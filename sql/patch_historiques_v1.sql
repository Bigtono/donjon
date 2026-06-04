-- Patch compendium : historiques DD2024
-- Cree la table attendue par compendium/enregistrement.php.

CREATE TABLE IF NOT EXISTS dd_historiques (
  hi_id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  hi_nom            VARCHAR(150) NOT NULL,
  hi_description    TEXT         NOT NULL,
  hi_res_id         INT UNSIGNED NOT NULL COMMENT 'Source -> dd_ressources',
  hi_camp_id        INT UNSIGNED          DEFAULT NULL COMMENT 'null = global ; sinon homebrew -> dd_campagnes',
  hi_ruleset_var_id INT UNSIGNED NOT NULL COMMENT '-> dd_variables',
  PRIMARY KEY (hi_id),
  KEY idx_hi_res_id (hi_res_id),
  KEY idx_hi_camp_id (hi_camp_id),
  KEY idx_hi_ruleset_var_id (hi_ruleset_var_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE dd_historiques
  MODIFY hi_id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  MODIFY hi_nom            VARCHAR(150) NOT NULL,
  MODIFY hi_description    TEXT         NOT NULL,
  MODIFY hi_res_id         INT UNSIGNED NOT NULL COMMENT 'Source -> dd_ressources',
  MODIFY hi_camp_id        INT UNSIGNED          DEFAULT NULL COMMENT 'null = global ; sinon homebrew -> dd_campagnes',
  MODIFY hi_ruleset_var_id INT UNSIGNED NOT NULL COMMENT '-> dd_variables';
