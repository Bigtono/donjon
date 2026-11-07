-- sql/2026-11-01_sp-pe21_synergies_competences.sql
-- SP-PE21 — Synergies entre compétences (DD3.5)
--
-- Un degré de maîtrise de 5 dans une compétence (source) donne +2 aux tests d'une autre (cible). Une synergie
-- sans condition entre dans le total de la fiche et dans l'accès aux notes ; une synergie conditionnelle
-- (« associés aux parchemins ») est seulement affichée à côté du total. Décisions D-PE21a → D-PE21c.
--
-- Données : table des synergies du Manuel des Joueurs 3.5 et descriptions du compendium. Les synergies dont la
-- cible n'est pas une compétence (empathie sauvage, savoir bardique, renvoi des morts-vivants, Autohypnose
-- absente du compendium) ne sont pas reprises. Les compétences sont retrouvées par leur nom, nettoyé des
-- espaces et tabulations de fin (« Art de la magie », « Utilisation d'objets magiques ») : les ids peuvent
-- différer entre local et production. Rejouable : une synergie déjà présente n'est pas réinsérée.
-- Doit suivre 2026-10-31_sp-cd0_competences_domaines.sql (domaines de Connaissances). Pas de DELIMITER.

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS dd_competences_synergies (
  syn_id             INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  syn_comp_source_id INT UNSIGNED     NOT NULL COMMENT 'Compétence dont les rangs donnent le bonus -> dd_competences',
  syn_comp_cible_id  INT UNSIGNED     NOT NULL COMMENT 'Compétence qui reçoit le bonus -> dd_competences',
  syn_seuil          TINYINT UNSIGNED NOT NULL DEFAULT 5 COMMENT 'Rangs minimum dans la source',
  syn_bonus          TINYINT          NOT NULL DEFAULT 2 COMMENT 'Bonus accordé à la cible',
  syn_condition      VARCHAR(200)     NULL     DEFAULT NULL COMMENT 'NULL = toujours (compté dans le total) ; sinon cas d''application (affiché seulement)',
  PRIMARY KEY (syn_id),
  KEY idx_syn_source (syn_comp_source_id),
  KEY idx_syn_cible (syn_comp_cible_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO dd_competences_synergies (syn_comp_source_id, syn_comp_cible_id, syn_seuil, syn_bonus, syn_condition)
SELECT s.comp_id, c.comp_id, 5, 2, d.cond
  FROM (
              SELECT 'Acrobaties' AS src, 'Équilibre' AS cib, NULL AS cond
    UNION ALL SELECT 'Acrobaties', 'Saut', NULL
    UNION ALL SELECT 'Saut', 'Acrobaties', NULL
    UNION ALL SELECT 'Connaissances (mystères)', 'Art de la magie', NULL
    UNION ALL SELECT 'Art de la magie', 'Utilisation d''objets magiques', 'parchemins'
    UNION ALL SELECT 'Décryptage', 'Utilisation d''objets magiques', 'parchemins'
    UNION ALL SELECT 'Décryptage', 'Art de la magie', 'identifier les pouvoirs d''un cercle runique'
    UNION ALL SELECT 'Utilisation d''objets magiques', 'Art de la magie', 'déchiffrer un sort sur un parchemin'
    UNION ALL SELECT 'Artisanat', 'Estimation', 'objets produits par cet artisanat'
    UNION ALL SELECT 'Représentation', 'Concentration', 'résister au chahut pendant une représentation'
    UNION ALL SELECT 'Dressage', 'Équitation', NULL
    UNION ALL SELECT 'Évasion', 'Maîtrise des cordes', 'ligoter quelqu''un'
    UNION ALL SELECT 'Maîtrise des cordes', 'Évasion', 'se libérer de cordes'
    UNION ALL SELECT 'Maîtrise des cordes', 'Escalade', 'grimper à une corde'
    UNION ALL SELECT 'Bluff', 'Diplomatie', NULL
    UNION ALL SELECT 'Bluff', 'Intimidation', NULL
    UNION ALL SELECT 'Bluff', 'Escamotage', NULL
    UNION ALL SELECT 'Bluff', 'Déguisement', 'jouer un rôle'
    UNION ALL SELECT 'Psychologie', 'Diplomatie', NULL
    UNION ALL SELECT 'Connaissances (noblesse et royauté)', 'Diplomatie', NULL
    UNION ALL SELECT 'Connaissances (folklore local)', 'Renseignements', NULL
    UNION ALL SELECT 'Survie', 'Connaissances (nature)', NULL
    UNION ALL SELECT 'Connaissances (architecture et ingénierie)', 'Fouille', 'portes secrètes et compartiments cachés'
    UNION ALL SELECT 'Connaissances (exploration souterraine)', 'Survie', 'sous terre'
    UNION ALL SELECT 'Connaissances (géographie)', 'Survie', 'ne pas se perdre, éviter les dangers naturels'
    UNION ALL SELECT 'Connaissances (nature)', 'Survie', 'milieu naturel en surface'
    UNION ALL SELECT 'Connaissances (plans)', 'Survie', 'sur un autre plan'
    UNION ALL SELECT 'Fouille', 'Survie', 'suivre une piste'
  ) d
  JOIN dd_competences s
    ON s.comp_ruleset_var_id = 1
   AND TRIM(REPLACE(REPLACE(s.comp_nom, CHAR(9), ''), '’', '''')) = d.src
  JOIN dd_competences c
    ON c.comp_ruleset_var_id = 1
   AND TRIM(REPLACE(REPLACE(c.comp_nom, CHAR(9), ''), '’', '''')) = d.cib
 WHERE NOT EXISTS (
   SELECT 1 FROM dd_competences_synergies x
    WHERE x.syn_comp_source_id = s.comp_id
      AND x.syn_comp_cible_id  = c.comp_id
      AND x.syn_condition <=> d.cond
 );
