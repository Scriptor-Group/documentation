# Documentation du Système de Surveillance des Services

## Vue d'ensemble
Ce système de surveillance fournit des vérifications en temps réel de l'état des services d'infrastructure critiques : Base de données (PostgreSQL), Meilisearch, ChromaDB, Redis, Odin et le stockage objet (AWS S3 ou Azure Storage selon la configuration). Il propose à la fois une API et un tableau de bord visuel pour la surveillance du système.

## Table des matières
1. [Points d'accès API](#points-daccès-api)
2. [Tableau de bord](#accès-au-tableau-de-bord)
3. [Vérifications des services](#vérifications-des-services)
4. [Surveillance et alertes](#surveillance-et-alertes)
5. [Dépannage](#dépannage)

## Points d'accès API

### Vérification globale
```bash
GET /health/services
```
Vérifie tous les services configurés en parallèle.

### Vérification d'un service unique
```bash
GET /health/service/:service
```
Vérifie un seul service. Valeurs possibles pour `:service` : `database`, `meilisearch`, `chromaDB`, `redis`, `odin`, `s3`, `azureStorage`.

> Note : `s3` et `azureStorage` ne sont disponibles que si le backend de stockage correspondant est configuré (voir [Vérifications des services](#vérification-du-stockage-objet)).

### Format de réponse — `/health/services`
```json
{
  "status": "healthy" | "unhealthy",
  "timestamp": "2026-01-01T12:00:00.000Z",
  "vectorBusy": false,
  "services": {
    "database": {
      "status": "healthy" | "unhealthy" | "timeout",
      "responseTime": 50,
      "error": null
    },
    "meilisearch": {
      "status": "healthy" | "unhealthy" | "timeout",
      "responseTime": 45,
      "error": null
    }
    // ... autres services configurés
  },
  "vectorOperations": [
    {
      "id": "op-123",
      "operation": "embedding",
      "agentId": "agent-456",
      "duration": 1200,
      "details": {}
    }
  ]
}
```

Champs :
- `status` : statut global, `healthy` uniquement si **tous** les services sont `healthy`.
- `vectorBusy` : `true` si des opérations vectorielles sont en cours.
- `vectorOperations` : liste des opérations vectorielles en cours (vide sinon).
- `services.<nom>.status` : `healthy`, `unhealthy` (échec) ou `timeout` (dépassement du délai).
- `services.<nom>.responseTime` : durée en ms si `healthy`, `null` sinon.
- `services.<nom>.error` : message d'erreur si non `healthy`, `null` sinon.

### Format de réponse — `/health/service/:service`
```json
{
  "service": "redis",
  "timestamp": "2026-01-01T12:00:00.000Z",
  "status": "healthy" | "unhealthy" | "timeout",
  "responseTime": 12,
  "error": null
}
```

Si le service demandé n'existe pas (ou n'est pas configuré) :
```json
{
  "status": "unknown-service",
  "service": "foo",
  "error": "Service \"foo\" is not configured"
}
```

### Codes de statut
- `200` : service(s) opérationnel(s) (`status: healthy`)
- `500` : un ou plusieurs services défaillants (`unhealthy` ou `timeout`)
- `404` : service inconnu (endpoint unique uniquement)

## Vérifications des services

Chaque vérification dispose d'un délai d'expiration (timeout). Au-delà, le service est marqué `timeout`.

| Service | Sonde | Timeout |
| --- | --- | --- |
| `database` | Requête `SELECT 1` sur PostgreSQL | 4000 ms |
| `meilisearch` | Création de l'index `healthtest` + recherche `test` | 4000 ms |
| `chromaDB` | Création de la collection `healthtest` | 4000 ms |
| `redis` | Commande `PING` | 4000 ms |
| `odin` | GET `/api/v1/health` + vérification des workers de la queue `request` | 4000 ms |
| `s3` | `ListBuckets` (AWS S3) | 16000 ms |
| `azureStorage` | Vérification d'existence du conteneur Azure | 16000 ms |

### Vérification de la base de données
- Vérifie la connexion à PostgreSQL via une requête `SELECT 1`.

### Vérification de Meilisearch
- Crée/récupère l'index `healthtest` puis exécute une recherche `test`.

### Vérification de ChromaDB
- Crée/récupère la collection `healthtest`.

### Vérification de Redis
- Exécute une commande `PING`.

### Vérification d'Odin
- Appelle `GET {ODIN_API_URL}/api/v1/health` (échec si le statut HTTP n'est pas `ok`).
- Vérifie qu'au moins un worker consomme la queue BullMQ `request` (préfixe `devana:odin`). Aucun worker ⇒ `unhealthy`.

### Vérification du stockage objet
Un seul backend de stockage est vérifié, selon la configuration d'environnement :
- `s3` : actif si `AWS_S3_ACCESS_KEY_ID` est défini. Teste les permissions `ListBuckets`.
- `azureStorage` : actif si `AZURE_STORAGE_ACCOUNT_NAME` est défini (et `AWS_S3_ACCESS_KEY_ID` absent). Vérifie l'existence du conteneur.

## Surveillance et alertes

### Configuration recommandée de la surveillance

1. **Vérifications périodiques**
```bash
# Utilisation de cURL
curl -X GET http://votre-domaine/health/services -H "Accept: application/json"

# Utilisation de wget
wget -qO- http://votre-domaine/health/services

# Vérifier un service unique
curl -X GET http://votre-domaine/health/service/redis
```

2. **Exemple de script de surveillance**
```bash
#!/bin/bash

HEALTH_ENDPOINT="http://votre-domaine/health/services"
ALERT_EMAIL="admin@votre-domaine.com"

response=$(curl -s $HEALTH_ENDPOINT)
status=$(echo $response | jq -r '.status')

if [ "$status" != "healthy" ]; then
    echo "Système défaillant: $response" | mail -s "Alerte Santé" $ALERT_EMAIL
fi
```

3. **Configuration Crontab**
```bash
*/5 * * * * /chemin/vers/script-surveillance.sh
```

### Intégration avec les systèmes de surveillance

#### Configuration Prometheus
```yaml
scrape_configs:
  - job_name: 'surveillance-sante'
    metrics_path: '/health/services'
    scrape_interval: 30s
    static_configs:
      - targets: ['votre-domaine:port']
```

## Dépannage

### Problèmes courants et solutions

1. **Problèmes de connectivité base de données**
```bash
# Vérifier la connectivité
psql -h <hôte> -U <utilisateur> -d <base>
```

2. **Problèmes Meilisearch**
```bash
# Vérifier le statut
curl http://localhost:7700/health
```

3. **Problèmes Redis**
```bash
# Tester la connexion
redis-cli ping
```

4. **Problèmes Odin**
```bash
# Vérifier l'API Odin
curl ${ODIN_API_URL}/api/v1/health

# Si l'API répond mais le service est unhealthy :
# vérifier qu'au moins un worker consomme la queue "request"
```

### Étapes de récupération des services

1. **Récupération base de données**
```bash
# Redémarrer le service
sudo systemctl restart postgresql
```

2. **Récupération Redis**
```bash
# Vider le cache si nécessaire
redis-cli FLUSHALL
# Redémarrer Redis
sudo systemctl restart redis
```

3. **Récupération Odin**
```bash
# Redémarrer les workers Odin si la queue "request" n'a aucun consommateur
```

## Accès au tableau de bord

1. **Accéder au tableau de bord**
```
http://votre-domaine-front/health/
```

## Bonnes pratiques

1. **Surveillance régulière**
   - Mettre en place des vérifications automatisées toutes les 5 minutes
   - Configurer des alertes sur les statuts `unhealthy` et `timeout`
   - Surveiller `vectorBusy` / `vectorOperations` pour détecter une charge vectorielle anormale

2. **Maintenance**
   - Rotation régulière des logs
   - Redémarrages périodiques pendant les périodes creuses
   - Vérification régulière des sauvegardes

3. **Sécurité**
   - Restreindre l'accès aux points de santé aux IPs autorisées
   - Utiliser des identifiants sécurisés pour les connexions aux services
   - Audits de sécurité réguliers

## Support

Pour obtenir de l'aide supplémentaire ou signaler des problèmes :
- Créer une issue dans le dépôt
- Contact : support@devana.ai
