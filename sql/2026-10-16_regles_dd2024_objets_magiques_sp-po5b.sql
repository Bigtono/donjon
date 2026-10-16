-- sql/2026-10-16_regles_dd2024_objets_magiques_sp-po5b.sql
-- SP-PO5b — SRD 5.2.1 : règles « Objets magiques » (pages 215 à 220 du Document de Référence du Système)
--
-- Source : FR_SRD_CC_v5.2.1-regles_objets_magiques.pdf. Texte du SRD repris tel quel (hors coquilles d'extraction) ;
-- les tableaux vont dans dd_tableaux, appelés par [[tab:slug]] ; la liste alphabétique des objets est un tag
-- [[liste:objet|…]] (SP-PO1), toujours à jour avec le compendium.
--
-- Pages créées sous le chapitre « Objets magiques » (slug objets-magiques) : règles concernant les objets magiques,
-- rareté et valeur, activation, objets maudits, résilience, fabrication, objets intelligents, liste de A à Z.
-- La page « Catégories d'objets magiques » (slug historique categories_objets-magiques) existait avec une seule
-- phrase : elle reçoit le texte complet. « Utiliser les objets magiques » (SP-PO5, issue de la section Équipement)
-- n'est pas touchée.
--
-- Rejouable : tableaux en INSERT … ON DUPLICATE KEY UPDATE ; pages créées si absentes (NOT EXISTS) puis mises à jour
-- par slug. Aucun reg_id codé en dur. Pas de DELIMITER.

SET NAMES utf8mb4;

SET @rs   := (SELECT var_id FROM dd_variables WHERE var_cat = 'ruleset' AND var_valeur = 'DD2024' LIMIT 1);
SET @res  := (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'SRD 5.2.1' AND res_ruleset_var_id = @rs AND res_j_id IS NULL LIMIT 1);
SET @now  := NOW();
SET @r_objets_magiques := (SELECT reg_id FROM dd_regles WHERE reg_slug = 'objets-magiques' AND reg_ruleset_var_id = @rs LIMIT 1);

START TRANSACTION;

-- Tableaux (9)
INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note,
                         tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible,
                         tab_date_creation, tab_date_modif)
