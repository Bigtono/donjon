-- sql/2026-11-09_sp-jf5_domaines_mdjf.sql
-- SP-JF5 — Domaines du Manuel des Joueurs de Faerûn : colonne de source dd_domaines.do_res_id, domaines absents,
-- source / dieux / pouvoir des domaines existants et 9 sorts par domaine (dd_sortdomaine).
-- Généré par tools/generer-sp-jf5-domaines.php le 2026-11-09 depuis gemmaline.com. Rejouable. Pas de DELIMITER.

SET NAMES utf8mb4;

SET @col = (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'dd_domaines' AND COLUMN_NAME = 'do_res_id');

SET @ddl = IF(@col = 0, 'ALTER TABLE dd_domaines ADD COLUMN do_res_id INT UNSIGNED DEFAULT NULL COMMENT ''Source -> dd_ressources (NULL = non renseignée)''', 'SELECT ''do_res_id déjà présent'' AS message');

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

UPDATE dd_domaines SET do_res_id = COALESCE(do_res_id, 63), do_dieux = 'Lolth, Selvetarm' WHERE do_nom = 'Araignées';

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Pattes d''araignées' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Araignées' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Nuée grouillante' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Araignées' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Coursier Famtôme' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Araignées' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Vermine géante' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Araignées' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Fléau d''insectes' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Araignées' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Malédiction arachnide' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Araignées' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Araignée de pierre' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Araignées' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Mort rampante' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Araignées' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Métamorphose arachnide' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Araignées' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

INSERT INTO dd_domaines (do_nom, do_pouvoir, do_dieux, do_res_id)
SELECT 'Artisanat', 'Le prêtre jette les sorts de création avec un bonus de +1 au niveau de jeteur de sort. En outre, il gagne le don Talent en qualité de don supplémentaire dans la compétence Artisanat de son choix.', 'Callarduran Doucemains, Dugmaren Brilletoge, Dumathoïn, Flandal Peaudacier, Garl Brilledor, Geb, Gond, Jauhar, Laduguer, Moradin, Thoth', 63
WHERE NOT EXISTS (SELECT 1 FROM dd_domaines WHERE do_nom = 'Artisanat');

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Corde animée' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Artisanat' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Façonnage du bois' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Artisanat' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Façonnage de la pierre' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Artisanat' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Création mineure' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Artisanat' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Mur de pierre' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Artisanat' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Machine fantastique ' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Artisanat' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'création majeure' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Artisanat' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Cage de force' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Artisanat' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Machine fantastique améliorée' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Artisanat' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

INSERT INTO dd_domaines (do_nom, do_pouvoir, do_dieux, do_res_id)
SELECT 'Cavernes', 'Le prêtre gagne le pouvoir nain de connaissance de la pierre. S''il le possède déjà, son bonus racial de connaissance de la pierre aux tests de Fouille visant à remarquer que la pierre a été travaillée passe à de +2 à +4', 'Callarduran Doucemains, Diirinka, Duerra des Abîmes, Dumathoïn, Geb, Ghaunadaur, Grumbar, Gruumsh, Ibrandul, Kurtulmak, La Grande-Mère, Luthic, Segojan Hanteterre, Shar, Skoraeus Os-de-pierre', 63
WHERE NOT EXISTS (SELECT 1 FROM dd_domaines WHERE do_nom = 'Cavernes');

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Détection des passages secrets' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Cavernes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Ténèbres' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Cavernes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Fusion dans la pierre' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Cavernes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Refuge de Léomund' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Cavernes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Passe-muraille' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Cavernes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Orientation' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Cavernes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Mâchoire de pierre ' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Cavernes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Tremblement de terre' AND so_res_id = 3 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Cavernes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Emprisonnement' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Cavernes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

