-- sql/2026-11-09_sp-jf4_objets_mdjf.sql
-- SP-JF4 — Objets magiques du Manuel des Joueurs de Faerûn : import des absents, correction des fiches MdJF existantes
-- (prix, NLS, catégorie, texte complet avec emplacement / aura / conditions de création).
-- Généré par tools/generer-sp-jf4-objets.php le 2026-11-09 depuis gemmaline.com. Rejouable. Pas de DELIMITER.

SET NAMES utf8mb4;


INSERT INTO dd_objets_magiques (om_nom, om_com_id, om_fom_id, om_prix, om_nls, om_bonus_equiv, om_description, om_harmonisation, om_rarete, om_visible, om_public, om_res_id, om_ruleset_var_id)
SELECT 'Annulus conflagros', 1, 2, 92340, 6, NULL, '<p>Cet anneau de cuivre ressemble à une boucle qu''aurait pu produire une flammèche, d''autant que les rubis et topazes dont il est serti semblent refléter les différentes couleurs du feu. Chaque annulus conflagros confère une résistance au feu (10) à son porteur et lui permet d''activer les pouvoirs suivants en prononçant le bon mot de commande.</p>
<ul><li>Pyrotechnie (à volonté)</li><li>Mains brûlantes (3 fois/jour)</li><li>Boule de feu (2 fois/jour)</li><li>Mur de feu (1 fois/jour)</li></ul>
<p><strong>Emplacement.</strong> Doigts</p>
<p><strong>Aura.</strong> Évocation [Feu] modérée (niveau 6 de lanceur de sorts)</p>
<p><strong>Création.</strong> Conditions : Création d’anneaux magiques, boule de feu, mains brûlantes, mur de feu, pyrotechnie, résistance aux énergies destructives</p>', 0, 0, 1, 0, 63, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_objets_magiques WHERE om_nom = 'Annulus conflagros' AND om_res_id = 63 AND om_ruleset_var_id = 1);

UPDATE dd_objets_magiques SET om_com_id = 2, om_prix = 314320, om_nls = 18, om_bonus_equiv = NULL, om_description = '<p>Propriété originelle du seigneur nycaloth Gaulguth, cette redoutable hache d''armes +2 vorpale est conçue pour une créature de taille G. Brise-cœur suinte d''un ichor verdâtre et nauséabond qui empêche les blessures qu''il inflige de guérir magiquement.</p>
<p>Ainsi, un personnage tentant de jeter un sort d''Invocation (guérison) sur une créature touchée par brise-cœur doit réussir un test de niveau de lanceur de sorts (DD 20), sans quoi le sort n''a aucun effet. Cet effet inhibant disparaît dès que la créature retrouve son total de points de vie normal (via repos et guérison naturelle ou soins magiques passant outre les propriétés de l''arme).</p>
<p><strong>Poids.</strong> 6 kilos</p>
<p><strong>Aura.</strong> Évocation puissante (niveau 18 de lanceur de sorts)</p>
<p><strong>Création.</strong> Conditions : Création d’armes et armures magiques, affûtage, cercle de mort, malédiction Coût. 157 320 po +12 560 PX</p>'
WHERE om_nom = 'Brise-coeur' AND om_res_id = 63 AND om_ruleset_var_id = 1;

UPDATE dd_objets_magiques SET om_com_id = 13, om_prix = 2500, om_nls = 9, om_bonus_equiv = NULL, om_description = '<p>Créée par un guerrier/magicien calishite dans le but de l''aider à combattre son rival Vycaena, cette cape vaporeuse de lin blanc est recouverte d''une peau tannée de bête éclipsante. Une fois par round, le porteur peut glisser la main dans les plis de cette cape et en sortir une arme qu''il y a stockée. La cape de l''arsenal de Najjar fonctionne sur le même principe qu''un sac sans fond, si ce n''est qu''elle n''abrite que 12,5 kilos de matériel inerte susceptible de tenir sous une cape de 1,80 mètre de long. La plupart des armes à deux mains n''y ont donc pas leur place, sauf s''il est possible de les plier. Par contre, on peut facilement y dissimuler des armes légères ou à une main et autres objets de taille comparable. Étant donné que la cape est conçue pour abriter des armes, il n''y a pas de risque de la « crever », comme c''est le cas pour un sac sans fond.</p>
<p><strong>Emplacement.</strong> Épaule</p>
<p><strong>Aura.</strong> Invocation modérée (niveau 9 de lanceur de sorts)</p>
<p><strong>Création.</strong> Conditions : Création d’objets merveilleux, coffre secret de Léomund</p>'
WHERE om_nom = 'Cape de l''arsenal de Najjar' AND om_res_id = 63 AND om_ruleset_var_id = 1;

