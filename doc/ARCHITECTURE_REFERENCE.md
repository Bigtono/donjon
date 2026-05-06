# Codex DD — Document de référence architecture v2

> Ce document est la source de vérité pour tous les développements.
> À ouvrir dans VS Code à chaque session pour contextualiser Claude.
> Dernière mise à jour : phase 1

---

## 1. Philosophie technique

- PHP classique sans framework (pages contrôleurs + includes)
- JS vanilla, CSS maison
- PDO exclusivement — `prepare/execute` sur toutes les requêtes
- `htmlspecialchars` systématique sur toute sortie HTML via `h()`
- Token CSRF sur tous les formulaires POST et endpoints AJAX sensibles
- Balises PHP : `<?php` pour les blocs logiques, `<?=` pour l'affichage inline
- Syntaxe alternative sans accolades sauf pour `function()` et `class`
- Indentation : 2 espaces

### URL de base — règle absolue

La constante `BASE_URL` est définie dans `include/db.php` :

```php
define('BASE_URL', '/donjon');
```

**Toutes les URLs du projet passent par `BASE_URL` — aucune URL absolue codée en dur.**

| Contexte | Syntaxe |
|---|---|
| Lien HTML | `href="<?= BASE_URL ?>/chemin/page.php"` |
| Attribut `action` | `action="<?= BASE_URL ?>/chemin/page.php"` |
| Redirection PHP | `header('Location: ' . BASE_URL . '/chemin/page.php');` |
| Asset CSS/JS | `href="<?= BASE_URL ?>/css/main.css"` |
| Lien dans un email | `BASE_URL . '/profil/reinitialisation.php?token=...'` |

Cette constante vaut `/donjon` en local (XAMPP) et en production (maikastel.fr/donjon/) — zéro changement au déploiement.

---

## 2. Arborescence

```
codex-dd/
├── index.php                   ← dashboard
├── .htaccess
├── personnages/
│   ├── fiche.php
│   ├── modifier.php
│   └── enregistrement.php
├── compendium/
│   ├── classes.php
│   ├── sorts.php
│   ├── dons.php
│   └── races.php
├── campagnes/
│   ├── campagne.php
│   ├── scenario.php
│   └── rencontres.php
├── wiki/
│   ├── univers.php
│   └── articles.php
├── admin/
│   ├── utilisateurs.php
│   └── ressources.php
├── js/
│   ├── main.js                 ← togglePlus, actualiserPage, CSRF global
│   ├── personnage.js
│   ├── compendium.js
│   ├── campagne.js
│   └── wiki.js
├── css/
│   ├── main.css                ← variables CSS, layout, composants
│   └── modules.css             ← scopes .perso-*, .comp-*, etc.
├── include/
│   ├── db.php                  ← connexion PDO singleton
│   ├── auth.php                ← session, vérification droits
│   ├── helpers.php             ← fonctions transverses
│   ├── header.php
│   ├── footer.php
│   ├── ajax/
│   │   ├── detail-pp/          ← endpoints lecture (consultation)
│   │   └── modifier/           ← endpoints formulaires édition
│   └── insert/
│       ├── DD3.5/              ← templates spécifiques ruleset DD3.5
│       └── DD2024/             ← templates spécifiques ruleset DD2024
├── sql/
│   └── schema.sql              ← schéma complet de la base
└── doc/
    ├── ARCHITECTURE_REFERENCE.md   ← CE FICHIER
    └── DECISIONS_LOG.md            ← journal des décisions
```

---

## 3. Conventions de nommage BDD

- Toutes les tables préfixées `dd_`
- **Local (XAMPP)** : préfixe `dd_` — base dédiée v2, pas de cohabitation avec la v1
- **Production (OVH)** : renommage en `dd2_` au moment du déploiement (script RENAME TABLE à produire) pour cohabiter avec les tables v1
- Chaque table a un préfixe de champ unique (ex: `pe` pour `dd_personnages`)
- Premier champ = id index (ex: `pe_id`)
- Tout champ contenant `_id` renvoie à l'index d'une autre table
- Convention : `[préfixe_table_cible]_id` (ex: `pe_ra_id` → `dd_races.ra_id`)
- `_j_id` = propriétaire (renvoie à `dd_joueurs.j_id`)
- `_camp_id` = campagne (renvoie à `dd_campagnes.camp_id`)
- `_ruleset_var_id` = version de règles (renvoie à `dd_variables`)
- `_res_id` = ressource/livre source (renvoie à `dd_ressources`)

