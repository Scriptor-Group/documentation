# Documentation OAuth

Ce document fournit un aperçu de l'utilisation de l'authentification OAuth dans votre application pour accéder aux ressources protégées de notre plateforme.

## Flux OAuth

1. **Demande d'autorisation** : L'application cliente redirige l'utilisateur vers notre point de terminaison d'autorisation (`/oauth/authorize`) avec les paramètres nécessaires (ID client, URI de redirection, portées).

2. **Authentification de l'utilisateur** : L'utilisateur est invité à se connecter à notre plateforme s'il n'est pas déjà authentifié.

3. **Consentement de l'utilisateur** : L'utilisateur est présenté avec les autorisations (portées) demandées par l'application cliente et peut choisir d'accorder ou de refuser l'accès.

4. **Code d'autorisation** : Si l'utilisateur accorde l'accès, un code d'autorisation est généré et renvoyé à l'application cliente via l'URI de redirection fournie.

5. **Échange de jeton d'accès** : L'application cliente échange le code d'autorisation contre un jeton d'accès en effectuant une requête POST à notre point de terminaison de jeton (`/oauth/token`) avec le code d'autorisation et les informations d'identification du client.

6. **Accès aux ressources protégées** : L'application cliente peut maintenant utiliser le jeton d'accès pour effectuer des requêtes authentifiées à nos points de terminaison d'API (`/oauth/userinfo`) afin d'accéder aux ressources protégées de l'utilisateur.

## Points de terminaison

### Point de terminaison d'autorisation

- URL : `/oauth/authorize`
- Méthode : GET
- Paramètres :
  - `clientId` (obligatoire) : L'ID client obtenu lors de l'enregistrement de l'application.
  - `redirectUri` (obligatoire) : L'URI vers laquelle l'utilisateur sera redirigé après l'autorisation.
  - `scopes` (facultatif) : Une liste de portées demandées par l'application, séparées par des virgules.
  - `state` (facultatif) : Une valeur opaque utilisée par le client pour maintenir l'état entre la demande et le rappel.

### Point de terminaison de jeton

- URL : `/oauth/token`
- Méthode : POST
- Paramètres :
  - `grantType` (obligatoire) : Le type de grant OAuth utilisé (`authorization_code`, `refresh_token`, `client_credentials`).
  - `code` (obligatoire pour le type de grant `authorization_code`) : Le code d'autorisation reçu du point de terminaison d'autorisation.
  - `redirectUri` (obligatoire pour le type de grant `authorization_code`) : L'URI de redirection utilisée lors de la demande d'autorisation.
  - `clientId` (obligatoire) : L'ID client obtenu lors de l'enregistrement de l'application.
  - `clientSecret` (obligatoire) : Le secret client obtenu lors de l'enregistrement de l'application.
  - `refreshToken` (obligatoire pour le type de grant `refresh_token`) : Le jeton de rafraîchissement permettant d'obtenir un nouveau jeton d'accès.
  - `longLivedToken` (facultatif) : Un jeton d'accès à longue durée obtenu à partir d'un jeton de rafraîchissement.

### Point de terminaison des informations utilisateur

- URL : `/oauth/userinfo`
- Méthode : GET
- En-têtes :
  - `Authorization` (obligatoire) : Le jeton d'accès au format `Bearer {access_token}`.

## Réponses de l'API

### Réponse de jeton réussie

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "tGzv3JOkF0XG5Qx2TlKWIA",
  "scope": "read write"
}
```

### Réponse des informations utilisateur

```json
{
  "sub": "1234567890",
  "fullName": "John Doe",
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com"
}
```

## Types de grant OAuth

Les types de grant OAuth suivants sont pris en charge :

- `authorization_code` : Utilisé pour échanger un code d'autorisation contre un jeton d'accès.
- `refresh_token` : Utilisé pour obtenir un nouveau jeton d'accès à l'aide d'un jeton de rafraîchissement.
- `client_credentials` : Utilisé par les clients pour obtenir un jeton d'accès en utilisant leurs propres informations d'identification.

Le type de grant `password` n'est pas pris en charge pour des raisons de sécurité.

## Portées

Les portées suivantes sont prises en charge :

- `FIRST_NAME` : Accorde l'accès au prénom de l'utilisateur.
- `LAST_NAME` : Accorde l'accès au nom de famille de l'utilisateur.
- `EMAIL` : Accorde l'accès à l'adresse e-mail de l'utilisateur.
- `BDC` : Accorde l'accès aux informations de BDC de l'utilisateur.
- `AGENTS` : Accorde l'accès aux agents de l'utilisateur.

## Gestion des erreurs

Si une erreur se produit pendant le flux OAuth ou lors de l'accès aux ressources protégées, l'API renverra un code de statut HTTP approprié ainsi qu'une réponse d'erreur.

### Réponse d'erreur

```json
{
  "error": "Invalid client credentials"
}
```

## Exemples

Voici quelques exemples d'utilisation des points de terminaison OAuth :

### Demande d'autorisation

```
GET /oauth/authorize?clientId=123456&redirectUri=https://client-app.com/callback&scopes=read,write&state=abc123
```

### Échange de code d'autorisation contre un jeton d'accès

```
POST /oauth/token
Content-Type: application/json

{
  "grantType": "authorization_code",
  "code": "AUTH_CODE",
  "redirectUri": "https://client-app.com/callback",
  "clientId": "123456",
  "clientSecret": "SECRET"
}
```

### Rafraîchissement d'un jeton d'accès

```
POST /oauth/token
Content-Type: application/json

{
  "grantType": "refresh_token",
  "refreshToken": "REFRESH_TOKEN",
  "clientId": "123456",
  "clientSecret": "SECRET"
}
```

### Obtention d'un jeton d'accès avec les informations d'identification du client

```
POST /oauth/token
Content-Type: application/json

{
  "grantType": "client_credentials",
  "clientId": "123456",
  "clientSecret": "SECRET"
}
```

### Demande d'informations utilisateur

```
GET /oauth/userinfo
Authorization: Bearer ACCESS_TOKEN
```

Pour plus d'informations détaillées et d'exemples de code, veuillez consulter notre documentation d'API et nos guides SDK.

Si vous avez des questions ou avez besoin d'une assistance supplémentaire, n'hésitez pas à contacter notre équipe d'assistance à support@devana.ai.
