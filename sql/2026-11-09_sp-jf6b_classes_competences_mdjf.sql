-- sql/2026-11-09_sp-jf6b_classes_competences_mdjf.sql
-- SP-JF6b — Compétences de classe des classes de prestige MdJF déjà présentes (Adepte de l'ombre, Parangon ménestrel),
-- absentes de dd_classe_competence ; cla_competences renseigné s'il était vide. Rejouable. Pas de DELIMITER.

SET NAMES utf8mb4;

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Adepte de l''Ombre' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

UPDATE dd_classes SET cla_competences = '<p>Compétences de classe : Art de la magie, Artisanat, Bluff, Concentration, Connaissances (toutes), Déguisement, Discrétion, Profession.</p>' WHERE cla_id = @cla AND (cla_competences IS NULL OR cla_competences = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 2, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 2);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 3, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 3);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 4, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 4);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 9, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 9);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 14, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 14);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Parangon Ménestrel' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

UPDATE dd_classes SET cla_competences = '<p>Compétences de classe : Acrobaties, Artisanat, Bluff, Connaissances (au choix), Déguisement, Déplacement silencieux, Diplomatie, Discrétion, Escalade, Escamotage, Estimation, Évasion, Langue, Perception auditive, Profession, Psychologie, Renseignement, Représentation, Saut, Survie.</p>' WHERE cla_id = @cla AND (cla_competences IS NULL OR cla_competences = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 1, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 1);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 3, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 3);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 9, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 9);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 10, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 10);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 13, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 13);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 14, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 14);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 18, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 18);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 19, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 19);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 20, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 20);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 21, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 21);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 24, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 24);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 27, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 27);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 30, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 30);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 31, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 31);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 32, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 32);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 33, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 33);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 34, ''
WHERE @cla IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 34);
