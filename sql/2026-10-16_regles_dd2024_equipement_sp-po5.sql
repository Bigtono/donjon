-- sql/2026-10-16_regles_dd2024_equipement_sp-po5.sql
-- SP-PO5 — SRD 5.2.1 : Équipement et utilisation des objets magiques
-- Règles DD2024 (mécanismes de jeu uniquement). Les articles — prix, poids, caractéristiques et
-- descriptions — vivent dans le compendium ; les listes sont insérées par le tag [[liste:…]] (SP-PO1).
-- Rejouable : les nœuds créés par ce fichier, ses tableaux et les mises à jour sont réinitialisés par slug ;
-- rien d'autre n'est touché. Aucun reg_id codé en dur. Pas de DELIMITER.
-- Pré-requis : 2026-10-16_equipements_dd2024_srd_sp-po5.sql (familles et articles, pour les listes).

SET NAMES utf8mb4;

SET @rs   := (SELECT var_id FROM dd_variables WHERE var_cat = 'ruleset' AND var_valeur = 'DD2024' LIMIT 1);
SET @res  := (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'SRD 5.2.1' AND res_ruleset_var_id = @rs AND res_j_id IS NULL LIMIT 1);
SET @now  := NOW();
SET @r_equipement := (SELECT reg_id FROM dd_regles WHERE reg_slug = 'equipement' AND reg_ruleset_var_id = @rs LIMIT 1);
SET @r_objets_magiques := (SELECT reg_id FROM dd_regles WHERE reg_slug = 'objets-magiques' AND reg_ruleset_var_id = @rs LIMIT 1);

START TRANSACTION;

-- Réinitialisation idempotente (un nœud à la fois, des feuilles vers la racine : fk_reg_parent)
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @rs AND reg_slug = 'utiliser-les-objets-magiques';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @rs AND reg_slug = 'fabrication-d-objets-non-magiques';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @rs AND reg_slug = 'sorts-contre-paiement';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @rs AND reg_slug = 'employes-equipement';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @rs AND reg_slug = 'repas-boisson-et-hebergement';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @rs AND reg_slug = 'train-de-vie';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @rs AND reg_slug = 'montures-et-vehicules';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @rs AND reg_slug = 'materiel-d-aventurier-equipement';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @rs AND reg_slug = 'outils-equipement';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @rs AND reg_slug = 'armures-equipement';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @rs AND reg_slug = 'proprietes-des-armes';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @rs AND reg_slug = 'armes-equipement';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @rs AND reg_slug = 'vente-d-equipement';
DELETE FROM dd_tableaux WHERE tab_ruleset_var_id = @rs AND tab_slug IN (
    'monnaie-et-valeurs',
    'train-de-vie',
    'cout-des-parchemins-de-sort');

-- Nœuds
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_equipement, 'regle', 'Vente d''équipement', 'vente-d-equipement',
'<p>L''équipement est vendu à la moitié de son prix d''achat. Les biens commerciaux et objets de valeur, pierres précieuses et autres objets d''art, conservent quant à eux toute leur valeur sur le marché. La section « Objets magiques » propose des prix pour les objets magiques.</p>',
        5, @rs, @res, NULL, 1, @now, @now);
SET @r_vente_d_equipement := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_equipement, 'regle', 'Armes', 'armes-equipement',
'<p>Les listes ci-dessous présentent les principales armes disponibles dans le jeu. Chaque ligne ouvre la fiche de l''arme ; elles donnent le prix et le poids des armes, ainsi que les détails suivants :</p>
<p><strong>Catégorie.</strong> Toute arme appartient à l''une de ces catégories : arme courante ou arme de guerre. Les maîtrises d''armes sont généralement liées à l''une de ces catégories. Vous pourriez par exemple avoir la maîtrise des armes courantes.</p>
<p><strong>Corps à corps ou à distance.</strong> Chaque arme est classée comme arme de corps à corps ou à distance. Une arme de corps à corps sert à attaquer une cible située à 1,50 m ou moins de soi, tandis qu''une arme à distance permet d''attaquer une cible plus lointaine.</p>
<p><strong>Dégâts.</strong> Les dégâts infligés par chaque arme dans le cadre d''une attaque qui touche, ainsi que le type de dégâts qu''elle inflige.</p>
<p><strong>Propriétés.</strong> Les propriétés éventuelles d''une arme apparaissent en colonne « Propriétés ». Chaque propriété est expliquée dans la section « Propriétés des armes ».</p>
<p><strong>Bottes d''arme.</strong> Chaque arme est dotée d''une propriété botte (ou simplement « botte »), qui est définie en section « Propriétés botte ». Pour utiliser cette propriété, vous devez disposer d''une aptitude qui vous permet d''y recourir.</p>
<h3>Maîtrise des armes</h3>
<p>N''importe qui peut tenir une arme, mais vous devez en avoir la maîtrise pour ajouter votre bonus de maîtrise aux jets d''attaque correspondants. Les aptitudes d''un personnage-joueur peuvent lui conférer des maîtrises d''armes. Un monstre maîtrise les armes qui figurent dans son profil de jeu.</p>
<h3>Armes courantes</h3>
<p>[[liste:equipement|famille=armes-courantes|titre=-]]</p>
<h3>Armes de guerre</h3>
<p>[[liste:equipement|famille=armes-de-guerre|titre=-]]</p>',
        10, @rs, @res, NULL, 1, @now, @now);
