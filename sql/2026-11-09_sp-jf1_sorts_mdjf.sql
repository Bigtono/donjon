-- sql/2026-11-09_sp-jf1_sorts_mdjf.sql
-- SP-JF1 — Sorts du Manuel des Joueurs de Faerûn (source MdJF, res_id 63) absents de dd_sorts,
-- avec leurs niveaux par classe / domaine et les tableaux de leurs descriptions.
-- Généré par tools/generer-sp-jf1-sorts.php le 2026-11-09 depuis gemmaline.com (index element-MJF.htm).
-- Rejouable : chaque insertion est gardée par NOT EXISTS. Pas de DELIMITER.

SET NAMES utf8mb4;

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_visible, tab_date_creation, tab_date_modif)
SELECT 'sort-arc-lunaire-de-presper', 'Arc lunaire de Presper : tableau', '! Nombre d''orbes | Dégâts par orbe
1 | 4d6
2 | 3d6
3 | 2d6
4 | 2d4', 'll', 4, 1, 63, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM dd_tableaux WHERE tab_slug = 'sort-arc-lunaire-de-presper' AND tab_ruleset_var_id = 1);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_visible, tab_date_creation, tab_date_modif)
SELECT 'sort-orbite-de-crane', 'Orbite de crâne : tableau', '! Nombre de DV | Effet
Supérieur ou égal au niveau du lanceur de sorts | Charme
Inférieur au niveau du lanceur de sorts | Confusion', 'll', 4, 1, 63, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM dd_tableaux WHERE tab_slug = 'sort-orbite-de-crane' AND tab_ruleset_var_id = 1);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Arbre guérisseur', 6, 'Guérison', NULL, 1, 1, 0, 0, 1, NULL, 'personnelle et contact', 'le jeteur de sorts et un arbre', '', '1 action simple', '1 jour (T)', 'Non', 'aucun', '<p>L''initié pénètre au sein d''un arbre suffisamment grand pour accueillir son corps en trois dimensions. Il peut y rester jusqu''à une journée entière. Tant qu''il s''y trouve, l''arbre le nourrit et le soigne. Le personnage n''a nul besoin de manger ou de respirer, et il regagne un nombre de points de vie égal à son niveau global par heure de son séjour. S''il y passe une journée entière, il bénéficie d''un sort de guérison suprême. L''arbre confère également un abri total et protège de la chaleur et du froid extrêmes, du soleil, de la neige et de toute autre condition liée à-l''environnement. L''initié entend mais ne voit pas ce qu''il se passe à l''extérieur. Les dégâts physiques mineurs infligés à l''arbre ne lui nuisent pas, mais sa destruction partielle l''expulse s''il ne peut plus y tenir et lui inflige 5d6 points de dégâts. Si l''arbre est complètement détruit (par un incendie de forêt ou un sort de flétrissement végétal, par exemple), le personnage en est expulsé et meurt aussitôt, à moins de réussir un jet de Vigueur (DD 18).</p>
<p>Seul un initié de la Nature peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Arbre guérisseur' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Arbre guérisseur' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Arc lunaire de Presper', 1, NULL, 'électricité', 1, 1, 1, 0, 0, 'une petite pierre de lune', 'moyenne (30 m + 3 m/niveau)', '', '1d4 orbes d''électricité', '1 action simple', 'instantanée ou 1d4 rounds ; voir description', 'Non', 'aucun', '<p>Ce sort invoque 1d4 orbes d''électricité qui se rassemblent et tournent autour du mage à la manière d''une lueur féerique. Le personnage peut leur donner l''ordre d''attaquer les cibles situées a portée du sort. Plusieurs peuvent s''en prendre à une même cible, tout comme il leur est possible d''attaquer des cibles distinctes. Le mage doit réussir une attaque de contact à distance pour chacun. Les créatures touchées subissent des dégâts d''électricité selon la table suivante :</p>
<p>[[tab:sort-arc-lunaire-de-presper]]</p>
<p>Si le mage ne tire pas instantanément tous les orbes créés par le sort, il peut le faire au round suivant au prix d''une action simple. Si un round s''écoule sans que le mage ait tiré un des orbes, le sort prend fin et les orbes restants disparaissent.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Arc lunaire de Presper' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Arc lunaire de Presper' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Arc lunaire de Presper' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Avalanche vengeresse', 6, 'Création', 'froid', 1, 1, 0, 0, 0, NULL, 'moyenne (30 m + 3 m/niveau)', '', 'avalanche de neige de 6 mètres de rayon centrée n''omporte où dans les limites de la portée ; voir description', '1 action simple', 'instantanée', 'Non', 'Réflexes, 1/2 dégâts ou Réflèxes, annule ; voir description', '<p>Le prêtre convoque une avalanche de neige depuis les airs, ensevelissant ses adversaires et les expédiant outre-tombe en les transformant en glaçons.</p>
<p>L''avalanche vengeresse affecte les réatures suivant là où elles se trouvent par rapport au point d''origine du sort.</p>
<p><em>Dans un rayon de 6mètres du point d''origine.</em> Les créatures subissent 1d8 points de dégâts tous les deux niveaux de lanceur de sorts (maximum 10d8) et 1d6 points de dégâts de froid tous les deux niveaux de lanceur de sorts. En outre, celles qui ratent leur jet de sauvegarde sont ensevelies. Toutes les cases situées dans un rayon de 6 mètres du point d''origine sont victimes d''une lourde chute de neige qui persiste aussi longtemps que de la neige ordinaire.</p>
<p><em>Entre 6 et 12 mètres du point d''origine</em>. Les créatures subissent moitié moins de dégâts en raison de l''impact (Réflexes, annule). Celles qui ratent leur jet de sauvegarde doivent résister à la force de la neige comme si elles étaient victime d''une bousculade. La neige a un bonus de + 13 (+5 pour une Force effective de20, +8 pour sa taille G) au test de bousculade et elle repousse les sujets du point d''origine. Toutes les cases situées dans un rayon de 6 à 12 mètres sont recouvertes de neige qui persiste aussi longtemps que de la neige ordinaire.</p>
<p><em>Relief et structure</em>. L''avalanche déracine automatiquement les arbustes et laisse une trainée de décombres dans son sillage une fois la neige fondue. Les structures frappées par un tel sort subissent 1d6 x 10 points de dégâts.</p>
<p>L''avalanche vengeresse étaint les flammes, magiques ou non, avec lesquelles elle entre en contact</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Avalanche vengeresse' AND so_res_id = 63);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT s.so_id, 9, d.do_id FROM dd_sorts s JOIN dd_domaines d ON d.do_nom = 'Froid'
WHERE s.so_nom = 'Avalanche vengeresse' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_so_id = s.so_id AND x.sd_do_id = d.do_id);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT s.so_id, 9, d.do_id FROM dd_sorts s JOIN dd_domaines d ON d.do_nom = 'Neige'
WHERE s.so_nom = 'Avalanche vengeresse' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_so_id = s.so_id AND x.sd_do_id = d.do_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Bombardement', 6, 'Création', NULL, 1, 1, 0, 1, 0, 'Focalisateur : un cristal de quartz enchâssé dans une pierre', 'longue (120 m + 12 m/niveau)', '', 'rayonnement de 4,50 de rayon', '1 action simple', 'instantanée', 'Oui', 'Réflexes, 1/2 dégâts ; voir description', '<p>Les adversaires du druide sont- ensevelis sous une pluie de cailloux tombant des cieux. Le jeteur de sorts désigne le centre du rayonnement. Le sort inflige 1d8 points de dégâts par niveau de lanceur de sorts (jusqu''à un maximum de 20d8) et ensevelit toute cible ratant son jet de Réflexes. Les cibles qui réussissent leur jet de sauvegarde réduisent les dégâts subis de moitié et ne sont pas ensevelies. De leur côté, les sujets ensevelis suffoquent jusqu''à ce qu''ils s''extraient de la masse rocheuse (au prix d''une action complexe).</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Bombardement' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 8 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Druide' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Bombardement' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Brasier', 4, NULL, 'feu', 1, 1, 1, 0, 0, 'un gros morceau de cire d''abeille', 'courte (7,50 m + 1,50 m/2 niveaux)', '1 créature', '', '1 action simple', '1 round/niveau (T)', 'Oui', 'Vigueur, annule', '<p>Le sujet s''embrase et subit 6d6 points de dégâts de feu. Ses vêtements, objets, cheveux et chair brûlent avec fureur. À chaque round suivant, le feu inflige 1d6 points de dégâts de moins (minimum 1d6) jusqu''à ce que le sort s''achève ou que le sujet parvienne à éteindre les flammes. Les dégâts s''élèvent donc à 5d6 au 2e round, 4d6 au 3e round, etc. Les objets non magiques et inflammables que porte la cible ratent automatiquement leur jet de sauvegarde visant à résister aux dégâts.</p>
<p>Après le premier round, la cible peut tenter d''éteindre les flammes au prix d''une action complexe avant de subir des dégâts supplémentaires. Pour ce faire, elle doit réussir un jet de Réflexes (DD 15). Le fait de se rouler au sol confère un bonus de +2. Enfin, si l''on saute dans un lac ou que l''on use de magie pour éteindre les flammes, celles-ci sont automatiquement étouffées.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Brasier' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Druide' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Brasier' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Féticheur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Brasier' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Brise-chair', 2, NULL, NULL, 1, 1, 1, 0, 0, 'un os qui est brisé lors de l''incantation', 'courte (7,50 m + 1,50 m/2 niveaux)', '1 créature', '', '1 action simple', 'instantanée', 'Oui', 'Vigueur, partiel ; voir description', '<p>Ce sort macabre affecte le squelette de la cible, provoquant une douleur atroce en lui brisant les os. La cible est automatiquement étourdie pendant 1 round (pas de jet de sauvegarde). Au round suivant, elle doit réussir un jet de Vigueur sous peiné de subir 1d6 points de dégâts contondants par niveau de lanceur de sorts (jusqu''à un maximum de 15d6) et d''être nauséeuse pendant 1d+t.2 rounds en raison de la douleur.</p>
<p>Seul un initié de Loviatar peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Brise-chair' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Brise-chair' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Brise-chair' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Brise-chair' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Cerf spectral', 6, 'Création', NULL, 1, 1, 0, 0, 1, NULL, '0 m', '', 'une créature ressemblant à un cerf et quasi réelle', '1 action simple', '1 round/niveau', 'Non', 'aucun', '<p>Le prêtre invoque une sorte de cerf quasi réel. La créature peut attaquer pour le compte du jeteur de sorts ou bien lui servir de monture. Lors de l''incantation, le prêtre doit préciser s''il souhaite que le cerf apparaisse à ses côtés ou juste sous lui, afin qu''il puisse le monter sur-le-champ. Le cerf a une vitesse de déplacement de 18 mètres et est capable d''agir au moment même où il apparaît. Il se déplace selon le bon vouloir du prêtre, qui le contrôle au prix d''une action libre. Il peut chevaucher dans les airs comme s''il évoluait sur la terre ferme (effet semblable au sort coursier fantôme, niveau 12 de lanceur de sorts) et est capable de transporter 5 kilos par niveau de lanceur de sorts en plus de son cavalier.</p>
<p>Cette monture est une créature de-taille G pourvue d''une CA de 18 (-1 taille, +4 armure naturelle, +5 Dex) et de 7 points de vie, +1 par niveau de lanceur de sorts;. S''il perd tous ses points de vie, le cerf spectral disparaît.</p>
<p>Si on lui ordonne d''attaquer une autre créature, le cerf charge sa cible et tente-une action de bousculade. Il dispose d''une Force de 18 au regard de cette action. Le cerf ne peut pas être attaqué ou blessé, mais si le prêtre le monte au cours de l''action de bousculade, le défenseur peut user de son attaque d''opportunité contre le jeteur de sorts plutôt que contre le cerf. Si la bousculade se solde par un échec, le cerf (et le prêtre si celui-ci le monte) recule de 1,50 mètre par rapport à l''endroit où il se trouvait avant d''entrer dans l''espace occupé de la cible. Si la tentative de bousculade est couronnée de succès, le cerf fait reculer le défenseur de la distance maximale possible. En outre, ce dernier doit également remporter un jet de Vigueur sous peine d''être étourdi pendant 1 round.</p>
<p>Au terme du sort, le cerf disparaît Si le prêtre le chevauchait, il atterrit doucement au sol</p>
<p>Seul un initié de Malar peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Cerf spectral' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Cerf spectral' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Chaîne hurleuse', 1, NULL, 'force', 1, 1, 0, 1, 0, 'Focalisateur : une courte chaîne en platine d''une valeur de 500 po', 'moyenne (30 m + 3 m/niveau)', '1 créature située à portée', '', '1 action simple', '1 round/niveau', 'Oui', 'voir description', '<p>Ce sort convoque une chaîne rouge sang et luisante de force pure qui serpente autour de la cible, entravant ses mouvements et l''attaquant. Le sort tire son nom du hurlement surnaturel que produit la chaîne quand elle enserre sa victime. Le son produit est si fort que les créatures situées dans un rayon de 30 mètres de la chaîne subissent un malus de -2 aux tests de Perception auditive. La chaîne ne retient pas fermement sa victime, pas plus qu''elle ne l''empêche d''agir, mais cette dernière subit néanmoins un malus de -2 à l''attaque, aux sauvegardes et aux tests de compétence. En outre, elle doit réussir un test de Concentration (DD 15 + niveau de sort) pour lancer un sort pourvu de composantes gestuelles. Chaque round, la chaîne attaque la cible deux fois (+13/+8 corps à corps), infligeant 3d4 points de dégâts contondants par succès. Enfin, si la cible tente de lancer un sort au cours d''un round où les deux attaques sont couronnées de succès, le DD du test de Concentration augmente de +5.</p>
<p>Au moment où le sort est lancé, la cible a droit à un jet de Réflexes, pour échapper à l''étreinte de la chaîne, En cas de succès, celle-ci se manifeste dans un rayon de 1,50 mètre delà cible. Si la cible ne se déplace pas, la chaîne tente une fois encore de l''enchevêtrer lors de l''action suivante du mage. La cible a alors droit à un nouveau jet de Réflexes. Par contre, si la cible désignée n''est plus adjacente à la chaîne, elle se déplace vers sa proie de 6 mètres par round et passe à l''attaque dès que possible. La chaîne hurleuse est un objet de taille M doté d''une CA 12 et de 33 points de vie. Elle exploite les bonus aux sauvegardes du mage. Cependant, tous les dégâts qui lui sont infligés s''appliquent également à la cible du sort, qui a droit à un jet de Vigueur pour les réduire de moitié. Le sort prend fin au terme de sa durée, si la chaîne est détruite ou si la cible meurt</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Chaîne hurleuse' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 6 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Chaîne hurleuse' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 6 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Chaîne hurleuse' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Compétence divine', 7, NULL, NULL, 1, 1, 0, 0, 0, NULL, 'contact', '1 créature touchée', '', '1 action simple', '1 minute/niveau', 'Oui (inoffensif)', 'aucun', '<p>Ce sort confère au sujet une assistance divine. Il bénéficie ainsi d''un bonus d''aptitude de +5 à un test de compétence choisie par l''initié. Si la cible du sort ne possède pas la compétence en question, on considère qu''elle dispose de 1/2 degré de maîtrise et donc qu''elle connaît la compétence (cependant, ce 1/2 degré de maîtrise n''apporte rien au test de compétence) Au lieu d''une compétence, la cible peut aussi être considérée comme formée au maniement d''une arme (courante, de guerre ou exotique) ou au port d''un type d''armure (légère, intermédiaire, lourde) comme si elle possédait le don adéquat.</p>
<p>Seul un initié de Gond peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Compétence divine' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 1 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Compétence divine' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Contact de la moisissure', 6, 'Création', NULL, 1, 1, 0, 0, 1, NULL, 'contact', '', 'plaque de moisissure brune', '1 action simple', 'instantanée', 'Non', 'aucun', '<p>Une plaque de moisissure brune de 1,50 mètre de diamètre apparaît, centrée sur le point désigné par le prêtre. Il peut même la manifester sur une créature vivante en réussissant une attaque de contact au corps à corps.</p>
<p>Une créature vivante située dans un rayon de 1,50 mètre d''une moisissure brune subit 3d6 points de dégâts non-létaux de froid par round. Si des flammes approchent à 1,50 mètre ou moins de la plaque, celle-ci double aussitôt de volume. Par contre, des dégâts de froid la détruisent instantanément.</p>
<p>Seul un initié de la Nature peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Contact de la moisissure' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Contact de la moisissure' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Crachat de vipères', 6, 'Convocation', NULL, 1, 1, 1, 0, 0, 'une mue de serpent', 'courte (7,50 m +1,50 m/2 niveaux)', '1d4 + 3 créatures convoquées', '', '1 action simple', '1 round/niveau', 'Non', 'aucun', '<p>Ce sort convoque 1d4+3 vipères fiélons (chaotiques mauvaises) ou célestes (chaotiques bonnes) de taille M qui jaillissent de la bouche du jeteur de-sorts afin d''attaquer ses ennemis. Durant le round où le sort est lancé, le personnage crache des vipères jusqu''à atteindre le chiffre fixé par le sort. Il est possible d''en cracher trois au prix d''une action simple ou une au prix d''une action de mouvement. (Si le personnage se. déplace et lance le sort, il lui faut attendre son tour de jeu suivant, mais s''il lance le sort sans se déplacer, il peut cracher une vipère dans la foulée au prix d''une action de mouvement.) Les serpents tombent aux pieds du personnage, dans une case adjacente à la sienne, et agissent au même round, tout comme des créatures appelées par un sort de convocation de monstres.</p>
<p>Les serpents ne sont pas véritablement présents dans la bouche du personnage et ne l''empêchent donc pas de respirer. Cependant, tant qu''il n''a pas recraché tous les serpents convoqués par le biais du sort, il ne saurait parler, lancer de sorts dotés de composantes verbales ou activer d''objets requérant le don de parole. Au terme du sort toutes les vipères disparaissent et celles qui n''ont pas été crachées sont perdues.</p>
<p>Lorsque le jeteur de sorts use d''un sort de convocation pour appeler une créature bonne ou mauvaise, le sort est du type correspondant.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Crachat de vipères' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 7 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Crachat de vipères' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 7 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Crachat de vipères' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT s.so_id, 7, d.do_id FROM dd_sorts s JOIN dd_domaines d ON d.do_nom = 'Reptiles'
WHERE s.so_nom = 'Crachat de vipères' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_so_id = s.so_id AND x.sd_do_id = d.do_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Crâne des secrets', 9, 'Ombre', NULL, 1, 1, 0, 0, 0, NULL, 'courte (7,50 m + 1,50 m/2 niveaux)', '', 'crâne intangible', '1 round entier', 'permanente jusqu''à déclenchement', 'Non', 'aucun ; voir description', '<p>Le prêtre crée l''image d''un crâne intangible enveloppé de flammes noires. De toute évidence, le crâne et les flammes sont de simples illusions et n''infligent pas de dégâts. De même, le crâne ne peut subir de dégâts. Il vole a une vitesse de 12 mètres (manœuvrabilité parfaite), mais il ne saurait s''éloigner de plus de 6 mètres de son point d''origine. Il flotte dans les airs sans but précis mais d''une manière menaçante jusqu''au déclenchement. Lors de l''incantation, le mage fixe deux conditions de déclenchement. La première active un message, comme s''il s''agissait d''une bouche magique. Avec la seconde, le crâne crache une langue de flammes de 3 mètres de long infligeant 1d8 points de dégâts de feu tous les deux niveaux de lanceur de sorts (jusqu''à un maximum de 5d8) à la créature l''ayant déclenchée. Les créatures affectées ont droit à un jet de Réflexes pour réduire les dégâts de moitié. En cas d''échec, il leur faut réussir un jet de Vigueur sous peine d''être étourdies pendant 1 round.</p>
<p>La condition de déclenchement peut être la même pour les deux effets, aussi le crâne peut-il cracher des flammes et délivrer son message en même temps. Une fois les deux conditions remplies, le crâne disparaît. Chaque effet ne peut être produit qu''une seule fois. Le crâne ne délivrera pas son message une seconde fois si l''on remplit de nouveau la condition adéquate.</p>
<p>Seul un initié de Cyric peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Crâne des secrets' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Crâne des secrets' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Enchevêtrement épineux', 4, NULL, NULL, 0, 0, 0, 0, 0, NULL, '', '', '', '', NULL, NULL, NULL, '<p>A l''exception de ce qui suit, ce sort fonctionne sur le même principe qu''enchevêtrement. Les plantes prennent la forme de buissons épineux de 1,80 mètre de haut. Au round où le sort prend effet, les créatures enchevêtrées subissent 1d8 points de dégâts perforants, +1 point tous les deux niveaux de lanceur de sorts. Chaque fois qu''un sujet tente de se libérer ou de se déplacer au sein des buissons, il subit ces dégâts. Une créature enchevêtrée tentant de lancer un sort doit réussir un test de Concentration (DD 20 + niveau de sort) sous peine de le perdre.</p>
<p>Les buissons sont suffisamment denses et hauts pour conférer un abri aux créatures qui se trouvent en leur sein ou derrière eux.</p>
<p>Seul un initié de la Nature peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Enchevêtrement épineux' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Enchevêtrement épineux' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Épée axiomatique', 1, NULL, 'Loi', 1, 1, 0, 0, 0, NULL, 'contact', '1 arme touchée', '', '1 action simple', '1 round/niveau', 'Non', 'aucun', '<p>À l''exception de ce qui suit, ce sort fonctionne sur le même principe qu''épée sainte. L''arme se comporte comme une arme axiomatique (bonus d''altération de +5 à l''attaque et aux dégâts, alignement loyal, inflige +2d6 points de dégâts aux adversaires chaotiques). De plus, elle génère un effet de cerclé magique contre le Chaos (comme le sort du même nom)</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Épée axiomatique' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Paladin' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Épée axiomatique' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Épée et marteau', 1, NULL, 'force', 0, 0, 0, 0, 0, NULL, '', '', '', '', NULL, NULL, NULL, '<p>À l''exception de ce qui suit, ce,sort fonctionne sur le même principe qu''arme spirituelle. Une fois l''incantation terminée, deux armes constituées d''énergie apparaissent : une épée longue et un marteau de guerre. Toutes deux confèrent un bonus de +1 aux jets d''attaque. Si elles reçoivent l''ordre de s''en prendre au même adversaire, elles le prennent en tenaille et chacune bénéficie du bonus habituel (+2) aux jets d''attaque. Ces armes n''infligent cependant pas de dégâts d''attaque sournoise si l''initié est également pourvu de niveaux dans une classe conférant ce pouvoir.</p>
<p>Seul un initié de Tyr peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Épée et marteau' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Épée et marteau' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Épée et marteau suprêmes', 1, NULL, 'force', 0, 0, 0, 0, 0, NULL, '', '', '', '', NULL, NULL, NULL, '<p>À l''exception de ce qui suit, ce sort fonctionne sur- le même principe qu''épée et marteau. Les armes conviennent à. des créatures de taille G et chacune inflige 2d6 points de dégâts de force, +1 point tous. les trois niveaux de lanceur de sorts (jusqu''à un maximum de +10). Chaque arme confère un bonus de +2 aux jets d''attaque. De plus, elles ont une zone de critique possible comme si elles possédaient le don Science du critique (17-20 pour l''épée longue et 19-20 pour le marteau de guerre).</p>
<p>Seul un initié de Tyr peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Épée et marteau suprêmes' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 6 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Épée et marteau suprêmes' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Explosion de terreur', 2, NULL, NULL, 1, 1, 0, 0, 0, NULL, 'moyenne (30 m + 3 m/niveau)', '', 'rayon', '1 action simple', 'instantanée', 'Oui', 'Volonté, 1/2 (voir description)', '<p>Au prix d''une attaque de contact à distance, le personnage vise une cible à l''aide d''un rayon noir d''énergie négative. La créature frappée subit 4d8 points de dégâts, +1 par niveau de lanceur de sorts (jusqu''à +20) et est hébétée pendant 1 round. Si la cible réussit un jet de Volonté, les dégâts sont réduits de moitié et l''effet d''hébétement est annulé. Ce sort n''a aucun effet sur les créatures artificielles et les objets inanimés.</p>
<p>Ce sort soigne bien évidemment les morts-vivants à hauteur des dégâts normalement infligés.</p>
<p>Seul un initié de Cyric peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Explosion de terreur' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Explosion de terreur' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Force de la bête', 4, NULL, NULL, 1, 0, 0, 1, 0, 'Focalisateur : un des poils de sa forme animale', 'personnelle', 'le jeteur de sorts', '', '1 action simple', '1 round/niveau', NULL, NULL, '<p>Ce sort ne fonctionne que si l''initié est un lycanthrope. De plus, il n''en tire les fruits que s''il est sous forme humanoïde. Il gagne alors certaines particularités de sa forme animale tout en conservant sa forme humanoïde. Il bénéficie ainsi de la même réduction des dégâts que sa forme animale (5/argent ou 10/argent), du pouvoir spécial d''odorat et des dons auxquels il a accès sous forme animale. De plus, il bénéficie de la moitié de chaque ajustement aux valeurs de caractéristique (arrondir au multiple de 2 inférieur). Par exemple, si l''initié est un ours-garou, il bénéficie d''un bonus de +8 en Force et d''un bonus de +4 en Constitution. Toutefois, sa Dextérité n''est pas modifiée puisque la moitié de +2 arrondi au multiple de 2 inférieur donne +0. Si le personnage doit effectuer un test de Contrôle de forme alors qu''il est affecté par le sort, il subit un malus de -4.</p>
<p>Seuls les initiés de Malar et de Séluné peuvent lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Force de la bête' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Force de la bête' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Fouet mystique', 1, NULL, 'électricité, Mal', 1, 1, 0, 0, 1, NULL, '4,50m', '', 'fouet électrique', '1 action simple', '1 round/niveau', 'Oui', 'Vigueur, partiel', '<p>Le prêtre crée un long fouet d''énergie rougeâtre et fantomatique. Celui-ci apparaît dans sa main et ne peut en aucun cas le blesser. Il l''emploie comme s''il s''agissait d''un véritable fouet et qu''il était formé à son maniement. Tout coup porté à l''aide du fouet mystique se fait au prix d''une attaque de contact à distance. Il inflige 1d6 points de dégâts d''électricité tous les trois niveaux de lanceur de sorts jusqu''à un maximum de 4d6). Toute créature touchée doit réussir un jet de Vigueur sous peine d''être étourdie pendant 1 round. Étant donné que le fouet est immatériel, le prêtre bénéficie d''un bonus aux jets de dégâts égal à son modificateur de Charisme, mais son modificateur de Force ne s''applique pas.</p>
<p>Si le fouet touche sa cible, le prêtre peut le lâcher afin qu''il continue, seul, d''attaquer l''adversaire, ce qui lui permet d''avoir la main libre. Si la cible sombre dans l''inconscience, meurt ou est détruite, le fouet revient dans les mains du prêtre lors de son action suivante. Si celui-ci ne s''en saisit pas durant le round où il revient, il est dissipé. Dans le cas inverse, le prêtre peut s''en servir contre une autre créature et le cycle recommence.</p>
<p>Comme dans le cas d''un fouet normal, le prêtre peut utiliser le fouet mystique pour effectuer des attaques de croc-en-jambe et de désarmement, mais uniquement s''il le manie. L''arme ne peut donc pas réaliser ce genre d''attaques s''il la lâche.</p>
<p>Seuls les initiés de Baine (niveau 3) et de Loviatar (niveau 4) peuvent lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Fouet mystique' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Fouet mystique' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Griffe noire', 2, NULL, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', 'le jeteur de sorts', '', '1 action simple', '1 round/niveau', NULL, NULL, '<p>L''un des bras du prêtre prend l''apparence d''un appendice caoutchouteux et rétractile pourvu de griffes. Il peut attaquer à l''aide de ces griffes comme s''il avait une allonge naturelle de 1,50 mètre de plus. (Le sort confère donc une allonge naturelle de 3 mètres à la plupart des prêtres de taille M.) Le personnage bénéficie d''un bonus de malfaisance de +1 aux jets d''attaque avec la griffe noire, ce bonus augmentant de +1 tous les quatre niveaux de lanceur de sorts (+2 au niveau 5, +3 au niveau 9, etc.). Les griffes infligent 1d6 points de dégâts tranchants, +1 point d''énergie négative par niveau de lanceur de sorts (jusqu''à un maximum de +10). Si la victime réussit un jet de Volonté, les dégâts d''énergie négative sont réduits de moitié.</p>
<p>Le prêtre peut également profiter des griffes pour porter des attaques de contact, auquel cas le bonus de malfaisance aux jets d''attaque s''applique également. Une attaque de contact couronnée de succès inflige simplement les dégâts d''énergie négative. Ceux-ci soignent bien évidemment les morts-vivants.</p>
<p>Seul un initié de Cyric peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Griffe noire' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Griffe noire' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Lance de glace', 4, NULL, NULL, 1, 1, 1, 0, 0, '5 kilos de glace ou de neige. La plupart des mages lancent ce sort dans les régions recouvertes de neige ou de glace, mais les restes d''une tempête de grêle font également l''affaire', 'moyenne (30 m + 3 m/niveau)', '', 'une lance de glace', '1 action simple', 'instantanée', 'Oui', 'voir description', '<p>Ce sort transforme une masse de glace en une longue lance meurtrière magiquement propulsée vers la cible désignée. Le personnage doit réussir une attaque à distance accompagnée d''un bonus de +4 pour toucher la cible. En cas de réussite, la lance dé glace inflige 1d6 points de dégâts perforants pour moitié, le reste relevant de dégâts de froid. De plus, la cible doit réussir un jet de Vigueur sous peine d''être étourdie pendant 1d4 rounds. Quel que soit le résultat de l''attaque, la lance de glace se brise.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Lance de glace' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Lance de glace' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Lance de glace' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Druide' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Lance de glace' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Kleptomage' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Lance de glace' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT s.so_id, 4, d.do_id FROM dd_sorts s JOIN dd_domaines d ON d.do_nom = 'Glace'
WHERE s.so_nom = 'Lance de glace' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_so_id = s.so_id AND x.sd_do_id = d.do_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Linceul de feu', 1, NULL, 'feu', 1, 1, 1, 0, 0, 'une pincée de salpêtre, un petit morceau de phosphore et un bout de dentelle ou de toile d''araignée', 'courte (7,50 m + 1,50 m/2 niveaux)', '1 créature', '', '1 action simple', '1 round/niveau', 'Oui', 'Réflexes, annule ; voir description', '<p>Parfois qualifié de « tueur de trolls », ce sort embrase une créature, lui infligeant 2d6 points de dégâts de feu si elle rate son jet de sauvegarde. A chaque round suivant, elle subit de nouveau 2d6 points de dégâts de feu jusqu''à la fin du sort. Chaque fois que la cible entreprend une action de mouvement pour éteindre les flammes, elle a droit à un nouveau jet de Réflexes. Après le premier round, les flammes disparaissent et le sort s''achève dès que le sujet réussit un jet de sauvegarde.</p>
<p>En plus des effets mentionnés ci-dessus, la cible projette des flammes alentour à chaque round où elle est victime des flammes. Par conséquent, les créatures situées dans un rayon de 3 mètres subissent 1d4 points de feu par round. Un jet dé Réflexes réussi permet d''annuler ces dégâts.</p>
<p>Seul un initié de Kossuth peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Linceul de feu' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Linceul de feu' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Linceul de feu' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Linceul de feu' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Main de feu', 1, NULL, 'lumière', 1, 1, 0, 0, 0, NULL, 'contact', '1 créature touchée', '', '1 action simple', '1 minute/niveau ou jusqu''à utilisation', 'Oui', 'aucun', '<p>Le prêtre enveloppe sa main d''un amas de particules de lumière semblable à un crépitement permanent d''étincelles. Cette lueur affiche la couleur de son choix, qu''il est impossible de modifier une fois le sort lancé. La main de feu offre une luminosité égale à celle d''une bougie mais aucune chaleur. En outre, elle ne saurait embraser quelque objet que ce soit.</p>
<p>La main de feu peut être utilisée telle une attaque de contact au corps à corps jusqu''à une fois tous les deux niveaux. Quand elle touche une créature vivante, elle lui inflige 1d8 points de dégâts, +1 point/niveau de lanceur de sorts (jusqu''à un maximum de +5). Contre les morts-vivants, la main de feu inflige 2d6 points de dégâts, + 1 point/niveau de lanceur de sorts (jusqu''à un maximum de +5).</p>
<p>Contre les cibles qui ne sont ni mortes ni vivantes (comme les créatures artificielles), elle ne produit aucun effet.</p>
<p>Seul un initié de Séluné peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Main de feu' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 1 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Main de feu' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Manteau magique', 5, NULL, NULL, 1, 1, 0, 0, 0, NULL, 'contact', '1 créature touchée', '', '1 round entier', '10 minutes/niveau', 'Oui (inoffensif)', 'Volonté, annule (inoffensif)', '<p>L''initié de Mystra enveloppe le sujet d''une aura magique qui le protège contre certains sorts précis. Durant l''incantation, le personnage désigne donc un sort de 4e niveau ou moins tous les quatre niveaux de lanceur de sorts. Les sorts en question ne doivent pas prendre effet par le biais d''une attaque de contact.</p>
<p>Lorsque que le sujet d''un manteau magique est la cible d''un sort (ou lorsqu''il est pris dans la zone d''effet d''un sort) contre lequel il est protégé, le manteau absorbe alors totalement l''énergie de celui-ci Le sujet peut ensuite user de cette énergie absorbée de deux façons :</p>
<p><em>Guérison</em>. La cible bénéficie d''un sort de soins du niveau du sort absorbé. Le sort de soins prend effet comme si l''initié de Mystra l''avait lui-même lancé sur la cible. Si cette dernière est inconsciente, le sort-absorbé se transforme automatiquement en sort de soins, sans qu''on lui demande son avis.</p>
<p><em>Réception</em>. L''énergie déclenche immédiatement un sort visant la cible. L''initié de Mystra choisit ce sort lorsqu''il lance le manteau magique. Toutefois, celui-ci doit être un sort de 4e niveau ou moins préparé au moment de l''incantation, mais que le personnage ne perd pas. Il doit bien évidemment pouvoir affecter la cible. Si le niveau du sort lancé par son adversaire est moins élevé que celui choisi par le personnage, la cible est incapable d''activer l''effet prévu. Le sort que désigne l''initié de Mystra est lancé comme s''il le jetait lui-même sur la cible. Enfin, la durée du sort déclenché peut être supérieure à celle du manteau magique.</p>
<p>Par exemple, l''initié de Mystra peut choisir éclair en qualité de sort absorbé par le manteau magique, puis cercle magique contre le Mal en qualité de sort dont -bénéficiera le sujet. Ainsi, chaque fois qu''il se trouvera dans la zone d''un éclair (ou de quelque autre sort de 3e niveau ou plus qu''aura choisi le personnage), le sujet bénéficiera sur-le-champ d''un cercle magique contre le Mal.</p>
<p>Le manteau magique peut absorber 1d4 niveaux de sorts, +1 par tranche de quatre niveaux de lanceur de sorts (jusqu''à un maximum de 1d4+5). Si le manteau magique n''a pas la capacité nécessaire pour absorber un sort, il n''a aucun effet. Une fois les niveaux de sort absorbés, le manteau magique est dissipé.</p>
<p>Seul un initié de Mystra peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Manteau magique' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 6 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Manteau magique' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Marche des pierres', 6, NULL, 'téléportation', 1, 1, 1, 0, 0, 'la préparation de chacune des extrémités nécessite une sorte de pâte faite à partir de rubis et d''ambre, pour une valeur de 1 500 po. Pour lancer le sort, il faut également se munir d''un diamant d''une valeur de 2 500 po. Une fois le sort lancé, l''activation de l''une des pierres ne requiert aucune composante matérielle', 'contact', 'pierre touchée', '', '10 minutes', 'permanente jusqu''à utilisation', 'Oui (objet)', 'Volonté, annule (objet)', '<p>L''initié de Baine relie magiquement un lieu à un autre afin que le sujet puisse prononcer un mot de commande et être téléporté à l''autre bout.</p>
<p>Avant l''incantation, le personnage doit préparer les extrémités du lien, chacune devant être une surface de pierre de 1,50 mètre de côté. Ces préparatifs demandent 1 heure et conviennent à plusieurs utilisations du sort tant que les pierres ne sont pas endommagées.</p>
<p>Une fois le sort lancé, le jeteur de sorts fixe un mot de commande et touche l''une des pierres. Toute créature proférant ce mot de commande tout en se tenant sur l''une des pierres est instantanément téléportée (via téléportation suprême) vers l''autre extrémité. Les pierres fonctionnent une fois tous les quatre niveaux de lanceur de sorts. À chaque fois, elles sont capables de transporter une créature de taille M ou inférieure consentante, plus une créature de taille M ou inférieure consentante (chacune encombrée à concurrence de sa charge maximale) ou son équivalent tous les. trois niveaux de lanceur de sorts. Une créature de taille G compte pour deux créatures de taille M, une créature de taille TG compte pour deux créatures de taille G, etc. Toutes les créatures téléportées doivent être contact les unes avec les autres.</p>
<p>En raison du lien spécial qui existe entre les pierres, les abjurations comme interdiction et verrou dimensionnel ne gênent en rien l''utilisation de ce sort. Un sort de scellement de portail lancé sur l''une ou l''autre des pierres supprime l''effet de marche des pierres.</p>
<p>Seul un initié de Baine peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Marche des pierres' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 6 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Marche des pierres' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Marée guerrière', 4, NULL, NULL, 1, 1, 0, 0, 1, NULL, 'courte (7,50 m + 1,50 m/2 niveaux)', 'le jeteur de sorts et jusqu''à 1 créature/niveau, aucune ne devant se trouver à plus de 9 mètres l''une del''autre', '', '1 action simple', '1 round/niveau', 'Oui', 'Volonté, annule', '<p>Le prêtre dérobé l''énergie de ses proies. Les cibles autres que lui sont victimes d''un malus de circonstances de -1 aux jets de sauvegarde, jets d''attaque et jets de dégâts avec une arme. Tant qu''un ennemi au moins est affecté par le sort, le prêtre jouit des avantages suivants.</p>
<p>Il bénéficie d''un bonus de +1 aux jets d''attaque et aux jets de Réflexes, mais également d''un bonus d''esquive de +1 à la CA. Si la situation lui fait perdre son bonus à la CA, ce bonus d''esquive est annulé.</p>
<p>Tous ses modes de déplacement augmentent de 9 mètres, jusqu''à un maximum égal à deux fois sa vitesse de déplacement normale. Il s''agit d''un bonus d''altération.</p>
<p>Quand il effectue une attaque à outrance, le prêtre porte une attaque supplémentaire à l''aide de son arme. Celle-ci exploite son bonus à l''attaque maximal, auquel on ajoute les modificateurs habituels. Cet effet ne se cumule pas avec d''autres, comme un sort de rapidité ou la propriété spéciale du même nom de son arme.</p>
<p>S''il ne porte pas d''attaque supplémentaire, le prêtre peut lancer un sort de niveau 0 ou de 1er niveau préparé au prix d''une action libre, comme s''il lui appliquait le don Incantation rapide. Tous les deux niveaux de lanceur de sorts, au-delà du niveau 9, le prêtre peut appliquer cet avantage à un niveau de sort de plus (aux sorts de 1° niveau au niveau 11, de 3 niveau au niveau 13, de 4e niveau au niveau 15 et de 5e niveau au niveau 17). Les sorts de 6'' niveau ou plus ne sont pas affectés.</p>
<p>Si tous lés sujets sont libérés du sort (par la mort, une zone d''antimagie, une dissipation de la magie couronnée de succès, etc.), le sort prend fin sur-le-champ.</p>
<p>Seul un initié de Baine peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Marée guerrière' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Marée guerrière' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Masse d''Odo', 1, NULL, 'force', 1, 1, 0, 0, 1, NULL, '0 m', '', 'masse d''énergie', '1 action simple', '1 round/niveau', 'Oui', 'Vigueur, annule ; voir description', '<p>Le prêtre crée une masse d''armes d''énergie luisante qui apparaît dans sa main. Quand il s''en sert contre une créature, il lui faut effectuer une attaque de contact au corps à corps. S''il touche, la masse d''Odo inflige 1d6 points de dégâts de force par niveau de lanceur de sorts (jusqu''à un maximum de 10d6). Les morts-vivants subissent +1 point de dégâts par niveau de lanceur de sorts (jusqu''à un maximum de +10). Toute créature frappée par la masse doit réussir un jet de Vigueur sous peine d''être paralysée pendant 1 round. Le personnage peut porter une attaque à l''aide de la masse au round où celle-ci est convoquée.</p>
<p>La masse reste dans la main dit personnage mais ne disparaît pas s''il lance un autre sort. Lorsqu''il tient cette arme et qu''il est la cible d''un sort, il peut faire en sorte que la masse absorbe celui-ci,</p>
<p>Lorsque la masse frappe une créature, absorbe un sort:ou tombe de la main du jeteur de sorts pour une raison ou une autre, elle disparaît. Cependant, l''endroit même où elle disparaît luit tel un effet de lumière jusqu''au terme de la durée du sort.</p>
<p>Seul un initié de Heaum peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Masse d''Odo' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Masse d''Odo' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Métamorphose diabolique', 4, 'Métamorphose', 'Mal', 1, 0, 1, 0, 0, 'un os de créature fiélon, de créature demi-fiélon, de démon ou de diable', '', '', '', '', '1 minute/niveau', NULL, NULL, '<p>À l''exception de ce qui suit, ce sort est semblable à Métamorphose. Le mage est capable d''adopter la forme de n''importe quel créature fiélon, démon ou diable qu''il est possible d''appeler par le biais de convocation de monstres I, II, III ou IV. Il ne peut prendre qu''une seule forme par utilisation du sort, mais il gagne les pouvoirs extraordinaires, magiques et surnaturels de la créature choisie. Il prend alors le type Extérieur. Ainsi, les sorts et effets blessant ou protégeant les Extérieurs d''alignement mauvais l''affectent. Un sort censé le bannir vers son plan d''origine met un terme au sort et le laisse dans un état chancelant pendant 1 round par niveau de lanceur de sorts. Toutefois, cela n''expédie pas le personnage vers un autre plan.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Métamorphose diabolique' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 6 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Métamorphose diabolique' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 6 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Métamorphose diabolique' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Mur de clair de lune', 1, NULL, 'Bien, lumière', 1, 1, 0, 0, 0, NULL, 'moyenne (30 m + 3 m/niveau)', '', 'surface verticale de 1,50 m de côté/niveau max.', '1 action simple', '1 round/niveau', 'Oui', 'aucun', '<p>Un rideau scintillant et immobile de lumière blafarde apparaît. Celui-ci ne s''appuie pas forcément sur une surface solide et n''importe quelle créature peut le traverser. Les morts-vivants qui le touchent subissent néanmoins 4d12 points de dégâts. De leur côté, les créatures d''alignement mauvais et celles qui portent le symbole maudit de Shar ou d''Umberlie subissent 1d10 points de dégâts. Enfin, les objets magiques qui entrent en contact avec le rideau de lumière brillent d''une lueur féerique rougeâtre pendant 1d4+1 rounds.</p>
<p>Le rideau éclaire vivement sur 6 mètres et faiblement sur 6 mètres de plus (soit 12 mètres au total). Le mur de clair de lune contre et dissipe les sorts de ténèbres de 5e niveau ou moins dans un rayon de 12 mètres. Si le personnage évoque le mur pour qu''il se manifeste en un lieu occupé par des créatures, chacune subit les dégâts comme si elle le traversait.</p>
<p>Il est possible d''user de permanence sur un sort de mur de clair de lune. Le jeteur de sorts doit être de niveau 12 au moins et sacrifier 2 000 PX</p>
<p>Seul un initié de Séluné peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Mur de clair de lune' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Mur de clair de lune' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Mur de sable', 6, 'Création', 'terre', 1, 1, 1, 0, 1, 'une poignée de sable', 'moyenne (30 m + 3 m/niveau)', '', 'mur de sable de 1,50 m de côté/niveau max.', '1 action simple', 'concentration + 1 round/niveau', 'Non', 'aucun', '<p>Ce sort invoque un mur de sable opaque et visqueux. Il doit être lancé de manière à reposer sur une surface solide. Une fois le sort jeté, le mur est immobile. Le sable est suffisamment épais pour bloquer les attaques à distancé, conférant un abri en rapport avec sa taille, mais n''importe quelle créature peut tenter de le traverser. Pour ce faire, il est nécessaire d''entreprendre une action complexe et de réussir un test de Force. Pour chaque tranche de 5 points obtenue au-dessus de 15, l''intéressé parcourt 1,50 mètre.</p>
<p>Les créatures situées au sein du mur de sable sont aveuglées et assourdies. Du reste, elles sont incapables de parler et de respirer. Elles commencent donc à suffoquer si elles y restent trop longtemps. Il est impossible d''y lancer des sorts à composante verbale, les autres types de sort passant forcément par un test de Concentration (DD 20 + niveau de sort).</p>
<p>Il est possible d''attaquer un personnage situé au sein du mur de sable ou de l''autre côté de celui-ci à condition de remplir les critères suivants. Premièrement, l''attaquant doit avoir une idée générale de l''endroit où se trouve la cible (en gros, il faut qu''il l''ait vue entrer au sein de l''effet). Deuxièmement, cette même cible doit se trouver à portée d''allonge de l''assaillant (ou, dans le cas de créatures situées de l''autre côté du mur, celui-ci ne doit pas être plus large que son allonge). Quand bien même, la cible jouit d''un abri et d''un camouflage total.</p>
<p>Une flamme non protégée qui est plongée dans le mur de sable est instantanément éteinte.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Mur de sable' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Mur de sable' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Mur de sable' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Mur de sable' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Druide' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Mur de sable' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Façonneur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Mur de sable' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Leg du dragon de sable' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Mur de sable' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Non-vie après la mort', 2, NULL, 'Mal', 1, 1, 1, 0, 0, 'un morceau d''obsidienne taillé en forme de cœur, placé sur la poitrine du sujet, et un onyx noir d''une valeur de 50 po par DV de la créature visée au moment où le sort est lancé, que l''on met dans la bouche du sujet', 'contact', 'créature consentante et vivante touchée', '', '10 minutes', 'permanente jusqu''à utilisation', 'Non', 'aucun', '<p>L''initié arrache une partie de sa force vitale à une créature, la corrompt à l''aide d''énergie négative et du pouvoir de la non-vie, puis engendre en elle une transformation blasphématoire si elle venait à mourir.</p>
<p>Le sujet du sort perd 2 points de Constitution. Au moment de sa mort, l''énergie vitale corrompue entame un lent changement, faisant de lui un rejeton des cryptes dès le coucher de soleil suivant. Si ses restes sont détruits, le sort ne peut faire de lui un mort-vivant.</p>
<p>Si le sort est dissipé avant que le sujet ne meure, il ne recouvre pas ses 2 points de Constitution.</p>
<p>Seul un initié de Baine peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Non-vie après la mort' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 7 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Non-vie après la mort' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Orbe luisant de Nchaser', 1, NULL, 'lumière', 1, 1, 0, 1, 0, 'Focalisateur : la sphère en. verre dans laquelle est placée la lumière. Un tel orbe a une solidité de 0 et 2 points de résistance', 'contact', '', 'ource de lumière magique contrôlable', '1 action simple', 'permanente', 'Non', 'aucun', '<p>Ce sort dispose une source de lumière magique dans une sphère en verre de la taille d''un poing humain. Le personnage contrôle mentalement l''intensité de la lumière générée, du moins si l''orbe se trouve dans un rayon de 9 mètres. Le rayon de la lueur produite va de 0 à 18 mètres. Il n''y a aucune limite au nombre d''orbes que l''on peut posséder. De plus, le personnage peut contrôler l''intensité de chacun de manière indépendante ou groupée.</p>
<p>Si l''orbe luisant de Nchaser est détruit, la magie disparaît. Si le personnage meurt, l''orbe conserve néanmoins son enchantement. Un ensorceleur, magicien ou prêtre capable de lancer de sorts de 4e niveau peut alors en prendre le contrôle en le touchant tout simplement.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Orbe luisant de Nchaser' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Orbe luisant de Nchaser' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Orbe luisant de Nchaser' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Orbe luisant de Nchaser' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Orbite de crâne', 4, NULL, NULL, 1, 1, 0, 0, 0, NULL, 'personnelle', 'le jeteur de sorts', '', '1 action simple', '1 round/3 niveaux', 'Oui', 'aucun ; voir description', '<p>Le prêtre acquiert une attaque de regard à portée courte (7,50 m + 1,50 m/2niveaux) pendant toute la durée du sort. A chaque round, les créatures situées à portée et qui sont à même de le voir doivent réussir un jet de Volonté une fois leur tour de jeu venu pour éviter l''effet. De plus, en entreprenant une action d''attaque, le prêtre peut activement regarder une cible située à portée.</p>
<p>Selon les dés de vie de la cible, l''attaque de regard a l''un des effets suivants.</p>
<p>[[tab:sort-orbite-de-crane]]</p>
<p>Tant que ce sort est actif, les yeux du prêtre sont noirs et pourvus d''iris en forme de crânes.</p>
<p>Seul un initié de Cyric peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Orbite de crâne' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Orbite de crâne' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Pacte du martyr', 2, NULL, 'Bien', 1, 1, 0, 0, 0, NULL, 'moyenne (30 m + 3 m/niveau)', '1 créature consentante', '', '1 action simple', 'instantanée', 'Oui (inoffensif)', 'aucun', '<p>Le prêtre échange son total de points de vie avec une créature qui en possède moins que lui Si la cible était inconsciente et mourante, le personnage l''est également. Si la cible était inconsciente mais stabilisée, le personnage l''est aussi. Le sort ne transfère que les points de vie réels, pas les points de vie temporaires. Pacte du martyr ne fonctionne pas si le prêtre a moins de points de vie que la cible au moment où il lance le sort.</p>
<p>Seul un initié d''Ilmater peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Pacte du martyr' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Pacte du martyr' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Parade d''énergie', 5, NULL, NULL, 1, 1, 0, 0, 1, NULL, '3 m', 'le jeteur de sorts et les alliés situés dans une émanation de 3 m de rayon', '', '1 round entier', '1 minute/niveau', 'Oui', 'aucun (voir description)', '<p>Le personnage crée une sphère de force transparente et immobile centrée sur lui. Cette sphère illumine le périmètre qu''elle couvre avec la même intensité qu''une bougie, mais également tout ce qui est situé dans un rayon de 1,50 mètre.</p>
<p>Le jeteur de sorts et ses alliés peuvent- y pénétrer sans la moindre difficulté. Toute autre créature tentant d''en faire de même doit d''abord réussir un jet de Volonté. Bien qu''une créature puisse quitter la zone en toute liberté, il lui faut de nouveau réussir un jet de Volonté si elle souhaite y retourner, même s''il s''agit du jeteur de sorts ou de l''un de ses alliés. Les créatures situées dans la zone au moment où le sort est lancé n''en sont pas expulsées.</p>
<p>Tant qu''ils se trouvent dans la zone d''effet du sort, le personnage et ses alliés bénéficient d''un bonus de sainteté de +2 aux jets de sauvegarde contre les effets générés par les créatures d''alignement mauvais. Les créatures situées dans la zone qui ne sont pas les alliées du lanceur de sorts n''en profitent pas. La parade d''énergie n''empêche pas les sorts et objets de pénétrer en son sein, aussi est-il possible que deux créatures situées de chaque côté de la barrière combattent sans problème.</p>
<p>Cependant, les créatures attaquant à mains nues ou usant d''armes naturelles doivent réussir un jet de Volonté, à chaque round pour que leurs attaques aient une chance de pénétrer la parade d''énergie.</p>
<p>Seul un initié de Heaum peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Parade d''énergie' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Paladin' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Parade d''énergie' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Parade d''énergie' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Phylactère magique', 4, NULL, NULL, 1, 1, 0, 0, 1, NULL, 'contact', 'parchemin touché', '', '10 minutes', 'permanente jusqu''à utilisation', 'Oui (objet)', 'aucun (objet)', '<p>L''initié de Mystra fixe un certain nombre de . paramètres déclencheurs pour le compte d''un parchemin renfermant un sort qui figure sur sa liste de sorts. Le sort doit être susceptible d''affecter le personnage et ne peut être d''un niveau supérieur au quart de son niveau de lanceur de sorts (jusqu''au 5e niveau maximum, arrondir à l''entier inférieur). Toutes les restrictions d''utilisation des parchemins s''appliquent normalement (comme la valeur de caractéristique minimale ou là nécessité d''un test de niveau de lanceur de sorts).</p>
<p>Les conditions visant à ce que le sort prenne effet peuvent être d''ordre général, mais elles doivent être claires, telles qu''elles sont définies dans la description du sort prévoyance. Par exemple, un phylactère magique accompagnant un parchemin de respiration aquatique pourra partir du principe qu''à chaque fois que l''initié de Mystra est immergé, le sort prend effet instantanément. De même, un phylactère magique utilisé conjointement avec feuille morte pourra se déclencher chaque fois que le personnage chute d''une hauteur supérieure à 1,20 mètre. Si des complications se présentent, le phylactère magique risque d''échouer. Quels que. soient les désirs du jeteur de sorts, le parchemin n''est activé qu''en fonction des conditions établies.</p>
<p>Une fois les conditions prédéterminées en vigueur, le sort du parchemin est lancé sur l''initié, comme si celui-ci avait entrepris une action simple pour le lire. Si le parchemin renferme un sort qui ne figure pas sur la liste du personnage ou que les limitations propres au sort empêchent qu''il soit lancé, il ne se passe rien et la magie du phylactère est dissipée.</p>
<p>Le parchemin ainsi préparé doit être fixé au bras ou au front du jeteur de sorts (généralement, on le roule ou on le dispose dans une petite boite) et compte pour un bandeau ou bracelet en terme de limite de fonctionnement des objets magiques.</p>
<p>Phylactère magique doit être lancé une fois par sort devant prendre effet.</p>
<p>Si un autre individu porte le phylactère magique, le sort prend fin. Le jeteur de sorts peut l''ôter et le remettre sans malus, mais si 24 heures s''écoulent sans que qu''il l''ait porté, le sort prend également fui. À ce sujet, la fin du sort n''affecte en rien la magie que renferme le parchemin.</p>
<p>Seul un initié de Mystra peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Phylactère magique' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Phylactère magique' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Possession animale', 2, NULL, NULL, 1, 1, 1, 0, 0, 'une coupe remplie d''encens et de la nourriture dont l''animal est friand', 'courte (7,50 m + 1,50 m/2 niveaux)', '1 animal', '', '1 round entier', '1 round/niveau (T)', 'Oui', 'Volonté, annule', '<p>Le prêtre projette son esprit dans le corps d''un animal, le forçant ainsi à se comporter selon ses désirs. La cible doit être un animal normal (ni une créature magique, ni une vermine, ni un autre type de monstre) et le niveau de lanceur de sorts du prêtre doit être supérieur à ses dés de vie. L''esprit de l''animal reste dans son corps, mais il n''a aucun contrôle sur lui tant que le prêtre exerce sa coercition. Le corps de ce dernier reste comateux pendant la durée du sort.</p>
<p>Une fois dans le corps de l''animal, le prêtre conserve son Intelligence, sa Sagesse, son Charisme, son niveau, ses classes, son bonus de base à l''attaque, ses bonus de base aux sauvegardes, son alignement et ses. pouvoirs mentaux. Il ne peut lancer de sorts sous cette forme que s''il possède le don Incantation animale ou quelque pouvoir équivalent. Il lui est impossible d''activer les pouvoirs extraordinaires ou surnaturels du corps. De plus, il subit 1 point de dégâts tous les 2 points de dégâts subis par le corps de l''animal. Si l''animal est tué alors qu''il le possède, le prêtre doit réussir un jet de Vigueur (DD 10) sous peine de mourir.</p>
<p>Si le corps du prêtre est détruit pendant qu''il hante l''animal, il meurt à la fin du sort.</p>
<p>Seul un initié de Malar peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Possession animale' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Possession animale' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Projection d''épines', 4, NULL, NULL, 1, 1, 0, 0, 0, NULL, 'courte (7,50 m + 1,50 m/2 niveaux)', 'jusqu''à 1 créature/niveau', '', '1 action simple', 'instantanée', 'Oui', 'Vigueur, partiel', '<p>L''initié jette une plante épineuse dans la direction de la cible. Le sort transforme alors le végétal en une véritable volée d''épines qui infligent des dégâts à la cible choisie.</p>
<p>Le personnage effectue une attaque à distance normale contre chaque cible, sans malus bien qu''il n''en connaisse pas le maniement. Les épines infligent 1d6 points de dégâts par niveau de lanceur de sorts (jusqu''à un maximum de 20d6), mais le total peut être divisé entre les différentes cibles. Cette répartition doit néanmoins être établie avant d''effectuer les jets d''attaque. Ainsi, un initié de la Nature de niveau 8 peut viser une créature dans l''espoir de lui infliger 8d6 points de dégâts, deux créatures pour leur infliger 4d6 points de dégâts chacune, quatre créatures pour leur infliger 2d6 points de dégâts chacune, etc. Les dégâts sont répartis comme le souhaite le lanceur de sorts.</p>
<p>Une créature subissant des dégâts se tord de douleur comme si son corps était recouvert d''orties brûlantes et est fiévreuse pendant 2d4 rounds. Un jet de Vigueur réussi annule l''effet de fièvre.</p>
<p>Seul un initié de la Nature peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Projection d''épines' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Projection d''épines' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Protection contre le feu', 4, NULL, NULL, 0, 0, 0, 0, 0, NULL, '', '', 'cube de 6 m de côté/niveau (F)', '', '1 heure/niveau', 'Non', 'aucun', '<p>A l''exception de ce qui figure ci-dessus, ce sort fonctionne sur le même principe qu''extinction des feux. De plus, il produit les effets suivants. Tant que la protection contre le feu est en place, aucun effet de feu magique ne peut agir au sein de la zone. Cet effet est semblable à celui d''une zone d''antimagie, mais seuls les sorts de feu sont réprimés. Les feux non magiques créés dans la zone ou apportés en son sein sont également mouchés.</p>
<p>Seul un initié de la Nature peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Protection contre le feu' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Druide' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Protection contre le feu' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Protection contre le feu' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Protection naturelle', 5, NULL, NULL, 1, 1, 1, 0, 0, 'une pommade faite à partir de sirop de pêche et de cinabre', 'personnelle', 'le jeteur de sort', '', '1 round', '1 minute/niveau', NULL, NULL, '<p>Ce sort permet au personnage de survivre à certaines épreuves (comme un bain dans l''huile bouillante ou une avalanche) qui sont généralement mortelles. Ce sort ne protège le personnage que d''un évenement naturel, pas d''un sort ou des agissements d''une créature (comme le souffle d''un dragon ou les coups d''épée d''un bandit). Lors de l''incantation, le personnage doit définir la situation contre laquelle il souhaite se prémunir. Le sort n''est efficace qu''en cas de manifestation de la situation ainsi définie, auquel cas le personnage protégé par ce sort ne subit ni dégâts, ni inconfort. Cependant, le sort ne protège pas les objets qu''il transporte.</p>
<p>Quand le sort cesse de produire son effet, la situation ou l''évènement retrouve toutes leurs dangeristés pour le lanceur de sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Protection naturelle' AND so_res_id = 63);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT s.so_id, 8, d.do_id FROM dd_sorts s JOIN dd_domaines d ON d.do_nom = 'Repos éternel'
WHERE s.so_nom = 'Protection naturelle' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_so_id = s.so_id AND x.sd_do_id = d.do_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Rayon rubis d''inversion', 5, NULL, NULL, 1, 1, 1, 0, 0, 'un rubis d''une valeur de 1 000 po', 'moyenne (30 m + 3 m/niveau)', 'danger naturel ou magique ; voir description', '', '1 action simple', 'instantanée', 'Non', 'aucun', '<p>De la main tendue du mage jaillit une ligne de lumière rouge rubis capable d''annuler un danger ordinaire ou magique. Chaque version du sort peut viser l''un des dangers ci-dessous et le « corriger » de la manière décrite. Sauf indication contraire, le sort affecte indifféremment les dangers ordinaires et magiques du type indiqué. Par exemple, un rayon rubis d''inversion peut éliminer les toiles d''une araignée monstrueuse ou les effets du sort toile d''araignée.</p>
<ul><li>Tout piège visé par le rayon se déclenche. Cette version du sort peut avoir des effets défavorables sur les créatures situées dans la zone du piège. Pour lancer ce sort sur un piège, le mage doit évidemment l''avoir remarqué.</li><li>Le sort défait nœuds et entraves (chaînes, menottes, etc.). Enchevêtrement et effets magiques similaires sont dissipés. Les portes (et coffres, tiroirs, armoires, etc.)verrouillées, barrées ou protégées par verrou du mage s''ouvrent.</li><li>Un trou d''un rayon de 30 centimètres maximum apparaît dans un mur de force, une cage de force ou tout effet magique similaire. Cette fonction ne détruit pas l''effet visé, mais les créatures qui y sont emprisonnées ont là une chance de s''échapper.</li><li>Une créature métamorphosée, pétrifiée ou transformée retrouve sa forme naturelle.</li><li>Un sort de possession est dissipé si le rayon rubis d''inversion vise le réceptacle en cristal renfermant l''âme du lanceur de sorts.</li><li>Toiles, mucus, graisse et autres substances entravant les déplacements sont détruits dans une zone de 6 mètres de rayon. (Traitez cet effet comme une émanation)</li></ul>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Rayon rubis d''inversion' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 7 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Rayon rubis d''inversion' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 7 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Rayon rubis d''inversion' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Sens aux aguets', 7, NULL, NULL, 1, 1, 0, 0, 0, NULL, 'contact', '1 créature touchée', '', '1 action simple', '10 minutes/niveau', 'Oui (inoffensif)', 'Volonté, annule (inoffensif)', '<p>Ce sort intensifie les sens et la perception du danger du sujet. Il bénéficie donc d''un bonus d''intuition de +4 aux tests de Détection et Perception auditive. De plus, il gagne l''esquive instinctive et conserve son bonus de Dextérité à la CA (le cas échéant) même s''il est pris au dépourvu ou attaqué par un adversaire invisible. (Il perd néanmoins son bonus de Dextérité à la CA s''il est immobilisé.)</p>
<p>Seul un initié de Heaum peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Sens aux aguets' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Sens aux aguets' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Sévère réprobation de Nybor', 3, 'Coercition', 'mental', 0, 0, 0, 0, 0, NULL, '', '', '', '', '1 round/niveau', NULL, 'voir description', '<p>Ce sort fonctionne sur le même principe que Doux rappel de Nybor, si ce n''est que la cible doit réussir un jet de sauvegarde sous peine de mourir aussitôt. Si elle survit, il lui faut réussir un jet de Volonté pour échapper aux effets suivants. En cas d''échec, elle est hébétée durant pendant 1d4 rounds.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Sévère réprobation de Nybor' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 7 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Sévère réprobation de Nybor' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 7 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Sévère réprobation de Nybor' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Toile de lune', 5, NULL, NULL, 1, 1, 0, 0, 1, NULL, 'contact', '', 'barrière d''énergie de 3 m de haut (cercle de 1,50 m de diamètre ou ligne de 3 m de long)', '1 action simple', '10 minutes/niveau', 'Oui', 'aucun', '<p>Le prêtre crée une barrière d''énergie immobile qui dégage une douce lueur blafarde. Cette barrière peut prendre la forme d''un bouclier de 1,50 mètre de diamètre et de 3 mètres de haut disposé autour d''une créature consentante, ou d''une plaque de 3 mètres de côté orientée horizontalement (par exemple, en travers d''un passage) ou verticalement (sur une fosse), du moins tant que l''un de ses bords est en contact avec une surface solide.</p>
<p>La barrière a une face intérieure et une face extérieure. De l''intérieur, elle est transparente et n''importe quelle créature peut la traverser. De l''extérieur, elle est opaque et quasi infranchissable. Nulle créature ou attaque ne peut donc passer dans ce sens. Les créatures protégées par la toile de une bénéficient d''un abri et d''un camouflage total contre les attaques venues de l''extérieur.</p>
<p>Seul un initié de Séluné peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Toile de lune' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Toile de lune' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Transcription de symbole', 5, NULL, NULL, 1, 1, 0, 1, 0, 'Focalisateur : un bout d''ardoir décapé et poli d''un côté', 'contact', 'symbole magique touché', '', '1 action simple', '10 minutes/niveau ou jusqu''à utilisation', 'Non', 'aucun', '<p>La main du jeteur de sorts bénéficie d''une protection magique lui permettant de toucher un symbole magique (comme une glyphe de garde ou un symbole de mort) sans le déclencher. Le symbole touché est arraché de son emplacement et reste dans la main du jeteur de sorts, tel un sort de contact.</p>
<p>Pour ramasser le sort, le personnage doit effectuer un test de niveau de lanceur de sort (DD 20 + niveau du sort). En cas d''échec, le glyphe ou le symbole est déclenché. En cas de transfert réussi, le jeteur de sorts peut, au prix d''une action simple, poser le symbole sur une surface (mais pas une créature) seyant au sort concerné. Ensuite, le symbole transféré agit normalement et conserve toutes ses conditions de déclenchement (quoique son nouvel habitat puisse les empêcher ou les rendre difficiles).</p>
<p>Tant que le jeteur de sorts reste concentré, il a le droit de porter le symbole. Si sa concentration est brisée ou que le sort arrive à son terme, le symbole est déclenché et seul le jeteur de sort en est la cible, même s''il n''a aucunement rempli les conditions de déclenchement. Le jet de sauvegarde et la résistance à la magie sont les mêmes que pour le symbole originel. Le seul moyen sûr de se débarasser du sort est de le déposer sur une surface susceptible de le recevoir.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Transcription de symbole' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 8 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Transcription de symbole' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 8 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Transcription de symbole' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT s.so_id, 8, d.do_id FROM dd_sorts s JOIN dd_domaines d ON d.do_nom = 'Runes'
WHERE s.so_nom = 'Transcription de symbole' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_so_id = s.so_id AND x.sd_do_id = d.do_id);

