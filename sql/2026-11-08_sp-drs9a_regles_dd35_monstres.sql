-- sql/2026-11-08_sp-drs9a_regles_dd35_monstres.sql
-- SP-DRS9a — DRS 29 à 32 : les règles des monstres (présentation, évolution, dons, personnages monstrueux)
-- Chapitre « Les monstres » sous la racine « Créatures et pouvoirs spéciaux » (ordre 30, après « Types et
-- sous-types de créatures »), 4 parties calquées sur les 4 fichiers, 7 tableaux, 10 termes de glossaire.
-- Les fiches (DRS 33 à 40) sont des données du compendium (SP-MO7), les archétypes vont dans Races (SP-DRS9c).
-- Texte corrigé : voir doc/LOG_CORRECTIONS_DRS29_40.md.
-- Rejouable : le sous-arbre, les tableaux et les termes de CE fichier sont réinitialisés par slug ; rien
-- d'autre n'est touché. Aucun reg_id codé en dur. Pas de DELIMITER. Pré-requis : socle SP-DRS0, DRS 19.

SET NAMES utf8mb4;

SET @ddver     := (SELECT var_id FROM dd_variables WHERE var_cat = 'ruleset' AND var_valeur = 'DD3.5' LIMIT 1);
SET @res       := (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'DRS 3.5' AND res_ruleset_var_id = @ddver LIMIT 1);
SET @glo       := (SELECT reg_id FROM dd_regles WHERE reg_slug = 'glossaire' AND reg_ruleset_var_id = @ddver LIMIT 1);
SET @creatures := (SELECT reg_id FROM dd_regles WHERE reg_slug = 'creatures-et-pouvoirs-speciaux' AND reg_ruleset_var_id = @ddver LIMIT 1);
SET @tabc      := (SELECT tabc_id FROM dd_tableaux_categories WHERE tabc_slug = 'monstre' LIMIT 1);
SET @now       := NOW();

START TRANSACTION;

-- Réinitialisation idempotente (enfants d'abord)
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'personnages-monstrueux';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'dons-des-monstres';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'facteur-de-puissance-des-monstres-evolues';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'archetypes-des-monstres';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'augmentation-des-des-de-vie';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'monstres-et-niveaux-de-classe';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'tirage-des-valeurs-de-caracteristique';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'evolution-des-monstres';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'presentation-des-monstres';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'les-monstres';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_type = 'glossaire' AND reg_reg_id = @glo
  AND reg_slug IN ('ajustement-de-niveau', 'archetype', 'creature-de-base', 'des-de-vie-raciaux', 'facteur-de-puissance-fp', 'niveau-global-equivalent-nge', 'niveau-de-classe-associe', 'niveau-de-classe-dissocie', 'tirage-d-elite', 'tirage-simple');
DELETE FROM dd_tableaux WHERE tab_ruleset_var_id = @ddver
  AND tab_slug IN ('evolution-des-monstres-selon-le-type', 'modifications-du-profil-selon-la-taille', 'augmentation-des-degats-selon-la-taille', 'augmentation-du-fp-des-monstres-ameliores', 'pouvoirs-magiques-rapides-et-etendus', 'intelligence-des-personnages-monstrueux', 'caracteristiques-des-personnages-monstrueux');

-- Nœuds
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@creatures, 'chapitre', 'Les monstres', 'les-monstres',
'<p>Les règles communes à toutes les fiches de monstres : la façon dont un profil est présenté, l''évolution d''un monstre (niveaux de classe, dés de vie supplémentaires, archétypes) et son facteur de puissance, les dons propres aux monstres et la création d''un personnage monstrueux. Les fiches elles-mêmes sont dans le compendium Monstres, et les archétypes (vampire, liche, demi-dragon…) dans le compendium Races, type « Archétype ».</p>',
        30, @ddver, @res, NULL, 1, @now, @now);
