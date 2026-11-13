-- sql/2026-11-09_sp-jf6a_sorts_mdjf_corriges.sql
-- SP-JF6a — Correction des sorts du Manuel des Joueurs de Faerûn déjà présents (champs de la fiche, texte, niveaux)
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
  so_composante = 'un petit anneau en verre et un bout de fourrure animale',
  so_portee = 'personnelle ; voir description',
  so_zone_effet = 'deux éclairs/round ou huit éclairs d''un coup',
  so_duree_incantation = '1 round entier',
  so_duree_sort = '1 round/2 niveaux ou instantanée ; voir description',
  so_jet_sauvegarde = 'Réflexes, 1/2 dégâts ; voir description',
  so_resistance = 'Oui',
  so_description = '<p>Ce sort invoque un anneau de foudre pâle et crépitant qui tourne autour du mage à hauteur de la poitrine. L''anneau- se déplace avec lui et n''entrave en rien ses incantations et attaques. Du reste, il ne gêne pas davantage ses adversaires. Tant que le sort est en place, le mage bénéficie d''une résistance à l''électricité (20). À chaque round, au tour de jeu du mage, le sort génère deux éclairs (comme le sort du même nom, niveau 5 de lanceur de sorts) dans la direction de son choix. Chacun peut viser une cible différente. Une créature frappée par un tel éclair a droit à un jet de Réflexes pour réduire les dégâts de moitié. Le DD de sauvegarde est calculé comme pour un sort de 8e niveau, même si chaque éclair reproduit les effets d''un sort de 3e niveau.</p>
<p>Mais le mage peut également faire le choix de libérer toute la puissance de Vanneau de foudre d''un coup. Au terme de l''incantation, huit éclairs partent dans toutes les directions. Dans ce cas, la durée du sort est instantanée. Le choix de stocker les éclairs ou de les libérer d''un coup doit être fait lors de l''incantation.</p>'
WHERE so_nom = 'Anneau de foudre' AND so_res_id = 63;

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 8 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Anneau de foudre' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 8 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Anneau de foudre' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT s.so_id, 8, d.do_id FROM dd_sorts s JOIN dd_domaines d ON d.do_nom = 'Foudre'
WHERE s.so_nom = 'Anneau de foudre' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_so_id = s.so_id AND x.sd_do_id = d.do_id);

UPDATE dd_sorts SET so_co_id = 5,
  so_vocal = 1,
  so_gestuel = 1,
  so_materiel = 0,
  so_focalisateur = 0,
  so_focalisateur_divin = 0,
  so_portee = 'contact',
  so_cible = 'créature vivante touchée',
  so_duree_incantation = '1 action simple',
  so_duree_sort = '1 round',
  so_jet_sauvegarde = 'Vigueur, annule (inoffensif)',
  so_resistance = 'Oui (inoffensif)',
  so_description = '<p>La créature touchée bénéficie d''une réduction des dégâts (15/-) pendant 1 round.</p>
<p>Seul un initié de Lathandre peut lancer ce sort.</p>'
WHERE so_nom = 'Bouclier de Lathandre' AND so_res_id = 63;

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Bouclier de Lathandre' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

UPDATE dd_sorts SET so_co_id = 5,
  so_description = '<p>Ce sort fonctionne sur le même principe que Bouclier de Lathandre, si ce n''est que la cible bénéficie d''une réduction des dégâts (20/-), d''une immunité contre l''énergie négative et l''absorption d''énergie, et d''une résistance à l''acide (10), à l''électricité (10), au feu (10), au froid (10) et au son (10).</p>
<p>Seul un initié de Lathandre peut lancer ce sort.</p>'
WHERE so_nom = 'Bouclier de Lathandre suprême' AND so_res_id = 63;

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 7 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Bouclier de Lathandre suprême' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

