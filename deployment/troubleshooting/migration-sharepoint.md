# Migration SharePoint : Basic Auth vers Kerberos

## Vue d'ensemble

Ce guide détaille la procédure de migration d'un provider SharePoint utilisant l'authentification **Basic Auth** (obsolète) vers l'authentification **Kerberos**. Cette migration est nécessaire pour maintenir la connectivité et la sécurité des intégrations SharePoint.

### Objectif de la migration

L'objectif principal de cette migration est de **changer le type d'authentification sans perdre les travaux existants** liés aux connecteurs SharePoint, notamment :

- ✅ Les bases de connaissances connectées
- ✅ Les agents configurés avec ces connecteurs
- ✅ Les documents indexés
- ✅ Les configurations de dossiers

### Quand effectuer cette migration ?

⚠️ **Important** : Cette migration n'est nécessaire que si :

- ✅ Le ou les comptes de service Kerberos pointent vers **les mêmes ressources SharePoint** que celles actuellement configurées
- ✅ Vous souhaitez conserver les configurations existantes

Si les comptes de service pointent vers **d'autres ressources SharePoint** différentes de celles existantes, cette migration n'a pas lieu d'être. Il est préférable dans ce cas de repartir de zéro.

## Prérequis

Avant de commencer la migration, assurez-vous d'avoir :

- **Accès administrateur** : Droits `ADMIN` ou `SUPER_ADMIN` sur la plateforme
- **Authentification API** : 
  - Une **API Key valide** pour authentifier les requêtes, OU
  - Un **Client OAuth** configuré
- **Configuration Kerberos** :
  - Principal Kerberos
  - Fichier keytab
  - Chemin de cache pour les tickets
  - Service Principal Name (en format GSSAPI)
- **Informations utilisateur** : ID de l'utilisateur concerné par la migration
- **Accès base de données** : Connexion à la base de données Devana

⚠️ **Important** : Cette procédure n'est pas disponible dans les environnements hébergés par Devana (`HOSTED_BY_DEVANA=true`).

## Architecture de migration

La migration se déroule en 3 à 4 étapes selon votre configuration :

1. Mise à jour du type d'authentification du provider
2. Création d'un compte de service Kerberos *(optionnel si un compte existe déjà)*
3. Association du provider au compte Kerberos
4. Mise à jour du domaine du connecteur *(optionnel)*

## Étape 1 : Migrer le provider de Basic vers Kerberos

Cette première étape convertit le type d'authentification du provider SharePoint.

### Endpoint

```
PUT /migration/sharepoint/basic-to-kerberos
```

### Paramètres

| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `userId` | string | ✅ | Identifiant de l'utilisateur possédant le provider |

### Exemple de requête

```bash
curl -X PUT https://server-domain.com/migration/sharepoint/basic-to-kerberos \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "userId": "user-123-abc"
  }'
```

### Réponse succès

```json
{
  "success": true,
  "message": "✅ Migration Kerberos successfully achieved",
  "data": {
    "id": "provider-456-def",
    "oauthType": "KERBEROS"
  }
}
```

### Erreurs possibles

| Code | Message | Cause |
|------|---------|-------|
| 400 | `userId is required` | Paramètre `userId` manquant |
| 404 | `User not found` | L'utilisateur n'existe pas |
| 404 | `No Sharepoint provider found with auth basic deprecated` | Aucun provider SharePoint avec Basic Auth trouvé pour cet utilisateur |
| 500 | `Internal server error` | Erreur serveur |

## Étape 2 : Créer un compte de service Kerberos (optionnel)

