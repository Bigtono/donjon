-- sql/2026-11-08_sp-mo7a_fp_dd35.sql
-- SP-MO7a — Référentiel des facteurs de puissance : valeurs du DRS absentes de dd_fp
-- Les monstres du DRS (DRS 33 à 40) portent des FP que le référentiel ne connaît pas :
-- 1/10, 1/6, 1/3, 16 et 23 et plus (jusqu'à 30 pour les grands dracosires et les monstres évolués).
-- « 1/10 » fait 4 caractères : fp_nom passe à varchar(5).
-- fp_valeur, qui ne sert qu'au tri des listes, passe en décimal : 1/8, 1/4 et 1/2 valaient 0 ou 1
-- comme 0 et 1, d'où un ordre indéterminé ; chaque FP reçoit sa valeur exacte.
-- Rejouable : insertion seulement des libellés absents. Pas de DELIMITER.

SET NAMES utf8mb4;

ALTER TABLE dd_fp
  MODIFY fp_nom    varchar(5)   NOT NULL,
  MODIFY fp_valeur decimal(6,3) NOT NULL;

INSERT INTO dd_fp (fp_nom, fp_valeur)
SELECT v.nom, v.val
FROM (
  SELECT '1/10' nom, 0.100 val UNION ALL SELECT '1/6', 0.167 UNION ALL SELECT '1/3', 0.333
  UNION ALL SELECT '16', 16 UNION ALL SELECT '23', 23 UNION ALL SELECT '24', 24 UNION ALL SELECT '25', 25
  UNION ALL SELECT '26', 26 UNION ALL SELECT '27', 27 UNION ALL SELECT '28', 28 UNION ALL SELECT '29', 29
  UNION ALL SELECT '30', 30
) v
WHERE NOT EXISTS (SELECT 1 FROM dd_fp f WHERE f.fp_nom = v.nom);

UPDATE dd_fp SET fp_valeur = 0.125 WHERE fp_nom = '1/8';
UPDATE dd_fp SET fp_valeur = 0.250 WHERE fp_nom = '1/4';
UPDATE dd_fp SET fp_valeur = 0.500 WHERE fp_nom = '1/2';