INSERT INTO dd_sorts (so_nom, so_co_id, so_branche, so_registre, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_description, so_res_id, so_public, so_visible, so_ruleset_var_id)
SELECT 'Triple masque', 9, 'Ombre', NULL, 1, 1, 0, 0, 1, NULL, 'moyenne (30 m + 3 m/niveau)', '', 'trois images d''ombre', '1 action simple', '1 round/niveau (T)', 'Non', 'Volonté, dévoilé (en cas d''interaction)', '<p>L''initié crée trois images d''ombre de lui-même. Celles-ci lui ressemblent, ont une odeur semblable à la sienne et font les mêmes bruits que lui, mais elles sont intangibles. Au prix d''une action libre exécutée à son tour de jeu, le personnage peut basculer sur les sens d''une ombre ou recouvrer les siens. Quand il use des sens d''une ombre, celle-ci reproduit ses gestes (et sa voix), sauf s''il se concentre pour qu''elle se comporte différemment, Les ombres qui ne sont pas contrôlées ne bougent pas et ne réagissent pas davantage. S''il le souhaite, tout sort à portée de contact ou supérieure peut partir de l''ombre contrôlée plutôt que de lui. (L''ombre est quasi réelle, juste assez pour que le personnage lance des sorts par son biais.) Une ombre ne peut se lancer que des sorts qui affectent les ombres.</p>
<p>Les ombres se comportent comme les serviteurs convoqués par serviteur invisible. Elles sont donc dénuées d''intelligence et doivent se contenter d''effectuer des tâches simples, comme ouvrir une porte. Inutile donc de leur demander de résoudre une énigme.</p>
<p>Une ombre contrôlée peut également être programmée pour se déplacer dans une direction précise ou vers un lieu connu de l''initié. Elle se déplace à la vitesse du personnage et progresse jusqu''à atteindre sa destination, sauf si l''initié s''empare d''elle et lui ordonne de se rendre ailleurs. Si l''initié use de changement de plan, porte dimensionnelle, téléportation ou de quelque autre sort l''envoyant dans un autre plan, le sort prend fin.</p>
<p>Habituellement, ce sort permet de se procurer une poignée de faux corps, un qui permet de jeter des sorts en toute sécurité (comme projection d''image) et deux qui se chargent de distraire les ennemis.</p>
<p>Seul un initié de Cyric peut lancer ce sort.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_sorts WHERE so_nom = 'Triple masque' AND so_res_id = 63);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 7 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Triple masque' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);
