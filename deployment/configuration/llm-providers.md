# Configuration des Providers LLM et Embeddings

Ce guide explique comment configurer les différents providers de modèles de langage (LLM) et d'embeddings dans Devana.

## Table des matières

- [Introduction](#introduction)
- [Providers supportés](#providers-supportés)
- [Configuration des Embeddings](#configuration-des-embeddings)
- [Configuration des Modèles de Chat](#configuration-des-modèles-de-chat)
- [Exemples pratiques](#exemples-pratiques)
- [Résolution de problèmes](#résolution-de-problèmes)

## Introduction

Devana permet de configurer différents providers pour :
- **Les embeddings** : transformation de texte en vecteurs pour la recherche sémantique
- **Les modèles de chat** : génération de réponses conversationnelles

La configuration se fait via des variables d'environnement dans votre fichier `.env`.

## Providers supportés

### Embeddings
- **OpenAI** - text-embedding-3-small, text-embedding-3-large, text-embedding-ada-002
- **Mistral AI** - mistral-embed
- **Ollama** - nomic-embed-text, mxbai-embed-large, et autres modèles locaux
- **Serveurs compatibles OpenAI** - vLLM, LiteLLM, LocalAI, etc.

### Modèles de Chat
- **OpenAI** - GPT-4, GPT-4 Turbo, GPT-3.5 Turbo
- **Mistral AI** - Mistral Large, Mistral Medium, Mistral Small
- **Anthropic** - Claude 3.5 Sonnet, Claude 3 Opus, Claude 3 Haiku
- **Ollama** - Llama 3, Mistral, Gemma, et autres modèles locaux
- **Serveurs compatibles OpenAI** - vLLM, LiteLLM, etc.

## Configuration des Embeddings

### Variables d'environnement

Ajoutez ces variables dans votre fichier `.env` :

```bash
# Configuration principale des embeddings
EMBEDDING_JSON='{"model":"nom-du-modele","apiKey":"votre-cle-api"}'

# (Optionnel) Configuration spécifique pour l'indexation
EMBEDDING_INDEX_JSON='{"model":"nom-du-modele","apiKey":"votre-cle-api"}'
```

**Note :** Si `EMBEDDING_INDEX_JSON` n'est pas défini, `EMBEDDING_JSON` sera utilisé pour l'indexation et l'inférence.

### OpenAI Embeddings

#### Configuration standard

```bash
EMBEDDING_JSON='{"model":"text-embedding-3-large","apiKey":"sk-..."}'
```

#### Champs disponibles

| Champ | Description | Exemple | Par défaut |
|-------|-------------|---------|------------|
| `model` | Nom du modèle | `"text-embedding-3-large"` | `"text-embedding-3-small"` |
| `apiKey` | Clé API OpenAI | `"sk-..."` | Variable env `OPENAI_API_KEY` |
| `serverURL` | URL du serveur (optionnel) | `"https://api.openai.com/v1"` | API OpenAI |
| `dimensions` | Dimension des vecteurs | `3072` | Auto selon le modèle |
| `batchSize` | Taille des lots | `100` | `512` |

#### Avec serveur custom (vLLM, LiteLLM, etc.)

```bash
EMBEDDING_JSON='{"model":"intfloat/e5-mistral-7b-instruct","apiKey":"votre-cle","serverURL":"http://votre-serveur.com/v1"}'
```

**⚠️ Important :** L'URL doit se terminer par `/v1` si votre serveur l'attend. Par exemple, si votre endpoint est `http://example.com/v1/embeddings`, utilisez `"serverURL":"http://example.com/v1"`.

### Mistral AI Embeddings

#### Configuration standard

```bash
EMBEDDING_JSON='{"model":"mistral-embed","apiKey":"votre-cle-mistral"}'
```

#### Champs disponibles

| Champ | Description | Exemple | Par défaut |
|-------|-------------|---------|------------|
| `model` | Nom du modèle | `"mistral-embed"` | `"mistral-embed"` |
| `apiKey` | Clé API Mistral | `"abc123..."` | - |
| `serverURL` | URL du serveur (optionnel) | `"https://api.mistral.ai"` | API Mistral |
| `batchSize` | Taille des lots | `50` | `100` |

### Ollama Embeddings

#### Configuration standard

```bash
EMBEDDING_JSON='{"model":"nomic-embed-text","baseURL":"http://localhost:11434"}'
```

#### Champs disponibles

| Champ | Description | Exemple | Par défaut |
|-------|-------------|---------|------------|
| `model` | Nom du modèle Ollama | `"nomic-embed-text"` | - |
| `baseURL` | URL du serveur Ollama | `"http://localhost:11434"` | `"http://localhost:11434"` |

**Note :** Le modèle doit être installé localement avec `ollama pull nom-du-modele`.

## Configuration des Modèles de Chat

### Configuration via Custom Models

Les modèles de chat se configurent principalement via l'interface d'administration de Devana :

1. Allez dans **Administration** → **Custom Models**
2. Cliquez sur **Ajouter un modèle**
3. Remplissez la configuration

Vous pouvez également définir les clés API directement dans le `.env` :

```bash
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
MISTRAL_API_KEY=...
```

### OpenAI Chat

#### Configuration de base

```json
{
  "model": "gpt-4o",
  "apiKey": "sk-...",
  "temperature": 0.7,
  "maxTokens": 4096
}
```

#### Champs disponibles

| Champ | Description | Exemple | Par défaut |
|-------|-------------|---------|------------|
| `model` | Nom du modèle | `"gpt-4o"` | `"gpt-4o"` |
| `apiKey` | Clé API OpenAI | `"sk-..."` | Variable env `OPENAI_API_KEY` |
| `serverURL` | URL du serveur | `"https://api.openai.com/v1"` | API OpenAI |
| `temperature` | Créativité (0-2) | `0.7` | - |
| `maxTokens` | Tokens max à générer | `4096` | - |
| `topP` | Top P sampling | `0.9` | - |

#### Avec serveur compatible OpenAI

```json
{
  "model": "llama-3-70b",
  "apiKey": "votre-cle",
  "serverURL": "http://votre-serveur.com/v1",
  "temperature": 0.7,
  "maxTokens": 8192
}
```

### Mistral AI Chat

#### Configuration de base

```json
{
  "model": "mistral-large-latest",
  "apiKey": "votre-cle-mistral",
  "temperature": 0.7
}
```

#### Champs disponibles

| Champ | Description | Exemple | Par défaut |
|-------|-------------|---------|------------|
| `model` | Nom du modèle | `"mistral-large-latest"` | `"mistral-large-latest"` |
| `apiKey` | Clé API Mistral | `"abc..."` | - |
| `serverURL` | URL du serveur | `"https://api.mistral.ai"` | API Mistral |
| `temperature` | Créativité (0-1) | `0.7` | - |
| `maxTokens` | Tokens max à générer | `8192` | - |
| `safePrompt` | Mode sécurisé | `true` | `false` |

### Anthropic Chat

#### Configuration de base

```json
{
  "model": "claude-3-5-sonnet-20241022",
  "apiKey": "sk-ant-...",
  "temperature": 0.7,
  "maxTokens": 8192
}
```

#### Champs disponibles

| Champ | Description | Exemple | Par défaut |
|-------|-------------|---------|------------|
| `model` | Nom du modèle | `"claude-3-5-sonnet-20241022"` | `"claude-3-5-sonnet-20241022"` |
| `apiKey` | Clé API Anthropic | `"sk-ant-..."` | Variable env `ANTHROPIC_API_KEY` |
| `temperature` | Créativité (0-1) | `0.7` | - |
| `maxTokens` | Tokens max à générer | `8192` | `4096` |
| `topP` | Top P sampling | `0.9` | - |

### Ollama Chat

#### Configuration de base

```json
{
  "model": "llama3:70b",
  "baseURL": "http://localhost:11434",
  "temperature": 0.7
}
```

#### Champs disponibles

| Champ | Description | Exemple | Par défaut |
|-------|-------------|---------|------------|
| `model` | Nom du modèle Ollama | `"llama3:70b"` | - |
| `baseURL` | URL du serveur Ollama | `"http://localhost:11434"` | `"http://localhost:11434"` |
| `temperature` | Créativité | `0.7` | - |
| `numPredict` | Tokens max | `2048` | - |

## Exemples pratiques

### Utiliser OpenAI pour tout

```bash
# Embeddings
EMBEDDING_JSON='{"model":"text-embedding-3-large","apiKey":"sk-..."}'

# Chat (via variable d'environnement)
OPENAI_API_KEY=sk-...
```

### Utiliser Mistral AI pour tout

```bash
# Embeddings
EMBEDDING_JSON='{"model":"mistral-embed","apiKey":"votre-cle-mistral"}'

# Chat (via variable d'environnement)
MISTRAL_API_KEY=votre-cle-mistral
```

### Setup local avec Ollama

```bash
# Embeddings
EMBEDDING_JSON='{"model":"nomic-embed-text","baseURL":"http://localhost:11434"}'

# Chat (via custom model dans l'interface)
# Model: llama3:70b
# Base URL: http://localhost:11434
```

### Mix de providers

```bash
# OpenAI pour les embeddings (qualité)
EMBEDDING_JSON='{"model":"text-embedding-3-large","apiKey":"sk-..."}'

# Anthropic pour le chat (Claude)
ANTHROPIC_API_KEY=sk-ant-...
```

### Utiliser un serveur d'embeddings custom

```bash
# Serveur vLLM ou LiteLLM avec un modèle open source
EMBEDDING_JSON='{"model":"intfloat/e5-mistral-7b-instruct","apiKey":"votre-cle","serverURL":"http://embeddings.example.com/v1"}'
```

### Différencier indexation et inférence

```bash
# Modèle performant pour l'indexation (fait une seule fois)
EMBEDDING_INDEX_JSON='{"model":"text-embedding-3-large","apiKey":"sk-..."}'

# Modèle rapide pour l'inférence (utilisé à chaque recherche)
EMBEDDING_JSON='{"model":"text-embedding-3-small","apiKey":"sk-..."}'
```

## Résolution de problèmes

### Erreur 404 - Not Found

**Symptôme :**
```
Error: 404 status code (no body)
```

**Cause :** L'URL du serveur est incorrecte.

**Solution :**

Vérifiez que votre `serverURL` se termine par `/v1` si votre serveur l'attend :

```bash
# ❌ Incorrect (si le serveur attend /v1)
EMBEDDING_JSON='{"serverURL":"http://embeddings.example.com"}'

# ✅ Correct
EMBEDDING_JSON='{"serverURL":"http://embeddings.example.com/v1"}'
```

Pour tester votre endpoint :
```bash
curl -X POST http://embeddings.example.com/v1/embeddings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer votre-cle" \
  -d '{"input":"test","model":"nom-du-modele"}'
```

### Erreur 401 - Unauthorized

**Symptôme :**
```
Error: 401 Unauthorized
```

**Cause :** La clé API est incorrecte ou manquante.

**Solutions :**

1. Vérifiez que votre clé API est correcte
2. Pour OpenAI, la clé doit commencer par `sk-`
3. Pour Anthropic, la clé doit commencer par `sk-ant-`
4. Vérifiez que la clé n'a pas expiré

### Erreur de parsing JSON

**Symptôme :**
```
Unexpected token in JSON
```

**Cause :** Le JSON dans le `.env` n'est pas correctement formaté.

**Solution :**

Utilisez toujours des **quotes simples** autour du JSON dans le `.env` :

```bash
# ❌ Incorrect (sans quotes)
EMBEDDING_JSON={"model":"xxx","apiKey":"xxx"}

# ✅ Correct (avec quotes simples)
EMBEDDING_JSON='{"model":"xxx","apiKey":"xxx"}'
```

### Le modèle n'est pas trouvé

**Symptôme :**
```
Model not found
```

**Cause :** Le nom du modèle est incorrect.

**Solutions :**

**Pour OpenAI :**
- Vérifiez la liste sur https://platform.openai.com/docs/models
- Exemples valides : `gpt-4o`, `gpt-4-turbo`, `text-embedding-3-large`

**Pour Mistral :**
- Vérifiez sur https://docs.mistral.ai/getting-started/models/
- Exemples valides : `mistral-large-latest`, `mistral-medium`, `mistral-embed`

**Pour Ollama :**
- Listez les modèles installés : `ollama list`
- Installez un modèle : `ollama pull llama3`

**Pour serveurs custom :**
- Vérifiez la documentation de votre serveur
- Testez avec `curl` pour confirmer le nom du modèle

### Erreur de timeout

**Symptôme :**
```
Request timeout
```

**Cause :** Le serveur met trop de temps à répondre.

**Solution :**

Augmentez le timeout dans votre configuration :

```json
{
  "model": "votre-modele",
  "apiKey": "votre-cle",
  "timeout": 60000
}
```

Le timeout est en millisecondes (60000 = 60 secondes).

### Problème de compatibilité des champs

**Symptôme :**
Le champ `modelName` ou `endpoint` ne fonctionne pas.

**Solution :**

Utilisez les champs standards pour une meilleure compatibilité :
- `model` au lieu de `modelName`
- `serverURL` au lieu de `endpoint`

Les anciens champs sont toujours supportés, mais les nouveaux sont recommandés :

```json
{
  "model": "votre-modele",
  "serverURL": "http://example.com/v1"
}
```

## Vérifier votre configuration

### Test des embeddings

Créez un fichier test et observez les logs :

```bash
# Démarrez le serveur
yarn dev

# Uploadez un fichier via l'interface
# Observez les logs pour vérifier que l'embedding fonctionne
```

Les logs devraient afficher :
```
[INFO] Content chunked
[DEBUG] Generating embedding for chunk
[DEBUG] Chunk embedded and saved successfully
```

### Test des modèles de chat

Testez via l'interface de chat de Devana :

1. Sélectionnez votre custom model
2. Envoyez un message test
3. Vérifiez que vous recevez une réponse

## Bonnes pratiques

### Sécurité

- ✅ Utilisez des variables d'environnement pour les clés API
- ✅ Ne commitez jamais le fichier `.env`
- ✅ Ajoutez `.env` dans votre `.gitignore`
- ✅ Renouvelez régulièrement vos clés API
- ✅ Utilisez des clés avec des permissions minimales

### Performance

- ✅ Utilisez `text-embedding-3-small` pour l'inférence rapide
- ✅ Utilisez `text-embedding-3-large` pour l'indexation de qualité
- ✅ Ajustez `batchSize` selon vos besoins (100-512 recommandé)
- ✅ Configurez des timeouts appropriés (30-60 secondes)

### Coûts

- ✅ Surveillez votre consommation API sur les dashboards des providers
- ✅ Utilisez des modèles moins chers pour le développement
- ✅ Envisagez Ollama pour un usage local sans coûts

### Fiabilité

- ✅ Gardez une configuration de backup (second provider)
- ✅ Testez les configurations avant le déploiement
- ✅ Documentez vos configurations pour votre équipe
- ✅ Vérifiez les logs régulièrement

## Ressources

### Documentation officielle des providers

- **OpenAI** : https://platform.openai.com/docs
- **Mistral AI** : https://docs.mistral.ai
- **Anthropic** : https://docs.anthropic.com
- **Ollama** : https://ollama.ai/docs

### Outils compatibles OpenAI

- **vLLM** : https://docs.vllm.ai
- **LiteLLM** : https://docs.litellm.ai
- **LocalAI** : https://localai.io/docs
- **Text Generation Inference** : https://huggingface.co/docs/text-generation-inference

### Support

Pour toute question ou problème :
1. Consultez les logs du serveur Devana
2. Vérifiez cette documentation
3. Contactez le support Devana
4. Consultez le repository GitHub de Devana
