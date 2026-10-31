-- sql/2026-11-01_sp-no0_notes.sql
-- SP-NO0 — Module Notes : refonte du schéma
--
-- Les tables de notes héritées du schéma initial (dd_notes, dd_notes_contenus, dd_types_notes,
-- dd_personnages_notes, dd_campagnes_notes) n'ont jamais été utilisées : elles ne portent ni
-- campagne, ni scénario, ni ruleset, ni condition de compétence. Elles sont recréées :
--   - dd_types_notes       : catégories de notes, propres à chaque ruleset
--   - dd_notes             : la note, rattachée à une campagne (ruleset hérité) et à un scénario facultatif ;
--                            no_texte = tronc commun, toujours lisible par les destinataires
--   - dd_notes_contenus    : sections de la note
--   - dd_notes_conditions  : conditions d'accès d'une section (compétence + DD, combinées en OU ;
--                            accès si 10 + bonus total de compétence >= DD) — nouvelle
--   - dd_personnages_notes : destinataires (date de diffusion, date de lecture)
-- dd_campagnes_notes disparaît (la note porte sa campagne). dd_tags / dd_notes_tags sont conservées.
-- Décisions D-NO0 → D-NO4.
--
-- GARDE-FOU : la première instruction échoue (« Subquery returns more than 1 row ») si l'une des
-- tables supprimées contient une ligne. Rien n'est alors modifié ; arbitrage avant de rejouer.
-- Pas de DELIMITER.

SET NAMES utf8mb4;

SELECT (
  SELECT 1 FROM (
    SELECT 1 AS n
    UNION ALL SELECT 1 FROM dd_notes
    UNION ALL SELECT 1 FROM dd_notes_contenus
    UNION ALL SELECT 1 FROM dd_types_notes
    UNION ALL SELECT 1 FROM dd_personnages_notes
    UNION ALL SELECT 1 FROM dd_campagnes_notes
  ) AS lignes
) AS garde_tables_notes_vides;

DROP TABLE IF EXISTS dd_campagnes_notes;
DROP TABLE IF EXISTS dd_personnages_notes;
DROP TABLE IF EXISTS dd_notes_contenus;
DROP TABLE IF EXISTS dd_notes;
DROP TABLE IF EXISTS dd_types_notes;

CREATE TABLE dd_types_notes (
  tyno_id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tyno_nom            VARCHAR(80) NOT NULL,
  tyno_ruleset_var_id INT UNSIGNED NOT NULL COMMENT '-> dd_variables (ruleset)',
  tyno_ordre          SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (tyno_id),
  UNIQUE KEY uk_tyno_nom (tyno_ruleset_var_id, tyno_nom)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE dd_notes (
  no_id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  no_nom           VARCHAR(200) NOT NULL,
  no_camp_id       INT UNSIGNED NOT NULL COMMENT '-> dd_campagnes (le ruleset en est hérité)',
  no_sce_id        INT UNSIGNED NULL COMMENT '-> dd_scenarios ; NULL = toute la campagne',
  no_tyno_id       INT UNSIGNED NOT NULL COMMENT '-> dd_types_notes (catégorie)',
  no_texte         LONGTEXT NULL COMMENT 'Tronc commun, toujours lisible par les destinataires',
  no_j_id          INT UNSIGNED NOT NULL COMMENT 'Rédacteur -> dd_joueurs',
  no_date          DATETIME NOT NULL COMMENT 'Date de la note (tri), modifiable',
  no_date_maj      DATETIME NULL,
  no_supprime      TINYINT(1) NOT NULL DEFAULT 0,
  no_date_supprime DATETIME NULL,
  PRIMARY KEY (no_id),
  KEY idx_no_camp (no_camp_id, no_supprime, no_date),
  KEY idx_no_sce (no_sce_id),
  KEY idx_no_tyno (no_tyno_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE dd_notes_contenus (
  noc_id     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  noc_no_id  INT UNSIGNED NOT NULL COMMENT '-> dd_notes',
  noc_ordre  SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  noc_titre  VARCHAR(200) NULL,
  noc_texte  LONGTEXT NULL,
  PRIMARY KEY (noc_id),
  KEY idx_noc_note (noc_no_id, noc_ordre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE dd_notes_conditions (
  nocd_id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nocd_noc_id  INT UNSIGNED NOT NULL COMMENT '-> dd_notes_contenus',
  nocd_comp_id INT UNSIGNED NOT NULL COMMENT '-> dd_competences',
  nocd_dd      TINYINT UNSIGNED NOT NULL COMMENT 'DD : accès si 10 + bonus total >= DD',
  PRIMARY KEY (nocd_id),
  UNIQUE KEY uk_nocd (nocd_noc_id, nocd_comp_id),
  KEY idx_nocd_comp (nocd_comp_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE dd_personnages_notes (
  pno_id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pno_no_id   INT UNSIGNED NOT NULL COMMENT '-> dd_notes',
  pno_pe_id   INT UNSIGNED NOT NULL COMMENT '-> dd_personnages',
  pno_date    DATETIME NOT NULL COMMENT 'Date de diffusion au personnage',
  pno_lu_date DATETIME NULL COMMENT 'Première lecture par le joueur ; NULL = non lue',
  PRIMARY KEY (pno_id),
  UNIQUE KEY uk_pno (pno_no_id, pno_pe_id),
  KEY idx_pno_pe (pno_pe_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Catégories de départ, identiques pour les deux rulesets (1 = DD3.5, 2 = DD2024), modifiables ensuite (SP-NO6).
INSERT INTO dd_types_notes (tyno_nom, tyno_ruleset_var_id, tyno_ordre) VALUES
  ('Histoire', 1, 10),                   ('Histoire', 2, 10),
  ('Géographie et lieux', 1, 20),        ('Géographie et lieux', 2, 20),
  ('Personnages', 1, 30),                ('Personnages', 2, 30),
  ('Organisations et factions', 1, 40),  ('Organisations et factions', 2, 40),
  ('Religions et divinités', 1, 50),     ('Religions et divinités', 2, 50),
  ('Magie et arcanes', 1, 60),           ('Magie et arcanes', 2, 60),
  ('Créatures', 1, 70),                  ('Créatures', 2, 70),
  ('Objets et artefacts', 1, 80),        ('Objets et artefacts', 2, 80),
  ('Culture et société', 1, 90),         ('Culture et société', 2, 90),
  ('Indices et documents', 1, 100),      ('Indices et documents', 2, 100),
  ('Divers', 1, 110),                    ('Divers', 2, 110);
