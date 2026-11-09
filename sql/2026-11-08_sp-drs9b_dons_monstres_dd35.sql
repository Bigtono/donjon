-- sql/2026-11-08_sp-drs9b_dons_monstres_dd35.sql
-- SP-DRS9b — DRS 31 : les dons des monstres absents du compendium
-- Sur les 13 dons du DRS 31, 9 sont déjà en base (catégorie « Monstres », Manuel des monstres ou
-- autre source). On ajoute les 4 manquants, source DRS 3.5, catégorie « Monstres » :
-- Capture, Création de créature artificielle, Extension de pouvoir magique, Pouvoir magique rapide.
-- Le « Pouvoir magique rapide » déjà en base (Les chapitres interdits) portait une catégorie du
-- ruleset DD2024 (« Général » id 19) : elle est ramenée à « Général » DD3.5.
-- Rejouable : insertion seulement si le don n'existe pas déjà dans la source DRS 3.5.
-- Pas de DELIMITER. Pré-requis : socle SP-DRS0.

SET NAMES utf8mb4;

SET @ddver := (SELECT var_id FROM dd_variables WHERE var_cat = 'ruleset' AND var_valeur = 'DD3.5' LIMIT 1);
SET @res   := (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'DRS 3.5' AND res_ruleset_var_id = @ddver LIMIT 1);
SET @cat   := (SELECT dado_id FROM dd_data_don WHERE dado_nom = 'Monstres' AND dado_ruleset_var_id = @ddver LIMIT 1);
SET @gen   := (SELECT dado_id FROM dd_data_don WHERE dado_nom = 'Général' AND dado_ruleset_var_id = @ddver LIMIT 1);

START TRANSACTION;

