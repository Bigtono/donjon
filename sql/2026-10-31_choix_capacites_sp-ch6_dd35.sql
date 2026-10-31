-- sql/2026-10-31_choix_capacites_sp-ch6_dd35.sql
-- SP-CH6 — Capacités de classe DD3.5 qui imposent un choix au joueur (suite de sp-ch0)
-- (Renommée : « …_dd35_sp-ch6 » passait avant « …_sp-ch0 » dans l'ordre alphabétique du moteur et échouait faute des colonnes de sp-ch0.)
--
-- Lecture des textes des 270 couples classe × capacité DD3.5 ; retenues ici celles où le texte demande un
-- choix à CHAQUE niveau d'affectation (1 choix par niveau) :
--   mode don   : Don supplémentaire (Guerrier psychique, Magicien, Champion occultiste, Éclaireur, Tourmenteur,
--                Gardien du feu sacré du Phénix), Don de Métamagie (Adepte de l'ombre), Don de Vol (Magiciel du Zhentarim)
--   mode texte : Pouvoir spécial (Hiérophante), Secret et Langage supplémentaire (Gardien du savoir), Pouvoirs
--                spéciaux (Roublard), Ennemis jurés (Rôdeur), Maîtrise de terrain (Arpenteur d'horizon),
--                Résistance aux énergies destructives (Élu divin)
-- Capacités et classes désignées par leur NOM (les ids peuvent différer en production). Seules les affectations
-- de la classe visée reçoivent cc_nb_choix = 1. Pas de DELIMITER.

SET NAMES utf8mb4;
SET @rs35 := (SELECT var_id FROM dd_variables WHERE var_cat = 'ruleset' AND var_valeur = 'DD3.5' LIMIT 1);

-- Guerrier psychique — Don supplémentaire (niv 1,2,5,8,11,14,17,20)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'don'
 WHERE TRIM(cap.cap_nom) = 'Don supplémentaire' AND TRIM(cla.cla_nom) = 'Guerrier psychique' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Don supplémentaire' AND TRIM(cla.cla_nom) = 'Guerrier psychique' AND cla.cla_ruleset_var_id = @rs35;

-- Magicien — Don supplémentaire (niv 5,10,15,20)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'don'
 WHERE TRIM(cap.cap_nom) = 'Don supplémentaire' AND TRIM(cla.cla_nom) = 'Magicien' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Don supplémentaire' AND TRIM(cla.cla_nom) = 'Magicien' AND cla.cla_ruleset_var_id = @rs35;

-- Champion occultiste — Don supplémentaire (niv 1)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'don'
 WHERE TRIM(cap.cap_nom) = 'Don supplémentaire' AND TRIM(cla.cla_nom) = 'Champion occultiste' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Don supplémentaire' AND TRIM(cla.cla_nom) = 'Champion occultiste' AND cla.cla_ruleset_var_id = @rs35;

-- Eclaireur — Don supplémentaire (niv 4,8,16,20)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'don'
 WHERE TRIM(cap.cap_nom) = 'Don supplémentaire' AND TRIM(cla.cla_nom) = 'Eclaireur' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Don supplémentaire' AND TRIM(cla.cla_nom) = 'Eclaireur' AND cla.cla_ruleset_var_id = @rs35;

-- Tourmenteur — Dons supplémentaires (niv 5,10,15,20)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'don'
 WHERE TRIM(cap.cap_nom) = 'Dons supplémentaires' AND TRIM(cla.cla_nom) = 'Tourmenteur' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Dons supplémentaires' AND TRIM(cla.cla_nom) = 'Tourmenteur' AND cla.cla_ruleset_var_id = @rs35;

-- Gardien du feu sacré du Phénix — Don supplémentaire (niv 5)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'don'
 WHERE TRIM(cap.cap_nom) = 'Don supplémentaire' AND TRIM(cla.cla_nom) = 'Gardien du feu sacré du Phénix' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Don supplémentaire' AND TRIM(cla.cla_nom) = 'Gardien du feu sacré du Phénix' AND cla.cla_ruleset_var_id = @rs35;

-- Adepte de l'ombre — Don de Métamagie (niv 5)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'don', cap.cap_choix_dado_id = (SELECT dado_id FROM dd_data_don WHERE dado_nom = 'Métamagie' AND dado_ruleset_var_id = @rs35 LIMIT 1)
 WHERE TRIM(cap.cap_nom) = 'Don de Métamagie' AND TRIM(cla.cla_nom) = 'Adepte de l''ombre' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Don de Métamagie' AND TRIM(cla.cla_nom) = 'Adepte de l''ombre' AND cla.cla_ruleset_var_id = @rs35;

-- Magiciel du Zhenarim — Don de Vol (niv 2,4)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'don'
 WHERE TRIM(cap.cap_nom) = 'Don de Vol' AND TRIM(cla.cla_nom) = 'Magiciel du Zhenarim' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Don de Vol' AND TRIM(cla.cla_nom) = 'Magiciel du Zhenarim' AND cla.cla_ruleset_var_id = @rs35;

-- Hiérophante — Pouvoir spécial (niv 1,2,3,4,5)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'texte'
 WHERE TRIM(cap.cap_nom) = 'Pouvoir spécial' AND TRIM(cla.cla_nom) = 'Hiérophante' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Pouvoir spécial' AND TRIM(cla.cla_nom) = 'Hiérophante' AND cla.cla_ruleset_var_id = @rs35;

-- Gardien du savoir — Secret (niv 1,3,5,7,9)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'texte'
 WHERE TRIM(cap.cap_nom) = 'Secret' AND TRIM(cla.cla_nom) = 'Gardien du savoir' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Secret' AND TRIM(cla.cla_nom) = 'Gardien du savoir' AND cla.cla_ruleset_var_id = @rs35;

-- Gardien du savoir — Langage supplémentaire (niv 4,8)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'texte'
 WHERE TRIM(cap.cap_nom) = 'Langage supplémentaire' AND TRIM(cla.cla_nom) = 'Gardien du savoir' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Langage supplémentaire' AND TRIM(cla.cla_nom) = 'Gardien du savoir' AND cla.cla_ruleset_var_id = @rs35;

-- Roublard — Pouvoirs spéciaux (niv 10,13,16,19)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'texte'
 WHERE TRIM(cap.cap_nom) = 'Pouvoirs spéciaux' AND TRIM(cla.cla_nom) = 'Roublard' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Pouvoirs spéciaux' AND TRIM(cla.cla_nom) = 'Roublard' AND cla.cla_ruleset_var_id = @rs35;

-- Rôdeur — Ennemis jurés (niv 1,5,10,15,20)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'texte'
 WHERE TRIM(cap.cap_nom) = 'Ennemis jurés' AND TRIM(cla.cla_nom) = 'Rôdeur' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Ennemis jurés' AND TRIM(cla.cla_nom) = 'Rôdeur' AND cla.cla_ruleset_var_id = @rs35;

-- Arpenteur d'horizon — Maîtrise de terrain (niv 1,2,3,4,5)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'texte'
 WHERE TRIM(cap.cap_nom) = 'Maîtrise de terrain' AND TRIM(cla.cla_nom) = 'Arpenteur d''horizon' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Maîtrise de terrain' AND TRIM(cla.cla_nom) = 'Arpenteur d''horizon' AND cla.cla_ruleset_var_id = @rs35;

-- Arpenteur d'horizon — Maîtrise de terrain planaire (niv 6,7,8,9,10)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'texte'
 WHERE TRIM(cap.cap_nom) = 'Maîtrise de terrain planaire' AND TRIM(cla.cla_nom) = 'Arpenteur d''horizon' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Maîtrise de terrain planaire' AND TRIM(cla.cla_nom) = 'Arpenteur d''horizon' AND cla.cla_ruleset_var_id = @rs35;

-- Elu divin — Résistance aux énergies destructives (niv 5,10,15)
UPDATE dd_capacites_speciales cap
  JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cap.cap_choix_mode = 'texte'
 WHERE TRIM(cap.cap_nom) = 'Résistance aux énergies destructives' AND TRIM(cla.cla_nom) = 'Elu divin' AND cla.cla_ruleset_var_id = @rs35;
UPDATE dd_classe_capacite cc
  JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  JOIN dd_classes cla ON cla.cla_id = cc.cc_cla_id
   SET cc.cc_nb_choix = 1
 WHERE TRIM(cap.cap_nom) = 'Résistance aux énergies destructives' AND TRIM(cla.cla_nom) = 'Elu divin' AND cla.cla_ruleset_var_id = @rs35;
