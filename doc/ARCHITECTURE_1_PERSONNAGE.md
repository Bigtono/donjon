<!-- Mis à jour : 2026-05-30 -->


# ---------------------------------------------------------------------
# Architecture de la fiche de personnage
# ---------------------------------------------------------------------

Les informations sur le personnage sont ventilés dans plusieurs sous-pages.
1. fiche technique du personnage - personnage.php
2. background - personnage-background.php
3. possessions magiques - personnage-possessions.php
4. (si lanceur de sorts) grimoire - personnage-grimoire.php
5. notes (infos connues du personnages) - personnage-notes.php
6. notes du MJ - personnage-mj.php

Tous ces pages se partagent le même menu de navigation entre les différentes sous-pages
Les pages 1, 2, 4 et 6 ont leur propre bouton de mise à jour des données et leur propre système de formulaire /enregistrement
La mise à jour des données de la page 3 (possessions magiques) est gérée différement
La mise à jour des données de la page 5 (notes) est gérée différement

## Fiche de personnage
UN pesonnage est défini par  :
- un nom : [pe_nom]
- un joueur : [pe_j_id] -> table dd_joueurs
- une race de base : [pe_ra_id] -> table dd_races ( champ ra_rat_id : 1=base, 2=archétype)
- (DD3.5) un archetype : [pe_arc_id] -> table dd_races ( champ ra_rat_id : 2=archétype). Par défaut, le personnage n'en a pas
- un niveau global (voire règles METIERS)
- une ou plusieurs classes : liste horizontale reprenant les binomes Nom de la classe / Niveau dans la classe
- un bloc de caractérstiques : les 6 caractéristiques sont présentées sous la forme d'un tableau avec en entête les abréviations des caractéristiques et en 1ère et unique ligne les valeurs de caractéristiques et le modificateur associés entre parenthèses
- un bloc reprenant les compétences maitrisées par le personnage (selon les règles métiers de chaque ruleset) : les informations sont présentées en ligne par ordre alphabétique
- un bloc reprenant les dons  : les informations sont présentées en ligne par ordre alphabétique

Les race, archétype, classes, dons et compétences sont tous cliquables et ouvrent detail-pp contenant le descriptif associé.


## Background

Présentation du texte [pe_background]. Prévoir un système de pagination si le texte est trop long


## Possessions

Liste des objets magiques possédés par le personnage sus la forme d'un tableau reprenant :
- icone de suppression (avec confirmation)
- icone de modification
- nom de l'objet
- catégorie de l'objet


## Grimoire

Du fait de la complexité de cette page, son développement est reporté à une session ultérieure

## Notes

Liste des notes coonues par le personnage sus la forme d'un tableau reprenant :
- icone de suppression (avec confirmation)
- icone de modification
- nom de la note
- catégorie de la note



# ---------------------------------------------------------------------
# Architecture des formulaires de la fiche de personnage
# ---------------------------------------------------------------------

Toutes les modifications sont commités au moment de la validation du formulaire.

## Fiche de personnage

* nom : input [pe_nom]
* joueur : select [pe_j_id] -> table dd_joueurs (visible uniquement si l'utilisateur est un admin, sinon le champ est caché et sa valeur est la variable de session j_id)
* une race de base : select [pe_ra_id] -> table dd_races ( champ ra_rat_id : 1=base, 2=archétype)
* (DD3.5) un archetype : select [pe_arc_id] -> table dd_races ( champ ra_rat_id : 2=archétype).
* un niveau global : champ calculé

Gestion des classes
* le bloc Classes affiche toutes les classes du personnage, à raison d'une classe par ligne.
* à chaque ligne, on retrouve :
   - un bouton pour supprimer la classe (procédure classique avec écran de validation). 
   - nom de la classe 
   - niveau : un select permet de modifier le niveau de la classe

*  un bloc de caractérstiques : les 6 caractéristiques sont présentées sous la forme d'un tableau avec en entête les abréviations des caractéristiques et en 1ère et unique ligne des champps input  contenant les valeurs de caractéristiques

* un bloc reprenant les compétences maitrisées par le personnage (selon les règles métiers de chaque ruleset) : les informations sont présentées sous la forme d'un tableau à raison d'une ligne par compétence (toutes les compétences du ruleset sont représentées). La 1ère colonne contient le nom de la compétence, la 2ème colonne contient :
   - (DD3.5) un input avec la valeur numérique représentant le nombre de rangs dans la compétence
   - (DD2024) un case à cocher. Si la compétence est maitrisée, la case est coché 

- un bloc reprenant les dons  : les informations sont présentées en ligne par ordre alphabétique

### gestion des classes de prestige de lanceur de sort
La page personnage.php doit proposer une section contenant l'affectation des niveaux de classes de prestiges influant sur le NLS de classes de base de lanceur de sort. Les données sont stockées dans la table dd_personnages_nls
Cette section n'est affichée que si le personnage possède au moins une classe de base de lanceur de sort et au moins une classe de prestige influant sur les classes de base de lanceur de sort (classe de prestige dont au moins un des champs cn_niveauSortArcane, cn_niveauSortDivin ou cn_niveauSortEffectif est égal à 1).
La section est à positionner juste après le bloc de caractéristiques dans un div escamotable (avec le bouton Burger habituel. Bien réutiliser les fonctionalités toggle existantes)

Pour chaque classe de prestige influant sur des classes de base de lanceur de sort, il faut afficher un tableau contenant autant de lignes que de niveau dans la classe de prestige. Les champs du tableau sont  :
- le niveau à affecter (de 1 au niveau détenu par le personnage dans cette classe de prestige) 
- le nom de la classe de base de lanceur de sort affecté par cette classe prestige (champ penl_pc_id_base qui renvoie à pc_cla_id dans dd_personnages_classes qui renvoie à cla_nom dans dd_classes)
Si aucune correspondance n'existe dans dd_personnages_nls pour un niveau donné, il faut afficher en rouge à la place du nom de la classe la mention "A affecter"

La même section est à mettre en place dans personnage-modifier.php mais sous la forme d'un contenu de formulaire
- un tableau par classe de prestige influant sur le NLS de classes de base de lanceur de sort
- un select propose pour chaque niveau la liste des classes de base de lanceur de sort du personnage correspondant au type de magie affecté par la classe de prestige
   * si cn_niveauSortArcane = 1 : le select affiche toutes les classes de base de lanceur de sorts dont cla_mag_id = 1 
   * si cn_niveauSortDivin = 1 : le select affiche toutes les classes de base de lanceur de sorts dont cla_mag_id = 2 
   * si cn_niveauSortEffectif = 1 : le select affiche toutes les classes de base de lanceur de sorts indépendamment de la valeur de cla_mag_id
- Le joueur doit affecter chaque niveau à l'une ses classes de base de lanceur de sorts du personnage
Les données sont enregistrées dans le commit global de la page
La section est à positionner juste après le bloc de caractéristiques. Si plusieurs classes de prestiges sont à traiter, il faut aficher les tableaux dans des DIV escamotable avec chacun son bouton Burger.

## DD2024

### Race

### Historique

### Classe



# Formulaire de saisie





* un personnage peut posséder 
* l'interface propose la saisie d'un archetype sous la forme d'un champ SELECT