-- sql/2026-11-11_sp-re1_sources_simplifiees.sql
-- SP-RE1 — Refonte de la sélection des ressources (D-RE1 → D-RE6)
--
-- Les sélections de sources par utilisateur (dd_joueurs_sources) et par campagne
-- (dd_campagnes_sources) sont abandonnées : le compendium montre toutes les ressources
-- ACTIVES du ruleset (res_selection = 1, gérées par l'admin), plus les suppléments de MJ.
--
-- j_supplement_public : réglage de profil du MJ — 1 = son supplément est vu de tous,
--                        0 = privé (lui et les admins, plus les joueurs de ses campagnes).
--                        Remplace les drapeaux _public par entrée (colonnes laissées, ignorées).
-- j_voir_supplements  : préférence de profil — 1 = les listes du compendium affichent par
--                        défaut les suppléments de MJ publics.
--
-- Reprise :
--   - supplément public si le propriétaire avait au moins une entrée _public = 1 ;
--   - mode campagne activé pour tout propriétaire d'un supplément (le MJ = j_mode_campagne,
--     seul un MJ peut éditer son supplément).
-- Les tables dd_joueurs_sources / dd_campagnes_sources sont CONSERVÉES (suppression : SP-RE7).
-- NON IDEMPOTENT (ALTER TABLE) : jouée une seule fois par le moteur. Pas de DELIMITER.

SET NAMES utf8mb4;

ALTER TABLE dd_joueurs
  ADD COLUMN j_supplement_public TINYINT(1) NOT NULL DEFAULT 0
    COMMENT 'Supplément du MJ : 1 = public, 0 = privé — SP-RE1'
    AFTER j_mode_campagne,
  ADD COLUMN j_voir_supplements TINYINT(1) NOT NULL DEFAULT 0
    COMMENT 'Listes du compendium : afficher par défaut les suppléments de MJ — SP-RE1'
    AFTER j_supplement_public;

UPDATE dd_joueurs j
   SET j.j_supplement_public = 1
 WHERE j.j_id IN (
   SELECT res.res_j_id FROM dd_ressources res
    WHERE res.res_j_id IS NOT NULL
      AND (
           EXISTS (SELECT 1 FROM dd_sorts           x WHERE x.so_res_id   = res.res_id AND x.so_public   = 1)
        OR EXISTS (SELECT 1 FROM dd_classes         x WHERE x.cla_res_id  = res.res_id AND x.cla_public  = 1)
        OR EXISTS (SELECT 1 FROM dd_races           x WHERE x.ra_res_id   = res.res_id AND x.ra_public   = 1)
        OR EXISTS (SELECT 1 FROM dd_dons            x WHERE x.do_res_id   = res.res_id AND x.do_public   = 1)
        OR EXISTS (SELECT 1 FROM dd_competences     x WHERE x.comp_res_id = res.res_id AND x.comp_public = 1)
        OR EXISTS (SELECT 1 FROM dd_historiques     x WHERE x.hi_res_id   = res.res_id AND x.hi_public   = 1)
        OR EXISTS (SELECT 1 FROM dd_objets_magiques x WHERE x.om_res_id   = res.res_id AND x.om_public   = 1)
        OR EXISTS (SELECT 1 FROM dd_monstres        x WHERE x.mo_res_id   = res.res_id AND x.mo_public   = 1)
        OR EXISTS (SELECT 1 FROM dd_equipements     x WHERE x.eqt_res_id  = res.res_id AND x.eqt_public  = 1)
      )
 );

UPDATE dd_joueurs j
   SET j.j_mode_campagne = 1
 WHERE j.j_id IN (SELECT res.res_j_id FROM dd_ressources res WHERE res.res_j_id IS NOT NULL);
