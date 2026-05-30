-- import_regles_dd2024.sql
-- Met à jour reg_texte des chapitres Comment jouer (reg_id 1-10)
-- Source : SRD DD2024 5.2.1 CC-BY-4.0

SET @ddver = (SELECT var_id FROM dd_variables
             WHERE var_cat = 'RULESET' AND var_valeur = 'DD2024' LIMIT 1);

START TRANSACTION;

-- [1] comment-jouer
UPDATE dd_regles
SET    reg_texte = '<p>Ce chapitre présente les règles fondamentales de DD2024 : le rythme de jeu, les six caractéristiques, les tests de dés, la maîtrise, les actions, les interactions sociales, l''exploration et le combat.</p>',
       reg_date_modif = NOW()
WHERE  reg_slug = 'comment-jouer'
  AND  reg_ruleset_var_id = @ddver;

-- [2] rythme-de-jeu
UPDATE dd_regles
SET    reg_texte = '<ol>
  <li>Les trois piliers du jeu sont les suivants : interactions sociales, exploration et combat. Pour chacun de ces trois aspects, le jeu se déroule selon le modèle suivant :</li>
  <li>Le maître de jeu brosse le tableau. Le MJ décrit aux joueurs le lieu où se trouvent les aventuriers et ce qui les entoure (le nombre d''issues d''une salle, ce qui est posé sur une table, etc.).</li>
  <li>Les joueurs décrivent ce que font leurs personnages. Généralement, les personnages restent groupés lorsqu''ils explorent un donjon ou tout autre environnement. Parfois, ils se répartissent les tâches : un premier aventurier examine un coffre tandis qu''un deuxième inspecte un symbole mystérieux sur le mur et qu''un troisième monte la garde. Hors des situations de combat, le MJ veille à ce que chaque personnage ait l''occasion d''agir et il gère la résolution de leurs activités respectives. Au combat, les personnages jouent tour à tour.</li>
  <li>Le MJ relate le déroulement des tâches entreprises par les aventuriers. Certaines tâches se résolvent facilement. Quand un aventurier traverse une pièce pour ouvrir une porte, le MJ peut se contenter d''annoncer que la porte s''ouvre et ce qu''elle révèle. Mais cette porte peut être verrouillée ou le sol qui y mène peut cacher un piège (ou autre situation particulière compliquant la tâche). Dans un tel cas, le MJ peut demander au joueur de lancer un dé pour mieux déterminer ce qui se passe. Cette description entraîne souvent de nouvelles décisions, qui nous ramènent à l''étape 1. Ce modèle est valable pour chaque séance de jeu (chaque fois que vous vous réunissez pour jouer à D&amp;D), que les aventuriers conversent avec un aristocrate, explorent des ruines ou affrontent un dragon.</li>
</ol>

<p>Les exceptions s''imposent sur la règle générale Les règles générales régissent chaque aspect du jeu. Ainsi, les règles de combat vous indiquent que les attaques de corps à corps se basent sur la Force et les attaques à distance sur la Dextérité. Il s''agit d''une règle générale, qui s''applique par défaut tant que rien d''autre ne vient la contredire dans le jeu. Le jeu fait également intervenir des éléments (aptitudes de classe, dons, propriétés d''arme, sorts, objets magiques, aptitudes de monstre, etc.) qui viennent infirmer une règle générale. Lorsqu''une exception entre en conflit avec une règle générale, c''est l''exception qui l''emporte. Ainsi, quand une aptitude indique que vous pouvez effectuer une attaque de corps à corps en vous basant sur votre Charisme, c''est que vous en avez la possibilité, même si cette affirmation contredit la règle générale.</p>

<p>Dans certaines situations, notamment au combat, l''action est plus structurée et chacun joue tour à tour.</p>',
       reg_date_modif = NOW()
WHERE  reg_slug = 'rythme-de-jeu'
  AND  reg_ruleset_var_id = @ddver;

-- [3] les-six-caracteristiques
UPDATE dd_regles
SET    reg_texte = '<p>Toutes les créatures, personnages comme monstres, sont dotées de six caractéristiques représentant leurs attributs physiques et mentaux, comme indiqué sur la table Description des caractéristiques.</p>

<p class="table-titre"><strong>Description des caractéristiques</strong></p>

<table class="regles-table">
  <tr><th>Caractéristique</th><th>Valeur représentant…</th></tr>
  <tr><td>Force</td><td>La puissance physique</td></tr>
  <tr><td>Dextérité</td><td>L''agilité, les réflexes et l''équilibre</td></tr>
  <tr><td>Constitution</td><td>La santé et l''endurance</td></tr>
  <tr><td>Intelligence</td><td>Les capacités de raisonnement et la mémoire</td></tr>
  <tr><td>Sagesse</td><td>Le discernement et la fermeté mentale</td></tr>
  <tr><td>Charisme</td><td>La confiance en soi, l''aplomb et le charme naturel</td></tr>
</table>

<p class="table-titre"><strong>Valeurs de caractéristique</strong></p>

<table class="regles-table">
  <tr><th>Valeur</th><th>Signification</th></tr>
  <tr><td>1</td><td>Valeur minimale. Quand un effet réduit une valeur à 0, la description explique ce qui se passe.</td></tr>
  <tr><td>2–9</td><td>Capacités faibles.</td></tr>
  <tr><td>10–11</td><td>Moyenne humaine.</td></tr>
  <tr><td>12–19</td><td>Capacités remarquables.</td></tr>
  <tr><td>20</td><td>Valeur maximale pour un aventurier, sauf mention contraire.</td></tr>
  <tr><td>21–29</td><td>Capacités extraordinaires.</td></tr>
  <tr><td>30</td><td>Valeur théorique maximale.</td></tr>
</table>

<p>Chaque caractéristique est représentée par une valeur allant de 1 à 20 (ce maximum peut monter jusqu''à 30 dans le cas de certains monstres). Cette valeur est un ordre de grandeur relatif. La table Valeurs de caractéristique résume la signification de ces valeurs.</p>

<p>Il s''agit de la valeur minimale en conditions normales. Quand un effet réduit une valeur à 0, la description de l''effet explique ce qui se passe.</p>

<p>2–9 Capacités faibles.</p>

<p>10–11 Moyenne humaine.</p>

<p>12–19 Capacités remarquables.</p>

<p>Valeur maximale pour un aventurier, sauf mention contraire d''une aptitude.</p>

<p>21–29 Capacités extraordinaires.</p>

<p>Valeur théorique maximale.</p>

<p class="table-titre"><strong>Modificateurs de caractéristique</strong></p>

<table class="regles-table">
  <tr><th>Valeur</th><th>Modificateur</th><th>Valeur</th><th>Modificateur</th></tr>
  <tr><td>1</td><td>−5</td><td>16–17</td><td>+3</td></tr>
  <tr><td>2–3</td><td>−4</td><td>18–19</td><td>+4</td></tr>
  <tr><td>4–5</td><td>−3</td><td>20–21</td><td>+5</td></tr>
  <tr><td>6–7</td><td>−2</td><td>22–23</td><td>+6</td></tr>
  <tr><td>8–9</td><td>−1</td><td>24–25</td><td>+7</td></tr>
  <tr><td>10–11</td><td>+0</td><td>26–27</td><td>+8</td></tr>
  <tr><td>12–13</td><td>+1</td><td>28–29</td><td>+9</td></tr>
  <tr><td>14–15</td><td>+2</td><td>30</td><td>+10</td></tr>
</table>

<p>Chaque fois que vous divisez ou multipliez un nombre dans le jeu et que vous obtenez une fraction, arrondissez à l''entier inférieur même si cette fraction est d''un demi ou plus. Certaines règles constituent une exception en vous indiquant d''arrondir à l''entier supérieur.</p>

<p>un Test d20 associé à cette caractéristique (voir « Tests d20 »). Le modificateur d''une caractéristique dérive de sa valeur, comme le montre la table Modificateurs de caractéristique.</p>',
       reg_date_modif = NOW()
WHERE  reg_slug = 'les-six-caracteristiques'
  AND  reg_ruleset_var_id = @ddver;

-- [4] tests-d20
UPDATE dd_regles
SET    reg_texte = '<ol>
  <li>Quand le résultat d''une action est incertain, le jeu s''appuie sur le jet d''un d20 pour déterminer si la tâche est couronnée de succès ou si elle échoue. Ces jets appelés « Tests d20 » se présentent sous trois formes : tests de caractéristique, jets d''attaque et jets de sauvegarde. Ils passent par les étapes suivantes :</li>
  <li>Lancez 1d20. Plus le résultat est élevé, plus il est favorable. Si le jet s''effectue avec l''Avantage ou le Désavantage (voir plus loin dans « Comment jouer »), vous lancez deux d20, mais ne gardez qu''un résultat ; le plus élevé si vous avez l''Avantage, le plus faible si vous avez le Désavantage.</li>
  <li>Ajoutez les modificateurs. Ajoutez les modificateurs suivants au nombre obtenu sur le d20 :</li>
</ol>

<ol>
  <li>• Le modificateur de caractéristique concerné. « Comment jouer » et « Glossaire de règles » précisent quels modificateurs de caractéristique s''appliquent aux divers Tests d20. • Votre bonus de maîtrise si la situation le justifie. Chaque créature est dotée d''un bonus de maîtrise, nombre qu''elle ajoute à tout Test d20 faisant intervenir quelque chose, comme une compétence, dont elle a la maîtrise. Voir « Maîtrise », plus loin dans « Comment jouer ». • Appliquez les bonus et malus liés aux circonstances. Certaines aptitudes de classe, sorts ou autres éléments de jeu peuvent conférer un bonus ou imposer un malus au jet.</li>
  <li>Comparez le total au nombre cible. Si la somme du résultat du d20 et des modificateurs appliqués égale ou dépasse le nombre cible, le Test d20 est réussi. Dans le cas contraire, il est raté. Le maître de jeu fixe le nombre cible et annonce aux joueurs si leurs jets sont réussis ou non. Dans le cas des tests de caractéristique et des jets de sauvegarde, le nombre cible est appelé degré de difficulté (DD). Dans le cas des jets d''attaque, on parle pour le</li>
</ol>

<p>nombre cible de classe d''armure (CA), celle-ci apparaissant sur la fiche de personnage ou le profil de jeu (cf. « Glossaire de règles »).</p>

<h3>Tests de caractéristique</h3>

