-- sql/2026-10-11_regles_dd35_drs07_sp-drs2.sql
-- SP-DRS2 — DRS 07 : Équipement
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

-- Place pour les racines « Équipement » (40) et « Objets magiques » (50) : les créatures passent à 60.
UPDATE dd_regles SET reg_ordre = 60
WHERE  reg_slug = 'creatures-et-pouvoirs-speciaux' AND reg_ruleset_var_id = @ddver AND reg_ordre = 40;

-- Réinitialisation idempotente
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'lancement-de-sorts-et-services';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'bardes-et-montures';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'liste-des-marchandises-et-services';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'marchandises-et-services';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'enfiler-ou-oter-son-armure';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'armures-pour-creatures-inhabituelles';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'armures-de-maitre';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'liste-des-armures-et-boucliers';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'attributs-des-armures';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'les-armures-et-boucliers';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'armes-de-maitre';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'liste-des-armes';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'attributs-des-armes';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'categories-d-armes';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'les-armes';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'la-richesse-et-l-argent';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'equipement';
DELETE FROM dd_regles
WHERE  reg_ruleset_var_id = @ddver AND reg_type = 'glossaire' AND reg_reg_id = @glo
  AND  reg_slug IN (
    'arme-a-allonge',
    'arme-double',
    'arme-de-jet',
    'arme-a-projectiles',
    'arme-improvisee',
    'arme-de-maitre',
    'armure-de-maitre',
    'munition',
    'facteur-de-portee',
    'malus-d-armure-aux-tests',
    'risque-d-echec-des-sorts-profanes',
    'bonus-de-dexterite-maximal');
DELETE FROM dd_tableaux
WHERE  tab_ruleset_var_id = @ddver
  AND  tab_slug IN (
    'types-de-pieces',
    'produits-de-consommation-courante',
    'degats-armes-tp-g',
    'armures-creatures-inhabituelles',
    'enfiler-oter-armure',
    'vitesse-montures-barde');

-- Nœuds
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (NULL, 'chapitre', 'Équipement', 'equipement',
'<p>Tout ce que le personnage possède et peut acheter : l''argent, les armes, les armures et boucliers, les marchandises, les montures, les moyens de transport et les services. Les règles de ce chapitre décrivent les mécanismes ; les <strong>listes d''équipements</strong> qu''il contient sont toujours à jour : elles proviennent du compendium, où chaque article a sa fiche (prix, poids, caractéristiques et description propre).</p>
<p>Considérez que votre personnage possède au moins une tenue normale.</p>',
        40, @ddver, @res, NULL, 1, @now, @now);
SET @r_equipement := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_equipement, 'regle', 'La richesse et l''argent', 'la-richesse-et-l-argent',
'<h3>La monnaie</h3>
<p>Les aventuriers ont surtout recours à la pièce d''or (po). Une pièce d''or vaut 10 pièces d''argent. Chaque pièce d''argent vaut 10 pièces de cuivre (pc). Une pièce de platine (pp) vaut 10 po.</p>
<p>Une pièce pèse environ 10 grammes et une centaine de pièces pèse un kilo.</p>
<p>[[tab:types-de-pieces]]</p>
<h3>Richesses non monétaires</h3>
<p>Bien souvent, la richesse des gens ne se calcule pas en pièces. Le prix de certains produits de consommation courante est détaillé ci-dessous.</p>
<p>[[tab:produits-de-consommation-courante]]</p>
<h3>La revente du butin</h3>
<p>En règle générale, on peut revendre n''importe quel article à la moitié du prix indiqué. Les produits de consommation courante constituent l''exception à la règle. Ce terme regroupe toutes les marchandises pouvant être échangées sans la moindre difficulté, sans qu''il soit nécessaire de les monnayer.</p>',
        10, @ddver, @res, NULL, 1, @now, @now);
SET @r_la_richesse_et_l_argent := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_equipement, 'chapitre', 'Les armes', 'les-armes',
'<p>Les catégories d''armes, les caractéristiques que donne la liste des armes, et les règles propres aux armes de maître. La liste des armes et la description de chacune d''elles sont consultables dans le compendium.</p>',
        20, @ddver, @res, NULL, 1, @now, @now);
