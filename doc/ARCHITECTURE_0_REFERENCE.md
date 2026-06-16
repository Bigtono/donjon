<!-- Mis à jour : 2026-06-15 14:30 -->

# Codex DD v2 — Document de référence architecture

> Source de vérité pour tous les développements.
> À ouvrir dans VS Code à chaque session pour contextualiser Claude Code.
> Dernière mise à jour : Phase 2 SP-C — conception supplément utilisateur validée (plan SP-C0→SP-C7) ; Phase 3 sous-phase 3.2 livrée (éditeur Classes inline + domaines divins DD3.5)

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
| Gestionnaire compendium | j_compendium_manager = 1 | Édition compendium global + propre supplément |
| Utilisateur standard | par défaut | Ses propres données uniquement |
| MJ | contextuel : camp_j_id = session j_id | Données de sa campagne + personnages invités |

Le rôle MJ est contextuel — tout utilisateur devient MJ dès qu'il crée une campagne ou un univers.

### Règle de filtrage propriétaire

Toute requête sur données utilisateur : WHERE [prefix]_j_id = :user_id, sauf si admin.
Encapsulé dans ownerFilter() dans include/helpers.php.

### Fonctions d'autorisation compendium

**`canEditCompendium()`** (auth.php) — contrôle global :
- Retourne true si admin ou j_compendium_manager
- Conditionne l'affichage du bouton "Ajouter" et de la barre bulk
- Inchangée par la feature supplément

**`canEditCompendiumEntry($db, ?int $res_j_id)`** (helpers.php) — contrôle per-entry :
- Retourne true si admin
- Retourne true si `res_j_id IS NULL` (ressource officielle) + `j_compendium_manager`
- Retourne true si `res_j_id === j_id` courant (propre supplément)
- Retourne false si `res_j_id` est celui d'un autre utilisateur (même admin du compendium)
- Utilisée dans : menu ⋮ per-row dans `compendium-liste.php`, bouton Modifier dans `detail-pp/*.php`, garde de save dans `enregistrement.php`

### Visibilité des données par module

| Module | Règle |
|---|---|
| Compendium officiel | Visible par tous les utilisateurs connectés |
| Compendium — Supplément utilisateur | Propriétaire : voit tout (public + privé + brouillons). Autres avec supplément sélectionné : uniquement les entrées `_public=1 AND _visible=1`. |
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

1. **Compendium global** : admin + gestionnaires délégués (j_compendium_manager = 1). Visible par tous.
2. **Contenu homebrew campagne** : créé par le MJ via _camp_id. Mêmes formulaires + champ caché _camp_id. Visible MJ + joueurs de la campagne.
3. **Supplément utilisateur** : tout j_compendium_manager peut créer ses propres entrées rattachées à sa source "Supplément de {pseudo}". Voir § Supplément utilisateur ci-dessous.

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
   inclut désormais le supplément de l'utilisateur (auto-ajouté à la création)
