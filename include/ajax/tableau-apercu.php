<?php
// include/ajax/tableau-apercu.php — Aperçu d'un tableau en cours de saisie (SP-TB3)
//
// Rend le HTML d'un contenu POSTé sans rien écrire en base : la convention de
// saisie est textuelle, l'auteur doit pouvoir vérifier fusions et alignements
// avant d'enregistrer.
//
// POST : tab_nom, tab_contenu, tab_align, tab_note (+ csrf_token)
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9c

require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../auth.php';
require_once __DIR__ . '/../helpers.php';
require_once __DIR__ . '/../tableau-parser.php';

requireAuth();
verifyCsrf();

if (!canEditCompendium()):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

$ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);
$contenu    = (string)($_POST['tab_contenu'] ?? '');

if (trim($contenu) === ''):
  echo '<p class="text-muted">Rien à afficher — le contenu est vide.</p>';
  exit;
endif;

$tab = [
  'tab_slug'    => '',   // pas d'ancre id sur un aperçu
  'tab_nom'     => strParam($_POST['tab_nom']   ?? ''),
  'tab_contenu' => $contenu,
  'tab_align'   => strParam($_POST['tab_align'] ?? ''),
  'tab_note'    => strParam($_POST['tab_note']  ?? ''),
];

// Index de liaison chargé uniquement si le contenu porte au moins un tag
$index = preg_match('/[@%#$&]/', $contenu)
  ? chargerIndexMonstre($db, $ruleset_id, getActiveResIds($db))
  : [];

echo rendreTableau($tab, $index, $ruleset_id, $db);
