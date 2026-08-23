-- Import des dons DD2024 — Manuel des Joueurs 2024, chapitre 5 « Dons » (p. 207-211)
-- Généré le 2026-08-15 depuis MDJ_2024_v1-extrait_dons.pdf
--
-- Périmètre : les dons du PDF à partir de « Protection légère » qui sont absents de la base.
-- Les 10 dons de Style de combat (dado 21) et les 7 Faveurs épiques déjà présentes
-- (source SRD 5.2.1, res_id 93) ne sont volontairement pas touchés.
--
-- Paramètres fixes : do_res_id = 91 (Manuel des Joueurs 2024)
--                    do_ruleset_var_id = 2 (DD2024)
--                    do_camp_id = NULL, do_public = 1, do_visible = 1
--                    do_page_source = 91
--
-- Chaque INSERT est protégé par un NOT EXISTS sur (do_nom, do_ruleset_var_id) :
-- le script peut être rejoué sans créer de doublon.

START TRANSACTION;

-- Protection légère
INSERT INTO dd_dons (do_nom, do_dado_id, do_conditions, do_texte, do_resume, do_res_id, do_camp_id, do_public, do_visible, do_ruleset_var_id, do_page_source)
SELECT 'Protection légère', 19, 'niveau 4 ou supérieur',
       '<p><strong>Vous recevez les b&eacute;n&eacute;fices suivants.</strong></p>
<p><strong>Augmentation de caract&eacute;ristique</strong>. Votre valeur de Force ou de Dext&eacute;rit&eacute; augmente de 1, jusqu''&agrave; un maximum de 20.</p>
<p><strong>Formation aux armures</strong>. Vous recevez la formation aux armures l&eacute;g&egrave;res et aux boucliers.</p>',
       '', 91, NULL, 1, 1, 2, 91
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM dd_dons WHERE do_nom = 'Protection légère' AND do_ruleset_var_id = 2
);

-- Protection lourde
INSERT INTO dd_dons (do_nom, do_dado_id, do_conditions, do_texte, do_resume, do_res_id, do_camp_id, do_public, do_visible, do_ruleset_var_id, do_page_source)
SELECT 'Protection lourde', 19, 'niveau 4 ou supérieur, formation aux armures intermédiaires',
       '<p><strong>Vous recevez les b&eacute;n&eacute;fices suivants.</strong></p>
<p><strong>Augmentation de caract&eacute;ristique</strong>. Votre valeur de Force ou de Constitution augmente de 1, jusqu''&agrave; un maximum de 20.</p>
<p><strong>Formation aux armures</strong>. Vous recevez la formation aux armures lourdes.</p>',
       '', 91, NULL, 1, 1, 2, 91
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM dd_dons WHERE do_nom = 'Protection lourde' AND do_ruleset_var_id = 2
);

-- Résilient
INSERT INTO dd_dons (do_nom, do_dado_id, do_conditions, do_texte, do_resume, do_res_id, do_camp_id, do_public, do_visible, do_ruleset_var_id, do_page_source)
SELECT 'Résilient', 19, 'niveau 4 ou supérieur',
       '<p><strong>Vous recevez les b&eacute;n&eacute;fices suivants.</strong></p>
<p><strong>Augmentation de caract&eacute;ristique</strong>. Choisissez une caract&eacute;ristique pour laquelle vous n''avez pas la ma&icirc;trise des jets de sauvegarde. La valeur de la caract&eacute;ristique choisie augmente de 1, jusqu''&agrave; un maximum de 20.</p>
<p><strong>Ma&icirc;trise des jets de sauvegarde</strong>. Vous recevez la ma&icirc;trise des jets de sauvegarde associ&eacute;s &agrave; la caract&eacute;ristique choisie.</p>',
       '', 91, NULL, 1, 1, 2, 91
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM dd_dons WHERE do_nom = 'Résilient' AND do_ruleset_var_id = 2
);

-- Sentinelle
INSERT INTO dd_dons (do_nom, do_dado_id, do_conditions, do_texte, do_resume, do_res_id, do_camp_id, do_public, do_visible, do_ruleset_var_id, do_page_source)
SELECT 'Sentinelle', 19, 'niveau 4 ou supérieur, Force ou Dextérité 13 ou plus',
       '<p><strong>Vous recevez les b&eacute;n&eacute;fices suivants.</strong></p>
