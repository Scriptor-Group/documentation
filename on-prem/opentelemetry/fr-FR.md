# Guide d'installation OpenTelemetry en local (On-Premise)

Ce document décrit les étapes nécessaires pour configurer OpenTelemetry pour vos applications (`Devana` et `Odin`) dans un environnement local. Le processus implique la configuration de variables d'environnement, le déploiement d'un OpenTelemetry Collector, et enfin, le test de l'intégration.

## 1. Définir les variables d'environnement pour vos projets

La première étape consiste à configurer les variables d'environnement OpenTelemetry nécessaires au sein de vos projets d'application. Ces variables indiquent à vos applications d'envoyer les données de télémétrie (logs, traces et métriques) à l'OpenTelemetry Collector.

### Projet Devana

Définissez les variables d'environnement suivantes pour votre application `Devana` :

```bash
OTEL_EXPORTER_OTLP_LOGS_PROTOCOL='grpc'
OTEL_EXPORTER_OTLP_LOGS_ENDPOINT='http://localhost:4317'
OTEL_RESOURCE_ATTRIBUTES="service.name=devana-server,service.version=1.2.3"
```

* `OTEL_EXPORTER_OTLP_LOGS_PROTOCOL` : Spécifie le protocole de communication pour l'exportation des logs. Nous recommandons `grpc`.
* `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` : Le point d'accès où l'OpenTelemetry Collector écoute les logs. Dans cette configuration locale, c'est généralement `http://localhost:4317` si le collecteur est exécuté sur le même hôte.
* `OTEL_RESOURCE_ATTRIBUTES` : Définit les attributs statiques qui décrivent le service, tels que son nom et sa version.

### Projet Odin

Définissez les variables d'environnement suivantes pour votre application `Odin` :

```bash
OTEL_EXPORTER_OTLP_LOGS_ENDPOINT='http://localhost:4317'
OTEL_RESOURCE_ATTRIBUTES="service.name=odin-server,service.version=1.2.3"
OTEL_EXPORTER_OTLP_ENDPOINT_TRACES='http://localhost:4317'
OTEL_EXPORTER_OTLP_ENDPOINT_METRICS='http://localhost:4317'
```

* `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` : Le point d'accès pour les logs, similaire à Devana.
* `OTEL_RESOURCE_ATTRIBUTES` : Définit les attributs statiques pour le service Odin.
* `OTEL_EXPORTER_OTLP_ENDPOINT_TRACES` : Le point d'accès pour l'exportation des traces.
* `OTEL_EXPORTER_OTLP_ENDPOINT_METRICS` : Le point d'accès pour l'exportation des métriques.

