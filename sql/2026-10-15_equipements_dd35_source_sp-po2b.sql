-- sql/2026-10-15_equipements_dd35_source_sp-po2b.sql
-- SP-PO2b — Source des équipements DD3.5 : Manuel des joueurs 3.5 (« MdJ3.5 »), et non « DRS 3.5 ».
--
-- Contexte : 2026-10-11_equipements_dd35_drs07_sp-po2.sql importe les 269 articles du DRS 07 sous la
-- ressource « DRS 3.5 ». Ces données sont aussi celles du Manuel des joueurs : en local, la source a été
-- corrigée à la main (le 2026-10-15). Cette migration aligne les autres environnements (production).
--
-- Idempotente : ne touche que les articles encore rattachés à « DRS 3.5 » ; en local, où ils sont déjà
-- sous « MdJ3.5 », elle ne modifie rien. Ressources retrouvées par abréviation (les ids diffèrent
-- entre local et OVH). Si « MdJ3.5 » n'existe pas dans l'environnement, rien n'est modifié.
-- La migration du 2026-10-11 reste inchangée : ne pas la rejouer après celle-ci (elle recréerait les
-- articles sous « DRS 3.5 »).

SET NAMES utf8mb4;

SET @ddver := (SELECT var_id FROM dd_variables WHERE var_cat = 'ruleset' AND var_valeur = 'DD3.5' LIMIT 1);
SET @drs   := (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'DRS 3.5' AND res_ruleset_var_id = @ddver LIMIT 1);
SET @mdj   := (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' AND res_ruleset_var_id = @ddver AND res_j_id IS NULL LIMIT 1);

UPDATE dd_equipements
SET    eqt_res_id = @mdj
WHERE  @mdj IS NOT NULL AND @drs IS NOT NULL
  AND  eqt_res_id = @drs
  AND  eqt_ruleset_var_id = @ddver;
