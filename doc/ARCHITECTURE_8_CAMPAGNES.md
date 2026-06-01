<!-- Mis à jour : 2026-06-01 16:55 -->

# Codex DD v2 — Architecture : Campagnes

> Décisions techniques et structure de code pour le module Campagnes.
> Pour les règles fonctionnelles, voir `METIER_10_Campagnes.md`.
> Pour le schéma des tables, voir `SCHEMA_SQL.md` (section 7).
>
> **Statut : structure de données validée (schéma v1.1, patch SQL étape 1 appliqué).**
> L'architecture de code ci-dessous est la **cible proposée** ; le découpage en sous-phases et
> certains points marqués « à arbitrer » restent ouverts.

---

## 1. Tables impliquées

| Table | Préfixe | Rôle |
|---|---|---|
| `dd_campagnes` | `camp` | Entité principale (1 propriétaire, 1 ruleset, 0–1 univers) |
| `dd_campagnes_personnages` | `cp` | Lien N-N personnage ↔ campagne (source de vérité) |
| `dd_campagnes_sources` | `cs` | Sources de règles actives de la campagne (priorité 1) |
| `dd_scenarios` | `sce` | Scénarios (ruleset hérité de la campagne) |
| `dd_scenarios_chapitres` | `scc` | Chapitres d'un scénario |
| `dd_rencontres` | `re` | Rencontres (rattachement chapitre obligatoire) |
| `dd_oppositions` | `opp` | Copie éditable d'un monstre, propre à une rencontre |
| `dd_fichiers` | `fi` | Pièces jointes PDF génériques (campagne / scénario / rencontre) |
| `dd_campagnes_notes` | `cpno` | **RÉSERVÉ** — hors UI cette version |

Référentiels lus : `dd_univers` (`camp_un_id`), `dd_ressources` (sources), `dd_monstres` /
`dd_monstres_categories` (modèle d'opposition), `dd_personnages` (`pe_camp_id` = dernière campagne).
Voir `SCHEMA_SQL.md` pour la structure détaillée.

### Invariants de données

- Le ruleset n'existe **que** sur `camp_ruleset_var_id`. Toute requête sur un scénario / chapitre /
  rencontre / opposition remonte à la campagne pour connaître son ruleset (jointure).
- `re_scc_id` est **NOT NULL** : pas de rencontre orpheline.
- `opp_re_id` lie l'opposition à **une seule** rencontre (1-N) ; aucune table de liaison.
- `opp_mo_id` (monstre modèle) n'est jamais modifié après création.
- `pe_camp_id` est un raccourci dénormalisé ; le lien réel est dans `dd_campagnes_personnages`.

---

## 2. Fichiers (cible)

```
campagnes/
  campagnes.php            ← liste des campagnes du MJ (liste dédiée, voir §3)
  campagne.php             ← détail d'une campagne (scénarios, sources, personnages, PJ)
  scenario.php             ← détail d'un scénario (chapitres, rencontres)
  rencontre.php            ← détail d'une rencontre (oppositions, composition, PJ)
  enregistrement.php       ← POST centralisé du module (commit transactionnel)

include/ajax/
  detail-pp/
    campagne.php           ← rendu panel detail-pp campagne
    scenario.php           ← rendu panel detail-pp scénario
    rencontre.php          ← rendu panel detail-pp rencontre
    opposition.php         ← rendu panel detail-pp opposition (sous-panneau possible)
  modifier/
    campagne.php           ← formulaire création / modification campagne
    scenario.php           ← formulaire scénario
    chapitre.php           ← formulaire chapitre
    rencontre.php          ← formulaire rencontre
    opposition.php         ← formulaire opposition (+ sélecteur de monstre modèle)
  campagne/
    monstre-template.php   ← renvoie nom + catégorie + stats d'un monstre (pré-remplissage opposition)
    dupliquer.php          ← duplication scénario / rencontre / opposition (cascade, suffixe « - copie »)
    personnage-attach.php  ← attache un personnage à la campagne (dd_campagnes_personnages)
    personnage-detach.php  ← détache un personnage
  upload-pdf.php           ← upload d'une pièce jointe PDF (dd_fichiers) — voir §6
  upload-image.php         ← (EXISTANT) upload images TinyMCE — réutilisé tel quel

js/
  campagne.js              ← interactions module (overlays, duplication, attach perso, sélecteur monstre)

css/
  campagnes-modules.css    ← chargé si $css_module = 'campagnes'

doc/
  METIER_10_Campagnes.md
  ARCHITECTURE_8_CAMPAGNES.md   ← ce fichier
  SCHEMA_SQL.md                 ← section 7 (v1.1)
  DECISIONS_LOG.md              ← décisions de la session campagnes
```

> Les noms `campagnes.php` / `scenario.php` / `rencontre.php` remplacent l'ébauche
> `campagne.php, scenario.php, rencontres.php` de la §13 de la référence. **À arbitrer.**

---

## 3. Page liste — `campagnes/campagnes.php`

⚠️ **N'utilise pas** le moteur `compendium-liste.php`. Ce moteur filtre par sources actives
(`getActiveResIds()`) et par ruleset, ce qui ne correspond pas aux campagnes : une campagne est
scopée par **propriétaire** (`camp_j_id = utilisateur courant`), tous rulesets confondus.

→ Liste dédiée légère : `SELECT … FROM dd_campagnes WHERE camp_j_id = ? ORDER BY camp_nom`, avec le
ruleset et l'univers affichés en colonnes secondaires (jointures `dd_variables`, `dd_univers`).

---

## 4. Panels detail-pp et overlays

Le module réutilise le **système d'overlays empilés** existant (`#detail-pp`, `#modification`,
`#detail-pp-sub`) décrit au §12 de la référence — rien à réinventer.

