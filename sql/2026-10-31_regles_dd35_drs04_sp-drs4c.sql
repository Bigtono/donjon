-- sql/2026-10-31_regles_dd35_drs04_sp-drs4c.sql
-- SP-DRS4c — Règles DD3.5 : page « Liste des compétences »
-- Page de la racine « Les compétences » qui affiche, par le tag [[liste:competence]], la liste à jour
-- des compétences du compendium (nom, caractéristique, formation nécessaire, malus d'armure).
-- Texte d'introduction rédigé pour le wiki (pas dans le DRS 04).
-- Rejouable : seule la page de CE fichier est réinitialisée, par slug. Aucun reg_id codé en dur.
-- Pré-requis : 2026-10-31_regles_dd35_drs04_sp-drs4.sql (crée la racine « les-competences »).

SET NAMES utf8mb4;

SET @ddver := (SELECT var_id FROM dd_variables WHERE var_cat = 'ruleset' AND var_valeur = 'DD3.5' LIMIT 1);
SET @res   := (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'DRS 3.5' AND res_ruleset_var_id = @ddver LIMIT 1);
SET @racine := (SELECT reg_id FROM dd_regles WHERE reg_slug = 'les-competences' AND reg_ruleset_var_id = @ddver LIMIT 1);
SET @now   := NOW();

START TRANSACTION;

DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'liste-des-competences';

INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@racine, 'regle', 'Liste des compétences', 'liste-des-competences',
'<p>Le tableau suivant récapitule les compétences du jeu. Pour chacune, il indique la caractéristique dont le modificateur s''applique au test, si la compétence exige une formation et si le malus d''armure aux tests s''applique. Cliquez sur le nom d''une compétence pour afficher sa description complète.</p>
<p>[[liste:competence|titre=-]]</p>',
        110, @ddver, @res, NULL, 1, @now, @now);

COMMIT;
