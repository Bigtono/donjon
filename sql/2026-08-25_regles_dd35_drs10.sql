-- ============================================================
-- 2026-08-25_regles_dd35_drs10.sql — SP-DRS1 (lot 1)
-- Règles DD3.5 — DRS 10 : Le combat.
-- Rattachement : les règles sont les enfants directs de la racine
-- thématique « Le combat » (le thème et le fichier DRS coïncident).
-- Tableaux : dd_tableaux (convention texte, tag [[tab:slug]]) — SP-TB9.
-- Idempotent : réinitialise uniquement les enfants de « Le combat »
-- et les tableaux du fichier.
-- Pré-requis : 2026-08-25_regles_dd35_socle.sql.
-- ============================================================

SET NAMES utf8mb4;

SET @ddver := (SELECT var_id FROM dd_variables
               WHERE var_cat = 'ruleset' AND var_valeur = 'DD3.5' LIMIT 1);
SET @res   := (SELECT res_id FROM dd_ressources
               WHERE res_abreviation = 'DRS 3.5' AND res_ruleset_var_id = @ddver LIMIT 1);
SET @chap  := (SELECT reg_id FROM dd_regles
               WHERE reg_slug = 'le-combat' AND reg_ruleset_var_id = @ddver LIMIT 1);
SET @now := NOW();

START TRANSACTION;

-- ------------------------------------------------------------
-- Réinitialisation idempotente
-- ------------------------------------------------------------
DELETE FROM dd_regles WHERE @chap IS NOT NULL AND reg_reg_id = @chap;
DELETE FROM dd_tableaux
WHERE  tab_ruleset_var_id = @ddver
  AND  tab_slug IN ('actions-au-combat', 'modificateurs-du-jet-d-attaque',
                    'modificateurs-de-ca', 'combat-a-deux-armes');

-- ------------------------------------------------------------
-- Règle : Le déroulement du combat
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Le déroulement du combat', 'deroulement-du-combat',
        '<p>Le combat se déroule en <strong>rounds</strong> de 6 secondes. À chaque round, chaque combattant agit à son tour, dans l''ordre décroissant d''initiative. Le déroulement type est le suivant :</p>
<ol><li>Chaque combattant débute la bataille <strong>pris au dépourvu</strong>. Dès qu''il a agi une première fois, il ne l''est plus.</li><li>Le MJ détermine quels combattants sont conscients de leurs adversaires. S''il y en a qui ne le sont pas, un <strong>round de surprise</strong> a lieu : seuls les combattants conscients agissent, et uniquement par une action simple.</li><li>Les combattants qui n''ont pas encore joué font leur <strong>test d''initiative</strong>. Tous agissent ensuite dans l''ordre décroissant.</li><li>Une fois que tout le monde a joué son tour, le round s''achève et le combattant à la plus haute initiative entame le round suivant.</li></ol>
<h3>L''initiative</h3>
<p>Le test d''initiative est un test de Dextérité (1d20 + modificateur de Dextérité + modificateurs divers, dont le don Science de l''initiative). Il se fait une seule fois par combat : l''ordre obtenu reste le même de round en round. En cas d''égalité, la créature au plus haut modificateur agit la première ; si l''égalité persiste, on la départage au dé.</p>
<p>Un personnage <strong>pris au dépourvu</strong> (avant son premier tour de jeu) perd son bonus de Dextérité à la CA et ne peut pas effectuer d''attaque d''opportunité.</p>',
        10, @ddver, @res, NULL, 1, @now, @now);

-- ------------------------------------------------------------
-- Règle : Statistiques de combat
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Statistiques de combat', 'statistiques-de-combat',
        '<h3>Le jet d''attaque</h3>
