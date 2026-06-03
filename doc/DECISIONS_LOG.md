<!-- Mis à jour : 2026-06-02 16:05 -->

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

## Phase 2 — Monstres

> Forme classique d'un module compendium (moteur de liste `compendium-liste.php`, fiche
> `detail-pp`, formulaire `modifier`, dispatch dans `enregistrement.php`), enrichie d'un moteur
> de rendu propre — `include/monstre-parser.php` (v3).

**[2026-05] Stockage texte brut, analyse à l'AFFICHAGE (pas à l'enregistrement)**
`mo_stats` est stocké **tel quel** (texte brut). Aucune passe d'analyse au save :
`enregistrerMonstre()` écrit la valeur POST sans transformation (pas de `h()`).
Le formatage (mise en page) et les liens cliquables sont recalculés **à chaque affichage**
par `rendreStatsMonstre()` (`include/ajax/detail-pp/monstre.php`).
→ Ré-édition fidèle à la source ; les liens restent toujours à jour (une entité ajoutée
  plus tard devient cliquable sans re-sauvegarde) ; aucune logique d'idempotence à gérer.
→ Coût : quelques `SELECT` au moment de l'affichage — négligeable.
→ Renverse une approche de conception antérieure (analyse au save + HTML enrichi figé).

**[2026-05] Saisie en `<textarea>` brut — pas de TinyMCE pour mo_stats**
Le bloc de stats est saisi dans un `<textarea>` à texte brut, pas dans TinyMCE.
Le moteur traite du texte ligne à ligne (sortie échappée par `h()`), pas du HTML.
→ Saisie alignée, aucun risque de corruption HTML, pas de `DOMDocument`.