SET @r_monstres := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_monstres, 'regle', 'Présentation des monstres', 'presentation-des-monstres',
'<p>Chaque créature est présentée selon un format de base, détaillé ci-dessous.</p>
<h3>Profil</h3>
<p>Cette partie de la description du monstre rassemble les données vitales pour le jeu.</p>
<p><strong>Nom.</strong> Le nom sous lequel la créature est connue par la plupart des gens. La description peut éventuellement mentionner d''autres noms.</p>
<p><strong>Type (sous-type) et taille.</strong> Cette ligne indique d''abord le type de la créature, c''est-à-dire la famille à laquelle elle appartient. Cette information détermine la façon dont le monstre est affecté par la magie. Cette donnée décrit également plusieurs valeurs de la créature, comme les dés de vie, les bonus de base à l''attaque et aux sauvegardes et les points de compétence. Une éventuelle note entre parenthèses après le type de la créature indique un sous-type. La ligne de présentation s''achève avec la taille. Un modificateur de taille s''applique à la CA et au modificateur à l''attaque d''une créature, de même qu''à certaines de ses compétences. C''est également la taille qui détermine l''allonge de la créature et l''espace qu''elle occupe au combat (voir Espace occupé/allonge, plus loin).</p>
<p><strong>Dés de vie.</strong> Cette ligne indique le nombre et le type des dés de vie (DV) de la créature et ses points de vie supplémentaires. La parenthèse qui suit donne son total moyen de points de vie. Le nombre de dés de vie d''une créature correspond à son niveau quand il s''agit de déterminer comment les sorts l''affectent, à quelle vitesse elle récupère naturellement ses points de vie perdus et le degré de maîtrise maximal qu''elle peut atteindre dans ses compétences.</p>
<p><strong>Initiative.</strong> Cette ligne mentionne le modificateur à appliquer au test d''initiative du monstre.</p>
<p><strong>Vitesse de déplacement.</strong> Cette ligne indique la vitesse de déplacement tactique au sol de la créature (c''est-à-dire la distance qu''elle peut parcourir lors d''une action de mouvement). Si le monstre porte une armure, celle-ci est identifiée entre parenthèses, puis vient la vitesse de base de la créature. Si la créature dispose de plusieurs modes de déplacement, ceux-ci sont indiqués à la suite les uns des autres. Sauf précision contraire, tous les modes de déplacement sont d''origine naturelle (et non magique).</p>
<p><strong>Classe d''armure.</strong> La ligne classe d''armure indique la CA de la créature, détaillant entre parenthèses les modificateurs permettant d''aboutir à ce total (le plus souvent, ils sont dus à la taille, à la Dextérité et à l''armure naturelle). On donne ensuite la valeur de CA à appliquer contre les attaques de contact ou lorsque la créature est prise au dépourvu. La formation au port des armures d''un monstre dépend de son type, mais en général toute créature portant une armure est formée à son port, ainsi qu''à celui des armures de même catégorie ou plus légère.</p>
<p><strong>Attaque de base/lutte.</strong> Le premier nombre est le bonus de base à l''attaque de la créature (avant que les modificateurs ne soient appliqués). Cette information n''est pas utile lors d''attaques normales (le modificateur total est indiqué sur les lignes suivantes), mais il peut servir aux créatures possédant les dons Attaque en puissance ou Expertise du combat. Le deuxième nombre est le modificateur de lutte de la créature, qui lui sert lorsqu''elle tente d''agripper un adversaire, ou lorsqu''on tente de l''agripper. Le modificateur de lutte comprend tous les modificateurs s''appliquant aux tests de lutte de la créature (bonus de base à l''attaque, modificateur de Force, modificateur spécial de taille, ainsi que n''importe quel autre modificateur applicable, comme un bonus racial sur les tests de lutte).</p>
<p><strong>Attaque.</strong> Cette ligne indique l''attaque unique que la créature peut porter lors d''une action simple d''attaque. Dans la plupart des cas, cette ligne correspond aussi aux attaques d''opportunité portées par la créature. On fournit le nom de l''arme utilisée (naturelle ou manufacturée), puis, entre parenthèses, le modificateur total d''attaque, le type d''attaque (corps à corps ou distance) et les dégâts infligés. Le modificateur à l''attaque comprend le bonus de base à l''attaque, le modificateur de taille, le modificateur de Force (pour les attaques au corps à corps) ou de Dextérité (pour les attaques à distance), ainsi que tous les autres modificateurs applicables. Dans le cas des créatures possédant le don Attaque en finesse, c''est le modificateur de Dextérité qui est utilisé pour les armes de corps à corps sur lesquelles ce don s''applique.</p>
<p>Si la créature utilise des armes naturelles, c''est toujours l''arme naturelle principale qui est utilisée lors d''une action simple d''attaque. Si la créature dispose de plusieurs armes différentes, elles sont toutes indiquées, chaque possibilité étant séparée par le mot « ou ». Il est possible d''utiliser une arme naturelle secondaire lors d''une action simple d''attaque, mais avec un malus sur le jet d''attaque (voir Attaque à outrance, ci-dessous).</p>
<p><em>Dégâts.</em> Une attaque réussie inflige au moins 1 point de dégâts, même si une éventuelle soustraction fait tomber le résultat indiqué par les dés à 0 ou moins. Si l''attaque s''accompagne d''un effet secondaire (venin, maladie, etc.), l''information est donnée juste après les dégâts. Sauf indication contraire, un coup critique réussi se traduit par des dégâts doublés quand l''attaque est portée à l''aide d''une arme naturelle.</p>
<p><strong>Attaque à outrance.</strong> Cette ligne indique les attaques physiques que la créature peut porter lors d''une action d''attaque à outrance. La présentation de chaque arme est la même que pour l''attaque (voir ci-dessus), mais elle est parfois précédée du nombre d''exemplaires de cette arme (qui attaquent tous avec les mêmes valeurs). La première arme d''une séquence est l''arme principale, et les suivantes sont des armes secondaires. Les attaques portées avec une arme naturelle secondaire s''effectuent avec un malus de –5 sur le jet d''attaque, quel que soit leur nombre. Le don Attaques multiples permet de réduire ce malus à –2. Le bonus de Force aux dégâts est multiplié par 1,5 dans le cas des armes naturelles principales à condition que ce soit la seule attaque naturelle de la créature. Il est multiplié par 0,5 pour les attaques secondaires. Lorsque plusieurs armes, principale et secondaires, sont réunies dans une même parenthèse, la première valeur de dégâts concerne l''arme principale et la suivante celle de l''arme secondaire.</p>
<p><em>Armes manufacturées.</em> Les monstres utilisant des armes manufacturées telles que les épées, lances ou les arcs suivent les mêmes règles que les personnages, y compris pour ce qui est des attaques multiples, des malus encourus quand on se bat avec deux armes et des bonus aux dégâts selon la catégorie de l''arme (tout cela étant inclus dans les valeurs fournies).</p>
<p><strong>Espace occupé/allonge.</strong> Cette ligne indique la place dont la créature a besoin pour pouvoir combattre efficacement et à quelle distance elle doit se trouver de son adversaire pour le menacer. Les deux informations (espace occupé et allonge) sont séparées par une barre de fraction : le nombre avant la barre de fraction indique le côté de l''espace occupé par le monstre, puis vient son allonge naturelle. Si la créature bénéficie d''une allonge supérieure à la moyenne grâce à une arme, un tentacule ou autre, cette information est donnée entre parenthèses, de même que ce qui la procure.</p>
<p><strong>Attaques spéciales et particularités.</strong> Nombre de créatures possèdent des pouvoirs spéciaux. Dans le profil du monstre, ils sont décomposés en deux lignes : Attaques spéciales et Particularités, la seconde regroupant défenses, vulnérabilités et capacités autres que des attaques. Les pouvoirs spéciaux peuvent être de nature extraordinaire (Ext), magique (Mag) ou surnaturelle (Sur). Si des informations supplémentaires sont nécessaires, elles sont fournies dans la description du monstre. Lorsqu''un pouvoir spécial autorise un jet de sauvegarde, le type et le DD de celui-ci sont mentionnés dans la description. La plupart des DD de sauvegarde sont calculés selon la formule suivante : 10 + 1/2 DV raciaux de la créature + modificateur de caractéristique approprié de la créature. Le DD exact, ainsi que la caractéristique liée, sont indiqués dans la description du pouvoir.</p>
<p><strong>Jets de sauvegarde.</strong> Cette ligne indique les modificateurs de la créature pour les différents jets de sauvegarde (Réflexes, Vigueur et Volonté). Ils tiennent compte du bonus de base aux sauvegardes, des modificateurs de caractéristiques, des dons et de tous les autres modificateurs applicables.</p>
<p><strong>Caractéristiques.</strong> Cette ligne indique les valeurs de caractéristique de la créature, dans l''ordre habituel (For, Dex, Con, Int, Sag, Cha). Sauf indication contraire, les créatures possèdent des valeurs de caractéristiques moyennes avant l''application des ajustements raciaux (c''est-à-dire uniquement des 10 et des 11). Pour déduire les ajustements raciaux d''une créature d''après ses valeurs de caractéristiques, il suffit de déduire 10 des valeurs paires et 11 des valeurs impaires. Les exceptions éventuelles sont notées dans la section Combat de la description du monstre.</p>
<p><em>Force.</em> Les quadrupèdes peuvent transporter une charge plus importante que les bipèdes. Toute créature disposant d''au moins quatre membres peut porter autant qu''un quadrupède, même si elle n''utilise pas tous ses membres en même temps.</p>
<p><em>Intelligence.</em> Une créature peut parler toutes les langues mentionnées dans sa description, plus une par point de bonus en Intelligence. Du moment qu''elle a au moins 3 en Intelligence, elle comprend au minimum un langage (le commun, sauf indication contraire).</p>
<p><em>Caractéristiques inexistantes.</em> Il arrive que des créatures n''aient pas certaines caractéristiques. Cela ne signifie pas qu''elles ont une valeur de 0, mais bel et bien que cette caractéristique n''existe pas pour elles. Une caractéristique inexistante s''accompagne d''un modificateur de +0.</p>
<p><strong>Compétences.</strong> Cette ligne mentionne toutes les compétences de la créature, ainsi que le modificateur total atteint dans chacune (ce qui inclut le degré de maîtrise, le modificateur de caractéristique, le malus d''armure aux tests, les dons et les bonus raciaux, les bonus de synergie, ainsi que tous les autres modificateurs applicables). Toutes les compétences indiquées ont été achetées au coût de compétences de classe, sauf si la créature a une classe de personnage (auquel cas ce détail est mentionné). Le nombre de points de compétence d''une créature dépend de son type et de sa valeur d''Intelligence.</p>
<p>Le cas échéant, un paragraphe « Compétences » est ajouté à la description de la créature, afin de clarifier l''origine de certains modificateurs. Sauf indication contraire, ces bonus sont déjà intégrés dans le total indiqué dans le profil ; il ne faut donc pas les rajouter. Par contre, si le bonus s''accompagne d''un astérisque (*), il s''agit d''un modificateur soumis à condition ; il doit être ajouté quand les circonstances se vérifient.</p>
<p><em>Tendances naturelles.</em> Certaines créatures ne sont pas adaptées à toutes les activités. S''il vous semble qu''une créature n''est pas adaptée à une activité physique donnée, vous pouvez lui infliger un malus de –8 sur les tests de compétence en question. Dans les cas extrêmes, la créature rate automatiquement ses tests.</p>
<p><strong>Dons.</strong> Cette ligne mentionne les dons de la créature. Quelques créatures disposent de dons supplémentaires, qui sont indiqués par un S en exposant (S). Une créature n''a pas à remplir les conditions d''un don supplémentaire pour pouvoir l''utiliser. Il est possible de modifier une créature en modifiant sa liste de dons, à l''exception des dons supplémentaires, qui sont fixes.</p>
<p><strong>Environnement.</strong> Cette ligne indique le terrain et le climat où la créature réside le plus fréquemment. Ce n''est qu''une tendance, et absolument pas une règle.</p>
<p><strong>Organisation sociale.</strong> Cette ligne indique le type de groupe ou de communauté que les représentants de la race de créature peuvent constituer. Les chiffres et nombres notés entre parenthèses concernent les adultes présents au sein de chaque groupe. Il s''agit là des combattants, mais la plupart des groupes comprennent également des individus incapables de se battre et qui sont généralement exprimés en pourcentage par rapport aux combattants. Il peut s''agir de jeunes, d''infirmes, d''esclaves, ou encore de tout type d''individu peu enclin à se battre. Si cette ligne comprend le terme « domestiqué », la créature est presque toujours rencontrée en compagnie d''autres créatures, qu''elle sert d''une façon ou d''une autre.</p>
<p><strong>Facteur de puissance.</strong> La valeur indiquée correspond au niveau moyen d''un groupe de personnages pour qui une créature de ce type correspond à une rencontre de difficulté moyenne.</p>
<p><strong>Trésor.</strong> Cette ligne liste les possessions de la créature. Dans la plupart des cas, les créatures conservent leur trésor dans leur antre et n''ont presque rien sur elles quand elles se déplacent. Les monstres intelligents possédant des objets utiles ont tendance à les emmener partout, sauf pour ce qui est des objets trop lourds ou trop volumineux.</p>
<p><strong>Alignement.</strong> Cette ligne donne l''alignement que la créature a le plus de chances d''avoir. Cet alignement s''accompagne d''un qualificatif indiquant son degré de représentation au sein de l''espèce.</p>
<p><strong>Évolution possible.</strong> L''entrée d''un monstre ne détaille que les représentants les plus courants de chaque race. Cette ligne indique la puissance que la créature peut atteindre, en termes de DV supplémentaires (il ne s''agit pas là d''une limite absolue, mais les exceptions sont extrêmement rares). Les créatures intelligentes progressent souvent dans une classe de personnage plutôt que de gagner des dés de vie supplémentaires.</p>
<p><strong>Ajustement de niveau.</strong> Cette information est présente pour toutes les créatures pouvant être choisies comme personnage joueur ou comme compagnon d''arme. (Il s''agit généralement de créatures ayant une valeur de 3 ou plus en Intelligence ainsi que des mains préhensiles.) Le niveau global équivalent (NGE) de la créature est alors égal à la somme de ses dés de vie raciaux, de ses niveaux de classe et de son ajustement de niveau. Le NGE affecte les gains en PX, le nombre de PX nécessaires pour changer de niveau et la richesse initiale du personnage.</p>',
        10, @ddver, @res, NULL, 1, @now, @now);
