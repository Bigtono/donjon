-- sql/2026-10-11_regles_dd35_drs23_sp-drs3.sql
-- SP-DRS3 — DRS 23 : Objets magiques
-- Règles DD3.5 (mécanismes de jeu uniquement). Les articles eux-mêmes — prix, poids, caractéristiques et
-- descriptions — vivent dans le compendium ; les listes sont insérées par le tag [[liste:…]] (SP-PO1).
-- Texte corrigé : voir doc/LOG_CORRECTIONS_DRS07_DRS23.md.
-- Rejouable : le sous-arbre, les tableaux et les termes de glossaire de CE fichier sont
-- réinitialisés par slug ; rien d'autre n'est touché. Aucun reg_id codé en dur. Pas de DELIMITER.
-- Pré-requis : 2026-08-25_regles_dd35_socle.sql.

SET NAMES utf8mb4;

SET @ddver := (SELECT var_id FROM dd_variables WHERE var_cat = 'ruleset' AND var_valeur = 'DD3.5' LIMIT 1);
SET @res   := (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'DRS 3.5' AND res_ruleset_var_id = @ddver LIMIT 1);
SET @glo   := (SELECT reg_id FROM dd_regles WHERE reg_slug = 'glossaire' AND reg_ruleset_var_id = @ddver LIMIT 1);
SET @now   := NOW();

START TRANSACTION;

-- Réinitialisation idempotente
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'catalogue-des-objets-magiques';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'estimation-du-prix-des-objets-magiques';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'objets-intelligents-et-ajout-de-proprietes';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'creation-par-categorie';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'conditions-et-couts-de-creation';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'creation-d-objets-magiques';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'description-des-objets-magiques';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'charges-doses-et-usage-limite';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'sauvegardes-degats-et-reparation-des-objets-magiques';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'emplacements-des-objets-magiques';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'taille-des-objets-magiques';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'utiliser-les-objets-magiques';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'detection-de-la-magie-et-objets-magiques';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'categories-d-objets-magiques';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'objets-magiques';
DELETE FROM dd_regles
WHERE  reg_ruleset_var_id = @ddver AND reg_type = 'glossaire' AND reg_reg_id = @glo
  AND  reg_slug IN (
    'objet-a-fin-d-incantation',
    'objet-a-potentiel-magique',
    'objet-a-mot-de-commande',
    'objet-a-usage',
    'niveau-de-lanceur-de-sorts-d-un-objet',
    'aura-d-un-objet-magique',
    'charge-d-un-objet',
    'prix-de-base-d-un-objet-magique',
    'emplacement-d-un-objet-magique');
DELETE FROM dd_tableaux
WHERE  tab_ruleset_var_id = @ddver
  AND  tab_slug IN (
    'ecole-objet-magique',
    'determination-aleatoire-objets-magiques',
    'affinites-emplacements-corps',
    'resume-couts-creation-objets-magiques',
    'prix-base-baguettes',
    'cout-creation-baguettes',
    'prix-base-parchemins',
    'cout-creation-parchemins',
    'prix-base-potions-huiles',
    'cout-creation-potions-huiles',
    'estimation-prix-objets-magiques');

-- Nœuds
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (NULL, 'chapitre', 'Objets magiques', 'objets-magiques',
'<p>Les règles communes à tous les objets magiques : catégories, activation, taille, emplacements sur le corps, dégâts, charges, création et estimation du prix. Chaque objet a sa fiche dans le compendium ; les <strong>listes d''objets</strong> de ce chapitre proviennent du compendium et sont toujours à jour.</p>',
        50, @ddver, @res, NULL, 1, @now, @now);
SET @r_objets_magiques := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_objets_magiques, 'regle', 'Les catégories d''objets magiques', 'categories-d-objets-magiques',
'<p>Les objets magiques sont divisés en catégories : anneaux, armes, armures (et boucliers), baguettes, bâtons, objets merveilleux, parchemins, potions (et huiles), et sceptres. Les objets intelligents ou maudits sont détaillés après. Enfin, certains objets sont tellement rares et puissants qu''ils sont classés à part. Il s''agit des artefacts, lesquels peuvent être rares (dans le cas d''objets dont il n''existe qu''une poignée d''exemplaires de par le monde) ou uniques.</p>
<p><strong>Anneaux.</strong> Un anneau est un cercle de matière dure (le plus souvent de métal) que l''on porte au doigt (dans la limite de deux anneaux par personnage). Chaque anneau possède un pouvoir magique, souvent un effet constant affectant son porteur.</p>
<p><strong>Armes.</strong> Les armes magiques confèrent un bonus d''altération sur les jets d''attaque et de dégâts de leur utilisateur, et certaines possèdent d''autres pouvoirs.</p>
<p><strong>Armures et boucliers.</strong> Les armures et boucliers magiques confèrent une protection renforcée à leur utilisateur, et certains possèdent également d''autres pouvoirs.</p>
<p><strong>Baguettes.</strong> Une baguette est un petit bout de bois doté du pouvoir de jeter un certain sort. Une baguette nouvellement créée contient 50 charges et chaque activation du sort qu''elle contient dépense l''une de ces charges.</p>
<p><strong>Bâtons.</strong> Un bâton possède un certain nombre de pouvoirs différents souvent réunis par un concept commun. Un bâton nouvellement créé possède 50 charges et chaque utilisation d''une de ses fonctions dépense une ou plusieurs de ces charges.</p>
<p><strong>Objets merveilleux.</strong> Cette catégorie réunit tous les autres types d''objets magiques, ce qui comprend les bijoux, les outils, les livres, les habits et bien d''autres choses encore.</p>
<p><strong>Parchemins.</strong> On appelle parchemin magique un ou plusieurs sorts écrits sur une feuille de papier ou de parchemin, destinés à être utilisés ultérieurement.</p>
<p><strong>Potions et huiles.</strong> Une potion est un breuvage produisant un effet similaire à un sort et qui n''affecte que celui qui la boit. Une huile affecte un objet sur lequel elle est ointe.</p>
<p><strong>Sceptres.</strong> Un sceptre est un objet possédant un pouvoir qui n''a rien à voir avec les sorts existants.</p>
<p><strong>Objets intelligents.</strong> Certains objets, pour la plupart des armes, sont doués d''intelligence. Seuls les objets permanents peuvent être intelligents, pas ceux qui sont à charges ou à usage unique (autrement dit, potions, huiles, parchemins et baguettes, entre autres, ne sont jamais intelligents). En règle générale, moins de 1 % des objets magiques sont intelligents.</p>
<p><strong>Objets maudits.</strong> Qu''un accident se soit produit au cours de leur fabrication ou qu''ils aient été corrompus par une force extérieure, certains objets magiques sont maudits. Ils peuvent être très handicapants pour leur possesseur, à moins qu''ils présentent juste un défaut plus gênant que dangereux, ou encore qu''ils soient par nature imprévisibles. Les objets tirés aléatoirement sont maudits dans 5 % des cas.</p>',
        10, @ddver, @res, NULL, 1, @now, @now);
SET @r_categories_d_objets_magiques := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_objets_magiques, 'regle', 'Détection de la magie et objets magiques', 'detection-de-la-magie-et-objets-magiques',
'<p>Le sort <em>détection de la magie</em> permet d''identifier l''école à laquelle est affilié un objet magique, c''est-à-dire celle du sort placé dans une potion, une huile, un parchemin ou une baguette, ou du ou des sorts faisant partie des conditions de création des autres types d''objets. La description de chaque objet magique indique l''école à laquelle il est affilié et l''intensité de son aura.</p>
<p>Pour les objets que vous concevez vous-même et dont la construction requiert plusieurs sorts, une détection de la magie se focalise sur le sort dont le niveau est le plus élevé. Si aucun sort n''est exigé dans les conditions, appliquez la règle suivante.</p>
<p>[[tab:ecole-objet-magique]]</p>',
        20, @ddver, @res, NULL, 1, @now, @now);