SET @r_les_armes := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_les_armes, 'regle', 'Catégories d''armes', 'categories-d-armes',
'<p>Les armes sont regroupées en diverses catégories entre lesquelles existent de nombreux recoupements. Ce sont elles qui déterminent quel talent est nécessaire pour utiliser l''arme en question (arme courante, de guerre ou exotique), si cette dernière est utilisable au corps à corps ou à distance (arme de jet ou à projectile), quel est son encombrement relatif (légère, une main et deux mains) et enfin quelle est sa taille (petite, moyenne ou grande).</p>
<h3>Armes courantes, de guerre ou exotiques</h3>
<p>Les personnages de toutes les classes, sauf les druides, moines et magiciens, sont formés au maniement de toutes les armes courantes. Les barbares, guerriers, paladins et rôdeurs, quant à eux, sont formés au maniement de la totalité des armes courantes ou de guerre. Les personnages des autres classes sont formés au maniement d''un assortiment d''armes principalement courantes, mais aussi de guerre et, parfois, exotiques. Quand un personnage utilise une arme au maniement de laquelle il n''est pas formé, il subit un malus de –4 aux jets d''attaque.</p>
<h3>Armes de corps à corps et armes à distance</h3>
<p>Les armes de corps à corps s''utilisent au contact de l''adversaire, même si certaines sont aussi des armes de jet. Pour leur part, les armes à distance sont totalement inefficaces au corps à corps. Elles peuvent être des armes de jet ou à projectile.</p>
<h3>Catégories spéciales</h3>
<p>Certaines armes peuvent appartenir à l''une des catégories suivantes, qui possèdent leurs propres règles.</p>
<p><strong>Armes à allonge.</strong> La catégorie des armes à allonge regroupe la chaîne cloutée, la corsèque, la coutille, le fouet, la guisarme, la lance d''arçon et la pique. Une arme à allonge est une arme de corps à corps qui permet à son utilisateur de frapper des cibles même si elles ne sont pas adjacentes. La plupart des armes à allonge ont pour effet de doubler l''allonge naturelle, ce qui signifie qu''un personnage de taille P ou M peut frapper une cible distante de 3 mètres, mais pas une cible sur une case adjacente. Un personnage standard de taille G peut utiliser une arme à allonge conçue pour sa taille pour attaquer une cible située à 6 ou 4,5 mètres, mais ne peut frapper une cible adjacente ou éloignée de 3 mètres.</p>
<p><strong>Armes doubles.</strong> La catégorie des armes doubles comprend le bâton, la double lame, le fléau double, la hache double orque, le marteau-piolet gnome et l''urgrosh nain. Il est possible de se servir des deux têtes d''une arme double comme si l''on se battait avec deux armes mais, dans ce cas, le personnage encourt les malus habituels du combat à deux armes, comme s''il utilisait une arme à une main et une arme légère.</p>
<p>Il est aussi possible d''utiliser une arme double comme une arme à deux mains, en frappant avec une seule des deux têtes. Une créature maniant une arme double à une main ne peut pas s''en servir comme d''une arme double ; elle doit choisir l''une des deux têtes et s''y tenir pour le round.</p>
<p><strong>Armes de jet.</strong> La catégorie des armes de jet comprend la dague, les dards, l''épieu, le filet, le gourdin, la hache de lancer, les javelines, la lance, le marteau léger, les shurikens et le trident. Le modificateur de Force de l''attaquant s''applique aux jets de dégâts des armes de jet (à l''exception des armes à impact).</p>
<p>Il est possible de lancer une arme, même si elle n''est pas prévue à cet effet (c''est-à-dire les armes de corps à corps de la liste des armes dont la colonne « Facteur de portée » indique « — »), mais avec un malus de –4 sur le jet d''attaque et un facteur de portée de 3 mètres. Lancer une arme légère ou à une main est une action simple, tandis que lancer une arme à deux mains est une action complexe. Quelle que soit la nature de l''arme, un tel lancer obtient un critique possible sur un 20 naturel et inflige des dégâts doublés en cas de critique confirmé.</p>
<p><strong>Armes à projectiles.</strong> Cette catégorie regroupe les arbalètes à répétition, de poing, légères et lourdes, les arcs courts, courts composites, longs et longs composites et la fronde. La plupart des armes à projectiles ne peuvent être utilisées qu''à deux mains. Le bonus de Force du tireur ne s''applique pas aux jets de dégâts des armes à projectiles, à l''exception des arcs courts composites spéciaux, des arcs longs composites spéciaux et des frondes. Un malus de Force s''applique aux jets de dégâts des arcs et des frondes, mais pas des arbalètes.</p>
<p><strong>Munitions.</strong> Les armes à projectiles utilisent des munitions : des flèches pour les arcs, des carreaux pour les arbalètes et des billes spéciales pour les frondes. Encocher une flèche est une action libre, mais charger une arbalète ou une fronde nécessite une action.</p>
<p>En règle générale, une munition qui atteint sa cible est détruite ou rendue inutilisable, alors qu''une munition ayant frappé à côté a 50 % de chances seulement d''être détruite ou perdue.</p>
<p>Bien qu''ils soient des armes de jet, les shurikens sont considérés comme des munitions pour ce qui est de les dégainer, d''en fabriquer des versions de maîtres ou spéciales (voir <em>Les armes de maître</em>) et sur les chances de les perdre une fois lancés.</p>
<h3>Armes légères, à une main ou à deux mains</h3>
<p>Ces termes catégorisent les armes selon l''effort qu''il faut fournir pour les manier en combat. Ils indiquent si une arme de corps à corps tenue par une créature de la catégorie de taille de l''arme est considérée comme une arme légère, une arme à une main ou une arme à deux mains.</p>
<p><strong>Légère.</strong> Une arme légère est plus facile à tenir de la main non directrice qu''une arme à une main, et l''on peut s''en servir en étant agrippé en situation de lutte. Une main suffit pour la manier. Lorsqu''une arme légère est tenue dans la main directrice, le modificateur de Force s''applique normalement aux jets de dégâts. Par contre, dans la main non directrice, seule la moitié du bonus de Force s''applique (mais un malus est pris en compte intégralement). Il est possible de tenir une arme légère à deux mains, mais cela ne donne aucun avantage particulier, le modificateur de Force aux dégâts est le même que si l''arme était dans la main directrice du personnage. Une attaque à mains nues est toujours considérée comme une arme légère.</p>
<p><strong>À une main.</strong> Une arme à une main peut être tenue dans la main directrice ou dans la main non directrice. Lorsqu''une arme à une main est tenue dans la main directrice, le modificateur de Force s''applique normalement aux jets de dégâts. Par contre, dans la main non directrice, seule la moitié du bonus de Force s''applique (mais un malus est pris en compte intégralement). Une arme à une main peut être utilisée en la tenant à deux mains, et le bonus de Force aux dégâts est alors multiplié par 1,5 (mais un malus est pris en compte normalement).</p>
<p><strong>À deux mains.</strong> On ne peut se servir efficacement d''une arme à deux mains qu''en la tenant effectivement à deux mains. Le bonus de Force aux dégâts est multiplié par 1,5 pour une arme à deux mains (mais un malus est pris en compte normalement).</p>
<h3>Taille de l''arme</h3>
<p>Chaque arme est associée à une catégorie de taille. Ce terme indique la catégorie de taille des créatures auxquelles une arme est destinée.</p>
<p>La catégorie de taille d''une arme est différente de sa taille en tant qu''objet. En règle générale, une arme légère est un objet de deux catégories de taille inférieures à son porteur, une arme à une main est un objet d''une catégorie de taille inférieure à son porteur et une arme à deux mains est un objet de la même catégorie de taille que son porteur.</p>
<p><strong>Arme d''une taille inappropriée.</strong> Une créature ne peut utiliser de façon optimale une arme qui n''est pas conçue pour une créature de sa taille. On applique aux jets d''attaque un malus de –2 cumulatif pour chaque catégorie de taille de différence entre la catégorie de taille de la créature et de l''arme. Si une créature n''est pas formée au maniement d''une arme, le malus de non-formation de –4 s''applique également.</p>
<p>La mesure de l''effort nécessaire pour tenir une arme (c''est-à-dire si elle est légère, à une main ou à deux mains) augmente ou diminue d''une catégorie pour chaque catégorie de différence entre la catégorie de taille à laquelle une arme est destinée et la catégorie de taille de la créature qui l''utilise effectivement. Si la catégorie d''une arme devient plus que deux mains, elle est si lourde qu''elle est inutilisable. Si elle devient moins que légère, elle est trop petite pour être efficace.</p>
<h3>Armes improvisées</h3>
<p>Il arrive parfois que l''on utilise pour se battre des objets qui n''ont pas été fabriqués à cet usage. On se bat ainsi avec des tessons de bouteilles, des barreaux de chaises ou en lançant des chopes. On considère systématiquement que le personnage ne sait pas manier cette arme qui n''en est pas une, ce qui lui inflige un malus de –4 sur les jets d''attaque. Pour déterminer la catégorie de taille et le potentiel de dégâts d''une arme improvisée, le DM doit comparer l''objet avec les armes de la liste des armes jusqu''à trouver un équivalent. Toutes les armes improvisées obtiennent un critique possible sur un 20 naturel et infligent des dégâts doublés en cas de critique confirmé. Les armes de jet improvisées ont un facteur de portée de 3 mètres.</p>',
        10, @ddver, @res, NULL, 1, @now, @now);