3. Toutes les sources actives du ruleset (défaut absolu — res_j_id IS NULL uniquement)
```

### Architecture des pages du compendium — moteur de liste commun

Toutes les pages du compendium partagent la même structure et le même moteur.

Principe : chaque page déclare $listConfig puis délègue tout le rendu à include/compendium-liste.php.

Exemple de $listConfig (sorts.php) :

```php
$listConfig = [
  'entite'        => 'sort',
  'titre'         => 'Sorts',
  'from'          => 'dd_sorts so LEFT JOIN dd_colleges co ON co.co_id = so.so_co_id',
  'champ_id'      => 'so.so_id',
  'champ_res'     => 'so.so_res_id',
  'champ_ruleset' => 'so.so_ruleset_var_id',
  'champ_public'  => 'so.so_public',   // Supplément : champ _public
  'champ_visible' => 'so.so_visible',  // Supplément : champ _visible
  'colonnes'      => [
    ['sql' => 'so.so_nom',    'champ' => 'so_nom',    'label' => 'Nom',   'mobile' => true,  'tri' => true],
    ['sql' => 'so.so_niveau', 'champ' => 'so_niveau', 'label' => 'Niv.', 'mobile' => false, 'tri' => true],
    ['sql' => 'co.co_nom',    'champ' => 'co_nom',    'label' => 'Ecole', 'mobile' => false, 'tri' => true],
  ],
  'filtres'       => $filtres_specifiques,
  'url_detail'    => BASE_URL . '/include/ajax/detail-pp/sort.php',
  'url_modifier'  => BASE_URL . '/include/ajax/modifier/sort.php',
  'url_enreg'     => BASE_URL . '/compendium/enregistrement.php',
  'bulk_actions'  => [
    ['valeur' => 'supprimer', 'label' => 'Supprimer la selection'],
  ],
];
require_once '../include/header.php';
require_once '../include/compendium-liste.php';
require_once '../include/footer.php';
```

**Clés `$listConfig` relatives au supplément :**

| Clé | Type | Valeur | Comportement |
|---|---|---|---|
| `champ_public` | string | `'so.so_public'` | Référence SQL du champ `_public` |
| `champ_visible` | string | `'so.so_visible'` | Référence SQL du champ `_visible` |
| `champ_public` | false | — | Pas de filtre supplément (entité sans supplément) |

Si `champ_public` et `champ_visible` sont absents ou à `false`, le moteur se comporte exactement comme avant (rétro-compatible).

Séquence d'exécution de compendium-liste.php :
1. Lit GET : colonne de tri, direction, valeurs des filtres, page courante
2. Valide la colonne de tri par whitelist (colonnes avec tri = true)
3. Appelle getActiveResIds() → base sources active
4. Intersecte avec filtre sources GET si présent
5. Construit WHERE : texte libre + filtres spécifiques + sources
6. **Si champ_public déclaré : ajoute JOIN dd_ressources + filtre visibilité supplément**
7. Construit ORDER BY sécurisé
8. Exécute COUNT(*) → calcule pagination
9. Exécute SELECT avec LIMIT/OFFSET (inclut res.res_j_id AS _res_j_id si supplément)
10. Rend le HTML : zone filtre + tableau + pagination + barre bulk

### Structure de chaque page liste

Zone filtre :
  - INPUT texte libre (toujours premier)
  - Critères métier spécifiques à chaque page (certains conditionnels par ruleset)
  - **Toggle "Afficher mes brouillons"** (checkbox, visible uniquement si l'utilisateur a un supplément avec des entrées `_visible=0`)
  - SELECT sources multiple (toujours dernier — restreint dans la sélection active)

Tableau :
  - Checkbox | Menu ligne | col-primary (+ badge homebrew si _res_j_id IS NOT NULL) | col-secondary...

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

### Badge homebrew

Les lignes de supplément (`_res_j_id IS NOT NULL`) reçoivent la classe CSS `comp-ligne--homebrew` sur le `<tr>`.
Une icône indicateur est injectée dans `col-primary` pour signaler visuellement le contenu de supplément.
Styles dans `compendium-modules.css`.

### Confirmation de suppression

Div inline remplaçant temporairement la ligne dans le tableau. Pas de window.confirm().

### Fichiers du compendium

```
compendium/
  sorts.php, classes.php, dons.php, races.php, competences.php, objets.php
  historiques.php   (DD2024 uniquement — conditionné par ruleset en session)
  monstres.php
  enregistrement.php  (POST commun + mode ?ajax=1)

include/
  compendium-liste.php   (moteur commun)
  ajax/detail-pp/        (sort.php, classe.php, don.php, race.php, competence.php, historique.php, objet.php, monstre.php...)
  ajax/modifier/         (sort.php, classe.php, don.php, race.php, competence.php, historique.php, objet.php, monstre.php...)
```

> ⚠️ La page `compendium/historiques.php` (et ses endpoints AJAX) ne doit être accessible
> et affichée dans le menu que si `$_SESSION['rulesetRep'] === 'DD2024'`.

### enregistrement.php — mode AJAX

Détecte $_GET['ajax'] et retourne JSON {ok, id, url_detail} pour les saves individuels.
Mode normal (bulk) : redirect + flash message SESSION.

### Supplément utilisateur

#### Principe général

Tout `j_compendium_manager` peut créer ses propres entrées dans n'importe quelle section du compendium,
rattachées à sa source personnelle "Supplément de {pseudo}". Le supplément est une entrée `dd_ressources`
avec `res_j_id = j_id` et `res_camp_id IS NULL`. **1 supplément par utilisateur par ruleset.**

Le supplément est créé automatiquement (`getOrCreateUserSupplement($db, $j_id, $ruleset_var_id)`)
lors du premier save d'une entrée de supplément, puis auto-ajouté dans `dd_joueurs_sources`.

#### Droits d'édition per-entry

Voir `canEditCompendiumEntry()` au §4. Résumé :
- Seul le propriétaire peut modifier ses entrées de supplément (+ admin).
- Un autre `j_compendium_manager` ne peut PAS modifier le supplément d'autrui.

#### Visibilité des entrées

| `_public` | `_visible` | Qui voit l'entrée dans les listes |
|---|---|---|
| 0 | 1 | Propriétaire uniquement (privé normal — état par défaut) |
| 0 | 0 | Brouillon masqué — accessible via toggle "Afficher mes brouillons" |
| 1 | 1 | Tous les utilisateurs ayant le supplément sélectionné comme source |
| 1 | 0 | **INTERDIT** — contrainte UI + serveur |

Le propriétaire voit toujours toutes ses entrées (y compris les brouillons `_visible=0`) via le toggle dédié dans la barre de filtre.

#### Filtre visibilité dans le moteur de liste

```sql
AND (
  res.res_j_id IS NULL                           -- officiel : toujours
  OR res.res_j_id = :uid                          -- propriétaire : toujours (brouillons inclus)
  OR ({champ_public} = 1 AND {champ_visible} = 1) -- supplément partagé
)
```

Activé automatiquement par le moteur `compendium-liste.php` quand `champ_public` et `champ_visible` sont déclarés dans `$listConfig`.

#### Supplément comme source sélectionnable

- Auto-ajouté dans `dd_joueurs_sources` du propriétaire dès sa création.
- Visible dans "Mes sources" d'autres utilisateurs uniquement si ≥1 entrée est publique et visible.
- Ajout à une campagne : **manuel** (via la configuration des sources de la campagne).
- La priorité 3 de `getActiveResIds()` (défaut absolu) reste limitée aux ressources officielles (`res_j_id IS NULL`).

#### Helpers dédiés dans `helpers.php`

```php
// Retourne le res_id du supplément (null si non créé)
getUserSupplementResId($db, int $j_id, int $ruleset_var_id): ?int

