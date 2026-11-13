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
| Affichage du ruleset | **Jamais rappelé dans les pages** (titre, badge, méta) — c'est le contexte du header (D-CP11) |

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
| `canEditCompendium()` | Droit d'ajout au compendium : admin, gestionnaire ou MJ (`j_mode_campagne`) (auth.php) |
| `canEditCompendiumOfficiel()` | Droit sur le contenu officiel (règles, tableaux, sources officielles) : admin ou gestionnaire (auth.php) |
| `canEditCompendiumEntry($db, ?int $res_j_id)` | Droit per-entry (helpers.php) |
| `getActiveResIds($db, $ruleset_id, $opts)` | Sources montrées : ressources actives (admin) + son supplément + supplément du MJ de la campagne de contexte (`pe_id` / `camp_id`) + suppléments publics si `supplements` (SP-RE) |
| `getActiveResIdsCampagne($db, $camp_id, $ruleset_id)` | Même règle, la campagne pour contexte |
| `getOrCreateUserSupplement($db, $j_id, $ruleset_id)` | Crée le supplément utilisateur si absent |
| `creerSupplementsMJ($db, $j_id)` | Crée les deux suppléments d'un MJ (activation du mode campagne) |

---

## Système de panels et z-index

| Élément | z-index | Rôle |
|---|---|---|
| `#ecran-mj` | 190 | Écran du MJ, surcouche plein écran (SP-TB8) |
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
   **L'ordre de jeu est l'ordre alphabétique du nom de fichier COMPLET** : une migration qui dépend
   d'une autre (colonne, table) doit porter un nom qui la suit — mettre le rang de la phase juste
   après la date (`AAAA-MM-JJ_<phase>_<sujet>.sql`), pas le sujet d'abord. Avant de livrer une série
   de migrations dépendantes, la rejouer dans l'ordre du moteur sur une copie de la base (D-CH5).

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
   production), `SP-XC` (export de classes vers la production), `SP-CH` (choix liés aux capacités de classe), `SP-DO` (dons DD3.5 : dons de guerrier, données techniques), `SP-NO` (module Notes : diffusion d'informations aux joueurs), `SP-MO` (import des monstres DD3.5 de l'ancienne application), `SP-CV` (import des scénarios, chapitres et rencontres de l'ancienne application), `SP-ML` (envoi de mails du site), `SP-JF` (import du Manuel des Joueurs de Faerûn : sorts, dons, classes de prestige, objets, domaines), `SP-DU` (duplication d'une entrée du compendium : classes, puis races), `SP-CR` (règles spéciales d'une classe, affichées après ses capacités), `SP-RE` (refonte de la sélection des ressources : ressources actives + suppléments de MJ), `SP-SY` (synchronisation du contenu
   local → production, en attente d'arbitrage).
2. **À chaque livraison**, cocher les phases terminées et ajouter les phases restantes
   dans §0, au format checklist markdown :
   ```markdown
   - [x] SP-TB1 — Moteur de rendu des tableaux
   - [ ] SP-TB8g — Contrôle visuel de l'écran du MJ
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
- Supplément utilisateur SP-C0→SP-C5 et SP-C7 : **fait sur les 8 entités** du compendium (`_visible`, menu ⋮ per-entry, source à 2 groupes)
- Sources simplifiées SP-RE0→RE6 (2026-11-11) : plus de sélection par utilisateur ni par campagne ; le compendium montre les ressources
  actives (`res_selection`, admin seul) + son supplément + celui du MJ de sa campagne + les suppléments de MJ publics (filtre « Suppléments
  de MJ », préférence `j_voir_supplements`). MJ = `j_mode_campagne`, supplément public / privé en bloc (`j_supplement_public`), drapeaux
  `_public` par entrée abandonnés (D-RE1 → D-RE6). Restent SP-RE2b (`sql/2026-11-11_sp-re1_*` **à jouer en production**, puis revoir les
  ressources actives), SP-RE7 (suppression de `dd_joueurs_sources` / `dd_campagnes_sources`) et SP-RE9 (contrôle visuel)
- Campagnes : campagnes → scénarios → chapitres → rencontres → oppositions
- Transfert/Duplication opposition SP-T0 (même campagne) : fait
- Équipements SP-E0→E3 : table `dd_equipements` (`sql/2026-06-20_equipements_sp-e0.sql`), liste, formulaire, fiche détail
- Header context buttons : cascade setters, partial `include/header-context.php`, endpoint AJAX
- Tableaux de règles SP-TB0→TB7 : table `dd_tableaux`, convention texte, tag `[[tab:slug]]`,
  UI de gestion, migration des tableaux HTML existants. Portée du tag : `reg_texte`, définitions
  de glossaire, `mo_stats` et les champs description du compendium. Composant CSS `.reg-tab*`
  dans `css/modules.css` (chargé partout) — voir §9c. **Catégories SP-TB12** : `dd_tableaux_categories`
  (9 catégories communes aux rulesets, dont « Compétence » ajoutée par SP-TB13) + `tab_tabc_id`, filtre de la liste et du sélecteur ; les deux
  migrations `sql/2026-11-07_sp-tb12*.sql` (dont le renvoi de toute la table) restent à jouer en production
- Écran du MJ SP-TB8a→f : surcouche plein écran `#ecran-mj` ouverte depuis la colonne d'outils des Campagnes,
  tableaux disposés **par campagne** (`dd_campagnes_ecran`, `camp_ecran_colonnes`) en 2 à 6 colonnes virtuelles,
  glisser-déposer, largeur 1 ou 2, repliage ; ajout, sélection proposée (`tab_ecran_mj`) et duplication d'une
  autre campagne du même ruleset (`include/ecran-mj.php`, `js/ecran-mj.js`, §9c). Reste SP-TB8g : contrôle
  visuel et `sql/2026-11-07_sp-tb8b_ecran_mj.sql` à jouer en production
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
- Choix de capacités de classe SP-CH0→CH5 : `cc_nb_choix` / `cap_choix_mode` déclarés dans le formulaire de classe,
  emplacements remplis sur la fiche (`dd_personnages_choix`, texte libre ou don lié au bloc Dons). Reste SP-CH6 :
  déclarer les autres capacités à choix du compendium
- Gestion d'un personnage par l'admin et le MJ SP-PE18a→d : helpers `peutGererPersonnage()` & co.
  (`include/personnage_helpers.php`, §7.5e) ; le MJ gère les personnages de ses campagnes (hors suppression),
  les y ajoute / retire depuis `campagnes/campagne.php`, et les affecte à un joueur (`pe_affecte_par_j_id`,
  transfert avec trace). Reste SP-PE18e : contrôle visuel. Actions groupées de la liste SP-PE19 (affecter à une campagne / à un joueur, panneau
  `include/ajax/modifier/personnages-groupe.php`, admin et MJ seulement)
- Total de compétence SP-PE20 / PE21 : modificateur divers par compétence (`pec_mod_divers` + origine) et synergies DD3.5
  (`dd_competences_synergies`, 28 chargées, saisie au formulaire de compétence ; conditionnelles affichées hors total).
  Calcul unique `totalCompetence()`, repris par l'accès aux notes
- Aide à la saisie : `aideIcone()` sur les 13 champs soumis à un parser, contenu dans
  `include/aide-contextuelle.php` (une clé par jeu de parsers réellement appliqué)
- Déploiement SP-DP0→DP6 : bouton du header (local seulement) qui envoie par SFTP les fichiers
  modifiés vers OVH puis fait jouer les migrations par le serveur. Module local
  `admin/deploiement/`, **jamais transféré** ; paramètres hors projet
  (`C:/xampp/private/donjon-deploiement/`) ; exclusions = `.gitignore` + `.deployignore`.
  Moteur de migrations `include/migrations.php` + table `dd_migrations` (voir §6b)

### À faire (priorités)

- SP-PO3e (modifier un tag de liste déjà posé), SP-PO4 (écran des familles d'équipement), SP-PO13 (matériaux spéciaux), SP-PO14 (suppression des potions / baguettes DD3.5 masquées). Possessions livrées le 2026-11-06/07 (SP-PO6 → PO11 pour DD3.5 : schéma, moteur `include/objet-compose.php`, page Possessions, sélecteur, compositeur des sept types, usage en jeu ; SP-PO12 pour DD2024 : valeur par rareté, harmonisation).
  **Toutes les migrations jusqu'aux `2026-11-06_*` comprises sont jouées en production** (constaté sur le dump
  de production du 2026-11-07, qui a servi à recharger la base locale — D-TB23)
- SP-IM6 : **seule phase du cycle d'import encore ouverte** — les descriptions des 8 classes
  DD2024, absentes du SRD, à saisir depuis le MdJ 2024. Tout le reste est livré le 2026-08-28 :
  classes complètes, 9 espèces, 38 options de classe en dons, et les 356 objets magiques du SRD
  redressés (rareté, harmonisation, catégorie, texte intégral). L'équipement part en `SP-E6`
- SP-PE8 : module Personnages (livrés : `SP-PE0→PE7` dont la vue Magie, `PE9→PE13` et la
  compaction `PE10a→s`). Reste : mode jeu (suivi PV et variables par ruleset) + passe responsive
  < 992px sur les blocs PE3→PE7
- SP-NO8 : module Notes (arbitrage D-NO0 → D-NO4 ; SP-NO0 → NO7 et NO9 (actions groupées) livrés : schéma, moteur d'accès, formulaire,
  interfaces du MJ `campagnes/notes.php` et du joueur `personnages/notes.php`, D-NO5 → D-NO16, `doc/METIER_11_Notes.md`) — notes
  du MJ à tronc commun + sections conditionnées par compétence (score de compétence ≥ DD, OU), diffusées aux personnages ;
  import v1 (`admin/import-notes-v1.php`) joué en local dans L'Empire des Anges (migrations jouées en production) ;
  SP-NO10 : dupliquer une note d'une autre campagne ;
  SP-NO11a livré (diffusion à toute la campagne, `no_diffusion_campagne`, D-NO19 → D-NO22, migration jouée en production)
- SP-ML4 : mail de mot de passe oublié toujours non reçu en production (2026-11-08), malgré un envoi signalé comme réussi.
  Envoi SMTP livré (`envoyerMail()`, PHPMailer dans `include/phpmailer/`). `admin/test-email.php` choisit un compte actif et peut
  imiter le mail de réinitialisation (SP-ML5, ML6). Reste à tester vers une adresse non alias, puis à saisir le support OVH si nécessaire
- Règles spéciales de classe SP-CR1 (2026-11-11) : champ `cla_regles_speciales`, affiché sans libellé après les capacités de la fiche de classe
  (D-CR1). SP-CR4 livré (tableaux HTML des capacités → `dd_tableaux`, D-CR2). Restent SP-CR2 (`sql/2026-11-11_sp-cr1_*` et `sql/2026-11-11_sp-cr4_*` **à jouer en production**), SP-CR3 (saisir les règles des classes concernées) et SP-CR5 (tableaux HTML restants : races, dons, sorts, objets)
- Fiche de personnage SP-PE22 (2026-11-12) : trois CA en DD3.5 (`pe_ca_depourvu`, `pe_ca_contact`), BBA calculé (`bbaTotalPersonnage()` / `formatBba()`, 4 attaques au plus),
  vision et déplacement dans les deux rulesets, rangée de combat sous les caractéristiques, bonus de maîtrise DD2024 déplacé de l'en-tête (D-PE22a → c).
  Reste SP-PE22f : `sql/2026-11-12_sp-pe22_ca_vision_deplacement.sql` **à jouer en production**, contrôle visuel du formulaire de modification
- SP-SY0 : arbitrage de la synchronisation du contenu local → prod (non prioritaire, voir §6c) —
  ajouter en prod le contenu local absent, sans jamais rien écraser
- SP-TB8g : contrôle visuel de l'écran du MJ, migration `2026-11-07_sp-tb8b_ecran_mj.sql` à jouer en production
- Pages Campagnes SP-CP10 → CP12 (2026-11-07) : onglets en page mémorisés en session, oppositions en fiches à sous-menu avec suivi
  des PV (`dd_oppositions_pv`, `opp_nombre`, `opp_pv_max`), images jusqu'à 15 Mo. Restent SP-CP11b (`sql/2026-11-07_sp-cp11_oppositions_pv.sql`
  **à jouer en production**), SP-CP11d (`sql/2026-11-08_sp-cv1b_effectifs_oppositions.sql`, effectifs lus dans la composition, à jouer après `sp-cv1`) et SP-CP12b (limite d'envoi PHP d'OVH à vérifier)
