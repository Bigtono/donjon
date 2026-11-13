-- sql/2026-11-09_sp-jf2_dons_mdjf.sql
-- SP-JF2 — Dons du Manuel des Joueurs de Faerûn : import des absents, réécriture des fiches MdJF existantes,
-- rattachement des réimpressions au MdJF (mention de l'ancien supplément en fin de description).
-- Généré par tools/generer-sp-jf2-dons.php le 2026-11-09 depuis gemmaline.com. Rejouable. Pas de DELIMITER.

SET NAMES utf8mb4;

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_visible, tab_date_creation, tab_date_modif)
SELECT 'don-elu-des-sept-soeurs', 'Élu des sept sœurs : Sorts d''initié', '! Niveau | Sort
1 | Rayon d’espoir
1 | Vision des cieux
2 | Annulation de douleur
3 | Vision bénie
4 | Épée de conscience
5 | Couronne de flamme
5 | Gardien sacré
7 | Châtiment vertueux', 'll', 3, 1, 63, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM dd_tableaux WHERE tab_slug = 'don-elu-des-sept-soeurs' AND tab_ruleset_var_id = 1);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_visible, tab_date_creation, tab_date_modif)
SELECT 'don-initie-d-ilmater', 'Initié d’Ilmater : Sorts d''initié', '! Niveau | Sort
4 | Faveur d’Ilmater
4 | Gloire du martyr
4 | Pacte du martyr', 'll', 3, 1, 63, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM dd_tableaux WHERE tab_slug = 'don-initie-d-ilmater' AND tab_ruleset_var_id = 1);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_visible, tab_date_creation, tab_date_modif)
SELECT 'don-initie-de-baine', 'Initié de Baine : Sorts d''initié', '! Niveau | Sort
3 | Fouet mystique
5 | Marée guerrière
6 | Marche des pierres
7 | Non-vie après la mort', 'll', 3, 1, 63, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM dd_tableaux WHERE tab_slug = 'don-initie-de-baine' AND tab_ruleset_var_id = 1);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_visible, tab_date_creation, tab_date_modif)
SELECT 'don-initie-de-cyric', 'Initié de Cyric : Sorts d''initié', '! Niveau | Sort
2 | Griffe noire
4 | Crâne des secrets
4 | Explosion de terreur
5 | Orbite de crâne
7 | Triple masque', 'll', 3, 1, 63, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM dd_tableaux WHERE tab_slug = 'don-initie-de-cyric' AND tab_ruleset_var_id = 1);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_visible, tab_date_creation, tab_date_modif)
SELECT 'don-initie-de-gond', 'Initié de Gond : Sorts d''initié', '! Niveau | Sort
1 | Compétence divine
3 | Compréhension d’objet
6 | Machine fantastique', 'll', 3, 1, 63, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM dd_tableaux WHERE tab_slug = 'don-initie-de-gond' AND tab_ruleset_var_id = 1);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_visible, tab_date_creation, tab_date_modif)
SELECT 'don-initie-de-heaum', 'Initié de Heaum : Sorts d''initié', '! Niveau | Sort
2 | Sens aux aguets
3 | Masse d’Odo
3 | Parade d’énergie', 'll', 3, 1, 63, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM dd_tableaux WHERE tab_slug = 'don-initie-de-heaum' AND tab_ruleset_var_id = 1);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_visible, tab_date_creation, tab_date_modif)
SELECT 'don-initie-de-la-nature', 'Initié de la Nature : Sorts d''initié', '! Niveau | Sort
3 | Contact de la moisissure
4 | Enchevêtrement épineux
4 | Projection d’épines
5 | Arbre guérisseur
5 | Protection contre le feu', 'll', 3, 1, 63, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM dd_tableaux WHERE tab_slug = 'don-initie-de-la-nature' AND tab_ruleset_var_id = 1);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_visible, tab_date_creation, tab_date_modif)
SELECT 'don-initie-de-lathandre', 'Initié de Lathandre : Sorts d''initié', '! Niveau | Sort
1 | Rose manteau
3 | Lever de soleil
5 | Bouclier de Lathandre
7 | Bouclier suprême de Lathandre', 'll', 3, 1, 63, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM dd_tableaux WHERE tab_slug = 'don-initie-de-lathandre' AND tab_ruleset_var_id = 1);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_visible, tab_date_creation, tab_date_modif)
SELECT 'don-initie-de-loviatar', 'Initié de Loviatar : Sorts d''initié', '! Niveau | Sort
2 | Doux rappel de Nybor
4 | Fouet mystique
5 | Brise-chair', 'll', 3, 1, 63, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM dd_tableaux WHERE tab_slug = 'don-initie-de-loviatar' AND tab_ruleset_var_id = 1);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_visible, tab_date_creation, tab_date_modif)
SELECT 'don-initie-de-malar', 'Initié de Malar : Sorts d''initié', '! Niveau | Sort
2 | Cerf spectral
3 | Possession animale
4 | Force de la bête', 'll', 3, 1, 63, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM dd_tableaux WHERE tab_slug = 'don-initie-de-malar' AND tab_ruleset_var_id = 1);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_visible, tab_date_creation, tab_date_modif)
SELECT 'don-initie-de-mystra', 'Initié de Mystra : Sorts d''initié', '! Niveau | Sort
2 | Bouclier magique
3 | Sort universel
5 | Phylactère magique
6 | Manteau magique
6 | Sort universel amélioré
7 | Étoile bénie', 'll', 3, 1, 63, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM dd_tableaux WHERE tab_slug = 'don-initie-de-mystra' AND tab_ruleset_var_id = 1);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_visible, tab_date_creation, tab_date_modif)
SELECT 'don-initie-de-selune', 'Initié de Séluné : Sorts d''initié', '! Niveau | Sort
1 | Main de feu
3 | Sabre de lune
4 | Force de la bête
4 | Mur de clair de lune
5 | Toile de lune
5 | Voie lunaire', 'll', 3, 1, 63, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM dd_tableaux WHERE tab_slug = 'don-initie-de-selune' AND tab_ruleset_var_id = 1);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_visible, tab_date_creation, tab_date_modif)
SELECT 'don-initie-de-tyr', 'Initié de Tyr : Sorts d''initié', '! Niveau | Sort
4 | Épée et marteau
6 | Épée et marteau suprêmes', 'll', 3, 1, 63, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM dd_tableaux WHERE tab_slug = 'don-initie-de-tyr' AND tab_ruleset_var_id = 1);

UPDATE dd_dons SET do_texte = '<p><strong>Condition.</strong> Drow</p>
<p><strong>Avantage.</strong> Contrairement aux autres membres de sa race, le personnage n''est plus ébloui ou aveuglé lorsqu''il est exposé à une lumière vive ou au soleil. Les effets affectant toutes les créatures sans distinction de races, comme rayon du soleil ou explosion de lumière, l''affectent normalement.</p>', do_resume = 'Le personnage s''est habitué à la douloureuse lumière du soleil du monde de la surface.' WHERE do_id = 316 AND do_res_id = 63;

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Arboricole', 10, '<p><strong>Condition.</strong> Demi-elfe de lune[Aglarond], Demi-elfe de lune [Haute forêt], Demi-elfe des bois [Haute forêt], Elfe des bois [Bois de Yuir], Elfe des bois [Haute forêt], Elfe des étoiles [Bois de Yuir], Elfe sauvage [Bois de Chontal], Halfelin sagespectre [Bois de Chontal], Humain [Aglarond], Minuitlin [Arvandor]</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d’un bonus de +2 aux tests d’Équilibre et Escalade. Quand il grimpe, il ne perd pas son bonus de Dextérité à la CA et ses adversaires ne bénéficient pas d’un bonus de +2 à l’attaque.</p>
<p><strong>Normal.</strong> Un personnage qui escalade perd son bonus de Dextérité à la CA et ses adversaires bénéficient contre lui d’un bonus de +2 à l’attaque.</p>', 'Le personnage se sent comme chez lui dans les arbres et autres endroits élevés, se permettant des mouvements qui paralyseraient autrui de terreur.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Arboricole' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Artisanat magique', 3, '<p><strong>Condition.</strong> Un don de Création d’objets au choix</p>
<p><strong>Avantage.</strong> Chaque fois que vous choisissez ce don, sélectionnez l’un des dons de création d’objets de votre personnage. Au moment de déterminer le coût en PX et en matériaux pour créer un objet à l’aide de ce don, multipliez le prix de base par 0,75.</p>
<p><strong>Spécial.</strong> Ce don peut être choisi plusieurs fois. Chaque fois que vous le prenez, il s’applique à un nouveau don de création d’objets.</p>', 'Le personnage maîtrise le processus de fabrication d’un certain type d’objets magiques.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Artisanat magique' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Artiste', 10, '<p><strong>Condition.</strong> Avariel[Aire des aigles des neiges], Demi-Drow [Les Vaux], Demi-elfe de lune [Les Vaux], Elfe des étoiles [Sildëyuir], Gnome des roches [Contrées du Mitan Occidentale], Gnome des roches [Thesk], Humain [Chessenta], Humain [Contrées du Mitan Occidentale], Humain [Eauprofonde], Humain [Sélune]</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d’un bonus de +2 aux tests de Représentation et aux tests d’une compétence d’Artisanat impliquant un art (au choix), comme la calligraphie, la peinture, la sculpture ou le tissage. De plus, si le personnage possède le pouvoir de musique bardique, il peut y avoir recours trois fois de plus quotidiennement. Par exemple, un barde de niveau 3 pourvu de ce don peut utiliser son pouvoir de musique bardique 6 fois par jour.</p>
<p><strong>Normal.</strong> Un barde peut utiliser son pouvoir de musique bardique 1 fois par jour et par niveau de barde.</p>', 'Le personnage est issu d’une culture au sein de laquelle le conte et le chant occupent une place importante.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Artiste' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Beau parleur', 10, '<p><strong>Condition.</strong> Crépusculin[Sphur Upra], Demi-elfe de lune [Eauprofonde], Elfe de lune [Eauprofonde], Gnome des roches [Thesk], Humain [Eauprofonde], Humain [Lunargent], Humain [Thesk]</p>
<p><strong>Avantage.</strong> Le personnage ne subit qu’un malus de -5 s’il tente un test de Diplomatie au prix d’une action complexe.</p>
<p><strong>Normal.</strong> On a habituellement besoin de 1 minute pour effectuer un test de Diplomatie. Un personnage peut tenter un test de Diplomatie au prix d’une action complexe, mais il subit alors un malus de -10.</p>', 'Le personnage s’en remet rarement à son épée pour traiter avec des adversaires potentiels car son éloquence lui permet de venir à bout de la plupart des problèmes.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Beau parleur' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Bénédiction de Llira', 5, '<p><strong>Conditions.</strong> Degré de maîtrise de 1 en Évasion, Auréole de lumière</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d''un bonus de sainteté de +2 aux tests d''Évasion et aux jets de sauvegarde contre les effets qui paralysent, immobilisent ou enchevêtrent. Si le personnage rate son jet de sauvegarde, il peut en jouer un autre 1 round plus tard. S''il le réussit, il est tout simplement affecté comme s''il avait remporté le premier.</p>', 'Grâce aux faveurs que lui accorde la déesse de la liberté, le personnage offre une grande résistance aux tentatives de coercition physiques le visant.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Bénédiction de Llira' AND do_res_id = 63 AND do_ruleset_var_id = 1);

