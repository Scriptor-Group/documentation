Voici la documentation augmentée avec plus de détails sur le déploiement des services de Devana sur Kubernetes :

# Déploiement

Comment déployer les services de Devana sur Kubernetes.

## Prérequis

### Créer le Secret Docker Registry

Exécutez la commande suivante pour créer un secret nommé `regcred` (vous pouvez changer le nom si nécessaire) :

```
kubectl create secret docker-registry regcred \
  --docker-server=registry.devana.ai \
  --docker-username=<YOUR_USERNAME> \
  --docker-password=<YOUR_PASSWORD> \
  --docker-email=<YOUR_EMAIL> \
  --namespace=<NAMESPACE>
```

Remplacez `<YOUR_USERNAME>`, `<YOUR_PASSWORD>` et `<YOUR_EMAIL>` par vos identifiants de connexion au registre Docker de Devana (contactez le support technique de Devana si vous ne les avez pas).

Remplacez `<NAMESPACE>` par le namespace dans lequel vous souhaitez déployer les services de Devana.

### Créer le Cluster Issuer

Exécutez la commande suivante pour créer un Cluster Issuer nommé `letsencrypt-prod` :

```
kubectl apply -f issuer/letsencrypt-prod-issuer.yaml
```

Assurez-vous d'avoir le fichier `letsencrypt-prod-issuer.yaml` dans le répertoire `issuer/`.

### Personnaliser les fichiers de configuration

Personnalisez les fichiers de configuration des services de Devana en fonction de vos besoins. Vous pouvez modifier les variables d'environnement, les volumes, les ressources, etc.

Vous trouverez le fichier de secrets dans `secrets/secrets.yaml`. Assurez-vous de mettre à jour les valeurs des secrets avec les informations appropriées.

## Déploiement

### Secrets

Pour déployer les secrets de Devana, exécutez la commande suivante :

```
kubectl apply -f secrets/secrets.yaml
```

Assurez-vous d'avoir le fichier `secrets.yaml` dans le répertoire `secrets/`.

### API

Pour déployer le service API de Devana, exécutez la commande suivante :

```
kubectl apply -f api/api-deployment.yaml
```

Assurez-vous d'avoir le fichier `api-deployment.yaml` dans le répertoire `api/`.

Liste des variables d'environnement disponibles pour le service API :
- `LICENCE` : La licence de l'API Devana.
- `PORT` : Le port sur lequel l'API doit écouter.
- `EMBEDDING` : Le type d'embedding à utiliser (par exemple, "openai", "cohere", etc.).
- `APPLICATION_URL` : L'URL de l'application Devana.
- `API_URI` : L'URI de l'API Devana.
- `PDF_TO_WORD_SERVER` : L'URL du serveur de conversion PDF vers Word.
- `JWT_SECRET_KEY` : La clé secrète utilisée pour signer les jetons JWT.
- `DATABASE_URL` : L'URL de la base de données.
- `CHROMA_HOST` : L'hôte du service Chroma.
- `REDIS_HOST` : L'hôte du service Redis.
- `REDIS_PORT` : Le port du service Redis.
- `REDIS_PASSWORD` : Le mot de passe du service Redis.
- `OPENAI_API_KEY` : La clé API d'OpenAI.
- `DEEPL_KEY` : La clé API de DeepL.
- `ANTHROPIC_API_KEY` : La clé API d'Anthropic.
- `MISTRAL_API_KEY` : La clé API de Mistral.
- `GROQ_API_KEY` : La clé API de Groq.
- `GEMINI_API_KEY` : La clé API de Gemini.
- `MAILJET_TEMPLATE_ID` : L'ID du modèle Mailjet.
- `MAILJET_APIKEY_PUBLIC` : La clé API publique de Mailjet.
- `MAILJET_APIKEY_PRIVATE` : La clé API privée de Mailjet.
- `AWS_BEDROCK_ACCESS_KEY_ID` : L'ID de clé d'accès AWS Bedrock.
- `AWS_BEDROCK_SECRET_ACCESS_KEY` : La clé d'accès secrète AWS Bedrock.
- `AWS_S3_ACCESS_KEY_ID` : L'ID de clé d'accès AWS S3.
- `AWS_S3_ENPOINT` : Le point de terminaison AWS S3.
- `AWS_S3_REGION` : La région AWS S3.
- `AWS_S3_SECRET_ACCESS_KEY` : La clé d'accès secrète AWS S3.
- `SEARCH_API_KEY` : La clé API de recherche.
- `CRAWLBASE_TOKEN` : Le jeton Crawlbase.
- `TOKEN_METRICS` : Les métriques de jeton.
- `GOOGLE_APPLICATION_CLIENT_EMAIL` : L'e-mail du client d'application Google.
- `GOOGLE_APPLICATION_PRIVATE_KEY` : La clé privée de l'application Google.
- `CLIENT_URI` : L'URI du client.
- `GOOGLE_CLIENT_ID` : L'ID client Google.
- `GOOGLE_CLIENT_SECRET` : Le secret client Google.
- `DROPBOX_CLIENT_ID` : L'ID client Dropbox.
- `DROPBOX_CLIENT_SECRET` : Le secret client Dropbox.
- `MICROSOFT_CLIENT_ID` : L'ID client Microsoft.
- `MICROSOFT_CLIENT_SECRET` : Le secret client Microsoft.
- `OAUTH_CALLBACK_URI` : L'URI de rappel OAuth.
- `MICROSOFT_TENANT_ID` : L'ID de locataire Microsoft.

### Autres services

Suivez les mêmes étapes pour déployer les autres services de Devana, tels que le service d'authentification, le service de stockage, etc. Assurez-vous d'avoir les fichiers de déploiement correspondants dans leurs répertoires respectifs.

## Vérification

Une fois le déploiement terminé, vous pouvez vérifier l'état des pods en exécutant la commande suivante :

```
kubectl get pods -n <NAMESPACE>
```

Remplacez `<NAMESPACE>` par le namespace dans lequel vous avez déployé les services de Devana.

Assurez-vous que tous les pods sont dans l'état "Running" et qu'il n'y a pas d'erreurs.

## Accès aux services

Pour accéder aux services déployés, vous pouvez utiliser les commandes `kubectl port-forward` ou créer des services Kubernetes de type LoadBalancer ou NodePort.

Par exemple, pour accéder au service API en utilisant `port-forward`, exécutez la commande suivante :

```
kubectl port-forward svc/api 8080:80 -n <NAMESPACE>
```

Remplacez `<NAMESPACE>` par le namespace dans lequel vous avez déployé les services de Devana.

Vous pouvez maintenant accéder à l'API Devana à l'adresse `http://localhost:8080`.

N'hésitez pas à personnaliser davantage la documentation en fonction des spécificités de votre environnement et des services de Devana que vous déployez.