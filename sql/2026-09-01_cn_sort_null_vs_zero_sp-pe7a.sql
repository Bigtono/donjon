-- sql/2026-09-01_cn_sort_null_vs_zero_sp-pe7a.sql
-- SP-PE7a — Rétablit la distinction NULL / 0 dans dd_classe_niveau (DD3.5).
--
-- LE SRD 3.5 DONNE DEUX SENS OPPOSÉS À CES DEUX VALEURS :
--   « — »  le niveau de sort est INACCESSIBLE : ni emplacement, ni sort bonus,
--          ni emplacement de domaine.
--   « 0 »  le niveau est accessible mais SEULEMENT par les sorts en bonus —
--          « Quand la table indique que le barde peut lancer "0" sort d'un
--            niveau, il ne peut lancer que les sorts en bonus pour ce niveau
--            que peut lui accorder une valeur de Charisme élevée. »
--
-- CONSTAT (relevé du 2026-09-01, en écrivant getMagieContexte) : la convention
-- n'est pas tenue uniformément.
--   * Barde, Paladin, Rôdeur, Assassin, Chevalier noir, Tueur de Domiel :
--     4 à 6 « 0 » chacun, tous LÉGITIMES — ce sont les vrais « 0 » du SRD.
--   * Druide, Ensorceleur, Magicien : NULL partout, corrects.
--   * PRÊTRE (72 cellules) et ÉLU DIVIN (80) : « 0 » PARTOUT, y compris là où
--     le SRD écrit « — ». Un prêtre de niveau 6 se voyait ainsi accorder un
--     emplacement de 4e niveau qu'il ne peut pas lancer, sur la seule foi de
--     son bonus de Sagesse.
--
-- CORRECTIF. Pour ces deux classes seulement, les « 0 » situés AU-DELÀ du plus
-- haut niveau de sort réellement accessible à ce niveau de classe repassent à
-- NULL. Les « 0 » intercalés — s'il en existait — sont préservés : la requête
-- ne touche qu'au-delà du dernier niveau non nul.
--
-- IDEMPOTENT : rejouable, la seconde passe ne trouve plus de 0 à convertir.
-- Vérification :
--   SELECT COUNT(*) FROM dd_classe_niveau cn JOIN dd_classes c ON c.cla_id=cn.cn_cla_id
--   WHERE c.cla_ruleset_var_id=1 AND c.cla_mag_id>0 AND cn.cn_sort_n9 = 0;

UPDATE dd_classe_niveau SET cn_sort_n9 = NULL
WHERE  cn_cla_id IN (9, 48) AND cn_sort_n9 = 0;

UPDATE dd_classe_niveau SET cn_sort_n8 = NULL
WHERE  cn_cla_id IN (9, 48) AND cn_sort_n8 = 0 AND COALESCE(cn_sort_n9,0) = 0;

UPDATE dd_classe_niveau SET cn_sort_n7 = NULL
WHERE  cn_cla_id IN (9, 48) AND cn_sort_n7 = 0 AND COALESCE(cn_sort_n8,0) = 0 AND COALESCE(cn_sort_n9,0) = 0;

UPDATE dd_classe_niveau SET cn_sort_n6 = NULL
WHERE  cn_cla_id IN (9, 48) AND cn_sort_n6 = 0 AND COALESCE(cn_sort_n7,0) = 0 AND COALESCE(cn_sort_n8,0) = 0 AND COALESCE(cn_sort_n9,0) = 0;

UPDATE dd_classe_niveau SET cn_sort_n5 = NULL
WHERE  cn_cla_id IN (9, 48) AND cn_sort_n5 = 0 AND COALESCE(cn_sort_n6,0) = 0 AND COALESCE(cn_sort_n7,0) = 0 AND COALESCE(cn_sort_n8,0) = 0 AND COALESCE(cn_sort_n9,0) = 0;

UPDATE dd_classe_niveau SET cn_sort_n4 = NULL
WHERE  cn_cla_id IN (9, 48) AND cn_sort_n4 = 0 AND COALESCE(cn_sort_n5,0) = 0 AND COALESCE(cn_sort_n6,0) = 0 AND COALESCE(cn_sort_n7,0) = 0 AND COALESCE(cn_sort_n8,0) = 0 AND COALESCE(cn_sort_n9,0) = 0;

UPDATE dd_classe_niveau SET cn_sort_n3 = NULL
WHERE  cn_cla_id IN (9, 48) AND cn_sort_n3 = 0 AND COALESCE(cn_sort_n4,0) = 0 AND COALESCE(cn_sort_n5,0) = 0 AND COALESCE(cn_sort_n6,0) = 0 AND COALESCE(cn_sort_n7,0) = 0 AND COALESCE(cn_sort_n8,0) = 0 AND COALESCE(cn_sort_n9,0) = 0;

UPDATE dd_classe_niveau SET cn_sort_n2 = NULL
WHERE  cn_cla_id IN (9, 48) AND cn_sort_n2 = 0 AND COALESCE(cn_sort_n3,0) = 0 AND COALESCE(cn_sort_n4,0) = 0 AND COALESCE(cn_sort_n5,0) = 0 AND COALESCE(cn_sort_n6,0) = 0 AND COALESCE(cn_sort_n7,0) = 0 AND COALESCE(cn_sort_n8,0) = 0 AND COALESCE(cn_sort_n9,0) = 0;

UPDATE dd_classe_niveau SET cn_sort_n1 = NULL
WHERE  cn_cla_id IN (9, 48) AND cn_sort_n1 = 0 AND COALESCE(cn_sort_n2,0) = 0 AND COALESCE(cn_sort_n3,0) = 0 AND COALESCE(cn_sort_n4,0) = 0 AND COALESCE(cn_sort_n5,0) = 0 AND COALESCE(cn_sort_n6,0) = 0 AND COALESCE(cn_sort_n7,0) = 0 AND COALESCE(cn_sort_n8,0) = 0 AND COALESCE(cn_sort_n9,0) = 0;
