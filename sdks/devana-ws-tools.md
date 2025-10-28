# Devana WebSocket Tools

## Overview

Devana WebSocket Tools (`devana-ws-tools`) is a TypeScript/JavaScript library that enables applications to connect to Devana AI agents via WebSocket and expose custom tools dynamically. This allows Devana AI to interact with your application's functionality in real-time.

## Installation

```bash
npm install devana-ws-tools
# or
yarn add devana-ws-tools
```

## Core Concepts

### Dynamic Tools
Dynamic tools are functions or capabilities that your application exposes to Devana AI agents. These tools can:
- Execute actions in your application
- Query data from your systems
- Integrate with third-party services
- Control IoT devices
- Manipulate documents
- And much more

### WebSocket Connection
The library establishes a persistent WebSocket connection to Devana, enabling:
- Real-time bidirectional communication
- Low latency tool execution
- Event-driven architecture
- Automatic reconnection handling

## Basic Usage

### 1. Initialize the Client

```typescript
import { DevanaWSClient } from 'devana-ws-tools';

const client = new DevanaWSClient({
  apiKey: 'your-api-key',
  agentId: 'your-agent-id',
  wsUrl: 'wss://api.devana.ai/ws' // Optional, uses default if not provided
});
```

### 2. Define Tools

Tools are defined with a schema and handler function:

```typescript
const tools = [
  {
    name: 'getCurrentWeather',
    description: 'Get current weather for a location',
    parameters: {
      type: 'object',
      properties: {
        location: {
          type: 'string',
          description: 'City name or coordinates'
        },
        units: {
          type: 'string',
          enum: ['celsius', 'fahrenheit'],
          default: 'celsius'
        }
      },
      required: ['location']
    },
    handler: async (params) => {
      // Your implementation
      const weather = await fetchWeatherData(params.location);
      return {
        temperature: weather.temp,
        conditions: weather.conditions,
        units: params.units
      };
    }
  }
];
```

### 3. Register Tools and Connect

```typescript
// Register tools
tools.forEach(tool => {
  client.registerTool(tool);
});

// Connect to Devana
await client.connect();

// The client is now ready to receive tool execution requests
```

## Advanced Examples

### Office Automation Tools

```typescript
const officeTools = [
  {
    name: 'createDocument',
    description: 'Create a new document with specified content',
    parameters: {
      type: 'object',
      properties: {
        title: { type: 'string' },
        content: { type: 'string' },
        format: {
          type: 'string',
          enum: ['docx', 'pdf', 'html']
        }
      },
      required: ['title', 'content']
    },
    handler: async (params) => {
      const doc = await documentService.create({
        title: params.title,
        content: params.content,
        format: params.format || 'docx'
      });
      return {
        documentId: doc.id,
        url: doc.url,
        message: `Document "${params.title}" created successfully`
      };
    }
  },

  {
    name: 'scheduleCalendarEvent',
    description: 'Schedule a calendar event',
    parameters: {
      type: 'object',
      properties: {
        title: { type: 'string' },
        startTime: { type: 'string', format: 'date-time' },
        endTime: { type: 'string', format: 'date-time' },
        attendees: {
          type: 'array',
          items: { type: 'string' }
        },
        location: { type: 'string' },
        description: { type: 'string' }
      },
      required: ['title', 'startTime', 'endTime']
    },
    handler: async (params) => {
      const event = await calendarService.createEvent({
        title: params.title,
        start: new Date(params.startTime),
        end: new Date(params.endTime),
        attendees: params.attendees || [],
        location: params.location,
        description: params.description
      });
      return {
        eventId: event.id,
        meetingLink: event.meetingLink,
        message: `Event "${params.title}" scheduled for ${params.startTime}`
      };
    }
  }
];
```

### IoT Device Control

