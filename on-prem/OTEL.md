Actuellement uniquement l'API de Devana supporte OpenTelemetry.

Il faut utiliser ces variables d'environnement :

```
OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=http://jaeger:4318/v1/traces
OTEL_EXPORTER_OTLP_METRICS_ENDPOINT=http://otel-collector:4318/v1/metrics
OTEL_EXPORTER_OTLP_LOGS_ENDPOINT=http://otel-collector:4318/v1/logs
OTEL_RESOURCE_ATTRIBUTES=service.name=devana-api,service.version=0.0.0,deployment.environment=development
```

Pour les logs nous utilisons `pino-opentelemetry-transport`.
Pour les traces et metrics :

```
const sdk = new NodeSDK({
  traceExporter: new OTLPTraceExporter({
    url: process.env.OTEL_EXPORTER_OTLP_TRACES_ENDPOINT,
  }),
  metricReader: new PeriodicExportingMetricReader({
    exporter: new OTLPMetricExporter({
      url: process.env.OTEL_EXPORTER_OTLP_METRICS_ENDPOINT,
    }),
  }),
  instrumentations: [getNodeAutoInstrumentations()],
});

sdk.start();
```
