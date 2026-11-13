-- sql/2026-11-09_sp-jf3_classes_prestige_mdjf.sql
-- SP-JF3 — Classes de prestige du Manuel des Joueurs de Faerûn : classe, progression (dd_classe_niveau),
-- capacités (dd_capacites_speciales / dd_classe_capacite) et compétences de classe.
-- Généré par tools/generer-sp-jf3-classes.php le 2026-11-09 depuis gemmaline.com. Rejouable. Pas de DELIMITER.

SET NAMES utf8mb4;

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_visible, tab_date_creation, tab_date_modif)
SELECT 'classe-arcaniste-netherisse', 'Arcaniste nétherisse : tableau', '! Domaine | Racines
Esprit | Bannissement, coercition, contact, dissimulation, duperie, prédiction, révélation
Fluctuation | animation, animation des morts, dissipation, fortification, glyphe, réflexion, transformation, transport
Invention | affliction, armure, carnage, convocation, destruction, énergie, invocation', 'll', 1, 1, 63, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM dd_tableaux WHERE tab_slug = 'classe-arcaniste-netherisse' AND tab_ruleset_var_id = 1);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_visible, tab_date_creation, tab_date_modif)
SELECT 'classe-celebrante-de-sharess', 'Célébrante de Sharess : Sacrifice final', '! Niveau | 1er | 2e | 3e | 4e
1 | 2* | - | - | -
2 | 3 | - | - | -
3 | 3 | 2* | - | -
4 | 4 | 3 | - | -
S | 4 | 3 | 2* | -
6 | 4 | 4 | 3 | -
7 | 4 | 4 | 3 | 2*
8 | 4 | 4 | 4 | 3
9 | 4 | 4 | 4 | 3
10 | 4 | 4 | 4 | 4', 'lllll', 1, 1, 63, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM dd_tableaux WHERE tab_slug = 'classe-celebrante-de-sharess' AND tab_ruleset_var_id = 1);

INSERT INTO dd_tableaux (tab_slug, tab_nom, tab_contenu, tab_align, tab_tabc_id, tab_ruleset_var_id, tab_res_id, tab_visible, tab_date_creation, tab_date_modif)
SELECT 'classe-lanceur-de-runes', 'Lanceur de Runes : tableau', '! Nombre d''utilisations ou méthode de déclenchement | Prix de base | Niveau de lanceur de runes2
Une | Niveau de sort1 x niveau de lanceur de sorts x 50 po | —
Charges3 | Niveau de sort1 x niveau de lanceur de sorts x charges x 50 po | 3
Charges par jour3 | Niveau de sort1 x niveau de lanceur de sorts x charges x 400 po | 8
Permanente | (Niveau de sort1 x niveau de lanceur de sorts dissipé)4 x 1 000 po | 8
Contact | Coût de base | -
Lecture ou franchissement | Coût de base X 2 | 3', 'lll', 1, 1, 63, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM dd_tableaux WHERE tab_slug = 'classe-lanceur-de-runes' AND tab_ruleset_var_id = 1);

-- ===== Agent Ménestrel

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Agent Ménestrel', 'AM', 2, 6, 5, 6, '<p><strong>Alignement.</strong> Ne pas être mauvais</p>
<p><strong>Compétences.</strong> Degré de maîtrise de 4 en Connaissances (folklore local [une région au choix]), degré de maîtrise de 8 en Diplomatie, degré de maîtrise de 2 en Psychologie, degré de maîtrise de 1 en Survie</p>
<p><strong>Don.</strong> Négociation</p>
<p><strong>Spécial.</strong> Le candidat doit être parrainé par un membre des Ménestrels et gagner l’aval des Grands Ménestrels</p>', '<p>Les agents ménestrels sont formés au maniement des armes courantes et au port des armures légères.</p>', '<p>A chaque niveau d''agent ménestrel (à l''exception du niveau 1), le personnage obtient un niveau effectif .de jeteur de sorts pour une de ses classes de lanceur de sorts précédentes. Il obtient les sorts par jour et le niveau de lanceur de sorts d''un personnage de son niveau effectif. Par contre, il ne gagne aucun des autres avantages accompagnant habituellement ce niveau (dons de métamagie ou de création d''objets, meilleure chance de repousser les morts-vivants, etc.). Si l''agent ménestrel possède plusieurs classes de lanceur de sorts, le niveau effectif ne s''applique qu''à l''une d''entre elles, au choix du personnage.</p>', '<p>Compétences de classe : Acrobaties, Artisanat, Bluff, Connaissances (au choix), Déguisement, Déplacement silencieux, Diplomatie, Discrétion, Escalade, Escamotage, Estimation, Évasion, Langue, Natation, Perception auditive, Profession, Psychologie, Renseignement, Représentation, Saut, Survie.</p>', '<p>L''organisation plus ou moins secrète que constituent les Ménestrels dispose de membres dans tout Faerûn. Ces individus combattent le Mal, exhument des connaissances oubliées et maintiennent l''équilibre entre la civilisation et la nature. Les agents ménestrels travaillent sur le terrain, recueillent des renseignements et se chargent d''éliminer les menaces. Parfaitement à l''aise seuls ou en groupe, les agents ménestrels possèdent une grande diversité de talents.</p>
<p>Nombre d''agents ménestrels sont des bardes, mais ce n''est pas le cas de tous. Rôdeurs, roublards, ensorceleurs et magiciens sont</p>
<p>fréquents car ces classes proposent tout un éventail de talents et une grande souplesse. Certains prêtres, et plus particulièrement ceux de Deneir, Lliira et Tymora, ainsi que des druides et des moines, empruntent également cette voie. Barbares, guerriers-et paladins intègrent rarement cette classe car. leurs méthodes manquent quelque peu de subtilité.</p>
<p><strong>Anciens Agents Ménestrels.</strong></p>
<p>Un agent ménestrel violant le code de conduite de l''organisation, mettant en danger d''autres membres, délibérément ou par négligence, ou quittant les Ménestrels de son plein gré gagne rapidement une mauvaise réputation. Un tel individu ne peut plus progresser dans sa classe de prestige d''agent ménestrel. En outre, il ne peut plus profiter des pouvoirs suivants : cœur de Lliira, faveur de Mystra, œil de Déneïr, sourire de Tymora et voix de Lurue. Pour revenir dans le droit chemin et être à même de gagner de nouveaux niveaux dans sa classe de prestige, il faut adresser une demande aux Grands Ménestrels, que ces derniers décident d''une quête à confier au personnage et qu''il lui soit lancé un sort de pénitence par un prêtre d''un dieu choisi par les Grands Ménestrels.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Agent Ménestrel' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Agent Ménestrel' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 0, 0, 2, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '1', 0, 0, 3, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '2', 1, 1, 3, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '3', 1, 1, 4, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '3', 1, 1, 4, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Savoir des Ménestrels', '<p>Dès le niveau 1, l''agent ménestrel a accès à des renseignements sur le même principe que les bardes. Ce pouvoir fonctionne de la même façon que l''aptitude de savoir bardique, si ce n''est que le bonus au test est égal au niveau d''agent ménestrel + son modificateur d''Intelligence. Si le personnage possède déjà un pouvoir de savoir (comme des niveaux de barde ou de gardien du savoir), ses niveaux d''agent ménestrel s''ajoutent aux niveaux de la classe concernée pour ce qui est des tests.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Savoir des Ménestrels' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Cœur de Lliira', '<p>Au niveau 2, l''agent ménestrel bénéficie d''un bonus de sainteté de +2 aux jets de sauvegarde contre la coercition et la terreur.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Cœur de Lliira' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Œil de Déneïr', '<p>Toujours au niveau 2, l''agent ménestrel bénéficie d''un bonus de sainteté de +3 aux jets de sauvegarde contre les glyphes, les runes et les symboles.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Œil de Déneïr' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Sourire de Tymora', '<p>Dès le niveau 3, l''agent ménestrel bénéficie d''un bonus de chance de +2 à un jet de sauvegarde de son choix, 1 fois par jour. Il est possible d''ajouter ce bonus après avoir effectué le jet, une fois la réussite ou l''échec de la sauvegarde déterminé.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Sourire de Tymora' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Voix de Lurue', '<p>À partir du niveau 4, l''agent ménestrel peut user de communication avec les animaux (niveau de lanceur de sorts égal au niveau d''agent ménestrel), 3 fois par jour.</p>', 'mag', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Voix de Lurue' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Faveur de Mystra', '<p>Au niveau 5, l''agent ménestrel bénéficie d''un bonus de sainteté de +1 aux jets de sauvegarde contre les sorts.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Faveur de Mystra' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Savoir des Ménestrels' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Cœur de Lliira' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Œil de Déneïr' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Sourire de Tymora' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Voix de Lurue' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Faveur de Mystra' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 1, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 1 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 3, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 3 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'au choix'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'au choix');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 9, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 9 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 10, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 10 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 13, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 13 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 14, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 14 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 18, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 18 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 19, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 19 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 20, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 20 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 21, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 21 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 24, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 24 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 26, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 26 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 27, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 27 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 30, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 30 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 31, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 31 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 32, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 32 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 33, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 33 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 34, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 34 AND ccomp_precision = '');

-- ===== Arcaniste nétherisse

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Arcaniste nétherisse', 'AN', 2, 4, 5, 2, '<p><strong>Race.</strong> Humain (y compris mort-vivant) ou reflet</p>
<p><strong>Compétences.</strong> Degré de maîtrise de 25 en Art de la magie, degré de maîtrise de 25 en Connaissances (mystères)</p>
<p><strong>Don.</strong> Science de l’emplacement de sort</p>
<p><strong>Sorts.</strong> Faculté de lancer des sorts de magie profane de 13e niveau</p>
<p><strong>Spécial.</strong> Traditions de Nétheril : le candidat doit avoir accès aux anciennes traditions magiques de Nétheril. Une liche ou un reflet de l’empire de Pénombre remplit cette condition, mais (à la discrétion du MD) un personnage ayant exhumé de vieux secrets nétherisses conviendra tout aussi bien</p>', '<p>L''arcaniste nétherisse ne reçoit aucune formation supplémentaire au maniement des armes et des boucliers, ni au port des armures.</p>', NULL, '<p>Compétences de classe : Art de la magie, Concentration, Connaissances (toutes), Décryptage, Langue.</p>', '<p>Les archimages de l''ancienne Nétheril comptent assurément parmi les plus puissants lanceurs de sorts humains de toute l''histoire de Faerûn, même si les elfes précisent souvent que les Nétherisses apprirent tout ce qu''ils savaient auprès de leurs magiciens. Quand bien même, les lanceurs de sorts de Nétheril étaient connus pour leur incommensurable magie, parmi laquelle des sorts capables de priver les montagnes de leurs cimes et d''en faire autant de fiefs flottants dans les cieux. D''aucuns prétendent même que ces archimages disposaient d''un sort capable de faire d''un homme un dieu.</p>
<p>L''arcaniste nétherisse est un pionnier en matière de magie épique puisqu''il évente les secrets de sorts qui transcendent les limites habituelles. La plupart des membres de cette classe de prestige périrent lorsque leurs enclaves flottantes tombèrent des cieux et que leur puissant empire s''effondra dans le désert de l''Anauroch, mais l''un d''eux au moins a survécu à ce joujr, même s''il s''agit d''une liche. Cependant, il existe deux méthodes permettant aux mages modernes d''aborder les techniques de l''ancienne Nétheril. D''une part, ils peuvent se livrer à l''exploration des ruines nétherisses et y recueillir les secrets des arcanistes.</p>
<p>D''autres part, ils peuvent rendre visite à leurs descendants, les reflets. Parmi ces derniers, les arcanistes retrouvent une place de premier plan au sein de la société, pour le plus grand malheur de leurs voisins.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Arcaniste nétherisse' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Arcaniste nétherisse' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 0, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '0', 0, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '0', 0, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '0', 0, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '0', 0, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Magie épique', '<p>Au niveau 1, l''arcaniste nétherisse acquiert Magie épique en qualité de don supplémentaire s''il ne le possède pas déjà.</p>', NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Magie épique' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Spécialité', '<p>Tout arcaniste nétherisse choisit l''un des trois «domaines » de magie (invention, esprit ou fluctuation) qui devient sa spécialité. Il en choisit un second qui devient son champ mineur. Par contre, il est incapable de lancer les sorts accompagnés de racines issues du troisième.</p>
<p>Voici à quel domaine correspond chaque racine.</p>
<p>[[tab:classe-arcaniste-netherisse]]</p>
<p>Le DD de base du test d''Art de la magie visant à développer des sorts est réduit de 5 pour ce qui est de sa spécialité, comme dans le cas de la racine d''une école de prédilection. Si le sort se situe déjà dans l''école de prédilection de l''arcaniste, le pouvoir n''a aucun effet.</p>', NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Spécialité' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'École renforcée (épique)', '<p>Au niveau 2, le DD de sauvegarde des sorts épiques de l''arcaniste nétherisse augmente de +1, mais le DD d''Art de la magie reste inchangé.</p>', NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'École renforcée (épique)' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Résistance au contrecoup', '<p>Au niveau 3, l''arcaniste nétherisse acquiert une résistance au contrecoup '' (5) des sorts épiques qu''il lance. Chaque fois qu''il jette un sort épique affublé d''un contrecoup, les dégâts subis sont réduits de 5 points. Si les dégâts de contrecoup sont infligés sur plus de 1 round, la réduction est de 5 points par round.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Résistance au contrecoup' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Artisanat magique épique', '<p>Au niveau 4, l''arcaniste nétherisse gagne le pouvoir de développer des sorts épiques en leur consacrant moins de temps et de ressources. Lorsqu''il s''agit de fixer le coût en matières premières, il multiplie le DD du test d''Art de la magie par 7 000 po et non par 9 000 po. Le temps de développement et le coût en PX sont réduits en conséquence.</p>', NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Artisanat magique épique' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'École supérieure (épique)', '<p>Au niveau 5, le DD de sauvegarde des sorts épiques de l''arcaniste nétherisse augmente de +1, mais le DD d''Art de la magie reste inchangé. Cette augmentation se cumule avec celle du pouvoir d''École renforcée (épique), pour un accroissement net de +2.</p>', NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'École supérieure (épique)' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Magie épique' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Spécialité' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, 'épique', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'École renforcée (épique)' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, '5', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Résistance au contrecoup' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Artisanat magique épique' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, 'épique', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'École supérieure (épique)' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 2, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 2 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 4, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 4 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'toutes'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'toutes');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 8, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 8 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 24, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 24 AND ccomp_precision = '');

-- ===== Célébrante de Sharess

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Célébrante de Sharess', 'CS', 2, 6, 10, 6, '<p><strong>Alignement.</strong> Chaotique bon</p>
<p><strong>Compétences.</strong> Degré de maîtrise de 7 en Diplomatie, degré de maîtrise de 7 en Représentation (au choix)</p>
<p><strong>Dons.</strong> Vœu pieux, Vœu de pureté</p>', '<p>La célébrante de Sharess ne gagne aucune formation au maniement des armes et des boucliers, ni au port des armures.</p>', '<p>Dès le niveau 1, la célébrante de Sharess gagne le pouvoir de lancer un petit nombre de sorts de magie profane.</p>
<p>Pour lancer un sort, elle doit disposer d''une valeur de Charisme au moins égale à 10 + niveau du sort. Ainsi, une célébrante de Sharess dotée d''une valeur de Charisme inférieure à 10 est incapable de lancer ces sorts. Les sorts en bonus du personnage dépendent eux aussi de son Charisme. Le DD des jets de sauvegarde visant à résister à ces sorts est égal à 10 + niveau de sort + bonus de Charisme de la célébrante (le cas échéant). Lorsque la Table ci-dessous indique 0 sort d''un niveau donné, comme 0 sort de 1" niveau au niveau 1 la célébrante ne bénéficie que des sorts en bonus découlant de sa valeur de Charisme. La liste de sorts de cette classe figure plus bas. La célébrante de Sharess lance des sorts comme un barde.</p>
<p>Au niveau 6, puis tous les niveaux pairs par la suite (8 et 10), la célébrante de Sharess peut remplacer un sort qu''elle connaît déjà par un autre. Le niveau de ce nouveau sort doit être le même que celui de l''ancien et être au minimum de deux niveaux de moins que le plus haut niveau de sort auquel elle a accès. Par exemple, au niveau 6, une célébrante de Sharess peut changer un sort de 1" niveau contre un autre (puisqu''elle a accès aux sorts de 3e niveau). Aux niveaux 8 et 10, elle peut échanger un sort de 1er ou de 2e niveau contre un autre sort de même niveau (puisqu''elle peut désormais jeter des sorts de 4e niveau). À chaque occasion, la célébrante de Sharess ne peut réaliser qu''un seul échange. Elle peut alors procéder à l''opération au moment où elle gagne de nouveaux sorts connus pour le niveau en question, mais rien ne l''y oblige.</p>
<p>[[tab:classe-celebrante-de-sharess]]</p>
<p>* Encore faut-il que la célébrante de Sharess ait une valeur de Charisme suffisamment élevée pour avoir un sort en bonus à ce niveau.</p>', '<p>Compétences de classe : Acrobaties, Art de la magie, Artisanat, Bluff, Concentration, Déguisement, Diplomatie, Escamotage, Perception auditive, Profession, Psychologie, Renseignement, Représentation, Saut.</p>', '<p>Sharess est une divinité paradoxale. A l''origine, il s''agissait de la déesse de la guerre du panthéon mulhorandi, d''une championne dans le conflit mené contre Seth et les forces du Mal. Aujourd''hui, c''est une déesse de la passion et du sexe, si bien qu''on la surnomme plus volontiers Dame Débauche que l''Ennemie de Seth. La plupart de ses prêtres ont oublié sa gloire d''antan, gérant des maisons de joie et célébrant les Éternelles Réjouissances de la Vie, une fête quasi incessante donnée en l''honneur de la déesse.</p>
<p>Cependant, les célébrantes de Sharess sont différentes. Elles ne négligent pas l''aspect actuel de la déesse du plaisir et de la luxure, mais elles n''ont pour autant pas oublié la vielle Ennemie de Seth, qui était aussi le lieutenant d''Anhur. Les célébrantes de Sharess sont des séductrices et des guerrières, des hédonistes et de pieuses championnes du Bien. Bien que de nombreux disciples de la déesse soient chaotiques neutres et que certains tendent vers le Mal, les célébrantes rappellent constamment que ce Mal est l''ennemi et que le plaisir doit être partagé avec chacun au nom du Bien. Si les célébrantes de Sharess ne sont pas des prêtresses, elles incarnent souvent mieux la nature de leur divinité que nombre des représentants du clergé de celle-ci.</p>
<p>La plupart des célébrantes sont d''anciens bardes. Les prêtresses qui se tournent vers cette classe de prestige renoncent à leur progression en terme de magie divine, ce qui n''en fait pas une voie très séduisante. Parfois, des barbares/bardes sont attirées par les célébrantes. Enfin, les roublards sont également nombreux parmi elles.</p>
<p>Les PNJ célébrantes sont rares et ne sont pas les bienvenus au sein de l''Église décadente de Sharess, En effet, les célébrantes ont lancé un vaste mouvement réformateur et interpellent les leaders du clergé pour qu''ils changent l''interprétation du dogme de Sharess et rappellent l''aspect bon de son alignement, sans pour autant oublier son insouciance chaotique.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Célébrante de Sharess' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Célébrante de Sharess' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif, cn_sort_n1)
SELECT @cla, 1, '0', 0, 0, 2, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif, cn_sort_n1)
SELECT @cla, 2, '1', 0, 0, 3, 0, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif, cn_sort_n1, cn_sort_n2)
SELECT @cla, 3, '1', 1, 1, 3, 0, 0, 0, 2, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif, cn_sort_n1, cn_sort_n2)
SELECT @cla, 4, '2', 1, 1, 4, 0, 0, 0, 3, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif, cn_sort_n1, cn_sort_n2, cn_sort_n3)
SELECT @cla, 5, '2', 1, 1, 4, 0, 0, 0, 3, 2, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif, cn_sort_n1, cn_sort_n2, cn_sort_n3)
SELECT @cla, 6, '3', 2, 2, 5, 0, 0, 0, 3, 3, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 6);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4)
SELECT @cla, 7, '3', 2, 2, 5, 0, 0, 0, 3, 3, 2, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 7);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4)
SELECT @cla, 8, '4', 2, 2, 6, 0, 0, 0, 3, 3, 3, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 8);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4)
SELECT @cla, 9, '4', 3, 3, 6, 0, 0, 0, 3, 3, 3, 2
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 9);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif, cn_sort_n1, cn_sort_n2, cn_sort_n3, cn_sort_n4)
SELECT @cla, 10, '5', 3, 3, 7, 0, 0, 0, 3, 3, 3, 3
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 10);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Familier félin', '<p>Une célébrante de Sharess peut attirer un chat en guise de familier. Le processus demande 24 heures mais ne coûte rien (contrairement au pouvoir de familier des ensorceleurs et des mages). Au fil de la progression du personnage, le familier gagne également en puissance. Ce chat se conforme aux règles traitant des familiers des ensorceleurs et des magiciens, si ce n''est que le niveau de classe effectif visant à fixer les pouvoirs de l''animal est égal à deux fois le niveau de célébrante de Sharess du personnage. Par exemple, le familier d''une célébrante de Sharess de niveau 3 peut parler avec son maître, comme si le personnage était un ensorceleur ou un magicien de niveau 6.</p>
<p>Une célébrante ne peut avoir qu''un seul familier et ses niveaux de classe de prestige ne s''ajoutent pas à ceux de quelque autre classe pour ce qui est de fixer les pouvoirs de l''animal. Si le personnage dispose de niveaux dans une telle classe, utilisez celui-ci ou deux fois son niveau de célébrante de Sharess, au choix.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Familier félin' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Fascination', '<p>La célébrante de Sharess peut user de son pouvoir de flirt (cf. ci-dessous) pour fasciner une ou plusieurs créatures. Chaque cible doit se situer dans un rayon de 27 mètres de la célébrante et être à même de la voir, de l''entendre et de lui prêter attention. En cas de distraction (combat proche ou danger imminent), le pouvoir ne fonctionne pas. Au-delà du niveau 1, la célébrante peut viser une créature de plus tous les trois niveaux (deux au niveau 4, trois au niveau 7 et quatre au niveau 10).</p>
<p>Pour utiliser ce pouvoir, la célébrante doit effectuer un test de Représentation. Le résultat est le DD du jet de Volonté de chaque cible. Si une créature réussit son jet de sauvegarde, elle ne peut plus être fascinée par la célébrante pendant 24 heures. Dans le cas contraire, le sujet s''assoit tranquillement et fixe la célébrante du regard, sans entreprendre la moindre action tant qu''elle reste concentrée et poursuit sa représentation (jusqu''à 1 round par niveau de célébrante de Sharess). Un sujet fasciné subit un malus de -4 aux tests de compétence visant à réagir (comme Détection et Perception auditive). Toute menace potentielle (comme un allié de la célébrante s''approchant de la créature fascinée) exige du personnage qu''il effectue un nouveau test de Représentation et permet au sujet d''effectuer un second jet de sauvegarde contre un DD égal au résultat du dernier test de Représentation. Enfin, une menace potentielle (comme un individu sortant une arme, jetant un sort ou visant le sujet à l''aide d''une arme à distance) annule automatiquement l''effet. Il s''agit d''un enchantement (coercition) [mental],</p>', 'mag', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Fascination' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Flirt', '<p>Une fois par jour et par niveau de célébrante de Sharess, le personnage peut associer la compétence Représentation à ses talents de flirt et de séduction pour produire des effets magiques similaires à ceux de la musique bardique.</p>
<p>On déclenche un effet de flirt au prix d''une action simple.. Certains effets ont besoin de concentration, ce qui signifie que la célébrante doit entreprendre une action simple par round pour les maintenir. Quand elle utilise un pouvoir de flirt qui ne nécessite aucune concentration, la célébrante ne peut néanmoins pas lancer de sorts ni activer d''objets magiques à fin d''incantation (comme des parchemins) ou à mot de commande (comme des baguettes).</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Flirt' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Fureur de la tigresse', '<p>A partir du niveau 2, la célébrante de Sharess peut entrer dans un état de rage, gagnant alors une force et une résistance phénoménales tout en faisant montre d''intrépidité et d''insouciance. Le personnage bénéficie d''un bonus de +4 en Force et en Constitution, ainsi que d''un bonus de moral de +2 aux jets de Volonté. Par contre, il subit un malus de -2 à la CA. Ce pouvoir fonctionne sur le même principe que la rage du barbare. Il est utilisable 1 fois par jour au niveau 2, 2 fois par jour au niveau 6 et 3 fois par jour au niveau 10.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Fureur de la tigresse' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Suggestion', '<p>Une célébrante de Sharess de niveau 4 ou plus peut faire une suggestion (comme le sort) à une créature qu''elle a préalablement fascinée (voir plus haut). L''utilisation de ce pouvoir ne rompt pas la concentration du personnage et ne compte pas dans sa limite quotidienne d''effets de flirt. Un jet de Volonté (DD 10 + niveau de célébrante de Sharess + modificateur de Charisme) annule l''effet. Ce pouvoir n''affecte qu''un sujet. Il s''agit d''un enchantement (coercition) [langage, mental].</p>', 'mag', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Suggestion' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Bond de la tigresse', '<p>A partir du niveau 5, la célébrante de Sharess peut effectuer une attaque à outrance au terme d''une charge.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Bond de la tigresse' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Sanctuaire', '<p>Une célébrante de Sharess de niveau 7 ou plus peut empêcher des créatures de l''attaquer, elle ou ses alliés, sur le même principe qu''un sort de sanctuaire. Pour utiliser ce pouvoir, le personnage effectue un test de Représentation. Le résultat détermine le DD du jet de Volonté des créatures affectées. Un adversaire qui tente de frapper ou d''attaquer directement la célébrante ou ses alliés, même à l''aide d''un sort à ciblés, doit jouer un jet de Volonté. En cas de succès, l''assaillant attaque normalement et n''est pas affecté par cette utilisation du pouvoir de flirt. En cas d''échec, l''assaillant doit renoncer à son attaque, cette partie de son action est perdue, et il est incapable de s''en prendre directement à la célébrante ou à ses alliés pendant la durée de l''effet. Les créatures qui ne tentent pas d''attaque ne sont pas affectées. Cet effet n''empêche pas les adversaires de recourir à des sorts de zone susceptibles de nuire à la célébrante et à ses alliés. Si le personnage attaque une créature, ou que ses alliés en font de même, l''effet de sanctuaire disparait.</p>', 'mag', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Sanctuaire' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Célérité du tigre', '<p>À partir du niveau 8, la célébrante de Sharess peut agir comme si elle jouissait d''un sort de rapidité. Cet avantage dure un nombre de rounds par jour égal au niveau de célébrante de Sharess. La durée peut être décomposée en fractions de 1 round minimum. On met un terme à l''effet au prix d''une action libre.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Célérité du tigre' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Inspiration du désir', '<p>Au niveau 10, la célébrante de Sharess peut user de son pouvoir de flirt pour inspirer amour ou désir à une créature préalablement fascinée. L''utilisation de ce pouvoir ne rompt pas la concentration du personnage mais compte dans sa limite quotidienne d''effets de flirt. Un jet de Volonté (DD 10 + niveau de célébrante de Sharess + modificateur de Charisme) annule l''effet Ce pouvoir n''affecte qu''un sujet.</p>
<p><em>Amour</em>. La cible tombe amoureuse d''une créature précise qui doit se situer à portée de vue au moment où l''effet est déclenché. Sinon, il s''agit de la première créature aperçue. Le sujet fait tout son possible pour être aux côtés de l''objet de son affection et s''efforce de gagner l''amour de la créature.</p>
<p><em>Désir</em>. Cet effet est semblable au précédent, mais le sujet cherche à avoir des relations sexuelles avec la cible, sans pour autant lui faire de mal.</p>
<p>Ce pouvoir est un enchantement (coercition) [mental].</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Inspiration du désir' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Familier félin' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Fascination' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Flirt' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, '1 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Fureur de la tigresse' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Suggestion' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Bond de la tigresse' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 6, '2 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Fureur de la tigresse' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 6);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Sanctuaire' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 8, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Célérité du tigre' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 8);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, '3 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Fureur de la tigresse' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Inspiration du désir' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 1, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 1 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 2, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 2 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 3, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 3 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 4, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 4 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 9, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 9 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 13, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 13 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 19, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 19 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 27, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 27 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 30, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 30 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 31, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 31 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 32, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 32 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 33, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 33 AND ccomp_precision = '');

