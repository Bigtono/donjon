<?php
// compendium/enregistrement.php
// Point d'entrée unique pour toutes les écritures du compendium
//
// GET ajax=1 → retourne JSON {ok, id, url_detail, erreur}
// Sinon      → redirige avec flash message SESSION
//
// POST requis :
//   entite  — 'sort' | 'classe' | 'don' | 'race' | ...
//   action  — 'sauvegarder' | 'supprimer' | 'bulk_supprimer' | ...

require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAuth();
verifyCsrf();

$is_ajax = isset($_GET['ajax']);
$entite  = strParam($_POST['entite'] ?? '');
$action  = strParam($_POST['action'] ?? '');

// ============================================================
// Helpers de réponse
// ============================================================

function repondreOk(bool $is_ajax, int $id, string $entite, string $redirect_url): void {
  $url_detail = BASE_URL . '/include/ajax/detail-pp/' . $entite . '.php';
  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode(['ok' => true, 'id' => $id, 'url_detail' => $url_detail]);
    exit;
  endif;
  $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Modification enregistrée.'];
  header('Location: ' . $redirect_url);
  exit;
}

function repondreErreur(bool $is_ajax, string $message, string $redirect_url): void {
  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode(['ok' => false, 'erreur' => $message]);
    exit;
  endif;
  $_SESSION['flash_message'] = ['type' => 'error', 'text' => $message];
  header('Location: ' . $redirect_url);
  exit;
}

$redirect = $_SERVER['HTTP_REFERER'] ?? BASE_URL . '/compendium/' . $entite . 's.php';

// ============================================================
// Dispatch
// ============================================================

if (!canEditCompendium()):
  repondreErreur($is_ajax, 'Accès refusé.', $redirect);
endif;

switch ($entite):

  case 'sort':
    switch ($action):
      case 'sauvegarder': enregistrerSort($db, $is_ajax, $redirect); break;
      case 'supprimer':   supprimerSort($db, $is_ajax, $redirect);   break;
      case 'bulk_supprimer': bulkSupprimerSorts($db, $redirect);     break;
      default: repondreErreur($is_ajax, 'Action inconnue.', $redirect);
    endswitch;
    break;

  default:
    repondreErreur($is_ajax, 'Entité inconnue : ' . h($entite), $redirect);

endswitch;

// ============================================================
// SORT — Enregistrement
// ============================================================

