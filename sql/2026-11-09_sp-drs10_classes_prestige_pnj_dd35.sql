-- sql/2026-11-09_sp-drs10_classes_prestige_pnj_dd35.sql
-- SP-DRS10 — DRS 08a, 08b et 15 : classes de prestige et classes de PNJ (DD3.5)
--
-- 1. Cinq tableaux secondaires des classes, catégorie Classe, source DRS 3.5 (tags [[tab:classe-…]]).
-- 2. Règles : chapitre « Les classes », pages « Classes de prestige » (introduction et définitions du DRS)
--    et « Classes de PNJ » ; quatre termes de glossaire (Classe de base, Niveau de classe,
--    Niveau de lanceur de sorts, Niveau global).
-- 3. Les 15 classes de prestige du Guide du maître, déjà présentes, mises en conformité avec le DRS :
--    noms, abréviations, niveau maximal, conditions d'accès, armes et armures, compétences de classe,
--    liste de sorts, progression corrigée (niveau maximal du hiérophante et du thaumaturge, sauvegardes
--    du disciple draconien, capacités du maître des ombres, bonus à la CA du protecteur nain),
--    texte intégral de chaque capacité. Une capacité partagée avec une autre classe dont le texte
--    diffère reçoit une variante propre à la classe (cap_classe_initiale) — D-DRS11.
-- 4. Les 5 classes de PNJ (adepte, expert, gens du peuple, homme d'armes, noble), créées,
--    type PNJ, source Guide du maître : 20 niveaux, compétences, capacités et sorts de l'adepte.
--
-- Texte corrigé : voir doc/LOG_CORRECTIONS_DRS08_15.md. Classes et capacités retrouvées par leur nom
-- (les ids peuvent différer entre local et production). Rejouable : tableaux et règles en upsert sur
-- leur slug, capacités créées une seule fois (nom + classe), liaisons réécrites.
-- Datée du 09 pour passer après les migrations 2026-11-07_sp-tb12a (catégories de tableaux) et
-- 2026-11-08_* : le moteur joue les migrations dans l'ordre alphabétique du nom complet. Pas de DELIMITER.

SET NAMES utf8mb4;

SET @ddver  := (SELECT var_id FROM dd_variables WHERE var_cat = 'ruleset' AND var_valeur = 'DD3.5' LIMIT 1);
SET @drs    := (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'DRS 3.5' AND res_ruleset_var_id = @ddver LIMIT 1);
SET @gdm    := (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'GDM3.5' AND res_ruleset_var_id = @ddver LIMIT 1);
SET @catcla := (SELECT tabc_id FROM dd_tableaux_categories WHERE tabc_slug = 'classe' LIMIT 1);
SET @now    := NOW();

START TRANSACTION;

-- ============================================================ 1. Tableaux
INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id,
                         tab_ruleset_var_id, tab_res_id, tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible,
                         tab_date_creation, tab_date_modif)
VALUES
('classe-chevalier-noir-serviteur-fielon', 'Chevalier noir : serviteur fiélon',
'! Niveau global | DV sup. | Aj. d''armure naturelle | Aj. de Force | Int | Spécial
12 ou moins | +2 | +1 | +1 | 6 | Esquive extraordinaire, lien télépathique, transfert d''effet magique, transfert de jet de sauvegarde
13-15 | +4 | +3 | +2 | 7 | Communication avec le maître
16-18 | +6 | +5 | +3 | 8 | Lien du sang
19-20 | +8 | +7 | +4 | 9 | Résistance à la magie',
'cccccl', NULL, @catcla, @ddver, @drs, NULL, 0, 0, 1, @now, @now),
('classe-disciple-draconien-griffes', 'Disciple draconien : griffes et morsure',
'! Taille | Dégâts des griffes | Dégâts de la morsure
Petit (P) | 1d4 | 1d3
Moyen (M) | 1d6 | 1d4
Grand (G) | 1d8 | 1d6',
'lcc', NULL, @catcla, @ddver, @drs, NULL, 0, 0, 1, @now, @now),
('classe-disciple-draconien-souffle', 'Disciple draconien : souffle',
'! Type de dragon (1) | Souffle
Blanc | Cône de froid
Bleu | Ligne d''électricité
Noir | Ligne d''acide
Rouge | Cône de feu
Vert | Cône de gaz corrosif (acide)
Airain | Ligne de feu
Argent | Cône de froid
Bronze | Ligne d''électricité
Cuivre | Ligne d''acide
Or | Cône de feu
> (1) D''autres types de disciples draconiens sont envisageables en utilisant d''autres races de dragons comme ancêtres.',
'll', NULL, @catcla, @ddver, @drs, NULL, 0, 0, 1, @now, @now),
('classe-gardien-du-savoir-secrets', 'Secrets des gardiens du savoir',
'! Niveau + mod. Int | Secret | Effet
1 | Secret de maîtrise | Degré de maîtrise de 4 dans une compétence que le personnage ne maîtrisait pas
2 | Secret de vitalité | +3 points de vie
3 | Secret de la force intérieure | +2 aux jets de Volonté
4 | Secret de la résistance physique | +2 aux jets de Vigueur
5 | Secret de la vivacité | +2 aux jets de Réflexes
6 | Secret du combat | +1 aux jets d''attaque
7 | Secret de l''esquive | Bonus d''esquive de +1 à la CA
8 | Savoir pratique | Don au choix
9 | Arcane secret | 1 sort en bonus du 1er niveau (1)
10 | Autre arcane secret | 1 sort en bonus du 2e niveau (1)
> (1) Équivalent à un sort en bonus offert par une caractéristique élevée.',
'cll', NULL, @catcla, @ddver, @drs, NULL, 0, 0, 1, @now, @now),
('classe-hierophante-alignement', 'Hiérophante : alignements opposés',
'! Alignement de l''hiérophante | Alignement opposé
Chaotique bon | Loyal mauvais
Chaotique neutre | Loyal neutre
Chaotique mauvais | Loyal bon
Neutre bon | Neutre mauvais
Neutre | Loyal bon ou chaotique bon ou loyal mauvais ou chaotique mauvais (1)
Neutre mauvais | Neutre bon
Loyal bon | Chaotique mauvais
Loyal neutre | Chaotique neutre
Loyal mauvais | Chaotique bon
> (1) Un hiérophante neutre doit choisir l''un de ces alignements en tant qu''alignement opposé et ne peut le changer par la suite.',
'll', NULL, @catcla, @ddver, @drs, NULL, 0, 0, 1, @now, @now)
ON DUPLICATE KEY UPDATE
  tab_nom = VALUES(tab_nom), tab_contenu = VALUES(tab_contenu), tab_align = VALUES(tab_align),
  tab_tabc_id = VALUES(tab_tabc_id), tab_res_id = VALUES(tab_res_id), tab_date_modif = VALUES(tab_date_modif);

-- ============================================================ 2. Règles et glossaire
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (NULL, 'chapitre', 'Les classes', 'les-classes',
'<p>Les règles communes aux classes qui complètent les classes de base : les classes de prestige, accessibles sous conditions, et les classes de personnages non joueurs. Les classes elles-mêmes sont décrites dans le compendium Classes.</p>',
        12, @ddver, @drs, NULL, 1, @now, @now)
ON DUPLICATE KEY UPDATE reg_reg_id = VALUES(reg_reg_id), reg_type = VALUES(reg_type), reg_nom = VALUES(reg_nom),
  reg_texte = VALUES(reg_texte), reg_res_id = VALUES(reg_res_id), reg_date_modif = VALUES(reg_date_modif);
SET @r_classes := (SELECT reg_id FROM dd_regles WHERE reg_slug = 'les-classes' AND reg_ruleset_var_id = @ddver);
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_classes, 'regle', 'Classes de prestige', 'classes-de-prestige',
'<p>Les classes de prestige offrent des nouvelles possibilités aux personnages souhaitant se multiclasser (à noter que, dans ce cas, ils n''encourent pas le malus de points d''expérience normalement associé au multiclassage). Contrairement aux classes de base, un personnage doit remplir certaines conditions avant de pouvoir prendre son premier niveau dans une classe de prestige. La procédure de passage de niveau s''applique aussi aux classes de prestige, ce qui signifie que la première étape consiste toujours à choisir une classe. Si le personnage ne remplit pas les conditions associées à une classe de prestige avant cette première étape, il ne peut pas la choisir pour son passage de niveau.</p>
<h3>Définition des termes</h3>
<p>Les définitions suivantes concernent quelques termes utilisés pour les classes de prestige.</p>
<p><strong>Classe de base.</strong> L''une des onze classes accessibles aux personnages de niveau 1.</p>
<p><strong>Niveau de classe.</strong> Le niveau d''un personnage dans l''une de ses classes. Pour un personnage à une seule classe, le niveau de classe et le niveau global sont identiques.</p>
<p><strong>Niveau de lanceur de sorts.</strong> Le niveau intervenant dans les variables des sorts. Il est généralement égal au niveau de classe (voir ci-dessus) permettant de lancer le sort en question. Certaines classes de prestige augmentent le niveau de lanceur de sorts d''une classe existante.</p>
<p><strong>Niveau global.</strong> Le niveau total du personnage, égal à la somme de tous ses niveaux de classe de ses différentes classes.</p>',
        10, @ddver, @drs, NULL, 1, @now, @now)
ON DUPLICATE KEY UPDATE reg_reg_id = VALUES(reg_reg_id), reg_type = VALUES(reg_type), reg_nom = VALUES(reg_nom),
  reg_texte = VALUES(reg_texte), reg_res_id = VALUES(reg_res_id), reg_date_modif = VALUES(reg_date_modif);
SET @r_prestige := (SELECT reg_id FROM dd_regles WHERE reg_slug = 'classes-de-prestige' AND reg_ruleset_var_id = @ddver);
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@r_classes, 'regle', 'Classes de PNJ', 'classes-de-pnj',
'<p>Les classes de PNJ sont destinées aux personnages non joueurs : adepte (lanceur de sorts divins des communautés reculées), expert (artisan ou spécialiste), gens du peuple (paysans et manœuvres), homme d''armes (soldat ou garde) et noble. Elles sont moins puissantes que les classes de base ; un monstre qui progresse par une classe de PNJ relève du tirage simple des valeurs de caractéristique.</p>
<p>Chaque classe de PNJ indique l''équipement de départ du personnage. Les fiches sont décrites dans le compendium Classes.</p>',
        20, @ddver, @drs, NULL, 1, @now, @now)
ON DUPLICATE KEY UPDATE reg_reg_id = VALUES(reg_reg_id), reg_type = VALUES(reg_type), reg_nom = VALUES(reg_nom),
  reg_texte = VALUES(reg_texte), reg_res_id = VALUES(reg_res_id), reg_date_modif = VALUES(reg_date_modif);
SET @r_pnj := (SELECT reg_id FROM dd_regles WHERE reg_slug = 'classes-de-pnj' AND reg_ruleset_var_id = @ddver);
SET @glo := (SELECT reg_id FROM dd_regles WHERE reg_slug = 'glossaire' AND reg_ruleset_var_id = @ddver AND reg_type = 'chapitre');
SET @o := (SELECT COALESCE(MAX(reg_ordre), 0) + 1 FROM dd_regles WHERE reg_reg_id = @glo AND reg_slug <> 'classe-de-base' AND reg_nom < 'Classe de base');
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@glo, 'glossaire', 'Classe de base', 'classe-de-base',
'<p>L''une des onze classes accessibles aux personnages de niveau 1. Voir <em>Classes de prestige</em>.</p>',
        @o, @ddver, @drs, NULL, 1, @now, @now)
ON DUPLICATE KEY UPDATE reg_reg_id = VALUES(reg_reg_id), reg_type = VALUES(reg_type), reg_nom = VALUES(reg_nom),
  reg_texte = VALUES(reg_texte), reg_res_id = VALUES(reg_res_id), reg_date_modif = VALUES(reg_date_modif);
SET @g1 := (SELECT reg_id FROM dd_regles WHERE reg_slug = 'classe-de-base' AND reg_ruleset_var_id = @ddver);
SET @o := (SELECT COALESCE(MAX(reg_ordre), 0) + 1 FROM dd_regles WHERE reg_reg_id = @glo AND reg_slug <> 'niveau-de-classe' AND reg_nom < 'Niveau de classe');
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@glo, 'glossaire', 'Niveau de classe', 'niveau-de-classe',
'<p>Le niveau d''un personnage dans l''une de ses classes. Pour un personnage à une seule classe, le niveau de classe et le niveau global sont identiques.</p>',
        @o, @ddver, @drs, NULL, 1, @now, @now)
ON DUPLICATE KEY UPDATE reg_reg_id = VALUES(reg_reg_id), reg_type = VALUES(reg_type), reg_nom = VALUES(reg_nom),
  reg_texte = VALUES(reg_texte), reg_res_id = VALUES(reg_res_id), reg_date_modif = VALUES(reg_date_modif);
SET @g2 := (SELECT reg_id FROM dd_regles WHERE reg_slug = 'niveau-de-classe' AND reg_ruleset_var_id = @ddver);
SET @o := (SELECT COALESCE(MAX(reg_ordre), 0) + 1 FROM dd_regles WHERE reg_reg_id = @glo AND reg_slug <> 'niveau-de-lanceur-de-sorts' AND reg_nom < 'Niveau de lanceur de sorts');
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@glo, 'glossaire', 'Niveau de lanceur de sorts', 'niveau-de-lanceur-de-sorts',
'<p>Le niveau intervenant dans les variables des sorts. Il est généralement égal au niveau de classe permettant de lancer le sort en question. Certaines classes de prestige augmentent le niveau de lanceur de sorts d''une classe existante.</p>',
        @o, @ddver, @drs, NULL, 1, @now, @now)
ON DUPLICATE KEY UPDATE reg_reg_id = VALUES(reg_reg_id), reg_type = VALUES(reg_type), reg_nom = VALUES(reg_nom),
  reg_texte = VALUES(reg_texte), reg_res_id = VALUES(reg_res_id), reg_date_modif = VALUES(reg_date_modif);
SET @g3 := (SELECT reg_id FROM dd_regles WHERE reg_slug = 'niveau-de-lanceur-de-sorts' AND reg_ruleset_var_id = @ddver);
SET @o := (SELECT COALESCE(MAX(reg_ordre), 0) + 1 FROM dd_regles WHERE reg_reg_id = @glo AND reg_slug <> 'niveau-global' AND reg_nom < 'Niveau global');
INSERT INTO dd_regles (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
                       reg_ruleset_var_id, reg_res_id, reg_camp_id, reg_visible, reg_date_creation, reg_date_modif)
VALUES (@glo, 'glossaire', 'Niveau global', 'niveau-global',
'<p>Le niveau total du personnage, égal à la somme de tous ses niveaux de classe de ses différentes classes.</p>',
        @o, @ddver, @drs, NULL, 1, @now, @now)
ON DUPLICATE KEY UPDATE reg_reg_id = VALUES(reg_reg_id), reg_type = VALUES(reg_type), reg_nom = VALUES(reg_nom),
  reg_texte = VALUES(reg_texte), reg_res_id = VALUES(reg_res_id), reg_date_modif = VALUES(reg_date_modif);
SET @g4 := (SELECT reg_id FROM dd_regles WHERE reg_slug = 'niveau-global' AND reg_ruleset_var_id = @ddver);

-- ============================================================ 3-4. Classes

-- ------------------------------------------------------------ Archer-mage
SET @c := (SELECT cla_id FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 2
             AND TRIM(cla_nom) IN ('Archer-Mage', 'Archer-mage') ORDER BY cla_id LIMIT 1);
UPDATE dd_classes SET
  cla_nom = 'Archer-mage',
  cla_abreviation = 'AM',
  cla_dV = 8,
  cla_pointsCompetences = 4,
  cla_niveauMax = 10,
  cla_conditions = '<p><strong>Race.</strong> Elfe ou demi-elfe.</p>
<p><strong>Bonus de base à l''attaque.</strong> +6.</p>
<p><strong>Dons.</strong> Arme de prédilection (arc court ou arc long), Tir à bout portant, Tir de précision.</p>
<p><strong>Sorts.</strong> Faculté de lancer les sorts profanes de niveau 1.</p>',
  cla_armes = '<p>L''archer-mage est formé au maniement des armes courantes et de guerre, ainsi que des boucliers (à l''exception du pavois). Il est également formé au port des armures légères et intermédiaires.</p>'
WHERE cla_id = @c;
DELETE FROM dd_classe_competence WHERE ccomp_cla_id = @c;
INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @c, comp_id, NULL FROM dd_competences
WHERE comp_ruleset_var_id = @ddver AND TRIM(comp_nom) IN ('Artisanat', 'Déplacement silencieux', 'Détection', 'Discrétion', 'Équitation', 'Maîtrise des cordes', 'Perception auditive', 'Survie');
-- Flèche magique
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Flèche magique (+1)', 'Flèche magique') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Flèche magique', cap_type = 'sur', cap_classe_initiale = @c,
  cap_description = '<p>Dès le niveau 1, toute flèche normale tirée par l''archer-mage devient magique et acquiert un bonus d''altération de +1. Contrairement aux armes magiques normales, ces flèches ne coûtent ni argent ni points d''expérience au personnage. Par contre, elles ne fonctionnent que pour lui. Tous les niveaux impairs d''archer-mage, ses flèches deviennent plus puissantes (+1 au niveau 1, +2 au niveau 3, +3 au niveau 5, +4 au niveau 7 et +5 au niveau 9).</p>'
WHERE cap_id = @k;
-- fusion des « Flèche magique (+N) » en une seule capacité, le bonus passant en précision
SET @f := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) = 'Flèche magique (+2)' LIMIT 1);
DELETE FROM dd_classe_capacite WHERE cc_cla_id = @c AND cc_cap_id = @f;
DELETE FROM dd_capacites_speciales WHERE cap_id = @f
  AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite WHERE cc_cap_id = @f)
  AND NOT EXISTS (SELECT 1 FROM dd_race_capacite WHERE cr_cap_id = @f)
  AND NOT EXISTS (SELECT 1 FROM dd_personnages_choix WHERE pech_cap_id = @f);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 3, '+2', 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision);
SET @f := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) = 'Flèche magique (+3)' LIMIT 1);
DELETE FROM dd_classe_capacite WHERE cc_cla_id = @c AND cc_cap_id = @f;
DELETE FROM dd_capacites_speciales WHERE cap_id = @f
  AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite WHERE cc_cap_id = @f)
  AND NOT EXISTS (SELECT 1 FROM dd_race_capacite WHERE cr_cap_id = @f)
  AND NOT EXISTS (SELECT 1 FROM dd_personnages_choix WHERE pech_cap_id = @f);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 5, '+3', 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision);
SET @f := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) = 'Flèche magique (+4)' LIMIT 1);
DELETE FROM dd_classe_capacite WHERE cc_cla_id = @c AND cc_cap_id = @f;
DELETE FROM dd_capacites_speciales WHERE cap_id = @f
  AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite WHERE cc_cap_id = @f)
  AND NOT EXISTS (SELECT 1 FROM dd_race_capacite WHERE cr_cap_id = @f)
  AND NOT EXISTS (SELECT 1 FROM dd_personnages_choix WHERE pech_cap_id = @f);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 7, '+4', 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision);
