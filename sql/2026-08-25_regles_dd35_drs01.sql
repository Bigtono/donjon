-- ============================================================
-- 2026-08-25_regles_dd35_drs01.sql — SP-DRS1 (lot 1)
-- Règles DD3.5 — DRS 01 : Les caractéristiques.
-- Rattachement : racine thématique « Les bases du jeu ».
-- Tableaux : dd_tableaux (convention texte, tag [[tab:slug]]) — SP-TB9.
-- Idempotent : réinitialise uniquement le sous-arbre du chapitre
-- « Les caractéristiques » et ses tableaux.
-- Pré-requis : 2026-08-25_regles_dd35_socle.sql.
-- ============================================================

SET NAMES utf8mb4;

SET @ddver := (SELECT var_id FROM dd_variables
               WHERE var_cat = 'ruleset' AND var_valeur = 'DD3.5' LIMIT 1);
SET @res   := (SELECT res_id FROM dd_ressources
               WHERE res_abreviation = 'DRS 3.5' AND res_ruleset_var_id = @ddver LIMIT 1);
SET @racine := (SELECT reg_id FROM dd_regles
                WHERE reg_slug = 'les-bases-du-jeu' AND reg_ruleset_var_id = @ddver LIMIT 1);
SET @now := NOW();

START TRANSACTION;

-- ------------------------------------------------------------
-- Réinitialisation idempotente du sous-arbre DRS 01
-- ------------------------------------------------------------
SET @chap := (SELECT reg_id FROM dd_regles
              WHERE reg_slug = 'les-caracteristiques' AND reg_ruleset_var_id = @ddver LIMIT 1);
DELETE FROM dd_regles WHERE @chap IS NOT NULL AND reg_reg_id = @chap;
DELETE FROM dd_regles WHERE @chap IS NOT NULL AND reg_id = @chap;
DELETE FROM dd_tableaux
WHERE  tab_ruleset_var_id = @ddver
  AND  tab_slug IN ('modificateurs-de-caracteristiques');

-- ------------------------------------------------------------
-- Chapitre
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@racine, 'chapitre', 'Les caractéristiques', 'les-caracteristiques',
        '<p>Chaque créature possède six caractéristiques qui décrivent ses atouts et ses faiblesses physiques et mentales : la Force (For), la Dextérité (Dex), la Constitution (Con), l''Intelligence (Int), la Sagesse (Sag) et le Charisme (Cha). Une valeur de 10 ou 11 correspond à la moyenne humaine ; les aventuriers accomplis dépassent souvent 18.</p><p>Chaque caractéristique confère un modificateur qui s''applique aux jets de dés qui en dépendent. C''est ce modificateur, plus que la valeur brute, qui intervient dans la quasi-totalité des règles.</p>',
        10, @ddver, @res, NULL, 1, @now, @now);
SET @chap := LAST_INSERT_ID();

-- ------------------------------------------------------------
-- Règle : Modificateurs de caractéristiques
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Modificateurs de caractéristiques', 'modificateurs-de-caracteristiques-regle',
        '<p>Chaque caractéristique est associée à un modificateur, indiqué dans le tableau ci-dessous. Il s''applique à tous les jets de dés liés à la caractéristique : jets d''attaque, jets de dégâts, jets de sauvegarde, tests de caractéristique et de compétence, etc. Le modificateur vaut (valeur − 10) divisé par 2, arrondi à l''entier inférieur.</p>
<p>[[tab:modificateurs-de-caracteristiques]]</p>
<h3>Sorts en bonus</h3>
<p>La caractéristique primordiale d''un lanceur de sorts (Intelligence pour le magicien, Sagesse pour le prêtre, le druide, le paladin et le rôdeur, Charisme pour le barde et l''ensorceleur) lui octroie des sorts en bonus si elle est suffisamment élevée. La colonne « Sorts en bonus » indique le nombre de sorts quotidiens supplémentaires pour chaque niveau de sort. Pour lancer un sort, le personnage doit par ailleurs avoir une valeur de caractéristique primordiale au moins égale à 10 + le niveau du sort ; les sorts du niveau 0 ne donnent jamais droit à des sorts en bonus.</p>',
        10, @ddver, @res, NULL, 1, @now, @now);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note,
                         tab_ruleset_var_id, tab_res_id, tab_camp_id,
                         tab_ecran_mj, tab_ecran_ordre, tab_visible,
                         tab_date_creation, tab_date_modif)
