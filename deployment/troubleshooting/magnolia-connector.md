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
class: info.magnolia.rest.delivery.jcr.v2.JcrDeliveryEndpointDefinition
workspace: website
nodeTypes:
  - mgnl:page
depth: 10
includeSystemProperties: true
```

`restEndpoints/delivery/assets.yaml` :
```yaml
class: info.magnolia.rest.delivery.jcr.v2.JcrDeliveryEndpointDefinition
workspace: dam
nodeTypes:
  - mgnl:asset
  - mgnl:folder
depth: 10
includeSystemProperties: true
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

### Téléchargement binaire d'un asset

```
GET /dam/jcr:{uuid} → fichier binaire (ex: /dam/jcr:a1b2c3d4-e5f6-7890)
```

> Cette route utilise le **servlet DAM** de Magnolia, pas la Delivery API. Elle supporte les mêmes modes d'authentification (anonymous ou basic auth).

**Headers attendus dans la réponse :**
- `Content-Type` : type MIME du fichier
- `Content-Disposition` : nom du fichier (utile pour l'API Devana)