UPDATE dd_dons SET do_texte = '<p><strong>Condition.</strong> Aasimar[Unther], Boogin [Outreterre (Nord-Terre)], Centaure [Plateau de Thay], Chaond [Marches d''Argent], Demi-orque [Amn], Genasi de feu [Unther], Gnoll [Plateau de Thay], Halfelin d''Anadia [Polarat du Sud], Humain [Bief de Vilhon], Humain [Cités libres de Parsanic], Humain [Cote des dragons], Humain [Iles Nélanthères], Humain [Mer de Lune], Humain [Swagdar], Humain [Unther], Humain [Vaste], Métissoïde [Île du Faucon], Nain d''écu [Eauprofonde], Nain gris [Outreterre (Nord-Terre)], Orogue [Outreterre (Nord-Terre)], Orogue [Thesk], Orque des montagnes [Outreterre (Nord-Terre)], Orque des montagnes [Thesk], Orque gris [Thesk], Tanarukk [Outreterre (Nord-Terre)], Tieffelin [Contrées du Mitan Occidentale], Tieffelin [Impiltur], Tieffelin [Marches d''Argent], Tieffelin [Unther], Torve [Outreterre (Reeshov)]</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d’un bonus de +2 aux tests d’initiative.</p>
<p>De plus, le personnage obtient un bonus de +2 sur tous ses tests de Estimation et Intimidation.</p>', do_resume = 'Le personnage sait comment aborder une compétition et mener autrui par le bout du nez. Quand les autres discutent, il passe à l’action.' WHERE do_id = 337 AND do_res_id = 63;

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Cavalier émérite', 10, '<p><strong>Condition.</strong> Humain[Contrées du Mitan Occidentale], Humain [Cormyr], Humain [Dambrath], Humain [Narfell], Humain [Nimbrall], Humain [Nord], Humain [Terres de la Horde]</p>
<p><strong>Avantage.</strong> Le personnage peut faire 10 aux tests d’Équitation, même s’il est pressé ou menacé.</p>
<p>Si le cavalier ou sa monture rate un jet de Réflexes; le personnage a droit à un test d’Équitation pour réussir son jet de sauvegarde. Le jet de sauvegarde, est couronné de succès si le résultat du test d’Équitation est supérieur ou égal au DD de sauvegarde du sort. (Le personnage peut donc remplacer le résultat de son jet de Réflexes par celui de son test d’Équitation.) On peut procéder à cette substitution 1 fois par round pour le cavalier ou pour la monture, au choix. Si les deux intéressés ratent leur jet de Réflexes contre un même effet (par exemple, une boule de feu ou un souffle de dragon rouge), le résultat du test d’Équitation s’applique aux deux jets de sauvegarde.</p>', 'Le personnage a passé des heures et des heures à apprendre à tenir sa monture au combat.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Cavalier émérite' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Chance des héros', 10, '<p><strong>Condition.</strong> Bricolin[Contrées du Mitan Occidentale], Crépusculin [Sphur Upra], Demi-elfe de lune [Aglarond], Elfe de lune [Cour elfique], Elfe des bois [Bois de Yuir], Elfe des bois [Cour elfique], Elfe des bois [Forêt de Léthyr], Elfe des étoiles [Bois de Yuir], Elfe sauvage [Cour elfique], Halfelin pied-léger [Contrées du Mitan Occidentale], Halfelin sagespectre [Vallée de Channath], Halfelin vaillant [Contrées du Mitan Occidentale], Halfelin vaillant [Vallée de Channath], Humain [Aglarond], Humain [Les Vaux], Humain [Téthyr], Humain [Turmish], Humain [Vaste], Minuitlin [Arvandor]</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d’un bonus de chance de +1 aux jets de sauvegarde et à la CA.</p>', 'La contrée natale du personnage a pour habitude de mettre au monde des héros. Grâce à son courage, à sa détermination et à sa résistance, il s’en sort là où nul ne saurait survivre.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Chance des héros' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Charge furieuse', 10, '<p><strong>Condition.</strong> Aarakocra[Cornes des Tempêtes], Centaure [Haute forêt], Demi-orque [Chessenta], Humain [Chevauché], Humain [Cormyr], Humain [Téthyr], Humain [Tribus d’Uthgardt], Loxo [Shaar], Orque des montagnes [Chessenta], Wemic [Shaar]</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d’un bonus de +4 au jet d’attaque effectué au terme d’une charge.</p>', 'Le peuple du personnage est connu pour son amour de la guerre et perd rarement son temps dans d’interminables corps à corps. En effet, rien de mieux qu’une charge dévastatrice pour se défaire de ses adversaires.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Charge furieuse' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Cœur de forge', 10, '<p><strong>Condition.</strong> Genasi de feu[Cité de Cuivre], Humain [Iles Nélanthères], Méphilin du feu [Cité de Cuivre], Nain d''écu [Cote des épées], Nain d''or [Montagnes Fumantes]</p>
<p><strong>Avantage.</strong> Le personnage gagne une résistance au feu (5).</p>', 'Habitué aux chaleurs infernales de sa terre natale, le personnage affiche une résistance naturelle au feu.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Cœur de forge' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Cœur de tempêtes', 10, '<p><strong>Condition.</strong> Humain[Altumbel], Humain [Cités libres de Parsanic], Humain [Cote des dragons], Humain [Cote des épées], Humain [Konigheim], Humain [Lac de Vapeur], Humain [Lapaliiya], Humain [Tharsult]</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d’un bonus de +2 aux tests d’Équilibre et Profession (marin). Il ne tient pas compte des malus découlant de déplacements contrariés quand il se bat ou évolue sur un pont glissant. Enfin, il bénéficie d’un bonus d’esquive de +1 à la CA quand il combat sur un navire.</p>
<p><strong>Normal.</strong> Un personnage qui progresse sur une surface traître ou difficile compte chaque case de mouvement comme deux cases de déplacement.</p>', 'Le personnage a l’océan dans le sang. Il est habitué aux traques en mer et aux abordages.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Cœur de tempêtes' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Connaissance des sorts', 10, '<p><strong>Condition.</strong> Céladarin[Eternelle-Rencontre], Elfe de lune [Eternelle-Rencontre], Elfe des bois [Eternelle-Rencontre], Elfe du soleil [Eternelle-Rencontre], Humain [Bief des magiciens], Humain [Calimshan], Humain [Halruaa], Humain [Nimbrall], Humain [Sélune], Humain [Shadovar], Reflet [Shadovar], Zénythri [Calimshan]</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d’un bonus de +2 aux tests d’Art de la magie et Connaissance (mystères). Il bénéficie également d’un bonus de +2 aux jets de sauvegarde contre les illusions.</p>', 'Le personnage a été élevé dans un pays où les magiciens sont monnaie courante. Tous ses compatriotes ont des connaissances magiques et il appris qu’il faut parfois voir au-delà des apparences.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Connaissance des sorts' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Contact de haine', 5, '<p><strong>Conditions.</strong> Sort souillé, Faculté de lancer des sorts divins de 5e niveau, Baine en qualité de divinité tutélaire</p>
<p><strong>Avantage.</strong> Une fois tous les dix jours, le personnage peut toucher un animal et le transformer en bête de Baine (comparable à la bête de Xvim). Les dés de vie de l''animal (avant la transformation) ne sauraient être supérieurs aux niveaux de prêtre du personnage. La créature visée a droit à un jet de Volonté (DD 10 + 1/2 niveau de prêtre + modificateur de Sagesse). Si l''animal est le compagnon d''un autre personnage, il peut exploiter le bonus de base aux jets de Volonté de celui-ci à la place du sien, en appliquant néanmoins son propre modificateur de caractéristique. En cas d''échec, l''animal se transforme en bête de Baine sur-le-champ et obéit aux ordres du personnage.</p>
<p>La bête de Baine créée inflige des dégâts maléfiques à l''aide de son pouvoir de châtiment du Bien. On ne peut soigner de dégâts maléfiques qu''en usant de magie jetée dans la zone d''un sort de consécration ou sanctification.</p>', 'Comptant parmi les élus de Baine, le personnage est capable de transformer les animaux en mignons maléfiques.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Contact de haine' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Contresort épique', 8, '<p><strong>Conditions.</strong> Degré de maîtrise de 30 en Art de la magie, Attaques réflexes, Contresort réactif, Incantation rapide, Science du contresort, Science de l’initiative</p>
<p><strong>Avantage.</strong> Le personnage peut contrer autant de fois par round qu''il le souhaite le sort d''un adversaire, même s''il n''a pas préparé d''action en ce sens. Ce contresort ne compte pas dans le total d''actions auxquelles il a droit chaque round. Le personnage peut même utiliser ce don s''il est pris au dépourvu.</p>
<p><strong>Normal.</strong> Sans ce don, le personnage doit préparer une action à chaque round s''il souhaite user de contresort. Un personnage pourvu du don Contresort réactif peut contrer le sort d''un adversaire s''il n''a pas préparé d''action, mais une fois par tour de jeu et seulement s''il n''est pas pris au dépourvu,</p>', 'Le personnage peut contrer un nombre de sorts illimité par round.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Contresort épique' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Contresort réactif', 1, '<p><strong>Conditions.</strong> Science de l’initiative, Science du contresort</p>
<p><strong>Avantage.</strong> Une fois par round, le personnage peut contrer le sort d’un adversaire, même s’il n’a pas préparé d’action dans ce sens. Cette action de contresort remplace le tour de jeu suivant du personnage. Enfin, il est impossible d’avoir recours à ce don quand on est pris au dépourvu.</p>
<p><strong>Normal.</strong> Sans ce don, il faut préparer une action à chaque round où l’on souhaite user d’un contresort.</p>', 'Le personnage contre rapidement les sorts de ses adversaires.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Contresort réactif' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Cosmopolite', 10, '<p><strong>Condition.</strong> Demi-elfe de lune[Eauprofonde], Elfe de lune [Eauprofonde], Genasi d''eau [Cité de Verre], Genasi de feu [Cité de Cuivre], Genasi de terre [Grand Fouissement Funeste], Halfelin pied-léger [Amn], Humain [Amn], Humain [Cote des épées], Humain [Eauprofonde], Humain [Eaux dorées], Humain [Gemmaline], Kenku [Eaux dorées], Méphilin du feu [Cité de Cuivre], Nain d''écu [Eauprofonde]</p>
<p><strong>Avantage.</strong> Le personnage obtient un bonus de +2 sur tous ses tests de Bluff , Psychologie et Renseignement.</p>', 'On a menti à votre personnage un nombre de fois incalculable. Cela l’a néanmoins familiarisé aux techniques de duperie, de supercherie et de double langage des citadins.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Cosmopolite' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Coup axiomatique', 5, '<p><strong>Conditions.</strong> Alignement loyal, Aptitude de classe de Châtiment de l’anarchie</p>
<p><strong>Avantage.</strong> L''arme du personnage est considérée comme une arme axiomatique (loyale, +2d6 points de dégâts contre les créatures chaotiques). Si l''arme est déjà pourvue de cet alignement, ce don n''a aucun effet.</p>', 'Les attaques du personnage infligent des dégâts considérables aux créatures'' chaotiques.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Coup axiomatique' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Courageux', 10, '<p><strong>Condition.</strong> Aarakocra[Cornes des Tempêtes], Avariel [Aire des aigles des neiges], Bricolin [Contrées du Mitan Occidentale], Bricolin [Lantan], Crépusculin [Sphur Upra], Demi-orque [Terres de la Horde], Elfe de lune [Cour elfique], Elfe des bois [Cour elfique], Elfe sauvage [Cour elfique], Gnome des roches [Lantan], Halfelin pied-léger [Contrées du Mitan Occidentale], Halfelin sagespectre [Vallée de Channath], Halfelin vaillant [Contrées du Mitan Occidentale], Halfelin vaillant [Vallée de Channath], Humain [Impiltur], Orque gris [Terres de la Horde], Thri-Kreen [Shaar]</p>
<p><strong>Avantage.</strong> Le personnage est immunisé contre les effets de terreur, magiques ou non.</p>', 'Le personnage ne connaît pas la peur et rien ne saurait ébranler son courage.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Courageux' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Courroux terrifiant', 10, '<p><strong>Condition.</strong> Chaond[Marches d''Argent], Genasi d''air [Thay], Genasi d''eau [Thay], Genasi de feu [Thay], Genasi de terre [Thay], Gulgar [Montagne du Levant], Humain [Rashéménie], Kir-lanan [Collines Lointaines], Kuo-Toa [Outreterre (Sloopdilmonpolop)], Loxo [Shaar], Tieffelin [Contrées du Mitan Occidentale], Tieffelin [Impiltur], Tieffelin [Marches d''Argent], Tieffelin [Thay]</p>
<p><strong>Avantage.</strong> Quand le personnage charge, effectue une attaque à outrance ou lance un sort qui vise des cibles ou dont la zone inclut un ennemi, il jouit du pouvoir de présence terrifiante pour le round. Les ennemis situés dans un rayon de 6 mètres doivent réussir un jet de Volonté (DD 10 + 1/2 niveau global + modificateur de Cha) sous peine d’être secoués pendant 1 minute. Que leur jet de sauvegarde soit couronné de succès ou non, les créatures exposées à l’effet sont ensuite immunisées contre la présence terrifiante du personnage pendant 24 heures. Il s’agit d’un effet de moral extraordinaire.</p>', 'Au combat, le personnage a l’air terrifiant et bien peu de ses ennemis ont le cran de l’affronter.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Courroux terrifiant' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Débrouillard', 10, '<p><strong>Condition.</strong> Aasimar[Chessenta], Cactacée [Calimshan], Genasi d''eau [Chessenta], Halfelin pied-léger [Amn], Halfelin pied-léger [Calimshan], Halfelin vaillant [Calimshan], Humain [Amn], Humain [Bief des magiciens], Humain [Calimshan], Humain [Chessenta], Humain [Mer de Lune], Humain [Unther], Kenku [Calimshan], Tieffelin [Contrées du Mitan Occidentale], Zénythri [Calimshan]</p>
<p><strong>Avantage.</strong> Le personnage obtient un bonus de +2 sur tous ses tests de Intimidation , Psychologie et Renseignement.</p>', 'Le personnage sait comment s’informer, poser les bonnes questions et dialoguer avec la pègre sans’ éveiller de soupçons.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Débrouillard' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Détaché de ce monde', 10, '<p><strong>Condition.</strong> Céladarin[Eternelle-Rencontre], Elfe de lune [Eternelle-Rencontre], Elfe des bois [Eternelle-Rencontre], Elfe des étoiles [Sildëyuir], Elfe du soleil [Eternelle-Rencontre], Githzeraï [Repos du Guerrier], Homme-esprit des montagnes [Cendrane], Homme-esprit des rivières [Cendrane], Imaskari des profondeurs [Outreterre (Noire Imaskar)], Vasharan [Téthyr]</p>
<p><strong>Avantage.</strong> Le personnage est un Extérieur natif, pas un humanoïde. Il a la vision dans le noir sur 18 mètres. De plus, il bénéficie d’un bonus de +2 aux tests de Diplomatie.</p>', 'Les compatriotes du personnage sont connus pour leurs pouvoirs mystiques et semblent transcender leur forme mortelle. Le rayonnement interne du PJ est tel qu’il est plus qu’un simple mortel!', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Détaché de ce monde' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Dévotion épique', 8, '<p><strong>Conditions.</strong> Sag 21, Volonté de fer, Alignement ne présentant pas la composante choisie, Divinité tutélaire n’acceptant pas les prêtres présentant la composante choisie</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d''un bonus de +4 sur les jets de sauvegarde contre les sons appartenant au registre de l''alignement choisi.</p>
<p>Par exemple, un paladin loyal bon de Heaum qui choisit Dévotion épique (chaos) obtient un bonus contre les sorts du Chaos. Il ne peut choisir ni la loi, ni le bien car ils font partie de son alignement, ni le mal, car Heaum accepte les prêtres d''alignement mauvais.</p>
<p><strong>Spécial.</strong> Ce don peut être choisi plusieurs fois, en sélectionnant une autre composante remplissant les conditions.</p>', 'Lorsqu''un personnage acquiert ce don, il doit choisir une composante d''alignement (bien, chaos, loi, mal) différente des siennes. Il est alors particulièrement résistant aux sorts de ce registre d''alignement.', 60, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Dévotion épique' AND do_res_id = 60 AND do_ruleset_var_id = 1);