<p>Un test de caractéristique intervient quand une créature puise dans son talent ou sa formation pour surmonter une épreuve, comme forcer une porte bloquée, crocheter une serrure, divertir une foule ou décrypter un code. Le MJ et les règles font généralement appel à ces tests lorsque ce que tente une créature a une probabilité d''échouer et qu''il ne s''agit pas d''une attaque. Lorsque l''issue de la tâche est incertaine et intéressante sur le plan narratif, les dés la déterminent.</p>

<p><strong>Modificateur de caractéristique</strong></p>

<p>Un test de caractéristique tire son nom de la caractéristique à laquelle il est associé : un test de Force, un test d''Intelligence, etc. La caractéristique associée se décide selon la situation. La table « Tests de caractéristique typiques » fournit de tels exemples.</p>

<p><strong>Tests de caractéristique typiques</strong></p>

<p><strong>Caractéristique Effectuez un test pour…</strong></p>

<p><strong>Force</strong></p>

<p>Soulever, pousser, tirer ou briser quelque chose</p>

<p><strong>Dextérité</strong></p>

<p>Vous déplacer avec agilité, vivacité ou furtivité</p>

<p><strong>Constitution</strong></p>

<p>Repousser les limites ordinaires de votre organisme</p>

<p><strong>Intelligence</strong></p>

<p>Mettre votre raison ou votre mémoire à l''épreuve</p>

<p><strong>Sagesse</strong></p>

<p>Observer l''environnement ou les comportements</p>

<p><strong>Charisme</strong></p>

<p>Influencer, divertir ou tromper autrui</p>

<p class="table-titre"><strong>Bonus de maîtrise</strong></p>

<table class="regles-table">
  <tr><th>Niveau</th><th>Bonus de maîtrise</th></tr>
  <tr><td>1–4</td><td>+2</td></tr>
  <tr><td>5–8</td><td>+3</td></tr>
  <tr><td>9–12</td><td>+4</td></tr>
  <tr><td>13–16</td><td>+5</td></tr>
  <tr><td>17–20</td><td>+6</td></tr>
</table>

<p>Votre bonus de maîtrise s''ajoute à un test de caractéristique lorsque le MJ statue qu''une maîtrise de compétence ou d''outil s''y applique et que vous disposez de cette maîtrise. Ainsi, quand une règle indique un test de Force (Acrobaties ou Athlétisme), vous pouvez ajouter votre bonus de maîtrise au test si vous disposez de la maîtrise de la compétence Acrobaties ou Athlétisme. Pour plus de détails sur les maîtrises de compétence et d''outil, reportez-vous à « Maîtrise », voir plus loin dans « Comment jouer ».</p>

<p><strong>Degré de difficulté</strong></p>

<p>Le degré de difficulté d''un test de caractéristique représente la difficulté de la tâche. Plus une tâche est ardue, plus le DD est élevé. Les règles fournissent les DD de certains tests, mais c''est toujours le MJ qui tranche. La table « Degrés de difficulté courants » propose une estimation des DD de tests de caractéristique.</p>

<p class="table-titre"><strong>Degrés de difficulté courants</strong></p>

<table class="regles-table">
  <tr><th>La tâche est…</th><th>DD</th></tr>
  <tr><td>Très facile</td><td>5</td></tr>
  <tr><td>Facile</td><td>10</td></tr>
  <tr><td>Modérée</td><td>15</td></tr>
  <tr><td>Difficile</td><td>20</td></tr>
  <tr><td>Très difficile</td><td>25</td></tr>
  <tr><td>Presque impossible</td><td>30</td></tr>
</table>

<h3>Jets de sauvegarde</h3>

<p>Un jet de sauvegarde, souvent abrégé en JS, représente une tentative d''échapper ou de résister à un danger, tel qu''une déflagration, une bouffée de vapeurs toxiques ou un sort qui menace d''envahir votre esprit. On ne choisit généralement pas d''effectuer un JS ; vous devez vous y soumettre lorsque votre personnage ou un monstre (dans le cas du MJ) est en danger. Le résultat du jet de sauvegarde est détaillé par l''effet qui l''a provoqué. Si vous ne comptez pas résister à l''effet, vous pouvez rater volontairement votre JS sans lancer le dé.</p>

<p><strong>Modificateur de caractéristique</strong></p>

<p>Un jet de sauvegarde tire son nom de la caractéristique à laquelle il est associé : un JS Constitution, un JS Sagesse, etc. La caractéristique associée dépend du type d''effet auquel on tente de résister, comme le montre la table « Jets de sauvegarde typiques ».</p>

<p>Jets de sauvegarde typiques Caractéristique</p>

<p><strong>Effectuez un JS pour…</strong></p>

<p><strong>Force</strong></p>

<p><strong>Vous opposer à une force physique</strong></p>

<p><strong>Dextérité</strong></p>

<p><strong>Esquiver un danger physique</strong></p>

<p><strong>Constitution</strong></p>

<p><strong>Supporter un danger toxique</strong></p>

<p><strong>Intelligence</strong></p>

<p><strong>Percer une illusion</strong></p>

<p><strong>Sagesse</strong></p>

<p><strong>Résister à un assaut mental</strong></p>

<p><strong>Charisme</strong></p>

<p><strong>Affirmer votre identité</strong></p>

<p>Vous ajoutez votre bonus de maîtrise à un JS si vous disposez de la maîtrise de ce type de jet de sauvegarde. Voir « Maîtrise », plus loin dans « Comment jouer ».</p>

<p><strong>Degré de difficulté</strong></p>

<p>Le degré de difficulté d''un jet de sauvegarde est déterminé par l''effet qui le provoque ou par le MJ. Exemple : quand un sort vous impose un JS, le DD est fixé par la caractéristique d''incantation du lanceur et son bonus de maîtrise. Les aptitudes de monstre qui engendrent des JS en spécifient le DD.</p>

<h3>Jets d''attaque</h3>

<p>Un jet d''attaque permet de déterminer si une attaque touche sa cible. Le jet d''attaque touche si son résultat est supérieur ou égal à la classe d''armure de la cible. Les jets d''attaque interviennent généralement lors d''affrontements, selon les règles de la section « Combat », plus loin dans « Comment jouer », mais le MJ peut également y faire appel en d''autres circonstances, comme lors d''un concours de tir à l''arc.</p>

<p><strong>Modificateur de caractéristique</strong></p>

<p>La table « Caractéristiques de jet d''attaque » indique quel modificateur de caractéristique s''applique selon le type de jet d''attaque.</p>

<p class="table-titre"><strong>Caractéristiques de jet d''attaque</strong></p>

<table class="regles-table">
  <tr><th>Caractéristique</th><th>Type d''attaque</th></tr>
  <tr><td>Force</td><td>Attaque de corps à corps avec une arme ou attaque à mains nues</td></tr>
  <tr><td>Dextérité</td><td>Attaque à distance avec une arme</td></tr>
  <tr><td>Variable</td><td>Attaque de sort (caractéristique définie par l''aptitude Sorts)</td></tr>
</table>

<p>Certaines aptitudes vous permettent de recourir à d''autres modificateurs de caractéristique que ceux indiqués. Ainsi, la propriété Finesse (cf. « Équipement ») permet de choisir entre Force et Dextérité lorsqu''on utilise une arme qui est dotée de cette propriété.</p>

<p>Vous ajoutez votre bonus de maîtrise au jet d''attaque lorsque vous attaquez avec une arme dont vous avez la maîtrise, ainsi que lorsque vous attaquez avec un sort. Pour plus de détails sur les maîtrises d''arme, reportez-vous à « Maîtrise », plus loin dans « Comment jouer ».</p>

<p><strong>Classe d''armure</strong></p>

<p>La classe d''armure (ou CA) d''une créature représente sa capacité à éviter les blessures au combat. La CA d''un personnage se détermine à sa création (cf. « Création de personnage »), tandis que celle d''un monstre apparaît dans son profil de jeu. Calcul de la CA. Toutes les créatures débutent avec le même calcul pour la CA de base :</p>

<p>CA de base = 10 + modificateur de Dextérité de la créature La CA d''une créature peut ensuite être modifiée par l''armure, des objets magiques, des sorts et autres éléments. Une seule CA de base. Certains sorts et aptitudes de classe fournissent aux personnages une autre méthode de calcul pour la CA. Un personnage doté de plusieurs aptitudes qui lui offrent diverses méthodes de calcul de la CA doit en choisir une ; une même créature ne peut pas être affectée par plus d''une méthode de calcul.</p>

<p><strong>Résultat de 20 ou 1 sur le dé</strong></p>

<p>Si vous obtenez un 20 sur le d20 (on dit aussi « 20 naturel ») d''un jet d''attaque, l''attaque touche quels que soient les modificateurs engagés et la CA</p>

<h3>Inspiration héroïque</h3>

<p>Il arrive que le MJ ou une règle vous octroie l''Inspiration héroïque. Si vous disposez de l''Inspiration héroïque, vous pouvez la dépenser pour rejouer aussitôt tout dé que vous venez de lancer, à condition de conserver ce nouveau jet. Une seule à la fois. Vous ne pouvez en aucun cas disposer de plus d''une Inspiration héroïque à la fois. Si, pour une raison quelconque, vous recevez l''Inspiration héroïque alors que vous en disposez déjà, vous pouvez la confier à un personnage-joueur de votre groupe qui n''en est pas pourvu. Recevoir l''Inspiration héroïque. Votre MJ peut vous octroyer l''Inspiration héroïque pour diverses raisons. En général, il l''accorde lorsque vous accomplissez un geste héroïque, incarnez remarquablement votre personnage ou que votre prestation s''avère particulièrement divertissante. C''est une sorte de récompense pour celles et ceux qui contribuent activement au plaisir de jeu de toute la table. D''autres règles permettent à votre aventurier d''acquérir l''Inspiration héroïque, indépendamment de la décision du MJ. Les personnages humains commencent ainsi chaque journée avec l''Inspiration héroïque.</p>

<p>de la cible. C''est ce que l''on appelle un Coup critique (cf. « Combat », plus loin dans « Comment jouer »). Si vous obtenez un 1 sur le d20 (on dit aussi « 1 naturel ») d''un jet d''attaque, l''attaque rate, quels que soient les modificateurs engagés et la CA de la cible.</p>

<h3>Avantage et Désavantage</h3>

<p>Il arrive qu''un Test d20 soit modifié par l''Avantage ou le Désavantage. L''Avantage reflète des circonstances favorables autour d''un jet de d20, tandis que le Désavantage représente des conditions défavorables. C''est généralement par l''intermédiaire d''aptitudes ou d''actions spéciales que l''on reçoit l''Avantage ou le Désavantage. Le MJ peut aussi statuer que les circonstances octroient l''Avantage ou imposent le Désavantage.</p>

