# Endpoints API Devana.ai

Guide de navigation pour choisir les bons endpoints selon vos besoins.

---

## 🎯 Quelle API utiliser ?

### 🔐 Agents - API Privée (Gestion complète)

**📄 [Documentation : agents.md](./agents.md)**

**Utilisez cette API si vous voulez :**
- Gérer vos agents (création, modification, suppression)
- Lister tous vos agents
- Récupérer les détails complets d'un agent (configuration avancée)
- Ajouter des fichiers à un agent
- Gérer les tools actifs sur un agent
- Accéder aux conversations d'un agent

**Authentification :** Clé API privée (Bearer token)

**Endpoints principaux :**
- `GET /v1/agents` - Liste tous vos agents
- `POST /v1/agents` - Créer un agent
- `GET /v1/agent/:id` - Récupérer un agent (détaillé)
- `PUT /v1/agents/:id` - Mettre à jour un agent
- `DELETE /v1/agents/:id` - Supprimer un agent

---

### 🌐 Agents - API Publique (Intégration frontend)

**📄 [Documentation : agents-public.md](./agents-public.md)**

**Utilisez cette API si vous voulez :**
- Intégrer un agent dans votre application web
- Créer des conversations publiques pour vos utilisateurs finaux
- Générer des tokens de session pour vos utilisateurs
- Permettre à vos utilisateurs de discuter avec un agent sans authentification

**Authentification :** Clé API publique (Bearer token) + tokens de session

**Endpoints principaux :**
- `GET /v1/chat/conversation/public/message/token` - Générer un token de session
- `GET /v1/chat/conversation/public/messages/:token` - Récupérer les messages
- `POST /v1/chat/conversation/public/message` - Envoyer un message

**⚠️ Important :** Cette API est conçue pour être appelée depuis votre backend pour générer des tokens, puis utilisée depuis votre frontend avec ces tokens.

---

## 💬 Conversations

### API Privée (Gestion)

**📄 [Documentation : conversations.md](./conversations.md)**

**Pour :**
- Gérer vos conversations privées
- Récupérer les métriques détaillées
- Supprimer des conversations
- Lister toutes vos conversations

**Authentification :** Clé API privée

---

### API Publique (Widgets)

**📄 [Documentation : public-conversations.md](./public-conversations.md)**

**Pour :**
- Créer des conversations publiques embedables
- Intégrer des widgets de chat
- Gérer les conversations publiques

**Authentification :** Clé API publique

---

## 🚀 Autres endpoints

### Chat Completions
**📄 [Documentation : completions.md](./completions.md)**

Endpoint principal pour converser avec les agents (streaming, RAG, tools).

---

### Gestion des fichiers
**📄 [Documentation : files.md](./files.md)**

Upload multi-fichiers (jusqu'à 5000) avec extraction de contenu.

---

### Dossiers (Bases de connaissances)
**📄 [Documentation : folders.md](./folders.md)**

Gestion des dossiers et bases de connaissances pour vos agents.

---

### Documents
**📄 [Documentation : documents.md](./documents.md)**

Extraction et traitement de documents avec Odin.

---

### Interactions
**📄 [Documentation : interactions.md](./interactions.md)**

Feedback utilisateur et actions sur les conversations.

---

### Jobs
**📄 [Documentation : jobs.md](./jobs.md)**

Monitoring des tâches asynchrones (extraction, embeddings, etc.).

---

## 🔍 Tableau récapitulatif

| Besoin | Documentation | Authentification |
|--------|---------------|------------------|
| **Gérer mes agents** | [agents.md](./agents.md) | Clé API privée |
| **Intégrer un agent dans mon app** | [agents-public.md](./agents-public.md) | Clé API publique |
| **Converser avec un agent** | [completions.md](./completions.md) | Clé API privée |
| **Gérer mes conversations** | [conversations.md](./conversations.md) | Clé API privée |
| **Widget chat public** | [public-conversations.md](./public-conversations.md) | Clé API publique |
| **Upload de fichiers** | [files.md](./files.md) | Clé API privée |
| **Gérer les dossiers** | [folders.md](./folders.md) | Clé API privée |
| **Traiter des documents** | [documents.md](./documents.md) | Clé API privée |
| **Feedback utilisateur** | [interactions.md](./interactions.md) | Clé API privée |
| **Monitoring des jobs** | [jobs.md](./jobs.md) | Clé API privée |

---

## 📖 Ressources complémentaires

- [Documentation API complète](../README.md)
- [Authentification OAuth 2.0](../authentication/oauth.md)
- [Formats supportés](../reference/supported-formats.md)
- [Guide d'intégration IFrame](../integration/iframe.md)
- [Configuration des Tools](../integration/tools.md)
