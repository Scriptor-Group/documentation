# Devana Custom Model

Pour ajouter un modèle custom dans Devana, suivez les étapes suivantes :

1. Rendez-vous dans l'interface `Super Administrateur`.
2. Accédez à la section `Custom Model`.
3. Ajoutez un nouveau modèle en remplissant les informations nécessaires.

## Exemple de Configuration

- **Nom** : `Mixtral 8x22-FP8`
- **Description** : `Hosted by Devana`
- **Modèle** : `Open AI` (correspond au type d'API utilisé)
- **Configuration du Modèle** :
  ```json
  {
    "model": "mistral-nemo",
    "apiKey": "EMPTY",
    "configuration": {
      "baseURL": "http://exemple/v1"
    }
  }
  ```
- **Embedding** : `Mistral`
- **Configuration de l'Embedding** :
  ```json
  {
    "model": "intfloat/e5-mistral-7b-instruct",
    "api_key": "EMPTY",
    "endpoint": "http://exemple"
  }
  ```
- **Nombre de jetons maximum** : `9000`
- **Logo** : Le logo de votre choix