<p><strong>Lancez deux d20</strong></p>

<p>Lorsque vous effectuez un jet avec l''Avantage ou le Désavantage, vous lancez un second d20 avec le premier. Vous ne retenez que le plus élevé des deux dés si vous avez l''Avantage, que le plus faible si vous avez le Désavantage. Si vous avez le Désavantage et obtenez par exemple 18 et 3 sur les dés, vous gardez le 3. Si vous avez au contraire l''Avantage, c''est le 18 que vous retenez avec ces mêmes jets.</p>

<p><strong>Non cumulables</strong></p>

<p>Quand plusieurs circonstances s''appliquent à un jet de dés et que chacune octroie l''Avantage, vous ne lancez pas plus de deux d20. De même, quand plusieurs circonstances imposent le Désavantage, vous ne lancez que deux d20.</p>

<p>Si les circonstances vous octroient l''Avantage tout en vous imposant le Désavantage, le jet n''a en définitive ni l''un ni l''autre, et vous lancez donc un seul d20. Cela reste vrai même si plusieurs conditions vous imposent le Désavantage et qu''une seule vous octroie l''Avantage, ou inversement. Dans une telle situation, vous ne recevez ni Avantage ni Désavantage.</p>

<p><strong>Cas des jets qu''on rejoue</strong></p>

<p>Lorsque vous avez l''Avantage ou le Désavantage et qu''un élément du jeu vous permet de relancer le d20 ou de le remplacer, vous ne pouvez relancer ou remplacer qu''un seul dé. Vous choisissez lequel. Exemple : si vous avez l''Inspiration héroïque (cf. encadré ci-après) et obtenez 3 et 18 sur les d20 d''un test de caractéristique effectué avec Avantage ou Désavantage, vous pouvez dépenser votre Inspiration héroïque pour relancer l''un de ces dés, mais pas les deux.</p>',
       reg_date_modif = NOW()
WHERE  reg_slug = 'tests-d20'
  AND  reg_ruleset_var_id = @ddver;

-- [5] maitrise
UPDATE dd_regles
SET    reg_texte = '<p>Les personnages et monstres se distinguent dans divers domaines. Certains excellent avec de nombreuses armes, d''autres ne savent en manier que quelques-unes. Certains brillent pour cerner les motivations d''autrui, d''autres pour percer les mystères du multivers. Toutes les créatures sont dotées d''un bonus de maîtrise, qui reflète l''impact de l''apprentissage sur leurs capacités. Le bonus de maîtrise d''un personnage augmente au gré de son acquisition de niveaux (cf. « Création de personnage »). Le bonus de maîtrise d''un monstre découle de son facteur de puissance (cf. « Glossaire de règles »). La table « Bonus de maîtrise » montre comment se détermine ce bonus. Ce bonus s''applique à un Test d20 lorsque la créature est dotée de la maîtrise d''une compétence, d''un jet de sauvegarde ou d''un objet dont elle se sert pour le Test d20. Le bonus est également employé pour les attaques de sort et pour le calcul du DD de sauvegarde des sorts.</p>

<p class="table-titre"><strong>Bonus de maîtrise</strong></p>

<table class="regles-table">
  <tr><th>Niveau</th><th>Bonus de maîtrise</th></tr>
  <tr><td>1–4</td><td>+2</td></tr>
  <tr><td>5–8</td><td>+3</td></tr>
  <tr><td>9–12</td><td>+4</td></tr>
  <tr><td>13–16</td><td>+5</td></tr>
  <tr><td>17–20</td><td>+6</td></tr>
</table>

<p>Le bonus ne se cumule pas Votre bonus de maîtrise ne peut pas s''ajouter plus d''une fois à un jet de dé ou à un nombre. Ainsi, quand une règle vous permet d''effectuer un test de Charisme (Persuasion ou Tromperie), vous ajoutez votre bonus de maîtrise si vous maîtrisez l''une de ces compétences, mais ne l''appliquez pas deux fois si vous maîtrisez les deux compétences.</p>

<p class="table-titre"><strong>Compétences</strong></p>

<table class="regles-table">
  <tr><th>Compétence</th><th>Caractéristique</th><th>Exemples d''application</th></tr>
  <tr><td>Acrobaties</td><td>Dextérité</td><td>Rester debout lorsque l''équilibre est précaire ou accomplir un exercice acrobatique.</td></tr>
  <tr><td>Arcanes</td><td>Intelligence</td><td>Se souvenir de détails sur les sorts, les objets magiques ou les plans d''existence.</td></tr>
  <tr><td>Athlétisme</td><td>Force</td><td>Sauter plus loin que la normale, nager dans des flots violents ou briser quelque chose.</td></tr>
  <tr><td>Discrétion</td><td>Dextérité</td><td>Se déplacer sans faire de bruit et se cacher.</td></tr>
  <tr><td>Dressage</td><td>Sagesse</td><td>Apaiser ou dresser un animal.</td></tr>
  <tr><td>Histoire</td><td>Intelligence</td><td>Se souvenir d''événements historiques, peuples, nations et cultures.</td></tr>
  <tr><td>Intuition</td><td>Sagesse</td><td>Reconnaître l''humeur et les intentions des gens.</td></tr>
  <tr><td>Médecine</td><td>Sagesse</td><td>Diagnostiquer une maladie ou déterminer les causes de morts récentes.</td></tr>
  <tr><td>Nature</td><td>Intelligence</td><td>Connaître les terrains, plantes, animaux et phénomènes naturels.</td></tr>
  <tr><td>Perception</td><td>Sagesse</td><td>Détecter par les sens ce qui peut échapper à d''autres.</td></tr>
  <tr><td>Persuasion</td><td>Charisme</td><td>Convaincre quelqu''un avec de bonnes manières ou changer son humeur.</td></tr>
  <tr><td>Religion</td><td>Intelligence</td><td>Connaître les dieux, rituels et symboles sacrés.</td></tr>
  <tr><td>Représentation</td><td>Charisme</td><td>Charmer ou divertir un public par la danse, la musique, le théâtre.</td></tr>
  <tr><td>Supercherie</td><td>Charisme</td><td>Mentir ou manipuler quelqu''un.</td></tr>
  <tr><td>Survie</td><td>Sagesse</td><td>Remonter une piste, trouver de la nourriture, s''orienter et éviter les dangers sauvages.</td></tr>
</table>

<p>Il peut en revanche arriver que le bonus de maîtrise soit multiplié ou divisé (doublé ou réduit de moitié, par exemple) avant son application. Ainsi l''aptitude Expertise (cf. « Glossaire de règles ») double-t-elle le bonus de maîtrise pour certains tests de caractéristique. Chaque fois que le bonus est employé, on ne peut le multiplier ou le diviser qu''une seule fois.</p>

<p><strong>Maîtrises de compétence</strong></p>

<p>La plupart des tests de caractéristique font intervenir une compétence, associée à un ensemble de choses que les créatures peuvent tenter par un tel test. Les descriptions des actions que vous entreprenez (cf. « Actions », plus loin dans « Comment jouer ») spécifient la compétence appliquée si cette action est assortie d''un test de caractéristique, et bien d''autres règles indiquent si une compétence est en jeu. C''est toujours le MJ qui tranche pour savoir si une compétence s''applique à une situation donnée. Si une créature maîtrise une compétence, elle applique son bonus de maîtrise aux tests de caractéristique qui font intervenir cette compétence. Sans cette maîtrise, la créature peut effectuer des tests de caractéristique associés à la compétence, mais elle n''applique pas son bonus de maîtrise. Exemple : si un personnage tente de gravir une falaise, le MJ peut lui demander un test de Force (Athlétisme). Si l''aventurier a la maîtrise d''Athlétisme, il applique son bonus de maîtrise au test de Force. S''il n''en est pas doté, il effectue son test sans ajouter son bonus de maîtrise.</p>

<p><strong>Liste des compétences</strong></p>

<p>Les compétences figurent sur la table « Compétences », qui fournit pour chacune des exemples d''utilisation ainsi que le test de caractéristique le plus souvent associé.</p>

<p><strong>Détermination de la compétence</strong></p>

<p>Les maîtrises de compétence de départ d''un personnage sont déterminées à sa création, et les maîtrises de compétence des monstres apparaissent dans leur profil.</p>

<p><strong>Maîtrise des jets de sauvegarde</strong></p>

<p>La maîtrise d''un jet de sauvegarde permet au personnage d''ajouter son bonus de maîtrise aux JS correspondants. Si vous avez par exemple la maîtrise des jets de sauvegarde de Sagesse, vous pouvez appliquer votre bonus de maîtrise aux JS Sagesse. Certains monstres disposent également de maîtrises de jet de sauvegarde, comme l''indique leur profil. Chaque classe dispose de la maîtrise d''au moins deux jets de sauvegarde, pour illustrer comment la classe forme à se soustraire ou à résister à certaines menaces. Ainsi, les Magiciens maîtrisent les JS Intelligence et Sagesse ; ils ont appris à résister aux attaques mentales.</p>

<h3>Maîtrises d''équipement</h3>

<p>Un personnage acquiert la maîtrise de divers outils et armes, par le biais de sa classe et de son historique. On compte deux catégories de maîtrises d''équipement :</p>

<p>Armes. N''importe qui peut tenir une arme, mais la maîtrise vous rend plus efficace dans son maniement. Si vous avez la maîtrise d''une arme, vous ajoutez votre bonus de maîtrise aux jets d''attaque correspondants. Outils. Si vous avez la maîtrise d''un outil, vous pouvez ajouter votre bonus de maîtrise aux tests de caractéristique correspondants. Si vous avez la maîtrise de la compétence également associée à ce test, vous avez aussi l''Avantage au test. Ainsi, vous pouvez conjointement tirer profit d''une maîtrise de compétence et d''une maîtrise d''outil à un même test de caractéristique.</p>',
       reg_date_modif = NOW()
WHERE  reg_slug = 'maitrise'
  AND  reg_ruleset_var_id = @ddver;

-- [6] actions
UPDATE dd_regles
SET    reg_texte = '<p>Lorsque votre activité ne se limite pas à un déplacement ou une simple communication, vous entreprenez généralement une action. La table « Actions » dresse la liste des actions principales du jeu, mieux détaillées dans « Glossaire de règles ».</p>

<p class="table-titre"><strong>Actions disponibles</strong></p>

