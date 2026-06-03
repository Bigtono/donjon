-- =====================================================================
-- Import sorts SRD 5.2.1 (DD2024) — LOT 2 : lettre B (15 sorts)
-- Cible : dd_sorts (so_id 2109..2123) + dd_sortclasse (sc_id dès 7338)
-- res_id=93 (SRD) | ruleset_var_id=2 (DD2024) | camp_id NULL (compendium global)
-- Réexécution : DELETE FROM dd_sortclasse WHERE sc_so_id BETWEEN 2109 AND 2123;
--              DELETE FROM dd_sorts WHERE so_id BETWEEN 2109 AND 2123;
-- =====================================================================
SET NAMES utf8mb4;
START TRANSACTION;

-- [2109] Bagou (niv 8, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2109, 'Bagou', 8, 3, NULL, 1, 0, 0, 0, 0, NULL, 'personnelle', '', '', 'action', '1 heure', NULL, NULL, 0, 0, '<p>Jusqu''à la fin du sort, chaque fois que vous effectuez un test de Charisme, vous pouvez substituer 15 au nombre que vous obtenez sur le dé. De plus, quoi que vous disiez, toute magie censée vérifier que vous ne mentez pas identifie vos paroles comme sincères.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7338, 2109, 53, 8),
  (7339, 2109, 58, 8);

-- [2110] Baies nourricières (niv 1, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2110, 'Baies nourricières', 1, 6, NULL, 1, 1, 1, 0, 0, 'une branche de gui', 'personnelle', '', '', 'action', '24 heures', NULL, NULL, 0, 0, '<p>Dix baies se matérialisent dans votre main, gorgées de magie pour toute la durée. Une créature peut manger l''une de ces baies par une action Bonus. L''ingestion d''une baie fait récupérer 1 point de vie et fournit l''équivalent d''une journée de sustentation pour une créature.</p>
<p>Les baies non consommées disparaissent quand le sort prend fin.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7340, 2110, 55, 1),
  (7341, 2110, 60, 1);

-- [2111] Bannissement (niv 4, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2111, 'Bannissement', 4, 5, NULL, 1, 1, 1, 0, 0, 'un pentacle', '9 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Une créature que vous voyez à portée doit réussir un jet de sauvegarde de Charisme sous peine d''être transportée dans un demi-plan sans danger pour toute la durée. Tant qu''elle y reste, la cible subit l''état Neutralisé. Lorsque le sort prend fin, la cible réapparaît dans l''espace qu''elle avait quitté ou, si celui-ci n''est plus libre, dans l''espace inoccupé le plus proche.</p>
<p>Si la cible est de type Aberration, Céleste, Élémentaire, Fée ou Fiélon, elle ne revient pas si le sort persiste pendant 1 minute. Au lieu de cela, elle est transportée en un lieu aléatoire d''un plan (choisi par le MJ) associé à son type de créature.</p>
<p>Emplacement de niveau supérieur. Vous pouvez cibler une créature supplémentaire par niveau d''emplacement au-delà du 4e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7342, 2111, 54, 4),
  (7343, 2111, 56, 4),
  (7344, 2111, 52, 4),
  (7345, 2111, 58, 4),
  (7346, 2111, 59, 4);

-- [2112] Barrière de lames (niv 6, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2112, 'Barrière de lames', 6, 1, NULL, 1, 1, 0, 0, 0, NULL, '27 m', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Vous créez un mur de lames tourbillonnantes d''énergie magique. Le mur apparaît à portée et persiste pour toute la durée. Vous érigez ainsi un mur dont la hauteur n''excède pas 6 m et l''épaisseur 1,50 m ; pour le reste, vous avez le choix entre créer un mur droit long de 30 m au maximum ou un mur circulaire dont le diamètre ne dépasse pas 18 m. Le mur octroie un Abri supérieur et son espace constitue un Terrain difficile.</p>
<p>Toute créature prise dans l''espace du mur effectue un jet de sauvegarde de Dextérité, et subit 6d10 dégâts de force en cas d''échec, la moitié en cas de réussite. Une créature effectue aussi ce JS si elle pénètre dans l''espace du mur ou y termine son tour. Une même créature n''effectue en aucun cas ce JS plus d''une fois par tour.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7347, 2112, 54, 6);

-- [2113] Bénédiction (niv 1, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2113, 'Bénédiction', 1, 3, NULL, 1, 1, 1, 0, 0, 'un symbole sacré d''une valeur minimale de 5 po', '9 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous bénissez jusqu''à trois créatures à portée. Chaque fois qu''une de ces cibles effectue un jet d''attaque ou un jet de sauvegarde avant la fin du sort, elle ajoute 1d4 au résultat correspondant.</p>
<p>Emplacement de niveau supérieur. Vous pouvez cibler une créature supplémentaire par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7348, 2113, 54, 1),
  (7349, 2113, 59, 1);

-- [2114] Blessure (niv 1, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2114, 'Blessure', 1, 2, NULL, 1, 1, 0, 0, 0, NULL, 'contact', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>La créature que vous touchez physiquement effectue un jet de sauvegarde de Constitution et subit 2d10 dégâts nécrotiques en cas d''échec, la moitié en cas de réussite.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d10 par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7350, 2114, 54, 1);

-- [2115] Bouche magique (niv 2, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2115, 'Bouche magique', 2, 9, NULL, 1, 1, 1, 0, 0, 'poudre de jade d''une valeur minimale de 10 po, que le sort détruit', '9 m', '', '', '1 minute ou rituel', 'jusqu''à dissipation', NULL, NULL, 0, 1, '<p>Vous chargez un objet à portée d''un message qui sera prononcé lorsqu''une condition de déclenchement se présentera. Choisissez un objet que vous voyez et qui n''est pas porté par une autre créature. Prononcez alors un message d''un maximum de 25 mots (vous disposez toutefois de 10 minutes pour le peaufiner). Enfin, déterminez les circonstances qui déclencheront la transmission du message par le sort.</p>
<p>Quand cette condition se présente, une bouche magique apparaît sur l''objet et récite le message avec votre voix, au même volume que vous. Si l''objet choisi est lui-même doté d''une ouverture qui peut passer pour une bouche (comme sur une statue d''humanoïde), la bouche magique s''y manifeste et les mots semblent en émaner. À l''incantation du sort, vous pouvez décider que le sort prenne fin après avoir livré son message ou qu''il reste en place et répète son annonce chaque fois que le déclencheur se présente.</p>
<p>Les circonstances de déclenchement peuvent être générales ou détaillées, à votre convenance, mais doivent correspondre à des conditions visuelles ou auditives intervenant dans un rayon de 9 m de l''objet. Vous pourriez ainsi statuer que la bouche s''exprime quand une créature s''approche à 9 m ou moins de l''objet ou quand une cloche d''argent sonne dans ce même rayon.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7351, 2115, 53, 2),
  (7352, 2115, 52, 2);

-- [2116] Bouclier (niv 1, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2116, 'Bouclier', 1, 5, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'Réaction', '1 round', NULL, NULL, 0, 0, '<p>Réaction, que vous jouez lorsqu''un jet d''attaque vous touche ou que le sort projectile magique vous cible.</p>
<p>Une barrière imperceptible de force magique vous protège. Jusqu''au début de votre tour suivant, vous recevez un bonus de +5 à la CA, y compris contre l''attaque qui a déclenché le sort, et vous ne subissez aucun dégât de projectile magique.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7353, 2116, 56, 1),
  (7354, 2116, 52, 1);

-- [2117] Bouclier de feu (niv 4, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2117, 'Bouclier de feu', 4, 1, NULL, 1, 1, 1, 0, 0, 'un peu de phosphore ou une luciole', 'personnelle', '', '', 'action', '10 minutes', NULL, NULL, 0, 0, '<p>Des flammes ondoyantes vous enveloppent pour toute la durée en produisant une Lumière vive dans un rayon de 3 m et une Lumière faible sur 3 m de plus.</p>
<p>Les flammes vous procurent un écran chaud ou frais, à votre convenance. Un écran chaud vous octroie la Résistance aux dégâts de froid, un écran frais la Résistance aux dégâts de feu.</p>
<p>De plus, chaque fois qu''une créature située dans un rayon de 1,50 m de vous vous touche avec un jet d''attaque de corps à corps, les flammes s''attisent brusquement. L''assaillant subit 2d8 dégâts de feu si l''écran est chaud, 2d8 dégâts de froid s''il est frais.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7355, 2117, 55, 4),
  (7356, 2117, 56, 4),
  (7357, 2117, 52, 4);

-- [2118] Bouclier de la foi (niv 1, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2118, 'Bouclier de la foi', 1, 5, NULL, 1, 1, 1, 0, 0, 'un parchemin de prière', '18 m', '', '', 'action Bonus', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Un champ scintillant enveloppe une créature de votre choix à portée et lui octroie un bonus de +2 à la CA pour toute la durée.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7358, 2118, 54, 1),
  (7359, 2118, 59, 1);

-- [2119] Bouffée de poison (niv 0, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2119, 'Bouffée de poison', 0, 2, NULL, 1, 1, 0, 0, 0, NULL, '9 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous projetez une brume toxique vers une créature à portée. Effectuez une attaque de sort à distance contre la cible. Si l''attaque touche, la cible subit 1d12 dégâts de poison.</p>
<p>Amélioration de sort mineur. Les dégâts augmentent de 1d12 lorsque vous atteignez les niveaux 5 (2d12), 11 (3d12) et 17 (4d12).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7360, 2119, 55, 0),
  (7361, 2119, 56, 0),
  (7362, 2119, 52, 0),
  (7363, 2119, 58, 0);

-- [2120] Boule de feu (niv 3, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2120, 'Boule de feu', 3, 1, NULL, 1, 1, 1, 0, 0, 'une boulette de guano de chauve-souris et de soufre', '45 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Une zébrure éblouissante jaillit de vous jusqu''au point que vous choisissez à portée, produisant une déflagration au grondement sourd. Chaque créature prise dans la Sphère de 6 m de rayon centrée sur ce point d''origine effectue un jet de sauvegarde de Dextérité et subit 8d6 dégâts de feu en cas d''échec, la moitié en cas de réussite.</p>
<p>L''explosion embrase les objets inflammables de la zone qui ne sont portés par personne.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d6 par niveau d''emplacement au-delà du 3e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7364, 2120, 56, 3),
  (7365, 2120, 52, 3);

-- [2121] Boule de feu à retardement (niv 7, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2121, 'Boule de feu à retardement', 7, 1, NULL, 1, 1, 1, 0, 0, 'une boulette de guano de chauve-souris et de soufre', '45 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Un rayon de lumière jaune jaillit de vous pour se condenser en un point que vous choisissez à portée, sous forme d''une bille luisante pour toute la durée. Lorsque le sort prend fin, la bille explose et toute créature prise dans une Sphère de 6 m de rayon centrée sur ce point effectue un jet de sauvegarde de Dextérité. Elle subit des dégâts de feu égaux aux dégâts accumulés en cas d''échec, la moitié en cas de réussite.</p>
<p>Les dégâts de base du sort sont de 12d6 et les dégâts augmentent de 1d6 chaque fois que votre tour prend fin tandis que le sort persiste.</p>
<p>Si une créature touche physiquement la bille avant la fin de l''intervalle, elle effectue un jet de sauvegarde de Dextérité. En cas d''échec, le sort prend fin et la bille explose. En cas de réussite, la créature peut projeter la bille d''un maximum de 12 m. Si la bille pénètre dans l''espace d''une créature ou heurte un objet solide, le sort prend fin et la bille explose.</p>
<p>Quand la bille explose, les objets inflammables pris dans la déflagration s''embrasent s''ils ne sont portés par personne.</p>
<p>Emplacement de niveau supérieur. Les dégâts de base augmentent de 1d6 par niveau d''emplacement au-delà du 7e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7366, 2121, 56, 7),
  (7367, 2121, 52, 7);

-- [2122] Bourrasque (niv 2, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2122, 'Bourrasque', 2, 1, NULL, 1, 1, 1, 0, 0, 'une graine de légumineuse', 'personnelle', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Une Ligne de vent fort longue de 18 m et large de 3 m souffle depuis vous dans la direction de votre choix pour toute la durée. Toute créature prise dans la Ligne doit réussir un jet de sauvegarde de Force sous peine d''être repoussée de 4,50 m de vous selon la direction de la Ligne. Une créature qui termine son tour dans la Ligne est soumise au même JS.</p>
<p>Toute créature prise dans la Ligne qui se déplace vers vous doit consacrer le double du déplacement normal pour toute distance parcourue.</p>
<p>La bourrasque disperse les gaz et vapeurs, éteint les bougies et autres flammes exposées de la zone. Les flammes protégées, comme celles des lanternes, vacillent vigoureusement avec un risque de 50 % de s''éteindre.</p>
<p>Par une action Bonus à vos tours suivants, vous pouvez changer la direction dans laquelle la Ligne jaillit de vous.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7368, 2122, 55, 2),
  (7369, 2122, 56, 2),
  (7370, 2122, 52, 2),
  (7371, 2122, 60, 2);

-- [2123] Brume mortelle (niv 5, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2123, 'Brume mortelle', 5, 6, NULL, 1, 1, 0, 0, 0, NULL, '36 m', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Vous créez une Sphère de 6 m de rayon constituée de brouillard d''un jaune verdâtre, centrée sur un point à portée. La brume persiste pour toute la durée, à moins qu''un vent fort (comme celui engendré par bourrasque) la disperse et mette fin au sort. Sa zone présente une Visibilité nulle.</p>
<p>Chaque créature prise dans la Sphère effectue un jet de sauvegarde de Constitution et subit 5d8 dégâts de poison en cas d''échec, la moitié en cas de réussite. Toute créature qui voit la Sphère se déplacer dans son espace, ou qui pénètre dans la Sphère ou y termine son tour est également soumise à ce JS. Une même créature n''effectue en aucun cas ce JS plus d''une fois par tour.</p>
<p>La Sphère s''éloigne de vous de 3 m au début de chacun de vos tours.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d8 par niveau d''emplacement au-delà du 5e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7372, 2123, 56, 5),
  (7373, 2123, 52, 5);

COMMIT;
-- Fin lot 2 — 15 sorts, prochains IDs : dd_sorts=2124, dd_sortclasse=7374