VALUES
('categories-d-objets-magiques', 'Catégories d’objets magiques',
'! Catégorie | Exemples
Anneaux | Anneau d’invisibilité
Armes | Épée longue +1, projectiles +1
Armures | Armure de cuir +1, bouclier +1
Baguettes | Baguette de boules de feu
Bâtons | Bâton percussif
Objets merveilleux | Bottes elfiques, sac sans fond
Parchemins | Parchemin de sort
Potions | Potion de guérison
Sceptres | Sceptre inamovible',
'll', NULL, @rs, @res, NULL, 0, 0, 1, @now, @now),
('miscibilite-des-potions', 'Miscibilité des potions',
'! 1d100 | Résultat
01 | Les deux potions perdent leurs effets, et le mélange crée une explosion magique dans une Sphère de 1,50 m de rayon centrée sur lui-même. Chaque créature prise dans la zone subit 4d10 dégâts de force.
02–08 | Les deux potions perdent leurs effets et le mélange devient le poison par ingestion de votre choix (cf. « Poisons » de « Boîte à outils ludique »).
09–15 | Les deux potions perdent leurs effets.
16–25 | Une potion perd son effet.
26–35 | Les deux potions agissent, mais leurs effets numériques et leur durée sont réduits de moitié. Si une potion n’a ni effet numérique ni durée, elle perd son effet.
36–90 | Les deux potions agissent normalement.
91–99 | Les deux potions agissent, et les effets numériques ainsi que la durée de l’une d’entre elles sont doublés. Si aucune des deux potions n’a de variable à doubler de cette manière, elles agissent toutes deux normalement.
00 | Une seule potion agit, mais ses effets sont permanents. Choisissez l’effet le plus simple à rendre permanent ou celui qui vous paraît le plus amusant. Une potion de guérison, par exemple, augmente le maximum de points de vie du buveur de 2d4 + 2, tandis qu’une potion d’invisibilité octroie au buveur l’état Invisible indéfiniment. À votre discrétion, le sort dissipation de la magie ou toute autre magie comparable peut dissiper l’effet persistant.',
'cl', NULL, @rs, @res, NULL, 0, 0, 1, @now, @now),
('rarete-et-valeur-des-objets-magiques', 'Rareté et valeur des objets magiques',
'! Rareté | Valeur*
Courante | 100 po
Peu courante | 400 po
Rare | 4 000 po
Très rare | 40 000 po
Légendaire | 200 000 po
Artefact | Inestimable',
'lr', '*Réduire de moitié la valeur de tout objet à utilisation unique autre qu’un parchemin de sort. La valeur d’un parchemin de sort est égale au double du coût de fabrication du parchemin (tel qu’indiqué à « Écrire des parchemins de sort » dans « Équipement »).', @rs, @res, NULL, 0, 0, 1, @now, @now),
('outils-par-objet-magique', 'Outils par objet magique',
'! Catégorie d’objet | Outil nécessaire
Anneaux | Outils de joaillier
Armes | Outils de forgeron, outils de menuisier ou outils de tanneur selon le type d’arme, comme indiqué dans la description des outils
Armures | Outils de forgeron, outils de tanneur ou outils de tisserand selon le type d’armure, comme indiqué dans la description des outils
Baguettes | Outils de menuisier
Bâtons | Outils de menuisier
Objets merveilleux | Outils de bricoleur ou l’outil nécessaire pour fabriquer l’objet non magique sur lequel se fonde l’objet magique
Parchemins | Matériel de calligraphe
Potions | Matériel d’alchimiste ou matériel d’herboriste
Sceptres | Outils de menuisier',
'll', NULL, @rs, @res, NULL, 0, 0, 1, @now, @now),
('cout-et-temps-de-fabrication-d-un-objet-magique', 'Coût et temps de fabrication d’un objet magique',
'! Rareté de l’objet | Temps* | Coût*
Courant | 5 jours | 50 po
Peu courant | 10 jours | 200 po
Rare | 50 jours | 2 000 po
Très rare | 125 jours | 20 000 po
Légendaire | 250 jours | 100 000 po',
'lrr', '*Temps et coût sont réduits de moitié pour un objet à utilisation unique autre qu’un parchemin de sort, dont le temps et le coût de fabrication figurent en section « Équipement ».', @rs, @res, NULL, 0, 0, 1, @now, @now),
('alignement-d-objet-intelligent', 'Alignement d’objet intelligent',
'! 1d100 | Alignement
01–15 | Loyal Bon
16–35 | Neutre Bon
36–50 | Chaotique Bon
51–63 | Loyal Neutre
64–73 | Neutre
74–85 | Chaotique Neutre
86–89 | Loyal Mauvais
90–96 | Neutre Mauvais
97–00 | Chaotique Mauvais',
'cl', NULL, @rs, @res, NULL, 0, 0, 1, @now, @now),
('modes-de-communication-d-objet-intelligent', 'Modes de communication d’objet intelligent',
'! 1d10 | Mode de communication
1–6 | L’objet communique en transmettant ses émotions à la créature qui le porte ou le manie.
7–9 | L’objet parle une ou plusieurs langues.
10 | L’objet parle une ou plusieurs langues. Il peut en outre communiquer par télépathie avec la créature qui le porte ou le manie.',
'cl', NULL, @rs, @res, NULL, 0, 0, 1, @now, @now),
('sens-d-objet-intelligent', 'Sens d’objet intelligent',
'! 1d4 | Sens
1 | Ouïe et vision normales sur 9 m
2 | Ouïe et vision normales sur 18 m
3 | Ouïe et vision normales sur 36 m
4 | Ouïe et Vision dans le noir sur 36 m',
'cl', NULL, @rs, @res, NULL, 0, 0, 1, @now, @now),
('grand-dessein-d-objet-intelligent', 'Grand dessein d’objet intelligent',
'! 1d10 | Grand dessein
1 | Aligné. L’objet est voué à la défaite ou à la destruction des entités d’un alignement diamétralement opposé au sien. Un tel objet n’est jamais Neutre.
2 | Fléau. L’objet cherche à contrecarrer ou à détruire les créatures d’un type particulier, comme les Artificiels, les Fiélons ou les Morts-vivants.
3 | En quête de son créateur. L’objet cherche la trace de son créateur pour comprendre dans quel but il a été créé.
4 | En quête de son destin. L’objet est convaincu que lui-même et son porteur ont un rôle clé à jouer dans des événements à venir.
5 | Destructeur. L’objet aspire à la destruction et pousse son utilisateur à combattre tous azimuts.
6 | En quête de gloire. L’objet cherche à se faire connaître comme le plus grand objet magique du monde, et incite à cette fin son porteur à devenir une personnalité de premier plan.
7 | En quête de savoir. L’objet, avide de savoir, compte ardemment résoudre un mystère, exhumer un secret ou décrypter une prophétie obscure.
8 | Protecteur. L’objet cherche à défendre un type particulier de créature, comme les elfes ou les loups-garous.
9 | En quête de l’âme sœur. L’objet est à la recherche d’un autre objet magique intelligent, peut-être semblable à lui-même.
10 | Templier. L’objet cherche à défendre les serviteurs ou les intérêts d’une divinité donnée.',
'cl', NULL, @rs, @res, NULL, 0, 0, 1, @now, @now)
ON DUPLICATE KEY UPDATE tab_nom = VALUES(tab_nom), tab_contenu = VALUES(tab_contenu), tab_align = VALUES(tab_align),
                        tab_note = VALUES(tab_note), tab_res_id = VALUES(tab_res_id), tab_date_modif = VALUES(tab_date_modif);