<table class="regles-table">
  <tr><th>Action</th><th>Résumé</th></tr>
  <tr><td>Attaque</td><td>Effectuer une attaque avec une arme ou à mains nues.</td></tr>
  <tr><td>Désengagement</td><td>Votre déplacement ne provoque pas d''attaques d''Opportunité pour le reste du tour.</td></tr>
  <tr><td>Esquive</td><td>Les jets d''attaque vous visant ont le Désavantage et vous avez l''Avantage aux JS Dextérité jusqu''à votre prochain tour.</td></tr>
  <tr><td>Influence</td><td>Test de Charisme (Persuasion ou Supercherie) ou Sagesse (Dressage) pour modifier l''attitude d''une créature.</td></tr>
  <tr><td>Intention</td><td>Se préparer à entreprendre une action en réaction à un déclencheur défini.</td></tr>
  <tr><td>Magie</td><td>Lancer un sort, utiliser un objet magique ou une aptitude magique.</td></tr>
  <tr><td>Observation</td><td>Test de Sagesse (Intuition, Médecine, Perception ou Survie).</td></tr>
  <tr><td>Pointe</td><td>Déplacement supplémentaire égal à votre Vitesse pour le reste du tour.</td></tr>
  <tr><td>Soutien</td><td>Aider une autre créature dans un test ou un jet d''attaque, ou lui administrer les premiers soins.</td></tr>
  <tr><td>Utilisation</td><td>Utiliser un objet non magique.</td></tr>
</table>

<p>Jusqu''au début de votre tour suivant, les jets d''attaque vous visant ont le Désavantage et vous avez l''Avantage aux JS Dextérité. Vous perdez ce bénéfice si vous subissez l''état Neutralisé ou si votre Vitesse tombe à 0.</p>

<p><strong>Étude</strong></p>

<p>Effectuer un test d''Intelligence (Arcanes, Histoire, Investigation, Nature ou Religion).</p>

<p><strong>Furtivité</strong></p>

<p>Effectuer un test de Dextérité (Discrétion).</p>

<p><strong>Influence</strong></p>

<p>Effectuer un test de Charisme (Intimidation, Persuasion, Représentation ou Tromperie) ou de Sagesse (Dressage) pour influer sur l''attitude d''une créature.</p>

<p><strong>Intention</strong></p>

<p>Se préparer à entreprendre une action en réaction au déclencheur que vous définissez.</p>

<p><strong>Magie</strong></p>

<p>Lancer un sort, utiliser un objet magique ou une aptitude magique.</p>

<p><strong>Action</strong></p>

<p><strong>Résumé</strong></p>

<p><strong>Observation</strong></p>

<p>Effectuer un test de Sagesse (Intuition, Médecine, Perception ou Survie).</p>

<p><strong>Pointe</strong></p>

<p>Pour le reste du tour, vous bénéficiez d''un déplacement supplémentaire égal à votre Vitesse.</p>

<p><strong>Soutien</strong></p>

<p>Aider une autre créature dans le cadre d''un test de caractéristique ou d''un jet d''attaque, ou lui administrer les premiers soins.</p>

<p><strong>Utilisation</strong></p>

<p>Utiliser un objet non magique.</p>

<p>Personnages-joueurs et monstres peuvent tenter d''autres activités que celles couvertes par ces actions. De nombreuses aptitudes de classe et autres capacités vous fournissent d''autres options d''action, et vous pouvez en improviser d''autres. Lorsque vous décrivez une action non détaillée dans les règles, le MJ vous dira si elle est possible et quel genre de Test d20 effectuer, le cas échéant.</p>

<p><strong>Une chose à la fois</strong></p>

<p>Le jeu recourt aux actions pour gérer ce que vous pouvez faire à un instant donné. Vous ne pouvez entreprendre qu''une seule action à la fois. Ce principe est primordial au combat, comme le décrit la section « Combat », plus loin dans « Comment jouer ». Les actions peuvent toutefois intervenir dans d''autres contextes : lors d''une interaction sociale, vous pouvez tenter d''influencer une créature ou de recourir à l''action Observation pour interpréter son langage corporel, mais vous ne pouvez pas accomplir les deux en même temps. Et lorsque vous explorez un donjon, vous ne pouvez pas simultanément entreprendre l''action Observation pour chercher les pièges et l''action Soutien pour aider un autre personnage à débloquer une porte (via l''action Utilisation).</p>

<h3>Actions Bonus</h3>

<p>Divers sorts, aptitudes de classe et autres capacités vous permettent d''entreprendre une action supplémentaire à votre tour, ce qu''on appelle une action Bonus. L''aptitude Ruse du Roublard, par exemple, lui permet d''entreprendre une action Bonus. Vous ne pouvez entreprendre une action Bonus que si une aptitude spéciale, un sort ou autre élément du jeu spécifie que vous pouvez accomplir quelque chose par une action Bonus. Sans cela, vous n''avez tout bonnement pas d''action Bonus à entreprendre. Vous ne pouvez entreprendre qu''une seule action Bonus, toujours à votre tour, si bien qu''il vous faut choisir laquelle dans le cas où vous auriez accès à plusieurs actions Bonus. Vous choisissez à quel moment de votre tour entreprendre une action Bonus, sauf mention contraire dans la description de celle-ci. Tout ce qui vous prive de la capacité à entreprendre des actions vous empêche également d''entreprendre une action Bonus.</p>

<h3>Réactions</h3>

<p>Certaines aptitudes spéciales et situations, ainsi que certains sorts vous permettent d''effectuer une action spéciale appelée Réaction. Une Réaction est une réponse instantanée à un déclencheur, qui peut intervenir à votre tour ou à celui de quelqu''un d''autre. L''attaque d''Opportunité, décrite plus loin dans « Comment jouer », est la Réaction la plus courante. Lorsque vous jouez votre Réaction, vous devez attendre le début de votre tour suivant pour en jouer une nouvelle. Si la Réaction interrompt le tour d''une autre créature, celle-ci peut reprendre son tour juste après la Réaction. En termes de séquence, une Réaction intervient aussitôt après son déclencheur, sauf mention contraire dans la description de la Réaction.</p>',
       reg_date_modif = NOW()
WHERE  reg_slug = 'actions'
  AND  reg_ruleset_var_id = @ddver;

-- [7] interactions-sociales
UPDATE dd_regles
SET    reg_texte = '<p>Au fil de leurs aventures, les personnages-joueurs rencontrent des gens très divers et font face à des monstres plus bavards que bagarreurs. C''est dans ces situations qu''interviennent les interactions sociales, qui peuvent prendre bien des formes. Vous pouvez ainsi tenter de convaincre un cambrioleur de confesser ses méfaits ou chercher à amadouer un garde. Le maître de jeu assume le rôle de tous les personnages non-joueurs participant à ces échanges. L''attitude d''un PNJ vis-à-vis de votre aventurier peut être Amicale, Indifférente ou Hostile (définitions dans « Glossaire de règles »). Les PNJ Amicaux sont enclins à vous aider, tandis que les PNJ Hostiles seront plutôt des obstacles sur votre chemin. Les interactions sociales se gèrent sur deux axes : l''interprétation et les tests de caractéristique.</p>

<p><strong>Interprétation</strong></p>

<p>Le « roleplay », ou l''interprétation, revient tout bonnement à jouer son rôle. Dans ces scènes, c''est vous, en tant que joueur, qui décidez comment votre personnage pense, agit et s''exprime. Le roleplay fait partie intégrante du jeu dans sa globalité, mais les interactions sociales lui donnent la part belle. Quand vous interprétez ainsi votre PJ, vous choisirez entre l''approche active et l''approche descriptive. Le MJ se base sur la personnalité des PNJ et le comportement de votre aventurier pour définir comment réagissent les interlocuteurs PNJ. Un bandit couard cèdera plus facilement à la menace d''un emprisonnement. Une marchande rétive ne daignera pas aider les personnages s''ils l''importunent. Un dragon vaniteux boira du petit lait si on le flatte. Lorsque le MJ interprète un PNJ, notez bien comment il campe sa personnalité. Vous pourriez en apprendre plus sur ses desseins et profiter de ces renseignements pour mieux l''influencer.</p>

<p>Si vous offrez à un PNJ ce qu''il désire ou savez jouer avec ses goûts, ses craintes ou ses ambitions, vous pourrez nouer des liens, éviter de recourir à la violence ou obtenir une information cruciale. À l''inverse, si vous offensez un fier combattant ou médisez sur les alliés d''un aristocrate, vous aurez grand mal à convaincre ou duper ceux qui vous écoutent.</p>

<h3>Tests de caractéristique</h3>

<p>Les tests de caractéristique jouent parfois un rôle clé dans la résolution d''un échange avec des PNJ. Vos efforts d''interprétation peuvent influer sur l''attitude d''un PNJ, mais il peut rester une part d''aléatoire si le MJ souhaite que les dés interviennent dans la résolution de vos échanges avec le PNJ. Dans une telle situation, le MJ vous demandera généralement d''entreprendre l''action Influence. Penchez-vous sur vos maîtrises de compétence lorsqu''il s''agit de préparer un échange avec un PNJ ; privilégiez les approches qui tirent profit des maîtrises de votre groupe. Si le groupe a par exemple besoin de tromper un garde pour avoir accès à un château, le Roublard qui a la maîtrise de Tromperie est censé mener les débats.</p>',
       reg_date_modif = NOW()
WHERE  reg_slug = 'interactions-sociales'
  AND  reg_ruleset_var_id = @ddver;

-- [8] exploration
UPDATE dd_regles
SET    reg_texte = '<p>L''exploration consiste à prospecter des lieux sombres et dangereux qui regorgent de mystères. Les règles de cette section détaillent la manière dont les aventuriers interagissent avec l''environnement de tels sites.</p>

<p><strong>Matériel d''aventure</strong></p>

<p>Quand les aventuriers explorent, leur équipement leur est utile de bien des façons. Ils peuvent ainsi atteindre des endroits peu accessibles avec une échelle, percevoir ce qui leur échapperait grâce à une torche ou autre source de lumière, crocheter les portes et coffres verrouillés avec des outils de voleur, et ralentir leurs poursuivants avec des chausse-trappes. Vous trouverez les règles sur les nombreux objets utiles en aventure à « Équipement ». Les objets des sections « Outils » et « Matériel d''aventurier » sont particulièrement intéressants. Les armes présentées à « Équipement » ne se limitent pas aux batailles ; un bâton de combat, par exemple, peut servir à appuyer sur un poussoir peu engageant dont vous préférez éviter le contact.</p>

<h3>Vision et éclairage</h3>

<p>Certaines tâches d''aventurier, telles que détecter le danger, frapper l''ennemi et désigner la cible d''un sort, dépendent de la vision, c''est pourquoi les effets qui limitent la Visibilité peuvent vous gêner.</p>