> **Note** : Cette étape est **optionnelle** si vous disposez déjà d'un compte de service Kerberos configuré. Dans ce cas, passez directement à l'[Étape 3](#étape-3--connecter-le-provider-au-compte-kerberos).
>
> Vous pouvez vérifier les comptes existants :
> - Via l'endpoint API `GET /v1/sharepoint_svc_kerberos` (voir [Gestion des comptes](#gestion-des-comptes-de-service-kerberos))
> - Directement dans l'application : **Administration** → **Connecteur**

Cette étape configure un nouveau compte de service Kerberos qui sera utilisé pour l'authentification.

### Endpoint

```
POST /migration/sharepoint/kerberos-account-service
```

### Paramètres

| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `name` | string | ✅ | Nom descriptif du compte de service |
| `principal` | string | ✅ | Principal Kerberos (ex: `svc_sharepoint@REALM`) |
| `keytab` | string | ✅ | Chemin vers le fichier keytab |
| `cache_path` | string | ✅ | Chemin vers le cache des tickets Kerberos |
| `spn` | string | ✅ | Service Principal Name en format GSSAPI |

### Exemple de requête

```bash
curl -X POST https://server-domain.com/migration/sharepoint/kerberos-account-service \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "name": "SharePoint Production Service",
    "principal": "svc_sharepoint@COMPANY.COM",
    "keytab": "/etc/krb5/sharepoint.keytab",
    "cache_path": "/tmp/krb5cc_0",
    "spn": "HTTP@sharepoint.company.com"
  }'
```

### Réponse succès

```json
{
  "success": true,
  "message": "✅ Kerberos account service created successfully",
  "data": {
    "id": "kerberos-789-ghi",
    "name": "SharePoint Production Service",
    "principal": "svc_sharepoint@COMPANY.COM",
    "keyTabPath": "/etc/krb5/sharepoint.keytab",
    "ticketPath": "/tmp/krb5cc_sharepoint",
    "spn": "HTTP@sharepoint.company.com"
  }
}
```

### Erreurs possibles

| Code | Message | Cause |
|------|---------|-------|
| 400 | `Validation error` | Paramètres invalides ou manquants |
| 500 | `Failed to create Kerberos account service` | Échec de création en base de données |
| 500 | `Internal server error` | Erreur serveur |

## Étape 3 : Connecter le provider au compte Kerberos

Cette étape associe le provider SharePoint migré au compte de service Kerberos créé.

### Endpoint

```
PUT /migration/sharepoint/svc-kerberos-connect-provider
```

### Paramètres

| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `providerId` | string | ✅ | ID du provider SharePoint (obtenu à l'étape 1) |
| `kerberosSvcAccountId` | string | ✅ | ID du compte Kerberos (obtenu à l'étape 2) |

### Exemple de requête

```bash
curl -X PUT https://server-domain.com/migration/sharepoint/svc-kerberos-connect-provider \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "providerId": "provider-456-def",
    "kerberosSvcAccountId": "kerberos-789-ghi"
  }'
```

### Réponse succès

```json
{
  "success": true,
  "message": "✅ Devana provider connected to Kerberos service account successfully"
}
```

### Erreurs possibles

| Code | Message | Cause |
|------|---------|-------|
| 400 | `Validation error` | Paramètres invalides ou manquants |
| 404 | `Devana provider not found` | Le provider n'existe pas |
| 404 | `Kerberos service account not found` | Le compte Kerberos n'existe pas |
| 500 | `Internal server error` | Erreur serveur |

## Étape 4 : Mettre à jour le domaine du connecteur (optionnel)

Si le domaine SharePoint a changé, cette étape permet de mettre à jour la configuration du dossier connecté.

### Endpoint

```
PUT /migration/sharepoint/update-domain-connector-sharepoint
```

### Paramètres

| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `folderId` | string | ✅ | ID du dossier SharePoint à mettre à jour |
| `domain` | string | ✅ | Nouveau domaine SharePoint (ex: `sharepoint.newdomain.com`) |

### Exemple de requête

```bash
curl -X PUT https://server-domain.com/migration/sharepoint/update-domain-connector-sharepoint \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "folderId": "cuid123",
    "domain": "sharepoint.newdomain.com/sites/newsite"
  }'
```

### Réponse succès

```json
{
  "success": true,
  "message": "✅ Folder provider updated with new domain successfully"
}
```

### Erreurs possibles

| Code | Message | Cause |
|------|---------|-------|
| 400 | `Validation error` | Paramètres invalides ou manquants |
| 400 | `No host exist for the folder provider` | Aucun host configuré pour ce dossier |
| 404 | `Folder not found with the provided id` | Le dossier n'existe pas |
| 500 | `Internal server error` | Erreur serveur |

## Gestion des comptes de service Kerberos

### Lister tous les comptes

Pour visualiser tous les comptes de service Kerberos configurés :

#### Endpoint

```
GET /v1/sharepoint_svc_kerberos
```

#### Exemple de requête

```bash
curl -X GET https://server-domain.com/v1/sharepoint_svc_kerberos \
  -H "Authorization: Bearer YOUR_API_KEY"
```

#### Réponse succès

```json
{
  "success": true,
  "data": [
    {
      "id": "cuid123",
      "name": "SharePoint Production Service",
      "principal": "svc_sharepoint@COMPANY.COM",
      "keyTabPath": "/etc/krb5/sharepoint.keytab",
      "ticketPath": "/tmp/krb5cc_0",
      "spn": "HTTP@sharepoint.company.com"
    }
  ]
}
```

#### Restrictions d'accès

- ❌ Non disponible dans les environnements hébergés par Devana
- ✅ Nécessite un rôle `ADMIN` ou `SUPER_ADMIN`
- ✅ Nécessite une API Key valide

## Procédure complète de migration

Voici un script complet pour migrer un utilisateur :

```bash
#!/bin/bash

# Configuration
API_URL="https://server-domain.com"
API_KEY="your-api-key"
USER_ID="user-123-abc"

# Étape 1 : Migrer le provider
echo "Étape 1 : Migration du provider..."
PROVIDER_RESPONSE=$(curl -s -X PUT "$API_URL/migration/sharepoint/basic-to-kerberos" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "{\"userId\": \"$USER_ID\"}")

PROVIDER_ID=$(echo $PROVIDER_RESPONSE | jq -r '.data.id')
echo "Provider migré : $PROVIDER_ID"

# Étape 2 : Créer le compte Kerberos
echo "Étape 2 : Création du compte Kerberos..."
KERBEROS_RESPONSE=$(curl -s -X POST "$API_URL/migration/sharepoint/kerberos-account-service" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d '{
    "name": "SharePoint Production",
    "principal": "svc_sharepoint@COMPANY.COM",
    "keytab": "/etc/krb5/sharepoint.keytab",
    "cache_path": "/tmp/krb5cc_0",
    "spn": "HTTP@sharepoint.company.com"
  }')

KERBEROS_ID=$(echo $KERBEROS_RESPONSE | jq -r '.data.id')
echo "Compte Kerberos créé : $KERBEROS_ID"

# Étape 3 : Connecter le provider au compte Kerberos
echo "Étape 3 : Association provider-Kerberos..."
curl -s -X PUT "$API_URL/migration/sharepoint/svc-kerberos-connect-provider" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "{
    \"providerId\": \"$PROVIDER_ID\",
    \"kerberosSvcAccountId\": \"$KERBEROS_ID\"
  }"

echo "Migration terminée avec succès !"
```

## Points d'attention

### Sécurité

- 🔒 Les fichiers keytab contiennent des informations sensibles, assurez-vous qu'ils sont protégés avec les permissions appropriées (`chmod 600`)
- 🔒 Ne partagez jamais vos API Keys dans les logs ou le code source
- 🔒 Utilisez des chemins sécurisés pour les caches de tickets Kerberos

### Permissions fichiers

```bash
# Permissions recommandées pour le keytab
chmod 600 /etc/krb5/sharepoint.keytab
chown devana-service:devana-service /etc/krb5/sharepoint.keytab

# Permissions pour le cache de tickets
chmod 700 /tmp/krb5cc_sharepoint
```

### Configuration Kerberos

Assurez-vous que votre fichier `/etc/krb5.conf` est correctement configuré :

```ini
[libdefaults]
    default_realm = COMPANY.COM
    dns_lookup_realm = false
    dns_lookup_kdc = true
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true

[realms]
    COMPANY.COM = {
        kdc = kdc.company.com
        admin_server = kadmin.company.com
    }

[domain_realm]
    .company.com = COMPANY.COM
    company.com = COMPANY.COM
```

### Validation de la migration

Après la migration, vérifiez que :

1. ✅ Le provider est bien en mode `KERBEROS`
2. ✅ Le compte Kerberos est créé et visible via `GET /v1/sharepoint_svc_kerberos`
3. ✅ L'association provider-Kerberos est effective
4. ✅ Les tickets Kerberos sont générés correctement
5. ✅ La connexion SharePoint fonctionne

## Rollback

Si la migration échoue ou cause des problèmes, vous pouvez revenir en arrière :

1. **Supprimer l'association** : Mettre `sharepointSvcKerberosId` à `null` dans le provider dans la table `DevanaProvider`
2. **Restaurer Basic Auth** : Mettre à jour `oauthType` à `BASIC` et restaurer `metadataOauth` dans la table `DevanaProvider`
3. **Restaurer les configurations** : Mettre à jour les précédentes configurations si nécessaire dans la table `DevanaProvider`

⚠️ **Attention** : Le rollback nécessite un accès direct à la base de données.