UPDATE dd_sorts SET so_co_id = 1,
  so_registre = 'électricité',
  so_vocal = 1,
  so_gestuel = 1,
  so_materiel = 1,
  so_focalisateur = 0,
  so_focalisateur_divin = 0,
  so_composante = 'une poignée de boulettes de cuivre et de fer',
  so_portee = 'moyenne (30 m + 3 m/niveau)',
  so_zone_effet = '1 boule de foudre/2 niveaux',
  so_duree_incantation = '1 action simple',
  so_duree_sort = '1 round/niveau',
  so_jet_sauvegarde = 'Réflexes, 1/2 dégâts',
  so_resistance = 'Oui',
  so_description = '<p>Le mage crée une boule d''électricité de 90 centimètres de diamètre par tranche de 2 niveaux (jusqu''à un maximum de huit boules). Chacune diffuse autant de lumière qu''une bougie.</p>
<p>Au moment de créer les boules de foudre, le mage les programme mentalement pour qu''elles se déplacent comme bon lui semble. Une boule se déplace à la vitesse de 30 mètres par round et vole avec une manœuvrabilité parfaite. Lorsqu''une boule de foudre frappe une créature, elle s''arrête et ne bouge plus jusqu''à la fin du sort. Elle est dissipée si la distance la séparant du mage excède la portée du sort Une boule « voit » comme un humain dans les conditions de luminosité de l''endroit (sachant qu''elle produit un minimum de lumière).</p>
<p>Par exemple, il est possible de programmer une boule de foudre pour qu''elle longe le mur de gauche d''un couloir et qu''elle frappe la première créature qu''elle « voit », d''en programmer une autre pour qu''elle se comporte de la même manière en longeant le mur de droite, et de demander aux autres de les suivre en restant à 1,50 mètre derrière et en adoptant une formation hémisphérique. Les deux premières tourneront au premier angle pour continuer de longer les murs, même si elles doivent pour cela sortir du champ de vision du jeteur de sorts, puis frapperont la première créature qu''elles « verront », ce qui mettra fin à leur programme, les immobilisant du même coup dans la case de leur cible. Le fait de programmer les boules constitue une action libre durant le round où le sort est lancé, et une action de mouvement par la suite.</p>
<p>Toute créature frappée par une boule de foudre (ou qui en touche une à l''aide d''une arme naturelle ou de corps a corps) subit 2d6 points de dégâts d''électricité (jet de Réflexes, 1/2 dégâts) Une créature qui entre en contact avec plusieurs boules de foudre subit les dégâts .de chacune et bénéficie d''autant de jets de sauvegarde. Une créature dotée d''une résistance à la magie effectue un test de RM par boule de foudre, chaque succès remporté signifiant que la magie n''a pu la blesser.</p>'
WHERE so_nom = 'Boules de foudre' AND so_res_id = 63;

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Boules de foudre' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Boules de foudre' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT s.so_id, 5, d.do_id FROM dd_sorts s JOIN dd_domaines d ON d.do_nom = 'Foudre'
WHERE s.so_nom = 'Boules de foudre' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_so_id = s.so_id AND x.sd_do_id = d.do_id);

UPDATE dd_sorts SET so_co_id = 6,
  so_branche = 'Création',
  so_vocal = 1,
  so_gestuel = 1,
  so_materiel = 1,
  so_focalisateur = 1,
  so_focalisateur_divin = 0,
  so_composante = 'encres à tatouages déclinées en différentes couleurs ; Focalisateur : aiguilles à tatouages',
  so_portee = 'contact',
  so_cible = 'créature touchée',
  so_duree_incantation = '10 minutes',
  so_duree_sort = '1 jour',
  so_jet_sauvegarde = 'aucun',
  so_resistance = 'Oui (inoffensif)',
  so_description = '<p>Comme son nom l''indique, ce sort permet de créer un tatouage magique. Le lanceur détermine le type exact de tatouage, sans oublier que ce choix est restreint par son niveau de jeteur de sorts. Le concepteur d''un tatouage magique doit disposer d''un minimum de talent artistique pour faire le croquis du tatouage désiré - au moins 1 degré de maîtrise en Artisanat (dessin), Artisanat (peinture). Artisanat (calligraphie) ou quelque autre compétence d''Artisanat. La création d''un tatouage magique passe par un jet d''Artisanat. Comme vous le noterez ci-dessous, le DD varie suivant le type de tatouage. Un jeteur de sorts de niveau 3 à 6 est capable de créer les tatouages suivants (DD 10) :</p>
