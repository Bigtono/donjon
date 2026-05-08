# Codex DD v2 — Cahier des charges complet

> Synthèse de toutes les décisions prises en phase de conception.
> Dernière mise à jour : fin Phase 1

---

## 1. Présentation du projet

Application web d'aide au jeu de rôle Donjons & Dragons, destinée à faciliter le travail du maître de jeu et des joueurs pendant les parties. L'application remplace entièrement une v1 développée au fil des années pour un usage personnel.

**Objectif principal de la v2** : ouvrir l'application à plusieurs utilisateurs indépendants, chacun gérant ses propres données (personnages, campagnes, univers), tout en partageant un compendium de règles commun.

---

## 2. Contexte technique

| Élément | Choix |
|---|---|
| Langage serveur | PHP classique sans framework |
| Base de données | MySQL — PDO exclusivement |
| Front-end | JS vanilla, CSS maison |
| Hébergement prod | OVH — `http://maikastel.fr/donjon/` |
| Développement local | XAMPP — `http://localhost/donjon/` |
| Versioning | GitHub — repo `Bigtono/donjon` |
| Éditeur | VS Code + plugin Claude Code |

### Conventions de code

- Balises PHP : `<?php` pour les blocs logiques, `<?=` pour l'affichage inline
- Syntaxe alternative PHP sans accolades sauf pour `function()` et `class`
- Indentation : 2 espaces
- `htmlspecialchars` systématique via `h()` sur toute sortie HTML
- `prepare/execute` PDO sur toutes les requêtes SQL
- Token CSRF sur tous les formulaires POST et endpoints AJAX sensibles
- `BASE_URL = '/donjon'` défini dans `include/db.php` — aucune URL absolue codée en dur

### Conventions base de données

- Tables préfixées `dd_` (en local)
- Au déploiement OVH : renommage en `dd2_` via script `RENAME TABLE` (cohabitation avec tables v1)
- Champs préfixés par table (ex : `pe_` pour `dd_personnages`)
- Premier champ = id index de la table
- Tout champ contenant `_id` renvoie à une autre table
- `_j_id` = propriétaire → `dd_joueurs`
- `_camp_id` = campagne → `dd_campagnes`
- `_res_id` = ressource/livre → `dd_ressources`
- `_ruleset_var_id` = version de règles → `dd_variables`

---

## 3. Versions de règles (rulesets)

Deux rulesets développés en parallèle dès le départ :

| ID | Nom | Répertoire templates |
|---|---|---|
| 1 | DD3.5 | `include/insert/DD3.5/` |
| 2 | DD2024 | `include/insert/DD2024/` |

Sélection via `$_SESSION['rulesetRep']` — whitelist stricte.
Les templates ruleset ne contiennent que du HTML, jamais de logique auth/session/redirection.

---

## 4. Modèle utilisateur et droits

### Rôles

| Rôle | Condition | Droits |
|---|---|---|
| **Admin** | `j_admin = 1` | Tout le site, bypass filtres propriétaire |
| **Gestionnaire compendium** | `j_compendium_manager = 1` | Édition du compendium global sans être admin |
| **Utilisateur standard** | par défaut | Ses propres données uniquement |
| **MJ** | contextuel : `camp_j_id = session j_id` | Données de sa campagne + personnages invités |

Le rôle MJ est **contextuel** — tout utilisateur devient MJ dès qu'il crée une campagne ou un univers. Il n'existe pas de rôle MJ structurel en base.

### Règle de filtrage propriétaire

Toute requête sur données utilisateur applique `WHERE [prefix]_j_id = :user_id`, sauf si admin.
Encapsulé dans `ownerFilter()` dans `include/helpers.php`.

### Visibilité des données par module

