<?php
// include/campagne-contexte.php — Socle commun des sous-pages d'une campagne (SP-CP9).
//
// La page d'une campagne est découpée en sous-pages, sur le modèle du module
// Personnages : Description (campagne.php), Personnages (campagne-personnages.php)
// et Scénarios (campagne-scenarios.php). Ce fragment, inclus en tête de chacune,
// charge la campagne, vérifie l'accès du MJ et prépare les variables du gabarit.
//
// Paramètre GET : id (int) — camp_id
// Produit : $id, $camp, $base_modifier, $url_enreg et les variables du header.
//
// Le ruleset n'est pas affiché (D-CP11) : inutile de le joindre ici.

require_once __DIR__ . '/db.php';
require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/helpers.php';

requireAuth();

$id = intParam($_GET['id'] ?? 0);
if (!$id):
  $_SESSION['flash_message'] = ['type' => 'error', 'text' => 'Identifiant manquant.'];
  header('Location: ' . BASE_URL . '/campagnes/index.php');
  exit;
endif;

$stmt = $db->prepare('
  SELECT camp.*, un.un_nom AS univers_nom
  FROM   dd_campagnes camp
  LEFT JOIN dd_univers un ON un.un_id = camp.camp_un_id
  WHERE  camp.camp_id = ? AND camp.camp_supprime = 0
');
$stmt->execute([$id]);
$camp = $stmt->fetch();

if (!$camp || !isMJ($db, $id)):
  $_SESSION['flash_message'] = ['type' => 'error', 'text' => 'Campagne introuvable ou accès refusé.'];
  header('Location: ' . BASE_URL . '/campagnes/index.php');
  exit;
endif;

// Contexte de navigation du header (cf. §12) — chaque sous-page est un point
// de consultation de la campagne.
setLastCampagne($id, $camp['camp_nom']);

$page_title      = $camp['camp_nom'];
$js_module       = 'campagne';
$css_module      = 'campagnes';
$body_class      = 'camp-plein';
$outils_camp_id  = $id;

$base_modifier = BASE_URL . '/include/ajax/modifier';
$url_enreg     = BASE_URL . '/campagnes/enregistrement.php?ajax=1';
