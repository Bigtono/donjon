-- sql/2026-10-31_choix_capacites_sp-ch0.sql
-- SP-CH0 — Choix liés aux capacités de classe (fiche de personnage)
--
-- Certaines capacités de classe imposent un choix à chaque niveau (Grand arcane de l'Archimage,
-- Don supplémentaire du Guerrier…). Trois ajouts :
--   - dd_classe_capacite.cc_nb_choix  : nombre de choix accordés à CE niveau (0 = aucun)
--   - dd_capacites_speciales.cap_choix_mode / cap_choix_dado_id : nature du choix ('texte' ou 'don')
--     et, en mode 'don', catégorie de don proposée (NULL = toutes)
--   - dd_personnages_choix : le choix du joueur, une ligne par emplacement
-- et dd_personnages_dons.ped_pech_id, qui marque un don posé par un emplacement de choix.
--
-- dd_personnages_choix est indexée par clé NATURELLE (personnage, classe, capacité, niveau, rang) et
-- non par cc_id : l'enregistrement d'une classe dans le compendium supprime puis réinsère toutes ses
-- lignes dd_classe_capacite, ce qui changerait les cc_id.
--
-- Amorçage par noms (ids différents entre local et production) : Grand arcane (Archimage, texte) et
-- Don supplémentaire (Guerrier, don). Les autres capacités se déclarent depuis le formulaire de classe.
-- Pas de DELIMITER.

SET NAMES utf8mb4;

ALTER TABLE dd_classe_capacite
  ADD COLUMN cc_nb_choix TINYINT UNSIGNED NOT NULL DEFAULT 0
    COMMENT 'Nombre de choix accordés à ce niveau (SP-CH)' AFTER cc_precision;

ALTER TABLE dd_capacites_speciales
  ADD COLUMN cap_choix_mode VARCHAR(10) NOT NULL DEFAULT ''
    COMMENT 'Nature du choix : vide = aucun, texte, don (SP-CH)',
  ADD COLUMN cap_choix_dado_id INT UNSIGNED NULL
    COMMENT '-> dd_data_don : catégorie de don proposée en mode don (NULL = toutes)';

CREATE TABLE IF NOT EXISTS dd_personnages_choix (
  pech_id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pech_pe_id   INT UNSIGNED NOT NULL COMMENT '-> dd_personnages',
  pech_cla_id  INT UNSIGNED NOT NULL COMMENT '-> dd_classes',
  pech_cap_id  INT UNSIGNED NOT NULL COMMENT '-> dd_capacites_speciales',
  pech_niveau  TINYINT UNSIGNED NOT NULL COMMENT 'Niveau de classe qui accorde le choix',
  pech_rang    TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Rang du choix parmi ceux de ce niveau',
  pech_do_id   INT UNSIGNED NULL COMMENT '-> dd_dons (mode don)',
  pech_texte   VARCHAR(255) NULL COMMENT 'Choix saisi (mode texte)',
  PRIMARY KEY (pech_id),
  UNIQUE KEY uk_pech (pech_pe_id, pech_cla_id, pech_cap_id, pech_niveau, pech_rang)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE dd_personnages_dons
  ADD COLUMN ped_pech_id INT UNSIGNED NULL
    COMMENT '-> dd_personnages_choix : don posé par un emplacement de choix (SP-CH)';

-- Grand arcane (Archimage) : un choix par niveau, en texte libre.
UPDATE dd_capacites_speciales
   SET cap_choix_mode = 'texte'
 WHERE cap_nom = 'Grand arcane';

UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla             ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE cap.cap_nom = 'Grand arcane'
   AND cla.cla_nom LIKE 'Archimage%';

-- Don supplémentaire (Guerrier DD3.5) : un don à chaque niveau où la capacité est affectée.
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla        ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'don'
 WHERE cap.cap_nom = 'Don supplémentaire'
   AND cla.cla_nom = 'Guerrier'
   AND cla.cla_ruleset_var_id = (SELECT var_id FROM dd_variables WHERE var_cat = 'ruleset' AND var_valeur = 'DD3.5' LIMIT 1);

UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla             ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE cap.cap_nom = 'Don supplémentaire'
   AND cla.cla_nom = 'Guerrier'
   AND cla.cla_ruleset_var_id = (SELECT var_id FROM dd_variables WHERE var_cat = 'ruleset' AND var_valeur = 'DD3.5' LIMIT 1);
