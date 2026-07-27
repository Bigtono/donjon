-- 2026-07-27_tableaux_sp-tb0.sql
-- SP-TB0 — Table dd_tableaux : isolation des tableaux de données des règles.
--
-- Un tableau est saisi une fois, en convention texte (sans HTML), puis inséré
-- dans le corps d'une règle par le tag [[tab:slug]]. Le HTML est produit au
-- rendu par include/tableau-parser.php ; le design reste géré en CSS.
--
-- Scoping : ruleset uniquement (comme dd_regles) — le moteur compendium-liste.php
-- ne s'applique pas à ce module.
--
-- Référence : doc/ARCHITECTURE_0_REFERENCE.md §9c

START TRANSACTION;

CREATE TABLE IF NOT EXISTS `dd_tableaux` (
  `tab_id`             int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `tab_slug`           varchar(120) NOT NULL COMMENT 'Clé du tag [[tab:slug]] — stable entre environnements',
  `tab_nom`            varchar(200) NOT NULL COMMENT 'Titre affiché au-dessus du tableau',
  `tab_contenu`        text NOT NULL COMMENT 'Convention texte : ! en-tête, # section, > note, | séparateur',
  `tab_align`          varchar(40) DEFAULT NULL COMMENT 'Alignement par colonne, ex. "lrr" ou "l,r,r" (l/c/r)',
  `tab_note`           varchar(500) DEFAULT NULL COMMENT 'Note de bas de tableau (peut aussi venir des lignes >)',
  `tab_ruleset_var_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_variables',
  `tab_res_id`         int(10) UNSIGNED DEFAULT NULL COMMENT 'Ressource d''origine -> dd_ressources (attribution)',
  `tab_camp_id`        int(10) UNSIGNED DEFAULT NULL COMMENT 'RÉSERVÉ house rules -> dd_campagnes, NULL = officiel',
  `tab_ecran_mj`       tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 = retenu pour l''écran du MJ (SP-TB8)',
  `tab_ecran_ordre`    smallint(5) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Ordre d''affichage sur l''écran du MJ',
  `tab_visible`        tinyint(1) NOT NULL DEFAULT 1 COMMENT '0 = brouillon/masqué (éditeurs seulement)',
  `tab_date_creation`  datetime NOT NULL,
  `tab_date_modif`     datetime NOT NULL,
  PRIMARY KEY (`tab_id`),
  UNIQUE KEY `uk_tab_slug_ruleset` (`tab_slug`, `tab_ruleset_var_id`),
  KEY `idx_tab_ruleset` (`tab_ruleset_var_id`),
  KEY `idx_tab_ecran` (`tab_ruleset_var_id`, `tab_ecran_mj`, `tab_ecran_ordre`),
  KEY `idx_tab_res` (`tab_res_id`),
  KEY `idx_tab_camp` (`tab_camp_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

COMMIT;
