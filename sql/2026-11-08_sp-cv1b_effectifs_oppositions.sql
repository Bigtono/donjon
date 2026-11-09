-- ============================================================
-- SP-CV1b — Effectifs des oppositions de L'Empire des Anges
-- 2026-11-08 — correctif de SP-CP11 (D-CP16, doc/DECISIONS_LOG.md)
-- ============================================================
-- L'effectif d'une opposition (« 5 × Asabi Brute ») était écrit dans la
-- composition de la rencontre (re_composition), pas dans le nom : la migration
-- SP-CP11 l'avait laissé à 1. Les valeurs ci-dessous sont lues ligne à ligne
-- dans les compositions par effectifsComposition() (include/opposition-pv.php) :
-- 118 lignes, toutes appariées à une opposition, dont 55 effectifs > 1.
--
-- Ordre : après 2026-11-07_sp-cp11 (colonnes opp_nombre / opp_pv_max) et après
-- 2026-11-08_sp-cv1 (insertion de ces oppositions, ids fixes 2001+).
-- « AND opp_nombre = 1 » : un effectif déjà corrigé à la main n'est pas écrasé.

UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2003 AND opp_nombre = 1; -- chasseur Maug (Barbicane)
UPDATE dd_oppositions SET opp_nombre = 4 WHERE opp_id = 2007 AND opp_nombre = 1; -- Drow éclaireur de Dhuurniv (Poste de Garde Drow avancé)
UPDATE dd_oppositions SET opp_nombre = 3 WHERE opp_id = 2010 AND opp_nombre = 1; -- Mercenaire crânes et massues (la Colline du bois du chêne)
UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2016 AND opp_nombre = 1; -- Naug-Adar (Assassinat d’un personnage)
UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2017 AND opp_nombre = 1; -- Rat Familier (Assassinat d’un personnage)
UPDATE dd_oppositions SET opp_nombre = 4 WHERE opp_id = 2018 AND opp_nombre = 1; -- Mercenaire Bloodthorn (Assassinat d’un personnage)
UPDATE dd_oppositions SET opp_nombre = 4 WHERE opp_id = 2022 AND opp_nombre = 1; -- Drow éclaireur expérimenté de Dhuurniv (Poste de Garde Drow avancé)
UPDATE dd_oppositions SET opp_nombre = 4 WHERE opp_id = 2024 AND opp_nombre = 1; -- Loups-garou (forme hybride) (Mauvais Sang)
UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2031 AND opp_nombre = 1; -- Tigre sanguinaire (Ce n'est qu'un exercice)
UPDATE dd_oppositions SET opp_nombre = 3 WHERE opp_id = 2032 AND opp_nombre = 1; -- Our céleste (Ce n'est qu'un exercice)
UPDATE dd_oppositions SET opp_nombre = 4 WHERE opp_id = 2037 AND opp_nombre = 1; -- Loup légendaire (Chef de meute)
UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2091 AND opp_nombre = 1; -- Ettin fiélon (la Cour)
UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2093 AND opp_nombre = 1; -- Ogre War Hulk (Bataille du Pont)
UPDATE dd_oppositions SET opp_nombre = 4 WHERE opp_id = 2094 AND opp_nombre = 1; -- Archer Zhentilar (Bataille du Pont)
UPDATE dd_oppositions SET opp_nombre = 3 WHERE opp_id = 2097 AND opp_nombre = 1; -- Istivin Naerindyth (Soutien aérien)
UPDATE dd_oppositions SET opp_nombre = 4 WHERE opp_id = 2098 AND opp_nombre = 1; -- Destrier d’Istivin (Soutien aérien)
UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2099 AND opp_nombre = 1; -- Balhannoth (Embuscade du Balhannoth)
UPDATE dd_oppositions SET opp_nombre = 20 WHERE opp_id = 2103 AND opp_nombre = 1; -- Garde terrifiant (Evasion de prison)
UPDATE dd_oppositions SET opp_nombre = 4 WHERE opp_id = 2107 AND opp_nombre = 1; -- Erinyes (La chute de Sombrespoir)
UPDATE dd_oppositions SET opp_nombre = 4 WHERE opp_id = 2108 AND opp_nombre = 1; -- diable barbu (La chute de Sombrespoir)
UPDATE dd_oppositions SET opp_nombre = 5 WHERE opp_id = 2111 AND opp_nombre = 1; -- Fantassin d'élite Zhentilar (Bataille du Pont)
UPDATE dd_oppositions SET opp_nombre = 4 WHERE opp_id = 2119 AND opp_nombre = 1; -- Géants de Phaerlin (Enragés) (Entrée de Synode)
UPDATE dd_oppositions SET opp_nombre = 8 WHERE opp_id = 2120 AND opp_nombre = 1; -- Sentinelles Saguaro (Rencontres spécifiques)
UPDATE dd_oppositions SET opp_nombre = 11 WHERE opp_id = 2121 AND opp_nombre = 1; -- Esclaves génasis de terre (Rencontres spécifiques)
UPDATE dd_oppositions SET opp_nombre = 4 WHERE opp_id = 2123 AND opp_nombre = 1; -- Nécrophages de poussière (évolués) (Poste de garde abandonné)
UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2124 AND opp_nombre = 1; -- Holocauste élémentaire (Entrée d’Augathra)
UPDATE dd_oppositions SET opp_nombre = 4 WHERE opp_id = 2127 AND opp_nombre = 1; -- chats des cryptes (Tombes cachées)
UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2129 AND opp_nombre = 1; -- Golems de diamant (Tombes cachées)
UPDATE dd_oppositions SET opp_nombre = 3 WHERE opp_id = 2130 AND opp_nombre = 1; -- Momies (Tombes cachées)
UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2132 AND opp_nombre = 1; -- Varrangoin, mineur (Cascade)
UPDATE dd_oppositions SET opp_nombre = 3 WHERE opp_id = 2133 AND opp_nombre = 1; -- géants de phaerlin (en rage) (Première salle de garde)
UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2135 AND opp_nombre = 1; -- géants de phaerlin (en rage) (Deuxième salle de garde)
UPDATE dd_oppositions SET opp_nombre = 4 WHERE opp_id = 2137 AND opp_nombre = 1; -- Serpent ailé (Laboratoire)
UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2140 AND opp_nombre = 1; -- Phaerimm nouveau-né (Pépinière de Phaerimm)
UPDATE dd_oppositions SET opp_nombre = 3 WHERE opp_id = 2141 AND opp_nombre = 1; -- Percetombe (Pépinière de Phaerimm)
UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2142 AND opp_nombre = 1; -- Phaerimm juvénile (Pépinière de Phaerimm)
UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2144 AND opp_nombre = 1; -- Gargouilles Kir-Lanan (Chambres du Maître)
UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2154 AND opp_nombre = 1; -- Cultiste du Pic du Fracassement (Embuscade de la Secte)
UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2155 AND opp_nombre = 1; -- Vesserabe (Patrouille de Shadovar)
UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2156 AND opp_nombre = 1; -- Mage Shadovar (Patrouille de Shadovar)
UPDATE dd_oppositions SET opp_nombre = 3 WHERE opp_id = 2158 AND opp_nombre = 1; -- pillard Asabi (Pillards psioniques)
UPDATE dd_oppositions SET opp_nombre = 5 WHERE opp_id = 2171 AND opp_nombre = 1; -- Asabi Brute (Les catacombes d’Oreme)
UPDATE dd_oppositions SET opp_nombre = 3 WHERE opp_id = 2173 AND opp_nombre = 1; -- pilleur de tombe supérieur (Portails des Thaaluds)
UPDATE dd_oppositions SET opp_nombre = 4 WHERE opp_id = 2175 AND opp_nombre = 1; -- pilleur de tombe supérieur (La Tour d’Askilion)
UPDATE dd_oppositions SET opp_nombre = 3 WHERE opp_id = 2176 AND opp_nombre = 1; -- Éclaireurs aériens Shadovar (Attaque aérienne)
UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2177 AND opp_nombre = 1; -- Adepte de l'ombre Sharéen (Bataille dans l’oasis)
UPDATE dd_oppositions SET opp_nombre = 8 WHERE opp_id = 2178 AND opp_nombre = 1; -- Soldat d'élite krinth (Bataille dans l’oasis)
UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2179 AND opp_nombre = 1; -- Serpents de la mer de l'ombre (Hors des profondeurs)
UPDATE dd_oppositions SET opp_nombre = 6 WHERE opp_id = 2180 AND opp_nombre = 1; -- krinth Guerrier prêtre de Shar (Gardiens des vergers)
UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2181 AND opp_nombre = 1; -- Phaerimm adulte (Un ennemi ancestral)
UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2188 AND opp_nombre = 1; -- Âme-en-peine vénérable (Belladone)
UPDATE dd_oppositions SET opp_nombre = 2 WHERE opp_id = 2190 AND opp_nombre = 1; -- Golem de pierre avancé (Gardiens de pierre)
UPDATE dd_oppositions SET opp_nombre = 6 WHERE opp_id = 2196 AND opp_nombre = 1; -- Guerrier krinth (L'incantateur sans visage)
UPDATE dd_oppositions SET opp_nombre = 3 WHERE opp_id = 2217 AND opp_nombre = 1; -- Vesserabe (Attaque aérienne)
UPDATE dd_oppositions SET opp_nombre = 4 WHERE opp_id = 2219 AND opp_nombre = 1; -- Mage Shadovar (Attaque Shadovar)

-- PV max des oppositions insérées par sp-cv1 après le pré-remplissage de
-- sp-cp11 (en production) : même lecture de la ligne « PV » du bloc de stats.
UPDATE dd_oppositions
   SET opp_pv_max = CAST(REGEXP_SUBSTR(REGEXP_SUBSTR(opp_stats, '[Pp][Vv] *:? *[0-9]+'), '[0-9]+') AS UNSIGNED)
 WHERE opp_pv_max IS NULL
   AND opp_stats REGEXP '[Pp][Vv] *:? *[0-9]+';
