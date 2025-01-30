# Documentation de Déploiement Devana sur Kubernetes

Ce document détaille le processus complet de déploiement des services Devana sur Kubernetes.

## Table des matières
- [Prérequis](#prérequis)
- [Configuration des Variables d'Environnement](#configuration-des-variables-denvironnement)
- [Déploiement](#déploiement)
- [Vérification](#vérification)
- [Résolution des Problèmes Courants](#résolution-des-problèmes-courants)

## Prérequis

### Technologies nécessaires
Pour déployer Devana sur un cluster Kubernetes ou OpenShift, vous devez disposer du CLI approprié :

- kubectl pour Kubernetes
- oc pour OpenShift
Assurez-vous que votre CLI (kubectl ou oc) est configurée pour se connecter à votre cluster et que vous disposez des autorisations nécessaires (souvent un compte administrateur ou un compte avec des droits suffisants sur le namespace ciblé).

:warning: Pour le cas d'OpenShift, il faut au préalable autoriser la politique de sécurité `anyuid` dans votre projet. Cela peut se faire avec la commande suivante : 

`oc adm policy add-scc-to-user anyuid -z default -n $(oc project -q)`

### Créer le Secret Docker Registry

Exécutez la commande suivante pour créer un secret permettant de récupérer les images depuis le registre Devana :

```bash
kubectl create secret docker-registry devana-registry \
  --docker-server=registry.devana.ai \
  --docker-username=<YOUR_USERNAME> \
  --docker-password=<YOUR_PASSWORD> \
```

Remplacez les valeurs `<YOUR_USERNAME>` et `<YOUR_PASSWORD>` par vos informations d'identification pour le registre Docker de Devana.

>**Remarque :**
>- Si vous utilisez OpenShift, la même commande oc apply -f ... peut s’utiliser.

### Créer le Cluster Issuer

Pour configurer les certificats SSL, créez un Cluster Issuer :

```bash
kubectl apply -f issuer/letsencrypt-prod-issuer.yaml
```

## Configuration des Variables d'Environnement

### Configuration Générale
- `LICENCE` : Licence de l'API Devana
- `PORT` : Port d'écoute de l'API
- `APPLICATION_URL` : URL principale de l'application
- `CLIENT_URI` : URI du client
- `API_URI` : URI de l'API
- `API_CORE_KEY` : Clé API core
- `JWT_SECRET_KEY` : Clé secrète pour la signature des tokens JWT
- `GRAPHQL_INTROSPECTION` : Active/désactive l'introspection GraphQL
- `ENABLE_SYNC_ACCOUNTS` : Active/désactive la synchronisation des comptes
- `HOSTED_BY_DEVANA` : Indique si l'instance est hébergée par Devana
- `RUN_CRON` : Active/désactive les tâches cron

### Services de Traitement
- `PDF_TO_WORD_SERVER` : URL du service de conversion PDF vers Word
- `IMAGE_TO_IMAGE_SERVER` : URL du service de traitement d'images
- `TEXT_TO_IMAGE_SERVER` : URL du service de génération d'images

### Base de Données et Stockage
- `DATABASE_URL` : URL de connexion à la base de données
- `CHROMA_HOST` : Hôte du service Chroma
- `CHROMA_API_KEY` : Clé API pour Chroma
- `REDIS_HOST` : Hôte Redis
- `REDIS_PORT` : Port Redis
- `REDIS_PASSWORD` : Mot de passe Redis
- `MEILI_HOST` : Hôte MeiliSearch
- `MEILI_MASTER_KEY` : Clé maître MeiliSearch

### Services IA et ML
- `EMBEDDING` : Type d'embedding à utiliser
- `OPENAI_API_KEY` : Clé API OpenAI
- `ANTHROPIC_API_KEY` : Clé API Anthropic
- `MISTRAL_API_KEY` : Clé API Mistral
- `GROQ_API_KEY` : Clé API Groq
- `GEMINI_API_KEY` : Clé API Gemini
- `DEVANA_EMBEDDINGS_HOST` : Hôte des embeddings Devana
- `DEVANA_EMBEDDINGS_INDEX_HOST` : Hôte d'index des embeddings
- `DEVANA_EMBEDDINGS_APIKEY` : Clé API embeddings
- `DEVANA_EMBEDDINGS_INDEX_APIKEY` : Clé API index embeddings

### Configuration AWS
- `AWS_BEDROCK_ACCESS_KEY_ID` : ID de clé d'accès AWS Bedrock
- `AWS_BEDROCK_SECRET_ACCESS_KEY` : Clé secrète AWS Bedrock
- `AWS_S3_ACCESS_KEY_ID` : ID de clé d'accès AWS S3
- `AWS_S3_SECRET_ACCESS_KEY` : Clé secrète AWS S3

### Authentification et OAuth
- `NEXTAUTH_URL` : URL NextAuth
- `NEXTAUTH_SECRET` : Secret NextAuth
- `GITHUB_ID` : ID client GitHub
- `GITHUB_SECRET` : Secret client GitHub
- `GOOGLE_ID` : ID client Google
- `GOOGLE_SECRET` : Secret client Google
- `GOOGLE_CLIENT_ID` : ID client Google (OAuth)
- `GOOGLE_CLIENT_SECRET` : Secret client Google (OAuth)
- `FACEBOOK_ID` : ID client Facebook
- `FACEBOOK_SECRET` : Secret client Facebook
- `DROPBOX_CLIENT_ID` : ID client Dropbox
- `DROPBOX_CLIENT_SECRET` : Secret client Dropbox
- `MICROSOFT_CLIENT_ID` : ID client Microsoft
- `MICROSOFT_CLIENT_SECRET` : Secret client Microsoft
- `MICROSOFT_TENANT_ID` : ID tenant Microsoft
- `OAUTH_CALLBACK_URI` : URI de callback OAuth
- `JIRA_CLIENT_ID` : ID client Jira
- `JIRA_CLIENT_SECRET` : Secret client Jira

### Services API et Traduction
- `DEEPL_KEY` : Clé API DeepL
- `GOOGLE_TRANSLATE_API_KEY` : Clé API Google Translate
- `SEARCH_API_KEY` : Clé API de recherche
- `CRAWLBASE_TOKEN` : Token Crawlbase
- `TOKEN_METRICS` : Métriques de token
- `APIDECK_API_KEY` : Clé API Apideck
- `APIDECK_APP_ID` : ID d'application Apideck

### Paiement et Communication
- `STRIPE_SECRET_KEY` : Clé secrète Stripe
- `STRIPE_WEBHOOK_SECRET` : Secret webhook Stripe
- `MAILJET_TEMPLATE_ID` : ID template Mailjet
- `MAILJET_APIKEY_PUBLIC` : Clé API publique Mailjet
- `MAILJET_APIKEY_PRIVATE` : Clé API privée Mailjet

### Configuration Frontend
- `NEXT_PUBLIC_API_URL` : URL API publique
- `NEXT_PUBLIC_GRAPHQL_URL` : URL GraphQL publique
- `NEXT_PUBLIC_WS_URL` : URL WebSocket publique
- `NEXT_PUBLIC_FRONTEND_URL` : URL frontend publique
- `NEXT_PUBLIC_STRIPE_PUBLIC_KEY` : Clé publique Stripe
- `NEXT_PUBLIC_GOOGLE_MAPS_API_KEY` : Clé API Google Maps
- `ENABLE_OPENREPLAY` : Active/désactive OpenReplay

### Monitoring et Debug
- `SENTRY_DSN` : DSN Sentry
- `ADPUB_TOKEN` : Token AdPub
- `KUBE_CONFIG` : Configuration Kubernetes
- `KUBE_NAMESPACE` : Namespace Kubernetes

## Déploiement

### 1. Déploiement des Secrets

Appliquez la configuration des secrets :

```bash
kubectl apply -f secrets/secrets.yaml
```

### 2. Déploiement des Services Additionnels

Déployez les autres services nécessaires dans l'ordre suivant :

```bash
kubectl apply -f devana/devana-meilisearch.yml
kubectl apply -f devana/devana-redis.yml
kubectl apply -f devana/devana-postgres.yml
kubectl apply -f devana/devana-docx.yml
kubectl apply -f devana/devana-vectors.yml
```

### 3. Déploiement de l'API

Déployez le service API :

```bash
kubectl apply -f devana/devana-api.yml
```

### 4. Déploiement du Front-End

Déployez le service Front-End :

```bash
kubectl apply -f devana/devana-front.yml
```

## Vérification

Vérifiez l'état des pods :

```bash
kubectl get pods
```

Vérifiez les logs des pods en cas d'erreur :

```bash
kubectl logs <POD_NAME>
```

## Résolution des Problèmes Courants

1. **Problème de Secret Registry**
   - Vérifiez les credentials du registry
   - Recréez le secret avec les bonnes informations

2. **Problèmes de Connection à la Base de Données**
   - Vérifiez la variable DATABASE_URL
   - Assurez-vous que le service de base de données est en cours d'exécution

3. **Erreurs de Certificats SSL**
   - Vérifiez la configuration du Cluster Issuer
   - Assurez-vous que les domaines sont correctement configurés

4. **Problème avec la license devana**
   - Assurez-vous d'avoir autorisé la connection vers `l.devana.ai`
   - Vérifiez que votre clé de license est valide ainsi que présente et à jour dans le secret registry `secret-devana`.

Pour toute assistance supplémentaire, contactez le support technique de Devana.