---

## 4. Modèle utilisateur et droits

### Rôles

| Rôle | Condition | Droits |
|---|---|---|
| Admin | `j_admin = 1` | Tout le site, bypass filtres propriétaire |
| Gestionnaire compendium | `j_compendium_manager = 1` | Édition compendium global (sans être admin) |
| Utilisateur standard | par défaut | Ses données uniquement |
| MJ | contextuel : `camp_j_id = session j_id` | Données de sa campagne + personnages invités |

### Règle transverse de filtrage

Toute requête sur données utilisateur applique :
```sql
WHERE [prefix]_j_id = :user_id
-- ou, si admin :
-- pas de filtre propriétaire
```
Encapsulé dans `ownerFilter()` dans `include/helpers.php`.

### Visibilité par module

| Module | Qui voit quoi |
|---|---|
| Compendium | Tous les utilisateurs connectés |
| Personnages | Propriétaire (`pe_j_id`) + MJs des campagnes du personnage |
| Campagnes | Propriétaire (`camp_j_id`) uniquement |
| Wiki/Univers | Propriétaire + utilisateurs ayant accès si univers public |
| Articles wiki | Propriétaire voit tout ; autres : `ua_visible = 1` uniquement |
| Notes MJ (`cp_notes_mj`) | MJ uniquement (`camp_j_id`) |

---

## 5. Patterns d'interface

### detail-pp / modification

- `detail-pp` = consultation (lecture seule)
- `modification` = formulaire d'édition superposé par-dessus `detail-pp`
- Fermer `modification` (Annuler) ne ferme PAS `detail-pp`
- Après sauvegarde : rafraîchir `detail-pp` + liste si impactée

### Commit global

- `*-modifier.php` : édition locale JS/DOM uniquement, zéro écriture BDD
- `*-enregistrement.php` : un seul POST applique tous les changements en transaction
- Actions UI (ajout/suppression/modif ligne) → état JS → champs hidden sérialisés
- Validation métier obligatoire côté serveur
- Écriture en transaction PDO avec `commit()`/`rollback()`

### Blocs repliables (burger)

```html
<button onclick="togglePlus('id_bloc')"><i class="fa fa-bars"></i></button>
<div id="id_bloc" class="accordion-content noDisplay">
  <div class="box-data"><!-- contenu --></div>
</div>
```
Style validé : fond `#f3f3ef`, bordure `#e2e2dd`, rayon `0.35rem`, padding `10px`.

---

## 6. Multi-ruleset

- Rulesets actifs : `DD3.5`, `DD2024`
- Sélection via `$_SESSION['rulesetRep']` (whitelist stricte)
- Templates ruleset dans `include/insert/DD3.5/` et `include/insert/DD2024/`
- Contrat template : HTML uniquement, pas d'auth/session/redirection
- Variables fournies par le contrôleur : `$db`, `$_SESSION`, données métier

---

## 7. Sélection des sources — chaîne de priorité

```
1. Sélection de la campagne (dd_campagnes_sources)
   └─ actif si : personnage en session + rattaché à une campagne
                 + campagne possède une sélection propre
2. Sélection personnelle (dd_joueurs_sources, par ruleset)
   └─ actif si : pas de campagne active ou campagne sans sélection
3. Toutes les sources actives du ruleset (défaut absolu)
```

Contexte actif déterminé par `$_SESSION['last_pe_id']` (dernier personnage consulté).
Helper PHP `getActiveResIds($db, $session)` → retourne `array` d'ids.

---

## 8. Tables de la base de données

Voir `sql/schema.sql` pour le schéma complet.

### Tables principales