<p><strong>Augmentation de caract&eacute;ristique</strong>. Votre valeur de Force ou de Dext&eacute;rit&eacute; augmente de 1, jusqu''&agrave; un maximum de 20.</p>
<p><strong>Gardien</strong>. Aussit&ocirc;t apr&egrave;s qu''une cr&eacute;ature situ&eacute;e dans un rayon de 1,50 m entreprend l''action D&eacute;sengagement ou touche une cible autre que vous avec une attaque, vous pouvez effectuer une attaque d''Opportunit&eacute; contre cette cr&eacute;ature.</p>
<p><strong>Immobilisation</strong>. Lorsque vous touchez une cr&eacute;ature avec une attaque d''Opportunit&eacute;, sa Vitesse devient 0 pour le reste du tour en cours.</p>',
       '', 91, NULL, 1, 1, 2, 91
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM dd_dons WHERE do_nom = 'Sentinelle' AND do_ruleset_var_id = 2
);

-- Télékinésiste
INSERT INTO dd_dons (do_nom, do_dado_id, do_conditions, do_texte, do_resume, do_res_id, do_camp_id, do_public, do_visible, do_ruleset_var_id, do_page_source)
SELECT 'Télékinésiste', 19, 'niveau 4 ou supérieur',
       '<p><strong>Vous recevez les b&eacute;n&eacute;fices suivants.</strong></p>
<p><strong>Augmentation de caract&eacute;ristique</strong>. Votre valeur d''Intelligence, de Sagesse ou de Charisme augmente de 1, jusqu''&agrave; un maximum de 20.</p>
<p><strong>T&eacute;l&eacute;kin&eacute;sie mineure</strong>. Vous apprenez le sort main du mage. Vous pouvez le lancer sans composante verbale ni somatique, pouvez rendre la main spectrale Invisible, tandis que sa port&eacute;e et la distance maximale qui vous en s&eacute;pare augmentent toutes deux de 9 m lorsque vous le lancez. La caract&eacute;ristique d''incantation associ&eacute;e &agrave; ce sort est celle que le don a augment&eacute;e.</p>
<p><strong>Bourrade t&eacute;l&eacute;kin&eacute;tique</strong>. Par une action Bonus, vous pouvez tenter de pousser une cr&eacute;ature que vous voyez dans un rayon de 9 m, par t&eacute;l&eacute;kin&eacute;sie. La cible doit alors r&eacute;ussir un jet de sauvegarde de Force (DD &eacute;gal &agrave; 8 + votre bonus de ma&icirc;trise + le modificateur de la caract&eacute;ristique augment&eacute;e par le don), sous peine d''&ecirc;tre d&eacute;plac&eacute;e de 1,50 m, vers vous ou loin de vous.</p>',
       '', 91, NULL, 1, 1, 2, 91
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM dd_dons WHERE do_nom = 'Télékinésiste' AND do_ruleset_var_id = 2
);

-- Télépathe
INSERT INTO dd_dons (do_nom, do_dado_id, do_conditions, do_texte, do_resume, do_res_id, do_camp_id, do_public, do_visible, do_ruleset_var_id, do_page_source)
SELECT 'Télépathe', 19, 'niveau 4 ou supérieur',
       '<p><strong>Vous recevez les b&eacute;n&eacute;fices suivants.</strong></p>
<p><strong>Augmentation de caract&eacute;ristique</strong>. Votre valeur d''Intelligence, de Sagesse ou de Charisme augmente de 1, jusqu''&agrave; un maximum de 20.</p>
<p><strong>Parole t&eacute;l&eacute;pathique</strong>. Vous pouvez vous adresser par t&eacute;l&eacute;pathie &agrave; toute cr&eacute;ature que vous voyez dans un rayon de 18 m. Ces paroles t&eacute;l&eacute;pathiques sont prononc&eacute;es dans une langue que vous parlez, si bien que la cr&eacute;ature ne les comprend que si elle parle aussi cette langue. Cette communication ne conf&egrave;re pas &agrave; la cr&eacute;ature la facult&eacute; de vous r&eacute;pondre par t&eacute;l&eacute;pathie.</p>
<p><strong>D&eacute;tection des pens&eacute;es</strong>. Le sort d&eacute;tection des pens&eacute;es est consid&eacute;r&eacute; comme toujours pr&eacute;par&eacute; pour vous. Vous pouvez lancer ce sort sans d&eacute;penser d''emplacement de sort ni composante, sachant que vous devez ensuite terminer un Repos long avant de pouvoir le relancer par ce biais. Vous pouvez &eacute;galement le lancer avec vos &eacute;ventuels emplacements de sort de niveau ad&eacute;quat. La caract&eacute;ristique d''incantation associ&eacute;e &agrave; ce sort est celle que le don a augment&eacute;e.</p>',
       '', 91, NULL, 1, 1, 2, 91
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM dd_dons WHERE do_nom = 'Télépathe' AND do_ruleset_var_id = 2
);

