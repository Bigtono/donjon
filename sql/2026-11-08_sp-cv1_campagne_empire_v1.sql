-- 2026-11-08_sp-cv1_campagne_empire_v1.sql
-- SP-CV1 — Scénarios, chapitres et rencontres v1 de L'Empire des Anges (campagne v1 1 → v2 5)
-- Généré par tools/generer-sp-cv1-campagne-empire-v1.php le 2026-11-07 19:30.
-- Ids figés = 2000 + id v1 (D-CV3) ; oppositions recopiées des fiches SP-MO3, effectifs dans re_composition (D-CV0).
-- Prérequis : 2026-11-06_sp-mo3_monstres_dd35.sql. Rejouable (NOT EXISTS). Pas de DELIMITER.

SET NAMES utf8mb4;

-- ============================================================
-- Scénario 2001 — Valombre : l'Épuration
-- ============================================================
INSERT INTO dd_scenarios (sce_id, sce_nom, sce_ordre, sce_description, sce_camp_id)
SELECT 2001, 'Valombre : l\'Épuration', 1, NULL, 5
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_scenarios WHERE sce_id = 2001);

-- Chapitre 2001 — D : Le Val plongé dans l'ombre
INSERT INTO dd_scenarios_chapitres (scc_id, scc_sce_id, scc_nom, scc_ordre, scc_abreviation, scc_description)
SELECT 2001, 2001, 'Le Val plongé dans l\'ombre', 1, 'D', NULL
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_scenarios_chapitres WHERE scc_id = 2001);

-- Rencontre 2020 — D1 : la Colline du bois du chêne
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2020, 'la Colline du bois du chêne', 'D1', 1, 2001, NULL, '<ul>\n<li>1 × Rarnok Jadronson</li>\n<li>1 × Sergent Borgan Selgard</li>\n<li>3 × Mercenaire crânes et massues</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2020);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2008, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2020, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2163 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2020)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2008);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2009, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2020, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2164 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2020)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2009);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2010, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 3, 2020, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2165 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2020)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2010);

-- Rencontre 2021 — D2 : Ciel rouge
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2021, 'Ciel rouge', 'D2', 2, 2001, NULL, '<ul>\n<li>1 × Istivin Naerindyth</li>\n<li>1 × Destrier d’Istivin</li>\n<li>1 × Chauve-souris fiélonne</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2021);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2011, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2021, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2166 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2021)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2011);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2012, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2021, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2167 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2021)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2012);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2013, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 3, 2021, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2168 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2021)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2013);

-- Rencontre 2022 — D3 : La colline du guetteur
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2022, 'La colline du guetteur', 'D3', 3, 2001, NULL, '<ul>\n<li>1 × Gormauthator</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2022);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2014, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2022, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2169 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2022)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2014);

-- Rencontre 2023 — D4 : la Tombe d’Aumry
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2023, 'la Tombe d’Aumry', 'D4', 4, 2001, NULL, '<ul>\n<li>1 × Goelier de Syluné</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2023);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2015, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2023, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2170 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2023)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2015);

-- Rencontre 2024 — D5 : Assassinat d’un personnage
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2024, 'Assassinat d’un personnage', 'D5', 5, 2001, NULL, '<ul>\n<li>2 × Naug-Adar</li>\n<li>2 × Rat Familier</li>\n<li>4 × Mercenaire Bloodthorn</li>\n<li>1 × Molosse satanique</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2024);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2016, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2024, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2171 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2024)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2016);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2017, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2024, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2172 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2024)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2017);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2018, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 3, 2024, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2173 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2024)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2018);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2019, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 4, 2024, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2174 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2024)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2019);

-- Rencontre 2025 — D6 : Tueurs dans la nuit
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2025, 'Tueurs dans la nuit', 'D6', 6, 2001, NULL, '<ul>\n<li>1 × Traqueur de Baine</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2025);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2020, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2025, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2175 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2025)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2020);

-- Chapitre 2002 — C : Château Roche
INSERT INTO dd_scenarios_chapitres (scc_id, scc_sce_id, scc_nom, scc_ordre, scc_abreviation, scc_description)
SELECT 2002, 2001, 'Château Roche', 2, 'C', NULL
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_scenarios_chapitres WHERE scc_id = 2002);

