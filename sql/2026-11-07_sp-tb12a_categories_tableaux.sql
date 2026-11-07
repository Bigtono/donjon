-- sql/2026-11-07_sp-tb12a_categories_tableaux.sql
-- SP-TB12a — Catégories de tableaux : critère de filtrage du gestionnaire et du sélecteur
--
-- Table de référence commune aux deux rulesets (pas de _ruleset_var_id) : une catégorie
-- « sort » ou « monstre » a le même sens en DD3.5 et en DD2024 (D-TB20).
-- Une seule catégorie par tableau, facultative : tab_tabc_id NULL = sans catégorie (D-TB21).
-- Ids figés : la migration d'upsert SP-TB12b y fait référence par id.
-- Le classement des tableaux existants est porté par 2026-11-07_sp-tb12b_tableaux_upsert.sql.
-- Pas de DELIMITER.

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS dd_tableaux_categories (
  tabc_id    int(10) UNSIGNED     NOT NULL AUTO_INCREMENT,
  tabc_slug  varchar(40)          NOT NULL COMMENT 'Clé stable entre environnements',
  tabc_nom   varchar(80)          NOT NULL COMMENT 'Libellé affiché (filtre, formulaire, fiche)',
  tabc_ordre smallint(5) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Ordre dans les listes déroulantes',
  PRIMARY KEY (tabc_id),
  UNIQUE KEY uk_tabc_slug (tabc_slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Catégories des tableaux dd_tableaux, communes aux rulesets (SP-TB12)';

INSERT IGNORE INTO dd_tableaux_categories (tabc_id, tabc_slug, tabc_nom, tabc_ordre) VALUES
  (1, 'classe',       'Classe',       10),
  (2, 'race',         'Race',         20),
  (3, 'don',          'Don',          30),
  (4, 'sort',         'Sort',         40),
  (5, 'monstre',      'Monstre',      50),
  (6, 'objet-magique','Objet magique',60),
  (7, 'regle',        'Règle',        70),
  (8, 'equipement',   'Équipement',   80);

ALTER TABLE dd_tableaux
  ADD COLUMN tab_tabc_id int(10) UNSIGNED DEFAULT NULL
    COMMENT 'Catégorie -> dd_tableaux_categories, NULL = sans catégorie (SP-TB12)'
    AFTER tab_note,
  ADD KEY idx_tab_categorie (tab_tabc_id),
  ADD CONSTRAINT fk_tab_categorie FOREIGN KEY (tab_tabc_id)
    REFERENCES dd_tableaux_categories (tabc_id) ON DELETE SET NULL;