SET @f := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) = 'Flèche magique (+5)' LIMIT 1);
DELETE FROM dd_classe_capacite WHERE cc_cla_id = @c AND cc_cap_id = @f;
DELETE FROM dd_capacites_speciales WHERE cap_id = @f
  AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite WHERE cc_cap_id = @f)
  AND NOT EXISTS (SELECT 1 FROM dd_race_capacite WHERE cr_cap_id = @f)
  AND NOT EXISTS (SELECT 1 FROM dd_personnages_choix WHERE pech_cap_id = @f);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 9, '+5', 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision);
UPDATE dd_classe_capacite SET cc_precision = '+1' WHERE cc_cla_id = @c AND cc_cap_id = @k AND cc_niveau = 1;
-- Flèche enchantée (Mag)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Flèche enchantée') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Flèche enchantée', cap_type = 'mag', cap_classe_initiale = @c,
  cap_description = '<p>Au niveau 2, l''archer-mage acquiert le pouvoir de placer un sort sur une de ses flèches. Quand celle-ci est tirée, le sort prend effet à partir du point d''impact (même s''il s''agit d''une incantation qui ne devrait normalement affecter que le personnage). La portée du sort devient donc celle de l''arc. Lancer le sort et tirer la flèche ne demande qu''une action simple. La flèche doit être tirée dans le round de l''incantation, sans quoi le sort est perdu.</p>'
WHERE cap_id = @k;
-- Flèche à tête chercheuse (Mag)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Flèche à tête chercheuse') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Flèche à tête chercheuse', cap_type = 'mag', cap_classe_initiale = @c,
  cap_description = '<p>À partir du niveau 4, l''archer-mage peut, une fois par jour, tirer une flèche sur une cible qu''il a déjà vue. Pour peu que la cible soit à portée, la flèche contourne les obstacles pour aller la toucher (en tournant à l''angle des couloirs, etc.). Seuls les obstacles infranchissables peuvent stopper la flèche. Ce pouvoir magique ne tient aucun compte des modificateurs dont bénéficie normalement une cible camouflée ou à couvert. Cet important détail excepté, le jet d''attaque s''effectue normalement. Utiliser ce pouvoir est une action simple (qui comprend le tir de la flèche).</p>'
WHERE cap_id = @k;
-- Flèche de phase (Mag)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Flèche de phase') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Flèche de phase', cap_type = 'mag', cap_classe_initiale = @c,
  cap_description = '<p>Une fois par jour, un archer-mage de niveau 6 peut tirer une flèche sur une cible qu''il a déjà vue et qui doit se trouver à portée. La flèche file vers la cible en ligne droite, traversant tous les obstacles non magiques (elle est stoppée par n''importe quelle barrière magique). Le jet d''attaque s''effectue normalement, mais sans compter les bonus que la cible doit à son armure et à un éventuel camouflage ou abri. Ce pouvoir est magique. Utiliser ce pouvoir est une action simple (qui comprend le tir de la flèche).</p>'
WHERE cap_id = @k;
-- Pluie de flèches (Mag)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Pluie de flèches') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Pluie de flèches', cap_type = 'mag', cap_classe_initiale = @c,
  cap_description = '<p>Dès le niveau 8, le personnage acquiert ce pouvoir magique qu''il peut utiliser une fois par jour, à la place de ses attaques normales. Quand il y fait appel, il tire une flèche sur chaque cible à portée, jusqu''à un maximum d''une par niveau d''archer-mage. Toutes ces attaques utilisent son bonus de base correspondant à sa première attaque du round et il ne peut tirer plus d''une flèche par cible.</p>'
WHERE cap_id = @k;
-- Flèche de mort (Mag)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Flèche de mort') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Flèche de mort', cap_type = 'mag', cap_classe_initiale = @c,
  cap_description = '<p>Au niveau 10, l''archer-mage peut créer une flèche de mort. S''il touche sa cible, cette dernière doit réussir un jet de Vigueur (DD 20) sous peine de mourir dans l''instant. La fabrication de la flèche exige une journée entière, et elle ne fonctionne que pour son créateur. La magie ne dure qu''un an, et un archer-mage ne peut jamais avoir plus d''une flèche de mort en même temps.</p>'
WHERE cap_id = @k;

-- ------------------------------------------------------------ Archimage
SET @c := (SELECT cla_id FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 2
             AND TRIM(cla_nom) IN ('Archimage') ORDER BY cla_id LIMIT 1);
UPDATE dd_classes SET
  cla_nom = 'Archimage',
  cla_abreviation = 'Arc',
  cla_dV = 4,
  cla_pointsCompetences = 2,
  cla_niveauMax = 5,
  cla_conditions = '<p><strong>Compétences.</strong> Degré de maîtrise de 15 en Art de la magie, degré de maîtrise de 15 en Connaissances (mystères).</p>
<p><strong>Dons.</strong> Talent (Art de la magie), École renforcée dans deux écoles de magie différentes.</p>
<p><strong>Sorts.</strong> Faculté de lancer des sorts profanes de 7e niveau et connaissance de sorts du 5e niveau d''au moins cinq écoles de magie différentes.</p>',
  cla_armes = '<p>L''archimage ne reçoit aucune formation au maniement des armes ou au port des armures.</p>'
WHERE cla_id = @c;
DELETE FROM dd_classe_competence WHERE ccomp_cla_id = @c;
INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @c, comp_id, NULL FROM dd_competences
WHERE comp_ruleset_var_id = @ddver AND TRIM(comp_nom) IN ('Art de la magie', 'Concentration', 'Connaissances (architecture et ingénierie)', 'Connaissances (exploration souterraine)', 'Connaissances (folklore local)', 'Connaissances (géographie)', 'Connaissances (histoire)', 'Connaissances (mystères)', 'Connaissances (nature)', 'Connaissances (noblesse et royauté)', 'Connaissances (plans)', 'Connaissances (religion)', 'Fouille', 'Profession');
INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @c, comp_id, 'alchimie' FROM dd_competences
WHERE comp_ruleset_var_id = @ddver AND comp_parent_id IS NULL AND TRIM(comp_nom) = 'Artisanat' LIMIT 1;
-- Sorts (archimage)
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Sorts (archimage)', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Sorts (archimage)' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Sorts (archimage)' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = NULL, cap_choix_mode = NULL,
  cap_description = '<p>À chaque nouveau niveau d''archimage, le personnage obtient un niveau effectif de jeteur de sorts pour une de ses classes précédentes pratiquant la magie profane et dont il maîtrise le 7e niveau de sorts (s''il possède plusieurs classes satisfaisant à cette condition, le niveau effectif ne s''applique qu''à l''une d''entre elles, au choix du personnage). Il obtient les sorts par jour (ainsi que les sorts connus, le cas échéant) et le niveau de lanceur de sorts d''un personnage de son niveau effectif. Néanmoins, il ne gagne aucun des autres avantages accompagnant habituellement ce niveau, tels qu''une meilleure chance de repousser ou d''intimider les morts-vivants, de nouveaux dons de métamagie ou de création d''objets, etc.</p>'
WHERE cap_id = @k;
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 1, NULL, 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Grand arcane
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Grand arcane') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Grand arcane', cap_type = NULL, cap_classe_initiale = @c,
  cap_description = '<p>L''archimage a l''occasion d''apprendre l''un des secrets de la liste suivante en sacrifiant de façon permanente l''un de ses emplacements de sorts existant (il ne peut sacrifier ainsi les emplacements du plus haut niveau de sort auquel il a accès). La description de chaque pouvoir indique le niveau d''emplacement de sort minimal qu''il faut sacrifier pour l''obtenir.</p>
<p>S''il le désire, un archimage peut choisir de sacrifier un emplacement de sort d''un niveau supérieur à celui exigé pour obtenir un grand arcane.</p>
<p><strong>Feu profane (Sur).</strong> L''archimage obtient le pouvoir de canaliser l''énergie d''un sort de magie profane en feu profane, qui se manifeste comme un trait d''énergie magique brute. Le trait est une attaque de contact à distance avec une portée longue (120 mètres + 12 mètres/niveau d''archimage), qui inflige 1d6 points de dégâts par niveau de classe de l''archimage plus 1d6 points de dégâts par niveau du sort canalisé. Ce pouvoir coûte un emplacement de sort de 9e niveau.</p>
<p><strong>Maîtrise de formation.</strong> L''archimage est capable d''altérer les sorts à zone d''effet ou à effet qui utilisent l''une des formes suivantes : cône, cylindre, émanation, étendue et rayonnement. Cela lui permet de créer des espaces dans la zone d''effet ou dans l''effet qui ne sont pas affectés par le sort. Les dimensions minimales d''une zone sont celles d''un cube de 1,50 mètre d''arête. Par exemple, un archimage pourrait lancer une boule de feu et laisser un trou là où se trouve un allié, évitant ainsi qu''il ne subisse les dégâts du feu. De plus, les sorts façonnables ont une dimension minimale de 1,50 mètre au lieu de 3 mètres. Ce pouvoir coûte un emplacement de sort du 6e niveau.</p>
<p><strong>Maîtrise des énergies.</strong> L''archimage est capable d''altérer un sort de magie profane au moment où il est lancé afin d''exploiter une énergie destructive différente de celle employée normalement par le sort. Ce pouvoir ne peut affecter que les sorts relevant des registres suivants : acide, électricité, feu, froid ou son. Le temps d''incantation du sort est inchangé. L''archimage décide d''utiliser ou non ce pouvoir et du type d''énergie employée au début de l''incantation. Ce pouvoir coûte un emplacement de sort du 8e niveau.</p>
<p><strong>Maîtrise du contresort.</strong> Lorsque l''archimage contre un sort, il est renvoyé à son lanceur comme s''il était affecté pleinement par le sort renvoi des sorts. Si le sort visé ne peut être affecté par renvoi des sorts, alors il est simplement contré. Ce pouvoir coûte un emplacement de sort du 7e niveau.</p>
<p><strong>Portée profane (Sur).</strong> L''archimage est capable d''utiliser ses sorts ayant une portée de contact sur des cibles distantes de 9 mètres ou moins. Il doit réussir une attaque de contact à distance. Le pouvoir de portée profane peut être choisi une deuxième fois, ce qui augmente sa portée à 18 mètres. Ce pouvoir coûte un emplacement de sort du 7e niveau.</p>
<p><strong>Pouvoir magique.</strong> Lorsque l''archimage choisit ce pouvoir, il peut sacrifier l''un de ses emplacements de sort (qui n''a pas déjà été sacrifié pour un autre pouvoir) pour préparer de façon définitive l''un de ses sorts en tant que pouvoir magique utilisable deux fois par jour. Lorsqu''il lance ce sort, l''archimage n''a nul besoin de composantes autres qu''un éventuel sacrifice en PX. Néanmoins, si le sort s''accompagne d''une composante matérielle coûteuse, il doit sacrifier un nombre de PX égal à dix fois le prix en po de cette composante à chaque utilisation du pouvoir magique. Ce pouvoir coûte un emplacement de sort du 5e niveau et un emplacement de sort d''un niveau correspondant à celui du sort transformé en pouvoir magique.</p>
<p>L''archimage peut choisir de transformer un sort métamagique en pouvoir magique, mais il doit sacrifier un emplacement du niveau de sort modifié.</p>
<p>L''archimage peut sacrifier un emplacement de sort de niveau plus élevé que nécessaire afin de disposer de plus d''utilisations quotidiennes du pouvoir magique. Sacrifier un emplacement de sort supérieur de 3 niveaux donne droit à quatre utilisations par jour, et un emplacement de sort supérieur de 6 niveaux permet six utilisations par jour.</p>
<p>Si l''archimage prend plusieurs fois ce pouvoir de grand arcane, il peut choisir le même sort (ce qui augmente le nombre d''utilisations quotidiennes) ou un autre sort.</p>
<p><strong>Puissance magique.</strong> Ce pouvoir augmente le niveau de lanceur de sorts effectif de l''archimage de +1, mais uniquement pour ce qui est de déterminer les valeurs variables d''un sort (comme la portée et les dégâts infligés) et les tests de niveau de lanceur de sorts. Ce pouvoir coûte un emplacement de sort du 5e niveau.</p>'
WHERE cap_id = @k;

-- ------------------------------------------------------------ Arpenteur d'horizon
SET @c := (SELECT cla_id FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 2
             AND TRIM(cla_nom) IN ('Arpenteur d''horizon') ORDER BY cla_id LIMIT 1);
UPDATE dd_classes SET
  cla_nom = 'Arpenteur d''horizon',
  cla_abreviation = 'AH',
  cla_dV = 8,
  cla_pointsCompetences = 4,
  cla_niveauMax = 10,
  cla_conditions = '<p><strong>Compétence.</strong> Degré de maîtrise de 8 en Connaissances (géographie).</p>
<p><strong>Dons.</strong> Endurance.</p>',
  cla_armes = '<p>L''arpenteur d''horizon ne reçoit aucune formation au maniement des armes ou au port des armures.</p>'
WHERE cla_id = @c;
DELETE FROM dd_classe_competence WHERE ccomp_cla_id = @c;
INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @c, comp_id, NULL FROM dd_competences
WHERE comp_ruleset_var_id = @ddver AND TRIM(comp_nom) IN ('Connaissances (géographie)', 'Déplacement silencieux', 'Détection', 'Diplomatie', 'Discrétion', 'Dressage', 'Équilibre', 'Équitation', 'Escalade', 'Langue', 'Perception auditive', 'Profession', 'Survie');
-- Maîtrise de terrain
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Maîtrise de terrain') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Maîtrise de terrain', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>À chaque niveau, il ajoute un terrain de la liste qui suit à son répertoire. La maîtrise de terrain confère à l''arpenteur d''horizon un bonus sur les tests de compétences utiles sur ce terrain, ou un autre avantage similaire. L''arpenteur d''horizon apprend aussi à combattre les créatures dangereuses habitant généralement sur ce type de terrain. Il obtient alors un bonus d''intuition de +1 sur les jets d''attaque et de dégâts contre les créatures dont la description mentionne spécifiquement le terrain maîtrisé sur la ligne Environnement. Les avantages de la maîtrise de terrain sont inhérents au personnage et il les possède où qu''il se trouve. Il conserve ses bonus de maîtrise de terrain aux tests de compétence et aux jets d''attaque et de dégâts même lorsqu''il ne se trouve pas sur le terrain en question.</p>
<p><strong>Aquatique.</strong> Le personnage bénéficie soit d''un bonus d''aptitude de +4 sur les tests de Natation, soit d''un bonus de +3 mètres à la vitesse de nage s''il en a une. Il obtient un bonus d''intuition de +1 sur les jets d''attaque et de dégâts contre les créatures aquatiques.</p>
<p><strong>Collines.</strong> Le personnage bénéficie d''un bonus d''aptitude de +4 sur les tests de Perception auditive. Il obtient un bonus d''intuition de +1 sur les jets d''attaque et de dégâts contre les créatures des collines.</p>
<p><strong>Déserts.</strong> Le personnage est immunisé contre la fatigue et les effets qui devraient l''épuiser ne font que le fatiguer. Il obtient un bonus d''intuition de +1 sur les jets d''attaque et de dégâts contre les créatures des déserts.</p>
<p><strong>Forêts.</strong> Le personnage bénéficie d''un bonus d''aptitude de +4 sur les tests de Discrétion. Il obtient un bonus d''intuition de +1 sur les jets d''attaque et de dégâts contre les créatures des forêts.</p>
<p><strong>Marécages.</strong> Le personnage bénéficie d''un bonus d''aptitude de +4 sur les tests de Déplacement silencieux. Il obtient un bonus d''intuition de +1 sur les jets d''attaque et de dégâts contre les créatures des marécages.</p>
<p><strong>Montagnes.</strong> Le personnage bénéficie soit d''un bonus d''aptitude de +4 sur les tests d''Escalade, soit d''un bonus de +3 mètres sur sa vitesse d''escalade s''il en a une. Il obtient un bonus d''intuition de +1 sur les jets d''attaque et de dégâts contre les créatures des montagnes.</p>
<p><strong>Plaines.</strong> Le personnage bénéficie d''un bonus d''aptitude de +4 sur les tests de Détection. Il obtient un bonus d''intuition de +1 sur les jets d''attaque et de dégâts contre les créatures des plaines.</p>
<p><strong>Souterrains.</strong> Le personnage bénéficie de la vision dans le noir avec une portée de 18 mètres. S''il possède déjà la vision dans le noir par une autre source, sa portée passe alors à 36 mètres. Il obtient un bonus d''intuition de +1 sur les jets d''attaque et de dégâts contre les créatures des souterrains.</p>'
WHERE cap_id = @k;
-- Maîtrise de terrain planaire
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Maîtrise de terrain planaire') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Maîtrise de terrain planaire', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>La maîtrise de terrain planaire fonctionne comme la maîtrise de terrain ordinaire, mais l''arpenteur peut choisir un type de terrain planaire à chaque niveau. Il peut aussi choisir un type de terrain ordinaire à la place d''un terrain planaire.</p>
<p><strong>Aléatoire (planaire).</strong> Le personnage a appris à utiliser à son avantage les propriétés changeantes des plans tels que les Limbes et le plan de l''Ombre, ce qui lui permet de s''y déplacer plus rapidement. Il peut anticiper les changements dans les plans qui vont l''emmener plus près de sa destination, ce qui lui permet d''utiliser un pouvoir magique similaire à porte dimensionnelle (avec un niveau de lanceur de sorts égal à son niveau global) une fois tous les 1d4 rounds. Il obtient un bonus d''intuition de +1 sur les jets d''attaque et de dégâts contre les élémentaires et les Extérieurs originaires d''un plan changeant, comme les slaads et les molosses de l''ombre.</p>
<p><strong>Aligné (planaire).</strong> Le personnage a le pouvoir instinctif d''imiter l''alignement dominant du plan sur lequel il se trouve. Il ne subit aucun des malus imposés par un alignement contraire à celui du plan et les sorts et pouvoirs qui affectent les créatures de l''alignement opposé (comme ténèbres maudites) sont sans effet sur lui. Il est considéré comme ayant l''alignement du plan en ce qui concerne la magie, mais le comportement du personnage et ses aptitudes de classe liées à l''alignement ne sont pas affectées.</p>
<p><strong>Caverneuse (planaire).</strong> Le personnage obtient la perception des vibrations à une portée de 9 mètres. Il obtient un bonus d''intuition de +1 sur les jets d''attaque et de dégâts contre les élémentaires et les Extérieurs du sous-type de la Terre.</p>
<p><strong>Flambant (planaire).</strong> Grâce à cette maîtrise de terrain planaire, le personnage bénéficie d''une résistance au feu (20). Il obtient un bonus d''intuition de +1 sur les jets d''attaque et de dégâts contre les élémentaires et les Extérieurs du sous-type du Feu.</p>
<p><strong>Froid (planaire).</strong> Grâce à cette maîtrise de terrain planaire, le personnage bénéficie d''une résistance au froid (20). Il obtient un bonus d''intuition de +1 sur les jets d''attaque et de dégâts contre les élémentaires et les Extérieurs du sous-type du Froid.</p>
<p><strong>Sans-poids (planaire).</strong> Le personnage bénéficie d''un bonus de +9 mètres à sa vitesse de vol sur les plans sans gravité ou à gravité directionnelle subjective, comme le plan Astral ou le plan élémentaire de l''Air. Il obtient un bonus d''intuition de +1 sur les jets d''attaque et de dégâts contre les créatures originaires du plan Astral, du plan élémentaire de l''Air et du plan Éthéré, comme les githyankis ou les élémentaires de l''Air. (Une créature est considérée comme originaire d''un plan si celui-ci est cité dans la ligne Environnement de son profil.)</p>
<p><strong>Autre (planaire).</strong> Si votre campagne utilise d''autres plans de votre invention, il vous faut concevoir d''autres maîtrises de terrain planaire.</p>'
WHERE cap_id = @k;

