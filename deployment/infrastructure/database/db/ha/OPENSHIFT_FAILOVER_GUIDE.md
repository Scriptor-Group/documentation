# Guide de Failover PostgreSQL sur OpenShift

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Failover manuel](#failover-manuel)
3. [Failover automatique avec Patroni](#failover-automatique-avec-patroni)
4. [Tests de failover](#tests-de-failover)
5. [Retour à la normale](#retour-à-la-normale)
6. [Troubleshooting](#troubleshooting)

---

## Vue d'ensemble

Le failover est le processus de promotion d'un serveur slave en master lorsque le master actuel devient indisponible.

### Types de failover

**Failover manuel :**

- Contrôle total de l'opération
- Intervention humaine requise
- Temps d'indisponibilité plus long (5-15 minutes)
- Adapté aux environnements avec maintenance planifiée

**Failover automatique :**

- Promotion automatique du slave
- Temps d'indisponibilité minimal (30-90 secondes)
- Nécessite un outil d'orchestration (Patroni, Stolon, repmgr)
- Adapté aux environnements production haute disponibilité

### Architecture après failover

```
AVANT FAILOVER :
┌──────────┐
│  Master  │ ← Écritures
└────┬─────┘
     │ Réplication
     ▼
┌──────────┐
│  Slave   │ ← Lectures
└──────────┘

APRÈS FAILOVER :
┌──────────┐
│ Ex-Master│ ← ARRÊTÉ
└──────────┘

┌──────────┐
│ Ex-Slave │ ← Écritures + Lectures
│ (promu)  │   NOUVEAU MASTER
└──────────┘
```

---

## Failover manuel

### Prérequis

- Accès au pod slave
- Accès aux services OpenShift
- Backup récent de la base de données

### Scénario : Le master est indisponible

**Signes d'indisponibilité :**

- Pod master en `CrashLoopBackOff` ou `Error`
- Applications ne peuvent plus écrire
- Réplication arrêtée sur le slave

---

### Étape 1 : Vérification de l'état

```bash
# Vérifier l'état des pods
oc get pods -l app=postgresql

# Vérifier l'état de la réplication (si le master répond)
MASTER_POD=$(oc get pods -l name=postgresql -o jsonpath='{.items[0].metadata.name}')
oc exec $MASTER_POD -- psql -U postgres -c "SELECT * FROM pg_stat_replication;" 2>/dev/null || echo "Master inaccessible"

# Vérifier le lag sur le slave
SLAVE_POD=$(oc get pods -l role=slave -o jsonpath='{.items[0].metadata.name}')
oc exec $SLAVE_POD -- psql -U postgres -c "SELECT pg_is_in_recovery();"
```

**Résultats attendus :**

- `pg_is_in_recovery() = true` : le slave est encore en mode standby
- Master inaccessible ou ne répond plus

---

### Étape 2 : Backup de sécurité du slave

⚠️ **CRITIQUE : Toujours faire un backup avant promotion**

```bash
# Snapshot du PVC (si votre storage class le supporte)
oc get pvc postgresql-slave -o yaml > pvc-slave-before-promotion.yaml

# Ou backup SQL
oc exec $SLAVE_POD -- pg_dumpall -U postgres > backup-slave-before-promotion.sql
```

---

### Étape 3 : Promotion du slave en master

**Option A : Promotion avec pg_ctl (PostgreSQL 12+)**

```bash
# Se connecter au pod slave
oc exec -it $SLAVE_POD -- bash

# À l'intérieur du conteneur
pg_ctl promote -D $PGDATA

# Vérifier la promotion
psql -U postgres -c "SELECT pg_is_in_recovery();"
# Devrait retourner "f" (false)

# Sortir du conteneur
exit
```

**Option B : Promotion avec fonction SQL (PostgreSQL 12+)**

```bash
oc exec $SLAVE_POD -- psql -U postgres -c "SELECT pg_promote();"
```

**Option C : Promotion manuelle (toutes versions)**

```bash
# Supprimer le fichier standby.signal
oc exec $SLAVE_POD -- rm -f /var/lib/postgresql/data/standby.signal

# Redémarrer PostgreSQL
oc exec $SLAVE_POD -- pg_ctl restart -D /var/lib/postgresql/data
```

---

### Étape 4 : Vérification de la promotion

```bash
# Vérifier que le slave n'est plus en recovery
oc exec $SLAVE_POD -- psql -U postgres -c "SELECT pg_is_in_recovery();"
# Doit retourner "f"

# Tester une écriture
oc exec $SLAVE_POD -- psql -U postgres -c "CREATE TABLE test_failover (id INT);"
oc exec $SLAVE_POD -- psql -U postgres -c "INSERT INTO test_failover VALUES (1);"
oc exec $SLAVE_POD -- psql -U postgres -c "SELECT * FROM test_failover;"
```

---

### Étape 5 : Redirection du service master

Modifier le service pour pointer vers l'ex-slave (nouveau master) :

**Resource : Modification du service `postgresql`**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgresql
  labels:
    app: postgresql
spec:
  ports:
    - name: postgresql
      port: 5432
      targetPort: 5432
  selector:
    app: postgresql
    role: slave # ← Pointer vers l'ex-slave
  type: ClusterIP
```

Appliquer :

```bash
oc apply -f postgresql-service-updated.yaml

# Ou directement avec oc patch
oc patch service postgresql -p '{"spec":{"selector":{"role":"slave"}}}'
```

---

### Étape 6 : Mise à jour des labels du nouveau master

Mettre à jour les labels du pod promu :

```bash
# Modifier le deployment slave
oc edit deployment postgresql-slave

# Changer les labels
# labels:
#   app: postgresql
#   role: master  # ← Changer de "slave" à "master"
```

Ou créer un nouveau service temporaire :

```bash
# Créer un service pointant vers l'ex-slave
oc expose deployment postgresql-slave --name=postgresql-temp --port=5432

# Supprimer l'ancien service master
oc delete service postgresql

# Renommer le service temporaire
oc patch service postgresql-temp -p '{"metadata":{"name":"postgresql"}}'
```

---

### Étape 7 : Configuration du nouveau master pour la réplication

Configurer le nouveau master pour accepter de futurs slaves :

```bash
# Créer l'utilisateur de réplication si nécessaire
oc exec $SLAVE_POD -- psql -U postgres <<EOF
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='replicator') THEN
        CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'replicator_password';
    END IF;
END
\$\$;
EOF

# Créer un nouveau slot de réplication
oc exec $SLAVE_POD -- psql -U postgres -c "SELECT pg_create_physical_replication_slot('replication_slot_new_slave');"
```

Appliquer la configuration master (réutiliser les ConfigMaps existantes) :

```bash
# Le pod utilise déjà slave.conf, il faut le passer en master.conf
oc exec $SLAVE_POD -- bash -c "cp /etc/postgresql/slave.conf /var/lib/postgresql/data/postgresql.auto.conf"

# Ou recréer le pod avec la configuration master
oc set volumes deployment/postgresql-slave \
  --add --name=master-config \
  --type=configmap \
  --configmap-name=postgresql-master-config \
  --mount-path=/etc/postgresql/master.conf \
  --sub-path=master.conf \
  --overwrite

# Redémarrer le pod
oc rollout restart deployment/postgresql-slave
```

---

### Étape 8 : Validation finale

```bash
# Applications peuvent écrire
oc exec $SLAVE_POD -- psql -U postgres -c "INSERT INTO test_failover VALUES (2);"

# Vérifier les connexions
oc exec $SLAVE_POD -- psql -U postgres -c "SELECT count(*) FROM pg_stat_activity;"

# Tester depuis une application
oc run test-pg --image=postgres:15 --rm -it --restart=Never -- \
  psql -h postgresql -U postgres -d postgres -c "SELECT now();"
```

---

## Failover automatique avec Patroni

Patroni est la solution recommandée pour le failover automatique PostgreSQL sur Kubernetes/OpenShift.

### Architecture avec Patroni

```
┌─────────────────────────────────────────────┐
│              etcd / Consul                  │
│         (Distributed Config Store)          │
└────────────────┬────────────────────────────┘
                 │
         ┌───────┴────────┐
         │                │
    ┌────▼────┐      ┌────▼────┐
    │ Patroni │      │ Patroni │
    │ Master  │─────▶│ Replica │
    │   Pod   │      │   Pod   │
    └─────────┘      └─────────┘
         │                │
    ┌────▼────┐      ┌────▼────┐
    │  PG     │      │  PG     │
    │ Master  │      │ Slave   │
    └─────────┘      └─────────┘
```

---

### Composants nécessaires

1. **etcd** : Store de configuration distribuée (consensus)
2. **Patroni** : Agent qui gère PostgreSQL et le failover
3. **PostgreSQL** : Base de données

---

### Étape 1 : Déploiement d'etcd

**Resource : `etcd-statefulset.yaml`**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: etcd
  labels:
    app: etcd
spec:
  ports:
    - port: 2379
      name: client
    - port: 2380
      name: peer
  clusterIP: None
  selector:
    app: etcd
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: etcd
spec:
  serviceName: etcd
  replicas: 3
  selector:
    matchLabels:
      app: etcd
  template:
    metadata:
      labels:
        app: etcd
    spec:
      containers:
        - name: etcd
          image: quay.io/coreos/etcd:v3.5.9
          ports:
            - containerPort: 2379
              name: client
            - containerPort: 2380
              name: peer
          env:
            - name: ETCD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: ETCD_INITIAL_CLUSTER
              value: "etcd-0=http://etcd-0.etcd:2380,etcd-1=http://etcd-1.etcd:2380,etcd-2=http://etcd-2.etcd:2380"
            - name: ETCD_INITIAL_CLUSTER_STATE
              value: "new"
            - name: ETCD_INITIAL_CLUSTER_TOKEN
              value: "etcd-cluster"
            - name: ETCD_LISTEN_CLIENT_URLS
              value: "http://0.0.0.0:2379"
            - name: ETCD_ADVERTISE_CLIENT_URLS
              value: "http://$(ETCD_NAME).etcd:2379"
            - name: ETCD_LISTEN_PEER_URLS
              value: "http://0.0.0.0:2380"
            - name: ETCD_INITIAL_ADVERTISE_PEER_URLS
              value: "http://$(ETCD_NAME).etcd:2380"
          volumeMounts:
            - name: etcd-data
              mountPath: /var/lib/etcd
  volumeClaimTemplates:
    - metadata:
        name: etcd-data
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Gi
```

Appliquer :

```bash
oc apply -f etcd-statefulset.yaml

# Attendre que etcd soit prêt
oc wait --for=condition=ready pod -l app=etcd --timeout=300s

# Vérifier l'état du cluster
oc exec etcd-0 -- etcdctl member list
```

---

### Étape 2 : ConfigMap Patroni

**Resource : `patroni-config.yaml`**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: patroni-config
data:
  patroni.yml: |
    scope: postgres-cluster
    namespace: /service/
    name: ${HOSTNAME}

    restapi:
      listen: 0.0.0.0:8008
      connect_address: ${HOSTNAME}.postgresql-patroni:8008

    etcd:
      hosts: etcd-0.etcd:2379,etcd-1.etcd:2379,etcd-2.etcd:2379

    bootstrap:
      dcs:
        ttl: 30
        loop_wait: 10
        retry_timeout: 10
        maximum_lag_on_failover: 1048576
        postgresql:
          use_pg_rewind: true
          parameters:
            max_connections: 100
            shared_buffers: 256MB
            wal_level: replica
            hot_standby: "on"
            max_wal_senders: 10
            max_replication_slots: 10
            wal_keep_size: 1GB
            logging_collector: "on"

      initdb:
        - encoding: UTF8
        - data-checksums

      pg_hba:
        - local all all trust
        - host all all 0.0.0.0/0 md5
        - host replication replicator 0.0.0.0/0 md5

      users:
        admin:
          password: admin_password
          options:
            - createrole
            - createdb
        replicator:
          password: replicator_password
          options:
            - replication

    postgresql:
      listen: 0.0.0.0:5432
      connect_address: ${HOSTNAME}.postgresql-patroni:5432
      data_dir: /var/lib/postgresql/data
      bin_dir: /usr/lib/postgresql/15/bin
      authentication:
        replication:
          username: replicator
          password: replicator_password
        superuser:
          username: postgres
          password: postgres_password

    watchdog:
      mode: off

    tags:
      nofailover: false
      noloadbalance: false
      clonefrom: false
```

**Paramètres clés :**

- `ttl: 30` : Temps avant de considérer un nœud mort
- `loop_wait: 10` : Intervalle de vérification
- `maximum_lag_on_failover` : Lag max accepté pour être élu master
- `use_pg_rewind: true` : Permet de resynchroniser un ancien master

Appliquer :

```bash
oc apply -f patroni-config.yaml
```

---

### Étape 3 : StatefulSet PostgreSQL avec Patroni

**Resource : `postgresql-patroni-statefulset.yaml`**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgresql-patroni
  labels:
    app: postgresql-patroni
spec:
  ports:
    - port: 5432
      name: postgresql
    - port: 8008
      name: patroni
  clusterIP: None
  selector:
    app: postgresql-patroni
---
apiVersion: v1
kind: Service
metadata:
  name: postgresql-master
  labels:
    app: postgresql-patroni
spec:
  ports:
    - port: 5432
      targetPort: 5432
  selector:
    app: postgresql-patroni
    role: master
  type: ClusterIP
---
apiVersion: v1
kind: Service
metadata:
  name: postgresql-replicas
  labels:
    app: postgresql-patroni
spec:
  ports:
    - port: 5432
      targetPort: 5432
  selector:
    app: postgresql-patroni
    role: replica
  type: ClusterIP
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgresql-patroni
  labels:
    app: postgresql-patroni
spec:
  serviceName: postgresql-patroni
  replicas: 3
  selector:
    matchLabels:
      app: postgresql-patroni
  template:
    metadata:
      labels:
        app: postgresql-patroni
    spec:
      serviceAccountName: postgresql-patroni
      containers:
        - name: postgresql
          image: postgres:15
          ports:
            - containerPort: 5432
              name: postgresql
            - containerPort: 8008
              name: patroni
          env:
            - name: PATRONI_KUBERNETES_LABELS
              value: "{app: postgresql-patroni}"
            - name: PATRONI_KUBERNETES_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: PATRONI_SUPERUSER_USERNAME
              value: postgres
            - name: PATRONI_SUPERUSER_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgresql-patroni-secret
                  key: superuser-password
            - name: PATRONI_REPLICATION_USERNAME
              value: replicator
            - name: PATRONI_REPLICATION_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgresql-patroni-secret
                  key: replication-password
            - name: PATRONI_SCOPE
              value: postgres-cluster
            - name: PATRONI_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: PATRONI_POSTGRESQL_DATA_DIR
              value: /var/lib/postgresql/data
            - name: PATRONI_POSTGRESQL_PGPASS
              value: /tmp/pgpass
            - name: PATRONI_ETCD_HOSTS
              value: "etcd-0.etcd:2379,etcd-1.etcd:2379,etcd-2.etcd:2379"
            - name: PATRONI_RESTAPI_LISTEN
              value: "0.0.0.0:8008"
            - name: PATRONI_POSTGRESQL_LISTEN
              value: "0.0.0.0:5432"
          volumeMounts:
            - name: postgresql-data
              mountPath: /var/lib/postgresql/data
            - name: patroni-config
              mountPath: /etc/patroni
          command:
            - /bin/bash
            - -c
            - |
              # Installer Patroni
              apt-get update && apt-get install -y python3-pip python3-psycopg2
              pip3 install patroni[etcd]

              # Démarrer Patroni
              exec patroni /etc/patroni/patroni.yml

          livenessProbe:
            httpGet:
              path: /liveness
              port: 8008
            initialDelaySeconds: 30
            periodSeconds: 10

          readinessProbe:
            httpGet:
              path: /readiness
              port: 8008
            initialDelaySeconds: 10
            periodSeconds: 5

      volumes:
        - name: patroni-config
          configMap:
            name: patroni-config

  volumeClaimTemplates:
    - metadata:
        name: postgresql-data
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 20Gi
```

---

### Étape 4 : Secret Patroni

**Resource : `postgresql-patroni-secret.yaml`**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgresql-patroni-secret
type: Opaque
stringData:
  superuser-password: <GÉNÉRER_MOT_DE_PASSE_FORT>
  replication-password: <GÉNÉRER_MOT_DE_PASSE_FORT>
```

---

### Étape 5 : ServiceAccount et RBAC

**Resource : `postgresql-patroni-rbac.yaml`**

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: postgresql-patroni
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: postgresql-patroni
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["create", "get", "list", "patch", "update", "watch"]
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["create", "get", "list", "patch", "update", "watch", "delete"]
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "patch", "update", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: postgresql-patroni
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: postgresql-patroni
subjects:
  - kind: ServiceAccount
    name: postgresql-patroni
```

---

### Étape 6 : Déploiement

```bash
# Appliquer les secrets
oc apply -f postgresql-patroni-secret.yaml

# Appliquer les RBAC
oc apply -f postgresql-patroni-rbac.yaml

# Déployer le StatefulSet
oc apply -f postgresql-patroni-statefulset.yaml

# Surveiller le déploiement
oc get pods -l app=postgresql-patroni -w

# Vérifier les logs
oc logs -f postgresql-patroni-0
```

---

### Étape 7 : Vérification du cluster Patroni

```bash
# Voir l'état du cluster
oc exec postgresql-patroni-0 -- patronictl -c /etc/patroni/patroni.yml list

# Résultat attendu :
# + Cluster: postgres-cluster --+---------+---------+----+-----------+
# | Member              | Host  | Role    | State   | TL | Lag in MB |
# +---------------------+-------+---------+---------+----+-----------+
# | postgresql-patroni-0| 10... | Leader  | running |  1 |           |
# | postgresql-patroni-1| 10... | Replica | running |  1 |         0 |
# | postgresql-patroni-2| 10... | Replica | running |  1 |         0 |
# +---------------------+-------+---------+---------+----+-----------+

# Vérifier le master actuel
oc exec postgresql-patroni-0 -- patronictl -c /etc/patroni/patroni.yml show-config
```

---

### Étape 8 : Test du failover automatique

**Simuler une panne du master :**

```bash
# Identifier le pod master
MASTER_POD=$(oc get pods -l app=postgresql-patroni,role=master -o jsonpath='{.items[0].metadata.name}')

# Supprimer le pod master
oc delete pod $MASTER_POD

# Observer le failover automatique
watch -n 1 "oc exec postgresql-patroni-0 -- patronictl -c /etc/patroni/patroni.yml list"
```

**Comportement attendu :**

1. Patroni détecte que le master ne répond plus (~30 secondes)
2. Un replica est automatiquement promu en master (~10 secondes)
3. L'ancien master redémarre et devient replica automatiquement
4. Temps total d'indisponibilité : ~40-60 secondes

---

### Configuration du service pour Patroni

Les applications doivent utiliser les services appropriés :

**Pour les écritures (master uniquement) :**

```bash
postgresql-master:5432
```

**Pour les lectures (replicas uniquement) :**

```bash
postgresql-replicas:5432
```

**Pour lectures + écritures (tout le cluster) :**

```bash
postgresql-patroni:5432
```

---

## Tests de failover

### Test 1 : Failover manuel planifié

**Avec Patroni :**

```bash
# Effectuer un switchover planifié
oc exec postgresql-patroni-0 -- patronictl -c /etc/patroni/patroni.yml switchover --master postgresql-patroni-0 --candidate postgresql-patroni-1 --force
```

**Sans Patroni (manuel) :**
Suivre la procédure de failover manuel (section précédente)

---

### Test 2 : Failover automatique sur panne

```bash
# Simuler un crash du pod master
MASTER_POD=$(oc get pods -l app=postgresql-patroni,role=master -o jsonpath='{.items[0].metadata.name}')
oc delete pod $MASTER_POD --grace-period=0 --force

# Surveiller
watch -n 1 "oc get pods -l app=postgresql-patroni"
watch -n 1 "oc exec postgresql-patroni-0 -- patronictl -c /etc/patroni/patroni.yml list"
```

---

### Test 3 : Split-brain prevention

```bash
# Isoler un pod du réseau (nécessite Network Policies)
# Créer une NetworkPolicy qui bloque le master actuel

# Patroni devrait :
# 1. Détecter la perte de quorum
# 2. Promouvoir un nouveau master parmi les nœuds connectés
# 3. Empêcher l'ancien master d'accepter des écritures
```

---

### Test 4 : Performance pendant failover

```bash
# Script de test de charge
cat > test-failover-performance.sh <<'EOF'
#!/bin/bash

# Connexion à la base
CONNECTION="postgresql://postgres:password@postgresql-master:5432/postgres"

# Boucle d'écriture
while true; do
    result=$(psql "$CONNECTION" -c "INSERT INTO test_failover VALUES (NOW()) RETURNING *;" 2>&1)
    if [[ $? -eq 0 ]]; then
        echo "[$(date)] SUCCESS: $result"
    else
        echo "[$(date)] FAILED: $result"
    fi
    sleep 1
done
EOF

# Lancer le test en arrière-plan
oc run test-failover --image=postgres:15 --rm -it --restart=Never -- bash -c "$(cat test-failover-performance.sh)"

# Dans un autre terminal, déclencher le failover
oc delete pod $MASTER_POD
```

---

## Retour à la normale

### Après failover manuel : Ajouter un nouveau slave

Une fois le failover effectué, l'ancien master peut être reconfiguré comme slave.

**Étape 1 : Nettoyer l'ancien master**

```bash
# Si l'ancien master est récupérable
OLD_MASTER_POD=$(oc get pods -l name=postgresql -o jsonpath='{.items[0].metadata.name}')

# Supprimer le pod et le PVC
oc delete pod $OLD_MASTER_POD
oc delete pvc postgresql  # PVC de l'ancien master
```

**Étape 2 : Créer un nouveau PVC pour le nouveau slave**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgresql-new-slave
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
  storageClassName: standard
```

**Étape 3 : Déployer le nouveau slave**

Utiliser la même configuration que dans le guide principal (OPENSHIFT_REPLICATION_GUIDE.md), en changeant :

- Service master : pointer vers le nouveau master (ex-slave promu)
- Nom du PVC : `postgresql-new-slave`

---

### Après failover Patroni : Automatique

Avec Patroni, pas d'action nécessaire :

- L'ancien master redémarre automatiquement comme replica
- Patroni synchronise automatiquement les données
- Le cluster retrouve son état nominal (1 master + N replicas)

---

## Troubleshooting

### Problème : Promotion du slave échoue

**Symptômes :**

```bash
ERROR: cannot promote server because it is still in recovery mode
```

**Solutions :**

1. **Vérifier si le slave a fini de rattraper le WAL :**

```bash
oc exec $SLAVE_POD -- psql -U postgres -c "
SELECT pg_is_in_recovery(), pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn();
"
```

2. **Attendre la fin du replay :**

```bash
# Le slave doit terminer d'appliquer tous les WAL
# Attendre quelques minutes puis réessayer
```

3. **Forcer la promotion (dernier recours) :**

```bash
oc exec $SLAVE_POD -- pg_ctl promote -D /var/lib/postgresql/data
```

---

### Problème : Split-brain (deux masters actifs)

**Symptômes :**

- Deux pods acceptent des écritures
- Données divergentes entre les deux serveurs

**⚠️ CRITIQUE : Éviter à tout prix**

**Solutions :**

1. **Identifier les deux masters :**

```bash
oc exec <pod1> -- psql -U postgres -c "SELECT pg_is_in_recovery();"
oc exec <pod2> -- psql -U postgres -c "SELECT pg_is_in_recovery();"
```

2. **Choisir le master à conserver :**
   - Généralement : le plus récent (LSN le plus élevé)
   - Ou celui avec le plus de données

```bash
# Vérifier les LSN
oc exec <pod1> -- psql -U postgres -c "SELECT pg_current_wal_lsn();"
oc exec <pod2> -- psql -U postgres -c "SELECT pg_current_wal_lsn();"
```

3. **Arrêter l'autre master :**

```bash
oc scale deployment/<old-master> --replicas=0
```

4. **Reconfigurer en slave :**
   - Supprimer le PVC de l'ancien master
   - Recréer comme slave depuis le nouveau master

**Prévention :**

- Utiliser Patroni (gestion automatique du quorum)
- Toujours vérifier qu'un seul master est actif avant failover manuel

---

### Problème : Patroni n'élit pas de nouveau master

**Symptômes :**

```bash
patronictl list
# Tous les membres en état "no master"
```

**Solutions :**

1. **Vérifier etcd :**

```bash
oc exec etcd-0 -- etcdctl endpoint health --cluster
```

2. **Vérifier le quorum :**

```bash
# Patroni nécessite la majorité (2/3, 3/5, etc.)
# Si trop de nœuds down, pas de quorum
```

3. **Réinitialiser le cluster (dernier recours) :**

```bash
oc exec postgresql-patroni-0 -- patronictl -c /etc/patroni/patroni.yml reinit postgres-cluster postgresql-patroni-0
```

---

### Problème : Applications continuent d'écrire sur l'ancien master

**Symptômes :**

- Applications reçoivent des erreurs après failover
- Connexions vers l'ancien master

**Solutions :**

1. **Vérifier les services :**

```bash
oc get endpoints postgresql-master
# Doit pointer vers le nouveau master
```

2. **Forcer la reconnexion :**

```bash
# Redémarrer les applications
oc rollout restart deployment/<app-name>
```

3. **Utiliser un proxy (pgBouncer, HAProxy) :**
   - Le proxy détecte automatiquement le master actif
   - Les applications se connectent au proxy, pas directement à PostgreSQL

---

## Checklist de failover

### Avant le failover

- [ ] Backup complet de toutes les bases de données
- [ ] Vérification du lag de réplication (< 10MB recommandé)
- [ ] Communication aux équipes
- [ ] Plan de rollback préparé
- [ ] Vérification que le slave est prêt à être promu

### Pendant le failover manuel

- [ ] Backup du slave avant promotion
- [ ] Promotion du slave exécutée
- [ ] Vérification pg_is_in_recovery() = false
- [ ] Test d'écriture réussi
- [ ] Service redirigé vers le nouveau master
- [ ] Applications reconnectées

### Après le failover

- [ ] Monitoring actif du nouveau master
- [ ] Plan de reconstruction d'un slave
- [ ] Documentation de l'incident
- [ ] Post-mortem (si failover non planifié)

---

## Comparaison solutions de failover

| Critère                     | Failover Manuel | Patroni     |
| --------------------------- | --------------- | ----------- |
| **Temps d'indisponibilité** | 5-15 min        | 30-90 sec   |
| **Intervention humaine**    | Requise         | Optionnelle |
| **Complexité**              | Faible          | Moyenne     |
| **Risque d'erreur**         | Élevé           | Faible      |
| **Split-brain**             | Possible        | Prévenu     |
| **Coût opérationnel**       | Élevé           | Faible      |
| **Use case**                | Dev/Test        | Production  |

---

## Ressources supplémentaires

### Documentation

- [PostgreSQL High Availability](https://www.postgresql.org/docs/current/high-availability.html)
- [Patroni Documentation](https://patroni.readthedocs.io/)
- [etcd Documentation](https://etcd.io/docs/)

### Commandes utiles

```bash
# État du cluster Patroni
oc exec <patroni-pod> -- patronictl list

# Switchover planifié
oc exec <patroni-pod> -- patronictl switchover

# Failover manuel (sans master actuel)
oc exec <patroni-pod> -- patronictl failover

# Redémarrer un membre
oc exec <patroni-pod> -- patronictl restart <member-name>

# Réinitialiser un membre
oc exec <patroni-pod> -- patronictl reinit <cluster-name> <member-name>
```