SET @r_categories_d_armes := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_les_armes, 'regle', 'Attributs des armes', 'attributs-des-armes',
'<p>Pour choisir au mieux les armes de votre personnage, gardez bien ces facteurs présents à l''esprit (ils apparaissent en tête des colonnes de la liste des armes).</p>
<p><strong>Prix.</strong> Il s''agit du coût de l''arme en pièces d''or (po) ou d''argent (pa). Il inclut l''équipement vendu avec l''arme (un fourreau pour une épée, un carquois pour des flèches). Le prix indiqué correspond aux armes de taille P ou M. Les armes de taille G coûtent deux fois plus cher.</p>
<p><strong>Dégâts.</strong> Les dégâts infligés par l''arme en cas d''attaque réussie. La colonne intitulée « Dgts (P) » concerne les armes de taille P, c''est-à-dire celles des gnomes et des halfelins. La colonne « Dgts (M) » concerne les armes de taille M, c''est-à-dire celles des demi-elfes, demi-orques, elfes, humains et nains. Dans le cas où la colonne propose deux jets de dés séparés par une barre de fraction, il s''agit d''une arme double. Les deux valeurs indiquées correspondent respectivement à la première et à la seconde tête de l''arme.</p>
<p>La table suivante permet de connaître le potentiel de dégâts des armes de taille TP et G.</p>
<p>[[tab:degats-armes-tp-g]]</p>
<p><strong>Critique.</strong> Cette colonne indique ce qui se passe en cas de coup critique. Lorsque cela se produit, il suffit de jeter les dés de dégâts (bonus compris) deux, trois ou quatre fois (en fonction de l''arme) et de faire le total.</p>
<p><strong>Exception.</strong> Les dés de dégâts supplémentaires séparés et au-delà des dégâts normaux d''une arme ne sont pas multipliés en cas de coup critique.</p>
<ul>
<li>×2 : les dégâts de l''arme sont doublés en cas de coup critique.</li>
<li>×3 : les dégâts de l''arme sont triplés en cas de coup critique.</li>
<li>×3/×4 : une des têtes de l''arme cause des dégâts triplés en cas de coup critique, l''autre des dégâts quadruplés.</li>
<li>×4 : les dégâts de l''arme sont quadruplés en cas de coup critique.</li>
<li>19–20/×2 : l''arme obtient un coup critique possible sur un 19 ou 20 au jet d''attaque (au lieu de 20 seulement) et cause des dégâts doublés en cas de confirmation du critique possible. (On parle de zone de critique possible de 19–20).</li>
<li>18–20/×2 : l''arme obtient un coup critique possible sur un 18, 19 ou 20 au jet d''attaque (au lieu de 20 seulement) et cause des dégâts doublés en cas de confirmation du critique possible. (On parle de zone de critique possible de 18–20).</li>
</ul>
<p><strong>Facteur de portée.</strong> En deçà de cette distance, les attaques se font sans malus. Par la suite, chaque distance égale au facteur de portée entraîne un malus cumulatif de –2 au jet d''attaque. Les armes de jet, telles que la hache de lancer, ne peuvent être envoyées au-delà de 5 facteurs de portée. Les armes à projectiles, comme les arcs, peuvent tirer jusqu''à 10 facteurs de portée.</p>
<p><strong>Poids.</strong> Le poids d''une arme de taille M. Ce nombre est divisé par deux pour les armes de taille P et doublé pour celles de taille G.</p>
<p><strong>Type.</strong> Les armes sont réparties en trois catégories selon le type de dégâts qu''elles infligent : contondantes, perforantes et tranchantes. Certains monstres peuvent être résistants ou immunisés contre certains types de dégâts. Ainsi, les squelettes subissent des dégâts réduits des armes tranchantes et perforantes.</p>
<p>Certaines armes infligent des dégâts de deux types. Par exemple, la morgenstern inflige des dégâts contondants et perforants. Dans ce cas, l''ensemble des dégâts est des deux types, il n''y a pas une moitié d''un type et une moitié de l''autre. C''est pourquoi une créature doit être protégée contre les deux types de dégâts pour que son immunité ou sa résistance s''applique.</p>
<p>D''autres armes peuvent infliger deux types de dégâts selon la façon dont on les utilise. Par exemple, la dague peut infliger des dégâts perforants ou tranchants. Dans une situation où le type de dégâts est important, l''utilisateur d''une de ces armes peut choisir entre les deux types de dégâts.</p>
<p>Quand deux types sont donnés, l''arme est des deux types simultanément s''ils sont séparés par « et », ou l''un des deux types choisis par le joueur au moment de l''attaque s''ils sont séparés par « ou ».</p>
<p><strong>Spécial.</strong> Certaines armes ont des attributs spéciaux. Référez-vous à la description de l''arme lorsque c''est le cas.</p>',
        20, @ddver, @res, NULL, 1, @now, @now);
