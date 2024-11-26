# Documentation API Publique

Bienvenue dans la documentation de l'API publique. Cette API permet aux clients d’interagir avec les services, de gérer leurs données, et d’effectuer diverses opérations. 

## Authentification

Toutes les routes nécessitent une clé API (`Authorization` header sous la forme `Bearer <API_KEY>`). Une clé valide est essentielle pour accéder aux fonctionnalités de l’API.

---

### **v1/agents**
#### Récupérer la liste des agents
- **URL** : `GET /v1/agents`
- **Description** : Retourne la liste des agents associés à l'utilisateur.
- **Réponse** :
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "string",
        "name": "string",
        "description": "string",
        "chatVersion": "string",
        "model": "string",
        "publicChat": "boolean",
        "createdAt": "timestamp",
        "updatedAt": "timestamp"
      }
    ]
  }
  ```
- **Erreurs possibles** :
  - 500 : Erreur interne du serveur.

---

### **v1/conversations**
#### Récupérer les métriques d'une conversation
- **URL** : `GET /v1/conversations/:id/metrics`
- **Paramètres** :
  - `id` : Identifiant unique de la conversation (CUID).
- **Description** : Retourne les détails et les métriques d'une conversation spécifique.
- **Réponse** :
  ```json
  {
    "success": true,
    "data": {
      "id": "string",
      "message": "string",
      "score": "number",
      "type": "string",
      "model": "string",
      "sources": "string",
      "status": "string",
      "agent": "string",
      "tokens": {
        "message": "number",
        "context": "number"
      },
      "conversationCalls": [
        {
          "type": "string",
          "messages": "string",
          "messagesTokens": "number",
          "outputContent": "string",
          "outputTokens": "number",
          "timeMs": "number"
        }
      ]
    }
  }
  ```
- **Erreurs possibles** :
  - 400 : Requête invalide.
  - 403 : Accès non autorisé.
  - 404 : Conversation ou données non trouvées.
  - 500 : Erreur interne du serveur.

---

### **v1/files**
#### Télécharger un fichier
- **URL** : `POST /v1/files`
- **Description** : Télécharge un fichier pour le traitement.
- **Body** : `multipart/form-data` avec un champ `file`.
- **Réponse** :
  ```json
  {
    "success": true,
    "data": {
      "id": "string",
      "name": "string",
      "size": "number",
      "mimetype": "string"
    }
  }
  ```
- **Erreurs possibles** :
  - 400 : Aucun fichier téléchargé.
  - 500 : Erreurs internes (extraction de texte, génération des embeddings).

---

### **v1/folders**
#### Associer des fichiers à un dossier
- **URL** : `POST /v1/folders/:id/files`
- **Paramètres** :
  - `id` : Identifiant unique du dossier (CUID).
- **Body** :
  ```json
  {
    "filesIds": ["string"]
  }
  ```
- **Description** : Associe des fichiers spécifiés à un dossier.
- **Réponse** :
  ```json
  {
    "success": true,
    "data": ["string"] // IDs des nouveaux fichiers ajoutés.
  }
  ```
- **Erreurs possibles** :
  - 400 : Requête invalide.
  - 403 : Accès non autorisé au dossier ou fichier.
  - 409 : Fichiers déjà associés.
  - 500 : Erreur interne.

---

### **v1/users**
#### Récupérer les informations d’un utilisateur
- **URL** : `GET /v1/users/:id`
- **Paramètres** :
  - `id` : Identifiant unique de l'utilisateur (CUID).
- **Description** : Retourne les informations de l'utilisateur spécifié. Accessible uniquement par les administrateurs.
- **Réponse** :
  ```json
  {
    "success": true,
    "data": {
      "id": "string",
      "firstName": "string",
      "lastName": "string",
      "email": "string",
      "post": "string",
      "createdAt": "timestamp",
      "updatedAt": "timestamp",
      "Team": [
        {
          "id": "string",
          "name": "string",
          "createdAt": "timestamp",
          "updatedAt": "timestamp"
        }
      ]
    }
  }
  ```
- **Erreurs possibles** :
  - 400 : Requête invalide.
  - 403 : Accès non autorisé.
  - 404 : Utilisateur non trouvé.
  - 500 : Erreur interne.

---

## Réponse standard

Toutes les réponses suivent un format uniforme :
```json
{
  "success": true | false,
  "data": { ... } | null,
  "error": "string" // Si success = false
}
```

## Statuts HTTP utilisés
- `200 OK` : Requête réussie.
- `400 Bad Request` : Requête invalide.
- `401 Unauthorized` : Authentification manquante.
- `403 Forbidden` : Accès non autorisé.
- `404 Not Found` : Ressource non trouvée.
- `409 Conflict` : Conflit lors du traitement.
- `500 Internal Server Error` : Erreur interne du serveur.