-- Tireur d'élite
INSERT INTO dd_dons (do_nom, do_dado_id, do_conditions, do_texte, do_resume, do_res_id, do_camp_id, do_public, do_visible, do_ruleset_var_id, do_page_source)
SELECT 'Tireur d''élite', 19, 'niveau 4 ou supérieur, Dextérité 13 ou plus',
       '<p><strong>Vous recevez les b&eacute;n&eacute;fices suivants.</strong></p>
<p><strong>Augmentation de caract&eacute;ristique</strong>. Votre valeur de Dext&eacute;rit&eacute; augmente de 1, jusqu''&agrave; un maximum de 20.</p>
<p><strong>Contournement d''abri</strong>. Vos attaques &agrave; distance avec arme ne sont pas affect&eacute;es par l''Abri partiel et l''Abri sup&eacute;rieur.</p>
<p><strong>Tir au corps &agrave; corps</strong>. Vous trouver dans un rayon de 1,50 m d''un adversaire n''impose pas le D&eacute;savantage &agrave; vos jets d''attaque avec une arme &agrave; distance.</p>
<p><strong>Longue port&eacute;e</strong>. Attaquer &agrave; longue port&eacute;e n''impose pas de D&eacute;savantage &agrave; vos jets d''attaque avec une arme &agrave; distance.</p>',
       '', 91, NULL, 1, 1, 2, 91
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM dd_dons WHERE do_nom = 'Tireur d''élite' AND do_ruleset_var_id = 2
);

-- Trancheur
INSERT INTO dd_dons (do_nom, do_dado_id, do_conditions, do_texte, do_resume, do_res_id, do_camp_id, do_public, do_visible, do_ruleset_var_id, do_page_source)
SELECT 'Trancheur', 19, 'niveau 4 ou supérieur',
       '<p><strong>Vous recevez les b&eacute;n&eacute;fices suivants.</strong></p>
<p><strong>Augmentation de caract&eacute;ristique</strong>. Votre valeur de Force ou de Dext&eacute;rit&eacute; augmente de 1, jusqu''&agrave; un maximum de 20.</p>
<p><strong>Coupe-jarret</strong>. Une fois par tour, lorsque vous touchez une cr&eacute;ature avec une attaque qui inflige des d&eacute;g&acirc;ts tranchants, vous pouvez r&eacute;duire la Vitesse de cette cr&eacute;ature de 3 m jusqu''au d&eacute;but de votre tour suivant.</p>
<p><strong>Critique renforc&eacute;</strong>. Lorsque vous obtenez un Coup critique qui inflige des d&eacute;g&acirc;ts tranchants &agrave; une cr&eacute;ature, celle-ci subit le D&eacute;savantage &agrave; ses jets d''attaque jusqu''au d&eacute;but de votre tour suivant.</p>',
       '', 91, NULL, 1, 1, 2, 91
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM dd_dons WHERE do_nom = 'Trancheur' AND do_ruleset_var_id = 2
);

-- Tueur de mages
INSERT INTO dd_dons (do_nom, do_dado_id, do_conditions, do_texte, do_resume, do_res_id, do_camp_id, do_public, do_visible, do_ruleset_var_id, do_page_source)
SELECT 'Tueur de mages', 19, 'niveau 4 ou supérieur',
       '<p><strong>Vous recevez les b&eacute;n&eacute;fices suivants.</strong></p>
