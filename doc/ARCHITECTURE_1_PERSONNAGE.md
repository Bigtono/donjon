
# Architecture des personnages

## tronc commun

### Classes
* un personnage possède une classe s'il dispose au moins d'un niveau dans cette classe 
* Un personnage est considéré comme un lanceur de sort s'il possède au moins une classe de lanceur de sort

### Races


## DD3.5

## Classes

## Races

### gestiop des classes de prestige de lanceur de sort
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

##