INSERT INTO dd_domaines (do_nom, do_pouvoir, do_dieux, do_res_id)
SELECT 'Charme', 'Une fois par jour, le prêtre peut augmenter sa valeur de Charisme de 4 points. Ce pouvoir dure 1 minutes. On l''active au prix d''une action libre.', 'Bala, Eilistraée, Gargauth, Graz’zt, Hanali Celanil, Leïra, Lliira, Malcanthet, Milil, Oghma, Selan, Sharess, Sharindlar, Sheela Peryroyl, Ssharstrune, Sunie, Trouveur d’Éperon de Wyvern', 63
WHERE NOT EXISTS (SELECT 1 FROM dd_domaines WHERE do_nom = 'Charme');

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Charme-personne' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Charme' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Apaisement des émotions' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Charme' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Suggestion' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Charme' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Espoir' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Charme' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Charme-monstre' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Charme' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Quête' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Charme' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Aliénation mentale' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Charme' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Exigence' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Charme' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Domination universelle' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Charme' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

UPDATE dd_domaines SET do_res_id = COALESCE(do_res_id, 63), do_dieux = 'Abbathor, Jauhar, Jisan, Nephtys, Rhyxali, Shaundakul, Vergadain, Waukeen' WHERE do_nom = 'Commerce';

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Message' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Commerce' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Gemme explosive' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Commerce' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Splendeur de l''aigle' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Commerce' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Communication à distance' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Commerce' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Fabrication' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Commerce' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Vision lucide' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Commerce' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Manoir somptueux de Mordenkainen' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Commerce' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Esprit impénétrable' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Commerce' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Localisation suprême' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Commerce' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

UPDATE dd_domaines SET do_res_id = COALESCE(do_res_id, 63), do_dieux = 'Beshaba, Hathor, Hoar, Jergal, Kelemvor, Savras, Semuanya, Shekinester' WHERE do_nom = 'Destin';

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Coup au but' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Destin' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Augure' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Destin' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Malédiction' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Destin' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Divination' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Destin' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Marque de la justice' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Destin' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Quête' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Destin' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Vision mystique' AND so_res_id = 3 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Destin' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Moment de prescience' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Destin' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Prémonition' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Destin' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

UPDATE dd_domaines SET do_res_id = COALESCE(do_res_id, 63), do_dieux = 'Eilistraée, Ghaunadaur, Kiaransalee, Lolth, Selvetarm, Vhaeraun', do_pouvoir = 'Le prêtre gagne Réflexes surhumains en qualité de don supplémentaire' WHERE do_nom = 'Drows';

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Manteau de sombre puissance' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Drows' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Clairaudience/clairvoyance' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Drows' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Suggestion' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Drows' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Détection du mensonge' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Drows' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Forme arachnide' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Drows' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Dissipation suprême' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Drows' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Parole du chaos' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Drows' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Allié suprême d''outreplan' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Drows' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Portail' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Drows' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

UPDATE dd_domaines SET do_res_id = COALESCE(do_res_id, 63), do_dieux = 'Aerdrië Faenya, Angharradh, Corellon Larethian, Eilistraée, Erevan Ileserë, Fenmarel Mestarine, Hanali Celanil, Labelas Enoreth, Rillifane Rallathil, Sashelas des Profondeurs, Sehanine Archelune, Shevarash, Solonor Thelandira' WHERE do_nom = 'Elfe';

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Coup au but' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Elfe' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Grâce féline' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Elfe' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Collet' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Elfe' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Communion avec la nature' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Elfe' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Orientation' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Elfe' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Chêne animé' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Elfe' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Explosion de lumière' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Elfe' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Aversion' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Elfe' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

UPDATE dd_domaines SET do_res_id = COALESCE(do_res_id, 63), do_dieux = 'Auppenser, Duerra des Abîmes, Ilsensine, Memnor, Sardior' WHERE do_nom = 'Esprit';

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Confusion mineure' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Esprit' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Détection de pensées' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Esprit' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Clairaudience/clairvoyance' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Esprit' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Modification de mémoire' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Esprit' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Brume mentale' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Esprit' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Lien télépathique de Rary' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Esprit' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Aversion' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Esprit' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Esprit impénétrable' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Esprit' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