// Crée le supplément si absent + auto-add dd_joueurs_sources, retourne res_id
getOrCreateUserSupplement($db, int $j_id, int $ruleset_var_id): int
```

---

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
| `mo_res_id` | Source (obligatoire) → `dd_ressources` (officielle ou supplément utilisateur) |
| `mo_camp_id` | Homebrew de campagne (NULL = officiel ou supplément) |
| `mo_public` | 0 = privé, 1 = partagé (supplément uniquement) |
| `mo_visible` | 0 = brouillon masqué, 1 = visible (supplément uniquement) |
| `mo_ruleset_var_id` | Ruleset → `dd_variables` |

> **`mo_j_id` supprimé.** La propriété et la visibilité des monstres sont désormais gérées via
> `mo_res_id` (supplément) et `mo_camp_id` (homebrew campagne), alignées sur le mécanisme commun
> à toutes les entités du compendium. Migration via `patch_004_supplements.sql`.

> ⚠️ **Écart schéma SQL / code à régulariser.** `sql/schema.sql` et le dump `sql/maikasteiymaika.sql` ne
> reflètent pas encore `mo_mocat_id`, `mo_mogr_id`, `mo_res_id`, `mo_camp_id`, `mo_public`, `mo_visible`
> ni les tables `dd_monstres_categories`, `dd_monstres_groupes`, `dd_fp`. La base réelle est à jour ;
> les fichiers SQL versionnés sont à resynchroniser.

**Visibilité — mécanisme unifié.** Portée par le moteur commun via `champ_public`/`champ_visible` dans `$listConfig`.
Le filtre `extra_where` spécifique `(mo.mo_j_id IS NULL OR mo.mo_j_id = $uid)` est supprimé.

#### Liaison des entités — deux mécanismes complémentaires

**1. Tags explicites (prioritaires, résolus en pré-passe `resoudreTagsExplicites()`)** :

| Tag | Cible | Résolution |
|---|---|---|
| `#Nom du don#` | `dd_dons` | par **nom** (index, insensible casse/accents) |
| `$Nom du sort$` | `dd_sorts` | par **nom** |
| `@id@` | `dd_regles` (tout type) | par **id** |
| `%id%` | `dd_regles` `reg_type='glossaire'` | par **id** |

**2. Liaison automatique (`lierAuto()`) — limitée à sorts + glossaire.** Sur le texte libre,
une passe relie automatiquement les **sorts** et les **termes de glossaire** via un index fusionné
(`construireIndexAuto()`, priorité sort > glossaire). Garde-fous : normalisation casse/accents,
plus longue correspondance d'abord, longueur minimale `MO_LONGUEUR_MIN = 4`.

#### Dictionnaire — registre `typesLiablesMonstre()`

Registre déclaratif décrivant les types chargés **par nom** : `don` et `sort` (table, id, nom,
colonnes ruleset/res/camp). Le **glossaire** est chargé séparément depuis `dd_regles`. Chargement
(`chargerIndexMonstre()`) scopé : **ruleset courant + sources actives (`getActiveResIds()`) +
`camp IS NULL`**.

#### Rendu par ruleset

- **DD2024** (`formaterBlocDD2024()` + `classerLigneDD2024()`) : classification ligne par ligne —
  en-tête / ligne de **caractéristiques** (grille 3×2 via `rendreTableauCarac()`),
  **titre de section**, **label inline**, **label gras**, **sous-liste de sorts**, **pouvoir**, ligne simple.
