-- sql/2026-11-06_sp-mo1_categories_monstres_dd35.sql
-- SP-MO1 — Catégories DD3.5 : les types de créature du Manuel des Monstres 3.5
--
-- Préalable à l'import des monstres DD3.5 de l'ancienne application (SP-MO3) : seuls Mort-vivant (1),
-- Démon (2), Créature artificielle (3), Céleste (8) et Dragon (11) existaient en DD3.5.
-- Ids figés à partir de 21 (D-MO3) : l'import y fait référence par id.
-- Corrige aussi la catégorie 16 « Géant », rattachée au ruleset 0 alors que sa description est celle de DD2024.
-- Rejouable : chaque ligne n'est insérée que si son id est libre. Pas de DELIMITER.

SET NAMES utf8mb4;

INSERT INTO dd_monstres_categories (mocat_id, mocat_nom, mocat_description, mocat_ruleset_var_id)
SELECT t.id, t.nom, NULL, 1
FROM (
  SELECT 21 AS id, 'Aberration' AS nom
  UNION ALL SELECT 22, 'Animal'
  UNION ALL SELECT 23, 'Créature magique'
  UNION ALL SELECT 24, 'Élémentaire'
  UNION ALL SELECT 25, 'Extérieur'
  UNION ALL SELECT 26, 'Fée'
  UNION ALL SELECT 27, 'Géant'
  UNION ALL SELECT 28, 'Humanoïde'
  UNION ALL SELECT 29, 'Humanoïde monstrueux'
  UNION ALL SELECT 30, 'Plante'
  UNION ALL SELECT 31, 'Vase'
  UNION ALL SELECT 32, 'Vermine'
) t
WHERE NOT EXISTS (SELECT 1 FROM dd_monstres_categories c WHERE c.mocat_id = t.id);

UPDATE dd_monstres_categories SET mocat_ruleset_var_id = 2 WHERE mocat_id = 16 AND mocat_ruleset_var_id = 0;
