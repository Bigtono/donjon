<?php
// personnages/enregistrement.php — POST commun du module Personnages.
// Routeur d'actions transactionnelles (commit global, cf. ARCHITECTURE §7.4).
//
// Actions implémentées :
//   - supprimerPersonnage     (SP-PE0)
//   - enregistrerPersonnage   (SP-PE1 : création + mise à jour identité)
//   - enregistrerClasses      (SP-PE2)
//   - enregistrerCompetences  (SP-PE3)
//   - ajouterDon / supprimerDon (SP-PE4 — écriture immédiate, une ligne)
//   - rattacherCampagne / detacherCampagne / definirCampagneCourante /
//     basculerParticipationCampagne (SP-PE5 — écriture immédiate)
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

  case 'enregistrerCompetences':
    enregistrerCompetences($db, $is_ajax, $j_id);
    break;

  case 'ajouterDon':
  case 'supprimerDon':
    basculerDon($db, $is_ajax, $j_id, $action === 'ajouterDon');
    break;

  // --------------------------------------------------------
  // CAMPAGNES (SP-PE5 — écriture immédiate, cf. archi §7.5c)
  // --------------------------------------------------------
  case 'rattacherCampagne':
  case 'detacherCampagne':
    basculerRattachementCampagne($db, $is_ajax, $action === 'rattacherCampagne');
    break;

  case 'definirCampagneCourante':
    definirCampagneCourante($db, $is_ajax);
    break;

  case 'basculerParticipationCampagne':
    basculerParticipationCampagne($db, $is_ajax);
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

  // Ruleset : jamais saisi ni posté — session à la création, valeur en base
  // ensuite (le bloc « Édition » plus bas le relit de toute façon). Cf. helpers.php.
  $ruleset_id = rulesetEnregistrement($db, 'dd_personnages', 'pe_id',
                                      'pe_ruleset_var_id', $pe_id);

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
// ENREGISTREMENT DES CLASSES (SP-PE2)
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

// ============================================================
// ENREGISTREMENT DES COMPÉTENCES (SP-PE3)
// ============================================================
// Reçoit en POST :
//   pe_id                     int
//   competences[][comp_id]    int  — id de la compétence
//   competences[][maitrise]   int  — DD3.5 : rangs ; DD2024 : 0/1/2
//
// Pattern DELETE + INSERT en transaction : seules les lignes maitrise > 0
// sont enregistrées (archi §7.5). Une liste vide est valide et efface toutes
// les compétences du personnage.
//
// Validations : intégrité uniquement (propriétaire, appartenance de la
// compétence au ruleset du personnage, bornes techniques). Aucune règle de
// jeu — pas de plafond de rangs, pas de contrôle de points de compétence.

