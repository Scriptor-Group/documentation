# Déployer les compléments Office

Cette page explique comment déployer les compléments Suite 366 (Word, Excel, PowerPoint, Outlook) selon l'écosystème Microsoft de l'organisation : Microsoft 365 avec Exchange Online, hybride, ou tout on-premises. Elle complète la [vue d'ensemble des compléments](./README.md), qui décrit les outils disponibles par version d'Office.

> **Support** : pour toute question, contactez support-it@devana.ai

---

## Ce qui est déployé

- **Un manifeste par application** : un fichier XML qui contient l'adresse de la plateforme, la description du bouton **Assistant** du ruban et la permission demandée, sans aucun secret. Le volet lui-même est servi par la plateforme Suite 366 et se met à jour avec elle.
- **Cinq manifestes**, générés par la plateforme pour son adresse et téléchargeables dans *Paramètres › Compléments Office* (liens des administrateurs) :

| Manifeste | Application | Permission demandée | Usage |
|---|---|---|---|
| Word | Word | Lecture et écriture du document | Tous les écosystèmes |
| Excel | Excel | Lecture et écriture du document | Tous les écosystèmes |
| PowerPoint | PowerPoint | Lecture et écriture du document | Tous les écosystèmes |
| Outlook (standard) | Outlook | Lecture et écriture de l'élément ouvert | Exchange Online ; Exchange on-premises sans EWS |
| Outlook (EWS) | Outlook | Lecture et écriture de la boîte aux lettres | Exchange on-premises : ajoute par EWS les fonctions absentes des versions on-premises (voir [Outlook et Exchange on-premises](./README.md#outlook-et-exchange-on-premises)) |

Un seul manifeste Outlook est déployé à la fois. Les deux portent des identifiants distincts : passer de l'un à l'autre consiste à retirer le premier puis à ajouter le second.

Le manifeste est au format XML (*add-in only manifest*) : Microsoft indique que le manifeste unifié JSON ne s'installe pas pour des boîtes hébergées sur Exchange Server on-premises ni dans les versions perpétuelles d'Office.

Prérequis communs (poste, HTTPS, flux réseau) : voir [Prérequis](./README.md#prérequis).

---

## Choisir le mode de déploiement

| Écosystème | Word, Excel, PowerPoint | Outlook |
|---|---|---|
| Microsoft 365, boîtes aux lettres Exchange Online | Applications intégrées du centre d'administration Microsoft 365 | Applications intégrées, manifeste standard |
| Hybride (boîtes réparties entre Exchange Online et Exchange on-premises) | Applications intégrées pour les utilisateurs dont la boîte est dans Exchange Online ; pour les autres, comme tout on-premises | Boîtes Exchange Online : Applications intégrées, manifeste standard. Boîtes on-premises : Exchange on-premises, manifeste EWS ou standard |
| Tout on-premises (Exchange Server, Office LTSC ou Microsoft 365 Apps sans Exchange Online) | Catalogue SharePoint déclaré par stratégie de groupe, ou installation par l'utilisateur | Centre d'administration Exchange ou `New-App`, manifeste EWS (recommandé) ou standard |

La règle qui découle de la documentation Microsoft : le déploiement par le centre d'administration Microsoft 365 (*Applications intégrées*) exige des boîtes **Exchange Online** et ne s'applique pas aux boîtes Exchange on-premises, y compris pour Word, Excel et PowerPoint (*« Centralized deployment is only supported for online mailboxes. It doesn't support deployment to on-premises Exchange mailboxes. »*). Le partage par population en hybride en est la conséquence ; Microsoft ne le décrit pas en toutes lettres.

### Clients pris en charge

| Client | Exchange Online | Exchange on-premises |
|---|---|---|
| Word, Excel, PowerPoint sur Windows (LTSC 2021, LTSC 2024, Microsoft 365 Apps) | Oui | Oui |
| Word, Excel, PowerPoint pour Mac | Oui | Oui, hors catalogue SharePoint (voir [Postes Mac](#postes-mac)) |
| Outlook classique pour Windows | Oui | Oui |
| Nouvel Outlook pour Windows | Oui | Non : Microsoft ne prend pas en charge les comptes on-premises, hybrides ou souverains dans ce client |
| Outlook pour Mac | Oui | Oui : la nouvelle interface accepte les comptes Exchange on-premises et leurs compléments ; l'ancienne interface fonctionne avec Exchange on-premises jusqu'au 9 octobre 2029 selon Microsoft |
| Outlook sur le web | Oui | Oui, interface classique servie par Exchange (le complément est déployé sur la boîte) ; non recetté |
| Outlook sur Android et iOS | Non : le manifeste ne déclare que le format bureau | Non : Microsoft ne prend pas en charge les compléments avec un compte Exchange on-premises |
| Word, Excel, PowerPoint sur le web | Non ciblé | Non ciblé |

---

## Microsoft 365 avec Exchange Online

Les cinq manifestes s'ajoutent par leur adresse, sans fichier à manipuler.

1. Dans *Paramètres › Compléments Office* de la plateforme, copier le lien du manifeste (Word, Excel, PowerPoint, Outlook standard).
2. Centre d'administration Microsoft 365 › *Paramètres* › *Applications intégrées* › *Charger des applications personnalisées*, puis *Fournir un lien vers le fichier manifeste*.
3. Choisir les utilisateurs ou les groupes, valider les permissions.

- **Prérequis Microsoft** : boîtes aux lettres Exchange Online, utilisateurs connectés à Office avec leur compte professionnel.
- **Bouton du ruban** : affiché sans action de l'utilisateur.
- **Outlook** : manifeste standard. Le manifeste EWS n'apporte rien sur Exchange Online, où Microsoft a désactivé les jetons Exchange hérités.

---

## Hybride

Les deux modes coexistent, par population :

- **Utilisateurs dont la boîte est dans Exchange Online** : comme [Microsoft 365 avec Exchange Online](#microsoft-365-avec-exchange-online), pour Word, Excel, PowerPoint et Outlook (manifeste standard).
- **Utilisateurs dont la boîte est on-premises** : Outlook par [Exchange on-premises](#outlook-avec-exchange-on-premises) (manifeste EWS ou standard), Word, Excel et PowerPoint comme [sans Exchange Online](#word-excel-et-powerpoint-sans-exchange-online).

---

## Tout on-premises

### Outlook avec Exchange on-premises

L'administrateur Exchange ajoute le complément pour l'organisation. Aucune action n'est demandée aux utilisateurs.

**1. Choisir le manifeste.**

- **EWS (recommandé)** : les 21 outils garantis sur Exchange on-premises, dont le transfert, la lecture du contenu des pièces jointes et les catégories (détail dans [Outlook et Exchange on-premises](./README.md#outlook-et-exchange-on-premises)). Demande la permission de lecture et d'écriture de la boîte aux lettres.
- **Standard** : 15 outils garantis sur Mailbox 1.5, plus ceux des jeux 1.6 et 1.8 si le client Outlook les expose. Accès limité à l'élément ouvert.

**2. Prérequis Exchange.**

| Prérequis | Manifeste standard | Manifeste EWS |
|---|---|---|
| Exchange Server 2016, 2019 ou Subscription Edition | Oui | Oui |
| Compléments autorisés dans l'organisation : `Get-OrganizationConfig \| Format-List AppsForOfficeEnabled` doit renvoyer `True` | Oui | Oui |
| EWS activé, avec l'authentification OAuth sur son répertoire virtuel : `Set-WebServicesVirtualDirectory -Identity "<serveur>\EWS (Default Web Site)" -OAuthAuthentication $true` | Non | Oui |
| Installation par un administrateur (Microsoft le réserve aux administrateurs pour ce niveau de permission) | Non | Oui, avec `-AllowReadWriteMailbox` |

Microsoft liste aussi, parmi les prérequis des compléments avec Exchange on-premises : *« Exchange Web Services (EWS) must be enabled and must be exposed to the Internet »* et *« The server must have a valid authentication certificate in order for the server to issue valid identity tokens »*.

**3. Importer le manifeste.** Télécharger le fichier dans *Paramètres › Compléments Office*, puis, dans Exchange Management Shell :

```powershell
# Manifeste EWS
New-App -OrganizationApp -FileData ([System.IO.File]::ReadAllBytes("C:\Temp\suite366-outlook-ews.xml")) -AllowReadWriteMailbox -ProvidedTo Everyone -DefaultStateForUser Enabled

# Manifeste standard
New-App -OrganizationApp -FileData ([System.IO.File]::ReadAllBytes("C:\Temp\suite366-outlook.xml")) -ProvidedTo Everyone -DefaultStateForUser Enabled
```

- **Pilote** : `-ProvidedTo SpecificUsers -UserList "utilisateur1@exemple.org","utilisateur2@exemple.org"`.
- **Par le centre d'administration Exchange** : *Organisation › Compléments*, ajout à partir d'un fichier.
- **Par adresse** (`-Url` au lieu de `-FileData`) : le serveur Exchange télécharge alors lui-même le manifeste ; il doit joindre l'adresse de la plateforme, sans redirection (*« The Exchange server must be able to reach the target URL »*). Importé en fichier, le manifeste ne demande aucun flux du serveur Exchange vers la plateforme.
- **Office Store** : un complément d'organisation n'y passe pas ; bloquer l'accès des utilisateurs au Store ne l'empêche pas.

**4. Postes.** Outlook classique sur Windows, ou Outlook pour Mac. Le nouvel Outlook pour Windows ne se connecte pas aux boîtes on-premises.

### Word, Excel et PowerPoint sans Exchange Online

Pour Word, Excel et PowerPoint sans Exchange Online, le mode on-premises que Microsoft documente pour la production est le catalogue SharePoint. Les deux autres modes ci-dessous fonctionnent, mais Microsoft ne les prend pas en charge en production.

| Mode | Prérequis | Bouton Assistant dans le ruban | Pris en charge par Microsoft en production |
|---|---|---|---|
| Catalogue d'applications SharePoint Server, déclaré comme catalogue approuvé par stratégie de groupe | SharePoint Server ; Windows uniquement | Non : Microsoft ne prend pas en charge les boutons du ruban dans ce mode ; le volet s'ouvre depuis *Insertion › Mes compléments* | Oui |
| Partage réseau déclaré comme catalogue approuvé | Partage en lecture seule contenant les manifestes ; Windows uniquement | Oui, après une première insertion depuis *Mes compléments* | Non : *« Deployment by network share isn't supported for production add-ins »* |
| Installation par l'utilisateur depuis *Paramètres › Compléments Office* | Exécution d'un petit script autorisée sur le poste (Windows) ou commande Terminal (Mac), sans droits administrateur | Oui | Non : repose sur le mécanisme de chargement réservé par Microsoft aux tests |

**Catalogue SharePoint.**

1. Créer le catalogue d'applications sur SharePoint Server et y déposer les manifestes Word, Excel et PowerPoint téléchargés depuis la plateforme.
2. Déclarer le catalogue sur les postes par stratégie de groupe. Microsoft indique l'emplacement des paramètres dans les modèles d'administration de Microsoft 365 Apps, Office LTSC 2021, Office 2019 et Office 2016 (intitulés anglais) : *User Configuration › Policies › Administrative Templates › Microsoft Office 2016 › Security Settings › Trust Center › Trusted Catalogs*.
3. Les utilisateurs insèrent le complément depuis *Insertion › Mes compléments*.

**Installation par l'utilisateur.** Dans *Paramètres › Compléments Office*, un programme d'installation (Windows) ou une commande (Mac) servi par la plateforme déclare les trois manifestes sur le poste. Ce mode garde le bouton du ruban et convient à un pilote ; une organisation qui exige un mode pris en charge par Microsoft passe par le catalogue SharePoint. Outlook ne s'installe pas ainsi : il se déploie sur les boîtes aux lettres.

### Postes Mac

- **Word, Excel, PowerPoint** : Microsoft ne prend pas en charge les catalogues SharePoint sur Mac. Avec Exchange Online, les Applications intégrées s'appliquent. Sans Exchange Online, la commande d'installation de la plateforme dépose les manifestes dans le dossier de compléments de chaque application, mécanisme que Microsoft réserve aux tests.
- **Outlook** : déployé sur la boîte aux lettres comme sur Windows ; rien à faire sur le poste.

---

## Mises à jour

- **Le volet** est servi par la plateforme : il se met à jour avec elle, sans action sur les postes, sur le serveur Exchange ni dans les catalogues.
- **Le manifeste** ne change que si le bouton du ruban, les permissions demandées ou l'adresse de la plateforme changent. Sa version est alors incrémentée, et le nouveau fichier est à réimporter (Exchange, Applications intégrées) ou à redéposer (catalogue). Microsoft indique qu'un manifeste de version supérieure remplace l'ancien à l'installation, et qu'un complément déployé pour toute l'organisation demande alors un nouveau consentement de l'administrateur.
- **Changement d'adresse de la plateforme** : l'identifiant de chaque complément dérive de cette adresse ; les manifestes sont à redéployer.

---

## Vérifier le déploiement

1. **Le bouton** : *Assistant* apparaît dans le ruban (onglet Accueil de Word, Excel, PowerPoint ; message ou rendez-vous ouvert dans Outlook), sauf avec le catalogue SharePoint (*Insertion › Mes compléments*).
2. **Le diagnostic** : dans le volet, *Réglages › Diagnostic* affiche le moteur web, les jeux d'API exposés par Office et, avec le manifeste Outlook EWS, la mention « EWS ».
3. **La connexion** : *Se connecter avec Suite 366* ouvre la page de connexion de la plateforme ; une fois connecté, la liste des modèles et des agents de l'organisation s'affiche.

---

## Sources

Documentation Microsoft consultée le 28 octobre 2026 :

- [Deploy and publish Office Add-ins](https://learn.microsoft.com/office/dev/add-ins/publish/publish)
- [Centralized deployment FAQ](https://learn.microsoft.com/microsoft-365/admin/manage/centralized-deployment-faq)
- [Deploy add-ins in the Microsoft 365 admin center](https://learn.microsoft.com/microsoft-365/admin/manage/office-addins)
- [New-App (Exchange PowerShell)](https://learn.microsoft.com/powershell/module/exchangepowershell/new-app)
- [Use Exchange Web Services (EWS) from an Outlook add-in in Exchange on-premises](https://learn.microsoft.com/office/dev/add-ins/outlook/web-services)
- [Privacy and security for Office Add-ins](https://learn.microsoft.com/office/dev/add-ins/concepts/privacy-and-security)
- [Requirements for running Office Add-ins](https://learn.microsoft.com/office/dev/add-ins/concepts/requirements-for-running-office-add-ins)
- [Office Add-ins manifest overview](https://learn.microsoft.com/office/dev/add-ins/develop/xml-manifest-overview)
- [Unified manifest for Microsoft 365](https://learn.microsoft.com/office/dev/add-ins/develop/unified-manifest-overview)
- [Publish task pane and content add-ins to an app catalog on SharePoint](https://learn.microsoft.com/office/dev/add-ins/publish/publish-task-pane-and-content-add-ins-to-an-add-in-catalog)
- [Create a network shared folder catalog for task pane and content add-ins](https://learn.microsoft.com/office/dev/add-ins/testing/create-a-network-shared-folder-catalog-for-task-pane-and-content-add-ins)
- [Sideload Office Add-ins on Mac for testing](https://learn.microsoft.com/office/dev/add-ins/testing/sideload-an-office-add-in-on-mac)
- [Outlook JavaScript API requirement sets](https://learn.microsoft.com/javascript/api/requirement-sets/outlook/outlook-api-requirement-sets)
- [Develop Outlook add-ins for the new Outlook on Windows](https://learn.microsoft.com/office/dev/add-ins/outlook/one-outlook)
- [Add-ins for Outlook on mobile devices](https://learn.microsoft.com/office/dev/add-ins/outlook/outlook-mobile-addins)
- [Outlook for Mac](https://support.microsoft.com/outlook/outlook-for-mac) et [End of support for legacy Outlook for Mac](https://support.microsoft.com/outlook/end-of-support-for-legacy-outlook-for-mac)