-- ------------------------------------------------------------ Assassin
SET @c := (SELECT cla_id FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 2
             AND TRIM(cla_nom) IN ('Assassin') ORDER BY cla_id LIMIT 1);
UPDATE dd_classes SET
  cla_nom = 'Assassin',
  cla_abreviation = 'As',
  cla_dV = 6,
  cla_pointsCompetences = 4,
  cla_niveauMax = 10,
  cla_conditions = '<p><strong>Alignement.</strong> Mauvais.</p>
<p><strong>Compétences.</strong> Degré de maîtrise de 4 en Déguisement, degré de maîtrise de 8 en Déplacement silencieux, degré de maîtrise de 8 en Discrétion.</p>
<p><strong>Spécial.</strong> Pour être accepté au sein de sa guilde, le personnage doit tuer une cible désignée.</p>',
  cla_armes = '<p>L''assassin est formé au maniement des armes permettant de frapper sans bruit et de donner la mort discrètement, de près ou de loin : arbalète (lourde, légère ou de poing), arc court (composite ou non), dague, dard, épée courte, matraque et rapière. Il est également formé au port de l''armure légère, mais pas au maniement des boucliers.</p>',
  cla_sorts = '<p>L''assassin choisit ses sorts dans la liste suivante :</p>
<p><strong>1er niveau :</strong> brume de dissimulation, coup au but, déguisement, détection du poison, feuille morte, saut, sommeil et son imaginaire.</p>
<p><strong>2e niveau :</strong> alignement indétectable, grâce féline, invisibilité, modification d''apparence, passage sans traces, pattes d''araignée, ruse du renard, ténèbres et texte illusoire.</p>
<p><strong>3e niveau :</strong> antidétection, cercle magique contre le Bien, détection faussée, simulacre de vie, sommeil profond et ténèbres profondes.</p>
<p><strong>4e niveau :</strong> bagou, clairvoyance/clairaudience, empoisonnement, invisibilité suprême, liberté de mouvement, localisation de créature, modification de mémoire et porte dimensionnelle.</p>'
WHERE cla_id = @c;
DELETE FROM dd_classe_competence WHERE ccomp_cla_id = @c;
INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @c, comp_id, NULL FROM dd_competences
WHERE comp_ruleset_var_id = @ddver AND TRIM(comp_nom) IN ('Acrobaties', 'Artisanat', 'Bluff', 'Contrefaçon', 'Crochetage', 'Décryptage', 'Déguisement', 'Déplacement silencieux', 'Désamorçage', 'Détection', 'Diplomatie', 'Discrétion', 'Équilibre', 'Escalade', 'Escamotage', 'Évasion', 'Fouille', 'Intimidation', 'Maîtrise des cordes', 'Natation', 'Perception auditive', 'Psychologie', 'Renseignements', 'Saut', 'Utilisation d''objets magiques');
-- Attaque sournoise
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Attaque sournoise', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Attaque sournoise' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Attaque sournoise' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = NULL, cap_choix_mode = NULL,
  cap_description = '<p>Cette aptitude est en tous points similaire à celle du roublard du même nom. Les dégâts supplémentaires augmentent de +1d6 tous les niveaux impairs (niveaux 3, 5, 7 et 9). Si l''assassin bénéficie également de l''attaque sournoise par le biais d''une autre classe (par exemple, roublard), les dégâts supplémentaires se cumulent.</p>'
WHERE cap_id = @k;
-- variante : la capacité partagée « Attaque sournoise » n'est plus liée à cette classe
DELETE cc FROM dd_classe_capacite cc JOIN dd_capacites_speciales cs ON cs.cap_id = cc.cc_cap_id
WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) = 'Attaque sournoise' AND NOT (cs.cap_classe_initiale <=> @c);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 1, '+1d6', 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 3, '+2d6', 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 5, '+3d6', 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 7, '+4d6', 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 9, '+5d6', 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Attaque mortelle
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Attaque mortelle') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Attaque mortelle', cap_type = NULL, cap_classe_initiale = @c,
  cap_description = '<p>Si l''assassin étudie sa cible pendant au moins 3 rounds puis réussit une attaque sournoise infligeant des dégâts, le coup peut paralyser ou tuer la victime (au choix de l''assassin). Tout au long de la phase d''observation, le personnage peut exécuter d''autres actions, à condition que son attention ne dévie pas de la cible et que cette dernière ne le repère pas (ou ne voit pas en lui un ennemi). Si la victime rate son jet de Vigueur (DD 10 + niveau de l''assassin + modificateur d''Int de l''assassin) contre un coup mortel, elle meurt. Si son agresseur cherchait juste à la paralyser, elle se retrouve sans défense, incapable d''agir pendant 1d6 rounds, + 1 round par niveau de l''assassin. Si la cible réussit son jet de sauvegarde, le coup inflige juste les dégâts normaux pour une attaque sournoise. Une fois que l''assassin a étudié sa proie, il doit porter son attaque dans les 3 rounds qui suivent, sous peine de devoir recommencer à l''examiner. De même, si la victime réussit son jet de sauvegarde, 3 nouveaux rounds sont nécessaires à l''assassin pour tenter une nouvelle attaque mortelle (à condition, bien sûr, que la cible n''ait pas remarqué d''où venait le coup précédent).</p>'
WHERE cap_id = @k;
-- Sorts
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Sorts (assassin)') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Sorts (assassin)', cap_type = NULL, cap_classe_initiale = @c,
  cap_description = '<p>Dès le niveau 1, l''assassin a la possibilité de lancer quelques sorts profanes. Pour ce faire, il doit avoir une Intelligence au moins égale à 10 + niveau du sort, ce qui signifie qu''il ne peut pas jeter le moindre sort s''il a 10 ou moins dans cette caractéristique. Ses sorts en bonus sont basés sur l''Intelligence et le jet de sauvegarde de la cible s''accompagne d''un DD égal à 10 + niveau du sort + modificateur d''Intelligence de l''assassin (le cas échéant). Si la Table : sorts connus par l''assassin indique que le personnage a 0 sort d''un niveau donné, cela signifie qu''il a juste droit à ses éventuels sorts en bonus. Si son Intelligence ne lui confère pas le bonus nécessaire, il ne peut pas lancer de sorts du niveau indiqué. L''assassin prépare et lance ses sorts de la même manière que le barde.</p>
<p>Lorsqu''il atteint le niveau 6, et tous les 2 niveaux après cela (niveaux 8 et 10), un assassin peut choisir d''apprendre un nouveau sort à la place de l''un de ceux qu''il connaît déjà. Le niveau du nouveau sort doit être identique à celui du sort oublié, et ce niveau doit être inférieur de 2 niveaux au plus haut niveau de sorts accessibles au personnage. Un assassin ne peut échanger qu''un seul sort à chaque fois, et doit choisir s''il procède à un échange en même temps qu''il apprend de nouveaux sorts lors du passage de niveau.</p>'
WHERE cap_id = @k;
-- Utilisation du poison
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Utilisation de poison', 'Utilisation du poison') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Utilisation du poison', cap_type = NULL, cap_classe_initiale = @c,
  cap_description = '<p>L''assassin est entraîné à utiliser du poison ; il ne risque jamais de s''empoisonner accidentellement quand il enduit son arme d''une substance nocive.</p>'
WHERE cap_id = @k;
-- Bonus aux sauvegardes contre le poison
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Bonus aux sauvegardes contre le poison') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Bonus aux sauvegardes contre le poison', cap_type = NULL, cap_classe_initiale = @c,
  cap_description = '<p>Au niveau 2, l''assassin obtient un bonus de +1 aux jets de sauvegarde contre tous les poisons. Il augmente ensuite tous les niveaux pairs (+1 au niveau 2, +2 au niveau 4, +3 au niveau 6, etc.).</p>'
WHERE cap_id = @k;
-- Esquive instinctive (Ext)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Esquive instinctive') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Esquive instinctive', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>Dès le niveau 2, l''assassin conserve son éventuel bonus de Dextérité à la CA même s''il est pris au dépourvu ou attaqué par un adversaire invisible (il perd toujours ce bonus s''il est immobilisé). Si un assassin possède déjà cette aptitude grâce à une autre classe, il obtient l''esquive instinctive supérieure (voir ci-dessous) au lieu de l''esquive instinctive.</p>'
WHERE cap_id = @k;
-- Esquive instinctive supérieure (Ext)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Esquive instinctive supérieure') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Esquive instinctive supérieure', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>Au niveau 5, l''assassin ne peut plus être pris en tenaille, car il pare les assauts de ses adversaires avec autant d''aisance que s''ils venaient tous de la même direction. Les roublards ne peuvent plus lui porter d''attaques sournoises en le prenant en tenaille, à moins d''avoir au moins 4 niveaux de roublard de plus que le personnage n''a de niveaux d''assassin.</p>
<p>Si un personnage possède déjà l''aptitude d''esquive instinctive grâce à une autre classe, il obtient l''esquive instinctive supérieure dès le niveau 2 d''assassin et les niveaux des différentes classes proposant cette aptitude se cumulent pour déterminer le niveau de roublard nécessaire pour le prendre en tenaille.</p>'
WHERE cap_id = @k;
-- Discrétion totale (Sur)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Discrétion totale') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Discrétion totale', cap_type = 'sur', cap_classe_initiale = @c,
  cap_description = '<p>L''assassin peut faire appel à sa compétence de Discrétion même si on l''observe. Du moment qu''il se trouve à moins de 3 mètres d''une zone d''ombre, il peut se cacher au vu et au su de tout le monde (à noter qu''il ne peut se fondre dans sa propre ombre ; il doit forcément s''agir de celle d''un autre ou d''un objet).</p>'
WHERE cap_id = @k;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Brume de dissimulation'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Coup au but'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Déguisement'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Détection du poison'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Feuille morte'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Saut'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Sommeil'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Son imaginaire'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Alignement indétectable'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Grâce féline'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Invisibilité'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Modification d''apparence'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Passage sans trace'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Pattes d''araignées'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Ruse de renard'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Ténèbres'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Antidétection'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Cercle magique contre le bien'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Détection faussée'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Simulacre de vie'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Sommeil profond'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Ténèbres profondes'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 4 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Bagou'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 4 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Clairaudience/clairvoyance'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 4 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Empoisonnement'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 4 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Invisibilité suprême'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 4 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Liberté de mouvement'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 4 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Localisation de créature'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 4 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Modification de mémoire'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 4 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Porte dimensionnelle'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;

-- ------------------------------------------------------------ Champion occultiste
SET @c := (SELECT cla_id FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 2
             AND TRIM(cla_nom) IN ('Champion occultiste') ORDER BY cla_id LIMIT 1);
UPDATE dd_classes SET
  cla_nom = 'Champion occultiste',
  cla_abreviation = 'CO',
  cla_dV = 6,
  cla_pointsCompetences = 2,
  cla_niveauMax = 10,
  cla_conditions = '<p><strong>Maniement des armes.</strong> Doit être formé au maniement de toutes les armes de guerre.</p>
<p><strong>Sorts.</strong> Faculté de lancer des sorts du 3e niveau.</p>',
  cla_armes = '<p>Le champion occultiste ne reçoit aucune formation au maniement des armes ou au port des armures.</p>'
WHERE cla_id = @c;
DELETE FROM dd_classe_competence WHERE ccomp_cla_id = @c;
INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @c, comp_id, NULL FROM dd_competences
WHERE comp_ruleset_var_id = @ddver AND TRIM(comp_nom) IN ('Art de la magie', 'Artisanat', 'Concentration', 'Connaissances (mystères)', 'Connaissances (noblesse et royauté)', 'Décryptage', 'Équitation', 'Natation', 'Psychologie', 'Saut');
-- Don supplémentaire
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Don supplémentaire') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Don supplémentaire', cap_type = NULL, cap_classe_initiale = @c,
  cap_description = '<p>Au niveau 1, le champion occultiste peut choisir un don parmi la liste des dons supplémentaires accessibles aux guerriers. Ces dons sont obtenus en plus de ceux que n''importe quel personnage acquiert tous les trois niveaux. Le personnage doit satisfaire à toutes les conditions requises pour chaque don, y compris les quatre niveaux de guerrier pour la Spécialisation martiale.</p>'
WHERE cap_id = @k;
-- Sorts (champion occultiste)
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Sorts (champion occultiste)', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Sorts (champion occultiste)' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Sorts (champion occultiste)' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = NULL, cap_choix_mode = NULL,
  cap_description = '<p>À partir du niveau 2, à chaque nouveau niveau de champion occultiste, le personnage obtient un niveau effectif de jeteur de sorts pour une de ses classes précédentes pratiquant la magie profane et dont il maîtrise le 3e niveau de sorts (s''il possède plusieurs classes satisfaisant à cette condition, le niveau effectif ne s''applique qu''à l''une d''entre elles, au choix du personnage). Il obtient les sorts par jour (ainsi que les sorts connus, le cas échéant) et le niveau de lanceur de sorts d''un personnage de son niveau effectif. Néanmoins, il ne gagne aucun des autres avantages accompagnant habituellement ce niveau, tels qu''une meilleure chance de repousser ou d''intimider les morts-vivants, de nouveaux dons de métamagie ou de création d''objets, etc.</p>'
WHERE cap_id = @k;
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 2, NULL, 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);

-- ------------------------------------------------------------ Chevalier noir
SET @c := (SELECT cla_id FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 2
             AND TRIM(cla_nom) IN ('Chevalier noir') ORDER BY cla_id LIMIT 1);
UPDATE dd_classes SET
  cla_nom = 'Chevalier noir',
  cla_abreviation = 'CN',
  cla_dV = 10,
  cla_pointsCompetences = 2,
  cla_niveauMax = 10,
  cla_conditions = '<p><strong>Alignement.</strong> Mauvais.</p>
<p><strong>Bonus de base à l''attaque.</strong> +6.</p>
<p><strong>Compétences.</strong> Degré de maîtrise de 2 en Connaissances (religion), degré de maîtrise de 5 en Discrétion.</p>
<p><strong>Dons.</strong> Attaque en puissance, Enchaînement, Science de la destruction.</p>
<p><strong>Spécial.</strong> Le chevalier noir doit avoir établi un contact amical avec un Extérieur malfaisant (convoqué par lui-même ou quelqu''un d''autre).</p>',
  cla_armes = '<p>Le chevalier noir est formé au maniement des armes courantes et de guerre, ainsi que des boucliers (à l''exception du pavois). Il est également formé au port de toutes les armures.</p>',
  cla_sorts = '<p>Le chevalier noir choisit ses sorts dans la liste suivante :</p>
<p><strong>1er niveau :</strong> anathème, arme magique, blessure légère, convocation de monstres I (1), corruption d''arme (2), frayeur, soins légers.</p>
<p><strong>2e niveau :</strong> blessure modérée, convocation de monstres II (1), force de taureau, fracassement, mise à mort, soins modérés, splendeur de l''aigle, ténèbres.</p>
<p><strong>3e niveau :</strong> blessure grave, contagion, convocation de monstres III (1), protection contre les énergies destructives, soins importants, ténèbres profondes.</p>
<p><strong>4e niveau :</strong> blessure critique, convocation de monstres IV (1), empoisonnement, liberté de mouvement, soins intensifs.</p>
<p>(1) Uniquement pour appeler des créatures maléfiques.</p>
<p>(2) Voir ci-dessous.</p>'
WHERE cla_id = @c;
DELETE FROM dd_classe_competence WHERE ccomp_cla_id = @c;
INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @c, comp_id, NULL FROM dd_competences
WHERE comp_ruleset_var_id = @ddver AND TRIM(comp_nom) IN ('Artisanat', 'Concentration', 'Connaissances (religion)', 'Diplomatie', 'Discrétion', 'Dressage', 'Équitation', 'Intimidation', 'Premiers secours', 'Profession');
-- Aura de Mal (Ext)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Aura de Mal') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Aura de Mal', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>Un chevalier noir génère une puissante aura de Mal (voir le sort détection du Mal), égale à son niveau de chevalier noir plus son éventuel niveau de prêtre.</p>'
WHERE cap_id = @k;
-- Détection du Bien
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Détection du bien', 'Détection du Bien') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Détection du Bien', cap_type = 'mag', cap_classe_initiale = @c,
  cap_description = '<p>À volonté, le chevalier noir peut faire appel à ce pouvoir magique reproduisant l''effet du sort du même nom.</p>'
WHERE cap_id = @k;
-- Utilisation du poison
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Utilisation du poison') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Utilisation du poison', cap_type = NULL, cap_classe_initiale = @c,
  cap_description = '<p>Le chevalier noir est entraîné à utiliser du poison ; il ne risque jamais de s''empoisonner accidentellement quand il enduit son arme d''une substance nocive.</p>'
WHERE cap_id = @k;
-- Bénédiction impie (Sur)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Bénédiction impie') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Bénédiction impie', cap_type = 'sur', cap_classe_initiale = @c,
  cap_description = '<p>Si la valeur de Charisme du chevalier noir lui confère un bonus, celui-ci s''applique à tous les jets de sauvegarde du personnage.</p>'
WHERE cap_id = @k;
-- Sorts (chevalier noir)
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Sorts (chevalier noir)', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Sorts (chevalier noir)' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Sorts (chevalier noir)' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = NULL, cap_choix_mode = NULL,
  cap_description = '<p>Dès le niveau 1, le chevalier noir a la possibilité de lancer quelques sorts divins. Pour ce faire, il doit avoir une Sagesse au moins égale à 10 + niveau du sort, ce qui signifie qu''il ne peut pas jeter le moindre sort s''il a 10 ou moins dans cette caractéristique. Ses sorts en bonus sont basés sur la Sagesse et le jet de sauvegarde de la cible s''accompagne d''un DD égal à 10 + niveau du sort + modificateur de Sagesse du chevalier noir (le cas échéant). Si la Table : le chevalier noir indique que le personnage a 0 sort d''un niveau donné, cela signifie qu''il a juste droit à ses éventuels sorts en bonus. Le chevalier noir a accès à tous les sorts indiqués plus bas ; il les prépare et les lance de la même manière que le prêtre (mais ne peut pas les transformer spontanément en sorts de soins ou de blessure).</p>'
WHERE cap_id = @k;
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 1, NULL, 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Châtiment du Bien
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Châtiment du bien', 'Châtiment du Bien') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Châtiment du Bien', cap_type = 'sur', cap_classe_initiale = @c,
  cap_description = '<p>Une fois par jour, un chevalier noir de niveau 2 ou plus peut tenter de châtier une créature d''alignement bon par le biais d''une attaque de corps à corps normale. Dans ce cas, il ajoute son bonus de Charisme au résultat du jet d''attaque (si le modificateur de Charisme du personnage est un malus, il n''est pas pris en compte) et, en cas de coup au but, il inflige 1 point de dégâts supplémentaire par niveau. Par exemple, un chevalier noir de niveau 9 armé d''une épée longue occasionnera 1d8+9 points de dégâts, plus les bonus dus à sa Force ou son arme, si celle-ci est magique. Si le personnage utilise accidentellement ce pouvoir contre une créature qui n''est pas d''alignement bon, il ne se déclenche pas, mais le chevalier noir ne peut plus s''en servir de la journée.</p>
