<!-- Mis à jour : 2026-05-30 -->

# Architecture Fiche de sort DD3.5 / DD2024

# Objectif
Afficher le détail d'un sort, créer/modifier un sort

# Contenu de la fiche de sort par ruleset
Chaque ruleset présente les sorts de manière spécifique
Entre crochets : champ issu de la table dd_sorts
Entre accolades : champ composé construit depuis plusieurs tables et champs

## Fiche du ruleset DD3.5
[so_nom]
{Collège} [so_branche]
Niveau : {liste des classes} {Liste des domaines}
Composantes : {liste des composante de sorts -> champs so_vocal, so_gestuel, so_materiel} ([so_composante])
Temps d'incantation : [so_duree_incantation]
Portée : [so_portee]
Cible : [so_cible]
Zone d'effet : [so_zone_effet]
Durée : [so_duree_sort]
Jet de sauvegarde : [so_jet_sauvegarde]
Résistance à la magie : [so_resistance]
[so_description]
{source du document}
{nom de la campagne}
{ruleset}

## détail des champs composé pour le ruleset DD3.5
{Collège} : champ [co_nom] dans dd_colleges
{liste des classes} : issu de la table dd_sortclasse. Pour chaque entrée dans cette table pour ce sort, on affiche le nom de la classe ([cla_nom] dans dd_classes) suivi de [sc_niveau]
{liste des domaines} : issu de la table dd_sortdomaine. Pour chaque entrée dans cette table pour ce sort, on affiche le nom du domaine ([do_nom] dans dd_domaines) suivi de [sd_niveau]
{liste des composante de sorts -> champs so_vocal, so_gestuel, so_materiel} : si so_vocal=1, on affiche V, si so_gestuel=1, on affiche G, si so_materiel=1, on affiche M
{source du document} : champ res_nom dans dd_ressources. La ressource dont est tiré le sort doit toujours être affiché
{nom de la campagne} : champ camp_nom  dans dd_campagnes. Le champ n'apparaît que si so_camp_id n'est pas null — c'est un sort homebrew.
{ruleset} : champ var_valeur dans dd_variables


# Fiche du ruleset DD2024
[so_nom]
{college} de niveau [so_niveau] ({liste des classes})
Temps d'incantation : [so_duree_incantation]
Portée : [so_portee]
Composantes : {liste des composante de sorts -> champs so_vocal, so_gestuel, so_materiel} ([so_composante])
Durée : [so_duree_sort]
[so_description]
{source du document}
{nom de la campagne}
{ruleset}

# détail des champs composé pour le ruleset DD2024
{Collège} : champ [co_nom] dans dd_colleges
{liste des classes} : issu de la table dd_sortclasse. Pour chaque entrée dans cette table pour ce sort, on affiche le nom de la classe ([cla_nom] dans dd_classes)
{liste des composante de sorts -> champs so_vocal, so_gestuel, so_materiel} : si so_vocal=1, on affiche V, si so_gestuel=1, on affiche S, si so_materiel=1, on affiche M
{source du document} : champ res_nom dans dd_ressources
{nom de la campagne} : champ camp_nom  dans dd_campagnes
{ruleset} : champ var_valeur dans dd_variables


# Exemple (pour le ruleset DD3.5) 

Aspersion acide
Invocation (création) [acide]
Niveau : Ensorceleur/Magicien 0
Composantes : V, G
Temps d'incantation : 1 action simple
Portée : courte (7,50 m + 1,50 m/2 niveaux)
Effet : un projectile constitué d’acide
Durée : instantanée
Jet de sauvegarde : aucun
Résistance à la magie : non

Le personnage lance un petit orbe en direction de la cible. Il doit effectuer une attaque de contact à distance pour toucher celle-ci. L’orbe inflige alors 1d3 points de dégâts d’acide.

Source : Manuel du Joueur


# Gestion des formulaires de création/modification d'un sort
* certaines données sont incluses dans des blocs repliables (voir ARCHITECTURE_REFERENCE.md)

## champs communs
* la liste des ressources correspond à la liste des ressources sélectionnées (selon le contexte : joueur ou campagne), filtré par ruleset et présentée par ordre alphabétique.
* la liste des campagnes correspond aux campagnes de l'utilisateur
* le choix des composantes de sorts (champs so_vocal, so_gestuel, so_materiel) se fait via des cases à cocher
* le champ so_composante est géré par une zone de texte classique
* le champ so_description autorise une saisie enrichie avec un plugin du type ckeditor

## Ruleset DD3.5
* la liste des classes de lanceurs de sort est encapsulé dans un bloc repliable. Les classes sont affichées par ordre alphabétique, en commençant par les classes de base puis par les clases de prestige. La liste propose pour chaque classe de choisir un niveau dans une liste déroulante (0 à 9, 0 par défaut à la création).
* la liste des domaines est encapsulé dans un bloc repliable. Les domaines sont affichées par ordre alphabétique. La liste propose pour chaque domainee de choisir un niveau dans une liste déroulante (0 à 9, 0 par défaut à la création).
* le ruleset propose deux nouvelles composantes de sorts (so_focalisateur et so_focalisateur_divin) gérés comme so_vocal, so_gestuel et so_materiel
* le ruleset propose un champ supplémentaire so_resume (résumé du sort) qui n'est pas affiché avec le sort mais pourra être inclus ultérieurement dans la liste des sorts (sorts.php)

## Ruleset DD2024
* la liste des classes de lanceurs de sort est encapsulé dans un bloc repliable. Les classes sont affichées par ordre alphabétique, en commençant par les classes de base puis par les clases de prestige. La liste propose pour chaque classe de choisir un niveau dans une liste déroulante (0 à 20, 0 par défaut à la création).

# Enregistreement des données

## Enregistrement des associations
 * Lors de la sauvegarde d'un sort, il faut gérer simultanément trois tables : dd_sorts, dd_sortclasse (toutes les lignes existantes supprimées puis recréées pour les niveaux > 0) et dd_sortdomaine (idem) 