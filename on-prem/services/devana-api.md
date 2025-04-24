# Devana API Service

Le service API de Devana est une API REST+GraphQL qui permet de gérer l'ensemble des fonctionnalités de l'application.

## Installation

Pour installer le service API de Devana, vous devez disposer des éléments suivants :

- Un cluster Kubernetes (version 1.19 ou supérieure) avec au moins 3 nœuds
- Une base de données PostgreSQL (version 12 ou supérieure)
- Un serveur de fichiers S3 compatible
- Un serveur Redis (version 6 ou supérieure)

Avant de procéder à l'installation de Devana, assurez-vous que votre infrastructure remplit ces conditions et que vous disposez des accès et autorisations nécessaires pour créer et gérer les ressources sur votre plateforme de cloud.

## Recommandations de performance par pod

Pour garantir des performances optimales de l'application Devana, il est important de dimensionner correctement les ressources allouées à chaque pod.

- CPU : **4 vCPU**
- RAM : **4 Go**
- Disque : **10 Go**

> Nous recommandons d'utiliser un réplica set de minimum 2 pods pour garantir la haute disponibilité.

## Prérequis

Pour pouvoir récupérer l'image Docker de l'API de Devana, vous devez disposer d'un compte sur le registre Docker de Devana. Pour obtenir vos identifiants, contactez le support technique de Devana (support-it@devana.ai).

## Configuration

Le service API de Devana peut être configuré via les variables d'environnement suivantes :

- `API_PORT` : Port d'écoute de l'API (par défaut : 3000)
- `API_HOST` : Adresse d'écoute de l'API (par défaut : 0.0.0.0)
- `DATABASE_URL` : URL de connexion à la base de données PostgreSQL (format : `postgresql://user:password@host:port/database`)
- `REDIS_URL` : URL de connexion au serveur Redis (format : `redis://user:password@host:port`)
- `S3_ENDPOINT` : URL du serveur S3 compatible (par exemple : `https://s3.amazonaws.com`)
- `S3_ACCESS_KEY` : Clé d'accès au serveur S3
- `S3_SECRET_KEY` : Clé secrète d'accès au serveur S3
- `S3_BUCKET` : Nom du bucket S3 à utiliser pour le stockage des fichiers
- `JWT_SECRET` : Clé secrète utilisée pour signer les tokens JWT (JSON Web Tokens)
- `OPENAI_API_KEY` : Clé d'API OpenAI (nécessaire pour utiliser les fonctionnalités d'IA)
- `OPENAI_API_URL` : URL de l'API OpenAI (par défaut : `https://api.openai.com`)
- `OPENAI_MODEL` : Modèle d'IA OpenAI à utiliser (par défaut : `gpt-3.5-turbo`)
- `ENABLE_PROXY` : Activer ou désactiver l'utilisation d'un proxy pour les requêtes sortantes (par défaut : `false`)
- `HTTP_PROXY`: Proxy HTTP à utiliser pour les requêtes sortantes
- `HTTPS_PROXY`: Proxy HTTPS à utiliser pour les requêtes sortantes
- `NO_PROXY`: Liste des adresses IP ou noms de domaine à exclure des proxies (séparés par des virgules)
- `PROXY_FORCE_HTTP`: Forcer l'utilisation du proxy HTTP pour toutes les requêtes sortantes qui sont normalement en HTTPS (par défaut : `false`)
- `MAX_TOKENS_TOOLS_CALLBACK` : Nombre maximum de tokens à retourner lors de l'appel aux outils ajoutés par l'utilisateur (par défaut : 20 000 tokens)
- `TOOLMODEL_MODEL` : Modèle LLM à utiliser pour l'appel des outils
- `TOOLMODEL_API_KEY` : Clé d'API pour le LLM d'appel aux outils
- `TOOLMODEL_BASE_URL` : URL de base pour le LLM qui s'occupe des appels d'outils
- `DEVANA_EMBEDDINGS_INDEX_MODEL` : Modèle LLM à utiliser pour l'indexation des embeddings
- `DEVANA_EMBEDDINGS_INDEX_APIKEY` : Clé d'API pour le LLM d'indexation des embeddings
- `DEVANA_EMBEDDINGS_INDEX_HOST` : URL de base pour le LLM qui s'occupe de l'indexation des embeddings
- `SCALEWAY_API_KEY` : Clé d'API Scaleway pour l'inférence LLM
- `ENCRYPTION_KEY` : [On-Prem] Permet le chiffrement des identifiants pour les configurations Sharepoint On-Premises
  - Longueur de la clé :La longueur de la clé doit correspondre à une des tailles acceptées par l'AES (128, 192 ou 256 bits).
    - AES-128: nécessite une clé de 128 bits (16 octets).
    - AES-192: nécessite une clé de 192 bits (24 octets).
    - AES-256: nécessite une clé de 256 bits (32 octets).
