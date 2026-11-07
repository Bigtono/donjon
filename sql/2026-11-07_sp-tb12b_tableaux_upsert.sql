-- sql/2026-11-07_sp-tb12b_tableaux_upsert.sql
-- SP-TB12d — Renvoi en production de toute la table dd_tableaux, catégories comprises
--
-- Généré le 2026-11-07 10:12 depuis la base locale, elle-même rechargée le jour même depuis le dump de
-- production (maikasteiydonj25_mysql_db-261107.sql) : les tab_id sont donc ceux de la production.
-- Upsert ligne à ligne par tab_id (D-TB23) : toutes les colonnes sont réécrites avec la version locale ;
-- un tableau créé en production après le dump n'est ni modifié ni supprimé.
-- Suppose 2026-11-07_sp-tb12a_categories_tableaux.sql (colonne tab_tabc_id, ids de catégorie 1 → 8).
-- 113 tableaux. Rejouable. Pas de DELIMITER.

SET NAMES utf8mb4;

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (1, 'description-des-caracteristiques', 'Description des caractéristiques', '! Caractéristique | Valeur représentant…\nForce | La puissance physique\nDextérité | L\'agilité, les réflexes et l\'équilibre\nConstitution | La santé et l\'endurance\nIntelligence | Les capacités de raisonnement et la mémoire\nSagesse | Le discernement et la fermeté mentale\nCharisme | La confiance en soi, l\'aplomb et le charme naturel', NULL, NULL, 7, 2, 91, NULL, 0, 0, 1, '2026-07-27 14:11:02', '2026-07-27 14:11:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (2, 'valeurs-de-caracteristique', 'Valeurs de caractéristique', '! Valeur | Signification\n1 | Valeur minimale. Quand un effet réduit une valeur à 0, la description explique ce qui se passe.\n2–9 | Capacités faibles.\n10–11 | Moyenne humaine.\n12–19 | Capacités remarquables.\n20 | Valeur maximale pour un aventurier, sauf mention contraire.\n21–29 | Capacités extraordinaires.\n30 | Valeur théorique maximale.', NULL, NULL, 7, 2, 91, NULL, 0, 0, 1, '2026-07-27 14:11:02', '2026-07-27 14:11:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (3, 'modificateurs-de-caracteristique', 'Modificateurs de caractéristique', '! Valeur | Modificateur | Valeur | Modificateur\n1 | −5 | 16–17 | +3\n2–3 | −4 | 18–19 | +4\n4–5 | −3 | 20–21 | +5\n6–7 | −2 | 22–23 | +6\n8–9 | −1 | 24–25 | +7\n10–11 | +0 | 26–27 | +8\n12–13 | +1 | 28–29 | +9\n14–15 | +2 | 30 | +10', NULL, NULL, 7, 2, 91, NULL, 0, 0, 1, '2026-07-27 14:11:02', '2026-07-27 14:11:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (4, 'bonus-de-maitrise', 'Bonus de maîtrise', '! Niveau | Bonus de maîtrise\n1–4 | +2\n5–8 | +3\n9–12 | +4\n13–16 | +5\n17–20 | +6\n21-24 | +7\n25-28 | +8\n29-30 | +9', NULL, NULL, 7, 2, 91, NULL, 1, 0, 1, '2026-07-27 14:11:02', '2026-08-28 19:35:49')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (5, 'degres-de-difficulte-courants', 'Degrés de difficulté courants', '! La tâche est… | DD\nTrès facile | 5\nFacile | 10\nModérée | 15\nDifficile | 20\nTrès difficile | 25\nPresque impossible | 30', NULL, NULL, 7, 2, 91, NULL, 0, 0, 1, '2026-07-27 14:11:02', '2026-07-27 14:11:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (6, 'caracteristiques-de-jet-d-attaque', 'Caractéristiques de jet d\'attaque', '! Caractéristique | Type d\'attaque\nForce | Attaque de corps à corps avec une arme ou attaque à mains nues\nDextérité | Attaque à distance avec une arme\nVariable | Attaque de sort (caractéristique définie par l\'aptitude Sorts)', NULL, NULL, 7, 2, 91, NULL, 0, 0, 1, '2026-07-27 14:11:02', '2026-07-27 14:11:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (7, 'competences', 'Compétences', '! Compétence | Caractéristique | Exemples d\'application\nAcrobaties | Dextérité | Rester debout lorsque l\'équilibre est précaire ou accomplir un exercice acrobatique.\nArcanes | Intelligence | Se souvenir de détails sur les sorts, les objets magiques ou les plans d\'existence.\nAthlétisme | Force | Sauter plus loin que la normale, nager dans des flots violents ou briser quelque chose.\nDiscrétion | Dextérité | Se déplacer sans faire de bruit et se cacher.\nDressage | Sagesse | Apaiser ou dresser un animal.\nHistoire | Intelligence | Se souvenir d\'événements historiques, peuples, nations et cultures.\nIntuition | Sagesse | Reconnaître l\'humeur et les intentions des gens.\nMédecine | Sagesse | Diagnostiquer une maladie ou déterminer les causes de morts récentes.\nNature | Intelligence | Connaître les terrains, plantes, animaux et phénomènes naturels.\nPerception | Sagesse | Détecter par les sens ce qui peut échapper à d\'autres.\nPersuasion | Charisme | Convaincre quelqu\'un avec de bonnes manières ou changer son humeur.\nReligion | Intelligence | Connaître les dieux, rituels et symboles sacrés.\nReprésentation | Charisme | Charmer ou divertir un public par la danse, la musique, le théâtre.\nSupercherie | Charisme | Mentir ou manipuler quelqu\'un.\nSurvie | Sagesse | Remonter une piste, trouver de la nourriture, s\'orienter et éviter les dangers sauvages.', NULL, NULL, 7, 2, 91, NULL, 0, 0, 1, '2026-07-27 14:11:02', '2026-07-27 14:11:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (8, 'actions-disponibles', 'Actions disponibles', '! Action | Résumé\nAttaque | Effectuer une attaque avec une arme ou à mains nues.\nDésengagement | Votre déplacement ne provoque pas d\'attaques d\'Opportunité pour le reste du tour.\nEsquive | Jusqu\'au début de votre tour suivant, les jets d\'attaque vous visant ont le Désavantage et vous avez l\'Avantage aux JS Dextérité. Vous perdez ce bénéfice si vous subissez l\'état Neutralisé ou si votre Vitesse tombe à 0.\nÉtude | Effectuer un test d\'Intelligence (Arcanes, Histoire, Investigation, Nature ou Religion)..\nFurtivité | Effectuer un test de Dextérité (Discrétion).\nInfluence | Effectuer un test de Charisme (Intimidation, Persuasion, Représentation ou Tromperie) ou de Sagesse (Dressage) pour influer sur l\'attitude d\'une créature.\nIntention | Se préparer à entreprendre une action en réaction à un déclencheur défini.\nMagie | Lancer un sort, utiliser un objet magique ou une aptitude magique.\nObservation | Effectuer un test de Sagesse (Intuition, Médecine, Perception ou Survie).\nPointe | Pour le reste du tour, vous bénéficiez d\'un déplacement supplémentaire égal à votre Vitesse.\nSoutien | Aider une autre créature dans un test ou un jet d\'attaque, ou lui administrer les premiers soins.\nUtilisation | Utiliser un objet non magique.', NULL, NULL, 7, 2, 91, NULL, 0, 0, 1, '2026-07-27 14:11:02', '2026-07-27 14:11:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (9, 'taille-des-creatures', 'Taille des créatures', '! Cat. de taille | Espace (mètres) | Espace (cases)\nTrès petite (TP) | 75 cm de côté | 4 par case\nPetite (P) | 1,50 m de côté | 1 case\nMoyenne (M) | 1,50 m de côté | 1 case\nGrande (G) | 3 m de côté | 4 cases (2 sur 2)\nTrès Grande (TG) | 4,50 m de côté | 9 cases (3 sur 3)\nGigantesque (Gig) | 6 m de côté | 16 cases (4 sur 4)', NULL, NULL, 7, 2, 91, NULL, 0, 0, 1, '2026-07-27 14:11:02', '2026-07-27 21:49:51')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (10, 'abris', 'Abris', '! Degré | Bénéfice pour la cible | Octroyé par\nPartiel | +2 à la CA et aux JS Dextérité | Une créature ou un objet qui protège au moins la moitié du corps\nSupérieur | +5 à la CA et aux JS Dextérité | Un objet qui abrite au moins les ¾ du corps de la cible', NULL, NULL, 7, 2, 91, NULL, 1, 0, 1, '2026-07-27 14:11:02', '2026-08-28 19:35:30')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (11, 'allure-de-voyage-par-environnement', 'Allure de voyage par environnement', '! Environnement | Allure maximale | Distance de rencontre | DD d’alimentation | DD d’orientation | DD d’observation\nArctique | Rapide* | 6d6 × 3 m | 20 | 10 | 10\nCollines | Normale | 2d10 × 3 m | 15 | 10 | 15\nDésert | Normale | 6d6 × 3 m | 20 | 10 | 10\nForêt | Normale | 2d8 × 3 m | 10 | 15 | 15\nLittoral | Normale | 2d10 × 3 m | 10 | 5 | 15\nMarais | Lente | 2d8 × 3 m | 10 | 15 | 20\nMontagnes | Lente | 4d10 × 3 m | 20 | 15 | 20\nOutreterre | Normale | 2d6 × 3 m | 20 | 10 | 20\nPlaine | Rapide | 6d6 × 3 m | 15 | 5 | 15\nUrbain | Normale | 2d6 × 3 m | 20 | 15 | 15\nVoie d’eau | Spéciale† | 6d6 × 3 m | 15 | 10 | 15', NULL, NULL, 7, 2, 91, NULL, 0, 0, 1, '2026-07-27 14:11:02', '2026-07-27 17:11:42')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (12, 'preparation-des-sorts-par-classe', 'Préparation des sorts par classe', '! Classe | Changez quand vous… | Nombre de sorts\nBarde | gagnez un niveau | Un\nClerc | terminez un Repos long | Libre\nDruide | terminez un Repos long | Libre\nEnsorceleur | gagnez un niveau | Un\nMagicien | terminez un Repos long | Libre\nOccultiste | gagnez un niveau | Un\nPaladin | terminez un Repos long | Un\nRôdeur | terminez un Repos long | Un', NULL, NULL, 4, 2, 91, NULL, 0, 0, 1, '2026-07-27 14:11:02', '2026-07-27 14:11:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (13, 'ecoles-de-magie', 'Écoles de magie', '! École | Effets typiques\nAbjuration | Empêche ou inverse les effets nocifs\nDivination | Révèle des informations\nEnchantement | Influence l\'esprit\nÉvocation | Canalise les énergies pour produire des effets souvent destructeurs\nIllusion | Trompe l\'esprit ou les sens\nInvocation | Transporte des créatures ou des objets\nNécromancie | Manipule la vie et la mort\nTransmutation | Transforme des créatures ou des objets', NULL, NULL, 4, 2, 91, NULL, 0, 0, 1, '2026-07-27 14:11:02', '2026-07-27 14:11:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (14, 'tests-de-caracteristique-typiques', 'Tests de caractéristique typiques', '! caractéristiques | Effectuer un test pour... \nForce | Soulever, pousser, tirer ou briser quelque chose\nDextérité | Vous déplacer avec agilité, vivacité ou furtivité\nConstitution | Repousser les limites ordinaires de votre organisme\nIntelligence | Mettre votre raison ou votre mémoire à l\'épreuve\nSagesse | Observer l\'environnement ou les comportements\nCharisme | Influencer, divertir ou tromper autrui', NULL, NULL, 7, 2, 91, NULL, 0, 0, 1, '2026-07-27 16:37:53', '2026-07-27 16:37:53')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (15, 'jets-de-sauvegarde-typiques', 'Jets de sauvegarde typiques', '! Caractéristique | Effectuez un JS pour…\nForce | Vous opposer à une force physique\nDextérité | Esquiver un danger physique\nConstitution | Supporter un danger toxique\nIntelligence | Percer une illusion\nSagesse | Résister à un assaut mental\nCharisme | Affirmer votre identité', NULL, NULL, 7, 2, 91, NULL, 0, 0, 1, '2026-07-27 16:40:38', '2026-07-27 16:40:38')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (16, 'allure-de-voyage', 'Allure de voyage', '# Distance parcourue par…\n! Allure | Minute | Heure | Jour\nRapide | 120 m | 6 km | 45 km\nNormale | 90 m | 4,5 km | 36 km\nLente | 60 m | 3 km | 27 km ', NULL, NULL, 7, 2, 91, NULL, 0, 0, 1, '2026-07-27 17:10:47', '2026-07-27 17:11:52')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (17, 'don-faconnage-rapide', 'Don Façonnage rapide', '! Outils d\'artisan | Équipement fabriqué\nOutils de bricoleur | Boîte à amadou, cloche, pelle\nOutils de charpentier | Échelle, torche\nOutils de forgeron | Billes, chausse-trappes, grappin, pot en fer, seau\nOutils de maçon | Palan\nOutils de menuisier | Gourdin, massue, bâton de combat\nOutils de potier | Cruche, lampe\nOutils de tanneur | Étui, sacoche\nOutils de tisserand | Corde, filet, panier, tente', NULL, NULL, 3, 2, 91, NULL, 0, 0, 1, '2026-08-10 21:13:23', '2026-08-10 21:13:23')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (18, 'des-d-energie-d-ame-aceree', 'Dés d\'énergie d\'Ame acérée', '! Niveau de Roublard | Taille de dé | Nombre\n3 | D6 | 4\n5 | D8 | 6\n9 | D8 | 8\n11 | D10 | 8\n13 | D10 | 10\n17 | D12 | 12', 'ccc', NULL, 1, 2, 91, NULL, 0, 0, 1, '2026-08-22 19:17:48', '2026-08-22 19:17:48')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (19, 'sorts-de-l-arnaqueur-arcanique', 'Sorts de l\'Arnaqueur arcanique', '! |  | -Emplacements par niveau de sort- | | |\n! Niveau de roublard | Sorts préparés | 1e | 2e | 3e | 4e \n3 | 3 | 2 | | | \n4 | 4 | 3 | | |   \ns | 4 | 3 | | |  \n6 | 4 | 3 | | |  \n7 | 5 | 4 | 2 | |  \n8 | 6 | 4 | 2 | |  \n9 | 6 | 4 | 2 | |  \n10 | 7 | 4 | 3 | | \n11 | 8 | 4 | 3 | |  \n12 | 8 | 4 | 3 | | \n13 | 9 | 4 | 3 | 2 | \n14 | 10 | 4 | 3 | 2 | \n15 | 10 | 4 | 3 | 2 | \n16 | 11 | 4 | 3 | 3 | \n17 | 11 | 4 | 3 | 3 | \n18 | 11 | 4 | 3 | 3 | \n19 | 12 | 4 | 3 | 3 | 1\n20 | 13 | 4 | 3 | 3 | 1', NULL, NULL, 1, 2, 91, NULL, 0, 0, 1, '2026-08-22 20:05:38', '2026-08-22 20:05:38')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (20, 'modificateurs-de-caracteristiques', 'Modificateurs de caractéristiques et sorts en bonus', '! Valeur | Modificateur | Sorts en bonus (par niveau de sort) | | | | | | | | |\n! ^ | ^ | 1er | 2e | 3e | 4e | 5e | 6e | 7e | 8e | 9e\n1 | −5 | — | — | — | — | — | — | — | — | —\n2–3 | −4 | — | — | — | — | — | — | — | — | —\n4–5 | −3 | — | — | — | — | — | — | — | — | —\n6–7 | −2 | — | — | — | — | — | — | — | — | —\n8–9 | −1 | — | — | — | — | — | — | — | — | —\n10–11 | 0 | — | — | — | — | — | — | — | — | —\n12–13 | +1 | 1 | — | — | — | — | — | — | — | —\n14–15 | +2 | 1 | 1 | — | — | — | — | — | — | —\n16–17 | +3 | 1 | 1 | 1 | — | — | — | — | — | —\n18–19 | +4 | 1 | 1 | 1 | 1 | — | — | — | — | —\n20–21 | +5 | 2 | 1 | 1 | 1 | 1 | — | — | — | —\n22–23 | +6 | 2 | 2 | 1 | 1 | 1 | 1 | — | — | —\n24–25 | +7 | 2 | 2 | 2 | 1 | 1 | 1 | 1 | — | —\n26–27 | +8 | 2 | 2 | 2 | 2 | 1 | 1 | 1 | 1 | —\n28–29 | +9 | 3 | 2 | 2 | 2 | 2 | 1 | 1 | 1 | 1\n30–31 | +10 | 3 | 3 | 2 | 2 | 2 | 2 | 1 | 1 | 1\n32–33 | +11 | 3 | 3 | 3 | 2 | 2 | 2 | 2 | 1 | 1\n34–35 | +12 | 3 | 3 | 3 | 3 | 2 | 2 | 2 | 2 | 1\n36–37 | +13 | 4 | 3 | 3 | 3 | 3 | 2 | 2 | 2 | 2\n38–39 | +14 | 4 | 4 | 3 | 3 | 3 | 3 | 2 | 2 | 2\n40–41 | +15 | 4 | 4 | 4 | 3 | 3 | 3 | 3 | 2 | 2\n42–43 | +16 | 4 | 4 | 4 | 4 | 3 | 3 | 3 | 3 | 2\n44–45 | +17 | 5 | 4 | 4 | 4 | 4 | 3 | 3 | 3 | 3\n> Une valeur de 9 ou moins dans la caractéristique primordiale interdit de lancer les sorts qui en dépendent ; il faut une valeur d\'au moins 10 + le niveau du sort.', 'ccccccccccc', NULL, 7, 1, 98, NULL, 0, 0, 1, '2026-08-25 22:32:13', '2026-08-25 22:32:13')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (25, 'terrain-foret', 'Éléments de terrain — forêts', '! Élément | Clairsemée | Moyenne | Dense\nArbres typiques | 30 % | 40 % | 60 %\nArbres massifs | — | 10 % | 20 %\nTaillis clairsemés | 50 % | 70 % | 50 %\nTaillis denses | — | 20 % | 50 %\n> Un arbre occupe une case et offre un abri (+4 CA, +2 Réflexes). Les taillis sont du terrain difficile procurant camouflage ; les taillis denses (DD Discrétion réduit, déplacement ÷ 4) exigent parfois un test d\'Évasion pour les traverser sans dommage.', 'lccc', NULL, 7, 1, 98, NULL, 0, 0, 1, '2026-08-25 22:32:13', '2026-08-25 22:32:13')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (26, 'terrain-marais', 'Éléments de terrain — marais', '! Élément | Marécage peu profond | Marécage profond\nFondrières peu profondes | 20 % | 40 %\nFondrières profondes | — | 20 %\nHaies de roseaux | 30 % | 60 %\n> Fondrière peu profonde : terrain difficile. Fondrière profonde : 1,20 m d\'eau — 4 cases de déplacement par case traversée, ou nage ; camouflage possible en s\'immergeant. Les roseaux procurent du camouflage et sont du terrain difficile.', 'lcc', NULL, 7, 1, 98, NULL, 0, 0, 1, '2026-08-25 22:32:13', '2026-08-25 22:32:13')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (27, 'terrain-collines', 'Éléments de terrain — collines', '! Élément | Collines douces | Collines escarpées\nPente douce | 75 % | 40 %\nPente escarpée | 20 % | 50 %\nFalaise | 5 % | 10 %\nÉboulis | — | —\n> Pente escarpée : terrain difficile en montée ; un personnage qui court ou charge en descente doit réussir un test d\'Équilibre (DD 10). Falaise : Escalade DD 15, hauteur typique 1d4 × 3 m.', 'lcc', NULL, 7, 1, 98, NULL, 0, 0, 1, '2026-08-25 22:32:13', '2026-08-25 22:32:13')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (28, 'terrain-montagnes', 'Éléments de terrain — montagnes', '! Élément | Alpages | Montagne rocailleuse | Montagne escarpée\nPente douce | 50 % | 25 % | 15 %\nPente escarpée | 40 % | 55 % | 55 %\nFalaise | 10 % | 15 % | 20 %\nÉboulis | — | 5 % | 10 %\n> Éboulis : terrain difficile, test d\'Équilibre (DD 10) pour courir ou charger. Paroi montagneuse : Escalade DD 15 à 25. Au-dessus de 4 500 m, l\'air raréfié impose un test de Vigueur horaire (DD 15, +1 cumulatif) sous peine de fatigue.', 'lccc', NULL, 7, 1, 98, NULL, 0, 0, 1, '2026-08-25 22:32:13', '2026-08-25 22:32:13')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (29, 'terrain-desert', 'Éléments de terrain — déserts', '! Élément | Désert de pierre | Désert de sable\nTerrain accidenté | 50 % | 10 %\nSable profond | 10 % | 50 %\nDunes | — | 40 %\n> Sable profond et dunes : terrain difficile. Le versant sous le vent d\'une dune compte comme une pente escarpée. Chaleur du jour, froid de la nuit et déshydratation : voir Chaleur et froid.', 'lcc', NULL, 7, 1, 98, NULL, 0, 0, 1, '2026-08-25 22:32:13', '2026-08-25 22:32:13')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (30, 'terrain-plaines', 'Éléments de terrain — plaines', '! Élément | Cultivée | Prairie | Steppe\nVégétation haute | 40 % | 60 % | 20 %\nTerrain accidenté | — | 10 % | 20 %\nHaies et murets | 20 % | 5 % | —\n> La végétation haute procure du camouflage à une créature à terre ou de taille P ; une haie ou un muret offre un abri (+4 CA).', 'lccc', NULL, 7, 1, 98, NULL, 0, 0, 1, '2026-08-25 22:32:13', '2026-08-25 22:32:13')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (31, 'climat-aleatoire', 'Climat aléatoire', '! d% | Temps | Plaines, forêts, collines | Désert\n01–70 | Temps de saison | Normal pour la saison | Chaleur normale\n71–80 | Temps anormal | Vague de chaleur (01–50) ou de froid (51–100) | Chaleur intense\n81–90 | Intempéries | Précipitations (pluie ou neige selon température) | Vent violent et poussière\n91–99 | Tempête | Orage, tempête de neige… | Tempête de sable\n100 | Tempête majeure | Blizzard, ouragan, tornade… | Tempête de sable violente\n> Jet à faire une fois par jour de voyage ; adapter à la saison et au climat régional.', 'cllc', NULL, 7, 1, 98, NULL, 0, 0, 1, '2026-08-25 22:32:13', '2026-08-25 22:32:13')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (32, 'effets-du-vent', 'Effets du vent', '! Force du vent | Vitesse | Attaques à distance | Taille emportée | Test de Vigueur (DD)\nBrise légère | 0–15 km/h | — | — | —\nBrise modérée | 16–30 km/h | — | — | —\nVent soutenu | 31–45 km/h | −2 | TP | 10\nVent violent | 46–75 km/h | −4 | P | 15\nBourrasques | 76–110 km/h | Impossibles¹ | M | 18\nVent de tempête | 111–130 km/h | Impossibles¹ | G | 20\nOuragan | 131–280 km/h | Impossibles¹ | TG | 25\nTornade | 281–500 km/h | Impossibles¹ | Gig | 30\n> 1. Sauf armes de siège (−4 par palier au-delà de « vent violent »). Une créature de la taille indiquée ou inférieure qui rate son test de Vigueur est stoppée (à pied) ou emportée : les créatures volantes subissent le palier de taille supérieur. Les vents soutenus et plus éteignent les flammes non protégées.', 'lcccc', NULL, 7, 1, 98, NULL, 0, 0, 1, '2026-08-25 22:32:13', '2026-08-25 22:32:13')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (33, 'pouvoirs-ext-mag-sur', 'Pouvoirs extraordinaires, magiques et surnaturels', '! Propriété | Ext | Mag | Sur\nPeut être dissipé | Non | Oui | Non\nSoumis à la résistance à la magie | Non | Oui | Non\nFonctionne dans une zone d\'antimagie | Oui | Non | Non\nSon utilisation provoque une attaque d\'opportunité | Non | Oui | Non\nPeut être contré | Non | Oui | Non', 'lccc', NULL, 7, 1, 98, NULL, 0, 0, 1, '2026-08-25 22:32:13', '2026-08-25 22:32:13')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (34, 'caracteristiques-des-types', 'Caractéristiques des types de créatures', '! Type | Dé de vie | BBA | Bons jets de sauvegarde | Points de compétence\nAberration | d8 | ×3/4 | Volonté | 2 + mod. Int\nAnimal | d8 | ×3/4 | Vigueur et Réflexes | 2 + mod. Int\nCréature artificielle | d10 | ×3/4 | Aucun | 2 + mod. Int¹\nCréature magique | d10 | ×1 | Vigueur et Réflexes | 2 + mod. Int\nDragon | d12 | ×1 | Vigueur, Réflexes et Volonté | 6 + mod. Int\nÉlémentaire | d8 | ×3/4 | Réflexes (air, feu) ou Vigueur (terre, eau) | 2 + mod. Int\nExtérieur | d8 | ×1 | Vigueur, Réflexes et Volonté | 8 + mod. Int\nFée | d6 | ×1/2 | Réflexes et Volonté | 6 + mod. Int\nGéant | d8 | ×3/4 | Vigueur | 2 + mod. Int\nHumanoïde | d8 | ×3/4 | Variable (un des trois) | 2 + mod. Int\nHumanoïde monstrueux | d8 | ×1 | Réflexes et Volonté | 2 + mod. Int\nMort-vivant | d12 | ×1/2 | Volonté | 4 + mod. Int\nPlante | d8 | ×3/4 | Vigueur | 2 + mod. Int¹\nVase | d10 | ×3/4 | Aucun | 2 + mod. Int¹\nVermine | d8 | ×3/4 | Vigueur | 2 + mod. Int¹\n> 1. Les créatures dépourvues d\'Intelligence ne reçoivent ni points de compétence ni dons. Points de compétence : minimum 1 par dé de vie, quadruplés au premier dé de vie.', 'lcccc', NULL, 5, 1, 98, NULL, 0, 0, 1, '2026-08-25 22:32:13', '2026-08-25 22:32:13')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (35, 'actions-au-combat', 'Actions au combat', '! Action | Attaque d\'opportunité ?\n# Actions simples\nAttaquer (corps à corps) | Non\nAttaquer (à distance) | Oui\nAttaquer (à mains nues) | Oui\nAider quelqu\'un | Peut-être¹\nBoire une potion ou appliquer une huile | Oui\nDégainer une arme cachée (Escamotage) | Non\nFeinter | Non\nLancer un sort (incantation d\'une action simple) | Oui\nPréparer une action (déclenche une action simple) | Non\nRengainer une arme | Oui\nStabiliser un mourant (Premiers secours) | Oui\nUtiliser un objet magique (hors potion) | Non\nUtiliser un pouvoir extraordinaire | Non\nUtiliser un pouvoir magique | Oui\nUtiliser un pouvoir surnaturel | Non\n# Actions de mouvement\nSe déplacer (jusqu\'à sa vitesse) | Oui²\nDégainer une arme | Non\nRamasser un objet | Oui\nRecharger une arbalète de poing ou légère | Oui\nRécupérer un objet rangé | Oui\nSe relever (depuis à terre) | Oui\nMonter en selle ou mettre pied à terre | Non\nOuvrir ou fermer une porte | Non\nDiriger un sort actif | Non\n# Actions complexes\nAttaque à outrance | Non\nCharger³ | Non\nCourir (×4) | Oui\nBattre en retraite | Non\nLancer un sort (incantation d\'un round complet) | Oui\nRecharger une arbalète lourde ou une arme à répétition | Oui\nAsséner le coup de grâce | Oui\nÉteindre les flammes qui vous consument | Non\nSe libérer d\'un filet ou d\'une entrave | Oui\n# Actions libres\nParler | Non\nLâcher un objet ou se jeter à terre | Non\nCesser de se concentrer sur un sort | Non\nIncanter un sort rapide | Non\n> 1. Selon la manière d\'aider. — 2. Quitter une case contrôlée provoque une attaque d\'opportunité ; le pas de placement de 1,50 m, jamais. — 3. La charge devient une action simple quand on ne dispose que d\'une action simple (round de surprise).', 'lc', NULL, 7, 1, 98, NULL, 0, 0, 1, '2026-08-25 22:32:26', '2026-08-25 22:32:26')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (36, 'modificateurs-du-jet-d-attaque', 'Modificateurs du jet d\'attaque', '! L\'attaquant est… | Corps à corps | À distance\nEn hauteur par rapport à la cible | +1 | +0\nInvisible | +2¹ | +2¹\nÀ terre | −4 | Impossible²\nAveuglé | −2¹ | −2¹\nEnchevêtré | −2³ | −2³\nPris en tenaille avec un allié | +2 | —\nSerré de près (au corps à corps) | — | −4⁴\nMonté sur une créature (cible à pied) | +1 | —\n> 1. La cible perd en outre son bonus de Dextérité à la CA (attaquant invisible) ; l\'attaquant aveuglé subit les 50 % de chances de rater du camouflage total. — 2. Sauf avec une arbalète ou une arme de poing. — 3. Et la Dextérité de l\'attaquant est limitée. — 4. Tirer sur une cible en mêlée : −4, annulé par le don Tir de précision.', 'lcc', NULL, 7, 1, 98, NULL, 0, 0, 1, '2026-08-25 22:32:26', '2026-08-25 22:32:26')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (37, 'modificateurs-de-ca', 'Modificateurs de la classe d\'armure', '! Le défenseur est… | Corps à corps | À distance\nDerrière un abri | +4 | +4\nAgenouillé ou assis | −2 | +2\nÀ terre | −4 | +4\nPris au dépourvu | Pas de bonus de Dex | Pas de bonus de Dex\nSans défense | −4¹ | +0¹\nAgrippé (en lutte) | +0² | +0²\nAveuglé | −2¹ | −2¹\nEscaladant un mur | −2¹ | −2¹\nCourant | — | −2\n> 1. Et perte du bonus de Dextérité à la CA. — 2. Le défenseur en lutte perd son bonus de Dextérité contre les adversaires extérieurs à la lutte.', 'lcc', NULL, 7, 1, 98, NULL, 0, 0, 1, '2026-08-25 22:32:26', '2026-08-25 22:32:26')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (38, 'combat-a-deux-armes', 'Combat à deux armes — malus aux jets d\'attaque', '! Circonstances | Main directrice | Main secondaire\nMalus de base | −6 | −10\nL\'arme secondaire est légère | −4 | −8\nDon Combat à deux armes | −4 | −4\nArme secondaire légère + don Combat à deux armes | −2 | −2\n> Une double arme (bâton, double lame…) suit les règles du combat à deux armes, sa seconde extrémité comptant comme une arme légère.', 'lcc', NULL, 7, 1, 98, NULL, 0, 0, 1, '2026-08-25 22:32:26', '2026-08-25 22:32:26')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (39, 'gestion-de-la-magie', 'Gestion de la magie', '! Moment | Scène | Description & Notes MJ\n\nAube — Journée entière | Événement 1 : La Tempête | Déclencher tôt le matin. Infliger des perturbations sans blesser grièvement les PJ : ruiner une monture, détruire un équipement, tuer un PNJ allié secondaire. La magie déraille dès maintenant → introduire la règle de Chaos Magique.\n\nMilieu de journée (hors-scène) | Événement 2A : Rencontre de Minuit et Mystra | Background MJ uniquement. Mystra remet le pendentif. Résultat : Minuit brille d\'un éclat bleu-blanc, pendentif serti sur sa peau.\n\nNuit (fin de tempête) | Événement 2B : L\'Entrée Dramatique de Minuit | Les PJ se réfugient à L\'Orgueil d\'Arabel (ou auberge choisie). La porte s\'ouvre violemment. Minuit s\'effondre. Le pendentif inflige 2d10 dégâts à qui le touche (2d12 tours). Minuit inconsciente, puis se réveille sans malaise.', NULL, NULL, 7, 2, 95, NULL, 0, 0, 1, '2026-08-28 09:31:04', '2026-08-28 09:31:04')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (40, 'ancetres-draconiques', 'Ancêtres draconiques', '! Dragon | Type de dégâts\nAirain | Feu\nArgent | Froid\nBlanc | Froid\nBleu | Foudre\nBronze | Foudre\nCuivre | Acide\nNoir | Acide\nOr | Feu\nRouge | Feu\nVert | Poison', 'll', NULL, 2, 2, 93, NULL, 0, 0, 1, '2026-08-28 14:51:29', '2026-08-28 15:11:43')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (41, 'lignages-elfiques', 'Lignages elfiques', '! Lignage | Niveau 1 | Niveau 3 | Niveau 5\nDrow | La portée de votre Vision dans le noir passe à 36 m. Vous connaissez également le sort mineur lumières dansantes. | lueurs féeriques | ténèbres\nElfe sylvestre | Votre Vitesse passe à 10,50 m. Vous connaissez également le sort mineur druidisme. | grande foulée | passage sans trace\nHaut-elfe | Vous connaissez le sort mineur prestidigitation. Chaque fois que vous terminez un Repos long, vous pouvez remplacer ce sort mineur par un autre sort mineur de la liste de sorts du Magicien. | détection de la magie | foulée brumeuse', 'llll', NULL, 2, 2, 93, NULL, 0, 0, 1, '2026-08-28 14:51:29', '2026-08-28 15:11:43')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (42, 'heritages-fielons', 'Héritages fiélons', '! Héritage | Niveau 1 | Niveau 3 | Niveau 5\nAbyssal | Vous bénéficiez de la Résistance aux dégâts de poison. Vous connaissez en outre le sort mineur bouffée de poison. | rayon empoisonné | immobilisation de personne\nChtonien | Vous bénéficiez de la Résistance aux dégâts nécrotiques. Vous connaissez en outre le sort mineur contact glacial. | simulacre de vie | rayon affaiblissant\nInfernal | Vous bénéficiez de la Résistance aux dégâts de feu. Vous connaissez en outre le sort mineur trait de feu. | représailles infernales | ténèbres', 'llll', NULL, 2, 2, 93, NULL, 0, 0, 1, '2026-08-28 14:51:29', '2026-08-28 15:11:43')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (43, 'amulette-des-plans-destinations', 'Amulette des plans — destinations', '! 1d100 | Destination\n01–60 | Emplacement aléatoire sur le plan que vous aviez nommé\n61–70 | Emplacement aléatoire sur un Plan Intérieur déterminé par le résultat de 1d6 : 1, le Plan de l’Air ; 2, le Plan de la Terre ; 3, le Plan du Feu ; 4, le Plan de l’Eau ; 5, la Féerie ; et 6, la Gisombre\n71–80 | Emplacement aléatoire sur un Plan Extérieur déterminé par le résultat de 1d8 : 1, l’Arborée ; 2, l’Arcadie ; 3, les Terres des Bêtes ; 4, la Bytopie ; 5, l’Élysée ; 6, Méchanus ; 7, le Mont Céleste ; et 8, Ysgard\n81–90 | Emplacement aléatoire sur un Plan Extérieur déterminé par le résultat de 1d8 : 1, les Abysses ; 2, l’Achéron ; 3, les Carcères ; 4, la Géhenne ; 5, Hadès ; 6, les Limbes ; 7, les Neuf Enfers ; et 8, le Pandémonium\n91–00 | Emplacement aléatoire sur le Plan Astral', 'lc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-08-28 16:09:37', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (44, 'effets-baguette-des-merveilles', 'Effets de baguette des merveilles', '! 1d100 | Effet\n01–20 | Vous lancez un sort émanant du point d’origine choisi. Lancez 1d10 pour déterminer le sort : 1–2, boule de feu ; 3–4, lenteur ; 5–6, lueurs féeriques ; 7–8, nuage nauséabond ; 9–10, ténèbres.\n21–25 | Rien ne se passe au point d’origine. Au lieu de cela, vous subissez l’état Étourdi jusqu’au début de votre tour suivant, convaincu qu’un événement extraordinaire se produit sous vos yeux.\n26–30 | Vous lancez bourrasque. La Ligne créée par le sort s’étend de vous jusqu’au point d’origine.\n31–35 | Rien ne se passe au point d’origine. Au lieu de cela, vous subissez 1d6 dégâts psychiques.\n36–40 | Une pluie torrentielle s’abat pendant 1 minute dans un Cylindre de 36 m de haut et 18 m de rayon centré sur le point d’origine. Pendant cette durée, la zone d’effet est à Visibilité réduite.\n41–45 | Une nuée de 600 papillons surdimensionnés emplit un Cylindre de 18 m de haut et 9 m de rayon centré sur le point d’origine. Les papillons restent pendant 10 minutes, durant lesquelles la zone d’effet est à Visibilité nulle.\n46–50 | Vous lancez éclair. La Ligne créée par le sort s’étend de vous jusqu’au point d’origine.\n51–55 | La créature la plus proche du point d’origine est agrandie comme si vous aviez lancé sur elle agrandissement/rapetissement. Si vous n’êtes pas cette cible et que celle-ci ne peut pas être affectée par ce sort, c’est vous qui en devenez la cible.\n56–60 | Une créature formée magiquement apparaît dans un espace inoccupé aussi près que possible du point d’origine. Elle n’est pas sous votre contrôle, agit normalement et disparaît après 1 heure ou lorsqu’elle tombe à 0 point de vie. Lancez 1d4 pour déterminer quelle créature apparaît. Sur un1, un rhinocéros se présente ; 2, un éléphant ; 3–4, un rat.\n61–64 | De l’herbe recouvre un cercle de 18 m de rayon au sol, le centre de ce cercle étant aussi proche que possible du point d’origine. Si de l’herbe était déjà présente, elle grandit jusqu’à atteindre dix fois sa taille normale et demeure ainsi pendant 1 minute.\n65–68 | Un objet au choix du MJ disparaît dans le Plan Éthéré. L’objet ne doit être porté par personne, doit se trouver dans un rayon de 36 m du point d’origine et ne doit pas mesurer plus de 3 m de long, de large ou de haut. S’il n’y a aucun objet de la sorte à portée, rien ne se passe.\n69–72 | Rien ne se passe au point d’origine. À la place, vous rapetissez comme si vous aviez lancé agrandissement/rapetissement sur vous-même et restez dans cet état pendant 1 minute.\n73–77 | Des feuilles poussent sur la créature la plus proche du point d’origine. À moins d’être arrachées avant, ces feuilles brunissent et tombent au bout de 24 heures.\n78–82 | Rien ne se passe au point d’origine. Au lieu de cela, une explosion de lumière colorée et scintillante s’étend depuis vous dans une Émanation de 9 m. Chaque créature prise dans la zone doit réussir un jet de sauvegarde de Constitution DD 15 sous peine de subir l’état Aveuglé pendant 1 minute. Une créature affectée réitère le JS à la fin de chacun de ses tours, et met un terme à l’effet sur elle-même en cas de réussite.\n83–87 | Rien ne se passe au point d’origine. Au lieu de cela, vous lancez invisibilité sur vous-même.\n88–92 | Rien ne se passe au point d’origine. Au lieu de cela, un torrent de 1d4 × 10 gemmes, chacune d’une valeur de 1 po, jaillit de la pointe de la baguette vers le point d’origine en formant une Ligne de 9 m de long sur 1,50 m de large. Chaque gemme inflige 1 dégât contondant ; les dégâts totaux infligés par les gemmes se divisent équitablement entre toutes les créatures présentes sur cette Ligne.\n93–97 | Vous lancez métamorphose, en ciblant la créature la plus proche du point d’origine. Lancez 1d4 pour déterminer la nouvelle forme de la cible. 1, la nouvelle forme est un ours noir ; 2, une guêpe géante ; 3–4, une grenouille.\n98–00 | La créature la plus proche du point d’origine effectue un jet de sauvegarde de Constitution DD 15. En cas d’échec, elle subit l’état Entravé et commence à se pétrifier. Tant qu’elle est ainsi Entravée, la créature réitère le JS à la fin de son tour suivant. En cas de réussite, l’effet prend fin. En cas d’échec, la créature subit l’état Pétrifié qui remplace l’état Entravé. La pétrification persiste jusqu’à ce que la créature en soit affranchie par le sort restauration suprême ou une magie équivalente.', 'lc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-08-28 16:09:37', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (45, 'bouteille-du-mauvais-genie', 'Bouteille du mauvais génie — effets', '! 1d10 | Effet\n1 | L’éfrit vous attaque. Après 5 rounds de combat, l’éfrit disparaît et la bouteille perd sa magie.\n2–9 | L’éfrit comprend les mêmes langues que vous et obéit à vos ordres pendant 1 heure, après quoi il retourne dans la bouteille, scellée par un nouveau bouchon. La bouteille ne peut pas être débouchée pendant 24 heures. Lors des deux prochains débouchages de la bouteille, le même effet se produit. Si l’on ouvre la bouteille une quatrième fois, l’éfrit s’enfuit, disparaît et la bouteille perd sa magie.\n10 | L’éfrit comprend les mêmes langues que vous et peut lancer souhait une fois pour vous. Il disparaît après avoir exaucé le souhait (au bout de 1 heure sans cela) et la bouteille perd sa magie.', 'lc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-08-28 16:09:37', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (46, 'chapeau-mille-sorts-effets', 'Chapeau mille-sorts — effets', '! 1d100 | Effet\n01–50 | Vous lancez un sort déterminé aléatoirement en jetant 1d10 : 1, agrandissement/rapetissement (effet agrandissement) ; 2, agrandissement/rapetissement (effet rapetissement) ; 3, boule de feu ; 4, bourrasque ; 5, éclair ; 6, force fantasmagorique ; 7, invisibilité (lancé sur vous) ; 8, lueurs féeriques ; 9, métamorphose ; 10, nuage nauséabond.\n51–55 | Vous subissez l’état Étourdi jusqu’à la fin de votre tour suivant, convaincu qu’un événement extraordinaire vient de se produire.\n56–60 | Une nuée de papillons inoffensifs remplit un Cube de 3 m dans un rayon de 9 m de vous. La nuée se disperse au bout de 1 minute.\n61–65 | Vous sortez un objet non magique du chapeau. Lancez 1d4 pour déterminer de quel objet il s’agit : 1, une fiole d’acide ; 2, une flasque de feu grégeois ; 3, un pied-de-biche ; 4, une torche allumée.\n66–70 | En proie à une poussée de « maladie magique », vous subissez l’état Empoisonné pendant 1 heure.\n71–75 | Vous subissez l’état Pétrifié jusqu’à la fin de votre tour suivant.\n76–80 | Vous sortez un objet non magique du chapeau. Lancez 1d4 pour déterminer de quel objet il s’agit : 1, une dague ; 2, un grappin attaché à une corde ; 3, un sac de chausse-trappes ; 4, une gemme d’une valeur de 50 po.\n81–85 | Une créature apparaît dans un espace inoccupé, le plus près possible de vous. La créature n’est pas sous votre contrôle, agit normalement et disparaît après 1 heure ou lorsqu’elle tombe à 0 point de vie. Lancez 1d4 pour déterminer la créature : 1, un chameau ; 2, un éléphant ; 3, une mule ; 4, un serpent constricteur.\n86–90 | Une nuée de chauve-souris Hostile sort du chapeau, occupe votre espace et vous attaque.\n91–95 | Un portail vertical bidirectionnel de 3 m, donnant sur un autre plan d’existence, s’ouvre en un espace inoccupé dans un rayon de 9 m de vous et reste ouvert jusqu’à la fin de votre tour suivant. Le MJ détermine sur quel plan il mène.\n96–00 | Vous sortez un objet magique du chapeau. Lancez 1d6 pour déterminer la rareté de l’objet : 1 à 3, courant ; 4 ou 5, peu courant ; 6, rare. Le MJ choisit l’objet, qui disparaît au bout de 1 heure s’il n’est pas consommé ou détruit avant cela.', 'lc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-08-28 16:09:37', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (47, 'perles-du-chapelet-mystique', 'Perles du chapelet mystique', '! 1d20 | Perle | Sort\n1–6 | Perle de bénédiction | bénédiction\n7–8 | Perle de châtiment | châtiment de révélation\n9 | Perle de convocation | gardien de la foi\n10 | Perle d’envolée divine | vent divin\n11–16 | Perle de guérison | soins (au 2e niveau)\n17–20 | Perle de rétablissement | restauration suprême', 'lc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-08-28 16:09:37', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (48, 'cierge-d-invocation-plans', 'Cierge d’invocation — Plans Extérieurs', '! 1d100 | Plan Extérieur\n01–05 | Abysses\n06–10 | Achéron\n11–17 | Arborée\n18–25 | Arcadie\n26–33 | Bytopie\n34–38 | Carcères\n39–46 | Élysée\n47–51 | Géhenne\n52–56 | Hadès\n57–61 | Limbes\n62–69 | Méchanus\n70–77 | Mont Céleste\n78–82 | Neuf Enfers\n83–87 | Pandémonium\n88–95 | Terres des Bêtes\n96–00 | Ysgard', 'lc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-08-28 16:09:37', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (49, 'pieces-de-la-robe-du-camelot', 'Pièces de la robe du camelot', '! 1d100 | Pièce\n01–08 | Sac de 100 po\n09–15 | Coffre en argent (30 cm de long, 15 de large et de profondeur) d’une valeur de 500 po\n16–22 | Porte en fer (jusqu’à 3 m de large et 3 m de haut, barrée du côté de votre choix) que vous pouvez encastrer dans une ouverture à votre portée ; elle s’adapte à l’ouverture, se fixe et pivote sur ses gonds\n23–30 | 10 gemmes d’une valeur unitaire de 100 po\n31–44 | Échelle en bois (7,20 m de long)\n45–51 | Cheval de selle équipé d’une selle d’équitation\n52–59 | Fossé (un Cube de 3 m) que vous pouvez disposer au sol dans un rayon de 3 m de vous\n60–68 | 4 potions de guérison\n69–75 | Barque (3,60 m de long)\n76–83 | Parchemin de sort contenant un sort du 1er, 2e ou 3e niveau (choisissez)\n84–90 | 2 molosses\n91–96 | Fenêtre (60 cm sur 1,20 m, profondeur jusqu’à 60 cm), que vous pouvez placer sur une surface verticale à portée\n97–00 | Bélier portable', 'lc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-08-28 16:09:37', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (50, 'sphere-d-annihilation-portails', 'Sphère d’annihilation — interaction avec un portail', '! 1d100 | Résultat\n01–50 | La sphère est détruite.\n51–85 | La sphère franchit le portail ou entre dans l’espace extradimensionnel.\n86–00 | Une faille planaire propulse chaque créature et objet dans un rayon de 54 m de la sphère, cette dernière comprise, vers un plan d’existence aléatoire.', 'lc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-08-28 16:09:37', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (51, 'effets-des-haricots-magiques', 'Effets des haricots magiques', '! 1d100 | Effet\n01 | 5d4 champignons poussent. Si une créature mange un champignon, lancez n’importe quel dé. En cas de résultat impair, la créature doit réussir un jet de sauvegarde de Constitution DD 15 sous peine de subir 5d6 dégâts de poison et l’état Empoisonné pendant 1 heure. En cas de résultat pair, la créature reçoit 5d6 points de vie temporaires qui persistent pendant 1 heure.\n02–10 | Un geyser jaillit sur 9 m de haut en déversant de l’eau, de la bière, de la mayonnaise, du thé, du vinaigre, du vin ou de l’huile (au choix du MJ) pendant 1d4 minutes.\n11–20 | Un sylvanien pousse. Lancez n’importe quel dé. En cas de résultat impair, ce sylvanien est Chaotique Mauvais. En cas de résultat pair, il est Chaotique Bon.\n21–30 | Une statue de pierre à votre effigie, animée, mais immobile, se dresse et profère des menaces verbales à votre encontre. Si vous partez et que d’autres s’en approchent, elle vous décrit comme le plus odieux des scélérats et intime aux nouveaux arrivants de vous pourchasser. Si vous êtes sur le même plan d’existence que la statue, elle sait exactement où vous êtes. La statue devient inanimée au bout de 24 heures.\n31–40 | Un feu de camp aux flammes vertes s’allume ; il brûle pendant 24 heures (sauf si quelqu’un l’éteint).\n41–50 | Trois criards poussent.\n51–60 | 1d4 + 4 crapauds rose vif émergent en rampant. Chaque fois qu’un crapaud est touché, il se transforme en un monstre de taille G ou inférieure au choix du MJ, qui agit selon son alignement et sa nature. Le monstre persiste pendant 1 minute puis disparaît dans une bouffée de fumée rose vif.\n61–70 | Une bulette affamée surgit du sol et passe à l’attaque.\n71–80 | Un arbre fruitier émerge. Il porte 1d10 + 20 fruits, dont 1d8 agissent comme autant de potions déterminées aléatoirement. L’arbre disparaît au bout de 1 heure. Les fruits cueillis persistent et conservent leurs propriétés magiques pendant 30 jours.\n81–90 | Un nid contenant 1d4 + 3 œufs aux couleurs de l’arc-en-ciel apparaît. Toute créature qui mange un œuf effectue un jet de sauvegarde de Constitution DD 20. En cas de réussite, cette créature augmente sa valeur de caractéristique la plus basse de 1, de manière permanente, le hasard décidant de laquelle en cas d’égalité. En cas d’échec, la créature subit 10d6 dégâts de force, provoqués par une explosion interne.\n91–95 | Une pyramide à base carrée de 18 m de côté surgit du sol. À l’intérieur, une chambre funéraire abrite une momie, une momie auguste ou quelque autre Mort-vivant choisi par le MJ. Son sarcophage contient un trésor choisi par le MJ.\n96–00 | Un plant de haricot géant surgit, poussant jusqu’à une hauteur décidée par le MJ. Le sommet mène là où le MJ le décide : panorama superbe, château d’une géante des nuages, autre plan d’existence, etc.', 'lc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-08-28 16:09:37', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (52, 'tarot-mysterieux', 'Tarot mystérieux', '! Carte | 1d100 (jeu de 13 cartes) | 1d100 (jeu de 22 cartes)\nLa Balance | — | 01–05\nLe Bouffon | 01–08 | 06–10\nLe Chevalier | 09–16 | 11–15\nLa Clef | 17–24 | 16–20\nLa Comète | — | 21–25\nLe Crâne | 25–32 | 26–29\nLe Donjon | — | 30–33\nL’Énigme | — | 34–37\nL’Étoile | 33–40 | 38–42\nEuryale | 41–48 | 43–46\nLes Flammes | 49–56 | 47–50\nLe Fou | — | 51–54\nLa Gemme | — | 55–59\nLa Lune | 57–64 | 60–64\nLe Néant | 65–68 | 65–68\nLes Parques | — | 69–73\nLa Ruine | 69–76 | 74–77\nLes Serres | — | 78–81\nLe Soleil | 77–84 | 82–86\nLe Traître | 85–92 | 87–90\nLe Trône | 93–100 | 91–95\nLe Vizir | — | 96–00', 'lcc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-08-28 16:09:37', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (53, 'types-de-pieces', 'Les différents types de pièces', '! | Valeur d\'échange | | |\n! Pièce | PC | PA | PO | PP\nPièce de cuivre (pc) | 1 | 1/10 | 1/100 | 1/1 000\nPièce d\'argent (pa) | 10 | 1 | 1/10 | 1/100\nPièce d\'or (po) | 100 | 10 | 1 | 1/10\nPièce de platine (pp) | 1 000 | 100 | 10 | 1', 'lrrrr', NULL, 8, 1, 98, NULL, 0, 0, 1, '2026-10-11 14:02:45', '2026-10-11 14:02:45')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (54, 'produits-de-consommation-courante', 'Produits de consommation courante', '! Prix | Article\n1 pc | Une livre (500 g) de blé\n2 pc | Une livre (500 g) de farine, ou un poulet\n1 pa | Une livre (500 g) de fer\n5 pa | Une livre (500 g) de tabac ou de cuivre\n1 po | Une livre (500 g) de cannelle, ou une chèvre\n2 po | Une livre (500 g) de gingembre ou de poivre, ou un mouton\n3 po | Un cochon\n4 po | Un mètre carré de lin\n5 po | Une livre (500 g) d\'argent ou de sel\n10 po | Un mètre carré de soie ou une vache\n15 po | Une livre (500 g) de safran ou de clous de girofle, ou un bœuf\n50 po | Une livre (500 g) d\'or\n500 po | Une livre (500 g) de platine', 'rl', NULL, 8, 1, 98, NULL, 0, 0, 1, '2026-10-11 14:02:45', '2026-10-11 14:02:45')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (55, 'degats-armes-tp-g', 'Dégâts des armes de taille TP ou G', '! Dégâts d\'une arme de taille M | Dégâts d\'une arme de taille TP | Dégâts d\'une arme de taille G\n1d2 | — | 1d3\n1d3 | 1 | 1d4\n1d4 | 1d2 | 1d6\n1d6 | 1d3 | 1d8\n1d8 | 1d4 | 2d6\n1d10 | 1d6 | 2d8\n1d12 | 1d8 | 3d6\n2d4 | 1d4 | 2d6\n2d6 | 1d8 | 3d6\n2d8 | 1d10 | 3d8\n2d10 | 2d6 | 4d8', 'ccc', NULL, 8, 1, 98, NULL, 0, 0, 1, '2026-10-11 14:02:45', '2026-10-11 14:02:45')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (56, 'armures-creatures-inhabituelles', 'Armures pour créatures inhabituelles', '! Taille | Humanoïde | | Non-humanoïde |\n! ^ | Prix | Poids | Prix | Poids\nJusqu\'à très petite (TP) | ×1/2 | ×1/10 | ×1 | ×1/10\nPetite (P) | ×1 | ×1/2 | ×2 | ×1/2\nMoyenne (M) | ×1 | ×1 | ×2 | ×1\nGrande (G) | ×2 | ×2 | ×4 | ×2\nTrès grande (TG) | ×4 | ×5 | ×8 | ×5\nGigantesque (Gig) | ×8 | ×8 | ×16 | ×8\nColossale (C) | ×16 | ×12 | ×32 | ×12', 'lcccc', 'Pour une créature de taille TP ou moins, le bonus d\'armure est réduit de moitié.', 8, 1, 98, NULL, 0, 0, 1, '2026-10-11 14:02:45', '2026-10-11 14:02:45')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (57, 'enfiler-oter-armure', 'Enfiler ou ôter son armure', '! Armure | Enfiler | Enfiler à la hâte | Ôter\nBouclier (tous) | 1 action de mouvement | sans objet | 1 action de mouvement\nArmure matelassée, de cuir, de cuir cloutée, de peau ou chemise de mailles | 1 minute | 5 rounds | 1 minute¹\nCuirasse, armure d\'écailles, de mailles, clibanion ou crevice | 4 minutes¹ | 1 minute | 1 minute¹\nArmure à plaques ou harnois | 4 minutes² | 4 minutes¹ | 1d4+1 minutes¹\n> ¹ En cas d\'assistance, ce temps est divisé par deux. Un personnage ne faisant rien d\'autre peut aider un ou deux compagnons si ces derniers sont adjacents. Il est impossible de s\'aider mutuellement à revêtir une armure (du moins, en même temps).\n> ² Une assistance extérieure est nécessaire pour bien ajuster cette armure, sans quoi elle ne peut qu\'être enfilée à la hâte.', 'lccc', NULL, 8, 1, 98, NULL, 0, 0, 1, '2026-10-11 14:02:45', '2026-10-11 14:02:45')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (58, 'vitesse-montures-barde', 'Vitesse des montures portant une barde', '! | Vitesse | |\n! Barde | (12 m) | (15 m) | (18 m)\nIntermédiaire | 9 m | 10,50 m | 12 m\nLourde | 9 m¹ | 10,50 m¹ | 12 m¹', 'lccc', 'Une monture revêtue d\'une armure lourde voit sa vitesse de déplacement multipliée par trois seulement lorsqu\'elle court (au lieu de quatre).', 8, 1, 98, NULL, 0, 0, 1, '2026-10-11 14:02:45', '2026-10-11 14:02:45')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (59, 'ecole-objet-magique', 'École d\'un objet magique sans sort requis', '! Nature de l\'objet | École\nArme ou objet d\'attaque | Évocation\nArmure ou objet de protection | Abjuration\nObjet conférant un bonus à une caractéristique, à un test de compétence, etc. | Transmutation', 'll', NULL, 6, 1, 98, NULL, 0, 0, 1, '2026-10-11 14:02:45', '2026-10-11 14:02:45')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (60, 'determination-aleatoire-objets-magiques', 'Détermination aléatoire des objets magiques', '! Faible | Intermédiaire | Puissant | Catégorie d\'objets\n01–02 | 01–10 | 01–10 | Anneaux\n03–07 | 11–20 | 11–20 | Armes\n08–11 | 21–30 | 21–30 | Armures et boucliers\n12–21 | 31–45 | 31–35 | Baguettes\n— | 46–48 | 36–55 | Bâtons\n22–30 | 49–65 | 56–75 | Objets merveilleux\n31–65 | 66–80 | 76–85 | Parchemins\n66–100 | 81–90 | 86–90 | Potions et huiles\n— | 91–100 | 91–100 | Sceptres', 'cccl', NULL, 6, 1, 98, NULL, 0, 0, 1, '2026-10-11 14:02:45', '2026-10-11 14:02:45')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (61, 'affinites-emplacements-corps', 'Affinités des emplacements sur le corps', '! Emplacement sur le corps | Affinité\nBandeau, casque | Amélioration de l\'esprit, attaques à distance\nCouvre-chef | Interaction sociale\nPhylactère | Moral, alignement\nLentilles, lunettes | Vue\nCape, manteau, écharpe | Transformation, protection\nAmulette, broche, médaillon, collier, charme, scarabée | Protection, discernement\nRobe | Effets multiples\nChemise | Amélioration du corps\nGilet, chasuble | Amélioration des aptitudes de classe\nBracelets | Combat, alliés\nGants | Précision\nGantelets | Puissance destructive\nCeinture | Amélioration du corps\nBottes | Déplacement', 'll', NULL, 6, 1, 98, NULL, 0, 0, 1, '2026-10-11 14:02:45', '2026-10-11 14:02:45')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (62, 'resume-couts-creation-objets-magiques', 'Résumé des coûts de création des objets magiques', '! Catégorie d\'objet | Don requis | Prix de base | Coût de création de base | Coût d\'objet | Coût de composantes | Prix de vente\nAnneau | Création d\'anneaux magiques | Variable, voir la table d\'estimation du prix des objets magiques | Prix de base/2 en po, prix de base/25 en PX | Non¹ | Non¹ | Prix de base\nArme | Création d\'armes et armures magiques | Selon la table des armes | Prix de base/2 en po, prix de base/25 en PX | Oui (arme de maître) | Non¹ | Prix de base + coût d\'objet\nArmure ou bouclier | Création d\'armes et armures magiques | Selon la table des armures et boucliers | Prix de base/2 en po, prix de base/25 en PX | Oui (armure ou bouclier de maître) | Non¹ | Prix de base + coût d\'objet\nBaguette | Création de baguettes magiques | 750 × niveau de sort × niveau de lanceur de sorts | Prix de base/2 en po, prix de base/25 en PX | Non¹ | Oui (50 fois) | Prix de base + coût des composantes (1 PX = 5 po)\nBâton | Création des bâtons magiques | Spécial | Prix de base/2 en po, prix de base/25 en PX | Non¹ | Oui (50 ou 25 fois) | Prix de base + coût des composantes (1 PX = 5 po)\nObjet merveilleux | Création d\'objets merveilleux | Variable, voir la table d\'estimation du prix des objets magiques | Prix de base/2 en po, prix de base/25 en PX | Non¹ | Non | Prix de base\nParchemin | Écriture de parchemins | 25 × niveau de sort × niveau de lanceur de sorts | Prix de base/2 en po, prix de base/25 en PX | Non¹ | Oui (1 fois) | Prix de base + coût des composantes (1 PX = 5 po)\nPotion ou huile | Préparation de potions | 50 × niveau de sort × niveau de lanceur de sorts | Prix de base/2 en po, prix de base/25 en PX | Non¹ | Oui (1 fois) | Prix de base + coût des composantes (1 PX = 5 po)\nSceptre | Création de sceptres magiques | Variable, voir la table d\'estimation du prix des objets magiques | Prix de base/2 en po, prix de base/25 en PX | Non¹ | Non¹ | Prix de base', 'llllllll', '¹ Aucun en règle générale, mais des exceptions peuvent exister (voir Coûts supplémentaires).', 6, 1, 98, NULL, 0, 0, 1, '2026-10-11 14:02:45', '2026-10-11 14:02:45')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (63, 'prix-base-baguettes', 'Prix de base des baguettes', '! | Classe | | |\n! Niveau du sort | Dru, Mag, Prê | Ens | Bard | Pal, Rôd\n0 | 375 po | 375 po | 375 po | —\n1 | 750 po | 750 po | 1 500 po | 1 500 po\n2 | 4 500 po | 6 000 po | 6 000 po | 6 000 po\n3 | 11 250 po | 13 500 po | 15 750 po | 11 250 po\n4 | 21 000 po | 24 000 po | 30 000 po | 21 000 po', 'lrrrr', NULL, 6, 1, 98, NULL, 0, 0, 1, '2026-10-11 14:02:45', '2026-10-11 14:02:45')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (64, 'cout-creation-baguettes', 'Coût de base de création des baguettes', '! | Classe | | |\n! Niveau du sort | Dru, Mag, Prê | Ens | Bard | Pal, Rôd\n0 | 187 po, 5 pa + 15 PX | 187 po, 5 pa + 15 PX | 187 po, 5 pa + 15 PX | —\n1 | 375 po + 30 PX | 375 po + 30 PX | 750 po + 60 PX | 750 po + 60 PX\n2 | 2 250 po + 180 PX | 3 000 po + 240 PX | 3 000 po + 240 PX | 3 000 po + 240 PX\n3 | 5 625 po + 450 PX | 6 750 po + 540 PX | 7 875 po + 630 PX | 5 625 po + 450 PX\n4 | 10 500 po + 840 PX | 12 000 po + 960 PX | 15 000 po + 1 200 PX | 10 500 po + 840 PX', 'lrrrr', NULL, 6, 1, 98, NULL, 0, 0, 1, '2026-10-11 14:02:45', '2026-10-11 14:02:45')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (65, 'prix-base-parchemins', 'Prix de base des parchemins', '! | Classe | | |\n! Niveau du sort | Dru, Mag, Prê | Ens | Bard | Pal, Rôd\n0 | 12 po, 5 pa | 12 po, 5 pa | 12 po, 5 pa | —\n1 | 25 po | 25 po | 50 po | 50 po\n2 | 150 po | 200 po | 200 po | 200 po\n3 | 375 po | 450 po | 525 po | 375 po\n4 | 700 po | 800 po | 1 000 po | 700 po\n5 | 1 125 po | 1 250 po | 1 625 po | —\n6 | 1 650 po | 1 800 po | 2 400 po | —\n7 | 2 275 po | 2 450 po | — | —\n8 | 3 000 po | 3 200 po | — | —\n9 | 3 825 po | 4 050 po | — | —', 'lrrrr', NULL, 6, 1, 98, NULL, 0, 0, 1, '2026-10-11 14:02:45', '2026-10-11 14:02:45')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (66, 'cout-creation-parchemins', 'Coût de base de création des parchemins', '! | Classe | | |\n! Niveau du sort | Dru, Mag, Prê | Ens | Bard | Pal, Rôd\n0 | 6 po, 2 pa, 5 pc + 1 PX | 6 po, 2 pa, 5 pc + 1 PX | 6 po, 2 pa, 5 pc + 1 PX | —\n1 | 12 po, 5 pa + 1 PX | 12 po, 5 pa + 1 PX | 25 po + 2 PX | 25 po + 2 PX\n2 | 75 po + 6 PX | 100 po + 8 PX | 100 po + 8 PX | 100 po + 8 PX\n3 | 187 po, 5 pa + 15 PX | 225 po + 18 PX | 262 po, 5 pa + 21 PX | 187 po, 5 pa + 15 PX\n4 | 350 po + 28 PX | 400 po + 32 PX | 500 po + 40 PX | 350 po + 28 PX\n5 | 562 po, 5 pa + 45 PX | 625 po + 50 PX | 812 po, 5 pa + 65 PX | —\n6 | 825 po + 66 PX | 900 po + 72 PX | 1 200 po + 96 PX | —\n7 | 1 137 po, 5 pa + 91 PX | 1 225 po + 98 PX | — | —\n8 | 1 500 po + 120 PX | 1 600 po + 128 PX | — | —\n9 | 1 912 po, 5 pa + 153 PX | 2 025 po + 162 PX | — | —', 'lrrrr', NULL, 6, 1, 98, NULL, 0, 0, 1, '2026-10-11 14:02:45', '2026-10-11 14:02:45')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (67, 'prix-base-potions-huiles', 'Prix de base des potions et des huiles', '! | Classe | | |\n! Niveau du sort | Dru, Mag, Prê | Ens | Bard | Pal, Rôd\n0 | 25 po | 25 po | 25 po | —\n1 | 50 po | 50 po | 100 po | 100 po\n2 | 300 po | 400 po | 400 po | 400 po\n3 | 750 po | 900 po | 1 050 po | 750 po', 'lrrrr', NULL, 6, 1, 98, NULL, 0, 0, 1, '2026-10-11 14:02:45', '2026-10-11 14:02:45')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (68, 'cout-creation-potions-huiles', 'Coût de base de création des potions et des huiles', '! | Classe | | |\n! Niveau du sort | Dru, Mag, Prê | Ens | Bard | Pal, Rôd\n0 | 12 po, 5 pa + 1 PX | 12 po, 5 pa + 1 PX | 12 po, 5 pa + 1 PX | —\n1 | 25 po + 2 PX | 25 po + 2 PX | 50 po + 4 PX | 50 po + 4 PX\n2 | 150 po + 12 PX | 200 po + 16 PX | 200 po + 16 PX | 200 po + 16 PX\n3 | 375 po + 30 PX | 450 po + 36 PX | 525 po + 42 PX | 375 po + 30 PX', 'lrrrr', NULL, 6, 1, 98, NULL, 0, 0, 1, '2026-10-11 14:02:45', '2026-10-11 14:02:45')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (69, 'estimation-prix-objets-magiques', 'Estimation du prix des objets magiques', '! Effet | Prix de base\n# Effets conférant un bonus\nBonus à l\'armure naturelle (altération) | Bonus au carré × 2 000 po\nBonus à la CA (parade) | Bonus au carré × 2 000 po\nBonus à la CA (autre¹) | Bonus au carré × 2 500 po\nBonus à une armure (altération) | Bonus au carré × 1 000 po\nBonus à une arme (altération) | Bonus au carré × 2 000 po\nBonus à une caractéristique (altération) | Bonus au carré × 1 000 po\nBonus à une compétence (aptitude) | Bonus au carré × 100 po\nBonus aux sauvegardes (résistance) | Bonus au carré × 1 000 po\nBonus aux sauvegardes (autre¹) | Bonus au carré × 2 000 po\nRésistance à la magie | 10 000 po par point au-dessus de RM 12 (RM 13 minimum)\nSort en bonus | Niveau de sort au carré × 1 000 po\n# Effets de type sort\nUsage unique, fin d\'incantation | Niveau du sort × niveau du lanceur de sorts × 25 po\nUsage unique, usage | Niveau du sort × niveau du lanceur de sorts × 50 po\n50 charges, potentiel magique | Niveau du sort × niveau du lanceur de sorts × 750 po\nIllimité, mot de commande | Niveau du sort × niveau du lanceur de sorts × 1 800 po\nIllimité, usage ou continu | Niveau du sort × niveau du lanceur de sorts × 2 000 po²\n# Spécial (ajustement au prix de base)\nChanger illimité en 1 à 4 charges par jour | Multiplier par 0,2 (1 charge), 0,4 (2), 0,6 (3) ou 0,8 (4)\nChanger illimité en 50 charges | Multiplier par 0,5\nEmplacement inhabituel³ | Multiplier par 1,5\nN\'occupe pas d\'emplacement⁴ | Multiplier par 2\nRequiert une compétence | Multiplier par 0,9\nRequiert une race ou une classe | Multiplier par 0,7\n# Objet ou composante (coût supplémentaire)\nArme, armure ou bouclier | Ajouter le coût d\'un objet de maître\nSort à composantes coûteuses | Ajouter le prix des composantes pour chaque charge⁵\nSort exigeant des PX | Ajouter 5 po par PX et par charge⁵\n> ¹ Comme un bonus de chance, d\'intuition, sacré ou de malfaisance.\n> ² Le prix d\'un effet continu dépend de la durée du sort. Si elle est exprimée en rounds, le prix est multiplié par 4. Si elle est de 1 minute/niveau, il est multiplié par 2. Si elle est de 10 minutes/niveau, il est multiplié par 1,5. Si elle est de 24 heures ou plus, il est divisé par deux.\n> ³ Voir Affinités des emplacements sur le corps.\n> ⁴ Voir Emplacements des objets magiques sur le corps.\n> ⁵ Si l\'objet est à usage continu ou illimité, déterminez son prix comme s\'il avait 100 charges. Si son utilisation obéit à une limite quotidienne, considérez qu\'il a 50 charges.', 'll', 'Niveau du sort : un sort du niveau 0 vaut deux fois moins qu\'un sort du 1er niveau pour ce qui est de déterminer le prix de l\'objet.', 6, 1, 98, NULL, 0, 0, 1, '2026-10-11 14:02:45', '2026-10-11 14:02:45')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (70, 'monnaie-et-valeurs', 'Monnaie et valeurs', '! Pièce | Valeur en po\nPièce de cuivre (pc) | 1/100\nPièce d\'argent (pa) | 1/10\nPièce d\'électrum (pe) | 1/2\nPièce d\'or (po) | 1\nPièce de platine (pp) | 10', 'lr', NULL, 8, 2, 93, NULL, 0, 0, 1, '2026-10-16 15:51:54', '2026-10-16 15:51:54')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (71, 'train-de-vie', 'Train de vie', '! Train de vie | Coût par jour\nMendiant | gratuit\nMisérable | 1 pa\nPauvre | 2 pa\nModeste | 1 po\nConfortable | 2 po\nRiche | 4 po\nAristocratique | 10 po', 'lr', NULL, 8, 2, 93, NULL, 0, 0, 1, '2026-10-16 15:51:54', '2026-10-16 15:51:54')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (72, 'cout-des-parchemins-de-sort', 'Coût des parchemins de sort', '! Niveau du sort | Temps | Coût\nSort mineur | 1 jour | 15 po\n1 | 1 jour | 25 po\n2 | 3 jours | 100 po\n3 | 5 jours | 150 po\n4 | 10 jours | 1 000 po\n5 | 25 jours | 1 500 po\n6 | 40 jours | 10 000 po\n7 | 50 jours | 12 500 po\n8 | 60 jours | 15 000 po\n9 | 120 jours | 50 000 po', 'crr', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 15:51:54', '2026-10-16 15:51:54')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (73, 'anneau-de-feu-d-etoiles-spheres', 'Anneau de feu d’étoiles — dégâts des sphères de foudre', '! Nombre de sphères | Dégâts de foudre\n1 | 4d12\n2 | 5d4\n3 | 2d6\n4 | 2d4', 'cc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (74, 'anneau-de-maitrise-elementaire-sorts', 'Anneau de maîtrise élémentaire — sorts selon le plan', '! Plan | Sorts (charges)\nAir | bourrasque (2 charges), chaîne d’éclairs (3 charges), feuille morte (0 charge), mur de vent (1 charge)\nEau | création ou destruction d’eau (1 charge), marche sur l’onde (2 charges), mur de glace (3 charges), tempête de grêle (2 charges), tsunami (5 charges)\nFeu | boule de feu (2 charges), mains brûlantes (1 charge), mur de feu (3 charges), tempête de feu (4 charges)\nTerre | façonnage de la pierre (2 charges), mur de pierre (3 charges), peau de pierre (3 charges), tremblement de terre (5 charges)', 'll', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (75, 'anneau-de-resistance-types-de-degats', 'Anneau de résistance — type de dégâts et gemme', '! 1d10 | Type de dégâts | Gemme\n1 | Acide | Perle\n2 | Feu | Grenat\n3 | Force | Saphir\n4 | Foudre | Citrine\n5 | Froid | Tourmaline\n6 | Nécrotiques | Jais\n7 | Poison | Améthyste\n8 | Psychiques | Jade\n9 | Radiants | Topaze\n10 | Tonnerre | Spinelle', 'cll', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (76, 'armure-de-resistance-types-de-degats', 'Armure de résistance — type de dégâts', '! 1d10 | Type de dégâts\n1 | Acide\n2 | Feu\n3 | Force\n4 | Foudre\n5 | Froid\n6 | Nécrotiques\n7 | Poison\n8 | Psychiques\n9 | Radiants\n10 | Tonnerre', 'cl', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (77, 'potion-de-resistance-types-de-degats', 'Potion de résistance — type de dégâts', '! 1d10 | Type de dégâts\n1 | Acide\n2 | Feu\n3 | Force\n4 | Foudre\n5 | Froid\n6 | Nécrotiques\n7 | Poison\n8 | Psychiques\n9 | Radiants\n10 | Tonnerre', 'cl', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (78, 'armure-d-ecailles-de-dragon-resistances', 'Armure d’écailles de dragon — résistance selon l’espèce', '! Dragon | Résistance\nAirain | Feu\nArgent | Froid\nBlanc | Froid\nBleu | Foudre\nBronze | Foudre\nCuivre | Acide\nNoir | Acide\nOr | Feu\nRouge | Feu\nVert | Poison', 'll', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (79, 'baguette-de-terreur-sorts', 'Baguette de terreur — sorts', '! Sort | Coût en charges\ninjonction (« fuis » ou « rampe » uniquement) | 1\nterreur (Cône de 18 m) | 3', 'lc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (80, 'baguette-des-entraves-sorts', 'Baguette des entraves — sorts', '! Sort | Coût en charges\nimmobilisation de monstre | 5\nimmobilisation de personne | 2', 'lc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (81, 'baton-de-feu-sorts', 'Bâton de feu — sorts', '! Sort | Coût en charges\nboule de feu | 3\nmains brûlantes | 1\nmur de feu | 4', 'lc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (82, 'baton-de-givre-sorts', 'Bâton de givre — sorts', '! Sort | Coût en charges\ncône de froid | 5\nmur de glace | 4\nnappe de brouillard | 1\ntempête de grêle | 4', 'lc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (83, 'baton-de-guerison-sorts', 'Bâton de guérison — sorts', '! Sort | Coût en charges\nrestauration partielle | 2\nsoins | 1 charge par niveau de sort (maximum 4 pour un sort du 4e niveau)\nsoins de groupe | 5', 'lc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (84, 'baton-de-surpuissance-sorts', 'Bâton de surpuissance — sorts', '! Sort | Coût en charges\nboule de feu (au 5e niveau) | 5\ncône de froid | 5\néclair (au 5e niveau) | 5\nglobe d’invulnérabilité | 6\nimmobilisation de monstre | 5\nlévitation | 2\nmur de force | 5\nprojectile magique | 1\nrayon affaiblissant | 1', 'lc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (85, 'baton-des-forets-sorts', 'Bâton des forêts — sorts', '! Sort | Coût en charges\namitié avec les animaux | 1\ncommunication avec les animaux | 1\ncommunication avec les plantes | 3\néveil | 5\nlocalisation d’animaux ou de plantes | 2\nmur d’épines | 6\npassage sans trace | 2\npeau d’écorce | 2', 'lc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (86, 'baton-du-grand-essaim-sorts', 'Bâton du grand essaim — sorts', '! Sort | Coût en charges\nfléau d’insectes | 5\ninsecte géant | 4', 'lc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (87, 'baton-du-thaumaturge-sorts', 'Bâton du thaumaturge — sorts', '! Sort | Coût en charges\nagrandissement/rapetissement | 0\nboule de feu (au 7e niveau) | 7\nchangement de plan | 7\ndéblocage | 2\ndétection de la magie | 0\ndissipation de la magie | 3\néclair (au 7e niveau) | 7\ninvisibilité | 2\ninvocation d’élémentaire | 7\nlumière | 0\nmain du mage | 0\nmur de feu | 4\npasse-muraille | 5\nprotection contre le mal et le bien | 0\nsphère de feu | 2\ntélékinésie | 5\ntempête de grêle | 4\ntoile d’araignée | 2\nverrou magique | 0', 'lc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (88, 'ceinturon-de-force-de-geant-valeurs', 'Ceinturon de force de géant — valeur de Force et rareté', '! Ceinturon | For | Rareté\nCeinturon de force de géant (collines) | 21 | Rare\nCeinturon de force de géant (givre ou pierres) | 23 | Très rare\nCeinturon de force de géant (feu) | 25 | Très rare\nCeinturon de force de géant (nuages) | 27 | Légendaire\nCeinturon de force de géant (tempêtes) | 29 | Légendaire', 'lcl', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (89, 'cor-du-valhalla-types', 'Cor du Valhalla — types de cor', '! 1d100 | Type de cor | Esprits | Prérequis\n01–40 | Argent | 2 | Aucun\n41–75 | Airain | 3 | Maîtrise de toutes les armes courantes\n76–90 | Bronze | 4 | Formation au port de toutes les armures intermédiaires\n91–00 | Fer | 5 | Maîtrise de toutes les armes de guerre', 'clcl', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (90, 'cube-de-force-faces', 'Faces du cube de force', '! Sort | Coût en charges\narmure du mage | 1\nbouclier | 1\npetite hutte | 3\nsanctuaire privé | 4\nsphère résiliente | 4\nmur de force | 5', 'lc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (91, 'gemme-elementaire-types', 'Gemme élémentaire — élémentaire convoqué', '! Gemme | Élémentaire convoqué\nCorindon rouge | Élémentaire du feu\nDiamant jaune | Élémentaire de la terre\nÉmeraude | Élémentaire de l’eau\nSaphir bleu | Élémentaire de l’air', 'll', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (92, 'manuel-des-golems-types', 'Manuel des golems — type de golem', '! 1d20 | Golem | Temps | Prix\n1–5 | Golem d’argile | 30 jours | 65 000 po\n6–17 | Golem de chair | 60 jours | 50 000 po\n18 | Golem de fer | 120 jours | 100 000 po\n19–20 | Golem de pierre | 90 jours | 80 000 po', 'clrr', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (93, 'orbe-draconique-sorts', 'Orbe draconique — sorts', '! Sort | Coût en charges\ndétection de la magie | 0\nlumière du jour | 1\nprotection contre la mort | 2\nscrutation (DD de sauvegarde 18) | 3\nsoins (au 9e niveau) | 4', 'lc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (94, 'parchemin-de-sort-rarete-et-valeurs', 'Parchemin de sort — rareté, DD et bonus selon le niveau du sort', '! Niveau du sort | Rareté | DD de sauvegarde | Bonus à l’attaque\nSort mineur | Courant | 13 | +5\n1 | Courant | 13 | +5\n2 | Peu courant | 13 | +5\n3 | Peu courant | 15 | +7\n4 | Rare | 15 | +7\n5 | Rare | 17 | +9\n6 | Très rare | 17 | +9\n7 | Très rare | 18 | +10\n8 | Très rare | 18 | +10\n9 | Légendaire | 19 | +11', 'lccc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (95, 'plumes-magiques', 'Plumes magiques', '! 1d100 | Plume | Rareté\n01–20 | Ancre | Peu courante\n21–45 | Arbre | Peu courante\n46–60 | Bateau-cygne | Rare\n61–75 | Éventail | Peu courante\n76–85 | Fouet | Rare\n86–00 | Oiseau | Rare', 'cll', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (96, 'potion-de-force-de-geant-valeurs', 'Potion de force de géant — valeur de Force et rareté', '! Potion | Force | Rareté\nPotion de force de géant (collines) | 21 | Peu courante\nPotion de force de géant (givre ou pierres) | 23 | Rare\nPotion de force de géant (feu) | 25 | Rare\nPotion de force de géant (nuages) | 27 | Très rare\nPotion de force de géant (tempêtes) | 29 | Légendaire', 'lcl', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (97, 'potions-de-guerison-pv', 'Potions de guérison — points de vie récupérés', '! Potion | Pv récupérés | Rareté\nPotion de guérison | 2d4 + 2 | Courante\nPotion de guérison (importante) | 4d4 + 4 | Peu courante\nPotion de guérison (supérieure) | 8d4 + 8 | Rare\nPotion de guérison (suprême) | 10d4 + 20 | Très rare', 'lcl', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (98, 'projectile-tueur-types-de-creatures', 'Projectile tueur — type de créature', '! 1d100 | Type de créature\n01–10 | Aberrations\n11–15 | Artificiels\n16–20 | Bêtes\n21–25 | Célestes\n26–35 | Dragons\n36–45 | Élémentaires\n46–55 | Fées\n56–65 | Fiélons\n66–70 | Géants\n71–75 | Humanoïdes\n76–80 | Monstruosités\n81–90 | Morts-vivants\n91–95 | Plantes\n96–00 | Vases', 'cl', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (99, 'sac-a-malices-gris', 'Sac à malices gris', '! 1d8 | Créature\n1 | Belette\n2 | Rat géant\n3 | Blaireau\n4 | Sanglier\n5 | Panthère\n6 | Blaireau géant\n7 | Loup sanguinaire\n8 | Cervidé géant', 'cl', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (100, 'sac-a-malices-rouille', 'Sac à malices rouille', '! 1d8 | Créature\n1 | Rat\n2 | Chouette\n3 | Molosse\n4 | Chèvre\n5 | Chèvre géante\n6 | Sanglier géant\n7 | Lion\n8 | Ours brun', 'cl', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (101, 'sac-a-malices-brun', 'Sac à malices brun', '! 1d8 | Créature\n1 | Chacal\n2 | Grand singe\n3 | Babouin\n4 | Autrache\n5 | Ours noir\n6 | Belette géante\n7 | Hyène géante\n8 | Tigre', 'cl', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (102, 'submersible-du-crabe-leviers', 'Leviers du submersible', '! Levier | Haut | Bas\n1 | Les pattes se déploient et le submersible est apte à la marche comme à la nage. | Les pattes se rétractent, ce qui réduit la Vitesse et la Vitesse de nage du submersible à 0 m et l’empêche de bénéficier d’un quelconque bonus de vitesse.\n2 | Le volet du hublot avant s’ouvre. | Le volet du hublot avant se ferme.\n3 | Les volets des hublots latéraux s’ouvrent (deux par côté). | Les volets des hublots latéraux se ferment (deux par côté).\n4 | Deux pinces se déploient depuis les côtés, à l’avant du submersible. | Les pinces se rétractent.\n5 | Chaque pince déployée effectue l’attaque de corps à corps suivante : +8 pour toucher, allonge 1,50 m. Touché : 7 (2d6) dégâts contondants. | Chaque pince déployée effectue l’attaque de corps à corps suivante : +8 pour toucher, allonge 1,50 m. Touché : La cible subit l’état Agrippé (évasion DD 15).\n6 | Le submersible marche ou nage vers l’avant à condition que ses pattes soient déployées. | Le submersible marche ou nage vers l’arrière à condition que ses pattes soient déployées.\n7 | Le submersible pivote de 90 degrés vers la gauche à condition que ses pattes soient déployées. | Le submersible pivote de 90 degrés vers la droite à condition que ses pattes soient déployées.\n8 | Des yeux mécaniques émettent une Lumière vive dans un rayon de 9 m et une Lumière faible sur 9 m de plus. | La lumière s’éteint.\n9 | Le submersible descend de 6 m s’il évolue dans l’élément liquide. | Le submersible remonte de 6 m s’il évolue dans l’élément liquide.\n10 | L’écoutille arrière s’ouvre. | L’écoutille arrière se ferme hermétiquement.', 'cll', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (103, 'tapis-volant-tailles', 'Tapis volant — tailles', '! 1d100 | Taille | Capacité | Vitesse de vol\n01–20 | 90 cm × 1,50 m | 100 kg | 24 m\n21–55 | 1,20 m × 1,80 m | 200 kg | 18 m\n56–80 | 1,50 m × 2,10 m | 300 kg | 12 m\n81–00 | 1,80 m × 2,70 m | 400 kg | 9 m', 'cccc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (104, 'tarot-fantasmagorique', 'Tarot fantasmagorique', '! 1d100 | Illusion*\n01–03 | Archimage\n04–06 | Assassin\n07–09 | Basilic\n10–12 | Berserker\n13–15 | Capitaine bandit\n16–18 | Chevalier\n19–21 | Combattant gnoll\n22–24 | Combattant gobelin\n25–27 | Combattant gobelours\n28–30 | Combattant hobgobelin\n31–33 | Combattant kobold\n34–36 | Dragon rouge adulte\n37–39 | Druide\n40–42 | Ecclésiastique\n43–45 | Érinye\n46–48 | Ettin\n49–51 | Géant des collines\n52–54 | Géant des nuages\n55–57 | Géant du feu\n58–60 | Géant du givre\n61–63 | Golem de fer\n64–66 | Guenaude nocturne\n67–69 | Incube\n70–72 | Liche\n73–75 | Méduse\n76–78 | Naga gardien\n79–81 | Ogre\n82–84 | Oni\n85–87 | Succube\n88–90 | Troll\n91–93 | Vétéran\n94–96 | Vouivre\n97–00 | La personne qui a tiré la carte', 'cl', '*Les profils de ces créatures (hormis celui de la personne qui a tiré la carte) figurent dans la section « Monstres ».', 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (105, 'mouche-geante-caracteristiques', 'Mouche géante — caractéristiques', '! Carac. | Valeur | MOD | JS\nFor | 14 | +2 | +2\nDex | 13 | +1 | +1\nCon | 13 | +1 | +1\nInt | 2 | −4 | −4\nSag | 10 | +0 | +0\nCha | 3 | −4 | −4', 'lccc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (106, 'avatar-de-la-mort-caracteristiques', 'Avatar de la Mort — caractéristiques', '! Carac. | Valeur | MOD | JS\nFor | 16 | +3 | +3\nDex | 16 | +3 | +3\nCon | 16 | +3 | +3\nInt | 16 | +3 | +3\nSag | 16 | +3 | +3\nCha | 16 | +3 | +3', 'lccc', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:02', '2026-10-16 18:08:02')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (117, 'categories-d-objets-magiques', 'Catégories d’objets magiques', '! Catégorie | Exemples\nAnneaux | Anneau d’invisibilité\nArmes | Épée longue +1, projectiles +1\nArmures | Armure de cuir +1, bouclier +1\nBaguettes | Baguette de boules de feu\nBâtons | Bâton percussif\nObjets merveilleux | Bottes elfiques, sac sans fond\nParchemins | Parchemin de sort\nPotions | Potion de guérison\nSceptres | Sceptre inamovible', 'll', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:03', '2026-10-16 18:08:03')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (118, 'miscibilite-des-potions', 'Miscibilité des potions', '! 1d100 | Résultat\n01 | Les deux potions perdent leurs effets, et le mélange crée une explosion magique dans une Sphère de 1,50 m de rayon centrée sur lui-même. Chaque créature prise dans la zone subit 4d10 dégâts de force.\n02–08 | Les deux potions perdent leurs effets et le mélange devient le poison par ingestion de votre choix (cf. « Poisons » de « Boîte à outils ludique »).\n09–15 | Les deux potions perdent leurs effets.\n16–25 | Une potion perd son effet.\n26–35 | Les deux potions agissent, mais leurs effets numériques et leur durée sont réduits de moitié. Si une potion n’a ni effet numérique ni durée, elle perd son effet.\n36–90 | Les deux potions agissent normalement.\n91–99 | Les deux potions agissent, et les effets numériques ainsi que la durée de l’une d’entre elles sont doublés. Si aucune des deux potions n’a de variable à doubler de cette manière, elles agissent toutes deux normalement.\n00 | Une seule potion agit, mais ses effets sont permanents. Choisissez l’effet le plus simple à rendre permanent ou celui qui vous paraît le plus amusant. Une potion de guérison, par exemple, augmente le maximum de points de vie du buveur de 2d4 + 2, tandis qu’une potion d’invisibilité octroie au buveur l’état Invisible indéfiniment. À votre discrétion, le sort dissipation de la magie ou toute autre magie comparable peut dissiper l’effet persistant.', 'cl', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:03', '2026-10-16 18:08:03')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (119, 'rarete-et-valeur-des-objets-magiques', 'Rareté et valeur des objets magiques', '! Rareté | Valeur*\nCourante | 100 po\nPeu courante | 400 po\nRare | 4 000 po\nTrès rare | 40 000 po\nLégendaire | 200 000 po\nArtefact | Inestimable', 'lr', '*Réduire de moitié la valeur de tout objet à utilisation unique autre qu’un parchemin de sort. La valeur d’un parchemin de sort est égale au double du coût de fabrication du parchemin (tel qu’indiqué à « Écrire des parchemins de sort » dans « Équipement »).', 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:03', '2026-10-16 18:08:03')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (120, 'outils-par-objet-magique', 'Outils par objet magique', '! Catégorie d’objet | Outil nécessaire\nAnneaux | Outils de joaillier\nArmes | Outils de forgeron, outils de menuisier ou outils de tanneur selon le type d’arme, comme indiqué dans la description des outils\nArmures | Outils de forgeron, outils de tanneur ou outils de tisserand selon le type d’armure, comme indiqué dans la description des outils\nBaguettes | Outils de menuisier\nBâtons | Outils de menuisier\nObjets merveilleux | Outils de bricoleur ou l’outil nécessaire pour fabriquer l’objet non magique sur lequel se fonde l’objet magique\nParchemins | Matériel de calligraphe\nPotions | Matériel d’alchimiste ou matériel d’herboriste\nSceptres | Outils de menuisier', 'll', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:03', '2026-10-16 18:08:03')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (121, 'cout-et-temps-de-fabrication-d-un-objet-magique', 'Coût et temps de fabrication d’un objet magique', '! Rareté de l’objet | Temps* | Coût*\nCourant | 5 jours | 50 po\nPeu courant | 10 jours | 200 po\nRare | 50 jours | 2 000 po\nTrès rare | 125 jours | 20 000 po\nLégendaire | 250 jours | 100 000 po', 'lrr', '*Temps et coût sont réduits de moitié pour un objet à utilisation unique autre qu’un parchemin de sort, dont le temps et le coût de fabrication figurent en section « Équipement ».', 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:03', '2026-10-16 18:08:03')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (122, 'alignement-d-objet-intelligent', 'Alignement d’objet intelligent', '! 1d100 | Alignement\n01–15 | Loyal Bon\n16–35 | Neutre Bon\n36–50 | Chaotique Bon\n51–63 | Loyal Neutre\n64–73 | Neutre\n74–85 | Chaotique Neutre\n86–89 | Loyal Mauvais\n90–96 | Neutre Mauvais\n97–00 | Chaotique Mauvais', 'cl', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:03', '2026-10-16 18:08:03')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (123, 'modes-de-communication-d-objet-intelligent', 'Modes de communication d’objet intelligent', '! 1d10 | Mode de communication\n1–6 | L’objet communique en transmettant ses émotions à la créature qui le porte ou le manie.\n7–9 | L’objet parle une ou plusieurs langues.\n10 | L’objet parle une ou plusieurs langues. Il peut en outre communiquer par télépathie avec la créature qui le porte ou le manie.', 'cl', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:03', '2026-10-16 18:08:03')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (124, 'sens-d-objet-intelligent', 'Sens d’objet intelligent', '! 1d4 | Sens\n1 | Ouïe et vision normales sur 9 m\n2 | Ouïe et vision normales sur 18 m\n3 | Ouïe et vision normales sur 36 m\n4 | Ouïe et Vision dans le noir sur 36 m', 'cl', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:03', '2026-10-16 18:08:03')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (125, 'grand-dessein-d-objet-intelligent', 'Grand dessein d’objet intelligent', '! 1d10 | Grand dessein\n1 | Aligné. L’objet est voué à la défaite ou à la destruction des entités d’un alignement diamétralement opposé au sien. Un tel objet n’est jamais Neutre.\n2 | Fléau. L’objet cherche à contrecarrer ou à détruire les créatures d’un type particulier, comme les Artificiels, les Fiélons ou les Morts-vivants.\n3 | En quête de son créateur. L’objet cherche la trace de son créateur pour comprendre dans quel but il a été créé.\n4 | En quête de son destin. L’objet est convaincu que lui-même et son porteur ont un rôle clé à jouer dans des événements à venir.\n5 | Destructeur. L’objet aspire à la destruction et pousse son utilisateur à combattre tous azimuts.\n6 | En quête de gloire. L’objet cherche à se faire connaître comme le plus grand objet magique du monde, et incite à cette fin son porteur à devenir une personnalité de premier plan.\n7 | En quête de savoir. L’objet, avide de savoir, compte ardemment résoudre un mystère, exhumer un secret ou décrypter une prophétie obscure.\n8 | Protecteur. L’objet cherche à défendre un type particulier de créature, comme les elfes ou les loups-garous.\n9 | En quête de l’âme sœur. L’objet est à la recherche d’un autre objet magique intelligent, peut-être semblable à lui-même.\n10 | Templier. L’objet cherche à défendre les serviteurs ou les intérêts d’une divinité donnée.', 'cl', NULL, 6, 2, 93, NULL, 0, 0, 1, '2026-10-16 18:08:03', '2026-10-16 18:08:03')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (126, 'exemples-de-degres-de-difficulte', 'Exemples de degrés de difficulté', '! Difficulté (DD) | Exemple (compétence utilisée)\nTrès facile (0) | Remarquer un grand objet posé en évidence (Détection)\nFacile (5) | Escalader une corde à nœuds (Escalade)\nMoyenne (10) | Entendre l\'approche d\'un garde (Perception auditive)\nDélicat (15) | Saboter une roue de chariot pour qu\'elle tombe en route (Désamorçage/sabotage)\nDifficile (20) | Nager en pleine tempête (Natation)\nFormidable (25) | Ouvrir une serrure de qualité moyenne (Crochetage)\nHéroïque (30) | Sauter par-dessus une faille de 9 mètres de large (Saut)\nPresque impossible (40) | Suivre la piste d\'un groupe d\'orques sur un terrain dur et après 24 heures de pluie (Survie)', 'll', NULL, 7, 1, 98, NULL, 0, 0, 1, '2026-10-31 20:36:16', '2026-10-31 20:36:16')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

INSERT INTO dd_tableaux (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES (127, 'exemples-de-tests-opposes', 'Exemples de tests opposés', '! Tâche | Compétence (caractéristique) | Compétence opposée (caractéristique)\nRouler quelqu\'un | Bluff (Cha) | Psychologie (Sag)\nTracer une fausse carte | Contrefaçon (Int) | Contrefaçon (Int)\nSe faire passer pour quelqu\'un d\'autre | Déguisement (Cha) | Détection (Sag)\nArriver furtivement dans le dos de quelqu\'un | Déplacement silencieux (Dex) | Perception auditive (Sag)\nNe pas se faire remarquer | Discrétion (Dex) | Détection (Sag)\nFaire hésiter une brute | Intimidation (Cha) | Spécial (1)\nLigoter un prisonnier | Maîtrise des cordes (Dex) | Évasion (Dex)\nDérober une bourse | Escamotage (Dex) | Détection (Sag)\n> (1) Un test d\'Intimidation est opposé par un test de niveau de la cible plutôt que par un test de compétence. Voir la description de la compétence Intimidation pour plus de détails.', 'lll', NULL, 7, 1, 98, NULL, 0, 0, 1, '2026-10-31 20:36:16', '2026-10-31 20:36:16')
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug),
  tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu),
  tab_align = VALUES(tab_align),
  tab_note = VALUES(tab_note),
  tab_tabc_id = VALUES(tab_tabc_id),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id),
  tab_res_id = VALUES(tab_res_id),
  tab_camp_id = VALUES(tab_camp_id),
  tab_ecran_mj = VALUES(tab_ecran_mj),
  tab_ecran_ordre = VALUES(tab_ecran_ordre),
  tab_visible = VALUES(tab_visible),
  tab_date_creation = VALUES(tab_date_creation),
  tab_date_modif = VALUES(tab_date_modif);

