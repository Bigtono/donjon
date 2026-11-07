-- sql/2026-11-07_sp-tb8b_ecran_mj.sql
-- SP-TB8b — Écran du MJ : sélection et disposition des tableaux, par campagne (D-TB24)
--
-- dd_campagnes.camp_ecran_colonnes : nombre de colonnes virtuelles choisi par le MJ (2 à 6).
-- dd_campagnes_ecran : un tableau posé sur l'écran d'une campagne.
--   ce_colonne : colonne de départ (0 = la plus à gauche)
--   ce_ordre   : ordre GLOBAL de placement — les tableaux sont posés dans cet ordre, chacun
--                au plus haut des colonnes qu'il couvre (voir ARCHITECTURE §9c)
--   ce_largeur : 1 ou 2 colonnes
--   ce_replie  : tableau réduit à son titre
-- Les campagnes sont supprimées en douceur : la cascade ne joue que sur la suppression
-- physique d'un tableau. Pas de DELIMITER.

SET NAMES utf8mb4;

ALTER TABLE dd_campagnes
  ADD COLUMN camp_ecran_colonnes tinyint(3) UNSIGNED NOT NULL DEFAULT 3
    COMMENT 'Écran du MJ : nombre de colonnes (2 à 6, SP-TB8)'
    AFTER camp_description;

CREATE TABLE IF NOT EXISTS dd_campagnes_ecran (
  ce_id      int(10) UNSIGNED     NOT NULL AUTO_INCREMENT,
  ce_camp_id int(10) UNSIGNED     NOT NULL COMMENT '-> dd_campagnes',
  ce_tab_id  int(10) UNSIGNED     NOT NULL COMMENT '-> dd_tableaux',
  ce_colonne tinyint(3) UNSIGNED  NOT NULL DEFAULT 0 COMMENT 'Colonne de départ, 0 = gauche',
  ce_ordre   smallint(5) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Ordre global de placement',
  ce_largeur tinyint(3) UNSIGNED  NOT NULL DEFAULT 1 COMMENT '1 ou 2 colonnes',
  ce_replie  tinyint(1)           NOT NULL DEFAULT 0 COMMENT '1 = réduit à son titre',
  PRIMARY KEY (ce_id),
  UNIQUE KEY uk_ce_camp_tab (ce_camp_id, ce_tab_id),
  KEY idx_ce_camp_ordre (ce_camp_id, ce_ordre),
  KEY idx_ce_tab (ce_tab_id),
  CONSTRAINT fk_ce_campagne FOREIGN KEY (ce_camp_id)
    REFERENCES dd_campagnes (camp_id) ON DELETE CASCADE,
  CONSTRAINT fk_ce_tableau FOREIGN KEY (ce_tab_id)
    REFERENCES dd_tableaux (tab_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Écran du MJ : tableaux posés sur l''écran d''une campagne (SP-TB8)';
