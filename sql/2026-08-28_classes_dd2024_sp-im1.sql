-- sql/2026-08-28_classes_dd2024_sp-im1.sql
-- SP-IM1 — Socle des 12 classes de base DD2024 (ruleset_var_id = 2).
--
-- Source : FR_SRD_CC_v5.2.1-classes.pdf, encadrés « Traits de base du <classe> ».
-- Arbitrages du 2026-08-28 : réalignement intégral sur le SRD (les valeurs déjà
-- saisies mais divergentes sont corrigées), et alimentation de dd_classe_competence.
--
-- Périmètre : dd_classes (traits de base) + dd_classe_competence.
--   Hors périmètre : dd_classe_niveau (SP-IM2), capacités (SP-IM3),
--   sous-classes (SP-IM4), listes d'options Métamagie / Manifestations occultes /
--   Styles de combat / Bottes d'arme (lot ultérieur).
--
-- NON TRAITÉ, signalé à l'utilisateur :
--   * cla_description : le SRD 5.2.1 ne contient AUCUN texte d'ambiance de classe
--     (les sections démarrent sur l'encadré des traits de base). Les 8 classes sans
--     description resteront vides — le texte doit venir du MdJ 2024, à la main.
--   * cla_competences, cla_outils, cla_equipement, cla_caracteristiques sont
--     renseignés ici mais ne sont AFFICHÉS NULLE PART en DD2024 par
--     include/ajax/detail-pp/classe.php (écart d'IHM, à arbitrer séparément).
--   * Barde : « 3 compétences au choix » sans liste fermée → aucune ligne
--     dd_classe_competence (les 18 compétences sont éligibles).
--
-- IDEMPOTENCE : rejouable sans effet de bord (UPDATE + DELETE/INSERT).

-- ------------------------------------------------------------
-- 1. Traits de base — dd_classes
-- ------------------------------------------------------------

-- Barbare (51)
UPDATE dd_classes SET
  cla_dV              = 12,
  cla_caracteristiques = 'Force',
  cla_sauvegardes     = 'Force et Constitution',
  cla_competences     = '2 au choix parmi : Athlétisme, Dressage, Intimidation, Nature, Perception et Survie',
  cla_armes           = 'Armes courantes et armes de guerre',
  cla_outils          = '',
  cla_armures         = 'Armures légères, intermédiaires et boucliers',
  cla_equipement      = 'Choisissez A ou B : (A) Hache à deux mains, 4 hachettes, paquetage d’explorateur et 15 po ; ou (B) 75 po'
WHERE cla_id = 51;

-- Barde (53)
UPDATE dd_classes SET
  cla_dV              = 8,
  cla_caracteristiques = 'Charisme',
  cla_sauvegardes     = 'Dextérité et Charisme',
  cla_competences     = '3 compétences au choix',
  cla_armes           = 'Armes courantes',
  cla_outils          = '3 instruments de musique au choix',
  cla_armures         = 'Armures légères',
  cla_equipement      = 'Choisissez A ou B : (A) Armure de cuir, 2 dagues, instrument de musique de votre choix, paquetage d’artiste et 19 po ; ou (B) 90 po'
WHERE cla_id = 53;

-- Clerc (54)
UPDATE dd_classes SET
  cla_dV              = 8,
  cla_caracteristiques = 'Sagesse',
  cla_sauvegardes     = 'Sagesse et Charisme',
  cla_competences     = '2 au choix parmi : Histoire, Intuition, Médecine, Persuasion et Religion',
  cla_armes           = 'Armes courantes',
  cla_outils          = '',
  cla_armures         = 'Armures légères, intermédiaires et boucliers',
  cla_equipement      = 'Choisissez A ou B : (A) Chemise de mailles, bouclier, masse d’armes, symbole sacré, paquetage d’ecclésiastique et 7 po ; ou (B) 110 po'
WHERE cla_id = 54;

-- Druide (55)
UPDATE dd_classes SET
  cla_dV              = 8,
  cla_caracteristiques = 'Sagesse',
  cla_sauvegardes     = 'Intelligence et Sagesse',
  cla_competences     = '2 au choix parmi : Arcanes, Dressage, Intuition, Médecine, Nature, Perception, Religion et Survie',
  cla_armes           = 'Armes courantes',
  cla_outils          = 'Matériel d’herboriste',
  cla_armures         = 'Armures légères et boucliers',
  cla_equipement      = 'Choisissez A ou B : (A) Armure de cuir, bouclier, serpe, focaliseur druidique (bâton de combat), paquetage d’explorateur, matériel d’herboriste et 9 po ; ou (B) 50 po'
WHERE cla_id = 55;

-- Ensorceleur (56)
UPDATE dd_classes SET
  cla_dV              = 6,
  cla_caracteristiques = 'Charisme',
  cla_sauvegardes     = 'Constitution et Charisme',
  cla_competences     = '2 au choix parmi : Arcanes, Intimidation, Intuition, Persuasion, Religion et Tromperie',
  cla_armes           = 'Armes courantes',
  cla_outils          = '',
  cla_armures         = 'Aucune',
  cla_equipement      = 'Choisissez A ou B : (A) Lance, 2 dagues, focaliseur arcanique (cristal), paquetage d’exploration souterraine et 28 po ; ou (B) 50 po'
WHERE cla_id = 56;

-- Guerrier (50)
UPDATE dd_classes SET
  cla_dV              = 10,
  cla_caracteristiques = 'Force ou Dextérité',
  cla_sauvegardes     = 'Force et Constitution',
  cla_competences     = '2 au choix parmi : Acrobaties, Athlétisme, Dressage, Histoire, Intuition, Intimidation, Perception, Persuasion et Survie',
  cla_armes           = 'Armes courantes et armes de guerre',
  cla_outils          = '',
  cla_armures         = 'Armures légères, intermédiaires et lourdes, boucliers',
  cla_equipement      = 'Choisissez entre A, B et C : (A) Cotte de mailles, épée à deux mains, fléau d’armes, 8 javelines, paquetage d’exploration souterraine et 4 po ; (B) Armure de cuir clouté, cimeterre, épée courte, arc long, 20 flèches, carquois, paquetage d’exploration souterraine et 11 po ; ou (C) 155 po'
WHERE cla_id = 50;

-- Magicien (52)
UPDATE dd_classes SET
  cla_dV              = 6,
  cla_caracteristiques = 'Intelligence',
  cla_sauvegardes     = 'Intelligence et Sagesse',
  cla_competences     = '2 au choix parmi : Arcanes, Histoire, Intuition, Investigation, Médecine, Nature et Religion',
  cla_armes           = 'Armes courantes',
  cla_outils          = '',
  cla_armures         = 'Aucune',
  cla_equipement      = 'Choisissez A ou B : (A) 2 dagues, focaliseur arcanique (bâton de combat), robe, grimoire, paquetage d’érudit et 5 po ; ou (B) 55 po'
WHERE cla_id = 52;

-- Moine (57)
UPDATE dd_classes SET
  cla_dV              = 8,
  cla_caracteristiques = 'Dextérité et Sagesse',
  cla_sauvegardes     = 'Force et Dextérité',
  cla_competences     = '2 au choix parmi : Acrobaties, Athlétisme, Discrétion, Histoire, Intuition et Religion',
  cla_armes           = 'Armes courantes ; et armes de guerre dotées de la propriété Légère',
  cla_outils          = 'Choisissez un type d’outils d’artisan ou d’instrument de musique',
  cla_armures         = 'Aucune',
  cla_equipement      = 'Choisissez A ou B : (A) Lance, 5 dagues, outils d’artisan ou instrument de musique choisis pour la maîtrise d’outils ci-dessus, paquetage d’explorateur et 11 po ; ou (B) 50 po'
WHERE cla_id = 57;

-- Occultiste (58)
UPDATE dd_classes SET
  cla_dV              = 8,
  cla_caracteristiques = 'Charisme',
  cla_sauvegardes     = 'Sagesse et Charisme',
  cla_competences     = '2 au choix parmi : Arcanes, Histoire, Intimidation, Investigation, Nature, Religion et Tromperie',
  cla_armes           = 'Armes courantes',
  cla_outils          = '',
  cla_armures         = 'Armures légères',
  cla_equipement      = 'Choisissez A ou B : (A) Armure de cuir, serpe, 2 dagues, focaliseur arcanique (orbe), livre (savoir occulte), paquetage d’érudit et 15 po ; ou (B) 100 po'
WHERE cla_id = 58;

-- Paladin (59)
UPDATE dd_classes SET
  cla_dV              = 10,
  cla_caracteristiques = 'Force et Charisme',
  cla_sauvegardes     = 'Sagesse et Charisme',
  cla_competences     = '2 au choix parmi : Athlétisme, Intimidation, Intuition, Médecine, Persuasion et Religion',
  cla_armes           = 'Armes courantes et armes de guerre',
  cla_outils          = '',
  cla_armures         = 'Armures légères, intermédiaires et lourdes, boucliers',
  cla_equipement      = 'Choisissez A ou B : (A) Cotte de mailles, bouclier, épée longue, 6 javelines, symbole sacré, paquetage d’ecclésiastique et 9 po ; ou (B) 150 po'
WHERE cla_id = 59;

-- Rôdeur (60)
UPDATE dd_classes SET
  cla_dV              = 10,
  cla_caracteristiques = 'Dextérité et Sagesse',
  cla_sauvegardes     = 'Force et Dextérité',
  cla_competences     = '3 au choix parmi : Athlétisme, Discrétion, Dressage, Intuition, Investigation, Nature, Perception et Survie',
  cla_armes           = 'Armes courantes et armes de guerre',
  cla_outils          = '',
  cla_armures         = 'Armures légères, intermédiaires et boucliers',
  cla_equipement      = 'Choisissez A ou B : (A) Armure de cuir clouté, cimeterre, épée courte, arc long, 20 flèches, carquois, focaliseur druidique (branche de gui), paquetage d’explorateur et 7 po ; ou (B) 150 po'
WHERE cla_id = 60;

-- Roublard (61) — cla_dV corrigé : 12 en base, d8 au SRD (écart signalé en SP-MA0)
UPDATE dd_classes SET
  cla_dV              = 8,
  cla_caracteristiques = 'Dextérité',
  cla_sauvegardes     = 'Dextérité et Intelligence',
  cla_competences     = '4 au choix parmi : Acrobaties, Athlétisme, Discrétion, Escamotage, Intimidation, Intuition, Investigation, Perception, Persuasion et Tromperie',
  cla_armes           = 'Armes courantes et armes de guerre dotées de la propriété Finesse ou Légère',
  cla_outils          = 'Outils de voleur',
  cla_armures         = 'Armures légères',
  cla_equipement      = 'Choisissez A ou B : (A) Armure de cuir, 2 dagues, épée courte, arc court, 20 flèches, carquois, outils de voleur, paquetage de cambrioleur et 8 po ; ou (B) 100 po'
WHERE cla_id = 61;

-- ------------------------------------------------------------
-- 2. Normalisation : cla_cla_id = 0 → NULL sur les classes de base
--    (la colonne est une FK nullable ; 0 ne désigne aucune classe)
-- ------------------------------------------------------------

UPDATE dd_classes
SET    cla_cla_id = NULL
WHERE  cla_ruleset_var_id = 2
  AND  cla_clt_id = 4
  AND  cla_cla_id = 0;

-- ------------------------------------------------------------
-- 3. Compétences maîtrisées — dd_classe_competence
--
--    La table n'a pas de clé unique : on purge les lignes des 12 classes
--    avant réinsertion pour rester rejouable.
--    ccomp_precision reste NULL : le nombre à choisir (« 2 au choix parmi »)
--    vit dans cla_competences, l'afficher sur chaque ligne serait illisible.
--
--    Compétences DD2024 : 94 Acrobaties · 95 Arcanes · 96 Athlétisme ·
--    97 Discrétion · 98 Dressage · 99 Escamotage · 100 Histoire ·
--    101 Intimidation · 102 Intuition · 103 Investigation · 104 Médecine ·
--    105 Nature · 106 Perception · 107 Persuasion · 108 Religion ·
--    109 Représentation · 110 Survie · 111 Tromperie
-- ------------------------------------------------------------

DELETE FROM dd_classe_competence WHERE ccomp_cla_id IN (50,51,52,53,54,55,56,57,58,59,60,61);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision) VALUES
  -- Barbare (51) : 2 au choix
  (51,  96, NULL), (51,  98, NULL), (51, 101, NULL), (51, 105, NULL), (51, 106, NULL), (51, 110, NULL),
  -- Barde (53) : 3 compétences au choix, sans liste fermée → aucune ligne
  -- Clerc (54) : 2 au choix
  (54, 100, NULL), (54, 102, NULL), (54, 104, NULL), (54, 107, NULL), (54, 108, NULL),
  -- Druide (55) : 2 au choix
  (55,  95, NULL), (55,  98, NULL), (55, 102, NULL), (55, 104, NULL), (55, 105, NULL), (55, 106, NULL),
  (55, 108, NULL), (55, 110, NULL),
  -- Ensorceleur (56) : 2 au choix
  (56,  95, NULL), (56, 101, NULL), (56, 102, NULL), (56, 107, NULL), (56, 108, NULL), (56, 111, NULL),
  -- Guerrier (50) : 2 au choix
  (50,  94, NULL), (50,  96, NULL), (50,  98, NULL), (50, 100, NULL), (50, 101, NULL), (50, 102, NULL),
  (50, 106, NULL), (50, 107, NULL), (50, 110, NULL),
  -- Magicien (52) : 2 au choix
  (52,  95, NULL), (52, 100, NULL), (52, 102, NULL), (52, 103, NULL), (52, 104, NULL), (52, 105, NULL),
  (52, 108, NULL),
  -- Moine (57) : 2 au choix
  (57,  94, NULL), (57,  96, NULL), (57,  97, NULL), (57, 100, NULL), (57, 102, NULL), (57, 108, NULL),
  -- Occultiste (58) : 2 au choix
  (58,  95, NULL), (58, 100, NULL), (58, 101, NULL), (58, 103, NULL), (58, 105, NULL), (58, 108, NULL),
  (58, 111, NULL),
  -- Paladin (59) : 2 au choix
  (59,  96, NULL), (59, 101, NULL), (59, 102, NULL), (59, 104, NULL), (59, 107, NULL), (59, 108, NULL),
  -- Rôdeur (60) : 3 au choix
  (60,  96, NULL), (60,  97, NULL), (60,  98, NULL), (60, 102, NULL), (60, 103, NULL), (60, 105, NULL),
  (60, 106, NULL), (60, 110, NULL),
  -- Roublard (61) : 4 au choix
  (61,  94, NULL), (61,  96, NULL), (61,  97, NULL), (61,  99, NULL), (61, 101, NULL), (61, 102, NULL),
  (61, 103, NULL), (61, 106, NULL), (61, 107, NULL), (61, 111, NULL);
