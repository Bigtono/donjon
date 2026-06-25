<?
// include/ajax/aide.php — Endpoint unique pour toutes les bulles d'aide contextuelle.
// Appelé par le handler .aide-icone de js/main.js.
//
// Paramètres GET :
//   cle (string) — clé déclarée dans include/aide-contextuelle.php
//
// Retourne le HTML de la bulle, ou 404 si la clé est inconnue.

require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../auth.php';
require_once __DIR__ . '/../helpers.php';

requireAuth();

$cle        = strParam($_GET['cle'] ?? '');
$ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);

$aides = require __DIR__ . '/../aide-contextuelle.php';

if (!$cle || !isset($aides[$cle])):
  http_response_code(404);
  echo '<p class="erreur">Aide introuvable.</p>';
  exit;
endif;

echo $aides[$cle]($db, $ruleset_id);
