## Version 0.6.0045

### 🚀 Nouvelles fonctionnalités
- 🔌 **Nouvel endpoint** : `GET /v1/agents/:id/tools` pour récupérer la liste des tools actifs d’un agent.
- 📈 **Tableau des métriques** : nombreuses nouvelles fonctionnalités et filtres.
- 🗑️ **Suppression automatique** des fichiers une fois traités via `AUTO_DELETE_FILES_PROVIDERS`.
- 🧰 Liste des tools : ajout de la notion de **tool parent** et de **filtres** (QOF).
- 🔗 **Crawling** : prise en charge des **liens de fichiers**.
- 🧱 **SharePoint** : possibilité de traiter les **données des SharePoint Lists** via le provider SharePoint.

### 💡 Améliorations
- 🕷️ **Crawling** : mise à jour majeure incluant plusieurs correctifs.
- 🧠 **RAG** : optimisations diverses et corrections.
- 🧾 **Description des tools** : augmentation de la longueur maximale autorisée.
- 🪪 **License checker** : moins restrictif pour éviter des downtimes si `l.devana.ai` est indisponible.
- 🔐 **URLs publiques des fichiers** : désormais accessibles uniquement aux personnes autorisées.

### 🐛 Corrections de bugs
- 🧭 Correction d’un bug sur `GET /v1/agents`.
- ⌨️ Correction d’un **raccourci clavier** qui ouvrait une fenêtre lors d’un `Ctrl+V` au lieu de coller dans une zone de texte.
- 👤 Correction d’un problème **de création de compte** dans certains cas, lié au nouveau système de SSO.
- 🖼️ Correction d’une **duplication de contexte** due aux captures d’écran.
- 🔐 Mises à jour de dépendances liées à la **sécurité**.