| Table | Préfixe | Rôle |
|---|---|---|
| `dd_joueurs` | `j` | Utilisateurs du site |
| `dd_variables` | `var` | Référentiel rulesets et autres valeurs |
| `dd_ressources` | `res` | Livres/suppléments de règles |
| `dd_joueurs_sources` | `js` | Sélection sources par utilisateur |
| `dd_campagnes_sources` | `cs` | Sélection sources par campagne |
| `dd_caracteristiques` | `car` | 6 caractéristiques DD |
| `dd_races` | `ra` | Races jouables |
| `dd_race_type` | `rat` | Types de race (base / archétype) |
| `dd_classes` | `cla` | Classes de personnage |
| `dd_classe_niveau` | `cn` | Table de bonus par niveau de classe |
| `dd_capacites_speciales` | `cap` | Capacités spéciales |
| `dd_classe_capacite` | `cc` | Affectation capacité → niveau de classe |
| `dd_dons` | `do` | Dons |
| `dd_sorts` | `so` | Sorts |
| `dd_sortclasse` | `sc` | Sorts par classe |
| `dd_colleges` | `co` | Collèges de magie |
| `dd_typeMagie` | `mag` | Types de magie (profane/divin) |
| `dd_personnages` | `pe` | Fiches personnages |
| `dd_personnages_classes` | `pc` | Classes du personnage |
| `dd_personnages_nls` | `penl` | NLS classes de prestige (DD3.5) |
| `dd_personnages_sorts` | `pes` | Sorts du personnage |
| `dd_personnages_sorts_prepares` | `pesp` | Sorts préparés |
| `dd_personnages_competences` | `pec` | Compétences du personnage |
| `dd_campagnes` | `camp` | Campagnes |
| `dd_campagnes_personnages` | `cp` | Lien personnage ↔ campagne + notes MJ |
| `dd_campagnes_sources` | `cs` | Sources actives d'une campagne |
| `dd_scenarios` | `sce` | Scénarios |
| `dd_scenarios_chapitres` | `scc` | Chapitres |
| `dd_rencontres` | `re` | Rencontres |
| `dd_rencontres_monstres` | `rem` | Monstres d'une rencontre |
| `dd_monstres` | `mo` | Monstres |
| `dd_univers` | `un` | Univers wiki |
| `dd_univers_droits` | `ud` | Délégation édition univers |
| `dd_univers_categories` | `uca` | Catégories d'articles |
| `dd_univers_articles` | `ua` | Articles wiki |
| `dd_campagnes_univers` | `cu` | Lien campagne ↔ univers |
| `dd_notes` | `no` | Notes de jeu |
| `dd_notes_contenus` | `noc` | Blocs de contenu d'une note |
| `dd_personnages_notes` | `pno` | Note attribuée à un personnage |
| `dd_campagnes_notes` | `cpno` | Note attribuée à une campagne |
| `dd_tags` | `tag` | Tags libres |
| `dd_notes_tags` | `notag` | Association notes ↔ tags |
| `dd_modificateurs` | `mod` | Modificateurs de caractéristiques |

---

## 9. Gestion des univers publics

- `un_public = 1` → univers sélectionnable par d'autres MJs
- Accès en lecture seule pour les campagnes qui le sélectionnent
- Exception : propriétaire délègue via `dd_univers_droits (ud_un_id, ud_j_id)`
- En v1 : délégation globale sur l'univers entier (pas par article)
- Granularité par article prévue en v2

---

## 10. Contenu homebrew de campagne

- Même formulaire que le compendium global
- Champ caché `_camp_id` distingue global (null) de homebrew (camp_id)
- Le MJ crée une entrée `dd_ressources` (`res_j_id = j_id`) pour son recueil maison
- Visibilité : `_camp_id = null` → tous ; `_camp_id = X` → MJ + joueurs de la campagne X

---

## 11. Notes MJ sur les personnages

- Stockées dans `dd_campagnes_personnages.cp_notes_mj`
- Visibles uniquement par le propriétaire de la campagne (`camp_j_id`)
- Supprimées quand le personnage quitte la campagne
- Archivage prévu en v2

---

## 12. Checklist avant chaque merge

- [ ] Aucun write AJAX dans `*-modifier.php`
- [ ] Payload hidden complet et cohérent au submit
- [ ] Validations serveur couvrent les cas invalides
- [ ] Transaction PDO active sur `*-enregistrement.php`
- [ ] `ownerFilter()` appliqué sur toutes les requêtes de liste
- [ ] `htmlspecialchars` / `h()` sur toutes les sorties HTML
- [ ] CSRF token vérifié sur tous les POST
- [ ] **Aucune URL absolue codée en dur — `BASE_URL` utilisé partout**
- [ ] Templates ruleset ne contiennent pas de logique auth/session
- [ ] `rulesetRep` validé via whitelist avant inclusion template
