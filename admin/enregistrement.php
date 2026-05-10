<?php
// admin/enregistrement.php — Point d'entrée unique pour toutes les écritures admin
//
// GET ajax=1 → retourne JSON {ok, id, url_detail, erreur}
// Sinon      → redirige avec flash message SESSION
//
// POST requis :
//   entite  — 'utilisateur' | 'ressource'
//   action  — voir chaque entité ci-dessous

require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAdmin();
verifyCsrf();

$is_ajax = isset($_GET['ajax']);
$entite  = strParam($_POST['entite'] ?? '');
$action  = strParam($_POST['action'] ?? '');

// ============================================================
// Helpers de réponse
// ============================================================

function adminOk(bool $is_ajax, int $id, string $entite, string $redirect): void
{
  $url_detail = BASE_URL . '/include/ajax/detail-pp/' . $entite . '.php';
  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode(['ok' => true, 'id' => $id, 'url_detail' => $url_detail]);
    exit;
  endif;
  $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Modification enregistrée.'];
  header('Location: ' . $redirect);
  exit;
}

function adminErreur(bool $is_ajax, string $message, string $redirect): void
{
  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode(['ok' => false, 'erreur' => $message]);
    exit;
  endif;
  $_SESSION['flash_message'] = ['type' => 'error', 'text' => $message];
  header('Location: ' . $redirect);
  exit;
}

$redirect = $_SERVER['HTTP_REFERER'] ?? BASE_URL . '/admin/' . $entite . 's.php';

// ============================================================
// Dispatch
// ============================================================

switch ($entite):

  case 'utilisateur':
    switch ($action):
      case 'sauvegarder':
        sauvegarderUtilisateur($db, $is_ajax, $redirect);
        break;
      case 'desactiver':
        changerVisibiliteUtilisateur($db, $is_ajax, $redirect, 0);
        break;
      case 'reactiver':
        changerVisibiliteUtilisateur($db, $is_ajax, $redirect, 1);
        break;
      case 'bulk_desactiver':
        bulkDesactiverUtilisateurs($db, $redirect);
        break;
      default:
        adminErreur($is_ajax, 'Action inconnue.', $redirect);
    endswitch;
    break;

  case 'ressource':
    switch ($action):
      case 'sauvegarder':
        sauvegarderRessource($db, $is_ajax, $redirect);
        break;
      case 'supprimer':
        supprimerRessource($db, $is_ajax, $redirect);
        break;
      default:
        adminErreur($is_ajax, 'Action inconnue.', $redirect);
    endswitch;
    break;

  default:
    adminErreur($is_ajax, 'Entité inconnue.', $redirect);

endswitch;

// ============================================================
// UTILISATEUR — Sauvegarde (création ou modification)
// ============================================================

