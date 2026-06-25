# CLAUDE.md — Codex DD v2 (donjon)

> Contexte persistant chargé à chaque session Claude Code.
> Pour les détails techniques complets, lire `doc/ARCHITECTURE_0_REFERENCE.md`.

---

## Projet

Application PHP/MySQL de compendium D&D et gestion de campagnes.
Deux rulesets : **DD3.5** (id 1) et **DD2024** (id 2).
- Prod : `http://maikastel.fr/donjon/` (OVH)
- Dev local : `http://localhost/donjon/` (XAMPP)
- GitHub : `https://github.com/Bigtono/donjon` (branche `main`)

---

## Conventions de code — NON NÉGOCIABLES

- **Indentation : 2 espaces** (jamais de tabs)
- **PHP** : syntaxe alternative sans accolades dans les templates (`if/endif`, `foreach/endforeach`) ; accolades **uniquement** pour `function()` et `class`
- **Balises PHP** : `<?php` pour les blocs logiques, `<?= ... ?>` pour l'affichage inline
- **Sortie HTML** : toujours via `h()` (= `htmlspecialchars`) — jamais d'affichage brut d'une variable
- **SQL** : PDO exclusivement, `prepare()`/`execute()` systématiques — jamais de concaténation
- **URLs** : toujours via `BASE_URL` (`define('BASE_URL', '/donjon')` dans `include/db.php`) — aucune URL absolue codée en dur
- **CSS** : `var(--clr-*)` et `var(--sp-*)` — jamais de valeurs hexadécimales en dur dans les fichiers CSS
- **JS** : pattern IIFE pour les formulaires injectés via AJAX ; `var` (pas `const`) pour les variables pouvant être re-déclarées à la réouverture du formulaire

---

## Constantes architecturales

| Élément | Valeur / règle |
|---|---|
| Préfixe tables | `dd_` (local) / `dd2_` (OVH, rename script) |
| Préfixe champs | Par table (ex. `so_` pour `dd_sorts`, `mo_` pour `dd_monstres`) |
| `_j_id` | FK → `dd_joueurs` (propriétaire) |
| `_camp_id` | FK → `dd_campagnes` |
| `_res_id` | FK → `dd_ressources` (livre source) |
| `_ruleset_var_id` | FK → `dd_variables` (ruleset) |
| Ruleset DD3.5 | id = 1, dossier templates `include/insert/DD3.5/` |
| Ruleset DD2024 | id = 2, dossier templates `include/insert/DD2024/` |
| `dd_historiques` | DD2024 uniquement — jamais exposé en DD3.5 |

---

## Fonctions helpers critiques (`include/helpers.php`)

| Fonction | Rôle |
|---|---|
| `h($str)` | Échappement HTML — systématique |
| `intParam($k)` | Lit et valide un entier depuis GET/POST |
| `strParam($k)` | Lit et nettoie une chaîne depuis GET/POST |
| `requireAuth()` | Vérifie la session, redirige sinon |
| `requireAdmin()` | Vérifie le rôle admin |
| `csrfField()` / `verifyCsrf()` | Token CSRF — obligatoire sur tout formulaire POST |
| `isMJ($db, $camp_id)` | Vérifie si l'utilisateur courant est MJ de la campagne |
| `ownerFilter()` | WHERE `_j_id = :user_id` sauf admin |
| `canEditCompendium()` | Droit global édition compendium (auth.php) |
| `canEditCompendiumEntry($db, ?int $res_j_id)` | Droit per-entry (helpers.php) |
| `getActiveResIds($db, $ruleset_id)` | Sources actives : campagne > perso > défaut |
| `getActiveResIdsCampagne($db, $camp_id, $ruleset_id)` | Sources actives d'une campagne (inclut le supplément perso du MJ) |
| `getOrCreateUserSupplement($db, $j_id, $ruleset_id)` | Crée le supplément utilisateur si absent |

---

## Système de panels et z-index

| Élément | z-index | Rôle |
|---|---|---|
| `#detail-pp-backdrop` | 199 | Backdrop detail principal |
| `#detail-pp` | 200 | Panneau détail (lecture) |
| `#modification-backdrop` | 249 | Backdrop formulaire |
| `#modification` | 250 | Formulaire d'édition |
| `#detail-pp-sub-backdrop` | 299 | Backdrop sous-panneau |
| `#detail-pp-sub` | 300 | Sous-panneau (au-dessus de tout) |

**Règle** : ouvrir `#modification` depuis `#detail-pp-sub` → appeler `fermerSubPanel()` **avant** `actualiserPageModif()`.

**API JS (`main.js`)** : `actualiserPageSub(url, params)` · `fermerSubPanel()` · `fermerDetailPP()` · `naviguerDetailPP(url, params)` · `rafraichirDetailPPCourant()`

---

## Moteur de liste compendium (`include/compendium-liste.php`)

Chaque page déclare `$listConfig` et délègue tout le rendu. Clés obligatoires :
`entite`, `titre`, `from`, `champ_id`, `champ_res`, `champ_ruleset`, `colonnes`, `filtres`, `url_detail`, `url_modifier`, `url_enreg`.

