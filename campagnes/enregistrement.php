<?php
// campagnes/enregistrement.php — Point d'entrée unique des écritures du module Campagnes.
//
// GET ajax=1 → retourne JSON {ok, id, url_detail, erreur}
// Sinon      → redirige avec flash message SESSION
//
// POST requis :
//   action — 'enregistrerCampagne' | 'supprimerCampagne'
//           | 'enregistrerScenario' | 'supprimerScenario'
//           | 'enregistrerChapitre' | 'supprimerChapitre'

require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAuth();
verifyCsrf();

$is_ajax  = isset($_GET['ajax']);
$action   = strParam($_POST['action'] ?? '');
$redirect = $_SERVER['HTTP_REFERER'] ?? BASE_URL . '/campagnes/index.php';

// ============================================================
// Helpers de réponse
// ============================================================

function campOk(bool $is_ajax, int $id, string $redirect, string $url_detail = ''): void
{
  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode(['ok' => true, 'id' => $id, 'url_detail' => $url_detail]);
    exit;
  endif;
  $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Modification enregistrée.'];
  header('Location: ' . $redirect);
  exit;
}

function campErreur(bool $is_ajax, string $message, string $redirect): void
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

// ============================================================
// Dispatch
// ============================================================

switch ($action):

  case 'enregistrerCampagne':
    enregistrerCampagne($db, $is_ajax, $redirect);
    break;

  case 'supprimerCampagne':
    supprimerCampagne($db, $is_ajax, $redirect);
    break;

  case 'enregistrerScenario':
    enregistrerScenario($db, $is_ajax, $redirect);
    break;

  case 'supprimerScenario':
    supprimerScenario($db, $is_ajax, $redirect);
    break;

  case 'enregistrerChapitre':
    enregistrerChapitre($db, $is_ajax, $redirect);
    break;

  case 'supprimerChapitre':
    supprimerChapitre($db, $is_ajax, $redirect);
    break;

  case 'enregistrerRencontre':
    enregistrerRencontre($db, $is_ajax, $redirect);
    break;

  case 'supprimerRencontre':
    supprimerRencontre($db, $is_ajax, $redirect);
    break;

  case 'enregistrerOpposition':
    enregistrerOpposition($db, $is_ajax, $redirect);
    break;

  case 'supprimerOpposition':
    supprimerOpposition($db, $is_ajax, $redirect);
    break;

  default:
    campErreur($is_ajax, 'Action inconnue.', $redirect);

endswitch;

// ============================================================
// CAMPAGNE — Sauvegarde
// ============================================================

