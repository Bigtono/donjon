-- =============================================================================
-- Codex DD v2 — Patch SQL — Module Compendium — Équipements (SP-E0)
-- Mis à jour : 2026-06-20 21:00
-- -----------------------------------------------------------------------------
-- Crée dd_equipements (équipement mondain — armes, armures, matériel non
-- magique), distincte de dd_objets_magiques (objets magiques, déjà existante).
-- Schéma fourni par l'utilisateur, déjà documenté dans SCHEMA_SQL.md.
--
-- Étape SQL uniquement (SP-E0). Aucun contrôleur/formulaire/endpoint ne
-- référence encore cette table — cf. ARCHITECTURE_0_REFERENCE.md § Plan
-- Équipements (SP-E) pour les étapes suivantes (SP-E1 à SP-E4), volontairement
-- différées (cf. DECISIONS_LOG.md [2026-06-20]).
--
-- Idempotent (CREATE TABLE IF NOT EXISTS). N'altère aucune donnée existante.
-- =============================================================================

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS dd_equipements (
  eqt_id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  eqt_nom             VARCHAR(150) NOT NULL,
  eqt_description     TEXT                  DEFAULT NULL  COMMENT 'Description HTML TinyMCE (format libre)',
  eqt_visible         TINYINT(1)   NOT NULL DEFAULT 1      COMMENT '0 = masqué aux joueurs non-éditeurs',
  eqt_res_id          INT UNSIGNED NOT NULL                COMMENT '-> dd_ressources (source)',
  eqt_camp_id         INT UNSIGNED          DEFAULT NULL   COMMENT 'NULL = global ; sinon homebrew -> dd_campagnes',
  eqt_ruleset_var_id  INT UNSIGNED NOT NULL                COMMENT '-> dd_variables',
  PRIMARY KEY (eqt_id),
  KEY idx_eqt_res (eqt_res_id),
  KEY idx_eqt_camp (eqt_camp_id),
  KEY idx_eqt_ruleset (eqt_ruleset_var_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
