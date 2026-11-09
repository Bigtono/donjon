-- sql/2026-11-08_sp-drs9c_archetypes_dd35.sql
-- SP-DRS9c — DRS 35 à 40 : les archétypes des monstres, rangés dans le compendium Races (type « Archétype »)
-- Huit archétypes absents de la base, source DRS 3.5 : Demi-céleste, Demi-fiélon, Fantôme, Liche,
-- Lycanthrope, Squelette, Vampire, Zombi. Texte intégral des sections « Création de … » du DRS ;
-- les tableaux vont dans dd_tableaux (catégorie Monstre) et sont appelés par [[tab:archetype-…]].
-- Demi-dragon, Céleste et Fiélon existent déjà (autres sources) : non touchés.
-- Le second « Création d'un squelette » du DRS 40 est en fait celui du zombi (coquille du titre).
-- Texte corrigé : voir doc/LOG_CORRECTIONS_DRS29_40.md.
-- Rejouable : tableaux réinitialisés par slug, archétypes insérés seulement s'ils sont absents de la
-- source DRS 3.5. Pas de DELIMITER. Pré-requis : socle SP-DRS0, SP-TB12 (catégories de tableaux).

SET NAMES utf8mb4;

SET @ddver := (SELECT var_id FROM dd_variables WHERE var_cat = 'ruleset' AND var_valeur = 'DD3.5' LIMIT 1);
SET @res   := (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'DRS 3.5' AND res_ruleset_var_id = @ddver LIMIT 1);
SET @rat   := (SELECT rat_id FROM dd_race_type WHERE rat_nom = 'Archétype' AND rat_ruleset_var_id = @ddver LIMIT 1);
SET @tabc  := (SELECT tabc_id FROM dd_tableaux_categories WHERE tabc_slug = 'monstre' LIMIT 1);
SET @now   := NOW();

START TRANSACTION;

DELETE FROM dd_tableaux WHERE tab_ruleset_var_id = @ddver
  AND tab_slug IN ('archetype-demi-celeste-pouvoirs-magiques', 'archetype-demi-fielon-degats', 'archetype-demi-fielon-pouvoirs-magiques', 'archetype-lycanthrope-attaques-hybride', 'archetype-lycanthropes-courants', 'archetype-lycanthrope-transformation-involontaire', 'archetype-lycanthrope-transformation-volontaire', 'archetype-squelette-armure-naturelle', 'archetype-squelette-degats-griffes', 'archetype-squelette-fp', 'archetype-vampire-degats-coup', 'archetype-zombi-armure-naturelle', 'archetype-zombi-degats-coup', 'archetype-zombi-fp');

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id,
                         tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible,
                         tab_date_creation, tab_date_modif)
