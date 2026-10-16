<?php
// profil/ruleset.php — Bascule du ruleset actif depuis le header (SP-RB).
// POST du switch .site-header__ruleset : passe la session sur l'autre ruleset,
// restaure le contexte de navigation mémorisé pour celui-ci (dernier
// personnage, campagne…) puis recharge la page équivalente. Le ruleset par
// défaut du profil n'est pas modifié : la bascule ne vaut que pour la session.
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAuth(BASE_URL . '/index.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST'):
  header('Location: ' . BASE_URL . '/index.php');
  exit;
endif;

verifyCsrf();

$actuel  = (int)($_SESSION['ruleset_var_id'] ?? 1);
$nouveau = intParam($_POST['ruleset_var_id'] ?? 0);

// Sans cible explicite, le switch bascule vers « l'autre » ruleset.
if ($nouveau <= 0):
  $nouveau = $actuel === 1 ? 2 : 1;
endif;

$chk = $db->prepare('SELECT var_id FROM dd_variables WHERE var_id = ? AND var_cat = \'ruleset\'');
$chk->execute([$nouveau]);
if (!$chk->fetch()):
  header('Location: ' . BASE_URL . '/index.php');
  exit;
endif;

basculerRuleset($db, $nouveau);

header('Location: ' . pageEquivalenteRuleset(strParam($_POST['retour'] ?? ''), $nouveau));
exit;
