<!-- Mis à jour : 2026-06-20 16:00 -->

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
→ **Affiné par la décision [2026-06-15] canEditCompendiumEntry() — le bouton Modifier dans detail-pp
  du compendium est maintenant conditionné par canEditCompendiumEntry() (per-entry) et non canEditCompendium() (global).**

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

**[2026-06-17] Sous-classes DD2024 — réutilisation de dd_classes**
Une sous-classe (DD2024) est stockée comme une ligne ordinaire de dd_classes plutôt que dans une
table dédiée. Le champ cla_cla_id, présent en base mais jusque-là inexploité par le code, porte la
classe parente (liaison N sous-classes → 1 classe, NULL pour Base/Prestige). Le type de classe
distingue les deux cas via dd_classe_type : clt_id=4 « Base » et clt_id=5 « Sous-classe » (DD2024,
valeurs confirmées en base — pas de constante partagée, à l'image de cla_clt_id===2 pour le
prestige DD3.5). Le mécanisme de capacités spéciales par niveau (dd_classe_capacite) est réutilisé
sans changement de schéma, une sous-classe étant une ligne dd_classes comme une autre. Le
formulaire masque dynamiquement (JS, classe .classe-champ-normal) tous les champs propres à une
classe complète (dé de vie, table de progression, type de magie, etc.) quand le type Sous-classe
est sélectionné ; le serveur neutralise ces mêmes champs à l'enregistrement pour éviter des
données résiduelles, et purge dd_classe_niveau en cas de changement de type. supprimerClasse()
bloque désormais la suppression d'une classe référencée comme parente par des sous-classes.
→ Alternative écartée : table dd_sousclasses dédiée (+ dd_sousclasse_capacite). La réutilisation
de dd_classes évite toute migration et tout nouveau module compendium, conformément au principe
projet de réutilisation maximale des patterns existants.

**[2026-06-17] Sous-classes DD2024 — titre des capacités spéciales « Niveau XX : Nom »**
Pour une sous-classe, la section "Capacités spéciales" de detail-pp/classe.php affiche une ligne
par affectation niveau/capacité (dd_classe_capacite, triée par cc_niveau), avec pour titre
"Niveau XX : Nom de la capacité" — une même capacité affectée à plusieurs niveaux apparaît donc
plusieurs fois. Pour une classe normale, l'affichage reste inchangé (simple nom, niveau déjà
visible dans la table de progression).
→ Une sous-classe n'a pas de table de progression ; le niveau doit donc être porté par le titre
de chaque capacité plutôt que par un tableau absent.

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
**Nota : dd_monstres est exclu de ce périmètre — les monstres ne sont pas filtrés par resource dans le moteur de liste standard.**
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
→ **Affiné par [2026-06-15] : les suppléments publics d'autres utilisateurs sont désormais également affichés dans "Mes sources", dans une section distincte.**

**[2025-05] Sélection des sources — zéro sélection autorisé**
Si l'utilisateur décoche toutes les ressources, les lignes dd_joueurs_sources sont supprimées.
getActiveResIds() retombe alors sur la priorité 3 (res_selection = 1 — défaut absolu).
Un message explicite informe l'utilisateur de ce comportement lors de la sauvegarde.
→ Pas de contrainte min=1 — permet à l'utilisateur de "réinitialiser" sa sélection proprement.

**[2025-05] Sélection des sources — validation serveur des res_id reçus**
Chaque res_id reçu en POST est revalidé contre la liste des ressources globales du ruleset actif.
Aucun res_id étranger (autre ruleset, homebrew) ne peut être inséré via manipulation du formulaire.
→ Sécurité : pas de confiance implicite dans les valeurs POST.

~~**[2025-05] Homebrew campagne vs homebrew profil — décision d'architecture** — SUPERSÉDÉ par [2026-06-15]~~
~~Le contenu homebrew reste exclusivement rattaché à une campagne (res_j_id NOT NULL, res_camp_id NOT NULL).~~
~~Aucun homebrew "profil" (res_j_id NOT NULL, res_camp_id IS NULL) n'est implémenté à ce stade.~~
→ **Décision levée. Le homebrew profil est maintenant implémenté sous le nom de "supplément utilisateur". Voir [2026-06-15].**

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

~~**[2026-05] Visibilité portée par `mo_j_id` (pattern propre au module)** — SUPERSÉDÉ par [2026-06-15]~~
~~`mo_j_id IS NULL` = monstre public (visible de tous) ; sinon visible du seul propriétaire.~~
~~Clause de liste `(mo.mo_j_id IS NULL OR mo.mo_j_id = <uid>)` injectée via `extra_where`.~~
→ **Décision levée. `mo_j_id` est supprimé. La visibilité des monstres est gérée via le mécanisme supplément (`mo_res_id`, `mo_public`, `mo_visible`). Voir [2026-06-15].**

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

## Phase 2 — Supplément utilisateur (SP-C)

**[2026-06-15] Activation de la réserve d'architecture — supplément utilisateur**
La réserve `res_j_id NOT NULL AND res_camp_id IS NULL` (posée en [2025-05]) est maintenant activée.
Le "homebrew profil" est implémenté sous le nom de **supplément utilisateur**.
Le supplément est une entrée `dd_ressources` avec `res_j_id = j_id` (propriétaire) et `res_camp_id IS NULL`.
**1 supplément par utilisateur par ruleset** (2 max par utilisateur : DD3.5 + DD2024).
Nommage : `res_nom = 'Supplément de {pseudo}'`, `res_abreviation = 'Supp.'`, `res_selection = 0`.
Créé automatiquement à la première sauvegarde d'une entrée de supplément.
Droit de création : tout `j_compendium_manager` (accès identique à l'édition du compendium global).
→ La décision "[2025-05] Homebrew campagne vs homebrew profil" est supersédée.

**[2026-06-15] Champs `_public` et `_visible` — sémantiques distinctes**
Deux champs `tinyint(1)` contrôlent la visibilité des entrées de supplément :
- **`_public`** (défaut 0) : partage vers autres utilisateurs ayant le supplément sélectionné.
  N'a de sens QUE pour les entrées de supplément. Les entrées officielles sont toujours publiques.
- **`_visible`** (défaut 1) : présence dans les listes standard du compendium.
  `_visible = 0` = brouillon masqué — n'apparaît pas dans la liste même pour le propriétaire.
  Accessible via toggle "Afficher mes brouillons" dans la barre de filtre (visible uniquement
  pour le propriétaire du supplément).
  N'a de sens QUE pour les entrées non partagées (`_public = 0`).
- **Contrainte** : `_public = 1` implique `_visible = 1` (forcé serveur au save + contrainte UI).
  Une entrée partagée est forcément visible. Combinaison `_public=1, _visible=0` impossible.

Matrice des états valides :

| `_public` | `_visible` | Qui voit l'entrée dans la liste |
|---|---|---|
| 0 | 1 | Propriétaire uniquement (privé normal) |
| 0 | 0 | Brouillon — visible via toggle "Afficher mes brouillons" (propriétaire seul) |
| 1 | 1 | Tous les utilisateurs ayant le supplément sélectionné |
| 1 | 0 | INTERDIT |

Ajoutés sur **8 entités** (sorts, dons, compétences, races, classes, historiques, monstres) + `om_public` seul pour objets_magiques (`om_visible` existant conservé avec sa sémantique propre).

**[2026-06-15] Suppression de `mo_j_id` — alignement monstres sur le mécanisme supplement**
`dd_monstres.mo_j_id` (NULL = public, sinon visible du seul propriétaire) est **supprimé**.
La propriété et la visibilité des monstres sont désormais gérées exclusivement via :
- `mo_res_id` → ressource supplément de l'utilisateur (monstres personnels)
- `mo_camp_id` → homebrew de campagne (inchangé)
- `mo_public` / `mo_visible` (nouveaux champs, mêmes règles que les autres entités)
Patch SQL `patch_004_supplements.sql` inclut la **migration des monstres existants** :
pour chaque `mo_j_id IS NOT NULL`, création du supplément utilisateur si absent, UPDATE `mo_res_id`,
SET `mo_public=0, mo_visible=1`, puis `ALTER TABLE DROP COLUMN mo_j_id`.
Le `extra_where` de `monstres.php` (`mo.mo_j_id IS NULL OR mo.mo_j_id = $uid`) est supprimé.
Le moteur de liste prend le relai via le filtre visibilité supplément.
→ Unification complète du mécanisme de visibilité dans tout le compendium.

**[2026-06-15] `canEditCompendiumEntry()` — garde per-entry**
Nouvelle fonction dans `helpers.php` pour valider le droit d'édition d'une entrée spécifique :
```php
function canEditCompendiumEntry($db, ?int $res_j_id): bool {
  if (isAdmin()) return true;
  // Supplément : seul le propriétaire
  if ($res_j_id !== null) {
    return (int)($_SESSION['j_id'] ?? 0) === $res_j_id;
  }
  // Ressource officielle : gestionnaire compendium
  return !empty($_SESSION['j_compendium_manager']);
}
```
Utilisée dans : `compendium-liste.php` (menu ⋮ per-row), `detail-pp/*.php` × 8 (bouton Modifier),
`enregistrement.php` (garde de save par entité). Le paramètre `$res_j_id` est issu de
`res.res_j_id AS _res_j_id` ajouté automatiquement dans le SELECT par le moteur.
`canEditCompendium()` (dans `auth.php`) reste inchangée — contrôle le bouton "Ajouter" et la barre bulk.

**[2026-06-15] Filtre visibilité dans `compendium-liste.php` — JOIN automatique**
Quand `champ_public` et `champ_visible` sont déclarés dans `$listConfig`, le moteur :
1. Ajoute `JOIN dd_ressources res ON res.res_id = {champ_res}` au FROM
2. Ajoute `res.res_j_id AS _res_j_id` dans le SELECT (pour per-entry auth)
3. Ajoute le fragment WHERE :
```sql
AND (
  res.res_j_id IS NULL
  OR res.res_j_id = :uid
  OR ({champ_public} = 1 AND {champ_visible} = 1)
)
```
4. Adapte l'affichage du menu ⋮ par ligne (canEditCompendiumEntry basé sur `_res_j_id`)
5. Ajoute la classe `comp-ligne--homebrew` sur les lignes avec `_res_j_id IS NOT NULL`

Nouvelles clés dans `$listConfig` :
- `'champ_public'`  → référence SQL de la colonne (ex: `'so.so_public'`) ou `false`
- `'champ_visible'` → référence SQL de la colonne (ex: `'so.so_visible'`) ou `false`
Si absentes ou à `false` : aucune modification du comportement existant (rétro-compatible).
Toutes les 8 pages contrôleurs du compendium déclarent ces clés.

**[2026-06-15] Source dropdown dans les formulaires modifier — 2 groupes**
Dans chaque formulaire `modifier/*.php`, le `<select>` Source est restructuré en deux groupes :
- `<optgroup label="Sources officielles">` : ressources officielles du ruleset actif
- `<optgroup label="Mon supplément">` : ressource supplément de l'utilisateur (créée si absente)
Les champs `_public` / `_visible` n'apparaissent (via JS) que lorsqu'une source de supplément est sélectionnée.
Pour les entrées officielles, ces champs sont masqués et non soumis.
→ L'utilisateur ne peut pas marquer une entrée officielle comme publique/privée.

**[2026-06-15] Auto-sélection du supplément dans les sources personnelles**
Lors de la première sauvegarde d'une entrée de supplément :
1. La ressource supplément est créée automatiquement si absente (`getOrCreateUserSupplement($db, $j_id, $ruleset_var_id)`).
2. Elle est auto-ajoutée dans `dd_joueurs_sources` pour le propriétaire (priorité 2 de `getActiveResIds()`).
→ **Pas d'auto-ajout aux campagnes** — le MJ ajoute son supplément aux sources d'une campagne manuellement via la configuration de la campagne.
→ La chaîne `getActiveResIds()` (priorité 2 = `dd_joueurs_sources`) suffit ; la fonction reste inchangée.

**[2026-06-17] Garde-fou anti-régression — `getOrCreateUserSupplement()` et la priorité 2**
Problème identifié en codant SP-C1 : `getActiveResIds()` court-circuite dès que la priorité 2
(`dd_joueurs_sources` non vide) renvoie un résultat — elle ne fusionne jamais avec la priorité 3.
Si un utilisateur n'a **jamais** personnalisé "Mes sources" (0 ligne en base, il dépend donc du
défaut absolu — priorité 3, toutes les ressources `res_selection=1`), le premier ajout automatique
de son supplément dans `dd_joueurs_sources` ferait basculer sa priorité 2 sur **"supplément seul"**,
masquant alors silencieusement toutes les ressources officielles par défaut qu'il voyait jusque-là.
→ **Correctif intégré dans `getOrCreateUserSupplement()`** : avant d'insérer le supplément, la
fonction vérifie si l'utilisateur a déjà une sélection personnelle pour ce ruleset. Si non, elle
reproduit d'abord le défaut (`res_selection=1 AND res_j_id IS NULL`) dans `dd_joueurs_sources`,
puis ajoute le supplément. L'utilisateur retrouve exactement la même vue qu'avant + son supplément.
→ `getActiveResIds()` elle-même **reste inchangée** (cf. [2026-06-15] Auto-sélection du supplément) —
le correctif est entièrement contenu dans la fonction de création du supplément.