function enregistrerSort($db, bool $is_ajax, string $redirect): void {
  $so_id      = intParam($_POST['so_id'] ?? 0);
  $nom        = strParam($_POST['so_nom']               ?? '');
  $ruleset_id = intParam($_POST['so_ruleset_var_id']    ?? 1);

  if (!$nom):
    repondreErreur($is_ajax, 'Le nom du sort est obligatoire.', $redirect);
  endif;

  $res_id = intParam($_POST['so_res_id'] ?? 0);
  if (!$res_id):
    repondreErreur($is_ajax, 'La source est obligatoire.', $redirect);
  endif;

  // Champs texte communs
  $co_id     = intParam($_POST['so_co_id']             ?? 0) ?: null;
  $camp_id   = intParam($_POST['so_camp_id']           ?? 0) ?: null;
  $portee    = strParam($_POST['so_portee']            ?? '');
  $dur_inc   = strParam($_POST['so_duree_incantation'] ?? '');
  $dur_sort  = strParam($_POST['so_duree_sort']        ?? '');
  $composante= strParam($_POST['so_composante']        ?? '');
  $description = $_POST['so_description'] ?? ''; // HTML TinyMCE — pas de h()

  // Booléens composantes
  $vocal    = isset($_POST['so_vocal'])    ? 1 : 0;
  $gestuel  = isset($_POST['so_gestuel'])  ? 1 : 0;
  $materiel = isset($_POST['so_materiel']) ? 1 : 0;

  // Champs DD3.5
  $branche   = strParam($_POST['so_branche']          ?? '');
  $cible     = strParam($_POST['so_cible']            ?? '');
  $zone      = strParam($_POST['so_zone_effet']       ?? '');
  $jet_save  = strParam($_POST['so_jet_sauvegarde']   ?? '');
  $resistance= strParam($_POST['so_resistance']       ?? '');
  $resume    = strParam($_POST['so_resume']           ?? '');
  $focalis   = isset($_POST['so_focalisateur'])       ? 1 : 0;
  $focalis_d = isset($_POST['so_focalisateur_divin']) ? 1 : 0;

  // Champs DD2024
  $niveau    = intParam($_POST['so_niveau'] ?? 0);

  // Associations classes et domaines
  $niveaux_classes  = $_POST['niveaux_classes']  ?? [];
  $niveaux_domaines = $_POST['niveaux_domaines'] ?? [];

  try:
    $db->beginTransaction();

    if ($so_id === 0):
      // ---- CRÉATION ----
      $stmt = $db->prepare('
        INSERT INTO dd_sorts
          (so_nom, so_co_id, so_branche, so_vocal, so_gestuel, so_materiel,
           so_focalisateur, so_focalisateur_divin, so_composante, so_portee,
           so_cible, so_zone_effet, so_duree_incantation, so_duree_sort,
           so_jet_sauvegarde, so_resistance, so_niveau, so_resume,
           so_description, so_res_id, so_camp_id, so_ruleset_var_id)
        VALUES
          (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
      ');
      $stmt->execute([
        $nom, $co_id, $branche, $vocal, $gestuel, $materiel,
        $focalis, $focalis_d, $composante, $portee,
        $cible, $zone, $dur_inc, $dur_sort,
        $jet_save, $resistance, $niveau, $resume,
        $description, $res_id, $camp_id, $ruleset_id,
      ]);
      $so_id = (int)$db->lastInsertId();

    else:
      // ---- MODIFICATION ----
      $stmt = $db->prepare('
        UPDATE dd_sorts SET
          so_nom                = ?,
          so_co_id              = ?,
          so_branche            = ?,
          so_vocal              = ?,
          so_gestuel            = ?,
          so_materiel           = ?,
          so_focalisateur       = ?,
          so_focalisateur_divin = ?,
          so_composante         = ?,
          so_portee             = ?,
          so_cible              = ?,
          so_zone_effet         = ?,
          so_duree_incantation  = ?,
          so_duree_sort         = ?,
          so_jet_sauvegarde     = ?,
          so_resistance         = ?,
          so_niveau             = ?,
          so_resume             = ?,
          so_description        = ?,
          so_res_id             = ?,
          so_camp_id            = ?,
          so_ruleset_var_id     = ?
        WHERE so_id = ?
      ');
      $stmt->execute([
        $nom, $co_id, $branche, $vocal, $gestuel, $materiel,
        $focalis, $focalis_d, $composante, $portee,
        $cible, $zone, $dur_inc, $dur_sort,
        $jet_save, $resistance, $niveau, $resume,
        $description, $res_id, $camp_id, $ruleset_id,
        $so_id,
      ]);
    endif;

    // ---- Associations classes ----
    $del = $db->prepare('DELETE FROM dd_sortclasse WHERE sc_so_id = ?');
    $del->execute([$so_id]);
    $ins = $db->prepare('INSERT INTO dd_sortclasse (sc_so_id, sc_cla_id, sc_niveau) VALUES (?,?,?)');
    foreach ($niveaux_classes as $cla_id => $niv):
      $niv = (int)$niv;
      if ($niv > 0):
        $ins->execute([$so_id, (int)$cla_id, $niv]);
      endif;
    endforeach;

    // ---- Associations domaines [DD3.5] ----
    $del_dom = $db->prepare('DELETE FROM dd_sortdomaine WHERE sd_so_id = ?');
    $del_dom->execute([$so_id]);
    if (!empty($niveaux_domaines)):
      $ins_dom = $db->prepare('INSERT INTO dd_sortdomaine (sd_so_id, sd_do_id, sd_niveau) VALUES (?,?,?)');
      foreach ($niveaux_domaines as $dom_id => $niv):
        $niv = (int)$niv;
        if ($niv > 0):
          $ins_dom->execute([$so_id, (int)$dom_id, $niv]);
        endif;
      endforeach;
    endif;

    $db->commit();
    repondreOk($is_ajax, $so_id, 'sort', $redirect);

  catch (Exception $e):
    $db->rollBack();
    error_log('enregistrerSort : ' . $e->getMessage());
    repondreErreur($is_ajax, 'Erreur base de données.', $redirect);
  endtry;
}

// ============================================================
// SORT — Suppression individuelle
// ============================================================

function supprimerSort($db, bool $is_ajax, string $redirect): void {
  $ids = $_POST['ids'] ?? [];
  if (!empty($_POST['id'])) $ids[] = $_POST['id'];
  $ids = array_map('intval', (array)$ids);
  $ids = array_filter($ids);

  if (empty($ids)):
    repondreErreur($is_ajax, 'Aucun sort à supprimer.', $redirect);
  endif;

  try:
    $db->beginTransaction();
    foreach ($ids as $so_id):
      $db->prepare('DELETE FROM dd_sortclasse  WHERE sc_so_id = ?')->execute([$so_id]);
      $db->prepare('DELETE FROM dd_sortdomaine WHERE sd_so_id = ?')->execute([$so_id]);
      $db->prepare('DELETE FROM dd_sorts       WHERE so_id    = ?')->execute([$so_id]);
    endforeach;
    $db->commit();

    if ($is_ajax):
      header('Content-Type: application/json');
      echo json_encode(['ok' => true, 'id' => 0, 'url_detail' => '']);
      exit;
    endif;
    $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Sort(s) supprimé(s).'];
    header('Location: ' . $redirect);
    exit;

  catch (Exception $e):
    $db->rollBack();
    error_log('supprimerSort : ' . $e->getMessage());
    repondreErreur($is_ajax, 'Erreur lors de la suppression.', $redirect);
  endtry;
}

// ============================================================
// SORT — Suppression groupée (bulk)
// ============================================================

function bulkSupprimerSorts($db, string $redirect): void {
  // Réutilise la suppression individuelle en mode non-AJAX
  supprimerSort($db, false, $redirect);
}
