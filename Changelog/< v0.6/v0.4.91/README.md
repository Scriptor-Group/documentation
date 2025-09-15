# CHANGELOG

## Version 0.4.91 (Avril 2025)

### 🚀 Nouvelles fonctionnalités

- ✨ Nouvelle interface `/setup` permettant la première configuration après installation (il n'est plus nécessaire d'avoir accès à la BDD)
- 🔌 Nouvelle API REST permettant de récupérer les informations d'un agent
- 🧪 Ajout de la possibilité de tester l'usage des tools des agents via le challenger (beta)
- 📨 Ajout d'un bouton permettant l'envoi d'un mail avec un rapport d'erreur sur les fichiers en erreur d'extraction par Odin v2
- 🔐 Ajout du mode agent de production sur les agents
- 🌐 Ajout du support des Proxy dans l'application, celle-ci peut faire passer 100% du traffic via un proxy interne

### 💡 Améliorations

- 📊 Passage de la BDD vectorielle en version RUST pour un gain de performance
- 🔍 Amélioration du comportement du RAG sur la recherche d'informations
- 📄 Amélioration de l'aperçu des pages avec de la pagination cliquable par page
- 📎 Amélioration du support des pièces jointes
- 🔄 Amélioration de l'api permettant la récupération des jobs
- 🔑 Meilleure gestion des clés API pour une marque blanche
- 📋 Ajout d'une variable d'env permettant l'anonymisation des données personnelles dans les metrics

### 🔗 Support étendu des liens

- 🌍 Support des noms de domaine dans les liens SharePoint
- 📊 Support des liens dans les Excel
- 🖼️ Récupération des attributs ALT / TITLE sur les balises img des fichiers HTML et ASPX

### 🌍 Internationalisation

- 🌐 Pré-prompt multilingue

### 🔒 Sécurité

- 🛡️ Correction d'un problème de sécurité au niveau des clés API
- 🔐 Mise à jour d'éléments de sécurité

### 🐛 Corrections de bugs

- 🖥️ Fix d'un problème d'affichage de la réponse qui disparaissait sous certaines conditions
- 🔄 Correction d'un problème d'accès à un SharePoint partagé dans une base de connaissances

### 📋 Compatibilité

- 📂 Prise en charge officielle de SharePoint On-prem (Stable)
- 👥 Ajout d'un mode permettant l'accès à d'autres collaborateurs à une session SharePoint rattachée à une base de connaissance

# Version précedente

Les détails de la version 0.4.2 a été publiée dans le changement précédent.