UPDATE dd_domaines SET do_res_id = COALESCE(do_res_id, 63), do_dieux = 'Berronar Purargent, Botu’Astok, Cyrrollalee, Eldath, Hathor, Hiatea, Isis, Lliira, Luthic, Yondalla' WHERE do_nom = 'Famille';

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Bénédiction' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Famille' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Protection d''autrui' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Famille' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Main du berger' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Famille' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Lien télépathique de Rary' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Famille' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Festin des héros' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Famille' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Protection contre les sorts' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Famille' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_domaines (do_nom, do_pouvoir, do_dieux, do_res_id)
SELECT 'Froid', 'Le prêtre peut repousser ou détruire les créatures du feu de la même façon qu’un prêtre bon repousse les morts-vivants. Il peut également intimider ou contrôler les créatures du froid de la même façon qu’un prêtre mauvais intimide les morts-vivants. Le prêtre peut utiliser ces deux pouvoirs confondus un nombre total de fois égal à (3 + modificateur de Charisme) par jour.', 'Aseroth, Aurile, Kostchtchie, Levistus, Méphistophélès, Thrym, Ulutiu', 63
WHERE NOT EXISTS (SELECT 1 FROM dd_domaines WHERE do_nom = 'Froid');

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Contact glacial' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Froid' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Métal gelé' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Froid' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Tempête de neige' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Froid' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Tempête de grêle' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Froid' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Mur de glace' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Froid' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Cône de froid' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Froid' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Contrôle du climat' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Froid' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Rayon polaire' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Froid' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Avalanche vengeresse' AND so_res_id = 63 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Froid' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

INSERT INTO dd_domaines (do_nom, do_pouvoir, do_dieux, do_res_id)
SELECT 'Gnomes', 'Le prêtre jette ls sorts d''Illusion avec un bonus de +1 au niveau de lanceur de sorts', 'Baervan Ermiterrant, Baravar Sombretoge, Callarduran Doucemains, Flandal Peaudacier, Gaerdal Maindefer, Garl Brilledor, Segojan Hanteterre, Urdlen', 63
WHERE NOT EXISTS (SELECT 1 FROM dd_domaines WHERE do_nom = 'Gnomes');

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Image silencieuse' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Gnomes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Gemme explosive' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Gnomes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Image imparfaite' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Gnomes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Création mineure' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Gnomes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Terrain hallucinatoire' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Gnomes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Machine fantastique ' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Gnomes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'écran' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Gnomes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Danse irrésistible d''Otto' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Gnomes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Convocation d''alliés naturels IX' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Gnomes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

UPDATE dd_domaines SET do_res_id = COALESCE(do_res_id, 63), do_dieux = 'Baine, Baphomet, Blibdoolpoolp, Ghaunadaur, Grolantor, Gruumsh, Kostchtchie, La Grande-Mère, Levistus, Olhydra, Seth, Urdlen' WHERE do_nom = 'Haine';

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Anathème' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Haine' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Effroi' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Haine' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Malédiction' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Haine' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Chant de discorde' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Haine' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Force du colosse' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Haine' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Interdiction' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Haine' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Blasphème' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Haine' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Aversion' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Haine' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Plainte d''outre-tombe' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Haine' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

UPDATE dd_domaines SET do_res_id = COALESCE(do_res_id, 63), do_dieux = 'Arvoreen, Brandobaris, Cyrrollalee, Sheela Peryroyl, Urogalan, Yondalla' WHERE do_nom = 'Halfelins';

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Pierre magique' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Halfelins' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Grâce féline' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Halfelins' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Panoplie magique' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Halfelins' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Liberté de mouvement' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Halfelins' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Chien de garde de Mordenkainen' AND so_res_id = 3 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Halfelins' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Glissement de terrain' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Halfelins' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Traversée des ombres' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Halfelins' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Mot de rappel' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Halfelins' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Prémonition' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Halfelins' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

UPDATE dd_domaines SET do_res_id = COALESCE(do_res_id, 63) WHERE do_nom = 'Illusion';

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Image silencieuse' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Illusion' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Image imparfaite' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Illusion' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Déplacement' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Illusion' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Assassin imaginaire' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Illusion' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Image prédéterminée' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Illusion' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Double illusoire' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Illusion' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'écran' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Illusion' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Ennemi subconscient' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Illusion' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

UPDATE dd_domaines SET do_res_id = COALESCE(do_res_id, 63) WHERE do_nom = 'Justice';

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Bouclier de la foi' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Justice' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Endurance de l''ours' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Justice' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Communication avec les morts' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Justice' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Bouclier de feu' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Justice' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Marque de la justice' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Justice' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Bannissement' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Justice' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Renvoi des sorts' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Justice' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Localisation suprême' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Justice' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

