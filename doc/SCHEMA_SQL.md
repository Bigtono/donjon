<!-- Mis à jour : 2026-06-20 21:00 -->

# Codex DD v2 — Schéma de base de données

> Documentation lisible du schéma réel de la base.
> Source de vérité pour le développement — mise à jour à chaque évolution structurelle.
> Le fichier SQL complet pour import est `sql/schema.sql`.

---

## Versioning

| Version | Date | Auteur | Modifications |
|---|---|---|---|
| 1.0 | 2025-05 | JM | Création — schéma initial issu du dump XAMPP |
| 1.1 | 2026-06-01 | JM | Module Campagnes — refonte section 7 : `dd_oppositions` (copie éditable de monstre) + `dd_fichiers` (PJ génériques) ; ruleset hérité de la campagne (retrait `sce_ruleset_var_id`) ; univers 1-1 (`camp_un_id`, retrait `dd_campagnes_univers`) ; abandon `dd_rencontres_monstres` / `dd_rencontres_oppositions` ; `pe_camp_id` (dernière campagne jouée) |
| 1.2 | 2026-06-02 | JM | dd_sorts : ajout `so_concentration` / `so_rituel` (0/1, DD2024). Import en masse des sorts SRD 5.2.1 (res_id 93) par lots à IDs explicites |
| 1.3 | 2026-06-20 | JM | `dd_equipements` : CRÉÉE (équipement mondain, distincte de `dd_objets_magiques`). SQL committé : `sql/2026-06-20_equipements_sp-e0.sql`. Module compendium correspondant non développé — cf. plan SP-E (ARCHITECTURE_0_REFERENCE.md) |

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
| res_description | text | null | Description de la ressource |

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

### dd_alignements
Référentiel des alignements **commun à tous les rulesets DD** (9 alignements classiques).
Créé par le patch `2026-06-12_personnages_socle.sql`.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| al_id | int unsigned | PK | |
| al_nom | varchar(60) | nn | Ex : Loyal Bon |
| al_abreviation | varchar(10) | nn | Ex : LB, NN, CM |
| al_ordre | tinyint unsigned | nn, défaut 0 | Tri d'affichage |

---

### dd_bonus_maitrise
Bonus de maitrise par niveau dns *[DD2024]*

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| bm_id | int unsigned | PK | |
| bm_niveau | int | nn | de 1 à 20 |
| bm_bonus | int | nn | de 0 à 6 |
| bm_ruleset_var_id | int unsigned | nn | -> dd_variables |

### dd_fp
Facteur de puissance des monstres
| Champ | Type | Null | Commentaire |
|---|---|---|---|
| fp_id | int unsigned | PK | |
| fp_nom | varchar(3) | nn | alpahnumérique |
| fp_valeur | int | nn | |


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
| so_portee | varchar(150) | nn | |
| so_cible | varchar(150) | nn | *[DD3.5]* |
| so_zone_effet | varchar(150) | nn | *[DD3.5]* |
| so_duree_incantation | varchar(150) | nn | |
| so_duree_sort | varchar(150) | null | |
| so_resistance | varchar(150) | null | *[DD3.5]* Résistance à la magie. Ex : Oui, Non |
| so_jet_sauvegarde | varchar(100) | null | *[DD3.5]* Ex : Vigueur annule |
| so_concentration | tinyint(4) | nn, défaut 0 | *[DD2024]* Sort à concentration (0/1) |
| so_rituel | tinyint(4) | nn, défaut 0 | *[DD2024]* Sort lançable en rituel (0/1). Le « ou rituel » reste aussi présent dans `so_duree_incantation` |
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
| cla_clt_id | tinyint unsigned | nn, défaut 1 | Type -> dd_classe_type (1=base/2=prestige *[DD3.5]* historique ; 4=Base/5=Sous-classe *[DD2024]*) |
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
| cla_cla_id | int unsigned | null | *[DD2024]* Classe parente d'une sous-classe (cla_clt_id=5) -> dd_classes ; null pour Base/Prestige |
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
Type de classe — une ligne par ruleset (`clt_ruleset_var_id`), ID non normalisés entre rulesets.
| Champ | Type | Null | Commentaire |
|---|---|---|---|
| clt_id | int unsigned | PK | |
| clt_nom | varchar(50) | nn | |
| clt_ruleset_var_id | int unsigned | nn | -> dd_variables| |

