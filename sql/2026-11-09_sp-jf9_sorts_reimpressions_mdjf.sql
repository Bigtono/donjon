-- sql/2026-11-09_sp-jf9_sorts_reimpressions_mdjf.sql
-- SP-JF9 — Sorts du MdJF déjà présents sous un autre supplément : fiche corrigée d'après gemmaline, source passée au MdJF,
-- mention de l'ancien supplément en fin de description (même règle que les dons, D-JF2)
-- Généré par tools/generer-sp-jf1-sorts.php le 2026-11-09 depuis gemmaline.com (index element-MJF.htm).
-- Rejouable : chaque insertion est gardée par NOT EXISTS. Pas de DELIMITER.

SET NAMES utf8mb4;

UPDATE dd_sorts SET so_co_id = 1,
  so_registre = 'électricité',
  so_vocal = 1,
  so_gestuel = 1,
  so_materiel = 1,
  so_focalisateur = 0,
  so_focalisateur_divin = 0,
  so_composante = 'une boucle en cuivre et un aimant',
  so_portee = 'courte (7,50 m +1,50 m/2 niveaux)',
  so_cible = '1 créature/3 niveaux de lanceur de sorts, chacune devant être adjacente à une autre',
  so_duree_incantation = '1 action simple',
  so_duree_sort = 'instantanée',
  so_jet_sauvegarde = 'Réflexes, 1/2 (voir description)',
  so_resistance = 'Oui',
  so_description = '<p>Un petit éclair frappe une créature tous les trois niveaux de lanceur de sorts du mage (jusqu''à un maximum de quatre créatures). Chaque cible doit se trouver dans une case adjacente à une autre. Le sort inflige 1d6 points de dégâts d''électricité tous les deux niveaux de lanceur de sorts (jusqu''à un maximum de 5d6). Une créature qui échoue son jet de Réflexes doit réussir un jet de Volonté sous peine d''être étourdie durant 1 round.</p>
<p><em>Ce sort figurait déjà dans le supplément « Magie de faerun ».</em></p>',
  so_res_id = 63
WHERE so_nom = 'Boucle électrique de Gedlee' AND so_res_id = 38;

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Boucle électrique de Gedlee' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Boucle électrique de Gedlee' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

UPDATE dd_sorts SET so_co_id = 5,
  so_vocal = 1,
  so_gestuel = 1,
  so_materiel = 0,
  so_focalisateur = 0,
  so_focalisateur_divin = 1,
  so_portee = 'contact',
  so_cible = '1 créature touchée',
  so_duree_incantation = '1 action simple ; voir description',
  so_duree_sort = '1 minute/niveau',
  so_jet_sauvegarde = 'Volonté, annule (inoffensif)',
  so_resistance = 'Oui (inoffensif)',
  so_description = '<p>Le sujet bénéficie d''un bonus de résistance de +3 aux jets de sauvegarde contre les sorts et pouvoirs magiques (mais pas contre les pouvoirs surnaturels et extraordinaires). Au niveau 11, l''initié de Mystra peut se lancer ce sort au prix d''une action libre.</p>
<p>Seul un initié de Mystra peut lancer ce sort.</p>
<p><em>Ce sort figurait déjà dans le supplément « Magie de faerun ».</em></p>',
  so_res_id = 63
WHERE so_nom = 'Bouclier magique' AND so_res_id = 38;

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Bouclier magique' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

UPDATE dd_sorts SET so_co_id = 7,
  so_vocal = 1,
  so_gestuel = 1,
  so_materiel = 0,
  so_focalisateur = 0,
  so_focalisateur_divin = 0,
  so_portee = 'courte (7,50 m + 1,50 m/2 niveaux)',
  so_cible = 'le jeteur de sorts',
  so_duree_incantation = '1 action simple',
  so_duree_sort = '1 minute/niveau',
  so_description = '<p>L''initié décèle aisément les défauts des objets mécaniques. Il peut effectuer les tests de Crochetage et de Désamorçage/sabotage comme s''il disposait d''un degré de maîtrise de 1/2 dans ces compétences. S''il possède déjà Ces compétences, il bénéficie d''un bonus d''intuition égal à son niveau de lanceur de sorts (jusqu''à un maximum de +15) aux tests.</p>
<p>Seul un initié de Gond peut lancer ce sort.</p>
<p><em>Ce sort figurait déjà dans le supplément « Magie de faerun ».</em></p>',
  so_res_id = 63
WHERE so_nom = 'Compréhension d''objet' AND so_res_id = 38;

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Compréhension d''objet' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

UPDATE dd_sorts SET so_co_id = 3,
  so_branche = 'Coercition',
  so_registre = 'mental',
  so_vocal = 1,
  so_gestuel = 1,
  so_materiel = 0,
  so_focalisateur = 1,
  so_focalisateur_divin = 0,
  so_composante = 'Focalisateur : une baguette d''au moins 30 centimètres de long',
  so_portee = 'courte (7,50 m + 1,50 m/2 niveaux)',
  so_cible = '1 créature vivante',
  so_duree_incantation = '1 action simple',
  so_duree_sort = '1 round/niveau',
  so_jet_sauvegarde = 'Vigueur, annule',
  so_resistance = 'Oui',
  so_description = '<p>Ce sort est depuis longtemps populaire auprès des esclavagistes et autres individus souhaitant que leurs serviteurs travaillent un peu plus vite. Néanmoins, les Magiciens Rouges en ont fait un sort de combat.</p>
