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
        "folderBaseId": "string",
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

#### Récupérer un agent
- **URL** : `GET /v1/agents/:id`
- **Paramètres** :
  - `id` : Identifiant unique de l'agent.
- **Description** : Retourne les informations d'un agent spécifique.
- **Réponse** :
  ```json
  {
    "success": true,
    "data": 
      {
        "id": "string",
        "name": "string",
        "description": "string",
        "chatVersion": "string",
        "folderBaseId": "string",
        "model": "string",
        "publicChat": "boolean",
        "createdAt": "timestamp",
        "updatedAt": "timestamp"
      }
    
  }
  ```
- **Erreurs possibles** :
  - 400 : Requête invalide.
  - 403 : Accès non autorisé.
  - 404 : Agent non trouvé.
  - 500 : Erreur interne du serveur.  

#### Créer un agent
- **URL** : `POST /v1/agents`
- **Description** : Crée un nouvel agent.
- **Body** :
  ```json
  {
    "name": "string",
    "description": "string" | null,
    "model": "string" | null,
    "publicChat": "boolean" | null,
    "iaIdentity": "string" | null,
    "welcomeMessage": "string" | null,
    "target": "string" | null,
    "customModelId": "string" | null,
    "embedModel": "string" | null,
    "folderIds": ["string"] | null,
    "attachedAgents": ["string"] | null,
    "backgroundColor": "string" | null,
    "textColor": "string" | null,
    "iaType": "string" | null,
    "connectWeb": "boolean" | null,
    "freeLevel": "string" | null,
    "showSources": "boolean" | null,
    "suggestions": ["string"] | null,
    "chappieMode": "boolean" | null,
    "minimumTools": "number" | null,
    "maxTokensMonth": "number" | null,
    "maxContextTokens": "number" | null,
    "alertTokensMonth": "number" | null,
    "overrideUrl": "string" | null
  }
  ```
- **Réponse** :
  ```json
  {
    "success": true,
    "data": 
      {
        "id": "string",
        "name": "string",
        "description": "string",
        "chatVersion": "string",
        "folderBaseId": "string",
        "model": "string",
        "publicChat": "boolean",
        "createdAt": "timestamp",
        "updatedAt": "timestamp"
      }
    
  }
  ```
- **Erreurs possibles** :
  - 400 : Requête invalide.
  - 500 : Erreur interne du serveur.  

#### Mettre à jour un agent
- **URL** : `PUT /v1/agents/:id`
- **Paramètres** :
  - `id` : Identifiant unique de l'agent.
- **Body** :
  ```json
  {
    "name": "string" | null,
    "description": "string" | null,
    "model": "string" | null,
    "publicChat": "boolean" | null,
    "iaIdentity": "string" | null,
    "welcomeMessage": "string" | null,
    "target": "string" | null,
    "customModelId": "string" | null,
    "embedModel": "string" | null,
    "folderIds": ["string"] | null,
    "attachedAgents": ["string"] | null,
    "backgroundColor": "string" | null,
    "textColor": "string" | null,
    "iaType": "string" | null,
    "connectWeb": "boolean" | null,
    "freeLevel": "string" | null,
    "showSources": "boolean" | null,
    "suggestions": ["string"] | null,
    "chappieMode": "boolean" | null,
    "minimumTools": "number" | null,
    "maxTokensMonth": "number" | null,
    "maxContextTokens": "number" | null,
    "alertTokensMonth": "number" | null,
    "overrideUrl": "string" | null
  }
  ```
- **Réponse** :
  ```json
  {
    "success": true,
    "data": 
      {
        "id": "string",
        "name": "string",
        "description": "string",
        "chatVersion": "string",
        "folderBaseId": "string",
        "model": "string",
        "publicChat": "boolean",
        "createdAt": "timestamp",
        "updatedAt": "timestamp"
      }
    
  }
  ```
- **Erreurs possibles** :
  - 400 : Requête invalide.
  - 403 : Accès non autorisé.
  - 500 : Erreur interne du serveur.   

#### Supprimer un agent
- **URL** : `DELETE /v1/agents/:id`
- **Paramètres** :
  - `id` : Identifiant unique de l'agent.
- **Réponse** :
  ```json
  {
    "success": true,
    "data": 
      {
        "message": "string"
      }
    
  }
  ```
- **Erreurs possibles** :
  - 400 : Requête invalide.
  - 403 : Accès non autorisé.
  - 500 : Erreur interne du serveur.  

### Récupérer les conversations d'un agent
- **URL** : `GET /v1/agents/:id/conversations`
- **Paramètres** :
  - `id` : Identifiant unique de l'agent.
- **Description** : Retourne les conversations associées à un agent spécifique.
- **Réponse** :
  ```json
  {
    "success": true,
    "data": 
      [
        {
          "id": "string",
          "date": "timestamp",
          "message": "string",
          "model": "string",
        }
      ]
    
  }
  ```
- **Erreurs possibles** :
  - 400 : Requête invalide.
  - 403 : Accès non autorisé.
  - 404 : Agent non trouvé.
  - 500 : Erreur interne du serveur.