> Valeurs confirmées en base : DD2024 → clt_id=4 « Base », clt_id=5 « Sous-classe ».
> DD3.5 utilise historiquement clt_id=1 « Base », clt_id=2 « Prestige » (voir code legacy
> `cla_clt_id === 2`). Ces littéraux sont dupliqués dans le code (pas de constante partagée) —
> voir « Module Classes — sous-classes (DD2024) » dans ARCHITECTURE_0_REFERENCE.md.

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
| hi_id | int unsigned | PK | |
| hi_nom | varchar(150) | nn | |
| hi_description | text | nn | |
| hi_res_id | int unsigned | nn | Source -> dd_ressources |
| hi_camp_id | int unsigned | null | null = global ; sinon homebrew -> dd_campagnes |
| hi_ruleset_var_id | int unsigned | nn | -> dd_variables |

---

---

### dd_format_objet_magique
Formats d'objet magique — détermine si la description est calculée auto (DD3.5) ou saisie librement.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| fom_id | int unsigned | PK | |
| fom_nom | varchar(50) | nn | Ex : "Auto (calculé)", "Description libre" |

---

### dd_categorie_objet_magique
Catégories d'objets magiques (Anneau, Arme, Baguette, Parchemin, Potion…).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| com_id | int unsigned | PK | |
| com_nom | varchar(80) | nn | |
| com_est_calcule | tinyint(1) | nn, défaut 0 | 1 = calcul auto NLS/prix activable (DD3.5 uniquement) |
| com_est_propriete | tinyint(1) | nn, défaut 0 | 1 = catégorie masquée par défaut dans la liste (propriétés spéciales DD3.5) |
| com_ruleset_var_id | int unsigned | nn | -> dd_variables |

> `com_est_calcule = 1` pour : Arme, Armure/Bouclier, Baguette, Parchemin, Potion/Huile (DD3.5 uniquement).
> En DD2024, toutes les catégories ont `com_est_calcule = 0` — pas de calcul auto.

---

### dd_objets_magiques
Objets magiques du compendium.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| om_id | int unsigned | PK | |
| om_nom | varchar(150) | nn | |
| om_com_id | int unsigned | nn | Catégorie -> dd_categorie_objet_magique |
| om_fom_id | int unsigned | nn, défaut 2 | Format -> dd_format_objet_magique (1=auto, 2=libre) |
| om_so_id | int unsigned | null | Sort lié (potions/parchemins/baguettes) -> dd_sorts |
| om_so_niveau | tinyint | nn, défaut 0 | *[DD3.5]*, NLS override (0 = calculé auto depuis dd_sortclasse) |
| om_modificateurs | tinyint | nn, défaut 0 | *[DD3.5]*, Bonus magique +1 à +5 (armes/armures) |
| om_variantes | varchar(255) | null | Variantes textuelles (mineur, majeur…) |
| om_prix | int | null | *[DD3.5]*, prix de l'objet |
| om_ajustement_prix | int | nn, defaut 0 | *[DD3.5]*, ajustement de prix de l'objet |
| om_description | text | null | Description HTML TinyMCE (format libre) |
| om_harmonisation | tinyint(4) | nn, défaut 0 | *[DD2024]*, 1 : harmonisation requise |
| om_rarete | int(10) | null | *[DD2024]*, -> dd_objets_magiques_rarete |
| om_visible | tinyint(1) | nn, défaut 1 | 0 = masqué aux joueurs non-éditeurs |
| om_res_id | int unsigned | nn | Source -> dd_ressources |
| om_camp_id | int unsigned | null | null = global ; sinon homebrew -> dd_campagnes |
| om_ruleset_var_id | int unsigned | nn | -> dd_variables |

### dd_objets_magiques_rarete
Rareté des bjets magiques du compendium.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| omr_id | int unsigned | PK | |
| omr_nom | varchar(150) | nn | |
| om_ruleset_var_id | int unsigned | nn | -> dd_variables |