<p>Au niveau 5, puis à nouveau au niveau 10, le chevalier noir gagne une utilisation quotidienne supplémentaire de son aptitude de châtiment du Bien.</p>'
WHERE cap_id = @k;
-- Aura de désespoir (Sur)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Aura de désespoir') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Aura de désespoir', cap_type = 'sur', cap_classe_initiale = @c,
  cap_description = '<p>À partir du niveau 3, le chevalier noir dégage une aura provoquant l''abattement de ses ennemis : tous ceux qui se trouvent à moins de 3 mètres subissent un malus de –2 à tous leurs jets de sauvegarde.</p>'
WHERE cap_id = @k;
-- Contrôle des morts-vivants
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Contrôle des morts vivants', 'Contrôle des morts-vivants') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Contrôle des morts-vivants', cap_type = 'sur', cap_classe_initiale = @c,
  cap_description = '<p>Quand le chevalier noir atteint le niveau 3, il acquiert le pouvoir de contrôler et d''intimider les morts-vivants. Il affecte ces créatures comme un prêtre ayant deux niveaux de moins.</p>'
WHERE cap_id = @k;
-- Attaque sournoise
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Attaque sournoise', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Attaque sournoise' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Attaque sournoise' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = NULL, cap_choix_mode = NULL,
  cap_description = '<p>Cette aptitude, obtenue au niveau 4, est en tous points similaire à celle du roublard du même nom. Les dégâts supplémentaires augmentent de +1d6 tous les 3 niveaux suivants (niveaux 7 et 10). Si le chevalier noir bénéficie également de l''attaque sournoise par le biais d''une autre classe, les dégâts supplémentaires se cumulent.</p>'
WHERE cap_id = @k;
-- variante : la capacité partagée « Attaque sournoise » n'est plus liée à cette classe
DELETE cc FROM dd_classe_capacite cc JOIN dd_capacites_speciales cs ON cs.cap_id = cc.cc_cap_id
WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) = 'Attaque sournoise' AND NOT (cs.cap_classe_initiale <=> @c);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 4, '+1d6', 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 7, '+2d6', 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 10, '+3d6', 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Corruption d'arme
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Corruption d''arme', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Corruption d''arme' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Corruption d''arme' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = NULL, cap_choix_mode = NULL,
  cap_description = '<p>Les chevaliers noirs ont accès à un sort qui leur est propre, corruption d''arme, et qui est l''opposé du sort de paladin bénédiction d''arme. Au lieu d''améliorer l''efficacité de l''arme contre les adversaires d''alignement mauvais (à l''instar du sort de paladin), corruption d''arme rend une arme plus efficace contre les créatures d''alignement bon.</p>'
WHERE cap_id = @k;
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 1, NULL, 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Paladin déchu
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Paladin déchu', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Paladin déchu' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Paladin déchu' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = NULL, cap_choix_mode = NULL,
  cap_description = '<p>Les chevaliers noirs ayant également des niveaux de paladin (autrement dit, les paladins déchus) acquièrent des pouvoirs supplémentaires dépendant de leur niveau de paladin.</p>
<p>Un paladin déchu qui devient un chevalier noir gagne toutes les aptitudes suivantes, selon son niveau de paladin : 1–2 : Châtiment du Bien (1/jour). (En plus du pouvoir accordé à tous les chevaliers noirs.)</p>
<p>3–4 : Imposition des mains (Sur). Chaque jour, le chevalier noir peut se guérir d''un nombre de points de vie égal à son bonus de Charisme multiplié par son niveau. Ce pouvoir ne lui permet de soigner personne d''autre que lui-même et son serviteur fiélon.</p>
<p>5–6 : Dégâts de l''attaque sournoise augmentés de +1d6. Châtiment du Bien (2/jour).</p>
<p>7–8 : Convocation de fiélon (Mag). Une fois par jour, le paladin déchu peut lancer convocation de monstres I, mais uniquement pour appeler une créature maléfique. Pour ce qui est de ce pouvoir, son niveau de lanceur de sorts est égal au double de son niveau de chevalier noir.</p>
<p>9–10 : Écuyer mort-vivant. À partir du niveau 5, en plus de son serviteur fiélon, le paladin déchu bénéficie des services d''un écuyer squelette ou zombi (de taille M), qui ne peut pas être repoussé ou intimidé et qui acquiert les mêmes pouvoirs que le serviteur fiélon au fur et à mesure que le chevalier noir gagne des niveaux. Châtiment du Bien (3/jour).</p>
<p>11+ : Un personnage de ce niveau peut instantanément échanger autant de niveaux de paladin qu''il le souhaite contre des niveaux de chevalier noir. Son niveau global ne change pas. Si son niveau de paladin déchu tombe trop bas suite à cet échange, le personnage perd les pouvoirs correspondant aux niveaux échangés.</p>'
WHERE cap_id = @k;
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 1, NULL, 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Serviteur fiélon du chevalier noir
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Serviteur fiélon') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Serviteur fiélon', cap_type = 'mag', cap_classe_initiale = @c,
  cap_description = '<p>À partir du niveau 5, le chevalier noir peut appeler un serviteur fiélon, qui prend la forme d''un chat, d''une chauve-souris, d''un cheval, d''un corbeau, d''un crapaud, d''un poney ou d''un rat sanguinaire. Cette créature fiélon gagne des DV supplémentaires et des pouvoirs en fonction du niveau de son maître.</p>
<p>Le personnage ne peut pas avoir plus d''un serviteur fiélon à la fois. Si la créature meurt, le chevalier noir ne peut pas en appeler une autre avant trente jours. Le nouveau serviteur présente d''emblée les caractéristiques correspondant au niveau de son maître.</p>
<p>[[tab:classe-chevalier-noir-serviteur-fielon]]</p>
<p><strong>Niveau global.</strong> Le niveau total du personnage.</p>
<p><strong>DV sup.</strong> Le serviteur fiélon obtient des dés de vie supplémentaires (des d8), qui sont ajoutés à ses points de vie (avec le modificateur de Constitution habituel). Cette augmentation de dés de vie influe aussi sur ses bonus de base à l''attaque et aux sauvegardes.</p>
<p>Aj. d''armure naturelle. L''ajustement indiqué vient s''ajouter au bonus d''armure naturelle à la CA existant du serviteur fiélon.</p>
<p><strong>Aj. de Force.</strong> Ajoutez ce chiffre à la valeur de Force du serviteur.</p>
<p><strong>Int.</strong> La valeur d''Intelligence de la créature (qui est plus intelligente que les autres animaux de la même espèce). Les pouvoirs indiqués sur la colonne « Spécial » de la table sont décrits ci-dessous.</p>
<p><strong>Esquive extraordinaire (Ext).</strong> Si le serviteur fiélon est pris pour cible par une attaque autorisant un jet de Réflexes pour réduire de moitié les dégâts occasionnés, il l''évite totalement en cas de jet de sauvegarde réussi (même s''il le rate, l''attaque ne lui inflige que demi-dégâts).</p>
<p><strong>Lien télépathique (Sur).</strong> Le chevalier noir bénéficie d''un lien télépathique avec son serviteur tant que celui-ci reste distant de moins de 1,5 kilomètre. Il ne voit pas par les yeux de la créature, mais peut communiquer télépathiquement avec elle. À cause de la nature limitée du lien, seuls des sentiments généraux peuvent être transmis.</p>
<p>En raison du lien unissant le serviteur à son maître, celui-ci bénéficie des informations rapportées par son animal suite à la visite d''un lieu ou l''observation d''un objet.</p>
<p>Transfert d''effet magique. Si le chevalier noir le souhaite, tout sort (mais pas un pouvoir magique) qu''il lance sur lui-même peut également affecter son serviteur fiélon, à condition que ce dernier se trouve à moins de 1,50 mètre de distance. Si le sort a une durée autre qu''instantanée, il cesse d''affecter la créature si cette dernière s''éloigne trop de son maître (au-delà de 1,50 mètre). Dans ce cas, l''effet du sort ne reprend pas, même si la créature revient à côté du chevalier noir. Le personnage peut lancer directement sur son serviteur tout sort à portée personnelle. Ce transfert d''effet magique est permis même si, en temps normal, le sort ne devrait pas affecter une entité du type du serviteur (créature magique).</p>
<p><strong>Transfert de jet de sauvegarde.</strong> Le serviteur fiélon utilise son jet de sauvegarde de base ou celui de son maître, en prenant chaque fois le plus avantageux des deux. Le serviteur applique ses propres modificateurs de caractéristiques aux jets de sauvegarde et il n''obtient aucun autre bonus sur les jets de sauvegarde dont pourrait bénéficier le chevalier noir.</p>
<p><strong>Communication avec le maître (Ext).</strong> Si le niveau global du chevalier noir atteint 13, lui et son serviteur fiélon peuvent communiquer verbalement comme s''ils parlaient un langage commun. Les autres créatures qui viendraient à les entendre ne peuvent comprendre ce qu''ils se disent sans assistance magique.</p>
<p><strong>Lien du sang (Ext).</strong> Si le niveau global du chevalier noir atteint 16, le serviteur fiélon bénéficie d''un bonus de +2 aux jets d''attaque et de sauvegarde et à tous les tests s''il voit son maître menacé ou en danger. Ce bonus dure tant que le danger est immédiat ou apparent.</p>
<p><strong>Résistance à la magie (Ext).</strong> Si le niveau global du chevalier noir atteint 19, le serviteur obtient une résistance à la magie égale au niveau du chevalier noir + 5. Si un adversaire tente d''affecter la créature à l''aide de magie, il doit obtenir sur un test de niveau de lanceur de sorts (1d20 + niveau de lanceur de sorts) un résultat au moins égal à la résistance à la magie du serviteur fiélon.</p>'
WHERE cap_id = @k;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Anathème'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Arme magique'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Blessure légère'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Convocation de monstres I'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Corruption d''arme'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Frayeur'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Soins légers'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Blessure modérée'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Convocation de monstres II'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Force de taureau'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Fracassement'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Mise à mort'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Soins modérés'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Splendeur de l''aigle'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Ténèbres'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Blessure grave'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Contagion'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Convocation de monstres III'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Protection contre les énergies destructives'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Soins importants'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Ténèbres profondes'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 4 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Blessure critique'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 4 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Convocation de monstres IV'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 4 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Empoisonnement'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 4 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Liberté de mouvement'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 4 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Soins intensifs'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;

-- ------------------------------------------------------------ Disciple draconien
SET @c := (SELECT cla_id FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 2
             AND TRIM(cla_nom) IN ('Disciple draconien') ORDER BY cla_id LIMIT 1);
UPDATE dd_classes SET
  cla_nom = 'Disciple draconien',
  cla_abreviation = 'DD',
  cla_dV = 12,
  cla_pointsCompetences = 2,
  cla_niveauMax = 10,
  cla_conditions = '<p><strong>Race.</strong> Autre que dracon (ne peut déjà être un demi-dragon).</p>
<p><strong>Compétences.</strong> Degré de maîtrise de 8 en Connaissances (mystères).</p>
<p><strong>Langue.</strong> Doit parler le draconique.</p>
<p><strong>Sorts.</strong> Faculté de lancer des sorts profanes sans les préparer.</p>
<p><strong>Spécial.</strong> Le personnage doit choisir une race de dragon lorsqu''il prend son premier niveau de disciple draconien.</p>',
  cla_armes = '<p>Le disciple draconien ne reçoit aucune formation au maniement des armes ou au port des armures.</p>'
WHERE cla_id = @c;
DELETE FROM dd_classe_competence WHERE ccomp_cla_id = @c;
INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @c, comp_id, NULL FROM dd_competences
WHERE comp_ruleset_var_id = @ddver AND TRIM(comp_nom) IN ('Art de la magie', 'Artisanat', 'Concentration', 'Connaissances (architecture et ingénierie)', 'Connaissances (exploration souterraine)', 'Connaissances (folklore local)', 'Connaissances (géographie)', 'Connaissances (histoire)', 'Connaissances (mystères)', 'Connaissances (nature)', 'Connaissances (noblesse et royauté)', 'Connaissances (plans)', 'Connaissances (religion)', 'Détection', 'Diplomatie', 'Évasion', 'Fouille', 'Langue', 'Perception auditive', 'Profession', 'Renseignements');
UPDATE dd_classe_niveau SET cn_vigueur = 5, cn_volonte = 5 WHERE cn_cla_id = @c AND cn_niveau = 7;
-- Sorts en bonus (disciple draconien)
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Sorts en bonus (disciple draconien)', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Sorts en bonus (disciple draconien)' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Sorts en bonus (disciple draconien)' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = NULL, cap_choix_mode = NULL,
  cap_description = '<p>À certains niveaux de disciple draconien (voir la Table : le disciple draconien), le personnage obtient un sort en bonus similaire à ceux reçus pour une valeur de caractéristique primordiale élevée. Le personnage doit choisir à quelle classe de jeteur de sorts et à quel niveau de sort ce sort en bonus va s''appliquer. Une fois ce choix effectué, il ne peut être changé. Le sort en bonus peut s''appliquer à n''importe quel niveau de sort accessible au personnage.</p>'
WHERE cap_id = @k;
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 1, NULL, 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Augmentation d'armure naturelle
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Augmentation naturelle d''armure', 'Augmentation d''armure naturelle') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Augmentation d''armure naturelle', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>Aux niveaux 1, 4 et 7, le disciple draconien adopte une apparence se rapprochant de plus en plus de celle d''un dragon. Sur sa peau se forment des écailles luisantes, presque invisibles au début du processus, mais qui deviennent de plus en plus évidentes aux niveaux supérieurs. Cette transformation augmente l''éventuel bonus d''armure naturelle du personnage, selon les nombres indiqués par la Table : le disciple draconien (ces bonus ne sont pas cumulatifs). Le disciple adopte de plus en plus l''aspect physique de son ancêtre draconien au fur et à mesure que ses écailles s''épaississent.</p>'
WHERE cap_id = @k;
-- Griffes et morsure (Ext)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Griffes et morsure') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Griffes et morsure', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>Au niveau 2, le disciple draconien obtient des attaques de griffes et de morsure, qui infligent les dégâts indiqués sur la table suivante. Si le personnage dispose déjà d''attaques de griffes ou de morsure par ailleurs, il peut conserver la valeur de dégâts de son choix entre les deux.</p>
<p>[[tab:classe-disciple-draconien-griffes]]</p>
<p>Le disciple draconien est considéré comme étant formé au maniement de ses armes naturelles. Lors d''une action d''attaque à outrance, il peut porter une attaque de morsure avec son bonus de base à l''attaque maximal, et deux attaques de griffes avec un malus de –5. Le don Attaques multiples permet de réduire ses malus de –2 seulement.</p>'
WHERE cap_id = @k;
-- Augmentation de caractéristique
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Augmentation de caractéristiques', 'Augmentation de caractéristique') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Augmentation de caractéristique', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>Les valeurs de caractéristique du disciple draconien augmentent avec les niveaux, comme l''indique la Table : le disciple draconien. Cette augmentation est similaire à celle due au passage de niveau.</p>'
WHERE cap_id = @k;
-- Souffle (Sur)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Souffle') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Souffle', cap_type = 'sur', cap_classe_initiale = @c,
  cap_description = '<p>Au niveau 3, le disciple draconien obtient une attaque de souffle mineure, semblable à celle de son ancêtre draconien. La nature et la forme de ce souffle dépendent de la variété de dragon choisie par le personnage au niveau 1 (voir la table ci-dessous). Dans tous les cas, le souffle inflige 2d8 points de dégâts du type d''énergie destructive spécifié.</p>
<p>Au niveau 7, les dégâts passent à 4d8 et, quand le disciple atteint l''apothéose au niveau 10, ils passent à leur maximum, à 6d8. Quelle que soit sa force, l''attaque de souffle ne peut être utilisée qu''une fois par jour. Elle suit toutes les règles de l''attaque de souffle des dragons, aux exceptions notées ici.</p>
<p>Le DD du jet de sauvegarde contre le souffle est de 10 + le niveau de classe du disciple + le modificateur de Constitution du disciple. Un souffle en forme de ligne fait 1,50 mètre de large et de haut et 18 mètres de long. Un souffle en forme de cône fait 9 mètres de long.</p>
<p>[[tab:classe-disciple-draconien-souffle]]</p>'
WHERE cap_id = @k;
-- Perception aveugle (Ext)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Perception aveugle') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Perception aveugle', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>Au niveau 5, le disciple draconien obtient la perception aveugle avec une portée de 9 mètres. Grâce à des sens autres que la vue, comme une ouïe ou un odorat surdéveloppé, il peut discerner les choses sans les voir. Il n''a normalement pas besoin de réussir un test de Détection ou de Perception auditive pour remarquer ou situer une créature se trouvant à portée de sa perception aveugle et vers laquelle il peut tracer une ligne d''effet dégagée. Un adversaire que le personnage ne peut voir bénéficie toujours d''un camouflage total contre lui, et les attaques du disciple draconien encourent le risque d''échec habituel dû au camouflage. Le manque de visibilité handicape normalement les mouvements d''un personnage disposant de la perception aveugle. De même, une créature bénéficiant de la perception aveugle perd son bonus de Dextérité face aux adversaires qu''elle ne peut voir.</p>
<p>Au niveau 10, la portée de ce pouvoir passe à 18 mètres.</p>'
WHERE cap_id = @k;
-- Ailes (Ext)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Ailes') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Ailes', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>Au niveau 9, une paire d''ailes ressemblant à celle d''un dragon pousse au disciple draconien, qui peut maintenant voler à une vitesse égale à sa vitesse de déplacement au sol et avec une manœuvrabilité moyenne.</p>'
WHERE cap_id = @k;
-- Apothéose draconienne
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Apothéose draconienne') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Apothéose draconienne', cap_type = NULL, cap_classe_initiale = @c,
  cap_description = '<p>Au niveau 10, le disciple prend complètement possession de son héritage draconien et gagne l''archétype demi-dragon (voir le Manuel des Monstres). Son attaque de souffle atteint son potentiel maximal (voir ci-dessous) et sa valeur de Force est majorée de 4 points et celle de Charisme de 2 points. Son bonus d''armure naturelle augmente de +4 et il obtient la vision nocturne, la vision dans le noir (avec une portée de 18 mètres), l''immunité contre le sommeil et la paralysie, ainsi que l''immunité contre l''énergie destructive utilisée par son attaque de souffle.</p>'
WHERE cap_id = @k;

-- ------------------------------------------------------------ Duelliste
SET @c := (SELECT cla_id FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 2
             AND TRIM(cla_nom) IN ('Duelliste') ORDER BY cla_id LIMIT 1);
UPDATE dd_classes SET
  cla_nom = 'Duelliste',
  cla_abreviation = 'Due',
  cla_dV = 10,
  cla_pointsCompetences = 4,
  cla_niveauMax = 10,
  cla_conditions = '<p><strong>Bonus de base à l''attaque.</strong> +6.</p>
<p><strong>Compétences.</strong> Degré de maîtrise de 3 en Acrobaties, degré de maîtrise de 5 en Représentation.</p>
<p><strong>Dons.</strong> Attaque en finesse, Esquive, Souplesse du serpent.</p>',
  cla_armes = '<p>Le duelliste est formé au maniement de toutes les armes courantes et de guerre, mais ni au port des armures, ni au maniement des boucliers.</p>'
