# Installation PostgreSQL Operator en mode Namespace-Scoped

Guide d'installation du PostgreSQL Operator sans permissions cluster-admin, limitée à un namespace spécifique.

## Contexte

Cette installation est adaptée pour les environnements OpenShift où vous n'avez pas les droits `cluster-admin` pour créer des `ClusterRole` et `ClusterRoleBinding`.

### Limitations

⚠️ **Limitations importantes de cette approche :**

- L'opérateur ne peut gérer que les clusters PostgreSQL **dans le même namespace**
- Pas de gestion multi-namespace
- Certaines fonctionnalités avancées peuvent être limitées
- Les pods PostgreSQL utilisent un ServiceAccount du même namespace

### Avantages

✅ **Avantages :**
- Pas besoin de droits cluster-admin
- Installation self-service
- Isolation complète par namespace
- Sécurité renforcée (principe du moindre privilège)

---

## Prérequis

### Permissions nécessaires dans le namespace

Vous devez avoir les permissions suivantes dans votre namespace :

```bash
# Vérifier vos permissions
oc auth can-i create serviceaccounts -n postgres-operator
oc auth can-i create roles -n postgres-operator
oc auth can-i create rolebindings -n postgres-operator
oc auth can-i create deployments -n postgres-operator
```

Toutes ces commandes doivent retourner `yes`.

### Demande à l'admin cluster (REQUIS)

L'admin cluster doit créer la CRD `postgresqls` qui est une ressource cluster-level :

**Fichier à envoyer à l'admin : `crd-request.yaml`**

```yaml
# L'admin doit exécuter : oc create -f crd-request.yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: postgresqls.acid.zalan.do
spec:
  group: acid.zalan.do
  names:
    kind: postgresql
    listKind: postgresqlList
    plural: postgresqls
    singular: postgresql
    shortNames:
    - pg
  scope: Namespaced
  versions:
  - name: v1
    served: true
    storage: true
    subresources:
      status: {}
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            x-kubernetes-preserve-unknown-fields: true
          status:
            type: object
            x-kubernetes-preserve-unknown-fields: true
    additionalPrinterColumns:
    - name: Team
      type: string
      description: Team responsible for Postgres CLuster
      jsonPath: .spec.teamId
    - name: Version
      type: string
      description: PostgreSQL version
      jsonPath: .spec.postgresql.version
    - name: Pods
      type: integer
      description: Number of Pods per Postgres cluster
      jsonPath: .spec.numberOfInstances
    - name: Volume
      type: string
      description: Size of the bound volume
      jsonPath: .spec.volume.size
    - name: CPU-Request
      type: string
      description: Requested CPU for Postgres containers
      jsonPath: .spec.resources.requests.cpu
    - name: Memory-Request
      type: string
      description: Requested memory for Postgres containers
      jsonPath: .spec.resources.requests.memory
    - name: Age
      type: date
      jsonPath: .metadata.creationTimestamp
    - name: Status
      type: string
      description: Current sync status of postgresql resource
      jsonPath: .status.PostgresClusterStatus
```

**Message pour l'admin :**

```
Bonjour,

Je souhaite déployer le PostgreSQL Operator dans mon namespace "postgres-operator"
sans nécessiter de permissions cluster-admin.

Pourriez-vous créer la CustomResourceDefinition nécessaire avec la commande suivante ?

oc create -f crd-request.yaml

Cette CRD permettra de créer des ressources PostgreSQL de manière scopée à mon namespace.

Merci,
```

---

## Installation

### Étape 1 : Créer le namespace

```bash
oc new-project postgres-operator
```

### Étape 2 : Attendre la création de la CRD par l'admin

```bash
# Vérifier que la CRD est créée
oc get crd postgresqls.acid.zalan.do

# Devrait afficher :
# NAME                        CREATED AT
# postgresqls.acid.zalan.do   2025-01-08T...
```

### Étape 3 : Créer le RBAC namespace-scoped

```bash
oc create -f rbac-namespace-scoped.yaml
```

Vérifier :

```bash
oc get sa -n postgres-operator
# Devrait afficher postgres-operator et postgres-pod

oc get role -n postgres-operator
# Devrait afficher postgres-operator et postgres-pod

oc get rolebinding -n postgres-operator
# Devrait afficher postgres-operator et postgres-pod
```

### Étape 4 : Créer la ConfigMap

Créer le fichier `configmap-namespace-scoped.yaml` :

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-operator
  namespace: postgres-operator