**[2026-05] Liens par TAGS EXPLICITES (résolus en pré-passe)**
La liaison repose d'abord sur quatre tags saisis explicitement dans le texte :
- `#Nom du don#`  → lien vers le don (recherche par nom dans l'index, insensible casse/accents)
- `$Nom du sort$` → lien vers le sort (par nom)
- `@id@`          → lien vers la règle `dd_regles` (par id, tout type)
- `%id%`          → lien vers le terme de glossaire `dd_regles` (par id, `reg_type='glossaire'`)
Un tag introuvable est rendu en texte simple (sans lien), jamais en erreur.
→ Contrôle éditorial total sur ce qui devient cliquable ; pas de dépendance à une heuristique
  fragile pour les entités sensibles (dons, sorts cités hors contexte).

**[2026-05] Liaison AUTOMATIQUE limitée à sorts + glossaire**
En complément des tags, une passe automatique relie les **sorts** et les **termes de glossaire**
détectés dans le texte libre (descriptions de pouvoirs, valeurs de labels). Index fusionné
`construireIndexAuto()` avec priorité sort > glossaire. Garde-fous : normalisation
casse/accents, plus longue correspondance d'abord, longueur minimale `MO_LONGUEUR_MIN = 4`.
Le **nom d'un pouvoir** n'est jamais parsé automatiquement (affiché tel quel).
Les dons ne sont **pas** liés automatiquement (noms trop courants / ambigus) — uniquement
via tag `#…#` (ou via la ligne « Dons : » en DD3.5).
→ Faux positifs maîtrisés : seules deux familles d'entités peu ambiguës sont auto-liées.

**[2026-05] Dictionnaire — registre `typesLiablesMonstre()` (don + sort)**
Le registre déclaratif `typesLiablesMonstre()` décrit les types chargés par nom (table, id, nom,
colonnes ruleset/res/camp) : **don** et **sort**. Le glossaire est chargé séparément depuis
`dd_regles`. Chargement scopé : ruleset courant + sources actives (`getActiveResIds()`) + `camp IS NULL`.
Aucune source active → dictionnaire vide pour les types scopés par ressource.

**[2026-05] Parseur DD2024 par classification de lignes**
`formaterBlocDD2024()` classe chaque ligne via `classerLigneDD2024()` :
en-tête/ligne de caractéristiques, titre de section (Traits, Actions, Réactions, Repaire…),
label inline (CA, Pv, Vitesse, Initiative), label gras (Résistances, Immunités, FP, Équipement…),
sous-liste de sorts (« À volonté : », « N/jour : »), pouvoir (« Nom. Description »), ligne simple.
Les caractéristiques (For/Dex/Con/Int/Sag/Cha) sont rendues en **grille 3×2** (`rendreTableauCarac()`).
Séparateur de blocs : une ligne `***` → `<hr class="mo-stat-hr">`.

**[2026-05] Parseur DD3.5 par labels « : »**
`formaterLigneDD35()` reconnaît les labels DD3.5 terminés par « : » (Classe d'armure, Dés de vie,
Dons, Compétences…). Ligne « Dons : » → liaison dons ; autres → liaison auto (sorts + glossaire).
Le parsing automatique DD3.5 est volontairement minimal — **à compléter ultérieurement**.

**[2026-05] Sortie neutre `data-*`, résolution des liens côté client**
Le moteur produit des `<span class="mo-lien" data-type data-id>` **sans** `onclick` ni URL.
Le conteneur `.mo-stats[data-detail-base]` porte la base d'URL. Un gestionnaire délégué unique
dans `compendium.js` lit `data-type`/`data-id` et résout la cible :
- `regle`     → ouverture de `regles/regle.php?id=…` dans un nouvel onglet
- `glossaire` → `actualiserPageSub()` vers `detail-pp-sub/glossaire.php`
- `don`/`sort` → `actualiserPageSub()` vers l'endpoint `detail-pp` du type (table `MO_LIEN_FICHIERS`)
→ Indépendant de `BASE_URL` (local `/donjon` vs OVH) ; couplage stockage/JS supprimé.

**[2026-05] Autocomplétion des tags `@`/`%` dans le formulaire**
`include/ajax/autocomplete-tags-monstre.php` alimente une popup clavier dans le `<textarea>` :
en frappant `@` (règle) ou `%` (glossaire), l'utilisateur reçoit des suggestions (id + libellé +
fil d'Ariane), scopées au ruleset courant. Les tags `#`/`$` (don/sort) sont résolus par nom au rendu.
→ Saisie des renvois par id fiabilisée sans quitter le champ.

**[2026-05] Visibilité portée par `mo_j_id` (pattern propre au module)**
`mo_j_id IS NULL` = monstre public (visible de tous) ; sinon visible du seul propriétaire
(case « Monstre privé » du formulaire). Clause de liste
`(mo.mo_j_id IS NULL OR mo.mo_j_id = <uid>)` injectée via `extra_where` ; `ownerFilter()` n'est
**pas** utilisé (il masquerait les monstres publics à NULL). Les éditeurs voient tout.

**[2026-05] FP en libellé (varchar), `dd_fp` comme référentiel**
`mo_fp_id` conserve le **libellé** alphanumérique (« 1/2 », « 13 »…) ; `dd_fp` peuple et **ordonne**
le `<select>` du filtre via `fp_valeur`. `mo_mocat_id` (catégorie, obligatoire) et `mo_mogr_id`
(groupe) sont des FK entières ; le groupe est **DD2024 uniquement** (champ caché à `0` → stocké
`NULL` en DD3.5).

> ⚠️ **Écart schéma SQL / code à régulariser.** Le code référence `mo_mocat_id`, `mo_mogr_id`,
> `mo_res_id`, `mo_camp_id` et les tables `dd_monstres_categories`, `dd_monstres_groupes`, `dd_fp`,
> mais les fichiers `sql/schema.sql` et le dump `sql/maikasteiymaika.sql` du dépôt ne les
> reflètent pas encore (colonnes/tables absentes). La base réelle est à jour (gestion SQL directe) ;
> les fichiers SQL versionnés sont à resynchroniser.

**[2026-05] `modifier/monstre-old.php` — ancienne version conservée**
Une version antérieure du formulaire (`include/ajax/modifier/monstre-old.php`) reste dans le dépôt.
À supprimer une fois le v3 stabilisé.

---

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

**[2026-05] Bug corrigé — thème ignoré à la connexion par formulaire**
Symptôme : un utilisateur ayant choisi le thème « clair » se voyait toujours afficher le thème
« sombre » après connexion.
Cause : le `SELECT` de connexion dans `index.php` ne récupérait pas la colonne `j_theme`.
`startUserSession($row)` recevait donc un `$row` sans clé `j_theme`, et l'expression
`$row['j_theme'] ?? 'dark'` retombait systématiquement sur `'dark'`.
Le chemin « remember me » (`checkRememberMe()`) sélectionnait déjà `j_theme` — le bug ne se
manifestait donc qu'à la connexion explicite par formulaire.
Correctif : ajout de `j_theme` à la liste des colonnes du `SELECT` de login.
→ Invariant retenu : toute colonne consommée par `startUserSession()` doit figurer dans
  **les deux** requêtes qui peuvent l'appeler (login formulaire ET remember me). Garder ces
  deux `SELECT` synchronisés sur la même liste de colonnes.

---

## Phase 4 — Campagnes (conception)

**[2026-06-01] Hiérarchie du module**
Campagne → Scénario → Chapitre → Rencontre → Opposition. La v1 (Campagne → … → Rencontre → Monstres)
est remplacée : les rencontres ne référencent plus des monstres mais des **oppositions**.
→ Permet au MJ d'ajuster un adversaire pour sa partie sans toucher au compendium.

**[2026-06-01] Ruleset hérité**
Le ruleset n'est stocké que sur `camp_ruleset_var_id`. Retrait de `sce_ruleset_var_id`. Scénarios,
chapitres, rencontres et oppositions héritent du ruleset de la campagne par jointure remontante.
→ Source unique, pas de divergence possible de ruleset à l'intérieur d'une campagne.

**[2026-06-01] Univers 1-1**
Une campagne est reliée à au plus un univers. Abandon de la liaison N-N `dd_campagnes_univers` au
profit d'un champ `camp_un_id` (nullable) sur `dd_campagnes`. Les univers restent agnostiques du ruleset.
→ Le besoin réel est 1-1 ; la table de liaison était surdimensionnée.

**[2026-06-01] Lien personnage ↔ campagne**
N-N via `dd_campagnes_personnages` (source de vérité). On conserve en plus `dd_personnages.pe_camp_id`
comme raccourci « dernière campagne jouée » (campagne en cours). Géré par le module Personnages.
→ Le raccourci sert l'ouverture de session/fiche ; il ne fait pas autorité sur le rattachement.

**[2026-06-01] Oppositions = copies éditables de monstres**
Nouvelle table `dd_oppositions`. À la création, le formulaire propose un sélecteur de monstre qui
pré-remplit nom, libellé de catégorie (texte libre) et stats ; `opp_mo_id` (modèle) est stocké pour
traçabilité et **non modifiable**. Lien rencontre **1-N** via `opp_re_id`.
→ Le MJ personnalise/annote un adversaire sans altérer le compendium.

**[2026-06-01] Effectifs en clair, pas de table de liaison**
Pas de colonne d'effectif chiffrée ni de table `dd_rencontres_oppositions`. Une rencontre porte N
oppositions (1-N) et un champ texte `re_composition` décrivant littéralement les effectifs et la
disposition. Abandon de `dd_rencontres_monstres`.
→ La composition d'une rencontre est plus lisible et plus souple en texte qu'en comptage rigide.

**[2026-06-01] Duplication limitée au ruleset courant**
Duplication possible d'un scénario, d'une rencontre ou d'une opposition (suffixe « - copie »), en
cascade descendante, vers le même contexte ou une autre campagne **du même ruleset uniquement**.
→ Une copie inter-ruleset produirait des références de monstres invalides. Aucune exception en v2.

**[2026-06-01] Rencontres non orphelines**
`re_scc_id` passe NOT NULL : une rencontre appartient toujours à un chapitre. Le besoin v1 de
rencontre orpheline est couvert autrement par la duplication inter-scénarios.
→ Simplifie le modèle et les parcours UI.

**[2026-06-01] Pièces jointes PDF — table générique**
Table polymorphe unique `dd_fichiers` (`fi_entite` ∈ {campagne, scenario, rencontre}). PDF uniquement,
validation serveur double (extension + magic bytes), stockage du binaire hors base, téléchargement
contrôlé par la propriété de la campagne.
→ Un seul handler d'upload pour les trois entités plutôt que trois tables dédiées.

**[2026-06-01] Images des descriptions**
Les descriptions campagne/scénario/rencontre (TinyMCE `.tinymce-full`) acceptent des images
**téléversées serveur**, via l'endpoint existant `upload-image.php`. Pas de nouvel endpoint image.
→ Réutilisation du socle TinyMCE déjà en place (§16).

**[2026-06-01] Liste des campagnes — moteur dédié**
`campagnes.php` n'utilise pas `compendium-liste.php` : les campagnes sont scopées par propriétaire
(`camp_j_id`), pas par sources/ruleset. Liste légère dédiée.
→ Le moteur compendium filtre par `getActiveResIds()`, inadapté aux campagnes.

**[2026-06-01] Sécurisation des endpoints**
Tout endpoint d'ajout/édition vérifie la propriété de la campagne (`camp_j_id == utilisateur`) en
remontant la hiérarchie. Correction de la faille v1 (`*_create.php` sans authentification).
→ Empêche la manipulation d'entités par injection d'id en POST.

**[2026-06-01] Soft delete — stratégie complète validée**
Flag par table (`_supprime TINYINT(1) DEFAULT 0` + `_date_supprime DATETIME NULL`) sur les 6 tables
de contenu : `dd_campagnes`, `dd_scenarios`, `dd_scenarios_chapitres`, `dd_rencontres`,
`dd_oppositions`, `dd_fichiers`. Index sur chaque colonne `_supprime` (filtre systématique).
Cascade gérée en application (PHP, transaction PDO unique) dans `enregistrement.php` :
campagne → scénarios → chapitres → rencontres → oppositions + fichiers, plus
`SET NULL` sur `dd_personnages.pe_camp_id` et `DELETE` physique des lignes de liaison sans
contenu propre (`dd_campagnes_personnages`, `dd_campagnes_sources`, `dd_campagnes_notes`).
Fichiers PDF physiques : **suppression immédiate via `unlink()`** (option A) — libération disque,
pas de dossier trash.
**Pas d'interface de restauration côté MJ** — récupération admin uniquement en base si besoin.
Toute requête de lecture filtre `_supprime = 0` sans exception (précondition implicite).
Patch SQL : `doc/sql/2026-06-01_campagnes_v2_etape2a.sql`.
→ Cohérent avec la politique « jamais de DELETE » du projet. Pas de triggers ni FK (style schema.sql).

**[2026-06-01] Notes MJ — réservées**
`cp_notes_mj` (dans `dd_campagnes_personnages`) et `dd_campagnes_notes` conservées en base mais
**hors UI** cette version. Le système de notes n'est pas finalisé et empiète sur le module Personnages.
→ On évite de figer une UI sur un besoin non stabilisé.

**[2026-06-01] Patch SQL étape 1 appliqué**
`doc/sql/2026-06-01_campagnes_v2_etape1.sql` : + `pe_camp_id`, + `camp_un_id`, DROP
`dd_campagnes_univers`, retrait `sce_ruleset_var_id`, `re_scc_id` NOT NULL, + `re_composition`,
CREATE `dd_oppositions`, DROP `dd_rencontres_monstres`, CREATE `dd_fichiers`. Descriptions en LONGTEXT.
→ Schéma réel aligné sur `SCHEMA_SQL.md` v1.1. Reprise de données v1→v2 = patch étape 2 (à venir).

---

## Bugs connus — à traiter

- **Admin / liste utilisateurs** : le menu ⋮ (dropdown) ne fonctionne pas correctement sur les lignes `admin-ligne--inactif`. La piste CSS (stacking context créé par `opacity` sur `<td>`) a été explorée sans succès. À investiguer en session dédiée.

---

**[2026-06-02] Import en masse des sorts SRD 5.2.1 (DD2024)**
Import des sorts du SRD officiel dans `dd_sorts` / `dd_sortclasse` via script SQL à IDs explicites (dd_sorts dès 2082, dd_sortclasse dès 7272), livré par lots alphabétiques validés. Mapping : `so_co_id` -> `dd_colleges`, `sc_cla_id` -> `dd_classes`, `so_res_id` = 93 (SRD), `so_ruleset_var_id` = 2. En DD2024 un sort a un niveau unique -> `sc_niveau` identique pour toutes ses classes. Champs DD3.5 neutralisés (`so_cible`/`so_zone_effet` = '', `so_branche`/`so_resistance`/`so_jet_sauvegarde` NULL, focalisateurs 0). Blocs de stats de créatures conservés inline dans `so_description`. `so_resume` laissé NULL. `so_description` est stocké en **HTML** (champ TinyMCE, affiché brut) : un `<p>` par paragraphe du PDF et `<br>` pour les retours à la ligne internes (puces, lignes étiquetées, blocs de stats), afin de respecter la mise en forme du document source.
-> Compendium DD2024 alimenté sans saisie manuelle ; ré-import d'un lot possible via plage d'IDs (DELETE bornée).

**[2026-06-02] Schéma dd_sorts — colonnes so_concentration / so_rituel**
Ajout de `so_concentration` et `so_rituel` (tinyint 0/1) à `dd_sorts` pour stocker explicitement ces propriétés DD2024 (auparavant implicites dans le texte de durée/incantation).
-> Filtrage et affichage dédiés possibles ; le « ou rituel » reste aussi dans `so_duree_incantation` pour la lisibilité.

---

## À décider

- [x] ~~Gestion des mots de passe oubliés~~ → implémenté (token 1h + DEV_MODE)
- [x] ~~Ordre d'affichage par défaut des listes~~ → alphabétique sur col-primary (tri GET modifiable)
- [x] ~~Zone admin — nombre de blocs~~ → 2 blocs (Utilisateurs + Ressources) ; Variables via phpMyAdmin
- [x] ~~Suppression utilisateur~~ → désactivation j_visible=0, jamais DELETE
- [x] ~~Sélection sources profil — zéro sélection~~ → autorisé, retour au défaut, message explicatif
- [x] ~~Homebrew profil vs campagne~~ → homebrew reste campagne uniquement ; res_camp_id IS NULL réservé
- [x] ~~Thèmes visuels~~ → dark (défaut) + light "Parchemin" via j_theme en BDD + classe body
- [x] ~~Monstres — où analyser le bloc de stats~~ → à l'affichage, stockage texte brut (moteur monstre-parser.php v3)
- [x] ~~Monstres — TinyMCE pour mo_stats ?~~ → non, `<textarea>` brut
- [x] ~~Monstres — mécanisme de liens~~ → tags explicites `#`/`$`/`@`/`%` + liaison auto sorts/glossaire
- [x] ~~Monstres — visibilité~~ → mo_j_id (NULL = public, sinon propriétaire)
- [ ] Monstres — resynchroniser sql/schema.sql et le dump avec le schéma réel (catégories, groupes, fp, colonnes mo_*)
- [ ] Monstres — supprimer include/ajax/modifier/monstre-old.php une fois le v3 stabilisé
- [ ] Monstres — étendre le parsing automatique DD3.5 (actuellement minimal)
- [ ] Sorts DD2024 — `so_resume` : NULL ou résumé court généré par sort (actuellement NULL)
- [ ] Interface d'inscription (auto-inscription ou invitation admin seulement ?)
- [ ] Taille maximale des contenus wiki (LONGTEXT = ~4Go, probablement suffisant)
- [ ] Homebrew profil (recueil maison transversal) — implémentation future si besoin confirmé
- [x] ~~Campagnes — lien perso↔campagne~~ → N-N (dd_campagnes_personnages) + pe_camp_id (dernière campagne)
- [x] ~~Campagnes — rencontres : monstres ou copies ?~~ → oppositions (copies éditables, dd_oppositions)
- [x] ~~Campagnes — effectifs~~ → champ texte re_composition, pas de comptage chiffré ni table de liaison
- [x] ~~Campagnes — univers 1-1 ou N-N ?~~ → 1-1 (camp_un_id)
- [x] ~~Campagnes — ruleset par entité ?~~ → hérité de la campagne (source unique camp_ruleset_var_id)
- [x] ~~Campagnes — topo détaillé de la suppression douce (cascade + sort des PJ + pe_camp_id)~~ → stratégie validée (flag + cascade application + unlink PDF + pas d'UI restauration)
- [ ] Campagnes — taille max des pièces jointes PDF (proposition : 20 Mo)
- [ ] Campagnes — stratégie FK/cascade en base (schema.sql sans contraintes FK actuellement)
- [ ] Campagnes — harmoniser la numérotation doc (ARCHITECTURE_8 vs METIER_10)
- [ ] Campagnes — patch SQL étape 2 : reprise de données v1→v2 (pe_camp_id, sc_*→sce_*)
- [ ] Resynchroniser sql/schema.sql avec le schéma réel (section 7 Campagnes v1.1)
