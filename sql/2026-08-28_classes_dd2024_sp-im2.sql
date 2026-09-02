-- sql/2026-08-28_classes_dd2024_sp-im2.sql
-- SP-IM2 — Tables de progression des 12 classes de base DD2024 (dd_classe_niveau).
--
-- Source : FR_SRD_CC_v5.2.1-classes.pdf, tables « Aptitudes du <classe> ».
-- Arbitrage du 2026-08-28 : réalignement intégral sur le SRD.
--
-- Ce que le patch corrige, tel que relevé en base le 2026-08-28 :
--   * cn_bba (bonus de maîtrise DD2024) VIDE sur Barde, Clerc, Druide,
--     Ensorceleur, Paladin et Roublard.
--   * AUCUNE ligne pour Moine, Occultiste et Rôdeur (3 × 20 lignes créées).
--   * Barde : seuls les niveaux 1 à 3 étaient renseignés.
--   * Ensorceleur et Paladin : aucun emplacement de sort.
--   * Druide : Forme sauvage fausse à partir du niveau 9 (le SRD plafonne à 3
--     jusqu'au niveau 16, la base montait à 6), sorts mineurs faux à partir du
--     niveau 10, et emplacements de 5e niveau à 3 au lieu de 2 (niv. 11 à 17).
--   * Magicien : 4 sorts mineurs au niveau 10 au lieu de 5.
--   * Roublard : Attaque sournoise 3d6 au niveau 4 au lieu de 2d6.
--
-- Conventions DD2024 (cf. doc/METIER_2_Classes.md) :
--   cn_bba        = bonus de maîtrise
--   cn_sort_n0    = sorts mineurs   ·   cn_sortPrepare = sorts préparés
--   cn_sort_n1..9 = emplacements de sort par niveau
--   cn_pouvoir1..5 = colonnes propres à la classe (intitulés dans cla_pouvoir1..5)
--   cn_reflexes / cn_vigueur / cn_volonte : DD3.5 uniquement → 0
--
-- Occultiste : la Magie de pacte n'a pas d'emplacements par niveau de sort.
--   Le nombre d'emplacements et leur niveau vivent dans cn_pouvoir2 / cn_pouvoir3,
--   cn_sort_n1..9 restent à 0 — c'est le modèle déjà retenu par cla_pouvoir2/3.
--
-- IDEMPOTENCE : DELETE puis INSERT des 240 lignes. Rejouable.
--   ⚠ dd_classe_niveau n'a pas de clé unique : le DELETE est la seule protection
--   contre les doublons, ne pas exécuter l'INSERT seul.

DELETE FROM dd_classe_niveau WHERE cn_cla_id IN (50,51,52,53,54,55,56,57,58,59,60,61);

-- Barbare (51)
INSERT INTO dd_classe_niveau
  (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte,
   cn_sortPrepare, cn_sort_n0, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4,
   cn_sort_n5, cn_sort_n6, cn_sort_n7, cn_sort_n8, cn_sort_n9,
   cn_pouvoir1, cn_pouvoir2, cn_pouvoir3, cn_pouvoir4, cn_pouvoir5)
VALUES
  (51,  1, '2', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2', '+2', '2', NULL, NULL),
  (51,  2, '2', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2', '+2', '2', NULL, NULL),
  (51,  3, '2', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '3', '+2', '2', NULL, NULL),
  (51,  4, '2', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '3', '+2', '3', NULL, NULL),
  (51,  5, '3', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '3', '+2', '3', NULL, NULL),
  (51,  6, '3', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '4', '+2', '3', NULL, NULL),
  (51,  7, '3', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '4', '+2', '3', NULL, NULL),
  (51,  8, '3', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '4', '+2', '3', NULL, NULL),
  (51,  9, '4', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '4', '+3', '3', NULL, NULL),
  (51, 10, '4', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '4', '+3', '4', NULL, NULL),
  (51, 11, '4', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '4', '+3', '4', NULL, NULL),
  (51, 12, '4', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '5', '+3', '4', NULL, NULL),
  (51, 13, '5', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '5', '+3', '4', NULL, NULL),
  (51, 14, '5', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '5', '+3', '4', NULL, NULL),
  (51, 15, '5', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '5', '+3', '4', NULL, NULL),
  (51, 16, '5', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '5', '+4', '4', NULL, NULL),
  (51, 17, '6', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '6', '+4', '4', NULL, NULL),
  (51, 18, '6', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '6', '+4', '4', NULL, NULL),
  (51, 19, '6', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '6', '+4', '4', NULL, NULL),
  (51, 20, '6', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '6', '+4', '4', NULL, NULL);

-- Barde (53)
INSERT INTO dd_classe_niveau
  (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte,
   cn_sortPrepare, cn_sort_n0, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4,
   cn_sort_n5, cn_sort_n6, cn_sort_n7, cn_sort_n8, cn_sort_n9,
   cn_pouvoir1, cn_pouvoir2, cn_pouvoir3, cn_pouvoir4, cn_pouvoir5)
VALUES
  (53,  1, '2', 0, 0, 0,  4, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'd6', NULL, NULL, NULL, NULL),
  (53,  2, '2', 0, 0, 0,  5, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0, 'd6', NULL, NULL, NULL, NULL),
  (53,  3, '2', 0, 0, 0,  6, 2, 4, 2, 0, 0, 0, 0, 0, 0, 0, 'd6', NULL, NULL, NULL, NULL),
  (53,  4, '2', 0, 0, 0,  7, 3, 4, 3, 0, 0, 0, 0, 0, 0, 0, 'd6', NULL, NULL, NULL, NULL),
  (53,  5, '3', 0, 0, 0,  9, 3, 4, 3, 2, 0, 0, 0, 0, 0, 0, 'd8', NULL, NULL, NULL, NULL),
  (53,  6, '3', 0, 0, 0, 10, 3, 4, 3, 3, 0, 0, 0, 0, 0, 0, 'd8', NULL, NULL, NULL, NULL),
  (53,  7, '3', 0, 0, 0, 11, 3, 4, 3, 3, 1, 0, 0, 0, 0, 0, 'd8', NULL, NULL, NULL, NULL),
  (53,  8, '3', 0, 0, 0, 12, 3, 4, 3, 3, 2, 0, 0, 0, 0, 0, 'd8', NULL, NULL, NULL, NULL),
  (53,  9, '4', 0, 0, 0, 14, 3, 4, 3, 3, 3, 1, 0, 0, 0, 0, 'd8', NULL, NULL, NULL, NULL),
  (53, 10, '4', 0, 0, 0, 15, 4, 4, 3, 3, 3, 2, 0, 0, 0, 0, 'd10', NULL, NULL, NULL, NULL),
  (53, 11, '4', 0, 0, 0, 16, 4, 4, 3, 3, 3, 2, 1, 0, 0, 0, 'd10', NULL, NULL, NULL, NULL),
  (53, 12, '4', 0, 0, 0, 16, 4, 4, 3, 3, 3, 2, 1, 0, 0, 0, 'd10', NULL, NULL, NULL, NULL),
  (53, 13, '5', 0, 0, 0, 17, 4, 4, 3, 3, 3, 2, 1, 1, 0, 0, 'd10', NULL, NULL, NULL, NULL),
  (53, 14, '5', 0, 0, 0, 17, 4, 4, 3, 3, 3, 2, 1, 1, 0, 0, 'd10', NULL, NULL, NULL, NULL),
  (53, 15, '5', 0, 0, 0, 18, 4, 4, 3, 3, 3, 2, 1, 1, 1, 0, 'd12', NULL, NULL, NULL, NULL),
  (53, 16, '5', 0, 0, 0, 18, 4, 4, 3, 3, 3, 2, 1, 1, 1, 0, 'd12', NULL, NULL, NULL, NULL),
  (53, 17, '6', 0, 0, 0, 19, 4, 4, 3, 3, 3, 2, 1, 1, 1, 1, 'd12', NULL, NULL, NULL, NULL),
  (53, 18, '6', 0, 0, 0, 20, 4, 4, 3, 3, 3, 3, 1, 1, 1, 1, 'd12', NULL, NULL, NULL, NULL),
  (53, 19, '6', 0, 0, 0, 21, 4, 4, 3, 3, 3, 3, 2, 1, 1, 1, 'd12', NULL, NULL, NULL, NULL),
  (53, 20, '6', 0, 0, 0, 22, 4, 4, 3, 3, 3, 3, 2, 2, 1, 1, 'd12', NULL, NULL, NULL, NULL);

-- Clerc (54)
INSERT INTO dd_classe_niveau
  (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte,
   cn_sortPrepare, cn_sort_n0, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4,
   cn_sort_n5, cn_sort_n6, cn_sort_n7, cn_sort_n8, cn_sort_n9,
   cn_pouvoir1, cn_pouvoir2, cn_pouvoir3, cn_pouvoir4, cn_pouvoir5)
VALUES
  (54,  1, '2', 0, 0, 0,  4, 3, 2, 0, 0, 0, 0, 0, 0, 0, 0, '—', NULL, NULL, NULL, NULL),
  (54,  2, '2', 0, 0, 0,  5, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, '2', NULL, NULL, NULL, NULL),
  (54,  3, '2', 0, 0, 0,  6, 3, 4, 2, 0, 0, 0, 0, 0, 0, 0, '2', NULL, NULL, NULL, NULL),
  (54,  4, '2', 0, 0, 0,  7, 4, 4, 3, 0, 0, 0, 0, 0, 0, 0, '2', NULL, NULL, NULL, NULL),
  (54,  5, '3', 0, 0, 0,  9, 4, 4, 3, 2, 0, 0, 0, 0, 0, 0, '2', NULL, NULL, NULL, NULL),
  (54,  6, '3', 0, 0, 0, 10, 4, 4, 3, 3, 0, 0, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (54,  7, '3', 0, 0, 0, 11, 4, 4, 3, 3, 1, 0, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (54,  8, '3', 0, 0, 0, 12, 4, 4, 3, 3, 2, 0, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (54,  9, '4', 0, 0, 0, 14, 4, 4, 3, 3, 3, 1, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (54, 10, '4', 0, 0, 0, 15, 5, 4, 3, 3, 3, 2, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (54, 11, '4', 0, 0, 0, 16, 5, 4, 3, 3, 3, 2, 1, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (54, 12, '4', 0, 0, 0, 16, 5, 4, 3, 3, 3, 2, 1, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (54, 13, '5', 0, 0, 0, 17, 5, 4, 3, 3, 3, 2, 1, 1, 0, 0, '3', NULL, NULL, NULL, NULL),
  (54, 14, '5', 0, 0, 0, 17, 5, 4, 3, 3, 3, 2, 1, 1, 0, 0, '3', NULL, NULL, NULL, NULL),
  (54, 15, '5', 0, 0, 0, 18, 5, 4, 3, 3, 3, 2, 1, 1, 1, 0, '3', NULL, NULL, NULL, NULL),
  (54, 16, '5', 0, 0, 0, 18, 5, 4, 3, 3, 3, 2, 1, 1, 1, 0, '3', NULL, NULL, NULL, NULL),
  (54, 17, '6', 0, 0, 0, 19, 5, 4, 3, 3, 3, 2, 1, 1, 1, 1, '3', NULL, NULL, NULL, NULL),
  (54, 18, '6', 0, 0, 0, 20, 5, 4, 3, 3, 3, 3, 1, 1, 1, 1, '4', NULL, NULL, NULL, NULL),
  (54, 19, '6', 0, 0, 0, 21, 5, 4, 3, 3, 3, 3, 2, 1, 1, 1, '4', NULL, NULL, NULL, NULL),
  (54, 20, '6', 0, 0, 0, 22, 5, 4, 3, 3, 3, 3, 2, 2, 1, 1, '4', NULL, NULL, NULL, NULL);

-- Druide (55)
INSERT INTO dd_classe_niveau
  (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte,
   cn_sortPrepare, cn_sort_n0, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4,
   cn_sort_n5, cn_sort_n6, cn_sort_n7, cn_sort_n8, cn_sort_n9,
   cn_pouvoir1, cn_pouvoir2, cn_pouvoir3, cn_pouvoir4, cn_pouvoir5)
VALUES
  (55,  1, '2', 0, 0, 0,  4, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, '—', NULL, NULL, NULL, NULL),
  (55,  2, '2', 0, 0, 0,  5, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0, '2', NULL, NULL, NULL, NULL),
  (55,  3, '2', 0, 0, 0,  6, 2, 4, 2, 0, 0, 0, 0, 0, 0, 0, '2', NULL, NULL, NULL, NULL),
  (55,  4, '2', 0, 0, 0,  7, 3, 4, 3, 0, 0, 0, 0, 0, 0, 0, '2', NULL, NULL, NULL, NULL),
  (55,  5, '3', 0, 0, 0,  9, 3, 4, 3, 2, 0, 0, 0, 0, 0, 0, '2', NULL, NULL, NULL, NULL),
  (55,  6, '3', 0, 0, 0, 10, 3, 4, 3, 3, 0, 0, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (55,  7, '3', 0, 0, 0, 11, 3, 4, 3, 3, 1, 0, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (55,  8, '3', 0, 0, 0, 12, 3, 4, 3, 3, 2, 0, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (55,  9, '4', 0, 0, 0, 14, 3, 4, 3, 3, 3, 1, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (55, 10, '4', 0, 0, 0, 15, 4, 4, 3, 3, 3, 2, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (55, 11, '4', 0, 0, 0, 16, 4, 4, 3, 3, 3, 2, 1, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (55, 12, '4', 0, 0, 0, 16, 4, 4, 3, 3, 3, 2, 1, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (55, 13, '5', 0, 0, 0, 17, 4, 4, 3, 3, 3, 2, 1, 1, 0, 0, '3', NULL, NULL, NULL, NULL),
  (55, 14, '5', 0, 0, 0, 17, 4, 4, 3, 3, 3, 2, 1, 1, 0, 0, '3', NULL, NULL, NULL, NULL),
  (55, 15, '5', 0, 0, 0, 18, 4, 4, 3, 3, 3, 2, 1, 1, 1, 0, '3', NULL, NULL, NULL, NULL),
  (55, 16, '5', 0, 0, 0, 18, 4, 4, 3, 3, 3, 2, 1, 1, 1, 0, '3', NULL, NULL, NULL, NULL),
  (55, 17, '6', 0, 0, 0, 19, 4, 4, 3, 3, 3, 2, 1, 1, 1, 1, '4', NULL, NULL, NULL, NULL),
  (55, 18, '6', 0, 0, 0, 20, 4, 4, 3, 3, 3, 3, 1, 1, 1, 1, '4', NULL, NULL, NULL, NULL),
  (55, 19, '6', 0, 0, 0, 21, 4, 4, 3, 3, 3, 3, 2, 1, 1, 1, '4', NULL, NULL, NULL, NULL),
  (55, 20, '6', 0, 0, 0, 22, 4, 4, 3, 3, 3, 3, 2, 2, 1, 1, '4', NULL, NULL, NULL, NULL);

-- Ensorceleur (56)
INSERT INTO dd_classe_niveau
  (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte,
   cn_sortPrepare, cn_sort_n0, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4,
   cn_sort_n5, cn_sort_n6, cn_sort_n7, cn_sort_n8, cn_sort_n9,
   cn_pouvoir1, cn_pouvoir2, cn_pouvoir3, cn_pouvoir4, cn_pouvoir5)
VALUES
  (56,  1, '2', 0, 0, 0,  2, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, '—', NULL, NULL, NULL, NULL),
  (56,  2, '2', 0, 0, 0,  4, 4, 3, 0, 0, 0, 0, 0, 0, 0, 0, '2', NULL, NULL, NULL, NULL),
  (56,  3, '2', 0, 0, 0,  6, 4, 4, 2, 0, 0, 0, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (56,  4, '2', 0, 0, 0,  7, 5, 4, 3, 0, 0, 0, 0, 0, 0, 0, '4', NULL, NULL, NULL, NULL),
  (56,  5, '3', 0, 0, 0,  9, 5, 4, 3, 2, 0, 0, 0, 0, 0, 0, '5', NULL, NULL, NULL, NULL),
  (56,  6, '3', 0, 0, 0, 10, 5, 4, 3, 3, 0, 0, 0, 0, 0, 0, '6', NULL, NULL, NULL, NULL),
  (56,  7, '3', 0, 0, 0, 11, 5, 4, 3, 3, 1, 0, 0, 0, 0, 0, '7', NULL, NULL, NULL, NULL),
  (56,  8, '3', 0, 0, 0, 12, 5, 4, 3, 3, 2, 0, 0, 0, 0, 0, '8', NULL, NULL, NULL, NULL),
  (56,  9, '4', 0, 0, 0, 14, 5, 4, 3, 3, 3, 1, 0, 0, 0, 0, '9', NULL, NULL, NULL, NULL),
  (56, 10, '4', 0, 0, 0, 15, 6, 4, 3, 3, 3, 2, 0, 0, 0, 0, '10', NULL, NULL, NULL, NULL),
  (56, 11, '4', 0, 0, 0, 16, 6, 4, 3, 3, 3, 2, 1, 0, 0, 0, '11', NULL, NULL, NULL, NULL),
  (56, 12, '4', 0, 0, 0, 16, 6, 4, 3, 3, 3, 2, 1, 0, 0, 0, '12', NULL, NULL, NULL, NULL),
  (56, 13, '5', 0, 0, 0, 17, 6, 4, 3, 3, 3, 2, 1, 1, 0, 0, '13', NULL, NULL, NULL, NULL),
  (56, 14, '5', 0, 0, 0, 17, 6, 4, 3, 3, 3, 2, 1, 1, 0, 0, '14', NULL, NULL, NULL, NULL),
  (56, 15, '5', 0, 0, 0, 18, 6, 4, 3, 3, 3, 2, 1, 1, 1, 0, '15', NULL, NULL, NULL, NULL),
  (56, 16, '5', 0, 0, 0, 18, 6, 4, 3, 3, 3, 2, 1, 1, 1, 0, '16', NULL, NULL, NULL, NULL),
  (56, 17, '6', 0, 0, 0, 19, 6, 4, 3, 3, 3, 2, 1, 1, 1, 1, '17', NULL, NULL, NULL, NULL),
  (56, 18, '6', 0, 0, 0, 20, 6, 4, 3, 3, 3, 3, 1, 1, 1, 1, '18', NULL, NULL, NULL, NULL),
  (56, 19, '6', 0, 0, 0, 21, 6, 4, 3, 3, 3, 3, 2, 1, 1, 1, '19', NULL, NULL, NULL, NULL),
  (56, 20, '6', 0, 0, 0, 22, 6, 4, 3, 3, 3, 3, 2, 2, 1, 1, '20', NULL, NULL, NULL, NULL);

-- Guerrier (50)
INSERT INTO dd_classe_niveau
  (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte,
   cn_sortPrepare, cn_sort_n0, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4,
   cn_sort_n5, cn_sort_n6, cn_sort_n7, cn_sort_n8, cn_sort_n9,
   cn_pouvoir1, cn_pouvoir2, cn_pouvoir3, cn_pouvoir4, cn_pouvoir5)
VALUES
  (50,  1, '2', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2', '3', NULL, NULL, NULL),
  (50,  2, '2', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2', '3', NULL, NULL, NULL),
  (50,  3, '2', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2', '3', NULL, NULL, NULL),
  (50,  4, '2', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '3', '4', NULL, NULL, NULL),
  (50,  5, '3', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '3', '4', NULL, NULL, NULL),
  (50,  6, '3', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '3', '4', NULL, NULL, NULL),
  (50,  7, '3', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '3', '4', NULL, NULL, NULL),
  (50,  8, '3', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '3', '4', NULL, NULL, NULL),
  (50,  9, '4', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '4', '4', NULL, NULL, NULL),
  (50, 10, '4', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '4', '5', NULL, NULL, NULL),
  (50, 11, '4', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '4', '5', NULL, NULL, NULL),
  (50, 12, '4', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '4', '5', NULL, NULL, NULL),
  (50, 13, '5', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '4', '5', NULL, NULL, NULL),
  (50, 14, '5', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '4', '5', NULL, NULL, NULL),
  (50, 15, '5', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '4', '5', NULL, NULL, NULL),
  (50, 16, '5', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '4', '6', NULL, NULL, NULL),
  (50, 17, '6', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '4', '6', NULL, NULL, NULL),
  (50, 18, '6', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '4', '6', NULL, NULL, NULL),
  (50, 19, '6', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '4', '6', NULL, NULL, NULL),
  (50, 20, '6', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '4', '6', NULL, NULL, NULL);

-- Magicien (52)
INSERT INTO dd_classe_niveau
  (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte,
   cn_sortPrepare, cn_sort_n0, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4,
   cn_sort_n5, cn_sort_n6, cn_sort_n7, cn_sort_n8, cn_sort_n9,
   cn_pouvoir1, cn_pouvoir2, cn_pouvoir3, cn_pouvoir4, cn_pouvoir5)
VALUES
  (52,  1, '2', 0, 0, 0,  4, 3, 2, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL),
  (52,  2, '2', 0, 0, 0,  5, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL),
  (52,  3, '2', 0, 0, 0,  6, 3, 4, 2, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL),
  (52,  4, '2', 0, 0, 0,  7, 4, 4, 3, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL),
  (52,  5, '3', 0, 0, 0,  9, 4, 4, 3, 2, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL),
  (52,  6, '3', 0, 0, 0, 10, 4, 4, 3, 3, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL),
  (52,  7, '3', 0, 0, 0, 11, 4, 4, 3, 3, 1, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL),
  (52,  8, '3', 0, 0, 0, 12, 4, 4, 3, 3, 2, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL),
  (52,  9, '4', 0, 0, 0, 14, 4, 4, 3, 3, 3, 1, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL),
  (52, 10, '4', 0, 0, 0, 15, 5, 4, 3, 3, 3, 2, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL),
  (52, 11, '4', 0, 0, 0, 16, 5, 4, 3, 3, 3, 2, 1, 0, 0, 0, NULL, NULL, NULL, NULL, NULL),
  (52, 12, '4', 0, 0, 0, 16, 5, 4, 3, 3, 3, 2, 1, 0, 0, 0, NULL, NULL, NULL, NULL, NULL),
  (52, 13, '5', 0, 0, 0, 17, 5, 4, 3, 3, 3, 2, 1, 1, 0, 0, NULL, NULL, NULL, NULL, NULL),
  (52, 14, '5', 0, 0, 0, 18, 5, 4, 3, 3, 3, 2, 1, 1, 0, 0, NULL, NULL, NULL, NULL, NULL),
  (52, 15, '5', 0, 0, 0, 19, 5, 4, 3, 3, 3, 2, 1, 1, 1, 0, NULL, NULL, NULL, NULL, NULL),
  (52, 16, '5', 0, 0, 0, 21, 5, 4, 3, 3, 3, 2, 1, 1, 1, 0, NULL, NULL, NULL, NULL, NULL),
  (52, 17, '6', 0, 0, 0, 22, 5, 4, 3, 3, 3, 2, 1, 1, 1, 1, NULL, NULL, NULL, NULL, NULL),
  (52, 18, '6', 0, 0, 0, 23, 5, 4, 3, 3, 3, 3, 1, 1, 1, 1, NULL, NULL, NULL, NULL, NULL),
  (52, 19, '6', 0, 0, 0, 24, 5, 4, 3, 3, 3, 3, 2, 1, 1, 1, NULL, NULL, NULL, NULL, NULL),
  (52, 20, '6', 0, 0, 0, 25, 5, 4, 3, 3, 3, 3, 2, 2, 1, 1, NULL, NULL, NULL, NULL, NULL);

-- Moine (57)
INSERT INTO dd_classe_niveau
  (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte,
   cn_sortPrepare, cn_sort_n0, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4,
   cn_sort_n5, cn_sort_n6, cn_sort_n7, cn_sort_n8, cn_sort_n9,
   cn_pouvoir1, cn_pouvoir2, cn_pouvoir3, cn_pouvoir4, cn_pouvoir5)
VALUES
  (57,  1, '2', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d6', '—', '—', NULL, NULL),
  (57,  2, '2', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d6', '2', '+3 m', NULL, NULL),
  (57,  3, '2', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d6', '3', '+3 m', NULL, NULL),
  (57,  4, '2', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d6', '4', '+3 m', NULL, NULL),
  (57,  5, '3', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d8', '5', '+3 m', NULL, NULL),
  (57,  6, '3', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d8', '6', '+4,50 m', NULL, NULL),
  (57,  7, '3', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d8', '7', '+4,50 m', NULL, NULL),
  (57,  8, '3', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d8', '8', '+4,50 m', NULL, NULL),
  (57,  9, '4', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d8', '9', '+4,50 m', NULL, NULL),
  (57, 10, '4', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d8', '10', '+6 m', NULL, NULL),
  (57, 11, '4', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d10', '11', '+6 m', NULL, NULL),
  (57, 12, '4', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d10', '12', '+6 m', NULL, NULL),
  (57, 13, '5', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d10', '13', '+6 m', NULL, NULL),
  (57, 14, '5', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d10', '14', '+7,50 m', NULL, NULL),
  (57, 15, '5', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d10', '15', '+7,50 m', NULL, NULL),
  (57, 16, '5', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d10', '16', '+7,50 m', NULL, NULL),
  (57, 17, '6', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d12', '17', '+7,50 m', NULL, NULL),
  (57, 18, '6', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d12', '18', '+9 m', NULL, NULL),
  (57, 19, '6', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d12', '19', '+9 m', NULL, NULL),
  (57, 20, '6', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d12', '20', '+9 m', NULL, NULL);

-- Occultiste (58)
INSERT INTO dd_classe_niveau
  (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte,
   cn_sortPrepare, cn_sort_n0, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4,
   cn_sort_n5, cn_sort_n6, cn_sort_n7, cn_sort_n8, cn_sort_n9,
   cn_pouvoir1, cn_pouvoir2, cn_pouvoir3, cn_pouvoir4, cn_pouvoir5)
VALUES
  (58,  1, '2', 0, 0, 0,  2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1', '1', '1', NULL, NULL),
  (58,  2, '2', 0, 0, 0,  3, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, '3', '2', '1', NULL, NULL),
  (58,  3, '2', 0, 0, 0,  4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, '3', '2', '2', NULL, NULL),
  (58,  4, '2', 0, 0, 0,  5, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '3', '2', '2', NULL, NULL),
  (58,  5, '3', 0, 0, 0,  6, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '5', '2', '3', NULL, NULL),
  (58,  6, '3', 0, 0, 0,  7, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '5', '2', '3', NULL, NULL),
  (58,  7, '3', 0, 0, 0,  8, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '6', '2', '4', NULL, NULL),
  (58,  8, '3', 0, 0, 0,  9, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '6', '2', '4', NULL, NULL),
  (58,  9, '4', 0, 0, 0, 10, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '7', '2', '5', NULL, NULL),
  (58, 10, '4', 0, 0, 0, 10, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, '7', '2', '5', NULL, NULL),
  (58, 11, '4', 0, 0, 0, 11, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, '7', '3', '5', NULL, NULL),
  (58, 12, '4', 0, 0, 0, 11, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, '8', '3', '5', NULL, NULL),
  (58, 13, '5', 0, 0, 0, 12, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, '8', '3', '5', NULL, NULL),
  (58, 14, '5', 0, 0, 0, 12, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, '8', '3', '5', NULL, NULL),
  (58, 15, '5', 0, 0, 0, 13, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, '9', '3', '5', NULL, NULL),
  (58, 16, '5', 0, 0, 0, 13, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, '9', '3', '5', NULL, NULL),
  (58, 17, '6', 0, 0, 0, 14, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, '9', '4', '5', NULL, NULL),
  (58, 18, '6', 0, 0, 0, 14, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, '10', '4', '5', NULL, NULL),
  (58, 19, '6', 0, 0, 0, 15, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, '10', '4', '5', NULL, NULL),
  (58, 20, '6', 0, 0, 0, 15, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, '10', '4', '5', NULL, NULL);

-- Paladin (59)
INSERT INTO dd_classe_niveau
  (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte,
   cn_sortPrepare, cn_sort_n0, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4,
   cn_sort_n5, cn_sort_n6, cn_sort_n7, cn_sort_n8, cn_sort_n9,
   cn_pouvoir1, cn_pouvoir2, cn_pouvoir3, cn_pouvoir4, cn_pouvoir5)
VALUES
  (59,  1, '2', 0, 0, 0,  2, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, '—', NULL, NULL, NULL, NULL),
  (59,  2, '2', 0, 0, 0,  3, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, '—', NULL, NULL, NULL, NULL),
  (59,  3, '2', 0, 0, 0,  4, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, '2', NULL, NULL, NULL, NULL),
  (59,  4, '2', 0, 0, 0,  5, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, '2', NULL, NULL, NULL, NULL),
  (59,  5, '3', 0, 0, 0,  6, 0, 4, 2, 0, 0, 0, 0, 0, 0, 0, '2', NULL, NULL, NULL, NULL),
  (59,  6, '3', 0, 0, 0,  6, 0, 4, 2, 0, 0, 0, 0, 0, 0, 0, '2', NULL, NULL, NULL, NULL),
  (59,  7, '3', 0, 0, 0,  7, 0, 4, 3, 0, 0, 0, 0, 0, 0, 0, '2', NULL, NULL, NULL, NULL),
  (59,  8, '3', 0, 0, 0,  7, 0, 4, 3, 0, 0, 0, 0, 0, 0, 0, '2', NULL, NULL, NULL, NULL),
  (59,  9, '4', 0, 0, 0,  9, 0, 4, 3, 2, 0, 0, 0, 0, 0, 0, '2', NULL, NULL, NULL, NULL),
  (59, 10, '4', 0, 0, 0,  9, 0, 4, 3, 2, 0, 0, 0, 0, 0, 0, '2', NULL, NULL, NULL, NULL),
  (59, 11, '4', 0, 0, 0, 10, 0, 4, 3, 3, 0, 0, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (59, 12, '4', 0, 0, 0, 10, 0, 4, 3, 3, 0, 0, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (59, 13, '5', 0, 0, 0, 11, 0, 4, 3, 3, 1, 0, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (59, 14, '5', 0, 0, 0, 11, 0, 4, 3, 3, 1, 0, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (59, 15, '5', 0, 0, 0, 12, 0, 4, 3, 3, 2, 0, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (59, 16, '5', 0, 0, 0, 12, 0, 4, 3, 3, 2, 0, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (59, 17, '6', 0, 0, 0, 14, 0, 4, 3, 3, 3, 1, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (59, 18, '6', 0, 0, 0, 14, 0, 4, 3, 3, 3, 1, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (59, 19, '6', 0, 0, 0, 15, 0, 4, 3, 3, 3, 2, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (59, 20, '6', 0, 0, 0, 15, 0, 4, 3, 3, 3, 2, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL);

-- Rôdeur (60)
INSERT INTO dd_classe_niveau
  (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte,
   cn_sortPrepare, cn_sort_n0, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4,
   cn_sort_n5, cn_sort_n6, cn_sort_n7, cn_sort_n8, cn_sort_n9,
   cn_pouvoir1, cn_pouvoir2, cn_pouvoir3, cn_pouvoir4, cn_pouvoir5)
VALUES
  (60,  1, '2', 0, 0, 0,  2, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, '2', NULL, NULL, NULL, NULL),
  (60,  2, '2', 0, 0, 0,  3, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, '2', NULL, NULL, NULL, NULL),
  (60,  3, '2', 0, 0, 0,  4, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, '2', NULL, NULL, NULL, NULL),
  (60,  4, '2', 0, 0, 0,  5, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, '2', NULL, NULL, NULL, NULL),
  (60,  5, '3', 0, 0, 0,  6, 0, 4, 2, 0, 0, 0, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (60,  6, '3', 0, 0, 0,  6, 0, 4, 2, 0, 0, 0, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (60,  7, '3', 0, 0, 0,  7, 0, 4, 3, 0, 0, 0, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (60,  8, '3', 0, 0, 0,  7, 0, 4, 3, 0, 0, 0, 0, 0, 0, 0, '3', NULL, NULL, NULL, NULL),
  (60,  9, '4', 0, 0, 0,  9, 0, 4, 3, 2, 0, 0, 0, 0, 0, 0, '4', NULL, NULL, NULL, NULL),
  (60, 10, '4', 0, 0, 0,  9, 0, 4, 3, 2, 0, 0, 0, 0, 0, 0, '4', NULL, NULL, NULL, NULL),
  (60, 11, '4', 0, 0, 0, 10, 0, 4, 3, 3, 0, 0, 0, 0, 0, 0, '4', NULL, NULL, NULL, NULL),
  (60, 12, '4', 0, 0, 0, 10, 0, 4, 3, 3, 0, 0, 0, 0, 0, 0, '4', NULL, NULL, NULL, NULL),
  (60, 13, '5', 0, 0, 0, 11, 0, 4, 3, 3, 1, 0, 0, 0, 0, 0, '5', NULL, NULL, NULL, NULL),
  (60, 14, '5', 0, 0, 0, 11, 0, 4, 3, 3, 1, 0, 0, 0, 0, 0, '5', NULL, NULL, NULL, NULL),
  (60, 15, '5', 0, 0, 0, 12, 0, 4, 3, 3, 2, 0, 0, 0, 0, 0, '5', NULL, NULL, NULL, NULL),
  (60, 16, '5', 0, 0, 0, 12, 0, 4, 3, 3, 2, 0, 0, 0, 0, 0, '5', NULL, NULL, NULL, NULL),
  (60, 17, '6', 0, 0, 0, 14, 0, 4, 3, 3, 3, 1, 0, 0, 0, 0, '6', NULL, NULL, NULL, NULL),
  (60, 18, '6', 0, 0, 0, 14, 0, 4, 3, 3, 3, 1, 0, 0, 0, 0, '6', NULL, NULL, NULL, NULL),
  (60, 19, '6', 0, 0, 0, 15, 0, 4, 3, 3, 3, 2, 0, 0, 0, 0, '6', NULL, NULL, NULL, NULL),
  (60, 20, '6', 0, 0, 0, 15, 0, 4, 3, 3, 3, 2, 0, 0, 0, 0, '6', NULL, NULL, NULL, NULL);

-- Roublard (61)
INSERT INTO dd_classe_niveau
  (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte,
   cn_sortPrepare, cn_sort_n0, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4,
   cn_sort_n5, cn_sort_n6, cn_sort_n7, cn_sort_n8, cn_sort_n9,
   cn_pouvoir1, cn_pouvoir2, cn_pouvoir3, cn_pouvoir4, cn_pouvoir5)
VALUES
  (61,  1, '2', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d6', NULL, NULL, NULL, NULL),
  (61,  2, '2', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1d6', NULL, NULL, NULL, NULL),
  (61,  3, '2', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2d6', NULL, NULL, NULL, NULL),
  (61,  4, '2', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2d6', NULL, NULL, NULL, NULL),
  (61,  5, '3', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '3d6', NULL, NULL, NULL, NULL),
  (61,  6, '3', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '3d6', NULL, NULL, NULL, NULL),
  (61,  7, '3', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '4d6', NULL, NULL, NULL, NULL),
  (61,  8, '3', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '4d6', NULL, NULL, NULL, NULL),
  (61,  9, '4', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '5d6', NULL, NULL, NULL, NULL),
  (61, 10, '4', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '5d6', NULL, NULL, NULL, NULL),
  (61, 11, '4', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '6d6', NULL, NULL, NULL, NULL),
  (61, 12, '4', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '6d6', NULL, NULL, NULL, NULL),
  (61, 13, '5', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '7d6', NULL, NULL, NULL, NULL),
  (61, 14, '5', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '7d6', NULL, NULL, NULL, NULL),
  (61, 15, '5', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '8d6', NULL, NULL, NULL, NULL),
  (61, 16, '5', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '8d6', NULL, NULL, NULL, NULL),
  (61, 17, '6', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '9d6', NULL, NULL, NULL, NULL),
  (61, 18, '6', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '9d6', NULL, NULL, NULL, NULL),
  (61, 19, '6', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '10d6', NULL, NULL, NULL, NULL),
  (61, 20, '6', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '10d6', NULL, NULL, NULL, NULL);

-- ------------------------------------------------------------
-- Intitulés des colonnes de pouvoir (cla_pouvoir1..5), alignés
-- sur les en-têtes de colonne des tables « Aptitudes du <classe> ».
-- ------------------------------------------------------------

UPDATE dd_classes SET cla_pouvoir1 = 'Rages',                   cla_pouvoir2 = 'Dégâts de Rage',      cla_pouvoir3 = 'Bottes d’arme',          cla_pouvoir4 = NULL, cla_pouvoir5 = NULL WHERE cla_id = 51;
UPDATE dd_classes SET cla_pouvoir1 = 'Dé bardique',             cla_pouvoir2 = NULL,                   cla_pouvoir3 = NULL,                      cla_pouvoir4 = NULL, cla_pouvoir5 = NULL WHERE cla_id = 53;
UPDATE dd_classes SET cla_pouvoir1 = 'Conduit divin',           cla_pouvoir2 = NULL,                   cla_pouvoir3 = NULL,                      cla_pouvoir4 = NULL, cla_pouvoir5 = NULL WHERE cla_id = 54;
UPDATE dd_classes SET cla_pouvoir1 = 'Forme sauvage',           cla_pouvoir2 = NULL,                   cla_pouvoir3 = NULL,                      cla_pouvoir4 = NULL, cla_pouvoir5 = NULL WHERE cla_id = 55;
UPDATE dd_classes SET cla_pouvoir1 = 'Points de Sorcellerie',   cla_pouvoir2 = NULL,                   cla_pouvoir3 = NULL,                      cla_pouvoir4 = NULL, cla_pouvoir5 = NULL WHERE cla_id = 56;
UPDATE dd_classes SET cla_pouvoir1 = 'Second souffle',          cla_pouvoir2 = 'Bottes d’arme',        cla_pouvoir3 = NULL,                      cla_pouvoir4 = NULL, cla_pouvoir5 = NULL WHERE cla_id = 50;
UPDATE dd_classes SET cla_pouvoir1 = NULL,                      cla_pouvoir2 = NULL,                   cla_pouvoir3 = NULL,                      cla_pouvoir4 = NULL, cla_pouvoir5 = NULL WHERE cla_id = 52;
UPDATE dd_classes SET cla_pouvoir1 = 'Arts martiaux',           cla_pouvoir2 = 'Points de Credo',      cla_pouvoir3 = 'Déplacement sans armure', cla_pouvoir4 = NULL, cla_pouvoir5 = NULL WHERE cla_id = 57;
UPDATE dd_classes SET cla_pouvoir1 = 'Manifestations occultes', cla_pouvoir2 = 'Emplacements de sort', cla_pouvoir3 = 'Niveau des emplacements', cla_pouvoir4 = NULL, cla_pouvoir5 = NULL WHERE cla_id = 58;
UPDATE dd_classes SET cla_pouvoir1 = 'Conduit divin',           cla_pouvoir2 = NULL,                   cla_pouvoir3 = NULL,                      cla_pouvoir4 = NULL, cla_pouvoir5 = NULL WHERE cla_id = 59;
UPDATE dd_classes SET cla_pouvoir1 = 'Ennemi juré',             cla_pouvoir2 = NULL,                   cla_pouvoir3 = NULL,                      cla_pouvoir4 = NULL, cla_pouvoir5 = NULL WHERE cla_id = 60;
UPDATE dd_classes SET cla_pouvoir1 = 'Attaque sournoise',       cla_pouvoir2 = NULL,                   cla_pouvoir3 = NULL,                      cla_pouvoir4 = NULL, cla_pouvoir5 = NULL WHERE cla_id = 61;
