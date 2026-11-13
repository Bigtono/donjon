-- sql/2026-11-11_sp-cr4_tableaux_capacites_classes.sql
-- SP-CR4 — Tableaux HTML restés dans les descriptions de capacités spéciales (DD3.5)
--
-- Huit tableaux saisis dans dd_tableaux (convention texte), catégorie Classe (Race pour la capacité de la créature
-- céleste), source = celle de la classe ou de la race. Chaque <table> des descriptions est remplacé par
-- <p>[[tab:slug]]</p>. Le tableau « pistage » (DD de base selon le sol), créé en local dans l'appli, est rejoué ici pour exister aussi
-- en production ; il est appelé par la capacité du rôdeur. Les modificateurs au DD du pistage ne forment qu'un tableau, appelé par le rôdeur et par le rôdeur bédouin.
-- Retouches de texte : « dégêts » → « Dégâts » (légende de la capacité du moine reprise comme titre du tableau, légende retirée
-- de la description) ; « écoutées » → « écoulées » ; sous-lignes du pistage rendues par un tiret (la grille à colonne de retrait
-- n'a pas d'équivalent) ; exposants <sup> → ¹ ². Voir doc/LOG_CORRECTIONS_CAPACITES_TABLEAUX.md.
-- Capacités retrouvées par leur nom et leur classe / race (les ids peuvent différer entre local et production) ; la réécriture
-- d'une description est gardée par le MD5 du texte local : un texte différent en production n'est pas touché. Rejouable.
-- Datée du 11 pour passer après les migrations antérieures (ordre alphabétique du nom complet). Pas de DELIMITER.

SET NAMES utf8mb4;

SET @ddver   := (SELECT var_id FROM dd_variables WHERE var_cat = 'ruleset' AND var_valeur = 'DD3.5' LIMIT 1);
SET @catcla  := (SELECT tabc_id FROM dd_tableaux_categories WHERE tabc_slug = 'classe' LIMIT 1);
SET @catrace := (SELECT tabc_id FROM dd_tableaux_categories WHERE tabc_slug = 'race' LIMIT 1);
SET @now     := NOW();

START TRANSACTION;

