Genkins et GitLab pour le déploiement des yml

- > Build application (varification + set env) équivalent a helm
- > Si ok -> s'occupe de faire matcher les variables d'env
- > Excemitle pour les secrets
- > Teraform
- > API KEY pour le blob

##

# Url d'env

- **Api** : https://devana-api.{{bil.environment}}.openshift.bnet.luxds.net
- **Websocket** : https://devana-ws.{{bil.environment}}.openshift.bnet.luxds.net
- **Front** : https://devana.{{bil.environment}}.openshift.bnet.luxds.net

**Env : tst, uat, prd**

## Ouvertures

- Routes openshift
  - Firewall / Routages OK en téhorique
- SSL
  - Openshift qui gère les certificats dans l'ingress
  - Peut-etre un problème de timeout

# Sharepoint / NTFS

- Network OK ?
- Authentification Sharepoint -> Besoin de récupérer les éléments d'auth
  -> Besoin d'un compte de service

# Déploy

1. Configuration dans gitlab
2. A chaque push -> Build jenkins (check les fichiers yml) (helm)
3. Digital.AI déploy -> Match des envs / Vérif + Déploy
4. Déploiement dans openshift

# Config BIL

## Redis

### Performances

- 0.100 cpu
- 128 Ram

### Autres

- Version : dommgifer/redis-5-rhel7:202303

> [!ATTENTION] > **Note** : L'arg required passord pas ajoutée, uniquement la var d'environnement si pb d'accès après.

## PGSQL

### Performances

- 2 vcpu / 100 cpu
- 4 go de ram / 2go request
- Replica : Taff sur le replica
- 100 Go de disque

### Envs

- DB_NAME: devana
- HOST: davana-pgsql-service

### Autres

- 17-4 Alpine

> [!ATTENTION] > **Note** : Reco pour slave master

## Chroma

- 2vcpu
- 3Go de ram > \* 2 pour la prod

## Front

- 800
- 1go de ram
- CPU request 0.2
- Memory request 108

## Sharepoint

- On recupère quoi au niveau des metadata sur sharepoint voir avec @thomas
- Création des comptes CA en cours pour l'UAT et la prod

## Meilisearch

### Performances

- 500m
- 100m
- 512Gi
- 256Mi

### Version :

v1.13.3-nr

### Gotenberg

- 1.5cpu
- 1go de ram

### Version

- 8.18.0

### Port

- 3000
