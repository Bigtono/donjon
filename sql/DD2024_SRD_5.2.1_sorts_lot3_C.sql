-- =====================================================================
-- Import sorts SRD 5.2.1 (DD2024) — LOT 3 : lettre C (50 sorts)
-- dd_sorts so_id 2124..2173 | dd_sortclasse sc_id dès 7374
-- res_id=93 | ruleset_var_id=2 | camp_id NULL
-- Réexécution : DELETE FROM dd_sortclasse WHERE sc_so_id BETWEEN 2124 AND 2173;
--              DELETE FROM dd_sorts WHERE so_id BETWEEN 2124 AND 2173;
-- =====================================================================
SET NAMES utf8mb4;
START TRANSACTION;

-- [2124] Cécité/surdité (niv 2, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2124, 'Cécité/surdité', 2, 4, NULL, 1, 0, 0, 0, 0, NULL, '36 m', '', '', 'action', '1 minute', NULL, NULL, 0, 0, '<p>Une créature que vous voyez à portée doit réussir un jet de sauvegarde de Constitution, sous peine de subir l''état Assourdi ou Aveuglé (vous choisissez) pour toute la durée. La cible réitère le JS à la fin de chacun de ses tours et met un terme au sort sur elle-même en cas de réussite.</p>
<p>Emplacement de niveau supérieur. Vous pouvez cibler une créature supplémentaire par niveau d''emplacement au-delà du 2e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7374, 2124, 53, 2),
  (7375, 2124, 54, 2),
  (7376, 2124, 56, 2),
  (7377, 2124, 52, 2);

-- [2125] Cercle de mort (niv 6, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2125, 'Cercle de mort', 6, 2, NULL, 1, 1, 1, 0, 0, 'une perle noire d''une valeur minimale de 500 po réduite en poudre', '45 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Des ondes d''énergie négative rayonnent sous forme d''une Sphère de 18 m de rayon centrée sur un point que vous choisissez à portée. Chaque créature prise dans la zone effectue un jet de sauvegarde de Constitution et subit 8d8 dégâts nécrotiques en cas d''échec, la moitié en cas de réussite.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 2d8 par niveau d''emplacement au-delà du 6e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7378, 2125, 56, 6),
  (7379, 2125, 52, 6),
  (7380, 2125, 58, 6);

-- [2126] Cercle de téléportation (niv 5, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2126, 'Cercle de téléportation', 5, 6, NULL, 1, 0, 1, 0, 0, 'encres rares d''une valeur minimale de 50 po, que le sort détruit', '3 m', '', '', '1 minute', '1 round', NULL, NULL, 0, 0, '<p>À l''incantation du sort, vous tracez un cercle de 1,50 m de diamètre au sol, composé de symboles qui relient votre emplacement à un cercle de téléportation permanent de votre choix dont vous connaissez la séquence de runes et situé sur le même plan d''existence que vous. Un portail chatoyant s''ouvre au sein du cercle ainsi tracé et reste ouvert jusqu''à la fin de votre tour suivant. Toute créature qui pénètre dans le portail apparaît aussitôt dans un rayon de 1,50 m du cercle de destination ou, si cet espace n''est pas libre, dans l''espace inoccupé le plus proche.</p>
<p>De nombreux temples et guildes importants disposent d''un cercle de téléportation permanent dans leurs locaux. Chaque cercle comprend toujours sa propre séquence de runes, une suite de symboles à l''agencement unique.</p>
<p>La première fois que vous acquérez la faculté de lancer ce sort, vous apprenez la séquence de runes de deux destinations du Plan Matériel, déterminées par le MJ. Vous y ajouterez éventuellement d''autres séquences au fil de vos aventures. Graver une nouvelle séquence de runes dans votre mémoire nécessite de l''étudier pendant 1 minute.</p>
<p>Vous pouvez créer un cercle de téléportation permanent en lançant quotidiennement ce sort au même endroit pendant 365 jours.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7381, 2126, 53, 5),
  (7382, 2126, 56, 5),
  (7383, 2126, 52, 5),
  (7384, 2126, 58, 5);

-- [2127] Cercle magique (niv 3, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2127, 'Cercle magique', 3, 5, NULL, 1, 1, 1, 0, 0, 'poudre d''argent et sel d''une valeur minimale de 100 po, que le sort détruit', '3 m', '', '', '1 minute', '1 heure', NULL, NULL, 0, 0, '<p>Vous créez un Cylindre d''énergies magiques, de 3 m de rayon et 6 m de haut, centré sur un point du sol que vous voyez à portée. Des runes luisantes apparaissent sur toute surface comprise dans le Cylindre, y compris le sol.</p>
<p>Choisissez un ou plusieurs types parmi les suivants : Célestes, Élémentaires, Fées, Fiélons et Morts-vivants. Le cercle affecte les créatures du ou des types retenus des façons suivantes :<br>
• La créature ne peut pénétrer dans le Cylindre de son plein gré sans recourir à des moyens magiques. Si la créature recourt à la téléportation ou au voyage interplanaire pour ce faire, elle doit d''abord réussir un jet de sauvegarde de Charisme.<br>
• La créature a le Désavantage aux jets d''attaque contre les cibles situées dans le Cylindre.<br>
• La créature ne peut pas posséder une cible comprise dans le Cylindre ni lui imposer l''état Charmé ou Effrayé.</p>
<p>À chaque incantation du sort, vous pouvez inverser l''orientation de sa magie, c''est-à-dire en empêchant toute créature du ou des types retenus de quitter le Cylindre et en protégeant les cibles qui se trouvent à l''extérieur.</p>
<p>Emplacement de niveau supérieur. La durée augmente de 1 heure par niveau d''emplacement au-delà du 3e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7385, 2127, 54, 3),
  (7386, 2127, 52, 3),
  (7387, 2127, 58, 3),
  (7388, 2127, 59, 3);

-- [2128] Chaîne d'éclairs (niv 6, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2128, 'Chaîne d''éclairs', 6, 1, NULL, 1, 1, 1, 0, 0, 'trois broches en argent', '45 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous projetez un trait de foudre vers une cible que vous voyez à portée. Trois éclairs jaillissent alors de cette cible vers un maximum de trois autres cibles, que vous choisissez, distantes de 9 m ou moins de la première. Toutes ces cibles peuvent être des créatures ou des objets, et ne peuvent être ciblées par plus d''un éclair.</p>
<p>Chaque cible effectue un jet de sauvegarde de Dextérité, et subit 10d8 dégâts de foudre en cas d''échec, la moitié en cas de réussite.</p>
<p>Emplacement de niveau supérieur. Un éclair supplémentaire jaillit de la première cible vers une autre par niveau d''emplacement au-delà du 6e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7389, 2128, 56, 6),
  (7390, 2128, 52, 6);

-- [2129] Charme-monstre (niv 4, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2129, 'Charme-monstre', 4, 3, NULL, 1, 1, 0, 0, 0, NULL, '9 m', '', '', 'action', '1 heure', NULL, NULL, 0, 0, '<p>Une créature que vous voyez à portée effectue un jet de sauvegarde de Sagesse. Ce jet s''effectue avec l''Avantage si vous ou vos alliés êtes en train de l''affronter. En cas d''échec, la cible subit l''état Charmé jusqu''à la fin du sort ou que vous ou vos alliés lui infligiez des dégâts. La créature ainsi Charmée vous est Amicale. Lorsque le sort prend fin, la cible sait que vous l''avez Charmée.</p>
<p>Emplacement de niveau supérieur. Vous pouvez cibler une créature supplémentaire par niveau d''emplacement au-delà du 4e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7391, 2129, 53, 4),
  (7392, 2129, 55, 4),
  (7393, 2129, 56, 4),
  (7394, 2129, 52, 4),
  (7395, 2129, 58, 4);

