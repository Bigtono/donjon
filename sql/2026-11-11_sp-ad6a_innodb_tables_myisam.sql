-- sql/2026-11-11_sp-ad6a_innodb_tables_myisam.sql
-- SP-AD6a — Passage en InnoDB des cinq dernières tables MyISAM du compendium
--
-- La suppression en cascade d'une ressource (SP-AD6b, include/ressource-suppression.php) s'exécute
-- dans UNE transaction, avec une vérification « zéro orphelin » avant le COMMIT. Une table MyISAM
-- ignore la transaction : en cas d'échec, ses lignes resteraient supprimées et deviendraient des
-- orphelins. Ces tables sont rattachées aux classes, aux races et aux domaines.
--
-- Seul le moteur change : jeu de caractères, colonnes et index sont conservés.
-- IDEMPOTENT : un ALTER … ENGINE=InnoDB sur une table déjà InnoDB la reconstruit sans effet.
-- Pas de DELIMITER.

SET NAMES utf8mb4;

ALTER TABLE dd_races             ENGINE=InnoDB;
ALTER TABLE dd_race_capacite     ENGINE=InnoDB;
ALTER TABLE dd_classe_niveau     ENGINE=InnoDB;
ALTER TABLE dd_classe_competence ENGINE=InnoDB;
ALTER TABLE dd_domaines          ENGINE=InnoDB;
