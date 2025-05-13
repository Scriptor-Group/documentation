## ☁️ Configuration du Cloud Storage (S3 ou Azure)

Votre application prend en charge deux providers de stockage cloud :

- **Amazon S3** (ou compatible : MinIO, Wasabi, etc.)
- **Microsoft Azure Blob Storage**

Chaque microservice a ses propres variables d’environnement. Voici un guide pour les configurer correctement.

---

### 🔧 1. Devana API – Variables d’environnement

#### ✅ Pour Azure Blob Storage

```env
# Nom du compte de stockage Azure
AZURE_STORAGE_ACCOUNT_NAME=your-account-name

# Clé du compte Azure
AZURE_STORAGE_ACCOUNT_KEY=your-account-key

# Endpoint du serveur Azure
AZURE_STORAGE_ENDPOINT=http://127.0.0.1:10000/your-account-name

# Nom du container blob
AZURE_STORAGE_CONTAINER_NAME=devana
```

#### ✅ Pour Amazon S3

```env
# Clés d'accès AWS
AWS_S3_ACCESS_KEY_ID=your-access-key-id
AWS_S3_SECRET_ACCESS_KEY=your-secret-access-key

# Nom du bucket S3
AWS_S3_BUCKET_NAME=devana

# Domaine pour servir les fichiers (CDN ou S3 direct)
AWS_S3_DOMAIN=https://cdn.your-domain.com

# Endpoint serveur S3
AWS_S3_ENDPOINT=https://s3.your-provider.com

# Région S3
AWS_S3_REGION=eu-west-3
```

---

### 🔧 2. Microservice Odin – Variables d’environnement

#### ✅ Pour Azure Blob Storage

```env
# Nom du compte Azure
AZURE_STORAGE_ACCOUNT_NAME=your-account-name

# Clé d'accès Azure
AZURE_STORAGE_ACCOUNT_KEY=your-account-key

# Endpoint serveur Azure
AZURE_STORAGE_ENDPOINT=http://127.0.0.1:10000/your-account-name

# Nom du container
AZURE_STORAGE_CONTAINER_NAME=devana

# Répertoires spécifiques dans le container
AZURE_STORAGE_DOCUMENTS_DIR=documents
AZURE_STORAGE_ATTACHMENTS_DIR=attachments
```

#### ✅ Pour Amazon S3

```env
# Endpoint serveur S3
S3_ENDPOINT=https://s3.your-provider.com

# Région S3
S3_REGION=eu-west-3

# Clés d'accès
S3_ACCESS_KEY=your-access-key
S3_SECRET_KEY=your-secret-key

# Nom du bucket
S3_BUCKET=odin
```

---

### ⚠️ Remarques générales

- Ne définissez qu'un seul provider à la fois (S3 ou Azure).
- Pour chaque service, l'application détecte automatiquement quel provider utiliser selon les variables présentes.
