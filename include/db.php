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
  // Diagnostic D-CFG2 : on journalise l'environnement détecté et l'hôte DSN
  // ciblé (jamais DB_USER ni DB_PASS) pour distinguer immédiatement une
  // mauvaise branche de détection (D-CFG1) d'un identifiant OVH invalide.
  $environnementLogue = DEV_MODE ? 'DEV (local)' : 'PROD (OVH)';
  $hoteDsnLogue = preg_match('/host=([^;]+)/', DB_DSN, $m) ? $m[1] : 'inconnu';
  error_log(
    'DB connexion échouée [env=' . $environnementLogue . ', host_dsn=' . $hoteDsnLogue .
    ', http_host=' . ($_SERVER['HTTP_HOST'] ?? 'n/a') . '] : ' . $e->getMessage()
  );
  http_response_code(503);
  exit('Service temporairement indisponible Err1.');
}
