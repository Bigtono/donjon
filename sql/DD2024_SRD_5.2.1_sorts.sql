-- =====================================================================
-- Import sorts SRD 5.2.1 (DD2024) — LOT 1 : lettre A (27 sorts)
-- Cible : dd_sorts (so_id 2082..2108) + dd_sortclasse (sc_id dès 7272)
-- res_id=93 (SRD) | ruleset_var_id=2 (DD2024) | camp_id NULL (compendium global)
-- Réexécution : DELETE FROM dd_sortclasse WHERE sc_so_id BETWEEN 2082 AND 2108;
--              DELETE FROM dd_sorts WHERE so_id BETWEEN 2082 AND 2108;
-- =====================================================================
SET NAMES utf8mb4;
START TRANSACTION;

-- [2082] Agrandissement/rapetissement (niv 2, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2082, 'Agrandissement/rapetissement', 2, 4, NULL, 1, 1, 1, 0, 0, 'une pincée de poudre de fer', '9 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Pour toute la durée, le sort agrandit ou rapetisse une créature ou un objet que vous voyez à portée (voir l''effet retenu ci-après). Dans le cas d''un objet, il ne doit être porté par personne. Si la cible est une créature non consentante, elle effectue un jet de sauvegarde de Constitution. En cas de réussite, le sort est sans effet.</p>
<p>Tout ce que porte une créature ciblée change également de taille. Tout objet qu''elle lâche retrouve aussitôt sa taille normale. Les armes lancées et les projectiles retrouvent aussi leur taille dès qu''ils ont touché ou raté leur cible.</p>
<p>Agrandissement. La taille de la cible augmente d''une catégorie ; de taille M à G, par exemple. La cible a l''Avantage aux tests de Force et aux jets de sauvegarde de Force. Les attaques que la cible effectue avec une arme agrandie ou à mains nues infligent 1d4 dégâts supplémentaires quand elles touchent.</p>
<p>Rapetissement. La taille de la cible diminue d''une catégorie ; de taille M à P, par exemple. La cible subit le Désavantage aux tests de Force et aux jets de sauvegarde de Force. Les attaques que la cible effectue avec une arme rapetissée ou à mains nues infligent 1d4 dégâts de moins quand elles touchent (minimum de 1 dégât).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7272, 2082, 53, 2),
  (7273, 2082, 55, 2),
  (7274, 2082, 56, 2),
  (7275, 2082, 52, 2);

-- [2083] Aide (niv 2, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2083, 'Aide', 2, 5, NULL, 1, 1, 1, 0, 0, 'une bandelette de tissu blanc', '9 m', '', '', 'action', '8 heures', NULL, NULL, 0, 0, '<p>Choisissez jusqu''à trois créatures à portée. Le maximum de points de vie de chaque cible et ses points de vie actuels augmentent de 5 pour toute la durée.</p>
<p>Emplacement de niveau supérieur. Les points de vie de chaque cible augmentent de 5 de plus par niveau d''emplacement au-delà du 2e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7276, 2083, 53, 2),
  (7277, 2083, 54, 2),
  (7278, 2083, 55, 2),
  (7279, 2083, 59, 2),
  (7280, 2083, 60, 2);

-- [2084] Alarme (niv 1, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2084, 'Alarme', 1, 5, NULL, 1, 1, 1, 0, 0, 'une cloche et du fil d''argent', '9 m', '', '', '1 minute ou rituel', '8 heures', NULL, NULL, 0, 1, '<p>Vous disposez une alarme contre les intrus. Choisissez une porte, une fenêtre ou une zone à portée dont la taille n''excède pas un Cube de 6 m. Jusqu''à la fin du sort, vous êtes alerté chaque fois qu''une créature touche la zone protégée ou y pénètre. À l''incantation du sort, vous pouvez désigner des créatures qui ne déclencheront pas l''alarme. Vous choisissez également si l''alarme est mentale ou sonore :</p>
<p>Alarme mentale. L''alarme vous alerte par un signal psychique, à condition que vous soyez dans un rayon de 1,5 km de la zone protégée. Si vous dormez, ce signal vous réveille.</p>
<p>Alarme sonore. L''alarme produit le même son qu''une clochette, pendant 10 secondes, audible sur un rayon de 18 m de la zone protégée.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7281, 2084, 52, 1),
  (7282, 2084, 60, 1);

