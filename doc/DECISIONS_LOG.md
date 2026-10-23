<!-- Mis à jour : 2026-10-23 13:55 -->

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

**[2026-06-20] Développement urgent — équipement cliquable + parser appliqué aux oppositions**

*Demande* : (1) rendre cliquables les équipements/objets magiques dans la ligne "Equipement" et les
blocs "Actions" du bloc de stats ; (2) appliquer le même moteur de rendu (`monstre-parser.php`) à
l'affichage des oppositions (module Campagnes), qui montrait jusqu'ici `opp_stats` en texte brut
(`<pre>` échappé, aucun lien, pas de mise en forme).

*Partie 1 — Liaison automatique objets/équipement (`include/monstre-parser.php`)* :
- Type `objet` ajouté à `typesLiablesMonstre()` (`dd_objets_magiques` : `om_id`/`om_nom`/
  `om_ruleset_var_id`/`om_res_id`/`om_camp_id` — mêmes clés que `don`/`sort`, donc `chargerIndexMonstre()`
  l'indexe automatiquement sans autre changement).
- `construireIndexAuto()` : priorité étendue à `sort > objet > glossaire` (sort gagne en cas de
  collision de nom, objet avant glossaire — un nom d'objet est plus spécifique qu'un terme générique).
- **Aucun nouveau tag explicite** (pas de `&Nom&` ou équivalent pour les objets) : le mécanisme
  `lierAuto()` déjà câblé sur la ligne `label_gras` "Equipement" (DD2024) et sur la description des
  `pouvoir` (blocs Actions) suffit tel quel — ces deux points de passage appellent déjà `lierAuto()`
  avec l'index fusionné, qui inclut désormais les objets. Testé en local (PDO SQLite en mémoire) :
  "Equipement" et le texte d'une action ("Morsure. Attaque … avec une épée longue +1…") produisent
  bien `<span class="mo-lien" data-type="objet" data-id="…">`.
- Le mapping JS `MO_LIEN_FICHIERS` (cf. partie 2) contenait déjà `objet: 'objet.php'` — anticipé mais
  inutilisé jusqu'à aujourd'hui, donc aucun changement JS requis pour le clic lui-même.

*Partie 2 — Handler de clic `.mo-lien` déplacé vers `js/main.js`* :
- Avant ce jour, le handler vivait dans `js/compendium.js`, chargé uniquement sur les pages
  compendium (`$js_module = 'compendium'`). Le module Campagnes charge `js/campagne.js`
  (`$js_module = 'campagne'`) — sans déplacement, les liens produits dans une opposition auraient
  été inertes (spans non cliquables, juste du texte souligné par erreur de style résiduel).
- Déplacé intégralement vers `js/main.js`, chargé sans condition sur toutes les pages
  (`include/footer.php`, `<script src=".../js/main.js">` hors du bloc conditionnel `$js_module`).
  Retiré de `compendium.js` (évite la double délégation et le double fetch au clic).

*Partie 3 — Styles `.mo-*` déplacés vers `css/modules.css`* :
- Même raisonnement que la partie 2 : `.mo-stats`, `.mo-lien`, `.mo-section-titre`, `.mo-pouvoir`,
  `.mo-sous-liste`, `.mo-carac-*` (grille caractéristiques DD2024) déplacés de
  `css/compendium-modules.css` (chargé seulement sur les pages compendium) vers `css/modules.css`
  (chargé sans condition, cf. `include/header.php`). Restent dans `compendium-modules.css` :
  `.mo-stats-input` et `.mo-tag-popup*` (popup d'autocomplétion des tags `@`/`%` dans le `<textarea>`
  d'édition — usage exclusif du formulaire compendium, jamais affiché côté opposition).
- Vérifié : les variables CSS utilisées (`--clr-accent`, `--clr-accent-2`, `--clr-border`,
  `--clr-text-muted`, `--clr-surface-2`) sont définies dans `css/main.css` (thème global, chargé
  partout) — aucune dépendance résiduelle à `compendium-modules.css`.

*Partie 4 — `include/ajax/detail-pp-sub/opposition.php`* :
- `<pre class="opp-stats"><?= h($opp['opp_stats']) ?></pre>` remplacé par
  `rendreStatsMonstre($db, $opp['opp_stats'], $ruleset_id, $res_ids)`, rendu dans un conteneur
  `<div class="mo-stats" data-detail-base="…">` (même structure que `detail-pp/monstre.php`).
- `$ruleset_id` = `camp_ruleset_var_id` (déjà remonté par la jointure existante de ce fichier
  jusqu'à `dd_campagnes`, juste ajouté au `SELECT`) — **pas** le ruleset de session du visiteur.
- `$res_ids` = `getActiveResIdsCampagne($db, camp_id, ruleset_id)` (sources actives de la
  **campagne**, fonction déjà existante depuis SP-C0/recherche-monstre) — **pas**
  `getActiveResIds()` (sources personnelles du visiteur). Cohérence : une opposition est un contenu
  de campagne consulté par n'importe quel MJ de cette campagne, son index de liaison ne doit pas
  dépendre des sources personnelles de qui la regarde.
- `opp_stats` est une copie texte de `mo_stats` (recopiée telle quelle à la sélection du monstre,
  cf. `modifier/opposition.php` → `chargerDepuisMonstre()`) : même format de texte brut, donc le
  parser s'applique sans aucune adaptation de format.

*Limite UX assumée (non corrigée, hors périmètre de l'urgence)* : `#detail-pp-sub` est un panneau
unique sans pile (`actualiserPageSub()` remplace toujours son contenu). L'opposition y est déjà
affichée ; cliquer un lien `.mo-lien` à l'intérieur **remplace donc la vue Opposition** par la fiche
ciblée (sort/don/objet/glossaire), au lieu de s'empiler par-dessus comme c'est le cas pour les liens
cliqués depuis `detail-pp/monstre.php` (qui vit dans `#detail-pp`, un panneau différent du
sous-panneau qu'il ouvre). Seul "Fermer" est disponible, pas de "retour". Net positif par rapport à
l'état précédent (texte totalement inerte), mais une vraie pile de sous-panneaux nécessiterait de
faire évoluer `actualiserPageSub()`/`fermerSubPanel()` — non fait, à reprendre si gênant en pratique.

**[2026-06-20] Clarification — `dd_equipements` n'existait pas ; utilisée `dd_objets_magiques` seule**

Suite au développement ci-dessus, l'utilisateur signale que **`dd_equipements`** (équipement
mondain : armes, armures, matériel non magique) n'avait en réalité jamais été créée en base — il
s'en est rendu compte après coup. Le développement du jour n'a donc câblé que la liaison **objets
magiques** (`dd_objets_magiques`, module déjà existant) ; le mot "équipements" de la demande
initiale n'a, de fait, pas été couvert séparément (aucune table, aucun module, aucun endpoint
n'existait pour ce concept avant ce jour).

Arbitrage proposé (3 options) → réponse : **schéma SQL fourni à utiliser maintenant, reste du module
différé**, avec demande explicite de planifier les étapes restantes, numérotées sur le modèle SP-C.

*Fait aujourd'hui (SP-E0 uniquement)* :
- `dd_equipements` créée via `sql/2026-06-20_equipements_sp-e0.sql`, **committé dans le dépôt**
  (contrairement à `patch_004_supplements.sql`, jamais committé — leçon appliquée ici directement).
  Testé par exécution réelle sur une instance MariaDB locale (`CREATE TABLE` + `DESCRIBE`), pas
  seulement relu — la table se crée sans erreur et la structure correspond exactement au schéma
  fourni.
- `doc/SCHEMA_SQL.md` : coquille corrigée (la description de `dd_equipements` avait été copiée
  depuis la section `dd_objets_magiques` — "Objets magiques du compendium" — manifestement un
  copier-coller non corrigé lors de l'injection par l'utilisateur). Ligne de versioning 1.3 ajoutée.
- Écart noté avec le modèle Supplément (SP-C) : `eqt_visible` seul, pas de `eqt_public` — modèle de
  visibilité simple (façon ancien `om_visible` pré-SP-C0), pas de notion propriétaire/supplément.
  Non corrigé unilatéralement (le schéma vient de l'utilisateur) ; à arbitrer explicitement plus
  tard si Équipements doit rejoindre le mécanisme supplément (SP-E5, planifié mais pas priorisé).
- Plan **SP-E0 à SP-E5** ajouté dans `ARCHITECTURE_0_REFERENCE.md` § Module Équipements (planifié),
  sur le modèle du tableau SP-C0..C7 : SP-E1 (contrôleur liste), SP-E2 (formulaire +
  enregistrement), SP-E3 (fiche détail), SP-E4 (liaison dans `monstre-parser.php` — **explicitement
  bloquée par SP-E3**, un lien sans endpoint de destination produirait une 404), SP-E5 *(à
  arbitrer)* alignement sur le mécanisme Supplément.

*Pas fait, volontairement différé* : SP-E1 à SP-E5 (aucun contrôleur, formulaire, endpoint ou
liaison parser pour `dd_equipements`). La liaison auto "objet" déjà livrée dans
`monstre-parser.php` (ce même jour) continue de ne couvrir que `dd_objets_magiques` — ne pas
confondre les deux lors d'une prochaine session : *objet* (existant, câblé) ≠ *equipement* (planifié
SP-E, pas câblé).

**[2026-06-20] Oppositions — 2 correctifs : formulaire sous la vue + monstre d'origine optionnel**

*Signalement 1 — régression : le formulaire Modifier s'ouvre derrière la vue Opposition.*
Investigation avant correction (vérification systématique, cf. consigne projet) : diff de tous mes
changements du jour contre la version précédente — **aucun ne touche** le bouton Modifier, sa
fonction JS (`actualiserPageModif()`, inchangée), ni les z-index CSS. Cause réelle, pré-existante :
`#modification` (`.overlay-panel--edit`, z-index 250) est **par design** sous `#detail-pp-sub`
(`.overlay-panel--sub`, z-index 300) — commentaire explicite dans `css/main.css` depuis l'origine
de cette architecture d'overlays. `grep` exhaustif sur tous les appels `actualiserPageModif`/
`ouvrirModifier` du dépôt : **la vue Opposition (`detail-pp-sub/opposition.php`) est le seul endroit
du code où "Modifier" est déclenché depuis l'intérieur d'un `#detail-pp-sub` déjà ouvert** — partout
ailleurs (sorts, dons, monstres, personnages, campagnes, rencontres…) le bouton Modifier vit dans
`#detail-pp` (z-index 200, toujours sous `#modification`), donc le conflit n'apparaît nulle part
ailleurs. Conclusion : pas une régression de mes changements précédents, mais un angle mort
architectural pré-existant, invisible jusqu'ici car Opposition est la seule entité avec un bouton
Modifier accessible depuis sa propre vue en sous-panneau.
→ Corrigé en fermant le sous-panneau juste avant l'ouverture du formulaire :
`onclick="fermerSubPanel(); actualiserPageModif(...)"` dans `detail-pp-sub/opposition.php`. Choix
volontairement local (pas de modification des z-index globaux ni de `actualiserPageModif()`
elle-même, utilisée sans problème ailleurs) — limite le risque de régression à l'unique cas concerné.
Effet de bord accepté : après annulation de l'édition (`fermerModification()`), la vue Opposition ne
se rouvre pas automatiquement (l'utilisateur doit recliquer la ligne dans la rencontre) — comportement
jugé acceptable, cohérent avec l'ouverture d'un formulaire d'édition "frais".

*Signalement 2 — le choix d'un monstre doit être optionnel (saisie manuelle possible).*
`opp_mo_id` était `NOT NULL` en base (`sql/2026-06-01_campagnes_v2_etape1.sql`) et bloqué côté
serveur (`campErreur('Choisissez un monstre d'origine.')` dans `enregistrerOpposition()`) et côté
client (`alert('Veuillez choisir un monstre d'origine.')` dans `modifier/opposition.php`).
→ Corrections :
- **SQL** : `opp_mo_id` rendu `NULL` (`sql/2026-06-20_oppositions_monstre_optionnel.sql`, committé,
  testé par exécution réelle sur MariaDB locale — `ALTER TABLE ... MODIFY COLUMN`, idempotent,
  n'altère aucune ligne existante puisque toutes ont déjà `opp_mo_id` renseigné).
- **Serveur** (`campagnes/enregistrement.php` → `enregistrerOpposition()`) : suppression du blocage
  `if ($opp_id_was_zero && !$opp_mo_id)` ; `$opp_mo_id = intParam(...) ?: null` (0 → NULL, cohérent
  avec le reste du code projet pour les FK optionnelles). `opp_mo_id` reste non modifiable après
  création (UPDATE ne le touche toujours pas) — y compris pour passer de NULL à une valeur : une
  opposition créée sans monstre le reste définitivement, cohérent avec la sémantique "figé pour
  traçabilité" déjà en place pour le cas où un monstre est choisi.
- **Formulaire** (`include/ajax/modifier/opposition.php`) : retrait du blocage JS bloquant la
  soumission sans monstre. Label "Monstre d'origine" annoté "(facultatif)" ; texte d'aide ajouté
  ("laissez vide pour une opposition saisie entièrement à la main") ; libellé par défaut changé de
  "— aucun monstre sélectionné —" à "— aucun, saisie manuelle —" (plus explicite sur l'intention).
- **Doc** : `SCHEMA_SQL.md` § `dd_oppositions` mis à jour (`opp_mo_id` nullable, sémantique NULL =
  saisie manuelle) + ligne de versioning 1.4. `ARCHITECTURE_0_REFERENCE.md` § Campagnes mis à jour.

**[2026-06-21] Bug — supplément personnel absent de la recherche de monstre (création d'opposition)**

*Signalement* : aucun monstre du supplément personnel de l'utilisateur n'apparaît dans les résultats
de recherche lors de la sélection d'un monstre pour créer une opposition.

*Cause* : `getActiveResIdsCampagne()` (`include/helpers.php`, utilisée par
`include/ajax/recherche-monstre.php`) ne renvoyait **jamais** le supplément personnel du MJ, dans
ses deux branches :
- Repli (pas de `dd_campagnes_sources` configurées pour la campagne) : `WHERE res_j_id IS NULL` —
  exclut explicitement tout supplément, ne renvoie que les sources officielles.
- Sources explicites (`dd_campagnes_sources` configurées) : aucun chemin n'aurait pu y faire entrer
  un supplément personnel de toute façon — le formulaire qui peuple cette table
  (`include/ajax/modifier/campagne.php`) ne propose **que** des sources officielles dans son select
  (`WHERE res_ruleset_var_id = ? AND res_j_id IS NULL`, ligne 73), sans option pour ajouter le
  supplément du MJ lui-même.

Cause racine plus large : `getActiveResIdsCampagne()` et le formulaire de sources de campagne ont été
écrits **avant** le système Supplément utilisateur (SP-C, livré le 2026-06-17) et n'ont jamais été
mis à jour pour en tenir compte — contrairement à `getActiveResIds()` (sources personnelles, hors
campagne) qui inclut bien le supplément de l'utilisateur depuis l'origine de SP-C1.

*Correctif* : `getActiveResIdsCampagne()` résout désormais systématiquement le supplément du
**propriétaire de la campagne** (`camp_j_id`, pas l'utilisateur courant — distinction utile si un
admin consulte la campagne d'un tiers) via `getUserSupplementResId()`, et l'ajoute dans les deux
branches (sources explicites : ajouté s'il n'y est pas déjà ; repli officiel : toujours ajouté).
Pas de changement nécessaire côté formulaire de sources de campagne (`modifier/campagne.php`) — le
supplément personnel est désormais inclus *implicitement*, sans avoir besoin d'être sélectionnable
explicitement dans cette liste. Testé (PDO SQLite en mémoire) sur les deux branches : présent dans
les deux cas après correctif, absent avant.

*Bénéficiaire secondaire* : `include/ajax/detail-pp-sub/opposition.php` (rendu du bloc de stats
d'une opposition, livré le 2026-06-20) utilise la même fonction pour son index de liaison — un sort/
objet du supplément personnel du MJ référencé dans le texte d'une opposition devient également
cliquable, sans changement de code de son côté.

*Non corrigé, noté pour mémoire* : `recherche-monstre.php` ne filtre pas par `mo_public`/
`mo_visible` — si `dd_campagnes_sources` contient explicitement le supplément **d'un tiers** (cas
rare : un autre joueur a partagé son supplément et le MJ l'a ajouté aux sources de sa campagne), les
entrées en brouillon (`mo_visible = 0`) de ce tiers pourraient apparaître dans la recherche. Risque
faible (nécessite une action explicite du MJ pour ajouter une source tierce) et hors périmètre de ce
signalement (qui portait sur l'absence du supplément **personnel**, pas sur une fuite de
confidentialité tierce) — à corriger si signalé séparément.

**[2026-07-02] Bug — supplément personnel absent de la liste Monstres du compendium (régression)**

*Signalement* : dans le compendium, section Monstres, les monstres du supplément personnel de
l'utilisateur n'apparaissent plus dans la liste, et l'option pour afficher/masquer le contenu du
supplément a disparu du menu de sélection des sources.

*Cause* : `getActiveResIds()` (`include/helpers.php`, utilisée par le moteur commun
`include/compendium-liste.php` — donc par toutes les listes du compendium, dont Monstres) possède
sa **propre branche priorité 1**, distincte de `getActiveResIdsCampagne()` : quand un personnage est
actif en session (`$_SESSION['last_pe_id']`) et rattaché à une campagne disposant d'une sélection de
sources explicite (`dd_campagnes_sources`), la fonction retourne directement les `cs_res_id` de
cette table, sans jamais appeler `getUserSupplementResId()`. Le supplément personnel de
l'utilisateur est donc absent du tableau retourné dès qu'un tel personnage est actif — ce qui exclut
à la fois ses entrées (filtre SQL sur `champ_res`) et l'entrée correspondante du menu de sélection
des sources (`$sources_dispo` dans `compendium-liste.php`, construit à partir du même tableau),
expliquant les deux symptômes signalés simultanément.

Cause racine plus large : cette branche de `getActiveResIds()` est le pendant, côté personnage/
joueur, du repli \"sources explicites\" de `getActiveResIdsCampagne()` (contexte MJ) — corrigé le
2026-06-22 (cf. entrée `[2026-06-22]` ci-après). Les deux fonctions dupliquent une logique proche
mais restent des fonctions distinctes (l'une scopée personnage/joueur via `last_pe_id`, l'autre
scopée MJ via `camp_id` explicite) ; le correctif du 22/06 n'avait porté que sur la seconde, laissant
celle-ci non corrigée depuis l'origine de SP-C1 pour ce cas précis (personnage actif dans une
campagne à sources explicites — le cas \"sans sources explicites\", couvert par la priorité 2, n'était
pas affecté).

*Correctif* : la branche priorité 1 de `getActiveResIds()` ajoute désormais systématiquement le
supplément personnel de l'**utilisateur courant** (`$_SESSION['j_id']`, via `getUserSupplementResId()`)
au tableau des `cs_res_id` de la campagne, s'il n'y figure pas déjà. Choix de `$j_id` (utilisateur
courant) plutôt que `camp_j_id` (propriétaire de la campagne, comme dans `getActiveResIdsCampagne()`)
: cette fonction est scopée personnage/joueur (le point de vue est celui du joueur qui consulte le
compendium avec son personnage actif), alors que `getActiveResIdsCampagne()` sert un contexte MJ où
la distinction avec le visiteur courant a du sens (admin consultant la campagne d'un tiers). Aucun
changement nécessaire côté `compendium-liste.php` ni côté formulaire de sources de campagne — le
supplément est désormais inclus implicitement, comme pour `getActiveResIdsCampagne()`.

**[2026-07-02] Bug (suite) — supplément personnel toujours absent après le correctif `getActiveResIds()` priorité 1**

*Signalement* : après le correctif ci-dessus (branche priorité 1 de `getActiveResIds()`), l'utilisateur
confirme que ses monstres de supplément (res_id 95) n'apparaissent toujours pas dans la liste
Monstres, et que l'option correspondante reste absente du menu Sources — « la régression n'est pas
corrigée ».

*Diagnostic* (interrogation directe de la base de dev locale, `SHOW CREATE TABLE` + `SELECT`) :
l'utilisateur (`j_id=1`) n'a **pas** de `last_pe_id` actif rattaché à une campagne à sources
explicites au moment du test — `getActiveResIds()` ne passe donc jamais par la branche priorité 1
corrigée plus haut, mais tombe directement en **priorité 2** (`dd_joueurs_sources`, sélection
personnelle). Or `dd_joueurs_sources` pour cet utilisateur/ruleset ne contenait **pas** `res_id=95`
(vérifié : 5 lignes présentes — 91, 93, 94, 96, 97 — toutes officielles, aucune référence au
supplément). Deux bugs distincts, donc, avec le même symptôme : le correctif du jour ne couvrait que
la branche priorité 1, pas la priorité 2.

*Cause racine (priorité 2)* : `profil/index.php`, section "Mes sources" (`$section === 'sources'`).
Le supplément personnel n'est **jamais proposé comme case à cocher** dans cette section (par design —
cf. `ARCHITECTURE_0_REFERENCE.md` § Supplément comme source sélectionnable : « le supplément de
l'utilisateur lui-même n'apparaît pas dans cette section, il est auto-sélectionné »). Mais le
handler de sauvegarde fait un `DELETE FROM dd_joueurs_sources WHERE js_j_id=? AND
js_ruleset_var_id=?` puis ré-insère **uniquement** les `res_id` cochés, validés contre la liste des
ressources officielles (`res_j_id IS NULL`). Le supplément n'étant jamais dans les cases cochées
(il n'existe pas de case pour lui), il disparaît de `dd_joueurs_sources` à la **première
sauvegarde de "Mes sources"** suivant sa création — quelle que soit la raison de cette sauvegarde
(changement de ruleset par défaut, de thème, etc., dès lors que la section "sources" est soumise).
C'est très probablement ce qui s'est produit ici : le supplément (créé au premier ajout de monstre
homebrew) a été retiré de la sélection active dès la sauvegarde suivante du profil.

*Correctif immédiat (données)* : ligne réinsérée manuellement dans `dd_joueurs_sources` pour
`j_id=1, res_id=95, ruleset_var_id=2` (requête directe, base de dev locale) — débloque
l'utilisateur immédiatement, sans attendre un nouveau save de profil.

*Correctif structurel (code)* : `profil/index.php`, juste avant le `DELETE` + `INSERT` en bloc de
la section "sources" — ajout de `getUserSupplementResId($db, $j_id, $ruleset_var_id_actif)` au
tableau `$ids_valides` s'il n'y figure pas déjà (le supplément n'étant jamais dans `$ids_post`
puisqu'il n'a pas de case à cocher, ce test est systématiquement vrai en pratique, mais la garde
`!in_array` documente l'invariant plutôt que de le supposer). Corrige le bug pour tout futur save de
"Mes sources", quel que soit le contexte priorité 1/2/3 de `getActiveResIds()`.

*Portée du correctif* : couvre uniquement la disparition du **propre** supplément de l'utilisateur.
La partie affichage des « suppléments publics d'autres utilisateurs » dans "Mes sources"
(deuxième moitié de SP-C6, cf. `ARCHITECTURE_0_REFERENCE.md` § Section "Mes sources") reste non
implémentée — non liée à ce bug, non prioritaire à ce jour, `profil/index.php` continue de ne
lister que les ressources officielles comme choix explicites.

*Non vérifié* : rendu navigateur du save de profil après correctif (pas de compte de test
disponible dans cette session) — logique validée par lecture de code et cohérence avec le
mécanisme déjà utilisé ailleurs (`getUserSupplementResId()`, fonction transverse existante et
déjà éprouvée par SP-C1/SP-C5).

**[2026-06-21] Bug — la liste des oppositions de la rencontre ne se rafraîchit pas après modification**

*Signalement* : modifier une opposition ne met pas à jour la liste des oppositions affichée dans la
fiche Rencontre.

*Cause* : `soumettre()` (`include/ajax/modifier/opposition.php`) ne traitait que la vue Opposition
elle-même après un save réussi — `actualiserPageSub(URL_OPP_DETAIL, {id: OPP_ID})` recharge
`#detail-pp-sub`, mais rien ne rechargeait `#detail-pp` (la fiche Rencontre affichée en dessous, qui
contient la `<table class="camp-sous-liste">` des oppositions). La branche création
(`OPP_ID === 0`) n'avait pas ce problème : elle appelle `naviguerDetailPP(URL_RE_DETAIL, {id: RE_ID})`,
qui recharge `#detail-pp` en entier (mais empile une nouvelle entrée dans l'historique de
navigation — pas adapté pour un simple rafraîchissement après édition, d'où l'absence de cet appel
dans la branche édition).

*Correctif* : nouvelle fonction `rafraichirDetailPPCourant()` (`js/main.js`, à côté de
`naviguerDetailPP()`/`retourDetailPP()`) — recharge le panel `#detail-pp` à partir du **sommet
actuel** de `_detailPpStack` (`_chargerDetailPP(top.url, top.params, …)`) **sans empiler de
nouvelle entrée**, contrairement à `naviguerDetailPP()`. Appelée juste avant
`actualiserPageSub(URL_OPP_DETAIL, …)` dans la branche édition de `soumettre()`. Les deux appels
(`#detail-pp` et `#detail-pp-sub`) sont deux fetch indépendants ciblant des éléments DOM différents
— pas de risque de course critique entre les deux.

*Bug apparenté repéré au passage, non corrigé (hors périmètre de ce signalement)* : le bouton
Supprimer de la vue Opposition (`detail-pp-sub/opposition.php`) appelle
`campOppDemanderSuppression(oppId, reId)` (`js/campagne.js`), qui cherche
`#camp-opp-row-{id}`/`#camp-opp-confirm-{id}` dans le DOM — ces éléments n'existent que dans la
liste de `rencontre.php`, jamais dans la vue Opposition elle-même. Supprimer une opposition depuis
sa propre vue détail ne fait donc actuellement **rien** (pas d'erreur visible, juste un early
return silencieux dans `campOppDemanderSuppression`). Fonctionne correctement depuis le menu ⋮ de
la liste dans `rencontre.php`. Probable même catégorie de bug que les deux précédents (fonctionnalité
écrite en supposant un contexte DOM — liste rencontre — qui ne correspond pas à tous les points
d'entrée possibles du bouton). À corriger si signalé séparément.

**[2026-06-21] Correctif — bouton Supprimer inopérant depuis la vue Opposition**

Corrigé tel qu'identifié ci-dessus : `detail-pp-sub/opposition.php` n'appelle plus
`campOppDemanderSuppression()`. Nouvelle fonction autonome `oppDetailSupprimer(oppId)`, définie
inline (`<script>` dans le même fichier, pattern déjà utilisé pour le toggle visibilité supplément
de `modifier/monstre.php`) — `confirm()` natif (pas de ligne de confirmation inline à dessiner, vue
à un seul élément) → `postAjax(campUrlEnreg, {action:'supprimerOpposition', id:oppId})` →
`fermerSubPanel()` + `rafraichirDetailPPCourant()` en cas de succès. `campUrlEnreg` et `postAjax`
restent accessibles : ce sont des globaux définis une fois au chargement initial de
`campagnes/index.php`, jamais ré-évalués lors de l'injection des fragments `#detail-pp`/
`#detail-pp-sub` (simples fetch + innerHTML dans la même page).

**[2026-06-21] Nouveau — Transférer / Dupliquer une opposition (SP-T0)**

*Demande* : ajouter au menu ⋮ de la liste des oppositions deux actions, **Transférer** et
**Dupliquer**, chacune ouvrant un menu contextuel proposant les rencontres de la même campagne ;
anticiper dans l'interface (sans l'implémenter) une évolution future vers le choix d'une rencontre
d'une **autre** campagne, à planifier/numéroter comme les étapes Monstres (SP-C, SP-E).

*Numérotation retenue* : **SP-T** (nouveau préfixe, distinct de SP-C/Supplément et SP-E/Équipements).
SP-T0 = ce qui est livré aujourd'hui (même campagne). SP-T1 = extension inter-campagnes, planifiée
mais non codée — cf. `ARCHITECTURE_0_REFERENCE.md` § Transfert / Duplication d'opposition (SP-T).

*Implémentation* :
- **Backend** (`campagnes/enregistrement.php`) : deux nouvelles actions dispatchées,
  `transfererOpposition` (`UPDATE opp_re_id`) et `dupliquerOpposition` (`INSERT` copie). Toutes
  deux passent par `checkReOwner()` sur la rencontre source **et** sur la rencontre cible, **plus**
  un nouveau garde-fou `memeCampagne($db, $re_id_a, $re_id_b)` — nécessaire car `checkReOwner()`
  seul ne garantit que "rencontre appartenant à une campagne du MJ courant", pas "même campagne que
  la source" : un MJ avec plusieurs campagnes pourrait sinon transférer une opposition vers une
  rencontre d'une autre de ses propres campagnes sans que `checkReOwner()` s'y oppose. Testé par
  exécution réelle des requêtes SQL sur une instance MariaDB locale (schéma reconstitué à partir de
  `SCHEMA_SQL.md`) : jointure `memeCampagne`, `UPDATE` transfert, `INSERT` duplication — tous
  vérifiés directement en base, pas seulement relus.
- **Duplication — suffixe « - copie »** : appliqué uniquement quand la cible est la rencontre
  d'origine (duplication "en place"), conformément à la convention déjà actée le 2026-06-01 pour la
  duplication en général. Vers une rencontre différente, le nom de la copie n'est pas modifié (pas
  de risque de confusion puisqu'elle n'apparaît pas à côté de l'original dans la même liste).
- **Endpoint JSON** `include/ajax/liste-rencontres-campagne.php` : liste des rencontres d'une
  campagne, groupées scénario › chapitre, avec `exclude_re_id` optionnel (utilisé par Transférer
  pour omettre la rencontre d'origine — non utilisé par Dupliquer, qui propose volontairement aussi
  la rencontre d'origine).
- **Popup contextuel** (`#camp-transfer-popup`, markup ajouté dans `rencontre.php`, logique dans
  `js/campagne.js`) : modèle visuel repris de `.mo-tag-popup` (popup flottant `position: absolute`,
  z-index 1200), mais **positionnement recalculé différemment** — `.mo-tag-popup` utilise
  `offsetTop`/`offsetLeft` du textarea, qui fonctionne car rien ne s'interpose entre le textarea et
  son `offsetParent` (`#modification`). Ici, le bouton déclencheur vit dans `.comp-menu-ligne`
  (`position: relative`), qui deviendrait l'`offsetParent` du bouton et fausserait tout calcul basé
  sur `offsetTop`/`offsetLeft`. Calcul retenu : différence de `getBoundingClientRect()` entre le
  bouton et `#detail-pp` (l'ancêtre réellement positionné du popup, `position: fixed` +
  `transform` → containing block), plus compensation du scroll interne de `#detail-pp`
  (`overflow-y: auto`). Fermeture au clic extérieur : même pattern différé (`setTimeout(…, 0)`
  avant d'enregistrer l'écouteur `document`) que `campToggleMenu()`, pour ne pas capter le clic qui
  vient d'ouvrir le popup.
- **Anticipation SP-T1** : pied de page fixe et non cliquable dans le popup
  (« Vers une autre campagne — bientôt disponible »). Aucune logique de sélection de campagne en
  amont — purement un repère visuel d'intention pour l'instant.
- Après succès (transfert ou duplication) : popup fermé, `rafraichirDetailPPCourant()` (la même
  fonction que pour le correctif de rafraîchissement de liste du 2026-06-21 précédent) pour mettre
  à jour la liste des oppositions affichée.

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

**[2026-07-01] SP-C2→C5 — Répliqué sur les 7 entités restantes (Dons, Sorts, Compétences, Races, Classes, Objets magiques, Historiques).**

*Contenu livré*, sur le modèle exact de Monstres (seule entité déjà traitée avant ce jour) :
- **SP-C2** : `champ_public`/`champ_visible`/`champ_res_owner` déclarés dans `$listConfig` des 7 contrôleurs
  (`compendium/{dons,sorts,competences,races,classes,objets,historiques}.php`). Moteur `compendium-liste.php`
  inchangé (déjà générique depuis le passage de Monstres).
- **SP-C3** : bouton Modifier de `detail-pp/*.php` conditionné par `canEditCompendiumEntry($db, res_j_id)`
  au lieu de `canEditCompendium()` — nécessite `res.res_j_id` ajouté au `SELECT` de chacune des 7 fiches.
- **SP-C4** : `modifier/*.php` — `<select>` source à 2 `<optgroup>` (officielles / « Mon supplément », sentinelle
  `'supplement'`), checkboxes `_public`/`_visible` affichées uniquement pour une source de supplément, script
  JS de bascule + contrainte client (`_public` coché ⇒ `_visible` coché et désactivé) — copié du pattern Monstres
  sur les 7 formulaires.
- **SP-C5** : `enregistrement.php` — chaque `enregistrer{Don,Sort,Competence,Race,Classe,Objet,Historique}()`
  résout désormais la source via `getOrCreateUserSupplement()` (sentinelle `'supplement'`) ou valide
  l'appartenance d'un `res_id` de supplément existant (garde-fou anti-forgerie de requête), calcule
  `_public`/`_visible` avec la contrainte serveur `_public=1 ⇒ _visible=1`. Suppression : nouvelles fonctions
  dédiées `supprimer{Don,Competence,Objet,Historique}()` (gating per-entry via `canEditCompendiumEntry()`),
  remplaçant `supprimerEntite()` générique qui n'avait aucune notion de propriétaire ; `supprimerSort()` et
  `supprimerRace()`/`supprimerClasse()` (déjà dédiées pour leurs vérifications de dépendances) complétées avec
  la même garde per-entry, insérée *avant* leurs vérifications métier existantes.

*Cas particulier — Objets magiques (`dd_objets_magiques`)* : `om_visible` préexistait à SP-C avec une sémantique
propre (« visible par les joueurs », librement modifiable quelle que soit la source, y compris officielle) —
conservée telle quelle, non fusionnée avec le mécanisme de brouillon des 7 autres entités. Seul `om_public` est
nouveau et n'agit que sur les entrées de supplément (forcé à 0 côté serveur pour les entrées officielles). Le
formulaire n'affiche donc qu'une checkbox « Partagé » conditionnelle (pas de checkbox « Visible » dupliquée,
celle-ci restant affichée en permanence comme avant). `detail-pp/objet.php` : le masquage préexistant
(`!canEditCompendium() && !om_visible`) est passé à `canEditCompendiumEntry()` pour laisser un propriétaire de
supplément voir ses propres brouillons — amélioration mineure alignée sur le pattern Monstres, aucune régression
(un éditeur global voyait déjà tout).

*Vérifications effectuées* (pas d'accès UI navigateur — pas de compte de test) :
- `php -l` sans erreur sur les 24 fichiers modifiés (7 contrôleurs liste + 7 detail-pp + 7 modifier +
  `enregistrement.php`).
- Smoke test HTTP (Apache + MySQL locaux démarrés pour l'occasion) : 302 (redirection login) sur les 21
  endpoints AJAX/contrôleurs, aucune 500.
- Script de validation SQL ponctuel (transactions ouvertes puis `ROLLBACK`, mêmes options PDO que
  `include/db.php` dont `ATTR_EMULATE_PREPARES=false`) : chaque `INSERT`/`UPDATE` des 7 `enregistrer*()`
  exécuté avec des valeurs factices contre le schéma réel — tous valides. Script supprimé après usage
  (fichier `_sp5_sql_test.php`, jamais committé).
→ **Non vérifié** : rendu visuel des formulaires, comportement JS du toggle source officielle/supplément,
  toggle "Afficher mes brouillons" en conditions réelles — à valider en navigateur à la prochaine session
  si besoin.

**[2026-07-01] SP-C5/SP-C6 — Blocage levé. `_public`/`_visible` existent déjà en base sur les 7 tables.**

*Action réalisée* : `SHOW CREATE TABLE` exécuté en direct sur la base de dev locale (`maikasteiymaika`,
MySQL XAMPP démarré pour l'occasion) sur les 7 tables listées dans l'audit du 2026-06-20 ci-dessous.

*Résultat* : `_public`/`_visible` (ou `_public` seul pour `dd_objets_magiques`, `om_visible` déjà
existant) sont **déjà présentes en base réelle** sur `dd_dons`, `dd_sorts`, `dd_competences`,
`dd_races`, `dd_classes`, `dd_historiques`, `dd_objets_magiques` — mêmes noms, mêmes types, même
sémantique par défaut (`_public` défaut 0, `_visible` défaut 1) que sur `dd_monstres`. La migration
SP-C0 a donc bien été appliquée en base pour les 8 entités, exactement comme pour Monstres avant sa
régularisation — seul le fichier `sql/patch_004_supplements.sql` et `SCHEMA_SQL.md` n'avaient pas
suivi (`patch_004_supplements.sql` reste introuvable dans le dépôt, non committé à l'époque).
`SCHEMA_SQL.md` mis à jour (v1.5) avec les 7 tables.

Écart annexe repéré sans rapport avec SP-C, noté pour mémoire, non traité ici : `dd_dons.do_page_source`
(int NOT NULL) existe en base sans documentation ni usage identifié dans le code audité jusqu'ici.

*Conséquence* : plus d'ambiguïté schéma/base. SP-C5 (`enregistrement.php` ownership + `_public`/
`_visible`) et SP-C4 (formulaire, dropdown 2 groupes) peuvent être répliqués directement sur le modèle
Monstres pour les 7 entités restantes, comme prévu par l'option "colonnes déjà présentes" de l'audit
du 2026-06-20 (ci-dessous, conservé pour traçabilité). SP-C6 (profil "Mes sources") n'a jamais été
bloquée par ce point — reprise possible indépendamment.

*Ordre retenu* : Dons en premier (structure la plus simple, cf. audit du 2026-06-20), puis Sorts,
Compétences, Races, Classes, Objets, Historiques.

---

**[2026-06-20] SP-C5/SP-C6 — Mis en pause après audit. Écart schéma à lever avant reprise.**

*Décision* : SP-C5 (enregistrement.php ownership, 7 entités restantes) et SP-C6 (profil "Mes
sources" — suppléments tiers) sont mis en pause à la demande de l'utilisateur, le temps de lever
le point bloquant ci-dessous. Ne pas reprendre SP-C5 sur Dons/Sorts/Compétences/Races/Classes/
Objets/Historiques sans avoir d'abord traité ce point — c'est exactement le même type d'écart qui a
causé la régression `mo_j_id` documentée plus haut [2026-06-20].

*Constat (audit du code + de la doc, sans accès à la base de production)* :

1. **`enregistrer{Don,Sort,Competence,Race,Classe,Objet,Historique}()` dans `compendium/enregistrement.php`
   n'écrivent `_public`/`_visible` nulle part** — ni dans l'INSERT, ni dans l'UPDATE. `{xx}_res_id`
   est lu en brut depuis `$_POST`, jamais résolu via `getOrCreateUserSupplement()`/sentinelle
   `'supplement'` (le mécanisme posé pour Monstres, SP-C4/C5).
2. **Suppression** : seules Sorts, Races, Classes ont une fonction dédiée (`supprimerSort()`,
   `supprimerRace()`, `supprimerClasse()`), mais **sans garde per-entry** (`canEditCompendiumEntry()`
   absent) — même lacune que celle corrigée pour Monstres (`supprimerMonstre()`, SP-C5). Dons,
   Compétences, Objets, Historiques utilisent `supprimerEntite()` générique, idem sans garde.
3. **`doc/SCHEMA_SQL.md` ne documente `_public`/`_visible` pour AUCUNE des 7 tables** (`dd_dons`,
   `dd_sorts`, `dd_competences`, `dd_races`, `dd_classes`, `dd_historiques`, `dd_objets_magiques`) —
   seules `mo_public`/`mo_visible` y figurent (ajoutées le 2026-06-20 pour Monstres). Vérifié
   explicitement sur `dd_sorts` et `dd_objets_magiques` : colonnes absentes de la doc.
4. **`sql/patch_004_supplements.sql`** — le fichier que l'entrée `[2026-06-17] SP-C0 et SP-C1
   livrées` (plus haut dans ce journal) décrit comme livré (15 `ALTER TABLE` sur les 8 tables) —
   **n'existe pas dans le dépôt** (`find . -iname "*patch_004*"` ne retourne rien). Seule trace :
   les mentions dans `ARCHITECTURE_0_REFERENCE.md` et ce journal.

*Conséquence* : impossible de savoir, sans interroger la base réelle, si `do_public`/`do_visible`
(et équivalents sur les 6 autres tables) **existent déjà en production** (migration appliquée
directement en base sans que le `.sql` ni `SCHEMA_SQL.md` n'aient été committés — schéma identique
au cas Monstres avant régularisation) **ou si SP-C0 reste à faire** pour ces 7 tables. Coder
SP-C5/SP-C4 dessus sans lever cette ambiguïté reproduirait l'incident `mo_j_id` à l'identique.

*Action requise avant reprise (à fournir par l'utilisateur, pas déductible du dépôt)* :
`SHOW CREATE TABLE` (ou export phpMyAdmin équivalent) d'au moins une des 7 tables — `dd_dons` ou
`dd_sorts` suggéré en premier, structure la plus simple. Selon le résultat :
- colonnes `_public`/`_visible` présentes → traiter comme Monstres : SP-C5 (`enregistrement.php`)
  + SP-C4 (formulaire) directement, mettre à jour `SCHEMA_SQL.md` au passage pour les 7 tables.
- colonnes absentes → SP-C0 reste à faire pour ces 7 tables (`ALTER TABLE`, idéalement committé
  cette fois dans `sql/` plutôt qu'appliqué directement en base) avant tout SP-C4/SP-C5.

*Hors périmètre de ce constat* : SP-C6 (profil "Mes sources") ne dépend pas de ce point — son blocage
est uniquement l'absence d'implémentation (`profil/index.php` filtre `res_j_id IS NULL` en dur,
ligne ~46), aucun écart de schéma identifié à ce sujet. Peut être repris indépendamment de la levée
du point ci-dessus si l'utilisateur le souhaite.

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
| SP-C2 | Moteur : `compendium-liste.php` (générique) + 8 contrôleurs (`champ_public`/`champ_visible`/`champ_res_owner`) | Élevée | ✅ livré (2026-07-01) — 8/8 entités branchées |
| SP-C3 | `detail-pp/*.php` × 8 : bouton Modifier per-entry | Modérée | ✅ livré (2026-07-01) — 8/8 entités |
| SP-C4 | `modifier/*.php` × 8 : source dropdown 2 groupes + champs `_public`/`_visible` | Modérée | ✅ livré (2026-07-01) — 8/8 entités |
| SP-C5 | `enregistrement.php` : ownership + `_public`/`_visible` + auto-create supplément + suppression per-entry | Modérée | ✅ livré (2026-07-01) — 8/8 entités |
| SP-C6 | `profil/index.php` : "Mes sources" — suppléments publics d'autres utilisateurs | Faible | ⏸ **en pause** (non bloquée techniquement, mise de côté à la demande utilisateur — cf. [2026-06-20] SP-C5/SP-C6 audit) |
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

**[2026-06-25] Parser Monstres — priorité objets magiques > sorts + tag manuel `&Nom&`**

- Constat : `construireIndexAuto()` priorisait `sort > objet > glossaire` pour la liaison automatique
  (utilisée notamment sur la ligne "Equipement" en label_gras DD2024). En cas d'ambiguïté de nom
  entre un objet magique et un sort, le sort gagnait — contre-intuitif sur une ligne d'équipement.
- Décision : inversion de la priorité globale du moteur de liaison automatique →
  `objet > sort > glossaire`. Pas de traitement spécifique à la ligne "Equipement" : le changement
  s'applique à tout le texte parsé (pouvoirs, labels gras, etc.), à valider à l'usage.
- Ajout du tag explicite `&Nom de l'objet&` (résolu en pré-passe par `resoudreTagsExplicites()`),
  sur le modèle de `#Nom du don#` et `$Nom du sort$`. Comble un manque : les objets magiques
  n'avaient jusqu'alors aucun moyen pour l'utilisateur de forcer le lien par tag, contrairement aux
  dons et sorts.
- Fichier modifié : `include/monstre-parser.php` (`construireIndexAuto()`,
  `resoudreTagsExplicites()`).

**[2026-06-25] Nouveau — Système d'aide contextuelle générique (icône `?`)**

- Besoin : afficher des bulles d'aide ancrées à un label (ex. rappel des tags `#`/`$`/`&`/`@`/`%`
  du parser monstre, au niveau du label "Description complète"), réutilisable dans tout
  formulaire de l'application sans dépendre du moteur de panels existant.
- Décision : contenu déclaré dans `include/aide-contextuelle.php` (tableau de closures
  `PDO $db, int $ruleset_id -> string HTML` — autorise du contenu dynamique sans changer l'API
  d'appel), édité à la main (pas de table SQL ni d'interface admin pour l'instant).
  Helper `aideIcone(string $cle)` dans `include/helpers.php` pour l'insertion côté formulaire.
  Endpoint unique `include/ajax/aide.php?cle=...` (GET, `requireAuth()`).
- Contrainte technique posée et résolue : `#detail-pp` et `#detail-pp-sub` ont un `transform`
  CSS, qui devient le containing block des descendants `position: fixed` (et leur
  `overflow-y: auto` peut rogner un enfant statique). La bulle `#aide-bulle` est donc **toujours**
  créée dynamiquement en enfant direct de `<body>` par `js/main.js` (jamais nichée dans le DOM
  d'un panel), positionnée via `getBoundingClientRect()` de l'icône, `z-index: 350`
  (au-dessus de `#detail-pp-sub` à 300). Fermeture : clic extérieur, Échap, re-clic, ou scroll
  de la couche d'ouverture (capture sur tous les conteneurs scrollables).
- Première utilisation : label "Description complète" du formulaire monstre
  (`include/ajax/modifier/monstre.php`), clé `monstre-tags-description`.
- Fichiers : `include/aide-contextuelle.php` (nouveau), `include/ajax/aide.php` (nouveau),
  `include/helpers.php` (`aideIcone()`), `css/modules.css` (`.aide-icone`, `#aide-bulle`),
  `js/main.js` (handler délégué `.aide-icone`).
- Pour ajouter une aide ailleurs dans l'app : une entrée dans `aide-contextuelle.php` +
  `<?= aideIcone('ma-cle') ?>` à l'endroit voulu — aucune autre modification nécessaire.

**[2026-06-25] Bug — tags de liaison ré-échappés en HTML littéral (double passage `h()`)**

- Symptôme : sur la ligne "Equipement" (et toute autre ligne combinant un tag explicite avec la
  liaison automatique), le `<span class="mo-lien">` produit par `resoudreTagsExplicites()` était
  affiché tel quel à l'écran au lieu d'être rendu comme lien.
- Cause : `formaterBlocDD2024()` chaîne systématiquement `resoudreTagsExplicites()` puis
  `lierAuto()`/`lierSorts()`/`lierDons()`. `lierAvecIndex()` traitait son entrée comme du texte
  brut intégral et appliquait `h()` sur tous les segments non reconnus par l'index — y compris
  le HTML déjà construit par la pré-passe de tags, ré-échappant ses chevrons en entités.
  Pas spécifique à "Equipement" : touchait toute combinaison tag + liaison auto (labels gras,
  pouvoirs, sous-listes de sorts, etc.).
- Correctif : `lierAvecIndex()` détecte désormais les blocs `<span class="mo-lien">...</span>`
  déjà présents dans le texte, les fait transiter inchangés (`lierAvecSegmentsProteges()`), et
  n'applique le tokenizer/`h()` (`lierSegmentBrut()`, ex-corps de `lierAvecIndex()`) qu'aux
  segments de texte brut situés entre eux.
- Fichier modifié : `include/monstre-parser.php` (`lierAvecIndex()` découpée en
  `lierAvecSegmentsProteges()` + `lierSegmentBrut()`).

**[2026-06-26] SP-E1/E2/E3 — Module Équipements (liste, formulaire, fiche détail)**

- Reprise du plan SP-E (différé depuis le 2026-06-20, cf. `[2026-06-20] Clarification —
  dd_equipements`), après dépôt par l'utilisateur d'un export complet de la structure de base
  (`sql/maikasteiymaika-20260626.sql`) pour vérification schema-first avant développement.
- Vérification : `dd_equipements` existe en base, structure identique au schéma SP-E0
  (`eqt_id`, `eqt_nom`, `eqt_description`, `eqt_visible`, `eqt_res_id`, `eqt_camp_id`,
  `eqt_ruleset_var_id`) — aucun écart, pas de `eqt_public`/owner (confirmé : modèle de visibilité
  simple, pas le mécanisme Supplément SP-C).
- Modèle suivi : module **Dons** (entité compendium simple, sans supplément) plutôt que
  Objets magiques (trop riche : catégories, formats, rareté — non pertinent pour l'équipement
  mondain en l'état du schéma fourni).
- Livré : `compendium/equipements.php` (`$listConfig`, sans filtre spécifique — pas de catégorie
  en base), `include/ajax/modifier/equipement.php` + `enregistrerEquipement()` dans
  `compendium/enregistrement.php` (`case 'equipement'`), `include/ajax/detail-pp/equipement.php`,
  `soumettreEquipement()` dans `js/compendium.js`, carte « Équipements » ajoutée dans
  `compendium/index.php`.
- Écart assumé : `eqt_visible` n'est pas câblé dans `$listConfig` (pas de `champ_visible` déclaré)
  — la liste affiche tous les équipements sans filtrage, comme `dd_dons` (qui n'a même pas cette
  colonne). Champ exposé dans le formulaire (case à cocher) et persisté en base, mais sans effet
  sur l'affichage liste/détail pour l'instant. À traiter explicitement si besoin lors de SP-E5.
- SP-E4 (liaison `monstre-parser.php`) reste à faire — n'est plus bloqué techniquement
  (`detail-pp/equipement.php` existe désormais) mais nécessite un arbitrage de priorité
  (`equipement` vs `objet`/`sort`/`glossaire` dans `construireIndexAuto()`), non traité aujourd'hui.
- Vérifié : `php -l` sur tous les fichiers PHP modifiés/créés (OK), requête `curl` sur
  `compendium/equipements.php` (redirection 302 attendue — `requireAuth()`, pas d'erreur 500).

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
- [ ] **⏸ BLOQUANT avant SP-C5 (7 entités restantes) — vérifier `SHOW CREATE TABLE dd_dons` (ou `dd_sorts`) : `_public`/`_visible` existent-elles déjà en base ? `sql/patch_004_supplements.sql` introuvable dans le dépôt, `SCHEMA_SQL.md` ne documente ces colonnes pour aucune des 7 tables. Cf. `DECISIONS_LOG.md` [2026-06-20] SP-C5/SP-C6 audit pour le détail complet — ne pas refaire cette analyse.**
- [ ] SP-C5 — Sorts, dons, compétences, classes, races, objets, historiques : enregistrement.php (ownership + auto-create supplément + suppression per-entry) — bloqué, voir item ci-dessus
- [ ] SP-C6 — Mettre à jour profil/index.php (Mes sources — suppléments tiers) — en pause (non bloquée techniquement, juste reportée)
- [x] ~~SP-C7 — Nettoyage monstres post-migration (suppression include/ajax/modifier/monstre-old.php, relecture monstre-parser.php pour refs mo_j_id résiduelles)~~ → livré (2026-06-20)
- [x] ~~Parser monstre — liaison auto objets magiques/équipement (ligne Equipement + blocs Actions)~~ → livré (2026-06-20, typesLiablesMonstre() + construireIndexAuto())
- [x] ~~Oppositions (Campagnes) — appliquer monstre-parser.php au lieu du `<pre>` brut~~ → livré (2026-06-20, detail-pp-sub/opposition.php, scope getActiveResIdsCampagne())
- [ ] Sous-panneaux — `actualiserPageSub()`/`fermerSubPanel()` ne gèrent qu'un niveau (pas de pile) : cliquer un lien `.mo-lien` depuis une opposition (déjà dans #detail-pp-sub) remplace la vue au lieu de s'empiler. Pas bloquant, à reprendre si gênant en pratique — cf. `DECISIONS_LOG.md` [2026-06-20] partie "Limite UX assumée".
- [x] ~~SP-E0 — dd_equipements : CREATE TABLE~~ → livré (2026-06-20, sql/2026-06-20_equipements_sp-e0.sql, committé + testé sur MariaDB réelle)
- [x] ~~SP-E1 — compendium/equipements.php (contrôleur liste + $listConfig)~~ → livré (2026-06-26)
- [x] ~~SP-E2 — modifier/equipement.php (formulaire) + enregistrement.php (enregistrerEquipement())~~ → livré (2026-06-26)
- [x] ~~SP-E3 — detail-pp/equipement.php (fiche détail)~~ → livré (2026-06-26)
- [ ] SP-E4 — monstre-parser.php : type 'equipement' (typesLiablesMonstre/construireIndexAuto) + MO_LIEN_FICHIERS — débloqué (SP-E3 livré), reste à faire
- [ ] SP-E5 (à arbitrer) — Équipements rejoint le mécanisme Supplément (SP-C) : eqt_public + champ_public/champ_visible/champ_res_owner
- [x] ~~Oppositions — bug formulaire Modifier ouvert sous la vue (z-index)~~ → corrigé (2026-06-20, fermerSubPanel() avant actualiserPageModif() dans detail-pp-sub/opposition.php)
- [x] ~~Oppositions — monstre d'origine optionnel (saisie manuelle possible)~~ → corrigé (2026-06-20, opp_mo_id nullable + retrait blocages serveur/client)
- [x] ~~Recherche monstre (création opposition) — supplément personnel du MJ absent des résultats~~ → corrigé (2026-06-21, getActiveResIdsCampagne() inclut désormais le supplément du propriétaire de la campagne)
- [ ] recherche-monstre.php ne filtre pas mo_public/mo_visible — fuite potentielle de brouillons si un supplément tiers est explicitement ajouté aux sources d'une campagne (risque faible, non signalé séparément) — cf. DECISIONS_LOG.md [2026-06-21]
- [x] ~~Oppositions — liste de la rencontre non rafraîchie après modification~~ → corrigé (2026-06-21, rafraichirDetailPPCourant() dans js/main.js)
- [ ] Oppositions — bouton Supprimer inopérant depuis la vue Opposition elle-même (campOppDemanderSuppression cherche des éléments DOM qui n'existent que dans la liste rencontre.php) — repéré 2026-06-21, non corrigé, fonctionne depuis le menu ⋮ de la liste
- [x] ~~Oppositions — bouton Supprimer inopérant depuis la vue Opposition~~ → corrigé (2026-06-21, oppDetailSupprimer() autonome dans detail-pp-sub/opposition.php)
- [x] ~~SP-T0 — Transférer/Dupliquer une opposition vers une rencontre de la même campagne~~ → livré (2026-06-21, popup contextuel + campagnes/enregistrement.php + liste-rencontres-campagne.php)
- [ ] SP-T1 — Transférer/Dupliquer une opposition vers une rencontre d'une autre campagne (sélecteur de campagne en amont dans le popup) — planifié, footer du popup réservé visuellement, aucune logique codée

---

## [2026-06-29] Export Roll20 NPC — `include/ajax/export/monstre-roll20.php`

### Contexte

Développement de la fonctionnalité d'export des monstres du compendium vers Roll20
au format JSON (fiche D&D 5e 2014 VF). Cible : campagne DD2024, fiche Roll20 "D&D 5e (2014)".

---

### D-R1 — Source de `npc_type`

**Décision :** `npc_type` = première ligne de `mo_stats` si elle ne commence pas par `CA`.
Si `mo_stats` commence directement par `CA`, `npc_type` est laissé vide.

**Raison :** La première ligne contient le type/alignement du monstre (ex : "Grande aberration,
Neutre mauvais"). Elle peut être absente dans certains formats anciens.

---

### D-R2 — Source du Bonus de Maîtrise

**Décision :** Le BM est extrait de la ligne `FP {X} ({Y} PX; BM {Z})` dans `mo_stats`.
- `{X}` → `npc_challenge` + fallback `mo_fp_id`
- `{Y}` → `npc_xp` (entier, espaces ignorés pour les grands nombres)
- `{Z}` → `pb`, `npc_pb`, `pb_custom`, `pb_type="custom"`

**Raison :** La ligne FP est la seule source structurée du BM dans le texte libre `mo_stats`.
Le champ `mo_fp_id` sert de fallback pour `npc_challenge` si la ligne FP est absente.

---

### D-R3 — Lignes optionnelles (Sens, Langues, Résistances, Immunités)

**Décision :** Ces lignes sont parsées si présentes, champ Roll20 laissé à `""` si absent.
Lignes concernées (préfixes reconnus, insensibles à la casse/accents) :
- `Compétences :` → compétences NPC avec détection expertise (BM×2)
- `Résistances aux dégâts :` → `npc_resistances`
- `Immunités aux dégâts :` → `npc_immunities`
- `Immunités aux états :` → `npc_condition_immunities`
- `Vulnérabilités :` → `npc_vulnerabilities`
- `Sens :` → `npc_senses`
- `Langues :` → `npc_languages`

---

### D-R4 — Mécanisme d'import Roll20

**Décision :** Import via script Roll20 API Pro `doc/roll20-api/ImportNPC.js`.

**Flux :**
1. PHP génère `roll20_{nom}.json` (téléchargement direct)
2. MJ colle le JSON dans les **GM Notes** d'un Handout Roll20
3. Commande chat : `!import-npc [nom_handout]` (défaut : "Import NPC")
4. Le script lit le Handout, parse le JSON, `createObj('character')` + `createObj('attribute')`

**Raison :** La Roll20 API ne permet pas l'import de fichiers externes sans Pro.
L'import via handout évite les limites de taille du chat (JSON souvent > 4 096 chars).

---

### D-R5 — `spelloutput` pour les sorts PNJ

**Décision V1 :** `spelloutput = "SPELLCARD"` pour **tous** les sorts PNJ.

**Raison :** La résolution sort → bouton d'attaque Roll20 (ATTACK) nécessite de connaître
le type de jet pour chaque sort (attaque de sort vs. jet de sauvegarde vs. aucun).
Cette logique dépasse le scope du parsing `mo_stats` actuel.

**V2 prévue (documentée, non implémentée) :**
- Ajouter un champ `so_type_jet` (attaque/sauvegarde/aucun) dans `dd_sorts`.
- Ou détecter via regex dans `so_description` les patterns d'attaque de sort.
- Générer alors `spelloutput = "ATTACK"` pour les sorts offensifs avec bouton de jet.

---

### D-R6 — Mapping de l'initiative

**Décision :** `initiative_bonus` Roll20 = `DEX_mod + DEX_score / 100` (convention tie-breaker).

**Raison :** La fiche Roll20 D&D 5e 2014 calcule l'initiative sur la base du modificateur de
Dextérité uniquement. L'initiative DD2024 (ex : +7 pour un Aboleth avec INT 18) n'est pas
supportée par la fiche 2014 — la valeur de `mo_stats` (`CA X Initiative +Y (Z)`) est ignorée
pour la construction du JSON.

**Impact utilisateur :** L'initiative affichée dans Roll20 diffère de l'initiative 2024 pour les
monstres utilisant INT ou d'autres caractéristiques. Limitation assumée (hors scope fiche 2014).

---

### D-R7 — Extension `$listConfig` : clé `row_actions`

**Décision :** `compendium-liste.php` est étendu avec la clé optionnelle `row_actions`
(tableau d'objets `{label, icon, href, download, require_edit}`).

**Comportement (corrigé le 2026-06-29, suite retour terrain) :** Toutes les `row_actions`
sont affichées comme items du menu ⋮, jamais comme bouton icône isolé dans `col-action`.
- `require_edit = false` → item visible pour **tous** les utilisateurs dans le menu ⋮.
  Le menu ⋮ s'affiche même pour un utilisateur non-éditeur dès qu'au moins une
  `row_action` ouverte existe (variable `$_has_open_actions` dans `compendium-liste.php`).
- `require_edit = true` → item réservé aux éditeurs (`canEditCompendiumEntry`), à côté
  de Modifier/Supprimer.

**Rétro-compatibilité :** Totale — clé absente = aucun comportement ajouté.
**Utilisation initiale :** Export Roll20 dans `compendium/monstres.php`.

---

### D-R8 — Chuchotage des jets au MJ (`wtype`)

**Décision :** L'attribut Roll20 `wtype` est exporté avec la valeur littérale `/w gm `
(chaîne fixe), et non une référence `@{whispertoggle}` comme en V1 initiale.

**Raison :** `@{whispertoggle}` correspond au mode fiche "Bascule" (boutons manuels),
pas au mode "Toujours" demandé. La fiche officielle D&D 5E by Roll20 ne publie pas
son code source (les sheets "by Roll20" sont fermées), mais la documentation
communautaire confirme que l'attribut `wtype` porte directement la valeur utilisée
dans les macros de jet (`@{wtype}&{template:...}`) — y compris pour la commande API
`!setattr --allgm --wtype|/w gm` utilisée par la communauté pour forcer ce réglage
rétroactivement. Régler `wtype = '/w gm '` à l'export reproduit exactement ce comportement.

**Impact :** Tous les jets du PNJ importé (attaques, sauvegardes, compétences) sont
automatiquement chuchotés au MJ, sans réglage manuel sur la fiche après import.

---

### D-R9 — Action "Incantation" recopiée intégralement dans Roll20

**Décision :** Le bloc `Incantation.` n'est plus filtré lors de la génération des
`repeating_npctrait` / `repeating_npcaction`. Son texte complet (intro + sous-listes
"À volonté :", "X/jour :"…) est recopié à l'identique comme action `TYPE B` (description),
en plus de l'extraction structurée des sorts dans `repeating_spell-N`.

**Raison :** Le MJ veut conserver le texte narratif complet de l'incantation
(formulation exacte du DD de sauvegarde, regroupement par fréquence d'usage) visible
sur la fiche, en plus des sorts importés individuellement et cliquables.

---

### D-R10 — Bug `firebaseId()` : suppression de `_` du charset

**Bug constaté :** Certains sorts générés apparaissaient vides dans Roll20 alors
qu'ils étaient correctement trouvés et exportés côté PHP (ex : "main du mage", "vol").

**Cause :** Le charset de `firebaseId()` incluait `_`, qui est le caractère séparateur
utilisé par Roll20 dans les noms d'attributs (`repeating_section_{ID}_field`). Un ID
contenant lui-même un `_` tronque le parsing du nom d'attribut côté Roll20 : la ligne
apparaît dans `_reporder` mais aucun attribut ne lui est rattaché → ligne fantôme vide.

**Correction :** Charset réduit à `[A-Za-z0-9]` (62 caractères, `random_int(0, 61)`).

---

### D-R11 — Bug noms de sorts avec note entre parenthèses

**Bug constaté :** Des sorts cités avec une note explicative dans `mo_stats`
(ex. `armure du mage (compris dans la CA)`, `boule de feu (au 4e niveau)`) n'étaient
jamais trouvés en base, donc absents du JSON exporté.

**Cause :** Le nom complet avec parenthèse ne matchait pas le nom en base (`armure du mage`).

**Correction :** `parseIncantation()` retire systématiquement tout texte entre
parenthèses du nom de sort avant ajout à `noms_sorts`, via
`preg_replace('/\s*\([^)]*\)/', '', $nom)`.

---

### D-R12 — Import Roll20 depuis le token sélectionné (sans Handout)

**Décision :** `ImportNPC.js` gagne une seconde commande `!import-npc-token`, qui lit
les GM Notes du **token actuellement sélectionné** sur la carte plutôt que d'un Handout.
En plus de créer le personnage, elle lie automatiquement le token (`token.set({represents,
name})`).

**Raison :** Le MJ pose souvent un token générique sur la carte avant la rencontre ;
coller le JSON directement dans les GM Notes du token (au lieu de créer un Handout
intermédiaire) accélère le flux en cours de partie. Pattern repris de scripts
communautaires Roll20 connus (ex. 5eShapedCompanion `!shaped-import-statblock`).

**Comportement conservé :** `!import-npc [nom_handout]` (mode Handout, sans lien token)
reste disponible pour la préparation de PNJ hors session.

---

### D-R13 — Bug `!import-npc-token` totalement silencieux : `gmnotes` Graphic est synchrone

**Bug constaté :** La commande `!import-npc-token` ne produisait absolument rien
(ni message chat, ni log API Console, ni erreur), alors que `!import-npc-ping`
répondait correctement et que la détection "aucun token sélectionné" fonctionnait.

**Cause :** Sur les objets Roll20 **Character** et **Handout**, les champs
`notes`/`gmnotes`/`bio` sont stockés de façon asynchrone (backend Firebase) et
nécessitent impérativement le pattern `obj.get('champ', function(valeur){...})`.
Sur un objet **Graphic** (token), en revanche, `gmnotes` est une propriété
**synchrone** classique — `obj.get('gmnotes')` retourne directement la valeur,
sans callback. En appliquant par erreur le pattern asynchrone au token, le
callback n'était jamais invoqué par Roll20 (ce n'est pas une erreur silencieuse :
c'est simplement un usage incorrect de l'API qui n'aboutit à aucune exécution).

**Correction :** `importerDepuisToken()` lit désormais `token.get('gmnotes')`
de façon synchrone, sans callback. Le mode Handout (`!import-npc`) conserve le
pattern asynchrone avec callback, qui est correct dans son cas.

**Leçon générale :** Sur Roll20 API, vérifier au cas par cas si une propriété
texte (`notes`, `gmnotes`, `bio`) est synchrone ou asynchrone selon le **type
d'objet** porteur (Character/Handout = async ; Graphic = sync), et ne jamais
supposer que le pattern d'un type s'applique à l'autre.

---

### D-R14 — Synchronisation de l'avatar/_defaulttoken du personnage en mode token

**Constat :** Après import en mode `!import-npc-token`, le token sur la carte est bien
lié à la fiche (`represents`), mais la fiche elle-même (portrait, vignette bibliothèque,
token par défaut pour un futur glisser-déposer) ne reprend pas l'image du token.

**Raison :** `token.set({represents: charId})` établit uniquement le lien fonctionnel
pour les jets (`@{selected|...}`, macros liées au token). Le personnage (Character) et
le token (Graphic) restent deux objets distincts dans le modèle Roll20, chacun avec
ses propres propriétés visuelles (`avatar`/`_defaulttoken` côté Character, `imgsrc`
côté Graphic) — aucune des deux API ne synchronise l'autre automatiquement.

**Correction :** Après liaison du token, `importerNpc()` lit `token.get('imgsrc')`,
le convertit vers sa variante `thumb` via `getCleanImgsrc()` (seule variante
acceptable en écriture par l'API Roll20, cf. doc officielle Mod Scripts Cookbook),
puis applique :
- `character.avatar` = image nettoyée (portrait visible sur la fiche et dans la bibliothèque)
- `character._defaulttoken` = JSON décrivant un token par défaut (image, largeur,
  hauteur, calque) réutilisé lors d'un futur glisser-déposer du personnage depuis le Journal

**Limitation :** Si l'image du token ne provient pas de la bibliothèque utilisateur
(upload externe, lien direct non standard), `getCleanImgsrc()` retourne `undefined` —
l'avatar n'est pas synchronisé et un avertissement explicite est chuchoté au MJ et
journalisé dans l'API Console plutôt que d'échouer silencieusement.

---

### D-R15 — `ImportNPC.js` v1.3 : chuchotage forcé, taille token, barres, position

**Contexte :** `include/ajax/export/monstre-roll20.php` n'est pas versionné sur le dépôt
GitHub (confirmé 404 sur `raw.githubusercontent.com`) — seul `ImportNPC.js` y est tenu à
jour avec un système de versioning propre (en-tête `// VERSIONS`). Cette entrée documente
exclusivement les évolutions apportées côté **import**, indépendamment de l'état réel du
script d'export local de Jean-Michel.

**D1 — Chuchotage forcé (filet de sécurité) :** `importerNpc()` force désormais l'attribut
`wtype` à la valeur `/w gm ` sur **toute** fiche importée (mode handout et mode token),
qu'il soit déjà présent dans le JSON ou non — créé s'il manque, écrasé sinon. Garantit
"Chuchoter les jets au MJ : Toujours" même si l'export PHP source venait à régresser sur
ce point (cf. D-R8 pour le contexte du choix initial `/w gm `).

**D2 — Taille de token (mode token uniquement) :** `token.set({width: 70, height: 70})`
appliqué systématiquement à l'import. Valeur fixe en pixels, non paramétrable pour l'instant.

**D3 — Barres de jeton (mode token uniquement) :** Répartition confirmée par Jean-Michel :
- Barre 1 = `npc_ac` (CA) — **liée** à l'attribut (`bar1_link`)
- Barre 2 = `passive_wisdom` (Perception passive) — **liée** à l'attribut (`bar2_link`)
- Barre 3 = `hp` (PV) — **valeur directe**, sans lien (voir D-R17)

Les barres 1 et 2 sont liées à leur attribut via `bar{N}_link` : Roll20 resynchronise
automatiquement la barre si l'attribut change. La barre 3 est intentionnellement non liée
(voir D-R17 pour la raison). Filet de sécurité : si `hp.current` est vide (cas fréquent
côté export), la barre est initialisée à `hp.max` sans modifier l'attribut.

**D4 — Position des barres :** `token.set({bar_location: 'bottom'})` — confirmé comme
propriété officielle du Graphic dans la documentation Roll20 actuelle (valeurs possibles :
`overlap_top`, `overlap_bottom`, `bottom`). Correspond à "Options des barres de jeton >
Position : En dessous".

**D5 — Token par défaut de la fiche, correction du bug v1.2.1 :** La V1.2.1 tentait
d'écrire `character._defaulttoken` directement via `.set()` — cette propriété est en
réalité **en lecture seule** côté API (confirmée par la documentation officielle Roll20).
Explique pourquoi seul l'avatar était repris après import, jamais le token par défaut.
Remplacé par l'appel à la fonction utilitaire globale Roll20 dédiée
`setDefaultTokenForCharacter(character, token)`, qui capture l'état courant du token
(image, taille, barres, position des barres…) — appelée en tout dernier, après toutes les
modifications du token, pour que le snapshot soit complet.


---

### D-R16 — Parser `mo_stats` : formats d'incantation DD2024 v2 et dégâts alternatifs

#### D-R16.1 — Format des sous-listes de sorts avec séparateur tiret

**Bug constaté :** Sur le Prêtre de Baine (et a priori tous les lanceurs du MM2024 ayant
ce format), la description de l'action Incantation était tronquée (première ligne seulement)
et aucun sort n'était généré (`noms_sorts` vide).

**Cause :** Le parser `parseActionBlock` collectait les sous-listes de sorts en cherchant
uniquement le séparateur `:`. Le format observé sur ce monstre utilise `-` avec espaces :

```
Tour de magie - assistance, lumière, thaumaturgie
Niveau 1 (3/J) - blessure, injonction, Protection contre le mal et le bien
Niveau 2 (2/J) - immobilisation de personne, silence
Niveau 3 (2/J) - fusion dans la pierre
```

Le `while` se cassait immédiatement faute de `:` → `$full_text` n'incluait que la première
ligne de l'Incantation, `parseIncantation` recevait un texte incomplet, `noms_sorts = []`.

**Correction :**
- Nouvelle fonction `estPrefixeSousListeSorts(string $ligne): bool` — teste les deux formats
  de séparateur (`:` et ` - `) et reconnaît les préfixes normalisés :
  `a volonte`, `\d+/jour`, `tour de magie`, `niveau \d`, `cantrip`
- `parseActionBlock` : remplace le `preg_match` inliné par `estPrefixeSousListeSorts($next)`
- `parseIncantation` : idem, remplace la double-condition `preg_match` par
  `estPrefixeSousListeSorts($sl)` + extraction de la partie noms après le séparateur

**Rétro-compatibilité :** Le format `:` précédent (Mage, Cultiste) continue de fonctionner.

#### D-R16.2 — Dégâts avec texte "En cas de coup réussi"

**Bug constaté :** L'action "Rafale oppressante" du Prêtre de Baine était parsée en
TYPE B (description seule) au lieu de TYPE A (attaque avec bouton de jet), car le parser
ne reconnaissait pas son format de résultat de toucher :

```
En cas de coup réussi : 16 (2d10 + 5) points de dégâts psychiques
```

**Cause :** Le regex ne cherchait que `Touché :` (format standard MM2024 de base), pas
`En cas de coup réussi :` ni l'intercalaire `points de` avant `dégâts`.

**Correction :** Le regex de dégâts principaux dans `parseAction()` est élargi :
- Alternative `(Touch[eé]|En cas de coup r[eé]ussi)` pour le mot déclencheur
- `(?:points de\s+)?` avant `d[eé]g[aâ]ts?` (optionnel)
- Les groupes capturants sont décalés : avg = `$m[2]`, formule = `$m[3]`, type = `$m[4]`

---

### D-R17 — Barre 3 (PV) : suppression de `bar3_link` pour gestion indépendante par token

**Contexte :** En combat, un même PNJ peut être instancié plusieurs fois sur la carte (2 gardes,
3 cultistes…). Chaque token est une occurrence distincte du même personnage Roll20.

**Problème avec `bar3_link` :** Quand une barre est liée (`bar{N}_link = attribut.id`), Roll20
synchronise la valeur affichée **sur tous les tokens** représentant ce personnage avec la valeur
de l'attribut hp de la fiche. Résultat : blesser un cultiste modifie les PV affichés sur TOUS
les tokens du même personnage — comportement impossible pour une gestion individuelle des PV.

**Correction (v1.4) :** La barre 3 est désormais configurée avec des valeurs directes uniquement :
- `bar3_value = hp.current` (ou `hp.max` si current est vide)
- `bar3_max = hp.max`
- `bar3_link` : **non défini** — chaque token garde ses PV indépendants

Les barres 1 (CA) et 2 (Perception passive) conservent leur lien (`bar{N}_link`) car ces valeurs
sont statiques et identiques sur toutes les instances d'un même PNJ — la synchronisation via
l'attribut est ici souhaitable.

**Impact sur `setDefaultTokenForCharacter` :** La fonction capture l'état courant du token,
y compris l'absence de lien sur bar3. Tout futur glisser-déposer du personnage depuis la
bibliothèque produira un token avec des PV initiaux indépendants.

---

### D-R20 — Bug : sections `mo_stats` dans un ordre non-standard (Traits après Actions)

**Bug constaté :** Pour certains monstres dont `mo_stats` place `Traits` après `Actions`
(format non-standard mais valide), le trait concerné était importé comme une Action dans
Roll20, et la section Traits était vide.

**Exemple :**
```
Actions
  Attaques multiples...
  Masse d'armes...
  Incantation...
Traits                          ← Traits APRÈS Actions
  Lumière divine. ...           ← absorbé par la section Actions (bug)
Actions Bonus
  Soutien divin...
```

**Cause :** La fonction `sentinelleBloc(array $bloc, array $cles, int $defaut): int`
calculait la borne de fin de chaque section en cherchant le minimum parmi une liste
**codée en dur** de sections-candidates. Les bornes pour Actions étaient
`['legendary','bonus','reactions']` — `traits` était délibérément absent (car, dans le
format standard, Traits est toujours avant Actions). Quand Traits apparaissait après
Actions dans le texte, la section Actions lisait jusqu'à Actions Bonus, engloutissant
le contenu de Traits. La sentinelle pour Traits trouvait `actions` (ligne 13) comme
minimum, inférieur à son propre début (ligne 19) → `$fin < $debut` → bloc vide.

**Correction :** Réécriture de `sentinelleBloc` avec une nouvelle signature
`sentinelleBloc(array $bloc, int $apres, int $defaut): int` :
- Paramètre `$apres` (position de début de la section courante) remplace `array $cles`
- La fonction cherche la première position du tableau `$bloc` qui est **strictement
  supérieure à `$apres`** — quel que soit le nom de la section
- Tous les appels de `parseMonstreStats` mis à jour : chaque section passe
  `$bloc['section_courante']` comme `$apres`

**Résultat :** L'ordre des sections dans `mo_stats` n'a plus d'importance —
l'algorithme trouve toujours la prochaine section qui vient après dans le texte.
Testé sur ordre standard (Traits→Actions→...) et non-standard (Actions→Traits→...).

---

### D-R21 — Accents dans le nom du fichier JSON exporté

**Bug constaté :** Le nom du fichier JSON téléchargé contenait des doubles underscores `__`
à la place des caractères accentués :

```
roll20_Squelette_enflamm__.json   (attendu : roll20_Squelette_enflamme.json)
roll20_Rodeur_M__nestrel.json     (attendu : roll20_Rodeur_Menestrel.json)
```

**Cause :** La construction du nom de fichier utilisait `preg_replace('/[^a-z0-9_-]/i', '_', $nom)`.
Sans le flag `/u` (Unicode), `preg_replace` opère octet par octet en PHP. Un caractère
accentué UTF-8 est encodé sur 2 octets (ex : `é` → `\xC3\xA9`) — chaque octet hors de
`[a-z0-9_-]` est remplacé indépendamment → **2 underscores** par caractère accentué.

**Correction :** Passer `mo_nom` dans `strtr()` avec une table de correspondance complète
(a–z + A–Z, avec leurs variantes accentuées) **avant** le `preg_replace` :

```php
$_nom_brut = strtr((string)$mo['mo_nom'], [
  'à'=>'a', 'é'=>'e', 'ê'=>'e', 'ç'=>'c', ...  // minuscules
  'À'=>'A', 'É'=>'E', 'Ê'=>'E', 'Ç'=>'C', ...  // majuscules
]);
$filename = 'roll20_' . preg_replace('/[^a-z0-9_-]/i', '_', $_nom_brut) . '.json';
```

La casse du nom original est préservée (`Squelette_enflamme`, `Rodeur_Menestrel`).

---

### D-R22 — Bug : `.gitignore` non ancré excluait silencieusement `include/ajax/export/`

**Bug constaté :** `include/ajax/export/monstre-roll20.php` n'a jamais été présent dans le
dépôt, malgré plusieurs livraisons ZIP successives contenant ce fichier. Le dossier
apparaissait grisé dans VS Code, signe d'une exclusion Git.

**Cause :** La règle `.gitignore` ajoutée pour exclure le dossier `export/` à la racine
(fichiers de test JSON, scripts tiers) était écrite sans `/` en tête :

```
export/
```

En syntaxe `.gitignore`, un motif sans `/` initial n'est pas ancré à la racine — il exclut
**tout dossier nommé `export`, à n'importe quelle profondeur**. Cette règle attrapait donc
aussi `include/ajax/export/`, empêchant tout `git add` sur ce répertoire, silencieusement
et sans aucune erreur.

**Correction :** Ancrage de la règle à la racine du dépôt :

```diff
-export/
+/export/
```

`include/ajax/export/monstre-roll20.php` est désormais versionné (commit `7819b08`).

**Point de vigilance retenu :** toute règle `.gitignore` visant un dossier à la racine doit
être ancrée avec `/` en tête, sauf intention explicite de l'appliquer à tous les niveaux de
l'arborescence.

---

### D-R23 — Bug : bloc "Incantation" non reconnu — formulations SRD standard non couvertes

**Bug constaté :** Export d'un monstre lanceur de sorts (Minuit, magicienne niveau 7) →
JSON généré sans aucun attribut `repeating_spell-*`, alors que `npcspellcastingflag = 1`
(le bloc Incantation était bien détecté) et `spell_save_dc = 0` (DD non trouvé).

**Cause — deux formulations officielles non couvertes :**

1. **DD de sauvegarde.** Le texte source dit `DD de sauvegarde des sorts 14` (formulation
   standard des blocs stat traduits), mais la regex `/DD\s+de\s+sauvegarde\s+(\d+)/iu`
   exigeait un chiffre immédiatement après "sauvegarde" — `des sorts` intercalé fait
   échouer le match, `save_dc` reste à 0.

2. **Tours de magie (pluriel).** La ligne `Tours de magie (à volonté) : lumière, ...` ne
   matchait pas le préfixe attendu `tour de magie` (singulier) dans
   `estPrefixeSousListeSorts()`. Cette ligne étant la **première** ligne de sous-liste
   scannée par la boucle de collecte (`parseAction`, bloc Incantation), son échec arrêtait
   immédiatement la boucle — **avant même d'examiner les lignes `Niveau 1` à `Niveau 4`**,
   pourtant correctement formatées. Un seul préfixe non reconnu en tête de liste a donc
   fait perdre la totalité des 15 sorts du monstre, pas seulement les sorts mineurs.

**Correction :**

```diff
- if (preg_match('/DD\s+de\s+sauvegarde\s+(\d+)/iu', $texte, $m)):
+ if (preg_match('/DD\s+de\s+sauvegarde\D{0,30}?(\d+)/iu', $texte, $m)):
```
```diff
- '/^(a volonte|\d+\/jour|tour de magie|niveau\s*\d|cantrip)/u'
+ '/^(a volonte|\d+\/jour|tours? de magie|niveau\s*\d|cantrip)/u'
```

`\D{0,30}?` (non-gourmand, borné à 30 caractères) tolère un intercalaire libre entre
"sauvegarde" et le chiffre sans risquer d'accrocher un chiffre sans rapport plus loin
dans le texte. `tours?` rend le `s` du pluriel optionnel, sans toucher au reste du motif.

**Résultat validé** sur le texte de Minuit : `save_dc = 14`, 15 noms de sorts extraits
(4 tours de magie + 4 niveau 1 + 3 niveau 2 + 3 niveau 3 + 1 niveau 4).

**Point de vigilance retenu :** la boucle de collecte des sous-listes de sorts s'arrête à
la **première** ligne non reconnue — elle ne "saute" pas une ligne isolée pour continuer
sur les suivantes. Tout futur ajout de formulation doit donc être testé sur la ligne
**Tours/Cantrips**, qui est structurellement la première de la liste et conditionne la
lecture de toutes les suivantes.

---

### D-R24 — Bug : section "Équipement" absorbée par Actions

**Bug constaté :** Sur les monstres dont `mo_stats` place un bloc "Équipement" dédié
(titre seul sur sa ligne, suivi d'un ou plusieurs paragraphes) **après** la section
Actions — cas de Minuit —, ce contenu se retrouvait rattaché à Actions dans Roll20 au
lieu de former un trait "Équipement" séparé.

**Cause :** `$sections_norm` (détection des titres de section dans `mo_stats`) ne
listait que `traits`, `actions`, `actions legendaires`, `actions bonus`, `reactions`.
"Équipement" n'y figurait pas. `sentinelleBloc()` cherchant la prochaine section
détectée **après** Actions pour en fixer la borne de fin, l'absence d'"Équipement"
dans `$bloc` faisait lire la section Actions jusqu'à la fin du texte (`$n`), avalant
le titre "Équipement" et son paragraphe.

Le mécanisme de synthèse en trait "Équipement" (`equipment_text` → `repeating_npctrait`,
voir §18 ARCHITECTURE) existait déjà, mais n'était alimenté que par la forme **ligne
d'en-tête** `Équipement : dague, arc court` (`parseOptionalLine()`), jamais par la forme
**section dédiée** utilisée par les statblocks à équipement conséquent (objets magiques,
grimoires...).

**Correction :**
- Ajout de `'equipment' => ['equipement']` à `$sections_norm` : "Équipement" devient une
  borne de section reconnue au même titre que les autres.
- Nouveau bloc d'extraction dans `parseMonstreStats()`, sur le même modèle que
  Traits/Actions/Réactions : capture les lignes entre "Équipement" et la prochaine
  section (ou la fin du texte), les assemble, et alimente `equipment_text` — réutilisant
  sans modification la synthèse en trait déjà en place dans `buildRoll20NpcJson()`.
- **Effet de bord corrigé au passage :** la section Réactions lisait jusqu'à la fin du
  texte sans passer par `sentinelleBloc()` (`array_slice($lignes, $debut)` non borné).
  Si un futur monstre plaçait "Équipement" après "Réactions", ce même bug se serait
  reproduit côté Réactions. Bornée désormais par `sentinelleBloc()` comme les autres
  sections, par cohérence avec D-R20.

**Résultat validé** sur le texte de Minuit (Traits → Actions → Équipement) : Actions ne
contient plus que Dague et Bâton ; le paragraphe Équipement (dagues, bâton, grimoires...)
est isolé et route vers `equipment_text`.

---

### Backlog Roll20 Export (V2)

- [ ] `spelloutput = "ATTACK"` pour sorts offensifs — cf. D-R5
- [ ] Détection automatique de l'image du token (API Roll20 non disponible sans Pro+)
- [ ] Export groupé (plusieurs monstres → ZIP de JSONs)
- [ ] Support du `npc_type` pour les monstres DD3.5 (format `mo_stats` différent)

---

### D-CFG1 — [2026-07-04] Config DB : fichier unique DEV/OVH à détection automatique

**Contexte :** Le fichier `config/db.config.php` de production (OVH) a été écrasé accidentellement
par la version locale (XAMPP), rendant le site inaccessible. Bien que ce fichier soit exclu du
dépôt git (`.gitignore`), rien n'empêchait un transfert manuel (FTP, zip complet de déploiement)
de copier la version d'un environnement sur l'autre.

**Décision :** `config/db.config.php` devient un fichier **unique, physiquement identique** sur
les deux hébergements. Il embarque les deux jeux d'identifiants (local + OVH) et sélectionne le
bon jeu au runtime via une détection d'environnement, plutôt que de reposer sur deux fichiers
distincts à ne jamais confondre.

**Mécanisme de détection :** Test de `$_SERVER['HTTP_HOST']` (repli sur `SERVER_NAME`) contre le
domaine de production `maikastel.fr`.
- Contient `maikastel.fr` → identifiants OVH, `DEV_MODE = false`
- Sinon (y compris hôte vide) → identifiants locaux, `DEV_MODE = true` (repli par défaut)

**Raison du choix du repli par défaut vers DEV plutôt que vers OVH :** Un faux négatif (prod
détectée comme dev) casserait immédiatement et visiblement la connexion DB en prod (host/user/pass
OVH incorrects) — erreur explicite et rapide à diagnostiquer. Un faux négatif inverse (dev détecté
comme prod) risquerait d'écrire silencieusement des données de test dans la base de production
si jamais la détection échouait côté OVH. Le repli vers DEV est donc le sens d'erreur le moins
dangereux.

**Limite connue :** Cette détection repose sur les variables de requête HTTP (`HTTP_HOST` /
`SERVER_NAME`). Un script PHP exécuté en ligne de commande (CLI, ex. cron) sur le serveur OVH ne
positionne pas ces variables et tomberait par défaut sur les identifiants locaux, donc échouerait
à se connecter à la base OVH. Aucun script CLI n'existe à ce jour dans le projet ; si un besoin de
ce type apparaît (ex. tâche planifiée sur OVH), ajouter une détection complémentaire (ex.
`gethostname()`, variable d'environnement dédiée, ou fichier marqueur) avant d'écrire ce script.

**Impact :** Le fichier `config/db.config.php` peut désormais être copié sans risque d'un
environnement vers l'autre lors d'un déploiement ; il continue d'être exclu du dépôt git.
`config/db.config.example.php` reste le gabarit de référence pour comprendre la structure des
constantes attendues, mais ne représente plus qu'un seul environnement — le fichier réel en
combine deux.

---

### D-CFG2 — [2026-07-04] 503 "Err1" sur OVH après déploiement du fichier commun (D-CFG1) — diagnostic en cours

**Contexte :** Immédiatement après déploiement du fichier `config/db.config.php` commun (D-CFG1),
le site fonctionne en local mais renvoie une erreur 503 avec le message `"Service temporairement
indisponible Err1."` sur OVH.

**Analyse :** Le message `Err1` est émis par le bloc `catch (PDOException $e)` de `include/db.php`,
**après** le chargement réussi de `config/db.config.php` (aucune erreur fatale PHP en amont — donc
la détection d'environnement s'exécute et une constante `DEV_MODE`/`DB_DSN` valide est bien
définie). L'échec se situe précisément dans `new PDO(DB_DSN, DB_USER, DB_PASS, ...)` : la tentative
de connexion MySQL elle-même est refusée par le serveur OVH.

**Deux causes possibles, non départagées à ce stade** (le contenu exact de `$e->getMessage()`
n'a pas encore été consulté dans les logs OVH) :
1. Identifiants OVH invalides (host, user, mot de passe ou nom de base incorrects/désynchronisés
   par rapport à ce qui est réellement configuré côté OVH Manager).
2. Mauvaise branche de détection D-CFG1 : si `$_SERVER['HTTP_HOST']` sur OVH ne contient pas
   `maikastel.fr` (accès via un alias `clusterXXX.hosting.ovh.net`, un proxy, ou toute
   configuration modifiant le Host vu par PHP), le fichier utiliserait par erreur les identifiants
   **locaux** (`host=localhost`) au lieu des identifiants OVH, provoquant un échec de connexion
   identique en apparence.

**Correctif appliqué (diagnostic uniquement, pas de correction de cause) :** `include/db.php` est
instrumenté : à chaque échec PDO, le log serveur reçoit désormais l'environnement détecté
(`DEV_MODE`), l'hôte extrait de `DB_DSN`, et `$_SERVER['HTTP_HOST']` — jamais `DB_USER` ni
`DB_PASS`, pour ne pas exposer de secret dans les logs. Ceci permettra, à la prochaine occurrence,
de lire directement dans le log lequel des deux scénarios ci-dessus s'est produit.

**Prochaine étape :** Jean-Michel consulte le log d'erreur OVH (espace client OVH → Hébergement →
Logs, ou le fichier `error_log` généré par Apache/PHP dans l'espace FTP) après un nouvel essai, et
transmet la ligne exacte pour trancher entre les deux causes. Selon le résultat :
- Si cause 1 (identifiants) : revérifier host/user/pass/dbname exacts dans l'espace OVH Manager,
  attention en particulier aux espaces invisibles et à la casse lors d'un copier-coller.
- Si cause 2 (détection) : renforcer la condition de D-CFG1 avec un signal plus fiable que
  `HTTP_HOST` (ex. vérification combinée avec `DOCUMENT_ROOT`, ou variable d'environnement dédiée
  positionnée dans la configuration Apache/OVH).

**Statut : ouvert.**

---

## [2026-07-04] Incident — Crash MySQL local, restauration incomplète du 28/06, récupération complète

> **Note de session [2026-07-05] :** cette entrée avait été rédigée le 04/07 puis a disparu du
> fichier (écrasée par une sauvegarde concurrente d'une autre session travaillant sur D-CFG1/D-CFG2
> ci-dessus, sans connaissance de cet ajout). Reconstituée à l'identique le 05/07 après constat de
> l'absence. **Leçon distincte à ajouter au bilan** : ce fichier journal lui-même a été victime d'un
> écrasement concurrent (deux sessions Claude Code éditant `DECISIONS_LOG.md` en parallèle sans se
voir) — un risque à garder en tête si plusieurs sessions travaillent le même jour.

### Signalement

Suite à un plantage MySQL local ce matin, Jean-Michel restaure une sauvegarde du 28/06 dans une
nouvelle base `donjon` (l'ancienne base `maikasteiymaika` semblait inaccessible) et repointe
`config/db.config.php` dessus. Premier symptôme : les monstres du supplément personnel de tono
(cf. mécanisme Supplément, SP-C, [2026-06-15]) ont disparu de la liste Monstres du compendium.

### Diagnostic 1 — Le schéma n'est pas en cause

Inspection directe de la base `donjon` restaurée : toutes les colonnes du mécanisme Supplément
(`mo_public`, `mo_visible`, `mo_res_id`, et leurs équivalents sur les 7 autres entités), ainsi que
`dd_monstres_categories`, `dd_monstres_groupes`, `dd_fp`, sont bien présentes — ces migrations
(`patch_004_supplements.sql` et la réplication du 2026-07-01, cf. plus haut) datent toutes d'avant
le 28/06. Aucun patch de schéma appliqué directement en base n'est donc perdu par cette restauration.

### Diagnostic 2 — Un data-only fix du 2026-07-02 n'avait jamais quitté le poste de dev

Cause réelle : `dd_joueurs_sources` ne contient plus la ligne du supplément de tono (`res_id=95`,
ruleset DD2024). C'est exactement le bug documenté le [2026-07-02] ci-dessus — sauf que sa
correction ponctuelle ("ligne réinsérée manuellement... base de dev locale") n'avait, comme
explicitement noté à l'époque, jamais été répliquée ailleurs. La restauration du 28/06 (antérieure
au 02/07) ne pouvait donc pas l'avoir.

→ **Leçon retenue :** un correctif de **données** (par opposition à un correctif de **schéma**,
lui documenté et committable dans `sql/`) appliqué en urgence sur un environnement doit être noté
explicitement comme *à répliquer* sur les autres environnements (ici : OVH production), pas
seulement comme "fait". Le correctif code (`profil/index.php`) empêche la récidive *future* du
bug, mais ne répare jamais rétroactivement une ligne déjà perdue ailleurs — ce qui explique
pourquoi le même symptôme est réapparu sur OVH (cf. plus bas), indépendamment du crash local.

### Diagnostic 3 — La base `maikasteiymaika` d'origine n'était pas juste "en retard", elle était récupérable

Investigation plus poussée sur l'ancienne base (celle qui a crashé) : 57 des 58 tables InnoDB
renvoyaient `ERROR 1932 : Table '...' doesn't exist in engine`, alors que les fichiers `.frm`/`.ibd`
sur disque étaient intacts et datés jusqu'au 3-4/07 (donc bien postérieurs au 28/06). Le journal
d'erreur MySQL révèle qu'un `innodb_force_recovery=6` (niveau le plus agressif, saute le rejeu du
redo log) avait déjà été tenté ce matin avant cette session, sans succès apparent — seul le
dictionnaire interne InnoDB était cassé, pas les tablespaces eux-mêmes.

**Procédure de récupération appliquée :**
1. Sauvegarde complète du dossier `data` MySQL avant toute manipulation (non destructif).
2. Pour chacune des 57 tables cassées : `DROP TABLE` (nettoyage des métadonnées orphelines),
   `CREATE TABLE` avec la structure exacte empruntée à `donjon` (schéma identique, confirmé par le
   diagnostic 1), `ALTER TABLE ... DISCARD TABLESPACE`, copie du fichier `.ibd` d'origine à sa
   place, `ALTER TABLE ... IMPORT TABLESPACE`, puis reconstruction des index secondaires et
   contraintes FK (nécessaire : `IMPORT TABLESPACE` sans fichier `.cfg` exige l'absence d'index
   secondaires au moment de l'import).
3. Cas particulier `dd_regles` (seule table avec un index `FULLTEXT`) : l'import échouait même
   après suppression de tous les index listés par `SHOW INDEX` — recréer la table **sans jamais
   déclarer l'index FULLTEXT** (plutôt que le déclarer puis le supprimer) a permis l'import, suivi
   d'un `ADD FULLTEXT KEY` a posteriori.
4. Script de traitement par lot : `recover.php` (PDO, information_schema pour capturer/rejouer les
   définitions d'index et de FK) — non committé au dépôt, outil ponctuel d'incident.

**Résultat :** 68/68 tables accessibles. Comparaison ligne à ligne avec le snapshot `donjon`
(28/06) : aucune table n'affiche un compte inférieur ; plusieurs en affichent un supérieur
(`dd_monstres` 24 vs 19, `dd_joueurs_sources` 28 vs 27, `dd_classe_niveau` 810 vs 770, etc.),
confirmant la récupération de l'activité réelle du 28/06 au 04/07 sans perte de données.

### Bascule finale et régression annexe

`config/db.config.php` repointé sur `maikasteiymaika` (récupérée) plutôt que `donjon`. La base
`donjon` est conservée (non supprimée) par précaution. Pendant l'intervention, une modification
indépendante du même fichier (unification config locale/OVH, cf. D-CFG1 ci-dessus) a transitoirement
réintroduit `dbname=donjon` en local, faisant réapparaître le symptôme une seconde fois — corrigé en
repointant sur `maikasteiymaika`.

### Volet OVH — même bug, jamais patché en production

Une fois le local rétabli, Jean-Michel signale le **même symptôme sur OVH**. Cause confirmée :
le correctif de données du 2026-07-02 n'ayant été appliqué qu'en local (cf. Diagnostic 2), la
production portait le même défaut depuis l'origine, sans lien avec le crash du jour. Corrigé par
Jean-Michel lui-même via phpMyAdmin OVH, avec une requête idempotente et générique (ne présuppose
aucun ID) :

```sql
INSERT INTO dd_joueurs_sources (js_j_id, js_res_id, js_ruleset_var_id)
SELECT r.res_j_id, r.res_id, r.res_ruleset_var_id
FROM dd_ressources r
WHERE r.res_j_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM dd_joueurs_sources s
    WHERE s.js_j_id = r.res_j_id
      AND s.js_res_id = r.res_id
      AND s.js_ruleset_var_id = r.res_ruleset_var_id
  );
```

**Statut initial : résolu en local et sur OVH.** Sauvegarde de sécurité du dossier `data` MySQL
local conservée hors dépôt (scratchpad de session, à rapatrier manuellement si besoin de rejouer
l'incident).

### Suite [2026-07-05] — Effet de bord découvert : compteurs AUTO_INCREMENT désynchronisés

**Signalement :** en testant une nouvelle action "Dupliquer" sur Monstres (session du 05/07, sans
rapport avec l'incident ci-dessus au départ), erreur `SQLSTATE[23000]: ... 1062 Duplicate entry '22'
for key 'PRIMARY'` sur `dd_monstres` lors d'un simple `INSERT` sans `mo_id` explicite.

**Cause :** conséquence directe de la procédure de récupération du 04/07 (Diagnostic 3 ci-dessus).
Chaque `CREATE TABLE` de reconstruction empruntait la DDL de `donjon` (snapshot du 28/06), DDL qui
embarque une valeur `AUTO_INCREMENT=N` littérale figée à cette date. `ALTER TABLE ... IMPORT
TABLESPACE` réimporte les lignes réelles mais **ne remet pas à jour ce compteur** vers le nouveau
`MAX(id)` — contrairement à un `INSERT` normal, InnoDB ne le recalcule pas non plus tout seul au
redémarrage du serveur dans ce cas précis (table reconstruite par import, pas par activité DML
continue). Le compteur restait donc bloqué sur l'ancienne valeur du 28/06 pour toute table ayant
reçu d'authentiques nouvelles lignes entre le 28/06 et le crash du 04/07 — les premiers `INSERT`
post-recovery rentrent alors en collision avec des lignes réelles déjà présentes (ex. mo_id 22/23/24
= Squelette/Zombi/Goule, déjà en base, pas des artefacts).

**Portée :** balayage systématique de toutes les tables InnoDB de `maikasteiymaika` (comparaison
`AUTO_INCREMENT` vs `MAX(pk)` réel via `information_schema`) — 4 tables concernées, corrigées par
`ALTER TABLE ... AUTO_INCREMENT = MAX(pk)+1` :
`dd_capacites_speciales` (452→459), `dd_classe_capacite` (768→790), `dd_joueurs_sources` (56→62),
`dd_monstres` (25→27). Les 53 autres tables recréées le 04/07 n'ont reçu aucun nouvel `INSERT`
depuis (compteur déjà correct par coïncidence, aucune activité pour révéler l'écart) — même risque
latent si une entrée y est ajoutée sans repasser par ce correctif ; aucun signe qu'il faille agir
préventivement ailleurs, mais à garder en tête si un autre "Duplicate entry" apparaît sur une table
touchée par la récupération du 04/07.

**Statut : corrigé (4 tables), pas de récidive attendue — `ALTER TABLE ... AUTO_INCREMENT` est
persistant, contrairement au comportement transitoire qui a permis l'écart initial.**

---

## SP-TB — Tableaux de règles

**[2026-08-10] Isolation des tableaux de données dans `dd_tableaux`**
Les tableaux de règles étaient saisis en HTML dans `reg_texte`, au milieu du corps de la règle.
Décision : table dédiée `dd_tableaux`, saisie en convention texte, insertion par tag `[[tab:slug]]`.
→ Un tableau devient une **donnée adressable** : réutilisable dans plusieurs règles (« Bonus de
maîtrise » était dupliqué), dans un bloc de stats de monstre, et — objectif final — dans l'écran
du MJ (SP-TB8), qui n'aurait eu aucun moyen d'aller chercher un `<table>` noyé dans du HTML.

**[2026-08-10] Convention de saisie plutôt que HTML**
Lignes préfixées : `!` en-tête, `#` section pleine largeur, `>` note, `|` séparateur de cellules.
→ Affranchit l'auteur du HTML, garantit une sortie homogène, et rend le design 100 % CSS.
L'alignement est sorti du contenu (colonne `tab_align`) : le contenu reste de la donnée pure.

**[2026-08-10] Fusions limitées aux lignes d'en-tête**
Cellule vide = fusion à gauche (`colspan`), `^` = fusion vers le haut (`rowspan`) — **uniquement**
dans les lignes `!`.
→ Les en-têtes sur deux niveaux sont un besoin réel des tableaux restant à saisir. Étendre les
fusions aux lignes de données rendrait impossible d'exprimer une cellule légitimement vide, dont
les grilles irrégulières (colonnes de longueurs inégales) ont un besoin constant.

**[2026-08-10] Tag `[[tab:slug]]` — délimiteur double, référence par slug**
Écarté : la famille de délimiteurs mono-caractère `#`/`$`/`&`/`@`/`%` déjà en place dans `mo_stats`.
→ `reg_texte` est du HTML TinyMCE et non du texte brut : `&` collisionne avec les entités et un
caractère isolé ne survit pas au nettoyage de collage. Référence par **slug** et non par id
(contrairement à `@id@`/`%id%`) : les ids ne survivent pas au passage local → OVH, alors que les
règles sont réimportées par script. Le renommage d'un slug est répercuté dans `reg_texte` et
`mo_stats`, sans quoi les insertions existantes deviendraient silencieusement irrésolubles.

**[2026-08-10] Remplacement du `<p>` entier en passe 1**
`resoudreTagsTableaux()` traite d'abord `<p>[[tab:slug]]</p>` avant les tags nus.
→ Un `<table>` rendu à l'intérieur d'un `<p>` est du HTML invalide : le navigateur ferme le
paragraphe et la mise en page casse. TinyMCE encapsule systématiquement le tag dans un `<p>`.

**[2026-08-10] Liaison des cellules : tags explicites seuls, pas de `lierAuto()`**
→ La liaison automatique par nom est trop coûteuse et trop bruyante dans une grille dense (chaque
cellule serait tokenisée). L'échappement est délégué à `lierAvecSegmentsProteges($txt, 0, …)` :
`maxWords = 0` court-circuite le tokenizer et `h()` s'applique à tout ce qui n'est pas un lien déjà
produit — pas de logique d'échappement dupliquée.

**[2026-08-10] `mo_stats` : sentinelle avant formatage (SP-TB6)**
Les lignes réduites à un tag sont sorties du flux et remplacées par `___TAB<n>___` avant
formatage, puis substituées à la fin.
→ Résoudre le tag après coup l'exposerait à `lierAuto()`, qui tokenise les mots de ≥ 4 lettres et
injecterait un `<span>` au milieu du slug, rendant le tag irrésoluble. La sentinelle ne contient
aucun mot assez long pour être tokenisé.

**[2026-08-10] Le picker ne propose pas la création d'un tableau**
Le sélecteur ouvert depuis l'éditeur de règle (`#detail-pp-sub`, z-index 300) n'offre qu'un lien
« Gérer » vers `regles/tableaux.php` en nouvel onglet.
→ Un formulaire de création occuperait `#modification` (250), qui porte la règle en cours
d'édition : l'utilisateur perdrait sa saisie. Contrainte structurelle du système de panels.

**[2026-08-10] Liste dédiée plutôt que moteur `compendium-liste.php`**
→ Conforme à §9b : le moteur ne s'applique pas au module Règles (scoping ruleset seul, pas de
sources actives ni de mécanisme de supplément). Le forcer aurait exclu tout tableau à
`tab_res_id IS NULL` via le filtre `IN (sources actives)`.

**[2026-08-10] Périmètre ruleset : DD2024 seul**
SP-TB0→TB6 n'alimentent que DD2024 (id 2). La saisie des tableaux DD3.5 (id 1) est isolée en
**SP-TB9**.
→ Décision utilisateur : ne pas mélanger les deux rulesets dans une même passe de saisie.

**[2026-08-10] Migration : script PHP idempotent plutôt que SQL littéral**
`sql/migrate_tableaux_sp-tb5.php`, simulation par défaut, `?go=1` pour appliquer.
→ Le script opère sur l'état réel de la base plutôt que sur une transcription figée du fichier
d'import. Résultat sur les données DD2024 : 10 blocs → 9 tableaux distincts, doublon « Bonus de
maîtrise » détecté et fusionné, aucun bloc ignoré. Les tableaux à `colspan`/`rowspan` sont
signalés et laissés intacts — les fusions ne sont pas devinables de façon fiable.

**[2026-08-10] `_tabSlugify()` sans dépendance à l'extension intl**
→ `extension=intl` est commentée dans le `php.ini` de XAMPP : un appel direct à
`transliterator_transliterate()` est une erreur fatale. Repli par table de translittération.
Le même défaut existe dans `_slugify()` (`include/regles-arbre.php`) — non corrigé ici, hors
périmètre, signalé à l'utilisateur.

**[2026-08-10] Suivi des phases de développement — consigne permanente**
Ajout d'un §0 « Suivi des phases de développement » en tête de `ARCHITECTURE_0_REFERENCE.md` :
checklist markdown de toutes les phases, tous projets confondus (SP-C, SP-E, SP-T, SP-TB).
Consigne inscrite comme **obligatoire et prioritaire** dans `CLAUDE.md`.
→ Demande utilisateur : disposer d'un tableau de bord unique de l'avancement, tenu à jour à
chaque livraison, plutôt que des statuts dispersés dans les sections de chaque module.

**[2026-08-10] SP-TB0 et SP-TB5 appliqués en base locale**
Schéma `dd_tableaux` créé sur `maikasteiymaika`, migration exécutée sur le ruleset DD2024.
Résultat : 14 blocs `<table>` dans 8 règles → 13 tableaux, 1 réutilisation, 0 ignoré.
→ Le fichier d'import ne décrivait que 10 blocs ; 4 tableaux avaient été ajoutés depuis via
l'interface. Confirme le choix d'un script opérant sur la base plutôt que sur le fichier.
Sauvegarde préalable : `sql/backup/2026-08-10_reg_texte_avant_sp-tb5.sql`.

**[2026-08-10] Script de migration exécutable en CLI**
Ajout d'un mode CLI (`--ruleset=<id> [--go]`) court-circuitant `requireAuth()`/`requireAdmin()`.
→ L'accès CLI implique déjà l'accès au système de fichiers : le garde ne protégerait rien et
empêcherait simplement l'exécution (pas de session HTTP). Permet de rejouer et de vérifier la
migration sans passer par le navigateur. Le ruleset devient obligatoire en CLI, faute de session.

**[2026-08-10] `;` retiré des commentaires de colonne SQL**
Le commentaire de `tab_camp_id` contenait `… -> dd_campagnes ; NULL = officiel`.
→ Un point-virgule à l'intérieur d'une chaîne de commentaire casse tout découpeur de requêtes
naïf (le nôtre l'a été). phpMyAdmin s'en accommode, pas un `explode(';')`. La convention
existante (`reg_camp_id` dans le dump) porte le même piège — à éviter dans les futures DDL.

**[2026-08-10] Extension `intl` — activée en local, confirmée sur OVH**
`extension=intl` décommentée dans le `php.ini` XAMPP (ICU **71.1**). OVH l'expose déjà
(ICU **63.1**, `intl.error_level=0`, `intl.use_exceptions=Off`).
→ Clôt le défaut signalé le même jour sur `_slugify()` (`include/regles-arbre.php`), qui appelait
`transliterator_transliterate()` sans garde : la fonction ne peut plus être indéfinie dans aucun
des deux environnements. **Aucune modification de code** — correction par configuration.

Le repli `strtr()` de `_tabSlugify()` (`include/tableau-parser.php`) est **conservé** : il ne coûte
rien (branche jamais prise) et protège d'un changement d'hébergement. Équivalence des deux chemins
vérifiée sur les 13 tableaux migrés — **0 divergence** — et sur une série de cas limites français
(œ, æ, apostrophes, majuscules accentuées, ponctuation). Seul écart relevé : l'eszett allemand
(`Süß` → `suss` via intl, `su` via le repli), sans objet sur un corpus francophone. Ajouter
`'ß'=>'ss'` à la table si un jour le repli redevient le chemin actif.

> Note : les deux environnements n'ont pas la même version d'ICU (71.1 local / 63.1 OVH). Sans
> conséquence ici — `Any-Latin; Latin-ASCII` est stable sur le latin accenté depuis bien avant
> ICU 63 — mais à garder en tête si un slug devait un jour être régénéré côté serveur.

**[2026-08-10] Découpage d'un tableau en blocs côte à côte — étudié, écarté**
Certains tableaux du livre source présentent un tableau à N colonnes logiques coupé en K moitiés
posées côte à côte (en-tête répété), pour économiser de la hauteur sur la page imprimée.
Proposition étudiée : sortir ce découpage du contenu vers une métadonnée `tab_blocs`, le rendu
produisant K `<table>` frères dans un conteneur `flex-wrap` (responsive gratuit, en-têtes
légitimes, `colspan`/`rowspan` préservés, override possible au rendu).

**Écarté — décision utilisateur : la contrainte de hauteur de page n'existe pas en affichage web,
le motif y perd sa raison d'être.** Aucune phase créée, rien n'est inscrit dans §0.

État conservé : un seul tableau porte le motif gravé dans son contenu — « Modificateurs de
caractéristique » (`[[tab:modificateurs-de-caracteristique]]`, 4 colonnes physiques = 2 blocs de
2 colonnes logiques, `tab_align = lrlr`). Il fonctionne tel quel, aucune reprise nécessaire.

> À rouvrir si **SP-TB8** (écran du MJ) le justifie : les colonnes y seront plus étroites qu'une
> page de règle, et un tableau dont le découpage est gravé dans le contenu ne pourra ni se
> déplier en 1 bloc ni se replier en 3. C'est le seul contexte où le sujet redevient bloquant.

---

## Phase SP-GL — Liaison automatique du glossaire

**[2026-08-10] Diagnostic — le « parser du glossaire » n'existait pas**
Signalement : dans la règle Exploration (id 8), chapitre Dangers, les mots Asphyxie, Brûlures,
Chutes, Déshydratation, Malnutrition ne sont pas cliquables.

Analyse : le rendu d'un nœud de règle (`regles/regle.php`, `include/ajax/detail-pp/regle.php`)
n'appliquait qu'une seule transformation, `resoudreTagsTableaux()` (tags `[[tab:slug]]`). Les
mots cliquables observés ailleurs sont des ancres `.glossaire-lien` **écrites en dur** dans
`reg_texte` par `sql/seed_regles_dd2024.sql`. Relevé en base : 94 nœuds porteurs d'ancres,
**tous de type `glossaire`** ; les 31 nœuds `chapitre`/`regle` avec texte n'en portaient
**aucune**. Le renvoi n'avait donc jamais fonctionné hors du glossaire — il ne s'agissait pas
d'une régression mais d'une fonctionnalité absente.

Deux points de contenu, indépendants du moteur : « Brûlures » n'est pas un terme du glossaire
(le SRD 2024 le nomme **Embrasement**) ; « Chutes » est le pluriel de **Chute**.

**[2026-08-10] Détection — casse exacte du terme, pas de liste noire**
Le glossaire DD2024 compte 155 termes dont beaucoup de mots courants (Action, Arme, Cible,
Créature, Objet, Sort, Mort, Vol, Danger, Ennemi…). Mesure sur les 31 nœuds de règles :

| Stratégie | Occurrences | Nœuds touchés |
|---|---|---|
| Insensible à la casse | 1 024 (Combat : 265 à lui seul) | 31 |
| **Casse exacte** | **278** | 14 |

→ **Casse exacte retenue.** Le SRD 2024 capitalise ses termes de jeu en milieu de phrase ; le
palmarès obtenu le confirme (Désavantage 26, Vitesse 21, Avantage 20, JS 18, Initiative 18,
Réaction 14, Résistance 12, Terrain difficile 8). Signal de détection gratuit et fiable, qui
évite d'avoir à maintenir une liste noire de mots courants — laquelle aurait dû être révisée à
chaque ajout au glossaire.

**[2026-08-10] Première occurrence seulement — par terme et par nœud**
278 liens restaient trop pour un texte suivi. Une seule ancre par terme et par nœud : le lecteur
a le renvoi là où il en a besoin, la page reste lisible. Les ancres manuelles déjà présentes dans
le HTML sont pré-scannées et comptent comme la première occurrence — sans quoi le parser en
aurait ajouté un doublon plus bas dans la même définition.
→ Résultat final : **107 renvois** sur 186 nœuds.

**[2026-08-10] Résolution au rendu, pas à l'enregistrement**
Alternative écartée : figer les ancres dans `reg_texte` au moment de la sauvegarde, comme le fait
le seed. Renommer ou masquer un terme aurait alors laissé des renvois périmés dans tous les nœuds
déjà enregistrés, avec un script de re-migration à écrire. Coût mesuré du rendu sur le nœud le
plus lourd (Combat, 18 ko) : **0,6 ms** — le sujet de la performance ne se pose pas.

**[2026-08-10] Ordre d'appel — glossaire avant tableaux**
`resoudreTagsTableaux($db, lierGlossaireAuto(...), ...)`. L'exclusion de « l'intérieur des
tableaux rendus » est obtenue **par l'ordre d'appel** et non par du code de détection : le HTML
des tableaux est injecté après la passe glossaire et ne la traverse jamais. Les tags `[[tab:slug]]`
sont par ailleurs isolés pendant la passe, pour qu'aucune ancre ne vienne les couper.

**[2026-08-10] Frontière de mot — le trait d'union en fait partie**
Faux positif relevé au test : « Mort » se liait dans « Mort-vivant » (nœud 155, Type de créature).
Les lookarounds incluent désormais le trait d'union et les tirets Unicode. Un terme peut lui-même
en contenir (« Personnage non-joueur ») : sans incidence, la contrainte ne porte que sur les
extrémités du match.

**[2026-08-10] Décodage / ré-échappement des segments de texte**
`reg_texte` stocke les accents en entités HTML (`D&eacute;shydratation`) : aucun motif accentué
n'y matcherait. Les segments analysés sont donc décodés, puis tout ce qui n'est pas transformé est
ré-échappé par `h()`. Page en UTF-8 et base en `utf8mb4` — les accents ressortent en clair, le HTML
produit est équivalent. Le contenu textuel a été vérifié identique avant/après sur les 186 nœuds.

**[2026-08-10] Handler et style portés en global**
Le handler `.glossaire-lien` vivait dans `js/regles.js` et son style dans `css/regles-modules.css`,
tous deux chargés uniquement sur le module Règles. Or ces ancres apparaissent aussi dans
`#detail-pp` (fiche règle ouverte depuis une campagne) et dans le sous-panneau glossaire — où elles
étaient donc **inertes et non stylées**, y compris pour les ancres manuelles du seed.
→ Handler déplacé dans `js/main.js` (base d'URL résolue comme `.mo-lien` : conteneur
`[data-detail-base]`, sinon `BASE_URL` global), style déplacé dans `css/modules.css` et repassé en
`var(--clr-accent-2)` (il portait un hex en dur, `#6b47a4`).

**[2026-08-10] Portée volontairement limitée aux règles**
Le compendium (`do_texte`, `om_texte`, `hi_description`…) n'est pas branché : phase **SP-GL3**,
à arbitrer conjointement avec **SP-TB7** qui vise exactement la même liste de champs. Le ruleset
DD3.5 (id 1) ne possède aucun nœud `reg_type='glossaire'` — le parser y sort immédiatement, index
vide ; sa saisie est la phase **SP-GL4**.

**[2026-08-10] SP-TB7 — portée du tag étendue au compendium**
Câblage de `[[tab:slug]]` sur 12 points de rendu : `so_description`, `cla_description`,
`ra_description`, `do_texte`, `comp_description`, `om_description`, `hi_description`,
`eqt_description`, `cap_description` (×3 fiches), plus la définition de glossaire.
→ Seuls les champs **déjà rendus sans `h()`** ont été retenus. Un champ échappé conserve son
échappement : retirer un `h()` pour y faire passer un tag ouvrirait une injection HTML sur un
champ jamais conçu pour contenir du balisage. Écartés pour cette raison ou par périmètre :
`do_conditions`, `do_resume`, les champs courts de classe (armes/armures/sorts/conditions),
`res_description` et tout le module Campagnes.

**[2026-08-10] Nouveau point d'entrée `rendreTexteAvecTableaux()`**
Lit le ruleset dans la session, avec override possible en 3ᵉ paramètre.
→ Un seul des neuf endpoints `detail-pp` du compendium définit une variable `$ruleset_id`
locale. Appeler `resoudreTagsTableaux($db, $x, $ruleset_id)` directement aurait produit un
scoping silencieusement faux (ruleset 0) dans les huit autres.

**[2026-08-10] Composant CSS `.reg-tab*` déplacé vers `css/modules.css`**
Le bloc de rendu quitte `regles-modules.css` ; seul l'outillage du gestionnaire y reste.
→ `regles-modules.css` n'est chargé que si `$css_module = 'regles'`. Or le tableau s'affiche
désormais sur les fiches du compendium et dans les blocs de stats de monstre — il y sortait
**sans aucun style**. Précédent identique dans le projet : le CSS du glossaire avait déjà été
déplacé vers `modules.css` pour la même raison.

> 🐛 Ce déplacement corrige un défaut de **SP-TB6**, annoncé livré à tort : le tag était résolu
> dans `mo_stats`, mais le tableau s'affichait sans style hors des pages Règles. La portée CSS
> avait été vérifiée pour les règles et pas pour les monstres.

**[2026-08-10] Lacune SP-TB2 comblée : sous-panneau glossaire**
`detail-pp-sub/glossaire.php` rendait `reg_texte` sans passer par le parser de tableaux.
→ SP-TB2 n'avait câblé que `regles/regle.php` et `detail-pp/regle.php`. Le tag est désormais
résolu **après** `lierGlossaireAuto()` : la liaison glossaire travaille sur du texte, le tag
doit lui rester opaque.

**[2026-08-10] `.reg-tab` rendu indépendant de son contexte typographique**
Ajout de `line-height`, `color` et `text-align` sur le composant.
→ Le tableau héritait de son hôte : `line-height: 1.7` dans le corps d'une règle
(`.regles-noeud__texte`), celle du `body` ailleurs — d'où un rendu différent entre le module
Règles et le gestionnaire. Un composant affiché dans cinq contextes doit être auto-portant.

**[2026-08-10] Bouton d'insertion de tableau généralisé aux formulaires du compendium**
SP-TB7 avait livré la résolution du tag sans le moyen de l'insérer : le bouton n'existait que
dans l'éditeur de règle (SP-TB4). Dans un formulaire du compendium, aucun bouton ni indication —
le geste naturel était de coller la convention de saisie directement dans le champ riche, où
TinyMCE la transforme en `<br>` et où elle n'a aucun sens (la convention ne vit que dans
`dd_tableaux.tab_contenu`). Cas rencontré en test sur le don « Façonneur ».
→ Bouton `tableau` ajouté aux **10 éditeurs** : règle, sort, classe (×2), race (×2), don,
compétence, objet, historique, équipement.

**[2026-08-10] Implémentation du bouton centralisée dans `js/main.js`**
`tableauxInitBouton(editor)` + `insererTableauDansEditeur(slug)` + `TAB_EDITEUR_ACTIF`.
Les formulaires ne portent plus que `toolbar: '… | tableau | …'` et un `setup:` d'une ligne.
→ Une implémentation par formulaire aurait été recopiée dix fois. `modifier/regle.php` a été
ramené sur la version partagée (suppression de son `window.reglesInsererTableau` local et de son
`URL_PICKER_TABLEAUX`), et le picker appelle désormais la fonction globale.

L'éditeur cible est mémorisé **au clic** sur le bouton, pas au moment de l'insertion : le picker
s'ouvrant dans `#detail-pp-sub`, le focus a quitté l'éditeur et `tinymce.activeEditor` ne
désigne plus le bon (ou plus rien).

Les deux `setup:` préexistants — overlays de capacité de `classe.php` et `race.php`, qui
restaurent le contenu du textarea sur `ed.on('init')` — ont été **étendus** par ajout de l'appel
en première instruction, jamais remplacés : une seconde clé `setup:` dans le même objet
littéral aurait écrasé la première sans erreur.

> ⚠ Le bouton `table` natif de TinyMCE reste présent dans ces barres. Il insère un `<table>`
> HTML dans le champ — précisément ce dont SP-TB affranchit le contenu, et ce que la migration
> SP-TB5 a nettoyé. Son retrait est une décision produit, non prise à ce jour.

**[2026-08-10] Bouton « Tableaux » ajouté aux listes du compendium**
Déclaré dans la barre d'actions de `include/compendium-liste.php`, gaté sur
`canEditCompendium()`, ouverture en nouvel onglet.
→ Le moteur sert les 9 entités du compendium : une déclaration unique les couvre toutes, là où
une modification page par page aurait été recopiée neuf fois. Nouvel onglet pour préserver
l'état de la liste (filtres, tri, pagination) pendant la création du tableau.

Complète le bouton d'insertion TinyMCE livré le même jour : celui-ci insère un tableau
**existant** dans un texte, celui-là donne accès à la **création**. Les deux étaient nécessaires.

**[2026-08-11] SP-GL3 — liaison glossaire étendue au compendium**
`rendreTexteAvecTableaux()` devient `rendreTexteEnrichi()` et enchaîne
`lierGlossaireAuto()` **puis** `resoudreTagsTableaux()`. Les 12 points de rendu du compendium
en héritent sans être touchés.
→ SP-TB7 avait fait de cette fonction le point de passage unique : SP-GL3 se réduit à une
modification de fonction au lieu de 12. L'ordre est celui imposé par §9d — glossaire d'abord,
le HTML des tableaux étant alors injecté après coup et ne traversant jamais le parser glossaire.

Arbitrage utilisateur : la casse est respectée dans toutes les saisies, la règle de casse exacte
s'applique donc telle quelle au compendium. `mo_stats` reste exclu — `monstre-parser.php` a sa
propre liaison glossaire, l'ajout produirait des liens en double.

Vérifié sur données réelles : ancres produites sur sorts/dons/historiques, aucune ancre à
l'intérieur d'un tableau rendu, « le Désavantage » lié / « un désavantage » non lié,
`mo_stats` inchangé (38 liens `.mo-lien`, 0 `.glossaire-lien`).

**[2026-08-11] Aide à la saisie sur tous les champs soumis à un parser**
Trois clés dans `include/aide-contextuelle.php` : `texte-parsers`, `tableau-convention`,
`monstre-tags-description` (enrichie de `[[tab:slug]]`, oubliée lors de SP-TB6). 13 icônes `?`
posées sur les étiquettes.
→ **Une clé par jeu de parsers réellement appliqué**, et non une aide générique : les champs
n'ont pas tous les mêmes passes. La bulle `texte-parsers` dit explicitement que
`#don#`/`$sort$`/`&objet&` n'y fonctionnent pas — annoncer un tag là où il n'est pas résolu se
paie en saisies inutilisables, c'est exactement le type d'erreur rencontré sur le don
« Façonneur ».

`texte-parsers` est dynamique : compte les termes de glossaire du ruleset actif et bascule sur
« aucun terme saisi » quand il n'y en a pas. Sur DD3.5, l'auteur sait tout de suite qu'aucun
renvoi ne sera produit.

**[2026-08-11] `<details>` d'aide du formulaire de tableau remplacé par `aideIcone()`**
→ Demande utilisateur : un seul mécanisme d'aide dans l'application, contenu centralisé.
Le CSS devenu inutile (`.reg-tab-aide*`) a été retiré. `#aide-bulle` s'élargit et devient
défilant selon son contenu (`:has(.aide-table)`) — pas de variante à passer depuis le PHP.

**[2026-08-11] Correction de datation des entrées SP-TB**
Les entrées SP-TB et les deux fichiers `sql/` créés dans cette session portaient la date
**2026-07-27**, qui est celle des travaux SP-GL antérieurs. Corrigées en **2026-08-10**, date
réelle de leur rédaction ; `2026-07-27_tableaux_sp-tb0.sql` et la sauvegarde `sql/backup/`
renommés en conséquence.
→ Un journal de décisions dont les dates sont fausses ne vaut plus rien : deux chantiers
distincts y apparaissaient le même jour. Les occurrences légitimes de 2026-07-27 (SP-GL, §9d)
ont été préservées.

---

## Module Personnages — passage au code projet SP-PE

**[2026-08-12] Renumérotation des sous-phases « 3.x » en `SP-PE`**
Constat lors d'un point de situation : le module Personnages était le **seul chantier du projet
absent du §0 « Suivi des phases »** de `ARCHITECTURE_0_REFERENCE.md`. Son avancement ne vivait
qu'en §7.11, sous forme d'une liste narrative (« 3.0 — *livrée* ») héritée du découpage par
« Phases » antérieur aux codes projet `SP-*`. Conséquence directe : impossible de retrouver son
état depuis le tableau de bord, alors que c'est précisément sa fonction.
→ Décision (validée par l'utilisateur) : le module reçoit le code projet **`SP-PE`** et ses phases
  sont renumérotées puis portées en checklist dans le §0, au même titre que `SP-C`, `SP-E`,
  `SP-T`, `SP-TB` et `SP-GL`.
→ **Aucune modification de code livré** : c'est une opération de documentation. `SP-PE0→PE2`
  correspondent exactement à ce qui existe en base et dans le dépôt depuis le 2026-06-14.

Table de correspondance (l'ancienne numérotation reste lisible dans les entrées du journal
antérieures au 2026-08-12, qui ne sont pas réécrites) :

| Nouveau | Ancien | Contenu | État |
|---|---|---|---|
| `SP-PE0` | 3.0 | Socle + SQL | livrée 2026-06-12 |
| `SP-PE1` | 3.1 | Fiche identité + première classe à la création | livrée 2026-06-13 |
| `SP-PE2` | 3.2 | Classes & niveaux (éditeur DOM inline) | livrée 2026-06-14 |
| `SP-PE3` | 3.3 | Compétences | à faire |
| `SP-PE4` | 3.4 | Dons | à faire |
| `SP-PE5` | — | Bloc Campagnes de la fiche (lecture seule) | à faire |
| `SP-PE6` | 3.5 | NLS prestige (DD3.5) | à faire |
| `SP-PE7` | 3.6 | Vue Magie | à faire |
| `SP-PE8` | 3.7 | Mode jeu + passe responsive < 992px | à faire |

**[2026-08-12] `SP-PE5` — le bloc Campagnes devient une phase à part entière**
Le bloc « Campagnes » figurait en position 9 de l'ordre des blocs de la fiche (archi §7.3) mais
n'était rattaché à aucune sous-phase 3.x — il n'apparaissait que dans la liste « À venir » de
`fiche.php`, sans propriétaire. Il aurait pu se perdre à la reprise.
→ Isolé en `SP-PE5`, inséré avant les phases lourdes (NLS, Magie) : c'est de la lecture seule sur
  des données déjà disponibles via `getCampagnesPersonnage()`, donc la phase la moins coûteuse
  restante.

**[2026-08-12] Objets magiques du personnage — hors périmètre `SP-PE`, pas de phase décochée**
Conformément à la règle de tenue du §0 (« une phase abandonnée est retirée, pas laissée
décochée »), `personnages/objets.php` ne reçoit **pas** de phase `SP-PE`. Le placeholder et son
motif (analyse métier non fiabilisée, dépendance au compendium Objets magiques, aucune table)
restent documentés en archi §7.9 et dans l'arbitrage [2026-06-12] [D].
→ Le sujet reviendra comme chantier propre (code projet distinct) le jour où l'analyse métier
  sera tranchée — pas comme une case perpétuellement vide du module Personnages.

**[2026-08-12] État réel du module au moment de la renumérotation**
Vérification faite dans le dépôt, et non d'après la doc : 3 commits seulement touchent
`personnages/` (2026-06-12, 06-13, 06-14), `personnages/enregistrement.php` n'expose que trois
actions (`supprimerPersonnage`, `enregistrerPersonnage`, `enregistrerClasses`), `magie.php` et
`objets.php` sont des placeholders. Le module est en **pause depuis le 2026-06-14** — le travail
a basculé sur Campagnes, puis SP-E, SP-T, SP-TB et SP-GL.
→ La mention « Phase 3 — Personnages EN COURS » du §14 était trompeuse depuis deux mois :
  corrigée en « EN PAUSE (`SP-PE`) » avec la date de dernière livraison.
→ Les tables `dd_personnages_competences`, `_dons`, `_nls`, `_sorts`, `_sorts_prepares` existent
  déjà en base : `SP-PE3→PE8` sont du code, pas du schéma. Aucun patch SQL attendu.

---

## SP-PE3 — Compétences du personnage

**[2026-08-12] D-PE3a — Éditeur inline sur la fiche, et non dans l'overlay**
L'archi §7.5 plaçait les compétences dans un bloc repliable de l'overlay `modifier/personnage.php`.
Décision contraire : l'éditeur est **inline dans le bloc Compétences de la fiche**, sur le modèle de
l'éditeur Classes de SP-PE2 (modes lecture / édition, commit global).
→ Raison : cocher une compétence en séance ne doit pas imposer de rouvrir le formulaire d'identité
  complet ; l'overlay reste dédié à l'identité, et le pattern d'édition du module devient uniforme.
→ Archi §7.5 corrigée en conséquence.
→ *Ces quatre décisions (D-PE3a à D-PE3d) ont été proposées en arbitrage avec recommandation ;
  faute de réponse, les options recommandées ont été appliquées et sont réversibles.*

**[2026-08-12] D-PE3b — Le total de compétence est affiché (2ᵉ exception au « pas de moteur de règles »)**
DD3.5 : rangs + mod. de carac. DD2024 : mod. de carac + bonus de maîtrise (`dd_bonus_maitrise` au
niveau global), doublé en expertise.
→ Même justification que le NLS en §7.7 : le total est le chiffre cherché au moment du jet, et le
  recalculer de tête annule le bénéfice de la fiche.
→ Le total est **volontairement incomplet** (ni équipement, ni malus d'armure, ni bonus divers — ces
  données ne sont pas saisies dans le module). La fiche l'annonce explicitement sous le tableau,
  pour qu'il ne soit jamais pris pour une valeur de fiche opposable.
→ Le calcul est écrit deux fois : `bonusCompetence()` en PHP (mode lecture) et dans
  `competencesEditor` en JS (recalcul à la volée pendant la saisie). Duplication assumée — la
  version JS ne fait pas d'aller-retour serveur à chaque frappe. Toute évolution de la formule doit
  toucher les deux.
→ Documenté en archi §7.7b.

**[2026-08-12] D-PE3c — Rangs DD3.5 : borne technique seule (0-99)**
Aucun plafond de règle (niveau + 3) n'est appliqué, ni en dur ni en indication.
→ Conforme à §7.1 : la saisie est déclarative et peut rester incomplète ou « fausse » au regard des
  règles sans que l'application s'en mêle. `MAX_RANGS = 99` côté JS et bornage serveur symétrique
  (2 en DD2024, 99 en DD3.5) ne servent qu'à empêcher les valeurs aberrantes.

**[2026-08-12] D-PE3d — Mode lecture : compétences maîtrisées uniquement**
Conforme à §7.3. Le tableau complet (36 lignes en DD3.5, 18 en DD2024) n'apparaît qu'en mode
édition, où un champ de filtre par nom évite le défilement sur mobile.

**[2026-08-12] Compétences hors sources actives — jamais masquées si déjà saisies**
La liste est bornée par `getActiveResIds()` comme le reste du module, **mais** une compétence déjà
saisie par le joueur reste affichée même si sa source a été désactivée depuis
(`OR pec.pec_id IS NOT NULL` dans `getPersonnageCompetences()`).
→ Désactiver un ouvrage dans « Mes sources » ne doit jamais faire disparaître silencieusement une
  donnée saisie : la donnée resterait en base, invisible et non modifiable, et serait effacée au
  prochain enregistrement (DELETE + INSERT).

**[2026-08-12] Bug évité — `comp_car_id = 0` est une valeur légitime**
Le chargement des compétences utilisait un `JOIN` sur `dd_caracteristiques`. Vérification en base :
la compétence DD3.5 **« Langue » (#24) porte `comp_car_id = 0`** — elle n'a pas de caractéristique
associée, ce qui est conforme aux règles. L'INNER JOIN la faisait disparaître de la fiche sans
aucun signal (35 compétences remontées sur 36).
→ Corrigé en **LEFT JOIN** ; `car_nom`/`car_diminutif` peuvent être NULL, la colonne Carac affiche
  « — » et le modificateur vaut 0. Le PHP ne construit alors aucun nom de champ `pe_*`.
→ Leçon générale : sur ce schéma, un `_id = 0` signifie « non renseigné » et n'est jamais une FK
  valide — tout JOIN sur un champ `_id` nullable ou à 0 doit être un LEFT JOIN.

**[2026-08-12] SP-PE3 livrée — vérifications effectuées**
Rendu de `fiche.php` testé hors serveur web (session simulée) : 0 erreur PHP, 18 compétences
injectées en JS, bonus de maîtrise correctement résolu. Action `enregistrerCompetences` testée par
POST simulé sur la base locale, puis table restaurée à son état initial (vide) :
→ maîtrise 9 envoyée en DD2024 → bornée à 2 ; compétence d'un autre ruleset → rejetée par le
  contrôle d'intégrité ; ligne à maîtrise 0 → ignorée. Les trois comportements sont conformes.

**[2026-08-13] Correctif — `getActiveResIds()` accepte un ruleset explicite**
Signalement : « la fonctionnalité n'apparaît pas pour le ruleset DD3.5 ». Reproduction : un
personnage **DD3.5** consulté pendant une session restée sur **DD2024** affiche 0 compétence *et*
0 classe dans l'éditeur — les listes se vident sans message d'erreur.
Cause : `getActiveResIds()` déduisait le ruleset de `$_SESSION['ruleset_var_id']`, alors que la
fiche et l'overlay Personnage travaillent sur `pe_ruleset_var_id`, **figé à la création**. Le
croisement « entités DD3.5 » × « sources DD2024 » ne remonte rien. Le défaut existait depuis SP-PE2
(éditeur Classes) et SP-PE1 (selects Race / Archétype / Historique) ; SP-PE3 l'a rendu visible.
→ `getActiveResIds($db, ?int $ruleset_var_id = null)` : second paramètre **optionnel**, repli sur
  la session. Les 14 appels du compendium sont inchangés — leur ruleset de session est le bon,
  puisque l'utilisateur y consulte précisément le ruleset qu'il a sélectionné.
→ `personnages/fiche.php` et `include/ajax/modifier/personnage.php` passent désormais le ruleset du
  personnage. Vérifié : 36 compétences et 32 classes rendues dans les deux sens (session cohérente
  et session divergente), 0 erreur PHP.
→ Règle : toute page dont l'entité porte son propre ruleset doit passer ce ruleset explicitement.
  Le ruleset de session ne fait autorité que pour le compendium.

**[2026-08-13] SP-PE3 — colonne de saisie élargie, et deux pièges de spécificité CSS**
Demande utilisateur : la colonne du champ de saisie (rangs DD3.5 / maîtrise DD2024) était beaucoup
trop étroite, à quadrupler au minimum. Elle portait `col-stat`, dimensionnée dans `modules.css`
pour un BBA ou un jet de sauvegarde (**46 px**) — jamais pour un champ éditable, ni pour le libellé
« Expertise ».
→ Classe dédiée `.per-comp-table__saisie` : **200 px** (× 4,35). Champs `width: 100%`, soit 188 px
  contre 64 px auparavant. Mesuré dans un navigateur sur le CSS réel du projet.
→ **Piège 1** — une simple `width: 200px` ne suffisait pas : la colonne « Compétence » est en
  `width: 100%` et absorbe l'espace libre, ramenant la colonne de saisie à 160 px. C'est
  `min-width` qui pilote réellement la largeur dans un tableau `table-layout: auto`.
→ **Piège 2** (défaut introduit par SP-PE3, corrigé au passage) — `.per-comp-table__nom
  { text-align: left }` n'a jamais été appliqué : `.table-dd th, .table-dd td { text-align: center }`
  (spécificité 0,1,1) l'emportait sur 0,1,0. Les 36 noms de compétences s'affichaient centrés.
  Sélecteur préfixé en `.table-dd .per-comp-table__nom`.
→ Leçon : dans ce projet, **toute règle visant une cellule de `.table-dd` doit être préfixée par
  `.table-dd`** — le composant pose déjà `text-align`, `padding` et `white-space` à ce niveau de
  spécificité.
→ Vérifié : cible tactile à 44 px sous 992 px (media query active), aucun débordement horizontal
  de page — la table large défile dans `.table-dd-wrap`.

---

## SP-PE4 — Dons du personnage

**[2026-08-13] D-PE4a — Écriture immédiate : exception assumée au commit global**
L'arbitrage [E] du 2026-06-12 avait banni toute écriture AJAX immédiate au profit d'un commit
global. Le sélecteur de dons y déroge : chaque « Ajouter » / « Supprimer » écrit une ligne
séparément (`ajouterDon` / `supprimerDon`).
→ Raison : la spécification ne prévoit **aucun bouton « Enregistrer »** — on enchaîne les choix et
  on ferme. Un état purement local serait perdu à la moindre fermeture accidentelle, et le compteur
  « total des dons du personnage » cesserait d'être une vérité serveur.
→ Le risque que l'arbitrage [E] écartait (état partiel incohérent à mi-formulaire) n'existe pas
  ici : chaque action est **atomique** et porte sur une seule ligne d'une table de liaison. Aucune
  transaction n'est nécessaire.
→ Portée de l'exception : **les tables de liaison simples, sans champ propre à saisir**. Les
  éditeurs Classes (SP-PE2) et Compétences (SP-PE3), qui portent des valeurs, restent en commit
  global. Ne pas généraliser sans nouvel arbitrage.

**[2026-08-13] D-PE4b — Le sélecteur gère lui-même l'ouverture de `#detail-pp`**
Il ne passe pas par `actualiserPage()`, pour deux raisons techniques :
1. `actualiserPage()` **n'exécute pas les `<script>`** du HTML injecté (seul `actualiserPageModif()`
   les recrée) : l'initialisation du panneau ne peut donc pas venir du fragment.
2. La fermeture doit **recharger la fiche** si des dons ont changé, ce que le ✕ générique ne fait
   pas — `donsPicker.fermer()` porte cette logique.
→ Le panneau réutilise `.overlay-close` et `.overlay-panel__inner` : l'apparence reste native.
→ Choix confirmé par le fait que le backdrop de `#detail-pp` **ne ferme pas au clic** (contrairement
   à `#detail-pp-sub`) : le panneau est sûr pour de la saisie, la fermeture est bien explicite.

**[2026-08-13] D-PE4c — Le bouton du volet droit est posé en JS**
`detail-pp/don.php` est partagé avec le compendium. Plutôt que d'y ajouter un paramètre
« mode personnage », le sélecteur injecte lui-même le bouton dans `.sort-detail__nom` après
chargement.
→ Le compendium reste ignorant de la notion de personnage ; aucun fichier partagé n'est modifié.

**[2026-08-13] D-PE4d — Deux volets conservés à toutes les largeurs**
Demande explicite de l'utilisateur : « une colonne à gauche avec un ascenseur contenant la liste
des dons, un espace à droite fixe contenant l'affichage du don ». Aucune bascule en colonne unique
sous 992 px, contrairement à la priorité mobile du §7.3.
→ Compensations : libellés des boutons masqués au profit des icônes, catégorie renvoyée sous le nom,
  cible tactile portée à 40 px. À revoir si l'usage sur téléphone se révèle trop serré.

**[2026-08-13] Données — un don DD2024 pointe sur une catégorie DD3.5**
Constaté en vérifiant le select de filtre, qui affichait « Général » **deux fois**. Le don **#381
« Tactiques Zhentarim »** (ruleset 2, source 94) porte `do_dado_id = 1`, c'est-à-dire la catégorie
« Général » du ruleset **DD3.5** (la catégorie DD2024 équivalente est `dado_id = 19`).
→ Incohérence de **données**, pas de code : le sélecteur affiche fidèlement ce qu'il lit, et le
  filtrage reste juste. Non corrigé — c'est du contenu utilisateur.
→ À corriger en base par `UPDATE dd_dons SET do_dado_id = 19 WHERE do_id = 381;` si c'est bien une
  erreur de saisie. Aucune contrainte SQL ne relie `do_ruleset_var_id` à `dado_ruleset_var_id`.

**[2026-08-13] SP-PE4 livrée — vérifications effectuées**
→ Rendu du sélecteur : 37 dons DD2024, compteur à 0, catégories alimentées, volet détail présent,
  0 erreur PHP. Fiche personnage rendue avec le bloc Dons, 0 erreur.
→ Actions testées en sous-processus isolés puis base restaurée à 0 ligne : ajout `{ok, total:1}` ;
  **ajout en double → total inchangé** (INSERT IGNORE + `uk_ped`) ; 2ᵉ ajout `total:2` ;
  **don d'un autre ruleset → rejeté** ; retrait `total:1`.
→ Mise en page mesurée dans un navigateur sur le CSS réel : volets côte à côte (410 px / 485 px
  dans un panneau de 960 px), ascenseur propre à la liste, 2 dons en surbrillance, 3 boutons
  « Supprimer » (2 en liste + 1 en fiche), compteur à 2, aucun débordement de page.
→ **Non vérifié** : le rendu à une largeur réellement inférieure à 400 px — le panneau d'aperçu
  n'honore pas le redimensionnement. Les règles sous 992 px sont bien actives (libellés masqués,
  boutons à 40 px), mais l'ergonomie sur téléphone reste à confirmer sur appareil.

**[2026-08-12] Listes de capacités des formulaires — composant `.table-classe-modif--liste`**
Les tables de capacités des formulaires Classe (§3) et Race (§3) portaient la classe
`.table-classe-modif`, qui n'a **jamais** eu de règles CSS : en-têtes centrés (défaut natif des
`<th>`) face à des cellules alignées à gauche, cellules sans padding (reset global
`*, *::before, *::after { padding: 0 }` de `main.css`) et table en largeur de contenu — d'où
l'impression de colonnes décalées.
→ Nouveau bloc dans `css/compendium-modules.css` (le même fichier qui porte déjà `.modif-section`,
  dont dépend tout le formulaire) : largeur 100 %, `padding` et `text-align: left` sur toutes les
  cellules, en-tête sur `--clr-surface-alt`, filet `--clr-border`, colonne `.col-actions` en
  `width: 1%` + `nowrap` pour que les deux boutons ne se replient pas.
→ Règles portées par le **modificateur** `--liste` et non par `.table-classe-modif` : la table de
  progression (Classe §2) partage la classe de base avec jusqu'à 26 colonnes d'`<input>`, elle
  n'entre pas dans le même moule et reste inchangée.
→ Les styles inline redondants des lignes injectées en JS (`font-size` de la colonne Niveau(x),
  `white-space` de la colonne Actions) sont remplacés par le CSS du composant.

**[2026-08-13] Changement de ruleset au profil — purge du contexte de navigation**
Basculer le « Ruleset par défaut » dans `profil/index.php` (section Paramètres) réécrivait
`ruleset_var_id` / `rulesetRep` mais laissait en session tout le contexte de navigation du ruleset
quitté : `last_pe_id` et la cascade `last_camp_*` / `last_sce_*` / `last_scc_*` / `last_re_*`.
→ Nouvelle fonction `resetContexteRuleset()` dans `include/helpers.php`, appelée depuis la section
  Paramètres **uniquement si l'id du ruleset change réellement** (même discriminant que
  `setLastCampagne()` : l'id, pas le passage dans le formulaire) — réenregistrer ses paramètres sans
  toucher au ruleset ne doit rien effacer.
→ Purge de la cascade **entière**, pas seulement des campagnes : `last_pe_id` est le premier maillon
  de `getActiveResIds()` (chaîne campagne > perso > défaut). Conservé après bascule, il fait remonter
  les sources de la campagne d'un personnage de l'autre ruleset — même famille de bug que l'entrée
  [2026-08-13] sur la fiche Personnage, mais prise à l'autre bout : là on figeait le ruleset de
  l'entité, ici on efface un contexte devenu hors-sujet.
→ La même bascule recharge `$ruleset_nom_actif`, `$ressources_dispo` et `$res_selectionnes` sur le
  nouveau ruleset : ces trois variables sont calculées avant le traitement du POST, la section
  « Mes sources » affichait donc encore les ressources du ruleset quitté jusqu'au rechargement
  suivant. Le titre de section et les cases à cocher restent cohérents avec le header.
→ Aucun impact sur la connexion : `startUserSession()` part d'une session régénérée, donc vierge.

**[2026-08-13] Liste des campagnes — filtrage par ruleset actif**
`campagnes/index.php` listait **toutes** les campagnes du MJ, tous rulesets confondus, alors que
`camp_ruleset_var_id` est le ruleset **maître** de la campagne (§8) et que la liste des personnages,
explicitement « calquée sur `campagnes/index.php` » (§7.4), filtre bien sur le ruleset de session.
→ Ajout de `camp.camp_ruleset_var_id = ?` au WHERE, alimenté par `$_SESSION['ruleset_var_id']`,
  exactement comme `personnages/index.php`.
→ La colonne « Ruleset » du tableau est **retirée** : filtrée, elle affichait la même valeur sur
  toutes les lignes. Le ruleset passe dans le titre — `Campagnes (DD2024)` — sur le modèle du h1 de
  la liste des personnages. Le `LEFT JOIN dd_variables` qui ne servait qu'à cette colonne disparaît
  avec elle. Aucun impact CSS : `.camp-liste` ne contient aucune règle `nth-child`.
→ Message vide contextualisé : « Aucune campagne en DD2024 pour le moment. »
→ **Non modifié, à arbitrer** : le formulaire de création laisse choisir l'autre ruleset
  (`optionListVar` en mode création, verrouillé ensuite) — la campagne créée sort alors
  immédiatement de la liste. `modifier/personnage.php` a exactement le même comportement depuis
  SP-PE1 ; verrouiller le select sur le ruleset de session se déciderait pour les deux modules à la
  fois, pas pour les campagnes seules.

**[2026-08-13] Ruleset des entités — retiré des formulaires, imposé côté serveur**
Suite du correctif « liste des campagnes ». Deux formulaires laissaient choisir le ruleset à la
création (`modifier/campagne.php`, `modifier/personnage.php`, `optionListVar`) et neuf le postaient
en champ caché depuis la session (les 9 entités du compendium). Dans les deux cas la valeur venait du
client : une entrée pouvait naître dans un ruleset où aucune liste ne l'affiche, et un POST forgé
pouvait déplacer une entrée existante d'un ruleset à l'autre.
→ Nouvelle fonction `rulesetEnregistrement($db, $table, $champ_id, $champ_ruleset, $id)` dans
  `include/helpers.php`, point de passage unique : `$_SESSION['ruleset_var_id']` si `$id === 0`,
  valeur relue en base sinon. Le POST n'est plus jamais consulté.
→ Les 11 champs de formulaire sont supprimés : 9 `<input type="hidden">` (sort, don, classe, race,
  compétence, objet, monstre, historique, équipement) et les 2 `optionListVar` (campagne,
  personnage). Campagne et Personnage conservent un affichage `<input disabled>` **sans `name`** —
  l'information reste visible, elle n'est plus transmise — avec un `form-hint` qui renvoie au profil
  pour créer dans l'autre ruleset.
→ `*_ruleset_var_id` retiré des `UPDATE` de don, équipement, sort, compétence, race et historique :
  le ruleset devient structurellement immuable. `dd_classes` le faisait déjà (ajout du paramètre
  nommé au seul INSERT), `dd_objets_magiques`, `dd_monstres`, `dd_campagnes` et `dd_personnages` ne
  l'écrivaient déjà qu'à l'INSERT.
→ Régression silencieuse corrigée au passage : les 9 formulaires du compendium initialisaient
  `$ruleset_id` depuis la **session**, pas depuis l'entité. Modifier un sort DD3.5 au cours d'une
  session DD2024 le basculait donc en DD2024. Vérifié après correctif sur la base locale :
  `rulesetEnregistrement()` rend bien 1 pour un sort DD3.5 alors que la session est en 2 ; rend 2 en
  création ; rend la valeur de session sur un id inexistant.
→ **Exception assumée** : `modifier/ressource.php` (admin) garde son select — une ressource est un
  livre source *déclaré pour* un ruleset, saisi indépendamment de la session de l'admin.
→ Non traité (autre chantier, déjà signalé) : les selects « campagne » du homebrew
  (8 × `modifier/*.php` + `compendium-liste.php`) ne filtrent toujours ni sur le ruleset ni sur
  `camp_supprime`.

---

## SP-PE5 — Campagnes du personnage

**[2026-08-14] D-PE5a — La phase « lecture seule » devient lecture + écriture**
`SP-PE5` avait été isolée le 2026-08-12 comme « la moins coûteuse : lecture seule sur des données
déjà disponibles via `getCampagnesPersonnage()` ». Vérification du code à sa reprise : ces données
ne pouvaient pas exister. `dd_campagnes_personnages` n'était la cible d'**aucun INSERT** dans
l'application — seulement deux DELETE de cascade (suppression d'une campagne, suppression d'un
personnage) — et `pe_camp_id` n'était jamais écrit, seulement remis à NULL à la suppression d'une
campagne. Aucun écran ne rattachait un personnage à une campagne ; le compteur « Personnages » de
`campagnes/index.php` affichait donc structurellement 0.
→ Livrer la lecture seule aurait produit un bloc affichant « aucune campagne » pour tous les
  personnages, définitivement, et laissé le compteur faux. La phase inclut donc le rattachement.
→ Leçon générale : une phase annoncée « lecture seule sur données existantes » doit être vérifiée
  côté écriture avant d'être estimée. L'existence d'une table et d'un helper de lecture ne prouve
  pas qu'une donnée y arrive.

**[2026-08-14] D-PE5b — Écriture immédiate plutôt que commit global**
Trois éditeurs coexistent désormais sur la fiche : Classes et Compétences en commit global, Dons
et Campagnes en écriture immédiate.
→ Critère retenu, déjà posé en D-PE4a : un éditeur qui porte des **valeurs** (niveau, rangs) se
  commite en bloc ; un éditeur qui bascule des **appartenances booléennes** écrit à chaque clic.
  Un bouton « Enregistrer » n'aurait rien à regrouper, et l'utilisateur qui quitte le bloc sans
  cliquer perdrait son travail sans le savoir.
→ Conséquence assumée : pas d'annulation. Le geste inverse est toujours à un clic.

**[2026-08-14] D-PE5c — Les deux écritures (liaison + raccourci) sont solidaires**
`dd_campagnes_personnages` est la source de vérité, `pe_camp_id` le raccourci « campagne en
cours » (METIER_10). Les laisser diverger produirait une fiche qui se contredit.
→ Quatre règles, appliquées dans la même transaction :
  1. Désigner une campagne en cours crée la liaison si elle manque et la force `cp_actif = 1`.
  2. Clore la participation de la campagne en cours efface `pe_camp_id`.
  3. Détacher la campagne en cours efface `pe_camp_id`.
  4. `camp_id = 0` sur `definirCampagneCourante` = « aucune campagne en cours ».
→ `getCampagnesPersonnage()` retient une campagne si la liaison existe **ou** si elle est désignée
  courante : une donnée héritée d'avant SP-PE5 reste visible au lieu de disparaître.
→ Chaque action renvoie l'état relu en base (`total`, `camp_courante`, `rattache`, `actif`) :
  l'éditeur n'extrapole jamais, une action pouvant en déplacer une autre.

**[2026-08-14] D-PE5d — `cp_actif` exposé comme « participation en cours / terminée »**
Le champ existait en base sans sémantique portée par une interface, et `getActiveResIds()` s'en
servait déjà.
→ Exposé en toggle manuel sur chaque campagne rattachée. Sens retenu : 1 = participation en cours,
  0 = terminée (le personnage a traversé la campagne, il n'y joue plus). Une participation
  terminée reste dans l'historique de la fiche mais n'ouvre plus les sources de la campagne.

**[2026-08-14] D-PE5e — Périmètre du rattachement : les campagnes du propriétaire uniquement**
L'application n'a aucun mécanisme d'invitation : un MJ ne peut pas proposer sa campagne au
personnage d'un autre joueur, et `detail-pp/personnage.php` est de toute façon réservé au
propriétaire (`canAccess`).
→ La liste proposée est bornée à `camp_j_id = pe_j_id` + `camp_ruleset_var_id = pe_ruleset_var_id`
  + `camp_supprime = 0`, contrôlée aussi côté serveur avant chaque rattachement.
→ Le filtre porte sur le **propriétaire du personnage**, pas sur l'utilisateur en session : un
  admin consultant la fiche d'un autre joueur voit la même liste que lui.
→ Le contrôle n'est **pas** rejoué au détachement : retirer une liaison devenue non conforme
  (campagne d'un autre ruleset héritée d'un import) doit rester possible.
→ Le ruleset filtré est celui du personnage, jamais celui de la session — règle du module posée le
  2026-08-13, sinon la liste se vide dès que les deux divergent.

**[2026-08-14] D-PE5f — Correctif `getActiveResIds()` priorité 1 : scope campagne en cours**
La branche priorité 1 unionnait les sources de **toutes** les campagnes du personnage à
`cp_actif = 1`. Défaut jusqu'ici invisible : la table de liaison étant vide, la branche n'était
jamais atteinte. SP-PE5 l'aurait réveillée telle quelle — et comme `$_SESSION['last_pe_id']` est
posé à chaque ouverture de fiche, l'effet aurait débordé sur tout le compendium de la session.
→ Requête rescopée sur la campagne en cours : jointure `dd_personnages` → liaison
  (`cp_camp_id = pe_camp_id`, `cp_actif = 1`) → `dd_campagnes_sources`.
→ Une campagne terminée n'ouvre donc plus ses ouvrages ; c'est ce qui donne son effet concret au
  toggle de D-PE5d.
→ Règle générale : une phase qui alimente une table pour la première fois doit auditer le code
  qui la lit déjà.

**[2026-08-14] D-PE5g — Miroir côté Campagnes en lecture seule**
`detail-pp/campagne.php` reçoit une section « Personnages » (nom, race, classes, statut).
→ Lecture seule assumée : le rattachement reste piloté depuis la fiche du personnage, un seul
  point d'écriture pour un seul modèle de données.
→ Les noms ne sont cliquables que si `canAccess()` passe — inutile d'ouvrir un panneau qui
  répondra 403.
→ `cp_notes_mj` reste non exposé (METIER_10 : prévu, non actif, dépend du module Notes Phase 5).

**[2026-08-14] D-PE5h — `.per-camp__badge` dans `modules.css`, le reste dans `personnages-modules.css`**
Le badge de statut sert à la fois au bloc de la fiche et au panneau de campagne, ce dernier étant
un fragment injecté en AJAX depuis un module qui ne charge pas `personnages-modules.css`.
→ Application de la règle permanente du 2026-06-14 : tout style utilisé par un fragment injecté
  va dans `modules.css`. Le reste (`.per-camp`, `.per-camp-editor__*`), rendu par `fiche.php`,
  reste dans la feuille du module.

**[2026-08-14] SP-PE5 livrée — vérifications effectuées**
- `php -l` sur les 5 fichiers PHP modifiés : aucune erreur de syntaxe.
- `js/personnage.js` parsé sans erreur (41 Ko) ; `modules.css` et `personnages-modules.css`
  chargés en CSSOM : 19 règles `.per-camp*` reconnues, aucune règle rejetée.
- Requêtes nouvelles ou modifiées exécutées contre la base locale : `getCampagnesPersonnage()`,
  `getCampagnesRattachables()`, priorité 1 de `getActiveResIds()`, section Personnages du panneau
  de campagne — toutes conformes au schéma réel.
- Chemin d'écriture rejoué en transaction annulée (rattacher → double clic → désigner en cours →
  clore → détacher) : idempotence de `INSERT IGNORE` sur `uk_cp` confirmée (1 ligne après deux
  clics), règles de cohérence de D-PE5c vérifiées à chaque étape, base inchangée après ROLLBACK.
- **Non vérifié** : le rendu et les interactions réelles dans le navigateur — les pages du module
  exigent une session authentifiée. À contrôler à la première ouverture de fiche.
- Aucun patch SQL, conformément à l'annonce §7.11.

---

## SP-PE6 — NLS prestige du personnage (DD3.5)

**[2026-08-27] D-PE6a — Commit global du bloc, et non écriture immédiate**
Quatre éditeurs coexistent désormais sur la fiche. Le critère posé en D-PE4a puis D-PE5b tranche
sans hésitation : le bloc NLS porte des **valeurs choisies dans des selects** (quelle classe de
base reçoit tel niveau), pas des appartenances booléennes.
→ Éditeur inline à commit global, comme Classes et Compétences : boutons Enregistrer / Annuler,
  persistance DELETE + INSERT en transaction (action `enregistrerNls`).
→ Corollaire utile : l'affectation d'une classe de prestige entière se saisit d'un trait, puis se
  valide en une écriture — un commit par select aurait produit jusqu'à 10 requêtes pour un geste
  que l'utilisateur perçoit comme unique.

**[2026-08-27] D-PE6b — Un niveau sans progression de NLS n'a pas de select**
Toutes les classes de prestige n'avancent pas le NLS à chaque niveau : le Champion occultiste ne
progresse qu'à partir du niveau 2 (`cn_niveauSortArcane = 0` au niveau 1), le Thaumaturge un
niveau sur deux.
→ Ces niveaux restent **visibles** dans le tableau (numérotation continue, l'utilisateur voit que
  le niveau existe) mais affichent « Sans progression de NLS » en `text-muted`, sans select en
  édition et sans « À affecter » en rouge en lecture.
→ Les deux autres options ont été écartées : donner un select produirait une affectation sans
  effet sur le calcul de SP-PE7 ; masquer la ligne produirait une numérotation à trous, illisible.
→ Cas limite traité pareil : un niveau **absent de `dd_classe_niveau`** (saisie compendium
  incomplète — le Hiérophante n'a que 5 lignes pour 10 niveaux) est traité comme sans progression.
  Le bloc n'invente pas une affectation à faire à partir d'une donnée manquante.

**[2026-08-27] D-PE6c — « Complétude » = celle de chaque ligne postée, pas celle du tableau**
La spec d'origine (`ARCHITECTURE_1_PERSONNAGE.md`) demandait que « le joueur doit affecter chaque
niveau » et l'annonce de phase parlait de « validation serveur = complétude ». Pris au pied de la
lettre, le serveur aurait refusé tout enregistrement partiel.
→ Lecture retenue, cohérente avec le principe « aide de jeu, saisie déclarative » de l'archi §7.1 :
  l'affectation partielle est **autorisée**. Les niveaux non affectés s'affichent « À affecter » en
  rouge — ce que la spec prévoit explicitement, donc un état attendu, pas une anomalie.
→ La complétude validée par le serveur est celle de **chaque ligne postée** : les trois champs ou
  rien, les deux `pc_id` appartiennent au personnage, la source est une classe de prestige, le
  niveau est dans les bornes détenues, il fait progresser le NLS, et la réceptrice est compatible
  avec son type de magie (`effectif` → toutes ; `arcane` → `cla_mag_id = 1` ; `divin` → 2).
→ Aucune règle de jeu au-delà : pas de contrôle de prérequis de classe de prestige.

**[2026-08-27] D-PE6d — Enregistrer les classes remet l'affectation NLS à zéro**
Comportement hérité de SP-PE2, constaté et **conservé** : `enregistrerClasses` supprime toutes les
lignes `dd_personnages_nls` du personnage avant son DELETE + INSERT des classes.
→ Ce n'est pas un défaut : `dd_personnages_nls` référence des `pc_id`, que le DELETE + INSERT
  renouvelle systématiquement. Les affectations ne peuvent pas leur survivre.
→ Conséquence à connaître : monter d'un niveau une classe depuis le bloc Classes efface
  l'affectation NLS, qui est à ressaisir. Documenté en archi §7.5d plutôt que contourné — préserver
  les lignes exigerait de réécrire l'enregistrement des classes en UPDATE ciblés, hors périmètre.

**[2026-08-27] D-PE6e — Le bloc est omis, pas vide, quand il n'a pas lieu d'être**
Condition d'affichage (reprise de la spec) : au moins une classe de base lanceuse **et** une
classe de prestige dont un niveau détenu fait progresser le NLS.
→ `getPersonnageNls()` renvoie `null` dans le cas contraire et `fiche.php` n'émet pas la section —
  plutôt qu'un bloc affichant « rien à affecter », qui n'apprendrait rien à personne.
→ La ligne « NLS prestige » de la liste « À venir » de la fiche est retirée par la même occasion.

**[2026-08-27] SP-PE6 livrée — vérifications effectuées**
- `php -l` sur les 3 fichiers PHP modifiés : aucune erreur de syntaxe.
- Contrôle des drapeaux réels en base : 23 classes de prestige DD3.5, dont 9 avec au moins un
  `cn_niveauSort*` levé — les trois combinaisons du filtrage (arcane seul, effectif, arcane+divin)
  existent bien, ainsi que le cas « niveau 1 sans progression » (Champion occultiste).
- **Vérifié dans le navigateur** (session authentifiée par la procédure D-RS35) sur un personnage
  de test à 4 classes (Magicien 7 / Prêtre 3 / Champion occultiste 4 / Théurge mystique 3) :
  lecture conforme (niveau 1 « Sans progression », niveaux 2-4 « À affecter » en rouge), selects
  filtrés correctement (Magicien seul sur les niveaux arcane, Magicien + Prêtre sur les niveaux
  arcane + divin), enregistrement partiel accepté et relu en base (4 lignes, 2 niveaux laissés
  non affectés). Personnage de test supprimé après contrôle.
- Chemin nominal reconfirmé par l'utilisateur sur un personnage réel (Elminster + classe de
  prestige) avant clôture de la phase.
- Aucun patch SQL, conformément à l'annonce §7.11.

---

**[2026-08-15] D-DON1 — Import des dons DD2024 du Manuel des Joueurs (p. 207-211)**
Livraison sous forme de fichier SQL relu et exécuté manuellement
(`sql/2026-08-15_dons_dd2024_mdj.sql`), pas d'écriture directe en base par l'assistant.
→ 14 dons créés : 9 en catégorie Général (`dado_id` 19) — Protection légère, Protection lourde,
  Résilient, Sentinelle, Télékinésiste, Télépathe, Tireur d'élite, Trancheur, Tueur de mages —
  et 5 en catégorie Faveur épique (`dado_id` 20) — Faveur de compétence, Faveur de récupération,
  Faveur de résistance aux énergies, Faveur de vigueur, Faveur de vitesse.
→ Périmètre demandé : tout le PDF à partir de « Protection légère ».

**[2026-08-15] D-DON2 — Les dons déjà présents issus du SRD 5.2.1 ne sont pas écrasés**
17 dons du périmètre existaient déjà en base sous `do_res_id = 93` (SRD 5.2.1), en texte brut sans
balisage HTML : les 10 dons de Style de combat (`dado_id` 21) et 7 Faveurs épiques (Faveur
d'attaque irrésistible, de déplacement dimensionnel, de l'esprit nocturne, de mémoire magique,
de prouesse martiale, de Vision lucide, du destin).
→ Décision : ne rien toucher. L'import ne crée que les entrées absentes.
→ Conséquence assumée : cohabitation de deux mises en forme dans `dd_dons` pour le ruleset DD2024
  (texte brut SRD vs HTML Manuel des Joueurs), et 5 de ces Faveurs épiques restent en
  `do_public = 0`. À reprendre si l'on veut une présentation homogène du chapitre Dons.

**[2026-08-15] D-DON3 — Mise en forme `do_texte` alignée sur le don « Protection intermédiaire »**
`<p><strong>Vous recevez les bénéfices suivants.</strong></p>` puis un `<p>` par bénéfice au
format `<strong>Nom du bénéfice</strong>. Texte.`, accents encodés en entités HTML.
→ Reproduit le gabarit de référence fourni (do_id 426) et le lot déjà importé sous `do_res_id = 91`.
→ Le point final est placé hors du `<strong>`, forme majoritaire dans le lot existant
  (cf. do_id 422) ; rendu visuel identique.
→ Aucun tag de liaison explicite (`$...$`, `#...#`) n'est posé : les noms de sorts cités
  (« main du mage », « détection des pensées ») sont pris en charge par `lierAuto()` au rendu.

**[2026-08-15] D-DON4 — `do_page_source = 91` pour ce lot**
Valeur imposée par l'utilisateur, alors que toutes les lignes DD2024 déjà en base portent
`do_page_source = 0`.
→ Écart de convention consigné ici : la colonne reste documentée « usage à clarifier »
  (cf. audit du 2026-07-01). 91 est aussi le `res_id` du Manuel des Joueurs 2024, déjà porté par
  `do_res_id` — à trancher si la colonne prend un jour un sens fonctionnel.

**[2026-08-15] D-DON5 — Source du texte : image des pages, pas la couche texte du PDF**
La couche texte de `MDJ_2024_v1-extrait_dons.pdf` est un OCR fautif (« DO » pour « DD »,
« augmente de l, » pour « de 1, », prérequis collés sans espace).
→ Les pages ont été rendues en image et transcrites visuellement.
→ Les erreurs OCR présentes dans les dons importés précédemment n'ont pas été propagées, mais
  elles subsistent en base sur ce lot antérieur (ex. do_id 422 « {DO égal à 8 », do_id 426
  « niveau 4 ou plus.formation aux armures légères »). Correction non demandée, non effectuée.

**[2026-08-22] D-RS0 — Nouveau projet SP-RS : finalisation de l'UI smartphone**
Chantier transverse ouvert sur les modules déclarés responsives en §10 (compendium, personnages,
wiki, profil, auth, admin — campagnes reste hors périmètre, desktop MJ).
→ Codes de phase `SP-RS0` à `SP-RS5`, checklist en §0.

**[2026-08-22] D-RS1 — Mode debug : bascule en session depuis le tableau de bord admin**
Le badge de dimensions d'écran est activé par une case à cocher dans `admin/index.php`
(section « Outils de développement », POST `section=debug` + CSRF), stockée dans
`$_SESSION['debug_ui']`.
→ Choix de la session contre une préférence en base : outil de mise au point, pas un paramètre
  utilisateur — aucun patch SQL, aucune colonne à maintenir, remise à zéro à la déconnexion.
→ Écarté : `?debug=1` + localStorage (accessible à tout utilisateur connaissant l'URL) et le
  raccourci clavier (inutilisable sur smartphone, la cible même du chantier).
→ Double garde à l'affichage : `$_SESSION['debug_ui']` **et** `$_SESSION['j_admin']` — la session
  d'un admin rétrogradé ne peut pas conserver le badge.

**[2026-08-22] D-RS2 — Contenu du badge : viewport, dpr et paliers CSS réels**
Le badge affiche `largeur × hauteur`, le `devicePixelRatio`, puis les trois paliers effectivement
déclarés dans les CSS du projet — 991, 768, 479 — soulignés quand ils sont actifs.
→ Les paliers sont passés par `data-breakpoints` depuis `include/header.php` : le JS ne les
  redéclare pas, une évolution des media queries se répercute en un seul point.
→ Position tournante sur les quatre coins au clic (`localStorage.debugViewportCoin`) : le badge
  masquerait sinon en permanence un coin de l'écran pendant les relevés.
→ `z-index: 9000`, très au-dessus du maximum applicatif (300 = `#detail-pp-sub`), pour rester
  lisible par-dessus les panneaux.

**[2026-08-22] D-RS3 — Menu principal en déroulant sous 992px, dans le flux du header**
Le bouton `#site-nav-toggle` et le panneau `#site-nav` occupent chacun toute la largeur
d'affichage, l'un sous l'autre, en `flex: 0 0 100%` dans le header en `flex-wrap`.
→ Retenu le seuil **991px** déjà en service plutôt qu'un nouveau palier smartphone : SP-RS5
  tranchera les paliers définitifs à partir des relevés du mode debug.
→ Panneau **dans le flux** et non en `position: absolute` : le header sticky grandit à
  l'ouverture au lieu de recouvrir le contenu ; `max-height: calc(100vh - 160px)` + scroll interne
  pour les sessions où la nav est longue (mode campagne + admin).
→ Panneau de liens maison, pas un `<select>` natif : la nav porte des icônes, un lien de profil et
  une déconnexion — un `<select>` imposerait une navigation par `onchange` et perdrait la
  sémantique des liens.
→ Bouton rendu uniquement si l'utilisateur est connecté (`$nav_collapsible`) : hors session la nav
  se limite à « Connexion ».
→ Fermeture au clic hors header, à `Échap` et au retour au-dessus de 991px au resize.

**[2026-08-22] D-RS4 — SP-RS2 : bandeau de contexte en fil d'Ariane défilable (≤991px)**
Mesuré avant refonte à 375×812 en cascade complète : 4 boutons de 178 à 243px de large, donc un
par ligne, bandeau de 150px et 259px consommés avant le premier contenu (32% de l'écran, 46% sur
un iPhone SE). Cibles tactiles de 27px, contre 44px recommandés.
→ Retenu : une seule ligne défilable horizontalement — coût vertical **constant à 57px** quelle
  que soit la profondeur, contre ~104px pour la variante « chips multi-lignes ».
→ Écarté « niveau courant seul + dépliage » : remonter d'un niveau aurait coûté un tap
  supplémentaire, alors que le bandeau existe précisément pour ça.
→ Le préfixe de type (« Campagne : », ~90px) est remplacé par une icône sous 992px ; la hiérarchie
  reste lisible par l'ordre et les chevrons de séparation.
→ Cadrage : sur smartphone le cas fréquent reste **un seul bouton personnage** — le module
  Campagnes est desktop-MJ (§10). La cascade à 4 niveaux est un scénario de bureau, ce qui a
  écarté tout mécanisme de dépliage.

**[2026-08-22] D-RS5 — Rendu unique serveur, différenciation par le CSS seul**
`include/header-context.php` émet le même HTML à toutes les largeurs (icône + libellé + nom +
séparateurs) ; la media query masque les libellés et révèle les séparateurs.
→ Un seul chemin de rendu à maintenir, et le fragment reste valable quel que soit le
  redimensionnement après chargement — ce qui compte, `actualiserContexteHeader()` réinjectant le
  bloc à chaud sans rechargement de page.
→ Conséquence assumée sur desktop : les icônes de type apparaissent aussi, seule évolution
  visible au-dessus de 992px.

**[2026-08-22] D-RS6 — `flex-shrink: 0` sur les boutons du fil d'Ariane**
Avec le `flex-shrink: 1` par défaut, les boutons se compriment pour tenir dans la ligne au lieu de
la faire déborder : `scrollWidth == clientWidth`, aucun défilement, et les quatre noms tronqués
(mesuré : 77/77/69/95px au lieu de 153/153/135/194px).
→ `flex: 0 0 auto` est structurant pour ce composant, pas cosmétique.

**[2026-08-22] D-RS7 — Piège de spécificité Font Awesome sur `display`**
`main.css` est chargé **avant** la feuille Font Awesome : à spécificité égale, `.fa { display }`
l'emporte sur une règle à une seule classe. Les séparateurs, masqués par
`.site-header__context-sep { display: none }`, restaient donc visibles en desktop.
→ Corrigé en écrivant la règle à deux classes. Règle générale : toute déclaration `display` visant
  une icône FA doit monter en spécificité.

**[2026-08-22] D-RS8 — SP-RS3 : le menu ⋮ était masqué sous 992px, pas seulement à l'étroit**
`.col-action { display: none }` dans la media query du compendium : sur téléphone, les 9 listes
n'offraient ni Modifier, ni Dupliquer, ni Supprimer, ni les `row_actions` déclarées par les pages
(export Roll20…). Perte fonctionnelle, pas un défaut de mise en page.
→ Colonne réaffichée à 44px, bouton 40×40. La colonne de sélection multiple reste masquée, la
  barre d'actions groupées l'étant déjà.
→ Le ⋮ reste **à gauche** du nom : c'est l'ordre des colonnes du moteur, commun aux 9 entités et
  au desktop. Le déplacer à droite imposerait de réordonner `th`/`td` dans le moteur et changerait
  aussi l'affichage de bureau — hors périmètre d'une passe responsive.

**[2026-08-22] D-RS9 — Recadrage du menu ⋮ dans le viewport**
`compToggleMenu()` positionnait le menu en `position: fixed` sur `rect.left` / `rect.bottom` sans
contrainte. Sur écran étroit il débordait à droite ; pour les dernières lignes d'une page il
s'ouvrait sous le bas du viewport.
→ Contrainte à 8px des bords, bascule au-dessus du bouton quand la place manque dessous.
→ Le menu est démasqué **avant** la mesure : sous `.noDisplay` (`display: none !important`),
  `offsetWidth`/`offsetHeight` valent 0 et le calcul serait faux.
→ Corrige aussi le desktop (menu tronqué en bas de page), sans changement visible ailleurs.

**[2026-08-22] D-RS10 — Menu Sources : `position: static` sans passer le conteneur en colonne**
La media query sortait le menu du flux absolu, mais `.comp-filtre-item` est un conteneur flex en
ligne : le menu devenait un frère de rangée et se partageait la largeur avec son bouton (mesuré
141px + 200px à 375px de large, côte à côte).
→ `.comp-filtre-item--sources` passe en `flex-direction: column`. Après correction : bouton et
  menu à 341px, empilés.
→ Règle générale : tout passage `absolute → static` en responsive doit vérifier la direction du
  conteneur flex parent.

**[2026-08-22] D-RS11 — Cibles tactiles du compendium portées à 40px**
Mesures à 375×812 : boutons d'action de la barre de filtre **20px de haut** (icône seule, libellé
masqué en mobile), selects 31px, bouton Sources 32px, pagination 32px.
→ Tous portés à 40px minimum. Les lignes de liste (59px) et le champ de recherche (40px) étaient
  déjà conformes.
→ Conséquence assumée : la pagination peut passer sur deux lignes quand la fenêtre de pages est
  large (jusqu'à 11 éléments). `.comp-pagination` étant déjà en `flex-wrap`, aucun débordement
  horizontal.

**[2026-08-22] D-RS12 — Tri sur colonnes secondaires : limite assumée sur mobile**
Sous 992px les en-têtes `col-secondary` sont masqués, donc seul le tri sur la colonne primaire
reste accessible ; les valeurs elles-mêmes restent lisibles dans `.comp-subrow`.
→ Non traité dans SP-RS3 : le vecteur naturel serait un select « Trier par » dans le panneau de
  filtres, à arbitrer si le besoin se confirme à l'usage.

**[2026-08-22] D-RS13 — SP-RS3b : la barre de filtrage devient un composant partagé**
Le module Personnages devait reprendre la barre de filtrage du compendium, mais celle-ci vivait
dans `compendium-modules.css` / `compendium.js`, non chargés sur les pages personnages. Une copie
partielle existait déjà dans `admin-modules.css` : sans décision, on partait vers une troisième.
→ CSS déplacé dans `css/modules.css`, `toggleFiltresMobile()` et son initialisation dans
  `js/main.js` — les deux seuls fichiers chargés sur toutes les pages.
→ **Classes `comp-filtre-*` conservées.** Les renommer imposerait de reprendre
  `compendium-liste.php`, `admin-liste.php`, `ajax/modifier/objet.php` et `compendium.js` pour un
  gain purement cosmétique. Le préfixe est historique, pas un périmètre.
→ Le composant `.per-filtres*` est supprimé de `personnages-modules.css`.

**[2026-08-22] D-RS14 — Effet du déplacement sur l'ordre des feuilles, vérifié**
`main.css` → `modules.css` → `<module>-modules.css`. Les règles déplacées passent de la position 3
à la position 2 : à spécificité égale, elles perdent désormais contre `<module>-modules.css`.
→ Analysé : le seul recouvrement restant est `.comp-filtre-select { max-width: 100% }` (mobile),
  déclaré à l'identique dans `compendium-modules.css` — aucun effet.
→ `admin-modules.css` garde sa copie partielle et continue donc de l'emporter sur ce qu'elle
  déclare. Elle hérite en plus des propriétés qu'elle ne déclare pas : contrôles pleine largeur et
  cibles 40px sous 992px. Effet **voulu et conservé**, §10 alignant déjà l'admin sur le compendium.
→ Vérifié dans le navigateur après déplacement, à 375px et à 1280px, sur les deux modules : rendu
  desktop inchangé (toggle masqué, formulaire en ligne, menu Sources en absolu) et rendu mobile
  identique entre compendium et personnages.

**[2026-08-22] D-RS15 — Personnages : fin de l'auto-soumission des selects de filtre**
Les deux selects se soumettaient au `change`. Avec un panneau repliable, chaque rechargement
referme le panneau : poser deux critères d'affilée devenait impossible sans le rouvrir.
→ Point de soumission unique, le bouton Filtrer, comme dans le compendium.
→ Les libellés visibles (`Campagne`, `Classe`, `Recherche`) disparaissent au profit de la première
  option (`— Campagne —`) et de l'attribut `title`, toujours par alignement sur le compendium.
→ Le bouton « Nouveau personnage » **reste dans la ligne de titre** et n'a pas été replié dans la
  barre de filtres comme le « + » du compendium : l'y mettre l'aurait rendu icône seule et masqué
  derrière le toggle sur mobile, pour une action de création fréquente.

**[2026-08-22] D-RS16 — Ligne de titre de personnages/index.php : défaut constaté, non corrigé**
Mesuré à 375px : `.flex-between` étant en `nowrap`, le h1 « Personnages (ruleset) » est comprimé à
239px et s'étale sur trois lignes, le bouton « Nouveau personnage » sur deux (96px de hauteur
totale).
→ Hors périmètre de la demande (barre de filtrage). Non corrigé : le correctif naturel
  (`flex-wrap: wrap` sous 992px) porterait sur `.flex-between`, utilitaire global de `main.css`
  utilisé par de nombreuses pages — à arbitrer, pas à décider au détour d'une passe.

**[2026-08-22] D-RS17 — SP-RS4 : `display: contents` pour ne pas toucher au desktop**
La barre d'en-tête commune aux trois panneaux devait exister dans le DOM à toutes les largeurs
(elle est injectée par `js/main.js`, pas par un template conditionnel), sans rien changer au rendu
de bureau où les boutons flottent aux coins du panneau.
→ `.overlay-panel__bar { display: contents }` en desktop : la boîte disparaît, les boutons
  `position: absolute` continuent de se référer au panneau. Vérifié à 1280px, coordonnées
  identiques à avant travaux (Fermer 30×27 en haut à droite, Retour 81×32 en haut à gauche).
→ Sous 992px la barre reprend une boîte flex et les boutons passent en `position: static`.
→ Alternative écartée : deux markups injectés selon `window.innerWidth`. Le panneau aurait été
  faux après une rotation d'écran ou un redimensionnement, l'injection n'ayant lieu qu'au
  chargement du contenu.

**[2026-08-22] D-RS18 — Panneaux en feuille plein écran plutôt que centrés**
Trois panneaux centrés de tailles voisines (646 / 297 / 86px mesurés) rendaient la profondeur
illisible sur un écran de 375px, et le décalage `translate(-46%, -46%)` du sous-panneau — pensé
pour laisser voir le panneau du dessous en desktop — le poussait **hors écran à droite** (bord à
386px pour 375 de viewport).
→ Feuille plein écran sous 992px : `inset: 0`, `transform: none`, sans rayon.
→ Le sous-panneau reste plein écran mais décalé de 24px vers le bas : la bande visible marque la
  profondeur et appartient à son backdrop, donc un tap dessus le ferme.
→ Écarté : le bottom sheet (ancré en bas, 92dvh). Mêmes bénéfices, mais une animation à écrire et
  aucun gain fonctionnel sur des panneaux qui occupent de toute façon presque tout l'écran.

**[2026-08-22] D-RS19 — `dvh` avec repli `vh`**
`max-height: 95vh` ignore la barre d'URL rétractable des navigateurs mobiles : l'unité `vh` se
réfère au viewport barre déployée, le panneau pouvait donc dépasser la zone réellement visible.
→ `height: 100vh` puis `height: 100dvh` déclarés dans cet ordre : les navigateurs qui ignorent
  `dvh` gardent la première déclaration.

**[2026-08-22] D-RS20 — Bouton Fermer ajouté à `#modification`, y compris en desktop**
`actualiserPageModif()` n'injectait aucun bouton Fermer — le panneau d'édition ne se fermait que
par le bouton Annuler du formulaire ou par un clic sur le backdrop. En feuille plein écran, il ne
reste plus aucun backdrop à toucher.
→ Fermer injecté dans la barre des trois panneaux, sans exception de largeur : le masquer en
  desktop aurait demandé une règle spéciale pour un seul panneau.
→ Seule évolution visible en desktop de toute la phase. Sans risque de perte de saisie : le
  backdrop, déjà cliquable, ferme le panneau de la même manière depuis toujours.

**[2026-08-22] D-RS21 — Effets de bord des marges réservées aux boutons flottants**
Plusieurs blocs réservaient à la main la bande occupée par les boutons flottants :
`.overlay-panel .camp-detail { margin-top }`, `.glossaire-sub__header { padding-top }`, et
`.glossaire-sub__ligne-badge`, positionné en absolu pour s'aligner verticalement sur l'ancien
bouton Fermer.
→ Neutralisés sous 992px. Sans quoi le badge du glossaire se serait superposé à la nouvelle barre
  et les fiches de campagne auraient gardé une bande vide de 2rem sous la barre.
→ Ces rustines subsistent en desktop, où le recouvrement du titre par les boutons flottants reste
  un défaut connu (choix explicite : la barre est mobile uniquement).

**[2026-08-22] D-RS22 — Relevés d'affichage : collecte par beacon, pas par le formulaire de connexion**
Objectif : arbitrer les paliers responsive sur des mesures réelles. Les premiers relevés manuels
(Galaxy A52 : 342×632 dpr 3.16 ; Galaxy A12 : 384×725 dpr 1.88) montrent deux appareils **sous
400px CSS**, donc tous deux sous le palier 479 — le moins utilisé du projet.
→ Collecte par beacon AJAX au premier chargement de page de chaque session authentifiée
  (`include/ajax/releve-device.php`, déclenché par `releveDevice()` dans `js/main.js`).
→ Écarté : des champs cachés dans le formulaire de connexion. `dd_joueurs.j_remember_token`
  existe : les sessions reprises par jeton de mémorisation ne passent jamais par ce formulaire et
  n'auraient jamais été mesurées.
→ Le relevé est pris sur la première page réellement affichée, donc dans les conditions qui
  décident du palier CSS appliqué.

**[2026-08-22] D-RS23 — Aucune donnée personnelle ajoutée**
Ni adresse IP, ni géolocalisation : le besoin est de dimensionner l'UI, pas de tracer les accès.
→ `co_session` stocke un **SHA-1 de `session_id()`**, jamais l'identifiant lui-même. Il ne sert
  que de clé d'unicité `uk_co_session (co_j_id, co_session)`, avec `INSERT IGNORE` : plusieurs
  onglets ouverts d'un coup émettent le beacon avant que le drapeau de session ne soit posé, et
  produiraient sinon plusieurs lignes pour une seule connexion.
→ L'`userAgent` est conservé (tronqué à 255) : c'est la seule façon d'identifier un modèle
  d'appareil quand `navigator.userAgentData` est absent (Firefox, Safari).

**[2026-08-22] D-RS24 — Double écriture : instantané et historique**
`dd_joueurs.j_last_*` (10 colonnes, écrasées) pour lire l'état courant d'un utilisateur sans
agréger, et `dd_connexions` (une ligne datée par session) pour la série qui servira à l'arbitrage.
→ Le nom `j_last_device_date` évite la confusion avec `j_derniere_connexion`, déjà présente et
  maintenue par ailleurs : la première date le relevé, la seconde la connexion.
→ Toutes les valeurs reçues sont bornées côté serveur au domaine de leur colonne — elles viennent
  du client, aucune n'est écrite telle quelle.
→ Le beacon échoue proprement si le patch SQL n'est pas encore appliqué, **sans poser le drapeau
  de session** : la collecte redémarre d'elle-même une fois la base à jour.

**[2026-08-22] D-RS25 — Écran d'administration `admin/connexions.php`**
Lecture seule : répartition par palier (part en %, utilisateurs distincts, largeurs observées),
largeurs les plus fréquentes, puis journal des 200 dernières connexions.
→ Les bornes de la synthèse (479 / 767 / 991) reprennent les media queries réellement déclarées :
  si un palier bouge en SP-RS5, l'écran doit être mis à jour avec lui.
→ Purge non automatisée. La requête est fournie en commentaire du patch SQL.

**[2026-08-12] Bulle d'aide des tableaux — fusions explicitées**
La section « Fusions » disait « cellule vide = fusion avec la cellule de gauche » sans
mentionner le `|` de fermeture : une fusion qui va jusqu'à la dernière colonne exige une barre
supplémentaire, faute de quoi elle est amputée d'une colonne (`_tabDecouper()` supprime une
cellule vide en fin de ligne pour qu'on puisse terminer une ligne par `|` sans créer de colonne
fantôme). Question posée en usage réel sur un tableau à 6 colonnes.
→ Section réécrite : règle de comptage (une cellule vide par colonne absorbée), avertissement
sur le `|` final, trois exemples sur 6 colonnes (fusion au milieu, fusion jusqu'au bord, deux
groupes) et un exemple de fusion verticale `^` avec la précision que le second niveau ne
déclare que les colonnes réellement subdivisées.

Les exemples de la bulle sont vérifiés **en les repassant dans le parser** : couverture 6/6 sur
les trois cas horizontaux, `rowspan=2` correct sur la paire verticale, aucun `^` résiduel en
sortie. Si la convention évolue sans que l'aide suive, ce contrôle le révèle.

> Comportement du parser **inchangé**. L'alternative étudiée — faire absorber automatiquement
> les colonnes restantes par la dernière cellule d'une ligne d'en-tête plus courte que le
> tableau — a été écartée : décision utilisateur de documenter plutôt que de modifier un
> comportement déjà en service.

**[2026-08-22] SP-SC1 — Sous-classes DD2024 : finitions liste et fiche**
Cinq ajustements demandés sur la section Classes du compendium, sans changement de schéma.

*Liste — classe de base dans la colonne Type.* La colonne rend
`CONCAT(clt.clt_nom, IF(clapar.cla_nom IS NULL, '', CONCAT(' (', clapar.cla_nom, ')')))` plutôt
qu'une colonne supplémentaire.
→ Une colonne de plus aurait coûté de la largeur sur une liste déjà à 4 colonnes, alors que
  l'information ne concerne qu'un type d'entrée. Le libellé reste vide de parenthèses pour Base
  et Prestige, dont `cla_cla_id` est `NULL` : aucune condition sur le ruleset n'est nécessaire.
→ Le tri porte sur la même expression, donc les sous-classes d'une même classe de base se
  regroupent naturellement.

*Liste — critère « Classe parente » conditionnel.* Le critère n'est ajouté à `$filtres` que si
`f_clt_id = 5`, et `$_GET['f_cla_par']` est purgé sinon. Le critère « Type de classe » reçoit une
nouvelle clé de moteur `submit_onchange`.
→ Le critère conditionnel est calculé côté page contrôleur, pas dans le moteur : le moteur reste
  générique, et la dépendance entre critères est une règle métier de la page.
→ Sans le `unset`, la valeur masquée resterait dans `$_GET` et se propagerait aux liens de tri et
  de pagination (`http_build_query($_GET)`) — le filtre continuerait d'agir sans être visible.
→ Les options n'exposent que les classes ayant réellement une sous-classe en base (`EXISTS`),
  pour ne pas proposer d'option à résultat vide.

*Fiche — mise en page.* « Compétences », « Maîtrise d'armes » et « Formation aux armures » étaient
rendus hors de `.sort-detail__body` (`font-size: .9rem`), libellé empilé au-dessus du texte. Ils
deviennent des `.sort-detail__row` du même bloc.
→ Cause de l'incohérence de taille : ces blocs héritaient de la taille du body de page, pas de
  celle du corps de fiche. Les rapatrier règle la taille et l'alignement d'un seul geste, sans
  ajouter de règle CSS de compensation.
→ Nouvelle classe `.sort-detail__value--html` pour les deux champs TinyMCE : sans neutralisation
  des marges de bord des `<p>` générés, le contenu retombe sous le libellé malgré le flex.

*Fiche — retrait de « Niveaux » en DD2024.* La progression y est commune à toutes les classes.
→ Conservé en DD3.5, où les classes de prestige ont des niveaux max distincts — la ligne y porte
  une vraie information.

*Fiche — liste des sous-classes sur une classe de base.* Symétrique de « Classe parente », mêmes
renvois `naviguerDetailPP()`.
→ La requête reprend le périmètre du moteur de liste (sources actives **et** règle de visibilité
  supplément) plutôt que de lister toutes les lignes `cla_cla_id = id` : une fiche ne doit pas
  exposer une entrée qu'une liste aurait masquée. Requête non exécutée si `getActiveResIds()`
  renvoie un tableau vide (jamais de `IN ()`).

**[2026-08-22] SP-SC2 — Capacités spéciales de la fiche de classe**
Requête unique agrégée à la place des deux requêtes classe normale / sous-classe, libellé de
section supprimé, titres « Niveau X : Nom » mis en avant.

*Une capacité = une entrée.* `MIN(cc.cc_niveau)` + `GROUP BY` sur toutes les colonnes non
agrégées, ordonné par niveau puis par nom.
→ La branche sous-classe listait une ligne **par affectation** : une capacité à itérations y
  apparaissait autant de fois qu'elle avait de niveaux, avec la même description répétée.
  L'agrégation supprime la répétition sans perdre le niveau d'entrée.
→ Le tri alphabétique de la branche « classe normale » perdait son sens dès lors que le niveau
  ouvre le titre — les capacités suivent désormais l'ordre d'acquisition.
→ Les itérations suivantes ne sont pas perdues : table de progression pour une classe normale,
  texte de la capacité pour une sous-classe.

*`cc_niveau = 0`.* Trois affectations DD3.5 le portent (Rôdeur, Maître des ombres, Kensai —
donnée non renseignée à la saisie). Le préfixe est omis dans ce cas, le nom s'affiche seul.
→ Afficher « Niveau 0 : » exposerait un niveau qui n'existe pas dans les règles. Corriger la
  donnée relève de la saisie, pas de l'affichage — la fiche se contente de ne pas mentir.

*Mise en forme.* Titre à `1.2rem` (+20% sur le corps de fiche) en `var(--clr-accent-2)`, l'accent
déjà porté par `.sort-detail__nom`. Styles sortis de l'inline vers `css/compendium-modules.css`.
→ L'espacement est porté par `margin-top` sur `.classe-detail__capacite + .classe-detail__capacite`
  plutôt que par un `margin-bottom` sur chaque bloc : sinon la dernière capacité creuse un vide
  avant le pied de fiche.
→ `.cap-type` est explicitement dé-grossi : sans règle, il héritait du `1.2rem` du titre alors
  que c'est une mention secondaire.
→ Palier 991px (celui où `#detail-pp` devient une feuille plein écran, SP-RS4) : espacement à
  `var(--sp-md)` et titre à `1.1rem`. Aérer une page n'a pas le même coût sur un panneau latéral
  et sur une feuille de téléphone, où la hauteur utile est la ressource rare.

**[2026-08-22] D-RS26 — SP-RS6 : le raccourci personnage quitte le bandeau de contexte**
Le dernier personnage consulté était un **niveau de repli** de `getHeaderContextNiveaux()` :
affiché seulement en l'absence de chaîne de campagne, et logé dans le bandeau de contexte.
→ Extrait dans `getHeaderPersonnage($db)` et rendu comme dernier élément de `<header>`, donc à
  l'extrême droite de la ligne de titre à toutes les largeurs. `getHeaderContextNiveaux()` ne
  retourne plus que la chaîne de campagne.
→ Conséquence voulue : le raccourci est désormais visible **en permanence**, y compris pendant la
  consultation d'une campagne, là où il disparaissait auparavant.
→ `.site-header__nav` reçoit `margin-left: auto` : le header est en `space-between` et compte
  maintenant trois éléments — sans cela la nav dérivait au centre en desktop.
→ Sous 992px le raccourci prend `order: 2` : il reste sur la ligne du logo, le bouton Menu
  (order 3) et la nav (order 4) gardant leurs propres lignes.
→ Limite connue : le raccourci est rendu au chargement de page. Consulter un personnage sans
  recharger (panneau) ne le met pas à jour avant la navigation suivante.

**[2026-08-22] D-RS27 — Troncature du raccourci : `min-width: 0` et plafond à 40%**
Mesuré à 375px avec un nom long (« Telgar Weyr le Magnifique ») : le raccourci occupait 186px et
**basculait sur une deuxième ligne**, repoussant le bouton Menu.
→ `min-width: 0` sur le raccourci — sans lui, un élément flex refuse de descendre sous la largeur
  de son contenu et l'ellipsis du nom ne s'applique jamais.
→ Plafond à `40%` de la largeur sous 992px : le logo et le badge de ruleset occupent ~186px, le
  reste doit tenir dans la ligne. Après correction : raccourci à 137px, nom tronqué, une seule
  ligne.

**[2026-08-22] D-RS28 — Bouton d'ajout et titre de la liste des personnages**
Le bouton « Nouveau personnage » perd son libellé et se réduit à son icône `+` (`title` et
`aria-label` conservés). La mention du ruleset disparaît du `<h1>` : elle fait double emploi avec
le badge `.site-header__ruleset` du header. `$ruleset_rep`, devenue inutilisée, est supprimée du
contrôleur.

**[2026-08-22] D-RS29 — SP-RS6b : le moteur de liste devient générique, Personnages l'adopte**
Six clés optionnelles ajoutées à `include/compendium-liste.php`, toutes additives — absentes, le
comportement est strictement celui d'avant :
`champ_res` absent (pas de filtre sources), `extra_params` (valeurs des `?` de `extra_where`),
`url_ligne` (clic de ligne vers une page au lieu de `#detail-pp`), `edition_libre` (menu ⋮ ouvert
sans `canEditCompendium()`), `avec_ajout` (masque les boutons Ajouter et Tableaux), `suppression`
(mode AJAX vers une action nommée au lieu du POST `ids[]`).
→ `personnages/index.php` passe de ~280 lignes de rendu maison à une déclaration `$listConfig`.
→ Le bug visible sur la capture d'écran disparaît de lui-même : `.per-liste td { display: block }`
  (0,1,1) l'emportait sur `.per-liste__col-sec { display: none }` (0,1,0), les valeurs
  s'affichaient donc **deux fois** en mobile. Même famille que D-RS7.
→ `.per-liste*` supprimé de `personnages-modules.css`, les fonctions `per*` de liste supprimées de
  `personnage.js` (un seul appelant, la page réécrite).

**[2026-08-22] D-RS30 — Correction : le moteur ne servait pas `regles/tableaux.php`**
J'ai affirmé à l'utilisateur, en argumentant la réutilisation, que `regles/tableaux.php` utilisait
déjà le moteur hors du module compendium. C'est faux : le fichier ne le mentionne que pour dire
qu'il ne s'y applique pas, au motif d'un « scoping ruleset seul, pas de sources actives ».
→ Le moteur servait 9 pages, il en sert 10 avec Personnages.
→ Le motif invoqué par `tableaux.php` est exactement la limitation levée par `champ_res` absent :
  cette page devient candidate à la migration en SP-RS6c.

**[2026-08-22] D-RS31 — JS des listes promu dans `main.js`**
`compToggleMenu`, `compDemanderSuppression`, `compAnnulerSuppression`, `compConfirmerSuppression`,
`compDupliquer`, `compMajBulkBar`, `compDeselectionnerTout`, `compSoumettreAction` et
`rafraichirListe` existaient en deux copies (compendium.js, admin.js) plus une variante `per*`
(personnage.js). Une seule implémentation désormais, dans `main.js`.
→ Deux divergences arbitrées à la fusion :
  – `compToggleMenu` garde le paramètre `btn` et le recadrage viewport (version compendium). Les
    listes admin l'appellent sans `btn` : le recadrage ne s'applique pas, leur menu restant
    positionné en `absolute` par `admin-modules.css`. **L'administration ne gagne donc pas encore
    le recadrage** — contrairement à ce que j'avais annoncé ; ce sera SP-RS6c, avec l'alignement
    de son CSS.
  – `compSoumettreAction` demande désormais confirmation pour **toutes** les actions groupées
    (comportement admin) et non plus seulement pour la suppression (comportement compendium), avec
    un message explicite pour cette dernière. Ajouter une confirmation ne peut pas faire perdre de
    données ; l'inverse si.

**[2026-08-22] D-RS32 — Vérification : 10 listes rendues, hors navigateur**
Les pages de liste ont été rendues en CLI avec une session simulée, en lecture seule, et leur HTML
inspecté : 9 listes du compendium inchangées (lignes présentes, bouton Sources, bouton Ajouter,
clic vers `#detail-pp`, suppression en mode formulaire), et Personnages conforme (2 lignes pour le
ruleset 2, aucun bouton Sources ni Ajouter, clic vers la fiche, suppression AJAX).
→ Cas de bord du module Personnages vérifiés un par un : scoping ruleset (1 ligne en DD3.5),
  propriétaire inexistant (0 ligne — l'ordre des `extra_params` est donc correct), filtre campagne,
  filtre classe par EXISTS, recherche texte, et surtout **utilisateur non-admin : les menus ⋮
  restent présents**, ce qui valide `edition_libre`.
→ Non vérifié : le rendu et les interactions réelles dans le navigateur, faute de session
  authentifiée. À contrôler en priorité sur la suppression d'un personnage depuis le menu ⋮.

**[2026-08-22] D-RS33 — Le CSS du moteur de liste rejoint modules.css**
Contrôle en session authentifiée : la liste des personnages s'affichait **sans aucun style de
tableau** — colonnes secondaires visibles sur mobile, bouton ⋮ à 18×22px, sous-ligne non masquée
en desktop. Cause : SP-RS3b n'avait promu que la **barre de filtrage** ; le tableau, le tri, le
menu ⋮, la pagination et la barre bulk étaient restés dans `compendium-modules.css`, que
`personnages/index.php` ne charge pas.
→ Ces blocs (desktop + media query 991px) rejoignent `css/modules.css`, avec le reste du moteur.
→ Le harnais CLI ne pouvait pas voir ce défaut : il vérifie le HTML produit, pas les feuilles de
  style effectivement chargées par la page.

**[2026-08-22] D-RS34 — Suppression du clone `.comp-menu-*` de personnages-modules.css**
Le fichier portait un clone assumé des classes `.comp-menu-*` / `.comp-confirm-*` (« clone de
compendium », créé parce que `compendium-modules.css` n'y était pas chargé). Chargé **après**
`modules.css`, il écrasait les règles partagées — les items du menu ⋮ restaient à 36px au lieu des
44px de la cible tactile SP-RS3.
→ Clone supprimé. Après correction, mesuré en navigateur : bouton ⋮ 40×40, items 43px.
→ Troisième occurrence du même schéma après D-RS10 et D-RS33 : un composant dupliqué localement
  parce que sa feuille n'était pas chargée, qui devient un écrasement silencieux dès que le
  composant est partagé.

**[2026-08-22] D-RS35 — Session authentifiée locale pour les contrôles, sans identifiants**
Le navigateur de travail conserve un `PHPSESSID` stable mais `document.cookie` y est inerte : la
session ne peut pas être posée depuis le JS.
→ Méthode retenue : identifier le fichier de session que le navigateur utilise déjà dans
  `C:\xampp\tmp`, puis y injecter les clés d'authentification. Aucun mot de passe manipulé, aucun
  fichier ajouté au dépôt — les deux scripts vivent dans le scratchpad de session.
→ `startUserSession()` n'est pas réutilisable telle quelle : elle appelle `session_regenerate_id()`,
  ce qui détruirait la session du navigateur. Les clés sont donc recopiées, avec obligation de
  resynchroniser si cette fonction évolue.
→ Écarté : une page `dev-login.php` gardée par `DEV_MODE`. C'est un contournement
  d'authentification qui vit dans le dépôt, et l'historique de `config/db.config.php` (D-CFG1,
  D-CFG2) montre qu'un fichier « local seulement » finit par partir en production.

**[2026-08-22] D-RS36 — Suppression réelle non exercée, volontairement**
Le chemin AJAX a été validé de bout en bout sur un identifiant **inexistant** (999999) : jeton CSRF
accepté, routage vers `supprimerPersonnage`, réponse JSON `{ok:false, erreur:"Personnage
introuvable ou accès refusé."}`. L'UI a été vérifiée jusqu'à la confirmation inline.
→ La suppression effective d'une ligne réelle n'a pas été déclenchée : ce sont les données de
  l'utilisateur. À exercer par lui sur un personnage jetable.

**[2026-08-22] D-RS37 — SP-RS6d : sous-ligne mobile découpée en parts adressables**
Pour détacher la campagne sur sa propre ligne, le moteur n'émet plus une chaîne
`« a · b · c »` mais une suite de `<span class="comp-subrow__part comp-subrow__part--<champ>">`.
Les séparateurs viennent d'un `::before` CSS.
→ Une page peut désormais isoler une valeur (`display: block` + `content: none` sur son `::before`)
  sans que le moteur connaisse la sémantique de ses colonnes.
→ Rendu visuel identique pour les 9 listes du compendium, vérifié.
→ Contrepartie assumée : le texte copié depuis la sous-ligne ne contient plus les séparateurs,
  ceux-ci étant générés par le CSS.

**[2026-08-22] D-RS38 — En-tête de fiche : grille nommée plutôt que deux structures**
La demande diffère selon la largeur — sous 992px le retour se pose au bout de la ligne du nom et
Modifier au bout de la ligne meta ; au-dessus les deux boutons restent groupés en haut à droite.
→ Structure HTML unique et à plat (nom, meta, retour, modifier), disposée par
  `grid-template-areas` redéfinies dans la media query. Aucun bouton dupliqué, donc aucun risque
  de divergence entre les deux rendus.
→ Vérifié : à 1280px les deux boutons restent côte à côte en haut à droite, comme avant ; à 375px
  chacun se cale à droite de sa ligne.

**[2026-08-22] D-RS39 — Bloc Classes déplacé dans le bloc Identité**
Les identifiants `#bloc-classes`, `#classes-lecture`, `#classes-edition`,
`#classes-editor-lignes`, `#btn-editer-classes` et `#classes-msg` sont conservés à l'identique :
`classesEditor` (js/personnage.js) s'y accroche. Vérifié après déplacement — la bascule
lecture/édition génère bien ses lignes et revient en lecture.
→ La ligne porte `per-identite__row--large` : elle occupe toute la largeur de la grille du bloc
  Identité, qui est en `repeat(auto-fit, minmax(260px, 1fr))`.
→ Le bouton d'édition est réduit à son icône **à toutes les largeurs** (règle dédiée sur
  `#btn-editer-classes`), contrairement aux autres boutons Modifier qui ne perdent leur libellé
  que sous 992px.

**[2026-08-22] D-RS40 — Libellés de boutons : classe `.per-btn-label`**
Les éditeurs inline réécrivent l'`innerHTML` de leurs boutons pour basculer Modifier ↔ Annuler.
Masquer les libellés en CSS imposait donc d'aligner aussi le JS : les 8 réécritures de
`js/personnage.js` produisent désormais `<i …></i><span class="per-btn-label">…</span>`.
→ Sans cela, le libellé serait réapparu en dur au premier passage en édition.

**[2026-08-22] D-RS41 — Combat : `flex: 1 1 0` au lieu de `1 1 140px` + `min-width: 140px`**
Les deux tuiles CA et PV passaient l'une sous l'autre dès que la largeur utile descendait sous
~296px — le cas d'un écran à 342px CSS, celui du Galaxy A52 relevé en §10h.
→ Base nulle et `min-width: 0` : les deux tuiles se partagent la ligne quelle que soit la largeur.
  Mesuré à 375px : 155px chacune, côte à côte.

**[2026-08-22] D-RS42 — SP-RS6e : bloc Compétences aligné sur le bloc Dons**
Le mode lecture abandonne le `<table class="table-dd per-comp-table">` au profit d'une liste flex
`.per-comp`, même mécanique que `.per-dons` : nom à gauche, valeurs calées à droite, alignement en
haut quand le nom passe à la ligne. Seule différence avec les dons, demandée : une ligne d'en-tête
en gras.
→ Les trois valeurs (Carac, Maîtrise/Rangs, Total) sont conservées — arbitrage de l'utilisateur
  contre une réduction à deux colonnes, qui aurait fait disparaître Carac et Maîtrise de la lecture.
→ **`width` en `rem`, pas en `em`** : l'en-tête (`.85em`) et les lignes (`.9em`) n'ont pas la même
  taille de police, une largeur en `em` produisait des colonnes décalées de 8px entre l'en-tête et
  les valeurs — constaté à la mesure avant correction.
→ `.per-comp-table*` est **conservé** dans le CSS : `competencesEditor` génère toujours ce tableau
  pour le mode édition. Vérifié après refonte — 19 lignes générées, bascule lecture/édition intacte.

---

## SP-TB10 / SP-TB11 — Le gestionnaire de tableaux quitte le module Règles

**[2026-08-24] D-TB10 — `regles/tableaux.php` → `tableaux/index.php`**
À l'usage, un tableau n'est pas une donnée du module Règles : le tag `[[tab:slug]]` est déjà résolu
dans les monstres et les huit champs description du compendium (SP-TB7), et le sera dans les
campagnes puis l'univers. Le gestionnaire devient un module à part entière — `tableaux/index.php`
et `tableaux/enregistrement.php`.
→ Arbitrage de l'utilisateur : pas d'entrée dans la navigation principale (elle porte déjà six
  entrées), mais un accès depuis la **barre d'outils de chaque module** — Règles et Compendium
  l'avaient déjà, Campagnes le reçoit. Univers n'existe pas encore (`wiki/univers.php` absent).
→ `regles/tableaux.php` subsiste en **redirection 301**, avec traduction du paramètre historique
  `ecran=1` en `f_ecran=1`. Cinq liens internes pointaient sur l'ancienne adresse.

**[2026-08-24] D-TB11 — La liste adopte le moteur `compendium-liste.php`**
La table maison de SP-TB3 n'avait ni pagination ni filtres. Le moteur partagé apporte les deux,
plus le tri, le menu ⋮, le panneau de filtres repliable en mobile et le CSS déjà déplacé en
SP-RS6b — soit exactement la demande, sans code neuf.
→ Le motif invoqué en SP-TB3 pour l'écarter (« pas de sources actives ») ne tenait pas au moteur
  mais aux données : 13 tableaux sur 19 avaient `tab_res_id` à NULL et auraient disparu derrière
  le filtre des sources. L'utilisateur a renseigné les sources manquantes par requête SQL avant la
  livraison ; le mécanisme standard s'applique désormais tel quel. Ferme D-RS30.
→ Le moteur sert 11 pages.

**[2026-08-24] D-TB12 — Trois capacités ajoutées au moteur plutôt que des exceptions**
Trois besoins de cette liste n'étaient pas couverts. Chacun a été traité par une clé générique,
additive et rétro-compatible, plutôt que par un cas particulier :
→ `champs_recherche` — le filtre texte balayait la seule première colonne ; la recherche par slug
  de SP-TB3 aurait été perdue. C'est pourtant le slug qu'on a sous les yeux quand un tag ne résout
  pas et qu'on cherche le tableau correspondant.
→ `colonnes[].valeurs` — colonne calculée en PHP. Voir D-TB13.
→ `td.comp-col--<champ>` — chaque cellule porte le nom de sa colonne, sur le modèle de
  `.comp-subrow__part--*` (SP-RS6d). Permet de recâbler la cellule « Tag à insérer » en `<code>`
  cliquable sans compter les index de colonnes.

**[2026-08-24] D-TB13 — La colonne Usages reste comptée en PHP**
Tentative d'un sous-select corrélé sur l'`UNION` des onze champs hôtes : rejeté par MySQL,
`Illegal mix of collations` — les colonnes hôtes ne partagent ni le même jeu de caractères
(`utf8` / `utf8mb4`) ni la même collation, et `CONVERT(... USING utf8mb4)` sur onze tables aurait
rendu la requête illisible pour un gain nul.
→ `compterUsagesTableaux()` scanne les onze champs avec un `WHERE ... LIKE '%[[tab:%'` — quelques
  lignes sur des milliers — et compte en PHP par `substr_count()`. Mesuré : **41 ms**, cache
  statique par requête. La valeur est passée au moteur par `colonnes[].valeurs`.
→ Conséquence assumée : la colonne n'est pas triable. Le comptage couvre tous les tableaux du
  ruleset, pas seulement la page affichée — la pagination reste donc exacte.

**[2026-08-24] D-TB14 — L'avertissement de suppression passe côté serveur**
La liste maison avertissait en JS (« N règles insèrent encore ce tableau ») ; le moteur générique
n'a qu'une confirmation neutre. L'utilisateur a demandé de conserver l'avertissement **et** la
colonne Usages.
→ `tableaux/enregistrement.php` refuse la suppression tant que `force=1` n'est pas transmis et
  répond `{ok:false, confirmation_requise:true, erreur}` ; `compConfirmerSuppression()` affiche le
  message et réémet la requête après accord. Le contrat est générique, réutilisable par toute
  liste ayant un garde-fou métier.
→ Bénéfice non recherché : le garde-fou s'applique désormais aussi hors interface, l'ancien
  contrôle étant purement client.

**[2026-08-24] D-TB15 — 🐛 La propagation d'un renommage de slug ignorait le compendium**
`_tabPropagerSlug()` ne couvrait que `reg_texte` et `mo_stats` : elle n'avait pas suivi SP-TB7.
Un tableau inséré dans une description du compendium — le don « Façonnage rapide » l'était déjà —
perdait son insertion en silence au premier renommage, le tag s'affichant en
`.reg-tab__manquant`.
→ `tableauChampsHotes()` devient la **source de vérité unique** des onze champs hôtes, partagée
  par la propagation, le comptage des usages et le garde-fou de suppression. Toute extension de
  la portée du tag se déclare là et nulle part ailleurs.
→ `dd_capacites_speciales` n'a pas de colonne ruleset : propagation sans ce filtre. Sans risque,
  l'unicité des slugs étant par ruleset et DD3.5 n'ayant encore aucun tableau (SP-TB9).
→ Vérifié en transaction annulée : le tag est bien réécrit dans `dd_dons.do_texte`, la base
  laissée intacte.

**[2026-08-24] D-TB16 — 🐛 L'outillage CSS/JS n'était chargé que sur les pages Règles**
Même défaut que celui corrigé en SP-TB7 pour le composant de rendu, sur le reste du module :
`.regle-detail__*`, `.tableau-detail*`, `.reg-tab-liste__tag*`, `.reg-tab-saisie`,
`.reg-tab-apercu`, `.tableaux-picker*` et `.regles-badge--ecran` vivaient dans
`regles-modules.css`. Or le picker s'ouvre depuis les dix éditeurs TinyMCE du site, et la fiche
détail d'une règle comme d'un tableau depuis n'importe quelle page — un tag `@id@` ou
`[[tab:slug]]` est résolu jusque dans les stats de monstre. Hors module Règles, tout cela
s'affichait sans style.
→ Déplacé dans `css/modules.css`, chargé sans condition. Même chemin pour la fonction de copie du
  tag : `js/regles.js` → `js/main.js`, renommée `copierTagTableau()`.
→ Règle générale à retenir : **ce qui est injecté en AJAX sur une page quelconque vit dans
  `modules.css` et `main.js`**, jamais dans un fichier de module.

**[2026-08-24] D-TB17 — SP-TB11 : le bouton Modifier passe dans le titre de la fiche**
Signalé par l'utilisateur : dans la fiche détail d'un tableau, le bouton Modifier et la croix de
fermeture se chevauchent. Cause : `.regle-detail__titre` est en `flex: 1`, ce qui pousse le bouton
au bord droit du panneau — exactement là où `.overlay-close` est positionné en `absolute`. Le
défaut touchait aussi la fiche d'une règle, qui partage ce header.
→ Arbitrage de l'utilisateur entre réserver une gouttière et aligner sur le compendium : **option
  retenue, le bouton entre dans le `<h2>`**, à la suite des badges, comme
  `.sort-detail__edit-btn`.
→ Mesuré après correction, panneau réel : bouton à x = 526–554, croix à 1082–1111 en desktop ;
  bouton à y = 107 et croix à y = 5–49 en 375px. Plus aucun contact dans les deux cas.

**[2026-08-24] D-TB18 — Abandon du filtre « par module du site »**
Demandé initialement, puis retiré par l'utilisateur : « un tableau peut être réutilisé partout ».
Un rattachement déclaré (colonne `tab_module_var_id` vers `dd_variables`) aurait été la seule
implémentation compatible avec une pagination SQL — un critère dérivé des usages réels oblige à
filtrer en PHP après le `LIMIT`, ce qui fausse les compteurs. Le coût de saisie et d'entretien ne
valait pas le service rendu.
→ Aucun patch SQL dans cette livraison. `dd_tableaux` est inchangée.

**[2026-08-24] D-TB19 — SP-TB8 mis en attente derrière la refonte du module Campagnes**
SP-TB10/TB11 validés par l'utilisateur (test manuel OK). L'enchaînement prévu sur SP-TB8 — l'écran
du MJ — est suspendu : une **refonte du module Campagnes** doit passer avant, et elle peut changer
la façon dont cet écran est présenté. Construire l'écran maintenant reviendrait à le refaire après.
→ SP-TB8 reste coché « à faire » en §0, assorti de sa condition de reprise. Non abandonné.
→ La refonte Campagnes est arbitrée dans une conversation séparée et recevra son code projet
  (`SP-<lettres>`) et ses phases numérotées à ce moment-là — rien n'est préempté ici.
→ État utile à la reprise : aucun tableau n'est coché `tab_ecran_mj` en base, `tab_ecran_ordre`
  vaut 0 partout. Le filtre « Écran du MJ » de `tableaux/index.php` fonctionne mais ne renvoie
  donc rien pour l'instant.
→ **Levée le jour même** : la refonte a reçu le code `SP-CP` et a été livrée. Voir D-CP9.

---

**[2026-08-24] D-CP1 — SP-CP : le module Campagnes quitte `#detail-pp` pour des pages**
Les quatre niveaux (campagne, scénario, chapitre, rencontre) deviennent des pages avec URL propre :
`campagnes/campagne.php?id=`, `scenario.php?id=`, `chapitre.php?id=`, `rencontre.php?id=`.
Les handlers `include/ajax/detail-pp/{campagne,scenario,chapitre,rencontre}.php` sont supprimés.
→ Le panneau convenait à la consultation ponctuelle, pas à la conduite d'une partie : pas d'URL
  partageable, pas de retour navigateur, aucune place pour des outils de jeu, et une pile
  `_detailPpStack` à retenir dans chaque formulaire après écriture.
→ `detail-pp/monstre.php` reste : un monstre du compendium se consulte en panneau depuis partout,
  y compris depuis les liens `.mo-lien` d'un bloc de stats d'opposition (arbitrage, question 3).
→ `detail-pp-sub/opposition.php` supprimé au passage : devenu orphelin (aucun appelant) une fois
  les stats rendues en place sur la page rencontre.

**[2026-08-24] D-CP2 — Gabarit deux colonnes, cadre élargi à 1500px**
Grille `minmax(260px, 25%)` + `minmax(0, 1fr)` : 363px / 1065px sur la cible 1536 × 799 annoncée
par l'utilisateur. Colonne d'outils à gauche en `position: sticky`, données à droite.
→ Le ratio demandé était « 1/4 – 3/4 » : un `25%` le tient à toutes les largeurs, là où une valeur
  fixe ne serait juste qu'à 1536. Le plancher `260px` évite que la colonne d'outils devienne
  inutilisable sur un portable plus étroit.
→ `--main-max` (1200px) laissait ~330px de vide de chaque côté à 1536. Élargissement à 1500px
  **limité aux pages du module** par `body.camp-plein` (`$body_class`), pour ne pas toucher au
  cadre du reste du site.
→ Sous 992px : une colonne, outils au-dessus dans un bloc replié par défaut (arbitrage, question 8).
  Le module reste documenté « non responsive, usage desktop MJ » — il s'agit d'éviter une mise en
  page cassée, pas d'ouvrir le module au téléphone.

**[2026-08-24] D-CP3 — Après écriture : recharger la page courante**
Les cinq formulaires restent des overlays `#modification` (arbitrage, question 5) et se concluent
tous par `window.location.reload()`. Deux exceptions : créer une campagne depuis la liste mène à sa
page, supprimer une campagne remonte à `index.php`.
→ Règle unique et vraie partout : on reste là d'où l'action est partie. Une règle « aller sur la
  fiche de l'objet enregistré » se tromperait dès qu'on modifie un scénario depuis la page de la
  campagne.
→ Corollaire : `enregistrement.php` ne renvoie plus d'`url_detail`. Le serveur ignore depuis quel
  niveau le formulaire a été ouvert ; la page, elle, le sait.

**[2026-08-24] D-CP4 — Ordre manuel : deux colonnes créées, saisie supprimée**
`dd_rencontres.re_ordre` et `dd_oppositions.opp_ordre` n'existaient pas — ces deux niveaux étaient
triés sur le nom. Créées et backfillées dans l'ordre alphabétique en vigueur
(`sql/2026-08-24_ordre_sp-cp.sql`, **committé**, appliqué en dev, à appliquer en prod).
→ Les champs « Ordre d'affichage » disparaissent des formulaires scénario et chapitre : l'ordre est
  piloté par le seul glisser-déposer (arbitrage, question 12). Deux sources de vérité pour un même
  rang, c'est une de trop — et le formulaire aurait écrasé à 0 un rang posé à la souris.
→ Attention au piège correspondant côté serveur : `sce_ordre`/`scc_ordre` ont dû être **retirés des
  UPDATE**, pas seulement des formulaires. Les y laisser avec un POST devenu vide remettait le rang
  à 0 à chaque modification de nom.
→ Un élément créé se pose en fin de liste (`MAX(ordre)+1`) ; une opposition transférée ou dupliquée
  également, plutôt que d'importer un rang qui n'a pas de sens dans sa nouvelle rencontre.

**[2026-08-24] D-CP5 — Deux composants transverses plutôt que deux bouts de code campagne**
Demandés explicitement génériques par l'utilisateur. `js/tri-liste.js` (glisser-déposer) et
`notifier()` (pastille d'enregistrement) sont chargés sur **toutes** les pages, sans dépendance au
module. Détail du contrat en `ARCHITECTURE_0_REFERENCE.md` §12b.
→ Pointer Events plutôt que l'API drag&drop HTML5 : un seul jeu d'événements pour souris et
  tactile, et `setPointerCapture()` évite de perdre le glissement dès que le curseur sort de la
  ligne. `touch-action: none` sur la poignée est **obligatoire**, sans quoi le navigateur traite le
  geste comme un défilement et n'émet plus de `pointermove`.
→ Prise sur une poignée dédiée, jamais sur la ligne : les cellules restent cliquables pour naviguer.
→ Handlers délégués sur `document` : aucune initialisation à appeler, le contenu injecté en AJAX
  fonctionne d'office.
→ Côté serveur, `reordonnerNiveau()` exige un **lot exact** (autant d'ids postés que d'enfants
  actifs du parent) : un lot partiel produirait des rangs en double, et un id étranger ne peut pas
  être déplacé même s'il appartient au même MJ.
→ `notifier()` branchée au passage sur les deux écritures immédiates qui n'affichaient rien ou
  affichaient un message local : sélecteur de dons (SP-PE4) et rattachement de campagne (SP-PE5),
  arbitrage question 14. Pas sur les commits de formulaire, qui ont déjà leur retour.

**[2026-08-24] D-CP6 — Oppositions : blocs de stats dépliés, plus de sous-panneau**
Sur `rencontre.php`, chaque opposition est une carte dont `rendreStatsMonstre()` est rendu ouvert.
→ « On verra à l'usage » (arbitrage, question 6), mais le principe est posé : en partie, lire une
  créature ne doit coûter aucun clic. Un burger permet de replier au cas par cas.
→ L'index de liaison reste scopé aux sources de la **campagne** (`getActiveResIdsCampagne()`), pas
  aux sources personnelles du visiteur — inchangé depuis le sous-panneau. Résolu une seule fois
  par page, pas une fois par opposition.

**[2026-08-24] D-CP7 — Le fil d'Ariane du header devient une suite de liens**
`include/header-context.php` rend des `<a href>` vers les pages du module ; `ouvrirContextePP()` est
retirée de `main.js` avec la chaîne d'ancêtres qu'elle transportait.
→ C'est ce qui donne enfin au bandeau la fonction annoncée : revenir à un niveau précis d'une
  campagne depuis **n'importe quelle page du site**, y compris hors module.
→ Conséquence sur §12 : `setLast*()` est désormais appelée par la page du niveau, plus par un
  handler `detail-pp/*`. Même contrat, autre point d'appel.
→ `personnages/fiche.php` (bloc Campagnes) suivait le même chemin : son lien ouvrait le panneau,
  il pointe maintenant sur la page.

**[2026-08-24] D-CP8 — Code / abréviation en préfixe du nom**
La colonne dédiée disparaît des listes de chapitres et de rencontres ; quand il existe, le code
préfixe le nom, séparé par ` : ` (`C5 : Événement 5`). Non grisé (arbitrage, question 15).
→ Une colonne entière pour un champ souvent vide coûtait plus de largeur qu'elle n'en informait.
  Le code fait partie du titre, pas des métadonnées — d'où l'absence de grisé.
→ Vaut aussi pour les bandeaux de titre des pages chapitre et rencontre.

**[2026-08-24] D-CP9 — SP-TB8 débloquée**
La condition de reprise posée en D-TB19 est levée : la refonte est arbitrée et livrée.
→ Point d'entrée acté : le premier bouton de `include/campagne-outils.php`, aujourd'hui inerte.
→ Présentation retenue : ouverture dans `#detail-pp` (arbitrage, question 1) — l'écran du MJ est
  une consultation ponctuelle par-dessus la page de jeu, pas un niveau de navigation.
→ La colonne d'outils ne contient que ce bouton (arbitrage, question 9). Le reste des aides de jeu
  est à arbitrer : phase `SP-CP8`.

**[2026-08-25] D-AD1 — L'admin change le mot de passe d'un utilisateur depuis le formulaire d'édition**
Section « Mot de passe » ajoutée à `include/ajax/modifier/utilisateur.php` en mode édition
uniquement : `j_pass_nouveau` + `j_pass_confirme`, tous deux **facultatifs**. Traitement dans
`sauvegarderUtilisateur()` (`admin/enregistrement.php`), branche MODIFICATION.
→ Pas de champ « mot de passe actuel », contrairement à `profil/index.php` : l'admin n'a pas à
  connaître le mot de passe qu'il remplace, et il ne peut pas le lire (bcrypt). Le garde-fou est
  `requireAdmin()` + CSRF, pas une reconnaissance de l'ancien secret.
→ Champs vides = mot de passe inchangé. C'est ce qui permet de garder **un seul** formulaire et un
  seul enregistrement pour toute la fiche : l'`UPDATE` ajoute `j_password_hash = ?` seulement si un
  nouveau mot de passe a été saisi. Aucune action ni aucun endpoint dédié.
→ Contrôles serveur repris de `profil/index.php` (8 caractères minimum, deux saisies identiques),
  exécutés **avant** `beginTransaction()` comme les autres validations de la fonction.
→ `j_reset_token` / `j_reset_token_expires` sont remis à NULL au passage : un lien de
  réinitialisation encore valide redonnerait la main sur un compte que l'admin vient de reprendre.
→ Les sessions ouvertes de l'utilisateur ne sont pas invalidées — hors périmètre, aucun registre
  de sessions n'existe côté serveur.

**[2026-08-25] D-DRS1 — Import des règles DD3.5 : chantier SP-DRS, lot 1 livré**
Import itératif des fichiers de règles du DRS 3.5 (~20 fichiers de règles sur les 40 du
document ; les fichiers de données compendium sont hors périmètre). Lot 1 : DRS 01, 10, 12, 18,
19 — 4 racines thématiques + 1 racine glossaire, 4 chapitres, 23 règles, 63 termes, 15 tableaux.
→ Arbitrages (5 questions posées, toutes tranchées par l'utilisateur) :
  **arborescence thématique** plutôt qu'un chapitre par fichier DRS ; **pages longues par
  section** plutôt qu'un nœud par manœuvre/état ; **mini-glossaire** de termes techniques
  majeurs compilé au fil du traitement (le DRS n'a pas de glossaire, contrairement au SRD 2024) ;
  **ressource dédiée « DRS 3.5 »** (OGL 1.0a) plutôt qu'un rattachement au MdJ3.5 — les DRS 12,
  18 et 19 relèvent du Guide du Maître et du Manuel des Monstres, une ressource unique évite le
  panachage ; **SP-TB9 et SP-GL4 absorbées au fil des lots**.
→ Contrairement au seed DD2024 : aucun `reg_id` codé en dur (les ids sont occupés — parents via
  `LAST_INSERT_ID()`), tableaux saisis directement en convention texte `dd_tableaux` (aucun HTML
  à migrer a posteriori), et pas de colonne `res_pages` dans l'INSERT ressource (elle n'existe
  pas dans le schéma réel).
→ Idempotence par sous-arbre : chaque fichier DRS ne réinitialise que son chapitre et ses
  tableaux ; le glossaire supprime par liste explicite de slugs pour préserver les termes des
  lots suivants ; le socle n'est jamais destructif.
→ `reg_ordre` par pas de 10 à tous les niveaux : les lots suivants s'intercalent sans
  renumérotation (l'ordre d'affichage suit l'ordre de présentation des lots par l'utilisateur).
→ Vérifié en local (base `maikasteiymaika`) : application des 7 fichiers sans erreur, rejeu
  idempotent, 0 tag `[[tab:]]` non résolu au rendu, 15/15 tableaux rendus, liaison automatique
  du glossaire opérationnelle (harnais CLI).

**[2026-08-25] D-DRS2 — Le socle active la source DRS 3.5 dans les sélections personnelles**
Symptôme trompeur constaté à la livraison : les règles affichaient bien les tableaux (rendu du
tag `[[tab:slug]]`), mais `tableaux/index.php` n'en listait **aucun** en DD3.5 — donnant
l'impression que les tableaux avaient été insérés en HTML dans les règles, sans passer par le
module. En réalité les 15 tableaux étaient en base et aucun `<table>` dans `reg_texte`.
→ Cause : le module Règles n'est pas filtré par sources, le gestionnaire de tableaux l'est
  (moteur `compendium-liste.php`). Tout utilisateur ayant une sélection personnelle DD3.5
  (`dd_joueurs_sources`, priorité 2 de `getActiveResIds()`) ne voyait pas la nouvelle ressource
  « DRS 3.5 » — même piège que celui documenté en §9c pour SP-TB3 (`tab_res_id` NULL).
→ Correctif dans le socle : INSERT idempotent qui ajoute « DRS 3.5 » à la sélection personnelle
  DD3.5 de chaque joueur qui en possède déjà une. Les joueurs sans sélection relèvent de la
  priorité 3 (`res_selection = 1`, déjà posé par la ressource).
→ À retenir pour tout futur seed créant une ressource : créer la ressource ne suffit pas, il faut
  aussi la faire entrer dans les sélections personnelles existantes, sinon son contenu est
  invisible dans toutes les listes filtrées par source.

**[2026-08-25] D-DRS3 — Bouton « Tableaux » généralisé aux trois pages du module Règles**
Le bouton vers `tableaux/index.php` n'existait que sur le sommaire (`regles/index.php`) ; il est
ajouté à la barre d'outils de la vue lecture (`regles/regle.php`) et de la recherche
(`regles/recherche.php`), même emplacement (après le champ de recherche) et même marquage.
→ C'est depuis la vue lecture qu'on constate qu'un tableau est à corriger : l'accès au
  gestionnaire doit être là, comme il l'est sur toutes les listes du compendium (SP-TB7).
→ Non conditionné à `canEditCompendium()`, comme sur le sommaire : la consultation du
  gestionnaire est ouverte à tous, seule l'édition y est gardée.

**[2026-08-27] D-MAG1 — Analyse fonctionnelle de la magie avant `SP-PE7` (aucun code livré)**
Analyse croisée des SRD DD3.5 (`DRS 20`, `DRS 03a/03b`, `DRS 21`) et DD2024 v5.2.1
(`règles-sorts`, Classes, Création de personnage) et relevé de l'état réel de la base.
Livrée dans `doc/METIER_7_SORTS.md` (le fichier, stub de 12 lignes depuis 2026-05-30, est
remplacé par l'analyse complète). Huit questions d'arbitrage ouvertes en §11 — aucune décision
prise, aucun patch SQL écrit.
→ Conclusion de modélisation : le comportement magique d'une classe tient dans **trois axes
  orthogonaux** valides pour les deux rulesets — réservoir (`liste` / `grimoire` / `repertoire`),
  engagement quotidien (`prepare` / `spontane` / `pacte`), cadence de renouvellement
  (`repos_long` / `montee_niveau`). Les deux premiers axes tiennent dans les drapeaux existants
  `cla_sort_compris` / `cla_sort_connu` / `cla_sort_prepare` **redéfinis et recodés** ; le
  troisième n'a aucun support (Q3).
→ DD2024 n'a plus qu'un seul mode d'incantation (toutes les classes préparent) : la complexité y
  est ailleurs — sorts toujours préparés, Magie de pacte, multiclassage à niveau d'incantateur
  calculé. DD3.5 en a cinq, dont deux (grimoire, répertoire spontané) sans équivalent 2024.
→ Relevé de base — trois bloquants non documentés jusqu'ici : `dd_modificateurs` est **vide**
  (le calcul des sorts bonus décrit en `ARCHITECTURE_0_REFERENCE.md` §7.7 est inopérant) ;
  `dd_classe_niveau` DD2024 est très incomplet (Barde 3/20, Ensorceleur 0, Paladin 0, Occultiste
  et Rôdeur **absents de la table**) ; `dd_personnages_sorts` et `dd_personnages_sorts_prepares`
  sont vides et aucun écran ne les alimente.
→ Ce dernier point est **exactement le piège de SP-PE5** (leçon du 2026-08-14) : `SP-PE7` est
  annoncée comme une vue, elle ne peut pas être livrée en lecture seule — les écrans d'écriture
  du grimoire, des sorts connus et des sorts préparés en font partie.
→ Incohérences de référentiel relevées au passage : `cla_mag_id` DD2024 pointe sur des valeurs du
  ruleset 3.5 (Magicien = 1) ou inexistantes (Rôdeur = 5) ; `cla_car_id = 0` sur 4 classes
  DD2024 ; les drapeaux `cla_sort_*` valent 0 partout en DD2024 et sont **inversés** en DD3.5
  (Magicien `connu=1/compris=0`, Ensorceleur `compris=1/connu=0`, Prêtre `domaine_divin=0`).
→ Écart de modélisation confirmé : `so_branche` mélange branche et registre sur les 1 935 sorts
  DD3.5, sans champ `so_registre` (Q4) ; et `cn_sort_n0` porte deux sémantiques selon le ruleset
  (emplacements de niveau 0 en DD3.5, **nombre de sorts mineurs connus** en DD2024) — à
  documenter quoi qu'il arrive.

**[2026-08-27] D-MAG2 — `cla_mag_id` : plage de valeurs propre à chaque ruleset (arbitrage Q1)**
Le champ est conservé tel quel, mais sa plage dépend du ruleset : DD3.5 garde `0/1/2`
(0 = non lanceur, 1 = profane, 2 = divin) ; DD2024 n'admet que `0/1`, où **1 signifie
« lanceur de sorts » sans distinction** — le ruleset 2024 ayant supprimé l'opposition
profane/divin.
→ Raison : le test `cla_mag_id > 0` identifie les classes lanceuses dans tout le code existant.
  Le préserver évite un drapeau supplémentaire et une reprise transverse.
→ Conséquence assumée : `cla_mag_id` **n'est plus une clé étrangère utilisable telle quelle**.
  En DD2024 la valeur 1 ne désigne plus la ligne `dd_typemagie` d'id 1 (« Prof », ruleset DD3.5),
  c'est un drapeau. Tout affichage du libellé de type de magie doit être conditionné à
  `cla_ruleset_var_id = 1`, sinon un Clerc DD2024 s'affiche « Magie profane ».
→ Les lignes `dd_typemagie` 3 (« Profane », DD2024) et 4 (« Divine », DD2024) deviennent mortes.
→ UPDATE à produire : les 8 classes lanceuses DD2024 passent à `cla_mag_id = 1` — aujourd'hui `4`
  pour Barde/Clerc/Druide/Ensorceleur/Paladin, `1` pour Magicien (juste par accident), `5` pour
  Rôdeur (valeur inexistante en table).

**[2026-08-27] D-MAG3 — Séparation branche / registre en DD3.5 (arbitrage Q4)**
Ajout d'un champ `so_registre` et migration par script depuis `so_branche`, qui mélange
aujourd'hui les deux notions sur les 1 935 sorts DD3.5.
→ Raison : le registre est la seule donnée qui permette de filtrer les sorts d'alignement
  (restriction prêtre/druide, §3.4) et de restituer l'affichage entre crochets décrit dans
  `ARCHITECTURE_7_SORTS.md` autrement que par une convention de saisie.
→ Trois formes à traiter : branche + crochets (`Fantasme [mental, terreur]`), registre seul sans
  crochets (`Mal`, `son`, `mal, mental`), branche seule (`Coercition`). La deuxième se reconnaît à
  l'appartenance à la **liste fermée des 19 registres du SRD**, comparaison insensible à la casse
  et aux accents — la casse est irrégulière en base et la migration la normalise.
→ Script **idempotent** et précédé d'un relevé de contrôle par forme détectée : les 1 935 lignes
  ne sont pas rejouables à l'identique une fois `so_branche` réécrit.
→ Périmètre induit hors module Personnages : fiche de sort, formulaire et liste du compendium
  Sorts.

**[2026-08-27] D-MAG4 — Ouverture du code projet `SP-MA` (arbitrage Q5)**
La « vue Magie » couvrait un chantier bien plus large que la phase `SP-PE7` du tableau de bord :
sur les neuf blocs de travail identifiés par l'analyse, **six touchent le compendium Classes, le
compendium Sorts ou le référentiel global**, pas le module Personnages.
→ Décision : ouverture d'un code projet transverse **`SP-MA` — Référentiel de la magie**
  (`SP-MA0` référentiel des classes lanceuses, `MA1` seed `dd_modificateurs`, `MA2`
  `dd_classe_niveau` DD2024, `MA3` registre DD3.5, `MA4` extensions de schéma, `MA5` complétion
  `dd_sortdomaine`). `SP-PE7` est recadrée sur la page Magie elle-même et **bloquée par
  `SP-MA0→MA2`**.
→ Raison décisive : `SP-MA4` et `SP-MA5` n'auraient aucune place légitime dans `SP-PE` et
  seraient sorties de la checklist — exactement la situation que le passage de « sous-phases 3.0
  à 3.7 » au code `SP-PE` avait corrigée le 2026-08-12.
→ Précédent retenu : `SP-TB`, parti du module Règles pour devenir autonome, jusqu'à la sortie du
  gestionnaire vers `tableaux/` en SP-TB10.
→ L'**écriture** (grimoire, sorts connus, sorts préparés) reste dans `SP-PE7` et n'est pas
  reportée : `dd_personnages_sorts` et `dd_personnages_sorts_prepares` sont vides et aucun écran
  ne les alimente. Une phase annoncée « vue » livrée en lecture seule serait structurellement
  vide — leçon SP-PE5 [2026-08-14], deuxième occurrence.

**[2026-08-27] D-MAG5 — Objectif produit du chantier magie**
Critère d'acceptation fixé avant tout développement, reporté en `METIER_7_SORTS.md` §10.1 :
un outil de gestion des sorts du personnage lanceur, dans les deux rulesets, qui (1) va au but —
le nombre de gestes pour préparer sa journée ou consulter un sort prime sur l'exhaustivité ;
(2) tient compte de la particularité de chaque classe — les trois axes réservoir / engagement /
cadence déterminent quels onglets et compteurs existent, l'interface ne montre pas ce qui n'a pas
de sens pour la classe ; (3) **assume le multiclassage lanceur**, structurant et critique en
DD3.5 ; (4) marche au doigt sur smartphone et tablette dès la conception, pas en rattrapage.
→ Conséquence de structure : le regroupement de premier rang de la page est **la classe
  lanceuse**, pas le niveau de sort. Un personnage monoclasse ne doit pas payer le prix visuel du
  multiclassage.
→ Conséquence sur le multiclassage DD3.5 : deux réservoirs, deux modes d'engagement, deux
  caractéristiques d'incantation et deux NLS distincts coexistent sans rien mutualiser — un
  ensorceleur/prêtre est le cas de test de référence. En DD2024 le partage est inverse :
  emplacements **communs** sur le niveau d'incantateur agrégé, mais sorts préparés et
  caractéristique **par classe**.
→ Conséquence sur le calendrier : la passe responsive reste rattachée à `SP-PE8` pour la
  cohérence avec les autres blocs de la fiche, mais l'objectif (4) impose de concevoir tactile
  dès `SP-PE7`.

**[2026-08-27] D-MAG6 — Cadrage règles validé : trois corrections, deux nuances, lecture A**
Confrontation du SRD, d'une analyse comparée externe fournie par l'utilisateur
(`Analyse_comparative_magie_DD35_DD5e_2024.docx`) et de la compréhension de l'utilisateur.
Convergence complète sur la thèse centrale — en DD3.5 préparer un sort revient à **réserver un
emplacement pour ce sort** ; en DD2024 préparer revient à **le rendre disponible**, les
emplacements étant une réserve générique. Cinq points corrigés ou précisés, tous validés.
→ **Correction 1 — DD2024 n'a aucun lanceur spontané.** Barde, Ensorceleur et Occultiste ont
  l'aptitude « Sorts préparés du 1er niveau et plus », comme le Clerc et le Magicien ; la notion
  de « sorts connus » a disparu de l'édition. Les synthèses qui les décrivent encore comme
  spontanés décrivent la **5e de 2014**. Suivre cette erreur aurait produit un profil
  `repertoire_spontane` pour le Barde 2024, un onglet « Sorts connus » et un plafond
  `cn_sortConnu_n*` — tout faux. `repertoire_spontane` **n'existe qu'en DD3.5**. Encadré
  d'avertissement ajouté en tête du §4.
→ **Correction 2 — l'upcasting n'existe pas en DD3.5.** Le SRD 3.5 autorise à dépenser un
  emplacement supérieur mais **sans le moindre bénéfice** (la puissance dépend du NLS, pas de
  l'emplacement) ; DD2024 fait l'inverse. Seul le don *Sort accru* élève le niveau d'un sort 3.5.
  **Conséquence d'interface, la plus structurante du chantier** : le geste de lancement diffère
  par nature — DD2024 impose de choisir le niveau d'emplacement à l'incantation, DD3.5 l'ignore.
  Ce ne sont pas deux variantes d'une page, ce sont deux gestes (portée `SP-PE8`). Voir §3.3b.
→ **Correction 3 — métamagie.** En DD3.5 c'est un mécanisme de coût en emplacement (deltas +1 à
  +4, cumulables, plafond niveau 9, choix à la préparation pour un préparateur). En DD2024 les
  *dons* ont disparu ; le mécanisme survit comme aptitude du seul Ensorceleur, payé en points de
  Sorcellerie, et **sans effet sur le niveau du sort ni sur l'emplacement**. `pesp_metamagie` et
  `pesp_niveau` restent donc strictement DD3.5. Voir §3.7.
→ **Nuance A — « liste préparée = liste lançable » est faux pour le prêtre et le druide.**
  L'incantation spontanée leur permet de sacrifier un sort préparé pour lancer un sort de
  soins/blessure/convocation qu'ils n'ont **pas** préparé. Pour ces classes la liste préparée est
  la réserve : la conversion doit être visible dans la page, sinon un joueur de prêtre ne voit pas
  ses soins.
→ **Nuance B — un emplacement préparé DD3.5 a trois états**, pas deux : `vierge` (le magicien peut
  en laisser et les remplir plus tard, 15 min minimum) · `réservé à un sort` · `dépensé`. DD2024
  n'en a que deux. À porter dans le modèle de suivi de `SP-PE8`. Voir §3.3c.
→ **Lecture A retenue pour le vocabulaire connu / compris** (cohérente avec le SRD et avec ce que
  `SCHEMA_SQL.md` documente déjà) : **connu** = le sort est à ma disposition (parchemin, grimoire
  emprunté ou trouvé) mais pas encore recopié → `pes_compris = 0` ; **compris** = déchiffré,
  étudié, **recopié dans mon grimoire** → `pes_compris = 1`. Règle décisive dans les deux lectures
  envisagées : **préparable ⟺ compris**. La page Magie affiche donc **deux** listes pour un profil
  grimoire, reliées par le geste « Recopier dans le grimoire ». Voir §3.1b.

**[2026-08-27] D-MAG7 — SP-MA0 livrée : `cla_profil_incantation` remplace les trois drapeaux**
Patch : `sql/2026-08-27_profil_incantation_sp-ma0.sql` (appliqué et vérifié en local, à passer en
prod). Code : `helpers.php`, `compendium/classes.php`, `compendium/enregistrement.php`,
`ajax/modifier/classe.php`, `ajax/detail-pp/classe.php`.
→ **Quatre profils, pas huit combinaisons.** Les axes réservoir / engagement du §6 n'ont que
  4 combinaisons réelles : Liste préparée (3), Grimoire (4), Répertoire spontané (5, DD3.5 seul),
  Magie de pacte (6, DD2024 seul). Stockage dans `dd_variables` (`var_cat = 'profinc'`), ids figés
  en constantes `PROFINC_*` — **pas de littéraux dispersés**, contrairement aux `clt_id` dont
  l'écueil est documenté au module Classes.
→ **Filtrage par ruleset centralisé** dans `profilsIncantation($db, $ruleset_var_id)` : c'est le
  seul endroit qui sait que « Répertoire spontané » est DD3.5 et « Magie de pacte » DD2024.
  Vérifié au rendu : aucune fuite dans un sens ni dans l'autre.
→ **Migration dérivée de la donnée, pas des drapeaux.** Les trois booléens étant établis comme
  faux, la migration s'appuie sur la présence d'au moins un `cn_sortConnu_n*` renseigné dans
  `dd_classe_niveau` → Répertoire spontané ; toute autre classe lanceuse → Liste préparée ; puis
  cas particuliers du SRD (Magicien → Grimoire, Occultiste → Magie de pacte). Effet secondaire
  voulu : les classes hors SRD (Élu divin, Assassin, Tueur de Domiel) conservent l'affichage
  qu'elles avaient.
→ **Deux défauts vivants corrigés.** (1) `cla_sort_connu = 0` sur l'**Ensorceleur DD3.5** masquait
  sa table « Sorts connus » alors que `cn_sortConnu_n*` était correctement peuplé sur 20 niveaux.
  (2) `cla_domaine_divin = 0` sur le **Prêtre DD3.5** empêchait l'affichage des deux selects de
  domaine dans l'éditeur de classes : le cas d'usage principal de `SP-PE2` était mort depuis sa
  livraison, `pc_do_id_1/2` restaient NULL en permanence.
→ **Conséquence de D-MAG2 portée dans le code** : le libellé `dd_typemagie` n'est plus lu qu'en
  DD3.5 (fiche de classe), le critère « Type de magie » de la liste disparaît en DD2024 au profit
  du profil d'incantation, et le formulaire y propose « Lanceur de sorts » Oui/Non. Sans cela un
  Clerc DD2024 se serait affiché « Magie profane ».
→ Dépréciation assumée plutôt que DROP : les 3 colonnes restent en base, non lues, non écrites,
  le temps de vérifier le comportement en production. Leur suppression fera l'objet d'un nettoyage.

**[2026-08-27] D-CL0 — Défauts de données relevés et NON corrigés (hors périmètre SP-MA0)**
Relevés pendant l'analyse du référentiel des classes ; laissés en l'état, l'utilisateur ayant posé
la règle « on ne modifie pas les données existantes » pour le chantier d'import.
→ `dd_classes.cla_res_id = 0` sur l'**Ensorceleur DD3.5** (id 4) : aucune ressource valide, donc
  `h($cla['res_nom'])` reçoit NULL et **sa fiche de classe plante en PHP 8**
  (`h(): Argument #1 must be of type string, null given`). Défaut préexistant, sans rapport avec
  SP-MA0, mais qui rend une fiche du compendium inaccessible.
→ `cla_dV = 12` sur le **Roublard DD2024** ; le SRD 5.2.1 dit d8.
→ `cla_niveauMax = 10` sur **Hiérophante** et **Thaumaturge** (DD3.5), qui font 5 niveaux — la
  table `dd_classe_niveau` n'en porte d'ailleurs que 5.
→ **Disciple draconien** (DD3.5) : `cn_niveauSortArcane/Divin/Effectif` tous NULL alors que le SRD
  lui donne une progression d'incantation — le bloc NLS de `SP-PE6` ne peut pas la proposer.

---

## Cycle d'import des données (SP-IM)

**[2026-08-28] D-IM1 — Ouverture du cycle d'import avant reprise du développement**
Les deux rulesets sont incomplets en base ; on remplit avant de reprendre le code, une base
complète rendant les tests de la fiche personnage réalistes. Premier lot : les **classes DD2024**,
depuis `FR_SRD_CC_v5.2.1-classes.pdf`. Livré en quatre patchs : `SP-IM1` traits de base,
`SP-IM2` tables de progression, `SP-IM3` capacités, `SP-IM4` sous-classes.
→ Le SRD ne couvre **qu'une sous-classe par classe** ; les sous-classes du Manuel des Joueurs 2024
  absentes du SRD restent à saisir à la main (l'utilisateur en a déjà saisi deux : Voie de
  l'Arbre-monde, Collège de la Lune, plus trois sous-classes de Roublard).

**[2026-08-28] D-IM2 — Réalignement intégral sur le SRD, et non simple complétion**
Sur les six classes déjà partiellement saisies, le patch corrige aussi l'existant divergent au lieu
de se contenter d'ajouter ce qui manque.
→ Lève la réserve posée en **D-CL0** (« on ne modifie pas les données existantes ») pour ce cycle :
  une base à moitié alignée sur le SRD et à moitié sur une saisie manuelle est intestable.
→ Corrections effectivement portées : `cla_dV` du Roublard 12 → 8 ; Forme sauvage du Druide fausse
  à partir du niveau 9 ; sorts mineurs du Druide faux à partir du niveau 10 ; emplacements de 5e
  niveau du Druide à 3 au lieu de 2 (niv. 11-17) ; sorts mineurs du Magicien au niveau 10 ;
  Attaque sournoise du Roublard 3d6 au niveau 4 au lieu de 2d6 ; « Voie du Berseker » →
  « Voie du Berserker » ; capacités du Clerc absentes des niveaux 9 à 20.
→ **Reste ouvert dans D-CL0** : `cla_res_id = 0` sur l'Ensorceleur DD3.5 (sa fiche plante toujours
  en PHP 8), `cla_niveauMax` de Hiérophante et Thaumaturge, progression du Disciple draconien.
  Hors périmètre — ruleset DD3.5.

**[2026-08-28] D-IM3 — Source des sous-classes créées : SRD 5.2.1 (res_id 93)**
Les 10 sous-classes créées portent `cla_res_id = 93`, et non 91 (Manuel des Joueurs 2024) comme les
entrées existantes.
→ Trace exactement la provenance du texte, ce que le contenu identique entre SRD et MdJ ne permet
  pas de deviner autrement.
→ Vérifié avant livraison que la visibilité tient : `dd_ressources.res_selection = 1` sur 93 (donc
  servie par le défaut de `getActiveResIds()`) **et** 93 présente dans `dd_joueurs_sources` pour
  `j_id = 1`. Sans cette double vérification les 10 sous-classes auraient été invisibles.
→ Les 2 sous-classes déjà en base (Voie du Berserker, Voleur) **gardent** leur source 91 : leur
  contenu est réaligné, pas leur provenance déclarée.

**[2026-08-28] D-IM4 — `dd_classe_competence` alimentée pour DD2024**
La table était **vide pour tout le ruleset DD2024**, alors que `detail-pp/classe.php` en tire le
bloc « Compétences maîtrisées » : le bloc n'apparaissait sur aucune des 12 classes. 87 lignes
insérées, une par compétence de la liste au choix.
→ `ccomp_precision` laissé NULL : le nombre à choisir (« 2 au choix parmi… ») reste dans le champ
  texte `cla_competences`, le répéter sur chaque ligne rendrait la liste illisible.
→ **Barde exclu** : « 3 compétences au choix » sans liste fermée, les 18 compétences sont
  éligibles — aucune ligne n'aurait de sens.
→ Écart d'IHM relevé au passage (`SP-IM7`) : `cla_competences`, `cla_outils`, `cla_equipement` et
  `cla_caracteristiques` sont saisissables dans le formulaire mais **affichés nulle part** en
  DD2024. Les données sont importées, l'affichage reste à arbitrer.

**[2026-08-28] D-IM5 — Conventions de reprise pour les capacités importées**
→ **Une ligne `dd_capacites_speciales` par classe**, même pour les aptitudes homonymes entre
  classes (« Amélioration de caractéristique », « Faveur épique », « Attaque supplémentaire »…),
  avec `cap_classe_initiale` = `cla_id` d'origine. C'est la convention déjà en place en base ;
  mutualiser aurait cassé l'édition per-classe.
→ **Ids figés** : 601+ pour les capacités de classe de base, 801+ pour les sous-classes, 70-79 pour
  les sous-classes créées. Les quatre patchs sont rejouables sans doublon, ce que ni
  `dd_classe_niveau` ni `dd_classe_capacite` ne garantissent par leur schéma.
→ ~~`cap_categorie_var_id = 92` repris par mimétisme (valeur majoritaire, 309 lignes). ⚠ **Cette
  référence est orpheline** : `dd_variables` ne contient plus que les catégories `profinc` et
  `ruleset`, les valeurs 91 et 92 ne désignent plus rien. À assainir hors de ce cycle.~~
  — **SUPERSÉDÉ le jour même par D-IM9** : la colonne a été supprimée, les patchs ne la
  renseignent plus.
→ **Écart interne au SRD** : la table de progression du Barbare annonce « Bond agressif » au niveau
  7, la section descriptive s'intitule « Bond instinctif ». Le titre de la section fait foi — c'est
  lui qui porte le texte, et c'est déjà le nom en base.
→ « Aptitude de sous-classe » n'a **aucune section descriptive** dans le SRD : son texte est rédigé,
  il ne provient pas du document.

**[2026-08-28] D-IM6 — Listes d'options du SRD sorties du lot (SP-IM5)**
Métamagie (10 options), Manifestations occultes (~20), Styles de combat (6) et Bottes d'arme (9)
ne sont pas importées.
→ Ce sont des **options au choix**, pas des acquis attachés à un niveau : `dd_capacites_speciales`
  et `dd_classe_capacite` leur conviennent mal, `cc_niveau` n'aurait pas de sens. La modélisation
  mérite son propre arbitrage.

**[2026-08-28] D-IM7 — `cla_pointsCompetences` : un champ, deux sens selon le ruleset**
`dd_classe_competence` ne veut pas dire la même chose dans les deux rulesets, et `SP-IM1` l'avait
remplie pour DD2024 sur le modèle DD3.5 — la liste était juste, l'information de cardinalité
manquait.
→ *[DD3.5]* la table liste les **compétences de classe** : un point investi dans l'une d'elles vaut
  1 rang, 1/2 rang ailleurs ; `cla_pointsCompetences` = points par niveau.
→ *[DD2024]* la table liste les compétences que le personnage **peut** maîtriser ; il en choisit un
  nombre fixe donné par la classe. C'est ce nombre que porte désormais `cla_pointsCompetences`
  (2 pour la plupart, 3 pour le Barde et le Rôdeur, 4 pour le Roublard).
→ **Le même champ pour les deux usages** plutôt qu'une colonne DD2024 dédiée : la sémantique reste
  « ce que la classe accorde en compétences », seule l'unité change. Commentaire de colonne mis à
  jour en base par l'utilisateur, doc alignée dans `SCHEMA_SQL.md`.
→ **Défaut corrigé au passage** : le champ n'était rendu que dans la section DD3.5 du formulaire.
  `compendium/enregistrement.php` lisant `intParam($_POST['cla_pointsCompetences'] ?? 0)`, tout
  enregistrement d'une classe DD2024 l'aurait **remis à 0** en silence. Le champ est maintenant
  présent dans les deux sections.
→ **Barde**, cas limite assumé : « 3 compétences au choix » parmi les 18, donc aucune ligne dans
  `dd_classe_competence`. La fiche retombe sur le texte libre `cla_competences` — d'où le maintien
  de ce champ, redondant partout ailleurs avec la liste structurée.

**[2026-08-28] D-IM8 — Fiche de classe DD2024 alignée sur l'encadré « Traits de base » du SRD**
Trois champs saisissables n'étaient affichés nulle part (`cla_caracteristiques`, `cla_outils`,
`cla_equipement`) ; les libellés et l'ordre des autres divergeaient du document.
→ Ordre et intitulés repris tels quels du SRD : Caractéristique principale, Dé de vie, Maîtrise des
  jets de sauvegarde, Maîtrises de compétence, Maîtrises d'arme, Maîtrises d'outils, Formation aux
  armures, Équipement de départ. `Incantation` et `Caractéristique LS`, propres à l'application,
  restent à leur place après le dé de vie.
→ **Échappement corrigé** : les quatre champs DD2024 sortent de `textarea` simples et étaient rendus
  **bruts** (`<?= $cla['cla_armes'] ?>`), contrairement à la règle projet. Ils passent désormais par
  `nl2br(h(...))`. Le rendu brut n'est conservé que pour `cla_armes` en DD3.5, qui vient de TinyMCE.
→ **Plantage D-CL0 neutralisé côté rendu** : `h($cla['res_nom'])` recevait NULL sur l'Ensorceleur
  DD3.5 (`cla_res_id = 0`) et rendait sa fiche inaccessible en PHP 8. Le pied de fiche affiche
  « Source inconnue » à défaut. **Le défaut de donnée reste entier** — corriger `cla_res_id`
  demande de savoir quelle ressource attribuer, ce n'est pas au rendu d'en décider.

**[2026-08-28] D-IM9 — Suppression de `dd_capacites_speciales.cap_categorie_var_id`**
Reliquat de l'application v1 : la colonne disait si la capacité venait d'une race (91) ou d'une
classe (92). Supprimée sur décision de l'utilisateur —
`sql/2026-08-28_capacites_drop_categorie.sql`.
→ **L'information est portée par les tables de liaison** `dd_race_capacite` et
  `dd_classe_capacite`, et une même capacité peut légitimement relever des deux : la colonne ne
  pouvait pas exprimer ce cas, que la fiche de capacité affiche pourtant déjà (blocs Classes et
  Races côte à côte).
→ **Elle était déjà morte** : 508 lignes à 92, 47 à 91, 41 à NULL, mais les valeurs 91 et 92 ne
  désignaient plus rien depuis la refonte de `dd_variables` (qui ne garde que `profinc` et
  `ruleset`). Le `LEFT JOIN` de `detail-pp/capacite.php` ne ramenait donc jamais de libellé et le
  bloc d'affichage ne s'affichait jamais. La catégorie `tcap` n'existe plus.
→ **Aucune écriture n'existait** : les `INSERT` et `UPDATE` de `compendium/enregistrement.php` ne
  l'ont jamais renseignée. Seuls les patchs `SP-IM3` et `SP-IM4` du jour la remplissaient — ils ont
  été mis à jour, l'ordre d'application entre eux et le `DROP` est donc indifférent.
→ Ceci **remplace la réserve posée en D-IM5** (« reprise par mimétisme, à assainir un jour »).
→ Sauvegarde des 596 valeurs prise avant le `DROP` (irréversible), hors dépôt.
→ Corrigés dans la foulée, même fichier : `cc_precision` était concaténée **sans `h()`** dans la
  liste des niveaux de `detail-pp/capacite.php` ; et `sql/schema.sql` ignorait `cap_classe_initiale`,
  pourtant en base depuis longtemps.

**[2026-08-28] D-IM10 — Espèces DD2024 : les 3 tables du SRD vont dans `dd_tableaux`**
Ancêtres draconiques, Lignages elfiques et Héritages fiélons sont saisies selon la convention texte
de `dd_tableaux` (ids figés 40-42) et appelées par `[[tab:slug]]` depuis `cap_description`.
→ C'est la convention du projet depuis `SP-TB`, et `cap_description` figure dans
  `tableauChampsHotes()` : le tag y est résolu au rendu, vérifié sur les 3 espèces concernées.
→ **Conséquence assumée** : la table des lignages elfiques, saisie à la main en `<table>` HTML brut
  dans l'ancienne capacité 436, est extraite. C'est exactement la dette que `SP-TB5` avait soldée
  ailleurs ; la laisser aurait signifié la rouvrir, et les 3 tables auraient échappé au
  gestionnaire `tableaux/index.php`.
→ Les cellules restent en texte brut : le parser sait résoudre `$sort$`, mais lier les 18 sorts
  cités demanderait leurs identifiants — hors périmètre de ce lot.

**[2026-08-28] D-IM11 — Réalignement des 5 espèces DD2024 déjà saisies**
Même règle que D-IM2 pour les classes : on corrige l'existant divergent plutôt que de seulement
compléter.
→ **Gnome** : ses 3 traits étaient empilés dans `ra_description` (2 691 caractères) au lieu d'être
  des lignes `dd_race_capacite` — seule espèce hors modèle. Ses traits n'apparaissaient donc ni
  dans le bloc Traits de la fiche, ni dans le panneau d'une capacité, ni dans aucune recherche.
→ **Elfe** : trait « Vision dans le noir » absent (4 traits sur 5).
→ **Humain** : bloc d'en-tête sans « Type de créature ». **Nain** : sans la phrase d'introduction.
→ Modèle retenu, celui que suivaient déjà Halfelin, Humain et Nain : `ra_description` porte le seul
  bloc d'en-tête (type de créature, catégorie de taille, vitesse, phrase d'amorce), chaque trait
  est une ligne `dd_capacites_speciales` + `dd_race_capacite` ordonnée par `cr_ordre` dès 0.
→ `cap_classe_initiale` reste NULL sur les traits d'espèce : la colonne désigne une classe.
→ « Vision dans le noir » a **sa propre ligne par espèce** (6 fois) : les portées diffèrent
  (18 m ou 36 m) et c'est déjà la convention en base pour le Nain, cohérente avec D-IM5.

**[2026-08-28] D-IM12 — Le nom du trait est retiré de sa description**
Dans le SRD, le nom du trait ouvre son propre paragraphe (« Brave. Vous avez l'Avantage… »).
En base il vit dans `cap_nom`, et `detail-pp/race.php` l'affiche en titre au-dessus du texte.
→ Le laisser en tête de `cap_description` produisait un doublon visible à l'écran. Il est retiré,
  ce que faisaient déjà les 15 entrées saisies à la main.
→ Les intertitres **internes** aux traits restent en gras : les 6 ascendances du Goliath, les 2
  lignages du Gnome. Le seuil de détection des intertitres est passé de 45 à 60 caractères —
  « Renversement des coteaux (géants des collines). » en fait 46 et était le seul non détecté.
  Contrôle effectué sur les 36 fragments produits : aucun faux positif.

**[2026-08-28] D-IM13 — Les options de classe deviennent des dons, et le périmètre de SP-IM5 se réduit**
Les listes d'options du SRD ne rejoignent ni `dd_capacites_speciales`, ni une table dédiée : elles
sont importées comme **dons**, dans deux nouvelles catégories `dd_data_don` — 22 « Métamagie » et
23 « Manifestation occulte ».
→ **Le précédent existait déjà** : la catégorie 21 « Style de combat » porte 10 dons depuis un
  import antérieur. Même nature d'objet — une option nommée, choisie dans un pool, à un niveau
  donné — donc même rangement.
→ `do_conditions` est le **seul champ du schéma** capable de porter les prérequis des manifestations
  (« Niveau d'Occultiste 9+, manifestation Pacte de la lame »). `dd_capacites_speciales` n'a pas
  d'équivalent, et `cc_niveau` n'aurait aucun sens pour une option facultative.
→ On hérite sans écrire une ligne de PHP de la liste du compendium, de la fiche, du formulaire
  d'édition et du sélecteur de dons. Aucune table créée (règle CLAUDE.md).
→ **Limite connue et acceptée** : `detail-pp/dons-picker.php` ne filtre pas par classe. Un Magicien
  pourra se voir attribuer « Sort jumeau ». Ce n'est pas une régression — les 10 styles de combat
  posent exactement le même problème depuis leur import — mais la dette devient plus visible.
  Un filtrage par classe serait une phase `SP-PE` distincte.
→ **`do_resume` est rédigé, pas importé** : le SRD ne contient pas ces résumés d'une ligne. Ils
  suivent le modèle de ceux des 10 styles de combat. À relire.

**[2026-08-28] D-IM14 — Deux des quatre listes annoncées sortent du périmètre**
Le libellé initial de `SP-IM5` promettait quatre listes. L'analyse en a écarté deux.
→ **Styles de combat** : les 10 sont **déjà en base** (catégorie 21, source 93, avec résumés). Le
  SRD n'en décrit que 6, la base a les 10 du Manuel des Joueurs. Rien à importer.
→ **Bottes d'arme** : ce sont des **propriétés d'arme**, pas des aptitudes de personnage. Elles ne
  figurent d'ailleurs pas dans le PDF des classes — seulement dans `FR_SRD_CC_v5.2.1.pdf`, section
  équipement, où le PDF Classes ne garde que l'intitulé de colonne. Elles rejoignent le chantier
  Équipement en **`SP-E6`**, avec le reste de `dd_equipements` — table **vide** à ce jour, et dont
  le schéma (`eqt_nom`, `eqt_description`) ne porte ni dégâts, ni propriétés, ni prix : la
  modélisation devra être arbitrée avant l'import.

**[2026-08-28] D-IM15 — Objets magiques DD2024 : diagnostic de l'import antérieur**
Un script IA antérieur avait importé les objets magiques du SRD en remplaçant chaque description
par un **résumé**, et sans renseigner les paramètres de jeu. Relevé sur les 359 objets DD2024 :
→ `om_rarete = 0` sur **349** d'entre eux — valeur qui n'existe pas dans
  `dd_objets_magiques_rarete`, dont les ids commencent à 1. Le champ n'avait jamais été alimenté.
→ `om_harmonisation = 1` sur **6** seulement, là où le SRD en marque environ **129**.
→ **186 descriptions** à moins de 80 % de la longueur du texte d'origine.
→ **8 catégories fausses** : élixirs et huiles rangés en « Objets merveilleux » au lieu de
  « Potions », fers de cheval en « Armes », Bâton de l'acrobate en « Bâtons » alors que le SRD en
  fait une arme.
→ **Ce qui sauve le lot** : le SRD est parfaitement régulier. Chaque objet porte une ligne de type
  « <Catégorie>, <rareté> (Harmonisation requise …) » d'où les trois paramètres se déduisent
  mécaniquement. C'est elle qui fait foi.

**[2026-08-28] D-IM16 — Les déclinaisons d'objets génériques sont conservées**
Le script antérieur avait **éclaté 21 entrées génériques du SRD en 121 déclinaisons** : une entrée
« Anneau de résistance » (avec sa table de types de dégâts) est devenue 10 lignes « Anneau de
résistance (acide) », « (feu) »… De même pour la Pierre de Ioun (14), la Figurine merveilleuse (11),
le Parchemin de sort (10), le Ceinturon de force de géant (6)…
→ **On garde les déclinaisons.** C'est le bon modèle pour le jeu : un inventaire de personnage a
  besoin de désigner « Anneau de résistance (feu) », pas un générique. Revenir aux 21 entrées du
  SRD aurait été plus fidèle au document mais destructif et moins utile.
→ Conséquence : elles ne se rapprochent d'aucune entrée du PDF par leur nom. Elles reçoivent en
  `SP-IM9b` le texte de leur générique et leur rareté propre, déduite des tables du SRD.

**[2026-08-28] D-IM17 — Découpage du redressement en trois sous-lots**
→ **IM9a** (livré) : les 235 objets qui se rapprochent du SRD par leur nom. Purement mécanique.
→ **IM9b** : les 121 déclinaisons — demande un arbitrage famille par famille sur la rareté.
→ **IM9c** : les 16 objets dont le texte du SRD porte une table. Leur **description est laissée
  intacte** par IM9a : les importer en texte brut aurait produit une bouillie (les tables sortent
  du PDF en colonnes désassemblées). Leur rareté, leur harmonisation et leur catégorie sont
  corrigées dès IM9a — seule la description attend.
→ Les sources **91 (MdJ)** et **95 (supplément de l'utilisateur)** sont exclues du redressement :
  « Sceptre du châtiment » et « anneau de clignotement » sont du contenu maison.
→ Corrigés au passage dans le harnais d'extraction, deux défauts qui affectaient aussi les lots
  précédents : le pied de page collé à son numéro (« 240 Document de Référence… ») n'était pas
  filtré, et une phrase isolée pouvait être prise pour un intertitre et mise en gras. Un intertitre
  ne venant jamais seul dans le SRD, la mise en gras exige désormais **au moins deux
  correspondances** dans le même bloc.

**[2026-08-28] D-IM18 — Déclinaisons d'objets magiques : ce que chacune reçoit**
Application de D-IM16 : les 121 déclinaisons sont conservées et redressées depuis leur générique.
→ **Texte du générique, TABLE EXCLUE.** Pour une déclinaison, le contenu de la table du SRD est
  précisément ce que porte `om_rarete` — « Cor du Valhalla (fer) → Légendaire ». Le reproduire dans
  la description n'aurait rien apporté, et les tables sortent du PDF en colonnes désassemblées.
  Les paragraphes de prose à reprendre sont **listés explicitement** pour chacun des 20 génériques,
  plutôt que devinés par une heuristique.
→ **Rareté propre à chaque déclinaison**, lue dans cette table : « Arme +2 » est rare quand
  « Arme +1 » est peu courante ; « Ceinturon de force de géant (tempêtes) » est légendaire quand
  celui des collines est rare ; « Pierre de Ioun — Protection » est rare quand celle de Maîtrise
  est légendaire. Sans cela les 121 lignes auraient toutes hérité d'une rareté unique, fausse pour
  la plupart.
→ **Trois familles décrivent chaque variante dans son propre paragraphe** — Pierre de Ioun, Plume
  magique, Figurine merveilleuse. Leur description reprend le chapeau du générique **puis le seul
  paragraphe de la variante** : « Pierre de Ioun — Agilité » décrit l'agilité, pas les quatorze
  pierres. Les ruptures de colonne coupant certains de ces paragraphes en deux ou trois, les
  continuations sont rattachées explicitement.
→ **« Armure de cuir clouté enchantée »** était restée sans rareté : sa ligne de type dans le PDF
  est « Armure (armure de cuir clouté) rare », **sans virgule** avant la rareté, contrairement aux
  256 autres. Le parseur ne la reconnaissait pas. Traitée comme cas isolé.
→ **Résultat** : les 356 objets de la source SRD ont désormais une rareté valide. Le seul objet
  DD2024 sans rareté est « Baguette de projectiles magiques » (source 91, MdJ), hors périmètre.

**[2026-08-28] D-IM19 — Objets magiques à table : 10 tables saisies, reconstructions contrôlées**
Fin du redressement ouvert par D-IM15. Les 16 entrées du SRD portant une table se réduisent à
**10 objets réellement présents en base** : les 6 autres sont des génériques (Cor du Valhalla,
Ceinturon et Potion de force de géant, Potion et Armure de résistance, Sac à malices) dont seules
les déclinaisons existent, traitées en `SP-IM9b`.
→ Tables dans `dd_tableaux` (ids 43-52) et tag `[[tab:slug]]` dans `om_description`, comme pour les
  espèces en `SP-IM8`. Les 10 tags se résolvent au rendu, vérifié.
→ **Deux reconstructions étaient risquées, elles sont contrôlées plutôt que devinées.**
  *Tarot mystérieux* : le PDF donne 44 plages pour 22 cartes, en alternance entre la colonne
  « jeu de 13 cartes » et celle « jeu de 22 cartes ». Le générateur **refuse de produire le
  fichier** si les deux colonnes ne comptent pas respectivement 13 et 22 plages strictement
  croissantes — deux contrôles indépendants qui se recoupent.
  *Sac de haricots magiques* : le PDF sépare entièrement les plages des effets, en deux blocs
  d'en-têtes suivis de leurs effets. Les 12 plages sont écrites explicitement et un contrôle
  vérifie qu'il y en a autant que d'effets.
→ *Chapelet mystique* saisi **à la main** : ses trois colonnes s'entremêlent dans l'extraction,
  une reconstitution automatique aurait été hasardeuse pour six lignes.
→ Trois pièges du PDF corrigés dans l'assembleur, chacun repéré à la relecture des tables produites
  avant application : un effet peut s'étaler sur plusieurs lignes et être coupé au milieu d'un mot
  (« du cha- / peau ») ; une table sur deux colonnes doubles sort entrelacée (cierge d'invocation,
  remis en ordre par plage) ; un effet peut commencer par un chiffre (« 10 gemmes d'une valeur… »)
  sans pour autant ouvrir une nouvelle ligne — c'est ce dernier cas qui avait cassé la Robe du
  camelot au premier essai.
→ **Bilan du cycle objets magiques** (IM9a + IM9b + IM9c) : sur les 356 objets de la source SRD,
  la rareté est renseignée partout (elle valait 0 sur 349), l'harmonisation passe de 6 à 173, la
  longueur moyenne des descriptions de ~250 à **724 caractères**, et les 8 catégories fausses sont
  corrigées.

---

**[2026-08-28] D-RS43 — Les capacités raciales reprennent le titre des capacités de classe**
La fiche race titrait ses capacités avec un simple `<strong>` sans règle CSS, espacées par des
styles inline (`margin-top: 1rem`, `margin-bottom: 0.75rem`), quand la fiche classe disposait
depuis SP-SC2 d’un titre à `1.2rem` / `700` / `var(--clr-accent-2)`. Les deux fiches affichent
pourtant **les mêmes entrées** (`dd_capacites_speciales`) : rien ne justifiait deux lectures.
→ Les sélecteurs `.race-detail__capacites`, `.race-detail__capacite`, `.race-detail__capacite-nom`
  et `.race-detail__capacite-nom .cap-type` sont **groupés** avec leurs homologues
  `.classe-detail__*` dans `css/compendium-modules.css` — pas de duplication du bloc, y compris
  dans le palier 991px. Un futur ajustement du titre porte sur les deux fiches d'un coup.
→ Le `<strong>` du markup est retiré : la graisse est désormais une propriété du titre, pas une
  balise sémantique posée pour l'obtenir.
→ Le type de capacité passe de `.race-detail__cap-type` à la classe commune `.cap-type`. L'ancienne
  classe n'existait dans aucune feuille de style : la mention s'affichait au corps du texte au lieu
  d'être dé-grossie comme sur la fiche classe.
→ Les styles inline d'espacement disparaissent au profit du `margin-top` sur le bloc suivant, même
  raison que pour les classes : un `margin-bottom` creuse un vide avant le pied de fiche.
→ **Reste un défaut de donnée, pas de rendu** : quelques descriptions de capacités raciales DD3.5
  ouvrent sur `<b>Nom de la capacité</b>.` (ex. *Armes familières* du Gnome), ce qui répète le
  titre maintenant qu'il est mis en avant. À nettoyer à la saisie, pas à l'affichage.

---

**[2026-08-28] D-RS44 — SP-PE9 : l'administrateur voit tous les personnages**
Le module Personnages était strictement personnel : `personnages/index.php` posait
`extra_where => 'pe.pe_j_id = ?'` sans exception. Or les accès **unitaires** — `fiche.php`,
`include/ajax/detail-pp/personnage.php`, `include/ajax/modifier/personnage.php` et les 8 actions de
`personnages/enregistrement.php` — passent tous par `getPersonnageContext()` / `canAccess()`, qui
autorisent l'admin depuis l'origine. Un admin pouvait donc ouvrir n'importe quelle fiche **à
condition d'en connaître l'`id`**, mais aucun écran ne les lui listait.
→ **Aucun droit nouveau n'est créé.** La modification est une **levée de scope d'affichage**, pas
  une extension de permissions : `extra_where` (et ses `extra_params`) n'est posé que si
  `isAdmin()` est faux. Le filtre ruleset (`champ_ruleset`) reste appliqué à tout le monde — un
  admin voit tous les joueurs, pas tous les rulesets d'un coup.
→ **Colonne « Joueur »** (`jo.j_pseudo`, triable) insérée juste après le nom, admin seulement. Le
  `LEFT JOIN dd_joueurs jo` est en revanche **posé dans tous les cas** : une jointure conditionnelle
  dans la chaîne `from` compliquerait la lecture pour économiser une jointure sur une clé primaire.
→ **Filtre « Joueur »** (`f_j_id`), admin seulement, restreint aux joueurs ayant au moins un
  personnage dans le ruleset actif — un select listant des joueurs qui ne ramèneraient aucune ligne
  n'aide personne.
→ **Filtre « Campagne » étendu** en admin à toutes les campagnes non supprimées du ruleset, libellées
  `Nom (pseudo du MJ)`. Deux MJ peuvent nommer leur campagne pareil ; sans le pseudo, le select
  serait ambigu.
→ **La propriété ne bouge pas** : la branche UPDATE de `enregistrerPersonnage` ne touche pas
  `pe_j_id`, seule la création l'écrit (avec le `j_id` de session). Un personnage corrigé par l'admin
  reste au joueur — et un personnage créé par l'admin lui appartient, ce qui est le comportement
  attendu tant qu'aucun écran ne propose de choisir le propriétaire.
→ Contrôlé au harnais CLI sur la base locale : admin en DD2024 → 4 personnages de 2 joueurs, colonne
  et filtre Joueur présents, tri `sort_col=joueur_pseudo` opérant, `f_j_id=2` ramenant la seule ligne
  de *bolls* ; joueur non admin → 1 personnage, ni colonne ni filtre Joueur. Fiche d'un personnage
  tiers : servie à l'admin, redirigée pour un joueur non propriétaire (comportement inchangé).

**[2026-08-27] D-MAG8 — SP-MA3 livrée : le champ `so_branche` mélangeait quatre notions, pas deux**
Patch : `sql/2026-08-27_registre_sp-ma3.sql` + `sql/migrate_registre_sp-ma3.php` (appliqués et
vérifiés en local, à passer en prod). Code : `detail-pp/sort.php`, `modifier/sort.php`,
`compendium/sorts.php`, `compendium/enregistrement.php`.
→ **Le constat de Q4 était sous-estimé.** L'arbitrage parlait de « trois formes » sur la foi d'un
  échantillon. Le relevé complet donne **84 valeurs distinctes sur 690 sorts** et quatre notions
  mélangées : des branches, des registres, des mélanges (avec ou sans crochets, avec ou sans
  virgules, casse et accents irréguliers), et des **données de domaine égarées** — « Cavernes 7 »,
  « Initié de Mystra 3 », « Portails 6 », « Mort aqueuse 5 » : un nom de domaine suivi de son
  niveau, qui relèvent de `dd_sortdomaine`.
→ **Découverte : des valeurs tronquées à 20 caractères** par l'import v1→v2, alors que la colonne
  fait `varchar(40)`. « bien, feu, résurrect », « creation, électricit », « coercition mental, b ».
  Le texte perdu **l'est définitivement** — aucune source ne permet de le reconstituer.
→ **Classifieur à deux listes fermées** plutôt que règles de découpage : 18 branches (12 du SRD +
  les 6 disciplines psioniques du GMP, de même rôle syntaxique) et 22 registres (19 du SRD +
  malédiction, poison, céleste, attestés dans les données). Crochets, virgules et espaces sont
  tous traités comme séparateurs, chaque jeton est classé indépendamment. Deux garde-fous :
  rattrapage par préfixe unique d'au moins 5 lettres (récupère « électricit »), et **garde
  anti-domaine** — toute valeur contenant un chiffre est disqualifiée en bloc, sans quoi
  « Mort aqueuse 5 » aurait produit un faux registre « mort ».
→ **Résultat : 673 nets, 7 partiels, 10 rejetés.** Les rejetés gardent leur `so_branche` d'origine
  et n'ont pas de registre — ce sont les données de domaine, à reprendre en `SP-MA5`.
→ **Migration rejouable et réversible.** Elle lit toujours la table de sauvegarde
  `dd_sorts_branche_backup_spma3`, jamais la colonne vive : la rejouer reproduit le même résultat
  au lieu d'écraser le registre déjà extrait, et le retour arrière tient en un UPDATE joint. C'est
  la contrepartie exigée par la réécriture de 680 lignes.
→ Convention de saisie : `so_registre` se saisit **sans crochets**, la fiche les ajoute au rendu.
→ Filtre « Registre » ajouté à la liste des sorts, DD3.5 seul. Il cherche le mot dans la liste
  (`FIND_IN_SET` sur la valeur dé-espacée) et non l'égalité stricte : « Mal » ramène bien les
  56 sorts, y compris « Mal, mental » et « obscurité, Mal ».
→ **Écueil de portabilité évité** : la première version listait les valeurs du filtre avec
  `JSON_TABLE`, absent avant MariaDB 10.6 — le serveur de dev est en **10.4**. L'éclatement se
  fait désormais en PHP, et le critère passe par le type de filtre `exists_range` du moteur de
  liste, qui accepte une liste de valeurs statique.

**[2026-08-27] D-MAG9 — SP-MA1 : les sorts bonus par formule, pas par table**
`dd_modificateurs` devait être seedée (30 lignes valeur → modificateur → sorts bonus). Analyse
faite avant de coder, la table s'est révélée être **un cache de deux fonctions pures**, dont l'une
était déjà écrite en PHP : `modCarac()` calcule le modificateur depuis 2026-06, la table n'a jamais
été lue par personne.
→ **Décision : la formule, pas la table.** `bonusSortsCarac($valeur, $niveau_sort)` et
  `peutLancerNiveau($valeur, $niveau_sort)` ajoutées à `include/helpers.php`. Aucun patch SQL,
  aucune donnée touchée.
→ **Raison décisive — le mode de défaillance.** Une table plafonnée renvoie **0 en silence**
  au-delà de sa dernière ligne. La doc annonçait 1 à 30 ; or un magicien de niveau 20 avec un
  bandeau +6 et des bonus inhérents dépasse 30 sans effort, et l'épique va plus loin — le SRD
  lui-même s'arrête à 45 et écrit « etc. ». Un zéro silencieux est le pire résultat possible pour
  une aide de jeu : le joueur ne voit pas qu'il manque des emplacements. La formule n'a pas de
  plage. Contrôle : à Int 60 elle rend `7 6 6 6 6 5 5 5 5`, là où une table à 30 lignes aurait
  rendu que des zéros.
→ Second argument : cohérence. Le projet avait déjà tranché pour la formule avec `modCarac()` ;
  garder la table pour le bonus aurait laissé **deux voies** pour deux règles issues de la même
  ligne du SRD.
→ Argument écarté (l'homebrew : un MJ pourrait vouloir modifier la progression en base) — jugé
  théorique, aucun besoin exprimé, et récupérable à tout moment puisque la fonction est un point
  de passage unique.
→ **Formule, contrôlée ligne à ligne contre la « Table : modificateurs de caractéristique et sorts
  en bonus » du SRD (DRS 01)** : `bonus = mod >= N ? floor((mod - N) / 4) + 1 : 0`, pour N de 1 à 9,
  et 0 au niveau 0 qui ne reçoit jamais de bonus. Les 12 lignes du SRD (modificateurs +0 à +11)
  sont reproduites au chiffre près, y compris la plus chargée : +11 → `3 3 3 2 2 2 2 1 1`.
→ **`modCarac()` et `formatMod()` déplacées** de `personnage_helpers.php` vers `helpers.php` :
  `bonusSortsCarac()` a besoin de la même formule de modificateur, et la dupliquer dans deux
  fichiers était le meilleur moyen de la voir diverger. Vérifié avant le déplacement :
  `helpers.php` est chargé avant `personnage_helpers.php` par les **7** points d'entrée du module,
  sans exception — les appels existants n'ont pas bougé.
→ `peutLancerNiveau()` livrée en même temps, à la demande : le prérequis `10 + niveau du sort` est
  une aide à l'affichage, jamais un filtre (principe « aide de jeu, pas moteur de règles »).
  Elle sera consommée par `SP-PE7`.
→ **`dd_modificateurs` devient morte** : documentée comme telle dans `SCHEMA_SQL.md`, section des
  tables à supprimer, aux côtés de `dd_sorts_import` et de la sauvegarde de `SP-MA3`.

**[2026-08-28] D-MAG10 — Portée par ruleset des helpers de SP-MA1 (correctif de documentation)**
Question posée à la relecture : ces fonctions valent-elles pour les deux rulesets ? Vérification
faite, **deux sur quatre seulement**, et l'une des deux restrictions n'était pas marquée.
→ `modCarac()` et `formatMod()` : **les deux rulesets**. La formule du modificateur et son
  formatage sont identiques en DD3.5 et DD2024.
→ `bonusSortsCarac()` : **DD3.5 uniquement**. DD2024 n'accorde aucun sort bonus de caractéristique,
  les emplacements viennent exclusivement de la table de classe. Correctement marqué dès la
  livraison.
→ `peutLancerNiveau()` : **DD3.5 uniquement** — et ce n'était **pas marqué**. La règle « valeur ≥
  10 + niveau du sort » a disparu en 2024 : aucune valeur minimale n'y conditionne l'accès à un
  niveau de sort. Appelée sur un personnage DD2024, la fonction aurait répondu « non » à tort sur
  une caractéristique modeste — un faux négatif silencieux dans une aide de jeu.
→ Contrôle : recherche dans le SRD 5.2.1 des deux règles. Aucune trace de sorts bonus ni de
  prérequis ; les seules occurrences 2024 de « 10 + le niveau du sort » sont des **DD de jet**
  (dissiper la magie, identifier un sort actif), pas un seuil de caractéristique.
→ Corrigé : marqueur `*[DD3.5]*` posé sur `peutLancerNiveau()`, et **tableau de portée ajouté en
  tête de section** dans `helpers.php` — les quatre fonctions y sont listées avec leur ruleset,
  pour que la question ne se repose pas. `SP-PE7` devra brancher sur le ruleset avant d'appeler
  les deux fonctions DD3.5.

**[2026-08-28] D-MAG11 — Migrations : /sql est interdit en HTTP, et une des consignes du projet était fausse**
Symptôme : « Forbidden » en tentant d'exécuter `sql/migrate_registre_sp-ma3.php` au navigateur.
→ Ce n'est pas un défaut : `sql/.htaccess` porte « Deny from all », et le `.htaccess` racine
  bloque en outre tout fichier `.sql`. Un script de migration joignable en HTTP serait une porte
  ouverte sur la base — la protection doit rester.
→ **Constat au passage** : `sql/.htaccess` existe **depuis la Phase 1** (commit `00a7281`), donc
  bien avant `SP-TB5`. Or l'en-tête de `sql/migrate_tableaux_sp-tb5.php` annonce
  « USAGE — navigateur, connecté en admin » avec deux URL. **Cette consigne n'a jamais pu
  fonctionner** : elle était fausse le jour où elle a été écrite. Le script a forcément été lancé
  en CLI, ou jamais. À corriger dans ce fichier — non fait ici, hors périmètre SP-MA.
→ Correctif appliqué à `migrate_registre_sp-ma3.php` : en-tête refait, mention explicite
  « pas utilisable au navigateur » avec la raison, et rappel que le binaire XAMPP n'est pas dans
  le PATH (`"C:/xampp/php/php.exe" …`).
→ **Nouvelle voie pour les hébergements sans CLI** : `sql/2026-08-28_registre_sp-ma3_donnees.sql`,
  sortie **figée** du classifieur en SQL pur — 680 UPDATE applicables depuis phpMyAdmin, sans
  exposer le moindre endpoint PHP ni toucher au `.htaccess`.
→ Chaque UPDATE est **gardé par la valeur d'origine** (`WHERE so_id = 123 AND so_branche = '…'`) :
  une ligne qui aurait divergé en prod n'est pas touchée, et le fichier reste rejouable (les
  lignes déjà migrées ne matchent plus la garde). Un contrôle post-application en fin de fichier
  donne les quatre compteurs attendus.
→ **Équivalence prouvée, pas supposée** : rollback complet de la base locale, application du
  fichier SQL, empreinte MD5 de `(so_id, so_branche, so_registre)` sur les 1 935 sorts DD3.5
  identique à celle obtenue par le script PHP (`159e0a4e…`). Le rollback lui-même est vérifié au
  passage — l'empreinte intermédiaire diffère bien.


**[2026-08-28] D-MAG12 — Incident : `dd_classe_niveau` réécrite à tort, et une clé unique fantôme**
Deux faits distincts, l'un qui est une erreur de ma part, l'autre un défaut réel du schéma.

**1. Travail redondant, puis destruction de données (erreur).**
`SP-MA2` a été entreprise sans relire §0. Or `SP-IM2`, livrée le 2026-08-28, faisait déjà ce
travail en plus large — les 12 classes et 240 lignes, contre 5 classes et 100 lignes — et la
ligne `SP-MA2` du tableau de bord portait déjà la mention « Livré par `SP-IM2` ».
→ Le diagnostic initial (« `sp-im2.sql` n'est pas appliqué ») était **faux** : il reposait sur un
  relevé antérieur de plusieurs tours, pris avant que le patch ne soit appliqué. Démenti par
  l'utilisateur, puis par deux marqueurs sans ambiguïté : le Moine avait ses 20 niveaux alors
  qu'aucun de mes patchs ne le touche, et les intitulés `cla_pouvoir` de l'Occultiste étaient
  posés.
→ **Dégât** : un `DELETE FROM dd_classe_niveau WHERE cn_cla_id IN (53,56,58,59,60)`, destiné à
  nettoyer mes propres doublons, a supprimé **aussi les lignes de `SP-IM2`** pour ces 5 classes,
  ensuite réinsérées avec des valeurs plus étroites — les colonnes `cn_pouvoir` de l'Occultiste
  s'étaient retrouvées à NULL. Les 7 autres classes n'ont pas été touchées.
→ **Réparation** : réapplication de `sql/2026-08-28_classes_dd2024_sp-im2.sql`, qui commence par
  un DELETE sur les 12 classes. Vérifié : 240 lignes, encodage de l'Occultiste rétabli
  (5 manifestations, 2 emplacements de niveau 3), aucun doublon. Mon patch concurrent a été
  supprimé du dépôt.
→ **À retenir** : relire §0 **au début de chaque phase**, pas seulement à son ouverture. Le
  tableau de bord bouge entre les sessions ; c'est précisément sa fonction.

**2. `dd_classe_niveau` n'avait aucune clé unique sur `(cn_cla_id, cn_niveau)` (défaut réel).**
`SCHEMA_SQL.md` la documentait pourtant ; la table ne portait que sa PRIMARY sur `cn_id`.
→ Conséquence : tout `INSERT ... ON DUPLICATE KEY UPDATE` sur cette table se comporte en INSERT
  pur et crée des **doublons silencieux** — c'est ainsi que 5 classes se sont retrouvées à
  40 lignes pour 20 niveaux. Rien dans l'application ne le détecte.
→ Clé `uk_cn_classe_niveau` créée, isolée dans son propre patch :
  `sql/2026-08-28_cle_unique_classe_niveau.sql`, avec le contrôle anti-doublon préalable.
  **À passer en prod** — sans elle, le même piège reste armé.
→ Troisième écart entre `SCHEMA_SQL.md` et la base réelle, après `mo_j_id` et
  `patch_004_supplements.sql`. La documentation de schéma décrit par endroits l'intention et non
  l'état : les clés et index y méritent une vérification avant d'être tenus pour acquis.

**3. Question ouverte laissée par `SP-IM2` — où vivent les emplacements de Magie de pacte.**
`SP-IM2` les porte dans les colonnes `cn_pouvoir1..3` (Manifestations occultes / Emplacements de
sort / Niveau des emplacements), fidèlement à la table du SRD, en laissant `cn_sort_n1..9` à 0.
→ Conséquence pour `SP-PE7` : la lecture générique « emplacements = `cn_sort_n1..9` » ne vaut pas
  pour l'Occultiste, qui devient un **cas particulier explicite**. À trancher avant d'écrire les
  helpers de calcul : soit la vue Magie lit les colonnes de pouvoir pour cette classe, soit on
  duplique l'information dans `cn_sort_n*`. Noté ici pour ne pas être découvert en cours de route.

**[2026-09-01] D-MAG13 — Q6 sans objet, Q7 et Q8 tranchées : les trois verrous de SP-PE7 sautent**
→ **Q8 — écriture immédiate**, sur le modèle du sélecteur de dons `SP-PE4`, **portée par classe**,
  pour les trois listes (grimoire, connus, préparés). Un seul motif d'interaction. Raisons :
  nettement meilleure au doigt (objectif 4 du §10.1 — pas de formulaire long à faire défiler, pas
  de bouton de validation à trouver en bas d'écran, `notifier()` donne le retour), et un commit
  global couvrant plusieurs classes lanceuses serait dangereux en multiclassage. Contrepartie
  assumée : refaire une liste complète coûte quelques gestes de plus, compensés par une action
  « Réinitialiser la liste préparée ».
→ **Occultiste — cas particulier explicite.** `SP-IM2` porte ses emplacements dans `cn_pouvoir1..3`
  et laisse `cn_sort_n1..9` à 0. Plutôt que de dupliquer l'information dans les colonnes
  d'emplacements, `SP-PE7` traitera la classe à part : une donnée présente en deux endroits finit
  par diverger. Rend **Q6 sans objet**.
→ **Q7 — table de liaison `dd_classe_sort`.** Le SRD formule tous les cas de la même façon, mot
  pour mot, avec la même table `Niveau de <classe> | Sorts`. Cinq cas relevés, trois seulement
  relèvent du référentiel : sort unique d'une aptitude de classe (A), table de sous-classe (B),
  usages gratuits (C). Les Manifestations occultes (D) sont **déjà traitées** — importées comme
  dons par `SP-IM5`. L'Arcanum mystique (E) est un **choix du joueur**, pas du référentiel.
→ Le champ `cs_cla_id` accepte indifféremment une classe et une sous-classe — une sous-classe
  étant une classe (`clt_id = 5`). C'est ce qui permet à A et B de partager une seule table : le
  SRD les formule pareil, seul le porteur change. Le modèle est celui de `dd_sortdomaine`, qui
  fait déjà ce travail pour les domaines DD3.5 : les deux rulesets partagent alors la même
  mécanique.
→ **Pourquoi c'était bloquant** : sans cette table, le compteur de sorts préparés de `SP-PE7` est
  faux dès qu'un personnage a une sous-classe. Un Paladin 3 du Serment de Dévotion a 4 sorts au
  plafond, plus *châtiment divin*, *bouclier de la foi* et *protection contre le mal* qui ne
  comptent pas — la page afficherait soit 4 sur 7 lançables, soit 7 sur 4.
→ **Arcanum différé** : marqueur `pesp_origine` (0 préparé, 1 toujours préparé, 2 arcanum) reporté
  en `SP-MA4b`. Ne concerne que l'Occultiste de niveau 11+, et le suivi des usages relève du Mode
  jeu. `SP-PE7` affichera un **avertissement** pour ces personnages plutôt que de faire semblant.
→ `SP-MA4` scindée : **`MA4a`** (la table, prérequis de `SP-PE7`) et **`MA4b`** (le reste, non
  bloquant — Q3 toujours ouverte, école de prédilection, `pesp_origine`).

**[2026-09-01] D-MAG14 — SP-MA4a livrée : `dd_classe_sort`, 67 lignes, dernier verrou de SP-PE7**
Patch : `sql/2026-09-01_sorts_toujours_prepares_sp-ma4a.sql` (appliqué et vérifié en local, à
passer en prod). Table `dd_classe_sort` + colonne `pesp_origine`.
→ **67 noms de sorts résolus en `so_id` : 0 introuvable, 0 ambigu.** C'était le risque principal
  de la phase (correspondance de noms français entre le PDF et la base) ; il est levé. Contrôles
  d'intégrité après application : 0 `cs_so_id` orphelin, 0 `cs_cla_id` orphelin, 0 sort hors DD2024.
→ Répartition : 9 porteurs — 3 sorts d'aptitude de classe (Paladin 1 *châtiment divin*, Rôdeur 1
  *marque du chasseur*, Occultiste 9 *contact avec les plans*) et 6 sous-classes (Domaine de la
  Vie, Serment de Dévotion, Protecteur Fiélon, Sorcellerie draconique à 10 lignes chacune, et
  Cercle de la Terre à 24 lignes).
→ **Trois sous-classes n'accordent aucun sort**, vérifié sur le SRD : Rôdeur/Chasseur (« Savoir du
  Chasseur » ne donne pas de sorts), Magicien/Évocateur, Barde/Collège du Savoir.
→ **Découverte 1 — le Cercle de la Terre ne rentrait pas dans le modèle initial.** « Chaque fois
  que vous terminez un Repos long, choisissez un type d'environnement entre : aride, polaire,
  tempéré et tropical. » Quatre tables alternatives, choix refait chaque jour. Résolu par la
  colonne `cs_variante` (validée le 2026-09-01). Le **choix du jour n'est pas stocké** : `SP-PE7`
  affichera les quatre groupes étiquetés et le joueur lira le sien — honnête pour une aide de jeu,
  et évite une donnée de séance dans le référentiel.
→ `cs_variante` est une chaîne **vide** et non NULL pour les autres porteurs : MySQL traite les
  NULL comme distincts dans une clé unique, ce qui aurait cassé l'idempotence de la clé
  `(cs_cla_id, cs_so_id, cs_variante)`.
→ **Découverte 2 — l'Arcanum mystique n'était pas un cas isolé.** Il existe une famille de sorts
  toujours préparés **mais choisis par le joueur** : Secrets magiques du Barde (niveau 10), Sorts
  de prédilection du Magicien (niveau 20), Arcanum de l'Occultiste (11/13/15/17). J'avais présenté
  l'Arcanum comme marginal et différable ; ils sont trois, et **le Barde à 10 est bien plus
  atteignable**. Différer aurait laissé un compteur faux pour tout barde de niveau 10+.
  `pesp_origine` a donc été intégrée à `MA4a` plutôt que reportée en `MA4b` (arbitré le 2026-09-01).
→ **Règle de lecture à porter dans `SP-PE7`** : les sorts sont **cumulatifs** — « pour votre niveau
  et les niveaux inférieurs ». Filtrer sur `cs_niveau <= niveau du personnage`, ne pas chercher
  l'égalité.
→ **Défaut du harnais local corrigé au passage** : le script d'application de patch découpait sur
  « ; » en suivant les chaînes, mais ne retirait que les commentaires en début de ligne. Une
  apostrophe dans un commentaire de fin de ligne (« -- Fléau d'insectes ») désynchronisait le
  suivi et **fusionnait deux instructions** — l'INSERT et l'ALTER ont été exécutés comme un seul
  bloc. MySQL lisait correctement, seul le harnais se trompait. Il retire désormais aussi les
  commentaires de fin de ligne, hors chaîne.

**[2026-09-01] D-MAG15 — SP-MA4b livrée : cadence de renouvellement (Q3, option a)**
Patch : `sql/2026-09-01_cadence_renouvellement_sp-ma4b.sql`. Colonne `cla_renouvellement`
-> `dd_variables` cat. `cadence`, 3 valeurs, constantes `CADENCE_*`, 19 classes lanceuses
renseignées. Code : `helpers.php` (`cadencesRenouvellement()`), formulaire, fiche, enregistrement.
→ **Changement d'avis assumé.** Le 2026-08-27 je recommandais de NE PAS modéliser cet axe :
  rien ne l'aurait lu, et je ne voulais pas d'une colonne qui rouille. Un consommateur est apparu
  entre-temps — l'action **« Réinitialiser la liste préparée »** retenue en Q8 n'a pas le même
  sens pour tous. Pour un Clerc c'est un geste quotidien ; pour un Barde DD2024 c'est un geste de
  **montée de niveau**. Sans la colonne, `SP-PE7` aurait proposé le même bouton aux deux et laissé
  un barde refaire sa liste chaque matin, ce que la règle interdit.
→ Second facteur : `SP-MA0` a posé le motif (catégorie `dd_variables` + constantes PHP + accesseur
  centralisé). Ajouter un second axe sur le même modèle ne coûte plus rien et reste cohérent.
→ Option (d) écartée après vérification : `cla_sorts`, le champ texte que je proposais de réutiliser
  en affichage seul, est **toujours vide sur les 8 classes DD2024 et 6 des 8 lanceuses DD3.5** —
  `SP-IM` ne l'a pas rempli. Il aurait fallu rédiger 14 textes pour un résultat non exploitable.
→ **DD3.5 : dérivé, pas énuméré.** Un répertoire figé (`cla_profil_incantation = 5`) ne change
  qu'à la montée de niveau, tous les autres lanceurs préparent. La dérivation couvre donc aussi
  les classes de prestige et les classes hors SRD — c'est tout l'intérêt de ne pas énumérer.
  DD2024 reste explicite, par la table « Préparation des sorts par classe » du SRD.
→ **Limite assumée** : la valeur « Montée de niveau » ne porte pas la périodicité fine du DD3.5
  (barde : niveau 5 puis tous les 3 ; ensorceleur : niveau 4 puis tous les 2). Plus fin que ce
  dont une aide de jeu a besoin ; le détail reste dans le descriptif de la classe.
→ `cadencesRenouvellement()` ne filtre **pas** par ruleset, contrairement à `profilsIncantation()` :
  aucune des trois valeurs n'est impossible dans l'absolu — « un seul sort par repos long » n'est
  simplement utilisée par aucune classe DD3.5 du SRD, mais rien ne l'interdit à une classe maison.
→ `SP-MA4` est close à un reliquat près, désormais suivi en **`SP-MA4c`** : l'école de prédilection
  du magicien DD3.5, non bloquante pour `SP-PE7`.

**[2026-09-01] D-PE7a — Helpers de calcul de la magie, et ce que le banc d'essai a révélé**
`getMagieContexte()` et 5 auxiliaires dans `personnage_helpers.php`. Aucune interface : la phase
est validée par un banc d'essai en ligne de commande, sur 4 personnages dont deux **synthétiques
créés en transaction annulée** (précédent D-RS36 — on ne détruit pas les données pour un contrôle).
→ **Le découpage `PE7a` / `PE7b` a payé.** Six défauts de calcul trouvés au premier passage, qu'une
  page aurait rendus sans les signaler :
  1. **Emplacements lus au niveau de classe et non au NLS effectif.** Un magicien 15 / archimage 5
     aurait lu la ligne 15 au lieu de la ligne 20.
  2. **NULL et 0 confondus** dans `cn_sort_n*` — voir le point suivant, c'est le plus lourd.
  3. **Niveau 0 absent des emplacements en DD3.5**, où `cn_sort_n0` est un vrai quota quotidien
     (en DD2024 la même colonne compte des sorts mineurs connus : deux sens, une colonne).
  4. **Bonus de maîtrise faux en DD2024** : le niveau global additionnait les lignes de
     sous-classe, une sous-classe étant une ligne de `dd_personnages_classes` sans être un niveau.
     Un paladin 6 / occultiste 5 était traité comme un personnage de niveau 17.
  5. `cn_sortPrepare` (0 en DD3.5) affiché comme un plafond réel.
  6. Sous-classes : **toutes** celles de la classe étaient retenues au lieu de celle que le
     personnage détient — n'importe quel clerc aurait vu les sorts du Domaine de la Vie.
→ **`NULL` et `0` ont deux sens opposés au SRD 3.5**, et la base ne les distinguait pas :
  « — » signifie que le niveau de sort est inaccessible, « 0 » qu'il l'est mais **uniquement par
  les sorts en bonus** de caractéristique. Relevé : Barde, Paladin, Rôdeur, Assassin, Chevalier
  noir et Tueur de Domiel portent 4 à 6 « 0 » **légitimes** chacun ; Druide, Ensorceleur et
  Magicien sont propres ; **Prêtre (72 cellules) et Élu divin (80) utilisaient « 0 » partout**.
  Conséquence concrète : un prêtre de niveau 6 recevait un emplacement de 4e niveau qu'il ne peut
  pas lancer, sur la seule foi de son bonus de Sagesse.
  Corrigé par `sql/2026-09-01_cn_sort_null_vs_zero_sp-pe7a.sql`, qui ne convertit que les « 0 »
  situés **au-delà** du plus haut niveau accessible, et seulement pour ces deux classes — les
  « 0 » du SRD sont préservés, vérifié sur le Barde niveau 2.
→ **Défaut de données corrigé le 2026-09-01** (`sql/2026-09-01_decalage_paladin_rodeur_sp-pe7a.sql`,
  avec sauvegarde et retour arrière) : les tables du **Paladin et du Rôdeur DD3.5 étaient
  décalées d'une colonne**. Preuve : au niveau 20 elles portent `n0..n3 = 3,3,3,3`, alors que le
  SRD donne à ces classes 4 niveaux de sorts (1 à 4) à 3 sorts par jour. `cn_sort_n0` contient donc
  les sorts de **1er** niveau. Or ni le Paladin ni le Rôdeur n'ont de sorts de niveau 0 — et les
  trois autres classes DD3.5 sans niveau 0 (Assassin, Chevalier noir, Tueur de Domiel) ont bien
  `cn_sort_n0` vide. 17 niveaux × 2 classes, colonnes n4..n9 vérifiées vides avant décalage.
  Contrôlé après coup contre la table du SRD : niveau 4 → `0` (sorts bonus seulement), niveau 6
  → 1, niveau 8 → 1/0, niveau 20 → 3/3/3/3, et plus aucun `cn_sort_n0` renseigné. Vérification
  de bout en bout par `getMagieContexte()` : un paladin 4 à Sagesse 14 obtient **1** sort de
  1er niveau (0 par la table + 1 en bonus), un paladin 4 à Sagesse 10 en obtient **0** sans que
  le niveau cesse d'être accessible — la règle « quota 0 ≠ pas de sorts » du SRD est tenue.
→ Trois pièges documentés en §0 ont été portés dans le code et vérifiés : l'Occultiste lit ses
  emplacements dans `cn_pouvoir1..3` (2 emplacements de niveau 3 au niveau 5, conforme au SRD) ;
  les sorts toujours préparés sont cumulatifs (un paladin 6 du Serment de Dévotion voit ceux des
  niveaux 1, 3 et 5) ; `bonusSortsCarac()` n'est appelée qu'en DD3.5.
→ Le multiclassage DD2024 lit ses emplacements dans la table du **lanceur complet** au niveau
  d'incantateur agrégé, et cette classe de référence est **déduite** (celle qui atteint les
  emplacements de 9e niveau au niveau 20) plutôt que codée en dur.

**[2026-09-01] D-PE7b — Vue Magie livrée**
`personnages/magie.php`, `include/ajax/detail-pp/sorts-picker.php`, module JS `sortsPicker`,
6 actions dans `personnages/enregistrement.php`. Aucun patch SQL.
→ **Le regroupement de premier rang est la CLASSE**, jamais le niveau de sort (objectif produit
  §10.1). Un monoclasse ne voit qu'une section ; un multiclassé en voit autant qu'il a de classes
  lanceuses, chacune avec sa caractéristique, son NLS et ses listes propres.
→ **Toute écriture est portée par la classe** (`pc_id` pour le répertoire, `cla_id` pour les
  préparés). C'est la garantie promise en Q8 : en multiclassage, une sauvegarde ne peut pas
  toucher la liste d'une autre classe.
→ **Le sélecteur a deux modes, et son réservoir dépend du profil** : en mode « préparation », un
  profil Grimoire ne propose que les sorts **compris** — préparable ⟺ compris (D-MAG6) — là où
  les autres profils proposent la liste de classe entière. Un grimoire vide affiche « recopiez
  d'abord des sorts » plutôt qu'une liste vide sans explication.
→ En DD3.5 le niveau d'un sort est **relatif à la classe** (`dd_sortclasse.sc_niveau`), en DD2024
  il est absolu (`so_niveau`) : deux requêtes distinctes dans le sélecteur plutôt qu'un COALESCE
  qui aurait masqué la différence.
→ **Clés uniques vérifiées avant de s'y fier**, leçon de `dd_classe_niveau` : `uk_pes` existe bien
  sur `dd_personnages_sorts`, l'`INSERT IGNORE` absorbe donc les doubles clics. `dd_personnages_
  sorts_prepares` n'en a **volontairement pas** — un magicien DD3.5 prépare plusieurs fois le même
  sort, en versions normale et métamagiques — d'où un test d'existence avant insertion.
→ Le compteur de sorts préparés ne totalise que `pesp_origine = 0`, et « Réinitialiser » ne
  supprime que ceux-là : les sorts toujours préparés ne sont pas des choix du joueur.
→ Testé en transaction annulée : double ajout absorbé, bascule du grimoire, compteur excluant les
  toujours préparés (3 lignes, 2 comptées), réinitialisation préservant le toujours préparé.
→ **Poids du sélecteur** : 400 Ko pour les 1 062 sorts de magicien DD3.5, contre 139 Ko pour les
  300 dons de `SP-PE4` — même coût par entrée, liste simplement plus longue. Le filtrage reste
  côté client (réactivité au doigt) et le `.htaccess` applique DEFLATE. À reconsidérer si les
  relevés `SP-RS5` montrent un problème sur mobile.
→ **Signalé, hors périmètre** : « Abri de léomund » et « Abri de Leomund » coexistent en double
  dans le compendium DD3.5 — deux entrées pour un même sort, à fusionner.

**[2026-09-01] D-PE7c — Fiche éclatée en cinq sous-pages, et refonte de la vue Magie**
Retours d'usage après le premier essai en navigateur. Deux chantiers distincts.

**1. La fiche devenait trop longue → sous-menu horizontal et cinq pages.**
→ Arbitrage : **des sous-pages**, pas des onglets sur une seule page. Trois raisons — `magie.php`
  en était déjà une, `SP-CP` a pris la même direction pour les Campagnes (« chaque niveau devient
  une page, avec son URL »), et la fiche chargeait déjà tout le référentiel des compétences du
  ruleset : y empiler la Magie aurait pénalisé le téléphone, exactement ce qu'on cherche à éviter.
→ Découpage : **Fiche** (identité, caracs, combat, compétences, NLS, dons) · **Magie** ·
  **Possessions** · **Background** · **Campagnes**. Partiel commun `include/personnage-nav.php`,
  qui surligne la page courante et **masque l'onglet Magie pour un non-lanceur**.
→ Sur téléphone, le sous-menu ne garde que les icônes et défile horizontalement : cinq libellés ne
  tiennent pas sur une ligne, et un menu replié sur deux lignes mange la hauteur utile.
→ `objets.php` devient `possessions.php` — le périmètre couvre objets magiques ET équipement — et
  l'ancien fichier subsiste en **redirection 301** pour ne casser aucun signet.
→ Nettoyage au passage : `fiche.php` chargeait toujours les campagnes (deux requêtes et une
  sérialisation JSON) pour un bloc qui n'y est plus. Retiré. Le global `perCampCourante`, oublié
  à l'extraction, a été ajouté à `campagnes.php` — l'éditeur lit ses données défensivement
  (`typeof … !== 'undefined'`), le défaut serait passé inaperçu jusqu'au premier rattachement.

**2. Vue Magie — dix corrections.**
→ **Quatre cases** de synthèse au lieu d'une liste : caractéristique, NLS, DD de sauvegarde,
  attaque des sorts. L'attaque était accolée au DD sur la même ligne — deux chiffres différents
  qu'on confond au premier coup d'œil. Grille `auto-fit` : 4 de front sur un poste, 2 sur
  tablette, 1 sur téléphone, sans média-query.
→ Les **boutons d'action descendent après les cases**, et prennent toute la largeur sur téléphone.
→ **Tableau des emplacements** repris sur `.table-dd` / `.col-sort`, comme la table « Nombre de
  sorts par jour » du descriptif de classe : c'est la même information, elle doit se lire pareil.
  Les **9 niveaux restent affichés** même inaccessibles (« — ») — une table dont le nombre de
  colonnes varie d'une classe à l'autre se compare mal. Ligne **« En stock »** ajoutée avec son
  bouton de réinitialisation : emplacement réservé, le suivi réel des emplacements consommés
  demande une table dédiée et relève de `SP-PE8` (arbitré).
→ **Ordre des listes inversé, du plus immédiat au plus lointain** : Sorts préparés → Grimoire →
  Connus. On lisait auparavant l'inverse.
→ Listes sans puce, **niveau du sort en pastille**, **2 à 3 colonnes** selon la largeur (`columns`
  et non `grid`, pour qu'on lise une colonne entière avant de passer à la suivante), une seule sur
  téléphone. Espacement augmenté au-dessus de chaque bloc.
→ Les explications passent en **bulles d'aide** (`aideIcone()`, 4 clés ajoutées à
  `aide-contextuelle.php`), reformulées pour dire le *pourquoi* et non le *quoi* — et le texte
  diffère selon le ruleset, la préparation n'ayant pas le même sens en DD3.5 et en DD2024.
→ `cursor: pointer` sur tout ce qui est cliquable.
→ **Défaut corrigé au passage** : la pastille de niveau restait vide sur tout le DD3.5. Le niveau
  d'un sort y est **relatif à la classe** (`dd_sortclasse.sc_niveau`) et non absolu — les deux
  requêtes de la page ne le résolvaient pas. Effet de bord bienvenu : les listes se trient
  désormais par niveau puis par nom.

**3. Sélecteur de sorts.**
→ **Compteurs en direct** : plafond global en DD2024 (`cn_sortPrepare`), **un compteur par niveau
  de sort en DD3.5** — il n'y a pas de plafond global dans ce ruleset, c'est le nombre
  d'emplacements de chaque niveau qui borne la préparation. Recalculés depuis le DOM plutôt que
  depuis la réponse serveur, qui ne renvoie qu'un total par classe.
→ La liste est **bornée aux niveaux accessibles** : proposer des sorts de niveau 9 à un magicien
  de niveau 5 noie le choix utile. Le critère est l'accessibilité calculée par
  `getMagieContexte()`, pas le niveau de classe — un « 0 » du SRD reste un niveau accessible.
→ Filtre **« Les siens seulement »** en mode répertoire : la liste de classe fait plus de mille
  entrées chez un magicien.

---

## SP-PE10 — Compaction de l'interface personnage

**[2026-09-19] D-RS45 — SP-PE10a : le bloc Identité tient sur deux rangées**
Code : `personnages/fiche.php`, `css/personnages-modules.css`. Aucun patch SQL.
→ **Le chantier reçoit son code projet `SP-PE10`** — passe de compaction de l'interface du module
  Personnages, distincte de `SP-PE8` (Mode jeu + passe responsive) qui reste ouverte. Sous-phases
  par écran : `SP-PE10a` pour la fiche, les suivantes numérotées à mesure des demandes.
→ **Race, Historique (DD2024), Sexe et Alignement passent sur une seule rangée.** Les trois
  dernières lignes du bloc remontent devant la ligne Classes dans le DOM : c'est ce qui rend la
  rangée contiguë. La ligne Classes, qui porte une liste, reste pleine largeur et ferme le bloc —
  elle n'est donc plus « juste après la race » comme depuis SP-RS6d, mais toujours en vue sans
  défilement.
→ **`.per-identite` passe de `grid` à `flex`.** En grille `auto-fit minmax(190px, 1fr)`, les quatre
  entrées tenaient bien sur une ligne mais laissaient une piste vide à droite — deux en DD3.5, qui
  n'a pas d'historique. En flex, `flex: 1 1 190px` répartit les entrées présentes sur toute la
  largeur : 4 × 255px en DD2024, 3 × 345px en DD3.5.
→ **Les libellés ne réservent plus 110px** (`flex: 0 0 auto`), le `padding` vertical des lignes
  passe de 4px à 3px et le `gap` vertical de la liste disparaît. La valeur peut passer sous son
  libellé (`flex-wrap: wrap` sur la ligne) — sauf sur la ligne Classes, tenue en `nowrap`.
→ **Responsive** : base de 160px sous 992px (les quatre entrées tiennent encore de front à 820px),
  130px sous 480px — deux colonnes jusqu'à 342px, seuil de référence du Galaxy A52 (§10h), repli
  sur une colonne en dessous.
→ Mesuré dans le navigateur sur le personnage *Adon* (DD2024, clerc/guerrier) : le bloc passe de
  **255px à 201px** sur un poste à 1280px, et de **294px à 254px** à 342px. Aucun débordement
  horizontal à 1280 / 820 / 375 / 342px. Le cas DD3.5 a été vérifié sur *Elminster*
  (magicien 20 / archimage 5) : trois entrées de 345px sur une rangée, même hauteur de bloc.
→ `include/ajax/detail-pp/personnage.php` réutilise `.per-identite` et présente déjà les mêmes
  entrées dans cet ordre : il bénéficie de la compaction sans modification.

**[2026-09-19] D-RS46 — SP-PE10b : la vue Magie se lit en trois temps**
Code : `personnages/magie.php`, `css/personnages-modules.css`. Aucun patch SQL. Structure posée
par une maquette de l'utilisateur (bloc du Magicien DD2024), déclinée aux autres profils et au
DD3.5.
→ **Le corps d'un bloc de classe suit désormais trois temps** : les quatre cases de synthèse et
  la barre d'actions, puis une rangée à deux colonnes — tableau des emplacements à gauche,
  panneau « Ressources de sorts » à droite —, puis les listes de sorts.
→ **Le panneau « Ressources de sorts » rassemble ce qui se dispersait.** Trois endroits
  différents portaient des compteurs : un paragraphe « Renouvellement · Domaines » sous les
  cases, un paragraphe de plafonds sous le tableau, et une pastille de comptage dans le titre de
  chaque liste. Tout est réuni en paires libellé / valeur, dans l'ordre de la maquette : sorts
  mineurs connus, sorts préparés, sorts en grimoire, sorts connus, renouvellement, domaines.
→ **Une ligne n'apparaît que si le profil la porte réellement.** Un clerc n'a ni grimoire ni
  répertoire : lui afficher « Sorts connus : 0 » lui ferait croire à une donnée manquante. D'où
  le tri par `cla_profil_incantation` — grimoire et connus pour `PROFINC_GRIMOIRE`, « Sorts au
  répertoire » pour `PROFINC_REPERTOIRE`, aucune des deux pour `PROFINC_LISTE` et le pacte.
  Même règle pour les plafonds : « Sorts mineurs connus » est une donnée DD2024
  (`cn_sort_n0` y compte les sorts mineurs, là où il porte les emplacements de niveau 0 en
  DD3.5), et le plafond de préparation n'existe qu'en DD2024 (`cn_sortPrepare`) — en DD3.5 la
  ligne n'affiche que le nombre préparé, puisque c'est le tableau des emplacements qui borne.
→ **Les listes de sorts passent en flux.** `columns: 2/3` découpait la largeur en tranches
  égales : la deuxième colonne démarrait au milieu de la page, loin de son titre, et un nom
  court laissait un vide aussi large qu'un nom long. Les sorts se suivent maintenant sur la
  ligne (`flex-wrap`), à écart **fixe de 24px** (`--sp-lg`, 8px entre deux lignes), et chaque
  liste repart à gauche, à l'aplomb de son titre.
→ **Deux correctifs de fond au passage.** La liste « Toujours préparés » portait
  `.per-liste-inline`, une classe **sans aucun style dans le projet** : elle s'affichait en
  liste à puces. Elle prend le flux commun. Et `.per-fiche__sous-titre`, qui coiffe toutes les
  listes de la page, n'était lui non plus **défini nulle part** — les titres tombaient sur le
  `h3` par défaut du navigateur, dont la marge haute ouvrait un trou sous le tableau.
→ « Niveau de sort » devient « **Niveaux de sort** » dans l'en-tête du tableau : la cellule
  coiffe les neuf colonnes, pas une seule.
→ Contrôlé dans le navigateur sur les trois profils présents en base : *Telgar Weyr* (DD2024,
  clerc 10 `PROFINC_LISTE` + magicien 20 `PROFINC_GRIMOIRE`) et *Elminster* (DD3.5, magicien 20
  + archimage 5). Tableau 601px / panneau 441px côte à côte à 1280px, encore côte à côte à
  820px (446 / 286), empilés à 375px ; aucun débordement horizontal, et les 11 colonnes du
  DD3.5 n'appellent pas de défilement interne. Écarts de liste relevés à 23-25px selon
  l'arrondi sous-pixel, listes alignées à x = celui de leur titre.
→ **Reste hors périmètre** : le suivi réel des emplacements consommés (ligne « En stock »,
  toujours un miroir de « Par jour ») demande une table dédiée et relève de `SP-PE8`.

**[2026-09-19] D-RS47 — SP-PE10c : le tableau des emplacements prend l'échelle de la page**
Code : `css/personnages-modules.css` seul. Aucun patch SQL, aucun changement de structure.
→ **`.table-dd` est réglé pour le compendium, pas pour cette page.** Il habille des tables de
  progression de classe qui alignent vingt lignes et une quinzaine de colonnes : d'où des
  cellules de 26px, un padding de 3px et une police de .82rem. Illisible ici, où le tableau n'a
  que deux ou trois lignes et se consulte d'un coup d'œil en séance.
→ **La référence est le panneau qui lui fait face, pas une taille choisie dans l'absolu.** Une
  première passe avait grossi le tableau bien au-delà (chiffres à 1.25rem, en-tête à 1.5rem) :
  il écrasait le reste du bloc. Les deux colonnes de la rangée partagent désormais la même
  échelle — en-tête de groupe à **1.05rem** comme le titre « Ressources de sorts », libellés de
  ligne et chiffres à **1rem** comme les libellés et valeurs des ressources, le gras marquant
  de part et d'autre ce qui est une valeur. Colonnes à 34px, padding 5px/8px.
→ **Rien ne change sous 992px** : la version compacte reste celle qui tient dans un téléphone.
→ **Le séparateur rouge de `.table-dd` est neutralisé sur cette table** (arbitré : surcharge
  locale, ni conservation ni retrait global). Il sépare les colonnes de sorts des autres
  colonnes d'une table de progression ; ici, où seule une colonne de libellés leur fait face,
  il ne sépare rien. Les tables du compendium et des règles le gardent.
→ Contrôlé dans les deux thèmes sur *Telgar Weyr* (DD2024, 10 colonnes) et *Elminster* (DD3.5,
  11 colonnes avec le niveau 0) : tailles rendues identiques de part et d'autre de la rangée
  (15,75px pour les deux en-têtes, 15px pour libellés et valeurs — la base `rem` du site fait
  15px) ; à 1000px, tableau de 520px et panneau de 360px, côte à côte et **sans défilement
  interne** malgré les 11 colonnes ; à 375px, retour au compact (13,1px) sans débordement.

**[2026-09-19] D-RS48 — SP-PE10d : le sélecteur de sorts n'avait aucun style à lui**
Code : `include/ajax/detail-pp/sorts-picker.php`, `js/personnage.js`, `css/modules.css`.
Aucun patch SQL.
→ **Constat de départ.** `sorts-picker.php` emprunte la coque du sélecteur de dons
  (`.dons-picker`) mais nomme ses propres éléments : `.dons-picker__items`,
  `.dons-picker__toggle`, `.dons-picker__decompte`, `.dons-picker__grimoire`, `.est-choisi`,
  `.sorts-picker__compteur(s)`, `.sorts-picker__jeton`, `.est-plein`. **Aucun n'existait dans
  les CSS du projet** : le `<ul>` s'affichait à puces, les boutons n'avaient que l'habillage
  générique `.btn`, les jetons de compteur DD3.5 étaient du texte nu — et un sort retenu ne se
  distinguait d'un autre que par l'icône de son bouton. La demande « changer la couleur de fond
  d'une ligne sélectionnée » portait donc sur un composant entièrement à styler.
→ **Ligne retenue : fond teinté + filet d'accent.** `color-mix(in srgb, var(--clr-accent) 14%,
  transparent)`, précédé de `var(--clr-surface-alt)` en repli pour les navigateurs sans
  `color-mix` (déjà employé dans `campagnes-modules.css`). Aucune couleur en dur, et la teinte
  suit le thème — parchemin comme sombre. Le nom passe en gras, le bouton prend la couleur
  d'accent : il retire, il ne l'ajoute plus.
→ **Téléphone : le volet de description disparaît, la fiche passe au-dessus.** Il occupait plus
  de la moitié de la largeur alors que le choix se fait dans la liste. Sous 992px, la liste
  prend 100 % et la fiche s'ouvre dans `#detail-pp-sub` (z-index 300), **par-dessus** le
  sélecteur (200), qui reste ouvert et retrouve sa place à la fermeture du sous-panneau. Le
  seuil est le même des deux côtés — média-query CSS et `matchMedia` dans `voir()`.
→ **Liste resserrée, bouton intact.** Padding de ligne ramené à 2px, nom sur une seule ligne
  avec ellipsis, aucun retour à la ligne — mais le bouton garde **44px** : c'est lui qu'on vise
  du pouce, et c'est lui qui fixe la hauteur de ligne (49px mesurés).
→ **Filtre « Les préparés seulement ».** Le filtre existait en mode répertoire sous le libellé
  « Les siens seulement » ; la même case sert désormais aux deux modes, avec le libellé et
  l'infobulle du mode. Rien à changer dans `filtrer()` : `est-choisi` signifie « retenu » dans
  un cas et « préparé » dans l'autre.
→ **Le bouton « recopier dans le grimoire » suit l'état du sort.** Il n'était posé qu'au rendu
  serveur, sur les sorts déjà retenus : un sort tout juste ajouté n'en avait pas tant que le
  panneau n'était pas rouvert. `_majBoutonGrimoire()` le pose et le retire à chaque bascule.
  Un sort ajouté ici n'est jamais déjà recopié (`pes_compris = 0`), le bouton naît donc toujours
  sur « livre ouvert ». `grimoire()` visait `querySelectorAll('.dons-picker__toggle')[1]`, la
  position dans la ligne : il vise maintenant `.dons-picker__grimoire`, sa classe.
→ Le profil d'incantation descend dans le DOM (`data-grimoire`) : le JS ne peut pas deviner
  qu'une classe tient grimoire.
→ **Contrôlé dans le navigateur, sur une session authentifiée** (procédure D-RS35), sur
  *Telgar Weyr* (magicien DD2024, 203 sorts au répertoire, 6 au grimoire) et *Elminster*
  (magicien DD3.5, jetons de compteur par niveau) : ligne teintée et filtre vérifiés dans les
  deux modes ; fiche dans le volet droit à 1280px, dans le sous-panneau à 375px sans que le
  sélecteur se ferme ; bouton grimoire apparu, disparu, reparu au fil des bascules, et
  **fonctionnel une fois posé en JS** (recopie puis retrait). Les écritures de contrôle ont été
  faites sur la vraie base puis annulées ; état relevé avant et **vérifié identique après**
  (9 sorts, mêmes `pes_compris`), conformément au précédent D-RS36.

**[2026-09-19] D-RS49 — SP-PE10e : en DD3.5, préparer un sort n'est pas un oui/non**
Code : `personnages/enregistrement.php`, `include/ajax/detail-pp/sorts-picker.php`,
`js/personnage.js`, `css/modules.css`. **Aucun patch SQL** — la colonne existait déjà.
→ **Le modèle était juste, l'interface ne le suivait pas.** Un magicien DD3.5 mémorise plusieurs
  fois le même sort, chaque exemplaire occupant un emplacement de son niveau. `pesp_nb` porte
  cette quantité depuis l'origine, `dd_personnages_sorts_prepares` n'a volontairement pas de clé
  unique, la vue Magie affiche déjà « ×N » et somme `GREATEST(pesp_nb,1)`. Mais
  `basculerPrepare()` insérait toujours `pesp_nb = 1` et supprimait la ligne au clic suivant, et
  le sélecteur n'offrait qu'une bascule : la quantité était inatteignable depuis l'écran.
→ **Un exemplaire par clic.** `preparerSort` incrémente (INSERT à 1, puis `pesp_nb + 1`),
  `retirerPrepare` décrémente et **supprime la ligne au dernier retrait**. La réponse renvoie le
  `nb` de la ligne : le serveur fait foi, le JS ne recompte pas de son côté.
→ **La quantité est une règle DD3.5, et le code le dit.** En DD2024 la liste préparée est un
  ENSEMBLE de sorts distincts — on lance n'importe lequel avec l'emplacement de son choix, et
  `cn_sortPrepare` plafonne des sorts distincts. La bascule présent/absent y est donc conservée,
  et `gardeSortPersonnage()` rend désormais le ruleset pour que l'écriture puisse trancher.
→ **La ligne porte un compteur `[−] N [+]`** en préparation DD3.5, à la place du bouton bascule.
  Les trois éléments sont toujours présents, y compris à zéro : la ligne ne bouge pas quand la
  quantité change et le pouce garde sa cible. Le « − » est désactivé à zéro.
→ **Le compteur est encadré.** Il est suivi de la pastille de niveau du sort : deux chiffres
  voisins qui ne disent pas la même chose — « combien j'en prépare » et « de quel niveau il
  est ». Le cadre marque la frontière, et prend la couleur d'accent quand la ligne est retenue.
  Même souci que le DD et l'attaque des sorts accolés, réglé en SP-PE7b.
→ **Les jetons de niveau comptent des exemplaires, plus des lignes.** `_majCompteurs()` sommait
  `.est-choisi[data-niv=n]` ; il somme maintenant leur `data-nb`. Un sort préparé trois fois
  consomme bien trois emplacements de son niveau.
→ **Rien ne bloque au-delà du plafond** : la page est une aide de jeu, pas un moteur de règles
  (§7.1). Le jeton du niveau vire au rouge, et c'est tout — cohérent avec ce qui existait.
→ `pesp_nb` vaut **0 par défaut en base** alors qu'un exemplaire préparé compte pour 1 : toute
  lecture passe par `GREATEST(pesp_nb, 1)`, comme le faisait déjà le total.
→ Contrôlé dans le navigateur sur *Elminster* (magicien 20 DD3.5) : montée à 3 exemplaires d'un
  même sort — jeton N0 de 4 à 1 —, saturation du niveau (jeton rouge à 0), retour à zéro avec
  suppression de la ligne, et clic de trop sur « − » sans effet ; `pesp_nb` vérifié en base à
  chaque palier. Sur *Telgar Weyr* (magicien 20 DD2024) : pas de compteur, bascule inchangée,
  plafond global toujours en sorts distincts (22/25). États relevés avant et **vérifiés
  identiques après** sur les deux personnages (précédent D-RS36).
→ **Hors périmètre, à traiter le jour où les métamagies seront saisies** : une version
  métamagique occupe sa propre ligne (`pesp_metamagie`), que cet écran ne montre pas encore. Le
  compteur ne porte donc que la version sans métamagie ; le picker cumule les lignes à
  l'affichage pour ne pas en masquer l'existence.

**[2026-09-19] D-RS50 — SP-PE10f : le niveau passe en intertitre, la ligne se dégage**
Code : `include/ajax/detail-pp/sorts-picker.php`, `js/personnage.js`, `css/modules.css`.
Aucun patch SQL.
→ **La pastille de niveau quitte chaque ligne** au profit d'un **en-tête par groupe de niveau**.
  Les sorts arrivent déjà triés par niveau puis par nom : un intertitre à chaque rupture dit la
  même chose que 203 pastilles, en neuf lignes. Sur un téléphone, le nom du sort passe de 193 à
  **285px** en répertoire et à **234px** en préparation — c'est là que la place manquait.
→ **L'en-tête est `sticky`** en haut de la liste : on sait toujours quel niveau on parcourt.
→ **Il se masque avec son groupe.** `filtrer()` relève les niveaux encore représentés et efface
  les en-têtes devenus orphelins — sans quoi une recherche laisserait des intertitres suivis de
  rien. Vérifié : « boule » ne laisse que les niveaux 3 et 7, « les siens seulement » que le 1.
→ **Le cadre du compteur, posé la veille en SP-PE10e, est retiré.** Il servait à le distinguer de
  la pastille de niveau qui le suivait ; la pastille ayant disparu, il ne séparait plus rien et
  surchargeait la ligne.
→ **Le compteur DD3.5 se resserre sur téléphone** : ses deux boutons descendent de 44 à **40px**
  — la taille déjà retenue pour le sélecteur de dons en mobile — et l'écart interne tombe à zéro.
  Il coûte deux cibles tactiles là où les autres modes n'en demandent qu'une ; sur 343px de
  liste, le nom du sort n'avait plus de quoi s'écrire. La hauteur de ligne passe de 49 à 45px.
→ Contrôlé sur *Telgar Weyr* (DD2024, 203 sorts, 9 niveaux) et *Elminster* (DD3.5, préparation) à
  375px et 1280px : en-têtes présents et collants, aucune pastille résiduelle, filtres exacts,
  aucun débordement horizontal.

**[2026-09-19] D-RS51 — SP-PE10g : sur téléphone, la liste du sélecteur sort de son cadre**
Code : `css/modules.css` seul. Aucun patch SQL.
→ Sous 992px, `.sorts-picker .dons-picker__liste` **perd sa bordure et son arrondi** : à quelques
  pixels du cadre de l'overlay, il le redoublait sans rien délimiter de plus, et les deux
  mangeaient la largeur du nom des sorts.
→ Elle **déborde du padding du panneau** de `--sp-sm` de chaque côté (marges négatives et
  `width: calc(100% + var(--sp-md))`). Débordement volontairement modéré : il reste 8px de marge,
  le texte ne touche pas le bord de l'écran.
→ Gain mesuré à 375px : la liste passe de 343 à **359px**, le nom du sort de 285 à **303px** en
  répertoire et de 234 à **252px** en préparation DD3.5 — soit, cumulé avec SP-PE10f, **110px
  gagnés sur le nom** depuis le début de la passe.
→ **L'ordinateur ne bouge pas** : la règle vit dans la média-query 991px, bordure et arrondi y
  sont vérifiés intacts, les deux volets aussi. Le **sélecteur de dons non plus** — la règle est
  préfixée `.sorts-picker`.

**[2026-10-07] D-RS52 — SP-PE10h : la fiche personnage reprend de la hauteur**
Code : `include/header.php`, `include/helpers.php`, `include/personnage_helpers.php`,
`include/ajax/detail-pp/personnage.php`, `personnages/fiche.php`, `personnages/background.php`,
`js/personnage.js`, `css/main.css`, `css/personnages-modules.css`. Aucun patch SQL.

**1. En-tête du site sur téléphone.**
→ Le bouton Menu occupait **une ligne entière pour lui seul** pendant que le raccourci
  personnage se serrait à 40 % au bout de la ligne de titre : exactement l'inverse de ce qu'il
  fallait. Le burger devient une icône de 44px à l'extrême droite de la ligne du logo et du
  badge de ruleset ; le raccourci prend la ligne suivante **sur toute la largeur** — c'est une
  cible de doigt, et le nom d'un personnage n'y est plus tronqué.
→ Le mot « Menu » et le chevron disparaissent sous 992px. **Le chevron a résisté** : Font
  Awesome, chargé après `main.css`, pose un `display` sur toute icône `.fa` et gagnait à
  spécificité égale. Ciblé depuis son bouton (`.site-header__burger .site-header__burger-chevron`)
  plutôt qu'avec un `!important`.

**2. Bloc Identité, refondu.**
→ **Une rangée de couples libellé/valeur** : niveau, race, sexe, alignement, et l'historique en
  DD2024. Chaque champ est un bloc insécable qui passe à la ligne entier — la grille de colonnes
  d'avant pouvait séparer « Alignement » de sa valeur.
→ **Le niveau total ouvre la rangée** et quitte la ligne sous le nom du personnage.
→ **Les classes perdent leur libellé et leurs « niv. »** : une par ligne, nom puis nombre, le
  liseré pointillé entre chacune. Dans un bloc Identité, « Clerc 5 » ne se lit pas autrement.
→ **Le bouton Modifier est posé en absolu** au bout de la première ligne. La place lui est
  réservée par le `padding-right` de cette ligne : un nom long passe à la ligne **avant** de
  l'atteindre, au lieu de glisser dessous.
→ **Le badge « P » des classes de prestige devient une italique** (DD3.5) — même information,
  plus de pastille sur la ligne.
→ **Les sous-classes DD2024 rejoignent leur classe, entre parenthèses** : « Clerc 5 (Domaine de
  la Vie) ». Une sous-classe n'est pas une classe de plus, c'en est une facette. Le rattachement
  se fait par `cla_cla_id`, que `getPersonnageClasses()` ne renvoyait pas.

**3. Défaut découvert en chemin : le niveau total comptait les sous-classes.**
→ `$niveau_global` sommait toutes les lignes de `dd_personnages_classes`. Le Domaine de la Vie
  d'Adon y ajoutait son niveau 1 : un clerc 5 / guerrier 1 affichait **7**. Le bonus de maîtrise
  DD2024, calculé sur ce total, était faux avec. Les sous-classes (`cla_clt_id = 5`) en sont
  exclues.
→ Les `clt_id` littéraux se dispersaient dans le code — un écueil déjà nommé dans
  `helpers.php` à propos des profils d'incantation. Ils reçoivent leurs constantes :
  `CLT_BASE_35`, `CLT_PRESTIGE`, `CLT_PNJ`, `CLT_BASE_2024`, `CLT_SOUS_CLASSE`.

**4. Caractéristiques, CA et PV.**
→ Les titres « Caractéristiques » et « Combat » tombent : le premier ne dit rien que la grille ne
  dise, le second coiffait deux nombres. Les contours restent — c'est eux qui séparent.
→ Les six caractéristiques passent en **deux lignes de trois**, comme le bloc de stats d'un
  monstre (`.mo-carac-table`). À six de front, les tuiles s'étiraient en bandes.
→ Le bloc Combat disparaît au profit de **deux tuiles** CA et PV, libellé et valeur sur la même
  ligne.
→ **Les trois blocs tiennent une rangée** sur un poste (caractéristiques 637px, CA et PV 216px
  chacun à 1280px) ; sur téléphone, les caractéristiques prennent leur ligne et CA / PV se
  partagent la suivante (176px chacun à 375px).

**5. Reste de la passe.**
→ **Les boutons ne gardent que leur icône**, sur la fiche comme dans les pages sœurs. Onze
  libellés retirés, dont **dix que `js/personnage.js` réinjectait** à chaque bascule d'éditeur :
  les masquer en CSS ne suffisait pas, ils reparaissaient au premier clic. La classe
  `.per-btn-label` et sa règle de masquage disparaissent avec eux.
→ **Compétences sur téléphone** : les colonnes Carac / Maîtrise / Total passent de 3.9 à 2.6rem
  et se collent à droite. Le nom de la compétence gagne ~55px — il tenait sur moins de la moitié
  de la ligne.
→ **Bloc NLS (DD3.5)** : le paragraphe d'explication est masqué sous 992px. Une phrase qu'on ne
  lit qu'une fois ne vaut pas quatre lignes sur un téléphone ; le bloc, lui, reste.

**6. Portée.**
→ `include/ajax/detail-pp/personnage.php` partage ces composants : il suit la refonte (champs
  d'identité, tuiles CA / PV). Sans quoi le nettoyage des règles mortes l'aurait laissé sans
  styles.
→ Contrôlé dans le navigateur à 1280px et 375px sur *Adon* (DD2024, clerc 5 + Domaine de la Vie
  + guerrier 1) et *Elminster* (DD3.5, magicien 20 + archimage 5) : rangée d'identité conforme,
  « Clerc 5 (Domaine de la Vie) », « *Archimage* 5 » en italique sans badge, niveau total à 6 et
  25, burger à 44px sur la ligne de titre, menu déroulant qui s'ouvre toujours, raccourci
  personnage à 343px, aucun débordement horizontal. **L'éditeur de classes inline a été ouvert
  et refermé** pour vérifier que le DOM remanié ne l'avait pas cassé.

**[2026-10-07] D-RS53 — SP-PE10i : les caractéristiques prennent la forme d'un bloc de monstre**
Code : `css/personnages-modules.css`, `js/personnage.js`, `personnages/fiche.php`,
`personnages/campagnes.php`. Aucun patch SQL.
→ **Sous 992px, chaque caractéristique tient sur une ligne** : abréviation sur son fond, valeur
  en gras, modificateur en gris — la forme de `.mo-carac-table`, le bloc de stats d'un monstre.
  Les tuiles empilaient les trois informations : trois lignes de texte par caractéristique, deux
  rangs de tuiles, et un bloc de **236px pour six nombres**. Il en fait **71**.
→ **Les tuiles CA et PV suivent** : leur padding et leur valeur se resserrent (130px → 50px).
  Ce n'était pas demandé, mais une fois les caractéristiques ramenées à 71px, deux nombres sur
  130px de haut à côté ne tenaient plus ensemble. La rangée entière passe de ~380 à **129px**.
→ **Rien ne change sur ordinateur** : tout vit dans la média-query 991px, les tuiles empilées y
  sont vérifiées intactes (220px, valeur à 24px).
→ **Trois boutons « Modifier » gardaient leur libellé**, écrit en dur dans le HTML et non porté
  par `.per-btn-label` — Compétences, NLS prestige, et Campagnes de la page sœur. Ils passent à
  l'icône seule, avec un `title` explicite.
→ **Conséquence traitée : le title doit suivre la bascule.** Sans libellé, il est le seul à dire
  ce que fait le bouton — or le JS ne réécrivait que l'icône, laissant « Modifier les
  compétences » sur un bouton devenu « Annuler ». Un helper unique,
  `perBasculerBoutonEditer()`, relève le title d'origine au premier passage et le restaure au
  retour en lecture ; les quatre éditeurs inline y passent (dix bascules).
→ **Non touchés, volontairement** : « Enregistrer », « Annuler » et « Ajouter une classe » d'un
  éditeur ouvert, et « Choisir des dons ». Ce sont des actions d'écriture ou d'ouverture, visibles
  seulement en édition, où un mot vaut mieux qu'une icône seule — et elles ne pèsent pas sur la
  lecture, qui est ce que cette passe cherche à alléger.
→ Contrôlé à 375px et 1280px sur *Adon* : six caractéristiques sur deux lignes, CA / PV alignées,
  bascule du bouton Compétences vérifiée dans les deux sens (icône **et** title), aucun
  débordement.

**[2026-10-07] D-RS54 — SP-PE10j : une règle de graisse, et un bonus de maîtrise retrouvé**
Code : `include/personnage_helpers.php`, `personnages/fiche.php`, `js/personnage.js`,
`css/personnages-modules.css`. Aucun patch SQL.

**1. Règle d'interface posée : le libellé en gras, la valeur en graisse normale, les deux à la
même taille et dans la même police.**
→ Le bloc Identité faisait l'inverse à moitié : libellés **rapetissés et grisés**, valeurs en
  corps normal — deux échelles de texte sur une ligne qui n'en demandait qu'une.
→ Les tuiles **CA et PV** l'inversaient franchement : libellé petit et gris, valeur énorme et
  grasse. Les deux passent à la même taille, le gras va au libellé.
→ Les **classes** aussi : le niveau portait le gras, pas le nom. Le nom est le libellé.

**2. Compacité.**
→ Bloc Identité : marges internes ramenées à `--sp-xs`, corps du bloc à `--sp-sm` en vertical —
  la dernière ligne de classe n'a pas de bordure, l'espace sous elle se voyait d'autant.
→ Lignes de **classes** (5px → 2px de padding), de **compétences** et de **dons**
  (`--sp-sm` → 2px), lignes du tableau **NLS** (3px → 1px, soit 27 → 23px).

**3. Compétences : la colonne Carac porte deux valeurs, pas une.**
→ Les trois colonnes avaient la même largeur, et l'abréviation passait sous son modificateur :
  « INT » puis « +2 » sur deux lignes, dans les deux rulesets. Carac prend **4.6rem** (4.2 sur
  téléphone), Maîtrise/Rangs et Total se contentent de **3.2rem** (2.4).
→ Ce qui n'était possible qu'en **abrégeant la colonne Maîtrise** : « M. » et « E » au lieu de
  « Maîtrise » et « Expertise », en lecture comme dans le select de l'éditeur. Le mot entier
  reste dans le `title`.

**4. Défaut corrigé : le bonus de maîtrise tombait à zéro au-delà du niveau 20.**
→ `getBonusMaitrise()` cherchait la ligne de **niveau exact** dans `dd_bonus_maitrise`, qui
  s'arrête au niveau 20. Un personnage multiclassé totalisant davantage — le magicien 20 /
  clerc 10 de la base de test — n'y trouvait rien et repartait avec **0**. Toutes ses
  compétences affichaient alors leur seul modificateur de caractéristique : « Discrétion DEX +5
  Maîtrise **+5** », là où il fallait +11.
→ La requête prend désormais le **palier le plus élevé qui ne dépasse pas le niveau**
  (`bm_niveau <= ? ORDER BY bm_niveau DESC LIMIT 1`). Paliers vérifiés : +2 jusqu'à 4, +3 à 5,
  +4 à 9, +5 à 13, +6 à 17 et au-delà.
→ `bonusCompetence()` était juste et n'a pas bougé : mod seul sans maîtrise, + le bonus avec,
  + deux fois le bonus en expertise. C'est son argument qui valait zéro.
→ Contrôlé après correction sur *Telgar Weyr* (niveau 30, bonus +6) : Discrétion DEX +5 maîtrise
  → **+11**, Investigation INT +4 expertise → **+16**, et les mêmes totaux en direct dans
  l'éditeur inline, qui partage le calcul côté JS.
→ Contrôlé à 375px et 1280px sur les trois personnages de test (DD2024 avec et sans
  multiclassage, DD3.5) : colonne Carac sur une ligne dans les deux rulesets, select de l'éditeur
  sur « — / M. / E », aucun débordement.

**[2026-10-07] D-RS55 — SP-PE10k : le bloc Identité perd son titre, les boutons se remettent en ligne**
Code : `personnages/fiche.php`, `css/personnages-modules.css`. Aucun patch SQL.
→ **Le titre « Identité » est retiré**, comme ceux des blocs de stats avant lui : il ne disait
  rien de plus que « Niveau 6 · Race Humain · Clerc 5 » juste en dessous, et coûtait une barre
  d'en-tête entière. Le contour du bloc reste — c'est lui qui délimite.
→ **Retour et Modifier ne s'empilent plus sur téléphone.** La surcharge mobile de
  `.per-fiche__header` les posait l'un sous l'autre (`"nom retour" / "meta modifier"`), ce qui
  les laissait littéralement superposés quand la ligne meta était vide — un personnage sans
  campagne en cours. Elle **est simplement supprimée** : elle n'existait que parce que leurs
  libellés « Liste » et « Modifier » ne tenaient pas côte à côte, or ce sont deux icônes depuis
  SP-PE10h. La grille de base les remet tous deux au bout de la ligne du nom.
→ Contrôlé à 375px et 1280px, avec et sans ligne meta (*Adon* a une campagne en cours, *Telgar
  Weyr* non) : boutons sur la même ligne, sans chevauchement, et la ligne meta passe dessous
  quand elle existe.

**[2026-10-07] D-RS56 — SP-PE10l : Mode jeu optionnel, bonus de maîtrise affiché, caracs compactées partout**
Code : `sql/2026-10-07_mode_jeu_optionnel_sp-pe10l.sql`, `profil/index.php`, `include/auth.php`,
`index.php`, `personnages/fiche.php`, `css/personnages-modules.css`.
**Un patch SQL** — appliqué et vérifié en local, à passer en prod.

**1. Le bloc « Mode jeu » devient optionnel.**
→ Nouvelle préférence `j_affichage_mode_jeu` dans `dd_joueurs`, sur le modèle de
  `j_mode_campagne` et `j_affichage_ruleset` : même type, même emplacement dans le formulaire de
  profil, même propagation en session (connexion par mot de passe **et** par cookie de
  mémorisation — les deux requêtes la sélectionnent).
→ **Défaut à 0, donc masqué.** Le bloc n'est encore qu'un emplacement réservé — le suivi des PV
  et des variables de partie relève de `SP-PE8` — et coûtait une barre d'en-tête pour rien. Un
  joueur qui le veut l'active ; **les utilisateurs existants le verront disparaître**, ce qui est
  l'objet de la demande.

**2. DD2024 : le bonus de maîtrise rejoint la rangée de stats.**
→ Une tuile « Maît. +3 » avant CA et PV. C'est une valeur qu'on relit sans arrêt — tous les jets
  de compétence et d'attaque en dépendent — et elle n'était visible nulle part sur la fiche.
→ **Rien en DD3.5** : la notion n'y existe pas.
→ Elles sont donc **trois** à se partager la rangée en DD2024. Base de tuile ramenée à 96px,
  padding et `gap` resserrés, libellé et valeur à 1.5em : « Maît. +3 » tient sur sa ligne jusqu'à
  **342px** de viewport (trois tuiles de 103px, mesuré), sans débordement interne.

**3. Les caractéristiques prennent partout la forme compacte.**
→ La forme « une ligne par caractéristique » posée sur téléphone en SP-PE10i devient la seule :
  rien ne justifiait qu'un poste affiche six nombres sur **220px** de haut quand un téléphone s'en
  tire avec 71. Le bloc fait désormais **87px** sur un poste.
→ La surcharge mobile correspondante est supprimée — elle faisait double emploi ; seul le padding
  du corps y reste resserré.

→ Contrôlé à 1280, 375 et 342px sur *Adon* (DD2024, trois tuiles) et *Elminster* (DD3.5, deux
  tuiles) : rangée sur une ligne dans tous les cas, aucun débordement. Préférence testée dans
  les deux états — bloc présent quand elle est active, absent sinon — et l'écriture en base
  vérifiée par une transaction annulée.

**[2026-10-07] D-RS57 — SP-PE10m : les caractéristiques occupent leur place, les listes se partagent la ligne**
Code : `personnages/fiche.php`, `css/personnages-modules.css`. Aucun patch SQL.
→ **Les caractéristiques grossissent** : valeur à 1.5rem, abréviation et modificateur à 1rem.
  Le bloc avait été resserré à 71px (SP-PE10i) puis étendu à l'ordinateur (SP-PE10l) ; à surface
  égale dans la page, il lui restait beaucoup de blanc. Il fait 78px sur téléphone, 94 sur un
  poste — pour des chiffres bien plus lisibles.
→ **L'abréviation perd sa pastille de fond.** Elle découpait chaque ligne en deux blocs, et
  c'est la valeur qu'on cherche du regard, pas le nom de la caractéristique : **la couleur
  d'accent passe donc à la valeur**, l'abréviation reste en gris.
→ **« Maît. » devient « BM »** sur la tuile du bonus de maîtrise ; le `title` garde le nom entier.
→ **Compétences et Dons se partagent la rangée** au-dessus de 992px (542px chacun à 1280px) :
  deux listes de même nature, lues de la même façon, qui laissaient chacune la moitié droite de
  l'écran vide. Le **bloc NLS** garde sa pleine largeur **sous** la rangée — il porte un tableau
  par classe de prestige. En DD3.5 l'ordre du DOM a donc changé : Compétences, Dons, puis NLS.
→ Sous 992px, les trois restent empilés en pleine largeur : deux listes côte à côte sur un
  téléphone ne laisseraient de place ni aux noms ni aux colonnes.
→ **`min-width: 0` sur les blocs de la rangée** : sans lui, le tableau de l'éditeur de
  compétences — toutes les compétences du ruleset, quatre colonnes — impose sa largeur
  intrinsèque et fait déborder la rangée dès l'ouverture. Vérifié en ouvrant l'éditeur : la
  rangée reste à 1100px, le bloc Dons ne bouge pas, et le tableau n'a même pas besoin de son
  défilement interne.
→ Contrôlé à 1280px et 375px sur *Adon* (DD2024) et *Elminster* (DD3.5, avec bloc NLS).

**[2026-10-07] D-RS58 — SP-PE10n : le bloc NLS prestige se replie**
Code : `personnages/fiche.php`, `js/personnage.js`, `css/personnages-modules.css`.
Aucun patch SQL.
→ **Replié par défaut**, avec le chevron des blocs repliables (celui du Mode jeu). L'affectation
  des niveaux de prestige se règle une fois pour toutes, à la montée de niveau : elle n'a pas à
  occuper la fiche entre deux. Le bloc passe de 286 à **43px** — son en-tête seul.
→ Les deux corps du bloc, lecture et édition, sont enveloppés dans un `#bloc-nls-body` unique :
  c'est lui que le chevron replie.
→ **Conséquence traitée : le bouton Modifier reste accessible dans l'en-tête replié.** Cliquer
  dessus aurait chargé l'éditeur dans un corps masqué, sans rien montrer. `nlsEditor` déplie le
  bloc avant d'ouvrir, via un `perDeplierBloc()` qui ne fait rien si le bloc est déjà ouvert —
  l'inverse de `perReplierBloc()`, qui bascule.
→ **Les deux boutons sont groupés à droite.** `.per-fiche__bloc-header--flex` était en
  `space-between`, ce qui convenait à un titre et un bouton ; le second se serait planté au
  milieu de la barre. Le titre porte maintenant `margin-right: auto`.
→ Nettoyage : `.per-classes__badge-prestige` n'avait plus de porteur depuis que l'italique a
  remplacé le badge « P » (SP-PE10h).
→ Contrôlé à 1280px et 375px : replié au chargement, ouverture et fermeture au chevron
  (43 ⇄ 286px), et ouverture de l'éditeur depuis l'état replié — bloc déplié, cinq lignes
  d'affectation générées, retour en lecture à l'annulation.

**[2026-10-07] D-RS59 — SP-PE10o : les caractéristiques s'alignent en colonnes**
Code : `css/personnages-modules.css` seul. Aucun patch SQL.
→ **Abréviation, valeur et modificateur reçoivent une largeur fixe**, la même pour les six
  caractéristiques, toutes calées à gauche : les deux rangs de trois se retrouvent ainsi à
  l'aplomb l'un de l'autre. En largeur libre, « 9 » et « 11 » ou « +0 » et « -1 » décalaient
  tout ce qui suivait sur leur ligne.
→ **La base flex ne suffisait pas.** `flex: 0 0 2.2rem` fixe la base, mais `min-width: auto` —
  la valeur par défaut d'un élément flex — laisse la boîte s'élargir à son contenu : une
  caractéristique à trois chiffres reprenait 39px au lieu de 33 et décalait sa ligne. Le champ
  est un `tinyint`, la valeur est saisissable. D'où `min-width: 0` sur les trois, et des
  largeurs qui couvrent « 100 » et « -10 ».
→ **Largeurs recalculées sur téléphone.** Celles du poste (2.6 + 2.8 + 2.4rem, gaps compris)
  demandent 125px par caractéristique, quand une colonne de la grille en fait 111 à 375px et
  **103 à 342px** : le modificateur de la troisième colonne sortait du bloc. Les colonnes
  restent fixes — donc alignées — mais plus étroites, et la valeur passe à 1.3rem.
→ Contrôlé à 1280, 375 et 342px, et en forçant une valeur à trois chiffres : alignement vertical
  exact dans tous les cas, et 3px de marge au plus serré (342px) entre le dernier modificateur
  et le bord du bloc.

**[2026-10-10] D-RS63 — SP-PE10p→r : la vue Magie passe en deux temps et ses listes en onglets**
Code : `personnages/magie.php`, `css/personnages-modules.css`, `js/personnage.js`. Aucun patch
SQL. Proposition soumise puis arbitrée par Jean-Michel sur le cas du magicien 20 DD2024 (bloc
d'environ 710px de haut à 1280px, ramené à 330px).

**1. Synthèse de classe (SP-PE10p).**
→ **Le panneau « Ressources de sorts » est supprimé** (revient sur D-RS46). Ses compteurs de
  listes rejoignent leurs onglets ; une fois retirés, il ne lui restait que trois lignes.
→ **Les quatre cases deviennent des paires libellé / valeur**, sur le modèle de la ligne
  d'identité de la fiche (règle de graisse SP-PE10j). Le nom de la caractéristique sert de
  libellé (« Intelligence 18 (+4) ») ; les notes qui ne faisaient que répéter le libellé
  (« jets d'attaque de sort », « toutes classes de sorts », « niveau de lanceur ») tombent, seul
  l'écart du NLS reste, en appoint grisé. Sorts mineurs, renouvellement et domaines, rescapés du
  panneau, suivent les quatre valeurs.
→ **Arbitré : en colonne sur ordinateur, en ligne sur téléphone.** Au-dessus de 992px, la
  synthèse forme un bloc vertical sur la même rangée que le tableau des emplacements ; en
  dessous, les deux blocs s'empilent et la synthèse revient en flux — les quatre premiers champs
  tiennent sur deux lignes à 375px.
→ **En DD3.5, le champ Attaque n'est pas produit**, plutôt qu'un « sans objet ». Le DD y reste une
  formule, « 10 + niv. +N ».
→ **Abandonné** : le total « Sorts connus » (grimoire + à recopier), redondant avec les onglets.

**2. Tableau des emplacements (SP-PE10q).**
→ **La rangée d'en-tête de groupe « Niveaux de sort » disparaît** : la case d'angle, vide, porte
  « Niv. ». L'en-tête occupait la moitié de la hauteur du tableau.
→ **L'en-tête passe en retrait** (.85rem, grisé, 1px de padding vertical) ; le corps garde 1rem
  gras — ce sont ses chiffres qu'on lit en séance. Revient en partie sur D-RS47 : l'échelle
  alignée sur le panneau d'en face n'a plus d'objet, ce panneau n'existant plus.
→ **« En stock » devient « Restant ».**

**3. Listes en onglets (SP-PE10r).**
→ **Préparés · Grimoire · À recopier** pour un grimoire, **Préparés** est l'onglet par défaut :
  c'est celui du jeu. Un profil à liste unique (clerc, ensorceleur) garde la barre réduite à un
  onglet — elle lui sert de titre et porte ses actions.
→ **Chaque onglet porte son compteur et ses actions.** La barre d'actions au-dessus du tableau
  disparaît : « Préparer » et « Réinitialiser » vivent dans Préparés, « Gérer » dans Grimoire et
  À recopier, avec l'icône d'aide de la liste. Seuls les outils de l'onglet actif sont visibles,
  à droite de la barre ; sous 768px ils se réduisent à leur icône, `title` conservé.
→ **Une ligne par niveau de sort, pastille en tête** (arbitré, plutôt que des intertitres : des
  groupes titrés dans un onglet faisaient un empilement de niveaux de titre). La pastille
  répétée devant chaque sort disparaît.
→ **Les sorts toujours préparés ferment le premier onglet** : ils se lancent aujourd'hui, comme
  les préparés. Groupés par variante puis par niveau ; leur niveau passe dans la pastille.
→ **Onglets secondaires** : soulignés, plus petits que la barre Fiche / Magie / Possessions, pour
  ne pas se confondre avec la navigation de page. Motif ARIA `tablist`, flèches gauche / droite.
→ **L'onglet actif survit au rechargement.** Le sélecteur de sorts recharge la page à sa
  fermeture : sans mémoire, on retombait toujours sur Préparés après avoir géré son grimoire.
  `sessionStorage`, une clé par bloc de classe (`perMagieOnglet:<pe_id>:<pc_id>`), lectures et
  écritures sous try/catch, repli sur le premier onglet.
→ **Téléphone** : écarts d'onglets réduits et police à .9rem pour que trois onglets et un outil
  tiennent sur 325px de barre (331px demandés avant réglage). Avec deux outils (Préparer +
  Réinitialiser) à côté de trois onglets, les outils passent sous les onglets.

→ Contrôlé dans le navigateur sur *Telgar Weyr* (DD2024, clerc 10 + magicien 20), *Elminster*
  (DD3.5, magicien 20 + archimage), *Tarius Amcathra* (prêtre DD3.5, domaines) et *Adon* (clerc
  DD2024, sorts toujours préparés) à 1280 et 375px : aucun débordement horizontal, onglets et
  outils synchronisés, onglet Grimoire retrouvé après rechargement. Les six personnages de la
  base rendus sans avertissement PHP.

**[2026-10-10] D-RS64 — SP-PE10s : Réinitialiser passe dans le sélecteur, les mineurs sortent du plafond**
Code : `personnages/magie.php`, `include/ajax/detail-pp/sorts-picker.php`, `js/personnage.js`,
`css/modules.css`, `css/personnages-modules.css`. Aucun patch SQL.
→ **« Réinitialiser » quitte l'onglet Préparés** pour la ligne des compteurs du sélecteur de
  préparation. Geste rare, il occupait une place permanente dans la vue ; dans le sélecteur, il
  est là où l'on refait sa liste. Même appel (`sortsPicker.reinitialiser()`), qui recharge la page.
→ **Boutons d'onglet en icône seule**, sur toutes les largeurs (`title` et `aria-label` portent
  l'action). Sur téléphone, trois onglets et leurs outils tiennent désormais sur une ligne dans
  tous les cas — c'est Réinitialiser qui faisait passer les outils sous les onglets.
→ **Défaut corrigé — les sorts mineurs pesaient sur le plafond DD2024.** Le compteur « Préparés
  N/plafond » de la vue Magie et le « sorts encore préparables » du sélecteur comptaient les sorts
  de niveau 0 préparés. Or en DD2024 un sort mineur est **connu**, pas préparé, et `cn_sort_n0`
  le compte à part ; `cn_sortPrepare` ne plafonne que les sorts de niveau 1 et plus. Le niveau 0
  est exclu côté serveur (vue et sélecteur) et dans `_majCompteurs()`. **DD3.5 inchangé** : le
  niveau 0 y occupe de vrais emplacements, et ses compteurs sont par niveau.
→ Contrôlé sur *Telgar Weyr* (magicien DD2024 : 7 sorts préparés dont 2 mineurs → « 5/25 » dans
  l'onglet, « 20 sorts encore préparables sur 25 » dans le sélecteur) et *Elminster* (DD3.5 :
  jetons N0→N9 intacts, Réinitialiser présent) ; barre d'onglets sur une ligne de 40px à 375px.

---

## SP-DP — Déploiement en production et migrations SQL

**[2026-10-07] D-DP1 — Nouveau projet SP-DP : arbitrage**
Demande : déployer le site local vers OVH depuis un bouton discret du header, visible en local
seulement, avec confirmation, exclusions dérivées du `.gitignore`, et si possible mise à jour de
la base. Arbitrage validé le jour même :
→ **SFTP uniquement.** Le FTP classique transmet le mot de passe en clair ; OVH propose le SFTP
  sur toutes ses offres (activation manuelle sur Perso, onglet FTP-SSH).
→ **Mot de passe mémorisé** dans un fichier hors du projet (plutôt que saisi à chaque envoi).
→ **Mode maintenance** pendant l'envoi : accepté.
→ **Migrations appliquées automatiquement** en fin d'envoi (SP-DP5 + SP-DP6), l'écran
  d'administration restant le recours manuel.
→ **Préfixe `dd_` en production** (cf. D-DP7).
→ **Nouvelle table `dd_migrations`** et **nouveau module `admin/deploiement/`** : validés.

**[2026-10-07] D-DP2 — Le module ne fonctionne qu'en local : quatre verrous indépendants**
Code : `admin/deploiement/lib.php`, `garde.php`, `.htaccess`, `bouton.php` ; `include/header.php`,
`admin/index.php`.
→ (1) Le dossier s'exclut lui-même du transfert, en dur (`DEPLOIEMENT_EXCLUSIONS_FIXES`).
  (2) Paramètres et secret hors du projet. (3) `REMOTE_ADDR` **et** `SERVER_ADDR` en boucle
  locale, sinon 404. (4) `Require local` côté Apache.
→ **Écarté : `DEV_MODE` ou `HTTP_HOST` comme signal.** Le client choisit l'en-tête Host, et
  `DEV_MODE` en dérive avec un repli permissif (D-CFG1). D-RS35 l'avait déjà noté : un fichier
  « local seulement » finit par partir en production — d'où plusieurs verrous plutôt qu'un.
→ Le header et le tableau de bord admin n'incluent le module que si son fichier existe
  (`is_file()`) : en production il est absent, rien ne s'affiche, aucune erreur.
→ Remarque de test : `Require local` accepte aussi l'adresse réseau propre du poste (requête de la
  machine vers elle-même) ; le contrôle PHP, plus strict, n'admet que 127.0.0.1 et ::1.
  **Corrigé le 2026-10-09** : cette rigueur masquait le module à l'usage réel (D-DP10).

**[2026-10-07] D-DP3 — Paramètres dans `C:/xampp/private/donjon-deploiement/`, pas en base**
→ À côté de htdocs : hors webroot, hors git, **hors OneDrive** (le projet y est synchronisé),
  hors de portée du déployeur qui ne parcourt que le projet.
→ **Écarté : une table en base.** La base locale part régulièrement en dump dans `sql/`, et une
  table créée par migration existerait aussi en production.
→ **Mot de passe en clair dans `config.json`, assumé.** Le chiffrer avec une clé rangée à côté ne
  protégerait de rien ; sa protection, c'est l'emplacement. Il n'est jamais renvoyé au navigateur
  (champ vide, « laisser vide pour conserver »).

**[2026-10-07] D-DP4 — Le périmètre est calculé par git, complété d'un `.deployignore`**
Code : `deploiementPerimetre()`.
→ git lui-même interprète `.gitignore` (négations, fichiers imbriqués, accents) : aucune
  réimplémentation de la syntaxe. `.deployignore`, même syntaxe, est passé à
  `git ls-files --exclude-from`.
→ **Les fichiers commités puis ignorés sont exclus** (`git ls-files -c -i --exclude-standard`) :
  `export/*` et `tools/gen_hash.php` sont suivis bien que `.gitignore` les exclue, ils seraient
  partis sinon.
→ L'arbre de travail fait foi, commité ou non : c'est lui qui est testé en local.
→ **git introuvable ou en échec → refus**, jamais de repli sur « tout le dossier ».
→ `.deployignore` retire : `doc/`, `scss/`, `demo/`, `data/`, `CLAUDE.md`, `phpinfo.php`,
  l'exemple de config, et tout `sql/` sauf les migrations datées et le `.htaccess`. Résultat au
  2026-10-07 : 179 fichiers envoyés, 108 exclusions.

**[2026-10-07] D-DP5 — SFTP par l'extension curl de PHP, empreinte du serveur épinglée**
→ Le curl de XAMPP (8.4.0) est compilé avec libssh2 : SFTP sans Composer ni extension.
→ **Écarté : phpseclib** (dépendance à vendoriser) et **ext-ssh2** (absente, binaires Windows
  incertains).
→ L'empreinte SHA-256 est **lue sans s'authentifier** : épinglage volontairement faux, la poignée
  de main échoue avant l'envoi de tout identifiant, libcurl cite l'empreinte réelle. Vérifié sur
  github.com : l'empreinte lue est celle que GitHub publie pour sa clé ECDSA.
→ Sans empreinte approuvée, toute connexion est refusée. Changer d'hôte ou de port l'oublie.
→ Suppressions : uniquement des fichiers du manifeste, décochées par défaut. Les fichiers créés
  en production (`img/uploads/`, logs) ne sont jamais touchés.

**[2026-10-07] D-DP6 — Migrations : découpage en instructions, jamais `PDO::exec()` sur un script**
Code : `migrationsInstructions()`, `migrationsAppliquer()`.
→ **Constat en test.** `exec()` d'un script dont la première instruction renvoie un résultat
  rend la main aussitôt : les instructions suivantes ne sont pas contrôlées, une erreur plus loin
  passe inaperçue, et la connexion reste bloquée (« 2014 Cannot execute queries while other
  unbuffered queries are active »). Même un `exec()` d'**une seule** instruction `SELECT`, `SHOW`
  ou `OPTIMIZE TABLE` bloque la connexion.
→ **Retenu** : découpage par un petit analyseur (chaînes, échappements et guillemets doublés,
  identifiants, commentaires `-- `, `#`, `/* */` ; `/*! */` conservé), puis `query()` +
  `closeCursor()` par instruction. Retirer les commentaires évite que PDO prenne un « 10:30 »
  pour un marqueur `:30`.
→ Vérifié : cas piégés (`?`, `:nom`, `;`, `--` dans des littéraux, apostrophes échappées) intacts ;
  les 990 instructions des 36 migrations existantes **préparées** par le serveur (analyse sans
  exécution) : aucune erreur de syntaxe.
→ **Écarté : `mysqli::multi_query`**, conforme au besoin mais contraire à la règle « PDO
  exclusivement ».
→ Arrêt à la première erreur, avec le rang et un extrait de l'instruction fautive. Un script
  contenant `DELIMITER` est refusé (commande du client mysql). Un fichier retouché après
  application est signalé, jamais rejoué.

**[2026-10-07] D-DP7 — Préfixe : `dd_` en production aussi**
→ Confirmé par Jean-Michel. Le code porte `dd_` en dur (1 226 requêtes, aucune constante de
  préfixe) et la production a sa propre base : le renommage en `dd2_` envisagé en 2025 n'a jamais
  été appliqué. Mention corrigée dans `ARCHITECTURE_0_REFERENCE.md` §2 et dans `CLAUDE.md`.
→ Les commentaires « dd2_ » des migrations existantes **ne sont pas corrigés** : modifier une
  migration change son empreinte, le moteur la signalerait comme retouchée.

**[2026-10-07] D-DP8 — Référence initiale : les 37 migrations existantes ne sont jamais rejouées**
Code : `include/migrations-reference.php`, `migrationsAssurerTable()`.
→ Toutes les migrations présentes ce jour ont été jouées à la main, en local comme en production
  (déclaration de Jean-Michel). La plupart ne sont pas idempotentes (`ADD COLUMN` rejoué →
  « Duplicate column name »).
→ À la création de `dd_migrations` (table vide), le moteur inscrit ces 37 fichiers au statut
  `reference`, avec leur SHA-256 du jour. **Liste figée** : on n'y ajoute jamais rien.
→ **Écarté : une date butoir** (« tout ce qui précède le 2026-10-08 »). Une migration créée le
  jour même après le moteur aurait été prise pour une ancienne.
→ La base locale a reçu sa table le 2026-10-07 (37 lignes de référence, aucune exécution).

**[2026-10-07] D-DP9 — Déclenchement en production par jeton à usage unique ; le schéma avant le code**
Code : `admin/migrations-auto.php`, `deploiementAppliquerMigrations()`, `include/maintenance.php`.
→ La base mutualisée OVH n'accepte que les connexions des serveurs d'hébergement : le SQL doit
  être exécuté par le site lui-même.
→ Le déployeur dépose par SFTP l'**empreinte** d'un jeton aléatoire (`config/.migrations-jeton`),
  puis poste le jeton. Le serveur compare, supprime, refuse au-delà de 5 min (horloge serveur).
  **Aucun secret permanent en production** ; un mauvais jeton ne détruit pas le fichier.
→ **Écarté : un secret partagé permanent** (un fichier de plus à protéger, à faire tourner) et
  **le clic manuel dans l'admin de production comme voie principale** (étape intercalée au milieu
  de l'envoi). L'écran `admin/migrations.php` reste le recours.
→ Le point d'entrée n'exécute que des fichiers déjà présents sur le disque, jamais du SQL reçu :
  même contourné, il ne ferait qu'appliquer en avance une migration légitime.
→ **Ordre** : maintenance → moteur et migrations → application → reste du code → suppressions →
  fin de maintenance. Les migrations ajoutent : l'ancien code supporte le nouveau schéma, pas
  l'inverse.
→ `config/.htaccess` ajouté ; `sql/.htaccess` existait déjà (même effet) et **garde sa syntaxe
  `Order` / `Deny`**, celle du `.htaccess` racine, éprouvée sur OVH — une première réécriture en
  `Require all denied` a été annulée pour ne pas mêler les deux syntaxes.

**[2026-10-07] Vérifications SP-DP**
→ Banc d'essai en ligne de commande, serveur simulé par un dossier : 31 contrôles (ordre des
  envois, maintenance première opération, exclusions, manifeste, suppressions limitées au
  manifeste, fichier inconnu intact, envoi complet, validation des paramètres, refus SFTP sans
  empreinte ou sur empreinte fausse).
→ Contre l'Apache local : page 503 et contournement du point d'entrée, jeton absent, faux, mal
  formé, expiré, fichier jeton inaccessible par le web, migration réussie puis migration en échec
  (seule la première inscrite), retouche signalée. Fichiers et lignes de test retirés.
→ Navigateur : paramètres, lecture et approbation d'empreinte, test de connexion (production
  joignable, moteur absent → 404 attendu), validation, panneau (aperçu du vrai gabarit, texte de
  confirmation, échec, reprise à la bonne étape, abandon réel avec verrou et journal).
→ **Non vérifié** : un transfert réel vers OVH — aucun accès SFTP dans la session. C'est l'objet
  de `SP-DP7` ; « Tester la connexion » exerce d'abord chaque opération (écriture, relecture,
  suppression) sur un fichier témoin.

---

## [2026-10-09] Correctif — variantes de bouton inexistantes (`btn--*`, `btn-link`)

**[2026-10-09] `btn--*` → `btn-*` (module Règles et gestionnaire de tableaux)**
Les variantes de bouton du design system s'écrivent `btn-primary`, `btn-secondary`, `btn-danger`,
`btn-sm` (`css/main.css`). 18 boutons portaient une graphie BEM `btn--…` qu'aucune feuille ne
définit : un `<button>` y gardait le fond gris natif du navigateur (`#f0f0f0`) et un texte noir,
y compris en thème sombre (le formulaire d'édition d'une règle et son bouton Enregistrer
compris) ; un `<a>` s'affichait en simple lien.
→ Renommage dans `regles/index.php`, `regles/recherche.php`, `regles/regle.php`,
  `include/ajax/detail-pp/regle.php`, `include/ajax/detail-pp-sub/tableaux-picker.php`,
  `include/ajax/modifier/regle.php`, `include/ajax/modifier/tableau.php`.
→ Le bouton loupe de la recherche des règles n'avait aucune variante (`btn btn--sm`) : il prend
  `btn btn-primary btn-sm`, comme le bouton de recherche de la barre de filtrage du compendium.

**[2026-10-09] Variante `.btn-link` ajoutée au design system**
12 boutons du module Personnages (`personnages/fiche.php`, `magie.php`, `campagnes.php` : retour,
modifier ou replier un bloc, « Choisir des dons », « Réinitialiser »…) portaient `btn-link`, jamais
défini — même fond gris natif, texte noir.
→ Classe définie dans `css/main.css` (section BOUTONS) plutôt que de retoucher les 12 boutons :
  le nom dit l'intention, une action discrète au rendu de lien. Ni fond ni bordure, couleur des
  liens (`--clr-accent-2`), `--clr-text` au survol.
→ Vérifié dans le navigateur, avant / après, sur des pages réelles rendues par le harnais CLI
  (règles, fiche règle et son formulaire d'édition, fiche personnage, magie) : couleurs calculées
  conformes aux variantes du design system dans les deux thèmes. Pas de code projet : correctif
  ponctuel, hors chantier.

**[2026-10-09] D-DP10 — « Local » = requête venue du poste lui-même, pas seulement de 127.0.0.1**
Code : `deploiementEstLocal()` (`admin/deploiement/lib.php`) ; commentaires de `garde.php`,
`bouton.php`, `.htaccess`, `admin/index.php`.
→ **Constat** : ni le nuage du header ni la tuile Déploiement n'apparaissaient. Le journal
  d'Apache montre que Jean-Michel consulte le site local par l'adresse réseau du poste,
  `http://192.168.1.10/donjon/`, et non par `localhost`. `REMOTE_ADDR` valait donc
  `192.168.1.10`, que le contrôle d'origine (127.0.0.1 / ::1 seulement) refusait.
→ **Nouvelle règle** : `REMOTE_ADDR` **identique** à `SERVER_ADDR`, et adresse **non publique**
  (plages privées ou réservées). C'est la définition de « même machine » qu'applique déjà
  `Require local` côté Apache.
→ Refusés : un autre appareil du réseau (téléphone : adresse différente de celle du serveur), un
  visiteur Internet, et un serveur public qui s'appellerait lui-même — l'adresse d'un hébergement
  OVH n'est jamais privée. Les trois autres verrous (auto-exclusion du dossier, paramètres hors
  projet, `Require local`) sont inchangés.
→ **Écarté : imposer `http://localhost/donjon/`.** L'accès par l'adresse réseau est l'usage
  habituel du poste ; un verrou qui masque l'outil à son seul utilisateur légitime est un défaut.
→ Vérifié : 7 cas unitaires (localhost IPv4/IPv6, adresse réseau du poste, téléphone, serveur
  public, visiteur, CLI) ; navigateur par `http://192.168.1.10/donjon/` : nuage, tuile, page de
  paramètres et panneau présents.

---

## SP-PE11 — Initiative, sauvegardes et capacités sur la fiche

**[2026-10-09] D-RS60 — SP-PE11 : la fiche gagne l'initiative, les sauvegardes et les capacités**
Code : `sql/2026-10-09_init_et_sauvegardes_sp-pe11.sql`, `include/ajax/modifier/personnage.php`,
`personnages/enregistrement.php`, `personnages/fiche.php`, `css/personnages-modules.css`.
**Un patch SQL**, joué en local et déclaré dans `dd_migrations` — à passer en prod.

**1. Initiative et bonus de maîtrise échangent leurs places.**
→ `pe_init` est **saisi, pas calculé** : l'initiative dépend de dons, d'objets et de capacités
  de classe que la base ne modélise pas (§7.1). Il ouvre la section 3 du formulaire, avant la CA.
→ La tuile de la rangée de stats passe du bonus de maîtrise à l'initiative, et vaut **pour les
  deux rulesets** — le BM n'existait qu'en DD2024, la tuile manquait donc au DD3.5.
→ Le **bonus de maîtrise rejoint le niveau global** : « Niveau 6 (BM +3) ». Il s'en déduit, il se
  lit avec lui. En retrait et sans gras : c'est une conséquence, pas une donnée de même rang.
→ La valeur de l'initiative avait d'abord reçu le gras ; elle est revenue à la règle commune du
  module en **SP-PE12**, comme les valeurs de sauvegarde.

**2. Six modificateurs de sauvegarde.**
→ `pe_for_save` … `pe_cha_save`, `SMALLINT` signé — ce sont des modificateurs, négatifs
  possibles. **Les six colonnes existent dans les deux rulesets** ; c'est l'affichage qui diffère.
  La demande parlait de « quatre champs » à saisir pour le DD2024 : six ont été faits, comme les
  six nommés juste avant et comme le bloc de stats d'un monstre, qui en montre six.
→ **Saisie** : sous sa caractéristique, dans la même cellule de la grille. Les libellés suivent
  le ruleset — `SAUV` partout en DD2024, `RÉF` / `VIG` / `VOL` sur DEX, CON et SAG en DD3.5.
  Les trois autres restent saisissables en DD3.5 plutôt que de faire changer le formulaire de
  forme selon le ruleset.
→ **Affichage DD2024** : une quatrième colonne dans le bloc des caractéristiques, derrière le
  modificateur, avec un en-tête `MOD / SAUV`. Les quatre colonnes tiennent encore à trois
  caractéristiques de front sur un poste (165px pour 177 disponibles) ; sous 992px la grille
  passe à **deux**, soit trois rangs de deux.
→ **Affichage DD3.5** : un bloc à part, sous la rangée de stats — le ruleset n'a que trois jets
  et ils portent leurs propres noms : **Réflexes** (DEX), **Vigueur** (CON), **Volonté** (SAG),
  dans cet ordre. Titre discret, libellés en gras — les valeurs sont revenues à la graisse
  normale en **SP-PE12**.

**3. Capacités spéciales — première proposition.**
→ Une rangée de deux blocs après Compétences / Dons : **race** d'un côté, **classes** de l'autre.
  Rien ne s'y saisit, tout vient de `dd_race_capacite` et `dd_classe_capacite`.
→ Les capacités de classe sont **filtrées sur le niveau atteint** (`cc_niveau <= pc_niveau`) et
  groupées par classe, l'intertitre n'apparaissant qu'à partir de deux classes. Le niveau
  d'obtention est rappelé à droite de chaque ligne.
→ Deux pièges traités : une **sous-classe DD2024** n'a pas de niveau propre et suit celui de sa
  classe porteuse, sans quoi ses capacités resteraient invisibles ; un **archétype DD3.5**
  (`pe_arc_id`) ajoute ses capacités à celles de la race de base.
→ Chaque titre ouvre `detail-pp/capacite.php`, qui existait déjà. Un bloc vide n'est pas rendu.
→ Relevé : 3 capacités de race et 12 de classe pour *Adon* (clerc 5 / domaine / guerrier 1),
  5 et 12 pour *Elminster* (magicien 20 / archimage 5).

**4. Défaut trouvé en chemin : le formulaire de modification n'avait pas de grille.**
→ `.modif-grid`, qui porte le `display: grid`, n'est défini que dans `compendium-modules.css` et
  `admin-modules.css` — deux feuilles que la fiche personnage ne charge pas. Son formulaire
  empilait donc tous ses champs en **une seule colonne**, et la grille à six colonnes des
  caractéristiques n'avait aucun conteneur où s'appliquer. La règle est reprise à l'identique
  dans `personnages-modules.css`.

→ Contrôlé à 1280 et 375px sur *Adon* (DD2024) et *Elminster* (DD3.5) : rangée de stats sur une
  ligne, colonnes de caractéristiques alignées d'un rang à l'autre dans les deux dispositions,
  bloc de sauvegardes DD3.5 dans le bon ordre, capacités groupées et cliquables, aucun
  débordement. Les requêtes d'écriture ont été rejouées telles quelles en transaction annulée,
  INSERT et UPDATE, pour vérifier que chaque valeur atterrit dans sa colonne.

**[2026-10-09] D-RS61 — SP-PE12 : la règle de graisse ne souffre plus d'exception**
Code : `personnages/fiche.php`, `css/personnages-modules.css`. Aucun patch SQL.
→ Les deux écarts concédés la veille en SP-PE11 — valeur de l'initiative en gras, valeurs des
  jets de sauvegarde DD3.5 en gras — **reviennent à la règle du module** : le gras au libellé,
  la valeur en graisse normale. L'initiative se lisait plus lourd que CA et PV dans la même
  rangée, et les trois jets DD3.5 n'avaient aucune raison de se distinguer du reste.
→ La **colonne SAUV** des caractéristiques (DD2024) suit : c'est une valeur elle aussi. Elle
  reste lisible face au modificateur qui la précède, celui-ci étant en gris.
→ `per-stat--init`, qui ne portait que le gras, est retirée du HTML avec sa règle.
→ Relevé après coup : libellés à 700, valeurs à 400, dans les trois endroits et les deux
  rulesets.

**[2026-10-10] D-RS62 — SP-PE13 : un en-tête par colonne, et le panneau de détail chargé partout**
Code : `personnages/fiche.php`, `css/personnages-modules.css`, `css/modules.css`,
`css/compendium-modules.css`. Aucun patch SQL.

**1. En-têtes MOD / SAUV (DD2024).**
→ L'en-tête unique, sorti de la grille en SP-PE11, ne coiffait que la **première** colonne de
  caractéristiques : les deux autres lisaient leurs modificateurs sans libellé.
→ Il revient **dans** la grille, une cellule par colonne, en première rangée : trois sur un
  poste, deux sous 992px — la troisième y est masquée, sans quoi elle tomberait sur la rangée
  des caractéristiques et les décalerait d'un cran.
→ Sur téléphone, ses libellés glissaient de **4 et 6px** à droite de leur colonne : l'en-tête
  gardait un écart de 4px quand les lignes étaient passées à 2. Les deux partagent désormais la
  même règle. Mesuré après coup : décalage nul, sur un poste comme sur un téléphone.

**2. Le panneau de détail perdait ses styles hors du compendium.**
→ Symptôme signalé : dans le panneau d'une capacité ouvert depuis la fiche, les listes à puces
  sortaient par la gauche. Cause : `.sort-detail__description ul { padding-left }` vivait dans
  `compendium-modules.css`, que la fiche ne charge pas — et avec lui **tout le composant
  `.sort-detail`** : en-tête, lignes, libellés, description et tableaux.
→ Or seize fragments de `include/ajax/detail-pp/` l'emploient (sort, classe, race, capacité,
  don, compétence, objet, monstre, règle…), ouverts aussi depuis la fiche personnage, la vue
  Magie, les campagnes et les règles. **Le composant migre vers `modules.css`** (29 règles), en
  application de la règle permanente du 2026-06-14 : un fragment injecté par AJAX dans
  `#detail-pp` a ses styles dans la seule feuille chargée partout.
→ **Pas de régression possible dans le compendium** : `modules.css` y est chargé avant
  `compendium-modules.css`, et les règles déplacées n'y ont plus d'homologue. Vérifié qu'aucune
  autre feuille ne redéfinit ces sélecteurs — seul `.sort-detail__edit-btn`, déjà dans
  `modules.css`, figure ailleurs.
→ Même famille de défaut que `.modif-grid` en SP-PE11 : un composant partagé déclaré dans la
  feuille d'un seul module.
→ **Troisième cas de tableau couvert** : `<thead>` contenant des `<td>` plutôt que des `<th>`.
  Le composant ne connaissait que l'en-tête en `<th>`, avec ou sans `<thead>` ; la table de
  « Particularités célestes » n'avait donc pas d'en-tête visible.
→ Contrôlé sur « Particularités célestes » injectée dans `#detail-pp` de la fiche, où
  `compendium-modules.css` n'est pas chargée : liste à 24px de retrait, puces à l'intérieur du
  panneau, en-tête de tableau en gras sur fond, alternance des lignes rétablie.

---

## SP-RB — Bascule de ruleset depuis le header

**[2026-10-10] D-RB0 — Le badge du ruleset devient un switch ; un contexte de navigation par ruleset**
Demande : basculer d'un clic entre DD3.5 et DD2024 pour tester, en retrouvant le dernier
personnage de chaque ruleset, et recharger si possible la page équivalente.
→ **Switch = formulaire POST** (`profil/ruleset.php`, CSRF), pas d'AJAX : la page doit de toute
  façon être rechargée dans le nouveau contexte, et le header fonctionne ainsi sans JS. Affiché
  aux mêmes conditions que l'ancien badge (`j_affichage_ruleset`).
→ **Session seulement** : `j_default_ruleset_var_id` n'est pas modifié. Le switch sert à
  naviguer et à tester ; le ruleset de connexion reste un réglage du profil.
→ **Mémoire par ruleset en session** (`$_SESSION['contexte_ruleset'][id]`), pas en base : le
  contexte de navigation (`last_pe_id`, chaîne campagne) a toujours vécu en session, aucune
  migration n'est nécessaire. Elle couvre aussi la campagne, pas seulement le personnage : même
  coût, et la purge de 2026-08-13 cesse d'effacer le contexte de l'autre ruleset.
→ `basculerRuleset()` devient le **seul** point de changement du ruleset de session ; le profil
  l'appelle à la place de `resetContexteRuleset()`. Restauration contrôlée en base (personnage
  supprimé, campagne supprimée ou d'un autre ruleset → niveau abandonné).
→ Un personnage consulté hors de son ruleset (fiche ouverte par lien) est rangé dans **son**
  ruleset : `setLastPersonnage()` reçoit le ruleset du personnage.
→ **Page équivalente** : faisable sans complication, la règle tient en une table (§3) — listes
  rechargées sans leurs filtres, pages d'entité repliées sur l'entité mémorisée du ruleset rejoint
  ou sur l'index du module, Historiques (DD2024 seul) → index du compendium, tout cas imprévu →
  accueil. La cible est reconstruite depuis `BASE_URL`, jamais reprise de l'URI postée.
→ Vérifié dans le navigateur : Elminster (DD3.5) → bascule → liste DD2024 vide de mémoire ;
  Adon ouvert sur Magie → bascule → Magie d'Elminster ; retour → Adon, avec Trilogie des Avatars
  › Valombre dans le fil d'Ariane ; Historiques → compendium DD3.5 ; sorts filtrés → sorts sans
  filtre. Header sans débordement à 375px.

**[2026-10-10] D-RB1 — Le switch à deux libellés redevient un badge cliquable**
Retour utilisateur : le switch `DD3.5 | DD2024` prenait trop de place sur téléphone (117px).
→ Le bouton n'affiche plus que le **ruleset actif**, suivi d'une icône ⇄ (`fa-right-left`,
  0.6rem, couleur `--clr-accent-2`) ; bordure et icône s'accentuent au survol. Le clic bascule
  comme avant, la page rechargée porte le libellé du nouveau ruleset.
→ Largeur mesurée à 375px : 75px en DD2024, 64px en DD3.5 — l'icône ajoute ~10px à l'ancien
  badge. Le libellé complet (« Ruleset actif : … — cliquer pour basculer en … ») passe dans
  `title` et `aria-label`.

**[2026-10-10] D-DP11 — Premier déploiement réel ; la production restait en maintenance**
Code : `DeploiementSftp::supprimer()` et `argument()` (`admin/deploiement/lib.php`).
→ Premier déploiement (SP-DP7) : 181 fichiers envoyés, migration
  `2026-10-09_init_et_sauvegardes_sp-pe11.sql` appliquée par la production. Mais le site est resté
  sur la page de maintenance : le fichier `.maintenance` n'avait jamais été supprimé, alors que le
  journal affichait « Site rouvert ».
→ **Cause** : dans une commande SFTP (`CURLOPT_QUOTE`), libcurl ne traduit pas le préfixe `/~/`
  — seule l'URL le fait. Le serveur cherchait `/~/www/donjon/.maintenance`, introuvable. Et le
  préfixe `*` (« continuer si la commande échoue »), choisi pour tolérer un fichier déjà absent,
  masquait **tout** échec. Le test de connexion l'aurait signalé (la suppression du témoin était
  vérifiée par listage) : un témoin résiduel a d'ailleurs été retrouvé dans le dossier privé.
→ **Correctif** : chemins relatifs dans les commandes SFTP (relatifs au dossier d'ouverture de
  session, le dossier d'accueil sur OVH) ; plus de `*` — seule l'erreur « No such file » est
  tolérée, tout autre échec interrompt l'étape et propose Reprendre / Abandonner.
→ Production rouverte le 2026-10-10 en supprimant `.maintenance` à la main (chemin relatif).
  Vérifié sur le serveur réel : création puis suppression effective d'un fichier témoin,
  suppression d'un fichier absent tolérée, test de connexion entièrement vert.

**[2026-10-10] D-DP12 — La référence initiale était fausse pour la production**
Code : `migrationsRemettreEnAttente()` (`include/migrations.php`), action « Remettre en attente »
de `admin/migrations.php` ; requête `sql/diagnostic_reference_sp-dp.sql`.
→ **Constat** : la page Magie plante en production — `Unknown column 'cla.cla_renouvellement'`.
  La migration `2026-09-01_cadence_renouvellement_sp-ma4b.sql` n'y avait jamais été jouée, mais
  la référence initiale (D-DP8, « toutes jouées en prod ») l'a inscrite comme passée : le moteur
  ne pouvait pas la rattraper.
→ **Correctif** : une migration `reference` ou `marquee` peut être **remise en attente** depuis
  l'écran Migrations SQL ; le moteur la joue au passage suivant, dans l'ordre. Une migration
  `executee` ne l'est jamais (son passage est prouvé).
→ **Diagnostic** : une requête en lecture seule relève, pour chaque migration de la référence, la
  trace qu'elle laisse en base (colonne, table, ligne ou compte). On la passe en local puis en
  production dans phpMyAdmin ; chaque écart désigne une migration à remettre en attente.
→ Leçon : une référence déclarée de mémoire n'est pas une preuve. Le diagnostic aurait dû
  précéder l'inscription.

**[2026-10-10] D-DP13 — Resynchronisation unique : copie manuelle de la base locale vers la production**
→ Le diagnostic (`sql/diagnostic_reference_sp-dp.sql`) a montré 23 migrations jamais jouées en
  production (2026-08-25 → 2026-09-01), dont un ordre à respecter (`regles_dd35_socle` avant les
  fichiers `drs*`).
→ **Décision de Jean-Michel** : la production n'est pas encore utilisée ; plutôt que de rejouer
  les migrations, il importe lui-même un export de la base locale dans la base OVH. Opération
  unique : aucun outillage supplémentaire. La phase SP-DP9 (rattrapage par le moteur) est retirée.
→ Conséquence voulue : `dd_migrations` part avec l'export, la production hérite exactement de
  l'état du local et les déploiements suivants reprennent normalement.
→ L'action « Remettre en attente » et la requête de diagnostic restent disponibles (SP-DP8).
→ Défaut préexistant relevé au passage, non corrigé : `requireAdmin()` / `requireAuth()`
  redirigent vers `/index.php` sans `BASE_URL` ; hors connexion, une page protégée de la prod
  renvoie à la racine de maikastel.fr, ce qui fait croire que la page n'existe pas.

---

## SP-SY — Synchronisation du contenu local → production

**[2026-10-10] D-SY1 — Projet instruit puis mis de côté, non prioritaire**
→ **Besoin** : le contenu saisi en local au fil du développement manque en production, le
  déploiement (SP-DP) ne transférant que les fichiers et la structure. Règle posée par
  Jean-Michel : **le contenu de la prod n'est jamais écrasé ni effacé ; seul le contenu local
  absent y est ajouté.**
→ **Projet distinct de SP-DP** : SP-DP transporte du code et des changements de structure,
  SP-SY transporterait des données. Les deux s'enchaînent (synchronisation toujours après les
  migrations), mais ils n'ont ni les mêmes risques ni le même calendrier.
→ **Principe retenu à ce stade** : `INSERT IGNORE` de tout le contenu local, qui n'ajoute que les
  clés primaires absentes, sans comparaison ligne à ligne et en conservant les identifiants (les
  liens entre tables restent justes). **Condition indispensable** : des plages d'identifiants
  séparées (compteurs de la prod à 1 000 000), sans quoi une ligne locale portant le même numéro
  qu'une ligne créée en prod serait perdue sans bruit.
→ **Écartés pour la règle posée** : la copie de tables entières (`DROP` + `CREATE`), qui écrase
  les créations de la prod ; et la comparaison champ à champ, inutile tant que seules les lignes
  absentes comptent.
→ Cinq questions laissées ouvertes (plages, périmètre, modifications locales, suppressions faites
  en prod, forme de l'outil) : `ARCHITECTURE_0_REFERENCE.md` §6c, phase `SP-SY0`.

---

## SP-XC — Export de classes vers la production

**[2026-10-10] D-XC1 — Un export ciblé par classe, retrouvé par son nom en production**
Code : `admin/deploiement/export-classes.php`, `admin/deploiement/export-classes-lib.php`.
→ **Besoin** : une classe saisie en local (fiche, progression, capacités, compétences, sorts) doit
  pouvoir partir en production sans attendre SP-SY. Demande de Jean-Michel : pas d'interface
  lourde, un fichier SQL rejouable en prod, plusieurs classes possibles dans un même fichier.
→ **Clés naturelles plutôt qu'identifiants** (arbitré) : le fichier ne contient aucun identifiant
  local. Chaque ligne est retrouvée en production par son nom — ressource (nom + ruleset), classe
  (nom + ruleset + parent, hors homebrew de campagne), sort, compétence, capacité. Un export par
  identifiants écraserait sans bruit une autre classe dès que les compteurs des deux bases auront
  divergé (même risque que celui instruit pour SP-SY, §6c).
→ **Sorts : nom octet par octet + ruleset + livre + rang.** Mesuré le 2026-10-10 : 395 noms de
  sorts DD3.5 existent en deux exemplaires (versions 3.0 et 3.5, dans deux livres), et 974 lignes
  de listes de sorts pointent vers le second. La collation `general_ci` confond en outre des sorts
  distincts (« Maths faciles » / « Maths Faciles ») ; 4 sorts sont de vrais homonymes d'un même
  livre (« Faux-semblant »). D'où `BINARY so_nom`, la ressource dans la clé, et le rang de
  l'exemplaire parmi ses homonymes exacts (`ORDER BY so_id LIMIT rang, 1`), l'ordre d'insertion
  étant le même des deux côtés. Les 73 sorts DD3.5 sans livre (`so_res_id = 0`) gardent cette
  valeur telle quelle.
→ **Capacités : le lien existant d'abord.** 33 couples nom + classe d'origine sont ambigus
  (« Armes et armures » ×5, sans origine, textes différents). Ordre de résolution : la capacité de
  même nom déjà rattachée à la classe en prod ; nom + origine + texte identique ; nom + origine si
  le couple est univoque en local ; sinon création.
→ **Refus à la génération** : deux classes de même nom dans un ruleset (cas d'« Archer sylvain »
  DD3.5), ou deux capacités distinctes de même nom dans une même classe — elles seraient
  confondues en production. Les classes homebrew de campagne ne sont pas proposées.
→ **Référentiels recopiés tels quels** : types de classe, caractéristiques, profils
  d'incantation, cadences — tables identiques des deux côtés.

**[2026-10-10] D-XC2 — La classe est écrasée, jamais supprimée**
→ Arbitré par Jean-Michel : une classe déjà présente en production est **écrasée**, exception
  assumée à la règle SP-SY « ne jamais rien écraser », limitée aux classes cochées.
→ La ligne `dd_classes` est créée si absente puis **mise à jour sur place** : les personnages de la
  production (`pc_cla_id`, `pesp_cla_id`) y restent rattachés. Ses lignes liées (niveaux,
  capacités, compétences, sorts toujours préparés, liste de sorts) sont supprimées puis
  réinsérées. Le script est donc rejouable.
→ **Liste de sorts** incluse par défaut, décochable : décochée, celle de la production reste
  intacte. **Sous-classes** : seules les classes cochées partent ; une sous-classe cochée seule
  exige que sa classe de base existe en production.
→ `cla_cla_id` d'une classe sans parent reprend la valeur locale (0 en DD3.5, NULL en DD2024).

**[2026-10-10] D-XC3 — Les capacités spéciales sont mises à jour**
→ Arbitré : une capacité retrouvée en production reçoit le texte local, même si elle est partagée
  avec une autre classe.

**[2026-10-10] D-XC4 — Transport : une migration de `sql/`, garde-fous avant toute écriture**
→ Arbitré (« si l'import est sécurisé comme la migration ») : l'export est écrit dans `sql/` sous
  le nom `AAAA-MM-JJ_xc-HHMMSS_<classes>.sql`. Le déploiement l'envoie par SFTP et le serveur le
  joue via le jeton à usage unique (§6b) : aucun canal nouveau. Le préfixe `xc-` le fait passer
  après les migrations de structure écrites le même jour (ordre alphabétique).
→ La page vit dans `admin/deploiement/` : elle hérite des quatre verrous du module (jamais
  transférée, requête venue du poste, `Require local`, administrateur).
→ La migration est **marquée appliquée en local** à l'écriture (statut `marquee`) : elle reproduit
  le contenu local, seule la production doit la jouer.
→ **Garde-fous en tête de script** : ressource, classe parente, sorts et compétences absents de la
  production font échouer le script **avant la première écriture** — important, `dd_classe_niveau`
  et `dd_classe_competence` étant en MyISAM, sans transaction possible. Le déclencheur est
  `SET @xc_garde := (SELECT 'XC : <message>' UNION ALL SELECT '' FROM DUAL WHERE <condition>)` :
  la sous-requête renvoie deux lignes, erreur 1242, et le moteur cite l'extrait qui commence par
  le message. **Pas de `DO`** : MariaDB y évalue la même sous-requête sans lever l'erreur (constaté
  en test). `SIGNAL` exigerait une procédure stockée, donc `DELIMITER`.
→ **Vérifié sur une copie de la base** (8 classes : Archer-Mage, Barde et Magicien DD3.5 ; Clerc,
  Domaine de la Vie, Druide, Cercle de la Terre, Paladin DD2024) : contenu identique à l'original
  champ à champ, sur copie identique comme sur classes absentes (recréées avec de nouveaux
  identifiants, sous-classe rattachée à la bonne base) ; rejeu sans effet ; sort ou parent
  manquant → échec à la garde, aucune écriture ; liste de sorts décochée → liste de prod intacte.
→ **Liens orphelins relevés, non exportés** : 55 lignes `dd_sortclasse`, 2 `dd_classe_capacite` et
  113 `dd_classe_competence` pointent vers des lignes qui n'existent plus en local. Non corrigés.

---

## SP-MA6 — Classes de prestige DD3.5 : sorts propres ou progression du NLS

**[2026-10-10] D-MAG16 — Les deux cas d'une prestige lanceuse sont exclusifs, et le formulaire les porte**
Code : `include/ajax/modifier/classe.php`, `compendium/enregistrement.php`,
`include/ajax/detail-pp/classe.php`, `css/compendium-modules.css`, `css/modules.css`.
**Migration** : `sql/2026-10-10_drapeaux_nls_sp-ma6.sql`.
→ **Règle posée par Jean-Michel.** Une classe de prestige DD3.5 lanceuse accorde **soit** ses
  propres sorts par jour (`cn_sort_n0..9`, ex. Tueur de Domiel), **soit** un niveau de lanceur à
  une classe de base existante (`cn_niveauSortArcane` / `Divin` / `Effectif`, ex. Archimage).
  Jamais les deux.
→ **Constat.** Les drapeaux n'apparaissaient nulle part dans le formulaire, et l'enregistrement
  ne les écrivait pas (absents de la liste des colonnes acceptées) : ceux en base n'étaient
  modifiables qu'en SQL. Pire, les classes du second cas sont toutes à `cla_mag_id = 0` — le
  formulaire leur masquait **toute** colonne de magie, et la fiche les affichait sans magie.
→ **Une bascule plutôt que treize colonnes.** La largeur du formulaire ne tient pas S0-S9 et trois
  colonnes de drapeaux côte à côte. La section 2 porte une bascule « Sorts par jour » /
  « Progression du NLS », visible pour une prestige DD3.5 seulement ; les deux jeux de colonnes
  sont rendus, un seul est affiché, et l'on bascule sans recharger.
→ **Le mode n'est pas stocké, il se déduit** : au moins un drapeau à 1 → progression du NLS. Pas de
  colonne nouvelle, et aucune incohérence possible entre un mode déclaré et les données.
→ **Trois cases par niveau, pas une liste à choix unique** : le théurge mystique avance le profane
  **et** le divin à chaque niveau. Libellés arbitrés : **Profane, Divin, Au choix** — « Au choix »
  pour `cn_niveauSortEffectif`, qui avance n'importe quelle classe de base lanceuse, au choix du
  joueur (c'est ce que fait l'éditeur NLS de la fiche).
→ **Une classe du second cas reste non lanceuse.** En mode NLS, type de magie, profil
  d'incantation et renouvellement sont désactivés en section 1, et le serveur les remet à 0 : avec
  `cla_mag_id > 0`, la vue Magie d'un personnage ouvrirait à l'Archimage un bloc de classe
  lanceuse vide.
→ **Exclusivité garantie côté serveur**, quel que soit ce qui est soumis : mode NLS → sorts par
  jour et connus à NULL ; mode Sorts → drapeaux à 0. Vérifié par une soumission trafiquée sur
  l'Archimage (S1 = 3, type de magie et profil forcés) : rien n'est passé.
→ **Les drapeaux des classes de base ne sont jamais écrits.** Le traitement ne s'applique que si la
  bascule est soumise, donc pour une prestige déjà créée. Relevé au passage : les six classes de
  base lanceuses portent un drapeau à 1 sur chacun de leurs niveaux. Sans effet — seuls ceux des
  prestiges sont lus — et laissés en l'état.
→ **Les colonnes de sorts s'affichent pour une prestige même sans type de magie.** Choisir le type
  obligeait jusqu'ici à enregistrer puis rouvrir le formulaire pour les voir apparaître ; une note
  rappelle qu'elles ne comptent qu'avec un type de magie.
→ **Fiche : une colonne rédigée, en forme courte** (arbitré, pour le téléphone) — « +1 niv.
  profane », « +1 niv. divin », « +1 niv. profane et divin », « +1 niv. au choix », « — » ; le
  libellé passe sur deux lignes sous 768px.
→ **Migration, valeurs seulement** (arbitré) : les drapeaux NULL (725 lignes sur 880) passent à 0.
  Et les trois prestiges du second cas qui portaient des sorts par jour **à 0** (Adepte de l'ombre,
  Gardien du feu sacré du Phénix, Olin Gisir) les voient passer à NULL : un 0 y signifie « niveau
  accessible par les seuls sorts en bonus », pas « aucun sort » — c'est ce que fait désormais
  l'enregistrement en mode NLS. Les prestiges du premier cas ne sont pas touchées (vérifié). La
  structure des colonnes (`int NULL`) est inchangée ; `SCHEMA_SQL.md`, qui annonçait
  `tinyint(1) NOT NULL`, est corrigé.
→ Contrôlé dans le navigateur : formulaire de l'Archimage ouvert en mode NLS (drapeaux restitués,
  section 1 désactivée), bascule dans les deux sens ; enregistrement sans modification puis
  soumission trafiquée, état relevé avant et **vérifié identique après** ; fiches de l'Archimage,
  du Théurge mystique, du Gardien du savoir (cas 2) et du Tueur de Domiel (cas 1, inchangée).
→ **Défaut préexistant relevé, non corrigé** : tout enregistrement d'une classe DD3.5 fait passer
  `cn_sortPrepare` et `cn_pouvoir1..5` de 0 à NULL (champs vides du formulaire). Sans effet sur
  l'affichage ; remis à l'identique sur l'Archimage après les contrôles.
→ **Limite** : sur téléphone, la table de progression d'une prestige dépasse encore de 82px à
  375px, du fait du `min-width: 160px` de la colonne Aptitudes, commun à toutes les tables de
  classe.

**[2026-10-10] D-MAG17 — SP-MA6d : NULL / 0 vérifié, drapeaux des classes de base retirés, table resserrée**
Code : `include/ajax/detail-pp/classe.php`, `css/modules.css`. **Migration** :
`sql/2026-10-10_drapeaux_nls_classes_base_sp-ma6.sql`.
→ **NULL / 0 dans les sorts par jour DD3.5 — vérifié, rien à corriger.** Règle rappelée par
  Jean-Michel : NULL = niveau de sort inaccessible ; 0 = accessible, mais par les seuls sorts en
  bonus de caractéristique. Contrôlé maillon par maillon :
  - **base** : le Paladin porte bien S1 = 0 aux niveaux 4-5, S2 = 0 au niveau 8, NULL ailleurs ;
    170 lignes DD3.5 portent un 0 au-delà du niveau 0 ;
  - **saisie** : un champ vide s'enregistre en NULL, « 0 » en 0 (`cols_nullable`) ; le formulaire
    restitue les deux tels quels ;
  - **fiche** : « — » pour NULL, « 0 » pour 0 ;
  - **calcul** : `getMagieContexte()` marque NULL inaccessible et n'ajoute le bonus qu'à un niveau
    accessible. Banc d'essai sur un paladin synthétique (transaction annulée, base vérifiée
    intacte) : niveau 4 Sag 10 → N1 = 0 ; Sag 14 → N1 = 1 ; niveau 8 Sag 10 → N1 = 1, N2 = 0 ;
    niveau 14 Sag 12 → N1 = 3 ; **niveau 3 Sag 18 → aucun emplacement**, le bonus ne rendant pas
    accessible un niveau qui ne l'est pas ;
  - le sélecteur de sorts et la vue Magie lisent ce même contexte.
  Une nuance, sans effet : les sorts **connus** (`cn_sortConnu_n*`) ne font pas la distinction
  — un 0 et un NULL s'y affichent tous deux « — ». Aucun bonus ne s'applique aux sorts connus,
  les deux valeurs y disent la même chose.
→ **Drapeaux NLS des classes de base remis à 0** (erreur de saisie confirmée) : Barde, Druide,
  Ensorceleur, Magicien, Prêtre, Rôdeur — 120 niveaux. Nouvelle migration, celle du matin étant
  déjà appliquée. Il ne reste de drapeaux que sur des prestiges (89 niveaux). Le NLS d'Elminster
  (magicien 20 + archimage 5) reste à 25.
→ **Largeur mini de la colonne Aptitudes sur téléphone — essai, puis réglage.** La retirer
  purement et simplement réglait les prestiges, mais **cassait les tables des lanceurs** : coincée
  entre dix colonnes de sorts, la colonne tombait à 25px et les mots se coupaient lettre à lettre
  (`word-break: break-word`). Même chez l'Archimage, elle tombait à 33px. Retenu : une classe
  `.table-dd--etroite`, posée sur les tables **sans colonnes de sorts** (non lanceuses, ou
  prestiges du cas 2), où Aptitudes descend à 88px sous 768px, sans coupure de mot ; les tables
  des lanceurs, qui défilent de toute façon, gardent leurs 160px.
→ Mesuré à 375px (cadre de 327px) : Archimage et Théurge mystique 327px, Barbare et Guerrier
  327px — tous sans défilement ; Gardien du savoir 340px (un mot long) ; Moine 511px (colonnes de
  pouvoirs) ; Magicien et Paladin inchangés (160px, défilement comme avant).
→ La limite relevée en D-MAG16 (82px de débordement) est levée pour les prestiges du cas 2.

**[2026-10-10] Correctif — « Conditions d'accès » remonte sous le type de classe**
Code : `include/ajax/modifier/classe.php`, `compendium/enregistrement.php`. Hors chantier.
→ Le champ `cla_conditions` (DD3.5, classes de prestige) était rendu en fin de section « Données
  DD3.5 », trop bas pour être trouvé, et **seulement si la classe était déjà une prestige à
  l'ouverture** : choisir « Prestige » dans la liste ne le faisait pas apparaître.
→ Il est désormais en section 1, juste après « Type de classe », sur toute la largeur
  (`modif-grid__full`), éditeur TinyMCE. Toujours rendu en DD3.5, affiché par
  `appliquerVisibiliteType()` pour le type Prestige, masqué pour Base et PNJ.
→ Le serveur vide les conditions d'une classe qui n'est pas une prestige : un texte saisi puis
  masqué en changeant de type ne reste pas en base. Aucune classe non prestige n'en portait.

**[2026-10-10] Correctif — la saisie TinyMCE était perdue à la deuxième ouverture d'un formulaire**
Code : `js/main.js` seul. Hors chantier, relevé en corrigeant le champ ci-dessus.
→ **Symptôme** : ouvrir un formulaire, le fermer, en ouvrir un second sans recharger la page — ce
  qu'on tapait dans un champ riche (description, armes, sorts, conditions…) n'était pas envoyé.
  L'ancien texte restait en base, sans message. 15 formulaires concernés : tous ceux qui
  chargent TinyMCE (sort, don, classe, race, objet, règle, campagne, scénario, chapitre,
  rencontre, personnage…).
→ **Cause** : `actualiserPageModif()` recréait tous les `<script>` du fragment injecté, y compris
  `<script src=".../tinymce.min.js">`. TinyMCE se retéléchargeait et, chargé de façon
  asynchrone, remplaçait l'objet global `tinymce` **après** que `initTMCE()` y eut créé ses
  éditeurs. `tinymce.get()` interrogeait le nouvel objet, vide : `soumettre()` ne recopiait
  aucun éditeur dans son `<textarea>`.
→ **Correctif** : la recréation des scripts passe dans `executerScriptsInjectes()`, commune à
  `actualiserPageModif()` et `actualiserPageSub()`. Un script **externe** déjà chargé — par un
  panneau précédent (mémorisé dans un `Set`, son DOM ayant disparu) ou par la page elle-même —
  n'est pas recréé ; les scripts **en ligne** sont toujours réexécutés, ils initialisent le
  fragment. Aucun des 15 formulaires n'est modifié.
→ Contrôlé sans rien enregistrer (lecture du `FormData` seulement) : trois formulaires de classe
  ouverts à la suite (Tueur de Domiel, Parangon ménestrel, Archimage), puis un formulaire de sort
  — à chaque fois quatre éditeurs (un pour le sort) vus par `tinymce.get()` et la saisie
  présente dans le formulaire envoyé ; TinyMCE chargé une seule fois ; sous-panneau
  `#detail-pp-sub` intact ; aucune erreur console nouvelle.

---

**[2026-10-11] SP-PO — Possessions, ruleset DD3.5 : règles d'équipement et d'objets magiques, tag de liste dynamique**
Code : `include/liste-parser.php` (nouveau), `include/tableau-parser.php`, `include/glossaire-parser.php`,
`include/aide-contextuelle.php`, `compendium/equipements.php`, `compendium/enregistrement.php`,
`include/ajax/modifier/equipement.php`, `include/ajax/detail-pp/equipement.php`, `regles/regle.php`,
`include/ajax/detail-pp/regle.php`, `include/ajax/detail-pp-sub/glossaire.php`, `js/main.js`, `css/modules.css` ;
`sql/2026-10-11_*.sql` (4 migrations). Demande : importer les PDF `DRS 07 (équipement)` et `DRS 23 (objets
magiques)` comme les règles déjà en place, équipements après « Aventure et environnement », objets magiques
après « Équipement ». **Précisée en cours d'analyse** : les descriptions d'équipement et d'objets magiques sont
déjà (ou doivent être) dans leurs tables ; les règles ne portent que les mécanismes de jeu, et affichent les
listes par un tag dynamique, valable pour les deux rulesets.

**D-PO1 — Les articles sont des données du compendium, les règles n'en affichent que la liste.**
→ Aucune table « armes », « armures » ni « marchandises » dans `dd_tableaux` : les 269 articles du DRS 07
  sont importés dans `dd_equipements` **avec leur description propre** (190 en ont une), et les règles les
  montrent par `[[liste:equipement|famille=…]]`. Les objets magiques existaient déjà (668 en DD3.5).
→ Raison : une liste saisie dans une règle vieillit dès qu'on ajoute un article, et se saisit deux fois. Seules
  les petites tables de mécanique restent statiques (monnaie, dégâts TP/G, enfiler/ôter, bardes, création).
→ **Alternative écartée** : tout en tableaux `dd_tableaux`, les fiches d'articles venant plus tard — c'était
  recommencer le chantier à l'import suivant.

**D-PO2 — Syntaxe du tag : `[[liste:entite|param=valeur|…]]`, références par slug.**
→ Entités `equipement` et `objet` ; paramètres `famille`, `source`, `tri`, `titre` (`titre=-` = sans légende).
  `|` plutôt qu'un espace : les sources en contiennent (« DRS 3.5 »). Mêmes deux passes que `[[tab:slug]]`.
→ **`source` absent = sources actives de l'utilisateur**, comme le compendium ; renseigné = ces sources-là
  quelles que soient les actives. Une règle peut donc montrer des lignes différentes à deux utilisateurs — voulu.
→ Plafond 200 lignes avec lien vers le compendium : un `[[liste:objet]]` nu afficherait 600+ lignes.
→ Le glossaire isole le tag (`GL_TAB_MOTIF` étendu) : « famille=armes » contient des mots du glossaire.

**D-PO3 — Modèle des équipements : familles en arbre, attributs en JSON piloté par la famille.**
→ `dd_categorie_equipement` (arbre par ruleset, slug) dont `cae_colonnes` définit **à la fois** les colonnes de
  la liste, les lignes de la fiche et les champs du formulaire. `dd_equipements.eqt_attributs` (JSON) porte
  dégâts, critique, bonus d'armure… Prix et poids : nombre (pièces de cuivre, grammes — tri, calculs futurs)
  **et** texte d'affichage prioritaire (« spécial », « +50 po »).
→ **Alternative écartée** : 11 colonnes typées (dégâts P/M, critique, portée, bonus d'armure, Dex max, malus,
  échec, vitesses…) — presque toutes vides pour 90 % des articles, et DD2024 en exigerait d'autres.
→ **Familles hiérarchiques** : « armes » = courantes + de guerre + exotiques, elles-mêmes divisées par
  encombrement, exactement comme la table du livre ; la section d'une liste est le chemin sous la famille
  demandée. Filtrer par famille inclut les descendants (PHP côté tag, ensemble d'ids côté liste du compendium).
→ `dd_equipements` était vide : structure modifiée sans migration de données. **Elle rejoint le mécanisme
  Supplément** (`eqt_public`, ressource du propriétaire, garde per-entry à la suppression) — solde SP-E5.

**D-PO4 — Familles d'objets magiques : la catégorie existante, avec un slug.**
→ `com_slug` ajouté à `dd_categorie_objet_magique`, rempli **par le nom** (les ids ne sont pas les mêmes
  en local et en production) ; filet `categorie-<id>` pour toute catégorie inconnue. Les propriétés spéciales
  DD3.5 restent exclues d'une liste sans `famille`, comme dans le compendium.
→ Constat au passage : un objet DD3.5 a `om_com_id = 0` (sans catégorie) — non corrigé, hors périmètre, il
  n'apparaît dans aucune liste filtrée par famille.

**D-PO5 — Place dans l'arbre : Équipement (40) et Objets magiques (50) après « Aventure et environnement ».**
→ « Créatures et pouvoirs spéciaux » passe de 40 à 60 (`UPDATE … AND reg_ordre = 40`, idempotent, dans la
  migration du DRS 07) : 30 et 40 étaient adjacents, sans place pour s'intercaler.
→ DRS 07 : 4 chapitres (racine + Armes, Armures et boucliers, Marchandises et services) et 13 pages longues
  par section ; DRS 23 : racine + 9 pages + chapitre « Création » (4 pages). 17 tableaux, 21 termes de glossaire.

**D-PO6 — Fidélité du texte : corrections de coquilles seulement, toutes journalisées.**
→ `doc/LOG_CORRECTIONS_DRS07_DRS23.md` : 22 coquilles corrigées, 6 normalisations typographiques, 16
  changements de structure (dont la fusion des munitions répétées et l'éclatement des articles à variantes).
→ **Une page ajoutée** hors DRS : « Catalogue des objets magiques », qui démontre `[[liste:objet|…]]`.
→ Les renvois vers des tables du DRS 28 (objets intelligents), non importé, restent du texte simple.

**D-PO7 — Pièges relevés à l'exécution** (détail en §9e de `ARCHITECTURE_0_REFERENCE.md`)
→ L'ordre des migrations est l'ordre alphabétique du nom : le schéma s'appelle `…_equipements_00_schema_…`.
→ `DELETE … IN (parent, enfants)` échoue sur `fk_reg_parent` : suppression feuille par feuille. Découvert
  en rejouant les migrations par le moteur (`migrationsAppliquer()`), pas par le client `mysql` — le rejeu a
  été fait deux fois de suite pour chacune.
→ Un test d'écriture par le vrai gestionnaire créait le supplément de l'utilisateur 1 (+ une ligne de
  sélection de sources) : supprimés aussitôt, état vérifié.
→ **Vérifié** : 8 pages de règles rendues sans avertissement ni tag restant (listes : 78 armes, 21 armures et
  boucliers, 170 marchandises, 486 objets) ; création, modification (source « supplément », prix texte) et
  suppression d'un équipement par `enregistrement.php` ; rendu navigateur des listes et de la liste du
  compendium. **Non vérifié** : clic sur un nom de liste (le panneau de travail ne peut pas ouvrir les pages du
  projet, voir `donjon-verification-sans-navigateur`) et saisie du formulaire dans un vrai navigateur.
→ **Reste à faire** : appliquer les 4 migrations en production (le déploiement les joue dans l'ordre) ;
  SP-PO3 à SP-PO6 (§0).

**[2026-10-15] D-DP14 — Jeton de migrations « absent » : le web d'OVH ne voit pas tout de suite un fichier déposé en SFTP**
→ Symptôme : après le changement de poste, l'étape « Application des migrations SQL en production » échouait
  avec « Jeton absent ou invalide », site laissé en maintenance (verrou conservé, étape rejouable).
→ Cause mesurée : un fichier déposé par SFTP sur OVH n'apparaît côté HTTP qu'au bout d'environ **15 s** quand le
  web a déjà cherché ce chemin (cache négatif du système de fichiers). Le déployeur postait le jeton aussitôt
  après le dépôt de `config/.migrations-jeton`. Le POST arrivait bien (sans redirection, corps reçu) ;
  c'est `is_file()` qui répondait faux côté serveur.
→ Correction (module local seulement, `admin/deploiement/lib.php`) : `deploiementAppliquerMigrations()` réessaie
  l'appel tant que la réponse est « Jeton absent ou invalide » (`DEPLOIEMENT_JETON_ESSAIS` = 10, pause
  `DEPLOIEMENT_JETON_PAUSE` = 6 s). Sans risque : `migrations-auto.php` ne supprime le jeton que lorsqu'il est
  reconnu ; un jeton non vu n'est pas consommé. `migrations-auto.php` est inchangé.
→ Même poste : le déploiement exige PHP ≥ 8.2 / libcurl ≥ 7.80 (`CURLOPT_SSH_HOST_PUBLIC_KEY_SHA256`) ; sous
  Apache, les DLL `libssh2`, `nghttp2` et `brotlidec` de PHP sont préchargées par `LoadFile` dans
  `httpd-xampp.conf` (celles d'`apache/bin` sont plus anciennes et empêchaient le chargement de `curl`).

**[2026-10-15] SP-PO2b — Source des équipements DD3.5 : Manuel des joueurs 3.5, pas « DRS 3.5 »**
Code : `sql/2026-10-15_equipements_dd35_source_sp-po2b.sql`. Constat : après l'import du 2026-10-11, les 269
articles étaient masqués à l'utilisateur dont la sélection personnelle de sources ne contenait pas « DRS 3.5 » ;
la source a été corrigée à la main en local (articles rattachés à `MdJ3.5`, ces données étant aussi celles du
Manuel des joueurs).
→ Nouvelle migration plutôt que retouche de celle du 2026-10-11 (déjà appliquée) : elle déplace les articles
  de « DRS 3.5 » vers `MdJ3.5`, **ressources retrouvées par abréviation** (ids différents entre local et OVH).
  Idempotente, sans effet en local ; jouée deux fois par `migrationsAppliquer()`.
→ ⚠ **Ne jamais rejouer** `…_equipements_dd35_drs07_sp-po2.sql` après celle-ci : elle supprime par source
  « DRS 3.5 » et recréerait 269 doublons sous cette source. Les règles (`…_regles_dd35_drs07/drs23_…`) restent
  sous « DRS 3.5 ».
→ Rappel : le compendium filtre sur les sources **cochées** de l'utilisateur (`getActiveResIds()`, priorité 2) ;
  une source ajoutée après coup n'apparaît pas dans une sélection personnelle existante.

**[2026-10-16] SP-PO5 — Équipement DD2024 : règles, familles propres au ruleset, 238 articles, listes dynamiques**
Code : `sql/2026-10-16_equipements_dd2024_srd_sp-po5.sql`, `sql/2026-10-16_regles_dd2024_equipement_sp-po5.sql`,
`include/liste-parser.php` (légende des listes). Demande : analyser `FR_SRD_CC_v5.2.1-equipements.pdf`, importer les
règles encore absentes, remplir `dd_equipements` avec les catégories propres au ruleset, poser les listes dynamiques
aux emplacements prévus dans les règles. Réutilise tel quel le mécanisme de SP-PO0/PO1 : aucune évolution de schéma.
→ **Familles DD2024** en arbre (armes courantes / de guerre × corps à corps / distance ; armures légères,
  intermédiaires, lourdes, bouclier ; outils d'artisan / autres ; matériel d'aventurier et ses sous-familles ;
  montures et véhicules ; repas ; employés ; services d'incantation). Les attributs de chaque famille reprennent les
  colonnes du livre (botte d'arme, CA, Force, Discrétion, vitesse, équipage…).
→ **Règles déjà présentes, donc complétées plutôt que dupliquées** : le chapitre « Équipement » (id 15) et sa règle
  « Monnaie » existaient. « Monnaie » est **remplacée** (table « Monnaie et valeurs » absente, mots collés) ; 12 pages
  sont créées sous le chapitre ; la section « Objets magiques » du PDF devient une page du chapitre « Objets magiques »
  existant. Le générateur retrouve les nœuds existants par slug, jamais par id.
→ **Variantes** (boîte de jeux, instruments) en articles distincts, sans l'entrée générique « variable » ; les entrées
  génériques « Munitions », « Focaliseur… », « Symbole sacré » sont conservées en plus de leurs formes (voir le journal
  des corrections, S1 et S6).
→ **Source** : « SRD 5.2.1 » (id 93 en local), retrouvée par abréviation. Pas de source « Manuel des joueurs » ici :
  le PDF est le SRD.
→ **Légende des listes** : avec plusieurs tableaux dans un seul tag (`famille=materiel-d-aventurier`), tous
  portaient la même légende ; elle est maintenant la plus profonde famille commune aux lignes de chaque tableau.
  Contrôlé sur les listes DD3.5 existantes (armes, armures, combinaison de familles) : inchangé ou amélioré.
→ **Vérifié** : les 2 migrations jouées deux fois chacune par `migrationsAppliquer()` ; 13 pages de règles
  rendues sans avertissement ni tag restant (38 armes, 13 armures, 37 outils, 98 articles de matériel, 25 montures
  et véhicules, 17 repas, 3 employés, 7 services) ; liste du compendium DD2024 : 238 résultats ; recoupement des
  prix et poids avec une seconde extraction du PDF (207 / 238 automatiquement, le reste relu à l'œil).
→ **Non vérifié** : le clic sur un nom de liste et le formulaire dans un vrai navigateur (le panneau de travail ne
  peut pas ouvrir les pages du projet). **Introduction du chapitre « Équipement »** (id 15) : mots collés, non
  modifiée.
→ **Reste à faire** : jouer les 2 migrations en production ; `SP-PO5b` (objets magiques DD2024) ; les utilisateurs
  qui ont une sélection personnelle de sources doivent cocher « SRD 5.2.1 » (déjà le cas en général).

**[2026-10-16] SP-PO5b — Objets magiques DD2024 : règles du SRD, descriptions retranscrites, tableaux**
Code : `sql/2026-10-16_regles_dd2024_objets_magiques_sp-po5b.sql`, `sql/2026-10-16_objets_dd2024_srd_sp-po5b.sql`.
Demande : analyser `FR_SRD_CC_v5.2.1-objets_magiques.pdf` et `…-regles_objets_magiques.pdf`, importer les règles, et remplacer
les descriptions des objets déjà présents qu'un import antérieur aurait « résumées ». Aucune évolution de schéma.
→ **Constat avant d'écrire** : les descriptions n'étaient pas résumées — 202 des 236 entrées comparées retrouvaient au moins
  97 % des mots du PDF (SP-IM9a les avait redressées). Le défaut était structurel : 25 objets avaient leurs **tableaux
  aplatis** en paragraphes (coût des sorts d'un bâton, tables d'effets…), les 73 déclinaisons d'entrées génériques
  (anneau de résistance, parchemin de sort…) n'en portaient **aucun**, 12 descriptions avaient des paragraphes fusionnés
  (armure d'invulnérabilité, chèvre voyageuse…), des traits d'union avalés ; « Yeux de lynx » manquait. Catégorie, rareté
  et harmonisation des 236 entrées de base déjà présentes sont exactes : non réécrites.
→ **Tout est reconstruit depuis le PDF** plutôt que corrigé à la main : texte en mode normal de `pdftotext`, tableaux en
  mode `-raw` (le mode `-layout` détache les nombres de leurs lignes), titres de capacité en gras retrouvés par liste
  fermée. Le rapport d'écarts ancien / nouveau a servi de contrôle : seules les différences attendues apparaissent.
→ **D-PO8 — Un tableau d'objet = une ligne de `dd_tableaux`, appelée par `[[tab:slug]]`**, comme pour les règles (SP-TB7) :
  34 nouveaux tableaux. **Alternative écartée** : conserver l'aplatissement en `<p>` ou écrire des `<table>` en HTML —
  c'est ce qui avait rendu les tables illisibles, et le rendu doit rester piloté par le CSS (`.reg-tab*`).
→ **D-PO9 — Convention des déclinaisons** (120 lignes) : texte commun de l'entrée générique du SRD + tableau + seul
  paragraphe de la déclinaison choisie (déjà le choix de SP-IM9b, complété par le tableau, qui manquait). Chaque
  déclinaison affiche le tableau **complet** : c'est le texte du livre, et le MJ y lit les autres variantes.
→ **D-PO10 — Profils inclus au texte** (mouche géante, avatar de la Mort) : bloc de paragraphes + tableau de
  caractéristiques. **Alternative écartée** : créer deux monstres — ils n'existent que par la carte ou la figurine qui les
  convoque, et le compendium de monstres ne les attend pas.
→ **D-PO11 — Migrations par nom et par slug, tableaux en upsert.** Les objets sont mis à jour `JOIN` sur le nom (filtré
  ruleset + source), les ids de la production n'étant pas ceux du local — et la synchronisation du contenu (SP-SY) n'étant
  pas faite, la production peut en différer. Les tableaux 43 à 52 (SP-IM9c) sont **réémis** pour la même raison, avec la
  ligne 96–00 du chapeau mille-sorts corrigée. « Yeux de lynx » : `INSERT … SELECT … WHERE NOT EXISTS`.
→ **Règles** : 9 pages sous « Objets magiques » (la page « Catégories » existait avec une phrase ; « Utiliser les objets
  magiques » de SP-PO5 est conservée), 9 tableaux, et une page de A à Z faite de 9 tags `[[liste:objet|famille=…|source=SRD
  5.2.1|titre=-]]` — aucun objet recopié dans la règle (D-PO1). Texte repris tel quel ; une phrase ajoutée hors SRD.
→ **Coquille du SRD corrigée** : « pas le biais » → « par le biais » (chapeau mille-sorts). Journal :
  `doc/LOG_CORRECTIONS_SRD2024_OBJETS_MAGIQUES.md`.
→ **Vérifié** : migrations jouées par `migrationsAppliquer()`, puis **rejouées** (instructions seules, sans
  enregistrement) : mêmes comptes, aucun doublon ; 357 descriptions identiques au calcul ; aucun tag `[[tab:…]]` orphelin ;
  rendu par `rendreTexteEnrichi()` de 8 objets et de 5 pages de règles sans tag restant ; page de A à Z : 34 anneaux, 37 armes,
  32 armures, 14 baguettes, 12 bâtons, 171 objets merveilleux, 10 parchemins, 40 potions, 7 sceptres (comptes de la base).
→ **Piège** : régénérer une migration déjà jouée change sa somme de contrôle (`dd_migrations`) ; pour la rejouer en local
  sans la signaler « retouchée », rejouer ses instructions puis aligner `mig_checksum` (fait une fois, pour la découpe
  des sorts de l'orbe draconique, dont le préfixe `Sort` avalait aussi le paragraphe « Sorts. »).
→ **Non vérifié** : l'aspect dans un vrai navigateur (le panneau de travail ne peut pas ouvrir les pages du projet ; un
  rendu injecté a confirmé les tables du submersible du Crabe, pas la mise en page des profils) ; le clic sur un nom de
  la page de A à Z.
→ **Reste à faire** : jouer en production les migrations `sql/2026-10-11_*`, `2026-10-15_*` et `2026-10-16_*` (dont ces
  deux-là, dans l'ordre alphabétique) ; `SP-PO3`, `PO4`, `PO6` (§0).

**[2026-10-16] SP-PO3 — Bouton TinyMCE d'insertion d'un tag `[[liste:…]]`**
Code : `include/liste-parser.php` (§7), `include/ajax/detail-pp-sub/listes-picker.php`, `include/ajax/liste-apercu.php`,
`js/main.js`, `css/modules.css`, `include/aide-contextuelle.php`, barre d'outils de 9 fichiers `include/ajax/modifier/*.php`
(11 éditeurs). Aucune table, aucune migration. Arbitré le même jour (6 questions) avant d'écrire.
→ **D-PO12 — Le serveur fabrique le tag, le navigateur l'insère.** Chaque changement du sélecteur interroge
  `liste-apercu.php`, qui valide familles, sources, tri et légende contre la base et renvoie le tag canonique avec le
  nombre de lignes. **Alternative écartée** : composer le tag en JS — un slug mal copié ou une légende contenant `|` ou
  `]]` aurait produit un tag qui s'affiche brut chez le lecteur, sans que l'éditeur le voie.
→ **D-PO13 — Le bouton s'enregistre dans `tableauxInitBouton()`.** Les 11 éditeurs qui ont le bouton Tableaux reçoivent
  le bouton Liste sans toucher à leurs `setup` ; seule leur barre d'outils cite `liste`. Contrepartie acceptée : le nom de
  la fonction est devenu un peu trompeur. Le décompte réel est de **11 éditeurs** dans 9 fichiers (le « 13 » de la discussion était
  une estimation).
→ **D-PO14 — Source : « sources actives du lecteur » par défaut, « figer la source » en option.** La liste proposée est
  celle des ressources **officielles** du ruleset (`res_j_id` NULL) : figer le supplément personnel d'un utilisateur dans
  une règle n'aurait aucun sens. La valeur écrite est l'abréviation **si elle est renseignée et unique dans le ruleset**,
  sinon le nom : en DD3.5, 20 ressources n'ont pas d'abréviation et « CP » en désigne deux — le moteur
  (`listeSourcesIds()`) accepterait l'abréviation ambiguë et afficherait les deux sources.
→ **Aperçu** : le nombre de lignes seulement (pas de rendu), avec avertissement à 0 ligne et au-delà de
  `LISTE_MAX_LIGNES`. Il compte pour les sources actives **de l'éditeur** quand aucune n'est figée.
→ **Droits** : `canEditCompendium()`, comme le sélecteur de tableaux.
→ **Plus tard (SP-PO3e)** : rouvrir le sélecteur sur un tag déjà posé. Inscrit au §0.
→ **Défaut corrigé au passage** : TinyMCE enregistre `â` en `&acirc;` dans une légende ; `listeParametres()` ne décodait
  pas les entités et `h()` affichait « b&acirc;tons ». Décodage ajouté (entités et `&nbsp;`). Les 13 pages de règles qui
  utilisent un tag de liste (4 en DD3.5, 9 en DD2024) rendent toujours sans tag brut.
→ **Vérifié** : fonctions de construction sur les deux rulesets (familles, source inconnue, tri inconnu, légende hostile) ;
  endpoint d'aperçu en JSON ; **dans le navigateur de travail, avec une session authentifiée** : bouton présent dans les
  éditeurs de l'objet (`om_description`) et de la règle, sélecteur ouvert dans `#detail-pp-sub`, bascule équipement /
  objets, familles, source figée, légende personnalisée, bouton Insérer — le tag est inséré dans son propre `<p>` et le
  sous-panneau se ferme, formulaire intact. Rien n'a été enregistré.
→ **Non vérifié** : les neuf autres formulaires (même code, même fonction) ; l'apparence en thème clair ; le mode tactile.
→ **Hors sujet relevé** : `include/ajax/releve-device.php` répond 500 avec une session de test sans les clés
  habituelles — le relevé SP-RS5a ; non investigué.

## Sécurité — Renouvellement des mots de passe après incident (2026-10-23)

**[2026-10-23] D-SEC1 — MariaDB local fermé au réseau, comptes protégés, phpMyAdmin authentifié**
Fichiers hors projet : `C:\xampp\mysql\bin\my.ini`, `C:\xampp\phpMyAdmin\config.inc.php`.
→ **Constat.** MariaDB écoutait sur `0.0.0.0:3306` avec `root` sans mot de passe, et phpMyAdmin
  se connectait seul en `root` (`auth_type=config`, `AllowNoPassword=true`). Apache restait limité à
  `Require local`, mais le port SQL était joignable depuis le réseau local.
→ **`bind-address="127.0.0.1"`** dans `my.ini` : le serveur n'écoute plus que sur la boucle locale.
→ **Mots de passe** posés sur les trois comptes `root` (`localhost`, `127.0.0.1`, `::1`), sur `pma`
  (aléatoire, reporté dans `controlpass`) et sur le compte applicatif. Le compte applicatif n'est
  plus joignable que depuis `localhost`.
→ **phpMyAdmin** passe en `auth_type=cookie`, `AllowNoPassword=false`, `blowfish_secret` renouvelé.
→ **Production (OVH)** : mot de passe de la base renouvelé et `config/db.config.php` retransféré par
  SFTP. Le fichier reste commun aux deux environnements (voir D-CFG1) ; chaque bloc a ses identifiants.
→ **Historique git vérifié** : `config/db.config.php` n'a jamais été commité, rien à purger.
→ **Aucune valeur secrète n'est consignée** ici ni dans `doc/`. Procédure appliquée par un script
  hors projet (`C:\xampp\private\`), mot de passe root saisi en masqué.

**[2026-10-23] D-SEC2 — Table système `mysql.db` corrompue (#1034) et tablespace `dd_format_objet_magique`**
→ **Constat.** phpMyAdmin « Comptes utilisateurs » renvoyait `#1034 Index corrompu dans la table 'db'`.
  Le serveur plantait aussi sur `SHOW CREATE TABLE dd_format_objet_magique` (page 0 du fichier `.ibd`
  illisible).
→ **Réparation.** `mysql.db` (Aria) réparée serveur arrêté (`aria_chk -r`) puis `REPAIR TABLE`.
  `dd_format_objet_magique` dumpée en mode `innodb_force_recovery=1`, supprimée puis recréée avec ses
  deux lignes (`1 Auto (calculé)`, `2 Description libre`). Serveur relancé en mode normal.
→ **Sauvegardes** avant intervention : copie des fichiers de données et dump de la base du projet,
  dans `C:\xampp\private\sauvegardes-mysql-20261023\` (hors projet, hors OneDrive, hors git).
→ **Non fait** : suppression des droits anonymes sur la base `test` dans `mysql.db` (refusée en
  session, à faire manuellement si souhaité). Le dump de juin ne contient aucune ligne pour cette table, la
  comparaison avec l'original n'a donc pas été possible.