UPDATE dd_domaines SET do_res_id = COALESCE(do_res_id, 63) WHERE do_nom = 'Lune';

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Lueur féerique' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Lune' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Rayon de lune ' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Lune' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Sabre de lune ' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Lune' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Espoir' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Lune' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Image permanente' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Lune' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Aliénation mentale' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Lune' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Métamorphose animale' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Lune' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Feu de lune' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Lune' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

INSERT INTO dd_domaines (do_nom, do_pouvoir, do_dieux, do_res_id)
SELECT 'Métal', 'Le prêtre gagne Maniement d''une arme de guerre ou Maniement d''une arme exotique ainsi qu''Arme de Prédilection pour un marteau de son choix. Il s''agit de dons supplémentaires. Le prêtre n''a pas besoin de satisfaire aux conditions d''obtention', 'Crystalle, Dispater, Dumathoïn, Flandal Peaudacier, Gond, Grumbar, Laduguer, Surtur', 63
WHERE NOT EXISTS (SELECT 1 FROM dd_domaines WHERE do_nom = 'Métal');

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Arme magique' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Métal' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Métal brûlant' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Métal' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Affûtage' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Métal' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Mur de fer' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Métal' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Barrière de lames' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Métal' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Corps de fer' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Métal' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Eloignement du métal et de la pierre' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Métal' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

INSERT INTO dd_domaines (do_nom, do_pouvoir, do_dieux, do_res_id)
SELECT 'Morts-vivants', 'Le prêtre gagne Emprise sur les morts-vivants en qualité de don supplémentaire', 'Kiaransalee, Myrkul, Orcus, Velsharoon', 63
WHERE NOT EXISTS (SELECT 1 FROM dd_domaines WHERE do_nom = 'Morts-vivants');

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Détection des morts vivants' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Morts-vivants' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'profanation' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Morts-vivants' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Animation des morts' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Morts-vivants' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Protection contre la mort' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Morts-vivants' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Blessure légère de groupe' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Morts-vivants' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Création de mort-vivant' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Morts-vivants' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Contrôle des morts-vivants' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Morts-vivants' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Création de mort-vivant dominant' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Morts-vivants' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Absorption d''énergie' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Morts-vivants' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

INSERT INTO dd_domaines (do_nom, do_pouvoir, do_dieux, do_res_id)
SELECT 'Nains', 'Le prêtre gagne Vigueur surhumaine en qualité de don supplémentaire', 'Abbathor, Berronar Purargent, Clangeddin Barbedargent, Diirinka, Duerra des Abîmes, Dugmaren Brilletoge, Dumathoïn, Gorm Gulthyn, Haela Brillehache, Laduguer, Marthammor Duin, Moradin, Sharindlar, Thard Harr, Vergadain', 63
WHERE NOT EXISTS (SELECT 1 FROM dd_domaines WHERE do_nom = 'Nains');

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Arme magique' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Nains' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Endurance de l''ours' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Nains' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Glyphe de garde' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Nains' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Arme magique suprême' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Nains' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Fabrication' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Nains' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Pierres commères' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Nains' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Décret' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Nains' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Protection contre les sorts' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Nains' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Nuée d''élémentaire' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Nains' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

INSERT INTO dd_domaines (do_nom, do_pouvoir, do_dieux, do_res_id)
SELECT 'Noblesse', 'Une fois par jour, le prêtre peut galvaniser ses alliés, leur conférant ainsi un bonus de moral de +1 aux jets de sauvegarde, jets d''attaque, tests de caracteristiques, tests de compétence et jets de dégâts des armes. Ses alliés doivent être à même de l''entendre prendre la parole pendant 1 round. On active ce pouvoir magique au prix d''une action simple et son effet dure un nombre de rounds égal au bonus de Charisme du personnage (1 round minmum)', 'Amaunator, Bahamut, Cavalière Rouge, Horus-Ré, Lathandre, Milil, Nobanion, Siamorphe', 63
WHERE NOT EXISTS (SELECT 1 FROM dd_domaines WHERE do_nom = 'Noblesse');

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Faveur divine' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Noblesse' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Discours captivant' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Noblesse' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Panoplie magique' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Noblesse' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Détection du mensonge' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Noblesse' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Injonction suprême' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Noblesse' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Quête' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Noblesse' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Champ de force' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Noblesse' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Exigence' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Noblesse' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

