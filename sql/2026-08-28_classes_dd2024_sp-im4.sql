-- sql/2026-08-28_classes_dd2024_sp-im4.sql
-- SP-IM4 — Les 12 sous-classes du SRD 5.2.1 (DD2024).
--
-- Source : FR_SRD_CC_v5.2.1-classes.pdf, sections « Sous-classe de <classe> : … ».
-- Arbitrages du 2026-08-28 :
--   * les 10 sous-classes CRÉÉES ici portent cla_res_id = 93 (SRD 5.2.1) ;
--   * les 2 déjà en base (Voie du Berserker, Voleur) gardent leur source
--     d'origine 91 (Manuel des Joueurs 2024) et sont seulement réalignées ;
--   * « Voie du Berseker » est corrigé en « Voie du Berserker ».
--
-- Ne sont PAS touchées : « Voie de l'Arbre-monde » (64) et « Collège de la
-- Lune » (65), hors SRD, saisies à la main.
--
-- Sous-classes créées (ids figés) :
--   70 Collège du Savoir (Barde) · 71 Domaine de la Vie (Clerc)
--   72 Cercle de la Terre (Druide) · 73 Sorcellerie draconique (Ensorceleur)
--   74 Champion (Guerrier) · 75 Évocateur (Magicien)
--   76 Credo de la Paume (Moine) · 77 Protecteur Fiélon (Occultiste)
--   78 Serment de Dévotion (Paladin) · 79 Chasseur (Rôdeur)
--
-- ⚠ VISIBILITÉ : la source 93 doit être active pour que ces sous-classes
--   apparaissent. Relevé le 2026-08-28 : res_selection = 1 (active par défaut)
--   et sélectionnée dans les sources personnelles de j_id = 1. Les autres
--   joueurs n'ayant aucune sélection DD2024 la reçoivent par le défaut.
--
-- IDEMPOTENCE : ids de classes (70-79) et de capacités (801+) figés,
--   INSERT … ON DUPLICATE KEY UPDATE. Rejouable.

-- ------------------------------------------------------------
-- 1. Sous-classes
-- ------------------------------------------------------------

INSERT INTO dd_classes
  (cla_id, cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_car_id, cla_mag_id,
   cla_profil_incantation, cla_sort_connu, cla_sort_compris, cla_sort_prepare,
   cla_domaine_divin, cla_niveauMax, cla_cla_id, cla_res_id, cla_camp_id,
   cla_public, cla_visible, cla_ruleset_var_id, cla_description)
