# 🚀 Mise à jour 0.4.0

## 🎉 Nouveautés  
- **Amélioration de la gestion des fichiers** : Ajout et optimisation des routes pour la gestion des fichiers dans les bases de connaissances.  
- **Support des documents volumineux** : Optimisation du traitement des fichiers volumineux avec une amélioration des performances du `document-parser-v2` aka **Odin**.
- **Mise à jour des workflows et des permissions** :  
  - Amélioration des accès Super Admin sur l’UI.
  - Ajout de nouvelles options de configuration pour les clients whitemark.

## 🛠 Corrections  
- **Correction des problèmes de crawling** : Résolution d’un bug lié au crawling récursif.  
- **Correction OAuth** : Correction d’un problème avec pour OAuth et API Key.  
- **Fix RAG** : Affichage corrigé des sources dans certains contextes.  
- **Fix sur la gestion des fichiers attachés** : Correction des erreurs de traitement des fichiers joints.  
- **Fix sur la gestion des paiements** : Résolution de bugs liés aux paiements en environnement on-premise.  
- **Fix sur la date dans le pré-prompt** : Ajustement de l'affichage de la date pour éviter les incohérences.  
- **Corrections UI** :  
  - Amélioration de l'affichage et des chargements des bases de connaissances.  
  - Correction d’un problème d’affichage sur certains écrans.  

## 🔄 Mises à jour vers Odin

- **Faire un backup** de la base de donnée postgreSQL
- Mettre à jour l'infrastructure pour prendre en compte Odin et bien le connecter à l'API et aux autres services
- Envoyer une requête HTTP sur l'API `GET:/migration/odin/update`
:warning: Pendant la migration, Devana ne sera pas disponible.

Dans le cas d'une erreur, vous pouvez tenter de passer la propriété `status` de la table `DevanaMigration` en `ERROR` ou vous pouvez retenter l'opération.