SET @r_armes_equipement := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_equipement, 'regle', 'Propriétés des armes', 'proprietes-des-armes',
'<p>Ci-après figurent les définitions des propriétés de la colonne Propriétés de la liste des armes.</p>
<h3>Allonge</h3>
<p>Une arme avec la propriété Allonge ajoute 1,50 m à votre allonge lorsque vous attaquez avec elle, ainsi qu''à l''allonge de vos attaques d''Opportunité.</p>
<h3>Chargement</h3>
<p>Vous ne pouvez tirer qu''un seul projectile lorsque vous consacrez une action, une action Bonus ou une Réaction à attaquer avec une arme dotée de la propriété Chargement, quel que soit le nombre d''attaques que vous pourriez normalement effectuer.</p>
<h3>Deux mains</h3>
<p>Une arme à Deux mains requiert vos deux mains lorsque vous l''utilisez pour attaquer.</p>
<h3>Finesse</h3>
<p>Lorsque vous effectuez une attaque avec une arme dotée de la propriété Finesse, vous choisissez entre le modificateur de Force et le modificateur de Dextérité celui qui s''applique aux jets d''attaque et de dégâts. Vous devez utiliser le même modificateur pour les deux jets.</p>
<h3>Lancer</h3>
<p>Quand une arme est dotée de la propriété Lancer, vous pouvez la lancer pour effectuer une attaque à distance, et la dégainer dans le cadre de l''attaque. S''il s''agit d''une arme de corps à corps, utilisez le même modificateur de caractéristique que pour les jets d''attaque et de dégâts de vos attaques de corps à corps avec cette arme.</p>
<h3>Légère</h3>
<p>Lorsque vous effectuez l''action Attaque à votre tour et attaquez avec une arme Légère, vous pouvez effectuer une attaque supplémentaire par une action Bonus plus tard au cours de ce même tour. Cette attaque supplémentaire doit être effectuée avec une arme Légère différente et vous n''ajoutez pas votre modificateur de caractéristique aux dégâts de l''attaque supplémentaire, sauf si ce modificateur est négatif. Vous pouvez par exemple attaquer avec une épée courte dans une main et une dague dans l''autre en utilisant l''action Attaque et une action Bonus, mais vous n''ajoutez votre modificateur de Force ou de Dextérité au jet de dégâts de l''action Bonus que si ce modificateur est négatif.</p>
<h3>Lourde</h3>
<p>Vous subissez le Désavantage aux jets d''attaque avec une arme Lourde s''il s''agit d''une arme de corps à corps et que votre valeur de Force est inférieure à 13, ou s''il s''agit d''une arme à distance et que votre valeur de Dextérité est inférieure à 13.</p>
<h3>Munitions</h3>
<p>Vous pouvez utiliser une arme dotée de la propriété Munitions pour effectuer une attaque à distance, à condition de disposer de ces munitions. Le type de munition nécessaire est indiqué avec la portée de l''arme. Chaque fois que vous attaquez avec cette arme, vous dépensez l''une de ces munitions. Saisir et charger un tel projectile fait partie de l''attaque (vous devez avoir une main libre pour charger une arme à une main). À l''issue d''un affrontement, vous pouvez consacrer 1 minute à récupérer la moitié de vos munitions utilisées pendant le combat (arrondir à l''inférieur) ; les autres sont perdues.</p>
<h3>Polyvalente</h3>
<p>Une arme dite Polyvalente peut s''utiliser à une ou deux mains. Une valeur de dégâts apparaît entre parenthèses avec la propriété. L''arme inflige ces dégâts lorsqu''elle est utilisée à deux mains pour effectuer une attaque de corps à corps.</p>
<h3>Portée</h3>
<p>La portée d''une arme à distance figure entre parenthèses après la propriété Munitions ou Lancer. Cette portée se compose de deux nombres. Le premier correspond à la portée normale exprimée en mètres, le second à la portée longue. Lorsque vous attaquez une cible située au-delà de la portée normale, vous subissez le Désavantage au jet d''attaque. Vous ne pouvez pas attaquer une cible hors de portée longue.</p>
<h3>Armes improvisées</h3>
<p>Si vous utilisez un objet (pied de table, poêle à frire, bouteille) comme arme improvisée, veuillez vous référer à l''entrée « Armes improvisées » du « Glossaire de règles ». Consultez également ces règles si vous maniez une arme hors des sentiers battus, par exemple en employant une arme à distance pour effectuer une attaque de corps à corps.</p>
<h3>Propriétés botte</h3>
<p>Chaque arme est dotée d''une botte, qui n''est utilisable que par un personnage disposant d''une aptitude, comme Bottes d''arme, qui déverrouille cette propriété pour le personnage. Les bottes sont définies ci-dessous.</p>
<p><strong>Coup double.</strong> Lorsque vous effectuez l''attaque supplémentaire de la propriété Légère de l''arme, vous pouvez l''effectuer dans le cadre de l''action Attaque au lieu de devoir y consacrer votre action Bonus. Vous ne pouvez effectuer cette attaque supplémentaire qu''une seule fois par tour.</p>
<p><strong>Écorchure.</strong> Si votre jet d''attaque avec cette arme rate une créature, vous pouvez lui infliger des dégâts égaux au modificateur de la caractéristique utilisée pour effectuer le jet d''attaque. Ces dégâts sont du même type que ceux infligés par l''arme, et ne peuvent être augmentés qu''en augmentant le modificateur de caractéristique.</p>
<p><strong>Enchaînement.</strong> Si vous touchez une créature avec un jet d''attaque de corps à corps avec cette arme, vous pouvez effectuer un jet d''attaque de corps à corps avec cette arme contre une deuxième créature située dans un rayon de 1,50 m de la première, et qui est elle aussi à votre portée. Si l''attaque touche, la deuxième créature subit les dégâts de l''arme, mais sans ajouter votre modificateur de caractéristique à ces dégâts, sauf si ce modificateur est négatif. Vous ne pouvez effectuer cette attaque supplémentaire qu''une seule fois par tour.</p>
<p><strong>Ouverture.</strong> Si vous touchez une créature avec cette arme et lui infligez des dégâts, vous avez l''Avantage à votre prochain jet d''attaque contre cette créature avant la fin de votre tour suivant.</p>
<p><strong>Poussée.</strong> Si vous touchez une créature avec cette arme, vous pouvez la repousser d''un maximum de 3 m en ligne droite pour peu qu''elle soit de taille G ou inférieure.</p>
<p><strong>Ralentissement.</strong> Si vous touchez une créature avec cette arme et lui infligez des dégâts, vous pouvez réduire sa Vitesse de 3 m jusqu''au début de votre tour suivant. Si la créature est touchée plus d''une fois par des armes dotées de cette propriété, la réduction de sa Vitesse n''excède pas 3 m.</p>
<p><strong>Renversement.</strong> Si vous touchez une créature avec cette arme, vous pouvez la contraindre à effectuer un jet de sauvegarde de Constitution (DD égal à 8 + le modificateur de caractéristique utilisé pour le jet d''attaque + votre bonus de maîtrise). En cas d''échec, la créature subit l''état À terre.</p>
<p><strong>Sape.</strong> Si vous touchez une créature avec cette arme, cette créature subit le Désavantage à son prochain jet d''attaque avant le début de votre tour suivant.</p>',
        20, @rs, @res, NULL, 1, @now, @now);
