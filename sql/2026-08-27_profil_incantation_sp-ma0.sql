-- sql/2026-08-27_profil_incantation_sp-ma0.sql
-- SP-MA0 — Référentiel des classes lanceuses de sorts.
--
-- Analyse : doc/METIER_7_SORTS.md (§6 modèle cible, §7 état relevé).
-- Arbitrages : DECISIONS_LOG.md [2026-08-27] D-MAG2 (cla_mag_id), D-MAG6 (règles),
--              et Q2 option (c) — champ cla_profil_incantation.
--
-- Ce que le patch corrige, tel que relevé en base le 2026-08-27 :
--   * cla_mag_id DD2024 pointait sur des valeurs du ruleset DD3.5 (Magicien = 1)
--     ou inexistantes (Rôdeur = 5) ; les autres valaient 4 (« Divine ») alors que
--     DD2024 ne distingue plus profane et divin.
--   * cla_car_id = 0 (non renseignée) sur Ensorceleur, Magicien, Occultiste, Rôdeur DD2024.
--   * Les trois drapeaux cla_sort_connu / _compris / _prepare valaient 0 sur toutes les
--     classes DD2024, et étaient INVERSÉS en DD3.5 (Magicien connu=1/compris=0,
--     Ensorceleur compris=1/connu=0) — 8 combinaisons possibles, 4 seulement ont un sens.
--   * cla_domaine_divin = 0 sur le Prêtre DD3.5 : les deux selects de domaine de
--     l'éditeur de classes (SP-PE2) ne s'affichaient JAMAIS, pc_do_id_1/2 restaient NULL.
--
-- IDEMPOTENCE : la section 2 (ADD COLUMN) n'est pas ré-exécutable. Vérifier avant rejeu :
--   SHOW COLUMNS FROM dd_classes LIKE 'cla_profil_incantation';
-- Toutes les autres sections sont rejouables sans effet de bord.
--
-- NON TRAITÉ ICI, volontairement (hors périmètre SP-MA0, signalé à l'utilisateur) :
--   * dd_classes.cla_dV du Roublard DD2024 vaut 12, le SRD 5.2.1 dit d8.
--   * cla_niveauMax = 10 sur Hiérophante et Thaumaturge (DD3.5), qui font 5 niveaux.
--   * Disciple draconien (DD3.5) : drapeaux cn_niveauSort* tous NULL alors que le SRD
--     lui donne une progression d'incantation.

-- ------------------------------------------------------------
-- 1. Référentiel des profils d'incantation (dd_variables, var_cat = 'profinc')
--
--    Quatre profils, et seulement quatre : ce sont les combinaisons réellement
--    présentes dans les règles (METIER_7_SORTS.md §6). IDs figés — ils sont
--    repris en constantes PHP dans include/helpers.php (PROFINC_*).
-- ------------------------------------------------------------

INSERT INTO dd_variables (var_id, var_cat, var_valeur, var_ordre, var_commentaire) VALUES
  (3, 'profinc', 'Liste préparée',      1, 'Réservoir = liste de classe entière ; le personnage prépare un sous-ensemble. DD3.5 : prêtre, druide, paladin, rôdeur. DD2024 : clerc, druide, paladin, rôdeur, barde, ensorceleur.'),
  (4, 'profinc', 'Grimoire',            2, 'Réservoir = grimoire (sous-ensemble matérialisé, dd_personnages_sorts.pes_compris = 1) ; le personnage prépare depuis le grimoire. Magicien, les deux rulesets.'),
  (5, 'profinc', 'Répertoire spontané', 3, 'Réservoir figé et plafonné (cn_sortConnu_n0..9) ; tout le répertoire est lançable sans préparation. DD3.5 UNIQUEMENT — barde, ensorceleur. Aucune classe DD2024 (voir METIER_7_SORTS.md §4, encadré).'),
  (6, 'profinc', 'Magie de pacte',       4, 'Préparé, mais emplacements tous du même niveau et restaurés au repos court. DD2024 uniquement — occultiste.')
ON DUPLICATE KEY UPDATE
  var_cat         = VALUES(var_cat),
  var_valeur      = VALUES(var_valeur),
  var_ordre       = VALUES(var_ordre),
  var_commentaire = VALUES(var_commentaire);

-- ------------------------------------------------------------
-- 2. Colonne cla_profil_incantation
--    0 = non renseigné / classe non lanceuse.
-- ------------------------------------------------------------

ALTER TABLE dd_classes
  ADD COLUMN cla_profil_incantation INT UNSIGNED NOT NULL DEFAULT 0 AFTER cla_mag_id;

-- ------------------------------------------------------------
-- 3. cla_mag_id — plage de valeurs propre à chaque ruleset (D-MAG2)
--
--    DD3.5   : 0 = non lanceur, 1 = profane, 2 = divin   → INCHANGÉ
--    DD2024  : 0 = non lanceur, 1 = lanceur (sans distinction profane/divin)
--
--    Le test « cla_mag_id > 0 » continue donc d'identifier une classe lanceuse
--    dans les deux rulesets. Conséquence portée dans le code : le libellé
--    dd_typemagie ne se lit QUE si cla_ruleset_var_id = 1.
-- ------------------------------------------------------------

UPDATE dd_classes
SET    cla_mag_id = 1
WHERE  cla_ruleset_var_id = 2
  AND  cla_mag_id > 0;

-- ------------------------------------------------------------
-- 4. cla_car_id — caractéristique d'incantation DD2024 manquante
--    (4 = Intelligence, 5 = Sagesse, 6 = Charisme dans dd_caracteristiques)
-- ------------------------------------------------------------

UPDATE dd_classes SET cla_car_id = 6 WHERE cla_ruleset_var_id = 2 AND cla_car_id = 0 AND TRIM(cla_nom) = 'Ensorceleur';
UPDATE dd_classes SET cla_car_id = 4 WHERE cla_ruleset_var_id = 2 AND cla_car_id = 0 AND TRIM(cla_nom) = 'Magicien';
UPDATE dd_classes SET cla_car_id = 6 WHERE cla_ruleset_var_id = 2 AND cla_car_id = 0 AND TRIM(cla_nom) = 'Occultiste';
UPDATE dd_classes SET cla_car_id = 5 WHERE cla_ruleset_var_id = 2 AND cla_car_id = 0 AND TRIM(cla_nom) = 'Rôdeur';

-- ------------------------------------------------------------
-- 5. cla_profil_incantation — dérivation générale
--
--    Les trois drapeaux cla_sort_* étant établis comme non fiables (§7), on ne
--    s'en sert PAS pour la migration. On dérive de la DONNÉE, qui, elle, est saine :
--      * une classe dont dd_classe_niveau porte au moins un cn_sortConnu_n*
--        renseigné a bien un répertoire figé  → Répertoire spontané ;
--      * toute autre classe lanceuse          → Liste préparée.
--    Les cas particuliers (grimoire, pacte) sont posés en section 6.
--
--    Cette règle préserve l'affichage existant de la table « Sorts connus » des
--    classes hors SRD (Élu divin, Assassin, Tueur de Domiel…), qui était piloté
--    jusqu'ici par cla_sort_connu.
-- ------------------------------------------------------------

UPDATE dd_classes c
SET    c.cla_profil_incantation = 5
WHERE  c.cla_mag_id > 0
  AND  EXISTS (
         SELECT 1 FROM dd_classe_niveau n
         WHERE  n.cn_cla_id = c.cla_id
           AND  COALESCE(n.cn_sortConnu_n0, n.cn_sortConnu_n1, n.cn_sortConnu_n2,
                         n.cn_sortConnu_n3, n.cn_sortConnu_n4, n.cn_sortConnu_n5,
                         n.cn_sortConnu_n6, n.cn_sortConnu_n7, n.cn_sortConnu_n8,
                         n.cn_sortConnu_n9) IS NOT NULL
       );

UPDATE dd_classes
SET    cla_profil_incantation = 3
WHERE  cla_mag_id > 0
  AND  cla_profil_incantation = 0;

-- ------------------------------------------------------------
-- 6. cla_profil_incantation — cas particuliers du SRD
--
--    Ciblage par ruleset + type + nom exact : ne touche ni les classes homebrew
--    ni les classes hors SRD portant un nom voisin.
-- ------------------------------------------------------------

-- Magicien : réservoir = grimoire (les deux rulesets)
UPDATE dd_classes SET cla_profil_incantation = 4
WHERE  TRIM(cla_nom) = 'Magicien'
  AND  ((cla_ruleset_var_id = 1 AND cla_clt_id = 1) OR (cla_ruleset_var_id = 2 AND cla_clt_id = 4));

-- Occultiste DD2024 : Magie de pacte
UPDATE dd_classes SET cla_profil_incantation = 6
WHERE  cla_ruleset_var_id = 2 AND cla_clt_id = 4 AND TRIM(cla_nom) = 'Occultiste';

-- Barde et Ensorceleur DD2024 : préparateurs comme les autres.
-- Ils n'ont pas de cn_sortConnu_n* en base, la section 5 les a donc déjà classés
-- en « Liste préparée » — cet UPDATE est un garde-fou explicite contre la
-- confusion 5e-2014 / 5e-2024 (METIER_7_SORTS.md §4, encadré).
UPDATE dd_classes SET cla_profil_incantation = 3
WHERE  cla_ruleset_var_id = 2 AND cla_clt_id = 4
  AND  TRIM(cla_nom) IN ('Barde', 'Ensorceleur');

-- ------------------------------------------------------------
-- 7. cla_domaine_divin — le Prêtre DD3.5 choisit deux domaines
--    Correctif d'un défaut visible : à 0, personnages/fiche.php n'affichait
--    jamais les deux selects de domaine (bloc Classes, SP-PE2).
-- ------------------------------------------------------------

UPDATE dd_classes
SET    cla_domaine_divin = 1
WHERE  cla_ruleset_var_id = 1 AND cla_clt_id = 1 AND TRIM(cla_nom) = 'Prêtre';

-- ------------------------------------------------------------
-- 8. Dépréciation des trois drapeaux
--
--    cla_sort_connu / cla_sort_compris / cla_sort_prepare ne sont plus ni lus
--    ni écrits par l'application après ce patch. Les colonnes sont CONSERVÉES
--    en l'état (aucun DROP) le temps de vérifier le comportement en production ;
--    leur suppression fera l'objet d'une phase de nettoyage ultérieure.
--    Ne pas les réutiliser : leur contenu est figé au 2026-08-27 et faux.
--
--    cla_domaine_divin, lui, reste ACTIF : il est orthogonal au profil
--    (un prêtre est « Liste préparée » ET à domaines).
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- 9. Contrôle post-application
-- ------------------------------------------------------------
--
-- SELECT c.cla_ruleset_var_id rs, c.cla_nom, c.cla_mag_id, c.cla_car_id,
--        c.cla_profil_incantation, v.var_valeur, c.cla_domaine_divin
-- FROM   dd_classes c
-- LEFT   JOIN dd_variables v ON v.var_id = c.cla_profil_incantation
-- WHERE  c.cla_mag_id > 0
-- ORDER  BY c.cla_ruleset_var_id, c.cla_clt_id, c.cla_nom;
--
-- Attendu : aucune classe lanceuse à cla_profil_incantation = 0,
--           aucun profil 5 (Répertoire spontané) en ruleset 2,
--           aucun profil 6 (Magie de pacte) en ruleset 1,
--           aucune classe lanceuse DD2024 à cla_car_id = 0.
