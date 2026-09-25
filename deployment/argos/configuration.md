# Configuration d'Argos

La configuration d'Argos se fait à deux niveaux :

- les **variables d'environnement** couvrent uniquement l'infrastructure et les secrets d'amorçage ;
- **tout le reste se règle dans le dashboard** (*Paramètres*). Les modifications s'appliquent à chaud, sans redémarrage.

## 📑 Table des matières

- [Variables d'environnement](#variables-denvironnement)
- [Connexion au dashboard (OAuth Devana)](#connexion-au-dashboard-oauth-devana)
- [Odin et Zeus](#odin-et-zeus)
- [Réglages du dashboard](#réglages-du-dashboard)
- [Rôles des utilisateurs](#rôles-des-utilisateurs)

## Variables d'environnement

### Argos (API et workers)

| Variable | Obligatoire | Défaut | Description |
|---|---|---|---|
| `DATABASE_URL` | Oui | — | PostgreSQL (base `argos`), ex. `postgresql://argos:***@postgres:5432/argos` |
| `ENCRYPTION_KEY` | Oui | — | Chiffrement des secrets stockés (mots de passe SharePoint, keytabs, clés LLM). 32 caractères minimum, **à sauvegarder** |
| `REDIS_URL` | Oui | `redis://localhost:6379` | Redis dédié, base 0 (partagée avec Odin et Zeus), ex. `redis://argos-redis:6379/0` |
| `S3_ENDPOINT` | | AWS S3 | Point d'accès du stockage S3 (MinIO, Ceph…) |
| `S3_BUCKET` | | `sharepoint-mcp` | Bucket unique, partagé avec Odin et Zeus |
| `S3_REGION` | | `us-east-1` | Région S3 |
| `S3_ACCESS_KEY` / `S3_SECRET_KEY` | | — | Identifiants S3 |
| `S3_FORCE_PATH_STYLE` | | `true` | Adressage par chemin (MinIO, Ceph) ; `false` pour l'adressage virtuel |
| `DEVANA_API_URL` | Oui | `http://localhost:4666` | URL de l'API de la plateforme Devana (connexion au dashboard) |
| `DEVANA_CLIENT_ID` / `DEVANA_CLIENT_SECRET` | Oui | — | Client OAuth Devana |
| `PUBLIC_URL` | Oui | `http://localhost:3100` | URL du dashboard vue par les utilisateurs : retour de connexion (`<PUBLIC_URL>/auth/callback`) et adresse MCP affichée |
| `FRONTEND_URL` | | `http://localhost:3100` | Page d'arrivée après connexion, en général identique à `PUBLIC_URL` |
| `BOOTSTRAP_ADMIN_EMAILS` | | — | Emails promus administrateurs à leur première connexion (séparés par des virgules) |
| `LOG_LEVEL` | | `info` | `fatal`, `error`, `warn`, `info`, `debug`, `trace` |
| `PORT` | | `4000` | Port d'écoute HTTP |

Le rôle d'un conteneur est fixé par sa commande : `api`, `worker` ou `migrate` (migrations de la base). Sans commande, le conteneur exécute l'API et les workers dans le même processus, ce qui convient à une petite installation.

### Dashboard

| Variable | Défaut | Description |
|---|---|---|
| `SERVEUR_URL` | `http://serveur-api:4000` | URL interne de l'API Argos |
| `PORT` | `3100` | Port d'écoute HTTP |

### Certificats d'autorité internes

- Certificat d'autorité interne pour **SharePoint** : collez-le (PEM) dans la connexion SharePoint, sans désactiver la vérification TLS.
- Certificats pour d'autres services, par exemple un fournisseur LLM interne : montez le fichier dans le conteneur et renseignez `NODE_EXTRA_CA_CERTS`.

## Connexion au dashboard (OAuth Devana)

Les utilisateurs se connectent au dashboard avec leur compte **Devana** (OAuth). Pour l'activer :

1. Sur votre plateforme Devana, créez un **client OAuth** pour Argos :
   - URI de redirection : `<PUBLIC_URL>/auth/callback` (ex. `https://argos.example.com/auth/callback`) ;
   - portées : prénom, nom et email (`FIRST_NAME`, `LAST_NAME`, `EMAIL`).
2. Renseignez `DEVANA_API_URL`, `DEVANA_CLIENT_ID` et `DEVANA_CLIENT_SECRET`.

Le fonctionnement d'OAuth sur Devana est décrit dans [Documentation OAuth](../../api/authentication/oauth.md).

Accès au dashboard (*Paramètres › Utilisateurs › Connexion au dashboard*) :

- domaines email autorisés ;
- rôle attribué aux nouveaux utilisateurs ;
- durée des sessions.

Le premier utilisateur connecté, et ceux listés dans `BOOTSTRAP_ADMIN_EMAILS`, deviennent administrateurs.

> Le **serveur MCP** n'utilise pas cette connexion : les agents s'authentifient avec des **clés API** dédiées (voir [Serveur MCP](./mcp.md)).

## Odin et Zeus

Odin (extraction du contenu) et Zeus (analyse des fichiers et vision) forment une **instance dédiée à Argos**. Ils partagent le Redis d'Argos (base 0) et son bucket S3.

### Odin

| Variable | Valeur |
|---|---|
| `DATABASE_URL` | Base `odin`, ex. `postgresql://argos:***@postgres:5432/odin` |
| `REDIS_HOST` / `REDIS_PORT` / `REDIS_PASSWORD` | Redis d'Argos |
| `S3_ENDPOINT`, `S3_REGION`, `S3_BUCKET`, `S3_ACCESS_KEY`, `S3_SECRET_KEY` | Identiques à Argos (même bucket) |
| `PORT` / `HOST` | `3009` / URL interne d'Odin, ex. `http://argos-odin:3009` |
| `BULLMQ_CONCURRENCY` | Documents traités en parallèle : au moins le total des slots Odin d'Argos (24 par défaut) |
| `HOME` | `/tmp` (système de fichiers en lecture seule) |

### Zeus

| Variable | Valeur |
|---|---|
| `REDIS_HOST` / `REDIS_PORT` / `REDIS_PASSWORD` | Redis d'Argos |
| `S3_ENDPOINT`, `S3_REGION`, `S3_BUCKET`, `S3_ACCESS_KEY`, `S3_SECRET_KEY` | Identiques à Argos (même bucket) |
| `LLM_VISION_API_URL`, `LLM_VISION_API_KEY`, `LLM_VISION_MODEL` | Modèle de vision, API compatible OpenAI. Il décrit les images et lit les pages scannées |
| `BULLMQ_CONCURRENCY` | Fichiers analysés en parallèle (défaut `4`) |
| `TESSERACT_LANG` | Langues de l'OCR, ex. `fra+eng` |

Sans clé de vision, Zeus traite les documents textuels ; seules les images et les pages scannées restent sans description.

Si Redis ou le bucket ne sont pas ceux d'Argos, alignez-les dans *Paramètres › Traitement & Odin › Odin* (adresse Redis, bucket lu par Odin).

## Réglages du dashboard

| Page | Réglages |
|---|---|
| **Traitement & Odin** | Pipeline : pause, documents traités simultanément (rapide / lent), tentatives, démarrage du traitement lent, plages horaires du traitement lent, priorité aux demandes des utilisateurs. Synchronisation : taille des lots, jobs simultanés, taille max des fichiers. Graphe et recherche sémantique. Rétention des journaux |
| **Modèles (LLM)** | Fournisseurs (API compatible OpenAI, cloud ou auto-hébergée) et rôles : extraction du graphe, embeddings, vision |
| **Kerberos** | Realm, KDC, principal et keytab du compte de service SharePoint (voir [Connexions SharePoint](./sharepoint.md#kerberos)) |
| **Serveur MCP** | Outils exposés, instructions transmises aux agents, limites de réponse, espaces MCP, clés API, journal des appels (voir [Serveur MCP](./mcp.md)) |
| **Utilisateurs** | Rôles des utilisateurs, accès au dashboard |
| **Système** | État des services (base, Redis, stockage, Odin) et points d'intégration |

Chaque réglage complexe est documenté par une info-bulle dans le dashboard.

## Rôles des utilisateurs

| Rôle | Droits |
|---|---|
| **Lecteur** | Consultation : vue d'ensemble, métriques, documents, graphe, traitements |
| **Opérateur** | + synchronisations, relances, retraitements, banc de test MCP |
| **Administrateur** | + connexions SharePoint, secrets, Kerberos, modèles LLM, paramètres, utilisateurs, espaces MCP |