data:
  # Configuration spécifique OpenShift
  kubernetes_use_configmaps: "true"

  # IMPORTANT : Limiter l'opérateur à ce namespace uniquement
  watched_namespace: "postgres-operator"

  # Images
  docker_image: registry.opensource.zalan.do/acid/spilo-16:3.2-p3
  sidecar_docker_image: registry.opensource.zalan.do/acid/pgbouncer:master-32

  # Ressources par défaut
  min_cpu_limit: "250m"
  max_cpu_request: "2"
  min_memory_limit: "250Mi"
  max_memory_request: "4Gi"

  # Configuration des pods
  pod_management_policy: "ordered_ready"
  pod_terminate_grace_period: "5m"

  # ServiceAccount pour les pods PostgreSQL
  service_account_name: "postgres-pod"

  # Configuration du stockage
  enable_pod_antiaffinity: "true"
  pod_antiaffinity_preferred_during_scheduling: "false"

  # Monitoring
  enable_pod_disruption_budget: "true"

  # Workers
  workers: "4"

  # Désactiver les features nécessitant cluster-level permissions
  enable_cross_namespace_secret: "false"
```

Appliquer :

```bash
oc create -f configmap-namespace-scoped.yaml
```

### Étape 5 : Déployer l'opérateur

Créer le fichier `operator-deployment.yaml` :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-operator
  namespace: postgres-operator
  labels:
    application: postgres-operator
    name: postgres-operator
spec:
  replicas: 1
  selector:
    matchLabels:
      name: postgres-operator
  template:
    metadata:
      labels:
        name: postgres-operator
        application: postgres-operator
    spec:
      serviceAccountName: postgres-operator
      containers:
      - name: postgres-operator
        image: ghcr.io/zalando/postgres-operator:v1.14.0
        imagePullPolicy: IfNotPresent
        resources:
          requests:
            cpu: 100m
            memory: 250Mi
          limits:
            cpu: 500m
            memory: 500Mi
        securityContext:
          runAsUser: 1000
          runAsNonRoot: true
          readOnlyRootFilesystem: true
          allowPrivilegeEscalation: false
        env:
        - name: CONFIG_MAP_NAME
          value: postgres-operator
        - name: WATCHED_NAMESPACE
          value: postgres-operator
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
```

Appliquer :

```bash
oc create -f operator-deployment.yaml
```

### Étape 6 : Vérifier le déploiement

```bash
# Vérifier que le pod démarre
oc get pods -l name=postgres-operator

# Devrait afficher :
# NAME                                READY   STATUS    RESTARTS   AGE
# postgres-operator-xxxxxxxxxx-xxxxx  1/1     Running   0          30s

# Vérifier les logs
oc logs -l name=postgres-operator -f
```

---

## Déploiement d'un cluster PostgreSQL

### Créer un cluster de test

Créer le fichier `test-cluster.yaml` :

```yaml
apiVersion: "acid.zalan.do/v1"
kind: postgresql
metadata:
  name: test-cluster
  namespace: postgres-operator
spec:
  teamId: "myteam"
  numberOfInstances: 2

  postgresql:
    version: "16"
    parameters:
      shared_buffers: "128MB"
      max_connections: "100"

  volume:
    size: 10Gi
    storageClass: "standard"

  users:
    admin:
      - superuser
      - createdb
    app_user: []

  databases:
    testdb: admin

  resources:
    requests:
      cpu: "500m"
      memory: "1Gi"
    limits:
      cpu: "1"
      memory: "2Gi"

  # IMPORTANT : Utiliser le ServiceAccount du namespace
  serviceAccountName: postgres-pod

  podAntiAffinity: true
```

Déployer :

```bash
oc apply -f test-cluster.yaml

# Observer la création
oc get postgresql
oc get pods -l cluster-name=test-cluster -w
```

### Vérifier le cluster

```bash
# Vérifier l'état
oc get postgresql test-cluster

# Vérifier les pods
oc get pods -l cluster-name=test-cluster

# Vérifier les services
oc get svc -l cluster-name=test-cluster

# Vérifier les secrets
oc get secrets -l cluster-name=test-cluster
```

---

## Test de connexion

```bash
# Récupérer le mot de passe
export PGPASSWORD=$(oc get secret admin.test-cluster.credentials.postgresql.acid.zalan.do \
  -o jsonpath='{.data.password}' | base64 -d)

# Se connecter
oc run psql-client --rm -it --restart=Never --image=postgres:16 -- \
  psql -h test-cluster.postgres-operator.svc.cluster.local -U admin -d testdb
```

---

## Limitations détaillées

### Ce qui fonctionne ✅

- Création de clusters PostgreSQL dans le namespace
- Haute disponibilité (réplication Patroni)
- Backups logiques
- Connection pooling (PgBouncer)
- Monitoring
- Scaling horizontal (ajout de replicas)
- Failover automatique
- Rolling upgrades

### Ce qui ne fonctionne PAS ❌