<p>Visibilité Certaines zones sont à Visibilité nulle ou réduite. Dans une zone à Visibilité réduite, comme en conditions de Lumière faible, dans un brouillard léger ou une végétation modérée, les créatures ont le Désavantage aux tests de Sagesse (Perception) basés sur la vue. Dans une zone à Visibilité nulle, comme dans les Ténèbres, dans un brouillard épais ou une végétation très dense, tout est opaque. Vous subissez alors l''état Aveuglé (cf. « Glossaire de règles ») lorsque vous tentez d''y voir quelque chose.</p>

<p><strong>Éclairage</strong></p>

<p>La présence ou l''absence de lumière détermine la catégorie d''éclairage d''une zone, comme définie ci-après. Lumière vive. Une Lumière vive permet à la plupart des créatures de voir normalement. Un ciel chargé suffit à produire une Lumière vive, de même que les torches, lanternes, flammes et autres sources de lumière, du moins dans un certain rayon. Lumière faible. Une Lumière faible, ou pénombre, produit une zone à Visibilité réduite. Une zone de Lumière faible fait souvent la transition entre la Lumière vive et les Ténèbres environnantes. La douce lueur du crépuscule et de l''aube compte aussi comme Lumière faible. De même, la pleine lune peut baigner le paysage de Lumière faible. Ténèbres. Les Ténèbres créent une zone à Visibilité nulle. En extérieur et de nuit, les personnages sont exposés aux Ténèbres (même avec du clair de lune), comme c''est le cas au fond d''un donjon non éclairé, ou dans une zone de Ténèbres magiques.</p>

<p><strong>Sens spéciaux</strong></p>

<p>Certaines créatures sont pourvues de sens spéciaux qui favorisent leur perception dans certaines situations. La section « Glossaire de règles » définit les sens spéciaux suivants :</p>

<p>Perception des vibrations Vision aveugle Vision dans le noir Vision lucide</p>

<h3>Se cacher</h3>

<p>Il n''est pas rare qu''aventuriers et monstres se cachent, que ce soit pour s''épier, se glisser dans le dos d''un gardien ou tendre une embuscade. C''est le maître de jeu qui décide quand les circonstances permettent de se cacher. Lorsque vous tentez de vous cacher, vous entreprenez l''action Furtivité.</p>

<h3>Interagir avec des objets</h3>

<p>Les interactions avec des objets se résolvent souvent simplement. Le joueur indique au MJ ce que son personnage fait, comme actionner un levier ou ouvrir une porte, et le MJ lui décrit ce qui se passe. Certaines règles encadrent toutefois ce qu''il est possible de faire avec un objet, comme détaillé ci-après.</p>

<h3>Qu''est-ce qu''un objet ?</h3>

<p>Dans le cadre de ces règles, nous ne traitons que des objets inanimés et distincts tels que fenêtres, portes, épées, livres, tables, chaises et pierres. Un bâtiment ou un véhicule entier, composé de nombreux objets, n''est pas considéré comme un objet.</p>

<p><strong>Interactions passagères</strong></p>

<p>Quand le temps manque, comme c''est le cas au combat, les interactions avec les objets sont limitées : une interaction gratuite par tour. Celle-ci doit intervenir durant le déplacement ou l''action de la créature. Pour toute interaction additionnelle, il faut entreprendre l''action Utilisation, comme expliqué dans la section « Combat », plus loin dans « Comment jouer ».</p>

<p><strong>Trouver un objet caché</strong></p>

<p>Lorsque votre personnage cherche ce qui peut être caché, comme un passage secret ou un piège, le MJ vous demande généralement d''effectuer un test de Sagesse (Perception), à condition que l''endroit où vous précisez que votre PJ fouille soit à proximité de ce qui est caché. En cas de réussite, vous trouvez cette chose ou remarquez des détails décisifs, voire les deux. Si la zone de fouille que vous spécifiez pour votre PJ n''est nullement proche de ce qui est caché, aucun test de Sagesse (Perception) ne le révèlera, quel qu''en soit le résultat.</p>

<p><strong>Transport des objets</strong></p>

<p>Vous pouvez généralement porter votre équipement et votre trésor sans vous soucier du poids de tous ces objets. Si vous tentez de transporter un objet particulièrement lourd ou un grand nombre d''objets plus légers, le MJ peut vous soumettre aux règles de capacité de charge de « Glossaire de règles ».</p>

<p><strong>Bris des objets</strong></p>

<p>Au prix d''une action, vous pouvez briser ou détruire automatiquement un objet non magique fragile tel qu''un récipient en verre ou un morceau de papier. Si vous comptez endommager un objet plus robuste, le MJ peut recourir aux règles de bris des objets de « Glossaire de règles ».</p>

<p><strong>Ordre de marche</strong></p>

<p>Les aventuriers sont censés fixer un ordre de marche pour leurs trajets, que ce soit en extérieur ou en intérieur. L''ordre de marche permet de déterminer facilement quels personnages sont affectés par les pièges, lesquels sont susceptibles de détecter l''ennemi et lesquels sont les plus proches de ces adversaires quand un combat éclate. Vous pouvez modifier l''ordre de marche hors des combats et le consigner à votre guise : sur un bout de papier, par exemple, ou en disposant des figurines.</p>

<h3>Dangers</h3>

<p>Les monstres constituent les principaux périls des personnages, mais d''autres menaces les attendent. La section « Glossaire de règles » définit les dangers suivants :</p>

<p>Asphyxie Brûlures Chutes Déshydratation</p>

<p><strong>Malnutrition</strong></p>

<h3>Voyage</h3>

<p>Au fil d''une aventure, les personnages seront parfois amenés à couvrir de longues distances dans le cadre de voyages pouvant durer des heures, voire des jours. Le MJ peut résumer un tel voyage sans devoir calculer précisément les distances et les temps de trajet, ou bien recourir scrupuleusement aux règles d''allure de voyage. Quand chaque seconde compte et que la précision est de mise, reportez-vous aux règles de déplacement de la section « Combat », plus loin dans « Comment jouer ».</p>

<p><strong>Allure de voyage</strong></p>

<p>Quand il se déplace hors des combats, un groupe peut évoluer à allure rapide, normale ou lente, comme indiqué sur la table « Allure de voyage ». La table indique la distance que le groupe peut couvrir dans un certain intervalle ; si le groupe est à dos de cheval ou d''une autre monture, il peut couvrir le double de cette distance en une heure, après quoi les montures doivent prendre un Repos court ou long pour pouvoir reprendre à une allure si soutenue (la section « Équipement » propose une sélection de montures et leurs prix de vente). La section « Boîte à outils ludique » propose des règles qui limitent ces choix selon le type de terrain.</p>

<p><strong>Allure de voyage</strong></p>

<p>Distance parcourue par… Allure</p>

<p><strong>Minute</strong></p>

<p><strong>Heure</strong></p>

<p><strong>Jour</strong></p>

<p><strong>Rapide</strong></p>

<p>120 m 6 km 45 km</p>

<p><strong>Normale</strong></p>

<p>90 m 4,5 km 36 km</p>

<p><strong>Lente</strong></p>

<p>60 m 3 km 27 km Chaque allure de voyage s''accompagne d''effets mécaniques, comme indiqué ci-après. Rapide. Un voyageur qui évolue à allure rapide a le Désavantage aux tests de Sagesse (Perception ou Survie) et Dextérité (Discrétion). Normale. Un voyageur qui évolue à allure normale a le Désavantage aux tests de Dextérité (Discrétion). Lente. Un voyageur qui évolue à allure lente a l''Avantage aux tests de Sagesse (Perception ou Survie).</p>

<p><strong>Véhicules</strong></p>

<p>Celles et ceux qui voyagent en chariot, en calèche ou à bord d''un autre véhicule terrestre doivent opter pour l''allure normale. À bord d''un bateau, c''est l''embarcation qui détermine la vitesse ; les passagers ne choisissent par leur allure de voyage. Si la taille du navire et celle de l''équipage le permettent, il est dans certains cas possible de voguer jusqu''à 24 heures par jour. La section « Équipement » propose des véhicules avec leurs prix de vente.</p>',
       reg_date_modif = NOW()
WHERE  reg_slug = 'exploration'
  AND  reg_ruleset_var_id = @ddver;

-- [9] combat
UPDATE dd_regles
SET    reg_texte = '<p>Les aventuriers font face à de nombreux monstres redoutables et d''infâmes adversaires. C''est dans ces moments qu''un combat éclate souvent.</p>

<h3>L''ordre du combat</h3>

<p>Le combat classique est un affrontement entre deux camps, qui se traduit par des coups portés avec diverses armes, des feintes, des parades, des déplacements tactiques et des incantations de sorts. Le jeu structure le combat en cycles faits de rounds et de tours. Un round représente un intervalle d''environ 6 secondes dans l''univers de jeu. Au cours d''un round, chaque participant à la bataille joue un tour. L''ordre des tours est déterminé au début du combat, lorsque chacun lance le dé d''Initiative. Une fois que tout le monde a joué son tour, l''affrontement se prolonge par un round supplémentaire si aucun des camps n''est vaincu.</p>

<p><strong>Combat étape par étape</strong></p>

<p>Le combat se déroule selon ces étapes :</p>

<ol>
  <li>Définir les positions. Le maître de jeu détermine où se trouvent les différents personnages et monstres. Prenant en compte l''ordre de marche des aventuriers ou les positions que leurs joueurs ont annoncées dans la zone, le MJ fixe le positionnement de leurs adversaires, en décidant à quelle distance ils sont et dans quelle direction.</li>
  <li>Jouer l''Initiative. Tous les participants au combat jouent l''Initiative, pour déterminer l''ordre des tours des combattants.</li>
  <li>Séquence des tours. Chaque participant au combat joue son tour, selon l''ordre d''Initiative. Une fois que tous les participants ont joué leur tour, le round prend fin. Répétez cette étape jusqu''à ce que l''affrontement cesse.</li>
</ol>

<p><strong>Initiative</strong></p>

<p>L''Initiative détermine la séquence des tours durant un combat. Lorsque le combat commence, chaque participant joue l''Initiative : chacun effectue un test de Dextérité qui détermine son rang dans l''ordre d''Initiative. Le MJ joue l''Initiative des monstres. Dans le cas d''un groupe de créatures identiques, le MJ peut se contenter d''un seul jet, chaque membre de ce groupe ayant le même rang d''Initiative. Surprise. Si un combattant est surpris quand le combat s''engage, il subit le Désavantage à son jet d''Initiative. Exemple : une créature embusquée engage le combat contre un adversaire qui ne se doute de rien. Dans ce cas, cet adversaire est surpris.</p>

