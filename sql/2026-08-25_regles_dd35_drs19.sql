-- ============================================================
-- 2026-08-25_regles_dd35_drs19.sql — SP-DRS1 (lot 1)
-- Règles DD3.5 — DRS 19 : Types, sous-types et pouvoirs spéciaux
-- (partie types et sous-types — les pouvoirs sont dans DRS 18).
-- Rattachement : racine thématique « Créatures et pouvoirs spéciaux ».
-- Tableaux : dd_tableaux (convention texte, tag [[tab:slug]]) — SP-TB9.
-- Idempotent : réinitialise uniquement le sous-arbre du chapitre
-- « Types et sous-types de créatures » et son tableau.
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
-- Réinitialisation idempotente du sous-arbre DRS 19
-- ------------------------------------------------------------
SET @chap := (SELECT reg_id FROM dd_regles
              WHERE reg_slug = 'types-et-sous-types-de-creatures' AND reg_ruleset_var_id = @ddver LIMIT 1);
DELETE FROM dd_regles WHERE @chap IS NOT NULL AND reg_reg_id = @chap;
DELETE FROM dd_regles WHERE @chap IS NOT NULL AND reg_id = @chap;
DELETE FROM dd_tableaux
WHERE  tab_ruleset_var_id = @ddver
  AND  tab_slug IN ('caracteristiques-des-types');

-- ------------------------------------------------------------
-- Chapitre
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@racine, 'chapitre', 'Types et sous-types de créatures', 'types-et-sous-types-de-creatures',
        '<p>Chaque créature appartient à un <strong>type</strong> qui détermine ses dés de vie, son bonus de base à l''attaque, ses jets de sauvegarde privilégiés, ses points de compétence et un ensemble de traits communs. Des <strong>sous-types</strong> précisent ce profil (élément, alignement, milieu…).</p>',
        20, @ddver, @res, NULL, 1, @now, @now);
SET @chap := LAST_INSERT_ID();

-- ------------------------------------------------------------
-- Règle : Types de créatures
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Types de créatures', 'types-de-creatures',
        '<p>[[tab:caracteristiques-des-types]]</p>
