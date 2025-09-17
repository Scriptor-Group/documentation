# 📦 Mise à jour 0.3.8

## 🎉 Nouveautés
* **API permettant d'associer des fichiers à une base de connaissance** : La route `POST /v1/folders/:id/files` est désormais remplacé par `POST /v1/folders/:id/files`
* **API permettant de récupérer et de supprimer mes fichiers sur une base de co** : Ajout des routes de lecture et suppression des fichiers dans les bases de connaissances

## 🔧 Corrections
* **Problème RAGScore** : Résolution d'un problème d'affichage du RAGScore a plus de 100%.
* **Problème RAG** : Résolution d'un problème d'affichage des sources dans certains contextes.
* **Temperature** : Résolution d'un problème qui faisait que la température n'était pas modifiée correctement.
* **Agents** : Résolution du problème des agents partagés supprimés.

## 🔄 Mises à jour
* **Identité pré-prompt** : Amélioration des IA en mode strict.
* **Markdown** : Amélioration du rendu des textes en markdown lors des réponses du LLM.
* **Interface** : Diverses améliorations mineures de l'interface