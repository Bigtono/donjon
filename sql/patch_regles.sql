-- ============================================================
-- patch_regles.sql — Module Règles (wiki de règles récursif)
-- Codex DD v2 — création de la table dd_regles
-- ------------------------------------------------------------
-- Préfixe        : reg
-- Récursivité    : reg_reg_id (NULL = racine)
-- Scoping        : reg_ruleset_var_id -> dd_variables (pas de filtre sources)
-- Distinction    : reg_type ('chapitre' | 'regle' | 'glossaire')
-- Recherche      : index FULLTEXT (reg_nom, reg_texte)
-- Réf. archi.    : doc/ARCHITECTURE_0_REFERENCE.md §9b + DECISIONS_LOG.md
-- ============================================================

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS dd_regles (
  reg_id              INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  reg_reg_id          INT UNSIGNED      NULL
                      COMMENT 'Parent récursif -> dd_regles ; NULL = racine',
  reg_type            ENUM('chapitre','regle','glossaire') NOT NULL DEFAULT 'regle'
                      COMMENT 'Indice d''affichage/sémantique ; glossaire = terme DD2024 (cible de renvoi)',
  reg_nom             VARCHAR(200)      NOT NULL,
  reg_slug            VARCHAR(220)      NOT NULL
                      COMMENT 'Version URL-safe — liens profonds stables',
  reg_texte           LONGTEXT          NULL
                      COMMENT 'Contenu HTML (TinyMCE) — intro pour un chapitre, corps pour une règle/un terme',
  reg_ordre           SMALLINT UNSIGNED NOT NULL DEFAULT 0
                      COMMENT 'Ordre parmi les frères (drag & drop)',
  reg_ruleset_var_id  INT UNSIGNED      NOT NULL
                      COMMENT '-> dd_variables',
  reg_res_id          INT UNSIGNED      NULL
                      COMMENT 'Ressource d''origine -> dd_ressources (attribution, ex : SRD 5.2.1)',
  reg_camp_id         INT UNSIGNED      NULL
                      COMMENT 'RÉSERVÉ house rules -> dd_campagnes ; NULL = règle officielle',
  reg_visible         TINYINT(1)        NOT NULL DEFAULT 1
                      COMMENT '0 = brouillon/masqué (éditeurs seulement)',
  reg_date_creation   DATETIME          NOT NULL,
  reg_date_modif      DATETIME          NOT NULL,
  PRIMARY KEY (reg_id),
  UNIQUE KEY uk_reg_slug_ruleset (reg_slug, reg_ruleset_var_id),
  KEY idx_reg_parent_ordre (reg_reg_id, reg_ordre),
  KEY idx_reg_ruleset (reg_ruleset_var_id),
  KEY idx_reg_type (reg_type),
  FULLTEXT KEY ft_reg_nom_texte (reg_nom, reg_texte),
  CONSTRAINT fk_reg_parent  FOREIGN KEY (reg_reg_id)        REFERENCES dd_regles    (reg_id) ON DELETE RESTRICT,
  CONSTRAINT fk_reg_ruleset FOREIGN KEY (reg_ruleset_var_id) REFERENCES dd_variables (var_id),
  CONSTRAINT fk_reg_res     FOREIGN KEY (reg_res_id)        REFERENCES dd_ressources (res_id) ON DELETE SET NULL,
  CONSTRAINT fk_reg_camp    FOREIGN KEY (reg_camp_id)       REFERENCES dd_campagnes  (camp_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