<ul><li>Bonus de résistance de +2 à tous les jets de sauvegarde d''un seul type (Réflexes, Vigueur ou Volonté).</li><li>Bonus de chance de +1 à tous les jets d''attaque.</li><li>Bonus de parade de +1 à la CA.</li></ul>
<p>Un jeteur de sorti de niveau 7 à 12 est capable de créer les tatouages ci-dessus (DD 10) et les suivants (DD 15) :</p>
<ul><li>Bonus de résistance de +2 à tous les jets de sauvegarde.</li><li>Bonus d''aptitude de +2 à tous les jets d''attaque.</li><li>La faculté de se souvenir d''un sort de niveau 0, 1 ou 2 précédemment lancé (comme si le sujet se servait d''une perle de thaumaturgie). Le personnage choisit le niveau du sort.</li></ul>
<p>Un jeteur de sorts de niveau 13 et plus est capable de créer les tatouages ci-dessus (DD 15) et les suivants (DD 20) :</p>
<ul><li>Résistance à la magie de 10 + 1 par tranche de 6 niveaux du jeteur de sorts</li><li>Bonus d''altération de +2 à une caractéristique au choix.</li><li>+1 niveau de lanceur de sorts. Si cela augmente le niveau effectif du sujet, cela ne change en rien le nombre de sorts qu''il est capable de lancer chaque jour. Un magicien de niveau 11 bénéficiant de ce pouvoir lance ses sorts comme un magicien de niveau 12 en termes de portée, de zone d''effet, etc. Cependant, son tatouage ne lui confère aucun sort supplémentaire.</li></ul>
<p>Une même créature ne peut avoir que trois tatouages magiques à la fois. Une fois celle-ci dotée de ses trois tatouages, tout effort visant à lui en faire un nouveau est voué à l''échec. Un sort d''effacement couronné de succès efface un seul tatouage magique. Une dissipation de ta magie couronnée de succès peut anéantir plusieurs tatouages si elle vise la créature les portant.</p>'
WHERE so_nom = 'Création de tatouage magique' AND so_res_id = 63;

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Création de tatouage magique' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 2 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Création de tatouage magique' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

UPDATE dd_sorts SET so_co_id = 4,
  so_zone_effet = 'matrice retenant 3 sorts',
  so_description = '<p>Ce sort fonctionne sur le même principe que Matrice de la Simbule, si ce n''est que le mage peut y stocker trois sorts de 3e niveau ou moins. En outre, il subit 3d6 points de dégâts lors de l''incantation (et non 1d6). La matrice se referme au bout de 3 rounds. Ensuite, aucun sort ne peut y être placé, même si elle n''est pas pleine.</p>
<p>Le mage peut également désigner un sort ou une séquence de sorts de cette matrice censés se déclencher dans les conditions fixées lors de l''incantation. Cet effet fonctionne sur le même principe que prévoyance. Le sort (ou la séquence de sorts) doit être d''un type susceptible d''affecter le mage, comme lévitation on feuille morte. Les conditions censées déclencher le ou les sorts désirés doivent être claires, mais elles peuvent être d''ordre général. Dans tous les cas, le déclencheur de la Simbule active le sort (ou la séquence de sorts) désigné dès que les conditions sont remplies. Le mage ne peut alors pas décider de retenir le ou les sorts.</p>'
WHERE so_nom = 'Déclencheur de la Simbule' AND so_res_id = 63;

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 9 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Déclencheur de la Simbule' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 9 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Déclencheur de la Simbule' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

UPDATE dd_sorts SET so_co_id = 5,
  so_registre = 'Bien',
  so_vocal = 1,
  so_gestuel = 1,
  so_materiel = 0,
  so_focalisateur = 0,
  so_focalisateur_divin = 1,
  so_portee = 'courte (7,50 m + 1,50 m/2 niveaux)',
  so_cible = '1 créature/5 niveaux',
  so_duree_incantation = '1 action simple',
  so_duree_sort = '1 round/niveau',
  so_jet_sauvegarde = 'aucun',
  so_resistance = 'Oui (inoffensif)',
  so_description = '<p>L''initié confère à une ou plusieurs créatures le pouvoir spécial de détruire les morts-vivants.</p>
