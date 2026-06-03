-- =====================================================================
-- Import sorts SRD 5.2.1 (DD2024) — LOT 4 : C manqués + D + E/É + F (64 sorts)
-- dd_sorts so_id 2174..2237 | dd_sortclasse sc_id dès 7497
-- res_id=93 | ruleset_var_id=2 | camp_id NULL
-- Réexécution : DELETE FROM dd_sortclasse WHERE sc_so_id BETWEEN 2174 AND 2237;
--              DELETE FROM dd_sorts WHERE so_id BETWEEN 2174 AND 2237;
-- =====================================================================
SET NAMES utf8mb4;
START TRANSACTION;

-- [2174] Cage de force (niv 7, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2174, 'Cage de force', 7, 1, NULL, 1, 1, 1, 0, 0, 'poudre de rubis d''une valeur minimale de 1 500 po, que le sort détruit', '30 m', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Une prison cubique, immobile et Invisible de force magique se matérialise autour d''une zone que vous choisissez à portée. Il peut s''agir d''une cage ou d''une cellule aux parois pleines, à votre convenance.</p>
<p>Une prison qui se présente comme une cage peut atteindre 6 m par côté. Elle se compose de barreaux de 1,25 cm de diamètre, espacés d''autant. Une prison aux parois pleines peut atteindre 3 m par côté. Ses parois empêchent toute matière d''y pénétrer et bloquent tout sort qui tenterait de les franchir dans un sens ou dans l''autre.</p>
<p>À l''incantation du sort, toute créature entièrement comprise dans la zone de la prison s''y retrouve bloquée. Les créatures partiellement comprises dans la zone, ou trop grandes pour y loger, sont écartées du centre de la prison jusqu''à se retrouver entièrement en dehors.</p>
<p>Une créature bloquée dans la prison ne peut en sortir par des moyens non magiques. Si un détenu tente de recourir à la téléportation ou au voyage interplanaire pour s''évader, il effectue d''abord un jet de sauvegarde de Charisme. En cas de réussite, la créature peut se servir de cette magie pour quitter la prison. En cas d''échec, elle ne sort pas de la zone et gaspille l''utilisation du sort ou de l''effet correspondant. La cage de force s''étend en outre dans le Plan Éthéré, ce qui empêche le voyage éthéré.</p>
<p>Dissipation de la magie ne permet pas de dissiper ce sort.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7497, 2174, 53, 7),
  (7498, 2174, 52, 7),
  (7499, 2174, 58, 7);

-- [2175] Caresse du vampire (niv 3, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2175, 'Caresse du vampire', 3, 2, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Le contact de votre main nimbée d''ombres siphonne l''énergie vitale d''autrui pour refermer vos plaies. Effectuez une attaque de sort au corps à corps contre une créature à portée d''allonge. Si l''attaque touche, la cible subit 3d6 dégâts nécrotiques et vous récupérez autant de points de vie que la moitié des dégâts nécrotiques infligés.</p>
<p>Jusqu''à la fin du sort, vous pouvez répéter l''attaque à chacun de vos tours, au prix de l''action Magie, en ciblant la même créature ou une autre.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d6 par niveau d''emplacement au-delà du 3e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7500, 2175, 56, 3),
  (7501, 2175, 52, 3),
  (7502, 2175, 58, 3);

-- [2176] Danse irrésistible (niv 6, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2176, 'Danse irrésistible', 6, 3, NULL, 1, 0, 0, 0, 0, NULL, '9 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Choisissez une créature que vous voyez à portée ; elle effectue un jet de sauvegarde de Sagesse. En cas de réussite, la cible entame une danse grotesque sur place en y consacrant tout son déplacement jusqu''à la fin de son tour suivant.</p>
<p>En cas d''échec, la cible subit l''état Charmé pour toute la durée. Ainsi Charmée, la cible danse grotesquement en y consacrant tout son déplacement sans quitter son espace, et elle a le Désavantage aux jets de sauvegarde de Dextérité et aux jets d''attaque, tandis que les autres créatures ont l''Avantage aux jets d''attaque contre elle. À chacun de ses tours, la cible peut consacrer une action à tenter de retrouver ses esprits et réitérer le JS ; elle met fin au sort sur elle-même en cas de réussite.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7503, 2176, 53, 6),
  (7504, 2176, 52, 6);

-- [2177] Déblocage (niv 2, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2177, 'Déblocage', 2, 4, NULL, 1, 0, 0, 0, 0, NULL, '18 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Choisissez un objet que vous voyez à portée. Il peut s''agir d''une porte, d''une boîte, d''un coffre, de menottes, d''un cadenas ou autre objet muni d''un système de fermeture, magique ou non.</p>
<p>Une cible verrouillée par une serrure ordinaire, barrée ou coincée est aussitôt déverrouillée, débloquée ou décoincée. Si l''objet présente plusieurs verrous, un seul d''entre eux est débloqué.</p>
<p>Si la cible est fermée par verrou magique, ce sort est réprimé pendant 10 minutes, durant lesquelles vous pouvez ouvrir et fermer l''objet.</p>
<p>À l''incantation du sort, un cognement sonore audible à 90 m émane de la cible.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7505, 2177, 53, 2),
  (7506, 2177, 56, 2),
  (7507, 2177, 52, 2);

-- [2178] Décharge occulte (niv 0, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2178, 'Décharge occulte', 0, 1, NULL, 1, 1, 0, 0, 0, NULL, '36 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous projetez un rayon d''énergie crépitante. Effectuez une attaque de sort à distance contre une créature ou un objet à portée. Si l''attaque touche, la cible subit 1d10 dégâts de force.</p>
<p>Amélioration de sort mineur. Le sort produit deux rayons au niveau 5, trois au niveau 11 et quatre au niveau 17. Vous pouvez viser la même cible avec ces rayons ou les répartir entre plusieurs cibles. Effectuez un jet d''attaque séparé pour chaque rayon.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7508, 2178, 58, 0);

-- [2179] Dédale (niv 8, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2179, 'Dédale', 8, 6, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Vous bannissez une créature que vous voyez à portée dans un demi-plan labyrinthique. La cible y reste pour toute la durée, à moins qu''elle n''en trouve la sortie.</p>
<p>La cible peut entreprendre l''action Étude pour tenter de s''évader. Ce faisant, elle effectue un test d''Intelligence (Investigation) DD 20. En cas de réussite, elle s''évade et le sort prend fin.</p>
<p>Lorsque le sort prend fin, la cible réapparaît dans l''espace qu''elle avait quitté ou, si celui-ci n''est plus libre, dans l''espace inoccupé le plus proche.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7509, 2179, 52, 8);

-- [2180] Déguisement (niv 1, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2180, 'Déguisement', 1, 9, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action', '1 heure', NULL, NULL, 0, 0, '<p>Vous vous donnez un aspect différent jusqu''à la fin du sort ; vous pouvez ainsi altérer l''apparence de vos vêtements, de votre armure, de vos armes et autres biens portés. Vous pouvez paraître jusqu''à 30 cm plus grand ou plus petit, sembler plus léger ou plus lourd. Vous devez adopter une forme présentant la même répartition de membres que vous.</p>
<p>Les changements apportés par le sort ne résistent pas à un examen physique. Si le sort ajoute un chapeau à votre accoutrement, ce couvre-chef n''est pas tangible.</p>
<p>Pour comprendre que vous êtes déguisé, une créature doit consacrer l''action Étude à vous examiner et réussir un test d''Intelligence (Investigation) assorti de votre DD de sauvegarde des sorts.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7510, 2180, 53, 1),
  (7511, 2180, 56, 1),
  (7512, 2180, 52, 1);

-- [2181] Délivrance des malédictions (niv 3, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2181, 'Délivrance des malédictions', 3, 5, NULL, 1, 1, 0, 0, 0, NULL, 'contact', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>À votre contact, toutes les malédictions qui affectent une créature ou un objet prennent fin. Si la cible est un objet magique maudit, la malédiction reste en place, mais le sort rompt l''Harmonisation du propriétaire avec l''objet, si bien que celui-ci peut s''en défaire ou s''en débarrasser.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7513, 2181, 54, 3),
  (7514, 2181, 52, 3),
  (7515, 2181, 58, 3),
  (7516, 2181, 59, 3);

