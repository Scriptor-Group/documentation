# Installation d'Argos sur Kubernetes / OpenShift

Déploiement d'Argos (API, workers, dashboard), d'Odin, de Zeus et d'un Redis dédié. Ce déploiement s'appuie sur un **PostgreSQL** et un **stockage S3** existants.

## 📑 Table des matières

- [Prérequis](#prérequis)
- [Manifestes fournis](#manifestes-fournis)
- [Installation](#installation)
- [OpenShift](#openshift)
- [Vérification](#vérification)
- [Mise à l'échelle](#mise-à-léchelle)

## Prérequis

- `kubectl` (ou `oc` pour OpenShift), avec des droits sur le namespace cible.
- Identifiants du registre `registry.devana.ai`, fournis par Devana.
- **PostgreSQL 15+** avec les extensions `vector` (pgvector) et `pg_trgm`, et deux bases :
  - `argos` ;
  - `odin`.
- **Stockage S3** (AWS S3, MinIO, Ceph…) avec un bucket dédié et des identifiants en lecture / écriture. Ce bucket unique est partagé par Argos, Odin et Zeus.
- Un **Ingress controller** (exemples pour NGINX) ou les Routes OpenShift, et un certificat TLS.
- Un client OAuth sur votre plateforme Devana (voir [Configuration](./configuration.md#connexion-au-dashboard-oauth-devana)).

### Préparer PostgreSQL

Avec un compte administrateur :

```sql
CREATE ROLE argos LOGIN PASSWORD '<mot de passe>';
CREATE DATABASE argos OWNER argos;
CREATE DATABASE odin OWNER argos;
\c argos
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
```

Sur un service managé, activez les extensions `vector` et `pg_trgm` selon la procédure de l'hébergeur. Pour le dimensionnement et la haute disponibilité, voir [PostgreSQL](../infrastructure/database/db/postgresql.md).

## Manifestes fournis

| Fichier | Contenu |
|---|---|
| [`argos-config.yaml`](./kubernetes/argos-config.yaml) | ConfigMap `argos-config` : URL publique, Devana, Redis, S3 |
| [`secrets.env.example`](./kubernetes/secrets.env.example) | Modèle des Secrets `argos-secrets`, `odin-secrets`, `zeus-secrets` |
| [`argos-serveur.yaml`](./kubernetes/argos-serveur.yaml) | ServiceAccount, API (migrations en initContainer) et workers |
| [`argos-front-end.yaml`](./kubernetes/argos-front-end.yaml) | Dashboard |
| [`redis.yaml`](./kubernetes/redis.yaml) | Redis dédié |
| [`odin.yaml`](./kubernetes/odin.yaml) | Odin (instance dédiée) |
| [`zeus.yaml`](./kubernetes/zeus.yaml) | Zeus |
| [`ingress.yaml`](./kubernetes/ingress.yaml) | Exposition HTTPS (Ingress NGINX), avec un délai long pour `/mcp` |

Les images sont référencées avec une version précise, par exemple `argos-serveur:1.0.0`. Remplacez-la par la version qui vous est communiquée, identique pour `argos-serveur` et `argos-front-end`.

## Installation

### 1. Namespace et accès au registre

```bash
kubectl create namespace argos
kubectl -n argos create secret docker-registry argos-registry \
  --docker-server=registry.devana.ai \
  --docker-username=<UTILISATEUR> \
  --docker-password=<MOT_DE_PASSE>
```

Le ServiceAccount `argos` référence ce secret : tous les pods d'Argos, Odin et Zeus l'utilisent.

### 2. Configuration

Adaptez les valeurs marquées **À ADAPTER** :

- dans `argos-config.yaml` : `PUBLIC_URL`, `DEVANA_API_URL`, `S3_*` ;
- dans `odin.yaml` et `zeus.yaml` : `S3_*`, qui doivent désigner le même stockage et le même bucket ;
- dans `zeus.yaml` : le modèle de vision.

La référence complète est dans [Configuration](./configuration.md).

```bash
kubectl -n argos apply -f argos-config.yaml
```

### 3. Secrets

Complétez trois fichiers d'après [`secrets.env.example`](./kubernetes/secrets.env.example), puis :

```bash
kubectl -n argos create secret generic argos-secrets --from-env-file=argos-secrets.env
kubectl -n argos create secret generic odin-secrets  --from-env-file=odin-secrets.env
kubectl -n argos create secret generic zeus-secrets  --from-env-file=zeus-secrets.env
```

| Secret | Clés |
|---|---|
| `argos-secrets` | `DATABASE_URL` (base `argos`), `ENCRYPTION_KEY`, `S3_ACCESS_KEY`, `S3_SECRET_KEY`, `DEVANA_CLIENT_ID`, `DEVANA_CLIENT_SECRET` |
| `odin-secrets` | `DATABASE_URL` (base `odin`), `S3_ACCESS_KEY`, `S3_SECRET_KEY` |
| `zeus-secrets` | `S3_ACCESS_KEY`, `S3_SECRET_KEY`, `LLM_VISION_API_KEY` |

> ⚠️ **Sauvegardez `ENCRYPTION_KEY`** (coffre-fort) : sans elle, les secrets enregistrés dans Argos sont illisibles. Générez-la avec `openssl rand -base64 48`.

### 4. Déploiement

```bash
kubectl -n argos apply -f redis.yaml -f odin.yaml -f zeus.yaml
kubectl -n argos apply -f argos-serveur.yaml -f argos-front-end.yaml
kubectl -n argos apply -f ingress.yaml
kubectl -n argos rollout status deployment/argos-api deployment/argos-worker deployment/argos-front-end
```

L'initContainer `migrate` de l'API applique les migrations de la base à chaque déploiement. Elles sont idempotentes, donc sûres avec plusieurs réplicas. Odin applique ses propres migrations au démarrage.

### 5. Exposition

[`ingress.yaml`](./kubernetes/ingress.yaml) publie un seul hôte :

| Chemin | Service | Particularités |
|---|---|---|
| `/` | `argos-front-end` | Dashboard |
| `/graphql`, `/auth`, `/files` | `argos-api` | Corps jusqu'à 20 Mo (keytabs, certificats), délai 300 s |
| `/mcp` | `argos-api` | Serveur MCP et ses espaces (`/mcp/<espace>`) ; délai **960 s**, sans mise en tampon |

Le délai de `/mcp` couvre la lecture d'un document jamais traité : l'agent attend son extraction, jusqu'à 15 minutes par défaut.

Pour un autre Ingress controller, reproduisez ces chemins et délais. Le dashboard sait aussi relayer ces chemins vers l'API : un routage de tout l'hôte vers `argos-front-end` fonctionne, à condition d'y appliquer le délai du serveur MCP.

## OpenShift

Les images sont compatibles avec la SCC `restricted-v2` :
- les manifestes ne fixent aucun UID pour Argos ;
- les fichiers appartiennent au groupe 0 ;
- l'écriture est limitée à `/tmp` et au cache du dashboard.

Retirez `runAsUser` / `runAsGroup` des manifestes Redis, Odin et Zeus pour laisser OpenShift attribuer l'UID du projet.

```bash
oc new-project argos
oc create secret docker-registry argos-registry --docker-server=registry.devana.ai \
  --docker-username=<UTILISATEUR> --docker-password=<MOT_DE_PASSE>
# ConfigMap, Secrets et manifestes : mêmes commandes qu'avec kubectl (oc apply -f …)
```

Remplacez l'Ingress par des Routes TLS (edge) sur le même hôte :

```bash
oc create route edge argos        --service=argos-front-end --hostname=argos.example.com
oc create route edge argos-api    --service=argos-api --hostname=argos.example.com --path=/graphql
oc create route edge argos-auth   --service=argos-api --hostname=argos.example.com --path=/auth
oc create route edge argos-files  --service=argos-api --hostname=argos.example.com --path=/files
oc create route edge argos-mcp    --service=argos-api --hostname=argos.example.com --path=/mcp
oc annotate route argos-api argos-auth argos-files haproxy.router.openshift.io/timeout=300s
oc annotate route argos-mcp haproxy.router.openshift.io/timeout=960s
```

Le chemin d'une Route est un préfixe : `argos-mcp` couvre aussi les espaces MCP `/mcp/<espace>`.

## Vérification

```bash
kubectl -n argos get pods
kubectl -n argos exec deploy/argos-api -- node -e "fetch('http://127.0.0.1:4000/readyz').then(r=>r.text()).then(console.log)"
# {"ok":true,"database":true,"redis":true}
kubectl -n argos logs deploy/argos-zeus | grep "BullMQ worker ready"
curl -s -o /dev/null -w '%{http_code}\n' -X POST https://argos.example.com/mcp   # 401 (clé API requise)
```

Ouvrez ensuite `PUBLIC_URL` pour la [première connexion](./installation-docker-compose.md#4-première-connexion). La page *Paramètres › Système* affiche l'état de la base, de Redis, du stockage et d'Odin.

## Mise à l'échelle

- **API** : sans état, elle se met à l'échelle horizontalement (`replicas`, HPA sur le CPU).
- **Workers** : ils se répartissent les traitements sans doublon. Augmentez `replicas` pour synchroniser et traiter plus vite. La capacité d'extraction se règle dans *Paramètres › Traitement & Odin*.
- **Odin et Zeus** : la concurrence d'Odin (`BULLMQ_CONCURRENCY`) doit rester au moins égale au total des slots configurés dans Argos (24 par défaut). Pour Zeus, augmentez `BULLMQ_CONCURRENCY` ou les réplicas selon le volume de documents scannés.
- **Arrêt** : les workers terminent leurs traitements en cours (`terminationGracePeriodSeconds: 75`). Un traitement interrompu reprend automatiquement.