WHERE cla_id = @c;
DELETE FROM dd_classe_competence WHERE ccomp_cla_id = @c;
INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @c, comp_id, NULL FROM dd_competences
WHERE comp_ruleset_var_id = @ddver AND TRIM(comp_nom) IN ('Acrobaties', 'Bluff', 'Détection', 'Équilibre', 'Évasion', 'Perception auditive', 'Psychologie', 'Représentation', 'Saut');
-- Défense astucieuse (Ext)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Défense astucieuse') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Défense astucieuse', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>Quand il ne porte ni armure, ni bouclier, mais qu''il tient une arme de corps à corps, le duelliste peut ajouter son éventuel bonus d''Intelligence à son bonus de Dextérité à la classe d''armure, dans la limite de son niveau de classe de duelliste. Lorsque le personnage est pris au dépourvu ou s''il perd son bonus de Dextérité à la CA d''une façon ou d''une autre, il perd aussi ce bonus.</p>'
WHERE cap_id = @k;
-- Réaction accrue (Ext)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Réaction accrue') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Réaction accrue', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>Au niveau 2, un duelliste obtient un bonus de +2 sur les tests d''initiative. Au niveau 8, ce bonus passe à +4. Il se cumule avec le bonus accordé par le don Science de l''initiative.</p>'
WHERE cap_id = @k;
-- Grande souplesse (Ext)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Grande souplesse') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Grande souplesse', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>Quand il ne porte ni armure, ni bouclier, un duelliste de niveau 3 obtient un bonus supplémentaire de +4 à la CA contre les attaques d''opportunité qu''il provoque lorsqu''il quitte une case contrôlée.</p>'
WHERE cap_id = @k;
-- Style (Ext)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Style') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Style', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>Au niveau 4, un duelliste obtient un bonus d''aptitude de +2 sur les jets de Réflexes, à condition de ne porter ni armure, ni bouclier.</p>'
WHERE cap_id = @k;
-- Attaque précise (Ext)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Attaque précise') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Attaque précise', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>À partir du niveau 5, le duelliste peut frapper avec précision avec une arme perforante légère ou à une main, infligeant +1d6 points de dégâts supplémentaires. Pour porter une attaque précise, le duelliste ne doit pas attaquer avec sa main secondaire ou tenir un bouclier. L''attaque précise du duelliste ne peut être utilisée que contre des créatures ayant une anatomie discernable. Les créatures immunisées contre les coups critiques ne sont pas vulnérables aux attaques précises. Tout objet ou pouvoir protégeant une créature contre les coups critiques le protège aussi contre les attaques précises.</p>
<p>Au niveau 10, les dégâts supplémentaires lors d''une attaque précise s''élèvent à +2d6.</p>'
WHERE cap_id = @k;
-- Charge acrobatique (Ext)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Charge acrobatique') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Charge acrobatique', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>À partir du niveau 6, le duelliste est capable de charger dans des situations où ce serait impossible à d''autres personnages. Il peut charger sur un terrain difficile qui handicape le mouvement.</p>'
WHERE cap_id = @k;
-- Parade élaborée (Ext)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Parade élaborée') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Parade élaborée', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>Un duelliste de niveau 7 qui choisit de combattre sur la défensive ou d''utiliser l''action de défense totale au corps à corps obtient un bonus d''esquive à la CA égal à son niveau de classe de duelliste.</p>'
WHERE cap_id = @k;
-- Parade de projectile
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Parade de projectile') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Parade de projectile', cap_type = NULL, cap_classe_initiale = @c,
  cap_description = '<p>Au niveau 9, un duelliste obtient les avantages du don Parade de projectile s''il utilise une arme perforante légère ou à une main.</p>'
WHERE cap_id = @k;

-- ------------------------------------------------------------ Gardien du savoir
SET @c := (SELECT cla_id FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 2
             AND TRIM(cla_nom) IN ('Gardien du savoir') ORDER BY cla_id LIMIT 1);
UPDATE dd_classes SET
  cla_nom = 'Gardien du savoir',
  cla_abreviation = 'GS',
  cla_dV = 4,
  cla_pointsCompetences = 4,
  cla_niveauMax = 10,
  cla_conditions = '<p><strong>Compétences.</strong> Degré de maîtrise de 10 dans deux compétences de Connaissances (spécialité au choix).</p>
<p><strong>Dons.</strong> Trois dons de métamagie ou de création d''objets, plus Talent (Connaissances (spécialité au choix)).</p>
<p><strong>Sorts.</strong> Faculté de lancer au moins sept sorts de divination, dont un du 3e niveau (ou plus).</p>',
  cla_armes = '<p>Le gardien du savoir ne reçoit aucune formation au maniement des armes ou au port des armures.</p>'
WHERE cla_id = @c;
DELETE FROM dd_classe_competence WHERE ccomp_cla_id = @c;
INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @c, comp_id, NULL FROM dd_competences
WHERE comp_ruleset_var_id = @ddver AND TRIM(comp_nom) IN ('Art de la magie', 'Concentration', 'Connaissances (architecture et ingénierie)', 'Connaissances (exploration souterraine)', 'Connaissances (folklore local)', 'Connaissances (géographie)', 'Connaissances (histoire)', 'Connaissances (mystères)', 'Connaissances (nature)', 'Connaissances (noblesse et royauté)', 'Connaissances (plans)', 'Connaissances (religion)', 'Décryptage', 'Dressage', 'Estimation', 'Langue', 'Premiers secours', 'Profession', 'Renseignements', 'Représentation', 'Utilisation d''objets magiques');
INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @c, comp_id, 'alchimie' FROM dd_competences
WHERE comp_ruleset_var_id = @ddver AND comp_parent_id IS NULL AND TRIM(comp_nom) = 'Artisanat' LIMIT 1;
-- Sorts (gardien du savoir)
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Sorts (gardien du savoir)', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Sorts (gardien du savoir)' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Sorts (gardien du savoir)' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = NULL, cap_choix_mode = NULL,
  cap_description = '<p>À chaque nouveau niveau de gardien du savoir, le personnage obtient un niveau effectif de jeteur de sorts pour une de ses classes précédentes pratiquant la magie et dont il maîtrise une divination de 3e niveau (s''il possède plusieurs classes satisfaisant à cette condition, le niveau effectif ne s''applique qu''à l''une d''entre elles, au choix du personnage). Il obtient les sorts par jour (ainsi que les sorts connus, le cas échéant) et le niveau de lanceur de sorts d''un personnage de son niveau effectif. Néanmoins, il ne gagne aucun des autres avantages accompagnant habituellement ce niveau, tels qu''une meilleure chance de repousser ou d''intimider les morts-vivants, de nouveaux dons de métamagie ou de création d''objets, etc.</p>'
WHERE cap_id = @k;
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 1, NULL, 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Secret
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Secret') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Secret', cap_type = NULL, cap_classe_initiale = @c,
  cap_description = '<p>Au cours de ses recherches, le personnage découvre de nombreux secrets. Tous les niveaux impairs (niveaux 1, 3, 5, 7 et 9), il peut choisir un secret de la table suivante. Son niveau et son modificateur d''Intelligence déterminent ceux auxquels il peut prétendre. Aucun secret ne peut être pris plus d''une fois.</p>
<p>[[tab:classe-gardien-du-savoir-secrets]]</p>'
WHERE cap_id = @k;
-- Savoir
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Savoir') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Savoir', cap_type = NULL, cap_classe_initiale = @c,
  cap_description = '<p>Comme son nom l''indique, le gardien du savoir s''intéresse à la connaissance sous toutes ses formes. Dès le niveau 2, il a la possibilité de connaître des légendes ou des informations sur des sujets extrêmement variés, tout comme un barde faisant appel à son savoir bardique. Le personnage ajoute son niveau et son modificateur d''Intelligence à son test de savoir. Voir la description du barde pour plus de précisions sur le savoir bardique.</p>'
WHERE cap_id = @k;
-- Langage supplémentaire
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Langage supplémentaire') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Langage supplémentaire', cap_type = NULL, cap_classe_initiale = @c,
  cap_description = '<p>Pour pouvoir poursuivre ses recherches, le gardien du savoir doit nécessairement apprendre de nouvelles langues. Il choisit un langage supplémentaire au niveau 4, et un autre au niveau 8.</p>'
WHERE cap_id = @k;
-- Savoir supérieur (Ext)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Savoir supérieur') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Savoir supérieur', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>Au niveau 6, le personnage acquiert la faculté de découvrir les propriétés des objets magiques comme avec l''aide du sort identification.</p>'
WHERE cap_id = @k;
-- Savoir divin (Ext)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Savoir divin') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Savoir divin', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>Au niveau 10, le gardien du savoir peut faire appel à ses immenses connaissances une fois par jour pour bénéficier de l''effet du sort mythes et légendes ou analyse d''enchantement, au choix.</p>'
WHERE cap_id = @k;

-- ------------------------------------------------------------ Hiérophante
SET @c := (SELECT cla_id FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 2
             AND TRIM(cla_nom) IN ('Hiérophante') ORDER BY cla_id LIMIT 1);
UPDATE dd_classes SET
  cla_nom = 'Hiérophante',
  cla_abreviation = 'Hié',
  cla_dV = 8,
  cla_pointsCompetences = 2,
  cla_niveauMax = 5,
  cla_conditions = '<p><strong>Compétences.</strong> Degré de maîtrise de 15 en Connaissances (religion).</p>
<p><strong>Dons.</strong> Au moins un don de métamagie.</p>
<p><strong>Sorts.</strong> Faculté de lancer des sorts divins de 7e niveau.</p>',
  cla_armes = '<p>L''hiérophante ne reçoit aucune formation au maniement des armes ou au port des armures.</p>'
WHERE cla_id = @c;
DELETE FROM dd_classe_competence WHERE ccomp_cla_id = @c;
INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @c, comp_id, NULL FROM dd_competences
WHERE comp_ruleset_var_id = @ddver AND TRIM(comp_nom) IN ('Art de la magie', 'Artisanat', 'Concentration', 'Connaissances (mystères)', 'Connaissances (religion)', 'Diplomatie', 'Premiers secours', 'Profession');
-- Sorts (hiérophante)
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Sorts (hiérophante)', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Sorts (hiérophante)' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Sorts (hiérophante)' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = NULL, cap_choix_mode = NULL,
  cap_description = '<p>Un hiérophante n''augmente pas son quota de sorts quotidien. Néanmoins, à chaque nouveau niveau d''hiérophante, le personnage obtient un bonus de +1 à son niveau de lanceur de sorts pour une de ses classes précédentes pratiquant la magie divine et dont il maîtrise les sorts de 7e niveau (s''il possède plusieurs classes satisfaisant à cette condition, le bonus ne s''applique qu''à l''une d''entre elles, au choix du personnage).</p>'
WHERE cap_id = @k;
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 1, NULL, 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Pouvoir spécial
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Pouvoir spécial') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Pouvoir spécial', cap_type = NULL, cap_classe_initiale = @c,
  cap_description = '<p>L''hiérophante obtient l''un des pouvoirs suivants à chaque niveau, au choix du personnage.</p>
<p><strong>Don de métamagie.</strong> S''il le désire, l''hiérophante peut choisir un don de métamagie au lieu d''un pouvoir spécial.</p>
<p><strong>Don du divin (Sur).</strong> Ce pouvoir n''est accessible qu''aux hiérophantes ayant des niveaux de prêtre. Il permet au personnage de transférer à une créature volontaire une ou plusieurs utilisations de son pouvoir de renvoi des morts-vivants (ou d''intimidation des morts-vivants, selon le pouvoir dont dispose le prêtre). Le transfert peut durer entre 24 heures et une semaine (ce temps est choisi par l''hiérophante au moment du transfert). Pendant cette période, l''hiérophante perd les utilisations quotidiennes transférées vers la créature. Le niveau effectif de prêtre de la créature lors d''un renvoi des morts-vivants est égal à celui d''hiérophante, mais elle utilise son propre modificateur de Charisme.</p>
<p><strong>Flétrissement d''infidèle (Sur).</strong> Un hiérophante peut utiliser les sorts d''énergie négative au maximum de leur efficacité contre les créatures ayant un alignement opposé au sien (voir la table ci-dessous). Lorsque le personnage lance un sort dont la description implique une manipulation ou une génération d''énergie négative (comme les sorts de blessure, leurs versions de groupe et le sort mise à mal) sur une créature de l''alignement opposé, le sort est affecté automatiquement par le don Quintessence des sorts (sans utiliser un emplacement de sort plus élevé ou un temps d''incantation plus long). Les morts-vivants affectés par ce pouvoir regagnent le maximum de points de vie.</p>
<p>[[tab:classe-hierophante-alignement]]</p>
<p><strong>Maîtrise de l''énergie (Sur).</strong> Ce pouvoir n''est accessible qu''aux hiérophantes ayant des niveaux de prêtre. L''hiérophante canalise l''énergie positive ou négative avec une plus grande efficacité, ce qui augmente le pouvoir qu''il exerce sur les morts-vivants. Il bénéficie d''un bonus de +4 sur ses tests de renvoi des morts-vivants et sur ses jets d''efficacité de renvoi des morts-vivants. Ce pouvoir spécial n''affecte que les morts-vivants, même si l''hiérophante peut renvoyer d''autres créatures, par exemple grâce à un pouvoir accordé de domaine.</p>
<p><strong>Portée divine (Sur).</strong> L''hiérophante est capable d''utiliser ses sorts ayant une portée de contact sur des cibles distantes de 9 mètres ou moins. Si le sort nécessite une attaque de contact au corps à corps, il doit réussir une attaque de contact à distance. Le pouvoir de portée divine peut être choisi une deuxième fois, ce qui augmente sa portée à 18 mètres.</p>
<p><strong>Pouvoir magique.</strong> Lorsque l''hiérophante choisit ce pouvoir, il peut sacrifier l''un de ses emplacements de sort divin pour préparer de façon définitive l''un de ses sorts en tant que pouvoir magique utilisable deux fois par jour. Lorsqu''il lance ce sort, l''hiérophante n''a nul besoin de composantes, autre qu''un éventuel sacrifice en PX. Néanmoins, si le sort s''accompagne d''une composante matérielle coûteuse, il doit sacrifier un nombre de PX égal à dix fois le prix en po de cette composante à chaque utilisation du pouvoir magique.</p>
<p>Ce pouvoir coûte un emplacement de sort d''un niveau correspondant à celui du sort transformé en pouvoir magique. L''hiérophante peut choisir de transformer un sort métamagique en pouvoir magique, mais il doit sacrifier un emplacement du niveau de sort modifié. Il peut aussi choisir de sacrifier un emplacement de sort de niveau plus élevé que nécessaire afin de disposer de plus d''utilisations quotidiennes du pouvoir magique. Sacrifier un emplacement de sort supérieur de 3 niveaux donne droit à quatre utilisations par jour, et un emplacement de sort supérieur de 6 niveaux permet six utilisations par jour.</p>
<p>Si l''hiérophante prend plusieurs fois ce pouvoir spécial, il peut choisir le même sort (ce qui augmente le nombre d''utilisations quotidiennes) ou un autre sort.</p>
<p><strong>Puissance de la nature (Sur).</strong> Ce pouvoir n''est accessible qu''aux hiérophantes ayant des niveaux de druide. Il permet au personnage de transférer à une créature volontaire une ou plusieurs de ses aptitudes de classe de druide. Le transfert peut durer entre 24 heures et une semaine (ce temps est choisi par l''hiérophante au moment du transfert). Pendant cette période, l''hiérophante perd les aptitudes transférées vers la créature. Il peut transférer n''importe quel pouvoir de druide, à l''exception de la capacité à lancer des sorts et à avoir un compagnon animal. Le pouvoir de druide de forme animale peut être transféré partiellement ou complètement. Par exemple, l''hiérophante peut transférer une utilisation quotidienne du pouvoir et conserver les autres pour lui-même. Si le personnage peut prendre l''apparence d''un animal de taille TG ou TP, le bénéficiaire du transfert le peut également.</p>
<p>À l''instar du sort transfert de sorts, l''hiérophante doit répondre des actes de tout bénéficiaire de ce pouvoir devant son dieu.</p>
<p><strong>Puissance magique.</strong> Ce pouvoir augmente le niveau de lanceur de sorts effectif d''hiérophante de +1, mais uniquement pour ce qui est de déterminer les valeurs variables d''un sort (comme la portée et les dégâts infligés) et les tests de niveau de lanceur de sorts. Ce pouvoir peut être choisi plusieurs fois, et ses effets sont cumulatifs.</p>
<p><strong>Soin de la foi (Sur).</strong> Un hiérophante peut utiliser ses sorts de guérison à leur puissance maximale sur les créatures du même alignement que lui (ce qui le comprend lui-même). Lorsque le personnage lance un sort de registre guérison sur une créature de son alignement, le sort est affecté automatiquement par le don Quintessence des sorts (sans utiliser un emplacement de sort plus élevé ou un temps d''incantation plus long).</p>'
WHERE cap_id = @k;

-- ------------------------------------------------------------ Maître des ombres
SET @c := (SELECT cla_id FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 2
             AND TRIM(cla_nom) IN ('Maître des ombres') ORDER BY cla_id LIMIT 1);
UPDATE dd_classes SET
  cla_nom = 'Maître des ombres',
  cla_abreviation = 'MO',
  cla_dV = 8,
  cla_pointsCompetences = 6,
  cla_niveauMax = 10,
  cla_conditions = '<p><strong>Compétences.</strong> Degré de maîtrise de 8 en Déplacement silencieux, degré de maîtrise de 10 en Discrétion, degré de maîtrise de 5 en Représentation (danse).</p>
<p><strong>Dons.</strong> Attaques réflexes, Esquive, Souplesse du serpent.</p>',
  cla_armes = '<p>Le maître des ombres est formé au maniement de l''arbalète (lourde, légère ou de poing), de l''arc court (composite ou non), du bâton, de la dague, des dards, de l''épée courte, du gourdin, de la masse d''armes, de la matraque, de la morgenstern et de la rapière. Il est formé au port de l''armure légère mais pas au maniement des boucliers.</p>'
WHERE cla_id = @c;
DELETE FROM dd_classe_competence WHERE ccomp_cla_id = @c;
INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @c, comp_id, NULL FROM dd_competences
WHERE comp_ruleset_var_id = @ddver AND TRIM(comp_nom) IN ('Acrobaties', 'Bluff', 'Décryptage', 'Déguisement', 'Déplacement silencieux', 'Détection', 'Diplomatie', 'Discrétion', 'Équilibre', 'Escamotage', 'Évasion', 'Fouille', 'Maîtrise des cordes', 'Perception auditive', 'Profession', 'Représentation', 'Saut');
DELETE cc FROM dd_classe_capacite cc JOIN dd_capacites_speciales cs ON cs.cap_id = cc.cc_cap_id
WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) = 'Attaque sournoise' AND cc.cc_niveau IN (2) AND NOT (cs.cap_classe_initiale <=> @c);
DELETE cc FROM dd_classe_capacite cc JOIN dd_capacites_speciales cs ON cs.cap_id = cc.cc_cap_id
WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) = 'Esquive instinctive supérieure' AND cc.cc_niveau IN (0) AND NOT (cs.cap_classe_initiale <=> @c);
-- Discrétion totale
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Discrétion totale', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Discrétion totale' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Discrétion totale' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = 'sur', cap_choix_mode = NULL,
  cap_description = '<p>Le maître des ombres peut faire appel à sa compétence de Discrétion même si on l''observe. Du moment qu''il se trouve à moins de 3 mètres d''une zone d''ombre, il peut se cacher au vu et au su de tout le monde (à noter qu''il ne peut se fondre dans sa propre ombre ; il doit forcément s''agir de celle d''un autre ou d''un objet).</p>'
