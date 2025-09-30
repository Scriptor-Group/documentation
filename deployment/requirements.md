# Requirements pour le Déploiement de Devana.ai

**Version:** 1.0
**Date:** Septembre 2025
**Audience:** Architectes d'entreprise, DevOps, Décideurs IT

---

## 📑 Table des matières

1. [Vue d'ensemble](#-vue-densemble)
2. [Architecture de la plateforme](#-architecture-de-la-plateforme)
3. [Requirements Matériels](#-requirements-matériels)
   - [Configuration minimale](#configuration-minimale-environnement-de-test--50-utilisateurs)
   - [Configuration production](#configuration-recommandée-production--100-500-utilisateurs)
   - [Configuration entreprise](#configuration-entreprise-1000-10-000-utilisateurs)
4. [Requirements LLM & Embeddings](#-requirements-llm--embeddings)
   - [Scénario 1 : Cloud Providers](#scénario-1--cloud-providers-openai-azure-openai-anthropic)
   - [Scénario 2 : Auto-hébergé](#scénario-2--llm-auto-hébergés-recommandé-pour-entreprises)
   - [Scénario 3 : Hybride](#scénario-3--hybride-recommandé-pour-flexibilité)
5. [Requirements Réseau](#-requirements-réseau)
6. [Requirements Stockage](#-requirements-stockage)
7. [Requirements Sécurité](#-requirements-sécurité)
8. [Requirements Kubernetes](#-requirements-kubernetes)
9. [Monitoring & Observabilité](#-monitoring--observabilité)
10. [Ressources complémentaires](#-ressources-complémentaires)

---

## 📋 Vue d'ensemble

Ce document spécifie les exigences techniques pour le déploiement de la plateforme Devana.ai en environnement d'entreprise. Il est conçu pour les organisations à grande échelle nécessitant haute disponibilité, sécurité renforcée et conformité réglementaire.

### Portée

- Déploiement on-premise ou cloud privé
- Architecture multi-environnements (dev, staging, production)
- Support de 100 à 10 000+ utilisateurs concurrents
- Intégration avec infrastructure existante (SSO, réseau, stockage)

---

## 🏗️ Architecture de la plateforme

### Composants principaux

La plateforme Devana.ai s'articule autour de 8 composants critiques :

| Composant | Technologie | Rôle | Criticité |
|-----------|-------------|------|-----------|
| **Devana API** | Node.js 22.x | Backend principal, orchestration | ⭐⭐⭐ Critique |
| **Devana Frontend** | Next.js 15.x | Interface utilisateur web | ⭐⭐⭐ Critique |
| **Odin** | Python 3.12 | Traitement de documents, OCR, vectorisation | ⭐⭐⭐ Critique |
| **PostgreSQL** | 17.x | Base de données relationnelle | ⭐⭐⭐ Critique |
| **ChromaDB** | 1.0.6+ | Base de données vectorielle (RAG) | ⭐⭐⭐ Critique |
| **Meilisearch** | 1.13.3+ | Moteur de recherche plein texte | ⭐⭐ Important |
| **Redis** | 7.4+ | Cache, sessions, files d'attente | ⭐⭐⭐ Critique |
| **S3/MinIO** | Compatible S3 | Stockage objets (fichiers utilisateurs) | ⭐⭐⭐ Critique |

### Dépendances externes

- **LLM Provider** (OpenAI, Azure OpenAI, ou auto-hébergé)
- **Embedding Model** (OpenAI, auto-hébergé via vLLM/TGI)
- **Services optionnels** : SharePoint, Azure AD, services web externes

---

## 💻 Requirements Matériels

### Configuration minimale (Environnement de test / < 50 utilisateurs)

| Composant | CPU | RAM | Stockage | GPU | Notes |
|-----------|-----|-----|----------|-----|-------|
| **Devana API** | 2 cores | 4 GB | 20 GB SSD | - | Node.js + PM2 |
| **Frontend** | 1 core | 2 GB | 10 GB SSD | - | Next.js SSR |
| **Odin** | 2 cores | 4 GB | 30 GB SSD | - | Sans GPU : OCR basique |
| **PostgreSQL** | 2 cores | 8 GB | 100 GB SSD | - | + WAL logs |
| **ChromaDB** | 1 core | 4 GB | 50 GB SSD | - | Données vectorielles |
| **Meilisearch** | 1 core | 2 GB | 20 GB SSD | - | Index de recherche |
| **Redis** | 1 core | 2 GB | 10 GB SSD | - | Cache en mémoire |
| **S3/MinIO** | 1 core | 2 GB | 500 GB+ | - | Selon volumétrie |
| **TOTAL** | **11 cores** | **28 GB** | **740 GB** | - | Configuration de base |

### Configuration recommandée (Production / 100-500 utilisateurs)

| Composant | CPU | RAM | Stockage | GPU | Réplicas HA |
|-----------|-----|-----|----------|-----|-------------|
| **Devana API** | 3 cores | 4 GB | 20 GB SSD | - | 2-3 pods |
| **Frontend** | 2 cores | 4 GB | 10 GB SSD | - | 2-3 pods |
| **Odin** | 3 cores | 6 GB | 50 GB SSD | Optionnel* | 2 pods |
| **PostgreSQL** | 4 cores | 16 GB | 500 GB SSD | - | 1 master + 2 replicas |
| **ChromaDB** | 2 cores | 8 GB | 200 GB SSD | - | 2-3 replicas |
| **Meilisearch** | 2 cores | 4 GB | 50 GB SSD | - | 2 replicas |
| **Redis** | 2 cores | 8 GB | 20 GB SSD | - | 1 master + 2 replicas |
| **S3/MinIO** | 2 cores | 8 GB | 2 TB+ | - | Cluster 4 nodes |
| **Load Balancer** | 2 cores | 4 GB | 10 GB | - | Nginx/HAProxy |
| **TOTAL (par nœud)** | **8-12 cores** | **24-32 GB** | **1-3 TB** | - | 3 nœuds min |

\* GPU pour Odin : recommandé pour l'OCR haute performance (NVIDIA T4 ou supérieur)

### Configuration entreprise (1000-10 000+ utilisateurs)

| Composant | CPU | RAM | Stockage | GPU | Réplicas HA |
|-----------|-----|-----|----------|-----|-------------|
| **Devana API** | 4 cores/pod | 6 GB/pod | 30 GB SSD | - | 5-10 pods (HPA) |
| **Frontend** | 2 cores/pod | 4 GB/pod | 15 GB SSD | - | 5-10 pods (HPA) |
| **Odin** | 4 cores/pod | 8 GB/pod | 100 GB SSD | 1 GPU/pod | 3-5 pods |
| **PostgreSQL** | 8-16 cores | 64-128 GB | 2-5 TB NVMe | - | Cluster 3-5 nodes |
| **ChromaDB** | 4 cores/pod | 16 GB/pod | 1 TB SSD | - | 3-5 replicas |
| **Meilisearch** | 4 cores/pod | 8 GB/pod | 200 GB SSD | - | 3 replicas |
| **Redis** | 4 cores | 16 GB | 50 GB SSD | - | Cluster 6 nodes |
| **S3/MinIO** | 4 cores/node | 16 GB/node | 10+ TB | - | Cluster 8+ nodes |
| **Load Balancer** | 4 cores | 8 GB | 20 GB | - | HA pair |
| **Monitoring** | 4 cores | 16 GB | 500 GB | - | Prometheus+Grafana |

**Cluster Kubernetes recommandé :**
- **Nœuds de calcul** : 10-20 nœuds (32 cores, 128 GB RAM chacun)
- **Nœuds GPU** (LLM 70B+) : 4-8 nœuds GPU (NVIDIA H100/H200)
- **Nœuds GPU** (Embeddings) : 2-3 nœuds GPU (NVIDIA L4 ou L40S)
- **Nœuds de données** (PostgreSQL, ChromaDB) : 3-5 nœuds (NVMe, 128-256 GB RAM)
- **Réseau** : 100 Gbps minimum entre nœuds GPU, 10 Gbps pour le reste

---

## 🤖 Requirements LLM & Embeddings

### Scénario 1 : Cloud Providers (OpenAI, Azure OpenAI, Anthropic)

**Avantages :**
- Pas d'infrastructure GPU nécessaire
- Scalabilité automatique
- Latence optimisée (CDN global)
- Coûts prévisibles (pay-per-token)

**Requirements :**
- **Bande passante** : 100 Mbps minimum (synchrone), 1 Gbps recommandé
- **Latence** : < 100ms vers endpoints API (idéalement < 50ms)
- **Disponibilité** : SLA 99.9% minimum (Azure/OpenAI)
- **Coûts estimés** (production, 1000 utilisateurs actifs) :
  - LLM : $5,000-$15,000/mois selon modèle et volume
  - Embeddings : $500-$2,000/mois

**Configuration réseau :**
```bash
# Whitelist endpoints
api.openai.com           # OpenAI
*.openai.azure.com       # Azure OpenAI
api.anthropic.com        # Claude
```

**Limitations :**
- Dépendance externe critique
- Données transitent hors infrastructure (conformité RGPD/HIPAA)
- Contrôle limité sur latence et disponibilité

---

### Scénario 2 : LLM Auto-hébergés (Recommandé pour entreprises)

**Avantages :**
- Contrôle total des données (on-premise)
- Latence prévisible (<10ms en réseau local)
- Conformité réglementaire garantie
- Coûts fixes après investissement initial

#### Requirements matériels par modèle

**Modèles de production (recommandés)**

| Modèle | Taille | GPU Recommandé | VRAM | RAM système | Latence | Throughput |
|--------|--------|----------------|------|-------------|---------|------------|
| **Llama 3.1 70B** | 70B params | 2x H100 (80GB) | 160 GB | 512 GB | ~80ms | 100 tokens/s |
| **Llama 3.3 70B** | 70B params | 2x H100 (80GB) | 160 GB | 512 GB | ~80ms | 100 tokens/s |
| **Mixtral 8x22B** | 141B params | 4x H100 (80GB) | 320 GB | 768 GB | ~150ms | 60 tokens/s |
| **Qwen 2.5 72B** | 72B params | 2x H100 (80GB) | 160 GB | 512 GB | ~85ms | 95 tokens/s |
| **DeepSeek V3** | 671B params | 8x H200 (141GB) | 1128 GB | 2048 GB | ~300ms | 40 tokens/s |

**GPU nouvelle génération (recommandés)**

| GPU | VRAM | Architecture | Use Case | Disponibilité |
|-----|------|--------------|----------|---------------|
| **NVIDIA H100 SXM** | 80 GB | Hopper | Production 70B-141B | ⭐ Recommandé |
| **NVIDIA H200** | 141 GB | Hopper+ | Production 141B-671B | ⭐⭐ Optimal |
| **NVIDIA A100** | 80 GB | Ampere | Alternative 70B | Acceptable |

**Configuration recommandée (production) :**
- **LLM principal** : 2x serveurs GPU (Llama 3.3 70B ou Qwen 2.5 72B)
  - GPU : 2x NVIDIA H100 80GB par serveur (ou 2x H200 141GB pour modèles >100B)
  - CPU : 64 cores (AMD EPYC 9004 series ou Intel Xeon Sapphire Rapids)
  - RAM : 512 GB DDR5
  - Stockage : 4 TB NVMe Gen4 (modèles + cache)
  - Réseau : 400 Gbps InfiniBand ou 100 Gbps Ethernet

- **Embedding Model** : 2x serveurs GPU (e5-mistral-7b-instruct ou gte-Qwen2-7B)
  - GPU : 1x NVIDIA L4 24GB par serveur
  - CPU : 16 cores
  - RAM : 128 GB
  - Stockage : 1 TB NVMe
  - Réseau : 25 Gbps

**Architectures supportées :**
- **vLLM** : Plateforme de serving haute performance (recommandé)
- **TGI** (Text Generation Inference) : Solution Hugging Face
- **Ollama** : Déploiement simplifié (dev/test uniquement)
- **TensorRT-LLM** : Performance maximale (NVIDIA)

**Exemple de déploiement vLLM (Kubernetes) :**
```yaml
# Voir cluster-embeddings/embedding.yml pour référence complète
resources:
  limits:
    nvidia.com/gpu: 1     # Par réplica
    cpu: "4"
    memory: "24Gi"
replicas: 2                # Haute disponibilité
```

**Scalabilité (modèles 70B+) :**
- **100-500 utilisateurs** : 2x H100 80GB (Llama 3.3 70B)
- **500-2000 utilisateurs** : 4x H100 80GB (2 serveurs en load balancing)
- **2000-5000 utilisateurs** : 8x H100 80GB (4 serveurs) ou 4x H200 141GB
- **5000-10000 utilisateurs** : Cluster GPU dédié (12-16x H100 ou 8-12x H200)

**Note :** Les petits modèles (<70B) ne sont pas recommandés pour un usage production enterprise-grade nécessitant des capacités de raisonnement avancées.

---

### Scénario 3 : Hybride (Recommandé pour flexibilité)

**Configuration :**
- LLM principal : Auto-hébergé (données sensibles)
- LLM secondaire : Cloud (fallback, pic de charge)
- Embeddings : Auto-hébergé (volumétrie élevée)

**Bénéfices :**
- Résilience maximale
- Optimisation coûts
- Conformité assurée sur données critiques

---

## 🌐 Requirements Réseau

### Bande passante

| Usage | Minimum | Recommandé | Notes |
|-------|---------|------------|-------|
| **Interne (pod-to-pod)** | 1 Gbps | 10 Gbps | Latence critique |
| **Externe (utilisateurs)** | 100 Mbps | 1 Gbps | Selon charge |
| **LLM Cloud** | 50 Mbps | 500 Mbps | Streaming tokens |
| **Backup & Sync** | - | 1 Gbps+ | Hors heures de pointe |

### Latence maximale acceptable

| Connexion | Max acceptable | Optimal | Impact si dépassé |
|-----------|----------------|---------|-------------------|
| Frontend ↔ API | 200ms | < 50ms | UX dégradée |
| API ↔ PostgreSQL | 10ms | < 2ms | Performance critique |
| API ↔ ChromaDB | 50ms | < 10ms | Lenteur RAG |
| API ↔ LLM | 500ms | < 100ms | Timeout utilisateur |
| API ↔ Redis | 5ms | < 1ms | Cache inefficace |

### Ports requis

#### Externes (Internet)
| Port | Protocole | Service | Justification |
|------|-----------|---------|---------------|
| 443 | HTTPS | Frontend, API | Accès utilisateurs |
| 80 | HTTP | Redirection HTTPS | Automatique |

#### Internes (Cluster)
| Port | Service | Notes |
|------|---------|-------|
| 4666 | Devana API | HTTP/GraphQL |
| 5001 | WebSocket | Temps réel |
| 3000 | Frontend | Next.js SSR |
| 3003 | Odin | API interne |
| 5432 | PostgreSQL | Base de données |
| 8000 | ChromaDB | Vector DB |
| 7700 | Meilisearch | Recherche |
| 6379 | Redis | Cache |
| 9000 | MinIO | S3-compatible |

### Règles Firewall (exemples)

```bash
# Production - Règles strictes
# Frontend accessible uniquement via Load Balancer
LB -> Frontend:3000 (ALLOW)
* -> Frontend:3000 (DENY)

# API accessible uniquement depuis Frontend et LB
Frontend -> API:4666,5001 (ALLOW)
LB -> API:4666 (ALLOW)
* -> API:4666,5001 (DENY)

# Services internes isolés
API -> PostgreSQL:5432 (ALLOW)
API -> ChromaDB:8000 (ALLOW)
API -> Redis:6379 (ALLOW)
API -> Odin:3003 (ALLOW)
* -> Services-internes:* (DENY)

# LLM/Embeddings (si auto-hébergé)
API -> LLM-Cluster:8000 (ALLOW)
Odin -> Embeddings:8000 (ALLOW)
* -> LLM-Cluster:8000 (DENY)
```

---

## 💾 Requirements Stockage

### Dimensionnement par volume

| Utilisateurs | Documents/user | Stockage total | Croissance annuelle |
|--------------|----------------|----------------|---------------------|
| 100 | 500 | 500 GB | +200 GB/an |
| 500 | 500 | 2 TB | +1 TB/an |
| 1,000 | 500 | 5 TB | +2 TB/an |
| 5,000 | 500 | 25 TB | +10 TB/an |
| 10,000 | 500 | 50 TB | +20 TB/an |

**Calcul détaillé (1000 utilisateurs) :**
- **Fichiers utilisateurs** (S3/MinIO) : 5 TB (500 docs × 10 MB avg × 1000 users)
- **Base de données PostgreSQL** : 500 GB (métadonnées, conversations, logs)
- **ChromaDB** (vecteurs) : 200 GB (1000 dims × 4 bytes × 50M chunks)
- **Meilisearch** (index) : 100 GB (index inversé + cache)
- **Redis** (cache) : 20 GB (sessions + cache applicatif)
- **Backups** : 6 TB (retention 30 jours, snapshots quotidiens)
- **Logs** : 50 GB/mois (application + système)

**Total :** ~12 TB avec marge de 30%

### Performances requises

| Composant | IOPS | Throughput | Type de stockage |
|-----------|------|------------|------------------|
| **PostgreSQL** | 10,000+ | 500 MB/s | NVMe SSD (local) |
| **ChromaDB** | 5,000+ | 300 MB/s | SSD (local ou SAN) |
| **S3/MinIO** | 1,000+ | 1 GB/s | HDD RAID ou SSD |
| **Logs** | 500+ | 50 MB/s | SSD |

### Stratégie de backup

**RTO (Recovery Time Objective) : < 4h**
**RPO (Recovery Point Objective) : < 15min**

- **PostgreSQL** : WAL archiving + snapshots quotidiens
- **ChromaDB** : Snapshots quotidiens (données reconstructibles)
- **S3/MinIO** : Réplication géographique + snapshots hebdomadaires
- **Redis** : RDB snapshots + AOF (append-only file)

---

## 🔒 Requirements Sécurité

### Conformité réglementaire

| Standard | Requis si | Mesures Devana.ai |
|----------|-----------|-------------------|
| **RGPD** | Données UE | ✅ Chiffrement at-rest/in-transit, droit à l'oubli |
| **ISO 27001** | Certification sécurité | ⚠️ Conformité aux bonnes pratiques (non certifié) |
| **SOC 2 Type II** | SaaS compliance | ⚠️ Conformité aux bonnes pratiques (non certifié) |
| **HIPAA** | Données santé US | ⚠️ Configuration spécifique requise |
| **HDS** | Hébergement santé FR | ⚠️ Datacenter certifié requis |

### Chiffrement

**At-Rest :**
- PostgreSQL : Chiffrement TDE (Transparent Data Encryption)
- S3/MinIO : AES-256 (SSE-S3 ou SSE-KMS)
- Disques : LUKS ou équivalent

**In-Transit :**
- TLS 1.3 minimum (1.2 acceptable avec ciphers forts)
- Certificats signés (Let's Encrypt ou CA interne)
- Mutual TLS pour services internes (optionnel mais recommandé)

### Authentification & Autorisation

**SSO requis (production) :**
- OIDC / OAuth 2.0
- SAML 2.0
- LDAP / Active Directory

**RBAC (Role-Based Access Control) :**
- Admin système
- Admin organisation
- Gestionnaire d'agents
- Utilisateur standard
- Utilisateur lecture seule

**Audit Logs :**
- Toutes actions admin
- Accès aux données sensibles
- Modifications de configuration
- Retention : 1 an minimum

### Isolation réseau

**Zones de sécurité :**
```
[Internet] → [DMZ: LB, WAF] → [App: Frontend, API] → [Data: DB, Storage]
                                                    → [AI: LLM, Embeddings]
```

**Segmentation réseau (VLANs/Subnets) :**
- **DMZ** : Load Balancers, Reverse Proxy (10.0.1.0/24)
- **Application** : Frontend, API (10.0.10.0/24)
- **Services** : Odin, Redis, Meilisearch (10.0.20.0/24)
- **Données** : PostgreSQL, ChromaDB (10.0.30.0/24)
- **AI** : LLM, Embeddings (10.0.40.0/24)
- **Management** : Monitoring, Backup (10.0.99.0/24)

---

## ☸️ Requirements Kubernetes

### Version

- **Minimum** : Kubernetes 1.31+
- **Recommandé** : Kubernetes 1.32+ ou OpenShift 4.19+
- **Distributions supportées** :
  - Vanilla Kubernetes
  - Red Hat OpenShift
  - Rancher RKE2
  - VMware Tanzu
  - Amazon EKS / Azure AKS / Google GKE (cloud privé)

### Addons conseillés

| Addon | Usage | Recommandation |
|-------|-------|----------------|
| **Ingress Controller** | Routing HTTP/S | Nginx Ingress ou Traefik |
| **Cert Manager** | Certificats TLS | Let's Encrypt ou CA interne |
| **MetalLB** | Load Balancer on-prem | Si pas de LB matériel |
| **CSI Driver** | Stockage persistant | Rook-Ceph, Longhorn, ou SAN |
| **GPU Operator** | Support GPU NVIDIA | Si LLM auto-hébergés |
| **Prometheus** | Monitoring | + Grafana pour visualisation |
| **Loki** | Logs agrégés | Ou ELK stack |

### Namespaces recommandés

```yaml
- devana-prod          # Application production
- devana-staging       # Pre-production
- devana-services      # Services partagés (DB, Redis)
- devana-ai            # LLM & Embeddings
- monitoring           # Prometheus, Grafana, Loki
- cert-manager         # Gestion certificats
```

### Storage Classes

```yaml
# Haute performance (PostgreSQL, ChromaDB)
storageClassName: fast-ssd
provisioner: kubernetes.io/no-provisioner  # Local NVMe
volumeBindingMode: WaitForFirstConsumer

# Standard (logs, backups)
storageClassName: standard
provisioner: kubernetes.io/aws-ebs  # Ou équivalent

# Objets (S3/MinIO via CSI)
storageClassName: s3-csi
provisioner: ru.yandex.s3.csi
```

---

## 📊 Monitoring & Observabilité

### Métriques critiques à surveiller

| Catégorie | Métrique | Seuil d'alerte | Action |
|-----------|----------|----------------|--------|
| **API** | Latency p95 | > 500ms | Scale horizontalement |
| **API** | Error rate | > 1% | Investigate logs |
| **PostgreSQL** | Connections | > 80% max | Scale ou optimize queries |
| **PostgreSQL** | Slow queries | > 1s | Index manquants |
| **ChromaDB** | Query latency | > 200ms | Scale ou optimize embeddings |
| **Redis** | Memory usage | > 80% | Increase RAM ou eviction |
| **LLM** | Tokens/sec | < 50 | Scale GPU ou model |
| **Odin** | Queue size | > 100 | Scale pods |

### Stack recommandé

- **Prometheus** : Métriques système + applicatives
- **Grafana** : Dashboards + alerting
- **Loki** : Logs agrégés (alternative à ELK)
- **Jaeger / Tempo** : Tracing distribué (optionnel)
- **OpenTelemetry** : Instrumentation standardisée

### Alerting critique

```yaml
# Exemples de règles Prometheus
- alert: APIHighLatency
  expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 0.5
  for: 5m
  severity: warning

- alert: PostgreSQLDown
  expr: up{job="postgresql"} == 0
  for: 1m
  severity: critical

- alert: LLMGPUMemoryHigh
  expr: nvidia_gpu_memory_used_bytes / nvidia_gpu_memory_total_bytes > 0.9
  for: 10m
  severity: warning
```

---

## 📚 Ressources complémentaires

### Documentation technique

- [Guide de déploiement Kubernetes](./infrastructure/kubernetes/kube/README.md)
- [Configuration des variables d'environnement](./configuration/environment-variables.md)
- [Ajout de modèles personnalisés](./configuration/add-custom-model.md)
- [Configuration SSO](./authentication/README.md)
- [Monitoring et health checks](./monitoring/health-checks.md)

### Ressources externes

- **vLLM Documentation** : https://docs.vllm.ai
- **Kubernetes Best Practices** : https://kubernetes.io/docs/concepts/
- **PostgreSQL Performance Tuning** : https://wiki.postgresql.org/wiki/Performance_Optimization
- **NVIDIA GPU Operator** : https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/

---

## 🔄 Historique des révisions

| Version | Date | Auteur | Modifications |
|---------|------|--------|---------------|
| 1.0 | Sept 2025 | Devana.ai | Création initiale |

---

**Note légale :** Ce document est confidentiel et destiné uniquement aux clients et partenaires de Scriptor Group. Toute reproduction ou diffusion est interdite sans autorisation écrite.

**© 2025 Scriptor Group - Tous droits réservés**