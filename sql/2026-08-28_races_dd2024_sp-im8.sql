-- sql/2026-08-28_races_dd2024_sp-im8.sql
-- SP-IM8 — Les 9 espèces du SRD 5.2.1 (DD2024).
--
-- Source : FR_SRD_CC_v5.2.1-races.pdf, section « Description des espèces ».
-- Arbitrages du 2026-08-28 :
--   * les 3 tables du SRD vont dans dd_tableaux + tag [[tab:slug]] (convention
--     SP-TB), et non en <table> HTML dans cap_description ;
--   * réalignement intégral des 5 espèces déjà saisies sur le SRD.
--
-- Espèces créées (ids figés) : 18 Drakéide · 19 Goliath · 20 Orc · 21 Tieffelin
-- Espèces réalignées : 12 Humain · 13 Nain · 14 Halfelin · 15 Elfe · 16 Gnome
--
-- Ce que le patch corrige, tel que relevé en base le 2026-08-28 :
--   * Gnome : ses 3 traits étaient empilés dans ra_description (2 691 car.) au
--     lieu d'être des lignes dd_race_capacite — seule espèce hors modèle, ses
--     traits n'apparaissaient donc ni dans le bloc Traits de la fiche, ni dans
--     le panneau d'une capacité.
--   * Elfe : trait « Vision dans le noir » absent, et table des lignages saisie
--     en <table> HTML brut dans cap_description — la dette que SP-TB5 avait
--     soldée partout ailleurs.
--   * Humain : bloc d'en-tête sans « Type de créature ».
--   * Nain : bloc d'en-tête sans la phrase d'introduction.
--
-- Modèle repris de l'existant (Halfelin, Humain, Nain) :
--   ra_description = bloc d'en-tête (type de créature, taille, vitesse, amorce) ;
--   un trait = une ligne dd_capacites_speciales + une ligne dd_race_capacite,
--   ordonnée par cr_ordre à partir de 0 ;
--   cap_classe_initiale reste NULL — la colonne désigne une classe, pas une race.
--
-- « Vision dans le noir » a sa propre ligne par espèce (6 fois) : les portées
-- diffèrent (18 m ou 36 m) et c'est la convention déjà en base pour le Nain,
-- comme pour les capacités de classe homonymes (D-IM5).
--
-- IDEMPOTENCE : ids figés (espèces 12-21, traits 901+, tableaux 40-42),
--   INSERT … ON DUPLICATE KEY UPDATE. Rejouable.

-- ------------------------------------------------------------
-- 1. Tables du SRD (dd_tableaux)
-- ------------------------------------------------------------

INSERT INTO dd_tableaux
  (tab_id, tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_ruleset_var_id,
   tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible,
   tab_date_creation, tab_date_modif)