-- ===== Champion Divin

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Champion Divin', 'CD', 2, 10, 5, 2, '<p>Bonus de base à l’attaque. +7</p>
<p><strong>Compétence.</strong> Degré de maîtrise, de 3 en Connaissances (religion)</p>
<p><strong>Don.</strong> Arme de prédilection (il doit s’agir de l’arme de prédilection du dieu)</p>
<p><strong>Divinité tutélaire.</strong> Le champion divin doit avoir une divinité tutélaire, et il doit s’agir du dieu dont il est l’un des champions</p>', '<p>Le champion divin est formé au maniement des armes courantes et des armes de guerre, mais il ne reçoit aucune formation au maniement des boucliers et au port des armures.</p>', NULL, '<p>Compétences de classe : Artisanat, Connaissances (religion), Dressage, Équitation, Escalade, Intimidation, Natation, Saut.</p>', '<p>Le champion divin est le bras armé de sa divinité tutélaire. Il veille sur les sites sacrés, protège les pèlerins et prend la tête des croisades. Bien que les paladins remplissent tous ces rôles au sein de nombreuses Eglises du Bien, un champion divin peut brandir la bannière de n''importe quel dieu, quel que soit son alignement et son éthique. Les rivalités entre champions divins de fois opposées alimentent les légendes que content les bardes depuis des siècles. Ces guerriers saints sont aimés des adorateurs de leur divinité tutélaire et haïs avec autant de ferveur par les ennemis de leur Église. La plupart des champions divins ont des antécédents martiaux ou militaires. Barbares, guerriers, paladins et rôdeurs constituent le plus gros de leurs rangs. Toutefois, certains moines et prêtres, ainsi que des druides particulièrement militants, décident d''emprunter cette voie. Nombre de champions divins de dieux maléfiques viennent des rangs des chevaliers noirs. Bardes, roublards, ensorceleurs et magiciens entrent rarement dans le cercle des champions divins, sauf quand ils sont particulièrement pieux et doués dans l''art de la guerre. Enfin, des champions divins de tout alignement ont également des niveaux de classe de prestige propre à leur Eglise.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Champion Divin' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Champion Divin' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '1', 0, 2, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '2', 0, 3, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '3', 1, 3, 1, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '4', 1, 4, 1, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '5', 1, 4, 1, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Imposition des mains', '<p>Dès le niveau 1, le champion divin peut soigner les blessures (les siennes ou celles d''une créature ayant la même divinité tutélaire que lui). Ce pouvoir fonctionne comme celui du paladin.</p>
<p>Si le champion divin possède déjà ce pouvoir (par exemple, via quelques niveaux de paladin), les utilisations quotidiennes issues de cette source ne sont pas limitées aux adorateurs de son dieu tutélaire. La limite ne s''applique donc qu''aux utilisations quotidiennes du pouvoir découlant des niveaux de champion divin.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Imposition des mains' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Défense sacrée', '<p>Dès le niveau 2, le champion divin bénéficie d''un bonus de +1 aux jets de sauvegarde contre lés sorts de magie divine, mais également contre les pouvoirs magiques et pouvoirs surnaturels des Extérieurs. Au niveau 4, ce bonus passe à +2.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Défense sacrée' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Don supplémentaire', '<p>Aux niveaux 2 et 4, le champion divin peut choisir un. don supplémentaire parmi la liste qui suit : Arme de prédilection, Arme en main, Attaques réflexes, Combat en aveugle. Expertise du combat, Maniement d''une arme exotique, Science du critique, Science de l''initiative et Science du renvoi. A chaque fois, il lui faut néanmoins satisfaire aux conditions du don requis.</p>', NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Don supplémentaire' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Châtiment de l''infidèle', '<p>Un champion divin de niveau 3 ou plus peut, 1 fois par jour, tenter de châtier une créature ayant une divinité tutélaire différente de la sienne en lui portant une attaque au corps à corps normale. Les créatures dotées d''une Intelligence de .2 ou moins n ont pas de divinité tutélaire et ne sont pas affectées par ce pouvoir. Par contre, les créatures dotées d''une Intelligence de 3 ou plus qui n''ont pas de divinité tutélaire le sont. Le personnage ajoute son bonus de Charisme (le cas échéant) au jet d''attaque et inflige 1 point de dégâts supplémentaire par niveau de champion divin. Par exemple, un champion divin de niveau 4 armé d''une épée longue infligera 1d8+4 points de dégâts, plus tout bonus de Force ou d''effet magique applicable.</p>
<p>Si le champion divin châtie accidentellement une créature dotée de la même divinité tutélaire que lui, le pouvoir n''a aucun effet, mais il est tout de même dépensé pour la journée. Si le champion divin possède déjà un pouvoir de châtiment (par exemple, via des niveaux de prêtre ou de paladin), il peut utiliser son pouvoir une fois de plus chaque jour (renonçant alors à l''utilisation découlant de l''autre source).</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Châtiment de l''infidèle' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Courroux divin', '<p>Un champion divin de niveau 5 peut, 1 fois par jour, canaliser une partie de la puissance de sa divinité tutélaire pour bonifier ses prouesses martiales. Cela lui confère une réduction des dégâts (5/-) et un bonus de +3 aux attaque, jets de dégâts et jets de sauvegarde durant un nombre de rounds égal à son modificateur de Charisme (1 round minimum). Il s''agit de bonus de sainteté si le dieu tutélaire du personnage est d''alignement bon, et de bonus de malfaisance s''il est d''alignement mauvais. Si la divinité est neutre, l''alignement du champion divin détermine la nature du bonus. Enfin, si la divinité et le personnage sont neutres, le champion divin choisit la nature du bonus dès l''acquisition du pouvoir.</p>
<p>Dons liés aux aptitudes</p>
<p><strong>Imposition des mains</strong> : Chevalier guérisseur, Imposition héroïque, Main salvatrice, Mains de guérisseur, Toucher d’azur</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Courroux divin' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Imposition des mains' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, '+1', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Défense sacrée' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Don supplémentaire' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Châtiment de l''infidèle' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, '+2', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Défense sacrée' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Don supplémentaire' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Courroux divin' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'religion'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'religion');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 15, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 15 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 17, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 17 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 18, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 18 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 23, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 23 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 26, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 26 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 33, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 33 AND ccomp_precision = '');

-- ===== Champion Martyr d'Ilmater

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Champion Martyr d''Ilmater', 'CMI', 2, 10, 10, 2, '<p><strong>Alignement.</strong> Loyal bon</p>
<p><strong>Compétences.</strong> Degré de maîtrise de 4 en Connaissances (religion), degré de maîtrise de 9 dans une compétence au choix</p>
<p><strong>Dons.</strong> Auréole de lumière, Endurance</p>
<p><strong>Divinité tutélaire.</strong> Ilmater</p>
<p><strong>Spécial.</strong> Le personnage doit avoir sacrifié sa vie avec héroïsme (puis avoir été rappelé à la vie)</p>', '<p>Le champion martyr d''Ilmater ne gagne aucune formation au maniement des armes et des boucliers, ni au port des armures.</p>', '<p>À chaque niveau pair de champion martyr d''Ilmater, le personnage obtient un niveau effectif de jeteur de sorts pour une de ses classes de lanceur de sorts précédentes ou un don supplémentaire, au choix. S''il choisit le don, il lui faut remplir les conditions d''obtention de celui-ci. S''il opte pour le niveau de lanceur de sorts, il obtient les sorts par jour et le niveau de lanceur de sorts d''un personnage de son niveau effectif. Par contre, il ne gagne aucun des autres avantages accompagnant habituellement ce niveau (dons de métamagie ou de création d''objets, meilleures chances de repousser les morts-vivants, etc.). Si le champion martyr d''Ilmater possède plusieurs classés de lanceur de sorts, le niveau effectif ne s''applique qu''à l''une d''entre elles, au choix du personnage.</p>
<p>Le champion martyr d''Ilmater est libre de choisir le don supplémentaire ou le niveau de lanceur de softs effectif à chaque niveau pair. S''il est dépourvu de facultés de lanceur de sorts, il doit obligatoirement se tourner vers un don supplémentaire.</p>', '<p>Compétences de classe : Art de la magie, Artisanat, Concentration, Connaissances (religion), Équitation, Escalade, Premiers secours, Profession.</p>', '<p>L''Église d''Ilmater est connue pour le grand nombre de martyrs qu''elle génère et pour l''incommensurable respect qu''elle leur voue. Il s''agit de la seule Église pourvue d''un saint martyrisé à deux reprises et beaucoup de disciples cherchent d''ailleurs à suivre l''exemple de saint Sollars. De son côté, le champion martyr se situe entre les deux. Il a déjà sacrifié sa vie de manière héroïque, reste un fidèle d''Ilmater et est prêt à connaître une nouvelle fois le martyre si les circonstances l''exigent.</p>
<p>Les champions martyrs d''Ilmater sont issus de toutes les classes car la voie du martyre est universelle. Cette classe de prestige offre généralement des avantages qui permettent aux intéressés de poursuivre leur évolution dans leur carrière précédente.</p>
<p>Les champions martyrs se tiennent à l''écart de la hiérarchie de l''Église d''Ilmater car ils font l''objet d''un véritable culte. Ce sont des agents libres de toute entrave, entièrement dévoués à la cause de leur dieu, de puissants champions qui luttent contre le Mal et les souffrances qu''il sème dans son sillage.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Champion Martyr d''Ilmater' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Champion Martyr d''Ilmater' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 2, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '1', 3, 0, 0, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '2', 3, 1, 1, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '3', 4, 1, 1, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '3', 4, 1, 1, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 6, '4', 5, 2, 2, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 6);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 7, '5', 5, 2, 2, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 7);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 8, '6', 6, 2, 2, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 8);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 9, '6', 6, 3, 3, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 9);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 10, '7', 7, 3, 3, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 10);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Combat à mains nues', '<p>Le champion ''martyr d''Ilmater combat sur le modèle de son dieu, à savoir à mains nues. Au niveau 1, il gagne Science du combat à mains nues en qualité de don supplémentaire s''il ne le possède pas déjà, A l''instar du moine, il peut attaquer avec l''un ou l''autre de ses poings, avec les coudes, les genoux ou les pieds. Ce pouvoir lui permet également d''user de combat à mains nues s''il a les mains prises. En outre, ses attaques à mains nues ne sauraient être traitées comme des attaques secondaires.</p>
<p>Habituellement, le champion martyr d''Ilmater inflige des dégâts létaux à mains nues, mais il peut se contenter de provoquer des dégâts non-létaux sans subir de malus. Ce même choix s''offre à lui en situation de lutte.</p>
<p>Les attaques à mains nues du personnage sont traitées comme des armes manufacturées et des armes naturelles dans le cadre des sorts et effets qui bonifient les premières ou les secondes (comme c''est le cas de arme magique ou de morsure magique).</p>
<p>Au niveau 1 le champion martyr d''Ilmater inflige 1d6 points de dégâts à mains nues s''il est de taille M, 1d4 s''il est de taille P et 1d8 s''il est de taille G. Au niveau 4, ces dégâts passent à 1d8 s''il est de taille M, 1d6 s''il est de taille P et 1d10 s''il est de taille G. Enfin, au niveau 8, ils passent à 1d10 s''il est de taille M, 1d8 s''il est de taille P et 2d8 s''il est de taille G.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Combat à mains nues' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Dur à cuire', '<p>Au niveau 1, le champion martyr d''Ilmater gagne Dur à cuire en qualité de don supplémentaire s''il ne le possède pas déjà.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Dur à cuire' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Immunité contre la terreur', '<p>A partir du niveau 2, le champion martyr d''Ilmater est immunisé contre la terreur (magique ou ordinaire).</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Immunité contre la terreur' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Endurance suprême', '<p>A partir du niveau 3, le champion martyr d''Ilmater bénéficie d''un bonus de sainteté de +4 aux tests et jets de sauvegarde profitant du don Endurance. S''agissant d''un bonus de sainteté, il s''ajoute à l''avantage que procure Endurance.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Endurance suprême' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Grâce divine', '<p>A partir du niveau 4, le champion martyr d''Ilmater bénéficie d''un bonus aux jets de sauvegarde égal à son bonus de Charisme (Je cas échéant).</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Grâce divine' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Souffrance sainte', '<p>A partir du niveau 5, si le champion martyr d''Ilmater survit après avoir subi un minimum de 50 points de dégâts au cours d''un même round, une lueur éclatante l''enveloppe, manifestant ainsi la grâce d''Ilmater. Le personnage bénéficie d''un bonus de sainteté aux jets d''attaque, jets de sauvegarde et tests de compétence. Celui-ci est égal à +1 tous les 10 points de dégâts subis lors du round précédent. L''effet dure un nombre de. rounds égal au niveau de champion martyr d''Ilmater du personnage. Bien que cet effet soit similaire au sort masochisme, il ne s''agit évidemment pas d''un pouvoir maléfique.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Souffrance sainte' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Réduction des dégâts', '<p>Au niveau 7, le champion martyr d''Ilmater gagne une réduction des dégâts (10/Mal). Au niveau 10, il s''agit d''une réduction des dégâts (15/Mal).</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Réduction des dégâts' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Autosubsistance', '<p>A partir du niveau 9, le champion martyr d''Ilmater''n''a plus besoin de manger,, de boire ou de respirer. S''il ne mange pas, son estomac le tiraille, et s''il ne peut respirer, ses poumons le brûlent. Toutefois, ces sensations n''impliquent pas un réel besoin. La faim, la soif, la suffocation et la noyade ne lui infligent pas de dégâts non-létaux et autres effets secondaires.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Autosubsistance' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Communion', '<p>À compter du niveau 9, le champion martyr d''Ilmater est si proche de son dieu qu''il peut lui poser une question par jour, comme s''il laçait un sort de communion. L''utilisation de ce pouvoir coûte 10 PX.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Communion' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Combat à mains nues' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Immunité contre la terreur' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, '1d8', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Endurance suprême' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Grâce divine' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Souffrance sainte' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, '10/Mal', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Réduction des dégâts' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 8, '1d10', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Combat à mains nues' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 8);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 9, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Autosubsistance' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 9);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 9, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Communion' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 9);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, '15/Mal', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Réduction des dégâts' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Dur à cuire' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 2, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 2 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 4, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 4 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'religion'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'religion');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 17, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 17 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 18, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 18 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 28, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 28 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');

-- ===== Chasseur du Sang Noir

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Chasseur du Sang Noir', 'CSN', 2, 8, 10, 4, '<p><strong>Race.</strong> Lycanthrope</p>
<p><strong>Compétences.</strong> Degré de maîtrise de 4 en Connaissances (nature), degré de maîtrise de 8 en Contrôle de forme (lycanthropes infectés uniquement), degré de maîtrise de 6 en Saut, degré de maîtrise de 6 en Survie</p>
<p><strong>Dons.</strong> Attaque en puissance, Attaque naturelle maléfique</p>
<p><strong>Divinité tutélaire.</strong> Malar</p>', '<p>Le. chasseur du sang noir ne gagne aucune formation au maniement des armes et des boucliers, ni au port des armures.</p>', NULL, '<p>Compétences de classe : Connaissances (nature), Déplacement silencieux, Détection, Discrétion, Escalade, Intimidation, Natation, Perception auditive, Saut, Survie.</p>', '<p>Les adeptes du Sang noir sont des lycanthropes unis par leur vénération de Malar, le Seigneur Bestial. Le credo principal de l''Église de Malar, là survie des plus forts par l''éradication des plus faibles, est maléfique au plus haut point, mais le dieu confère une puissance exceptionnelle à ceux qui agrémentent le Mal dans toute sa bestialité d''actes de torture, de viols et autres agissements malfaisants.</p>
<p>Les chasseurs du sang noir viennent de toutes les classes. Lycanthropes affectés et naturels satisfont à la condition raciale de cette classe de prestige. Rôdeurs, druides et barbares constituent le gros des chasseurs, mais simplement parce qu''ils sont nombreux parmi les adeptes du Sang noir. Les prêtres de Malar empruntent souvent cette voie parce qu''ils aiment lancer des. sorts sous forme animale.</p>
<p>Les chasseurs du-sang noir n''ont aucune structure. Certains groupes d''adeptes du Sang noir en abritent, d''autres non. Certains chasseurs prennent la tête de leur meute alors que d''autres se contentent de participer aux traques.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Chasseur du Sang Noir' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Chasseur du Sang Noir' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 2, 2, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '1', 3, 3, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '2', 3, 3, 1, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '3', 4, 4, 1, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '3', 4, 4, 1, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 6, '4', 5, 5, 2, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 6);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 7, '5', 5, 5, 2, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 7);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 8, '6', 6, 6, 2, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 8);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 9, '6', 6, 6, 3, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 9);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 10, '7', 7, 7, 3, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 10);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Incantation lycanthropique', '<p>Un chasseur du sang noir pourvu de facultés magiques peut lancer des sorts sous forme hybride ou animale, comme s''il s''agissait d''un druide sous forme animale usant du don Incantation animale.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Incantation lycanthropique' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Objets de forme animale', '<p>Lorsqu''il use de forme animale, le chasseur du sang noir peut porter une armure pourvue de la propriété spéciale de forme animale, un fermai! de constance ou tout autre objet Utilisable par un druide soûs forme animale. Dans le cadre de l''utilisation de tels objets, toutes les formes lycanthropiques du chasseur du sang noir constituent des formes animales.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Objets de forme animale' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Transmission de lycanthropie suprême', '<p>Si le personnage touche un adversaire à l''aide de son attaque morsure, le DD du jet de Vigueur visant à éviter de contracter la lycanthropie augmente d''un nombre de points égal à son niveau de chasseur du sang noir.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Transmission de lycanthropie suprême' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Aspect animal', '<p>À partir du niveau 2, le. chasseur du sang noir peut gagner certaines caractéristiques de sa forme animale tout en conservant sa forme humanoïde. Une fois par jour, il a donc le droit de bénéficier de la Force, de la Dextérité ou de la Constitution de sa forme animale sans adopter celle-ci. De plus, son bonus d''armure naturelle augmente de +2. Toits ces changements durent pendant 1 minute par niveau de chasseur du sang noir. Le personnage peut utiliser ce pouvoir 2 fois par jour au niveau 4, 3 fois par jour au niveau 6, 4 fois par jour au niveau 8 et 5 fois par jour au niveau 10.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Aspect animal' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Empathie sauvage', '<p>Un chasseur du sang noir de niveau 2 ou plus peut user de langage corporel et de sons pour améliorer l''attitude d''un animal. Ce pouvoir fonctionne sur le-même principe que l''aptitude de druide éponyme, si ce n''est que le personnage ajoute son niveau de chasseur du sang noir et non son niveau de druide au test d''empathie sauvage. De plus, il bénéficie d''un bonus racial de +8 (et non de +4) quand il use de ce pouvoir auprès d''animaux normaux ou sanguinaires correspondant à sa propre forme animale.</p>
<p>Si le chasseur du sang noir possède déjà ce pouvoir grâce à une autre classe (comme druide ou rôdeur), les niveaux de celle-ci s''ajoutent à ceux de la classe de prestige pour ce qui est de fixer le bonus dont bénéficient les tests d''empathie sauvage.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Empathie sauvage' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Science de la forme hybride', '<p>Au niveau 3, le chasseur du sang noir gagne le pouvoir d''utiliser les attaques spéciales de sa forme animale sous forme hybride.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Science de la forme hybride' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Science de l''attaque naturelle maléfique', '<p>À partir du niveau 4, le chasseur du sang noir inflige 1d4 points de dégâts maléfiques supplémentaires quand il frappe à l''aide d''une arme naturelle (contre 1 point avec le don Attaque naturelle maléfique). On ne peut soigner de dégâts maléfiques qu''en usant de magie jetée dans la zone d''un sort de consécration ou sanctification.</p>
<p>A partir du niveau 8, les dégâts maléfiques infligés par ses armes naturelles passent à 1d6.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Science de l''attaque naturelle maléfique' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Science de la réduction des dégâts', '<p>Au niveau 5, la réduction des dégâts lycanthropique du personnage, augmente de 5 points, (10/argent) s''il s''agit d''un lycanthrope infecté et (15/argent) s''il s''agit d''un lycanthrope naturel. Au niveau 10, seules les armes magiques en argent peuvent passer outre cette réduction des dégâts.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Science de la réduction des dégâts' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Transformation accélérée', '<p>Un chasseur du sang noir de niveau 6 ou plus passe de sa forme hybride à sa forme animale (et vice versa) au prix d''une action de mouvement, et non d''une action simple.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Transformation accélérée' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Transformation rapide', '<p>Un chasseur du sang noir de niveau 9 ou plus passe de sa forme hybride à sa forme animale (et vice versa) au prix d''une action libre.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Transformation rapide' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Incantation lycanthropique' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Objets de forme animale' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Transmission de lycanthropie suprême' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, '1 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Aspect animal' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Empathie sauvage' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Science de la forme hybride' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, '2 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Aspect animal' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, '1d4', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Science de l''attaque naturelle maléfique' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, '+5/argent', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Science de la réduction des dégâts' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 6, '3 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Aspect animal' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 6);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 6, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Transformation accélérée' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 6);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 8, '4 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Aspect animal' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 8);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 8, '1d6', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Science de l''attaque naturelle maléfique' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 8);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 9, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Transformation rapide' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 9);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, '5 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Aspect animal' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, 'magie et argent', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Science de la réduction des dégâts' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'nature'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'nature');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 10, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 10 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 12, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 12 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 14, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 14 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 18, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 18 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 23, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 23 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 26, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 26 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 27, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 27 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 33, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 33 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 34, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 34 AND ccomp_precision = '');

-- ===== Chasseur Shaaryen

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Chasseur Shaaryen', 'CS', 2, 10, 10, 4, '<p><strong>Région.</strong> Le Shaar</p>
<p>Bonus de base à l’attaque. +5</p>
<p><strong>Compétences.</strong> Degré de maîtrise de 4 en Dressage, degré de maîtrise de 6 en Equitation, degré de maîtrise de 8 en Survie</p>
<p><strong>Dons.</strong> Combat monté. Fraternité animale, Pistage, Tir monté</p>', '<p>Le chasseur shaaryen ne gagne aucune formation au maniement des armes et des boucliers, ni au port de l''armure.</p>', NULL, '<p>Compétences de classe : Artisanat, Connaissances (folklore local), Connaissances (nature), Déplacement silencieux, Détection, Discrétion, Dressage, Équitation, Escalade, Fouille, Maîtrise des cordes, Natation, Perception auditive, Premiers secours, Profession, Saut, Survie.</p>', '<p>S''ils quittent rarement leur patrie, les Shaaryens ont une réputation de bandits rusés, d''excellents cavaliers et de chasseurs expérimentés- Bien que les accusations dont ils sont victimes ne soient pas toutes fondées, ce sont effectivement de bons cavaliers, beaucoup d''entre eux étant également des pisteurs hors pair et de grands chasseurs. À l''aide de leurs montures vives comme l''éclair, ils rattrapent les proies les plus rapides et les criblent de flèches ou les transpercent de leur lance. La plupart des chasseurs shaaryens ne sortent pas de leur pays natal, se chargeant de trouver ressources et nourriture pour leur tribu, mais quelques-uns parcourent Faerûn pour y chercher l''aventure. Ces nomades deviennent généralement des guides ou des chasseurs de primes.</p>
<p>Rôdeurs et barbares constituent la majorité des chasseurs shaaryens, mais leurs rangs abritent également des roublards. Les druides se tournent rarement vers la vie de chasseur, et les membres des autres classes n''ont pas les talents de survie en milieu sauvage nécessaires pour intégrer cette classe de prestige.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Chasseur Shaaryen' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Chasseur Shaaryen' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '1', 2, 2, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '2', 3, 3, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '3', 3, 3, 1, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '4', 4, 4, 1, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '5', 4, 4, 1, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 6, '6', 5, 5, 2, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 6);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 7, '7', 5, 5, 2, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 7);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 8, '8', 6, 6, 2, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 8);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 9, '9', 6, 6, 3, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 9);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 10, '10', 7, 7, 3, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 10);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Bonus d''Équitation', '<p>Au niveau 1, le chasseur shaaryen bénéficie d''un bonus d''aptitude de +2 aux tests d''Équitation. Ce bonus passe à +4 au niveau 4, à +6 au niveau 7 et à +8 au niveau 10.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Bonus d''Équitation' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Pistage monté', '<p>Les chasseurs shaaryens sont particulièrement doués pour suivre une piste à cheval. Dès le niveau 2, ils peuvent suivre une piste à la moitié de la vitesse de déplacement de base de leur monture sans subir de malus aux tests de Survie. Au niveau 6, il leur est possible de suivre une piste à vitesse normale sans subir de malus à ces mêmes tests.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Pistage monté' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Grand galop', '<p>A partir du- niveau 3, le chasseur shaaryen peut pousser sa monture pour qu''elle avance au double de sa vitesse de déplacement habituelle pendant 1 round. Durant ce round, elle charge au double de cette nouvelle vitesse de déplacement et galope au quadruple de celle-ci. Ce pouvoir est utilisable 1 fois par jour sans que cela ne mette la monture en danger. Si le chasseur shaaryen tente d''y recourir une seconde fois, sa monture doit réussir un jet de Vigueur (DD 20) sous peine de subir 1d6 points de dégâts. Chaque fois que le chasseur tente d''y faire appel une nouvelle fois, sa monture doit effectuer un jet de Vigueur contre le même DD, sachant que les dégâts augmentent de 1d6 par tentative supplémentaire. Ainsi, la troisième utilisation de ce pouvoir au cours d''une .même journée infligera 2d6 points de dégâts, puis 3d6 pour la quatrième, etc.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Grand galop' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Précision montée', '<p>Les chasseurs shaaryens sont presque aussi doués que la horde tuigane quand ils tirent à dos de monture. Dès le niveau 4, ils bénéficient d''un bonus d''aptitude de +2 aux jets d''attaque à distance montés. Au niveau 9, ce bonus passe à +4;</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Précision montée' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Charge dévastatrice', '<p>Au niveau 5, le chasseur shaarryen reçoit Charge dévastatrice en qualité de don supplémentaire s''il ne le possède pas déjà. Il n''est pas obligé de satisfaire aux conditions du don.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Charge dévastatrice' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Longue chevauchée', '<p>Au niveau 7, le chasseur shaaryen apprend à puiser davantage dans les réserves, de sa monture afin de chevaucher plus longtemps et à meilleure allure. Quand il se déplace sur une longue distance, sa monture progresse à 150 % de sa vitesse de déplacement habituelle. Ce pouvoir n''augmente pas la vitesse de déplacement de la monture au combat.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Longue chevauchée' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Cavalier né', '<p>Quand un chasseur shaaryen atteint le niveau 8, sa maîtrise de l''équitation lui permet de réaliser d''incroyables tours. Une fois par jour, à la condition qu''il soit monté, il peut effectuer un test d''Équitation à la place d''un jet d''attaque, d''un jet de sauvegarde ou d''un test de compétence. Il exploite son modificateur d''Equitation total mais n''en gagne pas d''autres (comme un bonus d''altération dû à une arme ou un don qui augmente son bonus aux sauvegardes).</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Cavalier né' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, '+2', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Bonus d''Équitation' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, '1/2 VD', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Pistage monté' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Grand galop' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, '+4', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Bonus d''Équitation' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, '+2', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Précision montée' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Charge dévastatrice' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 6, 'VD normale', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Pistage monté' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 6);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, '+6', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Bonus d''Équitation' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Longue chevauchée' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 8, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Cavalier né' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 8);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 9, '+2', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Précision montée' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 9);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, '+8', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Bonus d''Équitation' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'folklore local'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'folklore local');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'nature'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'nature');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 10, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 10 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 12, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 12 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 14, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 14 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 15, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 15 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 17, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 17 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 18, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 18 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 22, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 22 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 25, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 25 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 26, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 26 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 27, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 27 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 28, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 28 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 33, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 33 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 34, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 34 AND ccomp_precision = '');