SET @r_detection_de_la_magie_et_objets_magiques := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_objets_magiques, 'regle', 'Utilisation des objets', 'utiliser-les-objets-magiques',
'<p>Pour pouvoir utiliser un objet, il faut commencer par l''activer, ce qui est parfois aussi simple que d''enfiler un anneau à son doigt. Certains objets fonctionnent en permanence à partir du moment où on les porte, mais dans la plupart des cas, l''utilisation d''un objet nécessite une action simple (qui ne provoque pas d''attaque d''opportunité). Ce n''est pas le cas des objets à fin d''incantation, qui sont considérés comme des sorts en situation de combat et dont l''utilisation provoque donc une attaque d''opportunité.</p>
<p>Sauf indication contraire dans la description de l''objet, l''activation d''un objet magique requiert une action simple. Cependant, lorsqu''un objet reproduit fidèlement l''effet d''un sort, son temps d''activation est égal au temps d''incantation du sort en question (là encore, sauf indication contraire).</p>
<p>Les quatre types d''objets magiques sont développés ci-dessous.</p>
<h3>Objets à fin d''incantation</h3>
<p>C''est la méthode d''activation des parchemins. Un parchemin est une incantation magique en grande partie prononcée. L''étape de préparation a déjà été effectuée (par celui qui a transcrit le sort sur le parchemin) et il ne reste plus à l''utilisateur qu''à achever l''incantation, en prononçant les dernières paroles et en effectuant les derniers gestes. Pour pouvoir utiliser ce type d''objet sans risque, le sort doit apparaître sur la liste des sorts d''une de ses classes et il doit être d''un niveau suffisant dans cette classe pour y avoir théoriquement accès lui-même. Si son niveau n''est pas assez élevé, un incident est toujours possible. Activer un objet à fin d''incantation est une action simple qui provoque une attaque d''opportunité (comme si le personnage lançait un sort).</p>
<h3>Objets à potentiel magique</h3>
<p>Cette méthode est similaire à la précédente, mais en plus simple encore. Le personnage n''a pas besoin d''achever l''incantation ; il lui suffit de la connaître (ne serait-ce qu''empiriquement) et de prononcer le mot déclenchant le pouvoir. En fait, l''objet reconnaît le potentiel magique de l''utilisateur. Il suffit que le ou les sorts fassent partie de la liste de sorts auxquels le personnage a droit en vertu de sa classe, et cette règle s''applique même si l''aventurier n''est pas encore capable de lancer des sorts, comme c''est le cas pour un paladin de niveau 1 à 3. Le personnage doit tout de même déterminer quel est le sort contenu dans l''objet avant de pouvoir y faire appel. Activer un objet à potentiel magique est une action simple qui ne provoque pas d''attaque d''opportunité.</p>
<h3>Objets à mot de commande</h3>
<p>Si aucune méthode d''activation n''est suggérée dans la description de l''objet ou par la nature de ce dernier, partez du principe qu''il est nécessaire de connaître un mot de commande. Avec ce type d''objet, le pouvoir se déclenche dès que l''utilisateur prononce le mot voulu ; il n''a pas besoin d''avoir la moindre connaissance en matière de magie.</p>
<p>Le mot de commande peut être un mot on ne peut plus normal, mais dans ce cas, le personnage risque d''activer accidentellement son objet s''il prononce le mot au cours d''une conversation. Le plus souvent, le mot ne veut rien dire, quand il ne s''agit pas d''un terme (ou d''une phrase) tiré d''une langue morte. Activer un objet à mot de commande est une action simple qui ne provoque pas d''attaque d''opportunité.</p>
<p>Il arrive que le mot de commande activant l''objet soit mentionné sur ce dernier. Parfois, il est camouflé par un dessin ou une frise rajouté ultérieurement, à moins que l''objet n''arbore un symbole permettant de retrouver le mot de commande lui-même.</p>
<p>Les compétences Connaissances (histoire) et Connaissances (mystères) peuvent permettre d''identifier les mots de commande ou de reconnaître des indices à leur sujet. Un test de compétence réussi (DD 30) est nécessaire pour trouver le mot de commande proprement dit. En cas d''échec, le fait de réussir un second test (DD 25) fournira peut-être un indice utile.</p>
<p>Les sorts <em>identification</em> et <em>analyse d''enchantement</em> permettent d''obtenir le mot de commande d''un objet.</p>
<h3>Objets à usage</h3>
<p>Il suffit d''utiliser normalement ce type d''objet pour que son pouvoir prenne effet : il peut falloir boire une potion, porter un habit, utiliser une arme ou un bouclier au combat, regarder à travers une lentille, éparpiller de la poudre, porter un anneau ou mettre un chapeau. C''est le mode d''activation le plus simple qui soit.</p>
<p>Nombre d''objets à usage sont des objets que l''on porte (vêtements, bijoux, etc.). C''est encore plus vrai avec les objets à fonctionnement continu, qui doivent presque tous être portés en permanence. Quelques-uns doivent simplement être en possession du personnage (c''est-à-dire quelque part sur sa personne, pas chez lui, au fond d''un coffre). Cela étant, certains objets conçus pour être portés doivent tout de même être activés. Même si cette activation nécessite parfois un mot de commande (voir ci-dessus), dans la plupart des cas, le personnage doit juste souhaiter mentalement que l''objet fonctionne. La description de l''objet indique généralement si un mot de commande est nécessaire ou non.</p>
<p>Sauf indication contraire, l''activation d''un objet à usage est soit une action simple, soit une activité instantanée et ne provoque pas d''attaque d''opportunité, sauf si l''usage que l''on fait de l''objet implique une action qui, elle, offre une attaque d''opportunité à l''adversaire. Si un certain laps de temps est nécessaire entre le moment où le personnage décide d''utiliser l''objet et celui où le pouvoir se déclenche, l''activation est une action simple. Par contre, si le pouvoir de l''objet prend effet chaque fois qu''on s''en sert, l''activation est une activité instantanée.</p>
<p>Notez bien que le fait de posséder un objet à usage n''implique pas que l''on sache ce qu''il fait. L''aventurier doit savoir quel est le pouvoir de l''objet (ou du moins en avoir une bonne idée) pour pouvoir s''en servir, sauf si ce pouvoir est permanent, comme c''est le cas pour une potion ou une arme.</p>',
        30, @ddver, @res, NULL, 1, @now, @now);
SET @r_utiliser_les_objets_magiques := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_objets_magiques, 'regle', 'Taille des objets magiques', 'taille-des-objets-magiques',
'<p>Lorsque les personnages découvrent un vêtement, un bijou ou une armure magiques, la taille ne doit pas constituer un problème. La plupart des habits magiques sont de taille unique ou s''adaptent d''eux-mêmes à la morphologie du porteur. Ne pénalisez pas un joueur parce qu''il a décidé d''incarner un personnage d''un type particulier.</p>
<p>Cela étant, il peut y avoir une raison pour que les objets s''adressent à une certaine catégorie ou race de personnages.</p>
<p><strong>Taille des armes et des armures.</strong> Les armes et les armures magiques découvertes dans un trésor déterminé aléatoirement ont 30 % de chances d''être de taille P (01–30), 60 % de chances d''être de taille M (31–90) et 10 % de chances d''être d''une autre taille (91–100). Ces objets s''adaptent à la taille de leur porteur tant qu''il est de la même catégorie de taille que l''objet, mais pas au-delà.</p>',
        40, @ddver, @res, NULL, 1, @now, @now);
SET @r_taille_des_objets_magiques := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_objets_magiques, 'regle', 'Emplacements des objets magiques sur le corps', 'emplacements-des-objets-magiques',
'<p>Beaucoup d''objets magiques doivent être portés pour qu''un personnage bénéficie de ses pouvoirs. Un objet doit être placé à un endroit précis pour fonctionner, et la magie de deux objets portés l''un sur l''autre s''annule. Cela fait qu''une créature humanoïde peut porter ainsi jusqu''à 12 objets différents en même temps.</p>
<p>Voici la liste des emplacements où une créature humanoïde peut porter un objet magique et les types d''objets qui peuvent s''y placer.</p>
<ul>
<li><strong>Sur la tête :</strong> un serre-tête, un bandeau, une couronne, un casque, un couvre-chef ou un phylactère.</li>
<li><strong>Devant les yeux :</strong> une paire de lunettes, des lentilles ou un monocle.</li>
<li><strong>Autour du cou :</strong> une amulette, une broche, un médaillon, un collier, un charme ou un scarabée.</li>
<li><strong>Sur le torse :</strong> un gilet, une veste, une chemise, une chasuble.</li>
<li><strong>Sur le corps</strong> (éventuellement par-dessus un gilet, une veste, une chemise ou une chasuble) : une robe ou une armure.</li>
<li><strong>Autour de la taille</strong> (éventuellement par-dessus une robe ou une armure) : une ceinture ou un ceinturon.</li>
<li><strong>Sur les épaules</strong> (éventuellement par-dessus une robe ou une armure) : une cape, une écharpe ou un manteau.</li>
<li><strong>Sur les bras ou les poignets :</strong> une paire de bracelets.</li>
<li><strong>Aux mains :</strong> une paire de gants ou de gantelets.</li>
<li><strong>Aux doigts :</strong> deux anneaux (un sur chaque main ou les deux sur la même main).</li>
<li><strong>Aux pieds :</strong> une paire de bottes ou de chaussons.</li>
</ul>
<p>Un personnage peut bien évidemment posséder plusieurs objets d''un même type, mais lorsque cela se produit, le dernier objet ajouté ne fonctionne pas, le ou les autres continuant de faire effet normalement.</p>
<p>Certains objets peuvent être portés sans occuper d''emplacement. La description des objets précise s''ils possèdent cette propriété.</p>
<h3>Affinités des emplacements sur le corps</h3>
<p>Chaque emplacement sur le corps a une affinité pour certains types de magie, non pas une école, mais une description très générale de la nature ou de la fonction des effets qu''on peut y placer. Ces affinités sont sciemment larges et abstraites, car aucune règle stricte ne pourrait s''appliquer à la grande variété des objets merveilleux.</p>
<p>Vous pouvez utiliser la liste suivante d''affinités pour décider si vous refusez ou acceptez de déplacer les effets d''un objet sur un autre emplacement. De même, lorsque vous concevez vos propres objets magiques, ces affinités vous guident sur la forme à leur donner.</p>
<p>Certains objets occupant le même emplacement ont des affinités différentes. Ainsi les gantelets expriment la destruction, tandis que les gants inspirent plutôt la précision.</p>
<p>[[tab:affinites-emplacements-corps]]</p>
<p>Les objets merveilleux qui ne respectent pas l''affinité de leur emplacement sur le corps du porteur voient leur prix de base augmenter de 50 %.</p>',
        50, @ddver, @res, NULL, 1, @now, @now);