SET @r_presentation := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_monstres, 'chapitre', 'Évolution des monstres', 'evolution-des-monstres',
'<p>Chacune des entrées de monstres dépeint une créature type de son espèce. Néanmoins, en les utilisant pour base, il existe divers moyens de créer des monstres uniques ou extraordinaires : en ajoutant des niveaux de classe, en augmentant le nombre de dés de vie, ou en ajoutant un archétype. Du reste, rien ne vous empêche de recouper ces méthodes. Ainsi, il est possible de faire évoluer un monstre doté d''un archétype en augmentant ses dés de vie et en lui ajoutant des niveaux de classe.</p>
<p><strong>Niveaux de classe.</strong> Les créatures intelligentes de forme plus ou moins humanoïde évoluent généralement par le biais de niveaux de classe. Dans ce cas, la ligne liée à l''évolution possible précise « par une classe de personnage ». Ces niveaux simulent généralement un gain d''expérience et l''apprentissage de compétences et de pouvoirs.</p>
<p><strong>Augmentation des dés de vie.</strong> Les créatures intelligentes, mais qui n''ont pas de forme humanoïde, et les monstres dénués d''intelligence évoluent en gagnant des dés de vie. On considère alors qu''il s''agit de spécimens supérieurs, particulièrement grands et puissants.</p>
<p><strong>Archétypes.</strong> Qu''elles soient intelligentes ou non, les créatures affublées d''un héritage singulier ou frappées d''un changement forcé peuvent être modifiées par le biais d''un archétype. L''ajout d''un archétype produit habituellement un monstre doté de pouvoirs qui diffèrent de ceux de son espèce.</p>
<p>Chacune de ces trois méthodes d''amélioration des monstres est abordée en détail dans les pages qui suivent.</p>',
        20, @ddver, @res, NULL, 1, @now, @now);
SET @r_evolution := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_evolution, 'regle', 'Tirage des valeurs de caractéristique', 'tirage-des-valeurs-de-caracteristique',
'<p>Les monstres disposent de valeurs de caractéristique moyennes (ou standard) : un 10 ou un 11 pour chacune (sans oublier les modificateurs raciaux). Cependant, les monstres améliorés sont des individus à part entière qui possèdent des valeurs de caractéristique supérieures à la normale. Ils bénéficient alors du tirage « d''élite » ou du tirage « simple ».</p>
<p>Les créatures améliorées par le biais d''un archétype ou d''une augmentation de dés de vie s''en remettent à l''une des trois méthodes de tirage (standard, simple ou d''élite). Un monstre unique relève généralement du tirage d''élite.</p>
<p><strong>Tirage d''élite.</strong> Le tirage d''élite produit les valeurs de caractéristique suivantes : 15, 14, 13, 12, 10 et 8. Même si le monstre présente un petit point faible par rapport à un membre type de son espèce, il lui reste supérieur. Ce tirage convient tout particulièrement aux monstres qui bénéficient de niveaux de classe de PJ.</p>
<p><strong>Tirage simple.</strong> Le tirage simple produit les valeurs de caractéristique suivantes : 13, 12, 11, 10, 9 et 8. Cette méthode ne produit pas nécessairement des monstres supérieurs à la normale, mais elle en fait des individus à part entière, dotés de forces et de faiblesses si on les compare à des membres typiques de leur espèce. Ce tirage convient tout particulièrement aux monstres qui bénéficient de niveaux de classe de PNJ.</p>
<p><strong>Amélioration des valeurs de caractéristique.</strong> On considère les dés de vie comme des niveaux pour ce qui est de l''augmentation des valeurs de caractéristiques. Par contre, les monstres ne bénéficient pas d''augmentations de caractéristiques pour les niveaux qu''ils ont « déjà atteints » par le biais de leurs dés de vie raciaux. En effet, ces ajustements sont déjà inclus dans leurs caractéristiques de base.</p>',
        10, @ddver, @res, NULL, 1, @now, @now);