<p>Tous les sujets jouissent de protection contre la mort. Ils bénéficient également d''un bonus de parade de +4 à la CA contre les attaques des morts-vivants et sont immunisés contre les attaques spéciales des morts-vivants qui infligent un affaiblissement temporaire pu une diminution permanente de caractéristique, ou qui inoculent un poison ou une maladie. Les sujets peuvent également effectuer des attaques à distance et au corps à corps contre les morts-vivants éthérés ou intangibles, comme s''ils disposaient d''armes spectrales. Enfin, ils passent outre la réduction des dégâts des morts-vivants.</p>'
WHERE so_nom = 'Eternel ennemi de la non-vie' AND so_res_id = 63;

UPDATE dd_sorts SET so_co_id = 5,
  so_vocal = 1,
  so_gestuel = 1,
  so_materiel = 0,
  so_focalisateur = 0,
  so_focalisateur_divin = 0,
  so_portee = 'courte (7,50 m + 1,50 m/2 niveaux)',
  so_zone_effet = 'une sphère absorbant la magie/niveau',
  so_duree_incantation = '1 action simple',
  so_duree_sort = '1 round/niveau',
  so_jet_sauvegarde = 'Volonté, annule (inoffensif)',
  so_resistance = 'Oui (inoffensif)',
  so_description = '<p>Le mage crée une sphère flottante et argentée par niveau de lanceur dé sorts, chacune de la taille de sa tête. Ces sphères tournent autour de lui et le protègent d''effets magiques. Au prix d''une action simple, il peut transmettre l''effet de ce sort (et donc l''ensemble des sphères) à une créature située à portée.</p>
<p>Chaque sphère peut absorber et annuler les sorts et pouvoirs magiques qui visent spécifiquement le sujet, quel que soit leur niveau. De son côté, le sujet peut décider d''absorber ou non un sort. (Cette option lui permet de profiter des sorts qui lui sont bénéfiques.) Les sorts de zone et les sorts qui ne visent pas de cible précise (comme main interposée de Bigby) ne sauraient être absorbés. Des lors qu''une sphère absorbe un sort ou un pouvoir magique, elle disparaît. Enfin, seuls les sorts et pouvoirs magiques de stature divine peuvent passer outre l''épuration resplendissante d''Elminster.</p>'
WHERE so_nom = 'Epuration resplendissante d’Elminster' AND so_res_id = 63;

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 9 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Epuration resplendissante d’Elminster' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 9 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Epuration resplendissante d’Elminster' AND s.so_res_id = 63
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
  so_duree_sort = '10 minutes/niveau',
  so_jet_sauvegarde = 'Vigueur, annule (inoffensif)',
  so_resistance = 'Oui (inoffensif)',
  so_description = '<p>Le druide prête des points de caractéristique à la cible.</p>
<p>Le druide subit un malus -4 dans la caractéristique de son choix et la cible bénéficie d''un bonus d''altération équivalent à la même caractéristique. Le druide n''a droit à aucun jet de sauvegarde pour éviter le malus, mais la cible peut effectuer un jet de Vigueur pour éviter le gain si tel est son souhait.</p>
<p>Si le druide jette ce sort une seconde fois dans l''heure qui suit, il subit 2d10 points de dégâts en plus de l''effet normal</p>'
WHERE so_nom = 'Equilibre naturel' AND so_res_id = 63;

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Druide' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Equilibre naturel' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