-- ===== Chevalier Dragon Pourpre

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Chevalier Dragon Pourpre', 'CDP', 2, 10, 5, 2, '<p><strong>Région.</strong> Le candidat doit avoir le Cormyr pour région natale ou posséder 8 degrés de maîtrise en Connaissances (Cormyr)</p>
<p><strong>Alignement.</strong> N’être ni mauvais ni chaotique</p>
<p>Bonus de base à l’attaque. +4</p>
<p><strong>Compétences.</strong> Degré de maîtrise de 2 en Détection, degré de maîtrise de 1 en Diplomatie ou Intimidation, degré de maîtrise de 2 en Équitation, degré de maîtrise de 2 en Perception auditive</p>
<p><strong>Spécial.</strong> Le candidat doit être membre des Dragons Pourpres</p>', '<p>Le chevalier dragon pourpre ne gagne aucune formation au maniement des armes et des boucliers, ni au port de l''armure.</p>', NULL, '<p>Compétences de classe : Connaissances (Cormyr), Connaissances (tactique), Diplomatie, Équitation, Escalade, Intimidation, Natation, Saut.</p>', '<p>Les célèbres Dragons Pourpres constituent le gros de l''armée régulière du Cormyr. Aux côtés des redoutables Magiciens de guerre du Cormyr, ces soldats expérimentés défendent le Royaume forestier contre toutes sortes de menaces, qu''il s''agisse d''humanoïdes sauvages ou d''énigmatiques reflets. Le chevalier dragon pourpre, un officier de l''armée, commande entre dix et cent soldats sur le champ de bataille. Ce titre est donc un grand honneur pour tout Cormyrien.</p>
<p>Guerriers, rôdeurs, et paladins constituent le gros des chevaliers dragons pourpres, mais quelques bardes, prêtres et roublards se''joignent également à eux. Bien qu''ils ne soient pas exclus de cette organisation, les magiciens et les ensorceleurs empruntent habituellement la voie des Magiciens de guerre, la brigade d''élite de lanceurs de sorts combattant pour le Cormyr. Barbares, druides et moines rejoignent rarement les rangs des chevaliers dragons pourpres, soit parce qu''ils manquent de discipline, soit parce qu''ils sont bien trop fougueux.</p>
<p>Le fait de choisir cette classe de prestige exige que l''on soit au service du Cormyr, détail qui peut ne pas être compatible avec toutes les campagnes.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Chevalier Dragon Pourpre' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Chevalier Dragon Pourpre' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '1', 0, 2, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '2', 0, 3, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '3', 1, 3, 1, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '4', 1, 4, 1, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '5', 1, 4, 1, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Cri de ralliement', '<p>Le chevalier dragon pourpre est capable de pousser un grand cri (généralement « Pour, le Cormyr ! ») qui lui confère un bonus de moral de +1 au jet d''attaque suivant et qui augmente sa vitesse de déplacement de 1,50 mètre jusqu''à son prochain tour de jeu. Ces avantages s''étendent également aux alliés présents dans un rayon de 18 mètres. Traditionnellement, le cri de ralliement est utilisé quand une formation de soldats est sur le point de charger. Il s''agit d''un pouvoir mental utilisable 3 fois par jour.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Cri de ralliement' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Écu héroïque', '<p>Un chevalier dragon pourpre peut utiliser l''action d''aide pour conférer un bonus de circonstance de +4 à la CA à un allié (et non +2).</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Écu héroïque' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Inspiration vaillante', '<p>Une fois par jour, un chevalier dragon pourpre de niveau 2 peut prononcer un sermon galvanisant pour encourager ses alliés (et lui-même). Ce pouvoir fonctionne sur le même principe que celui de barde du même nom. Les sujets (ce qui inclut le chevalier) bénéficient d''un bonus de moral de +2 aux jets, de sauvegarde contre les effets de charme et de terreur, et d''un bonus de moral de +1 aux jets d''attaque et aux jets de dégâts des armes. Pour en profiter, chaque allié doit entendre le chevalier dragon pourpre parler pendant 1 round. Les effets durent aussi longtemps que l''allié peut entendre le chevalier parler et pendant les 5 rounds suivants. Lorsqu''il parle, le chevalier peut se battre, mais il est incapable de lancer de sorts, d''activer des objets magiques à fin d''incantation (comme les parchemins) ou à mot de commande (comme les baguettes).</p>
<p>Au niveau 4, le chevalier obtient une autre utilisation quotidienne de ce pouvoir.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Inspiration vaillante' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Terreur', '<p>Une fois par jour, un chevalier dragon pourpre de niveau 3 ou plus peut créer un effet de terreur qui . fonctionne comme le sort du même nom (niveau de lanceur de sorts égal au niveau global du personnage).</p>', 'mag', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Terreur' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Serment du courroux', '<p>Un chevalier dragon pourpre de niveau 4 peut désigner un adversaire situé dans uri rayon de 18 mètres et faire le serment de l''abattre. Durant route la rencontre, le chevalier bénéficie d''un bonus de moral de +2 aux jets d''attaque au corps à corps, aux jets de dégâts des armes, aux jets de sauvegarde et aux tests de compétence, du moins s''ils sont effectués contre l''adversaire désigné. L''effet est immédiatement annulé si le chevalier attaque ou lance un sort contre une créature hostile autre que celle qu''il a désignée dans le cadre de ce pouvoir. Les attaques d''opportunité et les sorts jetés aux alliés ne comptent cependant pas, tout comme les sorts dont la zone d''effet peut toucher .plusieurs cibles (par exemple, boule de feu). Ce pouvoir est utilisable 1 fois par jour.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Serment du courroux' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Résistance ultime', '<p>Une fois par jour, un chevalier dragon pourpre de niveau 5 peut inspirer un sentiment d''héroïsme à ses troupes. Quand il utilise ce pouvoir, il gagne 2d10 points de vie temporaires, ce qui vaut également pour les alliés situés dans un rayon de 3 mètres. Ce pouvoir affecte un nombre de créatures égal au niveau de classe du chevalier + son modificateur de Charisme. L''effet dure un nombre de rounds équivalent.</p>
<p>Dons liés aux aptitudes</p>
<p><strong>Inspiration vaillante</strong> : Inspiration du feu draconique</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Résistance ultime' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Cri de ralliement' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Écu héroïque' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, '1 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Inspiration vaillante' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Terreur' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, '2 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Inspiration vaillante' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Serment du courroux' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Résistance ultime' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'Cormyr'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'Cormyr');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'tactique'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'tactique');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 13, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 13 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 17, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 17 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 18, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 18 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 23, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 23 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 26, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 26 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 33, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 33 AND ccomp_precision = '');

-- ===== Dévot Profane

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Dévot Profane', 'DP', 2, 4, 5, 2, '<p><strong>Compétences.</strong> Degré de maîtrise de 8 en Art de la magie, degré de maîtrise de 8 en Connaissances (religion)</p>
<p><strong>Don.</strong> Extension de portée</p>
<p><strong>Sorts.</strong> Faculté de lancer des sorts de magie profane de 4e niveau</p>
<p><strong>Divinité tutélaire.</strong> Le dévot profane doit avoir une divinité tutélaire et il doit s’agir du dieu dont il est l’un des dévots profanes</p>', '<p>Le dévot ne reçoit aucune formation supplémentaire au maniement des armes et des boucliers, ni au port des armures.</p>', '<p>A chaque niveau de dévot profane, le personnage obtient un niveau effectif de jeteur de sorts pour une de ses classes de lanceur de sorts profanes précédentes (via laquelle il est capable de lancer des sorts de 4e niveau au moins). Il obtient les sorts par jour et le niveau de lanceur de sorts d''un personnage de son niveau effectif. Par contre, il ne gagne aucun des autres avantages accompagnant habituellement ce niveau (dons de métamagie ou de création d''objets, pouvoirs de barde ou d''assassin, etc.). Si le dévot profane possède plusieurs classes de lanceur de sorts profanes via lesquelles il peut jeter des sorts de 4e niveau au moins, le niveau effectif ne s''applique qu''à l''une d''entre elles, au choix du personnage.</p>', '<p>Compétences de classe : Art de la magie, Artisanat, Concentration, Connaissances (toutes), Décryptage, Profession.</p>', '<p>Bien que prêtres et druides constituent le gros des lanceurs de sorts au sein des hiérarchies des Églises de Faerûn, ils ne sont pas en situation de monopole. Nombre d''ensorceleurs et de magiciens pieux, et même quelques bardes, choisissent de consacrer leur vie à un dieu, comme le font les plus dévots des prêtres. Ces lanceurs de sorts profanes ont une vision de la magie divine qui confond habituellement leurs pairs moins religieux.</p>
<p>Les dévots profanes sont les plus courants parmi les rangs des adorateurs d''Azouth et de Mystra, le premier attirant davantage de magiciens et la seconde d''ensorceleurs. Certains bardes deviennent les dévots profanes de Lliira ou de quelque autre divinité appréciant la musique. Enfin, certains assassins figurent parmi les dévots profanes de Baine.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Dévot Profane' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Dévot Profane' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 0, 0, 2, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '1', 0, 0, 3, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '1', 1, 1, 3, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '2', 1, 1, 4, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '2', 1, 1, 4, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Portée sacrée', '<p>Dès le niveau 1, le dévot profane peut appliquer les effets du don Extension de portée à tout sort qu''il lance. Il ne lui est pas nécessaire de le préparer comme un sort étendu. En outre, cela n''augmente pas le temps d''incantation et ne mobilise pas un emplacement de sort d''un niveau supérieur. Ce pouvoir peut être utilisé un nombre de fois par jour égal à 1 + modificateur de Charisme du dévot profane (1 fois par jour minimum).</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Portée sacrée' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Défense sacrée', '<p>Dès le niveau 2 le dévot profane bénéficie d''un bonus de +1 aux jets de sauvegarde contre les sorts de magie divine, mais également contre les pouvoirs magiques et pouvoirs surnaturels des Extérieurs. Au niveau 4, ce bonus passe à +2.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Défense sacrée' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Synergie divine', '<p>Au niveau 3, le dévot profane apprend à harmoniser sa magie avec celle des adorateurs de sa divinité. Chaque fois qu''il est la cible d''un sort inoffensif jeté par un lanceur de sorts divins de sa divinité tutélaire, le sort agit comme s''il bénéficiait des effets du don Extension d''effet. Le sort doit être lancé par un autre personnage. Si le dévot profane dispose de niveaux de lanceur de sorts de magie divine, il ne profite pas des avantages de ce pouvoir pour ce qui est des sorts qu''il jette lui-même. Un sort qui ne saurait profiter du don Extension d''effet ne tire aucun avantage de cette aptitude.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Synergie divine' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Suaire divin', '<p>Au niveau 5, le dévot profane peut, 1 fois par jour, s''entourer d''un linceul de puissance divine rayonnante le protégeant contre tous les sorts hostiles. Ce pouvoir fonctionne sur le même principe que le sort résistance à la magie (niveau de lanceur de sorts égal au niveau de dévot profane), mais le suaire est d''une couleur propre à la divinité tutélaire du personnage. Par exemple, un dévot profane de Tyr s''entoure d''une lueur rose-pourpre, contre un nuage palpitant de noir et de pourpre pour un dévot profane de Cyric.</p>', 'mag', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Suaire divin' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Portée sacrée' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Défense sacrée' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Synergie divine' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, '+2', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Défense sacrée' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Suaire divin' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 2, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 2 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 4, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 4 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'toutes'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'toutes');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 8, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 8 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');

-- ===== Disciple Divin

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Disciple Divin', 'DD', 2, 8, 5, 2, '<p><strong>Compétences.</strong> Degré de maîtrise de 8 en Connaissances (religion), degré de maîtrise de 5 en Diplomatie</p>
<p><strong>Sorts.</strong> Faculté de lancer des sorts de magie divine de 4e niveau</p>
<p><strong>Divinité tutélaire.</strong> Le disciple divin doit avoir une divinité tutélaire, et il doit s’agir du dieu dont il est l’un des disciples</p>', '<p>Le disciple divin ne reçoit aucune formation supplémentaire au maniement des armes et des boucliers, ni au port des armures.</p>', '<p>A chaque niveau de disciple divin, le personnage obtient un niveau effectif de jeteur de sorts pouf une de ses classes de lanceur de sorts divins précédentes (via laquelle il est capable de lancer des sorts divins de 4e niveau au moins). Il obtient les sorts par jour et le niveau de lanceur de sorts d''un personnage de son niveau effectif. Par contre, il ne gagne aucun des autres avantages accompagnant habituellement ce niveau (meilleures chances de repousser ou d''intimider les morts-vivants, etc.). Si le disciple divin possède plusieurs classes de lanceur de sorts divins via lesquelles il peut jeter des sorts de 4e niveau au moins, le niveau effectif ne s''applique qu''à l''une d''entre elles, au choix du personnage.</p>', '<p>Compétences de classe : Art de la magie, Artisanat, Concentration, Connaissances (nature), Connaissances (plans), Connaissances (histoire), Connaissances (religion), Connaissances (mystères), Diplomatie, Premiers secours, Profession, Survie.</p>', '<p>Parmi les disciples de chaque religion figurent quelques individus dont la dévotion ne connaît aucune limite. Le disciple divin est l''incarnation vivante de la divinité tutélaire sur Toril. Au faîte de sa puissance, il transcende même la condition de simple mortel. Dès lors, qu''il continue de servir son dieu à Faerûn ou qu''il le rejoigne, il entretient avec celui-ci une relation personnelle et privilégiée.</p>
<p>Les disciples divins sont toujours des jeteurs de sorts de magie divine. Prêtres et druides constituent les candidats les plus fréquents, mais les paladins et les rôdeurs les plus pieux empruntent parfois cette voie. Enfin, des dieux maléfiques élèvent parfois au sein de leur culte des chevaliers noirs au rang de disciples divins.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Disciple Divin' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Disciple Divin' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 0, 2, 2, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '1', 0, 3, 3, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '2', 1, 3, 3, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '3', 1, 4, 4, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '3', 1, 4, 4, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Émissaire divin', '<p>Dès le niveau 1, le disciple divin est capable de communiquer par. télépathie avec tout Extérieur situé dans un rayon de 18 mètres, du moins si celui-ci sert le même dieu ou a le même alignement que le personnage. L''effet de télépathie est un pouvoir surnaturel.</p>
<p>Le personnage bénéficie également d''un bonus égal à son niveau de disciple divin aux tests de compétence et de caractéristique relevant du Charisme quand il traite avec des Extérieurs partageant son alignement ou sa divinité tutélaire.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Émissaire divin' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Défense sacrée', '<p>Dès le niveau 2 le disciple divin bénéficie d''un bonus de +1 aux jets de sauvegarde contre les sorts de magie divine, mais également contre les pouvoirs magiques et pouvoirs surnaturels des Extérieurs. Au niveau 4, ce bonus passe à +2.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Défense sacrée' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Transfert de sorts', '<p>À partir du niveau 3, le disciple divin peut user de transfert de sorts (niveau de lanceur de sorts égal à celui du personnage). Comme il s''agit d''un pouvoir magique, le disciple divin n''a pas besoin de mobiliser un emplacement de sort de 4e niveau pour s''en servir, mais les sorts transférés mobilisent bel et bien des emplacements de bas niveau. Ce pouvoir est utilisable 1 fois par jour.</p>', 'mag', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Transfert de sorts' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Domaine', '<p>Au niveau 4, le disciple divin peut choisir un domaine parmi ceux que son dieu est susceptible de lui conférer. S''il a déjà deux domaines de prêtre, il en gagne donc un troisième. Quelle que soit sa classe de lanceur de sorts divins d''origine, il gagne le pouvoir accordé par ce troisième domaine, ajoutant ses niveaux de disciple divin à ses niveaux de prêtre (le cas échéant) pour en déterminer les effets. Si le personnage a déjà des niveaux de prêtre, il gagne également un troisième choix, de sort pour combler l''emplacement de domaine de chaque niveau. Druides, paladins et rôdeurs ne gagnent, pas d''emplacements de sorts supplémentaires, mais il leur est possible de préparer les sorts de domaine comme n''importe quel autre sort de leur liste.</p>', NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Domaine' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Transcendance', '<p>Au niveau 5, grâce à son association de longue date avec des Extérieurs et l''intervention directe de son dieu, le disciple divin transcende sa forme mortelle et devient un Extérieur pourvu du sous-type natif. Cette apothéose lui confère une immunité contre les sorts et effets qui n''affectent pas les Extérieurs (par exemple, charme-personne), ainsi que la vision dans le noir sur 18 mètres (s''il ne la possède pas déjà). Cependant, en raison du sous-type natif, le disciple divin n''en doit pas moins manger, respirer et dormir. Il est également possible de lui lancer réincarnation, rappel à* la vie ou résurrection. Il acquiert également les sous-types d''alignement correspondant aux composantes d''alignement qu''il a en commun avec son dieu.</p>
<p>Par exemple, un disciple divin chaotique neutre d''une divinité chaotique mauvaise acquiert le sous-type Chaos, et le disciple divin d''une divinité neutre n''en gagne aucun.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Transcendance' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Émissaire divin' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, '+1', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Défense sacrée' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Transfert de sorts' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, '+2', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Défense sacrée' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Domaine' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Transcendance' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 2, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 2 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 4, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 4 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'nature'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'nature');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'plans'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'plans');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'histoire'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'histoire');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'religion'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'religion');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'mystères'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'mystères');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 13, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 13 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 28, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 28 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 34, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 34 AND ccomp_precision = '');

-- ===== Espion du Zhentarim

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Espion du Zhentarim', 'EZ', 2, 6, 5, 6, '<p><strong>Alignement.</strong> Mauvais</p>
<p>Bonus de base à l’attaque. +5</p>
<p><strong>Compétences.</strong> Degré de maîtrise de 5 en Bluff, degré de maîtrise de 5 en Contrefaçon, degré de maîtrisé de 5 en Déguisement, degré de maîtrise de 5 en Renseignements</p>
<p><strong>Don.</strong> Fourberie</p>', '<p>L''espion du Zhentarim est formé au maniement des armes courantes et des boucliers, ainsi qu''au port des armures légères et intermédiaires.</p>', NULL, '<p>Compétences de classe : Acrobaties, Bluff, Contrefaçon, Crochetage, Décryptage, Déguisement, Déplacement silencieux, Désamorçage/sabotage, Détection, Diplomatie, Discrétion, Équilibre, Escalade, Escamotage, Estimation, Évasion, Fouille, Intimidation, Langue, Maîtrise des cordes, Perception auditive, Psychologie, Renseignement, Saut, Utilisation d’objets magiques.</p>', '<p>Le Zhentarim compte parmi les organisations « secrètes » les plus craintes et connues de Faerûn. Ses membres sont liés de près ou de loin à toutes sortes d''activités illégales, du meurtre au trafic de drogue en passant par l''esclavagisme. Bien que ses rangs abritent divers types d''individus, l''espion est certainement celui dont les Faeruniens croisent le plus souvent le chemin, même s''ils ne le réalisent jamais.</p>
<p>La plupart des espions du Zhentarim ont d''abord entrepris une carrière de roublard ou de barde, mais quelques moines, ensorceleurs et magiciens trouvent également ce travail à leur goût. Guerriers, barbares et rôdeurs manquent généralement de la subtilité nécessaire pour faire un bon espion. Enfin, les prêtres et druides attirés par l''organisation ont des us religieux qui leur permettent difficilement de se mélanger à la population.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Espion du Zhentarim' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Espion du Zhentarim' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 2, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '1', 3, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '2', 3, 1, 1, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '3', 4, 1, 1, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '3', 4, 1, 1, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Attaque sournoise', '<p>Ce pouvoir fonctionne sur le même principe que l''aptitude de roublard éponyme. Les dégâts supplémentaires infligés augmentent de +1d6 au niveau 1 et +2d6 au niveau 4. Si le personnage jouit déjà d''un bonus d''attaque sournoise (issus de niveaux de roublard, par exemple), les dégâts se cumulent. De plus, les niveaux d''espion du Zhentarim s''ajoutent à ceux d''autres classes (comme roublard ou assassin) pour ce qui est de passer outre l''esquive instinctive supérieure d''adversaires.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Attaque sournoise' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Couverture', '<p>L''espion du Zhentarim apprend à se créer des couvertures parfaites. Pour chaque compétence d''Artisanat ou de Profession dans laquelle il possède 2 degrés de maîtrise au moins, le personnage dispose d''une couverture. Chacune doit correspondre à une identité précise (comme « Jolan Tourne-boucle, boulanger de Valombre »), et non à une description générique (comme un simple boulanger). Le personnage peut mettre un terme à l''existence d''une couverture à tout moment pour s''en forger une nouvelle.</p>
<p>Quand il agit sous l''une de ses couvertures, il bénéficie d''un bonus de circonstances de +4 aux tests dé Déguisement et d''un bonus de +2 aux tests de Bluff et de Renseignements. Tous les 2 degrés de maîtrise supplémentaires (en plus des deux premiers) possédés dans la compétence d''Artisanat ou de Profession associée à sa couverture, chacun de ces bonus augmente de +1. Si le MD le souhaite, ces bonus peuvent être réduits ou éliminés dans les régions où la couverture est totalement hors de propos (par exemple, un boulanger de Valombre attirera certainement la méfiance dans les ruines de Myth Drannor).</p>
<p>Pour se créer une nouvelle identité ou en remplacer une ancienne, l''espion du Zhentarim doit sr-documenter et accumuler des effets-personnels, s''établir et mener une seconde vie crédible. Ce processus demande 1d4 x 10 jours, durant lesquels il ne peut rien faire d''autre, et coûte 6dl0 po. L''espion du Zhentarim n''est pas obligé de se constituer une couverture pour chaque compétence d''Artisanat ou de profession dans laquelle il possède 2 degrés de maîtrise. Il peut donc attendre qu''une occasion se présente à lui. Par exemple, il peut garder une identité de côté pour tirer le meilleur parti du pouvoir de couverture improbable (cf. ci-dessous).</p>
<p>Ce pouvoir ne confère pas les compétences nécessaires à la crédibilité de la couverture, comme une meilleure connaissance d''une région donnée, la capacité de parler une langue étrangère, des facultés de lanc.eur de sorts, etc. Les espions du Zhentarim ont donc tendance à se forger des identités qtii collent à leurs compétences.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Couverture' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Alignement indétectable', '<p>Au niveau 2, les exercices mentaux auxquels se livre l''espion du Zhentarim lui permettent de se protéger des sorts de Divination. Ce pouvoir fonctionne sur le même principe que le sort alignement indétectable, mais il est toujours actif. De plus, s''agissant d''un pouvoir extraordinaire, il'' n''est pas possible de le dissiper ou de le réprimer.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Alignement indétectable' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Utilisation du poison', '<p>Au niveau 3, l''espion du Zhentarim apprend à utiliser du poison. Il ne risque jamais de s''empoionner accidentellement quand il enduit son arme d''une substance délétère.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Utilisation du poison' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Couverture improbable', '<p>Au niveau 3, l''espion du Zhentarim peut désigner un nombre d''identités égal à son bonus de Charisme (1 minimum) qui sont ses « couvertures improbables ». Sous une telle couverture, le personnage prend l''identité de quelqu''un de bien différent : un membre du sexe opposé ou d''une race différente, ou un individu pourvu d''une silhouette très différente de la sienne. Il doit bien évidemment commencer par créer cette couverture s''il ne la possède pas déjà. Sous une couverture improbable, ses bonus aux test de Bluff, Déguisement et Renseignements sont doublés (+8 aux tests de Déguisement, +4 aux tests de Bluff et de renseignements, et +2 tous les 2 degrés de maîtrise supplémentaires aux tests effectués avec la compétence d''Artisanat ou de Profession en rapport avec la couverture). De plus, le DD des tests de Détection visant à percer son déguisement augmente de +4.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Couverture improbable' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Esprit fuyant', '<p>Au niveau 4, l''espion du Zhentarim gagne le pouvoir spécial d''esprit fuyant s''il ne le possède pas déjà.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Esprit fuyant' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Couverture avancée', '<p>Au niveau 5, l''espion du Zhentarim peut choisir un nombre de nouvelles couvertures égal à son bonus d''Intelligence (1 minimum). Il peut s''agir d''identités choi- • sies dans le cadre de l''aptitude de couverture improbable, d''identités différentes, voire d''un mélange des deux. Cependant, il ne s''agit pas forcément de nouvelles identités.</p>
<p>Quand l''espion du Zhentarim opère sous l''une de ces couvertures, son esprit est à ce point conditionné pour penser comme celui qu''il prétend être que les scrutations magiques et autres lectures de l''esprit ne révèlent rien de sa véritable nature (à moins qu''elles ne soient initiées par un dieu). Seuls les pensées, l''alignement et les émotions de la personnalité fictives peuvent ¦ être détectées.</p>
<p>Dons liés aux aptitudes</p>
<p><strong>Attaque sournoise</strong> : Attaque commotionnante, Attaque défigurante, Attaque persistante, Attaque sournoise d’opportunité (épique), Attaque sournoise démoniaque, Attaque sournoise retardée, Coup à la gorge, Coup habile, Coup sacré, Coupe-jarret, Dégâts persistants (épique), Drain d’esprit, Embusqué rapide, Frappe assourdissante, Frappe de feu draconique, Frappe débilitante, Frappe des ténèbres, Frappe du loup, Frappe éventrente, Frappe fièvreuse, Frappe hémorragique, Frappe indigo, Frappe miséricordieuse, Frappe paralysante, Frappe silencieuse, Frappe terrifiante, Frappe venimeuse, Hors-la-loi audacieux, Hors-la-loi sacré, Influx de démolition, Inquisiteur dévot, Lâche, Leçons de la nature, Lutte sauvage, Roublard ascétique, Science de l’attaque mortelle (épique), Science de l’attaque sournoise (épique), Spécialiste des ennemis</p>
<p><strong>Utilisation du poison</strong> : Expert du poison, Frappe venimeuse, Maître du poison</p>
<p><strong>Esprit fuyant</strong> : Vigueur habile (épique), Volonté habile (épique)</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Couverture avancée' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Couverture' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Alignement indétectable' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, '+1d6', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Attaque sournoise' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Couverture improbable' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Utilisation du poison' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, '+2d6', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Attaque sournoise' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Esprit fuyant' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Couverture avancée' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 1, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 1 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 3, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 3 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 6, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 6 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 7, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 7 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 8, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 8 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 9, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 9 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 10, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 10 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 11, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 11 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 12, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 12 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 13, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 13 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 14, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 14 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 16, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 16 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 18, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 18 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 19, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 19 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 20, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 20 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 21, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 21 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 22, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 22 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 23, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 23 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 24, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 24 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 25, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 25 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 27, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 27 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 30, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 30 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 31, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 31 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 33, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 33 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 35, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 35 AND ccomp_precision = '');

