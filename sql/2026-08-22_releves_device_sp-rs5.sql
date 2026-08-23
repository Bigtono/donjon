-- =============================================================================
-- Codex DD v2 — Patch SQL — Relevés d'affichage des utilisateurs (SP-RS5)
-- Mis à jour : 2026-08-22
-- -----------------------------------------------------------------------------
-- Objectif : constituer une base de mesures réelles pour arbitrer les paliers
-- responsive du projet (991 / 768 / 479 px), aujourd'hui posés a priori.
-- Deux écritures pour une seule collecte, faite par le beacon
-- include/ajax/releve-device.php au premier chargement de page de chaque
-- session authentifiée :
--   1. dd_joueurs.j_last_*  — instantané de la dernière connexion (écrasé)
--   2. dd_connexions        — une ligne datée par session (historique)
--
-- Aucune donnée personnelle supplémentaire : ni adresse IP, ni géolocalisation
-- (cf. DECISIONS_LOG.md [2026-08-22] D-RS23). co_session est un SHA-1 de
-- l'identifiant de session, jamais l'identifiant lui-même : il sert uniquement
-- de clé d'unicité pour ne pas créer deux lignes quand plusieurs onglets
-- s'ouvrent en même temps.
--
-- Idempotent : CREATE TABLE IF NOT EXISTS. Les ALTER TABLE ne le sont pas —
-- les rejouer produit "Duplicate column name", sans dommage.
-- N'altère aucune donnée existante.
-- =============================================================================

SET NAMES utf8mb4;

-- -----------------------------------------------------------------------------
-- 1. dd_joueurs — instantané de la dernière connexion
-- -----------------------------------------------------------------------------

ALTER TABLE dd_joueurs
  ADD COLUMN j_last_device_date DATETIME              DEFAULT NULL COMMENT 'Date du dernier relevé d''affichage',
  ADD COLUMN j_last_vp_w        SMALLINT UNSIGNED     DEFAULT NULL COMMENT 'Largeur du viewport en pixels CSS',
  ADD COLUMN j_last_vp_h        SMALLINT UNSIGNED     DEFAULT NULL COMMENT 'Hauteur du viewport en pixels CSS',
  ADD COLUMN j_last_dpr         DECIMAL(4,2)          DEFAULT NULL COMMENT 'devicePixelRatio',
  ADD COLUMN j_last_screen_w    SMALLINT UNSIGNED     DEFAULT NULL COMMENT 'screen.width en pixels CSS',
  ADD COLUMN j_last_screen_h    SMALLINT UNSIGNED     DEFAULT NULL COMMENT 'screen.height en pixels CSS',
  ADD COLUMN j_last_orientation VARCHAR(10)           DEFAULT NULL COMMENT 'portrait | landscape',
  ADD COLUMN j_last_touch       TINYINT UNSIGNED      DEFAULT NULL COMMENT 'navigator.maxTouchPoints (0 = pas tactile)',
  ADD COLUMN j_last_plateforme  VARCHAR(60)           DEFAULT NULL COMMENT 'navigator.userAgentData.platform si disponible',
  ADD COLUMN j_last_ua          VARCHAR(255)          DEFAULT NULL COMMENT 'navigator.userAgent (tronqué à 255)';

-- -----------------------------------------------------------------------------
-- 2. dd_connexions — une ligne datée par session authentifiée
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS dd_connexions (
  co_id          INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  co_j_id        INT UNSIGNED     NOT NULL              COMMENT '-> dd_joueurs',
  co_date        DATETIME         NOT NULL              COMMENT 'Horodatage du relevé',
  co_session     CHAR(40)         NOT NULL              COMMENT 'SHA-1 de session_id() — clé d''unicité, jamais l''id de session',
  co_vp_w        SMALLINT UNSIGNED         DEFAULT NULL COMMENT 'Largeur du viewport en pixels CSS',
  co_vp_h        SMALLINT UNSIGNED         DEFAULT NULL COMMENT 'Hauteur du viewport en pixels CSS',
  co_dpr         DECIMAL(4,2)              DEFAULT NULL COMMENT 'devicePixelRatio',
  co_screen_w    SMALLINT UNSIGNED         DEFAULT NULL COMMENT 'screen.width en pixels CSS',
  co_screen_h    SMALLINT UNSIGNED         DEFAULT NULL COMMENT 'screen.height en pixels CSS',
  co_orientation VARCHAR(10)               DEFAULT NULL COMMENT 'portrait | landscape',
  co_touch       TINYINT UNSIGNED          DEFAULT NULL COMMENT 'navigator.maxTouchPoints (0 = pas tactile)',
  co_plateforme  VARCHAR(60)               DEFAULT NULL COMMENT 'navigator.userAgentData.platform si disponible',
  co_langue      VARCHAR(10)               DEFAULT NULL COMMENT 'navigator.language',
  co_ua          VARCHAR(255)              DEFAULT NULL COMMENT 'navigator.userAgent (tronqué à 255)',
  PRIMARY KEY (co_id),
  UNIQUE KEY uk_co_session (co_j_id, co_session),
  KEY idx_co_joueur_date (co_j_id, co_date),
  KEY idx_co_date (co_date),
  KEY idx_co_vp_w (co_vp_w)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -----------------------------------------------------------------------------
-- Purge éventuelle (non automatisée) — à jouer à la main si la table grossit :
--   DELETE FROM dd_connexions WHERE co_date < DATE_SUB(NOW(), INTERVAL 12 MONTH);
-- -----------------------------------------------------------------------------
