
# Azure
 
> [!WARNING]
> Ressource en cours de rédaction

## Modules Azure recommandés

- **Azure Key Vault**
- **Serveurs Azure Database pour PostgreSQL**
- **Instances de conteneur**
- **Azure Blob Storage**
- **Application Conteneur**
- **Azure AI Studio**

## Procédure de déploiement

### Créer un groupe de ressources

Afin d'avoir un groupe de ressources pour inclure toutes vos ressources, vous devez créer un `Groupe de ressources`. 

### Réseaux

Veuillez créer une adresse réseau dédiée à Devana, ainsi qu'une souscription dédiée.

### Création de l'Azure Key Vault

Afin de stocker de manière sécurisée toutes les variables d'environnement, nous vous recommandons d'utiliser le service Azure Key Vault.

### Création de la base de données

Afin de fonctionner correctement, Devana nécessite une base de données PostgreSQL. Nous vous recommandons d'utiliser le service `Azure Database pour PostgreSQL`.

1. Créez une ressource `Serveurs Azure Database pour PostgreSQL`
2. Définissez une version de PostgreSQL `>=` à `16`
3. Définissez un `Type de charge de travail` adapté à votre installation
4. Définissez un `Calcul + stockage` de minimum `4 vCores et 16 Go de RAM`
5. Définissez une `Zone de disponibilité` adaptée à votre installation
6. Définissez un `Nom de l'utilisateur administrateur` (**Gardez-le précieusement en l'ajoutant dans votre Key Vault**)
7. Définissez un `Mot de passe` pour l'utilisateur administrateur (**Gardez-le précieusement en l'ajoutant dans votre Key Vault**)
8. Définissez une `Méthode de connectivité` ainsi que des `Règles de pare-feu` adaptées à votre installation
9. Définissez un `Chiffrement des données` adapté
10. Ajoutez les balises de votre choix sur votre base de données
11. Vérifiez et créez votre base de données

Après la création de votre base de données, vous devez :

1. Ajouter l'IP `privée` de votre base de données dans votre `Key Vault` pour permettre à Devana de se connecter à votre base de données
2. Ajouter une base de données `devana`
3. Créer une variable d'environnement `DATABASE_URL` dans votre `Key Vault` avec la valeur `postgresql://<user>:<password>@<host>:<port>/<database>?schema=devana`

### Créer un compte de stockage

> [!WARNING]
> Cette section est toujours en cours de rédaction, restez prudent.

Suivez la procédure pour ajouter une ressource `Azure Blob Storage` à votre groupe de ressources.

1. Créez un compte de stockage
2. Définissez des `Performances` adaptées à votre installation (Standard ou Premium)
3. Définissez un mode de `Redondance` adapté à votre installation (Localement redondant, Géographiquement redondant, Zone redondante, etc.)
4. `Exiger un transfert sécurisé pour les opérations d'API REST` doit être activé
5. Nous vous recommandons d'activer le mode `Autoriser la réplication entre clients` à `Froid`
6. `Activer la suppression réversible pour les blobs` doit être activé
7. `Activer la suppression réversible pour les conteneurs` doit être activé
8. `Activer la suppression réversible pour les partages de fichiers` doit être activé
9. Si vous le souhaitez, vous pouvez `Activer le chiffrement d'infrastructure`
10. Ajoutez les balises de votre choix sur votre compte de stockage
11. Vérifiez et créez votre compte de stockage

Après la création de votre compte de stockage, vous devez :

1. Ajouter une variable d'environnement `AZURE_STORAGE_CONNECTION_STRING` dans votre `Key Vault` avec la valeur `DefaultEndpointsProtocol=https;AccountName=<account-name>;AccountKey=<account-key>==;EndpointSuffix=core.windows.net`

### Création des Instances de conteneur

Les Instances de conteneur vont contenir des `Docker` permettant :
1. L'initialisation de la base de données
2. L'administration de la base de données si nécessaire
3. L'hébergement de la base de données vectorielle
4. L'hébergement du service Redis

> [!NOTE]
> Les Instances de conteneur ne sont pas auto-scalées.