-- Pages

-- Catégories d’objets magiques
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
SELECT @r_objets_magiques, 'regle', 'Catégories d’objets magiques', 'categories_objets-magiques', '', 0, @rs, @res, NULL, 1, @now, @now
  FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM dd_regles WHERE reg_slug = 'categories_objets-magiques' AND reg_ruleset_var_id = @rs);
UPDATE dd_regles
   SET reg_reg_id = @r_objets_magiques, reg_type = 'regle', reg_nom = 'Catégories d’objets magiques', reg_texte = '<p>Chaque objet magique appartient à une catégorie. La table « Catégories d’objets magiques » dresse la liste des neuf catégories et fournit des exemples. Les règles relatives aux catégories figurent après cette table.</p>
<p>[[tab:categories-d-objets-magiques]]</p>
<h3>Anneaux</h3>
<p>Pour que sa magie opère et sauf mention contraire dans sa description, un objet de la catégorie Anneaux doit être porté à un doigt ou à un appendice comparable.</p>
<h3>Armes</h3>
<p>Une arme magique est le plus souvent une version magique d’une arme qui figure dans « Équipement ». La description de certaines armes magiques précise quel type d’arme elles concernent, par exemple épée longue ou arc long. Si aucun type d’arme n’est spécifié, choisissez-le ou laissez le hasard en décider.</p>
<p><strong>Projectiles.</strong> Si une arme magique présente la propriété Munitions, les projectiles qu’elle tire sont considérés comme magiques au regard des règles concernant la nature magique des armes.</p>
<h3>Armures</h3>
<p>Un objet de la catégorie Armures est généralement la version magique d’une armure de la section « Équipement ». Sauf mention contraire dans sa description, l’armure doit être portée pour que sa magie opère.</p>
<p>Certaines armures magiques spécifient quel type d’armure elles concernent, par exemple cotte de mailles ou harnois. Si aucun type n’est spécifié, choisissez son type ou laissez le hasard en décider.</p>
<h3>Baguettes</h3>
<p>Un objet de la catégorie Baguettes mesure en général 30 à 40 cm et il est fait de métal, d’os ou de bois. Sa pointe est en métal, en cristal, en pierre ou dans un autre matériau.</p>
<p>Sauf mention contraire dans sa description, une baguette peut faire office de focaliseur arcanique.</p>
<h3>Bâtons</h3>
<p>Les objets de la catégorie Bâtons sont d’apparence très variable : certains sont droits, avec un diamètre presque identique sur toute leur longueur, d’autres sont tordus et noueux ; certains sont en bois, d’autres en matériaux composites, en métal poli ou en cristal. Un bâton pèse entre 1 et 3,5 kg et peut faire office de bâton de marche ou de canne.</p>
<p>Sauf mention contraire dans sa description, un bâton peut servir de bâton de combat non magique et de focaliseur arcanique.</p>
<h3>Objets merveilleux</h3>
<p>Les objets merveilleux comprennent les objets portables tels que les bottes, ceintures, capes, amulettes, broches et diadèmes. Sacs, tapis, figurines, cors, instruments de musique et bien d’autres entrent aussi dans cette vaste catégorie.</p>
<h3>Parchemins</h3>
<p>Un objet de la catégorie Parchemins est un rouleau de papier ou de vélin, parfois muni de tiges en bois sur deux côtés opposés et généralement conservé dans un étui en ivoire, jade, cuir, métal ou bois. Le parchemin le plus courant est le parchemin de sort, à savoir un sort archivé sous forme écrite.</p>
<p><strong>Utiliser un parchemin.</strong> Les parchemins sont des objets à utilisation unique. Pour libérer la magie du parchemin, l’utilisateur doit en lire le contenu. Une fois sa magie invoquée, le parchemin devient inutilisable. Les mots s’estompent ou l’objet tombe en poussière.</p>
<p>Toute créature apte à comprendre une langue écrite peut lire un parchemin et tenter de l’activer, sauf mention contraire dans sa description.</p>
<h3>Potions</h3>
<p>Un objet de la catégorie Potions est soit un breuvage magique qui doit être bu, soit une huile qu’il faut appliquer sur une créature ou un objet. La potion typique consiste en 30 ml de liquide contenu dans une fiole.</p>
<p><strong>Utiliser une potion.</strong> Les potions sont des objets à utilisation unique. Boire une potion ou l’administrer à une autre créature nécessite une action Bonus. L’application d’une huile peut prendre plus de temps, comme indiqué dans sa description. Une fois utilisée, une potion est consommée et prend effet immédiatement.</p>
<p><strong>Mélanger les potions.</strong> Un personnage peut boire une potion alors qu’il est encore sous l’effet d’une autre ou verser plusieurs potions dans un même récipient. Les ingrédients étranges utilisés dans l’élaboration des potions peuvent donner lieu à des interactions imprévisibles.</p>
<p>Lorsqu’un personnage mélange deux potions, effectuez un jet selon la table « Miscibilité des potions ». Si plus de deux potions sont combinées de la sorte, relancez le dé pour chaque potion suivante, en combinant les résultats. Si les effets ne sont pas évidents d’emblée, ne les révélez que lorsqu’ils se manifestent.</p>
<p>[[tab:miscibilite-des-potions]]</p>
<h3>Sceptres</h3>
<p>Un objet de la catégorie Sceptres est le plus souvent fait de métal, de bois ou d’os. Le sceptre moyen pèse entre 1 et 2,5 kg.</p>
<p>Sauf mention contraire dans sa description, un sceptre peut être utilisé comme focaliseur arcanique.</p>',
       reg_ordre = 0, reg_res_id = @res, reg_visible = 1, reg_date_modif = @now
 WHERE reg_slug = 'categories_objets-magiques' AND reg_ruleset_var_id = @rs;

