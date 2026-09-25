# Argos — Connecteur SharePoint on-premise pour agents IA (MCP)

**Argos** indexe vos sites **SharePoint on-premise** (2013 → Subscription Edition) et met leurs documents à disposition de vos agents IA via un **serveur MCP** (Model Context Protocol). Un dashboard web permet de piloter les connexions, le traitement des documents et les accès.

> **Support** : pour toute question, contactez support-it@devana.ai

---

## ✨ Fonctionnalités

- **Synchronisation SharePoint** : arborescence et métadonnées de chaque bibliothèque et des pages SharePoint, périmètre par dossiers, filtres de métadonnées, synchronisation incrémentale (seules les modifications sont relues).
- **Authentification SharePoint** : NTLM, Kerberos (keytab), Basic, avec certificat d'autorité interne.
- **Extraction du contenu** : texte, tableaux et images des documents (PDF, Office, pages SharePoint…) par **Odin**, en deux passes :
  - **rapide** pour tout le périmètre ;
  - **complète** (OCR et description des images) ensuite, bridée pour que les demandes des utilisateurs restent prioritaires.
- **Lecture à la demande** : un document jamais traité, demandé par un agent, est extrait immédiatement en priorité.
- **Recherche** : plein texte, similarité de noms, recherche sémantique et **graphe de connaissances** (personnes, entreprises, projets…).
- **Serveur MCP** : outils de navigation, de lecture, de recherche et de comparaison, utilisables par Devana et tout client MCP (Claude, Cursor, VS Code, SDK…).
- **Accès maîtrisés** :
  - **clés API dédiées** par application ;
  - **espaces MCP** limités à certains sites ou dossiers, pour des agents aux droits restreints.
- **Supervision** : métriques de performance et de synchronisation dans le dashboard, sondes de santé, métriques Prometheus.

## 🏗️ Architecture

```
                         Utilisateurs (navigateur)          Agents IA (clients MCP)
                                    │  HTTPS                        │  HTTPS + clé API
                                    ▼                               ▼
                    ┌───────────────────────────────────────────────────────────┐
                    │  Reverse proxy / Ingress   (/ → dashboard, /mcp /graphql /auth → API)
                    └───────────────────────────────────────────────────────────┘
                          │                              │
                   ┌─────────────┐   ┌──────────────────────────────────┐
                   │  Dashboard  │──▶│  API Argos                        │──▶ Devana (connexion OAuth)
                   │ (front-end) │   │  dashboard · serveur MCP          │
                   └─────────────┘   └──────────────────────────────────┘
                                                  │
     SharePoint on-premise ◀── REST ──  ┌──────────────────────────────────┐
     (NTLM · Kerberos · Basic)          │  Workers Argos (×N)               │──▶ Modèles LLM
                                        │  synchronisation · traitements    │    (graphe, embeddings)
                                        └──────────────────────────────────┘
                                          │            │             │
                                    PostgreSQL       Redis         Stockage S3
                                    (pgvector)     (dédié)        (bucket unique)
                                                       │             │
                                        ┌──────────────────────────────────┐
                                        │  Odin + Zeus (instance dédiée)    │──▶ Modèle de vision
                                        │  extraction du contenu            │
                                        └──────────────────────────────────┘
```

| Composant | Image | Rôle |
|---|---|---|
| API | `registry.devana.ai/devana/argos-serveur` | Dashboard (API), serveur MCP, connexion Devana |
| Workers | `registry.devana.ai/devana/argos-serveur` | Synchronisation SharePoint, téléchargements, extraction, graphe, embeddings |
| Dashboard | `registry.devana.ai/devana/argos-front-end` | Interface web |
| Odin | `registry.devana.ai/devana/odin` | Extraction du contenu des documents |
| Zeus | `registry.devana.ai/devana/zeus` | Analyse des fichiers (PDF, Office, OCR) et description des images |
| PostgreSQL 15+ | `pgvector/pgvector` ou service managé | Index, métadonnées, contenu extrait, graphe (extensions `vector` et `pg_trgm`) |
| Redis 7 | `redis` | Files de traitement (dédié à Argos, Odin et Zeus) |
| Stockage S3 | MinIO, Ceph, AWS S3… | Fichiers téléchargés et résultats d'extraction |

