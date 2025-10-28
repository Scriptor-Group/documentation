# Intégration Devana.ai

Guide complet pour intégrer Devana.ai dans vos applications web et créer des outils personnalisés.

---

## 🎯 Types d'intégration disponibles

### 🖼️ Intégration IFrame

**📄 [Documentation : iframe.md](./iframe.md)**

**Utilisez cette méthode si vous voulez :**
- Intégrer rapidement un agent dans votre site web
- Créer un chatbot visible sur votre page
- Aucune compétence backend requise
- Solution plug-and-play simple

**Fonctionnalités :**
- Embedding direct via `<iframe>`
- Agents publics accessibles sans authentification
- Personnalisation via query parameters (metadata, preprompt)
- Responsive et personnalisable avec CSS

**Démarrage rapide :**
```html
<iframe
  src="https://app.devana.ai/chat/{AGENT_ID}/"
  width="500"
  height="600"
></iframe>
```

---

### 💬 Widget Chatbot (IFrame Avancé)

**📄 [Documentation : iframe-examples.md](./iframe-examples.md)**

**Exemple complet pour :**
- Créer un chatbot flottant (coin de page)
- Bouton d'ouverture/fermeture
- Interface responsive et moderne

**Fonctionnalités :**
- Chatbot positionné en bas à droite
- Animation d'ouverture/fermeture
- Code HTML/CSS/JS prêt à l'emploi
- Personnalisable selon votre charte graphique

---

### 🛠️ Tools Personnalisés (Custom Tools)

**📄 [Documentation : tools.md](./tools.md)**

**Utilisez les Tools pour :**
- Étendre les capacités de vos agents avec des API externes
- Connecter vos services métier à l'IA
- Créer des actions personnalisées (recherche BDD, webhooks, etc.)
- Valider les inputs avec des schémas Zod

**Types de Tools :**
1. **Tools Standards** : Intégrés automatiquement au LLM
2. **Tools Développés** : Créés par l'équipe Devana (RAG, recherche web)
3. **Custom Tools Clients** : Configurables par vous via l'interface

**Fonctionnalités techniques :**
- Validation des données avec **Zod schemas**
- Authentification flexible (Headers, Query params, None)
- Méthodes HTTP : GET, POST
- Confirmation d'exécution optionnelle
- Header `x-user-id` automatiquement ajouté
- Limitation du nombre d'appels par agent

**Architecture d'un Tool :**
```typescript
{
  name: "MonTool",           // Nom unique
  description: "...",        // Description pour le LLM
  schema: z.object({...}),  // Validation Zod
  func: async (params) => {} // Logique d'exécution
}
```

**Exemple d'utilisation :**
1. Créer un Tool via l'interface Devana
2. Configurer l'URL de votre API
3. Définir le schéma des paramètres attendus
4. Activer le Tool sur votre agent
5. L'agent appellera automatiquement votre Tool quand nécessaire

---

## 📊 Tableau comparatif

| Méthode | Complexité | Backend requis | Personnalisation | Use case |
|---------|------------|----------------|------------------|----------|
| **IFrame simple** | ⭐ Facile | Non | Limitée | Chatbot public basique |
| **Widget Chatbot** | ⭐⭐ Moyen | Non | Moyenne | Chatbot flottant stylisé |
| **Custom Tools** | ⭐⭐⭐ Avancé | Oui | Totale | Intégration métier complexe |

---

## 🚀 Démarrage rapide

### Option 1 : IFrame Basique (5 minutes)

1. Créez un agent public sur [app.devana.ai](https://app.devana.ai)
2. Copiez l'URL de l'agent
3. Intégrez dans votre HTML :
   ```html
   <iframe src="https://app.devana.ai/chat/{AGENT_ID}/" width="500" height="600"></iframe>
   ```

### Option 2 : Widget Chatbot (15 minutes)

Suivez le guide complet dans [iframe-examples.md](./iframe-examples.md) avec code HTML/CSS/JS prêt à l'emploi.

### Option 3 : Custom Tool (30-60 minutes)

1. Développez votre API backend (GET ou POST)
2. Créez un Tool via l'interface Devana
3. Configurez l'authentification et les paramètres
4. Activez le Tool sur votre agent

---

## 🔐 Authentification

### IFrame (Agents publics)
- **Aucune authentification requise** pour l'utilisateur final
- L'agent doit être configuré comme **public** dans Devana
- Authentification optionnelle via clé API publique (voir [agents-public.md](../endpoints/agents-public.md))

### Custom Tools
- **Authentification par clé API** configurée dans l'interface
- Types supportés : `Headers`, `Query params`, `None`
- Header `x-user-id` automatiquement ajouté à chaque requête

---

## 📖 Cas d'usage courants

### Chatbot Support Client
→ [iframe-examples.md](./iframe-examples.md) - Widget flottant avec design moderne

### Assistant IA Embedé
→ [iframe.md](./iframe.md) - Intégration complète dans une page

### Connexion à votre CRM/ERP
→ [tools.md](./tools.md) - Custom Tool avec authentification API

### Recherche dans votre Base de Données
→ [tools.md](./tools.md) - Tool avec validation Zod des paramètres

### Webhook sur événement
→ [tools.md](./tools.md) - Tool POST vers votre service

---

## 🔗 Ressources complémentaires

### Documentation API
- [Agents API](../endpoints/agents.md) - Gestion des agents
- [API Publique](../endpoints/agents-public.md) - Agents publics et tokens de session
- [Completions](../endpoints/completions.md) - Chat et streaming

### Guides d'intégration
- [Authentification OAuth](../authentication/oauth.md)
- [Formats supportés](../reference/supported-formats.md)

### SDK et outils
- [devana-ws-tools](../../sdks/devana-ws-tools.md) - Client WebSocket pour intégrations temps réel
- [n8n-nodes-devana](../../sdks/n8n-nodes-devana.md) - Module n8n pour workflows

---

## 💬 Support

- **Documentation** : Consultez ce repository
- **Support technique** : support-it@devana.ai
- **Bugs & Issues** : [tyr.devana.ai](https://tyr.devana.ai)

---

## 🎓 Exemples complets

Tous les fichiers de cette section incluent des exemples de code complets et prêts à l'emploi :

- [iframe.md](./iframe.md) - HTML IFrame avec metadata et preprompt
- [iframe-examples.md](./iframe-examples.md) - Code complet HTML/CSS/JS pour chatbot
- [tools.md](./tools.md) - Exemples TypeScript avec Express.js et Zod
