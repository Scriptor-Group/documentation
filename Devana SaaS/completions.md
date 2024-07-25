# Documentation de l'API

Cette documentation explique l'utilisation de l'API pour générer des réponses à partir d'un agent Devana.

## Endpoint

- **URL** : `https://api.devana.ai/v1/chat/completions`
- **Méthode** : `POST`

## Paramètres de requête

Les paramètres suivants doivent être inclus dans le corps de la requête :

- `model` (obligatoire) : L'ID de l'agent à utiliser pour générer la réponse.
  - *Exemple* : `"model": "agent_id"`
- `messages` (obligatoire) : Un tableau de messages, chacun ayant un rôle (`user` ou `system`) et un contenu. Le dernier message de l'utilisateur est requis.
  - *Exemple* : 
    ```json
    "messages": [
      {"role": "system", "content": "Vous êtes un assistant utile."},
      {"role": "user", "content": "Quelle est la capitale de la France ?"}
    ]
    ```
- `temperature` (optionnel) : La température d'échantillonnage, une valeur entre 0 et 1. Une température plus élevée génère des réponses plus aléatoires.
  - *Exemple* : `"temperature": 0.7`
- `max_tokens` (optionnel) : Le nombre maximum de jetons à générer dans la réponse.
  - *Exemple* : `"max_tokens": 100`
- `top_p` (optionnel) : L'échantillonnage top-p, une alternative à la température.
  - *Exemple* : `"top_p": 0.9`
- `n` (optionnel) : Le nombre de réponses à générer.
  - *Exemple* : `"n": 3`
- `stop` (optionnel) : Une séquence où la génération doit s'arrêter.
  - *Exemple* : `"stop": ["\n"]`
- `stream` (optionnel) : Un booléen indiquant si la réponse doit être renvoyée sous forme de flux.
  - *Exemple* : `"stream": true`
- `conversation_id` (optionnel) : L'ID de la dernière conversation.
  - *Exemple* : `"conversation_id": "12345"`
- `lang` (optionnel) : Le code ISO 639-1 de la langue (par exemple, en, fr, de, es, it, nl, pl, pt, ru, zh).
  - *Exemple* : `"lang": "fr"`
- `files` (optionnel) : Un tableau d'ID de fichiers.
  - *Exemple* : `"files": ["file-abc123", "file-def456"]`
- `clientModel` (optionnel) : Le modèle LLM à utiliser.
  - *Exemple* : `"clientModel": "gpt-3"`

## Réponse

Si le paramètre `stream` est défini sur `true`, la réponse sera renvoyée sous forme de flux d'événements Server-Sent Events (SSE). Chaque événement contiendra un chunk de la réponse au format JSON.

Si `stream` est `false` ou non spécifié, la réponse complète sera renvoyée au format JSON.

La réponse JSON contient les champs suivants :

- `id` : L'ID du message de réponse.
  - *Exemple* : `"id": "response-123"`
- `object` : Le type d'objet (`chat.completion` pour une réponse complète, `chat.completion.chunk` pour un chunk de réponse).
  - *Exemple* : `"object": "chat.completion"`
- `created` : L'horodatage de la création de la réponse.
  - *Exemple* : `"created": 1627384958`
- `model` : L'ID du modèle utilisé.
  - *Exemple* : `"model": "devana-v1"`
- `conversation_id` : L'ID de la conversation.
  - *Exemple* : `"conversation_id": "id"`
- `choices` : Un tableau contenant les réponses générées.
  - *Exemple* : 
    ```json
    "choices": [
      {"text": "La capitale de la France est Paris.", "index": 0}
    ]
    ```
- `usage` : Les statistiques d'utilisation des jetons.
  - *Exemple* : 
    ```json
    "usage": {
      "prompt_tokens": 10,
      "completion_tokens": 7,
      "total_tokens": 17
    }
    ```

## Erreurs

L'API peut renvoyer les codes d'erreur suivants :

- `404` : Le modèle spécifié n'a pas été trouvé.
  - *Exemple* : 
    ```json
    {
      "error": {
        "code": 404,
        "message": "Model not found"
      }
    }
    ```
- `403` : Accès refusé au modèle ou limite d'utilisation atteinte.
  - *Exemple* : 
    ```json
    {
      "error": {
        "code": 403,
        "message": "Access denied or usage limit reached"
      }
    }
    ```
- `400` : Paramètres de requête invalides.
  - *Exemple* : 
    ```json
    {
      "error": {
        "code": 400,
        "message": "Invalid request parameters"
      }
    }
    ```

## Authentification

L'API utilise l'authentification OAuth pour identifier l'utilisateur.