- **DD3.5** (`formaterLigneDD35()`) : labels terminés par « : ». Ligne « Dons : » → liaison dons ;
  autres → liaison auto (sorts + glossaire). Parsing automatique DD3.5 **minimal — à compléter**.

Séparateur de blocs commun : une ligne `***` → `<hr class="mo-stat-hr">`.

#### Sortie découplée du JS et résolution des liens

```html
<span class="mo-lien" data-type="sort" data-id="42">Boule de feu</span>
```

| `data-type` | Action |
|---|---|
| `regle` | ouverture de `regles/regle.php?id=…` dans un **nouvel onglet** |
| `glossaire` | `actualiserPageSub()` → `detail-pp-sub/glossaire.php` (sous-panneau) |
| `don` / `sort` | `actualiserPageSub()` → endpoint `detail-pp` du type |

#### Formulaire et autocomplétion des tags

`include/ajax/modifier/monstre.php` : `<textarea>` brut + popup d'**autocomplétion clavier** des
tags `@` (règle) et `%` (glossaire), alimentée par `include/ajax/autocomplete-tags-monstre.php`.
Champs : `mo_nom`, `mo_mocat_id`, `mo_mogr_id`, `mo_fp_id`, `mo_res_id`, `mo_camp_id`,
`mo_public`, `mo_visible`, `mo_stats`.

> Une ancienne version `include/ajax/modifier/monstre-old.php` subsiste dans le dépôt — à supprimer
> une fois le v3 stabilisé.

#### Fichiers du module

```
compendium/monstres.php                     # contrôleur liste + $listConfig (champ_public/champ_visible)
compendium/enregistrement.php               # case 'monstre' / enregistrerMonstre() (stockage brut)
include/monstre-parser.php                  # moteur d'analyse + rendu (v3) — rendreStatsMonstre()
include/ajax/detail-pp/monstre.php          # fiche détail (#detail-pp) — appelle rendreStatsMonstre()
include/ajax/modifier/monstre.php           # formulaire (textarea + autocomplete tags + _public/_visible)
include/ajax/autocomplete-tags-monstre.php  # suggestions tags @ (règle) / % (glossaire)
js/compendium.js                            # gestionnaire délégué .mo-lien (résolution data-*)
css/compendium-modules.css                  # styles .mo-stats / .mo-lien / grille carac / .comp-ligne--homebrew
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

Les utilisateurs désactivés restent visibles dans la liste (indicateur visuel) avec une action "Réactiver".

**Bulk actions :** Désactiver la sélection.

**Formulaire modifier (overlay) :**
- Prénom, Nom, Pseudo, Email
- Droits : j_admin (checkbox), j_compendium_manager (checkbox)
- Mot de passe : champ obligatoire en mode **ajout** uniquement ; absent en mode édition

### B — Gestion des ressources

**Colonnes de la liste** (les compteurs sont calculés par sous-requêtes SQL) :

| # | Classe CSS | Contenu | Source SQL |
|---|---|---|---|
| 0 | bulk-check | Checkbox | — |
| 1 | col-action | Menu ⋮ : Modifier / Supprimer | — |
| 2 | col-primary | Nom | res_nom |
| 3 | col-secondary | Abréviation | res_abreviation |
| 4 | col-secondary | Ruleset | var_valeur via JOIN dd_variables |
| 5 | col-secondary | Propriétaire | j_pseudo si res_j_id IS NOT NULL (supplément) |
| 6 | col-secondary | Nb sorts | COUNT dd_sorts WHERE so_res_id |

**Règle de suppression :** Une ressource ne peut être supprimée que si **aucune** des tables
du compendium ne lui est rattachée. La vérification porte sur l'ensemble du périmètre :

```
dd_classes, dd_races, dd_sorts, dd_dons, dd_competences, dd_historiques, dd_objets_magiques
```

Si des données existent, la suppression est refusée avec un message explicite.

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

### 7.4 Liste des personnages — `personnages/index.php`

Liste dédiée (pas le moteur `compendium-liste.php`) calquée sur `campagnes/index.php`. Filtrage strict par
propriétaire (`pe_j_id = j_id`) et par **ruleset actif en session**.

**Filtres** (GET) :
- **Campagne** — select des campagnes du joueur (ruleset courant). Sémantique : `pe.pe_camp_id = ?`.
- **Classe** — select de toutes les classes du ruleset. Sémantique : `EXISTS (… dd_personnages_classes …)`.
- **Recherche libre** — `pe.pe_nom LIKE ?` (% en début et fin).

**Colonnes desktop** : ⋮ · Nom · Race · Classes · Alignement · Campagne en cours.

**Responsive** (< 992px) : seul le **nom** apparaît sur la première ligne ; race, classes, alignement et campagne
sont concaténés dans un résumé `text-muted` sur la ligne suivante.

### 7.5 Édition — commit global

L'édition passe par l'**overlay AJAX** `include/ajax/modifier/personnage.php` (pattern projet). L'overlay est
**local** (DOM/JS), **zéro écriture BDD**. Toute la persistance est centralisée dans `personnages/enregistrement.php`.

- **Identité** : formulaire classique. Background / notes via TinyMCE (config complète, avec images).
- **Classes / niveaux** : éditeur DOM déclaratif (nom de classe + niveau + domaines divins DD3.5), sans validation de règles.
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
règles métier et aident réellement en séance.

```
NLS effectif = niveau de classe de base
             + bonus des classes de prestige (dd_personnages_nls, selon cn_niveauSortArcane/Divin/Effectif)
