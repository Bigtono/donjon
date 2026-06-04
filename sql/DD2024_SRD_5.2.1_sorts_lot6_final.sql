-- =====================================================================
-- Import sorts SRD 5.2.1 (DD2024) — LOT 6 FINAL : P/Q/R/S/T/V/Z (94 sorts)
-- dd_sorts so_id 2327..2420 | dd_sortclasse sc_id dès 7901
-- res_id=93 | ruleset_var_id=2 | camp_id NULL
-- Réexécution : DELETE FROM dd_sortclasse WHERE sc_so_id BETWEEN 2327 AND 2420;
--              DELETE FROM dd_sorts WHERE so_id BETWEEN 2327 AND 2420;
-- =====================================================================
SET NAMES utf8mb4;
START TRANSACTION;

-- [2327] Parole divine (niv 7, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2327, 'Parole divine', 7, 1, NULL, 1, 0, 0, 0, 0, NULL, '9 m', '', '', 'action Bonus', 'instantanée', NULL, NULL, 0, 0, '<p>Vous prononcez une parole porteuse de la puissance des Plans Supérieurs. Chaque créature que vous choisissez à portée effectue un jet de sauvegarde de Charisme. En cas d''échec, une cible dotée de 50 points de vie ou moins subit un effet qui dépend de ses points de vie actuels :</p>
<p>0–20 pv — La cible meurt.<br>
21–30 pv — La cible subit les états Assourdi, Aveuglé et Étourdi pendant 1 heure.<br>
31–40 pv — La cible subit les états Assourdi et Aveuglé pendant 10 minutes.<br>
41–50 pv — La cible subit l''état Assourdi pendant 1 minute.</p>
<p>Quels que soient ses points de vie actuels, une cible Céleste, Élémentaire, Fée ou Fiélon qui rate son JS est renvoyée d''office dans son plan d''origine (s''il ne s''y trouve pas déjà) et ne peut revenir sur votre plan actuel pendant 24 heures, sauf par le biais du sort souhait.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7901, 2327, 54, 7);

-- [2328] Passage par les arbres (niv 5, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2328, 'Passage par les arbres', 5, 6, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous recevez la faculté d''entrer dans un arbre et de vous y déplacer pour atteindre un autre arbre du même type distant d''un maximum de 150 m. Les deux arbres doivent être vivants et d''une catégorie de taille supérieure ou égale à la vôtre.</p>
<p>Entrer dans un arbre nécessite d''y consacrer 1,50 m de déplacement. Vous prenez aussitôt conscience de la position de tous les autres arbres de la même essence dans un rayon de 150 m et, lors du déplacement qui vous permet de pénétrer dans l''arbre, vous avez alors le choix entre passer dans l''un de ces arbres ou ressortir par celui dans lequel vous venez d''entrer.</p>
<p>Si vous consacrez 1,50 m de déplacement supplémentaire, vous apparaissez à l''endroit de votre choix dans un rayon de 1,50 m de l''arbre de destination. S''il ne vous reste aucun déplacement, vous réapparaissez dans un rayon de 1,50 m de l''arbre de départ.</p>
<p>Vous ne pouvez utiliser cette faculté de transport qu''une seule fois à chacun de vos tours. Vous devez terminer chaque tour à l''extérieur d''un arbre.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7902, 2328, 55, 5),
  (7903, 2328, 60, 5);

-- [2329] Passage sans trace (niv 2, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2329, 'Passage sans trace', 2, 5, NULL, 1, 1, 1, 0, 0, 'les cendres d''une feuille de gui calcinée', 'personnelle', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Vous projetez pour toute la durée une aura de camouflage sous forme d''une Émanation de 9 m. Pour toute la durée, chaque créature que vous désignez dans un rayon de 9 m (y compris vous) bénéficie d''un bonus de +10 aux tests de Dextérité (Discrétion) et ne laisse pas de traces.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7904, 2329, 55, 2),
  (7905, 2329, 60, 2);

-- [2330] Passe-muraille (niv 5, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2330, 'Passe-muraille', 5, 4, NULL, 1, 1, 1, 0, 0, 'une pincée de graines de sésame', '9 m', '', '', 'action', '1 heure', NULL, NULL, 0, 0, '<p>Un passage se forme en un point que vous voyez sur une surface de bois, de plâtre ou de pierre à portée, et persiste pour toute la durée. Vous choisissez les dimensions de l''ouverture : jusqu''à 1,50 m de large, 2,40 m de haut et 6 m de profondeur. Le passage n''engendre aucune instabilité dans la structure qui l''entoure.</p>
<p>Lorsque le passage disparaît, tous les objets et créatures qui s''y trouvent encore sont éjectés sans heurt dans les espaces inoccupés les plus proches de la surface affectée.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7906, 2330, 52, 5);

-- [2331] Pattes d'araignée (niv 2, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2331, 'Pattes d''araignée', 2, 4, NULL, 1, 1, 1, 0, 0, 'une goutte de bitume et une araignée', 'contact', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Jusqu''à la fin du sort, une créature consentante que vous touchez reçoit la capacité de se déplacer dans toutes les directions le long des surfaces verticales, ainsi que sur les plafonds, tout en gardant les mains libres. La cible acquiert en outre une Vitesse d''escalade égale à sa Vitesse.</p>
<p>Emplacement de niveau supérieur. Vous pouvez cibler une créature supplémentaire par niveau d''emplacement au-delà du 2e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7907, 2331, 56, 2),
  (7908, 2331, 52, 2),
  (7909, 2331, 58, 2);

-- [2332] Peau d'écorce (niv 2, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2332, 'Peau d''écorce', 2, 4, NULL, 1, 1, 1, 0, 0, 'une poignée d''écorce', 'contact', '', '', 'action Bonus', '1 heure', NULL, NULL, 0, 0, '<p>Vous touchez une créature consentante. Jusqu''à la fin du sort, la peau de la cible adopte un aspect d''écorce et sa classe d''armure passe à 17 si elle est inférieure à cette valeur.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7910, 2332, 55, 2),
  (7911, 2332, 60, 2);

-- [2333] Peau de pierre (niv 4, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2333, 'Peau de pierre', 4, 4, NULL, 1, 1, 1, 0, 0, 'poudre de diamant d''une valeur minimale de 100 po, que le sort détruit', 'contact', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Jusqu''à la fin du sort, une créature consentante que vous touchez physiquement a la Résistance aux dégâts contondants, perforants et tranchants.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7912, 2333, 55, 4),
  (7913, 2333, 56, 4),
  (7914, 2333, 52, 4),
  (7915, 2333, 60, 4);

-- [2334] Petite hutte (niv 3, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2334, 'Petite hutte', 3, 1, NULL, 1, 1, 1, 0, 0, 'une bille de cristal', 'personnelle', '', '', '1 minute ou rituel', '8 heures', NULL, NULL, 0, 1, '<p>Une Émanation de 3 m se manifeste autour de vous, mais reste sur place pour toute la durée. Le sort échoue à l''incantation si l''Émanation ne suffit pas à englober toutes les créatures de sa zone.</p>
<p>Les créatures et objets situés dans l''Émanation à l''incantation peuvent s''y déplacer librement, y entrer et en sortir. Tous les autres objets et créatures ne peuvent le traverser. Les sorts du 3e niveau et inférieur ne peuvent franchir l''Émanation et leurs effets ne peuvent la chevaucher.</p>
<p>L''atmosphère à l''intérieur de l''Émanation est sèche et agréable, quel que soit le temps à l''extérieur. Jusqu''à la fin du sort, vous pouvez rendre l''intérieur faiblement éclairé ou enténébré, sur commande (pas d''action requise). L''Émanation est opaque depuis l''extérieur, de la couleur de votre choix, mais elle est transparente depuis l''intérieur.</p>
<p>Le sort prend fin prématurément si vous quittez l''Émanation ou si vous le lancez à nouveau.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7916, 2334, 53, 3),
  (7917, 2334, 52, 3);

-- [2335] Pétrification (niv 6, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2335, 'Pétrification', 6, 4, NULL, 1, 1, 1, 0, 0, 'une plume de cockatrice', '18 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous tentez de transformer en pierre une créature que vous voyez à portée. La cible effectue un jet de sauvegarde de Constitution. En cas d''échec, elle subit l''état Entravé pour toute la durée. En cas de réussite, sa vitesse tombe à 0 jusqu''au début de votre tour suivant. Les Artificiels réussissent automatiquement ce JS.</p>
<p>Une créature ainsi Entravée réitère le jet de sauvegarde de Constitution à la fin de chacun de ses tours. Si elle se sauvegarde trois fois contre le sort, celui-ci prend fin. Si elle rate son JS trois fois, elle se transforme en pierre et reste soumise à l''état Pétrifié pour toute la durée. Ces réussites et échecs n''ont pas besoin d''être consécutifs.</p>
<p>Si vous maintenez votre Concentration sur ce sort pendant toute la durée possible, la cible est Pétrifiée jusqu''à ce que l''état soit éliminé par restauration suprême ou une magie équivalente.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7918, 2335, 55, 6),
  (7919, 2335, 56, 6),
  (7920, 2335, 52, 6);

-- [2336] Poigne électrique (niv 0, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2336, 'Poigne électrique', 0, 1, NULL, 1, 1, 0, 0, 0, NULL, 'contact', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>La foudre jaillit de vous vers une créature que vous tentez de toucher. Effectuez une attaque de sort au corps à corps contre la cible. Si l''attaque touche, la cible subit 1d8 dégâts de foudre et ne peut pas effectuer d''attaque d''Opportunité jusqu''au début de son tour suivant.</p>
<p>Amélioration de sort mineur. Les dégâts augmentent de 1d8 lorsque vous atteignez les niveaux 5 (2d8), 11 (3d8) et 17 (4d8).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7921, 2336, 56, 0),
  (7922, 2336, 52, 0);

-- [2337] Portail (niv 9, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2337, 'Portail', 9, 6, NULL, 1, 1, 1, 0, 0, 'un diamant d''une valeur minimale de 5 000 po', '18 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous invoquez un portail reliant un espace inoccupé que vous voyez à portée à un lieu précis sur un autre plan d''existence. Le portail se présente comme une ouverture circulaire dont le diamètre peut aller de 1,50 m à 6 m. Le portail persiste pour toute la durée, sa destination étant visible par l''ouverture.</p>
<p>Le portail est doté d''une face avant et d''une face arrière. Emprunter le portail n''est possible que si on le franchit par sa face avant. Tout ce qui le franchit ainsi est aussitôt transporté sur l''autre plan.</p>
<p>Les divinités et autres souverains planaires peuvent empêcher les portails engendrés par ce sort de s''ouvrir en leur présence ou dans leur domaine.</p>
<p>À l''incantation du sort, vous pouvez prononcer le nom d''une créature donnée. Si cette créature se trouve sur un plan autre que celui que vous occupez, le portail s''ouvre à proximité de la créature nommée et la transporte jusqu''à l''espace inoccupé le plus proche du portail, sur votre plan. Vous n''avez nulle emprise particulière sur la créature.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7923, 2337, 54, 9),
  (7924, 2337, 56, 9),
  (7925, 2337, 52, 9),
  (7926, 2337, 58, 9);

-- [2338] Porte dimensionnelle (niv 4, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2338, 'Porte dimensionnelle', 4, 6, NULL, 1, 0, 0, 0, 0, NULL, '150 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous vous téléportez en un lieu à portée. Vous arrivez précisément à l''endroit désiré. Il peut s''agir d''un lieu que vous voyez, que vous visualisez ou dont vous pouvez spécifier la distance et la direction, comme « 60 m directement en contrebas » ou « en montant vers le nord-ouest à 45 degrés sur 90 m ».</p>
<p>Vous pouvez aussi téléporter une créature consentante. Celle-ci doit se trouver dans un rayon de 1,50 m de vous quand vous vous téléportez, et réapparaît dans un rayon de 1,50 m de votre espace de destination.</p>
<p>Si le sort est censé vous transporter en un lieu déjà occupé par une créature ou complètement obstrué par des objets, vous et toute créature qui vous accompagne subissez chacun 4d6 dégâts de force et le sort ne vous téléporte pas.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7927, 2338, 53, 4),
  (7928, 2338, 56, 4),
  (7929, 2338, 52, 4),
  (7930, 2338, 58, 4);

