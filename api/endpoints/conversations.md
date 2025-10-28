# Conversations API - Devana.ai

Documentation complète de l'API de gestion des conversations dans Devana.ai.

**Base URL:** `https://api.devana.ai`
**Préfixe:** `/v1/conversations`
**Authentification:** API Key requise

---

## 📑 Table des matières

- [Vue d'ensemble](#vue-densemble)
- [Authentification](#authentification)
- [Endpoints disponibles](#endpoints-disponibles)
  - [GET /v1/conversations/:id/metrics](#get-v1conversationsidmetrics---métriques-dune-conversation)
  - [GET /v1/conversations/:id/messages](#get-v1conversationsidmessages---messages-dune-conversation)
  - [DELETE /v1/conversations/:id](#delete-v1conversationsid---supprimer-une-conversation)
- [Modèles de données](#modèles-de-données)
- [Fonctionnalités spéciales](#fonctionnalités-spéciales)
- [Exemples d'intégration](#exemples-dintégration)
- [Différences avec l'API publique](#différences-avec-lapi-publique)

---

## Vue d'ensemble

L'API Conversations permet de gérer les conversations existantes avec les agents IA :
- Récupération des métriques détaillées (tokens, temps, sources)
- Accès à l'historique complet des messages
- Suppression sécurisée avec cascade

**Note importante :** Cette API gère les conversations **après leur création**. Pour créer de nouvelles conversations, utilisez l'endpoint [`/v1/chat/completions`](./completions.md).

---

## Authentification

Toutes les requêtes nécessitent une clé API dans le header `Authorization` :

```http
Authorization: Bearer YOUR_API_KEY
```

Les permissions sont vérifiées au niveau de l'agent associé à la conversation.

---

## Endpoints disponibles

### GET /v1/conversations/:id/metrics - Métriques d'une conversation

Récupère les métriques détaillées d'un message spécifique, incluant les statistiques de tokens et les appels de conversation associés.

#### Paramètres

| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `id` | String (CUID) | Oui | ID du message de conversation |

#### Requête

```http
GET /v1/conversations/cm4msg123abc/metrics
Authorization: Bearer YOUR_API_KEY
```

#### Réponse (200 OK)

```json
{
  "success": true,
  "data": {
    "id": "cm4msg123abc",
    "message": "Voici les résultats de votre analyse...",
    "score": 0.95,
    "type": "assistant",
    "model": "gpt-4",
    "sources": [
      {
        "fileName": "guide.pdf",
        "page": 12,
        "relevance": 0.89
      }
    ],
    "status": "completed",
    "agent": "cm4agent456def",
    "tokens": {
      "message": 250,
      "context": 1500
    },
    "conversationCalls": [
      {
        "type": "completion",
        "messages": {
          "role": "system",
          "content": "You are a helpful assistant..."
        },
        "messagesTokens": 50,
        "outputContent": "Based on the analysis...",
        "outputTokens": 200,
        "timeMs": 1250
      },
      {
        "type": "embedding",
        "messages": null,
        "messagesTokens": null,
        "outputContent": null,
        "outputTokens": 1500,
        "timeMs": 450
      }
    ]
  }
}
```

#### Champs de la réponse

| Champ | Type | Description |
|-------|------|-------------|
| `id` | String | Identifiant unique du message |
| `message` | String | Contenu du message |
| `score` | Number | Score de pertinence (0-1) |
| `type` | String | Rôle : `user`, `assistant`, `system` |
| `model` | String | Modèle utilisé (ou modèle custom si défini) |
| `sources` | Array | Sources utilisées pour la réponse |
| `status` | String | Statut du message |
| `agent` | String | ID de l'agent associé |
| `tokens.message` | Number | Tokens utilisés pour ce message |
| `tokens.context` | Number | Tokens de contexte utilisés |
| `conversationCalls` | Array | Détails des appels API effectués |

#### Exemple avec curl

```bash
curl -X GET https://api.devana.ai/v1/conversations/cm4msg123abc/metrics \
  -H "Authorization: Bearer YOUR_API_KEY"
```

---

### GET /v1/conversations/:id/messages - Messages d'une conversation

Récupère tous les messages d'une conversation, incluant le message principal et toutes les réponses.

#### Paramètres

| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `id` | String (CUID) | Oui | ID de la conversation |

#### Query Parameters

| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `flagged` | Boolean | Non | Si `true`, retourne uniquement les messages marqués par la modération |

#### Requête

```http
GET /v1/conversations/cm4conv789xyz/messages
Authorization: Bearer YOUR_API_KEY
```

#### Requête avec filtre de modération

```http
GET /v1/conversations/cm4conv789xyz/messages?flagged=true
Authorization: Bearer YOUR_API_KEY
```

#### Réponse (200 OK)

```json
{
  "success": true,
  "data": [
    {
      "id": "cm4msg001",
      "date": "2024-10-28T10:00:00.000Z",
      "message": "Comment optimiser cette fonction Python ?",
      "role": "user",
      "model": null,
      "score": null,
      "sources": null,
      "tokens": 15,
      "contextTokens": 0,
      "toolCalls": null
    },
    {
      "id": "cm4msg002",
      "date": "2024-10-28T10:00:15.000Z",
      "message": "Pour optimiser votre fonction Python, voici plusieurs suggestions...",
      "role": "assistant",
      "model": "gpt-4",
      "score": 0.92,
      "sources": [
        {
          "fileName": "python-optimization.pdf",
          "relevance": 0.88
        }
      ],
      "tokens": 350,
      "contextTokens": 1200,
      "toolCalls": {
        "web_search": {
          "query": "Python performance optimization techniques",
          "results": 5
        }
      }
    }
  ]
}
```

#### Structure des messages

| Champ | Type | Description |
|-------|------|-------------|
| `id` | String | Identifiant unique du message |
| `date` | DateTime | Date et heure du message |
| `message` | String | Contenu du message |
| `role` | String | `user`, `assistant`, ou `system` |
| `model` | String | Modèle utilisé (null pour user) |
| `score` | Number | Score de pertinence |
| `sources` | Array | Sources référencées |
| `tokens` | Number | Nombre de tokens du message |
| `contextTokens` | Number | Tokens de contexte |
| `toolCalls` | Object | Outils appelés pendant la génération |

#### Exemple avec curl

```bash
# Tous les messages
curl -X GET https://api.devana.ai/v1/conversations/cm4conv789xyz/messages \
  -H "Authorization: Bearer YOUR_API_KEY"

# Messages marqués uniquement
curl -X GET "https://api.devana.ai/v1/conversations/cm4conv789xyz/messages?flagged=true" \
  -H "Authorization: Bearer YOUR_API_KEY"
```

---

### DELETE /v1/conversations/:id - Supprimer une conversation

Supprime une conversation et tous ses messages enfants de manière récursive (soft delete).

#### Paramètres

| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `id` | String (CUID) | Oui | ID de la conversation à supprimer |

#### Requête

```http
DELETE /v1/conversations/cm4conv789xyz
Authorization: Bearer YOUR_API_KEY
```

#### Réponse (200 OK)

```json
{
  "success": true,
  "data": {
    "message": "Conversation deleted successfully",
    "deletedId": "cm4conv789xyz"
  }
}
```

#### Comportement de suppression

- **Soft delete** : Les conversations ne sont pas physiquement supprimées mais marquées avec `deletedAt`
- **Récursive** : Tous les messages enfants sont également marqués comme supprimés
- **Cascade** : La hiérarchie complète est traitée automatiquement
- **Réversible** : Possibilité de restauration côté base de données si nécessaire

#### Exemple avec curl

```bash
curl -X DELETE https://api.devana.ai/v1/conversations/cm4conv789xyz \
  -H "Authorization: Bearer YOUR_API_KEY"
```

---

## Modèles de données

### Message de conversation

```typescript
interface ConversationMessage {
  id: string;                    // CUID unique
  date: DateTime;                // Date de création
  message: string;               // Contenu du message
  role: "user" | "assistant" | "system";
  model: string | null;          // Modèle utilisé
  score: number | null;          // Score de qualité (0-1)
  sources: Source[] | null;      // Sources référencées
  tokens: number | null;         // Nombre de tokens du message
  contextTokens: number | null;  // Tokens de contexte
  toolCalls: object | null;      // Appels d'outils effectués
}
```

### Métriques de conversation

```typescript
interface ConversationMetrics {
  id: string;
  message: string;
  score: number | null;
  type: "user" | "assistant" | "system";
  model: string;                 // Nom du modèle custom ou standard
  sources: Source[] | null;
  status: string | null;
  agent: string;                 // ID de l'agent
  tokens: {
    message: number | null;
    context: number | null;
  };
  conversationCalls: ConversationCall[];
}
```

### Appel de conversation

```typescript
interface ConversationCall {
  type: string;                  // Type d'appel (completion, embedding, etc.)
  messages: object | null;       // Messages envoyés
  messagesTokens: number | null; // Tokens des messages
  outputContent: string | null;  // Contenu généré
  outputTokens: number | null;   // Tokens générés
  timeMs: number | null;         // Temps d'exécution en ms
}
```

### Source

```typescript
interface Source {
  fileName: string;              // Nom du fichier source
  page?: number;                 // Page (si applicable)
  relevance: number;             // Score de pertinence (0-1)
  excerpt?: string;              // Extrait pertinent
}
```

---

## Fonctionnalités spéciales

### Suppression récursive

La suppression d'une conversation parent entraîne automatiquement :
1. Identification de tous les messages enfants
2. Suppression récursive des enfants
3. Marquage avec `deletedAt` (soft delete)
4. Conservation de l'intégrité référentielle

### Contrôle d'accès

Chaque endpoint vérifie :
1. Authentification via API Key
2. Existence de la conversation
3. Droits sur l'agent associé via `guardAuthorizedAgentRights`
4. Non-suppression préalable (`deletedAt: null`)

### Support des modèles personnalisés

Les endpoints retournent automatiquement :
- Le nom du modèle personnalisé si configuré
- Le modèle standard en fallback
- Les métriques spécifiques au modèle utilisé

### Modération des contenus

Le paramètre `flagged` permet de :
- Filtrer les messages problématiques
- Identifier les contenus nécessitant une revue
- Implémenter des workflows de modération

---

## Exemples d'intégration

### Dashboard de métriques

```javascript
class ConversationMetrics {
  constructor(apiKey) {
    this.apiKey = apiKey;
    this.baseUrl = 'https://api.devana.ai/v1';
  }

  async getConversationStats(conversationId) {
    // Récupérer tous les messages
    const messagesResponse = await fetch(
      `${this.baseUrl}/conversations/${conversationId}/messages`,
      {
        headers: {
          'Authorization': `Bearer ${this.apiKey}`
        }
      }
    );

    const messages = await messagesResponse.json();

    // Calculer les statistiques
    const stats = {
      totalMessages: messages.data.length,
      userMessages: messages.data.filter(m => m.role === 'user').length,
      assistantMessages: messages.data.filter(m => m.role === 'assistant').length,
      totalTokens: 0,
      averageScore: 0,
      sourcesUsed: new Set()
    };

    // Analyser chaque message
    for (const message of messages.data) {
      if (message.tokens) {
        stats.totalTokens += message.tokens;
      }

      if (message.score) {
        stats.averageScore += message.score;
      }

      if (message.sources) {
        message.sources.forEach(source => {
          stats.sourcesUsed.add(source.fileName);
        });
      }
    }

    stats.averageScore = stats.averageScore / stats.assistantMessages || 0;
    stats.uniqueSources = stats.sourcesUsed.size;

    // Récupérer les métriques détaillées du dernier message assistant
    const lastAssistant = messages.data
      .filter(m => m.role === 'assistant')
      .pop();

    if (lastAssistant) {
      const metricsResponse = await fetch(
        `${this.baseUrl}/conversations/${lastAssistant.id}/metrics`,
        {
          headers: {
            'Authorization': `Bearer ${this.apiKey}`
          }
        }
      );

      const metrics = await metricsResponse.json();
      stats.lastResponseTime = metrics.data.conversationCalls
        .reduce((sum, call) => sum + (call.timeMs || 0), 0);
    }

    return stats;
  }

  async getTokenUsageReport(conversationIds) {
    const report = {
      conversations: [],
      totalTokens: 0,
      totalCost: 0
    };

    for (const id of conversationIds) {
      const response = await fetch(
        `${this.baseUrl}/conversations/${id}/messages`,
        {
          headers: {
            'Authorization': `Bearer ${this.apiKey}`
          }
        }
      );

      const messages = await response.json();

      const conversationTokens = messages.data.reduce((sum, msg) => {
        return sum + (msg.tokens || 0) + (msg.contextTokens || 0);
      }, 0);

      report.conversations.push({
        id,
        tokens: conversationTokens,
        messages: messages.data.length
      });

      report.totalTokens += conversationTokens;
    }

    // Calcul approximatif du coût (ajuster selon vos tarifs)
    report.totalCost = (report.totalTokens / 1000) * 0.03; // $0.03 per 1K tokens

    return report;
  }
}

// Utilisation
const metrics = new ConversationMetrics('YOUR_API_KEY');

// Obtenir les statistiques d'une conversation
const stats = await metrics.getConversationStats('cm4conv789xyz');
console.log('Statistiques:', stats);

// Rapport d'usage pour plusieurs conversations
const report = await metrics.getTokenUsageReport([
  'cm4conv001',
  'cm4conv002',
  'cm4conv003'
]);
console.log('Rapport de tokens:', report);
```

### Système de modération

```python
import requests
from typing import List, Dict
from datetime import datetime

class ConversationModerator:
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://api.devana.ai/v1"
        self.headers = {"Authorization": f"Bearer {api_key}"}

    def get_flagged_messages(self, conversation_id: str) -> List[Dict]:
        """Récupère tous les messages marqués par la modération"""

        response = requests.get(
            f"{self.base_url}/conversations/{conversation_id}/messages",
            headers=self.headers,
            params={"flagged": "true"}
        )

        if response.status_code == 200:
            return response.json()["data"]
        return []

    def analyze_conversation_safety(self, conversation_id: str) -> Dict:
        """Analyse la sécurité d'une conversation"""

        # Récupérer tous les messages
        all_messages = self.get_all_messages(conversation_id)
        flagged_messages = self.get_flagged_messages(conversation_id)

        analysis = {
            "conversation_id": conversation_id,
            "total_messages": len(all_messages),
            "flagged_messages": len(flagged_messages),
            "safety_score": 1.0 - (len(flagged_messages) / len(all_messages)) if all_messages else 1.0,
            "requires_review": len(flagged_messages) > 0,
            "flagged_content": []
        }

        # Analyser le contenu marqué
        for msg in flagged_messages:
            analysis["flagged_content"].append({
                "message_id": msg["id"],
                "role": msg["role"],
                "excerpt": msg["message"][:100] + "..." if len(msg["message"]) > 100 else msg["message"],
                "date": msg["date"]
            })

        return analysis

    def get_all_messages(self, conversation_id: str) -> List[Dict]:
        """Récupère tous les messages d'une conversation"""

        response = requests.get(
            f"{self.base_url}/conversations/{conversation_id}/messages",
            headers=self.headers
        )

        if response.status_code == 200:
            return response.json()["data"]
        return []

    def delete_unsafe_conversation(self, conversation_id: str, threshold: float = 0.7) -> bool:
        """Supprime une conversation si son score de sécurité est trop bas"""

        analysis = self.analyze_conversation_safety(conversation_id)

        if analysis["safety_score"] < threshold:
            response = requests.delete(
                f"{self.base_url}/conversations/{conversation_id}",
                headers=self.headers
            )

            if response.status_code == 200:
                print(f"Conversation {conversation_id} supprimée (score: {analysis['safety_score']})")
                return True

        return False

    def generate_moderation_report(self, conversation_ids: List[str]) -> Dict:
        """Génère un rapport de modération pour plusieurs conversations"""

        report = {
            "generated_at": datetime.now().isoformat(),
            "total_conversations": len(conversation_ids),
            "conversations_with_flags": 0,
            "total_flagged_messages": 0,
            "details": []
        }

        for conv_id in conversation_ids:
            analysis = self.analyze_conversation_safety(conv_id)

            if analysis["requires_review"]:
                report["conversations_with_flags"] += 1
                report["total_flagged_messages"] += analysis["flagged_messages"]

            report["details"].append(analysis)

        # Trier par score de sécurité (les plus problématiques en premier)
        report["details"].sort(key=lambda x: x["safety_score"])

        return report

# Utilisation
moderator = ConversationModerator("YOUR_API_KEY")

# Analyser une conversation
analysis = moderator.analyze_conversation_safety("cm4conv789xyz")
print(f"Score de sécurité: {analysis['safety_score']}")

# Générer un rapport de modération
report = moderator.generate_moderation_report([
    "cm4conv001",
    "cm4conv002",
    "cm4conv003"
])

print(f"Conversations nécessitant une revue: {report['conversations_with_flags']}")
```

### Export et archivage

```bash
#!/bin/bash

# Script d'export et archivage de conversations

API_KEY="YOUR_API_KEY"
BASE_URL="https://api.devana.ai/v1"
EXPORT_DIR="./conversation_exports"

# Créer le répertoire d'export
mkdir -p $EXPORT_DIR

export_conversation() {
  local conv_id=$1
  local export_file="$EXPORT_DIR/conversation_${conv_id}_$(date +%Y%m%d_%H%M%S).json"

  echo "Exporting conversation $conv_id..."

  # Récupérer les messages
  curl -s -X GET "$BASE_URL/conversations/$conv_id/messages" \
    -H "Authorization: Bearer $API_KEY" > "$export_file.tmp"

  # Vérifier le succès
  if [ $? -eq 0 ]; then
    # Formatter le JSON
    jq '.' "$export_file.tmp" > "$export_file"
    rm "$export_file.tmp"

    # Récupérer les métriques pour chaque message
    messages=$(jq -r '.data[].id' "$export_file")

    for msg_id in $messages; do
      echo "  Fetching metrics for message $msg_id..."

      curl -s -X GET "$BASE_URL/conversations/$msg_id/metrics" \
        -H "Authorization: Bearer $API_KEY" > "$EXPORT_DIR/metrics_${msg_id}.json"
    done

    echo "Export completed: $export_file"
  else
    echo "Failed to export conversation $conv_id"
    rm "$export_file.tmp"
  fi
}

# Export d'une conversation spécifique
export_conversation "cm4conv789xyz"

# Export en masse
CONVERSATION_IDS=("cm4conv001" "cm4conv002" "cm4conv003")

for conv_id in "${CONVERSATION_IDS[@]}"; do
  export_conversation $conv_id
done

# Créer une archive
echo "Creating archive..."
tar -czf "conversations_export_$(date +%Y%m%d).tar.gz" $EXPORT_DIR

echo "Archive created successfully"
```

---

## Différences avec l'API publique

### API Conversations (`/v1/conversations`)
- **Usage** : Gestion CRUD des conversations existantes
- **Authentification** : API Key requise
- **Permissions** : Basées sur l'agent
- **Fonctions** : Métriques, historique, suppression

### API Public Conversations (`/v1/chat/conversation`)
- **Usage** : Conversations embedables et widgets
- **Authentification** : Tokens de sécurité ou OAuth
- **Permissions** : Publiques avec tokens
- **Fonctions** : Streaming, chat en temps réel

Pour les conversations publiques et widgets, consultez [Public Conversations API](./public-conversations.md).

---

## Codes d'erreur

| Code | Message | Description | Solution |
|------|---------|-------------|----------|
| `400` | Bad Request | Paramètres invalides (ID non CUID) | Vérifier le format de l'ID |
| `403` | Forbidden | Pas d'autorisation sur l'agent | Vérifier les permissions |
| `404` | Not Found | Conversation/Message introuvable | Vérifier l'ID et la suppression |
| `500` | Internal Server Error | Erreur serveur | Réessayer ou contacter le support |

---

## Limites et quotas

| Limite | Valeur | Description |
|--------|--------|-------------|
| Messages par requête | 1000 | Maximum retourné par `/messages` |
| Profondeur récursive | Illimitée | Pour la suppression cascade |
| Rétention soft delete | 30 jours | Avant suppression définitive |
| Rate limit | 100 req/min | Par API Key |

---

## Support et assistance

Pour toute question ou problème concernant l'API Conversations :
- Consultez la [documentation générale de l'API](../README.md)
- Pour créer des conversations : [Chat Completions API](./completions.md)
- Pour les conversations publiques : [Public Conversations API](./public-conversations.md)
- Contactez le support technique : support@devana.ai
- Reportez les bugs sur notre [GitHub](https://github.com/devana-ai/api-issues)