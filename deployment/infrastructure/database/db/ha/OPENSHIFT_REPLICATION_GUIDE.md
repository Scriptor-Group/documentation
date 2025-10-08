# Guide de déploiement PostgreSQL Master/Slave sur OpenShift

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Prérequis](#prérequis)
3. [Phase 1 : Préparation du Master existant](#phase-1--préparation-du-master-existant)
4. [Phase 2 : Déploiement du Slave](#phase-2--déploiement-du-slave)
5. [Phase 3 : Configuration de la réplication](#phase-3--configuration-de-la-réplication)
6. [Phase 4 : Tests et validation](#phase-4--tests-et-validation)
7. [Monitoring et maintenance](#monitoring-et-maintenance)
8. [Procédure de rollback](#procédure-de-rollback)

---

## Vue d'ensemble

Ce guide décrit comment ajouter un serveur PostgreSQL slave (réplique) à un serveur master existant dans un environnement OpenShift.

**Architecture cible :**

```
┌─────────────────────────┐
│  Service Master (RW)    │ ← Applications (lecture/écriture)
│  postgresql-master      │
└────────────┬────────────┘
             │
    ┌────────▼────────┐
    │  Pod Master     │
    │  postgresql-0   │
    └────────┬────────┘
             │ Streaming Replication
             │
    ┌────────▼────────┐
    │  Pod Slave      │
    │  postgresql-1   │
    └────────┬────────┘
             │
┌────────────▼────────────┐
│  Service Slave (RO)     │ ← Applications (lecture seule)
│  postgresql-slave       │
└─────────────────────────┘
```

**Principes clés :**

- Réplication streaming asynchrone PostgreSQL
- Master : lecture/écriture (RW)
- Slave : lecture seule (RO)
- Utilisation de slots de réplication pour garantir la cohérence
- Pas de failover automatique (configuration manuelle nécessaire)

---

## Prérequis

### Accès et permissions

- Accès OpenShift CLI (`oc`) ou web console
- Permissions `edit` ou `admin` dans le namespace cible
- Accès au pod PostgreSQL master existant

### Commandes de reconnaissance

Identifier les ressources PostgreSQL existantes :

```bash
oc project <nom-du-projet>
oc get all | grep postgres
oc get pvc | grep postgres
oc get configmap | grep postgres
oc get secret | grep postgres
```

Vérifier la version PostgreSQL du master :

```bash
POD_NAME=$(oc get pods -l name=postgresql -o jsonpath='{.items[0].metadata.name}')
oc exec $POD_NAME -- psql --version
```

### Versions compatibles

- OpenShift 4.x ou supérieur
- PostgreSQL 12, 13, 14 ou 15

---

## Phase 1 : Préparation du Master existant

### Étape 1.1 : Backup de sécurité

**⚠️ CRITIQUE : Effectuer un backup complet avant toute modification**

```bash
# Sauvegarder les ressources OpenShift
oc get dc/postgresql -o yaml > backup-postgresql-dc.yaml
oc get svc/postgresql -o yaml > backup-postgresql-svc.yaml
oc get pvc/postgresql -o yaml > backup-postgresql-pvc.yaml
oc get configmap -o yaml > backup-configmaps.yaml
oc get secret -o yaml > backup-secrets.yaml

# Backup de la base de données
oc exec $POD_NAME -- pg_dumpall -U postgres > backup-database.sql
```

---

### Étape 1.2 : Secret pour la réplication

**Resource : `postgresql-replication-secret.yaml`**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgresql-replication
type: Opaque
stringData:
  replication-user: replicator
  replication-password: <GÉNÉRER_MOT_DE_PASSE_FORT>
```

Appliquer :

```bash
oc apply -f postgresql-replication-secret.yaml
```

---

### Étape 1.3 : ConfigMap Master - Configuration PostgreSQL

**Resource : `postgresql-master-config.yaml`**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgresql-master-config
data:
  master.conf: |
    # Configuration Master PostgreSQL
    listen_addresses = '*'
    max_connections = 100
    shared_buffers = 256MB

    # ===== Configuration WAL pour Réplication =====
    wal_level = replica                    # Active la réplication
    max_wal_senders = 10                   # Nombre max de connexions de réplication
    max_replication_slots = 10             # Nombre max de slots
    wal_keep_size = 1GB                    # Rétention des WAL (ajuster selon le besoin)
    hot_standby = on                       # Permet les lectures sur le slave

    # ===== Archivage WAL (optionnel mais recommandé) =====
    archive_mode = on
    archive_command = 'test ! -f /var/lib/postgresql/archive/%f && cp %p /var/lib/postgresql/archive/%f'

    # ===== Logging =====
    log_destination = 'stderr'
    logging_collector = on
    log_directory = 'log'
    log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
    log_statement = 'mod'
    log_replication_commands = on
    log_connections = on
    log_disconnections = on

  pg_hba.conf: |
    # TYPE  DATABASE        USER            ADDRESS                 METHOD
    local   all             all                                     trust
    host    all             all             127.0.0.1/32            md5
    host    all             all             ::1/128                 md5

    # Connexions depuis les pods OpenShift (ajuster le CIDR selon votre cluster)
    host    all             all             10.128.0.0/14           md5

    # ===== Configuration Réplication =====
    host    replication     replicator      10.128.0.0/14           md5
    host    replication     replicator      127.0.0.1/32            md5
```

**Points d'attention :**

- **CIDR réseau** : `10.128.0.0/14` est le réseau par défaut OpenShift. À ajuster selon votre configuration réseau.
- **wal_keep_size** : Détermine combien de WAL sont conservés. Augmenter si le slave peut être déconnecté longtemps.
- **shared_buffers** : À ajuster selon les ressources disponibles (généralement 25% de la RAM).

Appliquer :

```bash
oc apply -f postgresql-master-config.yaml
```

---

### Étape 1.4 : ConfigMap Master - Script d'initialisation

**Resource : `postgresql-master-init.yaml`**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgresql-master-init
data:
  init-master.sh: |
    #!/bin/bash
    set -e

    echo "Initialisation du master pour la réplication..."

    # Vérifier si déjà initialisé
    if psql -U postgres -d postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='replicator'" | grep -q 1; then
        echo "Utilisateur de réplication déjà existant"
    else
        # Créer l'utilisateur de réplication
        psql -U postgres <<-EOSQL
            CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD '${REPLICATION_PASSWORD}';
            SELECT pg_create_physical_replication_slot('replication_slot_slave');
        EOSQL
        echo "Utilisateur de réplication créé avec succès"
    fi
```

**Ce script :**

- Crée l'utilisateur `replicator` avec le privilège `REPLICATION`
- Crée un slot de réplication physique nommé `replication_slot_slave`
- Est idempotent (peut être exécuté plusieurs fois)

Appliquer :

```bash
oc apply -f postgresql-master-init.yaml
```

---

### Étape 1.5 : Modification du DeploymentConfig Master

**⚠️ ATTENTION : Redémarrage du pod master requis (interruption de service ~2-5 minutes)**

Récupérer le DeploymentConfig actuel :

```bash
oc get dc/postgresql -o yaml > postgresql-master-updated.yaml
```

**Modifications à appliquer dans `spec.template.spec` :**

#### 1. Ajouter les volumes

```yaml
spec:
  template:
    spec:
      volumes:
        # ... volumes existants ...
        - name: master-config
          configMap:
            name: postgresql-master-config
        - name: master-init
          configMap:
            name: postgresql-master-init
            defaultMode: 0755
        - name: archive
          emptyDir: {}
```

#### 2. Ajouter les volumeMounts au conteneur

```yaml
containers:
  - name: postgresql
    volumeMounts:
      # ... volumeMounts existants ...
      - name: master-config
        mountPath: /etc/postgresql/master.conf
        subPath: master.conf
      - name: master-config
        mountPath: /etc/postgresql/pg_hba.conf
        subPath: pg_hba.conf
      - name: master-init
        mountPath: /docker-entrypoint-initdb.d/init-master.sh
        subPath: init-master.sh
      - name: archive
        mountPath: /var/lib/postgresql/archive
```

#### 3. Ajouter les variables d'environnement

```yaml
env:
  # ... env existantes ...
  - name: REPLICATION_PASSWORD
    valueFrom:
      secretKeyRef:
        name: postgresql-replication
        key: replication-password
  - name: POSTGRESQL_ADMIN_PASSWORD
    valueFrom:
      secretKeyRef:
        name: postgresql # Adapter au nom du secret existant
        key: database-password
```

#### 4. Modifier les arguments de démarrage

```yaml
args:
  - "-c"
  - "config_file=/etc/postgresql/master.conf"
  - "-c"
  - "hba_file=/etc/postgresql/pg_hba.conf"
```

**Application des modifications :**

```bash
# Validation syntaxe
oc apply -f postgresql-master-updated.yaml --dry-run=client

# Application (⚠️ redémarrage du pod)
oc apply -f postgresql-master-updated.yaml

# Surveillance
oc get pods -w
```

---

### Étape 1.6 : Vérification de la configuration Master

Attendre que le pod soit prêt :

```bash
oc wait --for=condition=ready pod -l name=postgresql --timeout=300s
POD_NAME=$(oc get pods -l name=postgresql -o jsonpath='{.items[0].metadata.name}')
```

**Vérifications obligatoires :**

1. **Utilisateur de réplication :**

```bash
oc exec $POD_NAME -- psql -U postgres -c "SELECT rolname, rolreplication FROM pg_roles WHERE rolname='replicator';"
```

Résultat attendu : `replicator | t`

2. **Slot de réplication :**

```bash
oc exec $POD_NAME -- psql -U postgres -c "SELECT * FROM pg_replication_slots;"
```

Résultat attendu : `replication_slot_slave | physical | f`

3. **Paramètres WAL :**

```bash
oc exec $POD_NAME -- psql -U postgres -c "SHOW wal_level; SHOW max_wal_senders; SHOW wal_keep_size;"
```

Résultat attendu : `replica`, `10`, `1GB`

---

## Phase 2 : Déploiement du Slave

### Étape 2.1 : PersistentVolumeClaim Slave

**Resource : `postgresql-slave-pvc.yaml`**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgresql-slave
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi # Ajuster à la taille du master ou plus
  storageClassName: standard # Ajuster selon votre storage class
```

**Points d'attention :**

- Taille >= taille du PVC master
- Storage class avec performance similaire ou meilleure que le master

Appliquer :

```bash
oc apply -f postgresql-slave-pvc.yaml
```

---

### Étape 2.2 : ConfigMap Slave

**Resource : `postgresql-slave-config.yaml`**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgresql-slave-config
data:
  slave.conf: |
    # Configuration Slave PostgreSQL
    listen_addresses = '*'
    max_connections = 100
    shared_buffers = 256MB

    # ===== Configuration Réplication =====
    wal_level = replica
    hot_standby = on                       # CRITIQUE : permet les lectures
    max_wal_senders = 10
    max_replication_slots = 10

    # ===== Logging =====
    log_destination = 'stderr'
    logging_collector = on
    log_directory = 'log'
    log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
    log_statement = 'mod'
    log_connections = on
    log_disconnections = on

  setup-slave.sh: |
    #!/bin/bash
    set -e

    echo "Configuration du slave PostgreSQL..."

    # Attendre que le master soit disponible
    echo "Attente du master sur ${MASTER_SERVICE}..."
    until PGPASSWORD=${POSTGRESQL_ADMIN_PASSWORD} psql -h ${MASTER_SERVICE} -U postgres -c '\q' 2>/dev/null; do
      echo "Master non disponible, nouvelle tentative dans 5s..."
      sleep 5
    done

    echo "Master disponible, démarrage de la configuration du slave..."

    # Vérifier si déjà initialisé
    if [ -f "${PGDATA}/PG_VERSION" ]; then
        echo "Data directory déjà initialisé, démarrage en mode standby..."
        exit 0
    fi

    # Créer la copie depuis le master avec pg_basebackup
    echo "Création du backup depuis le master..."
    PGPASSWORD=${REPLICATION_PASSWORD} pg_basebackup \
        -h ${MASTER_SERVICE} \
        -D ${PGDATA} \
        -U replicator \
        -v -P -W -R \
        -X stream \
        -S replication_slot_slave

    # Créer standby.signal (mode hot standby)
    touch "${PGDATA}/standby.signal"

    # Fixer les permissions
    chmod 700 ${PGDATA}

    echo "Configuration du slave terminée avec succès"
```

**Détails pg_basebackup :**

- `-h` : hôte du master
- `-D` : répertoire de destination
- `-U` : utilisateur de réplication
- `-v -P` : verbose et progression
- `-W` : demander le mot de passe
- `-R` : créer automatiquement la configuration de réplication
- `-X stream` : inclure les WAL nécessaires
- `-S` : utiliser le slot de réplication

Appliquer :

```bash
oc apply -f postgresql-slave-config.yaml
```

---

### Étape 2.3 : Deployment Slave

**Resource : `postgresql-slave-deployment.yaml`**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgresql-slave
  labels:
    app: postgresql
    role: slave
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgresql
      role: slave
  template:
    metadata:
      labels:
        app: postgresql
        role: slave
    spec:
      # ===== Init Container : Configuration initiale du slave =====
      initContainers:
        - name: setup-slave
          image: postgres:15 # ⚠️ MÊME VERSION QUE LE MASTER
          command: ["/bin/bash", "/scripts/setup-slave.sh"]
          env:
            - name: PGDATA
              value: /var/lib/postgresql/data
            - name: MASTER_SERVICE
              value: postgresql # Nom du service du master
            - name: POSTGRESQL_ADMIN_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgresql # Adapter
                  key: database-password
            - name: REPLICATION_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgresql-replication
                  key: replication-password
          volumeMounts:
            - name: postgresql-data
              mountPath: /var/lib/postgresql/data
            - name: slave-config
              mountPath: /scripts

      # ===== Conteneur principal =====
      containers:
        - name: postgresql
          image: postgres:15 # ⚠️ MÊME VERSION QUE LE MASTER
          args:
            - "-c"
            - "config_file=/etc/postgresql/slave.conf"
          ports:
            - containerPort: 5432
              protocol: TCP
          env:
            - name: PGDATA
              value: /var/lib/postgresql/data
            - name: POSTGRES_USER
              value: postgres
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgresql
                  key: database-password
          volumeMounts:
            - name: postgresql-data
              mountPath: /var/lib/postgresql/data
            - name: slave-config
              mountPath: /etc/postgresql/slave.conf
              subPath: slave.conf

          # ===== Probes =====
          livenessProbe:
            exec:
              command:
                - /bin/sh
                - -c
                - pg_isready -U postgres
            initialDelaySeconds: 30
            timeoutSeconds: 5
            periodSeconds: 10
          readinessProbe:
            exec:
              command:
                - /bin/sh
                - -c
                - pg_isready -U postgres
            initialDelaySeconds: 10
            timeoutSeconds: 5
            periodSeconds: 5

          # ===== Ressources =====
          resources:
            requests:
              memory: "512Mi"
              cpu: "250m"
            limits:
              memory: "2Gi"
              cpu: "1000m"

      volumes:
        - name: postgresql-data
          persistentVolumeClaim:
            claimName: postgresql-slave
        - name: slave-config
          configMap:
            name: postgresql-slave-config
            defaultMode: 0755
```

**Points d'attention :**

- **Image** : Utiliser EXACTEMENT la même version que le master
- **MASTER_SERVICE** : Doit correspondre au nom du service du master
- **Ressources** : Ajuster selon les besoins

Appliquer :

```bash
oc apply -f postgresql-slave-deployment.yaml
```

---

### Étape 2.4 : Service Slave

**Resource : `postgresql-slave-service.yaml`**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgresql-slave
  labels:
    app: postgresql
    role: slave
spec:
  ports:
    - name: postgresql
      port: 5432
      targetPort: 5432
  selector:
    app: postgresql
    role: slave
  type: ClusterIP
```

Appliquer :

```bash
oc apply -f postgresql-slave-service.yaml
```

---

### Étape 2.5 : Surveillance du déploiement

```bash
# Surveiller les pods
oc get pods -l role=slave -w

# Logs de l'init container
SLAVE_POD=$(oc get pods -l role=slave -o jsonpath='{.items[0].metadata.name}')
oc logs $SLAVE_POD -c setup-slave -f

# Logs du conteneur principal
oc logs $SLAVE_POD -c postgresql -f
```

**Durée estimée** : 5-15 minutes selon la taille de la base de données.

---

## Phase 3 : Configuration de la réplication

### Étape 3.1 : Vérification de la connexion de réplication

```bash
MASTER_POD=$(oc get pods -l name=postgresql -o jsonpath='{.items[0].metadata.name}')

oc exec $MASTER_POD -- psql -U postgres -c "
SELECT
    pid,
    usename,
    application_name,
    client_addr,
    state,
    sync_state,
    sent_lsn,
    write_lsn,
    flush_lsn,
    replay_lsn
FROM pg_stat_replication;
"
```

**Résultat attendu :**

```
 pid | usename    | application_name | client_addr | state     | sync_state
-----+------------+------------------+-------------+-----------+------------
 123 | replicator | walreceiver      | 10.128.x.x  | streaming | async
```

**Vérification des colonnes :**

- `state = streaming` : réplication active
- `sync_state = async` : mode asynchrone (normal)
- `sent_lsn = replay_lsn` : pas de lag

---

### Étape 3.2 : Vérification du slot de réplication

```bash
oc exec $MASTER_POD -- psql -U postgres -c "
SELECT
    slot_name,
    slot_type,
    active,
    restart_lsn
FROM pg_replication_slots;
"
```

**Résultat attendu :**

```
      slot_name       | slot_type | active | restart_lsn
----------------------+-----------+--------+-------------
 replication_slot_slave | physical  | t      | 0/3000000
```

**Vérifications :**

- `active = t` : le slot est utilisé
- `restart_lsn` : position de départ

---

### Étape 3.3 : Mesure du lag de réplication

```bash
oc exec $MASTER_POD -- psql -U postgres -c "
SELECT
    client_addr,
    state,
    (pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn) / 1024 / 1024)::INT AS lag_mb,
    (EXTRACT(EPOCH FROM (now() - replay_time)))::INT AS lag_seconds
FROM pg_stat_replication;
"
```

**Valeurs acceptables :**

- `lag_mb < 10` : excellent
- `lag_seconds < 5` : excellent

---

## Phase 4 : Tests et validation

### Test 1 : Réplication des données

Créer des données sur le master :

```bash
oc exec $MASTER_POD -- psql -U postgres <<EOF
CREATE TABLE IF NOT EXISTS test_replication (
    id SERIAL PRIMARY KEY,
    message TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO test_replication (message)
VALUES ('Test 1'), ('Test 2'), ('Test 3');
EOF
```

Vérifier sur le slave :

```bash
SLAVE_POD=$(oc get pods -l role=slave -o jsonpath='{.items[0].metadata.name}')
oc exec $SLAVE_POD -- psql -U postgres -c "SELECT * FROM test_replication;"
```

✅ **Attendu** : Les 3 lignes apparaissent sur le slave.

---

### Test 2 : Lecture seule sur le slave

```bash
oc exec $SLAVE_POD -- psql -U postgres -c "
INSERT INTO test_replication (message) VALUES ('Should fail');
"
```

✅ **Attendu** : Erreur `cannot execute INSERT in a read-only transaction`

---

### Test 3 : Performance de réplication

Générer une charge :

```bash
oc exec $MASTER_POD -- psql -U postgres <<EOF
INSERT INTO test_replication (message)
SELECT 'Test ' || generate_series(1, 10000);
EOF
```

Vérifier immédiatement sur le slave :

```bash
oc exec $SLAVE_POD -- psql -U postgres -c "SELECT COUNT(*) FROM test_replication;"
```

✅ **Attendu** : Les 10000 lignes sont répliquées en < 5 secondes.

---

### Test 4 : Connexion depuis une application

Créer un pod de test :

```bash
oc run postgresql-test --image=postgres:15 --rm -it --restart=Never -- bash
```

Depuis le pod de test :

```bash
# Connexion master (RW)
psql -h postgresql -U postgres -d postgres

# Connexion slave (RO)
psql -h postgresql-slave -U postgres -d postgres
```

---

## Monitoring et maintenance

### Queries de monitoring

**Resource : `postgresql-monitoring-queries.yaml`**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgresql-monitoring-queries
data:
  replication-status.sql: |
    SELECT
        client_addr,
        state,
        sync_state,
        (pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn) / 1024 / 1024)::INT AS lag_mb,
        (EXTRACT(EPOCH FROM (now() - replay_time)))::INT AS lag_seconds
    FROM pg_stat_replication;

  database-size.sql: |
    SELECT
        pg_database.datname,
        pg_size_pretty(pg_database_size(pg_database.datname)) AS size
    FROM pg_database
    ORDER BY pg_database_size(pg_database.datname) DESC;

  connection-count.sql: |
    SELECT
        count(*) as total_connections,
        sum(case when state = 'active' then 1 else 0 end) as active_connections,
        sum(case when state = 'idle' then 1 else 0 end) as idle_connections
    FROM pg_stat_activity;

  replication-slots.sql: |
    SELECT
        slot_name,
        slot_type,
        active,
        pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)) AS retained_wal
    FROM pg_replication_slots;
```

Utilisation :

```bash
oc exec $MASTER_POD -- psql -U postgres -f /path/to/replication-status.sql
```

---

### Alertes Prometheus

**Resource : `postgresql-replication-alerts.yaml`**

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: postgresql-replication-alerts
spec:
  groups:
    - name: postgresql-replication
      interval: 30s
      rules:
        - alert: PostgreSQLReplicationLagHigh
          expr: pg_replication_lag_seconds > 30
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "PostgreSQL replication lag is high"
            description: "Replication lag is {{ $value }} seconds on {{ $labels.instance }}"

        - alert: PostgreSQLReplicationBroken
          expr: pg_replication_connected == 0
          for: 1m
          labels:
            severity: critical
          annotations:
            summary: "PostgreSQL replication is broken"
            description: "No replica is connected to the master"

        - alert: PostgreSQLReplicationSlotInactive
          expr: pg_replication_slot_active == 0
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "PostgreSQL replication slot is inactive"
            description: "Replication slot {{ $labels.slot_name }} is not active"
```

---

### CronJob de monitoring

**Resource : `postgresql-monitoring-cronjob.yaml`**

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: postgresql-replication-check
spec:
  schedule: "*/15 * * * *" # Toutes les 15 minutes
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: postgresql-monitor
          containers:
            - name: check
              image: postgres:15
              command:
                - /bin/bash
                - -c
                - |
                  MASTER_POD=$(kubectl get pods -l name=postgresql -o jsonpath='{.items[0].metadata.name}')

                  echo "Checking replication status..."
                  kubectl exec $MASTER_POD -- psql -U postgres -t -c "
                  SELECT
                      CASE
                          WHEN count(*) = 0 THEN 'ERROR: No replication connection'
                          WHEN max((pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn) / 1024 / 1024)::INT) > 100 THEN 'WARNING: Lag > 100MB'
                          WHEN max(EXTRACT(EPOCH FROM (now() - replay_time))::INT) > 60 THEN 'WARNING: Lag > 60 seconds'
                          ELSE 'OK: Replication healthy'
                      END as status
                  FROM pg_stat_replication;
                  "
          restartPolicy: OnFailure
```

**Pré-requis** : Créer le ServiceAccount avec les permissions nécessaires.

---

## Procédure de rollback

### Rollback du Slave

Si le slave pose problème, il peut être supprimé sans impact sur le master :

```bash
# Supprimer les ressources
oc delete deployment postgresql-slave
oc delete service postgresql-slave
oc delete pvc postgresql-slave

# Nettoyer le slot de réplication sur le master
MASTER_POD=$(oc get pods -l name=postgresql -o jsonpath='{.items[0].metadata.name}')
oc exec $MASTER_POD -- psql -U postgres -c "
SELECT pg_drop_replication_slot('replication_slot_slave');
"
```

---

### Rollback du Master

En cas de problème après modification du master :

```bash
# Restaurer la configuration d'origine
oc apply -f backup-postgresql-dc.yaml

# Surveiller le rollout
oc rollout status dc/postgresql

# Vérifier l'état
oc get pods -l name=postgresql
```

**⚠️ Attention** : Les ConfigMaps créées resteront présentes mais ne seront plus utilisées.

---

## Troubleshooting

### Problème : Le slave ne démarre pas

**Symptômes :**

- Pod en `CrashLoopBackOff`
- Init container échoue

**Diagnostic :**

```bash
oc logs $SLAVE_POD -c setup-slave
oc logs $SLAVE_POD -c postgresql
oc describe pod $SLAVE_POD
```

**Solutions courantes :**

1. **Master inaccessible :**

```bash
oc exec $SLAVE_POD -- ping postgresql
```

2. **Permissions secret :**

```bash
oc get secret postgresql-replication -o yaml
```

3. **Slot de réplication inexistant :**

```bash
oc exec $MASTER_POD -- psql -U postgres -c "SELECT * FROM pg_replication_slots;"
```

4. **Recréer depuis zéro :**

```bash
oc delete pod $SLAVE_POD
oc delete pvc postgresql-slave
oc apply -f postgresql-slave-pvc.yaml
```

---

### Problème : Lag de réplication élevé

**Symptômes :**

- `lag_mb > 100` MB
- `lag_seconds > 30` secondes

**Diagnostic :**

```bash
# Ressources du slave
oc describe pod $SLAVE_POD
oc top pod $SLAVE_POD

# Charge du master
oc top pod $MASTER_POD
```

**Solutions :**

1. **Augmenter les ressources du slave :**

```bash
oc edit deployment postgresql-slave
# Augmenter memory et cpu
```

2. **Vérifier la performance réseau :**

```bash
oc exec $MASTER_POD -- ping $SLAVE_POD_IP
```

3. **Vérifier les I/O disque :**

```bash
oc exec $SLAVE_POD -- iostat -x 1
```

---

### Problème : Slot de réplication sature le disque

**Symptômes :**

- Espace disque faible sur le master
- `retained_wal` très élevé

**Diagnostic :**

```bash
oc exec $MASTER_POD -- psql -U postgres -c "
SELECT
    slot_name,
    active,
    pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)) AS retained_wal
FROM pg_replication_slots;
"
```

**Solutions :**

1. **Si le slave est actif mais lent :** voir section lag

2. **Si le slave est perdu (inactive) :**

```bash
# Supprimer le slot
oc exec $MASTER_POD -- psql -U postgres -c "
SELECT pg_drop_replication_slot('replication_slot_slave');
"

# Recréer le slave depuis zéro
```

---

## Checklist de déploiement

### Avant le déploiement

- [ ] Backup complet de la base de données (`pg_dumpall`)
- [ ] Backup de toutes les configurations OpenShift
- [ ] Vérification de l'espace disque disponible (master et storage class)
- [ ] Planification de la fenêtre de maintenance (2-5 min)
- [ ] Communication aux utilisateurs
- [ ] Vérification du réseau OpenShift (CIDR)

### Pendant le déploiement

- [ ] Phase 1 : Secret réplication créé
- [ ] Phase 1 : ConfigMaps master créées
- [ ] Phase 1 : DeploymentConfig master modifié
- [ ] Phase 1 : Pod master redémarré avec succès
- [ ] Phase 1 : Utilisateur `replicator` créé
- [ ] Phase 1 : Slot `replication_slot_slave` créé
- [ ] Phase 2 : PVC slave créé
- [ ] Phase 2 : ConfigMap slave créée
- [ ] Phase 2 : Deployment slave déployé
- [ ] Phase 2 : Service slave créé
- [ ] Phase 3 : État réplication = `streaming`
- [ ] Phase 3 : Lag < 10MB et < 5s
- [ ] Phase 4 : Test réplication OK
- [ ] Phase 4 : Test lecture seule OK

### Après le déploiement

- [ ] Monitoring queries déployées
- [ ] Alertes Prometheus configurées
- [ ] CronJob monitoring créé
- [ ] Documentation mise à jour
- [ ] Formation de l'équipe
- [ ] Test de connexion applications

---

## Configuration des applications pour utiliser le slave

### Stratégie de répartition lecture/écriture

**Principe :** Diriger les lectures seules vers le slave, les écritures vers le master.

**Configuration des variables d'environnement :**

```bash
# Pour une application déployée
oc set env deployment/mon-application \
  DATABASE_URL_WRITE="postgresql://user:pass@postgresql:5432/dbname" \
  DATABASE_URL_READ="postgresql://user:pass@postgresql-slave:5432/dbname"
```

**Exemple de configuration applicative (Node.js / TypeORM) :**

```javascript
{
  type: 'postgres',
  replication: {
    master: {
      host: 'postgresql',
      port: 5432,
      username: 'user',
      password: 'pass',
      database: 'dbname'
    },
    slaves: [{
      host: 'postgresql-slave',
      port: 5432,
      username: 'user',
      password: 'pass',
      database: 'dbname'
    }]
  }
}
```

---

## Concepts clés PostgreSQL

### WAL (Write-Ahead Log)

- Journal des modifications avant écriture sur disque
- Base de la réplication streaming
- Configuré via `wal_level = replica`

### Replication Slot

- Garantit que le master conserve les WAL nécessaires
- Évite la perte de données si le slave est déconnecté
- ⚠️ Peut saturer le disque si le slave est perdu

### Hot Standby

- Mode lecture seule sur le slave
- Activé via `hot_standby = on`
- Permet de décharger le master des lectures

### Streaming Replication

- Réplication en temps réel des WAL
- Mode asynchrone par défaut (pas de garantie de durabilité)
- Mode synchrone possible (impact performance)

---

## Support

### Commandes de diagnostic

```bash
# Logs
oc logs <pod-name>
oc logs <pod-name> -c <container-name>

# Events
oc get events --sort-by='.lastTimestamp' | grep postgres

# Describe
oc describe pod <pod-name>
oc describe pvc <pvc-name>

# État des ressources
oc get all -l app=postgresql
oc top pod -l app=postgresql
```

### Documentation PostgreSQL

- [Streaming Replication](https://www.postgresql.org/docs/current/warm-standby.html)
- [pg_basebackup](https://www.postgresql.org/docs/current/app-pgbasebackup.html)
- [Replication Slots](https://www.postgresql.org/docs/current/warm-standby.html#STREAMING-REPLICATION-SLOTS)