| Module | Règle |
|---|---|
| Compendium officiel | Visible par tous les utilisateurs connectés |
| Personnages | Propriétaire + MJs des campagnes auxquelles le personnage est rattaché |
| Campagnes | Propriétaire uniquement |
| Notes MJ (`cp_notes_mj`) | MJ de la campagne uniquement — le propriétaire du personnage ne les voit pas (sauf s'il est lui-même MJ) |
| Univers privé | Propriétaire uniquement |
| Univers public | Tous les utilisateurs (sélectionnable par d'autres MJs) |
| Articles wiki visibles | Tous les ayants droit de l'univers |
| Articles wiki cachés | Propriétaire de l'univers uniquement |

---

## 5. Compendium des règles

### Droits d'édition

Deux niveaux :

1. **Compendium global** : éditable par l'admin et les gestionnaires délégués (`j_compendium_manager = 1`). Visible par tous.
2. **Contenu homebrew de campagne** : créé par le MJ, lié à une campagne via `_camp_id`. Visible uniquement par le MJ et les joueurs dont le personnage est rattaché à cette campagne.

Le contenu homebrew utilise les **mêmes formulaires** que le compendium global, avec un champ caché `_camp_id` pour distinguer global (`null`) de homebrew (`camp_id`).

Quand un MJ crée son premier contenu homebrew, une entrée `dd_ressources` est créée automatiquement avec `res_j_id = j_id` (son "recueil maison").

### Mode de consultation

Deux modes accessibles depuis l'interface :

- **Compendium global** : règles officielles selon la sélection de sources active
- **Vue campagne** : compendium global + ressources homebrew de la campagne

### Sélection des sources — chaîne de priorité

```
1. Sélection de la campagne (dd_campagnes_sources)
   └─ actif si : personnage mémorisé en session (last_pe_id)
                 + rattaché à une campagne
                 + cette campagne a sa propre sélection

2. Sélection personnelle de l'utilisateur (dd_joueurs_sources, par ruleset)
   └─ actif si : pas de campagne active ou campagne sans sélection propre

3. Toutes les sources actives du ruleset (défaut absolu)
```

Le contexte est déterminé par `$_SESSION['last_pe_id']` (dernier personnage consulté, mis à jour automatiquement). L'utilisateur n'a pas à choisir manuellement son contexte.

### Contenu du compendium

- Classes (avec table de bonus de classe et capacités spéciales)
- Sorts (par classe, par collège)
- Dons
- Races
- Objets magiques (à spécifier)
- Compétences

---

## 6. Module Personnages

### Règles générales

- Un personnage possède obligatoirement une race et au moins une classe
- Un personnage appartient à un utilisateur (`pe_j_id`)

### DD3.5 spécifique

- Le personnage peut avoir une race de base + un archétype optionnel (`ra_rat_id = 2`)
- Classes de prestige (`cla_clt_id = 2`) — nécessite au moins une classe de base
- Gestion du NLS (Niveau de Lanceur de Sort) pour les classes de prestige — table `dd_personnages_nls`
- Section NLS affichée uniquement si le personnage possède au moins une classe de base lanceur de sorts ET au moins une classe de prestige influant sur le NLS

### DD2024 spécifique

- Pas d'archétype, pas de classes de prestige
- `pe_arc_id` toujours à 0

### Notes MJ

Les notes MJ ne sont plus stockées dans `dd_personnages` mais dans `dd_campagnes_personnages.cp_notes_mj`. Elles sont propres à chaque association personnage-campagne et perdues si le personnage quitte la campagne (archivage prévu v2).

---

## 7. Module Campagnes

### Hiérarchie

```
Campagne (dd_campagnes)
  └── Scénarios (dd_scenarios)
        └── Chapitres (dd_scenarios_chapitres)
              └── Rencontres (dd_rencontres)
                    └── Monstres (dd_rencontres_monstres → dd_monstres)
```

### Personnages dans une campagne

Liaison via `dd_campagnes_personnages` (cp_camp_id, cp_pe_id, cp_notes_mj, cp_actif).
Le MJ voit la fiche complète du personnage + le champ `cp_notes_mj`.

### Responsive

Le module Campagnes n'est **pas responsive** — usage desktop exclusif (MJ en partie).

---

## 8. Module Wiki / Univers

### Structure

```
Univers (dd_univers) — public ou privé
  └── Catégories (dd_univers_categories) — géographie, histoire, organisations...
        └── Articles (dd_univers_articles) — visible ou caché
```

### Règles de visibilité

- Univers **privé** : propriétaire uniquement
- Univers **public** : sélectionnable par d'autres MJs pour leurs campagnes (`dd_campagnes_univers`)
- Article `ua_visible = 1` : visible par tous les ayants droit de l'univers
- Article `ua_visible = 0` : propriétaire uniquement (ou délégataire)
- Univers agnostique du ruleset

### Délégation

Le propriétaire peut déléguer les droits d'édition via `dd_univers_droits (ud_un_id, ud_j_id)`.
En v1 : délégation globale sur l'univers entier. Granularité par article prévue en v2.

---

## 9. Responsive

| Module | Responsive |
|---|---|
| Compendium | Oui |
| Personnages | Oui |
| Wiki / Univers | Oui |
| Campagnes | Non (desktop MJ uniquement) |
| Profil | Oui |
| Connexion / Auth | Oui |

Seuil : 992px (mode normal ≥ 992px, mode responsive ≤ 991px).

---

## 10. Profil utilisateur

### Données personnelles
Prénom, nom, pseudo (unique), email (unique).

### Mot de passe
Changement avec vérification de l'ancien mot de passe. Réinitialisation par email (token 1h).
En mode `DEV_MODE = true` : le lien de réinitialisation s'affiche directement dans la page.

### Paramètres personnalisables (liste évolutive)

| Paramètre | Champ | Description |
|---|---|---|
| Ruleset par défaut | `j_default_ruleset_var_id` | Ruleset chargé à chaque connexion |
| Mode campagne | `j_mode_campagne` | Active/désactive le menu Campagnes |
| Affichage ruleset | `j_affichage_ruleset` | Affiche le ruleset actif dans le header |
| Éléments par page | `j_items_par_page` | Taille des listes paginées (10/20/50/100) |

---

## 11. Patterns d'interface

### detail-pp / modification

- `#detail-pp` : consultation en lecture seule
- `#modification` : formulaire d'édition superposé par-dessus `#detail-pp`
- Fermer `#modification` (Annuler) **ne ferme pas** `#detail-pp`
- Après sauvegarde : rafraîchir `#detail-pp` + liste principale si impactée

### Commit global

- `*-modifier.php` : édition locale JS/DOM uniquement — zéro écriture BDD
- `*-enregistrement.php` : un seul POST applique tous les changements en transaction PDO
- Actions UI → état JS local → champs hidden sérialisés au submit
- Validation métier obligatoire côté serveur (jamais uniquement côté JS)
- Écriture en transaction avec `commit()`/`rollback()`

### Blocs repliables (burger)

```html
<button onclick="togglePlus('id_bloc')"><i class="fa fa-bars"></i></button>
<div id="id_bloc" class="accordion-content noDisplay">
  <div class="box-data"><!-- contenu --></div>
</div>
```

Style : fond `#f3f3ef`, bordure `#e2e2dd`, rayon `0.35rem`, padding `10px`.

---

## 12. Arborescence du projet

```
donjon/
├── index.php                       ← dashboard / connexion
├── .htaccess
├── personnages/
│   ├── fiche.php
│   ├── modifier.php
│   └── enregistrement.php
├── compendium/
│   ├── classes.php
│   ├── races.php
│   ├── origines.php (spécificité DD2024)
│   ├── competences.php
│   ├── dons.php
│   ├── sorts.php
│   └── objets_magiques.php
├── campagnes/
│   ├── campagne.php
│   ├── scenario.php
│   └── rencontres.php
├── wiki/
│   ├── univers.php
│   └── articles.php
├── profil/
│   ├── index.php
│   ├── mot-de-passe-oublie.php
│   └── reinitialisation.php
├── admin/
│   ├── utilisateurs.php
│   └── ressources.php
├── js/
│   ├── main.js                     ← togglePlus, actualiserPage, CSRF...
│   ├── personnage.js
│   ├── compendium.js
│   ├── campagne.js
│   ├── wiki.js
│   └── profil.js
├── css/
│   ├── main.css                    ← variables, layout, composants
│   └── modules.css                 ← scopes par module
├── include/
│   ├── db.php                      ← PDO + BASE_URL + DEV_MODE
│   ├── auth.php                    ← session, droits, CSRF, remember me
│   ├── helpers.php                 ← h(), ownerFilter(), getActiveResIds()...
│   ├── header.php
│   ├── footer.php
│   ├── ajax/
│   │   ├── detail-pp/
│   │   └── modifier/
│   └── insert/
│       ├── DD3.5/
│       └── DD2024/
├── sql/
│   ├── schema.sql
│   └── patch_001_reset_password.sql
└── doc/
    ├── CAHIER_DES_CHARGES.md       ← CE FICHIER
    ├── ARCHITECTURE_REFERENCE.md   ← référence technique pour VS Code
    └── DECISIONS_LOG.md            ← journal des décisions
```

---

## 13. Plan de développement

### Phase 1 — Socle technique ✅ TERMINÉ

- Structure de fichiers et arborescence
- Base de données (schema.sql)
- Auth : connexion, session, remember me, CSRF, logout
- Helpers : `h()`, `ownerFilter()`, `getActiveResIds()`, pagination
- Header / footer communs avec `BASE_URL`
- Dashboard
- Profil utilisateur (identité, mot de passe, paramètres)
- Réinitialisation mot de passe (avec mode DEV_MODE)
- CSS design system + responsive

### Phase 2 — Compendium 🔜 SUIVANT

Priorité donnée au compendium pour permettre l'alimentation du site en données dès le début.

- Page sélection des sources (`affichageSelectionSources.php`)
- Classes : données principales + table de bonus de classe + capacités spéciales
- Sorts : liste, détail, filtres par classe/collège/ressource
- Dons : liste, détail, filtres
- Races : liste, détail
- Gestion homebrew de campagne (même formulaires + champ `_camp_id` caché)
- Templates DD3.5 et DD2024 en parallèle

### Phase 3 — Personnages

- Création / édition fiche (race, archétype DD3.5, caractéristiques)
- Classes et niveaux (commit global)
- Sorts du personnage (accès, connus, préparés)
- Compétences et dons
- NLS classes de prestige (DD3.5 uniquement)

### Phase 4 — Campagnes

- Création campagne, scénarios, chapitres
- Rencontres et affectation de monstres
- Rattachement personnages à une campagne
- Notes MJ (`cp_notes_mj`)
- Sélection de sources propre à une campagne

### Phase 5 — Wiki / Univers

- Création d'univers (public / privé)
- Catégories et articles (visible / caché)
- Délégation de droits d'édition
- Rattachement univers à une campagne

---

## 14. Tables de la base de données

### Référentiels

| Table | Préfixe | Rôle |
|---|---|---|
| `dd_variables` | `var` | Rulesets et valeurs paramétrables |
| `dd_ressources` | `res` | Livres/suppléments de règles |
| `dd_caracteristiques` | `car` | 6 caractéristiques DD |
| `dd_modificateurs` | `mod` | Modificateurs de caractéristiques |

### Utilisateurs

| Table | Préfixe | Rôle |
|---|---|---|
| `dd_joueurs` | `j` | Utilisateurs du site |
| `dd_joueurs_sources` | `js` | Sélection sources par utilisateur |

### Compendium

| Table | Préfixe | Rôle |
|---|---|---|
| `dd_races` | `ra` | Races jouables |
| `dd_race_type` | `rat` | Types de race (base / archétype) |
| `dd_classes` | `cla` | Classes de personnage |
| `dd_classe_niveau` | `cn` | Table de bonus par niveau |
| `dd_capacites_speciales` | `cap` | Capacités spéciales |
| `dd_classe_capacite` | `cc` | Affectation capacité → niveau de classe |
| `dd_typeMagie` | `mag` | Types de magie |
| `dd_colleges` | `co` | Collèges de magie |
| `dd_sorts` | `so` | Sorts |
| `dd_sortclasse` | `sc` | Sorts par classe |
| `dd_dons` | `do` | Dons |
| `dd_data_don` | `dado` | Catégories de dons |
| `dd_competences` | `comp` | Compétences |

### Personnages

| Table | Préfixe | Rôle |
|---|---|---|
| `dd_personnages` | `pe` | Fiches personnages |
| `dd_personnages_classes` | `pc` | Classes du personnage |
| `dd_personnages_nls` | `penl` | NLS classes de prestige (DD3.5) |
| `dd_personnages_sorts` | `pes` | Sorts du personnage |
| `dd_personnages_sorts_prepares` | `pesp` | Sorts préparés |
| `dd_personnages_competences` | `pec` | Compétences du personnage |
| `dd_personnages_dons` | `ped` | Dons du personnage |

### Campagnes

| Table | Préfixe | Rôle |
|---|---|---|
| `dd_campagnes` | `camp` | Campagnes |
| `dd_campagnes_personnages` | `cp` | Lien personnage ↔ campagne + notes MJ |
| `dd_campagnes_sources` | `cs` | Sources actives d'une campagne |
| `dd_campagnes_univers` | `cu` | Lien campagne ↔ univers |
| `dd_campagnes_notes` | `cpno` | Note rattachée à une campagne |
| `dd_scenarios` | `sce` | Scénarios |
| `dd_scenarios_chapitres` | `scc` | Chapitres |
| `dd_rencontres` | `re` | Rencontres |
| `dd_rencontres_monstres` | `rem` | Monstres d'une rencontre |
| `dd_monstres` | `mo` | Monstres |

### Wiki / Univers

| Table | Préfixe | Rôle |
|---|---|---|
| `dd_univers` | `un` | Univers wiki |
| `dd_univers_droits` | `ud` | Délégation droits édition univers |
| `dd_univers_categories` | `uca` | Catégories d'articles |
| `dd_univers_articles` | `ua` | Articles wiki |

### Notes

| Table | Préfixe | Rôle |
|---|---|---|
| `dd_notes` | `no` | Notes de jeu |
| `dd_notes_contenus` | `noc` | Blocs de contenu (avec degré de difficulté) |
| `dd_personnages_notes` | `pno` | Note attribuée à un personnage |
| `dd_tags` | `tag` | Tags libres |
| `dd_notes_tags` | `notag` | Association notes ↔ tags |

---

## 15. Checklist avant chaque merge

- [ ] Aucun write AJAX dans `*-modifier.php`
- [ ] Payload hidden complet et cohérent au submit
- [ ] Validations serveur couvrent les cas invalides
- [ ] Transaction PDO active sur `*-enregistrement.php`
- [ ] `ownerFilter()` appliqué sur toutes les requêtes de liste
- [ ] `h()` sur toutes les sorties HTML
- [ ] CSRF token vérifié sur tous les POST
- [ ] Aucune URL absolue codée en dur — `BASE_URL` utilisé partout
- [ ] Templates ruleset sans logique auth/session
- [ ] `rulesetRep` validé via whitelist avant inclusion template
- [ ] Responsive testé sur les modules concernés (hors Campagnes)
