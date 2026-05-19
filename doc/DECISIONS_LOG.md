# Codex DD v2 — Journal des décisions

Format : `[DATE] Sujet — Décision — Raison`

---

## Phase de conception

**[2025] Architecture générale**
PHP classique sans framework. JS vanilla. CSS maison.
→ Maîtrise totale du code, compatibilité OVH garantie.

**[2025] Arborescence**
Hybride : dossiers par module (PHP) + assets partagés (js/, css/).
→ Groupement métier des pages + chemins d'include stables (toujours ../include/).

**[2025] Rôles utilisateur**
Suppression du rôle MJ structurel de la v1. Deux rôles fixes : admin (j_admin) et gestionnaire compendium (j_compendium_manager). MJ = rôle contextuel inféré de camp_j_id.
→ Chaque utilisateur peut être MJ de ses propres campagnes.

**[2025] Sélection des sources**
Chaîne de priorité : campagne > personnel > défaut ruleset.
Contexte déterminé par last_pe_id en session.
→ Pas de sélection manuelle du contexte par l'utilisateur.

**[2025] Notes MJ**
Suppression de pe_notes_mj. Remplacement par cp_notes_mj dans dd_campagnes_personnages.
→ Notes MJ propres à chaque association personnage-campagne. Archivage prévu en v2.

**[2025] Ressources**
dd_ressources reste neutre (pas de camp_id).
Sélection via tables de liaison : dd_joueurs_sources et dd_campagnes_sources.
→ Une ressource peut être sélectionnée par N utilisateurs et N campagnes simultanément.

**[2025] Contenu homebrew**
Même formulaire que le compendium global + champ caché _camp_id.
Le MJ crée une entrée dd_ressources (res_j_id = j_id) pour son recueil maison.
→ Réutilisation du code existant, distinction global/homebrew par _camp_id.

**[2025] Univers wiki**
Univers agnostiques du ruleset. Visibilité : public (sélectionnable par autres MJs) ou privé.
Articles : visible (ua_visible=1) ou caché (MJ seul).
Délégation en v1 : globale sur l'univers entier (dd_univers_droits).
Granularité par article prévue en v2.
→ Simplicité en v1 tout en posant les bases de la v2.

~~**[2025] Balises PHP** — SUPERSÉDÉ~~
~~Balises courtes `<?` et `?>`, syntaxe alternative sans accolades sauf function().~~
~~→ Convention maintenue depuis la v1 — incompatible avec certaines configs XAMPP, voir correction ci-dessous.~~

---

## Phase 1 — Socle technique

**[2025] CSRF**
Token en session, field généré par csrfField(), vérifié par verifyCsrf() sur tout POST.
Token accessible en JS via getCsrfToken() dans main.js.

**[2025] Remember me**
Token aléatoire (random_bytes(32)) stocké en base, cookie sécurisé 30j.
Vérification automatique dans auth.php au chargement de chaque page.

**[2025] getActiveResIds()**
Encapsulé dans helpers.php. Retourne un array de res_id selon la chaîne de priorité.
À appeler en début de toute page compendium/personnage nécessitant le filtrage sources.

**[2025] Préfixe tables — retour à dd_**
Développement en local sur base XAMPP dédiée v2 → préfixe dd_ conservé.
Le renommage en dd2_ pour OVH sera géré par un script RENAME TABLE au déploiement.
→ Code plus lisible, pas de friction en développement.

**[2025] BASE_URL — URLs relatives au sous-répertoire**
Site déployé sous /donjon/ en local et en production.
Constante BASE_URL = '/donjon' définie dans include/db.php.
Toutes les URLs passent par BASE_URL — aucune URL absolue codée en dur.
→ Zéro changement de code entre local et production.

**[2025] Balises PHP — correction convention**
<?php pour les blocs logiques, <?= pour l'affichage inline.
(Correction de la convention initiale <? court — incompatible avec certaines configs XAMPP.)
→ Compatible tous environnements sans configuration supplémentaire.

**[2025] DEV_MODE — mail en développement local**
define('DEV_MODE', true) dans include/db.php.
En DEV_MODE : lien de réinitialisation affiché directement dans la page.
En production : DEV_MODE = false, envoi par mail().
→ Évite la configuration SMTP sous XAMPP en développement.