SET @r_proprietes_des_armes := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_equipement, 'regle', 'Armures', 'armures-equipement',
'<p>La liste ci-dessous répertorie les principales armures du jeu. Chaque ligne ouvre la fiche de l''armure ; elle donne le prix et le poids des armures, ainsi que les détails ci-après :</p>
<p><strong>Catégorie.</strong> Chaque type d''armure appartient à l''une des catégories suivantes : armures légères, intermédiaires ou lourdes. Cette catégorie définit le temps nécessaire pour enfiler ou retirer l''armure.</p>
<p><strong>Classe d''armure (CA).</strong> La colonne Classe d''armure indique le calcul de la CA lorsque vous portez une telle armure. Ainsi, quand vous portez une armure de cuir, votre CA est de 11 + votre modificateur de Dextérité, tandis qu''elle est de 16 si vous portez une cotte de mailles.</p>
<p><strong>Force.</strong> Si la liste indique une valeur dans la colonne Force pour un type d''armure, l''armure correspondante réduit la vitesse du porteur de 3 m si celui-ci n''est pas doté d''une valeur de Force au moins égale au nombre indiqué.</p>
<p><strong>Discrétion.</strong> Quand la liste indique « Désavantage » en colonne Discrétion pour un type d''armure, le porteur subit le Désavantage à ses tests de Dextérité (Discrétion).</p>
<h3>Formation aux armures</h3>
<p>Si tout un chacun peut revêtir une armure ou tenir un bouclier, seules les personnes formées peuvent en faire un usage efficace, comme expliqué ci-après. La classe du personnage et d''autres aptitudes déterminent sa formation aux armures. Un monstre est considéré comme formé à l''armure qui figure dans son profil.</p>
<p><strong>Armures légères, intermédiaires ou lourdes.</strong> Si vous portez une armure légère, intermédiaire ou lourde sans avoir été formé à la porter, vous subissez le Désavantage à tous les Tests d20 qui impliquent la Force ou la Dextérité, et vous ne pouvez pas lancer de sorts.</p>
<p><strong>Bouclier.</strong> Vous ne recevez le bénéfice Classe d''armure d''un bouclier que si vous êtes formé à son port.</p>
<p><strong>Une seule à la fois.</strong> Une même créature ne peut pas porter plus d''une armure et un bouclier à la fois.</p>
<h3>Liste des armures</h3>
<p>[[liste:equipement|famille=armures|titre=-]]</p>',
        30, @rs, @res, NULL, 1, @now, @now);