- **Multi-namespace** : L'opérateur ne peut gérer que les clusters dans `postgres-operator`
- **Secrets partagés** : Pas d'accès aux secrets d'autres namespaces
- **Node labeling** : Pas de possibilité de créer/modifier des labels sur les nodes
- **StorageClass management** : Pas de création de StorageClass
- **PV provisioning** : Pas de contrôle sur les PersistentVolumes (niveau cluster)

### Workarounds

**Pour avoir plusieurs environnements :**

Option 1 : Tout dans le même namespace avec préfixes
```yaml
metadata:
  name: dev-app1-cluster
  namespace: postgres-operator
---
metadata:
  name: staging-app1-cluster
  namespace: postgres-operator
---
metadata:
  name: prod-app1-cluster
  namespace: postgres-operator
```

Option 2 : Déployer un opérateur par namespace (plus de ressources)
```bash
oc new-project postgres-dev
oc new-project postgres-staging
oc new-project postgres-prod

# Déployer l'opérateur dans chaque namespace
```

---

## Troubleshooting

### L'opérateur ne démarre pas

```bash
# Vérifier les logs
oc logs -l name=postgres-operator --tail=100

# Vérifier le ServiceAccount
oc get sa postgres-operator -o yaml

# Vérifier les RoleBindings
oc describe rolebinding postgres-operator
```

### Le cluster ne se crée pas

```bash
# Vérifier que la CRD existe
oc get crd postgresqls.acid.zalan.do

# Vérifier l'état du cluster
oc describe postgresql test-cluster

# Vérifier les events
oc get events --sort-by='.lastTimestamp' | grep postgres
```

### Erreur "forbidden" dans les logs

```bash
# L'opérateur essaie d'accéder à des ressources hors namespace
# Vérifier que watched_namespace est bien configuré
oc get configmap postgres-operator -o yaml | grep watched_namespace

# Si vide ou "*", corriger :
oc patch configmap postgres-operator -p '{"data":{"watched_namespace":"postgres-operator"}}'

# Redémarrer l'opérateur
oc rollout restart deployment postgres-operator
```

---

## Migration vers cluster-scoped (si droits admin obtenus)

Si vous obtenez les droits cluster-admin plus tard :

```bash
# 1. Supprimer l'installation namespace-scoped
oc delete deployment postgres-operator -n postgres-operator
oc delete -f rbac-namespace-scoped.yaml

# 2. Installer en mode cluster-scoped
git clone https://github.com/zalando/postgres-operator.git
cd postgres-operator

# 3. Créer le RBAC cluster-level
oc create -f manifests/operator-service-account-rbac-openshift.yaml

# 4. Mettre à jour la ConfigMap pour surveiller tous les namespaces
oc patch configmap postgres-operator -p '{"data":{"watched_namespace":"*"}}'

# 5. Redéployer l'opérateur
oc create -f manifests/postgres-operator.yaml

# Les clusters existants continueront de fonctionner
```

---

## Sécurité

### Principes appliqués

- **Principe du moindre privilège** : Permissions limitées au strict nécessaire
- **Isolation** : Chaque namespace est isolé
- **Security Context** : Pods non-root, read-only filesystem
- **RBAC** : Contrôle d'accès fin par ressource

### Bonnes pratiques

```yaml
# Dans vos manifests PostgreSQL, toujours spécifier :
spec:
  serviceAccountName: postgres-pod

  # Limiter les ressources
  resources:
    requests:
      cpu: "500m"
      memory: "1Gi"
    limits:
      cpu: "2"
      memory: "2Gi"

  # Activer Pod Security Standards
  podSecurityContext:
    runAsNonRoot: true
    fsGroup: 103
    seccompProfile:
      type: RuntimeDefault
```

---

## Récapitulatif des fichiers

```
postgres-operator/
├── crd-request.yaml                    # À faire créer par l'admin
├── rbac-namespace-scoped.yaml          # RBAC limité au namespace
├── configmap-namespace-scoped.yaml     # Configuration de l'opérateur
├── operator-deployment.yaml            # Déploiement de l'opérateur
└── test-cluster.yaml                   # Exemple de cluster
```

---

## Commandes de référence

```bash
# Status de l'opérateur
oc get pods -l name=postgres-operator
oc logs -l name=postgres-operator -f

# Liste des clusters
oc get postgresql

# Détails d'un cluster
oc describe postgresql test-cluster

# Pods PostgreSQL
oc get pods -l application=spilo

# Services
oc get svc -l application=spilo

# Secrets
oc get secrets -l cluster-name=test-cluster

# PVCs
oc get pvc -l cluster-name=test-cluster

# Supprimer un cluster (ATTENTION)
oc delete postgresql test-cluster
```

---

**Version du document** : 1.0
**Dernière mise à jour** : 2025-01-08
**Testé avec** : OpenShift 4.14+, PostgreSQL Operator v1.14.0