<p>Un jet d''attaque se fait sous la forme 1d20 + bonus d''attaque. Si le résultat égale ou dépasse la classe d''armure (CA) de la cible, l''attaque touche et inflige des dégâts. Un <strong>1 naturel</strong> rate toujours ; un <strong>20 naturel</strong> touche toujours et constitue une <strong>menace de critique</strong>.</p>
<ul><li><strong>Corps à corps</strong> : bonus d''attaque = bonus de base à l''attaque (BBA) + modificateur de Force + modificateur de taille.</li><li><strong>À distance</strong> : bonus d''attaque = BBA + modificateur de Dextérité + modificateur de taille + malus de portée (−2 par facteur de portée au-delà du premier).</li></ul>
<h3>Les dégâts</h3>
<p>Les dégâts se déduisent des points de vie de la cible. Le modificateur de Force s''applique aux dégâts des armes de corps à corps et des armes de jet : une fois et demie pour une arme tenue à deux mains, la moitié pour une arme tenue de la main secondaire. Les dégâts minimaux d''un coup qui touche sont de 1 point.</p>
<p><strong>Coups critiques.</strong> Sur une menace de critique (20 naturel, ou le résultat indiqué par la zone de critique de l''arme, ex. 19–20), on rejoue le jet d''attaque : s''il toucherait de nouveau, le coup est critique et les dégâts sont multipliés (×2, ×3 ou ×4 selon l''arme). Les dégâts d''énergie et les dés bonus (attaque sournoise…) ne sont pas multipliés.</p>
<h3>La classe d''armure (CA)</h3>
<p>CA = 10 + bonus d''armure + bonus de bouclier + modificateur de Dextérité + modificateur de taille + bonus divers (parade, esquive, armure naturelle…).</p>
<ul><li><strong>Pris au dépourvu</strong> : le personnage perd son bonus de Dextérité à la CA (et ses bonus d''esquive).</li><li><strong>Attaque de contact</strong> : la CA de contact ignore l''armure, le bouclier et l''armure naturelle ; ne restent que la taille, la Dextérité et les bonus de parade ou d''esquive.</li></ul>
<h3>Les points de vie</h3>
<p>Les points de vie (pv) mesurent la capacité à encaisser. Quand ils tombent à 0 le personnage est hors de combat, en dessous de 0 il est mourant, à −10 il est mort (voir <em>Blessures et mort</em>).</p>
<h3>La vitesse de déplacement</h3>
<p>La vitesse indique la distance parcourue par une action de mouvement (9 m pour un humain sans armure, 6 m en armure intermédiaire ou lourde). On peut se déplacer au double par la combinaison de deux actions de mouvement, ou au quadruple en courant (action complexe).</p>
<h3>Les jets de sauvegarde</h3>
<p>Un jet de sauvegarde (1d20 + bonus de base + modificateur de caractéristique) permet d''éviter ou de réduire un effet. <strong>Réflexes</strong> (Dex) contre les effets de zone, <strong>Vigueur</strong> (Con) contre les agressions physiques (poison, maladie…), <strong>Volonté</strong> (Sag) contre les effets mentaux. Le DD dépend de la source de l''effet. Un 1 naturel échoue toujours, un 20 naturel réussit toujours.</p>',
        20, @ddver, @res, NULL, 1, @now, @now);

-- ------------------------------------------------------------
-- Règle : Les actions au combat
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Les actions au combat', 'les-actions-au-combat',
        '<p>À son tour de jeu, un personnage peut accomplir une <strong>action simple</strong> et une <strong>action de mouvement</strong> (dans l''ordre de son choix), deux actions de mouvement, ou une <strong>action complexe</strong>. Les <strong>actions libres</strong> se combinent librement au reste, dans les limites fixées par le MJ.</p>