-- [2339] Possession (niv 6, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2339, 'Possession', 6, 2, NULL, 1, 1, 1, 0, 0, 'une gemme, un cristal ou un reliquaire d''une valeur minimale de 500 po', 'personnelle', '', '', '1 minute', 'jusqu''à dissipation', NULL, NULL, 0, 0, '<p>Votre corps sombre en catatonie tandis que votre âme le quitte pour pénétrer dans le récipient ayant servi de composante matérielle au sort. Tant que votre âme occupe ce contenant, vous restez conscient de l''environnement comme si vous occupiez l''espace du récipient. Vous ne pouvez pas vous déplacer ni jouer de Réactions. La seule action que vous puissiez entreprendre consiste à projeter votre âme à une distance maximale de 30 m du récipient : soit en reprenant possession de votre corps (ce qui met fin au sort), soit en tentant de posséder un autre corps Humanoïde.</p>
<p>Vous pouvez tenter de posséder tout Humanoïde dans un rayon de 30 m de vous, à condition de le voir. La cible effectue un jet de sauvegarde de Charisme. En cas d''échec, votre âme se transporte dans le corps de la cible et l''âme de celle-ci se retrouve séquestrée dans le récipient. En cas de réussite, la cible résiste et vous devez attendre 24 heures pour essayer à nouveau.</p>
<p>Une fois que vous possédez le corps d''une créature, vous la contrôlez. Vos PV, valeurs de For/Dex/Con, Vitesse et sens sont remplacés par ceux de la créature. Vous conservez pour le reste votre profil.</p>
<p>Si le corps hôte meurt alors que vous le possédez, la créature meurt et vous effectuez un JS de Charisme contre votre propre DD. En cas de réussite, vous retournez dans le récipient s''il se trouve dans un rayon de 30 m. Dans le cas contraire, vous mourez.</p>
<p>Si le contenant est détruit ou si le sort prend fin, votre âme retrouve votre corps. Si votre corps est distant de plus de 30 m ou s''il est mort, vous mourez.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7931, 2339, 52, 6);

-- [2340] Poussière d'étoile (niv 0, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2340, 'Poussière d''étoile', 0, 1, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous projetez une particule de lumière vers une créature ou un objet à portée. Effectuez une attaque de sort à distance contre la cible. Si l''attaque touche, la cible subit 1d8 dégâts radiants et, jusqu''à la fin de votre tour suivant, elle émet une Lumière faible dans un rayon de 3 m et ne peut bénéficier de l''état Invisible.</p>
<p>Amélioration de sort mineur. Les dégâts augmentent de 1d8 lorsque vous atteignez les niveaux 5 (2d8), 11 (3d8) et 17 (4d8).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7932, 2340, 53, 0),
  (7933, 2340, 55, 0);

-- [2341] Préméditation (niv 6, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2341, 'Préméditation', 6, 5, NULL, 1, 1, 1, 0, 0, 'une statuette en ivoire incrustée de gemmes, à votre image, d''une valeur minimale de 1 500 po', 'personnelle', '', '', '10 minutes', '10 jours', NULL, NULL, 0, 0, '<p>Choisissez un sort du 5e niveau ou inférieur que vous pouvez lancer, dont le temps d''incantation est d''une action et qui peut vous cibler. Vous lancez ce sort prémédité dans le cadre de l''incantation de préméditation, et acquittez les emplacements des deux sorts. Le sort prémédité n''agit pas aussitôt : il ne prendra effet que lorsqu''un déclencheur précis que vous décrivez se présentera.</p>
<p>Le sort prémédité prend effet aussitôt après que les conditions sont réunies pour la première fois, que vous le vouliez ou non, puis la préméditation prend fin.</p>
<p>Le sort prémédité ne prend effet que sur vous, même s''il est susceptible d''avoir d''autres cibles en temps normal. Vous ne pouvez recourir qu''à un sort de préméditation à la fois. Si vous relancez ce sort, la préméditation qui vous affectait déjà prend fin. La préméditation prend également fin si sa composante matérielle n''est plus sur vous.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7934, 2341, 52, 6);

