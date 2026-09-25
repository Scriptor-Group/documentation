# Installation d'Argos avec Docker Compose

Installation de la pile complète sur un serveur : Argos (API, workers, dashboard), Odin et Zeus, PostgreSQL, Redis et un stockage S3 local (MinIO).

## 📑 Table des matières

- [Prérequis](#prérequis)
- [Installation](#installation)
- [Exposition en HTTPS](#exposition-en-https)
- [Vérification](#vérification)
- [Opérations courantes](#opérations-courantes)

## Prérequis

- Linux x86_64 ou arm64, **4 vCPU et 16 Go de RAM** minimum, disque dimensionné selon le volume à indexer.
- Docker Engine 24+ et Docker Compose v2.23+ (`docker compose version`).
- Identifiants du registre `registry.devana.ai`, fournis par Devana.
- Un client OAuth sur votre plateforme Devana (voir [Configuration](./configuration.md#connexion-au-dashboard-oauth-devana)).
- Accès réseau aux serveurs SharePoint (et au contrôleur de domaine pour Kerberos).

## Installation

### 1. Récupérer les fichiers

Créez un répertoire d'installation et copiez-y :

- [`docker-compose.yml`](./docker-compose/docker-compose.yml)
- [`env.example`](./docker-compose/env.example), à renommer en `.env`

```bash
mkdir -p /opt/argos && cd /opt/argos
# copier docker-compose.yml et env.example dans ce répertoire
cp env.example .env && chmod 600 .env
```

### 2. Renseigner la configuration

Éditez `.env` :

| Variable | Valeur |
|---|---|
| `PUBLIC_URL` | URL du dashboard vue par les utilisateurs, ex. `https://argos.example.com` (voir [Exposition en HTTPS](#exposition-en-https)) |
| `DEVANA_API_URL` | URL de l'API de votre plateforme Devana |
| `DEVANA_CLIENT_ID`, `DEVANA_CLIENT_SECRET` | Client OAuth créé pour Argos (URI de redirection : `<PUBLIC_URL>/auth/callback`) |
| `ENCRYPTION_KEY` | Clé de chiffrement des secrets stockés, 32 caractères minimum : `openssl rand -base64 48` |
| `POSTGRES_PASSWORD`, `MINIO_ROOT_PASSWORD` | Mots de passe de la base et du stockage (`openssl rand -hex 24`) |
| `LLM_VISION_API_URL`, `LLM_VISION_API_KEY`, `LLM_VISION_MODEL` | Modèle de vision utilisé par Zeus (API compatible OpenAI) |

> ⚠️ **Sauvegardez `ENCRYPTION_KEY`** : sans elle, les secrets enregistrés dans Argos (mots de passe SharePoint, keytabs, clés LLM) sont illisibles.

Les autres variables (versions des images, ports) sont décrites dans `env.example`. La liste complète figure dans [Configuration](./configuration.md).

### 3. Démarrer

```bash
docker login registry.devana.ai
docker compose up -d --wait
```

Au premier démarrage :

1. la base est créée (bases `argos` et `odin`, extensions `vector` et `pg_trgm`) ;
2. le bucket est créé et les migrations sont appliquées ;
3. l'API, les workers, le dashboard, Odin et Zeus démarrent.

`--wait` rend la main quand tous les services sont sains, en 1 à 2 minutes.

### 4. Première connexion

Ouvrez `PUBLIC_URL` et cliquez sur **Se connecter avec Devana**. Le premier utilisateur connecté devient administrateur. Pour désigner d'autres administrateurs, utilisez `BOOTSTRAP_ADMIN_EMAILS` ou *Paramètres › Utilisateurs*.

Ensuite :

1. *Paramètres › Modèles (LLM)* : ajoutez votre fournisseur et affectez les rôles (graphe, embeddings, vision).
2. *Connexions SharePoint › Nouvelle connexion* : voir [Connexions SharePoint](./sharepoint.md).
3. *Banc de test MCP › Connecter une application* : créez une clé API et configurez vos agents (voir [Serveur MCP](./mcp.md)).

## Exposition en HTTPS

Le dashboard écoute sur le port `3100` (`FRONT_PORT`). Il relaie aussi l'API et le serveur MCP (`/graphql`, `/auth`, `/files`, `/mcp`). Placez-le derrière votre reverse proxy HTTPS et renseignez `PUBLIC_URL` avec l'URL publique.

Exemple NGINX :

```nginx
server {
    listen 443 ssl;
    server_name argos.example.com;
    # ssl_certificate / ssl_certificate_key …

    client_max_body_size 20m;          # keytabs et certificats téléversés

    location / {
        proxy_pass http://127.0.0.1:3100;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_read_timeout 300s;
    }

    # Serveur MCP : une lecture peut attendre l'extraction d'un document (jusqu'à 15 min)
    location /mcp {
        proxy_pass http://127.0.0.1:3100;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering off;
        proxy_read_timeout 960s;
        proxy_send_timeout 960s;
    }
}
```

Les ports d'administration (API `4000`, PostgreSQL `5432`, console MinIO `9001`) ne sont publiés que sur `PUBLISH_ADDR` (`127.0.0.1` par défaut).

## Vérification

```bash
docker compose ps                                                     # tous les services « healthy » (migrate et minio-init : exited 0)
curl -s localhost:4000/readyz                                         # {"ok":true,"database":true,"redis":true}
curl -s -o /dev/null -w '%{http_code}\n' localhost:3100/healthz        # 200
curl -s -o /dev/null -w '%{http_code}\n' -X POST localhost:3100/mcp    # 401 (clé API requise)
docker compose logs zeus | grep "BullMQ worker ready"                  # Zeus prêt
```

Le dashboard affiche l'état des services dans *Paramètres › Système* (base, Redis, stockage, Odin).

## Opérations courantes

```bash
docker compose logs -f serveur-worker               # journaux des traitements
docker compose up -d --scale serveur-worker=4       # workers supplémentaires
docker compose pull && docker compose up -d --wait  # mise à jour (voir Exploitation)
docker compose down                                 # arrêt (les volumes sont conservés)
```

Données persistantes : volumes `argos_postgres-data`, `argos_minio-data`, `argos_redis-data`. Pour les sauvegardes, voir [Exploitation](./exploitation.md#sauvegardes).

Pour utiliser un PostgreSQL ou un stockage S3 existant, adaptez les variables de connexion (voir [Configuration](./configuration.md)) et retirez les services correspondants du fichier compose.
