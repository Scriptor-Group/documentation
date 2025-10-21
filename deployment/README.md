# Déploiement Devana.ai

Documentation complète pour le déploiement de Devana.ai en environnement on-premise ou cloud privé.

> **Confidentialité** : Ce document contient des informations sensibles. Ne pas diffuser sans autorisation.
>
> **Support** : Pour toute question, contactez support-it@devana.ai

## 📚 Documentation par section

### 🚀 [Requirements & Dimensionnement](./requirements.md)
**⭐ Commencez ici** - Documentation complète des requirements matériels, logiciels, réseau et sécurité pour déployer Devana.ai. Inclut le dimensionnement pour LLM/Embeddings auto-hébergés.

- Requirements matériels par taille d'organisation
- Dimensionnement LLM & Embeddings (cloud vs auto-hébergé)
- Requirements réseau et latence
- Sécurité et conformité (RGPD, ISO 27001, SOC 2)
- Checklist de déploiement complète

### ⚙️ Configuration
- [Variables d'environnement](./configuration/environment-variables.md) - Configuration complète de tous les services
- [Fournisseurs LLM](./configuration/llm-providers.md) - Configuration des providers LLM & Embeddings (cloud et auto-hébergés)
- [Template de documentation agent](./configuration/agent-template.md) - Création d'agents personnalisés

### 🏗️ Infrastructure
- [Architecture](./architecture.md) - Vue d'ensemble technique et diagrammes
- [Kubernetes](./infrastructure/kubernetes/kube/README.md) - Déploiement sur cluster K8s/OpenShift
- [Base de données PostgreSQL](./infrastructure/database/db/postgresql.md) - Configuration et tuning
- [Azure Cloud](./infrastructure/azure/azure/README.md) *(en cours de rédaction)*

### 🔐 Authentification
- [Vue d'ensemble SSO](./authentication/README.md) - Providers supportés
- Configuration par provider : [Azure AD](./authentication/sso/azure.md), [Google](./authentication/sso/google.md), [LDAP](./authentication/sso/ldap.md), [OIDC](./authentication/sso/oidc.md), etc.

### 📊 Monitoring & Services
- [Health Checks](./monitoring/health-checks.md) - Surveillance de la plateforme
- [Gestion des licences](./monitoring/license.md) - Monitoring d'utilisation
- [Architecture des services](./services/services/) - Devana API, Odin

### 🔧 Troubleshooting
- [Problèmes courants](./troubleshooting/common-issues.md) - Guide de résolution
- [Migrations](./troubleshooting/migration-sharepoint.md) - Guides de migration spécifiques

---

## Démarrage rapide

Pour les détails complets d'architecture, de dimensionnement et de flux de données, consultez [architecture.md](./architecture.md).

# Installation

Pour effectuer l'installation de Devana, vous devez suivre les étapes décrites dans le document suivant : 
- [Installation Kubernetes](./infrastructure/kubernetes/kube/README.md).
- [Tutoriels Azure](./infrastructure/azure/azure/README.md) *(en cours de rédaction)*

# Déploiement de la base de données

Pour déployer la base de données PostgreSQL de Devana, vous pouvez suivre les instructions présentes dans le document suivant :
- [Déploiement de la base de données](./infrastructure/database/db/postgresql.md).

# Configuration des fournisseurs LLM

Pour configurer les fournisseurs LLM (cloud ou auto-hébergés) et les modèles personnalisés dans Devana, consultez la documentation suivante :
- [Fournisseurs LLM](./configuration/llm-providers.md).