SET @r_emplacements_des_objets_magiques := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_objets_magiques, 'regle', 'Jets de sauvegarde, dégâts et réparation', 'sauvegardes-degats-et-reparation-des-objets-magiques',
'<h3>Jets de sauvegarde contre les effets des objets magiques</h3>
<p>Les objets magiques produisent des sorts ou des pouvoirs magiques similaires à des sorts. Lorsqu''ils autorisent un jet de sauvegarde, ce dernier est calculé de la façon suivante : 10 + niveau du sort ou de l''effet + modificateur de caractéristique correspondant à la valeur de caractéristique minimale pour lancer le sort en question.</p>
<p>Les bâtons sont une exception à la règle précédente. Les effets d''un bâton sont déterminés comme si l''utilisateur lançait lui-même le sort, y compris pour le niveau de lanceur de sorts et tous les modificateurs au DD des jets de sauvegarde.</p>
<p>Dans la plupart des cas, la description des objets indique le DD associé aux divers effets produits par l''objet, surtout lorsque ces effets ne correspondent pas exactement à des sorts existants (auquel cas le DD devient plus difficile à déterminer).</p>
<h3>Dégâts infligés aux objets magiques</h3>
<p>Un objet magique n''a besoin d''effectuer un jet de sauvegarde que s''il n''est pas porté ou tenu, s''il est ciblé spécifiquement ou si son porteur obtient un 1 naturel sur un jet de sauvegarde et que l''effet en question atteint précisément cet objet. Les objets magiques devraient toujours avoir droit à un jet de sauvegarde contre les sorts capables de les endommager, même si ceux-ci n''offrent généralement aucun jet de sauvegarde aux objets non magiques. Les objets magiques utilisent le même bonus de base pour tous les jets de sauvegarde (Réflexes, Vigueur ou Volonté). Celui-ci se monte à 2 + moitié du niveau de lanceur de sorts de l''objet (arrondi à l''entier inférieur). Les objets intelligents constituent l''unique exception à cette règle, puisque leur valeur de Sagesse est prise en compte pour leurs jets de Volonté.</p>
<p>Sauf indication contraire, les objets magiques sont endommagés de la même manière que les objets normaux du même type. S''ils sont seulement détériorés, ils continuent de fonctionner, mais ils perdent tout pouvoir une fois détruits.</p>
<h3>Réparer les objets endommagés</h3>
<p>Il arrive que les objets magiques soient endommagés au cours d''une aventure, plus particulièrement les armes et les boucliers. Il est possible de réparer un objet magique avec la compétence Artisanat appropriée, et le coût est le même que pour un objet ordinaire. Le sort <em>réparation intégrale</em> permet de réparer un objet magique endommagé (mais pas détruit).</p>',
        60, @ddver, @res, NULL, 1, @now, @now);
SET @r_sauvegardes_degats_et_reparation_des_objets_magiques := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_objets_magiques, 'regle', 'Charges, doses et usage limité', 'charges-doses-et-usage-limite',
'<p>Beaucoup d''objets, le plus souvent des bâtons et des baguettes, voient leur puissance limitée par leur nombre de charges. En temps normal, ce type d''objet a un maximum de 50 charges. Si on le trouve dans le cadre d''un trésor déterminé aléatoirement, jetez 1d100 et divisez le résultat par 2 afin d''obtenir le nombre de charges restantes (arrondissez à l''entier inférieur, sans descendre en dessous de 1 charge). Si l''objet a un nombre de charges maximal autre que 50, calculez les charges restantes proportionnellement au total indiqué.</p>
<p>Le prix de vente indiqué considère toujours que l''objet est pleinement chargé (ce qui est le cas au moment où il est créé). Dans le cas d''un objet qui ne vaut plus rien quand toutes ses charges sont épuisées (ce qui concerne la quasi-totalité des objets à charges), son prix de vente diminue proportionnellement au nombre de charges utilisées. Si l''objet reste utile une fois toutes ses charges épuisées, seule la partie de sa valeur correspondant à ses charges est diminuée.</p>',
        70, @ddver, @res, NULL, 1, @now, @now);
SET @r_charges_doses_et_usage_limite := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_objets_magiques, 'regle', 'Description des objets magiques', 'description-des-objets-magiques',
'<p>Chaque catégorie débute par une présentation générale des objets de ce type, puis tous les objets qu''elle comprend sont détaillés par ordre alphabétique.</p>
<p>La présentation générale regroupe des indications concernant, entre autres, le mode d''activation et la détermination aléatoire. La CA, la solidité et le nombre de points de résistance de certains objets types sont mentionnés, de même que le DD nécessaire pour les casser ou les détruire. La CA indiquée part du principe que l''objet n''est ni porté, ni tenu, ce qui lui donne une Dextérité effective de 0 (malus de –5 à la CA). S''il est tenu ou porté par une créature, utilisez le modificateur de Dextérité de cette dernière plutôt que le malus de –5.</p>
<p>Certains objets ne bénéficient pas d''une description détaillée, surtout si leur unique fonction consiste à lancer un sort décrit par ailleurs. Consultez tout simplement la description du sort concerné en l''adaptant à l''objet (potion, parchemin, baguette, etc.). Partez du principe que le sort est lancé au niveau minimal pour pouvoir l''utiliser.</p>
<p>Les objets décrits voient leurs pouvoirs détaillés un à un, et les précisions suivantes apparaissent à la fin de leur description sous forme condensée.</p>
<ul>
<li><strong>Aura.</strong> La plupart du temps, un sort de détection de la magie permet d''apprendre à quelle école est affilié un objet magique et l''intensité de son aura magique. Quand elle est applicable, cette information est la première à figurer sur le profil condensé. La description du sort <em>détection de la magie</em> donne les détails des auras.</li>
<li><strong>Niveau de lanceur de sorts (NLS).</strong> L''information suivante du profil condensé est le niveau de lanceur de sorts de l''objet, qui permet d''estimer sa puissance relative. Le niveau de lanceur de sorts détermine le bonus de base aux sauvegardes de l''objet, mais aussi les variables telles que la portée ou les dégâts des effets générés, le cas échéant. Il indique également quel est le niveau de l''objet si celui-ci est pris pour cible par un sort tel que <em>dissipation de la magie</em>. Il est présenté sous la forme « NLS X » (NLS est une abréviation pour « niveau de lanceur de sorts »). Pour les potions, les huiles, les parchemins et les baguettes, le créateur de l''objet peut fixer librement le niveau de lanceur de sorts, à condition que celui-ci soit compris entre son propre niveau de lanceur de sorts et le niveau nécessaire pour jeter le sort stocké dans l''objet. Pour les autres objets magiques, le niveau de lanceur de sorts est déterminé par la nature de l''objet et il ne fait pas partie de ses conditions de création (voir <em>Création d''objets magiques</em>).</li>
<li><strong>Conditions.</strong> Les conditions auxquelles le personnage doit satisfaire pour pouvoir fabriquer l''objet sont précisées immédiatement après le niveau de lanceur de sorts. Il s''agit de dons, de sorts ou d''autres considérations telles que le fait d''appartenir à une certaine race, d''avoir atteint un niveau donné, etc.</li>
<li><strong>Prix de vente.</strong> Le prix de vente de l''objet est précédé du mot « Prix » qui représente la somme qu''un aventurier doit s''attendre à débourser s''il désire l''acheter. Le prix de vente a pour avantage de permettre un classement rapide des objets. Le prix de vente d''un objet pouvant être fabriqué à l''aide d''un don de création d''objets est généralement égal à son prix de base plus le coût éventuel des composantes matérielles et le nombre de PX à dépenser (le cas échéant).</li>
<li><strong>Coût de création.</strong> L''information suivante est annoncée par le mot « Coût » et indique le coût en pièces d''or et en points d''expérience nécessaire à la création de l''objet. Cette donnée n''apparaît que pour les objets ayant besoin de composantes matérielles coûteuses ou de PX et pour lesquels le prix de vente est supérieur au prix de base. Le coût de fabrication fait la somme des coûts habituels (liés au prix de base) et du prix des composantes supplémentaires. Les objets ne nécessitant pas de composantes matérielles coûteuses ne fournissent pas cette donnée. Dans leur cas, le prix de vente et le prix de base sont égaux. Leur coût de fabrication est égal à la moitié du prix de vente (en po), plus 1/25e du prix de vente (en PX).</li>
<li><strong>Poids.</strong> Le profil condensé de nombreux objets merveilleux s''achève sur leur poids. Si aucune indication de poids n''est présente, cela signifie que l''objet merveilleux a un poids négligeable (pour ce qui est de déterminer la charge transportée par chaque aventurier). Le poids des objets des autres catégories est précisé dans leur description générale ou correspond à un objet ordinaire du même type.</li>
</ul>
<h3>Détermination aléatoire des objets magiques</h3>
<p>[[tab:determination-aleatoire-objets-magiques]]</p>',
        80, @ddver, @res, NULL, 1, @now, @now);
