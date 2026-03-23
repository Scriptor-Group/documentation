# Installation PostgreSQL pour Devana

## Table des matières
- [Recommandations pour la Production](#recommandations-pour-la-production)
- [Services Cloud Recommandés](#services-cloud-recommandés)
- [Installation Locale pour le Développement](#installation-locale-pour-le-développement)
- [Configuration pour Devana](#configuration-pour-devana)
- [Gestion de la Base de Données](#gestion-de-la-base-de-données)

## Recommandations pour la Production

Pour les environnements de production, nous recommandons fortement d'utiliser une version hébergée de PostgreSQL auprès de votre fournisseur cloud. Cette approche offre plusieurs avantages :

- Haute disponibilité et réplication automatique
- Sauvegardes automatisées
- Mise à l'échelle simplifiée
- Maintenance et mises à jour gérées
- Monitoring intégré
- Support professionnel

## Services Cloud Recommandés

### AWS
- Amazon RDS pour PostgreSQL
- Amazon Aurora PostgreSQL
```bash
# Configuration minimale recommandée
Instance Type: db.t3.medium
Storage: 100 GB
Multi-AZ: Enabled
Version: PostgreSQL 14 ou supérieure
```

### Google Cloud
- Cloud SQL pour PostgreSQL
```bash
# Configuration minimale recommandée
Machine Type: db-g1-small
Storage: 100 GB
High Availability: Enabled
Version: PostgreSQL 14 ou supérieure
```

### Azure
- Azure Database pour PostgreSQL
```bash
# Configuration minimale recommandée
Compute: General Purpose, 2 vCores
Storage: 100 GB
Version: PostgreSQL 14 ou supérieure
```

## Installation Locale pour le Développement

Pour le développement local, vous pouvez installer PostgreSQL directement sur votre machine.

### Utilisation de Docker (Recommandé pour le développement)

1. Créez un fichier `docker-compose.yml` :
```yaml
version: '3.8'
services:
  postgres:
    image: postgres:14
    environment:
      POSTGRES_USER: devana
      POSTGRES_PASSWORD: devana_password
      POSTGRES_DB: devana
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    command: 
      - "postgres"
      - "-c"
      - "max_connections=1000"
      - "-c"
      - "shared_buffers=256MB"
volumes:
  postgres_data:
```

2. Démarrez le conteneur :
```bash
docker-compose up -d
```

### Installation Native

#### Sur Ubuntu/Debian
```bash
# Installation
sudo apt update
sudo apt install postgresql-14

# Démarrage du service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Création de l'utilisateur et de la base de données
sudo -u postgres psql -c "CREATE USER devana WITH PASSWORD 'devana_password';"
sudo -u postgres psql -c "CREATE DATABASE devana OWNER devana;"
```

#### Sur macOS avec Homebrew
```bash
# Installation
brew install postgresql@14

# Démarrage du service
brew services start postgresql@14

# Création de l'utilisateur et de la base de données
createuser -s devana
createdb -O devana devana
```

## Configuration pour Devana

### Paramètres Recommandés

Ajoutez ces paramètres dans votre `postgresql.conf` :

```ini
# Connexions
max_connections = 1000
shared_buffers = 256MB

# Performance
effective_cache_size = 1GB
maintenance_work_mem = 128MB
work_mem = 8MB

# WAL
wal_level = replica
max_wal_size = 1GB
min_wal_size = 80MB

# Query Planner
random_page_cost = 1.1
effective_io_concurrency = 200
```

### Variables d'Environnement Devana

Configurez votre connexion dans les variables d'environnement de Devana :

```env
DATABASE_URL=postgresql://devana:devana_password@localhost:5432/devana
```

Pour la production, utilisez l'URL de connexion fournie par votre service cloud.

## Gestion de la Base de Données

### Initialisation Automatique

L'initialisation et les migrations de la base de données sont gérées automatiquement par le service API de Devana au démarrage. Aucune action manuelle n'est nécessaire.

> **Note**: Assurez-vous simplement que la base de données est créée et accessible via l'URL de connexion fournie dans les variables d'environnement.

### Sauvegarde et Restauration

#### Stratégie de sauvegarde recommandée

Une politique de sauvegarde robuste doit couvrir les aspects suivants :

**Fréquence et rétention**

| Type de sauvegarde | Fréquence | Rétention minimale |
|---|---|---|
| Sauvegarde complète (full) | Quotidienne | 30 jours |
| Sauvegarde incrémentale / WAL archiving | Continue (temps réel) | 7 jours |
| Sauvegarde longue durée | Hebdomadaire | 90 jours minimum |

**Objectifs de reprise**

Définissez et documentez vos objectifs de reprise avant la mise en production :

- **RPO (Recovery Point Objective)** — perte de données maximale acceptable. Avec l'archivage WAL continu, le RPO peut être ramené à quelques secondes.
- **RTO (Recovery Time Objective)** — durée maximale d'indisponibilité acceptable. Dépend de la taille de la base et de l'infrastructure (réplication, failover automatique).

> **Recommandation** : documentez vos RPO/RTO cibles et validez-les par des tests réguliers.

**Stockage des sauvegardes**

- Conservez les sauvegardes dans un **emplacement géographiquement distinct** de la base de production
- Utilisez un stockage chiffré (au repos et en transit)
- Appliquez le principe du **3-2-1** : 3 copies, 2 supports différents, 1 copie hors site

#### Tests de restauration

> **Les sauvegardes qui ne sont pas testées ne sont pas des sauvegardes.**

Mettez en place une procédure de test de restauration régulière :

- **Fréquence** : au minimum **trimestrielle**, idéalement **mensuelle**
- **Périmètre** : restauration complète sur un environnement isolé (staging ou dédié)
- **Validation** : vérifiez l'intégrité des données restaurées (comptage de tables, cohérence applicative, requêtes de contrôle)
- **Chronométrage** : mesurez le temps de restauration réel et comparez-le à votre RTO cible
- **Documentation** : consignez chaque test dans un **rapport de restauration** incluant :
  - Date du test
  - Sauvegarde utilisée (date, type)
  - Temps de restauration constaté
  - Résultat (succès / échec / anomalies)
  - Actions correctives si nécessaire

```bash
# Exemple de test de restauration sur un environnement isolé
createdb -U devana devana_restore_test
pg_restore -U devana -d devana_restore_test -v backup.dump

# Vérification de l'intégrité
psql -U devana -d devana_restore_test -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';"

# Nettoyage après test
dropdb -U devana devana_restore_test
```

#### Supervision des sauvegardes

- **Alerting** : configurez des alertes en cas d'échec de sauvegarde (email, webhook, monitoring)
- **Journalisation** : conservez un historique horodaté des sauvegardes réalisées et de leur statut
- **Audit** : revoyez périodiquement la politique de sauvegarde (au moins annuellement) et après tout incident majeur

#### Pour la Production (Services Cloud)
- Utilisez les fonctionnalités de sauvegarde automatique de votre fournisseur cloud
- Configurez la rétention selon la politique décrite ci-dessus
- Activez la réplication multi-zones si disponible
- **Activez le Point-in-Time Recovery (PITR)** pour permettre une restauration à un instant précis
- Vérifiez que votre fournisseur permet l'**export des sauvegardes** vers un stockage externe

#### Pour le Développement Local
```bash
# Sauvegarde
pg_dump -U devana -d devana -F c -b -v -f backup.dump

# Restauration
pg_restore -U devana -d devana -v backup.dump
```

## Monitoring et Maintenance

### Requêtes de Monitoring Utiles

```sql
-- Taille des tables
SELECT schemaname, relname, pg_size_pretty(pg_total_relation_size(relid))
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

-- Connexions actives
SELECT * FROM pg_stat_activity WHERE state = 'active';

-- Performances des index
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

## Notes de Sécurité

- Utilisez toujours des mots de passe forts
- Limitez l'accès à la base de données aux seules adresses IP nécessaires
- Activez SSL/TLS pour les connexions
- Effectuez des sauvegardes régulières
- Gardez PostgreSQL à jour avec les derniers correctifs de sécurité

## Support

Pour toute question ou problème :
1. Consultez la [documentation PostgreSQL officielle](https://www.postgresql.org/docs/)
2. Contactez le support de votre fournisseur cloud pour les instances hébergées
3. Ouvrez un ticket auprès du support Devana pour les questions spécifiques à l'application