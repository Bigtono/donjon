-- sql/2026-11-06_sp-po6b_proprietes_speciales.sql
-- SP-PO6 — Propriétés spéciales DD3.5 exploitables par le compositeur (D-PO19)
--
-- Les propriétés spéciales restent des objets de dd_objets_magiques (catégories
-- proprietes-speciales-des-armes / -des-armures, D-PO4). Trois colonnes s'ajoutent :
--   om_bonus_equiv : équivalence en bonus (+1 à +5), ajoutée au bonus d'altération pour le prix ;
--                    NULL quand la propriété a un prix fixe (om_prix, en po).
--   om_nls         : NLS de la propriété (le NLS d'un objet composé est le plus élevé de ses éléments).
--   om_restriction : jetons séparés par des espaces ; NULL = aucune restriction.
--                    emploi  : cac, distance, jet (armes) ; armure, bouclier, ecu (écu ou rondache) ;
--                    dégâts  : tranchant, perforant, contondant (au moins un des types de l'arme).
--                    Si des jetons d'emploi sont présents, l'objet de base doit satisfaire l'un d'eux.
-- Valeurs : tables et fiches des DRS 24 et 25 (Guide du maître) ; pour les autres sources, le
-- « Prix » et le « NLS » de la description. Tueuse : +1 (tables du DRS 24 ; la fiche dit +2).
--
-- Corrections de données :
--   - om_ajustement_prix des propriétés remis à 0 (valeur d'import sans signification : 5 sur 42
--     propriétés d'armure) ; plus aucune lecture de cette colonne pour les propriétés.
--   - noms en minuscule capitalisés ; « graisseuse supérieur » -> « Graisseuse supérieure ».
--   - « défense » devient « Défense légère » + « Défense intermédiaire » / « Défense lourde » créées ;
--     « résistance à la magie » devient « Résistance à la magie (13) » + (15), (17), (19) créées.
--   - doublon « Sombre » (même description) : la ligne la plus récente est supprimée.
-- Pas de DELIMITER.

SET NAMES utf8mb4;

ALTER TABLE dd_objets_magiques
  ADD COLUMN om_bonus_equiv TINYINT UNSIGNED NULL
    COMMENT 'Propriété spéciale DD3.5 : équivalence en bonus (+1 à +5) ; NULL = prix fixe (om_prix) — SP-PO6'
    AFTER om_ajustement_prix,
  ADD COLUMN om_nls TINYINT UNSIGNED NULL
    COMMENT 'Propriété spéciale DD3.5 : NLS — SP-PO6'
    AFTER om_bonus_equiv,
  ADD COLUMN om_restriction VARCHAR(60) NULL
    COMMENT 'Propriété spéciale DD3.5 : jetons cac/distance/jet/armure/bouclier/ecu/tranchant/perforant/contondant — SP-PO6'
    AFTER om_nls;

-- Noms ---------------------------------------------------------------------------------------------

UPDATE dd_objets_magiques om
JOIN dd_categorie_objet_magique com ON com.com_id = om.om_com_id
SET om.om_nom = CONCAT(UPPER(LEFT(om.om_nom, 1)), SUBSTRING(om.om_nom, 2)),
    om.om_ajustement_prix = 0
WHERE com.com_ruleset_var_id = 1
  AND com.com_slug IN ('proprietes-speciales-des-armes', 'proprietes-speciales-des-armures');

UPDATE dd_objets_magiques om
JOIN dd_categorie_objet_magique com ON com.com_id = om.om_com_id
SET om.om_nom = 'Graisseuse supérieure'
WHERE com.com_ruleset_var_id = 1 AND com.com_slug = 'proprietes-speciales-des-armures'
  AND om.om_nom = 'Graisseuse supérieur';

UPDATE dd_objets_magiques om
JOIN dd_categorie_objet_magique com ON com.com_id = om.om_com_id
SET om.om_nom = 'Défense légère'
WHERE com.com_ruleset_var_id = 1 AND com.com_slug = 'proprietes-speciales-des-armures'
  AND om.om_nom = 'Défense';

UPDATE dd_objets_magiques om
JOIN dd_categorie_objet_magique com ON com.com_id = om.om_com_id
SET om.om_nom = 'Résistance à la magie (13)'
WHERE com.com_ruleset_var_id = 1 AND com.com_slug = 'proprietes-speciales-des-armures'
  AND om.om_nom = 'Résistance à la magie';

-- Doublon « Sombre » ------------------------------------------------------------------------------

DELETE o2
FROM dd_objets_magiques o2
JOIN dd_objets_magiques o1
  ON o1.om_nom = o2.om_nom AND o1.om_com_id = o2.om_com_id AND o1.om_id < o2.om_id
JOIN dd_categorie_objet_magique com ON com.com_id = o2.om_com_id
WHERE com.com_ruleset_var_id = 1 AND com.com_slug = 'proprietes-speciales-des-armures'
  AND o2.om_nom = 'Sombre';

-- Déclinaisons créées (copie de la ligne de base : description, source, visibilité) ---------------

INSERT INTO dd_objets_magiques
  (om_nom, om_com_id, om_fom_id, om_so_id, om_so_niveau, om_modificateurs, om_variantes, om_prix,
   om_ajustement_prix, om_description, om_harmonisation, om_rarete, om_visible, om_public,
   om_res_id, om_camp_id, om_ruleset_var_id)
SELECT d.nom, om.om_com_id, om.om_fom_id, NULL, 0, 0, NULL, NULL,
       0, om.om_description, 0, om.om_rarete, om.om_visible, om.om_public,
       om.om_res_id, om.om_camp_id, om.om_ruleset_var_id
FROM dd_objets_magiques om
JOIN dd_categorie_objet_magique com ON com.com_id = om.om_com_id
JOIN (
  SELECT 'Défense légère' AS base, 'Défense intermédiaire' AS nom
  UNION ALL SELECT 'Défense légère', 'Défense lourde'
  UNION ALL SELECT 'Résistance à la magie (13)', 'Résistance à la magie (15)'
  UNION ALL SELECT 'Résistance à la magie (13)', 'Résistance à la magie (17)'
  UNION ALL SELECT 'Résistance à la magie (13)', 'Résistance à la magie (19)'
) d ON d.base = om.om_nom
WHERE com.com_ruleset_var_id = 1 AND com.com_slug = 'proprietes-speciales-des-armures';

-- Valeurs -----------------------------------------------------------------------------------------

CREATE TEMPORARY TABLE tmp_po6_proprietes (
  slug        VARCHAR(60) NOT NULL,
  nom         VARCHAR(150) NOT NULL,
  bonus       TINYINT UNSIGNED NULL,
  prix        INT UNSIGNED NULL,
  nls         TINYINT UNSIGNED NULL,
  restriction VARCHAR(60) NULL
) ENGINE=MEMORY DEFAULT CHARSET=utf8mb4;

INSERT INTO tmp_po6_proprietes (slug, nom, bonus, prix, nls, restriction) VALUES
-- Armes — DRS 24
('proprietes-speciales-des-armes', 'Acérée',           1, NULL, 10, 'cac tranchant perforant'),
('proprietes-speciales-des-armes', 'Anarchique',       2, NULL,  7, NULL),
('proprietes-speciales-des-armes', 'Axiomatique',      2, NULL,  7, NULL),
('proprietes-speciales-des-armes', 'Boomerang',        1, NULL,  7, 'jet'),
('proprietes-speciales-des-armes', 'Dansante',         4, NULL, 15, 'cac'),
('proprietes-speciales-des-armes', 'Destruction',      2, NULL, 14, 'cac contondant'),
('proprietes-speciales-des-armes', 'Enchaînement',     1, NULL,  8, 'cac'),
('proprietes-speciales-des-armes', 'Feu',              1, NULL,  8, NULL),
('proprietes-speciales-des-armes', 'Feu intense',      2, NULL, 10, NULL),
('proprietes-speciales-des-armes', 'Focalisation ki',  1, NULL,  8, 'cac'),
('proprietes-speciales-des-armes', 'Foudre',           1, NULL,  8, NULL),
('proprietes-speciales-des-armes', 'Foudre intense',   2, NULL, 10, NULL),
('proprietes-speciales-des-armes', 'Froid',            1, NULL,  8, NULL),
('proprietes-speciales-des-armes', 'Froid intense',    2, NULL, 10, NULL),
('proprietes-speciales-des-armes', 'Gardienne',        1, NULL,  8, 'cac'),
('proprietes-speciales-des-armes', 'Impie',            2, NULL,  7, NULL),
('proprietes-speciales-des-armes', 'Lancer',           1, NULL,  5, 'cac'),
('proprietes-speciales-des-armes', 'Longue portée',    1, NULL,  6, 'distance'),
('proprietes-speciales-des-armes', 'Lumière',          4, NULL, 16, NULL),
('proprietes-speciales-des-armes', 'Miséricordieuse',  1, NULL,  5, NULL),
('proprietes-speciales-des-armes', 'Rapidité',         3, NULL,  7, NULL),
('proprietes-speciales-des-armes', 'Sainte',           2, NULL,  7, NULL),
('proprietes-speciales-des-armes', 'Sanglante',        2, NULL, 10, 'cac'),
('proprietes-speciales-des-armes', 'Spectrale',        1, NULL,  9, 'cac'),
('proprietes-speciales-des-armes', 'Stockage de sort', 1, NULL, 12, 'cac'),
('proprietes-speciales-des-armes', 'Tonnerre',         1, NULL,  5, NULL),
('proprietes-speciales-des-armes', 'Traqueuse',        1, NULL,  7, 'distance'),
('proprietes-speciales-des-armes', 'Tueuse',           1, NULL,  8, NULL),
('proprietes-speciales-des-armes', 'Vicieuse',         1, NULL,  9, 'cac'),
('proprietes-speciales-des-armes', 'Vorpale',          5, NULL, 18, 'cac tranchant'),
-- Armes — autres sources (prix et NLS de la description)
('proprietes-speciales-des-armes', 'Alerte',              1, NULL,   7, NULL),
('proprietes-speciales-des-armes', 'Aura élémentaire',    3, NULL,  15, NULL),
('proprietes-speciales-des-armes', 'Bannissement',        3, NULL,  13, NULL),
('proprietes-speciales-des-armes', 'Bénie',               1, NULL,   5, NULL),
('proprietes-speciales-des-armes', 'Destin',           NULL, 38500, 13, NULL),
('proprietes-speciales-des-armes', 'Dissipation',      NULL, 6000,   5, NULL),
('proprietes-speciales-des-armes', 'Dissipation suprême', NULL, 79200, 11, NULL),
('proprietes-speciales-des-armes', 'Dominatrice',         2, NULL,  11, NULL),
('proprietes-speciales-des-armes', 'Drow',                1, NULL,  12, NULL),
('proprietes-speciales-des-armes', 'Lumière céleste',     2, NULL,   5, NULL),
-- Armures et boucliers — DRS 25
('proprietes-speciales-des-armures', 'Animé',                       2, NULL, 12, 'bouclier'),
('proprietes-speciales-des-armures', 'Antiprojectiles',             2, NULL,  5, 'bouclier'),
('proprietes-speciales-des-armures', 'Attaque',                     1, NULL,  8, 'ecu'),
('proprietes-speciales-des-armures', 'Aveuglant',                   1, NULL,  7, 'bouclier'),
('proprietes-speciales-des-armures', 'Contrôle des morts-vivants', NULL, 49000, 13, NULL),
('proprietes-speciales-des-armures', 'Défense légère',              1, NULL, 13, NULL),
('proprietes-speciales-des-armures', 'Défense intermédiaire',       3, NULL, 13, NULL),
('proprietes-speciales-des-armures', 'Défense lourde',              5, NULL, 13, NULL),
('proprietes-speciales-des-armures', 'Déplacement furtif',          NULL,  3750,  5, 'armure'),
('proprietes-speciales-des-armures', 'Déplacement furtif supérieur', NULL, 15000, 10, 'armure'),
('proprietes-speciales-des-armures', 'Déplacement furtif suprême',  NULL, 33750, 15, 'armure'),
('proprietes-speciales-des-armures', 'Éthérée',                     NULL, 49000, 13, 'armure'),
('proprietes-speciales-des-armures', 'Forme animale',               3, NULL,  9, NULL),
('proprietes-speciales-des-armures', 'Graisseuse',                  NULL,  3750,  4, 'armure'),
('proprietes-speciales-des-armures', 'Graisseuse supérieure',       NULL, 15000, 10, 'armure'),
('proprietes-speciales-des-armures', 'Graisseuse suprême',          NULL, 33750, 15, 'armure'),
('proprietes-speciales-des-armures', 'Interception de projectiles', 1, NULL,  8, 'bouclier'),
('proprietes-speciales-des-armures', 'Invulnérabilité',             3, NULL, 18, 'armure'),
('proprietes-speciales-des-armures', 'Mimétisme',                   NULL,  2700, 10, 'armure'),
('proprietes-speciales-des-armures', 'Ombre',                       NULL,  3750,  5, 'armure'),
('proprietes-speciales-des-armures', 'Ombre supérieure',            NULL, 15000, 10, 'armure'),
('proprietes-speciales-des-armures', 'Ombre suprême',               NULL, 33750, 15, 'armure'),
('proprietes-speciales-des-armures', 'Réfléchissant',               5, NULL, 14, 'bouclier'),
('proprietes-speciales-des-armures', 'Résistance à l''acide',                   NULL, 18000,  3, NULL),
('proprietes-speciales-des-armures', 'Résistance à l''acide supérieure',        NULL, 42000,  7, NULL),
('proprietes-speciales-des-armures', 'Résistance à l''acide suprême',           NULL, 66000, 11, NULL),
('proprietes-speciales-des-armures', 'Résistance à l''électricité',             NULL, 18000,  3, NULL),
('proprietes-speciales-des-armures', 'Résistance à l''électricité supérieure',  NULL, 42000,  7, NULL),
('proprietes-speciales-des-armures', 'Résistance à l''électricité suprême',     NULL, 66000, 11, NULL),
('proprietes-speciales-des-armures', 'Résistance au feu',                       NULL, 18000,  3, NULL),
('proprietes-speciales-des-armures', 'Résistance au feu supérieure',            NULL, 42000,  7, NULL),
('proprietes-speciales-des-armures', 'Résistance au feu suprême',               NULL, 66000, 11, NULL),
('proprietes-speciales-des-armures', 'Résistance au froid',                     NULL, 18000,  3, NULL),
('proprietes-speciales-des-armures', 'Résistance au froid supérieure',          NULL, 42000,  7, NULL),
('proprietes-speciales-des-armures', 'Résistance au froid suprême',             NULL, 66000, 11, NULL),
('proprietes-speciales-des-armures', 'Résistance au son',                       NULL, 18000,  3, NULL),
('proprietes-speciales-des-armures', 'Résistance au son supérieure',            NULL, 42000,  7, NULL),
('proprietes-speciales-des-armures', 'Résistance au son suprême',               NULL, 66000, 11, NULL),
('proprietes-speciales-des-armures', 'Résistance à la magie (13)',  2, NULL, 15, NULL),
('proprietes-speciales-des-armures', 'Résistance à la magie (15)',  3, NULL, 15, NULL),
('proprietes-speciales-des-armures', 'Résistance à la magie (17)',  4, NULL, 15, NULL),
('proprietes-speciales-des-armures', 'Résistance à la magie (19)',  5, NULL, 15, NULL),
('proprietes-speciales-des-armures', 'Spectrale',                   3, NULL, 15, NULL),
-- Armures et boucliers — autres sources
('proprietes-speciales-des-armures', 'Crépusculaire',         1, NULL,  5, NULL),
('proprietes-speciales-des-armures', 'Exaltée',               3, NULL,  9, NULL),
('proprietes-speciales-des-armures', 'Liberté',               NULL, 60000, 7, 'armure'),
('proprietes-speciales-des-armures', 'Pointes empoisonnées',  1, NULL,  7, 'armure'),
('proprietes-speciales-des-armures', 'Protection des damnés', 1, NULL,  7, 'armure'),
('proprietes-speciales-des-armures', 'Refroidissante',        NULL,  1500, 3, 'armure'),
('proprietes-speciales-des-armures', 'Sacrée',                2, NULL,  8, NULL),
('proprietes-speciales-des-armures', 'Sanctuaire',            1, NULL, 10, NULL),
('proprietes-speciales-des-armures', 'Santé',                 NULL, 11250, 5, NULL),
('proprietes-speciales-des-armures', 'Sombre',                NULL,  8000, 8, NULL),
('proprietes-speciales-des-armures', 'Souplesse',             1, NULL,  8, 'armure');

UPDATE dd_objets_magiques om
JOIN dd_categorie_objet_magique com ON com.com_id = om.om_com_id AND com.com_ruleset_var_id = 1
JOIN tmp_po6_proprietes t
  ON t.slug COLLATE utf8mb4_unicode_ci = com.com_slug
 AND t.nom  COLLATE utf8mb4_unicode_ci = om.om_nom
SET om.om_bonus_equiv = t.bonus,
    om.om_prix        = t.prix,
    om.om_nls         = t.nls,
    om.om_restriction = t.restriction;

DROP TEMPORARY TABLE tmp_po6_proprietes;
