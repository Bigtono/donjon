-- sql/2026-08-28_objets_dd2024_sp-im9c.sql
-- SP-IM9c — Les objets magiques dont le texte du SRD porte une table.
--
-- Source : FR_SRD_CC_v5.2.1-objets_magiques.pdf.
--
-- SP-IM9a avait volontairement laissé la description de ces 10 objets intacte :
-- leurs tables sortent du PDF en colonnes désassemblées, les importer en texte
-- brut aurait produit une bouillie illisible. Leur rareté, leur harmonisation et
-- leur catégorie étaient déjà corrigées.
--
-- Ce patch saisit les 10 tables dans dd_tableaux (convention texte, ids 43-52) et
-- réécrit les descriptions avec le tag [[tab:slug]] — même mécanique que pour les
-- espèces en SP-IM8. om_description figure dans tableauChampsHotes(), le tag y
-- est donc résolu au rendu.
--
-- DEUX RECONSTRUCTIONS DÉLICATES, vérifiées plutôt que devinées :
--   * Sac de haricots magiques : le PDF sépare les plages de dés des effets en
--     deux blocs distincts. Ils sont réappariés dans l'ordre de lecture.
--   * Tarot mystérieux : 44 plages pour 22 cartes, en alternance entre la colonne
--     « jeu de 13 cartes » et la colonne « jeu de 22 cartes ». Le générateur
--     REFUSE de produire le fichier si les deux colonnes ne comptent pas
--     respectivement 13 et 22 plages strictement croissantes — double contrôle
--     indépendant de la reconstruction.
--
-- Le chapelet mystique est saisi À LA MAIN : ses trois colonnes (plage, perle,
-- sort) s'entremêlent dans l'extraction, une reconstitution automatique aurait
-- été hasardeuse.
--
-- IDEMPOTENCE : ids de tableaux figés, INSERT … ON DUPLICATE KEY UPDATE pour les
--   tables, UPDATE ciblés par om_id pour les descriptions. Rejouable.

-- ------------------------------------------------------------
-- 1. Les 10 tables (dd_tableaux)
-- ------------------------------------------------------------

INSERT INTO dd_tableaux
  (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_ruleset_var_id,
   tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible,
   tab_date_creation, tab_date_modif)