-- [2130] Charme-personne (niv 1, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2130, 'Charme-personne', 1, 3, NULL, 1, 1, 0, 0, 0, NULL, '9 m', '', '', 'action', '1 heure', NULL, NULL, 0, 0, '<p>Un Humanoïde que vous voyez à portée effectue un jet de sauvegarde de Sagesse. Ce jet s''effectue avec l''Avantage si vous ou vos alliés êtes en train de l''affronter. En cas d''échec, la cible subit l''état Charmé jusqu''à la fin du sort ou que vous ou vos alliés lui infligiez des dégâts. La créature ainsi Charmée vous est Amicale. Lorsque le sort prend fin, la cible sait que vous l''avez Charmée.</p>
<p>Emplacement de niveau supérieur. Vous pouvez cibler une créature supplémentaire par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7396, 2130, 53, 1),
  (7397, 2130, 55, 1),
  (7398, 2130, 56, 1),
  (7399, 2130, 52, 1),
  (7400, 2130, 58, 1);

-- [2131] Champ antimagie (niv 8, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2131, 'Champ antimagie', 8, 5, NULL, 1, 1, 1, 0, 0, 'limaille de fer', 'personnelle', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Une aura d''antimagie vous entoure sous forme d''une Émanation de 3 m. Nul ne peut lancer de sorts dans la zone, ni y entreprendre l''action Magie ou y produire des effets magiques. De tels effets, quelle que soit leur source, n''ont en outre aucun effet sur les cibles dans la zone. Les propriétés magiques des objets magiques ne fonctionnent pas à l''intérieur de l''aura ni sur ce qui s''y trouve.</p>
<p>Les zones d''effet produites par des sorts ou effets magiques n''englobent pas l''aura et nul ne peut se téléporter ou recourir au voyage planaire pour entrer dans l''aura ou en sortir. Les portails sont fermés tant qu''ils sont dans l''aura.</p>
<p>Les sorts en cours, à l''exception de ceux qui émanent d''un artefact ou d''une divinité, sont réprimés dans l''aura. Tant qu''un effet est réprimé, il n''est pas actif, mais tout le temps qu''il passe ainsi réprimé est décompté de sa durée.</p>
<p>Dissipation de la magie reste sans effet sur l''aura, et les auras créées par plusieurs sorts champ antimagie ne s''annulent pas mutuellement.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7401, 2131, 54, 8),
  (7402, 2131, 52, 8);

-- [2132] Changement de forme (niv 9, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2132, 'Changement de forme', 9, 4, NULL, 1, 1, 1, 0, 0, 'un diadème de jade d''une valeur minimale de 1 500 po', 'personnelle', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Vous vous métamorphosez en une autre créature pour toute la durée, mais avez la possibilité d''entreprendre l''action Magie pour adopter une autre forme couverte par le sort. La nouvelle forme doit être une créature dont le facteur de puissance n''est pas supérieur à votre niveau ou FP. Vous devez avoir déjà vu une telle créature, qui ne peut être ni un Artificiel ni un Mort-vivant.</p>
<p>En lançant ce sort, vous recevez autant de points de vie temporaires que les points de vie de la première forme adoptée. Ces points de vie temporaires disparaissent s''il en reste à la fin du sort.</p>
<p>Votre profil de jeu est remplacé par celui de la créature retenue, mais vous conservez certains de vos aspects : type de créature, alignement, personnalité, valeurs d''Intelligence, de Sagesse et de Charisme, points de vie, dés de vie, maîtrises et facultés de communication. Si vous disposez de l''aptitude Sorts ou Incantation, vous la conservez aussi.</p>
<p>Lors de la transformation, vous déterminez si votre équipement tombe au sol ou change de taille et de configuration pour s''adapter à votre nouvelle forme.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7403, 2132, 55, 9),
  (7404, 2132, 52, 9);

-- [2133] Changement de plan (niv 7, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2133, 'Changement de plan', 7, 6, NULL, 1, 1, 1, 0, 0, 'une badine métallique fourchue d''une valeur minimale de 250 po, accordée avec un plan d''existence', 'contact', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous et un maximum de huit créatures consentantes avec lesquelles vous formez un cercle en vous tenant par la main êtes transportés sur un autre plan d''existence. Vous pouvez spécifier une destination en des termes généraux, comme une cité donnée du Plan Élémentaire du Feu ou un palais précis sur la deuxième strate des Neuf Enfers, auquel cas vous apparaissez à destination ou à proximité (à l''appréciation du MJ).</p>
<p>Ou bien, si vous connaissez la séquence de runes d''un cercle de téléportation sur un autre plan d''existence, ce sort vous transporte directement dans le cercle. Si le cercle de téléportation est trop petit pour accueillir toutes les créatures transportées, elles apparaissent dans les espaces inoccupés les plus proches du cercle.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7405, 2133, 54, 7),
  (7406, 2133, 55, 7),
  (7407, 2133, 56, 7),
  (7408, 2133, 52, 7),
  (7409, 2133, 58, 7);

-- [2134] Châtiment de fournaise (niv 1, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2134, 'Châtiment de fournaise', 1, 1, NULL, 1, 0, 0, 0, 0, NULL, 'personnelle', '', '', 'action Bonus, que vous entreprenez aussitôt après avoir touché une cible avec une arme de corps à corps ou à mains nues', '1 minute', NULL, NULL, 0, 0, '<p>Alors que vous touchez la cible, elle subit 1d6 dégâts de feu supplémentaires de l''attaque. Au début de chacun de ses tours jusqu''à la fin du sort, la cible subit 1d6 dégâts de feu et effectue un jet de sauvegarde de Constitution. En cas d''échec, le sort se poursuit. En cas de réussite, le sort prend fin.</p>
<p>Emplacement de niveau supérieur. Tous les dégâts augmentent de 1d6 par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7410, 2134, 59, 1);

-- [2135] Châtiment de révélation (niv 2, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2135, 'Châtiment de révélation', 2, 4, NULL, 1, 0, 0, 0, 0, NULL, 'personnelle', '', '', 'action Bonus, que vous entreprenez aussitôt après avoir touché une créature avec une arme de corps à corps ou une attaque à mains nues', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>La cible touchée par l''attaque subit 2d6 dégâts radiants supplémentaires. Jusqu''à la fin du sort, la cible émet une Lumière vive dans un rayon de 1,50 m, les jets d''attaque contre elle ont l''Avantage et elle ne peut pas bénéficier de l''état Invisible.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d6 par niveau d''emplacement au-delà du 2e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7411, 2135, 59, 2);

