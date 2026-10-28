# Compléments Office Suite 366 : Word, Excel, PowerPoint, Outlook

Les compléments Office Suite 366 ajoutent un **volet assistant IA** dans Word, Excel, PowerPoint et Outlook. L'assistant lit et modifie le document ouvert (ou le message, ou le rendez-vous) au moyen d'**outils** adaptés à chaque application, en s'appuyant sur les agents et les modèles de votre plateforme Suite 366.

Les outils disponibles dépendent de la **version d'Office** installée sur le poste : cette page indique, pour chaque version, ce qui fonctionne.

> **Support** : pour toute question, contactez support-it@devana.ai

---

## Fonctionnement

- **Un volet par application** : un bouton **Assistant** dans le ruban ouvre le volet de conversation, à côté du document.
- **Servi par la plateforme** : le volet et ses manifestes sont publiés par votre plateforme Suite 366 elle-même, à son adresse (*Paramètres › Compléments Office*). Aucun serveur web supplémentaire n'est à installer, aucune adresse n'est à saisir sur le poste.
- **Connexion** : au premier usage, *Se connecter avec Suite 366* ouvre la page de connexion de la plateforme, avec son authentification habituelle (SSO compris). Une **clé personnelle** est alors créée pour le complément : valable 180 jours, révocable dans *Paramètres › Clés API*. Une clé `sk_user_…` collée à la main reste possible.
- **Modèles et agents** : le volet propose les modèles et les agents configurés par l'organisation dans la plateforme, modèle hébergé en interne compris. Rien n'est configuré sur les postes.
- **Outils** : l'assistant lit le document, puis agit par des outils précis (réécrire des paragraphes, créer un tableau croisé dynamique, composer une diapositive, préparer une réponse…). Une confirmation peut être exigée avant chaque modification.
- **Amélioration progressive** : au démarrage, le complément interroge Office sur les jeux d'API disponibles. Un outil non pris en charge par la version installée n'est pas proposé à l'assistant ; le reste fonctionne normalement.
- **Outlook** : le complément n'envoie jamais de message. Réponses, nouveaux messages et rendez-vous sont **ouverts pré-remplis**, ou enregistrés dans les Brouillons puis ouverts (transfert) ; l'utilisateur relit et envoie.

---

## Compatibilité en bref

Nombre d'outils disponibles, par version d'Office sur Windows. La version et le build se lisent dans *Fichier › Compte › À propos de Word* (ex. « Version 2302 (build 16130.20332) »).

| Office | Word | Excel | PowerPoint | Outlook + Exchange on-premises ² | Outlook + Exchange Online |
|---|---|---|---|---|---|
| LTSC 2021 (version 2108) | 24 / 33 | 38 / 38 | 5 / 22 | 15 / 24 ; 21 / 24 avec EWS | 20 / 24 |
| Microsoft 365, version 2302 ¹ | 31 / 33 | 38 / 38 | 20 / 22 | 15 / 24 ; 21 / 24 avec EWS | 20 / 24 |
| LTSC 2024 (version 2408) | 33 / 33 | 38 / 38 | 20 / 22 | 15 / 24 ; 21 / 24 avec EWS | 20 / 24 |
| Microsoft 365, version 2504 ou ultérieure | 33 / 33 | 38 / 38 | 22 / 22 | 15 / 24 ; 21 / 24 avec EWS | 20 / 24 |
| Office pour Mac (version à jour) | 33 / 33 | 38 / 38 | 22 / 22 | 15 / 24 ; 21 / 24 avec EWS | 20 / 24 ³ |

