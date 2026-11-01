-- sql/2026-11-01_sp-pe18_affectation_personnage.sql
-- SP-PE18 — Gestion d'un personnage par l'admin et le MJ
--
-- Un MJ peut affecter un personnage à un joueur : pe_j_id devient le joueur, et la nouvelle colonne
-- pe_affecte_par_j_id garde le MJ qui a affecté. Elle lui permet, à lui seul (et à l'admin), de retirer
-- l'affectation : pe_j_id revient alors à ce MJ et la trace repasse à NULL. NULL = personnage jamais
-- affecté (propriété d'origine). Décisions D-PE18a → D-PE18d.
-- Pas de DELIMITER.

SET NAMES utf8mb4;

ALTER TABLE dd_personnages
  ADD COLUMN pe_affecte_par_j_id INT UNSIGNED NULL DEFAULT NULL
    COMMENT 'MJ qui a affecté le personnage à son propriétaire actuel -> dd_joueurs (NULL = jamais affecté)'
    AFTER pe_j_id,
  ADD KEY idx_pe_affecte_par (pe_affecte_par_j_id);