<ul><li><strong>Action simple.</strong> Attaquer une fois, lancer un sort à l''incantation d''une action, boire une potion, utiliser un objet magique…</li><li><strong>Action de mouvement.</strong> Se déplacer jusqu''à sa vitesse, dégainer une arme, se relever, ouvrir une porte, recharger une arbalète légère…</li><li><strong>Action complexe.</strong> Attaque à outrance (utiliser toutes ses attaques), charge (cas particulier : elle reste possible en round de surprise sous forme d''action simple), course, retraite, sorts à incantation longue… Une action complexe autorise tout de même un pas de placement de 1,50 m.</li><li><strong>Action libre.</strong> Parler, lâcher un objet, se laisser tomber à terre, annuler la concentration sur un sort…</li><li><strong>Pas de placement (1,50 m).</strong> Une fois par round, un déplacement de 1,50 m qui ne provoque jamais d''attaque d''opportunité ; impossible dans le même round qu''un autre déplacement.</li></ul>
<p>[[tab:actions-au-combat]]</p>',
        30, @ddver, @res, NULL, 1, @now, @now);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note,
                         tab_ruleset_var_id, tab_res_id, tab_camp_id,
                         tab_ecran_mj, tab_ecran_ordre, tab_visible,
                         tab_date_creation, tab_date_modif)
VALUES ('actions-au-combat', 'Actions au combat',
'! Action | Attaque d''opportunité ?
# Actions simples
Attaquer (corps à corps) | Non
Attaquer (à distance) | Oui
Attaquer (à mains nues) | Oui
Aider quelqu''un | Peut-être¹
Boire une potion ou appliquer une huile | Oui
Dégainer une arme cachée (Escamotage) | Non
Feinter | Non
Lancer un sort (incantation d''une action simple) | Oui
Préparer une action (déclenche une action simple) | Non
Rengainer une arme | Oui
Stabiliser un mourant (Premiers secours) | Oui
Utiliser un objet magique (hors potion) | Non
Utiliser un pouvoir extraordinaire | Non
Utiliser un pouvoir magique | Oui
Utiliser un pouvoir surnaturel | Non
# Actions de mouvement
Se déplacer (jusqu''à sa vitesse) | Oui²
Dégainer une arme | Non
Ramasser un objet | Oui
Recharger une arbalète de poing ou légère | Oui
Récupérer un objet rangé | Oui
Se relever (depuis à terre) | Oui
Monter en selle ou mettre pied à terre | Non
Ouvrir ou fermer une porte | Non
Diriger un sort actif | Non
# Actions complexes
Attaque à outrance | Non
Charger³ | Non
Courir (×4) | Oui
Battre en retraite | Non
Lancer un sort (incantation d''un round complet) | Oui
Recharger une arbalète lourde ou une arme à répétition | Oui
Asséner le coup de grâce | Oui
Éteindre les flammes qui vous consument | Non
Se libérer d''un filet ou d''une entrave | Oui
# Actions libres
Parler | Non
Lâcher un objet ou se jeter à terre | Non
Cesser de se concentrer sur un sort | Non
Incanter un sort rapide | Non
> 1. Selon la manière d''aider. — 2. Quitter une case contrôlée provoque une attaque d''opportunité ; le pas de placement de 1,50 m, jamais. — 3. La charge devient une action simple quand on ne dispose que d''une action simple (round de surprise).',
        'lc', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now);

-- ------------------------------------------------------------
-- Règle : Blessures et mort
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Blessures et mort', 'blessures-et-mort',
        '<p>L''état d''un personnage dépend de ses points de vie restants :</p>