SET @r_tirage := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_evolution, 'regle', 'Monstres et niveaux de classe', 'monstres-et-niveaux-de-classe',
'<p>Si une créature acquiert une classe de personnage, elle suit les règles du multiclassage. Le nombre de ses dés de vie est égal à la somme de ses niveaux de classe et de ses dés de vie raciaux. La « classe monstrueuse » d''une créature est toujours une classe de prédilection ; le fait de l''avoir ne lui impose jamais le moindre malus de PX. Les dés de vie supplémentaires qu''une créature gagne en acquérant une classe de personnage n''ont jamais le moindre effet sur sa taille.</p>
<p><strong>Humanoïdes et niveaux de classe.</strong> Les créatures dotées de 1 DV ou moins remplacent leurs niveaux de monstre par leurs niveaux de personnage. Elles perdent leur bonus à l''attaque, leurs bonus aux sauvegardes, leurs compétences et leurs dons de monstre pour les remplacer par ceux d''un personnage de niveau 1 de la classe choisie.</p>
<p><strong>Ajustement de niveau et niveau global équivalent.</strong> Pour déterminer le niveau global équivalent (NGE) d''un personnage monstrueux, faites la somme de son ajustement de niveau, de ses dés de vie raciaux et de ses niveaux de classe de personnage. Il dispose alors d''un nombre de points d''expérience égal au minimum requis pour un personnage de son NGE.</p>
<p>Si vous choisissez d''équiper un monstre, exploitez son NGE en guise de niveau global pour déterminer la quantité de matériel à laquelle il a droit. En général, seuls les monstres dont la ligne consacrée à l''évolution possible précise « par une classe de personnage » reçoivent de l''équipement de PNJ. Les autres créatures dotées de niveaux de personnage doivent être traitées comme des monstres du FP approprié et avoir un trésor, pas de l''équipement.</p>
<p><strong>Acquisition des dons et augmentation des valeurs de caractéristique.</strong> L''acquisition des dons et les augmentations de caractéristiques d''un monstre dépendent de ses dés de vie, pas de son NGE.</p>',
        20, @ddver, @res, NULL, 1, @now, @now);
SET @r_niveaux := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_evolution, 'regle', 'Augmentation des dés de vie', 'augmentation-des-des-de-vie',
'<p>Lorsqu''une créature gagne des dés de vie, ses bonus à l''attaque et aux sauvegardes s''en trouvent parfois modifiés. Elle gagne également des dons et des compétences (selon son type, voir la table ci-dessous).</p>
<p>Notez que si une créature fait l''acquisition d''une classe de monstre, elle évolue selon cette classe et non selon son type.</p>
<p>[[tab:evolution-des-monstres-selon-le-type]]</p>
<h3>Augmentation de taille</h3>
<p>Certaines créatures changent de catégorie de taille quand elles gagnent des DV supplémentaires (le cas échéant, la nouvelle catégorie de taille est mentionnée entre parenthèses sur la ligne Évolution possible).</p>
<p>Une augmentation de taille affecte certains pouvoirs spéciaux, les valeurs de caractéristique, la CA, le bonus à l''attaque et les dégâts infligés par la créature, comme détaillé sur les tables suivantes.</p>
<p>[[tab:modifications-du-profil-selon-la-taille]]</p>
<p>[[tab:augmentation-des-degats-selon-la-taille]]</p>',
        30, @ddver, @res, NULL, 1, @now, @now);
