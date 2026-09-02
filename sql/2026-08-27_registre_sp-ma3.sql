-- sql/2026-08-27_registre_sp-ma3.sql
-- SP-MA3 — Séparation branche / registre en DD3.5.
--
-- Analyse : doc/METIER_7_SORTS.md §2 et §11 Q4. Arbitrage : DECISIONS_LOG.md
-- [2026-08-27] D-MAG3 — « on migre et on assume ».
--
-- CONSTAT (relevé du 2026-08-27, 1 935 sorts DD3.5) : so_branche mélange trois
-- notions et pas deux. 690 sorts portent une valeur, sur 84 valeurs distinctes :
--   * des BRANCHES              — Coercition, Création, Convocation, Charme…
--     (+ les 6 disciplines psioniques du GMP, de même rôle syntaxique)
--   * des REGISTRES             — Mal, Bien, feu, force, terre, son, lumière…
--   * des MÉLANGES              — « Fantasme [mental, terreur] », « coercition mental »,
--                                 « création, mal », avec ou sans crochets, avec ou
--                                 sans virgules, casse et accents irréguliers
--   * des DONNÉES DE DOMAINE ÉGARÉES — « Cavernes 7 », « Initié de Mystra 3 »,
--     « Portails 6 », « Mort aqueuse 5 » : un nom de domaine et son niveau, qui
--     relèvent de dd_sortdomaine et n'ont rien à faire ici.
--   * des valeurs TRONQUÉES à 20 caractères par l'import v1→v2 (la colonne fait
--     pourtant varchar(40)) : « bien, feu, résurrect », « creation, électricit »…
--     Le texte perdu l'est définitivement.
--
-- La classification ne tient pas en SQL : elle vit dans sql/migrate_registre_sp-ma3.php,
-- à exécuter APRÈS ce fichier. Elle s'appuie sur deux listes fermées (18 branches et
-- disciplines, 19 registres du SRD + 3 registres de suppléments attestés).
--
-- IDEMPOTENCE : la section 2 (ADD COLUMN) n'est pas ré-exécutable. Vérifier :
--   SHOW COLUMNS FROM dd_sorts LIKE 'so_registre';
-- Le script PHP, lui, est rejouable indéfiniment : il lit la table de sauvegarde
-- créée en section 1, jamais la colonne vive.

-- ------------------------------------------------------------
-- 1. Sauvegarde des valeurs d'origine — filet de sécurité ET source de la migration
--
--    La migration RÉÉCRIT so_branche sur 680 lignes. Cette table rend l'opération
--    réversible (voir section 4) et rend le script PHP rejouable : il classe
--    toujours depuis l'original, jamais depuis le résultat de la passe précédente.
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS dd_sorts_branche_backup_spma3 (
  bk_so_id    INT UNSIGNED NOT NULL PRIMARY KEY,
  bk_branche  VARCHAR(40) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO dd_sorts_branche_backup_spma3 (bk_so_id, bk_branche)
SELECT so_id, so_branche
FROM   dd_sorts
WHERE  so_ruleset_var_id = 1
  AND  TRIM(COALESCE(so_branche, '')) <> '';

-- ------------------------------------------------------------
-- 2. Colonne so_registre
--
--    120 caractères : un sort peut cumuler plusieurs registres
--    (« mental, terreur », « création, mort, mal »). so_branche reste en
--    varchar(40), une seule branche par sort suffisant largement.
-- ------------------------------------------------------------

ALTER TABLE dd_sorts
  ADD COLUMN so_registre VARCHAR(120) NULL AFTER so_branche;

-- ------------------------------------------------------------
-- 3. Migration
--    Exécuter maintenant :  php sql/migrate_registre_sp-ma3.php
--    (option --dry pour un rapport sans écriture)
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- 4. Retour arrière, si nécessaire
-- ------------------------------------------------------------
--
-- UPDATE dd_sorts s
--   JOIN dd_sorts_branche_backup_spma3 b ON b.bk_so_id = s.so_id
--   SET s.so_branche = b.bk_branche, s.so_registre = NULL;
--
-- La table de sauvegarde peut être conservée : elle est la seule trace des
-- valeurs d'origine, y compris des résidus de troncature perdus au passage.