-- [2342] Prémonition (niv 9, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2342, 'Prémonition', 9, 7, NULL, 1, 1, 1, 0, 0, 'une plume de colibri', 'contact', '', '', '1 minute', '8 heures', NULL, NULL, 0, 0, '<p>Vous touchez physiquement une créature consentante pour lui octroyer la faculté d''entrevoir l''avenir immédiat. Pour toute la durée, la cible a l''Avantage aux Tests d20 et les autres créatures subissent le Désavantage aux jets d''attaque contre elle. Le sort prend fin prématurément si vous le relancez.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7935, 2342, 53, 9),
  (7936, 2342, 55, 9),
  (7937, 2342, 52, 9),
  (7938, 2342, 58, 9);

-- [2343] Prestidigitation (niv 0, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2343, 'Prestidigitation', 0, 4, NULL, 1, 1, 0, 0, 0, NULL, '3 m', '', '', 'action', 'jusqu''à 1 heure', NULL, NULL, 0, 0, '<p>Vous produisez un effet magique à portée. Choisissez l''effet parmi les options ci-après. Si vous lancez ce sort plusieurs fois, vous pouvez faire coexister jusqu''à trois de ces effets non instantanés.</p>
<p>Effet sensoriel. Vous produisez un effet sensoriel instantané et inoffensif, comme une pluie d''étincelles, une petite rafale de vent, quelques notes de musique ou une odeur étrange.</p>
<p>Jeu avec le feu. Vous allumez ou éteignez une bougie, une torche ou un petit feu de camp, en un instant.</p>
<p>Nettoyage ou maculage. Vous nettoyez ou souillez en un instant un objet dont le volume ne dépasse pas 30 litres.</p>
<p>Sensation mineure. Vous refroidissez, réchauffez ou parfumez de la matière inerte pendant 1 heure (volume max. 30 litres).</p>
<p>Marque magique. Vous faites apparaître pendant 1 heure, sur un objet ou une surface, une couleur, une petite marque ou un symbole.</p>
<p>Création mineure. Vous créez une babiole non magique ou une image illusoire qui tient dans votre main. Elle persiste jusqu''à la fin de votre tour suivant. Elle ne peut pas infliger de dégâts et n''a aucune valeur monétaire.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7939, 2343, 53, 0),
  (7940, 2343, 56, 0),
  (7941, 2343, 52, 0),
  (7942, 2343, 58, 0);

-- [2344] Prière de guérison (niv 2, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2344, 'Prière de guérison', 2, 5, NULL, 1, 0, 0, 0, 0, NULL, '9 m', '', '', '10 minutes', 'instantanée', NULL, NULL, 0, 0, '<p>Un maximum de cinq créatures que vous choisissez parmi celles qui restent à portée pendant toute l''incantation reçoivent les bénéfices d''un Repos court et récupèrent chacune 2d8 points de vie. Une créature qui profite de ce sort doit terminer un Repos long pour pouvoir en profiter à nouveau.</p>
<p>Emplacement de niveau supérieur. Les soins augmentent de 1d8 par niveau d''emplacement au-delà du 2e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7943, 2344, 54, 2),
  (7944, 2344, 59, 2);

-- [2345] Projectile magique (niv 1, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2345, 'Projectile magique', 1, 1, NULL, 1, 1, 0, 0, 0, NULL, '36 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous créez trois traits de force magique et scintillante. Chaque projectile heurte une créature de votre choix parmi celles que vous voyez à portée. Un projectile inflige 1d4 + 1 dégâts de force à sa cible. Les traits frappent tous simultanément, sachant que vous pouvez viser une seule créature ou plusieurs.</p>
<p>Emplacement de niveau supérieur. Le sort produit un trait supplémentaire par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7945, 2345, 56, 1),
  (7946, 2345, 52, 1);

-- [2346] Projection astrale (niv 9, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2346, 'Projection astrale', 9, 2, NULL, 1, 1, 1, 0, 0, 'pour chaque cible affectée, une hyacinthe d''une valeur minimale de 1 000 po et un lingot d''argent ouvragé d''une valeur minimale de 100 po, composantes que le sort détruit', '3 m', '', '', '1 heure', 'jusqu''à dissipation', NULL, NULL, 0, 0, '<p>Vous et un maximum de huit créatures consentantes à portée projetez vos corps astraux dans le Plan Astral. Le corps abandonné par chaque cible reçoit l''état Inconscient, en animation suspendue.</p>
<p>Le corps astral d''une cible ressemble en tout point à sa forme mortelle et reprend son profil de jeu. Il est doté d''une cordelette d''argent partant d''entre les omoplates. Si la cordelette est sectionnée, le corps de la cible et la forme astrale meurent aussitôt.</p>
<p>La forme astrale d''une cible peut voyager dans le Plan Astral. Dès qu''une forme astrale quitte ce plan, la cible reprend possession de son corps sur le nouveau plan.</p>
<p>Tous les dégâts et effets qui s''appliquent à une forme astrale ne concernent aucunement le corps physique, et réciproquement. Si le corps d''origine ou la forme astrale tombe à 0 point de vie, le sort prend fin pour cette cible. Le sort prend fin pour toutes les cibles si vous consacrez l''action Magie à le révoquer.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7947, 2346, 54, 9),
  (7948, 2346, 52, 9),
  (7949, 2346, 58, 9);

-- [2347] Protection contre l'énergie (niv 3, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2347, 'Protection contre l''énergie', 3, 5, NULL, 1, 1, 0, 0, 0, NULL, 'contact', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Pour toute la durée, la créature consentante que vous touchez bénéficie de la Résistance à un type de dégâts de votre choix entre : acide, feu, foudre, froid et tonnerre.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7950, 2347, 54, 3),
  (7951, 2347, 55, 3),
  (7952, 2347, 56, 3),
  (7953, 2347, 52, 3),
  (7954, 2347, 60, 3);

-- [2348] Protection contre la mort (niv 4, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2348, 'Protection contre la mort', 4, 5, NULL, 1, 1, 0, 0, 0, NULL, 'contact', '', '', 'action', '8 heures', NULL, NULL, 0, 0, '<p>Vous touchez une créature pour la préserver de la mort. La première fois que la cible est censée tomber à 0 point de vie avant la fin du sort, elle se retrouve en fait à 1 point de vie, puis le sort prend fin.</p>
<p>Si ce sort est toujours actif alors que la cible est soumise à un effet censé la tuer sur le coup sans lui infliger de dégâts, cet effet est annulé en ce qui la concerne, et le sort prend fin.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7955, 2348, 54, 4),
  (7956, 2348, 59, 4);

-- [2349] Protection contre le mal et le bien (niv 1, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2349, 'Protection contre le mal et le bien', 1, 5, NULL, 1, 1, 1, 0, 0, 'une flasque d''eau bénite d''une valeur minimale de 25 po, que le sort détruit', 'contact', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Jusqu''à la fin du sort, une créature consentante que vous touchez physiquement est protégée contre les créatures des types suivants : Aberrations, Célestes, Élémentaires, Fées, Fiélons et Morts-vivants. Les créatures concernées ont le Désavantage aux jets d''attaque contre la cible. Elles ne peuvent pas posséder la cible, ni lui infliger les états Charmé et Effrayé. Si la cible est déjà Charmée, Effrayée ou possédée par une telle créature, elle a l''Avantage aux nouveaux jets de sauvegarde contre l''effet correspondant.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7957, 2349, 54, 1),
  (7958, 2349, 55, 1),
  (7959, 2349, 52, 1),
  (7960, 2349, 58, 1),
  (7961, 2349, 59, 1);

-- [2350] Protection contre le poison (niv 2, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2350, 'Protection contre le poison', 2, 5, NULL, 1, 1, 0, 0, 0, NULL, 'contact', '', '', 'action', '1 heure', NULL, NULL, 0, 0, '<p>Vous touchez physiquement une créature pour mettre fin sur elle à l''état Empoisonné. Pour toute la durée, la cible a l''Avantage aux jets de sauvegarde pour éviter l''état Empoisonné ou y mettre fin, et bénéficie de la Résistance aux dégâts de poison.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7962, 2350, 54, 2),
  (7963, 2350, 55, 2),
  (7964, 2350, 59, 2),
  (7965, 2350, 60, 2);

-- [2351] Protections et sceaux (niv 6, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2351, 'Protections et sceaux', 6, 5, NULL, 1, 1, 1, 0, 0, 'un sceptre en argent d''une valeur minimale de 10 po', 'contact', '', '', '1 heure', '24 heures', NULL, NULL, 0, 0, '<p>Vous créez une barrière qui protège un espace au sol d''une surface maximale de 225 m², haute de 6 m. La zone peut se présenter comme un carré de 15 m de côté ou une configuration équivalente de carrés contigus de 1,50 m ou 3 m de côté.</p>
<p>À l''incantation du sort, vous pouvez spécifier quels individus ne seront pas affectés, ou définir un mot de passe immunisant l''individu qui le prononce dans un rayon de 1,50 m de la zone.</p>
<p>Le sort crée les effets ci-après au sein de la zone protégée. Chacun peut être dissipé individuellement. Si tous les quatre sont dissipés, protections et sceaux prend fin.</p>
<p>Couloirs. La brume envahit les couloirs (Visibilité nulle). À chaque intersection, toute créature autre que vous a 50 % de chances de croire avoir pris une direction différente.</p>
<p>Escaliers. Tous les escaliers de la zone sont envahis de filandres (équivalent de toile d''araignée), qui se reconstituent en 10 minutes si détruits.</p>
<p>Portes. Toutes les portes de la zone sont magiquement verrouillées (verrou magique). Un maximum de dix portes peuvent être masquées en pans de mur.</p>
<p>Autres effets. L''un des effets suivants s''applique à la zone : lumières dansantes dans quatre couloirs, bouche magique en deux endroits, nuage nauséabond en deux endroits (se reconstitue en 10 minutes), bourrasque dans un couloir, ou suggestion dans un carré de 1,50 m.</p>
<p>Lancer quotidiennement ce sort sur la même zone pendant 365 jours le fait persister jusqu''à dissipation complète.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7966, 2351, 53, 6),
  (7967, 2351, 52, 6);

-- [2352] Purification de la nourriture et de l'eau (niv 1, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2352, 'Purification de la nourriture et de l''eau', 1, 4, NULL, 1, 1, 0, 0, 0, NULL, '3 m', '', '', 'action ou rituel', 'instantanée', NULL, NULL, 0, 1, '<p>Vous purgez de tout poison et pourriture les aliments et boissons non magiques dans une Sphère de 1,50 m de rayon centrée sur un point à portée.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7968, 2352, 54, 1),
  (7969, 2352, 55, 1),
  (7970, 2352, 59, 1);

-- [2353] Quête (niv 5, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2353, 'Quête', 5, 3, NULL, 1, 0, 0, 0, 0, NULL, '18 m', '', '', '1 minute', '30 jours', NULL, NULL, 0, 0, '<p>Vous intimez un ordre verbal à une créature que vous voyez à portée, pour la contraindre à accomplir une tâche ou l''empêcher d''exécuter certains actes que vous définissez. La cible doit réussir un jet de sauvegarde de Sagesse sous peine de subir l''état Charmé pour toute la durée. Elle réussit automatiquement ce JS si elle n''est pas en mesure de comprendre votre ordre.</p>
<p>Tant que la créature est ainsi Charmée, elle subit 5d10 dégâts psychiques quand elle se conduit directement à l''encontre de vos instructions. Elle ne peut pas subir ces dégâts plus d''une fois par jour.</p>
<p>Vous pouvez donner n''importe quel ordre, en dehors d''une tâche dont l''issue serait forcément fatale à la cible. Si l''instruction intimée est suicidaire, le sort prend fin.</p>
<p>Les sorts délivrance des malédictions, restauration suprême et souhait mettent chacun fin à ce sort.</p>
<p>Emplacement de niveau supérieur. Avec un emplacement du 7e ou 8e niveau, la durée est de 365 jours. Avec un emplacement du 9e niveau, le sort persiste jusqu''à ce qu''un des sorts cités plus haut y mette fin.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7971, 2353, 53, 5),
  (7972, 2353, 54, 5),
  (7973, 2353, 55, 5),
  (7974, 2353, 52, 5),
  (7975, 2353, 59, 5);

-- [2354] Rappel à la vie (niv 5, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2354, 'Rappel à la vie', 5, 2, NULL, 1, 1, 1, 0, 0, 'un diamant d''une valeur minimale de 500 po, que le sort détruit', 'contact', '', '', '1 heure', 'instantanée', NULL, NULL, 0, 0, '<p>D''un contact, vous ramenez à la vie une créature qui n''était pas un Mort-vivant quand elle est morte et dont la mort remonte à un maximum de 10 jours.</p>
<p>La créature est ramenée à la vie avec 1 point de vie. Ce sort neutralise également tous les poisons qui affectaient la créature au moment de mourir. Ce sort referme toutes les blessures mortelles, mais ne fait pas repousser l''anatomie manquante. Si la créature a perdu des organes essentiels à sa survie, le sort échoue automatiquement.</p>
<p>Revenir d''entre les morts demeure une épreuve. La cible subit un malus de –4 aux Tests d20. Chaque fois qu''elle termine un Repos long, ce malus diminue de 1, jusqu''à ce qu''il tombe à 0.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7976, 2354, 53, 5),
  (7977, 2354, 54, 5),
  (7978, 2354, 59, 5);

-- [2355] Rayon affaiblissant (niv 2, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2355, 'Rayon affaiblissant', 2, 2, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Un rayon débilitant jaillit de vous vers une créature à portée. La cible effectue un jet de sauvegarde de Constitution. En cas de réussite, la cible a le Désavantage à son prochain jet d''attaque intervenant avant le début de votre tour suivant.</p>
<p>En cas d''échec, elle a le Désavantage à tous ses Tests d20 basés sur la Force, pour toute la durée. Tout du long, elle soustrait aussi 1d8 à tous ses jets de dégâts. La cible réitère le JS à la fin de chacun de ses tours et met un terme au sort en cas de réussite.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7979, 2355, 52, 2),
  (7980, 2355, 58, 2);

-- [2356] Rayon ardent (niv 2, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2356, 'Rayon ardent', 2, 1, NULL, 1, 1, 0, 0, 0, NULL, '36 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous projetez trois rayons de flammes. Vous pouvez cibler une seule cible à portée ou bien plusieurs. Effectuez une attaque de sort à distance pour chaque rayon. Une attaque qui touche sa cible lui inflige 2d6 dégâts de feu.</p>
<p>Emplacement de niveau supérieur. Vous produisez un rayon supplémentaire par niveau d''emplacement au-delà du 2e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7981, 2356, 56, 2),
  (7982, 2356, 52, 2);

-- [2357] Rayon de givre (niv 0, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2357, 'Rayon de givre', 0, 1, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Un rayon de lueur zébrée bleuâtre et glaciale file vers une créature à portée. Effectuez une attaque de sort à distance contre la cible. Si l''attaque touche, la cible subit 1d8 dégâts de froid et sa Vitesse est réduite de 3 m jusqu''au début de votre tour suivant.</p>
<p>Amélioration de sort mineur. Les dégâts augmentent de 1d8 lorsque vous atteignez les niveaux 5 (2d8), 11 (3d8) et 17 (4d8).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7983, 2357, 56, 0),
  (7984, 2357, 52, 0);

-- [2358] Rayon de lune (niv 2, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2358, 'Rayon de lune', 2, 1, NULL, 1, 1, 1, 0, 0, 'une feuille de cocculus', '36 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Un large rayon de lueur argentée ténue plonge sous forme d''un Cylindre de 1,50 m de rayon et 12 m de haut, centré sur un point à portée. Jusqu''à la fin du sort, le Cylindre est empli de Lumière faible et vous pouvez entreprendre l''action Magie à vos tours suivants pour déplacer le Cylindre d''un maximum de 18 m.</p>
<p>Lorsque le Cylindre apparaît, chaque créature prise à l''intérieur effectue un jet de sauvegarde de Constitution. En cas d''échec, elle subit 2d10 dégâts radiants et, si elle est métamorphosée (par métamorphose, par exemple), elle reprend sa forme véritable et ne peut plus en changer tant qu''elle reste dans le Cylindre. En cas de réussite, elle subit uniquement la moitié de ces dégâts. Toute créature qui pénètre dans la zone ou y termine son tour est également soumise à ce JS. Une même créature n''effectue en aucun cas ce JS plus d''une fois par tour.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d10 par niveau d''emplacement au-delà du 2e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7985, 2358, 55, 2);

-- [2359] Rayon de soleil (niv 6, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2359, 'Rayon de soleil', 6, 1, NULL, 1, 1, 1, 0, 0, 'une loupe', 'personnelle', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous projetez un rayon de soleil sous forme d''une Ligne de 18 m de long et 1,50 m de large. Chaque créature prise dans la Ligne effectue un jet de sauvegarde de Constitution. En cas d''échec, elle subit 6d8 dégâts radiants, ainsi que l''état Aveuglé jusqu''au début de votre tour suivant. En cas de réussite, elle subit uniquement la moitié de ces dégâts.</p>
<p>Jusqu''à la fin du sort, vous pouvez entreprendre l''action Magie pour produire une nouvelle Ligne de radiance.</p>
<p>Pour toute la durée, un point de radiance brille juste au-dessus de vous. Il émet une Lumière vive sur un rayon de 9 m et une Lumière faible sur 9 m de plus. Cette lumière est celle du soleil.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7986, 2359, 54, 6),
  (7987, 2359, 55, 6),
  (7988, 2359, 56, 6),
  (7989, 2359, 52, 6);

-- [2360] Rayon empoisonné (niv 1, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2360, 'Rayon empoisonné', 1, 2, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous dardez un rayon verdâtre vers une créature à portée. Effectuez une attaque de sort à distance contre la cible. Si l''attaque touche, la cible subit 2d8 dégâts de poison, ainsi que l''état Empoisonné jusqu''à la fin de votre tour suivant.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d8 par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7990, 2360, 56, 1),
  (7991, 2360, 52, 1);

-- [2361] Rayon traçant (niv 1, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2361, 'Rayon traçant', 1, 1, NULL, 1, 1, 0, 0, 0, NULL, '36 m', '', '', 'action', '1 round', NULL, NULL, 0, 0, '<p>Vous projetez un trait de lumière vers une créature à portée. Effectuez une attaque de sort à distance contre la cible. Si l''attaque touche, la cible subit 4d6 dégâts radiants et le prochain jet d''attaque effectué contre elle avant la fin de votre tour suivant a l''Avantage.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d6 par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7992, 2361, 54, 1);

-- [2362] Régénération (niv 7, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2362, 'Régénération', 7, 4, NULL, 1, 1, 1, 0, 0, 'un moulin à prières', 'contact', '', '', '1 minute', '1 heure', NULL, NULL, 0, 0, '<p>Une créature que vous touchez physiquement récupère 4d8 + 15 points de vie. Pour toute la durée, la cible récupère 1 point de vie au début de chacun de ses tours et les parties sectionnées de son anatomie repoussent en 2 minutes.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7993, 2362, 53, 7),
  (7994, 2362, 54, 7),
  (7995, 2362, 55, 7);

-- [2363] Réincarnation (niv 5, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2363, 'Réincarnation', 5, 2, NULL, 1, 1, 1, 0, 0, 'des huiles rares d''une valeur minimale de 1 000 po, que le sort détruit', 'contact', '', '', '1 heure', 'instantanée', NULL, NULL, 0, 0, '<p>Vous touchez physiquement un Humanoïde mort ou l''un de ses restes. Si la créature n''est pas morte depuis plus de 10 jours, le sort forme un nouveau corps et appelle son âme pour prendre possession de ce corps. Lancez 1d10 pour déterminer l''espèce du nouveau corps (ou laissez le MJ choisir) :</p>
<p>1 — Relancez le dé<br>
2 — Drakéide<br>
3 — Elfe<br>
4 — Gnome<br>
5 — Goliath<br>
6 — Halfelin<br>
7 — Humain<br>
8 — Nain<br>
9 — Orc<br>
10 — Tieffelin</p>
<p>La créature réincarnée, qui fait les choix proposés par la description de l''espèce, se souvient de son ancienne vie et de ses expériences. Elle conserve les capacités dont elle disposait sous sa forme d''origine, si ce n''est qu''elle perd les traits de l''ancienne forme et acquiert ceux de la nouvelle.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7996, 2363, 55, 5);

-- [2364] Réparation (niv 0, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2364, 'Réparation', 0, 4, NULL, 1, 1, 1, 0, 0, 'deux magnétites', 'contact', '', '', '1 minute', 'instantanée', NULL, NULL, 0, 0, '<p>Ce sort répare une dégradation (déchirure ou bris) sur l''objet que vous touchez. Tant que la dégradation ne dépasse pas 30 cm dans quelque dimension que ce soit, vous la réparez et il n''en reste nulle trace.</p>
<p>Ce sort peut réparer la structure physique d''un objet magique, mais il ne lui rendra pas sa magie.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7997, 2364, 53, 0),
  (7998, 2364, 54, 0),
  (7999, 2364, 55, 0),
  (8000, 2364, 56, 0),
  (8001, 2364, 52, 0);

-- [2365] Repli expéditif (niv 1, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2365, 'Repli expéditif', 1, 4, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action Bonus', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Vous entreprenez l''action Pointe et, jusqu''à la fin du sort, vous pouvez entreprendre cette même action par une action Bonus.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8002, 2365, 56, 1),
  (8003, 2365, 52, 1),
  (8004, 2365, 58, 1);

-- [2366] Représailles infernales (niv 1, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2366, 'Représailles infernales', 1, 1, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'Réaction, que vous jouez lorsqu''une créature que vous voyez dans un rayon de 18 m vous inflige des dégâts', 'instantanée', NULL, NULL, 0, 0, '<p>La créature qui vous a infligé des dégâts se retrouve un court instant cernée de flammes vertes. Elle effectue un jet de sauvegarde de Dextérité, et subit 2d10 dégâts de feu en cas d''échec, la moitié en cas de réussite.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d10 par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8005, 2366, 58, 1);

-- [2367] Résistance (niv 0, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2367, 'Résistance', 0, 5, NULL, 1, 1, 0, 0, 0, NULL, 'contact', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous touchez physiquement une créature consentante en choisissant un type de dégâts entre : acide, contondants, feu, foudre, froid, nécrotiques, perforants, poison, radiants, tonnerre et tranchants. Quand la créature subit des dégâts du type retenu avant la fin du sort, elle réduit les dégâts subis de 1d4. Une même créature ne peut bénéficier qu''une fois par tour de ce sort.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8006, 2367, 54, 0),
  (8007, 2367, 55, 0);

-- [2368] Respiration aquatique (niv 3, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2368, 'Respiration aquatique', 3, 4, NULL, 1, 1, 1, 0, 0, 'un court roseau', '9 m', '', '', 'action ou rituel', '24 heures', NULL, NULL, 0, 1, '<p>Ce sort octroie la faculté de respirer sous l''eau à un maximum de dix créatures consentantes que vous choisissez à portée, jusqu''à la fin du sort. Les créatures affectées conservent leurs autres modes respiratoires.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8008, 2368, 55, 3),
  (8009, 2368, 56, 3),
  (8010, 2368, 52, 3),
  (8011, 2368, 60, 3);

-- [2369] Restauration partielle (niv 2, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2369, 'Restauration partielle', 2, 5, NULL, 1, 1, 0, 0, 0, NULL, 'contact', '', '', 'action Bonus', 'instantanée', NULL, NULL, 0, 0, '<p>Vous touchez physiquement une créature pour mettre fin à un état qui l''affecte parmi : Assourdi, Aveuglé, Empoisonné et Paralysé.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8012, 2369, 53, 2),
  (8013, 2369, 54, 2),
  (8014, 2369, 55, 2),
  (8015, 2369, 59, 2),
  (8016, 2369, 60, 2);

-- [2370] Restauration suprême (niv 5, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2370, 'Restauration suprême', 5, 5, NULL, 1, 1, 1, 0, 0, 'poudre de diamant d''une valeur minimale de 100 po, que le sort détruit', 'contact', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous touchez physiquement une créature pour lui retirer magiquement l''un des effets suivants :<br>
• 1 niveau d''Épuisement<br>
• L''état Charmé ou Pétrifié<br>
• Une malédiction, y compris l''Harmonisation éventuelle de la cible avec un objet magique maudit<br>
• Toute réduction de l''une des valeurs de caractéristique de la cible<br>
• Toute réduction du maximum de points de vie de la cible</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8017, 2370, 53, 5),
  (8018, 2370, 54, 5),
  (8019, 2370, 55, 5),
  (8020, 2370, 59, 5),
  (8021, 2370, 60, 5);

-- [2371] Résurrection (niv 7, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2371, 'Résurrection', 7, 2, NULL, 1, 1, 1, 0, 0, 'un diamant d''une valeur minimale de 1 000 po, que le sort détruit', 'contact', '', '', '1 heure', 'instantanée', NULL, NULL, 0, 0, '<p>D''un contact, vous ramenez à la vie une créature dont la mort ne remonte pas à plus d''un siècle, qui n''est pas morte de vieillesse et n''était pas un Mort-vivant au moment de mourir.</p>
<p>La créature revient à la vie avec tous ses points de vie. Ce sort neutralise également tous les poisons qui affectaient la créature, referme toutes les blessures mortelles et restitue l''anatomie manquante.</p>
<p>Revenir d''entre les morts demeure une épreuve. La cible subit un malus de –4 aux Tests d20. Chaque fois qu''elle termine un Repos long, ce malus diminue de 1, jusqu''à ce qu''il tombe à 0.</p>
<p>L''incantation de ce sort s''avère éreintante lorsqu''il s''agit de ramener à la vie une créature morte depuis 365 jours ou plus. Tant que vous n''avez pas terminé de Repos long, vous ne pouvez plus lancer de sort et vous subissez le Désavantage aux Tests d20.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8022, 2371, 53, 7),
  (8023, 2371, 54, 7);

-- [2372] Résurrection suprême (niv 9, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2372, 'Résurrection suprême', 9, 2, NULL, 1, 1, 1, 0, 0, 'au moins 25 000 po de diamants, que le sort détruit', 'contact', '', '', '1 heure', 'instantanée', NULL, NULL, 0, 0, '<p>Vous touchez une créature morte depuis un maximum de 200 ans pour quelque raison que ce soit, hormis de vieillesse. La créature est ranimée avec tous ses points de vie. Ce sort referme toutes les plaies, neutralise tous les poisons, soigne toutes les maladies magiques et lève toutes les malédictions. Il remplace les organes et membres endommagés ou manquants. Si la créature était un Mort-vivant, elle retrouve sa forme de vivant.</p>
<p>Le sort peut fournir un nouveau corps si celui d''origine n''existe plus, auquel cas vous devez prononcer le nom de la créature. Celle-ci apparaît en un espace inoccupé que vous choisissez dans un rayon de 3 m de vous.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8024, 2372, 54, 9),
  (8025, 2372, 55, 9);

-- [2373] Retour à la vie (niv 3, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2373, 'Retour à la vie', 3, 2, NULL, 1, 1, 1, 0, 0, 'un diamant d''une valeur minimale de 300 po, que le sort détruit', 'contact', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous touchez une créature morte dans la minute qui vient de s''écouler. La créature est ramenée à la vie avec 1 point de vie. Ce sort ne peut pas affecter une créature morte de vieillesse, pas plus qu''il ne restitue l''anatomie manquante.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8026, 2373, 54, 3),
  (8027, 2373, 55, 3),
  (8028, 2373, 59, 3),
  (8029, 2373, 60, 3);

-- [2374] Sanctification (niv 5, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2374, 'Sanctification', 5, 5, NULL, 1, 1, 1, 0, 0, 'encens d''une valeur minimale de 1 000 po, que le sort détruit', 'contact', '', '', '24 heures', 'jusqu''à dissipation', NULL, NULL, 0, 0, '<p>Vous touchez un point pour investir la zone environnante de pouvoir sacré ou impie (rayon jusqu''à 18 m). La zone présente les effets suivants.</p>
<p>Barrière sanctifiée. Choisissez un ou plusieurs types parmi : Aberrations, Célestes, Élémentaires, Fées, Fiélons et Morts-vivants. Les créatures de ces types ne peuvent pénétrer volontairement dans la zone. Toute créature possédée, Charmée ou Effrayée par de telles créatures ne l''est plus tant qu''elle reste dans la zone.</p>
<p>Effet supplémentaire. Vous liez l''un des effets suivants à la zone : Courage (immunité contre l''état Effrayé), Don des langues (communication universelle), Interférence extradimensionnelle (bloquer téléportation et voyage planaire), Lumière du jour (Lumière vive permanente), Repos paisible (les morts ne peuvent pas être transformés en Morts-vivants), Résistance (Résistance à un type de dégâts), Silence (aucun son ne franchit la zone), Ténèbres (obscurité totale), Terreur (état Effrayé pour les types retenus) ou Vulnérabilité (Vulnérabilité à un type de dégâts).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8030, 2374, 54, 5);

-- [2375] Sanctuaire (niv 1, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2375, 'Sanctuaire', 1, 5, NULL, 1, 1, 1, 0, 0, 'un éclat de verre issu d''un miroir', '9 m', '', '', 'action Bonus', '1 minute', NULL, NULL, 0, 0, '<p>Vous protégez une créature à portée. Jusqu''à la fin du sort, toute créature qui cible la créature protégée avec un jet d''attaque ou un sort nuisible doit réussir un jet de sauvegarde de Sagesse, sans quoi elle doit choisir une autre cible pour ne pas perdre l''attaque ou le sort. Ce sort ne protège pas la créature contre les zones d''effet. Le sort prend fin pour la créature protégée si elle effectue un jet d''attaque, lance un sort ou inflige des dégâts.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8031, 2375, 54, 1);

-- [2376] Sanctuaire privé (niv 4, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2376, 'Sanctuaire privé', 4, 5, NULL, 1, 1, 1, 0, 0, 'une feuille de plomb', '36 m', '', '', '10 minutes', '24 heures', NULL, NULL, 0, 0, '<p>Vous sécurisez magiquement une zone à portée (Cube de 1,50 m à 30 m d''arête) pour toute la durée. À l''incantation, vous choisissez autant de propriétés que souhaité parmi les suivantes :<br>
• Les sons ne franchissent pas le périmètre.<br>
• Le périmètre apparaît sombre et brumeux, empêchant de voir au travers.<br>
• Les capteurs des sorts de Divination ne peuvent ni apparaître à l''intérieur ni franchir son périmètre.<br>
• Les créatures de la zone ne peuvent pas être ciblées par les sorts de Divination.<br>
• Rien ne peut se téléporter dans la zone protégée ou hors d''elle.<br>
• Le voyage planaire est bloqué au sein de la zone protégée.</p>
<p>Lancer ce sort quotidiennement au même endroit pendant 365 jours fait persister le sort jusqu''à dissipation.</p>
<p>Emplacement de niveau supérieur. Vous pouvez augmenter l''arête du Cube de 30 m par niveau d''emplacement au-delà du 4e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8032, 2376, 52, 4);

-- [2377] Saut (niv 1, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2377, 'Saut', 1, 4, NULL, 1, 1, 1, 0, 0, 'une patte arrière de sauterelle', 'contact', '', '', 'action Bonus', '1 minute', NULL, NULL, 0, 0, '<p>Vous touchez une créature consentante. Une fois à chacun de ses tours jusqu''à la fin du sort, la créature peut sauter d''un maximum de 9 m en dépensant 3 m de déplacement.</p>
<p>Emplacement de niveau supérieur. Vous pouvez cibler une créature supplémentaire par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8033, 2377, 55, 1),
  (8034, 2377, 56, 1),
  (8035, 2377, 52, 1),
  (8036, 2377, 60, 1);

-- [2378] Scrutation (niv 5, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2378, 'Scrutation', 5, 7, NULL, 1, 1, 1, 0, 0, 'un focaliseur d''une valeur minimale de 1 000 po, comme une boule de cristal, un miroir en argent ou une vasque remplie d''eau bénite', 'personnelle', '', '', '10 minutes', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Vous voyez et entendez une créature de votre choix, située sur le même plan d''existence que vous. La cible effectue un jet de sauvegarde de Sagesse, modifié selon votre connaissance d''elle (indirecte +5, directe +0, intime –5) et les liens physiques que vous entretenez (portrait –2, bien personnel –4, élément anatomique –10). La cible ressent juste une forme de malaise.</p>
<p>En cas de réussite, la cible n''est pas affectée et vous ne pouvez plus réutiliser ce sort sur elle pendant 24 heures.</p>
<p>En cas d''échec, le sort crée un capteur Invisible et intangible dans un rayon de 3 m de la cible. Vous voyez et entendez par l''intermédiaire du capteur. Il se déplace avec la cible, en restant dans un rayon de 3 m d''elle pour toute la durée.</p>
<p>Plutôt qu''une créature, vous pouvez cibler un lieu que vous avez déjà vu. Le capteur apparaît à l''endroit désigné et ne bouge plus.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8037, 2378, 53, 5),
  (8038, 2378, 54, 5),
  (8039, 2378, 55, 5),
  (8040, 2378, 52, 5),
  (8041, 2378, 58, 5);

-- [2379] Serviteur invisible (niv 1, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2379, 'Serviteur invisible', 1, 6, NULL, 1, 1, 1, 0, 0, 'un bout de ficelle et un morceau de bois', '18 m', '', '', 'action ou rituel', '1 heure', NULL, NULL, 0, 1, '<p>Le sort crée une force de taille M, Invisible, dépourvue de conscience et de forme, qui accomplit des tâches rudimentaires sous vos ordres jusqu''à la fin du sort. Le serviteur se matérialise au sol en un espace inoccupé à portée. Il est doté d''une CA de 10, de 1 point de vie, d''une Force de 2, et ne peut pas effectuer d''attaques. S''il tombe à 0 point de vie, le sort prend fin.</p>
<p>À chacun de vos tours, vous pouvez par une action Bonus ordonner mentalement au serviteur de se déplacer d''un maximum de 4,50 m et d''interagir avec un objet. Il peut accomplir des tâches rudimentaires : aller chercher des objets, nettoyer, réparer, repasser les vêtements, allumer un feu ou servir les repas. Une fois l''instruction reçue, le serviteur s''y attèle jusqu''à l''avoir accomplie.</p>
<p>Si vous lui assignez une tâche qui lui demande de s''éloigner de plus de 18 m de vous, le sort prend fin.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8042, 2379, 53, 1),
  (8043, 2379, 52, 1),
  (8044, 2379, 58, 1);

-- [2380] Silence (niv 2, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2380, 'Silence', 2, 9, NULL, 1, 1, 0, 0, 0, NULL, '36 m', '', '', 'action ou rituel', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 1, '<p>Pour toute la durée, nul son ne peut être produit dans une Sphère de 6 m de rayon centrée sur un point que vous choisissez à portée. Les créatures et objets entièrement compris dans la Sphère ont l''Immunité contre les dégâts de tonnerre ; les créatures y subissent l''état Assourdi. Il est impossible de lancer un sort doté d''une composante verbale depuis l''intérieur de cette Sphère.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8045, 2380, 53, 2),
  (8046, 2380, 54, 2),
  (8047, 2380, 60, 2);

-- [2381] Simulacre (niv 7, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2381, 'Simulacre', 7, 9, NULL, 1, 1, 1, 0, 0, 'poudre de rubis d''une valeur minimale de 1 500 po, que le sort détruit', 'contact', '', '', '12 heures', 'jusqu''à dissipation', NULL, NULL, 0, 0, '<p>Vous façonnez un simulacre d''une Bête ou d''un Humanoïde qui se trouve dans un rayon de 3 m pendant tout le temps d''incantation. Vous terminez l''incantation en touchant physiquement la créature et un tas de neige ou de glace de même taille, qui prend alors la forme du simulacre. Il reprend le profil de la créature d''origine, si ce n''est qu''il s''agit d''un Artificiel, que son maximum de points de vie est moitié moindre et qu''il ne peut pas lancer de sorts.</p>
<p>Le simulacre est Amical envers vous et les créatures que vous désignez. Il obéit à vos ordres et agit à votre tour au combat. Il ne peut pas gagner de niveaux ni prendre de Repos.</p>
<p>Si le simulacre subit des dégâts, le seul moyen de lui restituer des points de vie consiste à le réparer lors d''un Repos long, en dépensant 100 po de composantes par point de vie restitué. Le simulacre doit rester dans un rayon de 1,50 m de vous durant toute l''opération.</p>
<p>Le simulacre persiste jusqu''à ce qu''il tombe à 0 point de vie, après quoi il fond. Si vous relancez ce sort, tout autre simulacre actif créé par ce sort est aussitôt détruit.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8048, 2381, 52, 7);

-- [2382] Simulacre de vie (niv 1, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2382, 'Simulacre de vie', 1, 2, NULL, 1, 1, 1, 0, 0, 'une goutte d''alcool', 'personnelle', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous recevez 2d4 + 4 points de vie temporaires.</p>
<p>Emplacement de niveau supérieur. Vous recevez 5 points de vie temporaires supplémentaires par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8049, 2382, 56, 1),
  (8050, 2382, 52, 1);

-- [2383] Soins (niv 1, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2383, 'Soins', 1, 5, NULL, 1, 1, 0, 0, 0, NULL, 'contact', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>La créature que vous touchez physiquement récupère un nombre de points de vie égal à 2d8 + votre modificateur de caractéristique d''incantation.</p>
<p>Emplacement de niveau supérieur. Les soins augmentent de 2d8 par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8051, 2383, 53, 1),
  (8052, 2383, 54, 1),
  (8053, 2383, 55, 1),
  (8054, 2383, 59, 1),
  (8055, 2383, 60, 1);

-- [2384] Soins de groupe (niv 5, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2384, 'Soins de groupe', 5, 5, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Une vague d''énergie curative déferle depuis un point que vous voyez à portée. Désignez un maximum de six créatures dans une Sphère de 9 m de rayon centrée sur ce point. Chaque cible récupère autant de points de vie que 5d8 + votre modificateur de caractéristique d''incantation.</p>
<p>Emplacement de niveau supérieur. Les soins augmentent de 1d8 par niveau d''emplacement au-delà du 5e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8056, 2384, 53, 5),
  (8057, 2384, 54, 5),
  (8058, 2384, 55, 5);

-- [2385] Sommeil (niv 1, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2385, 'Sommeil', 1, 3, NULL, 1, 1, 1, 0, 0, 'une pincée de sable ou des pétales de rose', '18 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Chaque créature que vous choisissez dans une Sphère de 1,50 m centrée sur un point à portée doit réussir un jet de sauvegarde de Sagesse sous peine de subir l''état Neutralisé jusqu''à la fin de son tour suivant et de réitérer le JS à la fin de cet intervalle. Si la cible rate ce second JS, elle subit l''état Inconscient pour toute la durée. Le sort prend fin sur toute cible qui subit des dégâts ou qui reçoit une secousse énergique d''une autre créature dans un rayon de 1,50 m d''elle.</p>
<p>Les créatures qui ne dorment pas, comme les elfes, et celles qui ont l''Immunité contre l''Épuisement, réussissent automatiquement leur JS contre ce sort.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8059, 2385, 53, 1),
  (8060, 2385, 56, 1),
  (8061, 2385, 52, 1);

-- [2386] Songe (niv 5, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2386, 'Songe', 5, 9, NULL, 1, 1, 1, 0, 0, 'une poignée de sable', 'spéciale', '', '', '1 minute', '8 heures', NULL, NULL, 0, 0, '<p>Vous ciblez une créature que vous connaissez sur votre plan d''existence. Vous-même, ou une créature consentante que vous touchez, entrez en transe pour faire office de messager onirique. Tant qu''il est en transe, le messager est Neutralisé et sa Vitesse est de 0.</p>
<p>Si la cible est endormie, le messager lui apparaît en rêve et peut converser avec elle aussi longtemps que le sommeil se prolonge et que le sort persiste. Le messager peut également façonner l''environnement du songe. Le messager peut sortir de sa transe à tout moment, ce qui met fin au sort. La cible se souvient parfaitement du songe à son réveil.</p>
<p>Si la cible est réveillée à l''incantation du sort, le messager le sait et peut mettre un terme à sa transe ou attendre que la cible s''endorme.</p>
<p>Vous pouvez rendre le messager terrifiant pour la cible. Dans ce cas, il livre un message qui ne dépasse pas dix mots, après quoi la cible effectue un jet de sauvegarde de Sagesse. En cas d''échec, la cible ne reçoit aucun bénéfice de son Repos et subit 3d6 dégâts psychiques à son réveil.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8062, 2386, 53, 5),
  (8063, 2386, 52, 5),
  (8064, 2386, 58, 5);

-- [2387] Souffle du dragon (niv 2, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2387, 'Souffle du dragon', 2, 4, NULL, 1, 1, 1, 0, 0, 'un piment', 'contact', '', '', 'action Bonus', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous touchez physiquement une créature consentante et choisissez entre acide, feu, foudre, froid ou poison. Jusqu''à la fin du sort, la cible peut entreprendre l''action Magie pour exhaler un Cône de 4,50 m. Chaque créature prise dans la zone effectue un jet de sauvegarde de Dextérité, et subit 3d6 dégâts du type choisi en cas d''échec, la moitié en cas de réussite.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d6 par niveau d''emplacement au-delà du 2e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8065, 2387, 56, 2),
  (8066, 2387, 52, 2);

-- [2388] Souhait (niv 9, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2388, 'Souhait', 9, 6, NULL, 1, 0, 0, 0, 0, NULL, 'personnelle', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Souhait est le sort le plus puissant que puisse lancer un mortel. De votre seule voix, vous pouvez influer sur la réalité même.</p>
<p>L''utilisation standard du sort revient à reproduire le sort de votre choix du 8e niveau ou inférieur. Dans cette version, vous n''avez pas besoin de remplir les conditions habituelles du sort. Le sort prend tout simplement effet.</p>
<p>Une autre approche vous permet de produire l''un des effets suivants :</p>
<p>Création d''objet. Vous créez un objet non magique d''une valeur maximale de 25 000 po. Aucune dimension ne peut dépasser 90 m et il apparaît au sol en un espace inoccupé que vous voyez.</p>
<p>Santé souveraine. Vous permettez à un maximum de vingt créatures que vous voyez de récupérer tous leurs points de vie et mettre un terme aux effets décrits pour restauration suprême.</p>
<p>Résistance. Vous octroyez la Résistance au type de dégâts de votre choix à un maximum de dix créatures que vous voyez. Cette Résistance est permanente.</p>
<p>Immunité magique. Vous octroyez l''Immunité contre un sort ou effet magique unique pendant 8 heures, à un maximum de dix créatures que vous voyez.</p>
<p>Apprentissage instantané. Vous remplacez l''un de vos dons par un autre don pour lequel vous remplissez les prérequis.</p>
<p>Caprice des dés. Vous modifiez un événement récent en faisant rejouer un jet de dés intervenu au cours du dernier round. Vous pouvez décider que le jet se rejoue avec l''Avantage ou le Désavantage.</p>
<p>Réalité remodelée. Vous pouvez souhaiter quelque chose qui n''entre pas dans le cadre de ces effets. Plus le souhait est ambitieux, plus il risque d''engendrer des incidents ou de ne produire que partiellement l''effet désiré.</p>
<p>Dès lors qu''il ne s''agit pas seulement de reproduire les effets d''un autre sort, lancer souhait est une véritable épreuve. Après une telle gageure, chaque fois que vous jetez un sort sans avoir terminé un Repos long, vous subissez 1d10 dégâts nécrotiques par niveau du sort. De plus, votre valeur de Force passe à 3 pendant 2d4 jours, avec un risque de 33 % que vous ne soyez plus jamais capable de relancer souhait.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8067, 2388, 56, 9),
  (8068, 2388, 52, 9);

-- [2389] Sphère de feu (niv 2, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2389, 'Sphère de feu', 2, 6, NULL, 1, 1, 1, 0, 0, 'une boule de cire', '18 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous produisez une Sphère de flammes de 1,50 m de diamètre qui apparaît au sol en un espace inoccupé à portée. Toute créature qui termine son tour dans un rayon de 1,50 m de la Sphère effectue un jet de sauvegarde de Dextérité et subit 2d6 dégâts de feu en cas d''échec, la moitié en cas de réussite.</p>
<p>Par une action Bonus, vous pouvez déplacer la Sphère d''un maximum de 9 m en la faisant rouler au sol. Si vous la déplacez dans l''espace d''une créature, celle-ci effectue un jet de sauvegarde contre ses dégâts, puis la Sphère cesse de se déplacer.</p>
<p>La Sphère peut franchir des obstacles dont la hauteur ne dépasse pas 1,50 m et des fosses d''une largeur maximale de 3 m. Elle embrase les objets inflammables non portés et produit une Lumière vive sur un rayon de 6 m et une Lumière faible sur 6 m de plus.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d6 par niveau d''emplacement au-delà du 2e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8069, 2389, 55, 2),
  (8070, 2389, 56, 2),
  (8071, 2389, 52, 2);

-- [2390] Sphère de vitriol (niv 4, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2390, 'Sphère de vitriol', 4, 1, NULL, 1, 1, 1, 0, 0, 'une goutte de bile', '45 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous pointez du doigt un lieu à portée et une boule d''acide luisant, de 30 cm de diamètre, y file aussitôt et y explose sous forme de Sphère de 6 m de rayon. Chaque créature prise dans la zone effectue un jet de sauvegarde de Dextérité. En cas d''échec, elle subit 10d4 dégâts d''acide, puis 5d4 dégâts d''acide à la fin de son tour suivant. En cas de réussite, elle subit uniquement la moitié des dégâts initiaux.</p>
<p>Emplacement de niveau supérieur. Les dégâts initiaux augmentent de 2d4 par niveau d''emplacement au-delà du 4e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8072, 2390, 56, 4),
  (8073, 2390, 52, 4);

-- [2391] Sphère glacée (niv 6, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2391, 'Sphère glacée', 6, 1, NULL, 1, 1, 1, 0, 0, 'une sphère miniature en cristal', '90 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Un globe glacial jaillit de vous vers un point que vous choisissez à portée, où il explose sous forme d''une Sphère de 18 m de rayon. Chaque créature prise dans la zone effectue un jet de sauvegarde de Constitution et subit 10d6 dégâts de froid en cas d''échec, la moitié en cas de réussite.</p>
<p>Si le globe heurte un volume d''eau, il gèle cette eau sur une profondeur de 15 cm et une surface de 9 m de côté. Les créatures qui nageaient à la surface se retrouvent bloquées dans la glace, avec l''état Entravé. Une créature bloquée peut consacrer une action à réussir un test de Force (Athlétisme) assorti de votre DD de sauvegarde des sorts pour s''extraire.</p>
<p>Vous pouvez vous retenir de projeter le globe une fois l''incantation terminée. Dans ce cas, un globe de la taille d''une bille apparaît dans votre main. Vous ou une autre créature pouvez le projeter (portée max. 12 m) ou utiliser une fronde pour le lancer. Il se brise à l''impact. Au bout de 1 minute sans bris, le globe explose.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d6 par niveau d''emplacement au-delà du 6e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8074, 2391, 56, 6),
  (8075, 2391, 52, 6);

-- [2392] Sphère résiliente (niv 4, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2392, 'Sphère résiliente', 4, 5, NULL, 1, 1, 1, 0, 0, 'une sphère de verre', '9 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Une Sphère chatoyante séquestre une créature ou un objet de taille G ou inférieure à portée. Une créature non consentante doit réussir un jet de sauvegarde de Dextérité pour ne pas être confinée pour toute la durée.</p>
<p>Rien, ni les objets physiques, ni l''énergie, ni les autres effets de sort, ne peut franchir cette barrière dans un sens comme dans l''autre, mais la créature séquestrée peut respirer normalement. La Sphère est immunisée contre tous les dégâts.</p>
<p>La Sphère ne pèse rien. Une créature confinée peut consacrer son action à pousser sur les parois et faire rouler la Sphère à concurrence de la moitié de sa propre Vitesse. D''autres créatures peuvent également la ramasser et la déplacer.</p>
<p>Le sort désintégration, s''il cible le globe, le détruit sans risque pour ce qui se trouve à l''intérieur.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8076, 2392, 52, 4);

-- [2393] Stabilisation (niv 0, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2393, 'Stabilisation', 0, 2, NULL, 1, 1, 0, 0, 0, NULL, '4,50 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Choisissez à portée une créature dotée de 0 point de vie, mais qui n''est pas morte. La créature est Stabilisée.</p>
<p>Amélioration de sort mineur. La portée augmente lorsque vous atteignez les niveaux 5 (9 m), 11 (18 m) et 17 (36 m).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8077, 2393, 54, 0),
  (8078, 2393, 55, 0);

-- [2394] Suggestion (niv 2, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2394, 'Suggestion', 2, 3, NULL, 1, 0, 1, 0, 0, 'une goutte de miel', '9 m', '', '', 'action', 'Concentration, jusqu''à 8 heures', NULL, NULL, 1, 0, '<p>Vous suggérez une ligne de conduite par 25 mots ou moins afin d''influencer magiquement une créature que vous voyez à portée, qui vous entend et vous comprend. La suggestion doit paraître raisonnable et ne pas présenter de risque évident d''infliger des dégâts à la cible ni à ses alliés.</p>
<p>La cible doit réussir un jet de sauvegarde de Sagesse sous peine de subir l''état Charmé pour toute la durée ou jusqu''à que vous ou l''un de vos alliés lui infligiez des dégâts. La cible Charmée se soumet à la suggestion de son mieux. L''activité suggérée peut s''étendre sur toute la durée, mais s''il est possible de l''accomplir plus tôt, le sort prend fin sur la cible dès qu''elle en a terminé.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8079, 2394, 53, 2),
  (8080, 2394, 56, 2),
  (8081, 2394, 52, 2),
  (8082, 2394, 58, 2);

-- [2395] Suggestion de groupe (niv 6, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2395, 'Suggestion de groupe', 6, 3, NULL, 1, 0, 1, 0, 0, 'une langue de serpent', '18 m', '', '', 'action', '24 heures', NULL, NULL, 0, 0, '<p>Vous suggérez une ligne de conduite par 25 mots ou moins afin d''influencer magiquement un maximum de douze créatures que vous voyez à portée et qui vous entendent et vous comprennent. La suggestion doit paraître raisonnable et ne pas présenter de risque évident d''infliger des dégâts aux cibles.</p>
<p>Chaque cible doit réussir un jet de sauvegarde de Sagesse sous peine de subir l''état Charmé pour toute la durée ou jusqu''à que vous ou l''un de vos alliés lui infligiez des dégâts. Chaque cible Charmée se soumet à la suggestion de son mieux.</p>
<p>Emplacement de niveau supérieur. La durée rallonge avec un emplacement du 7e niveau (10 jours), du 8e (30 jours) et du 9e (366 jours).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8083, 2395, 53, 6),
  (8084, 2395, 56, 6),
  (8085, 2395, 52, 6);

-- [2396] Symbole (niv 7, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2396, 'Symbole', 7, 5, NULL, 1, 1, 1, 0, 0, 'poudre de diamant d''une valeur minimale de 1 000 po, que le sort détruit', 'contact', '', '', '1 minute', 'jusqu''à dissipation ou activation', NULL, NULL, 0, 0, '<p>Vous inscrivez un glyphe nuisible, soit sur une surface, soit à l''intérieur d''un objet fermable. Le glyphe peut recouvrir une zone dont le diamètre ne dépasse pas 3 m. Si l''objet se déplace de plus de 3 m de l''endroit de l''incantation, le glyphe est rompu et le sort prend fin.</p>
<p>Le glyphe est pratiquement imperceptible (test de Sagesse (Perception) contre votre DD de sauvegarde pour le remarquer). Lors de l''inscription, vous décidez du déclencheur et de l''effet porté par le symbole.</p>
<p>Quand il s''active, le glyphe emplit une Sphère de 18 m de rayon de Lumière faible pendant 10 minutes, après quoi le sort prend fin. Chaque créature prise dans la Sphère au moment de l''activation est ciblée par l''effet choisi :</p>
<p>Discorde. JS Sagesse. Échec : chamailleries verbales pendant 1 minute (Désavantage aux jets d''attaque et tests de caractéristique).</p>
<p>Douleur. JS Constitution. Échec : état Neutralisé pendant 1 minute.</p>
<p>Étourdissement. JS Sagesse. Échec : état Étourdi pendant 1 minute.</p>
<p>Mort. JS Constitution. Échec : 10d10 dégâts nécrotiques. Réussite : 1/2.</p>
<p>Sommeil. JS Sagesse. Échec : état Inconscient pendant 10 minutes (réveil sur dégâts ou secousse).</p>
<p>Terreur. JS Sagesse. Échec : état Effrayé pendant 1 minute (la cible doit s''éloigner d''au moins 9 m du glyphe).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8086, 2396, 53, 7),
  (8087, 2396, 54, 7),
  (8088, 2396, 55, 7),
  (8089, 2396, 52, 7);

-- [2397] Télékinésie (niv 5, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2397, 'Télékinésie', 5, 4, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Vous recevez la faculté de déplacer ou manipuler objets et créatures par la simple pensée. À l''incantation, ainsi qu''au prix de l''action Magie à vos tours suivants avant la fin du sort, vous pouvez exercer votre volonté sur une créature ou un objet que vous voyez à portée.</p>
<p>Créature. Vous tentez de déplacer une créature de taille TG ou inférieure. Elle doit réussir un JS de Force sous peine d''être déplacée d''un maximum de 9 m dans la direction de votre choix. Jusqu''à la fin de votre tour suivant, la créature subit l''état Entravé ; si vous la soulevez dans les airs, elle y reste suspendue. Elle chute à la fin de votre tour suivant sauf si vous recourez une nouvelle fois à cette option et qu''elle rate le JS.</p>
<p>Objet. Vous tentez de déplacer un objet de taille TG ou inférieure. S''il n''est porté par personne, vous le déplacez automatiquement d''un maximum de 9 m. S''il est porté par une créature, celle-ci doit réussir un JS de Force, sans quoi vous lui arrachez l''objet. Vous pouvez exercer un contrôle plus précis sur les objets, comme manipuler un outil rudimentaire.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8090, 2397, 56, 5),
  (8091, 2397, 52, 5);

-- [2398] Téléportation (niv 7, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2398, 'Téléportation', 7, 6, NULL, 1, 0, 0, 0, 0, NULL, '3 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Ce sort vous transporte instantanément, ainsi que huit créatures consentantes que vous voyez à portée, ou bien un seul objet de taille G ou inférieure, vers la destination sélectionnée. Vous devez connaître la destination et elle doit se trouver sur le même plan. Votre niveau de familiarité avec la destination détermine si vous y parvenez effectivement (le MJ lance 1d100) :</p>
<p>Cercle permanent ou Objet lié → Sur place 01–100.<br>
Grande familiarité → Incident 01–05, Zone comparable 06–13, Déviation 14–24, Sur place 25–100.<br>
Vu plusieurs fois → Incident 01–33, Zone comparable 34–43, Déviation 44–53, Sur place 54–100.<br>
Vu une fois ou décrit → Incident 01–43, Zone comparable 44–53, Déviation 54–73, Sur place 74–100.<br>
Destination factice → Incident 01–50, Zone comparable 51–100.</p>
<p>Incident : chaque téléporté subit 3d10 dégâts de force, puis le MJ relance sur la table.<br>
Zone comparable : vous arrivez dans un lieu d''ambiance comparable.<br>
Déviation : vous arrivez à 2d12 × 1,5 km dans une direction aléatoire.<br>
Sur place : vous arrivez à l''endroit souhaité.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8092, 2398, 53, 7),
  (8093, 2398, 56, 7),
  (8094, 2398, 52, 7);

-- [2399] Tempête de feu (niv 7, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2399, 'Tempête de feu', 7, 1, NULL, 1, 1, 0, 0, 0, NULL, '45 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Une tempête de flammes éclate à portée. La zone de la tempête consiste en un maximum de 10 Cubes de 3 m, que vous disposez à votre guise. Chaque Cube doit être contigu à au moins un autre Cube. Chaque créature prise dans la zone effectue un jet de sauvegarde de Dextérité et subit 7d10 dégâts de feu en cas d''échec, la moitié en cas de réussite.</p>
<p>L''explosion embrase les objets inflammables de la zone qui ne sont portés par personne.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8095, 2399, 54, 7),
  (8096, 2399, 55, 7),
  (8097, 2399, 56, 7);

-- [2400] Tempête de grêle (niv 4, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2400, 'Tempête de grêle', 4, 1, NULL, 1, 1, 1, 0, 0, 'une moufle', '90 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>La grêle s''abat au sol dans un Cylindre de 6 m de rayon et 12 m de hauteur centré sur un point à portée. Chaque créature prise dans le Cylindre effectue un jet de sauvegarde de Dextérité. Elle subit 2d10 dégâts contondants et 4d6 dégâts de froid en cas d''échec, la moitié en cas de réussite.</p>
<p>Les grêlons transforment le sol du Cylindre en Terrain difficile jusqu''à la fin de votre tour suivant.</p>
<p>Emplacement de niveau supérieur. Les dégâts contondants augmentent de 1d10 par niveau d''emplacement au-delà du 4e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8098, 2400, 55, 4),
  (8099, 2400, 56, 4),
  (8100, 2400, 52, 4);

-- [2401] Tempête de neige (niv 3, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2401, 'Tempête de neige', 3, 6, NULL, 1, 1, 1, 0, 0, 'un parapluie miniature', '45 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Jusqu''à la fin du sort, la neige tombe dans un Cylindre de 12 m de haut et 6 m de diamètre centré sur un point que vous choisissez à portée. La Visibilité de la zone est nulle et les flammes nues s''y éteignent aussitôt.</p>
<p>Le sol du Cylindre constitue un Terrain difficile. Quand une créature pénètre dans le Cylindre pour la première fois d''un tour ou qu''elle y commence son tour, elle doit réussir un jet de sauvegarde de Dextérité sous peine de subir l''état À terre et de perdre sa Concentration.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8101, 2401, 55, 3),
  (8102, 2401, 56, 3),
  (8103, 2401, 52, 3);

-- [2402] Tempête vengeresse (niv 9, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2402, 'Tempête vengeresse', 9, 6, NULL, 1, 1, 0, 0, 0, NULL, '1,5 km', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Un nuage menaçant se forme pour toute la durée, centré sur un point à portée, et se déploie sur un rayon de 90 m. Chaque créature prise dans le nuage à son apparition doit réussir un JS de Constitution sous peine de subir 2d6 dégâts de tonnerre et l''état Assourdi pour toute la durée.</p>
<p>Au début de chacun de vos tours suivants, la tempête produit des effets différents :<br>
Tour 2 — Pluie acide : tous les objets et créatures directement dominés par le nuage subissent 4d6 dégâts d''acide.<br>
Tour 3 — Six éclairs frappent six cibles dominées par le nuage (JS Dextérité, 10d6 foudre en cas d''échec, 1/2 en cas de réussite).<br>
Tour 4 — Grêle : toute créature directement dominée subit 2d6 dégâts contondants.<br>
Tours 5 à 10 — Bourrasques et pluie glaciale : 1d6 dégâts de froid, Terrain difficile, Visibilité nulle, attaques à distance avec une arme impossibles, vent fort dans toute la zone.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8104, 2402, 55, 9);

-- [2403] Ténèbres (niv 2, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2403, 'Ténèbres', 2, 1, NULL, 1, 1, 1, 0, 0, 'une touffe de fourrure de chauve-souris et un bout de charbon', '18 m', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Pour toute la durée, des Ténèbres magiques se déploient depuis un point à portée en remplissant une Sphère de 4,50 m de rayon. La Vision dans le noir ne perce pas ces ténèbres et les lumières non magiques n''illuminent pas dans la Sphère.</p>
<p>Au lieu de cela, vous pouvez lancer le sort sur un objet porté par personne, de manière à ce que les Ténèbres emplissent une Émanation de 4,50 m centrée sur l''objet. Recouvrir l''objet d''une surface opaque bloque les Ténèbres.</p>
<p>Si tout ou partie de ce sort chevauche la zone de Lumière vive ou faible créée par un sort du 2e niveau ou inférieur, l''effet qui produit cette lumière est dissipé.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8105, 2403, 56, 2),
  (8106, 2403, 52, 2),
  (8107, 2403, 58, 2);

-- [2404] Tentacules noirs (niv 4, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2404, 'Tentacules noirs', 4, 6, NULL, 1, 1, 1, 0, 0, 'un tentacule', '27 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Des tentacules frétillants d''un noir d''ébène surgissent du sol et emplissent un espace de 6 m de côté que vous voyez à portée. Pour toute la durée, ces tentacules transforment le sol de la zone en Terrain difficile.</p>
<p>Toute créature prise dans la zone effectue un jet de sauvegarde de Force. En cas d''échec, elle subit 3d6 dégâts contondants, ainsi que l''état Entravé jusqu''à la fin du sort. Une créature effectue aussi ce JS si elle pénètre dans la zone ou y termine son tour. Une même créature n''effectue en aucun cas ce JS plus d''une fois par tour.</p>
<p>Une créature Entravée peut entreprendre une action pour effectuer un test de Force (Athlétisme) assorti de votre DD de sauvegarde des sorts et mettre un terme à l''état sur elle-même en cas de réussite.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8108, 2404, 52, 4);

-- [2405] Terrain hallucinatoire (niv 4, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2405, 'Terrain hallucinatoire', 4, 9, NULL, 1, 1, 1, 0, 0, 'un champignon', '90 m', '', '', '10 minutes', '24 heures', NULL, NULL, 0, 0, '<p>Un terrain naturel dans un Cube de 45 m à portée apparaît comme un autre type de terrain naturel, sur les plans visuel, auditif et olfactif. Les bâtiments, l''équipement et les créatures de la zone ne changent pas.</p>
<p>Les propriétés tactiles du terrain ne changent pas, si bien qu''une créature qui pénètre dans la zone remarquera probablement l''illusion. Si la différence n''est pas évidente au contact, une créature peut entreprendre l''action Étude pour tenter un test d''Intelligence (Investigation) assorti de votre DD de sauvegarde des sorts afin de percer l''illusion à jour.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8109, 2405, 53, 4),
  (8110, 2405, 55, 4),
  (8111, 2405, 52, 4),
  (8112, 2405, 58, 4);

-- [2406] Terreur (niv 3, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2406, 'Terreur', 3, 9, NULL, 1, 1, 1, 0, 0, 'une plume blanche', 'personnelle', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Chaque créature prise dans un Cône de 9 m doit réussir un jet de sauvegarde de Sagesse sous peine de lâcher ce qu''elle tient, et de subir l''état Effrayé pour toute la durée.</p>
<p>Ainsi Effrayée, la créature entreprend à chacun de ses tours l''action Pointe pour s''éloigner de vous par le chemin le plus sûr, sauf si elle n''a nulle part où aller. Si la créature termine son tour en un espace d''où elle ne vous a plus dans son champ de vision, elle effectue un jet de sauvegarde de Sagesse. En cas de réussite, le sort prend fin pour elle.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8113, 2406, 53, 3),
  (8114, 2406, 56, 3),
  (8115, 2406, 52, 3),
  (8116, 2406, 58, 3);

-- [2407] Texte illusoire (niv 1, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2407, 'Texte illusoire', 1, 9, NULL, 0, 1, 1, 0, 0, 'de l''encre d''une valeur minimale de 10 po, que le sort détruit', 'contact', '', '', '1 minute ou rituel', '10 jours', NULL, NULL, 0, 1, '<p>Vous écrivez sur du parchemin, du papier ou autre surface adaptée et y insufflez une illusion qui persiste pour toute la durée. À vos yeux, ainsi qu''à ceux de toute créature que vous désignez à l''incantation, le texte paraît normalement écrit et porte le message voulu. Pour toute autre créature, le texte paraît rédigé selon un alphabet inconnu ou magique, parfaitement incompréhensible. Une autre option consiste à donner un sens différent au message, qui semble écrit par quelqu''un d''autre et dans une autre langue que vous maîtrisez.</p>
<p>Si le sort est dissipé, le texte original et l''illusion disparaissent.</p>
<p>Une créature dotée de la Vision lucide peut lire le message caché.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8117, 2407, 53, 1),
  (8118, 2407, 52, 1),
  (8119, 2407, 58, 1);

-- [2408] Thaumaturgie (niv 0, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2408, 'Thaumaturgie', 0, 4, NULL, 1, 0, 0, 0, 0, NULL, '9 m', '', '', 'action', 'jusqu''à 1 minute', NULL, NULL, 0, 0, '<p>Vous engendrez une manifestation surnaturelle mineure. Vous créez l''un des effets magiques suivants à portée. Si vous lancez ce sort plusieurs fois, vous pouvez faire coexister jusqu''à trois de ces effets d''une minute.</p>
<p>Bruit fantôme. Vous faites émaner un son bref d''un point que vous choisissez à portée, comme un grondement de tonnerre, un croassement ou des murmures inquiétants.</p>
<p>Jeu avec le feu. Vous manipulez des flammes pendant 1 minute : elles vacillent, s''intensifient, s''atténuent ou changent de couleur.</p>
<p>Main invisible. Vous provoquez l''ouverture soudaine d''une porte ou fenêtre non verrouillée ou la faites claquer.</p>
<p>Secousse. Vous provoquez un léger tremblement de terre inoffensif pendant 1 minute.</p>
<p>Voix retentissante. Votre voix retentit jusqu''à trois fois plus fort que la normale pendant 1 minute. Pour toute la durée, vous avez l''Avantage aux tests de Charisme (Intimidation).</p>
<p>Yeux modifiés. Vous altérez l''aspect de vos yeux pendant 1 minute.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8120, 2408, 54, 0);

-- [2409] Toile d'araignée (niv 2, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2409, 'Toile d''araignée', 2, 6, NULL, 1, 1, 1, 0, 0, 'quelques filandres de toile d''araignée', '18 m', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Vous invoquez une masse gluante de fils d''araignée en un point que vous choisissez à portée. Pour toute la durée, cette toile remplit un Cube de 6 m depuis ce point d''origine. Elle constitue un Terrain difficile et la Visibilité est réduite dans la zone.</p>
<p>Si les fils ne peuvent pas se fixer à deux volumes solides et ne sont pas disposés en travers d''un sol, d''un mur ou d''un plafond, la toile s''effondre et le sort prend fin au début de votre tour suivant.</p>
<p>Quand une créature pénètre pour la première fois d''un tour dans la toile ou qu''elle y commence son tour, elle doit réussir un jet de sauvegarde de Dextérité sous peine de subir l''état Entravé. Une créature ainsi Entravée peut consacrer son action à effectuer un test de Force (Athlétisme) assorti de votre DD de sauvegarde des sorts pour se libérer.</p>
<p>La toile est inflammable. Tout Cube de toile de 1,50 m exposé aux flammes brûle en 1 round et inflige 2d4 dégâts de feu à toute créature qui commence son tour dans les flammes.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8121, 2409, 56, 2),
  (8122, 2409, 52, 2);

-- [2410] Trait de feu (niv 0, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2410, 'Trait de feu', 0, 1, NULL, 1, 1, 0, 0, 0, NULL, '36 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous projetez un grain enflammé vers une créature ou un objet à portée. Effectuez une attaque de sort à distance contre la cible. Si l''attaque touche, la cible subit 1d10 dégâts de feu. Tout objet inflammable touché par ce sort s''embrase s''il n''est pas porté.</p>
<p>Amélioration de sort mineur. Les dégâts augmentent de 1d10 lorsque vous atteignez les niveaux 5 (2d10), 11 (3d10) et 17 (4d10).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8123, 2410, 56, 0),
  (8124, 2410, 52, 0);

-- [2411] Tremblement de terre (niv 8, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2411, 'Tremblement de terre', 8, 4, NULL, 1, 1, 1, 0, 0, 'une pierre brisée', '150 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Choisissez un point du sol que vous voyez à portée. Pour toute la durée, le sol est parcouru d''intenses secousses dans un cercle de 30 m de rayon centré sur ce point, qui constitue un Terrain difficile.</p>
<p>À l''incantation du sort et à la fin de chacun de vos tours pour toute la durée, chaque créature au contact du sol de la zone effectue un jet de sauvegarde de Dextérité. En cas d''échec, la créature subit l''état À terre et sa Concentration est rompue.</p>
<p>Vous pouvez également provoquer les effets ci-après.</p>
<p>Crevasses. Un total de 1d6 crevasses s''ouvrent dans la zone à la fin du tour de l''incantation. Chacune est profonde de 1d10 × 3 m, large de 3 m et s''étend d''un bout à l''autre de la zone. Une créature dans l''espace d''une fissure doit réussir un JS de Dextérité sous peine d''y chuter.</p>
<p>Structures. Le séisme inflige 50 dégâts contondants à toute structure en contact avec le sol à l''incantation et à la fin de chacun de vos tours jusqu''à la fin du sort. Si un bâtiment tombe à 0 pv, il s''effondre. Une créature dans le rayon d''effondrement effectue un JS de Dextérité (12d6 dégâts contondants + état À terre + ensevelissement en cas d''échec, moitié en cas de réussite). S''extraire demande un test de Force (Athlétisme) DD 20.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8125, 2411, 54, 8),
  (8126, 2411, 55, 8),
  (8127, 2411, 56, 8);

-- [2412] Tsunami (niv 8, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2412, 'Tsunami', 8, 6, NULL, 1, 1, 0, 0, 0, NULL, '1,5 km', '', '', '1 minute', 'Concentration, jusqu''à 6 rounds', NULL, NULL, 1, 0, '<p>Une muraille d''eau se matérialise en un point que vous choisissez à portée. Ce mur peut atteindre jusqu''à 90 m de longueur, 90 m de hauteur et 15 m d''épaisseur. Le mur persiste pour toute la durée.</p>
<p>Quand le mur apparaît, chaque créature prise dans sa zone effectue un jet de sauvegarde de Force et subit 6d10 dégâts contondants en cas d''échec, la moitié en cas de réussite.</p>
<p>Au début de chacun de vos tours suivants, le mur et toutes les créatures qu''il englobe s''éloignent de 15 m de vous. Toutes les créatures de taille TG ou inférieure qui occupent un espace dans lequel le mur se déplace doivent réussir un JS de Force sous peine de subir 5d10 dégâts contondants. À la fin du tour, la hauteur du mur diminue de 15 m et les dégâts des rounds suivants diminuent de 1d10. Quand la hauteur atteint 0, le sort prend fin.</p>
<p>Une créature prise dans le mur ne peut se déplacer qu''en nageant (test de Force (Athlétisme) contre votre DD pour se déplacer). En cas d''échec, elle ne peut pas se déplacer. Une créature qui sort du mur tombe au sol.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8128, 2412, 55, 8);

-- [2413] Vague tonnante (niv 1, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2413, 'Vague tonnante', 1, 1, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous produisez une vague de force tonitruante. Chaque créature prise dans un Cube de 4,50 m émanant de vous effectue un jet de sauvegarde de Constitution. En cas d''échec, la créature subit 2d8 dégâts de tonnerre et le choc l''éloigne de 3 m de vous. En cas de réussite, elle subit uniquement la moitié de ces dégâts.</p>
<p>En outre, les objets non fixés entièrement compris dans le Cube sont automatiquement repoussés de 3 m de vous par le sort, dont le fracas s''entend à une distance de 90 m.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d8 par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8129, 2413, 53, 1),
  (8130, 2413, 55, 1),
  (8131, 2413, 56, 1),
  (8132, 2413, 52, 1);

-- [2414] Vent divin (niv 6, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2414, 'Vent divin', 6, 4, NULL, 1, 1, 1, 0, 0, 'une bougie', '9 m', '', '', '1 minute', '8 heures', NULL, NULL, 0, 0, '<p>Vous et un maximum de dix créatures consentantes que vous choisissez à portée adoptez une forme gazeuse pour toute la durée. Sous cette forme brumeuse, une cible est dotée d''une Vitesse de vol de 90 m avec vol stationnaire, de l''Immunité contre l''état À terre et de la Résistance aux dégâts contondants, perforants et tranchants. Les seules actions qu''elle peut entreprendre sont l''action Pointe et commencer à reprendre sa forme normale (action Magie, 1 minute nécessaire, état Étourdi pendant ce temps).</p>
<p>Si une cible est sous forme gazeuse et en vol au moment où le sort prend fin, elle redescend au rythme de 18 m par round pendant 1 minute, jusqu''à atterrir sans heurt. Si cette minute ne lui a pas suffi à toucher le sol, la cible chute de la distance restante.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8133, 2414, 55, 6);

-- [2415] Verrou magique (niv 2, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2415, 'Verrou magique', 2, 5, NULL, 1, 1, 1, 0, 0, 'poudre d''or d''une valeur minimale de 25 po, que le sort détruit', 'contact', '', '', 'action', 'jusqu''à dissipation', NULL, NULL, 0, 0, '<p>Vous touchez un accès fermé : porte, fenêtre, portail, récipient ou écoutille. L''accès est alors verrouillé magiquement pour toute la durée. Ce verrou résiste à toutes les tentatives d''ouverture non magiques. Vous et toutes les créatures que vous désignez à l''incantation pouvez ouvrir et fermer normalement l''objet malgré le verrou. Vous pouvez également décider d''un mot de passe qui déverrouille l''objet pendant 1 minute s''il est prononcé dans un rayon de 1,50 m de celui-ci.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8134, 2415, 52, 2);

-- [2416] Vision dans le noir (niv 2, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2416, 'Vision dans le noir', 2, 4, NULL, 1, 1, 1, 0, 0, 'une carotte séchée', 'contact', '', '', 'action', '8 heures', NULL, NULL, 0, 0, '<p>Pour toute la durée, une créature consentante que vous touchez physiquement acquiert la Vision dans le noir sur 45 m.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8135, 2416, 55, 2),
  (8136, 2416, 56, 2),
  (8137, 2416, 52, 2),
  (8138, 2416, 60, 2);

-- [2417] Vision suprême (niv 6, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2417, 'Vision suprême', 6, 7, NULL, 1, 1, 1, 0, 0, 'poudre de champignon d''une valeur minimale de 25 po, que le sort détruit', 'contact', '', '', 'action', '1 heure', NULL, NULL, 0, 0, '<p>Pour toute la durée, une créature consentante que vous touchez physiquement acquiert la Vision lucide sur 36 m.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8139, 2417, 53, 6),
  (8140, 2417, 54, 6),
  (8141, 2417, 56, 6),
  (8142, 2417, 52, 6),
  (8143, 2417, 58, 6);

-- [2418] Voie végétale (niv 6, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2418, 'Voie végétale', 6, 6, NULL, 1, 1, 0, 0, 0, NULL, '3 m', '', '', 'action', '1 minute', NULL, NULL, 0, 0, '<p>Ce sort crée un lien magique entre une plante inanimée à portée, de taille G ou supérieure, et une autre plante du même plan d''existence, sans contrainte de distance. Vous devez avoir déjà vu ou touché la plante de destination au moins une fois. Pour toute la durée, toutes les créatures peuvent s''avancer dans la plante ciblée et ressortir par la plante de destination en y consacrant 1,50 m de leur déplacement.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8144, 2418, 55, 6);

-- [2419] Vol (niv 3, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2419, 'Vol', 3, 4, NULL, 1, 1, 1, 0, 0, 'une plume', 'contact', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Vous touchez une créature consentante. Pour toute la durée, la cible acquiert une Vitesse de vol de 18 m et bénéficie du vol stationnaire. Lorsque le sort prend fin, la cible tombe si elle est toujours dans les airs, à moins de pouvoir arrêter sa chute.</p>
<p>Emplacement de niveau supérieur. Vous pouvez cibler une créature supplémentaire par niveau d''emplacement au-delà du 3e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8145, 2419, 56, 3),
  (8146, 2419, 52, 3),
  (8147, 2419, 58, 3);

-- [2420] Zone de vérité (niv 2, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2420, 'Zone de vérité', 2, 3, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', '10 minutes', NULL, NULL, 0, 0, '<p>Vous créez une zone magique qui interdit les mensonges dans une Sphère de 4,50 m de rayon centrée sur un point à portée. Jusqu''à la fin du sort, quand une créature entre dans la zone pour la première fois d''un tour ou y commence son tour, elle effectue un jet de sauvegarde de Charisme. En cas d''échec, elle ne peut mentir sciemment tant qu''elle est dans la zone. Vous savez si une telle créature a raté ou réussi son jet de sauvegarde.</p>
<p>Une créature affectée a conscience du sort et peut éluder les questions auxquelles elle répondrait normalement par un mensonge. Elle peut se montrer évasive, mais ce qu''elle dit doit rester vrai dans son esprit.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (8148, 2420, 53, 2),
  (8149, 2420, 54, 2),
  (8150, 2420, 59, 2);

COMMIT;
-- FIN IMPORT SRD 5.2.1 (DD2024) — 94 sorts, total dd_sorts=2421, dd_sortclasse=8151
