-- =====================================================================
-- Import sorts SRD 5.2.1 (DD2024) — LOT 5 : G/H/I/L/M/N/O+Œ (89 sorts)
-- dd_sorts so_id 2238..2326 | dd_sortclasse sc_id dès 7671
-- res_id=93 | ruleset_var_id=2 | camp_id NULL
-- Réexécution : DELETE FROM dd_sortclasse WHERE sc_so_id BETWEEN 2238 AND 2326;
--              DELETE FROM dd_sorts WHERE so_id BETWEEN 2238 AND 2326;
-- =====================================================================
SET NAMES utf8mb4;
START TRANSACTION;

-- [2238] Gardien de la foi (niv 4, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2238, 'Gardien de la foi', 4, 6, NULL, 1, 0, 0, 0, 0, NULL, '9 m', '', '', 'action', '8 heures', NULL, NULL, 0, 0, '<p>Un gardien spectral de taille G apparaît pour toute la durée et flotte en un espace inoccupé que vous voyez à portée. Le gardien, invulnérable, occupe cet espace et se présente sous une forme adaptée à votre divinité ou panthéon.</p>
<p>Tout ennemi qui se déplace dans un espace à 3 m ou moins du gardien pour la première fois d''un tour ou qui y commence son tour effectue un jet de sauvegarde de Dextérité et subit 20 dégâts radiants en cas d''échec, la moitié en cas de réussite. Le gardien disparaît après avoir infligé un total de 60 dégâts.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7671, 2238, 54, 4);

-- [2239] Glissement de terrain (niv 6, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2239, 'Glissement de terrain', 6, 4, NULL, 1, 1, 1, 0, 0, 'une pelle miniature', '36 m', '', '', 'action', 'Concentration, jusqu''à 2 heures', NULL, NULL, 1, 0, '<p>Choisissez à portée une zone de terrain dont la longueur ne dépasse pas 12 m. Vous pouvez remodeler la terre, le sable ou l''argile de la zone à votre guise pour toute la durée. Vous pouvez accroître ou diminuer la hauteur de la zone, créer une tranchée ou en combler une, ériger un mur ou l''aplanir, ou former une colonne. Aucune de ces altérations ne peut excéder en taille la moitié de la dimension la plus grande de la zone. Ces modifications s''accomplissent en 10 minutes. Ces transformations ne s''opérant que lentement, les créatures situées dans la zone ne se font généralement pas piéger ni blesser par les mouvements de terrain.</p>
<p>À la fin de chaque tranche de 10 minutes passées à vous concentrer sur le sort, vous pouvez choisir une nouvelle zone de terrain à portée pour l''affecter.</p>
<p>Ce sort ne peut pas manipuler la pierre naturelle ni les bâtiments en pierre. La roche et les édifices se contentent de s''adapter au terrain modifié. Si l''altération du terrain menace de rendre un édifice instable, il peut effectivement s''effondrer.</p>
<p>Ce sort n''affecte pas directement le développement de la flore. La terre déplacée emporte avec elle les plantes qui l''occupent.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7672, 2239, 55, 6),
  (7673, 2239, 56, 6),
  (7674, 2239, 52, 6);

-- [2240] Globe d'invulnérabilité (niv 6, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2240, 'Globe d''invulnérabilité', 6, 5, NULL, 1, 1, 1, 0, 0, 'une perle en verre', 'personnelle', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Une barrière immobile qui chatoie se matérialise sous forme d''une Émanation de 3 m qui persiste pour toute la durée.</p>
<p>Tout sort du 5e niveau ou inférieur lancé depuis l''extérieur de la barrière ne peut affecter ce qui se trouve à l''intérieur. Un tel sort peut cibler les créatures et objets situés dans le globe, mais il reste sur eux sans effet. De même, la zone comprise dans la barrière est exclue des zones d''effet créées par de tels sorts.</p>
<p>Emplacement de niveau supérieur. La barrière bloque les sorts d''un niveau de plus par niveau d''emplacement au-delà du 6e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7675, 2240, 56, 6),
  (7676, 2240, 52, 6);

-- [2241] Glyphe de garde (niv 3, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2241, 'Glyphe de garde', 3, 5, NULL, 1, 1, 1, 0, 0, 'poudre de diamant d''une valeur minimale de 200 po, que le sort détruit', 'contact', '', '', '1 heure', 'jusqu''à dissipation ou activation', NULL, NULL, 0, 0, '<p>Vous inscrivez un glyphe qui produira ultérieurement des effets magiques. Vous le tracez soit sur une surface (comme une table ou une section de sol), soit à l''intérieur d''un objet que l''on peut fermer (comme un livre ou un coffre) de manière à dissimuler le symbole. Le glyphe peut recouvrir une zone dont le diamètre ne dépasse pas 3 m. Si vous optez pour un objet, celui-ci doit rester à sa place ; si on le déplace de plus de 3 m de l''endroit où vous avez lancé le sort, le glyphe est rompu et le sort prend fin sans avoir été activé.</p>
<p>Le glyphe est pratiquement imperceptible, au point qu''il faut réussir un test de Sagesse (Perception) assorti de votre DD de sauvegarde des sorts pour le remarquer.</p>
<p>À l''inscription du glyphe, vous déterminez son déclencheur et décidez s''il s''agit d''une rune explosive ou d''un glyphe à sort (voir ci-après).</p>
<p>Déclencheur. Vous décidez ce qui le déclenche à l''incantation du sort. Dans le cas des glyphes de surface, les déclencheurs courants sont les suivants : toucher le glyphe, le fouler, retirer un objet qui le recouvre ou s''approcher dans un certain rayon. Pour les glyphes inscrits dans un objet, les déclencheurs courants sont l''ouverture de l''objet et la vue du glyphe. Une fois le glyphe déclenché, le sort prend fin. Vous pouvez préciser le déclencheur afin que seules les créatures d''un type donné l''activent, ou définir des créatures qui ne déclenchent pas le glyphe.</p>
<p>Rune explosive. Quand il se déclenche, le glyphe produit une explosion d''énergies magiques sous forme d''une Sphère de 6 m de rayon centrée sur le glyphe. Chaque créature prise dans la zone effectue un jet de sauvegarde de Dextérité. Elle subit 5d8 dégâts d''acide, de feu, de foudre, de froid ou de tonnerre (type que vous choisissez en inscrivant le glyphe) en cas d''échec, la moitié en cas de réussite.</p>
<p>Glyphe à sort. Vous pouvez charger le glyphe d''un sort du 3e niveau ou inférieur. Le sort doit cibler une seule créature ou une zone. Le sort ainsi appliqué au glyphe n''a pas d''effet immédiat lorsque vous le lancez. C''est seulement lors du déclenchement du glyphe que le sort chargé prend effet. Si le sort requiert normalement la Concentration, il persiste jusqu''à la fin de la durée maximale.</p>
<p>Emplacement de niveau supérieur. Les dégâts d''une rune explosive augmentent de 1d8 par niveau d''emplacement au-delà du 3e. Si vous créez un glyphe à sort, vous pouvez y stocker un sort dont le niveau ne dépasse pas celui de l''emplacement utilisé pour votre glyphe de garde.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7677, 2241, 53, 3),
  (7678, 2241, 54, 3),
  (7679, 2241, 52, 3);

-- [2242] Graisse (niv 1, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2242, 'Graisse', 1, 6, NULL, 1, 1, 1, 0, 0, 'un peu de couenne de porc ou de beurre', '18 m', '', '', 'action', '1 minute', NULL, NULL, 0, 0, '<p>Une graisse glissante non inflammable recouvre le sol sur un carré de 3 m de côté centré sur un point à portée, ce qui en fait un Terrain difficile pour toute la durée.</p>
<p>À l''apparition de la graisse, toute créature se tenant debout dans cette zone doit réussir un jet de sauvegarde de Dextérité sous peine de subir l''état À terre. Une créature qui pénètre dans la zone ou qui y termine son tour doit également réussir ce JS sous peine de se retrouver À terre.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7680, 2242, 56, 1),
  (7681, 2242, 52, 1);

-- [2243] Grande foulée (niv 1, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2243, 'Grande foulée', 1, 4, NULL, 1, 1, 1, 0, 0, 'une pincée de terre', 'contact', '', '', 'action', '1 heure', NULL, NULL, 0, 0, '<p>Vous touchez une créature. La Vitesse de la cible augmente de 3 m jusqu''à la fin du sort.</p>
<p>Emplacement de niveau supérieur. Vous pouvez cibler une créature supplémentaire par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7682, 2243, 53, 1),
  (7683, 2243, 55, 1),
  (7684, 2243, 52, 1),
  (7685, 2243, 60, 1);

-- [2244] Guérison (niv 6, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2244, 'Guérison', 6, 5, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Choisissez une créature que vous voyez à portée. Une vague d''énergie positive baigne la créature, qui récupère 70 points de vie. Ce sort met également fin aux éventuels états Assourdi, Aveuglé et Empoisonné de la cible.</p>
<p>Emplacement de niveau supérieur. Les soins augmentent de 10 par niveau d''emplacement au-delà du 6e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7686, 2244, 54, 6),
  (7687, 2244, 55, 6);

-- [2245] Guérison de groupe (niv 9, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2245, 'Guérison de groupe', 9, 5, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous projetez une vague d''énergie curative vers les créatures qui vous entourent. Vous restituez un maximum de 700 points de vie, répartis à votre guise entre les créatures de votre choix parmi celles que vous voyez à portée. Les créatures soignées par ce sort se débarrassent en outre des états Assourdi, Aveuglé et Empoisonné.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7688, 2245, 54, 9);

-- [2246] Hâte (niv 3, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2246, 'Hâte', 3, 4, NULL, 1, 1, 1, 0, 0, 'un copeau de racine de réglisse', '9 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Choisissez une créature consentante que vous voyez à portée. Jusqu''à la fin du sort, la cible voit sa Vitesse doubler, sa classe d''armure reçoit un bonus de +2, elle a l''Avantage aux jets de sauvegarde de Dextérité et bénéficie d''une action supplémentaire à chacun de ses tours. Cette action ne peut servir qu''à entreprendre l''action Attaque (une seule attaque d''arme), Désengagement, Furtivité, Pointe ou Utilisation.</p>
<p>Lorsque le sort prend fin, jusqu''à la fin de son tour suivant, la cible en proie à une vague de léthargie subit l''état Neutralisé et sa vitesse est de 0.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7689, 2246, 56, 3),
  (7690, 2246, 52, 3);

-- [2247] Héroïsme (niv 1, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2247, 'Héroïsme', 1, 3, NULL, 1, 1, 0, 0, 0, NULL, 'contact', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Une créature consentante que vous touchez est investie de vaillance. Jusqu''à la fin du sort, la créature est immunisée contre l''état Effrayé et reçoit autant de points de vie temporaires que votre modificateur de caractéristique d''incantation au début de chacun de ses tours.</p>
<p>Emplacement de niveau supérieur. Vous pouvez cibler une créature supplémentaire par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7691, 2247, 53, 1),
  (7692, 2247, 59, 1);

-- [2248] Identification (niv 1, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2248, 'Identification', 1, 7, NULL, 1, 1, 1, 0, 0, 'une perle d''une valeur minimale de 100 po', 'contact', '', '', '1 minute ou rituel', 'instantanée', NULL, NULL, 0, 1, '<p>Vous touchez physiquement un objet tout au long de l''incantation. S''il s''agit d''un objet magique ou imprégné de magie, vous en apprenez les propriétés et savez les utiliser ; vous savez également si l''Harmonisation est requise et de combien de charges l''objet dispose, le cas échéant. Vous apprenez aussi quels sorts éventuels affectent l''objet. Si l''objet a été créé par un sort, vous apprenez lequel.</p>
<p>Si au lieu d''un objet, vous touchez une créature pendant toute l''incantation, vous apprenez quels sorts éventuels l''affectent.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7693, 2248, 53, 1),
  (7694, 2248, 52, 1);