VALUES ('modificateurs-de-caracteristiques', 'Modificateurs de caractéristiques et sorts en bonus',
'! Valeur | Modificateur | Sorts en bonus (par niveau de sort) | | | | | | | | |
! ^ | ^ | 1er | 2e | 3e | 4e | 5e | 6e | 7e | 8e | 9e
1 | −5 | — | — | — | — | — | — | — | — | —
2–3 | −4 | — | — | — | — | — | — | — | — | —
4–5 | −3 | — | — | — | — | — | — | — | — | —
6–7 | −2 | — | — | — | — | — | — | — | — | —
8–9 | −1 | — | — | — | — | — | — | — | — | —
10–11 | 0 | — | — | — | — | — | — | — | — | —
12–13 | +1 | 1 | — | — | — | — | — | — | — | —
14–15 | +2 | 1 | 1 | — | — | — | — | — | — | —
16–17 | +3 | 1 | 1 | 1 | — | — | — | — | — | —
18–19 | +4 | 1 | 1 | 1 | 1 | — | — | — | — | —
20–21 | +5 | 2 | 1 | 1 | 1 | 1 | — | — | — | —
22–23 | +6 | 2 | 2 | 1 | 1 | 1 | 1 | — | — | —
24–25 | +7 | 2 | 2 | 2 | 1 | 1 | 1 | 1 | — | —
26–27 | +8 | 2 | 2 | 2 | 2 | 1 | 1 | 1 | 1 | —
28–29 | +9 | 3 | 2 | 2 | 2 | 2 | 1 | 1 | 1 | 1
30–31 | +10 | 3 | 3 | 2 | 2 | 2 | 2 | 1 | 1 | 1
32–33 | +11 | 3 | 3 | 3 | 2 | 2 | 2 | 2 | 1 | 1
34–35 | +12 | 3 | 3 | 3 | 3 | 2 | 2 | 2 | 2 | 1
36–37 | +13 | 4 | 3 | 3 | 3 | 3 | 2 | 2 | 2 | 2
38–39 | +14 | 4 | 4 | 3 | 3 | 3 | 3 | 2 | 2 | 2
40–41 | +15 | 4 | 4 | 4 | 3 | 3 | 3 | 3 | 2 | 2
42–43 | +16 | 4 | 4 | 4 | 4 | 3 | 3 | 3 | 3 | 2
44–45 | +17 | 5 | 4 | 4 | 4 | 4 | 3 | 3 | 3 | 3
> Une valeur de 9 ou moins dans la caractéristique primordiale interdit de lancer les sorts qui en dépendent ; il faut une valeur d''au moins 10 + le niveau du sort.',
        'ccccccccccc', NULL, @ddver, @res, NULL, 0, 0, 1, @now, @now);

-- ------------------------------------------------------------
-- Règle : Les six caractéristiques
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Les six caractéristiques', 'les-six-caracteristiques',
        '<h3>Force (For)</h3>
