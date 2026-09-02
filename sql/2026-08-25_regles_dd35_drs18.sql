-- ============================================================
-- 2026-08-25_regles_dd35_drs18.sql — SP-DRS1 (lot 1)
-- Règles DD3.5 — DRS 18 : Pouvoirs spéciaux et états préjudiciables.
-- Rattachement : racine thématique « Créatures et pouvoirs spéciaux ».
-- Tableaux : dd_tableaux (convention texte, tag [[tab:slug]]) — SP-TB9.
-- Idempotent : réinitialise uniquement le sous-arbre du chapitre
-- « Pouvoirs spéciaux et états préjudiciables » et son tableau.
-- Pré-requis : 2026-08-25_regles_dd35_socle.sql.
-- ============================================================

SET NAMES utf8mb4;

SET @ddver := (SELECT var_id FROM dd_variables
               WHERE var_cat = 'ruleset' AND var_valeur = 'DD3.5' LIMIT 1);
SET @res   := (SELECT res_id FROM dd_ressources
               WHERE res_abreviation = 'DRS 3.5' AND res_ruleset_var_id = @ddver LIMIT 1);
SET @racine := (SELECT reg_id FROM dd_regles
                WHERE reg_slug = 'creatures-et-pouvoirs-speciaux' AND reg_ruleset_var_id = @ddver LIMIT 1);
SET @now := NOW();

START TRANSACTION;

-- ------------------------------------------------------------
-- Réinitialisation idempotente du sous-arbre DRS 18
-- ------------------------------------------------------------
SET @chap := (SELECT reg_id FROM dd_regles
              WHERE reg_slug = 'pouvoirs-speciaux-et-etats-prejudiciables' AND reg_ruleset_var_id = @ddver LIMIT 1);
DELETE FROM dd_regles WHERE @chap IS NOT NULL AND reg_reg_id = @chap;
DELETE FROM dd_regles WHERE @chap IS NOT NULL AND reg_id = @chap;
DELETE FROM dd_tableaux
WHERE  tab_ruleset_var_id = @ddver
  AND  tab_slug IN ('pouvoirs-ext-mag-sur');

-- ------------------------------------------------------------
-- Chapitre
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@racine, 'chapitre', 'Pouvoirs spéciaux et états préjudiciables', 'pouvoirs-speciaux-et-etats-prejudiciables',
        '<p>Les créatures et les personnages disposent de pouvoirs spéciaux — extraordinaires, magiques ou surnaturels — et subissent des états préjudiciables qui modifient leurs capacités. Ce chapitre détaille les uns et les autres.</p>',
        10, @ddver, @res, NULL, 1, @now, @now);
SET @chap := LAST_INSERT_ID();

-- ------------------------------------------------------------
-- Règle : Nature des pouvoirs spéciaux
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Nature des pouvoirs spéciaux', 'nature-des-pouvoirs-speciaux',
        '<ul><li><strong>Pouvoirs extraordinaires (Ext).</strong> Aptitudes non magiques, souvent hors de portée du commun des mortels. Ils ne sont pas affectés par tout ce qui neutralise la magie, et leur utilisation ne provoque pas d''attaque d''opportunité.</li><li><strong>Pouvoirs magiques (Mag).</strong> Fonctionnent comme des sorts (niveau de lanceur, cible, portée…), sans composante ni focalisateur. Ils sont soumis à la résistance à la magie et à la dissipation, ne fonctionnent pas dans une zone d''antimagie et leur utilisation provoque une attaque d''opportunité.</li><li><strong>Pouvoirs surnaturels (Sur).</strong> Aptitudes magiques qui ne sont pas des sorts : elles ne peuvent être ni dissipées ni contrées et ignorent la résistance à la magie, mais cessent de fonctionner dans une zone d''antimagie. Leur utilisation ne provoque pas d''attaque d''opportunité.</li></ul>
<p>[[tab:pouvoirs-ext-mag-sur]]</p>',
        10, @ddver, @res, NULL, 1, @now, @now);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note,
                         tab_ruleset_var_id, tab_res_id, tab_camp_id,
                         tab_ecran_mj, tab_ecran_ordre, tab_visible,
                         tab_date_creation, tab_date_modif)
