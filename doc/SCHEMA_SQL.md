# Codex DD v2 — Schéma de base de données

> Documentation lisible du schéma réel de la base.
> Source de vérité pour le développement — mise à jour à chaque évolution structurelle.
> Le fichier SQL complet pour import est `sql/schema.sql`.

---

## Versioning

| Version | Date | Auteur | Modifications |
|---|---|---|---|
| 1.0 | 2025-05 | JM | Création — schéma initial issu du dump XAMPP |

---

## Conventions de lecture

- **PK** = clé primaire
- **UK** = clé unique
- `-> table` = clé étrangère vers la table indiquée
- *[DD3.5]* = champ spécifique au ruleset DD3.5
- *[DD2024]* = champ spécifique au ruleset DD2024
- `null` = valeur autorisée | `nn` = NOT NULL

---

## ⚠️ Tables temporaires à supprimer

| Table | Raison |
|---|---|
| `dd_sorts_import` | Table de migration v1→v2, à supprimer après vérification des données |

---

## Groupes fonctionnels

1. [Référentiels](#1-référentiels)
2. [Utilisateurs](#2-utilisateurs)
3. [Compendium — Sorts](#3-compendium--sorts)
4. [Compendium — Classes](#4-compendium--classes)
5. [Compendium — Autres](#5-compendium--autres)
6. [Personnages](#6-personnages)
7. [Campagnes](#7-campagnes)
8. [Wiki / Univers](#8-wiki--univers)
9. [Notes](#9-notes)

---

## 1. Référentiels

### dd_variables
Référentiel de valeurs paramétrables (rulesets, catégories de capacités, etc.)

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| var_id | int unsigned | PK | |
| var_cat | varchar(50) | nn | Catégorie. Ex : `ruleset`, `tcap` |
| var_valeur | varchar(100) | nn | Libellé de la valeur |
| var_ordre | tinyint unsigned | nn, défaut 0 | Ordre d'affichage dans les selects |
| var_commentaire | varchar(255) | null | commentaire sur l'usage de la variable |

---

### dd_ressources
Livres et suppléments de règles. Utilisés pour filtrer le contenu du compendium.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| res_id | int unsigned | PK | |
| res_nom | varchar(150) | nn | Titre complet du livre |
| res_abreviation | varchar(20) | nn | Abréviation affichée dans les listes |
| res_selection | tinyint(1) | nn, défaut 0 | 1 = actif par défaut dans les sélections |
| res_ruleset_var_id | int unsigned | nn | -> dd_variables |
| res_j_id | int unsigned | null | null = ressource officielle ; sinon propriétaire d'un recueil homebrew -> dd_joueurs |
| res_editeur | varchar(255) | null | Nom de l'éditeur |
| res_pages | int | nn | Nombre de pages |
| res_description | text | nn | Description de la ressource |

---

### dd_caracteristiques
Les 6 caractéristiques DD (FOR, CON, DEX, INT, SAG, CHA).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| car_id | int unsigned | PK | |
| car_nom | varchar(30) | nn | Nom complet. Ex : Force |
| car_diminutif | char(3) | nn | Abréviation 3 lettres. Ex : for |

---

### dd_modificateurs
Table de correspondance valeur de caractéristique → modificateur et bonus de sorts.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| mod_id | int unsigned | PK | |
| mod_carac | tinyint unsigned | nn | Valeur de la caractéristique (1 à 30) |
| mod_modificateur | tinyint | nn | Modificateur correspondant |
| mod_bonusSort0 … mod_bonusSort9 | tinyint unsigned | nn, défaut 0 | Sorts bonus par niveau (0 à 9) |

---

### dd_typemagie
Types de magie (profane, divin).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| mag_id | int unsigned | PK | |
| mag_nom | varchar(50) | nn | Ex : Magie profane |
| mag_abreviation | varchar(10) | nn | Ex : Arc |
| mag_ruleset_var_id | int unsigned | nn | -> dd_variables |

---

## 2. Utilisateurs

### dd_joueurs
Utilisateurs du site.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| j_id | int unsigned | PK | |
| j_prenom | varchar(50) | nn, défaut '' | |
| j_nom | varchar(50) | nn, défaut '' | |
| j_pseudo | varchar(50) | nn, UK | |
| j_email | varchar(150) | nn, UK | |
| j_password_hash | varchar(255) | nn | Hash bcrypt |
| j_remember_token | varchar(100) | null | Token cookie "se souvenir de moi" |
| j_remember_token_expires | datetime | null | Expiration du token remember me |
| j_reset_token | varchar(100) | null | Token de réinitialisation de mot de passe |
| j_reset_token_expires | datetime | null | Expiration du token reset (1 heure) |
| j_avatar_url | varchar(255) | null | URL de l'avatar |
| j_bio | text | null | Biographie libre |
| j_date_inscription | datetime | nn | Horodatage automatique |
| j_derniere_connexion | datetime | null | Mis à jour à chaque login |
| j_admin | tinyint(1) | nn, défaut 0 | 1 = admin global (accès total) |
| j_compendium_manager | tinyint(1) | nn, défaut 0 | 1 = peut éditer le compendium global sans être admin |
| j_default_ruleset_var_id | int unsigned | null | Ruleset chargé par défaut -> dd_variables |
| j_items_par_page | tinyint unsigned | nn, défaut 20 | Taille des listes paginées |
| j_visible | tinyint(1) | nn, défaut 1 | 0 = compte désactivé |
| j_notes | text | null | Notes admin sur cet utilisateur |
| j_mode_campagne | tinyint(1) | nn, défaut 0 | 1 = menu Campagnes visible et actif |
| j_affichage_ruleset | tinyint(1) | nn, défaut 1 | 1 = ruleset actif affiché dans le header |
| j_dd_onglet_sort | tinyint(1) | nn, défaut 0 | Préférence d'onglet sorts (usage futur) |
| j_dd_onglet_don | tinyint(1) | nn, défaut 0 | Préférence d'onglet dons (usage futur) |
| j_dd_onglet_om | tinyint(1) | nn, défaut 0 | Préférence d'onglet objets magiques (usage futur) |

---

### dd_joueurs_sources
Sélection personnelle de sources par utilisateur et par ruleset.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| js_id | int unsigned | PK | |
| js_j_id | int unsigned | nn, UK(js_j_id, js_res_id) | -> dd_joueurs |
| js_res_id | int unsigned | nn | -> dd_ressources |
| js_ruleset_var_id | int unsigned | nn | -> dd_variables |

---

## 3. Compendium — Sorts

### dd_sorts
Sorts du compendium.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| so_id | int unsigned | PK | |
| so_nom | varchar(150) | nn | |
| so_niveau | int | null | *[DD2024]* Niveau du sort (0-9) |
| so_co_id | int unsigned | null | Collège de magie -> dd_colleges |
| so_branche | varchar(40) | null | *[DD3.5]* Branche du collège. Ex : Appel |
| so_vocal | tinyint(4) | nn, défaut 0 | Composante vocale requise (0/1) |
| so_gestuel | tinyint(4) | nn, défaut 0 | Composante gestuelle requise (0/1) |
| so_materiel | tinyint(4) | nn, défaut 0 | Composante matérielle requise (0/1) |
| so_focalisateur | tinyint(4) | nn, défaut 0 | Focalisateur requis (0/1) |
| so_focalisateur_divin | tinyint(4) | nn, défaut 0 | *[DD3.5]* Focalisateur divin requis (0/1) |
| so_composante | varchar(255) | null | Détail textuel des composantes matérielles nécessaires |
| so_portee | varchar(100) | nn | |
| so_cible | varchar(150) | nn | *[DD3.5]* |
| so_zone_effet | varchar(100) | nn | *[DD3.5]* |
| so_duree_incantation | varchar(100) | nn | |
| so_duree_sort | varchar(100) | null | |
| so_resistance | varchar(100) | null | *[DD3.5]* Résistance à la magie. Ex : Oui, Non |
| so_jet_sauvegarde | varchar(50) | null | *[DD3.5]* Ex : Vigueur annule |
| so_description | text | null | Description complète du sort |
| so_resume | text | null | Résumé en quelques mots du sort |
| so_res_id | int unsigned | nn | Source -> dd_ressources |
| so_camp_id | int unsigned | null | null = compendium global ; sinon homebrew -> dd_campagnes |
| so_ruleset_var_id | int unsigned | nn | -> dd_variables |

---

### dd_colleges
Collèges de magie (Abjuration, Évocation, Nécromancie...).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| co_id | int unsigned | PK | |
| co_nom | varchar(50) | nn | |

---

### dd_sortclasse
Niveaux d'un sort pour chaque classe capable de le lancer.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| sc_id | int unsigned | PK | |
| sc_so_id | int unsigned | nn | -> dd_sorts |
| sc_cla_id | int unsigned | nn | -> dd_classes |
| sc_niveau | tinyint unsigned | nn | Niveau du sort pour cette classe (0-9) |

---

### dd_domaines
*[DD3.5]* Domaines de magie divine (Guerre, Mort, Soleil...).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| do_id | int | PK | |
| do_nom | varchar(255) | nn | |
| do_pouvoir | text | null | Description du pouvoir de domaine |
| do_dieux | text | null | Divinités accordant ce domaine |

> ⚠️ Table héritée de la v1 — moteur MyISAM, charset utf8. À convertir en InnoDB utf8mb4 lors d'une prochaine migration.

---

### dd_sortdomaine
*[DD3.5]* Sorts accessibles via un domaine, avec leur niveau dans ce domaine.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| sd_id | mediumint | PK | |
| sd_so_id | mediumint | nn | -> dd_sorts |
| sd_niveau | tinyint | nn | Niveau du sort dans ce domaine |
| sd_do_id | mediumint | nn | -> dd_domaines |

> ⚠️ Table héritée de la v1 — charset latin1. À convertir en utf8mb4 lors d'une prochaine migration.

---

## 4. Compendium — Classes

### dd_classes
Classes de personnage (base et prestige).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| cla_id | int unsigned | PK | |
| cla_nom | varchar(100) | nn | |
| cla_abreviation | varchar(20) | nn | |
| cla_clt_id | tinyint unsigned | nn, défaut 1 | Type : 1=base, 2=prestige *[DD3.5]* |
| cla_dV | tinyint unsigned | nn, défaut 6 | Dé de vie (4, 6, 8, 10, 12) |
| cla_alignement | varchar(100) | null | Restrictions d'alignement |
| cla_car_id | int unsigned | nn, défaut 0 | Caractéristique principale -> dd_caracteristiques (0=aucune) |
| cla_mag_id | int unsigned | nn, défaut 0 | Type de magie -> dd_typemagie (0=non lanceur de sorts) |
| cla_sort_connu | tinyint(1) | nn, défaut 0 | 1 = la classe a des sorts connus |
| cla_sort_compris | tinyint(1) | nn, défaut 0 | 1 = la classe a des sorts compris (grimoire) |
| cla_sort_prepare | tinyint(1) | nn, défaut 0 | 1 = la classe prépare ses sorts |
| cla_domaine_divin | tinyint(1) | nn, défaut 0 | *[DD3.5]* 1 = la classe choisit des domaines divins |
| cla_niveauMax | tinyint unsigned | nn, défaut 20 | Niveaux max : 3, 5, 10 ou 20 |
| cla_pointsCompetences | tinyint unsigned | null | *[DD3.5]* Points de compétences par niveau |
| cla_po_niveau1 | smallint unsigned | null | *[DD3.5]* Pièces d'or de départ |
| cla_conditions | text | null | *[DD3.5]* Conditions d'accès (classes de prestige) |
| cla_armes | text | null | Formations aux armes. Pour *[DD3.5]* contient armes et armures |
| cla_armures | text | null | *[DD2024]* Formations aux armures |
| cla_outils | text | null | *[DD2024]* Formations aux outils |
| cla_sauvegardes | text | null | *[DD2024]* Jets de sauvegarde maîtrisés |
| cla_equipement | text | null | *[DD2024]* Équipement de départ |
| cla_competences | text | null | Compétences de classe |
| cla_sorts | text | null | Description de la liste de sorts |
| cla_description | text | null | Description générale de la classe |
| cla_traits | text | null | Traits raciaux ou de classe |
| cla_caracteristiques | text | null | Caractéristiques importantes |
| cla_critere_rec | text | null | Critères recommandés |
| cla_pouvoir1 … cla_pouvoir5 | varchar(100) | null | Intitulé des pouvoirs spécifiques (colonnes de la table de bonus) |
| cla_cla_id | int unsigned | null | Classe parente éventuelle -> dd_classes |
| cla_res_id | int unsigned | nn | Source -> dd_ressources |
| cla_camp_id | int unsigned | null | null = global ; sinon homebrew -> dd_campagnes |
| cla_ruleset_var_id | int unsigned | nn | -> dd_variables |

---

### dd_classe_niveau
Table de bonus de classe par niveau.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| cn_id | int unsigned | PK | |
| cn_cla_id | int unsigned | nn, UK(cn_cla_id, cn_niveau) | -> dd_classes |
| cn_niveau | tinyint unsigned | nn | Niveau de classe (1 à niveauMax) |
| cn_bba | varchar(20) | nn, défaut '0' | *[DD3.5]* Bonus de base à l'attaque. Peut être multi-valeurs ex : +6/+1 |
| cn_reflexes | tinyint | nn, défaut 0 | *[DD3.5]* Bonus de base aux réflexes |
| cn_vigueur | tinyint | nn, défaut 0 | *[DD3.5]* Bonus de base à la vigueur |
| cn_volonte | tinyint | nn, défaut 0 | *[DD3.5]* Bonus de base à la volonté |
| cn_sort_n0 … cn_sort_n9 | tinyint unsigned | null | Sorts par jour par niveau de sort (0-9) |
| cn_sortPrepare | tinyint unsigned | null | *[DD2024]* Nombre de sorts préparés |
| cn_sortConnu_n0 … cn_sortConnu_n9 | tinyint unsigned | null | *[DD3.5]*  Sorts connus par niveau de sort (0-9) |
| cn_niveauSortArcane | tinyint(1) | nn, défaut 0 | *[DD3.5]* 1 = ce niveau de prestige avance le NLS arcane |
| cn_niveauSortDivin | tinyint(1) | nn, défaut 0 | *[DD3.5]* 1 = ce niveau de prestige avance le NLS divin |
| cn_niveauSortEffectif | tinyint(1) | nn, défaut 0 | *[DD3.5]* 1 = ce niveau de prestige avance le NLS effectif |
| cn_pouvoir1 … cn_pouvoir5 | varchar(255) | null | Valeur du pouvoir spécifique pour ce niveau |
| cn_sort_bonus | int unsigned | null | *[DD3.5]* Nb de sorts bonus par niveau de classe de prestige |

---

### dd_classe_capacite
Affectation d'une capacité spéciale à un niveau de classe.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| cc_id | int unsigned | PK | |
| cc_cla_id | int unsigned | nn, UK(cc_cla_id, cc_cap_id, cc_niveau) | -> dd_classes |
| cc_cap_id | int unsigned | nn | -> dd_capacites_speciales |
| cc_niveau | tinyint unsigned | nn | Niveau auquel la capacité est acquise |
| cc_precision | varchar(255) | null | Précision contextuelle affichée entre parenthèses. Ex : 3/jour, humanoïdes uniquement |

---

### dd_classe_competence
Affectation d'une compétence à une classe. Pour DD3.5 : il s'agit des compétences de classe. Pour DD2024 : il s'agit des compétences maitrisées
| Champ | Type | Null | Commentaire |
|---|---|---|---|
| ccomp_id | int unsigned | PK | |
| ccomp_cla_id | int unsigned | nn, UK(ccomp_cla_id, ccomp_comp_id, cc_niveau) | -> dd_classes |
| ccomp_comp_id | int unsigned | nn | -> dd_competences |
| ccomp_precision | varchar(255) | null | Précision pour les compétences d'artisanat, connaissance... Ex : Géographie, tailleur de pierre |

---

### dd_classe_type
Type de classe 
| Champ | Type | Null | Commentaire |
|---|---|---|---|
| clt_id | int unsigned | PK | |
| clt_nom | varchar(50) | nn | |
| clt_ruleset_var_id | int unsigned | nn | -> dd_variables| |

---

### dd_capacites_speciales
Capacités spéciales attribuables aux classes.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| cap_id | int unsigned | PK | |
| cap_nom | varchar(150) | nn | |
| cap_description | text | null | Description complète |
| cap_type | varchar(50) | null | Ex : Ext, Mag, Sur |
| cap_categorie_var_id | int unsigned | null | Catégorie -> dd_variables (cat=tcap) |

---

## 5. Compendium — Autres

### dd_dons

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| do_id | int unsigned | PK | |
| do_nom | varchar(150) | nn | |
| do_dado_id | int unsigned | null | Catégorie de don -> dd_data_don |
| do_conditions | text | null | prérequis d'accès au don |
| do_texte | text | null | Description complète |
| do_resume | text | null | Résumé court |
| do_res_id | int unsigned | nn | Source -> dd_ressources |
| do_camp_id | int unsigned | null | null = global ; sinon homebrew -> dd_campagnes |
| do_ruleset_var_id | int unsigned | nn | -> dd_variables |

---

### dd_data_don
Catégories de dons (Combat, Métamagie, Création d'objets...).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| dado_id | int unsigned | PK | |
| dado_nom | varchar(80) | nn | |
| dado_abreviation | varchar(5) | null | |
| dado_ruleset_var_id | int unsigned | nn | -> dd_variables |


---

### dd_competences

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| comp_id | int unsigned | PK | |
| comp_nom | varchar(100) | nn | |
| comp_car_id | int unsigned | nn | Caractéristique associée -> dd_caracteristiques |
| comp_malusArmure | int | nn | |
| comp_formation | int | nn | |
| comp_description | text | nn | |
| comp_res_id | int unsigned | nn | Source -> dd_ressources |
| comp_ruleset_var_id | int unsigned | nn | -> dd_variables |

---

### dd_races

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| ra_id | int unsigned | PK | |
| ra_nom | varchar(100) | nn | |
| ra_rat_id | int unsigned | nn | Type de race -> dd_race_type (1=base, 2=archétype) |
| ra_description | text | null | |
| ra_mod_niveau | int | nn, défaut 0 | *[DD3.5]* Modificateur de niveau global |
| ra_camp_id | int unsigned | null | null = global ; sinon homebrew -> dd_campagnes |
| ra_res_id | int unsigned | nn | Source -> dd_ressources |
| ra_ruleset_var_id | int unsigned | nn | -> dd_variables |

---

### dd_race_type
Types de race (base, archétype *[DD3.5]*).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| rat_id | int unsigned | PK | |
| rat_nom | varchar(50) | nn | |
| rat_description | text | null | |
| rat_ruleset_var_id | int unsigned | nn | -> dd_variables |

---

### dd_race_capacite
Affectation des capacités spéciales à une race (capacités raciales).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| cr_id | int unsigned | PK | |
| cr_ra_id | int unsigned | nn, UK(cr_ra_id, cr_cap_id) | -> dd_races |
| cr_cap_id | int unsigned | nn | -> dd_capacites_speciales |
| cr_ordre | tinyint unsigned | nn, défaut 0 | Ordre d'affichage — géré par drag & drop dans le formulaire |

> Pas de `cr_niveau` : une race confère l'ensemble de ses capacités spéciales dès la sélection,
> sans notion de niveau d'acquisition (contrairement à `dd_classe_capacite.cc_niveau`).

---

### dd_historiques
historiques de personnages (*[DD2024]*).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| his_id | int unsigned | PK | |
| his_nom | varchar(150) | nn | |
| his_description | text | nn | |
| his_res_id | int unsigned | nn | Source -> dd_ressources |
| his_camp_id | int unsigned | null | null = global ; sinon homebrew -> dd_campagnes |
| his_ruleset_var_id | int unsigned | nn | -> dd_variables |

---

### dd_monstres

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| mo_id | int unsigned | PK | |
| mo_nom | varchar(150) | nn | |
| mo_stats | text | null | Bloc de statistiques (format libre) |
| mo_fp_id | varchar(10) | null | Facteur de puissance (alphanumérique, ex : 1/2) |
| mo_j_id | int unsigned | null | Propriétaire -> dd_joueurs (null = visible par tous) |
| mo_ruleset_var_id | int unsigned | nn | -> dd_variables |

---

## 6. Personnages

### dd_personnages

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| pe_id | int unsigned | PK | |
| pe_nom | varchar(100) | nn | |
| pe_j_id | int unsigned | nn | Propriétaire -> dd_joueurs |
| pe_ra_id | int unsigned | nn, défaut 0 | Race de base -> dd_races |
| pe_arc_id | int unsigned | nn, défaut 0 | *[DD3.5]* Archétype racial -> dd_races (0 = aucun) |
| pe_for | tinyint unsigned | nn, défaut 10 | Force |
| pe_con | tinyint unsigned | nn, défaut 10 | Constitution |
| pe_dex | tinyint unsigned | nn, défaut 10 | Dextérité |
| pe_int | tinyint unsigned | nn, défaut 10 | Intelligence |
| pe_sag | tinyint unsigned | nn, défaut 10 | Sagesse |
| pe_cha | tinyint unsigned | nn, défaut 10 | Charisme |
| pe_ca | smallint | nn, défaut 10 | Classe d'armure totale |
| pe_pv | smallint | nn, défaut 0 | Points de vie totaux |
| pe_background | text | null | Historique du personnage |
| pe_notes | text | null | Notes privées du joueur (non visibles par le MJ) |
| pe_ruleset_var_id | int unsigned | nn | -> dd_variables |
| pe_date_creation | datetime | nn | Horodatage automatique |
| pe_date_modif | datetime | nn | Mis à jour automatiquement |

---

### dd_personnages_classes
Classes et niveaux d'un personnage.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| pc_id | int unsigned | PK | |
| pc_pe_id | int unsigned | nn, UK(pc_pe_id, pc_cla_id) | -> dd_personnages |
| pc_cla_id | int unsigned | nn | -> dd_classes |
| pc_niveau | tinyint unsigned | nn, défaut 1 | Niveau du personnage dans cette classe |
| pc_do_id_1 | int unsigned | null | *[DD3.5]* Premier domaine divin choisi -> dd_domaines |
| pc_do_id_2 | int unsigned | null | *[DD3.5]* Second domaine divin choisi -> dd_domaines |

---

### dd_personnages_nls
*[DD3.5]* Affectation des niveaux de classe de prestige aux classes de base de lanceur de sort (NLS).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| penl_id | int unsigned | PK | |
| penl_pc_id_base | int unsigned | nn | Classe de base réceptrice -> dd_personnages_classes |
| penl_pc_id_prestige | int unsigned | nn | Classe de prestige source -> dd_personnages_classes |
| penl_niveau | tinyint unsigned | nn | Niveau dans la classe de prestige concerné |

---

### dd_personnages_sorts
Sorts connus ou appris d'un personnage par classe.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| pes_id | int unsigned | PK | |
| pes_pc_id | int unsigned | nn, UK(pes_pc_id, pes_so_id) | Classe du personnage -> dd_personnages_classes |
| pes_so_id | int unsigned | nn | -> dd_sorts |
| pes_compris | tinyint(1) | nn, défaut 0 | 1 = sort compris (copié dans le grimoire) |

---

### dd_personnages_sorts_prepares
Sorts préparés d'un personnage.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| pesp_id | int unsigned | PK | |
| pesp_pe_id | int unsigned | nn | -> dd_personnages |
| pesp_cla_id | int unsigned | nn | Classe pour laquelle le sort est préparé -> dd_classes |
| pesp_so_id | int unsigned | nn | -> dd_sorts |
| pesp_metamagie | varchar(100) | null | *[DD3.5]* IDs de dons de métamagie appliqués, séparés par virgule |
| pesp_niveau | tinyint unsigned | null | *[DD3.5]* Niveau effectif après application de la métamagie |
| pesp_nb | tinyint unsigned | nn, défaut 0 | *[DD3.5]* Nombre d'exemplaires préparés ; *[DD2024]* 0 ou 1 |

---

### dd_personnages_competences

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| pec_id | int unsigned | PK | |
| pec_pe_id | int unsigned | nn, UK(pec_pe_id, pec_comp_id) | -> dd_personnages |
| pec_comp_id | int unsigned | nn | -> dd_competences |
| pec_maitrise | tinyint | nn, défaut 0 | *[DD3.5]* Nombre de rangs ; *[DD2024]* 0=aucune, 1=maîtrise, 2=expertise |

---

### dd_personnages_dons

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| ped_id | int unsigned | PK | |
| ped_pe_id | int unsigned | nn | -> dd_personnages |
| ped_do_id | int unsigned | nn | -> dd_dons |
| ped_niveau | tinyint unsigned | null | Niveau du personnage auquel le don a été pris |

---

### dd_personnages_notes
Degré de connaissance d'une note par un personnage.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| pno_id | int unsigned | PK | |
| pno_pe_id | int unsigned | nn, UK(pno_pe_id, pno_no_id) | -> dd_personnages |
| pno_no_id | int unsigned | nn | -> dd_notes |
| pno_dd | tinyint unsigned | nn, défaut 0 | Degré de connaissance du personnage (0 = aucun) |
| pno_actif | tinyint(1) | nn, défaut 1 | 0 = lien désactivé |

---

## 7. Campagnes

### dd_campagnes

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| camp_id | int unsigned | PK | |
| camp_nom | varchar(150) | nn | |
| camp_j_id | int unsigned | nn | MJ/propriétaire -> dd_joueurs |
| camp_ruleset_var_id | int unsigned | nn | -> dd_variables |
| camp_resume | text | null | Résumé court |
| camp_description | text | null | Description complète |
| camp_date_creation | datetime | nn | Horodatage automatique |

---

### dd_campagnes_personnages
Personnages rattachés à une campagne.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| cp_id | int unsigned | PK | |
| cp_camp_id | int unsigned | nn, UK(cp_camp_id, cp_pe_id) | -> dd_campagnes |
| cp_pe_id | int unsigned | nn | -> dd_personnages |
| cp_notes_mj | text | null | Notes privées du MJ sur ce personnage. Visibles uniquement par le MJ. Supprimées si le personnage quitte la campagne. |
| cp_actif | tinyint(1) | nn, défaut 1 | 0 = personnage inactif dans la campagne |

---

### dd_campagnes_sources
Sources actives spécifiques à une campagne (surcharge la sélection personnelle).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| cs_id | int unsigned | PK | |
| cs_camp_id | int unsigned | nn, UK(cs_camp_id, cs_res_id) | -> dd_campagnes |
| cs_res_id | int unsigned | nn | -> dd_ressources |

---

### dd_campagnes_univers
Univers wiki rattachés à une campagne.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| cu_id | int unsigned | PK | |
| cu_camp_id | int unsigned | nn, UK(cu_camp_id, cu_un_id) | -> dd_campagnes |
| cu_un_id | int unsigned | nn | -> dd_univers |

---

### dd_scenarios

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| sce_id | int unsigned | PK | |
| sce_nom | varchar(150) | nn | |
| sce_ordre | smallint unsigned | nn, défaut 0 | Ordre d'affichage dans la campagne |
| sce_description | text | null | |
| sce_camp_id | int unsigned | nn | -> dd_campagnes |
| sce_ruleset_var_id | int unsigned | nn | -> dd_variables |

---

### dd_scenarios_chapitres

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| scc_id | int unsigned | PK | |
| scc_sce_id | int unsigned | nn | -> dd_scenarios |
| scc_nom | varchar(150) | nn | |
| scc_ordre | smallint unsigned | nn, défaut 0 | |
| scc_abreviation | varchar(10) | null | |
| scc_description | text | null | |

---

### dd_rencontres

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| re_id | int unsigned | PK | |
| re_nom | varchar(150) | nn | |
| re_code | varchar(20) | null | Code de référence libre |
| re_scc_id | int unsigned | null | Chapitre parent -> dd_scenarios_chapitres (null = rencontre orpheline) |
| re_description | text | null | |

---

### dd_rencontres_monstres

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| rem_id | int unsigned | PK | |
| rem_re_id | int unsigned | nn | -> dd_rencontres |
| rem_mo_id | int unsigned | nn | -> dd_monstres |
| rem_effectif | smallint unsigned | nn, défaut 1 | Nombre d'exemplaires dans la rencontre |

---

### dd_campagnes_notes

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| cpno_id | int unsigned | PK | |
| cpno_no_id | int unsigned | nn, UK(cpno_no_id, cpno_camp_id) | -> dd_notes |
| cpno_camp_id | int unsigned | nn | -> dd_campagnes |

---

## 8. Wiki / Univers

### dd_univers

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| un_id | int unsigned | PK | |
| un_nom | varchar(150) | nn | |
| un_j_id | int unsigned | nn | Propriétaire -> dd_joueurs |
| un_description | text | null | |
| un_public | tinyint(1) | nn, défaut 0 | 1 = sélectionnable par d'autres MJs pour leurs campagnes |
| un_date_creation | datetime | nn | Horodatage automatique |

---

### dd_univers_droits
Délégation de droits d'édition sur un univers public (v1 : globale sur tout l'univers).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| ud_id | int unsigned | PK | |
| ud_un_id | int unsigned | nn, UK(ud_un_id, ud_j_id) | -> dd_univers |
| ud_j_id | int unsigned | nn | Délégataire -> dd_joueurs |

---

### dd_univers_categories

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| uca_id | int unsigned | PK | |
| uca_un_id | int unsigned | nn | -> dd_univers |
| uca_nom | varchar(100) | nn | Ex : Géographie, Histoire, Organisations |
| uca_ordre | tinyint unsigned | nn, défaut 0 | Ordre d'affichage |

---

### dd_univers_articles

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| ua_id | int unsigned | PK | |
| ua_uca_id | int unsigned | nn | Catégorie -> dd_univers_categories |
| ua_un_id | int unsigned | nn | -> dd_univers |
| ua_titre | varchar(200) | nn | |
| ua_contenu | longtext | null | Contenu de l'article (format libre) |
| ua_visible | tinyint(1) | nn, défaut 1 | 0 = visible MJ seul ; 1 = visible par tous les ayants droit de l'univers |
| ua_date_creation | datetime | nn | Horodatage automatique |
| ua_date_modif | datetime | nn | Mis à jour automatiquement |

---

## 9. Notes

### dd_notes

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| no_id | int unsigned | PK | |
| no_nom | varchar(200) | nn | Titre de la note |
| no_tyno_id | int unsigned | null | Type de note -> dd_types_notes |
| no_date | datetime | nn | Horodatage automatique |
| no_j_id | int unsigned | nn | Rédacteur -> dd_joueurs |

---

### dd_types_notes

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| tyno_id | int unsigned | PK | |
| tyno_nom | varchar(80) | nn | |

---

### dd_notes_contenus
Blocs de contenu d'une note, avec niveau de difficulté d'accès.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| noc_id | int unsigned | PK | |
| noc_no_id | int unsigned | nn | -> dd_notes |
| noc_dd | tinyint unsigned | nn, défaut 0 | Degré de difficulté d'accès (0 = libre, plus élevé = plus restreint) |
| noc_texte | longtext | null | Contenu du bloc |

---

### dd_tags

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| tag_id | int unsigned | PK | |
| tag_nom | varchar(80) | nn | |
| tag_slug | varchar(100) | nn, UK(tag_slug, tag_j_id) | Version URL-safe du nom |
| tag_j_id | int unsigned | nn | Propriétaire -> dd_joueurs |
| tag_date | datetime | nn | Horodatage automatique |

---

### dd_notes_tags

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| notag_id | int unsigned | PK | |
| notag_no_id | int unsigned | nn, UK(notag_no_id, notag_tag_id) | -> dd_notes |
| notag_tag_id | int unsigned | nn | -> dd_tags |



------------------------------------------------------------------------------------------------------
#LEGENDE
PK — Primary Key. C'est la clé primaire de la table : le champ qui identifie chaque enregistrement de façon unique. Dans toutes les tables du projet c'est toujours le premier champ, suffixe _id, auto-incrémenté.
nn — Not Null. Le champ est obligatoire — la base refuse l'insertion si la valeur est absente. À l'opposé, quand une colonne indique null, la valeur est optionnelle.
UK — Unique Key. Contrainte d'unicité : la combinaison des champs indiqués entre parenthèses ne peut pas apparaître deux fois dans la table. Par exemple UK(cp_camp_id, cp_pe_id) sur dd_campagnes_personnages garantit qu'un même personnage ne peut pas être rattaché deux fois à la même campagne.