SET @r_dv := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_evolution, 'regle', 'Archétypes', 'archetypes-des-monstres',
'<p>On crée certains monstres en ajoutant un archétype à une créature existante. Une créature ainsi modifiée est une erreur de la nature, le fruit d''une expérience ou la première génération de rejetons issus de parents de différentes espèces. Les archétypes sont décrits dans le compendium Races, type « Archétype ».</p>
<h3>Archétypes acquis et hérités</h3>
<p>Certains archétypes peuvent être ajoutés à une créature à n''importe quel moment de son existence. Ce genre d''archétype est qualifié d''acquis, dans le sens où la créature n''a pas toujours présenté les attributs propres à celui-ci.</p>
<p>D''autres archétypes, qualifiés d''hérités, font partie intégrante de la créature, et ce depuis sa conception. Les créatures naissent dotées de leur archétype.</p>
<p>Enfin, certains relèvent de l''un des deux types.</p>
<h3>Description des archétypes</h3>
<p>La description d''un archétype fournit un ensemble d''instructions visant à modifier une créature existante, qualifiée de « créature de base ».</p>
<p>Tous les changements apportés au profil de cette créature sont abordés ci-dessous. Généralement, quand une ligne précise du profil ne subit pas la moindre modification, elle ne figure pas dans la description de l''archétype. Dans un souci de clarté, il arrive qu''une telle rubrique apparaisse tout de même accompagnée de la mention « comme la créature de base ».</p>
<p><strong>Taille et type.</strong> Souvent, l''archétype modifie le type de la créature de base. Il arrive qu''il change également sa taille.</p>
<p>Si le type de la créature de base est modifié, elle acquiert également le sous-type altéré, sauf indication contraire. Ce sous-type va toujours de pair avec le type originel de la créature de base. Sauf indication contraire, la nouvelle créature a les traits du nouveau type, mais les aptitudes de l''originel.</p>
<p>Si l''archétype change également la taille de la créature de base, reportez-vous à la table « Modifications apportées au profil selon la taille » (page <em>Augmentation des dés de vie</em>) pour ce qui est de recalculer son armure naturelle, sa classe d''armure, ses jets d''attaque et son bonus de lutte.</p>
<p><strong>Dés de vie et points de vie.</strong> Rares sont les archétypes qui modifient le nombre de dés de vie d''un monstre. Par contre, certains changent la taille de ces mêmes dés de vie. Cela arrive habituellement suite à un changement de type. Quelques archétypes modifient les dés de vie déjà acquis et ceux à venir issus de niveaux de classe. Toutefois, la plupart n''altèrent que les DV originels de la créature de base, sans toucher aux dés de vie découlant de niveaux de classe.</p>
<p>Si cette rubrique n''apparaît pas, dés de vie et points de vie ne changent pas, sauf si le modificateur de Constitution de la créature a lui-même subi une modification.</p>
<p><strong>Initiative.</strong> Si l''archétype change la Dextérité du monstre, ou s''il ajoute ou ôte le don Science de l''initiative, cette ligne est modifiée.</p>
<p><strong>Vitesse de déplacement.</strong> Si l''archétype modifie la vitesse de déplacement de la créature de base, cette rubrique précise en quoi. En général, il offre un nouveau mode de déplacement, comme la faculté de voler.</p>
<p><strong>Classe d''armure.</strong> Si l''archétype modifie la taille de la créature, reportez-vous à la table « Modifications apportées au profil selon la taille » pour déterminer sa nouvelle classe d''armure et voir si son armure naturelle change également. Dans certains cas (fantômes, par exemple), la méthode de calcul de la classe d''armure n''a rien à voir. La description de l''archétype explique alors comment s''y prendre.</p>
<p><strong>Attaque de base/lutte.</strong> Un archétype modifie rarement le bonus à l''attaque de la créature de base. Si cela est le cas, sa description précise la marche à suivre. Tout changement apporté à la valeur de Force d''une créature modifie son bonus de lutte, comme dans le cas d''une altération de la taille.</p>
<p><strong>Attaque et attaque à outrance.</strong> La plupart des archétypes ne modifient en rien le bonus à l''attaque ou les modes d''attaque d''une créature, même lorsque le type de celle-ci change (le bonus de base à l''attaque de la créature est identique à celui de son type originel). Bien évidemment, si les valeurs de caractéristique sont retouchées, il en va de même pour les bonus à l''attaque. Si la Force ou la Dextérité sont modifiées, utilisez les nouveaux modificateurs pour calculer les bonus à l''attaque. Si la taille de la créature a été modifiée, vous devez également recalculer son bonus à l''attaque (voir la table « Modifications apportées au profil selon la taille »).</p>
<p><strong>Dégâts.</strong> Les dégâts infligés au corps à corps dépendent de la Force. Si la créature utilise une arme à deux mains ou ne présente qu''une seule arme naturelle, elle ajoute 1,5 fois son bonus de Force aux dégâts. Si elle possède plusieurs attaques, elle ajoute son bonus de Force aux jets de dégâts pour ce qui est de l''attaque principale, et la moitié de ce même bonus de Force aux dégâts de toutes les attaques secondaires.</p>
<p><strong>Espace occupé/allonge.</strong> L''archétype modifie cette ligne si la taille du monstre change. Notez tout de même qu''elle ne tient pas compte des facteurs spéciaux, comme les filaments d''un enlaceur.</p>
<p><strong>Attaques spéciales.</strong> Il est possible que l''archétype ajoute ou ôte des attaques spéciales. Sa description fournit alors toutes les modifications apportées, y compris le mode de calcul des DD de sauvegarde (le cas échéant).</p>
<p><strong>Particularités.</strong> Il est possible que l''archétype ajoute ou ôte des particularités. Sa description fournit alors toutes les modifications apportées, y compris le mode de calcul des DD de sauvegarde (le cas échéant). Si cette rubrique n''apparaît pas dans la description de l''archétype, la créature n''en gagne pas moins les particularités de son nouveau type.</p>
<p><strong>Jets de sauvegarde de base.</strong> Comme dans le cas des attaques, le type d''un monstre ne modifie pas toujours ses bonus de base aux sauvegardes. Ajustez-les simplement en fonction des nouvelles valeurs de Constitution, Dextérité et Sagesse. Cependant, l''archétype précisera peut-être que le monstre dispose de jets de sauvegarde favorables différents.</p>
<p><strong>Caractéristiques.</strong> Si l''archétype modifie une ou plusieurs valeurs de caractéristique, ces changements figurent dans cette rubrique.</p>
<p><strong>Compétences.</strong> Comme dans le cas des attaques, le type d''un monstre ne modifie pas toujours le nombre de ses points de compétence. La plupart des archétypes n''altèrent en rien le nombre de dés de vie de la créature, aussi n''est-il pas nécessaire de toucher aux compétences, sauf si la caractéristique dont elles dépendent n''est plus la même, si l''archétype confère des bonus ou s''il offre un don qui lui-même confère un bonus à certains tests de compétence.</p>
<p>Certains archétypes modifient le nombre de points de compétence gagnés. Toutefois, ce changement n''affecte généralement que les points gagnés après son ajout. Considérez les compétences fournies dans la description de la créature de base comme des compétences de classe. Cela est également valable pour les compétences fournies par l''archétype.</p>
<p><strong>Dons.</strong> Comme la plupart des archétypes ne modifient pas le nombre de dés de vie de la créature, ils ne changent pas non plus le nombre de dons auxquels elle a droit. Cependant, certains archétypes confèrent des dons supplémentaires.</p>
<p><strong>Environnement.</strong> Généralement comme la créature de base.</p>
<p><strong>Organisation sociale.</strong> Généralement comme la créature de base.</p>
<p><strong>Facteur de puissance.</strong> La plupart des archétypes augmentent le facteur de puissance de la créature. Il peut s''agir d''un modificateur qu''on ajoute au FP de la créature de base, ou d''un éventail de modificateurs dépendant des dés de vie ou du FP originels de celle-ci.</p>
<p><strong>Trésor.</strong> Généralement comme la créature de base.</p>
<p><strong>Alignement.</strong> Généralement comme la créature de base, sauf si l''archétype est associé à un alignement précis.</p>
<p><strong>Évolution possible.</strong> Généralement comme la créature de base.</p>
<p><strong>Ajustement de niveau.</strong> Cette rubrique dévoile le modificateur à l''ajustement de niveau de la créature de base. Ceci dit, il n''a de sens que si la créature conserve une Intelligence suffisamment élevée (3 au moins) pour gagner des niveaux de classe après avoir acquis l''archétype.</p>
<h3>Ajout de plusieurs archétypes</h3>
<p>En théorie, il n''existe pas de limite au nombre d''archétypes que l''on peut ajouter à une créature. Dans ce cas, appliquez-les à la suite, en tenant compte des archétypes hérités, puis des archétypes acquis. Prenez garde au type de la créature, dans le sens où certains archétypes sont incompatibles.</p>',
        40, @ddver, @res, NULL, 1, @now, @now);
