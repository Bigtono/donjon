<?php
// include/ajax/releve-device.php
// Beacon SP-RS5 — enregistre les caractéristiques d'affichage du navigateur,
// une fois par session authentifiée, appelé par releveDevice() (js/main.js).
//
// Deux écritures : instantané dans dd_joueurs.j_last_* (écrasé à chaque
// connexion) et ligne datée dans dd_connexions (historique alimentant
// l'arbitrage des paliers responsive).
//
// Aucune donnée personnelle supplémentaire n'est stockée : ni IP, ni
// géolocalisation. co_session est un SHA-1 de l'identifiant de session — clé
// d'unicité uniquement, cf. DECISIONS_LOG.md [2026-08-22] D-RS23.

require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../auth.php';
require_once __DIR__ . '/../helpers.php';

header('Content-Type: application/json; charset=utf-8');

requireAuth();
verifyCsrf();

$j_id = (int)$_SESSION['j_id'];

// Un seul relevé par session. Le drapeau couvre le cas courant ; l'unicité
// réelle est garantie par uk_co_session (plusieurs onglets ouverts d'un coup
// émettent le beacon avant que le drapeau ne soit posé).
if (!empty($_SESSION['releve_device'])):
  echo json_encode(['ok' => true, 'deja' => true]);
  exit;
endif;

// --- Normalisation des valeurs reçues ---------------------------------------
// Tout vient du client : rien n'est cru sur parole, tout est borné au domaine
// de la colonne.

function releveEntier($valeur, int $max): ?int
{
  if ($valeur === null || $valeur === '') return null;
  $n = (int)$valeur;
  if ($n < 0)    return null;
  if ($n > $max) return $max;
  return $n;
}

function releveTexte($valeur, int $max): ?string
{
  $s = trim((string)$valeur);
  if ($s === '') return null;
  return mb_substr($s, 0, $max);
}

$vp_w        = releveEntier($_POST['vp_w']     ?? null, 65535);
$vp_h        = releveEntier($_POST['vp_h']     ?? null, 65535);
$screen_w    = releveEntier($_POST['screen_w'] ?? null, 65535);
$screen_h    = releveEntier($_POST['screen_h'] ?? null, 65535);
$touch       = releveEntier($_POST['touch']    ?? null, 255);

$dpr = null;
if (isset($_POST['dpr']) && is_numeric($_POST['dpr'])):
  $dpr = (float)$_POST['dpr'];
  if ($dpr <= 0 || $dpr > 99.99) $dpr = null;
  else $dpr = round($dpr, 2);
endif;

$orientation = releveTexte($_POST['orientation'] ?? '', 10);
if (!in_array($orientation, ['portrait', 'landscape'], true)) $orientation = null;

$plateforme = releveTexte($_POST['plateforme'] ?? '', 60);
$langue     = releveTexte($_POST['langue']     ?? '', 10);
$ua         = releveTexte($_POST['ua']         ?? '', 255);

// Un relevé sans largeur de viewport n'a aucune valeur pour SP-RS5
if ($vp_w === null):
  http_response_code(400);
  echo json_encode(['ok' => false, 'erreur' => 'Relevé incomplet.']);
  exit;
endif;

// --- Écritures ---------------------------------------------------------------

$maintenant = date('Y-m-d H:i:s');
$empreinte  = sha1(session_id());

// Le patch sql/2026-08-22_releves_device_sp-rs5.sql doit avoir été appliqué.
// Tant qu'il ne l'est pas, on échoue proprement sans poser le drapeau : la
// collecte reprendra d'elle-même à la session suivante, une fois la base à jour.
try {
  $db->beginTransaction();

  // INSERT IGNORE : uk_co_session (co_j_id, co_session) garantit une seule ligne
  // par session, même si plusieurs onglets émettent le beacon simultanément.
  $ins = $db->prepare('
    INSERT IGNORE INTO dd_connexions
      (co_j_id, co_date, co_session, co_vp_w, co_vp_h, co_dpr,
       co_screen_w, co_screen_h, co_orientation, co_touch,
       co_plateforme, co_langue, co_ua)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  ');
  $ins->execute([
    $j_id, $maintenant, $empreinte, $vp_w, $vp_h, $dpr,
    $screen_w, $screen_h, $orientation, $touch,
    $plateforme, $langue, $ua,
  ]);

  $upd = $db->prepare('
    UPDATE dd_joueurs
    SET    j_last_device_date = ?, j_last_vp_w = ?, j_last_vp_h = ?, j_last_dpr = ?,
           j_last_screen_w = ?, j_last_screen_h = ?, j_last_orientation = ?,
           j_last_touch = ?, j_last_plateforme = ?, j_last_ua = ?
    WHERE  j_id = ?
  ');
  $upd->execute([
    $maintenant, $vp_w, $vp_h, $dpr,
    $screen_w, $screen_h, $orientation,
    $touch, $plateforme, $ua,
    $j_id,
  ]);

  $db->commit();
} catch (PDOException $e) {
  if ($db->inTransaction()) $db->rollBack();
  http_response_code(500);
  echo json_encode(['ok' => false, 'erreur' => 'Relevé non enregistré.']);
  exit;
}

$_SESSION['releve_device'] = true;

echo json_encode(['ok' => true]);
