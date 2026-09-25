# Serveur MCP d'Argos

Argos expose les documents indexés à vos agents IA via le **Model Context Protocol** (MCP). Tout client MCP compatible *Streamable HTTP* peut s'y connecter : Devana, Claude, Cursor, VS Code, SDK TypeScript et Python…

## 📑 Table des matières

- [Adresse et authentification](#adresse-et-authentification)
- [Clés API](#clés-api)
- [Espaces MCP](#espaces-mcp)
- [Configurer un client](#configurer-un-client)
- [Outils](#outils)
- [Filtres de métadonnées](#filtres-de-métadonnées)
- [Administration](#administration)

## Adresse et authentification

| Élément | Valeur |
|---|---|
| Serveur principal | `<PUBLIC_URL>/mcp`, ex. `https://argos.example.com/mcp` |
| Espace MCP | `<PUBLIC_URL>/mcp/<espace>` |
| Transport | Streamable HTTP (`POST`, réponses JSON) |
| Authentification | En-tête `Authorization: Bearer <clé API>` |

Le serveur MCP n'utilise pas la connexion Devana du dashboard : chaque application s'authentifie avec une **clé API dédiée**.

## Clés API

- **Création** : chaque utilisateur crée ses clés dans *Banc de test MCP › Connecter une application*. Il choisit un nom et une expiration (30 jours, 90 jours, 1 an ou aucune).
- **Affichage** : la clé (`spmcp_…`) n'est affichée **qu'une fois**, à sa création. Argos n'en conserve qu'une empreinte.
- **Droits** : une clé agit pour le compte de son propriétaire, sur un seul serveur (principal ou espace).
- **Révocation** : immédiate, par son propriétaire ou par un administrateur. Les administrateurs voient toutes les clés dans *Paramètres › Serveur MCP › Adresse & clés API*.
- **Refus** : une clé absente, inconnue, expirée ou révoquée est refusée (`401`). Une clé utilisée sur un autre serveur que le sien est refusée (`403`).

## Espaces MCP

Un **espace** est un serveur MCP limité à un périmètre. Il donne à chaque agent les seuls documents dont il a besoin, par exemple un agent RH limité au site RH, ou un agent juridique limité à certains dossiers.

Les administrateurs créent les espaces dans *Paramètres › Serveur MCP › Espaces MCP*. Chaque espace comprend :

- un **périmètre** :
  - règles « inclure » : un site entier ou un dossier ;
  - règles « exclure » : des sous-dossiers retirés, prioritaires sur les inclusions ;
- ses propres **clés API** ;
- une **présentation** ajoutée aux instructions transmises à l'agent : rôle, contenu des dossiers.

Le périmètre s'applique à **tous les outils** : navigation, lecture, recherche, graphe de connaissances, comparaison. Un document hors périmètre est « introuvable ». Les dossiers parents d'un dossier inclus restent visibles pour naviguer, sans leurs autres contenus.

Un site peut figurer dans un espace sans être exposé sur le serveur principal : option *Exposé sur le MCP principal* de la connexion.

## Configurer un client

L'onglet *Banc de test MCP › Connecter une application* donne, pour le serveur choisi (principal ou espace), l'adresse exacte et des configurations prêtes à copier, la clé créée étant déjà insérée. Clients couverts :

- Devana, Suite 366 ;
- Claude Code, Claude Desktop ;
- Cursor, VS Code ;
- SDK TypeScript et Python, curl.

**Devana** : dans la configuration de l'agent, ajoutez un serveur MCP de type HTTP avec l'adresse d'Argos et l'en-tête `Authorization: Bearer spmcp_…`. Cela requiert une version de Devana prenant en charge le transport *Streamable HTTP*.

**Cursor** (`~/.cursor/mcp.json`) :

```json
{
  "mcpServers": {
    "argos": {
      "url": "https://argos.example.com/mcp",
      "headers": { "Authorization": "Bearer spmcp_…" }
    }
  }
}
```

**Claude Code** :

```bash
claude mcp add --transport http argos https://argos.example.com/mcp \
  --header "Authorization: Bearer spmcp_…"
```

**Test de connexion** :

```bash
curl -X POST https://argos.example.com/mcp \
  -H "Authorization: Bearer spmcp_…" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

L'onglet *Banc de test MCP › Tester les outils* exécute les outils depuis le dashboard, dans le périmètre du serveur choisi.

## Outils

| Outil | Rôle |
|---|---|
| `get_metadata` | Sites accessibles et champs filtrables (type, valeurs possibles, opérateurs). À appeler en premier |
| `list_files` | Liste des fichiers et dossiers d'un chemin, avec filtres, recherche par mots-clés, tri et pagination. Chaque fichier porte un `fileId` |
| `tree` | Arborescence sur plusieurs niveaux |
| `read_file` | Contenu d'un fichier en Markdown, page par page, avec la description des images. Un fichier jamais traité est extrait immédiatement, en priorité |
| `get_file` | Informations sur un fichier : chemin, métadonnées, statut de traitement, pages, lien SharePoint, sous-fichiers (pièces jointes, archives) |
| `search` | Passages pertinents (plein texte et sémantique), avec fichier, page et extrait |
| `graph_search` | Entités (personnes, entreprises, projets, lieux…), leurs relations et les documents sources |
| `file_diff` | Différences entre deux fichiers : métadonnées et contenu |
| `sync_status` | État de la synchronisation par site (désactivé par défaut) |

Parcours recommandé pour un agent :

1. `get_metadata` ;
2. `list_files` / `tree` pour naviguer ;
3. `read_file` pour lire ;
4. `search` / `graph_search` pour rechercher.

Les chemins suivent la structure SharePoint : `/` liste les sites, puis `/<site>/<bibliothèque>/<dossier>/…`.

Chaque outil renvoie un texte lisible et des données structurées. Les erreurs (fichier introuvable, filtre invalide, délai d'extraction dépassé…) sont renvoyées avec un message explicite.

## Filtres de métadonnées

`list_files`, `tree` et `search` acceptent un filtre sur les métadonnées : les champs intégrés, plus les colonnes SharePoint exposées dans l'onglet *Métadonnées* de la connexion.

```json
{
  "logic": "and",
  "conditions": [
    { "field": "modified", "op": "gte", "value": "2025-01-01" },
    { "logic": "or", "conditions": [
      { "field": "DocType", "op": "eq", "value": "Contrat" },
      { "field": "DocType", "op": "eq", "value": "Avenant" }
    ] },
    { "field": "extension", "op": "in", "value": ["pdf", "docx"] }
  ]
}
```

| Type | Opérateurs |
|---|---|
| Texte | `eq` `ne` `contains` `not_contains` `starts_with` `ends_with` `in` `not_in` `is_null` `is_not_null` |
| Nombre | `eq` `ne` `gt` `gte` `lt` `lte` `between` `in` `not_in` `is_null` `is_not_null` |
| Date (ISO 8601, UTC) | `eq` `ne` `gt` `gte` `lt` `lte` `between` `is_null` `is_not_null` |
| Booléen | `eq` `ne` `is_null` `is_not_null` |
| Liste (choix multiples, personnes, taxonomie) | `eq` `ne` `contains` `not_contains` `in` `not_in` `is_null` `is_not_null` |

Règles de lecture :

- `between` attend `[min, max]`, bornes incluses.
- Une date sans heure désigne toute la journée.
- Les conditions s'imbriquent sur deux niveaux (`and` / `or`).

Champs intégrés : `name`, `path`, `extension`, `mimeType`, `size`, `created`, `modified`, `author`, `editor`, `kind`, `status`, `hasSlowContent`, `pageCount`, `wordCount`.

## Administration

*Paramètres › Serveur MCP* (administrateurs) :

| Onglet | Contenu |
|---|---|
| **Outils & comportement** | Activation de chaque outil, nom du serveur, instructions transmises aux agents, limites (résultats, taille de lecture, nœuds de l'arborescence), utilisateurs autorisés |
| **Espaces MCP** | Création des espaces, périmètre, présentation, activation |
| **Adresse & clés API** | Adresse du serveur, toutes les clés et leur révocation |
| **Journal des appels** | Appels par outil, clé et espace ; latence et erreurs |
