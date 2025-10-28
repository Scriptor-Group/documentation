<div align="center">

**Enterprise AI Platform for Intelligent Applications**

[Getting Started](#getting-started) • [API Reference](./api/README.md) • [Deployment](./deployment/README.md) • [Examples](#examples)

[![Version](https://img.shields.io/badge/version-0.6.0108-blue.svg)](./changelogs/devana/README.md)
[![License](https://img.shields.io/badge/license-Proprietary-red.svg)](#)

</div>

---

## Overview

Devana.ai is an enterprise-grade AI platform that empowers organizations to deploy, integrate, and control AI assistants at scale. Built for privacy, compliance, and performance.

### Key Capabilities

```
🤖 Custom AI Agents          📄 Document Intelligence      🔐 Enterprise Security
   Deploy specialized         Process & analyze docs        SSO, RBAC, audit logs
   assistants in minutes      with Odin engine              GDPR & SOC 2 ready

🔌 Flexible Integration      📊 Usage Analytics            🏢 On-Premise Ready
   REST API, WebSocket,       Track tokens, costs,          Full Kubernetes support
   IFrame, SDKs               and performance               Private cloud deployment
```

---

## Getting Started

### Cloud Deployment

The fastest way to get started with Devana.ai:

```bash
# 1. Create account at devana.ai
# 2. Generate API key from Settings → API
# 3. Make your first request

curl -X POST https://api.devana.ai/v1/chat/completions \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "agentId": "your-agent-id",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

**Next steps:**

- [Authentication Guide](./api/authentication/oauth.md)
- [API Reference](./api/README.md)
- [Integration Examples](#examples)

### Self-Hosted Deployment

Deploy Devana.ai in your infrastructure for full control:

1. **Review Requirements** → [Sizing & Specifications](./deployment/requirements.md)
2. **Configure LLM Providers** → [LLM Configuration](./deployment/configuration/llm-providers.md)
3. **Deploy with Kubernetes** → [Installation Guide](./deployment/infrastructure/kubernetes/kube/README.md)

**Prerequisites:**

- Kubernetes 1.24+
- PostgreSQL 14+ with pgvector
- 16GB RAM minimum (see [requirements](./deployment/requirements.md) for production sizing)

---

## Documentation

### For Developers

<table>
<tr>
<td width="50%">

**[API Reference](./api/README.md)**

Complete REST API documentation for building AI-powered applications.

- [Agents](./api/endpoints/agents.md) - Manage AI agents
- [Conversations](./api/endpoints/conversations.md) - Chat & history
- [Completions](./api/endpoints/completions.md) - Streaming responses
- [Documents](./api/endpoints/documents.md) - Upload & process files

</td>
<td width="50%">

**[SDKs & Tools](./sdks/README.md)**

Client libraries and integration packages.

- [devana-ws-tools](./sdks/devana-ws-tools.md) - WebSocket client
- [n8n-nodes-devana](./sdks/n8n-nodes-devana.md) - Workflow automation
- Custom integrations via [Tools API](./api/integration/tools.md)

</td>
</tr>
<tr>
<td width="50%">

**[Integration Guides](./api/integration/README.md)**

Embed Devana.ai in your applications.

- [IFrame Integration](./api/integration/iframe.md) - Embed chatbots
- [Custom Tools](./api/integration/tools.md) - Extend with your APIs
- [Webhooks](./api/endpoints/interactions.md) - Event-driven flows

</td>
<td width="50%">

**[Supported Formats](./api/reference/supported-formats.md)**

File types and data formats.

- Documents (PDF, Office, Text)
- Images with OCR support
- Structured data (JSON, CSV)

</td>
</tr>
</table>

### For DevOps & SysAdmins

<table>
<tr>
<td width="50%">

**[Deployment Guide](./deployment/README.md)**

Production-ready deployment.

- [Requirements](./deployment/requirements.md) ⭐ **Start here**
- [Kubernetes](./deployment/infrastructure/kubernetes/kube/README.md) - K8s/OpenShift
- [PostgreSQL](./deployment/infrastructure/database/db/postgresql.md) - Database setup
- [LLM Providers](./deployment/configuration/llm-providers.md) - Model configuration

</td>
<td width="50%">

**[Operations](./deployment/monitoring/health-checks.md)**

Monitor and maintain your deployment.

- [Health Checks](./deployment/monitoring/health-checks.md) - System monitoring
- [License Management](./deployment/monitoring/license.md) - Usage tracking
- [Troubleshooting](./deployment/troubleshooting/common-issues.md) - Common issues

</td>
</tr>
<tr>
<td width="50%">

**[Authentication](./deployment/authentication/README.md)**

Enterprise identity integration.

- Azure AD, Google Workspace
- LDAP, OIDC, SAML
- Custom SSO providers

</td>
<td width="50%">

**[Architecture](./deployment/architecture.md)**

System design and scaling.

- Component architecture
- Data flows and security
- Performance optimization

</td>
</tr>
</table>

### For Product Teams

**[Changelogs](./changelogs/)**

Track new features and improvements.

- [Devana Platform](./changelogs/devana/README.md) - Main platform updates (v0.6.0108)
- [Odin Service](./changelogs/odin/README.md) - Document processing engine (v0.1.25)

---

## Examples

### Basic Chat Completion

```bash
curl -X POST https://api.devana.ai/v1/chat/completions \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "agentId": "cm123abc",
    "messages": [
      {"role": "user", "content": "Explain quantum computing"}
    ]
  }'
```

### Streaming Response

```javascript
const response = await fetch("https://api.devana.ai/v1/chat/completions", {
  method: "POST",
  headers: {
    Authorization: "Bearer YOUR_API_KEY",
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    agentId: "cm123abc",
    messages: [{ role: "user", content: "Tell me a story" }],
    stream: true,
  }),
});

const reader = response.body.getReader();
// Process stream...
```

### IFrame Integration

```html
<!-- Embed an AI assistant in your webpage -->
<iframe
  src="https://app.devana.ai/chat/your-agent-id"
  width="100%"
  height="600px"
  frameborder="0"
></iframe>
```

### WebSocket Real-Time

```typescript
import { DevanaWSClient } from "devana-ws-tools";

const client = new DevanaWSClient({
  apiKey: "YOUR_API_KEY",
  agentId: "your-agent-id",
});

// Register custom tool
client.registerTool({
  name: "getWeather",
  handler: async (params) => {
    return { temperature: 22, condition: "sunny" };
  },
});

await client.connect();
```

**More examples:**

- [IFrame Chatbot Widget](./api/integration/iframe-examples.md)
- [Custom Tools Implementation](./api/integration/tools.md)
- [n8n Workflow Automation](./sdks/n8n-nodes-devana.md)

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Devana.ai Platform                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐   │
│  │  Front-end  │  │  API Server  │  │  Odin Service   │   │
│  │  (Next.js)  │◄─┤  (Node.js +  │◄─┤  (Document      │   │
│  │             │  │   GraphQL)   │  │   Processing)   │   │
│  └─────────────┘  └──────────────┘  └─────────────────┘   │
│         │                │                     │            │
│         └────────────────┼─────────────────────┘            │
│                          ▼                                  │
│            ┌───────────────────────────┐                    │
│            │  PostgreSQL + pgvector    │                    │
│            │  (Relational + Vector DB) │                    │
│            └───────────────────────────┘                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                          │
            ┌─────────────┼─────────────┐
            ▼             ▼             ▼
    ┌──────────┐   ┌───────────┐  ┌─────────┐
    │   LLM    │   │ Embedding │  │ Storage │
    │ Providers│   │  Models   │  │ (S3/...)│
    └──────────┘   └───────────┘  └─────────┘
```

**Learn more:** [Architecture Documentation](./deployment/architecture.md)

---

## Use Cases

### 🎓 Knowledge Management

Deploy RAG-powered assistants that answer questions from your documentation, wikis, and knowledge bases.

### 💼 Customer Support

Integrate AI agents into your support workflow with custom tools, CRM connections, and escalation handling.

### 📊 Document Processing

Extract, analyze, and summarize documents at scale with Odin's OCR and NLP capabilities.

### 🔧 Developer Tools

Build AI-powered features into your applications using our REST API, WebSocket SDK, or workflow automation.

---

## Security & Compliance

- **Data Privacy**: On-premise deployment keeps your data within your infrastructure
- **Access Control**: Role-based permissions, SSO integration, audit logs
- **Compliance Ready**: GDPR, SOC 2, ISO 27001 compliance support
- **Encryption**: TLS in transit, encryption at rest for sensitive data

**Learn more:** [Security Documentation](./deployment/requirements.md#sécurité-et-conformité)

---

## Support

### Documentation & Resources

- 📖 [Full Documentation](./api/README.md)
- 🎓 [Integration Guides](./api/integration/README.md)
- 🔧 [Troubleshooting](./deployment/troubleshooting/common-issues.md)

### Get Help

- 📧 **Technical Support**: [support-it@devana.ai](mailto:support-it@devana.ai)
- 🐛 **Bug Reports**: [tyr.devana.ai](https://tyr.devana.ai)
- 🌐 **Website**: [devana.ai](https://www.devana.ai)
- 💻 **GitHub**: [Devana](https://github.com/Scriptor-Group/devana.ai) • [Odin](https://github.com/Scriptor-Group/odin)
