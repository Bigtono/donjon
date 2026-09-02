-- ============================================================
-- 2026-08-25_regles_dd35_glossaire_lot1.sql — SP-DRS1 (lot 1) / SP-GL4
-- Mini-glossaire DD3.5 — termes techniques majeurs compilés lors
-- du traitement du lot 1 (DRS 01, 10, 12, 18, 19) :
--   actions, termes de combat, attaques spéciales, états
--   préjudiciables, pouvoirs spéciaux, caractéristiques.
-- Arbitrage 2026-08-25 (Q3) : les règles complètes restent dans
-- leurs chapitres ; le glossaire ne contient que des définitions
-- courtes (cibles de renvoi pour la liaison automatique SP-GL).
-- Idempotent : réinitialise uniquement les termes de CE lot (par
-- liste de slugs) — les lots suivants ajouteront leurs termes sans
-- toucher à ceux-ci.
-- Pré-requis : 2026-08-25_regles_dd35_socle.sql.
-- ============================================================

SET NAMES utf8mb4;

SET @ddver := (SELECT var_id FROM dd_variables
               WHERE var_cat = 'ruleset' AND var_valeur = 'DD3.5' LIMIT 1);
SET @res   := (SELECT res_id FROM dd_ressources
               WHERE res_abreviation = 'DRS 3.5' AND res_ruleset_var_id = @ddver LIMIT 1);
SET @glo   := (SELECT reg_id FROM dd_regles
               WHERE reg_slug = 'glossaire' AND reg_ruleset_var_id = @ddver LIMIT 1);
SET @now := NOW();

START TRANSACTION;

-- ------------------------------------------------------------
-- Réinitialisation idempotente — uniquement les termes du lot 1
-- ------------------------------------------------------------
DELETE FROM dd_regles
WHERE  reg_ruleset_var_id = @ddver
  AND  reg_type = 'glossaire'
  AND  reg_reg_id = @glo
  AND  reg_slug IN (
    'a-terre','abri','action-complexe','action-de-mouvement','action-libre','action-simple',
    'affaiblissement-de-caracteristique','assourdi','attaque-a-outrance','attaque-d-opportunite',
    'attaque-de-contact','aveugle','bonus-de-base-a-l-attaque','bousculade','camouflage',
    'chancelant','charge','classe-d-armure','coup-critique','coup-de-grace','croc-en-jambe',
    'degats-non-letaux','desarmement','diminution-permanente-de-caracteristique','ebloui',
    'effraye','enchevetre','epuise','etourdi','fascine','fatigue','feinte','fievreux',
    'guerison-acceleree','hebete','inconscient','initiative','jet-d-attaque','jet-de-sauvegarde',
    'lutte','modificateur-de-caracteristique','mourant','nauseeux','niveau-negatif','panique',
    'paralyse','pas-de-placement','petrifie','pouvoir-extraordinaire','pouvoir-magique',
    'pouvoir-surnaturel','pris-au-depourvu','prise-en-tenaille','reduction-de-degats',
    'regeneration','renversement','resistance-a-la-magie','round','sans-defense','secoue',
    'vision-dans-le-noir','vision-nocturne','zone-controlee');