<p>Ordre d''Initiative. Le total du test d''un combattant est appelé rang d''Initiative ou tout simplement Initiative. Le MJ classe les combattants par ordre décroissant de leur Initiative. Il définit ainsi l''ordre dans lequel les participants vont agir round après round. L''ordre d''Initiative reste inchangé d''un round à l''autre. Égalité. En cas d''égalité, le MJ décide dans quel ordre agissent les monstres en question, tandis que les joueurs décident de l''ordre pour les PJ ex aequo. Dans le cas d''une égalité entre un monstre et un personnage-joueur, le MJ tranche.</p>

<p><strong>Votre tour</strong></p>

<p>À votre tour, vous pouvez vous déplacer d''une distance n''excédant pas votre Vitesse et entreprendre une action. Vous décidez ce qui intervient en premier entre votre déplacement et votre action. Les principales actions possibles figurent à « Actions », plus haut dans « Comment jouer ». Les aptitudes de personnage et les profils de monstre fournissent en outre d''autres options. La section « Déplacement et position », plus loin dans « Comment jouer », détaille les règles de déplacement. Communiquer. Vous pouvez communiquer par les moyens disponibles, que ce soit par quelques mots</p>

<p><strong>Jeu sur quadrillage</strong></p>

<p>Si vous jouez en vous servant de plans quadrillés et de figurines ou de jetons, respectez ces règles. Cases. Chaque case représente un carré de 1,50 m de côté. Vitesse. Plutôt que de vous déplacer mètre par mètre ou pas à pas, déplacez-vous case par case, en segmentant votre déplacement par tranches de 1,50 m. Pour savoir combien votre Vitesse représente de cases, divisez-la par 3 puis doublez ce résultat. Ainsi, une Vitesse de 9 m correspond à 6 cases. Si vous recourez souvent aux quadrillages, n''hésitez pas à convertir votre Vitesse en cases sur votre fiche de personnage. Entrer dans une case. Pénétrer dans une case vous demande un « droit d''entrée » en termes de déplacement. Il vous faut acquitter 1 case de déplacement pour entrer dans une case inoccupée adjacente (orthogonalement ou diagonalement) à votre espace. Pénétrer dans une case de Terrain difficile vous coûte 2 cases de déplacement. D''autres effets peuvent faire grimper encore ce droit d''entrée. Angles. Un déplacement en diagonale ne permet pas de traverser l''angle d''un mur, un gros arbre ou un autre élément de l''environnement qui remplit son propre espace. Distances. Pour déterminer la distance qui sépare deux choses sur un plan quadrillé, qu''il s''agisse de créatures ou d''objets, comptez les cases à partir d''une case adjacente à l''une de ces choses en arrêtant le compte dans l''espace de l''autre chose. Tout cela en empruntant le chemin le plus court.</p>

<p>ou par gestes brefs, lorsque vous jouez votre tour. Cela ne dépense ni votre action ni votre déplacement. Les échanges plus longs, explications détaillées ou négociations avec l''ennemi, demandent une action. C''est par l''action Influence qu''on tentera le plus souvent d''influencer un monstre. Interagir avec des objets ou l''environnement. Vous pouvez interagir avec un objet ou un élément de l''environnement, gratuitement, durant votre déplacement ou votre action (mais pas les deux). Vous pouvez ainsi ouvrir une porte en plein déplacement pour venir à portée d''un adversaire. Si vous souhaitez interagir avec un second objet, il vous faut entreprendre l''action Utilisation. L''utilisation de certains objets magiques et autres objets spéciaux vous demande d''y consacrer votre action, comme indiqué dans leur description. Le MJ peut vous demander de consacrer une action à ces tâches lorsqu''un soin particulier est demandé ou lorsqu''elles présentent une difficulté inhabituelle. Ainsi le MJ peut-il exiger que vous entrepreniez l''action Utilisation pour ouvrir une porte coincée ou pour actionner la manivelle d''un pont-levis. Ne rien faire à votre tour. Vous pouvez parfaitement renoncer à votre déplacement ou à votre action, et même ne rien faire du tout à votre tour. Si vous n''arrivez pas à vous décider, rabattez-vous sur l''action Esquive ou l''action Intention (pour agir plus tard).</p>

<p><strong>Fin du combat</strong></p>

<p>Le combat prend fin lorsque l''un des camps est vaincu, que les créatures qui le composent aient trouvé la mort, perdu connaissance, pris la fuite ou se soient rendues. La fin des hostilités peut aussi intervenir si les deux camps s''accordent pour y mettre un terme.</p>

<h3>Déplacement et position</h3>

<p>À votre tour, vous pouvez vous déplacer d''une distance n''excédant pas votre Vitesse. Vous pouvez aussi décider de ne pas vous déplacer. Votre déplacement peut inclure des portions d''escalade, de nage, de reptation et de saut (cf. « Glossaire de règles »). Ces différents modes de déplacement peuvent s''associer avec votre déplacement de base ou constituer l''intégralité de votre déplacement. Quels que soient ces modes, vous déduisez la distance couverte par chacune de ces parties de votre Vitesse, jusqu''à ce qu''il ne vous en reste plus ou que vous ayez terminé votre déplacement, selon ce qui se produit en premier. La Vitesse d''un personnage se détermine à sa création. La Vitesse d''un monstre est indiquée dans son profil. Reportez-vous à « Glossaire de règles » pour plus de détails sur la Vitesse et les vitesses spéciales telles que Vitesse d''escalade, Vitesse de nage et Vitesse de vol.</p>

<p>Terrain difficile Les combattants sont souvent ralentis par un Terrain difficile. Les meubles bas, les gravats, les taillis, les escaliers raides, la neige et la boue sont autant d''exemples de Terrain difficile. Toute distance parcourue sur un Terrain difficile vous coûte le double en termes de déplacement, même quand plusieurs critères de la zone en font un Terrain difficile.</p>

<p><strong>Scinder son déplacement</strong></p>

<p>Vous pouvez scinder votre déplacement à votre tour, en le répartissant à votre guise avant et après toute action, action Bonus et Réaction que vous entreprenez à ce tour. Si vous disposez par exemple d''une Vitesse de 9 m, vous pouvez vous déplacer de 3 m, entreprendre une action, puis vous déplacer encore de 6 m.</p>

<p><strong>Plonger à terre</strong></p>

<p>À votre tour, vous pouvez vous octroyer l''état À terre (cf. « Glossaire de règles ») sans dépenser d''action ni le moindre déplacement, à condition que votre Vitesse soit supérieure à 0.</p>

<p><strong>Cat. de taille de la créature</strong></p>

<p>Toute créature se classe dans une catégorie de taille, qui détermine la largeur de l''espace carré qu''elle occupe sur un plan, comme indiqué sur la table « Tailles et espaces des créatures ». Les catégories de taille vont de la plus petite (TP) à la plus grande (Gig). L''espace d''une créature correspond à la zone qu''elle contrôle au combat et dont elle a besoin pour combattre efficacement. La taille d''un personnage est déterminée par son espèce, tandis que celle d''un monstre figure sur son profil de jeu.</p>

<p>Tailles et espaces des créatures Cat. de taille</p>

<p><strong>Espace (mètres) Espace (cases)</strong></p>

<p><strong>Très petite (TP)</strong></p>

<p>75 cm de côté 4 par case</p>

<p><strong>Petite (P)</strong></p>

<p>1,50 m de côté 1 case</p>

<p><strong>Moyenne (M)</strong></p>

<p>1,50 m de côté 1 case</p>

<p><strong>Grande (G)</strong></p>

<p>3 m de côté 4 cases (2 sur 2)</p>

<p><strong>Très grande (TG) 4,50 m de côté</strong></p>

<p>9 cases (3 sur 3)</p>

<p><strong>Gigantesque (Gig) 6 m de côté</strong></p>

<p>16 cases (4 sur 4)</p>

<p><strong>Se déplacer au milieu d''autres créatures</strong></p>

<p>Au cours de votre déplacement, vous pouvez traverser l''espace d''un allié, d''une créature dotée de l''état Neutralisé (cf. « Glossaire de règles »), d''une créature de taille TP ou d''une créature dont la catégorie de taille est supérieure ou inférieure à la vôtre d''au moins deux crans. L''espace d''une autre créature est considéré pour vous comme Terrain difficile, sauf si elle est votre alliée ou de taille TP. Vous ne pouvez pas terminer volontairement votre déplacement dans un espace occupé par une autre créature. Si, pour une raison quelconque, vous terminez un tour dans un espace où se trouve une autre créature, vous subissez l''état À terre (cf. « Glossaire de règles ») sauf si vous êtes de taille TP ou d''une catégorie de taille supérieure à celle de l''autre créature.</p>

<h3>Effectuer une attaque</h3>

<p>Lorsque vous entreprenez l''action Attaque, vous effectuez une attaque. Certaines autres actions, actions Bonus et Réactions vous permettent aussi d''effectuer une attaque. Que vous utilisiez une arme de corps à corps ou une arme à distance, ou effectuiez votre jet d''attaque dans le cadre d''un sort, toute attaque obéit à la structure suivante :</p>

<ol>
  <li>Choisissez une cible. Désignez une cible à portée de votre attaque : une créature, un objet ou un lieu.</li>
  <li>Déterminez les modificateurs. Le MJ détermine si la cible dispose d''un abri (voir section suivante) et si un Avantage ou un Désavantage s''applique contre elle. Par ailleurs, des sorts, capacités spéciales et autres effets peuvent entraîner des malus ou bonus à votre jet d''attaque.</li>
  <li>Résolvez l''attaque. Vous effectuez le jet d''attaque, comme décrit plus haut dans « Comment jouer ». S''il touche, vous déterminez les dégâts, sauf si l''attaque concernée est assortie de règles qui spécifient autre chose. Certaines attaques entraînent des effets spéciaux en plus des dégâts ou à leur place.</li>
</ol>

<p><strong>Abri</strong></p>

<p>Les murs, arbres, créatures et autres obstacles peuvent fournir un abri, qui protège la cible. Comme détaillé dans la table Abris, il existe trois degrés d''abris qui octroient chacun un bénéfice différent aux cibles. Une cible ne peut profiter d''un abri qu''en cas d''attaque ou d''effet provenant de l''autre côté de l''abri. Quand une cible se trouve derrière plusieurs éléments d''abri, seul celui qui fournit le niveau de protection le plus élevé est pris en compte ; les degrés ne se cumulent pas. Exemple : si une cible se trouve derrière une créature qui lui donne un abri partiel et un arbre qui lui donne un abri supérieur, elle ne bénéficie que d''un abri supérieur.</p>

