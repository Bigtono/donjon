<?php
// include/ajax/liste-apercu.php
// Aperçu du sélecteur de liste (SP-PO3) : valide les choix, construit le tag canonique et
// compte les lignes que la liste afficherait. Lecture seule (GET), JSON.
//
// Paramètres GET :
//   ent    equipement | objet
//   fam    slugs de famille, séparés par des virgules (vide = toutes)
//   src    identifiants de source, séparés par des virgules (vide = sources actives du lecteur)
//   tri    '' | nom | prix
//   titre  '' | '-' | texte
//
// Le comptage suit les sources ACTIVES de l'utilisateur quand aucune source n'est figée :
// c'est ce que le lecteur verra, pas forcément ce que voit un autre utilisateur.
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9e

require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../auth.php';
require_once __DIR__ . '/../helpers.php';
require_once __DIR__ . '/../liste-parser.php';

header('Content-Type: application/json; charset=utf-8');

requireAuth();
if (!canEditCompendium()):
  http_response_code(403);
  echo json_encode(['erreur' => 'Accès refusé.']);
  exit;
endif;

$ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);
$liste = fn(string $k): array => array_values(array_filter(array_map('trim', explode(',', (string)($_GET[$k] ?? ''))), 'strlen'));

$res = listeConstruireTag(
  $db,
  strParam($_GET['ent'] ?? ''),
  $liste('fam'),
  $liste('src'),
  strParam($_GET['tri'] ?? ''),
  strParam($_GET['titre'] ?? ''),
  $ruleset_id
);

if ($res['tag'] === null):
  echo json_encode(['tag' => null, 'erreur' => $res['erreur']]);
  exit;
endif;

$html = listeRendreTag($db, $res['tag'], $ruleset_id);
if ($html === null):
  echo json_encode(['tag' => null, 'erreur' => 'Cette liste ne peut pas être rendue.']);
  exit;
endif;

$n = listeCompterLignes($html);
echo json_encode([
  'tag'      => $res['tag'],
  'erreur'   => null,
  'lignes'   => $n['total'],
  'tronquee' => $n['total'] > LISTE_MAX_LIGNES,
  'max'      => LISTE_MAX_LIGNES,
]);