INSERT INTO dd_objets_magiques (om_nom, om_com_id, om_fom_id, om_prix, om_nls, om_bonus_equiv, om_description, om_harmonisation, om_rarete, om_visible, om_public, om_res_id, om_ruleset_var_id)
SELECT 'Coeur de Tasmia', 13, 2, 127000, 7, NULL, '<p>Ce splendide bustier à col haut est lacé de soie noire et cousu de saphirs. I! fonctionne sur le même principe qu''un casque de l''homme-poisson et un anneau de liberté de mouvement. De plus, il prolonge l''espérance de vie de son porteur, doublant le nombre, d''années de chacune de ses catégories d''âge restantes, ainsi que de son âge maximal. Par exemple, un humain adulte qui porte le cœur de Tasmia atteindra l''âge mûr à 70 ans, le grand âge à 106 ans, l''âge vénérable à 140 ans et son âge maximal 2d20x2 ans après. Le cœur de Tasmia compte comme une chemise pour ce qui est de la limite au nombre d''objets magiques.</p>
<p><strong>Emplacement.</strong> Torse</p>
<p><strong>Aura.</strong> Transmutation modérée (niveau 7 de lanceur de sorts)</p>
<p><strong>Création.</strong> Conditions : Création d’objets merveilleux, ’ liberté de mouvement, -respiration aquatique, le créateur doit être de niveau 10 au moins</p>', 0, 0, 1, 0, 63, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_objets_magiques WHERE om_nom = 'Coeur de Tasmia' AND om_res_id = 63 AND om_ruleset_var_id = 1);

INSERT INTO dd_objets_magiques (om_nom, om_com_id, om_fom_id, om_prix, om_nls, om_bonus_equiv, om_description, om_harmonisation, om_rarete, om_visible, om_public, om_res_id, om_ruleset_var_id)
SELECT 'Couronne de renvoi', 13, 2, 113600, 10, NULL, '<p>Ce diadème en bronze serti d''agates exerce un pouvoir considérable sur les morts-vivants. Le porteur de la couronne peut renvoyer les morts-vivants comme un prêtre de niveau 10 et bénéficie d''un bonus de résistance de +2 aux jets de sauvegardé contre les sorts et pouvoirs magiques des morts-vivants. De plus, il est en permanence affecté par un sort d''invisibilité pour les morts-vivants. Bien que la couronne de renvoi ne soit pas maudite, ses propriétaires finissent généralement entre les griffes de morts-vivants contre lesquels elle est censée les protéger.</p>
<p><strong>Emplacement.</strong> Tête</p>
<p><strong>Aura.</strong> Abjuration modérée (niveau 10 de lanceur de sorts)</p>
<p><strong>Création.</strong> Conditions : Création.d’objets merveilleux, invisibilité pour les morts-vivants, résistance, le créateur doit être un prêtre de niveau 10 au moins</p>', 0, 0, 1, 0, 63, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_objets_magiques WHERE om_nom = 'Couronne de renvoi' AND om_res_id = 63 AND om_ruleset_var_id = 1);

UPDATE dd_objets_magiques SET om_com_id = 29, om_prix = 38500, om_nls = 13, om_bonus_equiv = NULL, om_description = '<p>Les. armes dotées de cette propriété sont parfois remises aux aventuriers ayant les faveurs de l''Église de Tymora. En général, chacune est créée avec 7 charges. A son tour de jeu, le porteur peut sacrifier 1 charge (action libre) pour effectuer une attaque supplémentaire avec l''arme. Il a également la possibilité de sacrifier 1 charge quand bon lui semble, mais pas plus de 1 fois par round, pour relancer un dé. Il peut le faire après avoir pris connaissance du jet original.</p>
<p><strong>Aura.</strong> Transmutation puissante (niveau 13 de lanceur de sorts)</p>
<p><strong>Création.</strong> Conditions : Création d’armes et armures magiques, souhait limité Coût. 14 000 po + 3 220 PX</p>'
WHERE om_nom = 'Destin' AND om_res_id = 63 AND om_ruleset_var_id = 1;

