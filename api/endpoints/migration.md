# Migration

Documentation des endpoints pour la gestion des migrations entre les différentes versions de l'API.


## Authentification

Incluez votre clé API dans le header `Authorization` :

```bash
Authorization: Bearer VOTRE_TOKEN
```

Le système :

- Hydrate automatiquement l'utilisateur à partir du token.

## Migration SharePoint

### Migration SharePoint On-Premises – Auth Basic → NTLM

À compter du **14 juillet 2026**, l’authentification **Basic** pour SharePoint On-Premises sera **définitivement désactivée**. Ce référez-vous à la documentation de Microsoft pour plus d’informations : [Désactivation de l’authentification Basic](https://learn.microsoft.com/en-us/sharepoint/what-s-new/what-s-deprecated-or-removed-from-sharepoint-server-subscription-edition).
Vous devez migrer vos connexions vers l’authentification **NTLM** avant cette date.

⚠️ **Important** :

- Cette opération est **irréversible**.  
- Assurez-vous de disposer des informations de connexion correctes (**login NTLM + mot de passe**).  
- Seul un **administrateur** est autorisé à lancer cette migration.  



- **URL** : `PUT /migration/sharepoint/basic-to-ntlm`
- **Corps de la requête** :
  - `username` : Nom d'utilisateur pour l'authentification NTLM.
  - `password` : Mot de passe pour l'authentification NTLM.
  - `domain` : Domaine pour l'authentification NTLM. (optionnel)
  - `Workstation` : Poste de travail pour l'authentification NTLM. (optionnel)
  - `userId` : ID de l'utilisateur pour mettre à jour ses paramètres Auth Basic Sharepoint à NTLM. À défaut de ce paramètre, l'utilisateur courant selon le token sera utilisé. (optionnel)
  - `host_sharepoint`: URL du site Sharepoint On-Premises pour tester la connexion. (optionnel)
  - `force`: Booléen pour forcer la migration même si des erreurs sont détectées. Ce paramètre est conditionné si `host_sharepoint` est fourni. (optionnel)
- **Description** : Migre les connexions Sharepoint On-Premises de l'authentification Basic vers NTLM.
- **Réponse** :
  ```json
  {
    "success": true,
    "data": {
        "message": "string",
        "warning": "string (optionnel)",
    }
  }
  ```
- **Erreurs possibles** :
  - 400 : Requête invalide.
  - 401 : Non autorisé.
  - 403 : Accès non autorisé.
  - 404 : Message non trouvé.
  - 500 : Erreur interne du serveur.