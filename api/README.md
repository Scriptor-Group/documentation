# API Documentation

Documentation complète de l'API Devana.ai pour intégrer l'intelligence artificielle dans vos applications.

**Base URL :** `https://api.devana.ai`
**Authentification :** Bearer token (clé API)
**Format :** JSON
**Protocole :** HTTPS uniquement

---

## 📑 Table des matières

1. [Authentification](#authentification)
2. [Endpoints](#endpoints)
   - [Agents](#agents)
   - [Gestion des fichiers](#gestion-des-fichiers)
   - [Conversations & Completions](#conversations--completions)
3. [Intégration](#intégration)
4. [Démarrage rapide](#démarrage-rapide)
5. [Exemples](#exemples)
6. [Gestion des erreurs](#gestion-des-erreurs)
7. [Limites et quotas](#limites-et-quotas)

---

## Authentification

Toutes les requêtes API nécessitent une clé API fournie dans le header `Authorization`.

**Documentation complète :** [OAuth 2.0](./authentication/oauth.md)

```bash
Authorization: Bearer YOUR_API_KEY
```

**Obtenir une clé API :**
1. Créez un compte sur [app.devana.ai](https://app.devana.ai)
2. Accédez à Paramètres → API
3. Générez une nouvelle clé API

---

## Endpoints

### Agents

**Gestion des agents IA**

| Endpoint | Description | Documentation |
|----------|-------------|---------------|
| `GET /v1/agents` | Lister tous vos agents | [agents.md](./endpoints/agents.md) |
| `GET /v1/agents/:id` | Récupérer un agent spécifique | [agents.md](./endpoints/agents.md) |
| `POST /v1/agents` | Créer un nouvel agent | [agents.md](./endpoints/agents.md) |
| `PUT /v1/agents/:id` | Mettre à jour un agent | [agents.md](./endpoints/agents.md) |
| `DELETE /v1/agents/:id` | Supprimer un agent | [agents.md](./endpoints/agents.md) |
| `GET /v1/agents/:id/conversations` | Récupérer les conversations d'un agent | [agents.md](./endpoints/agents.md) |
| `POST /v1/agents/:id/files` | Ajouter des fichiers à un agent | [agents.md](./endpoints/agents.md) |
| `GET /v1/agents/:id/tools` | Récupérer les tools actifs | [agents.md](./endpoints/agents.md) |

**Documentation complète :**
- [Agents API](./endpoints/agents.md) - Endpoints internes (gestion complète)
- [Agents Public API](./endpoints/agents-public.md) - Endpoints publics (accès restreint)

### Gestion des fichiers

**Upload et gestion de documents**

| Endpoint | Description | Documentation |
|----------|-------------|---------------|
| `POST /api/upload` | Upload multi-fichiers (jusqu'à 5000) | [files.md](./endpoints/files.md) |

**Documentation complète :**
- [File Upload API](./endpoints/files.md) - Upload de fichiers avec extraction de contenu

### Conversations & Completions

**Génération de texte et gestion des conversations**

| Endpoint | Description | Documentation |
|----------|-------------|---------------|
| `POST /v1/chat/completions` | Créer une conversation avec un agent | [completions.md](./endpoints/completions.md) |
| `GET /v1/conversations` | Lister les conversations | [conversations/](./endpoints/conversations/) |
| `GET /v1/conversations/:id` | Récupérer une conversation | [conversations/](./endpoints/conversations/) |
| `DELETE /v1/conversations/:id` | Supprimer une conversation | [conversations/](./endpoints/conversations/) |
| `POST /v1/interactions` | Gérer les interactions utilisateur | [interactions.md](./endpoints/interactions.md) |

**Documentation complète :**
- [Chat Completions](./endpoints/completions.md) - Endpoint principal pour converser avec les agents
- [Conversations API](./endpoints/conversations/) - CRUD des conversations
- [Interactions](./endpoints/interactions.md) - Feedback et actions utilisateur

---

## Intégration

**Intégrer Devana.ai dans vos applications**

- **[IFrame Integration](./integration/iframe.md)** - Intégrer Devana.ai directement dans vos pages web
- **[IFrame Examples](./integration/iframe-examples.md)** - Exemples concrets d'intégration (chatbot, assistant)
- **[Tools](./integration/tools.md)** - Configuration et utilisation des outils (API calls, webhooks)

---

## Démarrage rapide

### Étape 1 : Obtenir une clé API

1. Créez un compte sur [app.devana.ai](https://app.devana.ai)
2. Accédez à **Paramètres → API**
3. Cliquez sur **"Générer une nouvelle clé"**
4. Copiez et conservez votre clé en lieu sûr

### Étape 2 : Premier appel API

**Lister vos agents :**

```bash
curl -X GET https://api.devana.ai/v1/agents \
  -H "Authorization: Bearer YOUR_API_KEY"
```

**Réponse :**
```json
{
  "success": true,
  "data": [
    {
      "id": "cm123abc",
      "name": "Assistant Support",
      "model": "gpt-4o",
      "publicChat": false
    }
  ]
}
```

### Étape 3 : Créer une conversation

```bash
curl -X POST https://api.devana.ai/v1/chat/completions \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "agentId": "cm123abc",
    "messages": [
      {"role": "user", "content": "Bonjour, peux-tu m'\''aider ?"}
    ]
  }'
```

**Réponse :**
```json
{
  "success": true,
  "data": {
    "id": "conv_abc123",
    "message": "Bonjour ! Bien sûr, je suis là pour vous aider. Que puis-je faire pour vous ?",
    "model": "gpt-4o",
    "tokens": 45,
    "sources": []
  }
}
```

---

## Exemples

### Conversation avec RAG (Retrieval Augmented Generation)

```bash
curl -X POST https://api.devana.ai/v1/chat/completions \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "agentId": "cm123abc",
    "messages": [
      {"role": "user", "content": "Quelles sont les fonctionnalités principales de notre produit ?"}
    ]
  }'
```

L'agent utilisera automatiquement les documents de sa base de connaissances pour répondre avec contexte.

### Conversation streaming

```bash
curl -X POST https://api.devana.ai/v1/chat/completions \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "agentId": "cm123abc",
    "messages": [{"role": "user", "content": "Explique-moi l'\''IA"}],
    "stream": true
  }'
```

Plus d'exemples : [completions.md](./endpoints/completions.md)

---

## Gestion des erreurs

Tous les endpoints retournent des codes HTTP standards.

| Code | Signification | Action |
|------|---------------|--------|
| `200` | Succès | Requête traitée correctement |
| `400` | Bad Request | Vérifier le format de la requête |
| `401` | Unauthorized | Clé API manquante ou invalide |
| `403` | Forbidden | Accès non autorisé à la ressource |
| `404` | Not Found | Ressource introuvable |
| `429` | Too Many Requests | Rate limit dépassé, ralentir les requêtes |
| `500` | Internal Server Error | Erreur serveur, réessayer plus tard |

**Format des erreurs :**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_AGENT_ID",
    "message": "L'agent spécifié n'existe pas ou vous n'y avez pas accès"
  }
}
```

---

## Limites et quotas

### Rate Limiting

**Limites par défaut :**
- **100 requêtes/minute** par clé API
- **10 000 tokens/heure** par agent

**Headers de réponse :**
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 87
X-RateLimit-Reset: 1640995200
```

**Si limite dépassée :**
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Trop de requêtes. Veuillez réessayer dans 42 secondes.",
    "retryAfter": 42
  }
}
```

### Quotas

Configurable par agent via l'interface d'administration :
- Tokens maximum par mois
- Nombre de fichiers maximum
- Taille maximale de base de connaissances

---

## Ressources

- [Guide de déploiement](../deployment/README.md) - Déployer Devana.ai on-premise
- [Changelogs](../changelogs/devana/) - Historique des versions
- [Formats supportés](../docs/supported-formats.md) - Types de fichiers acceptés
- [Requirements](../deployment/requirements.md) - Spécifications techniques

---

**Support :** support-it@devana.ai