-- [2085] Aliénation (niv 8, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2085, 'Aliénation', 8, 3, NULL, 1, 1, 1, 0, 0, 'l''anneau seul d''un trousseau de clefs', '45 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous assaillez l''esprit d''une créature que vous voyez à portée. La cible effectue un jet de sauvegarde d''Intelligence.</p>
<p>En cas d''échec, elle subit 10d12 dégâts psychiques et ne peut pas lancer de sort ni entreprendre l''action Magie. À l''issue de chaque tranche de 30 jours, la cible réitère le JS et met un terme à l''effet en cas de réussite. Les sorts guérison, restauration suprême et souhait mettent également chacun fin à l''effet.</p>
<p>En cas de réussite, la cible subit uniquement la moitié de ces dégâts.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7283, 2085, 53, 8),
  (7284, 2085, 55, 8),
  (7285, 2085, 52, 8),
  (7286, 2085, 58, 8);

-- [2086] Allié planaire (niv 6, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2086, 'Allié planaire', 6, 6, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', '10 minutes', 'instantanée', NULL, NULL, 0, 0, '<p>Vous implorez l''assistance d''une entité d''outre-monde. L''être doit vous être familier : un dieu, un prince démon ou toute autre entité de puissance cosmique. Il dépêche un Céleste, un Élémentaire ou un Fiélon parmi ses fidèles pour vous porter assistance, et la créature désignée se matérialise dans un espace inoccupé à portée. Si vous connaissez un nom spécifique de créature, vous pouvez le prononcer à l''incantation du sort pour la solliciter nommément, mais rien ne vous garantit qu''une autre ne sera pas envoyée à sa place (à la discrétion du MJ).</p>
<p>Quand la créature se présente, rien ne la contraint à se comporter d''une manière ou d''une autre. Vous pouvez lui demander d''accomplir un service en contrepartie d''autre chose, mais elle n''est pas tenue d''y consentir. La tâche requise peut aller du simple au plus complexe. Pour pouvoir négocier les services de la créature, vous devez être en mesure de communiquer avec elle.</p>
<p>La contrepartie peut prendre diverses formes. On peut considérer qu''une tâche qui se mesure en minutes correspond à une rétribution de 100 po par minute. Une tâche qui s''exprime en heures, à 1 000 po de l''heure. Une tâche qui s''étale sur plusieurs jours (jusqu''à un maximum de 10), à 10 000 po par jour. Le MJ peut ajuster ces contreparties selon les circonstances. Les créatures n''ont pas pour habitude d''accepter les missions qui s''annoncent suicidaires.</p>
<p>Une fois la tâche accomplie ou la durée convenue écoulée, la créature retourne sur son plan d''origine après vous avoir fait son rapport. Si vous ne pouvez convenir d''une rémunération, elle repart sans attendre.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7287, 2086, 54, 6);

-- [2087] Amélioration de caractéristique (niv 2, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2087, 'Amélioration de caractéristique', 2, 4, NULL, 1, 1, 1, 0, 0, 'une plume ou une touffe de fourrure', 'contact', '', '', 'action', 'Concentration, jusqu''à 1 heure', NULL, NULL, 1, 0, '<p>Vous touchez physiquement une créature et choisissez entre Force, Dextérité, Intelligence, Sagesse et Charisme. Pour toute la durée, la cible a l''Avantage aux tests de caractéristique associés à la caractéristique retenue.</p>
<p>Emplacement de niveau supérieur. Vous pouvez cibler une créature supplémentaire par niveau d''emplacement au-delà du 2e. Vous pouvez opter pour une caractéristique différente pour chaque cible.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7288, 2087, 53, 2),
  (7289, 2087, 54, 2),
  (7290, 2087, 55, 2),
  (7291, 2087, 56, 2),
  (7292, 2087, 52, 2),
  (7293, 2087, 60, 2);

-- [2088] Amitié avec les animaux (niv 1, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2088, 'Amitié avec les animaux', 1, 3, NULL, 1, 1, 1, 0, 0, 'un peu de nourriture', '9 m', '', '', 'action', '24 heures', NULL, NULL, 0, 0, '<p>Ciblez une Bête que vous voyez à portée. La cible doit réussir un jet de sauvegarde de Sagesse sous peine de subir l''état Charmé pour toute la durée du sort. Si vous ou l''un de vos alliés infligez des dégâts à la cible, le sort prend fin.</p>
<p>Emplacement de niveau supérieur. Vous pouvez affecter une Bête supplémentaire par niveau d''emplacement au-delà du 1er.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7294, 2088, 53, 1),
  (7295, 2088, 55, 1),
  (7296, 2088, 60, 1);

