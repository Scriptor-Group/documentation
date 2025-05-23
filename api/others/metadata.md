## 🔍 Filtrage par champ `metadata` – Endpoint `GET /v1/conversations` et `GET /v1/conversations/:id/messages`

L'API `GET /v1/conversations` et `GET /v1/conversations/:id/messages` permet de filtrer dynamiquement sur les champs JSON du champ `metadata`, même s’ils sont profondément imbriqués.

---

### 📌 Syntaxe des paramètres

- `metadata.` est requis en préfixe
- `__` (double underscore) est utilisé pour représenter un accès à un champ imbriqué dans un objet JSON
- `:operator` est l’opérateur de filtrage
- La valeur peut être un `string`, `boolean` (`true`/`false`) ou `number`

---

### ✅ Opérateur supporté

| Opérateur | Description                  | Exemple              |
|----------|------------------------------|----------------------|
| `equals` | Égal strict (`===`)          | `equals=uniqueId123`         |
| `not`    | Différent strict (`!==`)     | `not=uniqueId123`            |
| `gt`     | Plus grand que               | `gt=18`              |
| `gte`    | Plus grand ou égal que       | `gte=18`             |
| `lt`     | Plus petit que               | `lt=18`              |
| `lte`    | Plus petit ou égal que       | `lte=18`             |
| `string_contains` | Contient                     | `string_contains=123`             |
| `string_starts_with` | Commence par                     | `string_starts_with=uniqueId`             |
| `string_ends_with` | Termine par                     | `string_ends_with=123`             |
| `array_contains` | Contient dans un tableau                     | `array_contains=sport`             |
| `array_starts_with` | Commence par dans un tableau                     | `array_starts_with=sport`             |
| `array_ends_with` | Termine par dans un tableau                     | `array_ends_with=sport`             |

---

### 📝 Exemples

```
GET /v1/conversations?metadata.uniqueId:equals=uniqueId123
GET /v1/conversations?metadata.uniqueId:not=uniqueId123
GET /v1/conversations?metadata.client_age:gt=18
GET /v1/conversations?metadata.client_age:gte=18
GET /v1/conversations?metadata.client_age:lt=18
GET /v1/conversations?metadata.client_age:lte=18
GET /v1/conversations?metadata.uniqueId:string_contains=123
GET /v1/conversations?metadata.uniqueId:string_starts_with=uniqueId
GET /v1/conversations?metadata.uniqueId:string_ends_with=123
GET /v1/conversations?metadata.client_interests:array_contains=sport
GET /v1/conversations?metadata.client_interests:array_starts_with=sport
GET /v1/conversations?metadata.client_interests:array_ends_with=sport

```

Vous pouvez combiner les opérateurs pour filtrer sur plusieurs champs.

```
GET /v1/conversations?metadata.uniqueId:equals=uniqueId123&metadata.client_age:gt=18
```

#### 📝 Exemple de filtre sur un champ imbriqué

Pour récupérer les conversations dont le client a plus de 18 ans, vous pouvez utiliser le filtre suivant :

```
GET /v1/conversations?metadata.client__information__age:gt=18
```

Exemple de metadata :

```json
{
    "client": {
        "information": {
            "age": 18
        }
    }
}
```

#### ✅ Types supportés dans les valeurs des champs `metadata` pour les requêtes `GET /v1/conversations`

- `string`
- `boolean`
- `number`

