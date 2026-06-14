<?php
// personnages/enregistrement.php — POST commun du module Personnages.
// Routeur d'actions transactionnelles (commit global, cf. ARCHITECTURE §7.4).
//
// Actions implémentées :
//   - supprimerPersonnage   (sous-phase 3.0)
//   - enregistrerPersonnage (sous-phase 3.1 : création + mise à jour identité)
//
// Toutes les actions :
//   - Vérifient le CSRF (verifyCsrf())
//   - Vérifient la propriété du personnage (canAccess sur pe_j_id)
//   - Sont exécutées dans une transaction PDO
//   - Renvoient JSON {ok: bool, erreur?: string, id?: int, url_fiche?: string}
//     en mode ajax ; redirection sinon.
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';
require_once '../include/personnage_helpers.php';

requireAuth();

$is_ajax = !empty($_GET['ajax']);
verifyCsrf();

$action = strParam($_POST['action'] ?? '');
$j_id   = (int)$_SESSION['j_id'];

// Réponse standardisée
function repondre(bool $is_ajax, array $payload): void {
  if ($is_ajax):
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($payload);
    exit;
  endif;
  // Mode non-ajax : redirection (URL fournie dans le payload ou liste par défaut)
  $url = $payload['url'] ?? (BASE_URL . '/personnages/');
  header('Location: ' . $url);
  exit;
}

// ============================================================
// ROUTEUR D'ACTIONS
// ============================================================

