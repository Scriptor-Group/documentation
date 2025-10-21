![Devana](https://app.devana.ai/static/logo-small.png)

# Documentation Devana.ai

Bienvenue dans la documentation officielle de Devana.ai - Votre plateforme d'IA d'entreprise.

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

### 📖 [Documentation générale](./docs/)

- [Formats supportés](./docs/supported-formats.md) - Types de fichiers et formats de données

## 🚀 Démarrage rapide

### Solution Cloud

1. Créez un compte sur [devana.ai](https://www.devana.ai)
2. Obtenez votre clé API
3. Suivez la [documentation API](./api/README.md) pour intégrer

### Solution On-Premise

1. Consultez le [guide de déploiement](./deployment/README.md)
2. Configurez votre environnement
3. Déployez avec Kubernetes

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

```
Devana.ai Platform
├── Front-end (Next.js)
├── API Server (Node.js + GraphQL)
├── Odin (Document Processing)
└── Database (PostgreSQL + Vector DB)
```

## 🔗 Liens utiles

- 🌐 [Site web](https://www.devana.ai)
- 📱 [Application](https://app.devana.ai)
- 🐙 [GitHub - Devana](https://github.com/Scriptor-Group/devana.ai)
- 🐙 [GitHub - Odin](https://github.com/Scriptor-Group/odin)

## 💬 Support

Pour le support technique :

- Consultez la documentation dans ce repository
- Contactez support-it@devana.ai pour les questions spécifiques

## 📄 Licence

© 2025 Scriptor Group - Tous droits réservés

---

**Dernière mise à jour** : Septembre 2025
**Version** : v0.6.0053
