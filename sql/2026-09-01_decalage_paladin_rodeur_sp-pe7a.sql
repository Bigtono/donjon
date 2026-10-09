-- sql/2026-09-01_decalage_paladin_rodeur_sp-pe7a.sql
-- SP-PE7a — Corrige le décalage d'une colonne des tables de sorts du Paladin
-- et du Rôdeur DD3.5.
--
-- CONSTAT (2026-09-01, en validant getMagieContexte). Ces deux classes portent
-- leurs sorts par jour dans cn_sort_n0..n3 alors qu'ils appartiennent aux
-- niveaux de sort 1 à 4. Trois éléments concordants :
--   * au niveau 20, la base donne n0..n3 = 3,3,3,3 ; le SRD donne au paladin
--     et au rôdeur QUATRE niveaux de sorts (1 à 4) à 3 sorts par jour ;
--   * ni l'un ni l'autre n'a de sorts de niveau 0 au SRD — la colonne n0 ne
--     devrait donc jamais être renseignée ;
--   * les trois autres classes DD3.5 sans sorts de niveau 0 (Assassin,
--     Chevalier noir, Tueur de Domiel) ont bien cn_sort_n0 vide.
--
-- Sans ce correctif, la vue Magie accorde à un paladin des sorts de niveau 0
-- qui n'existent pas, et décale d'un cran tous ses autres emplacements.
--
-- SÉCURITÉ. Les colonnes n4..n9 sont vides sur ces deux classes (vérifié avant
-- application) : le décalage n'écrase rien. Une sauvegarde est prise en
-- section 1, le retour arrière est en section 4.
--
-- ORDRE DES AFFECTATIONS. MySQL évalue les assignations d'un SET de gauche à
-- droite en utilisant les valeurs déjà mises à jour. On décale donc du HAUT
-- vers le BAS (n4 <- n3, puis n3 <- n2, …) pour que chaque lecture porte encore
-- sur la valeur d'origine.
--
-- REJEU : NON idempotent — une seconde passe décalerait une fois de plus.
-- Vérifier avant de rejouer :
--   SELECT cn_sort_n0 FROM dd_classe_niveau WHERE cn_cla_id = 8 AND cn_niveau = 20;
--   -- doit valoir NULL après application.

-- ------------------------------------------------------------
-- 1. Sauvegarde
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS dd_classe_niveau_backup_pe7a (
  bk_cn_id  INT UNSIGNED NOT NULL PRIMARY KEY,
  bk_n0 TINYINT UNSIGNED NULL, bk_n1 TINYINT UNSIGNED NULL,
  bk_n2 TINYINT UNSIGNED NULL, bk_n3 TINYINT UNSIGNED NULL,
  bk_n4 TINYINT UNSIGNED NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO dd_classe_niveau_backup_pe7a
  (bk_cn_id, bk_n0, bk_n1, bk_n2, bk_n3, bk_n4)
SELECT cn_id, cn_sort_n0, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4
FROM   dd_classe_niveau
WHERE  cn_cla_id IN (8, 10);

-- ------------------------------------------------------------
-- 2. Décalage : n0..n3 deviennent n1..n4
-- ------------------------------------------------------------

UPDATE dd_classe_niveau
SET    cn_sort_n4 = cn_sort_n3,
       cn_sort_n3 = cn_sort_n2,
       cn_sort_n2 = cn_sort_n1,
       cn_sort_n1 = cn_sort_n0,
       cn_sort_n0 = NULL
WHERE  cn_cla_id IN (8, 10);

-- ------------------------------------------------------------
-- 3. Contrôle
-- ------------------------------------------------------------
--
-- SELECT cn_niveau, cn_sort_n0, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4
-- FROM   dd_classe_niveau WHERE cn_cla_id = 8 ORDER BY cn_niveau;
--
-- Attendu (table du paladin au SRD) : rien avant le niveau 4 ; niveau 4 → n1 = 0
-- (sorts bonus de Sagesse seulement) ; niveau 6 → n1 = 1 ; niveau 8 → n1 = 1,
-- n2 = 0 ; niveau 20 → n1..n4 = 3,3,3,3 et n0 NULL.

-- ------------------------------------------------------------
-- 4. Retour arrière
-- ------------------------------------------------------------
--
-- UPDATE dd_classe_niveau cn JOIN dd_classe_niveau_backup_pe7a b ON b.bk_cn_id = cn.cn_id
--   SET cn.cn_sort_n0 = b.bk_n0, cn.cn_sort_n1 = b.bk_n1, cn.cn_sort_n2 = b.bk_n2,
--       cn.cn_sort_n3 = b.bk_n3, cn.cn_sort_n4 = b.bk_n4;