### dd_equipements
Équipement mondain du compendium (armes, armures, matériel non magique) — distincte de
`dd_objets_magiques` (objets magiques).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| eqt_id | int unsigned | PK | |
| eqt_nom | varchar(150) | nn | |
| eqt_description | text | null | Description HTML TinyMCE (format libre) |
| eqt_visible | tinyint(1) | nn, défaut 1 | 0 = masqué aux joueurs non-éditeurs |
| eqt_res_id | int unsigned | nn | Source -> dd_ressources |
| eqt_camp_id | int unsigned | null | null = global ; sinon homebrew -> dd_campagnes |
| eqt_ruleset_var_id | int unsigned | nn | -> dd_variables |

> Table créée le 2026-06-20 (`sql/2026-06-20_equipements_sp-e0.sql`, committé dans le dépôt).
> ⚠️ Écart avec le modèle supplément (cf. § Supplément utilisateur, SP-C) : un seul flag
> `eqt_visible` plutôt que le couple `_public`/`_visible` des 8 tables déjà migrées — modèle de
> visibilité simple (ancien `om_visible` pré-SP-C0), pas de notion de propriétaire/supplément pour
> l'instant. À arbitrer explicitement si Équipements doit un jour rejoindre le mécanisme supplément
> (ajout `eqt_public` + `eqt_res_id` pointant vers une ressource supplément) — non fait, non
> nécessaire tant qu'aucun module n'existe pour cette table (cf. ARCHITECTURE_0_REFERENCE.md § Plan
> Équipements SP-E, DECISIONS_LOG.md [2026-06-20]).


### dd_monstres

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| mo_id | int unsigned | PK | |
| mo_nom | varchar(150) | nn | |
| mo_mocat_id | int(10) | nn | Catégorie du monstre -> dd_monstres_categories |
| mo_mogr_id | int(10) | null | groupe du monstre -> dd_monstres_groupes |
| mo_stats | text | null | Bloc de statistiques (format libre) |
| mo_fp_id | varchar(10) | null | Facteur de puissance (alphanumérique, ex : 1/2) |
| mo_j_id | int unsigned | null | Propriétaire -> dd_joueurs (null = visible par tous) |
| mo_res_id | int unsigned | nn | Source -> dd_ressources |
| mo_camp_id | int unsigned | null | null = global ; sinon homebrew -> dd_campagnes |
| mo_ruleset_var_id | int unsigned | nn | -> dd_variables |

### dd_monstres_categories

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| mocat_id | int unsigned | PK | |
| mocat_nom | varchar(150) | nn | |
| mocat_description | text | null | Description de la catégorie |
| mocat_ruleset_var_id | int unsigned | nn | -> dd_variables |

### dd_monstres_groupes

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| mogr_id | int unsigned | PK | |
| mogr_nom | varchar(150) | nn | |
| mogr_description | text | null | Description de la catégorie |
| mogr_ruleset_var_id | int unsigned | nn | -> dd_variables |


---

## 6. Personnages

### dd_personnages

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| pe_id | int unsigned | PK | |
| pe_nom | varchar(100) | nn | |
| pe_sexe | varchar(20) | null | Libellé libre, descriptif (féminin, masculin, etc.) — *patch 2026-06-12* |
| pe_j_id | int unsigned | nn | Propriétaire -> dd_joueurs |
| pe_ra_id | int unsigned | nn, défaut 0 | Race de base -> dd_races |
| pe_arc_id | int unsigned | nn, défaut 0 | *[DD3.5]* Archétype racial -> dd_races (0 = aucun) |
| pe_hi_id | int unsigned | null | *[DD2024]* Historique -> dd_historiques (NULL = aucun) — *patch 2026-06-12 (3.1)* |
| pe_al_id | int unsigned | null | Alignement -> dd_alignements (NULL = non renseigné) — *patch 2026-06-12* |
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
| pe_notes_scope | tinyint unsigned | nn, défaut 0 | Affichage notes : 0 = campagne en cours, 1 = toutes les campagnes — *patch 2026-06-12* |
| pe_camp_id | int unsigned | null | Dernière campagne jouée (campagne « en cours ») -> dd_campagnes ; NULL = aucune. Le rattachement réel reste géré par `dd_campagnes_personnages` (N-N) ; ce champ n'est qu'un raccourci de contexte. |
| pe_ruleset_var_id | int unsigned | nn | -> dd_variables |
| pe_date_creation | datetime | nn | Horodatage automatique |
| pe_date_modif | datetime | nn | Mis à jour automatiquement |

