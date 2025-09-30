## Système de Surveillance des Metrics d'Usage de l'Application Devana (On-Prem)

### Introduction

Bienvenue dans la documentation de surveillance des metrics d'usage de l'application Devana en mode on-premise. Ce système est essentiel pour garantir une utilisation optimale et conforme de Devana, ainsi que pour vérifier la validité de la licence en cours. Ce document explique en détail l'utilité du système, son fonctionnement, et les types de données collectées. 

### Utilité du Système

Le système de surveillance des metrics d'usage de Devana permet de :
- **Vérifier la validité de la licence** : Assurer que la licence de l'application est toujours valide en effectuant des pings réguliers vers l'adresse l.devana.ai.
- **Suivre l'utilisation de l'application** : Collecter et analyser diverses metrics d'usage pour optimiser les performances et identifier les besoins de maintenance.
- **Assurer la conformité et l'optimisation** : Garantir que l'application est utilisée conformément aux termes de la licence et optimiser l'allocation des ressources.

### Fonctionnement du Système

1. **Vérification de la Licence** :
   - Devana effectue des pings réguliers vers l'adresse `l.devana.ai` pour vérifier la validité de la licence. 
   - Ce processus assure que l'application est toujours sous licence valide et conforme aux termes d'utilisation.
   - **Note** : L'adresse `l.devana.ai` doit être obligatoirement accessible depuis l'infrastructure du client.

2. **Collection des Metrics d'Usage** :
   - Le système collecte les données suivantes :
     - **Licence** : Informations sur la licence en cours.
     - **Nombre d'utilisateurs** : Total des utilisateurs actifs de l'application.
     - **Nombre de messages** : Volume de messages échangés via l'application.
     - **Nombre de tokens** : Quantité de tokens utilisés.
     - **Nombre d'agents** : Nombre d'agents actifs dans l'application.
     - **Nombre de bases de connaissances** : Total des bases de connaissances utilisées.
     - **Utilisation du CPU** : Pourcentage de l'utilisation du processeur.
     - **Utilisation de la RAM** : Quantité de mémoire vive utilisée.
     - **État du réseau** : Statut de la connectivité réseau.
     - **Numéro du processus** : Identifiant du processus en cours d'exécution.

### Sécurité et Confidentialité

- **Aucune donnée confidentielle n'est envoyée** : Le système est conçu pour ne collecter que des metrics d'usage non sensibles. Aucune donnée personnelle ou confidentielle n'est transmise.
- **Transmission sécurisée** : Toutes les communications entre Devana et l'adresse `l.devana.ai` sont sécurisées et chiffrées pour protéger les informations collectées.

### Configuration et Installation

Le module de surveillance est inclus dans le logiciel Devana on-premise. Assurez-vous d'avoir correctement ajouter la licence dans vos variables d’environnement.

### Support et Assistance

Pour toute question ou assistance, veuillez contacter notre équipe de support à l'adresse support@devana.ai.