- SP-TB9 : saisie des tableaux du ruleset DD3.5 (id 1)
- SP-RE2b / RE7 / RE9 : migration des sources simplifiées à jouer en production, puis suppression des anciennes tables de sélection
- SP-E4 : `monstre-parser.php`, type liable `equipement` (SP-E5 soldée par SP-PO0)
- SP-T1 : Transférer/Dupliquer vers une autre campagne
- Compétences DD3.5 SP-DRS4b (2026-11-07) : texte intégral du DRS 04 pour les 36 fiches mères et 40 tableaux
  `competence-*` (catégorie Compétence) — `sql/2026-11-08_sp-drs4b_competences_dd35.sql`, **à jouer en production**
  (SP-DRS4d) ; journal `doc/LOG_CORRECTIONS_DRS04.md` §5
- Monstres du DRS 29 à 40 (2026-11-07) : règles SP-DRS9a (chapitre « Les monstres »), dons SP-DRS9b (tag
  `[[liste:don|famille=…]]`), archétypes SP-DRS9c (Races, type Archétype), FP SP-MO7a — migrations
  `sql/2026-11-08_sp-drs9*` et `_sp-mo7a_*` jouées en local, **à jouer en production**. Fiches SP-MO7 :
  435 fiches importées en local (mo_id 3001-3435, `sql/2026-11-08_sp-mo7c_*`, jouée en production le 2026-11-08,
  générateur `tools/generer-sp-mo7-monstres-drs.php`) ; journal `doc/LOG_CORRECTIONS_DRS29_40.md`
