<?php
// include/maintenance.php — Page servie pendant un déploiement (SP-DP4)
//
// Incluse par include/db.php tant que le fichier .maintenance existe à la
// racine du site. Le déployeur le pose au début d'un envoi et le retire à la
// fin : aucune page ne s'exécute ainsi sur un mélange de fichiers anciens et
// neufs, ni sur un code neuf dont les migrations ne sont pas encore passées.
//
// Autonome : ni session, ni base, ni header.php — rien de ce qui est en cours
// de transfert. Seule la feuille de style principale est chargée.
http_response_code(503);
header('Retry-After: 60');
header('Cache-Control: no-store');
header('Content-Type: text/html; charset=UTF-8');
?>
<!DOCTYPE html>
<html lang="fr">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Mise à jour en cours — Codex D&amp;D</title>
  <link rel="stylesheet" href="<?= BASE_URL ?>/css/main.css">
</head>

<body class="theme-dark">
  <main class="site-main">
    <h1>Mise à jour en cours</h1>
    <p class="flash-message flash-message--info">
      Le site est en cours de mise à jour. Il sera de nouveau disponible dans une minute :
      rechargez la page.
    </p>
  </main>
</body>

</html>
