# Préparation des configurations

# Avant de commencer nous devons vérifier que les prérequis sont bien présents :

1. Y a t'il un OpenShift, comment y accéder ?
   - Vérification des resources (16CPU / 38Go)
   - Version d'OpenShift (4.15)
2. Y a t'il de firewall ouvert vers l.devana.ai
   - l.devana.ai [OK] besoin d'un proxy
3. Y a t'il les LLMS a disposition ?
   - Azure AI Foundry
   - Pay as you go (4.o, 4.1, ada 3, ada small)
   - API Key
4. Y a t'il un accès au registry, les access sont ils ok ? Le replica est il fait ?
   - Nexus clone les images de registry.devana.ai
   - Il faut faire le fetch normalement c'est [OK]
5. Vérificatin des urls de staging / prod ...
   - OK
6. Récupérer les clés API/accès pour :
   - LLMS
   - BDD si il y a
   - Blob / S3
     - Pas d'API Key ? a vérifier
   - Connecteurs (Sharepoint, Teams, etc)
7. Récupérer/Vérifier les accès aux outils de monitoring (Grafana, Kibana, etc)
   - ELK -> OpenTelemetry

# Préparation des variables d'environnement

- Préparation des variables d'env pour l'API, Front
