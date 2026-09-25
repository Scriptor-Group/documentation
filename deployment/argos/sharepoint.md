# Connexions SharePoint

Argos se connecte aux sites **SharePoint on-premise** (2013, 2016, 2019, Subscription Edition) par leur API REST, avec un compte de service. Chaque site indexé est une **connexion**, créée et pilotée depuis le dashboard (*Connexions SharePoint*).

## 📑 Table des matières

- [Compte de service](#compte-de-service)
- [Créer une connexion](#créer-une-connexion)
- [Authentification](#authentification)
- [Kerberos](#kerberos)
- [Certificats TLS internes](#certificats-tls-internes)
- [Périmètre, filtre et métadonnées](#périmètre-filtre-et-métadonnées)
- [Synchronisation](#synchronisation)

## Compte de service

- Accès en **lecture** aux sites à indexer : membre du groupe *Visiteurs* du site, ou stratégie d'application Web en lecture seule.
- Pour indexer un site entier, le compte doit pouvoir lire toutes ses bibliothèques. Les éléments auxquels il n'a pas accès ne sont pas indexés.
- Le mot de passe et le keytab sont chiffrés dans la base (`ENCRYPTION_KEY`).

## Créer une connexion

*Connexions SharePoint › Nouvelle connexion* :

| Onglet | Réglages |
|---|---|
| **Site & authentification** | Nom, URL du site (ex. `https://portal.example.com/sites/rh`), méthode d'authentification et identifiants |
| **Réseau & TLS** | Délai des requêtes, vérification du certificat TLS, autorité de certification (PEM) |
| **Traitements** | Traitements activés pour ce site (Odin rapide, Odin lent, graphe de connaissances, recherche sémantique), taille max d'un fichier, extensions exclues, indexation des pages du site, exposition sur le MCP principal |
| **Planification** | Fréquence de la synchronisation incrémentale et de la synchronisation complète |

**Tester la connexion** valide l'authentification et liste les bibliothèques du site. Une fois enregistrée, la connexion se lance avec **Synchronisation complète**.

## Authentification

| Méthode | Configuration | Remarques |
|---|---|---|
| **NTLM** | Domaine (optionnel), identifiant, mot de passe | Identifiant au format `compte` avec le domaine, ou `DOMAINE\compte` |
| **Kerberos** | Configuration Kerberos (voir ci-dessous), SPN optionnel | Recommandé lorsque NTLM est désactivé |
| **Basic** | Identifiant, mot de passe | HTTPS impératif |
| **Anonyme** | — | Sites publics uniquement |

## Kerberos

1. **Préparer le compte de service** dans l'Active Directory et générer son **keytab**.
   - SPN du site SharePoint : `HTTP/<hôte SharePoint>`.
   - La procédure (compte, `ktpass`, chiffrement) est décrite dans [Authentification Kerberos — Connecteur SharePoint](../troubleshooting/kerberos.md).
2. **Déclarer la configuration** dans *Paramètres › Kerberos* :
   - royaume (realm), KDC (un par ligne), serveur d'administration ;
   - principal du compte de service ;
   - fichier keytab, téléversé dans le dashboard et stocké chiffré ;
   - options avancées : domaines → royaume, `rdns`, `dns_canonicalize_hostname`, sections additionnelles du `krb5.conf`.

   **URL de test** vérifie l'obtention d'un ticket et l'accès au site.
3. **Choisir cette configuration** dans la connexion SharePoint (méthode Kerberos). Renseignez un SPN seulement si le site est publié sous un autre nom que son hôte.

Les tickets sont obtenus et renouvelés automatiquement ; il n'y a rien à monter dans les conteneurs. Les pods Argos doivent joindre le KDC (port 88) et résoudre l'hôte SharePoint.

## Certificats TLS internes

Si le site SharePoint utilise un certificat émis par une autorité interne, collez le certificat de l'autorité (PEM) dans **Réseau & TLS › Autorité de certification** plutôt que de désactiver la vérification TLS.

## Périmètre, filtre et métadonnées

Onglets de la page d'une connexion :

| Onglet | Rôle |
|---|---|
| **Périmètre** | Bibliothèques et dossiers indexés (inclusions et exclusions) |
| **Filtre** | Conditions sur les métadonnées : seuls les éléments qui les remplissent sont indexés, y compris ceux ajoutés plus tard |
| **Métadonnées** | Colonnes SharePoint exposées aux agents, avec un alias et une description, et utilisables dans les filtres des outils MCP |
| **Synchronisations** | Historique, durées, éléments détectés, journal de chaque exécution |
| **Configuration** | Paramètres de la connexion ; **Réinitialiser l'index** pour repartir de zéro (la configuration est conservée) |

## Synchronisation

- **Complète** : énumère toutes les bibliothèques du périmètre et réconcilie les suppressions.
- **Incrémentale** : lit le journal des modifications SharePoint. Seuls les éléments ajoutés, modifiés ou supprimés sont traités.
- **Reprise** : une synchronisation interrompue (redémarrage, panne réseau) reprend là où elle s'était arrêtée.
- **Arrêt prolongé** : si la synchronisation reste arrêtée plus longtemps que la rétention du journal SharePoint (60 jours par défaut), la bibliothèque concernée est ré-énumérée automatiquement.
- **Traitement des documents** :
  1. une passe **rapide** porte sur tout le périmètre ;
  2. une passe **complète** (OCR et description des images) suit, selon les règles de *Paramètres › Traitement & Odin* : démarrage, plages horaires, priorité aux demandes des utilisateurs.
- **Échecs** : chaque document aboutit à un statut explicite (terminé, vide, non supporté, en échec…). Les documents en échec sont listés, avec leur raison, dans **Traitements en échec**, où ils peuvent être relancés.
