-- sql/2026-11-06_sp-po6c_masquage_potions_baguettes.sql
-- SP-PO6 — Potions et baguettes DD3.5 retirées du compendium (D-PO15)
--
-- En DD3.5, potions, huiles, baguettes et parchemins sont des objets « complexes » : ils se composent
-- depuis l'inventaire d'un personnage (sort × NLS, SP-PO11) et n'ont pas d'entrée au compendium.
-- Les lignes existantes (catégories baguettes et potions-et-huiles, ruleset 1) sont masquées :
-- om_visible = 0 les retire des listes et des sélecteurs pour les lecteurs ; les éditeurs du compendium
-- les voient encore. Suppression définitive : SP-PO14.
-- Pas de DELIMITER.

SET NAMES utf8mb4;

UPDATE dd_objets_magiques om
JOIN dd_categorie_objet_magique com ON com.com_id = om.om_com_id
SET om.om_visible = 0
WHERE com.com_ruleset_var_id = 1
  AND com.com_slug IN ('baguettes', 'potions-et-huiles');