<p><strong>Assaillants et cibles non visibles</strong></p>

<p>Lorsque vous effectuez un jet d''attaque contre une cible que vous ne voyez pas, vous avez le Désavantage au jet. Cela reste vrai que vous tentiez de deviner la position de la cible ou que vous cibliez une créature que vous entendez, mais ne voyez pas. Si la cible ne se trouve pas à l''endroit que vous visez, votre attaque rate. Lorsqu''une créature ne vous voit pas, vous avez l''Avantage aux jets d''attaque contre elle. Si vous êtes caché quand vous effectuez un jet d''attaque, votre position est révélée lorsque votre attaque touche ou rate.</p>

<p class="table-titre"><strong>Abris</strong></p>

<table class="regles-table">
  <tr><th>Degré</th><th>Bénéfice pour la cible</th><th>Octroyé par</th></tr>
  <tr><td>Partiel</td><td>+2 à la CA et aux JS Dextérité</td><td>Une créature ou un objet qui protège au moins la moitié du corps</td></tr>
  <tr><td>Supérieur</td><td>+5 à la CA et aux JS Dextérité</td><td>Un objet qui abrite au moins les ¾ du corps de la cible</td></tr>
</table>

<h3>Attaques à distance</h3>

<p>Lorsque vous effectuez une attaque à distance, vous tirez à l''arc, lancez une hache ou des projectiles vers un adversaire distant. De nombreux sorts font également intervenir une attaque à distance.</p>

<p><strong>Portée</strong></p>

<p>Vous ne pouvez effectuer une attaque à distance que si votre cible se situe à une portée spécifiée. Quand une attaque à distance, comme celle qu''on effectue avec un sort, n''indique qu''une seule portée, vous ne pouvez pas attaquer une cible hors de cette portée. Certaines attaques à distance, comme celles qu''on effectue avec un arc long, présentent deux portées. Le nombre le plus petit représente la portée normale, tandis que le plus grand correspond à la portée longue. Votre jet d''attaque subit le Désavantage lorsque votre cible se situe au-delà de la portée normale ; en outre, vous ne pouvez pas attaquer une cible située au-delà de la portée longue.</p>

<p><strong>Attaques à distance en combat rapproché</strong></p>

<p>La visée d''une attaque à distance s''avère plus compliquée quand un adversaire se tient près de vous. Lorsque vous effectuez une attaque à distance avec une arme, un sort ou autre moyen, vous avez le Désavantage au jet d''attaque si vous vous trouvez dans un rayon de 1,50 m d''un ennemi qui vous voit et qui ne subit pas l''état Neutralisé (cf. « Glossaire de règles »).</p>

<h3>Attaques de corps à corps</h3>

<p>Une attaque de corps à corps vous permet d''attaquer une cible à portée d''allonge. Elle fait généralement intervenir une arme tenue en main ou une attaque à mains nues. De nombreux monstres effectuent des attaques de corps à corps avec leurs griffes, leurs crocs et autres parties du corps. Quelques sorts font aussi intervenir des attaques de corps à corps.</p>

<p><strong>Allonge</strong></p>

<p>La plupart des créatures ont une allonge de 1,50 m et peuvent donc attaquer des cibles situées à 1,50 m ou moins lorsqu''elles effectuent une attaque de corps à corps. Certaines créatures disposent d''attaques de corps à corps dont l''allonge est supérieure à 1,50 m, comme l''indique leur description.</p>

<h3>Attaques d''Opportunité</h3>

<p>Les combattants restent à l''affût des erreurs de l''ennemi. Si vous vous éloignez de l''ennemi sans prendre garde, vous risquez de provoquer une attaque d''Opportunité. Éviter les attaques d''Opportunité. Vous pouvez éviter de provoquer une attaque d''Opportunité en entreprenant l''action Désengagement. Lorsque vous vous téléportez ou que l''on vous déplace sans que vous y consacriez de déplacement, ni votre action, action Bonus ou Réaction, vous ne provoquez pas d''attaque d''Opportunité. Ainsi, vous ne provoquez pas d''attaque d''Opportunité quand une explosion vous projette hors de la zone d''allonge d''un ennemi ou quand une chute vous éloigne d''un adversaire. Effectuer une attaque d''Opportunité. Vous pouvez effectuer une attaque d''Opportunité lorsqu''une créature que vous voyez quitte votre zone d''allonge. Vous devez alors jouer votre Réaction pour effectuer une attaque de corps à corps avec une arme ou une attaque à mains nues, contre cette créature. L''attaque intervient juste avant que la créature ait quitté votre zone d''allonge.</p>

<h3>Combat monté</h3>

<p>Une créature consentante dont la catégorie de taille est au moins d''un cran supérieure à un cavalier peut lui servir de monture si son anatomie le lui permet, en accord avec les règles suivantes.</p>

<p><strong>Monter et descendre</strong></p>

<p>Durant un déplacement, vous pouvez monter sur une créature située dans un rayon de 1,50 m de vous ou en descendre. Il vous faut consacrer la moitié de votre Vitesse (arrondie à l''inférieur) pour ce faire. Par exemple, si votre Vitesse est de 9 m, vous devez consacrer 4,50 m de déplacement à monter sur un cheval.</p>

<p><strong>Contrôler une monture</strong></p>

<p>Vous ne pouvez contrôler une monture que si elle est formée à recevoir un cavalier. Les chevaux domestiques, mules et créatures assimilées ont été dressés de la sorte. L''Initiative d''une monture contrôlée est la même que la vôtre quand vous la montez. Elle se déplace selon vos instructions à votre tour, durant lequel elle n''a que trois options d''action : Désengagement, Esquive et Pointe. Une monture contrôlée peut se déplacer et agir, y compris au tour où vous grimpez sur son dos. À l''inverse, une monture indépendante (qui vous accepte comme cavalier, mais ne se laisse pas contrôler), garde son propre rang d''Initiative, et agit et se déplace comme bon lui semble.</p>

<h3>Chuter de monture</h3>

<p>Si un effet est sur le point de déplacer votre monture contre sa volonté alors que vous la montez, vous devez réussir un JS Dextérité DD 10 sous peine d''en tomber et de subir l''état À terre (cf. « Glossaire de règles ») dans un espace inoccupé à 1,50 m ou moins de la monture. En combat monté, vous effectuez ce même JS si vousmême ou votre monture êtes jetés À terre.</p>

<h3>Combat subaquatique</h3>

<p>Sous l''eau, les combats obéissent aux règles suivantes.</p>

<p><strong>Combat laborieux</strong></p>

<p>Lorsqu''elle effectue un jet d''attaque de corps à corps sous l''eau avec une arme, une créature qui n''est pas dotée d''une Vitesse de nage a le Désavantage au jet d''attaque, sauf si l''arme inflige des dégâts perforants. Sous l''eau, un jet d''attaque à distance avec une arme rate automatiquement sa cible si celle-ci se trouve au-delà de la portée normale ; le jet d''attaque a le Désavantage contre une cible à portée normale.</p>

<p><strong>Résistance au feu</strong></p>

<p>Tout ce qui se trouve sous l''eau reçoit la Résistance aux dégâts de feu (voir « Dégâts et soins »).</p>',
       reg_date_modif = NOW()
WHERE  reg_slug = 'combat'
  AND  reg_ruleset_var_id = @ddver;

-- [10] degats-et-soins
UPDATE dd_regles
SET    reg_texte = '<p>Les blessures et la mort constituent une menace récurrente. Elles sont gérées par les règles suivantes.</p>

<h3>Points de vie</h3>

<p>Les points de vie (ou simplement pv) représentent la robustesse et l''envie de vivre. Les créatures dotées de beaucoup de points de vie sont plus difficiles à tuer. Votre maximum de points de vie correspond au nombre de points de vie dont vous disposez quand vous êtes indemne. Vos points de vie actuels sont compris entre ce maximum et 0, valeur minimale absolue. Chaque fois que vous subissez des dégâts, ceux-ci sont déduits de vos points de vie. La perte de points de vie n''a aucun effet sur vos capacités jusqu''à ce que vous tombiez à 0 point de vie. Si vos points de vie sont inférieurs ou égaux à la moitié de votre maximum, vous êtes En péril, ce qui n''a pas d''effet mécanique en soi, mais peut en activer d''autres.</p>

<p><strong>Repos</strong></p>

<p>Les aventuriers ne peuvent consacrer chaque instant à l''aventure. Ils doivent aussi se reposer. Toute créature peut prendre des Repos courts d''une heure en pleine journée ou un Repos long de 8 heures pour la clôturer. La récupération de points de vie constitue l''un des principaux bénéfices des Repos. La section « Glossaire de règles » fournit les règles propres aux Repos courts et longs.</p>

<h3>Jets de dégâts</h3>

<p>Chaque arme, chaque sort ou capacité de monstre qui cause des dommages spécifie les dégâts infligés. Vous lancez le ou les dés de dégâts, ajoutez les éventuels modificateurs, puis infligez les dégâts totaux à la cible. Si un malus s''applique aux dégâts, il est possible d''infliger 0 dégât, mais pas des dégâts négatifs. Lorsque vous attaquez avec une arme, vous ajoutez aux dégâts votre modificateur de caractéristique, le même que celui du jet d''attaque. Les sorts indiquent quels dés lancer pour les dégâts et spécifient quels éventuels modificateurs ajouter. Sauf mention contraire, vous n''ajoutez pas votre modificateur de caractéristique à des dégâts fixes non issus d''un jet, comme c''est le cas des dégâts d''une sarbacane. La section « Équipement » indique les dés de dégâts des armes et la section « Sorts » ceux des sorts.</p>

<h3>Coups critiques</h3>

<p>Lorsque vous obtenez un Coup critique, vous infligez des dégâts supplémentaires. Lancez deux fois les dés de dégâts, ajoutez-les, puis ajoutez normalement les modificateurs qui s''appliquent. Exemple : si vous obtenez un Coup critique avec une dague, vous lancez 2d4 pour les dégâts au lieu de 1d4, puis vous ajoutez les modificateurs applicables. Si l''attaque fait intervenir d''autres dés de dégâts, comme ceux de l''aptitude Attaque sournoise du Roublard, vous lancez également ceux-ci deux fois.</p>

<h3>Jets de sauvegarde et dégâts</h3>

<p>Les dégâts infligés dans le cadre d''un jet de sauvegarde obéissent à ces règles.</p>

<p><strong>Dégâts contre plusieurs cibles</strong></p>

