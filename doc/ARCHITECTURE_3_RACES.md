<!-- Mis à jour : 2026-05-30 -->

# Codex DD v2 — Architecture : Races

> Décisions techniques et structure de code pour la section Races du compendium.
> Pour les règles fonctionnelles, voir `METIER_RACES.md`.
> Pour le schéma des tables, voir `SCHEMA_SQL.md`.

---

## 1. Tables impliquées

| Table | Préfixe | Remarque |
|---|---|---|
| `dd_races` | `ra` | Entité principale |
| `dd_race_type` | `rat` | Référentiel des types de race |
| `dd_race_capacite` | `cr` | Liaison race ↔ capacité spéciale |
| `dd_capacites_speciales` | `cap` | Table partagée classes + races |

Voir `SCHEMA_SQL.md` pour la structure détaillée de chaque table.

---

## 2. Fichiers

```
compendium/
  races.php                        ← liste ($listConfig → compendium-liste.php)
  enregistrement.php               ← ajouter case 'race' (enregistrerRace, supprimerRace, bulkSupprimerRaces)

include/ajax/
  detail-pp/race.php               ← rendu HTML du panel detail-pp
  modifier/race.php                ← formulaire création / modification

include/insert/
  DD3.5/bloc_race.php              ← fragment capacités DD3.5 inclus dans detail-pp
  DD2024/bloc_race.php             ← fragment capacités DD2024 inclus dans detail-pp

js/
  compendium.js                    ← ajouter le drag & drop section 3 (pattern classe-modifier.js)

doc/
  METIER_RACES.md                  ← règles fonctionnelles
  ARCHITECTURE_3_RACES.md          ← ce fichier
  SCHEMA_SQL.md                    ← dd_race_capacite ajoutée
  DECISIONS_LOG.md                 ← décisions de la session races
```

---

## 3. Page liste — `compendium/races.php`

Pattern standard `$listConfig` → `compendium-liste.php`, identique aux autres pages du compendium.

### Colonnes

| Clé | Classe CSS | Champ SQL | Tri |
|---|---|---|---|
| nom | col-primary | `ra_nom` | Oui |
| type | col-secondary | `rat_nom` (JOIN `dd_race_type`) | Oui |

### Filtres

| Nom | Type moteur | SQL | Ruleset |
|---|---|---|---|
| Type de race | `select` query sur `dd_race_type` filtré par ruleset | `ra.ra_rat_id = ?` | DD3.5 + DD2024 |
| Modif. niveau | `checkbox` | `ra.ra_mod_niveau > 0` | DD3.5 uniquement |

### Tri par défaut

```sql
ORDER BY ra.ra_rat_id ASC, ra.ra_nom ASC
```

### Autres paramètres $listConfig

- `champ_id` : `ra_id`
- `champ_camp` : `ra_camp_id` (auto-inféré)
- Filtre sources : `ra_res_id` via `getActiveResIds()`

---

## 4. Panel detail-pp — `include/ajax/detail-pp/race.php`

Structure du rendu HTML selon le ruleset (`$_SESSION['rulesetRep']`) :

**DD3.5**
1. Nom + type de race
2. Modificateur de niveau (si `ra_mod_niveau > 0`)
3. Description (`ra_description`) — sortie HTML brute (TinyMCE)
4. Include `include/insert/DD3.5/bloc_race.php` → liste des capacités ordonnée par `cr_ordre`
   - Format ligne : `<strong>cap_nom</strong> (cap_type)` + `cap_description`

**DD2024**
1. Nom
2. Description (`ra_description`) — sortie HTML brute (TinyMCE)
3. Include `include/insert/DD2024/bloc_race.php` → liste des capacités ordonnée par `cr_ordre`
   - Format ligne : `<strong>cap_nom</strong>` + `cap_description`

La requête de chargement des capacités :

```sql
SELECT cap.cap_nom, cap.cap_description, cap.cap_type
FROM dd_race_capacite cr
JOIN dd_capacites_speciales cap ON cap.cap_id = cr.cr_cap_id
WHERE cr.cr_ra_id = :ra_id
ORDER BY cr.cr_ordre ASC
```

---

## 5. Formulaire — `include/ajax/modifier/race.php`

### Section 1 — Données de base (DD3.5 + DD2024)

| Champ HTML | Champ BDD | Type input | Obligatoire |
|---|---|---|---|
| `ra_nom` | `ra_nom` | text | Oui |
| `ra_rat_id` | `ra_rat_id` | select (query `dd_race_type` filtré ruleset) | Oui |
| `ra_res_id` | `ra_res_id` | select (sources actives) | Oui |
| `ra_description` | `ra_description` | TinyMCE basic (`.tinymce-basic`) | Non |