VALUES
  (43, 'amulette-des-plans-destinations', 'Amulette des plans — destinations', '! 1d100 | Destination
01–60 | Emplacement aléatoire sur le plan que vous aviez nommé
61–70 | Emplacement aléatoire sur un Plan Intérieur déterminé par le résultat de 1d6 : 1, le Plan de l’Air ; 2, le Plan de la Terre ; 3, le Plan du Feu ; 4, le Plan de l’Eau ; 5, la Féerie ; et 6, la Gisombre
71–80 | Emplacement aléatoire sur un Plan Extérieur déterminé par le résultat de 1d8 : 1, l’Arborée ; 2, l’Arcadie ; 3, les Terres des Bêtes ; 4, la Bytopie ; 5, l’Élysée ; 6, Méchanus ; 7, le Mont Céleste ; et 8, Ysgard
81–90 | Emplacement aléatoire sur un Plan Extérieur déterminé par le résultat de 1d8 : 1, les Abysses ; 2, l’Achéron ; 3, les Carcères ; 4, la Géhenne ; 5, Hadès ; 6, les Limbes ; 7, les Neuf Enfers ; et 8, le Pandémonium
91–00 | Emplacement aléatoire sur le Plan Astral', 'lc', NULL, 2, 93, NULL, 0, 0, 1, NOW(), NOW()),
  (44, 'effets-baguette-des-merveilles', 'Effets de baguette des merveilles', '! 1d100 | Effet
01–20 | Vous lancez un sort émanant du point d’origine choisi. Lancez 1d10 pour déterminer le sort : 1–2, boule de feu ; 3–4, lenteur ; 5–6, lueurs féeriques ; 7–8, nuage nauséabond ; 9–10, ténèbres.
21–25 | Rien ne se passe au point d’origine. Au lieu de cela, vous subissez l’état Étourdi jusqu’au début de votre tour suivant, convaincu qu’un événement extraordinaire se produit sous vos yeux.
26–30 | Vous lancez bourrasque. La Ligne créée par le sort s’étend de vous jusqu’au point d’origine.
31–35 | Rien ne se passe au point d’origine. Au lieu de cela, vous subissez 1d6 dégâts psychiques.
36–40 | Une pluie torrentielle s’abat pendant 1 minute dans un Cylindre de 36 m de haut et 18 m de rayon centré sur le point d’origine. Pendant cette durée, la zone d’effet est à Visibilité réduite.
41–45 | Une nuée de 600 papillons surdimensionnés emplit un Cylindre de 18 m de haut et 9 m de rayon centré sur le point d’origine. Les papillons restent pendant 10 minutes, durant lesquelles la zone d’effet est à Visibilité nulle.
46–50 | Vous lancez éclair. La Ligne créée par le sort s’étend de vous jusqu’au point d’origine.
51–55 | La créature la plus proche du point d’origine est agrandie comme si vous aviez lancé sur elle agrandissement/rapetissement. Si vous n’êtes pas cette cible et que celle-ci ne peut pas être affectée par ce sort, c’est vous qui en devenez la cible.
56–60 | Une créature formée magiquement apparaît dans un espace inoccupé aussi près que possible du point d’origine. Elle n’est pas sous votre contrôle, agit normalement et disparaît après 1 heure ou lorsqu’elle tombe à 0 point de vie. Lancez 1d4 pour déterminer quelle créature apparaît. Sur un1, un rhinocéros se présente ; 2, un éléphant ; 3–4, un rat.
61–64 | De l’herbe recouvre un cercle de 18 m de rayon au sol, le centre de ce cercle étant aussi proche que possible du point d’origine. Si de l’herbe était déjà présente, elle grandit jusqu’à atteindre dix fois sa taille normale et demeure ainsi pendant 1 minute.
65–68 | Un objet au choix du MJ disparaît dans le Plan Éthéré. L’objet ne doit être porté par personne, doit se trouver dans un rayon de 36 m du point d’origine et ne doit pas mesurer plus de 3 m de long, de large ou de haut. S’il n’y a aucun objet de la sorte à portée, rien ne se passe.
69–72 | Rien ne se passe au point d’origine. À la place, vous rapetissez comme si vous aviez lancé agrandissement/rapetissement sur vous-même et restez dans cet état pendant 1 minute.
73–77 | Des feuilles poussent sur la créature la plus proche du point d’origine. À moins d’être arrachées avant, ces feuilles brunissent et tombent au bout de 24 heures.
78–82 | Rien ne se passe au point d’origine. Au lieu de cela, une explosion de lumière colorée et scintillante s’étend depuis vous dans une Émanation de 9 m. Chaque créature prise dans la zone doit réussir un jet de sauvegarde de Constitution DD 15 sous peine de subir l’état Aveuglé pendant 1 minute. Une créature affectée réitère le JS à la fin de chacun de ses tours, et met un terme à l’effet sur elle-même en cas de réussite.
83–87 | Rien ne se passe au point d’origine. Au lieu de cela, vous lancez invisibilité sur vous-même.
88–92 | Rien ne se passe au point d’origine. Au lieu de cela, un torrent de 1d4 × 10 gemmes, chacune d’une valeur de 1 po, jaillit de la pointe de la baguette vers le point d’origine en formant une Ligne de 9 m de long sur 1,50 m de large. Chaque gemme inflige 1 dégât contondant ; les dégâts totaux infligés par les gemmes se divisent équitablement entre toutes les créatures présentes sur cette Ligne.
93–97 | Vous lancez métamorphose, en ciblant la créature la plus proche du point d’origine. Lancez 1d4 pour déterminer la nouvelle forme de la cible. 1, la nouvelle forme est un ours noir ; 2, une guêpe géante ; 3–4, une grenouille.
98–00 | La créature la plus proche du point d’origine effectue un jet de sauvegarde de Constitution DD 15. En cas d’échec, elle subit l’état Entravé et commence à se pétrifier. Tant qu’elle est ainsi Entravée, la créature réitère le JS à la fin de son tour suivant. En cas de réussite, l’effet prend fin. En cas d’échec, la créature subit l’état Pétrifié qui remplace l’état Entravé. La pétrification persiste jusqu’à ce que la créature en soit affranchie par le sort restauration suprême ou une magie équivalente.', 'lc', NULL, 2, 93, NULL, 0, 0, 1, NOW(), NOW()),
  (45, 'bouteille-du-mauvais-genie', 'Bouteille du mauvais génie — effets', '! 1d10 | Effet
1 | L’éfrit vous attaque. Après 5 rounds de combat, l’éfrit disparaît et la bouteille perd sa magie.
2–9 | L’éfrit comprend les mêmes langues que vous et obéit à vos ordres pendant 1 heure, après quoi il retourne dans la bouteille, scellée par un nouveau bouchon. La bouteille ne peut pas être débouchée pendant 24 heures. Lors des deux prochains débouchages de la bouteille, le même effet se produit. Si l’on ouvre la bouteille une quatrième fois, l’éfrit s’enfuit, disparaît et la bouteille perd sa magie.
10 | L’éfrit comprend les mêmes langues que vous et peut lancer souhait une fois pour vous. Il disparaît après avoir exaucé le souhait (au bout de 1 heure sans cela) et la bouteille perd sa magie.', 'lc', NULL, 2, 93, NULL, 0, 0, 1, NOW(), NOW()),
  (46, 'chapeau-mille-sorts-effets', 'Chapeau mille-sorts — effets', '! 1d100 | Effet
01–50 | Vous lancez un sort déterminé aléatoirement en jetant 1d10 : 1, agrandissement/rapetissement (effet agrandissement) ; 2, agrandissement/rapetissement (effet rapetissement) ; 3, boule de feu ; 4, bourrasque ; 5, éclair ; 6, force fantasmagorique ; 7, invisibilité (lancé sur vous) ; 8, lueurs féeriques ; 9, métamorphose ; 10, nuage nauséabond.
51–55 | Vous subissez l’état Étourdi jusqu’à la fin de votre tour suivant, convaincu qu’un événement extraordinaire vient de se produire.
56–60 | Une nuée de papillons inoffensifs remplit un Cube de 3 m dans un rayon de 9 m de vous. La nuée se disperse au bout de 1 minute.
61–65 | Vous sortez un objet non magique du chapeau. Lancez 1d4 pour déterminer de quel objet il s’agit : 1, une fiole d’acide ; 2, une flasque de feu grégeois ; 3, un pied-de-biche ; 4, une torche allumée.
66–70 | En proie à une poussée de « maladie magique », vous subissez l’état Empoisonné pendant 1 heure.
71–75 | Vous subissez l’état Pétrifié jusqu’à la fin de votre tour suivant.
76–80 | Vous sortez un objet non magique du chapeau. Lancez 1d4 pour déterminer de quel objet il s’agit : 1, une dague ; 2, un grappin attaché à une corde ; 3, un sac de chausse-trappes ; 4, une gemme d’une valeur de 50 po.
81–85 | Une créature apparaît dans un espace inoccupé, le plus près possible de vous. La créature n’est pas sous votre contrôle, agit normalement et disparaît après 1 heure ou lorsqu’elle tombe à 0 point de vie. Lancez 1d4 pour déterminer la créature : 1, un chameau ; 2, un éléphant ; 3, une mule ; 4, un serpent constricteur.
86–90 | Une nuée de chauve-souris Hostile sort du chapeau, occupe votre espace et vous attaque.
91–95 | Un portail vertical bidirectionnel de 3 m, donnant sur un autre plan d’existence, s’ouvre en un espace inoccupé dans un rayon de 9 m de vous et reste ouvert jusqu’à la fin de votre tour suivant. Le MJ détermine sur quel plan il mène.
96–00 | Vous sortez un objet magique du chapeau.', 'lc', NULL, 2, 93, NULL, 0, 0, 1, NOW(), NOW()),
  (47, 'perles-du-chapelet-mystique', 'Perles du chapelet mystique', '! 1d20 | Perle | Sort
1–6 | Perle de bénédiction | bénédiction
7–8 | Perle de châtiment | châtiment de révélation
9 | Perle de convocation | gardien de la foi
10 | Perle d’envolée divine | vent divin
11–16 | Perle de guérison | soins (au 2e niveau)
17–20 | Perle de rétablissement | restauration suprême', 'lc', NULL, 2, 93, NULL, 0, 0, 1, NOW(), NOW()),
  (48, 'cierge-d-invocation-plans', 'Cierge d’invocation — Plans Extérieurs', '! 1d100 | Plan Extérieur
01–05 | Abysses
06–10 | Achéron
11–17 | Arborée
18–25 | Arcadie
26–33 | Bytopie
34–38 | Carcères
39–46 | Élysée
47–51 | Géhenne
52–56 | Hadès
57–61 | Limbes
62–69 | Méchanus
70–77 | Mont Céleste
78–82 | Neuf Enfers
83–87 | Pandémonium
88–95 | Terres des Bêtes
96–00 | Ysgard', 'lc', NULL, 2, 93, NULL, 0, 0, 1, NOW(), NOW()),
  (49, 'pieces-de-la-robe-du-camelot', 'Pièces de la robe du camelot', '! 1d100 | Pièce
01–08 | Sac de 100 po
09–15 | Coffre en argent (30 cm de long, 15 de large et de profondeur) d’une valeur de 500 po
16–22 | Porte en fer (jusqu’à 3 m de large et 3 m de haut, barrée du côté de votre choix) que vous pouvez encastrer dans une ouverture à votre portée ; elle s’adapte à l’ouverture, se fixe et pivote sur ses gonds
23–30 | 10 gemmes d’une valeur unitaire de 100 po
31–44 | Échelle en bois (7,20 m de long)
45–51 | Cheval de selle équipé d’une selle d’équitation
52–59 | Fossé (un Cube de 3 m) que vous pouvez disposer au sol dans un rayon de 3 m de vous
60–68 | 4 potions de guérison
69–75 | Barque (3,60 m de long)
76–83 | Parchemin de sort contenant un sort du 1er, 2e ou 3e niveau (choisissez)
84–90 | 2 molosses
91–96 | Fenêtre (60 cm sur 1,20 m, profondeur jusqu’à 60 cm), que vous pouvez placer sur une surface verticale à portée
97–00 | Bélier portable', 'lc', NULL, 2, 93, NULL, 0, 0, 1, NOW(), NOW()),
  (50, 'sphere-d-annihilation-portails', 'Sphère d’annihilation — interaction avec un portail', '! 1d100 | Résultat
01–50 | La sphère est détruite.
51–85 | La sphère franchit le portail ou entre dans l’espace extradimensionnel.
86–00 | Une faille planaire propulse chaque créature et objet dans un rayon de 54 m de la sphère, cette dernière comprise, vers un plan d’existence aléatoire.', 'lc', NULL, 2, 93, NULL, 0, 0, 1, NOW(), NOW()),
  (51, 'effets-des-haricots-magiques', 'Effets des haricots magiques', '! 1d100 | Effet
01 | 5d4 champignons poussent. Si une créature mange un champignon, lancez n’importe quel dé. En cas de résultat impair, la créature doit réussir un jet de sauvegarde de Constitution DD 15 sous peine de subir 5d6 dégâts de poison et l’état Empoisonné pendant 1 heure. En cas de résultat pair, la créature reçoit 5d6 points de vie temporaires qui persistent pendant 1 heure.
02–10 | Un geyser jaillit sur 9 m de haut en déversant de l’eau, de la bière, de la mayonnaise, du thé, du vinaigre, du vin ou de l’huile (au choix du MJ) pendant 1d4 minutes.
11–20 | Un sylvanien pousse. Lancez n’importe quel dé. En cas de résultat impair, ce sylvanien est Chaotique Mauvais. En cas de résultat pair, il est Chaotique Bon.
21–30 | Une statue de pierre à votre effigie, animée, mais immobile, se dresse et profère des menaces verbales à votre encontre. Si vous partez et que d’autres s’en approchent, elle vous décrit comme le plus odieux des scélérats et intime aux nouveaux arrivants de vous pourchasser. Si vous êtes sur le même plan d’existence que la statue, elle sait exactement où vous êtes. La statue devient inanimée au bout de 24 heures.
31–40 | Un feu de camp aux flammes vertes s’allume ; il brûle pendant 24 heures (sauf si quelqu’un l’éteint).
41–50 | Trois criards poussent.
51–60 | 1d4 + 4 crapauds rose vif émergent en rampant. Chaque fois qu’un crapaud est touché, il se transforme en un monstre de taille G ou inférieure au choix du MJ, qui agit selon son alignement et sa nature. Le monstre persiste pendant 1 minute puis disparaît dans une bouffée de fumée rose vif.
61–70 | Une bulette affamée surgit du sol et passe à l’attaque.
71–80 | Un arbre fruitier émerge. Il porte 1d10 + 20 fruits, dont 1d8 agissent comme autant de potions déterminées aléatoirement. L’arbre disparaît au bout de 1 heure. Les fruits cueillis persistent et conservent leurs propriétés magiques pendant 30 jours.
81–90 | Un nid contenant 1d4 + 3 œufs aux couleurs de l’arc-en-ciel apparaît. Toute créature qui mange un œuf effectue un jet de sauvegarde de Constitution DD 20. En cas de réussite, cette créature augmente sa valeur de caractéristique la plus basse de 1, de manière permanente, le hasard décidant de laquelle en cas d’égalité. En cas d’échec, la créature subit 10d6 dégâts de force, provoqués par une explosion interne.
91–95 | Une pyramide à base carrée de 18 m de côté surgit du sol. À l’intérieur, une chambre funéraire abrite une momie, une momie auguste ou quelque autre Mort-vivant choisi par le MJ. Son sarcophage contient un trésor choisi par le MJ.
96–00 | Un plant de haricot géant surgit, poussant jusqu’à une hauteur décidée par le MJ. Le sommet mène là où le MJ le décide : panorama superbe, château d’une géante des nuages, autre plan d’existence, etc.', 'lc', NULL, 2, 93, NULL, 0, 0, 1, NOW(), NOW()),
  (52, 'tarot-mysterieux', 'Tarot mystérieux', '! Carte | 1d100 (jeu de 13 cartes) | 1d100 (jeu de 22 cartes)
La Balance | — | 01–05
Le Bouffon | 01–08 | 06–10
Le Chevalier | 09–16 | 11–15
La Clef | 17–24 | 16–20
La Comète | — | 21–25
Le Crâne | 25–32 | 26–29
Le Donjon | — | 30–33
L’Énigme | — | 34–37
L’Étoile | 33–40 | 38–42
Euryale | 41–48 | 43–46
Les Flammes | 49–56 | 47–50
Le Fou | — | 51–54
La Gemme | — | 55–59
La Lune | 57–64 | 60–64
Le Néant | 65–68 | 65–68
Les Parques | — | 69–73
La Ruine | 69–76 | 74–77
Les Serres | — | 78–81
Le Soleil | 77–84 | 82–86
Le Traître | 85–92 | 87–90
Le Trône | 93–100 | 91–95
Le Vizir | — | 96–00', 'lcc', NULL, 2, 93, NULL, 0, 0, 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug), tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu), tab_align = VALUES(tab_align),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id), tab_res_id = VALUES(tab_res_id),
  tab_date_modif = NOW();

-- ------------------------------------------------------------
-- 2. Descriptions des 10 objets
-- ------------------------------------------------------------

DROP TEMPORARY TABLE IF EXISTS tmp_om_im9c;

CREATE TEMPORARY TABLE tmp_om_im9c (
  t_id   INT UNSIGNED NOT NULL PRIMARY KEY,
  t_desc TEXT         NOT NULL
) ENGINE=InnoDB;

INSERT INTO tmp_om_im9c (t_id, t_desc) VALUES
  (1316, '<p>Tant que vous portez cette amulette, vous pouvez entreprendre l’action Magie en nommant un lieu que vous connaissez sur un autre plan d’existence. Effectuez ensuite un test d’Intelligence (Arcanes) DD 15. En cas de réussite, vous lancez changement de plan. En cas d’échec, vous-même et chaque créature et objet dans un rayon de 4,50 m voyagez vers une destination aléatoire déterminée par un jet de 1d100 sur la table ci-après.</p><p>[[tab:amulette-des-plans-destinations]]</p>'),
  (1292, '<p>Cette baguette dispose de 7 charges. Lorsque vous la tenez, vous pouvez entreprendre l’action Magie pour dépenser 1 charge en choisissant un point dans un rayon de 36 m. Ce lieu devient le point d’origine d’un sort ou d’un autre effet magique déterminé aléatoirement selon la table « Effets de baguette des merveilles ». Le DD de sauvegarde des sorts lancés par la baguette est de 15. Quand la portée maximale d’un sort est normalement inférieure à 36 m, elle passe à 36 m lorsqu’il est lancé par la baguette. Quand un effet a plusieurs cibles potentielles, le MJ détermine aléatoirement lesquelles sont affectées.</p><p>Récupération des charges. La baguette récupère quotidiennement 1d6 + 1 charges dépensées, à l’aube. Si vous dépensez la dernière charge, lancez 1d20. Sur un résultat de 1, la baguette tombe en poussière, à jamais détruite.</p><p>[[tab:effets-baguette-des-merveilles]]</p>'),
  (1330, '<p>Lorsque vous consacrez l’action Magie à retirer le bouchon, un épais nuage de fumée s’échappe de cette bouteille en bronze peint. À la fin de votre tour, la fumée se dissipe dans une gerbe de feu inoffensive et un éfrit apparaît en un espace inoccupé dans un rayon de 9 m.</p><p>La première fois que la bouteille est ouverte, le MJ jette le dé et consulte la table ci-après pour déterminer ce qui se produit.</p><p>[[tab:bouteille-du-mauvais-genie]]</p>'),
  (1355, '<p>Ce chapeau pointu présente les propriétés suivantes. Focaliseur d’incantation. Tant que vous le tenez, ce chapeau peut faire office de focaliseur d’incantation pour vos sorts de Magicien. Tout sort que vous lancez pas le biais du chapeau reçoit une composante somatique spéciale : vous devez plonger la main dans le chapeau et en « sortir » le sort.</p><p>Sort inconnu. Tant que vous tenez le chapeau, vous pouvez tenter de lancer un sort du 1er niveau ou supérieur que vous ne connaissez pas. Ce sort doit figurer sur la liste de sorts du Magicien, être d’un niveau que vous pouvez lancer, et le coût de ses composantes matérielles ne doit pas excéder 1 000 po. Une fois le sort choisi, dépensez un emplacement de sort correspondant au niveau du sort. Puis, pour déterminer si vous parvenez à le lancer, effectuez un test d’Intelligence (Arcanes) (DD 10 + le niveau du sort). En cas de réussite, vous lancez le sort en respectant son temps d’incantation, et ne pouvez plus recourir à cette propriété avant d’avoir terminé un Repos court ou long. En cas d’échec, vous ne lancez pas le sort, mais produisez un effet aléatoire, déterminé selon la table ci-après.</p><p>Tout sort lancé par le biais du chapeau reprend votre DD de sauvegarde des sorts et votre bonus d’attaque de sort.</p><p>[[tab:chapeau-mille-sorts-effets]]</p>'),
  (1356, '<p>Ce collier possède 1d4 + 2 perles magiques faites d’aigue-marine, de perle noire ou de topaze. Il possède en outre de nombreuses perles non magiques faites à partir de minéraux tels que l’ambre, l’héliotrope, la citrine, le corail, le jade, la perle ou le quartz. Si une perle magique est retirée du collier, celle-ci perd sa magie.</p><p>Il existe six types de perle magique. Le MJ choisit le type de chaque perle ou le détermine aléatoirement selon la table ci-dessous. Ce chapelet peut posséder plusieurs perles du même type. Pour en utiliser une, vous devez porter le collier. Chaque perle renferme un sort que vous pouvez lancer par une action Bonus (en appliquant votre DD de sauvegarde des sorts si nécessaire). Une fois lancé le sort contenu dans une perle magique, celle-ci ne peut plus resservir avant l’aube suivante.</p><p>[[tab:perles-du-chapelet-mystique]]</p>'),
  (1358, '<p>La magie du cierge est activée lorsque celui-ci est allumé, ce qui nécessite l’action Magie. Après avoir brûlé 4 heures, le cierge est détruit. Vous pouvez l’éteindre auparavant, afin de le réutiliser par la suite. Déduisez le temps de combustion par incréments de 1 minute de son temps de combustion total.</p><p>Tant qu’il brûle, le cierge émet une Lumière faible dans un rayon de 9 m. Dans cette lumière, vous bénéficiez de l’Avantage aux Tests d20. En outre, tout Clerc ou Druide dans sa lumière peut lancer ses sorts du 1er niveau préparés sans dépenser d’emplacements de sort.</p><p>Une autre option, lorsque vous allumez le cierge pour la première fois, consiste à lancer le sort portail. Dans ce cas, le cierge est détruit. Le portail créé par le sort ouvre sur un Plan Extérieur spécifique choisi par le MJ ou déterminé par le hasard selon la table ci-après.</p><p>[[tab:cierge-d-invocation-plans]]</p>'),
  (1459, '<p>Des pièces d’étoffe de formes et de couleurs diverses sont cousues sur cette robe. Lorsque vous portez la robe, vous pouvez entreprendre l’action Magie pour détacher l’une de ces pièces qui devient l’objet ou la créature qu’elle représente. Une fois la dernière pièce détachée, la robe devient un vêtement ordinaire.</p><p>Sur la robe sont cousus deux exemplaires de chacune des pièces suivantes :</p><ul><li>Corde (enroulée)</li><li>Dague</li><li>Lanterne sourde (remplie d’huile et allumée)</li><li>Miroir</li><li>Perche</li><li>Sac</li></ul><p>4d4 autres pièces sont elles aussi cousues sur la robe. Le MJ en choisit le type ou le détermine aléatoirement selon la table suivante.</p><p>[[tab:pieces-de-la-robe-du-camelot]]</p>'),
  (1469, '<p>Cette sphère noire de 60 cm de diamètre forme un trou dans le multivers en suspension dans l’espace, stabilisé par le champ magique qui l’entoure.</p><p>La sphère annihile toute matière qu’elle traverse et toute matière qui la traverse. Les Artefacts constituent la seule exception. Un Artefact qui n’est pas sensible aux dégâts d’une sphère d’annihilation la traverse sans dommage. Pour le reste, tout ce qui touche la sphère sans être entièrement englouti et annihilé par elle subit 8d10 dégâts de force.</p><p><b>Contrôler la sphère.</b> Une sphère d’annihilation reste stationnaire jusqu’à ce que quelqu’un en prenne le contrôle. Si vous êtes dans un rayon de 18 m d’une sphère, vous pouvez entreprendre l’action Magie pour effectuer un test d’Intelligence (Arcanes) DD 25. En cas de réussite, vous contrôlez la sphère jusqu’au début de votre tour suivant. Si elle était sous le contrôle d’une autre créature, celle-ci en perd le contrôle. En cas d’échec, la sphère se déplace de 3 m en ligne droite vers vous.</p><p>Tant que vous contrôlez la sphère, vous pouvez consacrer une action Bonus à la déplacer dans la direction de votre choix d’une distance maximale en mètres égale à votre modificateur d’Intelligence x 1,5 (minimum 1,50 m). Si la sphère pénètre dans l’espace d’une créature, celle-ci doit réussir un jet de sauvegarde de Dextérité DD 19 sous peine d’être touchée par la sphère et de subir 8d10 dégâts de force. Une créature réduite à 0 point de vie par ces dégâts est annihilée, ne laissant derrière elle que ses biens, sans aucun autre vestige physique.</p><p><b>Interactions avec la sphère.</b> Si la sphère entre en contact avec un portail planaire comme celui créé par le sort portail ou un espace extradimensionnel comme celui d’un puits portable, le MJ détermine aléatoirement ce qui se passe, en recourant à la table ci-après.</p><p>[[tab:sphere-d-annihilation-portails]]</p>'),
  (1464, '<p>Ce sac de toile épaisse renferme 3d4 haricots secs quand on le découvre. Il pèse 250 g indépendamment du nombre de haricots qu’il contient et devient un objet non magique dès qu’il est vide.</p><p>Si vous lancez un ou plusieurs haricots hors du sac, ils explosent sous forme d’une Sphère de 3 m de rayon centrée sur lui. Tous les haricots ainsi lancés sont détruits dans l’explosion. Chaque créature prise dans la Sphère, y compris vous-même, effectue un jet de sauvegarde de Dextérité DD 15, et subit 5d4 dégâts de force en cas d’échec, la moitié en cas de réussite.</p><p>Si vous retirez un haricot du sac, le plantez dans la terre ou le sable puis l’arrosez, il disparaît et produit un effet 1 minute plus tard, à l’endroit où vous l’avez planté. Le MJ peut choisir un effet dans la table ci-après ou laisser le hasard décider.</p><p>[[tab:effets-des-haricots-magiques]]</p>'),
  (1479, '<p>Généralement rangé dans un étui ou une sacoche, ce jeu de tarot se compose de cartes (ou « lames ») en ivoire ou en vélin. Si la plupart (75 %) de ces jeux comportent treize cartes, certains en ont vingt-deux.</p><p>Référez-vous à la colonne correspondante de la table « Tarot mystérieux » pour laisser le hasard décider des cartes que vous piochez dans le jeu.</p><p>Avant de piocher une carte, vous devez déclarer combien de cartes vous comptez tirer, puis vous les piochez au hasard. Toutes les cartes piochées au-delà du chiffre annoncé sont sans effet. Sinon, la magie d’une carte opère dès que vous piochez celle-ci dans le paquet. Vous ne devez pas laisser s’écouler plus d’une heure entre chaque pioche. Si vous renoncez à piocher le chiffre annoncé, le nombre de cartes qui reste pour atteindre ce chiffre s’envole de lui-même du paquet et prend effet simultanément.</p><p>Dès qu’une carte a été piochée, elle disparaît. À moins que cette carte soit le Fou ou le Bouffon, la carte réapparaît dans le paquet, ce qui laisse la possibilité de piocher deux fois la même carte. (Quand le Fou ou le Bouffon quitte le jeu, relancez sur la table si cette carte est tirée de nouveau.)</p><p>[[tab:tarot-mysterieux]]</p><p><b>L’effet de chaque carte est décrit ci-dessous.</b> La Balance. Vous pouvez augmenter de 2 l’une de vos valeurs de caractéristique, jusqu’à un maximum de 22, à condition de diminuer une autre valeur de caractéristique de 2. Il vous est interdit de diminuer une caractéristique dont la valeur est inférieure ou égale à 5. Vous pouvez également choisir de ne pas modifier vos valeurs de caractéristique, auquel cas cette lame est sans effet.</p><p>Le Bouffon. Vous bénéficiez de l’Avantage aux Tests d20 pendant les 72 prochaines heures, ou bien vous pouvez piocher deux cartes en plus du chiffre annoncé.</p><p>Le Chevalier. Vous recevez l’allégeance d’un chevalier, qui apparaît magiquement en un espace inoccupé dans un rayon de 9 m de vous. Ce chevalier est du même alignement que vous et vous sert loyalement jusqu’à sa mort, convaincu que vos destins sont intimement liés. Concertez-vous avec votre MJ afin d’imaginer un nom et une histoire à ce PNJ. Le MJ peut décider de recourir à un autre profil de jeu pour ce chevalier, à sa guise.</p><p>La Clef. Une arme magique rare ou de rareté supérieure, dont vous avez la maîtrise, apparaît dans vos mains. C’est le MJ qui choisit cette arme.</p><p>La Comète. La prochaine fois que vous entrez en combat avec une ou plusieurs créatures Hostiles, vous pouvez désigner l’une d’elles comme votre ennemi au moment de jouer l’Initiative. Si vous réduisez cet ennemi à 0 point de vie lors du combat, vous bénéficierez de l’Avantage aux jets de sauvegarde contre la mort pendant 1 an. Si quelqu’un d’autre réduit votre ennemi désigné à 0 point de vie ou si vous n’en avez choisi aucun, cette lame est sans effet.</p><p>Le Crâne. Un avatar de la Mort (cf. profil ci-joint) apparaît dans un espace inoccupé, aussi près que possible de vous. L’avatar, un inquiétant squelette vêtu d’une robe noire et brandissant une faux spectrale, ne prend que vous pour cible avec ses attaques. L’avatar disparaît lorsqu’il tombe à 0 point de vie ou que vous mourez. Si l’un de vos alliés inflige des dégâts à l’avatar, cet allié convoque un autre avatar de la Mort. Le nouvel avatar apparaît dans un espace inoccupé, aussi près que possible de cet allié, et ne cible que ce dernier avec ses attaques. Vous-même et vos alliés ne pouvez convoquer chacun qu’un seul avatar en conséquence de cette pioche. Une créature tuée par un avatar ne peut pas être ramenée à la vie.</p><p>Le Donjon. Vous disparaissez et plongez dans un état d’animation suspendue au sein d’une sphère extradimensionnelle. Tout ce que vous portiez disparaît avec vous hormis les Artefacts, qui demeurent dans l’espace que vous occupiez au moment de votre disparition. Vous restez emprisonné jusqu’à ce qu’on vous trouve ou vous retire de la sphère. Il est impossible de vous localiser au moyen de la magie de Divination, mais le sort souhait révèle la position de votre prison. Vous ne piochez plus aucune carte.</p><p><b>L’Énigme.</b> Réduit de façon permanente votre Intelligence ou votre Sagesse de 1d4 + 1 (valeur minimale de 1). Vous pouvez piocher une carte en plus du chiffre annoncé.</p><p><b>L’Étoile.</b> L’une de vos valeurs de caractéristique augmente de 2, jusqu’à un maximum de 24.</p><p><b>Euryale.</b> Le visage de méduse de la carte vous lance une malédiction. Vous subissez un malus de –2 aux jets de sauvegarde tant que persiste cette malédiction. Seul un dieu ou la magie de la carte « Les Parques » permet de lever cette malédiction.</p><p>Les Flammes. Un diable puissant devient votre ennemi. Ce diable travaille à votre perte et vous tourmente en savourant vos souffrances, avant de tenter de vous tuer. Cette haine persiste jusqu’à votre mort ou celle du diable.</p><p>Le Fou. Vous subissez le Désavantage aux Tests d20 pendant les 72 prochaines heures. Piochez une autre carte ; celle-ci n’est pas décomptée du chiffre annoncé.</p><p>La Gemme. Vingt-cinq bijoux d’une valeur unitaire de 2 000 po ou cinquante pierres précieuses d’une valeur unitaire de 1 000 po apparaissent à vos pieds.</p><p>La Lune. Vous recevez l’aptitude à lancer souhait 1d3 fois.</p><p>Le Néant. Votre âme est arrachée à votre corps et enfermée dans un objet en un lieu choisi par le MJ. Une ou plusieurs entités puissantes veillent sur ce lieu. Tant que votre âme est emprisonnée de cette manière, votre corps est inerte, cesse de vieillir et n’a nul besoin de nourriture, d’air ou d’eau. Le sort souhait ne parvient pas à réunir votre corps et votre âme, mais il révèle la position de l’objet qui renferme votre âme. Vous ne piochez plus aucune carte.</p><p>Les Parques. La trame de la réalité se délite et ses fils en tissent une nouvelle, vous permettant d’échapper à un événement comme s’il ne s’était jamais produit. Vous pouvez recourir à la magie de cette carte dès que vous la piochez ou en toute autre circonstance avant de mourir.</p><p>La Ruine. Toutes les formes de richesse que vous portez ou possédez, à l’exception des objets magiques, disparaissent. Vos biens meubles s’évanouissent. Vos négoces, bâtiments et terres sont perdus de la façon qui altère le moins possible le cours de la réalité. Tous les documents attestant que vous possédiez un bien volatilisé par cette carte disparaissent eux aussi.</p><p>Les Serres. Chaque objet magique que vous portez ou transportez se désintègre. Les Artefacts en votre possession, quant à eux, ne font que disparaître.</p><p>Le Soleil. Un objet magique (choisi par le MJ) apparaît sur votre personne. Vous recevez en outre quotidiennement 10 points de vie temporaires à l’aube, et ce jusqu’à votre mort.</p><p>Le Traître. Un PNJ au choix du MJ devient Hostile envers vous. Vous ignorez l’identité de ce PNJ tant que lui-même ou une tierce personne ne vous la révèle pas. Rien hormis le sort souhait ou une intervention divine ne peut mettre fin à l’hostilité de ce PNJ à votre égard.</p><p>Le Trône. Vous recevez la maîtrise et l’Expertise de votre choix entre les compétences Histoire, Intimidation, Intuition ou Persuasion. En outre, vous recevez la propriété légitime d’une petite forteresse quelque part dans le monde. Cela étant, cette forteresse est actuellement occupée par un ou plusieurs monstres, qui devront être éliminés pour que vous puissiez la faire vôtre.</p><p>Le Vizir. À tout moment de votre choix au cours de l’année qui suit la pioche de cette carte, vous pouvez poser une question tout en méditant et recevez mentalement une réponse exacte à cette question.</p>');

UPDATE dd_objets_magiques o
  JOIN tmp_om_im9c t ON t.t_id = o.om_id
SET o.om_description = t.t_desc;

DROP TEMPORARY TABLE tmp_om_im9c;
