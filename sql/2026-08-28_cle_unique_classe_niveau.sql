-- sql/2026-08-28_cle_unique_classe_niveau.sql
-- Clé unique manquante sur dd_classe_niveau.
--
-- SCHEMA_SQL.md documente « UK(cn_cla_id, cn_niveau) » sur cette table depuis
-- toujours. CETTE CLÉ N'EXISTAIT PAS : seule la PRIMARY sur cn_id était posée.
--
-- Constaté à la dure le 2026-08-28 : un INSERT ... ON DUPLICATE KEY UPDATE sur
-- cette table se comporte en INSERT pur et crée des doublons silencieux
-- (40 lignes pour 20 niveaux). Rien dans l'application ne le détecte : les
-- écrans affichent alors chaque niveau deux fois, ou l'une des deux versions
-- au hasard selon l'ORDER BY.
--
-- Troisième écart relevé entre SCHEMA_SQL.md et la base réelle, après mo_j_id
-- et patch_004_supplements.sql.
--
-- PRÉALABLE — vérifier qu'aucun doublon ne bloque la création :
--   SELECT cn_cla_id, cn_niveau, COUNT(*) FROM dd_classe_niveau
--   GROUP BY cn_cla_id, cn_niveau HAVING COUNT(*) > 1;
--   -- doit ne rien renvoyer ; sinon dédoublonner avant de poursuivre.
--
-- IDEMPOTENCE : non rejouable (l'ALTER échoue si la clé existe déjà). Vérifier :
--   SHOW INDEX FROM dd_classe_niveau WHERE Key_name = 'uk_cn_classe_niveau';

ALTER TABLE dd_classe_niveau
  ADD UNIQUE KEY uk_cn_classe_niveau (cn_cla_id, cn_niveau);
