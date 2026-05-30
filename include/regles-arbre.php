<?php
// include/regles-arbre.php — Moteur d'arbre récursif du module Règles
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9b
//
// Chargement en UNE requête SQL, puis tout le traitement en mémoire PHP :
//   chargerArbreRegles()   → tableau structuré {nodes, enfants, racines}
//   rendreSommaire()       → HTML du sommaire dépliable
//   reglesOrdreLecture()   → liste DFS (préfixe) = ordre de lecture linéaire
//   filAriane()            → chaîne des ancêtres [racine…parent, courant]
//   reglesNomChapitre()    → nom du chapitre racine d'un nœud

// ============================================================
// chargerArbreRegles()
// ============================================================
// Retourne :
//   'nodes'   → [reg_id => row]         tous les nœuds visibles
//   'enfants' → [parent_id => [id,…]]   enfants triés par (reg_ordre, reg_nom)
//   'racines' → [id,…]                  nœuds sans parent, triés
//
// Paramètres :
//   $ruleset_var_id   — ruleset actif (depuis $_SESSION)
//   $inclureCaches    — si true, inclut aussi reg_visible=0 (éditeurs)

function chargerArbreRegles(PDO $db, int $ruleset_var_id, bool $inclureCaches = false): array
{
  $cond = $inclureCaches ? '' : 'AND reg_visible = 1';
  $stmt = $db->prepare("
    SELECT reg_id, reg_reg_id, reg_type, reg_nom, reg_slug,
           reg_texte, reg_ordre, reg_visible, reg_camp_id, reg_res_id
    FROM   dd_regles
    WHERE  reg_ruleset_var_id = ?
      $cond
    ORDER  BY reg_ordre ASC, reg_nom ASC
  ");
  $stmt->execute([$ruleset_var_id]);
  $rows = $stmt->fetchAll();

  $nodes   = [];
  $enfants = [];
  $racines = [];

  foreach ($rows as $r):
    $id = (int)$r['reg_id'];
    $nodes[$id] = $r;
    $par = $r['reg_reg_id'] !== null ? (int)$r['reg_reg_id'] : null;
    if ($par === null):
      $racines[] = $id;
    else:
      $enfants[$par][] = $id;
    endif;
  endforeach;

  return [
    'nodes'   => $nodes,
    'enfants' => $enfants,
    'racines' => $racines,
  ];
}

// ============================================================
// reglesOrdreLecture()
// ============================================================
// Retourne la liste des reg_id dans l'ordre de lecture DFS préfixe.
// Même ordre qu'un livre : un chapitre est immédiatement suivi de son
// premier enfant, etc.
// Utilisé pour calculer précédent/suivant sans colonne globale.

function reglesOrdreLecture(array $arbre): array
{
  $liste = [];
  _dfs($arbre['racines'], $arbre['enfants'], $liste);
  return $liste;
}

function _dfs(array $ids, array $enfants, array &$liste): void
{
  foreach ($ids as $id):
    $liste[] = $id;
    if (!empty($enfants[$id])):
      _dfs($enfants[$id], $enfants, $liste);
    endif;
  endforeach;
}

// ============================================================
// filAriane()
// ============================================================
// Retourne [racine_id, …, parent_id, noeud_id] pour construire
// le breadcrumb. Retourne [] si le nœud est introuvable.

function filAriane(array $arbre, int $id): array
{
  $nodes = $arbre['nodes'];
  if (!isset($nodes[$id])) return [];

  $chemin = [];
  $cur    = $id;
  while ($cur !== null):
    array_unshift($chemin, $cur);
    $par = $nodes[$cur]['reg_reg_id'];
    $cur = $par !== null ? (int)$par : null;
  endwhile;
  return $chemin;
}

// ============================================================
// reglesNomChapitre()
// ============================================================
// Retourne le nom du chapitre racine d'un nœud (catégorie de haut niveau).

function reglesNomChapitre(array $arbre, int $id): string
{
  $ariane = filAriane($arbre, $id);
  if (empty($ariane)) return '';
  $racine_id = $ariane[0];
  return $arbre['nodes'][$racine_id]['reg_nom'] ?? '';
}

// ============================================================
// rendreSommaire()
// ============================================================
// Retourne le HTML du sommaire dépliable.
// Le nœud $idCourant et ses ancêtres sont marqués comme actifs/ouverts.
// Appel récursif en mémoire — zéro requête SQL supplémentaire.

function rendreSommaire(array $arbre, ?int $idCourant): string
{
  $ancetres = $idCourant ? array_flip(filAriane($arbre, $idCourant)) : [];
  $html = '<nav class="regles-sommaire" aria-label="Sommaire des règles">';
  $html .= _rendreSommaireNiveau($arbre['racines'], $arbre, $ancetres, $idCourant, 0);
  $html .= '</nav>';
  return $html;
}

function _rendreSommaireNiveau(array $ids, array $arbre, array $ancetres, ?int $idCourant, int $profondeur): string
{
  if (empty($ids)) return '';
  $html = '<ul class="regles-sommaire__liste regles-sommaire__liste--niv' . $profondeur . '">';
  foreach ($ids as $id):
    $n       = $arbre['nodes'][$id];
    $estActif  = $id === $idCourant;
    $estOuvert = isset($ancetres[$id]);
    $hasEnfants = !empty($arbre['enfants'][$id]);

    $cls = 'regles-sommaire__item';
    if ($estActif)  $cls .= ' regles-sommaire__item--actif';
    if ($estOuvert) $cls .= ' regles-sommaire__item--ouvert';
    if ($n['reg_type'] === 'glossaire') $cls .= ' regles-sommaire__item--glossaire';

    $html .= '<li class="' . $cls . '">';
    $html .= '<a href="' . BASE_URL . '/regles/regle.php?id=' . (int)$id . '"'
           . ' class="regles-sommaire__lien">'
           . htmlspecialchars($n['reg_nom'], ENT_QUOTES, 'UTF-8')
           . '</a>';

    if ($hasEnfants && ($estActif || $estOuvert)):
      $html .= _rendreSommaireNiveau($arbre['enfants'][$id], $arbre, $ancetres, $idCourant, $profondeur + 1);
    elseif ($hasEnfants):
      $html .= '<a href="' . BASE_URL . '/regles/regle.php?id=' . (int)$id . '"'
             . ' class="regles-sommaire__toggle" aria-label="Développer">'
             . '<i class="fa fa-chevron-right"></i></a>';
    endif;

    $html .= '</li>';
  endforeach;
  $html .= '</ul>';
  return $html;
}

// ============================================================
// reglesPrec() / reglesSuiv()
// ============================================================
// Retourne l'id du nœud précédent/suivant dans l'ordre DFS, ou null.

function reglesPrec(array $ordreLecture, int $idCourant): ?int
{
  $pos = array_search($idCourant, $ordreLecture, true);
  if ($pos === false || $pos === 0) return null;
  return $ordreLecture[$pos - 1];
}

function reglesSuiv(array $ordreLecture, int $idCourant): ?int
{
  $pos = array_search($idCourant, $ordreLecture, true);
  if ($pos === false) return null;
  $next = $pos + 1;
  return isset($ordreLecture[$next]) ? $ordreLecture[$next] : null;
}

// ============================================================
// reglesValiderParent()
// ============================================================
// Vérifie qu'un parent proposé n'est pas le nœud lui-même
// ni l'un de ses descendants — protection contre les cycles.
// Retourne true si la relation est sûre.

function reglesValiderParent(array $arbre, int $nodeId, int $newParentId): bool
{
  if ($newParentId === $nodeId) return false;
  // Tous les descendants de $nodeId
  $descendants = [];
  _collectDescendants($nodeId, $arbre['enfants'], $descendants);
  return !in_array($newParentId, $descendants, true);
}

function _collectDescendants(int $id, array $enfants, array &$acc): void
{
  if (empty($enfants[$id])) return;
  foreach ($enfants[$id] as $child):
    $acc[] = $child;
    _collectDescendants($child, $enfants, $acc);
  endforeach;
}

// ============================================================
// reglesGenererSlug()
// ============================================================
// Génère un slug URL-safe unique pour le ruleset donné.
// Essaie le slug de base, puis base-2, base-3…

function reglesGenererSlug(PDO $db, string $nom, int $rulesetVarId, int $excludeId = 0): string
{
  $base = _slugify($nom);
  $slug = $base;
  $i    = 2;
  while (true):
    $stmt = $db->prepare('
      SELECT COUNT(*) FROM dd_regles
      WHERE  reg_slug = ? AND reg_ruleset_var_id = ? AND reg_id != ?
    ');
    $stmt->execute([$slug, $rulesetVarId, $excludeId]);
    if ((int)$stmt->fetchColumn() === 0) return $slug;
    $slug = $base . '-' . $i++;
  endwhile;
}

function _slugify(string $s): string
{
  $s = transliterator_transliterate('Any-Latin; Latin-ASCII', $s) ?? $s;
  $s = strtolower($s);
  $s = preg_replace('/[^a-z0-9]+/', '-', $s);
  return trim($s, '-') ?: 'noeud';
}