-- ============================================================ 1. Tableaux

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id,
                         tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES ('pistage', 'Pistage',
'!Sol|DD
Très mou|5
Mou|10
Ferme|15
Dur|20',
NULL, NULL, @catcla, @ddver, (SELECT res_id FROM dd_ressources WHERE res_abreviation = 'DRS 3.5' AND res_ruleset_var_id = @ddver LIMIT 1), NULL, 0, 0, 1, @now, @now)
ON DUPLICATE KEY UPDATE tab_nom = VALUES(tab_nom), tab_contenu = VALUES(tab_contenu), tab_align = VALUES(tab_align),
  tab_tabc_id = VALUES(tab_tabc_id), tab_res_id = VALUES(tab_res_id), tab_date_modif = @now;

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id,
                         tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES ('classe-druide-compagnon-animal', 'Druide : compagnon animal',
'! Niveau de classe | DV sup. | Aj. d''armure naturelle | Aj. de For/Dex | Tours sup. | Spécial
1–2 | +0 | +0 | +0 | 1 | Lien, transfert d''effet magique
3–5 | +2 | +2 | +1 | 2 | Esquive totale
6–8 | +4 | +4 | +2 | 3 | Dévotion
9–11 | +6 | +6 | +3 | 4 | Attaques multiples
12–14 | +8 | +8 | +4 | 5 |
15–17 | +10 | +10 | +5 | 6 | Esquive extraordinaire
18–20 | +12 | +12 | +6 | 7 |',
'cccccl', NULL, @catcla, @ddver, (SELECT cla_res_id FROM dd_classes WHERE cla_nom = 'Druide' AND cla_ruleset_var_id = @ddver ORDER BY cla_id LIMIT 1), NULL, 0, 0, 1, @now, @now)
ON DUPLICATE KEY UPDATE tab_nom = VALUES(tab_nom), tab_contenu = VALUES(tab_contenu), tab_align = VALUES(tab_align),
  tab_tabc_id = VALUES(tab_tabc_id), tab_res_id = VALUES(tab_res_id), tab_date_modif = @now;

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id,
                         tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES ('classe-magicien-familiers', 'Magicien : familiers',
'! Familier | Faculté spéciale
Belette | Le maître obtient un bonus de +2 aux jets de Réflexes
Chat | Le maître obtient un bonus de +3 aux tests de Déplacement silencieux
Chauve-souris | Le maître obtient un bonus de +3 aux tests de Perception auditive
Chouette | Le maître obtient un bonus de +3 aux tests de Détection dans l''obscurité
Corbeau¹ | Le maître obtient un bonus de +3 aux tests d''Estimation
Crapaud | Le maître obtient +3 points de vie
Faucon | Le maître obtient un bonus de +3 aux tests de Détection sous une lumière vive
Rat | Le maître obtient un bonus de +2 aux jets de Vigueur
Serpent² | Le maître obtient un bonus de +3 aux tests de Bluff
Lézard | Le maître obtient un bonus de +2 aux tests d''Escalade',
'll', NULL, @catcla, @ddver, (SELECT cla_res_id FROM dd_classes WHERE cla_nom = 'Magicien' AND cla_ruleset_var_id = @ddver ORDER BY cla_id LIMIT 1), NULL, 0, 0, 1, @now, @now)
ON DUPLICATE KEY UPDATE tab_nom = VALUES(tab_nom), tab_contenu = VALUES(tab_contenu), tab_align = VALUES(tab_align),
  tab_tabc_id = VALUES(tab_tabc_id), tab_res_id = VALUES(tab_res_id), tab_date_modif = @now;

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id,
                         tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES ('classe-magicien-familier-progression', 'Magicien : progression du familier',
'! Niveau de classe du maître | Aj. d''armure naturelle | Int | Spécial
1-2 | +1 | 6 | Esquive extraordinaire, transfert d''effet magique, lien télépathique, vigilance
3-4 | +2 | 7 | Conduit
5-6 | +3 | 8 | Communication avec le maître
7-8 | +4 | 9 | Communication avec les animaux du même type
9-10 | +5 | 10 |
11-12 | +6 | 11 | Résistance à la magie
13-14 | +7 | 12 | Scrutation sur le familier
15-16 | +8 | 13 |
17-18 | +9 | 14 |
19-20 | +10 | 15 |',
'cccl', NULL, @catcla, @ddver, (SELECT cla_res_id FROM dd_classes WHERE cla_nom = 'Magicien' AND cla_ruleset_var_id = @ddver ORDER BY cla_id LIMIT 1), NULL, 0, 0, 1, @now, @now)
ON DUPLICATE KEY UPDATE tab_nom = VALUES(tab_nom), tab_contenu = VALUES(tab_contenu), tab_align = VALUES(tab_align),
  tab_tabc_id = VALUES(tab_tabc_id), tab_res_id = VALUES(tab_res_id), tab_date_modif = @now;

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id,
                         tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES ('classe-moine-mains-nues-taille', 'Dégâts à mains nues des moines de taille P et G',
'! Niveau | Dégâts (taille P) | Dégâts (taille G)
1-3 | 1d4 | 1d8
4-7 | 1d6 | 2d6
8-11 | 1d8 | 2d8
12-15 | 1d10 | 3d6
16-19 | 2d6 | 3d8
20 | 2d8 | 4d8',
'lcc', NULL, @catcla, @ddver, (SELECT cla_res_id FROM dd_classes WHERE cla_nom = 'Moine' AND cla_ruleset_var_id = @ddver ORDER BY cla_id LIMIT 1), NULL, 0, 0, 1, @now, @now)
ON DUPLICATE KEY UPDATE tab_nom = VALUES(tab_nom), tab_contenu = VALUES(tab_contenu), tab_align = VALUES(tab_align),
  tab_tabc_id = VALUES(tab_tabc_id), tab_res_id = VALUES(tab_res_id), tab_date_modif = @now;

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id,
                         tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES ('classe-rodeur-pistage-modificateurs', 'Pistage : modificateurs au DD',
'! Conditions en vigueur | Mod. DD
Pour 3 créatures faisant partie du groupe pisté | -1
Taille des créatures traquées¹ : |
– Infime (I) | +8
– Minuscule (Min) | +4
– Très petite (TP) | +2
– Petite (P) | +1
– Moyenne (M) | 0
– Grande (G) | -1
– Très grande (TG) | -2
– Gigantesque (Gig) | -4
– Colossale (C) | -8
Par tranche de 24 heures écoulées depuis que la piste a été laissée | +1
Par heure de pluie depuis que la piste a été laissée | +1
Chute de neige depuis que la piste a été laissée | +10
Mauvaise visibilité² : |
– Ciel nocturne couvert ou nuit sans lune | +6
– Clair de lune | +3
– Brouillard ou précipitations (pluie, neige, etc.) | +3
La cible masque sa piste (ce qui réduit sa vitesse de déplacement de moitié) | +5',
'lc', NULL, @catcla, @ddver, (SELECT cla_res_id FROM dd_classes WHERE cla_nom = 'Rôdeur' AND cla_ruleset_var_id = @ddver ORDER BY cla_id LIMIT 1), NULL, 0, 0, 1, @now, @now)
ON DUPLICATE KEY UPDATE tab_nom = VALUES(tab_nom), tab_contenu = VALUES(tab_contenu), tab_align = VALUES(tab_align),
  tab_tabc_id = VALUES(tab_tabc_id), tab_res_id = VALUES(tab_res_id), tab_date_modif = @now;

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id,
                         tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES ('classe-olin-gisir-secrets', 'Olin Gisir : secrets',
'! Niveau + mod. Int | Secret | Effet
1 | Connaissance des langues | Apprentissage de 3 nouveaux langages (tous exceptés les langages secrets)
2 | Secret de Santé | +3 points de vie
3 | Secret de Force Intérieure | +2 aux jets de Volonté
4 | Connaissance de la vraie endurance | +2 aux jets de Vigueur
5 | Navigation de donjon | Sens des pièges +2 (comme la capacité du roublard)
6 | Vision du caché | +4 aux jets de Fouille
7 | Ancien artifice | Don de création d''objet en tant que don supplémentaire
8 | Connaissance des sorts oubliée | Don de métamagie en tant que don supplémentaire
9 | Conjuration de démon | +2 de bonus sacré à la CA et sur les jets de sauvegarde contre les attaques faites par les Extérieurs mauvais
10 ou plus | Pensée focalisée | Résistance à la magie de 20 contre les sorts d''enchantement',
'cll', NULL, @catcla, @ddver, (SELECT cla_res_id FROM dd_classes WHERE cla_nom = 'Olin Gisir' AND cla_ruleset_var_id = @ddver ORDER BY cla_id LIMIT 1), NULL, 0, 0, 1, @now, @now)
ON DUPLICATE KEY UPDATE tab_nom = VALUES(tab_nom), tab_contenu = VALUES(tab_contenu), tab_align = VALUES(tab_align),
  tab_tabc_id = VALUES(tab_tabc_id), tab_res_id = VALUES(tab_res_id), tab_date_modif = @now;

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_tabc_id, tab_ruleset_var_id, tab_res_id,
                         tab_camp_id, tab_ecran_mj, tab_ecran_ordre, tab_visible, tab_date_creation, tab_date_modif)
VALUES ('race-celeste-particularites', 'Créature céleste : particularités',
'! Dés de vie | Résistance à l''acide, au froid et à l''électricité | Réduction des dégâts
1–3 | 5 | —
4–7 | 5 | 5/magie
8–11 | 10 | 5/magie
12 et plus | 10 | 10/magie',
'ccc', NULL, @catrace, @ddver, (SELECT ra_res_id FROM dd_races WHERE ra_nom = 'Céleste' AND ra_ruleset_var_id = @ddver ORDER BY ra_id LIMIT 1), NULL, 0, 0, 1, @now, @now)
ON DUPLICATE KEY UPDATE tab_nom = VALUES(tab_nom), tab_contenu = VALUES(tab_contenu), tab_align = VALUES(tab_align),
  tab_tabc_id = VALUES(tab_tabc_id), tab_res_id = VALUES(tab_res_id), tab_date_modif = @now;