function enregistrerCompetences(PDO $db, bool $is_ajax, int $j_id): void {
  $pe_id = intParam($_POST['pe_id'] ?? 0);
  if ($pe_id <= 0):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Identifiant manquant.']);
  endif;

  // Contrôle propriétaire + récupération du ruleset du personnage
  $stmt = $db->prepare('SELECT pe_j_id, pe_ruleset_var_id FROM dd_personnages WHERE pe_id = ?');
  $stmt->execute([$pe_id]);
  $row = $stmt->fetch();
  if (!$row || !canAccess((int)$row['pe_j_id'])):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Accès refusé.']);
  endif;
  $ruleset_id = (int)$row['pe_ruleset_var_id'];
  $max_saisie = ($ruleset_id === 2) ? 2 : 99; // DD2024 : 0/1/2 ; DD3.5 : borne technique

  $comp_post = $_POST['competences'] ?? [];
  if (!is_array($comp_post)):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Format de données invalide.']);
  endif;

  // Lecture, bornage et dédoublonnage
  $lignes = [];
  foreach ($comp_post as $row_post):
    $comp_id  = intParam($row_post['comp_id']  ?? 0);
    $maitrise = intParam($row_post['maitrise'] ?? 0);
    if ($comp_id <= 0 || $maitrise <= 0) continue; // ligne non maîtrisée : ignorée
    $lignes[$comp_id] = min($maitrise, $max_saisie);
  endforeach;

  // Intégrité : ne garder que les compétences existant réellement dans le
  // ruleset du personnage (une compétence d'un autre ruleset serait un
  // payload forgé ou une donnée devenue incohérente).
  if (!empty($lignes)):
    $ph        = implode(',', array_fill(0, count($lignes), '?'));
    $stmt_ctrl = $db->prepare("
      SELECT comp_id
        FROM dd_competences
       WHERE comp_ruleset_var_id = ?
         AND comp_id IN ($ph)
    ");
    $stmt_ctrl->execute(array_merge([$ruleset_id], array_keys($lignes)));
    $valides = $stmt_ctrl->fetchAll(PDO::FETCH_COLUMN);
    $lignes  = array_intersect_key($lignes, array_flip(array_map('intval', $valides)));
  endif;

  // Transaction : DELETE + INSERT
  try {
    $db->beginTransaction();

    $db->prepare('DELETE FROM dd_personnages_competences WHERE pec_pe_id = ?')
       ->execute([$pe_id]);

    if (!empty($lignes)):
      $stmt_ins = $db->prepare('
        INSERT INTO dd_personnages_competences (pec_pe_id, pec_comp_id, pec_maitrise)
        VALUES (?, ?, ?)
      ');
      foreach ($lignes as $comp_id => $maitrise):
        $stmt_ins->execute([$pe_id, $comp_id, $maitrise]);
      endforeach;
    endif;

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

// ============================================================
// AJOUT / RETRAIT D'UN DON (SP-PE4)
// ============================================================
// Reçoit en POST : pe_id (int), do_id (int)
//
// Écriture immédiate d'une seule ligne, à chaque clic du sélecteur de dons —
// exception assumée au commit global du module (cf. DECISIONS_LOG D-PE4a) :
// le panneau reste ouvert pour enchaîner les choix et n'a pas de bouton
// « Enregistrer ». Chaque action est atomique, il n'y a donc pas d'état
// partiel à protéger par une transaction.
//
// Renvoie {ok, possede, total} : `total` est le nombre de dons du personnage
// après l'opération, lu en base — le compteur du panneau n'extrapole jamais.

function basculerDon(PDO $db, bool $is_ajax, int $j_id, bool $ajouter): void {
  $pe_id = intParam($_POST['pe_id'] ?? 0);
  $do_id = intParam($_POST['do_id'] ?? 0);

  if ($pe_id <= 0 || $do_id <= 0):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Identifiant manquant.']);
  endif;

  // Contrôle propriétaire + ruleset du personnage
  $stmt = $db->prepare('SELECT pe_j_id, pe_ruleset_var_id FROM dd_personnages WHERE pe_id = ?');
  $stmt->execute([$pe_id]);
  $row = $stmt->fetch();
  if (!$row || !canAccess((int)$row['pe_j_id'])):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Accès refusé.']);
  endif;

  // Intégrité : le don doit exister dans le ruleset du personnage.
  // Contrôlé aussi au retrait — un id forgé ne doit pas servir à sonder la base.
  $stmt = $db->prepare('SELECT do_id FROM dd_dons WHERE do_id = ? AND do_ruleset_var_id = ?');
  $stmt->execute([$do_id, (int)$row['pe_ruleset_var_id']]);
  if (!$stmt->fetchColumn()):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Ce don n\'appartient pas au ruleset du personnage.']);
  endif;

  try {
    if ($ajouter):
      // INSERT IGNORE : la clé unique uk_ped (ped_pe_id, ped_do_id) rend
      // l'ajout idempotent — un double clic ne crée pas de doublon.
      $db->prepare('
        INSERT IGNORE INTO dd_personnages_dons (ped_pe_id, ped_do_id, ped_niveau)
        VALUES (?, ?, NULL)
      ')->execute([$pe_id, $do_id]);
    else:
      $db->prepare('DELETE FROM dd_personnages_dons WHERE ped_pe_id = ? AND ped_do_id = ?')
         ->execute([$pe_id, $do_id]);
    endif;

    $db->prepare('UPDATE dd_personnages SET pe_date_modif = NOW() WHERE pe_id = ?')
       ->execute([$pe_id]);

    $stmt = $db->prepare('SELECT COUNT(*) FROM dd_personnages_dons WHERE ped_pe_id = ?');
    $stmt->execute([$pe_id]);
    $total = (int)$stmt->fetchColumn();
  } catch (PDOException $e) {
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur SQL : ' . $e->getMessage()]);
  }

  repondre($is_ajax, ['ok' => true, 'possede' => $ajouter, 'total' => $total]);
}

// ============================================================
// CAMPAGNES DU PERSONNAGE (SP-PE5)
//
// Écriture immédiate, une action = une ligne de liaison (même parti que les
// dons, cf. D-PE4a) : ce sont des appartenances booléennes, pas des valeurs
// saisies, un commit global n'aurait rien à regrouper.
//
// `dd_campagnes_personnages` est la source de vérité du rattachement ;
// `pe_camp_id` n'est que le raccourci « campagne en cours » (METIER_10). Toute
// écriture maintient donc les deux de front, dans la même transaction.
// ============================================================

/**
 * Charge le personnage visé par une action campagne et contrôle l'accès.
 * Ne rend la main que si le personnage existe et appartient à l'utilisateur.
 */
function chargerPersonnagePourCampagne(PDO $db, bool $is_ajax): array {
  $pe_id = intParam($_POST['pe_id'] ?? 0);
  if ($pe_id <= 0):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Identifiant manquant.']);
  endif;

  $stmt = $db->prepare('
    SELECT pe_j_id, pe_camp_id, pe_ruleset_var_id
      FROM dd_personnages
     WHERE pe_id = ?
  ');
  $stmt->execute([$pe_id]);
  $perso = $stmt->fetch();

  if (!$perso || !canAccess((int)$perso['pe_j_id'])):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Personnage introuvable ou accès refusé.']);
  endif;

  return [$pe_id, $perso];
}

/**
 * Contrôle d'intégrité d'une campagne avant rattachement : elle doit exister,
 * appartenir au propriétaire du personnage (aucun mécanisme d'invitation dans
 * l'application) et partager son ruleset. Ne rend la main que si tout est vert.
 *
 * Volontairement non appelé au détachement : retirer une liaison devenue
 * incohérente (campagne d'un autre ruleset héritée d'un import) doit rester
 * possible.
 */
function verifierCampagneRattachable(PDO $db, bool $is_ajax, int $camp_id, array $perso): void {
  $stmt = $db->prepare('
    SELECT camp_j_id, camp_ruleset_var_id
      FROM dd_campagnes
     WHERE camp_id = ? AND camp_supprime = 0
  ');
  $stmt->execute([$camp_id]);
  $camp = $stmt->fetch();

  if (!$camp):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Campagne introuvable.']);
  endif;
  if ((int)$camp['camp_j_id'] !== (int)$perso['pe_j_id']):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Cette campagne n\'appartient pas au propriétaire du personnage.']);
  endif;
  if ((int)$camp['camp_ruleset_var_id'] !== (int)$perso['pe_ruleset_var_id']):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Cette campagne n\'est pas dans le ruleset du personnage.']);
  endif;
}

/**
 * État renvoyé au client après chaque écriture : nombre de campagnes liées et
 * campagne en cours, tous deux relus en base. Le panneau n'extrapole jamais
 * son état — même règle que le compteur du sélecteur de dons.
 */
function etatCampagnesPersonnage(PDO $db, int $pe_id): array {
  $stmt = $db->prepare('SELECT COUNT(*) FROM dd_campagnes_personnages WHERE cp_pe_id = ?');
  $stmt->execute([$pe_id]);
  $total = (int)$stmt->fetchColumn();

  $stmt = $db->prepare('SELECT pe_camp_id FROM dd_personnages WHERE pe_id = ?');
  $stmt->execute([$pe_id]);
  $courante = (int)$stmt->fetchColumn();

  return ['total' => $total, 'camp_courante' => $courante];
}

/** Rattache / détache un personnage à une campagne. */
function basculerRattachementCampagne(PDO $db, bool $is_ajax, bool $rattacher): void {
  list($pe_id, $perso) = chargerPersonnagePourCampagne($db, $is_ajax);

  $camp_id = intParam($_POST['camp_id'] ?? 0);
  if ($camp_id <= 0):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Campagne manquante.']);
  endif;

  if ($rattacher):
    verifierCampagneRattachable($db, $is_ajax, $camp_id, $perso);
  endif;

  try {
    $db->beginTransaction();

    if ($rattacher):
      // INSERT IGNORE : la clé unique uk_cp (cp_camp_id, cp_pe_id) rend
      // l'ajout idempotent — un double clic ne crée pas de doublon.
      $db->prepare('
        INSERT IGNORE INTO dd_campagnes_personnages (cp_camp_id, cp_pe_id, cp_actif)
        VALUES (?, ?, 1)
      ')->execute([$camp_id, $pe_id]);
    else:
      $db->prepare('
        DELETE FROM dd_campagnes_personnages
         WHERE cp_camp_id = ? AND cp_pe_id = ?
      ')->execute([$camp_id, $pe_id]);

      // Le raccourci ne peut pas survivre à la liaison qu'il raccourcit.
      if ((int)$perso['pe_camp_id'] === $camp_id):
        $db->prepare('UPDATE dd_personnages SET pe_camp_id = NULL WHERE pe_id = ?')
           ->execute([$pe_id]);
      endif;
    endif;

    $db->prepare('UPDATE dd_personnages SET pe_date_modif = NOW() WHERE pe_id = ?')
       ->execute([$pe_id]);

    $db->commit();
  } catch (PDOException $e) {
    $db->rollBack();
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur SQL : ' . $e->getMessage()]);
  }

  $etat = etatCampagnesPersonnage($db, $pe_id);
  repondre($is_ajax, array_merge($etat, [
    'ok'       => true,
    'camp_id'  => $camp_id,
    'rattache' => $rattacher,
    'actif'    => 1,
  ]));
}

/**
 * Désigne la campagne en cours (`pe_camp_id`). `camp_id = 0` signifie « aucune ».
 *
 * La liaison est créée si elle manque, et forcée active : une campagne en cours
 * est par définition une participation en cours — sans quoi getActiveResIds()
 * ignorerait ses sources tout en l'affichant comme campagne du moment.
 */
function definirCampagneCourante(PDO $db, bool $is_ajax): void {
  list($pe_id, $perso) = chargerPersonnagePourCampagne($db, $is_ajax);

  $camp_id = intParam($_POST['camp_id'] ?? 0);

  if ($camp_id > 0):
    verifierCampagneRattachable($db, $is_ajax, $camp_id, $perso);
  endif;

  try {
    $db->beginTransaction();

    if ($camp_id > 0):
      $db->prepare('
        INSERT IGNORE INTO dd_campagnes_personnages (cp_camp_id, cp_pe_id, cp_actif)
        VALUES (?, ?, 1)
      ')->execute([$camp_id, $pe_id]);

      $db->prepare('
        UPDATE dd_campagnes_personnages SET cp_actif = 1
         WHERE cp_camp_id = ? AND cp_pe_id = ?
      ')->execute([$camp_id, $pe_id]);

      $db->prepare('UPDATE dd_personnages SET pe_camp_id = ?, pe_date_modif = NOW() WHERE pe_id = ?')
         ->execute([$camp_id, $pe_id]);
    else:
      $db->prepare('UPDATE dd_personnages SET pe_camp_id = NULL, pe_date_modif = NOW() WHERE pe_id = ?')
         ->execute([$pe_id]);
    endif;

    $db->commit();
  } catch (PDOException $e) {
    $db->rollBack();
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur SQL : ' . $e->getMessage()]);
  }

  $etat = etatCampagnesPersonnage($db, $pe_id);
  repondre($is_ajax, array_merge($etat, [
    'ok'       => true,
    'camp_id'  => $camp_id,
    'rattache' => $camp_id > 0,
    'actif'    => 1,
  ]));
}

/**
 * Bascule `cp_actif` : participation en cours (1) / terminée (0).
 *
 * Marquer une participation terminée sur la campagne en cours efface le
 * raccourci `pe_camp_id` — réciproque de la règle appliquée ci-dessus.
 */
function basculerParticipationCampagne(PDO $db, bool $is_ajax): void {
  list($pe_id, $perso) = chargerPersonnagePourCampagne($db, $is_ajax);

  $camp_id = intParam($_POST['camp_id'] ?? 0);
  if ($camp_id <= 0):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Campagne manquante.']);
  endif;

  $stmt = $db->prepare('
    SELECT cp_actif FROM dd_campagnes_personnages
     WHERE cp_camp_id = ? AND cp_pe_id = ?
  ');
  $stmt->execute([$camp_id, $pe_id]);
  $ligne = $stmt->fetch();

  if (!$ligne):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Le personnage n\'est pas rattaché à cette campagne.']);
  endif;

  $actif = (int)$ligne['cp_actif'] === 1 ? 0 : 1;

  try {
    $db->beginTransaction();

    $db->prepare('
      UPDATE dd_campagnes_personnages SET cp_actif = ?
       WHERE cp_camp_id = ? AND cp_pe_id = ?
    ')->execute([$actif, $camp_id, $pe_id]);

    if ($actif === 0 && (int)$perso['pe_camp_id'] === $camp_id):
      $db->prepare('UPDATE dd_personnages SET pe_camp_id = NULL WHERE pe_id = ?')
         ->execute([$pe_id]);
    endif;

    $db->prepare('UPDATE dd_personnages SET pe_date_modif = NOW() WHERE pe_id = ?')
       ->execute([$pe_id]);

    $db->commit();
  } catch (PDOException $e) {
    $db->rollBack();
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur SQL : ' . $e->getMessage()]);
  }

  $etat = etatCampagnesPersonnage($db, $pe_id);
  repondre($is_ajax, array_merge($etat, [
    'ok'       => true,
    'camp_id'  => $camp_id,
    'rattache' => true,
    'actif'    => $actif,
  ]));
}
