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

# Ajout d'un model Azure

Pour ajouter un modèle personnalisé à Devana, **Azure** vous pouvez l'ajouter via l'interface d'administration de Devana ou en utilisant l'accès base de données.

## Types de configuration

Il existe deux types de configuration pour les modèles personnalisés :
```json
{
  azureOpenAIApiKey: "<your_key>", // In Node.js defaults to process.env.AZURE_OPENAI_API_KEY
  azureOpenAIApiEmbeddingsDeploymentName: "<your_embedding_deployment_name>", // In Node.js defaults to process.env.AZURE_OPENAI_API_EMBEDDINGS_DEPLOYMENT_NAME
  azureOpenAIApiVersion: "<api_version>", // In Node.js defaults to process.env.AZURE_OPENAI_API_VERSION
  azureOpenAIBasePath:
    "https://westeurope.api.microsoft.com/openai/deployments", // In Node.js defaults to process.env.AZURE_OPENAI_BASE_PATH
}
```

Si vous souhaitez utiliser Azure Managed Identity, veilliez nous contacter pour plus d'informations. (contact@devana.ai)

## Pour l'embedding vous pouvez utiliser le code suivant :

```json
{
  azureOpenAIApiKey: "<your_key>",
  azureOpenAIApiInstanceName: "<your_instance_name>",
  azureOpenAIApiEmbeddingsDeploymentName:
    "<your_embeddings_deployment_name>",
  azureOpenAIApiVersion: "<api_version>",
}
```json