-- [2249] Illusion mineure (niv 0, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2249, 'Illusion mineure', 0, 9, NULL, 0, 1, 1, 0, 0, 'un peu de laine brute', '9 m', '', '', 'action', '1 minute', NULL, NULL, 0, 0, '<p>Vous créez à portée un son ou l''image d''un objet qui persiste pour toute la durée. L''illusion prend fin si vous relancez ce sort.</p>
<p>Une créature qui entreprend l''action Étude pour examiner le son ou l''image peut comprendre qu''il s''agit d''une illusion en réussissant un test d''Intelligence (Investigation) assorti de votre DD de sauvegarde des sorts. Une créature qui perce l''illusion continue de la percevoir, quoiqu''amoindrie.</p>
<p>Son. Si vous créez un son, son volume peut aller du murmure au cri. Il peut prendre votre voix, celle de quelqu''un d''autre, imiter le rugissement du lion, un roulement de tambour ou une autre forme de votre choix. Le son se prolonge sans discontinuer pour toute la durée, à moins que vous préfériez ne le faire intervenir que de temps à autre.</p>
<p>Image. Si vous créez l''image d''un objet, comme une chaise, des empreintes boueuses ou un petit coffre, il doit pouvoir tenir dans un Cube de 1,50 m. L''image ne peut créer ni son, ni lumière, ni odeur, ni autre effet sensoriel. Toute interaction physique avec l''image percera l''illusion, car elle n''est pas tangible.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7695, 2249, 53, 0),
  (7696, 2249, 56, 0),
  (7697, 2249, 52, 0),
  (7698, 2249, 58, 0);

-- [2250] Illusion programmée (niv 6, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2250, 'Illusion programmée', 6, 9, NULL, 1, 1, 1, 0, 0, 'poudre de jade d''une valeur minimale de 25 po', '36 m', '', '', 'action', 'jusqu''à dissipation', NULL, NULL, 0, 0, '<p>Vous créez l''illusion d''un objet, d''une créature ou d''un autre phénomène visible à portée, qui s''active lorsqu''un déclencheur spécifique se présente. L''illusion reste imperceptible jusque-là. Elle doit loger dans un Cube de 9 m et vous décidez à l''incantation du sort comment l''illusion se comporte et quels sons elle produit. Cette performance scénarisée peut durer jusqu''à 5 minutes.</p>
<p>Quand le déclencheur se présente, l''illusion prend vie selon le scénario que vous avez décrit. Une fois qu''elle a terminé son numéro, l''illusion disparaît et reste en veilleuse pendant 10 minutes, après quoi on peut la réactiver.</p>
<p>Les circonstances de déclenchement peuvent être générales ou détaillées, à votre convenance, mais doivent correspondre à des conditions visuelles ou auditives intervenant dans un rayon de 9 m de la zone.</p>
<p>Toute interaction physique avec l''image percera l''illusion, car elle n''est pas tangible. Une créature qui entreprend l''action Étude pour examiner l''image peut comprendre qu''il s''agit d''une illusion en réussissant un test d''Intelligence (Investigation) assorti de votre DD de sauvegarde des sorts.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7699, 2250, 53, 6),
  (7700, 2250, 52, 6);

-- [2251] Image majeure (niv 3, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2251, 'Image majeure', 3, 9, NULL, 1, 1, 1, 0, 0, 'un peu de laine brute', '36 m', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Vous créez l''image d''un objet, d''une créature ou autre phénomène visible dont la taille ne dépasse pas celle d''un Cube de 6 m. L''image apparaît en un endroit que vous voyez à portée et persiste pour toute la durée. Elle semble réelle, avec les sons, les odeurs et la température attendus, mais elle ne peut infliger de dégâts ni d''états.</p>
<p>Si vous êtes à portée de l''illusion, vous pouvez entreprendre l''action Magie pour déplacer l''image vers un autre point à portée du sort. Lors de ce déplacement, vous pouvez modifier l''aspect de l''image afin que ses mouvements paraissent naturels. Vous pouvez lui faire produire des sons à votre guise et même la faire participer à une conversation.</p>
<p>Toute interaction physique avec l''image percera l''illusion, car elle n''est pas tangible. Une créature qui entreprend l''action Étude pour examiner l''image peut comprendre qu''il s''agit d''une illusion en réussissant un test d''Intelligence (Investigation) assorti de votre DD de sauvegarde des sorts.</p>
<p>Emplacement de niveau supérieur. Lancé par un emplacement du 4e niveau ou supérieur, le sort persiste jusqu''à dissipation sans besoin de Concentration.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7701, 2251, 53, 3),
  (7702, 2251, 56, 3),
  (7703, 2251, 52, 3),
  (7704, 2251, 58, 3);

-- [2252] Image miroir (niv 2, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2252, 'Image miroir', 2, 9, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action', '1 minute', NULL, NULL, 0, 0, '<p>Trois répliques illusoires de vous-même apparaissent dans votre espace. Jusqu''à la fin du sort, les répliques se déplacent avec vous et reproduisent vos actions en changeant constamment de position, si bien qu''il est impossible de savoir quelle version est réelle.</p>
<p>Chaque fois qu''une créature vous touche avec une attaque avant la fin du sort, lancez un d6 pour chacune de vos répliques. Si au moins l''un de ces d6 obtient un résultat de 3 ou plus, c''est l''une des répliques qui est touchée à votre place et qui est détruite. Pour le reste, les dégâts et effets ne s''appliquent pas aux répliques. Le sort prend fin quand les trois répliques sont détruites.</p>
<p>Toute créature subissant l''état Aveuglé, ou dotée de la Vision aveugle ou de la Vision lucide, n''est pas affectée par ce sort.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7705, 2252, 53, 2),
  (7706, 2252, 56, 2),
  (7707, 2252, 52, 2),
  (7708, 2252, 58, 2);

-- [2253] Image projetée (niv 7, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2253, 'Image projetée', 7, 9, NULL, 1, 1, 1, 0, 0, 'une statuette à votre effigie d''une valeur minimale de 5 po', '750 km', '', '', 'action', 'Concentration, jusqu''à 1 jour', NULL, NULL, 1, 0, '<p>Vous créez une réplique illusoire de vous-même qui persiste pour toute la durée. Ce double peut apparaître en n''importe quel lieu à portée que vous avez déjà vu, quels que soient les obstacles qui vous en séparent. L''illusion présente votre aspect et sonne comme vous, mais elle est intangible. Si elle subit des dégâts, l''illusion disparaît et le sort prend fin.</p>
<p>Vous voyez et entendez comme si vous vous trouviez dans son espace. Au prix de l''action Magie, vous pouvez déplacer votre double d''un maximum de 18 m et le faire bouger, parler et se comporter à votre guise.</p>
<p>Toute interaction physique avec l''image percera l''illusion, car elle n''est pas tangible. Une créature qui entreprend l''action Étude peut comprendre qu''il s''agit d''une illusion en réussissant un test d''Intelligence (Investigation) assorti de votre DD de sauvegarde des sorts.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7709, 2253, 53, 7),
  (7710, 2253, 52, 7);

-- [2254] Image silencieuse (niv 1, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2254, 'Image silencieuse', 1, 9, NULL, 1, 1, 1, 0, 0, 'un peu de laine brute', '18 m', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Vous créez l''image d''un objet, d''une créature ou autre phénomène visible dont la taille ne dépasse pas celle d''un Cube de 4,50 m. L''image apparaît en un endroit à portée et persiste pour toute la durée. Elle est purement visuelle, dépourvue de son, d''odeur et de tout autre effet sensoriel.</p>
<p>Au prix de l''action Magie, vous pouvez déplacer l''image en un point à portée. Lors de ce déplacement, vous pouvez modifier l''aspect de l''image afin que ses mouvements paraissent naturels.</p>
<p>Toute interaction physique avec l''image percera l''illusion, car elle n''est pas tangible. Une créature qui entreprend l''action Étude pour examiner l''image peut comprendre qu''il s''agit d''une illusion en réussissant un test d''Intelligence (Investigation) assorti de votre DD de sauvegarde des sorts.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7711, 2254, 53, 1),
  (7712, 2254, 56, 1),
  (7713, 2254, 52, 1);

-- [2255] Immobilisation de monstre (niv 5, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2255, 'Immobilisation de monstre', 5, 3, NULL, 1, 1, 1, 0, 0, 'un brin de fer', '27 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Choisissez une créature que vous voyez à portée. La cible doit réussir un jet de sauvegarde de Sagesse sous peine de subir l''état Paralysé pour toute la durée du sort. La cible réitère le JS à la fin de chacun de ses tours et met un terme au sort sur elle-même en cas de réussite.</p>
<p>Emplacement de niveau supérieur. Vous pouvez cibler une créature supplémentaire par niveau d''emplacement au-delà du 5e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7714, 2255, 53, 5),
  (7715, 2255, 56, 5),
  (7716, 2255, 52, 5),
  (7717, 2255, 58, 5);

-- [2256] Immobilisation de personne (niv 2, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2256, 'Immobilisation de personne', 2, 3, NULL, 1, 1, 1, 0, 0, 'un brin de fer', '18 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Choisissez un Humanoïde que vous voyez à portée. La cible doit réussir un jet de sauvegarde de Sagesse sous peine de subir l''état Paralysé pour toute la durée du sort. La cible réitère le JS à la fin de chacun de ses tours et met un terme au sort sur elle-même en cas de réussite.</p>
<p>Emplacement de niveau supérieur. Vous pouvez cibler un Humanoïde supplémentaire par niveau d''emplacement au-delà du 2e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7718, 2256, 53, 2),
  (7719, 2256, 54, 2),
  (7720, 2256, 55, 2),
  (7721, 2256, 56, 2),
  (7722, 2256, 52, 2),
  (7723, 2256, 58, 2);

-- [2257] Imprécation (niv 1, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2257, 'Imprécation', 1, 3, NULL, 1, 1, 1, 0, 0, 'une goutte de sang', '9 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Un maximum de trois créatures de votre choix parmi celles que vous voyez à portée effectuent un jet de sauvegarde de Charisme. Chaque fois qu''une créature ayant raté ce JS effectue un jet d''attaque ou un jet de sauvegarde avant la fin du sort, elle soustrait 1d4 au résultat correspondant.</p>
<p>Emplacement de niveau supérieur. Vous pouvez cibler une créature supplémentaire par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7724, 2257, 53, 1),
  (7725, 2257, 54, 1),
  (7726, 2257, 58, 1);

-- [2258] Injonction (niv 1, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2258, 'Injonction', 1, 3, NULL, 1, 0, 0, 0, 0, NULL, '18 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous adressez un simple mot de commande à une créature que vous voyez à portée. La cible doit réussir un jet de sauvegarde de Sagesse sous peine de devoir s''y soumettre à son tour suivant. Choisissez votre ordre parmi les options suivantes :</p>
<p>Approche. La cible se déplace dans votre direction par le chemin le plus court et direct, et termine son tour si elle se retrouve dans un rayon de 1,50 m de vous.<br>
Fuis. La cible consacre son tour à s''éloigner de vous par le moyen le plus rapide.<br>
Halte. À son tour, la cible ne se déplace pas, et n''entreprend ni action ni action Bonus.<br>
Lâche. La cible lâche ce qu''elle tient et termine son tour.<br>
Rampe. La cible subit l''état À terre et termine son tour.</p>
<p>Emplacement de niveau supérieur. Vous pouvez affecter une créature supplémentaire par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7727, 2258, 53, 1),
  (7728, 2258, 54, 1),
  (7729, 2258, 59, 1);

-- [2259] Insecte géant (niv 4, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2259, 'Insecte géant', 4, 6, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Vous convoquez une araignée, une guêpe ou un mille-pattes (choisissez à l''incantation du sort), en version géante. La créature se manifeste en un espace inoccupé que vous voyez à portée et reprend le profil de l''insecte géant. La créature disparaît quand le sort prend fin, ou si elle tombe à 0 point de vie.</p>
<p>La créature constitue un allié pour vous et vos alliés. Au combat, la créature partage votre rang d''Initiative, mais elle joue son tour juste après vous. Elle obéit à vos instructions verbales. Sans ordre de votre part, elle entreprend l''action Esquive et consacre son déplacement à se mettre à l''abri du danger.</p>
<p>Emplacement de niveau supérieur. Le niveau de l''emplacement de sort s''applique chaque fois que le profil de jeu y fait référence.</p>
<p>— Insecte géant —<br>
Bête de taille G, non alignée<br>
CA 11 + niveau du sort<br>
Pv 30 + 10 par niveau du sort au-delà du 4e<br>
Vitesse 12 m, escalade 12 m, vol 12 m (guêpe uniquement)<br>
For 17 (+3, JS +3) ; Dex 13 (+1, JS +1) ; Con 15 (+2, JS +2) ; Int 4 (-3, JS -3) ; Sag 14 (+2, JS +2) ; Cha 3 (-4, JS -4)<br>
Sens Vision dans le noir 18 m ; Perception passive 12<br>
Langues comprend les langues que vous parlez<br>
FP aucun (PX 0 ; BM égal à votre bonus de maîtrise)<br>
Traits — Pattes d''araignée. L''insecte peut parcourir les parois les plus difficiles à escalader, y compris les plafonds, sans passer par un test de caractéristique.<br>
Actions — Attaques multiples. L''insecte effectue autant d''attaques que la moitié du niveau de ce sort (arrondi à l''inférieur).<br>
Piqûre toxique. Corps à corps : bonus égal à votre modificateur d''attaque des sorts, allonge 3 m. Touché : 1d6 + 3 + niveau du sort dégâts perforants, plus 1d4 dégâts de poison.<br>
Jet de toile (araignée uniquement). À distance : bonus égal à votre modificateur d''attaque des sorts, portée 18 m. Touché : 1d10 + 3 + niveau du sort dégâts contondants, et la vitesse de la cible tombe à 0 jusqu''au début du tour suivant de l''insecte.<br>
Actions Bonus — Crachat venimeux (mille-pattes uniquement). JS Constitution : votre DD de sauvegarde des sorts, une créature que l''insecte voit dans un rayon de 3 m. Échec : la cible subit l''état Empoisonné jusqu''au début du tour suivant de l''insecte.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7730, 2259, 55, 4);