UPDATE dd_dons SET do_texte = '<p><strong>Condition.</strong> Aasimar[Mulhorande], Céladarin [Everska], Elfe de lune [Everska], Elfe des bois [Bois de Yuir], Elfe des étoiles [Bois de Yuir], Elfe du soleil [Everska], Genasi de terre [Mulhorande], Gnome des roches [Contrées du Mitan Occidentale], Gulgar [Outreterre (Griffe terre)], Halfelin d''Anadia [Polarat du Nord], Halfelin pied-léger [Luiren], Humain [Aglarond], Humain [Cormyr], Humain [Expatrié shou], Humain [Shadovar], Humain [Thay], Reflet [Shadovar], Slyth [OutreTerre (Fluvilnistra)], Thri-Kreen [Shaar], Tieffelin [Mulhorande], Zénythri [Mulhorande]</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d’un bonus de +2 aux jets de Volonté et aux tests de Concentration.</p>
<p><strong>Spécial.</strong> Ce don compte comme le don Volonté de fer pour ce qui est de satisfaire à des conditions ou prérequis et ne se cumule pas avec ce dernier.</p>', do_resume = 'Le peuple du personnage est admiré pour sa détermination et son indéfectible résolution. Il est difficile de le distraire par l’intermédiaire d’un sort ou d’un coup.' WHERE do_id = 346 AND do_res_id = 63;

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Don de discernement', 5, '<p><strong>Avantage.</strong> Si le personnage prend le temps (action libre) de songer à l''action qu''il est sur le point d''entreprendre, il sait si celle-ci aura des conséquences néfastes sur son alignement et la relation qu''il entretient avec son dieu. Les informations glanées sont les mêmes que celles qu''offre un phylactère du croyant.</p>', 'Le personnage peut compter sur sa conscience pour éviter de commettre un acte maléfique.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Don de discernement' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Éducation', 10, '<p><strong>Condition.</strong> Avariel[Aire des aigles des neiges], Bricolin [Lantan], Céladarin [Eternelle-Rencontre], Demi-elfe de lune [Lunargent], Elfe de lune [Eternelle-Rencontre], Elfe de lune [Lunargent], Elfe des bois [Eternelle-Rencontre], Elfe des bois [Lunargent], Elfe du soleil [Eternelle-Rencontre], Gnome des roches [Lantan], Humain [Chessenta], Humain [Eauprofonde], Humain [Gemmaline], Humain [Lantan], Humain [Lunargent]</p>
<p><strong>Avantage.</strong> Toutes les compétences de Connaissances sont pour le personnage des compétences de classe. Il a également la possibilité de choisir deux de ces compétences qu’il maîtrise particulièrement bien. Il bénéficie d’un bonus de +2 aux tests relevant de ces deux compétences. Si le personnage choisit une compétence qu’il ne connaît pas encore, il n’en tire aucun avantage immédiat car les compétences de Connaissances ne sont utilisables qu’après une formation.</p>', 'Certaines contrées accordent davantage de valeur à la plume qu’à l’épée. Durant son enfance, le personnage a bénéficié de plusieurs années d’instruction plus ou moins formelle.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Éducation' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Effet amélioré', 8, '<p><strong>Conditions.</strong> Degré de maîtrise de 30 en Art de la magie, Degré de maîtrise de 30 en Connaissances (mystères), Talent (Art de la magie), Aptitude de classe de Effet métamagique</p>
<p><strong>Avantage.</strong> Le personnage peut modifier les variables numériques d''un effet magique déjà en place (à l''exception du point d''origine ou du centre de l''effet) comme s''il jetait lui-même le sort, et même s''il en est normalement incapable. Par exemple, il a le droit de modifier le rayon d''un mur de feu en forme d''anneau, mais il est incapable d''en changer le point d''origine.</p>
<p>S''il le souhaite, il peut également remplacer le niveau de lanceur de sorts original par le sien. Il a également le droit de façonner l''effet comme bon lui semble tant qu''il respecte les paramètres du sort. A l''instar du pouvoir d''effet métamagique, il doit être adjacent à l''effet ou en son sein et réussir un test d''Art de la magie (DD 30 + [niveau du sort x 3}</p>
<p>Le personnage peut user de ce pouvoir et de son aptitude d''effet métamagique un nombre de fois par jour égal à 5 + modificateur d''Intelligence. Pour y recourir, il doit entreprendre une action complexe qui provoque des attaques d''opportunité.</p>', 'Le personnage peut modifier le profil d''un effet, magique persistant déjà en place.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Effet amélioré' AND do_res_id = 63 AND do_ruleset_var_id = 1);

UPDATE dd_dons SET do_texte = '<p><strong>Condition.</strong> Faculté de lancer des sorts profanes de 6e niveau</p>
<p><strong>Avantage.</strong> Le personnage ajoute les sorts qui suivent à la liste de sorts de la classe de magie profane qui lui permet de jeter des sorts de 6e niveau.</p>
<p>[[tab:don-elu-des-sept-soeurs]]</p>
<p>Si le personnage possède un grimoire, il les y ajoute tout simplement. S''il jette ses sorts -spontanément (à la manière d''un barde ou d''un ensorceleur), il peut instantanément en échanger un de ceux qu''il connaît contre un autre de la liste figurant ci-dessus. Par la suite, il peut en échanger d''autres en se conformant aux règles habituelles.</p>', do_resume = 'Grâce au lien qu''il entretient avec l''une des Sept Sœurs, le personnage a les faveurs de Mystra.' WHERE do_id = 283 AND do_res_id = 63;

UPDATE dd_dons SET do_texte = '<p><strong>Conditions.</strong> Magicien Rouge de niveau 5, Sort corrompu</p>
<p><strong>Avantage.</strong> Quand le personnage lance un sort corrompu, l''affaiblissement temporaire qu''il subit est réduit de 1 point.</p>', do_resume = 'Grâce à la place prestigieuse qu''il occupe parmi les Magiciens Rouges, le personnage connaît des secrets magiques maléfiques qui sont propres aux zulkirs.' WHERE do_id = 288 AND do_res_id = 63;

UPDATE dd_dons SET do_texte = '<p><strong>Conditions.</strong> Demi-elfe de lune[Eauprofonde], Drow [Menzoberranyr], Drow wyrmprofond [Menzoberranyr], Elfe de lune [Eauprofonde], Humain [Eauprofonde], Humain [Sembie], Formé au maniement des armes de guerre</p>
<p><strong>Avantage.</strong> Lorsque le personnage combat avec deux lames (cimeterre, dague, épée courte, épée longue ou rapière, quelle que soit la combinaison), il a droit, durant son action, de désigner un adversaire situé au corps à corps contre lequel il bénéficie d’un bonus de bouclier de +2 à la CA. Ce bonus se cumule avec le bonus de bouclier d’une targe ou d’un bouclier animé. A chaque fois que vient son tour de jeu, le personnage peut désigner un nouvel adversaire situé au corps à corps (action libre). Il doit renoncer à ce bonus s’il est pris au dépourvu ou perd son bonus de Dextérité à la CA.</p>
<p><em>Ce don figurait déjà dans le supplément « Les Royaumes Oubliés ».</em></p>', do_resume = COALESCE('Le personnage maîtrise un style de défense basé sur l’utilisation d’une lame dans chaque main.', do_resume), do_res_id = 63 WHERE do_id = 139 AND do_res_id = 40;

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Ethran', 10, '<p><strong>Conditions.</strong> Humain[Rashéménie], Sexe féminin</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d’un bonus de +2 aux tests de Dressage et Survie. Lorsqu’il traite avec d’autres Rashémis, il bénéficie d’un bonus de +2 aux tests de compétence et de caractéristique relevant du Charisme. De plus, il peut se livrer à la magie de cercle.</p>', 'Le personnage a été initié aux secrets des Sorcières de Rashéménie en qualité de membre des Ethran, les " injugées ".', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Ethran' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Fibre commerciale', 10, '<p><strong>Condition.</strong> Bricolin[Lantan], Cactacée [Calimshan], Gnome des profondeurs [Outreterre (Nord-Terre)], Gnome des roches [Lantan], Halfelin pied-léger [Amn], Halfelin pied-léger [Calimshan], Halfelin vaillant [Calimshan], Humain [Amn], Humain [Eauprofonde], Humain [Expatrié shou], Humain [Lantan], Humain [Sélune], Humain [Sembie], Humain [Tharsult], Humain [Thesk], Humain [Turmish], Humain [Vaste], Kenku [Calimshan], Nain d''écu [Cote des épées], Nain d''écu [Eauprofonde], Nain gris [Outreterre (Noires contrées)]</p>
<p><strong>Avantage.</strong> Quand le personnage vend des armes, des objets magiques et autres biens liés à ses aventures, il en tire 75 % du prix indiqué, contre 50 % en temps normal. Une fois par mois, il peut acheter un objet 75 % de son prix de vente. Durant la création de personnage, il reçoit également 300 po à dépenser comme il lui sied.</p>', 'Le personnage vient d’une famille pourvue de nombreux contacts parmi les guildes et le négoce de Faerûn. Il tire un bon prix de tout ce qu’il vend ou achète.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Fibre commerciale' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Force d''âme', 10, '<p><strong>Condition.</strong> Bricolin[Contrées du Mitan Occidentale], Demi-Drow [Dambrath], Demi-Drow [Les Vaux], Demi-elfe de lune [Les Vaux], Demi-elfe de lune [Lunargent], Elfe de lune [Cour elfique], Elfe de lune [Lunargent], Elfe des bois [Cour elfique], Elfe des bois [Lunargent], Elfe sauvage [Cour elfique], Furte [Arntombe], Gnome des profondeurs [Outreterre (Nord-Terre)], Gnome des roches [Contrées du Mitan Occidentale], Halfelin pied-léger [Luiren], Halfelin sagespectre [Vallée de Channath], Halfelin vaillant [Vallée de Channath], Humain [Iles Moonshae], Nains des falaises [Ruathym], Urdunnir [Oldonnar]</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d’un bonus de +1 aux jets de Vigueur et de Volonté. Ce bonus passe a +3 contre les effets de mort, l’absorption d’énergie et les diminutions permanentes de caractéristiques.</p>', 'Le personnage possède une résistance innée à la magie de mort et aux attaques surnaturelles. Il est difficile de séparer son âme de son corps.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Force d''âme' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Forestier', 10, '<p><strong>Condition.</strong> Centaure[Haute forêt], Demi-elfe de lune [Aglarond], Demi-elfe de lune [Haute forêt], Demi-elfe des bois [Haute forêt], Elfe des bois [Forêt de Léthyr], Elfe des bois [Haute forêt], Elfe des étoiles [Sildëyuir], Elfe sauvage [Bois de Chontal], Elfe sauvage [Val brumeux], Gnome des roches [Grand-Val], Gnomes des forêts [Grand-Val], Halfelin sagespectre [Bois de Chontal], Humain [Grand-Val], Humain [Les Vaux], Minuitlin [Arvandor], Minuitlin [Foyer de la Nature], Volodni [Forêt de Léthyr]</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d’un bonus de +1 aux tests de Déplacement silencieux, Détection, Discrétion et Perception auditive. En forêt, ce bonus passe à +3.</p>', 'Le personnage ne fait qu’un avec les vastes forêts de Faerûn. Au sein d’une forêt, il n’a guère de rival.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Forestier' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Formation magique', 10, '<p><strong>Conditions.</strong> Céladarin[Eternelle-Rencontre], Céladarin [Everska], Elfe de lune [Eternelle-Rencontre], Elfe de lune [Everska], Elfe des bois [Eternelle-Rencontre], Elfe du soleil [Eternelle-Rencontre], Elfe du soleil [Everska], Humain [Halruaa], Humain [Nimbrall], Int ou Cha 10</p>
<p><strong>Avantage.</strong> Le personnage peut lancer trois sorts profanes de niveau 0 par jour en qualité d’ensorceleur ou de magicien (au choix, tant qu’il a une valeur de 10 au moins dans la caractéristique attenante), Cette décision doit être prise au moment où le don est choisi. Le personnage tient compté du risque d’échec des sorts profanes s’il porte une armure. De plus, on le considère comme un ensorceleur ou un magicien de son niveau de lanceur de sorts (niveau 1 minimum) pour ce qui est des diverses variables liées au niveau.</p>
<p>Si le personnage lance ces sorts comme un ensorceleur, leur DD de sauvegarde est égal à 10 + son modificateur de Cha. Il connaît alors deux sorts de niveau 0 de la liste d’ensorceleur/magicien.</p>
<p>Si le personnage lance ces sorts comme un magicien, leur DD de sauvegarde est égal à 10 + son modificateur d’Int. Il possède alors un grimoire renfermant trois sorts de niveau 0 de la liste d’ensorceleur/magicien. Il les prépare de la même façon qu’un magicien.</p>
<p><strong>Spécial.</strong> Si le personnage possède des niveaux d’ensorceleur ou de magicien, il peut lancer trois sorts de niveau 0 de plus par jour.</p>', 'Le personnage est originaire d’une contrée où les bases de la magie sont enseignées à tous ceux qui font montre d’un don. Tout artisan ou travailleur, semble-t-il, connaît un tour ou deux susceptibles de lui faciliter la tâche.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Formation magique' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Impétueux', 10, '<p><strong>Condition.</strong> Humain[Altumbel], Humain [Damara], Humain [Grand-Val], Humain [Rashéménie], Loxo [Shaar], Nain d''écu [Epine dorsale du monde], Nain d''écu [Outreterre (Griffe terre)], Nain d''écu [Shanatar l’Ancienne], Nain d''or [Grande Faille], Nain gris [Outreterre (Nord-Terre)], Nain polaire [Epine dorsale du monde], Nains des falaises [Ruathym], Urdunnir [Epine dorsale du monde]</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d’un bonus de +2 aux jets de Volonté. Il ne saurait être secoué et ignore donc les effets de cet état préjudiciable.</p>
<p><strong>Spécial.</strong> Ce don compte comme le don Volonté de fer pour ce qui est de satisfaire à des conditions ou prérequis et ne se cumule pas avec ce dernier.</p>', 'L’opiniâtreté et la détermination du personnage sont légendaires. Il est particulièrement têtu et il est difficile de le faire changer d’avis.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Impétueux' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Infatigable', 10, '<p><strong>Condition.</strong> Demi-orque[Terres de la Horde], Gulgar [Outreterre (Griffe terre)], Halfelin d''Anadia [Polarat du Sud], Homme-lézard [Surkh], Humain [Chevauché], Humain [Terres de la Horde], Humain [Thindol], Humain [Vaasie], Killoren [Terres de la Horde], Minotaure [Outreterre (Labyrinthe)], Nain d''écu [Cote des épées], Nain d''écu [Montagnes Galènes], Nain d''écu [Shanatar l’Ancienne], Nains des falaises [Ruathym], Orcam [Mer des glaces flottantes], Orque gris [Terres de la Horde], Thri-Kreen [Shaar], Wemic [Shaar]</p>
<p><strong>Avantage.</strong> Le personnage réduit d’un cran les effets de l’épuisement et de la fatigue. Il ne peut donc pas être épuisé. S’il est exposé à un effet censé l’épuiser (comme vagues d’épuisement), il est simplement fatigué. S’il est exposé à un effet censé le fatiguer (comme au terme d’une rage de berserker), il n’est pas affecté.</p>', 'Le personnage ne connaît pas le sens du verbe " abandonner ".', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Infatigable' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Initié d''Ilmater', 5, '<p><strong>Conditions.</strong> Prêtre ou Paladin de niveau 7, Ilmater en qualité de divinité tutélaire</p>
<p><strong>Avantage.</strong> Quand le personnage lance un sort de soins qui soigne plus de points de vie que la cible n''a subi de dégâts, l''excédent se transforme en points de vie temporaires. Il est ainsi possible de conférer un nombre de points de vie temporaires égal aux dés de vie de la cible x 3. Ceux-ci ont une durée de vie de 1 heure. Toute créature jouissant de tels points de vie temporaires bénéficie également d''un bonus de sainteté de +2 aux jets de Vigueur et aux tests visant à résister à une tentative de bousculade ou de croc-en-jambe. Ces bonus s''évanouissent lorsque le dernier point de vie temporaire disparaît.</p>
<p>De plus, le personnage ajoute les sorts qui suivent à sa liste de sorts de prêtre ou de paladin.</p>
<p>[[tab:don-initie-d-ilmater]]</p>', 'Le personnage connaît les plus grands secrets de l''Eglise d''Ilmater,', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Initié d''Ilmater' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Initié de Baine', 5, '<p><strong>Conditions.</strong> Prêtre de niveau 5, Baine en qualité de divinité tutélaire</p>
<p><strong>Avantage.</strong> Le prêtre gagne présence terrifiante, le pouvoir de terroriser ses adversaires dès qu''il fait montre d''hostilité. Quand il attaque ou charge, les ennemis situés dans un rayon de 9 mètres doivent réussir un jet de Volonté (DD 10 +1/2 niveau de prêtre + modificateur de Charisme) sous peine d''être secoués pendant 1d4 rounds.</p>
<p>De plus, le personnage ajoute les sorts qui suivent à sa liste de sorts de prêtre.</p>
<p>[[tab:don-initie-de-baine]]</p>', 'Le personnage connaît les plus grands secrets de l''Église de Baine.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Initié de Baine' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Initié de Cyric', 5, '<p><strong>Conditions.</strong> Prêtre de niveau 3, Cyric en qualité de divinité tutélaire</p>
<p><strong>Avantage.</strong> Le personnage est immunisé contre la terreur magique et ordinaire.</p>
<p>De plus, le personnage ajoute les sorts qui suivent à sa liste de sorts de prêtre.</p>
<p>[[tab:don-initie-de-cyric]]</p>', 'Le personnage connaît les plus grands secrets de l''Église de Cyric.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Initié de Cyric' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Initié de Gond', 5, '<p><strong>Conditions.</strong> Prêtre de niveau 1, Gond en qualité de divinité tutélaire</p>
<p><strong>Avantage.</strong> Le personnage ajoute Crochetage et Désamorçage/sabotage à sa liste de compétences de prêtre.</p>
<p>De plus, le personnage ajoute les sorts qui suivent à sa liste de sorts de prêtre.</p>
<p>[[tab:don-initie-de-gond]]</p>', 'Le personnage connaît les plus grands secrets de l''Église de Gond', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Initié de Gond' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Initié de Heaum', 5, '<p><strong>Conditions.</strong> Prêtre ou Paladin de niveau 5, Heaum en qualité de divinité tutélaire</p>
<p><strong>Avantage.</strong> Le personnage peut effectuer des attaques d''opportunité quand il est pris au dépourvu, comme s''il avait le don Attaques réflexes. Par contre, il ne gagne pas d''attaques d''opportunité supplémentaires dans le round.</p>
<p>De plus, le personnage ajoute les sorts qui suivent à sa liste de sorts de prêtre ou de paladin.</p>
<p>[[tab:don-initie-de-heaum]]</p>', 'Le personnage connaît les plus grands secrets de l’Église de Heaum.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Initié de Heaum' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Initié de la Nature', 5, '<p><strong>Conditions.</strong> Prêtre ou Druide de niveau 5, Divinité tutélaire Eldath, Mailikki ou Sylvanus</p>
<p><strong>Avantage.</strong> Le personnage intimide ou contrôle les animaux et les créatures végétales comme un prêtre mauvais intimide ou contrôle les morts-vivants. Il peut utiliser ce pouvoir un nombre de fois par jour égal à 3 + modificateur de Charisme.</p>
<p>De plus, le personnage ajoute les sorts qui suivent à sa liste de sorts de prêtre ou de druide.</p>
<p>[[tab:don-initie-de-la-nature]]</p>', 'Le personnage connaît les plus grands secrets de l''Église d''Eldath, Mailikki ou Sylvanus.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Initié de la Nature' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Initié de Lathandre', 5, '<p><strong>Conditions.</strong> Prêtre de niveau 1, Lathandre en qualité de divinité tutélaire</p>
<p><strong>Avantage.</strong> Le personnage, peut lancer de manière spontanée tout sort de sa liste affichant le registre de la lumière ou ce même mot dans son nom, ce qui inclut lumière, lumière du jour et lumière brûlante. Ce pouvoir fonctionne sur le même principe que l''incantation spontanée des sorts de soins.</p>
<p>De plus, le personnage ajoute les sorts qui suivent à sa liste de sorts de prêtre.</p>
<p>[[tab:don-initie-de-lathandre]]</p>', 'Le personnage connaît les plus grands secrets de l''Église de Lathandre.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Initié de Lathandre' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Initié de Loviatar', 5, '<p><strong>Conditions.</strong> Prêtre de niveau 5, Loviatar en qualité de divinité tutélaire</p>
<p><strong>Avantage.</strong> Lorsque le personnage subit des dégâts pour la première fois au cours d''un combat, il bénéficie d''un bonus de moral de +1 aux jets d''attaque et de sauvegarde contre la terreur pendant 1 minute par niveau de prêtre.</p>
<p>De plus, il ajoute les sorts qui suivent à sa liste de sorts de prêtre :</p>
<p>[[tab:don-initie-de-loviatar]]</p>', 'Le personnage a été initié aux secrets de l''Eglise de Loviatar.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Initié de Loviatar' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Initié de Malar', 5, '<p><strong>Conditions.</strong> Prêtre ou Druide de niveau 3, Malar en qualité de divinité tutélaire</p>
<p><strong>Avantage.</strong> Quand le personnage lance un sort de convocation de monstres ou de convocation d''alliés naturels pour appeler un animal normal ou fiélon, ce dernier bénéficie d''un bonus d''altération de +4 en Force et en Constitution, comme si le personnage possédait le don Amélioration des créatures convoquées.</p>
<p>De plus, le personnage ajoute les sorts qui suivent à sa liste de sorts de prêtre ou de druide.</p>
<p>[[tab:don-initie-de-malar]]</p>', 'Le personnage connaît les plus grands secrets de l''Église de Malar.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Initié de Malar' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Initié de Mystra', 5, '<p><strong>Conditions.</strong> Prêtre de niveau 3, Mystra en qualité de divinité tutélaire</p>
<p><strong>Avantage.</strong> Le personnage peut tenter de lancer des sorts dans une zone de magie morte ou une zone d''antimagie. Dans une zone de magie morte, il lui faut réussir un test de niveau de lanceur de sorts contre un DD égal à 20 + niveau du sort qu''il tente de jeter. Au sein d''une zone d''antimagie, il doit réussir un test de niveau de lanceur de sorts contre un DD égal à 11 + niveau de lanceur de sorts de la zone d''antimagie. En cas de succès, le sort fonctionne normalement</p>
<p>De plus, le personnage ajoute les sorts qui suivent à sa liste de sorts de prêtre.</p>
<p>[[tab:don-initie-de-mystra]]</p>', 'Le personnage connaît les plus grands secrets de l''Église de Mystra.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Initié de Mystra' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Initié de Séluné', 5, '<p><strong>Conditions.</strong> Séluné en qualité de divinité tutélaire, Niveau 3 de prêtres druide, hathran ou rôdeur</p>
<p><strong>Avantage.</strong> Le personnage jette les sorts augure et divination avec un bonus de +5 au niveau de lanceur de sorts.</p>
<p>De plus, le personnage ajoute les sorts qui suivent à sa liste de sorts de prêtre, druide, hathran ou rôdeur.</p>
<p>[[tab:don-initie-de-selune]]</p>', 'Le personnage connaît les plus grands secrets de l''Église de Séluné', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Initié de Séluné' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Initié de Tyr', 5, '<p><strong>Conditions.</strong> Prêtre de niveau 7, Tyr en qualité de divinité tutélaire</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d''un bonus de +1 aux jets de dégâts quand il attaque à l''aide d''une épée longue.</p>
<p>De plus, le personnage ajoute les sorts qui suivent à sa liste de sorts de prêtre.</p>
<p>[[tab:don-initie-de-tyr]]</p>', 'Le personnage connaît les plus grands secrets de l''Église de Tyr.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Initié de Tyr' AND do_res_id = 63 AND do_ruleset_var_id = 1);

UPDATE dd_dons SET do_texte = '<p><strong>Conditions.</strong> Int 13, Niveau 3 de lanceur de sorts divins, Compétence d’Artisanat adéquate</p>
<p><strong>Avantage.</strong> Le personnage peut lancer tout sort auquel il accès en qualité de rune. Il doit avoir préparé le sort à inscrire, mais également disposer de tous les focaliseurs et composantes matérielles nécessaires. Si le sort a un coût en PX, le personnage en paye le prix en commençant la rune, en plus du coût en PX de la rune elle-même. En outre, les composantes matérielles sont détruites au début du rituel, ce qui n’est pas le cas des focaliseurs.</p>
<p>Un objet de taille M ou inférieure ne peut accueillir qu’une rune. Les objets plus gros peuvent contenir une rune par tranche de 2,25m2 de surface (1,50 m X 1,50 m). Il est impossible d’inscrire une rune sur une créature, mais on peut la placer sur un élément de son équipement.</p>
<p>Une rune a un prix de vente égal au niveau du sort X niveau de lanceur de sorts x 50 po (un sort de niveau 0 compte pour un 1/2 niveau). Le personnage doit également sacrifier un nombre de points d’expérience égal à 1/25 du prix de vente et acheter les matières premières nécessaires (pour une valeur totale égale à la moitié du prix indiqué).</p>
<p><em>Ce don figurait déjà dans le supplément « Les Royaumes Oubliés ».</em></p>', do_resume = COALESCE('Le personnage est capable de créer des runes magiques contenant des sorts jusqu’à ce qu’on les déclenche.', do_resume), do_res_id = 63 WHERE do_id = 93 AND do_res_id = 40;

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Inscription de runes épiques', 8, '<p><strong>Conditions.</strong> Int 19, Degré de maîtrise de 24 en Artisanat (en adéquation avec l’utilisation des runes), Inscription de runes</p>
<p><strong>Avantage.</strong> Le personnage peut créer des runes outrepassant les limites habituelles. Par exemple, il peut créer une rune accompagnée d''un.sort de 10e niveau ou de niveau 25 de lanceur de sorts.</p>
<p>Même ce don ne permet pas de créer une rune accompagnée d''un sort épique. En effet, une telle magie dépasse la puissance des textes et ne peut donc pas prendre la forme de runes.</p>', 'Le personnage est capable de créer des runes épiques.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Inscription de runes épiques' AND do_res_id = 63 AND do_ruleset_var_id = 1);

UPDATE dd_dons SET do_texte = '<p><strong>Condition.</strong> Aasimar[Chessenta], Genasi d''eau [Chessenta], Humain [Bief des magiciens], Humain [Chessenta], Humain [Eaux dorées], Humain [Halruaa], Humain [Lantan], Humain [Mulhorande], Humain [Nimbrall], Humain [Sélune], Humain [Unther], Imaskari des profondeurs [Outreterre (Noire Imaskar)], Kenku [Eaux dorées], Zénythri [Calimshan], Zénythri [Mulhorande]</p>
<p><strong>Avantage.</strong> Choisissez une classe de lanceur de sorts profanes. Le personnage peut désormais activer les objets à potentiel magique comme s’il disposait de 1 niveau dans la classe choisie. Celle-ci devient également une classe de prédilection eh plus de sa classe de prédilection normale. Par exemple, un guerrier/roublard humain qui choisit magicien dans le cadre de ce don pourra gagner des niveaux de magicien sans être victime du malus en points d’expérience pour s’être multiclassé dans trois classes.</p>
<p><strong>Spécial.</strong> Si le personnage est un magicien spécialisé et qu’il choisit la classe d’ensorceleur ou de magicien dans le cadre de l’avantage de ce don, il peut activer les objets à potentiel magique de son école opposée.</p>
<p><em>Ce don figurait déjà dans le supplément « Les Royaumes Oubliés ».</em></p>', do_resume = COALESCE('Au pays, tous ceux qui font la démonstration d’un quelconque talent magique bénéficient d’une formation spéciale. Nombre de personnages connaissent donc les us des bardes, ensorceleurs et magiciens.', do_resume), do_res_id = 63 WHERE do_id = 198 AND do_res_id = 40;

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Intrépide', 10, '<p><strong>Condition.</strong> Chaond[Damara], Demi-géant [Anauroch], Demi-orque [Amn], Demi-orque [Chessenta], Demi-orque [Vaasie], Furte [Shanatar l’Ancienne], Homme-lézard [Surkh], Humain [Anauroch], Humain [Damara], Humain [Grand-Val], Humain [Iles Moonshae], Humain [Impiltur], Humain [Shanatar l’Ancienne], Nain d''écu [Montagnes Galènes], Nain d''écu [Outreterre (Griffe terre)], Nain d''écu [Turmish], Nain d''or [Montagnes Fumantes], Nain d''or [Turmish], Orque des montagnes [Chessenta], Orque des montagnes [Vaasie], Slyth [OutreTerre (Fluvilnistra)]</p>
<p><strong>Avantage.</strong> Le personnage gagne 5 points de vie.</p>
<p><strong>Spécial.</strong> Ce don compte comme le don Robustesse pour ce qui est de satisfaire à des conditions ou prérequis et ne se cumule pas avec ce dernier.</p>', 'Le personnage tient bon là où d’autres s’écrouleraient.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Intrépide' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Jumeau tonnerre', 10, '<p><strong>Condition.</strong> Nain d''écu[Cote des épées], Nain d''écu [Eauprofonde], Nain d''écu [Epine dorsale du monde], Nain d''écu [Montagnes Galènes], Nain d''écu [Shanatar l’Ancienne], Nain d''écu [Turmish], Nain d''or [Grande Faille], Nain d''or [Montagnes Fumantes], Nain d''or [Turmish], Nain polaire [Epine dorsale du monde], Urdunnir [Epine dorsale du monde]</p>
<p><strong>Avantage.</strong> Le personnage a un frère jumeau ou une sœur jumelle. Si ce jumeau est vivant et qu’il se trouve dans le même plan, le personnage peut tenter un test de Sagesse (DD 12) pour savoir dans quelle direction le trouver. En cas de succès, le personnage connaît la direction de son jumeau au prix d’une action de mouvement durant l’heure qui suit. On peut tenter ce test une fois par heure.</p>
<p>Le personnage bénéficie également d’un bonus de +2 aux tests de Diplomatie et Intimidation.</p>', 'Le personnage est issu de la génération naine de jumeaux nés après la Bénédiction du Tonnerre de Moradin, au cours de l’Année du Tonnerre.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Jumeau tonnerre' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Lanceur de haches', 10, '<p><strong>Condition.</strong> Boogin[Outreterre (Nord-Terre)], Demi-orque [Mer de Lune], Homme-lézard [Surkh], Humain [Grand glacier], Humain [Iles Moonshae], Humain [Nord], Humain [Vaasie], Nain d''écu [Grand glacier], Nain polaire [Grand glacier], Ogrillon [Mer de Lune], Orogue [Mer de Lune], Orogue [Outreterre (Nord-Terre)], Orque des montagnes [Mer de Lune], Orque des montagnes [Outreterre (Nord-Terre)], Tanarukk [Outreterre (Nord-Terre)]</p>
<p><strong>Avantage.</strong> Quand le personnage effectue une attaque à distance à l’aide d’une arme de jet (hache, lance, javeline, etc.), il peut ajouter au jet d’attaque son bonus de Force à la place de son bonus de Dextérité.</p>
<p><strong>Normal.</strong> Un personnage qui attaque à l’aide d’une arme à distance ajoute habituellement son bonus de Dextérité au jet d’attaque.</p>', 'Le personnage est capable de porter un coup mortel quand il lance une arme lourde.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Lanceur de haches' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Lignée de feu', 10, '<p><strong>Condition.</strong> Genasi d''air[Calimshan], Genasi de feu [Calimshan], Humain [Calimshan]</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d’un bonus de +4 aux jets de sauvegarde contre les effets de feu. En outre, il lance les sorts affichant le registre du Feu avec un bonus de +2 au niveau de lanceur de sorts.</p>', 'Le personnage descend des éfrits qui régnèrent sur le Calimshan pendant si longtemps. Le sang de ces esprits du Feu coule donc dans ses veines.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Lignée de feu' AND do_res_id = 63 AND do_ruleset_var_id = 1);

