<?php
// include/ajax/liste-rencontres-campagne.php
// Endpoint JSON — liste des rencontres d'une campagne, groupées par
// scénario/chapitre. Utilisé par le popup contextuel Transférer/Dupliquer
// une opposition (js/campagne.js).
// Paramètres GET : camp_id (int, requis), exclude_re_id (int, optionnel —
// omet cette rencontre du résultat, utilisé par Transférer pour ne pas
// proposer la rencontre d'origine).

require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../auth.php';
require_once __DIR__ . '/../helpers.php';

requireAuth();
header('Content-Type: application/json');

$camp_id       = intParam($_GET['camp_id']       ?? 0);
$exclude_re_id = intParam($_GET['exclude_re_id'] ?? 0);

if (!$camp_id || !isMJ($db, $camp_id)):
  http_response_code(403);
  echo json_encode(['erreur' => 'Accès refusé']);
  exit;
endif;

$sql = '
  SELECT re.re_id, re.re_nom, re.re_code,
         scc.scc_id, scc.scc_nom,
         sce.sce_id, sce.sce_nom
  FROM   dd_rencontres re
  JOIN   dd_scenarios_chapitres scc ON scc.scc_id = re.re_scc_id
  JOIN   dd_scenarios sce           ON sce.sce_id = scc.scc_sce_id
  WHERE  sce.sce_camp_id = ? AND sce.sce_supprime = 0
    AND  scc.scc_supprime = 0 AND re.re_supprime = 0
';
$args = [$camp_id];

if ($exclude_re_id > 0):
  $sql   .= ' AND re.re_id != ?';
  $args[] = $exclude_re_id;
endif;

$sql .= ' ORDER BY sce.sce_nom ASC, scc.scc_nom ASC, re.re_nom ASC';

$stmt = $db->prepare($sql);
$stmt->execute($args);
$rows = $stmt->fetchAll();

// Regroupement scénario > chapitre > rencontres, pour affichage hiérarchique
// dans le popup côté client.
$groupes = [];
foreach ($rows as $r):
  $cle = $r['sce_id'] . '-' . $r['scc_id'];
  if (!isset($groupes[$cle])):
    $groupes[$cle] = [
      'sce_nom'     => $r['sce_nom'],
      'scc_nom'     => $r['scc_nom'],
      'rencontres'  => [],
    ];
  endif;
  $groupes[$cle]['rencontres'][] = [
    're_id'   => (int)$r['re_id'],
    're_nom'  => $r['re_nom'],
    're_code' => $r['re_code'],
  ];
endforeach;

echo json_encode(['groupes' => array_values($groupes)]);