-- ===== Gardesort de Lunargent

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Gardesort de Lunargent', 'GL', 2, 4, 5, 2, '<p><strong>Alignement.</strong> Ne pas être mauvais</p>
<p><strong>Compétences.</strong> Degré de maîtrise de 5 en Art de la magie, degré de maîtrise de 8 en Concentration</p>
<p><strong>Dons.</strong> Magie de guerre, un don de métamagie au choix</p>
<p><strong>Sorts.</strong> Faculté de lancer des sorts de magie profane de 4e niveau</p>
<p><strong>Spécial.</strong> Le candidat doit être accepté au sein de la Gardesort</p>', '<p>Le gardesort de Lunargent ne reçoit aucune formation supplémentaire au maniement des armes et des boucliers, ni au port des armures.</p>', '<p>A chaque niveau de gardesort de Lunargent, le personnage obtient un niveau effectif de jeteur de sorts pour une de ses classes de lanceur de sorts profanes précédentes (via laquelle il est capable de lancer des sorts de 4e niveau au moins). Il obtient les sorts par jour et le niveau de lanceur de sorts d''un personnage de son niveau effectif. Par contre, il ne gagne aucun des autres avantages accompagnant habituellement ce niveau (dons de métamagie ou de création d''objets supplémentaires, aptitudes de barde ou d''assassin, etc.). Si le gardesort de Lunargent possède plusieurs classes de lanceur de sorts profanes via lesquelles il peut jeter des sorts de 4e niveau au moins, le niveau effectif né s''applique qu''à l''une d''entre elles, au choix du personnage.</p>', '<p>Compétences de classe : Art de la magie, Artisanat, Concentration, Connaissances (toutes), Décryptage, Détection, Profession.</p>', '<p>Bastion de la civilisation dans le Nord sauvage, la cité de Lunargent attire l''attention des sinistres créatures qui vivent dans les forêts enneigées. Géants maléfiques, trolls, elfes noirs et créatures plus redoutables encore fomentent la chute du joyau du Nord. Heureusement pour les Lunargentins, la ville est cependant protégée. La Gardesort, organisation d''élite de lanceurs de sorts profanes, défend la communauté contre les menaces magiques et aide les chevaliers de Lunargent contre les ennemis classiques.</p>
<p>Ensorceleurs et magiciens occupent le gros des gardesorts. Aujourd''hui, l''organisation ne compte aucun barde, mais cette classe n''est pas volontairement écartée. Les personnages multiclassés sont rares en son sein, mais guerriers et roublards dotés de niveaux d''ensorceleur ou de magicien sont les bienvenus en raison de leur efficacité sur le terrain.</p>
<p>Le fait de choisir cette classe de prestige exige que l''on soit au service de Lunargent, détail qui peut ne pas être compatible avec toutes les campagnes.</p>
<p><strong>Anciens Gardesorts.</strong></p>
<p>Un gardesort de Lunargent renonçant à ses devoirs, trahissant Lunargent ou les Marches d''Argent, ou se comportant de manière inadéquate pour un officier militaire est chassé de la Gardesort. Son adrath est désactivé et sa relation au mythal annulée. Il conserve les autres aptitudes de gardesort de Lunargent, mais il ne peut plus progresser au sein de cette classe de prestige. Il récupère son statut et ses aptitudes s''il fait acte de contrition.</p>
<p>Un personnage peut également décider de prendre sa retraite. Il est alors censé rendre son adrath, mais il conserve toutes ses aptitudes de classe (à l''exception de son obligation de servir l''organisation). Il ne peut évidemment plus progresser dans cette classe de prestige. Il arrive néanmoins qu''un gardesort rejoigne de nouveau l''organisation, ce qui lui permet alors de prendre des niveaux de gardesort de Lunargent.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Gardesort de Lunargent' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Gardesort de Lunargent' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 0, 0, 2, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '1', 0, 0, 3, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '2', 1, 1, 3, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '3', 1, 1, 4, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '3', 1, 1, 4, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Gage', '<p>Un gardesort de Lunargent de niveau 1 reçoit un adrath, un petit disque en métal qui lui permet de lancer les sorts normalement prohibés par le mythal. Tant qu''il possède cet objet, le personnage peut lancer des sorts d''Invocation (convocation), des sorts d''Évocation [Feu] ou des sorts accompagnés du registre de la téléportation malgré les protections dont bénéficie Lunargent. Il lui est également possible d''utiliser des objets magiques qui reproduisent ces, effets.</p>
<p>Ce gage n''apparaît pas dans les mains du personnage comme par magie, aussi doit-il retourner à Lunargent pour le recevoir de son supérieur.</p>', NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Gage' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Harmonisation protectrice', '<p>Chaque gardesort de Lunargent de niveau 1 est introduit au sein de l''ordre via une cérémonie complexe tenue dans le grand palais de la ville. Cette cérémonie harmonise le personnage avec le mythal qui enveloppe Lunargent sans qu''il lui soit nécessaire de sacrifier les 2 500 PX habituels.</p>', NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Harmonisation protectrice' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Obligation', '<p>La Gardesort est une unité militaire, pas une simple confrérie de mages. De fait, chaque gardesort de Lunargent doit passer deux jours sur dix au moins en service actif, qu''il s''agisse de protéger les murailles de la ville ou de patrouiller la région en compagnie d''un détachement de chevaliers d''Argent.</p>', NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Obligation' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Don de métamagie', '<p>Aux niveaux 2 et 4, le gardesort a le droit de choisir un don de métamagie en qualité de don supplémentaire. Il doit satisfaire aux conditions de chacun.</p>', NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Don de métamagie' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Sort sélectif', '<p>Les gardesorts reçoivent un entraînement spécifique pour minimiser les dégâts collatéraux quand ils usent de sorts offensifs. Une fois par jour et par point de bonus d''Intelligence (1 fois par jour minimum), un gardesort de niveau 3 ou plus peut désigner un type (et un sous-type s''il le souhaite) de créatures lors d''une incantation. Lorsqu''un type est accompagné de plusieurs sous-types, le personnage peut décider ne n''en compter qu''un ou plusieurs, au choix. Ce type de créatures est alors le seul qui soit affecté ou non par le sort. Les objets, les matières inertes et tout ce qui est dénué de type sont affectés normalement. On lance un sort sélectif au prix d''une action complexe.</p>
<p>Par exemple, supposons qu''un gardesort patrouille la forêt de Lunargent en compagnie d''un groupe de chevaliers d''Argent constitué de deux humains, un elfe et un nain. Soudain, le groupe est attaqué par des gobelins. Le gardesort use de son pouvoir de sort sélectif pour lancer une boule de feu, désignant les humanoïdes (gobelinoïdes) comme les seules créatures affectées. La boule de feu explose au beau milieu de la mêlée. Bien que les compagnons du gardesort soient pris dans la zone d''effet, ils ne subissent pas de dégâts.</p>
<p>Au niveau 5, le gardesort peut désigner plusieurs types et sous-types de créature. Cependant, chaque type ou sous-type supplémentaire ainsi choisi sacrifie une utilisation quotidienne de ce pouvoir.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Sort sélectif' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Gardesort', '<p>A l''origine, la Gardesort fut conçue pour protéger la Haute Dame Alustriel d''attaques personnelles. Bien que ce rôle soit devenu secondaire par rapport à la protection de la ville, les gardesorts n''en reçoivent pas moins une formation de garde du corps. Au niveau 4, le personnage peut lancer tout sort profane défensif à portée personnelle sur autrui d''un simple contact Un sort défensif améliore la CA, augmente un modificateur de sauvegarde ou confère des points de vie supplémentaires (que ce soit en soignant les blessures ou eh octroyant des points de vie temporaires).</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Gardesort' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Puissance magique', '<p>Au niveau 5, le niveau de lanceur de sorts effectif du personnage bénéficie d''un bonus, de +1 pour ce qui est de déterminer les variables relevant du niveau et les tests de niveau de lanceur de sorts.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Puissance magique' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Gage' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Harmonisation protectrice' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Obligation' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Don de métamagie' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Sort sélectif' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Don de métamagie' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Gardesort' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Puissance magique' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, 'types multiples', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Sort sélectif' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 2, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 2 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 4, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 4 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'toutes'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'toutes');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 8, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 8 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 12, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 12 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');

-- ===== Gardien Mortuaire Evereskan

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Gardien Mortuaire Evereskan', 'GME', 2, 6, 5, 4, '<p><strong>Race.</strong> Elfe</p>
<p><strong>Région.</strong> Evereska</p>
<p>Bonus de base à l’attaque. +4</p>
<p><strong>Compétences.</strong> Degré de maîtrise de 5 en Déplacement silencieux, degré de maîtrise de 2 en Détection, degré de maîtrise de 5 en Discrétion, degré de maîtrise de 2 en Perception auditive, degré de maîtrise de 5 en Survie</p>
<p><strong>Dons.</strong> Pistage, Vigilance</p>
<p><strong>Sorts.</strong> Faculté de lancer des sorts de magie profane de 2e niveau</p>', '<p>Le gardien funéraire evereskan ne reçoit aucune formation supplémentaire au maniement des armes et des boucliers, ni au port des armures.</p>', '<p>À chaque niveau de gardien funéraire evereskan, le personnage obtient un niveau effectif de jeteur'' de sorts pour une de ses classes de lanceur de sorts profanes précédentes (via laquelle il est capable de lancer des sorts de 1° niveau au moins). Il obtient les sorts par jour et le niveau de lanceur de sorts d''un personnage de son niveau effectif. Par contre, il ne gagne aucun des autres avantages accompagnant habituellement ce niveau (dons de métamagie ou de création d''objets supplémentaires, aptitudes de barde ou d''assassin, etc.). Si le gardien funéraire evereskan possède plusieurs classes de lanceur de sorts profanes via lesquelles il peut jeter des sorts de 2e niveau au moins, le niveau effectif ne s''applique qu''à l''une d''entre elles, au choix du personnage.</p>', '<p>Compétences de classe : Acrobaties, Artisanat, Connaissances (Contrées du Mitan Occidentales), Connaissances (géographie), Crochetage, Décryptage, Déplacement silencieux, Désamorçage/sabotage, Détection, Discrétion, Escalade, Escamotage, Évasion, Fouille, Intimidation, Maîtrise des cordes, Natation, Perception auditive, Profession, Psychologie, Renseignement, Saut.</p>', '<p>Aux yeux des elfes d''Evereska, rien n''est plus sacré que les corps de leurs morts. De célèbres souverains, héros et savants de la Maison Fortifiée sont inhumés dans des tombeaux de la région, les elfes considérant que chaque site est inviolable. Malheureusement, lès tombes abritent également des trésors magiques précieux conçus par les elfes d''antan, et ceux-ci attirent bien évidemment de nombreux pillards désireux de se frotter aux défenses des autochtones. Les gardiens funéraires evereskans se chargent donc de l''entretien de ces défenses. Chaque gardien jure de traquer les pilleurs de tombes dans les moindres recoins de Faerûn et de ne rentrer qu''une fois les profanateurs tués.</p>
<p>Roublards/ensorceleurs et rôdeurs/ensorceleurs sont de loin les meilleurs candidats à cette classe de prestige. Cependant, moines, ensorceleurs et magiciens empruntent parfois cette voie. Guerriers, prêtres et paladins satisfont rarement aux conditions magiques et les barbares sont trop violents pour envisager cette carrière.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Gardien Mortuaire Evereskan' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Gardien Mortuaire Evereskan' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 2, 0, 2, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '1', 3, 0, 3, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '2', 3, 1, 3, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '3', 4, 1, 4, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '3', 4, 1, 4, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Devoir sacré', '<p>Le gardien funéraire evereskan bénéficie d''un bonus de sainteté de +2 aux tests de Déplacement silencieux, Discrétion, Renseignements et Survie effectués dans la région d''Evereska. Quand il se trouve dans une tombe evereskane, il bénéficie également d''un bonus de sainteté de +2 aux jets d''attaque et d''un bonus de sainteté égal à son niveau de gardien funéraire evereskan aux jets de dégâts.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Devoir sacré' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Bonus d''esquive', '<p>). A compter du niveau 2, le gardien funéraire evereskan bénéficie d''un bonus d''esquive de +1 à la CA quand il porte une armure légère (ou pas d''armure du tout).'' Ce bonus passe à +2 au niveau 4.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Bonus d''esquive' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Poursuite inlassable', '<p>Quand il poursuit un pillard de tombe evereskane, un gardien funéraire de niveau 2 ou plus conserve le bonus aux tests de Déplacement silencieux, Discrétion, Renseignements et Survie découlant de l''aptitude de devoir sacré, même s''il se trouve au-delà des frontières d''Evereska. Il conserve également les bonus aux jets d''attaque et de dégâts dus à cette aptitude, mais ils ne s''appliquent qu''aux attaques effectuées contre le voleur.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Poursuite inlassable' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Traque accélérée', '<p>A partir du niveau 3, le gardien funéraire evereskan ne subit plus de malus de -5 aux tests de Survie quand il suit une piste à sa vitesse normale. De plus, il subit un malus de -10 (et non de -20) quand il progresse à deux fois sa vitesse de déplacement habituelle tout en suivant une piste.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Traque accélérée' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Gardien silencieux', '<p>Au niveau 5, le gardien funéraire peut se fondre dans son environnement. Après une concentration de 10 minutes visant à se familiariser avec l''endroit, il bénéficie d''un bonus de +4 aux tests de Déplacement silencieux, Détection, Discrétion et Perception auditive tant qu''il reste dans un rayon de 30 mètres de l''endroit auquel il s''est habitué.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Gardien silencieux' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Devoir sacré' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, '+1', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Bonus d''esquive' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Poursuite inlassable' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, '+2', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Bonus d''esquive' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Gardien silencieux' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Traque accélérée' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 1, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 1 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'Contrées du Mitan Occidentales'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'Contrées du Mitan Occidentales');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'géographie'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'géographie');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 7, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 7 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 8, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 8 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 10, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 10 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 11, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 11 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 12, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 12 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 14, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 14 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 18, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 18 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 19, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 19 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 21, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 21 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 22, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 22 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 23, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 23 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 25, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 25 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 26, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 26 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 27, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 27 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 30, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 30 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 31, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 31 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 33, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 33 AND ccomp_precision = '');

-- ===== Hathran

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Hathran', 'H', 2, 4, 10, 2, '<p><strong>Sexe.</strong> Féminin</p>
<p><strong>Région.</strong> Rashéménie</p>
<p><strong>Alignement.</strong> Loyal bon, loyal neutre ou neutre bon</p>
<p><strong>Compétence.</strong> Degré de maîtrise de 4 en Connaissances (folklore local)(Rashéménie)</p>
<p><strong>Dons.</strong> Ethran, Prestige</p>
<p><strong>Sorts.</strong> Faculté de lancer des sorts de magie divine ou profane de 4e niveau</p>
<p><strong>Divinité tutélaire.</strong> Chauntéa, Mailikki ou Mystra</p>
<p><strong>Spécial.</strong> La candidate doit être membre des Sorcières de Rashéménie et ne peut posséder qu’Écriture de parchemins en qualité dé don de création d’objets</p>', '<p>Les hathrans sont formées au maniement du fouet. Par contre, elles ne reçoivent aucune formation pour ce qui est des autres armes et des bouchers. Enfin, elles ne sont pas formées au port des.armures.</p>', '<p>À chaque niveau d''hathran, le personnage obtient un niveau effectif de jeteur de sorts pour une de ses classes de lanceur de sorts précédentes (via laquelle il est capable de lancer des sorts de 4e niveau au moins). Il obtient les sorts par jour et le niveau de lanceur de sorts d''un personnage de son niveau effectif. Par contre, il ne gagne aucun des autres avantages accompagnant habituellement ce niveau (dons de métamagie ou de création d''objets supplémentaires, meilleure chance de repousser ou d''intimider les morts-vivants, etc.). Si l''hathran possède plusieurs classes de lanceur de sorts via lesquelles elle peut jeter des sorts de 4e niveau au moins, le niveau effectif ne s''applique qu''à l''une d''entre elles, au choix du personnage.</p>
<p>De plus, une courte liste de sorts est ajoutée à la liste du personnage pour ce qui est des classes lui permettant de jeter des sorts de 4e niveau.</p>', '<p>Compétences de classe : Art de la magie, Artisanat, Concentration, Connaissances (au choix), Diplomatie, Langue, Natation, Profession, Représentation, Survie.</p>', '<p>Dans la lointaine contrée de Rashéménie, une puissante communauté de jeteuses de softs divins et profanes s''efforce de protéger son peuple des déprédations de Thay et de mener la vie spirituelle de ses ouailles. Ces hathrans, ou Sorcières de Rashéménie comme on. les appelle plus couramment, constituent en quelque sorte l''éminence grise de leur royaume oriental. Leur puissance mystique semble ne connaître aucune limite. Les hathrans qui voyagent en dehors de la Rashéménie portent en permanence un masque visant a dissimuler leur visage aux yeux du monde extérieur.</p>
<p>La plupart des hathrans sont issues des classes d''ensorceleur et de prêtre. Bardes, magiciens et druides sont rares en leur sein. Par contre, paladins et rôdeurs n''y ont aucune place. Quelle que soit leur classe d''origine, les hathrans considèrent que les rivalités entre lanceurs de sorts n''ont aucun sens, aussi n''existe-t-il pas de tension entre la caste profane et la branche divine.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Hathran' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Hathran' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 0, 2, 2, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '1', 0, 3, 3, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '1', 1, 3, 3, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '2', 1, 4, 4, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '2', 1, 4, 4, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 6, '3', 2, 5, 5, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 6);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 7, '3', 2, 5, 5, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 7);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 8, '4', 2, 6, 6, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 8);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 9, '4', 3, 6, 6, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 9);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 10, '5', 3, 7, 7, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 10);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Bonus de Prestige', '<p>Dès le niveau 1, Phathran bénéficie d''un bonus de +2 en Prestige pour ce qui est de recruter un compagnon d''armes. Cependant, celui-ci doit être rashémi et être une femme pourvue du don Ethran ou un homme doté d''un niveau de barbare au moins.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Bonus de Prestige' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Magie des esprits rashémie', '<p>Les hathrans jouissent d''une grande souplesse dans l''utilisation de leur magie. Dès le niveau 1, une hathran qui prépare ses sorts peut lancer tout sort connu de manière spontanée à la place d''un sort de même niveau préparé, même s''il ne se trouve pas sur la même liste de sorts que celui qui est remplacé. Si l''hathran ne prépare normalement pas ses sorts, elle peut utiliser ses dons de métamagie sans tenir compte du temps d''incantation accru nécessaire. Un tel sort mobilise cependant un emplacement de sort d''un niveau plus élevé (cf. la description de chaque don). Pour user de ce pouvoir, l''hathran doit se situer en Rashéménie. Elle n''a pas de limite d''utilisation quotidienne.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Magie des esprits rashémie' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Tabou', '<p>Au sein de la société rashémie, la création des objets magiques est réservée aux lanceurs de sorts mâles, Les hathrans ne peuvent donc prendre aucun don de création d''objets, à l''exception d''Écriture de parchemins.</p>', NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Tabou' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Dialogue spirituel', '<p>Au niveau 2, l''hathran gagne le pouvoir de communiquer avec les créatures pourvues du sous-type esprit. Ce pouvoir fonctionne quelle que soit la langue utilisée par le personnage et l''esprit. L''hathran bénéficie également d''un bonus de +2 aux tests de compétence et de caractéristique relevant du Charisme effectués quand elle traite avec un esprit.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Dialogue spirituel' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Crainte de la wychlaran', '<p>Au niveau 3, l''hathran dégage une aura de puissance et de commandement telle que ses compatriotes rashémis ont du mal à se dresser contre elle. Les individus-originaires de la région Rashéménie et dont le niveau est inférieur ou égal à celui de l''hathran subissent-un malus de -2 aux jets d''attaque et aux tests de compétence opposés effectués contre le personnage. Ce malus passe à -4 au niveau 7 et à -6 au niveau 10.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Crainte de la wychlaran' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Magie des esprits universelle', '<p>A partir du niveau 3, l''affinité de l''hathran à la magie des esprits est telle qu''elle peut communier avec les esprits qui se trouvent en dehors de la Rashéménie. Elle peut donc utiliser son pouvoir de magie des esprits rashémie en dehors du pays, 1 fois par jour. Elle peut utiliser ce pouvoir 2 fois par jour à partir du niveau 6 et 3 fois par jour à compter du niveau 9,</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Magie des esprits universelle' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Concordat spirituel', '<p>À partir du niveau 4, l''hathran lance les différentes versions du sort allié d''outreplan avec un bonus de +1 au niveau,de lanceur de sorts.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Concordat spirituel' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Chef de cercle', '<p>Au niveau 5, l''hathran peut devenir un chef de cercle et agir en qualité de focaliseur dans le cadre de la magie de cercle rashémie.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Chef de cercle' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Dominion spirituel', '<p>A partir du niveau 8, l''hathran lance les différentes versions du sort contrat avec un bonus de +1 au niveau, de lanceur de sorts.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Dominion spirituel' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Chef de grand cercle', '<p>Au niveau 10, l''hathran maîtrise l''art. de la magie de cercle et peut prendre la tête de vastes cercles. Un grand cercle peut compter jusqu''à neuf assistants (contre cinq habituellement).</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Chef de grand cercle' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Bonus de Prestige' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Magie des esprits rashémie' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Tabou' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Dialogue spirituel' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, '-2', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Crainte de la wychlaran' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, '1 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Magie des esprits universelle' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Concordat spirituel' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Chef de cercle' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 6, '2 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Magie des esprits universelle' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 6);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, '—4', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Crainte de la wychlaran' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 8, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Dominion spirituel' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 8);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 9, '3 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Magie des esprits universelle' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 9);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Chef de grand cercle' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, '-6', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Crainte de la wychlaran' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 2, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 2 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 4, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 4 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'au choix'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'au choix');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 13, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 13 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 24, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 24 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 26, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 26 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 32, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 32 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 34, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 34 AND ccomp_precision = '');

-- ===== Hiérophante magefeu

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Hiérophante magefeu', 'HM', 2, 4, 10, 2, '<p><strong>Compétences.</strong> Degré de maîtrise de 12 en Art de la magie, degré de maîtrise de 24 en Concentration, degré de maîtrise de 12 en Connaissances (mystères)</p>
<p><strong>Dons.</strong> Arme de prédilection (magefeu), Endurance, Porteur du magefeu, Porteur du magefeu épique</p>', '<p>Le hiérophante magefeu ne reçoit aucune formation supplémentaire au maniement des armes et des boucliers, ni au port des armures.</p>', NULL, '<p>Compétences de classe : Art de la magie, Artisanat, Bluff, Concentration, Connaissances (mystères), Déguisement, Intimidation, Premiers secours, Profession, Psychologie, Survie.</p>', '<p>Bien que de nombreux personnages se qualifient de maîtres du magefeu, l''énergie de la Toile à l''état brut, ces individus font figure d''étudiants à côté du hiérophante magefeu. Ce maître de la Toile découvre des moyens visant à contrôler et à façonner le magefeu que les simples mortels pourraient difficilement comprendre.</p>
<p>Le hiérophante magefeu n''a pas de parcours précis, mais il est généralement rompu à l''utilisation'' du magefeu. La classe de prestige de modeleur de magefeu) offre une voie parfaite aux hiérophantes magefeu en herbe.</p>
<p>Etant donné la nature solitaire des utilisateurs du magefeu, il n''est guère surprenant que la plupart des hiérophantes magefeu vivent en marge de la société. Ceux qui quittent leur repaire secret pour les régions sauvages et les autres plans usent généralement de déguisement et autres subterfuges pour parvenir à leurs fins.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Hiérophante magefeu' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Hiérophante magefeu' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 0, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '0', 0, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '0', 0, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '0', 0, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '0', 0, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 6, '0', 0, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 6);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 7, '0', 0, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 7);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 8, '0', 0, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 8);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 9, '0', 0, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 9);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 10, '0', 0, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 10);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Absorption de charge d''objet suprême', '<p>Le hiérophante magefeu peut absorber un certain nombre de charges d''un objet qu''il touche (ce qui inclut les objets à usage unique, comme les potions et les parchemins) et convertir l''énergie ainsi dérobée en niveaux d''énergie magefeu stockés. Le personnage peut donc absorber un nombre de charges égal à son bonus de Charisme (minimum 1), mais pas plus que l''objet n''en contient. (Chaque sort d''un parchemin compte pour 1 charge.) Un objet totalement absorbé n''a plus de propriétés magiques. Une potion ne sera plus que de l''eau et un parchemin sera parfaitement vierge. Une créature portant un tel objet a droit à un jet de Volonté (DD 20 +1/2 niveau du hiérophante magefeu + son .modificateur de Charisme) pour annuler l''effet.</p>', 'mag', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Absorption de charge d''objet suprême' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Guérison à distance', '<p>Au niveau 2, lé hiérophante magefeu peut libérer l''énergie magefeu stockée pour soigner une créature située dans un rayon de 7,50 mètres + 1,50 mètre/2 niveaux de lanceur de sorts. Pour utiliser ce pouvoir, le personnage doit réussir une attaque de contact à distance. La quantité de soins prodigués est normale (2 points par niveau de magefeu, ou 1d4+l points par niveau de magefeu si le personnage a le pouvoir de modeleur de magefeu soins améliorés).</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Guérison à distance' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Rapidité', '<p>Une fois par jour, un hiérophante magefeu de niveau 3 ou plus peut sacrifier les niveaux d''énergie magefeu accumulés pour accélérer ses actions, comme s''il se lançait rapidité. Il fixe le nombre de niveaux dépensés au moment où il active ce pouvoir. Chaque niveau utilisé lui permet donc d''agir sous rapidité pendant 1 round. De plus, le personnage crépite de lumière tant que le pouvoir fait effet. Le hiérophante magefeu peut user de ce pouvoir 2 fois par jour au niveau 6 et 3 fois par jour au niveau 9.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Rapidité' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Dons supplémentaires', '<p>Aux niveaux 4 et 8, le hiérophante magefeu gagne un don supplémentaire choisi parmi la liste qui suit : Arme de prédilection épique (magefeu), Guérison accélérée, Parade exceptionnelle*,- Parade infinie*. Porteur du magefeu épique". Renvoi de flèches*. Résistance aux énergies destructives, Robustesse épique, Talent épique (Concentration). Le personnage doit remplir les conditions d''obtention de chaque don.</p>
<p>* Le personnage ne tient pas compte de la condition de Science du combat à mains nues pour ces dons.</p>', NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Dons supplémentaires' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Absorption des objets permanents suprême', '<p>Au niveau 5, le hiérophante magefeu peut absorber la puissance d''objets permanents d''un simple contact (action simple).''Un objet qui crée un effet magique (comme des bottes de rapidité} perd sa propriété pendant 24 heures et le personnage gagne un nombre de niveaux d''énergie magefeu égal au niveau de lanceur de sorts de l''objet. Une créature portant un tel objet à droit à un jet de Volonté (DD 20 + 1/2 niveau du hiérophante magefeu +"son modificateur de Charisme) pour annuler l''effet. Si toutes les propriétés magiques d''un objet sont absorbées, il n''en reste pas moins un objet magique.au regard des jets de sauvegarde, etc.</p>', 'mag', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Absorption des objets permanents suprême' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Réserve de magefeu', '<p>Au niveau 7, le hiérophante magefeu apprend à stocker les niveaux d''énergie magefeu dans une réserve spéciale. Ces niveaux d''énergie ne comptent pas dans le cadre de sa capacité de stockage habituelle, mais il est impossible. d''y avoir recours pour alimenter des effets de magefeu sans les sortir de cette réserve. Les niveaux d''énergie magefeu placés en réserve n''ont pas d''aura magique, aussi n''est-il pas possible de cerner la véritable nature du personnage en les-détectant. Pour ''mettre des niveaux d''énergie magefeu en réserve, il faut entreprendre une action complexe. Cela vaut également si le personnage souhaite les en extraire pour les inclure à sa capacité de stockage normale. Le personnage peut mettre en réserve un nombre de niveaux d''énergie magefeu égal à son niveau de hiérophante magefeu plus son bonus de Constitution (le cas échéant).</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Réserve de magefeu' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Rayonnement de magefeu', '<p>Au niveau 10, le hiérophante magefeu peut remplacer une attaque de magefeu normale par un rayonnement de magefeu. La portée reste la même mais le personnage effectue une attaque de contact. L''énergie magefeu explose en un rayonnement de 1,50 mètre de rayon centrée sur le point visé, infligeant alors les dégâts correspondants aux créatures situées dans la zone. Les cibles ont droit à un jet de Réflexes (DD 20 + 1/2 niveau de hiérophante magefeu + son modificateur de Charisme) pour réduire les dégâts de moitié. Le personnage peut effectuer autant d''attaques de rayonnement que d''attaques normales au cours du round, mais il ne peut recourir à ce pouvoir qu''au cours d''un round par jour. Par la suite, tous les 5 niveaux, il peut l''utiliser 1 round de plus chaque jour (2 rounds au niveau 15, 3 rounds au niveau 20, etc.).</p>
<p>Si le personnage a l''aptitude de modeleur de magefeu maelstrôm de feu, le rayonnement est de 3 mètres de rayon.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Rayonnement de magefeu' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Absorption de charge d''objet suprême' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Guérison à distance' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, '1 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Rapidité' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Dons supplémentaires' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Absorption des objets permanents suprême' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 6, '1 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Rapidité' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 6);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Réserve de magefeu' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 8, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Dons supplémentaires' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 8);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 9, '3 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Rapidité' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 9);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Rayonnement de magefeu' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 2, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 2 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 3, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 3 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 4, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 4 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'mystères'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'mystères');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 9, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 9 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 23, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 23 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 28, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 28 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 30, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 30 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 34, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 34 AND ccomp_precision = '');