-- [2136] Châtiment divin (niv 1, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2136, 'Châtiment divin', 1, 1, NULL, 1, 0, 0, 0, 0, NULL, 'personnelle', '', '', 'action Bonus, que vous entreprenez aussitôt après avoir touché une cible avec une arme de corps à corps ou à mains nues', 'instantanée', NULL, NULL, 0, 0, '<p>L''attaque inflige à la cible 2d8 dégâts radiants supplémentaires. Ces dégâts supplémentaires augmentent de 1d8 si la cible est un Fiélon ou un Mort-vivant.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d8 par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7412, 2136, 59, 1);

-- [2137] Chien de garde (niv 4, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2137, 'Chien de garde', 4, 6, NULL, 1, 1, 1, 0, 0, 'un sifflet en argent', '9 m', '', '', 'action', '8 heures', NULL, NULL, 0, 0, '<p>Vous invoquez un chien de garde fantomatique en un espace inoccupé que vous voyez à portée. Le molosse reste pour toute la durée (il disparaît toutefois si vous et lui vous retrouvez éloignés de plus de 90 m).</p>
<p>En dehors de vous, personne ne voit le chien de garde, qui est à la fois intangible et invulnérable. Quand une créature de taille S ou supérieure s''approche dans un rayon de 9 m de lui sans prononcer au préalable le mot de passe que vous avez spécifié à l''incantation du sort, le chien se met à aboyer furieusement. Le molosse est doté de la Vision lucide avec une portée de 9 m.</p>
<p>Au début de chacun de vos tours, le molosse tente de mordre un ennemi situé dans un rayon de 1,50 m de lui. Cet ennemi doit réussir un jet de sauvegarde de Dextérité sous peine de subir 4d8 dégâts de force.</p>
<p>À vos tours suivants, vous pouvez entreprendre l''action Magie pour déplacer le molosse d''un maximum de 9 m.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7413, 2137, 52, 4);

-- [2138] Clairvoyance (niv 3, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2138, 'Clairvoyance', 3, 7, NULL, 1, 1, 1, 0, 0, 'un focaliseur d''une valeur minimale de 100 po : une corne ornée pour écouter, un œil de verre pour observer', '1,5 km', '', '', '10 minutes', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Vous créez un capteur Invisible à portée en un lieu que vous connaissez (pour l''avoir déjà visité ou vu) ou en un lieu que vous ne connaissez pas, mais que vous pouvez imaginer (derrière une porte, au coin d''un couloir ou dans un bosquet d''arbres). Ce capteur intangible et invulnérable reste en place pour toute la durée.</p>
<p>À l''incantation du sort, choisissez entre écouter et observer. Vous pouvez alors recourir au sens retenu (ouïe ou vision) comme si vous vous trouviez dans l''espace du capteur. Par une action Bonus, vous pouvez passer de l''ouïe à la vision, ou réciproquement.</p>
<p>Une créature qui voit le capteur (parce qu''elle bénéficie de détection de l''invisibilité ou de la Vision lucide, par exemple) perçoit un globe lumineux de la taille de votre poing.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7414, 2138, 53, 3),
  (7415, 2138, 54, 3),
  (7416, 2138, 56, 3),
  (7417, 2138, 52, 3);

-- [2139] Clignotement (niv 3, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2139, 'Clignotement', 3, 4, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action', '1 minute', NULL, NULL, 0, 0, '<p>Lancez 1d6 à la fin de chacun de vos tours, pour toute la durée. Sur un résultat de 4 à 6, vous disparaissez de votre plan d''existence actuel pour réapparaître sur le Plan Éthéré (si vous êtes déjà sur ce dernier plan, le sort prend aussitôt fin). Tant que vous êtes sur le Plan Éthéré, vous percevez le plan d''où vous venez, mais tout est nuances de gris et votre vision ne porte que sur 18 m. Vous pouvez affecter d''autres créatures du Plan Éthéré (et elles peuvent vous affecter), tandis que les créatures situées sur l''autre plan ne vous perçoivent pas, sauf celles qui disposent d''une faculté spéciale leur permettant de percevoir ce qui se trouve sur le Plan Éthéré.</p>
<p>Vous retournez sur l''autre plan au début de votre tour suivant, ainsi que si le sort prend fin alors que vous êtes sur le Plan Éthéré. Vous réapparaissez alors en un espace inoccupé que vous voyez et choisissez dans un rayon de 3 m de l''espace que vous aviez quitté. Si aucun espace n''est libre dans ce rayon, vous apparaissez dans l''espace inoccupé le plus proche.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7418, 2139, 56, 3),
  (7419, 2139, 52, 3);

-- [2140] Clone (niv 8, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2140, 'Clone', 8, 2, NULL, 1, 1, 1, 0, 0, 'un diamant d''une valeur minimale de 1 000 po que le sort détruit et un récipient d''une valeur minimale de 2 000 po, assez grand pour contenir la créature à cloner', 'contact', '', '', '1 heure', 'instantanée', NULL, NULL, 0, 0, '<p>Vous touchez physiquement une créature ou au moins 15 cm³ de sa chair. Une réplique inerte se forme à l''intérieur d''un récipient utilisé pour l''incantation, sa croissance jusqu''à maturité demandant 120 jours. Vous décidez si le clone est une version plus jeune de la créature ou du même âge. Le clone reste inerte et immarcescible tant que le récipient n''est pas endommagé.</p>
<p>Si, une fois le clone formé, la créature d''origine meurt, son âme (à condition qu''elle soit libre et consentante) est transférée dans le clone. Le clone est identique à l''original sur le plan physique et présente la même personnalité ; ses souvenirs sont les mêmes, ainsi que ses caractéristiques, mais il ne récupère rien de l''équipement de la créature clonée. La dépouille du cloné, si elle existe, devient inerte et ne pourra être ramenée à la vie, étant donné que l''âme de la créature est ailleurs.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7420, 2140, 52, 8);

-- [2141] Coffre secret (niv 4, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2141, 'Coffre secret', 4, 6, NULL, 1, 1, 1, 0, 0, 'un coffre de 90 cm par 60 et 60, fait de matériaux rares d''une valeur minimale de 5 000 po, et sa réplique de taille TP faite des mêmes matériaux d''une valeur minimale de 50 po', 'contact', '', '', 'action', 'jusqu''à dissipation', NULL, NULL, 0, 0, '<p>Vous cachez un coffre et son contenu sur le Plan Éthéré. Vous devez toucher le coffre et la réplique miniature qui sert de composante matérielle pour le sort. Le coffre peut renfermer un maximum de 0,3 m³ de matière non vivante (90 × 60 × 60 cm).</p>
<p>Tant que le coffre reste sur le Plan Éthéré, vous pouvez entreprendre l''action Magie pour toucher la réplique et rappeler le coffre. Il réapparaît au sol, en un espace inoccupé dans un rayon de 1,50 m de vous. Vous pouvez le renvoyer sur le Plan Éthéré au prix de l''action Magie, en touchant simultanément le coffre et sa réplique.</p>
<p>Au bout de 60 jours, 5 % de risque s''accumulent chaque jour que le sort prenne fin. Le sort prend aussi fin si vous le relancez ou si la réplique de taille TP est détruite. Si le sort prend fin alors que le grand coffre se trouve sur le Plan Éthéré, celui-ci reste sur ce plan en attendant d''être retrouvé.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7421, 2141, 52, 4);

-- [2142] Colonne de flamme (niv 5, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2142, 'Colonne de flamme', 5, 1, NULL, 1, 1, 1, 0, 0, 'une pincée de soufre', '18 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Une colonne verticale de flammes radieuses surgit des hauteurs. Chaque créature prise dans un Cylindre d''un rayon de 3 m, haut de 12 m et centré sur un point à portée effectue un jet de sauvegarde de Dextérité. Elle subit 5d6 dégâts de feu et 5d6 dégâts radiants en cas d''échec, la moitié en cas de réussite.</p>
<p>Emplacement de niveau supérieur. Les dégâts de feu et les dégâts radiants augmentent chacun de 1d6 par niveau d''emplacement au-delà du 5e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7422, 2142, 54, 5);

-- [2143] Communication avec les animaux (niv 1, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2143, 'Communication avec les animaux', 1, 7, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action ou rituel', '10 minutes', NULL, NULL, 0, 1, '<p>Pour toute la durée, vous avez la faculté de comprendre les Bêtes et de communiquer verbalement avec elles, et toutes les options de compétence de l''action Influence vous sont accessibles avec elles.</p>
<p>La plupart des Bêtes ont peu à dire au-delà des sujets de survie et d''affection, mais toutes sont capables de vous informer sur les environs et les monstres locaux, notamment ce qu''elles ont perçu au cours de la dernière journée.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7423, 2143, 53, 1),
  (7424, 2143, 55, 1),
  (7425, 2143, 58, 1),
  (7426, 2143, 60, 1);

-- [2144] Communication à distance (niv 3, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2144, 'Communication à distance', 3, 7, NULL, 1, 1, 1, 0, 0, 'du fil de cuivre', 'illimitée', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous envoyez un bref message n''excédant pas 25 mots à une créature que vous avez rencontrée (ou qu''une personne qui l''a rencontrée vous a décrite). L''esprit de la cible perçoit le message, celle-ci vous identifie comme expéditeur si elle vous connaît et peut vous répondre aussitôt dans le même mode. Le sort permet aux cibles de comprendre le sens de votre message.</p>
<p>La distance qui vous sépare du destinataire n''a pas d''importance et vous pouvez même atteindre d''autres plans d''existence, mais si la cible se trouve sur un plan différent, il y a 5 % de chance pour que le message n''aboutisse pas. Si la transmission ne s''est pas faite, vous le savez.</p>
<p>À la réception du message, la créature peut vous empêcher de la recontacter par ce sort pour les 8 prochaines heures. Si vous tentez de lui envoyer un autre message dans cet intervalle, vous savez qu''elle vous a bloqué et le sort échoue.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7427, 2144, 53, 3),
  (7428, 2144, 54, 3),
  (7429, 2144, 52, 3);

-- [2145] Communication avec les morts (niv 3, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2145, 'Communication avec les morts', 3, 2, NULL, 1, 1, 1, 0, 0, 'de l''encens qui brûle', '3 m', '', '', 'action', '10 minutes', NULL, NULL, 0, 0, '<p>Vous octroyez un semblant de vie à un cadavre que vous choisissez à portée, pour qu''il puisse répondre aux questions que vous lui posez. La dépouille doit disposer d''une bouche et le sort échoue si la créature décédée était un Mort-vivant au moment de trépasser. Le sort échoue également si le cadavre a déjà été ciblé par ce sort au cours des 10 derniers jours.</p>
<p>Jusqu''à la fin du sort, vous pouvez poser jusqu''à cinq questions à la dépouille. Elle ne sait rien de plus que de son vivant et parle toujours les mêmes langues. Ses réponses ont tendance à se montrer brèves, sibyllines ou répétitives, d''autant que le cadavre n''est nullement contraint de vous répondre avec sincérité si vous lui êtes antipathique ou s''il vous voit comme un ennemi. Ce sort ne ramène pas l''âme de la créature dans son corps ; il ne fait qu''animer son esprit. Ainsi, le cadavre ne peut rien apprendre de nouveau ni comprendre ce qui a pu se passer depuis son décès, et ne peut pas davantage conjecturer sur l''avenir.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7430, 2145, 53, 3),
  (7431, 2145, 54, 3),
  (7432, 2145, 52, 3);

-- [2146] Communication avec les plantes (niv 3, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2146, 'Communication avec les plantes', 3, 4, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action', '10 minutes', NULL, NULL, 0, 0, '<p>Vous investissez la flore comprise dans une Émanation immobile de 9 m d''une conscience limitée et de mouvements, de quoi lui permettre de communiquer avec vous et de suivre vos instructions rudimentaires. Vous pouvez interroger ces plantes sur ce qui s''est passé dans la zone du sort depuis un jour, notamment la nature des créatures qui l''ont traversée, le temps qu''il a fait et autres détails.</p>
<p>Vous pouvez également transformer tout Terrain difficile engendré par la végétation (buissons et sous-bois, par exemple) en terrain ordinaire qui persiste pour toute la durée. Ou bien transformer un terrain ordinaire pourvu de végétation en Terrain difficile qui persiste pour toute la durée.</p>
<p>Le sort ne permet pas aux plantes de se déraciner pour se déplacer, mais elles peuvent agiter leurs branches, leurs vrilles et leurs pédoncules.</p>
<p>Si une créature de type Plante se trouve dans la zone, vous pouvez communiquer avec elle comme si vous parliez une langue commune.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7433, 2146, 53, 3),
  (7434, 2146, 55, 3),
  (7435, 2146, 60, 3);

-- [2147] Communion (niv 5, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2147, 'Communion', 5, 7, NULL, 1, 1, 1, 0, 0, 'encens', 'personnelle', '', '', '1 minute ou rituel', '1 minute', NULL, NULL, 0, 1, '<p>Vous contactez une divinité ou un intermédiaire divin pour lui poser trois questions auxquelles on peut répondre par l''affirmative ou la négative. Vous devez poser vos questions avant la fin du sort. Vous recevez une réponse juste à chaque question.</p>
<p>Les êtres divins ne sont pas forcément omniscients, si bien que vous pouvez recevoir « incertain » comme réponse (au lieu de « oui » ou « non ») si la question fait appel à des éléments qui s''écartent du domaine de connaissance de la déité. Si une réponse en un mot peut s''avérer trompeuse ou contraire aux intérêts de la divinité, le MJ peut se fendre d''une courte phrase en guise de réponse.</p>
<p>Si vous lancez le sort plus d''une fois avant de terminer votre prochain Repos long, vous courez dès la deuxième incantation 25 % de risques cumulatifs qu''il ne vous livre aucune réponse.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7436, 2147, 54, 5);

-- [2148] Communion avec la nature (niv 5, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2148, 'Communion avec la nature', 5, 7, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', '1 minute ou rituel', 'instantanée', NULL, NULL, 0, 1, '<p>Vous communiez avec des esprits de la nature en quête d''informations sur les environs. En extérieur, le sort vous investit des connaissances de la zone dans un rayon de 4,5 km. Dans une grotte et en milieu souterrain naturel, ce rayon est limité à 90 m. Le sort reste sans effet dans les endroits où la nature a laissé place aux constructions, comme dans un château ou dans un bourg.</p>
<p>Choisissez trois éléments parmi les suivants ; vous prenez connaissance de ces éléments, en relation avec la zone concernée :<br>
• Position des communautés implantées<br>
• Position des portails vers d''autres plans d''existence<br>
• Position d''une créature dont le facteur de puissance est d''au moins 10 (choisie par le MJ) et dont le type est Céleste, Élémentaire, Fée, Fiélon ou Mort-vivant<br>
• Type de plante, minéral ou Bête le plus courant (choisissez sur quel aspect vous informer)<br>
• Localisation des plans et cours d''eau</p>
<p>Ainsi, vous pouvez déterminer où se trouve un puissant monstre de la zone, les plans et cours d''eau, et les bourgs des environs.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7437, 2148, 55, 5),
  (7438, 2148, 60, 5);

-- [2149] Compréhension des langues (niv 1, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2149, 'Compréhension des langues', 1, 7, NULL, 1, 1, 1, 0, 0, 'une pincée de suie et de sel', 'personnelle', '', '', 'action ou rituel', '1 heure', NULL, NULL, 0, 1, '<p>Pour toute la durée, vous comprenez le sens littéral de toute langue parlée que vous entendez. Vous comprenez également tout écrit que vous voyez, à condition de toucher la surface sur laquelle il est rédigé. Il vous faut environ 1 minute pour lire une page de texte. Ce sort ne décrypte pas les symboles ni les messages secrets.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7439, 2149, 53, 1),
  (7440, 2149, 56, 1),
  (7441, 2149, 52, 1),
  (7442, 2149, 58, 1);

-- [2150] Compulsion (niv 4, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2150, 'Compulsion', 4, 3, NULL, 1, 1, 0, 0, 0, NULL, '9 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Chaque créature de votre choix parmi celles que vous voyez à portée doit réussir un jet de sauvegarde de Sagesse sous peine de subir l''état Charmé jusqu''à la fin du sort.</p>
<p>Pour toute la durée, vous pouvez par une action Bonus désigner une direction qui vous est horizontale. Chaque cible Charmée doit, à son tour suivant, consacrer autant de son déplacement que possible à se déplacer dans cette direction, selon le chemin le plus sûr. Une fois ce déplacement terminé, la cible réitère le JS et met un terme au sort sur elle-même en cas de réussite.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7443, 2150, 53, 4);

-- [2151] Cône de froid (niv 5, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2151, 'Cône de froid', 5, 1, NULL, 1, 1, 1, 0, 0, 'un petit cône de verre ou de cristal', 'personnelle', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous libérez une gerbe d''air glacial. Chaque créature prise dans un Cône de 18 m émanant de vous effectue un jet de sauvegarde de Constitution et subit 8d8 dégâts de froid en cas d''échec, la moitié en cas de réussite. Une créature tuée par ce sort se transforme en statue givrée, jusqu''à ce qu''elle dégèle.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d8 par niveau d''emplacement au-delà du 5e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7444, 2151, 55, 5),
  (7445, 2151, 56, 5),
  (7446, 2151, 52, 5);

-- [2152] Confusion (niv 4, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2152, 'Confusion', 4, 3, NULL, 1, 1, 1, 0, 0, 'trois coquilles de noix', '27 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Chaque créature prise dans une Sphère de 3 m de rayon centrée sur un point que vous choisissez à portée doit réussir un jet de sauvegarde de Sagesse, sous peine de ne pas pouvoir jouer de Réaction ni entreprendre d''action Bonus et de devoir jeter 1d10 au début de chacun de ses tours pour savoir comment elle se comporte à ce tour.</p>
<p>1d10 — Comportement du tour<br>
1 — La cible n''entreprend aucune action et consacre tout son déplacement à se déplacer. Lancez 1d4 pour la direction : 1, nord ; 2, est ; 3, sud ; 4, ouest.<br>
2–6 — La cible ne se déplace pas et n''entreprend aucune action.<br>
7–8 — La cible ne se déplace pas et entreprend l''action Attaque contre une créature aléatoire à portée d''allonge. Si aucune créature n''est à portée d''allonge, la cible n''entreprend aucune action.<br>
9–10 — La cible agit et se déplace à sa guise.</p>
<p>La cible affectée réitère le JS à la fin de chacun de ses tours et met un terme au sort sur elle-même en cas de réussite.</p>
<p>Emplacement de niveau supérieur. Le rayon de la Sphère augmente de 1,50 m par niveau d''emplacement au-delà du 4e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7447, 2152, 53, 4),
  (7448, 2152, 55, 4),
  (7449, 2152, 56, 4),
  (7450, 2152, 52, 4);

-- [2153] Contact avec les plans (niv 5, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2153, 'Contact avec les plans', 5, 7, NULL, 1, 0, 0, 0, 0, NULL, 'personnelle', '', '', '1 minute ou rituel', '1 minute', NULL, NULL, 0, 1, '<p>Vous contactez mentalement un demi-dieu, l''esprit d''un sage défunt ou quelque autre entité érudite d''un autre plan. Le contact avec une telle conscience extraplanaire peut vous anéantir l''esprit. À l''incantation du sort, effectuez un jet de sauvegarde d''Intelligence DD 15. En cas de sauvegarde réussie, vous pouvez poser jusqu''à cinq questions à l''entité. Vous devez les poser avant la fin du sort. Le MJ répond à chaque question par un seul mot, comme « oui », « non », « peut-être », « jamais », « inconséquent » ou « incertain » (si l''entité ne connaît pas la réponse). Si une réponse en un mot risque de s''avérer trompeuse, le MJ peut se fendre d''une courte phrase.</p>
<p>En cas d''échec, vous subissez 6d6 dégâts psychiques, ainsi que l''état Neutralisé jusqu''à ce que vous terminiez un Repos long. Le sort restauration suprême lancé sur vous met un terme à cet effet.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7451, 2153, 52, 5),
  (7452, 2153, 58, 5);

-- [2154] Contact glacial (niv 0, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2154, 'Contact glacial', 0, 2, NULL, 1, 1, 0, 0, 0, NULL, 'contact', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous canalisez l''étreinte d''outre-tombe et effectuez une attaque de sort au corps à corps contre une cible à portée d''allonge. Si l''attaque touche, la cible subit 1d10 dégâts nécrotiques et ne peut pas récupérer de points de vie jusqu''à la fin de votre tour suivant.</p>
<p>Amélioration de sort mineur. Les dégâts augmentent de 1d10 lorsque vous atteignez les niveaux 5 (2d10), 11 (3d10) et 17 (4d10).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7453, 2154, 56, 0),
  (7454, 2154, 52, 0),
  (7455, 2154, 58, 0);

-- [2155] Contagion (niv 5, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2155, 'Contagion', 5, 2, NULL, 1, 1, 0, 0, 0, NULL, 'contact', '', '', 'action', '7 jours', NULL, NULL, 0, 0, '<p>Votre contact transmet une maladie magique. La cible doit réussir un jet de sauvegarde de Constitution sous peine de subir 11d8 dégâts nécrotiques, ainsi que l''état Empoisonné. Vous désignez également une caractéristique à l''incantation. Tant que la cible est Empoisonnée, elle subit le Désavantage aux jets de sauvegarde associés à la caractéristique retenue.</p>
<p>La cible réitère le jet de sauvegarde à la fin de chacun de ses tours jusqu''à ce qu''elle ait obtenu trois réussites ou trois échecs. Si la cible réussit trois de ces JS, le sort prend fin sur elle. Si elle rate trois de ces JS, le sort persiste sur elle pendant 7 jours.</p>
<p>Chaque fois que la cible Empoisonnée reçoit un effet censé mettre fin à son état Empoisonné, elle doit réussir un jet de sauvegarde de Constitution, sans quoi l''état Empoisonné ne prend pas fin.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7456, 2155, 54, 5),
  (7457, 2155, 55, 5);

-- [2156] Contamination (niv 6, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2156, 'Contamination', 6, 2, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous libérez une magie virulente sur une créature que vous voyez à portée. La cible effectue un jet de sauvegarde de Constitution. En cas d''échec, elle subit 14d6 dégâts nécrotiques et son maximum de points de vie est réduit d''autant que les dégâts nécrotiques subis. En cas de réussite, elle subit uniquement la moitié de ces dégâts. Ce sort ne peut réduire son maximum de points de vie en dessous de 1.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7458, 2156, 54, 6);

-- [2157] Contresort (niv 3, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2157, 'Contresort', 3, 5, NULL, 0, 1, 0, 0, 0, NULL, '18 m', '', '', 'Réaction, que vous jouez en voyant dans un rayon de 18 m une créature lancer un sort avec une composante verbale, somatique ou matérielle', 'instantanée', NULL, NULL, 0, 0, '<p>Vous tentez d''interrompre une créature en pleine incantation. La créature effectue un jet de sauvegarde de Constitution. En cas d''échec, son sort se dissipe sans effet et l''action, l''action Bonus ou la Réaction entreprise pour l''incantation est gaspillée. Si ce sort était lancé par un emplacement, celui-ci n''est pas dépensé.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7459, 2157, 56, 3),
  (7460, 2157, 52, 3),
  (7461, 2157, 58, 3);

-- [2158] Contrôle de l'eau (niv 4, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2158, 'Contrôle de l''eau', 4, 4, NULL, 1, 1, 1, 0, 0, 'un mélange d''eau et de poussière', '90 m', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Jusqu''à la fin du sort, vous contrôlez tout volume d''eau compris dans la zone que vous désignez, un Cube dont l''arête ne dépasse pas 30 m, en y appliquant l''un des effets suivants. Au prix de l''action Magie à vos tours suivants, vous pouvez répéter le même effet ou en choisir un autre.</p>
<p>Contrôle du courant. Vous réorientez le cours des eaux de la zone à votre guise, même si les flots doivent surmonter des obstacles, grimper aux murs ou couler dans une direction insolite. Les eaux s''écoulent selon vos instructions, mais une fois qu''elles quittent la zone, la nature reprend ses droits et le courant s''adapte au terrain. Les eaux continuent à couler dans la direction de votre choix jusqu''à la fin du sort ou jusqu''à ce que vous optiez pour un autre effet.</p>
<p>Crue. Vous faites monter le niveau de toutes les eaux dormantes de la zone d''un maximum de 6 m. Si vous choisissez une zone comprise dans un grand plan d''eau, vous engendrez en fait une vague haute de 6 m qui part d''un côté de la zone et déferle vers l''autre avant de s''écraser. Tous les véhicules de taille TG ou inférieure pris sur son passage sont emportés de l''autre côté et ceux frappés par la vague ont 25 % de risque de chavirer.<br>
Le niveau de l''eau reste haut jusqu''à la fin du sort ou jusqu''à ce que vous optiez pour un autre effet. Si cet effet a produit une vague, celle-ci se répète au début de votre tour suivant tant que persiste l''effet de crue.</p>
<p>Séparation des eaux. Vous scindez les eaux de la zone pour créer une tranchée. Cette fosse s''étend sur toute la zone du sort, les eaux séparées formant une paroi verticale de chaque côté. La tranchée reste en place jusqu''à la fin du sort ou jusqu''à ce que vous optiez pour un autre effet. Les eaux la remplissent ensuite progressivement en l''espace d''un round, jusqu''à retrouver leur niveau initial.</p>
<p>Tourbillon. Vous engendrez la création d''un tourbillon au centre de la zone, d''une surface minimale de 15 m de côté et d''une profondeur d''au moins 7,50 m. Le tourbillon persiste jusqu''à ce que vous optiez pour un autre effet ou que le sort prenne fin. Les remous sont larges de 1,50 m à leur base pour atteindre jusqu''à 15 m au sommet, pour une hauteur de 7,50 m. Toute créature immergée dans l''eau et située dans un rayon de 7,50 m du tourbillon est tirée de 3 m vers les remous. Lorsqu''une créature entre dans les remous pour la première fois d''un tour ou y termine son tour, elle effectue un jet de sauvegarde de Force. En cas d''échec, elle subit 2d8 dégâts contondants ; en cas de réussite, la moitié. Une créature peut s''éloigner du tourbillon à la nage à condition de consacrer au préalable une action à s''en extraire et de réussir un test de Force (Athlétisme) assorti de votre DD de sauvegarde des sorts.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7462, 2158, 54, 4),
  (7463, 2158, 55, 4),
  (7464, 2158, 52, 4);

-- [2159] Contrôle du climat (niv 8, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2159, 'Contrôle du climat', 8, 4, NULL, 1, 1, 1, 0, 0, 'de l''encens qui brûle', 'personnelle', '', '', '10 minutes', 'Concentration, jusqu''à 8 heures', NULL, NULL, 1, 0, '<p>Vous prenez le contrôle du climat dans un rayon de 7,5 km pour toute la durée. Vous devez vous trouver en extérieur pour lancer ce sort, qui prend fin prématurément dès que vous êtes à l''intérieur.</p>
<p>À l''incantation du sort, vous altérez les conditions climatiques du moment, déterminées par le MJ. Vous pouvez modifier les précipitations, la température et le vent. Les nouvelles conditions mettent 1d4 × 10 minutes à prendre effet. Après ce laps de temps, vous pouvez à nouveau altérer les conditions. Quand le sort prend fin, le temps revient progressivement à la normale.</p>
<p>Lorsque vous changez les conditions climatiques, identifiez celles du moment dans les tables qui suivent et changez-en le stade d''un cran, vers le haut ou le bas. Lorsque vous modifiez le vent, vous pouvez en changer la direction.</p>
<p>Précipitations<br>
Stade 1 — Ciel dégagé<br>
Stade 2 — Quelques nuages<br>
Stade 3 — Ciel chargé ou brume au sol<br>
Stade 4 — Pluie, grêle ou neige<br>
Stade 5 — Pluie torrentielle, grêle battante ou blizzard</p>
<p>Température<br>
Stade 1 — Caniculaire<br>
Stade 2 — Chaud<br>
Stade 3 — Doux<br>
Stade 4 — Frais<br>
Stade 5 — Froid<br>
Stade 6 — Glacial</p>
<p>Vent<br>
Stade 1 — Calme<br>
Stade 2 — Vent modéré<br>
Stade 3 — Vent fort<br>
Stade 4 — Vent violent<br>
Stade 5 — Tempête</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7465, 2159, 54, 8),
  (7466, 2159, 55, 8),
  (7467, 2159, 52, 8);

-- [2160] Convocation de dragon (niv 5, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2160, 'Convocation de dragon', 5, 6, NULL, 1, 1, 1, 0, 0, 'un objet gravé d''une représentation de dragon, d''une valeur minimale de 500 po', '18 m', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Vous invoquez un esprit draconique. Il se manifeste en un espace inoccupé que vous voyez à portée en reprenant le profil de l''esprit draconique. La créature disparaît quand le sort prend fin, mais également si elle tombe à 0 point de vie.</p>
<p>La créature constitue un allié pour vous et vos alliés. Au combat, la créature partage votre rang d''Initiative, mais elle joue son tour juste après vous. Elle obéit à vos instructions verbales (pas d''action requise de votre part). Sans ordre de votre part, elle entreprend l''action Esquive et consacre son déplacement à se mettre à l''abri du danger.</p>
<p>Emplacement de niveau supérieur. Le niveau de l''emplacement s''applique chaque fois que le profil de jeu y fait référence.</p>
<p>— Esprit draconique —<br>
Dragon de taille G, Neutre<br>
CA 14 + niveau du sort<br>
Pv 50 + 10 par niveau du sort au-delà du 5e<br>
Vitesse 9 m, nage 9 m, vol 18 m<br>
For 19 (+4, JS +4) ; Dex 14 (+2, +2) ; Con 17 (+3, +3) ; Int 10 (+0, +0) ; Sag 14 (+2, +2) ; Cha 14 (+2, +2)<br>
Résistances acide, feu, froid, foudre, poison<br>
Immunités Charmé, Effrayé, Empoisonné<br>
Sens Vision aveugle 9 m, Vision dans le noir 18 m ; Perception passive 12<br>
Langues draconique, comprend les langues que vous connaissez<br>
FP aucun (PX 0 ; BM égal à votre bonus de maîtrise)<br>
Traits — Résistances partagées. Lorsque vous convoquez l''esprit, choisissez l''une de ses Résistances aux dégâts. Vous bénéficiez de la Résistance au type de dégâts choisi jusqu''à la fin du sort.<br>
Actions — Attaques multiples. L''esprit effectue autant d''attaques de Saignée que la moitié du niveau de ce sort (arrondi à l''inférieur) et il recourt à Souffle.<br>
Saignée. Corps à corps : Bonus égal à votre modificateur d''attaque des sorts, allonge 3 m. Touché : 1d6 + 4 + le niveau du sort dégâts perforants.<br>
Souffle. JS Dextérité : DD égal à votre DD de sauvegarde des sorts, chaque créature dans un cône de 9 m. Échec : 2d6 dégâts d''un type auquel l''esprit a la Résistance (vous choisissez à l''incantation du sort). Réussite : 1/2 dégâts.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7468, 2160, 52, 5);

-- [2161] Convocations instantanées (niv 6, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2161, 'Convocations instantanées', 6, 6, NULL, 1, 1, 1, 0, 0, 'un saphir d''une valeur minimale de 1 000 po', 'contact', '', '', '1 minute ou rituel', 'jusqu''à dissipation', NULL, NULL, 0, 1, '<p>Vous touchez le saphir de l''incantation et un objet d''un poids maximal de 5 kg et dont la dimension la plus grande n''excède pas 1,80 m. Le sort laisse une marque Invisible sur l''objet et inscrit invisiblement le nom de l''objet sur le saphir. Chaque fois que vous lancez ce sort, vous devez utiliser un saphir différent.</p>
<p>Par la suite, vous pouvez entreprendre l''action Magie pour prononcer le nom de l''objet et broyer le saphir. L''objet apparaît aussitôt dans votre main, quelle que soit la distance qui vous en sépare, même s''il est sur un autre plan, puis le sort prend fin.</p>
<p>Si une autre créature tient ou porte l''objet, broyer le saphir ne le transporte pas, mais vous savez en revanche qui est cette créature et où elle se trouve à l''instant même.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7469, 2161, 52, 6);

-- [2162] Coquille antivie (niv 5, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2162, 'Coquille antivie', 5, 5, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Une aura rayonne depuis vous pour toute la durée, sous forme d''une Émanation de 3 m. L''aura empêche les créatures autres que les Artificiels et les Morts-vivants de la franchir ou même d''y passer quelque partie de leur anatomie. Une créature affectée peut en revanche lancer des sorts ou effectuer des attaques à distance (ou avec des armes à allonge) à travers la barrière.</p>
<p>Si votre déplacement oblige une créature affectée à traverser la barrière, le sort prend fin.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7470, 2162, 55, 5);

-- [2163] Corde enchantée (niv 2, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2163, 'Corde enchantée', 2, 4, NULL, 1, 1, 1, 0, 0, 'de la corde', 'contact', '', '', 'action', '1 heure', NULL, NULL, 0, 0, '<p>Vous touchez une corde. Une extrémité de la corde se dresse dans les airs jusqu''à ce que toute la corde soit perpendiculaire au sol ou qu''elle atteigne un plafond. À son extrémité supérieure, un portail Invisible de 1,50 m sur 90 cm donne sur un espace extradimensionnel qui persiste jusqu''à la fin du sort. On peut accéder à cet espace en grimpant au sommet de la corde qu''on peut haler dans l''espace ou laisser choir de l''ouverture.</p>
<p>L''espace peut accueillir un maximum de huit créatures de taille M ou inférieure. Les attaques, sorts et autres effets ne peuvent franchir l''entrée de l''espace extradimensionnel, dans un sens comme dans l''autre, mais ses occupants voient ce qui se passe à l''extérieur. Tout ce qui se trouve à l''intérieur de l''espace tombe quand le sort prend fin.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7471, 2163, 52, 2);

-- [2164] Couleurs dansantes (niv 1, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2164, 'Couleurs dansantes', 1, 9, NULL, 1, 1, 1, 0, 0, 'une pincée de sable coloré', 'personnelle', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous projetez une gerbe éblouissante de lumière colorée. Chaque créature prise dans un Cône de 4,50 m émanant de vous doit réussir un jet de sauvegarde de Constitution sous peine de subir l''état Aveuglé jusqu''à la fin de votre tour suivant.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7472, 2164, 53, 1),
  (7473, 2164, 56, 1),
  (7474, 2164, 52, 1);

-- [2165] Coup au but (niv 0, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2165, 'Coup au but', 0, 7, NULL, 0, 1, 1, 0, 0, 'une arme dont vous avez la maîtrise, d''une valeur minimale de 1 pc', 'personnelle', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Une fulgurance magique vous guide pour effectuer une attaque avec l''arme utilisée pour l''incantation. Les jets d''attaque et de dégâts correspondants se basent sur votre caractéristique d''incantation, au lieu de la Force ou la Dextérité. Si l''attaque inflige des dégâts, il peut s''agir de dégâts radiants ou des dégâts normaux de l''arme (à votre convenance).</p>
<p>Amélioration de sort mineur. Que vous infligiez des dégâts radiants ou les dégâts normaux de l''arme, l''attaque inflige des dégâts radiants supplémentaires lorsque vous atteignez les niveaux 5 (1d6), 11 (2d6) et 17 (3d6).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7475, 2165, 53, 0),
  (7476, 2165, 56, 0),
  (7477, 2165, 52, 0),
  (7478, 2165, 58, 0);

-- [2166] Couteau de glace (niv 1, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2166, 'Couteau de glace', 1, 6, NULL, 0, 1, 1, 0, 0, 'une goutte d''eau ou un morceau de glace', '18 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous créez un fragment de glace que vous lancez sur une créature à portée. Effectuez une attaque de sort à distance contre la cible. Si l''attaque touche, la cible subit 1d10 dégâts perforants. Que l''attaque touche ou rate, le fragment explose alors. La cible et toutes les créatures situées dans un rayon de 1,50 m d''elle doivent réussir un jet de sauvegarde de Dextérité, sous peine de subir 2d6 dégâts de froid.</p>
<p>Emplacement de niveau supérieur. Les dégâts de froid augmentent de 1d6 par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7479, 2166, 55, 1),
  (7480, 2166, 56, 1),
  (7481, 2166, 52, 1);

-- [2167] Création (niv 5, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2167, 'Création', 5, 9, NULL, 1, 1, 1, 0, 0, 'un pinceau', '9 m', '', '', '1 minute', 'spéciale', NULL, NULL, 0, 0, '<p>Vous extrayez des volutes de matière ombreuse issue de Gisombre pour créer un objet à portée. L''objet est soit en matière végétale (textile, corde, bois, etc.) soit en matière minérale (pierre, cristal, métal et autres). L''objet doit rentrer dans un Cube de 1,50 m et sa forme comme sa matière doivent correspondre à quelque chose que vous avez déjà vu.</p>
<p>La durée du sort dépend de la matière de l''objet, comme indiqué sur la table Matières. Si l''objet est composé de plusieurs matières, c''est la durée la plus courte qui s''applique. Recourir à un objet créé par ce sort comme composante matérielle d''un autre sort fait échouer celui-ci.</p>
<p>Matières<br>
Matière végétale — 24 heures<br>
Pierre ou cristal — 12 heures<br>
Métal précieux — 1 heure<br>
Gemme — 10 minutes<br>
Adamantium ou mithral — 1 minute</p>
<p>Emplacement de niveau supérieur. L''arête du Cube augmente de 1,50 m par niveau d''emplacement au-delà du 5e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7482, 2167, 56, 5),
  (7483, 2167, 52, 5);

-- [2168] Création de mort-vivant (niv 6, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2168, 'Création de mort-vivant', 6, 2, NULL, 1, 1, 1, 0, 0, 'un onyx noir d''une valeur minimale de 150 po pour chaque cadavre', '3 m', '', '', '1 minute', 'instantanée', NULL, NULL, 0, 0, '<p>Vous ne pouvez lancer ce sort que de nuit. Choisissez jusqu''à trois cadavres d''Humanoïdes de taille M ou P à portée. Chaque cadavre devient une goule sous votre contrôle (profil dans « Monstres »).</p>
<p>Par une action Bonus à chacun de vos tours, vous pouvez donner des ordres mentaux à toute créature que vous avez créée par ce sort et qui se trouve dans un rayon de 36 m de vous. Vous pouvez ainsi contrôler plusieurs créatures, en les choisissant, à condition de leur intimer le même ordre. Vous décidez quelle action la créature va entreprendre et où elle se déplacera à son tour suivant, ou pouvez vous contenter de donner une instruction générale, comme garder un lieu donné. Sans instruction de votre part, la créature entreprend l''action Esquive et ne se déplace que pour éviter les dangers. Une fois qu''elle a reçu un ordre, la créature s''y soumet jusqu''à ce que la tâche soit accomplie.</p>
<p>La créature reste sous votre contrôle pendant 24 heures, après quoi elle cesse d''obéir aux ordres que vous lui avez donnés. Pour garder le contrôle du Mort-vivant pendant 24 heures de plus, vous devez relancer ce sort sur lui avant la fin des 24 heures en cours. Relancer le sort ainsi réaffirme votre emprise sur un maximum de trois créatures que vous avez animées par ce sort, au lieu d''en animer de nouvelles.</p>
<p>Emplacement de niveau supérieur. Avec un emplacement du 7e niveau, vous prenez ou prolongez le contrôle de quatre goules. Avec un emplacement du 8e niveau, vous prenez ou prolongez le contrôle de cinq goules, ou de deux blêmes ou nécrontes. Avec un emplacement du 9e niveau, vous prenez ou prolongez le contrôle de six goules, de trois blêmes ou nécrontes, ou de deux momies. Vous trouverez ces profils à la section « Monstres ».</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7484, 2168, 54, 6),
  (7485, 2168, 52, 6),
  (7486, 2168, 58, 6);

-- [2169] Création de nourriture et d'eau (niv 3, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2169, 'Création de nourriture et d''eau', 3, 6, NULL, 1, 1, 0, 0, 0, NULL, '9 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous créez 22,5 kg de nourriture et 120 litres d''eau potable qui apparaissent au sol ou dans des récipients à portée, de quoi mettre à l''abri de la faim et de la soif. La nourriture est fade, mais nourrissante, avec l''aspect des aliments de votre choix, et l''eau est propre. La nourriture se gâte si elle n''est pas consommée dans les 24 heures.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7487, 2169, 54, 3),
  (7488, 2169, 59, 3);

-- [2170] Création ou destruction d'eau (niv 1, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2170, 'Création ou destruction d''eau', 1, 4, NULL, 1, 1, 1, 0, 0, 'un mélange d''eau et de sable', '9 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous accomplissez l''une des tâches suivantes :</p>
<p>Création d''eau. Vous créez jusqu''à 40 litres d''eau propre dans un récipient ouvert à portée. Une autre option consiste à faire pleuvoir cette eau dans un Cube de 9 m à portée, ce qui éteint les flammes nues de la zone.</p>
<p>Destruction d''eau. Vous détruisez jusqu''à 40 litres d''eau dans un récipient ouvert à portée. Au lieu de cela, vous pouvez chasser le brouillard dans un Cube de 9 m à portée.</p>
<p>Emplacement de niveau supérieur. Vous créez ou détruisez 40 litres supplémentaires d''eau (ou l''arête du Cube augmente de 1,50 m) par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7489, 2170, 54, 1),
  (7490, 2170, 55, 1);

