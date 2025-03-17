# Documentation de Déploiement Devana sur Kubernetes

Ce document détaille le processus complet de déploiement des services Devana sur Kubernetes.

:warning: les services ne sont pas encore à jour pour prendre en compte l'ajout prochain de Odin aka le nouveau micro-service de parsing de documents.

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
