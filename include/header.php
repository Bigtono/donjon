<?
// include/header.php
// Variables attendues du contrôleur :
//   $page_title  (string) — titre affiché dans <title>
//   $js_module   (string, optionnel) — nom du fichier JS module à charger (sans .js)
//   $body_class  (string, optionnel) — classe CSS supplémentaire sur <body>

$page_title = isset($page_title) ? h($page_title) . ' — Codex DD' : 'Codex DD';
$js_module  = isset($js_module) ? h($js_module) : '';
$body_class = isset($body_class) ? h($body_class) : '';
?>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><?= $page_title ?></title>
  <link rel="stylesheet" href="<?= BASE_URL ?>/css/main.css">
  <link rel="stylesheet" href="<?= BASE_URL ?>/css/modules.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body class="<?= $body_class ?>">

<header class="site-header">
  <div class="site-header__brand">
    <a href="<?= BASE_URL ?>/index.php" class="site-header__logo">Codex DD</a>
    <? if (!empty($_SESSION['j_affichage_ruleset']) && !empty($_SESSION['rulesetRep'])): ?>
      <span class="site-header__ruleset"><?= h($_SESSION['rulesetRep']) ?></span>
    <? endif ?>
  </div>

  <nav class="site-header__nav">
    <? if (!empty($_SESSION['j_id'])): ?>
      <a href="<?= BASE_URL ?>/compendium/classes.php">Compendium</a>
      <a href="<?= BASE_URL ?>/personnages/fiche.php">Personnages</a>
      <? if (!empty($_SESSION['j_mode_campagne'])): ?>
        <a href="<?= BASE_URL ?>/campagnes/campagne.php">Campagnes</a>
      <? endif ?>
      <a href="<?= BASE_URL ?>/wiki/univers.php">Univers</a>
      <? if (!empty($_SESSION['j_admin'])): ?>
        <a href="<?= BASE_URL ?>/admin/utilisateurs.php">Admin</a>
      <? endif ?>
      <a href="<?= BASE_URL ?>/profil/index.php" class="site-header__profil">
        <i class="fa fa-user-circle"></i> <?= h($_SESSION['j_pseudo'] ?? '') ?>
      </a>
      <a href="<?= BASE_URL ?>/index.php?action=logout" class="site-header__logout" title="Déconnexion">
        <i class="fa fa-sign-out-alt"></i>
      </a>
    <? else: ?>
      <a href="<?= BASE_URL ?>/index.php">Connexion</a>
    <? endif ?>
  </nav>
</header>

<main class="site-main">
  <div id="detail-pp" class="overlay-panel noDisplay"></div>
  <div id="modification" class="overlay-panel overlay-panel--edit noDisplay"></div>

<?
// Affichage d'un message flash s'il existe
if (!empty($_SESSION['flash_message'])):
  $flash = $_SESSION['flash_message'];
  unset($_SESSION['flash_message']);
?>
  <div class="flash-message flash-message--<?= h($flash['type']) ?>">
    <?= h($flash['text']) ?>
  </div>
<? endif ?>
