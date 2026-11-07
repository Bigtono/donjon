<?php
// admin/enregistrement.php — Point d'entrée unique pour toutes les écritures admin
//
// GET ajax=1 → retourne JSON {ok, id, url_detail, erreur}
// Sinon      → redirige avec flash message SESSION
//
// POST requis :
//   entite  — 'utilisateur' | 'ressource' | 'categorie-note' (SP-NO6)
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

  case 'categorie-note':
    switch ($action):
      case 'sauvegarder':
        sauvegarderCategorieNote($db, $is_ajax, $redirect);
        break;
      case 'supprimer':
        supprimerCategorieNote($db, $is_ajax, $redirect);
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

  // Changement de mot de passe (modification uniquement) — champs vides = inchangé
  $hash_nouveau  = null;
  $pass_nouveau  = $_POST['j_pass_nouveau']  ?? '';
  $pass_confirme = $_POST['j_pass_confirme'] ?? '';
  if ($j_id > 0 && ($pass_nouveau !== '' || $pass_confirme !== '')):
    if (strlen($pass_nouveau) < 8):
      adminErreur($is_ajax, 'Le mot de passe doit contenir au moins 8 caractères.', $redirect);
    endif;
    if ($pass_nouveau !== $pass_confirme):
      adminErreur($is_ajax, 'Les deux mots de passe ne correspondent pas.', $redirect);
    endif;
    $hash_nouveau = password_hash($pass_nouveau, PASSWORD_DEFAULT);
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
      $sql = '
        UPDATE dd_joueurs SET
          j_prenom              = ?,
          j_nom                 = ?,
          j_pseudo              = ?,
          j_email               = ?,
          j_admin               = ?,
          j_compendium_manager  = ?,
          j_mode_campagne       = ?,
          j_items_par_page      = ?,
          j_notes               = ?';
      $params = [
        $prenom, $nom, $pseudo, $email,
        $j_admin, $j_compendium_manager, $j_mode_campagne, $j_items_par_page, $j_notes,
      ];

      if ($hash_nouveau !== null):
        // Un lien de réinitialisation en attente devient caduc
        $sql      .= ', j_password_hash = ?, j_reset_token = NULL, j_reset_token_expires = NULL';
        $params[]  = $hash_nouveau;
      endif;

      $sql     .= ' WHERE j_id = ?';
      $params[] = $j_id;

      $stmt = $db->prepare($sql);
      $stmt->execute($params);
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
           res_editeur, res_description)
        VALUES (?,?,?,?,?,?)
      ');
      $stmt->execute([
        $nom, $abreviation, $ruleset_id, $selection,
        $editeur, $description,
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
          res_description      = ?
        WHERE res_id = ?
      ');
      $stmt->execute([
        $nom, $abreviation, $ruleset_id, $selection,
        $editeur, $description,
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

  // Refus dès qu'une ressource porte du contenu (contenuRessourceTables())
  foreach ($ids as $res_id):
    try {
      $detail_erreur = decrireContenuRessource(compterContenuRessource($db, $res_id));
    } catch (Exception $e) {
      error_log('supprimerRessource : ' . $e->getMessage());
      adminErreur($is_ajax, 'Erreur lors de la vérification du contenu : suppression annulée.', $redirect);
    }
    if ($detail_erreur !== ''):
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

// ============================================================
// CATÉGORIE DE NOTES — Sauvegarde (SP-NO6)
// Nom unique par ruleset ; ruleset figé dès qu'une note (même supprimée)
// emploie la catégorie : la note doit garder le ruleset de sa campagne.
// ============================================================

function sauvegarderCategorieNote($db, bool $is_ajax, string $redirect): void
{
  $tyno_id    = intParam($_POST['tyno_id'] ?? 0);
  $nom        = trim(strParam($_POST['tyno_nom'] ?? ''));
  $ruleset_id = intParam($_POST['tyno_ruleset_var_id'] ?? 0);
  $ordre_brut = trim((string)($_POST['tyno_ordre'] ?? ''));

  if ($nom === ''):
    adminErreur($is_ajax, 'Le nom de la catégorie est obligatoire.', $redirect);
  endif;
  if (mb_strlen($nom) > 80):
    adminErreur($is_ajax, 'Le nom ne doit pas dépasser 80 caractères.', $redirect);
  endif;

  $stmt = $db->prepare("SELECT var_id FROM dd_variables WHERE var_id = ? AND var_cat = 'ruleset'");
  $stmt->execute([$ruleset_id]);
  if (!$stmt->fetch()):
    adminErreur($is_ajax, 'Ruleset invalide.', $redirect);
  endif;

  if ($tyno_id > 0):
    $stmt = $db->prepare('SELECT tyno_ruleset_var_id FROM dd_types_notes WHERE tyno_id = ?');
    $stmt->execute([$tyno_id]);
    $actuel = $stmt->fetchColumn();
    if ($actuel === false):
      adminErreur($is_ajax, 'Catégorie introuvable.', $redirect);
    endif;
    if ((int)$actuel !== $ruleset_id):
      $stmt = $db->prepare('SELECT COUNT(*) FROM dd_notes WHERE no_tyno_id = ?');
      $stmt->execute([$tyno_id]);
      if ((int)$stmt->fetchColumn() > 0):
        adminErreur($is_ajax, 'Des notes emploient cette catégorie : son ruleset ne peut plus changer.', $redirect);
      endif;
    endif;
  endif;

  $stmt = $db->prepare('SELECT COUNT(*) FROM dd_types_notes WHERE tyno_ruleset_var_id = ? AND tyno_nom = ? AND tyno_id <> ?');
  $stmt->execute([$ruleset_id, $nom, $tyno_id]);
  if ((int)$stmt->fetchColumn() > 0):
    adminErreur($is_ajax, 'Une catégorie de ce nom existe déjà pour ce ruleset.', $redirect);
  endif;

  // Ordre vide : à la suite des catégories du ruleset
  if ($ordre_brut === ''):
    $stmt = $db->prepare('SELECT COALESCE(MAX(tyno_ordre), 0) + 10 FROM dd_types_notes WHERE tyno_ruleset_var_id = ? AND tyno_id <> ?');
    $stmt->execute([$ruleset_id, $tyno_id]);
    $ordre = (int)$stmt->fetchColumn();
  else:
    $ordre = max(0, min(65535, (int)$ordre_brut));
  endif;

  try {
    if ($tyno_id === 0):
      $db->prepare('INSERT INTO dd_types_notes (tyno_nom, tyno_ruleset_var_id, tyno_ordre) VALUES (?, ?, ?)')
         ->execute([$nom, $ruleset_id, $ordre]);
      $tyno_id = (int)$db->lastInsertId();
    else:
      $db->prepare('UPDATE dd_types_notes SET tyno_nom = ?, tyno_ruleset_var_id = ?, tyno_ordre = ? WHERE tyno_id = ?')
         ->execute([$nom, $ruleset_id, $ordre, $tyno_id]);
    endif;
    adminOk($is_ajax, $tyno_id, 'categorie-note', $redirect);
  } catch (Exception $e) {
    error_log('sauvegarderCategorieNote : ' . $e->getMessage());
    adminErreur($is_ajax, 'Erreur base de données.', $redirect);
  }
}

// ============================================================
// CATÉGORIE DE NOTES — Suppression : refusée si une note l'emploie,
// y compris une note supprimée (no_tyno_id est NOT NULL).
// ============================================================

function supprimerCategorieNote($db, bool $is_ajax, string $redirect): void
{
  $ids = $_POST['ids'] ?? [];
  if (!empty($_POST['id'])) $ids[] = $_POST['id'];
  $ids = array_filter(array_map('intval', (array)$ids));

  if (empty($ids)):
    adminErreur($is_ajax, 'Aucune catégorie sélectionnée.', $redirect);
  endif;

  $stmt = $db->prepare('SELECT COUNT(*) FROM dd_notes WHERE no_tyno_id = ?');
  foreach ($ids as $tyno_id):
    $stmt->execute([$tyno_id]);
    $nb = (int)$stmt->fetchColumn();
    if ($nb > 0):
      adminErreur($is_ajax, 'Impossible de supprimer : ' . $nb . ' note' . ($nb > 1 ? 's emploient' : ' emploie')
        . ' cette catégorie. Changez-leur de catégorie d\'abord.', $redirect);
    endif;
  endforeach;

  $del = $db->prepare('DELETE FROM dd_types_notes WHERE tyno_id = ?');
  foreach ($ids as $tyno_id) $del->execute([$tyno_id]);

  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode(['ok' => true, 'id' => 0, 'url_detail' => '']);
    exit;
  endif;
  $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Catégorie(s) supprimée(s).'];
  header('Location: ' . $redirect);
  exit;
}
