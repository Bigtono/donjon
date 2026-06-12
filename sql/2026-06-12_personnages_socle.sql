-- =============================================================================
-- Codex DD v2 — Patch SQL — Module Personnages — sous-phase 3.0 (socle)
-- Mis à jour : 2026-06-12 15:00
-- -----------------------------------------------------------------------------
-- Prépare le schéma pour le module Personnages :
--   - Création du référentiel `dd_alignements` (commun à tous les rulesets DD).
--   - Ajout sur `dd_personnages` des colonnes :
--       * pe_sexe         : libellé descriptif libre (les deux rulesets)
--       * pe_al_id        : -> dd_alignements (NULL = non renseigné)
--       * pe_notes_scope  : préférence d'affichage des notes par campagne
--                           (0 = campagne en cours, 1 = toutes les campagnes)
--
-- Ne modifie PAS `pe_camp_id` : déjà ajouté par le patch campagnes étape 1
-- (2026-06-01_campagnes_v2_etape1.sql) comme "dernière campagne jouée".
--
-- À appliquer sur la base de DÉVELOPPEMENT (préfixe dd_). En production OVH,
-- le préfixe deviendra dd2_ au déploiement (cf. DECISIONS_LOG).
-- Idempotent autant que possible.
-- =============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------------------------------
-- 1. dd_alignements : référentiel commun à tous les rulesets DD
--    9 alignements classiques (loi/chaos x bien/mal/neutre).
--    Pas de soft-delete (référentiel figé).
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dd_alignements (
  al_id          INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  al_nom         VARCHAR(60)      NOT NULL,
  al_abreviation VARCHAR(10)      NOT NULL COMMENT 'Ex : LB, NN, CM',
  al_ordre       TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Tri d''affichage',
  PRIMARY KEY (al_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed des 9 alignements (vide d'abord si le patch est rejoué après ajout manuel)
TRUNCATE TABLE dd_alignements;

INSERT INTO dd_alignements (al_nom, al_abreviation, al_ordre) VALUES
  ('Loyal Bon',         'LB', 1),
  ('Neutre Bon',        'NB', 2),
  ('Chaotique Bon',     'CB', 3),
  ('Loyal Neutre',      'LN', 4),
  ('Neutre Strict',     'N',  5),
  ('Chaotique Neutre',  'CN', 6),
  ('Loyal Mauvais',     'LM', 7),
  ('Neutre Mauvais',    'NM', 8),
  ('Chaotique Mauvais', 'CM', 9);

-- -----------------------------------------------------------------------------
-- 2. dd_personnages : ajout pe_sexe, pe_al_id, pe_notes_scope
--    pe_camp_id (déjà existant) inchangé.
-- -----------------------------------------------------------------------------
ALTER TABLE dd_personnages
  ADD COLUMN pe_sexe VARCHAR(20) DEFAULT NULL
    COMMENT 'Libellé libre, descriptif (féminin, masculin, etc.)'
    AFTER pe_nom;

ALTER TABLE dd_personnages
  ADD COLUMN pe_al_id INT UNSIGNED DEFAULT NULL
    COMMENT '-> dd_alignements (NULL = non renseigné)'
    AFTER pe_arc_id;

ALTER TABLE dd_personnages
  ADD COLUMN pe_notes_scope TINYINT UNSIGNED NOT NULL DEFAULT 0
    COMMENT 'Affichage notes : 0 = campagne en cours, 1 = toutes les campagnes'
    AFTER pe_notes;

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- Fin du patch.
-- Vérifications post-application recommandées :
--   SELECT COUNT(*) FROM dd_alignements;  -- attendu : 9
--   SHOW COLUMNS FROM dd_personnages LIKE 'pe_sexe';
--   SHOW COLUMNS FROM dd_personnages LIKE 'pe_al_id';
--   SHOW COLUMNS FROM dd_personnages LIKE 'pe_notes_scope';
-- =============================================================================