VALUES
  (63, 'Voie du Berserker', '', 5, 12, 0, 0, 0, 0, 0, 0, 0, 20, 51, 91, NULL, 0, 1, 2, '<p>Les Barbares qui empruntent la Voie du Berserker transforment l’essentiel de leur Rage en violence. C’est la voie de la fureur débridée, dans laquelle on se laisse dominer et animer par la Rage pour s’abandonner dans le chaos des batailles.</p>'),
  (70, 'Collège du Savoir', '', 5, 8, 0, 0, 0, 0, 0, 0, 0, 20, 53, 93, NULL, 0, 1, 2, '<p>Les Bardes du Collège du Savoir récoltent leurs sorts et secrets de sources aussi diverses que les tomes académiques, les rites mystiques et les contes paysans. Les membres du collège se réunissent au sein de bibliothèques et universités pour s’échanger leurs trésors de sapience. Ils se rencontrent aussi à l’occasion de festivals ou lors d’une réunion entre gens de pouvoir, où il leur est loisible de dénoncer la corruption, de démêler les mensonges et de railler ces figures d’autorité gonflées d’importance.</p>'),
  (71, 'Domaine de la Vie', '', 5, 8, 0, 0, 0, 0, 0, 0, 0, 20, 54, 93, NULL, 0, 1, 2, '<p>Le Domaine de la Vie se concentre sur les énergies positives qui préservent toute vie à travers le multivers. Les Clercs qui puisent dans ce domaine excellent en guérison, en profitant de cette force vitale pour soigner de nombreuses blessures.</p><p>L’existence même compte sur les énergies positives associées à ce domaine, si bien que tout Clerc, quelle que soit sa confession, peut le choisir. Ce domaine est grandement associé aux divinités agricoles, aux dieux de la guérison ou de l’endurance, du foyer et de la communauté. Les ordres religieux dévoués aux soins prisent aussi la magie de ce domaine.</p>'),
  (72, 'Cercle de la Terre', '', 5, 8, 0, 0, 0, 0, 0, 0, 0, 20, 55, 93, NULL, 0, 1, 2, '<p>Le Cercle de la Terre accueille les mystes et les sages qui veillent sur les rites et savoirs ancestraux. Ces Druides se rassemblent dans des cercles sacrés faits d’arbres ou de menhirs pour se murmurer des secrets primitifs en langue druidique. Les membres les plus sagaces du cercle officient comme grands prêtres de leur communauté.</p>'),
  (73, 'Sorcellerie draconique', '', 5, 6, 0, 0, 0, 0, 0, 0, 0, 20, 56, 93, NULL, 0, 1, 2, '<p>Votre magie innée est le cadeau d’un dragon. Il se peut qu’un dragon vénérable, sentant la mort arriver, vous ait légué, à vous-même ou à un ancêtre, une partie de son pouvoir magique. Vous pourriez aussi avoir absorbé de la magie en un lieu imprégné de puissance draconique. À moins que vous ayez manipulé par mégarde un trésor provenant de l’antre d’un dragon, nimbé de pouvoir draconique. Vous pouvez enfin avoir un dragon comme ancêtre.</p>'),
  (74, 'Champion', '', 5, 10, 0, 0, 0, 0, 0, 0, 0, 20, 50, 93, NULL, 0, 1, 2, '<p>Un Champion cherche à tirer le meilleur parti de ses qualités martiales au service obstiné de la victoire. Les Champions conjuguent entraînement draconien et condition physique d’exception pour asséner des coups dévastateurs et endurer les périls, et enfin en récolter les lauriers. Qu’ils s’engagent dans une épreuve purement physique ou une bataille sanguinaire, ils n’ont qu’un objectif : le triomphe.</p>'),
  (75, 'Évocateur', '', 5, 6, 0, 0, 0, 0, 0, 0, 0, 20, 52, 93, NULL, 0, 1, 2, '<p>Vos études magiques ont essentiellement porté sur les effets élémentaires les plus puissants : gel intense, flammes ardentes, tonnerre roulant, crépitements de la foudre et corrosions de l’acide. Certains évocateurs œuvrent au service d’armées comme artilleurs spécialisés. D’autres utilisent leur pouvoir pour protéger autrui, tandis que d’autres encore cherchent avant tout à briller.</p>'),
  (76, 'Credo de la Paume', '', 5, 8, 0, 0, 0, 0, 0, 0, 0, 20, 57, 93, NULL, 0, 1, 2, '<p>Les Moines du Credo de la Paume excellent au combat à mains nues. Ils apprennent à bousculer et faire tomber leurs adversaires et à manipuler leur propre énergie pour consolider leur corps.</p>'),
  (77, 'Protecteur Fiélon', '', 5, 8, 0, 0, 0, 0, 0, 0, 0, 20, 58, 93, NULL, 0, 1, 2, '<p>Ce pacte vous permet de puiser dans les Plans Inférieurs, les royaumes de la perdition. Vous avez conclu un marché avec un seigneur démon, un archidiable ou autre fiélon particulièrement puissant. Les visées de ce protecteur sont maléfiques : corruption ou destruction de toute chose, y compris vous-même, et votre destin personnel peuvent vous opposer à ces mêmes objectifs.</p>'),
  (78, 'Serment de Dévotion', '', 5, 10, 0, 0, 0, 0, 0, 0, 0, 20, 59, 93, NULL, 0, 1, 2, '<p>Le Serment de Dévotion lie les Paladins aux idéaux de justice et d’ordre. Ces Paladins sont la vivante incarnation du preux chevalier en armure rutilante. Ils respectent un code de conduite des plus rigoureux et certains, pour le meilleur ou le pire, imposent au reste du monde cette même rigueur.</p><p>Beaucoup de ceux qui prêtent ce serment sont les fidèles serviteurs d’une divinité Loyale Bonne et mesurent leur propre dévotion à l’aune des préceptes de ce dieu. Certains considèrent les anges comme leur idéal et intègrent des images d’ailes angéliques à leur casque ou à leurs armoiries.</p><p>Ces Paladins partagent les préceptes suivants :</p><ul><li>Faire en sorte que sa parole ait toujours valeur de promesse.</li><li>Veiller sur les faibles et ne jamais avoir peur d’agir.</li><li>Servir d’exemple en accomplissant des actes honorables.</li></ul>'),
  (79, 'Chasseur', '', 5, 10, 0, 0, 0, 0, 0, 0, 0, 20, 60, 93, NULL, 0, 1, 2, '<p>Vous traquez des proies en pleine nature ou ailleurs, utilisant vos capacités de chasseur pour protéger la faune, la flore et les braves gens partout où menacent les forces de la destruction.</p>'),
  (68, 'Voleur', '', 5, 8, 0, 0, 0, 0, 0, 0, 0, 20, 61, 91, NULL, 0, 1, 2, '<p>Mélange de cambrioleur, de chasseur de trésor et d’explorateur, vous êtes la parfaite incarnation de l’aventurier. En plus d’améliorer votre agilité et votre discrétion, vous recevez des aptitudes utiles pour l’exploration des ruines et tirer le meilleur parti des objets magiques que vous y trouvez.</p>')
ON DUPLICATE KEY UPDATE
  cla_nom = VALUES(cla_nom), cla_clt_id = VALUES(cla_clt_id), cla_dV = VALUES(cla_dV),
  cla_niveauMax = VALUES(cla_niveauMax), cla_cla_id = VALUES(cla_cla_id),
  cla_res_id = VALUES(cla_res_id), cla_ruleset_var_id = VALUES(cla_ruleset_var_id),
  cla_description = VALUES(cla_description);

-- ------------------------------------------------------------
-- 2. Purge des affectations actuelles des sous-classes
-- ------------------------------------------------------------

DELETE FROM dd_classe_capacite WHERE cc_cla_id IN (63,70,71,72,73,74,75,76,77,78,79,68);

-- ------------------------------------------------------------
-- 3. Capacités de sous-classe — ids figés à partir de 801
-- ------------------------------------------------------------

INSERT INTO dd_capacites_speciales
  (cap_id, cap_nom, cap_description, cap_type, cap_classe_initiale)
