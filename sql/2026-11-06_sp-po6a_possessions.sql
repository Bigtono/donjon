-- sql/2026-11-06_sp-po6a_possessions.sql
-- SP-PO6 — Possessions du personnage : schéma (D-PO15 → D-PO20)
--
-- dd_personnages_possessions : une ligne par objet de l'inventaire d'un personnage.
--   pp_type = 'equipement' -> pp_eqt_id (dd_equipements)
--   pp_type = 'objet'      -> pp_om_id  (dd_objets_magiques, objet simple)
--   pp_type = 'compose'    -> objet magique complexe DD3.5 composé pour ce personnage (D-PO19) :
--                             pp_compose_cat, objet de base pp_eqt_id (arme / armure / bouclier),
--                             éléments dans dd_personnages_possessions_elements.
--   Prix, coût et PX d'un composé sont calculés par le serveur (include/objet-compose.php, SP-PO7)
--   puis figés ici ; prix en pièces de cuivre comme eqt_prix_pc (1 po = 100 pc).
-- dd_personnages_possessions_elements : propriétés spéciales (ppe_om_id) ou sorts (ppe_so_id) d'un composé.
-- FK logiques, non appliquées par la base (convention du module Personnages).
-- Pas de DELIMITER.

SET NAMES utf8mb4;

CREATE TABLE dd_personnages_possessions (
  pp_id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pp_pe_id         INT UNSIGNED NOT NULL COMMENT '-> dd_personnages',
  pp_type          ENUM('equipement','objet','compose') NOT NULL,
  pp_eqt_id        INT UNSIGNED NULL COMMENT '-> dd_equipements (équipement, ou objet de base d''un composé)',
  pp_om_id         INT UNSIGNED NULL COMMENT '-> dd_objets_magiques (objet simple)',
  pp_nom           VARCHAR(200) NULL COMMENT 'Nom libre ; composé : nom généré, modifiable',
  pp_quantite      SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  pp_equipe        TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 = porté / en main',
  pp_harmonise     TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'DD2024 : objet harmonisé (SP-PO12)',
  pp_charges       SMALLINT UNSIGNED NULL COMMENT 'Charges restantes (baguette : 50 à la création)',
  pp_notes         TEXT NULL,
  pp_compose_cat   ENUM('arme','armure','bouclier','potion','huile','baguette','parchemin') NULL COMMENT 'Composé seulement',
  pp_maitre        TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Composé : qualité de maître (implicite pour une arme ou armure magique)',
  pp_bonus         TINYINT UNSIGNED NULL COMMENT 'Composé : bonus d''altération (+1 à +5)',
  pp_bonus_tete2   TINYINT UNSIGNED NULL COMMENT 'Composé : bonus de la seconde tête d''une arme double',
  pp_nls           TINYINT UNSIGNED NULL COMMENT 'Composé : niveau de lanceur de sorts calculé',
  pp_prix_pc       INT UNSIGNED NULL COMMENT 'Composé : prix de vente calculé (photo), en pc',
  pp_cout_pc       INT UNSIGNED NULL COMMENT 'Composé : coût de création en po (photo), en pc',
  pp_cout_px       INT UNSIGNED NULL COMMENT 'Composé : coût de création en PX (photo)',
  pp_ordre         SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  pp_date_creation DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  pp_date_maj      DATETIME NULL,
  PRIMARY KEY (pp_id),
  KEY idx_pp_pe (pp_pe_id, pp_type, pp_ordre),
  KEY idx_pp_eqt (pp_eqt_id),
  KEY idx_pp_om (pp_om_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE dd_personnages_possessions_elements (
  ppe_id        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  ppe_pp_id     INT UNSIGNED NOT NULL COMMENT '-> dd_personnages_possessions (composé)',
  ppe_type      ENUM('propriete','sort') NOT NULL,
  ppe_tete      TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Arme double : 1 ou 2',
  ppe_om_id     INT UNSIGNED NULL COMMENT '-> dd_objets_magiques (propriété spéciale, catégories 29 / 30)',
  ppe_so_id     INT UNSIGNED NULL COMMENT '-> dd_sorts',
  ppe_cla_id    INT UNSIGNED NULL COMMENT '-> dd_classes : liste de classe qui fixe le niveau du sort',
  ppe_niveau    TINYINT UNSIGNED NULL COMMENT 'Niveau du sort dans cette liste (photo)',
  ppe_nls       TINYINT UNSIGNED NULL COMMENT 'NLS du sort',
  ppe_parametre VARCHAR(150) NULL COMMENT 'Tueuse : créature ; Stockage de sort : sort ; Aura élémentaire : énergie…',
  ppe_suppl_pc  INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Composantes coûteuses saisies à la main, en pc',
  ppe_suppl_px  INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Coût en PX du sort saisi à la main',
  ppe_utilise   TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Parchemin : sort déjà lu',
  ppe_ordre     SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (ppe_id),
  KEY idx_ppe_pp (ppe_pp_id, ppe_ordre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