-- Rencontre 2038 — C1 : Barbicane
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2038, 'Barbicane', 'C1', 1, 2002, NULL, '<ul>\n<li>2 × chasseur Maug</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2038);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2003, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2038, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2209 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2038)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2003);

-- Rencontre 2039 — C2 : la Cour
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2039, 'la Cour', 'C2', 2, 2002, NULL, '<ul>\n<li>1 × Nazrym</li>\n<li>1 × Molosse satanique</li>\n<li>1 × Corbeau fiélon</li>\n<li>2 × Ettin fiélon</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2039);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2088, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2039, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2224 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2039)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2088);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2089, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2039, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2174 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2039)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2089);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2090, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 3, 2039, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2225 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2039)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2090);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2091, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 4, 2039, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2226 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2039)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2091);

-- Chapitre 2003 — F : La Folie d'Azmaer
INSERT INTO dd_scenarios_chapitres (scc_id, scc_sce_id, scc_nom, scc_ordre, scc_abreviation, scc_description)
SELECT 2003, 2001, 'La Folie d\'Azmaer', 3, 'F', NULL
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_scenarios_chapitres WHERE scc_id = 2003);

-- Rencontre 2001 — 1 : La Crevasse du Coup d’épee
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2001, 'La Crevasse du Coup d’épee', '1', 1, 2003, NULL, '<ul>\n<li>1 × Aunrae Dhuunirv</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2001);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2150, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2001, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2244 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2001)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2150);

-- Rencontre 2002 — 2 : Poste de Garde Drow
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2002, 'Poste de Garde Drow', '2', 2, 2003, NULL, NULL
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2002);

-- Rencontre 2003 — 3 : Le Repaire d’Ombreroc
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2003, 'Le Repaire d’Ombreroc', '3', 3, 2003, NULL, NULL
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2003);

-- Rencontre 2004 — 4 : Caverne des Feux arachnéens
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2004, 'Caverne des Feux arachnéens', '4', 4, 2003, NULL, NULL
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2004);

-- Rencontre 2005 — 5 : Sanctuaire de Lolth
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2005, 'Sanctuaire de Lolth', '5', 5, 2003, NULL, NULL
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2005);

-- Rencontre 2006 — 6 : Le Labyrinthe
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2006, 'Le Labyrinthe', '6', 6, 2003, NULL, NULL
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2006);

-- Rencontre 2007 — 7 : Le Pont du Gouffre
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2007, 'Le Pont du Gouffre', '7', 7, 2003, NULL, NULL
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2007);

-- Rencontre 2008 — 8 : Le Lac du Crane
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2008, 'Le Lac du Crane', '8', 8, 2003, NULL, NULL
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2008);

-- Rencontre 2009 — 9 : Le Temple de Lolth
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2009, 'Le Temple de Lolth', '9', 9, 2003, NULL, '<ul>\n<li>Aunrae Dhuunirv (effectif non précisé)</li>\n<li>1 × Greyanna (Level up)</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2009);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2109, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2009, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2244 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2009)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2109);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2110, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2009, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2245 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2009)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2110);

-- Rencontre 2010 — 10 : Chambre du tresor
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2010, 'Chambre du tresor', '10', 10, 2003, NULL, NULL
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2010);

-- Rencontre 2026 — F2a : Poste de Garde Drow avancé
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2026, 'Poste de Garde Drow avancé', 'F2a', 11, 2003, NULL, '<ul>\n<li>1 × Lirdnolu Dhuurniv</li>\n<li>1 × Familier araignée velue</li>\n<li>1 × Duagloth Seerear</li>\n<li>4 × Drow éclaireur de Dhuurniv</li>\n<li>1 × Siar Egloth</li>\n<li>4 × Drow éclaireur expérimenté de Dhuurniv</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2026);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2004, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2026, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2159 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2026)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2004);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2005, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2026, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2160 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2026)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2005);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2006, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 3, 2026, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2161 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2026)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2006);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2007, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 4, 2026, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2162 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2026)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2007);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2021, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 5, 2026, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2176 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2026)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2021);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2022, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 6, 2026, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2177 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2026)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2022);