UPDATE dd_sorts SET so_co_id = 2,
  so_vocal = 1,
  so_gestuel = 1,
  so_materiel = 0,
  so_focalisateur = 0,
  so_focalisateur_divin = 0,
  so_portee = 'moyenne (30 m + 3 m/niveau)',
  so_cible = '1 créature consentante',
  so_duree_incantation = '1 action simple',
  so_duree_sort = '1 minute/niveau',
  so_jet_sauvegarde = 'aucun',
  so_resistance = 'Oui (inoffensif)',
  so_description = '<p>La cible de ce sort est immunisée contre les dégâts non-létaux,lès effets de charme et de ¦ coercition, et les attaques qui agissent expressément en infligeant de la douleur. De plus, elle est immunisée contre les effets provoquant les états préjudiciables suivants : hébété, épuisé, fatigué, nauséeux, fiévreux, chancelant et étourdi. La cible demeure consciente entre -1 et -9 points de vie et peut entreprendre, une seule et unique action par round quand elle se trouve dans cet état. Ces effets sont suspendus pendant toute la durée du sort s''ils frappaient déjà la cible au moment de l''incantation. (Le sujet se réveille donc s''il avait sombré dans l''inconscience). Lorsque le sort s''achève, tout effet précédemment suspendu par la magie (comme la fatigue, qui requiert normalement 8 heures de repos) reprend son cours. Les effets venant à expiration pendant la durée du sort ne reprennent pas à son terme.</p>
<p>Enfin, la cible jouit du don Endurance pendant toute la durée du sort.</p>
<p>Seul un initié d''Ilmater peut lancer ce sort.</p>'
WHERE so_nom = 'Faveur d''Ilmater' AND so_res_id = 63;

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Paladin' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Faveur d''Ilmater' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 4 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Faveur d''Ilmater' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

UPDATE dd_sorts SET so_co_id = 1,
  so_registre = 'lumière',
  so_vocal = 1,
  so_gestuel = 1,
  so_materiel = 0,
  so_focalisateur = 0,
  so_focalisateur_divin = 1,
  so_portee = 'courte (7,50 m + 1,50 m/2 niveaux)',
  so_zone_effet = 'rayonnement de 1,50 m de rayon',
  so_duree_incantation = '1 action simple',
  so_duree_sort = 'instantanée',
  so_jet_sauvegarde = 'Réflexes, partiel',
  so_resistance = 'Oui',
  so_description = '<p>L''initié crée une éblouissante explosion de lumière équivalente à la lumière naturelle du soleil. Les créatures vulnérables à la lumière et situées dans la zone sont aveuglées et subissent 4d6 points de dégâts. Les autres sont également aveuglées mais ne subissent que 2d6 points de dégâts. Un jet de Réflexes réussi annule l''aveuglement et réduit les dégâts de moitié.</p>
<p>Un mort-vivant pris dans la zone subit 1d6 points de dégâts par niveau de lanceur de sorts jusqu''à un maximum de 10d6). Là encore, un jet de Réflexes réussi annule l''aveuglement et réduit les dégâts de moitié. Les ultraviolets générés par le sort infligent également des dégâts aux thallophytes, moisissures, vases et mucus comme s''il s''agissait de mort-vivants.</p>
<p>Lever de soleil dissipe les sorts de ténèbres de 3e niveau ou moins actifs dans la zone d''effet.</p>
<p>Seul un initié de Lathandre peut lancer ce sort.</p>'
WHERE so_nom = 'Levé de soleil' AND so_res_id = 63;

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 3 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Levé de soleil' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

UPDATE dd_sorts SET so_co_id = 4,
  so_vocal = 1,
  so_gestuel = 1,
  so_materiel = 0,
  so_focalisateur = 1,
  so_focalisateur_divin = 0,
  so_composante = 'Focalisateur : un morceau d''ambre d''une valeur de 500 po',
  so_portee = 'personnelle',
  so_cible = 'le jeteur de sorts',
  so_zone_effet = 'matrice retenant un sort',
  so_duree_incantation = '1 action simple',
  so_duree_sort = '10 minutes/niveau (T)',
  so_description = '<p>Le mage prépare une matrice magique lui permettant de stocker l''un de ses sorts et de l''utiliser par la suite au prix d''une action libre. Dans le round suivant l''incantation de la matrice de la Simbule, le mage peut jeter un sort de 3e niveau ou moins et l''y stocker. La matrice se referme après 1 round, qu''elle abrite un sort ou non. On ne peut y emmagasiner que les sorts qu''il est possible d''altérer via le don Incantation rapide. On considère que le sort stocké est préparé. L''incantation de matrice de la Simbule inflige 1d6 points de dégâts au mage, qu''il n''est pas possible de soigner tant que la matrice existe.</p>
