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

## Bugs connus — à traiter

- **Admin / liste utilisateurs** : le menu ⋮ (dropdown) ne fonctionne pas correctement sur les lignes `admin-ligne--inactif`. La piste CSS (stacking context créé par `opacity` sur `<td>`) a été explorée sans succès. À investiguer en session dédiée.

---

## À décider

- [x] ~~Gestion des mots de passe oubliés~~ → implémenté (token 1h + DEV_MODE)
- [x] ~~Ordre d'affichage par défaut des listes~~ → alphabétique sur col-primary (tri GET modifiable)
- [x] ~~Zone admin — nombre de blocs~~ → 2 blocs (Utilisateurs + Ressources) ; Variables via phpMyAdmin
- [x] ~~Suppression utilisateur~~ → désactivation j_visible=0, jamais DELETE
- [ ] Interface d'inscription (auto-inscription ou invitation admin seulement ?)
- [ ] Taille maximale des contenus wiki (LONGTEXT = ~4Go, probablement suffisant)
