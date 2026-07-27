<?php
// regles/tableaux-enregistrement.php — Écriture des tableaux de règles (SP-TB3)
//
// Accès : canEditCompendium() uniquement (admin + gestionnaire compendium)
// CSRF  : vérifié systématiquement
//
// POST requis :
//   action — 'sauvegarder' | 'supprimer'
//
// GET ajax=1 → JSON {ok, id, erreur}
// Sinon      → redirect avec flash message
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9c

require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';
require_once '../include/tableau-parser.php';

requireAuth();
verifyCsrf();

if (!canEditCompendium()):
  _tabRepondreErreur(true, 'Accès refusé.');
endif;

$is_ajax  = isset($_GET['ajax']);
$action   = strParam($_POST['action'] ?? '');
$redirect = BASE_URL . '/regles/tableaux.php';

switch ($action):
  case 'sauvegarder':
    _tabSauvegarder($db, $is_ajax, $redirect);
    break;
  case 'supprimer':
    _tabSupprimer($db, $is_ajax, $redirect);
    break;
  default:
    _tabRepondreErreur($is_ajax, 'Action inconnue : ' . h($action), $redirect);
endswitch;

// ============================================================
// Helpers réponse
// ============================================================

function _tabRepondreOk(bool $is_ajax, int $id, string $slug, string $redirect): void
{
  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode([
      'ok'         => true,
      'id'         => $id,
      'slug'       => $slug,
      'url_detail' => BASE_URL . '/include/ajax/detail-pp/tableau.php',
    ]);
    exit;
  endif;
  $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Tableau enregistré.'];
  header('Location: ' . $redirect);
  exit;
}

function _tabRepondreErreur(bool $is_ajax, string $message, string $redirect = ''): void
{
  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode(['ok' => false, 'erreur' => $message]);
    exit;
  endif;
  $_SESSION['flash_message'] = ['type' => 'error', 'text' => $message];
  header('Location: ' . ($redirect ?: BASE_URL . '/regles/tableaux.php'));
  exit;
}

// ============================================================
// Sauvegarder (INSERT ou UPDATE)
// ============================================================

