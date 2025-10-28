# File Upload API

Documentation complète des endpoints d'upload de fichiers dans Devana.ai.

**Base URL:** `https://api.devana.ai`

---

## 📑 Table des matières

- [Vue d'ensemble](#vue-densemble)
- [Authentification](#authentification)
- [Endpoint principal : POST /api/upload](#endpoint-principal--post-apiupload)
  - [Description](#description)
  - [Paramètres de la requête](#paramètres-de-la-requête)
  - [Headers personnalisés](#headers-personnalisés)
  - [Format de la réponse](#format-de-la-réponse)
  - [Codes d'erreur](#codes-derreur)
  - [Exemples d'utilisation](#exemples-dutilisation)
- [Limites et quotas](#limites-et-quotas)
- [Formats supportés](#formats-supportés)
- [Mode Fast](#mode-fast)
- [Cas d'usage avancés](#cas-dusage-avancés)

---

## Vue d'ensemble

L'API d'upload de Devana.ai permet de télécharger des fichiers dans le système pour :

- Ajouter des documents à la base de connaissances d'un agent
- Attacher des fichiers à une conversation
- Organiser des fichiers dans des dossiers virtuels avec hiérarchie de chemins

L'endpoint supporte l'upload multiple (jusqu'à 5000 fichiers simultanément) et propose plusieurs modes de traitement incluant l'extraction asynchrone du contenu.

---

## Authentification

L'authentification est requise pour l'upload de fichiers dans des dossiers. Pour les attachements de conversation, l'authentification est optionnelle.

### Token Bearer

Utilisez un token JWT dans le header `Authorization`:

```http
Authorization: Bearer YOUR_JWT_TOKEN
```

Le token peut être obtenu via l'endpoint de connexion `/v1/auth/login`.

---

## Endpoint principal : POST /api/upload

### Description

Endpoint multi-fonctions pour l'upload de fichiers avec support de:

- Upload multiple (batch)
- Organisation par dossiers
- Attachement à des conversations
- Extraction asynchrone ou synchrone du contenu
- Mode Fast pour les attachements

### Méthode HTTP

```
POST /api/upload
```

### Paramètres de la requête

#### Body (multipart/form-data)

| Paramètre               | Type   | Requis | Description                                                                                                    |
| ----------------------- | ------ | ------ | -------------------------------------------------------------------------------------------------------------- |
| `file`                  | File[] | Oui    | Fichier(s) à uploader. Utiliser le nom de champ "file" pour tous les fichiers. Maximum 5000 fichiers.          |
| `path_0`, `path_1`, ... | String | Non    | Chemin spécifique pour chaque fichier (indexé). Permet d'organiser les fichiers dans une hiérarchie virtuelle. |

#### Headers personnalisés

| Header            | Type    | Requis       | Description                                                                  |
| ----------------- | ------- | ------------ | ---------------------------------------------------------------------------- |
| `Authorization`   | String  | Conditionnel | Token Bearer JWT. Requis pour l'upload dans des dossiers.                    |
| `folder`          | String  | Non          | ID du dossier de destination. Active les vérifications de permissions.       |
| `conversation`    | String  | Non          | ID de la conversation pour attacher les fichiers.                            |
| `path`            | String  | Non          | Chemin par défaut pour tous les fichiers (si pas de path spécifique).        |
| `wait`            | Boolean | Non          | Si `true`, attend la fin de l'extraction avant de répondre. Défaut: `false`. |
| `disableFastMode` | Boolean | Non          | Si `true`, désactive le mode Fast. Défaut: `false`.                          |

### Format de la réponse

#### Succès (200 OK)

```json
{
  "success": true,
  "data": {
    "message": "Files uploaded successfully",
    "ids": ["file-id-1", "file-id-2", "file-id-3"]
  }
}
```

#### Structure des IDs retournés

Les IDs retournés correspondent aux identifiants uniques des fichiers créés dans la base de données. Ils peuvent être utilisés pour :

- Récupérer les métadonnées du fichier
- Vérifier le statut de l'extraction
- Référencer le fichier dans d'autres opérations

### Codes d'erreur

| Code  | Message                                         | Description                                          |
| ----- | ----------------------------------------------- | ---------------------------------------------------- |
| `400` | "No files uploaded"                             | Aucun fichier n'a été fourni dans la requête         |
| `400` | "Too many files, max 5000"                      | Dépassement de la limite de 5000 fichiers            |
| `400` | "Invalid files uploaded"                        | Format de fichier invalide ou corrompu               |
| `401` | "Unauthorized"                                  | Token manquant ou invalide pour l'opération demandée |
| `401` | "You are not authorized to perform this action" | Permissions insuffisantes sur le dossier ou l'agent  |
| `413` | File too large                                  | Fichier dépassant la limite de 10GB                  |

### Exemples d'utilisation

#### Upload simple d'un fichier

```bash
curl -X POST https://api.devana.ai/api/upload \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "file=@document.pdf"
```

#### Upload multiple avec dossier de destination

```bash
curl -X POST https://api.devana.ai/api/upload \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "folder: folder-uuid-123" \
  -F "file=@document1.pdf" \
  -F "file=@document2.docx" \
  -F "file=@spreadsheet.xlsx"
```

#### Upload avec chemins spécifiques pour chaque fichier

```bash
curl -X POST https://api.devana.ai/api/upload \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "folder: folder-uuid-123" \
  -F "file=@rapport.pdf" \
  -F "path_0=rapports/2024/" \
  -F "file=@facture.pdf" \
  -F "path_1=factures/janvier/"
```

#### Upload avec attente de traitement synchrone

```bash
curl -X POST https://api.devana.ai/api/upload \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "folder: folder-uuid-123" \
  -H "wait: true" \
  -F "file=@document.pdf"
```

#### Attachement à une conversation

```bash
curl -X POST https://api.devana.ai/api/upload \
  -H "conversation: conv-uuid-456" \
  -F "file=@image.png"
```

---

## Limites et quotas

### Limites par fichier

| Limite                                 | Valeur    |
| -------------------------------------- | --------- |
| Taille maximale par fichier            | 10 GB     |
| Nombre maximum de fichiers par requête | 5000      |
| Timeout de traitement (mode synchrone) | 5 minutes |

### Limites de noms de fichiers

- Les noms de fichiers sont automatiquement convertis de Latin-1 vers UTF-8
- Les caractères spéciaux sont préservés
- La longueur maximale du nom est de 255 caractères

---

## Formats supportés

Devana.ai supporte plus de 50 formats de fichiers incluant :

- **Documents**: PDF, DOCX, DOC, ODT, RTF, TXT, MD
- **Tableurs**: XLSX, XLS, CSV, ODS
- **Présentations**: PPTX, PPT, ODP
- **Images**: PNG, JPG, JPEG, GIF, BMP, WEBP, SVG
- **Archives**: ZIP, TAR, GZ
- **Code source**: JS, TS, PY, JAVA, C, CPP, et plus

Pour la liste complète, consultez [Formats supportés](../../docs/supported-formats.md).

---

## Mode Fast

Le Mode Fast est automatiquement activé pour les attachements de conversation (quand aucun `folder` n'est spécifié) et peut être désactivé via le header `disableFastMode`.

### Caractéristiques du Mode Fast

- **Extraction optimisée** : Traitement prioritaire pour une disponibilité immédiate
- **Indexation rapide** : Les fichiers sont immédiatement disponibles pour les requêtes
- **Idéal pour** : Attachements de conversation, fichiers temporaires, documents nécessitant un accès immédiat

### Désactiver le Mode Fast

```bash
curl -X POST https://api.devana.ai/api/upload \
  -H "disableFastMode: true" \
  -F "file=@large-document.pdf"
```

---

## Cas d'usage avancés

### Upload avec organisation hiérarchique

Pour créer une structure de dossiers virtuels lors de l'upload :

```bash
# Structure créée :
# /2024/
#   ├── Q1/
#   │   ├── rapport-q1.pdf
#   │   └── resultats-q1.xlsx
#   └── Q2/
#       └── rapport-q2.pdf

curl -X POST https://api.devana.ai/api/upload \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "folder: folder-uuid-123" \
  -F "file=@rapport-q1.pdf" \
  -F "path_0=2024/Q1/" \
  -F "file=@resultats-q1.xlsx" \
  -F "path_1=2024/Q1/" \
  -F "file=@rapport-q2.pdf" \
  -F "path_2=2024/Q2/"
```

### Gestion des permissions

L'endpoint vérifie automatiquement les permissions selon le contexte :

1. **Dossiers de base (isBase=true)** :

   - Le propriétaire a tous les droits
   - Les autres utilisateurs nécessitent des permissions d'écriture sur l'agent associé

2. **Dossiers standards** :
   - Le propriétaire a tous les droits
   - Les autres utilisateurs nécessitent des permissions d'écriture explicites sur le dossier

### Détection de duplicatas

Le système détecte automatiquement les fichiers dupliqués basés sur :

- **Hash MD5** : Empêche l'upload de fichiers identiques dans le même dossier
- **URL d'origine** : Pour les fichiers provenant d'URLs externes

### Traitement asynchrone

Par défaut, l'extraction du contenu est asynchrone. Le système :

1. Upload le fichier dans le stockage cloud
2. Crée l'entrée en base de données
3. Retourne immédiatement l'ID du fichier
4. Lance l'extraction en arrière-plan (texte, embeddings, keywords)

Pour forcer l'attente :

```bash
curl -X POST https://api.devana.ai/api/upload \
  -H "wait: true" \
  -F "file=@document.pdf"
```

### Gestion des erreurs d'extraction

Si une erreur survient lors de l'extraction :

- Le fichier reste en base avec le statut `ERROR`
- Le message d'erreur est stocké dans le champ `errorMessage`
- Le fichier peut être re-traité ultérieurement

### Notifications en temps réel

Pour les uploads dans des dossiers, un événement WebSocket est publié :

```javascript
// Événement: VIRTUAL_FOLDERS_UPDATED
{
  "virtualFoldersUpdated": {
    "folderId": "folder-uuid-123",
    "folders": null  // Le client doit recharger la structure
  }
}
```

---

## Support et assistance

Pour toute question ou problème concernant l'API d'upload :

- Consultez la [documentation générale de l'API](../README.md)
- Contactez le support technique : support@devana.ai
- Reportez les bugs sur notre [GitHub](https://github.com/devana-ai/api-issues)
