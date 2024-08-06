## Documentation de l'API : Télécharger des documents

### Endpoint

`POST https://api-v2.clavus.io/api/downloadFile`

### Description

Cet endpoint permet de télécharger des documents en fournissant un `fileId` et un en-tête `Authorization` contenant le jeton Bearer. L'API retourne un lien S3 pour télécharger le fichier.

### Paramètres

#### En-têtes

- `Authorization` : Obligatoire. Jeton Bearer pour l'authentification. Format : `Bearer {token}`

#### Corps de la requête

- `fileId` : Obligatoire. Identifiant unique du fichier à télécharger.

### Exemple de Requête

#### Requête HTTP

```http
POST /api/downloadFile HTTP/1.1
Host: api-v2.clavus.io
Authorization: Bearer YOUR_ACCESS_TOKEN
Content-Type: application/json

{
  "fileId": "example-file-id"
}
```

#### Requête cURL

```bash
curl -X POST https://api-v2.clavus.io/api/downloadFile \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
        "fileId": "example-file-id"
      }'
```

### Réponses

#### Succès (200)

```json
{
  "status": "success",
  "data": {
    "s3Url": "https://s3.amazonaws.com/your-bucket/your-file-id"
  }
}
```

La réponse contient l'URL S3 pour télécharger le fichier.

#### Erreur (4xx / 5xx)

```json
{
  "status": "error",
  "message": "Description de l'erreur"
}
```

### Codes de Réponse

- `200 OK` : Le lien S3 pour le fichier a été retourné avec succès.
- `400 Bad Request` : La requête est mal formée ou des paramètres sont manquants.
- `401 Unauthorized` : Jeton d'authentification non valide ou manquant.
- `404 Not Found` : Le fichier avec le `fileId` spécifié n'a pas été trouvé.
- `500 Internal Server Error` : Erreur interne du serveur.

### Remarques

- Assurez-vous de remplacer `YOUR_ACCESS_TOKEN` par votre jeton api réel.
- Le lien S3 retourné est temporaire et peut expirer après un certain temps. Assurez-vous de télécharger le fichier avant l'expiration du lien.