**[2025] Responsive — exception module Campagnes**
Modules responsives (seuil 992px) : Compendium, Personnages, Wiki/Univers, Profil, Auth, Admin.
Module NON responsive : Campagnes — usage desktop exclusif (MJ en partie).
→ Complexité réduite sur un module à usage desktop uniquement.

**[2025] Module Profil utilisateur**
Trois sections indépendantes (champ hidden section) : identité, mot de passe, paramètres.
Liste de paramètres évolutive — chaque nouveau paramètre s'ajoute sans refonte.
→ Extensible sans refonte de la page.

**[2025] Ordre de développement des modules**
Compendium en premier (alimentation données) → Admin → Personnages → Campagnes → Wiki.
→ Les données du compendium sont nécessaires à tous les autres modules. L'admin permet de gérer les ressources et utilisateurs avant d'accueillir des joueurs.

---

## Phase 2 — Compendium

**[2025] Moteur de liste commun — $listConfig**
Toutes les pages du compendium utilisent un seul fichier include/compendium-liste.php.
Chaque page déclare un tableau $listConfig (colonnes, filtres, URLs AJAX, bulk actions)
puis inclut le moteur qui gère tout le rendu.
→ Code commun maintenable en un seul endroit, cohérence visuelle garantie entre toutes les pages.

**[2025] Tri et filtrage — rechargement GET côté serveur**
Tri et filtrage déclenchent un rechargement de page via GET.
Colonne de tri validée par whitelist (colonnes déclarées avec tri = true) avant injection SQL.
→ Sécurité ORDER BY + URL bookmarkable avec filtres actifs.

**[2025] Pagination — côté serveur**
Pagination SQL (LIMIT/OFFSET). Taille de page = $_SESSION['j_items_par_page'] (profil utilisateur).
→ Cohérent avec le paramètre profil déjà prévu. Adapté aux listes potentiellement longues.

**[2025] Filtre sources dans les listes**
Le SELECT sources affiche les sources de la sélection active (getActiveResIds()).
L'utilisateur peut restreindre à un sous-ensemble. Intersection des deux contraintes en ET.
→ L'utilisateur ne sort jamais de sa sélection de base.

**[2025] Filtres spécifiques par ruleset**
Les critères de filtre intermédiaires peuvent varier selon le ruleset.
La page gère le conditionnel avant de construire $listConfig['filtres'].
→ Le moteur compendium-liste.php reste générique.

**[2025] Actions groupées (bulk)**
Supprimer est la seule action bulk commune à toutes les listes.
Les autres actions bulk sont déclarées dans $listConfig['bulk_actions'], spécifiques à chaque liste.
→ Flexibilité par liste sans complexifier le moteur commun.

**[2025] Confirmation de suppression — div inline**
La confirmation remplace temporairement la ligne dans le tableau.
Pas de window.confirm() natif (non stylable).
→ Cohérence visuelle avec le reste du site.

**[2025] enregistrement.php — mode AJAX**
compendium/enregistrement.php détecte $_GET['ajax'] et retourne JSON {ok, id, url_detail}
pour les saves individuels (depuis detail-pp/modification).
Mode normal (bulk) : redirect + flash message.
→ Permet à apresModification() de piloter les rafraîchissements côté JS.

**[2025] Responsive listes compendium**
Classes CSS définies une fois dans modules.css :
- .col-primary : toujours visible — ligne principale sur mobile
- .col-secondary : sous-ligne sur mobile (font 0.8rem, style distinctif)
- .col-action : masqué sur mobile (boutons modifier/supprimer)
- .bulk-check : masqué sur mobile (cases à cocher)
→ Responsive géré uniquement par CSS, sans JS.

**[2025] Bouton Modifier dans detail-pp**
Le HTML de detail-pp contient le bouton Modifier si canEditCompendium() — vérification serveur.
Il appelle ouvrirModifier(url, id). Le contexte est déjà mémorisé dans _detailPpContext.
Ce pattern s'applique à toute ouverture de detail-pp depuis n'importe quelle page du site.
→ Droits vérifiés serveur, pas exposés au JS.

**[2025] Pattern detail-pp — contexte d'ouverture**
actualiserPage(url, params, context) mémorise le contexte dans _detailPpContext :
- 'liste' : ouverture depuis une liste compendium
- 'externe' : ouverture depuis toute autre page (défaut)

