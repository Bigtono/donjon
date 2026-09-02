-- sql/2026-09-01_cadence_renouvellement_sp-ma4b.sql
-- SP-MA4b — Cadence de renouvellement du réservoir de sorts (axe C).
--
-- Arbitrage Q3, tranchée le 2026-09-01 (option a). Troisième et dernier axe du
-- modèle de METIER_7_SORTS.md §6 : les deux premiers — réservoir et engagement —
-- vivent depuis SP-MA0 dans cla_profil_incantation. Celui-ci répond à :
-- QUAND le personnage peut-il changer les sorts auxquels il a accès ?
--
-- POURQUOI MAINTENANT. La question était ouverte depuis le 2026-08-27 et je
-- recommandais alors de ne pas la modéliser, faute de consommateur. SP-PE7 en a
-- créé un : l'action « Réinitialiser la liste préparée » retenue en Q8 n'a pas le
-- même sens pour tous. Pour un Clerc c'est un geste quotidien ; pour un Barde
-- DD2024 c'est un geste de MONTÉE DE NIVEAU. Sans cette colonne, la page
-- proposerait le même bouton aux deux et laisserait un barde refaire sa liste
-- chaque matin, ce que la règle interdit.
--
-- PORTÉE. C'est surtout un axe DD2024. En DD3.5, le réservoir d'un préparateur ne
-- bouge jamais (c'est toute la liste de classe) et seuls les lanceurs spontanés
-- ont une règle d'échange — d'où une dérivation depuis cla_profil_incantation
-- plutôt qu'une saisie classe par classe.
--
-- LIMITE ASSUMÉE. La valeur « Montée de niveau » ne porte pas la périodicité fine
-- du DD3.5 (barde : niveau 5 puis tous les 3 ; ensorceleur : niveau 4 puis tous
-- les 2). C'est plus fin que ce dont une aide de jeu a besoin ; le détail reste
-- dans le descriptif de la classe.
--
-- REJEU : sections 1, 3 et 4 rejouables. La SECTION 2 NE L'EST PAS — l'ALTER
-- échoue si la colonne existe. Vérifier :
--   SHOW COLUMNS FROM dd_classes LIKE 'cla_renouvellement';

-- ------------------------------------------------------------
-- 1. Référentiel des cadences (dd_variables, var_cat = 'cadence')
--    IDs figés — repris en constantes PHP CADENCE_* dans include/helpers.php.
-- ------------------------------------------------------------

INSERT INTO dd_variables (var_id, var_cat, var_valeur, var_ordre, var_commentaire) VALUES
  (7, 'cadence', 'Repos long, changement libre', 1, 'La liste peut être entièrement refaite à chaque repos long. DD2024 : clerc, druide, magicien. DD3.5 : tous les préparateurs (préparation quotidienne).'),
  (8, 'cadence', 'Repos long, un seul sort',     2, 'Un seul sort échangé par repos long. DD2024 : paladin, rôdeur. Aucune classe DD3.5.'),
  (9, 'cadence', 'Montée de niveau',             3, 'La liste ne change qu''en gagnant un niveau. DD2024 : barde, ensorceleur, occultiste. DD3.5 : lanceurs spontanés (barde, ensorceleur) selon leur règle d''échange propre.')
ON DUPLICATE KEY UPDATE
  var_cat = VALUES(var_cat), var_valeur = VALUES(var_valeur),
  var_ordre = VALUES(var_ordre), var_commentaire = VALUES(var_commentaire);

-- ------------------------------------------------------------
-- 2. Colonne cla_renouvellement
--    0 = non renseigné / classe non lanceuse.
-- ------------------------------------------------------------

ALTER TABLE dd_classes
  ADD COLUMN cla_renouvellement INT UNSIGNED NOT NULL DEFAULT 0 AFTER cla_profil_incantation;

-- ------------------------------------------------------------
-- 3. DD3.5 — dérivé du profil d'incantation
--
--    Un répertoire figé (profil 5) ne change qu'à la montée de niveau ; tous les
--    autres lanceurs préparent, donc refont leur liste à chaque période de repos.
--    Vaut aussi pour les classes de prestige et les classes hors SRD, ce qui est
--    l'intérêt de dériver plutôt que d'énumérer.
-- ------------------------------------------------------------

UPDATE dd_classes SET cla_renouvellement = 9
WHERE  cla_ruleset_var_id = 1 AND cla_mag_id > 0 AND cla_profil_incantation = 5;

UPDATE dd_classes SET cla_renouvellement = 7
WHERE  cla_ruleset_var_id = 1 AND cla_mag_id > 0 AND cla_profil_incantation IN (3, 4);

-- ------------------------------------------------------------
-- 4. DD2024 — table « Préparation des sorts par classe » du SRD 5.2.1
-- ------------------------------------------------------------

UPDATE dd_classes SET cla_renouvellement = 7
WHERE  cla_ruleset_var_id = 2 AND cla_clt_id = 4 AND TRIM(cla_nom) IN ('Clerc', 'Druide', 'Magicien');

UPDATE dd_classes SET cla_renouvellement = 8
WHERE  cla_ruleset_var_id = 2 AND cla_clt_id = 4 AND TRIM(cla_nom) IN ('Paladin', 'Rôdeur');

UPDATE dd_classes SET cla_renouvellement = 9
WHERE  cla_ruleset_var_id = 2 AND cla_clt_id = 4 AND TRIM(cla_nom) IN ('Barde', 'Ensorceleur', 'Occultiste');

-- ------------------------------------------------------------
-- 5. Contrôle post-application
-- ------------------------------------------------------------
--
-- SELECT c.cla_ruleset_var_id rs, c.cla_nom, v.var_valeur
-- FROM   dd_classes c LEFT JOIN dd_variables v ON v.var_id = c.cla_renouvellement
-- WHERE  c.cla_mag_id > 0 ORDER BY rs, c.cla_clt_id, c.cla_nom;
--
-- Attendu : aucune classe lanceuse à 0, aucune cadence 8 en DD3.5.
