# Compléments Office Suite 366 : Word, Excel, PowerPoint, Outlook

Les compléments Office Suite 366 ajoutent un **volet assistant IA** dans Word, Excel, PowerPoint et Outlook. L'assistant lit et modifie le document ouvert (ou le message, ou le rendez-vous) au moyen d'**outils** adaptés à chaque application, en s'appuyant sur les agents et les modèles de votre plateforme Suite 366.

Les outils disponibles dépendent de la **version d'Office** installée sur le poste : cette page indique, pour chaque version, ce qui fonctionne.

> **Support** : pour toute question, contactez support-it@devana.ai

---

## Table des matières

- [Fonctionnement](#fonctionnement)
- [Compatibilité en bref](#compatibilité-en-bref)
- [Prérequis](#prérequis)
- [Versions d'Office et jeux d'API](#versions-doffice-et-jeux-dapi)
- [Outils par version](#outils-par-version)
- [Données et sécurité](#données-et-sécurité)
- [Vérifier un poste](#vérifier-un-poste)
- [Sources](#sources)

---

## Fonctionnement

- **Un volet par application** : un bouton **Assistant** dans le ruban ouvre le volet de conversation, à côté du document.
- **Connexion** : l'utilisateur saisit l'adresse de sa plateforme Suite 366 et une **clé personnelle** (`sk_user_…`), créée dans *Paramètres › Code* avec un agent ou un modèle sélectionné.
- **Outils** : l'assistant lit le document, puis agit par des outils précis (réécrire des paragraphes, créer un tableau croisé dynamique, composer une diapositive, préparer une réponse…). Une confirmation peut être exigée avant chaque modification.
- **Amélioration progressive** : au démarrage, le complément interroge Office sur les jeux d'API disponibles. Un outil non pris en charge par la version installée n'est pas proposé à l'assistant ; le reste fonctionne normalement.
- **Outlook** : le complément n'envoie jamais de message. Réponses, nouveaux messages et rendez-vous sont **ouverts pré-remplis** ; l'utilisateur relit et envoie.

---

## Compatibilité en bref

Nombre d'outils disponibles, par version d'Office sur Windows. La version et le build se lisent dans *Fichier › Compte › À propos de Word* (ex. « Version 2302 (build 16130.20332) »).

| Office | Word | Excel | PowerPoint | Outlook + Exchange on-premises | Outlook + Exchange Online |
|---|---|---|---|---|---|
| LTSC 2021 (version 2108) | 24 / 33 | 38 / 38 | 5 / 22 | 16 / 19 | 19 / 19 |
| Microsoft 365, version 2302 ¹ | 31 / 33 | 38 / 38 | 20 / 22 | 16 / 19 ² | 19 / 19 |
| LTSC 2024 (version 2408) | 33 / 33 | 38 / 38 | 20 / 22 | 16 / 19 | 19 / 19 |
| Microsoft 365, version 2504 ou ultérieure | 33 / 33 | 38 / 38 | 22 / 22 | 16 / 19 ² | 19 / 19 |
| Office pour Mac (version à jour) | 33 / 33 | 38 / 38 | 22 / 22 | 16 / 19 ² | 19 / 19 ³ |

1. À partir du build **16130.20332**. Un build 2302 antérieur limite Word à 28 / 33.
2. Exchange Server on-premises (2016, 2019, Subscription Edition) plafonne à Mailbox 1.5. Les 3 outils de niveau supérieur peuvent fonctionner si le client Outlook les prend en charge : à vérifier sur poste (voir [Vérifier un poste](#vérifier-un-poste)).
3. Nouvelle interface d'Outlook pour Mac (16.38.506 ou ultérieure).

**Non pris en charge** : Office 2016 et 2019 (fin de support Microsoft en octobre 2025). PowerPoint 2019 en licence en volume ne charge pas le complément. Office sur le web et Outlook mobile ne sont pas ciblés.

---

## Prérequis

### Poste de travail

| Élément | Exigence |
|---|---|
| Système | Windows 11, ou Windows 10 version 1903 ou ultérieure ; macOS pris en charge par Office 16 |
| Office | LTSC 2021, LTSC 2024 ou Microsoft 365 Apps sur Windows ; Office 16 sur Mac |
| Moteur web (Windows) | **Microsoft Edge WebView2 Runtime**, installé avec les versions d'Office prises en charge. S'il est absent, Office utilise un ancien moteur et le volet affiche un message « navigateur non pris en charge ». Déployable hors ligne (programme d'installation autonome ou version fixe). |
| Moteur web (Mac) | Safari (WKWebView), rien à installer |

### Réseau et serveur

| Élément | Exigence |
|---|---|
| Hébergement | Les compléments sont un site statique servi en **HTTPS** (certificat reconnu par les postes) |
| Flux depuis les postes | HTTPS vers le site des compléments et vers la plateforme Suite 366 ; `appsforoffice.microsoft.com`, ou bibliothèque Office.js hébergée en interne pour un réseau fermé |
| Plateforme Suite 366 | Origine du site des compléments autorisée (CORS) |
| Exchange (Outlook) | Exchange Server 2016, 2019 ou Subscription Edition, ou Exchange Online |

### Distribution

| Application | Mode de déploiement |
|---|---|
| Word, Excel, PowerPoint | Manifestes XML dans un **catalogue de confiance** (partage réseau déclaré par stratégie de groupe), ou déploiement intégré Microsoft 365 |
| Outlook | Complément ajouté par l'administrateur dans le **centre d'administration Exchange** (on-premises), ou déploiement intégré Microsoft 365 |

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

Le complément se charge à partir de **Mailbox 1.3**. Le niveau garanti est le plus bas entre celui du client Outlook et celui du serveur Exchange ; un outil de niveau supérieur peut fonctionner si le client Outlook le prend en charge.

| Client ou serveur | Mailbox maximum |
|---|---|
| Exchange Server 2016, 2019, Subscription Edition | 1.5 |
| Exchange Online | 1.16 |
| Outlook LTSC 2021 | 1.9 |
| Outlook LTSC 2024 | 1.14 |
| Outlook classique Microsoft 365 / retail | 1.8 dès la version 1910 (12130.20272), 1.12 en version 2302, 1.13 dès la version 2304 |
| Nouvel Outlook pour Windows | 1.16 |
| Outlook pour Mac, nouvelle interface | 1.14 |
| Outlook pour Mac, interface classique | 1.8 |

| Jeu d'API | Outils |
|---|---|
| Mailbox 1.1 | 12 / 19 |
| Mailbox 1.2 | 13 / 19 |
| Mailbox 1.3 | 16 / 19 |
| Mailbox 1.6 | 17 / 19 |
| Mailbox 1.8 | 19 / 19 |

---

## Outils par version

Légende : **Oui** disponible ; **Non** indisponible ; **À vérifier** non garanti, dépend du client Outlook. *Lecture* : l'outil consulte le document ; *Écriture* : il le modifie (ou prépare un brouillon dans Outlook).

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

Colonnes : Outlook de bureau (Windows ou Mac) connecté à Exchange on-premises ou à Exchange Online.

| Outil | Rôle | Type | API min. | Exchange on-premises | Exchange Online |
|---|---|---|---|:-:|:-:|
| `outlook_get_item` | Lire les informations du message (objet, expéditeur, destinataires, date) | Lecture | 1.1 | Oui | Oui |
| `outlook_get_entities` | Extraire adresses, numéros, liens et propositions de réunion | Lecture | 1.1 | Oui | Oui |
| `outlook_get_appointment` | Lire une réunion ou un rendez-vous | Lecture | 1.1 | Oui | Oui |
| `outlook_get_attachments` | Lister les pièces jointes | Lecture | 1.1 | Oui | Oui |
| `outlook_reply` | Ouvrir une réponse pré-remplie | Écriture | 1.1 | Oui | Oui |
| `outlook_reply_all` | Ouvrir une réponse à tous pré-remplie | Écriture | 1.1 | Oui | Oui |
| `outlook_new_appointment` | Ouvrir un rendez-vous pré-rempli | Écriture | 1.1 | Oui | Oui |
| `outlook_update_appointment` | Modifier le rendez-vous en cours (objet, lieu, horaires) | Écriture | 1.1 | Oui | Oui |
| `outlook_add_attachment_from_url` | Joindre un fichier depuis une adresse HTTPS (téléchargé par Outlook) | Écriture | 1.1 | Oui | Oui |
| `outlook_set_subject` | Modifier l'objet | Écriture | 1.1 | Oui | Oui |
| `outlook_insert_at_cursor` | Insérer du texte au curseur | Écriture | 1.1 | Oui | Oui |
| `outlook_set_recipients` | Ajouter, remplacer ou retirer des destinataires | Écriture | 1.1 | Oui | Oui |
| `outlook_get_selected_text` | Lire le texte sélectionné | Lecture | 1.2 | Oui | Oui |
| `outlook_get_body` | Lire le corps du message (historique compris) | Lecture | 1.3 | Oui | Oui |
| `outlook_get_draft` | Lire le brouillon en cours | Lecture | 1.3 | Oui | Oui |
| `outlook_set_body` | Réécrire le brouillon (historique et signature conservés) | Écriture | 1.3 | Oui | Oui |
| `outlook_new_message` | Ouvrir un nouveau message pré-rempli | Écriture | 1.6 | À vérifier | Oui |
| `outlook_add_categories` | Ajouter des catégories | Écriture | 1.8 | À vérifier | Oui |
| `outlook_read_attachment` | Lire le contenu d'une pièce jointe (Word, Excel, PowerPoint, OpenDocument, texte, e-mail, invitation) | Lecture | 1.8 | À vérifier | Oui |

Les outils affichés dépendent aussi du contexte : message reçu, brouillon, réunion reçue ou rendez-vous en cours de création. Le texte des pièces jointes est extrait sur le poste, puis transmis à l'assistant comme le reste de la conversation (voir [Données et sécurité](#données-et-sécurité)). Les PDF et les images ne sont pas lus par le complément : les enregistrer dans le Drive Suite 366 pour en extraire le texte.

---

## Données et sécurité

| Sujet | Fonctionnement |
|---|---|
| Destinataire des données | Le volet ne communique qu'avec la plateforme Suite 366 dont l'adresse est saisie par l'utilisateur. En dehors du chargement de la bibliothèque Office.js (ligne suivante), aucun autre service n'est appelé et aucune télémétrie n'est collectée. |
| Contenu transmis | Chaque message envoie à la plateforme l'historique de la conversation et le contenu lu par les outils (sélection, document, message). La plateforme le transmet au fournisseur de modèle configuré par l'organisation (modèle hébergé en interne ou service externe). |
| Bibliothèque Office.js | Chargée depuis `appsforoffice.microsoft.com` sans aucune donnée utilisateur, ou hébergée en interne pour supprimer ce flux. |
| Clé personnelle | Créée par l'utilisateur, avec une date d'expiration facultative, et révocable à tout moment. Ses droits sont limités à l'usage de l'assistant (modèles et agents choisis à sa création) ; les agents agissent avec les droits de l'utilisateur. |
| Stockage sur le poste | La clé, les préférences et les conversations mémorisées sont conservées dans l'espace de stockage propre au complément, lié au profil de l'utilisateur sur le poste, **non chiffré** au repos. *Se déconnecter* efface la clé et les conversations mémorisées. Recommandations : clés d'une durée limitée (90 jours par exemple) et sessions Windows nominatives sur les postes partagés. |
| Modifications | Les outils d'écriture sont distincts des outils de lecture, et une confirmation peut être exigée avant chaque modification. Aucun message n'est envoyé automatiquement. |

---

## Vérifier un poste

1. **Version d'Office** : *Fichier › Compte › À propos de Word* (version et build).
2. **WebView2** : présent dans *Paramètres Windows › Applications* (« Microsoft Edge WebView2 Runtime »).
3. **Dans le volet** : *Réglages › Diagnostic* affiche le moteur web (« WebView2 (Chromium) » attendu sur Windows) et les jeux d'API réellement exposés par Office. C'est la référence pour savoir quels outils sont disponibles, notamment pour Outlook avec Exchange on-premises.

---

## Sources

Correspondances établies à partir de la documentation Microsoft (consultée le 28 septembre 2026) :

- [Word JavaScript API requirement sets](https://learn.microsoft.com/javascript/api/requirement-sets/word/word-api-requirement-sets)
- [Excel JavaScript API requirement sets](https://learn.microsoft.com/javascript/api/requirement-sets/excel/excel-api-requirement-sets)
- [PowerPoint JavaScript API requirement sets](https://learn.microsoft.com/javascript/api/requirement-sets/powerpoint/powerpoint-api-requirement-sets)
- [Outlook JavaScript API requirement sets](https://learn.microsoft.com/javascript/api/requirement-sets/outlook/outlook-api-requirement-sets)
- [Browsers and webview controls used by Office Add-ins](https://learn.microsoft.com/office/dev/add-ins/concepts/browsers-used-by-office-web-add-ins)