-- ============================================================ 2. Descriptions des capacités

-- Druide : Compagnon animal (druide) (ext) (local cap_id 31) — 1 tableau(x)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id JOIN dd_classes cl ON cl.cla_id = cc.cc_cla_id WHERE cl.cla_nom = 'Druide' AND cl.cla_ruleset_var_id = @ddver AND TRIM(cs.cap_nom) = 'Compagnon animal (druide) (ext)' AND cs.cap_description LIKE '%<table%' LIMIT 1);
UPDATE dd_capacites_speciales SET cap_description = '<p>&nbsp;Au d&eacute;but du jeu, un druide peut avoir un compagnon animal choisi dans la liste suivante : aigle, blaireau, chameau, cheval (l&eacute;ger ou lourd), chien de selle, chien, chouette, faucon, loup, poney, rat sanguinaire et serpent venimeux (petit ou de taille moyenne). Si la campagne se d&eacute;roule enti&egrave;rement ou partiellement dans un milieu aquatique, on peut ajouter les animaux suivants &agrave; cette liste : calmar, marsouin et requin de taille moyenne. Un compagnon animal suit loyalement le personnage au cours de ses aventures au mieux de ses capacit&eacute;s.</p>

<p>Le compagnon animal d&rsquo;un druide de niveau 1 est un animal tout &agrave; fait normal pour son esp&egrave;ce, aux exceptions indiqu&eacute;es plus loin. Lorsque le druide progresse en exp&eacute;rience, la puissance de l&rsquo;animal augmente elle aussi, selon la table contenu dans l&rsquo;encart.</p>

<p>Si un druide d&eacute;cide de se s&eacute;parer de son compagnon animal, il peut en obtenir un autre en accomplissant un rituel qui n&eacute;cessite 24 heures de pri&egrave;res ininterrompues. Cette c&eacute;r&eacute;monie peut aussi permettre de remplacer un compagnon animal qui aurait &eacute;t&eacute; tu&eacute;.</p>

<p>Un druide de niveau 4 ou plus peut choisir un compagnon animal hors norme (voir plus loin). Dans ce cas, l&rsquo;animal augmente en puissance comme si le personnage &eacute;tait d&rsquo;un niveau de druide moins &eacute;lev&eacute;. Il faut retirer le nombre indiqu&eacute; dans l&rsquo;en-t&ecirc;te correspondant &agrave; l&rsquo;animal choisi au niveau de druide du personnage pour d&eacute;terminer la puissance de l&rsquo;animal. (Si cet ajustement r&eacute;duit le niveau effectif de druide &agrave; 0 ou moins, le personnage ne peut poss&eacute;der un compagnon animal de cette esp&egrave;ce.)</p>

<h2>Le compagnon animal du druide</h2>

<p>Le compagnon animal d&rsquo;un druide est initialement un animal ordinaire. Au contact du druide et gr&acirc;ce &agrave; des rituels r&eacute;guliers, il devient plus fort et plus malin qu&rsquo;un membre moyen de son esp&egrave;ce. Il reste n&eacute;anmoins intrins&egrave;quement un animal, et son Intelligence n&rsquo;est pas affect&eacute;e. Il est li&eacute; &agrave; son ma&icirc;tre et obtient ainsi quelques pouvoirs sp&eacute;ciaux, qui sont d&eacute;crits ci-dessous.</p>

<p>[[tab:classe-druide-compagnon-animal]]</p>

<p>&nbsp;</p>

<p><strong>Profil des compagnons animaux. </strong>Utilisez le profil fourni pour l&rsquo;animal correspondant en faisant les modifications suivantes.</p>

<p><em>Niveau de classe.</em> Il s&rsquo;agit du niveau de druide du personnage. Le niveau de classe du druide se cumule avec le niveau de toutes les classes qui ont droit elle aussi &agrave; un compagnon animal (comme le r&ocirc;deur) pour d&eacute;terminer la puissance du compagnon et les animaux hors-normes accessibles au personnage.</p>

<p><em>DV sup. </em>L&rsquo;animal obtient des d&eacute;s de vie suppl&eacute;mentaires (des d8), qui sont ajout&eacute;s &agrave; ses points de vie (avec le modificateur de Constitution habituel). Cette augmentation de d&eacute;s de vie influe aussi sur ses bonus de base &agrave; l&rsquo;attaque et aux sauvegarde. Son bonus de base &agrave; l&rsquo;attaque est moyen (comme un druide), ses bonus de base de R&eacute;flexes et de Vigueur sont &eacute;lev&eacute;s et celui de Volont&eacute; est faible. (Voir la Table : bonus de base &agrave; l&rsquo;attaque et aux sauvegardes, en consid&eacute;rant un niveau &eacute;gal &agrave; ses d&eacute;s de vie.) Les DV suppl&eacute;mentaires d&rsquo;un compagnon animal lui donnent aussi des points de comp&eacute;tence et des dons, selon la m&eacute;thode d&rsquo;&eacute;volution normale des monstres.</p>

<p><em>Aj. d&rsquo;armure naturelle. </em>L&rsquo;ajustement indiqu&eacute; vient s&rsquo;ajouter au bonus d&rsquo;armure naturelle &agrave; la CA existant de l&rsquo;animal.</p>

<p><em>Aj. de For/Dex. </em>Cet ajustement s&rsquo;applique aux valeurs de Force et de Dext&eacute;rit&eacute; du compagnon animal.</p>