-- ------------------------------------------------------------
-- Termes (ordre alphabétique)
-- ------------------------------------------------------------
INSERT INTO dd_regles
  (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
   reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES
(@glo, 'glossaire', 'À terre', 'a-terre', '<p>Le personnage à terre subit −4 aux jets d''attaque au corps à corps, −4 à la CA contre le corps à corps mais +4 contre les attaques à distance. Se relever est une action de mouvement qui provoque une <a class="glossaire-lien" data-glossaire-slug="attaque-d-opportunite">attaque d''opportunité</a>.</p>', 10, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Abri', 'abri', '<p>Une cible derrière un abri gagne +4 à la CA et +2 aux jets de Réflexes contre les effets venant de l''autre côté. Un abri total interdit de la prendre pour cible.</p>', 20, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Action complexe', 'action-complexe', '<p>Action occupant tout le round (attaque à outrance, charge, course…). Elle laisse tout de même la possibilité d''un <a class="glossaire-lien" data-glossaire-slug="pas-de-placement">pas de placement</a> de 1,50 m.</p>', 30, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Action de mouvement', 'action-de-mouvement', '<p>Action permettant de se déplacer jusqu''à sa vitesse ou d''accomplir une tâche équivalente (dégainer, se relever, ouvrir une porte…).</p>', 40, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Action libre', 'action-libre', '<p>Action quasi instantanée (parler, lâcher un objet…) : on peut en accomplir plusieurs par round, dans les limites fixées par le MJ.</p>', 50, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Action simple', 'action-simple', '<p>L''action principale du tour de jeu : attaquer une fois, lancer la plupart des sorts, boire une potion… Elle se combine avec une <a class="glossaire-lien" data-glossaire-slug="action-de-mouvement">action de mouvement</a>.</p>', 60, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Affaiblissement de caractéristique', 'affaiblissement-de-caracteristique', '<p>Perte temporaire de points de caractéristique (poison, sort…). Récupération naturelle : 1 point par jour et par caractéristique.</p>', 70, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Assourdi', 'assourdi', '<p>−4 à l''initiative, échec automatique des tests de Perception auditive, 20 % de risque d''échec des sorts à composante verbale.</p>', 80, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Attaque à outrance', 'attaque-a-outrance', '<p>Action complexe : utiliser toutes les attaques que confère un bonus de base à l''attaque élevé (une attaque supplémentaire par tranche de +5 de BBA, à bonus décroissant : +11/+6/+1…).</p>', 90, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Attaque d''opportunité', 'attaque-d-opportunite', '<p>Attaque de corps à corps gratuite (une par round) contre un adversaire qui quitte une case contrôlée ou accomplit une action déconcentrante dans la <a class="glossaire-lien" data-glossaire-slug="zone-controlee">zone contrôlée</a>.</p>', 100, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Attaque de contact', 'attaque-de-contact', '<p>Jet d''attaque contre la CA de contact, qui ignore l''armure, le bouclier et l''armure naturelle (il suffit de toucher la cible, pas de percer sa protection).</p>', 110, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Aveuglé', 'aveugle', '<p>−2 à la CA, perte du bonus de Dextérité à la CA, demi-vitesse ; tous les adversaires bénéficient d''un <a class="glossaire-lien" data-glossaire-slug="camouflage">camouflage</a> total (50 % de chances de les rater).</p>', 120, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Bonus de base à l''attaque', 'bonus-de-base-a-l-attaque', '<p>BBA : bonus d''attaque conféré par la classe et le niveau, avant modificateurs. Un BBA de +6 ou plus donne des attaques supplémentaires en <a class="glossaire-lien" data-glossaire-slug="attaque-a-outrance">attaque à outrance</a>.</p>', 130, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Bousculade', 'bousculade', '<p>Manœuvre repoussant un adversaire : test de Force opposé, modifié par la taille ; le perdant recule d''au moins 1,50 m.</p>', 140, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Camouflage', 'camouflage', '<p>Une cible difficile à voir (pénombre, feuillage…) impose 20 % de chances de rater ; le camouflage total (invisibilité, obscurité totale) en impose 50 %.</p>', 150, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Chancelant', 'chancelant', '<p>Une seule action simple <em>ou</em> de mouvement par round (dégâts non létaux égalant les points de vie courants, ou 0 pv).</p>', 160, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Charge', 'charge', '<p>Action complexe : déplacement d''au moins 3 m en ligne droite puis une attaque unique à +2, au prix de −2 à la CA jusqu''au tour suivant.</p>', 170, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Classe d''armure', 'classe-d-armure', '<p>CA = 10 + armure + bouclier + Dextérité + taille + divers : le résultat que le <a class="glossaire-lien" data-glossaire-slug="jet-d-attaque">jet d''attaque</a> doit atteindre pour toucher.</p>', 180, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Coup critique', 'coup-critique', '<p>Sur une menace (20 naturel ou zone de critique de l''arme) confirmée par un second jet d''attaque réussi, les dégâts sont multipliés (×2, ×3 ou ×4 selon l''arme).</p>', 190, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Coup de grâce', 'coup-de-grace', '<p>Action complexe contre un adversaire <a class="glossaire-lien" data-glossaire-slug="sans-defense">sans défense</a> : coup critique automatique, et jet de Vigueur (DD 10 + dégâts) pour la victime sous peine de mort.</p>', 200, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Croc-en-jambe', 'croc-en-jambe', '<p>Manœuvre visant à faire tomber l''adversaire : attaque de contact puis test opposé (Force contre Force ou Dextérité) ; le perdant se retrouve <a class="glossaire-lien" data-glossaire-slug="a-terre">à terre</a>.</p>', 210, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Dégâts non létaux', 'degats-non-letaux', '<p>Dégâts comptés à part : quand leur total atteint les points de vie courants, le personnage est chancelant ; au-delà, inconscient. Récupération : 1 point par heure et par niveau.</p>', 220, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Désarmement', 'desarmement', '<p>Manœuvre visant à faire lâcher son arme à l''adversaire : jets d''attaque opposés ; en cas d''échec, l''adversaire peut désarmer en retour.</p>', 230, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Diminution permanente de caractéristique', 'diminution-permanente-de-caracteristique', '<p>Perte de caractéristique qui ne revient pas naturellement : seuls <em>restauration</em> et sorts supérieurs la soignent.</p>', 240, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Ébloui', 'ebloui', '<p>−1 aux jets d''attaque et aux tests de Détection et de Fouille.</p>', 250, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Effrayé', 'effraye', '<p>Le personnage fuit la source de sa peur ; s''il ne peut fuir, il combat avec −2 aux jets d''attaque, de sauvegarde et aux tests. Degré intermédiaire entre <a class="glossaire-lien" data-glossaire-slug="secoue">secoué</a> et <a class="glossaire-lien" data-glossaire-slug="panique">paniqué</a>.</p>', 260, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Enchevêtré', 'enchevetre', '<p>Demi-vitesse, ni course ni charge, −2 aux jets d''attaque, −4 à la Dextérité ; incanter exige un test de Concentration (DD 15 + niveau du sort).</p>', 270, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Épuisé', 'epuise', '<p>Demi-vitesse, −6 en Force et en Dextérité. Devient <a class="glossaire-lien" data-glossaire-slug="fatigue">fatigué</a> après 1 heure de repos.</p>', 280, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Étourdi', 'etourdi', '<p>Le personnage lâche ce qu''il tient, ne peut plus agir, subit −2 à la CA et perd son bonus de Dextérité à la CA.</p>', 290, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Fasciné', 'fascine', '<p>Incapable d''agir, absorbé par l''effet, −4 aux tests de perception ; toute menace évidente brise l''état.</p>', 300, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Fatigué', 'fatigue', '<p>Ni course ni charge, −2 en Force et en Dextérité. Une nouvelle cause de fatigue rend <a class="glossaire-lien" data-glossaire-slug="epuise">épuisé</a> ; 8 heures de repos dissipent l''état.</p>', 310, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Feinte', 'feinte', '<p>Action simple : Bluff opposé à Psychologie (+ BBA) ; en cas de réussite, la prochaine attaque de corps à corps prive l''adversaire de son bonus de Dextérité à la CA.</p>', 320, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Fiévreux', 'fievreux', '<p>−2 aux jets d''attaque, aux jets de dégâts des armes, aux jets de sauvegarde et aux tests de compétence et de caractéristique.</p>', 330, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Guérison accélérée', 'guerison-acceleree', '<p>La créature récupère les points de vie indiqués chaque round, mais ne fait pas repousser les membres perdus (contrairement à la <a class="glossaire-lien" data-glossaire-slug="regeneration">régénération</a>).</p>', 340, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Hébété', 'hebete', '<p>Aucune action possible pendant 1 round, mais le personnage se défend normalement.</p>', 350, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Inconscient', 'inconscient', '<p>Le personnage est <a class="glossaire-lien" data-glossaire-slug="sans-defense">sans défense</a> et ignore ce qui l''entoure.</p>', 360, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Initiative', 'initiative', '<p>Test de Dextérité fait une fois en début de combat ; il fixe l''ordre d''action pour tous les rounds.</p>', 370, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Jet d''attaque', 'jet-d-attaque', '<p>1d20 + bonus d''attaque, contre la <a class="glossaire-lien" data-glossaire-slug="classe-d-armure">classe d''armure</a> de la cible. 1 naturel : échec automatique ; 20 naturel : réussite automatique et menace de critique.</p>', 380, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Jet de sauvegarde', 'jet-de-sauvegarde', '<p>1d20 + bonus de base + modificateur de caractéristique pour éviter ou réduire un effet : Réflexes (Dex), Vigueur (Con) ou Volonté (Sag).</p>', 390, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Lutte', 'lutte', '<p>Corps à corps rapproché : attaque de contact puis tests de lutte opposés (BBA + Force + taille). Les lutteurs perdent leur Dextérité à la CA contre l''extérieur et leurs actions sont très limitées.</p>', 400, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Modificateur de caractéristique', 'modificateur-de-caracteristique', '<p>(Valeur − 10) ÷ 2, arrondi à l''inférieur : c''est lui qui s''applique aux jets de dés liés à la caractéristique.</p>', 410, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Mourant', 'mourant', '<p>Entre −1 et −9 points de vie : inconscient, −1 pv par round, 10 % de chances par round de se stabiliser.</p>', 420, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Nauséeux', 'nauseeux', '<p>Incapable d''attaquer, d''incanter ou de se concentrer : une seule action de mouvement par round.</p>', 430, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Niveau négatif', 'niveau-negatif', '<p>−1 aux jets et tests, −5 points de vie, −1 niveau effectif et perte d''un sort du plus haut niveau. Après 24 heures, jet de Vigueur sous peine de perte de niveau réelle.</p>', 440, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Paniqué', 'panique', '<p>Le personnage lâche tout et fuit au hasard ; acculé, il reste aux abois. Degré ultime de la peur, après <a class="glossaire-lien" data-glossaire-slug="secoue">secoué</a> et <a class="glossaire-lien" data-glossaire-slug="effraye">effrayé</a>.</p>', 450, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Paralysé', 'paralyse', '<p>Figé, <a class="glossaire-lien" data-glossaire-slug="sans-defense">sans défense</a>, Force et Dextérité effectives de 0 ; seules les actions purement mentales restent possibles.</p>', 460, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Pas de placement', 'pas-de-placement', '<p>Déplacement de 1,50 m, une fois par round, qui ne provoque jamais d''attaque d''opportunité ; interdit dans un round comportant un autre déplacement.</p>', 470, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Pétrifié', 'petrifie', '<p>Changé en pierre : inconscient, sans besoins vitaux ; les dégâts subis par la statue se retrouvent sur le corps rendu à la chair.</p>', 480, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Pouvoir extraordinaire', 'pouvoir-extraordinaire', '<p>(Ext) Aptitude non magique : insensible à l''antimagie et à la dissipation, n''éveille pas d''attaque d''opportunité.</p>', 490, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Pouvoir magique', 'pouvoir-magique', '<p>(Mag) Fonctionne comme un sort sans composantes : soumis à la résistance à la magie et à la dissipation, provoque une attaque d''opportunité.</p>', 500, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Pouvoir surnaturel', 'pouvoir-surnaturel', '<p>(Sur) Aptitude magique qui n''est pas un sort : ni dissipable ni soumise à la résistance à la magie, mais inopérante dans une zone d''antimagie.</p>', 510, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Pris au dépourvu', 'pris-au-depourvu', '<p>Avant son premier tour de jeu : perte du bonus de Dextérité à la CA et aucune attaque d''opportunité possible.</p>', 520, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Prise en tenaille', 'prise-en-tenaille', '<p>Deux adversaires menaçant une créature depuis des côtés opposés gagnent chacun +2 au jet d''attaque au corps à corps contre elle.</p>', 530, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Réduction de dégâts', 'reduction-de-degats', '<p>RD valeur/contournement : la créature ignore la valeur indiquée sur chaque attaque d''arme, sauf si l''arme correspond au contournement (magie, argent, fer froid, alignement…).</p>', 540, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Régénération', 'regeneration', '<p>Les dégâts subis sont non létaux et guérissent au rythme indiqué ; seules certaines attaques (feu, acide…) infligent des dégâts létaux à la créature.</p>', 550, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Renversement', 'renversement', '<p>Manœuvre consistant à traverser la case d''un adversaire pendant un déplacement : test de Force opposé, le perdant est renversé <a class="glossaire-lien" data-glossaire-slug="a-terre">à terre</a>.</p>', 560, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Résistance à la magie', 'resistance-a-la-magie', '<p>RM : pour affecter la créature, le lanceur doit réussir un test de niveau de lanceur (1d20 + niveau) contre la valeur de RM.</p>', 570, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Round', 'round', '<p>6 secondes de combat : chaque combattant y joue un tour complet, dans l''ordre d''initiative.</p>', 580, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Sans défense', 'sans-defense', '<p>Paralysé, endormi, ligoté ou inconscient : Dextérité effective 0, +4 au jet des attaques de corps à corps subies, cible possible d''un <a class="glossaire-lien" data-glossaire-slug="coup-de-grace">coup de grâce</a>.</p>', 590, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Secoué', 'secoue', '<p>−2 aux jets d''attaque, de sauvegarde et aux tests. Premier degré de la peur, avant <a class="glossaire-lien" data-glossaire-slug="effraye">effrayé</a> et <a class="glossaire-lien" data-glossaire-slug="panique">paniqué</a>.</p>', 600, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Vision dans le noir', 'vision-dans-le-noir', '<p>Vision en noir et blanc dans l''obscurité totale, jusqu''à la distance indiquée (18 m le plus souvent).</p>', 610, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Vision nocturne', 'vision-nocturne', '<p>La créature voit deux à quatre fois plus loin qu''un humain en faible éclairage, couleurs comprises.</p>', 620, @ddver, @res, NULL, 1, @now, @now),
(@glo, 'glossaire', 'Zone contrôlée', 'zone-controlee', '<p>Les cases situées dans l''allonge d''un combattant : y accomplir une action déconcentrante ou la quitter provoque une <a class="glossaire-lien" data-glossaire-slug="attaque-d-opportunite">attaque d''opportunité</a>.</p>', 630, @ddver, @res, NULL, 1, @now, @now);

COMMIT;
