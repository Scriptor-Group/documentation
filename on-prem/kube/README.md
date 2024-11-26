# Documentation de Déploiement Devana sur Kubernetes

Ce document détaille le processus complet de déploiement des services Devana sur Kubernetes.

## Table des matières
- [Prérequis](#prérequis)
- [Configuration des Variables d'Environnement](#configuration-des-variables-denvironnement)
- [Déploiement](#déploiement)
- [Vérification](#vérification)
- [Accès aux Services](#accès-aux-services)

## Prérequis

### Créer le Secret Docker Registry

Exécutez la commande suivante pour créer un secret nommé `regcred` :

```bash
kubectl create secret docker-registry regcred \
  --docker-server=registry.devana.ai \
  --docker-username=<YOUR_USERNAME> \
  --docker-password=<YOUR_PASSWORD> \
  --docker-email=<YOUR_EMAIL> \
  --namespace=<NAMESPACE>
```

Remplacez les valeurs `<YOUR_USERNAME>`, `<YOUR_PASSWORD>`, `<YOUR_EMAIL>` et `<NAMESPACE>` par vos informations d'identification pour le registre Docker de Devana.

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

### 2. Déploiement de l'API

Déployez le service API :

```bash
kubectl apply -f api/api-deployment.yaml
```

### 3. Déploiement des Services Additionnels

Déployez les autres services nécessaires dans l'ordre suivant :

```bash
kubectl apply -f database/
kubectl apply -f redis/
kubectl apply -f storage/
kubectl apply -f worker/
```

## Vérification

Vérifiez l'état des pods :

```bash
kubectl get pods -n <NAMESPACE>
```

Vérifiez les logs des pods en cas d'erreur :

```bash
kubectl logs <POD_NAME> -n <NAMESPACE>
```

## Accès aux Services

### Port-Forward Local

Pour accéder localement aux services :

```bash
# API
kubectl port-forward svc/api 8080:80 -n <NAMESPACE>

# Base de données
kubectl port-forward svc/postgres 5432:5432 -n <NAMESPACE>

# Redis
kubectl port-forward svc/redis 6379:6379 -n <NAMESPACE>
```

### Configuration des Ingress

Pour exposer les services publiquement, assurez-vous que vos ingress sont correctement configurés dans le fichier `ingress/ingress.yaml` et appliquez-les :

```bash
kubectl apply -f ingress/ingress.yaml
```

## Support et Maintenance

### Logs et Monitoring

Consultez les logs des services :

```bash
kubectl logs -f deployment/api -n <NAMESPACE>
```

### Mise à jour des Services

Pour mettre à jour un service :

```bash
kubectl rollout restart deployment <SERVICE_NAME> -n <NAMESPACE>
```

### Scaling

Pour ajuster le nombre de réplicas :

```bash
kubectl scale deployment <SERVICE_NAME> --replicas=<NUMBER> -n <NAMESPACE>
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

Pour toute assistance supplémentaire, contactez le support technique de Devana.