UPDATE dd_objets_magiques SET om_com_id = 29, om_prix = 6000, om_nls = 5, om_bonus_equiv = NULL, om_description = '<p>Une fois par jour, le porteur d''une arme de dissipation peut user de dissipation de la magie à cible contre une créature touchée (action libre). Le porteur peut recourir à cette propriété une fois le coup porté, mais la dissipation de la magie doit être utilisée au cours du round où l''arme a touché.</p>
<p><strong>Aura.</strong> Abjuration faible (niveau 5 de lanceur de sorts)</p>
<p><strong>Création.</strong> Conditions : Création d’armes et armures magiques, dissipation de la magie</p>'
WHERE om_nom = 'Dissipation' AND om_res_id = 63 AND om_ruleset_var_id = 1;

UPDATE dd_objets_magiques SET om_com_id = 29, om_prix = 79200, om_nls = 11, om_bonus_equiv = NULL, om_description = '<p>Trois fois par jour, le porteur d''une arme de dissipation suprême peut user de dissipation suprême à cible contre une créature touchée (action libre). Le porteur peut recourir à cette propriété une fois le coup porté, mais la dissipation suprême doit être utilisée au cours du round où l''arme a touché.</p>
<p><strong>Aura.</strong> Abjuration modérée (niveau 11 de lanceur de sorts)</p>
<p><strong>Création.</strong> Conditions : Création d’armes et armures magiques, dissipation suprême</p>'
WHERE om_nom = 'Dissipation suprême' AND om_res_id = 63 AND om_ruleset_var_id = 1;

INSERT INTO dd_objets_magiques (om_nom, om_com_id, om_fom_id, om_prix, om_nls, om_bonus_equiv, om_description, om_harmonisation, om_rarete, om_visible, om_public, om_res_id, om_ruleset_var_id)
SELECT 'Divergence', 16, 2, 117000, 13, NULL, '<p>Chacun de ces sceptres est ciselé de runes protectrices et surmonté d''une gemme. Le type de cette gemme dépend de la forme d''énergie destructive contre laquelle le sceptre a été conçu (une émeraude pour l''acide, une topaze pour l''électricité, un rubis pour le feu, un saphir pour le froid et un diamant pour le son). Quand un effet relevant du type d''énergie adéquat vise le porteur du tout point situé dans un rayon de 3 mètres de celui-ci, il a le droit de sacrifier 3 charges pour rediriger l''attaque en un point de son choix situé dans un rayon de 18 mètres (action libre). Un sort de zone doit être centré dans un rayon de 3 mètres du porteur pour que celui-ci puisse le rediriger. (En d''autres termes, une boule de feu jetée à 4,50 mètres ne saurait être redirigée, même si une partie de l''effet entre bel et bien dans un périmètre de 3 mètres du porteur.) De plus, le sceptre de divergence peut reproduire les effets d''un sort de lueur féerique. Ce pouvoir ne coûte aucune charge. Le sceptre de divergence a 50 charges au moment de sa création.</p>
<p><strong>Aura.</strong> Abjuration puissante (niveau 13 de lanceur de sorts)</p>
<p><strong>Création.</strong> Conditions : Création de sceptres magiques, lueur féerique, renvoi des sorts</p>', 0, 0, 1, 0, 63, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_objets_magiques WHERE om_nom = 'Divergence' AND om_res_id = 63 AND om_ruleset_var_id = 1);

UPDATE dd_objets_magiques SET om_com_id = 29, om_prix = NULL, om_nls = 11, om_bonus_equiv = 2, om_description = '<p>Une créature touchée par une arme dominatrice doit réussir un jet de Volonté (DD 16) sous peine d''être secouée.</p>
<p><strong>Aura.</strong> Enchantement modéré (niveau 11 de lanceur de sorts)</p>
<p><strong>Création.</strong> Conditions : Création d’armes et armures magiques, terreur</p>'
WHERE om_nom = 'Dominatrice' AND om_res_id = 63 AND om_ruleset_var_id = 1;

INSERT INTO dd_objets_magiques (om_nom, om_com_id, om_fom_id, om_prix, om_nls, om_bonus_equiv, om_description, om_harmonisation, om_rarete, om_visible, om_public, om_res_id, om_ruleset_var_id)
SELECT 'Foulard de Symxustar', 13, 2, 15000, NULL, NULL, '<p>Ce beau foulard, conçu pour une elfe, fonctionne sur le même principe qu''un grimoire. Tant qu''une magicienne le porte, elle peut étudier et préparer les sorts qui y sont « inscrits ». Le foulard de Symrustar peut stocker un total de trente-six sorts, mais pas plus de quatre par niveau. Le foulard est traité comme un grimoire de magicien pour ce qui est d''en déchiffrer le contenu, d''y « écrire » de nouveaux sorts, etc. Pour déterminer le nombre de sorts que renferme un foulard donné, jetez 1d4-1 pour chaque niveau de sort, puis fixer le nom dé chacun comme si vous génériez un parchemin.</p>
<p><strong>Aura.</strong> Transmutation modérée (niveau 1, de lanceur de sorts)</p>
<p><strong>Création.</strong> Conditions : Création d’objets merveilleux, page secrète</p>', 0, 0, 1, 0, 63, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_objets_magiques WHERE om_nom = 'Foulard de Symxustar' AND om_res_id = 63 AND om_ruleset_var_id = 1);