SET @r_armures_equipement := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_equipement, 'regle', 'Outils', 'outils-equipement',
'<p>Un outil vous aide à effectuer certains tests de caractéristique particuliers, à fabriquer des objets, ou les deux. La fiche d''un outil comprend le coût et le poids de l''outil, ainsi que les entrées suivantes :</p>
<p><strong>Caractéristique.</strong> Cette entrée indique quelle caractéristique employer lorsqu''un test de caractéristique est effectué avec l''outil.</p>
<p><strong>Utilisation.</strong> Cette entrée énumère les choses que vous pouvez faire avec l''outil dans le cadre de l''action Utilisation. Vous pouvez faire l''une de ces choses chaque fois que vous effectuez cette action. Cette entrée fournit également le DD pour l''action.</p>
<p><strong>Artisanat.</strong> Cette entrée indique ce que vous pouvez fabriquer avec l''outil, le cas échéant. Les sections « Fabrication d''objets non magiques », « Préparer des potions de guérison » et « Écrire des parchemins de sort » (voir <em>Fabrication d''objets non magiques</em>) présentent les règles propres à diverses fabrications.</p>
<p><strong>Variantes.</strong> Cette entrée apparaît si l''outil présente des variantes. Chacune nécessite une maîtrise distincte ; chaque variante a sa propre fiche.</p>
<h3>Maîtrise d''outils</h3>
<p>Si vous avez la maîtrise d''un outil, ajoutez votre bonus de maîtrise aux tests de caractéristique correspondants. Si vous avez la maîtrise d''une compétence associée à ce test, vous avez en outre l''Avantage au test.</p>
<p>Vos aptitudes peuvent vous octroyer la maîtrise d''un outil. Un monstre a la maîtrise des outils qui figurent dans son profil.</p>
<h3>Outils d''artisan</h3>
<p>Les outils d''artisan sont tous axés sur la fabrication d''objets et l''exercice d''un métier. Chacun nécessite une maîtrise distincte.</p>
<p>[[liste:equipement|famille=outils-d-artisan|titre=-]]</p>
<h3>Autres outils</h3>
<p>[[liste:equipement|famille=autres-outils|titre=-]]</p>',
        40, @rs, @res, NULL, 1, @now, @now);
SET @r_outils_equipement := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_equipement, 'regle', 'Matériel d''aventurier', 'materiel-d-aventurier-equipement',
'<p>Les listes ci-dessous présentent du matériel que les aventuriers trouvent souvent utile. Chaque objet est décrit sur sa fiche, avec son prix, son poids et ses règles d''utilisation.</p>
<p>Les munitions, focaliseurs arcaniques, focaliseurs druidiques et symboles sacrés existent sous plusieurs formes, détaillées dans les listes qui suivent la liste principale.</p>
<p>[[liste:equipement|famille=materiel-d-aventurier]]</p>',
        50, @rs, @res, NULL, 1, @now, @now);
