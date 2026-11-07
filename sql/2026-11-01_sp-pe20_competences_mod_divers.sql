-- sql/2026-11-01_sp-pe20_competences_mod_divers.sql
-- SP-PE20 — Modificateur divers des compétences du personnage
--
-- En attendant une gestion des bonus de dons, capacités et objets magiques, le joueur inscrit sur chaque
-- compétence un modificateur global (signé) et, s'il le souhaite, d'où il vient (« Talent +3, cape +5 »).
-- Il s'ajoute au total de la fiche et compte dans l'accès aux sections de notes. Une ligne peut désormais
-- exister sans rang (pec_maitrise = 0) quand seul le modificateur est saisi. Décision D-PE20a.
-- Pas de DELIMITER.

SET NAMES utf8mb4;

ALTER TABLE dd_personnages_competences
  ADD COLUMN pec_mod_divers SMALLINT NOT NULL DEFAULT 0
    COMMENT 'Modificateur divers saisi par le joueur (dons, capacités, objets) — SP-PE20'
    AFTER pec_maitrise,
  ADD COLUMN pec_mod_libelle VARCHAR(200) NULL DEFAULT NULL
    COMMENT 'Origine du modificateur divers, texte libre — SP-PE20'
    AFTER pec_mod_divers;
