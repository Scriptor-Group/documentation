# API Conversations - Documentation

Cette documentation décrit les endpoints de l'API conversations de Devana.ai pour les utilisateurs externes.

## Base URL

```
https://api.devana.ai/v1/conversations
```

## Authentication

L'API utilise l'authentification par **API Key** avec Bearer token dans les headers :

```
Authorization: Bearer {your_api_key}
```

---

## Endpoints

### 1. Métriques d'une conversation

#### `GET /:id/metrics`

Récupère les métriques détaillées d'un message de conversation spécifique, incluant les statistiques de tokens et les appels de conversation associés.

**Paramètres :**

- `:id` (string, CUID) : ID du message de conversation

**Headers :**

```
Authorization: Bearer {api_key}
Content-Type: application/json
```

**Réponse :**

**200 OK :**

```json
{
  "id": "string",
  "message": "string",
  "score": "number|null",
  "type": "user|assistant|system",
  "model": "string",
  "sources": "array|null",
  "status": "string|null",
  "agent": "string",
  "tokens": {
    "message": "number|null",
    "context": "number|null"
  },
  "conversationCalls": [
    {
      "type": "string",
      "messages": "object",
      "messagesTokens": "number|null",
      "outputContent": "string|null",
      "outputTokens": "number|null",
      "timeMs": "number|null"
    }
  ]
}
```

**Codes d'erreur :**

- `400` : Paramètres invalides (ID doit être un CUID valide)
- `403` : Accès refusé (pas d'autorisation pour cet agent)
- `404` : Message non trouvé

---

### 2. Messages d'une conversation

#### `GET /:id/messages`

Récupère tous les messages d'une conversation (message principal et ses réponses).

**Paramètres :**

- `:id` (string, CUID) : ID de la conversation

**Query Parameters (optionnels) :**

- `flagged` (boolean) : Filtre pour récupérer uniquement les messages marqués par la modération

**Headers :**

```
Authorization: Bearer {api_key}
Content-Type: application/json
```

**Exemples d'usage :**

```bash
GET /conversations/clwxyz123/messages
GET /conversations/clwxyz123/messages?flagged=true
```

**Réponse :**

**200 OK :**

```json
[
  {
    "id": "string",
    "date": "datetime",
    "message": "string",
    "role": "user|assistant|system",
    "model": "string",
    "score": "number|null",
    "sources": "array|null",
    "tokens": "number|null",
    "contextTokens": "number|null",
    "toolCalls": "object|null"
  }
]
```

**Codes d'erreur :**

- `400` : Paramètres invalides
- `403` : Accès refusé (pas d'autorisation pour cet agent)
- `404` : Agent non trouvé

---

### 3. Suppression d'une conversation

#### `DELETE /:id`

Supprime une conversation et tous ses messages enfants de manière récursive (soft delete).

**Paramètres :**

- `:id` (string, CUID) : ID de la conversation à supprimer

**Headers :**

```
Authorization: Bearer {api_key}
Content-Type: application/json
```

**Réponse :**

**200 OK :**

```json
{
  "message": "Conversation deleted successfully",
  "deletedId": "string"
}
```

**Codes d'erreur :**

- `400` : Paramètres invalides (ID doit être un CUID valide)
- `403` : Accès refusé (pas d'autorisation pour cet agent)
- `404` : Conversation non trouvée
- `500` : Erreur lors de la suppression

---

## Modèles de données

### Message de conversation

```typescript
{
  id: string; // CUID unique
  date: datetime; // Date de création
  message: string; // Contenu du message
  role: "user" | "assistant" | "system";
  model: string; // Modèle utilisé
  score: number | null; // Score de qualité
  sources: array | null; // Sources référencées
  tokens: number | null; // Nombre de tokens du message
  contextTokens: number | null; // Tokens de contexte
  toolCalls: object | null; // Appels d'outils effectués
}
```

### Métriques de conversation

```typescript
{
  id: string;
  message: string;
  score: number | null;
  type: "user" | "assistant" | "system";
  model: string;        // Nom du modèle custom ou modèle standard
  sources: array | null;
  status: string | null;
  agent: string;        // ID de l'agent
  tokens: {
    message: number | null;
    context: number | null;
  };
  conversationCalls: ConversationCall[];
}
```

### Appel de conversation

```typescript
{
  type: string; // Type d'appel
  messages: object; // Messages de l'appel
  messagesTokens: number | null;
  outputContent: string | null;
  outputTokens: number | null;
  timeMs: number | null; // Temps d'exécution en millisecondes
}
```

---

## Fonctionnalités spéciales

### Suppression récursive

- La suppression d'une conversation supprime automatiquement tous ses messages enfants et parents
- La suppression est récursive et traite toute la hiérarchie de messages

### Contrôle d'accès

- Chaque endpoint vérifie que l'utilisateur a les droits d'accès à l'agent associé
- Utilise le système de guards pour l'autorisation

### Support des modèles personnalisés

- Les métriques et messages retournent le nom du modèle personnalisé si disponible
- Fallback sur le modèle standard si pas de modèle personnalisé

---

## Exemples d'intégration

### Récupération des métriques d'un message

```javascript
const response = await fetch("/v1/conversations/clwxyz123/metrics", {
  headers: {
    Authorization: "Bearer your_api_key",
    "Content-Type": "application/json",
  },
});

const metrics = await response.json();
console.log(`Tokens utilisés: ${metrics.tokens.message}`);
```

### Filtrage des messages problématiques

```javascript
const flaggedMessages = await fetch(
  "/v1/conversations/clwxyz123/messages?flagged=true",
  {
    headers: {
      Authorization: "Bearer your_api_key",
    },
  }
);

const messages = await flaggedMessages.json();
console.log(`${messages.length} messages marqués par la modération`);
```

### Suppression sécurisée

```javascript
const deleteResponse = await fetch("/v1/conversations/clwxyz123", {
  method: "DELETE",
  headers: {
    Authorization: "Bearer your_api_key",
    "Content-Type": "application/json",
  },
});

if (deleteResponse.ok) {
  console.log("Conversation supprimée avec succès");
}
```
