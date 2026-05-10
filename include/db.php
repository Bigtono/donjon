<?php
// include/db.php — Connexion PDO (singleton)
// Les credentials sont dans config/db.config.php (exclu du dépôt git).

$configFile = __DIR__ . '/../config/db.config.php';

if (!file_exists($configFile)) {
  error_log('Fichier de configuration introuvable : ' . $configFile);
  http_response_code(503);
  exit('Service temporairement indisponible Err0.');
}

require_once $configFile;

$options = [
  PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
  PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
  PDO::ATTR_EMULATE_PREPARES   => false,
];

try {
  $db = new PDO(DB_DSN, DB_USER, DB_PASS, $options);
} catch (PDOException $e) {
  error_log('DB connexion échouée : ' . $e->getMessage());
  http_response_code(503);
  exit('Service temporairement indisponible Err1.');
}
