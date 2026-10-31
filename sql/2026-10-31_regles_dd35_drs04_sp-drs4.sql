-- sql/2026-10-31_regles_dd35_drs04_sp-drs4.sql
-- SP-DRS4 — DRS 04 : Les compétences (règles générales)
-- Règles DD3.5 (mécanismes de jeu uniquement). Les descriptions des 36 compétences — caractéristique
-- associée, DD, particularités — vivent dans le compendium (dd_competences) et ne sont pas reprises ici.
-- Texte corrigé : voir doc/LOG_CORRECTIONS_DRS04.md.
-- Rejouable : le sous-arbre, les tableaux et les termes de glossaire de CE fichier sont
-- réinitialisés par slug ; rien d'autre n'est touché. Aucun reg_id codé en dur. Pas de DELIMITER.
-- Pré-requis : 2026-08-25_regles_dd35_socle.sql.

SET NAMES utf8mb4;

SET @ddver := (SELECT var_id FROM dd_variables WHERE var_cat = 'ruleset' AND var_valeur = 'DD3.5' LIMIT 1);
SET @res   := (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'DRS 3.5' AND res_ruleset_var_id = @ddver LIMIT 1);
SET @glo   := (SELECT reg_id FROM dd_regles WHERE reg_slug = 'glossaire' AND reg_ruleset_var_id = @ddver LIMIT 1);
SET @now   := NOW();

START TRANSACTION;

-- Réinitialisation idempotente
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'description-des-competences';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'tests-de-caracteristique';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'la-synergie';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'combiner-ses-competences';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'test-sans-jet-de-de';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'temps-d-utilisation-des-competences';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'conditions-favorables-ou-defavorables';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'nouvelles-tentatives-et-test-inne';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'utilisation-des-competences';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'points-de-competence-et-degres-de-maitrise';
DELETE FROM dd_regles WHERE reg_ruleset_var_id = @ddver AND reg_slug = 'les-competences';
DELETE FROM dd_regles
WHERE  reg_ruleset_var_id = @ddver AND reg_type = 'glossaire' AND reg_reg_id = @glo
  AND  reg_slug IN (
    'competence-de-classe',
    'competence-hors-classe',
    'degre-de-difficulte-dd',
    'degre-de-maitrise',
    'faire-10',
    'faire-20',
    'modificateur-de-competence',
    'synergie-competences',
    'test-de-caracteristique',
    'test-inne-de-competence',
    'test-oppose');
DELETE FROM dd_tableaux
WHERE  tab_ruleset_var_id = @ddver
  AND  tab_slug IN (
    'exemples-de-degres-de-difficulte',
    'exemples-de-tests-opposes');

-- Nœuds
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (NULL, 'chapitre', 'Les compétences', 'les-competences',
'<p>Les règles communes à toutes les compétences : points de compétence et degrés de maîtrise, test de compétence, degrés de difficulté, tests opposés, nouvelles tentatives, conditions, temps d''utilisation, « faire 10 » et « faire 20 », entraide, synergie et tests de caractéristique. Chaque compétence a sa fiche dans le compendium ; elle précise sa caractéristique, la formation nécessaire, les DD habituels et les cas particuliers.</p>',
        15, @ddver, @res, NULL, 1, @now, @now);