- `SKIP_LIBRARY` : [On-Prem & Cloud] Tableau de bibliothèque Sharepoint à scopé pour les sites Sharepoint. `Exemple: ["Documents", "Site Pages", "Pages"]`
- `GOOGLE_CLIENT_ID` : [Cloud]	L'identifiant client de votre application Google Drive	
- `GOOGLE_CLIENT_SECRET` : [Cloud] Le secret client de votre application Google Drive
- `DROPBOX_CLIENT_ID` : [Cloud]	L'identifiant client de votre application Dropbox	
- `DROPBOX_CLIENT_SECRET` : [Cloud] Le secret client de votre application Dropbox	
- `MICROSOFT_CLIENT_ID` : [Cloud] L'identifiant client de votre application Microsoft OneDrive	
- `MICROSOFT_CLIENT_SECRET` : [Cloud] Le secret client de votre application Microsoft OneDrive	
- `OAUTH_CALLBACK_URI` : [Cloud] L'URL de redirection pour gérer l'authentification	
- `JIRA_CLIENT_ID` : [Cloud] L'identifiant client de votre application Jira	
- `JIRA_CLIENT_SECRET` : [Cloud] Le secret client de votre application Jira
- ... (d'autres variables d'environnement peuvent être nécessaires en fonction de la configuration de votre application)
- `ALLOW_PROVIDER_MULTIACCOUNT_ACCESS` : [On-Prem] Permet de gérer les accès multi-compte pour les fournisseurs de stockage cloud. (par défaut : `false`)

## Déploiement

Pour déployer le service API de Devana sur votre cluster Kubernetes, suivez les étapes ci-dessous :

1. Créez un namespace dédié à Devana :

```bash
kubectl create namespace devana
```

2. Créez un secret Kubernetes pour stocker les identifiants du registre Docker de Devana :

```bash
kubectl create secret docker-registry devana-registry \
  --docker-server=registry.devana.ai \
  --docker-username=<votre-nom-utilisateur> \
  --docker-password=<votre-mot-de-passe> \
  --namespace=devana
```

3. Appliquez les fichiers de configuration sur votre cluster Kubernetes :

```bash
kubectl apply -f ./kube/devana/devana-api.yml
```

4. Vérifiez que les pods sont bien démarrés et en cours d'exécution :

```bash
kubectl get pods -n devana-production
```

5. Exposez le service API de Devana en créant une ressource Ingress ou en utilisant un LoadBalancer, en fonction de votre configuration Kubernetes.

## Conclusion

Vous avez maintenant déployé le service API de Devana sur votre cluster Kubernetes. Les pods sont configurés avec les ressources recommandées et le service est exposé pour être accessible depuis l'extérieur du cluster.

N'oubliez pas de configurer correctement les secrets Kubernetes pour stocker les informations sensibles telles que les identifiants de base de données, les clés d'API, etc.

Si vous rencontrez des problèmes lors du déploiement ou de l'utilisation du service API de Devana, n'hésitez pas à contacter notre équipe de support technique à l'adresse support-it@devana.ai.