> [!WARNING]
> Attention, Azure demande le nom de l'image Docker à utiliser. Nous vous recommandons d'utiliser le nommage suivant : `registry.devana.ai/devana/<nom-de-l-image>:<version>`. Cette règle ne s'applique pas pour la création des `Application Conteneur` où vous devez utiliser la structure `devana/<nom-de-l-image>:<version>`.

#### Initialisation de la base de données

Pour initialiser la base de données, vous devez utiliser notre image `registry.devana.ai/devana/prisma-deploy:latest`. Vous devez ajouter la variable d'environnement `DATABASE_URL` lors de la création du conteneur.

#### Gestion de la base de données

Afin de pouvoir gérer la base de données, vous avez deux solutions.

**1. Connexion depuis votre poste** (Recommandé)

Si votre base de données est accessible sur Internet, nous vous recommandons d'utiliser la commande suivante via votre poste :

`docker run --rm -e DATABASE_URL='<votre-env>' registry.devana.ai/devana/prisma-deploy:latest npx prisma studio`

**2. Depuis un réseau privé**

> [!CAUTION]
> Le service permettant la gestion de la base de données n'ayant pas d'interface de connexion, veuillez faire attention à vos actions !

Créez un nouveau conteneur rattaché au réseau de votre base de données.

1. Choisissez comme image `registry.devana.ai/devana/prisma-deploy:latest` 
2. Ajoutez la variable d'environnement `DATABASE_URL`
3. Définissez comme commande d'exécution `["npx", "prisma", "studio"]`
4. Ouvrez le port `5555`
5. Créez votre conteneur

Vous pouvez maintenant accéder à l'interface d'administration de votre base de données via l'adresse `<ip-du-conteneur>:5555`.

> [!CAUTION]
> N'oubliez pas de supprimer le container après la fin de vos actions.

#### Créer votre serveur Redis

Afin de fonctionner correctement, Devana nécessite une base de données Redis fonctionnelle.

1. Ajoutez un nouveau conteneur utilisant minimum `1 vCore` et `1 Go de RAM`
2. Utilisez l'image Redis `redis:7.2`
3. Définissez la commande d'exécution avec `["redis-server", "--requirepass", "<un-mot-de-passe>"]` (Ajoutez `<un-mot-de-passe>` dans une variable d'environnement `REDIS_PASSWORD`)
4. Ouvrez le port `6379`
5. Créez votre conteneur

Sauvegardez l'IP privée de votre conteneur dans une nouvelle variable d'environnement `REDIS_HOST`. Ajoutez également une variable d'environnement `REDIS_PORT` contenant le port du serveur `6379`.

#### Créer votre base de données vectorielle

1. Ajoutez un nouveau conteneur utilisant minimum `3 vCores` et `4 Go de RAM`
2. Utilisez l'image `registry.devana.ai/devana/devana-vectors:latest`
3. Définissez la variable d'environnement `IS_PERSISTENT` à `true`
4. Ouvrez le port `8000`
5. Créez votre conteneur

Ajoutez une nouvelle variable d'environnement `CHROMA_HOST` contenant `http://<ip-du-conteneur>:8000`

### Création des Application Conteneur

Nous devons maintenant ouvrir 3 nouveaux services dans `Application Conteneur`. Celui-ci permet de déployer des services auto-scalés.

#### Front-end

Afin d'héberger le système d'extraction d'informations, vous devez ajouter une `Application Conteneur` avec les préférences suivantes :
- Utilisez l'image `devana/front:<votre-entreprise>` avec le container registry `registry.devana.ai`
- Utilisez des ressources `Processeur et mémoire` de minimum `1 vCpu et 2 Gio`
- Ajoutez la variable d'environnement `NODE_ENV` à `production`
- Ouvrez le port `3000`

Après la création de votre conteneur, pensez à définir un réplicat de minimum `2` instances.

#### Document parser

Afin d'héberger le système d'extraction d'informations, vous devez ajouter une `Application Conteneur` avec les préférences suivantes :
- Utilisez l'image `devana/pdfdocx:latest` avec le container registry `registry.devana.ai`
- Utilisez des ressources `Processeur et mémoire` de minimum `2 vCpu et 4 Gio`
- Ajoutez la variable d'environnement `NODE_ENV` à `production`
- Ouvrez le port `4667`