UPDATE dd_domaines SET do_res_id = COALESCE(do_res_id, 63), do_dieux = 'Ibrandul, Lolth, Mask, Rhyxali, Seth, Shar, Shargaas', do_pouvoir = 'Le prêtre gagne Combat en aveugle en qualité de don supplémentaire' WHERE do_nom = 'Obscurité';

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Brume de dissimulation' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Obscurité' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Cécité / surdité' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Obscurité' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Lueur noire' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Obscurité' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Armure des ténèbres' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Obscurité' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Éclair des ténèbres' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Obscurité' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Oeil indiscret' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Obscurité' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Cauchemar' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Obscurité' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Mot de pouvoir aveuglant' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Obscurité' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Mot de pouvoir mortel' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Obscurité' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

INSERT INTO dd_domaines (do_nom, do_pouvoir, do_dieux, do_res_id)
SELECT 'Océan', 'Me prêtre peut respirer sous l''eau comme si il bénéficiait des effets du sort de respiration aquatique. Ce pouvoir surnaturel se déclenche automatiquement dès qu''il est applicable et dure jusqu''au terme de l''effet ou jusqu''à ce le prêtre n''en ait plus utilité.', 'Istishia, Sashelas des Profondeurs, Sekolah, Ulutiu, Umberlie, Valkur', 63
WHERE NOT EXISTS (SELECT 1 FROM dd_domaines WHERE do_nom = 'Océan');

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Endurance aux énergies destructrices' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Océan' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Cacophonie' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Océan' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Respiration aquatique' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Océan' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Liberté de mouvement' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Océan' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Mur de glace' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Océan' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Trombe d’eau ' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Océan' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Tourbillon' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Océan' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Nuée d''élémentaire' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Océan' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

INSERT INTO dd_domaines (do_nom, do_pouvoir, do_dieux, do_res_id)
SELECT 'Organisation', 'Le prêtre gagne Extension de durée en qualité de don supplémentaire', 'Amaunator, Cavalière Rouge, Gond, Heaum, Ilneval, Jauhar, Jisan, Kor, Maglubiyet, Siamorphe, Sseth, Task, Ubtao, Zann', 63
WHERE NOT EXISTS (SELECT 1 FROM dd_domaines WHERE do_nom = 'Organisation');

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Perception de la mort' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Organisation' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Augure' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Organisation' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Clairaudience/clairvoyance' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Organisation' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Détection de la scrutation' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Organisation' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Festin des héros' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Organisation' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Scrutation suprême' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Organisation' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Localisation suprême' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Organisation' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Arrêt du temps' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Organisation' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

INSERT INTO dd_domaines (do_nom, do_pouvoir, do_dieux, do_res_id)
SELECT 'Orques', 'Le prêtre gagne le pouvoir de châtiment. Une fois par jour, une de ses attaques au corps à corps bénéficie d''un bonus aux dégâts égal à son niveau de prêtre. Il doit déclarer l''utilisation de ce pouvoir avant d''effectuer son attaque. En outre, s''il utilise ce pouvoir contre un nain ou un elfe, il bénéficie également d''un bonus de +4 au jet d''attaque.', 'Bahgtru, Gruumsh, Ilneval, Luthic, Shargaas, Yurtrus', 63
WHERE NOT EXISTS (SELECT 1 FROM dd_domaines WHERE do_nom = 'Orques');

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Frayeur' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Orques' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Flammes' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Orques' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Prière' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Orques' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Puissance divine' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Orques' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Oeil indiscret' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Orques' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Mauvais oeil' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Orques' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Blasphème' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Orques' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Manteau du Chaos' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Orques' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Mot de pouvoir mortel' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Orques' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

UPDATE dd_domaines SET do_res_id = COALESCE(do_res_id, 63), do_dieux = 'Eilistraée, Shaundakul' WHERE do_nom = 'Portails';

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Stabilisation de portail ' AND so_res_id = 70 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Portails' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Analyse de portail' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Portails' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Vision de portail' AND so_res_id = 70 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Portails' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Porte dimensionnelle' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Portails' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Barricade de portail ' AND so_res_id = 70 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Portails' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Détournement de portail ' AND so_res_id = 70 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Portails' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Passage dans l''éther' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Portails' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Reformatage de portail ' AND so_res_id = 70 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Portails' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Portail' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Portails' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