<ul><li><strong>1 pv ou plus</strong> : le personnage agit normalement.</li><li><strong>0 pv — hors de combat.</strong> Le personnage est chancelant : une seule action simple <em>ou</em> de mouvement par round. Toute action fatigante (attaquer, lancer un sort…) lui fait perdre 1 pv après résolution.</li><li><strong>−1 à −9 pv — mourant.</strong> Le personnage tombe inconscient et perd 1 pv par round. Chaque round, il a 10 % de chances de se <strong>stabiliser</strong> ; on peut aussi le stabiliser par un test de Premiers secours (DD 15) ou le moindre soin magique.</li><li><strong>−10 pv — mort.</strong></li></ul>
<h3>Guérison</h3>
<p><strong>Guérison naturelle :</strong> une nuit de repos rend 1 pv par niveau de personnage ; un jour entier de repos complet en rend le double. <strong>Guérison magique :</strong> les sorts de soins et pouvoirs assimilés rendent immédiatement les points de vie indiqués. La guérison ne peut jamais porter au-delà du total maximal.</p>
<h3>Dégâts non létaux</h3>
<p>Les dégâts non létaux (coups assommants, fatigue, chaleur…) se comptabilisent à part. Quand leur total atteint les points de vie courants, le personnage est <strong>chancelant</strong> ; quand il les dépasse, il tombe <strong>inconscient</strong>. Ils disparaissent au rythme de 1 point par heure et par niveau. Attaquer pour infliger des dégâts non létaux avec une arme létale (ou l''inverse) impose un malus de −4 au jet d''attaque.</p>
<h3>Caractéristiques et niveaux perdus</h3>
<p>L''affaiblissement de caractéristique et les niveaux négatifs relèvent des pouvoirs spéciaux (voir le chapitre <em>Créatures et pouvoirs spéciaux</em>).</p>',
        40, @ddver, @res, NULL, 1, @now, @now);

-- ------------------------------------------------------------
-- Règle : Déplacement, position et distance
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Déplacement, position et distance', 'deplacement-position-et-distance',
        '<p>Sur un quadrillage tactique, une case représente 1,50 m de côté. Une créature de taille M ou inférieure occupe une case ; les créatures plus grandes occupent plusieurs cases (2×2 pour la taille G, etc.).</p>
<ul><li><strong>Diagonales.</strong> La première diagonale compte 1 case, la deuxième 2, puis on alterne (1,50 m — 3 m — 1,50 m…). On ne peut pas couper un angle de mur en diagonale.</li><li><strong>Terrain difficile.</strong> Chaque case de terrain difficile compte double.</li><li><strong>Traverser une case occupée.</strong> On traverse librement la case d''un allié (sans s''y arrêter). On ne traverse pas la case d''un ennemi, sauf s''il est sans défense, ou par une manœuvre de renversement ou un test d''Acrobaties. Une créature dont la taille diffère d''au moins trois catégories peut être traversée.</li><li><strong>Espace et allonge.</strong> Une créature de taille M ou P a une allonge de 1,50 m : elle contrôle les cases adjacentes. Les grandes créatures ont une allonge supérieure (3 m pour la taille G de gabarit haut, etc.). Les armes à allonge (coutille…) doublent l''allonge mais ne menacent pas les cases adjacentes.</li></ul>',
        50, @ddver, @res, NULL, 1, @now, @now);

-- ------------------------------------------------------------
-- Règle : Attaques d'opportunité
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Attaques d''opportunité', 'attaques-d-opportunite',
        '<p>Chaque combattant <strong>contrôle</strong> les cases situées dans son allonge (sa <em>zone contrôlée</em>). Deux types d''actions accomplies dans une case contrôlée provoquent une <strong>attaque d''opportunité</strong> :</p>
<ul><li><strong>Se déplacer</strong> : quitter une case contrôlée provoque une attaque d''opportunité de l''ennemi qui la contrôle. Exceptions : le pas de placement de 1,50 m et la retraite (pour la case de départ).</li><li><strong>Accomplir une action qui déconcentre</strong> : lancer un sort, attaquer à distance, boire une potion, ramasser un objet… (voir la colonne dédiée du tableau des actions).</li></ul>
<p>L''attaque d''opportunité est une unique attaque de corps à corps au bonus d''attaque maximal, résolue immédiatement, avant l''action qui l''a provoquée. Chaque combattant ne peut en effectuer qu''<strong>une seule par round</strong> (le don Attaques réflexes en autorise plusieurs). Une créature ne provoque qu''une attaque d''opportunité par occasion, même si elle traverse plusieurs cases contrôlées du même adversaire.</p>
<p><strong>Lancer un sort sur la défensive</strong> (test de Concentration DD 15 + niveau du sort) permet d''éviter l''attaque d''opportunité ; en cas d''échec, le sort est perdu.</p>',
        60, @ddver, @res, NULL, 1, @now, @now);