<p><em>Tours sup. </em>Le compagnon animal conna&icirc;t le nombre indiqu&eacute; de tours suppl&eacute;mentaires, en plus de ceux que le druide peut lui apprendre par ailleurs (voir la comp&eacute;tence Dressage). Ces tours suppl&eacute;mentaires ne n&eacute;cessitent ni temps d&rsquo;apprentissage ni test de Dressage et ils ne comptent pas dans le nombre total de tours qu&rsquo;un animal peut apprendre. Le druide choisit quels tours sont connus de l&rsquo;animal et ils ne peuvent plus &ecirc;tre chang&eacute;s une fois choisis.</p>

<p><em>Lien (Ext). </em>Un druide peut diriger son compagnon animal par une action libre, ou le pousser par une action de mouvement, et ce m&ecirc;me s&rsquo;il ne poss&egrave;de pas un degr&eacute; de ma&icirc;trise en Dressage de 1 ou plus. Le druide b&eacute;n&eacute;ficie d&rsquo;un bonus de circonstances de +4 sur les tests d&rsquo;empathie sauvage et de Dressage en rapport avec son compagnon animal.</p>

<p><em>Transfert d&rsquo;effet magique (Ext). </em>Si le druide le souhaite, tout sort (mais pas un pouvoir magique) qu&rsquo;il lance sur lui- m&ecirc;me peut &eacute;galement affecter son compagnon animal. Ce dernier doit se trouver &agrave; 1,50 m&egrave;tre ou moins de distance au moment de l&rsquo;incantation pour b&eacute;n&eacute;ficier des effets du sort. Si le sort a une dur&eacute;e autre qu&rsquo;instantan&eacute;e, il cesse d&rsquo;affecter le compagnon animal si celui-ci s&rsquo;&eacute;loigne de son ma&icirc;tre de plus de 1,50 m&egrave;tre. Dans ce cas, l&rsquo;effet du sort ne reprend pas m&ecirc;me si le compagnon revient &agrave; c&ocirc;t&eacute; du druide. De plus, le personnage peut lancer directement sur son compagnon animal tout sort &agrave; port&eacute;e personnelle (il a alors une port&eacute;e de contact) au lieu de le lancer sur lui- m&ecirc;me. Ce transfert d&rsquo;effet magique est permis m&ecirc;me si, en temps normal, le sort ne devrait pas affecter une entit&eacute; du type du compagnon (animal).</p>

<p><em>Esquive totale (Ext).</em> Lorsque le compagnon animal est soumis &agrave; un effet qui autorise un jet de R&eacute;flexes pour demi- d&eacute;g&acirc;ts, il ne subit aucun d&eacute;g&acirc;t s&rsquo;il r&eacute;ussit son jet de sauvegarde.</p>

<p><em>D&eacute;votion (Ext). </em>La d&eacute;votion du compagnon animal pour son ma&icirc;tre est telle qu&rsquo;il obtient du bonus de moral de +4 sur ses jets de sauvegarde contre les sorts et effets de l&rsquo;&eacute;cole des enchantements.</p>

<p><em>Attaques multiples (Ext). </em>Le compagnon animal obtient automatiquement ce don en tant que don suppl&eacute;mentaire, &agrave; condition d&rsquo;avoir au moins trois attaques naturelles et de ne pas d&eacute;j&agrave; le poss&eacute;der. Si l&rsquo;animal ne remplit pas la condition des trois attaques naturelles, il obtient &agrave; la place de ce don la possibilit&eacute; de porter une seconde attaque &agrave; l&rsquo;aide de son arme naturelle principale, mais avec un malus de &ndash;5.</p>

<p><em>Esquive extraordinaire (Ext). </em>Lorsque le compagnon animal est soumis &agrave; un effet qui autorise un jet de R&eacute;flexes pour demi-d&eacute;g&acirc;ts, il ne subit aucun d&eacute;g&acirc;t s&rsquo;il r&eacute;ussit son jet de sauvegarde et la moiti&eacute; des d&eacute;g&acirc;ts dans le cas contraire. Compagnons animaux hors-normes Un druide d&rsquo;un niveau suffisamment &eacute;lev&eacute; peut choisir son compagnon animal parmi la liste suivante, en appliquant la r&eacute;duction indiqu&eacute;e sur son niveau effectif de druide pour d&eacute;terminer la puissance et les pouvoirs de son compagnon hors-norme.</p>

<h2>Compagnons animaux hors-normes</h2>

<p>Un druide d&rsquo;un niveau suffisamment &eacute;lev&eacute; peut choisir son compagnon animal parmi la liste suivante, en appliquant la r&eacute;duction indiqu&eacute;e sur son niveau effectif de druide pour d&eacute;terminer la puissance et les pouvoirs de son compagnon hors-norme.<br />
&nbsp;</p>
'
WHERE cap_id = @k AND MD5(cap_description) = '3679584a34e65388c48a3ac2cc2b589f';

-- Magicien : Appel de familier (local cap_id 44) — 2 tableau(x)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id JOIN dd_classes cl ON cl.cla_id = cc.cc_cla_id WHERE cl.cla_nom = 'Magicien' AND cl.cla_ruleset_var_id = @ddver AND TRIM(cs.cap_nom) = 'Appel de familier' AND cs.cap_description LIKE '%<table%' LIMIT 1);
UPDATE dd_capacites_speciales SET cap_description = '<p>Appel de familier. Le magicien a la possibilit&eacute; d&#39;appeler un familier, ce qui lui demande une journ&eacute;e enti&egrave;re et des composantes mat&eacute;rielles valant 100 po. Un familier est une cr&eacute;ature magique qui ressemble &agrave; un petit animal, mais plus r&eacute;sistant et plus intelligent. Il est autant le compagnon que le serviteur du personnage. Le magicien choisit le type de familier qui r&eacute;pond &agrave; son appel. La puissance du familier cro&icirc;t avec celle de son ma&icirc;tre. Si le familier meurt ou si le magicien le renvoie, le personnage doit jouer un jet de Vigueur (DD 15). En cas d&#39;&eacute;chec, il perd 200 PX par niveau de magicien (en cas de r&eacute;ussite, ce total est r&eacute;duit de moiti&eacute;). Le nombre de points d&#39;exp&eacute;rience du personnage ne peut jamais tomber en dessous de 0 suite au d&eacute;c&egrave;s ou au renvoi de son familier. Un familier tu&eacute; ou renvoy&eacute; ne peut &ecirc;tre remplac&eacute; avant un an et un jour. Les familiers peuvent &ecirc;tre ramen&eacute;s &agrave; la vie de la m&ecirc;me mani&egrave;re que les personnages, mais eux ne perdent alors pas de niveau (ou de points de Constitution). Un personnage multiclass&eacute; dont plusieurs classes donnent droit &agrave; un familier ne peut tout de m&ecirc;me avoir qu&#39;un familier &agrave; la fois.</p>

