-- 2026-10-10_drapeaux_nls_sp-ma6.sql
-- SP-MA6 — Classes de prestige DD3.5 : sorts propres OU progression du NLS.
--
-- Une classe de prestige lanceuse se comporte de l'une de deux façons,
-- exclusives : elle accorde ses propres sorts par jour (cn_sort_n0..9, ex. Tueur
-- de Domiel), ou elle fait avancer le niveau de lanceur d'une classe de base
-- (drapeaux cn_niveauSortArcane / Divin / Effectif, ex. Archimage).
--
-- 1. Les trois drapeaux valent 0 ou 1 ; NULL n'y a pas de sens distinct de 0.
--    Les colonnes restent nullables : seules les VALEURS sont normalisées.
--
-- 2. Les classes de prestige du second cas portaient des sorts par jour à 0
--    (Adepte de l'ombre, Gardien du feu sacré du Phénix, Olin Gisir). Or un 0
--    ne se lit pas comme une absence : il signifie « niveau accessible par les
--    seuls sorts en bonus ». Ces colonnes passent à NULL, comme le fait
--    désormais l'enregistrement d'une classe en mode « Progression du NLS ».
--    Condition : prestige DD3.5, non lanceuse (cla_mag_id = 0), au moins un
--    drapeau levé. Une prestige à sorts propres (Assassin, Chevalier noir,
--    Tueur de Domiel) n'est pas concernée.

UPDATE dd_classe_niveau SET cn_niveauSortArcane   = 0 WHERE cn_niveauSortArcane   IS NULL;
UPDATE dd_classe_niveau SET cn_niveauSortDivin    = 0 WHERE cn_niveauSortDivin    IS NULL;
UPDATE dd_classe_niveau SET cn_niveauSortEffectif = 0 WHERE cn_niveauSortEffectif IS NULL;

UPDATE dd_classe_niveau cn
  JOIN dd_classes c ON c.cla_id = cn.cn_cla_id
  JOIN (
    SELECT cn_cla_id
      FROM dd_classe_niveau
  GROUP BY cn_cla_id
    HAVING SUM(cn_niveauSortArcane + cn_niveauSortDivin + cn_niveauSortEffectif) > 0
  ) f ON f.cn_cla_id = cn.cn_cla_id
   SET cn.cn_sort_n0 = NULL, cn.cn_sort_n1 = NULL, cn.cn_sort_n2 = NULL,
       cn.cn_sort_n3 = NULL, cn.cn_sort_n4 = NULL, cn.cn_sort_n5 = NULL,
       cn.cn_sort_n6 = NULL, cn.cn_sort_n7 = NULL, cn.cn_sort_n8 = NULL,
       cn.cn_sort_n9 = NULL,
       cn.cn_sortConnu_n0 = NULL, cn.cn_sortConnu_n1 = NULL, cn.cn_sortConnu_n2 = NULL,
       cn.cn_sortConnu_n3 = NULL, cn.cn_sortConnu_n4 = NULL, cn.cn_sortConnu_n5 = NULL,
       cn.cn_sortConnu_n6 = NULL, cn.cn_sortConnu_n7 = NULL, cn.cn_sortConnu_n8 = NULL,
       cn.cn_sortConnu_n9 = NULL
 WHERE c.cla_ruleset_var_id = 1
   AND c.cla_clt_id = 2
   AND c.cla_mag_id = 0;