-- Règles concernant les objets magiques
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
SELECT @r_objets_magiques, 'regle', 'Règles concernant les objets magiques', 'regles-concernant-les-objets-magiques', '', 20, @rs, @res, NULL, 1, @now, @now
  FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM dd_regles WHERE reg_slug = 'regles-concernant-les-objets-magiques' AND reg_ruleset_var_id = @rs);
UPDATE dd_regles
   SET reg_reg_id = @r_objets_magiques, reg_type = 'regle', reg_nom = 'Règles concernant les objets magiques', reg_texte = '<p>Les règles concernant l’identification et l’utilisation des objets magiques, ainsi que leur Harmonisation, figurent à la section « Équipement ». Des règles supplémentaires sont présentées ci-dessous.</p>
<p><strong>Prérequis à l’Harmonisation.</strong> Si un objet magique présente un prérequis de classe, une créature doit appartenir à cette classe pour s’harmoniser avec cet objet. Si le prérequis est d’être un incantateur, toute créature remplit la condition si elle peut lancer au moins un sort en recourant à ses traits ou aptitudes sans utiliser d’objet magique ou d’artifice comparable.</p>
<p><strong>Objets conçus pour des créatures spécifiques.</strong> Dans bien des cas, les objets magiques destinés à être portés s’adaptent magiquement au porteur. Vous pouvez toutefois statuer qu’un objet magique donné n’ajuste pas sa taille à tous les porteurs. Tel armurier, par exemple, n’aura façonné que des objets adaptés au gabarit des nains.</p>
<p><strong>Anatomie inhabituelle.</strong> Il vous appartient de décider si une créature peut porter un objet qui n’est pas adapté à son anatomie. Un anneau placé sur un tentacule peut fonctionner, mais un yuan-ti avec une queue de serpent en guise de jambes ne pourra pas porter de bottes magiques.</p>
<p><strong>Objets appariés.</strong> Vous pouvez autoriser des exceptions à la règle selon laquelle les objets appariés doivent être portés tous les deux. Un personnage qui n’a qu’un bras, par exemple, pourra utiliser un seul gant piégeur de projectiles tant que le gant apparié se trouve dans ses affaires.</p>',
       reg_ordre = 20, reg_res_id = @res, reg_visible = 1, reg_date_modif = @now
 WHERE reg_slug = 'regles-concernant-les-objets-magiques' AND reg_ruleset_var_id = @rs;

-- Rareté et valeur des objets magiques
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
SELECT @r_objets_magiques, 'regle', 'Rareté et valeur des objets magiques', 'rarete-et-valeur-des-objets-magiques', '', 30, @rs, @res, NULL, 1, @now, @now
  FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM dd_regles WHERE reg_slug = 'rarete-et-valeur-des-objets-magiques' AND reg_ruleset_var_id = @rs);
UPDATE dd_regles
   SET reg_reg_id = @r_objets_magiques, reg_type = 'regle', reg_nom = 'Rareté et valeur des objets magiques', reg_texte = '<h3>Rareté d’un objet magique</h3>
