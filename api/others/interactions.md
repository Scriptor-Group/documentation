# Interactions

## Ajouter un "Like" à un message
- **URL** : `POST /v1/interactions/like/:messageId`
- **Paramètres** :
  - `messageId` : Identifiant unique du message.
- **Description** : Ajoute un "like" au message spécifié.
- **Réponse** :
  ```json
  {
    "success": true,
    "data": {
      "id": "string",
      "fiability": "string",
    }
  }
  ```
- **Erreurs possibles** :
  - 400 : Requête invalide.
  - 403 : Accès non autorisé.
  - 404 : Message non trouvé.
  - 409 : Like déjà existant.
  - 500 : Erreur interne du serveur.

## Ajouter un "Dislike" à un message
- **URL** : `POST /v1/interactions/dislike/:messageId`
- **Paramètres** :
  - `messageId` : Identifiant unique du message.
- **Description** : Ajoute un "dislike" au message spécifié.
- **Réponse** :
  ```json
  {
    "success": true,
    "data": {
      "id": "string",
      "fiability": "string",
    }
  }
  ```
- **Erreurs possibles** :
  - 400 : Requête invalide.
  - 403 : Accès non autorisé.
  - 404 : Message non trouvé.
  - 409 : Dislike déjà existant.
  - 500 : Erreur interne du serveur.

## Ajouter un commentaire à un message
- **URL** : `POST /v1/interactions/comment/:messageId`
- **Body** :
  ```json
  {
    "content": "string"
  }
  ```
- **Paramètres** :
  - `messageId` : Identifiant unique du message.
- **Description** : Ajoute un commentaire au message spécifié.
- **Réponse** :
  ```json
  {
    "success": true,
    "data": {
      "id": "string",
      "comment": "string",
    }
  }
  ```
- **Erreurs possibles** :
  - 400 : Requête invalide ou contenu vide.
  - 403 : Accès non autorisé.
  - 404 : Message non trouvé.
  - 500 : Erreur interne du serveur.

## Récupérer les interactions d'un message
- **URL** : `GET /v1/interactions/:messageId`
- **Paramètres** :
  - `messageId` : Identifiant unique du message.
- **Description** : Retourne toutes les interactions associées à un message.
- **Réponse** :
  ```json
  {
    "success": true,
    "data": {
        "like": "boolean",
        "dislike": "boolean",
        "comment": ""
    }
  }
  ```
- **Erreurs possibles** :
  - 400 : Requête invalide.
  - 403 : Accès non autorisé.
  - 404 : Message non trouvé.
  - 500 : Erreur interne du serveur.

## Supprimer une interaction à un message
- **URL** : `DELETE /v1/interactions/:messageId`
- **Paramètres** :
  - `messageId` : Identifiant unique du message.
- **Description** : Supprime une interaction spécifique (like, dislike et commentaire) à un message.
- **Réponse** :
  ```json
  {
    "success": true,
    "data": {
      "message": "Interaction supprimée avec succès"
    }
  }
  ```
- **Erreurs possibles** :
  - 400 : Requête invalide.
  - 403 : Accès non autorisé.
  - 404 : Interaction non trouvée.
  - 500 : Erreur interne du serveur.