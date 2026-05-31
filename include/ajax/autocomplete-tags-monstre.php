<?php
// include/ajax/autocomplete-tags-monstre.php
// Autocomplétion pour les tags explicites du textarea monstre.
//
// GET type    : 'regle' (@nn@) ou 'glossaire' (%nn%)
// GET q       : terme recherché (min 2 caractères)
// GET ruleset : ruleset_var_id courant
//
// Réponse JSON :
// [ { "id": 12, "label": "Charmé", "contexte": "États > Conditions" }, ... ]

require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../auth.php';
require_once __DIR__ . '/../helpers.php';

requireAuth();
header('Content-Type: application/json; charset=utf-8');

$type       = $_GET['type']    ?? '';
$q          = trim($_GET['q']  ?? '');
$ruleset_id = intParam($_GET['ruleset'] ?? 0);

if (mb_strlen($q) < 2 || $ruleset_id === 0 || !in_array($type, ['regle', 'glossaire'])):
  echo json_encode([]);
  exit;
endif;

$reg_type_sql = $type === 'glossaire' ? "'glossaire'" : "'regle','chapitre'";

// Charger toutes les règles du ruleset en mémoire pour construire l'arbre
// (même logique que chargerArbreRegles mais allégée)
$stmt = $db->prepare("
  SELECT reg_id, reg_reg_id, reg_nom, reg_type
  FROM   dd_regles
  WHERE  reg_ruleset_var_id = ?
    AND  reg_visible = 1
    AND  reg_type IN ($reg_type_sql)
  ORDER  BY reg_nom ASC
");
$stmt->execute([$ruleset_id]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Index par id pour la remontée du chemin
$index = [];
foreach ($rows as $r):
  $index[(int)$r['reg_id']] = $r;
endforeach;

// Construire le fil d'Ariane d'un nœud (max 3 niveaux pour le contexte)
function contexteRegle(array $index, int $id): string
{
  $chemin = [];
  $cur    = $id;
  $guard  = 0;
  while ($guard++ < 8):
    $n = $index[$cur] ?? null;
    if (!$n) break;
    $par = $n['reg_reg_id'] !== null ? (int)$n['reg_reg_id'] : null;
    if ($par === null) break;
    $chemin[] = $index[$par]['reg_nom'] ?? '';
    $cur = $par;
  endwhile;
  $chemin = array_filter(array_reverse($chemin));
  return implode(' › ', $chemin);
}

// Filtrer par q
$q_lower = mb_strtolower($q, 'UTF-8');
$result  = [];
foreach ($rows as $r):
  if (mb_strpos(mb_strtolower($r['reg_nom'], 'UTF-8'), $q_lower) === false) continue;
  $id  = (int)$r['reg_id'];
  $ctx = contexteRegle($index, $id);
  $result[] = [
    'id'      => $id,
    'label'   => $r['reg_nom'],
    'contexte' => $ctx,
  ];
  if (count($result) >= 8) break;
endforeach;

echo json_encode($result, JSON_UNESCAPED_UNICODE);