**Note** : Assurez-vous que ces variables d'environnement sont correctement définies dans l'environnement de déploiement de votre application (par exemple, `Dockerfile`, `docker-compose.yml`, manifestes de déploiement Kubernetes, ou directement sur l'hôte si l'application s'exécute en tant que processus autonome).

---

## 2. Déployer l'OpenTelemetry Collector

L'OpenTelemetry Collector est un composant crucial qui reçoit, traite et exporte les données de télémétrie. Vous avez deux options pour configurer le collecteur :

### Option A : Créer un nouvel OpenTelemetry Collector avec Docker Compose

Si vous avez déjà un fichier `docker-compose.yml` configuré pour l'OpenTelemetry Collector, vous pouvez l'utiliser pour déployer le collecteur.

1.  **Assurez-vous que Docker et Docker Compose sont installés** : Si ce n'est pas le cas, suivez la documentation officielle de Docker pour les installer sur votre serveur.

2.  **Localisez votre fichier `docker-compose.yml`** : Ce fichier doit définir le service OpenTelemetry Collector. Voici un exemple :

    ```yaml
    # docker-compose.yml
    services:
      otel-collector:
        image: otel/opentelemetry-collector-contrib:latest
        container_name: otel-collector
        restart: always
        command: ["--config=/etc/otel-collector-config.yaml"]
        volumes:
          - ./otel-collector-config.yaml:/etc/otel-collector-config.yaml:ro # Monte le fichier de configuration pour fournir la configuration on-premise (configs ELK/Jaeger/Prometheus/...)
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

3.  **Configurez `otel-collector-config.yaml`** : Ce fichier définit la manière dont le collecteur reçoit, traite et exporte les données de télémétrie. Il est monté en tant que volume dans le conteneur du collecteur. Vous avez mentionné que des exemples sont déjà écrits dans ce fichier. Assurez-vous que ces exemples sont configurés pour recevoir les données OTLP (logs, traces, métriques) et les transférer vers le backend de votre choix (par exemple, Jaeger pour les traces, Prometheus/Grafana pour les métriques, Loki pour les logs, ou un exportateur de fichiers pour les tests).

    Voici un exemple de base de `otel-collector-config.yaml` :

    ```yaml
    # otel-collector-config.yaml
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317 # Lie explicitement gRPC à toutes les interfaces
          http:
            endpoint: 0.0.0.0:4318 # Lie explicitement HTTP à toutes les interfaces

      # Récepteur de fichier de logs pour les logs Pino
      # filelog:
      #   include: [ /var/log/app/app.log ] # Chemin à l'intérieur du conteneur du collecteur (mappé par le volume)
      #   start_at: beginning
      #   poll_interval: 1s
      #   operators:
      #     - id: parse-log-json
      #       type: json_parser
      #       parse_from: body # Analyse explicitement à partir de la chaîne de ligne de log brute
      #       parse_to: attributes["parsed_json"] # Place l'objet JSON analysé ici

    processors:
      batch:
        timeout: 5s
        send_batch_size: 100

    exporters:
      # Exemple d'exportateurs OTLP
      # otlp/jaeger:
      #   endpoint: jaeger:4317
      #   tls:
      #     insecure: true # En mode dev, vous pourriez ne pas vouloir utiliser TLS
      #   headers:
      #     x-otlp-version: "0.16.0" # Exemple d'en-tête, à ajuster si nécessaire
      #   compression: gzip # Facultatif, si vous voulez compresser les données
      #   timeout: 5s # Facultatif, à ajuster si nécessaire
      #   retry_on_failure:
      #     enabled: true
      #     initial_interval: 5s
      #     max_interval: 30s

      # loki:
      #   endpoint: http://loki:3100/loki/api/v1/push
      #   tls:
      #     insecure: true # En mode dev, vous pourriez ne pas vouloir utiliser TLS
      #   headers:
      #     x-tenant-id: "default" # Exemple d'en-tête, à ajuster si nécessaire
      #   labels:
      #     resource:
      #       host.name:
      #       service.name:
      #     attribute:
      #       trace_id:
      #       span_id:
      #       component: # Pour votre champ de module
      #   tenant_id: "default" # Facultatif, si vous voulez spécifier un ID de locataire
      #   format: json # Cet exportateur envoie les logs au format JSON à Loki

      # prometheus:
      #   endpoint: prometheus:9090
      #   tls:
      #     insecure: true # En mode dev, vous pourriez ne pas vouloir utiliser TLS
      #   headers:
      #     x-tenant-id: "default" # Exemple d'en-tête, à ajuster si nécessaire
      #   labels:
      #     resource:
      #       host.name:
      #       service.name:
      #     attribute:
      #       trace_id:
      #       span_id:
      #       component: # Pour votre champ de module
      #   tenant_id: "default" # Facultatif, si vous voulez spécifier un ID de locataire
      #   format: json # Cet exportateur envoie les logs au format JSON à Prometheus
      #   # Note : Prometheus est généralement utilisé pour les métriques, pas les logs, mais c'est un exemple

    service:
      telemetry:
        logs:
          level: debug

      pipelines:
        # Quelques exemples de pipelines

        # Récepteur Prometheus pour le scraping des métriques
        # metrics:
        #   receivers: [ prometheus ]
        #   processors: [ batch ]
        #   exporters: [ prometheus ]

        # Récepteur OTLP pour les traces
        # traces:
        #   receivers: [ otlp ]
        #   processors: [ batch ]
        #   exporters: [ otlp/jaeger ]

        # Récepteur de fichier de logs pour les logs
        # logs:
        #   receivers: [ filelog ]
        #   processors: [ batch, transform ] # Le processeur de transformation est utilisé pour modifier les données de log (définies ci-dessus)
        #   exporters: [ debug, loki ]
    ```

    **Important** : Ajustez la section `exporters` dans `otel-collector-config.yaml` pour qu'elle corresponde à votre ou vos backends de télémétrie souhaités (par exemple, Jaeger, Prometheus, Loki, Elasticsearch, etc.).

4.  **Déployez le collecteur** : Naviguez jusqu'au répertoire contenant vos fichiers `docker-compose.yml` et `otel-collector-config.yaml` et exécutez :

    ```bash
    docker-compose up -d
    ```

    Cela démarrera l'OpenTelemetry Collector en arrière-plan.

### Option B : Se connecter à un OpenTelemetry Collector existant

Si vous avez déjà un OpenTelemetry Collector en cours d'exécution dans votre environnement, vous devez simplement vous assurer que les variables d'environnement de votre application (définies à l'étape 1) pointent vers le point d'accès correct de ce collecteur existant.

Vérifiez les points suivants :

* **Adresse IP/Nom d'hôte du collecteur** : Assurez-vous que `localhost` dans les variables `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`, `OTEL_EXPORTER_OTLP_ENDPOINT_TRACES` et `OTEL_EXPORTER_OTLP_ENDPOINT_METRICS` est remplacé par l'adresse IP ou le nom d'hôte réel de votre OpenTelemetry Collector en cours d'exécution.
* **Port OTLP du collecteur** : Confirmez que le port `4317` (ou `4318` pour HTTP) correspond au port sur lequel votre collecteur existant est configuré pour écouter les données OTLP.

---

## 3. Tester l'intégration

Une fois vos applications configurées avec les variables d'environnement et l'OpenTelemetry Collector en cours d'exécution, il est temps de tester l'intégration.

1.  **Démarrez vos applications** : Assurez-vous que vos deux applications, `Devana` et `Odin`, sont en cours d'exécution.

2.  **Générez de l'activité** : Interagissez avec vos applications pour produire des logs, des traces et des métriques. Par exemple :
    * Effectuez des appels API vers `Devana`.
    * Exécutez des opérations au sein d'`Odin`.

3.  **Surveillez les logs de l'OpenTelemetry Collector** : Si vous exécutez le collecteur avec `docker-compose up`, vous pouvez consulter ses logs avec :

    ```bash
    docker-compose logs -f otel-collector
    ```

    Vous devriez voir des messages indiquant que le collecteur reçoit des données de télémétrie. Si vous avez configuré un exportateur `logging` dans votre `otel-collector-config.yaml`, vous verrez les données de télémétrie brutes affichées dans les logs du collecteur.

4.  **Vérifiez votre backend de télémétrie** :
    * **Traces** : Accédez à votre interface utilisateur Jaeger (ou à tout autre backend de traçage que vous utilisez). Recherchez des traces provenant de `devana-server` et `odin-server`.
    * **Métriques** : Vérifiez votre tableau de bord Prometheus/Grafana. Vous devriez voir les métriques collectées ou poussées par le collecteur.
    * **Logs** : Vérifiez que les logs de `devana-server` et `odin-server` apparaissent dans votre système de gestion de logs configuré (par exemple, Loki, Elasticsearch).
    * **Exportateur de fichiers (pour les tests)** : Si vous avez configuré l'exportateur `file` dans `otel-collector-config.yaml`, vérifiez le chemin de fichier spécifié (`/var/log/otel-collector/telemetry.json` dans notre exemple) pour les données de télémétrie exportées.

En suivant ces étapes, vous devriez disposer d'une configuration OpenTelemetry on-premise fonctionnelle, collectant des données de télémétrie à partir de vos applications `Devana` et `Odin`.