-- [2182] Demi-plan (niv 8, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2182, 'Demi-plan', 8, 6, NULL, 0, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', '1 heure', NULL, NULL, 0, 0, '<p>Vous créez une porte ombreuse de taille M sur une surface solide plate que vous voyez à portée. Cette porte peut s''ouvrir et se fermer, et ouvre sur un demi-plan : une salle vide dont chaque dimension est de 9 m, faite de bois ou de pierre (à votre convenance).</p>
<p>Quand le sort prend fin, la porte disparaît et tous les objets encore dans le demi-plan y restent. Toutes les créatures qui s''y trouvent encore y restent, sauf celles qui décident d''être renvoyées à la disparition de la porte et qui se retrouvent dans les espaces inoccupés les plus proches de l''espace de la porte, avec l''état À terre.</p>
<p>Chaque fois que vous lancez ce sort, vous pouvez créer un nouveau demi-plan ou décider que la porte ombreuse ouvre sur un demi-plan que vous aviez engendré par une précédente incantation du même sort. Par ailleurs, si vous connaissez la nature et le contenu d''un demi-plan créé par ce sort, mais lancé par une autre créature, vous pouvez décider que votre porte ombreuse donne sur ce demi-plan.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7517, 2182, 56, 8),
  (7518, 2182, 52, 8),
  (7519, 2182, 58, 8);

-- [2183] Désintégration (niv 6, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2183, 'Désintégration', 6, 4, NULL, 1, 1, 1, 0, 0, 'une magnétite et de la poussière', '18 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous projetez un rayon vert vers une cible que vous voyez à portée. La cible peut être une créature, un objet non magique ou une création de force magique, telle que la paroi formée par mur de force.</p>
<p>Une créature ciblée par ce sort effectue un jet de sauvegarde de Dextérité. En cas d''échec, elle subit 10d6 + 40 dégâts de force. Si ces dégâts la font tomber à 0 point de vie, elle est désintégrée en poussière grise avec tout objet non magique qu''elle porte. La cible ne peut être ramenée à la vie que par résurrection suprême ou souhait.</p>
<p>Ce sort désintègre automatiquement un objet de taille G ou inférieure non magique, de même qu''une création de force magique dans la limite de cette taille. Dans le cas d''une taille TG ou supérieure, la désintégration ne concerne qu''une portion équivalente à un Cube de 3 m.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 3d6 par niveau d''emplacement au-delà du 6e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7520, 2183, 56, 6),
  (7521, 2183, 52, 6);

-- [2184] Détection de l'invisibilité (niv 2, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2184, 'Détection de l''invisibilité', 2, 7, NULL, 1, 1, 1, 0, 0, 'une pincée de talc', 'personnelle', '', '', 'action', '1 heure', NULL, NULL, 0, 0, '<p>Pour toute la durée, vous voyez les créatures et objets dotés de l''état Invisible comme s''ils étaient visibles, et vous percevez le Plan Éthéré. Les créatures et objets qui s''y trouvent ont un aspect spectral.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7522, 2184, 53, 2),
  (7523, 2184, 56, 2),
  (7524, 2184, 52, 2);

-- [2185] Détection de la magie (niv 1, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2185, 'Détection de la magie', 1, 7, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action ou rituel', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 1, '<p>Pour toute la durée, vous percevez la présence des effets magiques dans un rayon de 9 m. Si vous percevez de tels effets, vous pouvez entreprendre l''action Magie pour voir une faible aura autour de chaque créature et objet visibles et porteurs de magie de la zone, et vous apprenez l''école de magie correspondante dans le cas d''un effet produit par un sort.</p>
<p>Le sort est bloqué par 30 cm de pierre, de terre ou de bois, par 2,5 cm de métal (une simple feuille dans le cas du plomb).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7525, 2185, 53, 1),
  (7526, 2185, 54, 1),
  (7527, 2185, 55, 1),
  (7528, 2185, 56, 1),
  (7529, 2185, 52, 1),
  (7530, 2185, 58, 1),
  (7531, 2185, 59, 1),
  (7532, 2185, 60, 1);

-- [2186] Détection des pensées (niv 2, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2186, 'Détection des pensées', 2, 7, NULL, 1, 1, 1, 0, 0, '1 pièce de cuivre', 'personnelle', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous activez l''un des effets ci-après. À vos tours suivants jusqu''à la fin du sort, vous pouvez activer l''un des deux effets au prix de l''action Magie.</p>
<p>Perception des pensées. Vous percevez la présence de pensées dans un rayon de 9 m, si elles émanent de créatures maîtrisant une langue ou télépathes. Le sort est bloqué par 30 cm de pierre, de terre ou de bois, par 2,5 cm de métal.</p>
<p>Lecture des pensées. Dans un rayon de 9 m, ciblez une créature que vous voyez ou une créature détectée avec l''option Perception des pensées. Vous savez ce qui occupe son esprit à l''instant présent. Au prix de l''action Magie à votre tour suivant, vous pouvez tenter de sonder davantage son esprit : la cible effectue un JS Sagesse. En cas d''échec, vous saisissez comment elle raisonne, son état émotionnel et ce qui la tracasse. En cas de réussite, le sort prend fin. Dans les deux cas, la cible sait que vous sondez son esprit.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7533, 2186, 53, 2),
  (7534, 2186, 56, 2),
  (7535, 2186, 52, 2);

-- [2187] Détection des pièges (niv 2, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2187, 'Détection des pièges', 2, 7, NULL, 1, 1, 0, 0, 0, NULL, '36 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous percevez la présence de tout piège à la fois à portée et dans votre champ de vision. Un piège, dans le cadre de ce sort, correspond à tout objet ou mécanisme conçu pour infliger des dégâts ou présenter un danger.</p>
<p>Le sort se contente de révéler la présence d''un piège, pas son emplacement. Vous avez une notion de la nature du danger qu''il présente.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7536, 2187, 54, 2),
  (7537, 2187, 55, 2),
  (7538, 2187, 60, 2);

-- [2188] Détection du mal et du bien (niv 1, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2188, 'Détection du mal et du bien', 1, 7, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Pour toute la durée, vous percevez la position de toutes les créatures suivantes dans un rayon de 9 m : Aberrations, Célestes, Élémentaires, Fées, Fiélons et Morts-vivants. Vous percevez également si le sort sanctification est actif dans la zone, et où.</p>
<p>Le sort est bloqué par 30 cm de pierre, de terre ou de bois, par 2,5 cm de métal.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7539, 2188, 54, 1),
  (7540, 2188, 59, 1);

-- [2189] Détection du poison et des maladies (niv 1, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2189, 'Détection du poison et des maladies', 1, 7, NULL, 1, 1, 1, 0, 0, 'une feuille d''if', 'personnelle', '', '', 'action ou rituel', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 1, '<p>Pour toute la durée, vous percevez la position de tous les poisons, créatures venimeuses et vénéneuses, et maladies magiques dans un rayon de 9 m. Vous percevez dans chaque cas de quel genre de poison, créature ou maladie il s''agit.</p>
<p>Le sort est bloqué par 30 cm de pierre, de terre ou de bois, par 2,5 cm de métal.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7541, 2189, 54, 1),
  (7542, 2189, 55, 1),
  (7543, 2189, 59, 1),
  (7544, 2189, 60, 1);

-- [2190] Discours captivant (niv 2, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2190, 'Discours captivant', 2, 3, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous composez une formulation verbale fascinante qui contraint les créatures de votre choix, parmi celles que vous voyez à portée, à effectuer un jet de sauvegarde de Sagesse. Toute créature que vous ou vos compagnons êtes en train d''affronter réussit automatiquement ce JS. En cas d''échec, la cible subit un malus de –10 aux tests de Sagesse (Perception) et en Perception passive jusqu''à la fin du sort.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7545, 2190, 53, 2),
  (7546, 2190, 58, 2);