VALUES
  (40, 'ancetres-draconiques', 'Ancêtres draconiques', '! Dragon | Type de dégâts
Airain | Feu
Argent | Froid
Blanc | Froid
Bleu | Foudre
Bronze | Foudre
Cuivre | Acide
Noir | Acide
Or | Feu
Rouge | Feu
Vert | Poison', 'll', NULL, 2, 93, NULL, 0, 0, 1, NOW(), NOW()),
  (41, 'lignages-elfiques', 'Lignages elfiques', '! Lignage | Niveau 1 | Niveau 3 | Niveau 5
Drow | La portée de votre Vision dans le noir passe à 36 m. Vous connaissez également le sort mineur lumières dansantes. | lueurs féeriques | ténèbres
Elfe sylvestre | Votre Vitesse passe à 10,50 m. Vous connaissez également le sort mineur druidisme. | grande foulée | passage sans trace
Haut-elfe | Vous connaissez le sort mineur prestidigitation. Chaque fois que vous terminez un Repos long, vous pouvez remplacer ce sort mineur par un autre sort mineur de la liste de sorts du Magicien. | détection de la magie | foulée brumeuse', 'llll', NULL, 2, 93, NULL, 0, 0, 1, NOW(), NOW()),
  (42, 'heritages-fielons', 'Héritages fiélons', '! Héritage | Niveau 1 | Niveau 3 | Niveau 5
Abyssal | Vous bénéficiez de la Résistance aux dégâts de poison. Vous connaissez en outre le sort mineur bouffée de poison. | rayon empoisonné | immobilisation de personne
Chtonien | Vous bénéficiez de la Résistance aux dégâts nécrotiques. Vous connaissez en outre le sort mineur contact glacial. | simulacre de vie | rayon affaiblissant
Infernal | Vous bénéficiez de la Résistance aux dégâts de feu. Vous connaissez en outre le sort mineur trait de feu. | représailles infernales | ténèbres', 'llll', NULL, 2, 93, NULL, 0, 0, 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE
  tab_slug = VALUES(tab_slug), tab_nom = VALUES(tab_nom),
  tab_contenu = VALUES(tab_contenu), tab_align = VALUES(tab_align),
  tab_ruleset_var_id = VALUES(tab_ruleset_var_id), tab_res_id = VALUES(tab_res_id),
  tab_date_modif = NOW();

-- ------------------------------------------------------------
-- 2. Espèces (dd_races)
-- ------------------------------------------------------------

INSERT INTO dd_races
  (ra_id, ra_nom, ra_rat_id, ra_description, ra_mod_niveau, ra_camp_id,
   ra_res_id, ra_public, ra_visible, ra_ruleset_var_id)
VALUES
  (18, 'Drakéide', 3, '<p><strong>Type de créature</strong> : Humanoïde</p><p><strong>Catégorie de taille</strong> : M (moyenne, entre 1,50 m et 2,10 m)</p><p><strong>Vitesse</strong> : 9 m</p><p>En tant que drakéide, vous disposez des traits spéciaux suivants.</p>', 0, NULL, 93, 0, 1, 2),
  (15, 'Elfe', 3, '<p><strong>Type de créature</strong> : Humanoïde</p><p><strong>Catégorie de taille</strong> : M (moyenne, entre 1,50 m et 1,80 m)</p><p><strong>Vitesse</strong> : 9 m</p><p>En tant qu’elfe, vous disposez des traits spéciaux suivants.</p>', 0, NULL, 93, 0, 1, 2),
  (16, 'Gnome', 3, '<p><strong>Type de créature</strong> : Humanoïde</p><p><strong>Catégorie de taille</strong> : P (petite, entre 90 cm et 1,20 m)</p><p><strong>Vitesse</strong> : 9 m</p><p>En tant que gnome, vous disposez des traits spéciaux suivants.</p>', 0, NULL, 93, 0, 1, 2),
  (19, 'Goliath', 3, '<p><strong>Type de créature</strong> : Humanoïde</p><p><strong>Catégorie de taille</strong> : M (moyenne, entre 2,10 m et 2,40 m)</p><p><strong>Vitesse</strong> : 10,50 m</p><p>En tant que goliath, vous disposez des traits spéciaux suivants.</p>', 0, NULL, 93, 0, 1, 2),
  (14, 'Halfelin', 3, '<p><strong>Type de créature</strong> : Humanoïde</p><p><strong>Catégorie de taille</strong> : P (petite, entre 60 cm et 90 cm)</p><p><strong>Vitesse</strong> : 9 m</p><p>En tant que halfelin, vous disposez des traits spéciaux suivants.</p>', 0, NULL, 93, 0, 1, 2),
  (12, 'Humain', 3, '<p><strong>Type de créature</strong> : Humanoïde</p><p><strong>Catégorie de taille</strong> : M (moyenne, entre 1,20 m et 2,10 m) ou P (petite, de 60 cm à 1,20 m), à choisir lors de la sélection de l’espèce</p><p><strong>Vitesse</strong> : 9 m</p><p>En tant qu’humain, vous disposez des traits spéciaux suivants.</p>', 0, NULL, 93, 0, 1, 2),
  (13, 'Nain', 3, '<p><strong>Type de créature</strong> : Humanoïde</p><p><strong>Catégorie de taille</strong> : M (moyenne, entre 1,20 m et 1,50 m)</p><p><strong>Vitesse</strong> : 9 m</p><p>En tant que nain, vous disposez des traits spéciaux suivants.</p>', 0, NULL, 93, 0, 1, 2),
  (20, 'Orc', 3, '<p><strong>Type de créature</strong> : Humanoïde</p><p><strong>Catégorie de taille</strong> : M (moyenne, entre 1,80 m et 2,10 m)</p><p><strong>Vitesse</strong> : 9 m</p><p>En tant qu’orc, vous disposez des traits spéciaux suivants.</p>', 0, NULL, 93, 0, 1, 2),
  (21, 'Tieffelin', 3, '<p><strong>Type de créature</strong> : Humanoïde</p><p><strong>Catégorie de taille</strong> : M (moyenne, entre 1,20 m et 2,10 m) ou P (petite, de 90 cm à 1,20 m), à choisir lors de la sélection de l’espèce</p><p><strong>Vitesse</strong> : 9 m</p><p>En tant que tieffelin, vous disposez des traits spéciaux suivants.</p>', 0, NULL, 93, 0, 1, 2)
ON DUPLICATE KEY UPDATE
  ra_nom = VALUES(ra_nom), ra_rat_id = VALUES(ra_rat_id),
  ra_description = VALUES(ra_description), ra_res_id = VALUES(ra_res_id),
  ra_ruleset_var_id = VALUES(ra_ruleset_var_id);

-- ------------------------------------------------------------
-- 3. Purge des rattachements actuels des espèces DD2024
--    (dd_race_capacite n'a pas de clé unique : le DELETE est la seule
--     protection contre les doublons, ne pas exécuter l'INSERT seul)
-- ------------------------------------------------------------

DELETE FROM dd_race_capacite WHERE cr_ra_id IN (18,15,16,19,14,12,13,20,21);

-- ------------------------------------------------------------
-- 4. Traits spéciaux — ids figés à partir de 901
-- ------------------------------------------------------------

INSERT INTO dd_capacites_speciales
  (cap_id, cap_nom, cap_description, cap_type, cap_classe_initiale)
VALUES
  (901, 'Ascendance draconique', '<p>Votre lignée remonte à un géniteur dragon. Choisissez le type de dragon dans la table « Ancêtres draconiques ». Ce choix affecte vos traits Souffle et Résistance aux dégâts, ainsi que votre apparence.</p><p>[[tab:ancetres-draconiques]]</p>', '', NULL),
  (902, 'Résistance aux dégâts', '<p>Vous bénéficiez de la résistance au type de dégâts déterminé par votre trait Ascendance draconique.</p>', '', NULL),
  (903, 'Souffle', '<p>Lorsque vous entreprenez l’action Attaque à votre tour, vous pouvez remplacer l’une de vos attaques par une expiration d’énergie magique sous la forme d’un Cône de 4,50 m ou d’une Ligne de 9 m de long et 1,50 m de large (choisissez la forme à chaque fois). Chaque créature prise dans la zone effectue un jet de sauvegarde de Dextérité (DD 8 + votre modificateur de Constitution + votre bonus de maîtrise). En cas d’échec, la créature subit 1d10 dégâts du type déterminé par votre trait Ascendance draconique. En cas de réussite, elle ne subit que la moitié de ces dégâts. Les dégâts augmentent de 1d10 lorsque vous atteignez les niveaux de personnage 5 (2d10), 11 (3d10) et 17 (4d10).</p><p>Vous pouvez recourir à ce Souffle autant de fois que votre bonus de maîtrise, et récupérez ce quota en terminant un Repos long.</p>', '', NULL),
  (904, 'Vision dans le noir', '<p>Vous disposez de la Vision dans le noir sur 18 m.</p>', '', NULL),
  (905, 'Vol draconique', '<p>Lorsque vous atteignez le niveau de personnage 5, vous pouvez canaliser la magie draconique pour vous octroyer le vol de façon temporaire. Par une action Bonus, il vous pousse des ailes spectrales dans le dos qui persistent 10 minutes ou jusqu’à ce que vous rétractiez ces ailes (pas d’action requise) ou subissiez l’état Neutralisé. Pour toute la durée, vous disposez d’une Vitesse de vol égale à votre Vitesse. Ces ailes semblent être faites de la même énergie que votre souffle. Une fois ce trait utilisé, vous devez terminer un Repos long pour pouvoir y recourir de nouveau.</p>', '', NULL),
  (906, 'Ascendance féerique', '<p>Vous avez l’Avantage aux jets de sauvegarde visant à éviter l’état Charmé ou à y mettre un terme.</p>', '', NULL),
  (907, 'Lignage elfique', '<p>Vous appartenez à un lignage qui vous octroie des aptitudes surnaturelles. Choisissez-en un dans la table « Lignages elfiques ». Vous recevez le bénéfice du niveau 1 de ce lignage.</p><p>Lorsque vous atteignez les niveaux de personnage 3 et 5, vous apprenez un sort de niveau supérieur, comme indiqué sur la table. Ce sort est toujours considéré comme préparé pour vous. Vous pouvez le lancer une fois sans dépenser d’emplacement de sort et récupérez cette aptitude en terminant un Repos long. Vous pouvez également le lancer avec vos éventuels emplacements de sort de niveau adéquat.</p><p>[[tab:lignages-elfiques]]</p><p>L’Intelligence, la Sagesse ou le Charisme est votre caractéristique d’incantation pour les sorts que vous lancez avec ce trait (décidez de la caractéristique lors de la sélection du lignage).</p>', '', NULL),
  (908, 'Sens aiguisés', '<p>Vous bénéficiez de la maîtrise de la compétence Intuition, Perception ou Survie au choix.</p>', '', NULL),
  (909, 'Transe', '<p>Vous vous passez de sommeil et la magie ne peut pas vous endormir. Vous pouvez terminer un Repos long en 4 heures si vous les passez en transe méditative durant laquelle vous restez en éveil.</p>', '', NULL),
  (910, 'Vision dans le noir', '<p>Vous disposez de la Vision dans le noir sur 18 m.</p>', '', NULL),
  (911, 'Lignage gnome', '<p>Vous appartenez à un lignage qui vous octroie des aptitudes surnaturelles. Choisissez l’une des options ci-après ; quelle que soit celle que vous choisissez, l’Intelligence, la Sagesse ou le Charisme est votre caractéristique d’incantation pour les sorts que vous lancez avec ce trait (décidez de la caractéristique lors de la sélection du lignage) :</p><p><b>Gnome des forêts.</b> Vous connaissez le sort mineur illusion mineure. Le sort communication avec les animaux est en outre considéré pour vous comme toujours préparé. Vous pouvez le lancer sans emplacement de sort autant de fois que votre bonus de maîtrise, et récupérez ce quota en terminant un Repos long. Vous pouvez en outre dépenser les emplacements de sort adaptés dont vous disposez pour lancer ce sort.</p><p><b>Gnome des roches.</b> Vous connaissez les sorts mineurs prestidigitation et réparation. Vous pouvez en outre consacrer 10 minutes à lancer prestidigitation pour créer un appareil mécanique de taille TP (CA 5, 1 pv) tel qu’un jouet, un allume-feu ou une boîte à musique. Lorsque vous créez l’appareil, vous déterminez sa fonction en choisissant un effet parmi ceux de prestidigitation ; l’appareil produit cet effet chaque fois que vous-même ou une autre créature entreprenez une action Bonus pour l’activer par simple contact. Lorsque l’effet choisi comporte des options, vous devez en choisir une pour l’appareil à sa création. Si vous choisissez l’effet « allumage-extinction » du sort, par exemple, vous devez déterminer si l’appareil allume ou éteint le feu ; il ne peut pas faire les deux. Vous pouvez avoir trois appareils actifs de ce type à la fois, et chacun tombe en morceaux 8 heures après sa création ou lorsque vous le démantelez par simple contact en entreprenant l’action Utilisation.</p>', '', NULL),
  (912, 'Ruse gnome', '<p>Vous avez l’Avantage aux jets de sauvegarde d’Intelligence, de Sagesse et de Charisme.</p>', '', NULL),
  (913, 'Vision dans le noir', '<p>Vous disposez de la Vision dans le noir sur 18 m.</p>', '', NULL),
  (914, 'Ascendance gigante', '<p>Vous êtes un lointain descendant des géants. Choisissez l’un des bénéfices ci-après, une faveur surnaturelle liée à vos ancêtres ; vous pouvez recourir à ce bénéfice autant de fois que votre bonus de maîtrise et récupérez ce quota en terminant un Repos long :</p><p><b>Brûlure ignée (géants du feu).</b> Lorsque vous touchez une cible avec un jet d’attaque et lui infligez des dégâts, vous pouvez infliger 1d10 dégâts de feu supplémentaires à cette cible.</p><p><b>Endurance de la pierre (géants des pierres).</b> Lorsque vous subissez des dégâts, vous pouvez jouer votre Réaction pour lancer 1d12. Ajoutez votre modificateur de Constitution au résultat du dé et réduisez les dégâts de la somme obtenue.</p><p><b>Froid mordant (géants du givre).</b> Lorsque vous touchez une cible avec un jet d’attaque et lui infligez des dégâts, vous pouvez infliger 1d6 dégâts de froid supplémentaires à cette cible et réduire sa vitesse de 3 m jusqu’au début de votre tour suivant.</p><p><b>Renversement des coteaux (géants des collines).</b> Lorsque vous touchez une créature de taille G ou inférieure avec un jet d’attaque et lui infligez des dégâts, vous pouvez faire subir à cette cible l’état À terre.</p><p><b>Saut des nuées (géants des nuages).</b> Par une action Bonus, vous pouvez vous téléporter magiquement d’un maximum de 9 m dans un espace inoccupé que vous voyez.</p><p><b>Tonnerre des cieux (géants des tempêtes).</b> Lorsque vous subissez des dégâts de la part d’une créature dans un rayon de 18 m, vous pouvez jouer votre Réaction pour lui infliger 1d8 dégâts de tonnerre.</p>', '', NULL),
  (915, 'Forme de géant', '<p>À partir du niveau de personnage 5, vous pouvez changer de catégorie de taille et devenir de taille G par une action Bonus, à condition que l’espace que vous occupez soit suffisamment vaste. Cette transformation dure 10 minutes ou jusqu’à ce que vous y mettiez un terme (pas d’action requise). Pour toute la durée, vous avez l’Avantage aux tests de Force et votre Vitesse augmente de 3 m. Une fois ce trait utilisé, vous devez terminer un Repos long pour pouvoir y recourir de nouveau.</p>', '', NULL),
  (916, 'Forte carrure', '<p>Vous avez l’Avantage à tous les tests de caractéristique que vous effectuez pour mettre un terme à l’état Agrippé. Votre catégorie de taille est en outre considérée comme du cran immédiatement supérieur pour ce qui est de définir votre capacité de charge.</p>', '', NULL),
  (917, 'Agilité halfeline', '<p>Vous pouvez vous déplacer dans l’espace de toute créature d’une catégorie de taille supérieure à la vôtre, mais ne pouvez pas vous arrêter dans le même espace que celle-ci.</p>', '', NULL),
  (918, 'Brave', '<p>Vous avez l’Avantage aux jets de sauvegarde visant à éviter l’état Effrayé ou à y mettre un terme.</p>', '', NULL),
  (919, 'Chance', '<p>Lorsque vous obtenez un 1 au d20 d’un Test d20, vous pouvez relancer le dé, mais devez utiliser le nouveau résultat.</p>', '', NULL),
  (920, 'Discrétion naturelle', '<p>Il vous suffit d’être dans l’ombre d’une créature dont la catégorie de taille est d’au moins un cran supérieure à la vôtre pour pouvoir entreprendre l’action Furtivité.</p>', '', NULL),
  (921, 'Compétent', '<p>Vous recevez la maîtrise d’une compétence de votre choix.</p>', '', NULL),
  (922, 'Ingénieux', '<p>Vous recevez l’Inspiration héroïque chaque fois que vous terminez un Repos long.</p>', '', NULL),
  (923, 'Polyvalent', '<p>Vous recevez le don d’origines de votre choix (cf. « Dons »). Doué est recommandé.</p>', '', NULL),
  (924, 'Connaissance de la pierre', '<p>Par une action Bonus, vous recevez la Perception des vibrations à 18 m pendant 10 minutes. Cette Perception des vibrations nécessite que vous soyez sur une surface en pierre ou en contact physique avec une telle surface. Cette pierre peut être naturelle ou façonnée.</p><p>Vous pouvez recourir à cette action Bonus autant de fois que votre bonus de maîtrise, et récupérez ce quota en terminant un Repos long.</p>', '', NULL),
  (925, 'Résistance naine', '<p>Vous bénéficiez de la Résistance aux dégâts de poison. Vous avez en outre l’Avantage aux jets de sauvegarde visant à éviter l’état Empoisonné ou à y mettre un terme sur vous-même.</p>', '', NULL),
  (926, 'Ténacité naine', '<p>Votre maximum de points de vie augmente de 1, et augmente encore de 1 chaque fois que vous gagnez un niveau.</p>', '', NULL),
  (927, 'Vision dans le noir', '<p>Vous disposez de la Vision dans le noir sur 36 m.</p>', '', NULL),
  (928, 'Acharnement', '<p>Si vous tombez à 0 point de vie sans être tué sur le coup, vous pouvez en fait vous retrouver à 1 point de vie. Une fois ce trait utilisé, vous devez terminer un Repos long pour pouvoir y recourir de nouveau.</p>', '', NULL),
  (929, 'Poussée d’adrénaline', '<p>Vous pouvez entreprendre l’action Pointe par une action Bonus. Quand vous faites ainsi, vous recevez un nombre de points de vie temporaires égal à votre bonus de maîtrise.</p><p>Vous pouvez recourir à ce trait autant de fois que votre bonus de maîtrise, et récupérez ce quota en terminant un Repos court ou long.</p>', '', NULL),
  (930, 'Vision dans le noir', '<p>Vous disposez de la Vision dans le noir sur 36 m.</p>', '', NULL),
  (931, 'Héritage fiélon', '<p>Votre héritage vous octroie des aptitudes surnaturelles. Choisissez un héritage dans la table Héritages fiélons. Vous recevez le bénéfice de niveau 1 de l’héritage choisi.</p><p>Lorsque vous atteignez les niveaux de personnage 3 et 5, vous apprenez un sort de niveau supérieur, comme indiqué sur la table. Ce sort est toujours considéré comme préparé pour vous. Vous pouvez le lancer une fois sans dépenser d’emplacement de sort et récupérez cette aptitude en terminant un Repos long. Vous pouvez également le lancer avec vos éventuels emplacements de sort de niveau adéquat.</p><p>[[tab:heritages-fielons]]</p><p>L’Intelligence, la Sagesse ou le Charisme est votre caractéristique d’incantation pour les sorts que vous lancez avec ce trait (décidez de la caractéristique lors de la sélection de l’héritage).</p>', '', NULL),
  (932, 'Présence d’outre-monde', '<p>Vous connaissez le sort mineur thaumaturgie. Lorsque vous le lancez avec ce trait, le sort utilise la même caractéristique d’incantation que celle du trait Héritage fiélon.</p>', '', NULL),
  (933, 'Vision dans le noir', '<p>Vous disposez de la Vision dans le noir sur 18 m.</p>', '', NULL)
ON DUPLICATE KEY UPDATE
  cap_nom = VALUES(cap_nom), cap_description = VALUES(cap_description),
  cap_type = VALUES(cap_type), cap_classe_initiale = VALUES(cap_classe_initiale);

-- ------------------------------------------------------------
-- 5. Rattachement des traits aux espèces
-- ------------------------------------------------------------

INSERT INTO dd_race_capacite (cr_ra_id, cr_cap_id, cr_ordre)
VALUES
  (18, 901, 0),
  (18, 902, 1),
  (18, 903, 2),
  (18, 904, 3),
  (18, 905, 4),
  (15, 906, 0),
  (15, 907, 1),
  (15, 908, 2),
  (15, 909, 3),
  (15, 910, 4),
  (16, 911, 0),
  (16, 912, 1),
  (16, 913, 2),
  (19, 914, 0),
  (19, 915, 1),
  (19, 916, 2),
  (14, 917, 0),
  (14, 918, 1),
  (14, 919, 2),
  (14, 920, 3),
  (12, 921, 0),
  (12, 922, 1),
  (12, 923, 2),
  (13, 924, 0),
  (13, 925, 1),
  (13, 926, 2),
  (13, 927, 3),
  (20, 928, 0),
  (20, 929, 1),
  (20, 930, 2),
  (21, 931, 0),
  (21, 932, 1),
  (21, 933, 2);

-- ------------------------------------------------------------
-- 6. Retrait des traits DD2024 devenus orphelins
-- ------------------------------------------------------------

DELETE FROM dd_capacites_speciales
WHERE  cap_id IN (424,425,426,427,428,429,430,431,432,433,434,435,436,437,438)
  AND  cap_id NOT IN (SELECT cr_cap_id FROM dd_race_capacite)
  AND  cap_id NOT IN (SELECT cc_cap_id FROM dd_classe_capacite);