**[2026-06-17] SP-C0 et SP-C1 livrées**
`sql/patch_004_supplements.sql` : 15 `ALTER TABLE` idempotents (`_public`/`_visible` sur sorts, dons,
compétences, races, classes, historiques, monstres ; `_public` seul sur objets magiques) + migration
des monstres privés (`mo_j_id` → supplément, 4 étapes idempotentes basées sur `INSERT...SELECT` /
`UPDATE...JOIN`, sans procédure stockée ni curseur) + `DROP COLUMN mo_j_id` idempotent.
`include/helpers.php` : `getUserSupplementResId()`, `getOrCreateUserSupplement()` (avec le
garde-fou ci-dessus), `canEditCompendiumEntry()` — toutes trois dans `helpers.php` (pas `auth.php`),
cohérent avec les autres fonctions de ce fichier qui interrogent la base (`ownerFilter()`,
`getActiveResIds()`). Vérifié au passage : `res_j_id` n'est actuellement positionné nulle part dans
le code existant (`admin/enregistrement.php`, `modifier/ressource.php`) — aucun risque de collision
entre un futur supplément et une ressource homebrew-campagne préexistante.

**[2026-06-20] Régression — save monstre cassé par la migration `mo_j_id` (SP-C0)**
Signalé : "Erreur base de données" systématique à la création d'un monstre. Cause : `DROP COLUMN
mo_j_id` (SP-C0, livré le 17/06) exécuté en base, mais `enregistrerMonstre()`
(`compendium/enregistrement.php`) et le formulaire (`include/ajax/modifier/monstre.php`) n'avaient
jamais été mis à jour pour SP-C4/SP-C5 — ils écrivaient encore sur `mo_j_id`
(`Unknown column 'mo_j_id'`). Régression silencieuse : aucun test de création de monstre effectué
entre la migration SQL et ce signalement.
→ Corrigé en traitant SP-C4 + SP-C5 pour l'entité Monstres uniquement (les 7 autres entités du
compendium restent en l'état, non régressées puisqu'elles n'ont pas de colonne `_j_id` historique
à migrer de la même façon).

**[2026-06-20] SP-C4/SP-C5 livrées pour Monstres — choix d'implémentation**
- **Sentinelle `'supplement'`** pour `mo_res_id` côté formulaire plutôt qu'un `res_id` réel : le
  supplément de l'utilisateur peut ne pas encore exister (aucune entrée créée pour ce ruleset). La
  valeur sentinelle est résolue côté serveur par `getOrCreateUserSupplement()`, appelée **dans** la
  transaction de `enregistrerMonstre()` (la fonction ne gère pas sa propre transaction par design,
  cf. son docblock dans `helpers.php`).
- **Source dropdown 2 `<optgroup>`** : "Sources officielles" (`res_j_id IS NULL`, scopées
  `getActiveResIds()`) et "Mon supplément" (une seule option : la ressource personnelle, réelle ou
  sentinelle). Pas d'option pour le supplément d'un tiers — un compendium manager ne peut créer
  d'entrée que dans le sien.
- **Garde-fou serveur sur `mo_res_id` réel non-officiel** : si la valeur POST correspond à un
  `res_id` dont `res_j_id` est défini, on vérifie `res_j_id === $uid` (ou admin) avant d'écrire ;
  sinon `repondreErreur('Source de supplément invalide.')`. Empêche un POST forgé de rattacher un
  monstre au supplément d'un autre utilisateur via un `res_id` deviné/énuméré.
- **`_public = 1 ⇒ _visible = 1`** appliqué côté serveur uniquement (source de vérité), pas en
  confiance du POST : la case `_visible`, désactivée en JS quand `_public` est coché, n'est alors
  plus soumise par le navigateur — `enregistrerMonstre()` force `$visible = 1` dès que `$public`
  vaut `1`, indépendamment de ce qui arrive dans `$_POST['mo_visible']`.
- **Entrées officielles** : `mo_public`/`mo_visible` forcés à `1`/`1` côté serveur, champs masqués
  côté formulaire (pas de notion de partage/brouillon pour le compendium officiel).
- **Hors périmètre de cette livraison** (volontairement) : `compendium/monstres.php` ne déclare pas
  encore `champ_public`/`champ_visible` dans son `$listConfig`, et `include/compendium-liste.php`
  n'a pas le support générique de ces clés — c'est SP-C2 (moteur de liste + badge homebrew + menu ⋮
  + toggle brouillons) et SP-C3 (bouton Modifier per-entry dans `detail-pp/monstre.php`), encore à
  faire. Les entrées de supplément créées via ce formulaire sont donc correctement enregistrées en
  base mais pas encore distinguées visuellement ni filtrées dans la liste Monstres.

**[2026-06-20] Correction — champ Groupe (DD2024) redevenu facultatif**
Signalé : le `<select>` Groupe du formulaire monstre (`include/ajax/modifier/monstre.php`) portait
`required` + astérisque, alors que `mo_mogr_id` est nullable en base et qu'aucune règle métier
n'impose un groupe à tous les monstres DD2024 (le champ caché DD3.5 transmettait d'ailleurs déjà
une valeur potentiellement vide sans contrainte côté serveur — l'incohérence n'était que côté UI).
→ Retrait de `required` et de l'astérisque ; option vide relabellisée `—` au lieu de `— Choisir —`
(cohérent avec les autres champs facultatifs du formulaire, ex. Facteur de puissance). Aucun
changement côté `enregistrerMonstre()` : `$mogr_id` était déjà traité comme optionnel
(`intParam(...) ?: null`).

**[2026-06-20] SP-C2/SP-C3 livrées pour Monstres — moteur de liste, badge, gating per-entry**

*Contexte* : entre la livraison SP-C4/SP-C5 et cette session, le commit a été poussé sur `main` par
l'utilisateur (vérification systématique faite en re-clonant le repo en début de session — le
GitHub n'était pas synchronisé au moment de la demande de poursuite, cf. consigne d'accès GitHub).
Tous les fichiers de travail ont été confirmés identiques à `main` avant reprise.

*Choix d'implémentation, en écart avec la conception générique initiale (§ Compendium des règles,
non réécrite pour traçabilité — un erratum y a été ajouté) :*

- **Clé `champ_res_owner` ajoutée à `$listConfig`** (en plus de `champ_public`/`champ_visible`,
  initialement seules prévues). Raison : la conception initiale prévoyait que le moteur
  `compendium-liste.php` ajoute lui-même un `JOIN dd_ressources` pour résoudre `res_j_id`. Mais
  `compendium/monstres.php` (et très probablement les 7 autres contrôleurs à terme) joint déjà
  `dd_ressources` sous l'alias `res` pour afficher le nom de la source en colonne — un second JOIN
  automatique sous le même alias aurait provoqué une erreur SQL (alias dupliqué). Le contrôleur
  déclare donc explicitement la référence SQL vers la colonne déjà disponible
  (`champ_res_owner => 'res.res_j_id'`), le moteur ne fait plus de JOIN lui-même.
- **Toggle "Afficher mes brouillons" géré directement par le moteur**, pas via le mécanisme générique
  `filtres[]` à checkbox (qui délègue son effet en `extra_where` côté contrôleur). Raison : ce toggle
  est transverse à toutes les entités à supplément (même requête de détection, même paramètre GET
  `f_brouillons`, même clause WHERE) — le coder une fois dans le moteur évite de le redupliquer dans
  les 8 contrôleurs. Affiché uniquement si une requête `EXISTS`-like (`SELECT 1 ... LIMIT 1`) trouve
  au moins une entrée `_visible=0` appartenant à l'utilisateur courant pour cette entité.
- **Filtre de visibilité scindé en 2 variantes** selon l'état du toggle, plutôt qu'une clause unique
  avec un paramètre booléen en SQL (MySQL/MariaDB n'a pas de booléen de requête pratique à injecter
  proprement dans un `OR` conditionnel sans complexifier la requête) :
  toggle inactif → `(owner IS NULL OR (owner=:uid AND visible=1) OR (public=1 AND visible=1))` ;
  toggle actif → `(owner IS NULL OR owner=:uid OR (public=1 AND visible=1))`.
- **Badge homebrew** : classe `comp-ligne--homebrew` sur le `<tr>` (style : liseré `--clr-accent-2`
  + léger fond teinté sur `col-primary`) + icône `fa-flask` (`.comp-homebrew-icon`) injectée en tête
  de la colonne mobile primaire. Ajouté dans `css/compendium-modules.css`.
- **Gating per-entry du menu ⋮** : remplace `canEditCompendium()` (droit global) par
  `canEditCompendiumEntry($db, $_res_j_id)` quand `$gere_supplement` est actif. La checkbox bulk de
  la ligne est également masquée si l'utilisateur ne peut pas agir dessus (cohérent avec le menu) —
  empêche de sélectionner pour suppression groupée une ligne qu'on ne peut de toute façon pas
  supprimer. Le JS bulk (`js/compendium.js`) n'a nécessité aucune modification : il interroge déjà
  `.comp-check` via `querySelectorAll`, donc une checkbox absente est simplement ignorée.
- **Garde-fou serveur ajouté côté suppression** (extension du périmètre SP-C5, pas explicitement
  listée dans le plan initial mais nécessaire en défense en profondeur) : `supprimerEntite()`
  générique n'a aucune notion de propriétaire per-entry — n'importe quel `j_compendium_manager`
  pouvait jusqu'ici supprimer l'entrée de supplément d'un autre utilisateur via une requête POST
  directe (le menu ⋮ le masquait côté UI, mais rien ne l'empêchait côté serveur). Nouvelle fonction
  `supprimerMonstre()` (remplace `supprimerEntite()` pour cette entité dans le dispatch de
  `enregistrement.php`) : relit `res_j_id` pour chaque id reçu, filtre via `canEditCompendiumEntry()`,
  ne supprime que les ids autorisés (ignore silencieusement les autres plutôt que d'échouer toute
  l'opération — cohérent avec un éventuel id invalide isolé dans un bulk delete légitime).
- **SP-C3** : `include/ajax/detail-pp/monstre.php` sélectionne désormais `res.res_j_id` et remplace
  `canEditCompendium()` par `canEditCompendiumEntry($db, $res_j_id)` pour le bouton Modifier.

*Monstres est désormais traitée intégralement (SP-C0 à SP-C7, cf. entrée [2026-06-20] SP-C7 ci-dessous).*

*Pour les 7 autres entités* : le moteur `compendium-liste.php` est désormais générique et ne nécessite
plus aucune modification — il suffit, pour chacune, de (1) déclarer `champ_public`/`champ_visible`/
`champ_res_owner` dans son `$listConfig`, (2) répliquer le pattern de formulaire 2-groupes + ownership
côté `enregistrement.php`, (3) ajouter une fonction `supprimer*()` dédiée avec garde per-entry,
(4) câbler `canEditCompendiumEntry()` dans son `detail-pp/*.php`.

**[2026-06-20] SP-C7 — Nettoyage Monstres post-migration**
Vérification exhaustive avant suppression (`grep -rn` sur tout le dépôt) :
- `include/ajax/modifier/monstre-old.php` : aucune référence ailleurs dans le code (ni `require`,
  ni URL codée en dur côté JS) — confirmé obsolète depuis le passage à `mo_res_id`/`mo_public`/
  `mo_visible`. **Supprimé.**
- `mo_j_id` : plus aucune occurrence dans le code actif (seule trace restante : un commentaire
  explicatif dans `compendium/monstres.php` mentionnant l'ancienne colonne supprimée — légitime,
  conservé pour la traçabilité historique).
- `mo_prive` (ancien nom de la checkbox liée à `mo_j_id`) : n'existait que dans `monstre-old.php`,
  disparu avec sa suppression.
- `include/monstre-parser.php` : relu intégralement, aucune référence à `mo_j_id` ni à un concept de
  visibilité par propriétaire — le parseur ne traite que `mo_stats` (texte brut), indépendant du
  mécanisme de propriété/visibilité. Rien à modifier.
→ L'entrée `[2026-05] modifier/monstre-old.php — ancienne version conservée` plus haut dans ce
journal reste en l'état pour traçabilité historique ; elle est résolue par celle-ci.

**[2026-06-15] Supplément sélectionnable par d'autres utilisateurs**
La ressource supplément d'un utilisateur devient visible dans "Mes sources" (profil) pour les autres
uniquement si **au moins une entrée est publique et visible** (`_public = 1 AND _visible = 1`)
dans n'importe quelle section. Vérification par sous-requête UNION sur les 8 tables concernées.
Le profil "Mes sources" est étendu : une section "Suppléments d'autres utilisateurs" liste
les suppléments disponibles avec le pseudo du propriétaire et le nombre d'entrées publiques.
→ Le propriétaire voit son propre supplément sans cet affichage (il est auto-sélectionné).

**[2026-06-15] Badge homebrew dans les listes**
Toute ligne de supplément (`_res_j_id IS NOT NULL`) dans une liste compendium reçoit un badge visuel :
classe CSS `comp-ligne--homebrew` sur le `<tr>` et icône indicateur dans `col-primary`.
Styles dans `compendium-modules.css`.
→ Distinction visuelle immédiate entre contenu officiel et contenu de supplément.

**[2026-06-15] Plan de développement SP-C — 8 sous-phases**

| Phase | Contenu | Complexité | Avancement |
|---|---|---|---|
| SP-C0 | SQL : 8 ALTER TABLE + migration mo_j_id + `patch_004_supplements.sql` | Modérée | ✅ livré (2026-06-17) |
| SP-C1 | Socle : `getOrCreateUserSupplement`, `getUserSupplementResId`, `canEditCompendiumEntry` | Faible | ✅ livré (2026-06-17) |
| SP-C2 | Moteur : `compendium-liste.php` (générique) + 8 contrôleurs (`champ_public`/`champ_visible`/`champ_res_owner`) | Élevée | 🟢 moteur générique livré (2026-06-20) ; Monstres branché, 7 contrôleurs restants |
| SP-C3 | `detail-pp/*.php` × 8 : bouton Modifier per-entry | Modérée | 🟡 Monstres fait (2026-06-20), 7 restantes |
| SP-C4 | `modifier/*.php` × 8 : source dropdown 2 groupes + champs `_public`/`_visible` | Modérée | 🟡 Monstres fait (2026-06-20), 7 restantes |
| SP-C5 | `enregistrement.php` : ownership + `_public`/`_visible` + auto-create supplément + suppression per-entry | Modérée | 🟡 Monstres fait (2026-06-20), 7 restantes |
| SP-C6 | `profil/index.php` : "Mes sources" — suppléments publics d'autres utilisateurs | Faible | ⏳ à faire |
| SP-C7 | Monstres : nettoyage `monstre-old.php` + `monstre-parser.php` (rm refs `mo_j_id`) | Faible | ✅ livré (2026-06-20) |

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

**[2026-06-17] Mémorisation du contexte de navigation (header) — réintégration v1**
Reprise de la fonctionnalité v1 (boutons de retour rapide dans le header vers les derniers
campagne/scénario/chapitre consultés), adaptée au fonctionnement en panneaux AJAX empilés de la v2
(plus de rechargement de page entre niveaux, contrairement à la v1). Quatre arbitrages tranchés :
- **Persistance en session uniquement** (pas en base) — généralisation du pattern déjà posé pour
  les personnages (`setLastPersonnage()`/`getLastPersonnage()`, jusqu'ici jamais consommé côté
  header). Écriture dans `helpers.php` (`setLastCampagne()`/`setLastScenario()`/`setLastChapitre()`,
  cascade descendante), appelée depuis chaque `include/ajax/detail-pp/*.php` qui dispose déjà de la
  chaîne d'ancêtres via sa jointure. Lecture (`getHeaderCampagneContext()`) sans requête base.
- **Repli sur le dernier personnage consulté** quand aucune campagne n'est active, comme en v1 —
  `getLastPersonnage()` est enfin branché dans le header (une requête `dd_personnages` seulement
  dans ce cas de repli, pas à chaque page).
- **Invalidation au soft delete** : chaque `supprimer*()` de `campagnes/enregistrement.php` appelle
  `invalidateLastCampagneContext($niveau, $id)` après son commit, pour qu'un contexte mémorisé ne
  pointe jamais vers une fiche supprimée.
- **Affichage en boutons distincts**, un par niveau actif (Campagne / Scénario / Chapitre), plutôt
  que le `<select>` unique de v1. Chaque bouton reconstruit la chaîne complète dans
  `_detailPpStack` avant de charger le niveau visé, pour que le bouton ← Retour du panneau reste
  cohérent une fois revenu dedans.
→ Détail technique complet : `ARCHITECTURE_0_REFERENCE.md` §12 (nouvelle sous-section). Niveau
Rencontre ajouté au même schéma lors de SP3, sans rien changer côté header.

**[2026-06-18] Correction bug — boutons de contexte muets sans F5**
Symptôme : `last_camp_id`/`last_sce_id`/`last_scc_id` bien posés en session par les handlers
`detail-pp/*.php`, mais aucun bouton n'apparaissait dans le header après consultation d'une
campagne/scénario/chapitre — seul un F5 les faisait apparaître. Cause : `getHeaderCampagneContext()`
n'était lue qu'au rendu de page complète (`include/header.php`) ; consulter un niveau se fait via le
panneau AJAX `#detail-pp`, qui ne touche jamais au header déjà rendu dans le navigateur.
→ Factorisation de la lecture (campagne/scénario/chapitre + repli personnage) dans
  `getHeaderContextNiveaux(PDO $db): array` (`helpers.php`), et du rendu HTML dans un fragment
  partagé `include/header-context.php`, tous deux consommés à la fois par `header.php` (rendu
  initial) et par un nouvel endpoint `include/ajax/header-context.php` (rafraîchissement à chaud).
  `header.php` enveloppe le fragment dans un conteneur d'ID fixe et toujours présent dans le DOM
  (`#site-header-context-zone`), que `main.js` recible via `actualiserContexteHeader()`, appelée
  depuis `_chargerDetailPP()` — donc après tout chargement de panneau, sans dupliquer l'appel par
  fonction de navigation. Nécessite `BASE_URL` en variable JS globale, désormais posée une fois dans
  `include/footer.php` plutôt que dupliquée par page.
→ Piège de validation à ne pas reproduire en debug : un onglet déjà ouvert avant le déploiement du
  correctif garde l'ancien DOM/JS en cache — `actualiserContexteHeader()` ne trouve alors rien à
  mettre à jour. Toujours valider un changement de `header.php`/`main.js` après un Ctrl+F5.

**[2026-06-19] Correction régression — boutons Chapitre/Rencontre absents du header**
Symptôme signalé : seuls les boutons Campagne et Scénario apparaissaient dans le header après
navigation ; Chapitre et Rencontre restaient muets. Deux causes distinctes identifiées par diff
avec la dernière livraison connue :
- `include/ajax/detail-pp/chapitre.php` avait perdu son appel `setLastChapitre(...)` — écrasé sans
  intention lors de l'ajout de la section "Rencontres" à ce même fichier (développement SP3).
  Régression pure, pas un oubli de conception.
- `include/ajax/detail-pp/rencontre.php`, créé pendant SP3, n'a jamais appelé `setLastRencontre(...)` :
  cette fonction n'existait encore que sous forme de commentaire (« SP3 à venir ») dans `helpers.php`
  au moment où SP3 a réellement été codé — l'intégration au mécanisme de contexte n'a pas suivi.
- `getHeaderCampagneContext()` ne lisait pas `last_re_id`/`last_re_nom` (aucune branche `rencontre`).
- Le fragment `include/header-context.php` ne connaissait pas le type `'rencontre'` dans ses tableaux
  `$ctx_urls`/`$ctx_labels` — un contexte Rencontre actif aurait provoqué une clé indéfinie.
- `supprimerRencontre()` dans `campagnes/enregistrement.php` n'appelait pas
  `invalidateLastCampagneContext('rencontre', $re_id)`, contrairement aux trois autres `supprimer*()`.
→ Les 5 points corrigés : `setLastRencontre()` implémentée dans `helpers.php` (cascade depuis
  `setLastChapitre()`) ; branche `rencontre` ajoutée à `getHeaderCampagneContext()` ; appel
  `setLastChapitre()` réintégré dans `detail-pp/chapitre.php` ; appel `setLastRencontre()` ajouté
  dans `detail-pp/rencontre.php` ; `$ctx_urls`/`$ctx_labels` complétés dans `header-context.php` ;
  `invalidateLastCampagneContext('rencontre', ...)` ajouté dans `supprimerRencontre()`.
→ Checklist ajoutée en §17 de `ARCHITECTURE_0_REFERENCE.md` : toute sous-phase Campagnes qui ajoute
  un niveau ou modifie un handler `detail-pp/*.php` doit revérifier ces 5 points d'intégration —
  c'est leur absence de suivi systématique qui a permis cette régression silencieuse.

**[2026-06-19] Contexte de navigation (header) — préservation des niveaux enfants lors d'une revisite**
Comportement signalé comme gênant à l'usage : `setLastCampagne()`/`setLastScenario()`/
`setLastChapitre()` effaçaient systématiquement les niveaux enfants à chaque appel, y compris en
revisitant un niveau déjà actif — cliquer sur le bouton « Scénario » du header (qui recharge le même
scénario) effaçait chapitre et rencontre mémorisés, même sans aucun changement de sélection.
→ Les 4 fonctions `setLast*()` comparent désormais l'id reçu à l'id déjà mémorisé pour ce niveau :
  niveaux enfants effacés UNIQUEMENT si l'id change réellement (sélection d'une autre
  campagne/scénario/chapitre dans une liste) ; préservés si l'id est identique (revisite via un
  bouton du header, ou tout autre rechargement du même niveau). Le discriminant est l'id, pas le
  chemin emprunté pour y arriver — aucun changement requis côté handlers `detail-pp/*.php`, qui
  continuent d'appeler `setLast*()` de la même façon.
→ Exemple validé : Campagne → Scénario A → Chapitre → Rencontre chargés ; clic sur le bouton
  « Scénario » (revisite A) préserve chapitre et rencontre ; sélection d'un Scénario B depuis la
  fenêtre scénario efface chapitre et rencontre, conserve la campagne.
→ Section `ARCHITECTURE_0_REFERENCE.md` §12 mise à jour avec le code et l'explication du
  discriminant id. Pas de changement sur `getHeaderCampagneContext()`, l'affichage, ou
  `invalidateLastCampagneContext()`.

---

**[2026-06-04] Correction bug — Flèche sommaire règles à la ligne**
Dans `include/regles-arbre.php`, `_rendreSommaireNiveau()` : le lien `regles-sommaire__lien`
était `display:block`, forçant l'icône `fa-chevron-right` (dans un `<a>` séparé) à passer à la ligne.
→ Wrapper `<span class="regles-sommaire__ligne">` en flex introduit ; lien en `flex:1` ; flèche placée
  à l'intérieur du span (présente seulement si enfants, non actif, non ouvert).
  `css/regles-modules.css` : ajout `.regles-sommaire__ligne` (flex) et `.regles-sommaire__toggle`
  (flex-shrink:0) ; sélecteurs `--actif` et `--glossaire` mis à jour vers `>ligne>lien`.

**[2026-06-04] Correction bug — Tableaux BDD dans les contenus richtext**
Spec unifiée pour les tables générées par TinyMCE dans les contenus stockés en base
(module Règles, module Compendium) :
- Pas de bordure (border:none)
- Padding 3 px sur toutes les cellules
- Alignement gauche (th et td)
- th : gras, pas de couleur de fond
- td : alternance gris perle `rgba(128,128,128,.10)` (lignes impaires) / transparent
→ `css/regles-modules.css` : section `.regles-noeud__texte table` et `.regle-detail__texte table` refaite.
  `css/compendium-modules.css` : section `.sort-detail__description table` refaite (suppression des tons
  brun chauds DD3.5 #2a1810 au profit de la spec commune).
  `css/modules.css` : ajout classe utilitaire `.richtext` (même spec) pour usage futur dans wiki/campagnes.

**[2026-06-04] Correction bug — Listes compendium non pleine largeur en mode smartphone**
Sur écran ≤ 991 px, le padding de `.site-main` (var(--sp-sm) = 8 px) réduisait la largeur des tableaux
de liste. Solution : margin négative compensatoire sur `.comp-liste-container` en media query ≤ 991 px.
→ `css/compendium-modules.css` : ajout dans `@media (max-width: 991px)` de
  `margin-left/right: calc(-1 * var(--sp-sm, 8px))` sur `.comp-liste-container`.

---

## Phase 3 — Personnages (conception et sous-phase 3.0)

**[2026-06-12] Finalité du module — aide de jeu, pas moteur de règles**
La fiche du site ne remplace pas la fiche papier du joueur et n'implémente aucune règle de construction
de personnage (pas de prérequis de dons, pas de point-buy, pas de contrôle de cohérence niveau/classe).
C'est une aide de jeu : le joueur et le MJ saisissent certaines données, librement et partiellement, pour
disposer de liens cliquables vers les règles du compendium pendant la partie.
→ Objectif : réduire les recherches dans les livres de règles en cours de séance.
→ Conséquence : tous les éditeurs (classes, dons, compétences, sorts) sont déclaratifs ; aucune validation
  métier de règle de jeu. Les seules validations serveur portent sur l'intégrité (FK, propriétaire, complétude
  d'une affectation NLS).
→ La saisie peut rester incomplète sans erreur (ex : ne saisir que quelques dons).

**[2026-06-12] Abandon des répertoires ruleset `include/insert/DD3.5/` et `DD2024/`**
Le dispositif de templates ruleset envisagé initialement n'a jamais été implémenté : le compendium V2
(sorts, classes, dons, compétences, races, objets) gère les spécificités **inline** par conditions
`if ($ruleset_rep === 'DD3.5')` et filtre via `_ruleset_var_id`. Aucun dossier `insert/` n'existe dans le dépôt.
→ Décision : abandon définitif des arborescences parallèles par ruleset. Les personnages suivent la même
  approche inline + helpers PHP ciblés. La divergence ruleset des personnages est faible (historique DD2024,
  section NLS + archétype DD3.5, sémantique de `pec_maitrise`) et ne justifie pas de templates séparés.

**[2026-06-12] [A] Sexe et alignement — ajoutés pour les deux rulesets, alignements communs**
`dd_personnages` reçoit `pe_sexe` (VARCHAR(20) libre, descriptif) et `pe_al_id` (FK).
→ **Alignements communs à tous les rulesets DD** (pas de différenciation par ruleset). Le référentiel
  `dd_alignements` est créé sans `al_ruleset_var_id` : table simple avec 9 alignements classiques + `al_ordre`.
→ Sexe et alignement sont des libellés descriptifs : non cliquables (pas d'entité compendium).
→ Patch livré : `sql/2026-06-12_personnages_socle.sql`.

**[2026-06-12] [B] Campagne en cours — `pe_camp_id` + historique des campagnes**
Règle métier : un personnage n'est que dans une seule campagne à la fois mais en enchaîne plusieurs (liaison N-N
conservée dans `dd_campagnes_personnages`). La campagne **en cours** est stockée dans `pe_camp_id` (NULL = aucune,
ce champ existait déjà via le patch campagnes étape 1).
→ La fiche affiche un bloc « Campagnes » : campagne en cours + historique (lecture seule) des campagnes traversées.
→ L'attache / détache et l'édition de `cp_notes_mj` restent du ressort du module Campagnes (Phase 4).
→ Préférence d'affichage des notes mémorisée sur le perso : `pe_notes_scope` (0 = campagne en cours, 1 = toutes).
  Le contenu de l'onglet Notes lui-même relève du module Notes (Phase 5) ; seul l'emplacement est réservé en Phase 3.

**[2026-06-12] [C] Notes MJ retirées du formulaire personnage**
Toute notion de notes MJ disparaît du formulaire personnage. Les notes MJ sont portées exclusivement par
`dd_campagnes_personnages.cp_notes_mj` et gérées dans le module Campagnes.

**[2026-06-12] [D] Objets magiques du personnage — reportés**
L'analyse métier n'est pas fiabilisée (dépend de la section compendium Objets magiques). En Phase 3, seule une
page placeholder `personnages/objets.php` portant la mention « Fonctionnalité à venir » est créée. Aucune table.

**[2026-06-12] [E] Édition par commit global — confirmé pour les personnages**
Abandon de tous les endpoints d'écriture AJAX immédiate de la V1 (`ajax-valider*ClassePerso.php`,
`ajax-majNiveauClassePerso.php`, etc.). Toute l'édition (identité, classes, niveaux, NLS, compétences, dons,
sorts) est locale (DOM/JS) puis persistée en un seul POST transactionnel `personnages/enregistrement.php`.
→ Conforme à l'architecture V2 (pages modifier sans write BDD).

**[2026-06-12] [F] Fiche unique responsive + vue Magie dédiée + emplacement mode jeu**
Abandon de la navigation multi-pages V1 (onglets Fiche/Background/…). Une fiche unique `personnages/fiche.php`
avec sections repliables (`togglePlus`) ; la Magie reste une vue dédiée (`personnages/magie.php`) car plus lourde.
→ Priorité responsive : usage majoritaire sur tablette / smartphone par les joueurs en cours de partie.
→ Un emplacement « mode jeu » (suivi PV et autres variables selon ruleset) est réservé dans la fiche
  **en haut, accessible immédiatement** ; son contenu réel est développé ultérieurement.

**[2026-06-12] [G] Liste des sorts du personnage — chaîne de sources**
La liste des sorts proposée à un personnage est bornée par `getActiveResIds()` (chaîne campagne → perso → défaut),
exactement comme le compendium.

**[2026-06-12] Compétences du personnage — chargement complet du ruleset**
Rupture avec la V1 (ajout une à une via bouton). Le formulaire de modification charge d'emblée **toutes** les
compétences du ruleset dans un bloc repliable sous forme de tableau.
→ DD3.5 : input numérique, rangs de 0 à n (`pec_maitrise`).
→ DD2024 : sélecteur à 3 valeurs (0 = aucune, 1 = maîtrise, 2 = expertise).
→ Persistance : DELETE + INSERT en bloc, seules les lignes `pec_maitrise > 0` sont enregistrées (pattern identique
  à la sélection des sources du profil). La fiche n'affiche que les compétences maîtrisées.

**[2026-06-12] Dons du personnage — liste déclarative cliquable**
`dd_personnages_dons` : le joueur saisit librement les dons de son personnage (saisie partielle autorisée).
Chaque don affiché est cliquable et ouvre son descriptif via detail-pp. `ped_niveau` optionnel (indicatif).

**[2026-06-12] NLS et emplacements de sorts par jour — calcul conservé (exception assumée)**
Bien que le module soit une aide de jeu sans moteur de règles, le calcul du NLS et du nombre de sorts par jour
est **conservé** car les deux sont liés par les règles métier et constituent une aide précieuse en séance.
Logique portée du helper V1 (`personnage_grimoire_helper.php`), réécrite proprement pour le schéma V2 figé
(suppression du code défensif `SHOW COLUMNS` / fallbacks de noms de champs).
→ Calcul : NLS effectif (niveau de classe de base + bonus apportés par les classes de prestige via
  `dd_personnages_nls`) → lecture `dd_classe_niveau` (`cn_sort_n0..9`) → + sorts bonus de caractéristique
  (`dd_modificateurs.mod_bonusSort0..9`) → +1 par niveau de sort si la classe choisit des domaines divins (DD3.5).
→ DD2024 : nombre de sorts préparés via `cn_sortPrepare` ; bonus de maîtrise via `dd_bonus_maitrise`.
→ L'affectation NLS (DD3.5) reste une saisie déclarative du joueur ; la validation serveur porte uniquement
  sur la complétude de l'affectation, pas sur une règle de jeu.

**[2026-06-12] Tables réutilisées — consolidation des grimoires V1**
Les tables V1 `dd_grimoires` / `dd_grimoires_contenu` sont abandonnées au profit des tables V2 déjà figées :
`dd_personnages_sorts` (connus / compris) et `dd_personnages_sorts_prepares` (préparés, avec métamagie DD3.5).

**[2026-06-12] Liste personnages — filtrage par ruleset actif + filtres ad hoc**
La liste `personnages/index.php` est dédiée (n'utilise pas le moteur `compendium-liste.php` ; calquée sur
`campagnes/index.php`). Filtrage strict par propriétaire ET par ruleset actif en session — un joueur ne voit
que ses personnages du ruleset courant, comme dans le compendium.
→ Filtres : Campagne (select des campagnes du joueur, sur `pe_camp_id`), Classe (select de toutes les classes
  du ruleset, sémantique EXISTS sur `dd_personnages_classes`), Recherche libre (LIKE sur `pe_nom`).
→ Colonnes desktop : ⋮ · Nom · Race · Classes · Alignement · Campagne en cours.
→ Mobile (< 992px) : seul le nom sur la première ligne ; race · classes · alignement · campagne concaténés
  en résumé sous le nom. Bouton ⋮ remonté en haut-gauche de la carte.

**[2026-06-12] Ordre des blocs de la fiche — Mode jeu en haut**
Pour l'accessibilité en cours de partie (le bloc le plus consulté doit être le plus accessible) :
1. Mode jeu (emplacement réservé) — 2. Identité — 3. Caractéristiques — 4. Combat — 5. Classes —
6. NLS prestige (DD3.5) — 7. Compétences — 8. Dons — 9. Campagnes.

**[2026-06-12] Sous-phase 3.0 livrée — socle technique**
Patch SQL `sql/2026-06-12_personnages_socle.sql` (création `dd_alignements` + 9 alignements seedés,
ALTER `dd_personnages` pour `pe_sexe`/`pe_al_id`/`pe_notes_scope` ; `pe_camp_id` non touché car déjà existant).
Pages : `personnages/index.php` (liste filtrée responsive) + placeholders pour `fiche.php`, `modifier.php`,
`magie.php`, `objets.php`. Routeur `personnages/enregistrement.php` (action `supprimerPersonnage` implémentée
en transaction PDO avec cascade manuelle sur les tables liées). Assets : `js/personnage.js` (menu contextuel
+ suppression inline), `css/personnages-modules.css` (filtres + liste, breakpoint 991px). Helper PHP
`include/personnage_helpers.php` (getPersonnageContext, getPersonnageClasses, getCampagnesPersonnage,
getAlignements). Ajax `detail-pp/personnage.php` et `modifier/personnage.php` créés en placeholder.

**[2026-06-12] Correction doc — `personnages/modifier.php` n'existe pas**
La doc d'architecture mentionnait une page `personnages/modifier.php` qui n'a jamais existé : aucun module
de la V2 (compendium, campagnes, admin…) ne suit ce pattern. L'édition passe **toujours** par l'overlay
AJAX `include/ajax/modifier/X.php` (modèle exemplaire : `include/ajax/modifier/campagne.php`).
→ Archi §7.4 et §7.10 corrigées en conséquence (suppression de la référence à `modifier.php`).
→ Ce n'est pas une nouvelle décision : c'est la convention réelle du projet qui n'avait pas été reflétée correctement.

**[2026-06-12] Sous-phase 3.1 — option 1 retenue pour la première classe à la création**
Règle métier (archi §7.2) : un personnage doit avoir au moins une classe. Comme l'éditeur multi-classes
arrive en 3.2, le formulaire identité 3.1 impose un select **« Première classe » + niveau** à la création.
En mode édition, ces champs disparaissent (la modification des classes passera par l'éditeur 3.2 sur la fiche).
→ Permet de respecter la règle dès la 3.1 sans dépendance à la 3.2.
→ Avantage : la 3.2 transformera ce simple select en éditeur multi-lignes sans toucher au formulaire identité.

**[2026-06-12] Ajout colonne `pe_hi_id` — patch SQL 3.1**
La colonne `pe_hi_id` (historique DD2024 → `dd_historiques`) manquait dans le schéma. Ajoutée par le patch
`sql/2026-06-12_personnages_identite.sql` (idempotent via `information_schema.COLUMNS`).
→ Type : `INT UNSIGNED DEFAULT NULL`, position `AFTER pe_arc_id`.
→ NULL = aucun historique ; sémantique cohérente avec `pe_al_id` (FK logique, NULL = non renseigné).
→ Inutilisée par DD3.5 (toujours NULL).

**[2026-06-12] Sous-phase 3.1 livrée — fiche identité responsive**
Overlay `include/ajax/modifier/personnage.php` complet : formulaire identité (nom, sexe, race + archétype DD3.5,
historique DD2024 conditionnel, alignement, 6 caractéristiques, CA, PV, background TinyMCE) + première classe
+ niveau obligatoires à la création. IIFE pour isolation du scope (formulaire injecté via innerHTML).
Action `enregistrerPersonnage` ajoutée à `personnages/enregistrement.php` (création + mise à jour, transaction PDO,
INSERT initial dans `dd_personnages_classes`). Vue détail `include/ajax/detail-pp/personnage.php` complète
(synthèse cliquable race / archétype / historique / classes). Fiche unique `personnages/fiche.php` avec
4 blocs livrés (Mode jeu placeholder en tête, Identité, Caractéristiques 6+modificateurs, Combat) + bloc Classes
en lecture seule + bloc « À venir ». Helpers `modCarac()` et `formatMod()` ajoutés. CSS étendu (`.per-fiche__*`,
`.per-identite`, `.per-caracs`, `.per-combat`, `.per-classes`, formulaire `.modif-grid--carac`), avec
responsive en deux paliers : caracs en grille 3x2 sous 992px, 2x3 sous 480px ; identité en colonne unique ;
cibles tactiles élargies (inputs caracs min-height 44px en mobile).

**[2026-06-12] Correctif 3.1 — select Race vide dans l'overlay (filtrage incorrect)**
La requête de chargement des races (idem archétypes et historiques) de l'overlay 3.1 contenait deux erreurs :
1. La condition `(ra_res_id IN (?) OR ra_camp_id IS NOT NULL)` faisait apparaître les races homebrew de
   **toutes** les campagnes du système (fuite + bruit + sémantique erronée). Le pattern compendium réel
   (`include/compendium-liste.php`) filtre au contraire le compendium global uniquement (`camp_id IS NULL`).
2. Si `getActiveResIds()` renvoyait un tableau vide (joueur sans sources personnelles ET aucune source globale
   `res_selection = 1`), le `IN ()` était syntaxiquement invalide → requête en échec → 0 résultat → select vide
   sans message d'erreur (cas observé).
→ Trois requêtes corrigées (races base, archétypes DD3.5, historiques DD2024) :
  `AND ra.ra_camp_id IS NULL AND ra.ra_res_id IN ($placeholders)`.
→ Garde-fou : si `$res_ids` est vide, on injecte `[0]` (sentinelle) — `IN (0)` est valide et ne ramène rien.
→ UX : si aucune source n'est active, un message d'avertissement explicite est affiché en tête de l'overlay,
  avec un lien vers `/profil/` pour aller configurer les sources.

---

**[2026-06-14] Correctif 3.1 — select Race vide (ra_rat_id mal filtré)**
La requête de l'overlay de modification filtrait `ra_rat_id = 1` pour les « races de base ». Or la table
réelle utilise `ra_rat_id = 3` pour les races DD2024 (1 = race DD3.5, 2 = archétype DD3.5, 3 = race DD2024).
Toutes les races DD2024 étaient exclues silencieusement.
→ Correction : filtre `ra_rat_id != 2` (exclure uniquement les archétypes DD3.5, laisser passer 1 et 3).
→ SCHEMA_SQL.md à corriger : documenter que `ra_rat_id` prend les valeurs 1, 2 et 3 (pas seulement 1 et 2).

**[2026-06-14] Sous-phase 3.2 — éditeur Classes inline**
Décisions prises et implémentées :
→ L'éditeur Classes est **inline dans la fiche** (pas un overlay) — deux modes : lecture (liste cliquable
  detail-pp) et édition (activé par bouton « Modifier » dans le header du bloc).
→ Éditeur DOM local : ajout/suppression/modification de niveau par lignes dynamiques construites en JS.
  Commit global via `action=enregistrerClasses` en transaction PDO (DELETE + INSERT sur `dd_personnages_classes`).
→ **Domaines divins DD3.5 inclus dès 3.2** (champs `pc_do_id_1`/`pc_do_id_2`) : deux selects conditionnels
  apparaissent sur chaque ligne si la classe a `cla_domaine_divin = 1`. Table `dd_domaines` vide pour l'instant
  (les selects seront peuplés lors de l'import des domaines).
→ Classes groupées par type (base / prestige) dans le select via `<optgroup>`.
→ En mode lecture, badge « P » pour les classes de prestige DD3.5.
→ Règle métier : au moins une classe obligatoire, validée côté client ET serveur.
→ Sur suppression d'une classe, cascade manuelle sur `dd_personnages_sorts` et `dd_personnages_nls`
  (FK logiques — pas de CASCADE SQL).
→ Premier éditeur DOM dynamique du projet (pattern réutilisable pour dons 3.4).
→ `getPersonnageClasses()` étendu : JOIN sur `dd_domaines` pour `domaine1_nom`/`domaine2_nom`.
→ CSRF lu depuis `<meta name="csrf-token">` (pattern `postAjax` de main.js).

**[2026-06-14] Correctif 3.2c — bouton Modifier gris sur fiche personnage (classe, race, historique)**
Cause racine : `.sort-detail__edit-btn` était défini dans `compendium-modules.css`, qui n'est pas chargé sur
la fiche personnage (seul `personnages-modules.css` l'est). Les detail-pp (race, classe, historique) étant
des fragments AJAX injectés dans `#detail-pp`, ils héritent du CSS de la page hôte — sans
`compendium-modules.css`, le bouton recevait le style navigateur par défaut (fond gris).
→ **Solution** : déplacement de `.sort-detail__edit-btn` et `:hover` dans `modules.css` (chargé sur
  toutes les pages via `header.php`), avec suppression de la définition dans `compendium-modules.css`
  (commentaire de renvoi laissé pour traçabilité).
→ Hover corrigé en même temps : `rgba(255,255,255,0.08)` (invisible sur fond clair) → `var(--clr-surface-alt)`.

**[2026-06-14] Règle permanente — CSS des composants injectés via AJAX**
Tout style utilisé par un fragment HTML injecté via AJAX (detail-pp, modifier overlay) dans un contexte
hors-compendium **doit être dans `modules.css`** (chargé par `header.php` sur toutes les pages), jamais dans
un CSS module-spécifique (`compendium-modules.css`, `personnages-modules.css`, etc.) qui ne sera pas disponible
sur toutes les pages hôtes.
→ Corollaire : toutes les couleurs de ces composants doivent utiliser `var(--clr-*)` — jamais de valeurs
  hardcodées (`#fff`, `#333`…) car les composants s'affichent sur des fonds variables selon le thème.
→ **Application immédiate** : `.sort-detail__edit-btn` déplacé de `compendium-modules.css` vers `modules.css`.

**[2026-06-14] Style DD (`.table-dd`) — classe utilitaire universelle pour les tableaux**
Création de la classe `.table-dd` dans `modules.css` (chargé sur toutes les pages) comme style de tableau
de référence du site, aligné sur le style du module Règles. Caractéristiques :
- Sans bordures de cellule, padding 3 px 6 px, alignement centré par défaut
- En-têtes `<th>` : gras, fond `--clr-surface-alt`, couleur `--clr-text`
- En-tête de groupe (`.thead-groupes`) : fond `--clr-surface-alt`, texte muted, sans bordure basse
- Groupe sorts (`.th-groupe-sorts`) : séparateur accentué `2px solid --clr-accent`
- Alternance tbody : gris perle `rgba(128,128,128,.08)` (impair) / transparent (pair)
- Colonnes standardisées : `.col-niv` (32px), `.col-stat` (46px), `.col-sort` (26px),
  `.col-pouvoir` (70px fixe, retour à la ligne), `.col-aptitudes` (flexible, tout l'espace restant)
- Wrapper `.table-dd-wrap` pour le scroll horizontal sur mobile
→ La table de progression des classes (`detail-pp/classe.php`) migre de `.table-classe-niv` vers `.table-dd`.
  Le bloc `<style>` inline est réduit aux seules règles non couvertes (titre + `.lien-sub`).
→ `.sort-detail__description table` dans `compendium-modules.css` aligné sur le même style
  (fond `--clr-surface-alt` sur `<th>`, même alternance).
→ Tous les tableaux dans les descriptions de compendium (TinyMCE) bénéficient du style via
  `.sort-detail__description table` ou `.richtext table` selon le contexte.

**[2026-06-14] Consigne permanente — style tableau dans le site**
Le style DD (sans bordures, alternance gris/transparent, en-têtes sur fond `--clr-surface-alt`) est le style
de référence pour tous les tableaux du site. Pour appliquer ce style :
- Tableaux structurés (tables de progression, listes de données) : classe `.table-dd` + wrapper `.table-dd-wrap`
- Tableaux dans du contenu HTML TinyMCE injecté via compendium : `.sort-detail__description table` (automatique)
- Tableaux dans du contenu richtext : `.richtext table` (automatique)
Les tableaux à deux lignes d'en-tête (ex: lanceurs de sorts) utilisent `<thead>` avec une `<tr class="thead-groupes">`
pour la ligne de groupe et une `<tr>` standard pour les labels — les deux sont stylés par `.table-dd`.

**[2026-06-17] Standardisation TinyMCE — thème dynamique, toolbar canonique, fond aligné**
Audit de tous les champs TinyMCE du projet (15 blocs `tinymce.init()` répartis sur 13 fichiers
`include/ajax/modifier/*.php`). Constat : plusieurs formulaires (ressource, objet, sort, regle,
historique, competence, don, l'overlay capacité de classe, race et son overlay) codaient en dur
`skin: 'oxide-dark'` / `content_css: 'dark'` sans condition de thème — en thème clair (Parchemin),
l'éditeur affichait donc le fond bleu nuit du thème sombre au lieu du fond parchemin attendu. À
l'inverse, `classe.php` codait en dur le thème clair (`oxide`/`default` + `content_style` parchemin
manuel) sans variante sombre. `personnage.php`, `scenario.php`, `campagne.php` et `chapitre.php`
détectaient déjà le thème (`isLight`) mais sans fond explicite aligné sur `--clr-surface-2`.
Harmonisation appliquée aux 15 blocs :
- Détection systématique `var isLight = document.body.classList.contains('theme-light');` en tête de
  chaque `initTMCE()` (et de chaque init d'overlay TinyMCE ouvert après coup).
- `skin`/`content_css` toujours `isLight ? 'oxide'/'default' : 'oxide-dark'/'dark'`.
- `content_style` ajouté partout pour fixer explicitement fond/texte (`#eae6dd`/`#2a2015` en clair,
  `#0f3460`/`#e0e0e0` en sombre — copies figées de `--clr-surface-2`/`--clr-text`, l'iframe TinyMCE
  n'ayant pas accès aux variables CSS du document parent). `regle.php` conserve son `content_style`
  spécifique (`.glossaire-lien`, `.titre-tableau`, `.regles-encart`, `h3`/`h4`) : le fond thème est
  désormais concaténé devant ces règles, pas remplacé (et la coquille `color: balck` corrigée en
  `black` au passage).
- Toolbar harmonisée sur le standard `styles | bold italic underline | bullist numlist | link unlink
  [table] [image] | removeformat | code` : remplacement des boutons `h2 h3` (incohérents avec le
  sélecteur de style) par le bouton natif `styles` (Normal, Titre 1 à 6 — aucune config requise),
  ajout du bouton `unlink` partout où `link` est présent, ajout du bouton `code` (et du plugin
  associé) pour afficher/éditer le HTML source. `regle.php` conserve en plus son bouton `blocks`
  (titres) et ses `style_formats` personnalisés (Titre de tableau, Encadré), désormais cumulés avec
  `styles` dans la même toolbar.
- `chapitre.php` chargeait le plugin `link` sans bouton toolbar correspondant : bouton `link unlink`
  ajouté pour rendre le plugin réellement utilisable.
- `classe.php` perd son `content_style` ad hoc (`font-family: Segoe UI…`, `margin: 8px`) au profit du
  standard (`font-family: inherit`) — alignement visuel avec le reste du site plutôt qu'une police
  spécifique à ce module.
-> Tous les champs TinyMCE du projet partagent désormais le même contrat visuel et fonctionnel quel
  que soit le thème actif. Section 16 de `ARCHITECTURE_0_REFERENCE.md` réécrite intégralement (pattern
  `initTMCE()`, tableau thème dynamique, toolbar canonique avec tableau des boutons/plugins, variante
  images, variante Règles) ; section 17 (checklist) complétée de 3 points TinyMCE dédiés.
-> Tout nouveau champ TinyMCE doit reprendre ce pattern à l'identique — toute dérogation (boutons hors
  liste, fond codé en dur) doit être documentée ici au même titre qu'une décision d'architecture.

**[2026-06-19] TinyMCE — `image`+`table` intégrés à la référence canonique (plus de variante « sans »)**
Constat sur le formulaire Rencontre (`modifier/rencontre.php`) : `re_description` avait la toolbar
complète (`link unlink image table`) tandis que `re_composition`, dans le même formulaire, avait une
toolbar allégée (`link unlink`, sans `image`/`table`) — incohérence visuelle au sein d'un même écran,
héritée du découpage doc antérieur qui traitait « avec upload d'images » comme une variante optionnelle
au-dessus d'un standard « sans images ».
→ La toolbar complète devient la référence canonique unique pour tout nouveau champ TinyMCE de
  l'application, upload d'images compris (`images_upload_url`/`images_upload_credentials`/
  `automatic_uploads`). Le retrait de `table`/`image` reste possible mais doit être un choix explicite
  et justifié au cas par cas (champ trop court pour qu'un tableau ou une image ait un sens), jamais un
  allègement par défaut.
→ `re_composition` aligné sur `re_description` : même `toolbar`, mêmes `plugins`, upload d'images
  ajouté. Les deux éditeurs du formulaire Rencontre partagent désormais une configuration `setup`
  commune (`Object.assign` sur un objet de config partagé) qui notifie la fin d'initialisation de
  chaque éditeur via l'événement TinyMCE `init` ; le bouton Enregistrer reste désactivé tant que les
  deux instances ne sont pas confirmées prêtes — corrige une suspicion de perte de saisie sur
  `re_composition` en cas de clic sur Enregistrer avant la fin du chargement asynchrone de l'éditeur
  (le filet `tmceGet()` retombant sur `textarea.value`, qui peut être la valeur brute non éditée si
  l'utilisateur a tapé avant que TinyMCE ait fini de s'attacher).
→ Ordre d'affichage Description / Composition inversé (Description avant Composition) dans le
  formulaire de saisie et dans la fiche de lecture `detail-pp/rencontre.php`, par cohérence avec la
  hiérarchie de lecture attendue (résumé narratif avant détail tactique).
→ Section 16 de `ARCHITECTURE_0_REFERENCE.md` réécrite : le tableau de boutons et les chaînes
  `toolbar`/`plugins` canoniques incluent désormais `image`/`table` nativement ; l'ancienne section
  « Configuration avec upload d'images » a fusionné avec la section « Barre d'outils standard ».

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
- [x] ~~Homebrew profil vs campagne~~ → **IMPLÉMENTÉ** sous le nom de supplément utilisateur (SP-C) — voir [2026-06-15]
- [x] ~~Thèmes visuels~~ → dark (défaut) + light "Parchemin" via j_theme en BDD + classe body
- [x] ~~Monstres — où analyser le bloc de stats~~ → à l'affichage, stockage texte brut (moteur monstre-parser.php v3)
- [x] ~~Monstres — TinyMCE pour mo_stats ?~~ → non, `<textarea>` brut
- [x] ~~Monstres — mécanisme de liens~~ → tags explicites `#`/`$`/`@`/`%` + liaison auto sorts/glossaire
- [x] ~~Monstres — visibilité~~ → **SUPERSÉDÉ** par supplément utilisateur — `mo_j_id` supprimé, `mo_public`/`mo_visible` ajoutés, migration via `patch_004_supplements.sql`
- [ ] Monstres — resynchroniser sql/schema.sql et le dump avec le schéma réel (catégories, groupes, fp, colonnes mo_* incluant la suppression de mo_j_id et l'ajout de mo_public/mo_visible)
- [x] ~~Monstres — supprimer include/ajax/modifier/monstre-old.php une fois le v3 stabilisé~~ → fait (2026-06-20, SP-C7)
- [ ] Monstres — étendre le parsing automatique DD3.5 (actuellement minimal)
- [ ] Sorts DD2024 — `so_resume` : NULL ou résumé court généré par sort (actuellement NULL)
- [ ] Interface d'inscription (auto-inscription ou invitation admin seulement ?)
- [ ] Taille maximale des contenus wiki (LONGTEXT = ~4Go, probablement suffisant)
- [x] ~~Homebrew profil (recueil maison transversal)~~ → implémenté : supplément utilisateur (SP-C)
- [x] ~~Campagnes — lien perso↔campagne~~ → N-N (dd_campagnes_personnages) + pe_camp_id (dernière campagne)
- [x] ~~Campagnes — rencontres : monstres ou copies ?~~ → oppositions (copies éditables, dd_oppositions)
- [x] ~~Campagnes — effectifs~~ → champ texte re_composition, pas de comptage chiffré ni table de liaison
- [x] ~~Campagnes — univers 1-1 ou N-N ?~~ → 1-1 (camp_un_id)
- [x] ~~Campagnes — ruleset par entité ?~~ → hérité de la campagne (source unique camp_ruleset_var_id)
- [x] ~~Campagnes — topo détaillé de la suppression douce (cascade + sort des PJ + pe_camp_id)~~ → stratégie validée (flag + cascade application + unlink PDF + pas d'UI restauration)
- [x] ~~Campagnes — contexte de navigation (header)~~ → session uniquement (réutilise le pattern last_pe_id), repli personnage, invalidation au soft delete, un bouton par niveau
- [ ] Campagnes — taille max des pièces jointes PDF (proposition : 20 Mo)
- [ ] Campagnes — stratégie FK/cascade en base (schema.sql sans contraintes FK actuellement)
- [ ] Campagnes — harmoniser la numérotation doc (ARCHITECTURE_8 vs METIER_10)
- [ ] Campagnes — patch SQL étape 2 : reprise de données v1→v2 (pe_camp_id, sc_*→sce_*)
- [ ] Resynchroniser sql/schema.sql avec le schéma réel (section 7 Campagnes v1.1)
- [x] ~~Personnages — finalité du module~~ → aide de jeu, pas de moteur de règles de construction
- [x] ~~Personnages — découpage ruleset par répertoires~~ → abandonné, implémentation inline
- [x] ~~Personnages — structure de navigation~~ → fiche unique responsive + vue Magie dédiée
- [x] ~~Personnages — calcul NLS / sorts par jour~~ → conservé (aide de jeu liée aux règles métier)
- [x] ~~Personnages — saisie des compétences~~ → tableau complet du ruleset, persistance des maîtrises > 0
- [x] ~~Personnages — campagne en cours~~ → pe_camp_id + bloc historique des campagnes
- [x] ~~Personnages — référentiel alignements~~ → commun à tous les rulesets, 9 alignements classiques
- [x] ~~Personnages — filtres de la liste~~ → campagne, classe, recherche libre (ruleset implicite)
- [x] ~~Personnages — colonnes liste + responsive~~ → nom/race/classes/alignement/campagne ; nom seul en mobile
- [x] ~~Personnages — position du bloc Mode jeu~~ → en haut (accès rapide en partie)
- [x] ~~Personnages — éditeur classes 3.2~~ → inline dans la fiche, avec domaines divins DD3.5 inclus
- [ ] Personnages — contenu réel du « mode jeu » (variables suivies par ruleset)
- [ ] Personnages — objets magiques / possessions (analyse métier à fiabiliser)
- [ ] Personnages — sélection de sous-classe au niveau 3 (DD2024) : prévoir un champ type
      pc_scla_id sur dd_personnages_classes lors du découpage des sous-phases Personnages
      (sous-classes désormais gérées comme dd_classes.cla_clt_id=5, voir Phase 2 — Compendium)
- [ ] Personnages — resynchroniser sql/schema.sql avec dd_alignements + nouveaux champs dd_personnages (pe_sexe, pe_al_id, pe_notes_scope, pe_hi_id)
- [x] ~~SP-C0 — Produire sql/patch_004_supplements.sql~~ → livré (15 ALTER TABLE idempotents + migration mo_j_id)
- [x] ~~SP-C1 — Produire fonctions socle helpers.php~~ → livré (getUserSupplementResId, getOrCreateUserSupplement, canEditCompendiumEntry — toutes dans helpers.php)
- [x] ~~SP-C2 — Moteur compendium-liste.php (générique : champ_public/champ_visible/champ_res_owner)~~ → livré (2026-06-20, rétro-compatible)
- [x] ~~SP-C2 — Monstres : brancher champ_public/champ_visible/champ_res_owner dans $listConfig~~ → livré (2026-06-20, compendium/monstres.php)
- [ ] SP-C2 — Sorts, dons, compétences, classes, races, objets, historiques : brancher $listConfig (moteur déjà prêt, juste à déclarer les 3 clés)
- [x] ~~SP-C3 — Monstres : detail-pp/monstre.php bouton Modifier per-entry~~ → livré (2026-06-20, canEditCompendiumEntry($db, res_j_id))
- [ ] SP-C3 — Sorts, dons, compétences, classes, races, objets, historiques : detail-pp/*.php × 7
- [x] ~~SP-C4 — Monstres : source dropdown 2 groupes + _public/_visible~~ → livré (2026-06-20, include/ajax/modifier/monstre.php) ; 7 entités restantes
- [ ] SP-C4 — Sorts, dons, compétences, classes, races, objets, historiques : source dropdown 2 groupes + _public/_visible
- [x] ~~SP-C5 — Monstres : enregistrement.php ownership + auto-create supplément~~ → livré (2026-06-20, enregistrerMonstre()) ; 7 entités restantes
- [x] ~~SP-C5 — Monstres : suppression per-entry (garde canEditCompendiumEntry)~~ → livré (2026-06-20, supprimerMonstre() dédiée, remplace supprimerEntite() générique)
- [ ] SP-C5 — Sorts, dons, compétences, classes, races, objets, historiques : enregistrement.php (ownership + auto-create supplément + suppression per-entry)
- [ ] SP-C6 — Mettre à jour profil/index.php (Mes sources — suppléments tiers)
- [x] ~~SP-C7 — Nettoyage monstres post-migration (suppression include/ajax/modifier/monstre-old.php, relecture monstre-parser.php pour refs mo_j_id résiduelles)~~ → livré (2026-06-20)
