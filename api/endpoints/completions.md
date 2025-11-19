# Chat Completions API

Documentation de l'endpoint `/v1/chat/completions` pour générer des réponses avec vos agents IA.

**Endpoint :** `POST https://api.devana.ai/v1/chat/completions`
**Compatible :** OpenAI Chat Completions API + extensions Devana.ai

---

## 📑 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Authentification](#authentification)
3. [Paramètres de la requête](#paramètres-de-la-requête)
4. [Exemples d'utilisation](#exemples-dutilisation)
5. [Streaming](#streaming)
6. [RAG & Sources](#rag--sources)
7. [Tools Calls](#tools-calls)
8. [Gestion des erreurs](#gestion-des-erreurs)
9. [Paramètres avancés](#paramètres-avancés)

---

## Vue d'ensemble

L'endpoint `/v1/chat/completions` est compatible avec l'API OpenAI tout en offrant des fonctionnalités avancées :

**Fonctionnalités principales :**

- ✅ Gestion des historiques de conversations
- ✅ Support des fichiers en pièces jointes
- ✅ RAG (Retrieval Augmented Generation) automatique
- ✅ Tools calls avec validation et contrôle
- ✅ Streaming de réponses (Server-Sent Events)
- ✅ Configuration avancée par agent
- ✅ Metadata et webhooks pour analytics
- ✅ Mode debug pour développement
- ✅ Retry automatique avec backoff exponentiel

---

## Authentification

Incluez votre clé API dans le header `Authorization` :

```bash
Authorization: Bearer VOTRE_TOKEN
```

Le système :

- Hydrate automatiquement l'utilisateur à partir du token
- Vérifie les droits d'accès aux agents

## Effectuer des requêtes

### Endpoint

```
POST /v1/chat/completions
```

### Corps de la Requête

| Paramètre              | Type         | Obligatoire | Description                                                                                                  |
| ---------------------- | ------------ | ----------- | ------------------------------------------------------------------------------------------------------------ |
| `model`                | string       | Oui         | Un ID d'agent créé dans le système.                                                                          |
| `messages`             | array        | Oui         | Tableau des messages composant la conversation (maximum 4 messages).                                         |
| `temperature`          | float        | Non         | Contrôle l'aléatoire dans les réponses. Valeurs entre 0 et 1. Défaut: 0.8 ou valeur configurée pour l'agent. |
| `max_tokens`           | integer      | Non         | Nombre maximum de tokens à générer.                                                                          |
| `top_p`                | float        | Non         | Contrôle la diversité via l'échantillonnage nucleus.                                                         |
| `n`                    | integer      | Non         | Nombre de completions à générer.                                                                             |
| `stop`                 | string/array | Non         | Séquences où l'API arrêtera la génération.                                                                   |
| `stopSequences`        | array        | Non         | Séquences additionnelles où l'API arrêtera la génération.                                                    |
| `frequency_penalty`    | float        | Non         | Pénalité de fréquence pour réduire la répétition.                                                            |
| `presence_penalty`     | float        | Non         | Pénalité de présence pour encourager la nouveauté.                                                           |
| `stream`               | boolean      | Non         | Si vrai, les deltas de messages partiels seront envoyés.                                                     |
| `conversation_id`      | string       | Non         | ID de la conversation existante à continuer.                                                                 |
| `response_format`      | string       | Non         | Format de réponse souhaité (par exemple, { type: "text" \| "json_object"}). (compatible selon le LLM actif)  |
| `lang`                 | string       | Non         | Langue pour la réponse. Par défaut, locale de l'utilisateur ou 'fr'.                                         |
| `files`                | array        | Non         | Tableau des IDs de fichiers à inclure dans le contexte.                                                      |
| `clientModel`          | string       | Non         | Modèle spécifique à utiliser avec la configuration Devana AI. Défaut: valeur de DEFAULT_MODEL.               |
| `custom`               | object       | Non         | Options de configuration personnalisées, comme `disableAutomaticIdentity`.                                   |
| `metadata`             | object       | Non         | Metadata pour les dashboards et logging via webhooks (Si configurés).                                        |
| `headers`              | object       | Non         | Headers complémentaires pour l'authentification des tools calls.                                             |
| `identity`             | object       | Non         | Informations d'identité de l'utilisateur pour personnaliser le comportement de l'agent.                      |
| `asyncRagScore`        | boolean      | Non         | Si vrai, on n'attend pas le calcul du score RAG.                                                             |
| `attachementsFastMode` | boolean      | Non         | Si vrai, nous ignorons la vision sur les attachements                                                        |
| `hiddenMode`           | boolean      | Non         | Si vrai, la conversation ne sera pas visible dans l'interface utilisateur Devana.                            |

### Vérifications et limites

Le système effectue automatiquement plusieurs vérifications :

- Maximum 4 messages par requête
- Température entre 0 et 1
- Présence obligatoire d'au moins un message utilisateur
- Vérification des limites d'utilisation par utilisateur
- Validation des droits d'accès à l'agent

### Tool Calls

Les outils ajoutés via l'interface par l'utilisateur sont appelés automatiquement.

#### Headers envoyés aux outils

```typescript
{
  "x-user-id": string; // ID de l'utilisateur actuel Devana (si disponible)
  "x-agent-id": string; // ID de l'agent actuel utilisé pour la réponse
  // Autres headers personnalisés ajoutés lors de la requête
}
```

#### Support de confirmation des tool calls

Le système prend en charge la confirmation d'exécution d'outils via un format spécial :

```
[tool:confirm:{"messageId":"ID_MESSAGE","confirm":true|false}]
```

### Objet Message

```typescript
{
  role: "user" | "system" | "assistant",
  content: string
}
```

### Exemple de Requête

```bash
curl -X POST https://api.devana.ai/v1/chat/completions \
  -H "Authorization: Bearer VOTRE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "agent_id",
    "messages": [
      {"role": "user", "content": "Bonjour!"}
    ],
    "temperature": 0.7,
    "stream": false
  }'
```

## Réponses

### Réponse Standard

```typescript
{
  id: string;                  // ID du message
  object: "chat.completion";   // Type d'objet
  created: number;             // Timestamp
  model: string;               // ID du modèle utilisé
  conversation_id: string;     // ID de conversation
  rag_score: number;           // Score de la réponse (qualité)
  debug: {
    tool_calls: any[];         // Outils appelés durant la génération
    sources: any[];            // Sources utilisées pour la réponse
    metadata: object;          // Métadonnées additionnelles
  };
  choices: [{
    index: number;
    message: {
      role: "assistant";
      content: string;
      tool_calls: null;
      score: {
        value: number;         // Score de la réponse
      };
    };
    finish_reason: string | null;
    logprobs: null;
  }];
  usage: {
    prompt_tokens: number;     // Tokens dans le prompt
    completion_tokens: number; // Tokens dans la completion
    total_tokens: number;      // Total des tokens utilisés
  };
}
```

### Réponse en Streaming

Quand `stream: true`, l'API renvoie un flux d'événements server-sent. Chaque événement contient un delta de la réponse :

```typescript
{
  id: string;
  object: "chat.completion.chunk";
  created: number;
  model: string;
  conversation_id: string;
  rag_score: number | null;    // Présent uniquement dans le dernier chunk
  debug: object | null;        // Présent uniquement dans le dernier chunk
  choices: [{
    index: number;
    delta: {
      content: string;
    };
    finish_reason: null | "stop";
    logprobs: null;
  }];
  usage: {                     // Mis à jour dans chaque chunk
    prompt_tokens: number;
    completion_tokens: number;
    total_tokens: number;
  };
}
```

Le flux se termine par un chunk avec `finish_reason: "stop"` suivi d'un message `[DONE]`.

## Gestion des Erreurs

L'API utilise les codes de réponse HTTP conventionnels :

- `400` - Mauvaise Requête (paramètres invalides, messages manquants, etc.)
- `403` - Interdit (accès refusé ou limite d'utilisation atteinte)
- `404` - Non Trouvé (modèle ou conversation non trouvé)
- `500` - Erreur Interne du Serveur

Le système implémente une stratégie de retry avec backoff exponentiel pour les erreurs temporaires :

- Maximum 3 tentatives par défaut
- Délai initial de 500ms
- Délai doublé à chaque nouvelle tentative

### Format de Réponse d'Erreur

```typescript
{
  error: string; // Message d'erreur détaillé
}
```

## Limitation de Débit

L'API inclut une limitation de débit basée sur l'utilisateur :

- Les métriques utilisateur sont vérifiées avant le traitement des requêtes
- Quand les limites sont atteintes, retourne le code status 403

## Fonctionnalités Spéciales

### Contexte de Conversation

- Supporte la continuation des conversations existantes via `conversation_id`
- Maintient l'historique complet des conversations et les pièces jointes
- Suit automatiquement l'utilisation des tokens (prompt et réponse)
- Calcule et stocke les tokens de contexte pour optimiser les coûts

### Support des Fichiers

- Accepte les IDs de fichiers dans la requête
- Maintient les associations de fichiers avec les messages de conversation
- Combine automatiquement les fichiers attachés à la conversation et à la requête actuelle

### Configuration Agent/Modèle

- Supporte les agents AI personnalisés et la configuration Devana AI par défaut
- Paramètres d'identité et de comportement configurables par agent
- Connectivité web optionnelle pour des réponses améliorées
- Gestion des versions du chat par agent

### Surveillance et Analytique

- Suit les requêtes réseau détaillées
- Enregistre le statut de vérification et le scoring précis
- Supporte l'attribution des sources pour les réponses
- Maintient des métriques détaillées d'utilisation des tokens
- Fournit un système de debug en temps réel

### Particularités

- **Mode Chappie** disponible pour certains agents (vérification automatique)
- Gestion automatique de la langue selon les préférences utilisateur
- Support multi-modèles avec possibilité de spécifier le modèle client
- Vérification automatique des droits d'accès aux agents
- Gestion des statuts de conversation (PENDING, DONE, ERROR)

### Paramètre asyncRagScore

- Si `true`, la réponse est renvoyée immédiatement sans attendre le calcul du score RAG. Le score RAG sera calculé en arrière-plan. Les réponses n'incluront plus les sources, qui seront systématiquement un tableau vide (`[]`).

# Exemples d'Utilisation

## Conversation Simple

### Requête

```bash
curl -X POST https://api.devana.ai/v1/chat/completions \
  -H "Authorization: Bearer VOTRE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "default-agent",
    "messages": [
      {
        "role": "user",
        "content": "Quelle est la capitale de la France?"
      }
    ],
    "temperature": 0.7
  }'
```

### Réponse

```json
{
  "id": "msg_123abc",
  "object": "chat.completion",
  "created": 1698152365,
  "model": "default-agent",
  "conversation_id": "conv_456def",
  "rag_score": 0.95,
  "debug": {
    "tool_calls": null,
    "sources": null,
    "metadata": null
  },
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "La capitale de la France est Paris.",
        "tool_calls": null,
        "score": {
          "value": 0.95
        }
      },
      "finish_reason": "stop",
      "logprobs": null
    }
  ],
  "usage": {
    "prompt_tokens": 9,
    "completion_tokens": 8,
    "total_tokens": 17
  }
}
```

## Conversation avec Historique

### Requête

```bash
curl -X POST https://api.devana.ai/v1/chat/completions \
  -H "Authorization: Bearer VOTRE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "default-agent",
    "conversation_id": "conv_456def",
    "messages": [
      {
        "role": "user",
        "content": "Et combien d'habitants y vivent?"
      }
    ]
  }'
```

## Utilisation du Streaming

### Requête

```bash
curl -X POST https://api.devana.ai/v1/chat/completions \
  -H "Authorization: Bearer VOTRE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "default-agent",
    "messages": [
      {
        "role": "user",
        "content": "Raconte moi une histoire"
      }
    ],
    "stream": true
  }'
```

### Réponse (flux d'événements)

```
data: {"id":"msg_789ghi","object":"chat.completion.chunk","created":1698152366,"model":"default-agent","conversation_id":"conv_456def","choices":[{"index":0,"delta":{"content":"Il"},"finish_reason":null,"logprobs":null}],"usage":{"prompt_tokens":5,"completion_tokens":1,"total_tokens":6}}

data: {"id":"msg_789ghi","object":"chat.completion.chunk","created":1698152366,"model":"default-agent","conversation_id":"conv_456def","choices":[{"index":0,"delta":{"content":" était"},"finish_reason":null,"logprobs":null}],"usage":{"prompt_tokens":5,"completion_tokens":2,"total_tokens":7}}

data: {"id":"msg_789ghi","object":"chat.completion.chunk","created":1698152366,"model":"default-agent","conversation_id":"conv_456def","choices":[{"index":0,"delta":{"content":" une"},"finish_reason":null,"logprobs":null}],"usage":{"prompt_tokens":5,"completion_tokens":3,"total_tokens":8}}

...

data: {"id":"msg_789ghi","object":"chat.completion.chunk","created":1698152366,"model":"default-agent","conversation_id":"conv_456def","rag_score":0.87,"debug":{"tool_calls":[],"sources":null,"metadata":{}},"choices":[{"index":0,"delta":{"content":""},"finish_reason":"stop","logprobs":null}],"usage":{"prompt_tokens":5,"completion_tokens":150,"total_tokens":155}}

data: [DONE]
```

## Conversation avec Fichiers

### Requête

```bash
curl -X POST https://api.devana.ai/v1/chat/completions \
  -H "Authorization: Bearer VOTRE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "default-agent",
    "messages": [
      {
        "role": "user",
        "content": "Analyse ce document"
      }
    ],
    "files": ["file_123abc"],
    "temperature": 0.3
  }'
```

## Utilisation d'un Agent Personnalisé avec Debug et Identité

### Requête

```bash
curl -X POST https://api.devana.ai/v1/chat/completions \
  -H "Authorization: Bearer VOTRE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "agent-specialise-juridique",
    "messages": [
      {
        "role": "user",
        "content": "Explique moi le concept de force majeure"
      }
    ],
    "lang": "fr",
    "custom": {
      "disableAutomaticIdentity": true
    },
    "identity": {
      "name": "Conseiller Juridique",
      "expertise": "Droit Civil"
    },
    "metadata": {
      "sessionContext": "consultation",
      "clientSector": "Assurance"
    }
  }'
```

## Confirmation d'Exécution d'Outil

### Requête

```bash
curl -X POST https://api.devana.ai/v1/chat/completions \
  -H "Authorization: Bearer VOTRE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "default-agent",
    "conversation_id": "conv_456def",
    "messages": [
      {
        "role": "user",
        "content": "[tool:confirm:{\"messageId\":\"msg_123abc\",\"confirm\":true}]"
      }
    ]
  }'
```

## Gestion d'Erreur et Retry

### Exemple de Réponse d'Erreur

```json
{
  "error": "Limit reached"
}
```

# Conseils d'Utilisation Avancés

1. **Gestion des Tokens**

   - Surveillez l'utilisation des tokens dans les réponses pour estimer les coûts
   - Ajustez `max_tokens` selon vos besoins spécifiques
   - Le système calcule automatiquement les tokens pour le prompt et la réponse

2. **Optimisation des Réponses**

   - Utilisez une température basse (0.1-0.3) pour des réponses factuelles précises
   - Augmentez la température (0.7-0.9) pour des réponses plus créatives et variées
   - Ajustez `frequency_penalty` et `presence_penalty` pour contrôler la répétition

3. **Performance et Stabilité**

   - Utilisez le streaming pour une meilleure expérience utilisateur sur les réponses longues
   - Implémentez une logique de retry côté client (le serveur a déjà un backoff exponentiel)
   - Pour les environnements critiques, surveillez activement les métriques d'utilisation

4. **Gestion du Contexte**

   - Stockez les `conversation_id` pour maintenir le contexte entre les sessions
   - Limitez le nombre de messages dans vos requêtes (maximum 4)
   - Utilisez les fichiers pour fournir plus de contexte sans augmenter le nombre de messages

5. **Debugging**

   - Activez les métadonnées pour obtenir des informations détaillées sur le traitement
   - Utilisez le mode streaming pour voir la progression de la génération
   - Exploitez les informations de debug pour améliorer vos prompts

6. **Sécurité**
   - Utilisez des headers personnalisés pour l'authentification des tools calls
   - Gérez correctement les confirmations d'exécution pour les outils critiques
   - Validez les entrées utilisateur avant de les envoyer à l'API