VALUES ('pouvoirs-ext-mag-sur', 'Pouvoirs extraordinaires, magiques et surnaturels',
'! Propriété | Ext | Mag | Sur
Peut être dissipé | Non | Oui | Non
Soumis à la résistance à la magie | Non | Oui | Non
Fonctionne dans une zone d''antimagie | Oui | Non | Non
Son utilisation provoque une attaque d''opportunité | Non | Oui | Non
Peut être contré | Non | Oui | Non',
        'lccc', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now);

-- ------------------------------------------------------------
-- Règle : Pouvoirs spéciaux (détail alphabétique)
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Pouvoirs spéciaux', 'pouvoirs-speciaux',
        '<h3>Absorption d''énergie et niveaux négatifs</h3>
<p>Certaines attaques infligent des <strong>niveaux négatifs</strong>. Chaque niveau négatif impose : −1 à tous les tests de compétence et de caractéristique, aux jets d''attaque et de sauvegarde, −5 points de vie effectifs, −1 niveau effectif pour tous les calculs dépendant du niveau, et la perte d''un sort ou d''un emplacement du plus haut niveau accessible. Si les niveaux négatifs égalent les dés de vie, la créature meurt. Au bout de 24 heures, chaque niveau négatif exige un jet de Vigueur (DD fixé par l''attaque) : en cas d''échec, la perte de niveau devient réelle.</p>
<h3>Affaiblissement et diminution de caractéristique</h3>
<p>L''<strong>affaiblissement temporaire</strong> se récupère au rythme de 1 point par jour ; la <strong>diminution permanente</strong> exige une <em>restauration</em> ou mieux (voir <em>Les caractéristiques</em>).</p>
<h3>Arme de souffle (Sur)</h3>
<p>Attaque de zone (cône ou ligne) ne nécessitant ni jet d''attaque ni concentration ; jet de Réflexes (DD 10 + ½ DV + mod. de Con de la créature) pour demi-dégâts.</p>
<h3>Attaque de regard (Sur)</h3>
<p>Frappe toute créature à portée qui croise le regard du monstre : chaque adversaire risque l''effet à son propre tour (jet de sauvegarde à chaque round d''exposition). On peut détourner les yeux (50 % d''échapper à l''effet, mais l''adversaire gagne du camouflage) ou fermer les yeux / combattre de dos (immunité, mais l''adversaire bénéficie d''un camouflage total). La créature peut aussi utiliser activement son regard contre une cible (action libre limitée).</p>
<h3>Attaques mortelles</h3>
<p>Les effets de mort tuent instantanément (jet de sauvegarde pour y échapper). Le retour à la vie d''une victime d''effet de mort par <em>rappel à la vie</em> est impossible ; <em>résurrection</em> ou mieux est nécessaire. <em>Protection contre la mort</em> prémunit contre ces attaques.</p>
<h3>Charme et coercition</h3>
<p>Les effets de <strong>charme</strong> (<em>charme-personne</em>…) rendent la victime amicale envers le lanceur : elle n''obéit pas aveuglément et ne fait rien de suicidaire. Les effets de <strong>coercition</strong> (<em>domination</em>…) contrôlent réellement la victime. Ce sont des effets mentaux d''enchantement.</p>
<h3>Guérison accélérée (Ext)</h3>
<p>La créature récupère le nombre de points de vie indiqué à chaque round. Contrairement à la régénération, la guérison accélérée ne permet pas de faire repousser les membres perdus ni de survivre aux coups fatals.</p>
<h3>Intangibilité</h3>
<p>Une créature intangible ne peut être blessée que par d''autres créatures intangibles, les armes magiques, les sorts et effets magiques — et encore, toute attaque provenant d''une source tangible a 50 % de chances de la traverser sans effet (sauf effets de force, comme <em>projectile magique</em>). Elle traverse les objets solides, se déplace en silence et ses attaques ignorent l''armure naturelle, l''armure et le bouclier.</p>
<h3>Invisibilité</h3>
<p>Un attaquant invisible gagne +2 au jet d''attaque et prive sa cible de son bonus de Dextérité à la CA ; il bénéficie d''un camouflage total (50 % de chances d''être raté même si sa case est correctement devinée). Détecter un invisible : indices indirects (test de Détection DD 20 pour repérer sa présence, DD 40 pour situer sa case), <em>détection de l''invisibilité</em>, poudre, etc.</p>
<h3>Maladie (Ext)</h3>
<p>Contact, blessure ou inhalation ; jet de Vigueur pour y échapper. En cas d''échec, après la période d''incubation, la maladie inflige ses dégâts de caractéristique ; chaque jour, un nouveau jet de Vigueur (deux réussites consécutives = guérison). Le test de Premiers secours (DD 15) octroie un bonus.</p>
<h3>Métamorphose</h3>
<p>Le changement de forme (sorts de la famille de <em>métamorphose</em>, lycanthropes, métamorphes) suit les règles du sort concerné : la créature acquiert les caractéristiques physiques de la nouvelle forme et conserve ses caractéristiques mentales, son alignement et ses points de vie.</p>
<h3>Odorat (Ext)</h3>
<p>La créature détecte les adversaires à 9 m (18 m dans le sens du vent, 4,50 m contre le vent ; distances doublées pour les odeurs fortes). Elle peut localiser une source d''odeur adjacente et suivre une piste par un test de Sagesse (DD 10, modifié par l''ancienneté de la piste).</p>
<h3>Paralysie (Ext ou Sur)</h3>
<p>La victime paralysée est <strong>sans défense</strong> : incapable de bouger, d''agir physiquement ou de parler. La paralysie n''empêche pas les actions purement mentales. Plusieurs types de créatures (élémentaires, vases, plantes, vermines…) y sont immunisés — voir <em>Types et sous-types de créatures</em>.</p>
<h3>Peur</h3>
<p>Les effets de peur croissants : <strong>secoué</strong> (−2 aux jets d''attaque, de sauvegarde, tests de compétence et de caractéristique), <strong>effrayé</strong> (mêmes malus, la créature fuit la source de sa peur), <strong>paniqué</strong> (elle lâche ce qu''elle tient et fuit en aveugle). Les effets de peur se cumulent : un personnage secoué qui subit un nouvel effet de peur devient effrayé, puis paniqué.</p>
<h3>Poison (Ext)</h3>
<p>Blessure, contact, ingestion ou inhalation. Jet de Vigueur (DD fixé par le poison) contre les <strong>dégâts initiaux</strong>, puis une minute plus tard contre les <strong>dégâts secondaires</strong> (le plus souvent des dégâts de caractéristique). Manipuler un poison expose à un risque d''empoisonnement accidentel (5 %) ; <em>retard du poison</em> et <em>neutralisation du poison</em> y remédient.</p>
<h3>Réduction de dégâts (Ext ou Sur)</h3>
<p>Notée « RD valeur/contournement » (ex. RD 10/magie) : la créature ignore la valeur indiquée sur chaque attaque d''arme, sauf si l''arme correspond au contournement (arme magique, en argent, en fer froid, alignée, contondante… « — » signifiant qu''aucune arme ne la contourne). Les dégâts d''énergie, les sorts et les effets ignorent la RD.</p>
<h3>Régénération (Ext)</h3>
<p>Les dégâts infligés à la créature sont non létaux, qu''elle guérit au rythme indiqué. Seules certaines formes de dégâts (précisées par le monstre : feu et acide pour le troll…) lui infligent des dégâts létaux. Les membres tranchés repoussent ou peuvent être recollés.</p>
<h3>Résistance à la magie (Ext)</h3>
<p>Pour affecter la créature par un sort soumis à la résistance à la magie, le lanceur doit réussir un <strong>test de niveau de lanceur</strong> (1d20 + niveau de lanceur) contre la RM de la créature. La résistance à la magie n''a pas à être « activée » et la créature peut l''abaisser volontairement (action simple).</p>
<h3>Résistance aux énergies destructives (Ext)</h3>
<p>La créature ignore chaque round les premiers points de dégâts indiqués du type d''énergie concerné (feu, froid, acide, électricité, son).</p>
<h3>Résistance au renvoi (Ext)</h3>
<p>Un mort-vivant doté de cette résistance est traité comme s''il avait davantage de dés de vie face aux tentatives de renvoi (ex. +4 DV).</p>
<h3>Télépathie (Sur)</h3>
<p>La créature communique par la pensée avec toute créature à portée dotée d''un langage.</p>
<h3>Vision dans le noir (Ext)</h3>
<p>Vision en noir et blanc dans l''obscurité totale, jusqu''à la distance indiquée (18 m le plus souvent), sans aucune lumière.</p>
<h3>Vision nocturne (Ext)</h3>
<p>La créature voit deux fois (elfes) ou quatre fois plus loin qu''un humain en conditions de faible éclairage (lune, torche…), en conservant la vision des couleurs.</p>
<h3>Perception aveugle et vision aveugle (Ext)</h3>
<p>La <strong>vision aveugle</strong> permet de percevoir son environnement sans les yeux (écholocation, perception des vibrations) jusqu''à la portée indiquée ; la créature n''a pas besoin d''y voir. La <strong>perception aveugle</strong>, plus limitée, permet de situer les créatures sans les voir (pas besoin de deviner leur case, mais le camouflage total s''applique toujours au jet d''attaque).</p>',
        20, @ddver, @res, NULL, 1, @now, @now);

