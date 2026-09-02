-- sql/2026-08-24_ordre_sp-cp.sql
-- SP-CP0 — Refonte du module Campagnes : ordre manuel (glisser-déposer).
--
-- dd_scenarios.sce_ordre et dd_scenarios_chapitres.scc_ordre existent déjà.
-- Il manquait les deux niveaux inférieurs, jusqu'ici triés sur le nom :
--   dd_rencontres  → ORDER BY re_nom
--   dd_oppositions → ORDER BY opp_nom
--
-- Après ce patch, les quatre niveaux sont ordonnés manuellement par
-- glisser-déposer (js/tri-liste.js → campagnes/enregistrement.php,
-- actions reordonner*). Le tri applicatif devient partout :
--   ORDER BY <prefixe>_ordre ASC, <prefixe>_nom ASC
-- (le nom reste départage-égalité : deux lignes à 0 restent stables).
--
-- Idempotence : ce script n'est PAS ré-exécutable tel quel (ADD COLUMN
-- échouera la seconde fois). Vérifier avant de le rejouer :
--   SHOW COLUMNS FROM dd_rencontres LIKE 're_ordre';

-- ------------------------------------------------------------
-- 1. Colonnes d'ordre
-- ------------------------------------------------------------

ALTER TABLE dd_rencontres
  ADD COLUMN re_ordre SMALLINT UNSIGNED NOT NULL DEFAULT 0 AFTER re_code;

ALTER TABLE dd_oppositions
  ADD COLUMN opp_ordre SMALLINT UNSIGNED NOT NULL DEFAULT 0 AFTER opp_re_id;

-- ------------------------------------------------------------
-- 2. Backfill — reprend l'ordre alphabétique en vigueur jusqu'ici,
--    rang à rang, à l'intérieur de chaque parent.
--    ROW_NUMBER() : MariaDB >= 10.2 / MySQL >= 8.0.
-- ------------------------------------------------------------

UPDATE dd_rencontres re
JOIN (
  SELECT re_id,
         ROW_NUMBER() OVER (PARTITION BY re_scc_id ORDER BY re_nom ASC, re_id ASC) AS rang
  FROM   dd_rencontres
  WHERE  re_supprime = 0
) t ON t.re_id = re.re_id
SET re.re_ordre = t.rang;

UPDATE dd_oppositions opp
JOIN (
  SELECT opp_id,
         ROW_NUMBER() OVER (PARTITION BY opp_re_id ORDER BY opp_nom ASC, opp_id ASC) AS rang
  FROM   dd_oppositions
  WHERE  opp_supprime = 0
) t ON t.opp_id = opp.opp_id
SET opp.opp_ordre = t.rang;
