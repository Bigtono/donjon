<?php
// regles/enregistrement.php — Écriture du module Règles
//
// Accès : canEditCompendium() uniquement (admin + gestionnaire compendium)
// CSRF  : vérifié systématiquement
//
// POST requis :
//   action  — 'sauvegarder' | 'supprimer' | 'reordonner'
//
// GET ajax=1 → JSON {ok, id, erreur}
// Sinon      → redirect avec flash message
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9b + DECISIONS_LOG.md

require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';
require_once '../include/regles-arbre.php';

requireAuth();
verifyCsrf();

if (!canEditCompendium()):
  _repondreErreur(true, 'Accès refusé.');
endif;

$is_ajax = isset($_GET['ajax']);
$action  = strParam($_POST['action'] ?? '');
$redirect = BASE_URL . '/regles/index.php';

switch ($action):
  case 'sauvegarder':
    _sauvegarder($db, $is_ajax, $redirect);
    break;
  case 'supprimer':
    _supprimer($db, $is_ajax, $redirect);
    break;
  case 'reordonner':
    _reordonner($db, $is_ajax);
    break;
  default:
    _repondreErreur($is_ajax, 'Action inconnue : ' . h($action), $redirect);
endswitch;

// ============================================================
// Helpers réponse
// ============================================================

function _repondreOk(bool $is_ajax, int $id, string $redirect): void
{
  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode([
      'ok'         => true,
      'id'         => $id,
      'url_detail' => BASE_URL . '/include/ajax/detail-pp/regle.php',
    ]);
    exit;
  endif;
  $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Modification enregistrée.'];
  header('Location: ' . $redirect);
  exit;
}

function _repondreErreur(bool $is_ajax, string $message, string $redirect = ''): void
{
  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode(['ok' => false, 'erreur' => $message]);
    exit;
  endif;
  $_SESSION['flash_message'] = ['type' => 'error', 'text' => $message];
  header('Location: ' . ($redirect ?: BASE_URL . '/regles/index.php'));
  exit;
}

// ============================================================
// Sauvegarder (INSERT ou UPDATE)
// ============================================================

