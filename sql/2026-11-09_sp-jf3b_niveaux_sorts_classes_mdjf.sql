-- SP-JF3b — Niveaux des sorts MdJF pour les classes de prestige créées par SP-JF3
-- Généré par tools/generer-sp-jf1-sorts.php le 2026-11-09 depuis gemmaline.com (index element-MJF.htm).
-- Rejouable : chaque insertion est gardée par NOT EXISTS. Pas de DELIMITER.

SET NAMES utf8mb4;

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 8 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Anneau de foudre' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 8 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Anneau de foudre' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Arc lunaire de Presper' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Arc lunaire de Presper' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 8 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Druide' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Bombardement' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Boucle électrique de Gedlee' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Boucle électrique de Gedlee' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Boule de foudre' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Boule de foudre' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Druide' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Brasier' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Féticheur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Brasier' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Brise-chair' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Brise-chair' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 6 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Chaîne hurleuse' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 6 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Chaîne hurleuse' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 7 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Crachat de vipères' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 7 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Crachat de vipères' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Création de tatouage magique' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Création de tatouage magique' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 9 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Déclencheur de la Simbule' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 9 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Déclencheur de la Simbule' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Doux rappel de Nybor' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Doux rappel de Nybor' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Kleptomage' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Doux rappel de Nybor' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Paladin' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Épée axiomatique' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 9 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Épuration resplendissante d''Elminster' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 9 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Épuration resplendissante d''Elminster' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Druide' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Équilibre naturel' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Paladin' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Faveur d''Ilmater' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

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

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Linceul de feu' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Linceul de feu' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Matrice de la Simbule' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Matrice de la Simbule' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 6 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Métamorphose diabolique' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 6 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Métamorphose diabolique' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

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

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Nuage de confusion' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Nuage de confusion' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Barde' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Nuage de confusion' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

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

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Paladin' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Parade d''énergie' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Druide' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Protection contre le feu' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 7 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Rayon rubis d''inversion' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 7 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Rayon rubis d''inversion' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 7 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Sévère réprobation de Nybor' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 7 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Sévère réprobation de Nybor' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 6 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Tempête acide' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 6 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Tempête acide' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 8 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Transcription de symbole' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 8 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Transcription de symbole' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Vision aveugle' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Vision aveugle' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Vision aveugle' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Druide' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Vision aveugle' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Rôdeur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Vision aveugle' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Kleptomage' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Vision aveugle' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);
