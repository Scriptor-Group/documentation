# Devana SDKs and Integrations

This section contains documentation for Devana's software development kits (SDKs) and integration packages that enable developers to extend and integrate Devana AI capabilities into their applications.

## Available SDKs

### WebSocket Tools
**[devana-ws-tools](./devana-ws-tools.md)** - TypeScript/JavaScript library for real-time WebSocket connections to Devana AI agents

- Dynamic tool registration
- Bidirectional communication
- Automatic reconnection handling
- Full TypeScript support
- Suitable for: Web applications, Node.js services, IoT integrations

### n8n Integration
**[n8n-nodes-devana](./n8n-nodes-devana.md)** - Community node package for n8n workflow automation

- Chat node for conversational AI
- Document processing node
- RAG (Retrieval-Augmented Generation) node
- Workflow triggers from Devana events
- Suitable for: Workflow automation, process orchestration, no-code integrations

## Quick Start Guides

### WebSocket Integration
```bash
npm install devana-ws-tools
```

```typescript
import { DevanaWSClient } from 'devana-ws-tools';

const client = new DevanaWSClient({
  apiKey: 'your-api-key',
  agentId: 'your-agent-id'
});

// Register a tool
client.registerTool({
  name: 'getData',
  handler: async (params) => {
    // Your implementation
    return { data: 'result' };
  }
});

await client.connect();
```

### n8n Integration
1. Install via Community Nodes in n8n
2. Search for `n8n-nodes-devana`
3. Configure credentials with your API key
4. Start building workflows with Devana nodes

## Integration Patterns

### Event-Driven Architecture
Use WebSocket tools for real-time, event-driven integrations where low latency is critical.

### Workflow Automation
Use n8n nodes for complex, multi-step workflows that combine Devana AI with other services.

### Hybrid Approach
Combine both SDKs for maximum flexibility:
- n8n for orchestration and workflow management
- WebSocket tools for real-time components within workflows

## Authentication

All SDKs use the same authentication method:

```bash
# Set environment variable
export DEVANA_API_KEY="your-api-key"
```

Or configure programmatically:

```javascript
// WebSocket Tools
const client = new DevanaWSClient({
  apiKey: process.env.DEVANA_API_KEY
});

// n8n Nodes
// Configure in n8n Credentials UI
```

## Best Practices

1. **Security**: Never hardcode API keys in your source code
2. **Error Handling**: Implement comprehensive error handling and retry logic
3. **Rate Limiting**: Respect API rate limits to ensure service stability
4. **Logging**: Enable detailed logging in development, minimal logging in production
5. **Testing**: Use provided testing utilities and mock implementations

## Support Matrix

| SDK | Node.js | Browser | TypeScript | Language |
|-----|---------|---------|------------|----------|
| devana-ws-tools | ✅ 16+ | ✅ Modern | ✅ Full | JS/TS |
| n8n-nodes-devana | ✅ 18+ | ❌ | ✅ Full | JS/TS |

## Additional Resources

- [API Reference](../api/README.md) - Complete API documentation
- [Authentication Guide](../api/authentication.md) - Detailed authentication documentation
- [Rate Limits](../api/rate-limits.md) - API rate limiting information
- [Examples Repository](https://github.com/devana-ai/examples) - Sample implementations

## Getting Help

- **Documentation Issues**: Create an issue in the documentation repository
- **SDK Bugs**: Report in the respective SDK repository
- **General Support**: support@devana.ai
- **Community**: Join our Discord server

## Contributing

We welcome contributions to our SDKs! Please see the CONTRIBUTING.md file in each SDK repository for guidelines.

## License

All Devana SDKs are released under the MIT License unless otherwise specified.