<p>Tout objet magique présente une rareté, mesure approximative du pouvoir de l’objet par rapport à d’autres objets magiques. Les raretés figurent dans la table « Rareté et valeur d’un objet magique ».</p>
<p>Les objets magiques courants, comme la potion de guérison, sont les plus abondants. Les Artefacts, tel qu’un Orbe draconique, sont des objets inestimables, uniques et très difficiles à se procurer.</p>
<h3>Rareté et valeur des objets magiques</h3>
<p>Les objets magiques courants sont souvent disponibles à l’achat dans une bourgade ou une ville. Les objets magiques peu courants et rares ne se procurent généralement que dans une cité, et ceux de rareté supérieure ne se vendent que dans des lieux merveilleux, tels certaines cités d’autres plans d’existence. Si vous autorisez les personnages à vendre et acheter des objets magiques dans votre campagne, la rareté vous aidera à déterminer leur prix. Des valeurs en pièces d’or sont fournies dans la table « Rareté et valeur des objets magiques », mais certains vendeurs exigent un service plutôt que de l’or en guise de paiement.</p>
<p>Quand un objet magique comprend un objet qui affiche un prix de vente dans « Équipement » (par exemple une arme ou une armure), ajoutez le prix de l’objet à la valeur de l’objet magique. La valeur d’une armure +1 (harnois), par exemple, sera de 5 500 po, somme de la valeur d’un objet magique rare (4 000 po) et d’un harnois (1 500 po).</p>
<p>[[tab:rarete-et-valeur-des-objets-magiques]]</p>',
       reg_ordre = 30, reg_res_id = @res, reg_visible = 1, reg_date_modif = @now
 WHERE reg_slug = 'rarete-et-valeur-des-objets-magiques' AND reg_ruleset_var_id = @rs;

-- Activation d’un objet magique
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
SELECT @r_objets_magiques, 'regle', 'Activation d’un objet magique', 'activation-d-un-objet-magique', '', 40, @rs, @res, NULL, 1, @now, @now
  FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM dd_regles WHERE reg_slug = 'activation-d-un-objet-magique' AND reg_ruleset_var_id = @rs);
UPDATE dd_regles
   SET reg_reg_id = @r_objets_magiques, reg_type = 'regle', reg_nom = 'Activation d’un objet magique', reg_texte = '<p>L’action Magie est généralement requise pour activer un objet magique. Dans certains cas, l’utilisateur devra aussi accomplir quelque chose de spécial. La description de chaque catégorie d’objet ou de certains objets spécifiques détaille comment un tel objet doit être activé. L’activation de certains objets obéit aux règles suivantes.</p>
<h3>Mot de commande</h3>
<p>Un mot de commande est un mot ou une courte phrase qui doit être prononcé (oralement ou en langue des signes) pour que l’objet fonctionne. Les mots de commande doivent être prononcés de façon audible et ne fonctionnent pas dans les endroits où le son est réprimé, comme dans la zone d’effet du sort silence.</p>
<h3>Objets à utilisation unique</h3>
<p>Certains objets sont consommés, à savoir détruits, lorsqu’ils sont activés. Une potion de guérison, par exemple, doit être avalée, tandis que les écrits s’effacent d’un parchemin quand on le lit. Une fois utilisé, un objet à utilisation unique perd ses propriétés magiques.</p>
<h3>Sorts lancés depuis un objet</h3>
<p>Certains objets magiques permettent à l’utilisateur de lancer un sort à partir de l’objet. Le sort est lancé au niveau de sort et de lanceur le plus bas possible, ne consomme aucun des emplacements de sort de l’utilisateur et ne nécessite aucune composante, sauf mention contraire dans la description de l’objet. Le sort fonctionne de façon normale en ce qui concerne le temps d’incantation, la portée et la durée, et l’utilisateur de l’objet doit se concentrer si le sort nécessite la Concentration. De nombreux objets, comme les potions, ne demandent pas de lancer le sort et octroient les effets du sort avec sa durée habituelle.</p>
<p>Certains objets font exception à cette règle, modifiant le temps d’incantation, la durée ou d’autres aspects d’un sort.</p>
<p>Un objet magique peut nécessiter que l’utilisateur emploie sa propre caractéristique d’incantation quand il lance un sort par son biais. Si cet utilisateur présente plus d’une caractéristique d’incantation, il choisit laquelle employer avec l’objet. Si l’utilisateur est dépourvu de caractéristique d’incantation, son modificateur de caractéristique d’incantation est de +0 pour l’objet et son bonus de maîtrise s’applique.</p>
<h3>Charges</h3>
<p>Certains objets magiques sont dotés de charges que l’on dépense pour activer leurs propriétés. Le nombre de charges restantes d’un objet est révélé lorsque le sort identification est lancé sur lui. Une créature harmonisée avec un objet sait combien il lui reste de charges et quand et combien il en récupère le cas échéant.</p>
<h3>« L’aube suivante »</h3>
<p>Il est fréquent qu’un objet magique dispose de charges ou de propriétés qui se rechargent à l’aube suivante ou à un autre horaire spécifié. Si un tel objet se trouve sur un monde ou plan d’existence différent où l’événement spécifié ne se produit pas, il appartient au MJ de déterminer quand l’objet se recharge.</p>',
       reg_ordre = 40, reg_res_id = @res, reg_visible = 1, reg_date_modif = @now
 WHERE reg_slug = 'activation-d-un-objet-magique' AND reg_ruleset_var_id = @rs;