Emplacements = dd_classe_niveau.cn_sort_n0..9 (au NLS effectif)
             + dd_modificateurs.mod_bonusSort0..9 (bonus de la caractéristique de classe)
             + 1 par niveau de sort > 0 si la classe choisit des domaines divins (DD3.5)
```

DD2024 : nombre de sorts préparés via `cn_sortPrepare` ; bonus de maîtrise via `dd_bonus_maitrise`.

### 7.8 Stockage des sorts

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

- **3.0** Socle + SQL — *livrée*
- **3.1** Fiche identité (nom, race, archétype DD3.5, historique DD2024, sexe, alignement, caracs, combat) + première classe à la création — *livrée*
- **3.2** Classes & niveaux (éditeur multi-classes complet inline sur la fiche, domaines divins DD3.5) — *livrée*
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
- **Rencontre** : rattachement à un chapitre **obligatoire** (`re_scc_id` NOT NULL).
  Effectifs décrits **littéralement** dans `re_composition` (texte).
- **Opposition** : copie **éditable** d'un monstre du compendium (`dd_oppositions`), propre à une
  rencontre (lien 1-N `opp_re_id`). Le monstre modèle (`opp_mo_id`) est figé pour traçabilité.
- **Duplication** : scénario / rencontre / opposition duplicables (suffixe « - copie »), en cascade
  descendante, **limitée au ruleset courant**.
- **Pièces jointes** : PDF uniquement, table générique `dd_fichiers`.
- **Suppression douce** (flag `_supprime`, cascade application, unlink PDF, pas d'UI restauration).

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

### Schéma de la table dd_regles

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| reg_id | int unsigned | PK | |
| reg_reg_id | int unsigned | null | Parent récursif -> dd_regles ; NULL = racine |
| reg_type | enum('chapitre','regle','glossaire') | nn, défaut 'regle' | |
| reg_nom | varchar(200) | nn | Titre |
| reg_slug | varchar(220) | nn, UK(reg_slug, reg_ruleset_var_id) | Version URL-safe |
| reg_texte | longtext | null | Contenu HTML (TinyMCE) |
| reg_ordre | smallint unsigned | nn, défaut 0 | Ordre parmi les frères |
| reg_ruleset_var_id | int unsigned | nn | -> dd_variables |
| reg_camp_id | int unsigned | null | **RÉSERVÉ** house rules futures |
| reg_visible | tinyint(1) | nn, défaut 1 | 0 = brouillon/masqué |
| reg_date_creation | datetime | nn | |
| reg_date_modif | datetime | nn | |

### Périmètre / scoping

- Scoping **ruleset uniquement** (`reg_ruleset_var_id`). Le moteur `compendium-liste.php` **ne s'applique pas** à ce module.
- `reg_camp_id` (nullable) est **réservé** pour de futures *house rules* de campagne.

### Droits d'édition

Même portail que le compendium global : édition réservée à `admin` + `j_compendium_manager`
(via `canEditCompendium()`). Consultation : tout utilisateur authentifié.

### Navigation « comme un livre »

1. **Sommaire / arbre** (`regles/index.php`) — arbre récursif repliable du ruleset actif.
2. **Fil d'Ariane (breadcrumb)** — sur la vue lecture.
3. **Précédent / Suivant (ordre de lecture)** — calculés sur l'**ordre de lecture linéarisé** (DFS).

### Glossaire DD2024 et renvois cliquables

Termes = nœuds `dd_regles` (`reg_type = 'glossaire'`). Renvois = ancres `.glossaire-lien[data-glossaire-slug]`
dans `reg_texte`. Clic → `actualiserPageSub()` vers `detail-pp-sub/glossaire.php` (sous-panneau).

### Fichiers du module

```
regles/
  index.php, regle.php, recherche.php, enregistrement.php

include/
  regles-arbre.php
  ajax/
    detail-pp/regle.php
    detail-pp-sub/glossaire.php
    modifier/regle.php

