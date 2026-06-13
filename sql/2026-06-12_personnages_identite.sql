-- =============================================================================
-- Codex DD v2 — Patch SQL — Module Personnages — sous-phase 3.1 (identité)
-- Mis à jour : 2026-06-12 16:00
-- -----------------------------------------------------------------------------
-- Ajoute sur `dd_personnages` la colonne :
--   * pe_hi_id : -> dd_historiques (NULL = aucun) — utilisée par DD2024
--                (la table dd_historiques existe déjà dans le schéma V2 ;
--                voir SCHEMA_SQL.md §dd_historiques).
--
-- Reste cohérent avec la convention : FK logiques (non enforced), NULL pour
-- "non renseigné", AFTER positionnement intentionnel.
-- Idempotent grâce au filtrage information_schema.
-- =============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------------------------------
-- Ajout conditionnel de pe_hi_id (idempotent)
-- -----------------------------------------------------------------------------
SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
   WHERE TABLE_SCHEMA = DATABASE()
     AND TABLE_NAME   = 'dd_personnages'
     AND COLUMN_NAME  = 'pe_hi_id'
);

SET @sql = IF(@col_exists = 0,
  'ALTER TABLE dd_personnages
     ADD COLUMN pe_hi_id INT UNSIGNED DEFAULT NULL
       COMMENT ''[DD2024] Historique -> dd_historiques (NULL = aucun)''
       AFTER pe_arc_id',
  'SELECT ''pe_hi_id déjà présent — patch ignoré'' AS message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- Vérification post-application recommandée :
--   SHOW COLUMNS FROM dd_personnages LIKE 'pe_hi_id';
-- =============================================================================
