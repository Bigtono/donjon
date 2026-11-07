<?php
// include/ajax/possession-calcul.php
// Aperçu en direct du compositeur d'objets magiques DD3.5 (SP-PO7) : reçoit la composition en
// cours, la fait calculer par le moteur (include/objet-compose.php) et renvoie le résultat en JSON.
// Aucune écriture : l'enregistrement d'une possession recalcule de son côté (D-PO19).
//
// POST + CSRF. Champs : voir composeSpecDepuisPost().
// Option : listes=<so_id> → renvoie aussi les listes de classe du sort (choix de la classe,
//          NLS minimum de chacune) pour alimenter le compositeur.

require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../auth.php';
require_once __DIR__ . '/../helpers.php';
require_once __DIR__ . '/../objet-compose.php';

header('Content-Type: application/json; charset=utf-8');

requireAuth();

if ($_SERVER['REQUEST_METHOD'] !== 'POST'):
  http_response_code(405);
  echo json_encode(['erreur' => 'Méthode non autorisée.']);
  exit;
endif;
verifyCsrf();

if ((int)($_SESSION['ruleset_var_id'] ?? 0) !== OC_RULESET):
  http_response_code(400);
  echo json_encode(['erreur' => 'La composition d\'objets magiques concerne le ruleset DD3.5.']);
  exit;
endif;

$r = composerObjet($db, composeSpecDepuisPost($_POST));

$reponse = [
  'ok'             => $r['ok'],
  'erreurs'        => $r['erreurs'],
  'avertissements' => $r['avertissements'],
  'nom'            => $r['nom'],
  'quantite'       => $r['quantite'],
  'charges'        => $r['charges'],
  'nls'            => $r['nls'],
  'prix_pc'        => $r['prix_pc'],
  'cout_pc'        => $r['cout_pc'],
  'cout_px'        => $r['cout_px'],
  'prix'           => formaterPrixPo($r['prix_pc']),
  'cout'           => formaterPrixPo($r['cout_pc']),
  'details'        => array_map(fn($d) => ['libelle' => $d['libelle'], 'prix' => formaterPrixPo($d['pc'])], $r['details']),
  'elements'       => array_map(fn($e) => [
    'type'    => $e['ppe_type'],
    'libelle' => $e['libelle'],
    'tete'    => $e['ppe_tete'],
    'niveau'  => $e['ppe_niveau'],
    'nls'     => $e['ppe_nls'],
    'nls_min' => $e['nls_min'] ?? null,
    'cla_id'  => $e['ppe_cla_id'],
  ], $r['elements']),
];

$so_listes = intParam($_POST['listes'] ?? 0);
if ($so_listes > 0):
  $reponse['listes'] = array_map(fn($l) => [
    'cla_id'  => $l['cla_id'],
    'cla_nom' => $l['cla_nom'],
    'niveau'  => $l['niveau'],
    'nls_min' => $l['nls_min'],
    'type'    => $l['mag_id'] === 2 ? 'divin' : 'profane',
  ], sortListesClasses($db, $so_listes));
endif;

echo json_encode($reponse);
