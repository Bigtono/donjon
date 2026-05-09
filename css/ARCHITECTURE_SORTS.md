# Architecture Fiche de sort DD3.5 / DD2024

## Objectif
Afficher le détail d'un sort

## Contenu de la fiche de sort par ruleset
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

#détail des champs composé pour le ruleset DD3.5
{Collège} : champ [co_nom] dans dd_colleges
{liste des classes} : issu de la table dd_sortclasse. Pour chaque entrée dans cette table pour ce sort, on affiche le nom de la classe ([cla_nom] dans dd_classes) suivi de [sc_niveau]
{liste des domaines} : issu de la table dd_sortdomaine. Pour chaque entrée dans cette table pour ce sort, on affiche le nom du domaine ([do_nom] dans dd_domaines) suivi de [sd_niveau]
{liste des composante de sorts -> champs so_vocal, so_gestuel, so_materiel} : si so_vocal=1, on affiche V, si so_gestuel=1, on affiche G, si so_materiel=1, on affiche M
{source du document} : champ res_nom dans dd_ressources
{nom de la campagne} : champ camp_nom  dans dd_campagnes
{ruleset} : champ var_valeur dans dd_variables


## Fiche du ruleset DD2024
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

#détail des champs composé pour le ruleset DD2024
{Collège} : champ [co_nom] dans dd_colleges
{liste des classes} : issu de la table dd_sortclasse. Pour chaque entrée dans cette table pour ce sort, on affiche le nom de la classe ([cla_nom] dans dd_classes)
{liste des composante de sorts -> champs so_vocal, so_gestuel, so_materiel} : si so_vocal=1, on affiche V, si so_gestuel=1, on affiche S, si so_materiel=1, on affiche M
{source du document} : champ res_nom dans dd_ressources
{nom de la campagne} : champ camp_nom  dans dd_campagnes
{ruleset} : champ var_valeur dans dd_variables


Exemple pour le ruleset DD3.5 : 
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


## Gestion des formulaires de saisie 

# Ruleset DD3.5
Un bloc repliable contient la liste des classes de lanceurs de sorts