apresModification() exploite ce contexte :
- Toujours : rafraîchit #detail-pp
- Si 'liste' : appelle aussi rafraichirListe() = window.location.reload()
  (le reload préserve les GET params de tri et filtrage)
- Si 'externe' : ne touche pas à la page appelante

Ce pattern est transversal — il s'applique aussi aux modules Personnages et Campagnes
quand ils ouvrent des éléments du compendium depuis leurs propres pages.
→ Un seul mécanisme pour tous les contextes d'ouverture de detail-pp dans tout le site.

**[2025] so_composante — champ texte libre (correction)**
so_composante n'est pas un champ calculé depuis les booléens so_vocal/so_gestuel/so_materiel.
C'est un champ texte libre contenant le détail des composantes matérielles nécessaires au lancement.
Le script de migration migration_sorts_v1_v2.sql doit être corrigé en conséquence
(copie directe depuis v1 plutôt que construction par CONCAT).
→ Cohérence avec le schéma réel dd_sorts.

**[2025] dd_domaines et dd_sortdomaine — conservés en v2**
Les tables dd_domaines et dd_sortdomaine sont maintenues en v2 pour le ruleset DD3.5.
Importées manuellement depuis la v1.
Nota : les deux tables sont en MyISAM/charset non-utf8mb4 (héritage v1).
Conversion InnoDB + utf8mb4 à planifier lors d'une prochaine migration.
→ Les domaines divins DD3.5 restent fonctionnels (affichage sort, formulaire).

**[2025] so_resume — réintégré dans dd_sorts**
Champ so_resume (TEXT, null) réintégré après suppression initiale lors de la conception du schéma.
Affiché dans le formulaire modifier DD3.5 uniquement.
Prévu pour affichage dans la liste sorts.php dans une version ultérieure.
→ Cohérence avec l'architecture DD3.5 de la v1.

**[2025] Niveaux sorts/domaines dans formulaire — liste 0 à 9**
La liste déroulante des niveaux pour les classes et domaines va de 0 à 9 (pas 20).
La valeur 0 signifie "non attribué" et s'affiche comme option vide
(<option value="0"></option> puis <option value="1">1</option>...).
Les entrées avec niveau=0 ne sont pas enregistrées dans dd_sortclasse/dd_sortdomaine.
→ Clarté formulaire + correspondance avec les niveaux réels des sorts DD.

**[2025] Éditeur texte enrichi — TinyMCE retenu**
Besoin d'images dans wiki/univers et personnages → Quill.js écarté (gestion images native absente,
workaround base64 inacceptable). TinyMCE via CDN tiny.cloud, clé API gratuite.
Deux configurations : minimale (sans images) pour sorts/dons/classes/races/historiques,
complète (avec images) pour wiki/univers et personnages.
Clé API : constante TINYMCE_API_KEY dans include/db.php.
Upload images : include/ajax/upload-image.php → img/uploads/ (hors .gitignore).
→ Un seul éditeur cohérent dans toute l'application.

**[2025] Organisation CSS — fichiers par module**
modules.css conserve uniquement les styles globaux (login, dashboard, profil, header).
Chaque module fonctionnel a son propre fichier CSS chargé conditionnellement :
- compendium-modules.css (Phase 2, existant)
- personnages-modules.css (Phase 3, à créer)
- campagnes-modules.css (Phase 4, à créer)
- wiki-modules.css (Phase 5, à créer)
- admin-modules.css (Phase Admin, à créer)
Chargement via $css_module dans header.php — même pattern que $js_module.
→ Poids réduit par page, maintenabilité améliorée, cohérence avec le pattern JS existant.

**[2025] dd_historiques — entité compendium DD2024 uniquement**
Les historiques de personnage sont une mécanique spécifique au ruleset DD2024, absente de DD3.5.
La table dd_historiques (préfixe hi, champ hi_res_id) est intégrée au périmètre du compendium.
La page compendium/historiques.php et ses endpoints AJAX ne sont accessibles et affichés
dans la navigation que si $_SESSION['rulesetRep'] === 'DD2024'.
→ Le moteur compendium-liste.php reste générique ; le conditionnel est géré dans le contrôleur.

---

## Phase 2 — Compétences