UPDATE dd_objets_magiques SET om_com_id = 13, om_prix = 10000, om_nls = 7, om_bonus_equiv = NULL, om_description = '<p>Ce gantelet de mailles permet au porteur de jeter son arme de corps à corps comme si elle possédait les propriétés spéciales boomerang et de lancer.</p>
<p><strong>Emplacement.</strong> Mains</p>
<p><strong>Aura.</strong> Transmutation modérée (niveau 7 de lanceur de sorts)</p>
<p><strong>Création.</strong> Conditions : Création d’objets merveilleux, pierre magique, télékinésie</p>'
WHERE om_nom = 'Gant de Taarnahm le Vigilant' AND om_res_id = 63 AND om_ruleset_var_id = 1;

INSERT INTO dd_objets_magiques (om_nom, om_com_id, om_fom_id, om_prix, om_nls, om_bonus_equiv, om_description, om_harmonisation, om_rarete, om_visible, om_public, om_res_id, om_ruleset_var_id)
SELECT 'Gantelets d''armement profane', 13, 2, 9000, 3, NULL, '<p>Ces épais gantelets de cuir rehaussés d''argent recouvrent les mains et les poignets du porteur. Des fils argentés ornent les parties en cuir et chaque maille d''argent est couverte de runes au niveau de la paume. Lorsque le porteur manie une arme (métallique ou non), il passe outre la réduction des dégâts de ses adversaires comme s''il s''agissait d''une arme en argent magique. Si l''arme est déjà magique et en argent, les gantelets n''ont pas grand intérêt.</p>
<p><strong>Emplacement.</strong> Mains</p>
<p><strong>Poids.</strong> 0,5 kilo</p>
<p><strong>Aura.</strong> Transmutation faible (niveau 3 de lanceur de sorts)</p>
<p><strong>Création.</strong> Conditions : Création d’objets merveilleux, arme magique</p>', 0, 0, 1, 0, 63, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_objets_magiques WHERE om_nom = 'Gantelets d''armement profane' AND om_res_id = 63 AND om_ruleset_var_id = 1);

INSERT INTO dd_objets_magiques (om_nom, om_com_id, om_fom_id, om_prix, om_nls, om_bonus_equiv, om_description, om_harmonisation, om_rarete, om_visible, om_public, om_res_id, om_ruleset_var_id)
SELECT 'Heaume du pégase de Kloeth Ferétoile', 13, 2, 20160, 7, NULL, '<p>Ce magnifique casque ailé permet à son porteur de convoquer un pégase céleste, 2 fois,par jour, pour servir de monture ou participer à un combat. Il est nécessaire de prononcer un mot de commande à chaque convocation et la créature appelée reste pendant 3 heures, sauf si le porteur y met un terme avant.</p>
<p><strong>Emplacement.</strong> Tête</p>
<p><strong>Aura.</strong> Invocation modérée (niveau 7 de lanceur de sorts)</p>
<p><strong>Création.</strong> Conditions : Création d’objets merveilleux, convocation de monstres 4</p>', 0, 0, 1, 0, 63, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_objets_magiques WHERE om_nom = 'Heaume du pégase de Kloeth Ferétoile' AND om_res_id = 63 AND om_ruleset_var_id = 1);