-- Objets maudits
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
SELECT @r_objets_magiques, 'regle', 'Objets maudits', 'objets-maudits', '', 50, @rs, @res, NULL, 1, @now, @now
  FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM dd_regles WHERE reg_slug = 'objets-maudits' AND reg_ruleset_var_id = @rs);
UPDATE dd_regles
   SET reg_reg_id = @r_objets_magiques, reg_type = 'regle', reg_nom = 'Objets maudits', reg_texte = '<p>La description d’un objet magique précise s’il est porteur d’une malédiction. La plupart des méthodes d’identification d’objet, y compris le sort identification, ne révèlent pas une telle malédiction.</p>
<p>L’Harmonisation avec un objet maudit ne peut pas être interrompue volontairement sauf si la malédiction a été levée au préalable, par exemple avec le sort délivrance des malédictions.</p>',
       reg_ordre = 50, reg_res_id = @res, reg_visible = 1, reg_date_modif = @now
 WHERE reg_slug = 'objets-maudits' AND reg_ruleset_var_id = @rs;

-- Résilience des objets magiques
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
SELECT @r_objets_magiques, 'regle', 'Résilience des objets magiques', 'resilience-des-objets-magiques', '', 60, @rs, @res, NULL, 1, @now, @now
  FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM dd_regles WHERE reg_slug = 'resilience-des-objets-magiques' AND reg_ruleset_var_id = @rs);
UPDATE dd_regles
   SET reg_reg_id = @r_objets_magiques, reg_type = 'regle', reg_nom = 'Résilience des objets magiques', reg_texte = '<p>Un objet magique est au moins aussi solide qu’un objet non magique du même type. De nombreux objets magiques, autres que les potions et les parchemins, sont dotés de la Résistance à tous les dégâts.</p>
<p>Un Artefact ne peut être détruit que par un moyen spécial. Il est sinon insensible à toute forme de dégâts. Apprendre à détruire un Artefact nécessite souvent des recherches ou l’accomplissement d’une quête.</p>',
       reg_ordre = 60, reg_res_id = @res, reg_visible = 1, reg_date_modif = @now
 WHERE reg_slug = 'resilience-des-objets-magiques' AND reg_ruleset_var_id = @rs;

-- Fabrication d’objets magiques
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
SELECT @r_objets_magiques, 'regle', 'Fabrication d’objets magiques', 'fabrication-d-objets-magiques', '', 70, @rs, @res, NULL, 1, @now, @now
  FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM dd_regles WHERE reg_slug = 'fabrication-d-objets-magiques' AND reg_ruleset_var_id = @rs);
UPDATE dd_regles
   SET reg_reg_id = @r_objets_magiques, reg_type = 'regle', reg_nom = 'Fabrication d’objets magiques', reg_texte = '<p>La section « Équipement » contient les règles propres à la concoction de potions de guérison et à l’écriture de parchemins de sort. Pour créer d’autres objets magiques, veuillez suivre les règles ci-après. Dans ces règles, « vous » concerne le personnage qui fabrique l’objet magique.</p>