SET @r_description_des_objets_magiques := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_objets_magiques, 'chapitre', 'Création d''objets magiques', 'creation-d-objets-magiques',
'<p>La création d''objets magiques est un art difficile qui exige des dons, de l''argent, du temps et le sacrifice d''une part de son énergie vitale (sous la forme de PX). Les secrets de création des artefacts ont été perdus depuis longtemps.</p>',
        90, @ddver, @res, NULL, 1, @now, @now);
SET @r_creation_d_objets_magiques := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_creation_d_objets_magiques, 'regle', 'Conditions et coûts de création', 'conditions-et-couts-de-creation',
'<h3>Conditions</h3>
<p>Pour pouvoir créer un objet magique, il faut remplir certaines conditions de dons, de sorts ou autres.</p>
<p><strong>Dons requis.</strong> Le créateur doit posséder un ou plusieurs dons, dont au moins un don de création d''objets, et parfois des dons de métamagie ou généraux.</p>
<p><strong>Sorts requis.</strong> La création de la plupart des objets requiert un ou plusieurs sorts. Le créateur de l''objet doit préparer les sorts requis au début de chaque journée de travail (ou simplement les connaître dans le cas des ensorceleurs et des bardes). Le sort préparé est dépensé lors du travail sur l''objet (dans le cas des ensorceleurs et des bardes, un emplacement de sort du niveau correspondant à celui du sort est compté comme utilisé). Cependant, le sort n''est pas lancé mais juste consommé, et le personnage n''a pas à fournir les composantes matérielles, les focaliseurs, ou à sacrifier les PX normalement exigés lors de leur incantation normale.</p>
<p>Une condition de sort requis peut aussi être remplie par l''intermédiaire d''un autre lanceur de sorts, d''un pouvoir magique ou d''un objet à fin d''incantation ou à potentiel magique. Dans ce cas, chaque jour, le créateur doit utiliser son pouvoir magique ou son objet magique ou l''assistant doit préparer le sort (qui est dépensé comme décrit ci-dessus).</p>
<p><strong>Autres conditions.</strong> La création d''un objet donné peut n''être possible qu''aux personnages d''une certaine race ou d''un certain alignement ou encore aux pratiquants de la magie ayant atteint un niveau de lanceur de sorts donné. Cette dernière condition est par exemple requise par les armes, armures et boucliers magiques.</p>
<p><strong>Création commune.</strong> Plusieurs personnages peuvent collaborer à la fabrication d''un objet magique. Chacun d''entre eux doit remplir les conditions de dons de création d''objets. Par contre, ils n''ont à remplir les autres conditions (de dons métamagiques ou généraux, de sorts et autres) qu''à eux tous, plutôt qu''individuellement. Le temps de création n''est pas réduit. L''un d''entre eux doit être désigné comme le créateur pour déterminer le niveau de lanceur de sorts de l''objet (dans le cas d''un objet ayant un niveau variable, c''est-à-dire uniquement les baguettes, les parchemins, les potions et les huiles). Le sacrifice en PX peut être au choix effectué par le créateur seul ou réparti équitablement entre les différents intervenants.</p>
<h3>Prix</h3>
<p>Les coûts de base de création d''un objet magique (en PX, en or et en temps) dépendent de son prix de base. Celui-ci tient uniquement compte de la magie nécessaire, et pas des coûts complémentaires liés à un objet, à une composante matérielle coûteuse ou à un sacrifice de PX supplémentaire. Dans la plupart des cas, le prix de base d''un objet est égal à son prix de vente.</p>
<p><strong>Coût de base de création.</strong> Le coût de base de création d''un objet se monte toujours à la moitié de son prix de base en po pour les matières premières, à 1/25e de son prix de base en PX pour le sacrifice en points d''expérience et à 1 jour de travail par tranche de 1 000 po du prix de base. (Le temps ne peut descendre en dessous d''une journée par objet. Exception : le temps de préparation des potions et des huiles est toujours égal à un jour, quel que soit leur prix de base.) Le personnage doit dépenser l''or et sacrifier les PX au début du processus de création de l''objet.</p>
<h3>Coûts supplémentaires</h3>
<p>Les coûts supplémentaires doivent être acquittés en plus des coûts de base de création. Ils peuvent être dus à un objet ou aux composantes d''un sort.</p>
<p><strong>Coût d''objet.</strong> Dans la plupart des cas, le coût de l''objet à rendre magique est compris dans le coût de base des matières premières. Ce n''est cependant pas le cas quand l''objet a une valeur propre, en tant que gemme ou objet d''art par exemple, ou encore en tant qu''arme, armure ou bouclier de maître. (Les autres objets magiques n''ont pas besoin d''être de maître ou de qualité supérieure.)</p>
<p><strong>Coût de composante.</strong> Si les effets d''un objet magique dupliquent exactement un sort (c''est le cas de toutes les baguettes, de tous les bâtons, parchemins, potions et huiles), et que ce sort exige une composante matérielle coûteuse ou un sacrifice de PX, le créateur doit les acquitter lors de la création de l''objet. Dans le cas d''un objet à charges, les coûts sont multipliés par le nombre de charges (par exemple ×1 pour un parchemin ou ×50 pour une baguette). (Pour les bâtons, ce coût est divisé par le nombre de charges dépensées pour activer le sort.) Dans le cas d''un objet illimité, les coûts sont multipliés par 50 si le sort n''est utilisable qu''un certain nombre de fois par jour, ou par 100 dans les autres cas.</p>
<p>Ces coûts ne concernent que les sorts qui sont effectivement lancés par l''objet, ce qui n''est généralement pas le cas des sorts requis comme condition pour la création de l''objet.</p>
<p><strong>Coût total de création.</strong> Le coût total de création d''un objet est simplement la somme de ses coûts de base et de ses coûts supplémentaires. La description des objets requérant des coûts supplémentaires comprend le coût total du processus de fabrication.</p>
<p><strong>Prix de vente final.</strong> Le prix de vente final d''un objet est égal à son prix de base plus un éventuel coût d''objet, plus un éventuel coût de composante en po, plus 5 fois un éventuel coût de composante en PX.</p>
<p><strong>Sorts de niveau 0.</strong> Dans tous les calculs sur le prix des objets magiques, le niveau d''un sort de niveau 0 est compté comme étant de 0,5.</p>
<p><strong>Niveau de lanceur de sorts.</strong> Le niveau de lanceur de sorts de la plupart des objets magiques est fixé dans leur description. Mais dans le cas des baguettes, des parchemins, des potions et des huiles, le personnage peut les créer avec n''importe quel niveau de lanceur de sorts compris entre le sien propre et le niveau minimal qui lui est nécessaire pour lancer le sort en question. Comme toutes les classes ne disposent pas des différents sorts au même niveau, le prix d''un objet de ces catégories peut varier selon leur créateur.</p>
<p><strong>Dons de métamagie.</strong> Les baguettes, bâtons, parchemins, potions et huiles peuvent aussi contenir des sorts modifiés par des dons de métamagie, mais c''est alors leur niveau de sort effectif qui est pris en compte plutôt que leur niveau réel (que ce soit pour calculer le prix de l''objet ou la possibilité de le placer dans une baguette, une potion ou une huile). De plus, le niveau de lanceur de sorts de l''objet doit alors être suffisant pour lancer le sort à son nouveau niveau. Par exemple, une baguette peut contenir un sort à effet étendu (affecté par Extension d''effet), mais son niveau effectif est alors augmenté de 2.</p>
<h3>Conditions de travail</h3>
<p>Le créateur de l''objet a besoin de travailler dans un lieu calme, confortable et bien éclairé. Tout endroit où l''on peut préparer ses sorts permet également de fabriquer un objet magique.</p>
<p>On considère que le personnage travaille à la création de l''objet pendant 8 heures par jour. Il lui est impossible de gagner du temps en faisant davantage d''heures. Néanmoins, les jours de travail n''ont pas besoin d''être consécutifs et le créateur peut faire ce qu''il désire pendant les 16 autres heures de la journée. Un personnage faisant une pause dans son travail, par exemple pour partir à l''aventure, doit garder le compte des journées déjà effectuées sur cet objet.</p>
<p>Un personnage ne peut travailler que sur un seul objet magique dans une journée donnée. Cependant, il peut avoir plusieurs projets en cours et alterner sa progression de l''un à l''autre selon les jours.</p>
<h3>Résumé des coûts de création</h3>
<p>[[tab:resume-couts-creation-objets-magiques]]</p>',
        10, @ddver, @res, NULL, 1, @now, @now);