<p><strong>Les familiers</strong></p>

<p>Un familier est un animal normal qui obtient de nouveaux pouvoirs lorsqu&#39;il est convoqu&eacute; au service d&#39;un ensorceleur ou d&#39;un magicien. Il conserve l&#39;apparence, les d&eacute;s de vie, les bonus de base &agrave; l&#39;attaque et aux sauvegardes, les comp&eacute;tences et les dons de l&#39;animal qu&#39;il fut autrefois, mais il est consid&eacute;r&eacute; comme une cr&eacute;ature magique plut&ocirc;t qu&#39;un animal pour tous les effets qui tiennent compte du type d&#39;une cr&eacute;ature. Seul un animal n&#39;ayant pas &eacute;t&eacute; modifi&eacute; par la magie peut devenir un familier. Cela signifie qu&#39;un druide/ensorceleur ne peut faire un familier de son compagnon animal.</p>

<p>Les familiers poss&egrave;dent des facult&eacute;s sp&eacute;ciales qu&#39;ils transmettent &agrave; leur ma&icirc;tre. Ces pouvoirs ne fonctionnent que lorsque le personnage et son familier sont &agrave; moins de 1,5 kilom&egrave;tre l&#39;un de l&#39;autre.</p>

<p>Les niveaux des diff&eacute;rentes classes qui ont droit &agrave; un familier (comme l&#39;ensorceleur et le magicien) se cumulent pour donner le niveau du ma&icirc;tre, qui d&eacute;termine les pouvoirs du familier.</p>

<p>[[tab:classe-magicien-familiers]]</p>

<p><sup>1</sup> Un corbeau familier parle une langue du choix de son ma&icirc;tre en tant que pouvoir surnaturel.</p>

<p><sup>2</sup> Un tr&egrave;s petit serpent venimeux.</p>

<p><strong>Profil des familiers.</strong> Utilisez le profil fourni pour l&#39;animal correspondant, en faisant les modifications suivantes :</p>

<p><strong>D&eacute;s de vie.</strong> Pour tous les effets li&eacute;s au nombre de DV, substituez le niveau du ma&icirc;tre au nombre de DV du familier (ou conservez le nombre de DV de la cr&eacute;ature s&#39;il est plus &eacute;lev&eacute;).</p>

<p><strong>Points de vie. </strong>Un familier a la moiti&eacute; des points de vie de son ma&icirc;tre (en arrondissant &agrave; l&#39;entier inf&eacute;rieur), sans compter les points de vie temporaires.</p>

<p><strong>Attaques. </strong>Le bonus de base &agrave; l&#39;attaque est &eacute;gal &agrave; celui du ma&icirc;tre, auquel on ajoute le modificateur de Force ou de Dext&eacute;rit&eacute; du familier (prenez le plus &eacute;lev&eacute; des deux). Les d&eacute;g&ecirc;ts inflig&eacute;s sont les m&ecirc;mes que pour un animal de cette esp&egrave;ce.</p>

<p><strong>Jets de sauvegarde. </strong>Pour chaque cat&eacute;gorie de sauvegarde, le familier utilise soit les bonus de base de son ma&icirc;tre soit les siens (R&eacute;flexes +2, Vigueur +2, Volont&eacute; +0) s&#39;ils sont meilleurs. Le familier applique ses propres modificateurs de caract&eacute;ristiques aux jets de sauvegarde et il n&#39;obtient pas tout autre bonus sur les jets de sauvegarde dont pourrait b&eacute;n&eacute;ficier son ma&icirc;tre.</p>

<p><strong>Comp&eacute;tences. </strong>Pour chaque comp&eacute;tence poss&eacute;d&eacute;e par le ma&icirc;tre ou le familier, celui-ci utilise soit le degr&eacute; de ma&icirc;trise de son ma&icirc;tre soit ceux d&#39;un animal ordinaire de son esp&egrave;ce s&#39;ils sont meilleurs. Le familier applique ses propres modificateurs de caract&eacute;ristiques aux tests de comp&eacute;tence. Quel que soit le modificateur final de comp&eacute;tence d&#39;un familier, certaines (comme Artisanat) resteront hors de port&eacute;e pour un animal.</p>

<p>[[tab:classe-magicien-familier-progression]]</p>

<p><strong>Description des pouvoirs sp&eacute;ciaux des familiers. </strong>Tous les familiers ont des pouvoirs sp&eacute;ciaux (ou les transmettent &agrave; leur ma&icirc;tre) d&eacute;pendant du niveau combin&eacute; de celui-ci dans les diff&eacute;rentes classes qui ont droit &agrave; un familier. Tous ces pouvoirs sont cumulatifs.</p>

<p><em>Aj. d&#39;armure naturelle</em>. L&#39;ajustement indiqu&eacute; vient s&#39;ajouter au bonus d&#39;armure naturelle &agrave; la CA existant du familier. Il repr&eacute;sente sa r&eacute;sistance surnaturelle.</p>

<p><em>Int</em>. La valeur d&#39;Intelligence du familier. Les familiers sont aussi intelligents que des gens ordinaires, mais pas autant que des g&eacute;nies.</p>

<p><em>Esquive extraordinaire (Ext)</em>. Si le familier est pris pour cible par une attaque autorisant un jet de R&eacute;flexes pour r&eacute;duire de moiti&eacute; les d&eacute;g&ecirc;ts occasionn&eacute;s, il l&#39;&eacute;vite totalement en cas de jet de sauvegarde r&eacute;ussi (m&ecirc;me s&#39;il le rate, l&#39;attaque ne lui inflige que demi-d&eacute;g&ecirc;ts).</p>

<p><em>Transfert d&#39;effet magique</em>. Si le personnage le souhaite, tout sort (mais pas un pouvoir magique) qu&#39;il lance sur lui-m&ecirc;me peut &eacute;galement affecter son familier. Ce dernier doit se trouver &agrave; moins de 1,50 m&egrave;tre de distance au moment de l&#39;incantation. Si le sort a une dur&eacute;e autre qu&#39;instantan&eacute;e, il cesse d&#39;affecter la cr&eacute;ature si celle-ci s&#39;&eacute;loigne trop de son ma&icirc;tre de plus de 1,50 m&egrave;tre. Dans ce cas, l&#39;effet du sort ne reprend pas m&ecirc;me si le familier revient &agrave; c&ocirc;t&eacute; de l&#39;ensorceleur. De plus, le personnage peut lancer directement sur son familier tout sort &agrave; port&eacute;e personnelle (il a alors une port&eacute;e de contact) au lieu de le lancer sur lui-m&ecirc;me. Ce transfert d&#39;effet magique est permis m&ecirc;me si, en temps normal, le sort ne devrait pas affecter une entit&eacute; du type du familier (cr&eacute;ature magique).</p>

<p><em>Lien t&eacute;l&eacute;pathique (Sur)</em>. Le personnage dispose d&#39;un lien t&eacute;l&eacute;pathique avec son familier tant que celui-ci reste &agrave; moins de 1,5 kilom&egrave;tre. Il ne voit pas par les yeux de la cr&eacute;ature mais peut communiquer t&eacute;l&eacute;pathiquement avec elle. &Agrave; cause de la nature limit&eacute;e du lien, seuls des sentiments g&eacute;n&eacute;raux peuvent &ecirc;tre transmis (comme la peur, la faim, le bonheur ou la curiosit&eacute;). Notez que l&#39;Intelligence limit&eacute;e d&#39;un familier de personnage de bas niveau restreint s&eacute;v&egrave;rement ce qu&#39;il est capable de comprendre ou de rapporter, et que m&ecirc;me les familiers intelligents voient le monde d&#39;une fa&ccedil;on bien diff&eacute;rente de celle des humains.</p>

<p>En raison du lien unissant le familier &agrave; son ma&icirc;tre, celui-ci a le m&ecirc;me rapport que la cr&eacute;ature &agrave; un lieu ou &agrave; un objet. Par exemple, si le familier observe une pi&egrave;ce que le personnage n&#39;a jamais vue, ce dernier peut s&#39;y t&eacute;l&eacute;porter comme s&#39;il l&#39;avait personnellement observ&eacute;e.</p>

<p><em>Vigilance (Ext)</em>. La pr&eacute;sence du familier aff&ucirc;te les sens de son ma&icirc;tre. Tant que la cr&eacute;ature se trouve &agrave; port&eacute;e de main (au sens litt&eacute;ral), le personnage b&eacute;n&eacute;ficie du don Vigilance.</p>

<p><em>Conduit (Sur)</em>. Le familier d&#39;un ma&icirc;tre de niveau 3 peut placer les sorts de contact &agrave; sa place. Quand le personnage lance un sort de contact, il peut d&eacute;cider d&#39;utiliser son familier comme conduit (il doit le toucher au moment de l&#39;incantation). Le familier peut alors porter l&#39;attaque de contact normalement. Comme d&#39;habitude, si le personnage lance un autre sort, l&#39;&eacute;nergie du sort de contact se dissipe instantan&eacute;ment si le familier n&#39;a pas eu le temps de le transmettre.</p>

<p><em>Communication avec le ma&icirc;tre (Ext)</em>. Un ma&icirc;tre de niveau 5 et son familier peuvent communiquer verbalement, comme s&#39;ils utilisaient un langage existant, mais personne ne peut les comprendre sans assistance magique.</p>

<p><em>Communication avec les animaux du m&ecirc;me type (Ext)</em>. Le familier d&#39;un ma&icirc;tre de niveau 5 peut communiquer avec les animaux d&#39;une esp&egrave;ce voisine de la sienne (y compris les versions sanguinaires) : les chauves-souris peuvent ainsi s&#39;entretenir avec les chauves-souris ; les rats avec les rongeurs ; les chats avec les f&eacute;lins ; les faucons, les corbeaux et les chouettes avec les oiseaux ; les l&eacute;zards et les serpents avec les reptiles ; les crapauds avec les amphibiens ; et les belettes avec les animaux de la famille de must&eacute;lid&eacute;s (belettes, blaireaux, gloutons, hermines, moufettes, putois et zibelines). Les sujets de conversation sont limit&eacute;s par l&#39;Intelligence des participants.</p>

<p><em>R&eacute;sistance &agrave; la magie (Ext)</em>. &Agrave; partir du moment o&ugrave; son ma&icirc;tre atteint le niveau 11, le familier acquiert une r&eacute;sistance &agrave; la magie &eacute;gale au niveau du ma&icirc;tre + 5. Si un adversaire tente d&#39;affecter le familier &agrave; l&#39;aide d&#39;un sort, il doit effectuer un test de lanceur de sorts (1d20 + niveau de lanceur de sorts) et obtenir un r&eacute;sultat au moins &eacute;gal &agrave; la r&eacute;sistance &agrave; la magie du familier.</p>

<p><em>Scrutation sur le familier (Mag)</em>. Une fois par jour, un ma&icirc;tre de niveau 13 observer son familier &agrave; distance comme &agrave; l&#39;aide du sort <em>scrutation</em>.</p>
'
WHERE cap_id = @k AND MD5(cap_description) = '83a55df24ce48b7107b0b63aed3bff8a';

-- Moine : Combat à mains nues (local cap_id 106) — 1 tableau(x)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id JOIN dd_classes cl ON cl.cla_id = cc.cc_cla_id WHERE cl.cla_nom = 'Moine' AND cl.cla_ruleset_var_id = @ddver AND TRIM(cs.cap_nom) = 'Combat à mains nues' AND cs.cap_description LIKE '%<table%' LIMIT 1);
UPDATE dd_capacites_speciales SET cap_description = '<p>Le moine s''entra&icirc;ne longuement à se battre à mains nues, ce qui lui confère d''énormes avantages dans ce genre de situation. Un moine de niveau 1 re&ccedil;oit le don Science du combat à mains nues en tant que don supplémentaire. Ses attaques peuvent venir de ses poings, mais aussi des pieds, des coudes ou des genoux. Cela signifie qu''un moine peut m&ecirc;me porter des attaques &ldquo; à mains nues &rdquo; alors que ses deux mains sont occupées à porter quelque chose. De plus, la notion d''attaque secondaire de main non-directrice n''a pas de sens quand il se bat à mains nues. Un moine bénéficie donc toujours de son bonus de Force entier sur les jets de dégêts à mains nues.</p>

<p>En règle générale, les attaques à mains nues du moine infligent des dégêts létaux, mais le moine peut choisir d''infliger des dégêts non-létaux s''il le souhaite et ceci sans malus sur son jet d''attaque. Ce m&ecirc;me choix lui est offert en situation de lutte.</p>

<p>L''attaque à mains nues du moine est considérée à la fois comme une arme manufacturée et une arme naturelle pour les sorts et effets qui altèrent ou améliorent ces deux types d''armes (comme les sorts morsure magique et arme magique).</p>

<p>Les attaques à mains nues d''un moine infligent plus de dégêts que la normale, comme indiqué sur la Table : le moine. Les dégêts de cette table concernent uniquement un moine de taille M. Un moine de taille P inflige des dégêts moins importants, tandis qu&#39;un de taille G inflige des dégêts plus élevés, selon la table suivante.</p>

<p>[[tab:classe-moine-mains-nues-taille]]</p>

<p>&nbsp;</p>
'
WHERE cap_id = @k AND MD5(cap_description) = '12a94200c8a887e371071a00137a11ee';

-- Rôdeur : Pistage (local cap_id 107) — 2 tableau(x)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id JOIN dd_classes cl ON cl.cla_id = cc.cc_cla_id WHERE cl.cla_nom = 'Rôdeur' AND cl.cla_ruleset_var_id = @ddver AND TRIM(cs.cap_nom) = 'Pistage' AND cs.cap_description LIKE '%<table%' LIMIT 1);
UPDATE dd_capacites_speciales SET cap_description = '<p>l faut réussir un test de Survie pour trouver des traces ou les suivre pendant 1,5 kilomètre. Un nouveau test est nécessaire lorsque la piste devient plus difficile à suivre, comme par exemple quand d''autres traces la coupent ou quand elle se scinde en deux.</p>

<p>Tant qu''il piste, le personnage avance à la moitié de sa vitesse de déplacement. Il peut avancer de sa vitesse de déplacement avec un malus aux tests de compétence de -5, ou au double de sa vitesse de déplacement avec un malus de -20 aux tests de compétence. Le DD dépend du sol et des conditions en vigueur, selon la table suivante :</p>

<p>[[tab:pistage]]</p>

<p><em>Sol très mou</em>. Toute surface montrant des empreintes profondes et particulièrement lisibles (neige, boue, épaisse couche de poussière, etc.).<br />
<em>Sol mou</em>. Toute surface assez élastique pour s''enfoncer sous le poids d''un individu, mais plus résistante que la précédente. Les traces y sont nombreuses mais peu profondes.<br />
<em>Sol ferme</em>. La plupart des sols en extérieur (pelouse, champ, bois, etc.) et les surfaces molles ou extr&ecirc;mement sales à l''intérieur (épais tapis, sol crasseux, etc.). La créature suivie peut laisser quelques traces (brindilles cassées, touffes de poils, etc.), mais les empreintes, elles, sont extr&ecirc;mement rares.<br />
<em>Sol dur</em>. Toute surface n''imprimant pas la moindre empreinte (roche naturelle, plancher en pierre, etc.). La plupart des lits de cours d''eau entrent dans cette catégorie, car les traces laissées sont généralement effacées par le courant. La créature suivie ne peut laisser que quelques indices de son passage (cailloux déplacés, marques de griffures, etc.).</p>

<p>De nombreux modificateurs pouvant s''appliquer au test de Survie sont présentes ci-dessous :</p>

<p>[[tab:classe-rodeur-pistage-modificateurs]]</p>

<p><sup>1</sup> Si le groupe est composé de créatures de tailles diverses, on prend seulement en compte la taille la plus importante.<br />
<sup>2</sup> Ces facteurs ne s''additionnent pas ; seul le plus important est pris en compte.<br />
Si le personnage rate son test de Survie, il peut réessayer après 1 heure (en extérieur) ou 10 minutes (à l''intérieur), moment qu''il passe à essayer de retrouver la piste.</p>
'
WHERE cap_id = @k AND MD5(cap_description) = '43faa182459808454629e8c67fa60d96';

-- Olin Gisir : Secret (local cap_id 179) — 1 tableau(x)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id JOIN dd_classes cl ON cl.cla_id = cc.cc_cla_id WHERE cl.cla_nom = 'Olin Gisir' AND cl.cla_ruleset_var_id = @ddver AND TRIM(cs.cap_nom) = 'Secret' AND cs.cap_description LIKE '%<table%' LIMIT 1);
UPDATE dd_capacites_speciales SET cap_description = '<p>Le personnage a rassemblé un nombre considérable de savoirs anciens dans les différents grimoires trouvés, entendu les secrets chuchoté par les fiélons emprisonné dont le personnage a la garde, et d''autres sources plus terribles et plus dangereuses encore. Le personnage ajoutera son modification d''intelligence à&nbsp;son niveau de classe de prestige lui accordant cette capacité. Il pourra dès lors choisir n''importe quel secret pour lequel le résultat égale ou surpasse le nombre indiqué sur la table ci-dessous.</p>