```typescript
const iotTools = [
  {
    name: 'controlSmartLight',
    description: 'Control smart light settings',
    parameters: {
      type: 'object',
      properties: {
        deviceId: { type: 'string' },
        action: {
          type: 'string',
          enum: ['on', 'off', 'dim', 'color']
        },
        brightness: {
          type: 'number',
          minimum: 0,
          maximum: 100
        },
        color: { type: 'string' }
      },
      required: ['deviceId', 'action']
    },
    handler: async (params) => {
      const device = await iotHub.getDevice(params.deviceId);

      switch(params.action) {
        case 'on':
          await device.turnOn();
          break;
        case 'off':
          await device.turnOff();
          break;
        case 'dim':
          await device.setBrightness(params.brightness || 50);
          break;
        case 'color':
          await device.setColor(params.color);
          break;
      }

      return {
        status: 'success',
        deviceState: await device.getState()
      };
    }
  },

  {
    name: 'readSensorData',
    description: 'Read data from IoT sensors',
    parameters: {
      type: 'object',
      properties: {
        sensorType: {
          type: 'string',
          enum: ['temperature', 'humidity', 'motion', 'air_quality']
        },
        location: { type: 'string' }
      },
      required: ['sensorType']
    },
    handler: async (params) => {
      const sensors = await iotHub.getSensors({
        type: params.sensorType,
        location: params.location
      });

      const readings = await Promise.all(
        sensors.map(s => s.getCurrentReading())
      );

      return {
        sensorType: params.sensorType,
        readings: readings,
        timestamp: new Date().toISOString()
      };
    }
  }
];
```

### Database Query Tool

```typescript
const databaseTool = {
  name: 'queryDatabase',
  description: 'Execute safe database queries',
  parameters: {
    type: 'object',
    properties: {
      table: { type: 'string' },
      operation: {
        type: 'string',
        enum: ['select', 'count', 'aggregate']
      },
      filters: { type: 'object' },
      fields: {
        type: 'array',
        items: { type: 'string' }
      },
      limit: { type: 'number' }
    },
    required: ['table', 'operation']
  },
  handler: async (params) => {
    // Validate and sanitize inputs
    const query = buildSecureQuery(params);

    const results = await database.execute(query);

    return {
      rowCount: results.length,
      data: results,
      query: query.toString() // For transparency
    };
  }
};
```

## Error Handling

```typescript
client.on('error', (error) => {
  console.error('WebSocket error:', error);
  // Implement retry logic or alerting
});

client.on('disconnect', () => {
  console.log('Disconnected from Devana');
  // Attempt reconnection
});

client.on('tool_execution_error', (error) => {
  console.error('Tool execution failed:', error);
  // Log to monitoring service
});
```

## Security Best Practices

### 1. Input Validation
Always validate and sanitize tool parameters:

```typescript
handler: async (params) => {
  // Validate required fields
  if (!params.userId || typeof params.userId !== 'string') {
    throw new Error('Invalid userId');
  }

  // Sanitize inputs
  const sanitizedQuery = sanitizeSQL(params.query);

  // Execute with validated inputs
  return await executeAction(sanitizedQuery);
}
```

### 2. Authentication & Authorization

```typescript
const client = new DevanaWSClient({
  apiKey: process.env.DEVANA_API_KEY, // Never hardcode
  agentId: process.env.DEVANA_AGENT_ID,
  // Add custom auth headers if needed
  headers: {
    'X-Custom-Auth': await getAuthToken()
  }
});
```

### 3. Rate Limiting

```typescript
import { RateLimiter } from 'limiter';

const limiter = new RateLimiter({ tokensPerInterval: 10, interval: 'second' });

const rateLimitedTool = {
  name: 'expensiveOperation',
  handler: async (params) => {
    await limiter.removeTokens(1);
    return await performExpensiveOperation(params);
  }
};
```

## Environment Configuration

```bash
# .env file
DEVANA_API_KEY=your-api-key
DEVANA_AGENT_ID=your-agent-id
DEVANA_WS_URL=wss://api.devana.ai/ws
DEVANA_RECONNECT_ATTEMPTS=5
DEVANA_RECONNECT_DELAY=5000
```

```typescript
// config.ts
export const config = {
  apiKey: process.env.DEVANA_API_KEY,
  agentId: process.env.DEVANA_AGENT_ID,
  wsUrl: process.env.DEVANA_WS_URL,
  reconnectAttempts: parseInt(process.env.DEVANA_RECONNECT_ATTEMPTS || '5'),
  reconnectDelay: parseInt(process.env.DEVANA_RECONNECT_DELAY || '5000')
};
```

## Testing

```typescript
import { DevanaWSClient, MockWebSocket } from 'devana-ws-tools/testing';

describe('Tool Registration', () => {
  let client: DevanaWSClient;
  let mockWs: MockWebSocket;

  beforeEach(() => {
    mockWs = new MockWebSocket();
    client = new DevanaWSClient({
      apiKey: 'test-key',
      agentId: 'test-agent',
      websocket: mockWs // Inject mock
    });
  });

  test('should execute tool and return result', async () => {
    const tool = {
      name: 'testTool',
      handler: async (params) => ({ result: params.input * 2 })
    };

    client.registerTool(tool);
    await client.connect();

    const result = await mockWs.simulateToolCall('testTool', { input: 5 });
    expect(result).toEqual({ result: 10 });
  });
});
```