-- [2089] Animation des morts (niv 3, Necromancie)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2089, 'Animation des morts', 3, 2, NULL, 1, 1, 1, 0, 0, 'une goutte de sang, un morceau de chair et une pincée de poudre d''os', '3 m', '', '', '1 minute', 'instantanée', NULL, NULL, 0, 0, '<p>Choisissez un tas d''os ou un cadavre à portée, tiré d''un Humanoïde de taille M ou P. La cible devient un Mort-vivant : un squelette si vous avez opté pour des os ou un zombi si vous avez choisi un cadavre (profil de la créature à « Monstres »).</p>
<p>À chacun de vos tours, vous pouvez consacrer une action Bonus à donner des ordres mentaux à toute créature que vous avez créée par ce sort et qui se trouve dans un rayon de 18 m. Vous pouvez ainsi contrôler plusieurs créatures, en les choisissant, à condition de leur intimer le même ordre. Sans instruction de votre part, la créature entreprend l''action Esquive et ne se déplace que pour éviter les dangers. Une fois qu''elle a reçu un ordre, la créature s''y soumet jusqu''à ce que la tâche soit accomplie.</p>
<p>La créature reste sous votre contrôle pendant 24 heures, après quoi elle cesse d''obéir aux ordres que vous lui avez donnés. Pour en garder le contrôle pendant 24 heures de plus, vous devez relancer ce sort sur lui avant la fin des 24 heures en cours. Relancer le sort ainsi réaffirme votre emprise sur un maximum de quatre créatures que vous avez animées par ce sort, au lieu d''en animer une nouvelle.</p>
<p>Emplacement de niveau supérieur. Vous prenez ou prolongez le contrôle de deux Morts-vivants supplémentaires par niveau d''emplacement au-delà du 3e. Chacune de ces créatures doit être issue d''un tas d''os ou cadavre différent.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7297, 2089, 54, 3),
  (7298, 2089, 52, 3);

-- [2090] Animation des objets (niv 5, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2090, 'Animation des objets', 5, 4, NULL, 1, 1, 0, 0, 0, NULL, '36 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Les objets s''animent selon vos ordres. Choisissez des objets non magiques à portée qui ne sont portés par personne, ne sont fixés à aucune surface et ne sont pas de taille Gig. Le maximum d''objets que vous pouvez animer est égal à votre modificateur de caractéristique d''incantation ; dans ce cadre, une cible de taille M ou inférieure compte pour un objet, une cible de taille G pour deux et une cible de taille TG pour trois.</p>
<p>Chaque cible s''anime, se dote de pattes et devient un Artificiel reprenant le profil de l''objet animé ; la créature reste sous votre contrôle jusqu''à la fin du sort ou qu''elle tombe à 0 point de vie. Chaque créature ainsi créée constitue un allié pour vous et vos alliés. Au combat, elle partage votre rang d''Initiative, mais elle joue son tour juste après vous.</p>
<p>Jusqu''à la fin du sort, vous pouvez par une action Bonus donner des ordres mentaux à toute créature que vous avez créée par ce sort et qui se trouve dans un rayon de 150 m. Sans instruction de votre part, la créature entreprend l''action Esquive et ne se déplace que pour éviter les dangers. Quand la créature tombe à 0 point de vie, elle retrouve sa forme de départ, tous les dégâts excédentaires étant répercutés sur celle-ci.</p>
<p>Emplacement de niveau supérieur. Les dégâts de Coup de la créature augmentent de 1d4 (taille M ou inférieure), 1d6 (taille G) ou 1d12 (taille TG) par niveau d''emplacement au-delà du 5e.</p>
<p>— Objet animé —<br>
Artificiel de taille TG ou inférieure, non aligné<br>
CA 15<br>
Pv 10 (taille M ou inférieure), 20 (G), 40 (TG)<br>
Vitesse 9 m<br>
For 16 (+3, JS +3) ; Dex 10 (+0, +0) ; Con 10 (+0, +0) ; Int 3 (−4, −4) ; Sag 3 (−4, −4) ; Cha 1 (−5, −5)<br>
Immunités poison, psychiques ; Charmé, Effrayé, Empoisonné, Épuisement, Paralysé<br>
Sens Vision aveugle 9 m ; Perception passive 6<br>
Langues comprend les langues que vous parlez<br>
FP aucun (PX 0 ; BM égal à votre bonus de maîtrise)<br>
Actions — Coup. Corps à corps : bonus égal à votre modificateur d''attaque des sorts, allonge 1,50 m. Touché : dégâts de force égaux à 1d4 + 3 (taille M ou inférieure), 2d6 + 3 + votre modificateur de caractéristique d''incantation (G), ou 2d12 + 3 + votre modificateur de caractéristique d''incantation (TG).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7299, 2090, 53, 5),
  (7300, 2090, 56, 5),
  (7301, 2090, 52, 5);

