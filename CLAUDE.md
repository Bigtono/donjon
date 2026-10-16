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
- **URLs** : toujours via `BASE_URL` (`define('BASE_URL', '/donjon')` dans `config/db.config.php`, exclu de git — modèle : `config/db.config.example.php` ; chargé par `include/db.php`) — aucune URL absolue codée en dur
- **CSS** : `var(--clr-*)` et `var(--sp-*)` — jamais de valeurs hexadécimales en dur dans les fichiers CSS
- **JS** : pattern IIFE pour les formulaires injectés via AJAX ; `var` (pas `const`) pour les variables pouvant être re-déclarées à la réouverture du formulaire

---

## Constantes architecturales

| Élément | Valeur / règle |
|---|---|
| Préfixe tables | `dd_`, en local comme sur OVH (le renommage `dd2_` n'a jamais été appliqué) |
| Préfixe champs | Par table (ex. `so_` pour `dd_sorts`, `mo_` pour `dd_monstres`) |
| `_j_id` | FK → `dd_joueurs` (propriétaire) |
| `_camp_id` | FK → `dd_campagnes` |
| `_res_id` | FK → `dd_ressources` (livre source) |
| `_ruleset_var_id` | FK → `dd_variables` (ruleset) |
| Ruleset DD3.5 | id = 1 |
| Ruleset DD2024 | id = 2 |
| Spécificités ruleset | Gérées **inline** (`if ($ruleset_rep === 'DD3.5')`, filtre `_ruleset_var_id`) — pas de dossier de templates par ruleset (`include/insert/DD*/` abandonné le 2026-06-12, voir `DECISIONS_LOG.md`) |
| `dd_historiques` | DD2024 uniquement — jamais exposé en DD3.5 |

---

## Fonctions helpers critiques (`include/helpers.php` et `include/auth.php`)

| Fonction | Rôle |
|---|---|
| `h($str)` | Échappement HTML — systématique |
| `intParam($k)` | Lit et valide un entier depuis GET/POST |
| `strParam($k)` | Lit et nettoie une chaîne depuis GET/POST |
| `requireAuth()` | Vérifie la session, redirige sinon (auth.php) |
| `requireAdmin()` | Vérifie le rôle admin (auth.php) |
| `csrfField()` / `verifyCsrf()` | Token CSRF — obligatoire sur tout formulaire POST (auth.php) |
| `isMJ($db, $camp_id)` | Vérifie si l'utilisateur courant est MJ de la campagne (auth.php) |
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
7. **Migrations SQL** (SP-DP, voir `doc/ARCHITECTURE_0_REFERENCE.md` §6b) : toute évolution de
   base passe par un fichier `sql/AAAA-MM-JJ_<sujet>_<phase>.sql`, que le déploiement fait jouer
   en production par le moteur (`include/migrations.php`). **Ne jamais modifier une migration
   déjà appliquée** — elle ne serait pas rejouée, seulement signalée comme retouchée : écrire une
   nouvelle migration. Pas de `DELIMITER`. Après l'avoir jouée en local à la main, la déclarer
   dans `admin/migrations.php` (« Marquer comme appliquée »), ou la jouer depuis cet écran.

### Mise à jour de la documentation

Après toute livraison significative, mettre à jour :
- `doc/DECISIONS_LOG.md` : entrée datée pour chaque décision/choix technique
- `doc/ARCHITECTURE_0_REFERENCE.md` : si un pattern, module ou comportement change
- Les deux fichiers sont livrés **complets** (prêts à écraser l'existant), avec en tête :
  `<!-- Mis à jour : AAAA-MM-JJ HH:MM -->`

### ⚠️ Suivi des phases — OBLIGATOIRE ET PRIORITAIRE

`doc/ARCHITECTURE_0_REFERENCE.md` **§0 — Suivi des phases de développement** est le tableau de
bord unique de l'avancement du projet. Sa tenue à jour est **non négociable** :

1. **Tout nouveau chantier reçoit un code projet** (`SP-<lettres>`) et ses phases sont
   **numérotées** dès l'arbitration : `SP-TB0`, `SP-TB1`, … Codes en service : `SP-C`
   (supplément compendium), `SP-E` (équipements), `SP-PO` (possessions : équipements et objets
   magiques, tag de liste `[[liste:…]]`), `SP-T` (transfert d'opposition), `SP-TB` (tableaux de
   règles), `SP-GL` (glossaire), `SP-DRS` (import des règles DD3.5), `SP-IM` (import des données du
   compendium), `SP-MA` (référentiel de la magie), `SP-PE` (module Personnages), `SP-SC`
   (sous-classes DD2024), `SP-RS` (UI smartphone), `SP-CP` (refonte du module Campagnes), `SP-AD`
   (administration), `SP-RB` (bascule de ruleset depuis le header), `SP-DP` (déploiement en
   production), `SP-XC` (export de classes vers la production), `SP-SY` (synchronisation du contenu
   local → production, en attente d'arbitrage).
2. **À chaque livraison**, cocher les phases terminées et ajouter les phases restantes
   dans §0, au format checklist markdown :
   ```markdown
   - [x] SP-TB1 — Moteur de rendu des tableaux
   - [ ] SP-TB8 — Écran du MJ
   ```
3. **Les phases non livrées y figurent explicitement**, avec un libellé qui suffit à
   reprendre le travail plus tard. Une phase abandonnée est retirée, pas laissée décochée.
4. §0 ne contient **que** la checklist — les détails techniques vont dans la section du
   module, les décisions dans `DECISIONS_LOG.md`.

Ne jamais clôturer une tâche sans avoir mis §0 à jour.

---

## État courant du projet (octobre 2026)

> **L'état d'avancement fait foi dans `doc/ARCHITECTURE_0_REFERENCE.md` §0** (checklist des
> phases). La section ci-dessous n'en est qu'un résumé narratif.

### Implémenté
- Compendium complet : sorts, classes (+ sous-classes DD2024), races, dons, compétences, objets magiques, historiques (DD2024), monstres
- Supplément utilisateur SP-C0→SP-C5 et SP-C7 : **fait sur les 8 entités** du compendium (`_public`/`_visible`, menu ⋮ per-entry, source à 2 groupes). Reste SP-C6 (profil « Mes sources » : suppléments publics tiers, partiel)
- Campagnes : campagnes → scénarios → chapitres → rencontres → oppositions
- Transfert/Duplication opposition SP-T0 (même campagne) : fait
- Équipements SP-E0→E3 : table `dd_equipements` (`sql/2026-06-20_equipements_sp-e0.sql`), liste, formulaire, fiche détail
- Header context buttons : cascade setters, partial `include/header-context.php`, endpoint AJAX
- Tableaux de règles SP-TB0→TB7 : table `dd_tableaux`, convention texte, tag `[[tab:slug]]`,
  UI de gestion, migration des tableaux HTML existants. Portée du tag : `reg_texte`, définitions
  de glossaire, `mo_stats` et les champs description du compendium. Composant CSS `.reg-tab*`
  dans `css/modules.css` (chargé partout) — voir §9c
- Liaison auto du glossaire SP-GL0→GL3 : `include/glossaire-parser.php`, renvois produits au
  rendu dans `reg_texte`, les définitions de glossaire et les descriptions du compendium.
  Point de passage unique : `rendreTexteEnrichi()` — glossaire puis tableaux (voir §9d)
- Possessions DD2024 SP-PO5 : 28 familles, 238 articles du SRD 5.2.1, 13 pages de règles, listes dynamiques (journal : `doc/LOG_CORRECTIONS_SRD2024_EQUIPEMENT.md`)
- Possessions DD2024 SP-PO5b : règles « Objets magiques » du SRD (9 pages, 9 tableaux, page de A à Z en listes `[[liste:objet|…]]`) et **357 descriptions d'objets retranscrites** depuis le PDF — 44 tableaux appelés par `[[tab:slug]]`, déclinaisons complétées de leur table (journal : `doc/LOG_CORRECTIONS_SRD2024_OBJETS_MAGIQUES.md`, méthode : §9e)
- Possessions DD3.5 SP-PO0→PO2 + SP-DRS2/DRS3 : `dd_equipements` restructurée (familles
  `dd_categorie_equipement`, prix, poids, attributs JSON, supplément), 269 articles du DRS 07 importés,
  règles Équipement et Objets magiques. **Tag `[[liste:equipement|famille=…|source=…]]` /
  `[[liste:objet|…]]`** : listes dynamiques dans les règles, `include/liste-parser.php`, chaîné dans
  `rendreTexteEnrichi()` (voir §9e). Journal des corrections de texte : `doc/LOG_CORRECTIONS_DRS07_DRS23.md`
- Aide à la saisie : `aideIcone()` sur les 13 champs soumis à un parser, contenu dans
  `include/aide-contextuelle.php` (une clé par jeu de parsers réellement appliqué)
- Déploiement SP-DP0→DP6 : bouton du header (local seulement) qui envoie par SFTP les fichiers
  modifiés vers OVH puis fait jouer les migrations par le serveur. Module local
  `admin/deploiement/`, **jamais transféré** ; paramètres hors projet
  (`C:/xampp/private/donjon-deploiement/`) ; exclusions = `.gitignore` + `.deployignore`.
  Moteur de migrations `include/migrations.php` + table `dd_migrations` (voir §6b)

### À faire (priorités)

- SP-PO3e (modifier un tag de liste déjà posé), SP-PO4 (écran des familles d'équipement), SP-PO6 (possessions du personnage).
  Les migrations `sql/2026-10-11_*`, `2026-10-15_*` et `2026-10-16_*` (dont les deux `…_sp-po5b.sql`) restent à jouer en production
- SP-IM6 : **seule phase du cycle d'import encore ouverte** — les descriptions des 8 classes
  DD2024, absentes du SRD, à saisir depuis le MdJ 2024. Tout le reste est livré le 2026-08-28 :
  classes complètes, 9 espèces, 38 options de classe en dons, et les 356 objets magiques du SRD
  redressés (rareté, harmonisation, catégorie, texte intégral). L'équipement part en `SP-E6`
- SP-PE8 : module Personnages (livrés : `SP-PE0→PE7` dont la vue Magie, `PE9→PE13` et la
  compaction `PE10a→s`). Reste : mode jeu (suivi PV et variables par ruleset) + passe responsive
  < 992px sur les blocs PE3→PE7
- SP-SY0 : arbitrage de la synchronisation du contenu local → prod (non prioritaire, voir §6c) —
  ajouter en prod le contenu local absent, sans jamais rien écraser
- SP-TB8 : écran du MJ (alimenté par `tab_ecran_mj` / `tab_ecran_ordre`)
- SP-TB9 : saisie des tableaux du ruleset DD3.5 (id 1)
- SP-C6 : profil "Mes sources" — suppléments publics tiers
- SP-E4 : `monstre-parser.php`, type liable `equipement` (SP-E5 soldée par SP-PO0)
- SP-T1 : Transférer/Dupliquer vers une autre campagne
- Autres phases ouvertes (détail dans §0) : SP-MA4c / MA5 / MA6e (magie), SP-DRS4 et SP-GL4 (lots
  suivants du DRS), SP-RS5 / RS6c (UI smartphone), SP-CP8 (outils de partie), SP-XC4 (premier export
  de classes joué en production)

---

## Structure clés du projet

```
donjon/
  compendium/        sorts.php, classes.php, monstres.php, … enregistrement.php
  campagnes/         index.php, enregistrement.php, …
  personnages/       fiche.php, enregistrement.php, …
  admin/             migrations.php, migrations-auto.php ; deploiement/ (LOCAL, jamais transféré)
  include/
    db.php           connexion PDO (charge config/db.config.php, qui définit BASE_URL)
    auth.php         requireAuth(), requireAdmin(), isMJ(), csrfField(), verifyCsrf(), canEditCompendium()
    helpers.php      h(), intParam(), strParam(), ownerFilter(), canEditCompendiumEntry(), …
    header.php / footer.php
    compendium-liste.php   moteur de liste générique
    monstre-parser.php     rendu stats monstre (rendreStatsMonstre())
    tableau-parser.php     tableaux dd_tableaux + tag [[tab:slug]]
    glossaire-parser.php   liaison auto des termes de glossaire (lierGlossaireAuto())
    migrations.php         moteur de migrations SQL (SP-DP5)
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
