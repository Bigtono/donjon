-- =============================================================================
-- Codex DD v2 — Patch SQL — Module Campagnes — étape 2a (suppression douce)
-- Mis à jour : 2026-06-01 17:19
-- -----------------------------------------------------------------------------
-- Ajoute les colonnes de suppression douce sur les tables de contenu du module.
-- Aucune donnée existante n'est modifiée (DEFAULT 0 / NULL).
-- Le mécanisme de cascade est géré en application (PHP, transaction PDO unique).
-- Pas de triggers ni de FK pour rester cohérent avec le style du schema.sql.
--
-- Tables concernées :
--   dd_campagnes            → camp_supprime, camp_date_supprime
--   dd_scenarios            → sce_supprime,  sce_date_supprime
--   dd_scenarios_chapitres  → scc_supprime,  scc_date_supprime
--   dd_rencontres           → re_supprime,   re_date_supprime
--   dd_oppositions          → opp_supprime,  opp_date_supprime
--   dd_fichiers             → fi_supprime,   fi_date_supprime
--
-- Règle de filtrage (à respecter sur toute requête de lecture) :
--   _supprime = 0   →  contenu actif
--   _supprime = 1   →  supprimé (invisible MJ, récupérable admin uniquement)
--
-- Cascade de suppression (application, une transaction) :
--   Campagne → Scénarios → Chapitres → Rencontres → Oppositions + Fichiers
--   + SET NULL sur dd_personnages.pe_camp_id
--   + DELETE physique sur dd_campagnes_personnages, dd_campagnes_sources,
--     dd_campagnes_notes (lignes de liaison sans contenu propre)
--   + unlink() des fichiers physiques PDF (option A, libération disque immédiate)
--
-- Pas d'interface de restauration côté MJ — récupération admin uniquement en base.
-- =============================================================================

SET NAMES utf8mb4;

-- -----------------------------------------------------------------------------
-- dd_campagnes
-- -----------------------------------------------------------------------------
ALTER TABLE dd_campagnes
  ADD COLUMN camp_supprime      TINYINT(1) NOT NULL DEFAULT 0   COMMENT '0=actif, 1=supprimé (soft delete)'
    AFTER camp_date_creation,
  ADD COLUMN camp_date_supprime DATETIME   DEFAULT NULL         COMMENT 'Horodatage suppression'
    AFTER camp_supprime,
  ADD INDEX idx_camp_supprime (camp_supprime);

-- -----------------------------------------------------------------------------
-- dd_scenarios
-- -----------------------------------------------------------------------------
ALTER TABLE dd_scenarios
  ADD COLUMN sce_supprime      TINYINT(1) NOT NULL DEFAULT 0   COMMENT '0=actif, 1=supprimé'
    AFTER sce_camp_id,
  ADD COLUMN sce_date_supprime DATETIME   DEFAULT NULL         COMMENT 'Horodatage suppression'
    AFTER sce_supprime,
  ADD INDEX idx_sce_supprime (sce_supprime);

-- -----------------------------------------------------------------------------
-- dd_scenarios_chapitres
-- -----------------------------------------------------------------------------
ALTER TABLE dd_scenarios_chapitres
  ADD COLUMN scc_supprime      TINYINT(1) NOT NULL DEFAULT 0   COMMENT '0=actif, 1=supprimé'
    AFTER scc_sce_id,
  ADD COLUMN scc_date_supprime DATETIME   DEFAULT NULL         COMMENT 'Horodatage suppression'
    AFTER scc_supprime,
  ADD INDEX idx_scc_supprime (scc_supprime);

-- -----------------------------------------------------------------------------
-- dd_rencontres
-- -----------------------------------------------------------------------------
ALTER TABLE dd_rencontres
  ADD COLUMN re_supprime      TINYINT(1) NOT NULL DEFAULT 0   COMMENT '0=actif, 1=supprimé'
    AFTER re_scc_id,
  ADD COLUMN re_date_supprime DATETIME   DEFAULT NULL         COMMENT 'Horodatage suppression'
    AFTER re_supprime,
  ADD INDEX idx_re_supprime (re_supprime);

-- -----------------------------------------------------------------------------
-- dd_oppositions
-- -----------------------------------------------------------------------------
ALTER TABLE dd_oppositions
  ADD COLUMN opp_supprime      TINYINT(1) NOT NULL DEFAULT 0   COMMENT '0=actif, 1=supprimé'
    AFTER opp_re_id,
  ADD COLUMN opp_date_supprime DATETIME   DEFAULT NULL         COMMENT 'Horodatage suppression'
    AFTER opp_supprime,
  ADD INDEX idx_opp_supprime (opp_supprime);

-- -----------------------------------------------------------------------------
-- dd_fichiers
-- -----------------------------------------------------------------------------
ALTER TABLE dd_fichiers
  ADD COLUMN fi_supprime      TINYINT(1) NOT NULL DEFAULT 0   COMMENT '0=actif, 1=supprimé (fichier physique déjà supprimé via unlink)'
    AFTER fi_date,
  ADD COLUMN fi_date_supprime DATETIME   DEFAULT NULL         COMMENT 'Horodatage suppression'
    AFTER fi_supprime,
  ADD INDEX idx_fi_supprime (fi_supprime);

-- =============================================================================
-- Fin du patch — étape 2a.
-- Étape 2b (à venir) : reprise de données v1→v2 (pe_camp_id → dd_campagnes_personnages,
-- renommage sc_* → sce_*).
-- =============================================================================