-- ------------------------------------------------------------
-- Règle : Modificateurs de combat
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Modificateurs de combat', 'modificateurs-de-combat',
        '<p>La situation tactique modifie les jets d''attaque et la CA.</p>
<p>[[tab:modificateurs-du-jet-d-attaque]]</p>
<p>[[tab:modificateurs-de-ca]]</p>
<h3>Abri</h3>
<p>Une cible derrière un abri (muret, angle de mur, meurtrière…) gagne un <strong>bonus de +4 à la CA</strong> et un <strong>bonus de +2 aux jets de Réflexes</strong> contre les effets dont l''origine se situe de l''autre côté de l''abri. Un abri total interdit de prendre la cible pour cible. L''abri permet aussi le test de Discrétion.</p>
<h3>Camouflage</h3>
<p>Le camouflage (pénombre, brouillard, feuillage…) impose <strong>20 % de chances de rater</strong> toute attaque portée contre la cible. Le camouflage total (obscurité totale, invisibilité) porte ces chances à <strong>50 %</strong> et interdit de cibler la créature autrement qu''en visant sa case. Le camouflage permet le test de Discrétion.</p>
<h3>Prise en tenaille</h3>
<p>Deux adversaires qui menacent une même créature depuis des côtés opposés la prennent en tenaille : chacun gagne <strong>+2 au jet d''attaque</strong> au corps à corps (et le roublard peut placer son attaque sournoise).</p>
<h3>Aider quelqu''un</h3>
<p>Par une action simple, on peut faire un jet d''attaque contre une CA de 10 : en cas de réussite, un allié gagne au choix +2 à son prochain jet d''attaque contre cet adversaire ou +2 à la CA contre sa prochaine attaque.</p>
<h3>Combattre sur la défensive et parade totale</h3>
<p>Combattre sur la défensive : −4 aux jets d''attaque du round, +2 à la CA (esquive). Parade totale (action simple) : +4 à la CA (esquive), aucune attaque.</p>
<h3>Adversaire sans défense</h3>
<p>Un adversaire sans défense (endormi, paralysé, ligoté…) a une Dextérité effective de 0 (mod. −5) et subit +4 de bonus au jet des attaques de corps à corps portées contre lui. Il peut être victime du <strong>coup de grâce</strong> (action complexe) : le coup touche automatiquement, est critique, et la victime qui survit doit réussir un jet de Vigueur (DD 10 + dégâts) pour ne pas mourir.</p>',
        70, @ddver, @res, NULL, 1, @now, @now);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note,
                         tab_ruleset_var_id, tab_res_id, tab_camp_id,
                         tab_ecran_mj, tab_ecran_ordre, tab_visible,
                         tab_date_creation, tab_date_modif)
VALUES ('modificateurs-du-jet-d-attaque', 'Modificateurs du jet d''attaque',
'! L''attaquant est… | Corps à corps | À distance
En hauteur par rapport à la cible | +1 | +0
Invisible | +2¹ | +2¹
À terre | −4 | Impossible²
Aveuglé | −2¹ | −2¹
Enchevêtré | −2³ | −2³
Pris en tenaille avec un allié | +2 | —
Serré de près (au corps à corps) | — | −4⁴
Monté sur une créature (cible à pied) | +1 | —
> 1. La cible perd en outre son bonus de Dextérité à la CA (attaquant invisible) ; l''attaquant aveuglé subit les 50 % de chances de rater du camouflage total. — 2. Sauf avec une arbalète ou une arme de poing. — 3. Et la Dextérité de l''attaquant est limitée. — 4. Tirer sur une cible en mêlée : −4, annulé par le don Tir de précision.',
        'lcc', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note,
                         tab_ruleset_var_id, tab_res_id, tab_camp_id,
                         tab_ecran_mj, tab_ecran_ordre, tab_visible,
                         tab_date_creation, tab_date_modif)