SET @r_conditions_et_couts_de_creation := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_creation_d_objets_magiques, 'regle', 'Création selon la catégorie d''objet', 'creation-par-categorie',
'<h3>Anneaux magiques</h3>
<p>Pour fabriquer un anneau magique, un personnage doit avoir accès à une source de chaleur. Il lui faut également certains matériaux, dont celui qui servira à créer l''anneau. Le coût de ces matériaux est inclus dans le coût de création.</p>
<p><strong>Conditions.</strong> Le créateur d''un anneau doit posséder le don Création d''anneaux magiques. La création de chaque anneau s''accompagne de conditions supplémentaires.</p>
<p><strong>Prix.</strong> Le prix de base d''un anneau magique est généralement égal à son prix de vente, qui est indiqué dans sa description. Lorsque ce n''est pas le cas, la description comprend également le détail du coût de création total. Il n''existe pas de formule unique permettant de calculer le prix des anneaux. Référez-vous à la section <em>Estimation du prix des objets magiques</em> et prenez exemple sur les autres anneaux.</p>
<h3>Armes magiques</h3>
<p>Pour pouvoir fabriquer une arme magique, un personnage a besoin d''une source de chaleur et des outils nécessaires au travail du métal, du bois ou du cuir, selon le matériau employé. Il doit également avoir accès aux divers matériaux de fabrication, dont l''arme elle-même ou les pièces qui permettront de la constituer. Le coût des matériaux secondaires est inclus dans le coût de création.</p>
<p>C''est au moment de la fabrication que le personnage décide si l''arme émettra de la lumière ou non. Ce choix n''affecte pas le prix ni le temps de création, mais une fois l''arme achevée, il devient irrévocable.</p>
<p>La création d''armes doubles magiques est considérée comme une création de deux armes magiques distinctes pour ce qui est du coût (en po et en PX), du temps passé et des propriétés de l''arme.</p>
<p><strong>Conditions.</strong> Le créateur d''une arme doit posséder le don Création d''armes et armures magiques. De plus, le personnage doit avoir un niveau de lanceur de sorts au moins égal à 3 fois le bonus d''altération de l''arme (le bonus virtuel d''une propriété spéciale n''est pas pris en compte pour ce calcul). Chaque propriété spéciale impose d''autres conditions qui s''ajoutent aux précédentes.</p>
<p><strong>Prix.</strong> Le prix de base d''une arme magique dépend de son bonus d''altération et de ses propriétés spéciales. Le prix de vente final est égal au prix de base plus le prix de l''arme de maître.</p>
<p><strong>Coût d''objet.</strong> On ne peut rendre magique qu''une arme de maître, et son prix vient s''ajouter au coût de création.</p>
<h3>Armures et boucliers magiques</h3>
<p>Pour pouvoir fabriquer une armure ou un bouclier magique, un personnage a besoin d''une source de chaleur et des outils nécessaires au travail du métal, du bois ou du cuir, selon le matériau employé. Il doit également avoir accès aux divers matériaux de fabrication, dont l''armure ou le bouclier lui-même ou les pièces qui permettront de le constituer. Le coût des matériaux secondaires est inclus dans le coût de création.</p>
<p><strong>Conditions.</strong> Le créateur d''une armure ou d''un bouclier doit posséder le don Création d''armes et armures magiques. De plus, le personnage doit avoir un niveau de lanceur de sorts au moins égal à 3 fois le bonus d''altération de l''armure ou du bouclier (le bonus virtuel d''une propriété spéciale n''est pas pris en compte pour ce calcul). Chaque propriété spéciale impose d''autres conditions qui s''ajoutent aux précédentes.</p>
<p><strong>Prix.</strong> Le prix de base d''une armure ou d''un bouclier magique dépend de son bonus d''altération et de ses propriétés spéciales. Le prix de vente final est égal au prix de base plus le prix de l''armure ou du bouclier de maître.</p>
<p><strong>Coût d''objet.</strong> On ne peut rendre magique qu''une armure ou un bouclier de maître, et son prix vient s''ajouter au coût de création.</p>
<h3>Baguettes magiques</h3>
<p>Le personnage a besoin de quelques matériaux, dont celui dans lequel la baguette sera taillée. Le coût de ces matériaux est inclus dans le coût de création. Une baguette nouvellement créée renferme toujours le maximum de charges (50).</p>
<p><strong>Conditions.</strong> Le créateur d''une baguette doit posséder le don Création de baguettes magiques et son niveau de lanceur de sorts doit être au moins égal à celui qu''il souhaite donner à la baguette. Le sort que va contenir la baguette est évidemment requis.</p>
<p><strong>Prix.</strong> Les tables suivantes indiquent le prix de base et le coût de base de création d''une baguette préparée au niveau de lanceur de sorts minimal. De façon générale, le prix de base d''une baguette est égal au niveau de sort × le niveau de lanceur de sorts × 750 po.</p>
<p><strong>Coût de composante.</strong> Le créateur d''une baguette doit fournir assez de composantes matérielles et sacrifier assez de PX pour lancer 50 fois le sort que l''objet va contenir.</p>
<p>[[tab:prix-base-baguettes]]</p>
<p>[[tab:cout-creation-baguettes]]</p>
<h3>Bâtons magiques</h3>
<p>Le personnage a besoin de divers matériaux, dont celui (ou ceux) qui lui permettront de fabriquer le bâton proprement dit. Le coût de ces matériaux est inclus dans le coût de création. Un bâton nouvellement créé renferme toujours le maximum de charges (50).</p>
<p>Le niveau de lanceur de sorts de toutes les fonctions d''un bâton doit être identique, et il ne doit pas être inférieur à 8 même si tous les sorts qu''il contient sont de bas niveau.</p>
<p><strong>Conditions.</strong> Le créateur d''un bâton doit posséder le don Création de bâtons magiques. Les sorts que le bâton va contenir sont évidemment requis. La création de certains bâtons s''accompagne de conditions supplémentaires.</p>
<p><strong>Prix.</strong> Le prix de base d''un bâton magique est généralement égal à son prix de vente, qui est indiqué dans sa description. Lorsque ce n''est pas le cas, la description comprend également le détail du coût de création total. De façon générale, le prix de base d''un bâton magique est égal à la formule suivante : (375 po × niveau du plus puissant sort × niveau de lanceur de sorts) + 75 % de la valeur de la propriété suivante en termes de puissance (282,5 po × niveau de sort × niveau de lanceur de sorts) + 50 % de la valeur de toutes les propriétés restantes (soit, pour chacune, 187,5 po × niveau de sort × niveau de lanceur de sorts). Il est possible de placer un sort dans le bâton à la moitié du coût normal mais, dans ce cas, chaque activation du sort coûte 2 charges au lieu d''une.</p>
<p><strong>Coût de composante.</strong> Le créateur d''un bâton doit fournir assez de composantes matérielles et sacrifier assez de PX pour lancer 50 fois (pour un sort coûtant une charge) ou 25 fois (pour un sort coûtant deux charges) chaque sort que l''objet va contenir.</p>
<h3>Objets merveilleux</h3>
<p>Pour créer un objet merveilleux, un personnage a souvent besoin d''outils permettant de travailler les matériaux entrant dans la composition de l''objet. Il doit également avoir accès à ces matériaux, lesquels sont inclus dans le coût de fabrication.</p>
<p><strong>Conditions.</strong> Le créateur d''un objet merveilleux doit posséder le don Création d''objets merveilleux. La création de chaque objet merveilleux s''accompagne de conditions supplémentaires.</p>
<p><strong>Prix.</strong> Le prix de base d''un objet merveilleux est généralement égal à son prix de vente, qui est indiqué dans sa description. Lorsque ce n''est pas le cas, la description comprend également le détail du coût de création total. Il n''existe pas de formule unique permettant de calculer le prix des objets merveilleux. Référez-vous à la section <em>Estimation du prix des objets magiques</em> et prenez exemple sur les autres objets.</p>
<h3>Parchemins magiques</h3>
<p>Le personnage a besoin de tout un matériel d''écriture, dont le prix est inclus dans le coût de création du parchemin. Tous les ustensiles et ingrédients doivent être neufs et ne jamais avoir servi. Le personnage doit acquitter le coût total à chaque fois qu''il écrit un parchemin, même s''il a déjà créé le même parchemin à de nombreuses reprises.</p>
<p><strong>Conditions.</strong> Le créateur d''un parchemin doit posséder le don Écriture de parchemins et son niveau de lanceur de sorts doit être au moins égal à celui qu''il souhaite donner au parchemin. Le sort à écrire sur le parchemin est évidemment requis.</p>
<p><strong>Prix.</strong> Les tables suivantes indiquent le prix de base et le coût de base d''écriture d''un parchemin écrit au niveau de lanceur de sorts minimal. De façon générale, le prix de base d''un parchemin est égal au niveau de sort × le niveau de lanceur de sorts × 25 po.</p>
<p><strong>Coût de composante.</strong> Le créateur d''un parchemin doit fournir assez de composantes matérielles et sacrifier assez de PX pour lancer le sort qui y sera écrit.</p>
<p>[[tab:prix-base-parchemins]]</p>
<p>[[tab:cout-creation-parchemins]]</p>
<h3>Potions et huiles magiques</h3>
<p>Le personnage a besoin d''une surface plane sur laquelle travailler, de plusieurs récipients dans lesquels mélanger divers liquides, et d''une source de chaleur pour chauffer ses mixtures. Il lui faut également de nombreux ingrédients, dont le coût est inclus dans celui qui est indiqué pour la préparation de chaque potion ou huile. Tous les ingrédients utilisés pour concocter une potion doivent être neufs et ne jamais avoir servi. Le coût de chaque potion reste le même quelle que soit la quantité préparée.</p>
<p>La personne buvant une potion est considérée à la fois comme le lanceur et la cible de l''effet du sort. Les sorts dont la portée est personnelle ne peuvent pas non plus être utilisés par l''intermédiaire d''une potion. Seuls les sorts dont la cible est un objet peuvent être placés dans des huiles.</p>
<p><strong>Conditions.</strong> Le créateur d''une potion ou d''une huile doit posséder le don Préparation de potions et son niveau de lanceur de sorts doit être au moins égal à celui qu''il souhaite donner à la potion ou à l''huile. Le sort à préparer dans la potion ou l''huile est évidemment requis.</p>
<p><strong>Prix.</strong> Les tables suivantes indiquent le prix de base et le coût de base de préparation d''une potion ou d''une huile préparée au niveau de lanceur de sorts minimal. De façon générale, le prix de base d''une potion ou d''une huile est égal au niveau de sort × le niveau de lanceur de sorts × 50 po.</p>
<p><strong>Coût de composante.</strong> Le préparateur d''une potion ou d''une huile doit fournir assez de composantes matérielles et sacrifier assez de PX pour lancer le sort qui y sera écrit.</p>
<p><strong>Temps de création.</strong> La préparation d''une potion ou d''une huile prend toujours une journée, quel que soit son prix de base.</p>
<p>[[tab:prix-base-potions-huiles]]</p>
<p>[[tab:cout-creation-potions-huiles]]</p>
<h3>Sceptres magiques</h3>
<p>Le personnage a besoin de divers matériaux, dont celui (ou ceux) qui lui permettront de fabriquer le sceptre proprement dit. Le coût de ces matériaux est inclus dans le coût de création.</p>
<p><strong>Conditions.</strong> Le créateur d''un sceptre doit posséder le don Création de sceptres magiques. La création de chaque sceptre s''accompagne de conditions supplémentaires.</p>
<p><strong>Prix.</strong> Le prix de base d''un sceptre magique est généralement égal à son prix de vente, qui est indiqué dans sa description. Lorsque ce n''est pas le cas, la description comprend également le détail du coût de création total. Il n''existe pas de formule unique permettant de calculer le prix des sceptres. Référez-vous à la section <em>Estimation du prix des objets magiques</em> et prenez exemple sur les autres sceptres.</p>',
        20, @ddver, @res, NULL, 1, @now, @now);