- Classes de prestige et de PNJ DD3.5 SP-DRS10a (2026-11-09) : DRS 08a, 08b, 15 — 15 prestiges mis en conformité (conditions, armes,
  compétences liées domaine par domaine, sorts, capacités en texte intégral avec variantes par classe D-DRS11), 5 classes de PNJ créées,
  racine de règles « Les classes » et 4 termes de glossaire — `sql/2026-11-09_sp-drs10_classes_prestige_pnj_dd35.sql`, jouée en local,
  **à jouer en production** (SP-DRS10c) ; contrôle visuel SP-DRS10b ; journal `doc/LOG_CORRECTIONS_DRS08_15.md`
- Scénarios v1 de L'Empire des Anges SP-CV1 (2026-11-07) : 2 scénarios, 10 chapitres, 64 rencontres, 119 oppositions
  recopiées des fiches SP-MO3 — `sql/2026-11-08_sp-cv1_campagne_empire_v1.sql`, contrôle visuel validé (SP-CV2), jouée en production le 2026-11-08 (SP-CV3)
  ; journal `doc/LOG_IMPORT_CAMPAGNE_EMPIRE_V1.md`
- Autres phases ouvertes (détail dans §0) : SP-MA4c / MA5 / MA6e (magie), SP-DRS4d / DRS4e, SP-DRS5 et SP-GL4 (lots
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
