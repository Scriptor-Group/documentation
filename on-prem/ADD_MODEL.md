# Configuration des Modèles Personnalisés dans Devana

## Table des matières
- [Introduction](#introduction)
- [Configuration via l'Interface Administrateur](#configuration-via-linterface-administrateur)
- [Types de Modèles Supportés](#types-de-modèles-supportés)
- [Configuration Azure OpenAI](#configuration-azure-openai)
- [Configuration de Modèles Auto-hébergés](#configuration-de-modèles-auto-hébergés)
- [Bonnes Pratiques](#bonnes-pratiques)
- [Dépannage](#dépannage)

## Introduction

Devana permet l'intégration de modèles personnalisés pour répondre à des besoins spécifiques. Cette documentation détaille les différentes options de configuration disponibles.

## Configuration via l'Interface Administrateur

### Accès à l'Interface
1. Connectez-vous à l'interface Super Administrateur
2. Naviguez vers la section `Custom Model`
3. Cliquez sur `Ajouter un nouveau modèle`

### Champs de Configuration

#### Informations Générales
- **Nom** : Nom d'affichage du modèle
- **Description** : Description détaillée du modèle
- **Type de Modèle** : Type d'API utilisée (OpenAI, Azure, etc.)
- **Nombre de Jetons Maximum** : Limite de contexte
- **Logo** : Image représentative du modèle (format recommandé : PNG, max 2MB)

#### Configuration API
```json
{
  "model": "nom-du-modele",
  "apiKey": "VOTRE_CLE_API",
  "configuration": {
    "baseURL": "URL_DE_BASE_API",
    "temperature": 0.7,
    "maxTokens": 8000
  }
}
```

#### Configuration Embedding
```json
{
  "model": "nom-modele-embedding",
  "api_key": "VOTRE_CLE_API",
  "endpoint": "URL_ENDPOINT_EMBEDDING",
  "dimensions": 1024
}
```

## Types de Modèles Supportés

### OpenAI Compatible
```json
{
  "model": "gpt-4",
  "apiKey": "sk-...",
  "configuration": {
    "baseURL": "https://api.openai.com/v1",
    "temperature": 0.7
  }
}
```

### Mixtral (Auto-hébergé)
```json
{
  "model": "mistral-nemo",
  "apiKey": "EMPTY",
  "configuration": {
    "baseURL": "http://votre-serveur/v1",
    "maxTokens": 9000,
    "temperature": 0.8,
    "topP": 0.95
  }
}
```

### Llama 2 (Auto-hébergé)
```json
{
  "model": "llama2-70b",
  "apiKey": "EMPTY",
  "configuration": {
    "baseURL": "http://votre-serveur/v1",
    "maxTokens": 4096
  }
}
```

## Configuration Azure OpenAI

### Configuration Standard
```json
{
  "azureOpenAIApiKey": "VOTRE_CLE_API",
  "azureOpenAIApiEmbeddingsDeploymentName": "NOM_DEPLOYMENT_EMBEDDINGS",
  "azureOpenAIApiVersion": "2024-02-15",
  "azureOpenAIBasePath": "https://votre-instance.openai.azure.com/openai/deployments"
}
```

### Configuration avec Managed Identity
```json
{
  "useAzureManagedIdentity": true,
  "azureOpenAIApiInstanceName": "NOM_INSTANCE",
  "azureOpenAIApiDeploymentName": "NOM_DEPLOYMENT",
  "azureOpenAIApiVersion": "2024-02-15"
}
```

### Configuration Embedding Azure
```json
{
  "azureOpenAIApiKey": "VOTRE_CLE_API",
  "azureOpenAIApiInstanceName": "NOM_INSTANCE",
  "azureOpenAIApiEmbeddingsDeploymentName": "NOM_DEPLOYMENT_EMBEDDINGS",
  "azureOpenAIApiVersion": "2024-02-15",
  "dimensions": 1536
}
```

## Configuration de Modèles Auto-hébergés

### Prérequis
- API compatible OpenAI
- Support du streaming de réponses
- Endpoint d'embedding compatible

### Configuration Type
```json
{
  "model": "nom-modele",
  "apiKey": "EMPTY",
  "configuration": {
    "baseURL": "http://votre-serveur/v1",
    "maxTokens": 8192,
    "temperature": 0.7,
    "streamingEndpoint": "/chat/completions"
  }
}
```

## Bonnes Pratiques

### Sécurité
- Utilisez des clés API dédiées
- Configurez des restrictions IP si possible
- Activez le monitoring des appels API

### Performance
- Ajustez le `maxTokens` selon vos besoins
- Optimisez la `temperature` pour votre cas d'usage
- Configurez le rate limiting approprié

### Monitoring
- Surveillez l'utilisation des tokens
- Configurez des alertes de coûts
- Suivez les temps de réponse

## Dépannage

### Problèmes Courants
1. **Erreur de Connection**
   ```json
   {
     "error": "Unable to connect to API endpoint"
   }
   ```
   Solution : Vérifiez l'URL et les paramètres réseau

2. **Erreur d'Authentication**
   ```json
   {
     "error": "Invalid API key"
   }
   ```
   Solution : Vérifiez la validité et le format de la clé API

3. **Erreur de Configuration**
   ```json
   {
     "error": "Model not found"
   }
   ```
   Solution : Vérifiez le nom du modèle et sa disponibilité

### Logs et Debugging
```bash
# Vérification des logs
curl -X GET "http://votre-serveur/health/services"
curl -X POST "http://votre-serveur/v1/chat/completions" -d '{...}'
```

## Support

Pour toute assistance :
- Support technique : support@devana.ai
- Pour Azure Managed Identity : contact@devana.ai