Après la création de votre conteneur, pensez à définir un réplicat de minimum `3` instances.

#### API

Afin d'héberger l'API, vous devez ajouter une `Application Conteneur` avec les préférences suivantes :
- Utilisez l'image `devana/back:latest` avec le container registry `registry.devana.ai`
- Utilisez des ressources `Processeur et mémoire` de minimum `1.5 vCpu et 3 Gio`
- Ajoutez les variables d'environnement ci-dessous et ouvrez les ports nécessaires 

Après la création de votre conteneur, pensez à définir un réplicat de minimum `2` instances.

##### Liste des variables d'environnement nécessaires :

| Variable                       | Valeur                        |
| ------------------------------ | ----------------------------- |
| PORT                           | 4666                          |
| NODE_ENV                       | production                    |
| JWT_SECRET_KEY                 | Une clé générée par vos soins |
| DATABASE_URL                   | Key vault                     |
| CHROMA_HOST                    | Key vault                     |
| REDIS_HOST                     | Key vault                     |
| REDIS_PORT                     | Key vault                     |
| REDIS_PASSWORD                 | Key vault                     |
| APPLICATION_URL                | http(s)://url-du-front/       |
| CLIENT_URI                     | http(s)://url-du-front        |
| API_URI                        | http(s)://url-du-back         |
| PDF_TO_WORD_SERVER             | Key vault                     |
| OPENAI_API_KEY                 | Clé ou "EMPTY"                |
| ANTHROPIC_API_KEY              | Clé ou "EMPTY"                |
| MISTRAL_API_KEY                | Clé ou "EMPTY"                |
| GROQ_API_KEY                   | Clé ou "EMPTY"                |
| GEMINI_API_KEY                 | Clé ou "EMPTY"                |
| STRIPE_SECRET_KEY              | Clé ou "EMPTY"                |
| GOOGLE_APPLICATION_PRIVATE_KEY | Clé ou "EMPTY"                |
| GOOGLE_APPLICATION_PRIVATE_KEY | Clé ou "EMPTY"                |

##### Variables pour les connecteurs


| Variable                | Description                                               | Notes                                |
|-------------------------|-----------------------------------------------------------|--------------------------------------|
| `GOOGLE_CLIENT_ID`      | L'identifiant client de votre application Google Drive     |                                      |
| `GOOGLE_CLIENT_SECRET`  | Le secret client de votre application Google Drive         |                                      |
| `DROPBOX_CLIENT_ID`     | L'identifiant client de votre application Dropbox          |                                      |
| `DROPBOX_CLIENT_SECRET` | Le secret client de votre application Dropbox              |                                      |
| `MICROSOFT_CLIENT_ID`   | L'identifiant client de votre application Microsoft OneDrive|                                      |
| `MICROSOFT_CLIENT_SECRET`| Le secret client de votre application Microsoft OneDrive  |                                      |
| `OAUTH_CALLBACK_URI`    | L'URL de redirection pour gérer l'authentification         |                                      |
| `JIRA_CLIENT_ID`        | L'identifiant client de votre application Jira             |                                      |
| `JIRA_CLIENT_SECRET`    | Le secret client de votre application Jira                 |                                      |
| `SHAREPOINT_LIBRARY`    | Tableau de bibliothèque Sharepoint à scopé pour les sites Sharepoint                            | Exemple: `["Documents", "Site Pages", "Pages"]` |


##### Ports à ouvrir

| Port | Type | Description |
| ---- | ---- | ----------- |
| 4666 | TCP  | API         |
| 5001 | TCP  | WebSockets  |

### Création de l'Azure AI Studio

> [!NOTE]
> Documentation en cours de rédaction

## Accès à l'application

Rendez-vous sur l'IP de votre front Devana sur le port 3000 afin d'accéder à l'interface Devana.

### Création d'une marque blanche

> [!NOTE]
> Documentation en cours de rédaction