SET @r_materiel_d_aventurier_equipement := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_equipement, 'regle', 'Montures et véhicules', 'montures-et-vehicules',
'<p>Si une monture peut vous aider à vous déplacer plus rapidement dans les contrées sauvages, son intérêt principal reste de transporter l''équipement qui risquerait sinon de vous ralentir. La première liste présente la capacité de charge de chaque animal. Vous trouverez les profils de ces animaux à la section « Monstres ».</p>
<h3>Montures et cargaison</h3>
<p>Une bête qui tire une calèche, une charrette, un char, un traîneau ou un chariot peut déplacer jusqu''à cinq fois sa capacité de charge de base, poids du véhicule compris. Plusieurs animaux qui tirent le même véhicule additionnent leur capacité de charge.</p>
<h3>Barde</h3>
<p>La Barde est l''armure qui équipe une monture. Tous les types d''armure de la liste des armures sont disponibles à l''achat sous forme de Barde. Le prix est quatre fois celui d''une armure normale et le poids, le double de l''équivalent standard.</p>
<h3>Selles</h3>
<p>La selle est livrée avec un mors, une bride, des rênes et tout autre équipement nécessaire à son utilisation. Une selle militaire octroie l''Avantage aux tests de caractéristique que vous effectuez pour rester en selle. Une selle exotique est nécessaire pour chevaucher une monture aquatique ou volante.</p>
<h3>Montures et autres animaux</h3>
<p>[[liste:equipement|famille=montures-et-autres-animaux|titre=-]]</p>
<h3>Harnachement et véhicules tractés</h3>
<p>[[liste:equipement|famille=harnachement-et-vehicules-tractes|titre=-]]</p>
<h3>Véhicules de grande taille</h3>
<p>La liste ci-dessous fournit le profil de divers types de grands véhicules. Les remarques suivantes s''appliquent.</p>
<p><strong>Vitesse.</strong> Un navire qui fait voile contre un vent fort se déplace à la moitié de sa vitesse. En cas de calme plat (absence de vent), les bateaux ne peuvent pas naviguer à la voile et la propulsion doit se faire à la rame. Barges et barques sont utilisées sur les lacs et les rivières. Si vous naviguez vers l''aval, ajoutez la vitesse du courant (généralement 4,5 km par heure) à celle du véhicule. Il est impossible de naviguer à contre-courant à la seule force des rames, mais de tels véhicules peuvent être halés vers l''amont par des animaux de trait depuis la berge. Une barque peut être portée et pèse 50 kg.</p>
<p><strong>Équipage.</strong> Tout navire de plus fort gabarit qu''une barge ou une barque a besoin d''un équipage d''employés qualifiés (voir <em>Employés</em>) pour fonctionner. L''effectif minimum d''employés qualifiés nécessaires à l''équipage d''un navire dépend de son type, comme spécifié dans la liste.</p>
<p><strong>Passagers.</strong> La liste indique le nombre de passagers de taille P ou M qu''un bateau peut héberger dans des hamacs. Un bateau doté de cabines privées peut transporter cinq fois moins de passagers. Un passager paie généralement 5 pa par jour pour dormir dans un hamac, mais les prix sont susceptibles de varier d''un navire à l''autre. Une petite cabine privée coûte généralement 2 po par jour.</p>
<p><strong>Seuil de dégâts.</strong> Si un véhicule présente un seuil de dégâts (voir « Glossaire de règles »), celui-ci figure dans la liste.</p>
<p><strong>Réparation de navire.</strong> Les réparations d''un navire endommagé s''effectuent lorsque le bateau est à quai. Réparer 1 point de vie nécessite 1 jour et coûte 20 po (matériaux et main-d''œuvre). Si les réparations sont effectuées dans un endroit où matériaux et main-d''œuvre qualifiée abondent, comme le chantier naval d''une grande ville, la durée et le coût des réparations sont réduits de moitié.</p>
<p>[[liste:equipement|famille=vehicules-aeriens-et-bateaux|titre=-]]</p>',
        60, @rs, @res, NULL, 1, @now, @now);
SET @r_montures_et_vehicules := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_equipement, 'regle', 'Train de vie', 'train-de-vie',
'<p>Les dépenses de train de vie résument le coût de la vie quotidienne dans un monde fantastique. Elles couvrent l''hébergement, la nourriture, l''entretien de l''équipement et autres commodités.</p>
<p>Au début de chaque semaine ou de chaque mois (au choix du MJ), choisissez l''un des trains de vie suivants : mendiant, misérable, pauvre, modeste, confortable, riche ou aristocratique, et acquittez le prix correspondant au train de vie associé.</p>
<p>Si le train de vie n''a pas de répercussions automatiques en soi, le MJ peut le prendre en compte pour déterminer les risques ou la façon dont votre personnage est perçu.</p>
<p>[[tab:train-de-vie]]</p>
<p><strong>Mendiant (gratuit).</strong> Vous comptez sur votre bonne étoile et sur la charité pour survivre. Dormir à l''extérieur vous expose souvent à des dangers naturels.</p>
<p><strong>Misérable (1 pa par jour).</strong> Vous dépensez le strict minimum pour vos besoins. Vous êtes parfois exposé à des conditions insalubres et aux exactions des petits criminels.</p>
<p><strong>Pauvre (2 pa par jour).</strong> Vous dépensez avec parcimonie pour vos besoins essentiels.</p>
<p><strong>Modeste (1 po par jour).</strong> Vous subvenez à vos besoins à un niveau moyen.</p>
<p><strong>Confortable (2 po par jour).</strong> Vous subvenez aux besoins élémentaires et profitez de temps à autre du superflu.</p>
<p><strong>Riche (4 po par jour).</strong> Habitué à vivre dans le luxe, vous pourriez même avoir des domestiques.</p>
<p><strong>Aristocratique (10 po par jour).</strong> Vous payez pour ce qu''il y a de mieux et régnez sur une petite armée de serviteurs. Les personnes qui remarquent tout ce faste risquent de vous « inviter » à partager, par des moyens légaux ou non.</p>',
        70, @rs, @res, NULL, 1, @now, @now);