function enregistrerCampagne($db, bool $is_ajax, string $redirect): void
{
  $camp_id     = intParam($_POST['camp_id'] ?? 0);
  $nom         = strParam($_POST['camp_nom'] ?? '');
  $resume      = strParam($_POST['camp_resume'] ?? '');
  $description = $_POST['camp_description'] ?? '';
  $un_id       = intParam($_POST['camp_un_id'] ?? 0);
  $ruleset_id  = intParam($_POST['camp_ruleset_var_id'] ?? 0);
  $j_id        = (int)$_SESSION['j_id'];

  if (!$nom):
    campErreur($is_ajax, 'Le nom de la campagne est obligatoire.', $redirect);
  endif;

  $un_id_final = null;
  if ($un_id > 0):
    $stmt = $db->prepare('
      SELECT un_id FROM dd_univers
      WHERE  un_id = ? AND (un_j_id = ? OR un_public = 1)
    ');
    $stmt->execute([$un_id, $j_id]);
    if (!$stmt->fetch()):
      campErreur($is_ajax, 'Univers invalide.', $redirect);
    endif;
    $un_id_final = $un_id;
  endif;

  try {
    $db->beginTransaction();

    if ($camp_id === 0):
      $stmt = $db->prepare("SELECT var_id FROM dd_variables WHERE var_id = ? AND var_cat = 'ruleset'");
      $stmt->execute([$ruleset_id]);
      if (!$stmt->fetch()):
        $db->rollBack();
        campErreur($is_ajax, 'Ruleset invalide.', $redirect);
      endif;

      $stmt = $db->prepare('
        INSERT INTO dd_campagnes
          (camp_nom, camp_j_id, camp_ruleset_var_id, camp_un_id,
           camp_resume, camp_description, camp_date_creation, camp_supprime)
        VALUES (?,?,?,?,?,?,NOW(),0)
      ');
      $stmt->execute([$nom, $j_id, $ruleset_id, $un_id_final, $resume, $description]);
      $camp_id = (int)$db->lastInsertId();

    else:
      if (!isMJ($db, $camp_id)):
        $db->rollBack();
        campErreur($is_ajax, 'Accès refusé.', $redirect);
      endif;

      $stmt = $db->prepare('
        UPDATE dd_campagnes SET
          camp_nom         = ?,
          camp_un_id       = ?,
          camp_resume      = ?,
          camp_description = ?
        WHERE camp_id = ?
      ');
      $stmt->execute([$nom, $un_id_final, $resume, $description, $camp_id]);

      $sources = array_filter(array_map('intval', (array)($_POST['sources'] ?? [])));
      $db->prepare('DELETE FROM dd_campagnes_sources WHERE cs_camp_id = ?')->execute([$camp_id]);

      if (!empty($sources)):
        $stmt = $db->prepare('SELECT camp_ruleset_var_id FROM dd_campagnes WHERE camp_id = ?');
        $stmt->execute([$camp_id]);
        $camp_ruleset = (int)$stmt->fetchColumn();

        $ph   = implode(',', array_fill(0, count($sources), '?'));
        $stmt = $db->prepare("
          SELECT res_id FROM dd_ressources
          WHERE  res_id IN ($ph) AND res_ruleset_var_id = ? AND res_j_id IS NULL
        ");
        $stmt->execute(array_merge($sources, [$camp_ruleset]));
        $valides = array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN));

        if (!empty($valides)):
          $ins = $db->prepare('INSERT INTO dd_campagnes_sources (cs_camp_id, cs_res_id) VALUES (?,?)');
          foreach ($valides as $res_id):
            $ins->execute([$camp_id, $res_id]);
          endforeach;
        endif;
      endif;

    endif;

    $db->commit();
    campOk($is_ajax, $camp_id, $redirect, BASE_URL . '/include/ajax/detail-pp/campagne.php');

  } catch (Exception $e) {
    if ($db->inTransaction()) $db->rollBack();
    error_log('enregistrerCampagne : ' . $e->getMessage());
    campErreur($is_ajax, 'Erreur base de données.', $redirect);
  }
}

// ============================================================
// CAMPAGNE — Suppression douce en cascade
// ============================================================

function supprimerCampagne($db, bool $is_ajax, string $redirect): void
{
  $camp_id = intParam($_POST['id'] ?? $_POST['camp_id'] ?? 0);

  if (!$camp_id):
    campErreur($is_ajax, 'Identifiant manquant.', $redirect);
  endif;
  if (!isMJ($db, $camp_id)):
    campErreur($is_ajax, 'Accès refusé.', $redirect);
  endif;

  try {
    $db->beginTransaction();

    $sce_ids = colIds($db, 'SELECT sce_id FROM dd_scenarios WHERE sce_camp_id = ?', [$camp_id]);

    $scc_ids = [];
    $re_ids  = [];
    if (!empty($sce_ids)):
      $ph      = implode(',', array_fill(0, count($sce_ids), '?'));
      $scc_ids = colIds($db, "SELECT scc_id FROM dd_scenarios_chapitres WHERE scc_sce_id IN ($ph)", $sce_ids);
    endif;
    if (!empty($scc_ids)):
      $ph     = implode(',', array_fill(0, count($scc_ids), '?'));
      $re_ids = colIds($db, "SELECT re_id FROM dd_rencontres WHERE re_scc_id IN ($ph)", $scc_ids);
    endif;

    supprimerFichiers($db, 'campagne', [$camp_id]);
    if (!empty($sce_ids)) supprimerFichiers($db, 'scenario', $sce_ids);
    if (!empty($re_ids))  supprimerFichiers($db, 'rencontre', $re_ids);

    $now = date('Y-m-d H:i:s');
    softDeleteIds($db, 'dd_oppositions', 'opp_supprime', 'opp_date_supprime', 'opp_re_id', $re_ids);
    softDeleteIds($db, 'dd_rencontres', 're_supprime', 're_date_supprime', 're_id', $re_ids);
    softDeleteIds($db, 'dd_scenarios_chapitres', 'scc_supprime', 'scc_date_supprime', 'scc_id', $scc_ids);
    softDeleteIds($db, 'dd_scenarios', 'sce_supprime', 'sce_date_supprime', 'sce_id', $sce_ids);

    $db->prepare('UPDATE dd_campagnes SET camp_supprime = 1, camp_date_supprime = ? WHERE camp_id = ?')
       ->execute([$now, $camp_id]);

    $db->prepare('UPDATE dd_personnages SET pe_camp_id = NULL WHERE pe_camp_id = ?')->execute([$camp_id]);
    $db->prepare('DELETE FROM dd_campagnes_personnages WHERE cp_camp_id = ?')->execute([$camp_id]);
    $db->prepare('DELETE FROM dd_campagnes_sources     WHERE cs_camp_id = ?')->execute([$camp_id]);
    $db->prepare('DELETE FROM dd_campagnes_notes       WHERE cpno_camp_id = ?')->execute([$camp_id]);

    $db->commit();

    if ($is_ajax):
      header('Content-Type: application/json');
      echo json_encode(['ok' => true, 'id' => 0, 'url_detail' => '']);
      exit;
    endif;
    $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Campagne supprimée.'];
    header('Location: ' . BASE_URL . '/campagnes/index.php');
    exit;

  } catch (Exception $e) {
    if ($db->inTransaction()) $db->rollBack();
    error_log('supprimerCampagne : ' . $e->getMessage());
    campErreur($is_ajax, 'Erreur lors de la suppression.', $redirect);
  }
}

// ============================================================
// SCÉNARIO — Sauvegarde
// ============================================================

function enregistrerScenario($db, bool $is_ajax, string $redirect): void
{
  $sce_id     = intParam($_POST['sce_id']   ?? 0);
  $camp_id    = intParam($_POST['camp_id']  ?? 0);
  $nom        = strParam($_POST['sce_nom']  ?? '');
  $ordre      = intParam($_POST['sce_ordre'] ?? 0);
  $description = $_POST['sce_description'] ?? '';

  if (!$nom):
    campErreur($is_ajax, 'Le nom du scénario est obligatoire.', $redirect);
  endif;

  try {
    $db->beginTransaction();

    if ($sce_id === 0):
      // Création — camp_id requis et doit appartenir au MJ.
      if (!$camp_id || !isMJ($db, $camp_id)):
        $db->rollBack();
        campErreur($is_ajax, 'Accès refusé.', $redirect);
      endif;

      // Ordre automatique si non spécifié.
      if ($ordre === 0):
        $stmt = $db->prepare('SELECT COALESCE(MAX(sce_ordre),0)+1 FROM dd_scenarios WHERE sce_camp_id = ?');
        $stmt->execute([$camp_id]);
        $ordre = (int)$stmt->fetchColumn();
      endif;

      $stmt = $db->prepare('
        INSERT INTO dd_scenarios (sce_nom, sce_ordre, sce_description, sce_camp_id, sce_supprime)
        VALUES (?,?,?,?,0)
      ');
      $stmt->execute([$nom, $ordre, $description, $camp_id]);
      $sce_id = (int)$db->lastInsertId();

    else:
      // Modification — vérifier propriété via la campagne parente.
      if (!checkSceOwner($db, $sce_id)):
        $db->rollBack();
        campErreur($is_ajax, 'Accès refusé.', $redirect);
      endif;

      // Récupère camp_id si non fourni.
      if (!$camp_id):
        $stmt = $db->prepare('SELECT sce_camp_id FROM dd_scenarios WHERE sce_id = ?');
        $stmt->execute([$sce_id]);
        $camp_id = (int)$stmt->fetchColumn();
      endif;

      $stmt = $db->prepare('
        UPDATE dd_scenarios SET sce_nom = ?, sce_ordre = ?, sce_description = ?
        WHERE sce_id = ?
      ');
      $stmt->execute([$nom, $ordre, $description, $sce_id]);

    endif;

    $db->commit();
    // Retourne camp_id pour que le JS puisse rafraîchir la fiche campagne.
    if ($is_ajax):
      header('Content-Type: application/json');
      echo json_encode([
        'ok'       => true,
        'id'       => $sce_id,
        'camp_id'  => $camp_id,
        'url_detail' => BASE_URL . '/include/ajax/detail-pp/campagne.php',
      ]);
      exit;
    endif;
    $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Scénario enregistré.'];
    header('Location: ' . $redirect);
    exit;

  } catch (Exception $e) {
    if ($db->inTransaction()) $db->rollBack();
    error_log('enregistrerScenario : ' . $e->getMessage());
    campErreur($is_ajax, 'Erreur base de données.', $redirect);
  }
}

// ============================================================
// SCÉNARIO — Suppression douce en cascade
// ============================================================

function supprimerScenario($db, bool $is_ajax, string $redirect): void
{
  $sce_id = intParam($_POST['id'] ?? 0);

  if (!$sce_id || !checkSceOwner($db, $sce_id)):
    campErreur($is_ajax, 'Accès refusé.', $redirect);
  endif;

  // Récupère camp_id pour le retour JSON.
  $stmt = $db->prepare('SELECT sce_camp_id FROM dd_scenarios WHERE sce_id = ?');
  $stmt->execute([$sce_id]);
  $camp_id = (int)$stmt->fetchColumn();

  try {
    $db->beginTransaction();

    $ph      = '?';
    $scc_ids = colIds($db, "SELECT scc_id FROM dd_scenarios_chapitres WHERE scc_sce_id = $ph", [$sce_id]);
    $re_ids  = [];
    if (!empty($scc_ids)):
      $ph2    = implode(',', array_fill(0, count($scc_ids), '?'));
      $re_ids = colIds($db, "SELECT re_id FROM dd_rencontres WHERE re_scc_id IN ($ph2)", $scc_ids);
    endif;

    supprimerFichiers($db, 'scenario',  [$sce_id]);
    if (!empty($re_ids)) supprimerFichiers($db, 'rencontre', $re_ids);

    softDeleteIds($db, 'dd_oppositions', 'opp_supprime', 'opp_date_supprime', 'opp_re_id', $re_ids);
    softDeleteIds($db, 'dd_rencontres', 're_supprime', 're_date_supprime', 're_id', $re_ids);
    softDeleteIds($db, 'dd_scenarios_chapitres', 'scc_supprime', 'scc_date_supprime', 'scc_id', $scc_ids);

    $now = date('Y-m-d H:i:s');
    $db->prepare('UPDATE dd_scenarios SET sce_supprime = 1, sce_date_supprime = ? WHERE sce_id = ?')
       ->execute([$now, $sce_id]);

    $db->commit();

    if ($is_ajax):
      header('Content-Type: application/json');
      echo json_encode(['ok' => true, 'id' => $camp_id, 'camp_id' => $camp_id,
                        'url_detail' => BASE_URL . '/include/ajax/detail-pp/campagne.php']);
      exit;
    endif;
    $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Scénario supprimé.'];
    header('Location: ' . $redirect);
    exit;

  } catch (Exception $e) {
    if ($db->inTransaction()) $db->rollBack();
    error_log('supprimerScenario : ' . $e->getMessage());
    campErreur($is_ajax, 'Erreur lors de la suppression.', $redirect);
  }
}

// ============================================================
// CHAPITRE — Sauvegarde
// ============================================================

function enregistrerChapitre($db, bool $is_ajax, string $redirect): void
{
  $scc_id      = intParam($_POST['scc_id']          ?? 0);
  $sce_id      = intParam($_POST['sce_id']           ?? 0);
  $nom         = strParam($_POST['scc_nom']          ?? '');
  $abreviation = strParam($_POST['scc_abreviation']  ?? '');
  $ordre       = intParam($_POST['scc_ordre']        ?? 0);
  $description = strParam($_POST['scc_description']  ?? '');

  if (!$nom):
    campErreur($is_ajax, 'Le nom du chapitre est obligatoire.', $redirect);
  endif;

  // Tronque l'abréviation à 10 caractères.
  $abreviation = mb_substr($abreviation, 0, 10);

  try {
    $db->beginTransaction();

    $scc_id_was_zero = ($scc_id === 0);
    if ($scc_id === 0):
      if (!$sce_id || !checkSceOwner($db, $sce_id)):
        $db->rollBack();
        campErreur($is_ajax, 'Accès refusé.', $redirect);
      endif;

      if ($ordre === 0):
        $stmt = $db->prepare('SELECT COALESCE(MAX(scc_ordre),0)+1 FROM dd_scenarios_chapitres WHERE scc_sce_id = ?');
        $stmt->execute([$sce_id]);
        $ordre = (int)$stmt->fetchColumn();
      endif;

      $stmt = $db->prepare('
        INSERT INTO dd_scenarios_chapitres
          (scc_sce_id, scc_nom, scc_abreviation, scc_ordre, scc_description, scc_supprime)
        VALUES (?,?,?,?,?,0)
      ');
      $stmt->execute([$sce_id, $nom, $abreviation ?: null, $ordre, $description ?: null]);
      $scc_id = (int)$db->lastInsertId();

    else:
      if (!checkSccOwner($db, $scc_id)):
        $db->rollBack();
        campErreur($is_ajax, 'Accès refusé.', $redirect);
      endif;

      if (!$sce_id):
        $stmt = $db->prepare('SELECT scc_sce_id FROM dd_scenarios_chapitres WHERE scc_id = ?');
        $stmt->execute([$scc_id]);
        $sce_id = (int)$stmt->fetchColumn();
      endif;

      $stmt = $db->prepare('
        UPDATE dd_scenarios_chapitres
        SET scc_nom = ?, scc_abreviation = ?, scc_ordre = ?, scc_description = ?
        WHERE scc_id = ?
      ');
      $stmt->execute([$nom, $abreviation ?: null, $ordre, $description ?: null, $scc_id]);

    endif;

    $db->commit();

    if ($is_ajax):
      header('Content-Type: application/json');
      // Modification : url_detail pointe sur la fiche chapitre.
      // Création    : url_detail pointe sur la fiche scénario (retour au parent).
      $url_detail = $scc_id_was_zero
        ? BASE_URL . '/include/ajax/detail-pp/scenario.php'
        : BASE_URL . '/include/ajax/detail-pp/chapitre.php';
      $id_retour  = $scc_id_was_zero ? $sce_id : $scc_id;
      echo json_encode([
        'ok'      => true,
        'id'      => $id_retour,
        'scc_id'  => $scc_id,
        'sce_id'  => $sce_id,
        'url_detail' => $url_detail,
      ]);
      exit;
    endif;
    $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Chapitre enregistré.'];
    header('Location: ' . $redirect);
    exit;

  } catch (Exception $e) {
    if ($db->inTransaction()) $db->rollBack();
    error_log('enregistrerChapitre : ' . $e->getMessage());
    campErreur($is_ajax, 'Erreur base de données.', $redirect);
  }
}

// ============================================================
// CHAPITRE — Suppression douce en cascade
// ============================================================

function supprimerChapitre($db, bool $is_ajax, string $redirect): void
{
  $scc_id = intParam($_POST['id'] ?? 0);

  if (!$scc_id || !checkSccOwner($db, $scc_id)):
    campErreur($is_ajax, 'Accès refusé.', $redirect);
  endif;

  $stmt = $db->prepare('SELECT scc_sce_id FROM dd_scenarios_chapitres WHERE scc_id = ?');
  $stmt->execute([$scc_id]);
  $sce_id = (int)$stmt->fetchColumn();

  try {
    $db->beginTransaction();

    $re_ids = colIds($db, 'SELECT re_id FROM dd_rencontres WHERE re_scc_id = ?', [$scc_id]);
    if (!empty($re_ids)) supprimerFichiers($db, 'rencontre', $re_ids);

    softDeleteIds($db, 'dd_oppositions', 'opp_supprime', 'opp_date_supprime', 'opp_re_id', $re_ids);
    softDeleteIds($db, 'dd_rencontres', 're_supprime', 're_date_supprime', 're_id', $re_ids);

    $now = date('Y-m-d H:i:s');
    $db->prepare('UPDATE dd_scenarios_chapitres SET scc_supprime = 1, scc_date_supprime = ? WHERE scc_id = ?')
       ->execute([$now, $scc_id]);

    $db->commit();

    if ($is_ajax):
      header('Content-Type: application/json');
      echo json_encode([
        'ok'         => true,
        'id'         => $sce_id,
        'sce_id'     => $sce_id,
        'url_detail' => BASE_URL . '/include/ajax/detail-pp/scenario.php',
      ]);
      exit;
    endif;
    $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Chapitre supprimé.'];
    header('Location: ' . $redirect);
    exit;

  } catch (Exception $e) {
    if ($db->inTransaction()) $db->rollBack();
    error_log('supprimerChapitre : ' . $e->getMessage());
    campErreur($is_ajax, 'Erreur lors de la suppression.', $redirect);
  }
}

// ============================================================
// Utilitaires internes
// ============================================================

// Retourne un tableau d'entiers depuis une requête mono-colonne.
function colIds($db, string $sql, array $params): array
{
  $stmt = $db->prepare($sql);
  $stmt->execute($params);
  return array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN));
}

// Soft-delete en lot sur une colonne FK ou PK.
function softDeleteIds($db, string $table, string $col_flag, string $col_date, string $col_id, array $ids): void
{
  if (empty($ids)) return;
  $now = date('Y-m-d H:i:s');
  $ph  = implode(',', array_fill(0, count($ids), '?'));
  $db->prepare("UPDATE $table SET $col_flag = 1, $col_date = ? WHERE $col_id IN ($ph)")
     ->execute(array_merge([$now], $ids));
}

// unlink() des PDF puis marquage fi_supprime (option A).
function supprimerFichiers($db, string $entite, array $entite_ids): void
{
  if (empty($entite_ids)) return;

  $ph   = implode(',', array_fill(0, count($entite_ids), '?'));
  $stmt = $db->prepare("
    SELECT fi_id, fi_chemin FROM dd_fichiers
    WHERE  fi_entite = ? AND fi_entite_id IN ($ph) AND fi_supprime = 0
  ");
  $stmt->execute(array_merge([$entite], $entite_ids));
  $fichiers = $stmt->fetchAll();
  if (empty($fichiers)) return;

  $racine = realpath(__DIR__ . '/..');
  foreach ($fichiers as $f):
    $chemin = $racine . '/' . ltrim($f['fi_chemin'], '/');
    if (is_file($chemin)) @unlink($chemin);
  endforeach;

  $ids   = array_map(fn($f) => (int)$f['fi_id'], $fichiers);
  $phIds = implode(',', array_fill(0, count($ids), '?'));
  softDeleteIds($db, 'dd_fichiers', 'fi_supprime', 'fi_date_supprime', 'fi_id', $ids);
}

// Vérifie que le scénario appartient au MJ courant.
function checkSceOwner($db, int $sce_id): bool
{
  $stmt = $db->prepare('
    SELECT camp.camp_id FROM dd_scenarios sce
    JOIN   dd_campagnes camp ON camp.camp_id = sce.sce_camp_id
    WHERE  sce.sce_id = ? AND sce.sce_supprime = 0 AND camp.camp_supprime = 0
  ');
  $stmt->execute([$sce_id]);
  $row = $stmt->fetch();
  return $row && isMJ($db, (int)$row['camp_id']);
}

// Vérifie que le chapitre appartient au MJ courant.
function checkSccOwner($db, int $scc_id): bool
{
  $stmt = $db->prepare('
    SELECT camp.camp_id FROM dd_scenarios_chapitres scc
    JOIN   dd_scenarios sce   ON sce.sce_id   = scc.scc_sce_id
    JOIN   dd_campagnes camp  ON camp.camp_id  = sce.sce_camp_id
    WHERE  scc.scc_id = ? AND scc.scc_supprime = 0
      AND  sce.sce_supprime = 0 AND camp.camp_supprime = 0
  ');
  $stmt->execute([$scc_id]);
  $row = $stmt->fetch();
  return $row && isMJ($db, (int)$row['camp_id']);
}

// ============================================================
// RENCONTRE — Sauvegarde
// ============================================================

function enregistrerRencontre(PDO $db, bool $is_ajax, string $redirect): void
{
  $re_id          = intParam($_POST['re_id']   ?? 0);
  $scc_id         = intParam($_POST['scc_id']  ?? 0);
  $re_nom         = trim($_POST['re_nom']         ?? '');
  $re_code        = trim($_POST['re_code']        ?? '');
  $re_composition = trim($_POST['re_composition'] ?? '');
  $re_description = trim($_POST['re_description'] ?? '');

  if (!$re_nom)  campErreur($is_ajax, 'Le nom est obligatoire.', $redirect);
  if (!$scc_id)  campErreur($is_ajax, 'Chapitre manquant.', $redirect);
  if (!checkSccOwner($db, $scc_id)) campErreur($is_ajax, 'Accès refusé.', $redirect);

  $re_id_was_zero = ($re_id === 0);

  $db->beginTransaction();
  try {
    if ($re_id === 0):
      $stmt = $db->prepare('
        INSERT INTO dd_rencontres
          (re_nom, re_code, re_scc_id, re_description, re_composition, re_supprime)
        VALUES (?, ?, ?, ?, ?, 0)
      ');
      $stmt->execute([$re_nom, $re_code ?: null, $scc_id, $re_description ?: null, $re_composition ?: null]);
      $re_id = (int)$db->lastInsertId();
    else:
      // Vérification propriété sur la rencontre existante
      $stmt_chk = $db->prepare('SELECT re_scc_id FROM dd_rencontres WHERE re_id = ? AND re_supprime = 0');
      $stmt_chk->execute([$re_id]);
      $row_chk = $stmt_chk->fetch();
      if (!$row_chk || !checkSccOwner($db, (int)$row_chk['re_scc_id'])):
        $db->rollBack();
        campErreur($is_ajax, 'Accès refusé.', $redirect);
      endif;
      $stmt = $db->prepare('
        UPDATE dd_rencontres
        SET    re_nom = ?, re_code = ?, re_description = ?, re_composition = ?
        WHERE  re_id = ? AND re_supprime = 0
      ');
      $stmt->execute([$re_nom, $re_code ?: null, $re_description ?: null, $re_composition ?: null, $re_id]);
    endif;
    $db->commit();
  } catch (Exception $e) {
    $db->rollBack();
    campErreur($is_ajax, 'Erreur base de données.', $redirect);
  }

  $url_detail = $re_id_was_zero
    ? BASE_URL . '/include/ajax/detail-pp/chapitre.php'
    : BASE_URL . '/include/ajax/detail-pp/rencontre.php';
  $id_retour  = $re_id_was_zero ? $scc_id : $re_id;

  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode([
      'ok'         => true,
      'id'         => $id_retour,
      're_id'      => $re_id,
      'scc_id'     => $scc_id,
      'url_detail' => $url_detail,
    ]);
    exit;
  endif;
  $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Rencontre enregistrée.'];
  header('Location: ' . $redirect);
  exit;
}

// ============================================================
// RENCONTRE — Suppression (soft-delete)
// ============================================================

function supprimerRencontre(PDO $db, bool $is_ajax, string $redirect): void
{
  $re_id = intParam($_POST['id'] ?? 0);
  if (!$re_id) campErreur($is_ajax, 'Identifiant manquant.', $redirect);

  $stmt = $db->prepare('SELECT re_scc_id FROM dd_rencontres WHERE re_id = ? AND re_supprime = 0');
  $stmt->execute([$re_id]);
  $row = $stmt->fetch();
  if (!$row) campErreur($is_ajax, 'Rencontre introuvable.', $redirect);

  $scc_id = (int)$row['re_scc_id'];
  if (!checkSccOwner($db, $scc_id)) campErreur($is_ajax, 'Accès refusé.', $redirect);

  $db->beginTransaction();
  try {
    softDeleteIds($db, 'dd_rencontres', 're_supprime', 're_date_supprime', 're_id', [$re_id]);
    $db->commit();
  } catch (Exception $e) {
    $db->rollBack();
    campErreur($is_ajax, 'Erreur base de données.', $redirect);
  }

  invalidateLastCampagneContext('rencontre', $re_id);

  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode([
      'ok'         => true,
      'id'         => $scc_id,
      'scc_id'     => $scc_id,
      'url_detail' => BASE_URL . '/include/ajax/detail-pp/chapitre.php',
    ]);
    exit;
  endif;
  $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Rencontre supprimée.'];
  header('Location: ' . $redirect);
  exit;
}

// ============================================================
// OPPOSITION — Sauvegarde
// ============================================================

function enregistrerOpposition(PDO $db, bool $is_ajax, string $redirect): void
{
  $opp_id        = intParam($_POST['opp_id']        ?? 0);
  $re_id         = intParam($_POST['re_id']          ?? 0);
  $opp_mo_id     = intParam($_POST['opp_mo_id']       ?? 0);
  $opp_nom       = trim($_POST['opp_nom']             ?? '');
  $opp_mocat_nom = trim($_POST['opp_mocat_nom']       ?? '');
  $opp_stats     = trim($_POST['opp_stats']           ?? '');

  if (!$opp_nom) campErreur($is_ajax, 'Le nom est obligatoire.', $redirect);
  if (!$re_id)   campErreur($is_ajax, 'Rencontre manquante.', $redirect);
  if (!checkReOwner($db, $re_id)) campErreur($is_ajax, 'Accès refusé.', $redirect);

  $opp_id_was_zero = ($opp_id === 0);

  if ($opp_id_was_zero && !$opp_mo_id) {
    campErreur($is_ajax, 'Choisissez un monstre d\'origine.', $redirect);
  }

  $db->beginTransaction();
  try {
    if ($opp_id === 0):
      $stmt = $db->prepare('
        INSERT INTO dd_oppositions
          (opp_nom, opp_mocat_nom, opp_stats, opp_re_id, opp_mo_id, opp_supprime)
        VALUES (?, ?, ?, ?, ?, 0)
      ');
      $stmt->execute([$opp_nom, $opp_mocat_nom ?: null, $opp_stats ?: null, $re_id, $opp_mo_id]);
      $opp_id = (int)$db->lastInsertId();
    else:
      // Vérification propriété sur l'opposition existante
      $stmt_chk = $db->prepare('SELECT opp_re_id FROM dd_oppositions WHERE opp_id = ? AND opp_supprime = 0');
      $stmt_chk->execute([$opp_id]);
      $row_chk = $stmt_chk->fetch();
      if (!$row_chk || !checkReOwner($db, (int)$row_chk['opp_re_id'])):
        $db->rollBack();
        campErreur($is_ajax, 'Accès refusé.', $redirect);
      endif;
      // opp_mo_id n'est jamais modifié après création (traçabilité figée)
      $stmt = $db->prepare('
        UPDATE dd_oppositions
        SET    opp_nom = ?, opp_mocat_nom = ?, opp_stats = ?
        WHERE  opp_id = ? AND opp_supprime = 0
      ');
      $stmt->execute([$opp_nom, $opp_mocat_nom ?: null, $opp_stats ?: null, $opp_id]);
    endif;
    $db->commit();
  } catch (Exception $e) {
    $db->rollBack();
    campErreur($is_ajax, 'Erreur base de données.', $redirect);
  }

  $url_detail = $opp_id_was_zero
    ? BASE_URL . '/include/ajax/detail-pp/rencontre.php'
    : BASE_URL . '/include/ajax/detail-pp-sub/opposition.php';
  $id_retour  = $opp_id_was_zero ? $re_id : $opp_id;

  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode([
      'ok'         => true,
      'id'         => $id_retour,
      'opp_id'     => $opp_id,
      're_id'      => $re_id,
      'url_detail' => $url_detail,
    ]);
    exit;
  endif;
  $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Opposition enregistrée.'];
  header('Location: ' . $redirect);
  exit;
}

// ============================================================
// OPPOSITION — Suppression (soft-delete)
// ============================================================

function supprimerOpposition(PDO $db, bool $is_ajax, string $redirect): void
{
  $opp_id = intParam($_POST['id'] ?? 0);
  if (!$opp_id) campErreur($is_ajax, 'Identifiant manquant.', $redirect);

  $stmt = $db->prepare('SELECT opp_re_id FROM dd_oppositions WHERE opp_id = ? AND opp_supprime = 0');
  $stmt->execute([$opp_id]);
  $row = $stmt->fetch();
  if (!$row) campErreur($is_ajax, 'Opposition introuvable.', $redirect);

  $re_id = (int)$row['opp_re_id'];
  if (!checkReOwner($db, $re_id)) campErreur($is_ajax, 'Accès refusé.', $redirect);

  $db->beginTransaction();
  try {
    softDeleteIds($db, 'dd_oppositions', 'opp_supprime', 'opp_date_supprime', 'opp_id', [$opp_id]);
    $db->commit();
  } catch (Exception $e) {
    $db->rollBack();
    campErreur($is_ajax, 'Erreur base de données.', $redirect);
  }

  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode([
      'ok'         => true,
      'id'         => $re_id,
      're_id'      => $re_id,
      'url_detail' => BASE_URL . '/include/ajax/detail-pp/rencontre.php',
    ]);
    exit;
  endif;
  $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Opposition supprimée.'];
  header('Location: ' . $redirect);
  exit;
}

// Vérifie que l'utilisateur courant est MJ de la campagne porteuse de la rencontre.
function checkReOwner(PDO $db, int $re_id): bool
{
  $stmt = $db->prepare('
    SELECT camp.camp_id FROM dd_rencontres re
    JOIN   dd_scenarios_chapitres scc ON scc.scc_id = re.re_scc_id
    JOIN   dd_scenarios sce  ON sce.sce_id  = scc.scc_sce_id
    JOIN   dd_campagnes camp ON camp.camp_id = sce.sce_camp_id
    WHERE  re.re_id = ? AND re.re_supprime = 0
      AND  scc.scc_supprime = 0 AND sce.sce_supprime = 0 AND camp.camp_supprime = 0
  ');
  $stmt->execute([$re_id]);
  $row = $stmt->fetch();
  return $row && isMJ($db, (int)$row['camp_id']);
}
