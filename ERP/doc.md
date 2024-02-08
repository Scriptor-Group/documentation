# Utilisation des API de l'ERP de l'ENR

La documentation de l'API GraphQL de l'ERP de l'ENR vous permet d'accéder aux données et aux fonctionnalités de l'ERP via une interface de programmation. Pour utiliser l'API, vous devez disposer d'une clé API valide et envoyer des requêtes GraphQL à l'adresse `https://api-v2.clavus.io/api/external/graphql` avec un header `Authorization` contenant votre clé API préfixée par `Bearer`.

La documentation de l'API vous fournit les informations nécessaires pour utiliser chaque requête disponible, notamment les paramètres d'entrée et les données de sortie attendues. Elle vous permet également de comprendre les fonctionnalités et les limites de l'API, ainsi que les conditions d'utilisation.

En utilisant l'API de l'ERP de l'ENR, vous pouvez réaliser des opérations telles que la récupération de dossiers, la recherche de colonnes, la récupération d'utilisateurs ou de équipes, et bien d'autres encore. N'hésitez pas à consulter la documentation complète de l'API pour en savoir plus sur les possibilités offertes.


## Disposer d'une clé d'API

Pour utiliser l'API de l'ERP Clavus, vous devez disposer d'une clé d'API valide. Pour obtenir une clé d'API, vous devez demander à un administrateur de Clavus de vous en fournir une.

L'administrateur peut générer une nouvelle clé d'API dans le panel d'administration de Clavus, dans l'onglet "Gestion des clés API". Il vous suffit de lui fournir votre identifiant d'utilisateur et il pourra vous créer une clé d'API personnalisée.

Assurez-vous de garder votre clé d'API confidentielle et de ne pas la partager avec des personnes non autorisées. Si vous avez des questions sur l'utilisation de la clé d'API, n'hésitez pas à demander de l'aide à l'administrateur de Clavus qui vous l'a fournie.


## Utilisation d'un jeton Bearer

Pour utiliser l'API, vous devez inclure un jeton `Bearer` dans le header de la requête GraphQL. Le jeton `Bearer` est une chaîne de caractères qui vous est fournie par l'ERP de l'ENR et qui vous permet d'accéder aux données de l'API.

Voici comment inclure un jeton `Bearer` dans un header de requête HTTP :

```bash
Authorization: Bearer votre_jeton_ici
```

Voici comment inclure un jeton Bearer dans un header de requête GraphQL utilisant l'outil `curl` :

```bash
curl -X POST -H "Authorization: Bearer votre_jeton_ici" -H "Content-Type: application/json" --data '{ votre_requête_graphql_ici }' https://api-v2.clavus.io/api/external/graphql
```

## Playground

Il est possible de tester l'API de l'ERP de l'ENR en utilisant l'outil de playground GraphQL en ligne.

![capture_d’écran_2023-01-05_à_18.33.00.png](/capture_d’écran_2023-01-05_à_18.33.00.png)

Le playground GraphQL est un outil qui vous permet de tester les requêtes GraphQL et de visualiser leurs résultats de manière interactive. Pour utiliser le playground, vous devez d'abord vous rendre sur l'adresse `https://api-v2.clavus.io/api/external/graphql` et y entrer votre jeton `Bearer` dans le header de la requête, comme indiqué dans la documentation précédente.

Une fois que vous avez entré votre jeton `Bearer`, vous pouvez commencer à écrire et à envoyer des requêtes GraphQL dans la console du playground. Vous pouvez également utiliser le playground pour explorer la documentation de l'API et pour en savoir plus sur les différentes méthodes et les arguments disponibles.

Le playground GraphQL est un outil très pratique pour tester et développer des applications qui utilisent l'API de l'ERP de l'ENR, car il vous permet de vérifier rapidement que vos requêtes sont correctes et de visualiser les résultats obtenus.

## Récupération de dossiers

Pour récupérer une liste de dossiers, vous pouvez utiliser la requête GraphQL suivante :

```graphql
query {
  erpEnrAPI {
    getFolders(
      page: Int!,
      itemParPage: Int!,
      search: String,
      columns: [String],
      filterColumns: [FilterInput]
    ) {
      totalCount
      results {
        id
        columns {
          id
          name
          value
        }
      }
    }
  }
}
```

Les paramètres de la requête sont les suivants :

- `page` : numéro de la page de résultats à récupérer (entier, obligatoire)
- `itemParPage` : nombre de dossiers à afficher par page (entier, obligatoire)
- `search` : chaîne de caractères utilisée pour filtrer les résultats en fonction du nom du dossier (facultatif)
- `columns` : liste des colonnes à inclure dans les résultats (facultatif)
- `filterColumns` : liste de filtres à appliquer sur les colonnes (facultatif)

