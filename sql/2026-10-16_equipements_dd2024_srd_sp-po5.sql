-- sql/2026-10-16_equipements_dd2024_srd_sp-po5.sql
-- SP-PO5 — Import des équipements DD2024 du SRD 5.2.1 (chapitre « Équipement ») : familles propres au ruleset
-- (armes courantes / de guerre, armures, outils, matériel d'aventurier, montures et véhicules, repas,
-- services) puis les articles avec leur description. Les règles correspondantes : fichier
-- 2026-10-16_regles_dd2024_equipement_sp-po5.sql.
-- Source : ressource « SRD 5.2.1 » (retrouvée par abréviation). Corrections du texte :
-- doc/LOG_CORRECTIONS_SRD2024_EQUIPEMENT.md.
-- Pré-requis : 2026-10-11_equipements_00_schema_sp-po0.sql.
-- Rejouable : familles mises à jour par slug ; les articles de la source « SRD 5.2.1 » du ruleset DD2024 sont
-- supprimés puis réinsérés (les ajouts d'autres sources, dont les suppléments, ne sont pas touchés).
-- ⚠ Si les articles sont ensuite rattachés à une autre source (cf. SP-PO2b pour le DD3.5), ne plus rejouer ce fichier.

SET NAMES utf8mb4;

SET @dd24 := (SELECT var_id FROM dd_variables WHERE var_cat = 'ruleset' AND var_valeur = 'DD2024' LIMIT 1);
SET @res  := (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'SRD 5.2.1' AND res_ruleset_var_id = @dd24 AND res_j_id IS NULL LIMIT 1);

START TRANSACTION;

INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (NULL, 'Armes', 'armes', '[{"k":"degats","l":"Dégâts"},{"k":"proprietes","l":"Propriétés"},{"k":"botte","l":"Botte d''arme"},{"k":"poids","l":"Poids","a":"r"},{"k":"prix","l":"Prix","a":"r"}]', 10, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_armes := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'armes' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (@cae_armes, 'Armes courantes', 'armes-courantes', NULL, 10, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_armes_courantes := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'armes-courantes' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (@cae_armes_courantes, 'Armes courantes de corps à corps', 'armes-courantes-corps-a-corps', NULL, 10, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_armes_courantes_corps_a_corps := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'armes-courantes-corps-a-corps' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (@cae_armes_courantes, 'Armes courantes à distance', 'armes-courantes-distance', NULL, 20, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_armes_courantes_distance := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'armes-courantes-distance' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (@cae_armes, 'Armes de guerre', 'armes-de-guerre', NULL, 20, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_armes_de_guerre := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'armes-de-guerre' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (@cae_armes_de_guerre, 'Armes de guerre de corps à corps', 'armes-de-guerre-corps-a-corps', NULL, 10, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_armes_de_guerre_corps_a_corps := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'armes-de-guerre-corps-a-corps' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (@cae_armes_de_guerre, 'Armes de guerre à distance', 'armes-de-guerre-distance', NULL, 20, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_armes_de_guerre_distance := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'armes-de-guerre-distance' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (NULL, 'Armures', 'armures', '[{"k":"ca","l":"Classe d''armure (CA)"},{"k":"force","l":"Force","a":"c"},{"k":"discretion","l":"Discrétion","a":"c"},{"k":"poids","l":"Poids","a":"r"},{"k":"prix","l":"Coût","a":"r"}]', 20, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_armures := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'armures' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (@cae_armures, 'Armures légères', 'armures-legeres', NULL, 10, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_armures_legeres := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'armures-legeres' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (@cae_armures, 'Armures intermédiaires', 'armures-intermediaires', NULL, 20, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_armures_intermediaires := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'armures-intermediaires' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (@cae_armures, 'Armures lourdes', 'armures-lourdes', NULL, 30, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_armures_lourdes := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'armures-lourdes' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (@cae_armures, 'Bouclier', 'boucliers', NULL, 40, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_boucliers := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'boucliers' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (NULL, 'Outils', 'outils', '[{"k":"caracteristique","l":"Caractéristique"},{"k":"poids","l":"Poids","a":"r"},{"k":"prix","l":"Prix","a":"r"}]', 30, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_outils := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'outils' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (@cae_outils, 'Outils d''artisan', 'outils-d-artisan', NULL, 10, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_outils_d_artisan := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'outils-d-artisan' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (@cae_outils, 'Autres outils', 'autres-outils', NULL, 20, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_autres_outils := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'autres-outils' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (NULL, 'Matériel d''aventurier', 'materiel-d-aventurier', '[{"k":"poids","l":"Poids","a":"r"},{"k":"prix","l":"Prix","a":"r"}]', 40, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_materiel_d_aventurier := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'materiel-d-aventurier' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (@cae_materiel_d_aventurier, 'Munitions', 'munitions', '[{"k":"quantite","l":"Quantité","a":"c"},{"k":"rangement","l":"Rangement"},{"k":"poids","l":"Poids","a":"r"},{"k":"prix","l":"Prix","a":"r"}]', 10, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_munitions := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'munitions' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (@cae_materiel_d_aventurier, 'Focaliseurs arcaniques', 'focaliseurs-arcaniques', NULL, 20, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_focaliseurs_arcaniques := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'focaliseurs-arcaniques' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (@cae_materiel_d_aventurier, 'Focaliseurs druidiques', 'focaliseurs-druidiques', NULL, 30, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_focaliseurs_druidiques := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'focaliseurs-druidiques' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (@cae_materiel_d_aventurier, 'Symboles sacrés', 'symboles-sacres', NULL, 40, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_symboles_sacres := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'symboles-sacres' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (NULL, 'Montures et véhicules', 'montures-et-vehicules', '[{"k":"poids","l":"Poids","a":"r"},{"k":"prix","l":"Prix","a":"r"}]', 50, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_montures_et_vehicules := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'montures-et-vehicules' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (@cae_montures_et_vehicules, 'Montures et autres animaux', 'montures-et-autres-animaux', '[{"k":"capacite","l":"Capacité de charge","a":"r"},{"k":"prix","l":"Prix","a":"r"}]', 10, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_montures_et_autres_animaux := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'montures-et-autres-animaux' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (@cae_montures_et_vehicules, 'Harnachement et véhicules tractés', 'harnachement-et-vehicules-tractes', NULL, 20, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_harnachement_et_vehicules_tractes := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'harnachement-et-vehicules-tractes' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (@cae_montures_et_vehicules, 'Véhicules aériens et bateaux', 'vehicules-aeriens-et-bateaux', '[{"k":"vitesse","l":"Vitesse","a":"r"},{"k":"equipage","l":"Équipage","a":"c"},{"k":"passagers","l":"Passagers","a":"c"},{"k":"cargaison","l":"Cargaison (tonnes)","a":"c"},{"k":"ca","l":"CA","a":"c"},{"k":"pv","l":"PV","a":"c"},{"k":"seuil","l":"Seuil de dégâts","a":"c"},{"k":"prix","l":"Prix","a":"r"}]', 30, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_vehicules_aeriens_et_bateaux := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'vehicules-aeriens-et-bateaux' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (NULL, 'Repas, boisson et hébergement', 'repas-boisson-et-hebergement', '[{"k":"prix","l":"Prix","a":"r"}]', 60, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_repas_boisson_et_hebergement := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'repas-boisson-et-hebergement' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (NULL, 'Services', 'services', '[{"k":"prix","l":"Prix","a":"r"}]', 70, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_services := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'services' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (@cae_services, 'Employés', 'employes', NULL, 10, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_employes := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'employes' AND cae_ruleset_var_id = @dd24);
INSERT INTO dd_categorie_equipement (cae_cae_id, cae_nom, cae_slug, cae_colonnes, cae_ordre, cae_ruleset_var_id)
VALUES (@cae_services, 'Services d''incantation', 'services-d-incantation', '[{"k":"disponibilite","l":"Disponibilité"},{"k":"prix","l":"Prix","a":"r"}]', 20, @dd24)
ON DUPLICATE KEY UPDATE cae_cae_id = VALUES(cae_cae_id), cae_nom = VALUES(cae_nom),
  cae_colonnes = VALUES(cae_colonnes), cae_ordre = VALUES(cae_ordre);
SET @cae_services_d_incantation := (SELECT cae_id FROM dd_categorie_equipement WHERE cae_slug = 'services-d-incantation' AND cae_ruleset_var_id = @dd24);

DELETE FROM dd_equipements WHERE eqt_res_id = @res AND eqt_ruleset_var_id = @dd24;

-- armes-courantes-corps-a-corps
INSERT INTO dd_equipements (eqt_nom, eqt_cae_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt,
  eqt_attributs, eqt_ordre, eqt_description, eqt_visible, eqt_public, eqt_res_id, eqt_camp_id, eqt_ruleset_var_id) VALUES
  ('Bâton de combat', @cae_armes_courantes_corps_a_corps, 20, NULL, 2000, NULL, '{"degats":"1d6 contondants","proprietes":"Polyvalente (1d8)","botte":"Renversement"}', 10, NULL, 1, 0, @res, NULL, @dd24),
  ('Dague', @cae_armes_courantes_corps_a_corps, 200, NULL, 500, NULL, '{"degats":"1d4 perforants","proprietes":"Finesse, Lancer (portée 6/18), Légère","botte":"Coup double"}', 20, NULL, 1, 0, @res, NULL, @dd24),
  ('Gourdin', @cae_armes_courantes_corps_a_corps, 10, NULL, 1000, NULL, '{"degats":"1d4 contondants","proprietes":"Légère","botte":"Ralentissement"}', 30, NULL, 1, 0, @res, NULL, @dd24),
  ('Hachette', @cae_armes_courantes_corps_a_corps, 500, NULL, 1000, NULL, '{"degats":"1d6 tranchants","proprietes":"Lancer (portée 6/18), Légère","botte":"Ouverture"}', 40, NULL, 1, 0, @res, NULL, @dd24),
  ('Javeline', @cae_armes_courantes_corps_a_corps, 50, NULL, 1000, NULL, '{"degats":"1d6 perforants","proprietes":"Lancer (portée 9/36)","botte":"Ralentissement"}', 50, NULL, 1, 0, @res, NULL, @dd24),
  ('Lance', @cae_armes_courantes_corps_a_corps, 100, NULL, 1500, NULL, '{"degats":"1d6 perforants","proprietes":"Lancer (portée 6/18), Polyvalente (1d8)","botte":"Sape"}', 60, NULL, 1, 0, @res, NULL, @dd24),
  ('Marteau léger', @cae_armes_courantes_corps_a_corps, 200, NULL, 1000, NULL, '{"degats":"1d4 contondants","proprietes":"Lancer (portée 6/18), Légère","botte":"Coup double"}', 70, NULL, 1, 0, @res, NULL, @dd24),
  ('Masse d''armes', @cae_armes_courantes_corps_a_corps, 500, NULL, 2000, NULL, '{"degats":"1d6 contondants","proprietes":"—","botte":"Sape"}', 80, NULL, 1, 0, @res, NULL, @dd24),
  ('Massue', @cae_armes_courantes_corps_a_corps, 20, NULL, 5000, NULL, '{"degats":"1d8 contondants","proprietes":"Deux mains","botte":"Poussée"}', 90, NULL, 1, 0, @res, NULL, @dd24),
  ('Serpe', @cae_armes_courantes_corps_a_corps, 100, NULL, 1000, NULL, '{"degats":"1d4 tranchants","proprietes":"Légère","botte":"Coup double"}', 100, NULL, 1, 0, @res, NULL, @dd24);

-- armes-courantes-distance
INSERT INTO dd_equipements (eqt_nom, eqt_cae_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt,
  eqt_attributs, eqt_ordre, eqt_description, eqt_visible, eqt_public, eqt_res_id, eqt_camp_id, eqt_ruleset_var_id) VALUES
  ('Arbalète légère', @cae_armes_courantes_distance, 2500, NULL, 2500, NULL, '{"degats":"1d8 perforants","proprietes":"Chargement, Deux mains, Munitions (portée 24/96 ; carreaux)","botte":"Ralentissement"}', 10, NULL, 1, 0, @res, NULL, @dd24),
  ('Arc court', @cae_armes_courantes_distance, 2500, NULL, 1000, NULL, '{"degats":"1d6 perforants","proprietes":"Deux mains, Munitions (portée 24/96 ; flèches)","botte":"Ouverture"}', 20, NULL, 1, 0, @res, NULL, @dd24),
  ('Fléchette', @cae_armes_courantes_distance, 5, NULL, 125, NULL, '{"degats":"1d4 perforants","proprietes":"Finesse, Lancer (portée 6/18)","botte":"Ouverture"}', 30, NULL, 1, 0, @res, NULL, @dd24),
  ('Fronde', @cae_armes_courantes_distance, 10, NULL, NULL, NULL, '{"degats":"1d4 contondants","proprietes":"Munitions (portée 9/36 ; billes)","botte":"Ralentissement"}', 40, NULL, 1, 0, @res, NULL, @dd24);

-- armes-de-guerre-corps-a-corps
INSERT INTO dd_equipements (eqt_nom, eqt_cae_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt,
  eqt_attributs, eqt_ordre, eqt_description, eqt_visible, eqt_public, eqt_res_id, eqt_camp_id, eqt_ruleset_var_id) VALUES
  ('Cimeterre', @cae_armes_de_guerre_corps_a_corps, 2500, NULL, 1500, NULL, '{"degats":"1d6 tranchants","proprietes":"Finesse, Légère","botte":"Coup double"}', 10, NULL, 1, 0, @res, NULL, @dd24),
  ('Coutille', @cae_armes_de_guerre_corps_a_corps, 2000, NULL, 3000, NULL, '{"degats":"1d10 tranchants","proprietes":"Allonge, Deux mains, Lourde","botte":"Écorchure"}', 20, NULL, 1, 0, @res, NULL, @dd24),
  ('Épée à deux mains', @cae_armes_de_guerre_corps_a_corps, 5000, NULL, 3000, NULL, '{"degats":"2d6 tranchants","proprietes":"Deux mains, Lourde","botte":"Écorchure"}', 30, NULL, 1, 0, @res, NULL, @dd24),
  ('Épée courte', @cae_armes_de_guerre_corps_a_corps, 1000, NULL, 1000, NULL, '{"degats":"1d6 perforants","proprietes":"Finesse, Légère","botte":"Ouverture"}', 40, NULL, 1, 0, @res, NULL, @dd24),
  ('Épée longue', @cae_armes_de_guerre_corps_a_corps, 1500, NULL, 1500, NULL, '{"degats":"1d8 tranchants","proprietes":"Polyvalente (1d10)","botte":"Sape"}', 50, NULL, 1, 0, @res, NULL, @dd24),
  ('Fléau d''armes', @cae_armes_de_guerre_corps_a_corps, 1000, NULL, 1000, NULL, '{"degats":"1d8 contondants","proprietes":"—","botte":"Sape"}', 60, NULL, 1, 0, @res, NULL, @dd24),
  ('Fouet', @cae_armes_de_guerre_corps_a_corps, 200, NULL, 1500, NULL, '{"degats":"1d4 tranchants","proprietes":"Allonge, Finesse","botte":"Ralentissement"}', 70, NULL, 1, 0, @res, NULL, @dd24),
  ('Hache à deux mains', @cae_armes_de_guerre_corps_a_corps, 3000, NULL, 3500, NULL, '{"degats":"1d12 tranchants","proprietes":"Deux mains, Lourde","botte":"Enchaînement"}', 80, NULL, 1, 0, @res, NULL, @dd24),
  ('Hache d''armes', @cae_armes_de_guerre_corps_a_corps, 1000, NULL, 2000, NULL, '{"degats":"1d8 tranchants","proprietes":"Polyvalente (1d10)","botte":"Renversement"}', 90, NULL, 1, 0, @res, NULL, @dd24),
  ('Hallebarde', @cae_armes_de_guerre_corps_a_corps, 2000, NULL, 3000, NULL, '{"degats":"1d10 tranchants","proprietes":"Allonge, Deux mains, Lourde","botte":"Enchaînement"}', 100, NULL, 1, 0, @res, NULL, @dd24),
  ('Lance d''arçon', @cae_armes_de_guerre_corps_a_corps, 1000, NULL, 3000, NULL, '{"degats":"1d10 perforants","proprietes":"Allonge, Deux mains (sauf à cheval), Lourde","botte":"Renversement"}', 110, NULL, 1, 0, @res, NULL, @dd24),
  ('Maillet d''armes', @cae_armes_de_guerre_corps_a_corps, 1000, NULL, 5000, NULL, '{"degats":"2d6 contondants","proprietes":"Deux mains, Lourde","botte":"Renversement"}', 120, NULL, 1, 0, @res, NULL, @dd24),
  ('Marteau de guerre', @cae_armes_de_guerre_corps_a_corps, 1500, NULL, 2500, NULL, '{"degats":"1d8 contondants","proprietes":"Polyvalente (1d10)","botte":"Poussée"}', 130, NULL, 1, 0, @res, NULL, @dd24),
  ('Morgenstern', @cae_armes_de_guerre_corps_a_corps, 1500, NULL, 2000, NULL, '{"degats":"1d8 perforants","proprietes":"—","botte":"Sape"}', 140, NULL, 1, 0, @res, NULL, @dd24),
  ('Pic de guerre', @cae_armes_de_guerre_corps_a_corps, 500, NULL, 1000, NULL, '{"degats":"1d8 perforants","proprietes":"Polyvalente (1d10)","botte":"Sape"}', 150, NULL, 1, 0, @res, NULL, @dd24),
  ('Pique', @cae_armes_de_guerre_corps_a_corps, 500, NULL, 9000, NULL, '{"degats":"1d10 perforants","proprietes":"Allonge, Deux mains, Lourde","botte":"Poussée"}', 160, NULL, 1, 0, @res, NULL, @dd24),
  ('Rapière', @cae_armes_de_guerre_corps_a_corps, 2500, NULL, 1000, NULL, '{"degats":"1d8 perforants","proprietes":"Finesse","botte":"Ouverture"}', 170, NULL, 1, 0, @res, NULL, @dd24),
  ('Trident', @cae_armes_de_guerre_corps_a_corps, 500, NULL, 2000, NULL, '{"degats":"1d8 perforants","proprietes":"Lancer (portée 6/18), Polyvalente (1d10)","botte":"Renversement"}', 180, NULL, 1, 0, @res, NULL, @dd24);

-- armes-de-guerre-distance
INSERT INTO dd_equipements (eqt_nom, eqt_cae_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt,
  eqt_attributs, eqt_ordre, eqt_description, eqt_visible, eqt_public, eqt_res_id, eqt_camp_id, eqt_ruleset_var_id) VALUES
  ('Arbalète de poing', @cae_armes_de_guerre_distance, 7500, NULL, 1500, NULL, '{"degats":"1d6 perforants","proprietes":"Chargement, Légère, Munitions (portée 9/36 ; carreaux)","botte":"Ouverture"}', 10, NULL, 1, 0, @res, NULL, @dd24),
  ('Arbalète lourde', @cae_armes_de_guerre_distance, 5000, NULL, 9000, NULL, '{"degats":"1d10 perforants","proprietes":"Chargement, Deux mains, Lourde, Munitions (portée 30/120 ; carreaux)","botte":"Poussée"}', 20, NULL, 1, 0, @res, NULL, @dd24),
  ('Arc long', @cae_armes_de_guerre_distance, 5000, NULL, 1000, NULL, '{"degats":"1d8 perforants","proprietes":"Deux mains, Lourde, Munitions (portée 45/180 ; flèches)","botte":"Ralentissement"}', 30, NULL, 1, 0, @res, NULL, @dd24),
  ('Mousquet', @cae_armes_de_guerre_distance, 50000, NULL, 5000, NULL, '{"degats":"1d12 perforants","proprietes":"Chargement, Deux mains, Munitions (portée 12/36 ; balles)","botte":"Ralentissement"}', 40, NULL, 1, 0, @res, NULL, @dd24),
  ('Pistolet', @cae_armes_de_guerre_distance, 25000, NULL, 1500, NULL, '{"degats":"1d10 perforants","proprietes":"Chargement, Munitions (portée 9/27 ; balles)","botte":"Ouverture"}', 50, NULL, 1, 0, @res, NULL, @dd24),
  ('Sarbacane', @cae_armes_de_guerre_distance, 1000, NULL, 500, NULL, '{"degats":"1 perforant","proprietes":"Chargement, Munitions (portée 7,50/30 ; dards)","botte":"Ouverture"}', 60, NULL, 1, 0, @res, NULL, @dd24);

-- armures-legeres
INSERT INTO dd_equipements (eqt_nom, eqt_cae_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt,
  eqt_attributs, eqt_ordre, eqt_description, eqt_visible, eqt_public, eqt_res_id, eqt_camp_id, eqt_ruleset_var_id) VALUES
  ('Armure matelassée', @cae_armures_legeres, 500, NULL, 4000, NULL, '{"ca":"11 + modificateur de Dex","force":"—","discretion":"Désavantage"}', 10, '<p>Armure légère : elle s''enfile ou se retire en 1 minute.</p>', 1, 0, @res, NULL, @dd24),
  ('Armure de cuir', @cae_armures_legeres, 1000, NULL, 5000, NULL, '{"ca":"11 + modificateur de Dex","force":"—","discretion":"—"}', 20, '<p>Armure légère : elle s''enfile ou se retire en 1 minute.</p>', 1, 0, @res, NULL, @dd24),
  ('Armure de cuir clouté', @cae_armures_legeres, 4500, NULL, 6500, NULL, '{"ca":"12 + modificateur de Dex","force":"—","discretion":"—"}', 30, '<p>Armure légère : elle s''enfile ou se retire en 1 minute.</p>', 1, 0, @res, NULL, @dd24);

-- armures-intermediaires
INSERT INTO dd_equipements (eqt_nom, eqt_cae_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt,
  eqt_attributs, eqt_ordre, eqt_description, eqt_visible, eqt_public, eqt_res_id, eqt_camp_id, eqt_ruleset_var_id) VALUES
  ('Armure de peaux', @cae_armures_intermediaires, 1000, NULL, 6000, NULL, '{"ca":"12 + modificateur de Dex (max 2)","force":"—","discretion":"—"}', 10, '<p>Armure intermédiaire : elle s''enfile en 5 minutes et se retire en 1 minute.</p>', 1, 0, @res, NULL, @dd24),
  ('Chemise de mailles', @cae_armures_intermediaires, 5000, NULL, 10000, NULL, '{"ca":"13 + modificateur de Dex (max 2)","force":"—","discretion":"—"}', 20, '<p>Armure intermédiaire : elle s''enfile en 5 minutes et se retire en 1 minute.</p>', 1, 0, @res, NULL, @dd24),
  ('Armure d''écailles', @cae_armures_intermediaires, 5000, NULL, 22500, NULL, '{"ca":"14 + modificateur de Dex (max 2)","force":"—","discretion":"Désavantage"}', 30, '<p>Armure intermédiaire : elle s''enfile en 5 minutes et se retire en 1 minute.</p>', 1, 0, @res, NULL, @dd24),
  ('Cuirasse', @cae_armures_intermediaires, 40000, NULL, 10000, NULL, '{"ca":"14 + modificateur de Dex (max 2)","force":"—","discretion":"—"}', 40, '<p>Armure intermédiaire : elle s''enfile en 5 minutes et se retire en 1 minute.</p>', 1, 0, @res, NULL, @dd24),
  ('Demi-plate', @cae_armures_intermediaires, 75000, NULL, 20000, NULL, '{"ca":"15 + modificateur de Dex (max 2)","force":"—","discretion":"Désavantage"}', 50, '<p>Armure intermédiaire : elle s''enfile en 5 minutes et se retire en 1 minute.</p>', 1, 0, @res, NULL, @dd24);

-- armures-lourdes
INSERT INTO dd_equipements (eqt_nom, eqt_cae_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt,
  eqt_attributs, eqt_ordre, eqt_description, eqt_visible, eqt_public, eqt_res_id, eqt_camp_id, eqt_ruleset_var_id) VALUES
  ('Broigne', @cae_armures_lourdes, 3000, NULL, 20000, NULL, '{"ca":"14","force":"—","discretion":"Désavantage"}', 10, '<p>Armure lourde : elle s''enfile en 10 minutes et se retire en 5 minutes.</p>', 1, 0, @res, NULL, @dd24),
  ('Cotte de mailles', @cae_armures_lourdes, 7500, NULL, 27500, NULL, '{"ca":"16","force":"For 13","discretion":"Désavantage"}', 20, '<p>Armure lourde : elle s''enfile en 10 minutes et se retire en 5 minutes.</p>', 1, 0, @res, NULL, @dd24),
  ('Clibanion', @cae_armures_lourdes, 20000, NULL, 30000, NULL, '{"ca":"17","force":"For 15","discretion":"Désavantage"}', 30, '<p>Armure lourde : elle s''enfile en 10 minutes et se retire en 5 minutes.</p>', 1, 0, @res, NULL, @dd24),
  ('Harnois', @cae_armures_lourdes, 150000, NULL, 32500, NULL, '{"ca":"18","force":"For 15","discretion":"Désavantage"}', 40, '<p>Armure lourde : elle s''enfile en 10 minutes et se retire en 5 minutes.</p>', 1, 0, @res, NULL, @dd24);

-- boucliers
INSERT INTO dd_equipements (eqt_nom, eqt_cae_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt,
  eqt_attributs, eqt_ordre, eqt_description, eqt_visible, eqt_public, eqt_res_id, eqt_camp_id, eqt_ruleset_var_id) VALUES
  ('Bouclier', @cae_boucliers, 1000, NULL, 3000, NULL, '{"ca":"+2","force":"—","discretion":"—"}', 10, '<p>Un bouclier s''enfile ou se retire au prix de l''action Utilisation. Vous ne recevez le bénéfice Classe d''armure d''un bouclier que si vous êtes formé à son port.</p>', 1, 0, @res, NULL, @dd24);

-- outils-d-artisan
INSERT INTO dd_equipements (eqt_nom, eqt_cae_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt,
  eqt_attributs, eqt_ordre, eqt_description, eqt_visible, eqt_public, eqt_res_id, eqt_camp_id, eqt_ruleset_var_id) VALUES
  ('Matériel d''alchimiste', @cae_outils_d_artisan, 5000, NULL, 4000, NULL, '{"caracteristique":"Intelligence"}', 10, '<p><strong>Utilisation :</strong> identifier une substance (DD 15), allumer un feu (DD 15)</p>
<p><strong>Artisanat :</strong> acide, feu grégeois, huile, papier, parfum, sacoche à composantes</p>', 1, 0, @res, NULL, @dd24),
  ('Matériel de brasseur', @cae_outils_d_artisan, 2000, NULL, 4500, NULL, '{"caracteristique":"Intelligence"}', 20, '<p><strong>Utilisation :</strong> détecter qu''une boisson est empoisonnée (DD 15), identifier un alcool (DD 10)</p>
<p><strong>Artisanat :</strong> antidote</p>', 1, 0, @res, NULL, @dd24),
  ('Matériel de calligraphe', @cae_outils_d_artisan, 1000, NULL, 2500, NULL, '{"caracteristique":"Dextérité"}', 30, '<p><strong>Utilisation :</strong> écrire des textes avec des fioritures impressionnantes qui le prémunissent contre la contrefaçon (DD 15)</p>
<p><strong>Artisanat :</strong> encre, parchemin de sort</p>', 1, 0, @res, NULL, @dd24),
  ('Matériel de peintre', @cae_outils_d_artisan, 1000, NULL, 2500, NULL, '{"caracteristique":"Sagesse"}', 40, '<p><strong>Utilisation :</strong> produire une image ressemblante de quelque chose que vous avez vu (DD 10)</p>
<p><strong>Artisanat :</strong> focaliseur druidique, symbole sacré</p>', 1, 0, @res, NULL, @dd24),
  ('Outils de bricoleur', @cae_outils_d_artisan, 5000, NULL, 5000, NULL, '{"caracteristique":"Dextérité"}', 50, '<p><strong>Utilisation :</strong> assembler un objet de taille TP composé de ferraille, qui se désagrège au bout de 1 minute (DD 20)</p>
<p><strong>Artisanat :</strong> mousquet, pistolet, boîte à amadou, cloche, lanterne à capote, lanterne sourde, menottes, pelle, piège à mâchoires, serrure, sifflet</p>', 1, 0, @res, NULL, @dd24),
  ('Outils de cartographe', @cae_outils_d_artisan, 1500, NULL, 3000, NULL, '{"caracteristique":"Sagesse"}', 60, '<p><strong>Utilisation :</strong> cartographier une petite région (DD 15)</p>
<p><strong>Artisanat :</strong> carte</p>', 1, 0, @res, NULL, @dd24),
  ('Outils de charpentier', @cae_outils_d_artisan, 800, NULL, 3000, NULL, '{"caracteristique":"Force"}', 70, '<p><strong>Utilisation :</strong> sceller ou forcer une porte ou un contenant (DD 20)</p>
<p><strong>Artisanat :</strong> bâton de combat, bélier portable, coffre, échelle, gourdin, massue, perche, tonneau, torche</p>', 1, 0, @res, NULL, @dd24),
  ('Outils de cordonnier', @cae_outils_d_artisan, 500, NULL, 2500, NULL, '{"caracteristique":"Dextérité"}', 80, '<p><strong>Utilisation :</strong> modifier des chaussures afin d''octroyer l''Avantage au prochain test de Dextérité (Acrobaties) de leur porteur (DD 10)</p>
<p><strong>Artisanat :</strong> matériel d''escalade</p>', 1, 0, @res, NULL, @dd24),
  ('Outils de forgeron', @cae_outils_d_artisan, 2000, NULL, 4000, NULL, '{"caracteristique":"Force"}', 90, '<p><strong>Utilisation :</strong> forcer une porte ou un contenant (DD 20)</p>
<p><strong>Artisanat :</strong> toute arme de corps à corps (hormis bâton de combat, gourdin, massue et fouet), toute armure intermédiaire (hormis armure de peaux), toute armure lourde, balles pour arme à feu, billes, billes de fronde, chaîne, chausse-trappes, grappin, pied-de-biche, pointes en fer, pot en fer, seau</p>', 1, 0, @res, NULL, @dd24),
  ('Outils de joaillier', @cae_outils_d_artisan, 2500, NULL, 1000, NULL, '{"caracteristique":"Intelligence"}', 100, '<p><strong>Utilisation :</strong> déterminer la valeur d''une gemme (DD 15)</p>
<p><strong>Artisanat :</strong> focaliseur arcanique, symbole sacré</p>', 1, 0, @res, NULL, @dd24),
  ('Outils de maçon', @cae_outils_d_artisan, 1000, NULL, 4000, NULL, '{"caracteristique":"Force"}', 110, '<p><strong>Utilisation :</strong> ciseler un symbole ou creuser un trou dans la pierre (DD 10)</p>
<p><strong>Artisanat :</strong> palan</p>', 1, 0, @res, NULL, @dd24),
  ('Outils de menuisier', @cae_outils_d_artisan, 100, NULL, 2500, NULL, '{"caracteristique":"Dextérité"}', 120, '<p><strong>Utilisation :</strong> sculpter un motif dans le bois (DD 10)</p>
<p><strong>Artisanat :</strong> armes à distance (sauf fronde, mousquet et pistolet), bâton de combat, carreaux d''arbalète, dards de sarbacane, flèches, focaliseur arcanique, focaliseur druidique, porte-plume</p>', 1, 0, @res, NULL, @dd24),
  ('Outils de potier', @cae_outils_d_artisan, 1000, NULL, 1500, NULL, '{"caracteristique":"Intelligence"}', 130, '<p><strong>Utilisation :</strong> déterminer ce qu''a contenu un objet en céramique lors des dernières 24 heures (DD 15)</p>
<p><strong>Artisanat :</strong> cruche, lampe</p>', 1, 0, @res, NULL, @dd24),
  ('Outils de souffleur de verre', @cae_outils_d_artisan, 3000, NULL, 2500, NULL, '{"caracteristique":"Intelligence"}', 140, '<p><strong>Utilisation :</strong> déterminer ce qu''a contenu un objet en verre lors des dernières 24 heures (DD 15)</p>
<p><strong>Artisanat :</strong> bouteille en verre, fiole, longue-vue, loupe</p>', 1, 0, @res, NULL, @dd24),
  ('Outils de tanneur', @cae_outils_d_artisan, 500, NULL, 2500, NULL, '{"caracteristique":"Dextérité"}', 150, '<p><strong>Utilisation :</strong> ajouter un motif à un objet en cuir (DD 10)</p>
<p><strong>Artisanat :</strong> fouet, fronde, armure de cuir, armure de cuir clouté, armure de peaux, carquois, étui à carreaux d''arbalète, étui à cartes ou à parchemins, outre, parchemin, sacoche, sac à dos</p>', 1, 0, @res, NULL, @dd24),
  ('Outils de tisserand', @cae_outils_d_artisan, 100, NULL, 2500, NULL, '{"caracteristique":"Dextérité"}', 160, '<p><strong>Utilisation :</strong> raccommoder une déchirure dans un vêtement (DD 10), coudre un motif de taille TP (DD 10)</p>
<p><strong>Artisanat :</strong> armure matelassée, beaux habits, corde, couverture, ficelle, filet, panier, robe, sac, sac de couchage, tente, tenue de voyage</p>', 1, 0, @res, NULL, @dd24),
  ('Ustensiles de cuisinier', @cae_outils_d_artisan, 100, NULL, 4000, NULL, '{"caracteristique":"Sagesse"}', 170, '<p><strong>Utilisation :</strong> améliorer la saveur des aliments (DD 10), détecter si un plat est avarié ou empoisonné (DD 15)</p>
<p><strong>Artisanat :</strong> rations</p>', 1, 0, @res, NULL, @dd24);

-- autres-outils
INSERT INTO dd_equipements (eqt_nom, eqt_cae_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt,
  eqt_attributs, eqt_ordre, eqt_description, eqt_visible, eqt_public, eqt_res_id, eqt_camp_id, eqt_ruleset_var_id) VALUES
  ('Accessoires de déguisement', @cae_autres_outils, 2500, NULL, 1500, NULL, '{"caracteristique":"Charisme"}', 10, '<p><strong>Utilisation :</strong> appliquer du maquillage (DD 10)</p>
<p><strong>Artisanat :</strong> costume</p>', 1, 0, @res, NULL, @dd24),
  ('Boîte de jeux : cartes à jouer', @cae_autres_outils, 50, NULL, NULL, NULL, '{"caracteristique":"Sagesse"}', 20, '<p><strong>Utilisation :</strong> déterminer si quelqu''un triche (DD 10), gagner la partie (DD 20)</p>
<p>Variante de la boîte de jeux ; chaque variante nécessite une maîtrise distincte.</p>', 1, 0, @res, NULL, @dd24),
  ('Boîte de jeux : dés', @cae_autres_outils, 10, NULL, NULL, NULL, '{"caracteristique":"Sagesse"}', 30, '<p><strong>Utilisation :</strong> déterminer si quelqu''un triche (DD 10), gagner la partie (DD 20)</p>
<p>Variante de la boîte de jeux ; chaque variante nécessite une maîtrise distincte.</p>', 1, 0, @res, NULL, @dd24),
  ('Boîte de jeux : échecs draconiques', @cae_autres_outils, 100, NULL, NULL, NULL, '{"caracteristique":"Sagesse"}', 40, '<p><strong>Utilisation :</strong> déterminer si quelqu''un triche (DD 10), gagner la partie (DD 20)</p>
<p>Variante de la boîte de jeux ; chaque variante nécessite une maîtrise distincte.</p>', 1, 0, @res, NULL, @dd24),
  ('Boîte de jeux : jeu des dragons', @cae_autres_outils, 100, NULL, NULL, NULL, '{"caracteristique":"Sagesse"}', 50, '<p><strong>Utilisation :</strong> déterminer si quelqu''un triche (DD 10), gagner la partie (DD 20)</p>
<p>Variante de la boîte de jeux ; chaque variante nécessite une maîtrise distincte.</p>', 1, 0, @res, NULL, @dd24),
  ('Instrument de musique : chalemie', @cae_autres_outils, 200, NULL, 500, NULL, '{"caracteristique":"Charisme"}', 60, '<p><strong>Utilisation :</strong> jouer un air connu (DD 10), improviser une chanson (DD 15)</p>
<p>Variante de l''instrument de musique ; chaque variante nécessite une maîtrise distincte.</p>', 1, 0, @res, NULL, @dd24),
  ('Instrument de musique : cor', @cae_autres_outils, 300, NULL, 1000, NULL, '{"caracteristique":"Charisme"}', 70, '<p><strong>Utilisation :</strong> jouer un air connu (DD 10), improviser une chanson (DD 15)</p>
<p>Variante de l''instrument de musique ; chaque variante nécessite une maîtrise distincte.</p>', 1, 0, @res, NULL, @dd24),
  ('Instrument de musique : cornemuse', @cae_autres_outils, 3000, NULL, 3000, NULL, '{"caracteristique":"Charisme"}', 80, '<p><strong>Utilisation :</strong> jouer un air connu (DD 10), improviser une chanson (DD 15)</p>
<p>Variante de l''instrument de musique ; chaque variante nécessite une maîtrise distincte.</p>', 1, 0, @res, NULL, @dd24),
  ('Instrument de musique : flûte', @cae_autres_outils, 200, NULL, 500, NULL, '{"caracteristique":"Charisme"}', 90, '<p><strong>Utilisation :</strong> jouer un air connu (DD 10), improviser une chanson (DD 15)</p>
<p>Variante de l''instrument de musique ; chaque variante nécessite une maîtrise distincte.</p>', 1, 0, @res, NULL, @dd24),
  ('Instrument de musique : flûte de pan', @cae_autres_outils, 1200, NULL, 1000, NULL, '{"caracteristique":"Charisme"}', 100, '<p><strong>Utilisation :</strong> jouer un air connu (DD 10), improviser une chanson (DD 15)</p>
<p>Variante de l''instrument de musique ; chaque variante nécessite une maîtrise distincte.</p>', 1, 0, @res, NULL, @dd24),
  ('Instrument de musique : luth', @cae_autres_outils, 3500, NULL, 1000, NULL, '{"caracteristique":"Charisme"}', 110, '<p><strong>Utilisation :</strong> jouer un air connu (DD 10), improviser une chanson (DD 15)</p>
<p>Variante de l''instrument de musique ; chaque variante nécessite une maîtrise distincte.</p>', 1, 0, @res, NULL, @dd24),
  ('Instrument de musique : lyre', @cae_autres_outils, 3000, NULL, 1000, NULL, '{"caracteristique":"Charisme"}', 120, '<p><strong>Utilisation :</strong> jouer un air connu (DD 10), improviser une chanson (DD 15)</p>
<p>Variante de l''instrument de musique ; chaque variante nécessite une maîtrise distincte.</p>', 1, 0, @res, NULL, @dd24),
  ('Instrument de musique : tambour', @cae_autres_outils, 600, NULL, 1500, NULL, '{"caracteristique":"Charisme"}', 130, '<p><strong>Utilisation :</strong> jouer un air connu (DD 10), improviser une chanson (DD 15)</p>
<p>Variante de l''instrument de musique ; chaque variante nécessite une maîtrise distincte.</p>', 1, 0, @res, NULL, @dd24),
  ('Instrument de musique : tympanon', @cae_autres_outils, 2500, NULL, 5000, NULL, '{"caracteristique":"Charisme"}', 140, '<p><strong>Utilisation :</strong> jouer un air connu (DD 10), improviser une chanson (DD 15)</p>
<p>Variante de l''instrument de musique ; chaque variante nécessite une maîtrise distincte.</p>', 1, 0, @res, NULL, @dd24),
  ('Instrument de musique : viole', @cae_autres_outils, 3000, NULL, 500, NULL, '{"caracteristique":"Charisme"}', 150, '<p><strong>Utilisation :</strong> jouer un air connu (DD 10), improviser une chanson (DD 15)</p>
<p>Variante de l''instrument de musique ; chaque variante nécessite une maîtrise distincte.</p>', 1, 0, @res, NULL, @dd24),
  ('Instruments de navigateur', @cae_autres_outils, 2500, NULL, 1000, NULL, '{"caracteristique":"Sagesse"}', 160, '<p><strong>Utilisation :</strong> tracer un cap (DD 10), déterminer sa position en observant les étoiles (DD 15)</p>', 1, 0, @res, NULL, @dd24),
  ('Matériel d''empoisonneur', @cae_autres_outils, 5000, NULL, 1000, NULL, '{"caracteristique":"Intelligence"}', 170, '<p><strong>Utilisation :</strong> déterminer qu''un objet est empoisonné (DD 10)</p>
<p><strong>Artisanat :</strong> poison standard</p>', 1, 0, @res, NULL, @dd24),
  ('Matériel d''herboriste', @cae_autres_outils, 500, NULL, 1500, NULL, '{"caracteristique":"Intelligence"}', 180, '<p><strong>Utilisation :</strong> identifier une plante (DD 10)</p>
<p><strong>Artisanat :</strong> antidote, bougie, trousse de soins, potion de guérison</p>', 1, 0, @res, NULL, @dd24),
  ('Matériel de contrefaçon', @cae_autres_outils, 1500, NULL, 2500, NULL, '{"caracteristique":"Dextérité"}', 190, '<p><strong>Utilisation :</strong> imiter 10 mots ou moins de l''écriture d''autrui (DD 15), reproduire un cachet de cire (DD 20)</p>', 1, 0, @res, NULL, @dd24),
  ('Outils de voleur', @cae_autres_outils, 2500, NULL, 500, NULL, '{"caracteristique":"Dextérité"}', 200, '<p><strong>Utilisation :</strong> crocheter une serrure (DD 15), désamorcer un piège (DD 15)</p>', 1, 0, @res, NULL, @dd24);

-- materiel-d-aventurier
INSERT INTO dd_equipements (eqt_nom, eqt_cae_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt,
  eqt_attributs, eqt_ordre, eqt_description, eqt_visible, eqt_public, eqt_res_id, eqt_camp_id, eqt_ruleset_var_id) VALUES
  ('Acide', @cae_materiel_d_aventurier, 2500, NULL, 500, NULL, NULL, 10, '<p>Lorsque vous effectuez l''action Attaque, vous pouvez remplacer l''une de vos attaques par le jet d''une fiole d''acide. Ciblez une créature ou un objet que vous voyez dans un rayon de 6 m. La cible doit réussir un jet de sauvegarde de Dextérité (DD égal à 8 + votre modificateur de Dextérité + votre bonus de maîtrise) sous peine de subir 2d6 dégâts d''acide.</p>', 1, 0, @res, NULL, @dd24),
  ('Antidote', @cae_materiel_d_aventurier, 5000, NULL, NULL, NULL, NULL, 20, '<p>Par une action Bonus, vous pouvez boire le contenu d''une fiole d''antidote pour recevoir l''Avantage aux jets de sauvegarde visant à éviter l''état Empoisonné pendant 1 heure ou à y mettre un terme.</p>', 1, 0, @res, NULL, @dd24),
  ('Beaux habits', @cae_materiel_d_aventurier, 1500, NULL, 3000, NULL, NULL, 30, '<p>Les beaux habits sont fabriqués dans des tissus coûteux et dotés d''ornements élaborés. Certains événements et lieux n''acceptent que les personnes portant de tels vêtements.</p>', 1, 0, @res, NULL, @dd24),
  ('Bélier portable', @cae_materiel_d_aventurier, 400, NULL, 17500, NULL, NULL, 40, '<p>Vous pouvez utiliser un bélier portable pour enfoncer les portes. Vous recevez alors un bonus de +4 au test de Force associé. Si un autre personnage vous aide à utiliser le bélier, vous recevez l''Avantage à ce test.</p>', 1, 0, @res, NULL, @dd24),
  ('Billes', @cae_materiel_d_aventurier, 100, NULL, 1000, NULL, NULL, 50, '<p>Par une action Utilisation, vous pouvez déverser les billes de leur sacoche. Elles se répandent sur une surface plane de 3 m × 3 m, à une distance maximale de 3 m. Une créature qui traverse cette zone pour la première fois d''un tour doit réussir un jet de sauvegarde de Dextérité DD 10 sous peine de subir l''état À terre. 10 minutes sont nécessaires pour récupérer les billes.</p>', 1, 0, @res, NULL, @dd24),
  ('Boîte à amadou', @cae_materiel_d_aventurier, 50, NULL, 500, NULL, NULL, 60, '<p>Ce petit conteneur renferme silex, pierre à briquet et amorce (généralement un morceau de tissu imbibé d''huile), soit de quoi allumer un feu. L''utiliser pour allumer une bougie, une lampe, une lanterne ou une torche, ou tout autre objet dont le combustible est exposé, s''effectue par une action Bonus. Produire un autre type de flammes demande 1 minute.</p>', 1, 0, @res, NULL, @dd24),
  ('Bougie', @cae_materiel_d_aventurier, 1, NULL, NULL, NULL, NULL, 70, '<p>Après allumage et pendant 1 heure, une bougie produit une Lumière vive sur un rayon de 1,50 m et une Lumière faible sur 1,50 m de plus.</p>', 1, 0, @res, NULL, @dd24),
  ('Bouteille, verre', @cae_materiel_d_aventurier, 200, NULL, 1000, NULL, NULL, 80, '<p>Une bouteille en verre peut contenir jusqu''à 75 cl.</p>', 1, 0, @res, NULL, @dd24),
  ('Cadenas', @cae_materiel_d_aventurier, 1000, NULL, 500, NULL, NULL, 90, '<p>Un cadenas est livré avec une clef. Sans cette clef, une créature peut crocheter le cadenas à condition de réussir un test de Dextérité (Escamotage) DD 15 avec des outils de voleur.</p>', 1, 0, @res, NULL, @dd24),
  ('Carquois', @cae_materiel_d_aventurier, 100, NULL, 500, NULL, NULL, 100, '<p>Un carquois peut contenir jusqu''à 20 flèches.</p>', 1, 0, @res, NULL, @dd24),
  ('Carte', @cae_materiel_d_aventurier, 100, NULL, NULL, NULL, NULL, 110, '<p>Si vous consultez une carte précise, vous recevez un bonus de +5 aux tests de Sagesse (Survie) effectués pour trouver votre chemin dans le lieu représenté sur la carte.</p>', 1, 0, @res, NULL, @dd24),
  ('Chaîne', @cae_materiel_d_aventurier, 500, NULL, 5000, NULL, NULL, 120, '<p>Par une action Utilisation, vous enroulez une chaîne autour d''une créature non consentante dans un rayon de 1,50 m subissant l''état Agrippé, Entravé ou Neutralisé pour peu que vous réussissiez un test de Force (Athlétisme) DD 13. Si la créature a les jambes enchaînées, elle subit l''état Entravé jusqu''à ce qu''elle se libère. Se libérer de la chaîne nécessite que la créature réussisse un test de Dextérité (Acrobaties) DD 18 au prix d''une action. Briser cette chaîne nécessite de réussir un test de Force (Athlétisme) DD 20 au prix d''une action.</p>', 1, 0, @res, NULL, @dd24),
  ('Chausse-trappes', @cae_materiel_d_aventurier, 100, NULL, 1000, NULL, NULL, 130, '<p>Par une action Utilisation, vous pouvez répandre les chausse-trappes depuis leur sac pour couvrir une zone de 1,50 m × 1,50 m à une distance maximale de 1,50 m. Une créature qui traverse cette zone pour la première fois d''un tour doit réussir un jet de sauvegarde de Dextérité DD 15 sous peine de subir 1 dégât perforant et voir sa vitesse réduite à 0 jusqu''au début de son tour suivant. 10 minutes sont nécessaires pour récupérer les chausse-trappes.</p>', 1, 0, @res, NULL, @dd24),
  ('Cloche', @cae_materiel_d_aventurier, 100, NULL, NULL, NULL, NULL, 140, '<p>Actionnée par une action Utilisation, une cloche produit un son audible à 18 m.</p>', 1, 0, @res, NULL, @dd24),
  ('Coffre', @cae_materiel_d_aventurier, 500, NULL, 12500, NULL, NULL, 150, '<p>Un coffre contient jusqu''à 0,36 m³.</p>', 1, 0, @res, NULL, @dd24),
  ('Corde', @cae_materiel_d_aventurier, 100, NULL, 2500, NULL, NULL, 160, '<p>Par une action Utilisation, vous pouvez nouer la corde à condition de réussir un test de Dextérité (Escamotage) DD 10. Rompre la corde nécessite de réussir un test de Force (Athlétisme) DD 20.</p>
<p>Attacher une créature non consentante avec la corde nécessite que celle-ci subisse l''état Agrippé, Entravé ou Neutralisé. Si la créature a les jambes attachées, elle subit l''état Entravé jusqu''à ce qu''elle se libère. Se libérer de la corde nécessite que la créature réussisse un test de Dextérité (Acrobaties) DD 15 au prix d''une action.</p>', 1, 0, @res, NULL, @dd24),
  ('Costume', @cae_materiel_d_aventurier, 500, NULL, 2000, NULL, NULL, 170, '<p>Vêtu d''un costume, vous avez l''Avantage aux tests de caractéristique visant à vous faire passer pour la personne ou le type de personne qu''il représente.</p>', 1, 0, @res, NULL, @dd24),
  ('Couverture', @cae_materiel_d_aventurier, 50, NULL, 1500, NULL, NULL, 180, '<p>Enveloppé dans une couverture, vous avez l''Avantage aux jets de sauvegarde contre le froid extrême (voir « Boîte à outils ludique »).</p>', 1, 0, @res, NULL, @dd24),
  ('Cruche', @cae_materiel_d_aventurier, 2, NULL, 2000, NULL, NULL, 190, '<p>Une cruche contient jusqu''à 4 litres de liquide.</p>', 1, 0, @res, NULL, @dd24),
  ('Eau bénite', @cae_materiel_d_aventurier, 2500, NULL, 500, NULL, NULL, 200, '<p>Lorsque vous effectuez l''action Attaque, vous pouvez remplacer l''une de vos attaques par le jet d''une flasque d''eau bénite. Ciblez une créature que vous voyez dans un rayon de 6 m. La cible doit réussir un jet de sauvegarde de Dextérité (DD égal à 8 + votre modificateur de Dextérité + votre bonus de maîtrise) sous peine de subir 2d8 dégâts radiants si elle est de type Fiélon ou Mort-vivant.</p>', 1, 0, @res, NULL, @dd24),
  ('Échelle', @cae_materiel_d_aventurier, 10, NULL, 12500, NULL, NULL, 210, '<p>Une échelle mesure 3 m de haut. Grimper dessus permet de monter ou descendre.</p>', 1, 0, @res, NULL, @dd24),
  ('Encre', @cae_materiel_d_aventurier, 1000, NULL, NULL, NULL, NULL, 220, '<p>Conditionnée en bouteille de 30 ml, cette quantité d''encre permet de noircir environ 500 pages.</p>', 1, 0, @res, NULL, @dd24),
  ('Étui à cartes ou à parchemins', @cae_materiel_d_aventurier, 100, NULL, 500, NULL, NULL, 230, '<p>L''étui à cartes ou à parchemins peut contenir 10 feuilles de papier ou 5 feuilles de parchemin.</p>', 1, 0, @res, NULL, @dd24),
  ('Étui pour carreaux d''arbalète', @cae_materiel_d_aventurier, 100, NULL, 500, NULL, NULL, 240, '<p>Cet étui peut contenir 20 carreaux d''arbalète.</p>', 1, 0, @res, NULL, @dd24),
  ('Feu grégeois', @cae_materiel_d_aventurier, 5000, NULL, 500, NULL, NULL, 250, '<p>Lorsque vous effectuez l''action Attaque, vous pouvez remplacer l''une de vos attaques par le jet d''une flasque de feu grégeois. Ciblez une créature ou un objet que vous voyez dans un rayon de 6 m. La cible doit réussir un jet de sauvegarde de Dextérité (DD égal à 8 + votre modificateur de Dextérité + votre bonus de maîtrise) sous peine de subir 1d4 dégâts de feu et de prendre feu (voir « Glossaire de règles »).</p>', 1, 0, @res, NULL, @dd24),
  ('Ficelle', @cae_materiel_d_aventurier, 10, NULL, NULL, NULL, NULL, 260, '<p>Cette ficelle mesure 3 m de long. Vous pouvez y faire un nœud par une action Utilisation.</p>', 1, 0, @res, NULL, @dd24),
  ('Filet', @cae_materiel_d_aventurier, 100, NULL, 1500, NULL, NULL, 270, '<p>Lorsque vous effectuez l''action Attaque, vous pouvez remplacer l''une de vos attaques par le lancer d''un filet. Ciblez une créature que vous voyez à une distance maximale de 4,50 m. La cible doit réussir un jet de sauvegarde de Dextérité (DD égal à 8 + votre modificateur de Dextérité + votre bonus de maîtrise) sous peine de subir l''état Entravé jusqu''à sa libération. La cible réussit automatiquement si elle est de taille TG ou supérieure.</p>
<p>Pour être libérée, la cible (ou une créature dans un rayon de 1,50 m d''elle) doit entreprendre une action et effectuer un test de Force (Athlétisme) DD 10, libérant la créature Entravée en cas de réussite. La destruction du filet (CA 10 ; 5 pv ; Immunité aux dégâts contondants, psychiques et de poison) libère également la cible, mettant un terme à l''effet Entravé.</p>', 1, 0, @res, NULL, @dd24),
  ('Fiole', @cae_materiel_d_aventurier, 100, NULL, NULL, NULL, NULL, 280, '<p>Une fiole contient 120 ml de liquide.</p>', 1, 0, @res, NULL, @dd24),
  ('Flasque', @cae_materiel_d_aventurier, 2, NULL, 500, NULL, NULL, 290, '<p>Une flasque contient 0,5 litre de liquide.</p>', 1, 0, @res, NULL, @dd24),
  ('Focaliseur arcanique', @cae_materiel_d_aventurier, NULL, 'Variable', NULL, 'Variable', NULL, 300, '<p>Un focaliseur arcanique prend l''une des formes de la table « Focaliseurs arcaniques » et il est incrusté de pierreries ou sculpté afin de canaliser la magie arcanique. Un personnage Ensorceleur, Magicien ou Occultiste peut se servir d''un tel objet comme focaliseur d''incantation.</p>', 1, 0, @res, NULL, @dd24),
  ('Focaliseur druidique', @cae_materiel_d_aventurier, NULL, 'Variable', NULL, 'Variable', NULL, 310, '<p>Un focaliseur druidique prend l''une des formes proposées dans la table « Focaliseurs druidiques » et il est sculpté, attaché avec un ruban ou peint de façon à canaliser la magie primitive. Un Druide ou un Rôdeur peut se servir d''un tel objet comme focaliseur d''incantation.</p>', 1, 0, @res, NULL, @dd24),
  ('Grappin', @cae_materiel_d_aventurier, 200, NULL, 2000, NULL, NULL, 320, '<p>Par une action Utilisation, vous lancez le grappin sur une balustrade, un rebord ou une autre prise à une distance maximale de 15 m, et le grappin s''accroche si vous réussissez un test de Dextérité (Acrobaties) DD 13. Si vous aviez attaché une corde au grappin, vous pouvez y grimper.</p>', 1, 0, @res, NULL, @dd24),
  ('Huile', @cae_materiel_d_aventurier, 10, NULL, 500, NULL, NULL, 330, '<p>Vous pouvez asperger une créature, un objet ou un espace avec de l''huile ou l''utiliser comme combustible, comme détaillé ci-dessous.</p>
<p><strong>Asperger une créature ou un objet.</strong> Lorsque vous effectuez l''action Attaque, vous pouvez remplacer l''une de vos attaques par le jet d''une flasque d''huile. Ciblez une créature ou un objet à une distance maximale de 6 m. La cible doit réussir un jet de sauvegarde de Dextérité (DD égal à 8 + votre modificateur de Dextérité + votre bonus de maîtrise) sous peine d''être couverte d''huile. Si elle subit des dégâts de feu avant que l''huile ait séché (ce qui demande 1 minute), la cible subit 5 dégâts de feu supplémentaires, provoqués par l''embrasement de l''huile.</p>
<p><strong>Asperger un espace.</strong> Entreprendre l''action Utilisation permet d''étaler le contenu d''une flasque d''huile sur un sol plan et de couvrir une zone de 1,50 m de côté dans un rayon de 1,50 m. Embrasée, l''huile brûle jusqu''à la fin du tour 2 rounds après son allumage (soit pendant 12 secondes) et inflige 5 dégâts de feu à toute créature qui pénètre dans la zone ou y termine son tour. Une même créature ne peut subir ces dégâts qu''une fois par tour.</p>
<p><strong>Combustible.</strong> L''huile sert de combustible pour les lampes et les lanternes. Le contenu d''une flasque d''huile embrasée brûle pendant 6 heures dans une lampe ou une lanterne. Cette durée n''est pas nécessairement consécutive ; vous pouvez éteindre l''huile (par une action Utilisation) et la rallumer jusqu''à ce qu''elle ait brûlé pendant un total de 6 heures.</p>', 1, 0, @res, NULL, @dd24),
  ('Lampe', @cae_materiel_d_aventurier, 50, NULL, 500, NULL, NULL, 340, '<p>Une lampe brûle de l''huile comme combustible et produit une Lumière vive sur un rayon de 4,50 m, ainsi qu''une Lumière faible sur 9 m de plus.</p>', 1, 0, @res, NULL, @dd24),
  ('Lanterne à capote', @cae_materiel_d_aventurier, 500, NULL, 1000, NULL, NULL, 350, '<p>Une lanterne à capote brûle de l''huile comme combustible et produit une Lumière vive sur un rayon de 9 m, ainsi qu''une Lumière faible sur 9 m de plus. Abaisser la capote par une action Bonus permet de réduire l''éclairage à une Lumière faible sur un rayon de 1,50 m, et la relever de rétablir la pleine lumière.</p>', 1, 0, @res, NULL, @dd24),
  ('Lanterne sourde', @cae_materiel_d_aventurier, 1000, NULL, 1000, NULL, NULL, 360, '<p>Une lanterne sourde brûle de l''huile comme combustible et produit une Lumière vive sur un Cône de 18 m, ainsi qu''une Lumière faible sur 18 m de plus.</p>', 1, 0, @res, NULL, @dd24),
  ('Livre', @cae_materiel_d_aventurier, 2500, NULL, 2500, NULL, NULL, 370, '<p>Un livre traite de fiction ou de non-fiction. Si vous consultez un livre de non-fiction précis sur son sujet, vous recevez un bonus de +5 aux tests d''Intelligence (Arcanes, Histoire, Nature ou Religion) que vous effectuez sur ce sujet.</p>', 1, 0, @res, NULL, @dd24),
  ('Longue-vue', @cae_materiel_d_aventurier, 100000, NULL, 500, NULL, NULL, 380, '<p>Une longue-vue permet de grossir jusqu''à deux fois les objets que vous voyez à distance.</p>', 1, 0, @res, NULL, @dd24),
  ('Loupe', @cae_materiel_d_aventurier, 10000, NULL, NULL, NULL, NULL, 390, '<p>Une loupe octroie l''Avantage à tout test de caractéristique visant à inspecter ou estimer la valeur d''un objet très détaillé. Démarrer un feu avec une loupe nécessite une lumière aussi vive que celle du soleil, que la lentille concentre sur de l''amadou, lequel s''enflamme au bout d''environ 5 minutes.</p>', 1, 0, @res, NULL, @dd24),
  ('Matériel d''escalade', @cae_materiel_d_aventurier, 2500, NULL, 6000, NULL, NULL, 400, '<p>Le matériel d''escalade comprend des crampons de chaussures, des gants, des pitons et un harnais.</p>
<p>Par une action Utilisation, vous pouvez recourir au matériel d''escalade pour vous ancrer ; cette précaution prise, vous ne pouvez pas tomber à plus de 7,50 m du point d''ancrage, et vous ne pouvez pas vous en éloigner de plus de 7,50 m sans défaire préalablement l''ancrage par une action Bonus.</p>', 1, 0, @res, NULL, @dd24),
  ('Menottes', @cae_materiel_d_aventurier, 200, NULL, 3000, NULL, NULL, 410, '<p>Par une action Utilisation, vous menottez une créature non consentante de taille P ou de taille M située dans un rayon de 1,50 m et qui subit l''état Agrippé, Entravé ou Neutralisé à condition de réussir un test de Dextérité (Escamotage) DD 13. Tant qu''elle est menottée, la créature subit le Désavantage aux jets d''attaque, ainsi que l''état Entravé si les menottes sont attachées à une chaîne ou à un crochet fixe. Se libérer des menottes nécessite de réussir un test de Dextérité (Escamotage) DD 20 au prix d''une action. Les briser nécessite de réussir un test de Force (Athlétisme) DD 25 au prix d''une action.</p>
<p>Chaque paire de menottes est fournie avec une clef. Sans cette clef, une créature peut crocheter la serrure des menottes à condition de réussir un test de Dextérité (Escamotage) DD 15 avec des outils de voleur.</p>', 1, 0, @res, NULL, @dd24),
  ('Miroir', @cae_materiel_d_aventurier, 500, NULL, 250, NULL, NULL, 420, '<p>Ce miroir à main en acier est pratique pour se maquiller, mais aussi pour risquer un œil au détour d''un angle et réfléchir la lumière en guise de signal.</p>', 1, 0, @res, NULL, @dd24),
  ('Munitions', @cae_materiel_d_aventurier, NULL, 'Variable', NULL, 'Variable', NULL, 430, '<p>Les munitions sont nécessaires pour toute arme dotée de la propriété Munitions. Le descriptif de l''arme indique le type de munitions qu''elle utilise. La table « Munitions » répertorie les différents types de munitions et la quantité que vous obtenez lorsque vous en achetez. Figure en outre l''objet généralement utilisé pour ranger chaque type de munitions, qui doit être acheté séparément.</p>', 1, 0, @res, NULL, @dd24),
  ('Outre', @cae_materiel_d_aventurier, 20, NULL, 2500, NULL, NULL, 440, '<p>Une outre contient 2 litres de liquide. Boire insuffisamment d''eau, c''est s''exposer à la déshydratation (voir « Glossaire de règles »). Le poids indiqué est celui d''une outre pleine.</p>', 1, 0, @res, NULL, @dd24),
  ('Palan', @cae_materiel_d_aventurier, 100, NULL, 2500, NULL, NULL, 450, '<p>Un palan vous permet de soulever jusqu''à quatre fois le poids que vous pouvez normalement soulever.</p>', 1, 0, @res, NULL, @dd24),
  ('Panier', @cae_materiel_d_aventurier, 40, NULL, 1000, NULL, NULL, 460, '<p>Un panier contient jusqu''à 20 kg pour un volume de 60 litres ou 0,06 m³.</p>', 1, 0, @res, NULL, @dd24),
  ('Papier', @cae_materiel_d_aventurier, 20, NULL, NULL, NULL, NULL, 470, '<p>Une feuille de papier peut contenir environ 250 mots écrits à la main.</p>', 1, 0, @res, NULL, @dd24),
  ('Paquetage d''artiste', @cae_materiel_d_aventurier, 4000, NULL, 29000, NULL, NULL, 480, '<p>Le paquetage d''artiste contient les objets suivants : sac à dos, boîte à amadou, cloche, 3 costumes, 8 flasques d''huile, 9 jours de rations, lanterne sourde, miroir, outre, sac de couchage.</p>', 1, 0, @res, NULL, @dd24),
  ('Paquetage d''ecclésiastique', @cae_materiel_d_aventurier, 3300, NULL, 14500, NULL, NULL, 490, '<p>Le paquetage d''ecclésiastique contient les objets suivants : sac à dos, boîte à amadou, couverture, eau bénite, lampe, 7 jours de rations, robe.</p>', 1, 0, @res, NULL, @dd24),
  ('Paquetage d''érudit', @cae_materiel_d_aventurier, 4000, NULL, 11000, NULL, NULL, 500, '<p>Le paquetage d''érudit contient les objets suivants : sac à dos, boîte à amadou, encre, lampe, livre, porte-plume, 10 flasques d''huile, 10 feuilles de parchemin.</p>', 1, 0, @res, NULL, @dd24),
  ('Paquetage d''explorateur', @cae_materiel_d_aventurier, 1000, NULL, 27500, NULL, NULL, 510, '<p>Le paquetage d''explorateur contient les objets suivants : sac à dos, sac de couchage, boîte à amadou, corde, 2 flasques d''huile, 10 jours de rations, outre, 10 torches.</p>', 1, 0, @res, NULL, @dd24),
  ('Paquetage d''exploration souterraine', @cae_materiel_d_aventurier, 1200, NULL, 27500, NULL, NULL, 520, '<p>Le paquetage d''exploration souterraine contient les objets suivants : sac à dos, boîte à amadou, chausse-trappes, corde, 2 flasques d''huile, 10 jours de rations, outre, pied-de-biche, 10 torches.</p>', 1, 0, @res, NULL, @dd24),
  ('Paquetage de cambrioleur', @cae_materiel_d_aventurier, 1600, NULL, 21000, NULL, NULL, 530, '<p>Le paquetage de cambrioleur contient les objets suivants : sac à dos, billes, boîte à amadou, 10 bougies, cloche, corde, 7 flasques d''huile, lanterne à capote, outre, pied-de-biche, 5 jours de rations.</p>', 1, 0, @res, NULL, @dd24),
  ('Paquetage de diplomate', @cae_materiel_d_aventurier, 3900, NULL, 19500, NULL, NULL, 540, '<p>Le paquetage de diplomate contient les objets suivants : beaux habits, boîte à amadou, coffre, encre, 2 étuis à cartes et à parchemins, 5 feuilles de papier, 5 feuilles de parchemin, 4 flasques d''huile, lampe, 5 porte-plume, parfum.</p>', 1, 0, @res, NULL, @dd24),
  ('Parchemin', @cae_materiel_d_aventurier, 10, NULL, NULL, NULL, NULL, 550, '<p>Une feuille de parchemin peut contenir environ 250 mots écrits à la main.</p>', 1, 0, @res, NULL, @dd24),
  ('Parchemin de sort (1er niveau)', @cae_materiel_d_aventurier, 5000, NULL, NULL, NULL, NULL, 560, '<p>Un parchemin de sort est un objet magique qui porte la formule d''un sort mineur ou d''un sort du 1er niveau, tel que défini par le créateur du parchemin. Si ce sort figure dans votre liste de sorts de classe, vous pouvez lire le parchemin pour en lancer le sort avec son temps d''incantation habituel et sans en fournir les éventuelles composantes matérielles.</p>
<p>Si le sort nécessite un jet de sauvegarde ou un jet d''attaque, le DD de sauvegarde est de 13 et le bonus à l''attaque est de +5. Le parchemin se désintègre lorsque l''incantation est terminée.</p>', 1, 0, @res, NULL, @dd24),
  ('Parchemin de sort (sort mineur)', @cae_materiel_d_aventurier, 3000, NULL, NULL, NULL, NULL, 570, '<p>Un parchemin de sort est un objet magique qui porte la formule d''un sort mineur ou d''un sort du 1er niveau, tel que défini par le créateur du parchemin. Si ce sort figure dans votre liste de sorts de classe, vous pouvez lire le parchemin pour en lancer le sort avec son temps d''incantation habituel et sans en fournir les éventuelles composantes matérielles.</p>
<p>Si le sort nécessite un jet de sauvegarde ou un jet d''attaque, le DD de sauvegarde est de 13 et le bonus à l''attaque est de +5. Le parchemin se désintègre lorsque l''incantation est terminée.</p>', 1, 0, @res, NULL, @dd24),
  ('Parfum', @cae_materiel_d_aventurier, 500, NULL, NULL, NULL, NULL, 580, '<p>Le parfum est présenté dans un flacon de 120 ml. Pendant 1 heure après vous être appliqué du parfum, vous avez l''Avantage aux tests de Charisme (Persuasion) effectués afin d''influencer un Humanoïde Indifférent dans un rayon de 1,5 m.</p>', 1, 0, @res, NULL, @dd24),
  ('Pelle', @cae_materiel_d_aventurier, 200, NULL, 2500, NULL, NULL, 590, '<p>Au prix de 1 heure d''efforts, une pelle permet de creuser un trou de 1,5 m de côté pour autant de profondeur dans de la terre ou tout matériau similaire.</p>', 1, 0, @res, NULL, @dd24),
  ('Perche', @cae_materiel_d_aventurier, 5, NULL, 3500, NULL, NULL, 600, '<p>Une perche mesure 3 m de long. Vous pouvez l''utiliser pour toucher quelque chose à une distance maximale de 3 m. Si vous effectuez un test de Force (Athlétisme) dans le cadre d''un saut en hauteur ou en longueur, utiliser la perche pour sauter vous octroie l''Avantage à ce test.</p>', 1, 0, @res, NULL, @dd24),
  ('Pied-de-biche', @cae_materiel_d_aventurier, 200, NULL, 2500, NULL, NULL, 610, '<p>Le pied-de-biche vous octroie l''Avantage aux tests de Force chaque fois que son effet de levier peut être pris en compte.</p>', 1, 0, @res, NULL, @dd24),
  ('Piège à mâchoires', @cae_materiel_d_aventurier, 500, NULL, 12500, NULL, NULL, 620, '<p>Par une action Utilisation, vous posez un piège à mâchoires, anneau d''acier en dents de scie qui se referme lorsqu''une créature marche sur la plaque de pression centrale. Le piège est ancré par une lourde chaîne à un objet immobile, comme un arbre ou une pointe enfoncée dans le sol. Une créature qui marche sur la plaque doit réussir un jet de sauvegarde de Dextérité DD 13 sous peine de subir 1d4 dégâts perforants et de voir sa Vitesse réduite à 0 jusqu''au début de son tour suivant. Par la suite et jusqu''à ce que la créature se libère du piège, son déplacement est limité par la taille de la chaîne (en règle générale 90 cm de long).</p>
<p>Toute créature peut consacrer son action à effectuer un test de Force (Athlétisme) DD 13 et se libère, ou en extrait une autre créature à portée d''allonge, en cas de réussite. Chaque échec au test inflige 1 dégât perforant à la créature piégée.</p>', 1, 0, @res, NULL, @dd24),
  ('Pointes en fer', @cae_materiel_d_aventurier, 100, NULL, 2500, NULL, NULL, 630, '<p>Les pointes en fer sont vendues par paquets de dix. Par une action Utilisation, vous pouvez recourir à un objet contondant, par exemple un marteau léger, pour enfoncer une pointe dans du bois, de la terre ou tout matériau similaire. Faire ainsi permet de bloquer une porte ou d''attacher une corde ou une chaîne à la pointe.</p>', 1, 0, @res, NULL, @dd24),
  ('Poison standard', @cae_materiel_d_aventurier, 10000, NULL, NULL, NULL, NULL, 640, '<p>Par une action Bonus, utiliser une fiole de poison standard vous permet d''enduire une arme ou jusqu''à trois munitions. Une créature qui subit des dégâts perforants ou tranchants de l''arme ou des munitions empoisonnées subit 1d4 dégâts de poison supplémentaires. Une fois appliqué, le poison conserve sa virulence pendant 1 minute ou jusqu''à ce que ces dégâts soient infligés, selon ce qui survient en premier.</p>', 1, 0, @res, NULL, @dd24),
  ('Porte-plume', @cae_materiel_d_aventurier, 2, NULL, NULL, NULL, NULL, 650, '<p>Combiné à l''encre, le porte-plume permet d''écrire ou de dessiner.</p>', 1, 0, @res, NULL, @dd24),
  ('Pot en fer', @cae_materiel_d_aventurier, 200, NULL, 5000, NULL, NULL, 660, '<p>Un pot en fer contient jusqu''à 4 litres de liquide.</p>', 1, 0, @res, NULL, @dd24),
  ('Potion de guérison', @cae_materiel_d_aventurier, 5000, NULL, 250, NULL, NULL, 670, '<p>Cette potion est un objet magique. Par une action Bonus, vous pouvez boire une potion de guérison ou l''administrer à une autre créature dans un rayon de 1,50 m. La créature qui boit le liquide magique rouge contenu dans cette fiole récupère 2d4 + 2 points de vie.</p>', 1, 0, @res, NULL, @dd24),
  ('Rations', @cae_materiel_d_aventurier, 50, NULL, 1000, NULL, NULL, 680, '<p>Les rations sont composées d''aliments de voyage, viande séchée, fruits secs, biscuits et fruits à coque. Voir à « Malnutrition » dans le « Glossaire de règles » pour les risques liés à l''absence de nourriture.</p>', 1, 0, @res, NULL, @dd24),
  ('Robe', @cae_materiel_d_aventurier, 100, NULL, 2000, NULL, NULL, 690, '<p>Une robe a une signification professionnelle ou cérémonielle. Certains événements et lieux n''admettent que les personnes vêtues d''une robe d''une couleur donnée ou arborant certains symboles.</p>', 1, 0, @res, NULL, @dd24),
  ('Sac', @cae_materiel_d_aventurier, 1, NULL, 250, NULL, NULL, 700, '<p>Un sac contient jusqu''à 15 kg pour un volume de 0,03 m³.</p>', 1, 0, @res, NULL, @dd24),
  ('Sac à dos', @cae_materiel_d_aventurier, 200, NULL, 2500, NULL, NULL, 710, '<p>Un sac à dos contient jusqu''à 15 kg pour un volume de 30 litres ou 0,03 m³. Il peut également servir de sacoche de selle.</p>', 1, 0, @res, NULL, @dd24),
  ('Sac de couchage', @cae_materiel_d_aventurier, 100, NULL, 3500, NULL, NULL, 720, '<p>Un sac de couchage permet à une créature de taille P ou M de dormir. Dans un sac de couchage, vous réussissez automatiquement vos jets de sauvegarde contre le froid extrême (voir « Boîte à outils ludique »).</p>', 1, 0, @res, NULL, @dd24),
  ('Sacoche', @cae_materiel_d_aventurier, 50, NULL, 500, NULL, NULL, 730, '<p>Une sacoche contient jusqu''à 3 kg pour un volume de 0,006 m³.</p>', 1, 0, @res, NULL, @dd24),
  ('Sacoche à composantes', @cae_materiel_d_aventurier, 2500, NULL, 1000, NULL, NULL, 740, '<p>Une sacoche à composantes est étanche et divisée en compartiments qui permettent d''y ranger toutes les composantes matérielles gratuites de vos sorts.</p>', 1, 0, @res, NULL, @dd24),
  ('Seau', @cae_materiel_d_aventurier, 5, NULL, 1000, NULL, NULL, 750, '<p>Un seau contient 15 litres de liquide ou 0,015 m³.</p>', 1, 0, @res, NULL, @dd24),
  ('Sifflet', @cae_materiel_d_aventurier, 5, NULL, NULL, NULL, NULL, 760, '<p>Souffler dans le sifflet par une action Utilisation produit un son audible à 180 m.</p>', 1, 0, @res, NULL, @dd24),
  ('Symbole sacré', @cae_materiel_d_aventurier, NULL, 'Variable', NULL, 'Variable', NULL, 770, '<p>Un symbole sacré, qui prend l''une des formes proposées dans la table Symboles sacrés, est serti de pierreries ou peint afin de canaliser la magie divine. Clercs et Paladins peuvent se servir d''un symbole sacré comme focaliseur d''incantation.</p>
<p>La table indique si un symbole sacré doit être tenu, porté ou cousu sur une étoffe, par exemple sur un tabard ou une bannière, ou fixé sur un bouclier.</p>', 1, 0, @res, NULL, @dd24),
  ('Tente', @cae_materiel_d_aventurier, 200, NULL, 10000, NULL, NULL, 780, '<p>Jusqu''à deux créatures de taille P ou M peuvent dormir sous la même tente.</p>', 1, 0, @res, NULL, @dd24),
  ('Tenue de voyage', @cae_materiel_d_aventurier, 200, NULL, 2000, NULL, NULL, 790, '<p>La tenue de voyage comprend des vêtements résistants, conçus pour voyager dans divers environnements.</p>', 1, 0, @res, NULL, @dd24),
  ('Tonneau', @cae_materiel_d_aventurier, 200, NULL, 35000, NULL, NULL, 800, '<p>Un tonneau contient jusqu''à 140 litres de liquide ou 0,12 m³ de solide.</p>', 1, 0, @res, NULL, @dd24),
  ('Torche', @cae_materiel_d_aventurier, 1, NULL, 500, NULL, NULL, 810, '<p>Une torche brûle pendant 1 heure, produit une Lumière vive sur un rayon de 6 m et une Lumière faible sur 6 m de plus. Dans le cadre de l''action Attaque, vous pouvez attaquer avec la torche, en considérant celle-ci comme une arme courante de corps à corps. Si l''attaque touche, la cible subit 1 dégât de feu.</p>', 1, 0, @res, NULL, @dd24),
  ('Trousse de soins', @cae_materiel_d_aventurier, 500, NULL, 1500, NULL, NULL, 820, '<p>Une trousse de soins dispose de dix charges. Par une action Utilisation, dépenser une charge permet de stabiliser une créature avec l''état Inconscient et tombée à 0 point de vie sans passer par un test de Sagesse (Médecine).</p>', 1, 0, @res, NULL, @dd24);

-- munitions
INSERT INTO dd_equipements (eqt_nom, eqt_cae_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt,
  eqt_attributs, eqt_ordre, eqt_description, eqt_visible, eqt_public, eqt_res_id, eqt_camp_id, eqt_ruleset_var_id) VALUES
  ('Balles d''arme à feu', @cae_munitions, 300, NULL, 1000, NULL, '{"quantite":"10","rangement":"Sacoche"}', 10, NULL, 1, 0, @res, NULL, @dd24),
  ('Billes de fronde', @cae_munitions, 4, NULL, 750, NULL, '{"quantite":"20","rangement":"Sacoche"}', 20, NULL, 1, 0, @res, NULL, @dd24),
  ('Carreaux', @cae_munitions, 100, NULL, 750, NULL, '{"quantite":"20","rangement":"Étui"}', 30, NULL, 1, 0, @res, NULL, @dd24),
  ('Dards', @cae_munitions, 100, NULL, 500, NULL, '{"quantite":"50","rangement":"Sacoche"}', 40, NULL, 1, 0, @res, NULL, @dd24),
  ('Flèches', @cae_munitions, 100, NULL, 500, NULL, '{"quantite":"20","rangement":"Carquois"}', 50, NULL, 1, 0, @res, NULL, @dd24);

-- focaliseurs-arcaniques
INSERT INTO dd_equipements (eqt_nom, eqt_cae_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt,
  eqt_attributs, eqt_ordre, eqt_description, eqt_visible, eqt_public, eqt_res_id, eqt_camp_id, eqt_ruleset_var_id) VALUES
  ('Baguette', @cae_focaliseurs_arcaniques, 1000, NULL, 500, NULL, NULL, 10, NULL, 1, 0, @res, NULL, @dd24),
  ('Bâton (également bâton de combat)', @cae_focaliseurs_arcaniques, 500, NULL, 2000, NULL, NULL, 20, NULL, 1, 0, @res, NULL, @dd24),
  ('Cristal', @cae_focaliseurs_arcaniques, 1000, NULL, 500, NULL, NULL, 30, NULL, 1, 0, @res, NULL, @dd24),
  ('Orbe', @cae_focaliseurs_arcaniques, 2000, NULL, 1500, NULL, NULL, 40, NULL, 1, 0, @res, NULL, @dd24),
  ('Sceptre', @cae_focaliseurs_arcaniques, 1000, NULL, 1000, NULL, NULL, 50, NULL, 1, 0, @res, NULL, @dd24);

-- focaliseurs-druidiques
INSERT INTO dd_equipements (eqt_nom, eqt_cae_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt,
  eqt_attributs, eqt_ordre, eqt_description, eqt_visible, eqt_public, eqt_res_id, eqt_camp_id, eqt_ruleset_var_id) VALUES
  ('Baguette d''if', @cae_focaliseurs_druidiques, 1000, NULL, 500, NULL, NULL, 10, NULL, 1, 0, @res, NULL, @dd24),
  ('Bâton en bois (également bâton de combat)', @cae_focaliseurs_druidiques, 500, NULL, 2000, NULL, NULL, 20, NULL, 1, 0, @res, NULL, @dd24),
  ('Branche de houx', @cae_focaliseurs_druidiques, 100, NULL, NULL, NULL, NULL, 30, NULL, 1, 0, @res, NULL, @dd24);

-- symboles-sacres
INSERT INTO dd_equipements (eqt_nom, eqt_cae_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt,
  eqt_attributs, eqt_ordre, eqt_description, eqt_visible, eqt_public, eqt_res_id, eqt_camp_id, eqt_ruleset_var_id) VALUES
  ('Amulette (portée ou tenue)', @cae_symboles_sacres, 500, NULL, 500, NULL, NULL, 10, NULL, 1, 0, @res, NULL, @dd24),
  ('Emblème (cousu sur une étoffe ou fixé sur un bouclier)', @cae_symboles_sacres, 500, NULL, NULL, NULL, NULL, 20, NULL, 1, 0, @res, NULL, @dd24),
  ('Reliquaire (tenu)', @cae_symboles_sacres, 500, NULL, 1000, NULL, NULL, 30, NULL, 1, 0, @res, NULL, @dd24);

-- montures-et-autres-animaux
INSERT INTO dd_equipements (eqt_nom, eqt_cae_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt,
  eqt_attributs, eqt_ordre, eqt_description, eqt_visible, eqt_public, eqt_res_id, eqt_camp_id, eqt_ruleset_var_id) VALUES
  ('Chameau', @cae_montures_et_autres_animaux, 5000, NULL, NULL, NULL, '{"capacite":"225 kg"}', 10, NULL, 1, 0, @res, NULL, @dd24),
  ('Cheval de selle', @cae_montures_et_autres_animaux, 7500, NULL, NULL, NULL, '{"capacite":"240 kg"}', 20, NULL, 1, 0, @res, NULL, @dd24),
  ('Cheval de trait', @cae_montures_et_autres_animaux, 5000, NULL, NULL, NULL, '{"capacite":"270 kg"}', 30, NULL, 1, 0, @res, NULL, @dd24),
  ('Destrier', @cae_montures_et_autres_animaux, 40000, NULL, NULL, NULL, '{"capacite":"270 kg"}', 40, NULL, 1, 0, @res, NULL, @dd24),
  ('Éléphant', @cae_montures_et_autres_animaux, 20000, NULL, NULL, NULL, '{"capacite":"660 kg"}', 50, NULL, 1, 0, @res, NULL, @dd24),
  ('Molosse', @cae_montures_et_autres_animaux, 2500, NULL, NULL, NULL, '{"capacite":"97,5 kg"}', 60, NULL, 1, 0, @res, NULL, @dd24),
  ('Mule', @cae_montures_et_autres_animaux, 800, NULL, NULL, NULL, '{"capacite":"210 kg"}', 70, NULL, 1, 0, @res, NULL, @dd24),
  ('Poney', @cae_montures_et_autres_animaux, 3000, NULL, NULL, NULL, '{"capacite":"112,5 kg"}', 80, NULL, 1, 0, @res, NULL, @dd24);

-- harnachement-et-vehicules-tractes
INSERT INTO dd_equipements (eqt_nom, eqt_cae_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt,
  eqt_attributs, eqt_ordre, eqt_description, eqt_visible, eqt_public, eqt_res_id, eqt_camp_id, eqt_ruleset_var_id) VALUES
  ('Calèche', @cae_harnachement_et_vehicules_tractes, 10000, NULL, 300000, NULL, NULL, 10, NULL, 1, 0, @res, NULL, @dd24),
  ('Char', @cae_harnachement_et_vehicules_tractes, 25000, NULL, 50000, NULL, NULL, 20, NULL, 1, 0, @res, NULL, @dd24),
  ('Chariot', @cae_harnachement_et_vehicules_tractes, 3500, NULL, 200000, NULL, NULL, 30, NULL, 1, 0, @res, NULL, @dd24),
  ('Charrette', @cae_harnachement_et_vehicules_tractes, 1500, NULL, 100000, NULL, NULL, 40, NULL, 1, 0, @res, NULL, @dd24),
  ('Écuries, par jour', @cae_harnachement_et_vehicules_tractes, 50, NULL, NULL, NULL, NULL, 50, NULL, 1, 0, @res, NULL, @dd24),
  ('Fourrage (par jour)', @cae_harnachement_et_vehicules_tractes, 5, NULL, 5000, NULL, NULL, 60, NULL, 1, 0, @res, NULL, @dd24),
  ('Selle d''équitation', @cae_harnachement_et_vehicules_tractes, 1000, NULL, 12500, NULL, NULL, 70, '<p>La selle est livrée avec un mors, une bride, des rênes et tout autre équipement nécessaire à son utilisation.</p>', 1, 0, @res, NULL, @dd24),
  ('Selle exotique', @cae_harnachement_et_vehicules_tractes, 6000, NULL, 20000, NULL, NULL, 80, '<p>La selle est livrée avec un mors, une bride, des rênes et tout autre équipement nécessaire à son utilisation. Une selle exotique est nécessaire pour chevaucher une monture aquatique ou volante.</p>', 1, 0, @res, NULL, @dd24),
  ('Selle militaire', @cae_harnachement_et_vehicules_tractes, 2000, NULL, 15000, NULL, NULL, 90, '<p>La selle est livrée avec un mors, une bride, des rênes et tout autre équipement nécessaire à son utilisation. Une selle militaire octroie l''Avantage aux tests de caractéristique que vous effectuez pour rester en selle.</p>', 1, 0, @res, NULL, @dd24),
  ('Traîneau', @cae_harnachement_et_vehicules_tractes, 2000, NULL, 150000, NULL, NULL, 100, NULL, 1, 0, @res, NULL, @dd24);

-- vehicules-aeriens-et-bateaux
INSERT INTO dd_equipements (eqt_nom, eqt_cae_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt,
  eqt_attributs, eqt_ordre, eqt_description, eqt_visible, eqt_public, eqt_res_id, eqt_camp_id, eqt_ruleset_var_id) VALUES
  ('Barge', @cae_vehicules_aeriens_et_bateaux, 300000, NULL, NULL, NULL, '{"vitesse":"1,5 km/h","equipage":"1","passagers":"6","cargaison":"1/2","ca":"15","pv":"100","seuil":"10"}', 10, NULL, 1, 0, @res, NULL, @dd24),
  ('Barque', @cae_vehicules_aeriens_et_bateaux, 5000, NULL, NULL, NULL, '{"vitesse":"2,25 km/h","equipage":"1","passagers":"3","cargaison":"—","ca":"11","pv":"50","seuil":"—"}', 20, '<p>Une barque peut être portée et pèse 50 kg.</p>', 1, 0, @res, NULL, @dd24),
  ('Bateau à voiles', @cae_vehicules_aeriens_et_bateaux, 1000000, NULL, NULL, NULL, '{"vitesse":"3 km/h","equipage":"20","passagers":"20","cargaison":"100","ca":"15","pv":"300","seuil":"15"}', 30, NULL, 1, 0, @res, NULL, @dd24),
  ('Dirigeable', @cae_vehicules_aeriens_et_bateaux, 4000000, NULL, NULL, NULL, '{"vitesse":"12 km/h","equipage":"10","passagers":"20","cargaison":"1","ca":"13","pv":"300","seuil":"—"}', 40, NULL, 1, 0, @res, NULL, @dd24),
  ('Drakkar', @cae_vehicules_aeriens_et_bateaux, 1000000, NULL, NULL, NULL, '{"vitesse":"4,5 km/h","equipage":"40","passagers":"150","cargaison":"10","ca":"15","pv":"300","seuil":"15"}', 50, NULL, 1, 0, @res, NULL, @dd24),
  ('Galère', @cae_vehicules_aeriens_et_bateaux, 3000000, NULL, NULL, NULL, '{"vitesse":"6 km/h","equipage":"80","passagers":"—","cargaison":"150","ca":"15","pv":"500","seuil":"20"}', 60, NULL, 1, 0, @res, NULL, @dd24),
  ('Navire de guerre', @cae_vehicules_aeriens_et_bateaux, 2500000, NULL, NULL, NULL, '{"vitesse":"3,75 km/h","equipage":"60","passagers":"60","cargaison":"200","ca":"15","pv":"500","seuil":"20"}', 70, NULL, 1, 0, @res, NULL, @dd24);

-- repas-boisson-et-hebergement
INSERT INTO dd_equipements (eqt_nom, eqt_cae_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt,
  eqt_attributs, eqt_ordre, eqt_description, eqt_visible, eqt_public, eqt_res_id, eqt_camp_id, eqt_ruleset_var_id) VALUES
  ('Bière (pichet)', @cae_repas_boisson_et_hebergement, 4, NULL, NULL, NULL, NULL, 10, NULL, 1, 0, @res, NULL, @dd24),
  ('Fromage (tranche)', @cae_repas_boisson_et_hebergement, 10, NULL, NULL, NULL, NULL, 20, NULL, 1, 0, @res, NULL, @dd24),
  ('Pain (miche)', @cae_repas_boisson_et_hebergement, 2, NULL, NULL, NULL, NULL, 30, NULL, 1, 0, @res, NULL, @dd24),
  ('Repas misérable', @cae_repas_boisson_et_hebergement, 1, NULL, NULL, NULL, NULL, 40, NULL, 1, 0, @res, NULL, @dd24),
  ('Repas pauvre', @cae_repas_boisson_et_hebergement, 2, NULL, NULL, NULL, NULL, 50, NULL, 1, 0, @res, NULL, @dd24),
  ('Repas modeste', @cae_repas_boisson_et_hebergement, 10, NULL, NULL, NULL, NULL, 60, NULL, 1, 0, @res, NULL, @dd24),
  ('Repas confortable', @cae_repas_boisson_et_hebergement, 20, NULL, NULL, NULL, NULL, 70, NULL, 1, 0, @res, NULL, @dd24),
  ('Repas riche', @cae_repas_boisson_et_hebergement, 30, NULL, NULL, NULL, NULL, 80, NULL, 1, 0, @res, NULL, @dd24),
  ('Repas aristocratique', @cae_repas_boisson_et_hebergement, 60, NULL, NULL, NULL, NULL, 90, NULL, 1, 0, @res, NULL, @dd24),
  ('Séjour à l''auberge misérable (par jour)', @cae_repas_boisson_et_hebergement, 7, NULL, NULL, NULL, NULL, 100, NULL, 1, 0, @res, NULL, @dd24),
  ('Séjour à l''auberge pauvre (par jour)', @cae_repas_boisson_et_hebergement, 10, NULL, NULL, NULL, NULL, 110, NULL, 1, 0, @res, NULL, @dd24),
  ('Séjour à l''auberge modeste (par jour)', @cae_repas_boisson_et_hebergement, 50, NULL, NULL, NULL, NULL, 120, NULL, 1, 0, @res, NULL, @dd24),
  ('Séjour à l''auberge confortable (par jour)', @cae_repas_boisson_et_hebergement, 80, NULL, NULL, NULL, NULL, 130, NULL, 1, 0, @res, NULL, @dd24),
  ('Séjour à l''auberge riche (par jour)', @cae_repas_boisson_et_hebergement, 200, NULL, NULL, NULL, NULL, 140, NULL, 1, 0, @res, NULL, @dd24),
  ('Séjour à l''auberge aristocratique (par jour)', @cae_repas_boisson_et_hebergement, 400, NULL, NULL, NULL, NULL, 150, NULL, 1, 0, @res, NULL, @dd24),
  ('Vin ordinaire (bouteille)', @cae_repas_boisson_et_hebergement, 20, NULL, NULL, NULL, NULL, 160, NULL, 1, 0, @res, NULL, @dd24),
  ('Vin fin (bouteille)', @cae_repas_boisson_et_hebergement, 1000, NULL, NULL, NULL, NULL, 170, NULL, 1, 0, @res, NULL, @dd24);

-- employes
INSERT INTO dd_equipements (eqt_nom, eqt_cae_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt,
  eqt_attributs, eqt_ordre, eqt_description, eqt_visible, eqt_public, eqt_res_id, eqt_camp_id, eqt_ruleset_var_id) VALUES
  ('Employé qualifié', @cae_employes, NULL, '2 po par jour', NULL, NULL, NULL, 10, '<p>On parle d''employé qualifié pour toute personne chargée d''accomplir un service demandant de disposer d''une maîtrise (que ce soit d''arme, d''outil ou de compétence) : mercenaire, artisan, scribe, etc. Le salaire indiqué est un minimum ; certains employés experts exigent un montant plus élevé.</p>', 1, 0, @res, NULL, @dd24),
  ('Employé sans formation', @cae_employes, NULL, '2 pa par jour', NULL, NULL, NULL, 20, '<p>Les employés sans formation sont chargés des tâches qui ne nécessitent pas de maîtrise particulière, de type manœuvre et portefaix.</p>', 1, 0, @res, NULL, @dd24),
  ('Messager', @cae_employes, NULL, '2 pc par 1,5 km', NULL, NULL, NULL, 30, NULL, 1, 0, @res, NULL, @dd24);

-- services-d-incantation
INSERT INTO dd_equipements (eqt_nom, eqt_cae_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt,
  eqt_attributs, eqt_ordre, eqt_description, eqt_visible, eqt_public, eqt_res_id, eqt_camp_id, eqt_ruleset_var_id) VALUES
  ('Sort mineur', @cae_services_d_incantation, 3000, NULL, NULL, NULL, '{"disponibilite":"Village, bourgade ou ville"}', 10, '<p>Si un sort nécessite des composantes coûteuses, ajoutez le coût de ces composantes au prix indiqué. Plus un sort est d''un niveau élevé, plus il est difficile de trouver quelqu''un qui puisse le lancer.</p>', 1, 0, @res, NULL, @dd24),
  ('Sort du 1er niveau', @cae_services_d_incantation, 5000, NULL, NULL, NULL, '{"disponibilite":"Village, bourgade ou ville"}', 20, '<p>Si un sort nécessite des composantes coûteuses, ajoutez le coût de ces composantes au prix indiqué. Plus un sort est d''un niveau élevé, plus il est difficile de trouver quelqu''un qui puisse le lancer.</p>', 1, 0, @res, NULL, @dd24),
  ('Sort du 2e niveau', @cae_services_d_incantation, 20000, NULL, NULL, NULL, '{"disponibilite":"Village, bourgade ou ville"}', 30, '<p>Si un sort nécessite des composantes coûteuses, ajoutez le coût de ces composantes au prix indiqué. Plus un sort est d''un niveau élevé, plus il est difficile de trouver quelqu''un qui puisse le lancer.</p>', 1, 0, @res, NULL, @dd24),
  ('Sort du 3e niveau', @cae_services_d_incantation, 30000, NULL, NULL, NULL, '{"disponibilite":"Bourgade ou ville uniquement"}', 40, '<p>Si un sort nécessite des composantes coûteuses, ajoutez le coût de ces composantes au prix indiqué. Plus un sort est d''un niveau élevé, plus il est difficile de trouver quelqu''un qui puisse le lancer.</p>', 1, 0, @res, NULL, @dd24),
  ('Sort des 4e et 5e niveaux', @cae_services_d_incantation, 200000, NULL, NULL, NULL, '{"disponibilite":"Bourgade ou ville uniquement"}', 50, '<p>Si un sort nécessite des composantes coûteuses, ajoutez le coût de ces composantes au prix indiqué. Plus un sort est d''un niveau élevé, plus il est difficile de trouver quelqu''un qui puisse le lancer.</p>', 1, 0, @res, NULL, @dd24),
  ('Sort des 6e à 8e niveaux', @cae_services_d_incantation, 2000000, NULL, NULL, NULL, '{"disponibilite":"Ville uniquement"}', 60, '<p>Si un sort nécessite des composantes coûteuses, ajoutez le coût de ces composantes au prix indiqué. Plus un sort est d''un niveau élevé, plus il est difficile de trouver quelqu''un qui puisse le lancer.</p>', 1, 0, @res, NULL, @dd24),
  ('Sort du 9e niveau', @cae_services_d_incantation, 10000000, NULL, NULL, NULL, '{"disponibilite":"Ville uniquement"}', 70, '<p>Si un sort nécessite des composantes coûteuses, ajoutez le coût de ces composantes au prix indiqué. Plus un sort est d''un niveau élevé, plus il est difficile de trouver quelqu''un qui puisse le lancer.</p>', 1, 0, @res, NULL, @dd24);

COMMIT;
