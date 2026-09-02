-- sql/2026-09-01_sorts_toujours_prepares_sp-ma4a.sql
-- SP-MA4a — Sorts toujours préparés DD2024.
--
-- Arbitrage Q7, DECISIONS_LOG.md [2026-09-01] D-MAG13. Prérequis de SP-PE7 :
-- sans cette table, le compteur de sorts préparés est FAUX dès qu'un personnage
-- a une sous-classe. Un Paladin 3 du Serment de Dévotion a 4 sorts au plafond,
-- plus châtiment divin, bouclier de la foi et protection contre le mal et le bien
-- qui ne comptent pas — la page afficherait 4 sur 7 lançables, ou 7 sur 4.
--
-- LE SRD FORMULE TOUS CES CAS DE LA MÊME FAÇON, mot pour mot :
--   « Lorsque vous atteignez un niveau de Paladin spécifié dans la table
--     "Sorts du Serment de Dévotion", les sorts qui y figurent sont toujours
--     préparés pour vous. »
-- D'où une table unique, sur le modèle de dd_sortdomaine (domaines DD3.5) :
-- les deux rulesets partagent alors la même mécanique.
--
-- DEUX RÈGLES DE LECTURE, à porter dans SP-PE7 :
--   * CUMULATIF — « pour votre niveau et les niveaux inférieurs ». Un Paladin 9
--     a ceux des niveaux 3, 5 et 9. Filtrer sur cs_niveau <= niveau du personnage.
--   * NON DÉCOMPTÉ — ces sorts ne pèsent pas sur cn_sortPrepare.
--
-- CE QUI N'EST PAS DANS CETTE TABLE :
--   * Les Manifestations occultes de l'Occultiste (« lancer armure du mage sans
--     emplacement ») : déjà importées comme dons par SP-IM5, catégorie 23.
--   * Les sorts toujours préparés mais CHOISIS par le joueur — Secrets magiques
--     du Barde (niv. 10), Sorts de prédilection du Magicien (niv. 20), Arcanum
--     mystique de l'Occultiste (11/13/15/17). Ce sont des choix, pas du
--     référentiel : ils vivent dans dd_personnages_sorts_prepares, d'où la
--     colonne pesp_origine créée en section 3.
--
-- Source : FR_SRD_CC_v5.2.1-classes.pdf. Les 67 noms de sorts ont été résolus
-- en so_id par correspondance normalisée (casse, accents, apostrophes) :
-- 67 résolus, 0 introuvable, 0 ambigu.
--
-- REJEU : les sections 1 et 2 sont rejouables sans effet de bord (CREATE ... IF
-- NOT EXISTS, puis INSERT ... ON DUPLICATE KEY UPDATE sur la clé (cs_cla_id,
-- cs_so_id, cs_variante)). La SECTION 3 NE L'EST PAS — l'ALTER échoue si la
-- colonne existe déjà. Vérifier avant de rejouer :
--   SHOW COLUMNS FROM dd_personnages_sorts_prepares LIKE 'pesp_origine';