SET @r_creation_par_categorie := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_creation_d_objets_magiques, 'regle', 'Objets intelligents et ajout de propriétés', 'objets-intelligents-et-ajout-de-proprietes',
'<h3>Création d''objets intelligents</h3>
<p>La fabrication d''un objet intelligent nécessite un niveau de lanceur de sorts au moins égal à 15. Le temps et le coût de création correspondent à celui du type d''objet choisi, en prenant en compte les modificateurs au prix de base indiqués sur la table de l''Intelligence, de la Sagesse, du Charisme et des propriétés des objets intelligents et sur les tables de pouvoirs mineurs, majeurs et dédiés. L''alignement de l''objet est le même que celui du personnage.</p>
<h3>Ajout de nouvelles propriétés</h3>
<p>On peut ajouter autant de propriétés qu''on le souhaite à un objet magique, sans aucune limite. Dans ce cas, le coût de création est calculé en faisant la différence entre les pouvoirs que l''on souhaite obtenir et ceux que l''objet possède déjà. Ainsi, une épée longue +1 peut être transformée en épée longue +2 vorpale. Le personnage désirant le faire devra débourser le coût de création normal d''une épée longue +2 vorpale moins le coût de fabrication d''une épée longue +1.</p>
<p>Si l''on souhaite ajouter une fonction à un objet occupant un emplacement sur le corps de son porteur (voir <em>Emplacements des objets magiques sur le corps</em>), son prix de base est doublé. Par exemple, si un aventurier désire ajouter le pouvoir d''invisibilité à son anneau de protection +2, il lui en coûtera autant que s''il voulait créer deux anneaux d''invisibilité.</p>',
        30, @ddver, @res, NULL, 1, @now, @now);
SET @r_objets_intelligents_et_ajout_de_proprietes := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_creation_d_objets_magiques, 'regle', 'Estimation du prix des objets magiques', 'estimation-du-prix-des-objets-magiques',
'<p>De nombreux facteurs doivent être pris en compte pour calculer le prix des objets magiques de votre invention. Le moyen le plus simple consiste à trouver un objet similaire et à vous baser sur son prix, mais ce n''est pas toujours simple ou possible.</p>
<p><strong>Prix de chaque effet.</strong> Les objets magiques peuvent avoir deux types d''effets : soit conférer un bonus au porteur, soit reproduire les effets d''un sort. Le prix de base d''un effet du premier type dépend de la nature du bonus (altération, chance, etc.) et de sa destination (jets d''attaque, CA, etc.). Le prix de base d''un effet similaire à un sort dépend du niveau du sort, du niveau de lanceur de sorts de l''objet, mais aussi de la méthode d''activation (fin d''incantation, usage, etc.). (Attention, dans le cas où l''effet d''un sort est d''attribuer un bonus, comme <em>force de taureau</em>, le coût de l''effet doit être calculé selon la première méthode, et pas la seconde.) Effectuez votre calcul en vous référant à la table ci-dessous.</p>
<p>[[tab:estimation-prix-objets-magiques]]</p>
<p><strong>Objets à effets multiples.</strong> Pour calculer le prix de base total d''un objet ayant plusieurs effets, il faut d''abord calculer le prix de base individuel de chaque effet. La formule dépend ensuite de la nature de l''objet et de l''homogénéité des pouvoirs.</p>
<p><em>Objets occupant un emplacement sur le corps de leur porteur.</em> Le prix de base total est égal au prix de l''effet le plus élevé, plus deux fois le prix des autres effets.</p>
<p><em>Objets n''occupant pas d''emplacement sur le corps de leur utilisateur.</em> Si les effets ne sont pas similaires, le prix de base total est simplement la somme du prix des différents effets. Si les effets sont homogènes, le prix de base total est égal au prix de l''effet le plus coûteux, plus 75 % du prix du deuxième effet en terme de coût, plus 50 % du prix des autres pouvoirs. (Cela correspond au mode de calcul des bâtons.)</p>
<p><strong>Spécial.</strong> Plusieurs critères peuvent modifier le prix de base de l''effet, dans un sens ou dans l''autre. Par exemple, si l''objet ne peut être utilisé qu''une fois par jour, son prix est divisé par 5, mais, s''il n''occupe pas d''emplacement sur le corps de son utilisateur, son prix est doublé. Là encore, suivez les indications de la table.</p>
<p><strong>Coûts supplémentaires.</strong> La création de l''objet magique peut exiger des coûts supplémentaires.</p>
<p><strong>Coût de création.</strong> Le coût de création d''un objet est de la moitié de son prix de base en po (plus éventuellement le coût d''objet ou le coût de composante en po), plus 1/25e de son prix de base en PX (plus éventuellement le coût des composantes de PX) et à 1 jour de travail par tranche de 1 000 po du prix de base.</p>
<p><strong>Prix de vente final.</strong> Le prix de vente final d''un objet est égal à son prix de base plus un éventuel coût d''objet, plus un éventuel coût de composante en po, plus 5 fois un éventuel coût de composante en PX.</p>
<p><strong>Ajustements finaux.</strong> Vous remarquerez sans doute que tous les objets n''obéissent pas parfaitement à ces règles. En effet, les formules énoncées plus haut ne suffisent pas pour évaluer les mérites respectifs de deux objets très différents. Tous les objets magiques ont été estimés en fonction de leur valeur réelle en jeu.</p>
<p>Les formules ne constituent qu''un point de départ, un guide plus qu''une règle. Baguettes, parchemins, potions et huiles suivent exactement les règles indiquées. Les bâtons les suivent presque systématiquement. Mais pour les autres types d''objets, il est préférable de procéder au cas par cas. Sachez faire preuve de bon sens, en vous appuyant sur les nombreux exemples d''objets.</p>
<p>En aucun cas vous ne devez accepter tel quel un objet magique proposé par un joueur sans l''examiner attentivement, et cela même s''il a utilisé les formules précédentes. Une épée bénéficiant d''un effet continu de <em>coup au but</em>, une cape conférant des effets permanents d''<em>invisibilité suprême</em>, ou une ceinture pouvant lancer <em>guérison suprême</em> sur commande restent inacceptables, même si on peut calculer leur coût théorique à l''aide de ces règles.</p>',
        40, @ddver, @res, NULL, 1, @now, @now);
