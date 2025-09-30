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
        "updatedAt": "timestamp",
        "folderIds": ["string"],
        "maxFiles": "number"
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
        "updatedAt": "timestamp",
        "folderIds": ["string"],
        "maxFiles": "number"
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
    "overrideUrl": "string" | null,
    "maxFiles": "number" | null
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
        "updatedAt": "timestamp",
        "folderIds": ["string"],
        "maxFiles": "number"
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
    "overrideUrl": "string" | null,
    "maxFiles": "number" | null
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
        "updatedAt": "timestamp",
        "folderIds": ["string"],
        "maxFiles": "number"
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

### Récupérer les tools actifs sur un agent
- **URL** : `GET /v1/agents/:id/tools`
- **Paramètres** :
  - `id` : Identifiant unique de l'agent.
- **Réponse** :
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "string",
            "name": "string",
            "description": "string",
            "url": "string",
            "method": "string",
            "advanced": "boolean",
            "authorization": "string",
            "authorizationKeyParams": "string",
            "authorizationType": "string",
            "execConfirmation": "boolean",
            "isPublic": "boolean",
            "schema": {
              "arguments":[
                {
                  "name": "string",
                  "type": "string",
                  "nullable": "boolean",
                  "description": "string"
                }
              ]
            },
            "createdAt": "string",
            "updatedAt": "string",
      }
    ]
  }
  ```
- **Erreurs possibles** :
  - 400 : Requête invalide.
  - 401 : Authentification manquante.
  - 403 : Accès non autorisé.
  - 500 : Erreur interne du serveur.

---
