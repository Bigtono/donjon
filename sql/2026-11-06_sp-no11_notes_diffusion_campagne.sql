-- sql/2026-11-06_sp-no11_notes_diffusion_campagne.sql
-- SP-NO11 — Diffuser une note à toute la campagne
--
-- no_diffusion_campagne = 1 : la note est lue par tout personnage rattaché à sa campagne (dd_campagnes_personnages),
-- inactifs compris, y compris ceux rattachés après sa création ; un personnage qui quitte la campagne ne la lit plus.
-- dd_personnages_notes ne sert alors qu'au suivi de lecture (ligne créée à la première ouverture).
-- 0 = personnages choisis, comportement antérieur : les notes existantes ne changent pas (D-NO19 → D-NO22).
-- Pas de DELIMITER.

SET NAMES utf8mb4;

ALTER TABLE dd_notes
  ADD COLUMN no_diffusion_campagne TINYINT(1) NOT NULL DEFAULT 0
    COMMENT '1 = toute la campagne (accès par dd_campagnes_personnages) ; 0 = personnages choisis (dd_personnages_notes) — SP-NO11'
    AFTER no_tyno_id;
