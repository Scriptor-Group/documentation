# Variables d'Environnement - Devana.ai

Ce document décrit toutes les variables d'environnement nécessaires à la configuration des services Devana.ai.

## 📑 Table des matières

- [Devana API (Backend)](#devana-api-backend)
- [Odin (Service de traitement)](#odin-service-de-traitement)
- [Frontend](#frontend)

---

## Devana API (Backend)

## 1. Environnement d'exécution

Ces variables définissent le contexte dans lequel l'application est lancée, ce qui peut affecter le logging, l'optimisation et l'activation de certaines fonctionnalités de débogage.

| Variable   | Description                                           | Exemples                            |
| :--------- | :---------------------------------------------------- | :---------------------------------- |
| `NODE_ENV` | Définit l'environnement d'exécution de l'application. | `production`, `development`, `test` |

---

## 2. Tâches Planifiées (Cron)

Configuration pour les tâches automatisées qui s'exécutent à des intervalles réguliers.

| Variable                | Description                                                                                   | Valeur par défaut               |
| :---------------------- | :-------------------------------------------------------------------------------------------- | :------------------------------ |
| `RUN_CRON`              | Active (`true`) ou désactive (`false`) l'exécution globale des tâches cron.                   | `false`                         |
| `CRON_UPDATE_PROVIDERS` | Expression Cron pour la planification de la tâche de mise à jour des fournisseurs de données. | `0 * * * *` (toutes les heures) |

---

## 3. Application Principale

Paramètres de base concernant les points d'accès réseau, les URL publiques et la licence de l'application.

| Variable               | Description                                                 | Valeur par défaut |
| :--------------------- | :---------------------------------------------------------- | :---------------- |
| `PORT`                 | Port d'écoute du serveur principal de l'API.                | `4666`            |
| `WS_PORT`              | Port d'écoute du serveur WebSocket.                         | `5001`            |
| `API_URI`              | URL publique complète de l'API.                             | -                 |
| `CLIENT_URI`           | URL publique complète de l'application cliente (front-end). | -                 |
| `ODIN_API_URL`         | URL pour l'API ODIN.                                        | -                 |
| `LICENCE` ou `LICENSE` | Clé de licence de l'application.                            | -                 |

## 4. Services Internes

Configuration des connexions aux services et bases de données dont l'application dépend.

### Base de Données (PostgreSQL)

| Variable       | Description                                                      | Exemple de format                               |
| :------------- | :--------------------------------------------------------------- | :---------------------------------------------- |
| `DATABASE_URL` | Chaîne de connexion complète pour la base de données PostgreSQL. | `postgresql://USER:PASSWORD@HOST:PORT/DATABASE` |

### Redis

Utilisé pour le cache, la gestion des sessions et les files d'attente.

| Variable         | Description                                         |
| :--------------- | :-------------------------------------------------- |
| `REDIS_HOST`     | Hôte du serveur Redis.                              |
| `REDIS_PORT`     | Port du serveur Redis.                              |
| `REDIS_PASSWORD` | (Optionnel) Mot de passe pour la connexion à Redis. |

### ChromaDB (Vector Store)

Base de données vectorielle utilisée pour stocker et rechercher des embeddings.

| Variable         | Description                          |
| :--------------- | :----------------------------------- |
| `CHROMA_HOST`    | Hôte de l'instance ChromaDB.         |
| `CHROMA_API_KEY` | (Optionnel) Clé d'API pour ChromaDB. |

### Meilisearch (Moteur de Recherche)

Moteur de recherche utilisé pour l'indexation et la recherche plein texte.

| Variable           | Description                                                  |
| :----------------- | :----------------------------------------------------------- |
| `MEILI_HOST`       | Hôte de l'instance Meilisearch.                              |
| `MEILI_MASTER_KEY` | (Optionnel) Clé maître pour l'administration de Meilisearch. |

---

## 5. Stockage Cloud

Configuration pour le stockage de fichiers (documents, etc.). **Vous ne devez configurer qu'un seul fournisseur : soit AWS S3, soit Azure Storage.**

| Variable            | Description                                             |
| :------------------ | :------------------------------------------------------ |
| `CLOUD_BUCKET_NAME` | Nom du bucket (S3) ou du conteneur (Azure) de stockage. |

### AWS S3

| Variable                   | Description                                                                |
| :------------------------- | :------------------------------------------------------------------------- |
| `AWS_S3_ACCESS_KEY_ID`     | ID de la clé d'accès AWS.                                                  |
| `AWS_S3_SECRET_ACCESS_KEY` | Clé d'accès secrète AWS.                                                   |
| `AWS_S3_ENDPOINT`          | Endpoint du service S3 (requis, ex: `https://s3.eu-west-3.amazonaws.com`). |
| `AWS_S3_REGION`            | (Optionnel) Région AWS du bucket.                                          |
| `AWS_S3_DOMAIN`            | (Optionnel) Domaine personnalisé pour l'accès aux fichiers.                |

### Azure Storage

| Variable                     | Description                           |
| :--------------------------- | :------------------------------------ |
| `AZURE_CLIENT_ID`            | ID Client de l'application Azure.     |
| `AZURE_CLIENT_SECRET`        | Secret client de l'application Azure. |
| `AZURE_TENANT_ID`            | ID du Tenant (annuaire) Azure.        |
| `AZURE_STORAGE_ACCOUNT_NAME` | Nom du compte de stockage Azure.      |
| `AZURE_STORAGE_ACCOUNT_KEY`  | Clé d'accès du compte de stockage.    |

## 6. Configuration des Modèles d'IA (LLM)

Ces variables configurent les connexions aux modèles de langage pour la génération de texte, les embeddings, et l'utilisation d'outils.

**Note :** L'application supporte une nouvelle méthode de configuration via une variable JSON unique (`_JSON`), mais reste rétrocompatible avec les anciennes variables individuelles. **La méthode JSON est recommandée.**

Cette variable permet de restreindre l'utilisation des modèles d'IA.

| Variable                | Description                                                                                                                                                                                                                                                                                                        | Valeur par défaut |
| :---------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :---------------- |
| `USE_ONLY_CUSTOM_MODEL` | Si définie à `true`, l'application utilisera **uniquement** les modèles personnalisés fournis via les variables `..._JSON`. Aucun modèle par défaut ou pré-configuré ne sera disponible. C'est utile pour forcer l'usage de modèles spécifiques (ex: auto-hébergés) pour des raisons de sécurité ou de conformité. | `false`           |

### Modèle d'Embedding

Utilisé pour transformer le texte en vecteurs numériques.

- **Nouvelle méthode (recommandée)**
  | Variable | Description |
  | :--- | :--- |
  | `EMBEDDING_JSON` | Un objet JSON (sous forme de chaîne de caractères) contenant la configuration complète du modèle d'embedding (modèle, clé API, baseURL, etc.). |
  | `EMBEDDING_INDEX_JSON` | (Optionnel) Idem, mais pour un modèle d'embedding spécifique à l'indexation. |
- **Ancienne méthode (obsolète)**
  | Variable | Description |
  | :--- | :--- |
  | `DEVANA_EMBEDDINGS_APIKEY` | Clé API pour le service d'embedding. |
  | `DEVANA_EMBEDDINGS_HOST` | URL de base du service d'embedding. |
  | `DEVANA_EMBEDDINGS_MODEL` | Nom du modèle d'embedding. |
  | `...` | Variables similaires pour le modèle d'indexation (`..._INDEX_...`). |

### Modèle pour les Outils (ToolModel)

Modèle de langage capable d'appeler des fonctions (outils).

- **Nouvelle méthode (recommandée)**
  | Variable | Description |
  | :--- | :--- |
  | `TOOLMODEL_JSON`| (Optionnel) Un objet JSON (sous forme de chaîne de caractères) contenant la configuration du ToolModel. |
- **Ancienne méthode (obsolète)**
  | Variable | Description |
  | :--- | :--- |
  | `TOOLMODEL_API_KEY` | Clé API pour le service du ToolModel. |
  | `TOOLMODEL_BASE_URL` | URL de base du service du ToolModel. |
  | `TOOLMODEL_MODEL` | Nom du modèle. |

---

## 7. Fournisseurs de Données (Providers)

Gestion de l'accès aux différentes sources de données (ex: SharePoint, Jira).

| Variable                             | Description                                                                                                                          | Valeur par défaut |
| :----------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------- | :---------------- |
| `ALLOW_PROVIDER_MULTIACCOUNT_ACCESS` | (Optionnel) Permet à un utilisateur de se connecter à plusieurs comptes pour un même fournisseur (ex: plusieurs comptes SharePoint). | `false`           |
| `AUTO_DELETE_FILES_PROVIDERS`        | (Optionnel) Supprime automatiquement les fichiers importés par les fournisseurs après traitement dans le bucket du client.           | `false`           |

---

## 8. Serveur Mail (SMTP)

Configuration du serveur SMTP pour l'envoi d'e-mails transactionnels (tous optionnels).

| Variable        | Description                                        |
| :-------------- | :------------------------------------------------- |
| `MAIL_HOST`     | Hôte du serveur SMTP.                              |
| `MAIL_PORT`     | Port du serveur SMTP.                              |
| `MAIL_SECURE`   | Utiliser une connexion sécurisée (`true`/`false`). |
| `MAIL_USER`     | Nom d'utilisateur pour l'authentification SMTP.    |
| `MAIL_PASS`     | Mot de passe pour l'authentification SMTP.         |
| `SUPPORT_EMAIL` | Adresse e-mail affichée pour le support.           |

---

## 9. Proxy

Configuration d'un proxy pour les requêtes HTTP/HTTPS sortantes (tous optionnels).

| Variable      | Description                                                             |
| :------------ | :---------------------------------------------------------------------- |
| `HTTP_PROXY`  | URL du proxy pour les requêtes HTTP.                                    |
| `HTTPS_PROXY` | URL du proxy pour les requêtes HTTPS.                                   |
| `LLM_PROXY`   | URL d'un proxy spécifique pour les appels aux modèles de langage (LLM). |

---

## 10. Configuration Technique Avancée (RAG & Performance)

Paramètres de bas niveau pour ajuster le comportement du RAG (Retrieval-Augmented Generation) et les limites de traitement.

| Variable                              | Description                                                           | Valeur par défaut |
| :------------------------------------ | :-------------------------------------------------------------------- | :---------------- |
| `EMBEDDING_MAXIMAL_SCORE`             | Score de similarité maximal pour considérer un chunk comme pertinent. | `1`               |
| `MAX_TOKENS_TOOLS_CALLBACK`           | Nombre maximum de tokens pour le retour des outils.                   | `20000`           |
| `DEFAULT_EXTRACT_FILE_MAX_BATCH_SIZE` | Nombre de fichiers traités en parallèle lors de l'extraction.         | `3`               |

### Paramètres spécifiques au RAG

| Variable                         | Description                                                       | Valeur par défaut |
| :------------------------------- | :---------------------------------------------------------------- | :---------------- |
| `RAG_ABSOLUTE_MAX_TOKENS`        | Limite absolue de tokens pour le contexte du modèle.              | `120000`          |
| `RAG_ESTIMATED_TOKENS_PER_CHUNK` | Estimation du nombre de tokens par chunk de document.             | `600`             |
| `RAG_MAX_ATTACHMENTS_PER_PAGE`   | Nombre maximum de pièces jointes par page.                        | `3`               |
| `RAG_MAX_CHUNK_SIZE`             | Taille maximale d'un chunk de texte (en caractères).              | `2000`            |
| `RAG_MAX_HISTORY_MESSAGES`       | Nombre maximum de messages dans l'historique de conversation.     | `50`              |
| `RAG_MAX_HISTORY_TOKENS`         | Nombre maximum de tokens alloués à l'historique.                  | `1000`            |
| `RAG_MAX_PAGES`                  | Nombre maximum de pages de documents à récupérer.                 | `10`              |
| `RAG_SAFETY_MARGIN`              | Marge de sécurité (ex: 0.85 pour 85%) pour le calcul du contexte. | `0.85`            |
| `RAG_XML_OVERHEAD`               | Estimation du surcoût en tokens lié au formatage XML.             | `500`             |

---

## Odin (Service de traitement)

## 1. Services de Base

Configuration des connexions aux services et bases de données fondamentaux dont l'application dépend.

### Base de Données (PostgreSQL)

| Variable       | Description                                                                                                                                                |
| :------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| `DATABASE_URL` | Chaîne de connexion complète pour la base de données PostgreSQL, incluant l'utilisateur, le mot de passe, l'hôte, le port, le nom de la base et le schéma. | `postgresql://USER:PASSWORD@HOST:PORT/DATABASE?schema=SCHEMA` |

### Redis

Utilisé pour la mise en cache, la gestion des files d'attente et d'autres tâches en arrière-plan.

| Variable         | Description                                         |
| :--------------- | :-------------------------------------------------- |
| `REDIS_HOST`     | Hôte du serveur Redis.                              |
| `REDIS_PORT`     | Port d'écoute du serveur Redis.                     |
| `REDIS_PASSWORD` | (Optionnel) Mot de passe pour la connexion à Redis. |

---

## 2. Stockage Fichiers (Compatible S3)

Configuration pour le stockage d'objets (documents, images, etc.). Le système est compatible avec AWS S3 ou des solutions auto-hébergées comme Minio.

| Variable        | Description                                                                                                  |
| :-------------- | :----------------------------------------------------------------------------------------------------------- |
| `S3_BUCKET`     | Nom du bucket où les fichiers seront stockés.                                                                |
| `S3_ACCESS_KEY` | Clé d'accès (Access Key ID) pour le service S3.                                                              |
| `S3_SECRET_KEY` | Clé secrète (Secret Access Key) pour le service S3.                                                          |
| `S3_ENDPOINT`   | URL complète du service S3.                                                                                  |
| `S3_REGION`     | Région du bucket (ex: `eu-west-3`).                                                                          |
| `S3_PUBLIC_URL` | (Optionnel) URL publique de base pour accéder directement aux fichiers stockés, si différente de l'endpoint. |

---

## 3. Services Applicatifs

Configuration des points d'accès (URL) pour les services internes ou externes dont l'application dépend.

| Variable         | Description                                                                                    |
| :--------------- | :--------------------------------------------------------------------------------------------- |
| `DEVANA_API_URL` | URL interne de l'API principale, utilisée pour la communication entre services.                |
| `GOTENBERG_URL`  | URL de l'instance Gotenberg, utilisée pour la conversion de documents (ex: génération de PDF). |

---

## 4. Modèle d'IA (LLM)

Configuration de la connexion au modèle de langage (Large Language Model) utilisé pour la vision et la génération de texte.

| Variable      | Description                                                                           |
| :------------ | :------------------------------------------------------------------------------------ |
| `LLM_API_URL` | URL du point d'accès (endpoint) de l'API du LLM (ex: Ollama, TGI, OpenAI compatible). |
| `LLM_API_KEY` |
| `LLM_MODEL`   |

---

## Sharepoint
Paramètres spécifiques pour l'intégration avec SharePoint en tant que fournisseur de données.
| Variable                   | Description                                         |
| :------------------------- | :-------------------------------------------------- |
| `ASPX_ENABLE_ALT_FIRST`     | Active l'option de récupération textuel de l'image au lieu de son contenu binaire. Par défaut, le contenu binaire est récupéré. |

## 6. Sécurité & Réseau

Paramètres de configuration liés à la sécurité du réseau et aux certificats.

| Variable              | Description                                                                                                                                                                       | Exemple         |
| :-------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------------- |
| `NODE_EXTRA_CA_CERTS` | (Optionnel) Chemin d'accès à un fichier de certificats d'autorité (CA) supplémentaires. Utile pour les environnements d'entreprise utilisant des certificats TLS/SSL auto-signés. | `/certs/ca.crt` |

---

## Frontend

Ce document détaille les variables d'environnement requises pour le fonctionnement de l'application front-end (Next.js).

## 1. Sécurité et Authentification

Ces variables sont cruciales pour la sécurité de l'application, notamment pour la gestion des sessions utilisateur et la validation des jetons d'authentification. Elles doivent être gardées secrètes.

| Variable          | Description                                                                                                                                                             |
| :---------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `JWT_SECRET_KEY`  | Clé secrète utilisée pour signer et vérifier les JSON Web Tokens (JWT). Elle garantit que les jetons n'ont pas été altérés.                                             |
| `NEXTAUTH_SECRET` | Clé secrète requise par **NextAuth.js** pour chiffrer les cookies de session et les jetons JWT. **Cette variable est critique pour la sécurité de l'authentification.** |

---

## 2. Configuration de l'API

Cette variable définit le point d'accès au serveur back-end, permettant au front-end de communiquer avec lui pour récupérer ou envoyer des données.

| Variable  | Description                                                                                                                                                           |
| :-------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `API_URL` | URL complète du serveur API back-end. Cette URL est principalement utilisée par le serveur Next.js (pour le rendu côté serveur - SSR) afin de communiquer avec l'API. |