-- [2171] Croissance d'épines (niv 2, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2171, 'Croissance d''épines', 2, 4, NULL, 1, 1, 1, 0, 0, 'sept épines', '45 m', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Le sol dans une Sphère de 6 m de rayon centrée sur un point à portée laisse émerger des pointes et épines coriaces. La zone devient un Terrain difficile pour toute la durée. Lorsqu''une créature pénètre dans la zone ou s''y déplace, elle subit 2d4 dégâts perforants par tranche de 1,50 m qu''elle y parcourt.</p>
<p>La transformation du sol paraît naturelle. Toute créature qui ne voit pas la zone au moment de l''incantation doit entreprendre l''action Observation et réussir un test de Sagesse (Perception ou Survie) assorti de votre DD de sauvegarde des sorts pour reconnaître le danger avant de fouler ce sol.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7491, 2171, 55, 2),
  (7492, 2171, 60, 2);

-- [2172] Croissance végétale (niv 3, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2172, 'Croissance végétale', 3, 4, NULL, 1, 1, 0, 0, 0, NULL, '45 m', '', '', 'action (Embroussaillement) ou 8 heures (Fertilisation)', 'instantanée', NULL, NULL, 0, 0, '<p>Ce sort gorge les plantes de vitalité. La durée d''incantation employée détermine l''effet du sort : Embroussaillement ou Fertilisation, ci-après.</p>
<p>Embroussaillement. Choisissez un point à portée. Toutes les plantes normales dans une Sphère d''un rayon de 30 m centré sur ce point grossissent et grandissent. Une créature qui se déplace dans la zone doit dépenser le quadruple de déplacement pour toute distance parcourue. Vous pouvez désigner une ou plusieurs zones de n''importe quelle taille dans la zone d''effet du sort pour qu''elles ne soient pas affectées.</p>
<p>Fertilisation. Toutes les plantes dans un rayon de 750 m d''un point à portée gagnent en fécondité pendant 365 jours. Ces plantes produisent le double des apports alimentaires normaux lors des récoltes. Elles ne peuvent tirer profit de croissance végétale qu''une fois par an.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7493, 2172, 53, 3),
  (7494, 2172, 55, 3),
  (7495, 2172, 60, 3);

-- [2173] Crosse des druides (niv 0, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2173, 'Crosse des druides', 0, 4, NULL, 1, 1, 1, 0, 0, 'du gui', 'personnelle', '', '', 'action Bonus', '1 minute', NULL, NULL, 0, 0, '<p>Le bois d''un gourdin ou d''un bâton de combat que vous tenez s''imprègne du pouvoir de la nature. Pour toute la durée, vous pouvez recourir à votre caractéristique d''incantation plutôt qu''à la Force pour les jets d''attaque et de dégâts de vos attaques de corps à corps effectuées avec cette arme. Le dé de dégâts de l''arme passe en outre à d8. Si l''attaque inflige des dégâts, il peut s''agir de dégâts de force ou des dégâts normaux de l''arme (à votre convenance).</p>
<p>Le sort prend fin prématurément si vous le relancez ou si vous lâchez l''arme.</p>
<p>Amélioration de sort mineur. Le dé de dégâts change lorsque vous atteignez les niveaux 5 (d10), 11 (d12) et 17 (2d6).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7496, 2173, 55, 0);

COMMIT;
-- Fin lot 3 — 50 sorts, prochains IDs : dd_sorts=2174, dd_sortclasse=7497