**[2025] dd_competences — Schéma existant, pas de table de liaison**
La table dd_competences existait déjà avec le schéma :
comp_id, comp_nom, comp_car_id (FK dd_caracteristiques), comp_malusArmure (INT),
comp_formation (INT), comp_description (TEXT), comp_res_id, comp_ruleset_var_id.
Pas de comp_camp_id (pas de homebrew pour les compétences).
→ Aucune migration nécessaire. Les champs DD3.5 (malusArmure, formation) sont présents
  pour les deux rulesets : les compétences DD2024 ont aussi une caractéristique associée.

**[2025] champ_camp => false — extension du moteur compendium-liste.php**
Le moteur inférait systématiquement <alias>_camp_id IS NULL depuis champ_id,
causant une erreur SQL pour dd_competences qui n'a pas comp_camp_id.
Solution : support de champ_camp => false dans $listConfig pour désactiver le filtre camp.
Logique révisée : !array_key_exists → auto-inférer | string → filtre direct | false → omis.
Rétro-compatible : les pages existantes (sorts, dons, classes, races) ne déclarent pas
champ_camp, donc elles continuent d'utiliser l'auto-inférence.
→ Moteur plus robuste, extensible pour toute entité sans homebrew.

**[2025] comp_car_id — FK dd_caracteristiques, filtre via query directe**
Le filtre Caractéristique utilise une query sur dd_caracteristiques (car_id, car_nom),
comme les filtres sur dd_data_don pour les dons. Pas de UNION SELECT statique.
→ Cohérent avec le pattern query/query_params du moteur.

**[2025] comp_malusArmure — input number, pas checkbox**
Le champ est de type INT dans le schéma. Rendu comme <input type="number" min="0">
pour permettre des valeurs > 1 si nécessaire, tout en restant utilisable comme booléen (0/1).
→ Fidélité au schéma existant sans hypothèse sur les valeurs possibles.

**[2025] Filtre formation — valeur 1 uniquement (limitation moteur)**
Le moteur compendium-liste.php ignore les valeurs '0' dans les filtres métier
(condition `$val === '0'`). Seul "Formation requise" (= 1) est donc filtrable.
Filtrer sur "Sans formation" (= 0) n'est pas possible sans modifier le moteur.
→ Limitation documentée et acceptée. Cas d'usage principal couvert.

---

## Phase Admin — Zone d'administration

**[2025] Architecture admin — moteur distinct de compendium-liste.php**
La zone admin utilise son propre moteur include/admin-liste.php, distinct de compendium-liste.php.
Les contraintes sont structurellement différentes : pas de filtre sources, pas de filtre ruleset,
pas d'inférence _camp_id IS NULL, accès conditionné par requireAdmin() et non requireAuth().
→ Séparation des responsabilités : le moteur compendium reste simple et sans branchements admin.

**[2025] Zone admin — 2 blocs fonctionnels (pas 3)**
La zone admin comporte 2 blocs : A (Utilisateurs) et B (Ressources).
Le bloc C (Variables / dd_variables) est abandonné : l'interface de suppression d'une variable
ruleset serait trop préjudiciable en cas d'erreur. Les variables sont gérées via phpMyAdmin.
→ Sécurité opérationnelle : les données de configuration critiques restent hors UI.

**[2025] Suppression utilisateur — désactivation, jamais DELETE**
La "suppression" d'un utilisateur via l'interface admin est une désactivation : j_visible = 0.
Aucun DELETE physique sur dd_joueurs depuis l'UI, quelle que soit la demande.
Les données de jeu (personnages, campagnes, univers, notes) sont conservées intactes.
Les utilisateurs désactivés restent visibles dans la liste avec indicateur et action "Réactiver".
→ Préservation de l'intégrité référentielle. Une fonctionnalité future permettra de
  localiser et réaffecter les données orphelines.

**[2025] Suppression ressource — vérification sur 7 tables**
La suppression d'une ressource est conditionnée à l'absence de données dans l'ensemble
du périmètre compendium : dd_classes, dd_races, dd_sorts, dd_dons, dd_competences,
dd_historiques, dd_objets_magiques.
Si des données existent, la suppression est refusée avec un message listant les compteurs
par table. La confirmation inline affiche ces compteurs avant validation.
→ Intégrité des données du compendium garantie sans dépendre des contraintes FK MySQL.

