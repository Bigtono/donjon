<?php
// personnages/objets.php — Conservé en redirection.
//
// La page est devenue possessions.php au passage au sous-menu (2026-09-01),
// pour couvrir objets magiques ET équipement. Ce fichier ne subsiste que pour
// ne pas casser d'éventuels liens ou signets existants.
require_once '../include/db.php';
require_once '../include/helpers.php';

$pe_id = intParam($_GET['id'] ?? 0);
header('Location: ' . BASE_URL . '/personnages/possessions.php' . ($pe_id ? '?id=' . $pe_id : ''), true, 301);
exit;