<h3>Maîtrise des Arcanes</h3>
<p>Pour fabriquer un objet magique, vous-même ou un assistant devez avoir la maîtrise de la compétence Arcanes.</p>
<h3>Outils</h3>
<p>La table « Outils par objet magique » dresse la liste des outils nécessaires pour chaque catégorie d’objet magique. Vous devez utiliser l’outil indiqué pour fabriquer un tel objet et en avoir la maîtrise. Vos éventuels assistants doivent eux aussi en avoir la maîtrise. Pour plus d’informations sur les outils, référez-vous à la section « Équipement ».</p>
<p>[[tab:outils-par-objet-magique]]</p>
<h3>Sorts</h3>
<p>Si un objet magique permet à son utilisateur de lancer des sorts par son biais, vous devez avoir tous ces sorts préparés chaque jour consacré à la fabrication de l’objet.</p>
<h3>Temps et coût</h3>
<p>Fabriquer un objet magique demande du temps et de l’argent, corrélativement à sa rareté, comme indiqué dans la table « Coût et temps de fabrication d’un objet magique ».</p>
<p><strong>Travail par jour.</strong> Pour chaque jour de fabrication, vous devez travailler 8 heures. Si un objet nécessite plusieurs jours de travail, il n’est pas nécessaire que ces jours soient consécutifs.</p>
<p><strong>Assistants.</strong> Plusieurs personnages peuvent combiner leurs efforts pour réduire le temps de fabrication. Divisez le temps nécessaire à la création d’un objet par le nombre de personnages qui travaillent à sa fabrication. En temps normal, seul un autre personnage peut vous assister, mais le MJ peut vous en autoriser plusieurs.</p>
<p><strong>Matières premières.</strong> Le coût exprimé sur la table représente les matières premières nécessaires à la fabrication de l’objet magique. Le MJ détermine si les matières premières requises sont disponibles. Dans une cité, ces matières premières ont 75 % de chances d’être disponibles. Dans toute autre communauté, ces chances tombent à 25 %. Si les matières premières ne sont pas disponibles, vous devez attendre au moins 7 jours avant de refaire le test.</p>
<p>Si la fabrication d’un objet magique nécessite un objet avec prix d’achat (par exemple une arme ou une armure), vous devez en outre acquitter ce prix entier ou fabriquer l’objet selon les règles de la section « Équipement ». Pour la fabrication d’une armure +1 (harnois), par exemple, vous pouvez payer 3 500 po, ou seulement 2000 po et fabriquer l’armure.</p>
<p>[[tab:cout-et-temps-de-fabrication-d-un-objet-magique]]</p>',
       reg_ordre = 70, reg_res_id = @res, reg_visible = 1, reg_date_modif = @now
 WHERE reg_slug = 'fabrication-d-objets-magiques' AND reg_ruleset_var_id = @rs;

-- Objets magiques intelligents
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
SELECT @r_objets_magiques, 'regle', 'Objets magiques intelligents', 'objets-magiques-intelligents', '', 80, @rs, @res, NULL, 1, @now, @now
  FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM dd_regles WHERE reg_slug = 'objets-magiques-intelligents' AND reg_ruleset_var_id = @rs);
UPDATE dd_regles
   SET reg_reg_id = @r_objets_magiques, reg_type = 'regle', reg_nom = 'Objets magiques intelligents', reg_texte = '<p>Certains objets magiques sont dotés d’une intelligence et d’une personnalité. Un tel objet peut être possédé ou hanté par l’esprit d’un ancien propriétaire, ou bénéficier d’une conscience propre grâce à la magie qui l’a créé. Un objet intelligent est parfois un allié précieux pour son porteur, parfois une perpétuelle épine dans son pied.</p>
<p>La plupart des objets intelligents sont des armes, mais d’autres types d’objet peuvent posséder une conscience. Un objet à usage unique tel qu’une potion ou un parchemin n’est jamais intelligent.</p>
<p>Le MJ contrôle les objets magiques intelligents et leurs propriétés activées. Un porteur qui entretient une bonne relation avec l’objet peut accéder à ces propriétés. En cas de relation tendue, un conflit peut s’ensuivre (cf. « Conflits » ci-après).</p>
<h3>Traits des objets magiques intelligents</h3>
<p>Lorsque vous créez un objet magique intelligent, vous esquissez sa personnalité comme vous le feriez pour un PNJ, à quelques exceptions près.</p>
<p><strong>Caractéristiques.</strong> Un objet magique intelligent est doté de valeurs d’Intelligence, de Sagesse et de Charisme. Choisissez les caractéristiques de l’objet ou déterminez-les au hasard comme suit : lancez 4d6 pour chacune, en ne totalisant que les trois meilleurs.</p>
<p><strong>Alignement.</strong> Tout objet magique intelligent est doté d’un alignement. Son créateur ou la nature de l’objet peuvent influer sur cet alignement. Sans cela, choisissez un alignement ou laissez faire le hasard via la table « Alignement d’objet intelligent ».</p>
<p>[[tab:alignement-d-objet-intelligent]]</p>
<p><strong>Mode de communication.</strong> Un objet intelligent communique en livrant ses émotions, en transmettant le fond de ses pensées par télépathie ou en parlant à voix haute. Choisissez comment il communique ou laissez le hasard décider selon la table « Modes de communication d’objet intelligent » ci-après.</p>
<p>[[tab:modes-de-communication-d-objet-intelligent]]</p>
<p><strong>Sens.</strong> Un objet intelligent peut percevoir l’environnement à une portée limitée. Choisissez quels sont ses sens ou laissez le hasard décider selon la table « Sens d’objet intelligent » ci-après.</p>
<p>[[tab:sens-d-objet-intelligent]]</p>
<p><strong>Grand dessein.</strong> Vous pouvez attribuer à un objet intelligent un objectif qu’il poursuit, possiblement à l’exclusion de toute autre considération. Tant que son porteur agit en accord avec ce grand dessein, l’objet reste disposé à coopérer. Dévier de ce cap peut générer un conflit entre l’objet et son porteur (cf. « Conflits » ci-après). Choisissez un grand dessein ou laissez faire le hasard via la table « Grand dessein d’objet intelligent » ci-après.</p>
<p>[[tab:grand-dessein-d-objet-intelligent]]</p>
<h3>Conflits</h3>
<p>Lorsque le porteur d’un objet intelligent agit de façon contraire à l’alignement ou au dessein de l’objet, un conflit peut naître. Lorsqu’un tel conflit éclate, le porteur de l’objet effectue un jet de sauvegarde de Charisme (DD 12 + le modificateur de Charisme de l’objet). En cas d’échec, l’objet émet une ou plusieurs exigences parmi celles qui suivent :</p>
<p><strong>Poursuis mes rêves.</strong> L’objet exige que son porteur se consacre à son dessein, à l’exclusion de toute autre considération.</p>
<p><strong>Du balai.</strong> L’objet exige que son porteur se débarrasse de tout ce que l’objet trouve répugnant.</p>
<p><strong>Le changement, c’est maintenant.</strong> L’objet exige d’être confié à quelqu’un d’autre.</p>
<p><strong>Ne me quitte pas.</strong> L’objet insiste pour être équipé ou porté à tout moment.</p>
<p>Si son porteur refuse d’accéder aux exigences de l’objet, celui-ci peut faire l’une des choses ci-après :</p>
<ul>
<li>Rendre impossible l’Harmonisation avec son porteur.</li>
<li>Réprimer une ou plusieurs de ses propriétés activées.</li>
<li>Tenter de prendre le contrôle de son porteur, auquel cas celui-ci effectue un jet de sauvegarde de Charisme (DD 12 + le modificateur de Charisme de l’objet). En cas d’échec, le porteur subit l’état Charmé pendant 1d12 heures. Tant qu’il est ainsi Charmé, le porteur s’efforce d’obéir aux ordres de l’objet. Si le porteur subit des dégâts, il réitère le JS et met un terme à l’effet en cas de réussite. Que la tentative de contrôle de son porteur réussisse ou non, l’objet ne peut plus utiliser ce pouvoir jusqu’à l’aube suivante.</li>
</ul>',
       reg_ordre = 80, reg_res_id = @res, reg_visible = 1, reg_date_modif = @now
 WHERE reg_slug = 'objets-magiques-intelligents' AND reg_ruleset_var_id = @rs;