<p>Une fois le sort jeté, le sujet ressent une douleur aussi vive qu''aiguë. Il est alors hébété pendant 1 round. A chaque round suivant, il subit un malus de -2 à l''attaque, aux sauvegardes et aux tests jusqu''à la fin du sort. De plus, un lanceur de sorts visé par le doux rappel de Nybor est distrait par la douleur et doit réussir un test de Concentration chaque fois qu''il souhaite lancer un sort.</p>
<p>Seul un initié de Loviatar peut lancer ce sort.</p>
<p><em>Ce sort figurait déjà dans le supplément « Magie de faerun ».</em></p>',
  so_res_id = 63
WHERE so_nom = 'Doux rappel de Nybor' AND so_res_id = 38;

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Doux rappel de Nybor' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Doux rappel de Nybor' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Kleptomage' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Doux rappel de Nybor' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Doux rappel de Nybor' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

UPDATE dd_sorts SET so_co_id = 5,
  so_vocal = 1,
  so_gestuel = 1,
  so_materiel = 0,
  so_focalisateur = 0,
  so_focalisateur_divin = 0,
  so_portee = 'personnelle',
  so_zone_effet = 'étoile d''énergie protectrice',
  so_duree_incantation = '1 action simple',
  so_duree_sort = '1 round/niveau (T)',
  so_description = '<p>Un amas d''énergie luisant apparaît près de l''épaule du prêtre, offrant autant de lumière qu''une simple bougie. Cette étoile a trois fonctions et le prêtre active celle de son choix au prix d''une action libre lors de son tour de jeu.</p>
<p><em>Renvoi des sorts</em>. L''étoile bénie peut renvoyer 1d4+3 niveaux de sorts, comme le sort renvoi des sorts. Tout niveau de sort renvoyé l''est pour la durée de l''étoile bénie (elle ne recouvre pas ces niveaux dépensés chaque fois que le jeteur de sorts opte de nouveau pour cette fonction). Si tous les niveaux de sorts sont utilisés, cette fonction cesse d''oeuvrer, mais pas les autres.</p>
<p><em>Protection</em>. L''étoile bénie confère au jeteur de sorts un bonus de circonstances de +10 à la CA sans que cela n''affecte ses actions.</p>
<p><em>Éclair de feu</em>. L''étoile bénie projette un rayon d''énergie (attaque de contact à distance) contre une créature située dans un rayon de 27 mètres, infligeant 1d6 points de dégâts de feu tous les deux niveaux de lanceur de sorts (jusqu''à un maximum de 10d6).</p>
<p>Seul un initié de Mystra peut lancer ce sort.</p>
<p><em>Ce sort figurait déjà dans le supplément « Le Guide des Personnages Monstrueux ».</em></p>',
  so_res_id = 63
WHERE so_nom = 'Etoile bénie' AND so_res_id = 69;

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 7 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Etoile bénie' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

UPDATE dd_sorts SET so_co_id = 1,
  so_vocal = 1,
  so_gestuel = 1,
  so_materiel = 0,
  so_focalisateur = 0,
  so_focalisateur_divin = 0,
  so_portee = '3 m',
  so_cible = 'cône de 3 m de long',
  so_duree_incantation = '1 action simple',
  so_duree_sort = 'instantanée',
  so_jet_sauvegarde = 'Vigueur, annule',
  so_resistance = 'Oui',
  so_description = CONCAT(so_description, '
<p><em>Ce sort figurait déjà dans le supplément « Magie de faerun ».</em></p>'),
  so_res_id = 63
WHERE so_nom = 'Nuage de confusion' AND so_res_id = 38;

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Nuage de confusion' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Nuage de confusion' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Barde' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Nuage de confusion' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

UPDATE dd_sorts SET so_co_id = 4,
  so_vocal = 1,
  so_gestuel = 1,
  so_materiel = 0,
  so_focalisateur = 0,
  so_focalisateur_divin = 0,
  so_portee = 'contact',
  so_cible = '1 créature touchée',
  so_duree_incantation = '1 action simple',
  so_duree_sort = '1 minute/niveau',
  so_jet_sauvegarde = 'Volonté, annule (inoffensif)',
  so_resistance = 'Oui (inoffensif)',
  so_description = CONCAT(so_description, '
<p><em>Ce sort figurait déjà dans le supplément « Magie de faerun ».</em></p>'),
  so_res_id = 63
WHERE so_nom = 'Vision aveugle' AND so_res_id = 38;

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Vision aveugle' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Vision aveugle' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Vision aveugle' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Druide' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Vision aveugle' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Rôdeur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Vision aveugle' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Kleptomage' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Vision aveugle' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Vision aveugle' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);