css/regles-modules.css
js/regles.js
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

L'utilisateur peut choisir, pour le ruleset actif, quelles ressources alimentent son compendium.
Cette sélection correspond à la priorité 2 de getActiveResIds().

**Périmètre affiché :**
- Ressources globales officielles du ruleset actif (`res_j_id IS NULL`)
- Suppléments publics d'autres utilisateurs (section distincte) — visibles uniquement si ≥1 entrée est `_public=1 AND _visible=1`

Le supplément de l'utilisateur lui-même **n'apparaît pas** dans cette section (il est auto-sélectionné via `dd_joueurs_sources`).

**Comportement zéro sélection :** autorisé. getActiveResIds() retombe sur la priorité 3 (res_selection = 1).

**Sauvegarde :** DELETE + INSERT en bloc dans `dd_joueurs_sources`.

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

### Variable CSS --clr-surface-alt

`--clr-surface-alt` est définie dans chaque thème pour les composants qui nécessitent
une surface légèrement différente de `--clr-surface-2`. Ne pas utiliser de fallback hardcodé.

### Overlays — largeurs

| Composant | max-width |
|---|---|
| .overlay-panel (detail-pp) | 960px |
| .overlay-panel--edit (modification) | 1040px |

---

## 12. Patterns d'interface

### detail-pp — contexte d'ouverture

detail-pp peut être ouvert depuis deux contextes :
- 'liste' : depuis une page liste du compendium
- 'externe' : depuis toute autre page (fiche personnage, scénario...) — DEFAUT

### Bouton Modifier dans detail-pp

Le HTML de detail-pp contient le bouton Modifier si `canEditCompendiumEntry($db, $res_j_id)` (vérification serveur, per-entry).
Pour les entités non compendium (personnages, campagnes), la vérification reste spécifique au module.

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

### Système d'overlays empilés — #detail-pp, #modification, #detail-pp-sub

| Conteneur | Backdrop | Rôle | Écriture BDD |
|---|---|---|---|
| `#detail-pp` | `#detail-pp-backdrop` | Panneau de détail principal (lecture) | Non |
| `#modification` | `#modification-backdrop` | Formulaire d'édition (overlay) | Non |
| `#detail-pp-sub` | `#detail-pp-sub-backdrop` | **Sous-panneau** affiché AU-DESSUS de `#detail-pp` | Non — lecture seule |

**API JavaScript (main.js) :**

```javascript
actualiserPageSub(url, params = {});  // Ouvre/rafraîchit le sous-panneau
fermerSubPanel();                     // Ferme le sous-panneau uniquement
fermerDetailPP();                     // Ferme #detail-pp + cascade modification + sous-panneau
```

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
    index.php
    utilisateurs.php
    ressources.php
    enregistrement.php
  js/
    main.js          togglePlus, actualiserPage, _detailPpContext,
                     apresModification, rafraichirListe, CSRF
    personnage.js
    compendium.js    toggleSort, submitFiltre, bulk, confirmerSuppression inline
    campagne.js
    wiki.js
    regles.js
    profil.js
    admin.js
  css/
    main.css                  variables par thème (body.theme-dark/light), layout, composants transverses
    modules.css               styles globaux (login, dashboard, profil, header, sélecteur thème)
    compendium-modules.css    styles compendium (liste, detail-pp, badge homebrew)
    personnages-modules.css   (Phase 3)
    campagnes-modules.css     (Phase 4)
    wiki-modules.css          (Phase 5)
    regles-modules.css
    admin-modules.css
  include/
    db.php           PDO + BASE_URL + DEV_MODE
    auth.php         + canEditCompendium() + chargement j_theme en session
    helpers.php      + canEditCompendiumEntry() + getOrCreateUserSupplement() + getUserSupplementResId()
    header.php
    footer.php
    compendium-liste.php    moteur de liste commun compendium (lit $listConfig)
    admin-liste.php
    regles-arbre.php
    monstre-parser.php      moteur d'analyse + rendu du bloc de stats monstre (v3)
    personnage_helpers.php
    ajax/
      detail-pp/     sort.php, classe.php, don.php, race.php, historique.php,
                     objet.php, monstre.php, ...
      detail-pp-sub/ glossaire.php
      modifier/      sort.php, classe.php, don.php, race.php, historique.php,
                     objet.php, monstre.php, regle.php, ...
      autocomplete-tags-monstre.php
  sql/
    schema.sql
    patch_001_reset_password.sql
    patch_004_supplements.sql   ← 8 ALTER TABLE (_public/_visible) + migration mo_j_id
  uploads/
  img/
    uploads/
  doc/
    ARCHITECTURE_0_REFERENCE.md
    DECISIONS_LOG.md
    SCHEMA_SQL.md
    METIER_*.md