SET @r_competences := LAST_INSERT_ID();
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_competences, 'regle', 'Points de compétence et degrés de maîtrise', 'points-de-competence-et-degres-de-maitrise',
'<p>Quand on acquiert une compétence dite « de classe », chaque point de compétence dépensé augmente d''un le degré de maîtrise du personnage (soit un bonus de +1 lors des tests de cette compétence). Si l''on choisit une compétence dite « hors classe », 1 point de compétence n''augmente le degré de maîtrise que de un demi.</p>
<p>Le degré de maîtrise maximal qu''un personnage peut atteindre dans une compétence de classe est égal à son niveau global + 3 et à la moitié de ce résultat pour les compétences hors classe (n''arrondissez pas en cas de fraction).</p>
<p><strong>Utilisation des compétences.</strong> Voici la formule pour jouer un test de compétence : 1d20 + modificateur de compétence (modificateur de compétence = degré de maîtrise + modificateur de caractéristique + modificateurs divers).</p>
<p>Ce test s''effectue de la même façon qu''un jet d''attaque ou de sauvegarde. Plus le total obtenu est élevé, plus le résultat est favorable au personnage. Il faut soit atteindre un degré de difficulté (DD), soit battre le résultat du test de compétence de l''adversaire.</p>
<p><strong>Degré de maîtrise.</strong> Le degré de maîtrise dépend du nombre de points investis dans une compétence. Beaucoup de compétences peuvent être utilisées sans qu''on y ait investi le moindre point ; on parle alors de test inné de compétence.</p>
<p><strong>Modificateur de caractéristique.</strong> Les tests de compétence utilisent le modificateur de la caractéristique associée à cette compétence. Cette information est donnée dans la description de chaque compétence.</p>
<p><strong>Modificateurs divers.</strong> Les modificateurs divers comprennent, entre autres, les bonus raciaux, le malus d''armure aux tests et les bonus accordés par les dons.</p>
<p>Un point de compétence correspond à une augmentation du degré de maîtrise de 1 pour une compétence de classe et de 1/2 pour une compétence hors classe. La liste des compétences associées à chaque classe se trouve dans leur description. Les compétences qui n''apparaissent pas sur cette liste sont « hors classe ». Une augmentation du degré de maîtrise de 1/2 n''améliore pas le test de compétence, mais deux demis donnent un nouveau point de degré de maîtrise. Veillez bien à dépenser la totalité de vos points de compétence ; il est impossible d''en garder pour plus tard.</p>
<p>Le degré de maîtrise maximal que votre personnage ne peut pas dépasser est égal à son niveau global + 3 pour les compétences de classe, et la moitié - sans arrondir - de ce total pour les autres.</p>
<p>Si une compétence est une compétence de classe pour au moins une des classes du personnage, alors son degré de maîtrise maximal est égal à son niveau global + 3.</p>',
        10, @ddver, @res, NULL, 1, @now, @now);
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_competences, 'regle', 'Utilisation des compétences', 'utilisation-des-competences',
'<p>Chaque utilisation de compétence est évaluée grâce à un jet de dé. Plus le résultat du test de compétence est élevé, plus l''issue est favorable au personnage. Il est nécessaire d''atteindre un résultat donné, variant en fonction des conditions (soit un DD, soit le test opposé d''un adversaire), pour que la compétence soit utilisée avec brio. Plus la tâche est difficile, plus le chiffre à obtenir est élevé.</p>
<p>Le résultat du test peut être modifié par certaines conditions. Si le personnage est au calme, loin de toute source de déconcentration, il peut faire attention et éviter ainsi les erreurs du débutant. De même, s''il a du temps, il peut réessayer encore et encore jusqu''à ce qu''il réussisse du mieux possible. Enfin, l''aide de ses compagnons lui permettra parfois d''accomplir des prouesses qu''il n''aurait pu réaliser seul.</p>
<h3>Le test de compétence</h3>
<p>Le test de compétence prend en compte la formation du personnage (le degré de maîtrise), mais aussi son talent inné (le modificateur de caractéristique) et le hasard (le jet de dé). Il peut également intégrer des facteurs tels que la facilité de certaines races à accomplir certaines tâches (bonus racial), la difficulté supplémentaire due au port d''une armure (malus d''armure aux tests) ou les dons que possède le personnage et d''autres facteurs encore. Pour effectuer un test de compétence, jetez 1d20 et ajoutez le modificateur de compétence du personnage. Ce modificateur comprend son degré de maîtrise, son modificateur de caractéristique et tout autre modificateur pouvant s''appliquer à la compétence concernée (bonus racial, malus d''armure aux tests, etc.). Plus le total est élevé, plus l''issue est favorable. Contrairement aux jets d''attaque et de sauvegarde, un 20 naturel au dé ne constitue pas un succès automatique, pas plus qu''un 1 naturel n''est un échec automatiquement.</p>
<h3>Degré de difficulté</h3>
<p>Certains tests de compétence s''effectuent en fonction d''un degré de difficulté, ou DD. Le DD est une valeur déterminée en accord avec les règles des compétences représentant la difficulté de la tâche que le personnage s''est fixée.</p>
<p>[[tab:exemples-de-degres-de-difficulte]]</p>
<h3>Test opposé</h3>
<p>La réussite ou l''échec d''un test opposé est déterminé en comparant le résultat du test du personnage au résultat du test de son adversaire. Le vainqueur est celui des deux qui obtient le résultat le plus élevé, l''autre est le perdant. En cas d''égalité de résultat, la victoire revient à celui des deux dont le modificateur de compétence est le plus élevé. Si les modificateurs sont identiques, il faut relancer les dés tant qu''il y a égalité.</p>
<p>[[tab:exemples-de-tests-opposes]]</p>',
        20, @ddver, @res, NULL, 1, @now, @now);
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_competences, 'regle', 'Nouvelles tentatives et test inné', 'nouvelles-tentatives-et-test-inne',
'<h3>Nouvelles tentatives</h3>
<p>En règle générale, en cas d''échec, rien n''empêche d''utiliser encore et encore une compétence. Mais, pour certaines compétences, l''échec s''accompagne parfois de conséquences fâcheuses. Un petit nombre d''entre elles sont ainsi totalement inutiles une fois que l''on a raté sa première tentative. Pour la plupart des compétences, il est inutile de réussir plusieurs tests ; le premier succès suffit.</p>
<h3>Test inné de compétence</h3>
<p>En règle générale, on peut effectuer un test de compétence même quand on essaye d''utiliser une compétence pour laquelle on n''a pas reçu la moindre formation. Dans ce cas, le résultat du test ne bénéficie pas du degré de maîtrise, mais les autres modificateurs éventuels (racial, de caractéristique, etc.) sont toujours pris en compte. Nombre de compétences ne peuvent être utilisées que par les individus ayant reçu la formation adéquate.</p>',
        30, @ddver, @res, NULL, 1, @now, @now);
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_competences, 'regle', 'Conditions favorables ou défavorables', 'conditions-favorables-ou-defavorables',
'<p>Certaines conditions facilitent ou gênent l''utilisation d''une compétence, ce qui se traduit par un bonus ou un malus associé au test de compétence (ou éventuellement par une modification du DD de ce dernier).</p>
<p>On peut modifier le test de compétence de quatre façons :</p>
<ul>
<li>En accordant un bonus de circonstances de +2 pour représenter des conditions améliorant les chances de réussite, comme par exemple le fait de posséder l''outil idéal pour accomplir la tâche choisie, d''être aidé par un compagnon (voir <em>Combiner ses compétences</em>) ou de détenir des informations particulièrement complètes sur le sujet.</li>
<li>En imposant un malus de circonstances de –2 reflétant des difficultés exceptionnelles, comme le fait de devoir utiliser un outil inadéquat ou de disposer de renseignements erronés.</li>
<li>En réduisant le DD de 2 points pour simuler les conditions qui rendent la tâche plus facile, comme le fait d''avoir un public déjà acquis à sa cause ou de réaliser un travail qui n''a pas besoin d''être parfait.</li>
<li>En augmentant le DD de 2 points dans le cas où la tâche est plus complexe qu''à l''habitude, comme le fait de se retrouver face à un public hostile ou de devoir fournir un travail impeccable.</li>
</ul>
<p>Les conditions qui affectent la manière dont le personnage utilise sa compétence se retrouvent au niveau du modificateur, contrairement à celles qui modifient le résultat que le personnage doit obtenir, et qui, elles, influent sur le DD. Certes, un bonus au test de compétence entraîne le même résultat qu''une diminution égale du DD, mais tous deux représentent des cas de figure différents, et il arrive que cette distinction soit importante.</p>',
        40, @ddver, @res, NULL, 1, @now, @now);
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_competences, 'regle', 'Temps d''utilisation des compétences', 'temps-d-utilisation-des-competences',
'<p>Certaines compétences s''utilisent rapidement, tandis que d''autres exigent plusieurs rounds, voire encore plus. La plupart prennent une action simple, une action de mouvement ou une action complexe. Les différents types d''actions indiquent le temps qu''elles prennent dans un round de combat (6 secondes) et le déplacement qu''elles autorisent (voir <em>Les actions au combat</em>). Certains tests de compétence s''effectuent instantanément et sont considérés comme une simple réaction ; ils ne comptent pas comme des actions à part entière. D''autres représentent une partie du déplacement du personnage (c''est par exemple le cas de Saut). La description de chaque compétence indique le temps nécessaire pour y faire appel.</p>',
        50, @ddver, @res, NULL, 1, @now, @now);
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_competences, 'regle', 'Test sans jet de dé', 'test-sans-jet-de-de',
'<p>Un test de compétence représente la tentative faite pour atteindre un but, le plus souvent dans des conditions de tension ou de déconcentration importantes. Mais il arrive que le personnage puisse faire disparaître le facteur aléatoire, pour peu qu''il dispose de suffisamment de temps et de calme.</p>
<p><strong>Faire 10.</strong> Lorsqu''un aventurier n''est ni menacé ni distrait, il peut choisir de « faire 10 ». Dans ce cas, pas besoin de jeter le d20 ; on considère que le résultat est automatiquement égal à 10, ce qui revient à un succès automatique pour les tâches aisées. Il est impossible de « faire 10 » quand on est déconcentré ou menacé (par exemple, lors d''un combat). Dans la plupart des cas, faire 10 est une façon de jouer la sécurité. Le joueur sait (ou estime) qu''un résultat moyen permettra de réussir, mais a peur des conséquences d''un résultat trop bas et il préfère donc se rabattre sur la moyenne en faisant 10. Cette option est particulièrement utile lorsqu''un résultat élevé n''apporte aucun avantage particulier (comme pour escalader une corde à nœuds ou pour effectuer des soins à long terme).</p>
<p><strong>Faire 20.</strong> Si le personnage a suffisamment de temps devant lui (le plus souvent, 2 minutes pour toute compétence s''utilisant généralement en 1 round, une action complexe ou une action simple), s''il n''est ni menacé ni distrait et si la compétence qu''il désire utiliser n''implique aucune conséquence néfaste en cas d''échec, il peut choisir de « faire 20 ». Autrement dit, à force de réessayer, il va finir par obtenir un 20 sur le dé. Au lieu de lancer le dé, calculez le résultat de l''action comme si le jet de dé avait donné 20. Faire 20 signifie que le personnage réessaye jusqu''à réussir du mieux possible, mais cela implique beaucoup d''échecs entre-temps. Cette possibilité prend en moyenne vingt fois plus de temps qu''un test de compétence normal. Puisque faire 20 suppose que le personnage va rater de nombreuses fois avant de réussir, son utilisation avec une compétence présentant une conséquence néfaste en cas d''échec (comme un test de Désamorçage/sabotage effectué pour désamorcer un piège) déclencherait systématiquement ces conséquences avant qu''il ait une chance de réussir (dans ce cas, cela déclencherait le piège). Les compétences avec lesquelles on utilise régulièrement « faire 20 » sont Crochetage, Évasion et Fouille.</p>
<p><strong>Test de caractéristique et test de niveau de lanceur de sorts.</strong> Les règles permettant de faire 10 et de faire 20 s''appliquent aux tests de caractéristique. Par contre, aucune des deux règles ne s''applique aux tests de niveau de lanceur de sorts (auxquels on a recours, par exemple, pour lancer <em>dissipation de la magie</em>).</p>',
        60, @ddver, @res, NULL, 1, @now, @now);
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_competences, 'regle', 'Combiner ses compétences', 'combiner-ses-competences',
'<p>Plusieurs personnages peuvent combiner leurs efforts lorsqu''ils utilisent la même compétence en même temps.</p>
<h3>Actions individuelles simultanées</h3>
<p>Il arrive souvent que plusieurs aventuriers essayent d''accomplir la même action de manière indépendante, auquel cas le succès ou l''échec de chacun n''influe pas sur la tentative des autres.</p>
<h3>Aider quelqu''un</h3>
<p>Un personnage peut aider l''un de ses compagnons dans sa tâche en effectuant le même genre de test de compétence pour combiner leurs efforts. Si le résultat du test est de 10 ou plus, l''aide apportée se traduit par un bonus de +2 sur le test du compagnon, ce qui correspond à une condition favorable. (Il est impossible de faire 10 sur un test destiné à aider quelqu''un.) Il arrive souvent que l''aide des autres ne soit d''aucun secours ou que le nombre de personnes pouvant coopérer pour accomplir une action donnée soit limité.</p>
<p>Dans les cas où il faut remplir des conditions supplémentaires pour réaliser une action particulière, on ne peut aider quelqu''un que si on remplit soi-même ces conditions.</p>',
        70, @ddver, @res, NULL, 1, @now, @now);
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_competences, 'regle', 'La synergie', 'la-synergie',
'<p>Il arrive parfois que le fait de maîtriser deux compétences proches (comme Acrobaties et Saut) aide à accomplir des tâches en rapport avec chacune d''elles. En règle générale, le fait d''avoir atteint un degré de maîtrise de 5 dans une compétence confère un bonus de +2 aux tests de compétences liées (voir la description de chaque compétence). Dans certains cas, ce bonus ne s''applique pas systématiquement, mais seulement pour quelques tâches. Dans d''autres cas, la synergie ne s''applique pas à un test de compétence, mais à un autre type de test, comme ceux liés à une aptitude de classe.</p>',
        80, @ddver, @res, NULL, 1, @now, @now);
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_competences, 'regle', 'Tests de caractéristique', 'tests-de-caracteristique',
'<p>Il arrive qu''un personnage tente d''accomplir une action ne correspondant à aucune compétence. On a alors recours à un test de caractéristique, simulé par 1d20 + modificateur de la caractéristique appropriée (cela revient en quelque sorte à jouer un test inné de compétence).</p>
<p>Parfois, le résultat d''une action repose uniquement sur l''une des caractéristiques du personnage, sans que le hasard intervienne. De même que deux individus ne vont pas effectuer de test de taille pour savoir qui est le plus grand, ils ne jouent pas de test de Force pour savoir qui est le plus musclé.</p>',
        90, @ddver, @res, NULL, 1, @now, @now);
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_competences, 'regle', 'Description des compétences', 'description-des-competences',
'<p>Le compendium décrit les compétences en expliquant à quoi elles servent et en précisant les modificateurs qui s''appliquent en temps normal. Il est parfois possible de les utiliser dans des buts autres que ceux indiqués dans la description.</p>
<p>Voici comment se présentent les descriptions.</p>
<h3>Nom de la compétence</h3>
<p>L''en-tête comprend les informations suivantes :</p>
<p><strong>Caractéristique associée.</strong> La caractéristique qui s''applique au test de compétence, sous forme abrégée. <em>Exception</em> : Langue s''accompagne de la mention « Aucune », car l''utilisation de cette compétence ne nécessite aucun jet de dé.</p>
<p><strong>Formation nécessaire.</strong> Si cette entrée est incluse dans l''en-tête, seuls les personnages ayant un degré de maîtrise de 1 ou plus peuvent utiliser la compétence (les autres n''ont pas reçu la formation nécessaire). Dans le cas où rien n''est mentionné, la compétence peut être utilisée de manière innée (avec un degré de maîtrise de 0). Si des particularités s''appliquent à la formation reçue par le personnage, elles sont présentées en fin de description, dans le paragraphe « Test inné » (voir ci-dessous).</p>
<p><strong>Malus d''armure aux tests.</strong> Si cette entrée est présente dans l''en-tête, le malus d''armure aux tests s''applique sur tous les tests de cette compétence (à condition de porter une armure, bien sûr). Si cette entrée est absente, le malus d''armure aux tests ne s''applique pas.</p>
<p>L''en-tête est suivi d''une description sommaire de la compétence, puis viennent les informations suivantes :</p>
<p><strong>Test de compétence.</strong> Ce qu''un test réussi permet de réaliser et les DD habituels pour les tâches associées.</p>
<p><strong>Action.</strong> Le type d''action ou le temps nécessaire à l''utilisation de la compétence.</p>
<p><strong>Nouvelles tentatives.</strong> Les éventuelles conditions s''appliquant aux nouvelles tentatives faites pour réessayer d''utiliser la compétence. Si une compétence ne permet pas de tenter la même tâche plus d''une fois ou si l''échec a des conséquences néfastes inhérentes (comme pour la compétence Escalade), il est impossible de faire 20. Si ce paragraphe n''est pas présent, on peut réessayer autant de fois que souhaité sans autre risque spécifique, autre que celui de perdre du temps.</p>
<p><strong>Spécial.</strong> D''autres informations s''appliquant à la compétence, comme les résultats spéciaux qu''on peut obtenir ou les avantages que certains personnages reçoivent en fonction de leur race, leur classe ou leurs dons.</p>
<p><strong>Synergie.</strong> Certaines compétences fonctionnent particulièrement bien ensemble. Cette section, lorsqu''elle est présente, indique les bonus dont peut bénéficier cette compétence par synergie et ceux qu''elle offre lorsqu''on la maîtrise.</p>
<p><strong>Restrictions.</strong> L''usage complet de quelques compétences est réservé aux personnages de certaines classes ou aux personnages qui possèdent un don particulier. Ce paragraphe indique si une restriction de ce type existe pour la compétence.</p>
<p><strong>Test inné.</strong> Ce paragraphe indique les possibilités d''un personnage utilisant la compétence de façon innée (parce qu''il possède un degré de maîtrise de 0). Si cette section est absente, la compétence est utilisable normalement (pour les compétences permettant les tests innés) ou totalement inaccessible (pour les compétences dont l''en-tête indique « formation »).</p>',
        100, @ddver, @res, NULL, 1, @now, @now);