-- ===== Incantatrixe

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Incantatrixe', 'I', 2, 4, 10, 2, '<p><strong>Compétence.</strong> Degré de maîtrise de 8 en Art de la magie, degré de maîtrise de 4 en Concentration, degré de maîtrise de 8 en Connaissances (mystères)</p>
<p><strong>Dons.</strong> Volonté de fer, un don de métamagie au choix</p>
<p><strong>Sorts.</strong> Faculté de lancer des sorts de magie profane de 3e niveau</p>
<p><strong>Spécial.</strong> La candidate ne peut prendre Abjuration en guise d’école interdite</p>', NULL, '<p>A chaque niveau d''incantatrixe, le personnage obtient un niveau effectif de jeteur de sorts pour une de ses classes de lanceur de sorts profanes précédentes (via laquelle il est capable de lancer des sorts de 3e niveau au moins). Il obtient les sorts par jour et le niveau de lanceur de sorts d''un personnage de son niveau effectif. Par contre, il ne gagne aucun des autres avantages accompagnant habituellement ce niveau (dons de métamagie ou de création d''objets supplémentaires, aptitudes de barde ou d''assassin, etc.). Si l''incantatrixe possède plusieurs classes de lanceur de sorts profanes via lesquelles elle peut jeter des sorts de 3e niveau au moins, le niveau effectif ne s''applique qu''à l''une d''entre elles, au choix du personnage.</p>
<p><strong>Don de métamagie supplémentaire</strong>. Aux niveaux 1, 4, 7 et 10, l''incantatrixe peut choisir un don de métamagie en qualité de don supplémentaire. Il lui faut néanmoins satisfaire aux conditions du don voulu.</p>', '<p>Compétences de classe : Art de la magie, Artisanat, Concentration, Connaissances (mystères), Connaissances (plans), Intimidation, Premiers secours, Profession.</p>', '<p>A Faerûn, les incantatixes sont les maîtresses de la métamagie et se consacrent à l''étude de sorts et de techniques qui affectent d''autres sorts. Elles manipulent la magie sous sa forme brute, la façonnant à l''image de leurs souhaits et non des lois magiques habituelles. Elles appliquent donc leur compréhension intime de la métamagie de manière à altérer les sorts que lancent leurs alliés, les sorts jetés à partir de baguettes et de bâtons, voire les sorts déjà lancés.</p>
<p>La plupart des incantatrixes sont des magiciennes et des ensorceleuses de talent, mais cela n''empêche pas quelques bardes d''étudier ce type de magie. Les lanceurs de sorts divins se tournent rarement vers cette classe, sans doute parce que leur magie est teintée d''influence divine et donc, moins « pure » que la magie profane comme aiment à le dire les incantatrixes elles-mêmes. La plupart des incantatrixes sont des femmes et les quelques hommes qui empruntent cette voie sont qualifiés d''incantatars.</p>
<p>Les PNJ incantarixes sont généralement indépendants,.mais certains se réunissent''pour affronter un problème commun. N''appréciant guère les intrusions planaires dans le plan Matériel, elles voient la destruction des portails actifs ''comme une_ véritable responsabilité. En conséquence, une incantatrixe constitue toujours une bonne source de renseignements quant aux portails fonctionnels d''une région donnée. Étant donné que ces personnages ont des facultés magiques offensives très limitées, ils évitent généralement les affrontements et voyagent en compagnie d''individus qui compensent leur faiblesse.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Incantatrixe' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Incantatrixe' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 0, 0, 2, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '1', 0, 0, 3, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '1', 1, 1, 3, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '2', 1, 1, 4, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '2', 1, 1, 4, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 6, '3', 2, 2, 5, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 6);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 7, '3', 2, 2, 5, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 7);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 8, '4', 2, 2, 6, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 8);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 9, '4', 3, 3, 6, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 9);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 10, '5', 3, 3, 7, 1, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 10);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Études spécialisées', '<p>Au niveau 1, l''incantatrixe renonce a une école de magie pour s''attacher davantage aux autres. Elle ne peut choisir Abjuration ou Divination en guise d''école interdite. Cette dernière vient en plus de toute école interdite choisie en cas de spécialisation préalable. Ainsi, une magicienne spécialisée qui emprunte cette classe de prestige a trois écoles interdites et non deux.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Études spécialisées' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Métamagie coopérative', '<p>Au niveau 1, l''incantatrixe gagne le pouvoir d''appliquer n''importe lequel de ses dons de métamagie (à l''exception d''Incantation rapide, Incantation silencieuse et Incantation statique) à un sort lancé par un allié consentant. Ce dernier n''a pas besoin de préparer le sort sous forme de métamagie ni de mobiliser un emplacement de sort d''un niveau supérieur. En effet, l''incantatrixe modifie simplement le sort lors de l''incantation. A l''instar d''une incantation normale, l''utilisation de ce pouvoir se fait au prix d''une action simple qui provoque une attaque d''opportunité. L''incantatrixe peut néanmoins user de la compétence Concentration comme si elle lançait un sort sur la défensive. Elle doit préparer une action pour user de métamagie coopérative lorsque son allié commence l''incantation et se trouver dans une case adjacente à celui-ci. L''incantatrixe doit effectuer un test d''Art de la magie (DD 18 + [3 X niveau de sort modifié]) pour réussir. Le « niveau de sort modifié » est le niveau de l''emplacement de sort qui devrait être mobilisé s''il était préparé à l''aide du don de métamagie appliqué. Les dons de métamagie utilisés par le lanceur de sorts comptent également dans ce calcul. Par exemple, si l''incantatrixe applique le don Quintessence des sorts à l''éclair multiple d''un allié, le niveau de sort modifié est égal à 9 (6 pour le sort, +3 pour le don Quintessence des sorts) et le DD est égal à 18 + (3 X 9) = 45. Si elle applique le même don à l''éclair multiple silencieux d''un allié, le niveau de sort modifié est égal à 10 et le DD du test d''Art de la magie est égal à 48. L''incantatrixe peut utiliser ce pouvoir un nombre de fois par jour égal à 3 + son modificateur d''Intelligence.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Métamagie coopérative' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Effet métamagique', '<p>À partir du niveau 3, l''incantatrixe peut tenter d''appliquer n''importe lequel de ses dons à un effet magique persistant déjà en place. Par exemple, elle peut user d''Extension de durée sur un mur de force ou de Quintessence des sorts pour augmenter les dégâts d''une brume mortelle. Pour utiliser ce pouvoir, l''incantatrixe doit se trouver aii sein de l''effet ou dans une case adjacente à celui-ci et réussir un test d''Art de la magie (DD 18 + [3 x niveau de sort modifié]) pour réussir. Le « niveau de sort modifié » est le niveau de l''emplacement de sort qui devrait être mobilisé s''il était préparé à l''aide du don de métamagie appliqué. Les dons de métamagie appliqués à l''effet durant l''incantation (Incantation rapide. Incantation silencieuse ou Incantation statique) ne comptent pas ce calcul. Par contre, il faut tenir compte des dons de métamagie qui modifient l''effet du sort (comme Extension d''effet. Extension de portée ou Extension de zone d''effet).</p>
<p>Par exemple, si l''incantatrixe applique le don Extension de durée à un mur de feu, le niveau de sort modifié est égal à 5 (4 pour le sort, +1 pour le don Extension de durée) et le DD est égal à 18 + (3 X 5) = 33. Si le mur de feu a été lancé à l''aide du don Incantation silencieuse, le DD est toujours égal à 33 car ce don s''applique au niveau de l''incantation du sort, et non à l''effet.</p>
<p>Par contre, si elle applique à un mur de feu qui bénéficie déjà d''Extension d''effet, le niveau de sort modifié est égal à % et le DD du test d''Art de la magie est égal à 39.</p>
<p>L''incantatrixe peut utiliser ce pouvoir un nombre de fois par jour égal à 3 + son modificateur d''Intelligence. L''utilisation de ce pouvoir se fait au prix d''une action complexe qui provoque une attaque d''opportunité.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Effet métamagique' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Potentiel métamagique', '<p>Au niveau 5, l''incantatrixe gagne le pouvoir d''appliquer n''importe lequel de ses dons de métamagie à l''effet d''un objet à potentiel magique (généralement une baguette). Pour utiliser ce pouvoir, elle doit également posséder le don de création d''objets nécessaire à la fabrication de l''objet à potentiel magique utilisé. User de potentiel métamagique consomme un nombre de charges supplémentaires de l''objet égal au nombre de niveaux de sort que le don ajouterait au sort. Par exemple, l''incantatrixe peut user d''Incantation rapide pour modifier un sort jeté via une baguette en dépensant 5 charges (1 + 4 pour l''augmentation d''emplacement de sort). De même, elle peut y appliquer Extension d''effet en sacrifiant 3 charges, ou Incantation silencieuse en utilisant 2 charges. Appliqué à un objet à potentiel magique, le don Incantation statique n''offre aucun avantage.</p>
<p>L''incantatrixe ne saurait recourir à ce pouvoir quand elle utilise un objet à potentiel magique dénué de charges, comme un chapelet de prières courant.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Potentiel métamagique' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Vol de concentration', '<p>Au niveau 6, l''incantatrixe gagne le pouvoir de prendre le contrôle d''un sort requérant concentration (comme image accomplie, implosion ou nuée grouillante). Le lanceur de sorts adverse doit toutefois se trouver dans un rayon de 9 mètres. Si la cible est consentante, le transfert de concentration se fait automatiquement. Autrement, le personnage et son adversaire effectuent un test de niveau de lanceur de sorts opposé. Un lanceur de sorts divins bénéficie d''un bonus de +2 au test. Si l''incantatrixe l''emporte, elle prend le contrôle du sort tant qu''elle reste concentrée ou jusqu''à expiration de l''effet. Le sort agit alors comme si l''incantatrixe l''avait jeté (même si ce n''est pas le cas), mais les variables numériques déterminées lors de l''incantation (ce qui inclut le niveau de lanceur de sorts) ne bougent pas. Le lanceur de sorts original peut être affecté par son effet, mais il bénéficié alors d''un bonus de circonstances de +2 aux jets de sauvegarde contre celui-ci (le cas échéant). Si l''incantatrixe relâche sa concentration avant la fin du sort, son auteur peut en reprendre le contrôle en réussissant un test de niveau de lanceur de sorts (DD 15 + niveau de sort). En cas d''échec, personne ne contrôle plus le sort.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Vol de concentration' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Métamagie instantanée', '<p>Une fois par jour, une incantatrixe de niveau 7 ou plus peut appliquer l''un de ses dons de métamagie à un sort sans le modifier à l''avance (si elle prépare ses sorts) ou sans en augmenter le temps d''incantation (si elle ne prépare pas ses sorts), Ainsi, une magicienne lancera un sort comme si elle l''avait préparé et modifié à l''aide du don de métamagie choisi, mais sans mobiliser un emplacement de sort d''un niveau supérieur. De son côté, une ensorceleuse lancera son sort modifié sans allonger, le temps d''incantation. Une incantatrixe de niveau 9 ou 10 peut utiliser ce pouvoir 2 fois par jour. L''incantatrixe ne peut pas utiliser ce pouvoir si, en temps normal, le sort modifié utiliserait un emplacement de sort d''un niveau auquel elle n''a pas accès.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Métamagie instantanée' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Capture de sort', '<p>Dès le niveau 8, l''incantatrixe peut tenter de prendre le contrôle d''un effet persistant créé par un autre lanceur de sorts. L''effet ne doit pas relever de la concentration mais dépendre du contrôle de son auteur (comme arme spirituelle ou convocation de monstres, mais pas brume acide ou mur de feu ). De plus, l''effet (mais pas nécessairement le lanceur de sorts), doit se trouver dans un rayon de 9 mètres de l''incantatrixe. La cible et le personnage doivent effectuer un test de niveau de lanceur de sorts opposé. Un lanceur de sorts divins bénéficie d''un bonus de +2 au test. Si l''incantatrixe l''emporte, elle prend le contrôle du sort jusqu''à expiration de l''effet. Le sort agit alors comme si l''incantatrixe l''avait jeté (même si ce n''est pas le cas), mais les variables numériques déterminées lors de l''incantation (ce qui inclut le niveau de lanceur de sorts) ne bougent pas. Le lanceur de sorts original . peut être affecté par son effet, mais il bénéficie alors d''un bonus de circonstances de +2 aux jets de sauvegarde contre celui-ci (le cas échéant). S''il est possible de mettre un terme au sort et que l''incantatrixe le souhaite, elle doit effectuer un second test de niveau de lanceur de sorts opposé. En cas d''échec, le sort continue de faire effet et celui qui l''a jeté en reprend le contrôle.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Capture de sort' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Science de la métamagie', '<p>Au niveau 10, l''incantatrixe maîtrise à ce, point la métamagie que lorsqu''elle utilise un don de métamagie, le niveau de sort requis (le cas échéant) est réduit de 1 point (pour un minimum de +1). Par exemple, une incântatrixe/magicienne préparera une boule de feu à incantation rapide comme un sort de 6e niveau et non comme un sort de 7e niveau.</p>
<p>Cet avantage s''applique également aux autres aptitudes de classe de l''incantatrixe. Ainsi, le DD de ses pouvoirs d''effet métamagique et de métamagie coopérative est réduit selon les dons de métamagie impliqués. Enfin, elle sacrifie moins de charges quand elle use de potentiel métamagique.</p>
<p>Dons liés aux aptitudes</p>
<p><strong>Effet métamagique</strong> : Effet amélioré (épique)</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Science de la métamagie' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Don de métamagie supplémentaire', NULL, NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Don de métamagie supplémentaire' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Don de métamagie supplémentaire' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Études spécialisées' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Métamagie coopérative' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Effet métamagique' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Don de métamagie supplémentaire' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Potentiel métamagique' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 6, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Vol de concentration' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 6);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Don de métamagie supplémentaire' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, '1 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Métamagie instantanée' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 8, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Capture de sort' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 8);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 9, '2 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Métamagie instantanée' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 9);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Don de métamagie supplémentaire' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Science de la métamagie' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 2, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 2 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 4, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 4 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'mystères'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'mystères');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'plans'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'plans');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 23, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 23 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 28, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 28 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');

-- ===== Justiciar de Tyr

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Justiciar de Tyr', 'JT', 2, 8, 10, 2, '<p><strong>Alignement.</strong> Loyal bon</p>
<p>Bonus de base à l’attaque. +5</p>
<p><strong>Compétence.</strong> Degré de maîtrise de 4 en Connaissances (folklore local [au choix]), degré de maîtrise de 6 en Connaissances (religion), degré de maîtrise de 7 en Diplomatie</p>
<p><strong>Sorts.</strong> Faculté de lancer des sorts de magie divine de 2e niveau</p>
<p><strong>Divinité tutélaire.</strong> Tyr</p>', '<p>Le justiciar de Tyr est formé au maniement des armes courantes et des armes de guerre, mais pas à celui des boucliers. Il n''est pas formé au port des armures.</p>', '<p>A chaque niveau de justiciar de Tyr, le personnage obtient un niveau effectif de jeteur de sorts pour une de ses classes de lanceur de sorts divins précédentes (via laquelle il est capable de lancer des sorts de V niveau au moins). Il obtient -les sorts par jour et le niveau de lanceur de sorts d''un personnage de son niveau effectif. Par contre, il ne gagne aucun des autres avantages accompagnant habituellement ce niveau (dons de métamagie ou de création d''objets supplémentaires, meilleure chance de repousser les morts-vivants, etc.). Si le justiciar de .Tyr possède plusieurs classes de lanceur de sorts divins via lesquelles il peut jeter des sorts de 2e niveau au moins, le niveau effectif ne s''applique qu''à l''une d''entre elles, au choix du personnage.</p>', '<p>Compétences de classe : Art de la magie, Artisanat, Concentration, Connaissances (folklore local), Connaissances (mystères), Connaissances (plans), Connaissances (religion), Diplomatie, Premiers secours, Profession.</p>', '<p>Au titre de serviteurs du dieu de la justice, les prêtres de Tyr sont censés épouser la loi et l''ordre qui incarnent les préceptes du Dieu Manchot. Les justiciars constituent l''élite des serviteurs mortels de Tyr et ils symbolisent les attributions de leur dieu. Ils combattent le désordre et l''injustice avec autant de ferveur qu''un paladin lutte contre le Mal, ne faisant pas de quartier dans leur quête visant à offrir un ordre parfait à Faerûn. Certains justiciars sont assignés à de grandes villes, où la présence des fidèles de Tyr est forte et où ils servent de juges ou de magistrats. D''autres sont envoyés dans les régions frontalières comme le Nord où ils apportent un semblant d''ordre et de loi dans les communautés qui parsèment les zones sauvages de Faerûn. Les justiciars de haut niveau se rendent parfois dans les plans du Chaos pour y frapper des Extérieurs comme les slaads et les démons. Prêtres et paladins constituent le gros des justiciars, mais certains sont des guerriers/prêtres, voire de simples rôdeurs. Les roublards/prêtres sont très rares, mais il en existe quelques-uns. Par contre, leurs rangs n''abritent pas de moines, d''ensorceleurs ou de magiciens multiclassés. En raison des restrictions d''alignement, barbares, bardes et druides n''empruntent jamais cette voie.</p>
<p>Les paladins de Tyr peuvent se multiclasser en toute liberté en justiciar de Tyr.</p>
<p><strong>Anciens Justiciars de Tyr.</strong></p>
<p>Un justiciar de Tyr violant son alignement ou commettant un acte injuste .(comme un vol, une agression, ou le meurtre d''un innocent) perd ses facultés de lanceur de sorts et ses aptitudes de classe de prestige (à l''exception de sa formation au maniement des armes et du pouvoir de savoir bureaucratique). Il récupère son statut et ses aptitudes s''il fait acte de contrition.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Justiciar de Tyr' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Justiciar de Tyr' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 0, 2, 2, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '1', 0, 3, 3, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '2', 1, 3, 3, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '3', 1, 4, 4, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '3', 1, 4, 4, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 6, '4', 2, 5, 5, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 6);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 7, '5', 2, 5, 5, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 7);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 8, '6', 2, 6, 6, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 8);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 9, '6', 3, 6, 6, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 9);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 10, '7', 3, 7, 7, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 10);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Châtiment de l''anarchie', '<p>Dès le niveau 1, le justiciar de Tyr peut tenter de châtier un adversaire chaotique au moyen d''une attaque au corps à corps normale, 1 fois par jour. Il ajoute son bonus de Charisme (le cas échéant) au jet d''attaque et inflige 1 point de dégâts supplémentaire par niveau de justiciar de Tyr. Par exemple, un justiciar de Tyr de niveau 4 armé d''une épée longue infligera 1d8+4 points de dégâts, plus tout bonus de Force ou d''effet magique applicable. Si le justiciar de Tyr châtie accidentellement une créature qui n''est pas chaotique, le pouvoir n''a aucun effet, mais il est tout de même dépensé pour la journée. Ce pouvoir est utilisable 2 fois par jour au niveau 5 et 3 fois par jour au niveau 10.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Châtiment de l''anarchie' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Détection du Chaos', '<p>Au niveau 1, le justiciar de Tyr peut .user de détection du Chaos, à volonté (niveau de lanceur de sorts égal au niveau de lanceur de sorts divins du personnage).</p>', 'mag', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Détection du Chaos' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Savoir bureaucratique', '<p>Si la lutte contre les forces du Chaos reste la fonction principale du justiciar de Tyr, il est également censé connaître les mécanismes juridiques qui régissent les régions civilisées de Faerûn. Au niveau 2, il bénéficie d''un bonus égal à son niveau de justiciar de Tyr aux tests de Connaissances et de Renseignements en rapport avec le droit et les procès (savoir s''il est légal de porter une arme en ville, comment se comporter à la cour, etc.). Il bénéficie également de ce bonus aux tests de compétence ou de caractéristique liés au Charisme quand il s''agit de débattre de sujets juridiques.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Savoir bureaucratique' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Incantation axiomatique', '<p>Quand le justicier de Tyr atteint le niveau 3, la cause qui l''anime augmente la puissance de ses sorts. Le DD de sauvegarde de ses sorts relevant du registre de la Loi augmente de +1 (le cas échéant). Ce bonus passe à +2 au niveau 9.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Incantation axiomatique' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Détection du mensonge', '<p>Au niveau 4, le justiciar de Tyr peut user de détection du mensonge, 1 fois par jour (niveau de lanceur de sorts égal au niveau de lanceur de sorts divins du personnage).</p>', 'mag', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Détection du mensonge' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Faveur du dieu manchot', '<p>Tyr veille sur ses plus fidèles serviteurs; les protégeant ainsi des ravages dû désordre et de l''anarchie. Au niveau 5, le justiciar de Tyr bénéficie d''un bonus égal à son bonus de Charisme (le cas échéant) aux jets de sauvegarde contre les sorts accompagnés du registre du Chaos et contre les pouvoirs magiques et surnaturels des Extérieurs chaotiques. Ce bonus se cumule avec celui du pouvoir de grâce divine. Un paladin/justiciar ajoute donc deux fois son bonus de Charisme aux jets de sauvegardé contre les effets chaotiques.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Faveur du dieu manchot' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Calme de l''ordre', '<p>Sur simple contact, un justiciar de niveau 7 ou plus peut, 1 fois par jour, annuler l''un des effets suivants : héroïsme, rage, symbole d''aliénation, un effet de terreur ou l''aptitude de rage de berserker du barbare. Pour utiliser ce pouvoir contre une cible qui n''est pas consentante, le justiciar doit réussir une attaque de contact au corps à corps. La cible a alors droit à un jet de Volonté (DD 10 + 1/2 niveau de justiciar de Tyr + son modificateur de Charisme) pour éviter l''effet.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Calme de l''ordre' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Lame de justice', '<p>Au niveau 8, le justiciar de Tyr peut imprégner son arme de corps à corps du pouvoir de la justice. Une fois par jour et par point de bonus en Charisme (1 fois par jour minimum), le justiciar peut affubler son arme de corps à corps de la propriété spéciale axiomatique. (+2d6 points de dégâts contre les adversaires chaotiques). Si l''arme du personnage bénéficie déjà de cette amélioration, il n''en tire aucun avantage. Chaque utilisation du pouvoir correspond à une action libre et l''effet dure 1 round.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Lame de justice' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Aura de loi absolue', '<p>Au niveau 10, le justiciar de Tyr est un tel symbole d''ordre et de justice que le Chaos recule devant lui. Il est en permanence entouré par un effet de rejet du Chaos. S''il renvoie un Extérieur chaotique dans son plan d''origine ou dissipe un enchantement accompagné du registre du Chaos, l''aura disparaît temporairement. Il peut néanmoins la réactiver au prix d''une action libre dès son tour de jeu suivant.</p>
<p>Dons liés aux aptitudes</p>
<p><strong>Châtiment de l’anarchie</strong> : Coup axiomatique (épique)</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Aura de loi absolue' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, '1 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Châtiment de l''anarchie' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Détection du Chaos' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Savoir bureaucratique' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, '+1', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Incantation axiomatique' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Détection du mensonge' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, '2 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Châtiment de l''anarchie' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Faveur du dieu manchot' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Calme de l''ordre' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 8, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Lame de justice' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 8);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 9, '+2', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Incantation axiomatique' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 9);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Aura de loi absolue' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 2, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 2 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 4, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 4 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'folklore local'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'folklore local');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'mystères'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'mystères');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'plans'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'plans');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'religion'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'religion');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 13, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 13 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 28, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 28 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');

