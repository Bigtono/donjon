-- ============================================================
-- Codex DD v2 — Schéma de base de données
-- Convention : tables préfixées dd_, champs préfixés par table
-- ============================================================

SET NAMES utf8mb4;
SET foreign_key_checks = 0;

-- ------------------------------------------------------------
-- RÉFÉRENTIELS
-- ------------------------------------------------------------

CREATE TABLE dd_variables (
  var_id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  var_cat     VARCHAR(50)  NOT NULL COMMENT 'Catégorie (ex: ruleset, tcap...)',
  var_valeur  VARCHAR(100) NOT NULL,
  var_ordre   TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (var_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Référentiel de valeurs paramétrables';

-- Données initiales rulesets
INSERT INTO dd_variables (var_cat, var_valeur, var_ordre) VALUES
  ('ruleset', 'DD3.5',  1),
  ('ruleset', 'DD2024', 2);

CREATE TABLE dd_ressources (
  res_id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  res_nom            VARCHAR(150) NOT NULL,
  res_abreviation    VARCHAR(20)  NOT NULL,
  res_selection      TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '1 = actif globalement',
  res_ruleset_var_id INT UNSIGNED NOT NULL COMMENT '-> dd_variables',
  res_j_id           INT UNSIGNED          DEFAULT NULL COMMENT 'null = officiel, sinon propriétaire homebrew',
  PRIMARY KEY (res_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_caracteristiques (
  car_id        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  car_nom       VARCHAR(30)  NOT NULL,
  car_diminutif CHAR(3)      NOT NULL COMMENT '3 premières lettres du nom',
  PRIMARY KEY (car_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO dd_caracteristiques (car_nom, car_diminutif) VALUES
  ('Force',        'for'),
  ('Constitution', 'con'),
  ('Dextérité',    'dex'),
  ('Intelligence', 'int'),
  ('Sagesse',      'sag'),
  ('Charisme',     'cha');

CREATE TABLE dd_modificateurs (
  mod_id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  mod_carac       TINYINT UNSIGNED NOT NULL COMMENT 'Valeur de carac (1-30)',
  mod_modificateur TINYINT          NOT NULL,
  mod_bonusSort0  TINYINT UNSIGNED NOT NULL DEFAULT 0,
  mod_bonusSort1  TINYINT UNSIGNED NOT NULL DEFAULT 0,
  mod_bonusSort2  TINYINT UNSIGNED NOT NULL DEFAULT 0,
  mod_bonusSort3  TINYINT UNSIGNED NOT NULL DEFAULT 0,
  mod_bonusSort4  TINYINT UNSIGNED NOT NULL DEFAULT 0,
  mod_bonusSort5  TINYINT UNSIGNED NOT NULL DEFAULT 0,
  mod_bonusSort6  TINYINT UNSIGNED NOT NULL DEFAULT 0,
  mod_bonusSort7  TINYINT UNSIGNED NOT NULL DEFAULT 0,
  mod_bonusSort8  TINYINT UNSIGNED NOT NULL DEFAULT 0,
  mod_bonusSort9  TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (mod_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- UTILISATEURS
-- ------------------------------------------------------------

CREATE TABLE dd_joueurs (
  j_id                    INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  j_prenom                VARCHAR(50)   NOT NULL DEFAULT '',
  j_nom                   VARCHAR(50)   NOT NULL DEFAULT '',
  j_pseudo                VARCHAR(50)   NOT NULL,
  j_email                 VARCHAR(150)  NOT NULL,
  j_password_hash         VARCHAR(255)  NOT NULL,
  j_remember_token        VARCHAR(100)           DEFAULT NULL,
  j_remember_token_expires DATETIME              DEFAULT NULL,
  j_avatar_url            VARCHAR(255)           DEFAULT NULL,
  j_bio                   TEXT                   DEFAULT NULL,
  j_date_inscription      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  j_derniere_connexion    DATETIME               DEFAULT NULL,
  j_admin                 TINYINT(1)    NOT NULL DEFAULT 0 COMMENT '1 = admin global',
  j_compendium_manager    TINYINT(1)    NOT NULL DEFAULT 0 COMMENT '1 = peut éditer compendium global',
  j_default_ruleset_var_id INT UNSIGNED          DEFAULT NULL COMMENT '-> dd_variables',
  j_items_par_page        TINYINT UNSIGNED NOT NULL DEFAULT 20,
  j_visible               TINYINT(1)    NOT NULL DEFAULT 1,
  j_notes                 TEXT                   DEFAULT NULL,
  j_mode_campagne         TINYINT(1)    NOT NULL DEFAULT 0,
  j_affichage_ruleset     TINYINT(1)    NOT NULL DEFAULT 1,
  j_dd_onglet_sort        TINYINT(1)    NOT NULL DEFAULT 0,
  j_dd_onglet_don         TINYINT(1)    NOT NULL DEFAULT 0,
  j_dd_onglet_om          TINYINT(1)    NOT NULL DEFAULT 0,
  PRIMARY KEY (j_id),
  UNIQUE KEY uk_joueurs_email  (j_email),
  UNIQUE KEY uk_joueurs_pseudo (j_pseudo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Sélection de sources par utilisateur (par ruleset)
CREATE TABLE dd_joueurs_sources (
  js_id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  js_j_id            INT UNSIGNED NOT NULL COMMENT '-> dd_joueurs',
  js_res_id          INT UNSIGNED NOT NULL COMMENT '-> dd_ressources',
  js_ruleset_var_id  INT UNSIGNED NOT NULL COMMENT '-> dd_variables',
  PRIMARY KEY (js_id),
  UNIQUE KEY uk_js (js_j_id, js_res_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- COMPENDIUM — RACES
-- ------------------------------------------------------------

CREATE TABLE dd_race_type (
  rat_id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  rat_nom            VARCHAR(50)  NOT NULL,
  rat_ruleset_var_id INT UNSIGNED NOT NULL COMMENT '-> dd_variables',
  PRIMARY KEY (rat_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO dd_race_type (rat_nom, rat_ruleset_var_id) VALUES
  ('Race de base', 1),
  ('Archétype',    1);

CREATE TABLE dd_races (
  ra_id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  ra_nom            VARCHAR(100) NOT NULL,
  ra_rat_id         INT UNSIGNED NOT NULL COMMENT '1=base, 2=archétype -> dd_race_type',
  ra_description    TEXT                  DEFAULT NULL,
  ra_traits         TEXT                  DEFAULT NULL,
  ra_res_id         INT UNSIGNED NOT NULL COMMENT '-> dd_ressources',
  ra_ruleset_var_id INT UNSIGNED NOT NULL COMMENT '-> dd_variables',
  PRIMARY KEY (ra_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- COMPENDIUM — CLASSES
-- ------------------------------------------------------------

CREATE TABLE dd_typeMagie (
  mag_id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  mag_nom            VARCHAR(50)  NOT NULL,
  mag_abreviation    VARCHAR(10)  NOT NULL,
  mag_ruleset_var_id INT UNSIGNED NOT NULL COMMENT '-> dd_variables',
  PRIMARY KEY (mag_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_classes (
  cla_id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cla_nom            VARCHAR(100) NOT NULL,
  cla_abreviation    VARCHAR(20)  NOT NULL DEFAULT '',
  cla_clt_id         TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1=base, 2=prestige (DD3.5)',
  cla_dV             TINYINT UNSIGNED NOT NULL DEFAULT 6,
  cla_alignement     VARCHAR(100)          DEFAULT NULL,
  cla_car_id         INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '-> dd_caracteristiques, 0=aucun',
  cla_mag_id         INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '-> dd_typeMagie, 0=non lanceur',
  cla_sort_connu     TINYINT(1)   NOT NULL DEFAULT 0,
  cla_sort_compris   TINYINT(1)   NOT NULL DEFAULT 0,
  cla_sort_prepare   TINYINT(1)   NOT NULL DEFAULT 0,
  cla_domaine_divin  TINYINT(1)   NOT NULL DEFAULT 0,
  cla_niveauMax      TINYINT UNSIGNED NOT NULL DEFAULT 20 COMMENT '3, 5, 10 ou 20',
  -- DD3.5 spécifique
  cla_pointsCompetences TINYINT UNSIGNED DEFAULT NULL,
  cla_po_niveau1     SMALLINT UNSIGNED    DEFAULT NULL,
  cla_conditions     TEXT                 DEFAULT NULL,
  -- DD2024 spécifique
  cla_armures        TEXT                 DEFAULT NULL,
  cla_outils         TEXT                 DEFAULT NULL,
  cla_sauvegardes    TEXT                 DEFAULT NULL,
  cla_equipement     TEXT                 DEFAULT NULL,
  -- Commun
  cla_armes          TEXT                 DEFAULT NULL,
  cla_competences    TEXT                 DEFAULT NULL,
  cla_sorts          TEXT                 DEFAULT NULL,
  cla_description    TEXT                 DEFAULT NULL,
  cla_traits         TEXT                 DEFAULT NULL,
  cla_caracteristiques TEXT               DEFAULT NULL,
  cla_critere_rec    TEXT                 DEFAULT NULL,
  cla_pouvoir1       VARCHAR(100)         DEFAULT NULL,
  cla_pouvoir2       VARCHAR(100)         DEFAULT NULL,
  cla_pouvoir3       VARCHAR(100)         DEFAULT NULL,
  cla_pouvoir4       VARCHAR(100)         DEFAULT NULL,
  cla_cla_id         INT UNSIGNED         DEFAULT NULL COMMENT 'Classe parente éventuelle',
  cla_res_id         INT UNSIGNED NOT NULL COMMENT '-> dd_ressources',
  cla_camp_id        INT UNSIGNED         DEFAULT NULL COMMENT 'null=global, sinon homebrew -> dd_campagnes',
  cla_ruleset_var_id INT UNSIGNED NOT NULL COMMENT '-> dd_variables',
  PRIMARY KEY (cla_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_classe_niveau (
  cn_id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cn_cla_id      INT UNSIGNED NOT NULL COMMENT '-> dd_classes',
  cn_niveau      TINYINT UNSIGNED NOT NULL,
  cn_bba         VARCHAR(20)  NOT NULL DEFAULT '0' COMMENT 'Bonus base attaque (DD3.5: multi-valeurs ex +3/+1)',
  cn_reflexes    TINYINT      NOT NULL DEFAULT 0,
  cn_vigueur     TINYINT      NOT NULL DEFAULT 0,
  cn_volonte     TINYINT      NOT NULL DEFAULT 0,
  -- Sorts par jour
  cn_sort_n0     TINYINT UNSIGNED DEFAULT NULL,
  cn_sort_n1     TINYINT UNSIGNED DEFAULT NULL,
  cn_sort_n2     TINYINT UNSIGNED DEFAULT NULL,
  cn_sort_n3     TINYINT UNSIGNED DEFAULT NULL,
  cn_sort_n4     TINYINT UNSIGNED DEFAULT NULL,
  cn_sort_n5     TINYINT UNSIGNED DEFAULT NULL,
  cn_sort_n6     TINYINT UNSIGNED DEFAULT NULL,
  cn_sort_n7     TINYINT UNSIGNED DEFAULT NULL,
  cn_sort_n8     TINYINT UNSIGNED DEFAULT NULL,
  cn_sort_n9     TINYINT UNSIGNED DEFAULT NULL,
  -- Sorts connus (DD3.5)
  cn_sortConnu_n0 TINYINT UNSIGNED DEFAULT NULL,
  cn_sortConnu_n1 TINYINT UNSIGNED DEFAULT NULL,
  cn_sortConnu_n2 TINYINT UNSIGNED DEFAULT NULL,
  cn_sortConnu_n3 TINYINT UNSIGNED DEFAULT NULL,
  cn_sortConnu_n4 TINYINT UNSIGNED DEFAULT NULL,
  cn_sortConnu_n5 TINYINT UNSIGNED DEFAULT NULL,
  cn_sortConnu_n6 TINYINT UNSIGNED DEFAULT NULL,
  cn_sortConnu_n7 TINYINT UNSIGNED DEFAULT NULL,
  cn_sortConnu_n8 TINYINT UNSIGNED DEFAULT NULL,
  cn_sortConnu_n9 TINYINT UNSIGNED DEFAULT NULL,
  -- NLS prestige (DD3.5)
  cn_niveauSortArcane   TINYINT(1) NOT NULL DEFAULT 0,
  cn_niveauSortDivin    TINYINT(1) NOT NULL DEFAULT 0,
  cn_niveauSortEffectif TINYINT(1) NOT NULL DEFAULT 0,
  -- Pouvoirs spécifiques
  cn_pouvoir1    VARCHAR(255) DEFAULT NULL,
  cn_pouvoir2    VARCHAR(255) DEFAULT NULL,
  cn_pouvoir3    VARCHAR(255) DEFAULT NULL,
  cn_pouvoir4    VARCHAR(255) DEFAULT NULL,
  -- DD2024
  cn_sortPrepare TINYINT UNSIGNED DEFAULT NULL,
  PRIMARY KEY (cn_id),
  UNIQUE KEY uk_cn (cn_cla_id, cn_niveau)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_capacites_speciales (
  cap_id               INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cap_nom              VARCHAR(150) NOT NULL,
  cap_description      TEXT                  DEFAULT NULL,
  cap_type             VARCHAR(50)           DEFAULT NULL,
  cap_categorie_var_id INT UNSIGNED          DEFAULT NULL COMMENT '-> dd_variables cat=tcap',
  PRIMARY KEY (cap_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_classe_capacite (
  cc_id        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cc_cla_id    INT UNSIGNED NOT NULL COMMENT '-> dd_classes',
  cc_cap_id    INT UNSIGNED NOT NULL COMMENT '-> dd_capacites_speciales',
  cc_niveau    TINYINT UNSIGNED NOT NULL,
  cc_precision VARCHAR(255)         DEFAULT NULL,
  PRIMARY KEY (cc_id),
  UNIQUE KEY uk_cc (cc_cla_id, cc_cap_id, cc_niveau)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- COMPENDIUM — SORTS
-- ------------------------------------------------------------

CREATE TABLE dd_colleges (
  co_id  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  co_nom VARCHAR(50)  NOT NULL,
  PRIMARY KEY (co_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_sorts (
  so_id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  so_nom            VARCHAR(150) NOT NULL,
  so_co_id          INT UNSIGNED          DEFAULT NULL COMMENT '-> dd_colleges',
  so_description    TEXT                  DEFAULT NULL,
  so_res_id         INT UNSIGNED NOT NULL COMMENT '-> dd_ressources',
  so_camp_id        INT UNSIGNED          DEFAULT NULL COMMENT 'null=global, sinon homebrew -> dd_campagnes',
  so_ruleset_var_id INT UNSIGNED NOT NULL COMMENT '-> dd_variables',
  PRIMARY KEY (so_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_sortclasse (
  sc_id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  sc_so_id   INT UNSIGNED NOT NULL COMMENT '-> dd_sorts',
  sc_cla_id  INT UNSIGNED NOT NULL COMMENT '-> dd_classes',
  sc_niveau  TINYINT UNSIGNED NOT NULL COMMENT 'Niveau du sort pour cette classe (0-9)',
  PRIMARY KEY (sc_id),
  UNIQUE KEY uk_sc (sc_so_id, sc_cla_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- COMPENDIUM — DONS
-- ------------------------------------------------------------

CREATE TABLE dd_data_don (
  dado_id  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  dado_nom VARCHAR(80)  NOT NULL,
  PRIMARY KEY (dado_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_dons (
  do_id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  do_nom            VARCHAR(150) NOT NULL,
  do_dado_id        INT UNSIGNED          DEFAULT NULL COMMENT '-> dd_data_don',
  do_conditions     TEXT                  DEFAULT NULL COMMENT 'DD3.5 uniquement',
  do_texte          TEXT                  DEFAULT NULL,
  do_resume         TEXT                  DEFAULT NULL,
  do_res_id         INT UNSIGNED NOT NULL COMMENT '-> dd_ressources',
  do_camp_id        INT UNSIGNED          DEFAULT NULL COMMENT 'null=global, sinon homebrew -> dd_campagnes',
  do_ruleset_var_id INT UNSIGNED NOT NULL COMMENT '-> dd_variables',
  PRIMARY KEY (do_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- PERSONNAGES
-- ------------------------------------------------------------

CREATE TABLE dd_personnages (
  pe_id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pe_nom            VARCHAR(100) NOT NULL,
  pe_j_id           INT UNSIGNED NOT NULL COMMENT '-> dd_joueurs (propriétaire)',
  pe_ra_id          INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '-> dd_races (race de base)',
  pe_arc_id         INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'DD3.5: -> dd_races (archétype), 0=aucun',
  -- Caractéristiques
  pe_for            TINYINT UNSIGNED NOT NULL DEFAULT 10,
  pe_con            TINYINT UNSIGNED NOT NULL DEFAULT 10,
  pe_dex            TINYINT UNSIGNED NOT NULL DEFAULT 10,
  pe_int            TINYINT UNSIGNED NOT NULL DEFAULT 10,
  pe_sag            TINYINT UNSIGNED NOT NULL DEFAULT 10,
  pe_cha            TINYINT UNSIGNED NOT NULL DEFAULT 10,
  -- Stats dérivées
  pe_ca             SMALLINT         NOT NULL DEFAULT 10,
  pe_pv             SMALLINT         NOT NULL DEFAULT 0,
  -- Textes
  pe_background     TEXT                      DEFAULT NULL,
  pe_notes          TEXT                      DEFAULT NULL COMMENT 'Notes visibles par le propriétaire',
  -- Contexte
  pe_ruleset_var_id INT UNSIGNED NOT NULL COMMENT '-> dd_variables',
  pe_date_creation  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  pe_date_modif     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (pe_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_personnages_classes (
  pc_id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pc_pe_id    INT UNSIGNED NOT NULL COMMENT '-> dd_personnages',
  pc_cla_id   INT UNSIGNED NOT NULL COMMENT '-> dd_classes',
  pc_niveau   TINYINT UNSIGNED NOT NULL DEFAULT 1,
  pc_do_id_1  INT UNSIGNED DEFAULT NULL COMMENT 'Domaine divin 1 (si applicable)',
  pc_do_id_2  INT UNSIGNED DEFAULT NULL COMMENT 'Domaine divin 2 (si applicable)',
  PRIMARY KEY (pc_id),
  UNIQUE KEY uk_pc (pc_pe_id, pc_cla_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_personnages_nls (
  penl_id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  penl_pc_id_base    INT UNSIGNED NOT NULL COMMENT '-> dd_personnages_classes (classe de base lanceur)',
  penl_pc_id_prestige INT UNSIGNED NOT NULL COMMENT '-> dd_personnages_classes (classe prestige)',
  penl_niveau        TINYINT UNSIGNED NOT NULL COMMENT 'Niveau dans la classe prestige',
  PRIMARY KEY (penl_id),
  UNIQUE KEY uk_penl (penl_pc_id_base, penl_pc_id_prestige, penl_niveau)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COMMENT 'DD3.5 uniquement — NLS classes de prestige';

CREATE TABLE dd_personnages_sorts (
  pes_id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pes_pc_id   INT UNSIGNED NOT NULL COMMENT '-> dd_personnages_classes',
  pes_so_id   INT UNSIGNED NOT NULL COMMENT '-> dd_sorts',
  pes_compris TINYINT(1)   NOT NULL DEFAULT 0,
  PRIMARY KEY (pes_id),
  UNIQUE KEY uk_pes (pes_pc_id, pes_so_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_personnages_sorts_prepares (
  pesp_id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pesp_pe_id      INT UNSIGNED NOT NULL COMMENT '-> dd_personnages',
  pesp_cla_id     INT UNSIGNED NOT NULL COMMENT '-> dd_classes',
  pesp_so_id      INT UNSIGNED NOT NULL COMMENT '-> dd_sorts',
  pesp_metamagie  VARCHAR(100)          DEFAULT NULL COMMENT 'DD3.5: ids dons métamagie séparés virgule',
  pesp_niveau     TINYINT UNSIGNED      DEFAULT NULL COMMENT 'DD3.5: niveau effectif après métamagie',
  pesp_nb         TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'DD3.5: nb préparés; DD2024: 0/1',
  PRIMARY KEY (pesp_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_competences (
  comp_id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  comp_nom           VARCHAR(100) NOT NULL,
  comp_car_id        INT UNSIGNED NOT NULL COMMENT '-> dd_caracteristiques',
  comp_res_id        INT UNSIGNED NOT NULL COMMENT '-> dd_ressources',
  comp_ruleset_var_id INT UNSIGNED NOT NULL COMMENT '-> dd_variables',
  PRIMARY KEY (comp_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_personnages_competences (
  pec_id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pec_pe_id    INT UNSIGNED NOT NULL COMMENT '-> dd_personnages',
  pec_comp_id  INT UNSIGNED NOT NULL COMMENT '-> dd_competences',
  pec_maitrise TINYINT      NOT NULL DEFAULT 0 COMMENT 'DD3.5: valeur numérique; DD2024: 0=aucun,1=maîtrise,2=expertise',
  PRIMARY KEY (pec_id),
  UNIQUE KEY uk_pec (pec_pe_id, pec_comp_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_personnages_dons (
  ped_id     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  ped_pe_id  INT UNSIGNED NOT NULL COMMENT '-> dd_personnages',
  ped_do_id  INT UNSIGNED NOT NULL COMMENT '-> dd_dons',
  ped_niveau TINYINT UNSIGNED DEFAULT NULL COMMENT 'Niveau auquel le don a été pris',
  PRIMARY KEY (ped_id),
  UNIQUE KEY uk_ped (ped_pe_id, ped_do_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- CAMPAGNES
-- ------------------------------------------------------------

CREATE TABLE dd_campagnes (
  camp_id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  camp_nom            VARCHAR(150) NOT NULL,
  camp_j_id           INT UNSIGNED NOT NULL COMMENT '-> dd_joueurs (MJ/propriétaire)',
  camp_ruleset_var_id INT UNSIGNED NOT NULL COMMENT '-> dd_variables',
  camp_resume         TEXT                  DEFAULT NULL,
  camp_description    TEXT                  DEFAULT NULL,
  camp_date_creation  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (camp_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Lien personnage <-> campagne + notes MJ
CREATE TABLE dd_campagnes_personnages (
  cp_id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cp_camp_id  INT UNSIGNED NOT NULL COMMENT '-> dd_campagnes',
  cp_pe_id    INT UNSIGNED NOT NULL COMMENT '-> dd_personnages',
  cp_notes_mj TEXT                  DEFAULT NULL COMMENT 'Visible MJ uniquement',
  cp_actif    TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (cp_id),
  UNIQUE KEY uk_cp (cp_camp_id, cp_pe_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Sélection de sources propre à une campagne
CREATE TABLE dd_campagnes_sources (
  cs_id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cs_camp_id INT UNSIGNED NOT NULL COMMENT '-> dd_campagnes',
  cs_res_id  INT UNSIGNED NOT NULL COMMENT '-> dd_ressources',
  PRIMARY KEY (cs_id),
  UNIQUE KEY uk_cs (cs_camp_id, cs_res_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_scenarios (
  sce_id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  sce_nom            VARCHAR(150) NOT NULL,
  sce_ordre          SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  sce_description    TEXT                       DEFAULT NULL,
  sce_camp_id        INT UNSIGNED NOT NULL COMMENT '-> dd_campagnes',
  sce_ruleset_var_id INT UNSIGNED NOT NULL COMMENT '-> dd_variables',
  PRIMARY KEY (sce_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_scenarios_chapitres (
  scc_id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  scc_sce_id      INT UNSIGNED NOT NULL COMMENT '-> dd_scenarios',
  scc_nom         VARCHAR(150) NOT NULL,
  scc_ordre       SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  scc_abreviation VARCHAR(10)           DEFAULT NULL,
  scc_description TEXT                  DEFAULT NULL,
  PRIMARY KEY (scc_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_rencontres (
  re_id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  re_nom         VARCHAR(150) NOT NULL,
  re_code        VARCHAR(20)           DEFAULT NULL,
  re_scc_id      INT UNSIGNED          DEFAULT NULL COMMENT '-> dd_scenarios_chapitres (null=orpheline)',
  re_description TEXT                  DEFAULT NULL,
  PRIMARY KEY (re_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_monstres (
  mo_id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  mo_nom            VARCHAR(150) NOT NULL,
  mo_stats          TEXT                  DEFAULT NULL,
  mo_fp_id          VARCHAR(10)           DEFAULT NULL COMMENT 'Facteur de puissance (alphanum)',
  mo_j_id           INT UNSIGNED          DEFAULT NULL COMMENT '-> dd_joueurs (null=visible tous)',
  mo_ruleset_var_id INT UNSIGNED NOT NULL COMMENT '-> dd_variables',
  PRIMARY KEY (mo_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_rencontres_monstres (
  rem_id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  rem_re_id   INT UNSIGNED NOT NULL COMMENT '-> dd_rencontres',
  rem_mo_id   INT UNSIGNED NOT NULL COMMENT '-> dd_monstres',
  rem_effectif SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (rem_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- WIKI / UNIVERS
-- ------------------------------------------------------------

CREATE TABLE dd_univers (
  un_id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  un_nom           VARCHAR(150) NOT NULL,
  un_j_id          INT UNSIGNED NOT NULL COMMENT '-> dd_joueurs (propriétaire)',
  un_description   TEXT                  DEFAULT NULL,
  un_public        TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '1=sélectionnable par autres MJs',
  un_date_creation DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (un_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Délégation de droits d'édition sur un univers (v1: global sur l'univers)
CREATE TABLE dd_univers_droits (
  ud_id    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  ud_un_id INT UNSIGNED NOT NULL COMMENT '-> dd_univers',
  ud_j_id  INT UNSIGNED NOT NULL COMMENT '-> dd_joueurs (délégataire)',
  PRIMARY KEY (ud_id),
  UNIQUE KEY uk_ud (ud_un_id, ud_j_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_univers_categories (
  uca_id    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  uca_un_id INT UNSIGNED NOT NULL COMMENT '-> dd_univers',
  uca_nom   VARCHAR(100) NOT NULL,
  uca_ordre TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (uca_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_univers_articles (
  ua_id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  ua_uca_id  INT UNSIGNED NOT NULL COMMENT '-> dd_univers_categories',
  ua_un_id   INT UNSIGNED NOT NULL COMMENT '-> dd_univers',
  ua_titre   VARCHAR(200) NOT NULL,
  ua_contenu LONGTEXT              DEFAULT NULL,
  ua_visible TINYINT(1)   NOT NULL DEFAULT 1 COMMENT '0=MJ seul, 1=tous les ayants droit',
  ua_date_creation DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ua_date_modif    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (ua_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Sélection d'un univers public par une campagne
CREATE TABLE dd_campagnes_univers (
  cu_id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cu_camp_id INT UNSIGNED NOT NULL COMMENT '-> dd_campagnes',
  cu_un_id   INT UNSIGNED NOT NULL COMMENT '-> dd_univers',
  PRIMARY KEY (cu_id),
  UNIQUE KEY uk_cu (cu_camp_id, cu_un_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- NOTES DE JEU
-- ------------------------------------------------------------

CREATE TABLE dd_notes (
  no_id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  no_nom      VARCHAR(200) NOT NULL,
  no_tyno_id  INT UNSIGNED          DEFAULT NULL COMMENT '-> dd_types_notes',
  no_date     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  no_j_id     INT UNSIGNED NOT NULL COMMENT '-> dd_joueurs (rédacteur)',
  PRIMARY KEY (no_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_types_notes (
  tyno_id  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tyno_nom VARCHAR(80)  NOT NULL,
  PRIMARY KEY (tyno_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_notes_contenus (
  noc_id    INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  noc_no_id INT UNSIGNED     NOT NULL COMMENT '-> dd_notes',
  noc_dd    TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Degré de difficulté d'accès',
  noc_texte LONGTEXT                  DEFAULT NULL,
  PRIMARY KEY (noc_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_personnages_notes (
  pno_id    INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  pno_pe_id INT UNSIGNED     NOT NULL COMMENT '-> dd_personnages',
  pno_no_id INT UNSIGNED     NOT NULL COMMENT '-> dd_notes',
  pno_dd    TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Niveau de connaissance du personnage',
  pno_actif TINYINT(1)       NOT NULL DEFAULT 1,
  PRIMARY KEY (pno_id),
  UNIQUE KEY uk_pno (pno_pe_id, pno_no_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_campagnes_notes (
  cpno_id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cpno_no_id   INT UNSIGNED NOT NULL COMMENT '-> dd_notes',
  cpno_camp_id INT UNSIGNED NOT NULL COMMENT '-> dd_campagnes',
  PRIMARY KEY (cpno_id),
  UNIQUE KEY uk_cpno (cpno_no_id, cpno_camp_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_tags (
  tag_id   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tag_nom  VARCHAR(80)  NOT NULL,
  tag_slug VARCHAR(100) NOT NULL,
  tag_j_id INT UNSIGNED NOT NULL COMMENT '-> dd_joueurs',
  tag_date DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (tag_id),
  UNIQUE KEY uk_tag_slug (tag_slug, tag_j_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dd_notes_tags (
  notag_id     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  notag_no_id  INT UNSIGNED NOT NULL COMMENT '-> dd_notes',
  notag_tag_id INT UNSIGNED NOT NULL COMMENT '-> dd_tags',
  PRIMARY KEY (notag_id),
  UNIQUE KEY uk_notag (notag_no_id, notag_tag_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET foreign_key_checks = 1;
