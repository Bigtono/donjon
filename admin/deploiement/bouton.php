<?php
// admin/deploiement/bouton.php — Bouton « Déployer » du header (SP-DP4)
//
// Inclus par include/header.php uniquement s'il existe — il n'existe jamais en
// production, ce dossier n'étant pas transféré. N'affiche rien si la requête
// ne vient pas du poste lui-même, ni pour un non-administrateur. Charge aussi
// la feuille de style et le script du module : le panneau s'ouvre depuis
// n'importe quelle page du site.
require_once __DIR__ . '/lib.php';

if (!empty($_SESSION['j_admin']) && deploiementEstLocal()):
?>
  <link rel="stylesheet" href="<?= BASE_URL ?>/admin/deploiement/deploiement.css">
  <a href="#" class="site-header__deploiement" title="Déployer en production"
     onclick="ouvrirDeploiement(); return false;">
    <i class="fa fa-cloud-arrow-up"></i>
    <span class="site-header__nav-label">Déployer</span>
  </a>
  <script src="<?= BASE_URL ?>/admin/deploiement/deploiement.js" defer></script>
<?php
endif;