-- ------------------------------------------------------------
-- 1. Table dd_classe_sort
--
--    cs_cla_id accepte indifféremment une CLASSE ou une SOUS-CLASSE — une
--    sous-classe étant une classe (cla_clt_id = 5). C'est ce qui permet aux
--    sorts d'aptitude de classe (Paladin 1 : châtiment divin) et aux tables de
--    sous-classe de partager une seule table : le SRD les formule pareil, seul
--    le porteur change.
--
--    cs_variante : le Cercle de la Terre du Druide fait exception. « Chaque fois
--    que vous terminez un Repos long, choisissez un type d'environnement entre :
--    aride, polaire, tempéré et tropical. » Quatre tables alternatives, et le
--    choix se refait chaque jour. La colonne les distingue ; le choix du jour
--    n'est PAS stocké — SP-PE7 affiche les quatre groupes étiquetés et le joueur
--    lit le sien. Chaîne VIDE (et non NULL) pour les autres cas : MySQL traite
--    les NULL comme distincts dans une clé unique, ce qui casserait l'idempotence.
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS dd_classe_sort (
  cs_id        INT UNSIGNED    NOT NULL AUTO_INCREMENT PRIMARY KEY,
  cs_cla_id    INT UNSIGNED    NOT NULL COMMENT 'Classe OU sous-classe -> dd_classes',
  cs_so_id     INT UNSIGNED    NOT NULL COMMENT '-> dd_sorts',
  cs_niveau    TINYINT UNSIGNED NOT NULL COMMENT 'Niveau de classe d''acquisition (cumulatif)',
  cs_variante  VARCHAR(30)     NOT NULL DEFAULT '' COMMENT 'Cercle de la Terre : aride/polaire/tempéré/tropical',
  cs_usages    TINYINT UNSIGNED     NULL COMMENT 'Incantations sans emplacement ; NULL = aucune',
  cs_recharge  VARCHAR(10)          NULL COMMENT 'court / long ; NULL si cs_usages est NULL',
  UNIQUE KEY uk_cs_classe_sort (cs_cla_id, cs_so_id, cs_variante),
  KEY idx_cs_cla (cs_cla_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 2. Données du SRD 5.2.1 — 67 lignes
-- ------------------------------------------------------------

INSERT INTO dd_classe_sort (cs_cla_id, cs_so_id, cs_niveau, cs_variante, cs_usages, cs_recharge) VALUES
  (59, 2136,  1, ''         , NULL, NULL   ),  -- Châtiment divin
  (60, 2291,  1, ''         , 2, 'long' ),  -- Marque du chasseur
  (58, 2153,  9, ''         , 1, 'long' ),  -- Contact avec les plans
  (71, 2083,  3, ''         , NULL, NULL   ),  -- Aide
  (71, 2113,  3, ''         , NULL, NULL   ),  -- Bénédiction
  (71, 2369,  3, ''         , NULL, NULL   ),  -- Restauration partielle
  (71, 2383,  3, ''         , NULL, NULL   ),  -- Soins
  (71, 2305,  5, ''         , NULL, NULL   ),  -- Mot de guérison de groupe
  (71, 2373,  5, ''         , NULL, NULL   ),  -- Retour à la vie
  (71, 2105,  7, ''         , NULL, NULL   ),  -- Aura de vie
  (71, 2348,  7, ''         , NULL, NULL   ),  -- Protection contre la mort
  (71, 2370,  9, ''         , NULL, NULL   ),  -- Restauration suprême
  (71, 2384,  9, ''         , NULL, NULL   ),  -- Soins de groupe
  (72, 2229,  3, 'aride'    , NULL, NULL   ),  -- Flou
  (72, 2286,  3, 'aride'    , NULL, NULL   ),  -- Mains brûlantes
  (72, 2410,  3, 'aride'    , NULL, NULL   ),  -- Trait de feu
  (72, 2120,  5, 'aride'    , NULL, NULL   ),  -- Boule de feu
  (72, 2228,  7, 'aride'    , NULL, NULL   ),  -- Flétrissement
  (72, 2315,  9, 'aride'    , NULL, NULL   ),  -- Mur de pierre
  (72, 2256,  3, 'polaire'  , NULL, NULL   ),  -- Immobilisation de personne
  (72, 2320,  3, 'polaire'  , NULL, NULL   ),  -- Nappe de brouillard
  (72, 2357,  3, 'polaire'  , NULL, NULL   ),  -- Rayon de givre
  (72, 2401,  5, 'polaire'  , NULL, NULL   ),  -- Tempête de neige
  (72, 2400,  7, 'polaire'  , NULL, NULL   ),  -- Tempête de grêle
  (72, 2151,  9, 'polaire'  , NULL, NULL   ),  -- Cône de froid
  (72, 2234,  3, 'tempéré', NULL, NULL   ),  -- Foulée brumeuse
  (72, 2336,  3, 'tempéré', NULL, NULL   ),  -- Poigne électrique
  (72, 2385,  3, 'tempéré', NULL, NULL   ),  -- Sommeil
  (72, 2204,  5, 'tempéré', NULL, NULL   ),  -- Éclair
  (72, 2273,  7, 'tempéré', NULL, NULL   ),  -- Liberté de mouvement
  (72, 2328,  9, 'tempéré', NULL, NULL   ),  -- Passage par les arbres
  (72, 2101,  3, 'tropical' , NULL, NULL   ),  -- Aspersion acide
  (72, 2360,  3, 'tropical' , NULL, NULL   ),  -- Rayon empoisonné
  (72, 2409,  3, 'tropical' , NULL, NULL   ),  -- Toile d'araignée
  (72, 2322,  5, 'tropical' , NULL, NULL   ),  -- Nuage nauséabond
  (72, 2296,  7, 'tropical' , NULL, NULL   ),  -- Métamorphose
  (72, 2226,  9, 'tropical' , NULL, NULL   ),  -- Fléau d'insectes
  (73, 2258,  3, ''         , NULL, NULL   ),  -- Injonction
  (73, 2300,  3, ''         , NULL, NULL   ),  -- Modification d'apparence
  (73, 2325,  3, ''         , NULL, NULL   ),  -- Orbe chromatique
  (73, 2387,  3, ''         , NULL, NULL   ),  -- Souffle du dragon
  (73, 2406,  5, ''         , NULL, NULL   ),  -- Terreur
  (73, 2419,  5, ''         , NULL, NULL   ),  -- Vol
  (73, 2129,  7, ''         , NULL, NULL   ),  -- Charme-monstre
  (73, 2324,  7, ''         , NULL, NULL   ),  -- Œil du mage
  (73, 2160,  9, ''         , NULL, NULL   ),  -- Convocation de dragon
  (73, 2319,  9, ''         , NULL, NULL   ),  -- Mythes et légendes
  (77, 2258,  3, ''         , NULL, NULL   ),  -- Injonction
  (77, 2286,  3, ''         , NULL, NULL   ),  -- Mains brûlantes
  (77, 2356,  3, ''         , NULL, NULL   ),  -- Rayon ardent
  (77, 2394,  3, ''         , NULL, NULL   ),  -- Suggestion
  (77, 2120,  5, ''         , NULL, NULL   ),  -- Boule de feu
  (77, 2322,  5, ''         , NULL, NULL   ),  -- Nuage nauséabond
  (77, 2117,  7, ''         , NULL, NULL   ),  -- Bouclier de feu
  (77, 2312,  7, ''         , NULL, NULL   ),  -- Mur de feu
  (77, 2226,  9, ''         , NULL, NULL   ),  -- Fléau d'insectes
  (77, 2353,  9, ''         , NULL, NULL   ),  -- Quête
  (78, 2118,  3, ''         , NULL, NULL   ),  -- Bouclier de la foi
  (78, 2349,  3, ''         , NULL, NULL   ),  -- Protection contre le mal et le bien
  (78, 2083,  5, ''         , NULL, NULL   ),  -- Aide
  (78, 2420,  5, ''         , NULL, NULL   ),  -- Zone de vérité
  (78, 2193,  9, ''         , NULL, NULL   ),  -- Dissipation de la magie
  (78, 2279,  9, ''         , NULL, NULL   ),  -- Lueur d'espoir
  (78, 2238, 13, ''         , NULL, NULL   ),  -- Gardien de la foi
  (78, 2273, 13, ''         , NULL, NULL   ),  -- Liberté de mouvement
  (78, 2142, 17, ''         , NULL, NULL   ),  -- Colonne de flamme
  (78, 2147, 17, ''         , NULL, NULL   )  -- Communion
ON DUPLICATE KEY UPDATE
  cs_niveau   = VALUES(cs_niveau),
  cs_usages   = VALUES(cs_usages),
  cs_recharge = VALUES(cs_recharge);

-- ------------------------------------------------------------
-- 3. pesp_origine — sorts toujours préparés CHOISIS par le joueur
--
--    0 = préparé normalement       → COMPTE dans cn_sortPrepare
--    1 = toujours préparé, au choix → ne compte pas (Secrets magiques du Barde
--        niveau 10, Sorts de prédilection du Magicien niveau 20)
--    2 = arcanum mystique           → ne compte pas, un usage gratuit par repos
--        long (Occultiste 11/13/15/17)
--
--    Les sorts accordés par une classe ou une sous-classe (section 2) ne sont
--    PAS stockés ici : ils se déduisent de (classe, niveau) et sont calculés à
--    l'affichage.
--
--    Intégré à MA4a plutôt que différé : la famille des « toujours préparés au
--    choix » compte trois membres et non un seul, dont les Secrets magiques du
--    Barde dès le niveau 10 — bien plus atteignable que l'Arcanum au niveau 11.
--    Différer aurait laissé un compteur faux pour tout barde de niveau 10+.
-- ------------------------------------------------------------

ALTER TABLE dd_personnages_sorts_prepares
  ADD COLUMN pesp_origine TINYINT UNSIGNED NOT NULL DEFAULT 0
  COMMENT '0=préparé (compte au plafond), 1=toujours préparé au choix, 2=arcanum';

-- ------------------------------------------------------------
-- 4. Contrôle post-application
-- ------------------------------------------------------------
--
-- SELECT p.cla_nom AS porteur, s.cs_niveau, s.cs_variante,
--        COUNT(*) AS sorts, MAX(s.cs_usages) AS usages
-- FROM   dd_classe_sort s JOIN dd_classes p ON p.cla_id = s.cs_cla_id
-- GROUP  BY s.cs_cla_id, s.cs_variante, s.cs_niveau
-- ORDER  BY p.cla_nom, s.cs_variante, s.cs_niveau;
--
-- Attendu : 67 lignes réparties sur 9 porteurs (3 classes + 6 sous-classes),
-- dont 24 pour le Cercle de la Terre (4 variantes × 4 niveaux).
