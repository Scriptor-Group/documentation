## Version 0.6.0007

### 🚀 Nouvelles fonctionnalités
- 📊 **Métriques** : ajout de nouveaux **filtres**.
- 👯 **Agents** : possibilité de **dupliquer** un agent.
- 🎞️ **Traitement des fichiers vidéo**.
- 🛡️ Affichage d’un **statut** lorsque qu’un message est **bloqué** par le **prompt de sécurité** (le message reste en *pending*).
- 🔑 **Support des clés API dans les headers**.

### 💡 Améliorations
- 🧰 **Refonte** du système de **debug**.
- 🗄️ **Optimisations BDD**.
- ⚙️ **Refonte** de la gestion des **variables d’environnement**.
- 🧾 **Déduplication** : un fichier n’est pas retraité si son **MD5** existe déjà.

### 🐛 Corrections de bugs
- ☁️ **Azure health** : correctifs lorsque S3 n’est pas utilisé.
- 🧷 Correction d’un problème de **sécurité** lié à la réutilisation de **file IDs** sur plusieurs conversations.
- 🔧 Correction sur le provider **Jira**.
- 🧪 **Challenger** : mise à jour et correctifs.