-- [2260] Interdiction (niv 6, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2260, 'Interdiction', 6, 5, NULL, 1, 1, 1, 0, 0, 'poudre de rubis d''une valeur minimale de 1 000 po', 'contact', '', '', '10 minutes ou rituel', '1 jour', NULL, NULL, 0, 1, '<p>Vous créez une barrière contre le voyage magique qui protège jusqu''à 3 600 m² d''espace au sol, sur une hauteur de 9 m. Pour toute la durée, aucune créature ne peut se téléporter dans la zone ou y pénétrer par le biais d''un accès magique comme celui que crée le sort portail. Le sort proscrit tout voyage planaire dans la zone.</p>
<p>De plus, le sort inflige des dégâts aux types de créature que vous désignez à l''incantation. Choisissez un ou plusieurs types parmi les suivants : Aberrations, Célestes, Élémentaires, Fées, Fiélons et Morts-vivants. Lorsqu''une créature désignée entre dans la zone pour la première fois d''un tour ou y termine son tour, elle subit 5d10 dégâts nécrotiques ou radiants (vous choisissez à l''incantation du sort).</p>
<p>Vous pouvez choisir un mot de passe à l''incantation du sort. Une créature qui prononce ce sésame en pénétrant dans la zone ne subit aucun dégât du sort.</p>
<p>La zone du sort ne peut pas chevaucher celle d''un autre sort d''interdiction. Si vous lancez chaque jour interdiction au même endroit pendant 30 jours, le sort persiste jusqu''à dissipation.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7731, 2260, 54, 6);

-- [2261] Inversion de la gravité (niv 7, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2261, 'Inversion de la gravité', 7, 4, NULL, 1, 1, 1, 0, 0, 'une magnétite et de la limaille de fer', '30 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Ce sort inverse la gravité dans un Cylindre de 15 m de rayon et 30 m de haut centré sur un point à portée. Tous les objets et créatures de la zone qui ne sont pas ancrés au sol « chutent » vers le haut pour atteindre le sommet du Cylindre. Une créature a droit à un jet de sauvegarde de Dextérité pour saisir un objet fixé à portée d''allonge et ainsi éviter la « chute ».</p>
<p>Si un plafond ou un objet ancré se présente en travers de la chute, les objets et créatures qui tombent le heurtent comme ils le feraient lors d''une chute normale. Les objets et créatures qui atteignent le sommet du Cylindre sans rien heurter y restent en suspension pour toute la durée. À la fin du sort, les objets et créatures affectés retombent vers le bas.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7732, 2261, 55, 7),
  (7733, 2261, 56, 7),
  (7734, 2261, 52, 7);

-- [2262] Invisibilité (niv 2, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2262, 'Invisibilité', 2, 9, NULL, 1, 1, 1, 0, 0, 'un cil dans de la sève', 'contact', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>La créature que vous touchez physiquement reçoit l''état Invisible jusqu''à la fin du sort. Le sort prend fin prématurément si la cible effectue un jet d''attaque, inflige des dégâts ou lance un sort.</p>
<p>Emplacement de niveau supérieur. Vous pouvez cibler une créature supplémentaire par niveau d''emplacement au-delà du 2e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7735, 2262, 53, 2),
  (7736, 2262, 56, 2),
  (7737, 2262, 52, 2),
  (7738, 2262, 58, 2);

-- [2263] Invisibilité suprême (niv 4, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2263, 'Invisibilité suprême', 4, 9, NULL, 1, 1, 0, 0, 0, NULL, 'contact', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>La créature que vous touchez physiquement reçoit l''état Invisible jusqu''à la fin du sort.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7739, 2263, 53, 4),
  (7740, 2263, 56, 4),
  (7741, 2263, 52, 4);

-- [2264] Invocation d'animaux (niv 3, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2264, 'Invocation d''animaux', 3, 6, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Vous invoquez des esprits de la nature qui prennent la forme d''une « meute » de taille G d''animaux intangibles apparaissant en un espace inoccupé que vous voyez à portée. Cette meute persiste pour toute la durée et vous choisissez la forme animale des esprits (loups, serpents ou oiseaux, par exemple).</p>
<p>Vous avez l''Avantage aux jets de sauvegarde de Force tant que vous êtes dans un rayon de 1,50 m de la meute. Lorsque vous vous déplacez à votre tour, vous pouvez également déplacer la meute d''un maximum de 9 m jusqu''à un espace inoccupé que vous voyez.</p>
<p>Chaque fois que la meute se déplace dans un rayon de 3 m d''une créature que vous voyez, ainsi que chaque fois qu''une créature que vous voyez pénètre dans un espace à 3 m ou moins de la meute ou y termine son tour, vous pouvez contraindre cette créature à un jet de sauvegarde de Dextérité. En cas d''échec, elle subit 3d10 dégâts tranchants. Une même créature n''effectue en aucun cas ce JS plus d''une fois par tour.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d10 par niveau d''emplacement au-delà du 3e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7742, 2264, 55, 3),
  (7743, 2264, 60, 3);

-- [2265] Invocation d'élémentaire (niv 5, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2265, 'Invocation d''élémentaire', 5, 6, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Vous invoquez un esprit intangible de taille G issu des Plans Élémentaires, qui apparaît en un espace inoccupé à portée. Choisissez l''élément de l''esprit, qui définit son type de dégâts : air (foudre), eau (froid), feu (feu) ou terre (tonnerre). L''esprit persiste pour toute la durée.</p>
<p>Chaque fois qu''une créature que vous voyez pénètre dans l''espace de l''esprit ou commence son tour dans un rayon de 1,50 m de celui-ci, vous pouvez la contraindre à un jet de sauvegarde de Dextérité si l''esprit n''a pas de créature Entravée. En cas d''échec, la cible subit 8d8 dégâts du type associé à l''esprit, ainsi que l''état Entravé jusqu''à la fin du sort. Au début de chacun de ses tours, la cible Entravée réitère le JS. En cas d''échec, elle subit 4d8 dégâts du type de l''esprit. En cas de réussite, elle n''est plus Entravée par l''esprit.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d8 par niveau d''emplacement au-delà du 5e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7744, 2265, 55, 5),
  (7745, 2265, 52, 5);

-- [2266] Invocation d'élémentaires mineurs (niv 4, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2266, 'Invocation d''élémentaires mineurs', 4, 6, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Vous invoquez des esprits issus des Plans Élémentaires qui volètent autour de vous pour toute la durée, sous forme d''une Émanation de 4,50 m. Jusqu''à la fin du sort, toute attaque que vous effectuez inflige 2d8 dégâts supplémentaires lorsque vous touchez une créature prise dans l''Émanation. Ces dégâts sont d''acide, de feu, de foudre ou de froid (vous choisissez en effectuant l''attaque).</p>
<p>De plus, le sol dans l''Émanation constitue un Terrain difficile pour vos ennemis.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d8 par niveau d''emplacement au-delà du 4e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7746, 2266, 55, 4),
  (7747, 2266, 52, 4);

-- [2267] Invocation d'êtres sylvestres (niv 4, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2267, 'Invocation d''êtres sylvestres', 4, 6, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Vous invoquez des esprits de la nature qui volètent autour de vous pour toute la durée, sous forme d''une Émanation de 3 m. Chaque fois que l''Émanation pénètre dans l''espace d''une créature que vous voyez, ainsi que chaque fois qu''une créature que vous voyez pénètre dans l''Émanation ou y termine son tour, vous pouvez la contraindre à un jet de sauvegarde de Sagesse. Elle subit 5d8 dégâts de force en cas d''échec, la moitié en cas de réussite. Une même créature n''effectue en aucun cas ce JS plus d''une fois par tour.</p>
<p>De plus, pour toute la durée du sort, vous pouvez entreprendre l''action Désengagement par une action Bonus.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d8 par niveau d''emplacement au-delà du 4e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7748, 2267, 55, 4),
  (7749, 2267, 60, 4);

-- [2268] Invocation de céleste (niv 7, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2268, 'Invocation de céleste', 7, 6, NULL, 1, 1, 0, 0, 0, NULL, '27 m', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Vous invoquez un esprit des Plans Supérieurs, qui se manifeste telle une colonne de lumière : un Cylindre de 3 m de rayon et 12 m de haut, centré sur un point à portée. Pour chaque créature que vous voyez dans le Cylindre, choisissez par laquelle des lumières suivantes elle est baignée :</p>
<p>Lumière calcinante. La cible effectue un jet de sauvegarde de Dextérité, et subit 6d12 dégâts radiants en cas d''échec, la moitié en cas de réussite.<br>
Lumière guérisseuse. La cible récupère autant de points de vie que 4d12 + votre modificateur de caractéristique d''incantation.</p>
<p>Jusqu''à la fin du sort, le Cylindre est empli d''une Lumière vive et, quand vous vous déplacez à votre tour, vous pouvez également déplacer le Cylindre d''un maximum de 9 m.</p>
<p>Chaque fois que le Cylindre se déplace dans l''espace d''une créature que vous voyez, ainsi que chaque fois qu''une créature que vous voyez pénètre dans le Cylindre ou y termine son tour, vous pouvez la baigner de l''une des lumières. Une même créature ne peut être affectée par ce sort plus d''une fois par tour.</p>
<p>Emplacement de niveau supérieur. Les soins et les dégâts augmentent de 1d12 par niveau d''emplacement au-delà du 7e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7750, 2268, 54, 7);

-- [2269] Invocation de fée (niv 6, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2269, 'Invocation de fée', 6, 6, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Vous invoquez un esprit de taille M issu de Féerie, en un espace inoccupé que vous voyez à portée. L''esprit persiste pour toute la durée, avec l''aspect de la Fée de votre choix. Quand l''esprit apparaît, vous pouvez effectuer une attaque de sort au corps à corps contre une créature située dans un rayon de 1,50 m de l''esprit. Si l''attaque touche, la cible subit des dégâts psychiques égaux à 3d12 plus votre modificateur de caractéristique d''incantation, et subit l''état Effrayé jusqu''au début de votre tour suivant.</p>
<p>Par une action Bonus à vos tours suivants, vous pouvez téléporter l''esprit en un espace inoccupé que vous voyez dans un rayon de 9 m de l''espace que vous lui faites quitter et effectuer l''attaque contre une créature située à 1,50 m ou moins de lui.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d12 par niveau d''emplacement au-delà du 6e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7751, 2269, 55, 6);

-- [2270] Lame de feu (niv 2, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2270, 'Lame de feu', 2, 1, NULL, 1, 1, 1, 0, 0, 'une feuille d''amarante', 'personnelle', '', '', 'action Bonus', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Vous faites apparaître une lame ardente dans votre main libre. La lame est comparable en taille et forme à un cimeterre. Elle persiste pour toute la durée. Si vous la lâchez, la lame disparaît, mais vous pouvez la faire réapparaître par une action Bonus.</p>
<p>Au prix de l''action Magie, vous pouvez effectuer une attaque de sort avec la lame enflammée. Si l''attaque touche, la cible subit des dégâts de feu : 3d6 plus votre modificateur de caractéristique d''incantation.</p>
<p>La lame ardente projette une Lumière vive sur un rayon de 3 m, et une Lumière faible sur 3 m de plus.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d6 par niveau d''emplacement au-delà du 2e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7752, 2270, 55, 2),
  (7753, 2270, 56, 2);

