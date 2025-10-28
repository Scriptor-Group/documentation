# Documents API - Devana.ai

Documentation complète de l'API de gestion et d'extraction de documents dans Devana.ai.

**Base URL:** `https://api.devana.ai`
**Préfixe:** `/v1/documents`
**Authentification:** API Key requise

---

## 📑 Table des matières

- [Vue d'ensemble](#vue-densemble)
- [Authentification](#authentification)
- [Endpoints disponibles](#endpoints-disponibles)
  - [GET /v1/documents/:id](#get-v1documentsid---récupérer-le-contenu-dun-document)
  - [GET /v1/documents/:id/status](#get-v1documentsidstatus---statut-dextraction)
  - [POST /v1/documents](#post-v1documents---upload-et-extraction-de-document)
- [Format des payloads](#format-des-payloads)
- [Statuts d'extraction](#statuts-dextraction)
- [Types de fichiers supportés](#types-de-fichiers-supportés)
- [Gestion des erreurs](#gestion-des-erreurs)
- [Exemples avancés](#exemples-avancés)

---

## Vue d'ensemble

L'API Documents permet de gérer le cycle de vie complet des documents :
- Upload de documents avec extraction automatique du contenu
- Récupération du contenu extrait et structuré
- Suivi du statut d'extraction en temps réel
- Support de multiples formats (PDF, DOCX, images, etc.)

Cette API utilise un système d'extraction avancé (Odin) pour traiter les documents complexes et extraire leur structure, texte, tableaux et métadonnées.

---

## Authentification

Toutes les requêtes nécessitent une clé API dans le header `Authorization` :

```http
Authorization: Bearer YOUR_API_KEY
```

Les permissions sont vérifiées au niveau du dossier contenant le document.

---

## Endpoints disponibles

### GET /v1/documents/:id - Récupérer le contenu d'un document

Récupère le payload complet d'un document incluant le texte extrait, la structure et les métadonnées.

#### Paramètres

| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `id` | String (CUID) | Oui | Identifiant unique du document |

#### Requête

```http
GET /v1/documents/cm4doc123abc456def
Authorization: Bearer YOUR_API_KEY
```

#### Réponse (200 OK) - Document traité par Odin

```json
{
  "success": true,
  "data": {
    "documentId": "cm4doc123abc456def",
    "status": "DONE",
    "title": "Rapport Annuel 2024",
    "content": "Contenu extrait du document...",
    "pages": [
      {
        "pageNumber": 1,
        "text": "Texte de la première page...",
        "tables": [],
        "images": []
      }
    ],
    "metadata": {
      "author": "John Doe",
      "creationDate": "2024-01-15",
      "pageCount": 45,
      "language": "fr"
    },
    "summary": "Résumé automatique du document...",
    "keywords": ["rapport", "annuel", "2024", "finance"],
    "totalWords": 12500
  }
}
```

#### Réponse (200 OK) - Document texte simple

```json
{
  "success": true,
  "data": {
    "documentId": "cm4doc789xyz123abc",
    "status": "DONE",
    "text": "Contenu textuel du document...",
    "words": 500,
    "title": "document.txt",
    "metadata": {
      "mimetype": "text/plain",
      "size": 15678
    }
  }
}
```

#### Exemple avec curl

```bash
curl -X GET https://api.devana.ai/v1/documents/cm4doc123abc456def \
  -H "Authorization: Bearer YOUR_API_KEY"
```

---

### GET /v1/documents/:id/status - Statut d'extraction

Récupère uniquement le statut d'extraction d'un document sans le contenu complet.

#### Paramètres

| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `id` | String (CUID) | Oui | Identifiant unique du document |

#### Requête

```http
GET /v1/documents/cm4doc123abc456def/status
Authorization: Bearer YOUR_API_KEY
```

#### Réponse (200 OK)

```json
{
  "success": true,
  "data": "DONE"
}
```

**Statuts possibles :**
- `PENDING` : En attente de traitement
- `IN_PROGRESS` : Extraction en cours
- `DONE` : Extraction terminée avec succès
- `ERROR` : Erreur lors de l'extraction

#### Exemple avec curl

```bash
curl -X GET https://api.devana.ai/v1/documents/cm4doc123abc456def/status \
  -H "Authorization: Bearer YOUR_API_KEY"
```

#### Utilisation pour le polling

```bash
# Script de polling pour attendre la fin de l'extraction
DOCUMENT_ID="cm4doc123abc456def"
STATUS="PENDING"

while [ "$STATUS" != "DONE" ] && [ "$STATUS" != "ERROR" ]; do
  STATUS=$(curl -s -X GET "https://api.devana.ai/v1/documents/$DOCUMENT_ID/status" \
    -H "Authorization: Bearer YOUR_API_KEY" | jq -r '.data')

  echo "Status: $STATUS"

  if [ "$STATUS" = "ERROR" ]; then
    echo "Erreur lors de l'extraction"
    exit 1
  fi

  if [ "$STATUS" != "DONE" ]; then
    sleep 2
  fi
done

echo "Extraction terminée, récupération du contenu..."
curl -X GET "https://api.devana.ai/v1/documents/$DOCUMENT_ID" \
  -H "Authorization: Bearer YOUR_API_KEY"
```

---

### POST /v1/documents - Upload et extraction de document

Upload un document et lance automatiquement l'extraction du contenu. Retourne immédiatement le payload pour les fichiers simples ou après traitement pour les documents complexes.

#### Headers

| Header | Type | Requis | Description |
|---------|------|--------|-------------|
| `Authorization` | String | Oui | Token Bearer avec API Key |
| `Content-Type` | String | Oui | `multipart/form-data` |

#### Body Parameters (multipart/form-data)

| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `file` | File | Oui | Le fichier à uploader |
| `folderId` | String (CUID) | Oui | ID du dossier de destination |

#### Requête

```http
POST /v1/documents
Authorization: Bearer YOUR_API_KEY
Content-Type: multipart/form-data
```

#### Réponse (200 OK) - Document complexe (PDF, DOCX, Images)

Le système attend la fin de l'extraction avant de répondre :

```json
{
  "success": true,
  "data": {
    "documentId": "cm4newdoc456xyz789",
    "status": "DONE",
    "title": "Présentation Q4 2024",
    "content": "Contenu extrait structuré...",
    "pages": [
      {
        "pageNumber": 1,
        "text": "Slide 1: Résultats Q4 2024...",
        "images": [
          {
            "url": "https://storage.devana.ai/images/chart1.png",
            "caption": "Graphique des ventes"
          }
        ]
      }
    ],
    "metadata": {
      "format": "PDF",
      "pageCount": 25,
      "extractionTime": 3.5
    },
    "summary": "Présentation des résultats du quatrième trimestre...",
    "totalWords": 3500
  }
}
```

#### Réponse (200 OK) - Document texte simple

Pour les fichiers texte simples, la réponse est immédiate :

```json
{
  "success": true,
  "data": {
    "text": "Contenu du fichier texte...",
    "words": 250,
    "title": "readme.md",
    "metadata": {
      "mimetype": "text/markdown",
      "size": 5678
    }
  }
}
```

#### Exemple avec curl - Upload PDF

```bash
curl -X POST https://api.devana.ai/v1/documents \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -F "file=@presentation.pdf" \
  -F "folderId=cm4folder123abc"
```

#### Exemple avec curl - Upload image

```bash
curl -X POST https://api.devana.ai/v1/documents \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -F "file=@diagram.png" \
  -F "folderId=cm4folder123abc"
```

---

## Format des payloads

### Payload Odin (documents complexes)

Les documents traités par Odin retournent un payload structuré :

```typescript
interface OdinPayload {
  documentId: string;
  status: ExtractStatus;
  title?: string;
  content?: string;
  pages?: Page[];
  metadata?: DocumentMetadata;
  summary?: string;
  keywords?: string[];
  totalWords?: number;
  error?: string;
}

interface Page {
  pageNumber: number;
  text: string;
  tables?: Table[];
  images?: Image[];
}

interface DocumentMetadata {
  author?: string;
  creationDate?: string;
  modificationDate?: string;
  pageCount?: number;
  language?: string;
  format?: string;
  extractionTime?: number;
}
```

### Payload texte simple

Les fichiers texte retournent un payload simplifié :

```typescript
interface TextPayload {
  text: string;
  words: number;
  title: string;
  metadata: {
    mimetype: string;
    size: number;
  };
}
```

---

## Statuts d'extraction

| Statut | Description | Actions recommandées |
|--------|-------------|---------------------|
| `PENDING` | Document en file d'attente | Attendre et vérifier régulièrement |
| `IN_PROGRESS` | Extraction en cours | Continuer le polling |
| `DONE` | Extraction réussie | Récupérer le payload complet |
| `ERROR` | Échec de l'extraction | Vérifier les logs, réessayer si nécessaire |

---

## Types de fichiers supportés

### Documents avec extraction Odin
- **PDF** : Extraction complète avec structure, images, tableaux
- **DOCX/DOC** : Documents Word avec formatage préservé
- **PPTX/PPT** : Présentations PowerPoint
- **Images** : PNG, JPG, JPEG (avec OCR si nécessaire)

### Documents avec extraction simple
- **Texte** : TXT, MD, CSV
- **Code** : JS, PY, JSON, XML, HTML
- **Tableurs** : XLSX, XLS (extraction basique)

Pour la liste complète, consultez [Formats supportés](../../docs/supported-formats.md).

---

## Gestion des erreurs

| Code | Message | Description | Solution |
|------|---------|-------------|----------|
| `400` | Bad Request | Paramètres invalides | Vérifier le format des paramètres |
| `400` | No file uploaded | Aucun fichier fourni | Inclure un fichier dans la requête |
| `401` | Unauthorized | Permissions insuffisantes | Vérifier les droits sur le dossier |
| `404` | File/Folder not found | Ressource introuvable | Vérifier l'ID fourni |
| `408` | Request Timeout | Extraction trop longue | Réessayer ou utiliser l'API Jobs |
| `500` | Internal Server Error | Erreur serveur | Contacter le support |

### Gestion des erreurs d'extraction

En cas d'erreur lors de l'extraction :

```json
{
  "success": false,
  "error": {
    "code": "EXTRACTION_FAILED",
    "message": "Failed to extract content from PDF",
    "details": "Corrupted file or unsupported format"
  }
}
```

---

## Exemples avancés

### Upload et traitement de document avec retry

```javascript
async function uploadDocumentWithRetry(file, folderId, maxRetries = 3) {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('folderId', folderId);

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch('https://api.devana.ai/v1/documents', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${API_KEY}`
        },
        body: formData
      });

      if (response.ok) {
        const data = await response.json();

        // Si le document est en cours de traitement
        if (data.data.status === 'IN_PROGRESS') {
          return await waitForExtraction(data.data.documentId);
        }

        return data.data;
      }

      if (response.status === 408 && attempt < maxRetries) {
        console.log(`Timeout, retry ${attempt}/${maxRetries}`);
        await new Promise(resolve => setTimeout(resolve, 2000 * attempt));
        continue;
      }

      throw new Error(`Upload failed: ${response.statusText}`);
    } catch (error) {
      if (attempt === maxRetries) throw error;
      console.log(`Error on attempt ${attempt}, retrying...`);
    }
  }
}

async function waitForExtraction(documentId) {
  let status = 'PENDING';
  let attempts = 0;
  const maxAttempts = 60; // 2 minutes maximum

  while (status !== 'DONE' && status !== 'ERROR' && attempts < maxAttempts) {
    await new Promise(resolve => setTimeout(resolve, 2000));

    const response = await fetch(
      `https://api.devana.ai/v1/documents/${documentId}/status`,
      {
        headers: {
          'Authorization': `Bearer ${API_KEY}`
        }
      }
    );

    const data = await response.json();
    status = data.data;
    attempts++;

    console.log(`Status: ${status} (attempt ${attempts}/${maxAttempts})`);
  }

  if (status === 'DONE') {
    // Récupérer le payload complet
    const response = await fetch(
      `https://api.devana.ai/v1/documents/${documentId}`,
      {
        headers: {
          'Authorization': `Bearer ${API_KEY}`
        }
      }
    );

    return (await response.json()).data;
  }

  throw new Error(`Extraction failed with status: ${status}`);
}
```

### Batch processing de documents

```bash
#!/bin/bash

# Upload multiple documents to a folder
FOLDER_ID="cm4folder123abc"
FILES=("report.pdf" "presentation.pptx" "data.xlsx")
DOCUMENT_IDS=()

echo "Uploading documents..."

for FILE in "${FILES[@]}"; do
  echo "Uploading $FILE..."

  RESPONSE=$(curl -s -X POST https://api.devana.ai/v1/documents \
    -H "Authorization: Bearer YOUR_API_KEY" \
    -F "file=@$FILE" \
    -F "folderId=$FOLDER_ID")

  DOC_ID=$(echo $RESPONSE | jq -r '.data.documentId')
  DOCUMENT_IDS+=($DOC_ID)

  echo "Document $FILE uploaded with ID: $DOC_ID"
done

echo "Checking extraction status..."

# Wait for all documents to be processed
ALL_DONE=false
while [ "$ALL_DONE" = false ]; do
  ALL_DONE=true

  for DOC_ID in "${DOCUMENT_IDS[@]}"; do
    STATUS=$(curl -s -X GET "https://api.devana.ai/v1/documents/$DOC_ID/status" \
      -H "Authorization: Bearer YOUR_API_KEY" | jq -r '.data')

    echo "Document $DOC_ID: $STATUS"

    if [ "$STATUS" != "DONE" ] && [ "$STATUS" != "ERROR" ]; then
      ALL_DONE=false
    fi
  done

  if [ "$ALL_DONE" = false ]; then
    sleep 3
  fi
done

echo "All documents processed!"

# Retrieve all payloads
for DOC_ID in "${DOCUMENT_IDS[@]}"; do
  echo "Retrieving content for $DOC_ID..."
  curl -X GET "https://api.devana.ai/v1/documents/$DOC_ID" \
    -H "Authorization: Bearer YOUR_API_KEY" \
    -o "output_$DOC_ID.json"
done
```

### Extraction avec analyse du contenu

```python
import requests
import json
from typing import Dict, List

class DocumentProcessor:
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://api.devana.ai/v1"
        self.headers = {"Authorization": f"Bearer {api_key}"}

    def upload_and_analyze(self, file_path: str, folder_id: str) -> Dict:
        """Upload un document et analyse son contenu"""

        # Upload du document
        with open(file_path, 'rb') as f:
            files = {'file': f}
            data = {'folderId': folder_id}

            response = requests.post(
                f"{self.base_url}/documents",
                headers=self.headers,
                files=files,
                data=data
            )

        if response.status_code != 200:
            raise Exception(f"Upload failed: {response.text}")

        document = response.json()['data']

        # Analyser le contenu
        analysis = self.analyze_content(document)

        return {
            'document': document,
            'analysis': analysis
        }

    def analyze_content(self, document: Dict) -> Dict:
        """Analyse le contenu extrait"""

        analysis = {
            'word_count': document.get('totalWords', 0),
            'page_count': len(document.get('pages', [])),
            'has_tables': False,
            'has_images': False,
            'keywords': document.get('keywords', []),
            'language': document.get('metadata', {}).get('language'),
            'summary_available': 'summary' in document
        }

        # Vérifier la présence de tableaux et images
        for page in document.get('pages', []):
            if page.get('tables'):
                analysis['has_tables'] = True
            if page.get('images'):
                analysis['has_images'] = True

        return analysis

    def extract_tables(self, document: Dict) -> List[Dict]:
        """Extrait tous les tableaux du document"""

        tables = []
        for page in document.get('pages', []):
            for table in page.get('tables', []):
                tables.append({
                    'page': page['pageNumber'],
                    'data': table
                })

        return tables

# Utilisation
processor = DocumentProcessor("YOUR_API_KEY")

result = processor.upload_and_analyze(
    "financial_report.pdf",
    "cm4folder123abc"
)

print(f"Document analysé : {result['document']['title']}")
print(f"Analyse : {json.dumps(result['analysis'], indent=2)}")

# Extraire les tableaux si présents
if result['analysis']['has_tables']:
    tables = processor.extract_tables(result['document'])
    print(f"Nombre de tableaux trouvés : {len(tables)}")
```

---

## Intégration avec l'API Jobs

Pour les documents volumineux ou les traitements batch, utilisez l'API Jobs pour suivre l'extraction :

```bash
# Vérifier le job d'extraction
curl -X GET "https://api.devana.ai/v1/jobs?targetId=cm4doc123abc&type=EXTRACTION" \
  -H "Authorization: Bearer YOUR_API_KEY"
```

---

## Bonnes pratiques

1. **Gestion des timeouts**
   - Implémenter un système de retry pour les uploads
   - Utiliser le polling pour les documents complexes
   - Définir un timeout maximum (ex: 5 minutes)

2. **Optimisation des performances**
   - Grouper les uploads en batch quand possible
   - Utiliser l'API Jobs pour le suivi asynchrone
   - Mettre en cache les payloads extraits

3. **Gestion des erreurs**
   - Toujours vérifier le statut d'extraction
   - Logger les erreurs pour le debugging
   - Prévoir un fallback pour les échecs d'extraction

4. **Sécurité**
   - Vérifier les permissions avant l'upload
   - Valider les types de fichiers côté client
   - Limiter la taille des uploads

---

## Support et assistance

Pour toute question ou problème concernant l'API Documents :
- Consultez la [documentation générale de l'API](../README.md)
- Contactez le support technique : support@devana.ai
- Reportez les bugs sur notre [GitHub](https://github.com/devana-ai/api-issues)