Clés supplément (déclarer les 3 ensemble) : `champ_public`, `champ_visible`, `champ_res_owner`.
Le `from` doit déjà joindre `dd_ressources` sous l'alias attendu (le moteur ne rajoute pas de JOIN).

**`IN ()` vide** : si `getActiveResIds()` retourne un tableau vide, omettre le filtre SQL — ne jamais générer `IN ()`.

---

## TinyMCE

TinyMCE 6 via CDN jsDelivr, sans clé API. Pattern `initTMCE()` obligatoire :
- Détection thème : `var isLight = document.body.classList.contains('theme-light')`
- `skin` / `content_css` toujours conditionnés sur `isLight` (jamais codés en dur)
- `content_style` en valeurs hex fixes (les `var(--clr-*)` ne traversent pas l'iframe TinyMCE)
- `tinymce.remove('#mon_champ')` avant `tinymce.init()` pour éviter les doublons sur réouverture

---

## Documentation du projet

Tous les fichiers dans `doc/` :

| Fichier | Contenu |
|---|---|
| `ARCHITECTURE_0_REFERENCE.md` | **Source de vérité technique** — lire avant tout développement |
| `DECISIONS_LOG.md` | Journal daté de toutes les décisions |
| `SCHEMA_SQL.md` | Schéma base de données |
| `METIER_*.md` | Règles de jeu / specs fonctionnelles (sans code) |

---

## Workflow de développement

1. **Avant chaque tâche** : lire `doc/ARCHITECTURE_0_REFERENCE.md` pour contextualiser. Lire les fichiers concernés directement sur le disque local.
2. **Arbitration avant code** : pour toute décision architecturale non triviale, poser les questions numérotées et attendre validation explicite avant d'implémenter.
3. **Écriture directe** : modifier les fichiers en place dans l'arborescence du projet. Aucun ZIP.
4. **Sécurité** : CSRF sur tout POST, `h()` sur toute sortie, PDO sur tout SQL.
5. **Réutilisation maximale** : moteur `compendium-liste.php`, pattern `$listConfig`, helpers existants. Pas de nouvelle table ni nouveau module sans arbitration préalable.
6. **Schema-first** : vérifier que les colonnes SQL référencées existent réellement en base avant d'écrire le code. En cas de doute, demander confirmation.

### Mise à jour de la documentation

Après toute livraison significative, mettre à jour :
- `doc/DECISIONS_LOG.md` : entrée datée pour chaque décision/choix technique
- `doc/ARCHITECTURE_0_REFERENCE.md` : si un pattern, module ou comportement change
- Les deux fichiers sont livrés **complets** (prêts à écraser l'existant), avec en tête :
  `<!-- Mis à jour : AAAA-MM-JJ HH:MM -->`

---

## État courant du projet (juin 2026)

### Implémenté
- Compendium complet : sorts, classes (+ sous-classes DD2024), races, dons, compétences, objets magiques, historiques (DD2024), monstres
- Supplément utilisateur SP-C0→SP-C7 : **fait pour Monstres** ; schéma `_public`/`_visible` à vérifier et appliquer aux 7 autres entités (sorts, feats, skills, classes, races, objets, historiques) — `patch_004_supplements.sql` à confirmer appliqué en base
- Campagnes : campagnes → scénarios → chapitres → rencontres → oppositions
- Transfert/Duplication opposition SP-T0 (même campagne) : fait
- Équipements SP-E0 : table `dd_equipements` créée (`sql/2026-06-20_equipements_sp-e0.sql`)
- Header context buttons : cascade setters, partial `include/header-context.php`, endpoint AJAX

### À faire (priorités)
- SP-C6/C7 pour les 7 entités restantes du compendium (après vérif schema)
- SP-E1→E5 : module équipements (liste, formulaire, détail, parser, supplément)
- SP-T1 : Transférer/Dupliquer vers une autre campagne

---

## Structure clés du projet

```
donjon/
  compendium/        sorts.php, classes.php, monstres.php, … enregistrement.php
  campagnes/         index.php, enregistrement.php, …
  personnages/       fiche.php, enregistrement.php, …
  include/
    db.php           define BASE_URL, connexion PDO
    auth.php         requireAuth(), canEditCompendium()
    helpers.php      h(), intParam(), csrfField(), ownerFilter(), canEditCompendiumEntry(), …
    header.php / footer.php
    compendium-liste.php   moteur de liste générique
    monstre-parser.php     rendu stats monstre (rendreStatsMonstre())
    header-context.php     fragment boutons contextuels
    ajax/detail-pp/        fiches détail (sort.php, monstre.php, …)
    ajax/modifier/         formulaires d'édition (sort.php, monstre.php, …)
    ajax/header-context.php
  css/
    main.css          variables --clr-*, --sp-*, overlays, z-index
    modules.css       .mo-* globaux (chargé sur toutes les pages)
    compendium-modules.css  styles compendium spécifiques
  js/
    main.js           globals partagés, .mo-lien handler, panels API
    compendium.js     logique compendium
    campagne.js       logique campagnes
  doc/               documentation (voir § Documentation)
  sql/               migrations (patch_*.sql, 2026-*.sql)
```