-- [2271] Lenteur (niv 3, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2271, 'Lenteur', 3, 4, NULL, 1, 1, 1, 0, 0, 'une goutte de mélasse', '36 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous altérez le temps autour d''un maximum de six créatures de votre choix dans un Cube de 12 m à portée. Chaque cible doit réussir un jet de sauvegarde de Sagesse sous peine d''être affectée par ce sort pour toute la durée.</p>
<p>Une cible affectée voit sa Vitesse réduite de moitié, subit un malus de –2 à la CA et aux jets de sauvegarde de Dextérité, et ne peut pas jouer de Réactions. À ses tours, elle peut entreprendre une action ou une action Bonus, mais pas les deux, et elle ne peut effectuer qu''une attaque dans le cadre de l''action Attaque. Si elle lance un sort avec une composante somatique, il y a 25 % de chances que le sort échoue en raison de la torpeur de sa gestuelle.</p>
<p>Une cible affectée réitère le JS à la fin de chacun de ses tours et met un terme au sort sur elle-même en cas de réussite.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7754, 2271, 53, 3),
  (7755, 2271, 56, 3),
  (7756, 2271, 52, 3);

-- [2272] Lévitation (niv 2, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2272, 'Lévitation', 2, 4, NULL, 1, 1, 1, 0, 0, 'un ressort métallique', '18 m', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Une créature ou un objet de votre choix que vous voyez à portée monte verticalement d''un maximum de 6 m et y reste, en suspension, pour toute la durée. Le sort peut faire léviter un objet dont le poids n''excède pas 250 kg. Une créature non consentante qui réussit un jet de sauvegarde de Constitution n''est pas affectée.</p>
<p>La cible ne peut se déplacer qu''en prenant appui sur des objets et surfaces fixes à portée (murs, plafonds, etc.), comme si elle escaladait. À votre tour, vous pouvez modifier l''altitude de la cible d''un maximum de 6 m vers le haut ou vers le bas. Si vous êtes la cible, vous pouvez vous déplacer ainsi dans le cadre de votre déplacement. Sans cela, vous devez entreprendre l''action Magie pour déplacer la cible, qui doit rester à portée du sort.</p>
<p>Lorsque le sort prend fin, la cible redescend en flottant vers le sol si elle est toujours dans les airs.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7757, 2272, 56, 2),
  (7758, 2272, 52, 2);

-- [2273] Liberté de mouvement (niv 4, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2273, 'Liberté de mouvement', 4, 5, NULL, 1, 1, 1, 0, 0, 'une bandelette de cuir', 'contact', '', '', 'action', '1 heure', NULL, NULL, 0, 0, '<p>Vous touchez une créature consentante. Pour toute la durée, les déplacements de la cible ne sont pas affectés par le Terrain difficile, et les sorts et effets magiques ne peuvent ni réduire sa Vitesse, ni lui infliger l''état Paralysé ou Entravé. La cible dispose aussi d''une Vitesse de nage égale à sa Vitesse.</p>
<p>De plus, la cible peut consacrer 1,50 m de son déplacement à s''extraire automatiquement d''entraves non magiques, comme des menottes ou l''étreinte d''une créature qui lui impose l''état Agrippé.</p>
<p>Emplacement de niveau supérieur. Vous pouvez cibler une créature supplémentaire par niveau d''emplacement au-delà du 4e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7759, 2273, 53, 4),
  (7760, 2273, 54, 4),
  (7761, 2273, 55, 4),
  (7762, 2273, 60, 4);

-- [2274] Lien de protection (niv 2, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2274, 'Lien de protection', 2, 5, NULL, 1, 1, 1, 0, 0, 'deux bagues de platine d''une valeur de 50 po chacune, que la cible et vous devez porter pour toute la durée', 'contact', '', '', 'action', '1 heure', NULL, NULL, 0, 0, '<p>Vous touchez physiquement une créature consentante pour forger un lien magique entre elle et vous jusqu''à la fin du sort. Tant que la cible se trouve dans un rayon de 18 m de vous, elle reçoit un bonus de +1 à la CA et aux jets de sauvegarde, et bénéficie de la Résistance à tous les dégâts. Par ailleurs, chaque fois qu''elle subit des dégâts, vous en subissez autant.</p>
<p>Le sort prend fin si vous tombez à 0 point de vie ou si la cible et vous vous retrouvez distants de plus de 18 m. Il prend également fin s''il est relancé sur l''une des deux créatures ainsi liées.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7763, 2274, 54, 2),
  (7764, 2274, 59, 2);

-- [2275] Lien télépathique (niv 5, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2275, 'Lien télépathique', 5, 7, NULL, 1, 1, 1, 0, 0, 'deux œufs', '9 m', '', '', 'action ou rituel', '1 heure', NULL, NULL, 0, 1, '<p>Vous forgez un lien télépathique entre un maximum de huit créatures consentantes que vous choisissez à portée, chacune se retrouvant en relation psychique avec toutes les autres pour toute la durée. Les créatures incapables de communiquer par le biais d''une langue ne sont pas affectées par ce sort.</p>
<p>Jusqu''à la fin du sort, les cibles peuvent communiquer par télépathie via le lien psychique, qu''elles parlent ou non une même langue. La communication, possible quelle que soit la distance, ne s''étend toutefois pas d''un plan d''existence à l''autre.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7765, 2275, 53, 5),
  (7766, 2275, 52, 5);

-- [2276] Localisation d'animaux ou de plantes (niv 2, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2276, 'Localisation d''animaux ou de plantes', 2, 7, NULL, 1, 1, 1, 0, 0, 'une touffe de poils de limier', 'personnelle', '', '', 'action ou rituel', 'instantanée', NULL, NULL, 0, 1, '<p>Décrivez ou nommez une sorte de créature de type Bête ou Plante, ou une plante non magique. Vous savez alors dans quelle direction et à quelle distance se trouve, le cas échéant, la créature ou la plante de cette sorte la plus proche dans un rayon de 7,5 km.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7767, 2276, 53, 2),
  (7768, 2276, 55, 2),
  (7769, 2276, 60, 2);

-- [2277] Localisation d'objet (niv 2, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2277, 'Localisation d''objet', 2, 7, NULL, 1, 1, 1, 0, 0, 'une brindille fourchue', 'personnelle', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Décrivez ou nommez un objet qui vous est familier. Vous percevez dans quelle direction l''objet se trouve, à condition qu''il soit situé dans un rayon de 300 m. Si l''objet est en mouvement, vous savez dans quelle direction il se déplace.</p>
<p>Le sort peut localiser un objet donné que vous connaissez, à condition que vous l''ayez déjà vu de près (9 m ou moins). Une autre option vous permet de localiser l''objet d''une certaine catégorie le plus proche, en mentionnant par exemple un certain genre de vêtement, de bijou, de meuble, d''outil ou d''arme.</p>
<p>Ce sort ne trouve pas l''objet si la moindre épaisseur de plomb vous en sépare.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7770, 2277, 53, 2),
  (7771, 2277, 54, 2),
  (7772, 2277, 55, 2),
  (7773, 2277, 52, 2),
  (7774, 2277, 59, 2),
  (7775, 2277, 60, 2);

-- [2278] Localisation de créature (niv 4, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2278, 'Localisation de créature', 4, 7, NULL, 1, 1, 1, 0, 0, 'une touffe de poils de limier', 'personnelle', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Décrivez ou nommez une créature qui vous est familière. Vous percevez dans quelle direction la créature se trouve, à condition qu''elle soit située dans un rayon de 300 m. Si la créature se déplace, vous savez dans quelle direction.</p>
<p>Le sort peut localiser une créature donnée que vous connaissez ou la créature d''une certaine catégorie la plus proche, à condition que vous ayez déjà vu une telle créature de près (9 m ou moins). Si la créature décrite ou nommée se trouve sous une forme différente (sous les effets du sort métamorphose, par exemple), le sort ne parvient pas à la localiser.</p>
<p>Ce sort ne trouve pas davantage la créature si la moindre épaisseur de plomb vous sépare d''elle.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7776, 2278, 53, 4),
  (7777, 2278, 54, 4),
  (7778, 2278, 55, 4),
  (7779, 2278, 52, 4),
  (7780, 2278, 59, 4),
  (7781, 2278, 60, 4);

-- [2279] Lueur d'espoir (niv 3, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2279, 'Lueur d''espoir', 3, 5, NULL, 1, 1, 0, 0, 0, NULL, '9 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Choisissez autant de créatures que vous le souhaitez à portée. Pour toute la durée, chaque cible a l''Avantage aux jets de sauvegarde de Sagesse et aux jets de sauvegarde contre la mort, et récupère le maximum possible de points de vie chaque fois qu''on la soigne.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7782, 2279, 54, 3);

-- [2280] Lueurs féeriques (niv 1, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2280, 'Lueurs féeriques', 1, 1, NULL, 1, 0, 0, 0, 0, NULL, '18 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Le contour des objets compris dans un Cube de 6 m à portée luit de bleu, de vert ou de violet, à votre convenance. Chaque créature prise dans le Cube est elle aussi nimbée si elle rate un jet de sauvegarde de Dextérité. Pour toute la durée, les objets et les créatures affectées projettent une Lumière faible sur un rayon de 3 m, et ne peuvent bénéficier de l''état Invisible.</p>
<p>Les jets d''attaque contre une créature ou un objet affectés ont l''Avantage si l''assaillant voit la cible.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7783, 2280, 53, 1),
  (7784, 2280, 55, 1);

-- [2281] Lumière (niv 0, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2281, 'Lumière', 0, 1, NULL, 1, 0, 1, 0, 0, 'une luciole ou de la mousse phosphorescente', 'contact', '', '', 'action', '1 heure', NULL, NULL, 0, 0, '<p>Vous touchez physiquement un objet de taille G ou inférieure qui n''est porté par personne d''autre. Jusqu''à la fin du sort, l''objet produit une Lumière vive sur un rayon de 6 m et une Lumière faible sur 6 m de plus. La lumière peut présenter les teintes de votre choix.</p>
<p>Recouvrir l''objet d''une surface opaque bloque la lumière. Le sort prend fin si vous le relancez.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7785, 2281, 53, 0),
  (7786, 2281, 54, 0),
  (7787, 2281, 56, 0),
  (7788, 2281, 52, 0);

-- [2282] Lumière du jour (niv 3, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2282, 'Lumière du jour', 3, 1, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', '1 heure', NULL, NULL, 0, 0, '<p>Pour toute la durée, la lumière du soleil rayonne depuis un point à portée en emplissant une Sphère de 18 m de rayon. La Sphère constitue une zone de Lumière vive et produit une Lumière faible sur 18 m de plus.</p>
<p>Au lieu de cela, vous pouvez lancer le sort sur un objet porté par personne, de manière à ce que les rayons du soleil emplissent une Émanation de 18 m centrée sur l''objet. Il suffit de recouvrir cet objet d''une surface opaque pour bloquer la lumière du soleil.</p>
<p>Si tout ou partie de ce sort chevauche la zone de Ténèbres créée par un sort du 3e niveau ou inférieur, cet autre sort est dissipé.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7789, 2282, 54, 3),
  (7790, 2282, 55, 3),
  (7791, 2282, 56, 3),
  (7792, 2282, 59, 3),
  (7793, 2282, 60, 3);

-- [2283] Lumières dansantes (niv 0, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2283, 'Lumières dansantes', 0, 9, NULL, 1, 1, 1, 0, 0, 'un peu de phosphore', '36 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous créez jusqu''à quatre lumières de la taille d''une torche, à portée ; pour toute la durée, elles ont l''aspect de torches, de lanternes ou de globes luisants qui flottent dans les airs. Au lieu de cela, vous pouvez fusionner les quatre lumières en forme luisante vaguement humaine, de taille M. Quelle que soit la forme choisie, chaque lueur émet une Lumière faible dans un rayon de 3 m.</p>
<p>Par une action Bonus, vous pouvez déplacer les lueurs d''un maximum de 18 m vers un nouvel espace à portée. Chaque lueur du sort, à sa création, doit se situer dans un rayon de 6 m d''une autre, et s''évanouit si jamais elle quitte la portée du sort.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7794, 2283, 53, 0),
  (7795, 2283, 56, 0),
  (7796, 2283, 52, 0);