UPDATE dd_dons SET do_texte = '<p><strong>Condition.</strong> Sag 15 ou Shar en qualité divinité tutélaire</p>
<p><strong>Avantage.</strong> Les sorts du personnage puisent désormais leur puissance dans la Toile d’Ombre plutôt que dans la Toile. En outre, il est capable d’activer les objets magiques qui exploitent 1a Toile d’Ombre sans subir de dégâts.</p>
<p>Le DD de sauvegarde des enchantements, illusions et nécromancies que lance le personnage augmente de +1. Le personnage bénéficie également d’un bonus, de +1 aux tests de niveau de lanceur de sorts visant à vaincre la résistance à la magie des effets issus de ces écoles.</p>
<p>La Toile d’Ombre est moins intéressante pour les effets impliquant énergie et matière. Ainsi, le niveau effectif de jeteur de sorts est réduit de 1 point dans le cadre des évocations et des transmutations (sauf s’il s’agit de sorts relevant du registre de l’obscurité). Un utilisateur de la Toile d’Ombre de niveau 1 ne peut donc pas lancer le moindre sort de ces écoles.</p>
<p>Le personnage ne peut plus lancer de sorts relevant du registre de la lumière. Sa capacité à utiliser les objets magiques générant de la lumière est également limitée. Ainsi, il ne peut plus faire appel au pouvoir de lumière des objets magiques à mot de commande et à fin d’incantation.</p>
<p>Désormais, tous les objets magiques qu’il crée sont des objets magiques de la Toile d’Ombre.</p>
<p><em>Ce don figurait déjà dans le supplément « Les Royaumes Oubliés ».</em></p>', do_resume = COALESCE('Le personnage a découvert les dangereux secrets de la Toile d’Ombre.', do_resume), do_res_id = 63 WHERE do_id = 112 AND do_res_id = 40;

