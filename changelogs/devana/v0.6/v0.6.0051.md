## Version 0.6.0051

### 📚 Documentation

- 📝 **Paramètre asyncRagScore pour l'API** : ajout de la documentation du paramètre `asyncRagScore` dans l'endpoint `/v1/chat/completions`. Lorsque ce paramètre est activé (`true`), la réponse est renvoyée immédiatement sans attendre le calcul du score RAG, qui sera effectué en arrière-plan. Dans ce mode, les sources ne seront pas incluses dans la réponse (tableau vide `[]`).