VALUES ('modificateurs-de-ca', 'Modificateurs de la classe d''armure',
'! Le défenseur est… | Corps à corps | À distance
Derrière un abri | +4 | +4
Agenouillé ou assis | −2 | +2
À terre | −4 | +4
Pris au dépourvu | Pas de bonus de Dex | Pas de bonus de Dex
Sans défense | −4¹ | +0¹
Agrippé (en lutte) | +0² | +0²
Aveuglé | −2¹ | −2¹
Escaladant un mur | −2¹ | −2¹
Courant | — | −2
> 1. Et perte du bonus de Dextérité à la CA. — 2. Le défenseur en lutte perd son bonus de Dextérité contre les adversaires extérieurs à la lutte.',
        'lcc', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now);

-- ------------------------------------------------------------
-- Règle : Attaques spéciales
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Attaques spéciales', 'attaques-speciales',
        '<h3>Bousculade</h3>
<p>Pousser un adversaire (action simple, ou partie d''une charge). L''entrée dans sa case provoque une attaque d''opportunité de sa part. Test de Force opposé (+4 par catégorie de taille au-dessus de M, +2 en charge, −4 par catégorie en dessous de M). En cas de réussite, l''adversaire recule de 1,50 m, plus 1,50 m par tranche de 5 points d''écart si on le suit.</p>
<h3>Charge</h3>
<p>Action complexe : se déplacer d''au moins 3 m (jusqu''au double de sa vitesse) <strong>en ligne droite dégagée</strong>, puis porter une unique attaque avec <strong>+2 au jet d''attaque</strong> ; le chargeur subit <strong>−2 à la CA</strong> jusqu''à son prochain tour. Une lance d''arçon inflige des dégâts doublés en charge montée ; une arme préparée contre une charge (fauchard…) inflige des dégâts doublés au chargeur.</p>
<h3>Combat à deux armes</h3>
<p>Combattre avec une arme dans chaque main donne une attaque supplémentaire avec l''arme secondaire, au prix de malus aux jets d''attaque, réduits si l''arme secondaire est légère et par le don Combat à deux armes.</p>
<p>[[tab:combat-a-deux-armes]]</p>
<h3>Combat monté</h3>
<p>La monture agit à l''initiative du cavalier. Diriger une monture de guerre est libre ; une monture ordinaire au combat exige un test d''Équitation (action de mouvement). Le cavalier gagne +1 au corps à corps contre les adversaires à pied. Attaquer à distance depuis une monture en mouvement impose −4 (−8 au galop, sauf tir monté).</p>
<h3>Croc-en-jambe</h3>
<p>Attaque de contact au corps à corps (elle provoque une attaque d''opportunité), puis test opposé de Force contre Force ou Dextérité (au choix du défenseur), modifié par la taille et la stabilité. En cas de réussite, l''adversaire tombe à terre ; en cas d''échec, il peut immédiatement tenter de vous faire tomber à son tour. Certaines armes (fléau, chaîne cloutée…) permettent le croc-en-jambe sans risque.</p>
<h3>Désarmement</h3>
<p>Provoque une attaque d''opportunité. Jets d''attaque opposés (+4 par catégorie de taille d''écart, +4 pour une arme à deux mains, −4 pour une arme légère, +4 pour le défenseur si l''objet visé n''est pas une arme tenue). En cas de réussite, l''arme du défenseur tombe à terre ; en cas d''échec, le défenseur peut tenter de vous désarmer en retour. Le don Science du désarmement supprime l''attaque d''opportunité.</p>
<h3>Destruction d''objet</h3>
<p>Frapper une arme ou un bouclier tenu : jets d''attaque opposés (mêmes modificateurs que le désarmement) ; frapper un objet porté : jet d''attaque contre la CA de l''objet. L''objet a une solidité (les points de dégâts inférieurs sont ignorés) et des points de résistance. Cette manœuvre provoque une attaque d''opportunité.</p>
<h3>Feinte</h3>
<p>Action simple : test de Bluff opposé à Psychologie (+ BBA) de l''adversaire. En cas de réussite, la prochaine attaque de corps à corps contre lui (au plus tard au round suivant) le prive de son bonus de Dextérité à la CA. Feinter contre une créature non humanoïde : −4 ; contre une Intelligence animale (1–2) : −8.</p>
<h3>Lutte</h3>
<p><strong>Engager la lutte :</strong> attaque de contact au corps à corps (provoque une attaque d''opportunité ; si elle inflige des dégâts, la lutte échoue), puis test de lutte opposé (BBA + modificateur de Force + modificateur spécial de taille : +4 par catégorie au-dessus de M, −4 par catégorie en dessous). En cas de réussite, les deux adversaires sont agrippés.</p>
<p><strong>En lutte</strong>, par une action d''attaque (test de lutte opposé) on peut : infliger des dégâts à mains nues, s''échapper (Évasion possible à la place), se déplacer en entraînant l''adversaire (moitié de la vitesse), récupérer ou dégainer une arme légère, attaquer avec une arme légère (−4), ou immobiliser l''adversaire pour 1 round (il est alors quasiment sans défense). Les lutteurs perdent leur bonus de Dextérité à la CA contre les adversaires extérieurs, ne contrôlent plus aucune case et ne peuvent lancer que des sorts sans composante somatique ni focalisateur en main (test de Concentration DD 20 + niveau du sort).</p>
<h3>Renversement</h3>
<p>Pendant un déplacement (ou une charge), traverser la case d''un adversaire d''une taille au plus égale à la sienne + une catégorie. L''adversaire peut laisser passer ou bloquer ; s''il bloque, test opposé de Force (modificateurs de taille et de stabilité) : en cas de réussite il est renversé à terre, sinon le renverseur s''arrête ou tombe selon le résultat.</p>
<h3>Armes à aspersion</h3>
<p>Une arme à aspersion (feu grégeois, acide…) se lance par une attaque de contact à distance contre la cible ou une intersection du quadrillage (CA 5). La cible directe subit les dégâts pleins ; toutes les créatures à 1,50 m subissent 1 point de dégâts d''éclaboussure.</p>',
        80, @ddver, @res, NULL, 1, @now, @now);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note,
                         tab_ruleset_var_id, tab_res_id, tab_camp_id,
                         tab_ecran_mj, tab_ecran_ordre, tab_visible,
                         tab_date_creation, tab_date_modif)
