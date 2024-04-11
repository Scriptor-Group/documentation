# API Documentation

Cette documentation explique l'utilisation de l'API pour générer des réponses à partir d'un agent Devana.

## Endpoint

- URL : `/completions`
- Méthode : `POST`

## Paramètres de requête

Les paramètres suivants doivent être inclus dans le corps de la requête :

- `model` (obligatoire) : L'ID de l'agent à utiliser pour générer la réponse.
- `messages` (obligatoire) : Un tableau de messages, chacun ayant un rôle (`user` ou `system`) et un contenu. Le dernier message de l'utilisateur est requis.
- `temperature` (optionnel) : La température d'échantillonnage, une valeur entre 0 et 1. Une température plus élevée génère des réponses plus aléatoires.
- `max_tokens` (optionnel) : Le nombre maximum de jetons à générer dans la réponse.
- `top_p` (optionnel) : L'échantillonnage top-p, une alternative à la température.
- `n` (optionnel) : Le nombre de réponses à générer.
- `stop` (optionnel) : Une séquence où la génération doit s'arrêter.
- `stream` (optionnel) : Un booléen indiquant si la réponse doit être renvoyée sous forme de flux.
- `conversation_id` (optionnel) : L'ID de la dernière conversation.
- `lang` (optionnel) : Le code ISO 639-1 de la langue (par exemple, en, fr, de, es, it, nl, pl, pt, ru, zh).
- `files` (optionnel) : Un tableau d'ID de fichiers.
- `clientModel` (optionnel) : Le modèle LLM à utiliser.

## Réponse

Si le paramètre `stream` est défini sur `true`, la réponse sera renvoyée sous forme de flux d'événements Server-Sent Events (SSE). Chaque événement contiendra un chunk de la réponse au format JSON.

Si `stream` est `false` ou non spécifié, la réponse complète sera renvoyée au format JSON.

La réponse JSON contient les champs suivants :

- `id` : L'ID du message de réponse.
- `object` : Le type d'objet (`chat.completion` pour une réponse complète, `chat.completion.chunk` pour un chunk de réponse).
- `created` : L'horodatage de la création de la réponse.
- `model` : L'ID du modèle utilisé.
- `conversation_id` : L'ID de la conversation.
- `choices` : Un tableau contenant les réponses générées.
- `usage` : Les statistiques d'utilisation des jetons.

## Erreurs

L'API peut renvoyer les codes d'erreur suivants :

- `404` : Le modèle spécifié n'a pas été trouvé.
- `403` : Accès refusé au modèle ou limite d'utilisation atteinte.
- `400` : Paramètres de requête invalides.

## Authentification

L'API utilise l'authentification OAuth pour identifier l'utilisateur.
