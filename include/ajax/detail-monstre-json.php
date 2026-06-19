<?php
// include/ajax/detail-monstre-json.php
// Retourne les champs d'un monstre en JSON, pour pré-remplir le formulaire opposition
// après sélection dans le sous-panneau de recherche.
// Paramètres GET : id (int) — mo_id, camp_id (int, contrôle d'accès)

require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../auth.php';
require_once __DIR__ . '/../helpers.php';

requireAuth();
header('Content-Type: application/json');

$id      = intParam($_GET['id']      ?? 0);
$camp_id = intParam($_GET['camp_id'] ?? 0);

if (!$id || !$camp_id || !isMJ($db, $camp_id)):
  http_response_code(403);
  echo json_encode(['erreur' => 'Accès refusé']);
  exit;
endif;

$stmt = $db->prepare('
  SELECT mo.mo_id, mo.mo_nom, mo.mo_stats, mocat.mocat_nom
  FROM   dd_monstres mo
  LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
  WHERE  mo.mo_id = ?
');
$stmt->execute([$id]);
$mo = $stmt->fetch();

if (!$mo):
  http_response_code(404);
  echo json_encode(['erreur' => 'Monstre introuvable']);
  exit;
endif;

echo json_encode(['ok' => true, 'monstre' => $mo]);
