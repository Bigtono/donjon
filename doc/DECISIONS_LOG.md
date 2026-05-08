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
Token accessible en JS via getCsrfToken() dans main.js (injecté dans fetchPanel()).

**[2025] Remember me**
Token aléatoire (random_bytes(32)) stocké en base, cookie sécurisé 30j.
Vérification automatique dans auth.php au chargement de chaque page.

**[2025] getActiveResIds()**
Encapsulé dans helpers.php. Retourne un array de res_id selon la chaîne de priorité.
À appeler en début de toute page compendium/personnage nécessitant le filtrage sources.

**[2025] Préfixe tables — retour à dd_**
Développement en local sur base XAMPP dédiée v2 → préfixe `dd_` conservé (pas de cohabitation v1 en local).
Le renommage en `dd2_` pour OVH sera géré par un script RENAME TABLE au moment du déploiement.
→ Code plus lisible, pas de friction en développement.

**[2025] BASE_URL — URLs relatives au sous-répertoire**
Site déployé sous `/donjon/` en local (XAMPP) et en production (maikastel.fr/donjon/).
Constante `BASE_URL = '/donjon'` définie dans `include/db.php`.
Toutes les URLs passent par `BASE_URL` — aucune URL absolue codée en dur.
→ Zéro changement de code entre local et production.

**[2025] Balises PHP — correction convention**
`<?php` pour les blocs logiques, `<?=` pour l'affichage inline.
(Correction de la convention initiale `<?` court — incompatible avec certaines configs XAMPP.)
→ Compatible tous environnements sans configuration supplémentaire.

**[2025] DEV_MODE — mail en développement local**
`define('DEV_MODE', true)` dans `include/db.php`.
En DEV_MODE : le lien de réinitialisation de mot de passe s'affiche directement dans la page.
En production : `DEV_MODE = false`, envoi par mail via mail().
→ Évite la configuration SMTP sous XAMPP en développement.

**[2025] Responsive — exception module Campagnes**
Modules responsives (seuil 992px) : Compendium, Personnages, Wiki/Univers, Profil, Auth.
Module NON responsive : Campagnes — usage desktop exclusif (MJ en partie sur ordinateur).
→ Complexité réduite sur un module à usage contexte desktop uniquement.

**[2025] Module Profil utilisateur**
Trois sections indépendantes (formulaires séparés via champ hidden `section`) :
- Identité : prénom, nom, pseudo, email (avec contrôle d'unicité)
- Mot de passe : vérification ancien mdp, token reset 1h, DEV_MODE pour affichage lien
- Paramètres : liste évolutive (ruleset par défaut, mode campagne, affichage ruleset, items/page)
→ Extensible : chaque nouveau paramètre s'ajoute sans refonte de la page.

**[2025] Ordre de développement des modules — modification**
Ordre initial : Compendium > Personnages > Campagnes > Wiki.
(Modification de l'ordre : Compendium placé en premier pour permettre l'alimentation
en données dès le début du développement, avant même le module Personnages.)
→ Les données du compendium sont nécessaires à tous les autres modules.

---

## À décider

- [x] ~~Gestion des mots de passe oubliés~~ → implémenté (token 1h + DEV_MODE)
- [ ] Interface d'inscription (auto-inscription ou invitation admin seulement ?)
- [ ] Ordre d'affichage par défaut des listes (alphabétique partout ?)
- [ ] Taille maximale des contenus wiki (LONGTEXT = ~4Go, probablement suffisant)