SET @r_attributs_des_armes := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_les_armes, 'regle', 'Liste des armes', 'liste-des-armes',
'<p>Chaque ligne ouvre la fiche de l''arme, avec sa description et ses règles particulières. Le poids indiqué est celui d''une arme de taille M : une arme de taille P pèse deux fois moins et une arme de taille G deux fois plus.</p>
<h3>Armes courantes</h3>
<p>[[liste:equipement|famille=armes-courantes|titre=-]]</p>
<h3>Armes de guerre</h3>
<p>[[liste:equipement|famille=armes-de-guerre|titre=-]]</p>
<h3>Armes exotiques</h3>
<p>[[liste:equipement|famille=armes-exotiques|titre=-]]</p>',
        30, @ddver, @res, NULL, 1, @now, @now);
SET @r_liste_des_armes := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_les_armes, 'regle', 'Les armes de maître', 'armes-de-maitre',
'<p>Une arme de maître est un objet de qualité exceptionnelle, qui confère un bonus d''altération de +1 aux jets d''attaque.</p>
<p>On ne peut pas transformer une arme existante en arme de maître ; elle doit avoir été fabriquée en tant que telle (voir la compétence Artisanat). Une arme de maître coûte 300 po de plus qu''une arme identique, mais de qualité ordinaire. Dans le cas des munitions, comme les flèches, le surcoût n''est que de 6 po la pièce. Dans le cas des armes doubles, le surcoût est doublé, soit 600 po.</p>
<p>Les munitions de maître sont toujours inutilisables (détruites) après avoir été tirées. Le bonus d''altération d''une munition ne se cumule pas avec l''éventuel bonus d''altération de l''arme à projectile où elle est placée.</p>
<p>Toutes les armes magiques sont aussi des armes de maître. Le bonus d''altération dû à la qualité de l''arme ne se cumule pas avec le bonus d''altération octroyé par la magie de l''arme.</p>
<p>Bien que certaines armures et boucliers (comme un écu à pointes) puissent servir d''armes, il est impossible d''en fabriquer une version de maître qui confère un bonus d''altération aux jets d''attaque. Les armures et boucliers de maître bénéficient plutôt d''une réduction du malus d''armure aux tests.</p>',
        40, @ddver, @res, NULL, 1, @now, @now);
SET @r_armes_de_maitre := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_equipement, 'chapitre', 'Les armures et boucliers', 'les-armures-et-boucliers',
'<p>Les caractéristiques des armures et des boucliers, la liste de ceux que propose le compendium, et les règles pour les revêtir et les adapter. La description de chaque armure est consultable dans le compendium.</p>',
        30, @ddver, @res, NULL, 1, @now, @now);