-- Chapitre 2004 — L : L'antre Sinistre d'Alokair
INSERT INTO dd_scenarios_chapitres (scc_id, scc_sce_id, scc_nom, scc_ordre, scc_abreviation, scc_description)
SELECT 2004, 2001, 'L\'antre Sinistre d\'Alokair', 4, 'L', NULL
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_scenarios_chapitres WHERE scc_id = 2004);

-- Chapitre 2005 — U : Soulèvement
INSERT INTO dd_scenarios_chapitres (scc_id, scc_sce_id, scc_nom, scc_ordre, scc_abreviation, scc_description)
SELECT 2005, 2001, 'Soulèvement', 5, 'U', NULL
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_scenarios_chapitres WHERE scc_id = 2005);

-- Rencontre 2011 — U1 : Chef de meute
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2011, 'Chef de meute', 'U1', 1, 2005, NULL, '<ul>\n<li>1 × Crocgivre</li>\n<li>4 × Loup légendaire</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2011);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2034, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2011, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2200 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2011)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2034);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2037, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2011, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2203 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2011)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2037);

-- Rencontre 2012 — U2 : Susurrus Déchainé
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2012, 'Susurrus Déchainé', 'U2', 2, 2005, NULL, '<ul>\n<li>1 × Gardien de la croisée des chemins</li>\n<li>1 × Azalar Fauconnier</li>\n<li>1 × Satyre</li>\n<li>1 × Le Susurrus</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2012);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2035, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2012, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2201 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2012)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2035);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2036, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2012, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2202 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2012)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2036);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2038, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 3, 2012, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2205 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2012)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2038);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2112, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 4, 2012, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2247 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2012)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2112);

-- Rencontre 2013 — U3 : Bataille du Pont
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2013, 'Bataille du Pont', 'U3', 3, 2005, NULL, '<ul>\n<li>1 × Forthar Helvenstron</li>\n<li>2 × Ogre War Hulk</li>\n<li>4 × Archer Zhentilar</li>\n<li>5 × Fantassin d&apos;élite Zhentilar</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2013);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2092, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2013, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2227 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2013)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2092);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2093, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2013, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2228 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2013)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2093);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2094, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 3, 2013, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2229 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2013)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2094);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2111, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 4, 2013, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2246 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2013)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2111);

-- Rencontre 2014 — U4 : Soutien aérien
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2014, 'Soutien aérien', 'U4', 4, 2005, NULL, '<ul>\n<li>1 × Zvopua l&apos;Aberration Draconique</li>\n<li>1 × Eregul l&apos;Indépendant</li>\n<li>3 × Istivin Naerindyth</li>\n<li>4 × Destrier d’Istivin</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2014);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2095, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2014, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2230 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2014)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2095);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2096, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2014, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2231 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2014)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2096);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2097, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 3, 2014, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2166 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2014)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2097);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2098, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 4, 2014, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2167 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2014)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2098);

-- Rencontre 2015 — U5 : Embuscade du Balhannoth
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2015, 'Embuscade du Balhannoth', 'U5', 5, 2005, NULL, '<ul>\n<li>2 × Balhannoth</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2015);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2099, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2015, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2232 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2015)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2099);

-- Rencontre 2016 — U6 : Evasion de prison
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2016, 'Evasion de prison', 'U6', 6, 2005, NULL, '<ul>\n<li>1 × Le Gardien</li>\n<li>20 × Garde terrifiant</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2016);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2102, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2016, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2235 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2016)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2102);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2103, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2016, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2236 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2016)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2103);

-- Rencontre 2017 — U7 : Immunité diplomatique
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2017, 'Immunité diplomatique', 'U7', 7, 2005, NULL, '<ul>\n<li>1 × Jezz l&apos;Estropié</li>\n<li>1 × Familier vipère</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2017);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2100, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2017, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2233 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2017)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2100);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2101, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2017, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2234 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2017)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2101);

-- Rencontre 2018 — U8 : L’ombre de Trystemine
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2018, 'L’ombre de Trystemine', 'U8', 8, 2005, NULL, '<ul>\n<li>1 × Seigneur Trystemine (Possédé)</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2018);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2104, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2018, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2237 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2018)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2104);