-- Tableaux
INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note,
                         tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible,
                         tab_date_creation, tab_date_modif)
VALUES
('exemples-de-degres-de-difficulte', 'Exemples de degrés de difficulté',
'! Difficulté (DD) | Exemple (compétence utilisée)
Très facile (0) | Remarquer un grand objet posé en évidence (Détection)
Facile (5) | Escalader une corde à nœuds (Escalade)
Moyenne (10) | Entendre l''approche d''un garde (Perception auditive)
Délicat (15) | Saboter une roue de chariot pour qu''elle tombe en route (Désamorçage/sabotage)
Difficile (20) | Nager en pleine tempête (Natation)
Formidable (25) | Ouvrir une serrure de qualité moyenne (Crochetage)
Héroïque (30) | Sauter par-dessus une faille de 9 mètres de large (Saut)
Presque impossible (40) | Suivre la piste d''un groupe d''orques sur un terrain dur et après 24 heures de pluie (Survie)',
'll', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('exemples-de-tests-opposes', 'Exemples de tests opposés',
'! Tâche | Compétence (caractéristique) | Compétence opposée (caractéristique)
Rouler quelqu''un | Bluff (Cha) | Psychologie (Sag)
Tracer une fausse carte | Contrefaçon (Int) | Contrefaçon (Int)
Se faire passer pour quelqu''un d''autre | Déguisement (Cha) | Détection (Sag)
Arriver furtivement dans le dos de quelqu''un | Déplacement silencieux (Dex) | Perception auditive (Sag)
Ne pas se faire remarquer | Discrétion (Dex) | Détection (Sag)
Faire hésiter une brute | Intimidation (Cha) | Spécial (1)
Ligoter un prisonnier | Maîtrise des cordes (Dex) | Évasion (Dex)
Dérober une bourse | Escamotage (Dex) | Détection (Sag)
> (1) Un test d''Intimidation est opposé par un test de niveau de la cible plutôt que par un test de compétence. Voir la description de la compétence Intimidation pour plus de détails.',
'lll', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now);

-- Glossaire
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES
(@glo, 'glossaire', 'Compétence de classe', 'competence-de-classe', '<p>Compétence figurant sur la liste d''une des classes du personnage : chaque point de compétence y vaut un degré de maîtrise, jusqu''à niveau global + 3. Voir <em>Points de compétence et degrés de maîtrise</em>.</p>', 640, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Compétence hors classe', 'competence-hors-classe', '<p>Compétence absente de la liste de classe du personnage : un point de compétence n''y vaut qu''un demi-degré de maîtrise, avec pour maximum la moitié de celui d''une compétence de classe (sans arrondir). Voir <em>Points de compétence et degrés de maîtrise</em>.</p>', 650, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Degré de difficulté (DD)', 'degre-de-difficulte-dd', '<p>Valeur qu''un test de compétence doit égaler ou dépasser pour réussir une tâche : de 0 (très facile) à 40 (presque impossible). Voir <em>Utilisation des compétences</em>.</p>', 660, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Degré de maîtrise', 'degre-de-maitrise', '<p>Formation du personnage dans une compétence, mesurée en degrés ; chaque degré donne +1 au test de compétence. Maximum : niveau global + 3 pour une compétence de classe. Voir <em>Points de compétence et degrés de maîtrise</em>.</p>', 670, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Faire 10', 'faire-10', '<p>Remplacer le jet de d20 d''un test par un résultat de 10, quand le personnage n''est ni menacé ni distrait. Impossible en combat. Voir <em>Test sans jet de dé</em>.</p>', 680, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Faire 20', 'faire-20', '<p>Remplacer le jet de d20 d''un test par un résultat de 20, au prix de vingt fois plus de temps (le plus souvent 2 minutes) ; impossible si l''échec a des conséquences néfastes. Voir <em>Test sans jet de dé</em>.</p>', 690, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Modificateur de compétence', 'modificateur-de-competence', '<p>Total ajouté au d20 d''un test de compétence : degré de maîtrise + modificateur de caractéristique + modificateurs divers (racial, malus d''armure aux tests, dons…). Voir <em>Points de compétence et degrés de maîtrise</em>.</p>', 700, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Synergie (compétences)', 'synergie-competences', '<p>Bonus de +2 aux tests d''une compétence liée quand le personnage a un degré de maîtrise de 5 dans une compétence proche (Acrobaties et Saut, par exemple). Voir <em>La synergie</em>.</p>', 710, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Test de caractéristique', 'test-de-caracteristique', '<p>1d20 + modificateur de la caractéristique appropriée, pour une action qui ne correspond à aucune compétence (l''équivalent d''un test inné de compétence). Voir <em>Tests de caractéristique</em>.</p>', 720, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Test inné de compétence', 'test-inne-de-competence', '<p>Test d''une compétence dans laquelle le personnage n''a aucun degré de maîtrise : seuls les autres modificateurs s''appliquent. Impossible pour une compétence à formation nécessaire. Voir <em>Nouvelles tentatives et test inné</em>.</p>', 730, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Test opposé', 'test-oppose', '<p>Test de compétence comparé à celui d''un adversaire plutôt qu''à un DD : le résultat le plus élevé l''emporte ; à égalité, le modificateur de compétence le plus élevé, puis on relance. Voir <em>Utilisation des compétences</em>.</p>', 740, @ddver, @res, NULL, 1, @now, @now);

COMMIT;