WHERE cap_id = @k;
-- variante : la capacité partagée « Discrétion totale » n'est plus liée à cette classe
DELETE cc FROM dd_classe_capacite cc JOIN dd_capacites_speciales cs ON cs.cap_id = cc.cc_cap_id
WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) = 'Discrétion totale' AND NOT (cs.cap_classe_initiale <=> @c);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 1, NULL, 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Esquive totale
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Esquive totale', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Esquive totale' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Esquive totale' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = 'ext', cap_choix_mode = NULL,
  cap_description = '<p>Au niveau 2, le maître des ombres acquiert le pouvoir d''esquive totale. S''il réussit son jet de Réflexes contre une attaque dont les dégâts sont normalement réduits de moitié en cas de jet de Réflexes réussi, il l''évite totalement et ne subit pas le moindre dégât. Cette aptitude ne peut être utilisée que si le personnage ne porte aucune armure ou une armure légère.</p>'
WHERE cap_id = @k;
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 2, NULL, 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Vision dans le noir
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Vision dans le noir', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Vision dans le noir' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Vision dans le noir' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = 'sur', cap_choix_mode = NULL,
  cap_description = '<p>Également au niveau 2, le maître des ombres voit dans l''obscurité la plus totale comme s''il bénéficiait en permanence de l''effet du sort vision dans le noir.</p>'
WHERE cap_id = @k;
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 2, NULL, 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Esquive instinctive
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Esquive instinctive', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Esquive instinctive' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Esquive instinctive' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = 'ext', cap_choix_mode = NULL,
  cap_description = '<p>Au niveau 2, le maître des ombres conserve son bonus de Dextérité à la CA même s''il est pris au dépourvu ou attaqué par un adversaire invisible (il perd toujours ce bonus s''il est immobilisé). Si un maître des ombres possède déjà cette aptitude grâce à une autre classe, il obtient l''esquive instinctive supérieure (voir ci-dessous) au lieu de l''esquive instinctive.</p>'
WHERE cap_id = @k;
-- variante : la capacité partagée « Esquive instinctive » n'est plus liée à cette classe
DELETE cc FROM dd_classe_capacite cc JOIN dd_capacites_speciales cs ON cs.cap_id = cc.cc_cap_id
WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) = 'Esquive instinctive' AND NOT (cs.cap_classe_initiale <=> @c);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 2, NULL, 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Ombres illusoires (Mag)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Ombres illusoires') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Ombres illusoires', cap_type = 'mag', cap_classe_initiale = @c,
  cap_description = '<p>Quand le maître des ombres atteint le niveau 3, il peut créer des illusions à partir des ombres qui l''entourent. Ce pouvoir magique produit un effet similaire au sort image silencieuse ; il peut être utilisé une fois par jour.</p>'
WHERE cap_id = @k;
-- Appel du compagnon ombre
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Appel du compagnon d''ombre', 'Appel du compagnon ombre') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Appel du compagnon ombre', cap_type = 'sur', cap_classe_initiale = @c,
  cap_description = '<p>Au niveau 3, le personnage peut convoquer un compagnon ombre.</p>
<p>Contrairement aux ombres normales, le compagnon est du même alignement que le personnage et il ne peut créer de rejetons. Personne d''autre que ce dernier ne peut le repousser, l''intimider ou le contrôler. Il accompagne fidèlement le maître des ombres, avec qui il peut communiquer intelligiblement. Chaque fois que le personnage gagne trois niveaux de maître des ombres supplémentaires (niveaux 6 et 9), son compagnon ombre gagne +2 DV (et les bonus correspondant aux bonus de base à l''attaque et aux sauvegardes).</p>
<p>Si le compagnon ombre est détruit (ou si le personnage le renvoie volontairement), son maître doit réussir un jet de Vigueur (DD 15). Dans le cas contraire, il perd 200 PX par niveau de maître des ombres. Un jet de sauvegarde réussi réduit de moitié cette perte de points d''expérience, soit 100 PX par niveau de maître des ombres. Le personnage ne peut pas tomber en dessous de 0 PX suite à une telle mésaventure. Un compagnon ombre détruit ou renvoyé ne peut pas être remplacé pendant 30 jours.</p>'
WHERE cap_id = @k;
-- Téléportation par les ombres (Sur)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Téléportation par les ombres') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Téléportation par les ombres', cap_type = 'sur', cap_classe_initiale = @c,
  cap_description = '<p>Au niveau 4, le maître des ombres acquiert la faculté de se déplacer d''une zone d''ombre à l''autre comme s''il employait le sort porte dimensionnelle. Ce pouvoir est toutefois plus limité que le sort, en ce sens que le personnage doit impérativement partir d''une zone d''ombre et apparaître au niveau d''une autre. Il peut parcourir jusqu''à 6 mètres par jour de cette manière, qu''il peut décomposer en deux sauts (de 3 mètres chacun) s''il le souhaite. Tous les deux niveaux au-delà du niveau 4, la distance qu''il peut parcourir double (12 mètres au niveau 6, 24 mètres au niveau 8 et 48 mètres au niveau 10). Il peut diviser ce total en autant de sauts qu''il le souhaite, mais chaque saut, aussi court soit-il, compte au moins pour 3 mètres et tout saut est arrondi au multiple de 3 mètres supérieur pour ce qui est de déterminer la distance utilisée.</p>'
WHERE cap_id = @k;
UPDATE dd_classe_capacite SET cc_precision = '6 m' WHERE cc_cla_id = @c AND cc_cap_id = @k AND cc_niveau = 4;
UPDATE dd_classe_capacite SET cc_precision = '12 m' WHERE cc_cla_id = @c AND cc_cap_id = @k AND cc_niveau = 6;
UPDATE dd_classe_capacite SET cc_precision = '24 m' WHERE cc_cla_id = @c AND cc_cap_id = @k AND cc_niveau = 8;
UPDATE dd_classe_capacite SET cc_precision = '48 m' WHERE cc_cla_id = @c AND cc_cap_id = @k AND cc_niveau = 10;
-- Roulé-boulé
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Roulé boulé', 'Roulé-boulé') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Roulé-boulé', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>À partir du niveau 5, le maître des ombres peut accompagner les coups mortels et ainsi encaisser moins de dégâts. Une fois par jour, alors qu''il vient d''être touché par une attaque qui le ferait tomber à 0 points de vie ou moins (mais pas s''il est victime d''un sort ou d''un pouvoir spécial), il peut tenter d''exécuter un roulé-boulé afin de réduire la violence du coup. Il effectue un jet de Réflexes (DD = points de dégâts encaissés) et, en cas de succès, les dégâts qui devaient lui être infligés sont réduits de moitié. Il doit voir venir l''attaque et pouvoir réagir pour tenter cette manœuvre désespérée (s''il est dans une situation où il perd son bonus de Dextérité à la CA, le roulé-boulé n''est pas possible).</p>'
WHERE cap_id = @k;
-- Esquive instinctive supérieure
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Esquive instinctive supérieure', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Esquive instinctive supérieure' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Esquive instinctive supérieure' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = 'ext', cap_choix_mode = NULL,
  cap_description = '<p>Au niveau 5, le maître des ombres ne peut plus être pris en tenaille, car il pare les assauts de ses adversaires avec autant d''aisance que s''ils venaient tous de la même direction. Les roublards ne peuvent plus lui porter des attaques sournoises en le prenant en tenaille, à moins d''avoir au moins 4 niveaux de roublard de plus que le personnage n''a de niveaux de maître des ombres.</p>
<p>Si un personnage possède déjà l''aptitude d''esquive instinctive grâce à une autre classe, il obtient l''esquive instinctive supérieure dès le niveau 2 de maître des ombres et les niveaux des différentes classes proposant cette aptitude se cumulent pour déterminer le niveau de roublard nécessaire pour le prendre en tenaille.</p>'
WHERE cap_id = @k;
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 5, NULL, 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Esprit fuyant (Ext)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Esprit fuyant') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Esprit fuyant', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>Ce pouvoir extraordinaire acquis au niveau 7 représente l''aisance avec laquelle le maître des ombres parvient à échapper aux effets magiques cherchant à le contrôler. Chaque fois que le personnage est pris pour cible par un enchantement et qu''il rate son jet de sauvegarde, il peut en tenter un second 1 round plus tard. S''il le rate également, il succombe à l''effet du sort.</p>'
WHERE cap_id = @k;
-- Esquive extraordinaire
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Esquive extraordinaire', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Esquive extraordinaire' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Esquive extraordinaire' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = 'ext', cap_choix_mode = NULL,
  cap_description = '<p>Ce pouvoir ressemble à esquive totale, mais l''agilité du maître des ombres lui permet d''échapper au danger avec encore plus d''aisance, et les dégâts infligés par une attaque autorisant un jet de Réflexes pour demi-dégâts sont réduits de moitié même s''il rate son jet de Réflexes (s''il le réussit, il l''esquive totalement).</p>'
WHERE cap_id = @k;
-- variante : la capacité partagée « Esquive extraordinaire » n'est plus liée à cette classe
DELETE cc FROM dd_classe_capacite cc JOIN dd_capacites_speciales cs ON cs.cap_id = cc.cc_cap_id
WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) = 'Esquive extraordinaire' AND NOT (cs.cap_classe_initiale <=> @c);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 10, NULL, 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);

-- ------------------------------------------------------------ Mystificateur profane
SET @c := (SELECT cla_id FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 2
             AND TRIM(cla_nom) IN ('Mystificateur profane') ORDER BY cla_id LIMIT 1);
UPDATE dd_classes SET
  cla_nom = 'Mystificateur profane',
  cla_abreviation = 'MP',
  cla_dV = 4,
  cla_pointsCompetences = 4,
  cla_niveauMax = 10,
  cla_conditions = '<p><strong>Alignement.</strong> Autre que loyal.</p>
<p><strong>Compétences.</strong> Degré de maîtrise de 7 en Décryptage, degré de maîtrise de 7 en Désamorçage/sabotage, degré de maîtrise de 7 en Évasion, degré de maîtrise de 4 en Connaissances (mystères).</p>
<p><strong>Sorts.</strong> Faculté de lancer manipulation à distance et au moins un sort profane de 3e niveau (ou plus).</p>
<p><strong>Spécial.</strong> Attaque sournoise (+2d6 ou plus).</p>',
  cla_armes = '<p>Le mystificateur profane ne reçoit aucune formation au maniement des armes ou au port des armures.</p>'
WHERE cla_id = @c;
DELETE FROM dd_classe_competence WHERE ccomp_cla_id = @c;
INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @c, comp_id, NULL FROM dd_competences
WHERE comp_ruleset_var_id = @ddver AND TRIM(comp_nom) IN ('Acrobaties', 'Art de la magie', 'Artisanat', 'Bluff', 'Concentration', 'Connaissances (architecture et ingénierie)', 'Connaissances (exploration souterraine)', 'Connaissances (folklore local)', 'Connaissances (géographie)', 'Connaissances (histoire)', 'Connaissances (mystères)', 'Connaissances (nature)', 'Connaissances (noblesse et royauté)', 'Connaissances (plans)', 'Connaissances (religion)', 'Crochetage', 'Décryptage', 'Déguisement', 'Déplacement silencieux', 'Désamorçage', 'Détection', 'Diplomatie', 'Discrétion', 'Équilibre', 'Escalade', 'Escamotage', 'Estimation', 'Évasion', 'Fouille', 'Langue', 'Maîtrise des cordes', 'Natation', 'Perception auditive', 'Profession', 'Psychologie', 'Renseignements', 'Saut');
-- Sorts (mystificateur profane)
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Sorts (mystificateur profane)', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Sorts (mystificateur profane)' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Sorts (mystificateur profane)' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = NULL, cap_choix_mode = NULL,
  cap_description = '<p>À chaque nouveau niveau de mystificateur profane, le personnage obtient un niveau effectif de jeteur de sorts pour une de ses classes précédentes pratiquant la magie profane et dont il maîtrise le 3e niveau de sorts (s''il possède plusieurs classes satisfaisant à cette condition, le niveau effectif ne s''applique qu''à l''une d''entre elles, au choix du personnage). Il obtient les sorts par jour (ainsi que les sorts connus, le cas échéant) et le niveau de lanceur de sorts d''un personnage de son niveau effectif. Néanmoins, il ne gagne aucun des autres avantages accompagnant habituellement ce niveau, tels qu''une meilleure chance de repousser ou d''intimider les morts-vivants, de nouveaux dons de métamagie ou de création d''objets, etc.</p>'
WHERE cap_id = @k;
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 1, NULL, 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Prestidigitation à distance
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Prestidigitation à distance') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Prestidigitation à distance', cap_type = 'sur', cap_classe_initiale = @c,
  cap_description = '<p>Grâce à ses talents uniques en la matière, un mystificateur profane peut employer les compétences suivantes à distance, et ce jusqu''à 9 mètres au maximum : Crochetage, Désamorçage/sabotage et Escamotage. Exécuter ses actions de loin augmente le DD habituel du test de compétence de +5 et interdit de faire 10. Un objet ne peut être manipulé que s''il pèse 2,5 kg ou moins.</p>
<p>Le mystificateur profane peut utiliser ce pouvoir une seule fois par jour au niveau 1, et obtient une utilisation supplémentaire tous les quatre niveaux supplémentaires (deux fois au niveau 5 et trois fois au niveau 9). Chaque utilisation du pouvoir ne permet qu''un test de compétence, et le personnage doit posséder un degré de maîtrise de 1 ou plus dans une compétence pour l''utiliser à distance.</p>'
WHERE cap_id = @k;
-- Attaque sournoise
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Attaque sournoise', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Attaque sournoise' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Attaque sournoise' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = NULL, cap_choix_mode = NULL,
  cap_description = '<p>Cette aptitude, obtenue au niveau 2, est en tout point similaire à celle du roublard du même nom. Les dégâts supplémentaires augmentent de +1d6 tous les niveaux pairs (niveaux 4, 6 et 8). Si le mystificateur profane bénéficie également de l''attaque sournoise par le biais d''une autre classe (par exemple, roublard), les dégâts supplémentaires se cumulent.</p>'
WHERE cap_id = @k;
-- variante : la capacité partagée « Attaque sournoise » n'est plus liée à cette classe
DELETE cc FROM dd_classe_capacite cc JOIN dd_capacites_speciales cs ON cs.cap_id = cc.cc_cap_id
WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) = 'Attaque sournoise' AND NOT (cs.cap_classe_initiale <=> @c);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 2, '+1d6', 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 4, '+2d6', 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 6, '+3d6', 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 8, '+4d6', 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 10, '+5d6', 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Attaque imprévisible
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Attaque imprévisible') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Attaque imprévisible', cap_type = 'sur', cap_classe_initiale = @c,
  cap_description = '<p>À partir du niveau 3 et une fois par jour, le mystificateur profane peut faire de n''importe laquelle de ses attaques au corps à corps ou à distance une attaque sournoise. Dans le cas d''une attaque à distance, la cible doit se trouver à 9 mètres ou moins. La cible perd son éventuel bonus de Dextérité à la CA, mais uniquement contre cette attaque. Ce pouvoir peut être utilisé contre n''importe quelle créature, mais celles qui sont immunisées contre les coups critiques ne subissent pas les dégâts supplémentaires (bien qu''elles perdent tout de même leur bonus de Dextérité à la CA).</p>
<p>Un mystificateur profane de niveau 7 peut utiliser ce pouvoir deux fois par jour.</p>'
WHERE cap_id = @k;

-- ------------------------------------------------------------ Protecteur nain
SET @c := (SELECT cla_id FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 2
             AND TRIM(cla_nom) IN ('Protecteur nain') ORDER BY cla_id LIMIT 1);
UPDATE dd_classes SET
  cla_nom = 'Protecteur nain',
  cla_abreviation = 'PN',
  cla_dV = 12,
  cla_pointsCompetences = 2,
  cla_niveauMax = 10,
  cla_conditions = '<p><strong>Race.</strong> Nain.</p>
<p><strong>Alignement.</strong> Loyal.</p>
<p><strong>Bonus de base à l''attaque.</strong> +7.</p>
<p><strong>Dons.</strong> Endurance, Esquive, Robustesse.</p>',
  cla_armes = '<p>Le protecteur nain est formé au maniement de toutes les armes courantes ou de guerre, ainsi que les boucliers (y compris les pavois). Il est également formé au port de toutes les armures.</p>',
  cla_pouvoir1 = 'Bonus à la CA'
WHERE cla_id = @c;
DELETE FROM dd_classe_competence WHERE ccomp_cla_id = @c;
INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @c, comp_id, NULL FROM dd_competences
WHERE comp_ruleset_var_id = @ddver AND TRIM(comp_nom) IN ('Artisanat', 'Détection', 'Perception auditive', 'Psychologie');
UPDATE dd_classe_niveau SET cn_pouvoir1 = '+1' WHERE cn_cla_id = @c AND cn_niveau = 1;
UPDATE dd_classe_niveau SET cn_pouvoir1 = '+1' WHERE cn_cla_id = @c AND cn_niveau = 2;
UPDATE dd_classe_niveau SET cn_pouvoir1 = '+1' WHERE cn_cla_id = @c AND cn_niveau = 3;
UPDATE dd_classe_niveau SET cn_pouvoir1 = '+2' WHERE cn_cla_id = @c AND cn_niveau = 4;
UPDATE dd_classe_niveau SET cn_pouvoir1 = '+2' WHERE cn_cla_id = @c AND cn_niveau = 5;
UPDATE dd_classe_niveau SET cn_pouvoir1 = '+2' WHERE cn_cla_id = @c AND cn_niveau = 6;
UPDATE dd_classe_niveau SET cn_pouvoir1 = '+3' WHERE cn_cla_id = @c AND cn_niveau = 7;
UPDATE dd_classe_niveau SET cn_pouvoir1 = '+3' WHERE cn_cla_id = @c AND cn_niveau = 8;
UPDATE dd_classe_niveau SET cn_pouvoir1 = '+3' WHERE cn_cla_id = @c AND cn_niveau = 9;
UPDATE dd_classe_niveau SET cn_pouvoir1 = '+4' WHERE cn_cla_id = @c AND cn_niveau = 10;
-- Bonus à la CA (protecteur nain)
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Bonus à la CA (protecteur nain)', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Bonus à la CA (protecteur nain)' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Bonus à la CA (protecteur nain)' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = 'ext', cap_choix_mode = NULL,
  cap_description = '<p>Le protecteur nain bénéficie d''un bonus d''esquive de +1 à la CA au niveau 1, qui augmente de +1 tous les 3 niveaux (+2 au niveau 4, +3 au niveau 7 et +4 au niveau 10).</p>'
WHERE cap_id = @k;
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 1, NULL, 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Position défensive
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Position défensive') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Position défensive', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>En cas de besoin, le protecteur nain peut gagner d''impressionnants bonus, mais il est alors incapable de bouger de l''endroit où il se trouve. Il acquiert un bonus de +2 en Force, un bonus de +4 en Constitution, un bonus de résistance de +2 à tous les jets de sauvegarde et un bonus d''esquive de +4 à la CA. Cette augmentation de Constitution se traduit par 2 points de vie supplémentaires par niveau global, mais ces points de vie disparaissent dès que la valeur de Constitution du protecteur nain retombe à son niveau normal. Le personnage est incapable de se mouvoir, et donc de faire appel à des compétences telles que Déplacement silencieux ou Saut. Il peut garder sa position défensive pendant 3 rounds + modificateur de Constitution (pour ce calcul, c''est la valeur augmentée de 4 points qui est prise en compte). S''il le souhaite, il peut y mettre un terme prématurément. Quand le taux d''adrénaline retombe, le protecteur nain a le souffle coupé et subit un malus de –2 en Force jusqu''à la fin de la rencontre. Chaque jour, il ne peut prendre cette position qu''un nombre de fois déterminé par son niveau (voir la Table : le protecteur nain). Prendre une position défensive ne demande aucune action, mais le personnage ne peut le faire qu''au cours d''une action.</p>'
WHERE cap_id = @k;
-- Esquive instinctive
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Esquive instinctive', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Esquive instinctive' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Esquive instinctive' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = 'ext', cap_choix_mode = NULL,
  cap_description = '<p>Dès le niveau 2, le protecteur nain conserve son bonus de Dextérité à la CA même s''il est pris au dépourvu ou attaqué par un adversaire invisible (il perd toujours ce bonus s''il est immobilisé). Si un protecteur nain possède déjà cette aptitude grâce à une autre classe, il obtient l''esquive instinctive supérieure (voir ci-dessous) au lieu de l''esquive instinctive.</p>'
