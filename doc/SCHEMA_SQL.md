<!-- Mis à jour : 2026-11-09 19:40 -->

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
| 1.4 | 2026-06-20 | JM | `dd_oppositions.opp_mo_id` rendu NULLABLE — monstre d'origine optionnel, saisie d'opposition 100% manuelle possible. SQL committé : `sql/2026-06-20_oppositions_monstre_optionnel.sql` |
| 1.6 | 2026-08-24 | JM | **SP-CP0** — ordre manuel des deux derniers niveaux du module Campagnes : `dd_rencontres.re_ordre` et `dd_oppositions.opp_ordre` CRÉÉES (`smallint unsigned nn défaut 0`), avec backfill reprenant l'ordre alphabétique en vigueur jusque-là, rang à rang dans chaque parent. Les quatre niveaux sont désormais ordonnés par glisser-déposer. SQL **committé** : `sql/2026-08-24_ordre_sp-cp.sql` (appliqué en dev le 2026-08-24 ; **reste à appliquer en prod OVH**) |
| 1.7 | 2026-08-28 | JM | **SP-IM1→IM4 et IM7** — import des classes DD2024, aucune évolution de structure : uniquement des données (12 classes, 240 lignes `dd_classe_niveau`, 244 capacités, 10 sous-classes ids 70-79, 87 lignes `dd_classe_competence`). **Sémantique précisée** : `dd_classe_competence` et `cla_pointsCompetences` n'ont pas le même sens selon le ruleset — voir les deux entrées concernées ci-dessous et `DECISIONS_LOG.md` D-IM7. SQL committé : `sql/2026-08-28_classes_dd2024_sp-im{1,2,3,4,7}.sql` (appliqué en dev le 2026-08-28 ; **reste à appliquer en prod OVH**) |
| 1.8 | 2026-08-28 | JM | `dd_capacites_speciales.cap_categorie_var_id` **SUPPRIMÉE** — reliquat v1 (race 91 / classe 92), information portée par les tables de liaison ; ses valeurs ne désignaient plus rien depuis la refonte de `dd_variables`, et la catégorie `tcap` n'existe plus. Colonne `cap_classe_initiale` ajoutée à la doc et à `sql/schema.sql`, où elle manquait. SQL committé : `sql/2026-08-28_capacites_drop_categorie.sql` (**NON IDEMPOTENT**, appliqué en dev le 2026-08-28 ; **reste à appliquer en prod OVH**) |
| 1.9 | 2026-08-28 | JM | **SP-IM8** — espèces DD2024, aucune évolution de structure : 9 espèces (4 créées, ids 18-21), 33 traits (`dd_capacites_speciales` 901+ / `dd_race_capacite`) et 3 tables du SRD dans `dd_tableaux` (ids 40-42). Les 15 traits d'espèce antérieurs (ids 424-438) sont retirés. SQL committé : `sql/2026-08-28_races_dd2024_sp-im8.sql` (appliqué en dev le 2026-08-28 ; **reste à appliquer en prod OVH**) |
| 1.10 | 2026-08-28 | JM | **SP-IM5** — options de classe DD2024 : 2 catégories de dons créées dans `dd_data_don` (22 « Métamagie », 23 « Manifestation occulte ») et 38 dons (ids 501-538). Aucune évolution de structure. SQL committé : `sql/2026-08-28_options_dd2024_sp-im5.sql` (appliqué en dev le 2026-08-28 ; **reste à appliquer en prod OVH**) |
| 1.11 | 2026-08-28 | JM | **SP-IM9a** — redressement de 235 objets magiques DD2024 (description, `om_rarete`, `om_harmonisation`, `om_com_id`) d'après la ligne de type du SRD. Aucune évolution de structure. Reste `om_rarete` à 0 sur 119 lignes — les déclinaisons, traitées en SP-IM9b. SQL committé : `sql/2026-08-28_objets_dd2024_sp-im9a.sql` (appliqué en dev le 2026-08-28 ; **reste à appliquer en prod OVH**) |
| 1.12 | 2026-08-28 | JM | **SP-IM9b** — 121 déclinaisons d'objets magiques DD2024 redressées (description, rareté propre, catégorie, harmonisation). Aucune évolution de structure. Les 356 objets de la source SRD ont désormais une rareté valide. SQL committé : `sql/2026-08-28_objets_dd2024_sp-im9b.sql` (appliqué en dev le 2026-08-28 ; **reste à appliquer en prod OVH**) |
| 1.13 | 2026-08-28 | JM | **SP-IM9c** — 10 tables d'objets magiques saisies dans `dd_tableaux` (ids 43-52) et 10 descriptions réécrites avec le tag `[[tab:slug]]`. Aucune évolution de structure. SQL committé : `sql/2026-08-28_objets_dd2024_sp-im9c.sql` (appliqué en dev le 2026-08-28 ; **reste à appliquer en prod OVH**) |
| 1.14 | 2026-10-07 | JM | **SP-DP5** — `dd_migrations` CRÉÉE : trace des migrations SQL appliquées à la base de chaque environnement. Pas de fichier SQL : la table est créée par le moteur (`include/migrations.php`, `migrationsAssurerTable()`) à son premier appel, qui y inscrit aussitôt les 37 migrations antérieures au statut `reference` sans les rejouer. Créée en dev le 2026-10-07 ; sera créée en prod au premier déploiement (SP-DP). Préfixe `dd_` confirmé en production — le renommage `dd2_` n'a jamais été appliqué |
| 1.15 | 2026-10-11 | JM | **SP-PO0 / SP-PO2** — `dd_categorie_equipement` CRÉÉE (arbre de familles d'équipement par ruleset, colonnes de liste en JSON). `dd_equipements` (vide jusque-là) reçoit `eqt_cae_id`, `eqt_prix_pc`, `eqt_prix_txt`, `eqt_poids_g`, `eqt_poids_txt`, `eqt_attributs`, `eqt_ordre` et `eqt_public` (rejoint le mécanisme Supplément). `dd_categorie_objet_magique.com_slug` ajouté (clé du tag `[[liste:objet|famille=…]]`). Import de 269 articles du DRS 07. SQL committé : `sql/2026-10-11_equipements_00_schema_sp-po0.sql` (**NON IDEMPOTENT**, ALTER TABLE) et `sql/2026-10-11_equipements_dd35_drs07_sp-po2.sql` ; règles : `sql/2026-10-11_regles_dd35_drs07_sp-drs2.sql`, `…_drs23_sp-drs3.sql` (appliqués en dev le 2026-10-11 ; **restent à appliquer en prod OVH**, par le déploiement) |
| 1.16 | 2026-10-16 | JM | **SP-PO5** — équipement DD2024, aucune évolution de structure : 28 familles `dd_categorie_equipement` (ruleset 2) et 238 articles `dd_equipements` (source « SRD 5.2.1 »), 13 règles et 3 tableaux. SQL committé : `sql/2026-10-16_equipements_dd2024_srd_sp-po5.sql`, `sql/2026-10-16_regles_dd2024_equipement_sp-po5.sql` (appliqués en dev le 2026-10-16 ; **restent à appliquer en prod OVH**) |
| 1.17 | 2026-10-31 | JM | **SP-CH0** — choix liés aux capacités de classe : `dd_classe_capacite.cc_nb_choix`, `dd_capacites_speciales.cap_choix_mode` / `cap_choix_dado_id`, `dd_personnages_dons.ped_pech_id` AJOUTÉES ; `dd_personnages_choix` CRÉÉE. SQL : `sql/2026-10-31_choix_capacites_sp-ch0.sql` (appliqué en dev le 2026-10-31 ; **reste à appliquer en prod OVH**) |
| 1.19 | 2026-10-31 | JM | **SP-CH8** — `dd_personnages_choix.pech_precision` AJOUTÉE (précision libre d'un don choisi). SQL : `sql/2026-10-31_choix_precision_sp-ch8.sql` (appliqué en dev le 2026-10-31 ; **reste à appliquer en prod OVH**) |
| 1.18 | 2026-10-31 | JM | **SP-DO0** — dons DD3.5 : `dd_dons.do_guerrier`, `do_prereq_bba/for/dex/con/int/sag/cha`, `do_niv_lanceur` et `dd_capacites_speciales.cap_choix_guerrier` AJOUTÉES. 92 dons DD3.5 renseignés par appariement de nom avec une table tierce locale (46 dons de guerrier). SQL : `sql/2026-10-31_dons_techniques_dd35_sp-do0.sql` (appliqué en dev le 2026-10-31 ; **reste à appliquer en prod OVH**) |
| 1.21 | 2026-11-01 | JM | **SP-NO7** — tables de transit `dd_v1_notes`, `dd_v1_notes_contenus`, `dd_v1_notes_tags` CRÉÉES (copie de l'export des notes v1 + `no_importe_no_id`), temporaires. SQL : `sql/2026-11-01_sp-no7_notes_v1_transit.sql` (appliqué en dev le 2026-11-01 ; **reste à appliquer en prod OVH**) |
| 1.20 | 2026-11-01 | JM | **SP-NO0** — module Notes : `dd_notes`, `dd_notes_contenus`, `dd_types_notes`, `dd_personnages_notes` RECRÉÉES (tables vides jamais utilisées ; campagne, scénario facultatif, catégorie par ruleset, sections, destinataires et date de lecture) ; `dd_notes_conditions` CRÉÉE ; `dd_campagnes_notes` SUPPRIMÉE ; 11 catégories amorcées par ruleset. SQL : `sql/2026-11-01_sp-no0_notes.sql` (garde-fou : échoue sans rien modifier si une des tables supprimées contient une ligne ; appliqué en dev le 2026-11-01 ; **reste à appliquer en prod OVH**) |
| 1.22 | 2026-11-01 | JM | **SP-PE20 / SP-PE21** — `dd_personnages_competences.pec_mod_divers` / `pec_mod_libelle` AJOUTÉES ; `dd_competences_synergies` CRÉÉE (28 synergies DD3.5). SQL : `sql/2026-11-01_sp-pe20_competences_mod_divers.sql`, `sql/2026-11-01_sp-pe21_synergies_competences.sql` (appliqués en dev le 2026-11-01 ; **restent à appliquer en prod OVH**) |
| 1.23 | 2026-11-06 | JM | **SP-NO11** — `dd_notes.no_diffusion_campagne` AJOUTÉE (diffusion à toute la campagne) ; `dd_personnages_notes` ne sert plus qu'au suivi de lecture pour ces notes. SQL : `sql/2026-11-06_sp-no11_notes_diffusion_campagne.sql` (appliqué en dev le 2026-11-06 ; **reste à appliquer en prod OVH**) |
| 1.24 | 2026-11-06 | JM | **SP-PO6** — possessions du personnage : `dd_personnages_possessions` et `dd_personnages_possessions_elements` CRÉÉES ; `dd_objets_magiques.om_bonus_equiv` / `om_nls` / `om_restriction` AJOUTÉES (propriétés spéciales DD3.5, 94 valeurs chargées, `om_ajustement_prix` des propriétés remis à 0, déclinaisons Défense et Résistance à la magie créées, doublon « Sombre » supprimé) ; potions et baguettes DD3.5 masquées (`om_visible` = 0). SQL : `sql/2026-11-06_sp-po6a_possessions.sql`, `…_sp-po6b_proprietes_speciales.sql`, `…_sp-po6c_masquage_potions_baguettes.sql` (appliqués en dev le 2026-11-06 ; **restent à appliquer en prod OVH**) |
| 1.25 | 2026-11-07 | JM | Base locale **rechargée depuis le dump de production** du 2026-11-07 : toutes les migrations antérieures (1.17 → 1.24 comprises) y étaient jouées, les mentions « reste à appliquer en prod » de ces lignes sont donc soldées. **SP-TB12** — `dd_tableaux_categories` CRÉÉE (8 catégories communes aux rulesets), `dd_tableaux.tab_tabc_id` AJOUTÉE (FK, `ON DELETE SET NULL`) ; les 113 tableaux classés. SQL : `sql/2026-11-07_sp-tb12a_categories_tableaux.sql`, `…_sp-tb12b_tableaux_upsert.sql` (renvoi de toute la table, appliqués en dev le 2026-11-07 ; **restent à appliquer en prod OVH**) |
| 1.26 | 2026-11-07 | JM | **SP-TB8** — écran du MJ : `dd_campagnes_ecran` CRÉÉE (tableaux posés sur l'écran d'une campagne, FK en cascade), `dd_campagnes.camp_ecran_colonnes` AJOUTÉE. SQL : `sql/2026-11-07_sp-tb8b_ecran_mj.sql` (appliqué en dev le 2026-11-07 ; **reste à appliquer en prod OVH**) |
| 1.27 | 2026-11-07 | JM | **SP-DRS4b / SP-TB13** — données seulement, aucune colonne : `dd_tableaux_categories` reçoit la catégorie 9 « Compétence » ; 40 tableaux `competence-*` ajoutés à `dd_tableaux` (DD3.5) ; `dd_competences.comp_description` réécrite pour les 36 compétences mères DD3.5 ; deux `comp_nom` débarrassés d'un blanc final. SQL : `sql/2026-11-08_sp-drs4b_competences_dd35.sql` (appliqué en dev le 2026-11-07 ; **reste à appliquer en prod OVH**) |
| 1.28 | 2026-11-07 | JM | **SP-CP11** — suivi des PV des oppositions : `dd_oppositions.opp_nombre` (effectif, défaut 1) et `opp_pv_max` (PV max d'une créature, pré-rempli d'après la ligne « PV » du bloc de stats : 121 / 128 en local) AJOUTÉES ; `dd_oppositions_pv` CRÉÉE (PV courants des créatures entamées, FK en cascade). SQL : `sql/2026-11-07_sp-cp11_oppositions_pv.sql` (**NON IDEMPOTENT**, appliqué en dev le 2026-11-07 ; **reste à appliquer en prod OVH**) |
| 1.29 | 2026-11-07 | JM | **SP-CP11c** — données seulement, aucune colonne : `dd_oppositions.opp_nombre` renseigné d'après la composition des rencontres de la campagne v1 (55 oppositions), `opp_pv_max` repris là où il était vide. SQL : `sql/2026-11-08_sp-cv1b_effectifs_oppositions.sql` (appliqué en dev le 2026-11-07 ; **reste à appliquer en prod OVH**, après `sp-cv1`) |
| 1.30 | 2026-11-09 | JM | **SP-DRS10** — données seulement, aucune colonne : 15 classes de prestige DD3.5 mises en conformité avec le DRS (`dd_classes`, `dd_classe_niveau`, `dd_classe_capacite`, `dd_classe_competence`, `dd_sortclasse`), 5 classes de PNJ créées (`cla_clt_id` 3) ; capacités réécrites ou créées dans `dd_capacites_speciales`, `cap_classe_initiale` désormais renseignée pour les capacités propres à une classe (variantes, D-DRS11) ; 5 tableaux `classe-*` (catégorie Classe) ; racine de règles « Les classes » et 4 termes de glossaire dans `dd_regles`. SQL : `sql/2026-11-09_sp-drs10_classes_prestige_pnj_dd35.sql` (appliqué en dev le 2026-11-09 ; **reste à appliquer en prod OVH**) |
| 1.5 | 2026-07-01 | JM | Audit `SHOW CREATE TABLE` sur les 7 tables restantes du Supplément (SP-C5/C6, débloquant) : `_public`/`_visible` **existent déjà en base réelle** sur `dd_dons`, `dd_sorts`, `dd_competences`, `dd_races`, `dd_classes`, `dd_historiques` (+ `om_public` sur `dd_objets_magiques`, `om_visible` déjà documenté). Colonnes ajoutées à la doc ci-dessous. `sql/patch_004_supplements.sql` reste introuvable dans le dépôt (appliqué directement en base, jamais committé — même écart que l'incident `mo_j_id`). Écart noté au passage : `dd_dons.do_page_source` (int NOT NULL) présent en base, non documenté, sans rapport avec SP-C — non traité ici |

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
| `dd_modificateurs` | **Morte depuis SP-MA1** (2026-08-27) — était vide et n'a jamais été lue. Le modificateur vient de `modCarac()`, les sorts bonus de `bonusSortsCarac()`, toutes deux dans `include/helpers.php`. À supprimer |
| `dd_sorts_branche_backup_spma3` | **SP-MA3** — copie des 690 valeurs `so_branche` d'origine (DD3.5), prise avant la séparation branche/registre. Deux rôles : retour arrière, et **source de la migration** — `sql/migrate_registre_sp-ma3.php` lit toujours cette table et jamais la colonne vive, ce qui le rend rejouable. Seule trace des résidus de troncature perdus. À supprimer une fois la migration validée avec du recul |

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
10. [Technique](#10-technique)

---

## 1. Référentiels

### dd_variables
Référentiel de valeurs paramétrables (rulesets, catégories de capacités, etc.)

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| var_id | int unsigned | PK | |
| var_cat | varchar(50) | nn | Catégorie. Deux seulement en base : `ruleset` et `profinc` (`tcap` a disparu avec `cap_categorie_var_id`, cf. `dd_capacites_speciales`) |
| var_valeur | varchar(100) | nn | Libellé de la valeur |
| var_ordre | tinyint unsigned | nn, défaut 0 | Ordre d'affichage dans les selects |
| var_commentaire | varchar(255) | null | commentaire sur l'usage de la variable |

> Catégorie `cadence` — **cadences de renouvellement** (SP-MA4b,
> `sql/2026-09-01_cadence_renouvellement_sp-ma4b.sql`). IDs figés, constantes `CADENCE_*` :
> `7` Repos long, changement libre · `8` Repos long, un seul sort *(DD2024 seul)* ·
> `9` Montée de niveau. Accesseur : `cadencesRenouvellement($db)` — **sans filtrage par ruleset**,
> aucune valeur n'étant impossible dans l'absolu pour une classe maison.

> Catégorie `profinc` — **profils d'incantation** (SP-MA0, `sql/2026-08-27_profil_incantation_sp-ma0.sql`).
> IDs figés, repris en constantes `PROFINC_*` dans `include/helpers.php` :
> `3` Liste préparée · `4` Grimoire · `5` Répertoire spontané *(DD3.5 uniquement)* ·
> `6` Magie de pacte *(DD2024 uniquement)*. Le filtrage par ruleset est centralisé dans
> `profilsIncantation($db, $ruleset_var_id)`. Voir `METIER_7_SORTS.md` §6.

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
| so_branche | varchar(40) | null | *[DD3.5]* Branche du collège, **une seule**. Ex : Appel, Coercition, Création. Contient aussi les 6 disciplines psioniques du GMP, de même rôle syntaxique. Nettoyé et normalisé par SP-MA3 |
| so_registre | varchar(120) | null | *[DD3.5]* Registre(s) du sort, séparés par `, `. Ex : `mental, terreur`. **Saisi sans crochets** — la fiche les ajoute au rendu (convention SRD). Créé par SP-MA3 (`sql/2026-08-27_registre_sp-ma3.sql`) |
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
| so_public | tinyint(1) | nn, défaut 0 | Supplément : 0 = privé, 1 = partagé |
| so_visible | tinyint(1) | nn, défaut 1 | Supplément : 0 = brouillon masqué, 1 = visible |
| so_ruleset_var_id | int unsigned | nn | -> dd_variables |

> `so_public`/`so_visible` confirmées en base le 2026-07-01 (audit `SHOW CREATE TABLE`, cf. versioning v1.5) — mécanisme Supplément (SP-C), même sémantique que `mo_public`/`mo_visible`.

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

### dd_classe_sort
*[DD2024]* Sorts **toujours préparés** accordés par une classe ou une sous-classe (SP-MA4a).
Même rôle que `dd_sortdomaine` pour les domaines DD3.5 : un sort rattaché à un porteur, avec un niveau.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| cs_id | int unsigned | PK | |
| cs_cla_id | int unsigned | nn, UK(cs_cla_id, cs_so_id, cs_variante) | **Classe OU sous-classe** -> dd_classes — une sous-classe est une classe (`cla_clt_id = 5`) |
| cs_so_id | int unsigned | nn | -> dd_sorts |
| cs_niveau | tinyint unsigned | nn | Niveau de classe d'acquisition. **Cumulatif** : un Paladin 9 a les sorts des niveaux 3, 5 et 9 — filtrer `cs_niveau <= niveau` |
| cs_variante | varchar(30) | nn, défaut `''` | Cercle de la Terre du Druide : `aride` / `polaire` / `tempéré` / `tropical`. Chaîne **vide** et non NULL, les NULL étant distincts dans une clé unique MySQL |
| cs_usages | tinyint unsigned | null | Incantations sans emplacement ; NULL = aucune |
| cs_recharge | varchar(10) | null | `court` / `long` |

> Ces sorts **ne comptent pas** dans `cn_sortPrepare`. Ne contient ni les Manifestations occultes
> (importées comme dons par `SP-IM5`), ni les sorts toujours préparés **choisis** par le joueur
> (voir `dd_personnages_sorts_prepares.pesp_origine`).

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
| cla_mag_id | int unsigned | nn, défaut 0 | Lanceur de sorts. **Plage propre à chaque ruleset** *(D-MAG2)* : *[DD3.5]* 0=non lanceur, 1=profane, 2=divin -> dd_typemagie ; *[DD2024]* 0=non lanceur, **1=lanceur, sans distinction** — la valeur n'y désigne alors **aucune** ligne `dd_typemagie`. `cla_mag_id > 0` reste le test « classe lanceuse » dans les deux rulesets ; le libellé `dd_typemagie` ne se lit **que** si `cla_ruleset_var_id = 1` |
| cla_profil_incantation | int unsigned | nn, défaut 0 | Profil d'incantation -> dd_variables (`var_cat = 'profinc'`). 0 = aucun. 3=Liste préparée, 4=Grimoire, 5=Répertoire spontané *[DD3.5]*, 6=Magie de pacte *[DD2024]*. Constantes `PROFINC_*` dans `include/helpers.php` |
| cla_renouvellement | int unsigned | nn, défaut 0 | Cadence de renouvellement du réservoir (axe C, SP-MA4b) -> dd_variables (`var_cat = 'cadence'`). 0 = aucune. 7=Repos long changement libre, 8=Repos long un seul sort *[DD2024]*, 9=Montée de niveau. Constantes `CADENCE_*`. **Ne porte pas la périodicité fine DD3.5** (barde : niveau 5 puis tous les 3 ; ensorceleur : niveau 4 puis tous les 2) — trop fin pour une aide de jeu, le détail reste dans le descriptif de la classe |
| ~~cla_sort_connu~~ | tinyint(1) | nn, défaut 0 | ⚠️ **DÉPRÉCIÉ (SP-MA0, 2026-08-27)** — remplacé par `cla_profil_incantation`. Colonne conservée mais **ni lue ni écrite** ; contenu figé et faux (Magicien et Ensorceleur inversés). Ne pas réutiliser |
| ~~cla_sort_compris~~ | tinyint(1) | nn, défaut 0 | ⚠️ **DÉPRÉCIÉ (SP-MA0)** — idem |
| ~~cla_sort_prepare~~ | tinyint(1) | nn, défaut 0 | ⚠️ **DÉPRÉCIÉ (SP-MA0)** — idem |
| cla_domaine_divin | tinyint(1) | nn, défaut 0 | *[DD3.5]* 1 = la classe choisit des domaines divins |
| cla_niveauMax | tinyint unsigned | nn, défaut 20 | Niveaux max : 3, 5, 10 ou 20 |
| cla_pointsCompetences | tinyint unsigned | null | Sens propre à chaque ruleset *(SP-IM7)* : *[DD3.5]* points de compétences par niveau (à multiplier, + mod. Int) ; *[DD2024]* **nombre de compétences que le personnage choisit** dans la liste `dd_classe_competence` de sa classe |
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
| cla_public | tinyint(1) | nn, défaut 0 | Supplément : 0 = privé, 1 = partagé |
| cla_visible | tinyint(1) | nn, défaut 1 | Supplément : 0 = brouillon masqué, 1 = visible |
| cla_ruleset_var_id | int unsigned | nn | -> dd_variables |

> `cla_public`/`cla_visible` confirmées en base le 2026-07-01 (audit `SHOW CREATE TABLE`, cf. versioning v1.5).

---

### dd_classe_niveau
Table de bonus de classe par niveau.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| cn_id | int unsigned | PK | |
| cn_cla_id | int unsigned | nn, UK(cn_cla_id, cn_niveau) | -> dd_classes. ⚠ **Cette clé unique n'existait pas en base** — documentée depuis toujours, absente en réalité (seule la PRIMARY sur `cn_id` était posée). Créée le 2026-08-28 par `sql/2026-08-28_cle_unique_classe_niveau.sql` sous le nom `uk_cn_classe_niveau`, après l'incident de duplication qu'elle aurait dû empêcher |
| cn_niveau | tinyint unsigned | nn | Niveau de classe (1 à niveauMax) |
| cn_bba | varchar(20) | nn, défaut '0' | *[DD3.5]* Bonus de base à l'attaque. Peut être multi-valeurs ex : +6/+1 |
| cn_reflexes | tinyint | nn, défaut 0 | *[DD3.5]* Bonus de base aux réflexes |
| cn_vigueur | tinyint | nn, défaut 0 | *[DD3.5]* Bonus de base à la vigueur |
| cn_volonte | tinyint | nn, défaut 0 | *[DD3.5]* Bonus de base à la volonté |
| cn_sort_n0 … cn_sort_n9 | tinyint unsigned | null | Sorts par jour par niveau de sort (0-9) |
| cn_sortPrepare | tinyint unsigned | null | *[DD2024]* Nombre de sorts préparés |
| cn_sortConnu_n0 … cn_sortConnu_n9 | tinyint unsigned | null | *[DD3.5]*  Sorts connus par niveau de sort (0-9) |
| cn_niveauSortArcane | int | null (valeurs 0/1 depuis SP-MA6) | *[DD3.5]* 1 = ce niveau de prestige avance le NLS d'une base profane. Exclusif de `cn_sort_n*` (SP-MA6) |
| cn_niveauSortDivin | int | null (valeurs 0/1 depuis SP-MA6) | *[DD3.5]* 1 = ce niveau de prestige avance le NLS d'une base divine. Exclusif de `cn_sort_n*` (SP-MA6) |
| cn_niveauSortEffectif | int | null (valeurs 0/1 depuis SP-MA6) | *[DD3.5]* 1 = ce niveau de prestige avance le NLS d'une base lanceuse au choix (« Au choix »). Exclusif de `cn_sort_n*` (SP-MA6) |
| cn_pouvoir1 … cn_pouvoir5 | varchar(255) | null | Valeur du pouvoir spécifique pour ce niveau |
| cn_sortsBonus | int | null | *[DD3.5]* Nb de sorts bonus par niveau de classe de prestige |

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
| cc_nb_choix | tinyint unsigned | nn, défaut 0 | *[SP-CH]* Nombre de choix que la capacité accorde à CE niveau (0 = aucun ; sans effet si `cap_choix_mode` est vide) |

---

### dd_classe_competence
Affectation d'une compétence à une classe. **La sémantique diffère d'un ruleset à l'autre**, et
avec elle le rôle de `dd_classes.cla_pointsCompetences` :
- *[DD3.5]* — les **compétences de classe**. Un point de compétence investi dans l'une d'elles vaut
  1 rang, contre 1/2 rang ailleurs. Le nombre de points par niveau est `cla_pointsCompetences`.
- *[DD2024]* — les compétences que le personnage **peut** maîtriser. Il en choisit un nombre fixe,
  porté par `cla_pointsCompetences` (« 2 au choix parmi : … »). Une classe sans liste fermée — le
  Barde choisit parmi les 18 — n'a **aucune ligne ici** : seul le texte `cla_competences` la décrit.
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
| cap_classe_initiale | int | null | -> dd_classes, classe d'origine de la capacité ; pour une variante propre à une classe (D-DRS11), c'est elle qui distingue deux capacités de même nom |
| cap_choix_mode | varchar(10) | nn, défaut '' | *[SP-CH]* Nature du choix que le joueur saisit sur sa fiche : vide = aucun, `texte` ou `don` |
| cap_choix_dado_id | int unsigned | null | *[SP-CH]* -> dd_data_don : catégorie de don proposée en mode `don` (NULL = toutes). Non transporté par l'export de classes |
| cap_choix_guerrier | tinyint(1) | nn, défaut 0 | *[SP-DO]* Mode `don` : limite le choix aux dons de guerrier (`dd_dons.do_guerrier`) ; avec `cap_choix_dado_id`, dons de guerrier OU de cette catégorie (Guerrier psychique : + dons psioniques) |

> `cap_categorie_var_id` **supprimée le 2026-08-28** (`sql/2026-08-28_capacites_drop_categorie.sql`).
> Reliquat de la v1 : elle distinguait capacité de race (91) de capacité de classe (92), information
> désormais portée par les tables de liaison `dd_race_capacite` et `dd_classe_capacite` — une même
> capacité pouvant relever des deux. Les valeurs 91/92 ne désignaient plus rien depuis la refonte de
> `dd_variables`. Catégorie `tcap` : n'existe plus.

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
| do_public | tinyint(1) | nn, défaut 0 | Supplément : 0 = privé, 1 = partagé |
| do_visible | tinyint(1) | nn, défaut 1 | Supplément : 0 = brouillon masqué, 1 = visible |
| do_ruleset_var_id | int unsigned | nn | -> dd_variables |
| do_page_source | int(11) | nn | ⚠️ Colonne présente en base, non documentée avant l'audit du 2026-07-01, usage à clarifier — sans rapport avec le mécanisme Supplément |
| do_guerrier | tinyint(1) | nn, défaut 0 | *[DD3.5, SP-DO]* Don de guerrier : peut être choisi par le guerrier en tant que don supplémentaire. Filtre le choix de don des capacités `cap_choix_guerrier = 1` |
| do_prereq_bba | tinyint unsigned | null | *[DD3.5, SP-DO]* Donnée technique : bonus de base à l'attaque minimal. NULL = aucun prérequis connu. **Non affichée par défaut** dans la fiche du don |
| do_prereq_for / do_prereq_dex / do_prereq_con / do_prereq_int / do_prereq_sag / do_prereq_cha | tinyint unsigned | null | *[DD3.5, SP-DO]* Donnée technique : valeur minimale de la caractéristique (Force, Dextérité, Constitution, Intelligence, Sagesse, Charisme). Même règle que `do_prereq_bba` |
| do_niv_lanceur | tinyint unsigned | null | *[DD3.5, SP-DO]* Donnée technique : niveau de lanceur de sorts minimal. Même règle |

> `do_public`/`do_visible` confirmées en base le 2026-07-01 (audit `SHOW CREATE TABLE`, cf. versioning v1.5).

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
| comp_public | tinyint(1) | nn, défaut 0 | Supplément : 0 = privé, 1 = partagé |
| comp_visible | tinyint(1) | nn, défaut 1 | Supplément : 0 = brouillon masqué, 1 = visible |
| comp_ruleset_var_id | int unsigned | nn | -> dd_variables |

> `comp_public`/`comp_visible` confirmées en base le 2026-07-01 (audit `SHOW CREATE TABLE`, cf. versioning v1.5).

---

### dd_competences_synergies
Synergies entre compétences, DD3.5 (SP-PE21, D-PE21a → c). Une compétence source ayant au moins `syn_seuil` rangs donne `syn_bonus` aux tests de la cible.
| Champ | Type | Null | Commentaire |
|---|---|---|---|
| syn_id | int unsigned | PK | |
| syn_comp_source_id | int unsigned | nn, index | -> dd_competences (compétence dont les rangs donnent le bonus) |
| syn_comp_cible_id | int unsigned | nn, index | -> dd_competences (compétence qui reçoit le bonus) |
| syn_seuil | tinyint unsigned | nn, défaut 5 | Rangs minimum dans la source |
| syn_bonus | tinyint | nn, défaut 2 | Bonus accordé |
| syn_condition | varchar(200) | NULL | NULL = toujours (compté dans le total) ; sinon cas d'application (affiché, hors total) |

> Chargée par `sql/2026-11-01_sp-pe21_synergies_competences.sql` (28 lignes), maintenue depuis le formulaire de compétence ; lignes supprimées avec la compétence source ou cible.

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
| ra_public | tinyint(1) | nn, défaut 0 | Supplément : 0 = privé, 1 = partagé |
| ra_visible | tinyint(1) | nn, défaut 1 | Supplément : 0 = brouillon masqué, 1 = visible |
| ra_ruleset_var_id | int unsigned | nn | -> dd_variables |

> `ra_public`/`ra_visible` confirmées en base le 2026-07-01 (audit `SHOW CREATE TABLE`, cf. versioning v1.5). Table héritée v1 : MyISAM/utf8 (cf. écart déjà documenté ailleurs dans ce fichier pour `dd_domaines`/`dd_sortdomaine`), `ra_res_id` nullable en base réelle (documenté `nn` ici par cohérence applicative — l'appli exige toujours une valeur).

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
| hi_public | tinyint(1) | nn, défaut 0 | Supplément : 0 = privé, 1 = partagé |
| hi_visible | tinyint(1) | nn, défaut 1 | Supplément : 0 = brouillon masqué, 1 = visible |
| hi_ruleset_var_id | int unsigned | nn | -> dd_variables |

> `hi_public`/`hi_visible` confirmées en base le 2026-07-01 (audit `SHOW CREATE TABLE`, cf. versioning v1.5).

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
| com_slug | varchar(100) | null, UK(com_slug, com_ruleset_var_id) | Clé du paramètre `famille=` du tag `[[liste:objet|…]]` (SP-PO1) — rempli par le nom à la migration |
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
| om_ajustement_prix | int | nn, defaut 0 | *[DD3.5]*, ajustement de prix de l'objet — lu par aucun code ; remis à 0 sur les propriétés spéciales (SP-PO6) |
| om_bonus_equiv | tinyint unsigned | null | *[DD3.5, SP-PO6]* Propriété spéciale : équivalence en bonus (+1 à +5), ajoutée au bonus d'altération pour le prix ; NULL = prix fixe dans `om_prix` (po) |
| om_nls | tinyint unsigned | null | *[DD3.5, SP-PO6]* Propriété spéciale : NLS |
| om_restriction | varchar(60) | null | *[DD3.5, SP-PO6]* Propriété spéciale : jetons séparés par des espaces — emploi `cac` / `distance` / `jet` / `armure` / `bouclier` / `ecu` (l'objet de base doit satisfaire l'un d'eux), dégâts `tranchant` / `perforant` / `contondant` (au moins un). NULL = aucune restriction. Liste : `proprieteRestrictionsJetons()` (`include/helpers.php`) |
| om_description | text | null | Description HTML TinyMCE (format libre) |
| om_harmonisation | tinyint(4) | nn, défaut 0 | *[DD2024]*, 1 : harmonisation requise |
| om_rarete | int(10) | null | *[DD2024]*, -> dd_objets_magiques_rarete |
| om_visible | tinyint(1) | nn, défaut 1 | 0 = masqué aux joueurs non-éditeurs (sémantique propre, conservée) |
| om_public | tinyint(1) | nn, défaut 0 | Supplément : 0 = privé, 1 = partagé |
| om_res_id | int unsigned | nn | Source -> dd_ressources |
| om_camp_id | int unsigned | null | null = global ; sinon homebrew -> dd_campagnes |
| om_ruleset_var_id | int unsigned | nn | -> dd_variables |

> `om_public` confirmée en base le 2026-07-01 (audit `SHOW CREATE TABLE`, cf. versioning v1.5) — `om_visible` existait déjà avant SP-C, réutilisée telle quelle comme `_visible`.

### dd_objets_magiques_rarete
Rareté des bjets magiques du compendium.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| omr_id | int unsigned | PK | |
| omr_nom | varchar(150) | nn | |
| om_ruleset_var_id | int unsigned | nn | -> dd_variables |


### dd_categorie_equipement
Familles d'équipement, arbre par ruleset (famille > sous-famille > …). **Une seule définition de colonnes
pilote la liste (tag `[[liste:equipement|…]]`, fiche détail) ET le formulaire d'édition.**

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| cae_id | int unsigned | PK | |
| cae_cae_id | int unsigned | null | Parent récursif ; NULL = famille racine |
| cae_nom | varchar(100) | nn | |
| cae_slug | varchar(100) | nn, UK(cae_slug, cae_ruleset_var_id) | Clé du paramètre `famille=` du tag |
| cae_colonnes | text | null | JSON `[{k, l, a?, liste?}]` — `k` = `prix`, `poids` ou une clé d'attribut ; `l` = libellé ; `a` = alignement `l/c/r` ; `liste:false` = fiche seulement. NULL = hérite du plus proche ancêtre qui en a une |
| cae_ordre | smallint unsigned | nn, défaut 0 | Ordre parmi les frères |
| cae_ruleset_var_id | int unsigned | nn | -> dd_variables |

> Jeu DD2024 (28 familles, SP-PO5) : `armes` (courantes / de guerre × corps à corps / distance), `armures` (légères, intermédiaires, lourdes, bouclier), `outils` (d'artisan, autres), `materiel-d-aventurier` (munitions, focaliseurs arcaniques et druidiques, symboles sacrés), `montures-et-vehicules` (animaux, harnachement, véhicules aériens et bateaux), `repas-boisson-et-hebergement`, `services` (employés, services d'incantation).
> Jeu DD3.5 (32 familles) : `armes` (courantes / de guerre / exotiques, chacune en légères / une main / deux mains /
> distance), `armures-et-boucliers` (légères, intermédiaires, lourdes, boucliers, suppléments),
> `marchandises-et-services` (8 sous-familles). Les familles DD2024 sont à saisir avec l'import des équipements DD2024.
> Aucun écran d'administration : comme `dd_categorie_objet_magique`, les familles se créent par migration SQL.

### dd_equipements
Équipement mondain du compendium (armes, armures, matériel non magique) — distincte de
`dd_objets_magiques` (objets magiques).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| eqt_id | int unsigned | PK | |
| eqt_nom | varchar(150) | nn | |
| eqt_cae_id | int unsigned | null | Famille -> dd_categorie_equipement |
| eqt_prix_pc | int unsigned | null | Prix en pièces de cuivre (1 po = 100 pc) ; NULL = sans prix chiffré |
| eqt_prix_txt | varchar(60) | null | Prix affiché quand il n'est pas un nombre (« spécial », « +50 po », « Niveau × 5 po ») ; prime sur `eqt_prix_pc` à l'affichage |
| eqt_poids_g | int unsigned | null | Poids en grammes ; NULL = négligeable ou sans objet |
| eqt_poids_txt | varchar(60) | null | Poids affiché quand il n'est pas un nombre ; prime sur `eqt_poids_g` |
| eqt_attributs | text | null | JSON `{clé : valeur}` — les clés sont celles de `cae_colonnes` (dégâts, critique, bonus d'armure…) |
| eqt_ordre | smallint unsigned | nn, défaut 0 | Ordre dans la famille (celui du livre) ; à égalité, nom |
| eqt_description | text | null | Description HTML TinyMCE (règles propres à l'article ; format libre) |
| eqt_visible | tinyint(1) | nn, défaut 1 | 0 = masqué aux joueurs non-éditeurs (sémantique propre, conservée) |
| eqt_public | tinyint(1) | nn, défaut 0 | Supplément : 0 = privé, 1 = partagé |
| eqt_res_id | int unsigned | nn | Source -> dd_ressources (officielle ou supplément de l'utilisateur) |
| eqt_camp_id | int unsigned | null | null = global ; sinon homebrew -> dd_campagnes |
| eqt_ruleset_var_id | int unsigned | nn | -> dd_variables |

> Table créée le 2026-06-20 (`sql/2026-06-20_equipements_sp-e0.sql`) ; **étendue le 2026-10-11** (SP-PO0,
> `sql/2026-10-11_equipements_00_schema_sp-po0.sql`) — elle était vide, la structure a donc pu changer sans
> migration de données. Elle rejoint le mécanisme Supplément (`eqt_public` + ressource supplément du propriétaire,
> même modèle que `om_public`) : cela **solde SP-E5**. Import DRS 07 : 269 articles, source « DRS 3.5 »
> (`sql/2026-10-11_equipements_dd35_drs07_sp-po2.sql`).

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

### dd_tableaux

Tableaux de données insérés par le tag `[[tab:slug]]` (SP-TB). Détail du module :
`doc/ARCHITECTURE_0_REFERENCE.md` §9c.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| tab_id | int unsigned | PK | |
| tab_slug | varchar(120) | nn, UK(tab_slug, tab_ruleset_var_id) | Clé du tag |
| tab_nom | varchar(200) | nn | Titre affiché |
| tab_contenu | text | nn | Convention texte (`!` en-tête, `#` section, `>` note, `\|` séparateur) |
| tab_align | varchar(40) | null | Une lettre par colonne (`l` / `c` / `r`) |
| tab_note | varchar(500) | null | Note de bas de tableau |
| tab_tabc_id | int unsigned | null | -> dd_tableaux_categories (`fk_tab_categorie`, ON DELETE SET NULL), NULL = sans catégorie — SP-TB12 |
| tab_ruleset_var_id | int unsigned | nn | -> dd_variables |
| tab_res_id | int unsigned | null | -> dd_ressources |
| tab_camp_id | int unsigned | null | Réservé house rules -> dd_campagnes |
| tab_ecran_mj | tinyint(1) | nn, défaut 0 | Proposé pour l'écran du MJ : préremplit un écran vide (SP-TB8) |
| tab_ecran_ordre | smallint unsigned | nn, défaut 0 | Ordre de ce préremplissage |
| tab_visible | tinyint(1) | nn, défaut 1 | 0 = brouillon |
| tab_date_creation / tab_date_modif | datetime | nn | |

### dd_tableaux_categories

Catégories des tableaux, **communes aux deux rulesets** (pas de `_ruleset_var_id`) — SP-TB12.
Ids figés : 1 Classe, 2 Race, 3 Don, 4 Sort, 5 Monstre, 6 Objet magique, 7 Règle, 8 Équipement,
9 Compétence (SP-TB13, ordre 35).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| tabc_id | int unsigned | PK | |
| tabc_slug | varchar(40) | nn, UK | Clé stable entre environnements |
| tabc_nom | varchar(80) | nn | Libellé |
| tabc_ordre | smallint unsigned | nn, défaut 0 | Ordre des listes déroulantes |


---

## 6. Personnages

### dd_personnages

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| pe_id | int unsigned | PK | |
| pe_nom | varchar(100) | nn | |
| pe_sexe | varchar(20) | null | Libellé libre, descriptif (féminin, masculin, etc.) — *patch 2026-06-12* |
| pe_j_id | int unsigned | nn | Propriétaire -> dd_joueurs (le joueur, après affectation par un MJ) |
| pe_affecte_par_j_id | int unsigned | null, index | MJ qui a affecté le personnage à son propriétaire actuel -> dd_joueurs ; NULL = jamais affecté. Seul ce MJ (ou l’admin) peut retirer l’affectation, qui rend `pe_j_id` au MJ — *SP-PE18, `sql/2026-11-01_sp-pe18_affectation_personnage.sql`* |
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
| pesp_origine | tinyint unsigned | nn, défaut 0 | *[DD2024]* Origine du sort préparé (SP-MA4a) : **0** = préparé normalement, **compte** dans `cn_sortPrepare` ; **1** = toujours préparé au choix du joueur (Secrets magiques du Barde niv. 10, Sorts de prédilection du Magicien niv. 20) ; **2** = arcanum mystique (Occultiste 11/13/15/17). Les sorts accordés par une classe ou sous-classe ne sont **pas** stockés ici — ils se déduisent de `dd_classe_sort` |

---

### dd_personnages_competences
Liste des compétences que possède le personnage
| Champ | Type | Null | Commentaire |
|---|---|---|---|
| pec_id | int unsigned | PK | |
| pec_pe_id | int unsigned | nn, UK(pec_pe_id, pec_comp_id) | -> dd_personnages |
| pec_comp_id | int unsigned | nn | -> dd_competences |
| pec_maitrise | tinyint | nn, défaut 0 | *[DD3.5]* Nombre de rangs ; *[DD2024]* 0=aucune, 1=maîtrise, 2=expertise |
| pec_mod_divers | smallint | nn, défaut 0 | Modificateur divers saisi par le joueur (dons, capacités, objets) — SP-PE20 |
| pec_mod_libelle | varchar(200) | NULL | Origine du modificateur divers, texte libre — SP-PE20 |

> Une ligne existe si `pec_maitrise > 0` ou `pec_mod_divers <> 0` (SP-PE20).

---

### dd_personnages_dons
Liste des dons que possède le personnage
| Champ | Type | Null | Commentaire |
|---|---|---|---|
| ped_id | int unsigned | PK | |
| ped_pe_id | int unsigned | nn | -> dd_personnages |
| ped_do_id | int unsigned | nn | -> dd_dons |
| ped_niveau | tinyint unsigned | null | Niveau du personnage auquel le don a été pris |
| ped_pech_id | int unsigned | null | *[SP-CH]* -> dd_personnages_choix : don posé par un emplacement de choix de capacité (NULL = saisi à la main). Le retrait passe par l'emplacement |

---

### dd_personnages_choix
*[SP-CH]* Choix du joueur pour une capacité de classe qui en impose (Grand arcane, Don supplémentaire…). Une ligne par emplacement rempli. Indexée par **clé naturelle** et non par `cc_id`, que l'enregistrement d'une classe dans le compendium régénère.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| pech_id | int unsigned | PK | |
| pech_pe_id | int unsigned | nn, UK(pech_pe_id, pech_cla_id, pech_cap_id, pech_niveau, pech_rang) | -> dd_personnages |
| pech_cla_id | int unsigned | nn | -> dd_classes (classe ou sous-classe qui accorde le choix) |
| pech_cap_id | int unsigned | nn | -> dd_capacites_speciales |
| pech_niveau | tinyint unsigned | nn | Niveau de classe qui accorde le choix |
| pech_rang | tinyint unsigned | nn, défaut 1 | Rang parmi les `cc_nb_choix` choix de ce niveau |
| pech_do_id | int unsigned | null | -> dd_dons (capacité en mode `don`) |
| pech_texte | varchar(255) | null | Choix saisi (capacité en mode `texte`) |
| pech_precision | varchar(100) | null | *[SP-CH8]* Précision du don choisi (arme d'une Spécialisation martiale, école, compétence…), texte libre, mode `don` seulement. Affichée entre parenthèses à côté du don, dans le bloc Capacités et dans le bloc Dons |

---

### dd_personnages_possessions
*[SP-PO6]* Inventaire d'un personnage : une ligne par objet (D-PO15 → D-PO20). FK logiques. Purge dans `supprimerPersonnage`.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| pp_id | int unsigned | PK | |
| pp_pe_id | int unsigned | nn | -> dd_personnages |
| pp_type | enum('equipement','objet','compose') | nn | `equipement` → `pp_eqt_id` ; `objet` (objet magique simple) → `pp_om_id` ; `compose` : objet magique complexe DD3.5 composé pour ce personnage |
| pp_eqt_id | int unsigned | null | -> dd_equipements : l'équipement, ou l'objet de base d'un composé (arme, armure, bouclier) |
| pp_om_id | int unsigned | null | -> dd_objets_magiques (objet simple) |
| pp_nom | varchar(200) | null | Nom libre ; composé : nom généré, modifiable |
| pp_quantite | smallint unsigned | nn, défaut 1 | |
| pp_equipe | tinyint(1) | nn, défaut 0 | 1 = porté / en main |
| pp_harmonise | tinyint(1) | nn, défaut 0 | *[DD2024]* objet harmonisé (SP-PO12) |
| pp_charges | smallint unsigned | null | Charges restantes (baguette) |
| pp_notes | text | null | |
| pp_compose_cat | enum('arme','armure','bouclier','potion','huile','baguette','parchemin') | null | Composé seulement |
| pp_maitre | tinyint(1) | nn, défaut 0 | Composé : qualité de maître |
| pp_bonus | tinyint unsigned | null | Composé : bonus d'altération |
| pp_bonus_tete2 | tinyint unsigned | null | Composé : bonus de la seconde tête d'une arme double |
| pp_nls | tinyint unsigned | null | Composé : NLS calculé |
| pp_prix_pc / pp_cout_pc | int unsigned | null | Composé : prix de vente / coût de création, en pc — **photo** du calcul serveur (`include/objet-compose.php`, SP-PO7) |
| pp_cout_px | int unsigned | null | Composé : coût de création en PX (photo) |
| pp_ordre | smallint unsigned | nn, défaut 0 | |
| pp_date_creation / pp_date_maj | datetime | nn / null | |

### dd_personnages_possessions_elements
*[SP-PO6]* Éléments d'un objet composé : propriétés spéciales (armes, armures, boucliers) ou sorts (potion, baguette, parchemin).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| ppe_id | int unsigned | PK | |
| ppe_pp_id | int unsigned | nn | -> dd_personnages_possessions (`pp_type` = `compose`) |
| ppe_type | enum('propriete','sort') | nn | |
| ppe_tete | tinyint unsigned | nn, défaut 1 | Arme double : tête 1 ou 2 |
| ppe_om_id | int unsigned | null | -> dd_objets_magiques (propriété spéciale) |
| ppe_so_id | int unsigned | null | -> dd_sorts |
| ppe_cla_id | int unsigned | null | -> dd_classes : liste de classe qui fixe le niveau du sort |
| ppe_niveau / ppe_nls | tinyint unsigned | null | Niveau du sort dans cette liste (photo) / NLS du sort |
| ppe_parametre | varchar(150) | null | Paramètre libre (Tueuse : créature ; Stockage de sort : sort ; Aura élémentaire : énergie) |
| ppe_suppl_pc / ppe_suppl_px | int unsigned | nn, défaut 0 | Composantes coûteuses (pc) et coût en PX du sort, saisis à la main |
| ppe_utilise | tinyint(1) | nn, défaut 0 | Parchemin : sort déjà lu |
| ppe_ordre | smallint unsigned | nn, défaut 0 | |

---

### dd_personnages_notes
*[SP-NO0]* Destinataires d’une note : une ligne par personnage à qui le MJ l’a diffusée.
*[SP-NO11]* Pour une note diffusée à toute la campagne (`no_diffusion_campagne` = 1), la ligne n’ouvre aucun accès :
elle ne fait que suivre la lecture, et n’est créée qu’à la première ouverture.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| pno_id | int unsigned | PK | |
| pno_no_id | int unsigned | nn, UK(pno_no_id, pno_pe_id) | -> dd_notes |
| pno_pe_id | int unsigned | nn, KEY | -> dd_personnages |
| pno_date | datetime | nn | Date de diffusion au personnage |
| pno_lu_date | datetime | null | Première lecture par le joueur ; NULL = non lue (pastille « nouveau ») |

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
| camp_ecran_colonnes | tinyint unsigned | nn, défaut 3 | Écran du MJ : nombre de colonnes, 2 à 6 (SP-TB8) |
| camp_date_creation | datetime | nn | Horodatage automatique |

> **Ruleset hérité** : le ruleset n'est stocké QUE sur la campagne (`camp_ruleset_var_id`).
> Scénarios / chapitres / rencontres / oppositions le lisent par jointure remontante. Aucune
> colonne `_ruleset_var_id` redondante sur les entités filles.
> **Univers 1-1** : la liaison N-N `dd_campagnes_univers` de l'ébauche précédente est **abandonnée**
> au profit de `camp_un_id`.

---

### dd_campagnes_ecran
Écran du MJ (SP-TB8) : tableaux posés sur l'écran d'une campagne. UK (`ce_camp_id`, `ce_tab_id`).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| ce_id | int unsigned | PK | |
| ce_camp_id | int unsigned | nn | -> dd_campagnes (FK, `ON DELETE CASCADE`) |
| ce_tab_id | int unsigned | nn | -> dd_tableaux (FK, `ON DELETE CASCADE`) |
| ce_colonne | tinyint unsigned | nn, défaut 0 | Colonne de départ, 0 = gauche |
| ce_ordre | smallint unsigned | nn, défaut 0 | Ordre **global** de placement (ARCHITECTURE §9c) |
| ce_largeur | tinyint unsigned | nn, défaut 1 | 1 ou 2 colonnes |
| ce_replie | tinyint(1) | nn, défaut 0 | 1 = réduit à son titre |

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
| sce_ordre | smallint unsigned | nn, défaut 0 | Ordre d'affichage dans la campagne. Glisser-déposer uniquement, plus saisi au formulaire depuis SP-CP |
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
| scc_ordre | smallint unsigned | nn, défaut 0 | Glisser-déposer uniquement, plus saisi au formulaire depuis SP-CP |
| scc_abreviation | varchar(10) | null | Affichée **en préfixe du nom** (`ABR : Nom`) depuis SP-CP |
| scc_description | text | null | |

---

### dd_rencontres
Une rencontre appartient **obligatoirement** à un chapitre (plus de rencontre orpheline).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| re_id | int unsigned | PK | |
| re_nom | varchar(150) | nn | |
| re_code | varchar(20) | null | Code de référence libre. Affiché **en préfixe du nom** (`CODE : Nom`) depuis SP-CP — plus de colonne dédiée dans les listes |
| re_ordre | smallint unsigned | nn, défaut 0 | Ordre d'affichage dans le chapitre. Glisser-déposer uniquement, jamais saisi (SP-CP0) |
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
Copie **éditable** d'un monstre du compendium, propre à une rencontre — **ou opposition saisie
entièrement à la main**, sans monstre d'origine. Le MJ recopie un monstre puis ajuste/annote
librement pour sa partie, **sans altérer le compendium** ; ou bien saisit directement nom + stats.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| opp_id | int unsigned | PK | |
| opp_nom | varchar(150) | nn | Recopié de `mo_nom` si monstre choisi, sinon saisi librement. Éditable |
| opp_mocat_nom | varchar(150) | null | Recopié du libellé de catégorie (`mocat_nom` via `mo_mocat_id`) si monstre choisi, sinon texte libre. Éditable |
| opp_stats | text | null | Recopié de `mo_stats` si monstre choisi, sinon saisi librement. Éditable |
| opp_nombre | tinyint unsigned | nn, défaut 1 | Effectif : nombre de créatures identiques (SP-CP11). Saisi dans le formulaire d'opposition |
| opp_pv_max | smallint unsigned | null | PV max d'une créature (SP-CP11). `NULL` = lus dans `opp_stats` à l'affichage (`pvMaxDepuisStats()`) |
| opp_ordre | smallint unsigned | nn, défaut 0 | Ordre d'affichage dans la rencontre. Glisser-déposer uniquement (SP-CP0). Une opposition transférée ou dupliquée se pose en fin de la rencontre d'arrivée |
| opp_re_id | int unsigned | nn | Rencontre parente -> dd_rencontres |
| opp_mo_id | int unsigned | **null** | Monstre-template d'origine -> dd_monstres. **Non éditable** par le MJ une fois fixé (traçabilité). **`NULL` = opposition saisie manuellement**, sans monstre d'origine au compendium. |

> Lien rencontre **1-N** (`opp_re_id`), pas de table de liaison.
> À la création, le formulaire propose un sélecteur de monstre **optionnel** (scopé ruleset courant
> + sources actives) qui, s'il est utilisé, pré-remplit `opp_nom`, `opp_mocat_nom`, `opp_stats` et
> fige `opp_mo_id`. Si aucun monstre n'est choisi, le MJ saisit `opp_nom`/`opp_mocat_nom`/`opp_stats`
> directement et `opp_mo_id` reste `NULL` (définitivement — pas de monstre d'origine ajoutable après
> coup, cohérent avec le caractère figé du champ).
> Duplicable (« *[nom] - copie* »).
> `opp_mo_id` normalisé en `int unsigned` (la spec initiale notait `int(10)`).
> `opp_mo_id` rendu **nullable** le 2026-06-20 (`sql/2026-06-20_oppositions_monstre_optionnel.sql`,
> committé + testé sur MariaDB réelle) — était `NOT NULL` à l'origine, bloquant toute saisie
> manuelle.

### dd_oppositions_pv
PV courants des créatures **entamées** d'une opposition (SP-CP11). Une ligne absente = la créature est à `opp_pv_max`.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| opv_opp_id | int unsigned | PK | -> dd_oppositions (`ON DELETE CASCADE`) |
| opv_rang | tinyint unsigned | PK | N° de la créature dans l'opposition (1..`opp_nombre`) |
| opv_pv | smallint | nn | PV courants, négatifs admis |

> Réinitialiser une rencontre = supprimer ses lignes. Réduire `opp_nombre` supprime les rangs en trop.
> La duplication d'une opposition ne recopie pas cette table.

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

*[SP-NO0]* Notes rédigées par le MJ et diffusées aux personnages d'une campagne. Une note = un tronc commun
(`no_texte`), toujours lisible par ses destinataires, et des sections (`dd_notes_contenus`) dont l'accès
peut dépendre de compétences (`dd_notes_conditions`). Règles fonctionnelles : `METIER_11_Notes.md`.

### dd_types_notes
Catégories de notes, propres à chaque ruleset.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| tyno_id | int unsigned | PK | |
| tyno_nom | varchar(80) | nn, UK(tyno_ruleset_var_id, tyno_nom) | |
| tyno_ruleset_var_id | int unsigned | nn | -> dd_variables (ruleset) |
| tyno_ordre | smallint unsigned | nn, défaut 0 | Ordre d'affichage |

> Amorçage (SP-NO0), identique pour les deux rulesets : Histoire, Géographie et lieux, Personnages,
> Organisations et factions, Religions et divinités, Magie et arcanes, Créatures, Objets et artefacts,
> Culture et société, Indices et documents, Divers.

---

### dd_notes

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| no_id | int unsigned | PK | |
| no_nom | varchar(200) | nn | Titre de la note |
| no_camp_id | int unsigned | nn, KEY(no_camp_id, no_supprime, no_date) | -> dd_campagnes. Le ruleset de la note est celui de la campagne (pas de colonne propre) |
| no_sce_id | int unsigned | null, KEY | -> dd_scenarios ; NULL = note valable pour toute la campagne |
| no_tyno_id | int unsigned | nn, KEY | Catégorie -> dd_types_notes (du ruleset de la campagne) |
| no_diffusion_campagne | tinyint(1) | nn, défaut 0 | 1 = lue par tout personnage rattaché à la campagne (inactifs compris, y compris ceux ajoutés plus tard) ; 0 = destinataires de `dd_personnages_notes` — SP-NO11 |
| no_texte | longtext | null | Tronc commun (TinyMCE, images autorisées), toujours lisible par les destinataires |
| no_j_id | int unsigned | nn | Rédacteur -> dd_joueurs |
| no_date | datetime | nn | Date de la note, critère de tri, modifiable par le MJ |
| no_date_maj | datetime | null | Dernière modification |
| no_supprime | tinyint(1) | nn, défaut 0 | Suppression douce (posée aussi par la suppression de la campagne) |
| no_date_supprime | datetime | null | |

---

### dd_notes_contenus
Sections d'une note.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| noc_id | int unsigned | PK | |
| noc_no_id | int unsigned | nn, KEY(noc_no_id, noc_ordre) | -> dd_notes |
| noc_ordre | smallint unsigned | nn, défaut 0 | Ordre dans la note |
| noc_titre | varchar(200) | null | Intertitre facultatif |
| noc_texte | longtext | null | Contenu (TinyMCE, images autorisées) |

---

### dd_notes_conditions
Conditions d'accès à une section. Aucune ligne = section lisible par tous les destinataires ; plusieurs lignes
= **OU** (une seule condition satisfaite suffit). Une condition est satisfaite si `bonus total de
compétence ≥ nocd_dd` (score, sans « prendre 10 » depuis D-NO23) ; en DD3.5, une compétence à formation requise sans rang ne la satisfait jamais.

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| nocd_id | int unsigned | PK | |
| nocd_noc_id | int unsigned | nn, UK(nocd_noc_id, nocd_comp_id) | -> dd_notes_contenus |
| nocd_comp_id | int unsigned | nn, KEY | -> dd_competences |
| nocd_dd | tinyint unsigned | nn | Score de compétence (bonus total) à atteindre |

---

> `dd_personnages_notes` (destinataires) est décrite avec les tables du personnage. `dd_campagnes_notes`
> a été **supprimée** par SP-NO0 : la note porte sa campagne.

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

### dd_v1_notes, dd_v1_notes_contenus, dd_v1_notes_tags — transit (SP-NO7)

Copie de l'export des notes de la v1, chargée par `sql/2026-11-01_sp-no7_notes_v1_transit.sql`, lue par
`admin/import-notes-v1.php`. Colonnes de la v1 conservées telles quelles (`no_*`, `noc_*`, `notag_*`, d'où le
recouvrement de préfixe avec `dd_notes`), en utf8mb4. Ajout : `dd_v1_notes.no_importe_no_id` (int unsigned, null) →
`dd_notes` créée par l'import (NULL = pas encore importée). **Temporaires** : à supprimer après l'import en production
(SP-NO8).

---

## 10. Technique

### dd_migrations
Migrations SQL appliquées à la base de l'environnement (local ou production) — SP-DP5. Une migration est un fichier `sql/AAAA-MM-JJ_*.sql` ; un fichier sans ligne est « en attente ». Table créée par le moteur, sans fichier SQL (voir `ARCHITECTURE_0_REFERENCE.md` §6b).

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| mig_id | int unsigned | PK | |
| mig_fichier | varchar(190) | nn, UK | Nom du fichier dans `sql/` |
| mig_checksum | char(64) | nn | SHA-256 du fichier au moment de son application — un écart signale une migration retouchée, jamais rejouée |
| mig_statut | varchar(12) | nn | `executee` (jouée par le moteur) \| `reference` (antérieure au moteur, inscrite sans exécution) \| `marquee` (jouée à la main, déclarée depuis `admin/migrations.php`) |
| mig_date | datetime | nn | Date d'application ou d'inscription |
| mig_duree_ms | int unsigned | null | Durée d'exécution (statut `executee`) |



------------------------------------------------------------------------------------------------------
#LEGENDE
PK — Primary Key. C'est la clé primaire de la table : le champ qui identifie chaque enregistrement de façon unique. Dans toutes les tables du projet c'est toujours le premier champ, suffixe _id, auto-incrémenté.
nn — Not Null. Le champ est obligatoire — la base refuse l'insertion si la valeur est absente. À l'opposé, quand une colonne indique null, la valeur est optionnelle.
UK — Unique Key. Contrainte d'unicité : la combinaison des champs indiqués entre parenthèses ne peut pas apparaître deux fois dans la table. Par exemple UK(cp_camp_id, cp_pe_id) sur dd_campagnes_personnages garantit qu'un même personnage ne peut pas être rattaché deux fois à la même campagne.