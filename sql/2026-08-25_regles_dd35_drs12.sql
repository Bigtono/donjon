-- ============================================================
-- 2026-08-25_regles_dd35_drs12.sql — SP-DRS1 (lot 1)
-- Règles DD3.5 — DRS 12 : Extérieur, climat et environnement.
-- Rattachement : racine thématique « Aventure et environnement ».
-- Tableaux : dd_tableaux (convention texte, tag [[tab:slug]]) — SP-TB9.
-- Idempotent : réinitialise uniquement le sous-arbre du chapitre
-- « Extérieur, climat et environnement » et ses tableaux.
-- Pré-requis : 2026-08-25_regles_dd35_socle.sql.
-- ============================================================

SET NAMES utf8mb4;

SET @ddver := (SELECT var_id FROM dd_variables
               WHERE var_cat = 'ruleset' AND var_valeur = 'DD3.5' LIMIT 1);
SET @res   := (SELECT res_id FROM dd_ressources
               WHERE res_abreviation = 'DRS 3.5' AND res_ruleset_var_id = @ddver LIMIT 1);
SET @racine := (SELECT reg_id FROM dd_regles
                WHERE reg_slug = 'aventure-et-environnement' AND reg_ruleset_var_id = @ddver LIMIT 1);
SET @now := NOW();

START TRANSACTION;

-- ------------------------------------------------------------
-- Réinitialisation idempotente du sous-arbre DRS 12
-- ------------------------------------------------------------
SET @chap := (SELECT reg_id FROM dd_regles
              WHERE reg_slug = 'exterieur-climat-et-environnement' AND reg_ruleset_var_id = @ddver LIMIT 1);
DELETE FROM dd_regles WHERE @chap IS NOT NULL AND reg_reg_id = @chap;
DELETE FROM dd_regles WHERE @chap IS NOT NULL AND reg_id = @chap;
DELETE FROM dd_tableaux
WHERE  tab_ruleset_var_id = @ddver
  AND  tab_slug IN ('terrain-foret', 'terrain-marais', 'terrain-collines',
                    'terrain-montagnes', 'terrain-desert', 'terrain-plaines',
                    'climat-aleatoire', 'effets-du-vent');

-- ------------------------------------------------------------
-- Chapitre
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@racine, 'chapitre', 'Extérieur, climat et environnement', 'exterieur-climat-et-environnement',
        '<p>L''aventure en extérieur confronte les personnages à des dangers qui ne doivent rien aux monstres : s''orienter, traverser les milieux naturels, subir le climat, survivre à la chaleur, au froid et aux autres périls de l''environnement.</p>',
        10, @ddver, @res, NULL, 1, @now, @now);
SET @chap := LAST_INSERT_ID();

-- ------------------------------------------------------------
-- Règle : Se déplacer en extérieur
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Se déplacer en extérieur', 'se-deplacer-en-exterieur',
        '<h3>Se perdre</h3>
<p>Un groupe qui progresse hors des routes par mauvaise visibilité (brouillard, nuit sans lune) ou en terrain uniforme (forêt dense, désert, plaine sans repère) risque de se perdre : chaque heure de marche, le guide fait un test de <strong>Survie</strong>. Le DD dépend du terrain : 12 en plaine, 14 en forêt clairsemée, dans les landes ou les collines, 16 en forêt moyenne, dans le désert ou les marais, 18 en forêt dense ou en montagne. En cas d''échec, le groupe part dans une direction aléatoire.</p>
<p>Un groupe perdu s''en rend compte au bout d''un moment (test de Survie DD 20 chaque heure) ; il peut ensuite tenter de se réorienter (test de Survie DD 15, une tentative par heure d''errance). Une carte précise ou un point de repère visible (montagne, côte) évite de se perdre.</p>
<h3>Rythme de voyage</h3>
<p>Une journée de marche représente 8 heures de déplacement effectif. La distance dépend de la vitesse du personnage et du terrain : les routes se parcourent à vitesse normale, les pistes et le terrain découvert peuvent la réduire, les terrains difficiles (montagne, marécage, forêt dense) la divisent jusqu''à moitié ou au quart. La <strong>marche forcée</strong> au-delà de 8 heures impose chaque heure un test de Constitution (DD 10 + 2 par heure supplémentaire) sous peine de dégâts non létaux et de fatigue.</p>',
        10, @ddver, @res, NULL, 1, @now, @now);