UPDATE dd_dons SET do_texte = '<p><strong>Condition.</strong> Magie de la Toile d’ombre</p>
<p><strong>Avantage.</strong> Quand un utilisateur de la Toile emploie un sort (comme détection de la magie), un pouvoir magique ou un objet magique de divination susceptible de détecter l’aura magique de l’un des sorts du personnage, il lui faut réussir un test de niveau de lanceur de sorts (DD 11 + niveau, de lanceur de sorts du personnage) pour que son action soit couronnée de succès. De même, un utilisateur de la Toile recourant à une divination (comme détection de l’invisibilité) pour révéler les effets de l’un des sorts du personnage doit réussir un test de niveau de lanceur de sorts pour y parvenir. L’utilisateur de la Toile ne peut effectuer qu’un test de niveau de lanceur de sorts par divination employée, quel que soit le nombre des sorts du personnage affectant la zone. Toutes les créatures usant de sorts ou de pouvoirs magiques sont considérées comme des utilisatrices de la Toile, sauf si elles possèdent le don Magie de la Toile d’ Ombre</p>
<p>Cet avantage ne s’étend pas aux évocations et aux transmutations que lance le personnage.</p>
<p><em>Ce don figurait déjà dans le supplément « Les Royaumes Oubliés ».</em></p>', do_resume = COALESCE('Le personnage peut se servir de la Toile d’Ombre pour que les utilisateurs de la Toile aient davantage de mal à détecter ses sorts.', do_resume), do_res_id = 63 WHERE do_id = 94 AND do_res_id = 40;

