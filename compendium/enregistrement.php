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

function repondreOk(bool $is_ajax, int $id, string $entite, string $redirect_url): void
{
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

function repondreErreur(bool $is_ajax, string $message, string $redirect_url): void
{
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

  case 'competence':
    switch ($action):
      case 'sauvegarder':
        enregistrerCompetence($db, $is_ajax, $redirect);
        break;
      case 'supprimer':
        supprimerEntite($db, 'dd_competences', 'comp_id', $is_ajax, $redirect);
        break;
      case 'bulk_supprimer':
        supprimerEntite($db, 'dd_competences', 'comp_id', $is_ajax, $redirect);
        break;
      default:
        repondreErreur($is_ajax, 'Action inconnue.', $redirect);
    endswitch;
    break;

  case 'don':
    switch ($action):
      case 'sauvegarder':
        enregistrerDon($db, $is_ajax, $redirect);
        break;
      case 'supprimer':
        supprimerEntite($db, 'dd_dons', 'do_id', $is_ajax, $redirect);
        break;
      case 'bulk_supprimer':
        supprimerEntite($db, 'dd_dons', 'do_id', $is_ajax, $redirect);
        break;
      default:
        repondreErreur($is_ajax, 'Action inconnue.', $redirect);
    endswitch;
    break;

  case 'sort':
    switch ($action):
      case 'sauvegarder':
        enregistrerSort($db, $is_ajax, $redirect);
        break;
      case 'supprimer':
        supprimerSort($db, $is_ajax, $redirect);
        break;
      case 'bulk_supprimer':
        bulkSupprimerSorts($db, $redirect);
        break;
      default:
        repondreErreur($is_ajax, 'Action inconnue.', $redirect);
    endswitch;
    break;


  case 'race':
    switch ($action):
      case 'sauvegarder':
        enregistrerRace($db, $is_ajax, $redirect);
        break;
      case 'supprimer':
        supprimerRace($db, $is_ajax, $redirect);
        break;
      case 'bulk_supprimer':
        bulkSupprimerRaces($db, $is_ajax, $redirect);
        break;
      default:
        repondreErreur($is_ajax, 'Action inconnue.', $redirect);
    endswitch;
    break;

  default:
    repondreErreur($is_ajax, 'Entité inconnue : ' . h($entite), $redirect);

endswitch;


// ============================================================
// DON — Enregistrement
// ============================================================

function enregistrerDon($db, bool $is_ajax, string $redirect): void
{
  $do_id      = intParam($_POST['do_id']             ?? 0);
  $nom        = strParam($_POST['do_nom']            ?? '');
  $ruleset_id = intParam($_POST['do_ruleset_var_id'] ?? 1);

  if (!$nom):
    repondreErreur($is_ajax, 'Le nom du don est obligatoire.', $redirect);
  endif;

  $res_id = intParam($_POST['do_res_id'] ?? 0);
  if (!$res_id):
    repondreErreur($is_ajax, 'La source est obligatoire.', $redirect);
  endif;

  $dado_id    = intParam($_POST['do_dado_id']  ?? 0) ?: null;
  $camp_id    = intParam($_POST['do_camp_id']  ?? 0) ?: null;
  $conditions = strParam($_POST['do_conditions'] ?? '');
  $resume     = strParam($_POST['do_resume']   ?? '');
  $texte      = $_POST['do_texte'] ?? '';   // HTML TinyMCE

  try {
    $db->beginTransaction();

    if ($do_id === 0):
      $stmt = $db->prepare('
        INSERT INTO dd_dons
          (do_nom, do_dado_id, do_conditions, do_texte, do_resume,
           do_res_id, do_camp_id, do_ruleset_var_id)
        VALUES (?,?,?,?,?,?,?,?)
      ');
      $stmt->execute([
        $nom,
        $dado_id,
        $conditions,
        $texte,
        $resume,
        $res_id,
        $camp_id,
        $ruleset_id
      ]);
      $do_id = (int)$db->lastInsertId();
    else:
      $stmt = $db->prepare('
        UPDATE dd_dons SET
          do_nom            = ?,
          do_dado_id        = ?,
          do_conditions     = ?,
          do_texte          = ?,
          do_resume         = ?,
          do_res_id         = ?,
          do_camp_id        = ?,
          do_ruleset_var_id = ?
        WHERE do_id = ?
      ');
      $stmt->execute([
        $nom,
        $dado_id,
        $conditions,
        $texte,
        $resume,
        $res_id,
        $camp_id,
        $ruleset_id,
        $do_id
      ]);
    endif;

    $db->commit();
    repondreOk($is_ajax, $do_id, 'don', $redirect);
  } catch (Exception $e) {
    $db->rollBack();
    error_log('enregistrerDon : ' . $e->getMessage());
    repondreErreur($is_ajax, 'Erreur base de données.', $redirect);
  }
}

// ============================================================
// ENTITÉ GÉNÉRIQUE — Suppression (sorts, dons, et futurs)
// ============================================================

function supprimerEntite($db, string $table, string $champ_id, bool $is_ajax, string $redirect): void
{
  $ids = $_POST['ids'] ?? [];
  if (!empty($_POST['id'])) $ids[] = $_POST['id'];
  $ids = array_filter(array_map('intval', (array)$ids));

  if (empty($ids)):
    repondreErreur($is_ajax, 'Aucun élément à supprimer.', $redirect);
  endif;

  try {
    $db->beginTransaction();
    $ph   = implode(',', array_fill(0, count($ids), '?'));
    $stmt = $db->prepare("DELETE FROM $table WHERE $champ_id IN ($ph)");
    $stmt->execute($ids);
    $db->commit();

    if ($is_ajax):
      header('Content-Type: application/json');
      echo json_encode(['ok' => true, 'id' => 0, 'url_detail' => '']);
      exit;
    endif;
    $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Élément(s) supprimé(s).'];
    header('Location: ' . $redirect);
    exit;
  } catch (Exception $e) {
    $db->rollBack();
    error_log('supprimerEntite : ' . $e->getMessage());
    repondreErreur($is_ajax, 'Erreur lors de la suppression.', $redirect);
  }
}

// ============================================================
// SORT — Enregistrement
// ============================================================

function enregistrerSort($db, bool $is_ajax, string $redirect): void
{
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
  $composante = strParam($_POST['so_composante']        ?? '');
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
  $resistance = strParam($_POST['so_resistance']       ?? '');
  $resume    = strParam($_POST['so_resume']           ?? '');
  $focalis   = isset($_POST['so_focalisateur'])       ? 1 : 0;
  $focalis_d = isset($_POST['so_focalisateur_divin']) ? 1 : 0;

  // Champs DD2024
  $niveau    = intParam($_POST['so_niveau'] ?? 0);

  // Associations classes et domaines
  $niveaux_classes  = $_POST['niveaux_classes']  ?? [];
  $niveaux_domaines = $_POST['niveaux_domaines'] ?? [];

  try {
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
        $nom,
        $co_id,
        $branche,
        $vocal,
        $gestuel,
        $materiel,
        $focalis,
        $focalis_d,
        $composante,
        $portee,
        $cible,
        $zone,
        $dur_inc,
        $dur_sort,
        $jet_save,
        $resistance,
        $niveau,
        $resume,
        $description,
        $res_id,
        $camp_id,
        $ruleset_id,
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
        $nom,
        $co_id,
        $branche,
        $vocal,
        $gestuel,
        $materiel,
        $focalis,
        $focalis_d,
        $composante,
        $portee,
        $cible,
        $zone,
        $dur_inc,
        $dur_sort,
        $jet_save,
        $resistance,
        $niveau,
        $resume,
        $description,
        $res_id,
        $camp_id,
        $ruleset_id,
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
  } catch (Exception $e) {
    $db->rollBack();
    error_log('enregistrerSort : ' . $e->getMessage());
    repondreErreur($is_ajax, 'Erreur base de données.', $redirect);
  }
}

// ============================================================
// SORT — Suppression individuelle
// ============================================================

function supprimerSort($db, bool $is_ajax, string $redirect): void
{
  $ids = $_POST['ids'] ?? [];
  if (!empty($_POST['id'])) $ids[] = $_POST['id'];
  $ids = array_map('intval', (array)$ids);
  $ids = array_filter($ids);

  if (empty($ids)):
    repondreErreur($is_ajax, 'Aucun sort à supprimer.', $redirect);
  endif;

  try {
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
  } catch (Exception $e) {
    $db->rollBack();
    error_log('supprimerSort : ' . $e->getMessage());
    repondreErreur($is_ajax, 'Erreur lors de la suppression.', $redirect);
  }
}

// ============================================================
// SORT — Suppression groupée (bulk)
// ============================================================

function bulkSupprimerSorts($db, string $redirect): void
{
  // Réutilise la suppression individuelle en mode non-AJAX
  supprimerSort($db, false, $redirect);
}


// ============================================================
// COMPÉTENCE — Enregistrement
// ============================================================

function enregistrerCompetence($db, bool $is_ajax, string $redirect): void
{
  $comp_id    = intParam($_POST['comp_id']             ?? 0);
  $nom        = strParam($_POST['comp_nom']            ?? '');
  $ruleset_id = intParam($_POST['comp_ruleset_var_id'] ?? 1);

  if (!$nom):
    repondreErreur($is_ajax, 'Le nom de la compétence est obligatoire.', $redirect);
  endif;

  $res_id = intParam($_POST['comp_res_id'] ?? 0);
  if (!$res_id):
    repondreErreur($is_ajax, 'La source est obligatoire.', $redirect);
  endif;

  $car_id      = intParam($_POST['comp_car_id']      ?? 0);
  if (!$car_id):
    repondreErreur($is_ajax, 'La caractéristique est obligatoire.', $redirect);
  endif;

  $formation   = isset($_POST['comp_formation'])  ? 1 : 0;
  $malusArmure = intParam($_POST['comp_malusArmure'] ?? 0);
  $description = $_POST['comp_description'] ?? '';   // HTML TinyMCE — pas de h()

  try {
    $db->beginTransaction();

    if ($comp_id === 0):
      $stmt = $db->prepare('
        INSERT INTO dd_competences
          (comp_nom, comp_car_id, comp_formation, comp_malusArmure,
           comp_description, comp_res_id, comp_ruleset_var_id)
        VALUES (?,?,?,?,?,?,?)
      ');
      $stmt->execute([
        $nom,
        $car_id,
        $formation,
        $malusArmure,
        $description,
        $res_id,
        $ruleset_id,
      ]);
      $comp_id = (int)$db->lastInsertId();
    else:
      $stmt = $db->prepare('
        UPDATE dd_competences SET
          comp_nom            = ?,
          comp_car_id         = ?,
          comp_formation      = ?,
          comp_malusArmure    = ?,
          comp_description    = ?,
          comp_res_id         = ?,
          comp_ruleset_var_id = ?
        WHERE comp_id = ?
      ');
      $stmt->execute([
        $nom,
        $car_id,
        $formation,
        $malusArmure,
        $description,
        $res_id,
        $ruleset_id,
        $comp_id,
      ]);
    endif;

    $db->commit();
    repondreOk($is_ajax, $comp_id, 'competence', $redirect);
  } catch (Exception $e) {
    $db->rollBack();
    error_log('enregistrerCompetence : ' . $e->getMessage());
    repondreErreur($is_ajax, 'Erreur base de données.', $redirect);
  }
}

// ============================================================
// RACE — Enregistrement (création + modification)
// ============================================================

function enregistrerRace($db, bool $is_ajax, string $redirect): void
{
  $ra_id      = intParam($_POST['ra_id']             ?? 0);
  $nom        = strParam($_POST['ra_nom']            ?? '');
  $ruleset_id = intParam($_POST['ra_ruleset_var_id'] ?? 1);

  if (!$nom):
    repondreErreur($is_ajax, 'Le nom de la race est obligatoire.', $redirect);
  endif;

  $res_id = intParam($_POST['ra_res_id'] ?? 0);
  if (!$res_id):
    repondreErreur($is_ajax, 'La source est obligatoire.', $redirect);
  endif;

  $rat_id      = intParam($_POST['ra_rat_id']      ?? 0) ?: null;
  $mod_niveau  = intParam($_POST['ra_mod_niveau']   ?? 0);
  $camp_id     = intParam($_POST['ra_camp_id']      ?? 0) ?: null;
  $description = $_POST['ra_description'] ?? '';   // HTML TinyMCE — pas de h()

  // Payload capacités
  $payload_raw = $_POST['capacites_payload'] ?? '[]';
  $payload     = json_decode($payload_raw, true);
  if (!is_array($payload)) $payload = [];

  try {
    $db->beginTransaction();

    // ---- INSERT ou UPDATE dd_races ----
    if ($ra_id === 0):
      $stmt = $db->prepare('
        INSERT INTO dd_races
          (ra_nom, ra_rat_id, ra_description, ra_mod_niveau,
           ra_res_id, ra_camp_id, ra_ruleset_var_id)
        VALUES (?,?,?,?,?,?,?)
      ');
      $stmt->execute([
        $nom,
        $rat_id,
        $description,
        $mod_niveau,
        $res_id,
        $camp_id,
        $ruleset_id,
      ]);
      $ra_id = (int)$db->lastInsertId();
    else:
      $stmt = $db->prepare('
        UPDATE dd_races SET
          ra_nom            = ?,
          ra_rat_id         = ?,
          ra_description    = ?,
          ra_mod_niveau     = ?,
          ra_res_id         = ?,
          ra_camp_id        = ?,
          ra_ruleset_var_id = ?
        WHERE ra_id = ?
      ');
      $stmt->execute([
        $nom,
        $rat_id,
        $description,
        $mod_niveau,
        $res_id,
        $camp_id,
        $ruleset_id,
        $ra_id,
      ]);
    endif;

    // ---- Traitement du payload capacités ----
    $stmt_ins_cap = $db->prepare('
      INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type)
      VALUES (?,?,?)
    ');
    $stmt_ins_lien = $db->prepare('
      INSERT INTO dd_race_capacite (cr_ra_id, cr_cap_id, cr_ordre)
      VALUES (?,?,?)
    ');
    $stmt_upd_ordre = $db->prepare('
      UPDATE dd_race_capacite
      SET    cr_ordre = ?
      WHERE  cr_ra_id = ? AND cr_cap_id = ?
    ');
    $stmt_upd_cap = $db->prepare('
      UPDATE dd_capacites_speciales SET
        cap_nom         = ?,
        cap_description = ?,
        cap_type        = ?
      WHERE cap_id = ?
    ');
    $stmt_del_lien = $db->prepare('
      DELETE FROM dd_race_capacite
      WHERE  cr_ra_id = ? AND cr_cap_id = ?
    ');

    foreach ($payload as $item):
      $action = $item['action'] ?? '';

      if ($action === 'new'):
        $cap_nom  = strParam($item['cap_nom']         ?? '');
        $cap_desc = $item['cap_description']           ?? '';
        $cap_type = strParam($item['cap_type']         ?? '');
        $cr_ordre = intParam($item['cr_ordre']         ?? 0);

        if (!$cap_nom) continue;

        $stmt_ins_cap->execute([$cap_nom, $cap_desc, $cap_type]);
        $new_cap_id = (int)$db->lastInsertId();
        $stmt_ins_lien->execute([$ra_id, $new_cap_id, $cr_ordre]);

      elseif ($action === 'existing'):
        $cap_id   = intParam($item['cap_id']  ?? 0);
        $cr_ordre = intParam($item['cr_ordre'] ?? 0);
        if (!$cap_id) continue;
        $stmt_upd_ordre->execute([$cr_ordre, $ra_id, $cap_id]);

      elseif ($action === 'update'):
        // Modification du contenu d'une capacité existante (nom, description, type)
        // + mise à jour de cr_ordre
        $cap_id   = intParam($item['cap_id']           ?? 0);
        $cap_nom  = strParam($item['cap_nom']           ?? '');
        $cap_desc = $item['cap_description']             ?? '';
        $cap_type = strParam($item['cap_type']           ?? '');
        $cr_ordre = intParam($item['cr_ordre']           ?? 0);
        if (!$cap_id || !$cap_nom) continue;
        $stmt_upd_cap->execute([$cap_nom, $cap_desc, $cap_type, $cap_id]);
        $stmt_upd_ordre->execute([$cr_ordre, $ra_id, $cap_id]);

      elseif ($action === 'delete'):
        $cap_id = intParam($item['cap_id'] ?? 0);
        if (!$cap_id) continue;
        $stmt_del_lien->execute([$ra_id, $cap_id]);

      endif;
    endforeach;

    $db->commit();
    repondreOk($is_ajax, $ra_id, 'race', $redirect);
  } catch (Exception $e) {
    $db->rollBack();
    error_log('enregistrerRace : ' . $e->getMessage());
    repondreErreur($is_ajax, 'Erreur base de données.', $redirect);
  }
}


// ============================================================
// RACE — Suppression individuelle (avec vérification dépendances)
// ============================================================

function supprimerRace($db, bool $is_ajax, string $redirect): void
{
  $ids = $_POST['ids'] ?? [];
  if (!empty($_POST['id'])) $ids[] = $_POST['id'];
  $ids = array_filter(array_map('intval', (array)$ids));

  if (empty($ids)):
    repondreErreur($is_ajax, 'Aucune race à supprimer.', $redirect);
  endif;

  $refus   = [];
  $ok_ids  = [];

  foreach ($ids as $ra_id):
    // Vérification dépendances personnages (race de base ET archétype)
    $stmt = $db->prepare('
      SELECT COUNT(*) FROM dd_personnages
      WHERE pe_ra_id = ? OR pe_arc_id = ?
    ');
    $stmt->execute([$ra_id, $ra_id]);
    $nb_perso = (int)$stmt->fetchColumn();

    if ($nb_perso > 0):
      // Récupérer le nom pour le message
      $stmt_nom = $db->prepare('SELECT ra_nom FROM dd_races WHERE ra_id = ?');
      $stmt_nom->execute([$ra_id]);
      $ra_nom = $stmt_nom->fetchColumn() ?: "race #$ra_id";
      $refus[] = "« $ra_nom » : $nb_perso personnage(s) associé(s)";
    else:
      $ok_ids[] = $ra_id;
    endif;
  endforeach;

  // Suppression des races sans dépendances
  if (!empty($ok_ids)):
    try {
      $db->beginTransaction();
      foreach ($ok_ids as $ra_id):
        $db->prepare('DELETE FROM dd_race_capacite WHERE cr_ra_id = ?')->execute([$ra_id]);
        $db->prepare('DELETE FROM dd_races          WHERE ra_id   = ?')->execute([$ra_id]);
      endforeach;
      $db->commit();
    } catch (Exception $e) {
      $db->rollBack();
      error_log('supprimerRace : ' . $e->getMessage());
      repondreErreur($is_ajax, 'Erreur lors de la suppression.', $redirect);
    }
  endif;

  // Construction du message de retour
  if (empty($refus)):
    if ($is_ajax):
      header('Content-Type: application/json');
      echo json_encode(['ok' => true, 'id' => 0, 'url_detail' => '']);
      exit;
    endif;
    $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Race(s) supprimée(s).'];
    header('Location: ' . $redirect);
    exit;
  endif;

  // Refus partiel ou total
  $msg_refus = 'Suppression impossible pour : ' . implode(' ; ', $refus) . '.';
  if (!empty($ok_ids)):
    $msg_refus = count($ok_ids) . ' race(s) supprimée(s). ' . $msg_refus;
  endif;

  repondreErreur($is_ajax, $msg_refus, $redirect);
}


// ============================================================
// RACE — Suppression groupée (bulk)
// ============================================================

function bulkSupprimerRaces($db, bool $is_ajax, string $redirect): void
{
  supprimerRace($db, $is_ajax, $redirect);
}
