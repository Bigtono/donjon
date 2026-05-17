# Codex DD v2 — Document de référence architecture

> Source de vérité pour tous les développements.
> À ouvrir dans VS Code à chaque session pour contextualiser Claude Code.
> Dernière mise à jour : Mise en page — Système de thèmes (dark/light) + fix table-classe-niv + overlays élargis

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

- Un personnage possède obligatoirement une race et au moins une classe
- DD3.5 : race de base + archétype optionnel, classes de prestige, NLS (dd_personnages_nls)
- DD2024 : pas d'archétype, pas de classes de prestige (pe_arc_id = 0)
- Notes MJ : dd_campagnes_personnages.cp_notes_mj (perdues si le personnage quitte la campagne)

---

## 8. Module Campagnes

Hiérarchie : Campagne → Scénarios → Chapitres → Rencontres → Monstres
Liaison personnages via dd_campagnes_personnages.
Module NON responsive — usage desktop exclusif.

---

## 9. Module Wiki / Univers

Univers (public/privé) → Catégories → Articles (visible/caché)
Délégation droits via dd_univers_droits. En v1 : globale sur l'univers entier.

---

## 10. Responsive

| Module | Responsive | Notes |
|---|---|---|
| Compendium | Oui | col-primary/secondary/action, pas de boutons action mobile |
| Personnages | Oui | |
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
  personnages/     fiche.php, modifier.php, enregistrement.php
  compendium/      sorts.php, classes.php, dons.php, races.php,
                   competences.php, objets.php,
                   historiques.php   (DD2024 uniquement)
                   enregistrement.php
  campagnes/       campagne.php, scenario.php, rencontres.php
  wiki/            univers.php, articles.php
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
    profil.js
    admin.js         (Phase admin — clone adapté de compendium.js)
  css/
    main.css                  variables par thème (body.theme-dark/light), layout, composants transverses
    modules.css               styles globaux (login, dashboard, profil, header, sélecteur thème)
    compendium-modules.css    styles compendium — chargé si $css_module = 'compendium'
    personnages-modules.css   (Phase 3) — chargé si $css_module = 'personnages'
    campagnes-modules.css     (Phase 4) — chargé si $css_module = 'campagnes'
    wiki-modules.css          (Phase 5) — chargé si $css_module = 'wiki'
    admin-modules.css         chargé si $css_module = 'admin'
  include/
    db.php           PDO + BASE_URL + DEV_MODE
    auth.php         + chargement j_theme en session
    helpers.php
    header.php       classe theme-{dark|light} sur body + charge $css_module-modules.css et $js_module.js
    footer.php
    compendium-liste.php    moteur de liste commun compendium (lit $listConfig)
    admin-liste.php         moteur de liste commun admin (lit $adminListConfig)
    ajax/
      detail-pp/     sort.php, classe.php, don.php, race.php, historique.php...
                     utilisateur.php, ressource.php   (admin)
      modifier/      sort.php, classe.php, don.php, race.php, historique.php...
                     utilisateur.php, ressource.php   (admin)
    insert/
      DD3.5/
      DD2024/
  sql/
    schema.sql
    patch_001_reset_password.sql
    patch_002_theme.sql        ← ALTER TABLE dd_joueurs ADD j_theme
  img/
    uploads/               dépôt fichiers uploadés via TinyMCE (755)
  doc/
    ARCHITECTURE_0_REFERENCE.md
    DECISIONS_LOG.md
    SCHEMA_SQL.md
    ARCHITECTURE_2_SORTS.md
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
- Pages : sorts, classes, dons, races, competences, objets, historiques (DD2024)
- AJAX detail-pp et modifier pour chaque entité
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
Campagne, scénarios, chapitres, rencontres, monstres, personnages invités.

### Phase 5 — Wiki / Univers
Univers, catégories, articles, délégation, lien univers <-> campagne.

---

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
| dd_campagnes | camp | Campagnes |
| dd_campagnes_personnages | cp | Lien personnage <-> campagne + notes MJ |
| dd_campagnes_sources | cs | Sources actives d'une campagne |
| dd_campagnes_univers | cu | Lien campagne <-> univers |
| dd_campagnes_notes | cpno | Note rattachée à une campagne |
| dd_scenarios | sce | Scénarios |
| dd_scenarios_chapitres | scc | Chapitres |
| dd_rencontres | re | Rencontres |
| dd_rencontres_monstres | rem | Monstres d'une rencontre |
| dd_monstres | mo | Monstres |

### Wiki / Univers
| Table | Préfixe | Rôle |
|---|---|---|
| dd_univers | un | Univers wiki |
| dd_univers_droits | ud | Délégation droits édition |
| dd_univers_categories | uca | Catégories d'articles |
| dd_univers_articles | ua | Articles wiki |

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
- [ ] img/uploads/ exclu du repo (.gitignore)
- [ ] Thèmes : toute nouvelle variable CSS définie dans body.theme-dark ET body.theme-light
- [ ] Thèmes : aucun fallback de couleur hardcodé dans les composants (ex: #f5efe6) — utiliser uniquement des var()
- [ ] Thèmes : --clr-surface-alt défini dans les deux thèmes si utilisé dans un composant