-- [2284] Main arcanique (niv 5, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2284, 'Main arcanique', 5, 1, NULL, 1, 1, 1, 0, 0, 'une coquille d''œuf et un gant', '36 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous créez une main de taille G faite d''énergies magiques chatoyantes. Elle apparaît dans un espace inoccupé que vous voyez à portée. La main persiste pendant toute la durée et se déplace sous votre contrôle. La main est un objet doté d''une CA de 20 et de points de vie égaux à votre maximum de points de vie. S''il tombe à 0 point de vie, le sort prend fin. La main n''occupe pas son espace.</p>
<p>À l''incantation du sort, ainsi que par une action Bonus à vos tours suivants, vous pouvez déplacer la main d''un maximum de 18 m puis lui faire produire l''un des effets suivants :</p>
<p>Main agrippeuse. La main tente d''agripper une créature de taille TG ou inférieure dans un rayon de 1,50 m d''elle. La cible doit réussir un jet de sauvegarde de Dextérité sous peine de subir l''état Agrippé, le DD d''évasion étant égal à votre DD de sauvegarde des sorts. Tant que la main agrippe la cible, vous pouvez entreprendre une action Bonus pour que la main la broie et lui inflige 4d6 dégâts contondants plus votre modificateur de caractéristique d''incantation.</p>
<p>Main impérieuse. La main tente de pousser une créature de taille TG ou inférieure dans un rayon de 1,50 m d''elle. La cible doit réussir un jet de sauvegarde de Force, sans quoi la main la repousse d''un maximum de 1,50 m, plus 1,50 m multiplié par votre modificateur de caractéristique d''incantation.</p>
<p>Main interposée. La main vous octroie un Abri partiel contre les attaques et effets émanant de son espace ou qui le traversent. De plus, son espace est considéré comme un Terrain difficile pour vos ennemis.</p>
<p>Poing serré. La main frappe une cible dans un rayon de 1,50 m d''elle. Effectuez une attaque de sort au corps à corps. Si l''attaque touche, la cible subit 5d8 dégâts de force.</p>
<p>Emplacement de niveau supérieur. Les dégâts de l''option poing serré augmentent de 2d8 et ceux de main agrippeuse de 2d6 par niveau d''emplacement au-delà du 5e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7797, 2284, 56, 5),
  (7798, 2284, 52, 5);

-- [2285] Main du mage (niv 0, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2285, 'Main du mage', 0, 6, NULL, 1, 1, 0, 0, 0, NULL, '9 m', '', '', 'action', '1 minute', NULL, NULL, 0, 0, '<p>Une main spectrale et flottante apparaît en un point que vous choisissez à portée. La main persiste pour toute la durée. Elle disparaît si jamais elle se retrouve à plus de 9 m de vous ou si vous relancez ce sort.</p>
<p>À l''incantation du sort, la main peut servir à manipuler un objet, à ouvrir une porte ou un récipient non verrouillés, à ranger ou récupérer un objet dans un conteneur ouvert ou à déverser le contenu d''une fiole.</p>
<p>Au prix de l''action Magie à vos tours suivants, vous pouvez de nouveau contrôler ainsi la main, et la déplacer d''un maximum de 9 m. Elle ne peut ni attaquer, ni activer d''objet magique, ni porter plus de 5 kg.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7799, 2285, 53, 0),
  (7800, 2285, 56, 0),
  (7801, 2285, 52, 0),
  (7802, 2285, 58, 0);

-- [2286] Mains brûlantes (niv 1, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2286, 'Mains brûlantes', 1, 1, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Une fine nappe de flammes jaillit de vous. Chaque créature prise dans un Cône de 4,50 m effectue un jet de sauvegarde de Dextérité et subit 3d6 dégâts de feu en cas d''échec, la moitié en cas de réussite.</p>
<p>Les objets inflammables pris dans le Cône s''embrasent s''ils ne sont portés par personne.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d6 par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7803, 2286, 56, 1),
  (7804, 2286, 52, 1);

-- [2287] Malédiction (niv 3, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2287, 'Malédiction', 3, 2, NULL, 1, 1, 0, 0, 0, NULL, 'contact', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous touchez physiquement une créature, qui doit réussir un jet de sauvegarde de Sagesse sous peine d''être maudite pour toute la durée. Jusqu''à la fin de la malédiction, la cible subit l''un des effets suivants, à votre convenance :<br>
• Choisissez une caractéristique. La cible a le Désavantage aux tests de caractéristique et jets de sauvegarde associés à cette caractéristique.<br>
• La cible a le Désavantage aux jets d''attaque contre vous.<br>
• Au combat, la cible doit réussir un jet de sauvegarde de Sagesse au début de chacun de ses tours sous peine de devoir entreprendre l''action Esquive à ce tour.<br>
• Si vous infligez des dégâts à la cible par un jet d''attaque ou un sort, elle subit 1d8 dégâts nécrotiques supplémentaires.</p>
<p>Emplacement de niveau supérieur. Avec un emplacement du 4e niveau, la Concentration peut durer jusqu''à 10 minutes. Avec un emplacement du 5e niveau ou supérieur, le sort ne requiert pas de Concentration (durée : 8 heures au 5e-6e, 24 heures au 7e-8e, jusqu''à dissipation au 9e).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7805, 2287, 53, 3),
  (7806, 2287, 54, 3),
  (7807, 2287, 52, 3);

-- [2288] Maléfice (niv 1, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2288, 'Maléfice', 1, 3, NULL, 1, 1, 1, 0, 0, 'un œil pétrifié de triton', '27 m', '', '', 'action Bonus', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Vous maudissez une créature que vous voyez à portée. Jusqu''à la fin du sort, vous infligez 1d6 dégâts nécrotiques supplémentaires à la cible chaque fois que vous la touchez avec un jet d''attaque. Vous désignez également une caractéristique à l''incantation. La cible subit le Désavantage aux tests de caractéristique associés à la caractéristique en question.</p>
<p>Si la cible tombe à 0 point de vie avant la fin du sort, vous pouvez désigner une nouvelle cible à l''un de vos tours suivants, par une action Bonus.</p>
<p>Emplacement de niveau supérieur. Votre Concentration peut persister plus longtemps avec un emplacement du 2e niveau (jusqu''à 4 heures), du 3e ou 4e (jusqu''à 8 heures), ou du 5e et supérieur (24 heures).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7808, 2288, 58, 1);

-- [2289] Manoir somptueux (niv 7, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2289, 'Manoir somptueux', 7, 6, NULL, 1, 1, 1, 0, 0, 'une porte miniature d''une valeur minimale de 15 po', '90 m', '', '', '1 minute', '24 heures', NULL, NULL, 0, 0, '<p>Vous invoquez une porte chatoyante à portée, qui persiste pour toute la durée. La porte, large de 1,50 m et haute de 3 m, ouvre sur une demeure extradimensionnelle. Vous et toute créature que vous désignez à l''incantation du sort pouvez pénétrer dans cette demeure tant que la porte reste ouverte. Vous pouvez l''ouvrir ou la refermer (pas d''action requise) si vous vous trouvez dans un rayon de 9 m d''elle. Tant qu''elle est fermée, on ne peut pas la percevoir.</p>
<p>La configuration des étages est laissée à votre discrétion, mais l''espace total ne peut excéder l''équivalent de 50 Cubes contigus de 3 m. La demeure est meublée et décorée selon vos désirs. Elle renferme suffisamment de nourriture pour servir un banquet de neuf plats pour 100 convives. Les meubles et autres objets créés par ce sort se dissipent en fumée si on les sort du manoir.</p>
<p>100 serviteurs quasi transparents accueillent les invités. Invulnérables, ils obéissent à vos ordres et peuvent accomplir toute tâche à la portée d''un humain, mais ils ne peuvent ni attaquer ni entreprendre d''action qui pourrait nuire directement à une autre créature. Les domestiques ne peuvent pas quitter la demeure.</p>
<p>Quand le sort prend fin, tous les objets et créatures qui occupent son espace extradimensionnel sont renvoyés dans les espaces inoccupés les plus proches de l''entrée.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7809, 2289, 53, 7),
  (7810, 2289, 52, 7);

-- [2290] Marche sur l'onde (niv 3, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2290, 'Marche sur l''onde', 3, 4, NULL, 1, 1, 1, 0, 0, 'un morceau de liège', '9 m', '', '', 'action ou rituel', '1 heure', NULL, NULL, 0, 1, '<p>Ce sort octroie la faculté de se déplacer sur n''importe quelle surface liquide (eau, acide, boue, neige, sables mouvants et même lave) comme s''il s''agissait d''une surface solide ne présentant aucun risque (sur de la lave, les créatures s''exposent tout de même aux dégâts que peut engendrer la chaleur). Un maximum de dix créatures consentantes que vous choisissez à portée reçoivent cette faculté pour toute la durée.</p>
<p>Une cible affectée peut entreprendre une action Bonus pour s''immerger dans le liquide alors qu''elle est à sa surface, ou vice-versa, mais une cible qui tombe dans le liquide en traverse la surface et se retrouve immergée.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7811, 2290, 54, 3),
  (7812, 2290, 55, 3),
  (7813, 2290, 56, 3),
  (7814, 2290, 60, 3);

-- [2291] Marque du chasseur (niv 1, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2291, 'Marque du chasseur', 1, 7, NULL, 1, 0, 0, 0, 0, NULL, '27 m', '', '', 'action Bonus', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Vous désignez magiquement une créature que vous voyez à portée comme votre proie. Jusqu''à la fin du sort, vous infligez 1d6 dégâts de force à la cible chaque fois que vous la touchez avec un jet d''attaque. Vous avez aussi l''Avantage aux tests de Sagesse (Perception ou Survie) visant à la trouver.</p>
<p>Si la cible tombe à 0 point de vie avant la fin du sort, vous pouvez par une action Bonus déplacer la marque vers une autre créature que vous voyez à portée.</p>
<p>Emplacement de niveau supérieur. Votre Concentration peut persister plus longtemps avec un emplacement du 3e ou 4e niveau (jusqu''à 8 heures), ou du 5e et supérieur (24 heures).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7815, 2291, 60, 1);

-- [2292] Mauvais œil (niv 6, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2292, 'Mauvais œil', 6, 2, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Pour toute la durée, vos yeux sont d''un noir d''encre. Une créature que vous choisissez parmi celles que vous voyez dans un rayon de 18 m doit réussir un jet de sauvegarde de Sagesse pour ne pas être affectée par l''un des effets suivants de votre choix, pour toute la durée. À chacun de vos tours jusqu''à la fin du sort, vous pouvez entreprendre l''action Magie à cibler une autre créature, sans toutefois pouvoir choisir une créature qui a réussi son JS contre cette incantation.</p>
<p>Endormie. La cible subit l''état Inconscient. Elle reprend conscience si elle subit des dégâts ou si une autre créature consacre une action à la secouer.</p>
<p>Nauséeuse. La cible subit l''état Empoisonné.</p>
<p>Paniquée. La cible subit l''état Effrayé. Ainsi Effrayée, la cible doit à chacun de ses tours entreprendre l''action Pointe et s''éloigner de vous par le chemin le plus sûr et le plus court. Si la cible atteint un espace distant de plus de 18 m de vous d''où elle ne vous voit plus, cet effet prend fin.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7816, 2292, 53, 6),
  (7817, 2292, 56, 6),
  (7818, 2292, 52, 6),
  (7819, 2292, 58, 6);

-- [2293] Message (niv 0, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2293, 'Message', 0, 4, NULL, 0, 1, 1, 0, 0, 'du fil de cuivre', '36 m', '', '', 'action', '1 round', NULL, NULL, 0, 0, '<p>Vous pointez le doigt vers une créature à portée et murmurez un message. La cible (et seulement elle) entend votre message et peut y répondre par un murmure audible de votre seule personne.</p>
<p>Vous pouvez lancer ce sort à travers des objets solides si vous connaissez la cible et savez qu''elle se trouve derrière ces obstacles. Le silence magique, 30 cm de pierre, de métal ou de bois, ou une simple feuille de plomb suffisent à bloquer le sort.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7820, 2293, 53, 0),
  (7821, 2293, 55, 0),
  (7822, 2293, 56, 0),
  (7823, 2293, 52, 0);