SET @r_train_de_vie := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_equipement, 'regle', 'Repas, boisson et hébergement', 'repas-boisson-et-hebergement',
'<p>La liste ci-dessous indique les prix des articles et de l''hébergement pour une nuit. Les prix d''hébergement quotidien et des repas sont inclus dans les dépenses de train de vie.</p>
<p>[[liste:equipement|famille=repas-boisson-et-hebergement|titre=-]]</p>',
        80, @rs, @res, NULL, 1, @now, @now);
SET @r_repas_boisson_et_hebergement := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_equipement, 'regle', 'Employés', 'employes-equipement',
'<p>On parle d''employé qualifié pour toute personne chargée d''accomplir un service demandant de disposer d''une maîtrise (que ce soit d''arme, d''outil ou de compétence) : mercenaire, artisan, scribe, etc. Le salaire indiqué dans la liste est un minimum ; certains employés experts exigent un montant plus élevé. Les employés sans formation sont chargés des tâches qui ne nécessitent pas de maîtrise particulière, de type manœuvre et portefaix.</p>
<p>[[liste:equipement|famille=employes|titre=-]]</p>',
        90, @rs, @res, NULL, 1, @now, @now);
SET @r_employes_equipement := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_equipement, 'regle', 'Sorts', 'sorts-contre-paiement',
'<p>Maintes localités abritent des individus disposés à lancer des sorts contre argent sonnant et trébuchant. Si un sort nécessite des composantes coûteuses, ajoutez le coût de ces composantes au prix indiqué dans la liste « Services d''incantation » ci-après. Plus un sort est d''un niveau élevé, plus il est difficile de trouver quelqu''un qui puisse le lancer.</p>
<p>[[liste:equipement|famille=services-d-incantation|titre=-]]</p>',
        100, @rs, @res, NULL, 1, @now, @now);
SET @r_sorts_contre_paiement := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_equipement, 'regle', 'Fabrication d''objets non magiques', 'fabrication-d-objets-non-magiques',
'<p>Pour fabriquer un objet non magique, il vous faut les outils adaptés, des matières premières et du temps, chacun de ces éléments étant détaillé ci-dessous. Si vous remplissez les conditions requises, vous fabriquez l''objet et pouvez l''utiliser ou le vendre au prix normal.</p>
<h3>Outils</h3>
<p>La section « Outils » dresse la liste des outils nécessaires pour fabriquer certains objets. Le MJ décide des outils nécessaires à la fabrication d''objets qui n''y figurent pas.</p>
<p>Vous devez utiliser l''outil indiqué pour fabriquer un tel objet et en avoir la maîtrise. Toute personne qui vous aide doit également maîtriser cet outil.</p>
<h3>Matières premières</h3>
<p>Pour fabriquer un objet, vous avez besoin de matières premières valant la moitié de sa valeur marchande (arrondi à l''inférieur). Vous aurez par exemple besoin de 750 po de matières premières pour fabriquer un harnois, d''une valeur marchande de 1 500 po. Le MJ détermine si les matières premières requises sont disponibles.</p>
<h3>Temps</h3>
<p>Pour déterminer le nombre de jours (en travaillant 8 heures par jour) nécessaires à la fabrication d''un objet, divisez par 10 son prix d''achat en po, en arrondissant au jour supplémentaire. 5 jours vous seront par exemple nécessaires pour fabriquer une arbalète lourde, dont la valeur marchande est 50 po.</p>
<p>Si un objet nécessite plusieurs jours de travail, il n''est pas nécessaire que ces jours soient consécutifs. Plusieurs personnages peuvent combiner leurs efforts pour réduire le temps de fabrication. Divisez le temps nécessaire à la création d''un objet par le nombre de personnages qui travaillent à sa fabrication. En temps normal, seul un autre personnage peut vous assister, mais le MJ peut vous en autoriser plusieurs.</p>
<h3>Préparer des potions de guérison</h3>
<p>Un personnage qui a la maîtrise du matériel d''herboriste peut créer une potion de guérison. À cette fin, il faut utiliser ce matériel et 25 po de matières premières pendant 1 journée entière (8 heures de travail).</p>
<h3>Écrire des parchemins de sort</h3>
<p>Un lanceur de sorts peut transférer un sort sur un parchemin et créer un parchemin de sort en s''appuyant sur les règles ci-après.</p>
<p><strong>Temps et coût.</strong> Écrire un parchemin nécessite une quantité de temps et d''argent qui est fonction du niveau du sort, comme indiqué sur la table « Coût des parchemins de sort ». Pour chaque jour de transcription, vous devez travailler 8 heures. Si un parchemin nécessite plusieurs jours, il n''est pas nécessaire que ces jours soient consécutifs.</p>
<p><strong>Prérequis pour le scribe.</strong> Pour écrire un parchemin, vous devez avoir la maîtrise de la compétence Arcanes ou du matériel de calligraphe et avoir le sort préparé à chaque jour de son inscription. Vous devez en outre disposer des éventuelles composantes matérielles nécessaires ; si le sort consomme des composantes matérielles, celles-ci ne sont consommées qu''au moment où vous terminez le parchemin. Le sort du parchemin utilise votre DD de sauvegarde des sorts et votre bonus d''attaque de sort.</p>
<p><strong>Sorts mineurs.</strong> Si le sort retranscrit est un sort mineur, cette version du parchemin fonctionne comme si le lanceur était de votre niveau.</p>
<p>[[tab:cout-des-parchemins-de-sort]]</p>',
        110, @rs, @res, NULL, 1, @now, @now);