UPDATE dd_dons SET do_texte = '<p><strong>Condition.</strong> Magie de la Toile d’ombre</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d’un bonus de +4 aux tests de niveau de lanceur de sorts visant à vaincre la résistance à la magie d’un utilisateur de la Toile. Toutes les créatures usant de sorts et de pouvoirs magiques sont considérées comme des utilisatrices de la Toile, sauf si elles possèdent le don Magie de la Toile d’Ombre. Cet avantage se cumule avec ceux découlant des dons Efficacité des sorts accrus et Efficacité des sorts supérieure, mais il ne s’étend pas aux évocations et aux transmutations.</p>
<p><em>Ce don figurait déjà dans le supplément « Les Royaumes Oubliés ».</em></p>', do_resume = COALESCE('Le personnage peut se servir de la Toile d’Ombre pour que les utilisateurs de la Toile aient plus de mal à résister à ses sorts.', do_resume), do_res_id = 63 WHERE do_id = 95 AND do_res_id = 40;

UPDATE dd_dons SET do_texte = '<p><strong>Condition.</strong> Magie de la Toile d’ombre</p>
<p><strong>Avantage.</strong> Les sorts du personnage résistent aux tentatives de dissipation des utilisateurs de la Toile. Toutes les créatures usant de sorts ou de pouvoirs magiques sont des utilisatrices de la Toile, sauf si elles possèdent le don Magie de la Toile d’Ombre. Quand un utilisateur de la Toile effectue un test de dissipation contre l’un des sorts du personnage (dont dissipation de la magie pour contrer un sort qu’il lance), le DD s’élève à 15 + niveau de lanceur de sorts du personnage. Cet avantage ne s’étend pas aux évocations et aux transmutations,</p>', do_resume = 'Le personnage peut se servir de la Toile d’Ombre pour que les utilisateurs de la Toile aient plus de mal à dissiper ses sorts.' WHERE do_id = 311 AND do_res_id = 63;

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Maître des portails', 3, '<p><strong>Condition.</strong> Création d’objets merveilleux</p>
<p><strong>Avantage.</strong> Quand le personnage crée un portail, il s’acquitte simplement de la moitié du coût de création de l’objet. Cet avantage ne se cumule pas avec celui d’Artisanat magique.</p>
<p>De plus, le personnage sait comment franchir les portails dangereux en toute sécurité. Au prix d’une action simple, il peut tenter de stabiliser temporairement un portail défectueux. Effectuez un test d’Art de la magie et ajoutez le résultat à celui du jet des hasards de portail. Le portail reste stable pendant 1 minute, mais le personnage peut renouveler l’opération aussi souvent que nécessaire.</p>', 'Le personnage est particulièrement doué dans l’art de création des portails, des objets magiques permanents qui transportent ceux qui en connaissent les secrets d’un endroit à un autre. Faerûn est parsemée de portails.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Maître des portails' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Milice', 10, '<p><strong>Condition.</strong> Demi-elfe de lune[Aglarond], Halfelin d''Anadia [Polarat du Nord], Halfelin pied-léger [Luiren], Humain [Altumbel], Humain [Impiltur], Humain [Konigheim], Humain [Les Vaux], Humain [Samarach], Humain [Thindol], Humain [Turmish]</p>
<p><strong>Avantage.</strong> Le personnage est formé au maniement de toutes les armes de guerre.</p>', 'Le peuple du personnage compte sur une milice entraînée et armée pour défendre ses terres. Le personnage connaît l’usage des armes.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Milice' AND do_res_id = 63 AND do_ruleset_var_id = 1);