-- [2191] Disque flottant (niv 1, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2191, 'Disque flottant', 1, 6, NULL, 1, 1, 1, 0, 0, 'une goutte de mercure', '9 m', '', '', 'action ou rituel', '1 heure', NULL, NULL, 0, 1, '<p>Ce sort crée un plan horizontal et circulaire de force, de 90 cm de diamètre pour 2,5 cm d''épaisseur, qui flotte 90 cm au-dessus du sol en un espace inoccupé que vous voyez et choisissez à portée. Le disque persiste pour toute la durée et supporte 250 kg. Si on y pose un excédent de poids, le sort prend fin et tout ce qui se trouvait sur le disque tombe au sol.</p>
<p>Le disque est immobile tant que vous restez dans un rayon de 6 m de lui. Si vous vous en écartez de plus de 6 m, le disque vous suit pour rester dans ce rayon. Il peut traverser un Terrain difficile, monter ou descendre des marches, une pente ou équivalent, mais ne peut pas franchir une dénivellation abrupte de 3 m ou plus.</p>
<p>Si vous vous éloignez de plus de 30 m du disque, le sort prend fin.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7547, 2191, 52, 1);

-- [2192] Dissimulation suprême (niv 7, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2192, 'Dissimulation suprême', 7, 4, NULL, 1, 1, 1, 0, 0, 'poudre de gemme d''une valeur minimale de 5 000 po, que le sort détruit', 'contact', '', '', 'action', 'jusqu''à dissipation', NULL, NULL, 0, 0, '<p>D''un contact, vous isolez magiquement un objet ou une créature consentante. Pour toute la durée, la cible a l''état Invisible et les sorts de Divination ne peuvent pas la cibler, aucune magie ne peut la détecter ni l''observer à distance.</p>
<p>Si la cible est une créature, elle sombre dans un état d''animation suspendue ; elle subit l''état Inconscient, ne vieillit pas et se passe de nourriture, d''eau et d''air.</p>
<p>Vous pouvez fixer une condition qui mettra un terme prématuré au sort. Vous êtes libre de choisir n''importe quelle condition, mais elle doit intervenir ou être visible dans un rayon de 1,5 km de la cible. Le sort prend également fin si la cible subit des dégâts.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7548, 2192, 52, 7);

-- [2193] Dissipation de la magie (niv 3, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2193, 'Dissipation de la magie', 3, 5, NULL, 1, 1, 0, 0, 0, NULL, '36 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Choisissez une créature, un objet ou un effet magique à portée. Tout sort du 3e niveau ou inférieur affectant la cible prend fin. Pour chaque sort du 4e niveau ou supérieur affectant la cible, effectuez un test de caractéristique d''incantation (DD 10 plus le niveau du sort concerné). En cas de réussite, le sort prend fin.</p>
<p>Emplacement de niveau supérieur. Vous mettez automatiquement un terme aux sorts qui affectent la cible et sont d''un niveau qui ne dépasse pas celui de votre emplacement de sort.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7549, 2193, 53, 3),
  (7550, 2193, 54, 3),
  (7551, 2193, 55, 3),
  (7552, 2193, 56, 3),
  (7553, 2193, 52, 3),
  (7554, 2193, 58, 3),
  (7555, 2193, 59, 3),
  (7556, 2193, 60, 3);

-- [2194] Dissipation du mal et du bien (niv 5, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2194, 'Dissipation du mal et du bien', 5, 5, NULL, 1, 1, 1, 0, 0, 'poudre d''argent et de fer', 'personnelle', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Pour toute la durée, Célestes, Élémentaires, Fées, Fiélons et Morts-vivants ont le Désavantage aux jets d''attaque contre vous. Vous pouvez mettre un terme prématuré au sort en recourant à l''une des fonctions spéciales suivantes.</p>
<p>Annulation d''enchantement. Au prix de l''action Magie, vous touchez une créature possédée ou subissant l''état Charmé ou Effrayé par au moins une créature d''un type précité. La cible n''est plus possédée, Charmée ou Effrayée par cette autre créature.</p>
<p>Renvoi. Au prix de l''action Magie, vous ciblez une créature que vous voyez dans un rayon de 1,50 m, d''un type précité. La cible doit réussir un jet de sauvegarde de Charisme sous peine d''être renvoyée dans son plan d''origine. S''ils ne sont pas sur leur plan d''origine, les Morts-vivants sont envoyés en Gisombre et les Fées en Féerie.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7557, 2194, 54, 5),
  (7558, 2194, 59, 5);

-- [2195] Divination (niv 4, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2195, 'Divination', 4, 7, NULL, 1, 1, 1, 0, 0, 'encens d''une valeur minimale de 25 po, que le sort détruit', 'personnelle', '', '', 'action ou rituel', 'instantanée', NULL, NULL, 0, 1, '<p>Ce sort vous met en contact avec un dieu ou ses serviteurs. Vous posez une question au sujet d''un objectif précis, d''un événement ou d''une activité censés intervenir dans les 7 jours. Le MJ vous répond par la vérité, qui peut s''énoncer par une courte phrase ou un vers abscons. Le sort ne tient pas compte des conjonctures qui pourraient peser dans la balance, comme l''incantation de nouveaux sorts.</p>
<p>Si vous lancez le sort plus d''une fois avant de terminer votre prochain Repos long, vous courez dès la deuxième incantation 25 % de risques cumulatifs qu''il ne vous livre aucune réponse.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7559, 2195, 54, 4),
  (7560, 2195, 55, 4),
  (7561, 2195, 52, 4);

-- [2196] Doigt de mort (niv 7, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2196, 'Doigt de mort', 7, 2, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous libérez des énergies négatives vers une créature que vous voyez à portée. La cible effectue un jet de sauvegarde de Constitution et subit 7d8 + 30 dégâts nécrotiques en cas d''échec, la moitié en cas de réussite.</p>
<p>Un Humanoïde tué par ce sort se relève au début de votre tour suivant comme zombi obéissant à vos instructions verbales.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7562, 2196, 56, 7),
  (7563, 2196, 52, 7),
  (7564, 2196, 58, 7);

-- [2197] Domination de bête (niv 4, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2197, 'Domination de bête', 4, 3, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Une Bête que vous voyez à portée doit réussir un jet de sauvegarde de Sagesse sous peine de subir l''état Charmé pour toute la durée. La cible a l''Avantage au JS si vous ou vos alliés êtes en train de l''affronter. Chaque fois que la cible subit des dégâts, elle réitère le JS et met un terme au sort sur elle-même en cas de réussite.</p>
<p>Un lien télépathique persiste entre vous et la cible Charmée tant que vous êtes tous deux sur un même plan d''existence. À votre tour, vous pouvez profiter de ce lien pour donner des ordres à la cible (pas d''action requise). La cible fait de son mieux pour vous obéir. Vous pouvez aussi lui faire jouer une Réaction, au prix toutefois de votre propre Réaction.</p>
<p>Emplacement de niveau supérieur. Votre Concentration peut persister plus longtemps avec un emplacement du 5e niveau (jusqu''à 10 minutes), du 6e (jusqu''à 1 heure), ou du 7e et supérieur (jusqu''à 8 heures).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7565, 2197, 55, 4),
  (7566, 2197, 56, 4),
  (7567, 2197, 60, 4);

-- [2198] Domination de monstre (niv 8, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2198, 'Domination de monstre', 8, 3, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Une créature que vous voyez à portée doit réussir un jet de sauvegarde de Sagesse sous peine de subir l''état Charmé pour toute la durée. La cible a l''Avantage au JS si vous ou vos alliés êtes en train de l''affronter. Chaque fois que la cible subit des dégâts, elle réitère le JS et met un terme au sort sur elle-même en cas de réussite.</p>
<p>Un lien télépathique persiste entre vous et la cible Charmée tant que vous êtes tous deux sur un même plan d''existence. À votre tour, vous pouvez profiter de ce lien pour donner des ordres à la cible (pas d''action requise). La cible fait de son mieux pour vous obéir. Vous pouvez aussi lui faire jouer une Réaction, au prix toutefois de votre propre Réaction.</p>
<p>Emplacement de niveau supérieur. Votre Concentration peut persister plus longtemps avec un emplacement du 9e niveau (jusqu''à 8 heures).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7568, 2198, 53, 8),
  (7569, 2198, 56, 8),
  (7570, 2198, 52, 8),
  (7571, 2198, 58, 8);