```

---

## 14. Plan de développement

### Phase 1 — Socle technique TERMINE
Auth, session, helpers, header/footer, dashboard, profil, reset MDP, CSS design system.

### Phase 2 — Compendium EN COURS (sorts, dons, compétences, classes, races, objets, monstres, historiques)
- include/compendium-liste.php — moteur commun
- compendium/enregistrement.php — POST commun + mode AJAX
- js/compendium.js — tri, filtre, bulk, confirmation inline
- css/compendium-modules.css — styles listes, detail-pp sort, responsive compendium
- Pages : sorts, classes, dons, races, competences, objets, monstres, historiques (DD2024)
- AJAX detail-pp et modifier pour chaque entité
- Monstres : moteur de rendu dédié include/monstre-parser.php (v3)

### Phase 2 — Supplément utilisateur (SP-C)

Permet à tout j_compendium_manager de créer des entrées propres dans le compendium,
rattachées à une source "Supplément de {pseudo}" (1 par ruleset par utilisateur).

| Phase | Contenu | Complexité |
|---|---|---|
| **SP-C0** | SQL : 8 × ALTER TABLE (`_public`/`_visible`) + migration `mo_j_id` (`patch_004_supplements.sql`) | Modérée |
| **SP-C1** | Socle : `getOrCreateUserSupplement`, `getUserSupplementResId`, `canEditCompendiumEntry` | Faible |
| **SP-C2** | Moteur : `compendium-liste.php` JOIN + filtre visibilité + per-entry menu ⋮ + badge ; 8 contrôleurs | Élevée |
| **SP-C3** | `detail-pp/*.php` × 8 : bouton Modifier per-entry (`canEditCompendiumEntry`) | Modérée |
| **SP-C4** | `modifier/*.php` × 8 : source dropdown 2 groupes + `_public`/`_visible` | Modérée |
| **SP-C5** | `enregistrement.php` : ownership + save `_public`/`_visible` + auto-create supplément | Modérée |
| **SP-C6** | `profil/index.php` : "Mes sources" étendu aux suppléments publics tiers | Faible |
| **SP-C7** | Nettoyage monstres post-migration (`monstres.php`, `monstre-parser.php`) | Faible |

### Phase Admin — Zone d'administration TERMINE

### Mise en page — Thèmes TERMINE

### Phase 3 — Personnages EN COURS
Fiche, classes/niveaux, sorts, compétences, dons, NLS (DD3.5).

### Phase 4 — Campagnes
Campagne (sources, univers, personnages invités), scénarios, chapitres, rencontres, oppositions,
duplication, pièces jointes PDF. Structure de données validée.

### Phase 5 — Wiki / Univers
Univers, catégories, articles, délégation, lien univers <-> campagne.

### Module Règles — Wiki de règles TERMINE
Table récursive dd_regles, arbre repliable, vue lecture (fil d'Ariane + Précédent/Suivant DFS),
recherche FULLTEXT, glossaire DD2024 (nœuds reg_type='glossaire' + ancres .glossaire-lien).

---

## 15. Tables de la base de données

### Référentiels
| Table | Préfixe | Rôle |
|---|---|---|
| dd_variables | var | Rulesets et valeurs paramétrables |
| dd_ressources | res | Livres/suppléments — res_j_id = null (officiel) ou j_id (supplément) |
| dd_caracteristiques | car | 6 caractéristiques DD |
| dd_modificateurs | mod | Modificateurs de caractéristiques |

### Utilisateurs
| Table | Préfixe | Rôle |
|---|---|---|
| dd_joueurs | j | Utilisateurs |
| dd_joueurs_sources | js | Sélection sources par utilisateur (inclut les suppléments) |

### Compendium
| Table | Préfixe | Champs supplément | Rôle |
|---|---|---|---|
| dd_races | ra | `ra_public`, `ra_visible` | Races jouables |
| dd_race_type | rat | — | Types de race |
| dd_classes | cla | `cla_public`, `cla_visible` | Classes de personnage |
| dd_classe_niveau | cn | — | Table de bonus par niveau |
| dd_capacites_speciales | cap | — | Capacités spéciales |
| dd_classe_capacite | cc | — | Affectation capacité → niveau |
| dd_typeMagie | mag | — | Types de magie |
| dd_colleges | co | — | Collèges de magie |
| dd_sorts | so | `so_public`, `so_visible` | Sorts |
| dd_sortclasse | sc | — | Sorts par classe |
| dd_dons | do | `do_public`, `do_visible` | Dons |
| dd_data_don | dado | — | Catégories de dons |
| dd_competences | comp | `comp_public`, `comp_visible` | Compétences (pas de `comp_camp_id`) |
| dd_historiques | hi | `hi_public`, `hi_visible` | Historiques (DD2024 uniquement) |
| dd_objets_magiques | om | `om_public` | Objets magiques (`om_visible` déjà existant) |
| dd_monstres | mo | `mo_public`, `mo_visible` | Monstres (`mo_j_id` supprimé, migration vers supplément) |
| dd_monstres_categories | mocat | — | Catégories de monstres |
| dd_monstres_groupes | mogr | — | Groupes de monstres (DD2024) |
| dd_fp | fp | — | Référentiel des facteurs de puissance |

> **Champs `_public` et `_visible` :** ajoutés via `patch_004_supplements.sql`.
> `_public` : 0 = privé (défaut), 1 = partagé. N'a de sens que pour les entrées de supplément.
> `_visible` : 0 = brouillon masqué, 1 = visible (défaut). Contrainte : `_public=1` implique `_visible=1`.

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
| dd_campagnes_personnages | cp | Lien N-N personnage <-> campagne |
| dd_campagnes_sources | cs | Sources actives d'une campagne (priorité 1) |
| dd_scenarios | sce | Scénarios |
| dd_scenarios_chapitres | scc | Chapitres |
| dd_rencontres | re | Rencontres |
| dd_oppositions | opp | Copie éditable d'un monstre |
| dd_fichiers | fi | Pièces jointes PDF génériques |
| dd_campagnes_notes | cpno | RÉSERVÉ |

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
| dd_regles | reg | Chapitres et règles, hiérarchie récursive (reg_reg_id) |

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

TinyMCE via CDN tiny.cloud. Clé API dans include/db.php (TINYMCE_API_KEY).

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

### Configuration règles — listes + tables, sans images

Pour : module Règles.

### Endpoint upload images

Fichier : include/ajax/upload-image.php
Répertoire : img/uploads/ (permissions 755, dans .gitignore)
Retourne : { "location": "URL_du_fichier" }

### Affichage du contenu TinyMCE

Le HTML généré est stocké et affiché **tel quel** (sans h()).

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
- [ ] ownerFilter() appliqué sur toutes les requêtes de liste (modules non-compendium)
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
- [ ] **Supplément : `champ_public` et `champ_visible` déclarés dans `$listConfig` pour les 8 pages contrôleurs**
- [ ] **Supplément : filtre visibilité moteur — `(res.res_j_id IS NULL OR res.res_j_id = :uid OR (_public=1 AND _visible=1))` appliqué quand champ_public est déclaré**
- [ ] **Supplément : menu ⋮ et bouton Modifier dans `detail-pp` conditionnés par `canEditCompendiumEntry($db, $_res_j_id)` (per-entry)**
- [ ] **Supplément : formulaire `modifier/*.php` — source dropdown 2 groupes (officiel + supplément) ; `_public`/`_visible` masqués pour sources officielles**
- [ ] **Supplément : contrainte serveur — si `_public = 1` alors `_visible` forcé à 1 au save**
- [ ] **Supplément : auto-création ressource supplément + auto-add `dd_joueurs_sources` sur premier save**
- [ ] **Supplément : badge `.comp-ligne--homebrew` sur toutes les lignes de supplément dans les listes**
- [ ] **Monstres : `mo_j_id` absent de toutes les requêtes (colonne supprimée via `patch_004_supplements.sql`)**
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
- [ ] Règles (DD2024) : termes de glossaire = nœuds reg_type='glossaire'
- [ ] Règles (DD2024) : renvois = ancres `.glossaire-lien[data-glossaire-slug]` dans reg_texte
- [ ] Règles (DD2024) : clic renvoi → actualiserPageSub() vers detail-pp-sub/glossaire.php
- [ ] img/uploads/ exclu du repo (.gitignore)
- [ ] Thèmes : toute nouvelle variable CSS définie dans body.theme-dark ET body.theme-light
- [ ] Thèmes : aucun fallback de couleur hardcodé dans les composants — utiliser uniquement des var()
- [ ] CSS AJAX : tout style utilisé par un fragment injecté via AJAX hors-compendium → modules.css
- [ ] CSS AJAX : .sort-detail__edit-btn et tout composant partagé → modules.css uniquement
- [ ] Couleurs composants partagés : jamais de valeur hardcodée (#fff, #333…) — toujours var(--clr-*)
- [ ] Tableaux structurés : utiliser .table-dd + .table-dd-wrap
- [ ] Tableaux à 2 lignes d'en-tête : thead avec <tr class="thead-groupes"> pour la ligne groupe
- [ ] Style tableau : jamais de border sur th/td — alternance fond gris perle / transparent sur tbody
- [ ] Thèmes : --clr-surface-alt défini dans les deux thèmes si utilisé dans un composant