### Section 2 — DD3.5 uniquement

Conditionnée par `$_SESSION['rulesetRep'] === 'DD3.5'`.

| Champ HTML | Champ BDD | Type input |
|---|---|---|
| `ra_mod_niveau` | `ra_mod_niveau` | number, entier, défaut 0 |

### Section 3 — Capacités raciales

Masquée en mode création (`ra_id = 0`). Affiche un message invitant à enregistrer la race d'abord.

En mode modification, affiche un tableau avec les colonnes : Ordre (drag handle), Nom, Type, Description, Actions (modifier / supprimer).

**Drag & drop** : les lignes du tableau sont réordonnables. L'ordre effectif dans le DOM est lu au moment du submit pour alimenter `cr_ordre` dans le payload JSON.

**Champ caché** : `<input type="hidden" id="capacites_payload" name="capacites_payload" value="[]">`

**Bouton « Nouvelle capacité »** : ouvre un formulaire inline (overlay) pour saisir une nouvelle capacité spéciale (`cap_nom`, `cap_description`, `cap_type` en DD3.5) et l'associer à la race.

### Format du payload JSON (`capacites_payload`)

Sérialisé au submit depuis l'état courant du DOM. Trois types d'entrées :

```json
[
  {
    "action": "existing",
    "cap_id": 12,
    "cr_ordre": 1
  },
  {
    "action": "new",
    "cap_nom": "Résistance à la magie",
    "cap_description": "<p>...</p>",
    "cap_type": "Sur",
    "cr_ordre": 2
  },
  {
    "action": "delete",
    "cap_id": 7
  }
]
```

| Valeur `action` | Signification |
|---|---|
| `existing` | Lien existant — seul `cr_ordre` peut avoir changé (drag & drop) |
| `new` | Nouvelle capacité : INSERT dans `dd_capacites_speciales` puis INSERT dans `dd_race_capacite` |
| `delete` | Supprimer le lien `dd_race_capacite` — ne pas toucher à `dd_capacites_speciales` |

---

## 6. Enregistrement — `compendium/enregistrement.php`

Ajouter le case `'race'` dans le switch principal.

### `enregistrerRace($db, $is_ajax, $redirect)`

Logique transactionnelle :

1. Valider `ra_nom` (obligatoire) et `ra_res_id` (obligatoire).
2. INSERT ou UPDATE `dd_races` selon `ra_id`.
3. Décoder `capacites_payload` (JSON) :
   - `action = 'new'` → INSERT `dd_capacites_speciales`, récupérer `cap_id`, INSERT `dd_race_capacite (cr_ra_id, cr_cap_id, cr_ordre)`.
   - `action = 'existing'` → UPDATE `dd_race_capacite SET cr_ordre = ? WHERE cr_ra_id = ? AND cr_cap_id = ?`.
   - `action = 'delete'` → DELETE `dd_race_capacite WHERE cr_ra_id = ? AND cr_cap_id = ?`.
4. Commit ou rollback sur exception.

### `supprimerRace($db, $is_ajax, $redirect)`

1. Vérifier les dépendances :
   ```sql
   SELECT COUNT(*) FROM dd_personnages
   WHERE pe_ra_id = :ra_id OR pe_arc_id = :ra_id
   ```
2. Si count > 0 → refuser avec message : *« Impossible de supprimer : N personnage(s) utilisent cette race. »*
3. Sinon :
   ```sql
   DELETE FROM dd_race_capacite WHERE cr_ra_id = :ra_id
   DELETE FROM dd_races WHERE ra_id = :ra_id
   ```

### `bulkSupprimerRaces($db, $redirect)`

Boucle sur les IDs reçus, applique `supprimerRace()` pour chaque. Si une race est refusée, elle est ignorée et la liste des refus est reportée dans le flash message.

---

## 7. Décisions techniques

Voir `DECISIONS_LOG.md` — section **Phase 2 — Races** pour le détail et les justifications de chaque décision.

Résumé :

- Modificateurs de caractéristiques supprimés de `dd_races` → devenus capacités spéciales.
- `dd_race_capacite` : pas de `cr_niveau` (acquisition immédiate), ajout de `cr_ordre` (drag & drop).
- `cap_type` affiché uniquement en DD3.5, entre parenthèses après le nom de la capacité.
- Filtre type de race présent pour DD3.5 et DD2024 (extensibilité futurs rulesets).
- Vérification dépendances `dd_personnages` obligatoire avant toute suppression de race.
- Section 3 masquée en création — pattern identique à `classe-modifier.php`.
- Payload JSON `capacites_payload` — pattern identique aux capacités de classe.