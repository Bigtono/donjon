-- sql/2026-10-31_choix_capacites_sp-ch6b_dd35.sql
-- SP-CH6b — Capacités DD3.5 à choix UNIQUE à l'obtention (suite de sp-ch6), toutes en mode texte :
-- (Renommée : « …_dd35_sp-ch6b » passait avant « …_sp-ch0 » dans l'ordre alphabétique du moteur — voir sp-ch6_dd35.)
--   Style de combat et Compagnon animal (Rôdeur), Arme distinctive (Kensaï), École de prédilection et Appel de
--   familier (Magicien), Appel de familier (Ensorceleur, Tourmenteur — capacité partagée), Compagnon animal (Druide),
--   Talent (Magiciel du Zhentarim : la compétence visée).
-- Capacités et classes désignées par leur NOM. Chaque affectation de la classe visée reçoit cc_nb_choix = 1.
-- Pas de DELIMITER.

SET NAMES utf8mb4;
SET @rs35 := (SELECT var_id FROM dd_variables WHERE var_cat = 'ruleset' AND var_valeur = 'DD3.5' LIMIT 1);

-- Rôdeur — Style de combat (niv 2)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'texte'
 WHERE TRIM(cap.cap_nom) = 'Style de combat' AND TRIM(cla.cla_nom) = 'Rôdeur' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Style de combat' AND TRIM(cla.cla_nom) = 'Rôdeur' AND cla.cla_ruleset_var_id = @rs35;

-- Kensai — Arme distinctive (niv 1)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'texte'
 WHERE TRIM(cap.cap_nom) = 'Arme distinctive' AND TRIM(cla.cla_nom) = 'Kensai' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Arme distinctive' AND TRIM(cla.cla_nom) = 'Kensai' AND cla.cla_ruleset_var_id = @rs35;

-- Magicien — Ecole de prédilection (niv 1)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'texte'
 WHERE TRIM(cap.cap_nom) = 'Ecole de prédilection' AND TRIM(cla.cla_nom) = 'Magicien' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Ecole de prédilection' AND TRIM(cla.cla_nom) = 'Magicien' AND cla.cla_ruleset_var_id = @rs35;

-- Magicien — Appel de familier (niv 1)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'texte'
 WHERE TRIM(cap.cap_nom) = 'Appel de familier' AND TRIM(cla.cla_nom) = 'Magicien' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Appel de familier' AND TRIM(cla.cla_nom) = 'Magicien' AND cla.cla_ruleset_var_id = @rs35;

-- Ensorceleur — Appel de familier (niv 1)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'texte'
 WHERE TRIM(cap.cap_nom) = 'Appel de familier' AND TRIM(cla.cla_nom) = 'Ensorceleur' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Appel de familier' AND TRIM(cla.cla_nom) = 'Ensorceleur' AND cla.cla_ruleset_var_id = @rs35;

-- Tourmenteur — Appel de familier (niv 4)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'texte'
 WHERE TRIM(cap.cap_nom) = 'Appel de familier' AND TRIM(cla.cla_nom) = 'Tourmenteur' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Appel de familier' AND TRIM(cla.cla_nom) = 'Tourmenteur' AND cla.cla_ruleset_var_id = @rs35;

-- Druide — Compagnon animal (druide) (ext) (niv 1)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'texte'
 WHERE TRIM(cap.cap_nom) = 'Compagnon animal (druide) (ext)' AND TRIM(cla.cla_nom) = 'Druide' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Compagnon animal (druide) (ext)' AND TRIM(cla.cla_nom) = 'Druide' AND cla.cla_ruleset_var_id = @rs35;

-- Rôdeur — Compagnon animal (rodeur) (niv 4)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'texte'
 WHERE TRIM(cap.cap_nom) = 'Compagnon animal (rodeur)' AND TRIM(cla.cla_nom) = 'Rôdeur' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Compagnon animal (rodeur)' AND TRIM(cla.cla_nom) = 'Rôdeur' AND cla.cla_ruleset_var_id = @rs35;

-- Magiciel du Zhenarim — Talent (niv 4)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'texte'
 WHERE TRIM(cap.cap_nom) = 'Talent' AND TRIM(cla.cla_nom) = 'Magiciel du Zhenarim' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Talent' AND TRIM(cla.cla_nom) = 'Magiciel du Zhenarim' AND cla.cla_ruleset_var_id = @rs35;
