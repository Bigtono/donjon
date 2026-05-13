# Architecture dons DD3.5 / DD2024

# Objectif
Afficher le détail d'un don, créer/modifier un don


# Gestion de la liste
Structur identique à la liste des sorts
Le menu de filtrage propose
1. (inpout) Mots-clés
2. (select) Catégorie de don
3. (select) Ressources


# Gestion de la fiche
Chaque ruleset présente les sorts de manière spécifique
Entre crochets : champ issu de la table dd_sorts
Entre accolades : champ composé construit depuis plusieurs tables et champs

## Fiche du ruleset DD3.5
[do_nom]
{catégorie}
[do_texte]
{source du document} : champ res_nom dans dd_ressources. La ressource dont est tiré le don doit toujours être affiché
{nom de la campagne} : champ camp_nom  dans dd_campagnes. Le champ n'apparaît que si so_camp_id n'est pas null — c'est un don homebrew.
{ruleset} : champ var_valeur dans dd_variables

## Fiche du ruleset DD2024
[do_nom]
{catégorie} [do_conditions]
[do_texte]
{source du document} : champ res_nom dans dd_ressources. La ressource dont est tiré le don doit toujours être affiché
{nom de la campagne} : champ camp_nom  dans dd_campagnes. Le champ n'apparaît que si so_camp_id n'est pas null — c'est un don homebrew.
{ruleset} : champ var_valeur dans dd_variables

## détail des champs composé pour tous les ruleset
{catégorie} : champ [dado_nom] dans dd_data_don
{source du document} : champ res_nom dans dd_ressources
{nom de la campagne} : champ camp_nom  dans dd_campagnes
{ruleset} : champ var_valeur dans dd_variables


# Exemple (pour le ruleset DD2024) 

Empoigneur
Don général (prérequis : niveau 4 ou supérieur, Force ou Dextérité 13 ou plus)

Vous recevez les bénéfices suivants.
* Augmentation de caractéristique. Votre valeur de Force ou de Dextérité augmente de 1, jusqu’à un maximum de 20.
* Frappe et empoignade. Lorsque vous touchez une créature avec une attaque à mains nues dans le cadre de l’action Attaque à votre tour, vous pouvez recourir simultanément aux options Dégâts et Lutte. Vous ne pouvez recourir à ce bénéfice qu’une seule fois par tour.
* Attaque avec avantage. Vous avez l’Avantage aux jets d’attaque contre une créature à laquelle vous imposez l’état Agrippé.
* Lutteur rapide. Votre Vitesse n’est pas réduite de moitié lorsque vous déplacez une créature à laquelle vous imposez l’état Agrippé, à condition que cette créature soit de votre taille ou d’une catégorie inférieure.

Source : Manuel du Joueur 2024
[DD 2024]


# Gestion des formulaires de création/modification d'un sort

## champs communs
* Nom : [do_nom]
(champ spécifique DD2024, voir ci-après)
* Description : [do_texte] -> TinyMCE
* Résumé : [do_resume]
* Ressource : [do_res_id]
* Campagne : [do_camp_id]

La liste des ressources correspond à la liste des ressources sélectionnées (selon le contexte : joueur ou campagne), filtré par ruleset et présentée par ordre alphabétique.
La liste des campagnes correspond aux campagnes de l'utilisateur
Le champ ruleset n'est pas affichée, la valeur do_ruleset_var_id est complétée automatiquement dans la requête SQL avec la variable ruleset en session

## Ruleset DD3.5
aucune spécificité

## Ruleset DD2024
le ruleset gère un champ spécifique 
* Prérequis: [do_conditions]
Ce champ est inséré entre le nom et la description

# Enregistrement des données
Conforme aux règles fixées pour le compendium