-- ===== Lanceur de Runes

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Lanceur de Runes', 'LR', 2, 8, 10, 2, '<p><strong>Compétences.</strong> Degré de maîtrise de 8 en Art de la magie, degré de maîtrise de 8 en Artisanat (calligraphie, ferronnerie, taille des pierres fines ou précieuses, travail de la pierre ou travail du bois)</p>
<p><strong>Sorts.</strong> Faculté de lancer des sorts de magie divine de 3e niveau</p>', '<p>Le lanceur de runes ne gagne pas de formation.au maniement des armes et des boucliers, ni au port des armures.</p>', '<p>À chaque niveau de lanceur de runes, le personnage obtient un niveau effectif de jeteur de sorts pour une de ses classes de lanceur de sorts divins précédentes (via laquelle il est capable de lancer des sorts de 3e niveau au moins). Il obtient les sorts par jour et le niveau de lanceur de sorts d''un personnage de son niveau effectif. Par contre, il ne gagne aucun des autres avantages accompagnant habituellement ce niveau (dons de métamagie ou de création d''objets supplémentaires, meilleure chance de repousser les morts-vivants, etc.). Si le lanceur de runes possède plusieurs classes de lanceur de sorts divins via lesquelles il peut jeter des sorts de 3e niveau au moins, le niveau effectif ne s''applique qu''à l''une d''entre elles, au choix du personnage.</p>', '<p>Compétences de classe : Art de la magie, Artisanat, Concentration, Connaissances (mystères), Connaissances (religion), Diplomatie, Premiers secours, Profession.</p>', '<p>Conçue par les nains et les géants, la création de runes de pouvoir s''est répandue au-delà des collines et des montagnes. Ceux qui domptent ce pouvoir, les lanceurs de runes, f créent des symboles particulièrement puissants, utilisables plusieurs fois, qui se déclenchent parfois sans qu''on les touche. Les biens d''un lanceur de runes sédentaire sont généralement décorés par de nombreux symboles, ce qui rend leur apparence impressionnante et constitue une véritable menace pour les voleurs.</p>
<p>La plupart des lanceurs de runes sont des nains et des géants, aussi n''est-il pas étonnant qu''ils soient majoritairement issus des classes de prêtre et d''adepte. Certains rôdeurs et paladins entreprennent également une carrière de lanceur de runes, plus particulièrement depuis que la Bénédiction du Tonnerre a poussé nombre de jeunes nains à explorer le monde. De rares druides empruntent cette voie, le plus souvent dans les régions où ils sont si jeu nombreux qu''ils doivent compter sur les runes pour protéger une vaste zone. Les prêtres et paladins lanceurs de runes utilisent leurs pouvoirs pour protéger leurs temples et objets saints. De leur côté, les rôdeurs lanceurs de runes s''en servent pour surveiller les sentiers, repaires d''animaux menacés et refuges naturels.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Lanceur de Runes' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Lanceur de Runes' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 0, 2, 2, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '1', 0, 3, 3, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '2', 1, 3, 3, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '3', 1, 4, 4, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '3', 1, 4, 4, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 6, '4', 2, 5, 5, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 6);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 7, '5', 2, 5, 5, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 7);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 8, '6', 2, 6, 6, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 8);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 9, '6', 3, 6, 6, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 9);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 10, '7', 3, 7, 7, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 10);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Artisanat runique', '<p>Au niveau 1, le lanceur de runes bénéficie d''un bonus de +1 aux tests d''Artisanat visant à graver une rune. Ce bonus passe à +2 au niveau 4 et à +3 au niveau 7.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Artisanat runique' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Pouvoir runique', '<p>Dès le niveau 2, les runes du personnage deviennent plus puissantes. Ajoutez +1 au DD visant à effacer, dissiper ou désamorcer les runes créées par le lanceur de runes, mais également aux tests de niveau de lanceur de sorts destinés à vaincre la résistance à la magie des cibles. Cette augmentation ne s''applique pas au DD de sauvegarde visant à résister à l''effet de la rune (le cas échéant). Elle passe à +2 au niveau 5 et à +3 au niveau 9.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Pouvoir runique' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Science des runes', '<p>Au fil de sa progression, le personnage crée des runes capables de fonctionner plusieurs fois et pourvues de différents types de déclencheurs. Cependant, toute particularité supplémentaire augmente le coût de la rune, comme précisé dans la table ci-dessous.</p>
<p>[[tab:classe-lanceur-de-runes]]</p>
<p>1 Un sort de niveau 0 compte comme 1/2 niveau.</p>
<p>2 Niveau de lanceur de runes minimum requis pour écrire une rùne de ce type.</p>
<p>3 Si le sort a une composante ou un coût en PX, ajoutez celui-ci multiplié par le nombre de charges au prix de base de la rune.</p>
<p>4 Si le sort a. une composante ou un coût en PX, ajoutez 100 fois celui-ci au prix de base de la rune.</p>
<p><strong>Lecture ou franchissement</strong>. Toute tentative visant à étudier, identifier ou sonder une rune revient à la « lire ». Passer par une porte (ou. un portait) arborant une rune revient à la « franchir ». Pour affecter une cible, il doit y avoir une ligne d''effet dégagée entre la rune et celle-ci .Enfin, la cible doit se trouver dans un rayon de 9 mètres.</p>
<p>Une rune qui se déclenche quand on la franchit peut être « réglée » comme l''entend le lanceur de runes. Ainsi, on peut la régler selon des paramètres physiques (comme la taille ou le poids), le type, le sous-type ou la race (comme les drows ou les aberrations). On peut aussi les régler sur le Bien, le Chaos, la Loi, le Mal ou une divinité tutélaire. Par contre, on ne peut les régler selon une. classe, des dés de vie ou un niveau. Les runes réagissent normalement contre les créatures invisibles, mais elles ne se déclenchent pas contre celles qui les franchissent de façon éthérée. Lorsqu''il pose une rune censée se déclencher quand on la franchit, le lanceur de runes a la possibilité de préciser un mot de passe ou une phrase qui évitera qu''une créature ne l''active.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Science des runes' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Quintessence des runes (Exf)', '<p>Au niveau 6, les runes créées par le personnage prennent leur valeur maximale, comme si elles se trouvaient sous l''influence du don Quintessence des sorts (sans qu''il soit nécessaire de mobiliser un emplacement de sort d''un niveau supérieur). Le fait de tirer la quintessence d''une rune augmente de +5 le DD du test d''Artisanat requis pour la façonner.</p>', NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Quintessence des runes (Exf)' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Chant runique', '<p>Un lanceur de runes de niveau 10 peut lancer un sort divin auquel il a accès avec un bonus de +1 au niveau de lanceur de sorts en traçant une rune dans les airs (il s''agit alors d''une composante gestuelle additionnelle). Les sorts habituellement pourvus d''un temps d''incantation de 1 action simple voient celui-ci passer à 1 action complexe, le temps d''incantation des autres grimpant à 1 round. Ce pouvoir ne saurait être utilisé conjointement avec des sorts à incantation statique et il ne fonctionne pas avec le pouvoir, quintessence des runes.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Chant runique' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, '+1', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Artisanat runique' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, '+1', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Pouvoir runique' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Science des runes' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, '+2', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Artisanat runique' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, '+2', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Pouvoir runique' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 6, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Quintessence des runes (Exf)' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 6);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, '+3', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Artisanat runique' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 8, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Science des runes' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 8);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 9, '+3', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Pouvoir runique' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 9);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Chant runique' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 2, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 2 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 4, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 4 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'mystères'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'mystères');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'religion'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'religion');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 13, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 13 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 28, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 28 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');

-- ===== Marteau de Moradin

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Marteau de Moradin', 'MM', 2, 10, 10, 2, '<p><strong>Race.</strong> Nain</p>
<p><strong>Région.</strong> Épine dorsale du Monde</p>
<p>Bonus de base à l’attaque. +7</p>
<p><strong>Compétence.</strong> Degré de maîtrise de 10 en Artisanat (fabrication d’armes)</p>
<p><strong>Dons.</strong> Arme de prédilection (marteau de guerre), Volonté de fer</p>
<p><strong>Sorts.</strong> Faculté de lancer des sorts de magie divine de 2e niveau</p>
<p><strong>Divinité tutélaire.</strong> Moradin</p>', '<p>Le Marteau de Moradin est formé au maniement des armes courantes, des armes de guerre et des boucliers. Il est également formé au port de tous les types d''armures.</p>', NULL, '<p>Compétences de classe : Art de la magie, Artisanat, Concentration, Connaissances (religion), Connaissances (histoire), Connaissances (mystères), Connaissances (plans), Premiers secours, Profession.</p>', '<p>Au sein des halls de la citadelle d''Adbar du Nord glacé, un ordre d''élite de prêtres-soldats défend le peuple nain contre les assauts de géants, d''elfes noirs et de gobelinoïdes tous aussi féroces les uns que les autres. Connus sous le nom de marteaux de Moradin, ces individus se réunissent à la citadelle d''Adbar pour repousser les incursions de créatures des ténèbres qui hantent le Nord. L''armée régulière, la garde de fer, est parfaitement capable de défendre la cité, mais les marteaux s''occupent plus précisément des monstres en allant les traquer chez eux.</p>
<p>Guerriers/prêtres et paladins constituent la majorité des membres de cette classe de prestige, mais elle abrite également des prêtres/moines. Bien que rôdeurs et prêtres/roublards soient tout à fait capables d''emprunter cette voie, la plupart se tournent néanmoins vers les éclaireurs des profondeurs, une autre branche de l''armée de la citadelle d''Adbar. Il est rare que des membres d''autres classes intègrent les rangs des marteaux de Moradin.</p>
<p>Les paladins de Moradin peuvent se multiclasser en toute liberté en marteaux de Moradin.</p>
<p><strong>Anciens Marteaux de Moradin.</strong></p>
<p>Un marteau de Moradin violant son alignement ou trahissant la citadelle d''Adbar ou son organisation perd tous les pouvoirs magiques et surnaturels découlant de cette classe de prestige. Il récupère son statut et ses aptitudes s''il fait acte de contrition..</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Marteau de Moradin' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Marteau de Moradin' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '1', 0, 2, 2, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '2', 0, 3, 3, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '3', 1, 3, 3, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '4', 1, 4, 4, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '5', 1, 4, 4, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 6, '6', 2, 5, 5, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 6);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 7, '7', 2, 5, 5, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 7);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 8, '8', 2, 6, 6, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 8);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 9, '9', 3, 6, 6, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 9);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 10, '10', 3, 7, 7, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 10);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Aura de bravoure', '<p>Dès le niveau 1, le Marteau de Moradin développe une aura de bravoure qui fonctionne sur le même principe que celle d''un paladin.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Aura de bravoure' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Lancer de marteau', '<p>Le Marteau de Moradin peut user de son marteau de guerre en qualité d''arme de jet avec un facteur de portée de 6 mètres. Il ne subit pas de malus supplémentaire quand il se sert ainsi de son arme.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Lancer de marteau' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Marteau boomerang', '<p>Quand le Marteau de Moradin atteint le niveau 2, tout marteau de guerre qu''il lance bénéficie de la propriété boomerang. Un marteau de guerre boomerang revient dans la main de son propriétaire juste avant son tour de jeu suivait, ce qui lui permet de lé réutiliser aussitôt.</p>
<p>Le personnage rattrape son marteau au prix d''une action libre. S''il n''est pas en mesure de le réceptionner, l''arme tombe dans la case depuis laquelle il l''a lancée.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Marteau boomerang' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Tueur de gobelins', '<p>A partir du niveau 2, le marteau de Moradin peut imprégner tout marteau de guerre de la propriété tueur de gobelins (action de mouvement). Ce pouvoir est utilisable 1 fois par jour et l''effet dure pendant un nombre de rounds égal au modificateur de Charisme du personnage.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Tueur de gobelins' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Poigne puissante', '<p>Au niveau 3, le Marteau de Moradin gagne un bonus égal à la moitié de son bonus de Force (arrondir à l''entier inférieur) aux jets de dégâts effectués au corps à corps avec un marteau de guerre. Son bonus aux dégâts est donc égal à 1,5 fois son bonus de Force quand il le manie à une main, et à 2 fois son bonus de Force quand il le manie à deux mains.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Poigne puissante' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Réduction des dégâts', '<p>Au niveau 3, le Marteau de Moradin gagne une réduction des dégâts (2/-). Celle-ci passe à (4/-) au niveau 6, puis à (6/-) au niveau 9.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Réduction des dégâts' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Tir lointain', '<p>Au niveau 4, le Marteau de Moradin jouit du don Tir lointain quand il lance son marteau de guerre. Le facteur de portée de son arme passe donc à 9 mètres.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Tir lointain' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Tremblement', '<p>En frappant violemment le sol à l''aide de son marteau de guerre (action simple), un Marteau de Moradin de niveau 4 ou plus crée une onde de choc qui fait trembler la terre devant lui. Les créatures qui sont en contact avec le sol dans un cône de 18 mètres de long à partir du point d''impact doivent réussir un jet de réflexes (DD 10 + niveau de Marteau de Moradin + modificateur de Charisme) sous peine de se retrouver à terre.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Tremblement' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Frappe en puissance', '<p>À partir du niveau 5, le Marteau de Moradin peut frapper son adversaire avec une violence telle que celui-ci s''en retrouve hébété. Pour user de ce pouvoir, le personnage effectue un jet d''attaque normal. (Le joueur doit néanmoins déclarer l''utilisation du pouvoir avant d''effectuer son jet d''attaque ; si le personnage rate, le pouvoir ne fonctionne pas.) En cas de succès, l''attaque infligé les dégâts habituels. De plus, l''adversaire'' doit réussir un jet de Vigueur (DD 10 + niveau de Marteau de Moradin + modificateur de Force) sous peine d''être hébété pendant 1 round. Les créatures artificielles, les morts-vivants, les vases, les créatures intangibles et les créatures immunisées contre les coups critiques ne sont pas affectés. Ce pouvoir est utilisable 1 fois par jour au niveau 5 et 4 fois par jour au niveau 10.</p>
<p>Au niveau 9, le Marteau de Moradin peut jeter son marteau de guerre avec une force telle qu''il percute toutes les créatures situées sur son chemin. Quand il lance son marteau, le personnage effectue un jet d''attaque à distance et confronte son résultat à la CA de toutes les créatures situées sur une ligne de 18 mètres de long. Il jette ensuite les dégâts pour chaque créature touchée.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Frappe en puissance' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Tueur de drows', '<p>Quand un Marteau de Moradin de niveau 5 ou plus use de l''aptitude tueur de gobelins, son arme bénéficie également de la propriété tueuse de drows. Ce pouvoir ne confère pas d''utilisations supplémentaires de l''aptitude tueur de gobelins et n''allonge pas la durée de l''effet.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Tueur de drows' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Écrase-Chaos', '<p>Un Marteau de Moradin de niveau 7 peut imprégner tout marteau de guerre de la propriété spéciale axiomatique (action de mouvement). Ce pouvoir est utilisable 1 fois par jour et l''effet dure pendant un nombre de rounds égal au modificateur de Charisme du personnage.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Écrase-Chaos' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Robuste', '<p>Les Marteau de Moradin sont connus pour leur faculté de résistance face à une volée de flèches ou à une horde de gobelins couinant. À partir du niveau 7, le personnage peut ajouter à la CA son modificateur de base aux jets de Volonté, 1 fois par jour (action libre). L''effet dure pendant 1 round par niveau de Marteau de Moradin.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Robuste' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Tueur de géants', '<p>Quand un Marteau de Moradin de niveau 8 ou plus use de l''aptitude tueur de gobelins, son arme bénéficie également de la propriété tueuse de géants. Ce pouvoir ne confère pas d''utilisations supplémentaires de l''aptitude tueur de gobelins et n''allonge pas la durée de l''effet.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Tueur de géants' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Frappe tonnerre', '<p>Quand le Marteau de Moradin atteint le niveau 8, ses coups sont si puissants que les armures n''offrent guère de protection contre eux, mais la victime doit en plus endurer une douleur insupportable. Quand il manie son marteau de guerre, le personnage bénéficie d''un bonus aux jets de dégâts des armes au corps à corps égal au bonus d''armure de son adversaire (ce qui n''inclut pas le bonus de bouclier et les bonus d''altération). Ainsi, un Marteau de Moradin qui frappe un adversaire portant une cuirasse bénéficie d''un bonus de +5 aux jets de dégâts.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Frappe tonnerre' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Os de la terre', '<p>Quand le Marteau de Moradin atteint le niveau 10, il jouit d''une puissante bénédiction. Ce pouvoir fonctionne sur le même principe que le sort traversée des ombres (niveau de lanceur de sorts égal au niveau de lanceur de sorts divins du personnage), si ce n''est qu''au lieu de se déplacer à la frontière du plan de l''Ombre, il voyage à la lisière du plan élémentaire de la Terre. Le point d''origine et la destination doivent se situer dans un rayon de 1,50 mètre de roche naturelle et solide. Ce pouvoir est utilisable 1 fois par jour.</p>
<p>Dons liés aux aptitudes</p>
<p><strong>Aura de bravoure</strong> : Aura de bravoure étendue, Aura de pureté, Extension d’aura de bravoure (épique), Science de l’aura de bravoure (épique)</p>', 'mag', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Os de la terre' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Lancer en puissance', NULL, NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Lancer en puissance' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Aura de bravoure' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Lancer de marteau' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Marteau boomerang' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Tueur de gobelins' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Poigne puissante' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, '2/-', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Réduction des dégâts' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Tir lointain' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Tremblement' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, '2 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Frappe en puissance' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Tueur de drows' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 6, '4/-', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Réduction des dégâts' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 6);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Écrase-Chaos' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Robuste' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 8, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Frappe tonnerre' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 8);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 8, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Tueur de géants' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 8);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 9, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Lancer en puissance' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 9);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 9, '6/-', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Réduction des dégâts' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 9);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, '4 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Frappe en puissance' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Os de la terre' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 2, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 2 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 4, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 4 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'religion'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'religion');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'histoire'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'histoire');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'mystères'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'mystères');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'plans'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'plans');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 28, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 28 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');

-- ===== Moine de la Mort Longue

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Moine de la Mort Longue', 'MML', 2, 8, 10, 4, '<p><strong>Alignement.</strong> Ne pas être bon</p>
<p><strong>Compétence.</strong> Degré de maîtrise de 5 en Artisanat (alchimie), degré de maîtrise de 8 en Connaissances(mystères), degré de maîtrise de 7 en Artisanat (fabrication de poison), degré de maîtrise de 3 en Premiers secours</p>
<p><strong>Jet de sauvegarde.</strong> Volonté +5</p>
<p><strong>Spécial.</strong> Le candidat doit être intronisé parmi les moines de la mort longue au moyen d’une cérémonie secrète consistant en divers actes aussi morbides qu’affreux, le tout, dans le but de tester sa détermination</p>', '<p>Le moine de la mort longue ne gagne aucune formation au maniement des armes et des boucliers, ni au port des armures.</p>', NULL, '<p>Compétences de classe : Acrobaties, Artisanat, Bluff, Concentration, Connaissances (mystères), Connaissances (religion), Contrefaçon, Décryptage, Déguisement, Équilibre, Intimidation, Langue, Premiers secours, Profession, Saut.</p>', '<p>Dispersés au travers de Faerûn, les moines de la mort longue sont membres d''un ordre macabre et secret d''érudits désireux de cerner la véritable nature de la mort. Ils ne s''intéressent pas au sort réservé à l''âme dans l''au-delà, mais seulement au processus de mort et à ses effets sur les tissus vivants. Leur organisation est particulièrement puissante à Thay, mais des avant-postes sont disséminés dans tout Faerûn, même au sein des Marches d''Argent.</p>
<p>Les moines sont les principaux candidats à cette classe de prestige, mais on y trouve également des prêtres des noirs dieux de la mort (comme Velsharoon, Kiaransalee, voire Myrkul, le dieu mort). Nécromanciens, assassins et autres personnages fascinés par la mort complètent les rangs de l''ordre.</p>
<p><strong>Anciens moines de la mort longue.</strong></p>
<p>Un moine de la mort longue trahissant les secrets de l''ordre ou tentant de quitter l''organisation devient la proie d''assassins. Ces derniers ont un ND égal au niveau global du personnage (il peut s''agir d''un assassin de même niveau ou de plusieurs individus de niveau inférieur), mais chaque tentative de meurtre se soldant par un échec augmente le ND du groupe suivant de +1. Si l''ancien moine de la mort, longue survit à une tentative d''assassinat menée par un groupe doté d''un ND supérieur à son niveau de 5 points, l''organisation met un terme à la traque (trop coûteuse en ressources).</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Moine de la Mort Longue' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Moine de la Mort Longue' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 2, 0, 2, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '1', 3, 0, 3, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '2', 3, 1, 3, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '3', 4, 1, 4, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '3', 4, 1, 4, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 6, '4', 5, 2, 5, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 6);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 7, '5', 5, 2, 5, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 7);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 8, '6', 6, 2, 6, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 8);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 9, '6', 6, 3, 6, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 9);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 10, '7', 7, 3, 7, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 10);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Aptitudes de moines', '<p>Le personnage a les dégâts à mains nues, le bonus à la CA et le déplacement accéléré d''un moine de son niveau dans cette classe de prestige. S''il possède également des niveaux de moine, ceux-ci s''ajoutent à ceux de moine de la mort longue pour ce qui est de déterminer ces pouvoirs.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Aptitudes de moines' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Sauvegarde contre la mort', '<p>Au niveau 1, le moine de la mort longue bénéficie d''un bonus de +1 aux jets de sauvegarde contre les effets de mort. Ce bonus augmente de +1 tous les niveaux impairs (+2 au niveau 3, +3 au niveau 5, +4 au niveau 7 et +5 au niveau 9).</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Sauvegarde contre la mort' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Utilisation du poison', '<p>Un moine de la mort longue apprend à utiliser du poison. Il ne risque jamais de s''empoisonner accidentellement quand il enduit son arme d''une substance délétère.</p>', NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Utilisation du poison' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Suaire macabre', '<p>Les moines de la mort longue sont déroutants, voire effrayants. Ceux qui les voient ont donc tendance à les oublier aussi vite que possible. Quand un moine de la mort longue atteint le niveau 2, le DD des tests de Renseignements, de savoir bardique et autres talents visant à en apprendre à son sujet augmente d''un nombre égal à son niveau dans cette classe de prestige.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Suaire macabre' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Mise à mort', '<p>Au niveau .3, le moine de la mort longue peut user de mise à mort, 1 fois par jour (niveau de lanceur de sorts égal au niveau de moine de la mort longue).</p>', 'mag', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Mise à mort' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Attaque mortelle', '<p>Au niveau 6, le moine de la mort longue est capable de porter une attaque mortelle. Ce pouvoir fonctionne sur le même principe que l''aptitude d''assassin du même nom, si ce n''est que le DD de sauvegarde est égal à 10 + niveau de moine de la mort longue + son modificateur d''Intelligence.</p>
<p>Si le personnage possède déjà ce pouvoir (par exemple, via la classe d''assassin), les niveaux de la classe en question se cumulent aux niveaux de moine de la mort longue pour ce qui est de déterminer le DD de sauvegarde.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Attaque mortelle' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Caresse mortelle', '<p>Un moine de la mort longue de niveau 10 peut effectuer une attaque de caresse mortelle, 1 fois par jour. Ce pouvoir fonctionne sur le même principe que celui du domaine de la Mort, si ce n''est que l''on jette 1d6 par niveau de moine de la mort longue.</p>
<p>Si le personnage possède déjà ce pouvoir (par exemple, via la classe de prêtre), les niveaux de la classe en question se cumulent aux niveaux de moine de la mort longue pour ce qui est de déterminer le DD de sauvegarde.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Caresse mortelle' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Aptitudes de moines' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, '+1', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Sauvegarde contre la mort' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Utilisation du poison' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Suaire macabre' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Mise à mort' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, '+2', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Sauvegarde contre la mort' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, '+3', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Sauvegarde contre la mort' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 6, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Attaque mortelle' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 6);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, '+4', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Sauvegarde contre la mort' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 9, '+5', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Sauvegarde contre la mort' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 9);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Caresse mortelle' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 1, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 1 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 3, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 3 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 4, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 4 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'mystères'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'mystères');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'religion'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'religion');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 6, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 6 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 8, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 8 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 9, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 9 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 16, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 16 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 23, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 23 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 24, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 24 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 28, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 28 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 33, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 33 AND ccomp_precision = '');