-- ------------------------------------------------------------
-- Règle : Les milieux naturels
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Les milieux naturels', 'les-milieux-naturels',
        '<p>Chaque milieu naturel combine des éléments de terrain qui affectent le déplacement, la visibilité et les possibilités de discrétion. Les tableaux ci-dessous donnent la fréquence des éléments typiques selon la densité du milieu.</p>
<h3>Forêts</h3>
<p>Les arbres offrent un abri (+4 CA, +2 Réflexes) à qui se tient dans leur case ; taillis et broussailles sont du terrain difficile qui procure du camouflage. Les incendies de forêt constituent un danger majeur (voir <em>Autres dangers</em>).</p>
<p>[[tab:terrain-foret]]</p>
<h3>Marais</h3>
<p>Les fondrières sont du terrain difficile ; les fondrières profondes exigent de nager ou de patauger (les tourbières peuvent cacher des sables mouvants). Les haies de roseaux procurent camouflage et gênent le déplacement.</p>
<p>[[tab:terrain-marais]]</p>
<h3>Collines</h3>
<p>Les pentes douces ne gênent pas la marche ; les pentes escarpées sont du terrain difficile (test d''Escalade DD 0 pour courir ou charger vers le haut) et les falaises exigent l''escalade (DD 15).</p>
<p>[[tab:terrain-collines]]</p>
<h3>Montagnes</h3>
<p>Aux éléments des collines s''ajoutent les éboulis (terrain difficile, risque de chute de pierres), les parois (Escalade DD 15 à 25), les crevasses et, en altitude, l''air raréfié : au-dessus de 4 500 m, chaque heure impose un test de Vigueur (DD 15, +1 par test précédent) sous peine de fatigue liée à l''altitude.</p>
<p>[[tab:terrain-montagnes]]</p>
<h3>Déserts</h3>
<p>Le sable fin ne gêne pas la marche, les dunes de sable profond sont du terrain difficile. Le danger principal reste la chaleur du jour, le froid de la nuit et la déshydratation (voir <em>Chaleur et froid</em> et <em>Autres dangers</em>).</p>
<p>[[tab:terrain-desert]]</p>
<h3>Plaines</h3>
<p>Terrain le plus praticable : la végétation haute procure du camouflage à qui se tient à terre, et les rares haies ou murets servent d''abri.</p>
<p>[[tab:terrain-plaines]]</p>',
        20, @ddver, @res, NULL, 1, @now, @now);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note,
                         tab_ruleset_var_id, tab_res_id, tab_camp_id,
                         tab_ecran_mj, tab_ecran_ordre, tab_visible,
                         tab_date_creation, tab_date_modif)