SET @r_estimation_du_prix_des_objets_magiques := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_objets_magiques, 'regle', 'Catalogue des objets magiques', 'catalogue-des-objets-magiques',
'<p>Les listes ci-dessous sont produites à partir du compendium et se mettent à jour d''elles-mêmes. Chaque ligne ouvre la fiche de l''objet. Pour restreindre l''affichage à une source, utilisez le paramètre <code>source</code> du tag de liste.</p>
<h3>Anneaux</h3>
<p>[[liste:objet|famille=anneaux]]</p>
<h3>Armes</h3>
<p>[[liste:objet|famille=armes]]</p>
<h3>Armures et boucliers</h3>
<p>[[liste:objet|famille=armures-et-boucliers]]</p>
<h3>Baguettes</h3>
<p>[[liste:objet|famille=baguettes]]</p>
<h3>Bâtons</h3>
<p>[[liste:objet|famille=batons]]</p>
<h3>Objets merveilleux</h3>
<p>[[liste:objet|famille=objets-merveilleux]]</p>
<h3>Parchemins</h3>
<p>[[liste:objet|famille=parchemins]]</p>
<h3>Potions et huiles</h3>
<p>[[liste:objet|famille=potions-et-huiles]]</p>
<h3>Sceptres</h3>
<p>[[liste:objet|famille=sceptres]]</p>
<h3>Objets maudits</h3>
<p>[[liste:objet|famille=objets-maudits]]</p>
<h3>Artefacts</h3>
<p>[[liste:objet|famille=artefacts-mineurs,artefacts-majeurs]]</p>',
        100, @ddver, @res, NULL, 1, @now, @now);
SET @r_catalogue_des_objets_magiques := LAST_INSERT_ID();

-- Tableaux (convention texte, SP-TB)
INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note,
                         tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible,
                         tab_date_creation, tab_date_modif)