SET @r_les_armures_et_boucliers := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_les_armures_et_boucliers, 'regle', 'Attributs des armures', 'attributs-des-armures',
'<p>Chaque classe a généralement un type d''armure de prédilection, mais il est possible de s''équiper plus lourdement en choisissant l''un des dons de Port d''armure. Les armures et les boucliers peuvent être endommagés par certaines attaques.</p>
<p>Lorsque vous choisissez votre armure, gardez bien les facteurs suivants à l''esprit (ils apparaissent en tête de colonnes de la liste des armures et boucliers).</p>
<p><strong>Prix.</strong> Le prix de l''armure pour une créature humanoïde de taille P ou M. Pour les autres créatures, voir <em>Armures pour créatures inhabituelles</em>.</p>
<p><strong>Bonus d''armure/de bouclier.</strong> Les armures confèrent un bonus d''armure à la CA et les boucliers confèrent un bonus de bouclier à la CA. Le bonus d''armure d''une armure manufacturée ne se cumule pas avec les autres effets ou objets procurant eux aussi un bonus d''armure. De même, le bonus de bouclier d''un bouclier manufacturé ne se cumule pas avec les autres effets qui confèrent un bonus de bouclier.</p>
<p><strong>Bonus de Dextérité maximal.</strong> Ce chiffre est le bonus de Dextérité maximal à la CA que l''armure autorise. En effet, les armures lourdes restreignent la mobilité de leur porteur, ce qui réduit d''autant sa capacité à esquiver les coups. Cette limite n''affecte aucun des autres facteurs liés à la Dextérité.</p>
<p>Même si le bonus de Dextérité du personnage tombe à 0 à cause d''une armure, on considère qu''il l''a toujours. L''encombrement d''un personnage (le poids de son équipement) peut lui aussi limiter le bonus de Dextérité qu''il peut appliquer à sa classe d''armure.</p>
<p><strong>Bouclier.</strong> Les boucliers n''affectent en rien le bonus de Dextérité maximal, à l''exception du pavois.</p>
<p><strong>Malus d''armure aux tests.</strong> Toute armure plus lourde que celle de cuir rend plus difficile l''utilisation de certaines compétences. Le malus d''armure aux tests s''applique aux tests de compétence suivants : Acrobaties, Déplacement silencieux, Discrétion, Équilibre, Escalade, Escamotage, Évasion et Saut. Le double du malus d''armure aux tests s''applique aux tests de Natation. L''encombrement d''un personnage (le poids de son équipement, armure comprise) peut lui aussi imposer un malus d''armure aux tests.</p>
<p><strong>Bouclier.</strong> Si le personnage utilise également un bouclier, les deux malus d''armure aux tests s''additionnent.</p>
<p><strong>Absence de formation au port de l''armure.</strong> Si le personnage a revêtu une armure au port de laquelle il n''est pas formé, ou s''il porte un bouclier au maniement duquel il n''est pas formé, le malus d''armure aux tests de l''armure ou du bouclier s''applique à tous ses jets d''attaque et aux tests de caractéristique ou de compétence associées à la Force ou à la Dextérité. Le malus pour une absence de formation au port d''une armure se cumule avec celui d''une absence de formation au maniement du bouclier.</p>
<p><strong>Dormir en armure.</strong> Tout personnage dormant sans retirer une armure intermédiaire ou lourde se réveille automatiquement fatigué. Il subit alors un malus de –2 à ses tests de Force et de Dextérité et se retrouve dans l''incapacité de charger ou de courir. Dormir en portant une armure légère ne cause aucun problème.</p>
<p><strong>Risque d''échec des sorts profanes.</strong> L''armure gêne les gestes qu''il convient d''effectuer pour lancer des sorts de magie profane à composante gestuelle. Les pratiquants de ce type de magie risquent de voir leurs sorts échouer s''ils revêtent une armure, ce qui explique qu''ensorceleurs et magiciens préfèrent généralement s''en passer. Les bardes peuvent porter une armure légère sans encourir le risque de voir leurs sorts de magie bardique échouer.</p>
<p><strong>Lancer des sorts de magie profane en armure.</strong> Lorsqu''un personnage tente de jeter un tel sort alors qu''il porte une armure, il lui faut souvent effectuer un jet d''échec de sort. La liste des armures et boucliers indique le risque d''échec au cours de l''incantation. S''il s''agit d''un sort sans composante gestuelle, le personnage peut toutefois le lancer sans risque d''échec.</p>
<p><strong>Bouclier.</strong> Si le personnage utilise à la fois une armure et un bouclier, additionnez les deux pourcentages indiqués pour connaître le risque d''échec des sorts profanes.</p>
<p><strong>Vitesse de déplacement.</strong> Les armures lourdes ou intermédiaires ralentissent celui qui les porte. Certes, mieux vaut être lent et en vie que rapide et mort, mais pouvoir se déplacer est souvent bien utile. La liste des armures et boucliers communique la vitesse de déplacement que permet chaque armure. Sans armure, humains, elfes, demi-elfes et demi-orques se déplacent de 9 mètres. Ils utilisent la première colonne. Nains, gnomes et halfelins vont moins vite, même sans armure (6 mètres). Eux se réfèrent à la seconde colonne. Cependant, la vitesse des nains est toujours de 6 mètres, même s''ils portent une armure ou une charge intermédiaire ou lourde. Un éventuel bouclier n''influe pas sur la vitesse de déplacement.</p>
<p><strong>Poids.</strong> Le poids de l''armure. Pour un personnage de taille P, il convient de le diviser par deux, et pour un personnage de taille G, de le multiplier par deux.</p>',
        10, @ddver, @res, NULL, 1, @now, @now);
SET @r_attributs_des_armures := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_les_armures_et_boucliers, 'regle', 'Liste des armures et boucliers', 'liste-des-armures-et-boucliers',
'<p>Chaque ligne ouvre la fiche de l''armure ou du bouclier, avec sa description. Le poids indiqué concerne les armures faites pour les personnages de taille M : celles destinées aux personnages de taille P pèsent deux fois moins lourd, et celles destinées aux personnages de taille G deux fois plus lourd.</p>
<p>[[liste:equipement|famille=armures-et-boucliers]]</p>
<ul>
<li>Le pavois permet aussi de se mettre à couvert, voir sa description.</li>
<li>Le gantelet d''armes empêche de jeter les sorts à composante gestuelle avec cette main.</li>
</ul>',
        20, @ddver, @res, NULL, 1, @now, @now);
SET @r_liste_des_armures_et_boucliers := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_les_armures_et_boucliers, 'regle', 'Armures de maître', 'armures-de-maitre',
'<p>Au même titre que les armes, on peut acheter ou fabriquer des versions de maître des armures et des boucliers. Ces objets de qualité exceptionnelle fonctionnent comme leurs pendants ordinaires, si ce n''est que le malus d''armure aux tests qu''ils imposent est réduit de 1 point.</p>
<p>Une armure ou un bouclier de maître coûte 150 po de plus qu''un objet identique, mais de qualité moyenne. Le fait qu''une armure ou un bouclier soit de qualité supérieure ne confère jamais de bonus aux jets d''attaque ou de dégâts, même si l''objet est utilisé comme une arme (par exemple, en y ajoutant des pointes).</p>
<p>Toutes les armures et tous les boucliers magiques sont aussi des objets de maître.</p>
<p>On ne peut pas transformer une armure ou un bouclier existant en objet de maître, il doit avoir été fabriqué en tant que tel (voir la compétence Artisanat).</p>',
        30, @ddver, @res, NULL, 1, @now, @now);
