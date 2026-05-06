-- ============================================================
-- Patch 001 — Champs reset mot de passe
-- À exécuter une seule fois sur la base
-- ============================================================

ALTER TABLE dd_joueurs
  ADD COLUMN j_reset_token         VARCHAR(100) DEFAULT NULL AFTER j_remember_token_expires,
  ADD COLUMN j_reset_token_expires DATETIME     DEFAULT NULL AFTER j_reset_token;
