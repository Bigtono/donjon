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

  case 'classe':
    switch ($action):
      case 'sauvegarder':
        enregistrerClasse($db, $is_ajax, $redirect);
        break;
      case 'supprimer':
        supprimerClasse($db, $is_ajax, $redirect);
        break;
      case 'bulk_supprimer':
        bulkSupprimerClasses($db, $is_ajax, $redirect);
        break;
      default:
        repondreErreur($is_ajax, 'Action inconnue.', $redirect);
    endswitch;
    break;

  case 'objet':
    switch ($action):
      case 'sauvegarder':
        enregistrerObjet($db, $is_ajax, $redirect);
        break;
      case 'supprimer':
      case 'bulk_supprimer':
        supprimerEntite($db, 'dd_objets_magiques', 'om_id', $is_ajax, $redirect);
        break;
      default:
        repondreErreur($is_ajax, 'Action inconnue.', $redirect);
    endswitch;
    break;

  case 'monstre':
    switch ($action):
      case 'sauvegarder':
        enregistrerMonstre($db, $is_ajax, $redirect);
        break;
      case 'supprimer':
      case 'bulk_supprimer':
        supprimerEntite($db, 'dd_monstres', 'mo_id', $is_ajax, $redirect);
        break;
      default:
        repondreErreur($is_ajax, 'Action inconnue.', $redirect);
    endswitch;
    break;

  case 'historique':
    switch ($action):
      case 'sauvegarder':
        enregistrerHistorique($db, $is_ajax, $redirect);
        break;
      case 'supprimer':
      case 'bulk_supprimer':
        supprimerEntite($db, 'dd_historiques', 'hi_id', $is_ajax, $redirect);
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

// ============================================================
// CLASSE — Enregistrement (création + modification)
// ============================================================

