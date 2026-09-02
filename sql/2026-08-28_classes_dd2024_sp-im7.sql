-- sql/2026-08-28_classes_dd2024_sp-im7.sql
-- SP-IM7 — Nombre de compétences maîtrisées au choix (DD2024).
--
-- Source : FR_SRD_CC_v5.2.1-classes.pdf, ligne « Maîtrises de compétence » de
--          l'encadré « Traits de base du <classe> ».
--
-- CONTEXTE — sémantique de dd_classe_competence, différente d'un ruleset à l'autre :
--   *[DD3.5]*  la table liste les compétences DE CLASSE. Un point investi dans
--              une compétence de classe vaut 1 rang, 1/2 rang ailleurs. Le nombre
--              de points par niveau vit dans cla_pointsCompetences.
--   *[DD2024]* la table liste les compétences que le personnage PEUT maîtriser.
--              Il en choisit un nombre fixe, indiqué par la classe — c'est cette
--              information qui manquait, et que porte désormais cla_pointsCompetences.
--
-- SP-IM1 avait rempli dd_classe_competence sur le modèle DD3.5 : la liste était
-- juste, mais le nombre à choisir n'existait qu'en texte libre dans
-- cla_competences, non exploitable. Ce patch le rend structuré.
--
-- Le champ garde ses deux usages, distingués par le ruleset — commentaire de
-- colonne mis à jour en base par l'utilisateur le 2026-08-28.
--
-- ⚠ Le Barde n'a PAS de liste fermée (« 3 compétences au choix » parmi les 18) :
--   cla_pointsCompetences = 3, et aucune ligne dd_classe_competence. La fiche
--   retombe alors sur le texte libre cla_competences.
--
-- IDEMPOTENCE : UPDATE seuls, rejouable.

UPDATE dd_classes SET cla_pointsCompetences = 2 WHERE cla_id = 51;  -- Barbare     : Athlétisme, Dressage, Intimidation, Nature, Perception, Survie
UPDATE dd_classes SET cla_pointsCompetences = 3 WHERE cla_id = 53;  -- Barde       : 3 compétences au choix, sans liste fermée
UPDATE dd_classes SET cla_pointsCompetences = 2 WHERE cla_id = 54;  -- Clerc       : Histoire, Intuition, Médecine, Persuasion, Religion
UPDATE dd_classes SET cla_pointsCompetences = 2 WHERE cla_id = 55;  -- Druide      : Arcanes, Dressage, Intuition, Médecine, Nature, Perception, Religion, Survie
UPDATE dd_classes SET cla_pointsCompetences = 2 WHERE cla_id = 56;  -- Ensorceleur : Arcanes, Intimidation, Intuition, Persuasion, Religion, Tromperie
UPDATE dd_classes SET cla_pointsCompetences = 2 WHERE cla_id = 50;  -- Guerrier    : Acrobaties, Athlétisme, Dressage, Histoire, Intuition, Intimidation, Perception, Persuasion, Survie
UPDATE dd_classes SET cla_pointsCompetences = 2 WHERE cla_id = 52;  -- Magicien    : Arcanes, Histoire, Intuition, Investigation, Médecine, Nature, Religion
UPDATE dd_classes SET cla_pointsCompetences = 2 WHERE cla_id = 57;  -- Moine       : Acrobaties, Athlétisme, Discrétion, Histoire, Intuition, Religion
UPDATE dd_classes SET cla_pointsCompetences = 2 WHERE cla_id = 58;  -- Occultiste  : Arcanes, Histoire, Intimidation, Investigation, Nature, Religion, Tromperie
UPDATE dd_classes SET cla_pointsCompetences = 2 WHERE cla_id = 59;  -- Paladin     : Athlétisme, Intimidation, Intuition, Médecine, Persuasion, Religion
UPDATE dd_classes SET cla_pointsCompetences = 3 WHERE cla_id = 60;  -- Rôdeur      : Athlétisme, Discrétion, Dressage, Intuition, Investigation, Nature, Perception, Survie
UPDATE dd_classes SET cla_pointsCompetences = 4 WHERE cla_id = 61;  -- Roublard    : Acrobaties, Athlétisme, Discrétion, Escamotage, Intimidation, Intuition, Investigation, Perception, Persuasion, Tromperie