UPDATE dd_objets_magiques SET om_com_id = 13, om_prix = 75040, om_nls = 7, om_bonus_equiv = NULL, om_description = '<p>Ces gemmes vertes et éclatantes, chacune de la taille du poing, furent créées par les plus talentueux espions de Myth Drannor avant sa chute. Quand on le pose contre la peau, le kiira N''Vaelahr s''insère sans douleur dans la chair et s''y fixe si fermement qu''il est ensuite impossible de l''enlever. Traditionnellement, une telle gemme est placée au niveau du cœur, mais on peut la mettre sur n''importe quelle partie du corps. Une fois implantée, la gemme peut se déplacer dans le corps de son porteur sur simple concentration. Un kiira N''Vaelahr confère les pouvoirs suivants :</p>
<p>Le kiira NVaelahr est une sorte d''enregistreur qui archive automatiquement les souvenirs de son porteur. Les souvenirs mémorisés par la gemme peuvent ensuite être passés. La diffusion est alors visible et audible au porteur uniquement, sauf s''il use d''un autre pouvoir (cf. ci-dessous) pour la rendre visible à autrui. Ces souvenirs offrent son et image uniquement. De plus, ils sont un peu flous et il est difficile de s''y retrouver. (Les tentatives visant à voir ou entendre un événement précis subissent un malus de -2 aux tests de Détection et Perception auditive.) Au prix d''une action simple, le porteur de la gemme peut faire en sorte que l''objet enregistre ses souvenirs avec plus de détails. La gemme peut renfermer jusqu''à 10 heures de souvenirs détaillés, qui peuvent ensuite être lus sans malus. Si le porteur le souhaite, ces souvenirs peuvent inclure ses réflexions et sentiments.</p>
<ul><li>Le porteur peut user de détection de pensées à volonté. Il peut également envoyer des messages télépathiques (ce qui inclut des souvenirs archivés dans son kiira NVaelahr) à ceux dont il lit les pensées.</li><li>Le porteur bénéficie d''un bonus de résistance de +2 aux jets de Volonté.</li><li>Le porteur de la gemme peut user d''image accomplie, 1 fois par jour. Seuls les souvenirs enregistrés par le kiira N''Vhaelahr peuvent être ainsi projetés.</li><li>Le porteur de la gemme peut user de vol supérieur, 1 fois par jour.</li></ul>
<p><strong>Aura.</strong> Divination, Illusion et Transmutation modérées (niveau 7 de lanceur de sorts)</p>
<p><strong>Création.</strong> Conditions : Création d’objets merveilleux, détection de pensées, image accomplie, vol supérieur</p>'
WHERE om_nom = 'Kiira N''Vaelahr' AND om_res_id = 63 AND om_ruleset_var_id = 1;

UPDATE dd_objets_magiques SET om_com_id = 13, om_prix = 232560, om_nls = 13, om_bonus_equiv = NULL, om_description = '<p>Cette petite pierre a tout l''âir d''une pierre ioun. Elle dérive selon une orbite imprécise à 1d3 x 30 centimètres de la tête de son utilisateur et on ne peut l''en séparer qu''en la prenant, que ce soit à la main ou au filet. La pierre protectrice de Vhyridaan a une CA de 26, 10 points de résistance et une solidité de 5. Trois fois par jour, son utilisateur peut prononcer un mot de commande pour jouir d''une protection contre les sorts. Cet effet fonctionne sur le même principe que renvoi des sorts, si ce n''est que la pierre absorbe toujours 5 niveaux de sort avant de perdre ses propriétés, et non 1d4+6.</p>
<p>De plus, le propriétaire de la pierre protectrice peut y stocker 1 à 3 niveaux de sort par jour, comme s''il s''agissait d''une pierre ioun violet vif.</p>
<p><strong>Aura.</strong> Abjuration puissante (niveau 13 de lanceur de sorts)</p>
<p><strong>Création.</strong> Conditions : Création d’objets merveilleux, renvoi des sorts, transfert de sorts, Incantation rapide</p>'
WHERE om_nom = 'Pierre protectrice de Vhyridaan' AND om_res_id = 63 AND om_ruleset_var_id = 1;

