-- =============================================================================
-- Codex DD v2 — Patch SQL — Module Campagnes — Opposition sans monstre d'origine
-- Mis à jour : 2026-06-20 22:30
-- -----------------------------------------------------------------------------
-- dd_oppositions.opp_mo_id devient NULLABLE : le choix d'un monstre d'origine
-- au compendium devient optionnel à la création d'une opposition — le MJ doit
-- pouvoir saisir une opposition entièrement à la main (nom + stats libres),
-- sans passer par le sélecteur de monstre.
--
-- opp_mo_id reste, quand renseigné, un template figé non éditable après
-- création (traçabilité) — seule sa NULLABILITÉ change, pas sa sémantique.
--
-- Idempotent (MODIFY COLUMN n'échoue pas si déjà nullable).
-- N'altère aucune donnée existante (toutes les lignes actuelles ont déjà
-- opp_mo_id renseigné, donc aucune valeur ne devient NULL rétroactivement).
-- =============================================================================

SET NAMES utf8mb4;

ALTER TABLE dd_oppositions
  MODIFY COLUMN opp_mo_id INT UNSIGNED NULL
    COMMENT '-> dd_monstres (template figé, non éditable). NULL = opposition saisie manuellement, sans monstre d''origine.';