-- [2294] Messager animal (niv 2, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2294, 'Messager animal', 2, 3, NULL, 1, 1, 1, 0, 0, 'un peu de nourriture', '9 m', '', '', 'action ou rituel', '24 heures', NULL, NULL, 0, 1, '<p>La Bête de taille TP de votre choix parmi celles que vous voyez à portée doit réussir un jet de sauvegarde de Charisme, sans quoi elle s''efforce de livrer le message que vous lui confiez (si son facteur de puissance n''est pas 0, elle réussit automatiquement). Vous spécifiez un lieu que vous avez déjà visité et un destinataire qui correspond à une description générale. Vous lui communiquez de plus un message limité à vingt-cinq mots. La Bête voyage vers le lieu spécifié tant que le sort est actif, ce qui lui permet de parcourir 75 km en 24 heures dans le cas d''un animal volant, 37,5 km sinon.</p>
<p>Quand la Bête arrive à destination, elle livre votre message à la créature décrite, en imitant votre manière de communiquer. Si elle ne parvient pas à destination avant la fin du sort, le message est perdu et la Bête revient à l''endroit de l''incantation.</p>
<p>Emplacement de niveau supérieur. La durée augmente de 48 heures par niveau d''emplacement au-delà du 2e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7824, 2294, 53, 2),
  (7825, 2294, 55, 2),
  (7826, 2294, 60, 2);

-- [2295] Métal brûlant (niv 2, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2295, 'Métal brûlant', 2, 4, NULL, 1, 1, 1, 0, 0, 'un bout de fer et une flamme', '18 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Choisissez un objet manufacturé en métal, tel qu''une arme, ou une armure métallique intermédiaire ou lourde, que vous voyez à portée. Vous faites chauffer l''objet au rouge incandescent. Toute créature en contact physique avec l''objet subit 2d8 dégâts de feu à l''incantation du sort. Jusqu''à la fin du sort, vous pouvez appliquer de nouveau ces dégâts par une action Bonus à chacun de vos tours suivants, à condition que l''objet soit à portée.</p>
<p>Une créature qui tient un tel objet ou en est vêtue et qui subit les dégâts correspondants doit réussir un jet de sauvegarde de Constitution sous peine de lâcher l''objet (si elle en a la possibilité). Si elle ne peut pas le lâcher, elle a le Désavantage à ses jets d''attaque et tests de caractéristique jusqu''au début de votre tour suivant.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d8 par niveau d''emplacement au-delà du 2e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7827, 2295, 53, 2),
  (7828, 2295, 55, 2);

-- [2296] Métamorphose (niv 4, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2296, 'Métamorphose', 4, 4, NULL, 1, 1, 1, 0, 0, 'une chrysalide', '18 m', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Vous tentez de transformer en Bête une créature que vous voyez à portée. La cible doit réussir un jet de sauvegarde de Sagesse sous peine d''être métamorphosée en Bête pour toute la durée. Cette forme est une Bête de votre choix dont le facteur de puissance est inférieur ou égal à celui de la cible (ou à son niveau, si elle n''a pas de FP). Le profil de la cible est remplacé par celui de la Bête retenue, si ce n''est que la cible conserve son alignement, sa personnalité, son type de créature, ses points de vie et ses dés de vie.</p>
<p>La cible reçoit autant de points de vie temporaires que les points de vie de sa forme de Bête. Ces points de vie temporaires disparaissent s''il lui en reste à la fin du sort. Le sort prend fin prématurément sur la cible s''il ne lui reste plus de points de vie temporaires.</p>
<p>La cible est limitée dans les actions qu''elle peut entreprendre par l''anatomie de sa nouvelle forme, et elle ne peut ni parler ni lancer de sorts. L''équipement porté par la cible se fond dans sa nouvelle forme.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7829, 2296, 53, 4),
  (7830, 2296, 55, 4),
  (7831, 2296, 56, 4),
  (7832, 2296, 52, 4);

-- [2297] Métamorphose animale (niv 8, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2297, 'Métamorphose animale', 8, 4, NULL, 1, 1, 0, 0, 0, NULL, '9 m', '', '', 'action', '24 heures', NULL, NULL, 0, 0, '<p>Choisissez autant de créatures consentantes que vous souhaitez, parmi celles que vous voyez à portée. Chaque cible se transforme en Bête de taille G ou inférieure de votre choix, dont le facteur de puissance ne dépasse pas 4. Vous pouvez opter pour une forme différente pour chaque cible. Aux tours suivants, vous pouvez entreprendre l''action Magie pour de nouveau transformer les cibles.</p>
<p>Le profil de jeu de chaque cible est remplacé par celui de la Bête choisie, à l''exception de son type de créature, de ses points de vie et dés de vie, de sa faculté de communication, de son alignement et de ses valeurs d''Intelligence, Sagesse et Charisme, qui restent les siens. Les actions de la cible sont limitées par l''anatomie de la Bête retenue et elle ne peut pas lancer de sorts. L''équipement porté par la cible se fond dans sa nouvelle forme.</p>
<p>La cible reçoit autant de points de vie temporaires que les points de vie de la première forme adoptée. Ces points de vie temporaires disparaissent s''il en reste à la fin du sort. La transformation persiste pour toute la durée, sauf si la cible y met un terme par une action Bonus.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7833, 2297, 55, 8);

-- [2298] Métamorphose suprême (niv 9, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2298, 'Métamorphose suprême', 9, 4, NULL, 1, 1, 1, 0, 0, 'une goutte de mercure, un bon morceau de gomme arabique et une volute de fumée', '9 m', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Choisissez une créature ou un objet non magique que vous voyez à portée. La créature se métamorphose en une autre créature ou en objet non magique, ou l''objet se transforme en créature. La transformation persiste pour toute la durée, sauf si la cible meurt ou est détruite. Toutefois, si vous maintenez votre Concentration pour la totalité de la durée du sort, celui-ci persiste jusqu''à dissipation. Une créature non consentante peut effectuer un jet de sauvegarde de Sagesse. En cas de réussite, elle n''est pas affectée par le sort.</p>
<p>Créature en créature. Si vous transformez une créature en autre sorte de créature, vous choisissez sa nouvelle forme à votre guise, mais le facteur de puissance de celle-ci ne doit pas dépasser celui de la cible (ou son niveau). Le profil de la cible est remplacé par celui de la nouvelle forme, si ce n''est qu''elle conserve ses points de vie, ses dés de vie, son alignement et sa personnalité. La cible reçoit autant de points de vie temporaires que les points de vie de la nouvelle forme. La cible ne peut ni parler ni lancer de sorts. L''équipement porté se fond dans la nouvelle forme.</p>
<p>Objet en créature. Vous pouvez transformer un objet en la créature de votre choix, à condition que la catégorie de taille de celle-ci ne dépasse pas celle de l''objet et que son facteur de puissance n''excède pas 9. La créature est Amicale envers vous et vos compagnons. Si le sort persiste plus d''une heure, vous perdez le contrôle de la créature.</p>
<p>Créature en objet. Si vous transformez une créature en objet, elle adopte sa nouvelle forme en fusionnant avec tout ce qu''elle porte, à condition que la taille de l''objet n''excède pas celle de la créature. Le profil de la créature devient celui de l''objet. La créature ne garde aucun souvenir du temps passé sous cette forme après la fin du sort.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7834, 2298, 53, 9),
  (7835, 2298, 52, 9),
  (7836, 2298, 58, 9);

-- [2299] Mirage (niv 7, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2299, 'Mirage', 7, 9, NULL, 1, 1, 0, 0, 0, NULL, 'champ de vision', '', '', '10 minutes', '10 jours', NULL, NULL, 0, 0, '<p>Vous faites en sorte que l''environnement d''une zone carrée de 1,5 km de côté apparaisse différemment sur tous les plans sensoriels. Ainsi, un champ ou une route pourrait se présenter comme un marais, une colline, une crevasse glaciaire ou quelque autre environnement accidenté ou infranchissable.</p>
<p>De même, vous pouvez altérer l''aspect des bâtiments ou en ajouter là où il n''y en a pas. Le sort ne permet pas de déguiser ni de cacher des créatures, ni d''en ajouter.</p>
<p>L''illusion comprend des éléments auditifs, visuels, tactiles et olfactifs, si bien qu''un sol dégagé peut être transformé en Terrain difficile (et vice versa) ou gêner les déplacements dans la zone. Tout élément du terrain illusoire retiré de la zone du sort disparaît aussitôt.</p>
<p>Les créatures dotées de la Vision lucide percent l''illusion et perçoivent le véritable environnement. Tous les autres éléments de l''illusion restent toutefois en place.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7837, 2299, 53, 7),
  (7838, 2299, 55, 7),
  (7839, 2299, 52, 7);

-- [2300] Modification d'apparence (niv 2, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2300, 'Modification d''apparence', 2, 4, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Vous altérez votre forme physique. Choisissez l''une des options suivantes. Les effets persistent pour toute la durée, durant laquelle vous pouvez entreprendre l''action Magie pour changer d''option.</p>
<p>Adaptation aquatique. Vous vous dotez de branchies et vos doigts deviennent palmés. Vous recevez une Vitesse de nage égale à votre Vitesse et pouvez respirer sous l''eau.</p>
<p>Armes naturelles. Vous vous dotez de griffes (tranchants), de crocs (perforants), de cornes (perforants) ou de sabots (contondants). Ces attaques à mains nues infligent 1d6 dégâts du type indiqué et vous ajoutez votre modificateur de caractéristique d''incantation aux jets d''attaque et de dégâts, au lieu de recourir à la Force.</p>
<p>Changement d''aspect. Vous transformez votre aspect. Vous décidez de votre apparence, notamment de votre taille, votre poids, les traits de votre visage, le timbre de votre voix, la longueur de vos cheveux, votre teint et autres attributs. Vous pouvez vous faire passer pour un membre d''une autre espèce, mais cela n''influe pas sur votre profil de jeu. Vous ne pouvez pas prendre l''aspect d''une créature dont la catégorie de taille est différente de la vôtre.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7840, 2300, 56, 2),
  (7841, 2300, 52, 2);

-- [2301] Modification de mémoire (niv 5, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2301, 'Modification de mémoire', 5, 3, NULL, 1, 1, 0, 0, 0, NULL, '9 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous tentez de remodeler les souvenirs d''une autre créature. Une créature que vous voyez à portée effectue un jet de sauvegarde de Sagesse. Si vous êtes en train de l''affronter, elle a l''Avantage au JS. En cas d''échec, la cible subit l''état Charmé pour toute la durée. Ainsi Charmée, la cible subit aussi l''état Neutralisé et n''a pas conscience de son environnement, mais elle vous entend toujours. Si elle subit des dégâts ou est la cible d''un autre sort, cette modification de mémoire prend fin et nul souvenir n''est altéré.</p>
<p>Tant que persiste ce charme, vous pouvez influer sur un souvenir de la cible ayant eu lieu au cours des 24 dernières heures et ne s''étalant pas sur plus de 10 minutes. Vous pouvez effacer toute mémoire de l''événement, permettre à la cible de s''en souvenir parfaitement, altérer certains éléments qui y sont liés dans son esprit ou créer de toutes pièces le souvenir d''un autre événement.</p>
<p>Vous devez parler à la cible pour lui décrire en quoi sa mémoire est modifiée, sachant qu''elle doit comprendre la langue employée pour que le souvenir s''enracine. L''altération prend effet quand le sort se termine.</p>
<p>Le sort délivrance des malédictions ou restauration suprême lancé sur la cible lui rend sa mémoire d''origine.</p>
<p>Emplacement de niveau supérieur. Vous pouvez altérer le souvenir d''un événement qui remonte à un maximum de 7 jours (6e niveau), 30 jours (7e), 365 jours (8e) ou à tout moment de son passé (9e).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7842, 2301, 53, 5),
  (7843, 2301, 52, 5);

-- [2302] Monture fantôme (niv 3, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2302, 'Monture fantôme', 3, 9, NULL, 1, 1, 0, 0, 0, NULL, '9 m', '', '', '1 minute ou rituel', '1 heure', NULL, NULL, 0, 1, '<p>Une créature chevaline quasi réelle de taille G se manifeste au sol en un espace inoccupé que vous choisissez à portée. Vous décidez de son apparence, sachant qu''elle est équipée d''une selle, de mors et d''une bride. Tout l''équipement créé par le sort disparaît dans une bouffée de fumée si on l''éloigne de plus de 3 m de la monture.</p>
<p>Pour toute la durée, vous ou une créature que vous désignez pouvez chevaucher la monture. Elle reprend le profil du cheval de selle, si ce n''est que sa Vitesse est de 30 m et qu''elle peut couvrir 19,5 km en une heure. Quand le sort prend fin, la monture s''efface progressivement en laissant à son cavalier 1 minute pour en descendre. Le sort prend fin prématurément si la monture subit le moindre dégât.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7844, 2302, 52, 3);