INSERT INTO dd_dons (do_nom, do_dado_id, do_conditions, do_texte, do_resume, do_res_id, do_camp_id, do_public,
                     do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Capture', @cat, 'Taille TG ou supérieure.',
'<p><strong>Condition.</strong> Taille TG ou supérieure.</p>
<p><strong>Avantage.</strong> Si la créature touche à l''aide de sa morsure ou de l''une de ses griffes, elle peut tenter d''engager une lutte comme si elle possédait l''attaque spéciale étreinte. Si elle parvient à maintenir sa prise sur une créature faisant au moins trois catégories de taille de moins qu''elle, elle la serre violemment à chaque round et lui inflige automatiquement les dégâts correspondant à l''attaque de griffes ou de morsure. De plus, un adversaire agrippé dans sa gueule n''a pas droit au moindre jet de Réflexes si elle décide de souffler (encore faut-il qu''elle possède une telle attaque).</p>
<p>La créature peut à tout moment lâcher un sujet qu''elle a capturé (action libre), à moins qu''elle ne préfère le jeter au loin (action simple). Dans ce cas, l''adversaire projeté de la sorte parcourt 1d6 × 3 mètres et subit 1d6 points de dégâts tous les 3 mètres parcourus. Si la créature l''a jeté alors qu''elle se trouvait en vol, le sujet subit les dégâts correspondant à une chute de la hauteur correspondante si ceux-ci sont plus élevés que ceux indiqués précédemment.</p>',
'Une morsure ou des griffes qui touchent permettent d''engager une lutte et d''écraser ou de projeter la proie.',
@res, NULL, 0, 1, @ddver, 0, 0
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Capture' AND do_res_id = @res AND do_ruleset_var_id = @ddver);

INSERT INTO dd_dons (do_nom, do_dado_id, do_conditions, do_texte, do_resume, do_res_id, do_camp_id, do_public,
                     do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Création de créature artificielle', @cat, 'Création d''armes et armures magiques, Création d''objets merveilleux.',
'<p><strong>Conditions.</strong> Création d''armes et armures magiques, Création d''objets merveilleux.</p>
<p><strong>Avantage.</strong> Une créature dotée de ce don est capable de façonner toute créature artificielle, du moment qu''elle satisfait aux conditions. Le processus de fabrication prend 1 jour par tranche de 1 000 po du prix de vente. La créature doit sacrifier un nombre de points d''expérience égal à 1/25e du prix de la créature et acheter les matières premières nécessaires (pour une valeur totale égale à la moitié du prix de base). Pour plus de détails, reportez-vous à la description de chaque créature.</p>
<p>La créature peut également réparer les créatures artificielles qui ont subi des dégâts. Ainsi, en une journée de travail, elle peut annuler jusqu''à 20 points de dégâts en dépensant 50 po par point de vie restitué.</p>
<p>Une créature artificielle nouvellement conçue possède les points de vie moyens découlant de ses dés de vie.</p>',
'Permet de fabriquer et de réparer des créatures artificielles (golems…).',
@res, NULL, 0, 1, @ddver, 0, 0
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Création de créature artificielle' AND do_res_id = @res AND do_ruleset_var_id = @ddver);

INSERT INTO dd_dons (do_nom, do_dado_id, do_conditions, do_texte, do_resume, do_res_id, do_camp_id, do_public,
                     do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Extension de pouvoir magique', @cat, 'Niveau de lanceur de sorts de 6 ou plus pour le pouvoir magique concerné.',
'<p><strong>Condition.</strong> Niveau de lanceur de sorts de 6 ou plus pour ce qui est du pouvoir magique concerné.</p>
<p><strong>Avantage.</strong> Choisissez l''un des pouvoirs magiques de la créature soumis aux restrictions figurant ci-dessous. Elle peut alors s''en servir 3 fois par jour (ou moins si elle ne peut normalement s''en servir que 1 ou 2 fois par jour) comme s''il s''agissait d''un pouvoir magique à effet étendu.</p>
<p>Tous les effets numériques et aléatoires d''un pouvoir magique à effet étendu sont augmentés de moitié. Les jets de sauvegarde et les jets opposés ne sont pas altérés. De la même manière, les pouvoirs magiques ne comportant pas de variable numérique ne sont pas affectés.</p>
<p>On ne peut choisir qu''un pouvoir magique reproduisant les effets d''un sort dont le niveau est inférieur ou égal à la moitié du niveau de lanceur de sorts de la créature (arrondir à l''entier inférieur) –2. Reportez-vous à la table figurant dans la description du don Pouvoir magique rapide.</p>
<p>[[tab:pouvoirs-magiques-rapides-et-etendus]]</p>
<p><strong>Spécial.</strong> Ce don peut être choisi à plusieurs reprises. À chaque fois, la créature doit l''appliquer à un autre de ses pouvoirs magiques.</p>',
'Un pouvoir magique s''utilise jusqu''à 3 fois par jour avec un effet étendu (effets numériques +50 %).',
@res, NULL, 0, 1, @ddver, 0, 0
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Extension de pouvoir magique' AND do_res_id = @res AND do_ruleset_var_id = @ddver);

INSERT INTO dd_dons (do_nom, do_dado_id, do_conditions, do_texte, do_resume, do_res_id, do_camp_id, do_public,
                     do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Pouvoir magique rapide', @cat, 'Niveau de lanceur de sorts de 10 ou plus pour le pouvoir magique concerné.',
'<p><strong>Condition.</strong> Niveau de lanceur de sorts de 10 ou plus pour ce qui est du pouvoir magique concerné.</p>
<p><strong>Avantage.</strong> Choisissez l''un des pouvoirs magiques de la créature qui satisfait aux conditions énoncées ci-dessous. Elle peut alors utiliser ce pouvoir comme un pouvoir magique à incantation rapide, 3 fois par jour (ou moins si elle ne peut normalement s''en servir qu''une ou deux fois par jour).</p>
<p>L''utilisation d''un pouvoir magique à incantation rapide ne requiert qu''une action libre qui ne provoque pas d''attaque d''opportunité. La créature peut effectuer une autre action, y compris le recours à un autre pouvoir magique, dans le round où elle a utilisé un pouvoir magique à incantation rapide. Par contre, elle ne peut se servir que d''un pouvoir magique à incantation rapide par round.</p>
<p>On ne peut choisir qu''un pouvoir magique reproduisant les effets d''un sort dont le niveau est inférieur ou égal à la moitié du niveau de lanceur de sorts de la créature (arrondir à l''entier inférieur) –4. Reportez-vous à la table ci-dessous. Par ailleurs, un pouvoir magique reproduisant les effets d''un sort dont le temps d''incantation est supérieur à 1 round ne peut bénéficier d''une version rapide.</p>
<p>[[tab:pouvoirs-magiques-rapides-et-etendus]]</p>
<p><strong>Normal.</strong> Sauf indication contraire, l''utilisation d''un pouvoir magique requiert une action simple et provoque une attaque d''opportunité.</p>
<p><strong>Spécial.</strong> Ce don peut être choisi à plusieurs reprises. À chaque fois, la créature l''applique à un nouveau pouvoir magique.</p>',
'Un pouvoir magique s''utilise jusqu''à 3 fois par jour par une action libre, sans attaque d''opportunité.',
@res, NULL, 0, 1, @ddver, 0, 0
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Pouvoir magique rapide' AND do_res_id = @res AND do_ruleset_var_id = @ddver);

-- Don DD3.5 rangé dans une catégorie du ruleset DD2024 : ramené à « Général » DD3.5
UPDATE dd_dons
SET    do_dado_id = @gen
WHERE  do_ruleset_var_id = @ddver AND do_nom = 'Pouvoir magique rapide' AND do_res_id <> @res
  AND  do_dado_id IN (SELECT dado_id FROM dd_data_don WHERE dado_ruleset_var_id <> @ddver);

COMMIT;