- **`#detail-pp`** : détail principal d'une campagne, d'un scénario ou d'une rencontre, ouvert en
  contexte `'externe'` (navigation interne au module) ou `'liste'` (depuis `campagnes.php`).
- **`#modification`** : tous les formulaires de création/édition (campagne, scénario, chapitre,
  rencontre, opposition). Édition locale DOM, **zéro écriture** ; commit via `enregistrement.php`.
- **`#detail-pp-sub`** : consultation en lecture seule d'un élément référencé sans fermer le
  panneau courant — typiquement l'aperçu d'une **opposition** depuis la fiche rencontre, ou la
  fiche du **monstre modèle** (lien `opp_mo_id`) via le `detail-pp/monstre.php` du compendium.

Bouton **Modifier** injecté dans `detail-pp` selon les droits (propriété de la campagne, vérifiée
serveur). `apresModification()` rafraîchit le panel courant (+ la liste si contexte `'liste'`).

---

## 5. Enregistrement — `campagnes/enregistrement.php`

POST unique centralisé par module (pattern `compendium/enregistrement.php`), une transaction PDO
par commit, validation métier serveur, CSRF obligatoire. Aiguillage par un paramètre d'action :

| Action | Effet |
|---|---|
| `enregistrerCampagne` | INSERT/UPDATE `dd_campagnes` (+ `dd_campagnes_sources`, `camp_un_id`) |
| `enregistrerScenario` | INSERT/UPDATE `dd_scenarios` |
| `enregistrerChapitre` | INSERT/UPDATE `dd_scenarios_chapitres` |
| `enregistrerRencontre` | INSERT/UPDATE `dd_rencontres` (dont `re_composition`) |
| `enregistrerOpposition` | INSERT/UPDATE `dd_oppositions` (`opp_mo_id` figé après création) |
| `supprimer*` | Suppression douce (stratégie à préciser, cf. §8) |

### Contrôle de propriété — systématique

Chaque action vérifie que l'entité visée appartient bien à une campagne dont
`camp_j_id == utilisateur courant`, en remontant la hiérarchie (opposition → rencontre → chapitre
→ scénario → campagne). **Correction de la faille v1** : en v1, les endpoints AJAX de création
(`*_create.php`) n'incluaient pas l'authentification et acceptaient n'importe quel id en POST.

### Recopie d'une opposition

À la création d'une opposition, le serveur (re)lit le monstre modèle pour fiabiliser la recopie :
`opp_nom ← mo_nom`, `opp_mocat_nom ← mocat_nom` (libellé via `mo_mocat_id`), `opp_stats ← mo_stats`,
`opp_mo_id ← mo_id`. Le MJ peut ensuite éditer les trois premiers ; `opp_mo_id` reste figé.

---

## 6. Pièces jointes PDF — `dd_fichiers` + `include/ajax/upload-pdf.php`

Table générique polymorphe : `fi_entite` ∈ {campagne, scenario, rencontre} + `fi_entite_id`.
Un seul endpoint d'upload sert les trois entités.

- **Validation serveur double** : extension `.pdf` **et** signature (magic bytes `%PDF-`), MIME
  `application/pdf`, taille max à fixer (proposition : 20 Mo).
- **Stockage hors arborescence publique** (ou répertoire protégé) : proposition
  `uploads/campagnes/{fi_entite}/{fi_entite_id}/{hash}.pdf`. `fi_chemin` = chemin relatif ;
  `fi_nom_origine` = nom affiché.
- **Téléchargement contrôlé** : servi par un script qui vérifie la propriété de la campagne
  porteuse avant d'envoyer le binaire (jamais de lien direct vers le fichier).
- Le **dépôt** d'une pièce jointe est une action à confirmation explicite (cf. règles produit).

> Les **images** des descriptions (TinyMCE) réutilisent l'endpoint **existant**
> `include/ajax/upload-image.php` (config `.tinymce-full`, `img/uploads/`) — voir §16 de la
> référence. Pas de nouvel endpoint image.

---

## 7. Édition de texte enrichi

Champs concernés : `camp_description`, `sce_description`, `re_description` → configuration
**`.tinymce-full`** (images autorisées). `camp_resume` reste un champ simple. `re_composition` est
un `<textarea>` brut mis en évidence (texte littéral des effectifs, pas de HTML riche requis).

---

## 8. Suppression douce

Stratégie actée sur le principe ; **topo détaillé à fournir avant implémentation** :
- marquage logique vs table d'archive,
- cascade scénario → chapitres → rencontres → oppositions,
- sort des pièces jointes (`dd_fichiers`) et des fichiers physiques,
- effet sur `dd_campagnes_personnages` et sur `pe_camp_id`.

---

## 9. Points encore à arbitrer

- Noms de fichiers de pages (`campagnes.php` / `scenario.php` / `rencontre.php`) vs ébauche §13.
- Numérotation documentaire : ce fichier est `ARCHITECTURE_8_*` (aligné sur la §8 de la référence),
  le métier est `METIER_10_*` (prochain numéro libre) — à harmoniser si souhaité.
- Stratégie FK/cascade en base (le `schema.sql` actuel n'utilise pas de contraintes FK).
- Détail de la suppression douce (§8).
- Taille max des pièces jointes PDF.
- Découpage en sous-phases de développement.