UPDATE dd_dons SET do_texte = '<p><strong>Conditions.</strong> Verminophile, Lolth en qualité de divinité tutélaire</p>
<p><strong>Avantage.</strong> La salive du personnage est venimeuse. Il lui est possible d''inoculer son venin en agrippant son adversaire dont la peau est exposée s''il réussit un test de lutte. Le DD du jet de Vigueur visant à résister à l''empoisonnement est égal à 10 + 1/2 niveau global + modificateur de Constitution. Les dégâts initiaux et secondaires sont les mêmes (affaiblissement temporaire de 1d4 points de Force). Les baisers du personnage sont également venimeux. Il peut aussi répandre sa salive sur de la nourriture ou la mélanger à une boisson. En cas d''ingestion, le DD de sauvegarde diminue de 1 points.</p>', do_resume = 'Le personnage acquiert une morsure venimeuse semblable à celle d''une araignée.' WHERE do_id = 287 AND do_res_id = 63;

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Negociateur-né', 10, '<p><strong>Condition.</strong> Halfelin d''Anadia[Polarat du Nord], Halfelin pied-léger [Amn], Humain [Amn], Humain [Bief de Vilhon], Humain [Cités libres de Parsanic], Humain [Cote des dragons], Humain [Eauprofonde], Humain [Eaux dorées], Humain [Marches du désert], Humain [Sembie], Humain [Tharsult], Humain [Thesk], Kenku [Eaux dorées], Nain d''écu [Eauprofonde], Nain d''écu [Turmish], Nain d''or [Grande Faille], Nain d''or [Turmish]</p>
<p><strong>Avantage.</strong> Le personnage obtient un bonus de +2 sur tous ses tests de Bluff , Estimation et Psychologie.</p>', 'La culture du personnage est basée sur le troc et l’art du commerce.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Negociateur-né' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Nomade monté', 10, '<p><strong>Condition.</strong> Humain[Chevauché], Humain [Shaar], Humain [Terres de la Horde], Killoren [Terres de la Horde]</p>
<p><strong>Avantage.</strong> Le personnage acquiert le don Maniement d’une arme de guerre (arc court composite, cimeterre et lance d’arçon). De plus, il bénéficie d’un bonus de +3 aux tests d’Équitation.</p>', 'Le personnage a été élevé au sein d’une culture pour laquelle l’équitation et le tir à l’arc ont une grande importance.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Nomade monté' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Pied léger', 10, '<p><strong>Condition.</strong> Demi-Drow[Les Vaux], Demi-elfe de lune [Haute forêt], Demi-elfe de lune [Les Vaux], Demi-elfe des bois [Haute forêt], Elfe des bois [Forêt de Léthyr], Elfe des bois [Haute forêt], Elfe des bois [Wealdath], Elfe sauvage [Wealdath], Humain [Shaar], Humain [Thindol], Minuitlin [Foyer de la Nature]</p>
<p><strong>Avantage.</strong> La vitesse de base au sol du personnage est de 3 mètres supérieure a celle des autres représentants de sa race. Cet avantage ne s’applique que s’il porte une armure légère (ou pas d’armure du tout) et ne s’encombre pas d’une charge lourde. Appliquez le bonus avant de modifier la vitesse de déplacement du personnage en raison de sa charge transportée.</p>
<p><strong>Spécial.</strong> Si l’une des aptitudes de classe du personnage augmente également sa vitesse de déplacement, celle-ci se cumule avec l’effet du don Pied léger.</p>
<p>Le don "Pied léger" du Codex Martial a été renommé Course sinueuse pour éviter les homonymes.</p>', 'Le personnage est très rapide.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Pied léger' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Pied sûr', 10, '<p><strong>Condition.</strong> Demi-orque[Amn], Demi-orque [Mer de Lune], Demi-orque [Vaasie], Gulgar [Montagne du Levant], Humain [Grand glacier], Humain [Tribus d’Uthgardt], Minotaure [Outreterre (Labyrinthe)], Ogrillon [Vaasie], Orogue [Mer de Lune], Orque des montagnes [Mer de Lune], Orque des montagnes [Vaasie], Torve [Outreterre (Reeshov)]</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d’un bonus de +2 aux tests d’Escalade et Saut. Il ne tient pas compte des malus découlant de déplacements contrariés quand il évolue sur une pente glacée ou raide. Si la surface est à la fois glacée et raide, chaque case de mouvement coûte deux cases de déplacement au lieu de huit</p>
<p><strong>Normal.</strong> Un personnage qui progresse sur une surface glacée ou raide compte chaque case de mouvement comme deux cases de déplacement.</p>', 'Le personnage est habitué à combattre sur des pentes raides et autres surfaces traîtresses.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Pied sûr' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Porteur du magefeu épique', 8, '<p><strong>Conditions.</strong> Degré de maîtrise de 20 en Concentration, Endurance, Porteur du magefeu</p>
<p><strong>Avantage.</strong> Pour ce qui est de fixer la limite de niveaux d''énergie magefeu que le personnage est en mesure de stocker, considérez que sa valeur de Constitution bénéficie d''un bonus de +4.</p>
<p><strong>Normal.</strong> Sans ce don, la limite de niveaux d''énergie magefeu que le personnage est en mesure de stocker est égale à sa valeur de Constitution.</p>
<p><strong>Spécial.</strong> Il est possible de choisir ce don plusieurs fois. Chaque fois que vous le prenez, la limite de niveaux d''énergie magefeu que le personnage est en mesure de stocker augmente de +4</p>', 'Le personnage peut stocker davantage de niveaux d''énergie magefeu que la normale', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Porteur du magefeu épique' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Préparation profane', 1, '<p><strong>Condition.</strong> Faculté de lancer des sorts de magie profane spontanés</p>
<p><strong>Avantage.</strong> Chaque jour, le personnage peut mobiliser un ou plusieurs emplacements de sort pour préparer des sorts qu’il connaît. (En général, c’est pour leur appliquer des dons de métamagie.) Ensuite, il peut lancer le sort concerné au prix d’une action simple, même s’il l’accompagne de dons de métamagie. L’emplacement de sort mobilisé doit correspondre au niveau du sort choisi Une fois le sort préparé, le personnage ne peut plus rien faire de son emplacement de sort tant qu’il ne l’a pas jeté.</p>
<p><strong>Normal.</strong> Un ensorceleur ou un barde qui applique un don de métamagie à un sort doit entreprendre une action complexe et non une action simple.</p>', 'Le personnage est capable de préparer un sort de magie profane à l’avance, comme le font les magiciens. Dans ce cas, il n’a pas besoin de temps supplémentaire pour appliquer des dons de métamagie au sort.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Préparation profane' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Prodige magique', 1, '<p><strong>Avantage.</strong> Lorsque le personnage détermine ses sorts en bonus, considérez que sa caractéristique primaire (Charisme pour les bardes et ensorceleurs. Intelligence pour les magiciens) bénéficie d’un bonus de +2.</p>
<p><strong>Spécial.</strong> Il est possible de choisir ce don plusieurs fois. Il s’applique à chaque fois à une valeur de caractéristique différente. Enfin, un personnage peut le prendre même s’il ne possède pas encore de niveau dans la classe de jeteur de sorts attenante.</p>
<p>On ne peut choisir ce don qu’au niveau 1.</p>', 'Le personnage est particulièrement doué en magie.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Prodige magique' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Racé', 10, '<p><strong>Condition.</strong> Boogin[Outreterre (Nord-Terre)], Centaure [Plateau de Thay], Cornu [Val Perdu], Demi-orque [Vaasie], Drow [Drow de Cormanthor], Drow [Menzoberranyr], Drow wyrmprofond [Drow de Cormanthor], Drow wyrmprofond [Menzoberranyr], Elfe aquatique [Karpri], Elfe aquatique [Mer extérieure], Elfe aquatique [Mer intérieure], Fey''ri [Vallée du Delimbiyr], Furte [Arntombe], Gnoll [Plateau de Thay], Halfelin d''Anadia [Polarat du Sud], Halfelin sagespectre [Bois de Chontal], Homme-lézard [Rethild], Humain [Iles Nélanthères], Humain [Les Vaux], Humain [Lunargent], Humain [Swagdar], Humain [Téthyr], Métissoïde [Île du Faucon], Nain d''écu [Outreterre (Griffe terre)], Orogue [Outreterre (Nord-Terre)], Orque des montagnes [Outreterre (Nord-Terre)], Orque des montagnes [Vaasie], Piquedos [Val Perdu], Tanarukk [Outreterre (Nord-Terre)], Torve [Outreterre (Reeshov)], Vasharan [Téthyr], Voltigeur [Val Perdu]</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d’un bonus de +2 aux tests d’initiative et de Détection. Il ne saurait être secoué et ignore donc les effets de cet état préjudiciable. Cependant, il peut être effrayé ou paniqué.</p>', 'Le personnage sait ce que signifie le fait de combattre pour sauver sa peau. Sa vivacité d’esprit et ses réflexes physiques prennent tout leur sens lorsque ses ennemis dégainent leurs armes ou lancent des sorts meurtriers.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Racé' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Rapide et silencieux', 10, '<p><strong>Condition.</strong> Demi-orque[Nord], Drow [Drow de Cormanthor], Drow wyrmprofond [Drow de Cormanthor], Elfe des bois [Wealdath], Elfe sauvage [Val brumeux], Elfe sauvage [Wealdath], Feuneuvien [Pics enflammés], Furte [Arntombe], Furte [Shanatar l’Ancienne], Gobelin [Montagnes de Viteterre], Gobelours [Montagnes de Viteterre], Halfelin pied-léger [Nord], Halfelin sagespectre [Bois de Chontal], Hobgobelin [Montagnes de Viteterre], Humain [Shanatar l’Ancienne], Humain [Tribus d’Uthgardt], Métissoïde [Île du Faucon], Orogue [Nord], Orque des montagnes [Nord], Orque sangelé [Nord], Tanarukk [Nord], Wemic [Shaar]</p>
<p><strong>Avantage.</strong> Le personnage peut évoluer à la totalité de sa vitesse de déplacement et utiliser les compétences Déplacement silencieux ou Discrétion sans le moindre malus.</p>
<p><strong>Normal.</strong> Un personnage qui évolue à plus de la moitié de sa vitesse de déplacement subit un malus de -5 aux tests de Déplacement silencieux et Discrétion.</p>', 'Le personnage compte les ombres parmi ses amis et son pas est plus léger que celui d’un chat.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Rapide et silencieux' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Résistance au poison', 10, '<p><strong>Condition.</strong> Demi-orque[Mer de Lune], Demi-orque [Nord], Furte [Shanatar l’Ancienne], Gobelin [Montagnes de Viteterre], Gobelours [Montagnes de Viteterre], Hobgobelin [Montagnes de Viteterre], Homme-lézard [Rethild], Humain [Dambrath], Humain [Lapaliiya], Humain [Shanatar l’Ancienne], Nain gris [Outreterre (Nord-Terre)], Ogrillon [Nord], Orogue [Mer de Lune], Orogue [Nord], Orque des montagnes [Mer de Lune], Orque des montagnes [Nord], Orque sangelé [Nord], Tanarukk [Nord]</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d’un bonus de +4 aux jets de Vigueur contre le poison.</p>', 'Le personnage s’est habitué à de nombreuses substances mortelles en s’y exposant avec précaution ou tout simplement parce que son environnement est particulièrement hostile. Il est donc capable de résister à des poisons qui tueraient un cheval.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Résistance au poison' AND do_res_id = 63 AND do_ruleset_var_id = 1);