SET @r_archetypes := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_evolution, 'regle', 'Facteur de puissance des monstres évolués', 'facteur-de-puissance-des-monstres-evolues',
'<p>Quand on ajoute des niveaux de classe à une créature ayant 1 DV ou moins, celle-ci évolue comme un personnage. Dans le cas contraire, conformez-vous aux instructions qui suivent.</p>
<h3>Ajout de niveaux de classe</h3>
<p>Si vous décidez de faire évoluer un monstre en lui ajoutant des niveaux de classe de PJ, vous devez décider si ces derniers améliorent les pouvoirs qu''il possède déjà.</p>
<p>Lorsque vous ajoutez des niveaux de classe à une créature, conférez-lui les valeurs de caractéristique appropriées à cette classe. La plupart des créatures sont bâties à l''aide du tirage standard de valeurs de caractéristique (11, 11, 11, 10, 10 et 10) ajusté selon leurs modificateurs raciaux. Si vous ajoutez une classe de PJ (comme druide ou guerrier) à une créature, utilisez le tirage d''élite (15, 14, 13, 12, 10 et 8) avant d''appliquer les ajustements raciaux. Les créatures dotées de classes de PNJ exploitent le tirage simple (13, 12, 11, 10, 9, 8).</p>
<p><strong>Niveaux de classe associés.</strong> Les niveaux de classe qui accroissent les forces existantes d''un monstre sont qualifiés d''associés. Chacun de ces niveaux augmente le FP d''un monstre de 1 point.</p>
<p>Barbare, guerrier, paladin et rôdeur sont des classes associées aux créatures comptant sur leurs capacités de combat.</p>
<p>Rôdeur et roublard sont les classes associées des créatures comptant sur la discrétion pour surprendre leurs adversaires et sur l''utilisation de compétences.</p>
<p>Les classes de lanceur de sorts sont associées aux créatures qui ont déjà la faculté de jeter des sorts comme des personnages issus de la classe en question. En effet, les niveaux de monstre de la classe de lanceur de sorts sont cumulables avec les facultés magiques innées.</p>
<p><strong>Niveaux de classe dissociés.</strong> Si vous ajoutez un niveau de classe qui ne joue pas directement dans le sens des forces d''une créature, celui-ci est qualifié de dissocié. Les choses se compliquent alors un tantinet. L''ajout d''un niveau de classe dissocié à un monstre augmente son FP de ½ point jusqu''à ce que ses niveaux de classe dissociés égalent le nombre de ses dés de vie originels. Dès lors, chaque niveau supplémentaire de cette même classe (ou d''une classe similaire) est considéré comme associé et augmente le FP du monstre de 1 point.</p>
<p>Les niveaux de classe de PNJ sont toujours dissociés.</p>
<h3>Ajout de dés de vie</h3>
<p>Lorsque vous améliorez un monstre en lui ajoutant des dés de vie, reportez-vous à la table ci-dessous pour en déterminer les effets sur son FP. N''oubliez pas que de nombreux monstres qui évoluent de cette manière augmentent également de catégorie de taille. Ne cumulez pas cette augmentation du FP avec celle découlant de l''ajout de niveaux de classe.</p>
<p>En général, une fois le FP d''une créature doublé, surveillez toute augmentation supplémentaire de ses pouvoirs. L''ajout de dés de vie à une créature améliore plusieurs de ses pouvoirs, et des augmentations radicales ne pourront sans doute pas suivre cette progression indéfiniment. Comparez le bonus à l''attaque, les bonus aux sauvegardes et le DD des pouvoirs spéciaux d''un monstre amélioré par un ajout de DV à des personnages de niveau semblable, et ajustez le FP en conséquence.</p>
<p>[[tab:augmentation-du-fp-des-monstres-ameliores]]</p>
<h3>Augmentation de la taille</h3>
<p>En général, l''augmentation de la taille d''un monstre accroît son efficacité au combat. Les créatures de grande taille bénéficient d''une Force plus élevée, d''une meilleure allonge et d''autres avantages. Appliquez ces modificateurs si la catégorie de taille d''une créature est supérieure à M, sachant qu''ils sont cumulables avec d''autres augmentations.</p>
<p>Cependant, soyez prudent car les monstres bénéficiant d''une petite taille risquent de perdre en efficacité en raison de leur augmentation de taille. C''est pour cela que les monstres qui ne tirent aucun avantage d''une augmentation de taille n''évoluent pas de cette manière.</p>
<h3>Ajout de pouvoirs spéciaux</h3>
<p>On peut ajouter toutes sortes de pouvoirs magiques, surnaturels ou extraordinaires à une créature. Comme dans le cas de niveaux de classe, vous devez déterminer l''importance du pouvoir au regard du répertoire dont le monstre dispose déjà. Un ensemble de pouvoirs œuvrant de concert n''appellera qu''un seul modificateur. Si le pouvoir (ou l''ensemble de pouvoirs) accroît grandement l''efficacité de la créature au combat, augmentez le FP de celle-ci de 2 points. S''il s''agit d''un pouvoir mineur, augmentez-le de 1 point. Enfin, s''il ne présente pas grand intérêt, ne touchez pas au FP. Si les pouvoirs spéciaux qu''un monstre gagne ne sont pas liés à une classe ou à une augmentation de dés de vie, l''augmentation du FP est cumulative.</p>
<p>On parle d''attaque spéciale d''importance lorsque celle-ci est capable de mettre un adversaire hors de combat en 1 round. On parle de particularité d''importance lorsque celle-ci réduit la vulnérabilité du monstre face à des attaques courantes. N''ajoutez pas ce facteur deux fois si le monstre possède des attaques spéciales et des particularités.</p>
<p>Assurez-vous d''évaluer ces pouvoirs en tenant compte du FP actuel du monstre.</p>',
        50, @ddver, @res, NULL, 1, @now, @now);
SET @r_fp := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_monstres, 'regle', 'Dons des monstres', 'dons-des-monstres',
'<p>Ces dons sont surtout accessibles aux monstres : la plupart demandent une arme naturelle, une attaque spéciale, une vitesse de vol ou des pouvoirs magiques. Une créature qui en remplit les conditions peut les choisir comme n''importe quel autre don. Chaque don est décrit dans le compendium Dons, catégorie « Monstres ».</p>
<p>[[liste:don|famille=monstres|titre=Dons des monstres]]</p>
<h3>Pouvoirs magiques rapides et étendus</h3>
<p>Les dons Pouvoir magique rapide et Extension de pouvoir magique ne s''appliquent qu''à un pouvoir magique reproduisant un sort de niveau suffisamment bas au regard du niveau de lanceur de sorts de la créature pour ce pouvoir : la table indique le niveau de lanceur de sorts requis selon le niveau du sort.</p>
<p>[[tab:pouvoirs-magiques-rapides-et-etendus]]</p>',
        30, @ddver, @res, NULL, 1, @now, @now);