-- [2303] Moquerie cruelle (niv 0, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2303, 'Moquerie cruelle', 0, 3, NULL, 1, 0, 0, 0, 0, NULL, '18 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous adressez un chapelet d''insultes assaisonnées de subtils enchantements à une créature que vous voyez ou entendez à portée. La cible doit réussir un jet de sauvegarde de Sagesse sous peine de subir 1d6 dégâts psychiques, ainsi que le Désavantage à son prochain jet d''attaque intervenant avant la fin de son tour suivant.</p>
<p>Amélioration de sort mineur. Les dégâts augmentent de 1d6 lorsque vous atteignez les niveaux 5 (2d6), 11 (3d6) et 17 (4d6).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7845, 2303, 53, 0);

-- [2304] Mot de guérison (niv 1, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2304, 'Mot de guérison', 1, 5, NULL, 1, 0, 0, 0, 0, NULL, '18 m', '', '', 'action Bonus', 'instantanée', NULL, NULL, 0, 0, '<p>La créature de votre choix parmi celles que vous voyez à portée récupère des points de vie : 2d4 + votre modificateur de caractéristique d''incantation.</p>
<p>Emplacement de niveau supérieur. Les soins augmentent de 2d4 par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7846, 2304, 53, 1),
  (7847, 2304, 54, 1),
  (7848, 2304, 55, 1);

-- [2305] Mot de guérison de groupe (niv 3, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2305, 'Mot de guérison de groupe', 3, 5, NULL, 1, 0, 0, 0, 0, NULL, '18 m', '', '', 'action Bonus', 'instantanée', NULL, NULL, 0, 0, '<p>Un maximum de six créatures de votre choix parmi celles que vous voyez à portée récupèrent des points de vie : 2d4 + votre modificateur de caractéristique d''incantation.</p>
<p>Emplacement de niveau supérieur. Les soins augmentent de 1d4 par niveau d''emplacement au-delà du 3e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7849, 2305, 53, 3),
  (7850, 2305, 54, 3);

-- [2306] Mot de pouvoir étourdissant (niv 8, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2306, 'Mot de pouvoir étourdissant', 8, 3, NULL, 1, 0, 0, 0, 0, NULL, '18 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous assaillez l''esprit d''une créature que vous voyez à portée. Si la cible choisie est dotée de 150 points de vie ou moins, elle subit l''état Étourdi. Dans le cas contraire, sa Vitesse tombe à 0 jusqu''au début de votre tour suivant.</p>
<p>La cible Étourdie effectue un jet de sauvegarde de Constitution à la fin de chacun de ses tours et met un terme à cet état en cas de réussite.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7851, 2306, 53, 8),
  (7852, 2306, 56, 8),
  (7853, 2306, 52, 8),
  (7854, 2306, 58, 8);