<h3>Aberration</h3>
<p>Anatomie étrange, pouvoirs bizarres ou origine extraterrestre. Vision dans le noir 18 m. Maîtrise de ses armes naturelles et de toute arme mentionnée dans sa description.</p>
<h3>Animal</h3>
<p>Créature vivante non humanoïde dépourvue de pouvoirs surnaturels, d''Intelligence 1 ou 2 (jamais plus). Vision nocturne. Alignement toujours neutre.</p>
<h3>Créature artificielle</h3>
<p>Objet animé ou créature fabriquée (golem…). Pas de Constitution ; vision dans le noir 18 m et vision nocturne. Immunisée contre les effets mentaux, le poison, le sommeil, la paralysie, l''étourdissement, la maladie, les effets de mort et la nécromancie. Non soumise aux coups critiques, aux dégâts non létaux, à l''affaiblissement de caractéristique et à l''absorption d''énergie. Ne peut pas être soignée (sauf réparation) et n''est jamais mourante : à 0 point de vie, elle est immédiatement détruite. Points de vie en bonus selon la taille.</p>
<h3>Créature magique</h3>
<p>Semblable à un animal mais d''Intelligence supérieure à 2, ou dotée de pouvoirs surnaturels ou extraordinaires. Vision dans le noir 18 m et vision nocturne.</p>
<h3>Dragon</h3>
<p>Reptilien, généralement ailé, doté de pouvoirs magiques ou inhabituels. Vision dans le noir 18 m et vision nocturne. Immunisé contre le sommeil et la paralysie magiques.</p>
<h3>Élémentaire</h3>
<p>Créature composée d''un des quatre éléments. Immunisée contre le poison, le sommeil, la paralysie et l''étourdissement ; non sujette aux coups critiques ni à la prise en tenaille. Ne dort pas. Un élémentaire détruit ne peut être ramené que par <em>résurrection suprême</em>, <em>souhait</em> ou <em>miracle</em>.</p>
<h3>Extérieur</h3>
<p>Créature au moins partiellement issue d''un autre plan. Vision dans le noir 18 m. Ne peut être rappelée à la vie que par <em>résurrection suprême</em>, <em>souhait</em> ou <em>miracle</em>. Maîtrise de toutes les armes courantes et de guerre.</p>
<h3>Fée</h3>
<p>Créature aux pouvoirs surnaturels, liée à la nature ou à quelque lieu. Vision nocturne.</p>
<h3>Géant</h3>
<p>Humanoïde de grande taille et de grande force. Vision nocturne. Maîtrise de ses armes naturelles, des armes courantes et de guerre mentionnées dans sa description.</p>
<h3>Humanoïde</h3>
<p>Créature bipède de taille P ou M, sans pouvoirs surnaturels, en général civilisée (humains, elfes, orques, gobelins…). Le plus souvent 1 dé de vie, remplacé par sa classe.</p>
<h3>Humanoïde monstrueux</h3>
<p>Humanoïde aux traits monstrueux ou animaux, souvent doté de pouvoirs surnaturels (harpie, minotaure…). Vision dans le noir 18 m.</p>
<h3>Mort-vivant</h3>
<p>Créature morte réanimée. Pas de Constitution. Vision dans le noir 18 m. Immunisé contre les effets mentaux, le poison, le sommeil, la paralysie, l''étourdissement, la maladie et les effets de mort. Non soumis aux coups critiques, aux dégâts non létaux, à l''affaiblissement de caractéristiques physiques et à l''absorption d''énergie ; immunisé contre tout effet exigeant un jet de Vigueur (sauf s''il affecte aussi les objets). Soigné par l''énergie négative ; détruit à 0 point de vie. Ne respire pas, ne mange pas, ne dort pas.</p>
<h3>Plante</h3>
<p>Créature végétale. Vision nocturne. Immunisée contre les effets mentaux, le poison, le sommeil, la paralysie, l''étourdissement et la métamorphose ; non sujette aux coups critiques.</p>
<h3>Vase</h3>
<p>Créature amorphe, généralement dépourvue d''Intelligence (immunisée de ce fait contre les effets mentaux). Aveugle (vision aveugle 18 m), immunisée contre le poison, le sommeil, la paralysie, la métamorphose et l''étourdissement ; non sujette aux coups critiques ni à la prise en tenaille.</p>
<h3>Vermine</h3>
<p>Insectes, arachnides et arthropodes géants. Dépourvue d''Intelligence (immunisée contre les effets mentaux) ; vision dans le noir 18 m. Alignement toujours neutre.</p>',
        10, @ddver, @res, NULL, 1, @now, @now);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note,
                         tab_ruleset_var_id, tab_res_id, tab_camp_id,
                         tab_ecran_mj, tab_ecran_ordre, tab_visible,
                         tab_date_creation, tab_date_modif)
VALUES ('caracteristiques-des-types', 'Caractéristiques des types de créatures',
'! Type | Dé de vie | BBA | Bons jets de sauvegarde | Points de compétence
Aberration | d8 | ×3/4 | Volonté | 2 + mod. Int
Animal | d8 | ×3/4 | Vigueur et Réflexes | 2 + mod. Int
Créature artificielle | d10 | ×3/4 | Aucun | 2 + mod. Int¹
Créature magique | d10 | ×1 | Vigueur et Réflexes | 2 + mod. Int
Dragon | d12 | ×1 | Vigueur, Réflexes et Volonté | 6 + mod. Int
Élémentaire | d8 | ×3/4 | Réflexes (air, feu) ou Vigueur (terre, eau) | 2 + mod. Int
Extérieur | d8 | ×1 | Vigueur, Réflexes et Volonté | 8 + mod. Int
Fée | d6 | ×1/2 | Réflexes et Volonté | 6 + mod. Int
Géant | d8 | ×3/4 | Vigueur | 2 + mod. Int
Humanoïde | d8 | ×3/4 | Variable (un des trois) | 2 + mod. Int
Humanoïde monstrueux | d8 | ×1 | Réflexes et Volonté | 2 + mod. Int
Mort-vivant | d12 | ×1/2 | Volonté | 4 + mod. Int
Plante | d8 | ×3/4 | Vigueur | 2 + mod. Int¹
Vase | d10 | ×3/4 | Aucun | 2 + mod. Int¹
Vermine | d8 | ×3/4 | Vigueur | 2 + mod. Int¹
> 1. Les créatures dépourvues d''Intelligence ne reçoivent ni points de compétence ni dons. Points de compétence : minimum 1 par dé de vie, quadruplés au premier dé de vie.',
        'lcccc', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now);

