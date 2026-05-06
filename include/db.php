<?php
// include/db.php — Connexion PDO (singleton)
// Chargé en premier dans chaque page contrôleur

define('BASE_URL', '/donjon');

$dsn  = 'mysql:host=localhost;dbname=maikasteiymaika;charset=utf8mb4';
$user = 'blabla';
$pass = 'blabla';

$options = [
  PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
  PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
  PDO::ATTR_EMULATE_PREPARES   => false,
];

try {
  $db = new PDO($dsn, $user, $pass, $options);
} catch (PDOException $e) {
  // En production : logguer l'erreur sans l'exposer
  error_log('DB connexion échouée : ' . $e->getMessage());
  http_response_code(503);
  exit('Service temporairement indisponible.');
}
