# On-Premise OpenTelemetry Installation Guide

This document outlines the steps required to set up OpenTelemetry for your applications (`Devana` and `Odin`) in an on-premise environment. The process involves configuring environment variables, deploying an OpenTelemetry Collector, and finally, testing the integration.

## 1. Define Environment Variables for Your Projects

The first step is to configure the necessary OpenTelemetry environment variables within your application projects. These variables direct your applications to send telemetry data (logs, traces, and metrics) to the OpenTelemetry Collector.

### Devana Project

Set the following environment variables for your `Devana` application:

```bash
OTEL_EXPORTER_OTLP_LOGS_PROTOCOL='grpc'
OTEL_EXPORTER_OTLP_LOGS_ENDPOINT='http://localhost:4317'
OTEL_RESOURCE_ATTRIBUTES="service.name=devana-server,service.version=1.2.3"
```

* `OTEL_EXPORTER_OTLP_LOGS_PROTOCOL`: Specifies the communication protocol for exporting logs. We recommend `grpc`.
* `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`: The endpoint where the OpenTelemetry Collector is listening for logs. In this on-premise setup, it's typically `http://localhost:4317` if the collector is running on the same host.
* `OTEL_RESOURCE_ATTRIBUTES`: Defines static attributes that describe the service, such as its name and version.

### Odin Project

Set the following environment variables for your `Odin` application:

```bash
OTEL_EXPORTER_OTLP_LOGS_ENDPOINT='http://localhost:4317'
OTEL_RESOURCE_ATTRIBUTES="service.name=odin-server,service.version=1.2.3"
OTEL_EXPORTER_OTLP_ENDPOINT_TRACES='http://localhost:4317'
OTEL_EXPORTER_OTLP_ENDPOINT_METRICS='http://localhost:4317'
```

* `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`: The endpoint for logs, similar to Devana.
* `OTEL_RESOURCE_ATTRIBUTES`: Defines static attributes for the Odin service.
* `OTEL_EXPORTER_OTLP_ENDPOINT_TRACES`: The endpoint for exporting traces.
* `OTEL_EXPORTER_OTLP_ENDPOINT_METRICS`: The endpoint for exporting metrics.

**Note:** Ensure that these environment variables are set correctly in your application's deployment environment (e.g., `Dockerfile`, `docker-compose.yml`, Kubernetes deployment manifests, or directly on the host if running as a standalone process).

## 2. Deploy the OpenTelemetry Collector

The OpenTelemetry Collector is a crucial component that receives, processes, and exports telemetry data. You have two options for setting up the Collector:

### Option A: Create a New OpenTelemetry Collector using Docker Compose

If you have a `docker-compose.yml` file already set up for the OpenTelemetry Collector, you can use it to deploy the collector.

1.  **Ensure Docker and Docker Compose are installed:** If not, follow the official Docker documentation to install them on your server.

2.  **Locate your `docker-compose.yml` file:** This file should define the OpenTelemetry Collector service. An example might look like this:

    ```yaml
    # docker-compose.yml
    services:
      otel-collector:
        image: otel/opentelemetry-collector-contrib:latest
        container_name: otel-collector
        restart: always
        command: ["--config=/etc/otel-collector-config.yaml"]
        volumes:
          - ./otel-collector-config.yaml:/etc/otel-collector-config.yaml:ro # Mount the config file in order to provide on-premise configuration (ELK/Jaeger/Prometheus/... configs)
          - shared-logs:/var/log/app
        ports:
          - "8888:8888"
          - "4317:4317"
          - "4318:4318"
        networks:
          - otel-network
        profiles:
          - logs

        networks:
          otel-network:
            driver: bridge
    ```