-- [2307] Mot de pouvoir guérisseur (niv 9, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2307, 'Mot de pouvoir guérisseur', 9, 3, NULL, 1, 0, 0, 0, 0, NULL, '18 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Une vague d''énergies de guérison baigne une créature que vous voyez à portée. La cible récupère tous ses points de vie. Si la créature a l''état Charmé, Effrayé, Empoisonné, Étourdi ou Paralysé, cet état prend fin. Si la créature a l''état À terre, elle peut jouer sa Réaction pour se relever.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7855, 2307, 53, 9),
  (7856, 2307, 54, 9);

-- [2308] Mot de pouvoir mortel (niv 9, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2308, 'Mot de pouvoir mortel', 9, 3, NULL, 1, 0, 0, 0, 0, NULL, '18 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>La mort s''impose à une créature que vous voyez à portée. Si la cible choisie est dotée de 100 points de vie ou moins, elle meurt. Dans le cas contraire, elle subit 12d12 dégâts psychiques.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7857, 2308, 53, 9),
  (7858, 2308, 56, 9),
  (7859, 2308, 52, 9),
  (7860, 2308, 58, 9);

-- [2309] Mot de retour (niv 6, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2309, 'Mot de retour', 6, 6, NULL, 1, 0, 0, 0, 0, NULL, '1,50 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous-même et un maximum de cinq créatures consentantes situées dans un rayon de 1,50 m vous téléportez en un sanctuaire désigné à l''avance. Vous et les créatures téléportées apparaissez dans les espaces inoccupés les plus proches du point désigné quand vous avez préparé votre sanctuaire.</p>
<p>Si vous lancez ce sort sans avoir préparé de sanctuaire, il est sans effet. Le sanctuaire se désigne au préalable en lançant ce sort en un lieu, tel qu''un temple.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7861, 2309, 54, 6);

-- [2310] Motif hypnotique (niv 3, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2310, 'Motif hypnotique', 3, 9, NULL, 0, 1, 1, 0, 0, 'une pincée de confettis', '36 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous créez un motif animé de couleurs occupant un Cube de 9 m à portée. Le motif apparaît un instant et disparaît aussitôt. Chaque créature prise dans la zone, si elle voit le motif, doit réussir un jet de sauvegarde de Sagesse sous peine de subir l''état Charmé pour toute la durée du sort. Tant qu''elle est ainsi Charmée, la créature subit l''état Neutralisé et sa Vitesse est de 0.</p>
<p>Le sort prend fin pour une créature affectée si elle subit des dégâts ou si quelqu''un d''autre consacre une action à la sortir de son hébétude.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7862, 2310, 53, 3),
  (7863, 2310, 56, 3),
  (7864, 2310, 52, 3),
  (7865, 2310, 58, 3);

-- [2311] Mur d'épines (niv 6, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2311, 'Mur d''épines', 6, 6, NULL, 1, 1, 1, 0, 0, 'une poignée d''épines', '36 m', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Vous créez un mur fait d''un enchevêtrement végétal hérissé d''épines acérées. Le mur apparaît à portée sur une surface solide et persiste pour toute la durée. Vous pouvez ainsi ériger un mur dont l''épaisseur n''excède pas 1,50 m ; pour le reste, vous avez le choix entre un mur droit long d''un maximum de 18 m et haut de 3 m ou moins, et un mur circulaire dont le diamètre et la hauteur ne dépassent pas 6 m. Le mur bloque le champ de vision.</p>
<p>Quand le mur apparaît, chaque créature prise dans sa zone effectue un jet de sauvegarde de Dextérité et subit 7d8 dégâts perforants en cas d''échec, la moitié en cas de réussite.</p>
<p>Une créature peut se déplacer à travers ces ronces, mais toute distance parcourue à travers le mur lui coûte le quadruple en termes de déplacement. De plus, la première fois d''un tour qu''une créature pénètre dans la haie ou qu''elle y termine son propre tour, elle effectue un jet de sauvegarde de Dextérité et subit 7d8 dégâts tranchants en cas d''échec, la moitié en cas de réussite. Une même créature n''effectue en aucun cas ce JS plus d''une fois par tour.</p>
<p>Emplacement de niveau supérieur. Les dégâts des deux types augmentent de 1d8 par niveau d''emplacement au-delà du 6e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7866, 2311, 55, 6);

-- [2312] Mur de feu (niv 4, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2312, 'Mur de feu', 4, 1, NULL, 1, 1, 1, 0, 0, 'un morceau de charbon', '36 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous créez un mur de flammes sur une surface solide à portée. Vous pouvez ainsi ériger un mur dont la hauteur n''excède pas 6 m et l''épaisseur 30 cm ; pour le reste, vous avez le choix entre un mur droit long d''un maximum de 18 m et un mur circulaire dont le diamètre ne dépasse pas 6 m. Ce mur opaque persiste pour toute la durée.</p>
<p>Quand le mur apparaît, chaque créature prise dans sa zone effectue un jet de sauvegarde de Dextérité et subit 5d8 dégâts de feu en cas d''échec, la moitié en cas de réussite.</p>
<p>L''un des côtés du mur que vous choisissez à l''incantation du sort inflige 5d8 dégâts de feu à toute créature qui termine son tour à 3 m ou moins de ce côté ou dans le mur. Une créature qui pénètre dans le mur pour la première fois d''un tour ou qui y termine son tour subit ces mêmes dégâts. L''autre côté du mur n''inflige pas de dégâts.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d8 par niveau d''emplacement au-delà du 4e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7867, 2312, 55, 4),
  (7868, 2312, 56, 4),
  (7869, 2312, 52, 4);

-- [2313] Mur de force (niv 5, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2313, 'Mur de force', 5, 1, NULL, 1, 1, 1, 0, 0, 'un éclat de verre', '36 m', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Un mur de force invisible se matérialise en un point que vous choisissez à portée. Le mur se présente dans l''orientation de votre choix, horizontal ou vertical, voire complètement de biais. Il peut rester en suspension ou reposer sur une surface solide. Vous pouvez le façonner en dôme hémisphérique ou en globe d''un rayon maximal de 3 m, ou en faire une surface plane composée de dix pans de 3 m sur 3. Chaque pan doit être contigu avec un autre. Quelle que soit sa forme, le mur est épais de 6 mm et persiste pour toute la durée. Si le mur traverse l''espace d''une créature à son apparition, la créature est repoussée du côté du mur que vous choisissez.</p>
<p>Rien ne peut franchir physiquement le mur. Il est immunisé contre tous les dégâts et insensible à dissipation de la magie. Le sort désintégration détruit en revanche le mur instantanément. Ce mur s''étend en outre sur le Plan Éthéré, ce qui empêche le voyage éthéré le traversant.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7870, 2313, 52, 5);

-- [2314] Mur de glace (niv 6, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2314, 'Mur de glace', 6, 1, NULL, 1, 1, 1, 0, 0, 'un morceau de quartz', '36 m', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Vous créez un mur de glace sur une surface solide à portée. Vous pouvez le façonner en dôme hémisphérique ou en globe d''un rayon maximal de 3 m, ou en faire une surface plane composée de dix pans de 3 m sur 3. Quelle que soit sa forme, le mur est épais de 30 cm et persiste pour toute la durée.</p>
<p>Si le mur traverse l''espace d''une créature à son apparition, la créature est repoussée du côté du mur que vous choisissez et effectue un jet de sauvegarde de Dextérité ; elle subit 10d6 dégâts de froid en cas d''échec, la moitié en cas de réussite.</p>
<p>Le mur est un objet que l''on peut endommager. Doté d''une CA de 12 et de 30 points de vie par section de 3 m de côté, il bénéficie de l''Immunité contre les dégâts de froid, de poison et psychiques, et subit la Vulnérabilité aux dégâts de feu. Une section réduite à 0 point de vie est détruite et laisse une nappe d''air glacial.</p>
<p>Une créature qui traverse une telle nappe pour la première fois d''un tour effectue un jet de sauvegarde de Constitution et subit 5d6 dégâts de froid en cas d''échec, la moitié en cas de réussite.</p>
<p>Emplacement de niveau supérieur. Les dégâts infligés par le mur à son apparition augmentent de 2d6 et ceux de la nappe d''air glacial de 1d6 par niveau d''emplacement au-delà du 6e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7871, 2314, 52, 6);

-- [2315] Mur de pierre (niv 5, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2315, 'Mur de pierre', 5, 1, NULL, 1, 1, 1, 0, 0, 'un cube de granit', '36 m', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Un mur non magique de pierre solide se matérialise en un point que vous choisissez à portée. Le mur, épais de 15 cm, se compose de dix pans de 3 m sur 3. Chaque pan doit être contigu avec un autre. Une autre option consiste à créer des pans de 3 m sur 6, épais de seulement 7,5 cm.</p>
<p>Si le mur traverse l''espace d''une créature à son apparition, la créature est repoussée du côté du mur que vous choisissez. Si une créature est censée se retrouver cernée par le mur de tous les côtés, elle a droit à un jet de sauvegarde de Dextérité. En cas de réussite, elle peut jouer sa Réaction pour se déplacer dans les limites de sa Vitesse de manière à ne plus être séquestrée par le mur.</p>
<p>Le mur peut prendre toute forme de votre choix, mais il ne peut pas occuper le même espace que des créatures ou des objets. Il n''a pas besoin d''être vertical ni de reposer sur des fondations robustes. Il doit en revanche fusionner avec de la pierre existante.</p>
<p>Le mur est un objet de pierre que l''on peut endommager. Chaque pan présente une CA de 15 et dispose de 30 points de vie par tranche de 2,5 cm d''épaisseur, avec l''Immunité contre les dégâts psychiques et de poison.</p>
<p>Si vous maintenez la Concentration sur ce sort jusqu''au terme de sa durée maximale, le mur devient permanent, sans possibilité de le dissiper.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7872, 2315, 55, 5),
  (7873, 2315, 56, 5),
  (7874, 2315, 52, 5);

-- [2316] Mur de vent (niv 3, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2316, 'Mur de vent', 3, 1, NULL, 1, 1, 1, 0, 0, 'un éventail et une plume', '36 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Un mur de vent fort se dresse depuis le sol en un point que vous choisissez à portée. Vous pouvez ainsi ériger un mur dont la hauteur n''excède pas 4,50 m, la longueur 15 m et l''épaisseur 30 cm. Le mur persiste pour toute la durée.</p>
<p>Quand le mur apparaît, chaque créature prise dans sa zone effectue un jet de sauvegarde de Force et subit 4d8 dégâts contondants en cas d''échec, la moitié en cas de réussite.</p>
<p>Le vent fort repousse le brouillard, la fumée et autres gaz et vapeurs. Les créatures et objets volants de taille P ou inférieure ne peuvent pas traverser le mur. Les matériaux légers et libres s''envolent verticalement au contact du mur. Flèches, carreaux d''arbalète et autres projectiles ordinaires tirés sur des cibles situées derrière le mur sont déviés vers le haut et ratent automatiquement. Les créatures sous forme gazeuse ne peuvent pas le traverser.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7875, 2316, 55, 3),
  (7876, 2316, 60, 3);

-- [2317] Mur prismatique (niv 9, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2317, 'Mur prismatique', 9, 5, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', '10 minutes', NULL, NULL, 0, 0, '<p>Un plan multicolore de lueurs chatoyantes s''érige sous forme d''un mur vertical opaque centré sur un point à portée (longueur max. 27 m, hauteur max. 9 m, épaisseur 2,5 cm) ou en globe d''un diamètre maximal de 9 m. Le mur persiste pour toute la durée. Si vous le positionnez en un espace occupé par une créature, le sort prend aussitôt fin sans effet.</p>
<p>Le mur produit une Lumière vive sur 30 m et une Lumière faible sur 30 m de plus. Vous et les créatures que vous désignez pouvez sans risque traverser le mur. Si une autre créature qui voit le mur s''approche dans un rayon de 6 m ou y commence son tour, elle doit réussir un jet de sauvegarde de Constitution sous peine de subir l''état Aveuglé pendant 1 minute.</p>
<p>Le mur est constitué de sept couches. Lorsqu''une créature tente de pénétrer le mur ou de le traverser, elle le fait couche après couche jusqu''à toutes les avoir franchies. Chaque couche contraint la créature à un jet de sauvegarde de Dextérité.</p>
<p>1 — Rouge. Échec : 12d6 dégâts de feu. Réussite : 1/2. Détruite par au moins 25 dégâts de froid.<br>
2 — Orange. Échec : 12d6 dégâts d''acide. Réussite : 1/2. Détruite par un vent fort.<br>
3 — Jaune. Échec : 12d6 dégâts de foudre. Réussite : 1/2. Détruite par au moins 60 dégâts de force.<br>
4 — Verte. Échec : 12d6 dégâts de poison. Réussite : 1/2. Détruite par passe-muraille ou sort équivalent.<br>
5 — Bleue. Échec : 12d6 dégâts de froid. Réussite : 1/2. Détruite par au moins 25 dégâts de feu.<br>
6 — Indigo. Échec : état Entravé ; JS Constitution en fin de chaque tour. Trois réussites = fin de l''état. Trois échecs = état Pétrifié (restauration suprême pour en sortir). Les sorts ne peuvent pas traverser cette couche ; détruite par lumière du jour.<br>
7 — Violette. Échec : état Aveuglé ; JS Sagesse au début de votre tour suivant. Réussite : fin de l''état. Échec : fin de l''état + téléportation vers un plan aléatoire. Détruite par dissipation de la magie.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7877, 2317, 53, 9),
  (7878, 2317, 52, 9);

-- [2318] Murmures dissonants (niv 1, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2318, 'Murmures dissonants', 1, 3, NULL, 1, 0, 0, 0, 0, NULL, '18 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Une créature que vous choisissez parmi celles que vous voyez à portée perçoit intérieurement une mélodie discordante. La cible effectue un jet de sauvegarde de Sagesse. Elle subit 3d6 dégâts psychiques en cas d''échec et doit aussitôt jouer sa Réaction si disponible pour s''éloigner de vous autant qu''elle le peut, par le chemin le plus sûr. En cas de réussite, la cible subit uniquement la moitié de ces dégâts.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d6 par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7879, 2318, 53, 1);

-- [2319] Mythes et légendes (niv 5, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2319, 'Mythes et légendes', 5, 7, NULL, 1, 1, 1, 0, 0, 'de l''encens d''une valeur minimale de 250 po que le sort détruit, et quatre lamelles d''ivoire d''une valeur minimale de 50 po chacune', 'personnelle', '', '', '10 minutes', 'instantanée', NULL, NULL, 0, 0, '<p>Nommez ou décrivez un élément notoire : personne, lieu ou objet. Le sort vous fait prendre brièvement conscience d''un fait important (décrit par le MJ) concernant l''élément mentionné.</p>
<p>Cette bribe de savoir peut consister en des détails essentiels, des révélations cocasses, voire quelque secret toujours resté méconnu. Plus vous en savez déjà sur l''élément, plus précises et détaillées seront les informations transmises. Les détails révélés sont justes, mais sont parfois formulés de manière imagée ou par le biais de vers (à l''appréciation du MJ).</p>
<p>Si l''élément retenu n''est pas véritablement notoire, vous n''entendez que quelques notes tristes de trombone et le sort prend fin.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7880, 2319, 53, 5),
  (7881, 2319, 54, 5),
  (7882, 2319, 52, 5);

-- [2320] Nappe de brouillard (niv 1, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2320, 'Nappe de brouillard', 1, 6, NULL, 1, 1, 0, 0, 0, NULL, '36 m', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Vous créez une Sphère de 6 m de rayon constituée de brouillard, centrée sur un point à portée. La Sphère présente une Visibilité nulle. Elle persiste pour toute la durée, à moins qu''un vent fort (comme celui engendré par bourrasque) la disperse.</p>
<p>Emplacement de niveau supérieur. Le rayon du brouillard augmente de 6 m par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7883, 2320, 55, 1),
  (7884, 2320, 56, 1),
  (7885, 2320, 52, 1),
  (7886, 2320, 60, 1);

-- [2321] Nuage incendiaire (niv 8, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2321, 'Nuage incendiaire', 8, 6, NULL, 1, 1, 0, 0, 0, NULL, '45 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Un nuage tourbillonnant de fumée se manifeste, chargé de flammèches, sous forme d''une Sphère de 6 m de rayon centrée sur un point à portée. La zone du nuage présente une Visibilité nulle. Elle persiste pour toute la durée, à moins qu''un vent fort (comme celui engendré par bourrasque) la disperse.</p>
<p>Chaque créature prise dans le nuage à son apparition effectue un jet de sauvegarde de Dextérité et subit 10d8 dégâts de feu en cas d''échec, la moitié en cas de réussite. Toute créature qui voit la Sphère se déplacer dans son espace, ou qui pénètre dans la Sphère ou y termine son tour, est également soumise à ce JS. Une même créature n''effectue en aucun cas ce JS plus d''une fois par tour.</p>
<p>Le nuage s''éloigne de 3 m de vous au début de chacun de vos tours, dans la direction de votre choix.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7887, 2321, 55, 8),
  (7888, 2321, 56, 8),
  (7889, 2321, 52, 8);

-- [2322] Nuage nauséabond (niv 3, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2322, 'Nuage nauséabond', 3, 6, NULL, 1, 1, 1, 0, 0, 'un œuf pourri', '27 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous créez une Sphère d''un rayon de 6 m remplie de vapeurs nauséeuses jaunes, centrée sur un point à portée. Le nuage présente une Visibilité nulle. Il flotte sur place pour toute la durée, à moins qu''un vent fort (comme celui engendré par bourrasque) le disperse.</p>
<p>Chaque créature qui commence son tour dans la Sphère doit réussir un jet de sauvegarde de Constitution sous peine de subir l''état Empoisonné jusqu''à la fin du tour en cours. Ainsi Empoisonnée, la créature ne peut pas entreprendre d''action ni d''action Bonus.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7890, 2322, 53, 3),
  (7891, 2322, 56, 3),
  (7892, 2322, 52, 3);

-- [2323] Nuée de météores (niv 9, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2323, 'Nuée de météores', 9, 1, NULL, 1, 1, 0, 0, 0, NULL, '1,5 km', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Des orbes embrasés s''abattent au sol en quatre points différents que vous voyez à portée. Toute créature prise dans une Sphère d''un rayon de 12 m centrée sur l''un des quatre points effectue un jet de sauvegarde de Dextérité. Une créature subit 20d6 dégâts de feu et 20d6 dégâts contondants en cas d''échec, la moitié en cas de réussite. Une créature prise dans les zones de plus d''une Sphère ardente n''est affectée qu''une fois.</p>
<p>Un objet non magique qui n''est porté par personne subit lui aussi les dégâts s''il est dans la zone d''effet du sort, et il s''embrase s''il est inflammable.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7893, 2323, 56, 9),
  (7894, 2323, 52, 9);

-- [2324] Œil du mage (niv 4, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2324, 'Œil du mage', 4, 7, NULL, 1, 1, 1, 0, 0, 'une touffe de poils de chauve-souris', '9 m', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Vous créez un œil invulnérable et Invisible à portée, qui flotte dans les airs pour toute la durée. Vous recevez mentalement des informations visuelles transmises par l''œil, qui voit dans toutes les directions. Il dispose en outre de la Vision dans le noir sur 9 m.</p>
<p>Par une action Bonus, vous pouvez déplacer l''œil d''un maximum de 9 m dans la direction de votre choix. Un obstacle solide bloque les déplacements de l''œil, mais celui-ci peut se glisser dans un interstice d''une largeur minimale de 2,5 cm.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7895, 2324, 52, 4);

-- [2325] Orbe chromatique (niv 1, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2325, 'Orbe chromatique', 1, 1, NULL, 1, 1, 1, 0, 0, 'un diamant d''une valeur minimale de 50 po', '27 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous projetez un orbe d''énergie sur une cible à portée. Choisissez une énergie entre acide, feu, foudre, froid, poison et tonnerre pour composer l''orbe, puis effectuez un jet d''attaque de sort à distance contre la cible. Si l''attaque touche, la cible subit 3d8 dégâts du type retenu.</p>
<p>Si vous obtenez le même nombre sur au moins deux des d8, l''orbe rebondit vers une autre cible de votre choix dans un rayon de 9 m de la cible. Effectuez un jet d''attaque contre la nouvelle cible et un nouveau jet de dégâts. L''orbe ne rebondit pas une deuxième fois, sauf si vous avez lancé le sort par un emplacement du 2e niveau ou supérieur.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d8 par niveau d''emplacement au-delà du 1er. L''orbe est susceptible de rebondir autant de fois que le niveau de l''emplacement dépensé, une même créature ne pouvant être ciblée qu''une fois par incantation du sort.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7896, 2325, 56, 1),
  (7897, 2325, 52, 1);

-- [2326] Orientation (niv 6, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2326, 'Orientation', 6, 7, NULL, 1, 1, 1, 0, 0, 'des accessoires de divination d''une valeur minimale de 100 po', 'personnelle', '', '', '1 minute', 'Concentration, jusqu''à 1 jour', NULL, NULL, 1, 0, '<p>Vous trouvez magiquement le chemin le plus direct jusqu''à un lieu que vous nommez. Vous devez connaître cet endroit et le sort échoue si le lieu nommé est sur un autre plan d''existence, est une destination mobile ou un endroit générique (comme « l''antre d''un dragon vert »).</p>
<p>Pour toute la durée et tant que vous êtes sur le même plan d''existence que la destination, vous savez quelle distance vous en sépare et dans quelle direction elle se trouve. Chaque fois que vous avez le choix entre plusieurs itinéraires, vous savez automatiquement lequel est le plus direct.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7898, 2326, 53, 6),
  (7899, 2326, 54, 6),
  (7900, 2326, 55, 6);

COMMIT;
-- Fin lot 5 — 89 sorts, prochains IDs : dd_sorts=2327, dd_sortclasse=7901
