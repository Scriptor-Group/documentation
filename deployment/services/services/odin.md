# Odin Service

Le **service Odin** fournit un OCR avancé (Reconnaissance Optique de Caractères) pour extraire et analyser le texte de vos documents. Il s’appuie sur différentes technologies pour garantir un traitement fiable et performant. Celui-ci permet le traitement des Tableaux/Images/Diagrammes/....

## Fonctionnalités principales

- **OCR avancé** : Extraction de texte à partir d’images et de documents scannés.  
- **Intégration LLM** : Interaction avec une API compatible OpenAI pour l’analyse et l’enrichissement sémantique.  
- **File d'attente** : Gestion asynchrone et scalable via BullMQ.  

## Configuration

Le service requiert plusieurs variables d'environnement pour fonctionner correctement. Vous pouvez les définir soit en passant des `-e` au moment de lancer le conteneur, soit en utilisant un fichier `.env` que vous montez dans votre conteneur.

| Nom                 | Description                                                                           | Obligatoire | Valeur par défaut |
|---------------------|---------------------------------------------------------------------------------------|------------|-------------------|
| `DEVANA_API_URL`    | URL de l’API Devana (pour les webhooks de retour de traitement).                      | Oui        | _N/A_            |
| `QUEUE_NAME`        | Nom de la queue utilisée dans Redis pour BullMQ.                                      | Non        | `odin_queue`      |
| `CONCURRENCY_QUEUE` | Nombre maximum d’opérations simultanées autorisées dans la queue.                     | Non        | `20`               |
| `REDIS_HOST`        | Hôte Redis (IP ou nom de domaine).                                                    | Oui        | _N/A_            |
| `REDIS_PORT`        | Port de Redis.                                                                        | Oui        | _N/A_            |
| `REDIS_PASSWORD`    | Mot de passe Redis.                                                                   | Oui        | _N/A_            |
| `LLM_API_URL`       | URL de base compatible avec l’API OpenAI.                                             | Oui        | _N/A_            |
| `LLM_API_KEY`       | Clé API pour l’API OpenAI.                                                            | Oui        | _N/A_            |

### Exemple de fichier `.env`

```bash
DEVANA_API_URL=https://votre-instance.devana.com
QUEUE_NAME=odin_queue
CONCURRENCY_QUEUE=5
REDIS_HOST=redis.local
REDIS_PORT=6379
REDIS_PASSWORD=secret
LLM_API_URL=https://api.openai.com
LLM_API_KEY=sk-xxxxx
```

## Installation via Docker

Le service Odin est distribué sous forme d’image Docker disponible sur le registre privé **registry.devana.ai**. 

### Pré-requis

1. **Accès au registre Docker** : Vous devez disposer d’un identifiant et d’un mot de passe pour le registre `registry.devana.ai`.
2. **Docker** : Assurez-vous que Docker est installé et configuré sur votre machine.  
