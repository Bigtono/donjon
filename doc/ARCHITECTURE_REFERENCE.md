# Codex DD v2 — Document de référence architecture

> Source de vérité pour tous les développements.
> À ouvrir dans VS Code à chaque session pour contextualiser Claude Code.
> Dernière mise à jour : Phase 2 — conception compendium

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

Classes CSS définies une fois dans modules.css :

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
  enregistrement.php  (POST commun + mode ?ajax=1)

include/
  compendium-liste.php   (moteur commun)
  ajax/detail-pp/        (sort.php, classe.php, don.php, race.php...)
  ajax/modifier/         (sort.php, classe.php, don.php, race.php...)
```

### enregistrement.php — mode AJAX

Détecte $_GET['ajax'] et retourne JSON {ok, id, url_detail} pour les saves individuels.
Mode normal (bulk) : redirect + flash message SESSION.

---

## 6. Module Personnages

- Un personnage possède obligatoirement une race et au moins une classe
- DD3.5 : race de base + archétype optionnel, classes de prestige, NLS (dd_personnages_nls)
- DD2024 : pas d'archétype, pas de classes de prestige (pe_arc_id = 0)
- Notes MJ : dd_campagnes_personnages.cp_notes_mj (perdues si le personnage quitte la campagne)

---

## 7. Module Campagnes

Hiérarchie : Campagne → Scénarios → Chapitres → Rencontres → Monstres
Liaison personnages via dd_campagnes_personnages.
Module NON responsive — usage desktop exclusif.

---

## 8. Module Wiki / Univers

Univers (public/privé) → Catégories → Articles (visible/caché)
Délégation droits via dd_univers_droits. En v1 : globale sur l'univers entier.

---

## 9. Responsive

| Module | Responsive | Notes |
|---|---|---|
| Compendium | Oui | col-primary/secondary/action, pas de boutons action mobile |
| Personnages | Oui | |
| Wiki / Univers | Oui | |
| Campagnes | Non | Desktop MJ uniquement |
| Profil | Oui | |
| Connexion / Auth | Oui | |

Seuil : 992px.

---

## 10. Profil utilisateur

Trois sections indépendantes (champ hidden section) : identité, mot de passe, paramètres.
DEV_MODE = true dans include/db.php → lien reset MDP affiché en page.

| Paramètre | Champ | Description |
|---|---|---|
| Ruleset par défaut | j_default_ruleset_var_id | Ruleset chargé à chaque connexion |
| Mode campagne | j_mode_campagne | Active/désactive le menu Campagnes |
| Affichage ruleset | j_affichage_ruleset | Affiche le ruleset dans le header |
| Éléments par page | j_items_par_page | Taille des listes (10/20/50/100) |

---

## 11. Patterns d'interface

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
Style : fond #f3f3ef, bordure #e2e2dd, rayon 0.35rem, padding 10px.

---

## 12. Arborescence du projet

```
donjon/
  index.php
  .htaccess
  personnages/     fiche.php, modifier.php, enregistrement.php
  compendium/      sorts.php, classes.php, dons.php, races.php,
                   competences.php, objets.php, enregistrement.php
  campagnes/       campagne.php, scenario.php, rencontres.php
  wiki/            univers.php, articles.php
  profil/          index.php, mot-de-passe-oublie.php, reinitialisation.php
  admin/           utilisateurs.php, ressources.php
  js/
    main.js          togglePlus, actualiserPage, _detailPpContext,
                     apresModification, rafraichirListe, CSRF
    personnage.js
    compendium.js    toggleSort, submitFiltre, bulk, confirmerSuppression inline
    campagne.js
    wiki.js
    profil.js
  css/
    main.css         variables, layout, composants
    modules.css      .col-primary, .col-secondary, .col-action, .bulk-check
  include/
    db.php           PDO + BASE_URL + DEV_MODE
    auth.php
    helpers.php
    header.php
    footer.php
    compendium-liste.php    moteur de liste commun (lit $listConfig)
    ajax/
      detail-pp/     sort.php, classe.php, don.php, race.php...
      modifier/      sort.php, classe.php, don.php, race.php...
    insert/
      DD3.5/
      DD2024/
  sql/
    schema.sql
    patch_001_reset_password.sql
  doc/
    ARCHITECTURE_REFERENCE.md
    DECISIONS_LOG.md
```

---

## 13. Plan de développement

### Phase 1 — Socle technique TERMINE
Auth, session, helpers, header/footer, dashboard, profil, reset MDP, CSS design system.

### Phase 2 — Compendium EN COURS
- include/compendium-liste.php — moteur commun
- compendium/enregistrement.php — POST commun + mode AJAX
- js/compendium.js — tri, filtre, bulk, confirmation inline
- CSS responsive listes (.col-primary, .col-secondary, .col-action)
- Pages : sorts, classes, dons, races, competences
- AJAX detail-pp et modifier pour chaque entité
- Templates DD3.5 et DD2024 en parallèle

### Phase 3 — Personnages
Fiche, classes/niveaux, sorts, compétences, dons, NLS (DD3.5).

### Phase 4 — Campagnes
Campagne, scénarios, chapitres, rencontres, monstres, personnages invités.

### Phase 5 — Wiki / Univers
Univers, catégories, articles, délégation, lien univers <-> campagne.

---

## 14. Tables de la base de données

### Référentiels
| Table | Préfixe | Rôle |
|---|---|---|
| dd_variables | var | Rulesets et valeurs paramétrables |
| dd_ressources | res | Livres/suppléments |
| dd_caracteristiques | car | 6 caractéristiques DD |
| dd_modificateurs | mod | Modificateurs de caractéristiques |

### Utilisateurs
| Table | Préfixe | Rôle |
|---|---|---|
| dd_joueurs | j | Utilisateurs |
| dd_joueurs_sources | js | Sélection sources par utilisateur |

### Compendium
| Table | Préfixe | Rôle |
|---|---|---|
| dd_races | ra | Races jouables |
| dd_race_type | rat | Types de race |
| dd_classes | cla | Classes de personnage |
| dd_classe_niveau | cn | Table de bonus par niveau |
| dd_capacites_speciales | cap | Capacités spéciales |
| dd_classe_capacite | cc | Affectation capacité → niveau |
| dd_typeMagie | mag | Types de magie |
| dd_colleges | co | Collèges de magie |
| dd_sorts | so | Sorts |
| dd_sortclasse | sc | Sorts par classe |
| dd_dons | do | Dons |
| dd_data_don | dado | Catégories de dons |
| dd_competences | comp | Compétences |

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

## 15. Checklist avant chaque merge

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
- [ ] Compendium : colonne de tri validée par whitelist avant ORDER BY
- [ ] Compendium : _detailPpContext correctement passé à actualiserPage()
- [ ] Compendium : enregistrement.php?ajax=1 retourne JSON, mode normal retourne redirect
