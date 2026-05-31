<!-- Mis à jour : 2026-05-30 -->

# Règles métiers générales sur les classes

## Tronc commun

* Par défaut, une classe de de personnage est une classe de base (cla_clt_id=1). Certains ruleset introduisent d'autres types de classe de personnage (cla_clt_id>1).
* une classe est découpées en niveaux (selon le ruleset de 3 à 20).
* Une classe de base est considérée comme une classe de base de lanceur de sort si cla_mag_id >0. Si cla_mag_id=1, le lanceur de sort manipule la magie profane. Si clas_mag_id=2, le lanceur de sort manipule la magie divine. Si cla_mage_id > 0 alors les champs cla_connu, cla_compris et cla_prepare sont égaux à 0 ou 1 selon les règles spécifiques à la classe (voir Gestion de la magie)
* Une classe de base compte 20 niveaux (cla_niveauMax=20). Chaque classe possède un enregistrement par niveau dans la table dd_classe_niveau. 


## Ruleset dd3.5

* le ruleset introduit un nouveau type de classe, la classe de prestige (cla_clt_id=2). Une classe de prestige n'est pas une classe de personnage en tant que telle. Un personnage doit obligatoirement posséder des niveaux dans au moins une classe de base pour pouvoir posséder des niveaux dans au moins une classe de prestige.
* une classe de prestige compte 3, 5, 7 ou 10 niveaux (cla_niveauMax = 3 ou 5 ou 7 ou 10)
* chaque classe possède une liste de compétences privilégées appelée "liste des compétences de classe". 
* à chaque niveau, une classe accorde les bonus suivants :
  - bonus de base à l'attaque (bba)
  - bonus au jet de sauvegarde de réflexe 
  - bonus au jet de sauvegarde de vigueur
  - bonus au jet de sauvegarde de volonté
* les classes accordent aux personnages des apititudes spécifiques à certains niveaux obtenus dans la classe 
* à chaque niveau, une classe de lanceur de sort accorde au personnage un nouveau total de sort par jour et par niveau de sort
* à chaque niveau, certaines classes accordent des bonus spécifiques (exemple : pouvoir Ki du moine)

## Ruleset DD2024

* le ruleset introduit le concept de sous-classe. une sous-classe est rattachée à une classe. Un personnage doit choisir sa sous-classe quand il atteint le niveau 3 dans sa classe
* la sous-classe diffère de la classe de base ou même de la classe de prestige de DD3.5 dans le sens où elle n'accorde pas des bonus similaires à une classe de base comme le fait la classe de prestige. La sous-classe n'influe pas sur les valeurs chiffrés des niveaux de classe mais accorde de nouvelles aptitudes de classes selon les niveaux de classe
 

## Types de données d'une classe

Une classe est composées de plusieurs types de données qui feront l'objet de traitements spécifiques.

A - Les données de classes stockées dans dd_classes
  1. les données communes (nom, type de classe, abreviation, dé de vie etc...)
  2. les données communes spécifiques au ruleset
  3. les intitulés de pouvoirs spécifiques de la classe (champs cla_pouvoir1 à cla_pouvoir4). Une classe peut avoir de 0 à 4 pouvoirs spécifiques constituant autant de colonnes dans la table des bonus de classe. Si l'entête existe (champ non nul) alors la classe a le pouvoir indiqué et une colonne est affichée dans la table avec comme entête la valeur du champ cla_pouvoir correspondant. Si un champ cla_pouvoir est non nul, le champ cn_pouvoir correspondant dans dd_classe_niveau contient alors des données.

