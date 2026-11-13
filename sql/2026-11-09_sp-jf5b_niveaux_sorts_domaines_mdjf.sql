-- SP-JF5b — Niveaux des sorts MdJF pour les domaines créés par SP-JF5
-- Généré par tools/generer-sp-jf1-sorts.php le 2026-11-09 depuis gemmaline.com (index element-MJF.htm).
-- Rejouable : chaque insertion est gardée par NOT EXISTS. Pas de DELIMITER.

SET NAMES utf8mb4;

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT s.so_id, 8, d.do_id FROM dd_sorts s JOIN dd_domaines d ON d.do_nom = 'Foudre'
WHERE s.so_nom = 'Anneau de foudre' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_so_id = s.so_id AND x.sd_do_id = d.do_id);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT s.so_id, 9, d.do_id FROM dd_sorts s JOIN dd_domaines d ON d.do_nom = 'Froid'
WHERE s.so_nom = 'Avalanche vengeresse' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_so_id = s.so_id AND x.sd_do_id = d.do_id);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT s.so_id, 9, d.do_id FROM dd_sorts s JOIN dd_domaines d ON d.do_nom = 'Neige'
WHERE s.so_nom = 'Avalanche vengeresse' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_so_id = s.so_id AND x.sd_do_id = d.do_id);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT s.so_id, 5, d.do_id FROM dd_sorts s JOIN dd_domaines d ON d.do_nom = 'Foudre'
WHERE s.so_nom = 'Boule de foudre' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_so_id = s.so_id AND x.sd_do_id = d.do_id);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT s.so_id, 7, d.do_id FROM dd_sorts s JOIN dd_domaines d ON d.do_nom = 'Reptiles'
WHERE s.so_nom = 'Crachat de vipères' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_so_id = s.so_id AND x.sd_do_id = d.do_id);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT s.so_id, 4, d.do_id FROM dd_sorts s JOIN dd_domaines d ON d.do_nom = 'Glace'
WHERE s.so_nom = 'Lance de glace' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_so_id = s.so_id AND x.sd_do_id = d.do_id);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT s.so_id, 8, d.do_id FROM dd_sorts s JOIN dd_domaines d ON d.do_nom = 'Repos éternel'
WHERE s.so_nom = 'Protection naturelle' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_so_id = s.so_id AND x.sd_do_id = d.do_id);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT s.so_id, 7, d.do_id FROM dd_sorts s JOIN dd_domaines d ON d.do_nom = 'Acide'
WHERE s.so_nom = 'Tempête acide' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_so_id = s.so_id AND x.sd_do_id = d.do_id);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT s.so_id, 8, d.do_id FROM dd_sorts s JOIN dd_domaines d ON d.do_nom = 'Runes'
WHERE s.so_nom = 'Transcription de symbole' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_so_id = s.so_id AND x.sd_do_id = d.do_id);
