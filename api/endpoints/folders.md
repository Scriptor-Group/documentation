# Folders API - Devana.ai

Documentation complète de l'API de gestion des dossiers (bases de connaissances) dans Devana.ai.

**Base URL:** `https://api.devana.ai`
**Préfixe:** `/v1/folders`
**Authentification:** API Key requise

---

## 📑 Table des matières

- [Vue d'ensemble](#vue-densemble)
- [Authentification](#authentification)
- [Endpoints disponibles](#endpoints-disponibles)
  - [GET /v1/folders](#get-v1folders---lister-tous-les-dossiers)
  - [GET /v1/folders/:id](#get-v1foldersid---récupérer-un-dossier)
  - [POST /v1/folders](#post-v1folders---créer-un-dossier)
  - [PUT /v1/folders/:id](#put-v1foldersid---modifier-un-dossier)
  - [DELETE /v1/folders/:id](#delete-v1foldersid---supprimer-un-dossier)
  - [POST /v1/folders/:id/files](#post-v1foldersidfiles---ajouter-des-fichiers)
  - [GET /v1/folders/:id/files](#get-v1foldersidfiles---lister-les-fichiers)
  - [DELETE /v1/folders/:id/files/:fileId](#delete-v1foldersidfilesfileid---supprimer-un-fichier)
- [Types de dossiers](#types-de-dossiers)
- [Gestion des permissions](#gestion-des-permissions)
- [Gestion des chunks](#gestion-des-chunks)
- [Codes d'erreur](#codes-derreur)
- [Exemples avancés](#exemples-avancés)

---

## Vue d'ensemble

L'API Folders permet de gérer les dossiers (bases de connaissances) qui contiennent les documents utilisés par les agents IA. Chaque dossier peut contenir plusieurs fichiers et être partagé entre utilisateurs.

**Fonctionnalités principales :**
- Création et gestion de dossiers de documents
- Association de fichiers aux dossiers
- Partage de dossiers entre utilisateurs
- Configuration de la taille des chunks pour l'indexation
- Calcul automatique du nombre de mots

---

## Authentification

Toutes les requêtes nécessitent une clé API dans le header `Authorization` :

```http
Authorization: Bearer YOUR_API_KEY
```

La clé API peut être obtenue depuis l'interface d'administration ou via l'endpoint `/v1/auth/login`.

---

## Endpoints disponibles

### GET /v1/folders - Lister tous les dossiers

Récupère la liste de tous les dossiers appartenant à l'utilisateur ainsi que les dossiers partagés avec lui.

#### Requête

```http
GET /v1/folders
Authorization: Bearer YOUR_API_KEY
```

#### Réponse (200 OK)

```json
{
  "success": true,
  "data": [
    {
      "status": "fulfilled",
      "value": {
        "id": "cm4abc123def456ghi789",
        "name": "Documentation Technique",
        "description": "Base de connaissances pour le support technique",
        "chunkSize": 500,
        "createdAt": "2024-01-15T10:30:00.000Z",
        "updatedAt": "2024-01-20T14:45:00.000Z",
        "words": 125000
      }
    },
    {
      "status": "fulfilled",
      "value": {
        "id": "cm4xyz789abc123def456",
        "name": "FAQ Clients",
        "description": "Questions fréquentes et réponses",
        "chunkSize": 300,
        "createdAt": "2024-02-01T09:00:00.000Z",
        "updatedAt": "2024-02-15T16:20:00.000Z",
        "words": 45000
      }
    }
  ]
}
```

#### Exemple avec curl

```bash
curl -X GET https://api.devana.ai/v1/folders \
  -H "Authorization: Bearer YOUR_API_KEY"
```

---

### GET /v1/folders/:id - Récupérer un dossier

Récupère les détails complets d'un dossier spécifique.

#### Paramètres

| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `id` | String (CUID) | Oui | Identifiant unique du dossier |

#### Requête

```http
GET /v1/folders/cm4abc123def456ghi789
Authorization: Bearer YOUR_API_KEY
```

#### Réponse (200 OK)

```json
{
  "success": true,
  "data": {
    "id": "cm4abc123def456ghi789",
    "name": "Documentation Technique",
    "description": "Base de connaissances pour le support technique",
    "chunkSize": 500,
    "createdAt": "2024-01-15T10:30:00.000Z",
    "updatedAt": "2024-01-20T14:45:00.000Z",
    "words": 125000
  }
}
```

#### Exemple avec curl

```bash
curl -X GET https://api.devana.ai/v1/folders/cm4abc123def456ghi789 \
  -H "Authorization: Bearer YOUR_API_KEY"
```

---

### POST /v1/folders - Créer un dossier

Crée un nouveau dossier pour organiser des documents.

#### Body Parameters

| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `name` | String | Oui | Nom du dossier |
| `description` | String | Non | Description du dossier |
| `chunkSize` | Number | Non | Taille des chunks pour l'indexation (par défaut: 500) |

#### Requête

```http
POST /v1/folders
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json
```

```json
{
  "name": "Base de connaissances Produit",
  "description": "Documentation complète de nos produits",
  "chunkSize": 400
}
```

#### Réponse (200 OK)

```json
{
  "success": true,
  "data": {
    "id": "cm4new789folder123xyz",
    "name": "Base de connaissances Produit",
    "description": "Documentation complète de nos produits",
    "words": 0,
    "chunkSize": 400,
    "createdAt": "2024-10-28T10:00:00.000Z",
    "updatedAt": "2024-10-28T10:00:00.000Z"
  }
}
```

#### Exemple avec curl

```bash
curl -X POST https://api.devana.ai/v1/folders \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Base de connaissances Produit",
    "description": "Documentation complète de nos produits",
    "chunkSize": 400
  }'
```

---

### PUT /v1/folders/:id - Modifier un dossier

Met à jour les propriétés d'un dossier existant.

#### Paramètres

| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `id` | String (CUID) | Oui | Identifiant unique du dossier |

#### Body Parameters

| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `name` | String | Non | Nouveau nom du dossier |
| `description` | String | Non | Nouvelle description |
| `chunkSize` | Number | Non | Nouvelle taille de chunks (ré-indexe tous les fichiers) |

#### Requête

```http
PUT /v1/folders/cm4abc123def456ghi789
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json
```

```json
{
  "name": "Documentation Technique V2",
  "description": "Base de connaissances mise à jour",
  "chunkSize": 600
}
```

#### Réponse (200 OK)

```json
{
  "success": true,
  "data": {
    "id": "cm4abc123def456ghi789",
    "name": "Documentation Technique V2",
    "description": "Base de connaissances mise à jour",
    "words": 125000,
    "chunkSize": 600,
    "createdAt": "2024-01-15T10:30:00.000Z",
    "updatedAt": "2024-10-28T11:00:00.000Z"
  }
}
```

**⚠️ Important :** Modifier le `chunkSize` déclenche une ré-indexation complète de tous les fichiers du dossier.

#### Exemple avec curl

```bash
curl -X PUT https://api.devana.ai/v1/folders/cm4abc123def456ghi789 \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Documentation Technique V2",
    "chunkSize": 600
  }'
```

---

### DELETE /v1/folders/:id - Supprimer un dossier

Supprime définitivement un dossier et tous ses fichiers associés.

#### Paramètres

| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `id` | String (CUID) | Oui | Identifiant unique du dossier |

#### Requête

```http
DELETE /v1/folders/cm4abc123def456ghi789
Authorization: Bearer YOUR_API_KEY
```

#### Réponse (200 OK)

```json
{
  "success": true,
  "data": {
    "message": "Folder Documentation Technique deleted"
  }
}
```

**⚠️ Attention :**
- Les dossiers de base (`isBase: true`) ne peuvent pas être supprimés
- La suppression est définitive et entraîne :
  - Suppression de tous les fichiers du dossier
  - Suppression des associations avec les agents
  - Suppression des partages
  - Suppression des données vectorielles

#### Exemple avec curl

```bash
curl -X DELETE https://api.devana.ai/v1/folders/cm4abc123def456ghi789 \
  -H "Authorization: Bearer YOUR_API_KEY"
```

---

### POST /v1/folders/:id/files - Ajouter des fichiers

Associe des fichiers existants à un dossier.

#### Paramètres

| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `id` | String (CUID) | Oui | Identifiant unique du dossier |

#### Body Parameters

| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `filesIds` | Array[String] | Oui | Liste des IDs de fichiers à associer |

#### Requête

```http
POST /v1/folders/cm4abc123def456ghi789/files
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json
```

```json
{
  "filesIds": [
    "cm4file1abc123xyz",
    "cm4file2def456uvw",
    "cm4file3ghi789rst"
  ]
}
```

#### Réponse (200 OK)

```json
{
  "success": true,
  "data": [
    "cm4file1abc123xyz",
    "cm4file2def456uvw",
    "cm4file3ghi789rst"
  ]
}
```

**Notes :**
- Les fichiers doivent appartenir à l'utilisateur
- Les fichiers déjà associés au dossier sont ignorés
- Déclenche la synchronisation avec la base vectorielle

#### Exemple avec curl

```bash
curl -X POST https://api.devana.ai/v1/folders/cm4abc123def456ghi789/files \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "filesIds": ["cm4file1abc123xyz", "cm4file2def456uvw"]
  }'
```

---

### GET /v1/folders/:id/files - Lister les fichiers

Récupère la liste de tous les fichiers associés à un dossier.

#### Paramètres

| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `id` | String | Oui | Identifiant unique du dossier |

#### Requête

```http
GET /v1/folders/cm4abc123def456ghi789/files
Authorization: Bearer YOUR_API_KEY
```

#### Réponse (200 OK)

```json
{
  "success": true,
  "data": [
    {
      "id": "cm4file1abc123xyz",
      "name": "manuel-utilisateur.pdf",
      "size": 2456789,
      "mimetype": "application/pdf"
    },
    {
      "id": "cm4file2def456uvw",
      "name": "guide-installation.docx",
      "size": 1234567,
      "mimetype": "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    },
    {
      "id": "cm4file3ghi789rst",
      "name": "faq.md",
      "size": 45678,
      "mimetype": "text/markdown"
    }
  ]
}
```

#### Exemple avec curl

```bash
curl -X GET https://api.devana.ai/v1/folders/cm4abc123def456ghi789/files \
  -H "Authorization: Bearer YOUR_API_KEY"
```

---

### DELETE /v1/folders/:id/files/:fileId - Supprimer un fichier

Supprime définitivement un fichier spécifique d'un dossier.

#### Paramètres

| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `id` | String | Oui | Identifiant unique du dossier |
| `fileId` | String | Oui | Identifiant unique du fichier |

#### Requête

```http
DELETE /v1/folders/cm4abc123def456ghi789/files/cm4file1abc123xyz
Authorization: Bearer YOUR_API_KEY
```

#### Réponse (200 OK)

```json
{
  "success": true,
  "data": {
    "message": "File deleted successfully."
  }
}
```

**⚠️ Attention :** La suppression est définitive et entraîne :
- Suppression du fichier du stockage cloud
- Suppression des embeddings vectoriels
- Suppression des métadonnées

#### Exemple avec curl

```bash
curl -X DELETE https://api.devana.ai/v1/folders/cm4abc123def456ghi789/files/cm4file1abc123xyz \
  -H "Authorization: Bearer YOUR_API_KEY"
```

---

## Types de dossiers

### Dossiers standards
- Créés par les utilisateurs
- Peuvent être modifiés et supprimés
- Peuvent être partagés avec d'autres utilisateurs

### Dossiers de base (`isBase: true`)
- Dossiers système créés automatiquement
- Ne peuvent pas être supprimés
- Associés automatiquement aux agents
- Permissions spéciales requises

---

## Gestion des permissions

L'API vérifie automatiquement les permissions selon le contexte :

### Permissions de lecture
- Propriétaire du dossier : accès complet
- Utilisateurs avec partage : accès en lecture seule
- Vérifiées via `guardAuthorizedFolderRights`

### Permissions d'écriture
- Propriétaire du dossier : toutes les opérations
- Utilisateurs avec droits d'écriture explicites
- Vérifiées via `guardAuthorizedFolderRightsWrite`

### Hiérarchie des permissions
1. Vérification de la propriété
2. Vérification des partages
3. Vérification des droits sur les agents associés (pour les dossiers de base)

---

## Gestion des chunks

### Qu'est-ce qu'un chunk ?
Un chunk est un segment de texte utilisé pour l'indexation vectorielle. La taille du chunk affecte :
- La précision de la recherche
- La pertinence des résultats
- Les performances du système

### Tailles recommandées
- **300-500 tokens** : Documents techniques, FAQ
- **500-800 tokens** : Documentation générale
- **800-1200 tokens** : Textes narratifs longs

### Modification du chunkSize
Lorsque vous modifiez le `chunkSize` d'un dossier :
1. Tous les documents existants sont supprimés de l'index
2. Les fichiers sont ré-indexés avec la nouvelle taille
3. Le processus est asynchrone et peut prendre du temps

---

## Codes d'erreur

| Code | Message | Description |
|------|---------|-------------|
| `400` | Bad Request | Paramètres invalides ou manquants |
| `401` | Unauthorized | Clé API manquante ou invalide |
| `403` | Forbidden | Permissions insuffisantes |
| `404` | Not Found | Dossier ou fichier introuvable |
| `409` | Conflict | Fichiers déjà associés au dossier |
| `500` | Internal Server Error | Erreur serveur inattendue |

---

## Exemples avancés

### Créer une base de connaissances complète

```bash
# 1. Créer le dossier
FOLDER_ID=$(curl -X POST https://api.devana.ai/v1/folders \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Knowledge Base Produit",
    "description": "Documentation produit complète",
    "chunkSize": 500
  }' | jq -r '.data.id')

echo "Dossier créé: $FOLDER_ID"

# 2. Uploader des fichiers (via /api/upload)
FILE1_ID=$(curl -X POST https://api.devana.ai/api/upload \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -F "file=@manuel.pdf" | jq -r '.data.ids[0]')

FILE2_ID=$(curl -X POST https://api.devana.ai/api/upload \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -F "file=@guide.docx" | jq -r '.data.ids[0]')

# 3. Associer les fichiers au dossier
curl -X POST "https://api.devana.ai/v1/folders/$FOLDER_ID/files" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"filesIds\": [\"$FILE1_ID\", \"$FILE2_ID\"]
  }"

# 4. Vérifier les fichiers
curl -X GET "https://api.devana.ai/v1/folders/$FOLDER_ID/files" \
  -H "Authorization: Bearer YOUR_API_KEY"
```

### Migrer un dossier vers un nouveau système de chunks

```bash
# 1. Récupérer les informations actuelles
FOLDER_INFO=$(curl -X GET https://api.devana.ai/v1/folders/cm4abc123def456ghi789 \
  -H "Authorization: Bearer YOUR_API_KEY")

echo "Configuration actuelle:"
echo $FOLDER_INFO | jq '.data.chunkSize'

# 2. Modifier la taille des chunks (déclenche la ré-indexation)
curl -X PUT https://api.devana.ai/v1/folders/cm4abc123def456ghi789 \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "chunkSize": 800
  }'

echo "Ré-indexation en cours..."

# 3. Vérifier le statut (via l'API Jobs si disponible)
curl -X GET "https://api.devana.ai/v1/jobs?targetId=cm4abc123def456ghi789&type=EMBEDDING" \
  -H "Authorization: Bearer YOUR_API_KEY"
```

### Nettoyer un dossier (supprimer tous les fichiers)

```bash
# 1. Lister tous les fichiers
FILES=$(curl -X GET https://api.devana.ai/v1/folders/cm4abc123def456ghi789/files \
  -H "Authorization: Bearer YOUR_API_KEY" | jq -r '.data[].id')

# 2. Supprimer chaque fichier
for FILE_ID in $FILES; do
  echo "Suppression de $FILE_ID..."
  curl -X DELETE "https://api.devana.ai/v1/folders/cm4abc123def456ghi789/files/$FILE_ID" \
    -H "Authorization: Bearer YOUR_API_KEY"
done

echo "Tous les fichiers ont été supprimés"
```

---

## Intégration avec les agents

Les dossiers peuvent être associés aux agents IA pour leur fournir une base de connaissances :

```javascript
// Exemple d'association via l'API Agents
const associateFolderToAgent = async (agentId, folderId) => {
  const response = await fetch(`https://api.devana.ai/v1/agents/${agentId}`, {
    method: 'PUT',
    headers: {
      'Authorization': `Bearer ${API_KEY}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      folderIds: [folderId]  // Ajouter le dossier à l'agent
    })
  });

  return response.json();
};
```

---

## Bonnes pratiques

1. **Organisation des dossiers**
   - Créez des dossiers thématiques séparés
   - Utilisez des descriptions claires
   - Évitez les dossiers trop volumineux (> 1000 fichiers)

2. **Optimisation des chunks**
   - Testez différentes tailles pour votre cas d'usage
   - Plus petit = plus précis mais plus de tokens
   - Plus grand = moins de tokens mais moins précis

3. **Gestion des permissions**
   - Utilisez les partages pour la collaboration
   - Vérifiez les permissions avant les opérations sensibles
   - Documentez les accès partagés

4. **Performance**
   - Utilisez la pagination pour les grandes listes
   - Évitez les modifications fréquentes du chunkSize
   - Groupez les opérations d'ajout de fichiers

---

## Support et assistance

Pour toute question ou problème concernant l'API Folders :
- Consultez la [documentation générale de l'API](../README.md)
- Contactez le support technique : support@devana.ai
- Reportez les bugs sur notre [GitHub](https://github.com/devana-ai/api-issues)