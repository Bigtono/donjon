-- sql/diagnostic_reference_sp-dp.sql — À exécuter dans phpMyAdmin (LECTURE SEULE).
-- Vérifie, pour chaque migration de la référence initiale (D-DP8), qu'elle a bien
-- laissé sa trace dans la base. Comparer à la base locale : un écart désigne une
-- migration inscrite « déjà jouée » à tort, à remettre en attente (D-DP12).
-- Pas une migration : le nom ne suit pas le motif AAAA-MM-JJ_*.sql, il ne part pas en prod.
SELECT '2026-06-01_campagnes_v2_etape1' AS migration, (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'dd_rencontres' AND COLUMN_NAME = 're_composition') AS valeur
UNION ALL SELECT '2026-06-01_campagnes_v2_etape2a', (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'dd_campagnes' AND COLUMN_NAME = 'camp_supprime')
UNION ALL SELECT '2026-06-12_personnages_identite', (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'dd_personnages' AND COLUMN_NAME = 'pe_hi_id')
UNION ALL SELECT '2026-06-12_personnages_socle', (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'dd_personnages' AND COLUMN_NAME = 'pe_sexe')
UNION ALL SELECT '2026-06-20_equipements_sp-e0', (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'dd_equipements')
UNION ALL SELECT '2026-06-20_oppositions_monstre_optionnel', (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'dd_oppositions' AND COLUMN_NAME = 'opp_mo_id' AND IS_NULLABLE = 'YES')
UNION ALL SELECT '2026-08-10_tableaux_sp-tb0', (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'dd_tableaux')
UNION ALL SELECT '2026-08-15_dons_dd2024_mdj (dons DD2024)', (SELECT COUNT(*) FROM dd_dons WHERE do_ruleset_var_id = 2)
UNION ALL SELECT '2026-08-22_releves_device_sp-rs5', (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'dd_connexions')
UNION ALL SELECT '2026-08-24_ordre_sp-cp', (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'dd_rencontres' AND COLUMN_NAME = 're_ordre')
UNION ALL SELECT '2026-08-25_regles_dd35_socle (ressource DRS)', (SELECT COUNT(*) FROM dd_ressources WHERE res_abreviation = 'DRS 3.5')
UNION ALL SELECT '2026-08-25_regles_dd35_drs* (règles DD3.5)', (SELECT COUNT(*) FROM dd_regles WHERE reg_ruleset_var_id = 1)
UNION ALL SELECT '2026-08-27_profil_incantation_sp-ma0', (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'dd_classes' AND COLUMN_NAME = 'cla_profil_incantation')
UNION ALL SELECT '2026-08-27_registre_sp-ma3', (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'dd_sorts' AND COLUMN_NAME = 'so_registre')
UNION ALL SELECT '2026-08-28_capacites_drop_categorie (1 = PAS jouée)', (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'dd_capacites_speciales' AND COLUMN_NAME = 'cap_categorie_var_id')
UNION ALL SELECT '2026-08-28_classes_dd2024_sp-im2 (niveaux classes 50-61)', (SELECT COUNT(*) FROM dd_classe_niveau WHERE cn_cla_id BETWEEN 50 AND 61)
UNION ALL SELECT '2026-08-28_classes_dd2024_sp-im3 (capacité 601)', (SELECT COUNT(*) FROM dd_capacites_speciales WHERE cap_id = 601)
UNION ALL SELECT '2026-08-28_classes_dd2024_sp-im4 (sous-classe 70)', (SELECT COUNT(*) FROM dd_classes WHERE cla_id = 70)
UNION ALL SELECT '2026-08-28_classes_dd2024_sp-im7 (barbare : 2)', (SELECT cla_pointsCompetences FROM dd_classes WHERE cla_id = 51)
UNION ALL SELECT '2026-08-28_cle_unique_classe_niveau', (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'dd_classe_niveau' AND INDEX_NAME = 'uk_cn_classe_niveau')
UNION ALL SELECT '2026-08-28_objets_dd2024_sp-im9a/b (objets DD2024 rareté 0)', (SELECT COUNT(*) FROM dd_objets_magiques WHERE om_ruleset_var_id = 2 AND om_rarete = 0)
UNION ALL SELECT '2026-08-28_objets_dd2024_sp-im9c (tableau 43)', (SELECT COUNT(*) FROM dd_tableaux WHERE tab_id = 43)
UNION ALL SELECT '2026-08-28_options_dd2024_sp-im5 (catégorie de don 22)', (SELECT COUNT(*) FROM dd_data_don WHERE dado_id = 22)
UNION ALL SELECT '2026-08-28_races_dd2024_sp-im8 (espèce 18)', (SELECT COUNT(*) FROM dd_races WHERE ra_id = 18)
UNION ALL SELECT '2026-08-28_registre_sp-ma3_donnees (sorts avec registre)', (SELECT COUNT(*) FROM dd_sorts WHERE so_registre IS NOT NULL)
UNION ALL SELECT '2026-09-01_cadence_renouvellement_sp-ma4b', (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'dd_classes' AND COLUMN_NAME = 'cla_renouvellement')
UNION ALL SELECT '2026-09-01_cn_sort_null_vs_zero_sp-pe7a (cn_sort_n9 NULL)', (SELECT COUNT(*) FROM dd_classe_niveau WHERE cn_sort_n9 IS NULL)
UNION ALL SELECT '2026-09-01_decalage_paladin_rodeur_sp-pe7a', (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'dd_classe_niveau_backup_pe7a')
UNION ALL SELECT '2026-09-01_sorts_toujours_prepares_sp-ma4a', (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'dd_classe_sort')
UNION ALL SELECT '2026-10-07_mode_jeu_optionnel_sp-pe10l', (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'dd_joueurs' AND COLUMN_NAME = 'j_affichage_mode_jeu');