-- [2091] Antidétection (niv 3, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2091, 'Antidétection', 3, 5, NULL, 1, 1, 1, 0, 0, 'une pincée de poudre de diamant d''une valeur minimale de 25 po, que le sort détruit', 'contact', '', '', 'action', '8 heures', NULL, NULL, 0, 0, '<p>Pour toute la durée, vous cachez aux sorts de Divination une cible que vous touchez. La cible doit être une créature consentante, ou un lieu ou objet dont aucune dimension n''excède 3 m. Elle ne peut alors être ciblée par quelque sort de Divination que ce soit, ni perçue par des capteurs de scrutation magique.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7302, 2091, 53, 3),
  (7303, 2091, 52, 3),
  (7304, 2091, 60, 3);

-- [2092] Apaisement des émotions (niv 2, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2092, 'Apaisement des émotions', 2, 3, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Chaque Humanoïde pris dans une Sphère de 6 m de rayon centrée sur un point que vous choisissez à portée doit réussir un jet de sauvegarde de Charisme, sous peine d''être affecté par l''un des effets suivants (choisissez pour chaque créature) :</p>
<p>• La créature est immunisée contre les états Charmé et Effrayé jusqu''à la fin du sort. Si la créature était déjà Charmée ou Effrayée, ces états sont réprimés pour toute la durée.<br>
• Vous pouvez choisir des créatures envers lesquelles la cible est Hostile ; celle-ci devient indifférente à leur égard. Cette indifférence prend fin si la cible subit des dégâts ou est témoin de dégâts subis par ses alliés. Quand le sort prend fin, l''attitude de la créature revient à la normale.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7305, 2092, 53, 2),
  (7306, 2092, 54, 2);

-- [2093] Apparence trompeuse (niv 5, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2093, 'Apparence trompeuse', 5, 9, NULL, 1, 1, 0, 0, 0, NULL, '9 m', '', '', 'action', '8 heures', NULL, NULL, 0, 0, '<p>Vous modifiez de manière illusoire l''aspect des créatures de votre choix parmi celles que vous voyez à portée. Une créature non consentante peut effectuer un jet de sauvegarde de Charisme. En cas de réussite, elle n''est pas affectée par le sort.</p>
<p>Vous pouvez donner le même aspect à chaque cible ou varier les illusions. Le sort altère l''aspect du corps des cibles comme de leur équipement. Vous pouvez aussi les faire paraître plus grandes ou plus petites, individuellement, à concurrence de 30 cm, et les faire passer pour plus lourdes ou plus légères. Le nouvel aspect de chaque cible doit présenter la même configuration de membres que la sienne. Le sort persiste pour toute la durée.</p>
<p>Les changements apportés par le sort ne résistent pas à un examen physique. Une créature peut entreprendre l''action Étude pour examiner une cible et effectuer un test d''Intelligence (Investigation) assorti de votre DD de sauvegarde des sorts. En cas de réussite, elle se rend compte que la cible est déguisée.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7307, 2093, 53, 5),
  (7308, 2093, 56, 5),
  (7309, 2093, 52, 5);

-- [2094] Appel de destrier (niv 2, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2094, 'Appel de destrier', 2, 6, NULL, 1, 1, 0, 0, 0, NULL, '9 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous convoquez un être d''outre-monde qui se présente comme une monture fidèle en un espace inoccupé que vous choisissez à portée. Cette créature reprend le profil de la monture d''outre-monde. Si vous disposez déjà d''une telle monture par le biais de ce sort, elle est remplacée par la nouvelle.</p>
<p>Vous choisissez l''aspect de votre monture, un animal que l''on peut monter de taille G, comme un cheval, un chameau, un loup sanguinaire ou un grand cervidé. Chaque fois que vous lancez le sort, choisissez le type de créature de la monture : Céleste, Fée ou Fiélon, qui détermine certains traits du profil.</p>
<p>Combat. La monture constitue un allié pour vous et vos alliés. Au combat, elle partage votre rang d''Initiative et se gère comme une monture contrôlée lorsque vous la chevauchez. Si vous subissez l''état Neutralisé, la monture joue son tour juste après vous et agit de manière autonome en veillant à vous protéger.</p>
<p>Disparition de la monture. La monture disparaît si elle tombe à 0 point de vie ou si vous mourez. À sa disparition, elle laisse derrière elle tout ce qu''elle portait. Si vous relancez ce sort, vous décidez si vous convoquez la monture disparue ou une autre.</p>
<p>Emplacement de niveau supérieur. Le niveau de l''emplacement de sort s''applique chaque fois que le profil de jeu y fait référence.</p>
<p>— Monture d''outre-monde —<br>
Céleste, Fée ou Fiélon (à votre convenance) de taille G, Neutre<br>
CA 10 + 1 par niveau du sort<br>
Pv 5 + 10 par niveau du sort (la monture dispose d''un nombre de DV [d10] égal au niveau du sort)<br>
Vitesse 18 m, vol 18 m (sort du 4e niveau ou plus)<br>
For 18 (+4, JS +4) ; Dex 12 (+1, +1) ; Con 14 (+2, +2) ; Int 6 (−2, −2) ; Sag 12 (+1, +1) ; Cha 8 (−1, −1)<br>
Sens Perception passive 11<br>
Langues télépathie 1,5 km (fonctionne uniquement avec vous)<br>
FP aucun (PX 0 ; BM égal à votre bonus de maîtrise)<br>
Traits — Lien vital. Lorsque vous récupérez des points de vie par un sort du 1er niveau ou supérieur, la monture en récupère autant si vous vous trouvez à 1,50 m ou moins d''elle.<br>
Actions — Coup d''outre-monde. Corps à corps : bonus égal à votre modificateur d''attaque des sorts, allonge 1,50 m. Touché : 1d8 plus le niveau du sort dégâts radiants (Céleste), psychiques (Fée) ou nécrotiques (Fiélon).<br>
Actions Bonus — Contact guérisseur (Céleste ; recharge après un Repos long) : une créature dans un rayon de 1,50 m récupère 2d8 + le niveau du sort PV. Foulée féerique (Fée ; recharge après un Repos long) : la monture se téléporte avec son cavalier dans un rayon de 18 m. Regard fiélon (Fiélon ; recharge après un Repos long) : JS Sagesse (votre DD), une créature dans 18 m vue par la monture ; échec : Effrayé jusqu''à la fin de votre tour suivant.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7310, 2094, 59, 2);

-- [2095] Appel de familier (niv 1, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2095, 'Appel de familier', 1, 6, NULL, 1, 1, 1, 0, 0, 'de l''encens qui brûle d''une valeur minimale de 10 po, que le sort détruit', '3 m', '', '', '1 heure ou rituel', 'instantanée', NULL, NULL, 0, 1, '<p>Vous recevez les services d''un familier, esprit qui prend la forme animale de votre choix : araignée, belette, chat, chauve-souris, chouette, corbeau, faucon, grenouille, lézard, pieuvre, rat ou autre Bête dont le facteur de puissance est de 0. Le familier se présente en un espace inoccupé à portée, avec le profil de jeu de la forme retenue (cf. « Monstres »), si ce n''est qu''il s''agit d''un Céleste, d''une Fée ou d''un Fiélon (à votre convenance) et non d''une Bête. Votre familier agit indépendamment de vous, mais il obéit à vos instructions.</p>
<p>Lien télépathique. Tant que votre familier se trouve dans un rayon de 30 m de vous, vous pouvez communiquer avec lui par télépathie. De plus, par une action Bonus, vous pouvez voir par ses yeux et entendre par son ouïe jusqu''au début de votre tour suivant, en bénéficiant de ses éventuels sens spéciaux.</p>
<p>Si vous lancez un sort dont la portée est « contact », votre familier peut appliquer ce contact. Il doit se trouver dans un rayon de 30 m de vous et doit jouer sa Réaction pour appliquer le contact lors de l''incantation.</p>
<p>Combat. Le familier est votre allié, ainsi que celui de vos alliés. Il joue sa propre Initiative et agit à son tour. Un familier ne peut pas attaquer, mais il peut entreprendre normalement d''autres actions.</p>
<p>Disparition du familier. Quand le familier tombe à 0 point de vie, il disparaît. Il réapparaît si vous relancez ce sort. Au prix de l''action Magie, vous pouvez provisoirement révoquer le familier dans une niche dimensionnelle ou le révoquer à tout jamais. Tant qu''il est provisoirement révoqué, vous pouvez le faire réapparaître dans un rayon de 9 m de vous au prix de l''action Magie.</p>
<p>Un seul familier. Vous ne pouvez pas disposer de plus d''un familier à la fois. Si vous lancez ce sort alors que vous disposez déjà d''un familier, ce dernier adopte en fait une nouvelle forme adaptée.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7311, 2095, 52, 1);

-- [2096] Appel de la foudre (niv 3, Invocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2096, 'Appel de la foudre', 3, 6, NULL, 1, 1, 0, 0, 0, NULL, '36 m', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Un nuage menaçant se présente en un point que vous voyez à portée et qui vous surplombe directement. Il prend la forme d''un Cylindre haut de 3 m pour un rayon de 18 m.</p>
<p>À l''incantation du sort, choisissez un point que vous voyez sous le nuage. Un trait de foudre jaillit du nuage vers ce point. Chaque créature située dans un rayon de 1,50 m de ce point effectue un jet de sauvegarde de Dextérité et subit 3d10 dégâts de foudre en cas d''échec, la moitié en cas de réussite.</p>
<p>Jusqu''à la fin du sort, vous pouvez entreprendre l''action Magie pour invoquer chaque fois un nouvel éclair, en ciblant le même point ou un autre.</p>
<p>Si vous êtes en extérieur et en conditions orageuses à l''incantation du sort, il vous donne le contrôle de l''orage en cours au lieu d''en créer un. Dans de telles conditions, les dégâts du sort augmentent de 1d10.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d10 par niveau d''emplacement au-delà du 3e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7312, 2096, 55, 3);

-- [2097] Arme magique (niv 2, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2097, 'Arme magique', 2, 4, NULL, 1, 1, 0, 0, 0, NULL, 'contact', '', '', 'action Bonus', '1 heure', NULL, NULL, 0, 0, '<p>Vous touchez une arme non magique. Jusqu''à la fin du sort, l''arme devient magique, dotée d''un bonus de +1 aux jets d''attaque et aux jets de dégâts. Le sort prend fin prématurément si vous le relancez.</p>
<p>Emplacement de niveau supérieur. Le bonus passe à +2 avec un emplacement du 3e, 4e ou 5e niveau. Il passe à +3 avec un emplacement du 6e niveau ou supérieur.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7313, 2097, 56, 2),
  (7314, 2097, 52, 2),
  (7315, 2097, 59, 2),
  (7316, 2097, 60, 2);

-- [2098] Arme spirituelle (niv 2, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2098, 'Arme spirituelle', 2, 1, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action Bonus', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous créez une arme spectrale et flottante à l''image de l''arme de votre choix, qui persiste pour toute la durée. L''arme apparaît à portée dans l''espace de votre choix et vous pouvez aussitôt effectuer une attaque de sort au corps à corps contre une créature située dans un rayon de 1,50 m de l''arme. Si l''attaque touche, la cible subit des dégâts de force égaux à 1d8 + votre modificateur de caractéristique d''incantation.</p>
<p>Par une action Bonus à chaque tour consécutif, vous pouvez déplacer l''arme d''un maximum de 6 m et répéter l''attaque contre une créature située dans un rayon de 1,50 m de l''arme.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d8 par niveau d''emplacement au-delà du 2e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7317, 2098, 54, 2);

-- [2099] Armure du mage (niv 1, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2099, 'Armure du mage', 1, 5, NULL, 1, 1, 1, 0, 0, 'un morceau de cuir traité', 'contact', '', '', 'action', '8 heures', NULL, NULL, 0, 0, '<p>Vous touchez une créature consentante qui ne porte pas d''armure. Jusqu''à la fin du sort, sa CA de base est de 13 plus son modificateur de Dextérité. Le sort prend fin prématurément si la cible enfile une armure.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7318, 2099, 56, 1),
  (7319, 2099, 52, 1);

-- [2100] Arrêt du temps (niv 9, Transmutation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2100, 'Arrêt du temps', 9, 4, NULL, 1, 0, 0, 0, 0, NULL, 'personnelle', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous mettez un bref coup d''arrêt à l''écoulement du temps, pour tout le monde sauf vous-même. Le temps s''arrête pour les autres créatures tandis que vous prenez 1d4 +1 tours d''affilée, durant lesquels vous pouvez entreprendre des actions et vous déplacer comme en temps normal.</p>
<p>Ce sort prend fin si l''une des actions que vous entreprenez durant l''intervalle, ou l''un des effets créés, affecte une créature autre que vous ou un objet porté par quelqu''un d''autre que vous. Il se termine également si vous vous déplacez en un lieu distant de plus de 300 m de l''endroit où vous l''avez lancé.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7320, 2100, 56, 9),
  (7321, 2100, 52, 9);

-- [2101] Aspersion acide (niv 0, Evocation)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2101, 'Aspersion acide', 0, 1, NULL, 1, 1, 0, 0, 0, NULL, '18 m', '', '', 'action', 'instantanée', NULL, NULL, 0, 0, '<p>Vous créez une bulle acide en un point à portée, où elle explose sous forme de Sphère de 1,50 m de rayon. Chaque créature prise dans la Sphère doit réussir un jet de sauvegarde de Dextérité sous peine de subir 1d6 dégâts d''acide.</p>
<p>Amélioration de sort mineur. Les dégâts augmentent de 1d6 lorsque vous atteignez les niveaux 5 (2d6), 11 (3d6) et 17 (4d6).</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7322, 2101, 56, 0),
  (7323, 2101, 52, 0);

-- [2102] Assassin imaginaire (niv 4, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2102, 'Assassin imaginaire', 4, 9, NULL, 1, 1, 0, 0, 0, NULL, '36 m', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous puisez dans les cauchemars d''une créature que vous voyez à portée pour créer une illusion de ses plus grandes craintes, visible uniquement de la créature. La cible effectue un jet de sauvegarde de Sagesse. En cas d''échec, la cible subit 4d10 dégâts psychiques, ainsi que le Désavantage aux tests de caractéristique et aux jets d''attaque pour toute la durée. En cas de réussite, la cible subit la moitié de ces dégâts et le sort prend fin.</p>
<p>Pour toute la durée, la cible effectue un JS Sagesse à la fin de chacun de ses tours. En cas d''échec, elle subit de nouveau les dégâts psychiques. En cas de réussite, le sort prend fin.</p>
<p>Emplacement de niveau supérieur. Les dégâts augmentent de 1d10 par niveau d''emplacement au-delà du 4e.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7324, 2102, 53, 4),
  (7325, 2102, 52, 4);

-- [2103] Assistance (niv 0, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2103, 'Assistance', 0, 7, NULL, 1, 1, 0, 0, 0, NULL, 'contact', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Vous touchez physiquement une créature consentante en choisissant une compétence. Jusqu''à la fin du sort, la créature ajoute 1d4 au résultat de tout test de caractéristique associé à cette compétence.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7326, 2103, 54, 0),
  (7327, 2103, 55, 0);

-- [2104] Augure (niv 2, Divination)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2104, 'Augure', 2, 7, NULL, 1, 1, 1, 0, 0, 'cartes, os ou bâtonnets gravés spécialement, ou objets divinatoires comparables, d''une valeur minimale de 25 po', 'personnelle', '', '', '1 minute ou rituel', 'instantanée', NULL, NULL, 0, 1, '<p>Vous recevez un présage d''une entité surnaturelle vous renseignant sur l''issue d''une opération que vous comptez mener dans les 30 minutes. Le MJ choisit une option de la table Présages :</p>
<p>Fortune — pour une issue qui s''annonce favorable<br>
Misère — défavorable<br>
Fortune et misère — favorable et défavorable<br>
Indifférence — ni favorable ni défavorable</p>
<p>Le sort ne tient pas compte des conjonctures qui pourraient peser dans la balance, comme l''incantation de nouveaux sorts.</p>
<p>Si vous lancez le sort plus d''une fois avant de terminer votre prochain Repos long, vous courez dès la deuxième incantation 25 % de risques cumulatifs qu''il ne vous livre aucune réponse.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7328, 2104, 54, 2),
  (7329, 2104, 55, 2),
  (7330, 2104, 52, 2);

