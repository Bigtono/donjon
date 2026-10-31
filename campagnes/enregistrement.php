<?php
// campagnes/enregistrement.php — Point d'entrée unique des écritures du module Campagnes.
//
// GET ajax=1 → retourne JSON {ok, id, erreur}
// Sinon      → redirige avec flash message SESSION
//
// POST requis :
//   action — 'enregistrerCampagne' | 'supprimerCampagne'
//           | 'enregistrerScenario' | 'supprimerScenario'
//           | 'enregistrerChapitre' | 'supprimerChapitre'
//           | 'enregistrerNote' | 'supprimerNote' (SP-NO2)

require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';
require_once '../include/personnage_helpers.php'; // texteRicheVide() (SP-NO2)
require_once '../include/tableau-parser.php';     // _tabSlugify() : slug des mots-clés (SP-NO2)

requireAuth();
verifyCsrf();

$is_ajax  = isset($_GET['ajax']);
$action   = strParam($_POST['action'] ?? '');
$redirect = $_SERVER['HTTP_REFERER'] ?? BASE_URL . '/campagnes/index.php';

// ============================================================
// Helpers de réponse
// ============================================================

// SP-CP : plus d'url_detail dans les réponses. Elles désignaient les handlers
// include/ajax/detail-pp/{campagne,scenario,chapitre,rencontre}.php, supprimés
// avec le passage en pleine page. C'est désormais la page appelante qui décide
// où aller après une écriture — elle le sait mieux que le serveur, qui ignore
// depuis quel niveau le formulaire a été ouvert.
function campOk(bool $is_ajax, int $id, string $redirect): void
{
  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode(['ok' => true, 'id' => $id]);
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

  case 'transfererOpposition':
    transfererOpposition($db, $is_ajax, $redirect);
    break;

  case 'dupliquerOpposition':
    dupliquerOpposition($db, $is_ajax, $redirect);
    break;

  case 'reordonnerScenarios':
    reordonnerScenarios($db, $is_ajax, $redirect);
    break;

  case 'reordonnerChapitres':
    reordonnerChapitres($db, $is_ajax, $redirect);
    break;

  case 'reordonnerRencontres':
    reordonnerRencontres($db, $is_ajax, $redirect);
    break;

  case 'reordonnerOppositions':
    reordonnerOppositions($db, $is_ajax, $redirect);
    break;

  case 'enregistrerNote':
    enregistrerNote($db, $is_ajax, $redirect);
    break;

  case 'supprimerNote':
    supprimerNote($db, $is_ajax, $redirect);
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
  $j_id        = (int)$_SESSION['j_id'];

  // Ruleset maître de la campagne : jamais saisi ni posté — session à la
  // création, valeur en base ensuite (immuable). Cf. helpers.php.
  $ruleset_id  = rulesetEnregistrement($db, 'dd_campagnes', 'camp_id',
                                       'camp_ruleset_var_id', $camp_id);

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
    campOk($is_ajax, $camp_id, $redirect);

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
    softDeleteIds($db, 'dd_notes', 'no_supprime', 'no_date_supprime', 'no_camp_id', [$camp_id]);

    $db->prepare('UPDATE dd_campagnes SET camp_supprime = 1, camp_date_supprime = ? WHERE camp_id = ?')
       ->execute([$now, $camp_id]);

    $db->prepare('UPDATE dd_personnages SET pe_camp_id = NULL WHERE pe_camp_id = ?')->execute([$camp_id]);
    $db->prepare('DELETE FROM dd_campagnes_personnages WHERE cp_camp_id = ?')->execute([$camp_id]);
    $db->prepare('DELETE FROM dd_campagnes_sources     WHERE cs_camp_id = ?')->execute([$camp_id]);

    $db->commit();

    if ($is_ajax):
      header('Content-Type: application/json');
      echo json_encode(['ok' => true, 'id' => 0]);
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
  $description = $_POST['sce_description'] ?? '';

  // sce_ordre n'est plus saisi (SP-CP) : rang automatique à la création,
  // piloté ensuite par le seul glisser-déposer (action reordonnerScenarios).
  // Il n'apparaît donc PAS dans l'UPDATE — l'y laisser l'écraserait à 0.

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

      // Rang automatique : le nouveau scénario se pose en fin de liste.
      $stmt = $db->prepare('SELECT COALESCE(MAX(sce_ordre),0)+1 FROM dd_scenarios WHERE sce_camp_id = ?');
      $stmt->execute([$camp_id]);
      $ordre = (int)$stmt->fetchColumn();

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
        UPDATE dd_scenarios SET sce_nom = ?, sce_description = ?
        WHERE sce_id = ?
      ');
      $stmt->execute([$nom, $description, $sce_id]);

    endif;

    $db->commit();
    // Retourne camp_id pour que le JS puisse rafraîchir la fiche campagne.
    if ($is_ajax):
      header('Content-Type: application/json');
      echo json_encode([
        'ok'       => true,
        'id'       => $sce_id,
        'camp_id'  => $camp_id,
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

    // Les notes du scénario remontent au niveau de la campagne (D-NO7) : les
    // joueurs ne perdent pas des informations déjà reçues.
    $db->prepare('UPDATE dd_notes SET no_sce_id = NULL WHERE no_sce_id = ?')->execute([$sce_id]);

    $db->commit();

    if ($is_ajax):
      header('Content-Type: application/json');
      echo json_encode(['ok' => true, 'id' => $camp_id, 'camp_id' => $camp_id]);
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
  $description = strParam($_POST['scc_description']  ?? '');

  // scc_ordre n'est plus saisi (SP-CP) — cf. enregistrerScenario().

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

      // Rang automatique : le nouveau chapitre se pose en fin de liste.
      $stmt = $db->prepare('SELECT COALESCE(MAX(scc_ordre),0)+1 FROM dd_scenarios_chapitres WHERE scc_sce_id = ?');
      $stmt->execute([$sce_id]);
      $ordre = (int)$stmt->fetchColumn();

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
        SET scc_nom = ?, scc_abreviation = ?, scc_description = ?
        WHERE scc_id = ?
      ');
      $stmt->execute([$nom, $abreviation ?: null, $description ?: null, $scc_id]);

    endif;

    $db->commit();

    if ($is_ajax):
      header('Content-Type: application/json');
      $id_retour  = $scc_id_was_zero ? $sce_id : $scc_id;
      echo json_encode([
        'ok'      => true,
        'id'      => $id_retour,
        'scc_id'  => $scc_id,
        'sce_id'  => $sce_id,
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
  $re_composition = $_POST['re_composition'] ?? '';
  $re_description = $_POST['re_description'] ?? '';

  if (!$re_nom)  campErreur($is_ajax, 'Le nom est obligatoire.', $redirect);
  if (!$scc_id)  campErreur($is_ajax, 'Chapitre manquant.', $redirect);
  if (!checkSccOwner($db, $scc_id)) campErreur($is_ajax, 'Accès refusé.', $redirect);

  $re_id_was_zero = ($re_id === 0);

  $db->beginTransaction();
  try {
    if ($re_id === 0):
      // Rang automatique (SP-CP) : la nouvelle rencontre se pose en fin de
      // chapitre. re_ordre n'est jamais saisi, seul le glisser-déposer le change.
      $stmt = $db->prepare('SELECT COALESCE(MAX(re_ordre),0)+1 FROM dd_rencontres WHERE re_scc_id = ?');
      $stmt->execute([$scc_id]);
      $re_ordre = (int)$stmt->fetchColumn();

      $stmt = $db->prepare('
        INSERT INTO dd_rencontres
          (re_nom, re_code, re_ordre, re_scc_id, re_description, re_composition, re_supprime)
        VALUES (?, ?, ?, ?, ?, ?, 0)
      ');
      $stmt->execute([$re_nom, $re_code ?: null, $re_ordre, $scc_id,
                      $re_description ?: null, $re_composition ?: null]);
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

  $id_retour  = $re_id_was_zero ? $scc_id : $re_id;

  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode([
      'ok'         => true,
      'id'         => $id_retour,
      're_id'      => $re_id,
      'scc_id'     => $scc_id,
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
  $opp_mo_id     = intParam($_POST['opp_mo_id']       ?? 0) ?: null; // optionnel : saisie 100% manuelle possible
  $opp_nom       = trim($_POST['opp_nom']             ?? '');
  $opp_mocat_nom = trim($_POST['opp_mocat_nom']       ?? '');
  $opp_stats     = trim($_POST['opp_stats']           ?? '');

  if (!$opp_nom) campErreur($is_ajax, 'Le nom est obligatoire.', $redirect);
  if (!$re_id)   campErreur($is_ajax, 'Rencontre manquante.', $redirect);
  if (!checkReOwner($db, $re_id)) campErreur($is_ajax, 'Accès refusé.', $redirect);

  $opp_id_was_zero = ($opp_id === 0);

  $db->beginTransaction();
  try {
    if ($opp_id === 0):
      // Rang automatique (SP-CP) — cf. enregistrerRencontre().
      $stmt = $db->prepare('SELECT COALESCE(MAX(opp_ordre),0)+1 FROM dd_oppositions WHERE opp_re_id = ?');
      $stmt->execute([$re_id]);
      $opp_ordre = (int)$stmt->fetchColumn();

      $stmt = $db->prepare('
        INSERT INTO dd_oppositions
          (opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
        VALUES (?, ?, ?, ?, ?, ?, 0)
      ');
      $stmt->execute([$opp_nom, $opp_mocat_nom ?: null, $opp_stats ?: null,
                      $opp_ordre, $re_id, $opp_mo_id]);
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
      // opp_mo_id n'est jamais modifié après création (traçabilité figée) —
      // y compris pour passer de NULL à une valeur : si l'opposition a été
      // créée sans monstre d'origine, elle le reste (cohérent avec "figé").
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

  $id_retour  = $opp_id_was_zero ? $re_id : $opp_id;

  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode([
      'ok'         => true,
      'id'         => $id_retour,
      'opp_id'     => $opp_id,
      're_id'      => $re_id,
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
    ]);
    exit;
  endif;
  $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Opposition supprimée.'];
  header('Location: ' . $redirect);
  exit;
}

// Transfère une opposition vers une autre rencontre — SP-T0 : même campagne
// uniquement (cf. ARCHITECTURE_0_REFERENCE.md § Plan Transfert/Duplication
// d'opposition (SP-T) pour SP-T1, transfert inter-campagnes, planifié).
function transfererOpposition(PDO $db, bool $is_ajax, string $redirect): void
{
  $opp_id     = intParam($_POST['opp_id']     ?? 0);
  $dest_re_id = intParam($_POST['dest_re_id'] ?? 0);
  if (!$opp_id || !$dest_re_id) campErreur($is_ajax, 'Paramètres manquants.', $redirect);

  $stmt = $db->prepare('SELECT opp_re_id FROM dd_oppositions WHERE opp_id = ? AND opp_supprime = 0');
  $stmt->execute([$opp_id]);
  $row = $stmt->fetch();
  if (!$row) campErreur($is_ajax, 'Opposition introuvable.', $redirect);

  $source_re_id = (int)$row['opp_re_id'];
  if (!checkReOwner($db, $source_re_id)) campErreur($is_ajax, 'Accès refusé.', $redirect);
  if (!checkReOwner($db, $dest_re_id))   campErreur($is_ajax, 'Rencontre de destination invalide.', $redirect);

  if (!memeCampagne($db, $source_re_id, $dest_re_id)):
    campErreur($is_ajax, "Le transfert vers une autre campagne n'est pas encore disponible.", $redirect);
  endif;

  if ($dest_re_id === $source_re_id):
    campErreur($is_ajax, 'Cette opposition est déjà dans cette rencontre.', $redirect);
  endif;

  $db->beginTransaction();
  try {
    // L'opposition transférée se pose en fin de la rencontre d'arrivée (SP-CP) :
    // conserver son ancien rang la placerait arbitrairement dans un classement
    // qui n'est pas le sien.
    $stmt = $db->prepare('SELECT COALESCE(MAX(opp_ordre),0)+1 FROM dd_oppositions WHERE opp_re_id = ?');
    $stmt->execute([$dest_re_id]);
    $opp_ordre = (int)$stmt->fetchColumn();

    $stmt = $db->prepare('
      UPDATE dd_oppositions SET opp_re_id = ?, opp_ordre = ?
      WHERE  opp_id = ? AND opp_supprime = 0
    ');
    $stmt->execute([$dest_re_id, $opp_ordre, $opp_id]);
    $db->commit();
  } catch (Exception $e) {
    $db->rollBack();
    campErreur($is_ajax, 'Erreur base de données.', $redirect);
  }

  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode(['ok' => true, 'id' => $source_re_id, 're_id' => $source_re_id]);
    exit;
  endif;
  $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Opposition transférée.'];
  header('Location: ' . $redirect);
  exit;
}

// Duplique une opposition vers une autre rencontre (ou la même, pour une
// copie en place) — SP-T0 : même campagne uniquement (cf. SP-T1 ci-dessus).
// Suffixe « - copie » uniquement si la cible est la rencontre d'origine
// (convention déjà actée pour la duplication, cf. DECISIONS_LOG.md
// [2026-06-01]) — vers une rencontre différente, le nom n'est pas modifié.
function dupliquerOpposition(PDO $db, bool $is_ajax, string $redirect): void
{
  $opp_id     = intParam($_POST['opp_id']     ?? 0);
  $dest_re_id = intParam($_POST['dest_re_id'] ?? 0);
  if (!$opp_id || !$dest_re_id) campErreur($is_ajax, 'Paramètres manquants.', $redirect);

  $stmt = $db->prepare('SELECT * FROM dd_oppositions WHERE opp_id = ? AND opp_supprime = 0');
  $stmt->execute([$opp_id]);
  $opp = $stmt->fetch();
  if (!$opp) campErreur($is_ajax, 'Opposition introuvable.', $redirect);

  $source_re_id = (int)$opp['opp_re_id'];
  if (!checkReOwner($db, $source_re_id)) campErreur($is_ajax, 'Accès refusé.', $redirect);
  if (!checkReOwner($db, $dest_re_id))   campErreur($is_ajax, 'Rencontre de destination invalide.', $redirect);

  if (!memeCampagne($db, $source_re_id, $dest_re_id)):
    campErreur($is_ajax, "La duplication vers une autre campagne n'est pas encore disponible.", $redirect);
  endif;

  $nom = $opp['opp_nom'] . ($dest_re_id === $source_re_id ? ' - copie' : '');

  $db->beginTransaction();
  try {
    // La copie se pose en fin de la rencontre de destination (SP-CP).
    $stmt = $db->prepare('SELECT COALESCE(MAX(opp_ordre),0)+1 FROM dd_oppositions WHERE opp_re_id = ?');
    $stmt->execute([$dest_re_id]);
    $opp_ordre = (int)$stmt->fetchColumn();

    $stmt = $db->prepare('
      INSERT INTO dd_oppositions
        (opp_nom, opp_mocat_nom, opp_stats, opp_ordre, opp_re_id, opp_mo_id, opp_supprime)
      VALUES (?, ?, ?, ?, ?, ?, 0)
    ');
    $stmt->execute([
      $nom,
      $opp['opp_mocat_nom'],
      $opp['opp_stats'],
      $opp_ordre,
      $dest_re_id,
      $opp['opp_mo_id'],
    ]);
    $new_id = (int)$db->lastInsertId();
    $db->commit();
  } catch (Exception $e) {
    $db->rollBack();
    campErreur($is_ajax, 'Erreur base de données.', $redirect);
  }

  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode(['ok' => true, 'id' => $new_id, 're_id' => $source_re_id]);
    exit;
  endif;
  $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Opposition dupliquée.'];
  header('Location: ' . $redirect);
  exit;
}

// Vrai si deux rencontres appartiennent à la même campagne (par ids distincts
// — un MJ peut posséder plusieurs campagnes : checkReOwner() seul ne suffit
// pas à garantir "même campagne", seulement "campagne(s) du même MJ").
function memeCampagne(PDO $db, int $re_id_a, int $re_id_b): bool
{
  $camp_a = campIdDeRencontre($db, $re_id_a);
  $camp_b = campIdDeRencontre($db, $re_id_b);
  return $camp_a !== null && $camp_a === $camp_b;
}

function campIdDeRencontre(PDO $db, int $re_id): ?int
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
  return $row ? (int)$row['camp_id'] : null;
}

// ============================================================
// RÉORDONNANCEMENT — glisser-déposer (SP-CP2)
// ============================================================
// Quatre actions, une par niveau, toutes bâties sur reordonnerNiveau().
// Le client (js/tri-liste.js) poste :
//   parent_id — le conteneur dont on réordonne les enfants
//   ids       — les ids enfants dans le nouvel ordre, séparés par des virgules
//
// Contrôle de propriété : vérifié sur le PARENT (une seule remontée de
// hiérarchie), puis chaque id posté doit appartenir à ce parent — un id
// étranger glissé dans la liste ne peut donc pas être déplacé, même s'il
// appartient au même MJ. Le lot doit être complet et exact, sinon rien n'est
// écrit : un ordre partiel produirait des rangs en double.

// Écrit le rang de chaque enfant. $table / $col_* sont des littéraux internes
// (jamais issus du POST) — leur interpolation dans le SQL est sûre.
function reordonnerNiveau(PDO $db, bool $is_ajax, string $redirect,
                          string $table, string $col_id, string $col_ordre,
                          string $col_parent, string $col_supprime,
                          int $parent_id): void
{
  $ids = array_values(array_unique(array_filter(
    array_map('intval', explode(',', (string)($_POST['ids'] ?? ''))),
    fn($v) => $v > 0
  )));

  if (empty($ids)):
    campErreur($is_ajax, 'Aucun élément à réordonner.', $redirect);
  endif;

  // Le lot posté doit correspondre EXACTEMENT aux enfants actifs du parent.
  $ph   = implode(',', array_fill(0, count($ids), '?'));
  $stmt = $db->prepare("
    SELECT COUNT(*) FROM $table
    WHERE  $col_id IN ($ph) AND $col_parent = ? AND $col_supprime = 0
  ");
  $stmt->execute(array_merge($ids, [$parent_id]));
  if ((int)$stmt->fetchColumn() !== count($ids)):
    campErreur($is_ajax, 'Liste incohérente — ordre non enregistré.', $redirect);
  endif;

  try {
    $db->beginTransaction();
    $upd = $db->prepare("UPDATE $table SET $col_ordre = ? WHERE $col_id = ? AND $col_parent = ?");
    foreach ($ids as $rang => $id):
      $upd->execute([$rang + 1, $id, $parent_id]);
    endforeach;
    $db->commit();
  } catch (Exception $e) {
    if ($db->inTransaction()) $db->rollBack();
    error_log("reordonnerNiveau($table) : " . $e->getMessage());
    campErreur($is_ajax, 'Erreur base de données.', $redirect);
  }

  campOk($is_ajax, $parent_id, $redirect);
}

function reordonnerScenarios(PDO $db, bool $is_ajax, string $redirect): void
{
  $camp_id = intParam($_POST['parent_id'] ?? 0);
  if (!$camp_id || !isMJ($db, $camp_id)) campErreur($is_ajax, 'Accès refusé.', $redirect);

  reordonnerNiveau($db, $is_ajax, $redirect, 'dd_scenarios',
                   'sce_id', 'sce_ordre', 'sce_camp_id', 'sce_supprime', $camp_id);
}

function reordonnerChapitres(PDO $db, bool $is_ajax, string $redirect): void
{
  $sce_id = intParam($_POST['parent_id'] ?? 0);
  if (!$sce_id || !checkSceOwner($db, $sce_id)) campErreur($is_ajax, 'Accès refusé.', $redirect);

  reordonnerNiveau($db, $is_ajax, $redirect, 'dd_scenarios_chapitres',
                   'scc_id', 'scc_ordre', 'scc_sce_id', 'scc_supprime', $sce_id);
}

function reordonnerRencontres(PDO $db, bool $is_ajax, string $redirect): void
{
  $scc_id = intParam($_POST['parent_id'] ?? 0);
  if (!$scc_id || !checkSccOwner($db, $scc_id)) campErreur($is_ajax, 'Accès refusé.', $redirect);

  reordonnerNiveau($db, $is_ajax, $redirect, 'dd_rencontres',
                   're_id', 're_ordre', 're_scc_id', 're_supprime', $scc_id);
}

function reordonnerOppositions(PDO $db, bool $is_ajax, string $redirect): void
{
  $re_id = intParam($_POST['parent_id'] ?? 0);
  if (!$re_id || !checkReOwner($db, $re_id)) campErreur($is_ajax, 'Accès refusé.', $redirect);

  reordonnerNiveau($db, $is_ajax, $redirect, 'dd_oppositions',
                   'opp_id', 'opp_ordre', 'opp_re_id', 'opp_supprime', $re_id);
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

// ============================================================
// NOTES — Sauvegarde (SP-NO2)
// Une note = tronc commun + sections (JSON sections_json) avec leurs
// conditions « compétence + DD », mots-clés (tags[]) et destinataires
// (pe_ids[]). Sections, conditions et mots-clés sont remplacés en bloc ;
// les destinataires conservés gardent leur date de diffusion et de lecture,
// sauf « signaler_maj » qui remet la note à « non lue » (D-NO8).
// ============================================================

function enregistrerNote(PDO $db, bool $is_ajax, string $redirect): void
{
  $no_id    = intParam($_POST['no_id']      ?? 0);
  $camp_id  = intParam($_POST['camp_id']    ?? 0);
  $nom      = strParam($_POST['no_nom']     ?? '');
  $tyno_id  = intParam($_POST['no_tyno_id'] ?? 0);
  $sce_id   = intParam($_POST['no_sce_id']  ?? 0);
  $texte    = (string)($_POST['no_texte']   ?? '');
  $date     = strParam($_POST['no_date']    ?? '');
  $signaler = !empty($_POST['signaler_maj']);

  // Modification : la campagne est celle de la note, jamais celle du formulaire.
  if ($no_id > 0):
    $stmt = $db->prepare('SELECT no_camp_id FROM dd_notes WHERE no_id = ? AND no_supprime = 0');
    $stmt->execute([$no_id]);
    $camp_id = (int)$stmt->fetchColumn();
  endif;
  if (!$camp_id || !isMJ($db, $camp_id)):
    campErreur($is_ajax, 'Accès refusé.', $redirect);
  endif;

  if ($nom === ''):
    campErreur($is_ajax, 'Le titre de la note est obligatoire.', $redirect);
  endif;
  $nom = mb_substr($nom, 0, 200);

  $stmt = $db->prepare('SELECT camp_ruleset_var_id FROM dd_campagnes WHERE camp_id = ?');
  $stmt->execute([$camp_id]);
  $ruleset_id = (int)$stmt->fetchColumn();

  // Catégorie du ruleset de la campagne
  $stmt = $db->prepare('SELECT COUNT(*) FROM dd_types_notes WHERE tyno_id = ? AND tyno_ruleset_var_id = ?');
  $stmt->execute([$tyno_id, $ruleset_id]);
  if (!(int)$stmt->fetchColumn()):
    campErreur($is_ajax, 'Catégorie invalide.', $redirect);
  endif;

  // Scénario facultatif, de la même campagne
  if ($sce_id > 0):
    $stmt = $db->prepare('SELECT COUNT(*) FROM dd_scenarios WHERE sce_id = ? AND sce_camp_id = ? AND sce_supprime = 0');
    $stmt->execute([$sce_id, $camp_id]);
    if (!(int)$stmt->fetchColumn()):
      campErreur($is_ajax, 'Scénario invalide.', $redirect);
    endif;
  endif;

  $d        = DateTime::createFromFormat('!Y-m-d', $date);
  $date_sql = ($d && $d->format('Y-m-d') === $date) ? $date . ' 00:00:00' : date('Y-m-d H:i:s');

  // Sections : JSON [{titre, texte, conditions: [{comp_id, dd}]}]. Une section
  // sans intertitre ni contenu est ignorée ; une compétence hors du ruleset est
  // écartée, une compétence en double garde le DD le plus bas (UK section + compétence).
  $stmt = $db->prepare('SELECT comp_id FROM dd_competences WHERE comp_ruleset_var_id = ?');
  $stmt->execute([$ruleset_id]);
  $comp_valides = array_flip(array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN)));

  $brutes = json_decode((string)($_POST['sections_json'] ?? '[]'), true);
  if (!is_array($brutes)):
    campErreur($is_ajax, 'Sections illisibles.', $redirect);
  endif;
  $sections = [];
  foreach ($brutes as $s):
    if (!is_array($s)) continue;
    $titre_s = mb_substr(trim((string)($s['titre'] ?? '')), 0, 200);
    $texte_s = (string)($s['texte'] ?? '');
    if ($titre_s === '' && texteRicheVide($texte_s)) continue;
    $conds = [];
    foreach ((array)($s['conditions'] ?? []) as $c):
      if (!is_array($c)) continue;
      $cid = (int)($c['comp_id'] ?? 0);
      $dd  = max(1, min(60, (int)($c['dd'] ?? 0)));
      if (!isset($comp_valides[$cid])) continue;
      $conds[$cid] = isset($conds[$cid]) ? min($conds[$cid], $dd) : $dd;
    endforeach;
    $sections[] = ['titre' => $titre_s, 'texte' => $texte_s, 'conditions' => $conds];
  endforeach;

  // Mots-clés : identifiés par leur slug chez le MJ (« Valombre » = « valombre »).
  $tags = [];
  foreach ((array)($_POST['tags'] ?? []) as $t):
    $t    = mb_substr(preg_replace('/\s+/u', ' ', trim((string)$t)), 0, 80);
    $slug = $t !== '' ? _tabSlugify($t) : '';
    if ($slug !== '' && !isset($tags[$slug])) $tags[$slug] = $t;
  endforeach;

  // Destinataires : personnages de la campagne, ou déjà destinataires de la note
  // (un personnage qui a quitté la campagne peut rester destinataire).
  $pe_ids = array_values(array_unique(array_filter(array_map('intval', (array)($_POST['pe_ids'] ?? [])))));
  if ($pe_ids):
    $ph   = implode(',', array_fill(0, count($pe_ids), '?'));
    $stmt = $db->prepare("
      SELECT pe.pe_id FROM dd_personnages pe
       WHERE pe.pe_id IN ($ph)
         AND (EXISTS (SELECT 1 FROM dd_campagnes_personnages cp WHERE cp.cp_pe_id = pe.pe_id AND cp.cp_camp_id = ?)
          OR  EXISTS (SELECT 1 FROM dd_personnages_notes pno WHERE pno.pno_pe_id = pe.pe_id AND pno.pno_no_id = ?))
    ");
    $stmt->execute(array_merge($pe_ids, [$camp_id, $no_id]));
    $pe_ids = array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN));
  endif;

  try {
    $db->beginTransaction();
    $maintenant = date('Y-m-d H:i:s');

    if ($no_id === 0):
      $db->prepare('
        INSERT INTO dd_notes (no_nom, no_camp_id, no_sce_id, no_tyno_id, no_texte, no_j_id, no_date, no_supprime)
        VALUES (?, ?, ?, ?, ?, ?, ?, 0)
      ')->execute([$nom, $camp_id, $sce_id ?: null, $tyno_id, $texte, (int)$_SESSION['j_id'], $date_sql]);
      $no_id = (int)$db->lastInsertId();
    else:
      $db->prepare('
        UPDATE dd_notes SET no_nom = ?, no_sce_id = ?, no_tyno_id = ?, no_texte = ?, no_date = ?, no_date_maj = ?
         WHERE no_id = ?
      ')->execute([$nom, $sce_id ?: null, $tyno_id, $texte, $date_sql, $maintenant, $no_id]);
    endif;

    // Sections et conditions : remplacées en bloc (rien d'autre ne référence noc_id).
    $db->prepare('
      DELETE nocd FROM dd_notes_conditions nocd
        JOIN dd_notes_contenus noc ON noc.noc_id = nocd.nocd_noc_id
       WHERE noc.noc_no_id = ?
    ')->execute([$no_id]);
    $db->prepare('DELETE FROM dd_notes_contenus WHERE noc_no_id = ?')->execute([$no_id]);
    $ins_sec  = $db->prepare('INSERT INTO dd_notes_contenus (noc_no_id, noc_ordre, noc_titre, noc_texte) VALUES (?, ?, ?, ?)');
    $ins_cond = $db->prepare('INSERT INTO dd_notes_conditions (nocd_noc_id, nocd_comp_id, nocd_dd) VALUES (?, ?, ?)');
    foreach ($sections as $rang => $s):
      $ins_sec->execute([$no_id, $rang + 1, $s['titre'] !== '' ? $s['titre'] : null, $s['texte']]);
      $noc_id = (int)$db->lastInsertId();
      foreach ($s['conditions'] as $cid => $dd):
        $ins_cond->execute([$noc_id, $cid, $dd]);
      endforeach;
    endforeach;

    // Mots-clés
    $db->prepare('DELETE FROM dd_notes_tags WHERE notag_no_id = ?')->execute([$no_id]);
    $sel_tag = $db->prepare('SELECT tag_id FROM dd_tags WHERE tag_j_id = ? AND tag_slug = ?');
    $ins_tag = $db->prepare('INSERT INTO dd_tags (tag_nom, tag_slug, tag_j_id, tag_date) VALUES (?, ?, ?, ?)');
    $lien    = $db->prepare('INSERT INTO dd_notes_tags (notag_no_id, notag_tag_id) VALUES (?, ?)');
    foreach ($tags as $slug => $t):
      $sel_tag->execute([(int)$_SESSION['j_id'], $slug]);
      $tag_id = (int)$sel_tag->fetchColumn();
      if (!$tag_id):
        $ins_tag->execute([$t, $slug, (int)$_SESSION['j_id'], $maintenant]);
        $tag_id = (int)$db->lastInsertId();
      endif;
      $lien->execute([$no_id, $tag_id]);
    endforeach;

    // Destinataires
    if ($pe_ids):
      $ph = implode(',', array_fill(0, count($pe_ids), '?'));
      $db->prepare("DELETE FROM dd_personnages_notes WHERE pno_no_id = ? AND pno_pe_id NOT IN ($ph)")
         ->execute(array_merge([$no_id], $pe_ids));
    else:
      $db->prepare('DELETE FROM dd_personnages_notes WHERE pno_no_id = ?')->execute([$no_id]);
    endif;
    if ($signaler):
      $db->prepare('UPDATE dd_personnages_notes SET pno_lu_date = NULL WHERE pno_no_id = ?')->execute([$no_id]);
    endif;
    $ins_pno = $db->prepare('INSERT IGNORE INTO dd_personnages_notes (pno_no_id, pno_pe_id, pno_date) VALUES (?, ?, ?)');
    foreach ($pe_ids as $pe_id):
      $ins_pno->execute([$no_id, $pe_id, $maintenant]);
    endforeach;

    $db->commit();
    if ($is_ajax):
      header('Content-Type: application/json');
      echo json_encode(['ok' => true, 'id' => $no_id, 'camp_id' => $camp_id]);
      exit;
    endif;
    $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Note enregistrée.'];
    header('Location: ' . $redirect);
    exit;

  } catch (Exception $e) {
    if ($db->inTransaction()) $db->rollBack();
    error_log('enregistrerNote : ' . $e->getMessage());
    campErreur($is_ajax, 'Erreur base de données.', $redirect);
  }
}

// ============================================================
// NOTES — Suppression douce (SP-NO2)
// Les destinataires ne la voient plus (getNotesPersonnage() filtre no_supprime).
// ============================================================

function supprimerNote(PDO $db, bool $is_ajax, string $redirect): void
{
  $no_id = intParam($_POST['id'] ?? 0);

  $stmt = $db->prepare('SELECT no_camp_id FROM dd_notes WHERE no_id = ? AND no_supprime = 0');
  $stmt->execute([$no_id]);
  $camp_id = (int)$stmt->fetchColumn();
  if (!$camp_id || !isMJ($db, $camp_id)):
    campErreur($is_ajax, 'Accès refusé.', $redirect);
  endif;

  softDeleteIds($db, 'dd_notes', 'no_supprime', 'no_date_supprime', 'no_id', [$no_id]);

  if ($is_ajax):
    header('Content-Type: application/json');
    echo json_encode(['ok' => true, 'id' => $no_id, 'camp_id' => $camp_id]);
    exit;
  endif;
  $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Note supprimée.'];
  header('Location: ' . $redirect);
  exit;
}
