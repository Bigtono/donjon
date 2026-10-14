-- sql/2026-10-11_equipements_00_schema_sp-po0.sql
-- SP-PO0 — Schéma des équipements : catégories, prix, poids, attributs,
--          ordre d'affichage et mécanisme Supplément utilisateur.
--
-- Contexte : dd_equipements (SP-E0) était vide et sans catégorie ni donnée
-- chiffrée. Le tag de liste [[liste:equipement|famille=…|source=…]] (SP-PO1) et
-- l'import des équipements du DRS 07 (SP-PO2) exigent une famille, un prix, un
-- poids et des attributs propres à la famille (dégâts, critique, bonus d'armure…).
--
-- MODÈLE (arbitré le 2026-10-11) :
--   * dd_categorie_equipement — arbre par ruleset (famille > sous-catégorie > …).
--     cae_colonnes (JSON) définit à la fois les colonnes de la liste ET les champs
--     du formulaire ; NULL = hérite du parent.
--   * dd_equipements.eqt_attributs — JSON { clé : valeur } selon cae_colonnes.
--   * prix et poids : valeur numérique (pièces de cuivre, grammes) pour le tri et
--     les futurs calculs, + texte d'affichage quand la valeur n'est pas un nombre
--     (« spécial », « +50 po », « Niveau × 5 po »).
--   * Supplément utilisateur (SP-C) : eqt_public, sur le modèle de om_public.
--     eqt_visible existait déjà. (Solde SP-E5.)
--
-- Les objets magiques reçoivent un slug de catégorie (com_slug) : la référence du
-- tag se fait par slug, jamais par id (les ids diffèrent entre local et OVH).
--
-- IDEMPOTENCE : les ADD COLUMN ne sont pas ré-exécutables. Vérifier avant rejeu :
--   SHOW COLUMNS FROM dd_equipements LIKE 'eqt_cae_id';
-- Le reste est rejouable. Aucun DELIMITER.

SET NAMES utf8mb4;

-- ------------------------------------------------------------
-- 1. Catégories d'équipement
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dd_categorie_equipement (
  cae_id             INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  cae_cae_id         INT UNSIGNED  NULL COMMENT 'Parent récursif ; NULL = famille racine',
  cae_nom            VARCHAR(100)  NOT NULL,
  cae_slug           VARCHAR(100)  NOT NULL COMMENT 'Clé du paramètre famille= du tag [[liste:…]]',
  cae_colonnes       TEXT          NULL COMMENT 'JSON [{k,l,a,liste}] ; NULL = hérite du parent',
  cae_ordre          SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  cae_ruleset_var_id INT UNSIGNED  NOT NULL COMMENT '-> dd_variables',
  PRIMARY KEY (cae_id),
  UNIQUE KEY uk_cae_slug (cae_slug, cae_ruleset_var_id),
  KEY idx_cae_parent (cae_cae_id),
  KEY idx_cae_ruleset (cae_ruleset_var_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 2. dd_equipements — famille, données chiffrées, supplément
-- ------------------------------------------------------------
ALTER TABLE dd_equipements
  ADD COLUMN eqt_cae_id     INT UNSIGNED NULL
      COMMENT '-> dd_categorie_equipement' AFTER eqt_nom,
  ADD COLUMN eqt_prix_pc    INT UNSIGNED NULL
      COMMENT 'Prix en pièces de cuivre (1 po = 100 pc) ; NULL = sans prix chiffré' AFTER eqt_cae_id,
  ADD COLUMN eqt_prix_txt   VARCHAR(60)  NULL
      COMMENT 'Prix affiché quand il n''est pas un nombre (« spécial », « +50 po »)' AFTER eqt_prix_pc,
  ADD COLUMN eqt_poids_g    INT UNSIGNED NULL
      COMMENT 'Poids en grammes ; NULL = négligeable ou sans objet' AFTER eqt_prix_txt,
  ADD COLUMN eqt_poids_txt  VARCHAR(60)  NULL
      COMMENT 'Poids affiché quand il n''est pas un nombre (« spécial », « +2,5 kg »)' AFTER eqt_poids_g,
  ADD COLUMN eqt_attributs  TEXT         NULL
      COMMENT 'JSON { clé : valeur } selon cae_colonnes de la catégorie' AFTER eqt_poids_txt,
  ADD COLUMN eqt_ordre      SMALLINT UNSIGNED NOT NULL DEFAULT 0
      COMMENT 'Ordre dans la catégorie (celui du livre) ; à égalité, nom' AFTER eqt_attributs,
  ADD COLUMN eqt_public     TINYINT(1)   NOT NULL DEFAULT 0
      COMMENT 'Supplément : 0 = privé, 1 = partagé' AFTER eqt_visible,
  ADD KEY idx_eqt_cae (eqt_cae_id);

-- ------------------------------------------------------------
-- 3. Slug de catégorie d'objet magique
--    Rempli par le NOM (les ids ne sont pas stables d'un environnement à l'autre).
-- ------------------------------------------------------------
ALTER TABLE dd_categorie_objet_magique
  ADD COLUMN com_slug VARCHAR(100) NULL AFTER com_nom,
  ADD UNIQUE KEY uk_com_slug (com_slug, com_ruleset_var_id);

UPDATE dd_categorie_objet_magique SET com_slug = CASE com_nom
  WHEN 'Anneaux'                        THEN 'anneaux'
  WHEN 'Armes'                          THEN 'armes'
  WHEN 'Armures et boucliers'           THEN 'armures-et-boucliers'
  WHEN 'Armures'                        THEN 'armures'
  WHEN 'Baguettes'                      THEN 'baguettes'
  WHEN 'Bâtons'                         THEN 'batons'
  WHEN 'Objets merveilleux'             THEN 'objets-merveilleux'
  WHEN 'Parchemins'                     THEN 'parchemins'
  WHEN 'Potions & Huiles'               THEN 'potions-et-huiles'
  WHEN 'Potions'                        THEN 'potions'
  WHEN 'Sceptres'                       THEN 'sceptres'
  WHEN 'Objets maudits'                 THEN 'objets-maudits'
  WHEN 'Propriétés spéciales des armes'   THEN 'proprietes-speciales-des-armes'
  WHEN 'Propriétés spéciales des armures' THEN 'proprietes-speciales-des-armures'
  WHEN 'Artefacts mineurs'              THEN 'artefacts-mineurs'
  WHEN 'Artefacts majeurs'              THEN 'artefacts-majeurs'
  ELSE NULL END
WHERE com_slug IS NULL;

-- Filet de sécurité : toute catégorie inconnue reçoit un slug technique.
UPDATE dd_categorie_objet_magique
SET    com_slug = CONCAT('categorie-', com_id)
WHERE  com_slug IS NULL;
