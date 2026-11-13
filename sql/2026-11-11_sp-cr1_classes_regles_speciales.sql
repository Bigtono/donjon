-- sql/2026-11-11_sp-cr1_classes_regles_speciales.sql
-- SP-CR1 — Règles spéciales d'une classe (DD3.5 et DD2024)
--
-- cla_regles_speciales : texte riche affiché SANS libellé, juste après la liste des capacités
-- spéciales de la fiche de la classe. Sert aux règles complexes qui ne tiennent pas dans une
-- capacité isolée. Les parsers du texte enrichi (glossaire, [[tab:slug]], [[liste:…]]) s'y appliquent.
-- NON IDEMPOTENT (ALTER TABLE) : jouée une seule fois par le moteur.
-- Pas de DELIMITER.

SET NAMES utf8mb4;

ALTER TABLE dd_classes
  ADD COLUMN cla_regles_speciales TEXT DEFAULT NULL
    COMMENT 'Règles spéciales de la classe, affichées après les capacités spéciales — SP-CR1'
    AFTER cla_description;