-- Rencontre 2019 — U9 : La chute de Sombrespoir
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2019, 'La chute de Sombrespoir', 'U9', 9, 2005, NULL, '<ul>\n<li>1 × Scyllua Sombrespoir</li>\n<li>1 × Targaraene</li>\n<li>4 × Erinyes</li>\n<li>4 × diable barbu</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2019);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2105, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2019, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2238 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2019)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2105);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2106, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2019, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2239 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2019)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2106);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2107, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 3, 2019, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2240 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2019)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2107);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2108, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 4, 2019, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2241 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2019)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2108);

-- ============================================================
-- Scénario 2002 — Anauroch : l'Empire de Pénombre
-- ============================================================
INSERT INTO dd_scenarios (sce_id, sce_nom, sce_ordre, sce_description, sce_camp_id)
SELECT 2002, 'Anauroch : l\'Empire de Pénombre', 2, '<h2>Résumé de l\'aventure</h2>\n\n<h3>Chapitre 1 : La Tour du Hurlevent</h3>\n\n<p>Exploration des ruines de la Tour du Hurlevent à Myth Drannor pour découvrir le vol des Parchemins Nétherisses sous forme d\'un arbre magique, le Quess Ar Teranthvar. ?</p>\n\n<h3>Chapitre 2 : La Crypte d’Augathra le Dément</h3>\n\n<p>Recherche d\'Augathra le Dément dans une crypte infestée de phaerimms pour obtenir des informations sur le Quess Ar Teranthvar et le Prophète. ?</p>\n\n<h3>Chapitre 3 : Recherches et préparatifs</h3>\n\n<p>Investigations à Château-Suif et au Mont Talath pour localiser le Prophète et se préparer à traverser le désert d\'Anauroch.</p>\n\n<h3>Chapitre 4 : Sous les tours blanches</h3>\n\n<p>Découverte d\'Oreme, ancienne cité des sarrukh, où le Prophète, une liche sarrukh, est libéré des griffes de Kharantes, une abomination yuan-ti. ? Les joueurs obtiennent des informations sur le Calice d\'Amaunator.</p>\n\n<h3>Chapitre 5 : Rivage de l’Ombre</h3>\n\n<p>Confrontation finale sur les rives de la Mer de l’Ombre pour détruire le Quess Ar Teranthvar avec le Calice d\'Amaunator, tout en affrontant Hadrhune et ses alliés.</p>\n\n<h2>Objectifs principaux</h2>\n\n<ul>\n	<li>Empêcher les Shadovars et les disciples de Shar de détruire la Toile. ?</li>\n	<li>Récupérer et disperser les Parchemins Nétherisses pour éviter leur utilisation maléfique. ?</li>\n	<li>Libérer le Prophète et obtenir des informations sur le Calice d\'Amaunator.</li>\n	<li>Affronter Hadrhune et ses alliés pour mettre fin au rituel de corruption.</li>\n</ul>\n\n<h2>Enjeux et conséquences</h2>\n\n<ul>\n	<li>Les joueurs se font des ennemis puissants, notamment les Shadovars, l\'Église de Shar, et les phaerimms.</li>\n	<li>La destruction du Quess Ar Teranthvar libère les phaerimms emprisonnés sous Anauroch, créant de nouvelles menaces pour Faerûn.</li>\n	<li>Les Shadovars entament une quête pour retrouver les fragments des parchemins nétherisses.</li>\n	<li>Informations sur le désert d\'Anauroch et le Plan des Ombres :\n	<ul>\n		<li><strong>Conditions </strong>environnementales et dangers : Tempêtes de sable, dunes mobiles, éblouissement, coups de soleil, et difficultés de déplacement dans le sable.</li>\n		<li><strong>Habitants</strong> : Bédouins nomades méfiants envers la magie et D’tarigs, guides et marchands du désert.</li>\n		<li><strong>Commerce et équipements spécialisés</strong> : Vêtements et outils adaptés au désert, protection contre les éléments, et commerce contrôlé par le Zhentarim et les D’tarigs.</li>\n		<li><strong>Objets magiques</strong> : Artefacts comme le Calice d’Amaunator, le Livre de la noirceur, et les Tablettes de Pharyssolnyth.</li>\n		<li><strong>Créatures spécifiques</strong> : Krinths, serpents de la Mer de l’Ombre, sharns, et vesserabes, souvent liés au Plan des Ombres et à la Cité de Pénombre.</li>\n	</ul>\n	</li>\n</ul>\n\n<h2>Conclusion</h2>\n\n<p>Les joueurs réussissent à contrecarrer les plans des Shadovars et de l\'Église de Shar, mais leurs actions entraînent des répercussions importantes, notamment la libération des phaerimms et le chaos à Pénombre. Bien qu\'ils soient célébrés comme des héros, de nouveaux défis et ennemis les attendent dans Faerûn. </p>', 5
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_scenarios WHERE sce_id = 2002);