VALUES
('ecole-objet-magique', 'École d''un objet magique sans sort requis',
'! Nature de l''objet | École
Arme ou objet d''attaque | Évocation
Armure ou objet de protection | Abjuration
Objet conférant un bonus à une caractéristique, à un test de compétence, etc. | Transmutation',
'll', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('determination-aleatoire-objets-magiques', 'Détermination aléatoire des objets magiques',
'! Faible | Intermédiaire | Puissant | Catégorie d''objets
01–02 | 01–10 | 01–10 | Anneaux
03–07 | 11–20 | 11–20 | Armes
08–11 | 21–30 | 21–30 | Armures et boucliers
12–21 | 31–45 | 31–35 | Baguettes
— | 46–48 | 36–55 | Bâtons
22–30 | 49–65 | 56–75 | Objets merveilleux
31–65 | 66–80 | 76–85 | Parchemins
66–100 | 81–90 | 86–90 | Potions et huiles
— | 91–100 | 91–100 | Sceptres',
'cccl', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('affinites-emplacements-corps', 'Affinités des emplacements sur le corps',
'! Emplacement sur le corps | Affinité
Bandeau, casque | Amélioration de l''esprit, attaques à distance
Couvre-chef | Interaction sociale
Phylactère | Moral, alignement
Lentilles, lunettes | Vue
Cape, manteau, écharpe | Transformation, protection
Amulette, broche, médaillon, collier, charme, scarabée | Protection, discernement
Robe | Effets multiples
Chemise | Amélioration du corps
Gilet, chasuble | Amélioration des aptitudes de classe
Bracelets | Combat, alliés
Gants | Précision
Gantelets | Puissance destructive
Ceinture | Amélioration du corps
Bottes | Déplacement',
'll', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('resume-couts-creation-objets-magiques', 'Résumé des coûts de création des objets magiques',
'! Catégorie d''objet | Don requis | Prix de base | Coût de création de base | Coût d''objet | Coût de composantes | Prix de vente
Anneau | Création d''anneaux magiques | Variable, voir la table d''estimation du prix des objets magiques | Prix de base/2 en po, prix de base/25 en PX | Non¹ | Non¹ | Prix de base
Arme | Création d''armes et armures magiques | Selon la table des armes | Prix de base/2 en po, prix de base/25 en PX | Oui (arme de maître) | Non¹ | Prix de base + coût d''objet
Armure ou bouclier | Création d''armes et armures magiques | Selon la table des armures et boucliers | Prix de base/2 en po, prix de base/25 en PX | Oui (armure ou bouclier de maître) | Non¹ | Prix de base + coût d''objet
Baguette | Création de baguettes magiques | 750 × niveau de sort × niveau de lanceur de sorts | Prix de base/2 en po, prix de base/25 en PX | Non¹ | Oui (50 fois) | Prix de base + coût des composantes (1 PX = 5 po)
Bâton | Création des bâtons magiques | Spécial | Prix de base/2 en po, prix de base/25 en PX | Non¹ | Oui (50 ou 25 fois) | Prix de base + coût des composantes (1 PX = 5 po)
Objet merveilleux | Création d''objets merveilleux | Variable, voir la table d''estimation du prix des objets magiques | Prix de base/2 en po, prix de base/25 en PX | Non¹ | Non | Prix de base
Parchemin | Écriture de parchemins | 25 × niveau de sort × niveau de lanceur de sorts | Prix de base/2 en po, prix de base/25 en PX | Non¹ | Oui (1 fois) | Prix de base + coût des composantes (1 PX = 5 po)
Potion ou huile | Préparation de potions | 50 × niveau de sort × niveau de lanceur de sorts | Prix de base/2 en po, prix de base/25 en PX | Non¹ | Oui (1 fois) | Prix de base + coût des composantes (1 PX = 5 po)
Sceptre | Création de sceptres magiques | Variable, voir la table d''estimation du prix des objets magiques | Prix de base/2 en po, prix de base/25 en PX | Non¹ | Non¹ | Prix de base',
'llllllll', '¹ Aucun en règle générale, mais des exceptions peuvent exister (voir Coûts supplémentaires).', @ddver, @res, NULL, 0, 0, 1, @now, @now),
('prix-base-baguettes', 'Prix de base des baguettes',
'! | Classe | | |
! Niveau du sort | Dru, Mag, Prê | Ens | Bard | Pal, Rôd
0 | 375 po | 375 po | 375 po | —
1 | 750 po | 750 po | 1 500 po | 1 500 po
2 | 4 500 po | 6 000 po | 6 000 po | 6 000 po
3 | 11 250 po | 13 500 po | 15 750 po | 11 250 po
4 | 21 000 po | 24 000 po | 30 000 po | 21 000 po',
'lrrrr', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('cout-creation-baguettes', 'Coût de base de création des baguettes',
'! | Classe | | |
! Niveau du sort | Dru, Mag, Prê | Ens | Bard | Pal, Rôd
0 | 187 po, 5 pa + 15 PX | 187 po, 5 pa + 15 PX | 187 po, 5 pa + 15 PX | —
1 | 375 po + 30 PX | 375 po + 30 PX | 750 po + 60 PX | 750 po + 60 PX
2 | 2 250 po + 180 PX | 3 000 po + 240 PX | 3 000 po + 240 PX | 3 000 po + 240 PX
3 | 5 625 po + 450 PX | 6 750 po + 540 PX | 7 875 po + 630 PX | 5 625 po + 450 PX
4 | 10 500 po + 840 PX | 12 000 po + 960 PX | 15 000 po + 1 200 PX | 10 500 po + 840 PX',
'lrrrr', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('prix-base-parchemins', 'Prix de base des parchemins',
'! | Classe | | |
! Niveau du sort | Dru, Mag, Prê | Ens | Bard | Pal, Rôd
0 | 12 po, 5 pa | 12 po, 5 pa | 12 po, 5 pa | —
1 | 25 po | 25 po | 50 po | 50 po
2 | 150 po | 200 po | 200 po | 200 po
3 | 375 po | 450 po | 525 po | 375 po
4 | 700 po | 800 po | 1 000 po | 700 po
5 | 1 125 po | 1 250 po | 1 625 po | —
6 | 1 650 po | 1 800 po | 2 400 po | —
7 | 2 275 po | 2 450 po | — | —
8 | 3 000 po | 3 200 po | — | —
9 | 3 825 po | 4 050 po | — | —',
'lrrrr', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('cout-creation-parchemins', 'Coût de base de création des parchemins',
'! | Classe | | |
! Niveau du sort | Dru, Mag, Prê | Ens | Bard | Pal, Rôd
0 | 6 po, 2 pa, 5 pc + 1 PX | 6 po, 2 pa, 5 pc + 1 PX | 6 po, 2 pa, 5 pc + 1 PX | —
1 | 12 po, 5 pa + 1 PX | 12 po, 5 pa + 1 PX | 25 po + 2 PX | 25 po + 2 PX
2 | 75 po + 6 PX | 100 po + 8 PX | 100 po + 8 PX | 100 po + 8 PX
3 | 187 po, 5 pa + 15 PX | 225 po + 18 PX | 262 po, 5 pa + 21 PX | 187 po, 5 pa + 15 PX
4 | 350 po + 28 PX | 400 po + 32 PX | 500 po + 40 PX | 350 po + 28 PX
5 | 562 po, 5 pa + 45 PX | 625 po + 50 PX | 812 po, 5 pa + 65 PX | —
6 | 825 po + 66 PX | 900 po + 72 PX | 1 200 po + 96 PX | —
7 | 1 137 po, 5 pa + 91 PX | 1 225 po + 98 PX | — | —
8 | 1 500 po + 120 PX | 1 600 po + 128 PX | — | —
9 | 1 912 po, 5 pa + 153 PX | 2 025 po + 162 PX | — | —',
'lrrrr', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('prix-base-potions-huiles', 'Prix de base des potions et des huiles',
'! | Classe | | |
! Niveau du sort | Dru, Mag, Prê | Ens | Bard | Pal, Rôd
0 | 25 po | 25 po | 25 po | —
1 | 50 po | 50 po | 100 po | 100 po
2 | 300 po | 400 po | 400 po | 400 po
3 | 750 po | 900 po | 1 050 po | 750 po',
'lrrrr', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('cout-creation-potions-huiles', 'Coût de base de création des potions et des huiles',
'! | Classe | | |
! Niveau du sort | Dru, Mag, Prê | Ens | Bard | Pal, Rôd
0 | 12 po, 5 pa + 1 PX | 12 po, 5 pa + 1 PX | 12 po, 5 pa + 1 PX | —
1 | 25 po + 2 PX | 25 po + 2 PX | 50 po + 4 PX | 50 po + 4 PX
2 | 150 po + 12 PX | 200 po + 16 PX | 200 po + 16 PX | 200 po + 16 PX
3 | 375 po + 30 PX | 450 po + 36 PX | 525 po + 42 PX | 375 po + 30 PX',
'lrrrr', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('estimation-prix-objets-magiques', 'Estimation du prix des objets magiques',
'! Effet | Prix de base
# Effets conférant un bonus
Bonus à l''armure naturelle (altération) | Bonus au carré × 2 000 po
Bonus à la CA (parade) | Bonus au carré × 2 000 po
Bonus à la CA (autre¹) | Bonus au carré × 2 500 po
Bonus à une armure (altération) | Bonus au carré × 1 000 po
Bonus à une arme (altération) | Bonus au carré × 2 000 po
Bonus à une caractéristique (altération) | Bonus au carré × 1 000 po
Bonus à une compétence (aptitude) | Bonus au carré × 100 po
Bonus aux sauvegardes (résistance) | Bonus au carré × 1 000 po
Bonus aux sauvegardes (autre¹) | Bonus au carré × 2 000 po
Résistance à la magie | 10 000 po par point au-dessus de RM 12 (RM 13 minimum)
Sort en bonus | Niveau de sort au carré × 1 000 po
# Effets de type sort
Usage unique, fin d''incantation | Niveau du sort × niveau du lanceur de sorts × 25 po
Usage unique, usage | Niveau du sort × niveau du lanceur de sorts × 50 po
50 charges, potentiel magique | Niveau du sort × niveau du lanceur de sorts × 750 po
Illimité, mot de commande | Niveau du sort × niveau du lanceur de sorts × 1 800 po
Illimité, usage ou continu | Niveau du sort × niveau du lanceur de sorts × 2 000 po²
# Spécial (ajustement au prix de base)
Changer illimité en 1 à 4 charges par jour | Multiplier par 0,2 (1 charge), 0,4 (2), 0,6 (3) ou 0,8 (4)
Changer illimité en 50 charges | Multiplier par 0,5
Emplacement inhabituel³ | Multiplier par 1,5
N''occupe pas d''emplacement⁴ | Multiplier par 2
Requiert une compétence | Multiplier par 0,9
Requiert une race ou une classe | Multiplier par 0,7
# Objet ou composante (coût supplémentaire)
Arme, armure ou bouclier | Ajouter le coût d''un objet de maître
Sort à composantes coûteuses | Ajouter le prix des composantes pour chaque charge⁵
Sort exigeant des PX | Ajouter 5 po par PX et par charge⁵
> ¹ Comme un bonus de chance, d''intuition, sacré ou de malfaisance.
> ² Le prix d''un effet continu dépend de la durée du sort. Si elle est exprimée en rounds, le prix est multiplié par 4. Si elle est de 1 minute/niveau, il est multiplié par 2. Si elle est de 10 minutes/niveau, il est multiplié par 1,5. Si elle est de 24 heures ou plus, il est divisé par deux.
> ³ Voir Affinités des emplacements sur le corps.
> ⁴ Voir Emplacements des objets magiques sur le corps.
> ⁵ Si l''objet est à usage continu ou illimité, déterminez son prix comme s''il avait 100 charges. Si son utilisation obéit à une limite quotidienne, considérez qu''il a 50 charges.',
'll', 'Niveau du sort : un sort du niveau 0 vaut deux fois moins qu''un sort du 1er niveau pour ce qui est de déterminer le prix de l''objet.', @ddver, @res, NULL, 0, 0, 1, @now, @now);

-- Glossaire
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES
(@glo, 'glossaire', 'Objet à fin d''incantation', 'objet-a-fin-d-incantation', '<p>Objet (le parchemin) dont l''utilisateur achève l''incantation : le sort doit figurer sur la liste d''une de ses classes. Action simple qui provoque une attaque d''opportunité. Voir <em>Utilisation des objets</em>.</p>', 130, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Objet à potentiel magique', 'objet-a-potentiel-magique', '<p>Objet dont l''utilisateur prononce le mot déclencheur : le sort doit figurer sur la liste de sorts de sa classe (même s''il ne lance pas encore de sorts). Action simple, sans attaque d''opportunité. Voir <em>Utilisation des objets</em>.</p>', 140, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Objet à mot de commande', 'objet-a-mot-de-commande', '<p>Objet dont le pouvoir se déclenche quand l''utilisateur prononce le mot voulu, sans connaissance magique. Action simple, sans attaque d''opportunité. Voir <em>Utilisation des objets</em>.</p>', 150, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Objet à usage', 'objet-a-usage', '<p>Objet dont il suffit de se servir normalement (boire, porter, brandir…) pour que son pouvoir prenne effet. Voir <em>Utilisation des objets</em>.</p>', 160, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Niveau de lanceur de sorts (NLS)', 'niveau-de-lanceur-de-sorts-d-un-objet', '<p>Niveau de lanceur de sorts d''un objet magique, noté « NLS X » : il fixe son bonus de base aux jets de sauvegarde (2 + moitié du NLS), la portée et les dégâts de ses effets, et le niveau auquel il est pris pour cible par une dissipation de la magie. Voir <em>Description des objets magiques</em>.</p>', 170, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Aura d''un objet magique', 'aura-d-un-objet-magique', '<p>École et intensité de la magie d''un objet, révélées par <em>détection de la magie</em>. Voir <em>Détection de la magie et objets magiques</em>.</p>', 180, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Charges (objet magique)', 'charge-d-un-objet', '<p>Limite d''utilisations d''un objet (50 au maximum en général pour baguettes et bâtons). Le prix de vente diminue proportionnellement aux charges utilisées. Voir <em>Charges, doses et usage limité</em>.</p>', 190, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Prix de base (objet magique)', 'prix-de-base-d-un-objet-magique', '<p>Prix qui tient uniquement compte de la magie nécessaire, hors coût d''objet, composantes coûteuses et PX supplémentaires. Les coûts de création en découlent : moitié en po, 1/25e en PX et 1 jour de travail par 1 000 po. Voir <em>Conditions et coûts de création</em>.</p>', 200, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Emplacement (objet magique)', 'emplacement-d-un-objet-magique', '<p>Partie du corps où un objet magique doit être porté pour fonctionner (tête, yeux, cou, torse, corps, taille, épaules, bras, mains, doigts, pieds) : deux objets portés l''un sur l''autre s''annulent. Voir <em>Emplacements des objets magiques sur le corps</em>.</p>', 210, @ddver, @res, NULL, 1, @now, @now);

COMMIT;
