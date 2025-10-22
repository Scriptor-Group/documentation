# Configuration SSO Azure AD

Ce guide décrit comment configurer l'authentification Single Sign-On (SSO) avec Azure Active Directory pour votre application. Cette configuration supporte à la fois Azure AD cloud et les déploiements Active Directory Federation Services (ADFS) on-premises.

> **⚠️ Important** : Les callbacks Azure AD sont gérés par l'API serveur, pas par le frontend. Utilisez l'URL de votre API dans la configuration.

## Prérequis

- Accès administrateur à Azure AD
- Permissions pour créer des App Registrations
- Accès aux variables d'environnement de votre application

## Variables d'environnement requises

| Variable                 | Description                                   | Requis       | Exemple                                                         |
| ------------------------ | --------------------------------------------- | ------------ | --------------------------------------------------------------- |
| `AZURE_AD_CLIENT_ID`     | ID de l'application (client) depuis Azure AD  | Oui          | `12345678-1234-1234-1234-123456789012`                          |
| `AZURE_AD_CLIENT_SECRET` | Secret client depuis Azure AD                 | Oui          | `your-client-secret`                                            |
| `AZURE_AD_REDIRECT_URL`  | URI de redirection pour l'authentification    | Oui          | `https://votre-api.com/auth/azuread/callback`                   |
| `AZURE_AD_TENANT_ID`     | ID du tenant Azure AD (cloud uniquement)      | Cloud: Oui   | `87654321-4321-4321-4321-210987654321`                          |
| `AZURE_AD_ON_PREM_URL`   | URL des métadonnées ADFS (on-prem uniquement) | On-prem: Oui | `https://adfs.yourcompany.com/.well-known/openid-configuration` |
| `AZURE_AD_SCOPES`        | Liste des scopes séparés par virgules         | Non          | `profile,offline_access,email,User.Read,GroupMember.Read.All`   |
| `AZURE_AD_ROLES`         | Groupes à synchroniser comme équipes          | Non          | `Administrators,Users,Managers`                                 |
| `AZURE_AD_LOG_LEVEL`     | Niveau de log (error, warn, info, debug)      | Non          | `info`                                                          |

## 1. Création de l'App Registration Azure AD

### Étape 1 : Créer l'application