SET @r_armures_de_maitre := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_les_armures_et_boucliers, 'regle', 'Armures pour créatures inhabituelles', 'armures-pour-creatures-inhabituelles',
'<p>Les armures pour créatures particulièrement grandes, extrêmement petites ou non-humanoïdes ont un poids et un coût différents de ceux indiqués par la liste des armures et boucliers. Référez-vous à la ligne adéquate sur la table suivante, et appliquez les multiplicateurs au coût et au poids de l''armure en question.</p>
<p>[[tab:armures-creatures-inhabituelles]]</p>',
        40, @ddver, @res, NULL, 1, @now, @now);
SET @r_armures_pour_creatures_inhabituelles := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_les_armures_et_boucliers, 'regle', 'Enfiler ou ôter son armure', 'enfiler-ou-oter-son-armure',
'<p>Le temps nécessaire pour enfiler une armure dépend de la catégorie à laquelle elle appartient (voir table suivante).</p>
<p><strong>Enfiler.</strong> Cette colonne indique combien de temps il faut pour revêtir l''armure (1 minute correspond à 10 rounds). Préparer un bouclier consiste à l''attacher sur le bras, et ne nécessite qu''une action de mouvement.</p>
<p><strong>Enfiler à la hâte.</strong> Cette colonne indique le temps nécessaire pour enfiler son armure sans perdre de temps. L''armure est alors forcément mal ajustée, ce qui la rend moins efficace d''un point, tant pour la CA que pour le malus d''armure aux tests.</p>
<p><strong>Ôter.</strong> Cette colonne indique combien de temps il faut pour enlever son armure. Pour détacher un bouclier, il faut le dégager du bras et le lâcher, ce qui requiert une action de mouvement.</p>
<p>[[tab:enfiler-oter-armure]]</p>',
        50, @ddver, @res, NULL, 1, @now, @now);
SET @r_enfiler_ou_oter_son_armure := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_equipement, 'chapitre', 'Marchandises et services', 'marchandises-et-services',
'<p>Le matériel de l''aventurier, les substances spéciales, les vêtements, le gîte et le couvert, les montures, les moyens de transport et les services. Les listes ci-dessous donnent le prix et le poids de chaque article ; sa description est sur sa fiche.</p>',
        40, @ddver, @res, NULL, 1, @now, @now);
SET @r_marchandises_et_services := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_marchandises_et_services, 'regle', 'Liste des marchandises et services', 'liste-des-marchandises-et-services',
'<p>Certains articles sont décrits plus longuement sur leur fiche (règles d''utilisation, jets de sauvegarde, DD, etc.).</p>
<p>Les objets de cette liste pèsent un quart du poids indiqué quand on les fabrique pour des personnages de taille P ; les récipients pour personnages de taille P ne contiennent qu''un quart du volume indiqué. Un poids absent signifie un poids nul ou négligeable.</p>
<h3>Matériel d''aventurier</h3>
<p>[[liste:equipement|famille=materiel-d-aventurier|titre=-]]</p>
<h3>Substances et objets spéciaux</h3>
<p>Les substances spéciales qui suivent peuvent être fabriquées à l''aide de la compétence Artisanat (alchimie), à l''exception de la torche éternelle et de l''eau bénite.</p>
<p>[[liste:equipement|famille=substances-et-objets-speciaux|titre=-]]</p>
<h3>Matériel de classe et de compétence</h3>
<p>[[liste:equipement|famille=materiel-de-classe-et-de-competence|titre=-]]</p>
<p>Un symbole impie fonctionne de la même façon qu''un symbole sacré, si ce n''est qu''il concentre l''énergie négative et que ce sont les prêtres mauvais qui s''en servent (ou les prêtres neutres ayant choisi de jeter des sorts maléfiques et de contrôler les morts-vivants).</p>
<h3>Vêtements</h3>
<p>[[liste:equipement|famille=vetements|titre=-]]</p>
<h3>Nourriture, boisson et hébergement</h3>
<p>[[liste:equipement|famille=nourriture-boisson-et-hebergement|titre=-]]</p>
<h3>Montures et harnachement</h3>
<p>[[liste:equipement|famille=montures-et-harnachement|titre=-]]</p>
<h3>Moyens de transport</h3>
<p>[[liste:equipement|famille=moyens-de-transport|titre=-]]</p>
<h3>Lancement de sorts et services</h3>
<p>[[liste:equipement|famille=services|titre=-]]</p>',
        10, @ddver, @res, NULL, 1, @now, @now);
SET @r_liste_des_marchandises_et_services := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_marchandises_et_services, 'regle', 'Bardes et montures', 'bardes-et-montures',
'<p>Le cheval étant une créature de taille G et non humanoïde, son armure coûte quatre fois plus cher que celle d''un humain (une créature de taille M) et son poids est le double des chiffres mentionnés dans la liste des armures et boucliers (voir <em>Armures pour créatures inhabituelles</em>). Dans le cas où la barde est censée équiper un poney ou toute autre monture de taille M, son poids est le même que celui indiqué pour un humanoïde de taille M et son coût est seulement doublé.</p>
<p>Les bardes lourdes ou intermédiaires ralentissent les montures, comme le résume la table suivante.</p>
<p>[[tab:vitesse-montures-barde]]</p>
<p>Les montures volantes sont incapables de décoller si elles sont lestées par une barde lourde ou intermédiaire. Mettre ou enlever une barde prend cinq fois plus de temps que ne l''indique la table pour enfiler ou ôter son armure. Un animal en armure ne peut transporter d''autre charge que son cavalier et ses fontes. C''est pour cette raison que les chevaliers ont souvent besoin d''un second animal pour transporter leur équipement.</p>',
        20, @ddver, @res, NULL, 1, @now, @now);
