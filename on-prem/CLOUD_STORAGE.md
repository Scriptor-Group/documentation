## ☁️ Configuration du Cloud Storage (S3 ou Azure)

Votre application prend en charge deux providers de stockage cloud :

- **Amazon S3** (ou compatible : MinIO, Wasabi, etc.)
- **Microsoft Azure Blob Storage**

Chaque microservice a ses propres variables d’environnement. Voici un guide pour les configurer correctement.

---

### Prérequis

#### Pour Azure Blob Storage

- Un compte Azure
- Un compte de stockage Azure
- Une application Microsoft Entra ID

---


### 🔧 1. Devana API – Variables d’environnement

#### ✅ Pour Azure Blob Storage

```env
# Nom du compte de stockage Azure
AZURE_STORAGE_ACCOUNT_NAME=your-account-name

# Clé du compte Azure
AZURE_STORAGE_ACCOUNT_KEY=your-account-key

# Nom du container blob
AZURE_STORAGE_CONTAINER_NAME=devana

# ID de l'application Microsoft Entra ID
AZURE_CLIENT_ID=your-client-id

# Clé secrète du client Microsoft Entra ID
AZURE_CLIENT_SECRET=your-client-secret

# ID du locataire Microsoft Entra ID
AZURE_TENANT_ID=your-tenant-id
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

# Nom du container
AZURE_STORAGE_CONTAINER_NAME=devana

# ID de l'application Microsoft Entra ID
AZURE_CLIENT_ID=your-client-id

# Clé secrète du client Microsoft Entra ID
AZURE_CLIENT_SECRET=your-client-secret

# ID du locataire Microsoft Entra ID
AZURE_TENANT_ID=your-tenant-id

# Répertoires spécifiques dans le container
AZURE_STORAGE_DOCUMENTS_DIR=odin/odindocuments
AZURE_STORAGE_ATTACHMENTS_DIR=odin/odinattachments
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

### 🛠️ Guide rapide – Configuration

#### 1. Azure Blob Storage

##### 1.1. Créer une application Microsoft Entra ID
- Aller sur le portail Azure > Inscriptions d'applications > Nouvelle inscription
- Dans le formulaire, remplir les champs suivants :
  - **Nom** : Devana
  - **Type de compte** : Selon vos besoins
  - **URI de redirection** : Pas nécessaire dans ce cas là

##### 1.2. Créer un compte de stockage Azure
- Aller sur le portail Azure > Comptes de stockage > Nouveau
- Remplir les champs suivants du formulaire
- Une fois le compte de stockage créé, aller sur l'onglet `Controle d'accès (IAM)`, cliquer sur `Ajouter une attribution de rôle`, et créer un nouveau rôle avec les droits suivants :
  - `Contributeur aux données blob de stockage`
- Dans la section `Membres`, ajouter l'application Microsoft Entra ID créée précédemment.
- Dans la section `Vérifier + attribuer`, vérifier les informations et cliquer sur `Vérifier + attribuer`.

##### 1.3. Configurer les variables d'environnement
- Aller sur le portail Azure > Comptes de stockage > `your-account-name` > `Clés d'accès`
- Copier les valeurs des champs `Nom du compte de stockage` et `key1`
- Remplacer les variables d'environnement `AZURE_STORAGE_ACCOUNT_NAME` et `AZURE_STORAGE_ACCOUNT_KEY` dans le fichier `.env` du microservice Odin et Devana API
- Remplacer la variable d'environnement `AZURE_STORAGE_CONTAINER_NAME` dans le fichier `.env` du microservice Odin et Devana API par le nom du container créé précédemment si créé.
- Remplacer la variable d'environnement `AZURE_CLIENT_ID` dans le fichier `.env` du microservice Odin et Devana API par l'ID de l'application Microsoft Entra ID créée précédemment.
- Remplacer la variable d'environnement `AZURE_CLIENT_SECRET` dans le fichier `.env` du microservice Odin et Devana API par la clé secrète de l'application Microsoft Entra ID créée précédemment.
- Remplacer la variable d'environnement `AZURE_TENANT_ID` dans le fichier `.env` du microservice Odin et Devana API par l'ID du locataire Microsoft Entra ID créée précédemment.



### ⚠️ Remarques générales

- Ne définissez qu'un seul provider à la fois (S3 ou Azure) pour l'ensemble des services.
- Pour chaque service, l'application détecte automatiquement quel provider utiliser selon les variables présentes.
- Assurez-vous que tous les microservices pointent vers la même configuration de stockage cloud, afin d’éviter toute désynchronisation.
- Assurez-vous que si des clés secrètes sont utilisées, elles sont stockées de manière sécurisée et ne sont pas divulguées à des tiers, ainsi verifier leurs dates d'expiration.