WHERE cap_id = @k;
-- variante : la capacité partagée « Esquive instinctive » n'est plus liée à cette classe
DELETE cc FROM dd_classe_capacite cc JOIN dd_capacites_speciales cs ON cs.cap_id = cc.cc_cap_id
WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) = 'Esquive instinctive' AND NOT (cs.cap_classe_initiale <=> @c);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 2, NULL, 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Sens des pièges
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Sens des pièges', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Sens des pièges' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Sens des pièges' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = 'ext', cap_choix_mode = NULL,
  cap_description = '<p>À partir du niveau 4, le protecteur nain acquiert un sens intuitif lui permettant d''éviter les dangers des pièges, ce qui se traduit par un bonus de +1 aux jets de Réflexes effectués pour éviter les pièges et un bonus d''esquive de +1 à la CA contre les attaques déclenchées par des pièges. Ces bonus passent à +2 au niveau 8. Les bonus de sens des pièges de plusieurs classes se cumulent entre eux.</p>'
WHERE cap_id = @k;
-- variante : la capacité partagée « Sens des pièges » n'est plus liée à cette classe
DELETE cc FROM dd_classe_capacite cc JOIN dd_capacites_speciales cs ON cs.cap_id = cc.cc_cap_id
WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) = 'Sens des pièges' AND NOT (cs.cap_classe_initiale <=> @c);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 4, '+1', 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 8, '+2', 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Réduction des dégâts
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Réduction des dégâts', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Réduction des dégâts' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Réduction des dégâts' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = 'ext', cap_choix_mode = NULL,
  cap_description = '<p>À partir du niveau 6, la robustesse du protecteur nain lui permet de ne tenir aucun compte d''une partie des dégâts qu''il encaisse. Chaque fois que le personnage reçoit un coup, les dégâts qu''il subit sont diminués de 3 points. Au niveau 10, cette réduction des dégâts passe à 6/–. Ce pouvoir peut annuler une attaque (en faisant tomber les dégâts à 0), mais pas rendre des points de vie au personnage (même sur un résultat négatif).</p>'
WHERE cap_id = @k;
-- variante : la capacité partagée « Réduction des dégâts » n'est plus liée à cette classe
DELETE cc FROM dd_classe_capacite cc JOIN dd_capacites_speciales cs ON cs.cap_id = cc.cc_cap_id
WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) = 'Réduction des dégâts' AND NOT (cs.cap_classe_initiale <=> @c);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 6, '3/–', 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 10, '6/–', 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Esquive instinctive supérieure
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Esquive instinctive supérieure', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Esquive instinctive supérieure' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Esquive instinctive supérieure' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = 'ext', cap_choix_mode = NULL,
  cap_description = '<p>Au niveau 6, le protecteur nain ne peut plus être pris en tenaille, car il pare les assauts de ses adversaires avec autant d''aisance que s''ils venaient tous de la même direction. Les roublards ne peuvent plus lui porter d''attaques sournoises en le prenant en tenaille, à moins d''avoir au moins 4 niveaux de roublard de plus que le personnage n''a de niveau de protecteur nain.</p>
<p>Si un personnage possède déjà l''aptitude d''esquive instinctive grâce à une autre classe, il obtient l''esquive instinctive supérieure dès le niveau 2 de protecteur nain et les niveaux des différentes classes proposant cette aptitude se cumulent pour déterminer le niveau de roublard nécessaire pour le prendre en tenaille.</p>'
WHERE cap_id = @k;
-- variante : la capacité partagée « Esquive instinctive supérieure » n'est plus liée à cette classe
DELETE cc FROM dd_classe_capacite cc JOIN dd_capacites_speciales cs ON cs.cap_id = cc.cc_cap_id
WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) = 'Esquive instinctive supérieure' AND NOT (cs.cap_classe_initiale <=> @c);
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 6, NULL, 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Défense mobile (Ext)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Défense mobile') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Défense mobile', cap_type = 'ext', cap_classe_initiale = @c,
  cap_description = '<p>À partir du niveau 8, le protecteur nain peut ajuster sa position alors qu''il tient une posture défensive. Il peut alors effectuer un pas de placement de 1,50 mètre chaque round sans perdre les avantages de la posture défensive.</p>'
WHERE cap_id = @k;

-- ------------------------------------------------------------ Thaumaturge
SET @c := (SELECT cla_id FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 2
             AND TRIM(cla_nom) IN ('Thaumaturge') ORDER BY cla_id LIMIT 1);
UPDATE dd_classes SET
  cla_nom = 'Thaumaturge',
  cla_abreviation = 'Th',
  cla_dV = 4,
  cla_pointsCompetences = 2,
  cla_niveauMax = 5,
  cla_conditions = '<p><strong>Dons.</strong> École renforcée (Invocation).</p>
<p><strong>Sorts.</strong> Faculté de lancer allié d''outreplan.</p>',
  cla_armes = '<p>Le thaumaturge ne reçoit aucune formation au maniement des armes ou au port des armures.</p>'
WHERE cla_id = @c;
DELETE FROM dd_classe_competence WHERE ccomp_cla_id = @c;
INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @c, comp_id, NULL FROM dd_competences
WHERE comp_ruleset_var_id = @ddver AND TRIM(comp_nom) IN ('Art de la magie', 'Artisanat', 'Concentration', 'Connaissances (plans)', 'Connaissances (religion)', 'Diplomatie', 'Langue', 'Profession', 'Psychologie');
-- Sorts (thaumaturge)
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Sorts (thaumaturge)', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Sorts (thaumaturge)' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Sorts (thaumaturge)' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = NULL, cap_choix_mode = NULL,
  cap_description = '<p>À chaque nouveau niveau de thaumaturge, le personnage obtient un niveau effectif de jeteur de sorts pour une de ses classes précédentes pratiquant la magie (s''il possède plusieurs classes de ce type, le niveau effectif ne s''applique qu''à l''une d''entre elles, au choix du personnage). Il obtient les sorts par jour (ainsi que les sorts connus, le cas échéant) et le niveau de lanceur de sorts d''un personnage de son niveau effectif. Néanmoins, il ne gagne aucun des autres avantages accompagnant habituellement ce niveau, tels qu''une meilleure chance de repousser ou d''intimider les morts-vivants, de nouveaux dons de métamagie ou de création d''objets, etc.</p>'
WHERE cap_id = @k;
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 1, NULL, 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Science de l'appel d'allié
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Science de l''appel d''allié') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Science de l''appel d''allié', cap_type = NULL, cap_classe_initiale = @c,
  cap_description = '<p>Le thaumaturge est habile à convaincre les créatures des autres plans de le servir. Lorsque le personnage lance le sort allié d''outreplan (ainsi que allié majeur d''outreplan ou allié suprême d''outreplan), il effectue un test de Diplomatie pour convaincre la créature de l''aider à un prix réduit. Si le résultat du test de Diplomatie du thaumaturge est suffisant pour amener la créature à une attitude serviable, elle acceptera une réduction de 50% de ses prétentions habituelles, à condition toutefois que l''acte proposé n''aille pas contre sa nature.</p>
<p>L''aptitude de science de l''appel d''allié n''est utilisable que si le thaumaturge et la créature qu''il invoque ont au moins une composante d''alignement en commun. Un thaumaturge ne peut avoir qu''un allié de ce type à la fois, mais il lui est possible de négocier d''autres alliés au prix normal.</p>'
WHERE cap_id = @k;
-- Amélioration des créatures convoquées
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Amélioration des créatures convoquées') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Amélioration des créatures convoquées', cap_type = NULL, cap_classe_initiale = @c,
  cap_description = '<p>Au niveau 2, le thaumaturge obtient le don Amélioration des créatures convoquées.</p>'
WHERE cap_id = @k;
-- Convocation à durée étendue
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Convocation à durée étendue') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Convocation à durée étendue', cap_type = NULL, cap_classe_initiale = @c,
  cap_description = '<p>À partir du niveau 3, les sorts de la branche de convocation lancés par le thaumaturge voient leur durée doublée, comme s''il leur avait appliqué le don Extension de durée (bien que le niveau de ces sorts ne change pas). Cet effet est cumulable avec celui du don Extension de durée (qui pour sa part modifie bien le niveau du sort).</p>'
WHERE cap_id = @k;
-- Invocation prévoyante
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Invocation prévoyante') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Invocation prévoyante', cap_type = NULL, cap_classe_initiale = @c,
  cap_description = '<p>Un thaumaturge de niveau 4 peut préparer un sort de convocation ou d''appel à l''avance de façon à ce qu''il se déclenche lors d''un événement particulier. La procédure est la même que pour le sort prévoyance et le personnage doit lancer le sort de convocation ou d''appel à l''avance. Le sort prend effet dès que les conditions prédéfinies sont remplies.</p>
<p>Les conditions déclenchant l''invocation doivent être claires, mais elles peuvent être générales. Si des conditions complexes ou embrouillées sont utilisées, l''invocation prévoyante a une chance de rater lorsqu''elle est déclenchée. Le déclenchement de l''invocation est uniquement dépendant des conditions définies, et le thaumaturge n''a plus aucun choix en la matière (mais on peut mettre un terme à la plupart des invocations). Un thaumaturge ne peut avoir qu''une invocation prévoyante active à la fois.</p>'
WHERE cap_id = @k;
-- Compagnon d'arme planaire
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id
            WHERE cc.cc_cla_id = @c AND TRIM(cs.cap_nom) IN ('Compagnon d''arme planaire') ORDER BY cs.cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_nom = 'Compagnon d''arme planaire', cap_type = NULL, cap_classe_initiale = @c,
  cap_description = '<p>Un thaumaturge de niveau 5 peut utiliser l''un des sorts d''allié d''outreplan pour appeler une créature afin qu''elle le serve comme un compagnon d''armes. La créature sert loyalement le personnage tant qu''il sert une cause importante pour elle.</p>
<p>Pour appeler un compagnon d''arme planaire, le thaumaturge doit lancer le sort adapté et payer le coût en PX normalement. Il faut une offrande de 1 000 po × les DV de la créature pour la convaincre de servir comme compagnon d''armes planaire et l''aptitude de science de l''appel d''allié ne permet pas de réduire ce coût. Le compagnon d''arme planaire ne peut avoir plus de dés de vie que le thaumaturge et son NGE ne doit pas dépasser le niveau global du personnage –2.</p>
<p>Un thaumaturge ne peut avoir qu''un compagnon d''armes planaire à la fois, mais il peut continuer à passer des accords avec d''autres créatures appelées normalement. Un compagnon d''armes planaire peut remplacer un compagnon d''arme ordinaire, si le personnage en possède un grâce au don Prestige.</p>'
WHERE cap_id = @k;

-- ------------------------------------------------------------ Théurge mystique
SET @c := (SELECT cla_id FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 2
             AND TRIM(cla_nom) IN ('Théurge mystique') ORDER BY cla_id LIMIT 1);
UPDATE dd_classes SET
  cla_nom = 'Théurge mystique',
  cla_abreviation = 'TM',
  cla_dV = 4,
  cla_pointsCompetences = 2,
  cla_niveauMax = 10,
  cla_conditions = '<p><strong>Compétences.</strong> Degré de maîtrise de 6 en Connaissances (mystères) et degré de maîtrise de 6 en Connaissances (religion).</p>
<p><strong>Sorts.</strong> Faculté de lancer des sorts profanes de 2e niveau et des sorts divins de 2e niveau.</p>',
  cla_armes = '<p>Le théurge mystique ne reçoit aucune formation au maniement des armes ou au port des armures.</p>'
WHERE cla_id = @c;
DELETE FROM dd_classe_competence WHERE ccomp_cla_id = @c;
INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @c, comp_id, NULL FROM dd_competences
WHERE comp_ruleset_var_id = @ddver AND TRIM(comp_nom) IN ('Art de la magie', 'Artisanat', 'Concentration', 'Connaissances (mystères)', 'Connaissances (religion)', 'Décryptage', 'Profession', 'Psychologie');
-- Sorts (théurge mystique)
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Sorts (théurge mystique)', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Sorts (théurge mystique)' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Sorts (théurge mystique)' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = NULL, cap_choix_mode = NULL,
  cap_description = '<p>À chaque nouveau niveau de théurge mystique, le personnage obtient un niveau effectif de jeteur de sorts pour une de ses classes précédentes pratiquant la magie profane et dont il maîtrise le 2e niveau de sorts, ainsi qu''un niveau effectif de jeteur de sorts pour une de ses classes précédentes pratiquant la magie divine et dont il maîtrise le 2e niveau de sorts (dans les deux cas, s''il possède plusieurs classes satisfaisant à une condition, le niveau effectif ne s''applique qu''à l''une d''entre elles, au choix du personnage). Il obtient les sorts par jour (ainsi que les sorts connus, le cas échéant) et le niveau de lanceur de sorts d''un personnage de son niveau effectif. Néanmoins, il ne gagne aucun des autres avantages accompagnant habituellement ce niveau, tels qu''une meilleure chance de repousser ou d''intimider les morts-vivants, de nouveaux dons de métamagie ou de création d''objets, etc.</p>'
WHERE cap_id = @k;
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 1, NULL, 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);

-- ------------------------------------------------------------ Adepte
INSERT INTO dd_classes (cla_nom, cla_clt_id, cla_res_id, cla_ruleset_var_id, cla_camp_id, cla_public, cla_visible)
SELECT 'Adepte', 3, @gdm, @ddver, NULL, 0, 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 3 AND TRIM(cla_nom) = 'Adepte');
SET @c := (SELECT cla_id FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 3 AND TRIM(cla_nom) = 'Adepte' ORDER BY cla_id LIMIT 1);
UPDATE dd_classes SET
  cla_nom = 'Adepte',
  cla_abreviation = 'Adp',
  cla_clt_id = 3,
  cla_dV = 6,
  cla_car_id = 5,
  cla_mag_id = 2,
  cla_profil_incantation = 3,
  cla_renouvellement = 7,
  cla_sort_connu = 1,
  cla_sort_compris = 1,
  cla_sort_prepare = 1,
  cla_domaine_divin = 0,
  cla_niveauMax = 20,
  cla_pointsCompetences = 2,
  cla_po_niveau1 = 0,
  cla_conditions = NULL,
  cla_armes = '<p>L''adepte est formé au maniement de toutes les armes courantes. Par contre, il n''est formé ni au maniement des boucliers ni au port des armures.</p>',
  cla_sorts = '<p>L''adepte choisit ses sorts dans la liste suivante :</p>
<p><strong>Niveau 0 :</strong> Assistance divine, création d''eau, détection de la magie, fatigue, lecture de la magie, lumière, purification de nourriture et d''eau, réparation, soins superficiels, son imaginaire.</p>
<p><strong>1er niveau :</strong> Bénédiction, brume de dissimulation, compréhension des langages, détection de la Loi, détection du Bien, détection du Chaos, détection du Mal, endurance aux énergies destructives, frayeur, injonction, mains brûlantes, protection contre la Loi, protection contre le Bien, protection contre le Chaos, protection contre le Mal, soins légers, sommeil.</p>
<p><strong>2e niveau :</strong> Aide, détection de l''invisibilité, endurance de l''ours, force de taureau, grâce féline, hypnose des animaux, image miroir, invisibilité, ralentissement du poison, rayon ardent, résistance aux énergies destructives, soins modérés, ténèbres, toile d''araignée.</p>
<p><strong>3e niveau :</strong> Animation des morts, contagion, délivrance des malédictions, don des langues, éclair, flamme éternelle, guérison des maladies, lumière du jour, malédiction, neutralisation du poison, soins importants, ténèbres profondes.</p>
<p><strong>4e niveau :</strong> Création mineure, métamorphose, mur de feu, peau de pierre, restauration, soins intensifs.</p>
<p><strong>5e niveau :</strong> Annulation d''enchantement, communion, création majeure, guérison suprême, métamorphose funeste, mur de pierre, rappel à la vie, vision lucide.</p>',
  cla_description = '<p><strong>Équipement de départ.</strong> Pour 2d4 × 10 po d''équipement.</p>'
WHERE cla_id = @c;
INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte,
  cn_sort_n0, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4, cn_sort_n5,
  cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif, cn_sortsBonus)
VALUES
(@c, 1, '0', 0, 0, 2, 3, 1, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 2, '1', 0, 0, 3, 3, 1, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 3, '1', 1, 1, 3, 3, 2, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 4, '2', 1, 1, 4, 3, 2, 0, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 5, '2', 1, 1, 4, 3, 2, 1, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 6, '3', 2, 2, 5, 3, 2, 1, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 7, '3', 2, 2, 5, 3, 3, 2, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 8, '4', 2, 2, 6, 3, 3, 2, 0, NULL, NULL, 0, 0, 0, 0),
(@c, 9, '4', 3, 3, 6, 3, 3, 2, 1, NULL, NULL, 0, 0, 0, 0),
(@c, 10, '5', 3, 3, 7, 3, 3, 2, 1, NULL, NULL, 0, 0, 0, 0),
(@c, 11, '5', 3, 3, 7, 3, 3, 3, 2, NULL, NULL, 0, 0, 0, 0),
(@c, 12, '6/1', 4, 4, 8, 3, 3, 3, 2, 0, NULL, 0, 0, 0, 0),
(@c, 13, '6/1', 4, 4, 8, 3, 3, 3, 2, 1, NULL, 0, 0, 0, 0),
(@c, 14, '7/2', 4, 4, 9, 3, 3, 3, 2, 1, NULL, 0, 0, 0, 0),
(@c, 15, '7/2', 5, 5, 9, 3, 3, 3, 3, 2, NULL, 0, 0, 0, 0),
(@c, 16, '8/3', 5, 5, 10, 3, 3, 3, 3, 2, 0, 0, 0, 0, 0),
(@c, 17, '8/3', 5, 5, 10, 3, 3, 3, 3, 2, 1, 0, 0, 0, 0),
(@c, 18, '9/4', 6, 6, 11, 3, 3, 3, 3, 2, 1, 0, 0, 0, 0),
(@c, 19, '9/4', 6, 6, 11, 3, 3, 3, 3, 3, 2, 0, 0, 0, 0),
(@c, 20, '10/5', 6, 6, 12, 3, 3, 3, 3, 3, 2, 0, 0, 0, 0)
ON DUPLICATE KEY UPDATE cn_bba = VALUES(cn_bba), cn_reflexes = VALUES(cn_reflexes), cn_vigueur = VALUES(cn_vigueur),
  cn_volonte = VALUES(cn_volonte), cn_sort_n0 = VALUES(cn_sort_n0), cn_sort_n1 = VALUES(cn_sort_n1), cn_sort_n2 = VALUES(cn_sort_n2),
  cn_sort_n3 = VALUES(cn_sort_n3), cn_sort_n4 = VALUES(cn_sort_n4), cn_sort_n5 = VALUES(cn_sort_n5);