VALUES
('archetype-demi-celeste-pouvoirs-magiques', 'Pouvoirs magiques du demi-céleste',
'! DV | Pouvoirs
1–2 | Bénédiction, protection contre le Mal (3 fois/jour)
3–4 | Aide, détection du Mal
5–6 | Neutralisation du poison, soins importants
7–8 | Châtiment sacré, guérison des maladies
9–10 | Rejet du Mal
11–12 | Parole sacrée
13–14 | Aura sacrée (3 fois/jour), sanctification
15–16 | Symbole
17–18 | Convocation de monstres IX (célestes uniquement)
19–20 | Résurrection',
'cl', NULL, @tabc, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('archetype-demi-fielon-degats', 'Dégâts des armes naturelles du demi-fiélon',
'! Taille | Dégâts morsure | Dégâts griffes
Infime (I) | 1 | —
Minuscule (Min) | 1d2 | 1
Très petite (TP) | 1d3 | 1d2
Petite (P) | 1d4 | 1d3
Moyenne (M) | 1d6 | 1d4
Grande (G) | 1d8 | 1d6
Très grande (TG) | 2d6 | 1d8
Gigantesque (Gig) | 3d6 | 2d6
Colossale (C) | 4d6 | 3d6',
'lcc', NULL, @tabc, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('archetype-demi-fielon-pouvoirs-magiques', 'Pouvoirs magiques du demi-fiélon',
'! Niveau | Pouvoirs
1–2 | Ténèbres (3 fois/jour)
3–4 | Profanation
5–6 | Ténèbres maudites
7–8 | Empoisonnement (3 fois/jour)
9–10 | Contagion
11–12 | Blasphème
13–14 | Aura maudite (3 fois/jour), sanctification maléfique
15–16 | Flétrissure
17–18 | Convocation de monstres IX (fiélons uniquement)
19–20 | Destruction',
'cl', NULL, @tabc, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('archetype-lycanthrope-attaques-hybride', 'Attaques naturelles de l''hybride',
'! Taille de l''hybride | Griffes | Morsure
P | 1d3 | 1d4
M | 1d4 | 1d6
G | 1d6 | 1d8
TG | 2d4 | 2d6',
'lcc', NULL, @tabc, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('archetype-lycanthropes-courants', 'Lycanthropes courants',
'! Nom | Forme animale | Modificateurs de caractéristique (animal ou hybride) | Alignement préféré
Loup-garou | Loup | For +2, Dex +4, Con +4 | Chaotique mauvais
Ours-garou | Ours brun | For +16, Dex +2, Con +8 | Loyal bon
Rat-garou | Rat sanguinaire | Dex +6, Con +2 | Chaotique mauvais
Sanglier-garou | Sanglier | For +4, Con +6 | Neutre
Sanglier-garou sanguinaire | Sanglier sanguinaire | For +16, Con +6 | Neutre
Tigre-garou | Tigre | For +12, Dex +4, Con +6 | Neutre',
'llll', NULL, @tabc, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('archetype-lycanthrope-transformation-involontaire', 'Contrôle de forme : transformation involontaire',
'! Tâche | DD
Résister à une transformation involontaire | 25',
'lc', NULL, @tabc, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('archetype-lycanthrope-transformation-volontaire', 'Contrôle de forme : transformation volontaire',
'! Tâche | DD
Reprendre sa forme humanoïde (pleine lune*) | 25
Reprendre sa forme humanoïde (autre que pleine lune) | 20
Adopter sa forme hybride | 15
Transformation volontaire en forme animale (pleine lune) | 15
Transformation volontaire en forme animale (autre que pleine lune) | 20
> * Dans le cadre du jeu, on considère que la pleine lune dure trois nuits d''affilée, une fois par mois.',
'lc', NULL, @tabc, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('archetype-squelette-armure-naturelle', 'Armure naturelle du squelette',
'! Taille | Bonus d''armure naturelle
Très petite ou inférieure | +0
Petite | +1
Moyenne ou grande | +2
Très grande | +3
Gigantesque | +6
Colossale | +10',
'lc', NULL, @tabc, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('archetype-squelette-degats-griffes', 'Dégâts des griffes du squelette',
'! Taille | Dégâts
Infime ou minuscule | 1
Très petite | 1d2
Petite | 1d3
Moyenne | 1d4
Grande | 1d6
Très grande | 1d8
Gigantesque | 2d6
Colossale | 2d8',
'lc', NULL, @tabc, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('archetype-squelette-fp', 'Facteur de puissance du squelette',
'! Dés de vie | Facteur de puissance
1/2 | 1/6
1 | 1/3
2–3 | 1
4–5 | 2
6–7 | 3
8–9 | 4
10–11 | 5
12–14 | 6
15–17 | 7
18–20 | 8',
'cc', NULL, @tabc, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('archetype-vampire-degats-coup', 'Dégâts de l''attaque de coup du vampire',
'! Taille | Dégâts
Infime (I) | 1
Minuscule (Min) | 1d2
Très petite (TP) | 1d3
Petite (P) | 1d4
Moyenne (M) | 1d6
Grande (G) | 1d8
Très grande (TG) | 2d6
Gigantesque (Gig) | 2d8
Colossale (C) | 4d6',
'lc', NULL, @tabc, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('archetype-zombi-armure-naturelle', 'Armure naturelle du zombi',
'! Taille | Bonus d''armure naturelle
Très petite ou inférieure | +0
Petite | +1
Moyenne | +2
Grande | +3
Très grande | +4
Gigantesque | +7
Colossale | +11',
'lc', NULL, @tabc, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('archetype-zombi-degats-coup', 'Dégâts de l''attaque de coup du zombi',
'! Taille | Dégâts
Infime | 1
Minuscule | 1d2
Très petite | 1d3
Petite | 1d4
Moyenne | 1d6
Grande | 1d8
Très grande | 2d6
Gigantesque | 2d8
Colossale | 4d6',
'lc', NULL, @tabc, @ddver, @res, NULL, 0, 0, 1, @now, @now),
('archetype-zombi-fp', 'Facteur de puissance du zombi',
'! Dés de vie | Facteur de puissance
1/2 | 1/8
1 | 1/4
2 | 1/2
4 | 1
6 | 2
8–10 | 3
12–14 | 4
15–16 | 5
18–20 | 6',
'cc', NULL, @tabc, @ddver, @res, NULL, 0, 0, 1, @now, @now);

INSERT INTO dd_races (ra_nom, ra_rat_id, ra_description, ra_mod_niveau, ra_camp_id, ra_res_id, ra_public, ra_visible, ra_ruleset_var_id)
SELECT 'Demi-céleste', @rat,
'<p>L''archétype hérité « demi-céleste » peut être ajouté à n''importe quelle créature vivante et tangible, possédant au moins 4 en Intelligence et dont l''alignement est autre que mauvais (appelée ci-après « créature de base »). La créature céleste conserve le profil et les pouvoirs de la créature de base, exception faite de ce qui suit.</p>
<p><strong>Type et taille.</strong> Le demi-céleste fait automatiquement partie de la famille des Extérieurs. Il ne faut pas recalculer ses dés de vie et bonus de base à l''attaque et aux sauvegardes. Les demi-célestes sont par défaut des Extérieurs natifs. La taille est inchangée.</p>
<p><strong>Vitesse de déplacement.</strong> Le demi-céleste a des ailes de plumes. Il vole deux fois plus vite qu''il ne se déplace sur la terre ferme (bonne manœuvrabilité), ou à la vitesse de vol de la créature de base, si elle est plus élevée.</p>
<p><strong>Classe d''armure.</strong> L''armure naturelle de la créature de base augmente de +1.</p>
<p><strong>Attaques spéciales.</strong> Le demi-céleste conserve toutes les attaques spéciales de la créature de base et obtient les attaques suivantes.</p>
<p><strong>Châtiment du Mal (Sur).</strong> Une fois par jour, un demi-céleste peut porter une attaque de corps à corps normale avec un bonus sur le jet de dégâts égal à son nombre de DV (maximum +20), si la cible est d''alignement mauvais.</p>
<p><strong>Lumière du jour (Sur).</strong> Les demi-célestes peuvent employer ce pouvoir (identique au sort du même nom) à volonté.</p>
<p><strong>Pouvoirs magiques.</strong> S''il a au moins 8 en Intelligence ou en Sagesse, le demi-céleste peut également utiliser les pouvoirs magiques suivants, en fonction de son nombre de DV. Tous ces pouvoirs sont cumulables, et par exemple, un dragonnet d''airain demi-céleste (4 DV) peut employer bénédiction, protection contre le mal ainsi que aide et détection du Mal. Sauf indication contraire, chaque pouvoir est utilisable une fois par jour. Le niveau de lanceur de sorts est égal au nombre de DV de la créature et les DD de sauvegarde sont liés au Charisme.</p>
<p>[[tab:archetype-demi-celeste-pouvoirs-magiques]]</p>
<p><strong>Particularités.</strong> Le demi-céleste possède toutes les particularités de la créature de base plus les particularités suivantes.</p>
<ul>
<li>Vision dans le noir sur 18 mètres.</li>
<li>Immunité contre les maladies.</li>
<li>Résistance à l''acide, à l''électricité et au froid (10).</li>
<li>Réduction des dégâts de 5/magie si 11 DV ou moins, ou de 10/magie si 12 DV ou plus.</li>
<li>Les armes naturelles d''un demi-céleste sont considérées comme étant magiques pour ce qui est d''ignorer la réduction des dégâts.</li>
<li>Résistance à la magie égale au nombre de DV +10 (maximum 35).</li>
<li>Bonus racial de +4 sur les jets de sauvegarde contre le poison.</li>
</ul>
<p><strong>Caractéristiques.</strong> Comme la créature de base, en ajoutant les bonus suivants : For +4, Dex +2, Con +4, Int +2, Sag +4, Cha +4.</p>
<p><strong>Compétences.</strong> Le demi-céleste obtient des points de compétences comme un Extérieur, soit un total de (8 + modificateur d''Intelligence) x (nombre de DV +3). Les DV venant de niveaux de classes ne sont pas inclus dans ce calcul. Si le demi-céleste progresse dans une classe, il acquiert et dépense ses points de compétence normalement. Toutes les compétences apparaissant sur la liste de la créature de base sont considérées comme des compétences de classe, les autres étant des compétences hors classe.</p>
<p><strong>Facteur de puissance.</strong> Jusqu''à 5 DV, comme la créature de base +1 ; de 6 à 10 DV, comme la créature de base +2 ; à partir de 11 DV, comme la créature de base +3.</p>
<p><strong>Alignement.</strong> Toujours bon (loyal, neutre ou chaotique).</p>
<p><strong>Ajustement de niveau.</strong> Comme la créature de base +4.</p>',
4, NULL, @res, 0, 1, @ddver FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_races WHERE ra_nom = 'Demi-céleste' AND ra_res_id = @res AND ra_ruleset_var_id = @ddver);

INSERT INTO dd_races (ra_nom, ra_rat_id, ra_description, ra_mod_niveau, ra_camp_id, ra_res_id, ra_public, ra_visible, ra_ruleset_var_id)
SELECT 'Demi-fiélon', @rat,
'<p>L''archétype hérité « demi-fiélon » peut être ajouté à n''importe quelle créature vivante et tangible possédant au moins 4 en Intelligence et dont l''alignement est autre que bon (appelée ci-après « créature de base »). Une créature demi-fiélon conserve le profil et les pouvoirs de la créature de base, exception faite de ce qui suit.</p>
<p><strong>Type et taille.</strong> Le type du demi-fiélon devient automatiquement Extérieur. Il ne faut pas recalculer ses dés de vie et bonus de base à l''attaque et aux sauvegardes. Les demi-fiélons sont par défaut des Extérieurs natifs. La taille est inchangée.</p>
<p><strong>Vitesse de déplacement.</strong> Un demi-fiélon a des ailes de chauve-souris, et peut voler à sa vitesse de déplacement au sol (manœuvrabilité moyenne), ou à la vitesse de vol de la créature de base, si elle est plus élevée.</p>
<p><strong>Classe d''armure.</strong> L''armure naturelle de la créature de base augmente de +1.</p>
<p><strong>Attaques.</strong> Un demi-fiélon peut porter deux attaques de griffes et une attaque de morsure. Les griffes sont ses armes naturelles principales. Si la créature de base est capable de combattre à l''aide d''armes manufacturées, elle conserve cette capacité.</p>
<p>Lors d''une action d''attaque, un demi-fiélon utilise une arme s''il en est capable et un coup de griffes dans le cas contraire.</p>
<p>Lors d''une action d''attaque à outrance, l''attaque principale d''un demi-fiélon est portée avec une arme s''il en est capable et deux coups de griffes dans le cas contraire. Il peut ensuite mordre en tant qu''attaque secondaire. S''il utilise une arme mais garde une main libre, il peut porter une attaque de griffes en tant qu''attaque secondaire.</p>
<p><strong>Dégâts.</strong> Le demi-fiélon peut porter des attaques de griffes et de morsure. Si la créature de base est normalement incapable de se battre à l''aide de sa gueule ou de ses griffes, les dégâts qu''elle inflige sont indiqués sur la table ci-dessous. Par contre, si elle utilise déjà ces attaques en occasionnant des dégâts plus importants, conservez ses attaques normales.</p>
<p>[[tab:archetype-demi-fielon-degats]]</p>
<p><strong>Attaques spéciales.</strong> Le demi-fiélon conserve toutes les attaques spéciales de la créature de base, et obtient les suivantes.</p>
<p><strong>Châtiment du Bien (Sur).</strong> Une fois par jour, un demi-fiélon peut porter une attaque de corps à corps normale avec un bonus sur le jet de dégâts égal à son nombre de DV (maximum +20), si la cible est d''alignement bon.</p>
<p><strong>Pouvoirs magiques.</strong> S''il a au moins 8 en Intelligence ou en Sagesse, le demi-fiélon peut utiliser les pouvoirs magiques suivants, en fonction de son nombre de DV. Tous ces pouvoirs sont cumulables et, par exemple, un demi-fiélon ayant 4 DV peut employer ténèbres et profanation. Sauf indication contraire, chaque pouvoir est utilisable une fois par jour. Le niveau de lanceur de sorts est égal au nombre de DV de la créature et les DD de sauvegarde sont liés au Charisme.</p>
<p>[[tab:archetype-demi-fielon-pouvoirs-magiques]]</p>
<p><strong>Particularités.</strong> Le demi-fiélon possède toutes les particularités de la créature de base plus les particularités suivantes.</p>
<ul>
<li>Vision dans le noir sur 18 mètres.</li>
<li>Immunité contre le poison.</li>
<li>Résistance à l''acide, à l''électricité, au feu et au froid (10).</li>
<li>Réduction des dégâts de 5/magie si 11 DV ou moins, ou de 10/magie si 12 DV ou plus.</li>
<li>Les armes naturelles d''un demi-fiélon sont considérées comme étant magiques pour ce qui est d''ignorer la réduction des dégâts.</li>
<li>Résistance à la magie égale au nombre de DV +10 (maximum 35).</li>
</ul>
<p><strong>Caractéristiques.</strong> Comme la créature de base, en ajoutant les bonus suivants : For +4, Dex +4, Con +2, Int +4, Sag +0, Cha +2.</p>
<p><strong>Compétences.</strong> Le demi-fiélon obtient des points de compétences comme un Extérieur, soit un total de (8 + modificateur d''Intelligence) x (nombre de DV +3). Les DV venant de niveaux de classes ne sont pas inclus dans ce calcul. Si le demi-fiélon progresse dans une classe, il acquiert et dépense ses points de compétence normalement. Toutes les compétences apparaissant sur la liste de la créature de base sont considérées comme des compétences de classe, les autres étant des compétences hors classe.</p>
<p><strong>Environnement.</strong> Comme la créature de base ou le fiélon.</p>
<p><strong>Facteur de puissance.</strong> Jusqu''à 4 DV, comme la créature de base +1 ; de 5 à 10 DV, comme la créature de base +2 ; à partir de 11 DV, comme la créature de base +3.</p>
<p><strong>Alignement.</strong> Toujours mauvais (loyal, neutre ou chaotique).</p>
<p><strong>Ajustement de niveau.</strong> +4.</p>',
4, NULL, @res, 0, 1, @ddver FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_races WHERE ra_nom = 'Demi-fiélon' AND ra_res_id = @res AND ra_ruleset_var_id = @ddver);

INSERT INTO dd_races (ra_nom, ra_rat_id, ra_description, ra_mod_niveau, ra_camp_id, ra_res_id, ra_public, ra_visible, ra_ruleset_var_id)
SELECT 'Fantôme', @rat,
'<p>L''archétype acquis « fantôme » peut être associé à n''importe quelle créature appartenant à l''un des types suivants : aberration, animal, créature magique, dragon, géant, humanoïde, humanoïde monstrueux ou plante. La créature (appelée ci-après « créature de base ») doit avoir au moins 6 en Charisme.</p>
<p>Le fantôme conserve le profil et les pouvoirs de la créature de base, exception faite de ce qui suit.</p>
<p><strong>Taille et type.</strong> La créature change de type pour devenir un mort-vivant. Cependant, il ne faut pas recalculer son bonus de base à l''attaque et aux sauvegardes ou ses points de compétence. Elle prend le sous-type intangible. La taille est inchangée.</p>
<p><strong>Dés de vie.</strong> Tous les dés de vie actuels et futurs deviennent des d12.</p>
<p><strong>Vitesse de déplacement.</strong> Le fantôme acquiert une vitesse en vol de 9 mètres, sauf si la créature de base est capable de voler plus vite. Sa manœuvrabilité est parfaite.</p>
<p><strong>Classe d''armure.</strong> L''armure naturelle reste la même que celle de la créature de base, mais elle n''est prise en compte qu''en cas de combat dans le plan Éthéré. En cas de manifestation physique du fantôme (voir ci-dessous), sa valeur d''armure naturelle est égale à +0, mais il bénéficie d''un bonus de parade égal à son modificateur de Charisme (minimum +1).</p>
<p><strong>Attaques.</strong> Le fantôme conserve toutes les attaques de la créature de base, mais celles qui nécessitent un contact physique ne peuvent affecter que les adversaires éthérés.</p>
<p><strong>Dégâts.</strong> En cas de combat dans le plan Éthéré, le fantôme inflige les dégâts correspondant aux attaques naturelles de la créature de base. Contre les autres adversaires, il est incapable de se battre physiquement, mais peut utiliser ses attaques spéciales quand il se manifeste (voir ci-dessous).</p>
<p><strong>Attaques spéciales.</strong> Le fantôme conserve toutes les attaques spéciales de la créature de base, même si celles qui nécessitent un contact physique ne peuvent affecter que les adversaires éthérés. Il gagne également le pouvoir de manifestation et entre une et trois attaques spéciales parmi les suivantes. Sauf indication contraire, le DD du jet de sauvegarde accompagnant l''utilisation de ses pouvoirs est égal à 10 + 1/2 DV du fantôme + le modificateur de Charisme du fantôme.</p>
<p><strong>Aspect terrifiant (Sur).</strong> Toute créature vivante distante de 18 mètres ou moins et voyant le fantôme doit réussir un jet de Vigueur sous peine de subir immédiatement une diminution permanente de 1d4 points de Force, de 1d4 points de Dextérité et de 1d4 points de Constitution. Les créatures réussissant leur jet de sauvegarde ne peuvent plus être affectées par ce pouvoir du fantôme pendant une journée entière.</p>
<p><strong>Contact corrupteur (Sur).</strong> Lorsque le fantôme réussit une attaque de contact intangible sur une créature vivante, il lui inflige 1d6 points de dégâts. Contre les adversaires éthérés, il applique son modificateur de Force aux jets d''attaque et de dégâts. Contre un ennemi doté d''un corps physique, il applique son modificateur de Dextérité sur les jets d''attaque uniquement.</p>
<p><strong>Contact diminuant (Sur).</strong> Lorsque le fantôme réussit une attaque de contact intangible sur une créature vivante, il lui inflige une diminution permanente de 1d4 points d''une caractéristique de son choix. Chaque attaque réussie lui permet de guérir de 5 points de dégâts. Contre les adversaires éthérés, il applique son modificateur de Force aux jets d''attaque uniquement . Contre un ennemi doté d''un corps physique, il applique son modificateur de Dextérité sur les jets d''attaque uniquement.</p>
<p><strong>Lamentation d''épouvante (Sur).</strong> Le fantôme peut pousser un gémissement terrifiant dans le cadre d''une action simple. Toutes les créatures vivantes dans une étendue de 9 mètres de rayon doivent réussir un jet de Volonté pour ne pas céder à la panique pendant 2d4 rounds. C''est un effet de terreur, de son et mental, de type nécromancie. Les créatures réussissant leur jet de sauvegarde ne peuvent pas être affectées par les gémissements du fantôme pendant une journée entière.</p>
<p><strong>Manifestation (Sur).</strong> Tous les fantômes possèdent ce pouvoir. Ils vivent dans le plan Éthéré et étant des entités éthérées, ils ne peuvent affecter le monde matériel, ni être affectés par ce qui s''y trouve. Quand ils se manifestent, ils entrent partiellement dans le plan Matériel et deviennent visibles mais restent intangibles. Un fantôme manifesté peut uniquement être blessé par d''autres créatures intangibles, des armes magiques ou des sorts, mais toute attaque de source tangible a 50% de chances de ne lui infliger aucun dégât. Il peut passer à travers les objets solides et ses propres attaques passent à travers les armures. Un fantôme manifesté ne fait aucun bruit.</p>
<p>Dans cet état, il est possible aux fantômes d''attaquer physiquement à l''aide de son attaque de contact ou d''une arme spectrale (voir Équipement de fantôme, ci-dessous). Ils restent dans le plan Éthéré, où ils ne sont pas intangibles. Ils peuvent être attaqués par les créatures se trouvant dans le plan Matériel ou le plan Éthéré. Leur intangibilité les protège des attaques du plan Matériel, mais pas de celles venant du plan Éthéré. Quand un fantôme qui n''est pas manifesté lance un sort dans le plan Éthéré, sa magie reste sans effet contre les individus évoluant dans le plan Matériel ; par contre, elle affecte normalement ceux qui sont dans le plan Éthéré. Si le fantôme se manifeste, ses sorts continuent d''affecter les cibles se trouvant dans le plan Éthéré. Ils peuvent également affecter les créatures du plan Matériel, sauf dans le cas des sorts de contact (les sorts de contact d''un fantôme utilisant son pouvoir de manifestation ne fonctionnent pas contre les créatures dotées d''un corps physique).</p>
<p>Un fantôme est considéré comme étant originaire à la fois du plan Matériel et de plan Éthéré. Il ne prend pas le sous-type extraplanaire dans ces deux plans.</p>
<p><strong>Possession maléfique (Sur).</strong> Une fois par round, un fantôme éthéré peut tenter de fusionner avec une créature évoluant dans le plan Matériel. L''effet de ce pouvoir est similaire à celui du sort possession (niveau de lanceur de sorts égal à 10 ou au nombre de DV du fantôme, si celui-ci est plus élevé), si ce n''est qu''il ne nécessite pas le moindre réceptacle. Pour utiliser ce pouvoir, le fantôme doit avoir activé son pouvoir de manifestation et tenter de pénétrer dans l''espace occupé par sa cible. Ce déplacement ne provoque pas d''attaque d''opportunité. La victime a droit à un jet de Volonté (DD 15 + modificateur de Charisme du fantôme) pour résister à cette attaque. Si elle réussit son jet de sauvegarde, elle est immunisée contre le pouvoir de possession maléfique du fantôme pendant une journée entière. Si elle échoue, le fantôme disparaît dans le corps de sa cible.</p>
<p><strong>Regard corrupteur (Sur).</strong> D''un seul regard, le fantôme peut flétrir les chairs de toute créature vivante distante de 9 mètres ou moins. Quiconque croise le regard du mort-vivant doit réussir un jet de Vigueur pour ne pas encaisser 2d10 points de dégâts et subir une diminution permanente de 1d4 points de Charisme.</p>
<p><strong>Télékinésie (Sur).</strong> Le fantôme peut faire appel à ce pouvoir par une action simple (niveau de lanceur de sorts égal à 12 ou à son nombre de DV si celui-ci est plus élevé). Après avoir utilisé ce pouvoir, le fantôme doit attendre 1d4 rounds avant de s''en servir à nouveau.</p>
<p><strong>Particularités.</strong> Le fantôme conserve toutes les particularités de la créature de base, plus les suivantes.</p>
<p><strong>Reconstitution (Sur).</strong> Dans la plupart des cas, il est très difficile de détruire un fantôme au combat, pour la simple raison que le mort-vivant « détruit » se reconstitue presque toujours de lui-même au bout de 2d4 jours. Même les sorts les plus puissants n''offrent souvent qu''une solution temporaire. Un fantôme détruit revient au lieu qu''il hante s''il réussit un test de niveau (1d20 + nombre de DV du fantôme) de DD 16. La seule façon de se débarrasser définitivement d''un fantôme consiste à comprendre pourquoi il est là et à régler le problème qui l''empêche de trouver le repos. La raison de son existence et le moyen d''y mettre un terme varient avec chaque fantôme ; d''importantes recherches peuvent s''avérer nécessaires pour les découvrir.</p>
<p><strong>Résistance au renvoi des morts-vivants (Ext).</strong> Le fantôme bénéficie d''une résistance au renvoi de +4.</p>
<p><strong>Caractéristiques.</strong> Comme la créature de base, sauf que le fantôme n''a pas de valeur de Constitution et que sa valeur de Charisme augmente de +4.</p>
<p><strong>Compétences.</strong> Le fantôme bénéficie d''un bonus racial de +8 aux tests de Détection, Discrétion, Fouille et Perception auditive. Sinon, comme la créature de base.</p>
<p><strong>Environnement.</strong> Quelconque, souvent comme la créature de base.</p>
<p><strong>Organisation sociale.</strong> Solitaire, groupe (2–5) ou bande (7–12).</p>
<p><strong>Facteur de puissance.</strong> Comme la créature de base +2.</p>
<p><strong>Trésor.</strong> Aucun.</p>
<p><strong>Alignement.</strong> Quelconque.</p>
<p><strong>Ajustement de niveau.</strong> Comme la créature de base +5.</p>
<h4>Équipement de fantôme</h4>
<p>Quand un fantôme se forme, tout son équipement devient éthéré en même temps que lui. De plus, il conserve 2d4 objets qui étaient particulièrement importants pour lui de son vivant (à condition qu''ils ne soient pas entre les mains d''une autre créature). L''équipement fonctionne normalement dans le plan Éthéré. Par contre, dans le plan Matériel, il passe au travers des solides et des êtres de chair et de sang sans les affecter. Lorsque le fantôme est manifesté, les armes magiques bénéficiant d''un bonus au moins égal à +1 peuvent blesser les créatures matérielles, mais ont 50% de chances de n''infliger aucun dégât, de la même façon que le fantôme peut lui aussi être touché par les armes magiques.</p>
<p>Les objets restent à l''endroit où le fantôme est mort, de même que sa dépouille. Si une autre créature se saisit de l''un des objets, l''équivalent éthéré possédé par le fantôme disparaît aussitôt. Cela met invariablement le mort-vivant dans une rage folle, et il fait tout son possible pour récupérer l''objet (c''est-à-dire faire en sorte que le voleur le ramène où il l''a pris).</p>',
5, NULL, @res, 0, 1, @ddver FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_races WHERE ra_nom = 'Fantôme' AND ra_res_id = @res AND ra_ruleset_var_id = @ddver);

INSERT INTO dd_races (ra_nom, ra_rat_id, ra_description, ra_mod_niveau, ra_camp_id, ra_res_id, ra_public, ra_visible, ra_ruleset_var_id)
SELECT 'Liche', @rat,
'<p>L''archétype acquis « liche » peut être ajouté à n''importe quel humanoïde (appelé ci-après la « créature de base »), pour peu que ce dernier soit capable de créer le phylactère requis (voir plus bas). Il existe d''autres types de liches, comme les dragons, mais ils exploitent d''autres archétypes.</p>
<p>La liche conserve les caractéristiques et les pouvoirs spéciaux de la créature de base, exception faite de ce qui suit.</p>
<p><strong>Taille et type.</strong> Le type de la créature devient mort-vivant. Ne recalculez pas le bonus de base à l''attaque, les jets de sauvegarde et les points de compétence. La taille reste inchangée.</p>
<p><strong>Dés de vie.</strong> Les dés de vie actuels et à venir deviennent des d12.</p>
<p><strong>Classe d''armure.</strong> La liche acquiert un bonus d''armure naturelle de +5 (ou conserve l''armure naturelle du personnage si celle-ci est supérieure).</p>
<p><strong>Attaque.</strong> L''attaque de contact de la liche est utilisable 1 fois par round. Si la créature de base est capable de se servir d''armes, elle conserve cette capacité. Une créature dotée d''armes naturelles les conserve également. Une liche qui combat à mains nues compte sur son attaque de contact ou sur son arme naturelle principale (le cas échéant). Enfin, une liche armée utilise son attaque de contact ou l''arme en question, au choix.</p>
<p><strong>Attaque à outrance.</strong> Une liche qui combat à mains nues compte sur son attaque de contact (voir ci-dessus) ou sur ses armes naturelles (le cas échéant). Si elle est armée, elle utilise généralement son arme en guise d''attaque principale, son contact prenant la place d''attaque secondaire naturelle, du moins si elle a la possibilité de la porter (main libre ou arme naturelle utilisable dans le cadre d''une attaque secondaire).</p>
<p><strong>Dégâts.</strong> Si la liche ne possède pas d''attaque naturelle, elle gagne une attaque de contact qui exploite l''énergie négative pour infliger 1d8+5 points de dégâts aux créatures vivantes (un jet de Volonté, assorti d''un DD égal à 10 + 1/2 DV de la liche + son modificateur de Charisme, réduit ce total de moitié). Si elle possède des attaques naturelles, elle peut les utiliser ou se servir de celles du statut de liche, au choix. Si elle a recours a une arme naturelle, celle-ci inflige 1d8+5 points de dégâts supplémentaires.</p>
<p><strong>Attaques spéciales.</strong> La liche conserve toutes les attaques spéciales du personnage et gagne les suivantes. Sauf indication contraire, le DD des jets de sauvegarde est égal à 10 + 1/2 DV de la liche + son modificateur de Charisme.</p>
<p><strong>Aura de terreur (Sur).</strong> La liche est toujours entourée d''une aura de Mal et de mort. Toute créature de moins de 5 DV se trouvant dans un rayon de 18 mètres et regardant le mort-vivant doit réussir un jet de Volonté pour ne pas être affectée par l''équivalent du sort terreur, lancé comme par un ensorceleur du niveau de la liche. Si la créature réussit son jet de sauvegarde, l''aura de terreur de cette même liche ne peut plus l''affecter pendant 24 heures.</p>
<p><strong>Contact paralysant (Sur).</strong> Toute créature vivante touchée par l''attaque de contact de la liche doit réussir un jet de Vigueur pour ne pas se retrouver paralysée de façon permanente. Délivrance de la paralysie libère la victime, de même que tout sort permettant de se débarrasser d''une malédiction (voir le sort du même nom). L''effet de ce pouvoir ne peut pas être dissipé. Toute créature paralysée par une liche semble morte, mais un test de Détection (DD 20) ou de Premiers secours (DD 15) réussi révèle qu''elle respire encore.</p>
<p><strong>Sorts.</strong> La liche peut lancer les mêmes sorts que de son vivant.</p>
<p><strong>Particularités.</strong> La liche conserve toutes les particularités de la créature de base, auxquelles viennent s''ajouter les suivantes.</p>
<p><strong>Immunités (Ext).</strong> La liche est immunisée contre le froid, l''électricité, la métamorphose (bien qu''elle puisse en user sur elle-même) et les effets mentaux.</p>
<p><strong>Réduction des dégâts (Sur).</strong> Le corps de ce mort-vivant est particulièrement résistant, ce qui lui confère une réduction des dégâts de (15/contondant et magie). Ses armes naturelles sont considérées comme des armes magiques pour ce qui est de vaincre la réduction des dégâts de ses adversaires.</p>
<p><strong>Résistance au renvoi des morts-vivants (Ext).</strong> La liche bénéficie d''une résistance de +4 au renvoi des morts-vivants.</p>
<p><strong>Caractéristiques.</strong> La liche gagne les bonus suivants : Int +2, Sag +2 et Cha +2. Comme tous les morts-vivants, elle n''a pas de valeur de Constitution.</p>
<p><strong>Compétences.</strong> Elle bénéficie d''un bonus racial de +8 aux tests de Déplacement silencieux, Détection, Discrétion, Fouille, Perception auditive et Psychologie. Sinon, comme la créature de base.</p>
<p><strong>Organisation sociale.</strong> Solitaire ou groupe mixte (1 liche, 2–4 vampires et 5–8 vampiriens).</p>
<p><strong>Facteur de puissance.</strong> Comme la créature de base +2.</p>
<p><strong>Trésor.</strong> Pièces normales, biens précieux normaux (x2), objets normaux (x2).</p>
<p><strong>Alignement.</strong> Toujours mauvais.</p>
<p><strong>Évolution possible.</strong> Par une classe de personnage.</p>
<p><strong>Ajustement de niveau.</strong> Comme la créature de base +4.</p>
<h4>Personnages liches</h4>
<p>La transformation en liche est totalement malfaisante et ne peut être effectuée qu''avec l''accord du sujet. Le personnage conserve les pouvoirs et aptitudes de classe qui étaient les siens de son vivant.</p>
<h4>Le phylactère</h4>
<p>Le processus de transformation en liche nécessite la fabrication d''un phylactère magique à l''intérieur duquel le mort-vivant conservera son énergie vitale. Tant que le phylactère n''a pas été localisé et détruit, la liche revient à son semblant de vie 1d10 jours après sa mort apparente.</p>
<p>Chaque liche doit fabriquer son propre phylactère, ce qui requiert le don Création d''objets merveilleux. Le personnage doit être un lanceur de sorts de niveau 11 ou plus. La fabrication du phylactère coûte 120 000 po et nécessite le sacrifice de 4 800 PX. Une fois achevé, l''objet a un niveau de lanceur de sorts égal au niveau de son créateur (au moment où il a été fabriqué).</p>
<p>Le plus souvent, le phylactère prend la forme d''une boîte métallique au couvercle scellé contenant des bandelettes de papier sur lesquelles ont été transcrites des incantations magiques. Les caractéristiques du phylactère sont les suivantes : taille TP, 20 en solidité, 40 points de résistance, DD de 40 pour le casser. Certaines liches préfèrent conserver leur énergie vitale dans un anneau, une amulette ou un autre objet similaire, qui prend également le nom de phylactère.</p>',
4, NULL, @res, 0, 1, @ddver FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_races WHERE ra_nom = 'Liche' AND ra_res_id = @res AND ra_ruleset_var_id = @ddver);

INSERT INTO dd_races (ra_nom, ra_rat_id, ra_description, ra_mod_niveau, ra_camp_id, ra_res_id, ra_public, ra_visible, ra_ruleset_var_id)
SELECT 'Lycanthrope', @rat,
'<p>L''archétype « lycanthrope » peut être ajouté à n''importe quel humanoïde ou géant (appelé ci-après le « personnage »). L''archétype peut être hérité (lycanthropes naturels) ou acquis (lycanthropes infectés). Devenir un lycanthrope revient en quelque sorte à se multiclasser en animal en gagnant les dés de vie correspondants.</p>
<p><strong>Taille et type.</strong> Le type du personnage ne change pas, mais il acquiert le sous-type métamorphe. Le lycanthrope possède les caractéristiques d''un animal carnivore ou omnivore selon le type de ce dernier (appelé ci-après « animal »). Il peut s''agit d''un prédateur, d''un charognard ou d''un omnivore dont la taille est comprise entre moins une et plus une catégorie de celle du personnage (taille P, M ou G pour un personnage de taille M). Les lycanthropes ont la possibilité de prendre une forme hybride, combinant certains aspects du personnage et de l''animal. La taille de l''hybride est égale à celle du personnage ou de l''animal (choisir la plus grande). Le lycanthrope profite des pouvoirs spéciaux du personnage ou de l''animal en plus de ceux qui sont décrits ci-dessous.</p>
<p><strong>Dés de vie et points de vie.</strong> Somme de ceux du personnage et de l''animal. Pour calculer le total des points de vie, appliquez les modificateurs de Constitution propres à chaque forme. Par exemple, un homme du peuple de niveau 1 doté d''une Constitution de 11 en tant qu''humain, et de 15 en tant que loup, a 1d4 plus 2d8+4 points de vie.</p>
<p><strong>Vitesse de déplacement.</strong> Comme le personnage ou l''animal, selon la forme choisie par le lycanthrope. Les hybrides exploitent la vitesse de déplacement de base du personnage.</p>
<p><strong>Classe d''armure.</strong> Le bonus d''armure naturelle du personnage augmente de +2 sous toutes les formes. Sous forme hybride, il est égal au bonus d''armure naturelle de l''animal ou du personnage (choisir le plus élevé).</p>
<p><strong>Attaque de base/lutte.</strong> Ajoutez le bonus de base à l''attaque de l''animal à celui du personnage. Le bonus de lutte du lycanthrope est égal à son bonus à l''attaque, sans oublier les modificateurs de For et de taille, selon la forme adoptée.</p>
<p><strong>Attaques.</strong> Comme le personnage ou l''animal, selon la forme choisie. Sous forme hybride, le lycanthrope gagne deux attaques de griffes et une autre de morsure (il s''agit d''armes naturelles). Le montant des dégâts infligés dépend de la taille de l''hybride. Il peut mordre et attaquer à l''aide d''une arme, ou attaquer avec ses armes naturelles. Sa morsure est une attaque secondaire.</p>
<p>[[tab:archetype-lycanthrope-attaques-hybride]]</p>
<p><strong>Dégâts.</strong> Comme le personnage ou l''animal, selon la forme choisie.</p>
<p><strong>Attaques spéciales.</strong> Le lycanthrope conserve toutes les attaques spéciales du personnage ou de l''animal, selon la forme choisie. Dans le même temps, il gagne celle qui est décrite ci-dessous.</p>
<p>La forme hybride ne bénéficie pas des attaques spéciales de l''animal. Un lanceur de sorts est incapable de lancer le moindre effet affublé de composantes verbales, gestuelles ou matérielles sous forme animale (cela vaut également pour les sorts à composantes verbales sous forme hybride).</p>
<p><strong>Transmission de lycanthropie (Sur).</strong> Tout humanoïde ou géant mordu par un lycanthrope sous forme animale ou hybride doit réussir un jet de Vigueur (DD 15) sous peine de contracter à son tour la lycanthropie. Si la taille de la victime ne s''inscrit pas dans une fourchette d''une catégorie (en plus ou en moins) de celle du lycanthrope (par exemple, un géant des collines mordu par un rat-garou), elle ne contracte pas la maladie. Les lycanthropes infectés sont incapables de transmettre ce mal.</p>
<p><strong>Particularités.</strong> Le lycanthrope conserve toutes les particularités du personnage et de l''animal. Il acquiert également les suivantes :</p>
<p><strong>Empathie lycanthropique (Ext).</strong> Tout lycanthrope peut communiquer avec les animaux (sanguinaires ou non) de son espèce ; il sait également ce qu''ils ressentent. Cela lui confère un bonus racial de +4 aux tests visant à influencer l''attitude de ces animaux, tout en lui permettant de communiquer des concepts simples (« fuis », « attaque », « ami », « ennemi », etc.) à ceux qui se montrent amicaux envers lui.</p>
<p><strong>Odorat (Ext).</strong> Un lycanthrope dispose du pouvoir d''odorat sous toutes les formes.</p>
<p><strong>Réduction des dégâts (Ext).</strong> Sous forme animale ou hybride, un lycanthrope infecté bénéficie d''une réduction des dégâts (5/argent). De son côté, un lycanthrope naturel sous forme animale ou hybride bénéficie d''une réduction des dégâts (10/argent).</p>
<p><strong>Transformation (Sur).</strong> Tout lycanthrope peut se transformer en animal comme s''il employait le sort métamorphose (son équipement ne se transforme pas avec lui, la transformation ne lui restitue aucun point de vie et il ne peut adopter que sa forme animale). Il ajoute alors les modificateurs aux valeurs de caractéristique de l''animal à ses propres valeurs de caractéristique. Il peut également prendre une forme hybride, celle d''une créature bipède dotée de main préhensiles et aux traits animaux.</p>
<p>La transformation en forme animale ou hybride constitue une action simple. Un lycanthrope mort reprend automatiquement son apparence humaine, mais cela ne le ramène pas à la vie pour autant. Par contre, les membres tranchés restent sous forme animale. Pour les lycanthropes infectés, cette faculté de transformation est parfois difficile à contrôler (voir La lycanthropie en tant que maladie, plus loin). Par contre, les lycanthropes naturels la contrôlent parfaitement.</p>
<p><strong>Vision nocturne (Ext).</strong> Un lycanthrope dispose de la vision nocturne sous toutes les formes.</p>
<p><strong>Bonus de base aux sauvegardes.</strong> Ajoutez les bonus de base aux sauvegardes de l''animal à ceux du personnage.</p>
<p><strong>Caractéristiques.</strong> Tous les lycanthropes bénéficient de +2 en Sagesse. Sous forme animale ou hybride, les caractéristiques physiques s''améliorent en fonction de l''espèce de lycanthrope, comme indiqué dans la table ci-dessous. Ces ajustements sont égaux aux valeurs de caractéristique normales de l''animal, –10 ou –11. Par exemple, un crocodile-garou (For 19, Dex 12, Con 17) bénéficiera de +8 en For, +2 en Dex et +6 en Con sous forme de crocodile. Sous forme hybride, le lycanthrope modifie ses valeurs de caractéristique de la même façon. Enfin, la créature peut bénéficier d''une autre augmentation de caractéristique grâce à ses dés de vie supplémentaires.</p>
<p><strong>Compétences.</strong> Un lycanthrope gagne un nombre de points de compétence égal à (2 + modificateur d''Int, 1 minimum) par dé de vie de forme animale, comme s''il s''était multiclassé en cet animal (par contre, il ne s''agit pas d''un premier DV et il ne bénéficie pas de quatre fois le nombre de points de compétence).Toutes les compétences qui apparaissent dans la description de l''animal sont des compétences de classe pour le lycanthrope. Quelle que soit sa forme, il bénéficie également des bonus de compétence raciaux du personnage et de l''animal. Cependant, les bonus de compétence soumis à condition, comme le bonus de camouflage du tigre-garou aux tests de Discrétion, ne s''applique que sous la forme associée.</p>
<p><strong>Dons.</strong> Ajoutez les dons de l''animal à ceux du personnage. Si le lycanthrope a deux fois le même don, il ne tire avantage du deuxième que s''il s''agit d''un don qu''on peut choisir plusieurs fois (reportez-vous alors à la description de ce don). Du coup, il risque d''avoir plus de dons que ses dés de vie ne devraient normalement lui en autoriser. Dans ce cas, les dons additionnels sont notés comme des dons supplémentaires.</p>
<p>Il est possible qu''un lycanthrope ne satisfasse pas aux conditions d''un don sous forme humanoïde. Dans ce cas, il le possède mais ne peut pas s''en servir sous cette forme. Tous les lycanthropes reçoivent Volonté de fer en qualité de son supplémentaire.</p>
<p><strong>Environnement.</strong> Comme le personnage ou l''animal.</p>
<p><strong>Organisation sociale.</strong> Solitaire ou couple, parfois famille (2–4), meute (6–10) ou groupe (famille plus animaux de la même espèce).</p>
<p><strong>Facteur de puissance.</strong> Selon le niveau de classe ou le personnage, modifié selon les DV de l''animal : 1 DV ou 2 DV, +2 ; 3 DV à 5 DV, +3 ; 6 DV à 10 DV, +4 ; 11 DV à 20 DV, +5 ; 21 DV ou plus, +6.</p>
<p><strong>Trésor.</strong> Normal.</p>
<p><strong>Alignement.</strong> Au choix. Les nobles créatures comme les ours, les aigles et les lions produisent généralement des lycanthropes bons. Les créatures sinistres comme les rats, les serpents et les loups donnent des lycanthropes mauvais. Cela illustre la façon dont on voit ces animaux, pas leurs qualités intrinsèques.</p>
<p><strong>Évolution possible.</strong> Par une classe de personnage.</p>
<p><strong>Ajustement de niveau.</strong> Comme le personnage +2 (infecté) ou +3 (naturel). En outre, on augmente le niveau de personnage d''un lycanthrope d''un nombre égal aux dés de vie raciaux de l''animal.</p>
<h4>Lycanthropes courants</h4>
<p>[[tab:archetype-lycanthropes-courants]]</p>
<h4>La lycanthropie en tant que maladie</h4>
<p>Quand un personnage contracte la lycanthropie en étant mordu par un lycanthrope (voir ci-dessus), aucun symptôme n''apparaît avant la pleine lune suivante. À ce moment, le personnage infecté prend involontairement sa forme animale et devient une bête affamée oubliant jusqu''à sa propre identité (il devient temporairement un PNJ). Il reste sous cette forme jusqu''à l''aube, en prenant l''alignement correspondant à l''espèce de lycanthrope. Durant ce premier épisode, les action du personnages sont dictées par l''alignement de sa forme animale. Le personnage ne se souvient ensuite de rien, sauf s''il réussit un test de Sagesse (DD 15), auquel cas il prend conscience de sa condition de lycanthrope.</p>
<p>Par la suite, le personnage risque de se transformer involontairement chaque fois que la pleine lune se lève, mais aussi quand il subit des blessures au combat. Dans ce cas, il se sent pris d''une violente colère, et seul un test de Contrôle de forme (voir ci-dessous) réussi lui permet d''empêcher la métamorphose. Un personnage joueur qui n''est pas conscient de sa condition de lycanthrope devient temporairement un PNJ lors de ses transformations involontaires. Il agit tel que cela est décrit ci-dessus, selon l''alignement de sa forme animale.</p>
<p>Un personnage qui est conscient de sa condition conserve son identité et ne perd pas le contrôle de ses actes en cas de transformation. Cependant, chaque fois qu''il adopte sa forme animale, il doit réussir un jet de Volonté (DD 15 + nombre de fois où il a pris cette forme) ou être à jamais affublé de l''alignement de celle-ci, sous toutes ses formes.</p>
<p>Dès lors que le personnage est conscient du mal qui le ronge, il peut volontairement adopter sa forme animale ou hybride (voir Contrôle de forme). La tentative se fait au prix d''une action simple et on peut la répéter chaque round. Ce type de changement volontaire confère sur-le-champ et à jamais l''alignement propre au lycanthrope.</p>
<h4>Changement de forme</h4>
<p>On change de forme au prix d''une action simple. Si la transformation est involontaire, elle a lieu au tour suivant l''apparition du facteur déclencheur. Une transformation involontaire en forme animale ou hybride détruit les vêtements et l''armure du personnage (ainsi que les objets portés) si la nouvelle forme est plus imposante que l''ancienne ; les objets tenus en main tombent simplement au sol. Il est possible de se débarrasser rapidement de ses habits en cours de métamorphose, mais pas de l''armure. Une armure magique résiste au choc si elle réussit un jet de Vigueur (DD 15). Un personnage infecté qui n''est pas au courant de sa condition reste sous forme animale jusqu''à l''aube suivante. S''il est conscient de son état (voir ci-dessus), il peut essayer de se retransformer en humanoïde suite à une transformation (volontaire ou non) via un test de Contrôle de forme. En cas d''échec, il reste sous forme animale (ou hybride) jusqu''à l''aube suivante.</p>
<h4>Guérison de la lycanthropie</h4>
<p>Un personnage infecté mâchant quelques feuilles de belladone (ou d''aconit) moins de 1 heure après avoir été blessé par un lycanthrope a droit à un jet de Vigueur (DD 20) pour empêcher le mal de s''installer. Si la plante est administrée par un guérisseur, utilisez le nombre le plus favorable entre le bonus au jet de sauvegarde du personnage et le modificateur de Premiers secours de celui qui l''aide. Quelle que soit la quantité de belladone qu''il ingère, le personnage n''a droit qu''à une seule chance. La plante doit être raisonnablement fraîche (cueillie depuis moins d''une semaine).</p>
<p>Cependant, fraîche ou non, la belladone est toxique. Le personnage doit réussir un test de Vigueur (DD 13) ou subir un affaiblissement temporaire de 1d6 points de Force. Une minute plus tard, il doit réussir un second jet de Vigueur (DD 13) ou subir un nouvel affaiblissement temporaire de Force, mais de 2d6 points.</p>
<p>Les sorts guérison des maladies ou guérison suprême soignent également la lycanthropie, pour peu qu''ils soient lancés par un prêtre de niveau 12 ou plus et que le sujet en bénéficie dans les trois jours suivant l''infection. Un autre moyen de contrer la lycanthropie consiste à jeter délivrance des malédictions ou annulation d''enchantement sur le personnage lors d''un des trois jours de pleine lune. Une fois le sort lancé, le personnage infecté doit réussir un jet de Volonté (DD 20), le jeteur de sorts sachant automatiquement si sa tentative a été couronnée de succès. En cas d''échec, il ne reste plus qu''à recommencer. Il n''est pas rare que le sujet soit ligoté ou enfermé dans une cage jusqu''à ce que le prêtre parvienne à le soigner.</p>
<p>Seuls les lycanthropes infectés peuvent être soignés ; chez ceux qui l''acquièrent à la naissance, la lycanthropie est permanente.</p>
<h4>Personnages lycanthropes</h4>
<p>Le fait de devenir lycanthrope ne change en rien la classe de prédilection du personnage. Par contre, son alignement peut s''en trouver modifié (voir ci-dessus). Ce changement d''alignement peut expliquer que certaines classes de personnage perdent leurs aptitudes et pouvoirs.</p>
<p>Voici les traits raciaux des personnages lycanthropes :</p>
<ul>
<li>+2 en Sagesse. Les caractéristiques physiques augmentent selon les modificateurs de la forme animale lorsque le lycanthrope passe de sa forme humanoïde à une autre.</li>
<li>Taille identique à celle du personnage ou de l''animal.</li>
<li>Vision nocturne sous toutes les formes.</li>
<li>Odorat sous toutes les formes.</li>
<li><strong>Dés de vie raciaux.</strong> Un lycanthrope ajoute les dés de vie de sa forme animale aux dés de vie découlant de sa race, de son niveau et de sa classe. Ces dés de vie supplémentaires modifient en conséquence le bonus de base à l''attaque et les bonus aux sauvegardes de la créature.</li>
<li><strong>Compétences raciales.</strong> Un lycanthrope ajoute des points de compétence découlant de ses dés de vie d''animal, comme s''il était multiclassé en ce type d''animal. Il gagne un nombre de points de compétence égal à (2 + modificateur d''Int, minimum 1) par dé de vie de forme animale. Les compétences qui apparaissent dans la description de l''animal sont traitées comme des compétences de classe. Le nombre maximal de degrés de maîtrise est égal aux dés de vie de la forme animale + ses dés de vie raciaux (le cas échéant) + ses niveaux de classe +3. Les ajustements de compétence raciaux de la race de base et de la forme animale du lycanthrope (ce qui n''inclut pas les ajustements particuliers) sont ajoutés à ses modificateurs de compétence, quelle que soit la forme adoptée.</li>
<li><strong>Dons raciaux.</strong> Ajoutez les dés de vie de l''animal à ceux du personnage pour déterminer le nombre de dons qu''il possède. Tous les lycanthropes bénéficient de Volonté de fer en qualité de don supplémentaire.</li>
<li>Bonus d''armure naturelle de +2 sous toutes les formes.</li>
<li><strong>Attaques spéciales (voir ci-dessus).</strong> Transmission de lycanthropie (sous forme animale ou hybride uniquement)</li>
<li><strong>Particularités (voir ci-dessus).</strong> Empathie lycanthropique, transformation.</li>
<li><strong>Lycanthrope infecté.</strong> Réduction des dégâts (5/argent), sous forme animale ou hybride uniquement.</li>
<li><strong>Lycanthrope naturel.</strong> Réduction des dégâts (10/argent), sous forme animale ou hybride uniquement.</li>
<li><strong>Langues.</strong> D''office : comme le personnage.</li>
<li><strong>Classe de prédilection.</strong> Comme le personnage.</li>
<li><strong>Ajustement de niveau.</strong> Comme le personnage +2 (infecté) ou +3 (naturel).</li>
</ul>
<p><strong>Contrôle de forme (Sag).</strong> Tout personnage ayant contracté la lycanthropie et étant conscient de son état a la possibilité d''apprendre la compétence Contrôle de forme comme une compétence de classe. (Un personnage infecté qui n''est pas au fait de sa condition peut tenter d''effectuer des tests de Contrôle de forme innés.) Celle-ci détermine si le personnage parvient à contrôler son apparence, et donc à prévenir un changement de forme intempestif. Les lycanthropes naturels n''ont pas besoin de cette compétence car ils contrôlent pleinement leur transformation.</p>
<p><strong>Test de compétence (transformation involontaire).</strong> Le personnage infecté doit effectuer un test de compétence chaque fois que la pleine lune se lève, sous peine d''adopter involontairement sa forme animale. Il lui faut également effectuer un test de Contrôle de forme si ses blessures lui font perdre un quart de ses points de vie (puis un autre encore s''il perd la moitié de ses points de vie, et un de plus s''il en perd les trois quarts).</p>
<p>[[tab:archetype-lycanthrope-transformation-involontaire]]</p>
<p>En cas d''échec, le personnage reste sous forme animale jusqu''à l''aube suivante (il recouvre alors sa forme de base). Un personnage conscient de son état a le droit d''effectuer un test pour recouvrer sa forme humanoïde (voir ci-dessous). Là encore, il conserve sa forme animale jusqu''à l''aube suivante en cas d''échec.</p>
<p><strong>Nouvelles tentatives (transformation involontaire).</strong> Effectuez un test de compétence chaque fois qu''un événement déclencheur se produit.</p>
<p><strong>Test de compétence (transformation volontaire).</strong> Un personnage infecté conscient de son état peut user de cette compétence de son plein gré pour adopter sa forme animale ou hybride, ou encore pour recouvrer sa forme humanoïde, quels que soient ses blessures ou l''aspect de la lune.</p>
<p>[[tab:archetype-lycanthrope-transformation-volontaire]]</p>
<p><strong>Nouvelles tentatives (transformation volontaire).</strong> Un personnage peut tenter d''adopter sa forme animale ou hybride aussi souvent qu''il le souhaite (action simple). Cependant, s''il rate son test de compétence pour reprendre forme humanoïde, il doit rester sous forme animale ou hybride jusqu''à l''aube. À ce moment, il reprend automatiquement son aspect normal.</p>
<p><strong>Spécial.</strong> Un lycanthrope infecté ne peut tenter de transformation volontaire s''il n''est pas conscient de son état.</p>',
2, NULL, @res, 0, 1, @ddver FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_races WHERE ra_nom = 'Lycanthrope' AND ra_res_id = @res AND ra_ruleset_var_id = @ddver);

INSERT INTO dd_races (ra_nom, ra_rat_id, ra_description, ra_mod_niveau, ra_camp_id, ra_res_id, ra_public, ra_visible, ra_ruleset_var_id)
SELECT 'Squelette', @rat,
'<p>L''archétype acquis « squelette » peut être ajouté à n''importe quelle créature tangible (appelée ci-après la « créature de base »), pour peu qu''elle soit dotée d''un squelette et qu''il ne s''agisse pas d''un mort-vivant.</p>
<p><strong>Taille et type.</strong> Le type de la créature devient mort-vivant. Il conserve tout sous-type qu''il possède déjà, sauf si celui-ci relève d''un alignement (Bien, par exemple) ou d''une espèce (comme gobelinoïde ou reptilien). Il n''acquiert pas le sous-type altéré. Sauf indication contraire, il conserve les caractéristiques et pouvoirs spéciaux de la créature de base.</p>
<p><strong>Dés de vie.</strong> Débarrassez-vous des dés de vie issus de niveaux de classe (mais gardez 1 DV minimum) et transformez ceux qui restent en d12. Si la créature de base a plus de 20 dés de vie, le sort animation des morts ne permet pas d''en faire un squelette.</p>
<p><strong>Vitesse de déplacement.</strong> Les squelettes dotés d''ailes sont incapables de voler. Par contre, si la créature de base disposait d''un moyen magique de voler, le squelette peut en faire autant.</p>
<p><strong>Classe d''armure.</strong> Le bonus d''armure naturelle change selon la taille du squelette.</p>
<p>[[tab:archetype-squelette-armure-naturelle]]</p>
<p><strong>Attaques.</strong> Un squelette conserve les armes naturelles, attaques à l''aide d''armes et formations martiales de la créature de base, sauf si elles exigent la présence de chair (comme, par exemple, les tentacules d''un flagelleur mental). Une créature dotée de membres acquiert une attaque de griffes par main ; il peut user de chacune d''elle à son bonus d''attaque maximal. Enfin, le bonus de base à l''attaque d''un squelette est égal à la moitié de ses dés de vie.</p>
<p><strong>Dégâts.</strong> Les armes (naturelles ou non) infligent des dégâts normaux. Une attaque de griffes inflige des dégâts selon la taille du squelette. (Si la créature de base disposait déjà de griffes, utilisez les dégâts de celles du squelette s''ils sont plus élevés unqiuement.)</p>
<p>[[tab:archetype-squelette-degats-griffes]]</p>
<p><strong>Attaques spéciales.</strong> Un squelette ne conserve aucune des attaques spéciales de la créature de base.</p>
<p><strong>Particularités.</strong> Un squelette perd la plupart des particularités de la créature de base. Il conserve les particularités extraordinaires relevant d''attaques au corps à corps ou à distance. En outre, il gagne les suivantes :</p>
<p><strong>Immunité contre le froid (Ext).</strong> Les squelettes ne sont pas affectés par le froid.</p>
<p><strong>Réduction des dégâts (5/contondant).</strong> Les squelettes sont dénués de chair ou d''organes internes.</p>
<p><strong>Jets de sauvegarde.</strong> Bonus de base aux sauvegardes : Réf +1/3 DV, Vig +1/3 DV et Vol 1/2 DV + 2.</p>
<p><strong>Caractéristiques.</strong> La Dextérité d''un squelette augmente de +2, il n''a pas de valeurs de Constitution et d''Intelligence, sa Sagesse passe à 10 et son Charisme passe à 1.</p>
<p><strong>Compétences.</strong> Un squelette n''a pas de compétences.</p>
<p><strong>Dons.</strong> Un squelette perd tous les dons de la créature de base et acquiert Science de l''initiative.</p>
<p><strong>Environnement.</strong> Quelconque, généralement le même que la créature de base.</p>
<p><strong>Organisation sociale.</strong> Quelconque.</p>
<p><strong>Facteur de puissance.</strong> Selon les dés de vie, comme suit :</p>
<p>[[tab:archetype-squelette-fp]]</p>
<p><strong>Trésor.</strong> Aucun.</p>
<p><strong>Alignement.</strong> Toujours neutre mauvais.</p>
<p><strong>Évolution possible.</strong> Comme la créature de base (ou « — » si celle-ci évolue par une classe de personnage).</p>
<p><strong>Ajustement de niveau.</strong> —.</p>',
0, NULL, @res, 0, 1, @ddver FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_races WHERE ra_nom = 'Squelette' AND ra_res_id = @res AND ra_ruleset_var_id = @ddver);

INSERT INTO dd_races (ra_nom, ra_rat_id, ra_description, ra_mod_niveau, ra_camp_id, ra_res_id, ra_public, ra_visible, ra_ruleset_var_id)
SELECT 'Vampire', @rat,
'<p>L''archétype « vampire » peut être ajouté à n''importe quel humanoïde ou humanoïde monstrueux (appelé ci-après « créature de base »).</p>
<p>Le vampire conserve le profil et les pouvoirs spéciaux de la créature de base, exception faite de ce qui suit.</p>
<p><strong>Taille et type.</strong> Son type devient automatiquement mort-vivant (humanoïde altéré ou humanoïde monstrueux altéré). Ne recalculez pas le bonus de base à l''attaque, les sauvegardes et les points de compétence. La taille ne change pas.</p>
<p><strong>Dés de vie.</strong> Tous les dés de vie passés et à venir deviennent des d12.</p>
<p><strong>Vitesse de déplacement.</strong> Comme la créature de base. Si celle-ci est dotée d''une vitesse de déplacement à la nage, le vampire la conserve et n''est pas vulnérable à l''immersion dans les cours d''eau (voir plus loin).</p>
<p><strong>Classe d''armure.</strong> Le bonus d''armure naturelle de la créature de base augmente de +6.</p>
<p><strong>Attaque.</strong> Le vampire conserve toutes les attaques de la créature de base et gagne une attaque de coup si la créature de base n''en disposait pas. Si cette dernière était capable d''utiliser des armes, le vampire l''est également. Si elle était dotée d''armes naturelles, le vampire les conserve également. Un vampire dépourvu d''arme exploite son attaque de coup ou son arme naturelle principale (le cas échéant). S''il est armé, il utilise son attaque de coup ou son arme, au choix.</p>
<p><strong>Attaque à outrance.</strong> Un vampire dépourvu d''arme utilise son attaque de coup (voir ci-dessus) ou ses armes naturelles (le cas échéant). S''il possède une arme, il exploite celle-ci (attaque principale) et un coup ou quelque autre arme naturelle (attaque secondaire)</p>
<p><strong>Dégâts.</strong> Le vampire est capable d''asséner de terribles coups. Si la créature de base ne possède pas ce mode d''attaque, le mort-vivant inflige des dégâts correspondant à sa taille, comme indiqué ci-dessous. Par contre, si la créature de base possédait cette attaque et causait des dégâts plus importants, elle la conserve.</p>
<p>[[tab:archetype-vampire-degats-coup]]</p>
<p><strong>Attaques spéciales.</strong> Le vampire conserve toutes les attaques spéciales de la créature de base et gagne les suivantes. Sauf indication contraire, le DD assorti aux jets de sauvegarde est égal à 10 + 1/2 DV du vampire + son modificateur de Charisme.</p>
<p><strong>Absorption d''énergie (Sur).</strong> Tout être vivant touché par l''attaque de coup (ou quelque autre arme naturelle) d''un vampire acquiert 2 niveaux négatifs. Pour chaque niveau ainsi conféré, le vampire gagne 5 points de vie temporaires. Ce pouvoir est utilisable 1 fois par round.</p>
<p><strong>Absorption de sang (Ext).</strong> Le vampire peut sucer le sang d''une créature vivante en réussissant un test de lutte pour planter ses crocs dans sa gorge. S''il réussit à immobiliser son adversaire, il lui vole son fluide vital, ce qui se traduit par une diminution permanente de 1d4 points de Constitution chaque round où sa victime reste immobilisée. Chaque fois qu''il réussit cette attaque, le vampire gagne 5 points de vie temporaires.</p>
<p><strong>Création de rejetons (Sur).</strong> Tout humanoïde ou humanoïde monstrueux tué par le pouvoir d''absorption d''énergie d''un vampire revient à la vie sous forme de vampirien 1d4 jours après avoir été mis en terre.</p>
<p>Si le vampire fait tomber la Constitution de sa victime à 0 ou moins, celle-ci revient à la vie sous forme de vampirien si elle a 4 DV ou moins, ou sous forme de vampire si elle a 5 DV ou plus. Dans tous les cas, le vampirien ou le vampire nouvellement créé reste l''esclave de son créateur jusqu''à la destruction de ce dernier. Le nombre maximum d''esclaves dont le vampire peut disposer est égale à deux fois ses dés de vie. S''il a atteint cette limite et crée un nouveau rejeton, ce dernier est libre de tout contrôle. Un vampire asservi peut créer ses propres rejetons, ce qui explique qu''un maître puisse indirectement contrôler de nombreux sbires. Un vampire peut parfaitement relâcher l''un de ses rejetons pour en créer un nouveau. Néanmoins, dès qu''il est libéré, le rejeton ne peut plus être asservi.</p>
<p><strong>Créatures des ténèbres (Sur).</strong> Le vampire commande aux autres créatures de la nuit. Une fois par jour, il peut appeler 1d6+1 nuées de rats, 1d4+1 nuées de chauves-souris ou une meute de 3d6 loups (action simple). (Si la créature de base n''est pas terrestre, ce pouvoir permet de convoquer d''autres monstruosités de même puissance.) Les animaux apparaissent au bout de 2d6 rounds ; ils le servent pendant 1 heure maximum.</p>
<p><strong>Domination (Sur).</strong> Le vampire peut réduire à néant la volonté de sa proie en la regardant droit dans les yeux. L''utilisation de ce pouvoir est similaire à une attaque de regard, si ce n''est que le vampire doit la décider (il lui en coûte une action simple, et seule la créature qu''il fixe est en danger, pas les autres). La cible doit réussir un jet de Volonté pour ne pas tomber instantanément sous la coupe du vampire, comme si elle était affectée par le sort domination jeté par un lanceur de sorts de niveau 12. Ce pouvoir a une portée de 9 mètres.</p>
<p><strong>Particularités.</strong> Le vampire conserve toutes les particularités de la créature de base, auxquelles viennent s''ajouter les suivantes.</p>
<p><strong>État gazeux (Sur).</strong> Le vampire peut se transformer en brume à volonté, comme grâce à état gazeux (niveau 5 de lanceur de sorts ; action simple). Il peut rester dans cet état indéfiniment et bénéficie alors d''une vitesse de déplacement en vol de 6 mètres (manœuvrabilité parfaite).</p>
<p><strong>Guérison accélérée (Ext).</strong> Tant qu''il lui reste au moins 1 point de vie, le vampire soigne 5 points de dégâts par round. S''il tombe à 0 point de vie ou moins, il adopte automatiquement son état gazeux et tente de s''enfuir. Il lui faut atteindre son cercueil dans les 2 heures s''il ne veut pas être détruit à jamais (au cours de ce laps de temps, il peut parcourir un maximum de 15 kilomètres). S''il subit de nouveaux dégâts, ceux-ci n''ont aucun effet tant qu''il est en état gazeux. Une fois dans son cercueil, il est sans défense. Il remonte à 1 point de vie après s''être reposé pendant 1 heure, après quoi il n''est plus sans défense et le processus de guérison accélérée reprend normalement (5 points de vie par round).</p>
<p><strong>Pattes d''araignée (Ext).</strong> Il peut escalader les surfaces, même les plus verticales, comme s''il bénéficiait en permanence de l''effet du sort pattes d''araignée.</p>
<p><strong>Réduction des dégâts (Sur).</strong> Le vampire bénéficie d''une réduction des dégâts de (10/argent et magie). Pour ce qui est de vaincre la réduction des dégâts de ses adversaires, ses armes naturelles sont considérées comme des armes magiques.</p>
<p><strong>Résistance au renvoi des morts-vivants (Ext).</strong> Le vampire bénéficie d''une résistance de +4 au renvoi des morts-vivants.</p>
<p><strong>Résistances (Ext).</strong> Il possède une résistance de 10 points à l''électricité et au froid.</p>
<p><strong>Transformation (Sur).</strong> Un vampire peut se transformer en chauve-souris, chauve-souris sanguinaire, loup ou loup sanguinaire, ce qui lui coûte une action simple. Ce pouvoir est similaire au sort métamorphose (niveau 12 de lanceur de sorts), si ce n''est que le vampire ne regagne pas de points de vie ne peut pas prendre d''autres formes que celles mentionnées ci-dessus. Une fois transformé, le vampire perd son attaque naturelle de coup et son pouvoir de domination, mais il acquiert les armes naturelles et attaques spéciales extraordinaires de sa nouvelle forme. Il conserve son apparence jusqu''à ce qu''il décide d''en changer ou jusqu''au lever du soleil. (Si la créature de base n''est pas terrestre, ce pouvoir peut proposer d''autres formes.)</p>
<p><strong>Jets de sauvegarde.</strong> Comme la créature de base.</p>
<p><strong>Caractéristiques.</strong> Ajoutez les bonus suivants aux caractéristiques de la créature de base : For +6, Dex +4, Int +2, Sag +2, Cha +4. Comme tous les morts-vivants, le vampire n''a pas de valeur de Constitution.</p>
<p><strong>Compétences.</strong> Le vampire bénéficie d''un bonus racial de +8 aux tests de Bluff, Déplacement silencieux, Détection, Discrétion, Fouille, Perception auditive et Psychologie. Sinon, comme la créature de base.</p>
<p><strong>Dons.</strong> Le vampire acquiert automatiquement les dons suivants, si la créature de base ne les a pas déjà (et si elle remplit les conditions préalables) : Attaques réflexes, Esquive, Réflexes surhumains, Science de l''initiative et Vigilance.</p>
<p><strong>Environnement.</strong> Quelconque, généralement identique à celui de la créature de base.</p>
<p><strong>Organisation sociale.</strong> Solitaire, couple, groupe (3–5) ou bande (1–2 plus 2–5 vampiriens).</p>
<p><strong>Facteur de puissance.</strong> Comme la créature de base +2.</p>
<p><strong>Trésor.</strong> Normal (x2).</p>
<p><strong>Alignement.</strong> Toujours mauvais.</p>
<p><strong>Évolution possible.</strong> Par une classe de personnage.</p>
<p><strong>Ajustement de niveau.</strong> Comme la créature de base +8.</p>
<h4>Faiblesses du vampire</h4>
<p>Malgré ses nombreux pouvoirs, le vampire possède certaines faiblesses.</p>
<p><strong>Repousser un vampire.</strong> Le vampire ne supporte pas l''odeur de l''ail et n''entre jamais dans un lieu qui en est imprégné. De même, il recule devant les miroirs et les symboles sacrés, pour peu que ces derniers soient brandis avec conviction. À noter que ces objets l''empêchent juste de s''approcher ; ils ne lui font aucun mal. Il doit se tenir à 1,50 mètre au moins de la créature brandissant le miroir ou le symbole sacré et ne peut toucher ou porter une attaque de corps à corps contre celle-ci jusqu''au terme de la rencontre. On empêche un vampire de s''approcher au prix d''une action simple.</p>
<p>Le vampire ne peut pas traverser un cours d''eau à gué ou à la nage, mais il est possible de le lui faire franchir en le transportant dans son cercueil ou dans un bateau. Il ne peut pas entrer chez quelqu''un sans y avoir été invité par le propriétaire des lieux ou un membre de sa famille. Par contre, il peut pénétrer dans les lieux publics, qui sont par définition ouverts à tout le monde.</p>
<p><strong>Tuer un vampire.</strong> Quand un vampire se retrouve à 0 point de vie ou moins, il est hors de combat, mais revient vite à la vie s''il peut rejoindre son cercueil (voir plus haut). Néanmoins, certaines actions permettent de le tuer. Tout vampire directement exposé aux rayons du soleil est instantanément désorienté : il n''a plus droit qu''à une action de mouvement ou d''attaque et est détruit à tout jamais lors du round suivant s''il ne parvient pas à se mettre à l''abri. De la même manière, plonger un vampire dans un cours d''eau lui fait perdre un tiers de ses points de vie par round et le détruit à la fin du troisième round.</p>
<p>Planter un pieu dans le cœur d''un vampire le tue également, mais il revient à la vie dès que le pieu est ôté, à moins que son corps n''ait été détruit au préalable. Après avoir planté leur pieu, les chasseurs de vampire ont l''habitude de trancher la tête du mort-vivant et de lui remplir la bouche d''hosties (ou de l''équivalent, selon leur religion).</p>
<h4>Personnages vampires</h4>
<p>Tous les vampires sont d''alignement mauvais, ce qui implique que certains personnages qui le deviennent perdent automatiquement tout ou partie de leurs aptitudes et pouvoirs de classe. De plus, certaines classes subissent des handicaps supplémentaires :</p>
<p><strong>Ensorceleur ou magicien.</strong> Le personnage conserve ses aptitudes et pouvoirs de classe, mais s''il avait un familier autre qu''un rat ou une chauve-souris, il le perd aussitôt (le lien qui les unissait est rompu et le familier s''enfuit). Le personnage vampire peut appeler un autre familier, mais celui-ci doit impérativement être un rat ou une chauve-souris.</p>
<p><strong>Prêtre.</strong> Le personnage perd le pouvoir de renvoyer les morts-vivants, mais gagne celui de les intimider. Cette faculté n''affecte pas le maître du PJ (le vampire qui l''a corrompu) ni les autres morts-vivants que celui-ci contrôle.</p>
<p>Les prêtres vampires ont accès à deux des domaines suivants : Chaos, Destruction, Duperie et Mal.</p>',
8, NULL, @res, 0, 1, @ddver FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_races WHERE ra_nom = 'Vampire' AND ra_res_id = @res AND ra_ruleset_var_id = @ddver);

INSERT INTO dd_races (ra_nom, ra_rat_id, ra_description, ra_mod_niveau, ra_camp_id, ra_res_id, ra_public, ra_visible, ra_ruleset_var_id)
SELECT 'Zombi', @rat,
'<p>L''archétype acquis « zombi » peut être ajouté à n''importe quelle créature tangible (appelée ci-après la « créature de base »), pour peu qu''elle soit dotée d''un squelette et qu''il ne s''agisse pas d''un mort-vivant.</p>
<p><strong>Taille et type.</strong> Le type de la créature devient mort-vivant. Il conserve tout sous-type qu''il possède déjà, sauf si celui-ci relève d''un alignement ou d''une espèce. Il n''acquiert pas le sous-type altéré. Sauf indication contraire, il conserve le profil et les pouvoirs spéciaux de la créature de base.</p>
<p><strong>Dés de vie.</strong> Débarrassez-vous des dés de vie issus de niveaux de classe (mais gardez 1 DV minimum), doublez ceux qui restent et transformez-les en d12. Si la créature de base a plus de 10 dés de vie (sans compter ceux qui découlent de l''expérience), le sort animation des morts ne permet pas d''en faire un zombi.</p>
<p><strong>Vitesse de déplacement.</strong> Si la créature de base vole, sa manœuvrabilité tombe à déplorable.</p>
<p><strong>Classe d''armure.</strong> Le bonus d''armure naturelle augmente selon la taille du zombi.</p>
<p>[[tab:archetype-zombi-armure-naturelle]]</p>
<p><strong>Attaque de base.</strong> Un zombi a un bonus de base à l''attaque égal à la moitié de ses dés de vie.</p>
<p><strong>Attaques.</strong> Un zombi conserve les armes naturelles, attaques à l''aide d''armes et formations martiales de la créature de base. Il acquiert également une attaque de coup.</p>
<p><strong>Dégâts.</strong> Les armes (naturelles ou non) infligent des dégâts normaux. Une attaque de coup inflige des dégâts selon la taille du zombi. (Si la créature de base disposait déjà d''une attaque de coup, utilisez les dégâts de celles du zombi s''ils sont plus élevés uniquement.)</p>
<p>[[tab:archetype-zombi-degats-coup]]</p>
<p><strong>Attaques spéciales.</strong> Un zombi ne conserve aucune des attaques spéciales de la créature de base.</p>
<p><strong>Particularités.</strong> Un zombi perd la plupart des particularités de la créature de base. Il conserve les particularités extraordinaires relevant d''attaques au corps à corps ou à distance. En outre, il gagne la suivante :</p>
<p><strong>Limité à une seule action (Ext).</strong> Les zombis ont de mauvais réflexes et ne peuvent exécuter qu''une action de mouvement ou d''attaque par round. Il a donc le choix entre attaquer et se déplacer, et ne peut faire les deux que s''il charge.</p>
<p><strong>Jets de sauvegarde.</strong> Bonus de base aux sauvegardes : Réf +1/3 DV, Vig +1/3 DV et Vol 1/2 DV + 2.</p>
<p><strong>Caractéristiques.</strong> La Force d''un zombi augmente de +2, sa Dextérité baisse de –2, il n''a pas de valeurs de Constitution et d''Intelligence, sa Sagesse passe à 10 et son Charisme tombe à 1.</p>
<p><strong>Compétences.</strong> Un zombi n''a pas de compétences.</p>
<p><strong>Dons.</strong> Un zombi perd tous les dons de la créature de base et acquiert Robustesse.</p>
<p><strong>Environnement.</strong> Quelconque et souterrains.</p>
<p><strong>Organisation sociale.</strong> Quelconque.</p>
<p><strong>Facteur de puissance.</strong> Selon les dés de vie, comme suit :</p>
<p>[[tab:archetype-zombi-fp]]</p>
<p><strong>Trésor.</strong> Aucun.</p>
<p><strong>Alignement.</strong> Toujours neutre mauvais.</p>
<p><strong>Évolution possible.</strong> Comme la créature de base, mais doublez les dés de vie (20 maximum), ou « — » si celle-ci évolue par une classe de personnage.</p>
<p><strong>Ajustement de niveau.</strong> —.</p>',
0, NULL, @res, 0, 1, @ddver FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_races WHERE ra_nom = 'Zombi' AND ra_res_id = @res AND ra_ruleset_var_id = @ddver);

COMMIT;