-- Chapitre 2006 — M : La Tour du Hurlevent
INSERT INTO dd_scenarios_chapitres (scc_id, scc_sce_id, scc_nom, scc_ordre, scc_abreviation, scc_description)
SELECT 2006, 2002, 'La Tour du Hurlevent', 1, 'M', NULL
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_scenarios_chapitres WHERE scc_id = 2006);

-- Rencontre 2071 — 0 : Tour du Hurlevent
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2071, 'Tour du Hurlevent', '0', 1, 2006, NULL, '<ul>\n<li>1 × Darcassan</li>\n<li>1 × Darcassan le Mage</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2071);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2192, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2071, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2354 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2071)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2192);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2193, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2071, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2355 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2071)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2193);

-- Rencontre 2027 — M1 : Mauvais Sang
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2027, 'Mauvais Sang', 'M1', 2, 2006, NULL, '<ul>\n<li>1 × Keevosen Nihili</li>\n<li>4 × Loups-garou (forme hybride)</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2027);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2023, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2027, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2189 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2027)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2023);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2024, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2027, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2190 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2027)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2024);

-- Rencontre 2028 — M2 : Un habile défi
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2028, 'Un habile défi', 'M2', 3, 2006, NULL, '<ul>\n<li>1 × Darcassan l&apos;Habile</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2028);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2025, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2028, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2191 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2028)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2025);

-- Rencontre 2029 — M3 : Belladone
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2029, 'Belladone', 'M3', 4, 2006, NULL, '<ul>\n<li>1 × Sombre tourmenteur avancé</li>\n<li>2 × Âme-en-peine vénérable</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2029);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2026, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2029, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2192 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2029)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2026);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2188, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2029, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2193 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2029)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2188);

-- Rencontre 2030 — M4 : Gardiens de pierre
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2030, 'Gardiens de pierre', 'M4', 5, 2006, NULL, '<ul>\n<li>2 × Golem de pierre avancé</li>\n<li>1 × Horreur guerrière</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2030);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2190, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2030, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2352 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2030)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2190);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2191, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2030, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2353 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2030)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2191);

-- Rencontre 2031 — M5 : Le guerrier attaque
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2031, 'Le guerrier attaque', 'M5', 6, 2006, NULL, '<ul>\n<li>1 × Darcassan le guerrier</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2031);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2028, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2031, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2194 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2031)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2028);

-- Rencontre 2032 — M6 : Les Gardiens du coffre-fort
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2032, 'Les Gardiens du coffre-fort', 'M6', 7, 2006, '<p>Les Eladrins sont des créatures célestes originaires d\'Arborée. Ce sont des chevaliers et des seigneurs parcourant le cosmos à la recherche de personnes bonens dans le besoin. Ils sont farouchement indépendants mais ils représentent une part importantes des forces du bien.</p>', '<ul>\n<li>1 × Bralani avancé</li>\n<li>1 × Ghaele</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2032);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2029, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2032, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2195 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2032)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2029);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2030, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2032, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2196 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2032)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2030);

-- Rencontre 2033 — M7 : Ce n'est qu'un exercice
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2033, 'Ce n\'est qu\'un exercice', 'M7', 8, 2006, NULL, '<ul>\n<li>2 × Tigre sanguinaire</li>\n<li>3 × Our céleste</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2033);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2031, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2033, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2197 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2033)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2031);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2032, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2033, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2198 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2033)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2032);

-- Rencontre 2034 — M8 : Bataille dans le foyer
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2034, 'Bataille dans le foyer', 'M8', 9, 2006, NULL, '<ul>\n<li>1 × Darcassan le Gardien</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2034);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2033, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2034, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2199 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2034)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2033);

-- Chapitre 2007 — C : La Crypte d'Augathra la Démente
INSERT INTO dd_scenarios_chapitres (scc_id, scc_sce_id, scc_nom, scc_ordre, scc_abreviation, scc_description)
SELECT 2007, 2002, 'La Crypte d\'Augathra la Démente', 2, 'C', NULL
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_scenarios_chapitres WHERE scc_id = 2007);