-- ===== Oeil d'Horus-Rê

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Oeil d''Horus-Rê', 'OH', 2, 8, 10, 2, '<p><strong>Région.</strong> Mulhorande</p>
<p><strong>Alignement.</strong> Loyal bon</p>
<p><strong>Compétences.</strong> Degré de maîtrise de 9 en Connaissances (religion), degré de maîtrise de 4 en Détection</p>
<p><strong>Dons.</strong> Emprise sur les morts-vivants, Vigilance</p>
<p><strong>Sorts.</strong> Faculté de lancer des sorts de magie divine de 3e niveau</p>
<p><strong>Domaine.</strong> Soleil</p>', '<p>L''œil d''Horus-Rê ne reçoit aucune formation supplémentaire au maniement des armes et des boucliers, ni au port des armures.</p>', '<p>À partir du niveau 2, à chaque niveau d''œil d''Hôrus-Rê, le personnage gagne un niveau effectif de prêtre. Il obtient les sorts par jour et le niveau de lanceur de sorts d''un prêtre de son niveau effectif. Par contre, il ne gagne aucun des autres avantages accompagnant habituellement ce niveau (meilleures chances de renvoyer les morts-vivants, etc.).</p>', '<p>Compétences de classe : Art de la magie, Concentration, Connaissances (toutes), Détection, Diplomatie, Premiers secours, Profession.</p>', '<p>Après le Temps des Troubles, la divinité principale du panthéon mulhorandi songea de plus en plus à combattre les agents de Seth au-delà de la scène politique locale. Horus-Rê attira à lui des paladins et de nombreux prêtres se joignirent également à la croisade. Reflets parfaits de la sainte illumination de leur dieu, ces prêtres sont connus sous le nom d''yeux d''Horus-Rê. Ce sont les champions du Bien, les ennemis jurés de Seth et de merveilleux exterminateurs de morts-vivants.</p>
<p>Tous les membres de cette classe de prestige sont des prêtres d''Horus-Rê, mais certains disposent également de niveaux de paladin. Les guerriers/prêtres sont également courants et certains prêtres/magiciens usent de leur magie profane limitée pour bonifier leur magie divine.</p>
<p>Contrairement à l''ensemble du clergé d''Horus-Rê, les yeux se tiennent à l''écart des affaires politiques qui agitent la Mulhorande. Plutôt que de rendre des comptes au pharaon, ils se tournent vers leur propre structure hiérarchique. On trouve des yeux d''Horus-Rê PNJ partout où prospèrent les minions de Seth et les morts-vivants. Certains s''intéressent de plus en plus aux activités des yuan-tis de Hlondeth.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Oeil d''Horus-Rê' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Oeil d''Horus-Rê' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 0, 0, 2, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '1', 0, 0, 3, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '2', 1, 1, 3, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '3', 1, 1, 4, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '3', 1, 1, 4, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 6, '4', 2, 2, 5, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 6);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 7, '5', 2, 2, 5, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 7);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 8, '6', 2, 2, 6, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 8);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 9, '6', 3, 3, 6, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 9);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 10, '7', 3, 3, 7, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 10);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Rayonnement de la ferveur', '<p>Quand l''oeil d''Horus-Rê lance un sort du registre de la lumière, la lumière créée est plus vive que de coutume. Le rayon d''éclairage est doublé et le sort est traité comme s''il était d''un niveau supérieur, compris pour ce qui est de déterminer s''il peut contrer ou dissiper les sorts du registre de l''obscurité. Ainsi, un sort de lumière jeté par un œil d''Horus-Rê éclaire une zone de 36 mètres de rayon et est traité comme/un sort du 4e niveau, ce qui lui permet de contrer ou de dissiper les sorts du registre de l''obscurité jusqu''au 4e niveau.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Rayonnement de la ferveur' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Renvoi des morts-vivants', '<p>Le personnage ajoute ses niveaux de classe d''œil d''Horus-Rê à ceux de prêtre pour ce qui est du renvoi des-morts-vivants. Renvoi suprême (Sur). En plus de son aptitude de renvoi des morts-vivants habituel, l''œil d''Horus-Rê peut user de renvoi suprême (le pouvoir accordé par le domaine du Soleil) un nombre de fois par jour égal à 3 + modificateur de Charisme.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Renvoi des morts-vivants' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Lueur éternelle', '<p>Au niveau 2 l''œil d''Horus-Rê acquiert la vision dans le noir sur 18 mètres et la vision nocturne, ce qui lui permet de voir dans presque toutes les situations.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Lueur éternelle' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Contact du-soleil', '<p>Quand l''œil d''Horus-Rê atteint le niveau 3, les attaques qu''il porte à mains nues ou à l''aide d''une arme sont traitées comme des armes d''alignement bon pour ce qui est de vaincre la réduction des dégâts de ses adversaires.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Contact du-soleil' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Domaine', '<p>Au niveau 5, l''œil d''Horus-Rê a accès à un nouveau domaine, à choisir parmi ceux qu''offre Horus-Rê. Il gagne le pouvoir accordé par le domaine en question et peut faire son choix parmi sa liste de sorts quand il choisit ses sorts de domaine quotidiens. Il ne peut évidemment lancer qu''un seul sort de domaine par niveau de sort (du 1er au 9e) et par jour, mais il a désormais le choix entre trois sorts (et non deux) par niveau de sort.</p>', NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Domaine' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Vision bonifiée', '<p>Au niveau 6, l''œil d''Horus-Rê acquiert une acuité visuelle supérieure. Il ne tient pas compte des chances de rater des sorts et effets du registre de l''obscurité et gagne Combat en aveugle en qualité de don supplémentaire. De plus, il bénéficie d''un bonus de sainteté de +5 aux tests de Détection.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Vision bonifiée' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Explosion d''énergie positive', '<p>En sacrifiant deux utilisations quotidiennes de son pouvoir de renvoi des morts-vivants, un œil d''Horus-Rê de niveau 8 ou plus peut déclencher une explosion d''énergie positive affectant tous les morts-vivants situés dans un rayon de 30 mètres. Cet effet inflige 1d6 points de dégâts par niveau d''œil d''Horus-Rê aux morts-vivants situés dans la zone. Les créatures affectées ont droit à un jet de Réflexes (DD 20 + modificateur de Charisme de l''œil d''Horus-Rê) pour réduire les dégâts de moitié.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Explosion d''énergie positive' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Vision lucide', '<p>Un œil d''Horus-Rê de niveau 10 voit toutes les choses pour ce qu''elles sont véritablement, comme s''il bénéficiait d''un effet de vision lucide permanent.</p>
<p>Dons liés aux aptitudes</p>
<p><strong>Renvoi des morts-vivants</strong> : Armes glorieuses, Armes hantées, Aura d’énergie positive (épique), Bouclier divin, Chant divin, Coup spectral (épique), Déni de la résistance (épique), Disciple du soleil, Éclat sacré, Esprit divin, Essentia divine, Extension de renvoi, Garde divine, Guérison sainte, Hors-la-loi sacré, Levée des ténèbres, Main de Tyr, Marque de la Triade, Métamagie divine, Potentiel magique consacré, Potentiel magique purifié, Précision divine, Puissance divine, Puissance magique divine, Purge divine, Purification sacrée, Récupération de sort divine, Rejet de la mort, Renforcement saint, Renvoi d’azur, Renvoi exalté, Renvoi planaire (épique), Renvoi rapide, Résistance divine, Sanctification d’eau, Soins sacrés, Spontanéité de domaine, Vengeance divine, Vengeance divine épique (épique), Vengeance sacrée, Vigueur divine, Vitalité secrète, Vitesse divine</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Vision lucide' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Renvoi suprême', NULL, NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Renvoi suprême' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Rayonnement de la ferveur' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Renvoi des morts-vivants' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Renvoi suprême' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Lueur éternelle' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Contact du-soleil' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Domaine' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 6, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Vision bonifiée' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 6);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 8, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Explosion d''énergie positive' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 8);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Vision lucide' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 2, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 2 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 4, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 4 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'toutes'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'toutes');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 12, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 12 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 13, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 13 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 28, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 28 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');

-- ===== Quêteur Divin

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Quêteur Divin', 'QD', 2, 6, 5, 4, '<p><strong>Compétences.</strong> Degré de maîtrise de 3 en Connaissances (religion), degrés de maîtrise de 8 en Déplacement silencieux,. degré de maîtrise de 5 en Détection, degré de maîtrise de 8 eh Discrétion</p>
<p><strong>Don.</strong> Discret</p>
<p><strong>Divinité tutélaire.</strong> Un quêteur divin doit avoir- une divinité tutélaire, et il doit s’agir du dieu dont il est l’un des quêteurs</p>', NULL, NULL, '<p>Compétences de classe : Artisanat, Connaissances (géographie), Connaissances (religion), Déplacement silencieux, Détection, Diplomatie, Discrétion, Équitation, Escalade, Fouille, Maîtrise des cordes, Natation, Perception auditive, Profession, Saut, Survie.</p>', '<p>Même les dieux ont besoin d''intimité de temps en temps. Quand furtivité et discrétion doivent prendre le pas sur vaillance militaire et magie sainte, le quêteur divin se charge d''exécuter la mission. Selon l''Église à laquelle il appartient, le quêteur divin ira récupérer une relique sainte en territoire ennemi, espionnera le clergé d''un culte rival ou éliminera des hérétiques. La subtilité est le maître mot de cette classe de prestige. Du reste, le quêteur divin s''acquitte généralement de sa mission sans compromettre son Église.</p>
<p>Les quêteurs divins sont issus de n''importe quelle classe. Toutefois, il s''agit souvent de moines, de rôdeurs et de roublards. Barbares et bardes ont parfois les compétences nécessaires pour entrer dans leurs rangs, mais ils manquent généralement de subtilité. Ensorceleurs et magiciens font de bons quêteurs divins à l''occasion, mais ils ont habituellement du mal à réunir les compétences nécessaires.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Quêteur Divin' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Quêteur Divin' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 2, 0, 2, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '1', 3, 0, 3, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '2', 3, 1, 3, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '3', 4, 1, 4, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '3', 4, 1, 4, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Neutralisation de piège magique', '<p>Dès le niveau 1, le quêteur divin bénéficie d''un bonus de +3 aux tests de Fouille et de Désamorçage/sabotage visant à trouver, à désamorcer ou à contourner un piège magique.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Neutralisation de piège magique' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Défense sacrée', '<p>Dès le niveau 1, le quêteur divin bénéficie d''un bonus de +1 aux jets de sauvegarde contre les sorts de magie divine, mais également contre les pouvoirs magiques et pouvoirs surnaturels des Extérieurs. Au niveau 4, ce bonus passe à +2.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Défense sacrée' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Attaque sournoise', '<p>Ce pouvoir fonctionne sur le même principe que l''aptitude de roublard du même nom. Les dégâts supplémentaires se montent à +1d6 au niveau 1 et +2d6 au niveau 5. Si le quêteur divin possède déjà ce pouvoir, lès dégâts se cumulent. De plus, les niveaux de quêteur divins sont ajoutés à ceux d''autres classes (comme assassin ou roublard) pour ce qui est de passer outre l''esquive instinctive supérieure d''adversaires.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Attaque sournoise' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Localisation de créature', '<p>À partir du niveau 3, le quêteur divin peut user de localisation de créature (niveau de lanceur de sorts égal à son niveau de quêteur divin + modificateur de Charisme), 1 fois par jour.</p>', 'mag', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Localisation de créature' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Localisation d''objet', '<p>A partir du niveau 3, le quêteur divin peut user de localisation d''objet (niveau de lanceur de sorts égal à son niveau de quêteur divin + modificateur de Charisme), 1 fois par jour.</p>', 'mag', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Localisation d''objet' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Persévérance divine', '<p>A partir du niveau 4, si les points de vie du quêteur divin tombent à -1 ou moins, il recouvre instantanément un nombre de points de vie égal à 3d6 + bonus de Charisme (le cas échéant). Ce pouvoir est utilisable 1 fois par jour.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Persévérance divine' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Orientation', '<p>Au niveau 5, le quêteur divin peut user d''orientation (niveau de lanceur de sorts égal à son niveau de quêteur divin + modificateur de Charisme), 1 fois par jour.</p>', 'mag', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Orientation' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Discrétion sacrée', '<p>Au 1er niveau, le Quêteur Divin peut invoquer le pouvoir de sa divinité pour le protéger des yeux et des oreilles indiscrets. En tant qu''action simple, il peut s''accorder un bonus sacré de +10 (ou un bonus profane, si sa divinité tutélaire est maléfique) sur ses tests de Déplacement silencieux et Discrétion. Ce bonus dure un nombre de minute par jour égal à son bonus de Charisme (minimum, 1 minute). Cette durée n''a pas à être consécutive: le Quêteur Divin peut a diviser en durée aussi petite que 1 round s''il le désire. Mettre fin à l''effet est une action libre.</p>
<p>Dons liés aux aptitudes</p>
<p><strong>Attaque sournoise</strong> : Attaque commotionnante, Attaque défigurante, Attaque persistante, Attaque sournoise d’opportunité (épique), Attaque sournoise démoniaque, Attaque sournoise retardée, Coup à la gorge, Coup habile, Coup sacré, Coupe-jarret, Dégâts persistants (épique), Drain d’esprit, Embusqué rapide, Frappe assourdissante, Frappe de feu draconique, Frappe débilitante, Frappe des ténèbres, Frappe du loup, Frappe éventrente, Frappe fièvreuse, Frappe hémorragique, Frappe indigo, Frappe miséricordieuse, Frappe paralysante, Frappe silencieuse, Frappe terrifiante, Frappe venimeuse, Hors-la-loi audacieux, Hors-la-loi sacré, Influx de démolition, Inquisiteur dévot, Lâche, Leçons de la nature, Lutte sauvage, Roublard ascétique, Science de l’attaque mortelle (épique), Science de l’attaque sournoise (épique), Spécialiste des ennemis</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Discrétion sacrée' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Discrétion sacrée' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Neutralisation de piège magique' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, '+1d6', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Attaque sournoise' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, '+1', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Défense sacrée' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Localisation de créature' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Localisation d''objet' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, '+2', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Défense sacrée' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Persévérance divine' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, '+2d6', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Attaque sournoise' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Orientation' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'géographie'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'géographie');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'religion'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'religion');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 10, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 10 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 12, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 12 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 13, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 13 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 14, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 14 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 17, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 17 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 18, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 18 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 22, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 22 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 25, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 25 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 26, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 26 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 27, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 27 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 33, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 33 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 34, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 34 AND ccomp_precision = '');

-- ===== Seigneur de l'Aube de Lathandre

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Seigneur de l''Aube de Lathandre', 'SAL', 2, 8, 10, 2, '<p><strong>Alignement.</strong> Bon</p>
<p><strong>Compétence.</strong> Degré de maîtrise de 4 en Artisanat (au choix), degré de maîtrise de 8 en Connaissances (religion), degré de maîtrise de 7 en Diplomatie, degré de maîtrise de 2 en Représentation</p>
<p><strong>Don.</strong> Science du renvoi</p>
<p><strong>Sorts.</strong> Faculté de lancer des sorts de magie divine de 3e niveau, parmi lesquels lumière du jour</p>
<p><strong>Divinité tutélaire.</strong> Lathandre</p>', '<p>Le seigneur de l''aube de Lathandre ne gagne pas de formation au maniement des armes et des boucliers, ni ait port des armures.</p>', '<p>A chaque niveau de seigneur de l''aube de Lathandre, le personnage obtient un niveau effectif de jeteur de sorts pour une de ses classes de lanceur de sorts divins précédentes (via laquelle il est capable de lancer des sorts de 3e niveau au moins). Il obtient les sorts par jour et le niveau de lanceur de sorts d''un personnage de son niveau effectif. Par contre, il ne gagne aucun des autres avantages accompagnant habituellement ce niveau (dons de métamagie ou de création d''objets supplémentaires, meilleure chance de repousser les morts-vivants, etc.). Si le seigneur de l''aube de Lathandre possède plusieurs classes de lanceur de sorts divins via lesquelles il peut jeter des sorts de 3e niveau au moins, le niveau effectif ne s''applique qu''à l''une d''entre elles, au choix du personnage.</p>', '<p>Compétences de classe : Art de la magie, Artisanat, Concentration, Connaissances (mystères), Connaissances (plans), Connaissances (religion), Connaissances (histoire), Diplomatie, Premiers secours, Profession, Représentation.</p>', '<p>L''Église de Lathandre est connue et très respectée à Faerûn. Une grande part du respect qu''elle inspire vient des prêtres d''élite de Lathandre, les seigneurs de l''aube. En bien des façons, chacun de ces individus incarne l''archétype du prêtre classique. Ce sont des guérisseurs et des conseillers avisés, de vaillants protecteurs et d''implacables ennemis des morts-vivants. Croyant que leur devoir est d''apporter la lumière dans tous les lieux obscurs de Faerûn, les seigneurs de l''aube parcourent généralement le continent, dévoilant la gloire de leur dieu à ceux qui veulent bien les entendre et châtiant ses adversaires où qu''ils se cachent. La majorité des seigneurs de l''aube est constituée de prêtres, mais les paladins de Lathandre empruntent aussi souvent cette voie. Les guerriers multiclassés, et plus rarement les rôdeurs, rejoignent parfois les rangs des seigneurs de l''aube, mais cette classe de prestige n''attire guère les autres classes. Les paladins de Lathandre peuvent se multiclasser en. toute-liberté en seigneur de l''aube de Lathandre.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Seigneur de l''Aube de Lathandre' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Seigneur de l''Aube de Lathandre' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 0, 2, 2, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '1', 0, 3, 3, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '2', 1, 3, 3, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '3', 1, 4, 4, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '3', 1, 4, 4, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 6, '4', 2, 5, 5, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 6);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 7, '5', 2, 5, 5, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 7);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 8, '6', 2, 6, 6, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 8);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 9, '6', 3, 6, 6, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 9);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 10, '7', 3, 7, 7, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 10);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Fléau des sans repos', '<p>Les niveaux de seigneur de Lathandre du personnage s''ajoutent à tous ceux qui lui confèrent l''aptitude de classe de renvoi des morts-vivants quand il tente de renvoyer de telles créatures.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Fléau des sans repos' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Lumière de Lathandre', '<p>Quand un seigneur de l''aube lance un sort accompagné du registre-de la lumière, la zone d''effet est doublée.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Lumière de Lathandre' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Feu créateur', '<p>A l''instar de leur dieu, les seigneurs de l''aube sont des individus créatifs et expressifs. Au niveau 1, le personnage gagne un bonus égal à son niveau de seigneur de l''aube de Lathandre aux tests d''Artisanat et Représentation.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Feu créateur' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Lumière du jour', '<p>Au niveau 3, le seigneur de l''aube de Lathandre peut user de lumière du jour, 1 fois par jour (niveau de lanceur de sorts égal au niveau de lanceur de sorts divins du personnage).</p>', 'mag', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Lumière du jour' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Lumière brûlante', '<p>Au niveau 4, le seigneur de l''aube de Lathandre peut user de lumière brûlante, 1 fois par jour (niveau de lanceur de sorts égal au niveau de lanceur de sorts divins du personnage). Si ce pouvoir est utilisé contre un mort-vivant, les dégâts augmentent comme s''ils bénéficiaient du don Extension d''effet.</p>', 'mag', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Lumière brûlante' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Renvoi suprême', '<p>Un seigneur de l''aube de niveau 5 ou plus peut user de renvoi suprême, 1 fois par jour. Ce pouvoir fonctionne sur le même principe que le pouvoir accordé par le domaine du Soleil. Au niveau 9, il peut recourir à ce pouy6ir 1 fois par jour, Si le personnage à déjà accès au domaine du Soleil, il gagne une nouvelle utilisation quotidienne du pouvoir aux niveaux 5 et 9.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Renvoi suprême' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Bénédiction-de l''aube', '<p>La simple apparition du soleil matinal est une vision des plus inspirantes pour tous les seigneurs de l''aube. À partir du niveau 6, le seigneur de l''aube de Lathandre bénéficie d''un bonus de moral de +2 aux jets de Volonté, du lever du soleil à midi. Ce pouvoir ne fonctionne que si le personnage voit le soleil. L''effet est donc réprimé quand il lui est impossible de le distinguer.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Bénédiction-de l''aube' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Quintessence du renvoi', '<p>Un seigneur de l''aube de niveau 7 ou plus peut obtenir le résultat maximum sur un jet d''efficacité du renvoi des morts-vivants. Ce pouvoir est utilisable 1 fois par jour.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Quintessence du renvoi' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Régénération matinale', '<p>L''aube est un formidable symbole de renaissance et de renouveau. Une fois tous les dix jours, un seigneur de l''aube de niveau 8 ou plus peut prier son dieu durant 1 heure avant que l''aube ne se lève. Au terme de cette prière, au moment même où le soleil fait son apparition, le personnage bénéficie de l''un des avantages suivants :</p>
<ul><li>Recouvrer jusqu''à la totalité de ses points de vie (personnel uniquement).</li><li>Se débarrasser de tout poison ou maladie (personnel uniquement). Toutefois, cet effet ne peut rien contre les affaiblissements temporaires et les diminutions permanentes de caractéristiques causés par un poison ou une maladie.</li><li>Soigner un affaiblissement temporaire de caractéristique dû à un poison ou une maladie.</li></ul>
<p>Si les prières du seigneur de l''aube sont interrompues ne serait-ce que durant 1 round, il lui faut attendre 10 jours avant d''effectuer une nouvelle tentative.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Régénération matinale' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Aura étincelante', '<p>Au niveau 10, le personnage jouit de la lumière permanente de Lathandre. Quel que soit le niveau d''obscurité, le seigneur de l''aube voit comme s''il se trouvait en extérieur au moment où le soleil se lève. Ce pouvoir fonctionne sur le même principe que la vision dans le noir (portée de 18 mètres), si ce n''est que le personnage distingue parfaitement les couleurs. Il bénéficie également d''un bonus de sainteté de +2 aux jets de sauvegarde contre les sorts accompagnés du registre de l''obscurité et d''un bonus de sainteté de +1 à la CA contre les attaques des morts-vivants.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Aura étincelante' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Fléau des sans repos' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Lumière de Lathandre' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Feu créateur' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Lumière du jour' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Lumière brûlante' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, '1 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Renvoi suprême' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 6, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Bénédiction-de l''aube' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 6);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Quintessence du renvoi' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 8, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Régénération matinale' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 8);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 9, '2 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Renvoi suprême' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 9);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Aura étincelante' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 2, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 2 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 4, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 4 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'mystères'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'mystères');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'plans'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'plans');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'religion'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'religion');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'histoire'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'histoire');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 13, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 13 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 28, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 28 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 32, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 32 AND ccomp_precision = '');

-- ===== Seigneur Muqueux

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Seigneur Muqueux', 'SM', 2, 8, 10, 4, '<p><strong>Alignement.</strong> Mauvais</p>
<p>Bonus de base à l’attaque. +4</p>
<p><strong>Compétence.</strong> Degré de maîtrise de 6 en Déguisement</p>
<p><strong>Dons.</strong> Difformité provoquée</p>
<p><strong>Divinité tutélaire.</strong> Ghaunadaur</p>', '<p>Le seigneur muqueux ne gagne aucune formation au maniement des armes et des boucliers, ni au port des armures.</p>', NULL, '<p>Compétences de classe : Artisanat, Bluff, Connaissances (exploration souterraine), Contrefaçon, Déguisement, Déplacement silencieux, Discrétion, Estimation, Évasion, Intimidation, Survie.</p>', '<p>Bien que Ghaunadaur soit un membre du panthéon drow, il n''a rien d''un drow. Le Seigneur des Vases est le dieu des limons, des aboleths, des enlaceurs et des parias drows. Les seigneurs muqueux, qui comptent parmi les serviteurs préférés de Ghaunadaur, ne sont pas des prêtres mais des espions capables de changer de forme pour se fondre au sein d''une communauté étrangère. Bien que la plupart soient humanoïdes au début de leur carrière, ils prennent progressivement l''allure d''aberrations de Ghaunadaur, parfois qualifiés de ghaunadrans.</p>
<p>L''origine des seigneurs muqueux est variée, mais la plupart sont d''anciens roublards ou roublards/ guerriers. Les prêtres de Ghaunadaur renoncent parfois à leur progression classique pour se tourner vers cette classe de prestige, certains y voyant là un moyen de compléter leurs facultés de magie divine. La plupart des seigneurs muqueux sont drows, mais aucun anathème ne frappe les autres races. Ils ne sont évidemment pas les bienvenus chez les elfes, sous terre et en surface. Dans l''Outreterre, ils prennent la. tête de petites sectes de disciples de Ghaunadaur, généralement des rebelles qui s''opposent au clergé tout-puissant de Lolth.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Seigneur Muqueux' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Seigneur Muqueux' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 2, 0, 2, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '1', 3, 0, 3, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '2', 3, 1, 3, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '3', 4, 1, 4, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '3', 4, 1, 4, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 6, '4', 5, 2, 5, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 6);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 7, '5', 5, 2, 5, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 7);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 8, '6', 6, 2, 6, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 8);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 9, '6', 6, 3, 6, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 9);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 10, '7', 7, 3, 7, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 10);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Mucus paralysant', '<p>, Les pseudopodes du seigneur muqueux sont recouverts d''un mucus capable de paralyser ses adversaires. Une créature frappée par l''attaque naturelle d''un seigneur muqueux doit réussir un jet de Vigueur (DD 10 + . niveau de seigneur muqueux du personnage + son modificateur de Constitution) sous peine d''être paralysée pendant 1d4+1 rounds.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Mucus paralysant' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Pseudopodes', '<p>La forme physique du seigneur muqueux est bien plus sujette à mutation que celle d''une créature habituelle de son type. Au prix d''une action de mouvement, il peut transformer ses mains en pseudopodes (et vice versa). En réalisant une attaque à outrance, il peut effectuer deux attaques naturelles à l''aide de ses armes, contre-une seule s''il n''entreprend qu''une action simple. Chaque attaque inflige 1d6 points de dégâts. La transformation dure jusqu''à 1 round par niveau de seigneur muqueux. Cependant, le personnage peut y mettre un-terme prématurément au prix d''une action de mouvement.</p>
<p>Le seigneur muqueux peut utiliser ce pouvoir 1 fois par jour au niveau 3 Par la suite,-il gagne une utilisation supplémentaire du pouvoir tous les deux niveaux (3 fois au niveau 5, 4 fois au niveau 7 et 5 fois au niveau 9).</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Pseudopodes' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Regard charmeur', '<p>Un seigneur muqueux de niveau 3 ou plus peut user de regard charmeur pendant 1 round. Une créature croisant son regard doit réussir un jet de Volonté (DD 10 + niveau de seigneur muqueux du personnage + son modificateur de Charisme) sous peine d''être affectée par un effet de charme-monstre (niveau de lanceur de sorts égal au niveau de seigneur muqueux du personnage). Ce pouvoir est utilisable 1 fois par jour et par niveau de seigneur muqueux.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Regard charmeur' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Immunité contre le sommeil', '<p>Un seigneur muqueux de niveau 4 ou plus est immunisé contre les effets de sommeil.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Immunité contre le sommeil' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Modification d''apparence', '<p>Un seigneur muqueux de niveau 5 ou plus peut changer de forme comme s''il était sous l''influence d''un sort de modification d''apparence. Ce pouvoir est utilisable à volonté. Tout changement de forme vaut jusqu''à ce que le personnage ait de nouveau recours au pouvoir ou jusqu''à ce qu''il recouvre sa forme naturelle.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Modification d''apparence' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Réduction des dégâts', '<p>Quand le seigneur muqueux atteint le niveau ~i, son corps est à ce point sujet à mutation qu''il bénéficie d''une réduction des dégâts (5/perforant ou tranchant).</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Réduction des dégâts' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Immunité contre la métamorphose', '<p>Un seigneur muqueux de niveau 8 ou plus est immunisé contre la métamorphose.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Immunité contre la métamorphose' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Vision aveugle', '<p>Quand le seigneur muqueux atteint le niveau 9, son corps devient un véritable organe sensoriel, ce qui lui confère la vision aveugle sur 18 mètres.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Vision aveugle' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Dénué d''anatomie', '<p>Au niveau 10, le seigneur muqueux développe une telle mutabilité qu''il est immunisé contre les coups critiques et les attaques sournoises. De plus, il bénéficie d''une immunité contre le poison, la paralysie et l''étourdissement.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Dénué d''anatomie' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Mucus paralysant' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, '1 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Pseudopodes' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Regard charmeur' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, '2 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Pseudopodes' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Immunité contre le sommeil' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Modification d''apparence' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, '3 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Pseudopodes' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, '4 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Pseudopodes' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, '5/perforant ou tranchant', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Réduction des dégâts' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 8, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Immunité contre la métamorphose' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 8);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 9, '5 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Pseudopodes' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 9);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 9, '18 m', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Vision aveugle' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 9);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Dénué d''anatomie' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 3, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 3 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'exploration souterraine'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'exploration souterraine');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 6, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 6 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 9, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 9 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 10, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 10 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 14, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 14 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 20, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 20 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 21, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 21 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 23, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 23 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 34, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 34 AND ccomp_precision = '');

