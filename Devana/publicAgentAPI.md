# API Publique (Agents)

Pour chaque agent, vous avez la possibilité d'y ajouter une clé d'agent public. Cette clé d'agent public permet de gérer l'intégration de votre agent dans votre application. Cette clé d'API permet dans un premier temps la création de tokens pour vos utilisateurs lors du chargement de la page.

## Endpoints

### `GET /v1/chat/conversation/public/message/token`

Génère un jeton d'accès pour une nouvelle conversation publique associée à un modèle spécifique.

> [!IMPORTANT]
> Vous utilisez cette requête à l'ouverture du chat utilisateur.

#### En-têtes

- `Authorization` (obligatoire) : La clé API publique permettant d'authentifier la requête (format: `Bearer <API_KEY>`).

#### Réponses

- `200 OK` : Retourne le jeton d'accès généré pour la conversation publique.
- `401 Unauthorized` : Accès non autorisé si l'en-tête d'autorisation est manquant.
- `404 Not Found` : La clé API ou le modèle spécifié n'a pas été trouvé.

Payload d'exemple :
```json
{
    "token": "ae7e783c-7578-4a28-80fb-23c59f21d072"
}
```
  
### `GET /v1/chat/conversation/public/messages/:token`

Récupère les messages d'une conversation publique à l'aide d'un jeton de sécurité.

#### Paramètres

- `token` (obligatoire) : Le jeton de sécurité permettant d'accéder à la conversation publique.

#### Réponses

- `200 OK` : Retourne les messages de la conversation publique.
- `403 Forbidden` : Accès refusé si le jeton de sécurité n'est pas valide ou a été utilisé de manière suspecte.
- `404 Not Found` : La conversation associée au jeton n'a pas été trouvée.

```json
{
    "messages": [
        {
            "id": "cluosj5hh0000ab6adugihwih",
            "message": {
                "role": "system",
                "content": ""
            },
            "created": 1712450027141,
            "model": "GPT4",
            "conversation_id": "cluosj5hh0000ab6adugihwih",
            "usage": {
                "prompt_tokens": 0,
                "total_tokens": 0,
                "completion_tokens": 0
            }
        },
        {
            "id": "cluosrb2f0004a3ha8eut3hx0",
            "message": {
                "role": "user",
                "content": "Que propose Devana ?"
            },
            "created": 1712450407619,
            "model": "MIXTRAL_8X7B_DEVANA",
            "conversation_id": "cluosj5hh0000ab6adugihwih",
            "usage": {
                "prompt_tokens": 0,
                "total_tokens": 5,
                "completion_tokens": 0
            }
        },
        {
            "id": "cluosrb2p0006a3ha0xtf2ncu",
            "message": {
                "role": "assistant",
                "content": "Devana est une intelligence artificielle conçue pour optimiser et augmenter vos connaissances. Elle propose diverses fonctionnalités telles qu'une aide à la rédaction respectant les critères techniques, scientifiques ou journalistiques, une recherche d'informations avec des sources citées et vérifiables, une analyse de documents complexes, et un système de fact-checking en temps réel. Devana est également capable d'accéder à vos informations IT à tout moment et n'importe où, de structurer des documents et de les mettre aux normes, de rechercher et d'analyser de la jurisprudence, des lois et des doctrines juridiques, de traduire, résumer et expliquer des articles, des études et des documents académiques, et bien plus encore. Elle s'adapte à vos besoins et à votre niveau d'usage, que ce soit pour un usage personnel, éducatif ou professionnel."
            },
            "created": 1712450407633,
            "model": "MIXTRAL_8X7B_DEVANA",
            "conversation_id": "cluosj5hh0000ab6adugihwih",
            "usage": {
                "prompt_tokens": 0,
                "total_tokens": 254,
                "completion_tokens": 0
            }
        }
    ]
}
```

### `POST /v1/chat/conversation/public/message`

Envoie un message à une conversation publique.

#### En-têtes

- `Content-Type: application/json`

#### Corps de la requête

- `client_token` (obligatoire) : Le jeton client permettant d'authentifier la requête.
- `messages` (obligatoire) : Le contenu du message à envoyer.
- `stream` (optionnel) : Indique si la réponse doit être retournée en mode flux (stream).

```json
{
    "client_token": "ae7e783c-7578-4a28-80fb-23c59f21d072",
    "messages": [{
        "role": "user",
        "content": "Que propose Devana ?"
    }],
    "stream": true
}
```

#### Réponses

- `200 OK` : Le message a été envoyé avec succès à la conversation.
- `403 Forbidden` : Accès refusé si le jeton client n'est pas valide ou a été utilisé de manière suspecte.
- `429 Too Many Requests` : Trop de requêtes ont été effectuées en peu de temps.

__stream__
```
Exemple
de
reponse
[DONE]
```

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
