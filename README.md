# Documentation Devana

Devana est une plateforme d'intelligence artificielle destinée aux organisations : agents conversationnels, recherche dans les documents internes et intégration aux applications métier. Elle est disponible en service hébergé ou peut être déployée sur l'infrastructure de l'organisation (on-premise ou cloud privé).

Cette documentation s'adresse aux développeurs qui intègrent Devana, aux équipes qui l'installent et l'exploitent, et aux responsables de la sécurité et de la protection des données.

## Par où commencer

| Vous souhaitez | Point d'entrée |
|---|---|
| Appeler l'API depuis une application | [Démarrage rapide de l'API](./api/README.md#démarrage-rapide) |
| Intégrer un assistant dans un site web | [Intégration par iframe](./api/integration/iframe.md) |
| Donner aux agents l'accès à vos services | [Outils personnalisés](./api/integration/tools.md) |
| Automatiser des traitements | [Nœuds n8n](./sdks/n8n-nodes-devana.md) |
| Installer Devana sur votre infrastructure | [Prérequis et dimensionnement](./deployment/requirements.md) |
| Connecter votre annuaire d'entreprise | [Authentification unique (SSO)](./deployment/authentication/README.md) |
| Évaluer la sécurité et la protection des données | [Exigences de sécurité](./deployment/requirements.md#-requirements-sécurité) et [politique de confidentialité](./others/RGPD.md) |

## Produits

| Produit | Rôle | Documentation |
|---|---|---|
| Plateforme Devana | Agents IA, conversations, bases de connaissances, API | [API](./api/README.md), [déploiement](./deployment/README.md) |
| Odin | Extraction du contenu des documents (texte, tableaux, OCR) | [Service Odin](./deployment/services/services/odin.md) |
| Argos | Connecteur SharePoint on-premise pour les agents (MCP) | [Argos](./deployment/argos/README.md) |
| Compléments Office Suite 366 | Assistant IA dans Word, Excel, PowerPoint et Outlook | [Compléments Office](./deployment/office-addins/README.md) |
| SDK et intégrations | WebSocket, n8n, streaming des réponses | [SDK](./sdks/README.md) |

## Premier appel à l'API

L'API est accessible en HTTPS à l'adresse `https://api.devana.ai` et reprend le format OpenAI Chat Completions. Chaque requête est authentifiée par une clé API, créée dans **Paramètres > API** de l'application.

```bash
curl https://api.devana.ai/v1/chat/completions \
  -H "Authorization: Bearer $DEVANA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "ID_DE_L_AGENT",
    "messages": [{ "role": "user", "content": "Bonjour" }]
  }'
```

Le champ `model` contient l'identifiant de l'agent qui répond. Paramètres, streaming et sources des réponses : [référence Chat Completions](./api/endpoints/completions.md).

## Déployer sur votre infrastructure

1. [Prérequis et dimensionnement](./deployment/requirements.md) : matériel, réseau, stockage, modèles de langage, Kubernetes.
2. [Architecture](./deployment/architecture.md) : composants et flux entre les services.
3. [Installation sur Kubernetes](./deployment/infrastructure/kubernetes/kube/README.md) et [base de données PostgreSQL](./deployment/infrastructure/database/db/postgresql.md).
4. [Variables d'environnement](./deployment/configuration/environment-variables.md) et [fournisseurs de modèles](./deployment/configuration/llm-providers.md).
5. [Authentification unique](./deployment/authentication/README.md) : Microsoft Entra ID, Google Workspace, LDAP, OpenID Connect, OAuth 2.0.
6. [Supervision des services](./deployment/monitoring/health-checks.md) et [suivi de la licence](./deployment/monitoring/license.md).

## Sécurité et conformité

- **Maîtrise de l'hébergement** : la plateforme peut être déployée entièrement sur l'infrastructure de l'organisation, avec des [modèles de langage hébergés en interne](./deployment/requirements.md#-requirements-llm--embeddings).
- **Exigences de sécurité** : chiffrement en transit et au repos, authentification unique, contrôle d'accès par rôles, journalisation et segmentation réseau sont détaillés dans les [exigences de sécurité](./deployment/requirements.md#-requirements-sécurité).
- **Protection des données** : [politique de confidentialité et de conservation des données](./others/RGPD.md) et [sous-traitants du support situés hors de l'EEE](./others/sous-traitants-hors-ue.md).

## Dernières versions

| Composant | Version | Historique |
|---|---|---|
| Plateforme Devana | 1.3.2 | [Notes de version](./changelogs/devana/README.md) |
| Odin | 2.0.26 | [Notes de version](./changelogs/odin/README.md) |

## Assistance

- **Support technique** : [support-it@devana.ai](mailto:support-it@devana.ai)
- **Portail de support** : [tyr.devana.ai](https://tyr.devana.ai)
- **Signaler un incident** : [informations à joindre au rapport](./deployment/troubleshooting/common-issues.md)
- **Site** : [www.devana.ai](https://www.devana.ai)