> `pe_camp_id` est dénormalisé volontairement : il mémorise la **dernière** campagne du personnage
> (raccourci d'ouverture de session/fiche). La source de vérité du lien personnage↔campagne est la
> table N-N `dd_campagnes_personnages`. Géré par le module Personnages.

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
Liste des compétences que possède le personnage
| Champ | Type | Null | Commentaire |
|---|---|---|---|
| pec_id | int unsigned | PK | |
| pec_pe_id | int unsigned | nn, UK(pec_pe_id, pec_comp_id) | -> dd_personnages |
| pec_comp_id | int unsigned | nn | -> dd_competences |
| pec_maitrise | tinyint | nn, défaut 0 | *[DD3.5]* Nombre de rangs ; *[DD2024]* 0=aucune, 1=maîtrise, 2=expertise |

---

### dd_personnages_dons
Liste des dons que possède le personnage
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
| camp_ruleset_var_id | int unsigned | nn | -> dd_variables. **Ruleset maître** : hérité par scénarios, chapitres, rencontres et oppositions. |
| camp_un_id | int unsigned | null | Univers de la campagne -> dd_univers ; NULL = aucun. **1 campagne = au plus 1 univers**. Les univers sont agnostiques du ruleset. |
| camp_resume | text | null | Résumé court (texte simple) |
| camp_description | longtext | null | Description complète (HTML TinyMCE, images uploadées autorisées) |
| camp_date_creation | datetime | nn | Horodatage automatique |

> **Ruleset hérité** : le ruleset n'est stocké QUE sur la campagne (`camp_ruleset_var_id`).
> Scénarios / chapitres / rencontres / oppositions le lisent par jointure remontante. Aucune
> colonne `_ruleset_var_id` redondante sur les entités filles.
> **Univers 1-1** : la liaison N-N `dd_campagnes_univers` de l'ébauche précédente est **abandonnée**
> au profit de `camp_un_id`.

---

### dd_campagnes_personnages
Personnages rattachés à une campagne. **Source de vérité du lien personnage↔campagne (N-N).**

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| cp_id | int unsigned | PK | |
| cp_camp_id | int unsigned | nn, UK(cp_camp_id, cp_pe_id) | -> dd_campagnes |
| cp_pe_id | int unsigned | nn | -> dd_personnages |
| cp_notes_mj | text | null | **RÉSERVÉ** — notes privées du MJ sur ce personnage. Hors UI v2 (en attente du module Personnages). Visibles MJ uniquement ; perdues si le personnage quitte la campagne. |
| cp_actif | tinyint(1) | nn, défaut 1 | 0 = personnage inactif dans la campagne |

> Le raccourci `dd_personnages.pe_camp_id` (dernière campagne jouée) est dénormalisé et n'a pas
> valeur de lien : c'est cette table qui fait foi. Voir §6 `dd_personnages`.

---

### dd_campagnes_sources
Sources actives spécifiques à une campagne (priorité 1 de `getActiveResIds()`, surcharge la sélection personnelle).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| cs_id | int unsigned | PK | |
| cs_camp_id | int unsigned | nn, UK(cs_camp_id, cs_res_id) | -> dd_campagnes |
| cs_res_id | int unsigned | nn | -> dd_ressources |

---

### dd_scenarios
Ruleset hérité de la campagne (pas de colonne ruleset).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| sce_id | int unsigned | PK | |
| sce_nom | varchar(150) | nn | |
| sce_ordre | smallint unsigned | nn, défaut 0 | Ordre d'affichage dans la campagne |
| sce_description | longtext | null | Description (HTML TinyMCE, images uploadées autorisées) |
| sce_camp_id | int unsigned | nn | -> dd_campagnes |

> Duplicable (« *[nom] - copie* »), dans la **même campagne ou une autre campagne du même ruleset**
> (toute duplication est limitée au ruleset courant). La copie recopie en cascade chapitres,
> rencontres et oppositions.

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
Une rencontre appartient **obligatoirement** à un chapitre (plus de rencontre orpheline).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| re_id | int unsigned | PK | |
| re_nom | varchar(150) | nn | |
| re_code | varchar(20) | null | Code de référence libre |
| re_scc_id | int unsigned | nn | Chapitre parent -> dd_scenarios_chapitres |
| re_description | longtext | null | Description (HTML TinyMCE, images uploadées autorisées) |
| re_composition | text | null | **Détail littéral de la composition de la rencontre (effectifs, disposition, vagues…)**. Champ texte mis en évidence dans l'UI rencontre. Remplace tout stockage chiffré d'effectif. |

> **Effectifs en clair** : il n'existe aucune colonne d'effectif chiffrée ni de table de liaison
> rencontre↔opposition. Une rencontre porte N oppositions (lien 1-N via `dd_oppositions.opp_re_id`)
> et un champ texte `re_composition` qui décrit littéralement les effectifs. La table v1
> `dd_rencontres_monstres` (et l'ébauche `dd_rencontres_oppositions`) sont **abandonnées**.
> Rencontre duplicable (« *[nom] - copie* ») vers un autre scénario, même ou autre campagne du
> même ruleset ; la copie recopie ses oppositions.

---

### dd_oppositions
Copie **éditable** d'un monstre du compendium, propre à une rencontre. Le MJ recopie un monstre
puis ajuste/annote librement pour sa partie, **sans altérer le compendium**.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| opp_id | int unsigned | PK | |
| opp_nom | varchar(150) | nn | Recopié de `mo_nom`, éditable |
| opp_mocat_nom | varchar(150) | null | Recopié du libellé de catégorie (`mocat_nom` via `mo_mocat_id`), **stocké en texte libre**, éditable |
| opp_stats | text | null | Recopié de `mo_stats`, éditable |
| opp_re_id | int unsigned | nn | Rencontre parente -> dd_rencontres |
| opp_mo_id | int unsigned | nn | Monstre-template d'origine -> dd_monstres. **Non éditable** par le MJ (traçabilité). |

> Lien rencontre **1-N** (`opp_re_id`), pas de table de liaison.
> À la création, le formulaire propose un sélecteur de monstre (scopé ruleset courant + sources
> actives) qui pré-remplit `opp_nom`, `opp_mocat_nom`, `opp_stats` et fige `opp_mo_id`.
> Duplicable (« *[nom] - copie* »).
> `opp_mo_id` normalisé en `int unsigned` (la spec initiale notait `int(10)`).

---

### dd_fichiers
Pièces jointes **PDF** génériques, rattachables à une campagne, un scénario ou une rencontre
(table polymorphe, un seul handler d'upload). Stockage du binaire hors base.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| fi_id | int unsigned | PK | |
| fi_entite | enum('campagne','scenario','rencontre') | nn | Type d'entité porteuse |
| fi_entite_id | int unsigned | nn, KEY(fi_entite, fi_entite_id) | Id de l'entité porteuse (camp_id / sce_id / re_id) |
| fi_nom_origine | varchar(255) | nn | Nom de fichier d'origine (affichage) |
| fi_chemin | varchar(255) | nn | Chemin relatif de stockage serveur |
| fi_mime | varchar(100) | nn | Type MIME validé (application/pdf attendu) |
| fi_taille | int unsigned | nn | Taille en octets |
| fi_j_id | int unsigned | nn | Déposant -> dd_joueurs |
| fi_date | datetime | nn | Horodatage automatique |

> **PDF uniquement** : validation serveur double (extension + magic bytes), stockage sous
> `uploads/{fi_entite}/{fi_entite_id}/` protégé (hors webroot ou `.htaccess`). Le téléchargement
> requiert une autorisation (propriétaire/MJ de la campagne porteuse).
> Le même socle d'upload sert aux **images** insérées dans les champs `*_description` (TinyMCE).

---

### dd_campagnes_notes

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| cpno_id | int unsigned | PK | |
| cpno_no_id | int unsigned | nn, UK(cpno_no_id, cpno_camp_id) | -> dd_notes |
| cpno_camp_id | int unsigned | nn | -> dd_campagnes |

> **RÉSERVÉ / hors UI v2** : système de notes non finalisé, dépend du module Notes/Personnages.

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