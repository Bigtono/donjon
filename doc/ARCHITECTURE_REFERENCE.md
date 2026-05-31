<!--
  À INSÉRER DANS doc/ARCHITECTURE_0_REFERENCE.md
  Emplacement : fin de « ## 5. Compendium des règles », avant « ## 6. Zone d'administration ».
  Reporter aussi les mises à jour ponctuelles en bas de ce fichier (§ Arborescence, Plan, Tables).
-->

### Module Monstres — bloc de stats à liaisons cliquables

Module de compendium classique dans sa forme (moteur `compendium-liste.php`,
fiche `detail-pp`, formulaire `modifier`, dispatch dans `enregistrement.php`),
avec une particularité : le bloc de description (`mo_stats`) rend cliquables les
entités du jeu qu'il cite (dons, compétences, sorts, objets magiques, capacités
spéciales, races, classes).

#### Choix structurant : analyse À L'AFFICHAGE (et non à l'enregistrement)

`mo_stats` est stocké **en texte brut**, tel que saisi. La mise en forme et les
liens sont calculés **à chaque affichage** par `rendreStatsMonstre()`. C'est
l'inverse de la v1, qui figeait du HTML enrichi en base à l'enregistrement.

Conséquences :
- la ré-édition réaffiche exactement la source saisie (aucun HTML à « désparser ») ;
- les liens restent **toujours frais** : une entité ajoutée au compendium plus
  tard devient cliquable sans re-sauvegarder le monstre ;
- code plus simple : pas de logique d'idempotence ni de manipulation DOM au save.

Coût : 7 `SELECT nom` (un par type, filtrés ruleset + sources) au moment de
l'affichage d'une fiche — négligeable.

#### Suppression de TinyMCE pour ce champ

La mise en page des monstres étant très formalisée, `mo_stats` est saisi dans un
simple `<textarea>` à chasse fixe (pas d'éditeur riche). Le moteur travaille donc
sur du texte, pas du HTML : pas de DOMDocument, parsing ligne par ligne, sortie
intégralement échappée par `h()`.

#### Moteur — `include/monstre-parser.php`

Point d'entrée : `rendreStatsMonstre(PDO $db, ?string $texte, int $ruleset_id, array $res_ids): array`
→ `['html' => string, 'rapport' => ['liens' => int, 'par_type' => []]]`.

Principes :
1. **Registre déclaratif** `typesLiablesMonstre()` : une entrée par type (table,
   id, nom, colonnes de scoping ruleset/res/camp, drapeau `actif`). Ajouter un
   type liable = ajouter une ligne.
2. **Requêtes groupées** : un `SELECT` par type (7 au total), chargé en index
   `nom_normalisé => {id, nom}`. Pas de N+1 (la v1 faisait une requête par item).
3. **Normalisation** (`normaliserNomMonstre`) : minuscules + accents retirés +
   apostrophes unifiées + espaces compactés, des deux côtés. Matching insensible
   casse/accents.
4. **Liaison par fenêtrage de mots, plus longue correspondance d'abord** : « Art
   de la magie » l'emporte sur « magie ». Garde-fous : longueur minimale
   (`MO_LONGUEUR_MIN`), bornes de mots, candidats purement numériques ignorés.
5. **Sortie neutre découplée du JS** : `<span class="mo-lien" data-type="…"
   data-id="…">…</span>`, sans `onclick` ni URL. La résolution
   type → endpoint → `actualiserPageSub()` se fait côté client (gestionnaire
   délégué dans `compendium.js`), la base d'URL étant lue sur le conteneur
   `.mo-stats[data-detail-base]`. Indépendant de `BASE_URL` (local vs OVH).

#### Détection à deux niveaux

- **Lignes étiquetées** (`Dons :`, `Compétences :`) : liaison restreinte au type
  correspondant (haute précision ; gère le `+15` accolé à une compétence).
- **Texte libre** : liaison sur l'index fusionné des types `actif=true` (dons,
  compétences, sorts, objets, capacités). `race` et `classe` sont `actif=false`
  (noms trop courants comme « nain », « guerrier ») : reliés uniquement si cités
  sur une ligne étiquetée dédiée. En cas d'homonymie, priorité à l'ordre du registre.

#### Visibilité — `mo_j_id`

`mo_j_id IS NULL` = visible par tous ; sinon visible du seul propriétaire (case
« Monstre privé » du formulaire → `mo_j_id = j_id` courant). Clause de liste
`(mo_j_id IS NULL OR mo_j_id = <uid>)` injectée via `extra_where` ; `ownerFilter()`
n'est pas utilisé car il masquerait les monstres publics. Les éditeurs voient tout.

#### Catégorie / Groupe / FP

- `mo_mocat_id` (NN) → `dd_monstres_categories`, filtrée par ruleset.
- `mo_mogr_id` (NN) → `dd_monstres_groupes`, **DD2024 uniquement** ; en DD3.5 le
  formulaire transmet `0` via un champ caché.
- `mo_fp_id` reste **varchar** : on stocke le libellé (« 1/2 ») ; `dd_fp` sert de
  référentiel pour peupler et **ordonner** le `<select>` (`ORDER BY fp_valeur`).

#### Fichiers du module

```
compendium/monstres.php                # contrôleur liste + $listConfig
include/monstre-parser.php             # moteur d'analyse/rendu (nouveau)
include/ajax/detail-pp/monstre.php     # fiche détail (#detail-pp) — appelle le moteur
include/ajax/modifier/monstre.php      # formulaire création / modification
compendium/enregistrement.php          # + case 'monstre' / enregistrerMonstre()
js/compendium.js                       # + soumettreMonstre() + handler délégué .mo-lien
css/compendium-modules.css             # + styles .mo-stats / .mo-lien
compendium/index.php                   # + carte « Monstres »
```

<!--
  MISES À JOUR PONCTUELLES AILLEURS DANS LE FICHIER :
  • Arborescence : ajouter compendium/monstres.php, include/monstre-parser.php,
    include/ajax/modifier/monstre.php, include/ajax/detail-pp/monstre.php
  • Plan (Phase 2 — Compendium) : ajouter « Monstres » aux sections implémentées
  • Tables (Compendium) : ajouter dd_monstres, dd_monstres_categories,
    dd_monstres_groupes, dd_fp
-->