La réponse à la requête inclut le nombre total de dossiers et une liste de dossiers, chaque dossier étant représenté par un objet avec les propriétés suivantes :

- `id` : identifiant unique du dossier
- `columns` : liste d'objets représentant les colonnes du dossier, avec les propriétés id, name et value

Voici un exemple de résultat pour une requête de récupération de dossiers :

```json
{
  "data": {
    "erpEnrAPI": {
      "getFolders": {
        "totalCount": 100,
        "results": [
          {
            "id": "abc123",
            "columns": [
              {
                "id": "col1",
                "name": "Nom du client",
                "value": "John Doe"
              },
              {
                "id": "col2",
                "name": "Date de création",
                "value": "2022-01-01"
              }
            ]
          },
          {
            "id": "def456",
            "columns": [
              {
                "id": "col1",
                "name": "Nom du client",
                "value": "Jane Smith"
              },
              {
                "id": "col2",
                "name": "Date de création",
                "value": "2022-02-15"
              }
            ]
          }
        ]
      }
    }
  }
}
```

### Utilisation de search

L'argument `search` permet de filtrer les résultats d'une requête GraphQL en fonction de termes de recherche spécifiques. Si vous utilisez des termes de recherche entre guillemets (`"`), la requête ne retournera que les documents qui contiennent ces termes dans l'ordre donné. On appelle cela une recherche de phrase.

Les recherches de phrase sont insensibles à la casse et ignorent les séparateurs doux tels que `-`,`,`, et :`.` L'utilisation d'un séparateur dur au sein d'une recherche de phrase la divise en plusieurs recherches de phrase distinctes : `"Octavia.Butler"` retournera les mêmes résultats que `"Octavia" "Butler"`.

Il est possible de combiner des recherches de phrase et des requêtes normales dans une seule requête de recherche. Dans ce cas, la requête récupérera d'abord tous les documents avec des correspondances exactes aux phrases données, puis continuera avec son comportement par défaut.

### Utilisation de la pagination

Les arguments `page` et `itemParPage` permettent de contrôler la pagination des résultats d'une requête GraphQL.

L'argument page indique le numéro de la page de résultats que vous souhaitez récupérer. Par exemple, si vous spécifiez page: `2`, la requête retournera la deuxième page de résultats.

L'argument `itemParPage` indique le nombre d'éléments à afficher par page. Par exemple, si vous spécifiez `itemParPage: 25`, la requête retournera `25` éléments par page.

Voici un exemple d'utilisation des arguments `page` et `itemParPage` pour récupérer la deuxième page de `25` dossiers :

```graphql
query {
  erpEnrAPI {
    getFolders(
      page: 2,
      itemParPage: 25,
      search: String,
      columns: [String],
      filterColumns: [FilterInput]
    ) {
      totalCount
      results {
        id
        columns {
          id
          name
          value
        }
      }
    }
  }
}
```

### Utilisation de FilterInput

Le paramètre `FilterInput` peut être utilisé pour filtrer les résultats d'une requête GraphQL en fonction de certaines valeurs. Pour utiliser ce paramètre, vous devez fournir un objet contenant les propriétés suivantes :

- `column` : nom de la colonne sur laquelle le filtre doit être appliqué
- `operator` : opérateur de comparaison à utiliser pour le filtre (`=`, `<`, `>`, `<=`, `>=`, `IN`, `CONTAINS`)
- `value` : valeur à filtrer
Voici un exemple d'utilisation du paramètre `FilterInput` pour filtrer les dossiers sur un commercial spécifique :

```graphql
query {
  erpEnrAPI {
    getFolders(
      page: Int!,
      itemParPage: Int!,
      search: String,
      columns: [String],
      filterColumns: [
        {
          column: "commercial",
          operator: "=",
          value: "user1"
        }
      ]
    ) {
      totalCount
      results {
        id
        columns {
          id
          name
          value
        }
      }
    }
  }
}
```

Cette requête récupérera uniquement les dossiers qui ont pour commercial l'utilisateur avec l'identifiant `user1`.

Voici un exemple de résultat pour cette requête de filtrage des dossiers sur un commercial spécifique :

```json
{
  "data": {
    "erpEnrAPI": {
      "getFolders": {
        "totalCount": 50,
        "results": [
          {
            "id": "abc123",
            "columns": [
              {
                "id": "col1",
                "name": "Nom du client",
                "value": "John Doe"
              },
              {
                "id": "col2",
                "name": "Date de création",
                "value": "2022-01-01"
              },
              {
                "id": "col3",
                "name": "Commercial",
                "value": "user1"
              }
            ]
          },
          {
            "id": "def456",
            "columns": [
              {
                "id": "col1",
                "name": "Nom du client",
                "value": "Jane Smith"
              },
              {
                "id": "col2",
                "name": "Date de création",
                "value": "2022-02-15"
              },
              {
                "id": "col3",
                "name": "Commercial",
                "value": "user1"
              }
            ]
          }
        ]
      }
    }
  }
}
```