## Logging and Monitoring

```typescript
import winston from 'winston';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'devana-tools.log' })
  ]
});

client.on('tool_called', (toolName, params) => {
  logger.info('Tool called', { toolName, params, timestamp: Date.now() });
});

client.on('tool_completed', (toolName, result, duration) => {
  logger.info('Tool completed', {
    toolName,
    duration,
    timestamp: Date.now()
  });
});
```

## TypeScript Support

The library is fully typed. Import types for better IDE support:

```typescript
import {
  DevanaWSClient,
  Tool,
  ToolParameters,
  ToolHandler,
  ConnectionOptions,
  WSClientEvents
} from 'devana-ws-tools';

const myTool: Tool = {
  name: 'myTool',
  description: 'My custom tool',
  parameters: {
    type: 'object',
    properties: {
      input: { type: 'string' }
    }
  } as ToolParameters,
  handler: (async (params: any): Promise<any> => {
    return { output: params.input };
  }) as ToolHandler
};
```

## API Reference

### DevanaWSClient

#### Constructor Options
```typescript
interface ConnectionOptions {
  apiKey: string;           // Required: Your Devana API key
  agentId: string;          // Required: The agent ID to connect to
  wsUrl?: string;           // Optional: WebSocket URL (default: wss://api.devana.ai/ws)
  reconnect?: boolean;      // Optional: Auto-reconnect on disconnect (default: true)
  reconnectAttempts?: number; // Optional: Max reconnection attempts (default: 5)
  reconnectDelay?: number;  // Optional: Delay between reconnections in ms (default: 5000)
  headers?: object;         // Optional: Additional headers
}
```

#### Methods

| Method | Description | Parameters | Returns |
|--------|-------------|------------|---------|
| `connect()` | Establishes WebSocket connection | None | `Promise<void>` |
| `disconnect()` | Closes WebSocket connection | None | `void` |
| `registerTool(tool)` | Registers a new tool | `Tool` object | `void` |
| `unregisterTool(name)` | Removes a registered tool | Tool name | `void` |
| `getTools()` | Returns all registered tools | None | `Tool[]` |
| `on(event, handler)` | Adds event listener | Event name, handler | `void` |
| `off(event, handler)` | Removes event listener | Event name, handler | `void` |

#### Events

| Event | Description | Payload |
|-------|-------------|---------|
| `connected` | Connection established | None |
| `disconnected` | Connection closed | Close code and reason |
| `error` | Error occurred | Error object |
| `tool_called` | Tool execution started | Tool name and parameters |
| `tool_completed` | Tool execution finished | Tool name, result, duration |
| `tool_error` | Tool execution failed | Tool name and error |
| `message` | Raw message received | Message data |

## Troubleshooting

### Connection Issues

```typescript
// Enable debug logging
client.on('*', (event, ...args) => {
  console.log(`[${event}]`, ...args);
});

// Check connection state
if (client.isConnected()) {
  console.log('Connected to Devana');
} else {
  console.log('Not connected');
}
```

### Tool Registration Issues

```typescript
// Verify tool is registered
const tools = client.getTools();
console.log('Registered tools:', tools.map(t => t.name));

// Validate tool schema
try {
  validateToolSchema(myTool);
} catch (error) {
  console.error('Invalid tool schema:', error);
}
```

### Performance Monitoring

```typescript
client.on('tool_called', (name, params) => {
  console.time(`tool_${name}`);
});

client.on('tool_completed', (name) => {
  console.timeEnd(`tool_${name}`);
});
```

## Migration Guide

### From Version 1.x to 2.x

```typescript
// Version 1.x
const client = new DevanaClient(apiKey, agentId);

// Version 2.x
const client = new DevanaWSClient({
  apiKey: apiKey,
  agentId: agentId
});

// Tool registration remains the same
client.registerTool(tool);
```

## Support and Resources

- **GitHub Repository**: [github.com/devana-ai/devana-ws-tools](https://github.com/devana-ai/devana-ws-tools)
- **NPM Package**: [npmjs.com/package/devana-ws-tools](https://npmjs.com/package/devana-ws-tools)
- **API Documentation**: [docs.devana.ai/sdks/websocket-tools](https://docs.devana.ai/sdks/websocket-tools)
- **Examples**: [github.com/devana-ai/devana-ws-tools/examples](https://github.com/devana-ai/devana-ws-tools/examples)
- **Support**: support@devana.ai

## License

MIT License - See LICENSE file for details