<?php
// regles/tableaux.php — Redirection permanente vers le gestionnaire de tableaux.
//
// Le gestionnaire a quitté le module Règles en SP-TB10 : les tableaux sont un
// élément partagé (règles, compendium, campagnes). Ce fichier ne subsiste que
// pour les liens et signets pointant encore sur l'ancienne adresse.
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9c

require_once '../include/db.php';

// Les paramètres de l'ancienne page sont conservés : q est inchangé, le filtre
// « écran du MJ » est renommé ecran → f_ecran par le moteur de liste.
$params = $_GET;
if (isset($params['ecran'])):
  unset($params['ecran']);
  $params['f_ecran'] = 1;
endif;

$query = http_build_query($params);

header('Location: ' . BASE_URL . '/tableaux/index.php' . ($query !== '' ? '?' . $query : ''), true, 301);
exit;