B - les données liées aux niveaux de classe stockées dans dd_classe_niveau. Ces données sont présentée dans le descriptif de la classe sur le site sous la forme d'un tableau appelé "table des bonus de classe" et contient autant d'enregistrement par classe que la valeur cla_niveauMax de la table dd_classes.
  1. les données communes (niveau, jet de sauvegarde, bonus de base à l'attaque etc...)
  2. les données liées aux pouvoirs spécifiques de la classe (champs cn_pouvoir1 à cn_pouvoir4).

C - selon la classe et le niveau, une ou plusieurs capacités spéciales. Chaque capacité spéciale est décrite dans la table dd_capacites_speciales. L'attribution d'une capacité à un niveau de classe spécifique est faite via la table dd_classe_capacite selon la relation entre l'id de la classe (cc_cla_id) et l'id de la capacité spéciale (cc_cap_id) pour un niveau donné (cc_niveau). Le champ cc_precision contient des indications complémentaires spécifique à l'attribution de la capacité spéciales à ce niveau précis (nombre d'utilisation de la capacité spéciales, restriction d'emploi etc...). Le contenu de cc_precision est alors affiché entre parenthèses immédiatement après le nom de la capacité spéciale dans la table


## Conception de la page

La page classe.php est constituée de plusieurs sections

La première section contient les données principales de la classe. Ces données de ce bloc sont issues de la table dd_classes


La deuxième section contient les données constitutives de la table des bonus de classe. Ce bloc est spécifique à chaque ruleset

Pour le ruleset dd3.5 :
- niveau (cn_niveau)
- Bonus de base à l'attaque (cn_bba)
- Bonus de base de réflexes (cn_reflexes)
- Bonus de base de vigueur (cn_vigueur)
- Bonus de base de volonté (cn_volonte)
- Pouvoir 1 (cn_pouvoir1)
- Pouvoir 2 (cn_pouvoir2)
- Pouvoir 3 (cn_pouvoir3)
- Pouvoir 4 (cn_pouvoir4)
- sorts de niveau 0 (cn_sort_n0)
- sorts de niveau 1 (cn_sort_n1)
- sorts de niveau 2 (cn_sort_n2)
- sorts de niveau 3 (cn_sort_n3)
- sorts de niveau 4 (cn_sort_n4)
- sorts de niveau 5 (cn_sort_n5)
- sorts de niveau 6 (cn_sort_n6)
- sorts de niveau 7 (cn_sort_n7)
- sorts de niveau 8 (cn_sort_n8)
- sorts de niveau 9 (cn_sort_n9)

Pour le ruleset dd2024 :
- niveau (cn_niveau)
- Bonus de maitrise (cn_bba)
- Pouvoir 1 (cn_pouvoir1)
- Pouvoir 2 (cn_pouvoir2)
- Pouvoir 3 (cn_pouvoir3)
- Pouvoir 4 (cn_pouvoir4)
 -sorts de niveau 0 (cn_sort_n0)
- sorts de niveau 1 (cn_sort_n1)
- sorts de niveau 2 (cn_sort_n2)
- sorts de niveau 3 (cn_sort_n3)
- sorts de niveau 4 (cn_sort_n4)
- sorts de niveau 5 (cn_sort_n5)
- sorts de niveau 6 (cn_sort_n6)
- sorts de niveau 7 (cn_sort_n7)
- sorts de niveau 8 (cn_sort_n8)
- sorts de niveau 9 (cn_sort_n9)

Un 2ème tableau contient les nombre sorts connus par niveau de classe pour chaque niveau de sort :
- niveau (cn_niveau)
- sorts connus de niveau 0 (cn_sortConnu_n0)
- sorts connus de niveau 1 (cn_sortConnu_n1)
- sorts connus de niveau 2 (cn_sortConnu_n2)
- sorts connus de niveau 3 (cn_sortConnu_n3)
- sorts connus de niveau 4 (cn_sortConnu_n4)
- sorts connus de niveau 5 (cn_sortConnu_n5)
- sorts connus de niveau 6 (cn_sortConnu_n6)
- sorts connus de niveau 7 (cn_sortConnu_n7)
- sorts connus de niveau 8 (cn_sortConnu_n8)
- sorts connus de niveau 9 (cn_sortConnu_n9)


La 3ème section contient les capacités spéciales

L'interface doit permettre d'afficher toutes les capacités spéciales de la classe dans un tableau similaire aux précédent (l ligne par niveau). Chaque capacité est affichée avec son nom (cap_nom) et entre parenthèses ses précisions (cc_precision). Le nom est cliquable [onclick="affecterCapacite(id)] et affiche dans detailPP les données relatives à la capacité spéciales.

Le div detail-PP présente un premier bloc contenant :
- le nom de la capacité (cap_nom)
- sa description complète (cap_description)
- son type (cap_type)
- sa catégorie (cap_categorie_var_id, issu de la table dd_variables, fonction libVar pour afficher la valeur).
Un bouton Modifier permet de basculer en modification et ouvre un popup dans le DIV modification. Le contenu est alors présenté comme un formulaire affichant :
- un input avec le nom de la capacité (cap_nom)
- un textarea contenant sa description complète (cap_description)
- un input avec son type (cap_type)
- un select avec les différents choix de catégorie (cap_categorie_var_id, issu de la table dd_variables, fonction optionListVar() pour afficher le select avec $ cat="tcap").
Deux boutons permettent de Valider les données ou d'Annuler les modifications. Si la modification est validé, le Div formulaire disparait et fait place à nouveau à l'affichage précédent (y compris le bouton Modifier)

Dans un deuxième bloc en dessous sont affichés toutes les affectations de la capacités par niveau avec à chaque fois le niveau (cc_niveau) et la précision (cc_precision). Un bouton permet de supprimer cette affectation, un autre permet d'en créer une nouvelle.

Deux boutons Valider et Annuler en dessous les deux blocs permettent respectivement d'enregistrer les modifications apportées à la capacités et à ses affectations ou d'annuler tous les changements. Dans les deux cas de figures, le div detailPP est fermé et le tableau des capacités spéciales de la classe est mis à jour (si besoin)

A droite du libelle "tableau des capacités spéciales" se trouve un bouton permettant de créer une nouvelle capacité spéciale. Le click ouvre alors detailPP directement en mode formulaire pour saisir les données de la nouvelle capacité. Le bloc Affecation n'est pas affiché, il l'est uniquement si la capacité est validée. 