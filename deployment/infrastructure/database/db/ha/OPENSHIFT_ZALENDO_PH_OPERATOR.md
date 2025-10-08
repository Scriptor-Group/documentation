# Guide de Déploiement PostgreSQL Operator sur OpenShift

Ce guide détaille les étapes complètes pour déployer un cluster PostgreSQL en Haute Disponibilité (HA) sur OpenShift en utilisant le Zalando PostgreSQL Operator.

## Table des matières

1. [Prérequis](#prérequis)
2. [Installation du PostgreSQL Operator](#installation-du-postgresql-operator)
3. [Déploiement d'un cluster PostgreSQL HA](#déploiement-dun-cluster-postgresql-ha)
4. [Vérification et tests](#vérification-et-tests)
5. [Accès à la base de données](#accès-à-la-base-de-données)
6. [Configuration avancée](#configuration-avancée)
7. [Maintenance et opérations](#maintenance-et-opérations)
8. [Troubleshooting](#troubleshooting)

---

## Prérequis

### Accès et permissions

- Accès à un cluster OpenShift (version 4.x ou supérieure)
- CLI `oc` installé et configuré
- Permissions cluster-admin ou permissions suffisantes pour :
  - Créer des Custom Resource Definitions (CRD)
  - Créer des ClusterRoles et ClusterRoleBindings
  - Déployer des opérateurs
  - Créer des projets/namespaces

### Vérification de l'accès

```bash
# Vérifier la connexion au cluster
oc cluster-info

# Vérifier vos permissions
oc auth can-i create customresourcedefinitions
oc auth can-i create clusterroles
```

### Ressources requises

Par instance PostgreSQL :
- **CPU**: 1 core minimum (2 cores recommandés)
- **RAM**: 2 Gi minimum (4 Gi recommandés)
- **Storage**: Selon vos besoins (minimum 10 Gi recommandé)
- **PVC**: Support du ReadWriteOnce (RWO)

---

## Installation du PostgreSQL Operator

### Étape 1 : Créer un projet dédié (optionnel mais recommandé)

```bash
# Créer un nouveau projet pour l'opérateur
oc new-project postgres-operator

# Ou utiliser un projet existant
oc project postgres-operator
```

### Étape 2 : Cloner le repository (pour les manifests)

```bash
git clone https://github.com/zalando/postgres-operator.git
cd postgres-operator
```

### Étape 3 : Créer la ConfigMap avec la configuration OpenShift

**IMPORTANT pour OpenShift** : Il faut modifier la configuration pour activer `kubernetes_use_configmaps`.

Créer le fichier `openshift-configmap.yaml` :

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-operator
data:
  # Configuration spécifique OpenShift
  kubernetes_use_configmaps: "true"

  # Configuration générale
  docker_image: registry.opensource.zalan.do/acid/spilo-16:3.2-p3
  sidecar_docker_image: registry.opensource.zalan.do/acid/pgbouncer:master-32

  # Ressources par défaut
  min_cpu_limit: "250m"
  max_cpu_request: "1"
  min_memory_limit: "250Mi"
  max_memory_request: "1Gi"

  # Configuration des pods
  pod_management_policy: "ordered_ready"
  pod_terminate_grace_period: "5m"

  # Configuration du stockage
  enable_pod_antiaffinity: "true"
  pod_antiaffinity_preferred_during_scheduling: "false"

  # Monitoring
  enable_pod_disruption_budget: "true"

  # Configuration des workers
  workers: "8"
```

Appliquer la ConfigMap :

```bash
oc create -f openshift-configmap.yaml
```

### Étape 4 : Créer le RBAC spécifique OpenShift

```bash
# Utiliser le manifest RBAC spécifique pour OpenShift
oc create -f manifests/operator-service-account-rbac-openshift.yaml
```

**Note** : OpenShift nécessite des règles RBAC légèrement différentes de Kubernetes standard.

### Étape 5 : Déployer l'opérateur

```bash
# Déployer l'opérateur
oc create -f manifests/postgres-operator.yaml

# (Optionnel) Déployer l'API UI
oc create -f manifests/api-service.yaml
```

### Étape 6 : Vérifier le déploiement

```bash
# Vérifier que le pod de l'opérateur est en cours d'exécution
oc get pods -l name=postgres-operator

# Vérifier les logs
oc logs -l name=postgres-operator -f

# Vérifier la CRD
oc get crd postgresqls.acid.zalan.do
```

Le pod devrait être en état `Running` :
```
NAME                                READY   STATUS    RESTARTS   AGE
postgres-operator-xxxxxxxxxx-xxxxx  1/1     Running   0          30s
```

---

## Déploiement d'un cluster PostgreSQL HA

### Étape 1 : Créer un projet pour vos bases de données

```bash
# Créer un projet dédié pour vos bases PostgreSQL
oc new-project postgres-databases

# Ou utiliser un projet existant
oc project postgres-databases
```

### Étape 2 : Créer le manifest du cluster PostgreSQL

Créer le fichier `postgres-cluster-ha.yaml` :

```yaml
apiVersion: "acid.zalan.do/v1"
kind: postgresql
metadata:
  name: production-cluster
  namespace: postgres-databases
spec:
  # Identifiant de l'équipe
  teamId: "myteam"

  # Configuration HA : 3 instances pour production
  numberOfInstances: 3

  # Version PostgreSQL
  postgresql:
    version: "16"
    parameters:
      # Paramètres de performance
      shared_buffers: "256MB"
      max_connections: "100"
      work_mem: "8MB"
      # Paramètres de réplication
      max_wal_senders: "10"
      wal_keep_size: "1GB"

  # Configuration du volume
  volume:
    size: 20Gi
    storageClass: "standard"  # Ajuster selon votre StorageClass disponible

  # Utilisateurs et droits
  users:
    # Utilisateur admin avec superuser
    admin:
      - superuser
      - createdb

    # Utilisateur applicatif standard
    app_user:
      - login

  # Bases de données
  databases:
    app_db: admin

  # Ressources des pods
  resources:
    requests:
      cpu: "500m"
      memory: "1Gi"
    limits:
      cpu: "2"
      memory: "2Gi"

  # Anti-affinité pour distribuer les pods
  podAntiAffinity: true

  # Annotations pour le monitoring (optionnel)
  podAnnotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9187"

  # Tolérances pour les nodes dédiés (optionnel)
  # tolerations:
  # - key: "database"
  #   operator: "Equal"
  #   value: "postgresql"
  #   effect: "NoSchedule"
```

### Étape 3 : Déployer le cluster

```bash
# Appliquer le manifest
oc apply -f postgres-cluster-ha.yaml

# Vérifier la création du cluster
oc get postgresql

# Observer la création des pods
oc get pods -l cluster-name=production-cluster -w
```

### Étape 4 : Attendre que tous les pods soient prêts

Le déploiement peut prendre 2-5 minutes selon la configuration.

```bash
# Vérifier l'état du cluster
oc get postgresql production-cluster

# Tous les pods doivent être en Running
oc get pods -l cluster-name=production-cluster
```

Résultat attendu :
```
NAME                    READY   STATUS    RESTARTS   AGE
production-cluster-0    1/1     Running   0          3m
production-cluster-1    1/1     Running   0          2m30s
production-cluster-2    1/1     Running   0          2m
```

---

## Vérification et tests

### Vérifier les services créés

```bash
# Lister les services
oc get svc -l cluster-name=production-cluster
```

Vous devriez voir :
- `production-cluster` : Service principal (pointe vers le master)
- `production-cluster-repl` : Service pour les réplicas (lecture seule)
- `production-cluster-config` : Service headless pour la configuration

### Vérifier les secrets créés

```bash
# Lister les secrets des utilisateurs
oc get secrets -l cluster-name=production-cluster
```

### Vérifier les PVCs

```bash
# Vérifier les volumes persistants
oc get pvc -l cluster-name=production-cluster
```

### Tester la réplication

```bash
# Vérifier quel pod est le master
oc get pods -l cluster-name=production-cluster -L spilo-role

# Se connecter au master et vérifier la réplication
oc exec production-cluster-0 -- psql -U postgres -c "SELECT * FROM pg_stat_replication;"
```

---

## Accès à la base de données

### Récupérer les credentials

```bash
# Récupérer le mot de passe de l'utilisateur admin
export PGPASSWORD=$(oc get secret admin.production-cluster.credentials.postgresql.acid.zalan.do \
  -o jsonpath='{.data.password}' | base64 -d)

echo "Password: $PGPASSWORD"

# Récupérer le username
export PGUSER=$(oc get secret admin.production-cluster.credentials.postgresql.acid.zalan.do \
  -o jsonpath='{.data.username}' | base64 -d)

echo "Username: $PGUSER"
```

### Se connecter depuis un pod de test

```bash
# Lancer un pod PostgreSQL client
oc run psql-client --rm -it --restart=Never --image=postgres:16 -- bash

# Dans le pod, se connecter au master
psql -h production-cluster.postgres-databases.svc.cluster.local -U admin -d app_db

# Ou se connecter aux replicas (lecture seule)
psql -h production-cluster-repl.postgres-databases.svc.cluster.local -U admin -d app_db
```

### Créer une Route pour l'accès externe (optionnel)

**Attention** : Exposer PostgreSQL publiquement est déconseillé pour des raisons de sécurité.

```bash
# Créer une route (pour dev/test uniquement)
oc create route passthrough production-cluster-route \
  --service=production-cluster \
  --port=5432

# Récupérer l'URL
oc get route production-cluster-route
```

### Connection string pour les applications

```bash
# Pour le master (lecture/écriture)
postgresql://admin:PASSWORD@production-cluster.postgres-databases.svc.cluster.local:5432/app_db

# Pour les replicas (lecture seule)
postgresql://admin:PASSWORD@production-cluster-repl.postgres-databases.svc.cluster.local:5432/app_db
```

---

## Configuration avancée

### Backups automatiques avec WAL-E/WAL-G

Ajouter dans le manifest du cluster :

```yaml
spec:
  # ... autres configurations ...

  # Configuration des backups
  enableLogicalBackup: true
  logicalBackupSchedule: "30 2 * * *"  # Tous les jours à 2h30

  # Configuration de WAL-E pour AWS S3
  env:
    - name: WAL_S3_BUCKET
      value: "my-postgres-backups"
    - name: AWS_REGION
      value: "eu-west-1"
    - name: AWS_ACCESS_KEY_ID
      valueFrom:
        secretKeyRef:
          name: postgres-backup-credentials
          key: access-key
    - name: AWS_SECRET_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: postgres-backup-credentials
          key: secret-key
```

### Connection pooling avec PgBouncer

```yaml
spec:
  # ... autres configurations ...

  # Activer PgBouncer en sidecar
  enableConnectionPooler: true
  connectionPooler:
    numberOfInstances: 2
    mode: "transaction"
    schema: "pooler"
    user: "pooler"
    dockerImage: "registry.opensource.zalan.do/acid/pgbouncer:master-32"
    maxClientConnections: 1000
    defaultPoolSize: 25
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
      limits:
        cpu: "500m"
        memory: "256Mi"
```

### Monitoring avec Prometheus

```yaml
spec:
  # ... autres configurations ...

  # Ajouter le sidecar d'export pour Prometheus
  sidecars:
    - name: postgres-exporter
      image: "quay.io/prometheuscommunity/postgres-exporter:latest"
      ports:
        - containerPort: 9187
          name: metrics
      env:
        - name: DATA_SOURCE_NAME
          value: "postgresql://postgres@localhost:5432/postgres?sslmode=disable"
```

### Mise à l'échelle automatique (lecture)

Pour ajouter plus de réplicas :

```bash
# Éditer le cluster
oc edit postgresql production-cluster

# Modifier numberOfInstances
spec:
  numberOfInstances: 5  # Augmenter le nombre

# Ou via patch
oc patch postgresql production-cluster --type='merge' -p '{"spec":{"numberOfInstances":5}}'
```

---

## Maintenance et opérations

### Rotation des mots de passe

```bash
# L'opérateur gère automatiquement la rotation
# Forcer une rotation manuelle en ajoutant une annotation
oc annotate postgresql production-cluster \
  "acid.zalan.do/password-rotation"="$(date +%s)"
```

### Upgrade de version PostgreSQL

```bash
# Éditer le cluster
oc edit postgresql production-cluster

# Modifier la version
spec:
  postgresql:
    version: "17"  # Nouvelle version

# L'opérateur effectuera un rolling upgrade
oc get pods -l cluster-name=production-cluster -w
```

### Changement de taille de volume

```bash
# Patch le cluster avec une nouvelle taille
oc patch postgresql production-cluster --type='merge' \
  -p '{"spec":{"volume":{"size":"50Gi"}}}'

# Vérifier les PVCs
oc get pvc -l cluster-name=production-cluster
```

### Backup manuel

```bash
# Se connecter au master
oc exec production-cluster-0 -- su postgres -c \
  "pg_dump -Fc app_db > /home/postgres/backup_$(date +%Y%m%d).dump"

# Copier le backup localement
oc cp production-cluster-0:/home/postgres/backup_*.dump ./backup.dump
```

### Restauration

```bash
# Copier le backup dans le pod
oc cp ./backup.dump production-cluster-0:/tmp/backup.dump

# Restaurer
oc exec production-cluster-0 -- su postgres -c \
  "pg_restore -d app_db /tmp/backup.dump"
```

---

## Troubleshooting

### Le pod de l'opérateur ne démarre pas

```bash
# Vérifier les logs
oc logs -l name=postgres-operator --tail=100

# Vérifier les events
oc get events --sort-by='.lastTimestamp'

# Vérifier les SecurityContextConstraints
oc get scc
```

### Les pods PostgreSQL restent en Pending

```bash
# Vérifier les PVCs
oc get pvc -l cluster-name=production-cluster

# Vérifier les ressources disponibles
oc describe nodes | grep -A 5 "Allocated resources"

# Vérifier les events du pod
oc describe pod production-cluster-0
```

### Problèmes de réplication

```bash
# Se connecter au master
oc exec production-cluster-0 -- psql -U postgres -c \
  "SELECT * FROM pg_stat_replication;"

# Vérifier les logs du pod replica
oc logs production-cluster-1 --tail=50

# Vérifier la configuration
oc exec production-cluster-1 -- cat /home/postgres/pgdata/pgroot/data/postgresql.conf | grep -i replication
```

### Le cluster ne se crée pas

```bash
# Vérifier l'état du custom resource
oc describe postgresql production-cluster

# Vérifier les logs de l'opérateur
oc logs -l name=postgres-operator -f

# Vérifier que l'opérateur surveille le bon namespace
oc get configmap postgres-operator -o yaml | grep watched_namespace
```

### Erreur "no space left on device"

```bash
# Vérifier l'utilisation du disque
oc exec production-cluster-0 -- df -h

# Augmenter la taille du volume (voir section Maintenance)
# Nettoyer les WAL anciens
oc exec production-cluster-0 -- su postgres -c \
  "psql -c \"SELECT pg_switch_wal(); SELECT pg_switch_wal();\""
```

### Performance dégradée

```bash
# Vérifier les connexions actives
oc exec production-cluster-0 -- psql -U postgres -c \
  "SELECT count(*) FROM pg_stat_activity;"

# Vérifier les requêtes lentes
oc exec production-cluster-0 -- psql -U postgres -c \
  "SELECT pid, now() - query_start as duration, query FROM pg_stat_activity WHERE state = 'active' AND now() - query_start > interval '1 minute';"

# Analyser les locks
oc exec production-cluster-0 -- psql -U postgres -c \
  "SELECT * FROM pg_locks WHERE NOT granted;"
```

---

## Commandes utiles de référence

```bash
# Lister tous les clusters PostgreSQL
oc get postgresql --all-namespaces

# Voir les détails d'un cluster
oc describe postgresql production-cluster

# Voir les logs d'un pod PostgreSQL
oc logs production-cluster-0 -c postgres

# Se connecter en bash à un pod
oc exec -it production-cluster-0 -- bash

# Lister les bases de données
oc exec production-cluster-0 -- psql -U postgres -c "\l"

# Lister les utilisateurs
oc exec production-cluster-0 -- psql -U postgres -c "\du"

# Voir la taille des bases
oc exec production-cluster-0 -- psql -U postgres -c \
  "SELECT pg_database.datname, pg_size_pretty(pg_database_size(pg_database.datname)) AS size FROM pg_database;"

# Redémarrer un pod (rolling restart)
oc delete pod production-cluster-0
# L'opérateur le recréera automatiquement

# Supprimer un cluster (ATTENTION : destructif)
oc delete postgresql production-cluster
```

---

## Ressources additionnelles

- [Documentation officielle Zalando PostgreSQL Operator](https://github.com/zalando/postgres-operator/tree/master/docs)
- [Spilo - PostgreSQL Docker image utilisé](https://github.com/zalando/spilo)
- [Configuration Reference](https://github.com/zalando/postgres-operator/blob/master/docs/reference/operator_parameters.md)
- [OpenShift Documentation](https://docs.openshift.com/)

---

## Support et contribution

Pour toute question ou problème :
1. Vérifier les logs de l'opérateur
2. Consulter la documentation officielle
3. Ouvrir un issue sur le [GitHub du projet](https://github.com/zalando/postgres-operator/issues)

---

**Version du document** : 1.0
**Dernière mise à jour** : 2025-01-08
**Testé avec** : OpenShift 4.x, PostgreSQL Operator v1.11.x