-- ===== Vierge de la Souffrance

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Vierge de la Souffrance', 'VS', 2, 6, 10, 4, '<p><strong>Sexe.</strong> Féminin</p>
<p><strong>Compétence.</strong> Degré de maîtrise de 4 en Intimidation</p>
<p><strong>Don.</strong> Sort souillé</p>
<p><strong>Sorts.</strong> Faculté de lancer masochisme et sadisme en qualité de sorts de magie divine</p>
<p><strong>Divinité tutélaire.</strong> Loviatar</p>
<p><strong>Spécial.</strong> Le candidat doit avoir ingéré de l’agonie (douleur distillée)</p>', '<p>La vierge de la souffrance .est formée au maniement du fouet, mais elle ne gagne aucune formation au maniement des boucliers, ni au port des armures.</p>', '<p>À partir du niveau 2, à chaque niveau de vierge de la souffrance, le personnage obtient un niveau effectif de prêtre. Elle obtient les sorts par jour et le niveau de lanceur de sorts d''un personnage de son niveau effectif. Par contre, elle ne gagne aucun des autres avantages accompagnant habituellement ce niveau (meilleures chances de repousser les morts-vivants, etc.).</p>', '<p>Compétences de classe : Art de la magie, Artisanat, Bluff, Concentration, Connaissances (religion), Connaissances (mystères), Diplomatie, Intimidation, Maîtrise des cordes, Profession, Psychologie, Renseignement, Représentation.</p>', '<p>La déesse Loviatar est l''incarnation d''un grand nombre des actes et fétiches maléfiques.. Divinité tutélaire des sadiques et des masochistes, le Fouet Complaisant aime la douleur et les châtiments. Ses servantes les plus dévouées, les vierges de la souffrance, sont des femmes dépravées qui tirent un plaisir intense des douleurs qu''elles infligent. Dépendantes des souffrances qu''elles causent, elles le sont aussi de l''agonie, la drogue plus connue sous le nom de douleur distillée.</p>
<p>Les vierges de la souffrance sont issues des rangs d''élite du clergé perverti de Loviatar et comptent parmi ses prêtresses les plus tordues, Quelques-unes possèdent également des niveaux de roublard et d''assassin.</p>
<p>Les PNJ vierges de la souffrance couvrent à l''écart du courant dominant de l''Église, se déplaçant sans cesse pour s''assurer que la volonté de leur déesse est faite. Elles servent d''émissaires, d''agents secrets et d''inquisiteurs pour le compte de l''Église.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Vierge de la Souffrance' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Vierge de la Souffrance' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 2, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '1', 3, 0, 0, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '2', 3, 1, 1, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '3', 4, 1, 1, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '3', 4, 1, 1, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 6, '4', 5, 2, 2, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 6);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 7, '5', 5, 2, 2, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 7);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 8, '6', 6, 2, 2, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 8);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 9, '6', 6, 3, 3, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 9);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 10, '7', 7, 3, 3, 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 10);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Contact douloureux', '<p>Une fois par jour, une vierge de la souffrance peut effectuer une attaque de contact au corps à corps pour infliger une douleur atroce à un adversaire. Si elle le touche, celui-ci doit effectuer un jet de Volonté (DD 10 + niveau de vierge de la souffrance du personnage + son modificateur de Sagesse). En cas d''échec, le sujet est étourdi pendant 1 round. Les créatures artificielles, morts-vivants, vases, créatures intangibles et autres créatures immunisées contre les coups critiques ne sont pas affectés. La vierge de la souffrance peut utiliser ce pouvoir 2 fois par jour au niveau 4, 3 fois par jour au niveau 7 et 4 fois par jour au niveau 10.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Contact douloureux' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Dépendance à l''agonie', '<p>La vierge de la souffrance est dépendante à une drogue, l''agonie, également connue sous le nom de douleur distillée. Cependant, cette dépendance est moyenne et ne peut s''aggraver. Pour chaque journée passée sans ingérer sa dose d''agonie, le personnage subit un affaiblissement temporaire de 1d3 points de Dextérité. De plus, les effets indésirables de la drogue sont annulés en raison de sa connaissance de la douleur. L''effet initial d''une dose d''agonie l''étourdit pendant 1d4-1 rounds et la limite à une action par round pendant 1d4 minutes.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Dépendance à l''agonie' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Domaine supplémentaire', '<p>Une vierge de la souffrance de niveau 1 a accès au domaine de la Souffrance. Si elle le possède déjà, elle peut se tourner vers un autre domaine de Loviatar. Elle bénéficie du pouvoir accordé par ce troisième domaine et peut bien évidemment choisir ses sorts de domaine parmi ceux qu''il propose. Elle reste limitée à un sort de domaine par niveau de sort (du 1er au 9e) et par jour, mais elle dispose de trois choix au lieu des deux habituels.</p>', NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Domaine supplémentaire' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Manieuse de fouet', '<p>Une vierge de la souffrance peut porter des attaques de contact à l''aide de son fouet. Ce pouvoir lui confère une allonge de 4,50 mètres dans le cadre de ses sorts de contact et de son pouvoir de contact douloureux. Quand elle produit un effet de contact, elle peut également effectuer une attaque: normale à l''aide de son fouet, mais il lui faut alors réussir une attaque au corps à corps et non une attaque de contact. Le personnage peut user de sorts de contact au travers de son fouet même si son adversaire est normalement immunisé contre cette arme.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Manieuse de fouet' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Science du croc-en-jambe', '<p>A partir du niveau 3, la vierge de la souffrance bénéficie du don Science du croc-en-jambe quand elle utilise son fouet pour effectuer ce type d''attaque. Elle n''a pas à remplir les conditions habituelles de ce don, mais elle ne peut en bénéficier qu''avec son fouet.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Science du croc-en-jambe' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Science du désarmement', '<p>A partir du niveau 6, la vierge de la souffrance bénéficie du don Science du désarmement quand elle utilise son fouet pour effectuer ce type d''attaque. Elle n''a pas à remplir les conditions habituelles de ce don, mais elle ne peut en bénéficier qu''avec son fouet.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Science du désarmement' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Contact douloureux' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Domaine supplémentaire' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Manieuse de fouet' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Science du croc-en-jambe' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, '2 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Contact douloureux' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 6, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Science du désarmement' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 6);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, '3 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Contact douloureux' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, '4 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Contact douloureux' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Dépendance à l''agonie' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 2, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 2 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 3, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 3 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 4, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 4 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'religion'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'religion');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'mystères'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'mystères');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 13, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 13 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 23, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 23 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 25, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 25 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 30, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 30 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 31, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 31 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 32, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 32 AND ccomp_precision = '');

-- ===== Voleur Cognitif

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Voleur Cognitif', 'VC', 2, 4, 10, 4, '<p><strong>Compétences.</strong> Degré de maîtrise de 5 dans deux des compétences suivantes : Bluff, Crochetage, Déguisement, Renseignements</p>
<p><strong>Don.</strong> Regard inquisiteur</p>
<p><strong>Capacité psionique.</strong> Faculté de manifester décharge psionique</p>', '<p>Le voleur cognitif est formé au maniement des armes courantes et au port des armures légères.</p>', NULL, '<p>Compétences de classe : Art psi, Artisanat, Autohypnose, Bluff, Connaissances (psionique), Contrefaçon, Crochetage, Déguisement, Déplacement silencieux, Désamorçage/sabotage, Discrétion, Escamotage, Évasion, Profession, Psychologie.</p>', '<p>Ces espions psioniques parviennent à lire au plus profond de l''esprit de leurs cibles pour leur dérober des pensées et parfois leurs facultés de raisonnement. Sous leurs airs modestes, ils n''utilisent ni armes surpuissantes ni sorts tapageurs pour parvenir à leurs fins, mais ils ont le chic, pour se frayer un chemin dans la conscience même de leur proie.</p>
<p>Les voleurs cognitifs sont généralement issus des rangs des psions et des prodiges, mais des monstres pourvus d''une simple attaque psionique empruntent aussi cette voie. Les psions pourvus de la discipline Télépathie sont les plus nombreux.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Voleur Cognitif' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Voleur Cognitif' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 0, 0, 2, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '1', 0, 0, 3, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '1', 1, 1, 3, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '2', 1, 1, 4, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '2', 1, 1, 4, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 6, '3', 2, 2, 5, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 6);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 7, '3', 2, 2, 5, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 7);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 8, '4', 2, 2, 6, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 8);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 9, '4', 3, 3, 6, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 9);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 10, '5', 3, 3, 7, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 10);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Points psi/facultés découvertes', '<p>Aux niveaux 2, 3, 5, 6, 8 et 9 de voleur cognitif, le personnage obtient un niveau effectif de manifestant de facultés psioniques. Il bénéficie donc du niveau de manifestation et des points psi quotidiens d''un personnage de son niveau effectif. Par contre, il ne gagne aucun des autres avantages accompagnant habituellement ce niveau (dons supplémentaires, dons métapsioniques ou de création d''objets, points de vie en plus de ceux qui découlent de la classe de prestige, etc.). Si le voleur cognitif possède plusieurs classes psioniques, le niveau effectif ne s''applique qu''à l''une d''entre elles, au choix du personnage.</p>', NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Points psi/facultés découvertes' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Facultés connues supplémentaires', '<p>Aux niveaux 1, 4, 7 et 10, le voleur cognitif découvre deux nouvelles facultés issues de la discipline Télépathie. Il fait son choix parmi les facultés qu''il est en mesure de manifester. Même les voleurs cognitifs qui manifestent leurs facultés en qualité de prodige peuvent faire leur choix parmi la liste du télépathe qui leur est normalement interdite. Le personnage acquiert ces facultés par le biais d''une méditation personnelle, sur le même principe que les facultés apprises dans le cadre des classes psioniques de base. Elles n''exigent donc aucun sacrifice en PX.</p>', NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Facultés connues supplémentaires' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Détection de pensées', '<p>Au niveau 1, le voleur cognitif peut user de détection de pensées (comme la faculté psionique du même nom), 1 fois par jour. Le DD de sauvegarde de cette faculté est égal à 10 + 1/2 niveau global du voleur cognitif + son modificateur d''Int ou de Cha (choisir le plus élevé des deux). Il peut user de ce pouvoir 2 fois par jour au niveau 4, 3 fois par jour au niveau 7 et à volonté au niveau 10.</p>', 'psi', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Détection de pensées' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Confusion', '<p>Au niveau 4, le voleur cognitif peut user de confusion (comme le sort du même nom), 1 fois par jour. Le DD de sauvegarde de ce pouvoir est égal à 10 + 1/2 niveau global du voleur cognitif + son modificateur d''Int ou de Cha (choisir le plus élevé des deux). Il peut user de ce pouvoir 2 fois par jour au niveau 7 et 3 fois par jour au niveau 10.</p>', 'psi', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Confusion' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Sonde mentale', '<p>Au niveau 7, le voleur cognitif peut user de sonde mentale (comme la faculté psionique du même nom), 1 fois par jour. Le DD de sauvegarde de cette faculté est égal à 10 + 1/2 niveau global du voleur cognitif + son modificateur d''Int ou de Cha (choisir le plus élevé des deux). Il peut user de ce pouvoir 2 fois par jour au niveau 10.</p>', 'psi', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Sonde mentale' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Aliénation mentale', '<p>Au niveau 10, le voleur cognitif peut user d''aliénation mentale (comme le sort du même nom), 1 fois par jour. Le DD de sauvegarde de ce pouvoir est égal à 10 + 1/2 niveau global du voleur cognitif + son modificateur d''Int ou de Cha (choisir le plus élevé des deux).</p>', 'psi', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Aliénation mentale' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, '1 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Détection de pensées' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Facultés connues supplémentaires' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, '1 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Confusion' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, '2 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Détection de pensées' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Facultés connues supplémentaires' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, '2 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Confusion' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, '3 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Détection de pensées' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Facultés connues supplémentaires' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, '1 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Sonde mentale' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, '1 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Aliénation mentale' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, '3 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Confusion' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, 'à volonté', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Détection de pensées' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Facultés connues supplémentaires' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, '2 fois/jour', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Sonde mentale' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 3, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 3 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'psionique'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'psionique');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 6, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 6 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 7, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 7 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 9, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 9 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 10, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 10 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 11, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 11 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 14, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 14 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 19, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 19 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 21, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 21 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 30, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 30 AND ccomp_precision = '');

-- ===== Voleur de l'Ombre d'Amn

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Voleur de l''Ombre d''Amn', 'VOA', 2, 6, 5, 6, '<p><strong>Compétences.</strong> Degré de maîtrise de 3 en Bluff, degré de maîtrise de 3 Déplacement silencieux, degré de maîtrise de 8 en Discrétion, degré de maîtrise de 3 en Intimidation, degré de maîtrise de 3 en Renseignements</p>
<p><strong>Don.</strong> Persuasion</p>
<p><strong>Spécial.</strong> Le candidat doit être membre.d’une guilde de Voleurs de l’Ombre</p>', '<p>Le-voleur de l''ombre d''Amn est formé au maniement des armes courantes (mais pas des boucliers) et au port des armures légères.</p>', NULL, '<p>Compétences de classe : Artisanat, Bluff, Connaissances (folklore local), Contrefaçon, Crochetage, Déplacement silencieux, Désamorçage/sabotage, Détection, Diplomatie, Escalade, Escamotage, Estimation, Fouille, Intimidation, Maîtrise des cordes, Perception auditive, Profession, Psychologie, Saut.</p>', '<p>L''organisation connue sous le nom des Voleurs de l''Ombre est de loin la plus vaste et la plus prospère des guildes de voleurs de Faerûn. Sa réussite vient de son système de guildes entrelacées, chacune tournée vers la puissance et le profit. Depuis le quartier général d''Amn de l''organisation, cet ensemble de guildes se taille la part du lion des activités criminelles qui agitent la côte des Épées, mais elle n''en touche pas moins d''autres régions de Faerûn. Chaque membre de la guilde des Voleurs de l''Ombre d''Amn ne connaît que ses sbires, ses partenaires et son supérieur. Cette chape de secret protège l''organisation car les membres capturés ne peuvent- ainsi guère en « vendre » d''autres.</p>
<p>La plupart des voleurs de l''ombre d''Amn sont d''anciens roublards, niais certains spécialistes ont un passé de guerrier ou de rôdeur. Des prêtres de divinités maléfiques (plus particulièrement Mask et Shar) empruntent cette voie pour jouer un rôle précis sur le terrain. Enfin, ensorceleurs et magiciens jouent également un rôle de premier plan. Les voleurs de l''ombre sont passés maîtres dans l''art de la collaboration, de l''intimidation des braves gens, des roustes punitives et de l''acquisition de contacts de premier choix.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Voleur de l''Ombre d''Amn' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Voleur de l''Ombre d''Amn' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 2, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '1', 3, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '2', 3, 1, 1, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '3', 4, 1, 1, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '3', 4, 1, 1, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Attaque sournoise', '<p>Ce pouvoir fonctionne sur le même principe que l''aptitude de roublard éponyme. Les dégâts supplémentaires infligés augmentent de +1d6 au niveau 1, +2d6 au niveau 3 et +3d6 au niveau 5. Si le personnage jouit déjà d''un bonus d''attaque sournoise (issu de niveaux de roublard, par exemple), les dégâts se cumulent. De plus, les niveaux de voleur de l''ombre d''Amn s''ajoutent à ceux d''autres classes (comme roublard ou assassin) pour, ce qui est de passer outre l''esquive instinctive supérieure d''adversaires.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Attaque sournoise' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Double langage', '<p>Le voleur de l''ombre d''Amn développe des trésors d''ingéniosité dès qu''il s''agit de se tirer d''un mauvais pas. Au niveau 1, il bénéficie d''un bonus de +2 aux tests de Bluff et Diplomatie.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Double langage' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Don supplémentaire', '<p>Aux niveaux 2 et4, le voleur de l''ombre d''Amn gagne un don supplémentaire de son choix parmi la liste suivante : Arme de prédilection (au choix). Attaque en finesse, Combat en aveugle, Discret, Doigts de fée. Expertise du combat. Fourberie, Funambule, Incantation silencieuse, Incantation statique, Maniement d''une arme exotique (arbalète de poing ou shuriken), Négociation, Persuasion, Pistage, Prestige, Réflexes surhumains. Savoir-faire mécanique. Science de la feinte. Talent (compétence de voleur de l''ombre d''Amn), Vigilance et Voltigeur. Le personnage doit satisfaire aux conditions du don choisi.</p>', NULL, @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Don supplémentaire' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Esquive instinctive', '<p>Dès le niveau 2, le voleur de l''ombre d''Amn peut réagir instinctivement avant même que ses sens ne décèlent une menace. Il conserve son bonus de Dextérité à la CA même s''il est pris au dépourvu ou attaqué par un adversaire invisible (il perd toujours ce bonus s''il est immobilisé). Si le personnage possède déjà cette aptitude grâce à une autre classe, il obtient l''esquive instinctive supérieure (cf. voir ci-dessous) au lieu de l''esquive instinctive.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Esquive instinctive' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Réputation', '<p>Au niveau 3, l''infamie du voleur de l''ombre d''Amn lui confère un bonus de +1 en Prestige. Ce bonus passe à +2 au niveau 4 et à +3 au niveau 5. Habituellement, un voleur de l''ombre d''Amn qui dispose de suivants possède également un repaire permanent en ville, ce qui lui confère un bonus supplémentaire de +2 en Prestige.</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Réputation' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Esquive instinctive supérieure', '<p>Au niveau 5, le voleur de l''ombre d''Amn ne peut plus être pris en tenaille, car il pare les assauts de ses adversaires avec autant d''aisance que s''ils venaient tous de la même direction. Les roublards ne peuvent plus lui porter d''attaques sournoises en le prenant en tenaille, à moins d''avoir au moins 4 niveaux de roublard de plus que le personnage n''en a lui-même.</p>
<p>Si le personnage possède déjà l''aptitude d''esquive instinctive supérieure, les niveaux des différentes classes proposant cette aptitude se cumulent pour déterminer le niveau de roublard nécessaire pour le prendre en tenaille.</p>
<p>Dons liés aux aptitudes</p>
<p><strong>Attaque sournoise</strong> : Attaque commotionnante, Attaque défigurante, Attaque persistante, Attaque sournoise d’opportunité (épique), Attaque sournoise démoniaque, Attaque sournoise retardée, Coup à la gorge, Coup habile, Coup sacré, Coupe-jarret, Dégâts persistants (épique), Drain d’esprit, Embusqué rapide, Frappe assourdissante, Frappe de feu draconique, Frappe débilitante, Frappe des ténèbres, Frappe du loup, Frappe éventrente, Frappe fièvreuse, Frappe hémorragique, Frappe indigo, Frappe miséricordieuse, Frappe paralysante, Frappe silencieuse, Frappe terrifiante, Frappe venimeuse, Hors-la-loi audacieux, Hors-la-loi sacré, Influx de démolition, Inquisiteur dévot, Lâche, Leçons de la nature, Lutte sauvage, Roublard ascétique, Science de l’attaque mortelle (épique), Science de l’attaque sournoise (épique), Spécialiste des ennemis</p>
<p><strong>Esquive instinctive</strong> : Camouflage personnel (épique)</p>
<p><strong>Esquive instinctive supérieure</strong> : Intouchable</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Esquive instinctive supérieure' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, '+1d6', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Attaque sournoise' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Double langage' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Don supplémentaire' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Esquive instinctive' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, '+2d6', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Attaque sournoise' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 3, '+1', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Réputation' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 3);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Don supplémentaire' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, '+2', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Réputation' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, '+3d6', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Attaque sournoise' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Esquive instinctive' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, '+3', 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Réputation' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 3, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 3 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'folklore local'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'folklore local');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 6, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 6 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 7, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 7 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 10, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 10 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 11, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 11 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 12, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 12 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 13, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 13 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 18, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 18 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 19, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 19 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 20, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 20 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 22, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 22 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 23, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 23 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 25, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 25 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 27, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 27 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 30, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 30 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 33, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 33 AND ccomp_precision = '');

-- ===== Yathrinshee

INSERT INTO dd_classes (cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax, cla_pointsCompetences, cla_conditions, cla_armes, cla_sorts, cla_competences, cla_description, cla_res_id, cla_public, cla_visible, cla_ruleset_var_id)
SELECT 'Yathrinshee', 'Y', 2, 4, 10, 2, '<p><strong>Sexe.</strong> Féminin</p>
<p><strong>Race.</strong> Drow</p>
<p><strong>Compétences.</strong> Degré de maîtrise de 7 en Connaissances (mystères), degré de maîtrise-de 7 en Connaissances (religion), degré de maîtrise de 3 en Représentation (chant)</p>
<p><strong>Dons.</strong> École renforcée (Nécromancie), Nécrophile</p>
<p><strong>Sorts.</strong> Faculté de lancer animation des morts en qualité de sort de magie divine et main spectrale en qualité de sort de magie profane</p>
<p><strong>Divinité tutélaire.</strong> Kiaransalee</p>', '<p>La yathrinshee est formée au maniement du fouet, mais elle ne gagne aucune formation au maniement des boucliers, ni au port des armures.</p>', '<p>Aux niveaux 2 3, 5, 6, 8 et 9, le personnage obtient un niveau effectif de jeteur de sorts pour une de ses classes de lanceur de sorts divins et une de ses classes de lanceurs de sorts profanes précédentes. La yathrinshee obtient les sorts par jour et le niveau de lanceur de sorts d''un personnage de son niveau effectif. Par contre, il ne gagne aucun des autres avantages accompagnant habituellement ce niveau (dons de métamagie ou de création d''objets, etc.). Par exemple, une prêtresse 5/magicienne 3 qui prend trois niveaux de yathrinshee a accès aux mêmes sorts qu''une prêtresse 7/magicienne 5. Cependant, son familier ne gagne pas de nouveaux pouvoirs.</p>
<p>Si la yathrinshee possède plusieurs classes de lanceur de sorts divins ou plusieurs classes de lanceur de sorts profanes, le niveau effectif ne s''applique qu''à une classe de chaque, au choix du personnage.</p>', '<p>Compétences de classe : Art de la magie, Artisanat, Concentration, Connaissances (toutes), Fouille, Profession.</p>', '<p>Étant la déesse des morts-vivants, Kiaransalee aime les serviteurs qui combinent aptitudes de prêtre et talents de chercheur en matière d''énergie négative et de nécromancie. Les yathrinshees, les prêtresses d''élite de Kiaransalee, sont de puissantes utilisatrices de nécromancie, divine et profane. Pour devenir yathrinshee, une prêtresse doit connaître la magie divine et la magie profane. Presque toutes les yathrinshees ont un passé de prêtresse et de magicienne, mais quelques-unes ont des talents d''ensorceleuse. La plupart sont des nécromanciennes plutôt que des magiciennes généralistes. Les conditions liées aux facultés de lanceuses de sorts tiennent généralement les représentantes des autres classes à l''écart de cette voie. Les yathrinshees sont les leaders de l''Église secrète de Kiaransalee. Elles mènent les disciples, aussi bien dans le cadre du culte qu''au niveau des desseins de l''Église, conspirant contre les ennemis de la déesse et terrassant ses adversaires avant de les réanimer sous la forme de morts-vivants.</p>', 63, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classes WHERE cla_nom = 'Yathrinshee' AND cla_res_id = 63 AND cla_ruleset_var_id = 1);

SET @cla = (SELECT cla_id FROM dd_classes WHERE cla_nom = 'Yathrinshee' AND cla_res_id = 63 AND cla_ruleset_var_id = 1 LIMIT 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 1, '0', 0, 0, 2, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 1);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 2, '1', 0, 0, 3, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 2);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 3, '1', 1, 1, 3, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 3);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 4, '2', 1, 1, 4, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 4);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 5, '2', 1, 1, 4, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 5);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 6, '3', 2, 2, 5, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 6);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 7, '3', 2, 2, 5, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 7);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 8, '4', 2, 2, 6, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 8);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 9, '4', 3, 3, 6, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 9);

INSERT INTO dd_classe_niveau (cn_cla_id, cn_niveau, cn_bba, cn_reflexes, cn_vigueur, cn_volonte, cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif)
SELECT @cla, 10, '5', 3, 3, 7, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_niveau WHERE cn_cla_id = @cla AND cn_niveau = 10);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Intimidation des morts-vivants', '<p>Les niveaux de yathrinshee du personnage s''ajoutent à ceux de prêtresse pour ce qui est des tentatives d''intimidation et de contrôle des morts-vivants. Par exemple, une prêtresse 5/magicienne 3/yathrinshee 2 intimide les morts-vivants comme une prêtresse 7.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Intimidation des morts-vivants' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Nécromancienne', '<p>La yathrinshee exerce un pouvoir incroyable sur la mort. Quand elle lance un sort de l''école de Nécromancie, tous ses niveaux de lanceur de sorts se cumulent pour ce qui est de fixer son niveau de lanceur de sorts effectif. Elle ne gagne pas de sorts de plus haut niveau ou de sorts supplémentaires chaque jour, mais ceux qu''elle jette sont beaucoup plus efficaces.</p>
<p>Par exemple, une prétresse 5/magicienne 3/yathrinshee 3 a gagné deux niveaux de lanceur de sorts effectifs dans les Classes de prêtre et de magicien, ce qui lui confère les facultés de lanceur de sorts d''une prêtresse 7/magicienne 5. Ainsi, quand elle lance un sort de Nécromancie, divin ou profane, son niveau de lanceur de sorts effectif est égal à 12 (prêtre 7 + magicien 5).</p>', 'ext', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Nécromancienne' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Lamentations', '<p>Une fois par jour, une yathrinshee de niveau 2 ou plus peut entonner une complainte capable de troubler les adversaires qui affrontent des morts-vivants. En effet, -les morts-vivants situés dans un rayon de 9 mètres bénéficient d''une attaque de regard identique au regard déstabilisant d''un diable à chaînes. De plus, les créatures qui croisent le regard de la yathrinshee doivent réussir un jet de Volonté (DD 10 + niveau de yathrinshee du personnage + son modificateur de Charisme) sous peine de subir un malus de -2 aux jets d''attaque pendant 1d3 rounds. Elles y voient les visages d''êtres chers disparus ou d''ennemis jurés.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Lamentations' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Protection contre la mort', '<p>Une yathrinshee de niveau 4 ou plus est immunisée contre les effets de mort et d''énergie négative comme si elle jouissait d''un sort de protection contre la mort. À la place, une yathrinshee mort-vivante bénéficie d''un bonus de +4 en résistance au renvoi. Cet avantage se cumule à toute résistance au renvoi des morts-vivants existante.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Protection contre la mort' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Malédiction macabre', '<p>Une créature tuée par une yathrinshee de niveau 5 ou plus est instantanément réanimée sous la forme d''un zombi placé sous le contrôle du personnage.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Malédiction macabre' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Zone de profanation', '<p>À partir du niveau 7, la yathrinshee est en permanence entourée par une aura d''énergie négative de 6 mètres de rayon. Pour le reste, l''effet est identique au sort profanation.</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Zone de profanation' AND cap_classe_initiale = @cla);

INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type, cap_classe_initiale)
SELECT 'Mélopée funèbre', '<p>Au niveau 10, la yathrinshee est capable d''entonner une mélopée funèbre, 1 fois par jour. Ce pouvoir fonctionne sur le même principe que le sort plainte d''outre-tombe, si ce n''est qu''il affecte toutes les créatures situées dans une étendue de 9 mètres de rayon centrée sur le personnage.</p>
<p>Dons liés aux aptitudes</p>
<p><strong>Intimidation des morts-vivants</strong> : Armes glorieuses, Armes hantées, Aura profane, Bouclier divin, Chant divin, Coup spectral (épique), Défense impie, Déni de la résistance (épique), Disciple du soleil, Esprit divin, Essentia divine, Explosion impie, Extension de renvoi, Garde divine, Hors-la-loi sacré, Maîtrise des morts-vivants (épique), Métamagie divine, Précision divine, Puissance divine, Puissance magique divine, Purge divine, Rayonnement d’énergie négative (épique), Récupération de sort divine, Renforcement malfaisant, Renvoi planaire (épique), Renvoi rapide, Résistance divine, Sangsue malfaisante, Seigneur du désespoir, Spontanéité de domaine, Vengeance divine, Via Negativa, Vigueur divine, Vigueur malfaisante, Vitesse divine, Zone d’animation (épique)</p>', 'sur', @cla
WHERE NOT EXISTS (SELECT 1 FROM dd_capacites_speciales WHERE cap_nom = 'Mélopée funèbre' AND cap_classe_initiale = @cla);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Intimidation des morts-vivants' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 1, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Nécromancienne' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 1);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 2, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Lamentations' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 2);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 4, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Protection contre la mort' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 4);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 5, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Malédiction macabre' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 5);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 7, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Zone de profanation' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 7);

INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision, cc_nb_choix)
SELECT @cla, c.cap_id, 10, NULL, 0 FROM dd_capacites_speciales c WHERE c.cap_nom = 'Mélopée funèbre' AND c.cap_classe_initiale = @cla
AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite x WHERE x.cc_cla_id = @cla AND x.cc_cap_id = c.cap_id AND x.cc_niveau = 10);

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 2, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 2 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 76, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 76 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 4, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 4 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 5, 'toutes'
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 5 AND ccomp_precision = 'toutes');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 22, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 22 AND ccomp_precision = '');

INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ccomp_precision)
SELECT @cla, 29, ''
WHERE NOT EXISTS (SELECT 1 FROM dd_classe_competence WHERE ccomp_cla_id = @cla AND ccomp_comp_id = 29 AND ccomp_precision = '');
