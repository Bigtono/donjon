-- sql/2026-10-31_choix_precision_sp-ch8.sql
-- SP-CH8 — Précision d'un choix de don (suite de sp-ch0)
--
-- Certains dons se choisissent avec une précision : Spécialisation martiale ou Arme de prédilection (quelle arme),
-- École renforcée (quelle école), Talent (quelle compétence). pech_precision porte ce texte libre, saisi sur la
-- fiche à côté du don choisi. Elle n'existe que pour un emplacement en mode « don » ; NULL = aucune précision.
-- Pas de DELIMITER.

SET NAMES utf8mb4;

ALTER TABLE dd_personnages_choix
  ADD COLUMN pech_precision VARCHAR(100) NULL
    COMMENT 'Précision du don choisi (arme, école, compétence…) — mode don (SP-CH)' AFTER pech_texte;