function _sauvegarder(PDO $db, bool $is_ajax, string $redirect): void
{
  $id           = intParam($_POST['reg_id']           ?? 0);
  $nom          = strParam($_POST['reg_nom']           ?? '');
  $type         = strParam($_POST['reg_type']          ?? 'regle');
  $parent_id    = intParam($_POST['reg_reg_id']        ?? 0);
  $ordre        = intParam($_POST['reg_ordre']         ?? 0);
  $visible      = intParam($_POST['reg_visible']       ?? 1);
  $texte        = $_POST['reg_texte'] ?? '';   // HTML TinyMCE — non échappé
  $ruleset_id   = (int)($_SESSION['ruleset_var_id'] ?? 1);

  // Validation
  if ($nom === ''):
    _repondreErreur($is_ajax, 'Le nom est obligatoire.');
  endif;

  $types_valides = ['chapitre', 'regle', 'glossaire'];
  if (!in_array($type, $types_valides, true)):
    _repondreErreur($is_ajax, 'Type invalide.');
  endif;

  // Résolution du parent (0 = racine = NULL)
  $parent_sql = $parent_id > 0 ? $parent_id : null;

  // Vérification anti-cycle (modification uniquement)
  if ($id > 0 && $parent_sql !== null):
    $arbre = chargerArbreRegles($db, $ruleset_id, true);
    if (!reglesValiderParent($arbre, $id, (int)$parent_sql)):
      _repondreErreur($is_ajax, 'Le parent choisi crée un cycle dans l\'arbre.');
    endif;
  endif;

  // Génération / vérification du slug
  $slug_input = strParam($_POST['reg_slug'] ?? '');
  if ($slug_input === ''):
    $slug = reglesGenererSlug($db, $nom, $ruleset_id, $id);
  else:
    // Slug saisi manuellement : unicité obligatoire
    $stmt = $db->prepare('
      SELECT COUNT(*) FROM dd_regles
      WHERE  reg_slug = ? AND reg_ruleset_var_id = ? AND reg_id != ?
    ');
    $stmt->execute([$slug_input, $ruleset_id, $id]);
    if ((int)$stmt->fetchColumn() > 0):
      _repondreErreur($is_ajax, 'Ce slug est déjà utilisé pour ce ruleset.');
    endif;
    $slug = $slug_input;
  endif;

  try {
    $db->beginTransaction();

    if ($id === 0):
      // INSERT
      $stmt = $db->prepare('
        INSERT INTO dd_regles
          (reg_reg_id, reg_type, reg_nom, reg_slug, reg_texte, reg_ordre,
           reg_ruleset_var_id, reg_visible, reg_date_creation, reg_date_modif)
        VALUES (?,?,?,?,?,?,?,?,NOW(),NOW())
      ');
      $stmt->execute([
        $parent_sql, $type, $nom, $slug, $texte ?: null, $ordre, $ruleset_id, $visible,
      ]);
      $id = (int)$db->lastInsertId();
    else:
      // UPDATE
      $stmt = $db->prepare('
        UPDATE dd_regles
        SET    reg_reg_id  = ?,
               reg_type    = ?,
               reg_nom     = ?,
               reg_slug    = ?,
               reg_texte   = ?,
               reg_ordre   = ?,
               reg_visible = ?,
               reg_date_modif = NOW()
        WHERE  reg_id = ?
          AND  reg_ruleset_var_id = ?
      ');
      $stmt->execute([
        $parent_sql, $type, $nom, $slug, $texte ?: null, $ordre, $visible, $id, $ruleset_id,
      ]);
    endif;

    $db->commit();
  } catch (PDOException $e) {
    $db->rollBack();
    error_log('Règle sauvegarder : ' . $e->getMessage());
    _repondreErreur($is_ajax, 'Erreur lors de l\'enregistrement.');
  }

  $redirect_final = BASE_URL . '/regles/regle.php?id=' . $id;
  _repondreOk($is_ajax, $id, $redirect_final);
}

// ============================================================
// Supprimer
// ============================================================

function _supprimer(PDO $db, bool $is_ajax, string $redirect): void
{
  $id         = intParam($_POST['reg_id']    ?? 0);
  $ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);

  if (!$id):
    _repondreErreur($is_ajax, 'Identifiant manquant.');
  endif;

  // Vérifie que le nœud existe et appartient au ruleset
  $stmt = $db->prepare('SELECT reg_id FROM dd_regles WHERE reg_id = ? AND reg_ruleset_var_id = ?');
  $stmt->execute([$id, $ruleset_id]);
  if (!$stmt->fetch()):
    _repondreErreur($is_ajax, 'Nœud introuvable.');
  endif;

  // Refuse si des enfants existent (pas de suppression en cascade silencieuse)
  $stmt = $db->prepare('SELECT COUNT(*) FROM dd_regles WHERE reg_reg_id = ?');
  $stmt->execute([$id]);
  $nb_enfants = (int)$stmt->fetchColumn();
  if ($nb_enfants > 0):
    _repondreErreur($is_ajax,
      'Ce nœud contient ' . $nb_enfants . ' sous-élément' . ($nb_enfants > 1 ? 's' : '') . '. '
      . 'Déplacez-les ou supprimez-les d\'abord.'
    );
  endif;

  try {
    $stmt = $db->prepare('DELETE FROM dd_regles WHERE reg_id = ? AND reg_ruleset_var_id = ?');
    $stmt->execute([$id, $ruleset_id]);
  } catch (PDOException $e) {
    error_log('Règle supprimer : ' . $e->getMessage());
    _repondreErreur($is_ajax, 'Erreur lors de la suppression.');
  }

  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode(['ok' => true, 'id' => $id]);
    exit;
  endif;
  $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Nœud supprimé.'];
  header('Location: ' . $redirect);
  exit;
}

// ============================================================
// Réordonner (drag & drop)
// ============================================================
// POST : ordre_json = [{"id":12,"parent":5,"ordre":0}, …]

function _reordonner(PDO $db, bool $is_ajax): void
{
  $json       = strParam($_POST['ordre_json'] ?? '');
  $ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);

  if ($json === ''):
    _repondreErreur(true, 'Données manquantes.');
  endif;

  $items = json_decode($json, true);
  if (!is_array($items)):
    _repondreErreur(true, 'JSON invalide.');
  endif;

  // Validation anti-cycle globale : on construit un arbre provisoire et on le vérifie
  $arbre = chargerArbreRegles($db, $ruleset_id, true);
  foreach ($items as $item):
    $nid     = (int)($item['id']     ?? 0);
    $new_par = (int)($item['parent'] ?? 0);
    if (!$nid) continue;
    if ($new_par > 0 && !reglesValiderParent($arbre, $nid, $new_par)):
      _repondreErreur(true, 'Réordonnancement invalide : cycle détecté sur le nœud ' . $nid . '.');
    endif;
  endforeach;

  try {
    $db->beginTransaction();
    $stmt = $db->prepare('
      UPDATE dd_regles
      SET    reg_reg_id  = ?,
             reg_ordre   = ?,
             reg_date_modif = NOW()
      WHERE  reg_id = ? AND reg_ruleset_var_id = ?
    ');
    foreach ($items as $item):
      $nid     = (int)($item['id']     ?? 0);
      $new_par = (int)($item['parent'] ?? 0);
      $ordre   = (int)($item['ordre']  ?? 0);
      if (!$nid) continue;
      $stmt->execute([$new_par > 0 ? $new_par : null, $ordre, $nid, $ruleset_id]);
    endforeach;
    $db->commit();
  } catch (PDOException $e) {
    $db->rollBack();
    error_log('Règle réordonner : ' . $e->getMessage());
    _repondreErreur(true, 'Erreur lors du réordonnancement.');
  }

  header('Content-Type: application/json');
  echo json_encode(['ok' => true]);
  exit;
}