-- Rencontre 2044 — C00a : Rencontres spécifiques
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2044, 'Rencontres spécifiques', 'C00a', 1, 2007, '<p>Table de rencontre aléatoire des Rocterres<br />\nd% Rencontre NR Source<br />\n01-07 1d2 chimères 9 MM 34<br />\n08-15 1d4 méduses 10 MM 180<br />\n16-23 1d2 gynosphinx 10 MM 233<br />\n24-30 1d3 lézard géant à bandes 11 San 164<br />\n31-36 1d6 géants de pierre 11 MM 124<br />\n37-42 1d4+1 sentinelles saguaro 12 San 181<br />\n43-46 1d3 scorpions monstrueux gargantuesques<br />\n12 MM 288<br />\n47-53 1d4 béhirs 12 MM 25<br />\n54-57 1 golem de chair draconique* 14 MM2 116<br />\n58-60 1 dragon des sables adulte 14 San 154<br />\n61-64 Tempête de sable - GDM 91<br />\n65-100 Aucune rencontre<br />\n* Se retire si ses points de vie sont réduits à 70 ou moins. Voir<br />\nrencontre C1.</p>', '<ul>\n<li>8 × Sentinelles Saguaro</li>\n<li>11 × Esclaves génasis de terre</li>\n<li>1 × Cube gélatineux</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2044);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2120, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2044, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2255 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2044)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2120);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2121, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2044, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2256 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2044)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2121);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2122, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 3, 2044, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2257 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2044)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2122);

-- Rencontre 2043 — C01 : Entrée de Synode
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2043, 'Entrée de Synode', 'C01', 2, 2007, NULL, '<ul>\n<li>1 × Golem de chair draconique</li>\n<li>4 × Géants de Phaerlin (Enragés)</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2043);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2118, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2043, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2253 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2043)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2118);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2119, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2043, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2254 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2043)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2119);

-- Rencontre 2045 — C08 : Poste de garde abandonné
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2045, 'Poste de garde abandonné', 'C08', 3, 2007, NULL, '<ul>\n<li>4 × Nécrophages de poussière (évolués)</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2045);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2123, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2045, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2258 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2045)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2123);

-- Rencontre 2046 — C09 : Entrée d’Augathra
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2046, 'Entrée d’Augathra', 'C09', 4, 2007, NULL, '<ul>\n<li>2 × Holocauste élémentaire</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2046);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2124, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2046, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2259 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2046)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2124);

-- Rencontre 2047 — C11 : Chapelle d’Amaunathor
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2047, 'Chapelle d’Amaunathor', 'C11', 5, 2007, NULL, '<ul>\n<li>1 × Vestige onirique</li>\n<li>1 × Skorpiogéant</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2047);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2125, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2047, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2260 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2047)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2125);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2126, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2047, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2261 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2047)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2126);

-- Rencontre 2048 — C15 : Tombes cachées
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2048, 'Tombes cachées', 'C15', 6, 2007, NULL, '<ul>\n<li>4 × chats des cryptes</li>\n<li>1 × Hurlemort</li>\n<li>2 × Golems de diamant</li>\n<li>3 × Momies</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2048);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2127, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2048, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2262 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2048)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2127);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2128, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2048, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2263 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2048)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2128);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2129, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 3, 2048, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2264 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2048)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2129);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2130, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 4, 2048, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2265 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2048)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2130);

-- Rencontre 2049 — C20 : Cascade
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2049, 'Cascade', 'C20', 7, 2007, NULL, '<ul>\n<li>1 × Tyramort</li>\n<li>2 × Varrangoin, mineur</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2049);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2131, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2049, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2266 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2049)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2131);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2132, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2049, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2267 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2049)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2132);

-- Rencontre 2050 — C22 : Première salle de garde
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2050, 'Première salle de garde', 'C22', 8, 2007, NULL, '<ul>\n<li>3 × géants de phaerlin (en rage)</li>\n<li>1 × Tyrannoœil</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2050);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2133, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2050, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2268 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2050)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2133);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2134, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2050, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2269 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2050)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2134);

