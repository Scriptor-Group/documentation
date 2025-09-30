# API Agents - Devana.ai

Documentation des endpoints pour la gestion des agents IA.

**Base URL :** `https://api.devana.ai`

---

## 📑 Table des matières

1. [Authentification](#authentification)
2. [Endpoints disponibles](#endpoints-disponibles)
3. [Récupérer la liste des agents](#récupérer-la-liste-des-agents)
4. [Récupérer un agent](#récupérer-un-agent)
5. [Créer un agent](#créer-un-agent)
6. [Mettre à jour un agent](#mettre-à-jour-un-agent)
7. [Supprimer un agent](#supprimer-un-agent)
8. [Récupérer les conversations](#récupérer-les-conversations-dun-agent)
9. [Ajouter des fichiers](#ajouter-des-fichiers-à-un-agent)
10. [Récupérer les tools](#récupérer-les-tools-actifs-sur-un-agent)

---

## Authentification

Toutes les requêtes nécessitent une clé API dans le header `Authorization`.

```bash
Authorization: Bearer YOUR_API_KEY
```

Plus d'informations : [OAuth 2.0](../authentication/oauth.md)

---

## Endpoints disponibles

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/v1/agents` | Liste tous les agents |
| `GET` | `/v1/agents/:id` | Récupère un agent spécifique |
| `POST` | `/v1/agents` | Crée un nouvel agent |
| `PUT` | `/v1/agents/:id` | Met à jour un agent |
| `DELETE` | `/v1/agents/:id` | Supprime un agent |
| `GET` | `/v1/agents/:id/conversations` | Liste les conversations d'un agent |
| `POST` | `/v1/agents/:id/files` | Ajoute des fichiers à un agent |
| `GET` | `/v1/agents/:id/tools` | Liste les tools actifs |

---

## Endpoints

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
