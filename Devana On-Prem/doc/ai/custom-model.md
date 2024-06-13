# Ajout d'un model

Pour ajouter un modèle personnalisé à Devana, vous pouvez l'ajouter via l'interface d'administration de Devana ou en utilisant l'accès base de données.

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
