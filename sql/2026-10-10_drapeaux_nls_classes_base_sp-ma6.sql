-- 2026-10-10_drapeaux_nls_classes_base_sp-ma6.sql
-- SP-MA6 — Les drapeaux de progression du NLS ne concernent que les classes de
-- prestige DD3.5 : ils disent qu'un niveau de prestige fait gagner un niveau de
-- lanceur à une classe de base.
--
-- Les six classes de base lanceuses DD3.5 (Barde, Druide, Ensorceleur,
-- Magicien, Prêtre, Rôdeur) en portaient un à 1 sur chacun de leurs niveaux :
-- erreur de saisie, sans effet jusqu'ici (seuls les drapeaux des prestiges sont
-- lus), mais contraire à la règle. Remis à 0 pour toute classe qui n'est pas
-- une prestige, quel que soit le ruleset.

UPDATE dd_classe_niveau cn
  JOIN dd_classes c ON c.cla_id = cn.cn_cla_id
   SET cn.cn_niveauSortArcane = 0,
       cn.cn_niveauSortDivin = 0,
       cn.cn_niveauSortEffectif = 0
 WHERE c.cla_clt_id <> 2
   AND (cn.cn_niveauSortArcane <> 0 OR cn.cn_niveauSortDivin <> 0 OR cn.cn_niveauSortEffectif <> 0);
