# API Documentation

Documentation complète de l'API Devana.ai pour intégrer l'IA dans vos applications.

## 🔐 Authentification

- [OAuth 2.0](./authentication/oauth.md) - Authentification et autorisation

## 📡 Endpoints

### Agents
- [Agents API](./endpoints/agents.md) - Gestion complète des agents (CRUD)
- [Agents Public API](./endpoints/agents-public.md) - API publique pour les agents

### Conversations & Completions
- [Chat Completions](./endpoints/completions.md) - Génération de texte et conversations
- [Conversations API](./endpoints/conversations/) - Gestion des conversations
- [Interactions](./endpoints/interactions.md) - Gestion des interactions

## 🔌 Intégration

- [IFrame Integration](./integration/iframe.md) - Intégrer Devana.ai dans vos applications web
- [IFrame Examples](./integration/iframe-examples.md) - Exemples d'intégration
- [Tools](./integration/tools.md) - Liste des outils disponibles et leur configuration

## 🚀 Démarrage rapide

1. **Obtenir une clé API** : Créez un compte sur [devana.ai](https://app.devana.ai)
2. **Authentification** : Utilisez votre clé API dans le header `Authorization: Bearer <API_KEY>`
3. **Premier appel** : Testez avec l'endpoint `/v1/agents` pour lister vos agents

## 📝 Exemples

```bash
# Lister vos agents
curl -X GET https://api.devana.ai/v1/agents \
  -H "Authorization: Bearer YOUR_API_KEY"

# Créer une conversation
curl -X POST https://api.devana.ai/v1/chat/completions \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "agentId": "your-agent-id",
    "messages": [{"role": "user", "content": "Bonjour!"}]
  }'
```

## 🔗 Ressources

- [Documentation de déploiement](../deployment/README.md)
- [Changelogs](../changelogs/devana/)
- [Formats supportés](../docs/supported-formats.md)