<p>Le personnage pourra choisir un secret supplémentaire aux niveaux indiqués dans la tabl de progression.</p>

<p>[[tab:classe-olin-gisir-secrets]]</p>
'
WHERE cap_id = @k AND MD5(cap_description) = '6ef30cc69cad4270d187ccff9b979bc1';

-- Céleste : Particularités célestes (local cap_id 275) — 1 tableau(x)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_race_capacite rc ON rc.cr_cap_id = cs.cap_id JOIN dd_races ra ON ra.ra_id = rc.cr_ra_id WHERE ra.ra_nom = 'Céleste' AND ra.ra_ruleset_var_id = @ddver AND TRIM(cs.cap_nom) = 'Particularités célestes' AND cs.cap_description LIKE '%<table%' LIMIT 1);
UPDATE dd_capacites_speciales SET cap_description = '<p><b>Particularités. 
.</b> La créature céleste conserve toutes les particularités de la créature de base et gagne les suivantes.<p>
<ul>
<li>Vision dans le noir sur 18 mètres.</li>
<li>Réduction des dégâts (voir table ci-dessous)</li>
<li>Résistance à l’acide, au froid et à l’électricité (voir table ci-dessous)</li>
<li>Résistance à la magie égale à 5 + son nombre de DV (25 maximum)</li>
</ul>
<p>[[tab:race-celeste-particularites]]</p>
<p>Si la créature de base possède déjà l’une de ces particularités, appliquez la valeur qui l’avantage le plus.</p>
<p>Si la créature obtient une réduction des dégâts, ses armes naturelles sont considérées comme étant magiques pour ce qui est d’ignorer la réduction des dégâts.</p>'
WHERE cap_id = @k AND MD5(cap_description) = 'd0f5ac47e811ac96872b46d9177b4b3f';