-- ------------------------------------------------------------
-- Règle : États préjudiciables (détail alphabétique)
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'États préjudiciables', 'etats-prejudiciables',
        '<p>Les états ci-dessous décrivent les situations handicapantes les plus courantes. Sauf indication contraire, leurs effets ne se cumulent pas avec eux-mêmes.</p>
<h3>À terre</h3>
<p>Le personnage subit −4 aux jets d''attaque au corps à corps et ne peut pas utiliser d''arme à distance (hors arbalète). Il gagne +4 à la CA contre les attaques à distance mais −4 contre le corps à corps. Se relever est une action de mouvement qui provoque une attaque d''opportunité.</p>
<h3>Assourdi</h3>
<p>−4 à l''initiative, échec automatique des tests de Perception auditive, et 20 % de risque d''échec pour les incantations à composante verbale.</p>
<h3>Aux abois</h3>
<p>Le personnage recroquevillé ne peut plus agir, perd son bonus de Dextérité à la CA et subit −2 à la CA.</p>
<h3>Aveuglé</h3>
<p>Le personnage subit −2 à la CA, perd son bonus de Dextérité à la CA, se déplace à demi-vitesse, subit −4 aux tests de Fouille et aux tests fondés sur la vue ; tous ses adversaires bénéficient d''un camouflage total (50 % de chances de les rater).</p>
<h3>Chancelant</h3>
<p>Une seule action simple <em>ou</em> de mouvement par round (dégâts non létaux égaux aux points de vie courants, ou 0 point de vie).</p>
<h3>Confus</h3>
<p>Le personnage agit au hasard chaque round (jet de dé : attaquer le plus proche, babiller, fuir, agir normalement…).</p>
<h3>Ébloui</h3>
<p>−1 aux jets d''attaque et aux tests de Détection et de Fouille.</p>
<h3>Effrayé</h3>
<p>Le personnage fuit la source de sa peur par tous les moyens ; s''il ne peut pas fuir, il peut se battre avec −2 aux jets d''attaque, de sauvegarde, tests de compétence et de caractéristique.</p>
<h3>Enchevêtré</h3>
<p>Déplacement à demi-vitesse, ni course ni charge, −2 aux jets d''attaque, −4 à la Dextérité effective ; incanter exige un test de Concentration (DD 15 + niveau du sort).</p>
<h3>Épuisé</h3>
<p>Déplacement à demi-vitesse, −6 effectifs en Force et en Dextérité. Après 1 heure de repos, l''épuisement devient fatigue.</p>
<h3>Étourdi (sonné)</h3>
<p>Le personnage lâche ce qu''il tient, ne peut plus agir, subit −2 à la CA et perd son bonus de Dextérité à la CA.</p>
<h3>Fasciné</h3>
<p>Le personnage contemple l''effet, incapable d''agir, −4 aux tests de perception ; toute menace évidente brise l''état.</p>
<h3>Fatigué</h3>
<p>Ni courir ni charger, −2 effectifs en Force et en Dextérité. 8 heures de repos dissipent la fatigue ; toute nouvelle cause de fatigue rend le personnage épuisé.</p>
<h3>Fiévreux</h3>
<p>−2 aux jets d''attaque, aux jets de dégâts des armes, aux jets de sauvegarde et aux tests de compétence et de caractéristique.</p>
<h3>Hébété</h3>
<p>Le personnage ne peut accomplir aucune action pendant 1 round, mais se défend normalement.</p>
<h3>Hors de combat</h3>
<p>À exactement 0 point de vie : une action simple ou de mouvement par round ; toute action fatigante coûte 1 point de vie.</p>
<h3>Immobilisé</h3>
<p>Maintenu au sol en lutte : sans défense face aux adversaires extérieurs, actions très limitées.</p>
<h3>Inconscient</h3>
<p>Le personnage est sans défense et ignore ce qui l''entoure (points de vie négatifs, dégâts non létaux dépassant les points de vie…).</p>
<h3>Invisible</h3>
<p>Visuellement indétectable : +2 aux jets d''attaque contre les adversaires voyants, qui perdent leur bonus de Dextérité à la CA (voir <em>Pouvoirs spéciaux — Invisibilité</em>).</p>
<h3>Mort</h3>
<p>À −10 points de vie, à Constitution 0, ou victime d''un effet de mort. L''âme quitte le corps ; seuls <em>rappel à la vie</em>, <em>résurrection</em> et assimilés y remédient.</p>
<h3>Mourant</h3>
<p>Entre −1 et −9 points de vie : inconscient, perd 1 point de vie par round, 10 % de chances par round de se stabiliser.</p>
<h3>Nauséeux</h3>
<p>Incapable d''attaquer, d''incanter, de se concentrer : une seule action de mouvement par round.</p>
<h3>Paniqué</h3>
<p>Le personnage lâche ce qu''il tient et fuit la source de sa peur au hasard, incapable d''autre chose que fuir ; acculé, il reste aux abois. −2 aux jets de sauvegarde, tests de compétence et de caractéristique.</p>
<h3>Paralysé</h3>
<p>Figé sur place, sans défense, incapable de bouger et d''agir (les actions purement mentales restent possibles). Force et Dextérité effectives de 0.</p>
<h3>Pétrifié</h3>
<p>Changé en pierre : inconscient, sans poids ni besoin vitaux. Si la statue est brisée, le retour à la chair laisse les blessures correspondantes.</p>
<h3>Pris au dépourvu</h3>
<p>Avant son premier tour de jeu : perte du bonus de Dextérité à la CA, aucune attaque d''opportunité possible.</p>
<h3>Repoussé</h3>
<p>Mort-vivant fuyant un renvoi : il fuit pendant 10 rounds par le chemin le plus direct ; acculé, il reste aux abois.</p>
<h3>Sans défense</h3>
<p>Paralysé, endormi, ligoté ou inconscient : Dextérité effective 0 (mod. −5), +4 au jet des attaques de corps à corps subies, cible possible d''un coup de grâce.</p>
<h3>Secoué</h3>
<p>−2 aux jets d''attaque, de sauvegarde, tests de compétence et de caractéristique. Premier degré des effets de peur (puis effrayé, puis paniqué).</p>
<h3>Stabilisé</h3>
<p>Points de vie négatifs mais hémorragie stoppée : inconscient, il ne perd plus de points de vie ; sans soins, son état reste précaire.</p>
<h3>Vidé de son énergie</h3>
<p>Sous le coup de niveaux négatifs (voir <em>Pouvoirs spéciaux — Absorption d''énergie</em>).</p>',
        30, @ddver, @res, NULL, 1, @now, @now);

COMMIT;
