<?php
// include/ajax/recherche-monstre.php
// Endpoint JSON d'autocomplétion pour le sélecteur de monstre (module Campagnes).
// Scope : ruleset de la campagne + sources actives (getActiveResIdsCampagne).
// Paramètres GET : camp_id (int, requis), q (texte, optionnel), mocat_id (int, optionnel)

require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../auth.php';
require_once __DIR__ . '/../helpers.php';

requireAuth();
header('Content-Type: application/json');

$camp_id  = intParam($_GET['camp_id']  ?? 0);
$q        = trim($_GET['q']            ?? '');
$mocat_id = intParam($_GET['mocat_id'] ?? 0);

if (!$camp_id || !isMJ($db, $camp_id)):
  http_response_code(403);
  echo json_encode(['erreur' => 'Accès refusé']);
  exit;
endif;

$stmt = $db->prepare('SELECT camp_ruleset_var_id FROM dd_campagnes WHERE camp_id = ? AND camp_supprime = 0');
$stmt->execute([$camp_id]);
$ruleset_var_id = (int)$stmt->fetchColumn();

if (!$ruleset_var_id):
  http_response_code(404);
  echo json_encode(['erreur' => 'Campagne introuvable']);
  exit;
endif;

$res_ids = getActiveResIdsCampagne($db, $camp_id, $ruleset_var_id);

if (empty($res_ids)):
  echo json_encode(['resultats' => []]);
  exit;
endif;

$in   = resIdsPlaceholders($res_ids);
$args = $res_ids;

$sql = "
  SELECT mo.mo_id, mo.mo_nom, mo.mo_fp_id, mocat.mocat_nom
  FROM   dd_monstres mo
  LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
  WHERE  mo.mo_ruleset_var_id = ?
    AND  mo.mo_res_id IN ($in)
";
array_unshift($args, $ruleset_var_id);

if ($q !== ''):
  $sql   .= ' AND mo.mo_nom LIKE ?';
  $args[] = '%' . $q . '%';
endif;

if ($mocat_id > 0):
  $sql   .= ' AND mo.mo_mocat_id = ?';
  $args[] = $mocat_id;
endif;

$sql .= ' ORDER BY mo.mo_nom ASC LIMIT 20';

$stmt = $db->prepare($sql);
$stmt->execute($args);
$resultats = $stmt->fetchAll();

echo json_encode(['resultats' => $resultats]);
