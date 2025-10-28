![Devana](https://app.devana.ai/static/logo-small.png)

# Documentation Devana.ai

Bienvenue dans la documentation officielle de Devana.ai - Votre plateforme d'IA d'entreprise.

## 🎯 Pour qui ?

- **Développeurs** → Consultez la [documentation API](./api/README.md) pour intégrer Devana.ai
- **DevOps/SysAdmins** → Suivez le [guide de déploiement](./deployment/README.md) pour l'installation
- **Product Managers** → Découvrez les nouveautés dans les [changelogs](./changelogs/)
- **Intégrateurs** → Explorez les [SDKs et outils](./sdks/README.md) disponibles

## 🌟 Présentation

Devana.ai est une plateforme d'IA avancée qui permet aux organisations de :

- Déployer des assistants IA personnalisés
- Intégrer l'IA dans vos applications existantes
- Contrôler et monitorer l'usage de l'IA en environnement d'entreprise
- Garantir la confidentialité des données et la conformité
- Traiter et analyser des documents avec Odin, notre moteur de traitement de documents
- Suivre les usages et performances via des métriques détaillées

## 📚 Sections de documentation

### 📡 [API](./api/README.md)

Documentation complète de l'API REST pour intégrer Devana.ai dans vos applications.

- **Authentification** : OAuth 2.0
- **Endpoints** : Agents, Conversations, Completions
- **Intégration** : IFrame, Tools, Webhooks
- **[Formats supportés](./api/reference/supported-formats.md)** : Types de fichiers et formats de données

### 🛠️ [SDKs et Intégrations](./sdks/README.md)

Kits de développement et modules d'intégration pour Devana.ai.

- **[devana-ws-tools](./sdks/devana-ws-tools.md)** : Client WebSocket pour connexions temps réel
- **[n8n-nodes-devana](./sdks/n8n-nodes-devana.md)** : Module n8n pour l'automatisation de workflows
- **Outils dynamiques** : Enregistrement et exécution d'outils personnalisés
- **Intégrations** : IoT, Office, bases de données

### 🚀 [Déploiement](./deployment/README.md)

Guide complet pour déployer Devana.ai en on-premise ou cloud privé.

- **[Requirements](./deployment/requirements.md)** ⭐ : Dimensionnement matériel, LLM/Embeddings, réseau, sécurité
- **Configuration** : Variables d'environnement, [fournisseurs LLM](./deployment/configuration/llm-providers.md)
- **Infrastructure** : Kubernetes, Azure, Base de données PostgreSQL
- **Authentification** : SSO (Azure AD, Google, LDAP, OIDC...)
- **Monitoring** : Health checks, licences

### 📋 [Changelogs](./changelogs/)

Historique des versions et fonctionnalités.

- [Devana.ai](./changelogs/devana/README.md) - Plateforme principale
- [Odin](./changelogs/odin/README.md) - Service de traitement de documents

## 🚀 Démarrage rapide

- **Cloud** : Créez un compte sur [devana.ai](https://www.devana.ai), obtenez votre clé API → [Documentation API](./api/README.md)
- **On-Premise** : Consultez les [requirements](./deployment/requirements.md) puis suivez le [guide de déploiement](./deployment/README.md)

## 💡 Exemples d'utilisation

### Appel API simple

```bash
curl -X POST https://api.devana.ai/v1/chat/completions \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "agentId": "your-agent-id",
    "messages": [{"role": "user", "content": "Bonjour!"}]
  }'
```

### Intégration IFrame

```html
<iframe
  src="https://app.devana.ai/embed/your-agent-id"
  width="100%"
  height="600px"
  frameborder="0"
></iframe>
```

## 🏗️ Architecture

Devana.ai est composé de plusieurs services interconnectés :

- **Front-end** (Next.js) - Interface utilisateur web
- **API Server** (Node.js + GraphQL) - Backend principal
- **Odin** - Service de traitement et extraction de documents
- **Database** - PostgreSQL avec extensions vectorielles (pgvector)

Pour une vue détaillée de l'architecture, des flux de données et du dimensionnement, consultez la [documentation architecture complète](./deployment/architecture.md).

## 🔗 Liens utiles

- 🌐 [Site web](https://www.devana.ai)
- 📱 [Application](https://app.devana.ai)
- 🐙 [GitHub - Devana](https://github.com/Scriptor-Group/devana.ai)
- 🐙 [GitHub - Odin](https://github.com/Scriptor-Group/odin)

## 💬 Support

Pour obtenir de l'aide :

- 📖 **Documentation** : Consultez les guides dans ce repository
- 📧 **Support technique** : support-it@devana.ai
- 🐛 **Bugs & Issues** : Créez un ticket sur [tyr.devana.ai](https://tyr.devana.ai)
- 🔧 **Problèmes de déploiement** : Consultez le [troubleshooting guide](./deployment/troubleshooting/common-issues.md)

## 📄 Licence

© 2025 Scriptor Group - Tous droits réservés

---

**Dernière mise à jour** : Octobre 2025
**Version** : v0.6.0108