function _tabSauvegarder(PDO $db, bool $is_ajax, string $redirect): void
{
  $id          = intParam($_POST['tab_id']          ?? 0);
  $nom         = strParam($_POST['tab_nom']         ?? '');
  $contenu     = (string)($_POST['tab_contenu']     ?? '');
  $align       = strParam($_POST['tab_align']       ?? '');
  $note        = strParam($_POST['tab_note']        ?? '');
  $res_id      = intParam($_POST['tab_res_id']      ?? 0);
  $ecran_mj    = intParam($_POST['tab_ecran_mj']    ?? 0) ? 1 : 0;
  $ecran_ordre = intParam($_POST['tab_ecran_ordre'] ?? 0);
  $visible     = intParam($_POST['tab_visible']     ?? 1) ? 1 : 0;
  $ruleset_id  = (int)($_SESSION['ruleset_var_id'] ?? 1);

  if ($nom === ''):
    _tabRepondreErreur($is_ajax, 'Le nom est obligatoire.');
  endif;
  if (trim($contenu) === ''):
    _tabRepondreErreur($is_ajax, 'Le contenu est obligatoire.');
  endif;

  // Alignement : on ne conserve que les lettres l/c/r
  $align = preg_replace('/[^lcr]/i', '', strtolower($align));

  // ---- Slug ----
  $slug_input = strParam($_POST['tab_slug'] ?? '');
  $slug_avant = '';
  if ($id > 0):
    $stmt = $db->prepare('SELECT tab_slug FROM dd_tableaux WHERE tab_id = ? AND tab_ruleset_var_id = ?');
    $stmt->execute([$id, $ruleset_id]);
    $slug_avant = (string)$stmt->fetchColumn();
    if ($slug_avant === ''):
      _tabRepondreErreur($is_ajax, 'Tableau introuvable pour ce ruleset.');
    endif;
  endif;

  if ($slug_input === ''):
    $slug = tableauGenererSlug($db, $nom, $ruleset_id, $id);
  else:
    $slug = _tabSlugify($slug_input);
    $stmt = $db->prepare('
      SELECT COUNT(*) FROM dd_tableaux
      WHERE  tab_slug = ? AND tab_ruleset_var_id = ? AND tab_id != ?
    ');
    $stmt->execute([$slug, $ruleset_id, $id]);
    if ((int)$stmt->fetchColumn() > 0):
      _tabRepondreErreur($is_ajax, 'Ce slug est déjà utilisé pour ce ruleset : ' . h($slug));
    endif;
  endif;

  try {
    $db->beginTransaction();

    if ($id === 0):
      $stmt = $db->prepare('
        INSERT INTO dd_tableaux
          (tab_slug, tab_nom, tab_contenu, tab_align, tab_note, tab_ruleset_var_id,
           tab_res_id, tab_ecran_mj, tab_ecran_ordre, tab_visible,
           tab_date_creation, tab_date_modif)
        VALUES (?,?,?,?,?,?,?,?,?,?,NOW(),NOW())
      ');
      $stmt->execute([
        $slug, $nom, $contenu, $align ?: null, $note ?: null, $ruleset_id,
        $res_id ?: null, $ecran_mj, $ecran_ordre, $visible,
      ]);
      $id = (int)$db->lastInsertId();
    else:
      $stmt = $db->prepare('
        UPDATE dd_tableaux
        SET    tab_slug        = ?,
               tab_nom         = ?,
               tab_contenu     = ?,
               tab_align       = ?,
               tab_note        = ?,
               tab_res_id      = ?,
               tab_ecran_mj    = ?,
               tab_ecran_ordre = ?,
               tab_visible     = ?,
               tab_date_modif  = NOW()
        WHERE  tab_id = ? AND tab_ruleset_var_id = ?
      ');
      $stmt->execute([
        $slug, $nom, $contenu, $align ?: null, $note ?: null,
        $res_id ?: null, $ecran_mj, $ecran_ordre, $visible, $id, $ruleset_id,
      ]);

      // Renommage du slug : on répercute le tag dans les textes hôtes, sinon
      // toutes les insertions existantes deviendraient silencieusement
      // irrésolubles (elles s'afficheraient en .reg-tab__manquant).
      if ($slug_avant !== '' && $slug_avant !== $slug):
        _tabPropagerSlug($db, $slug_avant, $slug, $ruleset_id);
      endif;
    endif;

    $db->commit();
  } catch (PDOException $e) {
    $db->rollBack();
    error_log('Tableau sauvegarder : ' . $e->getMessage());
    _tabRepondreErreur($is_ajax, 'Erreur lors de l\'enregistrement.');
  }

  _tabRepondreOk($is_ajax, $id, $slug, $redirect);
}

// Répercute un renommage de slug sur tous les textes hôtes du ruleset.
// Portée actuelle : reg_texte (SP-TB2) et mo_stats (SP-TB6). À étendre en
// même temps que la portée du tag (SP-TB7).
function _tabPropagerSlug(PDO $db, string $avant, string $apres, int $ruleset_id): void
{
  $tag_avant = '[[tab:' . $avant . ']]';
  $tag_apres = '[[tab:' . $apres . ']]';

  $stmt = $db->prepare('
    UPDATE dd_regles
    SET    reg_texte = REPLACE(reg_texte, ?, ?), reg_date_modif = NOW()
    WHERE  reg_ruleset_var_id = ? AND reg_texte LIKE ?
  ');
  $stmt->execute([$tag_avant, $tag_apres, $ruleset_id, '%' . $tag_avant . '%']);

  $stmt = $db->prepare('
    UPDATE dd_monstres
    SET    mo_stats = REPLACE(mo_stats, ?, ?)
    WHERE  mo_ruleset_var_id = ? AND mo_stats LIKE ?
  ');
  $stmt->execute([$tag_avant, $tag_apres, $ruleset_id, '%' . $tag_avant . '%']);
}

// ============================================================
// Supprimer
// ============================================================

function _tabSupprimer(PDO $db, bool $is_ajax, string $redirect): void
{
  $id         = intParam($_POST['tab_id'] ?? 0);
  $ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);

  if (!$id):
    _tabRepondreErreur($is_ajax, 'Identifiant manquant.');
  endif;

  $stmt = $db->prepare('SELECT tab_slug FROM dd_tableaux WHERE tab_id = ? AND tab_ruleset_var_id = ?');
  $stmt->execute([$id, $ruleset_id]);
  $slug = $stmt->fetchColumn();
  if ($slug === false):
    _tabRepondreErreur($is_ajax, 'Tableau introuvable.');
  endif;

  try {
    $stmt = $db->prepare('DELETE FROM dd_tableaux WHERE tab_id = ? AND tab_ruleset_var_id = ?');
    $stmt->execute([$id, $ruleset_id]);
  } catch (PDOException $e) {
    error_log('Tableau supprimer : ' . $e->getMessage());
    _tabRepondreErreur($is_ajax, 'Erreur lors de la suppression.');
  }

  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode(['ok' => true, 'id' => $id]);
    exit;
  endif;
  $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Tableau supprimé.'];
  header('Location: ' . $redirect);
  exit;
}