-- Rencontre 2051 — C25 : Deuxième salle de garde
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2051, 'Deuxième salle de garde', 'C25', 9, 2007, NULL, '<ul>\n<li>2 × géants de phaerlin (en rage)</li>\n<li>1 × Tyrannoœil</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2051);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2135, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2051, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2268 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2051)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2135);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2136, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2051, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2269 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2051)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2136);

-- Rencontre 2052 — C27 : Laboratoire
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2052, 'Laboratoire', 'C27', 10, 2007, NULL, '<ul>\n<li>4 × Serpent ailé</li>\n<li>1 × Sang ardent flétri</li>\n<li>1 × Culcathrax</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2052);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2137, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2052, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2270 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2052)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2137);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2138, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2052, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2271 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2052)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2138);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2139, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 3, 2052, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2272 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2052)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2139);

-- Rencontre 2053 — C28 : Pépinière de Phaerimm
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2053, 'Pépinière de Phaerimm', 'C28', 11, 2007, NULL, '<ul>\n<li>2 × Phaerimm nouveau-né</li>\n<li>3 × Percetombe</li>\n<li>2 × Phaerimm juvénile</li>\n<li>1 × Tyrannoœil</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2053);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2140, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2053, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2273 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2053)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2140);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2141, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2053, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2274 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2053)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2141);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2142, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 3, 2053, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2275 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2053)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2142);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2143, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 4, 2053, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2269 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2053)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2143);

-- Rencontre 2054 — C32 : Chambres du Maître
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2054, 'Chambres du Maître', 'C32', 12, 2007, NULL, '<ul>\n<li>2 × Gargouilles Kir-Lanan</li>\n<li>1 × Drullister</li>\n<li>1 × Cushtal</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2054);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2144, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2054, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2276 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2054)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2144);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2145, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2054, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2277 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2054)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2145);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2218, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 3, 2054, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2405 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2054)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2218);

-- Rencontre 2072 — C36 : Salle du Mythalar
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2072, 'Salle du Mythalar', 'C36', 13, 2007, NULL, '<ul>\n<li>1 × Légion-en-peine supérieure</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2072);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2194, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2072, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2356 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2072)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2194);

-- Rencontre 2073 — C37 : L'incantateur sans visage
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2073, 'L\'incantateur sans visage', 'C37', 14, 2007, NULL, '<ul>\n<li>1 × L&apos;incantateur sans visage</li>\n<li>6 × Guerrier krinth</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2073);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2195, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2073, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2357 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2073)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2195);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2196, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2073, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2358 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2073)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2196);

-- Chapitre 2008 — W : Recherches et développements
INSERT INTO dd_scenarios_chapitres (scc_id, scc_sce_id, scc_nom, scc_ordre, scc_abreviation, scc_description)
SELECT 2008, 2002, 'Recherches et développements', 3, 'W', NULL
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_scenarios_chapitres WHERE scc_id = 2008);

-- Rencontre 2079 — Attaque Shadovar
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2079, 'Attaque Shadovar', NULL, 1, 2008, NULL, '<ul>\n<li>4 × Mage Shadovar</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2079);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2219, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2079, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2330 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2079)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2219);

-- Rencontre 2056 — 1 : Embuscade de la Secte
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2056, 'Embuscade de la Secte', '1', 2, 2008, NULL, '<ul>\n<li>2 × Cultiste du Pic du Fracassement</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2056);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2154, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2056, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2328 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2056)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2154);

-- Rencontre 2057 — 2 : Patrouille de Shadovar
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2057, 'Patrouille de Shadovar', '2', 3, 2008, NULL, '<ul>\n<li>2 × Vesserabe</li>\n<li>2 × Mage Shadovar</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2057);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2155, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2057, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2329 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2057)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2155);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2156, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2057, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2330 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2057)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2156);

-- Rencontre 2058 — 3 : Pillards psioniques
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2058, 'Pillards psioniques', '3', 4, 2008, NULL, '<ul>\n<li>3 × pillard Asabi</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2058);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2158, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2058, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2332 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2058)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2158);

-- Chapitre 2009 — T : Sous la tour blanche
INSERT INTO dd_scenarios_chapitres (scc_id, scc_sce_id, scc_nom, scc_ordre, scc_abreviation, scc_description)
SELECT 2009, 2002, 'Sous la tour blanche', 4, 'T', NULL
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_scenarios_chapitres WHERE scc_id = 2009);