3.  **Configure `otel-collector-config.yaml`:** This file defines how the collector receives, processes, and exports telemetry data. It is mounted as a volume into the collector container. You mentioned that examples are already written in this file. Ensure these examples are configured to receive OTLP data (logs, traces, metrics) and forward it to your desired backend (e.g., Jaeger for traces, Prometheus/Grafana for metrics, Loki for logs, or a file exporter for testing).

    A basic example of `otel-collector-config.yaml` might include:

    ```yaml
    # otel-collector-config.yaml
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317 # Explicitly bind gRPC to all interfaces
          http:
            endpoint: 0.0.0.0:4318 # Explicitly bind HTTP to all interfaces (THIS IS THE KEY FIX)

      # Filelog receiver for Pino logs
      # filelog:
      #   include: [ /var/log/app/app.log ] # Path inside the collector container (mapped by volume)
      #   start_at: beginning
      #   poll_interval: 1s
      #   operators:
      #     - id: parse-log-json
      #       type: json_parser
      #       parse_from: body # Explicitly parse from the raw log line string
      #       parse_to: attributes["parsed_json"] # Put the parsed JSON object here

    processors:
      batch:
        timeout: 5s
        send_batch_size: 100

    exporters:
      # Some OTLP exporters example
      # otlp/jaeger:
      #   endpoint: jaeger:4317
      #   tls:
      #     insecure: true # In dev mode, you might not want to use TLS
      #   headers:
      #     x-otlp-version: "0.16.0" # Example header, adjust as needed
      #   compression: gzip # Optional, if you want to compress the data
      #   timeout: 5s # Optional, adjust as needed
      #   retry_on_failure:
      #     enabled: true
      #     initial_interval: 5s
      #     max_interval: 30s

      # loki:
      #   endpoint: http://loki:3100/loki/api/v1/push
      #   tls:
      #     insecure: true # In dev mode, you might not want to use TLS
      #   headers:
      #     x-tenant-id: "default" # Example header, adjust as needed
      #   labels:
      #     resource:
      #       host.name:
      #       service.name:
      #     attribute:
      #       trace_id:
      #       span_id:
      #       component: # For your module field
      #   tenant_id: "default" # Optional, if you want to specify a tenant ID
      #   format: json # This exporter sends logs as JSON to Loki

      # prometheus:
      #   endpoint: prometheus:9090
      #   tls:
      #     insecure: true # In dev mode, you might not want to use TLS
      #   headers:
      #     x-tenant-id: "default" # Example header, adjust as needed
      #   labels:
      #     resource:
      #       host.name:
      #       service.name:
      #     attribute:
      #       trace_id:
      #       span_id:
      #       component: # For your module field
      #   tenant_id: "default" # Optional, if you want to specify a tenant ID
      #   format: json # This exporter sends logs as JSON to Prometheus
      #   # Note: Prometheus is typically used for metrics, not logs, but this is an example

    service:
      telemetry:
        logs:
          level: debug

      pipelines:
        # Some pipelines example

        # Prometheus receiver for scraping metrics
        # metrics:
        #   receivers: [ prometheus ]
        #   processors: [ batch ]
        #   exporters: [ prometheus ]

        # OTLP receiver for traces
        # traces:
        #   receivers: [ otlp ]
        #   processors: [ batch ]
        #   exporters: [ otlp/jaeger ]

        # Filelog receiver for logs
        # logs:
        #   receivers: [ filelog ]
        #   processors: [ batch, transform ] # The transform processor is used to modify the log data (defined above)
        #   exporters: [ debug, loki ]
    ```

    **Important:** Adjust the `exporters` section in `otel-collector-config.yaml` to match your desired telemetry backend(s) (e.g., Jaeger, Prometheus, Loki, Elasticsearch, etc.).

4.  **Deploy the collector:** Navigate to the directory containing your `docker-compose.yml` and `otel-collector-config.yaml` files and run:

    ```bash
    docker-compose up -d
    ```

    This will start the OpenTelemetry Collector in the background.

### Option B: Connect to an Existing OpenTelemetry Collector

If you already have an OpenTelemetry Collector running in your environment, you just need to ensure that your application's environment variables (defined in Step 1) point to the correct endpoint of this existing collector.

Verify the following:

* **Collector's IP Address/Hostname:** Make sure `localhost` in the `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`, `OTEL_EXPORTER_OTLP_ENDPOINT_TRACES`, and `OTEL_EXPORTER_OTLP_ENDPOINT_METRICS` variables is replaced with the actual IP address or hostname of your running OpenTelemetry Collector.
* **Collector's OTLP Port:** Confirm that the port `4317` (or `4318` for HTTP) matches the port your existing collector is configured to listen on for OTLP data.

## 3. Test the Integration

Once your applications are configured with the environment variables and the OpenTelemetry Collector is running, it's time to test the integration.

1.  **Start your applications:** Ensure both your `Devana` and `Odin` applications are running.

2.  **Generate some activity:** Interact with your applications to produce logs, traces, and metrics. For example:
    * Make API calls to `Devana`.
    * Perform operations within `Odin`.

3.  **Monitor the OpenTelemetry Collector logs:** If you're running the collector with `docker-compose up`, you can view its logs with:

    ```bash
    docker-compose logs -f otel-collector
    ```

    You should see messages indicating that the collector is receiving telemetry data. If you've configured a `logging` exporter in your `otel-collector-config.yaml`, you'll see the raw telemetry data printed in the collector's logs.

4.  **Check your telemetry backend:**
    * **Traces:** Navigate to your Jaeger UI (or whichever tracing backend you're using). Search for traces from `devana-server` and `odin-server`.
    * **Metrics:** Check your Prometheus/Grafana dashboard. You should see metrics being scraped or pushed from the collector.
    * **Logs:** Verify that logs from `devana-server` and `odin-server` are appearing in your configured log management system (e.g., Loki, Elasticsearch).
    * **File Exporter (for testing):** If you configured the `file` exporter in `otel-collector-config.yaml`, check the specified file path (`/var/log/otel-collector/telemetry.json` in our example) for the exported telemetry data.

By following these steps, you should have a functional on-premise OpenTelemetry setup collecting telemetry data from your `Devana` and `Odin` applications.