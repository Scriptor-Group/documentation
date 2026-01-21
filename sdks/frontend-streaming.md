# Guide d'Intégration du Streaming Chat Completions

## Vue d'ensemble

Ce guide explique comment intégrer correctement l'API de streaming chat completions de Devana dans votre application. Il couvre la gestion du streaming SSE (Server-Sent Events), le parsing des tokens, la gestion des balises spéciales (`<think>`, `[tool:]`), et les bonnes pratiques d'implémentation.

## Table des matières

1. [Architecture du streaming](#architecture-du-streaming)
2. [Configuration de la requête](#configuration-de-la-requête)
3. [Parsing du flux SSE](#parsing-du-flux-sse)
4. [Gestion des balises spéciales](#gestion-des-balises-spéciales)
5. [Gestion de l'état des messages](#gestion-de-létat-des-messages)
6. [Gestion des erreurs](#gestion-des-erreurs)
7. [Exemple d'implémentation complète](#exemple-dimplémentation-complète)
8. [Bonnes pratiques](#bonnes-pratiques)

---

## Architecture du streaming

Le système de streaming repose sur le protocole SSE (Server-Sent Events) qui permet au serveur d'envoyer des mises à jour en temps réel au client. Chaque "chunk" (morceau) reçu contient un token qui peut être :

- Du texte normal à afficher
- Une balise `<think>` pour les réflexions internes de l'IA
- Une balise `[tool:]` pour les appels d'outils

### Format des messages SSE

```
data: {"choices":[{"delta":{"content":"token"}}],"conversation_id":"conv-123"}

data: [DONE]
```

---

## Configuration de la requête

### Endpoint

```
POST /v1/chat/completions
```

### Headers requis

```typescript
{
  "Content-Type": "application/json",
  "Authorization": "Bearer YOUR_TOKEN"
}
```

### Corps de la requête

```typescript
{
  "stream": true,                          // Active le streaming
  "messages": [
    { "role": "user", "content": "..." }   // Vos messages
  ],
  "files": ["file-id-1", "file-id-2"],    // IDs de fichiers (optionnel)
  "clientModel": "model-name",             // Modèle spécifique (optionnel)
  "conversation_id": "conv-123",           // ID de conversation (optionnel)
  "model": "agent-id"                      // ID de l'agent
}
```

### Exemple avec Fetch API

```typescript
const response = await fetch("/v1/chat/completions", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    Authorization: `Bearer ${token}`,
  },
  body: JSON.stringify({
    stream: true,
    messages: [{ role: "user", content: message }],
    conversation_id: chatId,
    model: agentId,
  }),
  signal: abortController.signal, // Pour permettre l'annulation
});
```

---

## Parsing du flux SSE

Le parsing du flux SSE nécessite une attention particulière car les données peuvent arriver en morceaux incomplets.

### Algorithme de parsing

```typescript
const reader = response.body.getReader();
let buffer = "";
let lastFailedChunk = "";

while (true) {
  const { done, value } = await reader.read();
  if (done) break;

  // Ajouter les nouvelles données au buffer
  buffer += new TextDecoder().decode(value);

  let splitIndex: number;

  // Traiter tous les messages complets dans le buffer
  while ((splitIndex = buffer.indexOf("\n\n")) !== -1) {
    const messageWithLastFail = buffer.slice(0, splitIndex).trim();
    buffer = buffer.slice(splitIndex + 2);

    // Ignorer les messages non-data
    if (!messageWithLastFail.startsWith("data:")) continue;

    // Fin du flux
    if (messageWithLastFail === "data: [DONE]") continue;

    try {
      // Extraire et parser le JSON
      const jsonString = messageWithLastFail.replace(/^data:\s*/, "");
      const jsonData = JSON.parse(jsonString);
      lastFailedChunk = "";

      // Extraire le token
      const token = jsonData?.choices?.[0]?.delta?.content;
      if (token) {
        processStreamChunk(token); // Traiter le token
      }

      // Capturer le conversation_id pour les nouvelles conversations
      if (jsonData.conversation_id) {
        conversationId = jsonData.conversation_id;
      }
    } catch (e) {
      // Si le parsing échoue, remettre dans le buffer
      // (peut arriver si le message est incomplet)
      if (messageWithLastFail === lastFailedChunk) continue;
      lastFailedChunk = messageWithLastFail;
      buffer = messageWithLastFail + "\n\n" + buffer;
      break;
    }
  }
}
```

### Points clés du parsing

1. **Buffer** : Accumule les données jusqu'à avoir un message complet (`\n\n`)
2. **Retry logic** : Si un chunk échoue au parsing, on le réessaye une fois puis on passe au suivant
3. **conversation_id** : Récupérer l'ID pour les nouvelles conversations ou le tracking

---

## Gestion des balises spéciales

### 1. Balises `<think>` - Réflexions internes

Les balises `<think>` contiennent la chaîne de pensée de l'IA et ne doivent pas être affichées dans le message principal.

#### Format

```
<think>
Je dois d'abord vérifier les données...
Ensuite calculer le résultat...
</think>
Voici la réponse finale
```

#### Extraction

```typescript
function extractThinkAndMainContent(message: string) {
  let thinkContent = "";
  let mainContent = "";
  let currentPos = 0;
  let hasThinkBlock = false;

  while (currentPos < message.length) {
    const thinkStart = message.indexOf("<think>", currentPos);

    if (thinkStart === -1) {
      // Plus de balises <think>, ajouter le reste au contenu principal
      mainContent += message.substring(currentPos);
      break;
    }

    hasThinkBlock = true;
    // Ajouter le contenu avant <think> au contenu principal
    mainContent += message.substring(currentPos, thinkStart);

    const thinkEnd = message.indexOf("</think>", thinkStart);

    if (thinkEnd === -1) {
      // Bloc <think> ouvert (streaming en cours)
      const content = message.substring(thinkStart + 7);
      if (thinkContent && content) thinkContent += "\n\n---\n\n";
      thinkContent += content;
      break;
    } else {
      // Bloc <think> fermé
      const content = message.substring(thinkStart + 7, thinkEnd);
      if (thinkContent && content) thinkContent += "\n\n---\n\n";
      thinkContent += content;
      currentPos = thinkEnd + 8;
    }
  }

  // Nettoyage
  thinkContent = thinkContent.trim();
  mainContent = mainContent.replace(/<\/think>/g, "").trim();

  return { thinkContent, mainContent, hasThinkBlock };
}
```

#### Affichage UI

```typescript
// Dans votre composant de message
const { thinkContent, mainContent, hasThinkBlock } = extractThinkAndMainContent(message);

return (
  <>
    {hasThinkBlock && (
      <ThinkPanel
        content={thinkContent}
        isStreaming={isStreaming}
      />
    )}
    <MarkdownContent content={mainContent} />
  </>
);
```

### 2. Balises `[tool:]` - Exécution d'outils

Les balises `[tool:]` signalent qu'un outil est en cours d'exécution ou terminé.

#### Format

Les balises tool peuvent avoir deux formats selon l'implémentation serveur :

```typescript
// Démarrage d'un outil (toujours en JSON)
[tool:start:{"name":"web_search","args":{"query":"météo Paris"}}]

// Fin d'un outil - Format 1 : Simple (juste le nom)
[tool:end:web_search]

// Fin d'un outil - Format 2 : JSON structuré
[tool:end:{"name":"web_search"}]
```

**Note importante** : Le format `[tool:end:]` peut varier selon la configuration serveur. Votre code doit gérer les deux formats.

#### Parsing et gestion

```typescript
interface ToolInfo {
  id: string;
  name: string;
  args: Record<string, unknown>;
  startTime: number;
  endTime?: number;
}

function processStreamChunk(token: string) {
  // Détecter les balises tool
  if (token.startsWith("[tool:")) {
    const toolMatch = token.match(/\[tool:(start|end):(.+)\]/);

    if (toolMatch) {
      const [, action, dataString] = toolMatch;

      try {
        let toolData;

        // Essayer de parser en JSON d'abord
        try {
          toolData = JSON.parse(dataString);
        } catch {
          // Si ce n'est pas du JSON, c'est probablement juste le nom (format simple)
          // Format : [tool:end:ToolName]
          toolData = { name: dataString };
        }

        if (action === "start") {
          // Créer un ID unique pour tracer l'outil
          const uniqueId = `${toolData.name}-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;

          const toolInfo: ToolInfo = {
            id: uniqueId,
            name: toolData.name,
            args: toolData.args || {},
            startTime: Date.now(),
          };

          // Ajouter aux outils en cours
          setRunnedTools((prev) => [...prev, toolInfo]);
          setActiveTool(toolInfo);
        } else if (action === "end") {
          // Marquer l'outil comme terminé
          setActiveTool((prev) => {
            if (prev?.name === toolData.name) {
              setRunnedTools((tools) =>
                tools.map((t) =>
                  t.id === prev.id ? { ...t, endTime: Date.now() } : t,
                ),
              );
              return null;
            }
            return prev;
          });
        }
      } catch (e) {
        console.error("Error parsing tool data", e);
      }
    }

    // Important : ne pas ajouter ce token au contenu du message
    return;
  }

  // Token normal, l'ajouter au message
  setStreamedResponse((prev) => prev + token);
}
```

#### Affichage UI des outils

```typescript
interface ToolExecutionPanelProps {
  runnedTools: ToolInfo[];
  activeTool: ToolInfo | null;
  isStreaming: boolean;
}

function ToolExecutionPanel({ runnedTools, activeTool, isStreaming }: ToolExecutionPanelProps) {
  return (
    <div className="tool-panel">
      <h4>
        {isStreaming ? "Exécution des outils" : "Outils exécutés"}
        <Badge count={runnedTools.length} />
      </h4>

      {runnedTools.map((tool, index) => (
        <ToolStep
          key={tool.id}
          toolInfo={tool}
          status={activeTool?.id === tool.id ? "running" : "completed"}
          index={index}
        />
      ))}

      {/* Afficher l'outil actif s'il n'est pas déjà dans la liste */}
      {activeTool && !runnedTools.some(t => t.id === activeTool.id) && (
        <ToolStep
          toolInfo={activeTool}
          status="running"
          index={runnedTools.length}
        />
      )}
    </div>
  );
}
```

### 3. Balises `[tool:confirm:]` - Confirmation utilisateur

Certains outils nécessitent une confirmation de l'utilisateur avant d'être exécutés.

#### Format

```typescript
[tool:confirm:{"messageId":"msg-123","toolName":"delete_file","args":{...}}]
```

#### Gestion

```typescript
const TOOL_CONFIRM_KEY = "[tool:confirm:";

// Dans le rendu des messages
if (message.startsWith(TOOL_CONFIRM_KEY)) {
  return (
    <ToolConfirmDialog
      message={message}
      onConfirm={async (confirmed) => {
        // Envoyer la réponse de confirmation
        await sendMessage(
          `[tool:confirm:${JSON.stringify({
            messageId: message.id,
            confirm: confirmed
          })}]`
        );
      }}
    />
  );
}
```

---

## Gestion de l'état des messages

### Structure des messages

```typescript
interface Message {
  id: string;
  role: "USER" | "ASSISTANT" | "SYSTEM";
  message: string;
  status: "complete" | "streaming" | "temporary" | "error";
  fiability?: "GOOD" | "BAD" | "DEFAULT";
  comment?: string;
  files?: File[];
  sources?: Source[];
  runnedTools?: ToolInfo[];
  activeTool?: ToolInfo | null;
}
```

### États du flux de conversation

1. **Message temporaire utilisateur** : Affiché immédiatement lors de l'envoi
2. **Attente de réponse** : Indicateur de chargement
3. **Streaming assistant** : Message en cours de réception avec `status: "streaming"`
4. **Message complet** : Streaming terminé avec `status: "complete"`

### Gestion des états

```typescript
function useChat() {
  const [isStreaming, setIsStreaming] = useState(false);
  const [streamedResponse, setStreamedResponse] = useState("");
  const [temporaryQuestion, setTemporaryQuestion] = useState("");
  const [waitingForResponse, setWaitingForResponse] = useState(false);
  const [runnedTools, setRunnedTools] = useState<ToolInfo[]>([]);
  const [activeTool, setActiveTool] = useState<ToolInfo | null>(null);

  // Messages combinés : historique + messages temporaires
  const messages = useMemo(() => {
    const msgs: Message[] = [...historyMessages];

    // Ajouter la question temporaire
    if (temporaryQuestion) {
      msgs.push({
        id: "temp-user",
        role: "USER",
        message: temporaryQuestion,
        status: "temporary",
      });
    }

    // Ajouter la réponse en cours de streaming
    if (
      streamedResponse ||
      isStreaming ||
      activeTool ||
      runnedTools.length > 0
    ) {
      // Vérifier qu'on ne duplique pas avec l'historique
      const lastHistoryMsg = msgs[msgs.length - 1];
      const cleanStream = streamedResponse
        .replace(/<think>[\s\S]*?<\/think>/, "")
        .trim();
      const cleanHistory = lastHistoryMsg?.message
        ?.replace(/<think>[\s\S]*?<\/think>/, "")
        ?.trim();

      const isDuplicate =
        lastHistoryMsg?.role === "ASSISTANT" &&
        !isStreaming &&
        (lastHistoryMsg?.message === streamedResponse ||
          cleanHistory === cleanStream ||
          (cleanStream.length > 10 && cleanHistory?.includes(cleanStream)));

      if (!isDuplicate) {
        msgs.push({
          id: "streaming-assistant",
          role: "ASSISTANT",
          message: streamedResponse,
          status: isStreaming ? "streaming" : "complete",
          runnedTools,
          activeTool,
        });
      }
    }

    return msgs;
  }, [
    historyMessages,
    temporaryQuestion,
    streamedResponse,
    isStreaming,
    runnedTools,
    activeTool,
  ]);

  return { messages /* ... */ };
}
```

### Prévention des duplications

Lors du passage du streaming à l'historique permanent, il faut éviter d'afficher le même message deux fois :

```typescript
// Comparer le contenu sans les balises <think>
const cleanStream = streamedResponse
  .replace(/<think>[\s\S]*?<\/think>/, "")
  .trim();
const cleanHistory = lastHistoryMsg?.message
  ?.replace(/<think>[\s\S]*?<\/think>/, "")
  ?.trim();

const isDuplicate =
  lastHistoryMsg?.role === "ASSISTANT" &&
  !isStreaming &&
  (lastHistoryMsg?.message === streamedResponse ||
    cleanHistory === cleanStream ||
    (cleanStream.length > 10 && cleanHistory?.includes(cleanStream)));
```

---

## Gestion des erreurs

### Annulation de requête

```typescript
const abortControllerRef = useRef<AbortController | null>(null);

function sendMessage(message: string) {
  // Créer un nouveau controller pour cette requête
  abortControllerRef.current = new AbortController();

  try {
    const response = await fetch(url, {
      // ...
      signal: abortControllerRef.current.signal,
    });
    // ...
  } catch (error) {
    if (error.name !== "AbortError") {
      // Erreur réelle, afficher un message
      toast.error("Impossible d'envoyer le message");
    }
    // Si c'est AbortError, c'est une annulation volontaire
  } finally {
    abortControllerRef.current = null;
  }
}

function stopRequest() {
  if (abortControllerRef.current) {
    abortControllerRef.current.abort();
  }
  setIsStreaming(false);
  setWaitingForResponse(false);
  setTemporaryQuestion("");
}
```

### Gestion des erreurs réseau

```typescript
async function sendMessage(message: string) {
  try {
    const response = await fetch(url, {
      /* ... */
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    if (!response.body) {
      throw new Error("No response body");
    }

    // Traiter le flux...
  } catch (error) {
    if (error.name === "AbortError") {
      // Annulation volontaire, ne rien faire
      return;
    }

    // Erreur réelle
    console.error("Stream error:", error);
    toast.error("Erreur lors de l'envoi du message");

    // Réinitialiser les états
    setIsStreaming(false);
    setWaitingForResponse(false);
    setTemporaryQuestion("");
  }
}
```

### Timeout

```typescript
// Créer un timeout pour la requête
const timeoutId = setTimeout(() => {
  abortControllerRef.current?.abort();
  toast.error("La requête a pris trop de temps");
}, 60000); // 60 secondes

try {
  // ... traitement du streaming
} finally {
  clearTimeout(timeoutId);
}
```

---

## Exemple d'implémentation complète

Voici un exemple React complet d'intégration :

```typescript
import { useCallback, useEffect, useMemo, useRef, useState } from "react";

interface ToolInfo {
  id: string;
  name: string;
  args: Record<string, unknown>;
  startTime: number;
  endTime?: number;
}

interface Message {
  id: string;
  role: "USER" | "ASSISTANT" | "SYSTEM";
  message: string;
  status: "complete" | "streaming" | "temporary" | "error";
  runnedTools?: ToolInfo[];
  activeTool?: ToolInfo | null;
}

export function useChat({ chatId, agentId, userToken }) {
  const [isStreaming, setIsStreaming] = useState(false);
  const [streamedResponse, setStreamedResponse] = useState("");
  const [temporaryQuestion, setTemporaryQuestion] = useState("");
  const [waitingForResponse, setWaitingForResponse] = useState(false);
  const [runnedTools, setRunnedTools] = useState<ToolInfo[]>([]);
  const [activeTool, setActiveTool] = useState<ToolInfo | null>(null);
  const abortControllerRef = useRef<AbortController | null>(null);

  // Charger l'historique des messages (GraphQL, REST, etc.)
  const historyMessages = useMemo(() => {
    // Votre logique de chargement
    return [];
  }, [chatId]);

  // Messages combinés
  const messages = useMemo(() => {
    const msgs: Message[] = [...historyMessages];

    if (temporaryQuestion) {
      msgs.push({
        id: "temp-user",
        role: "USER",
        message: temporaryQuestion,
        status: "temporary",
      });
    }

    if (
      streamedResponse ||
      isStreaming ||
      activeTool ||
      runnedTools.length > 0
    ) {
      msgs.push({
        id: "streaming-assistant",
        role: "ASSISTANT",
        message: streamedResponse,
        status: isStreaming ? "streaming" : "complete",
        runnedTools,
        activeTool,
      });
    }

    return msgs;
  }, [
    historyMessages,
    temporaryQuestion,
    streamedResponse,
    isStreaming,
    runnedTools,
    activeTool,
  ]);

  // Traiter un chunk du stream
  const processStreamChunk = useCallback((token: string) => {
    // Gestion des outils
    if (token.startsWith("[tool:")) {
      const toolMatch = token.match(/\[tool:(start|end):(.+)\]/);
      if (toolMatch) {
        const [, action, dataString] = toolMatch;
        try {
          let toolData;

          // Essayer de parser en JSON d'abord
          try {
            toolData = JSON.parse(dataString);
          } catch {
            // Si ce n'est pas du JSON, c'est le format simple : [tool:end:ToolName]
            toolData = { name: dataString };
          }

          if (action === "start") {
            const uniqueId = `${toolData.name}-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
            const toolInfo: ToolInfo = {
              id: uniqueId,
              name: toolData.name,
              args: toolData.args || {},
              startTime: Date.now(),
            };
            setRunnedTools((prev) => [...prev, toolInfo]);
            setActiveTool(toolInfo);
          } else if (action === "end") {
            setActiveTool((prev) => {
              if (prev?.name === toolData.name) {
                setRunnedTools((tools) =>
                  tools.map((t) =>
                    t.id === prev.id ? { ...t, endTime: Date.now() } : t,
                  ),
                );
                return null;
              }
              return prev;
            });
          }
        } catch (e) {
          console.error("Error parsing tool data", e);
        }
      }
      return;
    }

    // Token normal
    setStreamedResponse((prev) => prev + token);
  }, []);

  // Envoyer un message
  const sendMessage = useCallback(
    async (message: string, files: string[] = []) => {
      if (!message) return;

      setTemporaryQuestion(message);
      setWaitingForResponse(true);
      setIsStreaming(true);
      setStreamedResponse("");
      setRunnedTools([]);
      setActiveTool(null);

      const url = "/v1/chat/completions";
      abortControllerRef.current = new AbortController();

      try {
        const response = await fetch(url, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${userToken}`,
          },
          body: JSON.stringify({
            stream: true,
            messages: [{ role: "user", content: message }],
            files,
            conversation_id: chatId,
            model: agentId,
          }),
          signal: abortControllerRef.current.signal,
        });

        if (!response.ok || !response.body) {
          throw new Error("Request failed");
        }

        setWaitingForResponse(false);

        const reader = response.body.getReader();
        let buffer = "";
        let lastFailedChunk = "";
        let finalChatId = chatId;

        while (true) {
          const { done, value } = await reader.read();
          if (done) break;

          buffer += new TextDecoder().decode(value);
          let splitIndex: number;

          while ((splitIndex = buffer.indexOf("\n\n")) !== -1) {
            const messageWithLastFail = buffer.slice(0, splitIndex).trim();
            buffer = buffer.slice(splitIndex + 2);

            if (!messageWithLastFail.startsWith("data:")) continue;
            if (messageWithLastFail === "data: [DONE]") continue;

            try {
              const jsonString = messageWithLastFail.replace(/^data:\s*/, "");
              const jsonData = JSON.parse(jsonString);
              lastFailedChunk = "";

              const token = jsonData?.choices?.[0]?.delta?.content;
              if (token) processStreamChunk(token);

              if (
                jsonData.conversation_id &&
                (!chatId || chatId !== jsonData.conversation_id)
              ) {
                finalChatId = jsonData.conversation_id;
              }
            } catch (e) {
              if (messageWithLastFail === lastFailedChunk) continue;
              lastFailedChunk = messageWithLastFail;
              buffer = messageWithLastFail + "\n\n" + buffer;
              break;
            }
          }
        }

        // Stream terminé
        setIsStreaming(false);
        setTemporaryQuestion("");

        // Rafraîchir l'historique
        if (finalChatId) {
          // Votre logique pour rafraîchir avec le nouvel ID
        }
      } catch (error) {
        if (error.name !== "AbortError") {
          console.error("Stream error:", error);
          // Afficher une erreur à l'utilisateur
        }
        setIsStreaming(false);
        setWaitingForResponse(false);
      } finally {
        abortControllerRef.current = null;
      }
    },
    [chatId, agentId, userToken, processStreamChunk],
  );

  // Arrêter le streaming
  const stopRequest = useCallback(() => {
    if (abortControllerRef.current) {
      abortControllerRef.current.abort();
    }
    setIsStreaming(false);
    setWaitingForResponse(false);
    setTemporaryQuestion("");
  }, []);

  return {
    messages,
    sendMessage,
    stopRequest,
    isStreaming,
    waitingForResponse,
  };
}
```

---

## Bonnes pratiques

### 1. Performance

- **Utiliser `requestAnimationFrame`** pour le scroll automatique pendant le streaming
- **Mémoriser les composants** avec `React.memo` pour éviter les re-renders inutiles
- **Debounce les updates UI** si le streaming est très rapide

```typescript
useEffect(() => {
  if (isStreaming && isAttachedToBottom) {
    requestAnimationFrame(() => {
      scrollContainerRef.current?.scrollTo({
        top: scrollContainerRef.current.scrollHeight,
        behavior: "auto",
      });
    });
  }
}, [messages, isStreaming, isAttachedToBottom]);
```

### 2. UX

- **Indicateur de streaming** : Afficher clairement que l'IA est en train de répondre
- **Bouton stop** : Permettre à l'utilisateur d'arrêter le streaming
- **Scroll automatique** : Suivre le message pendant le streaming, avec possibilité de désactiver
- **Affichage progressif** : Montrer le texte au fur et à mesure, pas par blocs

```typescript
<button
  onClick={stopRequest}
  disabled={!isStreaming}
>
  {isStreaming ? "Arrêter la génération" : "Génération terminée"}
</button>
```

### 3. Gestion d'état

- **Réinitialiser les états** lors du changement de conversation
- **Nettoyer les AbortControllers** dans les effets cleanup
- **Éviter les duplications** entre messages streaming et historique

```typescript
useEffect(() => {
  // Reset quand la conversation change
  setStreamedResponse("");
  setIsStreaming(false);
  setTemporaryQuestion("");
  setWaitingForResponse(false);
  setRunnedTools([]);
  setActiveTool(null);
}, [chatId]);
```

### 4. Accessibilité

- **ARIA labels** sur les boutons et indicateurs
- **Annonces** pour les lecteurs d'écran quand un message arrive
- **Focus management** lors de l'envoi de messages

```typescript
<div role="log" aria-live="polite" aria-atomic="false">
  {messages.map(msg => (
    <div key={msg.id} aria-label={`Message de ${msg.role}`}>
      {msg.message}
    </div>
  ))}
</div>
```

### 5. Sécurité

- **Échapper le HTML** dans les messages pour éviter les XSS
- **Valider les tokens** avant de les ajouter au DOM
- **Limiter la taille** du buffer pour éviter les attaques par overflow

````typescript
function escapeHtml(text: string): string {
  return text
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

// Appliquer uniquement en dehors des blocs de code
function addEscapeOutsideCodeBlocks(input: string): string {
  const segments = input.split(/(```[\s\S]*?```|`[^`]*`)/);
  return segments
    .map((segment, i) => {
      if (i % 2 === 0) {
        // Échapper uniquement en dehors des blocs de code
        return segment.replace(/</g, "&lt;").replace(/>/g, "&gt;");
      }
      return segment;
    })
    .join("");
}
````

### 6. Tests

```typescript
// Test du parsing SSE
describe("SSE Parsing", () => {
  it("should parse complete messages", () => {
    const chunk = 'data: {"choices":[{"delta":{"content":"Hello"}}]}\n\n';
    const result = parseSSEChunk(chunk);
    expect(result.token).toBe("Hello");
  });

  it("should handle incomplete messages", () => {
    const chunk1 = 'data: {"choices":[{"delta":';
    const chunk2 = '{"content":"Hello"}}]}\n\n';
    const buffer = chunk1 + chunk2;
    const result = parseSSEChunk(buffer);
    expect(result.token).toBe("Hello");
  });
});

// Test de l'extraction des balises think
describe("Think Tag Extraction", () => {
  it("should extract think content", () => {
    const message = "<think>Thinking...</think>Response";
    const { thinkContent, mainContent } = extractThinkAndMainContent(message);
    expect(thinkContent).toBe("Thinking...");
    expect(mainContent).toBe("Response");
  });

  it("should handle unclosed think tags", () => {
    const message = "<think>Thinking...";
    const { thinkContent, mainContent } = extractThinkAndMainContent(message);
    expect(thinkContent).toBe("Thinking...");
    expect(mainContent).toBe("");
  });
});

// Test des balises tool
describe("Tool Tags", () => {
  it("should parse tool start", () => {
    const token = '[tool:start:{"name":"search","args":{"q":"test"}}]';
    const result = parseToolTag(token);
    expect(result.action).toBe("start");
    expect(result.name).toBe("search");
    expect(result.args).toEqual({ q: "test" });
  });
});
```

---

## Résumé

L'intégration du streaming chat completions nécessite :

1. ✅ **Parser correctement le flux SSE** avec gestion du buffer
2. ✅ **Extraire les balises `<think>`** pour les afficher séparément
3. ✅ **Gérer les balises `[tool:]`** pour afficher l'exécution des outils
4. ✅ **Maintenir l'état des messages** (temporaires, streaming, complets)
5. ✅ **Prévenir les duplications** entre streaming et historique
6. ✅ **Gérer les erreurs** et permettre l'annulation
7. ✅ **Optimiser les performances** avec mémorisation et RAF
8. ✅ **Assurer une bonne UX** avec indicateurs et scroll automatique

En suivant ce guide, vous pourrez intégrer de manière robuste et performante le système de streaming chat completions de Devana dans votre application.

---

## Support

Pour toute question ou problème d'intégration, n'hésitez pas à consulter notre documentation complète ou à contacter notre support technique.