-- [2105] Aura de vie (niv 4, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2105, 'Aura de vie', 4, 5, NULL, 1, 0, 0, 0, 0, NULL, 'personnelle', '', '', 'action', 'Concentration, jusqu''à 10 minutes', NULL, NULL, 1, 0, '<p>Une aura rayonne depuis vous pour toute la durée, sous forme d''une Émanation de 9 m. Toute créature alliée comprise dans l''aura (y compris vous) bénéficie de la Résistance aux dégâts nécrotiques et rien ne peut réduire son maximum de points de vie. Si un allié à 0 point de vie commence son tour dans l''aura, il récupère 1 point de vie.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7331, 2105, 54, 4),
  (7332, 2105, 59, 4);

-- [2106] Aura magique de l'arcaniste (niv 2, Illusion)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2106, 'Aura magique de l''arcaniste', 2, 9, NULL, 1, 1, 1, 0, 0, 'un petit carré de soie', 'contact', '', '', 'action', '24 heures', NULL, NULL, 0, 0, '<p>D''un contact, vous placez une illusion sur une créature consentante ou un objet qui n''est porté par personne. Une créature reçoit l''effet Masque, tandis qu''un objet reçoit l''effet Aura factice (voir plus loin). Les effets persistent pour toute la durée. Si vous lancez ce sort sur une même créature ou un même objet pendant 30 jours consécutifs, l''illusion persiste jusqu''à dissipation.</p>
<p>Masque (créature). Choisissez un type de créature autre que celui de la cible. Les sorts et effets magiques considèrent désormais la cible comme du type retenu.</p>
<p>Aura factice (objet). Vous altérez la manière dont la cible se dévoile au gré de sorts et effets magiques qui perçoivent les auras magiques. Vous pouvez ainsi faire qu''un objet ordinaire paraisse magique, qu''un objet magique paraisse ordinaire, ou modifier l''aura magique d''un objet pour qu''elle soit associée à l''école de magie de votre choix.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7333, 2106, 52, 2);

