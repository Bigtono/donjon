<?php
// admin/deploiement/garde.php — Contrôles d'accès du module de déploiement (SP-DP)
// Inclus en tête de chaque point d'entrée du module : administrateur connecté
// ET requête venue de la machine qui la sert (deploiementEstLocal()). Sinon, 404 : le module n'a
// pas à révéler son existence.
require_once __DIR__ . '/../../include/db.php';
require_once __DIR__ . '/../../include/auth.php';
require_once __DIR__ . '/../../include/helpers.php';
require_once __DIR__ . '/lib.php';

requireAdmin(BASE_URL . '/index.php');

if (!deploiementEstLocal()):
  http_response_code(404);
  exit;
endif;