function enregistrerClasse($db, bool $is_ajax, string $redirect): void
{
  $cla_id     = intParam($_POST['cla_id']             ?? 0);
  $nom        = strParam($_POST['cla_nom']             ?? '');
  $ruleset_id = intParam($_POST['cla_ruleset_var_id']  ?? 1);

  if (!$nom):
    repondreErreur($is_ajax, 'Le nom de la classe est obligatoire.', $redirect);
  endif;

  $res_id = intParam($_POST['cla_res_id'] ?? 0);
  if (!$res_id):
    repondreErreur($is_ajax, 'La source est obligatoire.', $redirect);
  endif;

  // Champs scalaires
  $clt_id      = intParam($_POST['cla_clt_id']          ?? 1);
  $estSousClasse = ($clt_id === 5); // clt_id=5 → 'Sous-classe' (DD2024)
  $cla_cla_id  = $estSousClasse ? intParam($_POST['cla_cla_id'] ?? 0) : null;

  if ($estSousClasse && !$cla_cla_id):
    repondreErreur($is_ajax, 'La classe parente est obligatoire pour une sous-classe.', $redirect);
  endif;

  $dV          = intParam($_POST['cla_dV']              ?? 8);
  $niveauMax   = intParam($_POST['cla_niveauMax']       ?? 20);
  $mag_id      = intParam($_POST['cla_mag_id']          ?? 0);
  $car_id      = intParam($_POST['cla_car_id']          ?? 0);
  $camp_id     = intParam($_POST['cla_camp_id']         ?? 0) ?: null;
  $abreviation = strParam($_POST['cla_abreviation']     ?? '');
  $alignement  = strParam($_POST['cla_alignement']      ?? '');
  $ptsComp     = intParam($_POST['cla_pointsCompetences'] ?? 0);
  $poNiv1      = intParam($_POST['cla_po_niveau1']      ?? 0);

  // Flags booléens (checkboxes — absent = 0)
  $sortConnu    = isset($_POST['cla_sort_connu'])    ? 1 : 0;
  $sortCompris  = isset($_POST['cla_sort_compris'])  ? 1 : 0;
  $sortPrepare  = isset($_POST['cla_sort_prepare'])  ? 1 : 0;
  $domaineDivin = isset($_POST['cla_domaine_divin']) ? 1 : 0;

  // Champs texte TinyMCE (HTML — pas de h())
  $description    = $_POST['cla_description']    ?? '';
  $armes          = $_POST['cla_armes']          ?? '';
  $armures        = $_POST['cla_armures']        ?? '';
  $outils         = $_POST['cla_outils']         ?? '';
  $sauvegardes    = $_POST['cla_sauvegardes']    ?? '';
  $equipement     = $_POST['cla_equipement']     ?? '';
  $competences    = $_POST['cla_competences']    ?? '';
  $sorts          = $_POST['cla_sorts']          ?? '';
  $conditions     = $_POST['cla_conditions']     ?? '';
  $caracteristiques = $_POST['cla_caracteristiques'] ?? '';
  $traits         = $_POST['cla_traits']         ?? '';
  $critere_rec    = $_POST['cla_critere_rec']    ?? '';

  // Intitulés des pouvoirs 1-5
  $pouvoirs = [];
  for ($p = 1; $p <= 5; $p++):
    $pouvoirs[$p] = strParam($_POST['cla_pouvoir' . $p] ?? '');
  endfor;

  // Sous-classe (DD2024) : seuls nom/source/classe parente/capacités spéciales sont
  // pertinents. On neutralise les champs "classe normale" pour ne pas laisser de
  // données résiduelles en base, qu'ils aient été soumis ou non par le formulaire.
  if ($estSousClasse):
    $mag_id           = 0;
    $car_id           = 0;
    $alignement       = '';
    $ptsComp          = 0;
    $poNiv1           = 0;
    $sortConnu        = 0;
    $sortCompris      = 0;
    $sortPrepare      = 0;
    $domaineDivin     = 0;
    $armes            = '';
    $armures          = '';
    $outils           = '';
    $sauvegardes      = '';
    $equipement       = '';
    $competences      = '';
    $sorts            = '';
    $conditions       = '';
    $caracteristiques = '';
    $traits           = '';
    $critere_rec      = '';
    for ($p = 1; $p <= 5; $p++):
      $pouvoirs[$p] = '';
    endfor;
  endif;

  // Payloads capacités
  $capacites_payload    = json_decode($_POST['capacites_payload']    ?? '[]', true) ?: [];
  $affectations_payload = json_decode($_POST['affectations_payload'] ?? '[]', true) ?: [];
  $payload_ready        = ($_POST['payload_ready'] ?? '0') === '1';

  try {
    $db->beginTransaction();

    // ---- 1. INSERT ou UPDATE dd_classes ----

    $params = [
      ':cla_nom'              => $nom,
      ':cla_abreviation'      => $abreviation,
      ':cla_clt_id'           => $clt_id,
      ':cla_dV'               => $dV,
      ':cla_niveauMax'        => $niveauMax,
      ':cla_mag_id'           => $mag_id,
      ':cla_car_id'           => $car_id,
      ':cla_sort_connu'       => $sortConnu,
      ':cla_sort_compris'     => $sortCompris,
      ':cla_sort_prepare'     => $sortPrepare,
      ':cla_domaine_divin'    => $domaineDivin,
      ':cla_pointsCompetences' => $ptsComp,
      ':cla_po_niveau1'       => $poNiv1,
      ':cla_alignement'       => $alignement,
      ':cla_conditions'       => $conditions,
      ':cla_description'      => $description,
      ':cla_armes'            => $armes,
      ':cla_armures'          => $armures,
      ':cla_outils'           => $outils,
      ':cla_sauvegardes'      => $sauvegardes,
      ':cla_equipement'       => $equipement,
      ':cla_competences'      => $competences,
      ':cla_sorts'            => $sorts,
      ':cla_caracteristiques' => $caracteristiques,
      ':cla_traits'           => $traits,
      ':cla_critere_rec'      => $critere_rec,
      ':cla_pouvoir1'         => $pouvoirs[1],
      ':cla_pouvoir2'         => $pouvoirs[2],
      ':cla_pouvoir3'         => $pouvoirs[3],
      ':cla_pouvoir4'         => $pouvoirs[4],
      ':cla_pouvoir5'         => $pouvoirs[5],
      ':cla_res_id'           => $res_id,
      ':cla_camp_id'          => $camp_id,
      ':cla_cla_id'           => $cla_cla_id,
    ];

    if ($cla_id === 0):
      $params[':cla_ruleset_var_id'] = $ruleset_id;
      $stmt = $db->prepare('
        INSERT INTO dd_classes (
          cla_nom, cla_abreviation, cla_clt_id, cla_dV, cla_niveauMax,
          cla_mag_id, cla_car_id, cla_sort_connu, cla_sort_compris, cla_sort_prepare,
          cla_domaine_divin, cla_pointsCompetences, cla_po_niveau1, cla_alignement,
          cla_conditions, cla_description, cla_armes, cla_armures, cla_outils,
          cla_sauvegardes, cla_equipement, cla_competences, cla_sorts,
          cla_caracteristiques, cla_traits, cla_critere_rec,
          cla_pouvoir1, cla_pouvoir2, cla_pouvoir3, cla_pouvoir4, cla_pouvoir5,
          cla_res_id, cla_camp_id, cla_cla_id, cla_ruleset_var_id
        ) VALUES (
          :cla_nom, :cla_abreviation, :cla_clt_id, :cla_dV, :cla_niveauMax,
          :cla_mag_id, :cla_car_id, :cla_sort_connu, :cla_sort_compris, :cla_sort_prepare,
          :cla_domaine_divin, :cla_pointsCompetences, :cla_po_niveau1, :cla_alignement,
          :cla_conditions, :cla_description, :cla_armes, :cla_armures, :cla_outils,
          :cla_sauvegardes, :cla_equipement, :cla_competences, :cla_sorts,
          :cla_caracteristiques, :cla_traits, :cla_critere_rec,
          :cla_pouvoir1, :cla_pouvoir2, :cla_pouvoir3, :cla_pouvoir4, :cla_pouvoir5,
          :cla_res_id, :cla_camp_id, :cla_cla_id, :cla_ruleset_var_id
        )
      ');
      $stmt->execute($params);
      $cla_id = (int)$db->lastInsertId();
    else:
      $params[':cla_id'] = $cla_id;
      $stmt = $db->prepare('
        UPDATE dd_classes SET
          cla_nom              = :cla_nom,
          cla_abreviation      = :cla_abreviation,
          cla_clt_id           = :cla_clt_id,
          cla_dV               = :cla_dV,
          cla_niveauMax        = :cla_niveauMax,
          cla_mag_id           = :cla_mag_id,
          cla_car_id           = :cla_car_id,
          cla_sort_connu       = :cla_sort_connu,
          cla_sort_compris     = :cla_sort_compris,
          cla_sort_prepare     = :cla_sort_prepare,
          cla_domaine_divin    = :cla_domaine_divin,
          cla_pointsCompetences= :cla_pointsCompetences,
          cla_po_niveau1       = :cla_po_niveau1,
          cla_alignement       = :cla_alignement,
          cla_conditions       = :cla_conditions,
          cla_description      = :cla_description,
          cla_armes            = :cla_armes,
          cla_armures          = :cla_armures,
          cla_outils           = :cla_outils,
          cla_sauvegardes      = :cla_sauvegardes,
          cla_equipement       = :cla_equipement,
          cla_competences      = :cla_competences,
          cla_sorts            = :cla_sorts,
          cla_caracteristiques = :cla_caracteristiques,
          cla_traits           = :cla_traits,
          cla_critere_rec      = :cla_critere_rec,
          cla_pouvoir1         = :cla_pouvoir1,
          cla_pouvoir2         = :cla_pouvoir2,
          cla_pouvoir3         = :cla_pouvoir3,
          cla_pouvoir4         = :cla_pouvoir4,
          cla_pouvoir5         = :cla_pouvoir5,
          cla_res_id           = :cla_res_id,
          cla_camp_id          = :cla_camp_id,
          cla_cla_id           = :cla_cla_id
        WHERE cla_id = :cla_id
      ');
      $stmt->execute($params);
    endif;

    // ---- 2. Table de progression (UPSERT niveau par niveau) ----
    // Une sous-classe (DD2024) n'a pas de table de progression propre :
    // on purge d'éventuelles données issues d'un changement de type
    // (ex. une classe Base reclassée en Sous-classe) plutôt que de les conserver.

    if ($estSousClasse):
      $db->prepare('DELETE FROM dd_classe_niveau WHERE cn_cla_id = ?')->execute([$cla_id]);
    else:

    $niveaux_post = isset($_POST['niveaux']) && is_array($_POST['niveaux'])
      ? $_POST['niveaux']
      : [];

    if (!empty($niveaux_post)):
      $stmt_exists = $db->prepare('
        SELECT cn_id FROM dd_classe_niveau
        WHERE cn_cla_id = ? AND cn_niveau = ?
      ');

      // Colonnes toujours présentes dans la table
      $cols_allowed = [
        'cn_bba',
        'cn_reflexes',
        'cn_vigueur',
        'cn_volonte',
        'cn_pouvoir1',
        'cn_pouvoir2',
        'cn_pouvoir3',
        'cn_pouvoir4',
        'cn_pouvoir5',
        'cn_sort_n0',
        'cn_sort_n1',
        'cn_sort_n2',
        'cn_sort_n3',
        'cn_sort_n4',
        'cn_sort_n5',
        'cn_sort_n6',
        'cn_sort_n7',
        'cn_sort_n8',
        'cn_sort_n9',
        'cn_sortConnu_n0',
        'cn_sortConnu_n1',
        'cn_sortConnu_n2',
        'cn_sortConnu_n3',
        'cn_sortConnu_n4',
        'cn_sortConnu_n5',
        'cn_sortConnu_n6',
        'cn_sortConnu_n7',
        'cn_sortConnu_n8',
        'cn_sortConnu_n9',
        'cn_sortPrepare',
      ];

      // Colonnes nullable : champ vide → NULL (distinction entre "pas de sort" et "0 sort")
      // Les colonnes nn (bba, réflexes, vigueur, volonté) conservent leur valeur par défaut.
      $cols_nullable = [
        'cn_sort_n0',
        'cn_sort_n1',
        'cn_sort_n2',
        'cn_sort_n3',
        'cn_sort_n4',
        'cn_sort_n5',
        'cn_sort_n6',
        'cn_sort_n7',
        'cn_sort_n8',
        'cn_sort_n9',
        'cn_sortConnu_n0',
        'cn_sortConnu_n1',
        'cn_sortConnu_n2',
        'cn_sortConnu_n3',
        'cn_sortConnu_n4',
        'cn_sortConnu_n5',
        'cn_sortConnu_n6',
        'cn_sortConnu_n7',
        'cn_sortConnu_n8',
        'cn_sortConnu_n9',
        'cn_sortPrepare',
        'cn_pouvoir1',
        'cn_pouvoir2',
        'cn_pouvoir3',
        'cn_pouvoir4',
        'cn_pouvoir5',
      ];

      foreach ($niveaux_post as $nKey => $row):
        $niv = (int)$nKey;
        if ($niv < 1 || $niv > $niveauMax) continue;

        $values = [];
        foreach ($cols_allowed as $col):
          $raw = isset($row[$col]) ? trim((string)$row[$col]) : '';
          if ($raw === '' && in_array($col, $cols_nullable, true)):
            $values[$col] = null;
          else:
            $values[$col] = $raw;
          endif;
        endforeach;

        $stmt_exists->execute([$cla_id, $niv]);
        $exists = (bool)$stmt_exists->fetchColumn();

        if ($exists):
          $setParts = [];
          $updParams = [':cla' => $cla_id, ':niveau' => $niv];
          foreach ($cols_allowed as $col):
            $setParts[]           = $col . ' = :' . $col;
            $updParams[':' . $col] = $values[$col];
          endforeach;
          $db->prepare('
            UPDATE dd_classe_niveau SET ' . implode(', ', $setParts) . '
            WHERE cn_cla_id = :cla AND cn_niveau = :niveau
          ')->execute($updParams);
        else:
          $insCols   = ['cn_cla_id', 'cn_niveau'];
          $insParams = [':cn_cla_id' => $cla_id, ':cn_niveau' => $niv];
          foreach ($cols_allowed as $col):
            $insCols[]            = $col;
            $insParams[':' . $col] = $values[$col];
          endforeach;
          $db->prepare('
            INSERT INTO dd_classe_niveau (' . implode(', ', $insCols) . ')
            VALUES (' . implode(', ', array_keys($insParams)) . ')
          ')->execute($insParams);
        endif;
      endforeach;
    endif;

    endif; // fin else ($estSousClasse) — Section 2

    // ---- 3. Capacités spéciales (payload JS) ----

    if ($payload_ready && !empty($capacites_payload)):

      // Résoudre cap_key → cap_id (créer les nouvelles entrées dans dd_capacites_speciales)
      $capKeyToId = [];
      foreach ($capacites_payload as $capRow):
        $capKey  = (string)($capRow['cap_key'] ?? '');
        $cap_id  = intParam($capRow['cap_id'] ?? 0);
        $cap_nom = strParam($capRow['cap_nom'] ?? '');
        if (!$capKey || !$cap_nom) continue;

        $cap_desc = $capRow['cap_description'] ?? '';
        $cap_type = strParam($capRow['cap_type'] ?? '');

        if ($cap_id > 0):
          // Mise à jour de la capacité existante
          $db->prepare('
            UPDATE dd_capacites_speciales
            SET cap_nom = ?, cap_description = ?, cap_type = ?
            WHERE cap_id = ?
          ')->execute([$cap_nom, $cap_desc, $cap_type, $cap_id]);
          $capKeyToId[$capKey] = $cap_id;
        else:
          // Nouvelle capacité
          $db->prepare('
            INSERT INTO dd_capacites_speciales (cap_nom, cap_description, cap_type)
            VALUES (?, ?, ?)
          ')->execute([$cap_nom, $cap_desc, $cap_type]);
          $capKeyToId[$capKey] = (int)$db->lastInsertId();
        endif;
      endforeach;

      // Supprimer toutes les affectations existantes de la classe
      $db->prepare('DELETE FROM dd_classe_capacite WHERE cc_cla_id = ?')->execute([$cla_id]);

      // Réinsérer depuis affectations_payload
      $seen = [];
      $stmt_ins_aff = $db->prepare('
        INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, cc_niveau, cc_precision)
        VALUES (?, ?, ?, ?)
      ');
      foreach ($affectations_payload as $aff):
        $capKey   = (string)($aff['cap_key'] ?? '');
        $cc_niv   = intParam($aff['cc_niveau'] ?? 0);
        $cc_prec  = strParam($aff['cc_precision'] ?? '');

        if (!isset($capKeyToId[$capKey]) || $cc_niv < 1 || $cc_niv > $niveauMax) continue;
        $cap_id_eff = $capKeyToId[$capKey];

        // Déduplication
        $sig = $cap_id_eff . '|' . $cc_niv . '|' . $cc_prec;
        if (isset($seen[$sig])) continue;
        $seen[$sig] = true;

        $stmt_ins_aff->execute([$cla_id, $cap_id_eff, $cc_niv, $cc_prec]);
      endforeach;

    endif;

    $db->commit();
    repondreOk($is_ajax, $cla_id, 'classe', $redirect);
  } catch (Exception $e) {
    $db->rollBack();
    error_log('enregistrerClasse : ' . $e->getMessage());
    repondreErreur($is_ajax, 'Erreur base de données.', $redirect);
  }
}


// ============================================================
// CLASSE — Suppression (avec vérification dépendances)
// ============================================================

function supprimerClasse($db, bool $is_ajax, string $redirect): void
{
  $ids = $_POST['ids'] ?? [];
  if (!empty($_POST['id'])) $ids[] = $_POST['id'];
  $ids = array_filter(array_map('intval', (array)$ids));

  if (empty($ids)):
    repondreErreur($is_ajax, 'Aucune classe à supprimer.', $redirect);
  endif;

  $refus  = [];
  $ok_ids = [];

  foreach ($ids as $cla_id):
    // Vérification : personnages utilisant cette classe
    $stmt = $db->prepare('
      SELECT COUNT(*) FROM dd_personnages_classes WHERE pc_cla_id = ?
    ');
    $stmt->execute([$cla_id]);
    $nb = (int)$stmt->fetchColumn();

    // Vérification : sous-classes rattachées à cette classe (cla_cla_id)
    $stmt_sc = $db->prepare('
      SELECT GROUP_CONCAT(cla_nom SEPARATOR \', \') FROM dd_classes WHERE cla_cla_id = ?
    ');
    $stmt_sc->execute([$cla_id]);
    $sousClassesNoms = $stmt_sc->fetchColumn();

    if ($nb > 0 || $sousClassesNoms):
      $stmt_nom = $db->prepare('SELECT cla_nom FROM dd_classes WHERE cla_id = ?');
      $stmt_nom->execute([$cla_id]);
      $nom = $stmt_nom->fetchColumn() ?: "classe #$cla_id";

      $raisons = [];
      if ($nb > 0):
        $raisons[] = "$nb personnage(s) associé(s)";
      endif;
      if ($sousClassesNoms):
        $raisons[] = "sous-classe(s) rattachée(s) : $sousClassesNoms";
      endif;
      $refus[] = "« $nom » : " . implode(' ; ', $raisons);
    else:
      $ok_ids[] = $cla_id;
    endif;
  endforeach;

  if (!empty($ok_ids)):
    try {
      $db->beginTransaction();
      foreach ($ok_ids as $cla_id):
        $db->prepare('DELETE FROM dd_classe_capacite WHERE cc_cla_id = ?')->execute([$cla_id]);
        $db->prepare('DELETE FROM dd_classe_niveau   WHERE cn_cla_id = ?')->execute([$cla_id]);
        $db->prepare('DELETE FROM dd_classes         WHERE cla_id    = ?')->execute([$cla_id]);
      endforeach;
      $db->commit();
    } catch (Exception $e) {
      $db->rollBack();
      error_log('supprimerClasse : ' . $e->getMessage());
      repondreErreur($is_ajax, 'Erreur lors de la suppression.', $redirect);
    }
  endif;

  if (empty($refus)):
    if ($is_ajax):
      header('Content-Type: application/json');
      echo json_encode(['ok' => true, 'id' => 0, 'url_detail' => '']);
      exit;
    endif;
    $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Classe(s) supprimée(s).'];
    header('Location: ' . $redirect);
    exit;
  endif;

  $msg = 'Suppression impossible pour : ' . implode(' ; ', $refus) . '.';
  if (!empty($ok_ids)):
    $msg = count($ok_ids) . ' classe(s) supprimée(s). ' . $msg;
  endif;
  repondreErreur($is_ajax, $msg, $redirect);
}


// ============================================================
// CLASSE — Suppression groupée (bulk)
// ============================================================

function bulkSupprimerClasses($db, bool $is_ajax, string $redirect): void
{
  supprimerClasse($db, $is_ajax, $redirect);
}


// ============================================================
// OBJET MAGIQUE — Enregistrement
// ============================================================

function enregistrerObjet($db, bool $is_ajax, string $redirect): void
{
  $om_id      = intParam($_POST['om_id']             ?? 0);
  $nom        = strParam($_POST['om_nom']            ?? '');
  $ruleset_id = intParam($_POST['om_ruleset_var_id'] ?? 1);

  if (!$nom):
    repondreErreur($is_ajax, "Le nom de l'objet magique est obligatoire.", $redirect);
  endif;

  $res_id = intParam($_POST['om_res_id'] ?? 0);
  if (!$res_id):
    repondreErreur($is_ajax, 'La source est obligatoire.', $redirect);
  endif;

  $com_id = intParam($_POST['om_com_id'] ?? 0);
  if (!$com_id):
    repondreErreur($is_ajax, 'La catégorie est obligatoire.', $redirect);
  endif;

  $fom_id       = intParam($_POST['om_fom_id']        ?? 2);
  $so_id        = intParam($_POST['om_so_id']         ?? 0) ?: null;
  $so_niveau    = intParam($_POST['om_so_niveau']      ?? 0);
  $modificateurs = intParam($_POST['om_modificateurs'] ?? 0);
  $variantes    = strParam($_POST['om_variantes']      ?? '') ?: null;
  $visible      = isset($_POST['om_visible']) ? 1 : 0;
  $camp_id      = intParam($_POST['om_camp_id']       ?? 0) ?: null;
  $description  = $_POST['om_description'] ?? '';   // HTML TinyMCE — pas de h()

  try {
    $db->beginTransaction();

    if ($om_id === 0):
      $stmt = $db->prepare('
        INSERT INTO dd_objets_magiques
          (om_nom, om_com_id, om_fom_id, om_so_id, om_so_niveau,
           om_modificateurs, om_variantes, om_description, om_visible,
           om_res_id, om_camp_id, om_ruleset_var_id)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
      ');
      $stmt->execute([
        $nom,
        $com_id,
        $fom_id,
        $so_id,
        $so_niveau,
        $modificateurs,
        $variantes,
        $description,
        $visible,
        $res_id,
        $camp_id,
        $ruleset_id,
      ]);
      $om_id = (int)$db->lastInsertId();
    else:
      $stmt = $db->prepare('
        UPDATE dd_objets_magiques SET
          om_nom            = ?,
          om_com_id         = ?,
          om_fom_id         = ?,
          om_so_id          = ?,
          om_so_niveau      = ?,
          om_modificateurs  = ?,
          om_variantes      = ?,
          om_description    = ?,
          om_visible        = ?,
          om_res_id         = ?,
          om_camp_id        = ?
        WHERE om_id = ?
      ');
      $stmt->execute([
        $nom,
        $com_id,
        $fom_id,
        $so_id,
        $so_niveau,
        $modificateurs,
        $variantes,
        $description,
        $visible,
        $res_id,
        $camp_id,
        $om_id,
      ]);
    endif;

    $db->commit();
    repondreOk($is_ajax, $om_id, 'objet', $redirect);
  } catch (Exception $e) {
    $db->rollBack();
    error_log('enregistrerObjet : ' . $e->getMessage());
    repondreErreur($is_ajax, 'Erreur base de données.', $redirect);
  }
}

// ============================================================
// MONSTRE — Enregistrement (création + modification)
// ============================================================
// mo_stats est stocké TEL QUEL (texte brut). Aucune passe d'analyse à
// l'enregistrement : le formatage et les liens sont calculés à l'affichage
// par rendreStatsMonstre() (include/monstre-parser.php).

function enregistrerMonstre($db, bool $is_ajax, string $redirect): void
{
  $mo_id      = intParam($_POST['mo_id']             ?? 0);
  $nom        = strParam($_POST['mo_nom']            ?? '');
  $ruleset_id = intParam($_POST['mo_ruleset_var_id'] ?? 1);
  $uid        = (int)($_SESSION['j_id'] ?? 0);

  if (!$nom):
    repondreErreur($is_ajax, 'Le nom du monstre est obligatoire.', $redirect);
  endif;

  // mo_res_id : soit l'id réel d'une source active (officielle ou supplément
  // déjà créé), soit la sentinelle 'supplement' si l'utilisateur n'a encore
  // aucun supplément pour ce ruleset (cf. § Supplément utilisateur).
  $res_raw = strParam($_POST['mo_res_id'] ?? '');
  if (!$res_raw):
    repondreErreur($is_ajax, 'La source est obligatoire.', $redirect);
  endif;

  $mocat_id = intParam($_POST['mo_mocat_id'] ?? 0);
  if (!$mocat_id):
    repondreErreur($is_ajax, 'La catégorie est obligatoire.', $redirect);
  endif;

  // Groupe : NN en base, mais concept DD2024 uniquement.
  // En DD3.5 le champ caché transmet 0 -> on stocke 0 (pas de groupe).
  $mogr_id = intParam($_POST['mo_mogr_id'] ?? 0) ?: null;

  $fp_id   = strParam($_POST['mo_fp_id'] ?? '') ?: null; // varchar : libellé ou NULL
  $stats   = (string)($_POST['mo_stats'] ?? '');         // TEXTE BRUT — pas de h()
  $camp_id = intParam($_POST['mo_camp_id'] ?? 0) ?: null;

  try {
    $db->beginTransaction();

    // ----------------------------------------------------------
    // Résolution de la source (mécanisme commun supplément utilisateur)
    // ----------------------------------------------------------
    if ($res_raw === 'supplement'):
      // Premier save d'une entrée de supplément pour cet utilisateur/ruleset :
      // création à la volée (idempotente) + auto-add dd_joueurs_sources.
      $res_id         = getOrCreateUserSupplement($db, $uid, $ruleset_id);
      $est_supplement = true;
    else:
      $res_id = (int)$res_raw;
      $stmt = $db->prepare('SELECT res_j_id FROM dd_ressources WHERE res_id = ?');
      $stmt->execute([$res_id]);
      $res_j_id       = $stmt->fetchColumn();
      $est_supplement = ($res_j_id !== false && $res_j_id !== null);

      // Garde-fou : seul le propriétaire (ou un admin) peut rattacher une
      // entrée à un supplément — empêche un compendium manager d'écrire
      // dans le supplément d'autrui en forgeant la requête.
      if ($est_supplement && (int)$res_j_id !== $uid && !isAdmin()):
        $db->rollBack();
        repondreErreur($is_ajax, 'Source de supplément invalide.', $redirect);
      endif;
    endif;

    // ----------------------------------------------------------
    // Visibilité — pertinente uniquement pour une entrée de supplément.
    // Les entrées officielles sont toujours public=1 / visible=1.
    // Contrainte serveur : _public=1 implique _visible=1 (interdit en base).
    // ----------------------------------------------------------
    if ($est_supplement):
      $public  = isset($_POST['mo_public'])  ? 1 : 0;
      $visible = isset($_POST['mo_visible']) ? 1 : 0;
      if ($public):
        $visible = 1;
      endif;
    else:
      $public  = 1;
      $visible = 1;
    endif;

    if ($mo_id === 0):
      $stmt = $db->prepare('
        INSERT INTO dd_monstres
          (mo_nom, mo_mocat_id, mo_mogr_id, mo_stats, mo_fp_id,
           mo_res_id, mo_camp_id, mo_public, mo_visible, mo_ruleset_var_id)
        VALUES (?,?,?,?,?,?,?,?,?,?)
      ');
      $stmt->execute([
        $nom,
        $mocat_id,
        $mogr_id,
        $stats,
        $fp_id,
        $res_id,
        $camp_id,
        $public,
        $visible,
        $ruleset_id,
      ]);
      $mo_id = (int)$db->lastInsertId();
    else:
      $stmt = $db->prepare('
        UPDATE dd_monstres SET
          mo_nom      = ?,
          mo_mocat_id = ?,
          mo_mogr_id  = ?,
          mo_stats    = ?,
          mo_fp_id    = ?,
          mo_res_id   = ?,
          mo_camp_id  = ?,
          mo_public   = ?,
          mo_visible  = ?
        WHERE mo_id = ?
      ');
      $stmt->execute([
        $nom,
        $mocat_id,
        $mogr_id,
        $stats,
        $fp_id,
        $res_id,
        $camp_id,
        $public,
        $visible,
        $mo_id,
      ]);
    endif;

    $db->commit();
    repondreOk($is_ajax, $mo_id, 'monstre', $redirect);
  } catch (Exception $e) {
    $db->rollBack();
    error_log('enregistrerMonstre : ' . $e->getMessage());
    repondreErreur($is_ajax, 'Erreur base de données.', $redirect);
  }
}


// ============================================================
// HISTORIQUE — Enregistrement (DD2024 uniquement)
// ============================================================

function enregistrerHistorique($db, bool $is_ajax, string $redirect): void
{
  $hi_id      = intParam($_POST['hi_id']              ?? 0);
  $nom        = strParam($_POST['hi_nom']             ?? '');
  $ruleset_id = intParam($_POST['hi_ruleset_var_id']  ?? 2);

  if (!$nom):
    repondreErreur($is_ajax, "Le nom de l'historique est obligatoire.", $redirect);
  endif;

  $res_id = intParam($_POST['hi_res_id'] ?? 0);
  if (!$res_id):
    repondreErreur($is_ajax, 'La source est obligatoire.', $redirect);
  endif;

  $camp_id     = intParam($_POST['hi_camp_id']     ?? 0) ?: null;
  $description = $_POST['hi_description'] ?? '';   // HTML TinyMCE — pas de h()

  try {
    $db->beginTransaction();

    if ($hi_id === 0):
      $stmt = $db->prepare('
        INSERT INTO dd_historiques
          (hi_nom, hi_description, hi_res_id, hi_camp_id, hi_ruleset_var_id)
        VALUES (?,?,?,?,?)
      ');
      $stmt->execute([
        $nom,
        $description,
        $res_id,
        $camp_id,
        $ruleset_id,
      ]);
      $hi_id = (int)$db->lastInsertId();
    else:
      $stmt = $db->prepare('
        UPDATE dd_historiques SET
          hi_nom            = ?,
          hi_description    = ?,
          hi_res_id         = ?,
          hi_camp_id        = ?,
          hi_ruleset_var_id = ?
        WHERE hi_id = ?
      ');
      $stmt->execute([
        $nom,
        $description,
        $res_id,
        $camp_id,
        $ruleset_id,
        $hi_id,
      ]);
    endif;

    $db->commit();
    repondreOk($is_ajax, $hi_id, 'historique', $redirect);
  } catch (Exception $e) {
    $db->rollBack();
    error_log('enregistrerHistorique : ' . $e->getMessage());
    repondreErreur($is_ajax, 'Erreur base de données.', $redirect);
  }
}