SET @r_dons := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_monstres, 'regle', 'Personnages monstrueux', 'personnages-monstrueux',
'<p>La description de chaque monstre contient quasiment toutes les informations nécessaires pour le jouer, mais beaucoup ne font pas des personnages convenables et équilibrés. N''autorisez jamais les joueurs à incarner des monstres stupides (2 ou moins en Intelligence), incapables de communiquer ou si différents des autres personnages qu''ils mettront la campagne en danger. Certains monstres possèdent de puissants pouvoirs, incompatibles avec la carrière d''aventurier, sauf dans les campagnes où tous les personnages ont eux aussi accès à de nombreux pouvoirs et objets magiques.</p>
<p><strong>Niveau des personnages monstrueux.</strong> Le niveau global d''un personnage monstrueux est égal à la somme de ses dés de vie raciaux et de ses niveaux de classe. Son niveau global équivalent (NGE) est égal à son niveau global plus son ajustement de niveau. Les DV raciaux d''un personnage monstrueux sont considérés comme des niveaux de monstre, du type du monstre (humanoïde, géant, etc.) plutôt que d''une classe. Dès qu''ils obtiennent un niveau de classe, ils sont considérés comme des personnages multiclassés, mais leurs niveaux de monstre ne les exposent jamais à une pénalité sur les PX pour niveaux déséquilibrés.</p>
<p><strong>Humanoïdes et niveaux de classe.</strong> Les créatures dotées de 1 DV ou moins remplacent leurs niveaux de monstre par leurs niveaux de personnage. Elles perdent leur bonus de base à l''attaque et aux sauvegardes, leurs compétences et leurs dons de monstre pour les remplacer par ceux d''un personnage de niveau 1 de la classe choisie.</p>
<p>Les créatures dotées de 2 DV ou plus reçoivent les avantages dus au premier niveau (comme un don, les points de compétence quadruplés ou le maximum sur le premier dé de vie) pour leur premier DV racial (ces avantages sont inclus dans leur profil). Elles ne les reçoivent pas une seconde fois en obtenant leur premier niveau de classe. Les compétences de classe des niveaux de monstre d''un personnage monstrueux sont celles mentionnées dans leur profil.</p>
<p><strong>Ajustement de niveau et niveau global équivalent.</strong> Pour déterminer le niveau global équivalent (NGE) d''un personnage monstrueux, faites la somme de son ajustement de niveau, de ses dés de vie raciaux et de ses niveaux de classe de personnage.</p>
<p>Pour un personnage monstrueux, le NGE remplace le niveau global lorsqu''on détermine le nombre de points d''expérience nécessaires pour atteindre le niveau suivant. Le NGE remplace aussi le niveau global pour déterminer la richesse et l''équipement initial. On utilise le niveau global (non modifié par l''ajustement de niveau) pour tout le reste (par exemple, pour déterminer les niveaux d''obtention des dons et des augmentations de caractéristique), comme pour un personnage multiclassé ordinaire.</p>
<p>Un monstre sans DV raciaux ou correspondant à un archétype (comme un vampire ou un lycanthrope) doit commencer le jeu avec au moins un niveau de classe, comme un personnage normal. Un monstre bénéficiant de DV raciaux peut commencer le jeu sans niveau de classe, qu''il peut bien sûr acquérir normalement par la suite.</p>
<p>L''évolution normale de certains monstres passe habituellement par des dés de vie supplémentaires plutôt que par des niveaux de classe. Néanmoins, les personnages des joueurs sont des individus exceptionnels et ils peuvent toujours obtenir des niveaux de classe.</p>
<p><strong>Dés de vie.</strong> Le nombre de dés de vie d''un personnage monstrueux est égal à la somme de ses dés de vie raciaux et de ses niveaux de classe. Les dés de vie obtenus par une classe de personnage n''augmentent pas la taille de la créature, au contraire de dés de vie raciaux supplémentaires.</p>
<p><strong>Acquisition des dons et augmentation des valeurs de caractéristique.</strong> L''acquisition des dons et les augmentations de caractéristiques d''un monstre dépendent de ses dés de vie, pas de son NGE.</p>
<p><strong>Valeurs de caractéristiques des personnages monstrueux.</strong> Le profil des monstres détaille les valeurs de caractéristiques d''une créature moyenne de chaque race, mais un monstre devenu aventurier est forcément hors norme. Si vous créez un personnage monstrueux à partir de son profil, regardez si la créature a des valeurs de caractéristiques supérieures à 10. Si tel est le cas, ôtez 10 à la valeur indiquée (si elle est paire) ou 11 (si elle est impaire) afin d''obtenir l''ajustement racial à appliquer à cette caractéristique. Déterminez les valeurs du personnage comme d''habitude et ajoutez le modificateur racial au total pour obtenir la valeur de l''aventurier.</p>
<p>Pour les valeurs inférieures à 10, la procédure est différente. On commence par déterminer la valeur de caractéristique du personnage normalement, puis on compare le résultat obtenu à la valeur moyenne de cette race de monstre sur l''une des tables suivantes, l''une concernant l''Intelligence et l''autre les cinq autres caractéristiques.</p>
<p>Une table différente a été conçue pour l''Intelligence afin qu''aucun personnage n''ait une Intelligence de départ inférieure à 3. Cette distinction est extrêmement importante, car un aventurier ayant moins de 3 en Intelligence n''est pas jouable. C''est également le cas de ceux qui ont moins de 1 dans une autre caractéristique, et vous devriez réfléchir à deux fois avant d''accepter qu''un personnage puisse avoir moins de 3 dans une caractéristique, quelle qu''elle soit.</p>
<p>[[tab:intelligence-des-personnages-monstrueux]]</p>
<p>[[tab:caracteristiques-des-personnages-monstrueux]]</p>
<p><strong>Autres informations pour les personnages monstrueux.</strong> Les personnages monstrueux n''ayant aucun DV raciaux obtiennent normalement les dés de vie et les avantages liés au niveau selon leurs niveaux de classe. Ils obtiennent les compétences et les dons habituels pour un personnage de niveau 1 (même s''ils ont un ajustement de niveau). Pour les personnages monstrueux possédant des DV raciaux, on calcule ces avantages en fonction de leur niveau global, qui est égal à la somme de leurs DV raciaux et de leurs éventuels niveaux de classe.</p>
<p><strong>Points d''expérience pour les personnages monstrueux.</strong> Pour un personnage monstrueux sans dés de vie raciaux et sans ajustement de niveau, le niveau global est égal à la somme des niveaux de classe et le NGE est égal au niveau global. Il utilise les mêmes tables d''expérience que les races classiques.</p>
<p>Pour un personnage monstrueux sans DV raciaux et avec un ajustement de niveau, le niveau global est égal à la somme des niveaux de classe et le NGE est égal au niveau global plus l''ajustement de niveau. Le personnage utilise son NGE pour déterminer sa progression en niveau et son niveau global pour déterminer les avantages acquis.</p>
<p>Pour un personnage monstrueux ayant des DV raciaux et un ajustement de niveau, le niveau global est égal à la somme des niveaux de classe et des DV raciaux, tandis que le NGE est égal au niveau global plus l''ajustement de niveau. Le NGE sert à déterminer la progression du personnage en niveau et le niveau global sert à déterminer les avantages acquis.</p>',
        40, @ddver, @res, NULL, 1, @now, @now);
SET @r_persos := LAST_INSERT_ID();

-- Tableaux
INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id,
                         tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible,
                         tab_date_creation, tab_date_modif)