-- ------------------------------------------------------------
-- Règle : Sous-types de créatures
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Sous-types de créatures', 'sous-types-de-creatures',
        '<h3>Air</h3><p>Créature liée au plan de l''Air ; possède toujours une vitesse de vol.</p>
<h3>Aquatique</h3><p>Créature respirant sous l''eau, dotée d''une vitesse de nage. Ne peut pas respirer hors de l''eau, sauf si elle possède aussi le sous-type amphibie.</p>
<h3>Archon</h3><p>Céleste loyal bon du plan de Célestia : vision dans le noir 18 m, aura de menace, immunité contre l''électricité et la pétrification, +4 aux jets contre le poison, télépathie.</p>
<h3>Bien / Mal / Loi / Chaos</h3><p>Sous-types d''alignement des extérieurs : les attaques naturelles et les armes maniées de la créature sont considérées comme alignées en conséquence pour contourner la réduction de dégâts.</p>
<h3>Eau</h3><p>Créature liée au plan de l''Eau ; possède toujours une vitesse de nage et peut respirer sous l''eau.</p>
<h3>Extraplanaire</h3><p>Créature se trouvant hors de son plan d''origine. Le sous-type disparaît (au profit d''indigène) sur son plan natal.</p>
<h3>Feu</h3><p>Immunité contre le feu, vulnérabilité au froid (dégâts de froid +50 %).</p>
<h3>Froid</h3><p>Immunité contre le froid, vulnérabilité au feu (dégâts de feu +50 %).</p>
<h3>Gobelinoïde</h3><p>Humanoïdes de la famille des gobelins (gobelins, hobgobelins, gobelours) ; parlent le gobelin.</p>
<h3>Indigène</h3><p>Extérieur natif du plan Matériel : il peut être rappelé à la vie normalement et a besoin de manger et de dormir.</p>
<h3>Intangible</h3><p>Créature sans corps matériel (voir <em>Pouvoirs spéciaux — Intangibilité</em>).</p>
<h3>Métamorphe</h3><p>La créature change de forme à volonté ; elle retrouve sa forme réelle à sa mort. Maîtrise de ses armes naturelles sous toutes ses formes.</p>
<h3>Nuée</h3><p>Masse de créatures de taille TP à Infime agissant comme une créature unique : la nuée occupe 3 m × 3 m, attaque toute créature dont elle envahit l''espace, est immunisée contre les attaques d''arme (moitié des dégâts de zone pour les nuées de créatures Infimes ou Minuscules — immunité totale pour ces dernières aux armes), non sujette au croc-en-jambe, à la lutte ni à la bousculade.</p>
<h3>Reptilien</h3><p>Humanoïdes à sang froid et à écailles (kobolds, troglodytes, hommes-lézards…).</p>
<h3>Terre</h3><p>Créature liée au plan de la Terre ; possède souvent une vitesse de creusement.</p>
<h3>Augmenté</h3><p>Créature dont le type a changé (par un archétype, une transformation…) : elle garde trace de son type d''origine, ex. « mort-vivant (humanoïde augmenté) ».</p>',
        20, @ddver, @res, NULL, 1, @now, @now);

COMMIT;