-- Rôdeur bédouin : Pistage (local cap_id 1255) — 1 tableau(x)
SET @k := (SELECT cs.cap_id FROM dd_capacites_speciales cs JOIN dd_classe_capacite cc ON cc.cc_cap_id = cs.cap_id JOIN dd_classes cl ON cl.cla_id = cc.cc_cla_id WHERE cl.cla_nom = 'Rôdeur bédouin' AND cl.cla_ruleset_var_id = @ddver AND TRIM(cs.cap_nom) = 'Pistage' AND cs.cap_description LIKE '%<table%' LIMIT 1);
UPDATE dd_capacites_speciales SET cap_description = '<p>l faut r&eacute;ussir un test de Survie pour trouver des traces ou les suivre pendant 1,5 kilom&egrave;tre. Un nouveau test est n&eacute;cessaire lorsque la piste devient plus difficile &agrave; suivre, comme par exemple quand d''autres traces la coupent ou quand elle se scinde en deux.</p>
<p>Tant qu''il piste, le personnage avance &agrave; la moiti&eacute; de sa vitesse de d&eacute;placement. Il peut avancer de sa vitesse de d&eacute;placement avec un malus aux tests de comp&eacute;tence de -5, ou au double de sa vitesse de d&eacute;placement avec un malus de -20 aux tests de comp&eacute;tence. Le DD d&eacute;pend du sol et des conditions en vigueur, selon la table suivante :</p>
<p><code class="reg-tab-liste__tag" title="Cliquer pour copier">[[tab:pistage]]</code></p>
<p><em>Sol tr&egrave;s mou</em>. Toute surface montrant des empreintes profondes et particuli&egrave;rement lisibles (neige, boue, &eacute;paisse couche de poussi&egrave;re, etc.).<br><em>Sol mou</em>. Toute surface assez &eacute;lastique pour s''enfoncer sous le poids d''un individu, mais plus r&eacute;sistante que la pr&eacute;c&eacute;dente. Les traces y sont nombreuses mais peu profondes.<br><em>Sol ferme</em>. La plupart des sols en ext&eacute;rieur (pelouse, champ, bois, etc.) et les surfaces molles ou extr&ecirc;mement sales &agrave; l''int&eacute;rieur (&eacute;pais tapis, sol crasseux, etc.). La cr&eacute;ature suivie peut laisser quelques traces (brindilles cass&eacute;es, touffes de poils, etc.), mais les empreintes, elles, sont extr&ecirc;mement rares.<br><em>Sol dur</em>. Toute surface n''imprimant pas la moindre empreinte (roche naturelle, plancher en pierre, etc.). La plupart des lits de cours d''eau entrent dans cette cat&eacute;gorie, car les traces laiss&eacute;es sont g&eacute;n&eacute;ralement effac&eacute;es par le courant. La cr&eacute;ature suivie ne peut laisser que quelques indices de son passage (cailloux d&eacute;plac&eacute;s, marques de griffures, etc.).</p>
<p>De nombreux modificateurs pouvant s''appliquer au test de Survie sont pr&eacute;sentes ci-dessous :</p>
<p>[[tab:classe-rodeur-pistage-modificateurs]]</p>
<p><sup>1</sup> Si le groupe est compos&eacute; de cr&eacute;atures de tailles diverses, on prend seulement en compte la taille la plus importante.<br><sup>2</sup> Ces facteurs ne s''additionnent pas ; seul le plus important est pris en compte.<br>Si le personnage rate son test de Survie, il peut r&eacute;essayer apr&egrave;s 1 heure (en ext&eacute;rieur) ou 10 minutes (&agrave; l''int&eacute;rieur), moment qu''il passe &agrave; essayer de retrouver la piste.</p>'
WHERE cap_id = @k AND MD5(cap_description) = '46834d7fb3c942763755754fcc260875';

COMMIT;
