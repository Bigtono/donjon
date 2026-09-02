-- ============================================================
-- 2026-08-25_regles_dd35_socle.sql — SP-DRS0
-- Socle du module Règles pour le ruleset DD3.5 (id 1).
-- ------------------------------------------------------------
-- Contenu :
--   1. Ressource d'attribution « DRS 3.5 » (Document de référence
--      du système v3.5, OGL 1.0a) — arbitrage 2026-08-25 (Q4).
--   2. Les racines thématiques de l'arborescence des règles
--      (arbitrage Q1 : regroupement thématique, pas un chapitre
--      par fichier DRS) + la racine du mini-glossaire (Q3).
-- Idempotent : tout est en INSERT … WHERE NOT EXISTS, rien n'est
-- supprimé — les fichiers de lot (drs01, drs10, …) référencent
-- ces racines par slug.
-- Aucun reg_id codé en dur (les ids DD2024 occupent la table).
-- Pré-requis : patch_regles.sql.
-- ============================================================

SET NAMES utf8mb4;

-- Résolution dynamique du ruleset DD3.5 (pas d'id entier codé en dur).
SET @ddver := (SELECT var_id FROM dd_variables
               WHERE var_cat = 'ruleset' AND var_valeur = 'DD3.5' LIMIT 1);

SET @now := NOW();

START TRANSACTION;

-- ------------------------------------------------------------
-- 1. Ressource d'attribution DRS 3.5
--    (schéma réel : pas de colonne res_pages en base)
-- ------------------------------------------------------------
INSERT INTO dd_ressources (res_nom, res_abreviation, res_selection, res_ruleset_var_id, res_j_id, res_editeur, res_description)
SELECT 'Document de référence du système v3.5', 'DRS 3.5', 1, @ddver, NULL, 'Wizards of the Coast, Inc.',
       'Règles issues du Document de référence du système v3.5 (System Reference Document), contenu ouvert publié sous Open Game License v1.0a.'
WHERE @ddver IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dd_ressources
                  WHERE res_abreviation = 'DRS 3.5' AND res_ruleset_var_id = @ddver);
SET @res := (SELECT res_id FROM dd_ressources
             WHERE res_abreviation = 'DRS 3.5' AND res_ruleset_var_id = @ddver LIMIT 1);

-- ------------------------------------------------------------
-- 1b. Activation de la source dans les sélections personnelles
--     DD3.5 existantes (dd_joueurs_sources).
--     Sans cela, tout utilisateur ayant une sélection personnelle
--     (priorité 2 de getActiveResIds) ne verrait JAMAIS les
--     tableaux DRS 3.5 dans le gestionnaire tableaux/index.php ni
--     les futures entrées compendium de cette ressource — piège
--     documenté en §9c (les règles, non filtrées par source, les
--     affichent quand même : l'incohérence est trompeuse).
--     Les utilisateurs sans sélection personnelle sont couverts
--     par la priorité 3 (res_selection = 1). Idempotent.
-- ------------------------------------------------------------
INSERT INTO dd_joueurs_sources (js_j_id, js_res_id, js_ruleset_var_id)
SELECT DISTINCT js.js_j_id, @res, @ddver
FROM   dd_joueurs_sources js
WHERE  js.js_ruleset_var_id = @ddver
  AND  @res IS NOT NULL
  AND  NOT EXISTS (SELECT 1 FROM dd_joueurs_sources d
                   WHERE d.js_j_id = js.js_j_id
                     AND d.js_res_id = @res
                     AND d.js_ruleset_var_id = @ddver);

-- ------------------------------------------------------------
-- 2. Racines thématiques
--    reg_ordre par pas de 10 : les thèmes des lots suivants
--    (magie, personnages, …) s'intercaleront sans renumérotation.
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
SELECT NULL, 'chapitre', 'Les bases du jeu', 'les-bases-du-jeu',
       '<p>Les mécanismes fondamentaux du jeu : les caractéristiques, leurs modificateurs et leur évolution.</p>',
       10, @ddver, @res, NULL, 1, @now, @now
WHERE @ddver IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dd_regles WHERE reg_slug = 'les-bases-du-jeu' AND reg_ruleset_var_id = @ddver);

INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
SELECT NULL, 'chapitre', 'Le combat', 'le-combat',
       '<p>Le déroulement d''un combat, les statistiques et actions de combat, les blessures, le déplacement tactique, les attaques d''opportunité, les modificateurs et les attaques spéciales.</p>',
       20, @ddver, @res, NULL, 1, @now, @now
WHERE @ddver IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dd_regles WHERE reg_slug = 'le-combat' AND reg_ruleset_var_id = @ddver);

INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
SELECT NULL, 'chapitre', 'Aventure et environnement', 'aventure-et-environnement',
       '<p>Les règles de l''aventure hors des combats : voyages en extérieur, milieux naturels, climat et dangers de l''environnement.</p>',
       30, @ddver, @res, NULL, 1, @now, @now
WHERE @ddver IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dd_regles WHERE reg_slug = 'aventure-et-environnement' AND reg_ruleset_var_id = @ddver);

INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
SELECT NULL, 'chapitre', 'Créatures et pouvoirs spéciaux', 'creatures-et-pouvoirs-speciaux',
       '<p>Les règles communes aux créatures : pouvoirs spéciaux, états préjudiciables, types et sous-types.</p>',
       40, @ddver, @res, NULL, 1, @now, @now
WHERE @ddver IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dd_regles WHERE reg_slug = 'creatures-et-pouvoirs-speciaux' AND reg_ruleset_var_id = @ddver);

-- ------------------------------------------------------------
-- 3. Racine du mini-glossaire (arbitrage Q3 : termes techniques
--    majeurs seulement, compilés au fil du traitement des lots ;
--    les règles complètes restent dans leurs chapitres).
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
SELECT NULL, 'chapitre', 'Glossaire', 'glossaire',
       '<p>Les termes techniques majeurs du jeu, en définitions courtes. Chaque terme renvoie au chapitre qui détaille la règle complète.</p>',
       90, @ddver, @res, NULL, 1, @now, @now
WHERE @ddver IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dd_regles WHERE reg_slug = 'glossaire' AND reg_ruleset_var_id = @ddver);

COMMIT;