> ⚠️ **Odin et Redis doivent être dédiés à Argos.** Argos et Odin échangent par des files de traitement dans Redis. Une instance Odin, ou un Redis, partagée avec une plateforme Devana mélangerait les demandes des deux services.

## ✅ Prérequis

### Accès

- **Registre d'images** : identifiants pour `registry.devana.ai`, fournis par Devana.
- **Plateforme Devana** : un client OAuth pour la connexion au dashboard (voir [Configuration](./configuration.md#connexion-au-dashboard-oauth-devana)).
- **SharePoint** : un compte de service ayant un accès en **lecture** aux sites à indexer (voir [Connexions SharePoint](./sharepoint.md)).
- **Modèles LLM** (API compatible OpenAI, cloud ou auto-hébergée) :
  - un modèle de **vision** pour Zeus ;
  - optionnellement, un modèle de **chat** (graphe de connaissances) et un modèle d'**embeddings** (recherche sémantique), configurés dans le dashboard.

### Ressources indicatives

| Composant | CPU (requête) | Mémoire | Stockage |
|---|---|---|---|
| API (×2) | 0,25 | 512 Mo – 1 Go | — |
| Workers (×2) | 0,25 | 512 Mo – 1,5 Go | temporaire : 4 Go |
| Dashboard | 0,05 | 192 – 384 Mo | — |
| Odin | 0,25 | 1 – 2 Go | — |
| Zeus | 0,5 | 2 – 3 Go | — |
| Redis | 0,05 | 128 – 512 Mo | — |
| PostgreSQL | 1 | 2 Go | 20 Go minimum ; croît avec le texte extrait et les embeddings |
| Stockage S3 | — | — | au moins le volume des fichiers indexés |

Pour une installation sur un seul serveur (Docker Compose) : **4 vCPU, 16 Go de RAM**, disque dimensionné selon le volume à indexer.

### Réseau

| Source | Destination | Port | Usage |
|---|---|---|---|
| Utilisateurs, agents | Argos (reverse proxy) | 443 | Dashboard et serveur MCP |
| Workers et API Argos | Serveurs SharePoint | 443 / 80 | API REST SharePoint |
| Workers et API Argos | Contrôleur de domaine (KDC) | 88 | Kerberos (si utilisé) |
| API Argos | Plateforme Devana | 443 | Connexion OAuth au dashboard |
| Workers, Zeus | Fournisseur LLM | 443 | Vision, graphe, embeddings |

## 🚀 Installation

| Mode | Usage | Guide |
|---|---|---|
| **Docker Compose** | Un serveur, pile complète (PostgreSQL, Redis, S3 inclus) | [Installation Docker Compose](./installation-docker-compose.md) |
| **Kubernetes / OpenShift** | Production, mise à l'échelle, PostgreSQL et S3 existants | [Installation Kubernetes](./installation-kubernetes.md) |

Après l'installation :

1. **Première connexion** : le premier utilisateur connecté (ou ceux listés dans `BOOTSTRAP_ADMIN_EMAILS`) devient administrateur.
2. **Modèles LLM** : *Paramètres › Modèles (LLM)*.
3. **Connexions SharePoint** : *Connexions SharePoint › Nouvelle connexion*, puis *Tester la connexion* et *Synchronisation complète*.
4. **Agents** : créez une clé API MCP et connectez vos agents (voir [Serveur MCP](./mcp.md)).

## 📚 Documentation par section

- [Installation Docker Compose](./installation-docker-compose.md) : installation sur un serveur
- [Installation Kubernetes / OpenShift](./installation-kubernetes.md) : manifestes, exposition, mise à l'échelle
- [Configuration](./configuration.md) : variables d'environnement, OAuth Devana, réglages du dashboard
- [Connexions SharePoint](./sharepoint.md) : authentification (NTLM, Kerberos, Basic), périmètre, métadonnées
- [Serveur MCP](./mcp.md) : clés API, espaces, configuration des clients, outils
- [Exploitation](./exploitation.md) : supervision, sauvegardes, mises à jour, dépannage