<p>Lorsque vous produisez un effet infligeant des dégâts, qui impose simultanément un jet de sauvegarde à plus d''une cible, vous ne jouez qu''une seule fois les dégâts ; le résultat s''applique à toutes les cibles concernées. Ainsi, quand un Magicien lance boule de feu, les dés de dégâts ne sont lancés qu''une seule fois pour toutes les créatures prises dans la déflagration.</p>

<p><strong>Réduction de moitié</strong></p>

<p>De nombreux effets à jet de sauvegarde infligent des dégâts réduits de moitié (arrondis à l''inférieur) aux cibles qui réussissent leur JS. Ces « demi-dégâts » sont égaux à la moitié des dégâts qui seraient infligés en cas de JS raté.</p>

<h3>Types de dégâts</h3>

<p>Chaque fois que des dégâts s''appliquent, ils ont un type : feu ou tranchants, par exemple. Les types de dégâts, énumérés dans le « Glossaire de règles », n''ont pas de règle en soi, mais d''autres éléments de règle, comme la Résistance, font appel aux types de dégâts.</p>

<h3>Résistances et Vulnérabilités</h3>

<p>Certains objets et créatures présentent une Résistance ou une Vulnérabilité à certains types de dégâts. Si vous bénéficiez de la Résistance à un type de dégâts, ces dégâts sont réduits de moitié contre vous. Si vous présentez une Vulnérabilité à un type de dégâts, ils sont doublés contre vous. Exemple : si vous avez la Résistance aux dégâts de froid, ces dégâts sont réduits de moitié contre vous, et si vous avez la Vulnérabilité aux dégâts de feu, ceux-ci sont doublés contre vous.</p>

<p><strong>Pas de cumul</strong></p>

<p>Si plusieurs Résistances ou Vulnérabilités affectent un même type de dégâts, une seule Résistance ou Vulnérabilité est prise en compte. Exemple : si vous avez la Résistance aux dégâts nécrotiques ainsi que la Résistance à tous les dégâts, les dégâts nécrotiques sont simplement réduits de moitié contre vous.</p>

<p><strong>Ordre d''application</strong></p>

<p>Les modificateurs aux dégâts s''appliquent dans l''ordre suivant : ajustements (bonus, malus, multiplicateurs, etc.) en premier ; Résistance en deuxième ; Vulnérabilité en troisième. Exemple : une créature dotée de la Résistance à tous les dégâts et de la Vulnérabilité aux dégâts de feu se situe dans une aura magique qui réduit tous les dégâts de 5. Si on lui inflige 28 dégâts de feu, ceux-ci sont d''abord réduits de 5 (à 23 donc), puis réduits de moitié en raison de la Résistance de la créature (ce qui, arrondi à l''inférieur, donne 11), avant d''être doublés par sa Vulnérabilité (pour un total de 22).</p>

<h3>Immunité</h3>

<p>Divers objets et créatures bénéficient de l''Immunité contre certains types de dégâts et certains états. L''Immunité contre un type de dégâts signifie que vous ne subissez jamais de dégâts de ce type ; contre un état, elle indique que celui-ci ne peut pas vous affecter.</p>

<h3>Soins</h3>

<p>Les points de vie se récupèrent par magie (le sort soins, par exemple, ou une potion de guérison), ou par l''intermédiaire d''un Repos court ou long (cf. « Glossaire de règles »).</p>

<p><strong>Assommer une créature</strong></p>

<p>Lorsque vous êtes censé faire tomber une créature à 0 point de vie avec une attaque de corps à corps, vous pouvez à la place la réduire à 1 point de vie en lui imposant l''état Inconscient. Elle entame alors un Repos court, à la fin duquel cet état prend fin. L''état prend également fin si elle récupère au moins 1 point de vie, ou si quelqu''un consacre une action à lui administrer les premiers secours et réussit un test de Sagesse (Médecine) DD 10.</p>

<p>Lorsqu''une telle guérison opère sur vous, ajoutez les points de vie restitués à vos points de vie actuels. Vos points de vie ne peuvent pas dépasser votre maximum de points de vie, si bien que tous les points de vie récupérés en excédent sont perdus. Exemple : si vous recevez 8 points de vie de guérison alors que vous en avez actuellement 14 et que votre maximum de points de vie est de 20, vous n''en récupérez en fait que 6, pas 8.</p>

<h3>Tomber à 0 point de vie</h3>

<p>Quand une créature tombe à 0 point de vie, soit elle meurt sur le coup soit elle perd connaissance, comme expliqué ci-après.</p>

<p><strong>Mort sur le coup</strong></p>

<p>Une créature peut mourir sur-le-champ de plusieurs façons, notamment les suivantes. Mort des monstres. Un monstre meurt dès qu''il tombe à 0 point de vie, mais le maître de jeu peut faire abstraction de cette règle pour un monstre donné et le traiter comme un personnage. Maximum de points de vie de 0. Une créature meurt si son maximum de points de vie atteint 0. Certains effets absorbent l''énergie vitale, ce qui réduit le maximum de points de vie des créatures. Dégâts massifs. Lorsque des dégâts font tomber un personnage à 0 point de vie et qu''il reste un excédent après cette réduction, il meurt sur le coup si cet excédent est au moins égal à son maximum de points de vie. Exemple : si le maximum de points de vie de votre personnage est de 12, qu''il a actuellement 6 points de vie et qu''il subit 18 dégâts, il tombe à 0 point de vie, mais avec un excédent de 12 dégâts. Il meurt dans ce cas, car 12 correspond à son maximum de points de vie.</p>

<p><strong>Trépas d''un personnage</strong></p>

<p>Si votre personnage meurt, d''autres personnes pourraient trouver un moyen magique de le ramener d''entre les morts, avec le sort rappel à la vie, par exemple. Vous pouvez également discuter avec le MJ de la possibilité de créer un nouveau personnage qui rejoindra le groupe. La section « Glossaire de règles » fournit plus de détails sur la mort.</p>

<p><strong>Perte de connaissance</strong></p>

<p>Si vous tombez à 0 point de vie sans mourir sur le coup, vous recevez l''état Inconscient (cf. « Glossaire de règles ») jusqu''à ce que vous regagniez au moins 1 point de vie, et vous êtes soumis aux jets de sauvegarde contre la mort (voir ci-après).</p>

<p><strong>Jets de sauvegarde contre la mort</strong></p>

<p>Chaque fois que vous commencez votre tour avec 0 point de vie, vous effectuez un JS spécial appelé jet de sauvegarde contre la mort, afin de déterminer si vous glissez vers le trépas ou si vous vous accrochez à la vie. Contrairement à d''autres jets de sauvegarde, celui-ci n''est lié à aucune valeur de caractéristique. Votre destin ne vous appartient plus.</p>

<p>Trois réussites/échecs. Lancez 1d20. Si le dé donne un résultat de 10 ou plus, c''est une réussite. Dans le cas contraire, c''est un échec. Cet échec ou cette réussite n''a pas d''effet en soi. À la troisième réussite, vous êtes Stabilisé (voir « Stabiliser un personnage », plus loin). Au troisième échec, vous mourez. Ces réussites et échecs n''ont pas besoin d''être consécutifs ; notez-les quelque part, jusqu''à ce que vous atteigniez un total de trois pour l''un ou l''autre. Ces compteurs sont remis à zéro pour les deux lorsque vous récupérez au moins un point de vie ou êtes Stabilisé. Résultat de 1 ou 20. Lorsque vous obtenez un 1 sur le d20 d''un jet de sauvegarde contre la mort, cela vaut deux échecs. Si vous obtenez un 20 sur le d20, en revanche, vous récupérez 1 point de vie. Dégâts subis à 0 point de vie. Si vous subissez des dégâts alors que vous êtes à 0 point de vie, vous subissez un échec de jet de sauvegarde contre la mort. Si ces dégâts correspondent à un Coup critique, vous subissez en fait deux échecs. Si les dégâts sont au moins égaux à votre maximum de points de vie, vous mourez.</p>

<h3>Stabiliser un personnage</h3>

<p>Vous pouvez entreprendre l''action Soutien pour tenter de stabiliser une créature à 0 point de vie, ce qui demande de réussir un test de Sagesse (Médecine) DD 10. Une créature Stabilisée n''est pas soumise aux jets de sauvegarde contre la mort, bien qu''étant à 0 point de vie, mais elle garde l''état Inconscient. Si elle subit le moindre dégât, elle n''est plus Stabilisée et se retrouve à nouveau soumise aux JS contre la mort. Une créature Stabilisée qui n''est pas soignée récupère 1 point de vie au bout de 1d4 heures.</p>

<h3>Points de vie temporaires</h3>

<p>Certains sorts et effets octroient des points de vie temporaires, sorte de matelas de sécurité contre la perte de véritables points de vie, comme détaillé ci-après.</p>

<p><strong>Priorité des points de vie temporaires</strong></p>

<p>Si vous disposez de points de vie temporaires et que vous subissez des dégâts, ce sont d''abord ces points qui sont perdus, tout excédent éventuel étant alors soustrait à vos véritables points de vie. Exemple : si vous disposez de 5 points de vie temporaires et subissez 7 dégâts, vous perdez vos points de vie temporaires, puis subissez 2 dégâts.</p>

<p>Durée Les points de vie temporaires persistent jusqu''à ce qu''ils soient dépensés ou que vous terminiez un Repos long (cf. « Glossaire de règles »).</p>

<p><strong>Non cumulables</strong></p>

<p>Les points de vie temporaires ne se cumulent pas. Si vous disposez de points de vie temporaires et que vous en recevez d''autres, c''est à vous de décider si vous gardez les vôtres ou si vous les remplacez par les nouveaux. Exemple : si un sort vous octroie 12 points de vie temporaires alors que vous en avez déjà 10, vous pouvez en avoir 12 ou 10, mais pas 22.</p>

<p><strong>Ni points de vie ni soins</strong></p>

<p>Les points de vie temporaires ne s''ajoutent pas à vos points de vie, les soins ne permettent pas de les récupérer, et leur acquisition n''est pas considérée comme une forme de guérison. Les points de vie temporaires n''étant pas des points de vie, une créature peut tout à fait être à son maximum de points de vie et recevoir des points de vie temporaires. Si vous êtes à 0 point de vie, l''acquisition de points de vie temporaires ne vous fait pas reprendre connaissance. Seule la guérison peut vous sauver.</p>',
       reg_date_modif = NOW()
WHERE  reg_slug = 'degats-et-soins'
  AND  reg_ruleset_var_id = @ddver;

COMMIT;

-- 10 sections importées