SET @r_bardes_et_montures := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_marchandises_et_services, 'regle', 'Lancement de sorts et services', 'lancement-de-sorts-et-services',
'<p>La meilleure solution à un problème est parfois d''engager quelqu''un d''autre pour le résoudre.</p>
<p>Le niveau de la formule de prix d''un sort est le niveau de lanceur de sorts. Voir la description du sort pour les coûts additionnels. En règle générale, si les surcoûts d''un sort amènent son coût au-delà de 3 000 po, il n''est pas disponible sauf permission expresse du MJ.</p>
<h3>Faire lancer un sort par un PNJ</h3>
<p>Le prix est celui qu''il faut payer pour qu''un PNJ accepte de jeter le sort demandé. Le coût implique que le personnage vienne voir le PNJ et laisse ce dernier lancer le sort à un moment qu''il jugera opportun (c''est-à-dire généralement 24 heures plus tard, pour qu''il ait le temps de préparer le sort). Si le jeteur de sorts doit se déplacer, il faut négocier avec lui au cas par cas, la réponse par défaut étant systématiquement négative.</p>
<p>Le prix mentionné considère que le sort ne coûte rien, que ce soit en termes de composantes matérielles, de focaliseur ou de PX. En cas de composante matérielle coûteuse, son prix doit être ajouté au total. Si le sort nécessite un focaliseur (autre qu''un focaliseur divin), ajoutez 1/10 du coût de ce dernier à celui de l''enchantement. Enfin, dans le cas d''un sort faisant perdre des PX, il se négocie au coût additionnel de 5 po par PX perdu.</p>
<p>De plus, si lancer le sort peut avoir des conséquences néfastes, le jeteur de sort exigera des preuves que l''acheteur a les moyens et est prêt à payer pour réparer le contrecoup éventuel. Et encore, il faut déjà que le PNJ accepte de lancer le sort, ce qui est loin d''être assuré. Dans le cas des sorts qui transportent le lanceur du sort avec ses cibles, il faudra sans doute payer pour le retour du PNJ, même si les personnages ne l''accompagnent pas.</p>
<p>Enfin, toutes les villes et villages n''ont pas un lanceur de sort de niveau suffisant pour lancer n''importe quel sort. En règle générale, il faut voyager jusqu''à une petite ville (au moins) pour être assuré de trouver un PNJ capable de lancer des sorts du 1er niveau, une ville importante pour des sorts du 2e niveau, une grande ville pour des sorts des 3e et 4e niveaux, une cité pour des sorts des 5e et 6e niveaux et une métropole pour des sorts des 7e et 8e niveaux. Même dans une métropole, il n''est pas certain de trouver un lanceur de sorts pouvant jeter des sorts du 9e niveau.</p>',
        30, @ddver, @res, NULL, 1, @now, @now);
SET @r_lancement_de_sorts_et_services := LAST_INSERT_ID();

-- Tableaux (convention texte, SP-TB)
INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note,
                         tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible,
                         tab_date_creation, tab_date_modif)