function sauvegarderUtilisateur($db, bool $is_ajax, string $redirect): void
{
  $j_id    = intParam($_POST['j_id'] ?? 0);
  $prenom  = strParam($_POST['j_prenom']  ?? '');
  $nom     = strParam($_POST['j_nom']     ?? '');
  $pseudo  = strParam($_POST['j_pseudo']  ?? '');
  $email   = strParam($_POST['j_email']   ?? '');

  // Validation
  if (!$pseudo || !$email):
    adminErreur($is_ajax, 'Le pseudo et l\'email sont obligatoires.', $redirect);
  endif;
  if (!filter_var($email, FILTER_VALIDATE_EMAIL)):
    adminErreur($is_ajax, 'L\'adresse email est invalide.', $redirect);
  endif;

  // Unicité pseudo
  $stmt = $db->prepare(
    'SELECT j_id FROM dd_joueurs WHERE j_pseudo = ? AND j_id != ?'
  );
  $stmt->execute([$pseudo, $j_id]);
  if ($stmt->fetch()):
    adminErreur($is_ajax, 'Ce pseudo est déjà utilisé.', $redirect);
  endif;

  // Unicité email
  $stmt = $db->prepare(
    'SELECT j_id FROM dd_joueurs WHERE j_email = ? AND j_id != ?'
  );
  $stmt->execute([$email, $j_id]);
  if ($stmt->fetch()):
    adminErreur($is_ajax, 'Cet email est déjà utilisé.', $redirect);
  endif;

  $j_admin              = isset($_POST['j_admin'])              ? 1 : 0;
  $j_compendium_manager = isset($_POST['j_compendium_manager']) ? 1 : 0;
  $j_mode_campagne      = isset($_POST['j_mode_campagne'])      ? 1 : 0;
  $j_items_par_page     = intParam($_POST['j_items_par_page']   ?? 20);
  $j_notes              = strParam($_POST['j_notes']            ?? '');

  // Tailles de page autorisées
  $items_valides = [10, 20, 50, 100];
  if (!in_array($j_items_par_page, $items_valides)):
    $j_items_par_page = 20;
  endif;

  try {
    $db->beginTransaction();

    if ($j_id === 0):
      // ---- CRÉATION ----
      $password = strParam($_POST['j_password'] ?? '');
      if (!$password):
        adminErreur($is_ajax, 'Le mot de passe est obligatoire à la création.', $redirect);
      endif;
      if (strlen($password) < 8):
        adminErreur($is_ajax, 'Le mot de passe doit contenir au moins 8 caractères.', $redirect);
      endif;
      $hash = password_hash($password, PASSWORD_DEFAULT);

      $stmt = $db->prepare('
        INSERT INTO dd_joueurs
          (j_prenom, j_nom, j_pseudo, j_email, j_password_hash,
           j_admin, j_compendium_manager, j_mode_campagne, j_items_par_page, j_notes,
           j_visible, j_date_inscription)
        VALUES (?,?,?,?,?,?,?,?,?,?,1,NOW())
      ');
      $stmt->execute([
        $prenom, $nom, $pseudo, $email, $hash,
        $j_admin, $j_compendium_manager, $j_mode_campagne, $j_items_par_page, $j_notes,
      ]);
      $j_id = (int)$db->lastInsertId();

    else:
      // ---- MODIFICATION ----
      $stmt = $db->prepare('
        UPDATE dd_joueurs SET
          j_prenom              = ?,
          j_nom                 = ?,
          j_pseudo              = ?,
          j_email               = ?,
          j_admin               = ?,
          j_compendium_manager  = ?,
          j_mode_campagne       = ?,
          j_items_par_page      = ?,
          j_notes               = ?
        WHERE j_id = ?
      ');
      $stmt->execute([
        $prenom, $nom, $pseudo, $email,
        $j_admin, $j_compendium_manager, $j_mode_campagne, $j_items_par_page, $j_notes,
        $j_id,
      ]);
    endif;

    $db->commit();
    adminOk($is_ajax, $j_id, 'utilisateur', $redirect);
  } catch (Exception $e) {
    $db->rollBack();
    error_log('sauvegarderUtilisateur : ' . $e->getMessage());
    adminErreur($is_ajax, 'Erreur base de données.', $redirect);
  }
}

// ============================================================
// UTILISATEUR — Changement de visibilité (désactiver / réactiver)
// ============================================================

function changerVisibiliteUtilisateur($db, bool $is_ajax, string $redirect, int $visible): void
{
  $ids = $_POST['ids'] ?? [];
  if (!empty($_POST['id'])) $ids[] = $_POST['id'];
  $ids = array_filter(array_map('intval', (array)$ids));

  if (empty($ids)):
    adminErreur($is_ajax, 'Aucun utilisateur sélectionné.', $redirect);
  endif;

  // Empêcher l'admin de se désactiver lui-même
  $j_id_session = (int)($_SESSION['j_id'] ?? 0);
  if ($visible === 0 && in_array($j_id_session, $ids)):
    adminErreur($is_ajax, 'Vous ne pouvez pas désactiver votre propre compte.', $redirect);
  endif;

  try {
    $ph   = implode(',', array_fill(0, count($ids), '?'));
    $stmt = $db->prepare(
      "UPDATE dd_joueurs SET j_visible = ? WHERE j_id IN ($ph)"
    );
    $stmt->execute(array_merge([$visible], $ids));

    $texte = $visible === 1 ? 'Utilisateur(s) réactivé(s).' : 'Utilisateur(s) désactivé(s).';
    if ($is_ajax):
      header('Content-Type: application/json');
      echo json_encode(['ok' => true, 'id' => $ids[0], 'url_detail' => '']);
      exit;
    endif;
    $_SESSION['flash_message'] = ['type' => 'success', 'text' => $texte];
    header('Location: ' . $redirect);
    exit;
  } catch (Exception $e) {
    error_log('changerVisibiliteUtilisateur : ' . $e->getMessage());
    adminErreur($is_ajax, 'Erreur base de données.', $redirect);
  }
}

// ============================================================
// UTILISATEUR — Désactivation groupée (bulk)
// ============================================================

function bulkDesactiverUtilisateurs($db, string $redirect): void
{
  changerVisibiliteUtilisateur($db, false, $redirect, 0);
}

// ============================================================
// RESSOURCE — Sauvegarde (création ou modification)
// ============================================================

function sauvegarderRessource($db, bool $is_ajax, string $redirect): void
{
  $res_id        = intParam($_POST['res_id']             ?? 0);
  $nom           = strParam($_POST['res_nom']            ?? '');
  $abreviation   = strParam($_POST['res_abreviation']    ?? '');
  $ruleset_id    = intParam($_POST['res_ruleset_var_id'] ?? 0);
  $selection     = isset($_POST['res_selection'])   ? 1 : 0;
  $editeur       = strParam($_POST['res_editeur']        ?? '');
  $pages         = intParam($_POST['res_pages']          ?? 0);
  $description   = $_POST['res_description'] ?? ''; // HTML TinyMCE

  if (!$nom):
    adminErreur($is_ajax, 'Le nom de la ressource est obligatoire.', $redirect);
  endif;
  if (!$abreviation):
    adminErreur($is_ajax, 'L\'abréviation est obligatoire.', $redirect);
  endif;
  if (!$ruleset_id):
    adminErreur($is_ajax, 'Le ruleset est obligatoire.', $redirect);
  endif;

  // Vérification du ruleset
  $stmt = $db->prepare(
    "SELECT var_id FROM dd_variables WHERE var_id = ? AND var_cat = 'ruleset'"
  );
  $stmt->execute([$ruleset_id]);
  if (!$stmt->fetch()):
    adminErreur($is_ajax, 'Ruleset invalide.', $redirect);
  endif;

  try {
    $db->beginTransaction();

    if ($res_id === 0):
      $stmt = $db->prepare('
        INSERT INTO dd_ressources
          (res_nom, res_abreviation, res_ruleset_var_id, res_selection,
           res_editeur, res_pages, res_description)
        VALUES (?,?,?,?,?,?,?)
      ');
      $stmt->execute([
        $nom, $abreviation, $ruleset_id, $selection,
        $editeur, $pages ?: null, $description,
      ]);
      $res_id = (int)$db->lastInsertId();

    else:
      $stmt = $db->prepare('
        UPDATE dd_ressources SET
          res_nom              = ?,
          res_abreviation      = ?,
          res_ruleset_var_id   = ?,
          res_selection        = ?,
          res_editeur          = ?,
          res_pages            = ?,
          res_description      = ?
        WHERE res_id = ?
      ');
      $stmt->execute([
        $nom, $abreviation, $ruleset_id, $selection,
        $editeur, $pages ?: null, $description,
        $res_id,
      ]);
    endif;

    $db->commit();
    adminOk($is_ajax, $res_id, 'ressource', $redirect);
  } catch (Exception $e) {
    $db->rollBack();
    error_log('sauvegarderRessource : ' . $e->getMessage());
    adminErreur($is_ajax, 'Erreur base de données.', $redirect);
  }
}

// ============================================================
// RESSOURCE — Suppression (avec vérification de dépendances)
// ============================================================

function supprimerRessource($db, bool $is_ajax, string $redirect): void
{
  $ids = $_POST['ids'] ?? [];
  if (!empty($_POST['id'])) $ids[] = $_POST['id'];
  $ids = array_filter(array_map('intval', (array)$ids));

  if (empty($ids)):
    adminErreur($is_ajax, 'Aucune ressource sélectionnée.', $redirect);
  endif;

  // Vérification des dépendances pour chaque ressource
  // Périmètre complet du compendium (7 tables)
  $tables_compendium = [
    ['table' => 'dd_classes',        'champ' => 'cla_res_id', 'label' => 'classes',        'camp' => 'cla_camp_id'],
    ['table' => 'dd_races',          'champ' => 'ra_res_id',  'label' => 'races',           'camp' => null],
    ['table' => 'dd_sorts',          'champ' => 'so_res_id',  'label' => 'sorts',           'camp' => 'so_camp_id'],
    ['table' => 'dd_dons',           'champ' => 'do_res_id',  'label' => 'dons',            'camp' => 'do_camp_id'],
    ['table' => 'dd_competences',    'champ' => 'comp_res_id','label' => 'compétences',     'camp' => null],
    ['table' => 'dd_historiques',    'champ' => 'hi_res_id',  'label' => 'historiques',     'camp' => null],
    ['table' => 'dd_objets_magiques','champ' => 'om_res_id',  'label' => 'objets magiques', 'camp' => null],
  ];

  foreach ($ids as $res_id):
    $detail_erreur = verifierDependancesRessource($db, $res_id, $tables_compendium);
    if ($detail_erreur):
      adminErreur(
        $is_ajax,
        'Impossible de supprimer : cette ressource contient ' . $detail_erreur
          . '. Supprimez d\'abord le contenu associé.',
        $redirect
      );
    endif;
  endforeach;

  // Toutes les ressources sont libres — suppression
  try {
    $db->beginTransaction();
    foreach ($ids as $res_id):
      // Nettoyage des sélections utilisateurs et campagnes
      $db->prepare('DELETE FROM dd_joueurs_sources   WHERE js_res_id  = ?')->execute([$res_id]);
      $db->prepare('DELETE FROM dd_campagnes_sources WHERE cs_res_id  = ?')->execute([$res_id]);
      $db->prepare('DELETE FROM dd_ressources        WHERE res_id     = ?')->execute([$res_id]);
    endforeach;
    $db->commit();

    if ($is_ajax):
      header('Content-Type: application/json');
      echo json_encode(['ok' => true, 'id' => 0, 'url_detail' => '']);
      exit;
    endif;
    $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Ressource(s) supprimée(s).'];
    header('Location: ' . $redirect);
    exit;
  } catch (Exception $e) {
    $db->rollBack();
    error_log('supprimerRessource : ' . $e->getMessage());
    adminErreur($is_ajax, 'Erreur lors de la suppression.', $redirect);
  }
}

// Retourne null si aucune dépendance, sinon un texte descriptif des compteurs
function verifierDependancesRessource($db, int $res_id, array $tables): ?string
{
  $compteurs = [];
  foreach ($tables as $t):
    $cond = 'WHERE ' . $t['champ'] . ' = ?';
    if ($t['camp']):
      $cond .= ' AND ' . $t['camp'] . ' IS NULL'; // compendium global uniquement
    endif;
    try {
      $stmt = $db->prepare('SELECT COUNT(*) FROM ' . $t['table'] . ' ' . $cond);
      $stmt->execute([$res_id]);
      $nb = (int)$stmt->fetchColumn();
      if ($nb > 0):
        $compteurs[] = $nb . ' ' . $t['label'];
      endif;
    } catch (Exception $e) {
      // Table absente (ex: dd_historiques non encore créée) — on passe
      error_log('verifierDependancesRessource — table manquante: ' . $t['table']);
    }
  endforeach;

  return empty($compteurs) ? null : implode(', ', $compteurs);
}