### sortBy

Le paramètre permet de choisir l'ordre de retour des différents éléments. Vous pouvez l'utiliser avec la structure suivante.


```graphql
query {
  erpEnrAPI {
    getFolders(
      page: Int!,
      itemParPage: Int!,
      search: String,
      columns: [String],
      sortBy: [
        {
          column: "commercial",
          direction: "desc" // asc
        }
      ]
    ) {
      totalCount
      results {
        id
        columns {
          id
          name
          value
        }
      }
    }
  }
}
```


## Récupération de colonnes

Pour obtenir la liste des colonnes disponibles, vous pouvez utiliser la requête GraphQL suivante :

```graphql
query {
  erpEnrAPI {
    getColumns(
      page: Int!,
      itemParPage: Int!
    ) {
      id
      label
    }
  }
}
```

Les paramètres de la requête sont les suivants :

- `page` : numéro de la page de résultats à récupérer (entier, obligatoire)
- `itemParPage` : nombre de colonnes à afficher par page (entier, obligatoire)

La réponse à la requête inclut une liste d'objets représentant les colonnes, avec les propriétés suivantes :

- `id` : identifiant unique de la colonne
- `label` : nom de la colonne.

Voici un exemple de résultat pour une requête de récupération de colonnes :

```json
{
  "data": {
    "erpEnrAPI": {
      "getColumns": [
        {
          "id": "col1",
          "label": "Nom du client"
        },
        {
          "id": "col2",
          "label": "Date de création"
        },
        {
          "id": "col3",
          "label": "Statut du dossier"
        }
      ]
    }
  }
}
```

## Récupération des équipes

Pour récupérer les équipes disponibles dans l'ERP de l'ENR, vous pouvez utiliser la requête getTeams. Cette requête prend en entrée aucun paramètre et renvoie en sortie un tableau d'objets Team, chacun contenant les champs suivants :

- `id` : l'identifiant unique de l'équipe
- `name` : le nom de l'équipe
- `description`: la description de l'équipe
- `color` : la couleur associée à l'équipe

Voici un exemple de requête GraphQL pour récupérer les équipes :

```graphql
query {
  erpEnrAPI {
    getTeams {
      id
      name
      description
      color
    }
  }
}
```

Voici un exemple de réponse possible :


```json
{
  "data": {
    "getTeams": [
      {
        "id": "1",
        "name": "Équipe A",
        "description": "La première équipe",
        "color": "#ff0000"
      },
      {
        "id": "2",
        "name": "Équipe B",
        "description": "La deuxième équipe",
        "color": "#00ff00"
      }
    ]
  }
}
```

## Récupération de la liste des utilisateurs actifs

Pour récupérer une liste des utilisateurs actifs par équipe sur l'ERP, vous pouvez utiliser la requête GraphQL suivante :

```graphql
query {
  erpEnrAPI {
    getUsers(teamId: "id1") {
      id
      firstName
      lastName
      email
    }
  }
}
```

La réponse à la requête inclut une liste d'objets représentant les utilisateurs, avec les propriétés suivantes :

- `id` : identifiant unique de l'utilisateur
- `firstName` : prénom de l'utilisateur
- `lastName` : nom de famille de l'utilisateur
- `email` : adresse email de l'utilisateur

Voici un exemple de résultat pour une requête de récupération de la liste des commerciaux actifs :

```json
{
  "data": {
    "erpEnrAPI": {
      "getUsers": [
        {
          "id": "user1",
          "firstname": "John",
          "lastname": "Doe",
          "email": "john.doe@example.com"
        },
        {
          "id": "user2",
          "firstname": "Jane",
          "lastname": "Smith",
          "email": "jane.smith@example.com"
        }
      ]
    }
  }
}
```

## Récupération des valeurs

Pour récupérer toutes les valeurs d'un folder, vous pouvez exécuté la requête suivante :

```gql
query getValues {
  erpEnrAPI {
    getValuesByIds(ids: ["clsc618zi01qbwjw3m1hw93ge"]) {
      id
      values {
        id
        name
        label
        value
      }
    }
  }
}
```

Suite à cette query, la réponse renvoyée sera :
```
{
  "data": {
    "erpEnrAPI": {
      "getValuesByIds": [
        {
          "id": "clsc618zi01qbwjw3m1hw93ge",
          "values": [
            {
              "id": "clsc5ug8w001vwjw3neqiqice",
              "name": "commercial.accompagnant",
              "label": "Commercial accompagnant",
              "value": "Marvin"
            },
            ...
          ]
        }
      ]
    }
  }
}
```