1. À partir du build **16130.20332**. Un build 2302 antérieur limite Word à 28 / 33.
2. Exchange Server on-premises (2016, 2019, Subscription Edition) plafonne à Mailbox 1.5. Avec le manifeste standard, 15 outils sont garantis et 5 dépendent du client Outlook. Avec le manifeste **EWS**, prévu pour Exchange on-premises, 21 outils sont garantis et 3 restent à confirmer. Voir [Outlook et Exchange on-premises](#outlook-et-exchange-on-premises).
3. Nouvelle interface d'Outlook pour Mac (16.38.506 ou ultérieure).

**Non pris en charge** : Office 2016 et 2019 (fin de support Microsoft en octobre 2025). PowerPoint 2019 en licence en volume ne charge pas le complément. Word, Excel et PowerPoint sur le web ne sont pas ciblés. Le nouvel Outlook pour Windows et Outlook sur Android et iOS n'acceptent pas les compléments avec une boîte Exchange on-premises (voir [Déployer les compléments Office](./deploiement.md)).

---

## Prérequis

### Poste de travail

| Élément | Exigence |
|---|---|
| Système | Windows 11, ou Windows 10 version 1903 ou ultérieure ; macOS pris en charge par Office 16 |
| Office | LTSC 2021, LTSC 2024 ou Microsoft 365 Apps sur Windows ; Office 16 sur Mac |
| Moteur web (Windows) | **Microsoft Edge WebView2 Runtime**, installé avec les versions d'Office prises en charge. S'il est absent, Office utilise un ancien moteur et le volet affiche un message « navigateur non pris en charge ». Déployable hors ligne (programme d'installation autonome ou version fixe). |
| Moteur web (Mac) | Safari (WKWebView), rien à installer |

### Plateforme et messagerie

| Élément | Exigence |
|---|---|
| Plateforme Suite 366 | Servie en **HTTPS** avec un certificat reconnu par les postes (une autorité de certification interne convient). Office refuse les adresses HTTP et les certificats non approuvés. |
| Exchange (Outlook) | Exchange Server 2016, 2019 ou Subscription Edition, ou Exchange Online. Client : Outlook classique sur Windows, ou Outlook pour Mac. Manifeste EWS : EWS activé, avec l'authentification OAuth sur son répertoire virtuel (voir [Outlook et Exchange on-premises](#outlook-et-exchange-on-premises)) |
| Authentification | Aucune authentification auprès d'un service cloud : l'utilisateur se connecte à la plateforme Suite 366. Le complément lui-même ne demande aucun compte Microsoft ; seul le déploiement par le centre d'administration Microsoft 365 suppose des utilisateurs connectés à Office. |

### Flux réseau

| Source | Destination | Usage | Requis |
|---|---|---|---|
| Postes (Word, Excel, PowerPoint, Outlook) | Plateforme Suite 366, HTTPS (443) | Chargement du volet et échanges avec l'assistant | Oui |
| Postes | `appsforoffice.microsoft.com`, HTTPS (443) | Bibliothèque Office.js de Microsoft, chargée sans aucune donnée utilisateur | Oui, sauf avec une version de la plateforme qui embarque Office.js (sur demande, pour un réseau fermé) |
| Serveurs Exchange | Plateforme Suite 366 | Aucun flux quand le manifeste est importé en fichier ; lecture du manifeste seulement s'il est ajouté par son adresse | Non |
| Outlook (postes) | Serveur Exchange de la boîte aux lettres | Manifeste EWS : requêtes EWS du complément, transmises par Outlook avec les droits de l'utilisateur | Avec le manifeste EWS |
| Serveurs Exchange | Adresse d'un fichier à joindre | Quand l'assistant joint un fichier par son adresse (réponse avec fichier, ou Outlook sans Mailbox 1.8), Exchange télécharge lui-même le fichier ; avec Mailbox 1.8, c'est le poste | Seulement pour ces pièces jointes |
| Plateforme Suite 366 | Serveurs Exchange | Aucun flux | Non |
| Plateforme Suite 366 | Fournisseur de modèle | Traitement des demandes de l'assistant, par le modèle configuré par l'organisation (modèle hébergé en interne possible) | Selon la configuration |

Le déploiement est détaillé dans [Déployer les compléments Office](./deploiement.md).

---

## Versions d'Office et jeux d'API

Chaque application expose des **jeux d'API** (requirement sets) numérotés ; plus la version d'Office est récente, plus le jeu est élevé. La colonne « API min. » des [tableaux d'outils](#outils-par-version) renvoie à ces jeux.

Colonnes : Windows avec abonnement Microsoft 365 ou licence perpétuelle retail (version et build minimum) ; Windows en licence en volume (LTSC) ; Mac (version minimum).

### Word

| Jeu d'API | Microsoft 365 / retail | Licence en volume | Mac | Outils |
|---|---|---|---|---|
| WordApi 1.1 | 1509 (4266.1001) | Office 2016 et ultérieur | 15.19 | 17 / 33 |
| WordApi 1.3 | 1612 (7668.1000) | Office 2019, LTSC 2021 | 15.32 | 24 / 33 |
| WordApi 1.4 | 2208 (15601.20148) | LTSC 2024 | 16.64 | 28 / 33 |
| WordApi 1.5 | 2302 (16130.20332) | LTSC 2024 | 16.70 | 31 / 33 |
| WordApi 1.6 | 2308 (16731.20234) | LTSC 2024 | 16.76 | 33 / 33 |

### Excel

Tous les outils sont disponibles à partir d'**ExcelApi 1.10** : version 1907, LTSC 2021, Mac 16.30.

| Jeu d'API | Microsoft 365 / retail | Licence en volume | Mac | Outils |
|---|---|---|---|---|
| ExcelApi 1.1 | 1509 (4266.1001) | Office 2016 et ultérieur | 15.20 | 22 / 38 |
| ExcelApi 1.2 | 1601 (6741.2088) | Office 2019 | 15.22 | 28 / 38 |
| ExcelApi 1.4 | 1701 (7870.2024) | Office 2019 | 15.36 | 30 / 38 |
| ExcelApi 1.6 | 1704 (8201.2001) | Office 2019 | 15.36 | 31 / 38 |
| ExcelApi 1.7 | 1801 (9001.2171) | Office 2019 | 16.9 | 32 / 38 |
| ExcelApi 1.8 | 1808 (10730.20102) | LTSC 2021 | 16.17 | 34 / 38 |
| ExcelApi 1.9 | 1903 (11425.20204) | LTSC 2021 | 16.24 | 36 / 38 |
| ExcelApi 1.10 | 1907 (11929.20306) | LTSC 2021 | 16.30 | 38 / 38 |

### PowerPoint

Le complément se charge à partir de **PowerPointApi 1.1** : version 1810, LTSC 2021 ou Mac 16.19.

| Jeu d'API | Microsoft 365 / retail | Licence en volume | Mac | Outils |
|---|---|---|---|---|
| PowerPointApi 1.1 | 1810 (11001.20074) | LTSC 2021 | 16.19 | 4 / 22 |
| PowerPointApi 1.2 | 2011 (13426.20184) | LTSC 2021 | 16.43 | 5 / 22 |
| PowerPointApi 1.4 | 2207 (15330.20122) | LTSC 2024 | 16.62 | 18 / 22 |
| PowerPointApi 1.5 | 2208 (15601.20230) | LTSC 2024 | 16.64 | 20 / 22 |
| PowerPointApi 1.8 | 2504 (18730.20030) | non disponible | 16.96 | 22 / 22 |

### Outlook

Le complément se charge à partir de **Mailbox 1.3**. Le niveau garanti est le plus bas entre celui du client Outlook et celui du serveur Exchange ; un outil de niveau supérieur peut fonctionner si le client Outlook le prend en charge. Avec Exchange on-premises, le manifeste EWS ne dépend pas de ce niveau pour les outils qu'il remplace (voir [Outlook et Exchange on-premises](#outlook-et-exchange-on-premises)).

| Client ou serveur | Mailbox maximum |
|---|---|
| Exchange Server 2016, 2019, Subscription Edition | 1.5 |
| Exchange Online | 1.16 |
| Outlook LTSC 2021 | 1.9 |
| Outlook LTSC 2024 | 1.14 |
| Outlook classique Microsoft 365 / retail | 1.8 dès la version 1910 (12130.20272), 1.12 en version 2302, 1.13 dès la version 2304 |
| Nouvel Outlook pour Windows (Exchange Online uniquement) | 1.16 |
| Outlook sur le web d'Exchange on-premises (interface classique) | 1.6 |
| Outlook pour Mac, nouvelle interface | 1.14 |
| Outlook pour Mac, interface classique | 1.8 |

| Jeu d'API | Outils |
|---|---|
| Mailbox 1.1 | 11 / 24 |
| Mailbox 1.2 | 12 / 24 |
| Mailbox 1.3 | 15 / 24 |
| Mailbox 1.6 | 16 / 24 |
| Mailbox 1.8 | 20 / 24 |
| EWS (manifeste EWS, Exchange on-premises) | 24 / 24 |

---

## Outils par version

Légende : **Oui** disponible ; **Non** indisponible ; **Inconnu** la documentation Microsoft ne permet pas de l'affirmer (l'outil dépend du client Outlook, ou Microsoft se contredit sur l'opération EWS employée), non encore constaté sur un poste (voir [Outlook et Exchange on-premises](#outlook-et-exchange-on-premises)). *Lecture* : l'outil consulte le document ; *Écriture* : il le modifie (ou prépare un brouillon dans Outlook).

### Word

| Outil | Rôle | Type | API min. | LTSC 2021 | LTSC 2024 | Microsoft 365 |
|---|---|---|---|:-:|:-:|:-:|
| `word_get_document_text` | Lire le texte du document | Lecture | 1.1 | Oui | Oui | Oui |
| `word_get_selection` | Lire la sélection | Lecture | 1.1 | Oui | Oui | Oui |
| `word_get_outline` | Lire le plan (titres et niveaux) | Lecture | 1.1 | Oui | Oui | Oui |
| `word_get_paragraphs` | Lire une plage de paragraphes | Lecture | 1.1 | Oui | Oui | Oui |
| `word_find` | Rechercher un texte (occurrences et position) | Lecture | 1.1 | Oui | Oui | Oui |
| `word_get_content_controls` | Lister les champs de formulaire | Lecture | 1.1 | Oui | Oui | Oui |
| `word_insert_text` | Insérer du texte brut | Écriture | 1.1 | Oui | Oui | Oui |
| `word_insert_content` | Insérer du contenu mis en forme (titres, listes, tableaux) | Écriture | 1.1 | Oui | Oui | Oui |
| `word_select_text` | Sélectionner un passage | Écriture | 1.1 | Oui | Oui | Oui |
| `word_replace_paragraphs` | Réécrire plusieurs paragraphes | Écriture | 1.1 | Oui | Oui | Oui |
| `word_apply_edits` | Appliquer des corrections ciblées | Écriture | 1.1 | Oui | Oui | Oui |
| `word_format_text` | Mettre en forme des caractères | Écriture | 1.1 | Oui | Oui | Oui |
| `word_format_paragraphs` | Mettre en forme des paragraphes (style, alignement, retraits) | Écriture | 1.1 | Oui | Oui | Oui |
| `word_insert_break` | Insérer un saut de page ou de section | Écriture | 1.1 | Oui | Oui | Oui |
| `word_set_header_footer` | Écrire l'en-tête ou le pied de page | Écriture | 1.1 | Oui | Oui | Oui |
| `word_fill_content_controls` | Remplir les champs d'un modèle | Écriture | 1.1 | Oui | Oui | Oui |
| `word_insert_content_control` | Créer un champ de formulaire | Écriture | 1.1 | Oui | Oui | Oui |
| `word_get_tables` | Lire les tableaux | Lecture | 1.3 | Oui | Oui | Oui |
| `word_get_document_info` | Lire les propriétés du document | Lecture | 1.3 | Oui | Oui | Oui |
| `word_delete_paragraphs` | Supprimer des paragraphes | Écriture | 1.3 | Oui | Oui | Oui |
| `word_insert_table` | Insérer un tableau mis en forme | Écriture | 1.3 | Oui | Oui | Oui |
| `word_update_table` | Modifier un tableau (cellules, lignes, colonnes, style) | Écriture | 1.3 | Oui | Oui | Oui |
| `word_set_document_properties` | Modifier les propriétés du document | Écriture | 1.3 | Oui | Oui | Oui |
| `word_insert_hyperlink` | Créer un lien hypertexte | Écriture | 1.3 | Oui | Oui | Oui |
| `word_get_comments` | Lire les commentaires | Lecture | 1.4 | Non | Oui | Oui |
| `word_add_comments` | Ajouter des commentaires | Écriture | 1.4 | Non | Oui | Oui |
| `word_manage_comments` | Répondre, résoudre, rouvrir, supprimer des commentaires | Écriture | 1.4 | Non | Oui | Oui |
| `word_set_track_changes` | Activer ou désactiver le suivi des modifications | Écriture | 1.4 | Non | Oui | Oui |
| `word_get_styles` | Lister les styles du document | Lecture | 1.5 | Non | Oui | Oui |
| `word_insert_note` | Insérer une note de bas de page ou de fin | Écriture | 1.5 | Non | Oui | Oui |
| `word_table_of_contents` | Insérer ou mettre à jour la table des matières | Écriture | 1.5 | Non | Oui | Oui |
| `word_get_tracked_changes` | Lire les modifications suivies | Lecture | 1.6 | Non | Oui | Oui |
| `word_review_tracked_changes` | Accepter ou refuser des modifications suivies | Écriture | 1.6 | Non | Oui | Oui |

Options liées à la version : style de caractère (1.3) ; champ texte brut et numéros de page dans l'en-tête ou le pied (1.5) ; cases à cocher des formulaires (1.7 : version 2311, LTSC 2024, Mac 16.79).

### Excel

| Outil | Rôle | Type | API min. | LTSC 2021 | LTSC 2024 | Microsoft 365 |
|---|---|---|---|:-:|:-:|:-:|
| `excel_get_workbook_overview` | Décrire le classeur (feuilles, tableaux, graphiques) | Lecture | 1.1 | Oui | Oui | Oui |
| `excel_get_selection` | Lire la sélection | Lecture | 1.1 | Oui | Oui | Oui |
| `excel_read_range` | Lire une plage | Lecture | 1.1 | Oui | Oui | Oui |
| `excel_find` | Rechercher une valeur | Lecture | 1.1 | Oui | Oui | Oui |
| `excel_calculate` | Calculer des formules sans modifier le classeur (analyse de gros volumes) | Lecture | 1.1 | Oui | Oui | Oui |
| `excel_read_table` | Lire un tableau structuré par pages | Lecture | 1.1 | Oui | Oui | Oui |
| `excel_get_charts` | Lister les graphiques d'une feuille | Lecture | 1.1 | Oui | Oui | Oui |
| `excel_write_range` | Écrire des valeurs | Écriture | 1.1 | Oui | Oui | Oui |
| `excel_set_formulas` | Écrire des formules cellule par cellule | Écriture | 1.1 | Oui | Oui | Oui |
| `excel_add_table_rows` | Ajouter des lignes à un tableau | Écriture | 1.1 | Oui | Oui | Oui |
| `excel_update_table` | Modifier un tableau (nom, style, totaux, tri) | Écriture | 1.1 | Oui | Oui | Oui |
| `excel_create_table` | Convertir une plage en tableau | Écriture | 1.1 | Oui | Oui | Oui |
| `excel_add_worksheet` | Ajouter ou copier une feuille | Écriture | 1.1 | Oui | Oui | Oui |
| `excel_update_worksheet` | Modifier une feuille (nom, couleur, volets, protection) | Écriture | 1.1 | Oui | Oui | Oui |
| `excel_delete_worksheet` | Supprimer une feuille | Écriture | 1.1 | Oui | Oui | Oui |
| `excel_select_range` | Sélectionner une plage | Écriture | 1.1 | Oui | Oui | Oui |
| `excel_clear_range` | Effacer une plage | Écriture | 1.1 | Oui | Oui | Oui |
| `excel_format_range` | Mettre en forme une plage | Écriture | 1.1 | Oui | Oui | Oui |
| `excel_add_chart` | Créer un graphique | Écriture | 1.1 | Oui | Oui | Oui |
| `excel_update_chart` | Modifier un graphique | Écriture | 1.1 | Oui | Oui | Oui |
| `excel_insert_cells` | Insérer des cellules | Écriture | 1.1 | Oui | Oui | Oui |
| `excel_delete_cells` | Supprimer des cellules, lignes ou colonnes | Écriture | 1.1 | Oui | Oui | Oui |
| `excel_fill_formula` | Recopier une formule sur une plage | Écriture | 1.2 | Oui | Oui | Oui |
| `excel_sort_range` | Trier une plage | Écriture | 1.2 | Oui | Oui | Oui |
| `excel_set_dimensions` | Largeur des colonnes, hauteur des lignes, ajustement | Écriture | 1.2 | Oui | Oui | Oui |
| `excel_merge_cells` | Fusionner ou défusionner des cellules | Écriture | 1.2 | Oui | Oui | Oui |
| `excel_filter_table` | Filtrer un tableau ou une plage | Écriture | 1.2 | Oui | Oui | Oui |
| `excel_hide_or_group` | Masquer ou grouper des lignes et colonnes | Écriture | 1.2 | Oui | Oui | Oui |
| `excel_add_table_column` | Ajouter une colonne (calculée) à un tableau | Écriture | 1.4 | Oui | Oui | Oui |
| `excel_add_named_range` | Définir une plage nommée | Écriture | 1.4 | Oui | Oui | Oui |
| `excel_add_conditional_format` | Ajouter une mise en forme conditionnelle | Écriture | 1.6 | Oui | Oui | Oui |
| `excel_set_hyperlink` | Créer un lien hypertexte | Écriture | 1.7 | Oui | Oui | Oui |
| `excel_add_data_validation` | Ajouter une validation de données (liste déroulante…) | Écriture | 1.8 | Oui | Oui | Oui |
| `excel_add_pivot_table` | Créer un tableau croisé dynamique | Écriture | 1.8 | Oui | Oui | Oui |
| `excel_remove_duplicates` | Supprimer les doublons | Écriture | 1.9 | Oui | Oui | Oui |
| `excel_find_replace` | Rechercher et remplacer | Écriture | 1.9 | Oui | Oui | Oui |
| `excel_get_comments` | Lire les commentaires | Lecture | 1.10 | Oui | Oui | Oui |
| `excel_add_comment` | Ajouter un commentaire | Écriture | 1.10 | Oui | Oui | Oui |

Options liées à la version : état « résolu » des commentaires (1.11) ; formules à débordement dans les calculs (1.12).

### PowerPoint

| Outil | Rôle | Type | API min. | LTSC 2021 | LTSC 2024 | Microsoft 365 |
|---|---|---|---|:-:|:-:|:-:|
| `powerpoint_get_selected_text` | Lire le texte sélectionné | Lecture | 1.1 | Oui | Oui | Oui |
| `powerpoint_get_selected_slides` | Lister les diapositives sélectionnées | Lecture | 1.1 | Oui | Oui | Oui |
| `powerpoint_insert_text` | Insérer ou remplacer du texte | Écriture | 1.1 | Oui | Oui | Oui |
| `powerpoint_go_to_slide` | Afficher une diapositive | Écriture | 1.1 | Oui | Oui | Oui |
| `powerpoint_delete_slides` | Supprimer des diapositives | Écriture | 1.2 | Oui | Oui | Oui |
| `powerpoint_get_outline` | Lire le plan de la présentation | Lecture | 1.4 | Non | Oui | Oui |
| `powerpoint_get_slide` | Lire une diapositive en détail (formes, positions, styles) | Lecture | 1.4 | Non | Oui | Oui |
| `powerpoint_add_slide` | Ajouter une diapositive (dispositions du modèle) | Écriture | 1.4 | Non | Oui | Oui |
| `powerpoint_insert_slides_from_outline` | Ajouter plusieurs diapositives depuis un plan | Écriture | 1.4 | Non | Oui | Oui |
| `powerpoint_update_texts` | Réécrire les textes de plusieurs formes (traduction, reformulation) | Écriture | 1.4 | Non | Oui | Oui |
| `powerpoint_replace_text` | Rechercher et remplacer dans toute la présentation | Écriture | 1.4 | Non | Oui | Oui |
| `powerpoint_add_text_box` | Ajouter une zone de texte | Écriture | 1.4 | Non | Oui | Oui |
| `powerpoint_add_shape` | Ajouter une forme, une flèche ou une ligne | Écriture | 1.4 | Non | Oui | Oui |
| `powerpoint_format_shape` | Mettre en forme une forme | Écriture | 1.4 | Non | Oui | Oui |
| `powerpoint_delete_shapes` | Supprimer des formes | Écriture | 1.4 | Non | Oui | Oui |
| `powerpoint_build_slide` | Composer une diapositive à partir d'une mise en page prédéfinie | Écriture | 1.4 | Non | Oui | Oui |
| `powerpoint_build_deck` | Composer plusieurs diapositives à partir de mises en page prédéfinies | Écriture | 1.4 | Non | Oui | Oui |
| `powerpoint_restyle_slide` | Remettre en forme une diapositive existante | Écriture | 1.4 | Non | Oui | Oui |
| `powerpoint_get_selected_shapes` | Lire les formes sélectionnées | Lecture | 1.5 | Non | Oui | Oui |
| `powerpoint_select` | Sélectionner des diapositives ou des formes | Écriture | 1.5 | Non | Oui | Oui |
| `powerpoint_arrange_slides` | Déplacer ou dupliquer une diapositive | Écriture | 1.8 | Non | Non | Oui |
| `powerpoint_add_table` | Insérer un tableau natif | Écriture | 1.8 | Non | Non | Oui |

Sans PowerPointApi 1.8, les nouvelles diapositives sont ajoutées en fin de présentation et l'ordre de superposition des formes n'est pas modifiable. Les notes d'orateur ne sont accessibles dans aucune version.

### Outlook

Colonnes : Outlook de bureau (Windows ou Mac) connecté à Exchange on-premises avec le manifeste standard, à Exchange on-premises avec le manifeste EWS, ou à Exchange Online (manifeste standard). « 1.8 ou EWS » : Office.js si le client expose le jeu, sinon EWS avec le manifeste EWS, sur un message ou un rendez-vous ouvert en lecture.

| Outil | Rôle | Type | API min. | On-premises, standard | On-premises, EWS | Exchange Online |
|---|---|---|---|:-:|:-:|:-:|
| `outlook_get_item` | Lire les informations du message (objet, expéditeur, destinataires, date, catégories) | Lecture | 1.1 | Oui | Oui | Oui |
| `outlook_get_appointment` | Lire une réunion ou un rendez-vous (périodicité, salles selon la version) | Lecture | 1.1 | Oui | Oui | Oui |
| `outlook_get_attachments` | Lister les pièces jointes | Lecture | 1.1 | Oui | Oui | Oui |
| `outlook_reply` | Ouvrir une réponse pré-remplie, avec des fichiers joints par leur adresse | Écriture | 1.1 | Oui | Oui | Oui |
| `outlook_reply_all` | Ouvrir une réponse à tous pré-remplie, avec des fichiers joints par leur adresse | Écriture | 1.1 | Oui | Oui | Oui |
| `outlook_new_appointment` | Ouvrir un rendez-vous pré-rempli | Écriture | 1.1 | Oui | Oui | Oui |
| `outlook_update_appointment` | Modifier le rendez-vous en cours (objet, lieu, horaires) | Écriture | 1.1 | Oui | Oui | Oui |
| `outlook_add_attachment_from_url` | Joindre un fichier depuis une adresse HTTPS de téléchargement direct | Écriture | 1.1 | Oui | Oui | Oui |
| `outlook_set_subject` | Modifier l'objet | Écriture | 1.1 | Oui | Oui | Oui |
| `outlook_insert_at_cursor` | Insérer du texte au curseur | Écriture | 1.1 | Oui | Oui | Oui |
| `outlook_set_recipients` | Ajouter, remplacer ou retirer des destinataires | Écriture | 1.1 | Oui | Oui | Oui |
| `outlook_get_selected_text` | Lire le texte sélectionné | Lecture | 1.2 | Oui | Oui | Oui |
| `outlook_get_body` | Lire le corps du message (historique compris) | Lecture | 1.3 | Oui | Oui | Oui |
| `outlook_get_draft` | Lire le brouillon en cours | Lecture | 1.3 | Oui | Oui | Oui |
| `outlook_set_body` | Réécrire le brouillon (historique et signature conservés) | Écriture | 1.3 | Oui | Oui | Oui |
| `outlook_new_message` | Ouvrir un nouveau message pré-rempli | Écriture | 1.6 ou EWS | Inconnu | Oui | Oui |
| `outlook_add_categories` | Ajouter des catégories | Écriture | 1.8 ou EWS | Inconnu | Oui | Oui |
| `outlook_remove_categories` | Retirer des catégories | Écriture | 1.8 ou EWS | Inconnu | Oui | Oui |
| `outlook_read_attachment` | Lire le contenu d'une pièce jointe (Word, Excel, PowerPoint, OpenDocument, texte, e-mail, invitation) | Lecture | 1.8 ou EWS | Inconnu | Oui | Oui |
| `outlook_get_headers` | Lire les en-têtes Internet pour juger de la provenance (SPF, DKIM, DMARC, relais) | Lecture | 1.8 ou EWS | Inconnu | Oui | Oui |
| `outlook_forward` | Préparer un transfert (brouillon ouvert, pièces jointes d'origine comprises) | Écriture | EWS | Non | Oui | Non |
| `outlook_get_availability` | Consulter les disponibilités des participants et proposer des créneaux communs | Lecture | EWS | Non | Inconnu | Non |
| `outlook_find_people` | Chercher une personne dans l'annuaire de l'organisation | Lecture | EWS | Non | Inconnu | Non |
| `outlook_get_conversation` | Lire toute la conversation (partie propre à chaque message) | Lecture | EWS | Non | Inconnu | Non |

Les outils affichés dépendent aussi du contexte : message reçu, brouillon, réunion reçue ou rendez-vous en cours de création. Le texte des pièces jointes est extrait sur le poste, puis transmis à l'assistant comme le reste de la conversation (voir [Données et sécurité](#donnes-et-scurit)). Les PDF et les images ne sont pas lus par le complément : les enregistrer dans le Drive Suite 366 pour en extraire le texte. Ces colonnes reflètent la documentation Microsoft ; le complément Outlook n'a pas encore été recetté sur un poste connecté à Exchange on-premises.

---

## Outlook et Exchange on-premises

Microsoft documente deux plafonds pour Outlook : celui du serveur Exchange et celui du client Outlook.

- **Serveur** : Exchange Server 2016, 2019 et Subscription Edition prennent en charge les jeux Mailbox 1.1 à 1.5. Le complément demande Mailbox 1.3 : il s'installe et se charge avec ces serveurs.
- **Client** : une fonction d'un jeu supérieur ne s'exécute que si le client Outlook prend en charge le jeu dont elle a besoin (*« an implemented feature only works if the Outlook client in which the add-in is installed supports the minimum requirement set needed by a feature »*), et la même page précise qu'un complément peut être limité au plus bas des deux plafonds. Le diagnostic du volet (*Réglages › Diagnostic*) affiche le jeu Mailbox réellement exposé.

La plateforme propose donc **deux manifestes Outlook**, à choisir par l'organisation (un seul à la fois) :

| Manifeste | Permission demandée | Pour | Ce qu'il apporte |
|---|---|---|---|
| Outlook (standard) | Lecture et écriture de l'élément ouvert | Exchange Online, et Exchange on-premises sans EWS | 15 outils garantis sur Exchange on-premises ; les outils des jeux 1.6 et 1.8 si le client les expose |
| Outlook (EWS) | Lecture et écriture de la boîte aux lettres | Exchange on-premises | Les mêmes outils par EWS quand le client n'expose pas 1.6 ou 1.8 (nouveau message, catégories, contenu des pièces jointes, en-têtes), et des outils qu'aucune version d'Office.js n'offre : transfert, disponibilités, annuaire, conversation entière |

**Manifeste EWS.** EWS (Exchange Web Services) est l'interface du serveur Exchange qu'Outlook met à disposition des compléments (`makeEwsRequestAsync`, Mailbox 1.1) :

- **Chemin des données** : la requête part d'Outlook vers le serveur Exchange de la boîte, avec les droits de l'utilisateur ; elle ne passe pas par la plateforme Suite 366. Seul le résultat lu par l'assistant lui est transmis, comme tout contenu lu par un outil.
- **Opérations employées** : création de brouillons (`CreateItem`, jamais d'envoi), lecture d'un élément (`GetItem`), mise à jour des catégories (`UpdateItem`, sans notification aux participants d'une réunion), disponibilités (`GetUserAvailability`, plages occupées sans objet ni lieu), annuaire (`ResolveNames`), conversation (`GetConversationItems`). Le complément n'envoie, ne déplace et ne supprime aucun élément.
- **Prérequis Exchange** : l'administrateur active l'authentification OAuth sur le répertoire virtuel EWS (*« The server administrator must use the New-WebServicesVirtualDirectory or the Set-WebServicesVirtualDirectory cmdlet to set the OAuthAuthentication parameter to true »*). Microsoft réserve l'installation d'un complément de ce niveau aux administrateurs (*« Outlook add-ins that request the read/write mailbox permission require explicit administrator privilege to install »*).
- **Limites** : les replis EWS ne s'appliquent qu'à un élément ouvert en lecture (un brouillon n'a pas encore d'identifiant côté serveur). La lecture d'une pièce jointe passe par le message complet, qu'Outlook plafonne à 5 Mo de réponse (1 Mo avant la version 2303 d'Outlook classique) : environ 2,7 Mo de pièces jointes par message, au-delà l'assistant propose le Drive.
- **À confirmer sur un poste** : Microsoft liste `GetUserAvailability` et `ResolveNames` parmi les opérations autorisées sur une page, mais pas sur celle des permissions ; il ne documente pas non plus que l'identifiant de conversation d'Office.js est celui qu'attend EWS. Les trois outils concernés sont notés **Inconnu**.
- **Exchange Online** : Microsoft a désactivé les jetons Exchange hérités dans tous les tenants Microsoft 365 ; le manifeste EWS est prévu pour Exchange on-premises.

| Outil | Jeu d'API | Manifeste standard, jeu non exposé | Manifeste EWS |
|---|---|---|---|
| `outlook_new_message` | 1.6 | L'assistant ouvre une réponse ou une réponse à tous pré-remplie, ou donne le texte à coller | Brouillon créé dans les Brouillons, puis ouvert |
| `outlook_add_categories`, `outlook_remove_categories` | 1.8 | Outils non proposés | Catégories mises à jour sur le serveur |
| `outlook_read_attachment` | 1.8 | Nom et taille des pièces jointes ; l'assistant propose de les enregistrer dans le Drive Suite 366 | Contenu lu dans le message complet |
| `outlook_get_headers` | 1.8 | Outil non proposé | En-têtes lus sur le serveur |

---

## Déploiement et mises à jour

Rien n'est installé sur les postes en dehors d'Office : chaque application reçoit un **manifeste** (fichier XML) qui contient l'adresse de la plateforme et la description du bouton du ruban, sans aucun secret. La plateforme génère les cinq manifestes (Word, Excel, PowerPoint, Outlook standard, Outlook EWS) dans *Paramètres › Compléments Office*.

| Écosystème | Word, Excel, PowerPoint | Outlook |
|---|---|---|
| Microsoft 365, boîtes Exchange Online | Applications intégrées du centre d'administration Microsoft 365 | Applications intégrées, manifeste standard |
| Hybride | Applications intégrées pour les utilisateurs dont la boîte est dans Exchange Online ; sinon, comme tout on-premises | Boîtes Exchange Online : Applications intégrées. Boîtes on-premises : centre d'administration Exchange, manifeste EWS ou standard |
| Tout on-premises | Catalogue SharePoint déclaré par stratégie de groupe (sans bouton dans le ruban), ou installation par l'utilisateur | Centre d'administration Exchange ou `New-App`, manifeste EWS ou standard |

Le volet se met à jour avec la plateforme, sans action sur les postes, sur le serveur Exchange ni dans les catalogues ; un manifeste n'est à réimporter que si sa version change. Procédures, prérequis et limites par écosystème : [Déployer les compléments Office](./deploiement.md).

---

## Données et sécurité

| Sujet | Fonctionnement |
|---|---|
| Destinataire des données | Le volet ne communique qu'avec la plateforme Suite 366 qui le sert. En dehors du chargement de la bibliothèque Office.js (ligne suivante), aucun autre service n'est appelé et aucune télémétrie n'est collectée. |
| Contenu transmis | Chaque message envoie à la plateforme l'historique de la conversation et le contenu lu par les outils (sélection, document, message). La plateforme le transmet au fournisseur de modèle configuré par l'organisation (modèle hébergé en interne ou service externe). |
| Bibliothèque Office.js | Chargée depuis `appsforoffice.microsoft.com` sans aucune donnée utilisateur, ou embarquée dans la plateforme pour supprimer ce flux. |
| Clé personnelle | Créée à la connexion depuis le volet (valable 180 jours) ou collée à la main, et révocable à tout moment dans *Paramètres › Clés API*. Ses droits sont limités à l'usage de l'assistant : modèles et agents de l'organisation, ou ceux choisis à la création d'une clé manuelle. Les agents agissent avec les droits de l'utilisateur. |
| Stockage sur le poste | La clé, les préférences et les conversations mémorisées sont conservées dans l'espace de stockage propre au complément, lié au profil de l'utilisateur sur le poste, **non chiffré** au repos. *Se déconnecter* efface la clé et les conversations mémorisées. Recommandations : révoquer la clé d'un poste réaffecté (*Paramètres › Clés API*) et utiliser des sessions Windows nominatives sur les postes partagés. |
| Modifications | Les outils d'écriture sont distincts des outils de lecture, et une confirmation peut être exigée avant chaque modification. Aucun message n'est envoyé automatiquement. |
| Boîte aux lettres (manifeste EWS) | Le complément agit avec les droits de l'utilisateur, par Outlook et le serveur Exchange, sans passer par la plateforme. Il crée des brouillons et met à jour des catégories ; il n'envoie, ne déplace et ne supprime aucun élément. Le manifeste standard n'accède qu'à l'élément ouvert. |

---

## Vérifier un poste

1. **Version d'Office** : *Fichier › Compte › À propos de Word* (version et build).
2. **WebView2** : présent dans *Paramètres Windows › Applications* (« Microsoft Edge WebView2 Runtime »).
3. **Dans le volet** : *Réglages › Diagnostic* affiche le moteur web (« WebView2 (Chromium) » attendu sur Windows) et les jeux d'API réellement exposés par Office. C'est la référence pour savoir quels outils sont disponibles. Pour Outlook avec Exchange on-premises et le manifeste standard, le jeu Mailbox affiché décide des 5 outils notés Inconnu : Mailbox 1.6 pour le nouveau message, 1.8 pour les catégories, le contenu des pièces jointes et les en-têtes. Avec le manifeste EWS, le diagnostic affiche aussi « EWS ».

---

## Sources

Correspondances établies à partir de la documentation Microsoft (consultée les 28 septembre et 28 octobre 2026) :

- [Word JavaScript API requirement sets](https://learn.microsoft.com/javascript/api/requirement-sets/word/word-api-requirement-sets)
- [Excel JavaScript API requirement sets](https://learn.microsoft.com/javascript/api/requirement-sets/excel/excel-api-requirement-sets)
- [PowerPoint JavaScript API requirement sets](https://learn.microsoft.com/javascript/api/requirement-sets/powerpoint/powerpoint-api-requirement-sets)
- [Outlook JavaScript API requirement sets](https://learn.microsoft.com/javascript/api/requirement-sets/outlook/outlook-api-requirement-sets)
- [Browsers and webview controls used by Office Add-ins](https://learn.microsoft.com/office/dev/add-ins/concepts/browsers-used-by-office-web-add-ins)
- [Deploy and publish Office Add-ins](https://learn.microsoft.com/office/dev/add-ins/publish/publish)
- [Requirements to use centralized deployment for Office Add-ins](https://learn.microsoft.com/microsoft-365/admin/manage/centralized-deployment-of-add-ins)
- [New-App (Exchange PowerShell)](https://learn.microsoft.com/powershell/module/exchangepowershell/new-app)
- [Use Exchange Web Services (EWS) from an Outlook add-in in Exchange on-premises](https://learn.microsoft.com/office/dev/add-ins/outlook/web-services)
- [Understanding Outlook add-in permissions](https://learn.microsoft.com/office/dev/add-ins/outlook/understanding-outlook-add-in-permissions)
- [Privacy and security for Office Add-ins](https://learn.microsoft.com/office/dev/add-ins/concepts/privacy-and-security)
- [Limits for activation and JavaScript API for Outlook add-ins](https://learn.microsoft.com/office/dev/add-ins/outlook/limits-for-activation-and-javascript-api-for-outlook-add-ins)