INSERT INTO dd_objets_magiques (om_nom, om_com_id, om_fom_id, om_prix, om_nls, om_bonus_equiv, om_description, om_harmonisation, om_rarete, om_visible, om_public, om_res_id, om_ruleset_var_id)
SELECT 'Pierre surnaturelle', 13, 2, 250000, 20, NULL, '<p>Ces morceaux de verre à facettes de la taille du poing comptent parmi les objets les plus recherchés de Faerûn. Les mages en quête d''intimité et les êtres maléfiques désireux de laisser planer le secret sur leurs projets les arment tout particulièrement. Du reste, ils chargent souvent leurs sbires ou des aventuriers de les leur récupérer.</p>
<p>Une fois placée sur une surface verticale et activée via un ordre mental, une pierre surnaturelle se met à flotter à 90 centimètres du sol tout en luisant et tintant légèrement. Tant qu''elle est active, elle bloque tous les effets suivants dans un rayon de 9 kilomètres (y compris dans les airs^et sous terre).</p>
<ul><li>Les déplacements astraux et éthérés.</li><li>Les sorts de Divination (scrutation).</li><li>Les sorts d''Invocation (téléportation).</li><li>Les pouvoirs magiques, surnaturels et extraordinaires, les facultés psioniques et autres aptitudes reproduisant ces effets.</li></ul>
<p>La pierre surnaturelle n''entrave que les effets qui se manifestent dans la zone. Les sorts et pouvoirs activés au sein de cette zone et qui visent un lieu situé en dehors du rayon de 9 kilomètres ne sont pas concernés. Par exemple, un magicien se tenant près d''une pierre surnaturelle pourra lancer scrutation pour espionner une créature située à plus de 9 kilomètres, mais il sera incapable de se téléporter dans la pièce observée en raison de l''action de la pierre.</p>
<p><strong>Aura.</strong> Abjuration puissante (niveau 20 de lanceur de sorts)</p>
<p><strong>Création.</strong> Conditions : Création d’objets merveilleux, antidétection, porte dimensionnelle, le créateur doit être de niveau 20</p>', 0, 0, 1, 0, 63, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_objets_magiques WHERE om_nom = 'Pierre surnaturelle' AND om_res_id = 63 AND om_ruleset_var_id = 1);

INSERT INTO dd_objets_magiques (om_nom, om_com_id, om_fom_id, om_prix, om_nls, om_bonus_equiv, om_description, om_harmonisation, om_rarete, om_visible, om_public, om_res_id, om_ruleset_var_id)
SELECT 'Sphères', 16, 2, 25000, 9, NULL, '<p>Elminster aurait conçu le premier de ces rares et étranges sceptres, mais des magiciens de tout Toril en ont depuis créé de nouveaux exemplaires. L''unique fonction du sceptre des sphères est de créer de grosses bulles transparentes de 90 centimètres de diamètre dégageant autant de lumière qu''une bougie. Les bulles flottent dans les airs à la vitesse de 6 mètres par round dans la direction choisie par le porteur. Chacune peut renfermer jusqu''à 70 kilos de créatures ou d''objets. Tout objet situé dans une telle sphère est protégé des éléments (pluie, vent, neige, etc., mais pas de bonus ou de résistance contre les attaques d''énergie destructive) et jouit d''un effet as feuille morte si elle tombe de plus de 3 mètres. Les bulles ont une durée de vie de 8 heures (sauf si on les brise avant).</p>
<p>Une bulle n''est pas une prison. Tout être intelligent peut en sortir facilement en la brisant. Le sceptre des sphères a 50 charges au moment de sa création et la formation de chaque bulle coûte 1 charge.</p>
<p><strong>Aura.</strong> Évocation [force] modérée (niveau 9 de lanceur de sorts)</p>
<p><strong>Création.</strong> Conditions : Création de sceptres magiques, disque flottant de Tenser, feuille morte</p>', 0, 0, 1, 0, 63, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_objets_magiques WHERE om_nom = 'Sphères' AND om_res_id = 63 AND om_ruleset_var_id = 1);

INSERT INTO dd_objets_magiques (om_nom, om_com_id, om_fom_id, om_prix, om_nls, om_bonus_equiv, om_description, om_harmonisation, om_rarete, om_visible, om_public, om_res_id, om_ruleset_var_id)
SELECT 'Velsharoon', 1, 2, 33500, 5, NULL, '<p>En réalité, cet objet est constitué d''une paire d''anneaux que l''on porte à l''index et à l''auriculaire. Il ne compte cependant que pour un anneau dans le cadre de la limite au nombre d''objets magiques. Une fine chaîne en argent relie les deux anneaux. L''anneau de Velsharoon protège son porteur contre les morts-vivants, sur le même principe qu''une protection contre le Mal, si ce n''est que les bonus sont conférés contre les morts-vivants et non contre les créatures maléfiques. Le porteur bénéficie-également d''un bonus de résistance de +3 contre les sorts de l''école de Nécromancie.</p>
<p><strong>Emplacement.</strong> Doigts</p>
<p><strong>Aura.</strong> Abjuration faible (niveau 5 de lanceur de sorts)</p>
<p><strong>Création.</strong> Conditions : Création d’anneaux magiques, immobilisation de morts-vivants</p>', 0, 0, 1, 0, 63, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_objets_magiques WHERE om_nom = 'Velsharoon' AND om_res_id = 63 AND om_ruleset_var_id = 1);