switch ($action):

  // --------------------------------------------------------
  // SUPPRESSION PERSONNAGE
  // --------------------------------------------------------
  case 'supprimerPersonnage':
    $pe_id = intParam($_POST['id'] ?? 0);
    if ($pe_id <= 0):
      repondre($is_ajax, ['ok' => false, 'erreur' => 'Identifiant manquant.']);
    endif;

    // Contrôle propriétaire
    $stmt = $db->prepare('SELECT pe_j_id FROM dd_personnages WHERE pe_id = ?');
    $stmt->execute([$pe_id]);
    $row = $stmt->fetch();
    if (!$row || !canAccess((int)$row['pe_j_id'])):
      repondre($is_ajax, ['ok' => false, 'erreur' => 'Personnage introuvable ou accès refusé.']);
    endif;

    // Suppression transactionnelle : cascade manuelle sur les tables liées.
    // Les FK étant logiques (non enforced), on supprime explicitement.
    try {
      $db->beginTransaction();

      // Sorts préparés
      $db->prepare('DELETE FROM dd_personnages_sorts_prepares WHERE pesp_pe_id = ?')
         ->execute([$pe_id]);

      // Sorts connus (rattachés via pes_pc_id -> dd_personnages_classes)
      $db->prepare('
        DELETE pes FROM dd_personnages_sorts pes
          JOIN dd_personnages_classes pc ON pc.pc_id = pes.pes_pc_id
         WHERE pc.pc_pe_id = ?
      ')->execute([$pe_id]);

      // NLS prestige (rattachés via penl_pc_id_base ou penl_pc_id_prestige)
      $db->prepare('
        DELETE penl FROM dd_personnages_nls penl
          JOIN dd_personnages_classes pc ON pc.pc_id = penl.penl_pc_id_base
         WHERE pc.pc_pe_id = ?
      ')->execute([$pe_id]);

      // Classes
      $db->prepare('DELETE FROM dd_personnages_classes WHERE pc_pe_id = ?')
         ->execute([$pe_id]);

      // Compétences
      $db->prepare('DELETE FROM dd_personnages_competences WHERE pec_pe_id = ?')
         ->execute([$pe_id]);

      // Dons
      $db->prepare('DELETE FROM dd_personnages_dons WHERE ped_pe_id = ?')
         ->execute([$pe_id]);

      // Notes connues par le perso (les notes elles-mêmes restent)
      $db->prepare('DELETE FROM dd_personnages_notes WHERE pno_pe_id = ?')
         ->execute([$pe_id]);

      // Liaisons campagnes (la liaison N-N : le perso ne fait plus partie)
      $db->prepare('DELETE FROM dd_campagnes_personnages WHERE cp_pe_id = ?')
         ->execute([$pe_id]);

      // Personnage lui-même
      $db->prepare('DELETE FROM dd_personnages WHERE pe_id = ?')
         ->execute([$pe_id]);

      $db->commit();
    } catch (PDOException $e) {
      $db->rollBack();
      repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur SQL : ' . $e->getMessage()]);
    }

    repondre($is_ajax, ['ok' => true]);
    break;

  // --------------------------------------------------------
  // CRÉATION / MISE À JOUR PERSONNAGE (identité)
  // --------------------------------------------------------
  case 'enregistrerPersonnage':
    enregistrerPersonnage($db, $is_ajax, $j_id);
    break;

  case 'enregistrerClasses':
    enregistrerClasses($db, $is_ajax, $j_id);
    break;

  default:
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Action inconnue.']);

endswitch;

// ============================================================
// FONCTIONS
// ============================================================

function enregistrerPersonnage(PDO $db, bool $is_ajax, int $j_id): void {
  // Lecture et nettoyage des champs
  $pe_id  = intParam($_POST['pe_id']  ?? 0);
  $nom    = trim(strParam($_POST['pe_nom'] ?? ''));
  $sexe   = trim(strParam($_POST['pe_sexe'] ?? ''));
  $ra_id  = intParam($_POST['pe_ra_id']  ?? 0);
  $arc_id = intParam($_POST['pe_arc_id'] ?? 0);
  $hi_id  = intParam($_POST['pe_hi_id']  ?? 0);
  $al_id  = intParam($_POST['pe_al_id']  ?? 0);

  $caracs = [];
  foreach (['pe_for','pe_con','pe_dex','pe_int','pe_sag','pe_cha'] as $c):
    $caracs[$c] = max(0, min(99, intParam($_POST[$c] ?? 10)));
  endforeach;

  $ca = max(0, min(99,   intParam($_POST['pe_ca'] ?? 10)));
  $pv = max(0, min(9999, intParam($_POST['pe_pv'] ?? 0)));

  $background = $_POST['pe_background'] ?? '';
  $ruleset_id = intParam($_POST['pe_ruleset_var_id'] ?? 0);

  // À la création, première classe obligatoire (option 1 — cf. archi §7.2)
  $is_creation   = ($pe_id === 0);
  $cla_id_init   = intParam($_POST['pe_cla_id']     ?? 0);
  $cla_niv_init  = max(1, min(40, intParam($_POST['pe_cla_niveau'] ?? 0)));

  // ----- Validations ---------------------------------------
  if ($nom === ''):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Le nom du personnage est obligatoire.']);
  endif;
  if ($ra_id <= 0):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'La race est obligatoire.']);
  endif;
  if ($is_creation):
    if ($ruleset_id <= 0):
      repondre($is_ajax, ['ok' => false, 'erreur' => 'Le ruleset est obligatoire.']);
    endif;
    if ($cla_id_init <= 0):
      repondre($is_ajax, ['ok' => false, 'erreur' => 'La première classe est obligatoire.']);
    endif;
  endif;

  // Normaliser : pe_al_id = 0 → NULL ; pe_hi_id = 0 → NULL ; pe_arc_id = 0 reste 0
  $al_id_db = $al_id > 0 ? $al_id : null;
  $hi_id_db = $hi_id > 0 ? $hi_id : null;

  // ----- Édition : contrôle propriétaire -------------------
  if (!$is_creation):
    $stmt = $db->prepare('SELECT pe_j_id, pe_ruleset_var_id FROM dd_personnages WHERE pe_id = ?');
    $stmt->execute([$pe_id]);
    $row = $stmt->fetch();
    if (!$row || !canAccess((int)$row['pe_j_id'])):
      repondre($is_ajax, ['ok' => false, 'erreur' => 'Personnage introuvable ou accès refusé.']);
    endif;
    // Ruleset non modifiable
    $ruleset_id = (int)$row['pe_ruleset_var_id'];
  endif;

  // ----- Transaction ---------------------------------------
  try {
    $db->beginTransaction();

    if ($is_creation):
      $sql = '
        INSERT INTO dd_personnages
          (pe_nom, pe_sexe, pe_j_id, pe_ra_id, pe_arc_id, pe_hi_id, pe_al_id,
           pe_for, pe_con, pe_dex, pe_int, pe_sag, pe_cha,
           pe_ca, pe_pv, pe_background,
           pe_ruleset_var_id, pe_date_creation, pe_date_modif)
        VALUES
          (?, ?, ?, ?, ?, ?, ?,
           ?, ?, ?, ?, ?, ?,
           ?, ?, ?,
           ?, NOW(), NOW())
      ';
      $params = [
        $nom, $sexe, $j_id, $ra_id, $arc_id, $hi_id_db, $al_id_db,
        $caracs['pe_for'], $caracs['pe_con'], $caracs['pe_dex'],
        $caracs['pe_int'], $caracs['pe_sag'], $caracs['pe_cha'],
        $ca, $pv, $background,
        $ruleset_id,
      ];
      $db->prepare($sql)->execute($params);
      $pe_id = (int)$db->lastInsertId();

      // Première classe (option 1) — UNIQUE(pc_pe_id, pc_cla_id)
      $db->prepare('
        INSERT INTO dd_personnages_classes (pc_pe_id, pc_cla_id, pc_niveau)
        VALUES (?, ?, ?)
      ')->execute([$pe_id, $cla_id_init, $cla_niv_init]);

    else:
      // Mise à jour — identité uniquement (la modification des classes
      // passe par l'éditeur 3.2, le background reste ici)
      $sql = '
        UPDATE dd_personnages
           SET pe_nom        = ?,
               pe_sexe       = ?,
               pe_ra_id      = ?,
               pe_arc_id     = ?,
               pe_hi_id      = ?,
               pe_al_id      = ?,
               pe_for        = ?,
               pe_con        = ?,
               pe_dex        = ?,
               pe_int        = ?,
               pe_sag        = ?,
               pe_cha        = ?,
               pe_ca         = ?,
               pe_pv         = ?,
               pe_background = ?,
               pe_date_modif = NOW()
         WHERE pe_id = ?
      ';
      $params = [
        $nom, $sexe, $ra_id, $arc_id, $hi_id_db, $al_id_db,
        $caracs['pe_for'], $caracs['pe_con'], $caracs['pe_dex'],
        $caracs['pe_int'], $caracs['pe_sag'], $caracs['pe_cha'],
        $ca, $pv, $background,
        $pe_id,
      ];
      $db->prepare($sql)->execute($params);
    endif;

    $db->commit();
  } catch (PDOException $e) {
    $db->rollBack();
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur SQL : ' . $e->getMessage()]);
  }

  repondre($is_ajax, [
    'ok'        => true,
    'id'        => $pe_id,
    'url_fiche' => BASE_URL . '/personnages/fiche.php?id=' . $pe_id,
  ]);
}

// ============================================================
// ENREGISTREMENT DES CLASSES (3.2)
// ============================================================
// Reçoit en POST :
//   pe_id          int
//   classes[][cla_id]   int   — id de la classe
//   classes[][niveau]   int   — niveau dans cette classe
//   classes[][do_id_1]  int   — domaine divin 1 (DD3.5, 0=aucun)
//   classes[][do_id_2]  int   — domaine divin 2 (DD3.5, 0=aucun)
//
// Pattern DELETE + INSERT en transaction (comme la sélection des sources).
// Contrainte métier : au moins une classe obligatoire.

function enregistrerClasses(PDO $db, bool $is_ajax, int $j_id): void {
  $pe_id = intParam($_POST['pe_id'] ?? 0);
  if ($pe_id <= 0):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Identifiant manquant.']);
  endif;

  // Contrôle propriétaire
  $stmt = $db->prepare('SELECT pe_j_id FROM dd_personnages WHERE pe_id = ?');
  $stmt->execute([$pe_id]);
  $row = $stmt->fetch();
  if (!$row || !canAccess((int)$row['pe_j_id'])):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Accès refusé.']);
  endif;

  // Lecture et validation de la liste postée
  $classes_post = $_POST['classes'] ?? [];
  if (!is_array($classes_post)):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Format de données invalide.']);
  endif;

  // Dédoublonnage et validation ligne par ligne
  $lignes   = [];
  $cla_vus  = [];
  foreach ($classes_post as $row_post):
    $cla_id  = intParam($row_post['cla_id']  ?? 0);
    $niveau  = max(1, min(40, intParam($row_post['niveau']  ?? 1)));
    $do_id_1 = intParam($row_post['do_id_1'] ?? 0);
    $do_id_2 = intParam($row_post['do_id_2'] ?? 0);

    if ($cla_id <= 0) continue; // ligne vide ignorée
    if (isset($cla_vus[$cla_id])):
      repondre($is_ajax, ['ok' => false, 'erreur' => 'Une classe ne peut figurer qu\'une seule fois.']);
    endif;
    $cla_vus[$cla_id] = true;
    $lignes[] = [
      'cla_id'  => $cla_id,
      'niveau'  => $niveau,
      'do_id_1' => $do_id_1 > 0 ? $do_id_1 : null,
      'do_id_2' => $do_id_2 > 0 ? $do_id_2 : null,
    ];
  endforeach;

  if (empty($lignes)):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Au moins une classe est obligatoire.']);
  endif;

  // Transaction : DELETE + INSERT
  try {
    $db->beginTransaction();

    // Suppression des sorts rattachés aux classes supprimées
    // (pes_pc_id -> dd_personnages_classes : cascade manuelle)
    $db->prepare('
      DELETE pes FROM dd_personnages_sorts pes
        JOIN dd_personnages_classes pc ON pc.pc_id = pes.pes_pc_id
       WHERE pc.pc_pe_id = ?
    ')->execute([$pe_id]);

    // Suppression des NLS rattachés
    $db->prepare('
      DELETE penl FROM dd_personnages_nls penl
        JOIN dd_personnages_classes pc ON pc.pc_id = penl.penl_pc_id_base
       WHERE pc.pc_pe_id = ?
    ')->execute([$pe_id]);

    // Suppression de toutes les classes du personnage
    $db->prepare('DELETE FROM dd_personnages_classes WHERE pc_pe_id = ?')
       ->execute([$pe_id]);

    // Réinsertion
    $stmt_ins = $db->prepare('
      INSERT INTO dd_personnages_classes (pc_pe_id, pc_cla_id, pc_niveau, pc_do_id_1, pc_do_id_2)
      VALUES (?, ?, ?, ?, ?)
    ');
    foreach ($lignes as $l):
      $stmt_ins->execute([$pe_id, $l['cla_id'], $l['niveau'], $l['do_id_1'], $l['do_id_2']]);
    endforeach;

    // Mettre à jour la date de modification du personnage
    $db->prepare('UPDATE dd_personnages SET pe_date_modif = NOW() WHERE pe_id = ?')
       ->execute([$pe_id]);

    $db->commit();
  } catch (PDOException $e) {
    $db->rollBack();
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur SQL : ' . $e->getMessage()]);
  }

  repondre($is_ajax, ['ok' => true]);
}