<p><strong>Augmentation de caract&eacute;ristique</strong>. Votre valeur de Force ou de Dext&eacute;rit&eacute; augmente de 1, jusqu''&agrave; un maximum de 20.</p>
<p><strong>Briseur de concentration</strong>. Lorsque vous infligez des d&eacute;g&acirc;ts &agrave; une cr&eacute;ature qui se concentre, elle subit le D&eacute;savantage au jet de sauvegarde qu''elle effectue pour maintenir sa Concentration.</p>
<p><strong>Esprit pr&eacute;serv&eacute;</strong>. Si vous ratez un jet de sauvegarde d''Intelligence, de Sagesse ou de Charisme, vous pouvez d&eacute;cider de le r&eacute;ussir tout de m&ecirc;me. Une fois ce b&eacute;n&eacute;fice utilis&eacute;, vous devez terminer un Repos court ou long pour pouvoir y recourir de nouveau.</p>',
       '', 91, NULL, 1, 1, 2, 91
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM dd_dons WHERE do_nom = 'Tueur de mages' AND do_ruleset_var_id = 2
);

-- Faveur de compétence
INSERT INTO dd_dons (do_nom, do_dado_id, do_conditions, do_texte, do_resume, do_res_id, do_camp_id, do_public, do_visible, do_ruleset_var_id, do_page_source)
SELECT 'Faveur de compétence', 20, 'niveau 19 ou supérieur',
       '<p><strong>Vous recevez les b&eacute;n&eacute;fices suivants.</strong></p>
<p><strong>Augmentation de caract&eacute;ristique</strong>. Une valeur de caract&eacute;ristique de votre choix augmente de 1, jusqu''&agrave; un maximum de 30.</p>
<p><strong>Polyvalence totale</strong>. Vous recevez la ma&icirc;trise de toutes les comp&eacute;tences.</p>
<p><strong>Expertise</strong>. Choisissez une comp&eacute;tence pour laquelle vous n''avez pas l''Expertise. Vous recevez l''Expertise dans cette comp&eacute;tence.</p>',
       '', 91, NULL, 1, 1, 2, 91
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM dd_dons WHERE do_nom = 'Faveur de compétence' AND do_ruleset_var_id = 2
);

-- Faveur de récupération
INSERT INTO dd_dons (do_nom, do_dado_id, do_conditions, do_texte, do_resume, do_res_id, do_camp_id, do_public, do_visible, do_ruleset_var_id, do_page_source)
SELECT 'Faveur de récupération', 20, 'niveau 19 ou supérieur',
       '<p><strong>Vous recevez les b&eacute;n&eacute;fices suivants.</strong></p>
<p><strong>Augmentation de caract&eacute;ristique</strong>. Une valeur de caract&eacute;ristique de votre choix augmente de 1, jusqu''&agrave; un maximum de 30.</p>
<p><strong>Baroud d''honneur</strong>. Lorsque vous devriez &ecirc;tre r&eacute;duit &agrave; 0 point de vie, vous pouvez d&eacute;cider de tomber &agrave; 1 point de vie et de regagner un nombre de pv &eacute;gal &agrave; la moiti&eacute; de votre maximum de points de vie. Une fois ce b&eacute;n&eacute;fice utilis&eacute;, vous devez terminer un Repos long pour pouvoir y recourir de nouveau.</p>
<p><strong>Regain de vitalit&eacute;</strong>. Vous disposez d''une r&eacute;serve de dix d10. Par une action Bonus, vous pouvez d&eacute;penser des d&eacute;s de cette r&eacute;serve et les lancer pour r&eacute;cup&eacute;rer autant de points de vie que le total obtenu. Cette r&eacute;serve se reconstitue int&eacute;gralement lorsque vous terminez un Repos long.</p>',
       '', 91, NULL, 1, 1, 2, 91
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM dd_dons WHERE do_nom = 'Faveur de récupération' AND do_ruleset_var_id = 2
);

-- Faveur de résistance aux énergies
INSERT INTO dd_dons (do_nom, do_dado_id, do_conditions, do_texte, do_resume, do_res_id, do_camp_id, do_public, do_visible, do_ruleset_var_id, do_page_source)
SELECT 'Faveur de résistance aux énergies', 20, 'niveau 19 ou supérieur',
       '<p><strong>Vous recevez les b&eacute;n&eacute;fices suivants.</strong></p>