VALUES
('terrain-foret', 'Éléments de terrain — forêts',
'! Élément | Clairsemée | Moyenne | Dense
Arbres typiques | 30 % | 40 % | 60 %
Arbres massifs | — | 10 % | 20 %
Taillis clairsemés | 50 % | 70 % | 50 %
Taillis denses | — | 20 % | 50 %
> Un arbre occupe une case et offre un abri (+4 CA, +2 Réflexes). Les taillis sont du terrain difficile procurant camouflage ; les taillis denses (DD Discrétion réduit, déplacement ÷ 4) exigent parfois un test d''Évasion pour les traverser sans dommage.',
'lccc', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('terrain-marais', 'Éléments de terrain — marais',
'! Élément | Marécage peu profond | Marécage profond
Fondrières peu profondes | 20 % | 40 %
Fondrières profondes | — | 20 %
Haies de roseaux | 30 % | 60 %
> Fondrière peu profonde : terrain difficile. Fondrière profonde : 1,20 m d''eau — 4 cases de déplacement par case traversée, ou nage ; camouflage possible en s''immergeant. Les roseaux procurent du camouflage et sont du terrain difficile.',
'lcc', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('terrain-collines', 'Éléments de terrain — collines',
'! Élément | Collines douces | Collines escarpées
Pente douce | 75 % | 40 %
Pente escarpée | 20 % | 50 %
Falaise | 5 % | 10 %
Éboulis | — | —
> Pente escarpée : terrain difficile en montée ; un personnage qui court ou charge en descente doit réussir un test d''Équilibre (DD 10). Falaise : Escalade DD 15, hauteur typique 1d4 × 3 m.',
'lcc', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('terrain-montagnes', 'Éléments de terrain — montagnes',
'! Élément | Alpages | Montagne rocailleuse | Montagne escarpée
Pente douce | 50 % | 25 % | 15 %
Pente escarpée | 40 % | 55 % | 55 %
Falaise | 10 % | 15 % | 20 %
Éboulis | — | 5 % | 10 %
> Éboulis : terrain difficile, test d''Équilibre (DD 10) pour courir ou charger. Paroi montagneuse : Escalade DD 15 à 25. Au-dessus de 4 500 m, l''air raréfié impose un test de Vigueur horaire (DD 15, +1 cumulatif) sous peine de fatigue.',
'lccc', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('terrain-desert', 'Éléments de terrain — déserts',
'! Élément | Désert de pierre | Désert de sable
Terrain accidenté | 50 % | 10 %
Sable profond | 10 % | 50 %
Dunes | — | 40 %
> Sable profond et dunes : terrain difficile. Le versant sous le vent d''une dune compte comme une pente escarpée. Chaleur du jour, froid de la nuit et déshydratation : voir Chaleur et froid.',
'lcc', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('terrain-plaines', 'Éléments de terrain — plaines',
'! Élément | Cultivée | Prairie | Steppe
Végétation haute | 40 % | 60 % | 20 %
Terrain accidenté | — | 10 % | 20 %
Haies et murets | 20 % | 5 % | —
> La végétation haute procure du camouflage à une créature à terre ou de taille P ; une haie ou un muret offre un abri (+4 CA).',
'lccc', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now);

-- ------------------------------------------------------------
-- Règle : Environnement aquatique
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Environnement aquatique', 'environnement-aquatique',
        '<h3>Nager</h3>
<p>Un test de <strong>Natation</strong> par round : DD 10 en eau calme, 15 en eau agitée, 20 en eau démontée. Réussite : déplacement d''un quart de la vitesse (action de mouvement) ou de la moitié (action complexe). Échec de 4 points ou moins : sur place ; échec de 5 points ou plus : la tête passe sous l''eau. L''armure et la charge pèsent lourdement sur le test (malus d''armure ×2… le malus s''applique déjà via la charge).</p>
<h3>Retenir son souffle et noyade</h3>
<p>Une créature peut retenir son souffle pendant un nombre de rounds égal à <strong>deux fois sa Constitution</strong> (chaque action simple ou complexe accomplie réduit ce délai). Au-delà, test de Constitution (DD 10, +1 par round) chaque round : au premier échec, la créature commence à se noyer — round 1 : inconsciente (0 pv) ; round 2 : mourante (−1 pv) ; round 3 : morte.</p>
<h3>Combat sous l''eau</h3>
<p>Sous l''eau, sans liberté de mouvement : les armes tranchantes et contondantes subissent −2 au jet d''attaque et dégâts divisés par deux (les armes perforantes s''en tirent normalement) ; les attaques à distance sont quasi impossibles au-delà de la portée courte et perdent toute efficacité au-delà. Le feu ne fonctionne pas sous l''eau. Les créatures nageuses (vitesse de nage) ignorent l''essentiel de ces malus.</p>
<h3>Visibilité et perception</h3>
<p>La visibilité sous l''eau dépend de la clarté : eau limpide 60 m, eau trouble 6 m. La lumière décroît rapidement avec la profondeur ; au-delà de 300 m règne l''obscurité totale.</p>',
        30, @ddver, @res, NULL, 1, @now, @now);

-- ------------------------------------------------------------
-- Règle : Le climat
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Le climat', 'le-climat',
        '<p>[[tab:climat-aleatoire]]</p>
<h3>Précipitations</h3>
<ul><li><strong>Pluie.</strong> Malus de −4 aux tests de Détection et de Perception auditive, et aux attaques à distance ; éteint les flammes non protégées.</li><li><strong>Neige.</strong> Comme la pluie ; une journée de neige laisse un manteau qui fait du sol un terrain difficile. La <strong>neige abondante</strong> réduit en outre la visibilité (comme le brouillard) et laisse 1d4 × 25 cm de neige (terrain très difficile : 4 cases par case).</li><li><strong>Grêle.</strong> Ne réduit pas la visibilité mais impose −4 à la Perception auditive ; une grêle violente peut infliger 1 point de dégâts par jour d''exposition.</li><li><strong>Brouillard.</strong> Camouflage (20 %) au-delà de 1,50 m ; la vision est limitée.</li></ul>
<h3>Tempêtes</h3>
<p>Une tempête combine vents violents (voir tableau des vents) et précipitations : −8 aux tests de Détection et de Perception auditive et −4 aux attaques à distance. L''<strong>orage</strong> ajoute la foudre, la <strong>tempête de sable</strong> inflige 1d3 points de dégâts non létaux par heure à qui s''y expose, et l''<strong>ouragan</strong> comme la <strong>tornade</strong> rendent toute activité extérieure périlleuse (créatures emportées, structures détruites).</p>
<p>[[tab:effets-du-vent]]</p>',
        40, @ddver, @res, NULL, 1, @now, @now);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note,
                         tab_ruleset_var_id, tab_res_id, tab_camp_id,
                         tab_ecran_mj, tab_ecran_ordre, tab_visible,
                         tab_date_creation, tab_date_modif)
VALUES
('climat-aleatoire', 'Climat aléatoire',
'! d% | Temps | Plaines, forêts, collines | Désert
01–70 | Temps de saison | Normal pour la saison | Chaleur normale
71–80 | Temps anormal | Vague de chaleur (01–50) ou de froid (51–100) | Chaleur intense
81–90 | Intempéries | Précipitations (pluie ou neige selon température) | Vent violent et poussière
91–99 | Tempête | Orage, tempête de neige… | Tempête de sable
100 | Tempête majeure | Blizzard, ouragan, tornade… | Tempête de sable violente
> Jet à faire une fois par jour de voyage ; adapter à la saison et au climat régional.',
'cllc', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('effets-du-vent', 'Effets du vent',
'! Force du vent | Vitesse | Attaques à distance | Taille emportée | Test de Vigueur (DD)
Brise légère | 0–15 km/h | — | — | —
Brise modérée | 16–30 km/h | — | — | —
Vent soutenu | 31–45 km/h | −2 | TP | 10
Vent violent | 46–75 km/h | −4 | P | 15
Bourrasques | 76–110 km/h | Impossibles¹ | M | 18
Vent de tempête | 111–130 km/h | Impossibles¹ | G | 20
Ouragan | 131–280 km/h | Impossibles¹ | TG | 25
Tornade | 281–500 km/h | Impossibles¹ | Gig | 30
> 1. Sauf armes de siège (−4 par palier au-delà de « vent violent »). Une créature de la taille indiquée ou inférieure qui rate son test de Vigueur est stoppée (à pied) ou emportée : les créatures volantes subissent le palier de taille supérieur. Les vents soutenus et plus éteignent les flammes non protégées.',
'lcccc', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now);

-- ------------------------------------------------------------
-- Règle : Chaleur et froid
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Chaleur et froid', 'chaleur-et-froid',
        '<h3>Chaleur</h3>
<ul><li><strong>Forte chaleur (plus de 32 °C).</strong> Test de Vigueur toutes les heures (DD 15, +1 par test précédent) sous peine de 1d4 points de dégâts non létaux. Les personnages en armure ou lourdement vêtus subissent −4 au test.</li><li><strong>Chaleur torride (plus de 43 °C).</strong> Test toutes les 10 minutes.</li><li><strong>Chaleur extrême (air brûlant, plus de 60 °C).</strong> 1d6 points de dégâts (létaux) par minute sans jet de sauvegarde, plus le test de Vigueur horaire.</li></ul>
<p>Une victime de dégâts non létaux de chaleur souffre d''un <strong>coup de chaleur</strong> : elle est fatiguée et ces dégâts ne disparaissent pas tant qu''elle n''est pas rafraîchie.</p>
<h3>Froid</h3>
<ul><li><strong>Grand froid (moins de 4 °C).</strong> Test de Vigueur toutes les heures (DD 15, +1 par test précédent) sous peine de 1d6 points de dégâts non létaux.</li><li><strong>Froid intense (moins de −18 °C).</strong> Test toutes les 10 minutes.</li><li><strong>Froid extrême (moins de −29 °C).</strong> 1d6 points de dégâts (létaux) par minute sans jet de sauvegarde, plus le test de Vigueur.</li></ul>
<p>Une victime de dégâts non létaux de froid souffre d''<strong>hypothermie</strong> : elle est fatiguée. Un test de Survie réussi (DD 15) permet de gagner un bonus au jet et d''en faire profiter les autres. Se retrouver dans l''eau glacée inflige 1d6 points de dégâts non létaux par minute.</p>',
        50, @ddver, @res, NULL, 1, @now, @now);

-- ------------------------------------------------------------
-- Règle : Autres dangers
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Autres dangers', 'autres-dangers',
        '<h3>Acide</h3>
<p>Contact : 1d6 points de dégâts par round d''exposition ; immersion totale : 10d6 par round. Les vapeurs des acides puissants attaquent aussi les poumons (1 point de dégâts de Constitution par minute).</p>
<h3>Asphyxie</h3>
<p>Sans air, une créature tient deux fois sa Constitution en rounds, puis suit les règles de la noyade (voir <em>Environnement aquatique</em>). Dans un espace clos, l''air se raréfie lentement : compter plusieurs heures par personne avant l''étouffement progressif.</p>
<h3>Avalanches et éboulements</h3>
<p>Une avalanche ensevelit sa zone centrale (8d6 points de dégâts, réduits de moitié par un jet de Réflexes DD 15, puis ensevelissement : 1d6 points de dégâts non létaux par minute, asphyxie en cas d''inconscience) et frappe sa zone périphérique (3d6, Réflexes DD 15 annule).</p>
<h3>Chutes</h3>
<p>Une chute inflige <strong>1d6 points de dégâts par tranche de 3 m</strong> (maximum 20d6). Les 3 premiers mètres d''une chute volontaire infligent des dégâts non létaux ; un test de Saut (DD 15) ou d''Acrobaties (DD 15) réduit encore les dégâts. Une chute dans l''eau profonde est sans dégâts jusqu''à 6 m, puis 1d3 par tranche de 3 m.</p>
<h3>Chute d''objets</h3>
<p>Un objet qui tombe inflige 1d6 points de dégâts par tranche de 90 kg, ajustés selon la hauteur de chute ; jet de Réflexes (DD 15) pour l''éviter.</p>
<h3>Fumée</h3>
<p>Une créature qui respire d''épaisses volutes doit réussir chaque round un test de Vigueur (DD 15, +1 par test précédent) sous peine de passer le round à tousser (1d6 points de dégâts non létaux par round de toux). La fumée donne du camouflage.</p>
<h3>Lave</h3>
<p>Contact : 2d6 points de dégâts par round ; immersion : 20d6 par round. Les dégâts se poursuivent à demi-puissance pendant 1d3 rounds après l''exposition. La résistance au feu protège, mais une immersion la déborde vite.</p>
<h3>Obscurité</h3>
<p>Sans vision nocturne ni vision dans le noir, une créature plongée dans l''obscurité totale est effectivement aveuglée : camouflage total des adversaires (50 %), perte du bonus de Dextérité à la CA, déplacement à demi-vitesse (test d''Équilibre pour courir).</p>
<h3>Privation d''eau et de nourriture</h3>
<p>Un personnage a besoin de 4 litres d''eau et de 500 g de nourriture par jour. Sans eau au-delà d''un jour + sa Constitution en heures : test de Constitution horaire (DD 10, +1 par test) sous peine de 1d6 points de dégâts non létaux. Sans nourriture au-delà de 3 jours : 1d6 points de dégâts non létaux par jour. Ces dégâts ne se soignent pas tant que le personnage n''a ni bu ni mangé.</p>
<h3>Incendies</h3>
<p>Un feu de forêt avance plus vite qu''un marcheur ; qui est rattrapé subit la chaleur (dégâts non létaux puis létaux), la fumée et les flammes (1d6 points de dégâts par round au contact, vêtements qui prennent feu : 1d6 par round jusqu''à extinction, Réflexes DD 15).</p>
<h3>Sables mouvants</h3>
<p>Une créature qui s''y engage s''enfonce : test de Natation (DD 10) chaque round pour se maintenir ou progresser lentement ; en cas d''échec de 5 points ou plus, elle coule et risque la noyade. Le sauvetage exige une corde ou une perche (test de Force DD 15).</p>',
        60, @ddver, @res, NULL, 1, @now, @now);

COMMIT;
