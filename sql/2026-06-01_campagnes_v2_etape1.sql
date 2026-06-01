-- =============================================================================
-- Codex DD v2 — Patch SQL — Module Campagnes — étape 1 (structure)
-- Mis à jour : 2026-06-01 16:42
-- -----------------------------------------------------------------------------
-- Aligne le schéma réel sur SCHEMA_SQL.md v1.1 (section 7 + pe_camp_id).
-- À appliquer sur la base de DÉVELOPPEMENT (préfixe dd_). En production OVH,
-- le préfixe deviendra dd2_ au déploiement (cf. DECISIONS_LOG).
--
-- Idempotent autant que possible (IF EXISTS / IF NOT EXISTS).
-- N'altère AUCUNE donnée du compendium. La reprise de données v1->v2
-- (pe_camp_id -> dd_campagnes_personnages, sc_* -> sce_*) fait l'objet d'un
-- patch de migration séparé (étape 2).
--
-- Récapitulatif :
--   1. dd_personnages   : + pe_camp_id (dernière campagne jouée)
--   2. dd_campagnes      : + camp_un_id (univers 1-1), description -> LONGTEXT
--   3. dd_campagnes_univers : SUPPRIMÉE (remplacée par camp_un_id)
--   4. dd_scenarios      : - sce_ruleset_var_id (ruleset hérité), description -> LONGTEXT
--   5. dd_rencontres     : re_scc_id NOT NULL, + re_composition, description -> LONGTEXT
--   6. dd_oppositions    : CRÉÉE (copie éditable de monstre)
--   7. dd_rencontres_monstres : SUPPRIMÉE (remplacée par dd_oppositions)
--   8. dd_fichiers       : CRÉÉE (pièces jointes PDF génériques)
-- =============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------------------------------
-- 1. dd_personnages : raccourci « dernière campagne jouée »
--    La source de vérité du lien reste dd_campagnes_personnages (N-N).
-- -----------------------------------------------------------------------------
ALTER TABLE dd_personnages
  ADD COLUMN pe_camp_id INT UNSIGNED DEFAULT NULL
    COMMENT '-> dd_campagnes (dernière campagne jouée ; NULL = aucune)'
    AFTER pe_ruleset_var_id;

-- -----------------------------------------------------------------------------
-- 2. dd_campagnes : univers 1-1 + description riche
-- -----------------------------------------------------------------------------
ALTER TABLE dd_campagnes
  ADD COLUMN camp_un_id INT UNSIGNED DEFAULT NULL
    COMMENT '-> dd_univers (univers de la campagne ; NULL = aucun)'
    AFTER camp_ruleset_var_id;

ALTER TABLE dd_campagnes
  MODIFY COLUMN camp_description LONGTEXT DEFAULT NULL
    COMMENT 'HTML TinyMCE (images uploadées autorisées)';

-- -----------------------------------------------------------------------------
-- 3. dd_campagnes_univers : abandonnée au profit de camp_un_id
--    (table vide en dev ; aucune reprise nécessaire)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS dd_campagnes_univers;

-- -----------------------------------------------------------------------------
-- 4. dd_scenarios : ruleset hérité de la campagne + description riche
-- -----------------------------------------------------------------------------
ALTER TABLE dd_scenarios
  DROP COLUMN sce_ruleset_var_id;

ALTER TABLE dd_scenarios
  MODIFY COLUMN sce_description LONGTEXT DEFAULT NULL
    COMMENT 'HTML TinyMCE (images uploadées autorisées)';

-- -----------------------------------------------------------------------------
-- 5. dd_rencontres : rattachement chapitre obligatoire, composition littérale,
--    description riche.
--    NB : re_scc_id passe NOT NULL. S'assurer au préalable qu'aucune rencontre
--    orpheline (re_scc_id IS NULL) ne subsiste, sinon l'ALTER échouera.
-- -----------------------------------------------------------------------------
-- Contrôle préalable (à exécuter manuellement si doute) :
--   SELECT re_id, re_nom FROM dd_rencontres WHERE re_scc_id IS NULL;

ALTER TABLE dd_rencontres
  MODIFY COLUMN re_scc_id INT UNSIGNED NOT NULL
    COMMENT '-> dd_scenarios_chapitres (chapitre parent, obligatoire)';

ALTER TABLE dd_rencontres
  ADD COLUMN re_composition TEXT DEFAULT NULL
    COMMENT 'Détail littéral de la rencontre (effectifs, disposition, vagues...)'
    AFTER re_description;

ALTER TABLE dd_rencontres
  MODIFY COLUMN re_description LONGTEXT DEFAULT NULL
    COMMENT 'HTML TinyMCE (images uploadées autorisées)';

-- -----------------------------------------------------------------------------
-- 6. dd_oppositions : copie éditable d'un monstre du compendium, propre à une
--    rencontre. Lien rencontre 1-N (opp_re_id) ; pas de table de liaison.
--    opp_mo_id = template figé (traçabilité), non éditable par le MJ.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dd_oppositions (
  opp_id        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  opp_nom       VARCHAR(150) NOT NULL                COMMENT 'Recopié de mo_nom, éditable',
  opp_mocat_nom VARCHAR(150)          DEFAULT NULL   COMMENT 'Libellé catégorie (texte libre), éditable',
  opp_stats     TEXT                  DEFAULT NULL   COMMENT 'Recopié de mo_stats, éditable',
  opp_re_id     INT UNSIGNED NOT NULL                COMMENT '-> dd_rencontres (rencontre parente)',
  opp_mo_id     INT UNSIGNED NOT NULL                COMMENT '-> dd_monstres (template figé, non éditable)',
  PRIMARY KEY (opp_id),
  KEY idx_opp_re (opp_re_id),
  KEY idx_opp_mo (opp_mo_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------------------------
-- 7. dd_rencontres_monstres : abandonnée (remplacée par dd_oppositions)
--    Table vide en dev ; aucune reprise nécessaire.
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS dd_rencontres_monstres;

-- -----------------------------------------------------------------------------
-- 8. dd_fichiers : pièces jointes PDF génériques (polymorphe).
--    Rattachable à une campagne, un scénario ou une rencontre.
--    Le binaire est stocké hors base ; fi_chemin = chemin relatif serveur.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dd_fichiers (
  fi_id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  fi_entite      ENUM('campagne','scenario','rencontre') NOT NULL
                   COMMENT 'Type d''entité porteuse',
  fi_entite_id   INT UNSIGNED NOT NULL
                   COMMENT 'Id de l''entité porteuse (camp_id / sce_id / re_id)',
  fi_nom_origine VARCHAR(255) NOT NULL COMMENT 'Nom de fichier d''origine (affichage)',
  fi_chemin      VARCHAR(255) NOT NULL COMMENT 'Chemin relatif de stockage serveur',
  fi_mime        VARCHAR(100) NOT NULL COMMENT 'Type MIME validé (application/pdf attendu)',
  fi_taille      INT UNSIGNED NOT NULL COMMENT 'Taille en octets',
  fi_j_id        INT UNSIGNED NOT NULL COMMENT '-> dd_joueurs (déposant)',
  fi_date        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (fi_id),
  KEY idx_fi_entite (fi_entite, fi_entite_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- Fin du patch — étape 1.
-- Étape 2 (à venir) : reprise de données v1->v2 (pe_camp_id, sc_*->sce_*).
-- =============================================================================
