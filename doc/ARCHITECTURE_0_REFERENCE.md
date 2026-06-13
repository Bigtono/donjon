<!-- Mis à jour : 2026-06-12 16:00 -->

# Codex DD v2 — Document de référence architecture

> Source de vérité pour tous les développements.
> À ouvrir dans VS Code à chaque session pour contextualiser Claude Code.
> Dernière mise à jour : Phase 3 — sous-phase 3.1 livrée (fiche identité responsive : nom, race+archétype DD3.5, historique DD2024, sexe, alignement, caracs+modificateurs, combat ; overlay modifier complet ; première classe obligatoire à la création ; patch SQL `pe_hi_id`)

---

## 1. Philosophie technique

- PHP classique sans framework (pages contrôleurs + includes)
- JS vanilla, CSS maison
- PDO exclusivement — prepare/execute sur toutes les requêtes
- htmlspecialchars systématique via h() sur toute sortie HTML
- Token CSRF sur tous les formulaires POST et endpoints AJAX sensibles
- Balises PHP : <?php pour les blocs logiques, <?= pour l'affichage inline
- Syntaxe alternative PHP sans accolades sauf pour function() et class
- Indentation : 2 espaces
- CSS par module : `$css_module` charge conditionnellement `[module]-modules.css` (même pattern que `$js_module`)

### URL de base — règle absolue

define('BASE_URL', '/donjon') dans include/db.php.

Toutes les URLs du projet passent par BASE_URL — aucune URL absolue codée en dur.

| Contexte | Syntaxe |
|---|---|
| Lien HTML | href="<?= BASE_URL ?>/chemin/page.php" |
| Attribut action | action="<?= BASE_URL ?>/chemin/page.php" |
| Redirection PHP | header('Location: ' . BASE_URL . '/chemin'); |
| Asset CSS/JS | href="<?= BASE_URL ?>/css/main.css" |

---

## 2. Contexte technique

| Élément | Choix |
|---|---|
| Langage serveur | PHP classique sans framework |
| Base de données | MySQL — PDO exclusivement |
| Front-end | JS vanilla, CSS maison |
| Hébergement prod | OVH — http://maikastel.fr/donjon/ |
| Développement local | XAMPP — http://localhost/donjon/ |
| Versioning | GitHub — repo Bigtono/donjon |
| Éditeur | VS Code + plugin Claude Code |

### Conventions base de données

- Tables préfixées dd_ (en local)
- Au déploiement OVH : renommage en dd2_ via script RENAME TABLE
- Champs préfixés par table (ex : pe_ pour dd_personnages)
- Premier champ = id index de la table
- _j_id = propriétaire → dd_joueurs
- _camp_id = campagne → dd_campagnes
- _res_id = ressource/livre → dd_ressources
- _ruleset_var_id = version de règles → dd_variables

---

## 3. Versions de règles (rulesets)

| ID | Nom | Répertoire templates |
|---|---|---|
| 1 | DD3.5 | include/insert/DD3.5/ |
| 2 | DD2024 | include/insert/DD2024/ |

Sélection via $_SESSION['rulesetRep'] — whitelist stricte.
Les templates ruleset ne contiennent que du HTML, jamais de logique auth/session/redirection.

---

## 4. Modèle utilisateur et droits

### Rôles

| Rôle | Condition | Droits |
|---|---|---|
| Admin | j_admin = 1 | Tout le site, bypass filtres propriétaire |
| Gestionnaire compendium | j_compendium_manager = 1 | Édition compendium global sans être admin |
| Utilisateur standard | par défaut | Ses propres données uniquement |
| MJ | contextuel : camp_j_id = session j_id | Données de sa campagne + personnages invités |

Le rôle MJ est contextuel — tout utilisateur devient MJ dès qu'il crée une campagne ou un univers.

### Règle de filtrage propriétaire

Toute requête sur données utilisateur : WHERE [prefix]_j_id = :user_id, sauf si admin.
Encapsulé dans ownerFilter() dans include/helpers.php.

### Visibilité des données par module

| Module | Règle |
|---|---|
| Compendium officiel | Visible par tous les utilisateurs connectés |
| Personnages | Propriétaire + MJs des campagnes auxquelles le personnage est rattaché |
| Campagnes | Propriétaire uniquement |
| Notes MJ (cp_notes_mj) | MJ de la campagne uniquement |
| Univers privé | Propriétaire uniquement |
| Univers public | Sélectionnable par d'autres MJs |
| Articles wiki visibles | Tous les ayants droit de l'univers |
| Articles wiki cachés | Propriétaire de l'univers uniquement |

---

## 5. Compendium des règles

### Droits d'édition

1. Compendium global : admin + gestionnaires délégués (j_compendium_manager = 1). Visible par tous.
2. Contenu homebrew : créé par le MJ via _camp_id. Mêmes formulaires + champ caché _camp_id. Visible MJ + joueurs de la campagne.

> **Réserve d'architecture :** La combinaison `res_j_id NOT NULL AND res_camp_id IS NULL` est réservée
> pour un futur homebrew "profil" (recueil maison transversal, non campagne-spécifique).
> Elle ne doit pas être utilisée à d'autres fins. Voir DECISIONS_LOG — Homebrew campagne vs homebrew profil.

### Périmètre des entités du compendium

Les entités suivantes font partie du compendium et sont filtrées par ressource via leur champ `_res_id` :

| Table | Préfixe | Ruleset | Champ ressource |
|---|---|---|---|
| dd_classes | cla | DD3.5 + DD2024 | cla_res_id |
| dd_races | ra | DD3.5 + DD2024 | ra_res_id |
| dd_sorts | so | DD3.5 + DD2024 | so_res_id |
| dd_dons | do | DD3.5 + DD2024 | do_res_id |
| dd_competences | comp | DD3.5 + DD2024 | comp_res_id |
| dd_historiques | hi | **DD2024 uniquement** | hi_res_id |
| dd_objets_magiques | om | DD3.5 + DD2024 | om_res_id |

> ⚠️ `dd_historiques` est une entité exclusive au ruleset DD2024. Elle ne doit jamais apparaître dans les pages ou formulaires DD3.5.

