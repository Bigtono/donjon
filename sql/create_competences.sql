-- ============================================================
-- dd_competences — Compétences du compendium
-- Ruleset : DD3.5 + DD2024
-- Préfixe champs : comp_
-- Note : comp_camp_id présent pour compatibilité moteur compendium-liste.php
--        (infère <alias>_camp_id IS NULL pour filtrer le compendium global)
--        Réservé pour un éventuel homebrew futur — toujours NULL pour l'instant.
-- ============================================================

CREATE TABLE `dd_competences` (
  `comp_id`              INT          NOT NULL AUTO_INCREMENT,
  `comp_nom`             VARCHAR(150) NOT NULL,
  `comp_caracteristique` VARCHAR(5)   NULL     DEFAULT NULL
                                      COMMENT 'DD3.5 : FOR | DEX | CON | INT | SAG | CHA',
  `comp_formation`       TINYINT(1)   NOT NULL DEFAULT 0
                                      COMMENT 'DD3.5 : 1 = formation obligatoire',
  `comp_armure`          TINYINT(1)   NOT NULL DEFAULT 0
                                      COMMENT 'DD3.5 : 1 = malus armure applicable',
  `comp_texte`           TEXT         NULL     DEFAULT NULL,
  `comp_resume`          TEXT         NULL     DEFAULT NULL
                                      COMMENT 'Usage futur dans les listes',
  `comp_res_id`          INT          NOT NULL,
  `comp_camp_id`         INT          NULL     DEFAULT NULL
                                      COMMENT 'Compatibilité moteur + homebrew futur',
  `comp_ruleset_var_id`  INT          NOT NULL,
  PRIMARY KEY (`comp_id`),
  KEY `idx_comp_res`     (`comp_res_id`),
  KEY `idx_comp_ruleset` (`comp_ruleset_var_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