<p>Lorsque la matrice est active, le mage peut lancer le sort qu''elle renferme au prix d''une action libre. Une fois le sort de la matrice lancé, il en disparaît.</p>
<p>Une dissipation de la magie dissipant la matrice dissipe également le sort qui y est stocké. Une zone d''anti-magie interrompt la durée de la matrice mais n''en déclenche pas le sort (la matrice est de nouveau active lorsque le mage quitte la zone d''anti-magie). Si le mage meurt, le sort stocké et sa matrice sont dissipés sans causer le moindre effet.</p>'
WHERE so_nom = 'Matrice de la Simbule' AND so_res_id = 63;

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Matrice de la Simbule' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 5 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Matrice de la Simbule' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

UPDATE dd_sorts SET so_co_id = 5,
  so_vocal = 1,
  so_gestuel = 1,
  so_materiel = 0,
  so_focalisateur = 0,
  so_focalisateur_divin = 0,
  so_portee = 'contact',
  so_cible = 'créature touchée',
  so_duree_incantation = '1 action simple',
  so_duree_sort = '1 round/niveau',
  so_jet_sauvegarde = 'Vigueur, annule (inoffensif)',
  so_resistance = 'Oui (inoffensif)',
  so_description = '<p>La cible du sort luit d''un pâle éclat rosé dont l''intensité est égale à celle d''une bougie. Cette lueur confère au sujet un bonus de sainteté de +1 par niveau de lanceur de sorts (jusqu''à un maximum de +10) aux jets de sauvegarde contre les effets de douleur (comme doux rappel de Nybor) et de terreur. C''est également valable contre les effets rendant le sujet fiévreux ou nauséeux.</p>
<p>Seul un initié de Lathandre peut lancer ce sort.</p>'
WHERE so_nom = 'Rosemanteau' AND so_res_id = 63;

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 1 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Prêtre' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id = 1
WHERE s.so_nom = 'Rosemanteau' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

UPDATE dd_sorts SET so_co_id = 1,
  so_registre = 'acide',
  so_vocal = 1,
  so_gestuel = 1,
  so_materiel = 1,
  so_focalisateur = 0,
  so_focalisateur_divin = 0,
  so_composante = 'une flasque d''acide',
  so_portee = 'moyenne (30 m + 3 m/niveau)',
  so_zone_effet = 'cylindre (6 m de haut, 6 m de rayon)',
  so_duree_incantation = '1 action simple',
  so_duree_sort = 'instantanée',
  so_jet_sauvegarde = 'Réflexes, 1/2 dégâts',
  so_resistance = 'Oui',
  so_description = '<p>Une pluie acide s''abat sur les environs. Celle-ci inflige 1d8 points de dégâts d''acide par niveau de lanceur de sorts (jusqu''à un maximum de 15d8).</p>'
WHERE so_nom = 'Tempête acide' AND so_res_id = 63;

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 6 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Ensorceleur' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Tempête acide' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT s.so_id, c.cla_id, 6 FROM dd_sorts s JOIN dd_classes c ON c.cla_nom = 'Magicien' AND c.cla_ruleset_var_id = 1 AND c.cla_clt_id IN (1, 2)
WHERE s.so_nom = 'Tempête acide' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortclasse x WHERE x.sc_so_id = s.so_id AND x.sc_cla_id = c.cla_id);

INSERT INTO dd_sortdomaine (sd_so_id, sd_niveau, sd_do_id)
SELECT s.so_id, 7, d.do_id FROM dd_sorts s JOIN dd_domaines d ON d.do_nom = 'Acide'
WHERE s.so_nom = 'Tempête acide' AND s.so_res_id = 63
AND NOT EXISTS (SELECT 1 FROM dd_sortdomaine x WHERE x.sd_so_id = s.so_id AND x.sd_do_id = d.do_id);
