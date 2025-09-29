## Version 0.6.0053

### 🚀 Nouvelles fonctionnalités

- 🎯 **Choix du modèle pour le tooling** : possibilité de choisir le LLM utilisé pour le tooling, avec configuration du préprompt, de la température, et activation/désactivation du RAG getContext sur les tools.
- 📊 **Métriques anonymes** : implémentation complète de l'anonymisation des utilisateurs dans les statistiques des agents. Le toggle est désormais réservé aux administrateurs uniquement.
- 📈 **Améliorations du Challenger** : historique, dashboards et descriptions améliorés avec une interface plus complète.
- 📋 **Duplication de challenges** : possibilité de dupliquer un challenge existant.
- 🔍 **Filtres des tools améliorés** : mise à niveau du système de filtrage des tools.
- 🎫 **Bouton de ticket** : mise à jour du bouton "Nous contacter" vers un système de tickets.
- 🔭 **OpenTelemetry** : ajout du support OpenTelemetry pour l'observabilité de l'application.
- 🎨 **Choix du modèle pour les prompts de restriction** : possibilité de choisir le modèle utilisé pour les prompts de restriction.
- 📎 **Support ODP** : support des fichiers PowerPoint ODP pour Odin.

### 💡 Améliorations

- 🔄 **Refactorisation du code completions** : séparation et amélioration du code des completions pour une meilleure maintenabilité.
- 📊 **Métriques utilisateur** : division du fichier MetricsUser/index.tsx et optimisations diverses.
- 🎨 **Interface des métriques** : nouveaux composants réutilisables (MetricChart, TableMetricDocumentRagScore, MobileCard) pour afficher les métriques de manière optimisée.
- 📱 **Vue mobile** : amélioration de l'affichage des métriques sur mobile avec des composants dédiés.
- 🔧 **Hook personnalisé useMetricsQuery** : centralisation et simplification des requêtes GraphQL pour les métriques.
- 🛠️ **Utilitaires de métriques** : nouveaux constantes de plages de dates, générateurs de propriétés de graphiques et helpers de formatage.

### 🐛 Corrections de bugs

- 🔒 **Validation Zod** : ajout de validation Zod sur `/v1/chat/completions` pour prévenir les attaques DOS, notamment sur le paramètre `asyncRagScore` (booléen).
- 🖼️ **Authentification des images** : correction de l'authentification pour les images dans les messages markdown.
- 💥 **Crash UI URL undefined** : correction d'un crash de l'interface lié aux URLs undefined.
- 🤖 **Suggestions d'agents** : correction de bugs UI sur les suggestions d'agents et les messages de bienvenue.
- 🔗 **SharePoint** : corrections diverses sur l'intégration SharePoint.
- 📂 **Cron fichiers erreurs** : correction pour que les fichiers en erreur récupèrent bien les pièces jointes de conversation.
- 🗑️ **Suppression d'agent** : hotfix pour l'erreur Prisma de clé étrangère ConversationCalls lors de la suppression d'un agent.
- 🔧 **Variables d'environnement** : suppression de variables d'environnement inhabituelles pour SharePoint (ignore metadata).
- 📊 **Load more & totalCount** : correction du chargement paginé et du comptage total dans la base de connaissances et performances 3D.
- 🐛 **Debug obj blocked** : correction pour que les completions de chat dans l'objet debug soient bloquées si nécessaire.
- 📤 **Export CSV anonymisé** : correction de l'anonymisation des IDs utilisateurs dans les exports CSV selon la configuration de l'agent.