-- [2107] Aura sacrée (niv 8, Abjuration)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2107, 'Aura sacrée', 8, 5, NULL, 1, 1, 1, 0, 0, 'un reliquaire d''une valeur minimale de 1 000 po', 'personnelle', '', '', 'action', 'Concentration, jusqu''à 1 minute', NULL, NULL, 1, 0, '<p>Pour toute la durée, vous émettez une aura sous forme d''une Émanation de 9 m. Tant qu''elles sont dans l''aura, les créatures que vous choisissez ont l''Avantage aux jets de sauvegarde et les autres ont contre elle le Désavantage aux jets d''attaque. De plus, lorsqu''un Fiélon ou un Mort-vivant touche une créature affectée avec un jet d''attaque de corps à corps, l''assaillant doit réussir un jet de sauvegarde de Constitution sous peine de subir l''état Aveuglé jusqu''à la fin de son tour suivant.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7334, 2107, 54, 8);

-- [2108] Aversion/attirance (niv 8, Enchantement)
INSERT INTO dd_sorts (so_id, so_nom, so_niveau, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel, so_focalisateur, so_focalisateur_divin, so_composante, so_portee, so_cible, so_zone_effet, so_duree_incantation, so_duree_sort, so_resistance, so_jet_sauvegarde, so_concentration, so_rituel, so_description, so_resume, so_res_id, so_camp_id, so_ruleset_var_id) VALUES
  (2108, 'Aversion/attirance', 8, 3, NULL, 1, 1, 1, 0, 0, 'un mélange de vinaigre et de miel', '18 m', '', '', '1 heure', '10 jours', NULL, NULL, 0, 0, '<p>À l''incantation, choisissez si le sort produit de l''aversion ou de l''attirance, et ciblez une créature ou un objet de taille TG ou inférieure. Spécifiez alors une catégorie de créatures, comme les dragons rouges, les gobelins ou les vampires. Toute créature de la catégorie désignée effectue un jet de sauvegarde de Sagesse quand elle entre dans un rayon de 36 m de la cible. Ce qui arrive à une telle créature si elle rate son JS dépend de votre choix : attirance ou aversion.</p>
<p>Attirance. La créature subit l''état Charmé. La créature Charmée doit consacrer le déplacement de ses tours à se rapprocher autant que possible de la cible par le chemin le plus sûr. Si la créature se trouve dans un rayon de 1,50 m de la cible, elle ne peut s''en éloigner volontairement. Si la cible inflige des dégâts à la créature Charmée, cette dernière peut réitérer le JS Sagesse pour mettre un terme à l''effet.</p>
<p>Aversion. La créature subit l''état Effrayé. La créature Effrayée doit consacrer le déplacement de ses tours à s''éloigner autant que possible de la cible par le chemin le plus sûr.</p>
<p>Mettre fin à l''effet. Une créature ainsi Charmée ou Effrayée qui termine son tour au-delà de 36 m de la cible effectue un jet de sauvegarde de Sagesse. En cas de réussite, la créature n''est plus affectée par la cible. Une créature qui réussit son JS contre cet effet est immunisée contre celui-ci pendant 1 minute, après quoi elle peut de nouveau être affectée.</p>', NULL, 93, NULL, 2);
INSERT INTO dd_sortclasse (sc_id, sc_so_id, sc_cla_id, sc_niveau) VALUES
  (7335, 2108, 53, 8),
  (7336, 2108, 55, 8),
  (7337, 2108, 52, 8);

COMMIT;
-- Fin lot 1 — 27 sorts, prochains IDs : dd_sorts=2109, dd_sortclasse=7338