VALUES ('combat-a-deux-armes', 'Combat à deux armes — malus aux jets d''attaque',
'! Circonstances | Main directrice | Main secondaire
Malus de base | −6 | −10
L''arme secondaire est légère | −4 | −8
Don Combat à deux armes | −4 | −4
Arme secondaire légère + don Combat à deux armes | −2 | −2
> Une double arme (bâton, double lame…) suit les règles du combat à deux armes, sa seconde extrémité comptant comme une arme légère.',
        'lcc', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now);

-- ------------------------------------------------------------
-- Règle : Actions spéciales d'initiative
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Actions spéciales d''initiative', 'actions-speciales-d-initiative',
        '<h3>Retarder son action</h3>
<p>Le personnage n''agit pas à son tour et choisit d''agir plus tard dans le round, à une initiative inférieure de son choix. Sa nouvelle initiative devient la sienne pour la suite du combat. Retarder ne permet jamais d''interrompre l''action d''un autre.</p>
<h3>Préparer une action</h3>
<p>Action simple : le personnage déclare une action simple, de mouvement ou libre et la condition qui la déclenchera (« je tire sur le premier orque qui franchit la porte »). Quand la condition survient, l''action préparée se résout <strong>avant</strong> l''action qui l''a déclenchée, et l''initiative du personnage est redéfinie juste avant celle du déclencheur. Usage classique : <strong>contrer un sort</strong> (identifier le sort par Art de la magie DD 15 + niveau, puis le contrer par le même sort ou son opposé, ou par <em>dissipation de la magie</em>), ou <strong>préparer une arme contre une charge</strong> (dégâts doublés contre le chargeur).</p>',
        90, @ddver, @res, NULL, 1, @now, @now);

COMMIT;
