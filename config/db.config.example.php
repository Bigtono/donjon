<?php
// config/db.config.php — Credentials de connexion à la base de données
// Copier ce fichier en db.config.php et renseigner les valeurs réelles.
// Ce fichier exemple est commité ; db.config.php est exclu du dépôt.

define('BASE_URL', '/donjon');
define('DEV_MODE', false); // true en développement local
define('SITE_ORIGINE', 'http://maikastel.fr'); // Schéma + domaine des liens envoyés par mail, sans BASE_URL
define('MAIL_EXPEDITEUR', 'noreply@maikastel.fr'); // Adresse sur le domaine couvert par le SPF

// Envoi SMTP authentifié. Tant que le mot de passe est vide, le site utilise mail().
define('SMTP_HOTE', 'ssl0.ovh.net');
define('SMTP_PORT', 465);
define('SMTP_UTILISATEUR', 'noreply@maikastel.fr');
define('SMTP_MOT_DE_PASSE', '');

define('DB_DSN',  'mysql:host=127.0.0.1;dbname=NOM_BASE;charset=utf8mb4');
define('DB_USER', 'UTILISATEUR_MYSQL');
define('DB_PASS', 'MOT_DE_PASSE');