1. Connectez-vous au [portail Azure](https://portal.azure.com)
2. Accédez à **Azure Active Directory** > **App registrations**
3. Cliquez sur **New registration**
4. Configurez :
   - **Name** : Nom de votre application (ex: "DevanaAI SSO")
   - **Supported account types** : "Accounts in this organizational directory only"
   - **Redirect URI** : Type "Web" + `https://votre-api.com/auth/azuread/callback` (URL de l'API serveur)

### Étape 2 : Configuration des URI de redirection

1. Dans votre App Registration > **Authentication**
2. Ajoutez les URI de redirection :
   - Production : `https://votre-api.com/auth/azuread/callback` (API serveur)
3. Cochez **ID tokens** et **Access tokens** dans la section "Implicit grant and hybrid flows"

### Étape 3 : Générer un secret client

1. Accédez à **Certificates & secrets**
2. Cliquez sur **New client secret**
3. Configurez :
   - **Description** : "DevanaAI Client Secret"
   - **Expires** : 24 months (recommandé)
4. **⚠️ Copiez immédiatement la valeur du secret** (elle ne sera plus accessible)

## 2. Configuration des permissions API

### Permissions Microsoft Graph requises :

1. Dans **API permissions** > **Add a permission** > **Microsoft Graph**
2. Sélectionnez **Delegated permissions** et ajoutez :

#### Permissions obligatoires :

- `User.Read` - Lire le profil utilisateur de base ainsi que ses groupes

#### Permissions optionnelles :

- `GroupMember.Read.All` - Lire les groupes que les utilisateurs peuvent voir
- `Group.Read.All` - Alternative à GroupMember.Read.All (plus de permissions)
- `Directory.Read.All` - Lire les rôles directory (si nécessaire)

1. Cliquez sur **Grant admin consent** pour approuver les permissions

## 3. Configuration des claims de tokens

### Ajouter les groupes aux tokens :

1. Accédez à **Token configuration**
2. Cliquez sur **Add optional claim**
3. Sélectionnez **ID** tokens
4. Cochez **groups**
5. Cliquez sur **Add**

### Configuration avancée des groupes :

- **Groups assigned to the application** : Recommandé pour limiter les groupes inclus
- **All groups** : Inclut tous les groupes (peut créer des tokens volumineux)
- **Security groups** : Seulement les groupes de sécurité

## 4. Configuration on-premises ADFS (Alternative)

### Configuration de l'application ADFS :

1. Ouvrir la Console de gestion ADFS
2. Naviguer vers "Application Groups"
3. Créer un nouveau groupe d'applications pour l'application web et l'API web
4. Configurer l'URI de redirection : `https://votre-api.com/auth/azuread/callback`

### Obtenir l'URL des métadonnées :

L'URL des métadonnées suit le pattern :
`https://votre-serveur-adfs/.well-known/openid-configuration`

## 5. Configuration des variables d'environnement

### Pour Azure AD Cloud :

```bash
# Configuration Azure AD obligatoire
AZURE_AD_CLIENT_ID=votre-client-id
AZURE_AD_CLIENT_SECRET=votre-client-secret
AZURE_AD_TENANT_ID=votre-tenant-id
AZURE_AD_REDIRECT_URL=https://votre-api.com/auth/azuread/callback

# Scopes requis pour le bon fonctionnement
AZURE_AD_SCOPES=profile,offline_access,email,User.Read,GroupMember.Read.All

# Rôles/Groupes à synchroniser comme équipes (optionnel)
AZURE_AD_ROLES=Administrators,Users,Managers
```

### Pour Azure AD On-Premise :

```bash
# Configuration Azure AD On-Premises
AZURE_AD_CLIENT_ID=your-adfs-client-id
AZURE_AD_CLIENT_SECRET=your-adfs-client-secret
AZURE_AD_REDIRECT_URL=https://votre-api.com/auth/azuread/callback
AZURE_AD_ON_PREM_URL=https://adfs.yourcompany.com/.well-known/openid-configuration

# Scopes optionnels
AZURE_AD_SCOPES=profile,offline_access,email
```

## 6. Configuration Whitemark

Configurez votre whitemark pour inclure Azure AD comme fournisseur autorisé :

```json
{
  "allowedProviders": ["AZUREAD"],
  "registrationType": ["SSO"]
}
```

## 7. Flux d'authentification

1. L'utilisateur clique sur le bouton "Se connecter avec Microsoft"
2. L'utilisateur est redirigé vers le point de terminaison d'autorisation Azure AD/ADFS
3. L'utilisateur s'authentifie avec ses identifiants Microsoft
4. Azure AD redirige vers votre URL de callback avec le code d'autorisation
5. L'application échange le code contre un token d'accès et un token ID
6. L'application récupère optionnellement les rôles utilisateur depuis l'API Microsoft Graph
7. L'utilisateur est créé/mis à jour dans l'application et connecté

## 8. Mappage des données utilisateur

Azure AD fournit des informations utilisateur complètes :

| Champ Azure AD | Champ Application | Notes                          |
| -------------- | ----------------- | ------------------------------ |
| `email`        | `email`           | Identifiant principal          |
| `given_name`   | `firstName`       | Prénom                         |
| `family_name`  | `lastName`        | Nom de famille                 |
| `name`         | `displayName`     | Nom complet                    |
| `oid`          | `providerId`      | Identifiant unique utilisateur |

## 9. Gestion des équipes (Teams)

### Synchronisation automatique :

- Les groupes Azure AD deviennent automatiquement des équipes dans l'application
- Utilisez `AZURE_AD_ROLES` pour filtrer les groupes à synchroniser
- Format : noms de groupes séparés par des virgules

### Exemple de configuration :

```bash
# Synchronise seulement ces 3 groupes comme équipes
AZURE_AD_ROLES=DevTeam,QATeam,AdminTeam
```

### Configuration pour récupération des rôles :

Lorsque configuré avec les scopes appropriés (`User.Read` + `GroupMember.Read.All`), le système peut récupérer les rôles utilisateur :

#### Rôles Azure AD Cloud

- Récupère les rôles de directory depuis l'API Microsoft Graph
- Nécessite les permissions `Directory.Read.All` ou `Directory.AccessAsUser.All`
- Les rôles sont loggés mais pas actuellement utilisés pour l'autorisation

## 10. Fonctionnalités de sécurité

- **Protection CSRF** : Validation du paramètre state pour prévenir les attaques cross-site
- **Gestion de session** : Gestion sécurisée des sessions avec nettoyage automatique
- **Validation de domaine** : Authentification liée aux domaines whitemark spécifiques
- **Validation de token** : Validation complète des tokens OIDC en environnements de production
- **Application HTTPS** : Les environnements de production nécessitent HTTPS pour les URLs de redirection

## 11. Configuration avancée

### Scopes personnalisés

Scopes par défaut : `profile`, `offline_access`, `email`

Scopes additionnels courants :

- `User.Read` : Informations de profil de base
- `Directory.Read.All` : Lire les données de directory incluant les rôles
- `Directory.AccessAsUser.All` : Accéder au directory en tant qu'utilisateur connecté
- `GroupMember.Read.All` : Lire les appartenances aux groupes

### Paramètres spécifiques à l'environnement

Le fournisseur ajuste automatiquement le comportement basé sur `NODE_ENV` :

**Développement :**

- `allowHttpForRedirectUrl: true`
- `validateIssuer: false`

**Production :**

- `allowHttpForRedirectUrl: false`
- `validateIssuer: true`

## 12. Test de la configuration

### Vérifications à effectuer :

1. **Test d'authentification** :

   - L'utilisateur peut se connecter via Azure AD
   - Le profil utilisateur est correctement récupéré

2. **Test des groupes** :

   - Les groupes Azure AD apparaissent dans les logs
   - L'utilisateur est assigné aux bonnes équipes
   - Les permissions d'accès aux ressources partagées fonctionnent

3. **Test des tokens** :
   - Les tokens contiennent les claims attendus
   - Les scopes sont correctement accordés

### Commandes de diagnostic :

```bash
# Vérifier les logs d'authentification
grep "Azure AD" logs/application.log

# Vérifier les groupes récupérés
grep "userRoles" logs/application.log
```

## 13. Dépannage courant

### Problèmes fréquents

**AADSTS50011: Redirect URI mismatch**

- S'assurer que `AZURE_AD_REDIRECT_URL` correspond exactement à l'URI de redirection enregistrée
- Les URLs sont sensibles à la casse et doivent inclure le protocole (https://)

**AADSTS70001: Application not found**

- Vérifier que `AZURE_AD_CLIENT_ID` est correct
- S'assurer que l'application est correctement enregistrée dans le bon tenant

**AADSTS7000215: Invalid client secret**

- Vérifier que `AZURE_AD_CLIENT_SECRET` est correct et non expiré
- Les secrets clients ont des dates d'expiration dans Azure AD

**Invalid issuer**

- Pour le cloud : Vérifier que `AZURE_AD_TENANT_ID` est correct
- Pour on-prem : Vérifier que `AZURE_AD_ON_PREM_URL` pointe vers le bon serveur ADFS

**"No groups in token"**

- Vérifiez que `GroupMember.Read.All` est accordé
- Confirmez que les groupes sont ajoutés dans Token configuration
- L'utilisateur doit appartenir à au moins un groupe

**"Invalid redirect URI"**

- Vérifiez que l'URI de redirection correspond exactement
- Incluez le protocole (https://)
- Pas de slash final dans l'URI

**"Insufficient privileges"**

- Un administrateur doit accorder le consentement admin
- Vérifiez que les permissions API sont correctement configurées

**"Groups not syncing as teams"**

- Vérifiez `AZURE_AD_ROLES` contient les noms exacts des groupes
- Les noms de groupes sont sensibles à la casse
- Consultez les logs pour voir les groupes récupérés
- Utilisez `displayName` du groupe Azure AD (pas l'ID)

**"Failed to fetch user roles"**

- S'assurer que les permissions requises sont accordées et le consentement admin fourni
- Vérifier que les scopes `User.Read` et `Directory.Read.All` sont inclus
- Vérifier que le token d'accès a des permissions suffisantes

### Test

1. Activer Azure AD SSO dans votre configuration whitemark
2. Naviguer vers votre page de connexion
3. Cliquer sur "Se connecter avec Microsoft"
4. Compléter l'authentification avec un compte Azure AD
5. Vérifier que l'utilisateur est créé et connecté avec succès
6. Vérifier les logs pour les informations de rôles si configuré

### Informations de débogage

Le système log des informations détaillées incluant :

- Rôles utilisateur récupérés (quand configuré)
- Erreurs d'authentification avec codes d'erreur spécifiques
- Résultats de validation de tokens

## 14. Sécurité et bonnes pratiques

### Recommandations :

- ✅ Utilisez HTTPS pour toutes les URIs de redirection en production
- ✅ Renouvelez les secrets clients régulièrement avant expiration
- ✅ Surveillez les logs d'authentification pour les tentatives échouées
- ✅ Utilisez le principe du moindre privilège pour les permissions API
- ✅ Maintenez les serveurs ADFS à jour avec les derniers correctifs de sécurité
- ✅ Considérez l'utilisation de l'authentification basée sur certificats pour une sécurité accrue
- ✅ Utilisez des groupes spécifiques plutôt que "All groups"
- ✅ Testez sur un environnement de développement d'abord

### À éviter :

- ❌ Ne commitez jamais les secrets dans le code
- ❌ N'utilisez pas Directory.Read.All sans justification
- ❌ N'accordez pas plus de permissions que nécessaire

## Support

En cas de problème persistant, fournissez les informations suivantes :

- Version de l'application
- Configuration des variables d'environnement (sans les secrets)
- Messages d'erreur complets
- Logs d'authentification pertinents
