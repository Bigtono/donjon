-- sql/2026-10-31_sp-cd0_competences_domaines.sql
-- SP-CD0 — Compétences à domaines (DD3.5)
--
-- Connaissances, Artisanat, Profession et Représentation se déclinent en domaines, chacun étant une compétence à
-- part entière (rangs propres). Un domaine est une ligne dd_competences fille : comp_parent_id -> compétence mère.
-- Son nom complet est stocké (« Connaissances (histoire) ») ; caractéristique, formation et malus d'armure sont
-- recopiés de la mère (compendium/enregistrement.php les tient alignés).
--
-- La mère est retrouvée par son nom (les ids peuvent différer entre local et production). Les domaines déjà
-- présents ne sont pas réinsérés. Les liens dd_classe_competence orphelins (anciennes variantes supprimées, D-PE14)
-- sont retirés. Pas de DELIMITER.

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;

ALTER TABLE dd_competences
  ADD COLUMN comp_parent_id INT UNSIGNED NULL
    COMMENT 'Domaine : -> dd_competences (compétence mère) ; NULL = compétence simple ou mère (SP-CD)' AFTER comp_nom,
  ADD KEY idx_comp_parent (comp_parent_id);

INSERT INTO dd_competences
  (comp_nom, comp_parent_id, comp_car_id, comp_malusArmure, comp_formation, comp_description,
   comp_res_id, comp_public, comp_visible, comp_ruleset_var_id)
SELECT CONCAT(m.comp_nom, ' (', d.nom, ')'), m.comp_id, m.comp_car_id, m.comp_malusArmure, m.comp_formation,
       d.descr, m.comp_res_id, m.comp_public, m.comp_visible, m.comp_ruleset_var_id
  FROM dd_competences m
  JOIN (
              SELECT 'architecture et ingénierie' AS nom, '<p>Bâtiments, aqueducs, ponts, fortifications.</p>' AS descr
    UNION ALL SELECT 'exploration souterraine', '<p>Aberrations, cavernes, vases, spéléologie.</p>'
    UNION ALL SELECT 'folklore local', '<p>Légendes, personnalités pittoresques, habitants, lois et traditions, coutumes, humanoïdes.</p>'
    UNION ALL SELECT 'géographie', '<p>Pays, types de terrain, climat, peuples.</p>'
    UNION ALL SELECT 'histoire', '<p>Dynasties, guerres, colonies, migrations, fondation des villes et des pays.</p>'
    UNION ALL SELECT 'mystères', '<p>Créatures artificielles, créatures magiques, dragons, mystères anciens, phrases incompréhensibles, symboles ésotériques, traditions magiques.</p>'
    UNION ALL SELECT 'nature', '<p>Animaux, climat, cycles et saisons, fées, géants, humanoïdes monstrueux, plantes, vermines.</p>'
    UNION ALL SELECT 'noblesse et royauté', '<p>Lignées, héraldique, coutumes, arbres généalogiques, devises, personnalités.</p>'
    UNION ALL SELECT 'plans', '<p>Plans extérieurs, plans intérieurs, plan Astral, plan Éthéré, Extérieurs, élémentaires, la magie et les plans.</p>'
    UNION ALL SELECT 'religion', '<p>Dieux et déesses, mythologie, tradition ecclésiastique, symboles sacrés, morts-vivants.</p>'
  ) d
 WHERE m.comp_nom = 'Connaissances'
   AND m.comp_ruleset_var_id = 1
   AND m.comp_parent_id IS NULL
   AND NOT EXISTS (
     SELECT 1 FROM dd_competences x
      WHERE x.comp_ruleset_var_id = 1
        AND x.comp_nom = CONCAT(m.comp_nom, ' (', d.nom, ')')
   );

DELETE FROM dd_classe_competence
 WHERE ccomp_comp_id NOT IN (SELECT comp_id FROM dd_competences);
