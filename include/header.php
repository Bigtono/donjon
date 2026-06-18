<?
// include/header.php
// Variables attendues du contrôleur :
//   $page_title  (string) — titre affiché dans <title>
//   $js_module   (string, optionnel) — nom du fichier JS module à charger (sans .js)
//   $css_module  (string, optionnel) — nom du fichier CSS module à charger (sans -modules.css)
//   $body_class  (string, optionnel) — classe CSS supplémentaire sur <body>

$page_title = isset($page_title) ? h($page_title) . ' — Codex D&D' : 'Codex D&D';
$js_module  = isset($js_module) ? h($js_module) : '';
$css_module = isset($css_module) ? h($css_module) : '';
$body_class = isset($body_class) ? h($body_class) : '';

// Thème utilisateur — dark par défaut si non défini
$theme_valides = ['dark', 'light'];
$theme_actif   = in_array($_SESSION['j_theme'] ?? '', $theme_valides, true)
  ? $_SESSION['j_theme']
  : 'dark';

// Contexte de navigation (header) — derniers niveaux campagne consultés, ou
// repli sur le dernier personnage si aucune campagne n'est active (cf. doc §12).
$header_context_niveaux = [];
if (!empty($_SESSION['j_id'])):
  $header_context_niveaux = getHeaderCampagneContext();
  if (empty($header_context_niveaux)):
    $last_pe_id = getLastPersonnage();
    if ($last_pe_id > 0):
      $stmt_ctx_pe = $db->prepare('SELECT pe_nom FROM dd_personnages WHERE pe_id = ?');
      $stmt_ctx_pe->execute([$last_pe_id]);
      $ctx_pe_nom = $stmt_ctx_pe->fetchColumn();
      if ($ctx_pe_nom !== false):
        $header_context_niveaux[] = ['type' => 'personnage', 'id' => $last_pe_id, 'nom' => $ctx_pe_nom];
      endif;
    endif;
  endif;
endif;
?>
<!DOCTYPE html>
<html lang="fr">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><?= $page_title ?></title>
  <link rel="icon" type="image/png" href="<?= BASE_URL ?>/img/logo_codex.png">
  <link rel="stylesheet" href="<?= BASE_URL ?>/css/main.css">
  <link rel="stylesheet" href="<?= BASE_URL ?>/css/modules.css">
  <? if (!empty($css_module)): ?>
    <link rel="stylesheet" href="<?= BASE_URL ?>/css/<?= $css_module ?>-modules.css">
  <? endif ?>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <meta name="csrf-token" content="<?= csrfToken() ?>">
</head>

<body class="theme-<?= $theme_actif ?><?= $body_class ? ' ' . $body_class : '' ?>">

  <header class="site-header">
    <div class="site-header__brand">
      <a href="<?= BASE_URL ?>/index.php" class="site-header__logo">
        <img src="<?= BASE_URL ?>/img/logo_codex.png" alt="Codex DD" class="site-header__logo-img">
      </a>
      <? if (!empty($_SESSION['j_affichage_ruleset']) && !empty($_SESSION['rulesetRep'])): ?>
        <span class="site-header__ruleset"><?= h($_SESSION['rulesetRep']) ?></span>
      <? endif ?>
    </div>

    <nav class="site-header__nav">
      <? if (!empty($_SESSION['j_id'])): ?>
        <a href="<?= BASE_URL ?>/regles/index.php">Règles</a>
        <a href="<?= BASE_URL ?>/compendium/index.php">Compendium</a>
        <a href="<?= BASE_URL ?>/personnages/index.php">Personnages</a>
        <? if (!empty($_SESSION['j_mode_campagne'])): ?>
          <a href="<?= BASE_URL ?>/campagnes/index.php">Campagnes</a>
        <? endif ?>
        <a href="<?= BASE_URL ?>/wiki/univers.php">Univers</a>
        <? if (!empty($_SESSION['j_admin'])): ?>
          <a href="<?= BASE_URL ?>/admin/index.php">Admin</a>
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

  <? if (!empty($header_context_niveaux)): ?>
    <div class="site-header__context">
      <?
      $ctx_base_detail = BASE_URL . '/include/ajax/detail-pp';
      $ctx_urls = [
        'campagne' => $ctx_base_detail . '/campagne.php',
        'scenario' => $ctx_base_detail . '/scenario.php',
        'chapitre' => $ctx_base_detail . '/chapitre.php',
      ];
      $ctx_labels = ['campagne' => 'Campagne', 'scenario' => 'Scénario', 'chapitre' => 'Chapitre'];
      $ctx_chain  = [];
      foreach ($header_context_niveaux as $ctx_niveau):
        if ($ctx_niveau['type'] === 'personnage'):
      ?>
        <a class="site-header__context-btn"
           href="<?= BASE_URL ?>/personnages/fiche.php?id=<?= (int)$ctx_niveau['id'] ?>">
          <i class="fa fa-user"></i> <?= h($ctx_niveau['nom']) ?>
        </a>
      <?
          continue;
        endif;
        $ctx_chain[] = ['url' => $ctx_urls[$ctx_niveau['type']], 'params' => ['id' => $ctx_niveau['id']]];
      ?>
        <button type="button" class="site-header__context-btn"
                onclick="ouvrirContextePP(<?= h(json_encode($ctx_chain)) ?>)">
          <?= h($ctx_labels[$ctx_niveau['type']]) ?> : <?= h($ctx_niveau['nom']) ?>
        </button>
      <? endforeach ?>
    </div>
  <? endif ?>

  <main class="site-main">
    <div id="detail-pp-backdrop" class="overlay-backdrop noDisplay"></div>
    <div id="modification-backdrop" class="overlay-backdrop overlay-backdrop--edit noDisplay" onclick="fermerModification()"></div>
    <div id="detail-pp" class="overlay-panel noDisplay" style="position:fixed;"></div>
    <div id="modification" class="overlay-panel overlay-panel--edit noDisplay" style="position:fixed;"></div>
    <div id="detail-pp-sub-backdrop" class="overlay-backdrop overlay-backdrop--sub noDisplay" onclick="fermerSubPanel()"></div>
    <div id="detail-pp-sub" class="overlay-panel overlay-panel--sub noDisplay" style="position:fixed;"></div>

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