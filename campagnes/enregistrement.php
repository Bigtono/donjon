<?php
// campagnes/enregistrement.php — Point d'entrée unique des écritures du module Campagnes.
//
// GET ajax=1 → retourne JSON {ok, id, url_detail, erreur}
// Sinon      → redirige avec flash message SESSION
//
// POST requis :
//   action — 'enregistrerCampagne' | 'supprimerCampagne' (autres actions ajoutées en SP2+)

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

  default:
    campErreur($is_ajax, 'Action inconnue.', $redirect);

endswitch;

// ============================================================
// CAMPAGNE — Sauvegarde (création ou modification)
// ============================================================

function enregistrerCampagne($db, bool $is_ajax, string $redirect): void
{
  $camp_id     = intParam($_POST['camp_id'] ?? 0);
  $nom         = strParam($_POST['camp_nom'] ?? '');
  $resume      = strParam($_POST['camp_resume'] ?? '');
  $description = $_POST['camp_description'] ?? ''; // HTML TinyMCE
  $un_id       = intParam($_POST['camp_un_id'] ?? 0);
  $ruleset_id  = intParam($_POST['camp_ruleset_var_id'] ?? 0);
  $j_id        = (int)$_SESSION['j_id'];

  if (!$nom):
    campErreur($is_ajax, 'Le nom de la campagne est obligatoire.', $redirect);
  endif;

  // Univers : null si non choisi, sinon doit être accessible (mien ou public).
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
      // ---- CRÉATION ----
      // Validation du ruleset (catégorie insensible à la casse côté MySQL).
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
      // ---- MODIFICATION ----
      if (!isMJ($db, $camp_id)):
        $db->rollBack();
        campErreur($is_ajax, 'Accès refusé.', $redirect);
      endif;

      // Le ruleset (maître) n'est jamais modifié ici.
      $stmt = $db->prepare('
        UPDATE dd_campagnes SET
          camp_nom         = ?,
          camp_un_id       = ?,
          camp_resume      = ?,
          camp_description = ?
        WHERE camp_id = ?
      ');
      $stmt->execute([$nom, $un_id_final, $resume, $description, $camp_id]);

      // ---- Sources : remplacement complet (DELETE puis INSERT des cochées) ----
      // On ne garde que les ressources réellement du ruleset de la campagne.
      $sources = array_filter(array_map('intval', (array)($_POST['sources'] ?? [])));

      $db->prepare('DELETE FROM dd_campagnes_sources WHERE cs_camp_id = ?')->execute([$camp_id]);

      if (!empty($sources)):
        // Récupère le ruleset de la campagne pour valider les sources.
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
    $url_detail = BASE_URL . '/include/ajax/detail-pp/campagne.php';
    campOk($is_ajax, $camp_id, $redirect, $url_detail);

  } catch (Exception $e) {
    if ($db->inTransaction()) $db->rollBack();
    error_log('enregistrerCampagne : ' . $e->getMessage());
    campErreur($is_ajax, 'Erreur base de données.', $redirect);
  }
}

// ============================================================
// CAMPAGNE — Suppression douce en cascade
// ============================================================
// Cascade : campagne → scénarios → chapitres → rencontres → oppositions.
// + fichiers PDF (unlink physique, option A) ; + SET NULL pe_camp_id ;
// + DELETE physique des lignes de liaison sans contenu propre.

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

    // ---- Récupération des IDs de la hiérarchie ----
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

    // ---- Fichiers PDF physiques : unlink puis marquage ----
    supprimerFichiers($db, 'campagne', [$camp_id]);
    if (!empty($sce_ids)) supprimerFichiers($db, 'scenario', $sce_ids);
    if (!empty($re_ids))  supprimerFichiers($db, 'rencontre', $re_ids);

    // ---- Soft delete descendant ----
    $now = date('Y-m-d H:i:s');

    if (!empty($re_ids)):
      $ph = implode(',', array_fill(0, count($re_ids), '?'));
      $db->prepare("UPDATE dd_oppositions SET opp_supprime = 1, opp_date_supprime = ?
                    WHERE opp_re_id IN ($ph)")->execute(array_merge([$now], $re_ids));
      $db->prepare("UPDATE dd_rencontres SET re_supprime = 1, re_date_supprime = ?
                    WHERE re_id IN ($ph)")->execute(array_merge([$now], $re_ids));
    endif;
    if (!empty($scc_ids)):
      $ph = implode(',', array_fill(0, count($scc_ids), '?'));
      $db->prepare("UPDATE dd_scenarios_chapitres SET scc_supprime = 1, scc_date_supprime = ?
                    WHERE scc_id IN ($ph)")->execute(array_merge([$now], $scc_ids));
    endif;
    if (!empty($sce_ids)):
      $ph = implode(',', array_fill(0, count($sce_ids), '?'));
      $db->prepare("UPDATE dd_scenarios SET sce_supprime = 1, sce_date_supprime = ?
                    WHERE sce_id IN ($ph)")->execute(array_merge([$now], $sce_ids));
    endif;

    // ---- Campagne elle-même ----
    $db->prepare('UPDATE dd_campagnes SET camp_supprime = 1, camp_date_supprime = ? WHERE camp_id = ?')
       ->execute([$now, $camp_id]);

    // ---- Transverses ----
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
// Utilitaires internes
// ============================================================

// Retourne un tableau d'entiers depuis une requête mono-colonne.
function colIds($db, string $sql, array $params): array
{
  $stmt = $db->prepare($sql);
  $stmt->execute($params);
  return array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN));
}

// unlink() des PDF d'une entité puis marquage fi_supprime (option A).
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

  $racine = realpath(__DIR__ . '/..'); // racine du projet (donjon/)
  foreach ($fichiers as $f):
    $chemin = $racine . '/' . ltrim($f['fi_chemin'], '/');
    if (is_file($chemin)) @unlink($chemin);
  endforeach;

  $now    = date('Y-m-d H:i:s');
  $ids    = array_map(fn($f) => (int)$f['fi_id'], $fichiers);
  $phIds  = implode(',', array_fill(0, count($ids), '?'));
  $db->prepare("UPDATE dd_fichiers SET fi_supprime = 1, fi_date_supprime = ? WHERE fi_id IN ($phIds)")
     ->execute(array_merge([$now], $ids));
}
