# Référence de l'API

Cette documentation détaille l'endpoint de completion compatible avec la structure API d'OpenAI.

## Authentification

L'authentification est gérée via OAuth2. Incluez votre token d'authentification dans les headers de la requête :

```bash
Authorization: Bearer VOTRE_TOKEN
```

## Effectuer des requêtes

### Endpoint

```
POST /v1/completions
```

### Corps de la Requête

| Paramètre | Type | Obligatoire | Description |
|-----------|------|-------------|-------------|
| `model` | string | Oui | ID du modèle à utiliser. Peut être un ID d'agent personnalisé ou l'ID de configuration Devana AI par défaut. |
| `messages` | array | Oui | Tableau des messages composant la conversation (maximum 4 messages). |
| `temperature` | float | Non | Contrôle l'aléatoire dans les réponses. Valeurs entre 0 et 1. |
| `max_tokens` | integer | Non | Nombre maximum de tokens à générer. |
| `top_p` | float | Non | Contrôle la diversité via l'échantillonnage nucleus. |
| `n` | integer | Non | Nombre de completions à générer. |
| `stop` | string/array | Non | Séquences où l'API arrêtera la génération. |
| `stream` | boolean | Non | Si vrai, les deltas de messages partiels seront envoyés. |
| `conversation_id` | string | Non | ID de la conversation existante à continuer. |
| `lang` | string | Non | Langue pour la réponse. Par défaut, locale de l'utilisateur ou 'fr'. |
| `files` | array | Non | Tableau des IDs de fichiers à inclure dans le contexte. |
| `clientModel` | string | Non | Modèle spécifique à utiliser avec la configuration Devana AI. |
| `custom` | object | Non | Options de configuration personnalisées. |

#### Objet Message

```typescript
{
  role: "user" | "system" | "assistant",
  content: string
}
```

### Exemple de Requête

```bash
curl -X POST https://api.example.com/v1/completions \
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
  created: number;            // Timestamp
  model: string;              // ID du modèle utilisé
  conversation_id: string;    // ID de conversation
  choices: [{
    index: number;
    message: {
      role: "assistant";
      content: string;
      tool_calls: null;
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
  choices: [{
    index: number;
    delta: {
      content: string;
    };
    finish_reason: null | "stop";
    logprobs: null;
  }];
  usage: {
    prompt_tokens: number;
    completion_tokens: number;
    total_tokens: number;
  };
}
```

Le flux se termine par un message `[DONE]`.

## Gestion des Erreurs

L'API utilise les codes de réponse HTTP conventionnels :
- `400` - Mauvaise Requête (paramètres invalides)
- `403` - Interdit (accès refusé ou limite atteinte)
- `404` - Non Trouvé (modèle non trouvé)
- `500` - Erreur Interne du Serveur

### Format de Réponse d'Erreur

```typescript
{
  error: string  // Message d'erreur
}
```

## Limitation de Débit

L'API inclut une limitation de débit basée sur l'utilisateur :
- Les métriques utilisateur sont vérifiées avant le traitement des requêtes
- Quand les limites sont atteintes, retourne le code status 403

## Fonctionnalités Spéciales

### Contexte de Conversation
- Supporte la continuation des conversations existantes via `conversation_id`
- Maintient l'historique des conversations et les pièces jointes
- Suit automatiquement l'utilisation des tokens et le statut de la conversation

### Support des Fichiers
- Accepte les IDs de fichiers dans la requête
- Maintient les associations de fichiers avec les messages de conversation
- Supporte les pièces jointes au niveau conversation et message

### Configuration Agent/Modèle
- Supporte les agents AI personnalisés et la configuration Devana AI par défaut
- Paramètres d'identité et de comportement configurables par agent
- Connectivité web optionnelle pour des réponses améliorées

### Surveillance et Analytique
- Suit les requêtes réseau
- Enregistre le statut de vérification et le scoring
- Supporte l'attribution des sources pour les réponses
- Maintient des métriques détaillées d'utilisation des tokens