-- [2199] Domination de personne (niv 5, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2199, 'Domination de personne', 5, 3, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Un Humanoïde que vous voyez à portée doit réussir un jet de sauvegarde de Sagesse sous peine de subir l''état Charmé pour toute la durée. La cible a l''Avantage au JS si vous ou vos alliés êtes en train de l''affronter. Chaque fois que la cible subit des dégâts, elle réitère le JS et met un terme au sort sur elle-même en cas de réussite.</p>
<p>Un lien télépathique persiste entre vous et la cible Charmée tant que vous êtes tous deux sur un même plan d''existence. À votre tour, vous pouvez profiter de ce lien pour donner des ordres à la cible (pas d''action requise). La cible fait de son mieux pour vous obéir. Vous pouvez aussi lui faire jouer une Réaction, au prix toutefois de votre propre Réaction.</p>
<p>Emplacement de niveau supérieur. Votre Concentration peut persister plus longtemps avec un emplacement du 6e niveau (jusqu''à 10 minutes), du 7e (jusqu''à 1 heure), ou du 8e et supérieur (jusqu''à 8 heures).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7572, 2199, 53, 5),
  (7573, 2199, 56, 5),
  (7574, 2199, 52, 5);

-- [2200] Don des langues (niv 3, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2200, 'Don des langues', 3, 7, NULL, 1, 0, 1, 0, 0, 'une ziggourat miniature', 'contact', '', '', 'action', '1 heure', NULL, NULL, 0, 0, '<p>Ce sort octroie à la créature que vous touchez la faculté de comprendre toute langue parlée qu''elle entend et tout langage des signes qu''elle voit. De plus, lorsque la cible communique par signes ou par la voix, toute créature qui connaît au moins une langue comprend ce que la cible exprime à condition d''entendre ce qu''elle dit ou de voir sa gestuelle.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7575, 2200, 53, 3),
  (7576, 2200, 54, 3),
  (7577, 2200, 56, 3),
  (7578, 2200, 52, 3),
  (7579, 2200, 58, 3);

-- [2201] Double illusoire (niv 5, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2201, 'Double illusoire', 5, 9, NULL, 0, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Vous recevez l''état Invisible et, dans le même temps, votre double illusoire se présente à l''endroit où vous vous tenez. Ce double persiste pour toute la durée, mais l''invisibilité prend fin si vous effectuez un jet d''attaque, infligez des dégâts ou lancez un sort.</p>
<p>Au prix de l''action Magie, vous pouvez déplacer votre double à concurrence du double de votre Vitesse et le faire bouger, parler et se comporter à votre guise. Il est intangible et invulnérable.</p>
<p>Vous voyez et entendez comme si vous vous trouviez au même endroit que lui.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7580, 2201, 53, 5),
  (7581, 2201, 52, 5),
  (7582, 2201, 58, 5);

-- [2202] Doux repos (niv 2, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2202, 'Doux repos', 2, 2, NULL, 1, 1, 1, 0, 0, '2 pièces de cuivre, que le sort détruit', 'contact', '', '', 'action ou rituel', '10 jours', NULL, NULL, 0, 1, '<p>Vous touchez physiquement un cadavre ou autre dépouille. Pour toute la durée, la cible est protégée contre la putréfaction et rien ne peut en faire un Mort-vivant.</p>
<p>Ce sort prolonge également le délai au-delà duquel la cible ne pourra plus être ramenée d''entre les morts, les jours passés sous l''influence de ce sort n''étant pas décomptés dans le cadre de sorts tels que rappel à la vie.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7583, 2202, 54, 2),
  (7584, 2202, 52, 2),
  (7585, 2202, 59, 2);

-- [2203] Druidisme (niv 0, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2203, 'Druidisme', 0, 4, NULL, 1, 1, 0, 0, 0, NULL, '9 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous murmurez aux esprits de la nature pour créer l''un des effets suivants à portée :</p>
<p>Capteur climatique. Vous produisez un effet sensoriel inoffensif de taille TP qui prédit le temps qu''il fera où vous vous trouvez dans les 24 prochaines heures. L''effet persiste pendant 1 round.</p>
<p>Floraison. Vous faites instantanément s''épanouir une fleur, s''ouvrir une cosse de graines ou fleurir un bourgeon.</p>
<p>Effet sensoriel. Vous créez un effet sensoriel inoffensif : feuilles qui tombent, petites fées spectrales qui dansent, douce brise, bruit animal, vague odeur de sconse, etc. L''effet doit tenir dans un Cube de 1,50 m.</p>
<p>Jeu avec le feu. Vous allumez ou éteignez une bougie, une torche ou un petit feu de camp.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7586, 2203, 55, 0);

-- [2204] Éclair (niv 3, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2204, 'Éclair', 3, 1, NULL, 1, 1, 1, 0, 0, 'une touffe de fourrure et une tige de cristal', 'personnelle', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Un éclair foudroyant jaillit de vous sous la forme d''une Ligne de 30 m de long et 1,50 m de large, dans la direction de votre choix. Chaque créature prise dans la Ligne effectue un jet de sauvegarde de Dextérité et subit 8d6 dégâts de foudre en cas d''échec, la moitié en cas de réussite.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d6 par niveau d''emplacement au-delà du 3e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7587, 2204, 56, 3),
  (7588, 2204, 52, 3);

-- [2205] Éclat du soleil (niv 8, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2205, 'Éclat du soleil', 8, 1, NULL, 1, 1, 1, 0, 0, 'un morceau d''héliolite', '45 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>La lumière du soleil brille soudain dans une Sphère de 18 m de rayon, centrée sur un point que vous choisissez à portée. Chaque créature prise dans la Sphère effectue un jet de sauvegarde de Constitution. En cas d''échec, elle subit 12d6 dégâts radiants, ainsi que l''état Aveuglé pendant 1 minute. En cas de réussite, elle subit uniquement la moitié de ces dégâts.</p>
<p>Une créature Aveuglée par ce sort réitère le jet de sauvegarde de Constitution à la fin de chacun de ses tours et met un terme à l''effet sur elle-même en cas de réussite.</p>
<p>Le sort dissipe dans la zone toutes les Ténèbres qui résultent d''un sort.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7589, 2205, 54, 8),
  (7590, 2205, 55, 8),
  (7591, 2205, 56, 8),
  (7592, 2205, 52, 8);

-- [2206] Élémentalisme (niv 0, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2206, 'Élémentalisme', 0, 4, NULL, 1, 1, 0, 0, 0, NULL, '9 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous exercez votre contrôle sur les éléments, ce qui produit l''un des effets suivants à portée.</p>
<p>Appel d''air. Vous produisez une brise suffisante pour faire ondoyer les vêtements, soulever la poussière, bruisser les feuilles et fermer les portes et volets ouverts compris dans un Cube de 1,50 m.</p>
<p>Appel d''eau. Vous produisez des embruns frais qui humectent les créatures et objets dans un Cube de 1,50 m. Ou bien, vous créez 20 cl d''eau claire dans un récipient ouvert ; cette eau s''évapore au bout de 1 minute.</p>
<p>Appel de feu. Vous produisez un nuage de fumée parfumée, colorée et ardente, mais inoffensive, dans un Cube de 1,50 m. Les flammèches embrasent les bougies, torches et lampes de la zone.</p>
<p>Appel de terre. Vous produisez un linceul de poussière ou de sable qui tapisse les surfaces d''une zone de 1,50 m de côté, ou vous faites apparaître sur la terre ou le sable un mot unique qui reprend votre écriture.</p>
<p>Façonnage élémentaire. De la terre, du sable, des flammes, de la fumée, de la brume ou de l''eau qui tiennent dans un Cube de 30 cm adoptent grossièrement une forme pendant 1 heure.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7593, 2206, 55, 0),
  (7594, 2206, 56, 0),
  (7595, 2206, 52, 0);

-- [2207] Embruns prismatiques (niv 7, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2207, 'Embruns prismatiques', 7, 1, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Huit rayons de lumière jaillissent de vous dans un Cône de 18 m. Chaque créature prise dans le Cône effectue un jet de sauvegarde de Dextérité. Pour chaque cible, lancez 1d8 pour déterminer le rayon de couleur qui l''affecte.</p>
<p>1d8 — Rayon<br>
1 — Rouge. Échec : 12d6 dégâts de feu. Réussite : 1/2.<br>
2 — Orange. Échec : 12d6 dégâts d''acide. Réussite : 1/2.<br>
3 — Jaune. Échec : 12d6 dégâts de foudre. Réussite : 1/2.<br>
4 — Vert. Échec : 12d6 dégâts de poison. Réussite : 1/2.<br>
5 — Bleu. Échec : 12d6 dégâts de froid. Réussite : 1/2.<br>
6 — Indigo. Échec : état Entravé ; JS Constitution en fin de chaque tour. Trois réussites = fin de l''état. Trois échecs = état Pétrifié jusqu''à libération (restauration suprême).<br>
7 — Violet. Échec : état Aveuglé ; JS Sagesse au début de votre tour suivant. Réussite : fin de l''état. Échec : fin de l''état + téléportation vers un plan aléatoire (MJ).<br>
8 — Spécial. La cible est frappée par deux rayons. Lancez deux fois le dé, en rejouant tout 8.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7596, 2207, 53, 7),
  (7597, 2207, 56, 7),
  (7598, 2207, 52, 7);

-- [2208] Emprisonnement (niv 9, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2208, 'Emprisonnement', 9, 5, NULL, 1, 1, 1, 0, 0, 'une statuette à l''effigie de la cible d''une valeur minimale de 5 000 po', '9 m', '', '', '1 minute', 'jusqu''à dissipation', NULL, NULL, 0, 0, '<p>Vous créez des entraves magiques pour retenir une créature que vous voyez à portée. La cible effectue un jet de sauvegarde de Sagesse. En cas de réussite, la cible n''est pas affectée et elle est immunisée contre ce sort pendant 24 heures. En cas d''échec, la cible est emprisonnée. Tant qu''elle est emprisonnée, la cible se passe de respirer, de s''alimenter et de s''hydrater, ne vieillit pas, et les sorts de Divination ne permettent pas de la localiser ni de la percevoir.</p>
<p>Jusqu''à la fin du sort, la cible est aussi affectée par l''un des effets suivants (choisissez) :</p>
<p>Chaînes. Des chaînes fermement ancrées au sol retiennent la cible. La cible subit l''état Entravé et rien ne peut la déplacer.</p>
<p>Détention miniature. La cible est réduite à une taille de 2,5 cm pour se retrouver bloquée dans une gemme indestructible. La lumière traverse cette pierre, mais rien d''autre.</p>
<p>Enterrement. La cible est inhumée dans les entrailles de la terre, à l''intérieur d''un globe creux de force magique juste assez grand pour la contenir.</p>
<p>Léthargie. La cible subit l''état Inconscient, et rien ne peut la réveiller.</p>
<p>Prison isolée. La cible est bloquée dans un demi-plan protégé contre la téléportation et le voyage planaire.</p>
<p>Mettre fin au sort. À l''incantation du sort, spécifiez un déclencheur qui y mettra un terme. Le déclencheur peut être aussi spécifique et sophistiqué que vous le souhaitez, mais le MJ doit convenir qu''il a une grande chance de se présenter dans la décennie à venir. Le sort dissipation de la magie ne peut mettre un terme au sort que s''il est lancé au 9e niveau et s''il cible soit la prison, soit la composante utilisée pour créer celle-ci.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7599, 2208, 52, 9),
  (7600, 2208, 58, 9);

-- [2209] Enchevêtrement (niv 1, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2209, 'Enchevêtrement', 1, 6, NULL, 1, 1, 0, 0, 0, NULL, '27 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Des plantes grimpantes émergent du sol dans un carré de 6 m de côté à portée. Pour toute la durée, cette végétation transforme le sol de la zone en Terrain difficile. Elle disparaît quand le sort prend fin.</p>
<p>Chaque créature autre que vous prise dans la zone à l''incantation du sort doit réussir un jet de sauvegarde de Force pour ne pas subir l''état Entravé jusqu''à la fin du sort. Une créature Entravée peut entreprendre une action pour effectuer un test de Force (Athlétisme) assorti de votre DD de sauvegarde des sorts. En cas de réussite, elle se libère des plantes grimpantes et n''est plus Entravée par cette végétation.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7601, 2209, 55, 1),
  (7602, 2209, 60, 1);

-- [2210] Ennemi subconscient (niv 9, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2210, 'Ennemi subconscient', 9, 9, NULL, 1, 1, 0, 0, 0, NULL, '36 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous tentez de produire une terreur illusoire dans l''esprit d''autrui. Chaque créature que vous choisissez dans une Sphère de 9 m de rayon centrée sur un point à portée effectue un jet de sauvegarde de Sagesse. En cas d''échec, elle subit 10d10 dégâts psychiques, ainsi que l''état Effrayé pour toute la durée. En cas de réussite, elle subit uniquement la moitié de ces dégâts.</p>
<p>Une cible Effrayée effectue un JS Sagesse à la fin de chacun de ses tours. En cas d''échec, elle subit 5d10 dégâts psychiques. En cas de réussite, le sort prend fin pour elle.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7603, 2210, 52, 9),
  (7604, 2210, 58, 9);

-- [2211] Entrave planaire (niv 5, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2211, 'Entrave planaire', 5, 5, NULL, 1, 1, 1, 0, 0, 'un joyau d''une valeur minimale de 1 000 po, que le sort détruit', '18 m', '', '', '1 heure', '24 heures', NULL, NULL, 0, 0, '<p>Vous tentez de soumettre un Céleste, un Élémentaire, une Fée ou un Fiélon à votre service. La créature doit être à portée pendant toute l''incantation. À la fin de l''incantation, la cible doit réussir un jet de sauvegarde de Charisme sous peine d''être liée à votre service pour toute la durée. Si la créature a été convoquée ou créée par un autre sort, la durée de celui-ci augmente pour correspondre à la durée de cette entrave planaire.</p>
<p>Une créature ainsi liée à votre service obéit à vos instructions de son mieux. Vous pouvez lui ordonner de vous accompagner à l''aventure, de garder un site ou de livrer un message. Si la créature est Hostile, elle cherche à détourner vos ordres à ses propres fins. Si la créature mène à bien toutes vos instructions avant la fin du sort, elle se transporte auprès de vous pour faire son rapport si vous êtes sur le même plan d''existence.</p>
<p>Emplacement de niveau supérieur. La durée augmente avec un emplacement du 6e niveau (10 jours), du 7e (30 jours), du 8e (180 jours) et du 9e (366 jours).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7605, 2211, 53, 5),
  (7606, 2211, 54, 5),
  (7607, 2211, 55, 5),
  (7608, 2211, 52, 5),
  (7609, 2211, 58, 5);

-- [2212] Épée arcanique (niv 7, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2212, 'Épée arcanique', 7, 1, NULL, 1, 1, 1, 0, 0, 'une épée miniature d''une valeur minimale de 250 po', '27 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous créez une épée spectrale qui flotte dans les airs à portée. Elle persiste pour toute la durée.</p>
<p>À l''apparition de l''épée, vous effectuez une attaque de sort au corps à corps contre une cible dans un rayon de 1,50 m de l''épée. Si l''attaque touche, la cible subit des dégâts de force égaux à 4d12 + votre modificateur de caractéristique d''incantation.</p>
<p>À chacun de vos tours suivants, vous pouvez par une action Bonus déplacer l''épée d''un maximum de 9 m vers un point que vous voyez et réitérer l''attaque, contre la même cible ou une autre.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7610, 2212, 53, 7),
  (7611, 2212, 52, 7);

-- [2213] Épine mentale (niv 2, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2213, 'Épine mentale', 2, 7, NULL, 0, 1, 0, 0, 0, NULL, '36 m', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Vous enfoncez une pointe d''énergie psionique dans l''esprit d''une créature que vous voyez à portée. La cible effectue un jet de sauvegarde de Sagesse et subit 3d8 dégâts psychiques en cas d''échec, la moitié en cas de réussite. En cas d''échec, vous connaissez également la position de la cible tant que le sort persiste et que vous demeurez tous deux sur le même plan d''existence. Tant que vous savez par ce biais où se trouve la cible, elle ne peut être cachée vis-à-vis de vous et ne tire aucun bénéfice de l''état Invisible vis-à-vis de vous.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d8 par niveau d''emplacement au-delà du 2e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7612, 2213, 56, 2),
  (7613, 2213, 52, 2),
  (7614, 2213, 58, 2);

-- [2214] Éruption ensorcelée (niv 0, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2214, 'Éruption ensorcelée', 0, 1, NULL, 1, 1, 0, 0, 0, NULL, '36 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous projetez des énergies ensorcelées vers une créature ou un objet à portée. Effectuez une attaque de sort à distance contre la cible. Si l''attaque touche, la cible subit 1d8 dégâts du type choisi : acide, feu, foudre, froid, poison, psychiques ou tonnerre.</p>
<p>Si vous obtenez un 8 sur un d8 du sort, vous pouvez en lancer un autre pour l''ajouter aux dégâts. Quand vous lancez ce sort, le maximum de d8 supplémentaires que vous pouvez ainsi ajouter est égal à votre modificateur de caractéristique d''incantation.</p>
<p>Amélioration de sort mineur. Les dégâts augmentent de 1d8 lorsque vous atteignez les niveaux 5 (2d8), 11 (3d8) et 17 (4d8).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7615, 2214, 56, 0);

-- [2215] Esprit impénétrable (niv 8, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2215, 'Esprit impénétrable', 8, 5, NULL, 1, 1, 0, 0, 0, NULL, 'contact', '', '', 'action', '24 heures', NULL, NULL, 0, 0, '<p>Jusqu''à la fin du sort, une créature consentante que vous touchez physiquement bénéficie de l''Immunité contre les dégâts psychiques et l''état Charmé. La cible n''est pas davantage affectée par tout ce qui permet de percevoir les émotions ou l''alignement, de lire les pensées ou de détecter magiquement sa position, et aucun sort (pas même souhait) ne peut affecter l''esprit de la cible, l''observer à distance ou se renseigner sur son compte.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7616, 2215, 53, 8),
  (7617, 2215, 52, 8);

-- [2216] Esprits gardiens (niv 3, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2216, 'Esprits gardiens', 3, 6, NULL, 1, 1, 1, 0, 0, 'un parchemin de prière', 'personnelle', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Des esprits protecteurs volètent autour de vous pour toute la durée, sous forme d''une Émanation de 4,50 m. Si vous êtes bon ou neutre, ces formes spectrales paraissent angéliques ou féeriques. Si vous êtes mauvais, elles paraissent fiélonnes.</p>
<p>À l''incantation du sort, vous pouvez désigner des créatures qui ne seront pas affectées par ces esprits. Toutes les autres créatures voient leur Vitesse réduite de moitié dans la zone ; de plus, lorsque l''Émanation pénètre dans l''espace d''une telle créature ou que celle-ci entre dans l''Émanation pour la première fois d''un tour ou y termine son propre tour, elle effectue un jet de sauvegarde de Sagesse. En cas d''échec, elle subit 3d8 dégâts radiants (si vous êtes bon ou neutre) ou 3d8 dégâts nécrotiques (si vous êtes mauvais). En cas de réussite, la créature subit la moitié de ces dégâts. Une même créature n''effectue en aucun cas ce JS plus d''une fois par tour.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d8 par niveau d''emplacement au-delà du 3e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7618, 2216, 54, 3);

-- [2217] Éveil (niv 5, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2217, 'Éveil', 5, 4, NULL, 1, 1, 1, 0, 0, 'une agate d''une valeur minimale de 1 000 po, que le sort détruit', 'contact', '', '', '8 heures', 'instantanée', NULL, NULL, 0, 0, '<p>Vous consacrez le temps d''incantation à tracer des voies magiques à l''intérieur d''une gemme, puis touchez la cible. Celle-ci doit être une créature de type Bête ou Plante dotée d''une Intelligence inférieure à 4, ou une plante naturelle qui n''est pas une créature. La cible reçoit une Intelligence de 10 et la faculté de parler une langue que vous connaissez. Si la cible est une plante naturelle, elle devient une créature de type Plante et reçoit la capacité de se déplacer sur ses racines et autres appendices, et bénéficie de sens comparables à ceux d''un humain.</p>
<p>La cible éveillée subit l''état Charmé pendant 30 jours, sauf si vous-même ou l''un de vos compagnons lui infligez des dégâts. Quand cet état prend fin, la créature éveillée choisit l''attitude qu''elle adopte à votre égard.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7619, 2217, 53, 5),
  (7620, 2217, 55, 5);

-- [2218] Fabrication (niv 4, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2218, 'Fabrication', 4, 4, NULL, 1, 1, 0, 0, 0, NULL, '36 m', '', '', '10 minutes', 'instantanée', NULL, NULL, 0, 0, '<p>Vous convertissez des matières premières en produits finis. Vous pouvez ainsi fabriquer un pont de bois à partir d''un massif d''arbres, une corde à partir d''un tas de chanvre et des vêtements avec de la laine ou du lin en vrac.</p>
<p>Choisissez des matières premières que vous voyez à portée. Vous pouvez fabriquer un objet de taille G ou inférieure (qui loge dans un Cube de 3 m), à condition de disposer de suffisamment de matières premières. Si vous optez pour du métal, de la pierre ou toute autre substance minérale, l''objet fabriqué ne peut pas dépasser une taille M. La facture des objets est à la mesure de la qualité des matières premières.</p>
<p>Vous ne pouvez pas créer d''objet magique ni de créature avec ce sort. De même, vous ne pouvez pas créer d''objets dont la confection demande un savoir-faire exceptionnel, comme des armes ou des armures, sauf si vous disposez de la maîtrise des outils d''artisan correspondants.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7621, 2218, 52, 4);

-- [2219] Façonnage de la pierre (niv 4, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2219, 'Façonnage de la pierre', 4, 4, NULL, 1, 1, 1, 0, 0, 'de la terre glaise', 'contact', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous touchez physiquement un objet de pierre de taille M ou inférieure ou une section de pierre dont aucune dimension n''excède 1,50 m, pour les modeler à votre guise. Vous pouvez ainsi façonner un gros rocher en arme, en statue ou en caisson, ou pratiquer un passage dans une paroi dont l''épaisseur ne dépasse pas 1,50 m. Vous pourriez aussi modeler une porte de pierre ou en refaçonner l''encadrement pour la condamner. L''objet confectionné peut être doté d''un maximum de deux charnières et d''un loquet, mais les éléments mécaniques plus sophistiqués sont proscrits.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7622, 2219, 54, 4),
  (7623, 2219, 55, 4),
  (7624, 2219, 52, 4);

-- [2220] Faveur divine (niv 1, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2220, 'Faveur divine', 1, 4, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action Bonus', '1 minute', NULL, NULL, 0, 0, '<p>Jusqu''à la fin du sort, vos attaques avec une arme infligent 1d4 dégâts radiants supplémentaires quand elles touchent.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7625, 2220, 59, 1);

-- [2221] Festin des héros (niv 6, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2221, 'Festin des héros', 6, 6, NULL, 1, 1, 1, 0, 0, 'un vase incrusté de gemmes d''une valeur minimale de 1 000 po, que le sort détruit', 'personnelle', '', '', '10 minutes', 'instantanée', NULL, NULL, 0, 0, '<p>Vous invoquez un festin qui se présente sur une surface dans un Cube inoccupé de 3 m, à côté de vous. Il faut 1 heure pour ingérer ce festin, tous les plats disparaissant à l''issue de cet intervalle. Les bénéfices ne se font pas sentir avant la fin de l''heure. Un maximum de douze créatures peuvent participer au banquet.</p>
<p>Une créature qui a figuré parmi les convives reçoit plusieurs bénéfices, qui persistent pendant 24 heures. Elle bénéficie de la Résistance aux dégâts de poison et de l''Immunité contre les états Effrayé et Empoisonné. Son maximum de points de vie augmente en outre de 2d10 et elle reçoit ce même nombre de points de vie.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7626, 2221, 53, 6),
  (7627, 2221, 54, 6),
  (7628, 2221, 55, 6);

-- [2222] Feuille morte (niv 1, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2222, 'Feuille morte', 1, 4, NULL, 1, 0, 1, 0, 0, 'une petite plume ou un peu de duvet', '18 m', '', '', 'Réaction, que vous jouez quand vous ou une créature dans un rayon de 18 m chutez', '1 minute', NULL, NULL, 0, 0, '<p>Choisissez jusqu''à cinq créatures qui chutent à portée. La vitesse de chute de chacune passe à 18 m par round jusqu''à la fin du sort. Si la créature atterrit avant la fin du sort, elle ne subit aucun dégât de chute et le sort prend fin en ce qui la concerne.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7629, 2222, 53, 1),
  (7630, 2222, 56, 1),
  (7631, 2222, 52, 1);

-- [2223] Flamme éternelle (niv 2, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2223, 'Flamme éternelle', 2, 1, NULL, 1, 1, 1, 0, 0, 'poudre de rubis d''une valeur minimale de 50 po, que le sort détruit', 'contact', '', '', 'action', 'jusqu''à dissipation', NULL, NULL, 0, 0, '<p>Une flamme jaillit d''un objet que vous touchez physiquement. L''effet produit une Lumière vive sur un rayon de 6 m et une Lumière faible sur 6 m de plus. La flamme paraît ordinaire, mais elle ne produit aucune chaleur et s''alimente d''elle-même. On peut recouvrir ou cacher la flamme, mais ni l''étouffer ni l''éteindre.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7632, 2223, 54, 2),
  (7633, 2223, 55, 2),
  (7634, 2223, 52, 2);

-- [2224] Flamme sacrée (niv 0, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2224, 'Flamme sacrée', 0, 1, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Une radiance embrasée s''abat sur une créature que vous voyez à portée. La cible doit réussir un jet de sauvegarde de Dextérité sous peine de subir 1d8 dégâts radiants. Les Abris partiels et supérieurs ne confèrent aucun bénéfice dans le cadre de ce jet de sauvegarde.</p>
<p>Amélioration de sort mineur. Les dégâts augmentent de 1d8 lorsque vous atteignez les niveaux 5 (2d8), 11 (3d8) et 17 (4d8).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7635, 2224, 54, 0);

-- [2225] Flammes (niv 0, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2225, 'Flammes', 0, 6, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action Bonus', '10 minutes', NULL, NULL, 0, 0, '<p>Une flamme vacillante prend vie dans votre main et y persiste pour toute la durée. Tant qu''elles sont dans votre main, les flammes ne produisent pas de chaleur et n''embrasent rien, mais projettent une Lumière vive sur un rayon de 6 m et une Lumière faible sur 6 m de plus. Le sort prend fin si vous le relancez.</p>
<p>Jusqu''à la fin du sort, vous pouvez entreprendre l''action Magie pour projeter des flammes sur une créature ou un objet dans un rayon de 18 m. Effectuez une attaque de sort à distance. Si l''attaque touche, la cible subit 1d8 dégâts de feu.</p>
<p>Amélioration de sort mineur. Les dégâts augmentent de 1d8 lorsque vous atteignez les niveaux 5 (2d8), 11 (3d8) et 17 (4d8).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7636, 2225, 55, 0);

-- [2226] Fléau d'insectes (niv 5, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2226, 'Fléau d''insectes', 5, 6, NULL, 1, 1, 1, 0, 0, 'un criquet', '90 m', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Des nuées grouillantes de criquets emplissent une Sphère de 6 m de rayon centrée sur un point que vous choisissez à portée. La Sphère persiste pour toute la durée, et sa zone est à Visibilité réduite et constitue un Terrain difficile.</p>
<p>Chaque créature prise dans la nuée à son apparition effectue un jet de sauvegarde de Constitution, et subit 4d10 dégâts perforants en cas d''échec, la moitié en cas de réussite. Une créature effectue aussi ce JS lorsqu''elle pénètre dans la zone du sort pour la première fois d''un tour ou qu''elle y termine son tour. Une même créature n''effectue en aucun cas ce JS plus d''une fois par tour.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d10 par niveau d''emplacement au-delà du 5e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7637, 2226, 54, 5),
  (7638, 2226, 55, 5),
  (7639, 2226, 56, 5);

-- [2227] Flèche acide (niv 2, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2227, 'Flèche acide', 2, 1, NULL, 1, 1, 1, 0, 0, 'une feuille de rhubarbe en poudre', '27 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Une flèche d''un vert chatoyant fuse vers une cible à portée avant de produire une gerbe d''acide. Effectuez une attaque de sort à distance contre la cible. Si l''attaque touche, la cible subit aussitôt 4d4 dégâts d''acide, puis 2d4 dégâts d''acide à la fin de son tour suivant. Si l''attaque rate, la flèche asperge la cible d''acide en lui infligeant uniquement la moitié des dégâts initiaux.</p>
<p>Emplacement de niveau supérieur. Les dégâts (initiaux et consécutifs) augmentent de 1d4 par niveau d''emplacement au-delà du 2e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7640, 2227, 52, 2);

-- [2228] Flétrissement (niv 4, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2228, 'Flétrissement', 4, 2, NULL, 1, 1, 0, 0, 0, NULL, '9 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Une créature que vous voyez à portée effectue un jet de sauvegarde de Constitution et subit 8d8 dégâts nécrotiques en cas d''échec, la moitié en cas de réussite. Une Plante rate automatiquement ce JS.</p>
<p>Au lieu de cela, vous pouvez cibler une plante non magique qui n''est pas une créature, comme un arbre ou un arbuste. Elle n''effectue pas de JS, mais se flétrit et meurt.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d8 par niveau d''emplacement au-delà du 4e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7641, 2228, 55, 4),
  (7642, 2228, 56, 4),
  (7643, 2228, 52, 4),
  (7644, 2228, 58, 4);

-- [2229] Flou (niv 2, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2229, 'Flou', 2, 9, NULL, 1, 0, 0, 0, 0, NULL, 'personnelle', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Votre corps devient flou. Pour toute la durée, les créatures ont le Désavantage aux jets d''attaque contre vous. Un assaillant qui vous perçoit par la Vision aveugle ou la Vision lucide est immunisé contre cet effet.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7645, 2229, 56, 2),
  (7646, 2229, 52, 2);

-- [2230] Force fantasmagorique (niv 2, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2230, 'Force fantasmagorique', 2, 9, NULL, 1, 1, 1, 0, 0, 'un peu de laine brute', '18 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous tentez de concevoir une illusion dans l''esprit d''une créature que vous voyez à portée. La cible effectue un jet de sauvegarde d''Intelligence. Si elle le rate, vous créez un objet, une créature ou autre forme fantasmatique dont le volume n''excède pas un Cube de 3 m. Seule la cible le perçoit pour toute la durée. L''illusion fait intervenir l''ouïe, la perception de la température et d''autres sens de la créature.</p>
<p>Au prix de l''action Étude, la cible peut examiner la manifestation en effectuant un test d''Intelligence (Investigation) contre le DD de sauvegarde du sort. En cas de réussite, elle perce l''illusion et le sort prend fin.</p>
<p>Tant qu''elle est affectée par le sort, la cible considère ce qu''elle perçoit comme réel. À chacun de vos tours, si la cible se trouve dans un rayon de 1,50 m de l''illusion ou dans sa zone, une telle force fantasmatique peut lui infliger 2d8 dégâts psychiques. Dans son esprit, les dégâts sont du type adapté à l''illusion.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7647, 2230, 53, 2),
  (7648, 2230, 56, 2),
  (7649, 2230, 52, 2);

-- [2231] Forme éthérée (niv 7, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2231, 'Forme éthérée', 7, 6, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action', 'jusqu''à 8 heures', NULL, NULL, 0, 0, '<p>Vous pénétrez dans les régions frontalières du Plan Éthéré, bordure où il chevauche votre plan actuel. Vous demeurez dans la Frontière éthérée pour toute la durée. Durant cet intervalle, vous pouvez vous déplacer dans n''importe quelle direction. Si vous vous déplacez vers le haut ou le bas, toute distance parcourue vous coûte le double. Vous percevez ce qui se passe sur le plan d''où vous venez, mais tout est nuances de gris et votre vision ne porte que sur 18 m.</p>
<p>Tant que vous êtes sur le Plan Éthéré, seuls les créatures, objets et effets de ce plan peuvent vous affecter, et réciproquement. Les créatures qui ne s''y trouvent pas ne vous perçoivent pas et ne peuvent interagir avec vous, à moins de disposer d''une aptitude qui leur en donne la possibilité.</p>
<p>Quand le sort prend fin, vous retournez aussitôt sur votre plan de départ, à l''endroit équivalent à l''espace que vous occupez actuellement dans la Frontière éthérée. Si vous apparaissez dans un espace occupé, vous subissez un transfert dans l''espace inoccupé le plus proche, chaque tranche de 30 cm de ce transfert forcé vous infligeant 2 dégâts de force.</p>
<p>Ce sort prend fin sur-le-champ si vous le lancez tandis que vous êtes sur le Plan Éthéré ou un plan avec lequel il n''a pas de frontière, comme les Plans Extérieurs.</p>
<p>Emplacement de niveau supérieur. Vous pouvez cibler un maximum de trois créatures consentantes (y compris vous) par niveau d''emplacement au-delà du 7e. Ces créatures doivent se trouver dans un rayon de 3 m de vous à l''incantation du sort.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7650, 2231, 53, 7),
  (7651, 2231, 54, 7),
  (7652, 2231, 56, 7),
  (7653, 2231, 52, 7),
  (7654, 2231, 58, 7);

-- [2232] Forme gazeuse (niv 3, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2232, 'Forme gazeuse', 3, 4, NULL, 1, 1, 1, 0, 0, 'un peu de gaze', 'contact', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Pour toute la durée, une créature consentante que vous touchez se métamorphose, ainsi que tout ce qu''elle porte, en nuage de brume. Le sort prend fin si la cible tombe à 0 point de vie ou si elle entreprend l''action Magie pour y mettre fin sur elle-même.</p>
<p>Sous cette forme, la cible n''a qu''un seul mode de déplacement : une Vitesse de vol de 3 m, avec le vol stationnaire. Elle peut pénétrer dans l''espace d''une autre créature et l''occuper. La cible bénéficie de la Résistance aux dégâts contondants, perforants et tranchants, et de l''Immunité contre l''état À terre ; elle a aussi l''Avantage aux jets de sauvegarde de Force, Dextérité et Constitution. Elle peut se glisser dans les ouvertures les plus étroites, mais les liquides sont traités dans son cas comme des surfaces solides.</p>
<p>La cible ne peut ni parler ni manipuler d''objets, et il lui reste impossible de lâcher ou d''utiliser ce qu''elle portait, ou d''interagir avec cet équipement. La cible ne peut ni attaquer ni lancer de sorts.</p>
<p>Emplacement de niveau supérieur. Vous pouvez cibler une créature supplémentaire par niveau d''emplacement au-delà du 3e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7655, 2232, 56, 3),
  (7656, 2232, 52, 3),
  (7657, 2232, 58, 3);

-- [2233] Fou rire (niv 1, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2233, 'Fou rire', 1, 3, NULL, 1, 1, 1, 0, 0, 'une tartelette et une plume', '9 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Une créature de votre choix parmi celles que vous voyez à portée effectue un jet de sauvegarde de Sagesse. En cas d''échec, elle subit les états À terre et Neutralisé pour toute la durée. Tout ce temps, elle est prise d''un fou rire si elle a la faculté de rire et ne peut se relever d''elle-même.</p>
<p>À la fin de chacun de ses tours et chaque fois qu''elle subit des dégâts, la cible réitère le JS Sagesse. Elle a l''Avantage à ce JS s''il est déclenché par des dégâts. En cas de réussite, le sort prend fin.</p>
<p>Emplacement de niveau supérieur. Vous pouvez cibler une créature supplémentaire par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7658, 2233, 53, 1),
  (7659, 2233, 52, 1),
  (7660, 2233, 58, 1);

-- [2234] Foulée brumeuse (niv 2, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2234, 'Foulée brumeuse', 2, 6, NULL, 1, 0, 0, 0, 0, NULL, 'personnelle', '', '', 'action Bonus', 'instantanée', NULL, NULL, 0, 0, '<p>Une brume argentée vous enveloppe brièvement et vous vous téléportez d''un maximum de 9 m vers un espace inoccupé que vous voyez.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7661, 2234, 56, 2),
  (7662, 2234, 52, 2),
  (7663, 2234, 58, 2);

-- [2235] Fracassement (niv 2, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2235, 'Fracassement', 2, 1, NULL, 1, 1, 1, 0, 0, 'un fragment de mica', '18 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Un vacarme éclate en un point que vous choisissez à portée. Chaque créature prise dans une Sphère de 3 m de rayon centrée sur ce point effectue un jet de sauvegarde de Constitution et subit 3d8 dégâts de tonnerre en cas d''échec, la moitié en cas de réussite. Un Artificiel a le Désavantage à ce JS.</p>
<p>Un objet non magique qui n''est porté par personne subit lui aussi les dégâts s''il est dans la zone d''effet du sort.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d8 par niveau d''emplacement au-delà du 2e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7664, 2235, 53, 2),
  (7665, 2235, 56, 2),
  (7666, 2235, 52, 2);

-- [2236] Frappe piégeuse (niv 1, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2236, 'Frappe piégeuse', 1, 6, NULL, 1, 0, 0, 0, 0, NULL, 'personnelle', '', '', 'action Bonus, que vous entreprenez aussitôt après avoir touché une créature avec une arme', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Alors que vous touchez la cible, des plantes grimpantes se matérialisent sur elle et elle effectue un jet de sauvegarde de Force. Si la créature est de taille G ou supérieure, elle a l''Avantage au jet. En cas d''échec, elle subit l''état Entravé jusqu''à la fin du sort. En cas de réussite, les plantes disparaissent en se flétrissant et le sort prend fin.</p>
<p>Tant qu''elle est Entravée, la cible subit 1d6 dégâts perforants au début de chacun de ses tours. La cible ou une créature à portée d''allonge de celle-ci peut entreprendre une action pour effectuer un test de Force (Athlétisme) contre votre DD de sauvegarde des sorts. En cas de réussite, le sort prend fin.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d6 par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7667, 2236, 60, 1);

-- [2237] Fusion dans la pierre (niv 3, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2237, 'Fusion dans la pierre', 3, 4, NULL, 1, 1, 0, 0, 0, NULL, 'contact', '', '', 'action ou rituel', '8 heures', NULL, NULL, 0, 1, '<p>Vous pénétrez d''un pas dans un objet ou une surface de pierre suffisants pour accueillir l''intégralité de votre corps et fusionnez avec tout votre équipement dans cette masse minérale pour toute la durée. Votre présence n''est aucunement visible ni détectable par des moyens non magiques.</p>
<p>Tant que vous fusionnez avec la pierre, vous ne voyez pas ce qui se passe à l''extérieur et tous vos tests de Sagesse (Perception) visant à entendre les bruits extérieurs ont le Désavantage. Vous gardez la notion du temps et pouvez lancer des sorts sur vous-même. Vous pouvez consacrer 1,50 m de votre déplacement à émerger de la pierre à l''endroit par lequel vous l''avez intégrée, ce qui met fin au sort.</p>
<p>Les dommages physiques superficiels subis par la pierre ne vous font aucun mal, mais sa destruction partielle et toute altération de sa forme, si elles sont telles que vous n''y logez plus entièrement, vous éjectent de la pierre en vous infligeant 6d6 dégâts de force. La destruction totale de la pierre vous éjecte aussi, en vous infligeant 50 dégâts de force. Lors de toute éjection, vous vous retrouvez avec l''état À terre dans l''espace inoccupé le plus proche.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7668, 2237, 54, 3),
  (7669, 2237, 55, 3),
  (7670, 2237, 60, 3);

COMMIT;
-- Fin lot 4 — 64 sorts, prochains IDs : dd_sorts=2238, dd_sortclasse=7671
