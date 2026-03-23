# Connecteur Magnolia CMS - Documentation Technique

## Sommaire

1. [Prérequis Magnolia](#prérequis-magnolia)
2. [Authentification](#authentification)
3. [Routes API utilisées](#routes-api-utilisées)

---

## Prérequis Magnolia

### Delivery API

La **Delivery API** doit être activée et configurée sur l'instance Magnolia :

| Endpoint | Description |
|----------|-------------|
| `/.rest/delivery/pages` | Pages (workspace `website`) |
| `/.rest/delivery/assets` | Assets / DAM (workspace `dam`) |

> Les endpoints REST Nodes (`/.rest/nodes/v1/`) ne sont **pas** utilisés. Seule la Delivery API est nécessaire.

### Modules requis

- **Magnolia REST module** (`magnolia-rest-services`)
- **Delivery endpoint** configuré pour `pages` et `assets`
- **DAM module** pour le téléchargement binaire des assets

### Configuration des endpoints Delivery

`restEndpoints/delivery/pages.yaml` :
```yaml
$type: jcrDeliveryEndpoint_v2
workspace: website
depth: 3
nodeTypes:
  - mgnl:page
includeSystemProperties: true
bypassWorkspaceAcls: true
limit: 50
```

`restEndpoints/delivery/assets.yaml` :
```yaml
$type: jcrDeliveryEndpoint_v2
workspace: dam
depth: 2
nodeTypes:
  - mgnl:asset
  - mgnl:folder
includeSystemProperties: true
bypassWorkspaceAcls: true
limit: 50
references:
  - name: categories
    propertyName: categories
    referenceResolver:
      $type: jcrReferenceResolver
      targetWorkspace: category
```

> `includeSystemProperties: true` est **obligatoire**. Le connecteur utilise les propriétés système (`@name`, `@path`, `@id`, `@nodeType`, `@nodes`) pour la navigation, l'identification des types et le téléchargement des assets.
>
> `depth` doit couvrir la profondeur maximale de vos templates (page → area → component → sous-area → ...).

---

## Authentification

Le connecteur supporte deux modes :

### Mode Anonymous

Aucune authentification n'est envoyée.

- L'utilisateur `anonymous` doit avoir les permissions de lecture sur les workspaces `website` et `dam`
- Les endpoints REST et le servlet DAM doivent être accessibles sans authentification

### Mode Basic Auth

Le connecteur envoie un header `Authorization: Basic <base64(username:password)>` sur chaque requête (Delivery API et servlet DAM).

- Un compte utilisateur avec les permissions de lecture sur les workspaces `website` et `dam`

---

## Routes API utilisées

Le connecteur utilise les endpoints delivery standards (`/.rest/delivery/pages`, `/.rest/delivery/assets`) et le servlet DAM (`/dam/jcr:{uuid}`) pour le téléchargement binaire des assets.

| Route | Usage |
|-------|-------|
| `/.rest/delivery/pages` | Navigation et contenu des pages |
| `/.rest/delivery/assets` | Navigation et résolution des assets |
| `/dam/jcr:{uuid}` | Téléchargement binaire d'un asset |