UPDATE dd_domaines SET do_res_id = COALESCE(do_res_id, 63), do_dieux = 'Angharradh, Chauntéa, Kossuth, Lathandre, Semuanya, Shekinester, Shiallia, Silvanus, Trouveur d’Éperon de Wyvern, Zaaman Rul' WHERE do_nom = 'Renouvellement';

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Charme-personne' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Renouvellement' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Restauration partielle' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Renouvellement' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Guérison des maladies' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Renouvellement' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Festin des héros' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Renouvellement' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Restauration suprême' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Renouvellement' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Métamorphose universelle' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Renouvellement' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Delivrance' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Renouvellement' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

UPDATE dd_domaines SET do_res_id = COALESCE(do_res_id, 63), do_dieux = 'Jergal, Kelemvor, Osiris, Urogalan' WHERE do_nom = 'Repos éternel';

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Invisibilité pour les morts-vivants' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Repos éternel' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Préservation des morts' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Repos éternel' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Communication avec les morts' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Repos éternel' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Protection contre la mort' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Repos éternel' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Exécution' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Repos éternel' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Annihilation de mort-vivant' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Repos éternel' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Destruction' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Repos éternel' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Protection naturelle' AND so_res_id = 63 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Repos éternel' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Plainte d''outre-tombe' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Repos éternel' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

INSERT INTO dd_domaines (do_nom, do_pouvoir, do_dieux, do_res_id)
SELECT 'Reptiles', 'Le prêtre intimide ou contrôle les animaux (créatures reptiliennes ou serpents uniquement) comme un prêtre mauvais intimide ou contrôle les morts-vivants. Il peut utiliser ce pouvoir un nombre de fois égal à 3 + modificateur de Charisme', 'Hlal, Ibrandul, Kurtulmak, Sebek, Semuanya, Seth, Shekinester, Sseth, Ssharstrune, Task, Tiamat, Trouveur d’Éperon de Wyvern, Ubtao', 63
WHERE NOT EXISTS (SELECT 1 FROM dd_domaines WHERE do_nom = 'Reptiles');

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Morsure magique' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Reptiles' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Hypnose des animaux' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Reptiles' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Morsure magique suprême' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Reptiles' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Empoisonnement' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Reptiles' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Croissance animale' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Reptiles' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Mauvais oeil' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Reptiles' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Crachat de vipères' AND so_res_id = 63 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Reptiles' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Métamorphose animale' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Reptiles' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Changement de forme' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Reptiles' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

INSERT INTO dd_domaines (do_nom, do_pouvoir, do_dieux, do_res_id)
SELECT 'Runes', 'Le prêtre gagne Écriture de parchemins en qualité de don supplémentaire', 'Annam, Deneir, Dugmaren Brilletoge, Jergal, Mystra, Thoth, Zann', 63
WHERE NOT EXISTS (SELECT 1 FROM dd_domaines WHERE do_nom = 'Runes');

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Effacement' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Runes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Page secrète' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Runes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Glyphe de garde' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Runes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Runes explosives' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Runes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Contrat' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Runes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Glyphe de garde suprême' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Runes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Invocation instantanée de Drawmij' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Runes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Transcription de symbole' AND so_res_id = 63 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Runes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Cercle de téléportation' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Runes' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

INSERT INTO dd_domaines (do_nom, do_pouvoir, do_dieux, do_res_id)
SELECT 'Sorts', 'Me prêtre bénéficie d''un bonus de +2 aux tests d''Art de la magie et de Concentration', 'Azouth, Leïra, Mystra, Savras, Shekinester, Thoth', 63
WHERE NOT EXISTS (SELECT 1 FROM dd_domaines WHERE do_nom = 'Sorts');

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Armure de mage' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Sorts' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Silence' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Sorts' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Sort universel ' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Sorts' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Annulation d''enchantement' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Sorts' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Sort universel amélioré' AND so_res_id = 40 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Sorts' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Souhait limité' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Sorts' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Zone d''antimagie' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Sorts' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Disjonction de Mordenkainen' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Sorts' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