### Ajouter des fichiers à un agent
- **URL** : `POST /v1/agents/:id/files`
- **Paramètres** :
  - `id` : Identifiant unique de l'agent.
- **Body** :
  ```json
  {
    "filesIds": ["string"]
  }
  ```
- **Réponse** :
  ```json
  {
    "success": true,
    "data": ["string"]
  }
  ```
- **Erreurs possibles** :
  - 400 : Requête invalide.
  - 403 : Accès non autorisé.
  - 404 : Agent non trouvé.
  - 500 : Erreur interne du serveur.

---

### **v1/folders**
#### Récupérer la liste des bases de connaissances
- **URL** : `GET /v1/folders`
- **Description** : Retourne la liste des bases de connaissances associées à l'utilisateur.
- **Réponse** :
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "string",
        "name": "string",
        "description": "string",
        "words": "number",
        "chunkSize": "number",
        "createdAt": "timestamp",
        "updatedAt": "timestamp"
      }
    ]
  }
  ```
- **Erreurs possibles** :
  - 500 : Erreur interne du serveur.

#### Récupérer les informations d'une base de connaissances
- **URL** : `GET /v1/folders/:id`
- **Paramètres** :
  - `id` : Identifiant unique de la base de connaissances.
- **Description** : Retourne les informations d'une base de connaissances spécifique.
- **Réponse** :
  ```json
  {
    "success": true,
    "data": {
      "id": "string",
      "name": "string",
      "description": "string",
      "words": "number",
      "chunkSize": "number",
      "createdAt": "timestamp",
      "updatedAt": "timestamp"
    }
  }
  ```
- **Erreurs possibles** :
  - 400 : Requête invalide.
  - 403 : Accès non autorisé.
  - 404 : Base de connaissances non trouvée.
  - 500 : Erreur interne du serveur.


#### Créer une base de connaissances
- **URL** : `POST /v1/folders`
- **Description** : Crée une nouvelle base de connaissances.
- **Body** :
  ```json
  {
    "name": "string",
    "description": "string" | null,
    "chunkSize": "number" | null
  }
  ```
- **Réponse** :
  ```json
  {
    "success": true,
    "data": {
      "id": "string",
      "name": "string",
      "description": "string",
      "words": "number",
      "chunkSize": "number",
      "createdAt": "timestamp",
      "updatedAt": "timestamp"
    }
  }
  ```
- **Erreurs possibles** :
  - 400 : Requête invalide.
  - 500 : Erreur interne du serveur.

#### Mettre à jour une base de connaissances
- **URL** : `PUT /v1/folders/:id`
- **Paramètres** :
  - `id` : Identifiant unique de la base de connaissances.
- **Description** : Met à jour une base de connaissances existante.
- **Body** :
  ```json
  {
    "name": "string" | null,
    "description": "string" | null,
    "chunkSize": "number" | null
  }
  ```
- **Réponse** :
  ```json
  {
    "success": true,
    "data": {
      "id": "string",
      "name": "string",
      "description": "string",
      "words": "number",
      "chunkSize": "number",
      "createdAt": "timestamp",
      "updatedAt": "timestamp"
    }
  }
  ```
- **Erreurs possibles** :
  - 400 : Requête invalide.
  - 403 : Accès non autorisé.
  - 404 : Base de connaissances non trouvée.
  - 500 : Erreur interne du serveur.


#### Supprimer une base de connaissances.
- **URL** : `DELETE /v1/folders/:id`
- **Paramètres** :
  - `id` : Identifiant unique de la base de connaissances.
- **Description** : Supprime une base de connaissances spécifique.
- **Réponse** :
  ```json
  {
    "success": true,
    "data": {
      "message": "string"
    }
  }
  ```
- **Erreurs possibles** :
  - 400 : Requête invalide.
  - 403 : Accès non autorisé.
  - 404 : Base de connaissances non trouvée.
  - 500 : Erreur interne du serveur.


#### Sauvegarder des fichiers dans une base de connaissances
- **URL** : `POST /v1/folders/:id/files`
- **Paramètres** :
  - `id` : Identifiant unique de la base de connaissances.
- **Description** : Sauvegarder des fichiers dans une base de connaissances.
- **Body** :
  ```json
  {
    "filesIds": ["string"]
  }
  ```
- **Réponse** :
  ```json
  {
    "success": true,
    "data": ["string"]
  }
  ```
- **Erreurs possibles** :
  - 400 : Requête invalide.
  - 403 : Accès non autorisé.
  - 404 : Base de connaissances non trouvée.
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

### v1/jobs
#### Récupérer les jobs en cours d'un utilisateur
- **URL** : `GET /v1/jobs/:targetId?`
- **Paramètres** :
  - `targetId` : Identifiant unique du jobs (optionnel).
- **Description** : Retourne les jobs en cours d'un utilisateur.
- **Réponse** :
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "string",
        "targetId": "string",
        "userId": "string",
        "name": "string",
        "error": "string" | null,
        "payload": "string" | null,
        "status": "IN_PROGRESS" | "PENDING",
        "progress": "number",
        "instanceId": "string",
        "hidden": "boolean",
        "createdAt": "timestamp",
        "updatedAt": "timestamp"
      }
    ]
  }
  ```