<p>La Force mesure la puissance musculaire. Elle est primordiale pour les combattants au corps à corps. Son modificateur s''applique :</p>
<ul><li>aux jets d''attaque au corps à corps ;</li><li>aux jets de dégâts des armes de corps à corps et des armes de jet (une arme tenue à deux mains ajoute une fois et demie le modificateur, une arme tenue de la main secondaire la moitié) ;</li><li>aux tests d''Escalade, de Natation et de Saut ;</li><li>aux tests de Force (portes à enfoncer, etc.) et aux manœuvres de lutte, bousculade, croc-en-jambe…</li></ul>
<p>La Force détermine aussi la charge maximale que le personnage peut porter.</p>
<h3>Dextérité (Dex)</h3>
<p>La Dextérité mesure l''agilité, les réflexes et l''équilibre. Son modificateur s''applique :</p>
<ul><li>aux jets d''attaque à distance ;</li><li>à la classe d''armure, tant que le personnage peut réagir à l''attaque ;</li><li>aux jets de Réflexes ;</li><li>aux tests d''Acrobaties, de Discrétion, de Déplacement silencieux, d''Équilibre, d''Escamotage et de Maîtrise des cordes, ainsi qu''au test d''initiative.</li></ul>
<h3>Constitution (Con)</h3>
<p>La Constitution représente la santé et l''endurance. Son modificateur s''applique :</p>
<ul><li>à chaque dé de vie (un modificateur négatif ne peut toutefois pas ramener un dé de vie au-dessous de 1 point de vie) ;</li><li>aux jets de Vigueur ;</li><li>aux tests de Concentration.</li></ul>
<p>Si la Constitution d''une créature change, ses points de vie maximaux sont recalculés. Contrairement aux autres caractéristiques, une Constitution tombant à 0 signifie la mort.</p>
<h3>Intelligence (Int)</h3>
<p>L''Intelligence représente les capacités d''apprentissage et de raisonnement. Elle est la caractéristique primordiale des magiciens. Son modificateur s''applique :</p>
<ul><li>au nombre de langues connues au départ ;</li><li>au nombre de points de compétence gagnés à chaque niveau (minimum 1) ;</li><li>aux tests d''Artisanat, de Connaissances, de Décryptage, de Fouille et d''Estimation.</li></ul>
<p>Une créature capable de penser possède au moins 1 point d''Intelligence ; les animaux ont 1 ou 2.</p>
<h3>Sagesse (Sag)</h3>
<p>La Sagesse traduit la volonté, le bon sens, la perception et l''intuition. Elle est primordiale pour les prêtres, druides, paladins et rôdeurs. Son modificateur s''applique :</p>
<ul><li>aux jets de Volonté ;</li><li>aux tests de Détection, de Perception auditive, de Premiers secours, de Psychologie et de Survie.</li></ul>
<h3>Charisme (Cha)</h3>
<p>Le Charisme mesure la force de persuasion, le magnétisme personnel et l''aptitude à diriger. Il est primordial pour les bardes et les ensorceleurs, et intervient dans le renvoi des morts-vivants du prêtre et les pouvoirs du paladin. Son modificateur s''applique :</p>
<ul><li>aux tests de Bluff, de Diplomatie, de Déguisement, de Dressage, d''Intimidation, de Renseignements et de Représentation ;</li><li>aux tests de renvoi des morts-vivants.</li></ul>',
        20, @ddver, @res, NULL, 1, @now, @now);

-- ------------------------------------------------------------
-- Règle : Évolution des valeurs de caractéristiques
-- ------------------------------------------------------------
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible,
                       reg_date_creation, reg_date_modif)
VALUES (@chap, 'regle', 'Évolution des valeurs de caractéristiques', 'evolution-des-valeurs-de-caracteristiques',
        '<p>Les valeurs de caractéristiques ne sont pas figées : elles évoluent avec les niveaux, la magie et les agressions subies.</p>
<h3>Augmentations</h3>
<ul><li><strong>Montée de niveau.</strong> Tous les 4 niveaux (4e, 8e, 12e…), le personnage augmente de façon permanente la caractéristique de son choix de 1 point.</li><li><strong>Bonus d''altération.</strong> Sorts et objets magiques (<em>force de taureau</em>, <em>grâce féline</em>, ceinturon de force de géant…) confèrent des bonus temporaires ou permanents tant qu''ils s''appliquent.</li><li><strong>Bonus inhérents.</strong> Les sorts de <em>souhait</em> et les manuels et tomes magiques accordent des bonus inhérents permanents (maximum +5).</li><li><strong>Vieillissement.</strong> L''âge augmente les caractéristiques mentales et réduit les caractéristiques physiques.</li></ul>
<h3>Affaiblissement temporaire</h3>
<p>Certaines attaques (poison, sorts, pouvoirs spéciaux) infligent un affaiblissement temporaire de caractéristique. Les points perdus reviennent naturellement au rythme de 1 point par jour et par caractéristique affectée (2 points par jour de repos complet). Les sorts <em>restauration partielle</em> et <em>restauration</em> les rendent immédiatement.</p>
<h3>Diminution permanente</h3>
<p>La diminution permanente de caractéristique ne se soigne pas naturellement : seuls des sorts comme <em>restauration</em>, <em>restauration suprême</em>, <em>souhait</em> ou <em>miracle</em> peuvent rendre les points perdus.</p>
<h3>Caractéristique réduite à 0</h3>
<ul><li><strong>Force 0</strong> : la créature s''effondre, incapable de bouger (sans défense).</li><li><strong>Dextérité 0</strong> : la créature est paralysée (sans défense).</li><li><strong>Constitution 0</strong> : la créature meurt.</li><li><strong>Intelligence, Sagesse ou Charisme 0</strong> : la créature sombre dans l''inconscience (coma) jusqu''à ce qu''elle récupère au moins 1 point.</li></ul>',
        30, @ddver, @res, NULL, 1, @now, @now);

COMMIT;