UPDATE dd_dons SET do_texte = '<p><strong>Condition.</strong> Humain[Bief de Vilhon], Humain [Chult], Humain [Contrées du Mitan Occidentale], Humain [Lac de Vapeur], Humain [Lapaliiya], Humain [Samarach], Humain [Tharsult], Humain [Thindol]</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d’un bonus de +2 aux jets de Réflexes et d’un bonus de +2 aux jets de Vigueur contre le poison.</p>
<p><strong>Spécial.</strong> Ce don compte comme le don Réflexes surhumains pour ce qui est de satisfaire à des conditions ou prérequis et ne se cumule pas avec ce dernier.</p>
<p><em>Ce don figurait déjà dans le supplément « Les Royaumes Oubliés ».</em></p>', do_resume = COALESCE('Le sang des yuan-tis coule dans les veines du personnage. Nul signe extérieur ne trahit son héritage, mais il n’est pas entièrement humain.', do_resume), do_res_id = 63 WHERE do_id = 173 AND do_res_id = 40;

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Sang magique', 10, '<p><strong>Condition.</strong> Aasimar[Mulhorande], Aasimar [Unther], Drow [Menzoberranyr], Drow wyrmprofond [Menzoberranyr], Fey''ri [Vallée du Delimbiyr], Genasi d''air [Calimshan], Genasi de feu [Calimshan], Genasi de feu [Unther], Genasi de terre [Mulhorande], Gnome des profondeurs [Outreterre (Nord-Terre)], Gnome des roches [Grand-Val], Gnome des roches [Thesk], Gnomes des forêts [Grand-Val], Homme-esprit des montagnes [Cendrane], Homme-esprit des rivières [Cendrane], Kir-lanan [Collines Lointaines], Nain gris [Outreterre (Noires contrées)], Tieffelin [Mulhorande], Tieffelin [Unther], Urdunnir [Oldonnar], Zénythri [Calimshan], Zénythri [Mulhorande]</p>
<p><strong>Avantage.</strong> Le personnage peut utiliser ses pouvoirs magiques raciaux plus souvent que la norme. En effet, les pouvoirs auxquels il a normalement recours 1 fois par jour sont désormais utilisables 3 fois par jour.</p>', 'Le personnage a le chic pour tirer le meilleur parti de ses facultés magiques innées. Il peut donc y avoir recours plus souvent que les autres représentants de sa race.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Sang magique' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Science de la métamagie coopérative', 8, '<p><strong>Conditions.</strong> Degré de maîtrise de 30 en Art de la magie, Incantation rapide, Incantation silencieuse, Incantation statique, Aptitude de classe de magie coopérative.</p>
<p><strong>Avantage.</strong> Le personnage peut user de métamagie coopérative pour appliquer Incantation rapide, Incantation silencieuse ou Incantation statique au sort de l''un de ses alliés. S''il s''agit d''Incantation rapide, l''action du personnage et celle du lanceur de sorts sont des actions libres. Le personnage n''en doit pas moins préparer une action pour utiliser ce pouvoir au moment de l''incantation de son allié, mais il peut aussi préparer une action simple différente.</p>
<p>De plus, le personnage peut user de magie coopérative deux fois supplémentaires chaque jour.</p>
<p><strong>Normal.</strong> Sans ce don, le personnage.ne peut pas user de métamagie coopérative pour appliquer Incantation rapide, Incantation silencieuse ou Incantation statique au sort d''un allié.</p>', 'Le personnage peut bonifier le sort d''un allié au moment de l''incantation.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Science de la métamagie coopérative' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Signature magique', 1, '<p><strong>Condition.</strong> Niveau 1 de lanceur de sorts profanes</p>
<p><strong>Avantage.</strong> En raison de l’apparence inhabituelle que prennent les sorts du personnage, le DD des tests d’Art de la magie visant à identifier ceux qu’il jette augmente de +4. De plus, il peut sélectionner un sort connu par niveau de sort. Il s’agit de sorts " thématiques " qu’il lance avec un bonus de +1 au niveau de lanceur de sorts. Chaque fois qu’il accède à un nouveau niveau de sort, le personnage a droit à un sort thématique de plus (sans qu’il lui soit nécessaire de reprendre ce don).</p>
<p>Tous les thèmes sont possibles tant qu’on peut en faire une description visuelle. Par exemple, le thème peut être " électricité ", " sphères " ou " crânes hurlants ". Si le personnage choisit le thème des sphères, ses projectiles magiques prendront la forme de boules de lumière incandescentes et les monstres qu’il convoque émergeront de mystérieux globes aux couleurs de l’arc-en-ciel. Si le thème est " électricité ", ses sorts de rapidité se manifesteront sous la forme d’étincelles vert vif sautant d’allié en allié.</p>
<p>Il est impossible de profiter de ce don pour rendre les manifestations magiques invisibles ou pour changer le type de dégâts infligés, quelle que soit l’apparence des sorts.</p>', 'Les sorts du personnage se manifestent accompagnés d’une apparence ou d’un thème précis.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Signature magique' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Sort de signature', 1, '<p><strong>Condition.</strong> Maîtrise des sorts</p>
<p><strong>Avantage.</strong> Chaque fois que vous prenez ce don, choisissez un sort associé au don Maîtrise des sorts. Désormais, vôtre personnage peut convertir des sorts de magie profane du niveau du sort maîtrisé (ou plus élevé) préparés en ce sort de signature, tout comme un prêtre bon est capable, spontanément, de convertir des sorts préparés en sorts de soins.</p>
<p><strong>Spécial.</strong> Ce don peut être choisi plusieurs fois, mais ses effets ne se cumulent pas. Chaque fois que vous le prenez, il s’applique à un nouveau sort maîtrisé.</p>', 'Le personnage connaît tellement bien un sort précis qu’il peut convertir des sorts préparés en ce sort.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Sort de signature' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Sort inné', 2, '<p><strong>Conditions.</strong> Incantation rapide, Incantation silencieuse, Incantation statique</p>
<p><strong>Avantage.</strong> Choisissez un sort que votre personnage est en mesure de lancer. Il peut désormais jeter ce sort à volonté, comme s''il s''agissait d''un pouvoir magique, 1 fois par round. Un emplacement de sort de huit niveaux de plus que son niveau réel est à jamais mobilisé pour alimenter ce pouvoir. Si le sort inné nécessite un sacrifice en PX, il doit être acquitté à chaque fois que le pouvoir magique est employé. Si le sort inné a une composante de type focaliseur, celle-ci est également nécessaire pour activer le pouvoir magique. Enfin, si le sort inné nécessite une composante matérielle pour laquelle est exprimée une valeur en po, il faut utiliser un objet valant 50 fois ce coût au titre de focaliseur, objet indispensable pour utiliser le pouvoir magique. Comme un sort inné est un pouvoir magique et pas un véritable sort, un prêtre ne peut le convertir en un sort de soins ou de blessure. De plus, un personnage qui perd la faculté de lancer des sorts du niveau mobilisé pour alimenter ce pouvoir ne peut plus en user.</p>
<p><strong>Spécial.</strong> Ce don peut être choisi plusieurs fois, en prenant un sort différent à chaque reprise. Les coûts en emplacements de sort, focaliseur et composantes matérielles doivent être acquittés pour chaque son inné choisi.</p>', 'Le personnage maîtrise un sort si parfaitement qu''il peut désormais l''utiliser comme s''il s''agissait d''un pouvoir magique.', 67, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Sort inné' AND do_res_id = 67 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Spécialisation martiale de prédilection', 8, '<p><strong>Conditions.</strong> Arme de prédilection (du dieu concerné), Prouesse épique, Accès au domaine de la Guerre</p>
<p><strong>Normal.</strong> Le personnage bénéficie d''un bonus de +2 aux jets de dégâts quand il manie l''arme de prédilection de son dieu.</p>', 'Le personnage inflige davantage.de dégâts quand il manie l''arme de prédilection de son dieu,', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Spécialisation martiale de prédilection' AND do_res_id = 63 AND do_ruleset_var_id = 1);

UPDATE dd_dons SET do_texte = '<p><strong>Condition.</strong> Avariel[Aire des aigles des neiges], Demi-elfe de lune [Lunargent], Elfe de lune [Lunargent], Elfe des bois [Lunargent], Genasi d''air [Calimshan], Genasi d''air [Thay], Genasi d''eau [Thay], Genasi de feu [Calimshan], Genasi de feu [Thay], Genasi de terre [Thay], Homme-esprit des montagnes [Cendrane], Homme-esprit des rivières [Cendrane], Humain [Calimshan], Humain [Expatrié shou], Humain [Mulhorande], Humain [Thay], Tieffelin [Thay], Zénythri [Calimshan]</p>
<p><strong>Avantage.</strong> Au niveau 1, le personnage peut utiliser son modificateur d’Intelligence ou de Charisme (au choix) à la place de son modificateur de Constitution pour déterminer ses points de vie supplémentaires. Aux niveaux suivants, le modificateur de Constitution s’applique. De plus, il gagne 1 point de vie supplémentaire à chaque fois qu’il apprend un don de métamagie. Enfin, s’il est en mesure de jeter des sorts profanes, il bénéficie d’un bonus d’intuition de +1 à la CA.</p>
<p><em>Ce don figurait déjà dans le supplément « Les Royaumes Oubliés ».</em></p>', do_resume = COALESCE('Les esthètes et les mystiques de la région natale du personnage apprennent à dépasser la fragilité de leur corps grâce à l’inébranlable puissance de leur esprit.', do_resume), do_res_id = 63 WHERE do_id = 187 AND do_res_id = 40;

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Surineur', 10, '<p><strong>Condition.</strong> Aasimar[Chessenta], Demi-elfe aquatique [Cote des dragons], Demi-géant [Anauroch], Genasi d''eau [Chessenta], Gobelin [Montagnes de Viteterre], Gobelours [Montagnes de Viteterre], Halfelin sagespectre [Vallée de Channath], Halfelin vaillant [Vallée de Channath], Hobgobelin [Montagnes de Viteterre], Humain [Anauroch], Humain [Cote des épées], Humain [Dambrath], Humain [Lac de Vapeur], Orogue [Thesk], Orque des montagnes [Thesk], Orque gris [Thesk]</p>
<p><strong>Avantage.</strong> En situation de lutte, le personnage peut utiliser une arme légère pour frapper son adversaire sans subir de malus au jet d’attaque. De plus, il ne lui est pas nécessaire de réussir un test de lutte pour dégainer une arme légère, mais il lui faut entreprendre une action de mouvement. Si son bonus de base à l’attaque est supérieur ou égal à +6, il peut effectuer une attaque à outrance à l’aide de son arme légère tout en poursuivant la lutte, dû moins s’il a cette arme en main.</p>
<p><strong>Normal.</strong> En situation de lutte, un personnage subit un malus de -4 aux jets d’attaque quand il tente de frapper son adversaire à l’aide d’une arme légère, De plus, il doit réussir un test de lutte pour dégainer son arme et il ne peut porter d’attaque à outrance durant ce même round.</p>', 'En situation de lutte, le personnage se sert de ses armes sans difficulté.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Surineur' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Survivant', 10, '<p><strong>Condition.</strong> Cornu[Val Perdu], Demi-Drow [Dambrath], Demi-géant [Anauroch], Elfe aquatique [Mer extérieure], Elfe sauvage [Bois de Chontal], Feuneuvien [Pics enflammés], Gnome des roches [Karpri], Gobelin [Chult], Gulgar [Montagne du Levant], Halfelin d''Anadia [Polarat du Nord], Halfelin d''Anadia [Polarat du Sud], Humain [Anauroch], Humain [Chult], Humain [Grand glacier], Humain [Marches du désert], Humain [Narfell], Humain [Shaar], Killoren [Terres de la Horde], Kuo-Toa [Outreterre (Sloopdilmonpolop)], Minotaure [Outreterre (Labyrinthe)], Nain d''écu [Grand glacier], Nain polaire [Grand glacier], Nain sauvage [Chult], Orcam [Mer des glaces flottantes], Piquedos [Val Perdu], Slyth [OutreTerre (Fluvilnistra)], Vasharan [Téthyr], Voltigeur [Val Perdu]</p>
<p><strong>Avantage.</strong> Le personnage bénéficie d’un bonus de +1 aux jets de Vigueur et d’un bonus de +2 aux tests de Survie.</p>', 'Le peuple du personnage vit dans des régions que d’autres trouvent inhospitalières. Le personnage connaît nombre des secrets de la nature.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Survivant' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Tatouage focaliseur', 10, '<p><strong>Conditions.</strong> Genasi d''air[Thay], Genasi d''eau [Thay], Genasi de feu [Thay], Genasi de terre [Thay], Humain [Thay], Tieffelin [Thay], Être spécialisé dans une école de magie</p>
<p><strong>Avantage.</strong> Ajoutez +1 au DD de sauvegarde des sorts de l’école de prédilection du personnage. Ce dernier bénéficie d’un bonus de +1 aux tests de niveau de lanceur de sorts visant à passer outre la résistance à la magie de la cible lorsqu’il lance un sort de cette école. Enfin, il peut participer à la magie de cercle des Magiciens Rouges.</p>', 'Le personnage porte les puissants tatouages magiques des Magiciens Rouges de Thay.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Tatouage focaliseur' AND do_res_id = 63 AND do_ruleset_var_id = 1);

INSERT INTO dd_dons (do_nom, do_dado_id, do_texte, do_resume, do_res_id, do_public, do_visible, do_ruleset_var_id, do_page_source, do_guerrier)
SELECT 'Traqueur', 10, '<p><strong>Condition.</strong> Demi-elfe aquatique[Cote des dragons], Gobelin [Chult], Halfelin pied-léger [Nord], Humain [Chult], Humain [Cormyr], Humain [Impiltur], Humain [Mer de Lune], Humain [Nord], Humain [Samarach], Humain [Thindol], Nain d''écu [Epine dorsale du monde], Nain d''écu [Montagnes Galènes], Nain polaire [Epine dorsale du monde], Urdunnir [Epine dorsale du monde]</p>
<p><strong>Avantage.</strong> Le personnage acquiert un ennemi juré. Cet avantage fonctionne sur le même principe que l’aptitude de rôdeur du même nom, si ce n’est que le type exact de créature dépend de sa région natale.</p>
<p><strong>Spécial.</strong> Si le personnage est un rôdeur pourvu d’un ennemi juré correspondant à celui du don, les bonus se cumulent.</p>', 'Dans les contrées menacées par de féroces pillards, nombre de guerriers apprennent à combattre des créatures précises. Le personnage est donc capable de les combattre avec une redoutable efficacité.', 63, 0, 1, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_dons WHERE do_nom = 'Traqueur' AND do_res_id = 63 AND do_ruleset_var_id = 1);
