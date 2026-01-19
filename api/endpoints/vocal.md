# Devana Vocal Mode - Guide d'intégration

Ce guide explique comment fonctionne le mode vocal de Devana et comment l'intégrer dans votre propre application.

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture](#architecture)
3. [Protocole WebRTC](#protocole-webrtc)
4. [Détection vocale (VAD)](#détection-vocale-vad)
5. [Modèles utilisés](#modèles-utilisés)
6. [Événements DataChannel](#événements-datachannel)
7. [Intégration client](#intégration-client)
8. [Paramètres configurables](#paramètres-configurables)
9. [Gestion des fichiers](#gestion-des-fichiers)
10. [Exemples de code](#exemples-de-code)

---

## Vue d'ensemble

Le mode vocal Devana permet une interaction conversationnelle en temps réel avec un agent IA. L'utilisateur parle dans son microphone, sa voix est transcrite, envoyée à l'IA, et la réponse est synthétisée vocalement.

### Flux de données

```
┌─────────────┐     WebRTC Audio      ┌─────────────┐
│   Client    │ ◄──────────────────► │   Serveur   │
│  (Browser)  │                       │   Devana    │
└─────────────┘                       └─────────────┘
       │                                     │
       │  DataChannel (événements JSON)      │
       │ ◄─────────────────────────────────► │
       │                                     │
       │                              ┌──────┴──────┐
       │                              │     VAD     │
       │                              │  (Détection │
       │                              │   vocale)   │
       │                              └──────┬──────┘
       │                                     │
       │                              ┌──────┴──────┐
       │                              │     STT     │
       │                              │ (Speech to  │
       │                              │    Text)    │
       │                              └──────┬──────┘
       │                                     │
       │                              ┌──────┴──────┐
       │                              │     LLM     │
       │                              │  (Agent IA) │
       │                              └──────┬──────┘
       │                                     │
       │                              ┌──────┴──────┐
       │                              │     TTS     │
       │                              │  (Text to   │
       │                              │   Speech)   │
       │                              └─────────────┘
```

---

## Architecture

### Composants

| Composant       | Rôle                                              | Technologie              |
| --------------- | ------------------------------------------------- | ------------------------ |
| **WebRTC**      | Transport audio bidirectionnel temps réel         | RTCPeerConnection        |
| **DataChannel** | Canal de données pour événements et configuration | RTCDataChannel           |
| **VAD**         | Détection d'activité vocale côté serveur          | Algorithme RMS adaptatif |
| **STT**         | Transcription parole → texte                      | Whisper (faster-whisper) |
| **LLM**         | Génération de réponse                             | API Devana Completions   |
| **TTS**         | Synthèse texte → parole                           | Piper TTS                |

---

## Protocole WebRTC

### Établissement de la connexion

1. **Création de l'offre SDP** (côté client)
2. **Envoi au serveur** via HTTP POST
3. **Réception de la réponse SDP**
4. **Établissement du flux audio bidirectionnel**

### Endpoint

```
POST /v1/chat/vocal
Content-Type: application/json
Authorization: Bearer <token>

{
  "sdp": "<SDP offer string>",
  "agentId": "<ID de l'agent Devana>"
}
```

### Réponse

```json
{
  "sdp": "<SDP answer string>",
  "sessionId": "<UUID de la session>"
}
```

### Configuration ICE

Le serveur utilise un serveur STUN public pour la traversée NAT :

```javascript
iceServers: [{ urls: "stun:stun.l.google.com:19302" }];
```

### DataChannel

Le DataChannel doit être créé **côté client** avec le label `"events"` :

```javascript
const channel = peerConnection.createDataChannel("events", { ordered: true });
```

---

## Détection vocale (VAD)

Le VAD (Voice Activity Detection) est un algorithme adaptatif basé sur l'énergie RMS du signal audio.

### Fonctionnement

1. **Calibration initiale** (~1 seconde) : Mesure du bruit de fond ambiant
2. **Calcul des seuils dynamiques** : Basés sur le noise floor
3. **Détection de début de parole** : Énergie > seuil de démarrage pendant ~80ms
4. **Détection de fin de parole** : Silence > durée configurée

### Paramètres adaptatifs

| Paramètre                   | Description                                        | Valeur par défaut |
| --------------------------- | -------------------------------------------------- | ----------------- |
| `speechStartMultiplier`     | Multiplicateur noise floor pour détecter la parole | 3.5x              |
| `speechEndMultiplier`       | Multiplicateur pour détecter la fin                | 1.8x              |
| `silenceDurationMs`         | Durée de silence avant traitement                  | 1500ms            |
| `speechStartDebounceFrames` | Anti-rebond (évite faux positifs)                  | 8 frames (~80ms)  |
| `maxSpeechDurationMs`       | Durée max avant traitement forcé                   | 2000ms            |

### Protection contre les faux positifs

- **Debounce** : 8 frames consécutives au-dessus du seuil requises
- **Validation de pic** : Un pic d'énergie minimum doit être atteint
- **Tolérance micro-pics** : Les pics < 30ms pendant le silence sont ignorés

---

## Modèles utilisés

### STT (Speech-to-Text)

- **Modèle** : Whisper (via faster-whisper)
- **Variante** : `faster-whisper-small`
- **Langues** : Multi-langue avec détection automatique
- **Format d'entrée** : WAV 16kHz mono 16-bit

### TTS (Text-to-Speech)

- **Moteur** : Piper TTS
- **Modèle** : `fr_FR-upmc-medium` (français)
- **Format de sortie** : WAV 22050Hz

### LLM

- **API** : Devana Completions (`/v1/chat/completions`)
- **Streaming** : Oui (Server-Sent Events)
- **Contexte** : Historique de conversation maintenu

---

## Événements DataChannel

Le serveur envoie des événements JSON via le DataChannel pour informer le client de l'état du système.

### Événements serveur → client

#### `user_speech_start`

L'utilisateur a commencé à parler.

```json
{ "type": "user_speech_start" }
```

#### `user_speech_end`

L'utilisateur a arrêté de parler.

```json
{ "type": "user_speech_end" }
```

#### `processing`

Indique l'étape de traitement en cours.

```json
{ "type": "processing", "stage": "stt" | "llm" | "tts" }
```

#### `transcription`

Texte transcrit de la parole utilisateur.

```json
{ "type": "transcription", "text": "Bonjour, comment ça va ?" }
```

#### `response_text`

Texte de la réponse de l'IA (streaming).

```json
{ "type": "response_text", "text": "Je vais ", "partial": true }
```

#### `tts_start`

Début de la synthèse vocale.

```json
{ "type": "tts_start", "text": "Je vais bien, merci !" }
```

#### `tts_end`

Fin de la synthèse vocale.

```json
{ "type": "tts_end" }
```

#### `vad_stats`

Statistiques VAD en temps réel (pour debug/visualisation).

```json
{
  "type": "vad_stats",
  "energy": 245.5,
  "noiseFloor": 52.3,
  "speechStartThreshold": 183.1,
  "speechEndThreshold": 94.1,
  "peakEnergy": 412.8,
  "isSpeaking": true,
  "calibrationProgress": 100
}
```

#### `error`

Erreur survenue côté serveur.

```json
{ "type": "error", "message": "STT transcription failed" }
```

### Événements client → serveur

#### `settings_update`

Mise à jour des paramètres.

```json
{
  "type": "settings_update",
  "settings": {
    "vadSensitivity": 7,
    "silenceDuration": 1000,
    "language": "fr"
  }
}
```

#### `files_update`

Mise à jour des fichiers attachés.

```json
{
  "type": "files_update",
  "fileIds": ["file-id-1", "file-id-2"]
}
```

---

## Intégration client

### Prérequis

- Navigateur compatible WebRTC (Chrome, Firefox, Safari, Edge)
- Accès au microphone de l'utilisateur
- Token d'authentification Devana valide

### Étapes d'intégration

#### 1. Demander l'accès au microphone

```javascript
const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
```

#### 2. Créer la connexion WebRTC

```javascript
const peerConnection = new RTCPeerConnection({
  iceServers: [{ urls: "stun:stun.l.google.com:19302" }],
});

// Ajouter la piste audio locale
stream.getTracks().forEach((track) => {
  peerConnection.addTrack(track, stream);
});
```

#### 3. Créer le DataChannel

```javascript
const dataChannel = peerConnection.createDataChannel("events", {
  ordered: true,
});

dataChannel.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log("Event:", data.type, data);

  switch (data.type) {
    case "user_speech_start":
      // L'utilisateur parle
      break;
    case "transcription":
      // Afficher la transcription
      break;
    case "response_text":
      // Afficher la réponse de l'IA
      break;
    case "tts_start":
      // L'IA commence à parler
      break;
    case "tts_end":
      // L'IA a fini de parler
      break;
  }
};
```

#### 4. Recevoir l'audio du serveur

```javascript
const remoteAudio = new Audio();
remoteAudio.autoplay = true;

peerConnection.ontrack = (event) => {
  if (event.streams && event.streams[0]) {
    remoteAudio.srcObject = event.streams[0];
  }
};
```

#### 5. Créer et envoyer l'offre SDP

```javascript
const offer = await peerConnection.createOffer();
await peerConnection.setLocalDescription(offer);

// Attendre la fin du gathering ICE
await waitForIceGathering(peerConnection);

// Envoyer au serveur
const response = await fetch("https://api.devana.ai/v1/chat/vocal", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    Authorization: `Bearer ${userToken}`,
  },
  body: JSON.stringify({
    sdp: peerConnection.localDescription.sdp,
    agentId: "votre-agent-id",
  }),
});

const { sdp, sessionId } = await response.json();

// Appliquer la réponse
await peerConnection.setRemoteDescription(
  new RTCSessionDescription({ type: "answer", sdp }),
);
```

#### 6. Fonction utilitaire pour ICE gathering

```javascript
function waitForIceGathering(pc, timeout = 5000) {
  return new Promise((resolve) => {
    if (pc.iceGatheringState === "complete") {
      resolve();
      return;
    }

    const checkState = () => {
      if (pc.iceGatheringState === "complete") {
        pc.removeEventListener("icegatheringstatechange", checkState);
        resolve();
      }
    };

    pc.addEventListener("icegatheringstatechange", checkState);
    setTimeout(() => {
      pc.removeEventListener("icegatheringstatechange", checkState);
      resolve();
    }, timeout);
  });
}
```

---

## Paramètres configurables

Les paramètres peuvent être envoyés via le DataChannel après connexion.

### Sensibilité VAD

```javascript
dataChannel.send(
  JSON.stringify({
    type: "settings_update",
    settings: {
      vadSensitivity: 5, // 1-10 (1 = peu sensible, 10 = très sensible)
    },
  }),
);
```

### Délai avant envoi

```javascript
dataChannel.send(
  JSON.stringify({
    type: "settings_update",
    settings: {
      silenceDuration: 1500, // 500-3000ms
    },
  }),
);
```

### Langue

```javascript
dataChannel.send(
  JSON.stringify({
    type: "settings_update",
    settings: {
      language: "fr", // fr, en, es, de, it, pt
    },
  }),
);
```

---

## Gestion des fichiers

Vous pouvez attacher des fichiers (PDF, documents) que l'IA pourra consulter pendant la conversation vocale.

### Upload de fichiers

```javascript
const formData = new FormData();
formData.append("file", fileBlob);

const response = await fetch("https://api.devana.ai/api/upload", {
  method: "POST",
  headers: {
    Authorization: `Bearer ${userToken}`,
    conversation: sessionId, // Important: lie le fichier à la session
    wait: "true", // Attend la fin du traitement
  },
  body: formData,
});

const { data } = await response.json();
const fileIds = data.ids; // Array d'IDs de fichiers
```

### Notifier le serveur

```javascript
dataChannel.send(
  JSON.stringify({
    type: "files_update",
    fileIds: fileIds,
  }),
);
```

---

## Exemples de code

### Exemple complet (JavaScript vanilla)

```javascript
class DevanaVocalClient {
  constructor(userToken, agentId) {
    this.userToken = userToken;
    this.agentId = agentId;
    this.peerConnection = null;
    this.dataChannel = null;
    this.sessionId = null;
    this.onEvent = null;
  }

  async connect() {
    // 1. Obtenir le microphone
    const stream = await navigator.mediaDevices.getUserMedia({ audio: true });

    // 2. Créer la connexion
    this.peerConnection = new RTCPeerConnection({
      iceServers: [{ urls: "stun:stun.l.google.com:19302" }],
    });

    // 3. Ajouter l'audio local
    stream.getTracks().forEach((track) => {
      this.peerConnection.addTrack(track, stream);
    });

    // 4. Créer le DataChannel
    this.dataChannel = this.peerConnection.createDataChannel("events", {
      ordered: true,
    });
    this.dataChannel.onmessage = (e) => {
      const data = JSON.parse(e.data);
      this.onEvent?.(data);
    };

    // 5. Configurer la réception audio
    const remoteAudio = new Audio();
    remoteAudio.autoplay = true;
    this.peerConnection.ontrack = (e) => {
      remoteAudio.srcObject = e.streams[0] || new MediaStream([e.track]);
    };

    // 6. Créer l'offre
    const offer = await this.peerConnection.createOffer();
    await this.peerConnection.setLocalDescription(offer);
    await this._waitForIce();

    // 7. Envoyer au serveur
    const response = await fetch("https://api.devana.ai/v1/chat/vocal", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${this.userToken}`,
      },
      body: JSON.stringify({
        sdp: this.peerConnection.localDescription.sdp,
        agentId: this.agentId,
      }),
    });

    const { sdp, sessionId } = await response.json();
    this.sessionId = sessionId;

    await this.peerConnection.setRemoteDescription(
      new RTCSessionDescription({ type: "answer", sdp }),
    );

    return sessionId;
  }

  updateSettings(settings) {
    if (this.dataChannel?.readyState === "open") {
      this.dataChannel.send(
        JSON.stringify({
          type: "settings_update",
          settings,
        }),
      );
    }
  }

  disconnect() {
    this.dataChannel?.close();
    this.peerConnection?.close();
    this.peerConnection = null;
    this.dataChannel = null;
    this.sessionId = null;
  }

  async _waitForIce(timeout = 5000) {
    return new Promise((resolve) => {
      if (this.peerConnection.iceGatheringState === "complete") {
        resolve();
        return;
      }
      const check = () => {
        if (this.peerConnection.iceGatheringState === "complete") {
          this.peerConnection.removeEventListener(
            "icegatheringstatechange",
            check,
          );
          resolve();
        }
      };
      this.peerConnection.addEventListener("icegatheringstatechange", check);
      setTimeout(() => {
        this.peerConnection.removeEventListener(
          "icegatheringstatechange",
          check,
        );
        resolve();
      }, timeout);
    });
  }
}

// Utilisation
const client = new DevanaVocalClient("votre-token", "votre-agent-id");

client.onEvent = (event) => {
  switch (event.type) {
    case "transcription":
      console.log("Vous avez dit:", event.text);
      break;
    case "response_text":
      console.log("IA:", event.text);
      break;
    case "tts_start":
      console.log("L'IA parle...");
      break;
    case "tts_end":
      console.log("L'IA a fini de parler");
      break;
  }
};

await client.connect();
```

---

## Limitations et bonnes pratiques

### Limitations

- **Navigateurs supportés** : Chrome 74+, Firefox 66+, Safari 14.1+, Edge 79+
- **Durée de parole** : Max ~30 secondes par segment
- **Format audio** : Le serveur attend du PCM 48kHz (géré automatiquement par WebRTC)

### Bonnes pratiques

1. **Gestion des erreurs** : Toujours écouter l'événement `error` du DataChannel
2. **Reconnexion** : Implémenter une logique de reconnexion en cas de déconnexion
3. **Indicateurs visuels** : Utiliser les événements VAD pour montrer à l'utilisateur quand il est entendu
4. **Permissions** : Demander la permission micro avant d'initier la connexion
5. **Cleanup** : Toujours fermer proprement la connexion (arrêter les tracks, fermer le PeerConnection)

### Gestion du bruit ambiant

Le VAD s'adapte automatiquement au bruit de fond, mais pour de meilleurs résultats :

- Utilisez un micro de qualité
- Évitez les environnements très bruyants
- Attendez la fin de la calibration (~1 seconde) avant de parler

---

## Support

Pour toute question technique concernant l'intégration :

- Documentation API : https://docs.devana.ai
- Support : support@devana.ai
