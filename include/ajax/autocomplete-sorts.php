<?php
// include/ajax/autocomplete-sorts.php
// Retourne jusqu'à 5 sorts en JSON pour l'autocomplétion du champ "sort lié"
// dans le formulaire objets magiques.
//
// GET q        : chaîne de recherche (min 2 caractères)
// GET ruleset  : ruleset_var_id courant (entier)
// GET res_ids  : ids de sources actives séparés par virgule (optionnel)
//
// Réponse JSON :
// [ { "id": 12, "label": "Boule de feu — Niv. 3 (Manuel des joueurs)" }, ... ]

require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../auth.php';
require_once __DIR__ . '/../helpers.php';

requireAuth();

header('Content-Type: application/json; charset=utf-8');

$q          = trim($_GET['q'] ?? '');
$ruleset_id = intParam($_GET['ruleset'] ?? 0);
$res_raw    = $_GET['res_ids'] ?? '';

if (mb_strlen($q) < 2 || $ruleset_id === 0):
  echo json_encode([]);
  exit;
endif;

// Validation de res_ids : liste d'entiers uniquement
$res_ids = [];
foreach (explode(',', $res_raw) as $v):
  $v = (int)trim($v);
  if ($v > 0) $res_ids[] = $v;
endforeach;

// Restriction aux sources actives si présentes
$where_res = '';
if (!empty($res_ids)):
  $placeholders = implode(',', array_fill(0, count($res_ids), '?'));
  $where_res    = " AND so.so_res_id IN ($placeholders)";
endif;

// Niveau unifié :
//   DD3.5 (ruleset_var_id = 1) : MIN(sc_niveau) via dd_sortclasse
//   DD2024                     : so_niveau directement
$sql = "
  SELECT
    so.so_id,
    so.so_nom,
    res.res_nom,
    CASE
      WHEN so.so_ruleset_var_id = 1
        THEN (SELECT MIN(sc_niveau) FROM dd_sortclasse WHERE sc_so_id = so.so_id)
      ELSE so.so_niveau
    END AS niveau
  FROM dd_sorts so
  LEFT JOIN dd_ressources res ON res.res_id = so.so_res_id
  WHERE so.so_ruleset_var_id = ?
    AND so.so_nom LIKE ?
    AND so.so_camp_id IS NULL
    $where_res
  ORDER BY so.so_nom
  LIMIT 5
";

$params = array_merge([$ruleset_id, '%' . $q . '%'], $res_ids);

$stmt = $db->prepare($sql);
$stmt->execute($params);
$rows = $stmt->fetchAll();

$result = [];
foreach ($rows as $row):
  $niveau = $row['niveau'] !== null ? 'Niv. ' . (int)$row['niveau'] : '—';
  $result[] = [
    'id'    => (int)$row['so_id'],
    // Les chaînes sont échappées côté client via textContent — pas de h() ici
    // pour éviter le double-encodage des &amp; dans les labels JSON
    'label' => $row['so_nom'] . ' — ' . $niveau . ' (' . $row['res_nom'] . ')',
  ];
endforeach;

echo json_encode($result, JSON_UNESCAPED_UNICODE);