**[2025] Périmètre compendium — 7 tables avec res_id**
Le périmètre officiel des entités du compendium filtrées par ressource est :
dd_classes (cla_res_id), dd_races (ra_res_id), dd_sorts (so_res_id), dd_dons (do_res_id),
dd_competences (comp_res_id), dd_historiques (hi_res_id), dd_objets_magiques (om_res_id).
Ce périmètre est la référence pour toute vérification de dépendances (admin ressources).
→ Référence explicite pour éviter les oublis lors des vérifications de suppression.

**[2025] Mot de passe utilisateur en mode ajout**
Lors de la création d'un utilisateur via l'interface admin, l'admin saisit un mot de passe temporaire.
Le champ mot de passe est absent du formulaire de modification (édition d'un utilisateur existant).
La réinitialisation de mot de passe reste gérée par le flux profil/mot-de-passe-oublie.php.
→ Séparation claire entre création et gestion — pas de régression sur le flux reset MDP existant.

---

## Phase 2 — Profil utilisateur / Sélection des sources

**[2025-05] Sélection des sources — section profil**
Ajout d'une quatrième section "Mes sources" dans profil/index.php (pattern section hidden existant).
L'utilisateur choisit, pour le ruleset actif, quelles ressources globales alimentent son compendium.
La sélection est stockée dans dd_joueurs_sources (js_j_id, js_res_id, js_ruleset_var_id).
Sauvegarde par DELETE + INSERT en bloc (stratégie replace-all) — volume faible, pas de diff ligne.
→ Cohérent avec la chaîne de priorité existante dans getActiveResIds() (priorité 2).

**[2025-05] Sélection des sources — périmètre affiché**
Seules les ressources globales du ruleset actif sont proposées :
  WHERE res_ruleset_var_id = :ruleset_var_id AND res_j_id IS NULL
Le ruleset est lu depuis $_SESSION['ruleset_var_id'] côté serveur (pas depuis le formulaire).
→ Isolation par ruleset conforme à la structure de dd_joueurs_sources (js_ruleset_var_id).
→ Les ressources homebrew (res_j_id IS NOT NULL) ne sont pas gérées depuis le profil.

**[2025-05] Sélection des sources — zéro sélection autorisé**
Si l'utilisateur décoche toutes les ressources, les lignes dd_joueurs_sources sont supprimées.
getActiveResIds() retombe alors sur la priorité 3 (res_selection = 1 — défaut absolu).
Un message explicite informe l'utilisateur de ce comportement lors de la sauvegarde.
→ Pas de contrainte min=1 — permet à l'utilisateur de "réinitialiser" sa sélection proprement.

**[2025-05] Sélection des sources — validation serveur des res_id reçus**
Chaque res_id reçu en POST est revalidé contre la liste des ressources globales du ruleset actif.
Aucun res_id étranger (autre ruleset, homebrew) ne peut être inséré via manipulation du formulaire.
→ Sécurité : pas de confiance implicite dans les valeurs POST.

**[2025-05] Homebrew campagne vs homebrew profil — décision d'architecture**
Le contenu homebrew reste exclusivement rattaché à une campagne (res_j_id NOT NULL, res_camp_id NOT NULL).
Aucun homebrew "profil" (res_j_id NOT NULL, res_camp_id IS NULL) n'est implémenté à ce stade.

Le combinaison res_j_id NOT NULL AND res_camp_id IS NULL est **réservée** pour un futur homebrew profil.
Elle ne doit pas être utilisée à d'autres fins.

Si ce besoin est implémenté ultérieurement, les impacts seront :
- getActiveResIds() : merge additionnel du homebrew profil (res_j_id = j_id AND res_camp_id IS NULL)
  dans le résultat, en complément des sources globales actives, quelle que soit la priorité.
- compendium-liste.php : assouplissement du filtre champ_camp IS NULL pour inclure
  les ressources homebrew profil du joueur connecté.
- UI profil : nouvelle section de gestion du recueil personnel (création / suppression).
- UI création : point d'entrée sans campagne associée (res_camp_id = NULL).
→ Schéma BDD déjà compatible. Effort estimé : modéré, risque principal sur compendium-liste.php.

---

## Phase 2 — Races

**[2025-05] dd_races — suppressions des modificateurs de caractéristiques**
Les champs `ra_modifFor`, `ra_modifCon`, `ra_modifDex`, `ra_modifInt`, `ra_modifSag`, `ra_modifCha`
et `ra_origine` présents en v1 sont supprimés du schéma v2.
Les modificateurs de caractéristiques deviennent des **capacités spéciales** parmi les autres,
stockées dans `dd_capacites_speciales` et liées via `dd_race_capacite`.
→ Uniformisation du modèle de données. Flexibilité accrue (pas de limite à 6 attributs nommés en dur).

**[2025-05] dd_race_capacite — pas de cr_niveau, ajout de cr_ordre**
Pas de champ `cr_niveau` dans `dd_race_capacite` : une race confère immédiatement l'ensemble
de ses capacités raciales, sans notion de niveau d'acquisition (contrairement à `dd_classe_capacite`).
Ajout de `cr_ordre` (tinyint, défaut 0) pour l'ordre d'affichage.
`cr_ordre` est géré par **drag & drop** dans le formulaire — aucune saisie manuelle.
La valeur est calculée depuis l'ordre effectif des lignes dans le DOM au moment du submit.
→ UX cohérente avec les attentes d'un outil de gestion de compendium.

**[2025-05] cap_type — usage limité à l'affichage, DD3.5 uniquement**
Le champ `cap_type` de `dd_capacites_speciales` est conservé tel quel (valeurs libres : Ext, Mag, Sur…).
En DD3.5 : affiché entre parenthèses après le nom de la capacité dans le detail-pp.
En DD2024 : non affiché.
Le détournement v1 des valeurs `origine`, `vitesse`, `taille` est abandonné.
→ La v2 n'impose pas de valeurs spéciales à cap_type pour les races.

**[2025-05] dd_race_type — sélecteur toujours affiché dans la liste**
Le filtre par type de race est présent dans la liste `races.php` pour DD3.5 et DD2024.
Rationale : de futurs rulesets pourraient introduire de nouveaux types de race.
→ Le moteur de liste reste pertinent sans modification future si de nouveaux types sont ajoutés.

**[2025-05] Suppression race — vérification dépendances dd_personnages**
Avant toute suppression d'une race, vérification que `dd_personnages.pe_ra_id` et `pe_arc_id`
ne référencent pas la race ciblée.
Si des personnages dépendants existent, la suppression est refusée avec un message explicite.
Suppression des lignes `dd_race_capacite` en cascade. Les entrées `dd_capacites_speciales`
ne sont pas supprimées (table partagée avec les classes).
→ Intégrité référentielle garantie côté applicatif (cohérent avec le pattern admin/ressources).

**[2025-05] Formulaire race — section 3 masquée en mode création**
La section Capacités raciales (Section 3) n'est disponible qu'après la première sauvegarde de la race.
En mode création, un message invite à enregistrer d'abord la race (Section 1 + optionnellement Section 2).
→ Pattern identique à la Section 3 du formulaire classe (classe-modifier.php).

**[2025-05] Payload capacités races — pattern identique aux classes**
Les capacités raciales sont transmises via un champ caché `capacites_payload` (JSON).
Le JSON est construit au moment du submit depuis l'état du DOM (ordre drag & drop inclus).
Actions possibles par entrée : `existing` (mise à jour ordre), `new` (création cap + lien), `delete` (suppression lien).
La suppression d'un lien (action=delete) ne supprime pas l'entrée `dd_capacites_speciales`.
→ Réutilisation du pattern éprouvé sur les classes — cohérence technique et UX.

---

## Mise en page — Thèmes et overlays

**[2026-05] Système de thèmes — deux templates CSS**
Deux thèmes disponibles : `dark` (sombre, défaut — identique à l'existant) et `light` (clair "Parchemin").
Mécanisme : classe `theme-dark` ou `theme-light` sur `<body>`, pilotée par `$_SESSION['j_theme']`.
Les variables CSS (--clr-bg, --clr-surface, etc.) sont déclarées sous `body.theme-dark` et
`body.theme-light` dans main.css — plus sous `:root`. Les variables communes (typo, espacement,
rayons, layout) restent dans `:root`.
Stockage : champ `j_theme ENUM('dark','light') DEFAULT 'dark'` dans `dd_joueurs`.
Session : `$_SESSION['j_theme']` chargé dans `startUserSession()` (auth.php).
Choix utilisateur : radio buttons dans la section Paramètres de profil/index.php.
→ Zéro impact sur la structure HTML des pages — seules les couleurs changent.
→ Extensible : un troisième thème s'ajoute en déclarant `body.theme-xxx` dans main.css
  et en ajoutant la valeur au ENUM et à la whitelist de validation.

**[2026-05] Thème clair "Parchemin" — palette**
Fonds : #f4f1eb (bg), #ffffff (surface), #eae6dd (surface-2 et surface-alt).
Accents : #8b2020 (rouge bordeaux), #6b4e1f (or patiné).
Texte : #2a2015 (principal), #7a6e5a (atténué).
Bordures : #d5cfc3.
États : success #2a7a3b, warning #a06010, danger #c0392b.
Blocs burger (box-data) : fond #f9f6f0, bordure #d5cfc3 — harmonieux sur le thème clair.
→ Ambiance grimoire/manuscrit médiéval, cohérente avec l'univers DD.

**[2026-05] Thème sombre — correction bug table-classe-niv**
Bug identifié : `.table-classe-niv th` utilisait `background: var(--clr-surface-alt, #f5efe6)`.
La variable `--clr-surface-alt` n'était pas définie → fallback `#f5efe6` (fond clair)
avec texte `--clr-text` clair → en-tête illisible (texte clair sur fond clair).
Correction : `--clr-surface-alt` est maintenant définie dans chaque thème :
  - `body.theme-dark`  → `--clr-surface-alt: #0f3460` (bleu foncé, texte --clr-text-muted lisible)
  - `body.theme-light` → `--clr-surface-alt: #eae6dd` (beige parchemin)
Aucune modification du PHP nécessaire — la variable CSS est simplement définie.
→ Le fallback ne s'active plus ; la lisibilité est garantie dans les deux thèmes.

**[2026-05] Overlays élargis — tables de progression de classe**
`.overlay-panel` : max-width 720px → **960px** (width 90% → 92%).
`.overlay-panel--edit` : max-width 860px → **1040px**.
Les tables de classe (20+ colonnes : niveaux, BBA, jets, sorts/jour) nécessitent cet espace.
Sur mobile (≤991px) : width 98%, max-height 92vh — légère adaptation responsive.
→ Modification dans main.css uniquement, sans impact sur les autres modules.

**[2026-05] Sélecteur de thème dans le profil — radio buttons stylés**
Composant `.theme-selector` / `.theme-option` ajouté dans css/modules.css
(après le bloc `.toggle-label`).
Deux radio buttons visuellement transformés en boutons avec bordure active sur la valeur sélectionnée.
Couleur active : --clr-accent-2 (or/bordeaux selon le thème actif).
→ Cohérent avec le style des toggles existants dans la section Paramètres.

**[2026-05] Objets magiques — com_est_calcule vs IDs hardcodés**
La V1 hardcodait les IDs de catégorie (4=baguettes, 14=parchemins, 15=potions, 2=armes, 3=armures)
directement dans le template `descriptionOM.php`.
→ En V2 : champ `com_est_calcule tinyint(1)` ajouté dans `dd_categorie_objet_magique`.
Le template DD3.5 lit `$om['com_est_calcule']` et branche sur le calcul auto si = 1.
Le template DD2024 ignore toujours ce champ : pas de calcul NLS/prix en DD2024.
→ Les IDs de catégories restent nécessaires pour distinguer armes/armures des sorts liés
(baguettes/parchemins/potions) à l'intérieur du template DD3.5, mais le template n'est appelé
que si com_est_calcule=1, ce qui réduit l'exposition au hardcoding.

**[2026-05] Objets magiques — om_visible**
Champ repris de la V1. Permet au MJ de masquer un objet aux joueurs (om_visible=0).
→ Le filtre est appliqué dans `compendium/objets.php` via `extra_where` passé à `$listConfig`
  pour les utilisateurs sans droit d'édition.
→ Le detail-pp vérifie aussi om_visible et retourne 403 si l'utilisateur n'est pas éditeur.
→ Pas de filtrage dans `compendium-liste.php` lui-même : le moteur commun ne connaît pas
  la sémantique de chaque entité. L'extra_where est injecté dans $listConfig par la page.

**[2026-05] Objets magiques — autocomplétion sort lié**
Le champ "sort reproduit" est un select en V1 (liste complète). En V2 : autocomplétion AJAX.
→ Endpoint dédié `include/ajax/autocomplete-sorts.php`, requête LIKE + LIMIT 5.
→ Label affiché : "Nom du sort — Niv. X (Source)" pour lever les homonymes inter-sources.
→ Niveau unifié : DD3.5 → MIN(sc_niveau) via dd_sortclasse ; DD2024 → so_niveau direct.
→ Les sorts homebrew (so_camp_id IS NOT NULL) sont exclus : un objet global ne référence
  pas un sort de campagne.
→ Composant autonome : `initSortAutocomplete()` dans compendium.js, initialisée par le script
  inline de modifier/objet.php après injection du HTML dans #modification.
→ Bouton × (`.autocomplete-clear`) pour désélectionner sans vider le champ texte manuellement.
→ Navigation clavier : ArrowDown/Up, Enter, Escape.

**[2026-05] Objets magiques — extra_where dans $listConfig**
Le moteur `compendium-liste.php` ne gère pas nativement les filtres métier sur des champs
qui ne sont pas des filtres GET (ex: om_visible). Mécanisme : clé `extra_where` dans $listConfig,
clause SQL brute ajoutée en AND au WHERE si présente et non vide.
→ À documenter dans ARCHITECTURE_0_REFERENCE.md si d'autres entités en ont besoin.
→ La valeur est construite côté PHP dans la page contrôleur, jamais côté client.

**[2026-05] Objets magiques — com_est_propriete vs IDs hardcodés**
Les catégories "Propriétés spéciales des armes" et "Propriétés spéciales des armures" (DD3.5)
ne sont pas de vrais objets mais des pouvoirs d'objets. Elles doivent être masquées par défaut.
→ Champ `com_est_propriete tinyint(1) DEFAULT 0` ajouté dans `dd_categorie_objet_magique`.
→ Masquage via `extra_where` (sous-requête `NOT IN`) dans la liste, et clause conditionnelle
  dans la query du SELECT catégorie (barre de filtres).
→ Pas d'IDs hardcodés : le filtre lit `WHERE com_est_propriete = 1` — insensible aux IDs réels.
→ Exclusivement DD3.5 : le filtre et la case à cocher n'apparaissent qu'en ruleset DD3.5
  (`$ruleset_id === 1`). En DD2024, comportement standard sans masquage.

**[2026-05] Filtre checkbox — type générique dans compendium-liste.php**
Nouveau type `'checkbox'` ajouté dans la boucle de rendu des filtres de `compendium-liste.php`.
Structure de déclaration dans `$listConfig['filtres']` :
  `['type' => 'checkbox', 'name' => 'f_om_props', 'label' => '…', 'checked' => bool]`
→ Le `onchange` soumet le formulaire immédiatement (cohérent avec les selects).
→ Le badge mobile (`$filtres_actifs`) compte la checkbox si `checked = true`.
→ La valeur `checked` est calculée côté PHP dans la page contrôleur, jamais dans le moteur.
→ Réutilisable pour toute autre entité nécessitant un filtre booléen dans la barre de filtres.

---

## Bugs connus — à traiter

- **Admin / liste utilisateurs** : le menu ⋮ (dropdown) ne fonctionne pas correctement sur les lignes `admin-ligne--inactif`. La piste CSS (stacking context créé par `opacity` sur `<td>`) a été explorée sans succès. À investiguer en session dédiée.

---

## À décider

- [x] ~~Gestion des mots de passe oubliés~~ → implémenté (token 1h + DEV_MODE)
- [x] ~~Ordre d'affichage par défaut des listes~~ → alphabétique sur col-primary (tri GET modifiable)
- [x] ~~Zone admin — nombre de blocs~~ → 2 blocs (Utilisateurs + Ressources) ; Variables via phpMyAdmin
- [x] ~~Suppression utilisateur~~ → désactivation j_visible=0, jamais DELETE
- [x] ~~Sélection sources profil — zéro sélection~~ → autorisé, retour au défaut, message explicatif
- [x] ~~Homebrew profil vs campagne~~ → homebrew reste campagne uniquement ; res_camp_id IS NULL réservé
- [x] ~~Thèmes visuels~~ → dark (défaut) + light "Parchemin" via j_theme en BDD + classe body
- [ ] Interface d'inscription (auto-inscription ou invitation admin seulement ?)
- [ ] Taille maximale des contenus wiki (LONGTEXT = ~4Go, probablement suffisant)
- [ ] Homebrew profil (recueil maison transversal) — implémentation future si besoin confirmé