SET @r_fabrication_d_objets_non_magiques := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_objets_magiques, 'regle', 'Utiliser les objets magiques', 'utiliser-les-objets-magiques',
'<p>Toute aventure fait miroiter la perspective (mais pas forcément la promesse) de trouver des objets magiques. Des centaines d''objets magiques sont détaillés dans la section « Objets magiques ». Voici ce qu''il faut savoir sur leur utilisation.</p>
<h3>Identifier un objet magique</h3>
<p>Certains objets magiques ne se distinguent pas de leurs équivalents non magiques, tandis que d''autres sont manifestement magiques. Si manipuler un objet magique suffit à vous faire percevoir son caractère extraordinaire, l''apprentissage de ses propriétés magiques n''est pas automatique.</p>
<p>Le sort <em>identification</em> est le moyen le plus rapide de déterminer les propriétés d''un objet. L''autre solution consiste à se concentrer sur un objet magique pendant un Repos court tout en restant en contact physique permanent avec lui. Au terme du Repos, vous connaissez ses propriétés et comment y recourir (mais pas l''éventuelle malédiction que porte l''objet).</p>
<p>Certains objets magiques sont porteurs d''un indice relatif à leurs propriétés. Le mot de commande permettant d''activer un anneau est parfois gravé sur sa face intérieure, ou des plumes stylisées peuvent suggérer qu''il s''agit d''un anneau de feuille morte.</p>
<p>Porter ou expérimenter un objet peut également fournir des explications relatives à ses propriétés. Dans le cas particulier des potions, il suffit de goûter un peu du breuvage sur le bout de la langue pour déterminer l''effet de la potion. D''autres objets peuvent nécessiter davantage d''expérimentations. Si, par exemple, votre personnage passe au doigt un anneau de nage, le MJ peut vous glisser : « Tes mouvements sont devenus étrangement fluides. » Il pourrait être opportun de plonger dans une rivière pour en avoir le cœur net. Le MJ déclare alors que vous nagez avec une facilité déconcertante.</p>
<h3>Harmonisation</h3>
<p>Certains objets magiques nécessitent qu''une créature crée un lien avec eux (on parle alors d''Harmonisation) avant qu''elle puisse recourir à leurs propriétés magiques. Si vous n''êtes pas harmonisé avec un objet qui nécessite l''Harmonisation, vous recevez uniquement ses bénéfices non magiques, sauf mention contraire dans sa description. Un bouclier magique avec Harmonisation requise, par exemple, octroie les bénéfices d''un bouclier normal à une créature non harmonisée avec lui, mais aucune de ses propriétés magiques.</p>
<p><strong>S''harmoniser pendant un Repos court.</strong> L''Harmonisation avec un objet requiert que vous consacriez l''intégralité d''un Repos court à vous concentrer sur l''objet tout en restant en contact physique étroit avec lui (cette opération ne peut pas se dérouler pendant le même Repos court consacré à en comprendre les propriétés). Cette concentration peut prendre la forme d''exercices martiaux (pour une arme), d''une méditation (pour une baguette) ou de toute autre activité pertinente. Si le Repos court est interrompu, la tentative d''Harmonisation échoue. Dans le cas contraire, à la fin du Repos court, vous êtes harmonisé avec l''objet magique et avez accès à l''ensemble de ses propriétés magiques.</p>
<p><strong>Trois objets au maximum.</strong> Vous pouvez vous harmoniser avec un maximum de trois objets magiques à la fois. Toute tentative d''Harmonisation avec un quatrième objet échoue ; vous devez au préalable mettre fin à votre lien avec un autre objet. En outre, vous ne pouvez pas vous harmoniser avec plus d''un exemplaire du même objet. Vous ne pouvez par exemple être harmonisé qu''avec un seul anneau de protection.</p>
<p><strong>Fin de l''Harmonisation.</strong> Votre Harmonisation avec un objet prend fin si vous ne remplissez plus les prérequis, si l''objet s''est trouvé à plus de 30 m de vous pendant 24 heures, si vous mourez ou si une autre créature s''harmonise avec l''objet. Vous pouvez en outre mettre fin volontairement à l''Harmonisation en passant un autre Repos court concentré sur l''objet, sauf dans le cas d''un objet maudit.</p>
<h3>Porter et manier des objets magiques</h3>
<p>Certains objets doivent être portés ou maniés pour que l''on puisse recourir à leurs propriétés magiques. Un objet magique destiné à être porté sur le corps doit l''être à l''endroit prévu : les bottes aux pieds, les gants aux mains, les chapeaux et casques sur la tête et les anneaux au doigt. Une armure magique doit être enfilée, un bouclier attaché au bras, une cape attachée autour des épaules. Une arme doit être tenue en main.</p>
<p>Dans la plupart des cas, un objet magique censé être porté conviendra à une créature, quelle que soit sa taille ou sa carrure. Les vêtements magiques sont conçus pour être facilement ajustables ou s''adaptent magiquement au porteur.</p>
<p><strong>Plusieurs objets du même type.</strong> Il est impossible de porter plus d''un de certains objets magiques. Vous ne pouvez normalement pas porter plus d''une paire de chaussures, une paire de gants ou de gantelets, une paire de brassards, une armure, un couvre-chef et une cape. Le MJ peut consentir des exceptions.</p>
<p><strong>Objets appariés.</strong> Les objets fournis par paires, tels que les bottes, brassards, gantelets et gants, n''octroient leurs bénéfices que si les deux éléments de la paire sont portés. Un personnage qui porte une botte de sept lieues à un pied et une botte elfique à l''autre, par exemple, ne retire aucun bénéfice de l''une ni de l''autre.</p>',
        10, @rs, @res, NULL, 1, @now, @now);
