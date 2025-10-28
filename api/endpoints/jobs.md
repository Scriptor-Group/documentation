# Jobs API

Documentation de l'API de gestion des tâches asynchrones (Jobs) dans Devana.ai.

**Base URL:** `https://api.devana.ai`
**Préfixe:** `/v1/jobs`
**Authentification:** API Key requise

---

## 📑 Table des matières

- [Vue d'ensemble](#vue-densemble)
- [Authentification](#authentification)
- [Endpoint disponible](#endpoint-disponible)
  - [GET /v1/jobs](#get-v1jobs---lister-les-tâches)
- [Types de jobs](#types-de-jobs)
- [Statuts des jobs](#statuts-des-jobs)
- [Filtrage et pagination](#filtrage-et-pagination)
- [Structure des jobs](#structure-des-jobs)
- [Exemples d'utilisation](#exemples-dutilisation)
- [Cas d'usage avancés](#cas-dusage-avancés)

---

## Vue d'ensemble

L'API Jobs permet de suivre l'état des tâches asynchrones dans Devana.ai. Ces tâches incluent :

- Extraction de contenu de documents
- Génération d'embeddings
- Synchronisation de dossiers
- Import de données externes
- Traitement batch de fichiers

**Caractéristiques principales :**

- Suivi en temps réel des tâches
- Filtrage par type et statut
- Historique limité aux dernières 24 heures
- Pagination pour les grandes listes

---

## Authentification

Toutes les requêtes nécessitent une clé API dans le header `Authorization` :

```http
Authorization: Bearer YOUR_API_KEY
```

---

## Endpoint disponible

### GET /v1/jobs - Lister les tâches

Récupère la liste des tâches asynchrones de l'utilisateur avec possibilité de filtrage.

#### Query Parameters

| Paramètre  | Type          | Requis | Description                                                    | Valeur par défaut |
| ---------- | ------------- | ------ | -------------------------------------------------------------- | ----------------- |
| `targetId` | String        | Non    | ID de la ressource cible (document, dossier, etc.)             | -                 |
| `type`     | String (Enum) | Non    | Filtrer par statut : `PENDING`, `IN_PROGRESS`, `DONE`, `ERROR` | -                 |
| `limit`    | Number        | Non    | Nombre maximum de résultats                                    | 25                |
| `offset`   | Number        | Non    | Décalage pour la pagination                                    | 0                 |

#### Requête

```http
GET /v1/jobs?targetId=cm4doc123&type=IN_PROGRESS&limit=10
Authorization: Bearer YOUR_API_KEY
```

#### Réponse (200 OK)

```json
{
  "success": true,
  "data": [
    {
      "id": "cm4job789xyz123",
      "userId": "cm4user456abc",
      "targetId": "cm4doc123abc456",
      "type": "EXTRACTION",
      "status": "IN_PROGRESS",
      "progress": 65,
      "metadata": {
        "fileName": "rapport-2024.pdf",
        "fileSize": 2456789,
        "pageCount": 45
      },
      "startedAt": "2024-10-28T10:30:00.000Z",
      "createdAt": "2024-10-28T10:29:00.000Z",
      "updatedAt": "2024-10-28T10:35:00.000Z"
    },
    {
      "id": "cm4job456def789",
      "userId": "cm4user456abc",
      "targetId": "cm4folder789xyz",
      "type": "EMBEDDING",
      "status": "DONE",
      "progress": 100,
      "metadata": {
        "folderName": "Documentation",
        "filesProcessed": 25,
        "totalChunks": 1250
      },
      "startedAt": "2024-10-28T09:00:00.000Z",
      "completedAt": "2024-10-28T09:15:00.000Z",
      "createdAt": "2024-10-28T08:59:00.000Z",
      "updatedAt": "2024-10-28T09:15:00.000Z"
    }
  ]
}
```

#### Exemples avec curl

**Récupérer toutes les tâches récentes :**

```bash
curl -X GET https://api.devana.ai/v1/jobs \
  -H "Authorization: Bearer YOUR_API_KEY"
```

**Filtrer par document spécifique :**

```bash
curl -X GET "https://api.devana.ai/v1/jobs?targetId=cm4doc123abc456" \
  -H "Authorization: Bearer YOUR_API_KEY"
```

**Récupérer les tâches en erreur :**

```bash
curl -X GET "https://api.devana.ai/v1/jobs?type=ERROR" \
  -H "Authorization: Bearer YOUR_API_KEY"
```

**Pagination des résultats :**

```bash
curl -X GET "https://api.devana.ai/v1/jobs?limit=50&offset=50" \
  -H "Authorization: Bearer YOUR_API_KEY"
```

---

## Types de jobs

Les différents types de tâches trackées par le système :

| Type            | Description                                             | Durée typique |
| --------------- | ------------------------------------------------------- | ------------- |
| `EXTRACTION`    | Extraction de contenu de documents (PDF, DOCX, etc.)    | 5s - 5min     |
| `EMBEDDING`     | Génération de vecteurs pour la recherche sémantique     | 10s - 10min   |
| `SYNC`          | Synchronisation de dossiers externes (SharePoint, etc.) | 1min - 30min  |
| `IMPORT`        | Import batch de fichiers                                | 30s - 15min   |
| `TRANSCRIPTION` | Transcription audio (STT)                               | 10s - 5min    |
| `GENERATION`    | Génération de contenu ou résumés                        | 5s - 2min     |

---

## Statuts des jobs

| Statut        | Description                            | Action recommandée               |
| ------------- | -------------------------------------- | -------------------------------- |
| `PENDING`     | Tâche en attente dans la queue         | Attendre, vérifier régulièrement |
| `IN_PROGRESS` | Tâche en cours d'exécution             | Continuer le polling             |
| `DONE`        | Tâche terminée avec succès             | Récupérer les résultats          |
| `ERROR`       | Échec de la tâche                      | Vérifier les logs, réessayer     |
| `KILLED`      | Tâche annulée (non retourné par l'API) | -                                |

**Note :** Les jobs avec statut `KILLED` sont automatiquement filtrés et ne sont jamais retournés.

---

## Filtrage et pagination

### Filtrage par date

- Seuls les jobs des dernières **24 heures** sont retournés
- Pour un historique plus ancien, utilisez l'interface web

### Limitations

- Maximum 100 résultats par requête
- Offset maximum : 1000
- Les jobs sont triés par date de création (plus récent en premier)

### Exemples de filtrage complexe

```javascript
// Récupérer les jobs d'un dossier spécifique
async function getFolderJobs(folderId) {
  const response = await fetch(
    `https://api.devana.ai/v1/jobs?targetId=${folderId}`,
    {
      headers: {
        Authorization: `Bearer ${API_KEY}`,
      },
    }
  );

  const data = await response.json();
  return data.data;
}

// Filtrer les jobs par multiple critères
async function getFilteredJobs(filters) {
  const params = new URLSearchParams();

  if (filters.targetId) params.append("targetId", filters.targetId);
  if (filters.type) params.append("type", filters.type);
  if (filters.limit) params.append("limit", filters.limit);
  if (filters.offset) params.append("offset", filters.offset);

  const response = await fetch(
    `https://api.devana.ai/v1/jobs?${params.toString()}`,
    {
      headers: {
        Authorization: `Bearer ${API_KEY}`,
      },
    }
  );

  return response.json();
}
```

---

## Structure des jobs

### Objet Job complet

```typescript
interface Job {
  id: string; // Identifiant unique du job
  userId: string; // ID de l'utilisateur propriétaire
  targetId: string; // ID de la ressource cible
  type: JobType; // Type de tâche
  status: JobStatus; // Statut actuel
  progress?: number; // Progression (0-100)
  metadata?: {
    // Métadonnées spécifiques au type
    [key: string]: any;
  };
  error?: string; // Message d'erreur si échec
  startedAt?: Date; // Début de l'exécution
  completedAt?: Date; // Fin de l'exécution
  createdAt: Date; // Création du job
  updatedAt: Date; // Dernière mise à jour
}
```

### Métadonnées par type

**EXTRACTION:**

```json
{
  "fileName": "document.pdf",
  "fileSize": 1234567,
  "mimeType": "application/pdf",
  "pageCount": 10,
  "extractionMethod": "ODIN"
}
```

**EMBEDDING:**

```json
{
  "folderName": "Knowledge Base",
  "filesProcessed": 15,
  "totalChunks": 450,
  "chunkSize": 500,
  "model": "text-embedding-ada-002"
}
```

---

## Exemples d'utilisation

### Monitoring d'extraction de document

```bash
#!/bin/bash

# Upload un document et suivre son extraction
DOCUMENT_ID="cm4doc123abc456"

# Fonction pour vérifier le statut
check_job_status() {
  local doc_id=$1

  while true; do
    # Récupérer le job d'extraction
    JOB=$(curl -s -X GET "https://api.devana.ai/v1/jobs?targetId=$doc_id&type=EXTRACTION" \
      -H "Authorization: Bearer YOUR_API_KEY" | jq -r '.data[0]')

    if [ "$JOB" = "null" ]; then
      echo "Aucun job trouvé pour le document $doc_id"
      break
    fi

    STATUS=$(echo $JOB | jq -r '.status')
    PROGRESS=$(echo $JOB | jq -r '.progress // 0')

    echo "Status: $STATUS - Progress: $PROGRESS%"

    case $STATUS in
      "DONE")
        echo "Extraction terminée avec succès!"
        break
        ;;
      "ERROR")
        ERROR=$(echo $JOB | jq -r '.error')
        echo "Erreur lors de l'extraction: $ERROR"
        exit 1
        ;;
      *)
        sleep 2
        ;;
    esac
  done
}

check_job_status $DOCUMENT_ID
```

### Suivi de synchronisation de dossier

```python
import requests
import time
from typing import Dict, Optional

class JobMonitor:
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://api.devana.ai/v1"
        self.headers = {"Authorization": f"Bearer {api_key}"}

    def wait_for_job(self, target_id: str, job_type: str = None,
                     timeout: int = 300) -> Optional[Dict]:
        """
        Attend la fin d'un job avec timeout

        Args:
            target_id: ID de la ressource cible
            job_type: Type de job à filtrer (optionnel)
            timeout: Timeout en secondes

        Returns:
            Job terminé ou None si timeout
        """
        start_time = time.time()

        while time.time() - start_time < timeout:
            # Récupérer les jobs
            params = {"targetId": target_id}
            if job_type:
                params["type"] = job_type

            response = requests.get(
                f"{self.base_url}/jobs",
                headers=self.headers,
                params=params
            )

            if response.status_code != 200:
                raise Exception(f"API Error: {response.text}")

            jobs = response.json()["data"]

            if not jobs:
                print(f"No jobs found for {target_id}")
                return None

            # Prendre le job le plus récent
            job = jobs[0]
            status = job["status"]
            progress = job.get("progress", 0)

            print(f"Job {job['id']}: {status} ({progress}%)")

            if status == "DONE":
                return job
            elif status == "ERROR":
                raise Exception(f"Job failed: {job.get('error', 'Unknown error')}")

            time.sleep(2)

        raise TimeoutError(f"Job timeout after {timeout} seconds")

    def get_job_statistics(self) -> Dict:
        """Récupère les statistiques sur les jobs récents"""

        response = requests.get(
            f"{self.base_url}/jobs",
            headers=self.headers,
            params={"limit": 100}
        )

        jobs = response.json()["data"]

        stats = {
            "total": len(jobs),
            "pending": sum(1 for j in jobs if j["status"] == "PENDING"),
            "in_progress": sum(1 for j in jobs if j["status"] == "IN_PROGRESS"),
            "done": sum(1 for j in jobs if j["status"] == "DONE"),
            "error": sum(1 for j in jobs if j["status"] == "ERROR"),
            "by_type": {}
        }

        for job in jobs:
            job_type = job.get("type", "UNKNOWN")
            if job_type not in stats["by_type"]:
                stats["by_type"][job_type] = 0
            stats["by_type"][job_type] += 1

        return stats

# Utilisation
monitor = JobMonitor("YOUR_API_KEY")

# Attendre la fin d'une extraction
try:
    completed_job = monitor.wait_for_job(
        "cm4doc123abc",
        job_type="EXTRACTION",
        timeout=120
    )
    print(f"Extraction terminée: {completed_job}")
except TimeoutError:
    print("L'extraction a pris trop de temps")
except Exception as e:
    print(f"Erreur: {e}")

# Obtenir les statistiques
stats = monitor.get_job_statistics()
print(f"Statistiques des jobs: {stats}")
```

---

## Cas d'usage avancés

### Dashboard de monitoring

```javascript
// Créer un dashboard de suivi des jobs
class JobDashboard {
  constructor(apiKey) {
    this.apiKey = apiKey;
    this.jobs = new Map();
    this.updateInterval = null;
  }

  async fetchJobs() {
    const response = await fetch("https://api.devana.ai/v1/jobs?limit=50", {
      headers: {
        Authorization: `Bearer ${this.apiKey}`,
      },
    });

    const data = await response.json();
    return data.data;
  }

  async updateDashboard() {
    const jobs = await this.fetchJobs();

    // Mettre à jour le cache local
    jobs.forEach((job) => {
      const existing = this.jobs.get(job.id);

      if (!existing || existing.status !== job.status) {
        this.onJobUpdate(job, existing);
      }

      this.jobs.set(job.id, job);
    });

    this.renderDashboard();
  }

  onJobUpdate(newJob, oldJob) {
    // Notification de changement de statut
    if (oldJob && oldJob.status !== newJob.status) {
      console.log(
        `Job ${newJob.id} changed from ${oldJob.status} to ${newJob.status}`
      );

      if (newJob.status === "ERROR") {
        this.notifyError(newJob);
      } else if (newJob.status === "DONE") {
        this.notifyComplete(newJob);
      }
    }
  }

  renderDashboard() {
    const stats = this.getStatistics();

    console.clear();
    console.log("=== JOB DASHBOARD ===");
    console.log(`Total: ${stats.total}`);
    console.log(`Pending: ${stats.pending}`);
    console.log(`In Progress: ${stats.inProgress}`);
    console.log(`Completed: ${stats.completed}`);
    console.log(`Errors: ${stats.errors}`);
    console.log("\n=== ACTIVE JOBS ===");

    // Afficher les jobs actifs
    Array.from(this.jobs.values())
      .filter((job) => job.status === "IN_PROGRESS")
      .forEach((job) => {
        console.log(`${job.id}: ${job.type} - ${job.progress || 0}%`);
      });
  }

  getStatistics() {
    const jobs = Array.from(this.jobs.values());

    return {
      total: jobs.length,
      pending: jobs.filter((j) => j.status === "PENDING").length,
      inProgress: jobs.filter((j) => j.status === "IN_PROGRESS").length,
      completed: jobs.filter((j) => j.status === "DONE").length,
      errors: jobs.filter((j) => j.status === "ERROR").length,
    };
  }

  notifyError(job) {
    // Implémenter notification d'erreur
    console.error(`⚠️ Job failed: ${job.id} - ${job.error}`);
  }

  notifyComplete(job) {
    // Implémenter notification de succès
    console.log(`✅ Job completed: ${job.id}`);
  }

  start() {
    this.updateDashboard();
    this.updateInterval = setInterval(() => {
      this.updateDashboard();
    }, 5000); // Update every 5 seconds
  }

  stop() {
    if (this.updateInterval) {
      clearInterval(this.updateInterval);
    }
  }
}

// Lancer le dashboard
const dashboard = new JobDashboard("YOUR_API_KEY");
dashboard.start();
```

### Retry automatique des jobs en échec

```bash
#!/bin/bash

# Script de retry automatique pour les jobs en échec

API_KEY="YOUR_API_KEY"
MAX_RETRIES=3

retry_failed_jobs() {
  echo "Recherche des jobs en échec..."

  # Récupérer les jobs en erreur
  FAILED_JOBS=$(curl -s -X GET "https://api.devana.ai/v1/jobs?type=ERROR" \
    -H "Authorization: Bearer $API_KEY" | jq -r '.data[]')

  if [ -z "$FAILED_JOBS" ]; then
    echo "Aucun job en échec trouvé"
    return
  fi

  echo "$FAILED_JOBS" | jq -c '.' | while read -r job; do
    JOB_ID=$(echo $job | jq -r '.id')
    TARGET_ID=$(echo $job | jq -r '.targetId')
    JOB_TYPE=$(echo $job | jq -r '.type')

    echo "Retry du job $JOB_ID (Type: $JOB_TYPE, Target: $TARGET_ID)"

    case $JOB_TYPE in
      "EXTRACTION")
        # Relancer l'extraction
        curl -X POST "https://api.devana.ai/v1/documents/$TARGET_ID/reextract" \
          -H "Authorization: Bearer $API_KEY"
        ;;
      "EMBEDDING")
        # Relancer la génération d'embeddings
        curl -X POST "https://api.devana.ai/v1/folders/$TARGET_ID/reindex" \
          -H "Authorization: Bearer $API_KEY"
        ;;
      *)
        echo "Type de job non supporté pour le retry: $JOB_TYPE"
        ;;
    esac

    sleep 2
  done
}

# Exécuter toutes les 5 minutes
while true; do
  retry_failed_jobs
  echo "Prochaine vérification dans 5 minutes..."
  sleep 300
done
```

---

## Intégration avec webhooks

Pour recevoir des notifications en temps réel sur les changements de statut des jobs, configurez des webhooks :

```javascript
// Exemple de webhook handler
app.post("/webhook/job-status", (req, res) => {
  const { jobId, status, targetId, type, metadata } = req.body;

  console.log(`Job ${jobId} updated: ${status}`);

  switch (status) {
    case "DONE":
      // Traiter la fin du job
      handleJobComplete(targetId, type, metadata);
      break;
    case "ERROR":
      // Gérer l'erreur
      handleJobError(jobId, metadata.error);
      break;
  }

  res.status(200).send("OK");
});
```

---

## Limitations et considérations

1. **Rétention des données**

   - Les jobs sont conservés seulement 24 heures
   - Pour un historique long terme, stockez les résultats localement

2. **Rate limiting**

   - Maximum 100 requêtes par minute
   - Utilisez le polling intelligent avec backoff exponentiel

3. **Performance**
   - Évitez les requêtes trop fréquentes (minimum 2 secondes entre les polls)
   - Utilisez les filtres pour réduire la charge

---

## Support et assistance

Pour toute question ou problème concernant l'API Jobs :

- Consultez la [documentation générale de l'API](../README.md)
- Contactez le support technique : support@devana.ai
- Reportez les bugs sur notre [GitHub](https://github.com/devana-ai/api-issues)