VALUES
('evolution-des-monstres-selon-le-type', 'Évolution des monstres selon le type',
'! Type | Dés de vie | Bonus à l''attaque | JS favorables | Points de compétence (1)
Aberration | d8 | DV × ¾ (comme prêtre) | Vol | 2 + mod. d''Int par DV
Animal | d8 | DV × ¾ (comme prêtre) | Réf, Vig (et parfois Vol) | 2 + mod. d''Int par DV
Créature artificielle | d10 | DV × ¾ (comme prêtre) | — | 2 + mod. d''Int par DV (2)
Créature magique | d10 | DV (comme guerrier) | Réf, Vig | 2 + mod. d''Int par DV
Dragon | d12 | DV (comme guerrier) | Réf, Vig, Vol | 6 + mod. d''Int par DV
Élémentaire | d8 | DV × ¾ (comme prêtre) | Réf (Air, Feu) ou Vig (Eau, Terre) | 2 + mod. d''Int par DV
Extérieur | d8 | DV (comme guerrier) | Réf, Vig, Vol | 8 + mod. d''Int par DV
Fée | d6 | DV × ½ (comme magicien) | Réf, Vol | 6 + mod. d''Int par DV
Géant | d8 | DV × ¾ (comme prêtre) | Vig | 2 + mod. d''Int par DV
Humanoïde | d8 | DV × ¾ (comme prêtre) | Variable (un au choix) | 2 + mod. d''Int par DV
Humanoïde monstrueux | d8 | DV (comme guerrier) | Réf, Vol | 2 + mod. d''Int par DV
Mort-vivant | d12 | DV × ½ (comme magicien) | Vol | 4 + mod. d''Int par DV (2)
Plante | d8 | DV × ¾ (comme prêtre) | Vig | 2 + mod. d''Int par DV (2)
Vase | d10 | DV × ¾ (comme prêtre) | — | 2 + mod. d''Int par DV (2)
Vermine | d8 | DV × ¾ (comme prêtre) | Vig | 2 + mod. d''Int par DV (2)
> Tous les types ont un nombre de dons égal à 1 + 1 tous les 3 DV.
> (1) Dès lors que la créature a une Intelligence de 1 au moins, elle gagne un minimum de 1 point de compétence par dé de vie.
> (2) Les créatures dénuées de valeur d''Intelligence ne gagnent ni points de compétence ni dons.',
'lclll', NULL, @tabc, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('modifications-du-profil-selon-la-taille', 'Modifications apportées au profil selon la taille',
'! Ancienne taille (1) | Nouvelle taille | For | Dex | Con | Armure naturelle | CA/attaque
Infime | Minuscule | — | –2 | — | — | –4
Minuscule | Très petite | +2 | –2 | — | — | –2
Très petite | Petite | +4 | –2 | — | — | –1
Petite | Moyenne | +4 | –2 | +2 | — | –1
Moyenne | Grande | +8 | –2 | +4 | +2 | –1
Grande | Très grande | +8 | –2 | +4 | +3 | –1
Très grande | Gigantesque | +8 | — | +4 | +4 | –2
Gigantesque | Colossale | +8 | — | +4 | +5 | –4
> (1) Ces ajustements sont cumulables si la créature gagne plusieurs catégories de taille.',
'llccccc', NULL, @tabc, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('augmentation-des-degats-selon-la-taille', 'Augmentation des dégâts selon la taille',
'! Anciens dégâts (par attaque) (1) | Nouveaux dégâts
1d2 | 1d3
1d3 | 1d4
1d4 | 1d6
1d6 | 1d8
1d8 | 2d6
1d10 | 2d8
2d6 | 3d6
2d8 | 3d8
> (1) Ces ajustements sont cumulables si la créature gagne plusieurs catégories de taille.',
'cc', NULL, @tabc, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('augmentation-du-fp-des-monstres-ameliores', 'Augmentation du FP des monstres améliorés',
'! Type originel de la créature | Augmentation du FP
Aberration, créature artificielle, élémentaire, fée, géant, humanoïde, mort-vivant, plante, vase, vermine | +1 / 4 DV ajoutés
Animal, créature magique, humanoïde monstrueux | +1 / 3 DV ajoutés
Dragon, Extérieur, niveaux de classe dissociés | +1 / 2 DV ou 2 niveaux ajoutés
Niveaux de classe directement associés | +1 / niveau ajouté
# Autres modificateurs
Augmentation de la catégorie de taille à G ou plus | +1 au FP
Valeurs de caractéristique du monstre basées sur le tirage d''élite (1) | +1 au FP
Le monstre possède des attaques spéciales ou particularités qui augmentent grandement son efficacité au combat | +2 au FP
Le monstre possède des attaques spéciales ou particularités qui augmentent modérément son efficacité au combat | +1 au FP
Ajout d''un archétype | + modificateur au FP de l''archétype
> (1) N''appliquez pas cette augmentation si le monstre évolue par une classe de personnage (les monstres évoluant par une classe de personnage sont censés exploiter le tirage d''élite).',
'll', NULL, @tabc, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('pouvoirs-magiques-rapides-et-etendus', 'Pouvoirs magiques rapides et étendus',
'! Niveau de sort | Niveau de lanceur de sorts requis | |
! ^ | Pouvoir magique rapide | Extension de pouvoir magique
0 | 8 | 4
1er | 10 | 6
2e | 12 | 8
3e | 14 | 10
4e | 16 | 12
5e | 18 | 14
6e | 20 | 16
7e | — | 18
8e | — | 20
9e | — | —',
'ccc', NULL, @tabc, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('intelligence-des-personnages-monstrueux', 'Valeur d''Intelligence des personnages monstrueux',
'! Jet de dés | Valeur d’Intelligence moyenne du monstre | | | |
! ^ | 3 | 4–5 | 6–7 | 8–9
18 | 10 | 12 | 14 | 16
17 | 9 | 11 | 13 | 15
16 | 8 | 10 | 12 | 14
15 | 7 | 9 | 11 | 13
14 | 6 | 8 | 10 | 12
13 | 5 | 7 | 9 | 11
12 | 4 | 6 | 8 | 10
11 | 3 | 5 | 7 | 9
10 | 3 | 5 | 7 | 9
9 | 3 | 5 | 6 | 8
8 | 3 | 4 | 6 | 8
7 | 3 | 4 | 5 | 7
6 | 3 | 4 | 5 | 6
5 | 3 | 3 | 5 | 5
4 | 3 | 3 | 4 | 4
3 | 3 | 3 | 3 | 3',
'ccccc', NULL, @tabc, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('caracteristiques-des-personnages-monstrueux', 'Valeurs de caractéristique des personnages monstrueux',
'! Jet de dés | Valeur de caractéristique moyenne du monstre | | | | |
! ^ | 1 | 2–3 | 4–5 | 6–7 | 8–9
18 | 8 | 10 | 12 | 14 | 16
17 | 7 | 9 | 11 | 13 | 15
16 | 6 | 8 | 10 | 12 | 14
15 | 5 | 7 | 9 | 11 | 13
14 | 4 | 6 | 8 | 10 | 12
13 | 3 | 5 | 7 | 9 | 11
12 | 2 | 4 | 6 | 8 | 10
11 | 1 | 3 | 5 | 7 | 9
10 | 1 | 2 | 4 | 6 | 8
9 | 1 | 2 | 4 | 6 | 7
8 | 1 | 2 | 4 | 5 | 6
7 | 1 | 1 | 3 | 5 | 5
6 | 1 | 1 | 2 | 4 | 4
5 | 1 | 1 | 1 | 3 | 3
4 | 1 | 1 | 1 | 2 | 2
3 | 1 | 1 | 1 | 1 | 1
> Pour une valeur moyenne de 10 ou plus, ajouter l''ajustement racial (valeur – 10 si paire, – 11 si impaire) au résultat du jet.',
'cccccc', NULL, @tabc, @ddver, @res, NULL, 0, 0, 1, @now, @now);

-- Glossaire
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES
(@glo, 'glossaire', 'Ajustement de niveau', 'ajustement-de-niveau', '<p>Nombre ajouté aux dés de vie raciaux et aux niveaux de classe d''une créature jouable pour obtenir son niveau global équivalent (NGE). Voir <em>Personnages monstrueux</em>.</p>', 750, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Archétype', 'archetype', '<p>Ensemble de modifications appliquées à une « créature de base » (vampire, liche, demi-dragon…). Un archétype est acquis (ajouté en cours d''existence) ou hérité (présent dès la naissance). Voir <em>Archétypes</em>, page de l''évolution des monstres.</p>', 760, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Créature de base', 'creature-de-base', '<p>Créature à laquelle on applique un archétype ; elle conserve son profil, sauf ce que l''archétype modifie. Voir <em>Archétypes</em>.</p>', 770, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Dés de vie raciaux', 'des-de-vie-raciaux', '<p>Dés de vie qu''une créature tient de son espèce et non d''une classe : ils comptent comme des niveaux de monstre et, s''ils augmentent, peuvent faire grandir la créature. Voir <em>Monstres et niveaux de classe</em>.</p>', 780, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Facteur de puissance (FP)', 'facteur-de-puissance-fp', '<p>Niveau moyen d''un groupe de personnages pour qui la créature représente une rencontre de difficulté moyenne. Voir <em>Présentation des monstres</em> et <em>Facteur de puissance des monstres évolués</em>.</p>', 790, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Niveau global équivalent (NGE)', 'niveau-global-equivalent-nge', '<p>Dés de vie raciaux + niveaux de classe + ajustement de niveau d''un personnage monstrueux ; il remplace le niveau global pour les PX et la richesse, pas pour les dons ni les augmentations de caractéristique. Voir <em>Personnages monstrueux</em>.</p>', 800, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Niveau de classe associé', 'niveau-de-classe-associe', '<p>Niveau de classe qui renforce les points forts d''un monstre (guerrier pour un combattant, classe de lanceur de sorts pour une créature qui lance déjà des sorts) : +1 au FP par niveau. Voir <em>Facteur de puissance des monstres évolués</em>.</p>', 810, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Niveau de classe dissocié', 'niveau-de-classe-dissocie', '<p>Niveau de classe sans lien avec les forces d''un monstre (toujours le cas des classes de PNJ) : +½ au FP par niveau, jusqu''à égaler les DV originels. Voir <em>Facteur de puissance des monstres évolués</em>.</p>', 820, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Tirage d''élite', 'tirage-d-elite', '<p>Valeurs de caractéristique 15, 14, 13, 12, 10 et 8, avant ajustements raciaux, pour un monstre hors norme ou doté de niveaux de classe de PJ. Voir <em>Tirage des valeurs de caractéristique</em>.</p>', 830, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Tirage simple', 'tirage-simple', '<p>Valeurs de caractéristique 13, 12, 11, 10, 9 et 8, avant ajustements raciaux, pour un monstre doté de niveaux de classe de PNJ. Voir <em>Tirage des valeurs de caractéristique</em>.</p>', 840, @ddver, @res, NULL, 1, @now, @now);

COMMIT;