DELETE FROM dd_classe_competence WHERE ccomp_cla_id = @c;
INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @c, comp_id, NULL FROM dd_competences
WHERE comp_ruleset_var_id = @ddver AND TRIM(comp_nom) IN ('Art de la magie', 'Artisanat', 'Concentration', 'Connaissances (architecture et ingénierie)', 'Connaissances (exploration souterraine)', 'Connaissances (folklore local)', 'Connaissances (géographie)', 'Connaissances (histoire)', 'Connaissances (mystères)', 'Connaissances (nature)', 'Connaissances (noblesse et royauté)', 'Connaissances (plans)', 'Connaissances (religion)', 'Dressage', 'Premiers secours', 'Profession', 'Survie');
-- Sorts (adepte)
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Sorts (adepte)', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Sorts (adepte)' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Sorts (adepte)' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = NULL, cap_choix_mode = NULL,
  cap_description = '<p>L''adepte lance des sorts divins qui sont issus de sa liste de sorts (voir ci-dessous). Comme le prêtre, il doit choisir et préparer ses sorts à l''avance. Par contre, contrairement au prêtre, il est incapable de lancer des sorts de soins ou de blessure de manière spontanée.</p>
<p>Pour préparer ou lancer un sort, l''adepte doit avoir une valeur de Sagesse au moins égale à 10 + niveau du sort. Le DD associé au jet de sauvegarde de ses sorts est égal à 10 + niveau du sort + modificateur de Sagesse de l''adepte.</p>
<p>Contrairement au magicien, l''adepte ne trouve pas ses sorts dans des livres, sur des parchemins ou par quelque étude. Il les obtient par la prière ou la méditation, et les doit directement à son dieu ou à sa foi. Chaque jour, au moment qu''il a choisi (mais qui doit toujours rester le même), il doit prier ou méditer une heure durant pour récupérer ses sorts. Le temps qu''il passe à dormir n''a aucun effet sur la préparation des sorts.</p>
<p>À l''instar des autres lanceurs de sorts, l''adepte ne peut lancer qu''un certain nombre de sorts d''un niveau donné chaque jour. Le nombre de sorts qu''il peut lancer sur une base quotidienne apparaît sur la Table : l''adepte. En outre, il bénéficie de sorts en bonus s''il a une valeur de Sagesse élevée. Quand la Table : l''adepte indique 0 sort d''un niveau donné, cela signifie que le personnage a juste droit à ses sorts en bonus pour ce niveau. Chaque adepte possède un symbole sacré (focaliseur divin) dont l''aspect dépend de sa religion.</p>'
WHERE cap_id = @k;
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 1, NULL, 0)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
-- Appel de familier (adepte)
INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale, cap_choix_mode)
SELECT 'Appel de familier (adepte)', '', NULL, @c, NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Appel de familier (adepte)' AND cap_classe_initiale = @c);
SET @k := (SELECT cap_id FROM dd_capacites_speciales WHERE cap_nom = 'Appel de familier (adepte)' AND cap_classe_initiale = @c ORDER BY cap_id LIMIT 1);
UPDATE dd_capacites_speciales SET cap_type = NULL, cap_choix_mode = 'texte',
  cap_description = '<p>Au niveau 2, l''adepte peut appeler un familier, à la manière des magiciens et des ensorceleurs.</p>'
WHERE cap_id = @k;
INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix) VALUES (@c, @k, 2, NULL, 1)
ON DUPLICATE KEY UPDATE cc_precision = VALUES(cc_precision), cc_nb_choix = VALUES(cc_nb_choix);
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 0 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Assistance divine'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 0 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Création d''eau'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 0 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Détection de la magie'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 0 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Fatigue'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 0 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Lecture de la magie'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 0 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Lumière'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 0 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Purification de nourriture et d''eau'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 0 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Réparation'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 0 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Soins superficiels'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 0 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Son imaginaire'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Bénédiction'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Brume de dissimulation'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Compréhension des langues'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Détection de la loi'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Détection du bien'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Détection du chaos'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Détection du mal'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Endurance aux énergies destructrices'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Frayeur'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Injonction'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Mains brûlantes'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Protection contre la loi'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Protection contre le bien'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Protection contre le chaos'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Protection contre le mal'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Soins légers'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 1 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Sommeil'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Aide'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Détection de l''invisibilité'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Endurance de l''ours'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Force de taureau'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Grâce féline'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Hypnose des animaux'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Image miroir'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Invisibilité'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Ralentissement du poison'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Rayon ardent'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Résistance aux énergies destructices'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Soins modérés'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Ténèbres'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 2 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Toile d''araignée'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Animation des morts'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Contagion'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Délivrance des malédictions'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Don des langues'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Eclair'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Flamme éternelle'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Guérison des maladies'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Lumière du jour'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Malédiction'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Neutralisation du poison'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Soins importants'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 3 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Ténèbres profondes'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 4 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Création mineure'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 4 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Métamorphose'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 4 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Mur de feu'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 4 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Peau de pierre'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 4 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Restauration'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 4 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Soins intensifs'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 5 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Annulation d''enchantement'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 5 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Communion'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 5 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'création majeure'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 5 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Guérison suprême'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 5 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Métamorphose funeste'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 5 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Mur de pierre'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 5 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Rappel à la vie'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;
INSERT IGNORE INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau)
SELECT so_id, @c, 5 FROM dd_sorts WHERE so_ruleset_var_id = @ddver AND TRIM(so_nom) = 'Vision lucide'
ORDER BY (so_res_id = (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'MdJ3.5' LIMIT 1)) DESC, (so_res_id = @gdm) DESC, so_id LIMIT 1;

-- ------------------------------------------------------------ Expert
INSERT INTO dd_classes (cla_nom, cla_clt_id, cla_res_id, cla_ruleset_var_id, cla_camp_id, cla_public, cla_visible)
SELECT 'Expert', 3, @gdm, @ddver, NULL, 0, 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 3 AND TRIM(cla_nom) = 'Expert');
SET @c := (SELECT cla_id FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 3 AND TRIM(cla_nom) = 'Expert' ORDER BY cla_id LIMIT 1);
UPDATE dd_classes SET
  cla_nom = 'Expert',
  cla_abreviation = 'Exp',
  cla_clt_id = 3,
  cla_dV = 6,
  cla_car_id = 0,
  cla_mag_id = 0,
  cla_profil_incantation = 0,
  cla_renouvellement = 0,
  cla_sort_connu = 0,
  cla_sort_compris = 0,
  cla_sort_prepare = 0,
  cla_domaine_divin = 0,
  cla_niveauMax = 20,
  cla_pointsCompetences = 6,
  cla_po_niveau1 = 0,
  cla_conditions = NULL,
  cla_armes = '<p>L''expert est formé au maniement de toutes les armes courantes, mais pas des boucliers. Il est formé au port des armures légères.</p>',
  cla_sorts = NULL,
  cla_description = '<p><strong>Compétences de classe.</strong> L''expert peut choisir jusqu''à dix compétences, qui deviennent par la suite ses compétences de classe.</p>
<p><strong>Équipement de départ.</strong> Pour 3d4 × 10 po d''équipement.</p>'
WHERE cla_id = @c;
INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte,
  cn_sort_n0, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4, cn_sort_n5,
  cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif, cn_sortsBonus)
VALUES
(@c, 1, '0', 0, 0, 2, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 2, '1', 0, 0, 3, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 3, '2', 1, 1, 3, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 4, '3', 1, 1, 4, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 5, '3', 1, 1, 4, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 6, '4', 2, 2, 5, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 7, '5', 2, 2, 5, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 8, '6/1', 2, 2, 6, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 9, '6/1', 3, 3, 6, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 10, '7/2', 3, 3, 7, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 11, '8/3', 3, 3, 7, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 12, '9/4', 4, 4, 8, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 13, '9/4', 4, 4, 8, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 14, '10/5', 4, 4, 9, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 15, '11/6/1', 5, 5, 9, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 16, '12/7/2', 5, 5, 10, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 17, '12/7/2', 5, 5, 10, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 18, '13/8/3', 6, 6, 11, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 19, '14/9/4', 6, 6, 11, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 20, '15/10/5', 6, 6, 12, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0)
ON DUPLICATE KEY UPDATE cn_bba = VALUES(cn_bba), cn_reflexes = VALUES(cn_reflexes), cn_vigueur = VALUES(cn_vigueur),
  cn_volonte = VALUES(cn_volonte), cn_sort_n0 = VALUES(cn_sort_n0), cn_sort_n1 = VALUES(cn_sort_n1), cn_sort_n2 = VALUES(cn_sort_n2),
  cn_sort_n3 = VALUES(cn_sort_n3), cn_sort_n4 = VALUES(cn_sort_n4), cn_sort_n5 = VALUES(cn_sort_n5);

-- ------------------------------------------------------------ Gens du peuple
INSERT INTO dd_classes (cla_nom, cla_clt_id, cla_res_id, cla_ruleset_var_id, cla_camp_id, cla_public, cla_visible)
SELECT 'Gens du peuple', 3, @gdm, @ddver, NULL, 0, 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 3 AND TRIM(cla_nom) = 'Gens du peuple');
SET @c := (SELECT cla_id FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 3 AND TRIM(cla_nom) = 'Gens du peuple' ORDER BY cla_id LIMIT 1);
UPDATE dd_classes SET
  cla_nom = 'Gens du peuple',
  cla_abreviation = 'GdP',
  cla_clt_id = 3,
  cla_dV = 4,
  cla_car_id = 0,
  cla_mag_id = 0,
  cla_profil_incantation = 0,
  cla_renouvellement = 0,
  cla_sort_connu = 0,
  cla_sort_compris = 0,
  cla_sort_prepare = 0,
  cla_domaine_divin = 0,
  cla_niveauMax = 20,
  cla_pointsCompetences = 2,
  cla_po_niveau1 = 0,
  cla_conditions = NULL,
  cla_armes = '<p>Les gens du peuple sont formés au maniement d''une arme courante. Ils ne sont pas formés au maniement des boucliers ni au port des armures.</p>',
  cla_sorts = NULL,
  cla_description = '<p><strong>Équipement de départ.</strong> Pour 5d4 po d''équipement.</p>'
WHERE cla_id = @c;
INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte,
  cn_sort_n0, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4, cn_sort_n5,
  cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif, cn_sortsBonus)
VALUES
(@c, 1, '0', 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 2, '1', 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 3, '1', 1, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 4, '2', 1, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 5, '2', 1, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 6, '3', 2, 2, 2, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 7, '3', 2, 2, 2, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 8, '4', 2, 2, 2, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 9, '4', 3, 3, 3, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 10, '5', 3, 3, 3, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 11, '5', 3, 3, 3, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 12, '6/1', 4, 4, 4, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 13, '6/1', 4, 4, 4, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 14, '7/2', 4, 4, 4, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 15, '7/2', 5, 5, 5, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 16, '8/3', 5, 5, 5, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 17, '8/3', 5, 5, 5, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 18, '9/4', 6, 6, 6, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 19, '9/4', 6, 6, 6, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 20, '10/5', 6, 6, 6, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0)
ON DUPLICATE KEY UPDATE cn_bba = VALUES(cn_bba), cn_reflexes = VALUES(cn_reflexes), cn_vigueur = VALUES(cn_vigueur),
  cn_volonte = VALUES(cn_volonte), cn_sort_n0 = VALUES(cn_sort_n0), cn_sort_n1 = VALUES(cn_sort_n1), cn_sort_n2 = VALUES(cn_sort_n2),
  cn_sort_n3 = VALUES(cn_sort_n3), cn_sort_n4 = VALUES(cn_sort_n4), cn_sort_n5 = VALUES(cn_sort_n5);
DELETE FROM dd_classe_competence WHERE ccomp_cla_id = @c;
INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @c, comp_id, NULL FROM dd_competences
WHERE comp_ruleset_var_id = @ddver AND TRIM(comp_nom) IN ('Artisanat', 'Détection', 'Dressage', 'Équitation', 'Escalade', 'Maîtrise des cordes', 'Natation', 'Perception auditive', 'Profession', 'Saut');

-- ------------------------------------------------------------ Homme d'armes
INSERT INTO dd_classes (cla_nom, cla_clt_id, cla_res_id, cla_ruleset_var_id, cla_camp_id, cla_public, cla_visible)
SELECT 'Homme d''armes', 3, @gdm, @ddver, NULL, 0, 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 3 AND TRIM(cla_nom) = 'Homme d''armes');
SET @c := (SELECT cla_id FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 3 AND TRIM(cla_nom) = 'Homme d''armes' ORDER BY cla_id LIMIT 1);
UPDATE dd_classes SET
  cla_nom = 'Homme d''armes',
  cla_abreviation = 'HA',
  cla_clt_id = 3,
  cla_dV = 8,
  cla_car_id = 0,
  cla_mag_id = 0,
  cla_profil_incantation = 0,
  cla_renouvellement = 0,
  cla_sort_connu = 0,
  cla_sort_compris = 0,
  cla_sort_prepare = 0,
  cla_domaine_divin = 0,
  cla_niveauMax = 20,
  cla_pointsCompetences = 2,
  cla_po_niveau1 = 0,
  cla_conditions = NULL,
  cla_armes = '<p>L''homme d''armes est formé au maniement de toutes les armes courantes, des armes de guerre et des boucliers (à l''exception du pavois). Il est formé au port de toutes les armures.</p>',
  cla_sorts = NULL,
  cla_description = '<p><strong>Équipement de départ.</strong> Pour 3d4 × 10 po d''équipement.</p>'
WHERE cla_id = @c;
INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte,
  cn_sort_n0, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4, cn_sort_n5,
  cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif, cn_sortsBonus)
VALUES
(@c, 1, '1', 0, 2, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 2, '2', 0, 3, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 3, '3', 1, 3, 1, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 4, '4', 1, 4, 1, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 5, '5', 1, 4, 1, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 6, '6/1', 2, 5, 2, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 7, '7/2', 2, 5, 2, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 8, '8/3', 2, 6, 2, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 9, '9/4', 3, 6, 3, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 10, '10/5', 3, 7, 3, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 11, '11/6/1', 3, 7, 3, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 12, '12/7/2', 4, 8, 4, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 13, '13/8/3', 4, 8, 4, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 14, '14/9/4', 4, 9, 4, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 15, '15/10/5', 5, 9, 5, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 16, '16/11/6/1', 5, 10, 5, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 17, '17/12/7/2', 5, 10, 5, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 18, '18/13/8/3', 6, 11, 6, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 19, '19/14/9/4', 6, 11, 6, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 20, '20/15/10/5', 6, 12, 6, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0)
ON DUPLICATE KEY UPDATE cn_bba = VALUES(cn_bba), cn_reflexes = VALUES(cn_reflexes), cn_vigueur = VALUES(cn_vigueur),
  cn_volonte = VALUES(cn_volonte), cn_sort_n0 = VALUES(cn_sort_n0), cn_sort_n1 = VALUES(cn_sort_n1), cn_sort_n2 = VALUES(cn_sort_n2),
  cn_sort_n3 = VALUES(cn_sort_n3), cn_sort_n4 = VALUES(cn_sort_n4), cn_sort_n5 = VALUES(cn_sort_n5);
DELETE FROM dd_classe_competence WHERE ccomp_cla_id = @c;
INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @c, comp_id, NULL FROM dd_competences
WHERE comp_ruleset_var_id = @ddver AND TRIM(comp_nom) IN ('Dressage', 'Équitation', 'Escalade', 'Intimidation', 'Natation', 'Saut');

-- ------------------------------------------------------------ Noble
INSERT INTO dd_classes (cla_nom, cla_clt_id, cla_res_id, cla_ruleset_var_id, cla_camp_id, cla_public, cla_visible)
SELECT 'Noble', 3, @gdm, @ddver, NULL, 0, 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 3 AND TRIM(cla_nom) = 'Noble');
SET @c := (SELECT cla_id FROM dd_classes WHERE cla_ruleset_var_id = @ddver AND cla_clt_id = 3 AND TRIM(cla_nom) = 'Noble' ORDER BY cla_id LIMIT 1);
UPDATE dd_classes SET
  cla_nom = 'Noble',
  cla_abreviation = 'Nob',
  cla_clt_id = 3,
  cla_dV = 8,
  cla_car_id = 0,
  cla_mag_id = 0,
  cla_profil_incantation = 0,
  cla_renouvellement = 0,
  cla_sort_connu = 0,
  cla_sort_compris = 0,
  cla_sort_prepare = 0,
  cla_domaine_divin = 0,
  cla_niveauMax = 20,
  cla_pointsCompetences = 4,
  cla_po_niveau1 = 0,
  cla_conditions = NULL,
  cla_armes = '<p>Le noble est formé au maniement de toutes les armes courantes, des armes de guerre et des boucliers (à l''exception du pavois). Il est formé au port de toutes les armures.</p>',
  cla_sorts = NULL,
  cla_description = '<p><strong>Équipement de départ.</strong> Pour 6d8 × 10 po d''équipement.</p>'
WHERE cla_id = @c;
INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte,
  cn_sort_n0, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4, cn_sort_n5,
  cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif, cn_sortsBonus)
VALUES
(@c, 1, '0', 0, 0, 2, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 2, '1', 0, 0, 3, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 3, '2', 1, 1, 3, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 4, '3', 1, 1, 4, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 5, '3', 1, 1, 4, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 6, '4', 2, 2, 5, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 7, '5', 2, 2, 5, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 8, '6/1', 2, 2, 6, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 9, '6/1', 3, 3, 6, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 10, '7/2', 3, 3, 7, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 11, '8/3', 3, 3, 7, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 12, '9/4', 4, 4, 8, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 13, '9/4', 4, 4, 8, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 14, '10/5', 4, 4, 9, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 15, '11/6/1', 5, 5, 9, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 16, '12/7/2', 5, 5, 10, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 17, '12/7/2', 5, 5, 10, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 18, '13/8/3', 6, 6, 11, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 19, '14/9/4', 6, 6, 11, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0),
(@c, 20, '15/10/5', 6, 6, 12, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0)
ON DUPLICATE KEY UPDATE cn_bba = VALUES(cn_bba), cn_reflexes = VALUES(cn_reflexes), cn_vigueur = VALUES(cn_vigueur),
  cn_volonte = VALUES(cn_volonte), cn_sort_n0 = VALUES(cn_sort_n0), cn_sort_n1 = VALUES(cn_sort_n1), cn_sort_n2 = VALUES(cn_sort_n2),
  cn_sort_n3 = VALUES(cn_sort_n3), cn_sort_n4 = VALUES(cn_sort_n4), cn_sort_n5 = VALUES(cn_sort_n5);
DELETE FROM dd_classe_competence WHERE ccomp_cla_id = @c;
INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @c, comp_id, NULL FROM dd_competences
WHERE comp_ruleset_var_id = @ddver AND TRIM(comp_nom) IN ('Bluff', 'Connaissances (architecture et ingénierie)', 'Connaissances (exploration souterraine)', 'Connaissances (folklore local)', 'Connaissances (géographie)', 'Connaissances (histoire)', 'Connaissances (mystères)', 'Connaissances (nature)', 'Connaissances (noblesse et royauté)', 'Connaissances (plans)', 'Connaissances (religion)', 'Contrefaçon', 'Déguisement', 'Détection', 'Diplomatie', 'Dressage', 'Équitation', 'Estimation', 'Intimidation', 'Langue', 'Natation', 'Perception auditive', 'Psychologie', 'Renseignements', 'Représentation', 'Survie');

COMMIT;