VALUES
('types-de-pieces', 'Les différents types de pièces',
'! | Valeur d''échange | | |
! Pièce | PC | PA | PO | PP
Pièce de cuivre (pc) | 1 | 1/10 | 1/100 | 1/1 000
Pièce d''argent (pa) | 10 | 1 | 1/10 | 1/100
Pièce d''or (po) | 100 | 10 | 1 | 1/10
Pièce de platine (pp) | 1 000 | 100 | 10 | 1',
'lrrrr', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('produits-de-consommation-courante', 'Produits de consommation courante',
'! Prix | Article
1 pc | Une livre (500 g) de blé
2 pc | Une livre (500 g) de farine, ou un poulet
1 pa | Une livre (500 g) de fer
5 pa | Une livre (500 g) de tabac ou de cuivre
1 po | Une livre (500 g) de cannelle, ou une chèvre
2 po | Une livre (500 g) de gingembre ou de poivre, ou un mouton
3 po | Un cochon
4 po | Un mètre carré de lin
5 po | Une livre (500 g) d''argent ou de sel
10 po | Un mètre carré de soie ou une vache
15 po | Une livre (500 g) de safran ou de clous de girofle, ou un bœuf
50 po | Une livre (500 g) d''or
500 po | Une livre (500 g) de platine',
'rl', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('degats-armes-tp-g', 'Dégâts des armes de taille TP ou G',
'! Dégâts d''une arme de taille M | Dégâts d''une arme de taille TP | Dégâts d''une arme de taille G
1d2 | — | 1d3
1d3 | 1 | 1d4
1d4 | 1d2 | 1d6
1d6 | 1d3 | 1d8
1d8 | 1d4 | 2d6
1d10 | 1d6 | 2d8
1d12 | 1d8 | 3d6
2d4 | 1d4 | 2d6
2d6 | 1d8 | 3d6
2d8 | 1d10 | 3d8
2d10 | 2d6 | 4d8',
'ccc', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('armures-creatures-inhabituelles', 'Armures pour créatures inhabituelles',
'! Taille | Humanoïde | | Non-humanoïde |
! ^ | Prix | Poids | Prix | Poids
Jusqu''à très petite (TP) | ×1/2 | ×1/10 | ×1 | ×1/10
Petite (P) | ×1 | ×1/2 | ×2 | ×1/2
Moyenne (M) | ×1 | ×1 | ×2 | ×1
Grande (G) | ×2 | ×2 | ×4 | ×2
Très grande (TG) | ×4 | ×5 | ×8 | ×5
Gigantesque (Gig) | ×8 | ×8 | ×16 | ×8
Colossale (C) | ×16 | ×12 | ×32 | ×12',
'lcccc', 'Pour une créature de taille TP ou moins, le bonus d''armure est réduit de moitié.', @ddver, @res, NULL, 0, 0, 1, @now, @now),
('enfiler-oter-armure', 'Enfiler ou ôter son armure',
'! Armure | Enfiler | Enfiler à la hâte | Ôter
Bouclier (tous) | 1 action de mouvement | sans objet | 1 action de mouvement
Armure matelassée, de cuir, de cuir cloutée, de peau ou chemise de mailles | 1 minute | 5 rounds | 1 minute¹
Cuirasse, armure d''écailles, de mailles, clibanion ou crevice | 4 minutes¹ | 1 minute | 1 minute¹
Armure à plaques ou harnois | 4 minutes² | 4 minutes¹ | 1d4+1 minutes¹
> ¹ En cas d''assistance, ce temps est divisé par deux. Un personnage ne faisant rien d''autre peut aider un ou deux compagnons si ces derniers sont adjacents. Il est impossible de s''aider mutuellement à revêtir une armure (du moins, en même temps).
> ² Une assistance extérieure est nécessaire pour bien ajuster cette armure, sans quoi elle ne peut qu''être enfilée à la hâte.',
'lccc', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('vitesse-montures-barde', 'Vitesse des montures portant une barde',
'! | Vitesse | |
! Barde | (12 m) | (15 m) | (18 m)
Intermédiaire | 9 m | 10,50 m | 12 m
Lourde | 9 m¹ | 10,50 m¹ | 12 m¹',
'lccc', 'Une monture revêtue d''une armure lourde voit sa vitesse de déplacement multipliée par trois seulement lorsqu''elle court (au lieu de quatre).', @ddver, @res, NULL, 0, 0, 1, @now, @now);

-- Glossaire
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES
(@glo, 'glossaire', 'Arme à allonge', 'arme-a-allonge', '<p>Arme de corps à corps qui permet de frapper des cibles non adjacentes (chaîne cloutée, corsèque, coutille, fouet, guisarme, lance d''arçon, pique). Une créature de taille P ou M frappe à 3 mètres, mais pas sur une case adjacente. Voir <em>Catégories d''armes</em>.</p>', 10, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Arme double', 'arme-double', '<p>Arme à deux têtes qui permet de se battre comme avec deux armes, avec les malus du combat à deux armes (une arme à une main et une arme légère). Voir <em>Catégories d''armes</em>.</p>', 20, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Arme de jet', 'arme-de-jet', '<p>Arme qui se lance : le modificateur de Force s''applique aux dégâts. Une arme de corps à corps peut aussi être lancée, à –4 et avec un facteur de portée de 3 mètres. Voir <em>Catégories d''armes</em>.</p>', 30, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Arme à projectiles', 'arme-a-projectiles', '<p>Arc, arbalète ou fronde, qui tire des munitions. Le bonus de Force ne s''applique pas aux dégâts (sauf arcs composites spéciaux et frondes) ; un malus s''applique aux arcs et frondes. Voir <em>Catégories d''armes</em>.</p>', 40, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Arme improvisée', 'arme-improvisee', '<p>Objet utilisé comme arme sans avoir été fabriqué à cet usage : –4 aux jets d''attaque, critique possible sur 20 naturel, dégâts doublés en cas de critique confirmé, facteur de portée de 3 mètres si elle est lancée. Voir <em>Catégories d''armes</em>.</p>', 50, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Arme de maître', 'arme-de-maitre', '<p>Arme de qualité exceptionnelle (+300 po) qui confère un bonus d''altération de +1 aux jets d''attaque. Toute arme magique est aussi de maître. Voir <em>Les armes de maître</em>.</p>', 60, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Armure de maître', 'armure-de-maitre', '<p>Armure ou bouclier de qualité exceptionnelle (+150 po) dont le malus d''armure aux tests est réduit de 1. Voir <em>Armures de maître</em>.</p>', 70, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Munition', 'munition', '<p>Flèche, carreau ou bille de fronde. Une munition qui atteint sa cible est détruite ; ratée, elle a 50 % de chances d''être détruite ou perdue. Voir <em>Catégories d''armes</em>.</p>', 80, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Facteur de portée', 'facteur-de-portee', '<p>Distance en deçà de laquelle une attaque à distance se fait sans malus ; au-delà, –2 cumulatif par multiple du facteur. Maximum de 5 facteurs pour une arme de jet, 10 pour une arme à projectiles. Voir <em>Attributs des armes</em>.</p>', 90, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Malus d''armure aux tests', 'malus-d-armure-aux-tests', '<p>Pénalité imposée par une armure ou un bouclier aux tests d''Acrobaties, Déplacement silencieux, Discrétion, Équilibre, Escalade, Escamotage, Évasion et Saut (doublée pour Natation). Voir <em>Attributs des armures</em>.</p>', 100, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Risque d''échec des sorts profanes', 'risque-d-echec-des-sorts-profanes', '<p>Pourcentage de chances qu''un sort profane à composante gestuelle échoue quand on le lance en armure ; les pourcentages de l''armure et du bouclier s''additionnent. Voir <em>Attributs des armures</em>.</p>', 110, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Bonus de Dextérité maximal', 'bonus-de-dexterite-maximal', '<p>Plafond du bonus de Dextérité qu''une armure autorise à la CA. Voir <em>Attributs des armures</em>.</p>', 120, @ddver, @res, NULL, 1, @now, @now);

COMMIT;
