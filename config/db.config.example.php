<?php
// config/db.config.php — Credentials de connexion à la base de données
// Copier ce fichier en db.config.php et renseigner les valeurs réelles.
// Ce fichier exemple est commité ; db.config.php est exclu du dépôt.

define('BASE_URL', '/donjon');
define('DEV_MODE', false); // true en développement local

define('DB_DSN',  'mysql:host=localhost;dbname=NOM_BASE;charset=utf8mb4');
define('DB_USER', 'UTILISATEUR_MYSQL');
define('DB_PASS', 'MOT_DE_PASSE');