### Particularités
- Mode Chappie disponible pour certains agents
- Gestion automatique de la langue selon les préférences utilisateur
- Support multi-modèles avec possibilité de spécifier le modèle client
- Vérification automatique des droits d'accès aux agents

# Exemples d'Utilisation

## Conversation Simple

### Requête
```bash
curl -X POST https://api.example.com/v1/completions \
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
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "La capitale de la France est Paris.",
        "tool_calls": null
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
curl -X POST https://api.example.com/v1/completions \
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
curl -X POST https://api.example.com/v1/completions \
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
data: {"id":"msg_789ghi","object":"chat.completion.chunk","created":1698152366,"model":"default-agent","conversation_id":"conv_456def","choices":[{"index":0,"delta":{"content":"Il"},"finish_reason":null,"logprobs":null}]}

data: {"id":"msg_789ghi","object":"chat.completion.chunk","created":1698152366,"model":"default-agent","conversation_id":"conv_456def","choices":[{"index":0,"delta":{"content":" était"},"finish_reason":null,"logprobs":null}]}

data: {"id":"msg_789ghi","object":"chat.completion.chunk","created":1698152366,"model":"default-agent","conversation_id":"conv_456def","choices":[{"index":0,"delta":{"content":" une"},"finish_reason":null,"logprobs":null}]}

...

data: [DONE]
```

## Conversation avec Fichiers

### Requête
```bash
curl -X POST https://api.example.com/v1/completions \
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

## Utilisation d'un Agent Personnalisé avec Configuration Spécifique

### Requête
```bash
curl -X POST https://api.example.com/v1/completions \
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
    }
  }'
```

## Conversation Multi-tours avec Température Basse

### Requête
```bash
curl -X POST https://api.example.com/v1/completions \
  -H "Authorization: Bearer VOTRE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "default-agent",
    "messages": [
      {
        "role": "system",
        "content": "Tu es un assistant spécialisé en mathématiques"
      },
      {
        "role": "user",
        "content": "Quel est le théorème de Pythagore?"
      },
      {
        "role": "assistant",
        "content": "Le théorème de Pythagore établit que dans un triangle rectangle, le carré de l'hypoténuse est égal à la somme des carrés des deux autres côtés."
      },
      {
        "role": "user",
        "content": "Peux-tu me donner un exemple concret?"
      }
    ],
    "temperature": 0.2
  }'
```

## Utilisation avec Modèle Client Spécifique

### Requête
```bash
curl -X POST https://api.example.com/v1/completions \
  -H "Authorization: Bearer VOTRE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "devana-ai",
    "clientModel": "gpt-4",
    "messages": [
      {
        "role": "user",
        "content": "Analyse les tendances du marché de l'IA"
      }
    ],
    "max_tokens": 500
  }'
```

# Conseils d'Utilisation

1. **Gestion des Tokens**
   - Surveillez l'utilisation des tokens dans les réponses
   - Ajustez `max_tokens` selon vos besoins
   - Utilisez le streaming pour les réponses longues

2. **Optimisation des Réponses**
   - Utilisez une température basse (0.1-0.3) pour des réponses factuelles
   - Augmentez la température (0.7-0.9) pour des réponses plus créatives
   - Ajustez `top_p` pour contrôler la diversité des réponses

3. **Performance**
   - Limitez le nombre de messages dans l'historique
   - Utilisez le streaming pour une meilleure expérience utilisateur
   - Gérez correctement les timeouts côté client

4. **Gestion des Erreurs**
   - Implémentez une logique de retry avec backoff exponentiel
   - Surveillez les codes d'erreur HTTP
   - Vérifiez les limites d'utilisation

5. **Bonnes Pratiques**
   - Stockez les `conversation_id` pour maintenir le contexte
   - Utilisez des systèmes de cache appropriés
   - Implementez une gestion robuste des événements en streaming
