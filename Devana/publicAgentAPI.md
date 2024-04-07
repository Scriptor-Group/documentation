# API Publique (Agents)

Pour chaque agent, vous avez la possibilité d'y ajouter une clé d'agent public. Cette clé d'agent public permet de gérer l'intégration de votre agent dans votre application. Cette clé d'API permet dans un premier temps la création de tokens pour vos utilisateurs lors du chargement de la page.

## Endpoints

### `GET /v1/chat/conversation/public/message/token/:modelId`

Génère un jeton d'accès pour une nouvelle conversation publique associée à un modèle spécifique.

> [!IMPORTANT]
> Vous utilisez cette requête à l'ouverture du chat utilisateur.

#### Paramètres

- `modelId` (obligatoire) : L'identifiant du modèle (IA) pour lequel générer le jeton d'accès.

#### En-têtes

- `Authorization` (obligatoire) : La clé API publique permettant d'authentifier la requête (format: `Bearer <API_KEY>`).

#### Réponses

- `200 OK` : Retourne le jeton d'accès généré pour la conversation publique.
- `401 Unauthorized` : Accès non autorisé si l'en-tête d'autorisation est manquant.
- `404 Not Found` : La clé API ou le modèle spécifié n'a pas été trouvé.
  
### `GET /v1/chat/conversation/public/messages/:token`

Récupère les messages d'une conversation publique à l'aide d'un jeton de sécurité.

#### Paramètres

- `token` (obligatoire) : Le jeton de sécurité permettant d'accéder à la conversation publique.

#### Réponses

- `200 OK` : Retourne les messages de la conversation publique.
- `403 Forbidden` : Accès refusé si le jeton de sécurité n'est pas valide ou a été utilisé de manière suspecte.
- `404 Not Found` : La conversation associée au jeton n'a pas été trouvée.

### `POST /v1/chat/conversation/public/message`

Envoie un message à une conversation publique.

#### En-têtes

- `Content-Type: application/json`

#### Corps de la requête

- `client_token` (obligatoire) : Le jeton client permettant d'authentifier la requête.
- `message` (obligatoire) : Le contenu du message à envoyer.
- `stream` (optionnel) : Indique si la réponse doit être retournée en mode flux (stream).

#### Réponses

- `200 OK` : Le message a été envoyé avec succès à la conversation.
- `403 Forbidden` : Accès refusé si le jeton client n'est pas valide ou a été utilisé de manière suspecte.
- `429 Too Many Requests` : Trop de requêtes ont été effectuées en peu de temps.

## Sécurité

La sécurité est primordiale dans cette API. Voici les mesures de sécurité mises en place :

- **Jetons de sécurité (tokens)** : Les jetons de sécurité sont utilisés pour authentifier les requêtes et autoriser l'accès aux conversations publiques. Ils sont générés de manière unique et ont une durée de vie limitée. En cas d'utilisation suspecte ou de trop nombreuses requêtes en peu de temps, l'accès est refusé.

- **Clés API publiques** : Les clés API publiques servent à générer des jetons d'accès aux conversations publiques associées à des modèles spécifiques. Seules les clés API valides et actives sont acceptées.

- **Authentification OAuth2** : Les conversations non publiques nécessitent une authentification OAuth2 pour y accéder. Seuls les utilisateurs authentifiés et autorisés peuvent accéder à ces conversations.

- **Limites de débit (rate limiting)** : Des limites de débit sont appliquées pour prévenir les abus et les attaques par force brute. Si trop de requêtes sont effectuées en peu de temps, l'API retourne une erreur 429 (Too Many Requests).

- **Stockage sécurisé des données sensibles** : Les données sensibles, comme les jetons de sécurité et les clés API, sont stockées de manière sécurisée et ne sont pas exposées dans les réponses de l'API.

Il est fortement recommandé aux utilisateurs de l'API de suivre les meilleures pratiques de sécurité, notamment :

- Protéger les clés API et ne pas les partager.
- Utiliser des connexions sécurisées (HTTPS) pour toutes les requêtes.
- Valider et assainir les données d'entrée côté client avant de les envoyer à l'API.
- Stocker les jetons de sécurité de manière sécurisée côté client.

En suivant ces consignes de sécurité, vous contribuerez à garantir l'intégrité et la confidentialité des données lors de l'utilisation de l'API Publique (Agents).
