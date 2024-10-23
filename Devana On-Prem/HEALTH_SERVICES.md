# Documentation du Système de Surveillance des Services

## Vue d'ensemble
Ce système de surveillance fournit des vérifications en temps réel de l'état des services d'infrastructure critiques, notamment la Base de données, Meilisearch, ChromaDB, Redis, S3 et le service de conversion PDF. Il propose à la fois une API et un tableau de bord visuel pour la surveillance du système.

## Table des matières
1. [Point d'accès API](#point-daccès-api)
2. [Tableau de bord](#tableau-de-bord)
3. [Vérifications des services](#vérifications-des-services)
4. [Surveillance et alertes](#surveillance-et-alertes)
5. [Dépannage](#dépannage)

## Point d'accès API

### Vérification de base
```bash
GET /health/services
```

### Format de réponse
```json
{
  "status": "healthy" | "unhealthy",
  "timestamp": "2024-01-01T12:00:00.000Z",
  "totalResponseTime": 235,
  "services": {
    "database": {
      "status": "healthy" | "unhealthy",
      "responseTime": 50,
      "error": null | "message d'erreur"
    },
    "meilisearch": {
      "status": "healthy" | "unhealthy",
      "responseTime": 45,
      "error": null | "message d'erreur"
    },
    // ... autres services
  }
}
```

### Codes de statut
- `200`: Tous les systèmes sont opérationnels
- `500`: Un ou plusieurs services sont défaillants

## Vérifications des services

### Vérification de la base de données
- Vérifie la connexion à la base de données PostgreSQL
- Effectue une requête simple pour vérifier l'accès en lecture
- Seuil de temps de réponse : < 1000ms

### Vérification de Meilisearch
- Vérifie la connexion au serveur Meilisearch
- Teste la création d'index et la fonctionnalité de recherche
- Seuil de temps de réponse : < 500ms

### Vérification de ChromaDB
- Vérifie la connexion à ChromaDB
- Teste la création de collection
- Seuil de temps de réponse : < 1000ms

### Vérification de Redis
- Vérifie la connexion au serveur Redis
- Effectue une commande PING
- Seuil de temps de réponse : < 100ms

### Vérification de S3
- Vérifie la connectivité AWS S3
- Teste les permissions de listage des buckets
- Seuil de temps de réponse : < 300ms

### Vérification du service PDF
- Vérifie la disponibilité du service de conversion PDF
- Teste le point d'accès de santé
- Seuil de temps de réponse : < 500ms

## Surveillance et alertes

### Configuration recommandée de la surveillance

1. **Vérifications périodiques**
```bash
# Utilisation de cURL
curl -X GET http://votre-domaine/health/services -H "Accept: application/json"

# Utilisation de wget
wget -qO- http://votre-domaine/health/services
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

3. **Récupération service PDF**
```bash
# Redémarrer le service
sudo systemctl restart pdf-conversion-service
```

## Accès au tableau de bord

1. **Accéder au tableau de bord**
```
http://votre-domaine-front/health/
```

## Bonnes pratiques

1. **Surveillance régulière**
   - Mettre en place des vérifications automatisées toutes les 5 minutes
   - Configurer des alertes pour les temps de réponse dépassant les seuils
   - Surveiller les tendances pour la dégradation des performances

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
