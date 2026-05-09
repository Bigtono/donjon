-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : sam. 09 mai 2026 à 15:57
-- Version du serveur : 10.4.32-MariaDB
-- Version de PHP : 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `maikasteiymaika`
--

-- --------------------------------------------------------

--
-- Structure de la table `dd_campagnes`
--

CREATE TABLE `dd_campagnes` (
  `camp_id` int(10) UNSIGNED NOT NULL,
  `camp_nom` varchar(150) NOT NULL,
  `camp_j_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_joueurs (MJ/propriétaire)',
  `camp_ruleset_var_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_variables',
  `camp_resume` text DEFAULT NULL,
  `camp_description` text DEFAULT NULL,
  `camp_date_creation` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_campagnes_notes`
--

CREATE TABLE `dd_campagnes_notes` (
  `cpno_id` int(10) UNSIGNED NOT NULL,
  `cpno_no_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_notes',
  `cpno_camp_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_campagnes'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_campagnes_personnages`
--

CREATE TABLE `dd_campagnes_personnages` (
  `cp_id` int(10) UNSIGNED NOT NULL,
  `cp_camp_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_campagnes',
  `cp_pe_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_personnages',
  `cp_notes_mj` text DEFAULT NULL COMMENT 'Visible MJ uniquement',
  `cp_actif` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_campagnes_sources`
--

CREATE TABLE `dd_campagnes_sources` (
  `cs_id` int(10) UNSIGNED NOT NULL,
  `cs_camp_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_campagnes',
  `cs_res_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_ressources'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_campagnes_univers`
--

CREATE TABLE `dd_campagnes_univers` (
  `cu_id` int(10) UNSIGNED NOT NULL,
  `cu_camp_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_campagnes',
  `cu_un_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_univers'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_capacites_speciales`
--

CREATE TABLE `dd_capacites_speciales` (
  `cap_id` int(10) UNSIGNED NOT NULL,
  `cap_nom` varchar(150) NOT NULL,
  `cap_description` text DEFAULT NULL,
  `cap_type` varchar(50) DEFAULT NULL,
  `cap_categorie_var_id` int(10) UNSIGNED DEFAULT NULL COMMENT '-> dd_variables cat=tcap'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_caracteristiques`
--

CREATE TABLE `dd_caracteristiques` (
  `car_id` int(10) UNSIGNED NOT NULL,
  `car_nom` varchar(30) NOT NULL,
  `car_diminutif` char(3) NOT NULL COMMENT '3 premières lettres du nom'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_classes`
--

CREATE TABLE `dd_classes` (
  `cla_id` int(10) UNSIGNED NOT NULL,
  `cla_nom` varchar(100) NOT NULL,
  `cla_abreviation` varchar(20) NOT NULL DEFAULT '',
  `cla_clt_id` tinyint(3) UNSIGNED NOT NULL DEFAULT 1 COMMENT '1=base, 2=prestige (DD3.5)',
  `cla_dV` tinyint(3) UNSIGNED NOT NULL DEFAULT 6,
  `cla_alignement` varchar(100) DEFAULT NULL,
  `cla_car_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '-> dd_caracteristiques, 0=aucun',
  `cla_mag_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '-> dd_typeMagie, 0=non lanceur',
  `cla_sort_connu` tinyint(1) NOT NULL DEFAULT 0,
  `cla_sort_compris` tinyint(1) NOT NULL DEFAULT 0,
  `cla_sort_prepare` tinyint(1) NOT NULL DEFAULT 0,
  `cla_domaine_divin` tinyint(1) NOT NULL DEFAULT 0,
  `cla_niveauMax` tinyint(3) UNSIGNED NOT NULL DEFAULT 20 COMMENT '3, 5, 10 ou 20',
  `cla_pointsCompetences` tinyint(3) UNSIGNED DEFAULT NULL,
  `cla_po_niveau1` smallint(5) UNSIGNED DEFAULT NULL,
  `cla_conditions` text DEFAULT NULL,
  `cla_armures` text DEFAULT NULL,
  `cla_outils` text DEFAULT NULL,
  `cla_sauvegardes` text DEFAULT NULL,
  `cla_equipement` text DEFAULT NULL,
  `cla_armes` text DEFAULT NULL,
  `cla_competences` text DEFAULT NULL,
  `cla_sorts` text DEFAULT NULL,
  `cla_description` text DEFAULT NULL,
  `cla_traits` text DEFAULT NULL,
  `cla_caracteristiques` text DEFAULT NULL,
  `cla_critere_rec` text DEFAULT NULL,
  `cla_pouvoir1` varchar(100) DEFAULT NULL,
  `cla_pouvoir2` varchar(100) DEFAULT NULL,
  `cla_pouvoir3` varchar(100) DEFAULT NULL,
  `cla_pouvoir4` varchar(100) DEFAULT NULL,
  `cla_cla_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Classe parente éventuelle',
  `cla_res_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_ressources',
  `cla_camp_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'null=global, sinon homebrew -> dd_campagnes',
  `cla_ruleset_var_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_variables'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_classe_capacite`
--

CREATE TABLE `dd_classe_capacite` (
  `cc_id` int(10) UNSIGNED NOT NULL,
  `cc_cla_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_classes',
  `cc_cap_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_capacites_speciales',
  `cc_niveau` tinyint(3) UNSIGNED NOT NULL,
  `cc_precision` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_classe_niveau`
--

CREATE TABLE `dd_classe_niveau` (
  `cn_id` int(10) UNSIGNED NOT NULL,
  `cn_cla_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_classes',
  `cn_niveau` tinyint(3) UNSIGNED NOT NULL,
  `cn_bba` varchar(20) NOT NULL DEFAULT '0' COMMENT 'Bonus base attaque (DD3.5: multi-valeurs ex +3/+1)',
  `cn_reflexes` tinyint(4) NOT NULL DEFAULT 0,
  `cn_vigueur` tinyint(4) NOT NULL DEFAULT 0,
  `cn_volonte` tinyint(4) NOT NULL DEFAULT 0,
  `cn_sort_n0` tinyint(3) UNSIGNED DEFAULT NULL,
  `cn_sort_n1` tinyint(3) UNSIGNED DEFAULT NULL,
  `cn_sort_n2` tinyint(3) UNSIGNED DEFAULT NULL,
  `cn_sort_n3` tinyint(3) UNSIGNED DEFAULT NULL,
  `cn_sort_n4` tinyint(3) UNSIGNED DEFAULT NULL,
  `cn_sort_n5` tinyint(3) UNSIGNED DEFAULT NULL,
  `cn_sort_n6` tinyint(3) UNSIGNED DEFAULT NULL,
  `cn_sort_n7` tinyint(3) UNSIGNED DEFAULT NULL,
  `cn_sort_n8` tinyint(3) UNSIGNED DEFAULT NULL,
  `cn_sort_n9` tinyint(3) UNSIGNED DEFAULT NULL,
  `cn_sortConnu_n0` tinyint(3) UNSIGNED DEFAULT NULL,
  `cn_sortConnu_n1` tinyint(3) UNSIGNED DEFAULT NULL,
  `cn_sortConnu_n2` tinyint(3) UNSIGNED DEFAULT NULL,
  `cn_sortConnu_n3` tinyint(3) UNSIGNED DEFAULT NULL,
  `cn_sortConnu_n4` tinyint(3) UNSIGNED DEFAULT NULL,
  `cn_sortConnu_n5` tinyint(3) UNSIGNED DEFAULT NULL,
  `cn_sortConnu_n6` tinyint(3) UNSIGNED DEFAULT NULL,
  `cn_sortConnu_n7` tinyint(3) UNSIGNED DEFAULT NULL,
  `cn_sortConnu_n8` tinyint(3) UNSIGNED DEFAULT NULL,
  `cn_sortConnu_n9` tinyint(3) UNSIGNED DEFAULT NULL,
  `cn_niveauSortArcane` tinyint(1) NOT NULL DEFAULT 0,
  `cn_niveauSortDivin` tinyint(1) NOT NULL DEFAULT 0,
  `cn_niveauSortEffectif` tinyint(1) NOT NULL DEFAULT 0,
  `cn_pouvoir1` varchar(255) DEFAULT NULL,
  `cn_pouvoir2` varchar(255) DEFAULT NULL,
  `cn_pouvoir3` varchar(255) DEFAULT NULL,
  `cn_pouvoir4` varchar(255) DEFAULT NULL,
  `cn_sortPrepare` tinyint(3) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_colleges`
--

CREATE TABLE `dd_colleges` (
  `co_id` int(10) UNSIGNED NOT NULL,
  `co_nom` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_competences`
--

CREATE TABLE `dd_competences` (
  `comp_id` int(10) UNSIGNED NOT NULL,
  `comp_nom` varchar(100) NOT NULL,
  `comp_car_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_caracteristiques',
  `comp_res_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_ressources',
  `comp_ruleset_var_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_variables'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_data_don`
--

CREATE TABLE `dd_data_don` (
  `dado_id` int(10) UNSIGNED NOT NULL,
  `dado_nom` varchar(80) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_domaines`
--

CREATE TABLE `dd_domaines` (
  `do_id` int(11) NOT NULL,
  `do_nom` varchar(255) NOT NULL,
  `do_pouvoir` text DEFAULT NULL,
  `do_dieux` text DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_dons`
--

CREATE TABLE `dd_dons` (
  `do_id` int(10) UNSIGNED NOT NULL,
  `do_nom` varchar(150) NOT NULL,
  `do_dado_id` int(10) UNSIGNED DEFAULT NULL COMMENT '-> dd_data_don',
  `do_conditions` text DEFAULT NULL COMMENT 'DD3.5 uniquement',
  `do_texte` text DEFAULT NULL,
  `do_resume` text DEFAULT NULL,
  `do_res_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_ressources',
  `do_camp_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'null=global, sinon homebrew -> dd_campagnes',
  `do_ruleset_var_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_variables'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_joueurs`
--

CREATE TABLE `dd_joueurs` (
  `j_id` int(10) UNSIGNED NOT NULL,
  `j_prenom` varchar(50) NOT NULL DEFAULT '',
  `j_nom` varchar(50) NOT NULL DEFAULT '',
  `j_pseudo` varchar(50) NOT NULL,
  `j_email` varchar(150) NOT NULL,
  `j_password_hash` varchar(255) NOT NULL,
  `j_remember_token` varchar(100) DEFAULT NULL,
  `j_remember_token_expires` datetime DEFAULT NULL,
  `j_reset_token` varchar(100) DEFAULT NULL,
  `j_reset_token_expires` datetime DEFAULT NULL,
  `j_avatar_url` varchar(255) DEFAULT NULL,
  `j_bio` text DEFAULT NULL,
  `j_date_inscription` datetime NOT NULL DEFAULT current_timestamp(),
  `j_derniere_connexion` datetime DEFAULT NULL,
  `j_admin` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 = admin global',
  `j_compendium_manager` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 = peut éditer compendium global',
  `j_default_ruleset_var_id` int(10) UNSIGNED DEFAULT NULL COMMENT '-> dd_variables',
  `j_items_par_page` tinyint(3) UNSIGNED NOT NULL DEFAULT 20,
  `j_visible` tinyint(1) NOT NULL DEFAULT 1,
  `j_notes` text DEFAULT NULL,
  `j_mode_campagne` tinyint(1) NOT NULL DEFAULT 0,
  `j_affichage_ruleset` tinyint(1) NOT NULL DEFAULT 1,
  `j_dd_onglet_sort` tinyint(1) NOT NULL DEFAULT 0,
  `j_dd_onglet_don` tinyint(1) NOT NULL DEFAULT 0,
  `j_dd_onglet_om` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_joueurs_sources`
--

CREATE TABLE `dd_joueurs_sources` (
  `js_id` int(10) UNSIGNED NOT NULL,
  `js_j_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_joueurs',
  `js_res_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_ressources',
  `js_ruleset_var_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_variables'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_modificateurs`
--

CREATE TABLE `dd_modificateurs` (
  `mod_id` int(10) UNSIGNED NOT NULL,
  `mod_carac` tinyint(3) UNSIGNED NOT NULL COMMENT 'Valeur de carac (1-30)',
  `mod_modificateur` tinyint(4) NOT NULL,
  `mod_bonusSort0` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `mod_bonusSort1` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `mod_bonusSort2` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `mod_bonusSort3` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `mod_bonusSort4` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `mod_bonusSort5` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `mod_bonusSort6` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `mod_bonusSort7` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `mod_bonusSort8` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `mod_bonusSort9` tinyint(3) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_monstres`
--

CREATE TABLE `dd_monstres` (
  `mo_id` int(10) UNSIGNED NOT NULL,
  `mo_nom` varchar(150) NOT NULL,
  `mo_stats` text DEFAULT NULL,
  `mo_fp_id` varchar(10) DEFAULT NULL COMMENT 'Facteur de puissance (alphanum)',
  `mo_j_id` int(10) UNSIGNED DEFAULT NULL COMMENT '-> dd_joueurs (null=visible tous)',
  `mo_ruleset_var_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_variables'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_notes`
--

CREATE TABLE `dd_notes` (
  `no_id` int(10) UNSIGNED NOT NULL,
  `no_nom` varchar(200) NOT NULL,
  `no_tyno_id` int(10) UNSIGNED DEFAULT NULL COMMENT '-> dd_types_notes',
  `no_date` datetime NOT NULL DEFAULT current_timestamp(),
  `no_j_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_joueurs (rédacteur)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_notes_contenus`
--

CREATE TABLE `dd_notes_contenus` (
  `noc_id` int(10) UNSIGNED NOT NULL,
  `noc_no_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_notes',
  `noc_dd` tinyint(3) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Degré de difficulté accès',
  `noc_texte` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_notes_tags`
--

CREATE TABLE `dd_notes_tags` (
  `notag_id` int(10) UNSIGNED NOT NULL,
  `notag_no_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_notes',
  `notag_tag_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_tags'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_personnages`
--

CREATE TABLE `dd_personnages` (
  `pe_id` int(10) UNSIGNED NOT NULL,
  `pe_nom` varchar(100) NOT NULL,
  `pe_j_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_joueurs (propriétaire)',
  `pe_ra_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '-> dd_races (race de base)',
  `pe_arc_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'DD3.5: -> dd_races (archétype), 0=aucun',
  `pe_for` tinyint(3) UNSIGNED NOT NULL DEFAULT 10,
  `pe_con` tinyint(3) UNSIGNED NOT NULL DEFAULT 10,
  `pe_dex` tinyint(3) UNSIGNED NOT NULL DEFAULT 10,
  `pe_int` tinyint(3) UNSIGNED NOT NULL DEFAULT 10,
  `pe_sag` tinyint(3) UNSIGNED NOT NULL DEFAULT 10,
  `pe_cha` tinyint(3) UNSIGNED NOT NULL DEFAULT 10,
  `pe_ca` smallint(6) NOT NULL DEFAULT 10,
  `pe_pv` smallint(6) NOT NULL DEFAULT 0,
  `pe_background` text DEFAULT NULL,
  `pe_notes` text DEFAULT NULL COMMENT 'Notes visibles par le propriétaire',
  `pe_ruleset_var_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_variables',
  `pe_date_creation` datetime NOT NULL DEFAULT current_timestamp(),
  `pe_date_modif` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_personnages_classes`
--

CREATE TABLE `dd_personnages_classes` (
  `pc_id` int(10) UNSIGNED NOT NULL,
  `pc_pe_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_personnages',
  `pc_cla_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_classes',
  `pc_niveau` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `pc_do_id_1` int(10) UNSIGNED DEFAULT NULL COMMENT 'Domaine divin 1 (si applicable)',
  `pc_do_id_2` int(10) UNSIGNED DEFAULT NULL COMMENT 'Domaine divin 2 (si applicable)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_personnages_competences`
--

CREATE TABLE `dd_personnages_competences` (
  `pec_id` int(10) UNSIGNED NOT NULL,
  `pec_pe_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_personnages',
  `pec_comp_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_competences',
  `pec_maitrise` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'DD3.5: valeur numérique; DD2024: 0=aucun,1=maîtrise,2=expertise'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_personnages_dons`
--

CREATE TABLE `dd_personnages_dons` (
  `ped_id` int(10) UNSIGNED NOT NULL,
  `ped_pe_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_personnages',
  `ped_do_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_dons',
  `ped_niveau` tinyint(3) UNSIGNED DEFAULT NULL COMMENT 'Niveau auquel le don a été pris'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_personnages_nls`
--

CREATE TABLE `dd_personnages_nls` (
  `penl_id` int(10) UNSIGNED NOT NULL,
  `penl_pc_id_base` int(10) UNSIGNED NOT NULL COMMENT '-> dd_personnages_classes (classe de base lanceur)',
  `penl_pc_id_prestige` int(10) UNSIGNED NOT NULL COMMENT '-> dd_personnages_classes (classe prestige)',
  `penl_niveau` tinyint(3) UNSIGNED NOT NULL COMMENT 'Niveau dans la classe prestige'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='DD3.5 uniquement — NLS classes de prestige';

-- --------------------------------------------------------

--
-- Structure de la table `dd_personnages_notes`
--

CREATE TABLE `dd_personnages_notes` (
  `pno_id` int(10) UNSIGNED NOT NULL,
  `pno_pe_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_personnages',
  `pno_no_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_notes',
  `pno_dd` tinyint(3) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Niveau de connaissance du personnage',
  `pno_actif` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_personnages_sorts`
--

CREATE TABLE `dd_personnages_sorts` (
  `pes_id` int(10) UNSIGNED NOT NULL,
  `pes_pc_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_personnages_classes',
  `pes_so_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_sorts',
  `pes_compris` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_personnages_sorts_prepares`
--

CREATE TABLE `dd_personnages_sorts_prepares` (
  `pesp_id` int(10) UNSIGNED NOT NULL,
  `pesp_pe_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_personnages',
  `pesp_cla_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_classes',
  `pesp_so_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_sorts',
  `pesp_metamagie` varchar(100) DEFAULT NULL COMMENT 'DD3.5: ids dons métamagie séparés virgule',
  `pesp_niveau` tinyint(3) UNSIGNED DEFAULT NULL COMMENT 'DD3.5: niveau effectif après métamagie',
  `pesp_nb` tinyint(3) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'DD3.5: nb préparés; DD2024: 0/1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_races`
--

CREATE TABLE `dd_races` (
  `ra_id` int(10) UNSIGNED NOT NULL,
  `ra_nom` varchar(100) NOT NULL,
  `ra_rat_id` int(10) UNSIGNED NOT NULL COMMENT '1=base, 2=archétype -> dd_race_type',
  `ra_description` text DEFAULT NULL,
  `ra_traits` text DEFAULT NULL,
  `ra_res_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_ressources',
  `ra_ruleset_var_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_variables'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_race_type`
--

CREATE TABLE `dd_race_type` (
  `rat_id` int(10) UNSIGNED NOT NULL,
  `rat_nom` varchar(50) NOT NULL,
  `rat_ruleset_var_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_variables'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_rencontres`
--

CREATE TABLE `dd_rencontres` (
  `re_id` int(10) UNSIGNED NOT NULL,
  `re_nom` varchar(150) NOT NULL,
  `re_code` varchar(20) DEFAULT NULL,
  `re_scc_id` int(10) UNSIGNED DEFAULT NULL COMMENT '-> dd_scenarios_chapitres (null=orpheline)',
  `re_description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_rencontres_monstres`
--

CREATE TABLE `dd_rencontres_monstres` (
  `rem_id` int(10) UNSIGNED NOT NULL,
  `rem_re_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_rencontres',
  `rem_mo_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_monstres',
  `rem_effectif` smallint(5) UNSIGNED NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_ressources`
--

CREATE TABLE `dd_ressources` (
  `res_id` int(10) UNSIGNED NOT NULL,
  `res_nom` varchar(150) NOT NULL,
  `res_abreviation` varchar(20) NOT NULL,
  `res_selection` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 = actif globalement',
  `res_ruleset_var_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_variables',
  `res_j_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'null = officiel, sinon propriétaire homebrew',
  `res_editeur` varchar(255) DEFAULT NULL,
  `res_pages` int(11) NOT NULL,
  `res_description` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_scenarios`
--

CREATE TABLE `dd_scenarios` (
  `sce_id` int(10) UNSIGNED NOT NULL,
  `sce_nom` varchar(150) NOT NULL,
  `sce_ordre` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `sce_description` text DEFAULT NULL,
  `sce_camp_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_campagnes',
  `sce_ruleset_var_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_variables'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_scenarios_chapitres`
--

CREATE TABLE `dd_scenarios_chapitres` (
  `scc_id` int(10) UNSIGNED NOT NULL,
  `scc_sce_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_scenarios',
  `scc_nom` varchar(150) NOT NULL,
  `scc_ordre` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `scc_abreviation` varchar(10) DEFAULT NULL,
  `scc_description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_sortclasse`
--

CREATE TABLE `dd_sortclasse` (
  `sc_id` int(10) UNSIGNED NOT NULL,
  `sc_so_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_sorts',
  `sc_cla_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_classes',
  `sc_niveau` tinyint(3) UNSIGNED NOT NULL COMMENT 'Niveau du sort pour cette classe (0-9)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_sortdomaine`
--

CREATE TABLE `dd_sortdomaine` (
  `sd_id` mediumint(9) NOT NULL,
  `sd_so_id` mediumint(9) NOT NULL,
  `sd_niveau` tinyint(4) NOT NULL,
  `sd_do_id` mediumint(9) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_sorts`
--

CREATE TABLE `dd_sorts` (
  `so_id` int(10) UNSIGNED NOT NULL,
  `so_nom` varchar(150) NOT NULL,
  `so_niveau` int(11) DEFAULT NULL COMMENT 'DD2024',
  `so_co_id` int(10) UNSIGNED DEFAULT NULL COMMENT '-> dd_colleges',
  `so_branche` varchar(40) DEFAULT NULL COMMENT 'DD3.5',
  `so_vocal` tinyint(4) NOT NULL DEFAULT 0,
  `so_gestuel` tinyint(4) NOT NULL DEFAULT 0,
  `so_materiel` tinyint(4) NOT NULL DEFAULT 0,
  `so_focalisateur` tinyint(4) NOT NULL DEFAULT 0,
  `so_focalisateur_divin` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'DD3.5',
  `so_composante` varchar(255) DEFAULT NULL,
  `so_portee` varchar(100) NOT NULL,
  `so_cible` varchar(150) NOT NULL COMMENT 'DD3.5',
  `so_zone_effet` varchar(100) NOT NULL COMMENT 'DD3.5',
  `so_duree_incantation` varchar(100) NOT NULL,
  `so_duree_sort` varchar(100) DEFAULT NULL,
  `so_resistance` varchar(100) DEFAULT NULL COMMENT 'DD3.5',
  `so_jet_sauvegarde` varchar(50) DEFAULT NULL COMMENT 'DD3.5',
  `so_description` text DEFAULT NULL,
  `so_res_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_ressources',
  `so_camp_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'null=global, sinon homebrew -> dd_campagnes',
  `so_ruleset_var_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_variables'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_sorts_import`
--

CREATE TABLE `dd_sorts_import` (
  `so_id` smallint(6) NOT NULL,
  `so_nom` varchar(255) NOT NULL,
  `so_res_id` smallint(6) DEFAULT NULL COMMENT 'ressource (livre) dont est issu le sort\r\n',
  `so_page` smallint(6) NOT NULL DEFAULT 0,
  `so_texte` mediumtext DEFAULT NULL,
  `so_co_id` mediumint(9) NOT NULL COMMENT 'Collège',
  `so_branche` varchar(40) NOT NULL,
  `so_composante` varchar(255) NOT NULL,
  `so_portee` varchar(90) NOT NULL,
  `so_cible` varchar(150) NOT NULL,
  `so_zone_effet` varchar(100) DEFAULT NULL,
  `so_duree_sort` varchar(90) NOT NULL,
  `so_duree_incantation` varchar(30) NOT NULL,
  `so_resistance` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `so_jet_sauvegarde` varchar(30) DEFAULT NULL,
  `so_vocal` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `so_gestuel` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `so_materiel` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `so_focalisateur` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `so_focalisateur_divin` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `xp_sort` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `so_mentale` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `so_olfactive` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `so_effet` varchar(64) NOT NULL,
  `so_domaine` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `so_domaine_level` int(11) DEFAULT NULL,
  `a` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `b` int(11) DEFAULT NULL,
  `so_registre_acide` int(11) NOT NULL DEFAULT 0,
  `so_registre_bien` int(11) NOT NULL DEFAULT 0,
  `so_registre_chaos` int(11) NOT NULL DEFAULT 0,
  `so_registre_electricite` int(11) NOT NULL DEFAULT 0,
  `so_registre_feu` int(11) NOT NULL DEFAULT 0,
  `so_registre_force` int(11) NOT NULL DEFAULT 0,
  `so_registre_froid` int(11) NOT NULL DEFAULT 0,
  `so_registre_langage` int(11) NOT NULL DEFAULT 0,
  `so_registre_loi` int(11) NOT NULL DEFAULT 0,
  `so_registre_lumiere` int(11) NOT NULL DEFAULT 0,
  `so_registre_mal` int(11) NOT NULL DEFAULT 0,
  `so_registre_mental` int(11) NOT NULL DEFAULT 0,
  `so_registre_mort` int(11) NOT NULL DEFAULT 0,
  `so_registre_obscurite` int(11) NOT NULL DEFAULT 0,
  `so_registre_son` int(11) NOT NULL DEFAULT 0,
  `so_registre_teleportation` int(11) NOT NULL DEFAULT 0,
  `so_registre_terreur` int(11) NOT NULL DEFAULT 0,
  `so_resume` varchar(255) DEFAULT NULL,
  `so_edition` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `so_potion` int(11) NOT NULL DEFAULT 0,
  `so_modif` tinyint(4) NOT NULL DEFAULT 0,
  `so_ruleset_var_id` mediumint(9) NOT NULL,
  `so_niveau` tinyint(4) DEFAULT NULL COMMENT 'DD5',
  `so_j_id` mediumint(9) NOT NULL COMMENT 'Rédacteur',
  `so_date` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_tags`
--

CREATE TABLE `dd_tags` (
  `tag_id` int(10) UNSIGNED NOT NULL,
  `tag_nom` varchar(80) NOT NULL,
  `tag_slug` varchar(100) NOT NULL,
  `tag_j_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_joueurs',
  `tag_date` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_typemagie`
--

CREATE TABLE `dd_typemagie` (
  `mag_id` int(10) UNSIGNED NOT NULL,
  `mag_nom` varchar(50) NOT NULL,
  `mag_abreviation` varchar(10) NOT NULL,
  `mag_ruleset_var_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_variables'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_types_notes`
--

CREATE TABLE `dd_types_notes` (
  `tyno_id` int(10) UNSIGNED NOT NULL,
  `tyno_nom` varchar(80) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_univers`
--

CREATE TABLE `dd_univers` (
  `un_id` int(10) UNSIGNED NOT NULL,
  `un_nom` varchar(150) NOT NULL,
  `un_j_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_joueurs (propriétaire)',
  `un_description` text DEFAULT NULL,
  `un_public` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1=sélectionnable par autres MJs',
  `un_date_creation` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_univers_articles`
--

CREATE TABLE `dd_univers_articles` (
  `ua_id` int(10) UNSIGNED NOT NULL,
  `ua_uca_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_univers_categories',
  `ua_un_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_univers',
  `ua_titre` varchar(200) NOT NULL,
  `ua_contenu` longtext DEFAULT NULL,
  `ua_visible` tinyint(1) NOT NULL DEFAULT 1 COMMENT '0=MJ seul, 1=tous les ayants droit',
  `ua_date_creation` datetime NOT NULL DEFAULT current_timestamp(),
  `ua_date_modif` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_univers_categories`
--

CREATE TABLE `dd_univers_categories` (
  `uca_id` int(10) UNSIGNED NOT NULL,
  `uca_un_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_univers',
  `uca_nom` varchar(100) NOT NULL,
  `uca_ordre` tinyint(3) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_univers_droits`
--

CREATE TABLE `dd_univers_droits` (
  `ud_id` int(10) UNSIGNED NOT NULL,
  `ud_un_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_univers',
  `ud_j_id` int(10) UNSIGNED NOT NULL COMMENT '-> dd_joueurs (délégataire)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dd_variables`
--

CREATE TABLE `dd_variables` (
  `var_id` int(10) UNSIGNED NOT NULL,
  `var_cat` varchar(50) NOT NULL COMMENT 'Catégorie (ex: ruleset, tcap...)',
  `var_valeur` varchar(100) NOT NULL,
  `var_ordre` tinyint(3) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Référentiel de valeurs paramétrables';

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `dd_campagnes`
--
ALTER TABLE `dd_campagnes`
  ADD PRIMARY KEY (`camp_id`);

--
-- Index pour la table `dd_campagnes_notes`
--
ALTER TABLE `dd_campagnes_notes`
  ADD PRIMARY KEY (`cpno_id`),
  ADD UNIQUE KEY `uk_cpno` (`cpno_no_id`,`cpno_camp_id`);

--
-- Index pour la table `dd_campagnes_personnages`
--
ALTER TABLE `dd_campagnes_personnages`
  ADD PRIMARY KEY (`cp_id`),
  ADD UNIQUE KEY `uk_cp` (`cp_camp_id`,`cp_pe_id`);

--
-- Index pour la table `dd_campagnes_sources`
--
ALTER TABLE `dd_campagnes_sources`
  ADD PRIMARY KEY (`cs_id`),
  ADD UNIQUE KEY `uk_cs` (`cs_camp_id`,`cs_res_id`);

--
-- Index pour la table `dd_campagnes_univers`
--
ALTER TABLE `dd_campagnes_univers`
  ADD PRIMARY KEY (`cu_id`),
  ADD UNIQUE KEY `uk_cu` (`cu_camp_id`,`cu_un_id`);

--
-- Index pour la table `dd_capacites_speciales`
--
ALTER TABLE `dd_capacites_speciales`
  ADD PRIMARY KEY (`cap_id`);

--
-- Index pour la table `dd_caracteristiques`
--
ALTER TABLE `dd_caracteristiques`
  ADD PRIMARY KEY (`car_id`);

--
-- Index pour la table `dd_classes`
--
ALTER TABLE `dd_classes`
  ADD PRIMARY KEY (`cla_id`);

--
-- Index pour la table `dd_classe_capacite`
--
ALTER TABLE `dd_classe_capacite`
  ADD PRIMARY KEY (`cc_id`),
  ADD UNIQUE KEY `uk_cc` (`cc_cla_id`,`cc_cap_id`,`cc_niveau`);

--
-- Index pour la table `dd_classe_niveau`
--
ALTER TABLE `dd_classe_niveau`
  ADD PRIMARY KEY (`cn_id`),
  ADD UNIQUE KEY `uk_cn` (`cn_cla_id`,`cn_niveau`);

--
-- Index pour la table `dd_colleges`
--
ALTER TABLE `dd_colleges`
  ADD PRIMARY KEY (`co_id`);

--
-- Index pour la table `dd_competences`
--
ALTER TABLE `dd_competences`
  ADD PRIMARY KEY (`comp_id`);

--
-- Index pour la table `dd_data_don`
--
ALTER TABLE `dd_data_don`
  ADD PRIMARY KEY (`dado_id`);

--
-- Index pour la table `dd_domaines`
--
ALTER TABLE `dd_domaines`
  ADD PRIMARY KEY (`do_id`);

--
-- Index pour la table `dd_dons`
--
ALTER TABLE `dd_dons`
  ADD PRIMARY KEY (`do_id`);

--
-- Index pour la table `dd_joueurs`
--
ALTER TABLE `dd_joueurs`
  ADD PRIMARY KEY (`j_id`),
  ADD UNIQUE KEY `uk_joueurs_email` (`j_email`),
  ADD UNIQUE KEY `uk_joueurs_pseudo` (`j_pseudo`);

--
-- Index pour la table `dd_joueurs_sources`
--
ALTER TABLE `dd_joueurs_sources`
  ADD PRIMARY KEY (`js_id`),
  ADD UNIQUE KEY `uk_js` (`js_j_id`,`js_res_id`);

--
-- Index pour la table `dd_modificateurs`
--
ALTER TABLE `dd_modificateurs`
  ADD PRIMARY KEY (`mod_id`);

--
-- Index pour la table `dd_monstres`
--
ALTER TABLE `dd_monstres`
  ADD PRIMARY KEY (`mo_id`);

--
-- Index pour la table `dd_notes`
--
ALTER TABLE `dd_notes`
  ADD PRIMARY KEY (`no_id`);

--
-- Index pour la table `dd_notes_contenus`
--
ALTER TABLE `dd_notes_contenus`
  ADD PRIMARY KEY (`noc_id`);

--
-- Index pour la table `dd_notes_tags`
--
ALTER TABLE `dd_notes_tags`
  ADD PRIMARY KEY (`notag_id`),
  ADD UNIQUE KEY `uk_notag` (`notag_no_id`,`notag_tag_id`);

--
-- Index pour la table `dd_personnages`
--
ALTER TABLE `dd_personnages`
  ADD PRIMARY KEY (`pe_id`);

--
-- Index pour la table `dd_personnages_classes`
--
ALTER TABLE `dd_personnages_classes`
  ADD PRIMARY KEY (`pc_id`),
  ADD UNIQUE KEY `uk_pc` (`pc_pe_id`,`pc_cla_id`);

--
-- Index pour la table `dd_personnages_competences`
--
ALTER TABLE `dd_personnages_competences`
  ADD PRIMARY KEY (`pec_id`),
  ADD UNIQUE KEY `uk_pec` (`pec_pe_id`,`pec_comp_id`);

--
-- Index pour la table `dd_personnages_dons`
--
ALTER TABLE `dd_personnages_dons`
  ADD PRIMARY KEY (`ped_id`),
  ADD UNIQUE KEY `uk_ped` (`ped_pe_id`,`ped_do_id`);

--
-- Index pour la table `dd_personnages_nls`
--
ALTER TABLE `dd_personnages_nls`
  ADD PRIMARY KEY (`penl_id`),
  ADD UNIQUE KEY `uk_penl` (`penl_pc_id_base`,`penl_pc_id_prestige`,`penl_niveau`);

--
-- Index pour la table `dd_personnages_notes`
--
ALTER TABLE `dd_personnages_notes`
  ADD PRIMARY KEY (`pno_id`),
  ADD UNIQUE KEY `uk_pno` (`pno_pe_id`,`pno_no_id`);

--
-- Index pour la table `dd_personnages_sorts`
--
ALTER TABLE `dd_personnages_sorts`
  ADD PRIMARY KEY (`pes_id`),
  ADD UNIQUE KEY `uk_pes` (`pes_pc_id`,`pes_so_id`);

--
-- Index pour la table `dd_personnages_sorts_prepares`
--
ALTER TABLE `dd_personnages_sorts_prepares`
  ADD PRIMARY KEY (`pesp_id`);

--
-- Index pour la table `dd_races`
--
ALTER TABLE `dd_races`
  ADD PRIMARY KEY (`ra_id`);

--
-- Index pour la table `dd_race_type`
--
ALTER TABLE `dd_race_type`
  ADD PRIMARY KEY (`rat_id`);

--
-- Index pour la table `dd_rencontres`
--
ALTER TABLE `dd_rencontres`
  ADD PRIMARY KEY (`re_id`);

--
-- Index pour la table `dd_rencontres_monstres`
--
ALTER TABLE `dd_rencontres_monstres`
  ADD PRIMARY KEY (`rem_id`);

--
-- Index pour la table `dd_ressources`
--
ALTER TABLE `dd_ressources`
  ADD PRIMARY KEY (`res_id`);

--
-- Index pour la table `dd_scenarios`
--
ALTER TABLE `dd_scenarios`
  ADD PRIMARY KEY (`sce_id`);

--
-- Index pour la table `dd_scenarios_chapitres`
--
ALTER TABLE `dd_scenarios_chapitres`
  ADD PRIMARY KEY (`scc_id`);

--
-- Index pour la table `dd_sortclasse`
--
ALTER TABLE `dd_sortclasse`
  ADD PRIMARY KEY (`sc_id`),
  ADD UNIQUE KEY `uk_sc` (`sc_so_id`,`sc_cla_id`);

--
-- Index pour la table `dd_sortdomaine`
--
ALTER TABLE `dd_sortdomaine`
  ADD PRIMARY KEY (`sd_id`);

--
-- Index pour la table `dd_sorts`
--
ALTER TABLE `dd_sorts`
  ADD PRIMARY KEY (`so_id`);

--
-- Index pour la table `dd_sorts_import`
--
ALTER TABLE `dd_sorts_import`
  ADD PRIMARY KEY (`so_id`);

--
-- Index pour la table `dd_tags`
--
ALTER TABLE `dd_tags`
  ADD PRIMARY KEY (`tag_id`),
  ADD UNIQUE KEY `uk_tag_slug` (`tag_slug`,`tag_j_id`);

--
-- Index pour la table `dd_typemagie`
--
ALTER TABLE `dd_typemagie`
  ADD PRIMARY KEY (`mag_id`);

--
-- Index pour la table `dd_types_notes`
--
ALTER TABLE `dd_types_notes`
  ADD PRIMARY KEY (`tyno_id`);

--
-- Index pour la table `dd_univers`
--
ALTER TABLE `dd_univers`
  ADD PRIMARY KEY (`un_id`);

--
-- Index pour la table `dd_univers_articles`
--
ALTER TABLE `dd_univers_articles`
  ADD PRIMARY KEY (`ua_id`);

--
-- Index pour la table `dd_univers_categories`
--
ALTER TABLE `dd_univers_categories`
  ADD PRIMARY KEY (`uca_id`);

--
-- Index pour la table `dd_univers_droits`
--
ALTER TABLE `dd_univers_droits`
  ADD PRIMARY KEY (`ud_id`),
  ADD UNIQUE KEY `uk_ud` (`ud_un_id`,`ud_j_id`);

--
-- Index pour la table `dd_variables`
--
ALTER TABLE `dd_variables`
  ADD PRIMARY KEY (`var_id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `dd_campagnes`
--
ALTER TABLE `dd_campagnes`
  MODIFY `camp_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_campagnes_notes`
--
ALTER TABLE `dd_campagnes_notes`
  MODIFY `cpno_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_campagnes_personnages`
--
ALTER TABLE `dd_campagnes_personnages`
  MODIFY `cp_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_campagnes_sources`
--
ALTER TABLE `dd_campagnes_sources`
  MODIFY `cs_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_campagnes_univers`
--
ALTER TABLE `dd_campagnes_univers`
  MODIFY `cu_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_capacites_speciales`
--
ALTER TABLE `dd_capacites_speciales`
  MODIFY `cap_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_caracteristiques`
--
ALTER TABLE `dd_caracteristiques`
  MODIFY `car_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_classes`
--
ALTER TABLE `dd_classes`
  MODIFY `cla_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_classe_capacite`
--
ALTER TABLE `dd_classe_capacite`
  MODIFY `cc_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_classe_niveau`
--
ALTER TABLE `dd_classe_niveau`
  MODIFY `cn_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_colleges`
--
ALTER TABLE `dd_colleges`
  MODIFY `co_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_competences`
--
ALTER TABLE `dd_competences`
  MODIFY `comp_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_data_don`
--
ALTER TABLE `dd_data_don`
  MODIFY `dado_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_domaines`
--
ALTER TABLE `dd_domaines`
  MODIFY `do_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_dons`
--
ALTER TABLE `dd_dons`
  MODIFY `do_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_joueurs`
--
ALTER TABLE `dd_joueurs`
  MODIFY `j_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_joueurs_sources`
--
ALTER TABLE `dd_joueurs_sources`
  MODIFY `js_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_modificateurs`
--
ALTER TABLE `dd_modificateurs`
  MODIFY `mod_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_monstres`
--
ALTER TABLE `dd_monstres`
  MODIFY `mo_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_notes`
--
ALTER TABLE `dd_notes`
  MODIFY `no_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_notes_contenus`
--
ALTER TABLE `dd_notes_contenus`
  MODIFY `noc_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_notes_tags`
--
ALTER TABLE `dd_notes_tags`
  MODIFY `notag_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_personnages`
--
ALTER TABLE `dd_personnages`
  MODIFY `pe_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_personnages_classes`
--
ALTER TABLE `dd_personnages_classes`
  MODIFY `pc_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_personnages_competences`
--
ALTER TABLE `dd_personnages_competences`
  MODIFY `pec_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_personnages_dons`
--
ALTER TABLE `dd_personnages_dons`
  MODIFY `ped_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_personnages_nls`
--
ALTER TABLE `dd_personnages_nls`
  MODIFY `penl_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_personnages_notes`
--
ALTER TABLE `dd_personnages_notes`
  MODIFY `pno_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_personnages_sorts`
--
ALTER TABLE `dd_personnages_sorts`
  MODIFY `pes_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_personnages_sorts_prepares`
--
ALTER TABLE `dd_personnages_sorts_prepares`
  MODIFY `pesp_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_races`
--
ALTER TABLE `dd_races`
  MODIFY `ra_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_race_type`
--
ALTER TABLE `dd_race_type`
  MODIFY `rat_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_rencontres`
--
ALTER TABLE `dd_rencontres`
  MODIFY `re_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_rencontres_monstres`
--
ALTER TABLE `dd_rencontres_monstres`
  MODIFY `rem_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_ressources`
--
ALTER TABLE `dd_ressources`
  MODIFY `res_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_scenarios`
--
ALTER TABLE `dd_scenarios`
  MODIFY `sce_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_scenarios_chapitres`
--
ALTER TABLE `dd_scenarios_chapitres`
  MODIFY `scc_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_sortclasse`
--
ALTER TABLE `dd_sortclasse`
  MODIFY `sc_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_sortdomaine`
--
ALTER TABLE `dd_sortdomaine`
  MODIFY `sd_id` mediumint(9) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_sorts`
--
ALTER TABLE `dd_sorts`
  MODIFY `so_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_sorts_import`
--
ALTER TABLE `dd_sorts_import`
  MODIFY `so_id` smallint(6) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_tags`
--
ALTER TABLE `dd_tags`
  MODIFY `tag_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_typemagie`
--
ALTER TABLE `dd_typemagie`
  MODIFY `mag_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_types_notes`
--
ALTER TABLE `dd_types_notes`
  MODIFY `tyno_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_univers`
--
ALTER TABLE `dd_univers`
  MODIFY `un_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_univers_articles`
--
ALTER TABLE `dd_univers_articles`
  MODIFY `ua_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_univers_categories`
--
ALTER TABLE `dd_univers_categories`
  MODIFY `uca_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_univers_droits`
--
ALTER TABLE `dd_univers_droits`
  MODIFY `ud_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dd_variables`
--
ALTER TABLE `dd_variables`
  MODIFY `var_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