Cette liste est la référence pour toute vérification de dépendances (ex : suppression d'une ressource).

### Sélection des sources — chaîne de priorité

```
1. Sélection de la campagne (dd_campagnes_sources)
   actif si : personnage en session (last_pe_id) + campagne avec sélection propre
2. Sélection personnelle (dd_joueurs_sources, par ruleset)
3. Toutes les sources actives du ruleset (défaut absolu)
```

### Architecture des pages du compendium — moteur de liste commun

Toutes les pages du compendium partagent la même structure et le même moteur.

Principe : chaque page déclare $listConfig puis délègue tout le rendu à include/compendium-liste.php.

Exemple de $listConfig (sorts.php) :

```php
$listConfig = [
  'entite'       => 'sort',
  'titre'        => 'Sorts',
  'from'         => 'dd_sorts so LEFT JOIN dd_colleges co ON co.co_id = so.so_co_id',
  'champ_id'     => 'so.so_id',
  'champ_res'    => 'so.so_res_id',
  'colonnes'     => [
    ['sql' => 'so.so_nom',    'champ' => 'so_nom',    'label' => 'Nom',   'mobile' => true,  'tri' => true],
    ['sql' => 'so.so_niveau', 'champ' => 'so_niveau', 'label' => 'Niv.', 'mobile' => false, 'tri' => true],
    ['sql' => 'co.co_nom',    'champ' => 'co_nom',    'label' => 'Ecole', 'mobile' => false, 'tri' => true],
  ],
  'filtres'      => $filtres_specifiques,
  'url_detail'   => BASE_URL . '/include/ajax/detail-pp/sort.php',
  'url_modifier' => BASE_URL . '/include/ajax/modifier/sort.php',
  'url_enreg'    => BASE_URL . '/compendium/enregistrement.php',
  'bulk_actions' => [
    ['valeur' => 'supprimer', 'label' => 'Supprimer la selection'],
  ],
];
require_once '../include/header.php';
require_once '../include/compendium-liste.php';
require_once '../include/footer.php';
```

Séquence d'exécution de compendium-liste.php :
1. Lit GET : colonne de tri, direction, valeurs des filtres, page courante
2. Valide la colonne de tri par whitelist (colonnes avec tri = true)
3. Appelle getActiveResIds() → base sources active
4. Intersecte avec filtre sources GET si présent
5. Construit WHERE : texte libre + filtres spécifiques + sources
6. Construit ORDER BY sécurisé
7. Exécute COUNT(*) → calcule pagination
8. Exécute SELECT avec LIMIT/OFFSET
9. Rend le HTML : zone filtre + tableau + pagination + barre bulk

### Structure de chaque page liste

Zone filtre :
  - INPUT texte libre (toujours premier)
  - Critères métier spécifiques à chaque page (certains conditionnels par ruleset)
  - SELECT sources multiple (toujours dernier — restreint dans la sélection active)

Tableau :
  - Checkbox | Menu ligne | col-primary | col-secondary...

Pagination

Barre bulk en bas : Action [SELECT] [Appliquer]

### Responsive des listes compendium

Classes CSS définies dans compendium-modules.css :

| Classe | Desktop | Mobile (<=991px) |
|---|---|---|
| .col-primary | Colonne normale | Toujours visible — ligne principale |
| .col-secondary | Colonne normale | Sous-ligne (font 0.8rem, style distinctif) |
| .col-action | Visible (modifier/supprimer) | Masqué |
| .bulk-check | Visible (checkbox) | Masqué |

### Confirmation de suppression

Div inline remplaçant temporairement la ligne dans le tableau. Pas de window.confirm().

### Fichiers du compendium

```
compendium/
  sorts.php, classes.php, dons.php, races.php, competences.php, objets.php
  historiques.php   (DD2024 uniquement — conditionné par ruleset en session)
  enregistrement.php  (POST commun + mode ?ajax=1)

include/
  compendium-liste.php   (moteur commun)
  ajax/detail-pp/        (sort.php, classe.php, don.php, race.php, competence.php, historique.php...)
  ajax/modifier/         (sort.php, classe.php, don.php, race.php, competence.php, historique.php...)
```

> ⚠️ La page `compendium/historiques.php` (et ses endpoints AJAX) ne doit être accessible
> et affichée dans le menu que si `$_SESSION['rulesetRep'] === 'DD2024'`.

### enregistrement.php — mode AJAX

Détecte $_GET['ajax'] et retourne JSON {ok, id, url_detail} pour les saves individuels.
Mode normal (bulk) : redirect + flash message SESSION.


### Module Monstres — bloc de stats à liaisons cliquables (v3)

Le module Monstres est un module de compendium **classique dans sa forme** (moteur de liste
commun `compendium-liste.php`, fiche `detail-pp`, formulaire `modifier`, dispatch dans
`enregistrement.php`), enrichi d'un **moteur de rendu propre** : `include/monstre-parser.php` (v3).

#### Principe directeur — texte brut au stockage, analyse à l'affichage

`mo_stats` est **stocké tel quel**, en texte brut. `enregistrerMonstre()` écrit la valeur POST
sans transformation (pas de `h()`, pas de passe d'analyse au save). Le **formatage** (mise en page)
et les **liens cliquables** sont recalculés **à chaque affichage** par `rendreStatsMonstre()`,
appelé depuis `include/ajax/detail-pp/monstre.php`.

```php
// include/monstre-parser.php — point d'entrée public
// Retourne ['html' => string, 'rapport' => array]  ($rapport = compteur de liens par type)
function rendreStatsMonstre(PDO $db, ?string $texte, int $ruleset_id, array $res_ids): array
```

→ Ré-édition fidèle à la source ; liens toujours à jour (une entité ajoutée plus tard devient
cliquable sans re-sauvegarde) ; aucune logique d'idempotence. La saisie se fait dans un
`<textarea>` brut — **pas de TinyMCE**, pas de `DOMDocument`.

#### Périmètre des données

Table principale `dd_monstres` (colonnes référencées par le code) :

| Champ | Rôle |
|---|---|
| `mo_nom` | Nom de la créature (obligatoire) |
| `mo_mocat_id` | Catégorie (obligatoire) → `dd_monstres_categories` |
| `mo_mogr_id` | Groupe → `dd_monstres_groupes` *(DD2024 uniquement ; `0` → stocké `NULL` en DD3.5)* |
| `mo_fp_id` | Facteur de puissance — **libellé varchar** (« 1/2 ») → référentiel `dd_fp` |
| `mo_stats` | Bloc de description en **texte brut** — analysé au rendu, jamais au save |
| `mo_j_id` | Propriétaire. **NULL = visible par tous ; sinon visible par ce seul joueur** |
| `mo_res_id` | Source (obligatoire) → `dd_ressources` |
| `mo_camp_id` | Homebrew de campagne (NULL = officiel) |
| `mo_ruleset_var_id` | Ruleset → `dd_variables` |

> ⚠️ **Écart SQL versionné / code.** `sql/schema.sql` et le dump `sql/maikasteiymaika.sql` ne
> reflètent pas encore `mo_mocat_id`, `mo_mogr_id`, `mo_res_id`, `mo_camp_id` ni les tables
> `dd_monstres_categories`, `dd_monstres_groupes`, `dd_fp`. La base réelle est à jour ; les
> fichiers SQL du dépôt sont à resynchroniser (voir DECISIONS_LOG — Monstres).

**Visibilité — règle propre au module.** Portée par `mo_j_id` (et non un booléen comme les objets
magiques) :

```sql
-- clause de liste (extra_where), $uid = (int) $_SESSION['j_id']
(mo.mo_j_id IS NULL OR mo.mo_j_id = $uid)
```

`ownerFilter()` ne convient pas (il renverrait `prefix_j_id = :owner` et masquerait les monstres
publics à NULL). Les éditeurs (`canEditCompendium()`) voient tout.

#### Liaison des entités — deux mécanismes complémentaires

**1. Tags explicites (prioritaires, résolus en pré-passe `resoudreTagsExplicites()`)** — le moyen
fiable de poser un lien, sous le contrôle de l'éditeur :

| Tag | Cible | Résolution |
|---|---|---|
| `#Nom du don#` | `dd_dons` | par **nom** (index, insensible casse/accents) |
| `$Nom du sort$` | `dd_sorts` | par **nom** |
| `@id@` | `dd_regles` (tout type) | par **id** |
| `%id%` | `dd_regles` `reg_type='glossaire'` | par **id** |

Un tag introuvable est rendu en **texte simple** (sans lien), jamais en erreur.

**2. Liaison automatique (`lierAuto()`) — limitée à sorts + glossaire.** Sur le texte libre
(descriptions de pouvoirs, valeurs de labels), une passe relie automatiquement les **sorts** et
les **termes de glossaire** via un index fusionné (`construireIndexAuto()`, priorité sort >
glossaire). Garde-fous : normalisation casse/accents (`normaliserNomMonstre()`), plus longue
correspondance d'abord, longueur minimale `MO_LONGUEUR_MIN = 4`. Le **nom d'un pouvoir n'est
jamais auto-parsé**. Les **dons ne sont pas auto-liés** (noms trop ambigus) : tag `#…#` uniquement
(ou ligne « Dons : » en DD3.5 via `lierDons()`).

#### Dictionnaire — registre `typesLiablesMonstre()`

Registre déclaratif décrivant les types chargés **par nom** : `don` et `sort` (table, id, nom,
colonnes ruleset/res/camp). Le **glossaire** est chargé séparément depuis `dd_regles`. Chargement
(`chargerIndexMonstre()`) scopé : **ruleset courant + sources actives (`getActiveResIds()`) +
`camp IS NULL`**. Aucune source active → dictionnaire vide pour les types scopés par ressource.

#### Rendu par ruleset

- **DD2024** (`formaterBlocDD2024()` + `classerLigneDD2024()`) : classification ligne par ligne —
  en-tête / ligne de **caractéristiques** (rendues en **grille 3×2** via `rendreTableauCarac()` :
  For/Dex/Con/Int/Sag/Cha avec colonnes MOD/JS), **titre de section** (Traits, Actions, Actions
  légendaires, Réactions, Repaire, Pouvoirs…), **label inline** (CA, Pv, Vitesse, Initiative),
  **label gras** (Résistances, Immunités, FP, Équipement…), **sous-liste de sorts** (« À volonté : »,
  « N/jour : » → liaison sorts seuls), **pouvoir** (« Nom. Description »), ligne simple.
- **DD3.5** (`formaterLigneDD35()`) : labels terminés par « : » (Classe d'armure, Dés de vie, Dons,
  Compétences…). Ligne « Dons : » → liaison dons ; autres → liaison auto (sorts + glossaire).
  Parsing automatique DD3.5 **minimal — à compléter ultérieurement**.

Séparateur de blocs commun : une ligne `***` → `<hr class="mo-stat-hr">`.

#### Sortie découplée du JS et résolution des liens

Le moteur produit des spans **neutres**, sans `onclick` ni URL :

```html
<span class="mo-lien" data-type="sort" data-id="42">Boule de feu</span>
```

Le conteneur `.mo-stats[data-detail-base]` porte la base d'URL. Un **gestionnaire délégué** dans
`compendium.js` lit `data-type`/`data-id` et résout la cible :

| `data-type` | Action |
|---|---|
| `regle` | ouverture de `regles/regle.php?id=…` dans un **nouvel onglet** |
| `glossaire` | `actualiserPageSub()` → `detail-pp-sub/glossaire.php` (sous-panneau) |
| `don` / `sort` | `actualiserPageSub()` → endpoint `detail-pp` du type (table `MO_LIEN_FICHIERS`) |

→ Indépendant de `BASE_URL` (local `/donjon` vs OVH) ; couplage stockage/JS supprimé.

#### Formulaire et autocomplétion des tags

`include/ajax/modifier/monstre.php` : `<textarea>` brut + popup d'**autocomplétion clavier** des
tags `@` (règle) et `%` (glossaire), alimentée par `include/ajax/autocomplete-tags-monstre.php`
(suggestions id + libellé + fil d'Ariane, scopées au ruleset). Les tags `#`/`$` (don/sort) sont
résolus par nom au rendu. Champs : `mo_nom`, `mo_mocat_id`, `mo_mogr_id`, `mo_fp_id`, `mo_res_id`,
`mo_camp_id`, `mo_prive` (visibilité), `mo_stats`.

> Une ancienne version `include/ajax/modifier/monstre-old.php` subsiste dans le dépôt — à supprimer
> une fois le v3 stabilisé.

#### Fichiers du module

```
compendium/monstres.php                     # contrôleur liste + $listConfig + extra_where visibilité
compendium/enregistrement.php               # case 'monstre' / enregistrerMonstre() (stockage brut)
include/monstre-parser.php                  # moteur d'analyse + rendu (v3) — rendreStatsMonstre()
include/ajax/detail-pp/monstre.php          # fiche détail (#detail-pp) — appelle rendreStatsMonstre()
include/ajax/modifier/monstre.php           # formulaire (textarea + autocomplete tags)
include/ajax/autocomplete-tags-monstre.php  # suggestions tags @ (règle) / % (glossaire)
js/compendium.js                            # gestionnaire délégué .mo-lien (résolution data-*)
css/compendium-modules.css                  # styles .mo-stats / .mo-lien / grille carac
```


---

## 6. Zone d'administration

Accessible uniquement via `requireAdmin()`. Lien affiché dans le header si `$_SESSION['j_admin'] === true`.

### Architecture — moteur admin-liste.php

La zone admin suit le même principe que le compendium : chaque page déclare un `$adminListConfig`
et délègue le rendu à `include/admin-liste.php`.

`admin-liste.php` est un moteur **distinct** de `compendium-liste.php` car ses contraintes
sont différentes : pas de filtre sources, pas de filtre ruleset, pas de champ `_camp_id`.

Différences structurelles vs compendium-liste.php :

| Aspect | compendium-liste.php | admin-liste.php |
|---|---|---|
| Auth | requireAuth() | requireAdmin() |
| Filtre sources | Oui (getActiveResIds) | Non |
| Filtre ruleset | Oui | Non |
| Filtre _camp_id IS NULL | Oui (inféré) | Non |
| Bouton Ajouter | canEditCompendium() | Toujours visible |
| Suppression | Simple | Conditionnelle selon entité |

### Blocs fonctionnels

La zone admin comporte **2 blocs** accessibles depuis `admin/index.php` (dashboard-grid) :

| Bloc | Page | Entité |
|---|---|---|
| A — Gestion des utilisateurs | admin/utilisateurs.php | dd_joueurs |
| B — Gestion des ressources | admin/ressources.php | dd_ressources |

> Les variables (`dd_variables`) sont gérées directement via phpMyAdmin —
> aucune interface d'administration n'est prévue pour cette table.

### A — Gestion des utilisateurs

**Colonnes de la liste :**

| # | Classe CSS | Contenu |
|---|---|---|
| 0 | bulk-check | Checkbox |
| 1 | col-action | Menu ⋮ : Modifier / Réactiver / Désactiver |
| 2 | col-primary | Prénom + Nom |
| 3 | col-secondary | Pseudo |
| 4 | col-secondary | Email |
| 5 | col-secondary | Badges droits : Admin / Compendium |

**Règle de suppression :** La suppression d'un utilisateur est une **désactivation** (`j_visible = 0`),
jamais un DELETE physique. Les données de jeu (personnages, campagnes, univers) sont conservées.
Une fonctionnalité future permettra de localiser et réaffecter les données orphelines.

Message de confirmation inline : *"Cet utilisateur sera désactivé. Ses données de jeu sont conservées."*

Les utilisateurs désactivés restent visibles dans la liste (indicateur visuel) avec une action "Réactiver".

**Bulk actions :** Désactiver la sélection.

**Formulaire modifier (overlay) :**
- Prénom, Nom, Pseudo, Email
- Droits : j_admin (checkbox), j_compendium_manager (checkbox)
- Mot de passe : champ obligatoire en mode **ajout** uniquement ; absent en mode édition
  (la réinitialisation se fait via le profil utilisateur)

### B — Gestion des ressources

**Colonnes de la liste** (les compteurs sont calculés par sous-requêtes SQL) :

| # | Classe CSS | Contenu | Source SQL |
|---|---|---|---|
| 0 | bulk-check | Checkbox | — |
| 1 | col-action | Menu ⋮ : Modifier / Supprimer | — |
| 2 | col-primary | Nom | res_nom |
| 3 | col-secondary | Abréviation | res_abreviation |
| 4 | col-secondary | Ruleset | var_valeur via JOIN dd_variables |
| 5 | col-secondary | Nb classes | COUNT dd_classes WHERE cla_res_id |
| 6 | col-secondary | Nb races | COUNT dd_races WHERE ra_res_id |
| 7 | col-secondary | Nb sorts | COUNT dd_sorts WHERE so_res_id |

**Règle de suppression :** Une ressource ne peut être supprimée que si **aucune** des tables
du compendium ne lui est rattachée. La vérification porte sur l'ensemble du périmètre :

```
dd_classes, dd_races, dd_sorts, dd_dons, dd_competences, dd_historiques, dd_objets_magiques
```

Si des données existent, la suppression est refusée avec un message explicite indiquant
les compteurs par table. Exemple :
*"Impossible de supprimer : 12 classes, 3 races, 48 sorts sont rattachés à cette ressource."*

La confirmation inline affiche les compteurs **avant** validation pour éviter la surprise.

**Pas de bulk delete** — suppression individuelle avec vérification uniquement.

**Formulaire modifier (overlay) :**
- res_nom, res_abreviation
- res_ruleset_var_id : SELECT des rulesets (dd_variables WHERE var_cat = 'ruleset')
- res_selection : checkbox "actif par défaut dans les sélections"
- res_editeur, res_pages, res_description

### Fichiers de la zone admin

```
admin/
  index.php              ← dashboard (2 cartes)
  utilisateurs.php       ← liste utilisateurs ($adminListConfig → admin-liste.php)
  ressources.php         ← liste ressources ($adminListConfig → admin-liste.php)
  enregistrement.php     ← POST commun admin (insert/update/désactivation)

include/
  admin-liste.php        ← moteur commun admin
  ajax/
    detail-pp/
      utilisateur.php
      ressource.php
    modifier/
      utilisateur.php
      ressource.php

css/
  admin-modules.css      ← chargé si $css_module = 'admin'

js/
  admin.js               ← tri, bulk, confirmation inline (clone adapté de compendium.js)
```

---

## 7. Module Personnages

### 7.1 Finalité — aide de jeu, pas moteur de règles

La fiche du site **ne remplace pas** la fiche papier du joueur. Le module est une **aide de jeu** : le joueur
et le MJ y saisissent certaines données du personnage, librement et partiellement, pour disposer de **liens
cliquables vers les règles du compendium** pendant la partie. Objectif : réduire les recherches dans les livres.

Conséquences directes :
- Aucune règle de construction n'est implémentée (pas de prérequis de dons, pas de point-buy, pas de contrôle niveau/classe).
- Tous les éditeurs sont **déclaratifs** ; la saisie peut rester incomplète sans générer d'erreur.
- Les validations serveur portent uniquement sur l'intégrité (FK, propriétaire, complétude d'une affectation NLS), jamais sur une règle de jeu.

### 7.2 Règles métier conservées

- Un personnage possède obligatoirement une race et au moins une classe.
- DD3.5 : race de base + archétype optionnel (`pe_arc_id`), classes de prestige, affectation NLS (`dd_personnages_nls`).
- DD2024 : pas d'archétype (`pe_arc_id = 0`), pas de classe de prestige, historique (`dd_historiques`).
- La campagne **en cours** est stockée dans `pe_camp_id` (NULL = aucune) ; l'historique des campagnes traversées
  reste dans `dd_campagnes_personnages` (liaison N-N). Un personnage n'est dans qu'une seule campagne à la fois.

### 7.3 Structure — fiche unique responsive

Abandon de la navigation multi-pages V1. Une **fiche unique** `personnages/fiche.php` regroupe toutes les sections
en blocs repliables (`togglePlus`). La **Magie** reste une **vue dédiée** (`personnages/magie.php`), plus lourde.

> Priorité absolue : responsive tablette / smartphone. Le module est majoritairement utilisé par les joueurs
> en cours de partie sur petit écran. Cibles tactiles larges, table des caractéristiques en grille fluide,
> aucune action critique dépendant du survol. Seuil 992px aligné sur les autres modules.

**Ordre des blocs de la fiche** (de haut en bas — Mode jeu en tête pour accès rapide en séance) :

| Ordre | Bloc | Données | Cliquable → detail-pp |
|---|---|---|---|
| 1 | Mode jeu *(emplacement réservé)* | Suivi PV et autres variables selon ruleset — **contenu différé** | — |
| 2 | Identité | Nom, Race (+ archétype DD3.5), Historique (DD2024), Sexe, Alignement | Race, Historique |
| 3 | Caractéristiques | 6 caracs + modificateurs | — |
| 4 | Combat | CA, PV | — |
| 5 | Classes | Classes + niveaux | Classe |
| 6 | NLS prestige *(DD3.5)* | Affectation niveaux de prestige → classes de base lanceuses | — |
| 7 | Compétences | Compétences **maîtrisées** uniquement (maîtrise > 0) | Compétence |
| 8 | Dons | Dons saisis (liste déclarative) | Don |
| 9 | Campagnes | Campagne en cours + historique (lecture seule) | Campagne |

Sexe et alignement sont des libellés descriptifs (non cliquables). L'historique n'est cliquable qu'une fois
la section compendium Historiques et son `detail-pp/historique.php` livrés (fonctionnement calqué sur la race).

### 7.4 Liste des personnages — `personnages/index.php`

Liste dédiée (pas le moteur `compendium-liste.php`) calquée sur `campagnes/index.php`. Filtrage strict par
propriétaire (`pe_j_id = j_id`) et par **ruleset actif en session** (un joueur ne voit que ses personnages du
ruleset courant — cohérent avec le sélecteur global de ruleset).

**Filtres** (GET) :
- **Campagne** — select des campagnes du joueur (ruleset courant). Sémantique : `pe.pe_camp_id = ?` (campagne en cours).
- **Classe** — select de toutes les classes du ruleset. Sémantique : `EXISTS (… dd_personnages_classes …)` (le perso a au moins cette classe).
- **Recherche libre** — `pe.pe_nom LIKE ?` (% en début et fin).

**Colonnes desktop** : ⋮ · Nom · Race · Classes · Alignement · Campagne en cours.

**Responsive** (< 992px) : seul le **nom** apparaît sur la première ligne ; race, classes, alignement et campagne
sont concaténés dans un résumé `text-muted` sur la ligne suivante. Le bouton ⋮ remonte en haut-gauche de la carte.
Toutes les colonnes secondaires sont masquées via `.per-liste__col-sec { display: none }` au mobile.

### 7.5 Édition — commit global

L'édition passe par l'**overlay AJAX** `include/ajax/modifier/personnage.php` (pattern projet, pas de page `modifier.php` dédiée). L'overlay est **local** (DOM/JS), **zéro écriture BDD**. Toute la persistance est centralisée dans `personnages/enregistrement.php` : un seul POST en transaction PDO. Abandon de tous les endpoints d'écriture immédiate de la V1.

- **Identité** : formulaire classique. Background / notes via TinyMCE (config complète, avec images).
- **Classes / niveaux** : éditeur DOM déclaratif (nom de classe + niveau), sans validation de règles.
- **Compétences** : le formulaire charge **toutes** les compétences du ruleset dans un bloc repliable (tableau).
  DD3.5 : input numérique (rangs 0..n). DD2024 : sélecteur 0 (aucune) / 1 (maîtrise) / 2 (expertise).
  Persistance DELETE + INSERT en bloc des seules lignes `pec_maitrise > 0`.
- **Dons** : liste déclarative ajoutable / supprimable localement (`dd_personnages_dons`).
- **NLS prestige (DD3.5)** : un tableau par classe de prestige influant sur le NLS ; pour chaque niveau, un select
  des classes de base lanceuses compatibles. Saisie déclarative ; validation serveur = complétude de l'affectation.

### 7.6 Magie — vue dédiée

`personnages/magie.php` affiche, par classe lanceuse de sorts :
- le **nombre de sorts par jour** par niveau de sort (calcul conservé, cf. 7.7) ;
- les listes de sorts **connus / compris / préparés**, cliquables → `detail-pp/sort.php` (contexte `externe`).

La liste de sorts proposée est bornée par `getActiveResIds()` (chaîne campagne → perso → défaut, §5).

### 7.7 Calcul NLS et sorts par jour (conservé)

Exception assumée au principe « aide de jeu » : le calcul est conservé car NLS et emplacements sont liés par les
règles métier et aident réellement en séance. Logique portée du helper V1, réécrite proprement pour le schéma figé
(plus de `SHOW COLUMNS` ni de fallbacks de noms de champs).

```
NLS effectif = niveau de classe de base
             + bonus des classes de prestige (dd_personnages_nls, selon cn_niveauSortArcane/Divin/Effectif)
Emplacements = dd_classe_niveau.cn_sort_n0..9 (au NLS effectif)
             + dd_modificateurs.mod_bonusSort0..9 (bonus de la caractéristique de classe)
             + 1 par niveau de sort > 0 si la classe choisit des domaines divins (DD3.5)
```

DD2024 : nombre de sorts préparés via `cn_sortPrepare` ; bonus de maîtrise via `dd_bonus_maitrise`.

Affectation NLS (DD3.5) : pour chaque classe de prestige dont au moins un de `cn_niveauSortArcane`,
`cn_niveauSortDivin`, `cn_niveauSortEffectif` vaut 1, le joueur affecte chaque niveau de prestige à une classe
de base lanceuse compatible. Filtrage du select :
- `cn_niveauSortArcane = 1` → classes de base avec `cla_mag_id = 1`
- `cn_niveauSortDivin = 1` → classes de base avec `cla_mag_id = 2`
- `cn_niveauSortEffectif = 1` → toutes les classes de base lanceuses

Sur la fiche, un niveau non affecté affiche « À affecter » en rouge.

### 7.8 Stockage des sorts

Les tables V1 `dd_grimoires` / `dd_grimoires_contenu` sont abandonnées. On utilise :
- `dd_personnages_sorts` : sorts connus (présence de ligne) / compris (`pes_compris = 1`), rattachés à `pes_pc_id`.
- `dd_personnages_sorts_prepares` : sorts préparés, avec métamagie DD3.5 (`pesp_metamagie`, `pesp_niveau`, `pesp_nb`).

### 7.9 Pages annexes

- `personnages/objets.php` : placeholder « Fonctionnalité à venir » (analyse métier non fiabilisée, aucune table).
- Onglet Notes : emplacement réservé ; le contenu relève du module Notes (Phase 5). La préférence d'affichage
  (campagne en cours / toutes les campagnes) est mémorisée sur le personnage (`pe_notes_scope`).

### 7.10 Fichiers du module

```
personnages/
  index.php          Liste filtrée (campagne / classe / recherche libre), responsive
  fiche.php          Fiche unique (sections repliables, Mode jeu en tête)
  modifier.php       — n'existe pas : l'édition passe par include/ajax/modifier/personnage.php (overlay)
  enregistrement.php Routeur d'actions transactionnelles (commit global)
  magie.php          Vue dédiée Magie (NLS, emplacements, sorts cliquables)
  objets.php         Placeholder « Fonctionnalité à venir »

js/personnage.js                Menu contextuel, suppression inline, éditeurs DOM (3.2+)
css/personnages-modules.css     Styles module — chargé si $css_module = 'personnages'

include/personnage_helpers.php  getPersonnageContext, getPersonnageClasses,
                                getCampagnesPersonnage, getAlignements,
                                modCarac, formatMod
                                (calcul NLS et emplacements ajoutés en 3.5/3.6)

include/ajax/detail-pp/personnage.php   Vue détail (contexte 'externe' depuis Campagnes)
include/ajax/modifier/personnage.php    Overlay création / modification
```

### 7.11 Découpage en sous-phases

- **3.0** Socle + SQL (patch `dd_alignements` + champs `pe_sexe`/`pe_al_id`/`pe_notes_scope`, dossiers, JS/CSS, helpers, liste filtrée) — *livrée*
- **3.1** Fiche identité (nom, race, archétype DD3.5, historique DD2024, sexe, alignement, caracs, combat) + première classe à la création — *livrée*
- **3.2** Classes & niveaux (éditeur multi-classes complet sur la fiche)
- **3.3** Compétences (tableau complet du ruleset)
- **3.4** Dons
- **3.5** NLS prestige (DD3.5)
- **3.6** Vue Magie (calcul NLS + sorts par jour + listes cliquables)
- **3.7** Emplacement mode jeu + passe responsive < 992px

---

## 8. Module Campagnes

> Détails : `ARCHITECTURE_8_CAMPAGNES.md` (technique) et `METIER_10_Campagnes.md` (fonctionnel).
> Structure de données validée — schéma `SCHEMA_SQL.md` v1.1 (section 7).

Hiérarchie : **Campagne → Scénario → Chapitre → Rencontre → Opposition**

- **Campagne** : 1 propriétaire (`camp_j_id`, le MJ), 1 ruleset (`camp_ruleset_var_id`, **maître**,
  hérité par tout le contenu), 0–1 univers (`camp_un_id`, univers agnostiques du ruleset).
- **Sources** : `dd_campagnes_sources` — priorité 1 de la chaîne `getActiveResIds()`.
- **Personnages** : lien **N-N** via `dd_campagnes_personnages` (source de vérité).
  `dd_personnages.pe_camp_id` n'est qu'un raccourci « dernière campagne jouée ».
- **Rencontre** : rattachement à un chapitre **obligatoire** (`re_scc_id` NOT NULL, plus de
  rencontre orpheline). Effectifs décrits **littéralement** dans `re_composition` (texte).
- **Opposition** : copie **éditable** d'un monstre du compendium (`dd_oppositions`), propre à une
  rencontre (lien 1-N `opp_re_id`). Le monstre modèle (`opp_mo_id`) est figé pour traçabilité ;
  nom, catégorie (texte libre) et stats sont recopiés puis modifiables sans toucher au compendium.
- **Duplication** : scénario / rencontre / opposition duplicables (suffixe « - copie »), en cascade
  descendante, **limitée au ruleset courant** (pas de copie inter-ruleset).
- **Pièces jointes** : PDF uniquement, table générique `dd_fichiers` (campagne / scénario /
  rencontre). **Images** des descriptions via l'endpoint TinyMCE existant (`upload-image.php`).
- **Suppression douce** (détail à préciser avant implémentation).
- Notes MJ (`cp_notes_mj`, `dd_campagnes_notes`) : **réservées, hors UI** cette version.

Module **NON responsive** — usage desktop MJ exclusif. Menu visible si `j_mode_campagne = 1`.

---

## 9. Module Wiki / Univers

Univers (public/privé) → Catégories → Articles (visible/caché)
Délégation droits via dd_univers_droits. En v1 : globale sur l'univers entier.

---

## 9b. Module Règles

Module de référence transverse : un **wiki de règles** hiérarchique et récursif, pensé pour
la consultation rapide par le MJ pendant ses parties et la recherche d'une règle précise.

### Principe — table unique récursive

Une **table unique** `dd_regles` (préfixe `reg`) modélise l'intégralité d'un livre de règles
d'un ruleset. Chaque nœud référence son parent via `reg_reg_id` (NULL = racine). Un nœud porte
un `reg_type` qui sert d'indice sémantique et d'affichage :

| reg_type | Rôle | Arbre | Contenu |
|---|---|---|---|
| `chapitre` | Conteneur structurel (peut avoir une intro) | dossier | `reg_texte` optionnel |
| `regle` | Unité consultable (feuille en pratique) | page | `reg_texte` = corps de la règle |
| `glossaire` | Terme de glossaire DD2024 (définition courte, cible de renvoi) | page | `reg_texte` = définition |

> `reg_type` est un **indice**, pas une contrainte : une `regle` peut techniquement avoir
> des enfants. La récursion reste libre — la souplesse prime.

La hiérarchie EST la catégorisation : la table v1 `dd_categorie_regle` (vestigiale, jamais
sauvegardée par `regle-enregistrement.php`) n'est **pas** portée en v2.

### Schéma de la table dd_regles

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| reg_id | int unsigned | PK | |
| reg_reg_id | int unsigned | null | Parent récursif -> dd_regles ; NULL = racine |
| reg_type | enum('chapitre','regle','glossaire') | nn, défaut 'regle' | Indice d'affichage / sémantique ; `'glossaire'` = terme de glossaire DD2024 (cible de renvoi cliquable) |
| reg_nom | varchar(200) | nn | Titre du chapitre / de la règle |
| reg_slug | varchar(220) | nn, UK(reg_slug, reg_ruleset_var_id) | Version URL-safe — liens profonds stables |
| reg_texte | longtext | null | Contenu HTML (TinyMCE) — intro pour un chapitre, corps pour une règle |
| reg_ordre | smallint unsigned | nn, défaut 0 | Ordre parmi les frères (drag & drop) |
| reg_ruleset_var_id | int unsigned | nn | -> dd_variables |
| reg_camp_id | int unsigned | null | **RÉSERVÉ** house rules futures -> dd_campagnes ; NULL = règle officielle |
| reg_visible | tinyint(1) | nn, défaut 1 | 0 = brouillon/masqué (éditeurs seulement) |
| reg_date_creation | datetime | nn | Horodatage automatique |
| reg_date_modif | datetime | nn | Mis à jour automatiquement |

Index : `(reg_reg_id, reg_ordre)`, `(reg_ruleset_var_id)`, **FULLTEXT (reg_nom, reg_texte)**.

> Le champ v1 `re_ecran` (« affichage écran », sémantique floue) n'est pas repris :
> visibilité = `reg_visible`, ordre = `reg_ordre`.

### Périmètre / scoping

- Scoping **ruleset uniquement** (`reg_ruleset_var_id`). Un module Règles existe en parallèle
  pour DD3.5 et DD2024, comme le compendium.
- **Pas** de filtre sources (`_res_id`) : les règles sont du contenu de référence, pas du contenu
  filtré par livre/sélection. Le moteur `compendium-liste.php` **ne s'applique pas** à ce module.
- `reg_camp_id` (nullable) est **réservé** pour de futures *house rules* de campagne
  (NULL = règle officielle). Aucun comportement v2 ne s'en sert. Réservation cohérente avec la
  réserve homebrew (§5).

### Droits d'édition

Même portail que le compendium global : édition réservée à `admin` + `j_compendium_manager`
(via `canEditCompendium()`). Consultation : tout utilisateur authentifié.

### Navigation « comme un livre »

Trois axes pensés pour l'usage en table :

1. **Sommaire / arbre** (`regles/index.php`) — arbre récursif repliable du ruleset actif, rendu
   par `include/regles-arbre.php` (fonction récursive, équivalent v2 de la fonction `regles()`
   de la v1). Les chapitres se replient/déplient ; un clic ouvre la vue lecture.
2. **Fil d'Ariane (breadcrumb)** — sur la vue lecture, la chaîne des ancêtres est reconstruite
   en remontant `reg_reg_id` jusqu'à la racine. Le MJ sait toujours où il se trouve.
3. **Précédent / Suivant (ordre de lecture)** — `regle.php` affiche ◄ Précédent / Suivant ►
   calculés sur l'**ordre de lecture linéarisé** : parcours en profondeur (DFS) de l'arbre trié
   par `(reg_reg_id, reg_ordre)`. Helper `reglesOrdreLecture($ruleset_var_id)` (include/helpers.php)
   → séquence à plat ; Précédent/Suivant = voisins du nœud courant dans cette séquence.
   Aucune colonne d'ordre global matérialisée → pas de désynchronisation à l'édition ; feuillette
   le livre entier en descendant naturellement dans les chapitres.

La vue lecture affiche aussi un **sous-sommaire** : la liste ordonnée des enfants directs du nœud
courant (pour plonger d'un chapitre vers ses règles).

### Recherche

`regles/recherche.php` — moteur dédié, scope ruleset actif + `reg_camp_id IS NULL`.

- Index **FULLTEXT (InnoDB)** sur `(reg_nom, reg_texte)` → `MATCH … AGAINST` en mode naturel,
  classement par pertinence, le match sur `reg_nom` pondéré plus fort que sur `reg_texte`.
- **Fallback LIKE** si la requête est sous la longueur minimale FULLTEXT (`ft_min_word_len`)
  ou ramène 0 résultat.
- Chaque résultat affiche : **fil d'Ariane** du nœud (contexte), **extrait** du texte, et **terme
  recherché surligné** (`<span class="resultat_recherche">`, repris de la v1).
- Un clic ouvre la vue lecture (`regle.php`) ou le detail-pp selon le contexte d'ouverture.

### Consultation pendant la partie — detail-pp transverse

`include/ajax/detail-pp/regle.php` rend une règle dans l'overlay `#detail-pp` (fil d'Ariane +
contenu + Précédent/Suivant + recherche embarquée), ouvrable depuis les pages campagne/scénario/
rencontre en contexte `'externe'` (pattern detail-pp transverse, §12).
→ Le MJ tape un mot-clé, ouvre la règle, navigue, ferme l'overlay et reprend sa partie.

### Glossaire DD2024 et renvois cliquables

DD2024 introduit un **Glossaire de règles** : des définitions structurantes (états, termes,
dangers, sens spéciaux…) auxquelles le reste des règles renvoie en permanence
(« … l'état Aveuglé (cf. « Glossaire de règles ») »). Le module gère ces renvois sans
modèle de données dédié — il s'appuie sur l'arbre récursif existant et le sous-panneau
`#detail-pp-sub` déjà en place.

**Stockage des termes.** Chaque terme de glossaire est un **nœud `dd_regles` ordinaire**
(`reg_type = 'glossaire'`), enfant d'un chapitre « Glossaire de règles ». Il a donc nom,
`reg_slug`, `reg_texte` (la définition) et apparaît dans le sommaire, la recherche et l'ordre
de lecture comme tout autre nœud.

**Encodage des renvois — ancres explicites.** Un renvoi dans le corps d'une règle est une
**ancre HTML explicite** dans `reg_texte` :

```html
… vous subissez l'état <a class="glossaire-lien" data-glossaire-slug="aveugle">Aveuglé</a> …
```

> Choix : ancre explicite **plutôt qu'auto-détection au rendu**. L'auto-détection poserait
> les mêmes risques que le surlignage de recherche (casser le HTML TinyMCE, faux positifs,
> accords singulier/pluriel/genre). L'auto-liaison ne sert qu'**une seule fois à l'import**
> pour poser ces ancres ; l'éditeur garde ensuite le contrôle. Voir DECISIONS_LOG.

**Affichage au clic — sous-panneau `#detail-pp-sub`.** Un handler **délégué** dans `regles.js`
intercepte les clics sur `.glossaire-lien` et appelle le mécanisme existant :

```javascript
// regles.js — délégation
document.addEventListener('click', function (e) {
  const lien = e.target.closest('.glossaire-lien');
  if (!lien) return;
  e.preventDefault();
  actualiserPageSub(BASE_URL + '/include/ajax/detail-pp-sub/glossaire.php',
                    { slug: lien.dataset.glossaireSlug });
});
```

`actualiserPageSub()` (main.js, déjà existant) charge la définition en **lecture seule** dans
`#detail-pp-sub`, qui s'affiche **au-dessus** de la règle ouverte dans `#detail-pp` (backdrop et
bouton de fermeture auto-injectés). Le MJ lit la définition, ferme le sous-panneau
(`fermerSubPanel()`) et retrouve sa règle intacte.

**Renvois imbriqués.** Une définition de glossaire peut elle-même contenir des
`.glossaire-lien`. Un clic à l'intérieur du sous-panneau rappelle `actualiserPageSub()` :
le contenu du **même** `#detail-pp-sub` est **remplacé sur place** (pas d'empilement de
couches). Une pile « retour » optionnelle peut être gérée dans `regles.js` si la navigation
profonde le justifie.

**Endpoint.** `include/ajax/detail-pp-sub/glossaire.php?slug=…` : résout le terme par
`(reg_slug, reg_ruleset_var_id, reg_type='glossaire')`, rend nom + définition (HTML sans `h()`).
Lecture seule, scope ruleset actif.

**Recherche.** Les termes de glossaire étant des nœuds, ils remontent naturellement dans
`regles/recherche.php` (le MJ peut chercher « neutralisé » et tomber directement sur la
définition).

**Compatibilité DD3.5.** DD3.5 n'a pas de glossaire : aucun nœud `reg_type='glossaire'`,
aucune ancre `.glossaire-lien`. Le mécanisme est **dormant** côté DD3.5 — zéro impact.
Le schéma reste agnostique du ruleset.

**Responsabilités de l'import (étape SQL).** Le seed DD2024 doit : (1) créer le chapitre
« Glossaire de règles » et un nœud `reg_type='glossaire'` par terme ; (2) poser les ancres
`.glossaire-lien` dans les `reg_texte` des règles, par appariement des termes connus avec les
marqueurs « (cf. « Glossaire de règles ») » et les tournures « l'état X ».

### Édition

- `regles/modifier.php` *(ou overlay `include/ajax/modifier/regle.php`)* : édition locale JS/DOM,
  **zéro écriture BDD**. Champs : nom, type (chapitre/regle/glossaire), parent (`<select>` des nœuds du
  ruleset), contenu (TinyMCE config règles avec tables), visible. `reg_ordre` géré par
  **drag & drop** dans le sous-sommaire du parent (pattern races/classes, payload JSON au submit).
- `regles/enregistrement.php` : un seul POST en transaction PDO (insert/update/delete +
  réordonnancement des frères). Validations serveur : parent ≠ soi-même **et** ≠ un descendant
  (**anti-cycle**), `reg_type` whitelisté, `reg_ruleset_var_id` = ruleset en session, `reg_slug`
  régénéré + unicité par ruleset.
- `reg_slug` permet un lien profond mémorisable : `regles/regle.php?r=tests-de-caracteristique`.

### Fichiers du module

```
regles/
  index.php          sommaire racine (arbre) + barre de recherche
  regle.php          vue lecture (ariane, contenu, sous-sommaire, Précédent/Suivant)
  recherche.php      résultats FULLTEXT + surlignage + ariane
  modifier.php       formulaire d'édition (ou overlay) — aucune écriture BDD
  enregistrement.php POST commun (insert/update/delete/réordonnancement) — transaction PDO

include/
  regles-arbre.php   moteur d'arbre récursif (rendu sommaire) — fonction récursive
  ajax/
    detail-pp/regle.php   aperçu règle en overlay (consultation pendant la partie)
    detail-pp-sub/glossaire.php   définition d'un terme de glossaire (DD2024) — sous-panneau
    modifier/regle.php    formulaire édition en overlay

css/regles-modules.css   chargé si $css_module = 'regles'
js/regles.js             repli arbre, recherche, drag & drop ordre, overlay
```

---

## 10. Responsive

| Module | Responsive | Notes |
|---|---|---|
| Compendium | Oui | col-primary/secondary/action, pas de boutons action mobile |
| Personnages | Oui | **Priorité tablette/smartphone** — fiche unique, sections repliables, cibles tactiles larges, Mode jeu en haut |
| Wiki / Univers | Oui | |
| Campagnes | Non | Desktop MJ uniquement |
| Profil | Oui | |
| Connexion / Auth | Oui | |
| Admin | Oui | Même classes CSS que le compendium |

Seuil : 992px.

---

## 11. Profil utilisateur

Quatre sections indépendantes (champ hidden section) : identité, mot de passe, paramètres, sources.
DEV_MODE = true dans include/db.php → lien reset MDP affiché en page.

### Paramètres utilisateur

| Paramètre | Champ | Description |
|---|---|---|
| Ruleset par défaut | j_default_ruleset_var_id | Ruleset chargé à chaque connexion |
| Apparence | j_theme | Thème visuel : dark (sombre) ou light (Parchemin) |
| Mode campagne | j_mode_campagne | Active/désactive le menu Campagnes |
| Affichage ruleset | j_affichage_ruleset | Affiche le ruleset dans le header |
| Éléments par page | j_items_par_page | Taille des listes (10/20/50/100) |

### Section "Mes sources" — sélection personnelle des ressources

L'utilisateur peut choisir, pour le ruleset actif, quelles ressources globales alimentent son compendium.
Cette sélection correspond à la priorité 2 de getActiveResIds().

**Périmètre affiché :** ressources globales uniquement (`res_j_id IS NULL`) du ruleset actif.
Le ruleset est lu depuis `$_SESSION['ruleset_var_id']` côté serveur.

**Comportement zéro sélection :** autorisé. Supprimer toutes les lignes `dd_joueurs_sources`
pour ce joueur/ruleset équivaut à réinitialiser — getActiveResIds() retombe sur la priorité 3
(res_selection = 1). Un message explicite informe l'utilisateur.

**Sauvegarde :** DELETE + INSERT en bloc dans `dd_joueurs_sources`.
Chaque res_id reçu en POST est revalidé côté serveur contre la liste autorisée.

**Table de liaison :** `dd_joueurs_sources (js_j_id, js_res_id, js_ruleset_var_id)`

> Les ressources homebrew (`res_j_id IS NOT NULL`) ne sont pas gérées depuis le profil.
> Voir §5 Compendium — Contenu homebrew.

---

## 11b. Système de thèmes visuels

### Mécanisme

Le thème est une classe CSS sur `<body>` : `theme-dark` ou `theme-light`.

```php
// include/header.php
$theme_valides = ['dark', 'light'];
$theme_actif   = in_array($_SESSION['j_theme'] ?? '', $theme_valides, true)
                 ? $_SESSION['j_theme']
                 : 'dark';
// ...
<body class="theme-<?= $theme_actif ?>">
```

Les variables CSS sont déclarées par thème dans `css/main.css` :

```css
body.theme-dark  { --clr-bg: #1a1a2e; --clr-surface: #16213e; ... }
body.theme-light { --clr-bg: #f4f1eb; --clr-surface: #ffffff; ... }
:root            { /* typo, espacements, rayons — indépendants du thème */ }
```

### Thèmes disponibles

| Valeur | Nom | Description |
|---|---|---|
| dark | Sombre | Bleu nuit, accents rouge/or — défaut |
| light | Parchemin | Tons beiges chauds, accents bordeaux/or patiné |

### Stockage et session

- BDD : `dd_joueurs.j_theme ENUM('dark','light') DEFAULT 'dark'`
- Session : `$_SESSION['j_theme']` chargé dans `startUserSession()` (include/auth.php)
- Validation : whitelist `['dark','light']` dans auth.php et profil/index.php
- Choix : radio buttons dans la section Paramètres de profil/index.php

#### Thème utilisateur — `j_theme`

La préférence de thème (`dark` / `light`) est stockée en base dans
`dd_joueurs.j_theme` et propagée en session via `$_SESSION['j_theme']`. Le rendu
applique la classe `theme-<dark|light>` sur `<body>` dans `include/header.php`,
avec repli sur `dark` si la valeur de session est absente ou hors whitelist.

`$_SESSION['j_theme']` est alimenté à **trois** endroits, qui doivent rester
cohérents (même whitelist `['dark', 'light']`, même défaut `dark`) :

- **`startUserSession()`** (`include/auth.php`) — appelée à la connexion par
  formulaire **et** par le remember me.
- **`index.php`** — `SELECT` de connexion : **doit inclure `j_theme`**, sinon
  `startUserSession()` reçoit un `$row` incomplet et retombe sur `dark`.
- **`checkRememberMe()`** (`include/auth.php`) — `SELECT` de reconnexion
  automatique : inclut déjà `j_theme`.
- **`profil/index.php`** — mise à jour de la préférence (UPDATE + rafraîchissement
  de `$_SESSION['j_theme']`).

**Invariant** : toute colonne consommée par `startUserSession()` figure dans les
deux requêtes qui peuvent l'appeler (login formulaire et remember me). Un oubli
dans l'une des deux produit un comportement divergent selon le mode de connexion.

### Variable CSS --clr-surface-alt

`--clr-surface-alt` est définie dans chaque thème pour les composants qui nécessitent
une surface légèrement différente de `--clr-surface-2` (ex : en-têtes de `table-classe-niv`).
Ne pas utiliser de fallback hardcodé — toujours passer par la variable.

### Overlays — largeurs

| Composant | max-width |
|---|---|
| .overlay-panel (detail-pp) | 960px |
| .overlay-panel--edit (modification) | 1040px |

Ces valeurs permettent d'afficher les tables de progression de classe (20+ colonnes)
sans scroll horizontal dans le panel.

### Extension future

Un troisième thème s'ajoute en :
1. Déclarant `body.theme-xxx { ... }` dans main.css
2. Ajoutant 'xxx' au ENUM de dd_joueurs
3. Ajoutant 'xxx' aux whitelists dans auth.php et profil/index.php
4. Ajoutant l'option radio dans profil/index.php

---

## 12. Patterns d'interface

### detail-pp — contexte d'ouverture

detail-pp peut être ouvert depuis deux contextes :
- 'liste' : depuis une page liste du compendium
- 'externe' : depuis toute autre page (fiche personnage, scénario...) — DEFAUT

Le contexte est mémorisé en JS dans _detailPpContext.

```javascript
// main.js
let _detailPpContext = 'externe';
let _detailPpUrl     = '';
let _detailPpParams  = {};

// Depuis une liste compendium
actualiserPage(url, {id: 42}, 'liste');

// Depuis une page externe — context 'externe' par défaut
actualiserPage(url, {id: ra_id});
```

### Bouton Modifier dans detail-pp

Le HTML de detail-pp contient le bouton Modifier si canEditCompendium() (vérification serveur).
Le bouton appelle ouvrirModifier(url, id) — le contexte est déjà mémorisé.

Ce pattern est valable depuis toute page du site (compendium, personnage, campagne...).

### Après modification — apresModification()

```javascript
function apresModification(data) {
  fermerModification();
  actualiserPage(data.url_detail, {id: data.id}, _detailPpContext);
  if (_detailPpContext === 'liste') {
    rafraichirListe(); // window.location.reload() — préserve les GET params
  }
}
```

Règle :
- _detailPpContext = 'liste'    → rafraîchit detail-pp + liste
- _detailPpContext = 'externe'  → rafraîchit detail-pp uniquement

### Système d'overlays empilés — #detail-pp, #modification, #detail-pp-sub

> **Référence définitive.** Ces trois overlays existent et sont câblés dans `main.js`.
> Tout nouveau développement les **réutilise** — ne jamais en réinventer ni se demander
> si le sous-panneau existe : il existe.

Trois conteneurs d'overlay, chacun avec son backdrop, empilés par z-index croissant :

| Conteneur | Backdrop | Rôle | Écriture BDD |
|---|---|---|---|
| `#detail-pp` | `#detail-pp-backdrop` | Panneau de détail principal (lecture) | Non |
| `#modification` | `#modification-backdrop` | Formulaire d'édition (overlay) | Non (commit via enregistrement.php) |
| `#detail-pp-sub` | `#detail-pp-sub-backdrop` | **Sous-panneau** affiché AU-DESSUS de `#detail-pp` | **Non — lecture seule** |

**À quoi sert `#detail-pp-sub`.** Afficher le détail d'un élément **référencé** depuis un
panneau déjà ouvert, sans fermer le panneau principal : une capacité, une compétence, un sort
cité dans une fiche — et, pour le module Règles, **un terme de glossaire** cliqué dans une règle.
C'est la mécanique « overlay au-dessus de detail-pp » réutilisée par le glossaire DD2024 (§9b).

**API JavaScript (main.js) :**

```javascript
// Ouvre/rafraîchit le sous-panneau en lecture seule (GET).
// Injecte automatiquement un bouton de fermeture (fermerSubPanel) et affiche le backdrop.
actualiserPageSub(url, params = {});      // ex: actualiserPageSub(BASE_URL + '/include/ajax/detail-pp-sub/glossaire.php', { slug })

// Ferme UNIQUEMENT le sous-panneau, sans toucher au panneau principal.
fermerSubPanel();

// Ferme #detail-pp ET, en cascade, #modification + #detail-pp-sub.
fermerDetailPP();   // appelle fermerSubPanel() et fermerModification()
```

**Règles d'usage :**
- `#detail-pp-sub` est **strictement en lecture seule** : il charge un fragment via GET. Toute
  édition passe par `#modification` + `*-enregistrement.php` (jamais depuis le sous-panneau).
- Le bouton de fermeture et le backdrop sont **injectés automatiquement** par `actualiserPageSub()` —
  l'endpoint appelé ne rend que le contenu (pas de wrapper, pas de bouton fermer).
- **Pas d'empilement de N couches** : un lien référencé cliqué *dans* le sous-panneau rappelle
  `actualiserPageSub()`, ce qui **remplace le contenu sur place** du même `#detail-pp-sub`.
  Une pile « retour » peut être gérée côté JS du module si une navigation profonde est requise.
- Fermer le panneau principal (`fermerDetailPP()`) referme le sous-panneau en cascade.
- Endpoints dédiés rangés sous `include/ajax/detail-pp-sub/` (ex : `glossaire.php`).

**Quand l'utiliser (vs `#detail-pp`) :** dès qu'on consulte un élément référencé alors qu'un
détail est déjà ouvert. Si aucun panneau n'est ouvert (ouverture depuis une liste ou une page),
c'est `#detail-pp` (via `actualiserPage`) qui s'applique, pas le sous-panneau.

### Commit global (pages modifier)

- *-modifier.php : édition locale JS/DOM — zéro écriture BDD
- *-enregistrement.php : un seul POST en transaction PDO
- Validation métier obligatoire côté serveur

### Blocs repliables (burger)

```html
<button onclick="togglePlus('id_bloc')"><i class="fa fa-bars"></i></button>
<div id="id_bloc" class="accordion-content noDisplay">
  <div class="box-data">contenu</div>
</div>
```
Style : fond var(--burger-bg), bordure var(--burger-border), texte var(--burger-text).
Les valeurs de ces variables sont définies par thème dans main.css.
Le fond reste toujours "clair" dans les deux thèmes (beige #f3f3ef en dark, #f9f6f0 en light).

---

## 13. Arborescence du projet

```
donjon/
  index.php
  .htaccess
  personnages/     fiche.php, enregistrement.php, magie.php, objets.php, index.php
  compendium/      sorts.php, classes.php, dons.php, races.php,
                   competences.php, objets.php, monstres.php,
                   historiques.php   (DD2024 uniquement)
                   enregistrement.php
  campagnes/       campagnes.php (liste), campagne.php, scenario.php, rencontre.php
                   enregistrement.php (POST centralisé du module)
  wiki/            univers.php, articles.php
  regles/          index.php, regle.php, recherche.php, modifier.php, enregistrement.php
  profil/          index.php, mot-de-passe-oublie.php, reinitialisation.php
  admin/
    index.php            (dashboard admin — 2 cartes)
    utilisateurs.php     (liste + $adminListConfig)
    ressources.php       (liste + $adminListConfig)
    enregistrement.php   (POST commun admin)
  js/
    main.js          togglePlus, actualiserPage, _detailPpContext,
                     apresModification, rafraichirListe, CSRF
    personnage.js
    compendium.js    toggleSort, submitFiltre, bulk, confirmerSuppression inline
    campagne.js
    wiki.js
    regles.js        repli arbre, recherche, drag&drop ordre, overlay
    profil.js
    admin.js         (Phase admin — clone adapté de compendium.js)
  css/
    main.css                  variables par thème (body.theme-dark/light), layout, composants transverses
    modules.css               styles globaux (login, dashboard, profil, header, sélecteur thème)
    compendium-modules.css    styles compendium — chargé si $css_module = 'compendium'
    personnages-modules.css   (Phase 3) — chargé si $css_module = 'personnages'
    campagnes-modules.css     (Phase 4) — chargé si $css_module = 'campagnes'
    wiki-modules.css          (Phase 5) — chargé si $css_module = 'wiki'
    regles-modules.css        chargé si $css_module = 'regles'
    admin-modules.css         chargé si $css_module = 'admin'
  include/
    db.php           PDO + BASE_URL + DEV_MODE
    auth.php         + chargement j_theme en session
    helpers.php
    header.php       classe theme-{dark|light} sur body + charge $css_module-modules.css et $js_module.js
    footer.php
    compendium-liste.php    moteur de liste commun compendium (lit $listConfig)
    admin-liste.php         moteur de liste commun admin (lit $adminListConfig)
    regles-arbre.php        moteur d'arbre récursif du module Règles (fonction récursive)
    monstre-parser.php      moteur d'analyse + rendu du bloc de stats monstre (v3)
    ajax/
      detail-pp/     sort.php, classe.php, don.php, race.php, historique.php...
                     monstre.php   (Monstres — appelle rendreStatsMonstre())
                     campagne.php, scenario.php, rencontre.php, opposition.php   (Campagnes)
                     regle.php   (Règles)
                     utilisateur.php, ressource.php   (admin)
      detail-pp-sub/ glossaire.php   (Règles — terme de glossaire DD2024, au-dessus de detail-pp)
      modifier/      sort.php, classe.php, don.php, race.php, historique.php...
                     monstre.php   (Monstres — textarea + autocomplete tags)
                     regle.php   (Règles)
                     campagne.php, scenario.php, chapitre.php, rencontre.php, opposition.php   (Campagnes)
                     utilisateur.php, ressource.php   (admin)
      campagne/      monstre-template.php (pré-remplissage opposition), dupliquer.php,
                     personnage-attach.php, personnage-detach.php   (Campagnes)
      upload-pdf.php                   (Campagnes — pièces jointes PDF, table dd_fichiers)
      upload-image.php                 (TinyMCE — images, réutilisé par les descriptions campagnes)
      autocomplete-tags-monstre.php   (Monstres — suggestions tags @ règle / % glossaire)
      regles/        reorder.php, arbre.php   (drag & drop ordre + fragment sommaire)
    insert/
      DD3.5/
      DD2024/
  sql/
    schema.sql
    patch_001_reset_password.sql
    patch_002_theme.sql        ← ALTER TABLE dd_joueurs ADD j_theme
    doc/sql/2026-06-01_campagnes_v2_etape1.sql   ← Module Campagnes (oppositions, fichiers, pe_camp_id...)
  uploads/
    campagnes/             pièces jointes PDF (dd_fichiers) — hors webroot ou protégé
  img/
    uploads/               dépôt fichiers uploadés via TinyMCE (755)
  doc/
    ARCHITECTURE_0_REFERENCE.md
    DECISIONS_LOG.md
    SCHEMA_SQL.md
    ARCHITECTURE_2_SORTS.md
    ARCHITECTURE_8_CAMPAGNES.md
    METIER_10_Campagnes.md
    METIER_*.md
```

---

## 14. Plan de développement

### Phase 1 — Socle technique TERMINE
Auth, session, helpers, header/footer, dashboard, profil, reset MDP, CSS design system.

### Phase 2 — Compendium EN COURS (sorts, dons, compétences implémentés)
- include/compendium-liste.php — moteur commun
- compendium/enregistrement.php — POST commun + mode AJAX
- js/compendium.js — tri, filtre, bulk, confirmation inline
- css/compendium-modules.css — styles listes, detail-pp sort, responsive compendium
- Pages : sorts, classes, dons, races, competences, objets, monstres, historiques (DD2024)
- AJAX detail-pp et modifier pour chaque entité
- Monstres : moteur de rendu dédié include/monstre-parser.php (v3) — texte brut, analyse à l'affichage, tags explicites + autocomplétion
- Templates DD3.5 et DD2024 en parallèle

### Phase Admin — Zone d'administration TERMINE
- include/admin-liste.php — moteur commun admin
- admin/enregistrement.php — POST commun admin
- js/admin.js — tri, bulk, confirmation inline (adapté)
- css/admin-modules.css — styles listes admin
- admin/index.php — dashboard 2 cartes
- admin/utilisateurs.php + AJAX detail-pp/modifier/utilisateur.php
- admin/ressources.php + AJAX detail-pp/modifier/ressource.php

### Mise en page — Thèmes TERMINE
- Système dark/light via classe body + variables CSS par thème
- Fix bug table-classe-niv (--clr-surface-alt non défini)
- Overlays élargis (960px / 1040px)
- Sélecteur de thème dans profil/index.php section Paramètres

### Phase 3 — Personnages
Fiche, classes/niveaux, sorts, compétences, dons, NLS (DD3.5).

### Phase 4 — Campagnes
Campagne (sources, univers, personnages invités), scénarios, chapitres, rencontres, oppositions
(copies de monstres), duplication, pièces jointes PDF. Structure de données validée.

### Phase 5 — Wiki / Univers
Univers, catégories, articles, délégation, lien univers <-> campagne.

---

### Module Règles — Wiki de règles
Table récursive dd_regles (reg_reg_id), arbre/sommaire repliable, vue lecture (fil d'Ariane +
sous-sommaire + Précédent/Suivant en ordre de lecture DFS), recherche FULLTEXT + surlignage,
édition (drag & drop de l'ordre, anti-cycle parent), detail-pp transverse pour consultation
pendant la partie.
Glossaire DD2024 : termes = nœuds reg_type='glossaire' ; renvois cliquables (ancres
.glossaire-lien) ouvrant la définition dans le sous-panneau #detail-pp-sub (réutilisé).
Import SRD 5.2.1 : arbre complet + glossaire + pose des ancres de renvoi.

## 15. Tables de la base de données

### Référentiels
| Table | Préfixe | Rôle |
|---|---|---|
| dd_variables | var | Rulesets et valeurs paramétrables — gérées via phpMyAdmin uniquement |
| dd_ressources | res | Livres/suppléments — gérés via zone admin |
| dd_caracteristiques | car | 6 caractéristiques DD |
| dd_modificateurs | mod | Modificateurs de caractéristiques |

### Utilisateurs
| Table | Préfixe | Rôle |
|---|---|---|
| dd_joueurs | j | Utilisateurs — gérés via zone admin |
| dd_joueurs_sources | js | Sélection sources par utilisateur |

### Compendium
| Table | Préfixe | Rôle | Ruleset |
|---|---|---|---|
| dd_races | ra | Races jouables | DD3.5 + DD2024 |
| dd_race_type | rat | Types de race | DD3.5 + DD2024 |
| dd_classes | cla | Classes de personnage | DD3.5 + DD2024 |
| dd_classe_niveau | cn | Table de bonus par niveau | DD3.5 + DD2024 |
| dd_capacites_speciales | cap | Capacités spéciales | DD3.5 + DD2024 |
| dd_classe_capacite | cc | Affectation capacité → niveau | DD3.5 + DD2024 |
| dd_typeMagie | mag | Types de magie | DD3.5 + DD2024 |
| dd_colleges | co | Collèges de magie | DD3.5 + DD2024 |
| dd_sorts | so | Sorts | DD3.5 + DD2024 |
| dd_sortclasse | sc | Sorts par classe | DD3.5 + DD2024 |
| dd_dons | do | Dons | DD3.5 + DD2024 |
| dd_data_don | dado | Catégories de dons | DD3.5 + DD2024 |
| dd_competences | comp | Compétences | DD3.5 + DD2024 |
| dd_historiques | hi | Historiques de personnage | **DD2024 uniquement** |
| dd_objets_magiques | om | Objets magiques | DD3.5 + DD2024 |
| dd_monstres | mo | Monstres (mo_stats texte brut, rendu à l'affichage) | DD3.5 + DD2024 |
| dd_monstres_categories | mocat | Catégories de monstres | DD3.5 + DD2024 |
| dd_monstres_groupes | mogr | Groupes de monstres | **DD2024 uniquement** |
| dd_fp | fp | Référentiel des facteurs de puissance (ordonne le filtre FP) | DD3.5 + DD2024 |

### Personnages
| Table | Préfixe | Rôle |
|---|---|---|
| dd_personnages | pe | Fiches personnages |
| dd_personnages_classes | pc | Classes du personnage |
| dd_personnages_nls | penl | NLS classes de prestige (DD3.5) |
| dd_personnages_sorts | pes | Sorts du personnage |
| dd_personnages_sorts_prepares | pesp | Sorts préparés |
| dd_personnages_competences | pec | Compétences du personnage |
| dd_personnages_dons | ped | Dons du personnage |

### Campagnes
| Table | Préfixe | Rôle |
|---|---|---|
| dd_campagnes | camp | Campagnes (1 ruleset maître, 0–1 univers via camp_un_id) |
| dd_campagnes_personnages | cp | Lien N-N personnage <-> campagne (cp_notes_mj réservé) |
| dd_campagnes_sources | cs | Sources actives d'une campagne (priorité 1) |
| dd_scenarios | sce | Scénarios (ruleset hérité de la campagne) |
| dd_scenarios_chapitres | scc | Chapitres |
| dd_rencontres | re | Rencontres (re_scc_id NOT NULL, re_composition littérale) |
| dd_oppositions | opp | Copie éditable d'un monstre, propre à une rencontre |
| dd_fichiers | fi | Pièces jointes PDF génériques (campagne/scénario/rencontre) |
| dd_campagnes_notes | cpno | RÉSERVÉ — hors UI cette version |
| dd_monstres | mo | Monstres-modèles (table principale décrite au §Compendium) |

### Wiki / Univers
| Table | Préfixe | Rôle |
|---|---|---|
| dd_univers | un | Univers wiki |
| dd_univers_droits | ud | Délégation droits édition |
| dd_univers_categories | uca | Catégories d'articles |
| dd_univers_articles | ua | Articles wiki |

### Règles (wiki de règles)
| Table | Préfixe | Rôle |
|---|---|---|
| dd_regles | reg | Chapitres et règles, hiérarchie récursive (reg_reg_id) — scoping ruleset seul |

> La table v1 `dd_categorie_regle` n'est pas portée : la hiérarchie récursive remplace la catégorisation.

### Notes
| Table | Préfixe | Rôle |
|---|---|---|
| dd_notes | no | Notes de jeu |
| dd_notes_contenus | noc | Blocs de contenu |
| dd_personnages_notes | pno | Note attribuée à un personnage |
| dd_tags | tag | Tags libres |
| dd_notes_tags | notag | Association notes <-> tags |

---

## 16. Éditeur de texte enrichi — TinyMCE

### Choix retenu

TinyMCE via CDN tiny.cloud. Clé API gratuite (inscription tiny.cloud requise, aucune contrainte commerciale pour usage personnel/non-commercial). Éditeur unique dans toute l'application — deux configurations selon le contexte.

### Intégration CDN

La clé API est stockée dans include/db.php :

```php
define('TINYMCE_API_KEY', 'votre_cle_api');
```

Chargement dans les pages qui en ont besoin (pas dans header.php — uniquement sur les pages avec formulaire) :

```html
<script src="https://cdn.tiny.cloud/1/<?= TINYMCE_API_KEY ?>/tinymce/7/tinymce.min.js"
        referrerpolicy="origin"></script>
```

### Configuration minimale — sans images

Pour : sorts, dons, classes, races, compétences, historiques.

```javascript
tinymce.init({
  selector: '.tinymce-basic',
  language: 'fr_FR',
  menubar: false,
  plugins: 'lists link',
  toolbar: 'bold italic underline | bullist numlist | h2 h3 | link | removeformat',
  height: 300,
  skin: 'oxide-dark',
});
```

### Configuration complète — avec images

Pour : wiki/univers (articles), personnages (background, notes).

```javascript
tinymce.init({
  selector: '.tinymce-full',
  language: 'fr_FR',
  menubar: false,
  plugins: 'lists link image table',
  toolbar: 'bold italic underline | bullist numlist | h2 h3 | link image table | removeformat',
  height: 400,
  skin: 'oxide-dark',
  images_upload_url: BASE_URL + '/include/ajax/upload-image.php',
  images_upload_credentials: true,
  automatic_uploads: true,
});
```

### Configuration règles — listes + tables, sans images

Pour : module Règles (chapitres et règles). Les règles DD comportent de nombreuses tables
(degrés de difficulté, modificateurs de caractéristique, allure de voyage, abris…).

```javascript
tinymce.init({
  selector: '.tinymce-regle',
  language: 'fr_FR',
  menubar: false,
  plugins: 'lists link table',
  toolbar: 'bold italic underline | bullist numlist | h2 h3 | table | link | removeformat',
  height: 360,
  skin: 'oxide-dark',
});
```

### Endpoint upload images

Fichier : include/ajax/upload-image.php
Répertoire : img/uploads/ (permissions 755, dans .gitignore)
Retourne : { "location": "URL_du_fichier" }
Validation : type MIME (jpg/png/gif/webp), taille max 5Mo, renommage par hash.

### Affichage du contenu TinyMCE

Le HTML généré est stocké dans les champs TEXT/LONGTEXT et affiché tel quel.
Ne pas passer par h() — utiliser directement la valeur.
Sécurité : contenu produit uniquement par des utilisateurs authentifiés.

### Soumission formulaire AJAX

```javascript
tinymce.triggerSave(); // synchronise tous les éditeurs avant fetch()
```

---

## 17. Checklist avant chaque merge

- [ ] Aucun write AJAX dans *-modifier.php
- [ ] Payload hidden complet et cohérent au submit
- [ ] Validations serveur couvrent les cas invalides
- [ ] Transaction PDO active sur *-enregistrement.php
- [ ] ownerFilter() appliqué sur toutes les requêtes de liste
- [ ] h() sur toutes les sorties HTML
- [ ] CSRF token vérifié sur tous les POST
- [ ] Aucune URL absolue codée en dur — BASE_URL utilisé partout
- [ ] Templates ruleset sans logique auth/session
- [ ] rulesetRep validé via whitelist avant inclusion template
- [ ] Responsive testé sur les modules concernés (hors Campagnes)
- [ ] $css_module défini dans chaque contrôleur de module
- [ ] Compendium : colonne de tri validée par whitelist avant ORDER BY
- [ ] Compendium : _detailPpContext correctement passé à actualiserPage()
- [ ] Compendium : enregistrement.php?ajax=1 retourne JSON, mode normal retourne redirect
- [ ] Compendium : historiques.php et ses endpoints conditionnés au ruleset DD2024
- [ ] Admin : requireAdmin() en tête de chaque page admin/
- [ ] Admin : suppression utilisateur = désactivation j_visible=0, jamais DELETE
- [ ] Admin : suppression ressource = vérification préalable sur les 7 tables compendium
- [ ] TinyMCE : triggerSave() appelé avant tout submit AJAX
- [ ] TinyMCE : champs description/contenu affichés sans h()
- [ ] Règles : module n'utilise PAS compendium-liste.php (scoping ruleset seul, pas de sources)
- [ ] Règles : Précédent/Suivant calculés par reglesOrdreLecture() (DFS), pas de colonne globale
- [ ] Règles : parent validé anti-cycle (≠ soi-même, ≠ descendant) à l'enregistrement
- [ ] Règles : recherche FULLTEXT scope ruleset actif + reg_camp_id IS NULL, fallback LIKE
- [ ] Règles : édition réservée à canEditCompendium(), consultation par tout utilisateur
- [ ] Règles (DD2024) : termes de glossaire = nœuds reg_type='glossaire' (enfants du chapitre Glossaire)
- [ ] Règles (DD2024) : renvois = ancres `.glossaire-lien[data-glossaire-slug]` dans reg_texte (jamais d'auto-détection au rendu)
- [ ] Règles (DD2024) : clic renvoi → actualiserPageSub() vers detail-pp-sub/glossaire.php (sous-panneau existant réutilisé)
- [ ] Règles (DD2024) : renvoi imbriqué = remplacement sur place du #detail-pp-sub, pas d'empilement
- [ ] Règles : reg_type whitelisté côté serveur ('chapitre','regle','glossaire')
- [ ] img/uploads/ exclu du repo (.gitignore)
- [ ] Thèmes : toute nouvelle variable CSS définie dans body.theme-dark ET body.theme-light
- [ ] Thèmes : aucun fallback de couleur hardcodé dans les composants (ex: #f5efe6) — utiliser uniquement des var()
- [ ] Thèmes : --clr-surface-alt défini dans les deux thèmes si utilisé dans un composant