# Ajout et mise à jour des informations

## Comment ajouter un nouveau prospect ?

Pour intégrer un nouveau prospect dans l'ERP via l'API, utilisez la mutation `upsertProspect` comme illustré ci-dessous :

```gql
mutation {
  upsertProspect(
    firstName: "first name",
    lastName: "last name",
    address: "15 Fb saint-jean",
    postalCode: "09100",
    email: "exempl@clavus.io",
    phone: "0666666666",
    type: MORAL,
    siren: "0000000000000",
    puissanceKc: 300,
    prixHT: "23.00",
    gps: ["0.2993", "1.2020"],
    commercialNote: "Attention au ..."
  ) {
    id
    firstName
    lastName
    address
    postalCode
    email
    phone
    type
    siren
    puissanceKc
    prixHT
    gps
    commercialNote
  }
}
```

Lorsque vous exécutez cette mutation, vous obtiendrez une réponse similaire à celle-ci :

```json
{
  "data": {
    "upsertProspect": {
      "id": "clnj1a46700kpwjz8vfk5xjwr",
      "firstName": "first name",
      "lastName": "last name",
      "address": "15 Fb saint-jean",
      "postalCode": "09100",
      "email": "exempl@clavus.io",
      "phone": "0666666666",
      "type": "MORAL",
      "siren": "0000000000000",
      "puissanceKc": 300,
      "prixHT": "23.00",
      "gps": ["0.2993", "1.2020"],
      "commercialNote": "Attention au ..."
    }
  }
}
```

## Comment mettre à jour un prospect existant ?

Pour mettre à jour les informations d'un prospect déjà existant, employez la même mutation `upsertProspect`. Assurez-vous simplement d'inclure l'identifiant (`id`) du prospect dans les arguments. Ensuite, spécifiez les champs que vous souhaitez mettre à jour.

⚠️ **Attention !**

Il est **impossible** de mettre à jour un prospect dans l'ERP une fois qu'il a été converti. Toute tentative de modification d'un prospect converti sera refusée par le système. Assurez-vous de vérifier le statut du prospect avant d'essayer de le mettre à jour.

Exemple de mise à jour du prénom d'un prospect :

```gql
mutation {
  upsertProspect(
    id: "clnj1a46700kpwjz8vfk5xjwr",
    firstName: "updated"
  ) {
    id
    firstName
  }
}
```

Suite à cette mutation, la réponse renvoyée sera :

```json
{
  "data": {
    "upsertProspect": {
      "id": "clnj1a46700kpwjz8vfk5xjwr",
      "firstName": "updated"
    }
  }
}
```

Veillez à toujours vérifier les réponses des requêtes pour vous assurer que les opérations ont été exécutées correctement.

# Informations
Il est important de noter que les fichiers présents dans les colonnes de l'ERP ne sont pas accessibles via l'API GraphQL. Si vous souhaitez accéder à ces fichiers, vous devrez utiliser un autre moyen, comme par exemple le téléchargement manuel via l'interface de l'ERP.

Il est également possible que certaines colonnes ne soient pas disponibles via l'API, selon les droits d'accès de votre compte et les paramètres de sécurité de l'ERP. Si vous rencontrez des problèmes d'accès à certaines colonnes, n'hésitez pas à contacter l'assistance de *Clavus* pour obtenir de l'aide.

# Conditions d'utilisation

1. L'API GraphQL de l'ERP de l'ENR est fournie par Clavus et est destinée à être utilisée par les utilisateurs autorisés uniquement.
2. Pour utiliser l'API, vous devez disposer d'une clé API valide fournie par Clavus. Toute utilisation non autorisée de l'API peut entraîner la suspension ou la suppression de votre accès à l'API.
3. L'API est fournie « en l'état » et Clavus ne garantit pas l'exactitude, la fiabilité ou l'exhaustivité des données ou des résultats obtenus à l'aide de l'API. Clavus ne sera pas responsable de tout dommage indirect, consécutif, spécial, punitif ou autre résultant de l'utilisation ou de l'incapacité d'utiliser l'API.
4. Vous êtes responsable de la sécurité de votre clé API et de toutes les activités effectuées à l'aide de cette clé. Si vous suspectez une utilisation non autorisée de votre clé API, vous devez immédiatement en informer Clavus.
5. Clavus se réserve le droit de modifier, de suspendre ou de mettre fin à l'utilisation de l'API à tout moment, sans préavis.
6. En utilisant l'API, vous acceptez les présentes conditions d'utilisation. Si vous n'acceptez pas ces conditions, vous ne devez pas utiliser l'API.