SET @r_utiliser_les_objets_magiques := LAST_INSERT_ID();

-- Mises à jour de règles existantes (texte remplacé ; id et place dans l'arbre conservés)
UPDATE dd_regles SET reg_texte = '<p>Les personnages accumulent de la monnaie au fil de leurs aventures, qu''ils pourront dépenser dans les boutiques, auberges et autres commerces. Ces pièces portent des noms différents, selon la valeur relative des métaux qui les composent. La table « Monnaie et valeurs » dresse la liste des pièces et de leur valeur relative par rapport à la pièce d''or, base monétaire du jeu. 100 pièces de cuivre, par exemple, valent 1 pièce d''or.</p>
<p>Une pièce pèse environ 10 grammes, si bien que cent pièces font un kilogramme.</p>
<p>[[tab:monnaie-et-valeurs]]</p>', reg_date_modif = @now
WHERE  reg_slug = 'monnaie' AND reg_ruleset_var_id = @rs;

-- Tableaux (convention texte, SP-TB)
INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note,
                         tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible,
                         tab_date_creation, tab_date_modif)
VALUES
('monnaie-et-valeurs', 'Monnaie et valeurs',
'! Pièce | Valeur en po
Pièce de cuivre (pc) | 1/100
Pièce d''argent (pa) | 1/10
Pièce d''électrum (pe) | 1/2
Pièce d''or (po) | 1
Pièce de platine (pp) | 10',
'lr', NULL, @rs, @res, NULL, 0, 0, 1, @now, @now),
('train-de-vie', 'Train de vie',
'! Train de vie | Coût par jour
Mendiant | gratuit
Misérable | 1 pa
Pauvre | 2 pa
Modeste | 1 po
Confortable | 2 po
Riche | 4 po
Aristocratique | 10 po',
'lr', NULL, @rs, @res, NULL, 0, 0, 1, @now, @now),
('cout-des-parchemins-de-sort', 'Coût des parchemins de sort',
'! Niveau du sort | Temps | Coût
Sort mineur | 1 jour | 15 po
1 | 1 jour | 25 po
2 | 3 jours | 100 po
3 | 5 jours | 150 po
4 | 10 jours | 1 000 po
5 | 25 jours | 1 500 po
6 | 40 jours | 10 000 po
7 | 50 jours | 12 500 po
8 | 60 jours | 15 000 po
9 | 120 jours | 50 000 po',
'crr', NULL, @rs, @res, NULL, 0, 0, 1, @now, @now);

COMMIT;