-- Objets magiques de A à Z
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
SELECT @r_objets_magiques, 'regle', 'Objets magiques de A à Z', 'objets-magiques-de-a-a-z', '', 90, @rs, @res, NULL, 1, @now, @now
  FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM dd_regles WHERE reg_slug = 'objets-magiques-de-a-a-z' AND reg_ruleset_var_id = @rs);
UPDATE dd_regles
   SET reg_reg_id = @r_objets_magiques, reg_type = 'regle', reg_nom = 'Objets magiques de A à Z', reg_texte = '<p>Les objets magiques sont présentés par ordre alphabétique.</p>
<p>Si, dans la description d’un objet magique, le nom d’une créature est présenté en gras, cela indique que vous devez consulter son profil. Sauf mention contraire, ce profil de jeu figure alors dans « Monstres ». La lecture et l’utilisation d’un profil sont décrites dans « Monstres ».</p>
<p>Les objets du SRD sont listés ci-dessous par catégorie ; chaque ligne ouvre la fiche de l’objet.</p>
<h3>Anneaux</h3>
<p>[[liste:objet|famille=anneaux|source=SRD 5.2.1|titre=-]]</p>
<h3>Armes</h3>
<p>[[liste:objet|famille=armes|source=SRD 5.2.1|titre=-]]</p>
<h3>Armures</h3>
<p>[[liste:objet|famille=armures|source=SRD 5.2.1|titre=-]]</p>
<h3>Baguettes</h3>
<p>[[liste:objet|famille=baguettes|source=SRD 5.2.1|titre=-]]</p>
<h3>Bâtons</h3>
<p>[[liste:objet|famille=batons|source=SRD 5.2.1|titre=-]]</p>
<h3>Objets merveilleux</h3>
<p>[[liste:objet|famille=objets-merveilleux|source=SRD 5.2.1|titre=-]]</p>
<h3>Parchemins</h3>
<p>[[liste:objet|famille=parchemins|source=SRD 5.2.1|titre=-]]</p>
<h3>Potions</h3>
<p>[[liste:objet|famille=potions|source=SRD 5.2.1|titre=-]]</p>
<h3>Sceptres</h3>
<p>[[liste:objet|famille=sceptres|source=SRD 5.2.1|titre=-]]</p>',
       reg_ordre = 90, reg_res_id = @res, reg_visible = 1, reg_date_modif = @now
 WHERE reg_slug = 'objets-magiques-de-a-a-z' AND reg_ruleset_var_id = @rs;
COMMIT;
