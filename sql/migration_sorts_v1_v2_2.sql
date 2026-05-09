-- ============================================================
-- Migration sorts v1 → v2
-- Auteur : Codex DD
--
-- Étapes :
--   1. Exporter dd_sorts depuis OVH phpMyAdmin (données uniquement)
--   2. Importer dans XAMPP dans dd_sorts_import (voir CREATE ci-dessous)
--   3. Exécuter ce script
-- ============================================================


-- ------------------------------------------------------------
-- ÉTAPE 1 : Table d'import temporaire (structure v1)
-- Créer cette table AVANT d'importer le dump OVH
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS dd_sorts_import (
  so_id                 INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  so_nom                VARCHAR(150)     NOT NULL,
  so_co_id              INT UNSIGNED     DEFAULT NULL,
  so_branche            VARCHAR(40)      DEFAULT NULL,
  so_vocal              TINYINT(4)       NOT NULL DEFAULT 0,
  so_gestuel            TINYINT(4)       NOT NULL DEFAULT 0,
  so_materiel           TINYINT(4)       NOT NULL DEFAULT 0,
  so_focalisateur       TINYINT(4)       NOT NULL DEFAULT 0,
  so_focalisateur_divin TINYINT(4)       NOT NULL DEFAULT 0,
  so_resistance         TINYINT(4)       NOT NULL DEFAULT 0,  -- 0/1 en v1
  so_duree_incantation  VARCHAR(100)     NOT NULL DEFAULT '',
  so_portee             VARCHAR(100)     NOT NULL DEFAULT '',
  so_cible              VARCHAR(150)     NOT NULL DEFAULT '',
  so_zone_effet         VARCHAR(100)     NOT NULL DEFAULT '',
  so_duree_sort         VARCHAR(100)     DEFAULT NULL,
  so_jet_sauvegarde     VARCHAR(100)     DEFAULT NULL,
  so_res_id             INT UNSIGNED     NOT NULL DEFAULT 0,
  so_page               VARCHAR(20)      DEFAULT NULL,  -- ignoré en v2
  so_texte              TEXT             DEFAULT NULL,
  so_resume             TEXT             DEFAULT NULL,  -- ignoré en v2
  PRIMARY KEY (so_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- → Importer ici le dump OVH dans dd_sorts_import


-- ------------------------------------------------------------
-- ÉTAPE 2 : Migration vers dd_sorts v2
-- Transformations appliquées :
--   so_texte          → so_description
--   so_resistance     → varchar 'Oui'/'Non' (était tinyint 0/1)
--   so_composante     → calculé depuis les champs booléens
--   so_camp_id        → NULL (compendium global)
--   so_ruleset_var_id → 1 (DD3.5)
--   so_page           → supprimé
--   so_resume         → supprimé
-- ------------------------------------------------------------

INSERT INTO dd_sorts (
  so_id,
  so_nom,
  so_co_id,
  so_branche,
  so_vocal,
  so_gestuel,
  so_materiel,
  so_focalisateur,
  so_focalisateur_divin,
  so_composante,
  so_portee,
  so_cible,
  so_zone_effet,
  so_duree_incantation,
  so_duree_sort,
  so_resistance,
  so_jet_sauvegarde,
  so_description,
  so_res_id,
  so_camp_id,
  so_ruleset_var_id
)
SELECT
  so_id,
  so_nom,
  so_co_id,
  so_branche,
  so_vocal,
  so_gestuel,
  so_materiel,
  so_focalisateur,
  so_focalisateur_divin,

  -- so_composante : calculé depuis les champs booléens v1
  -- Produit ex : "V, G, M" ou "V, FD"
  NULLIF(
    TRIM(BOTH ', ' FROM CONCAT(
      IF(so_vocal            = 1, 'V, ',  ''),
      IF(so_gestuel          = 1, 'G, ',  ''),
      IF(so_materiel         = 1, 'M, ',  ''),
      IF(so_focalisateur     = 1, 'F, ',  ''),
      IF(so_focalisateur_divin = 1, 'FD', '')
    )),
    ''
  ),

  so_portee,
  so_cible,
  so_zone_effet,
  so_duree_incantation,
  so_duree_sort,

  -- so_resistance : tinyint(0/1) → varchar
  CASE so_resistance
    WHEN 1 THEN 'Oui'
    WHEN 0 THEN 'Non'
    ELSE NULL
  END,

  -- so_jet_sauvegarde : int v1 → varchar v2 (cast implicite MySQL)
  NULLIF(CAST(so_jet_sauvegarde AS CHAR), ''),

  -- so_texte → so_description
  so_texte,

  so_res_id,

  -- Nouveaux champs v2
  NULL,   -- so_camp_id : NULL = compendium global
  1       -- so_ruleset_var_id : 1 = DD3.5

FROM dd_sorts_import;


-- ------------------------------------------------------------
-- ÉTAPE 3 : Migration dd_sortclasse
-- La structure est identique entre v1 et v2 — simple copie
-- Exporter dd_sortclasse depuis OVH, importer directement
-- dans dd_sortclasse v2 (pas de transformation nécessaire)
-- ------------------------------------------------------------

-- Si vous préférez passer par une table intermédiaire :
-- CREATE TABLE dd_sortclasse_import LIKE dd_sortclasse;
-- → importer le dump OVH dans dd_sortclasse_import
-- INSERT INTO dd_sortclasse SELECT * FROM dd_sortclasse_import;


-- ------------------------------------------------------------
-- ÉTAPE 4 : Migration dd_colleges
-- Table identique entre v1 et v2 — simple copie
-- Exporter dd_colleges depuis OVH, importer directement
-- (vérifier les co_id avant d'importer pour éviter les conflits)
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- NETTOYAGE (après vérification)
-- ------------------------------------------------------------

-- DROP TABLE dd_sorts_import;
-- DROP TABLE IF EXISTS dd_sortclasse_import;