-- Rencontre 2059 — 1 : Les catacombes d’Oreme
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2059, 'Les catacombes d’Oreme', '1', 1, 2009, NULL, '<ul>\n<li>5 × Asabi Brute</li>\n<li>1 × Kharantes</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2059);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2171, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2059, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2339 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2059)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2171);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2208, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2059, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2340 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2059)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2208);

-- Rencontre 2060 — 2 : Portails des Thaaluds
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2060, 'Portails des Thaaluds', '2', 2, 2009, NULL, '<ul>\n<li>3 × pilleur de tombe supérieur</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2060);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2173, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2060, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2341 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2060)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2173);

-- Rencontre 2061 — 4 : La Tour d’Askilion
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2061, 'La Tour d’Askilion', '4', 3, 2009, NULL, '<ul>\n<li>1 × Askilion</li>\n<li>4 × pilleur de tombe supérieur</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2061);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2174, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2061, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2342 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2061)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2174);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2175, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2061, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2341 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2061)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2175);

-- Chapitre 2010 — S : Rivage de l'Ombre
INSERT INTO dd_scenarios_chapitres (scc_id, scc_sce_id, scc_nom, scc_ordre, scc_abreviation, scc_description)
SELECT 2010, 2002, 'Rivage de l\'Ombre', 5, 'S', NULL
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_scenarios_chapitres WHERE scc_id = 2010);

-- Rencontre 2062 — 1 : Attaque aérienne
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2062, 'Attaque aérienne', '1', 1, 2010, NULL, '<ul>\n<li>3 × Éclaireurs aériens Shadovar</li>\n<li>3 × Vesserabe</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2062);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2176, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2062, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2343 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2062)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2176);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2217, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2062, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2329 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2062)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2217);

-- Rencontre 2063 — 2 : Bataille dans l’oasis
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2063, 'Bataille dans l’oasis', '2', 2, 2010, NULL, '<ul>\n<li>2 × Adepte de l&apos;ombre Sharéen</li>\n<li>8 × Soldat d&apos;élite krinth</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2063);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2177, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2063, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2344 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2063)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2177);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2178, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2063, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2345 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2063)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2178);

-- Rencontre 2064 — 3 : Hors des profondeurs
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2064, 'Hors des profondeurs', '3', 3, 2010, NULL, '<ul>\n<li>2 × Serpents de la mer de l&apos;ombre</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2064);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2179, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2064, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2346 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2064)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2179);

-- Rencontre 2065 — 4 : Gardiens des vergers
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2065, 'Gardiens des vergers', '4', 4, 2010, NULL, '<ul>\n<li>6 × krinth Guerrier prêtre de Shar</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2065);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2180, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2065, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2347 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2065)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2180);

-- Rencontre 2066 — 5 : Un ennemi ancestral
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2066, 'Un ennemi ancestral', '5', 5, 2010, NULL, '<ul>\n<li>2 × Phaerimm adulte</li>\n<li>1 × Hadrhune</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2066);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2181, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2066, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2348 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2066)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2181);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2214, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2066, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2349 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2066)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2214);

-- Rencontre 2070 — 6 : Hardrhune intervient
INSERT INTO dd_rencontres (re_id, re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition)
SELECT 2070, 'Hardrhune intervient', '6', 6, 2010, NULL, '<ul>\n<li>1 × Hadrhune</li>\n<li>1 × double d&apos;ombre de Hadrhune</li>\n<li>1 × Delethyrsos</li>\n</ul>'
FROM DUAL WHERE EXISTS (SELECT 1 FROM dd_campagnes WHERE camp_id = 5) AND NOT EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2070);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2185, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 1, 2070, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2349 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2070)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2185);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2186, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 2, 2070, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2350 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2070)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2186);
INSERT INTO dd_oppositions (opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
SELECT 2187, mo.mo_nom, mocat.mocat_nom, mo.mo_stats, 3, 2070, mo.mo_id, 0
FROM dd_monstres mo LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
WHERE mo.mo_id = 2351 AND EXISTS (SELECT 1 FROM dd_rencontres WHERE re_id = 2070)
  AND NOT EXISTS (SELECT 1 FROM dd_oppositions WHERE opp_id = 2187);