<p><strong>Augmentation de caract&eacute;ristique</strong>. Une valeur de caract&eacute;ristique de votre choix augmente de 1, jusqu''&agrave; un maximum de 30.</p>
<p><strong>R&eacute;sistance aux &eacute;nergies</strong>. Vous recevez la R&eacute;sistance &agrave; deux des types de d&eacute;g&acirc;ts suivants, &agrave; votre convenance : acide, feu, foudre, froid, n&eacute;crotiques, poison, psychiques, radiants ou tonnerre. Chaque fois que vous terminez un Repos long, vous pouvez modifier ces choix.</p>
<p><strong>D&eacute;tournement d''&eacute;nergie</strong>. Lorsque vous subissez des d&eacute;g&acirc;ts de l''un des types choisis pour le b&eacute;n&eacute;fice R&eacute;sistance aux &eacute;nergies, vous pouvez jouer votre R&eacute;action pour diriger ces d&eacute;g&acirc;ts du m&ecirc;me type vers une autre cr&eacute;ature que vous voyez dans un rayon de 18 m, et qui ne se trouve pas derri&egrave;re un Abri total. Dans ce cas, la cr&eacute;ature doit r&eacute;ussir un jet de sauvegarde de Dext&eacute;rit&eacute; (DD &eacute;gal &agrave; 8 + votre modificateur de Constitution + votre bonus de ma&icirc;trise) ou subir 2d12 + votre modificateur de Constitution d&eacute;g&acirc;ts du m&ecirc;me type.</p>',
       '', 91, NULL, 1, 1, 2, 91
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM dd_dons WHERE do_nom = 'Faveur de résistance aux énergies' AND do_ruleset_var_id = 2
);

-- Faveur de vigueur
INSERT INTO dd_dons (do_nom, do_dado_id, do_conditions, do_texte, do_resume, do_res_id, do_camp_id, do_public, do_visible, do_ruleset_var_id, do_page_source)
SELECT 'Faveur de vigueur', 20, 'niveau 19 ou supérieur',
       '<p><strong>Vous recevez les b&eacute;n&eacute;fices suivants.</strong></p>
<p><strong>Augmentation de caract&eacute;ristique</strong>. Une valeur de caract&eacute;ristique de votre choix augmente de 1, jusqu''&agrave; un maximum de 30.</p>
<p><strong>Sant&eacute; fortifi&eacute;e</strong>. Votre maximum de points de vie augmente de 40. Chaque fois que vous regagnez des points de vie, vous pouvez en outre regagner un nombre de pv suppl&eacute;mentaires &eacute;gal &agrave; votre modificateur de Constitution. Une fois que vous avez regagn&eacute; ces points de vie suppl&eacute;mentaires, vous ne pouvez plus faire ainsi jusqu''au d&eacute;but de votre tour suivant.</p>',
       '', 91, NULL, 1, 1, 2, 91
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM dd_dons WHERE do_nom = 'Faveur de vigueur' AND do_ruleset_var_id = 2
);

-- Faveur de vitesse
INSERT INTO dd_dons (do_nom, do_dado_id, do_conditions, do_texte, do_resume, do_res_id, do_camp_id, do_public, do_visible, do_ruleset_var_id, do_page_source)
SELECT 'Faveur de vitesse', 20, 'niveau 19 ou supérieur',
       '<p><strong>Vous recevez les b&eacute;n&eacute;fices suivants.</strong></p>
<p><strong>Augmentation de caract&eacute;ristique</strong>. Une valeur de caract&eacute;ristique de votre choix augmente de 1, jusqu''&agrave; un maximum de 30.</p>
<p><strong>Expert en d&eacute;sengagement</strong>. Par une action Bonus, vous pouvez entreprendre l''action D&eacute;sengagement, qui met &eacute;galement un terme &agrave; l''&eacute;tat Agripp&eacute;.</p>
<p><strong>Prestesse</strong>. Votre Vitesse augmente de 9 m.</p>',
       '', 91, NULL, 1, 1, 2, 91
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM dd_dons WHERE do_nom = 'Faveur de vitesse' AND do_ruleset_var_id = 2
);

COMMIT;

-- Contrôle
-- SELECT do_id, do_nom, do_dado_id, do_res_id FROM dd_dons
--  WHERE do_ruleset_var_id = 2 AND do_res_id = 91 ORDER BY do_dado_id, do_nom;
