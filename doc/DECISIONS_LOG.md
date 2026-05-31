<!-- Mis à jour : 2026-05-30 -->

<!--
  À INSÉRER DANS doc/DECISIONS_LOG.md
  Emplacement : après la dernière section de Phase 2. Mettre aussi à jour « ## À décider ».
-->

## Phase 2 — Monstres

**[2025-05] Reprise complète du formatage v1 (trt-insertion-monstre-2.php)**
La v1 (analyse ligne à ligne sur texte brut, mots-clés en dur, requête SQL par
item, séparateurs `...`/`$$$`/`***`, `onClick` JS figés en base, matching exact
sensible casse/accents, liaison limitée à dons + compétences) est abandonnée au
profit d'un moteur unique `include/monstre-parser.php`.
→ Requêtes groupées (fin du N+1), registre déclaratif, sortie découplée du JS.

**[2025-05] Analyse À L'AFFICHAGE, stockage en texte brut (renverse la v1)**
`mo_stats` est stocké tel que saisi ; le rendu (formatage + liens) est calculé à
chaque affichage par `rendreStatsMonstre()`. La v1 figeait du HTML enrichi au save.
→ Ré-édition fidèle à la source, liens toujours à jour (une entité ajoutée plus
  tard devient cliquable sans re-sauvegarde), pas de logique d'idempotence.
→ Coût : 7 SELECT au moment de l'affichage — négligeable.

**[2025-05] Suppression de TinyMCE pour mo_stats**
La mise en page des monstres est formalisée : `<textarea>` à chasse fixe suffit.
Le moteur traite du texte brut (parsing ligne par ligne, sortie échappée par h()),
pas du HTML — plus de DOMDocument.
→ Saisie alignée, code plus simple, aucun risque de corruption HTML.

**[2025-05] Registre déclaratif des types liables**
Les 7 types (don, compétence, sort, objet, capacité, race, classe) sont décrits
dans `typesLiablesMonstre()` (table, clé, nom, scoping ruleset/res/camp, actif),
sur le modèle de `$listConfig`. Ajouter un type = ajouter une ligne.

**[2025-05] Scoping différencié — capacités non scopées**
6 types filtrés par ruleset + sources + camp_id IS NULL (selon colonnes
réellement présentes). `dd_capacites_speciales` n'a ni res ni ruleset ni camp :
résolu sans filtre (table partagée).

**[2025-05] Sortie neutre data-*, résolution côté client**
Le moteur produit `<span class="mo-lien" data-type data-id>` sans onclick ni URL.
`compendium.js` porte un gestionnaire délégué unique qui lit data-* et ouvre la
fiche via actualiserPageSub() ; la base d'URL est lue sur .mo-stats[data-detail-base].
→ Indépendant de BASE_URL (local /donjon vs OVH), couplage stockage/JS supprimé.
→ Abandon des onClick="afficherDon(id)" v1.

**[2025-05] Détection à deux niveaux**
Lignes étiquetées (Dons:/Compétences:) → liaison au type spécifique. Texte libre →
index fusionné des types actif=true. race/classe en actif=false (noms trop
courants) : liés seulement sur ligne étiquetée. Plus longue correspondance
d'abord ; longueur minimale et bornes de mots comme garde-fous.

**[2025-05] Visibilité portée par mo_j_id**
NULL = public ; sinon visible du seul propriétaire (case « Monstre privé »).
Clause (mo_j_id IS NULL OR mo_j_id = :uid) via extra_where ; pas ownerFilter()
(masquerait les monstres publics).

**[2025-05] FP en libellé (varchar), dd_fp comme référentiel**
mo_fp_id conserve le libellé alphanumérique (« 1/2 ») ; dd_fp peuple et ordonne
le select via fp_valeur. mo_mocat_id / mo_mogr_id sont des FK entières (NN) ;
le groupe est DD2024-only (transmis à 0 en DD3.5).

---

<!--
  « ## À décider » — lignes à ajouter :
  - [x] ~~Monstres — reprise du formatage v1~~ → moteur monstre-parser.php
  - [x] ~~Monstres — où parser~~ → à l'affichage, stockage texte brut
  - [x] ~~Monstres — TinyMCE ?~~ → non, textarea brut
  - [x] ~~Monstres — visibilité~~ → mo_j_id (NULL = public)
  - [ ] Monstres — convention « Pouvoirs » (gras du nom jusqu'au 1er point) à confirmer ?
-->