VALUES
  (801, 'Frénésie', '<p>Si vous recourez à Témérité alors que votre Rage est active, vous infligez des dégâts supplémentaires à la première cible que vous touchez à votre tour avec une attaque basée sur la Force. Pour déterminer ces dégâts supplémentaires, lancez autant de d6 que votre bonus de Rage aux dégâts et faites-en la somme. Ces dégâts sont du même type que ceux de l’arme ou l’attaque à mains nues employée pour l’attaque.</p>', '', 63),
  (802, 'Rage aveugle', '<p>Vous avez l’Immunité contre les états Charmé et Effrayé tant que votre Rage est active. Si vous subissez déjà l’état Charmé ou Effrayé au moment où vous entrez en Rage, l’état en question prend fin sur vous.</p>', '', 63),
  (803, 'Représailles', '<p>Lorsque vous subissez des dégâts de la part d’une créature située dans un rayon de 1,50 m, vous pouvez jouer votre Réaction pour effectuer contre elle une attaque de corps à corps avec une arme ou à mains nues.</p>', '', 63),
  (804, 'Présence intimidante', '<p>Par une action Bonus, vous pouvez inspirer la terreur chez autrui grâce à votre présence et votre puissance primale. Ce faisant, chaque créature de votre choix dans une Émanation de 9 m centrée sur vous effectue un jet de sauvegarde de Sagesse (DD 8 plus votre modificateur de Force et votre bonus de maîtrise). En cas d’échec, la créature subit l’état Effrayé pendant 1 minute. À la fin de chacun des tours d’une créature Effrayée, celle-ci réitère le JS et met un terme à l’effet sur elle-même en cas de réussite.</p><p>Une fois cette aptitude utilisée, vous devez terminer un Repos long ou dépenser une utilisation de votre Rage (pas d’action requise) pour en récupérer l’usage.</p><p>Barde</p>', '', 63),
  (805, 'Maîtrises supplémentaires', '<p>Vous recevez la maîtrise de trois compétences, au choix.</p>', '', 70),
  (806, 'Mots cinglants', '<p>Vous apprenez à déconcentrer, perturber et décourager autrui par votre sens surnaturel de la répartie. Lorsqu’une créature que vous voyez dans un rayon de 18 m effectue un jet de dégâts, ou bien réussit un test de caractéristique ou un jet d’attaque, vous pouvez jouer votre Réaction pour dépenser une utilisation de votre Inspiration bardique ; lancez votre dé d’Inspiration bardique que vous soustrayez au jet de la créature, afin de réduire les dégâts ou, éventuellement, de convertir sa réussite en échec.</p>', '', 70),
  (807, 'Découvertes magiques', '<p>Vous apprenez deux sorts de votre choix. Chacun de ces sorts peut être issu de la liste du Clerc, du Druide ou du Magicien (ces listes se trouvent chacune dans la section de chaque classe correspondante). Chaque sort retenu doit être un sort mineur ou d’un niveau pour lequel vous disposez d’au moins un emplacement, comme indiqué dans la table Aptitudes du Barde.</p><p>Ces sorts sont toujours préparés en ce qui vous concerne. Chaque fois que vous gagnez un niveau de Barde, vous pouvez remplacer l’un des sorts par un autre sort remplissant ces conditions.</p>', '', 70),
  (808, 'Compétence hors pair', '<p>Lorsque vous effectuez un test de caractéristique ou un jet d’attaque et que vous le ratez, vous pouvez dépenser une utilisation d’Inspiration bardique ; lancez le dé d’Inspiration bardique et ajoutez-en le résultat au Test d20 concerné, ce qui peut convertir l’échec en réussite. En cas d’échec final, l’Inspiration bardique n’est pas dépensée.</p><p>Clerc</p>', '', 70),
  (809, 'Disciple de la Vie', '<p>Lorsqu’un sort que vous lancez par un emplacement restitue des points de vie à une créature, celle-ci récupère des points de vie supplémentaires au tour où vous lancez le sort. Ces points de vie supplémentaires sont égaux à 2 plus le niveau de l’emplacement de sort.</p>', '', 71),
  (810, 'Sorts du Domaine de la Vie', '<p>Votre lien au domaine divin veille à ce que certains de vos sorts soient toujours préparés. Lorsque vous atteignez un niveau de clerc spécifié dans la table Sorts du Domaine de la Vie, les sorts qui y figurent sont toujours préparés pour vous.</p><p>Sorts du Domaine de la Vie</p><p>Niveau de</p><p>Clerc</p><p>Sorts préparés aide, bénédiction, restauration partielle, soins mot de guérison de groupe, retour à la vie aura de vie, protection contre la mort restauration suprême, soins de groupe</p>', '', 71),
  (811, 'Survivance', '<p>Au prix de l’action Magie, vous présentez votre symbole sacré et dépensez une utilisation de Conduit divin pour libérer des énergies curatives qui restituent autant de points de vie que le quintuple de votre niveau de Clerc. Choisissez des créatures En péril dans un rayon de 9 m (vous pouvez vous inclure) et répartissez ces points de vie entre elles. Cette aptitude ne permet pas à une créature de dépasser la moitié de son maximum de points de vie.</p>', '', 71),
  (812, 'Guérisseur béni', '<p>Les sorts de guérison que vous lancez sur autrui vous soignent également. Aussitôt après avoir lancé par un emplacement un sort qui restitue des points de vie à une ou plusieurs créatures autres que vous, vous récupérez un nombre de points de vie égal à 2 plus le niveau de l’emplacement.</p>', '', 71),
  (813, 'Guérison suprême', '<p>Quand vous êtes censé lancer un ou plusieurs dés pour restituer des points de vie à une créature par le biais d’un sort ou d’un Conduit divin, ne lancez pas les dés pour les soins ; au lieu de cela, prenez la valeur maximale pour chaque dé. Au lieu de rendre 2d6 points de vie à une créature, par exemple, vous lui en restituez 12.</p><p>Druide</p>', '', 71),
  (814, 'Sorts du Cercle de la Terre', '<p>Chaque fois que vous terminez un Repos long, choisissez un type d’environnement entre : aride, polaire, tempéré et tropical. Consultez parmi les tables ci-après celle qui correspond au type retenu ; les sorts énumérés pour votre niveau de druide et les niveaux inférieurs sont préparés en ce qui vous concerne.</p><p>Terres arides</p><p>Niveau de Druide Sorts de cercle flou, mains brûlantes, trait de feu boule de feu flétrissement mur de pierre</p><p>Terres polaires</p><p>Niveau de Druide Sorts de cercle immobilisation de personne, nappe de brouillard, rayon de givre tempête de neige tempête de grêle cône de froid</p><p>Terres tempérées</p><p>Niveau de</p><p>Druide</p><p>Sorts de cercle foulée brumeuse, poigne électrique, sommeil éclair liberté de mouvement passage par les arbres</p><p>Terres tropicales</p><p>Niveau de Druide</p><p>Sorts de cercle aspersion acide, rayon empoisonné, toile d’araignée nuage nauséabond métamorphose fléau d’insectes</p>', '', 72),
  (815, 'Aval de la terre', '<p>Au prix de l’action Magie, vous pouvez dépenser une utilisation de Forme sauvage en choisissant un point dans un rayon de 18 m. Des fleurs nourricières et des ronces vampiriques se manifestent quelques instants dans une Sphère de 3 m de rayon centrée sur ce point. Chaque créature que vous choisissez dans la Sphère effectue un jet de sauvegarde de Constitution assorti de votre DD de sauvegarde des sorts, et subit 2d6 dégâts nécrotiques en cas d’échec, la moitié en cas de réussite. Une créature de votre choix dans cette zone récupère 2d6 points de vie.</p><p>Les dégâts et les soins augmentent de 1d6 lorsque vous atteignez les niveaux 10 (3d6) et 14 (4d6) de Druide.</p>', '', 72),
  (816, 'Ressourcement', '<p>Vous pouvez lancer l’un des sorts du 1er niveau ou supérieur préparés par le biais de l’aptitude Sorts de cercle sans dépenser d’emplacement, après quoi il vous faut terminer un Repos long pour pouvoir le relancer ainsi.</p><p>En outre, quand vous terminez un Repos court, vous pouvez désigner des emplacements de sort dépensés que vous souhaitez récupérer. La somme des niveaux de ces emplacements dépensés ne doit pas excéder la moitié de votre niveau de Druide (arrondie au supérieur), et aucun d’eux ne doit être du 6e niveau ou supérieur. Exemple : si vous êtes Druide de niveau 6, vous pouvez récupérer un maximum de trois niveaux d’emplacements de sort. Vous pouvez ainsi récupérer un emplacement du 3e niveau, un emplacement du 2e et un du 1er, ou trois emplacements du 1er. Une fois que vous avez récupéré des emplacements par cette aptitude, vous devez terminer un Repos long pour pouvoir le refaire.</p>', '', 72),
  (817, 'Protégé de dame Nature', '<p>Vous êtes immunisé contre l’état Empoisonné et bénéficiez de la Résistance contre les dégâts du type associé à votre choix d’environnement actuel pour l’aptitude Sorts de cercle, comme indiqué dans la table « Protégé de dame Nature ».</p><p>Protégé de dame Nature</p><p>Environne-</p><p>Environne- ment</p><p>Résistance ment</p><p>Aride</p><p>Feu</p><p>Tempéré</p><p>Polaire</p><p>Froid</p><p>Tropical</p><p>Résistance Foudre Poison</p>', '', 72),
  (818, 'Sanctuaire de dame Nature', '<p>Au prix de l’action Magie, vous pouvez dépenser une utilisation de Forme sauvage pour faire apparaître au sol des plantes grimpantes et arbres spectraux dans un Cube de 4,50 m, dans un rayon de 36 m de vous. Ces végétaux spectraux persistent pendant 1 minute, mais disparaissent prématurément si vous subissez l’état Neutralisé ou mourez. Vous et vos alliés bénéficiez d’un Abri partiel dans la zone et vos alliés reçoivent la Résistance que vous octroie actuellement Protégé de dame Nature tant qu’ils restent dans la zone.</p><p>Par une action Bonus, vous pouvez déplacer au sol le Cube d’un maximum de 18 m, à condition qu’il reste dans un rayon de 36 m de vous.</p><p>Ensorceleur</p>', '', 72),
  (819, 'Résistance draconique', '<p>La magie qui vous habite se manifeste sous la forme de traits propres à votre don draconique. Votre maximum de points de vie initial augmente de 3, puis de 1 chaque fois que vous gagnez un niveau supplémentaire d’Ensorceleur.</p><p>Certaines parties de votre corps sont en outre couvertes d’écailles rappelant celles d’un dragon. Tant que vous ne portez pas d’armure, votre classe d’armure de base est égale à 10 + vos modificateurs de Dextérité et de Charisme.</p>', '', 73),
  (820, 'Sorts draconiques', '<p>Lorsque vous atteignez un niveau d’Ensorceleur spécifié dans la table « Sorts draconiques », les sorts qui y figurent sont toujours préparés pour vous.</p><p>Sorts draconiques</p><p>Niveau d’Ensorceleur</p><p>Sorts injonction, modification d’apparence, orbe chromatique, souffle du dragon terreur, vol charme-monstre, œil du mage convocation de dragon, mythes et légendes</p>', '', 73),
  (821, 'Affinité élémentaire', '<p>Votre magie draconique présente une affinité avec un type de dégâts associé aux dragons. Choisissez l’un des types suivants : acide, feu, foudre, froid ou poison.</p><p>Vous avez la Résistance à ce type de dégâts, et lorsque vous lancez un sort qui inflige des dégâts de ce type, vous pouvez ajouter votre modificateur de Charisme à un jet de dégâts de ce sort.</p>', '', 73),
  (822, 'Ailes draconiques', '<p>Par une action Bonus, vous faites apparaître des ailes draconiques dans votre dos. Ces ailes persistent 1 heure ou jusqu’à ce que vous les révoquiez (pas d’action requise). Pour toute la durée, vous bénéficiez d’une Vitesse de vol de 18 m.</p><p>Une fois cette aptitude utilisée, vous devez terminer un Repos long ou dépenser 3 points de Sorcellerie (pas d’action requise) pour en récupérer l’usage.</p>', '', 73),
  (823, 'Compagnon draconique', '<p>Vous pouvez lancer convocation de dragon sans composante matérielle. Vous pouvez aussi le lancer une fois sans dépenser d’emplacement de sort et récupérez cette aptitude en terminant un Repos long.</p><p>Chaque fois que vous commencez à lancer ce sort, vous pouvez en modifier l’incantation afin qu’elle ne nécessite pas la Concentration. Ce faisant, la durée du sort passe à 1 minute pour cette incantation.</p><p>Guerrier</p>', '', 73),
  (824, 'Critique amélioré', '<p>Vos jets d’attaque avec des armes et à mains nues obtiennent un Coup critique sur un résultat de 19 ou 20 sur le d20.</p>', '', 74),
  (825, 'Athlète accompli', '<p>Grâce à vos qualités athlétiques, vous avez l’Avantage aux jets d’Initiative et aux tests de Force (Athlétisme).</p><p>De plus, aussitôt après avoir obtenu un Coup critique, vous pouvez vous déplacer à concurrence de la moitié de votre Vitesse sans provoquer d’attaques d’Opportunité.</p>', '', 74),
  (826, 'Style de combat supplémentaire', '<p>Vous recevez un autre don de Style de combat de votre choix.</p>', '', 74),
  (827, 'Héros du champ d’honneur', '<p>Le frisson des batailles vous porte vers la victoire. En combat, vous pouvez vous octroyer l’Inspiration héroïque chaque fois que vous commencez votre tour sans en disposer.</p>', '', 74),
  (828, 'Critique supérieur', '<p>Vos jets d’attaque avec des armes et à mains nues obtiennent un Coup critique sur un résultat de 18, 19 ou 20 sur le d20.</p>', '', 74),
  (829, 'Survivant', '<p>Vous atteignez le summum de l’endurance martiale, ce qui vous octroie ces bénéfices.</p><p><b>Trompe-la-mort.</b> Vous avez l’Avantage aux jets de sauvegarde contre la mort. De plus, lorsque vous obtenez un jet de 18 ou 19 à un JS contre la mort, vous en retirez les mêmes bénéfices que si vous aviez obtenu un 20.</p><p><b>Résilience héroïque.</b> Au début de chacun de vos tours, si vous êtes En péril et doté d’au moins 1 point de vie, vous récupérez un nombre de pv égal à 5 + votre modificateur de Constitution.</p><p>Magicien</p>', '', 74),
  (830, 'Évocateur érudit', '<p>Choisissez deux sorts de Magicien de l’école de l’Évocation, chacun du 2e niveau au maximum, et ajoutez-les gratuitement à votre grimoire.</p><p>En outre, chaque fois que vous recevez l’accès à un nouveau niveau d’emplacements de sort dans cette classe, vous pouvez ajouter gratuitement à votre grimoire un sort de Magicien de l’école de l’Évocation. Le sort choisi doit être d’un niveau pour lequel vous disposez d’emplacements de sort.</p>', '', 75),
  (831, 'Sort mineur appuyé', '<p>Vos sorts mineurs restent redoutables pour les créatures qui croyaient s’y soustraire. Lorsque vous lancez un sort mineur sur une créature et que vous ratez votre jet d’attaque ou que la cible réussit son jet de sauvegarde, celle-ci subit la moitié des dégâts éventuels du sort mineur mais aucun effet supplémentaire de ce dernier.</p>', '', 75),
  (832, 'Façonneur de sorts', '<p>Vous pouvez créer des niches protectrices au sein des zones d’effet de vos sorts d’évocation. Lorsque vous lancez un sort d’Évocation qui affecte d’autres créatures que vous voyez, vous pouvez en désigner un nombre n’excédant pas 1 + le niveau du sort. Les créatures choisies réussissent automatiquement leur jet de sauvegarde contre le sort et ne subissent aucun dégât si elles étaient censées les réduire de moitié en cas de réussite.</p>', '', 75),
  (833, 'Évocation améliorée', '<p>Chaque fois que vous lancez un sort de Magicien de l’école de l’Évocation, vous pouvez ajouter votre modificateur d’Intelligence à un jet de dégâts de ce sort.</p>', '', 75),
  (834, 'Surcharge magique', '<p>Vous savez désormais augmenter la puissance de vos sorts. Lorsque vous lancez un sort de Magicien avec un emplacement de sort du 1er au 5e niveau et infligeant des dégâts, vous pouvez infliger le maximum de dégâts avec ce sort au tour où vous le lancez.</p><p>La première fois que vous procédez ainsi, vous ne subissez aucun effet indésirable. Si vous recourez de nouveau à cette aptitude avant d’avoir terminé un Repos long, vous subissez 2d12 dégâts nécrotiques pour chaque niveau de l’emplacement de sort, aussitôt après l’avoir lancé. Ces dégâts ne sont pas affectés par la Résistance et l’Immunité.</p><p>Chaque fois que vous réutilisez cette aptitude avant de terminer un Repos long, les dégâts nécrotiques par niveau de sort augmentent de 1d12.</p><p>Moine</p>', '', 75),
  (835, 'Technique de la Paume', '<p>Chaque fois que vous touchez une créature avec l’une des attaques octroyées par Déluge de coups, vous pouvez imposer l’un des effets suivants à cette cible.</p><p><b>Hésitation.</b> La cible ne peut pas effectuer d’attaque d’Opportunité jusqu’au début de son tour suivant.</p><p><b>Bourrade.</b> La cible doit réussir un jet de sauvegarde de Force sous peine d’être repoussée de vous d’un maximum de 4,50 m.</p><p><b>Renversement.</b> La cible doit réussir un jet de sauvegarde de Dextérité sous peine de subir l’état À terre.</p>', '', 76),
  (836, 'Plénitude physique', '<p>Vous recevez l’aptitude de vous soigner. Par une action Bonus, vous pouvez lancer votre dé d’Arts martiaux. Vous récupérez autant de points de vie que le nombre obtenu plus votre modificateur de Sagesse (minimum de 1 point de vie récupéré).</p><p>Vous pouvez recourir à cette aptitude autant de fois que votre modificateur de Sagesse (minimum d’une fois) et récupérez ce quota en terminant un Repos long.</p>', '', 76),
  (837, 'Foulée preste', '<p>Lorsque vous entreprenez une action Bonus autre que Porté par le vent, vous pouvez aussi recourir à Porté par le vent aussitôt après cette action Bonus.</p>', '', 76),
  (838, 'Paume vibratoire', '<p>Vous apprenez à produire des vibrations potentiellement mortelles dans le corps d’autrui. Lorsque vous touchez une créature avec une attaque à mains nues, vous pouvez dépenser 4 points de Credo pour déclencher ces vibrations imperceptibles, qui persistent autant de jours que votre niveau de Moine. Ces vibrations sont inoffensives jusqu’à ce que vous consacriez une action à y mettre fin. Par ailleurs, lorsque vous entreprenez l’action Attaque à votre tour, vous pouvez renoncer à l’une des attaques pour mettre un terme aux vibrations. Pour ce faire, vous et la cible devez vous trouver sur le même plan d’existence. Quand vous mettez fin aux vibrations, la cible effectue un jet de sauvegarde de Constitution, et subit 10d12 dégâts de force en cas d’échec, la moitié en cas de réussite.</p><p>Vous ne pouvez avoir qu’une créature à la fois sous l’effet de cette aptitude. Vous pouvez aussi mettre fin aux vibrations de façon inoffensive (pas d’action requise).</p><p>Occultiste</p>', '', 76),
  (839, 'Bénédiction du ténébreux', '<p>Lorsque vous réduisez un adversaire à 0 point de vie, vous recevez autant de points de vie temporaires que le total de votre modificateur de Charisme + votre niveau d’Occultiste (1 point de vie temporaire au minimum). Vous bénéficiez aussi de cette aptitude chaque fois qu’autrui réduit à 0 point de vie un adversaire dans un rayon de 3 m.</p>', '', 77),
  (840, 'Sorts du Fiélon', '<p>La magie de votre protecteur vous assure d’avoir certains sorts disponibles en permanence ; lorsque vous atteignez un niveau d’Occultiste spécifié dans la table « Sorts du Fiélon », les sorts qui y figurent sont toujours préparés pour vous.</p><p>Sorts du Fiélon</p><p>Niveau d’Occultiste Sorts injonction, mains brûlantes, rayon ardent, suggestion boule de feu, nuage nauséabond bouclier de feu, mur de feu fléau d’insectes, quête</p>', '', 77),
  (841, 'Chance du ténébreux', '<p>Vous pouvez demander à votre protecteur fiélon qu’il modifie le destin en votre faveur. Lorsque vous effectuez un test de caractéristique ou un jet de sauvegarde, vous pouvez recourir à cette aptitude pour ajouter 1d10 à ce jet. Vous pouvez faire ainsi après avoir effectué le jet, mais avant qu’interviennent ses effets.</p><p>Vous pouvez recourir à cette aptitude un nombre de fois égal à votre modificateur de Charisme (une fois au minimum), mais vous ne pouvez pas l’utiliser plus d’une fois par jet. Vous récupérez ce quota en terminant un Repos long.</p>', '', 77),
  (842, 'Résistance fiélonne', '<p>Choisissez un type de dégâts, autre que Force, chaque fois que vous terminez un Repos court ou long. Vous avez la Résistance à ce type de dégâts jusqu’à ce que vous en choisissiez un autre avec cette aptitude.</p>', '', 77),
  (843, 'Traversée des enfers', '<p>Une fois par tour, quand vous touchez une créature avec un jet d’attaque, vous pouvez tenter de projeter instantanément la cible dans les Plans Inférieurs. La cible doit réussir un jet de sauvegarde de Charisme assorti de votre DD de sauvegarde des sorts, faute de quoi elle disparaît, précipitée dans un paysage de cauchemar. La cible subit 8d10 dégâts psychiques si elle n’est pas un Fiélon et l’état Neutralisé jusqu’à la fin de votre tour suivant, puis elle retourne dans l’espace qu’elle occupait précédemment ou dans l’espace inoccupé le plus proche.</p><p>Une fois cette aptitude utilisée, vous devez terminer un Repos long ou dépenser un emplacement de sort de Magie de pacte (pas d’action requise) pour en récupérer l’usage.</p><p>Paladin</p>', '', 77),
  (844, 'Sorts du Serment de Dévotion', '<p>La magie de votre serment vous assure d’avoir certains sorts disponibles en permanence ; lorsque vous atteignez un niveau de Paladin spécifié dans la table « Sorts du Serment de Dévotion », les sorts qui y figurent sont toujours préparés pour vous.</p><p>Sorts du Serment de Dévotion</p><p>Niveau de Paladin Sorts bouclier de la foi, protection contre le mal et le bien aide, zone de vérité dissipation de la magie, lueur d’espoir gardien de la foi, liberté de mouvement colonne de flamme, communion</p>', '', 78),
  (845, 'Arme sacrée', '<p>Lorsque vous entreprenez l’action Attaque, vous pouvez dépenser une utilisation de votre Conduit divin pour imprégner d’énergie positive une arme de corps à corps que vous brandissez. Pendant 10 minutes ou jusqu’à ce que vous recouriez de nouveau à cette aptitude, vous ajoutez votre modificateur de Charisme aux jets d’attaque effectués avec cette arme (bonus minimum de +1), et chaque fois que vous touchez avec elle, vous décidez si elle inflige son type de dégâts normal ou des dégâts radiants.</p><p>L’arme émet également une Lumière vive dans un rayon de 6 m, et une Lumière faible sur 6 m de plus.</p><p>Vous pouvez mettre fin à cet effet de façon anticipée (pas d’action requise). L’effet cesse également si vous cessez de porter l’arme.</p>', '', 78),
  (846, 'Aura de dévotion', '<p>Vous-même et vos alliés jouissez de l’Immunité contre l’état Charmé au sein de votre Aura de protection. Si un allié Charmé pénètre dans l’aura, cet état est réprimé sur cet allié tant qu’il s’y trouve.</p>', '', 78),
  (847, 'Châtiment de protection', '<p>Votre châtiment magique rayonne désormais d’une énergie protectrice. Chaque fois que vous lancez châtiment divin, vous-même et vos alliés bénéficiez d’un Abri partiel dans votre Aura de protection. L’aura bénéficie de cette aptitude jusqu’au début de votre tour suivant.</p>', '', 78),
  (848, 'Nimbe sacré', '<p>Par une action Bonus, votre Aura de protection est renforcée de puissance sacrée, ce qui octroie les bénéfices ci-après pendant 10 minutes ou jusqu’à ce que vous décidiez d’y mettre fin (pas d’action requise). Une fois que vous avez utilisé cette aptitude, vous devez terminer un Repos long pour pouvoir y recourir de nouveau. Vous pouvez également retrouver son usage en dépensant un emplacement de sort du 5e niveau (pas d’action requise).</p><p><b>Dégâts radiants.</b> Chaque fois qu’un ennemi débute son tour dans l’aura, cette créature subit un total de dégâts radiants égal à votre modificateur de Charisme + votre bonus de maîtrise.</p><p><b>Lumière du soleil.</b> L’aura est inondée d’une Lumière vive qui est la lumière du soleil.</p><p><b>Périmètre sacré.</b> Vous bénéficiez de l’Avantage à tout jet de sauvegarde que vous contraint d’effectuer un Fiélon ou un Mort-vivant.</p><p>Rôdeur</p>', '', 78),
  (849, 'Savoir du Chasseur', '<p>Vous faites appel aux forces de la nature pour révéler les forces et faiblesses de votre proie. Lorsqu’une créature est marquée par votre marque du chasseur, vous savez si cette créature dispose d’Immunités, de Résistances ou de Vulnérabilités, et le cas échéant, vous en connaissez la teneur.</p>', '', 79),
  (850, 'Proie du chasseur', '<p>Vous recevez l’une des aptitudes suivantes au choix. Chaque fois que vous terminez un Repos court ou long, vous pouvez remplacer l’option choisie par l’autre.</p><p><b>Briseur de hordes.</b> Une fois à chacun de vos tours quand vous effectuez une attaque avec arme, vous pouvez effectuer une nouvelle attaque avec la même arme contre une créature différente dans un rayon de 1,50 m de la cible initiale et à portée de cette arme, à condition de ne pas l’avoir déjà attaquée ce tour-ci.</p><p><b>Goût du sang.</b> Votre ténacité vient à bout des ennemis les plus robustes. Lorsque vous touchez une créature avec une arme, celle-ci inflige 1d8 dégâts supplémentaires à la cible s’il lui manque des points de vie. Vous ne pouvez infliger ces dégâts supplémentaires qu’une seule fois par tour.</p>', '', 79),
  (851, 'Tactiques défensives', '<p>Vous recevez l’une des aptitudes suivantes au choix. Chaque fois que vous terminez un Repos court ou long, vous pouvez remplacer l’option choisie par l’autre.</p><p><b>Cauchemar de la horde.</b> Les attaques d’Opportunité contre vous subissent le Désavantage.</p><p><b>Défense contre les attaques multiples.</b> Lorsqu’une créature vous touche avec un jet d’attaque, cette créature subit le Désavantage à tous ses autres jets d’attaque contre vous pendant ce tour.</p>', '', 79),
  (852, 'Proie du chasseur supérieure', '<p>Une fois par tour, lorsque vous infligez des dégâts à une créature marquée par votre marque du chasseur, vous pouvez également infliger les dégâts supplémentaires de ce sort à une créature différente que vous voyez dans un rayon de 9 m de la première.</p>', '', 79),
  (853, 'Défense de chasseur supérieure', '<p>Quand vous subissez des dégâts, vous pouvez jouer votre Réaction pour vous octroyer la Résistance aux éventuels autres dégâts du même type jusqu’à la fin de ce tour.</p><p>Roublard</p><p>Devenir Roublard…</p>', '', 79),
  (854, 'Mains lestes', '<p>Par une action Bonus, vous effectuez l’une des choses suivantes :</p><p><b>Escamotage.</b> Effectuez un test de Dextérité (Escamotage) pour crocheter une serrure, désamorcer un piège avec les outils de voleur ou faire les poches.</p><p><b>Utilisation d’objet.</b> Effectuez l’action Utilisation ou Magie pour utiliser un objet magique qui nécessite cette action.</p>', '', 68),
  (855, 'Monte-en-l’air', '<p>Rompu à l’accès aux endroits difficiles, vous recevez les bénéfices ci-après.</p><p><b>Escaladeur.</b> Vous recevez une Vitesse d’escalade égale à votre Vitesse.</p><p><b>Sauteur.</b> Vous pouvez déterminer votre distance de saut en utilisant votre Dextérité plutôt que votre Force.</p>', '', 68),
  (856, 'Furtivité suprême', '<p>Vous recevez l’option de Frappe malicieuse suivante. Attaque furtive (coût : 1d6). Si vous jouissez de l’état Invisible consécutif à l’action Furtivité, l’attaque ne met pas fin à cet état à condition que vous terminiez le tour derrière un Abri supérieur ou un Abri total.</p>', '', 68),
  (857, 'Utilisation d’objets magiques', '<p>Vous avez appris à tirer le meilleur parti des objets magiques, ce qui vous octroie les bénéfices suivants.</p><p><b>Charges.</b> Chaque fois que vous utilisez une propriété d’objet magique qui dépense des charges, lancez 1d6. Sur un résultat de 6, vous utilisez la propriété sans dépenser la moindre charge.</p><p><b>Harmonisation.</b> Vous pouvez être harmonisé avec un maximum de quatre objets à la fois.</p><p><b>Parchemins.</b> Vous pouvez utiliser n’importe quel parchemin de sort, en recourant à l’Intelligence comme caractéristique d’incantation pour le sort qui y est inscrit. Si ce sort est un sort mineur ou un sort du 1er niveau, vous le lancez à coup sûr. Si le parchemin contient un sort de niveau supérieur, vous devez au préalable réussir un test d’Intelligence (Arcanes) (DD 10 + le niveau du sort). En cas de réussite, vous lancez le sort inscrit sur le parchemin. En cas d’échec, le parchemin se désintègre.</p>', '', 68),
  (858, 'Réflexes de voleur', '<p>Vous avez acquis l’art de tendre une embuscade et d’échapper au danger promptement. Vous pouvez jouer deux tours lors du premier round de chaque combat. Vous jouez votre premier tour à votre rang d’Initiative normal et votre deuxième tour à ce même rang moins 10.</p>', '', 68)
