# Architecture Compétences DD3.5 / DD2024

# Objectif
Afficher le détail d'une compétence, créer/modifier une compétence


# Gestion de la liste
Structur identique à la liste des sorts
Le menu de filtrage propose
1. (inpout) Mots-clés
2. (select) Ressources


# Gestion de la fiche
Chaque ruleset présente les sorts de manière spécifique
Entre crochets : champ issu de la table dd_sorts
Entre accolades : champ composé construit depuis plusieurs tables et champs

## Fiche du ruleset DD3.5
[comp_nom] 
{caractéristique associée} {formation nécessaire ; malus d'armure aux tests}
[comp_description]
{source du document} : champ res_nom dans dd_ressources. La ressource dont est tiré le don doit toujours être affiché
{ruleset} : champ var_valeur dans dd_variables

## Fiche du ruleset DD2024
[comp_nom] {caractéristique associée}
[comp_description]
{source du document} : champ res_nom dans dd_ressources. La ressource dont est tiré le don doit toujours être affiché
{ruleset} : champ var_valeur dans dd_variables

## détail des champs composé pour tous les ruleset
{caractéristique associée} : champ [car_nom] dans dd_caracteristiques
{formation nécessaire ; malus d'armure aux tests} : mentions à ajouter selon la valeur (0/1) de [comp_formation]  et [comp_malusArmure] 
{source du document} : champ res_nom dans dd_ressources
{ruleset} : champ var_valeur dans dd_variables


# Gestion des formulaires de création/modification d'un sort

## champs communs
* Nom : [comp_nom]
* Caractéristique associée : [comp_car_id] -> champ Select reprenant les abréviations des caractéristiques (champ car_diminutif de dd_caracteristiques)
(champ spécifique DD3.5, voir ci-après)
* Description : [comp_description] -> TinyMCE
* Ressource : [do_res_id]

La liste des ressources correspond à la liste des ressources sélectionnées (selon le contexte : joueur ou campagne), filtré par ruleset et présentée par ordre alphabétique.
Le champ ruleset n'est pas affichée, la valeur do_ruleset_var_id est complétée automatiquement dans la requête SQL avec la variable ruleset en session

## Ruleset DD3.5
* formation nécessaire : champ oui/non
* Malus d'armure aux tests : champ oui/non

## Ruleset DD2024
aucune spécificité

# Enregistrement des données
Conforme aux règles fixées pour le compendium