UPDATE dd_domaines SET do_res_id = COALESCE(do_res_id, 63), do_dieux = 'Diirinka, Ilmater, Jergal, Kossuth, Loviatar, Myrkul, Talona, Yurtrus' WHERE do_nom = 'Souffrance';

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Imprécation' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Souffrance' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Endurance de l''ours' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Souffrance' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Malédiction' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Souffrance' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Energie négative' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Souffrance' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Symbole de douleur' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Souffrance' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Mise à mal' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Souffrance' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Vagues d''épuisement' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Souffrance' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Flétrissure' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Souffrance' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Absorption d''énergie' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Souffrance' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

INSERT INTO dd_domaines (do_nom, do_pouvoir, do_dieux, do_res_id)
SELECT 'Tempête', 'Le prêtre gagne une résistance à l''électricité (5)', 'Aerdrië Faenya, Anhur, Aurile, Bahamut, Isis, Istishia, Stronmàus, Talos, Umberlie', 63
WHERE NOT EXISTS (SELECT 1 FROM dd_domaines WHERE do_nom = 'Tempête');

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Bouclier entropique' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Tempête' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Bourrasque' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Tempête' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Appel de la foudre' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Tempête' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Tempête de neige' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Tempête' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Tempête de grêle' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Tempête' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Appel de la tempête' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Tempête' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Contrôle du climat' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Tempête' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Cyclone' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Tempête' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_domaines (do_nom, do_pouvoir, do_dieux, do_res_id)
SELECT 'Temps', 'Le prêtre gagne Science de l’initiative en qualité de don supplémentaire', 'Amaunator, Grumbar, Kor, Labelas Enoreth', 63
WHERE NOT EXISTS (SELECT 1 FROM dd_domaines WHERE do_nom = 'Temps');

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Coup au but' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Temps' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Préservation des morts' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Temps' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Rapidité' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Temps' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Liberté de mouvement' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Temps' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Permanence' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Temps' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Moment de prescience' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Temps' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Prémonition' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Temps' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Arrêt du temps' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Temps' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

INSERT INTO dd_domaines (do_nom, do_pouvoir, do_dieux, do_res_id)
SELECT 'Tyrannie', 'Le DD de sauvegarde des sorts de coercition lancés par le prêtre augmente de +2.', 'Asmodée, Baine, Gilgeam, Ilsensine, Sekolah, Ssharstrune, Tiamat', 63
WHERE NOT EXISTS (SELECT 1 FROM dd_domaines WHERE do_nom = 'Tyrannie');

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Injonction' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Tyrannie' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Discours captivant' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Tyrannie' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Détection du mensonge' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Tyrannie' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Terreur' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 4, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Tyrannie' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 4);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Injonction suprême' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Tyrannie' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Quête' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 6, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Tyrannie' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 6);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Charme-monstre de groupe' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Tyrannie' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Domination universelle' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Tyrannie' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);

INSERT INTO dd_domaines (do_nom, do_pouvoir, do_dieux, do_res_id)
SELECT 'Vases', 'Le prêtre intimide ou contrôle les vases comme un prêtre mauvais intimide ou contrôle les morts-vivants. Il peut utiliser ce pouvoir un nombre de fois apr jour égal à 3 + son modificateur de Charisme.', 'Bwimb II, Ghaunadaur, Ilsensine, Moandre, Zuggtmoy', 63
WHERE NOT EXISTS (SELECT 1 FROM dd_domaines WHERE do_nom = 'Vases');

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Graisse' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 1, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Vases' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 1);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Flèche acide de Melf' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 2, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Vases' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 2);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Empoisonnement' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 3, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Vases' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 3);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Tentacules noirs d''Evard' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 5, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Vases' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 5);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Destruction' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 7, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Vases' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 7);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Mot de pouvoir aveuglant' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 8, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Vases' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 8);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT (SELECT so_id FROM dd_sorts WHERE so_ruleset_var_id = 1 AND so_nom = 'Implosion' AND so_res_id = 45 ORDER BY so_id LIMIT 1), 9, d.do_id
FROM dd_domaines d WHERE d.do_nom = 'Vases' AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_do_id = d.do_id AND x.sd_niveau = 9);