ON DUPLICATE KEY UPDATE
  cap_nom = VALUES(cap_nom), cap_description = VALUES(cap_description),
  cap_type = VALUES(cap_type),
  cap_classe_initiale = VALUES(cap_classe_initiale);

-- ------------------------------------------------------------
-- 4. Affectations niveau par niveau
-- ------------------------------------------------------------

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision)
VALUES
  (63, 801,  3, NULL),
  (63, 802,  6, NULL),
  (63, 803, 10, NULL),
  (63, 804, 14, NULL),
  (70, 805,  3, NULL),
  (70, 806,  3, NULL),
  (70, 807,  6, NULL),
  (70, 808, 14, NULL),
  (71, 809,  3, NULL),
  (71, 810,  3, NULL),
  (71, 811,  3, NULL),
  (71, 812,  6, NULL),
  (71, 813, 17, NULL),
  (72, 814,  3, NULL),
  (72, 815,  3, NULL),
  (72, 816,  6, NULL),
  (72, 817, 10, NULL),
  (72, 818, 14, NULL),
  (73, 819,  3, NULL),
  (73, 820,  3, NULL),
  (73, 821,  6, NULL),
  (73, 822, 14, NULL),
  (73, 823, 18, NULL),
  (74, 824,  3, NULL),
  (74, 825,  3, NULL),
  (74, 826,  7, NULL),
  (74, 827, 10, NULL),
  (74, 828, 15, NULL),
  (74, 829, 18, NULL),
  (75, 830,  3, NULL),
  (75, 831,  3, NULL),
  (75, 832,  6, NULL),
  (75, 833, 10, NULL),
  (75, 834, 14, NULL),
  (76, 835,  3, NULL),
  (76, 836,  6, NULL),
  (76, 837, 11, NULL),
  (76, 838, 17, NULL),
  (77, 839,  3, NULL),
  (77, 840,  3, NULL),
  (77, 841,  6, NULL),
  (77, 842, 10, NULL),
  (77, 843, 14, NULL),
  (78, 844,  3, NULL),
  (78, 845,  3, NULL),
  (78, 846,  7, NULL),
  (78, 847, 15, NULL),
  (78, 848, 20, NULL),
  (79, 849,  3, NULL),
  (79, 850,  3, NULL),
  (79, 851,  7, NULL),
  (79, 852, 11, NULL),
  (79, 853, 15, NULL),
  (68, 854,  3, NULL),
  (68, 855,  3, NULL),
  (68, 856,  9, NULL),
  (68, 857, 13, NULL),
  (68, 858, 17, NULL);

-- ------------------------------------------------------------
-- 5. Retrait des capacités de sous-classe devenues orphelines
-- ------------------------------------------------------------

DELETE FROM dd_capacites_speciales
WHERE  cap_id IN (439,440,441,442,487,488,489,490,491)
  AND  cap_id NOT IN (SELECT cc_cap_id FROM dd_classe_capacite)
  AND  cap_id NOT IN (SELECT cr_cap_id FROM dd_race_capacite);
