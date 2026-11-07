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
//   - enregistrerNls          (SP-PE6 — affectation NLS prestige DD3.5)
//   - definirPorteeNotes      (SP-NO4 — pe_notes_scope, écriture immédiate)
//   - affecterPersonnage / retirerAffectation (SP-PE18 — écriture immédiate)
//   - groupePersonnages       (SP-PE19 — actions groupées de la liste :
//                              campagne en cours, affectation à un joueur)
//   - ajouterPossession / modifierPossession / retirerPossession
//                             (SP-PO8 — inventaire, écriture immédiate)
//   - enregistrerCompose      (SP-PO10 — objet composé DD3.5, recalcul serveur)
//   - consommerPossession, utiliserSortParchemin (SP-PO11 — potion bue, charge, sort lu)
//
// Toutes les actions :
//   - Vérifient le CSRF (verifyCsrf())
//   - Vérifient le droit sur le personnage (peutGererPersonnage : propriétaire,
//     admin ou MJ — SP-PE18) ; la suppression reste au propriétaire / admin
//     (canAccess sur pe_j_id)
//   - Sont exécutées dans une transaction PDO
//   - Renvoient JSON {ok: bool, erreur?: string, id?: int, url_fiche?: string}
//     en mode ajax ; redirection sinon.
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';
require_once '../include/personnage_helpers.php';
// Formatage des prix et poids des possessions (SP-PO8)
require_once '../include/liste-parser.php';
// Moteur de composition des objets magiques DD3.5 (SP-PO10)
require_once '../include/objet-compose.php';

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

      // Choix de capacités de classe (SP-CH)
      $db->prepare('DELETE FROM dd_personnages_choix WHERE pech_pe_id = ?')
         ->execute([$pe_id]);

      // Possessions (SP-PO6) : éléments des objets composés, puis l'inventaire
      $db->prepare('
        DELETE ppe FROM dd_personnages_possessions_elements ppe
          JOIN dd_personnages_possessions pp ON pp.pp_id = ppe.ppe_pp_id
         WHERE pp.pp_pe_id = ?
      ')->execute([$pe_id]);
      $db->prepare('DELETE FROM dd_personnages_possessions WHERE pp_pe_id = ?')
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

  // --- Choix liés aux capacités de classe (SP-CH) — écriture immédiate
  case 'enregistrerChoixCapacite':
    enregistrerChoixCapacite($db, $is_ajax);
    break;

  case 'effacerChoixCapacite':
    effacerChoixCapacite($db, $is_ajax);
    break;

  // --- Sorts du personnage (SP-PE7b) — écriture immédiate, portée par classe
  case 'ajouterSort':
  case 'retirerSort':
    basculerSort($db, $is_ajax, $action === 'ajouterSort');
    break;

  case 'basculerGrimoire':
    basculerGrimoire($db, $is_ajax);
    break;

  case 'preparerSort':
  case 'retirerPrepare':
    basculerPrepare($db, $is_ajax, $action === 'preparerSort');
    break;

  case 'reinitialiserPrepares':
    reinitialiserPrepares($db, $is_ajax);
    break;

  case 'enregistrerNls':
    enregistrerNls($db, $is_ajax);
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

  case 'definirPorteeNotes':
    definirPorteeNotes($db, $is_ajax);
    break;

  // --------------------------------------------------------
  // AFFECTATION À UN JOUEUR (SP-PE18 — écriture immédiate)
  // --------------------------------------------------------
  case 'affecterPersonnage':
    affecterPersonnage($db, $is_ajax);
    break;

  case 'retirerAffectation':
    retirerAffectation($db, $is_ajax);
    break;

  // --------------------------------------------------------
  // ACTIONS GROUPÉES DE LA LISTE (SP-PE19)
  // --------------------------------------------------------
  case 'groupePersonnages':
    groupePersonnages($db, $is_ajax);
    break;

  // --------------------------------------------------------
  // POSSESSIONS (SP-PO8 — écriture immédiate)
  // --------------------------------------------------------
  case 'ajouterPossession':
    ajouterPossession($db, $is_ajax);
    break;

  case 'modifierPossession':
    modifierPossession($db, $is_ajax);
    break;

  case 'retirerPossession':
    retirerPossession($db, $is_ajax);
    break;

  case 'enregistrerCompose':
    enregistrerCompose($db, $is_ajax);
    break;

  case 'consommerPossession':
    consommerPossession($db, $is_ajax);
    break;

  case 'utiliserSortParchemin':
    utiliserSortParchemin($db, $is_ajax);
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

  // Modificateurs de sauvegarde, un par caractéristique (SP-PE11). Bornés
  // comme l'initiative : ce sont des modificateurs, pas des scores.
  $saves = [];
  foreach (['pe_for','pe_con','pe_dex','pe_int','pe_sag','pe_cha'] as $c):
    $saves[$c . '_save'] = max(-20, min(40, intParam($_POST[$c . '_save'] ?? 0)));
  endforeach;

  $init = max(-20, min(40, intParam($_POST['pe_init'] ?? 0)));
  $ca   = max(0, min(99,   intParam($_POST['pe_ca'] ?? 10)));
  $pv   = max(0, min(9999, intParam($_POST['pe_pv'] ?? 0)));

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
    $stmt = $db->prepare('SELECT pe_id, pe_j_id, pe_affecte_par_j_id, pe_ruleset_var_id FROM dd_personnages WHERE pe_id = ?');
    $stmt->execute([$pe_id]);
    $row = $stmt->fetch();
    if (!$row || !peutGererPersonnage($db, $row)):
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
           pe_for_save, pe_con_save, pe_dex_save,
           pe_int_save, pe_sag_save, pe_cha_save,
           pe_init, pe_ca, pe_pv, pe_background,
           pe_ruleset_var_id, pe_date_creation, pe_date_modif)
        VALUES
          (?, ?, ?, ?, ?, ?, ?,
           ?, ?, ?, ?, ?, ?,
           ?, ?, ?,
           ?, ?, ?,
           ?, ?, ?, ?,
           ?, NOW(), NOW())
      ';
      $params = [
        $nom, $sexe, $j_id, $ra_id, $arc_id, $hi_id_db, $al_id_db,
        $caracs['pe_for'], $caracs['pe_con'], $caracs['pe_dex'],
        $caracs['pe_int'], $caracs['pe_sag'], $caracs['pe_cha'],
        $saves['pe_for_save'], $saves['pe_con_save'], $saves['pe_dex_save'],
        $saves['pe_int_save'], $saves['pe_sag_save'], $saves['pe_cha_save'],
        $init, $ca, $pv, $background,
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
               pe_for_save   = ?,
               pe_con_save   = ?,
               pe_dex_save   = ?,
               pe_int_save   = ?,
               pe_sag_save   = ?,
               pe_cha_save   = ?,
               pe_init       = ?,
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
        $saves['pe_for_save'], $saves['pe_con_save'], $saves['pe_dex_save'],
        $saves['pe_int_save'], $saves['pe_sag_save'], $saves['pe_cha_save'],
        $init, $ca, $pv, $background,
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
  $stmt = $db->prepare('SELECT pe_id, pe_j_id, pe_affecte_par_j_id FROM dd_personnages WHERE pe_id = ?');
  $stmt->execute([$pe_id]);
  $row = $stmt->fetch();
  if (!$row || !peutGererPersonnage($db, $row)):
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

    // Choix de capacités (SP-CH) devenus sans objet : ceux d'une classe retirée
    // du personnage, et ceux d'un niveau que la classe n'atteint plus. Ils sont
    // effacés, avec les dons qu'ils avaient posés. Le niveau de référence est
    // celui de getPersonnageClasses() relu après réinsertion (une sous-classe
    // DD2024 suit sa classe porteuse).
    $classes_apres = getPersonnageClasses($db, $pe_id);
    $niveau_par_cla = [];
    foreach ($classes_apres as $k):
      $niveau_par_cla[(int)$k['pc_cla_id']] = niveauReferenceClasse($classes_apres, $k);
    endforeach;

    $stmt_choix = $db->prepare('SELECT pech_id, pech_cla_id, pech_niveau, pech_do_id FROM dd_personnages_choix WHERE pech_pe_id = ?');
    $stmt_choix->execute([$pe_id]);
    foreach ($stmt_choix->fetchAll() as $o):
      $niv_max = $niveau_par_cla[(int)$o['pech_cla_id']] ?? 0; // 0 = classe retirée
      if ((int)$o['pech_niveau'] <= $niv_max) continue;
      $db->prepare('DELETE FROM dd_personnages_choix WHERE pech_id = ?')->execute([(int)$o['pech_id']]);
      liberDonChoix($db, $pe_id, (int)$o['pech_id'], $o['pech_do_id'] !== null ? (int)$o['pech_do_id'] : null);
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
  $stmt = $db->prepare('SELECT pe_id, pe_j_id, pe_affecte_par_j_id, pe_ruleset_var_id FROM dd_personnages WHERE pe_id = ?');
  $stmt->execute([$pe_id]);
  $row = $stmt->fetch();
  if (!$row || !peutGererPersonnage($db, $row)):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Accès refusé.']);
  endif;
  $ruleset_id = (int)$row['pe_ruleset_var_id'];
  $max_saisie = ($ruleset_id === 2) ? 2 : 99; // DD2024 : 0/1/2 ; DD3.5 : borne technique

  $comp_post = $_POST['competences'] ?? [];
  if (!is_array($comp_post)):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Format de données invalide.']);
  endif;

  // Lecture, bornage et dédoublonnage. Une ligne sans rang est gardée si elle
  // porte un modificateur divers (SP-PE20) ; sinon elle est ignorée.
  $lignes = [];
  foreach ($comp_post as $row_post):
    if (!is_array($row_post)) continue;
    $comp_id  = (int)($row_post['comp_id']  ?? 0);
    $maitrise = max(0, min((int)($row_post['maitrise'] ?? 0), $max_saisie));
    $divers   = max(-99, min((int)($row_post['divers'] ?? 0), 99));
    if ($comp_id <= 0 || ($maitrise === 0 && $divers === 0)) continue;
    $libelle  = ($divers !== 0) ? mb_substr(trim((string)($row_post['libelle'] ?? '')), 0, 200) : '';
    $lignes[$comp_id] = [
      'maitrise' => $maitrise,
      'divers'   => $divers,
      'libelle'  => $libelle !== '' ? $libelle : null,
    ];
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
        INSERT INTO dd_personnages_competences
          (pec_pe_id, pec_comp_id, pec_maitrise, pec_mod_divers, pec_mod_libelle)
        VALUES (?, ?, ?, ?, ?)
      ');
      foreach ($lignes as $comp_id => $l):
        $stmt_ins->execute([$pe_id, $comp_id, $l['maitrise'], $l['divers'], $l['libelle']]);
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

// ============================================================
// SORTS DU PERSONNAGE (SP-PE7b)
// ============================================================
//
// Écriture immédiate, sur le modèle du sélecteur de dons (Q8, D-MAG13) et
// TOUJOURS PORTÉE PAR CLASSE : un commit global couvrant plusieurs classes
// lanceuses serait dangereux en multiclassage — une sauvegarde toucherait deux
// listes à la fois.

/**
 * Garde commune : le personnage appartient à l'utilisateur, la classe est bien
 * l'une des siennes, et le sort relève de son ruleset.
 *
 * Le contrôle du sort vaut aussi au RETRAIT : un identifiant forgé ne doit pas
 * servir à sonder la base (même principe que basculerDon).
 *
 * @return array [pe_id, pc_id, cla_id, so_id]
 */
function gardeSortPersonnage(PDO $db, bool $is_ajax, bool $exigePc): array {
  $pe_id = intParam($_POST['pe_id'] ?? 0);
  $pc_id = intParam($_POST['pc_id'] ?? 0);
  $so_id = intParam($_POST['so_id'] ?? 0);

  if ($pe_id <= 0 || ($exigePc && $pc_id <= 0)):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Identifiant manquant.']);
  endif;

  $stmt = $db->prepare('SELECT pe_id, pe_j_id, pe_affecte_par_j_id, pe_ruleset_var_id FROM dd_personnages WHERE pe_id = ?');
  $stmt->execute([$pe_id]);
  $perso = $stmt->fetch();
  if (!$perso || !peutGererPersonnage($db, $perso)):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Accès refusé.']);
  endif;

  $cla_id = intParam($_POST['cla_id'] ?? 0);
  if ($pc_id > 0):
    $stmt = $db->prepare('SELECT pc_cla_id FROM dd_personnages_classes WHERE pc_id = ? AND pc_pe_id = ?');
    $stmt->execute([$pc_id, $pe_id]);
    $cla_id = (int)$stmt->fetchColumn();
    if (!$cla_id):
      repondre($is_ajax, ['ok' => false, 'erreur' => 'Cette classe n\'est pas celle du personnage.']);
    endif;
  endif;

  if ($so_id > 0):
    $stmt = $db->prepare('SELECT so_id FROM dd_sorts WHERE so_id = ? AND so_ruleset_var_id = ?');
    $stmt->execute([$so_id, (int)$perso['pe_ruleset_var_id']]);
    if (!$stmt->fetchColumn()):
      repondre($is_ajax, ['ok' => false, 'erreur' => 'Ce sort n\'appartient pas au ruleset du personnage.']);
    endif;
  endif;

  return ['pe_id' => $pe_id, 'pc_id' => $pc_id, 'cla_id' => $cla_id, 'so_id' => $so_id,
          'ruleset' => (int)$perso['pe_ruleset_var_id']];
}

/** Ajoute ou retire un sort du répertoire d'une classe (dd_personnages_sorts). */
function basculerSort(PDO $db, bool $is_ajax, bool $ajouter): void {
  $g = gardeSortPersonnage($db, $is_ajax, true);
  try {
    if ($ajouter):
      // INSERT IGNORE : uk_pes (pes_pc_id, pes_so_id) existe bien — vérifié
      // en base, contrairement à la clé fantôme de dd_classe_niveau. Un double
      // clic ne crée donc pas de doublon.
      $db->prepare('INSERT IGNORE INTO dd_personnages_sorts (pes_pc_id, pes_so_id, pes_compris) VALUES (?, ?, 0)')
         ->execute([$g['pc_id'], $g['so_id']]);
    else:
      $db->prepare('DELETE FROM dd_personnages_sorts WHERE pes_pc_id = ? AND pes_so_id = ?')
         ->execute([$g['pc_id'], $g['so_id']]);
    endif;
    $db->prepare('UPDATE dd_personnages SET pe_date_modif = NOW() WHERE pe_id = ?')->execute([$g['pe_id']]);
    $stmt = $db->prepare('SELECT COUNT(*), COALESCE(SUM(pes_compris),0) FROM dd_personnages_sorts WHERE pes_pc_id = ?');
    $stmt->execute([$g['pc_id']]);
    [$total, $compris] = $stmt->fetch(PDO::FETCH_NUM);
  } catch (PDOException $e) {
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur SQL : ' . $e->getMessage()]);
  }
  repondre($is_ajax, ['ok' => true, 'possede' => $ajouter, 'total' => (int)$total, 'compris' => (int)$compris]);
}

/**
 * « Recopier dans le grimoire » et son inverse : bascule pes_compris.
 *
 * Lecture A (D-MAG6) : un sort CONNU est à disposition — parchemin ou grimoire
 * ramassé — mais n'est PRÉPARABLE qu'une fois COMPRIS, c'est-à-dire recopié.
 */
function basculerGrimoire(PDO $db, bool $is_ajax): void {
  $g = gardeSortPersonnage($db, $is_ajax, true);
  $compris = !empty($_POST['compris']) ? 1 : 0;
  try {
    $db->prepare('UPDATE dd_personnages_sorts SET pes_compris = ? WHERE pes_pc_id = ? AND pes_so_id = ?')
       ->execute([$compris, $g['pc_id'], $g['so_id']]);
    $db->prepare('UPDATE dd_personnages SET pe_date_modif = NOW() WHERE pe_id = ?')->execute([$g['pe_id']]);
  } catch (PDOException $e) {
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur SQL : ' . $e->getMessage()]);
  }
  repondre($is_ajax, ['ok' => true, 'compris' => (bool)$compris]);
}

/**
 * Ajoute ou retire UN EXEMPLAIRE préparé d'un sort, pour une classe.
 *
 * dd_personnages_sorts_prepares n'a VOLONTAIREMENT pas de clé unique : un
 * magicien DD3.5 peut préparer plusieurs fois le même sort, en version normale
 * et en versions métamagiques, chacune occupant son emplacement. La version
 * sans métamagie tient sa quantité dans `pesp_nb` (SP-PE10e) ; les versions
 * métamagiques auront leur propre ligne le jour où elles seront saisies.
 *
 * LA QUANTITÉ EST UNE RÈGLE DD3.5. En DD2024 la liste préparée est un ENSEMBLE
 * de sorts distincts — on lance n'importe lequel avec l'emplacement de son
 * choix, préparer deux fois le même n'a pas de sens. D'où la bascule
 * présent/absent conservée pour ce ruleset.
 *
 * `pesp_nb` vaut 0 par défaut en base alors qu'un exemplaire préparé compte
 * pour 1 : toute lecture passe donc par GREATEST(pesp_nb, 1), comme le total.
 *
 * Le compteur renvoyé ne totalise que pesp_origine = 0 : les sorts toujours
 * préparés ne pèsent pas sur le plafond (Q7).
 */
function basculerPrepare(PDO $db, bool $is_ajax, bool $ajouter): void {
  $g = gardeSortPersonnage($db, $is_ajax, false);
  if ($g['cla_id'] <= 0):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Classe manquante.']);
  endif;
  $est35 = ((int)$g['ruleset'] === 1);
  try {
    $stmt = $db->prepare('SELECT pesp_id, GREATEST(pesp_nb, 1) AS nb
                            FROM dd_personnages_sorts_prepares
                           WHERE pesp_pe_id = ? AND pesp_cla_id = ? AND pesp_so_id = ?
                             AND pesp_metamagie IS NULL AND pesp_origine = 0');
    $stmt->execute([$g['pe_id'], $g['cla_id'], $g['so_id']]);
    $ligne = $stmt->fetch();
    $nb    = $ligne ? (int)$ligne['nb'] : 0;

    if ($ajouter):
      if (!$ligne):
        $db->prepare('INSERT INTO dd_personnages_sorts_prepares
                        (pesp_pe_id, pesp_cla_id, pesp_so_id, pesp_nb, pesp_origine)
                      VALUES (?, ?, ?, 1, 0)')
           ->execute([$g['pe_id'], $g['cla_id'], $g['so_id']]);
        $nb = 1;
      elseif ($est35):
        $nb++;
        $db->prepare('UPDATE dd_personnages_sorts_prepares SET pesp_nb = ? WHERE pesp_id = ?')
           ->execute([$nb, (int)$ligne['pesp_id']]);
      endif;
    elseif ($ligne):
      if ($est35 && $nb > 1):
        $nb--;
        $db->prepare('UPDATE dd_personnages_sorts_prepares SET pesp_nb = ? WHERE pesp_id = ?')
           ->execute([$nb, (int)$ligne['pesp_id']]);
      else:
        // Le dernier exemplaire retiré emporte la ligne.
        $db->prepare('DELETE FROM dd_personnages_sorts_prepares WHERE pesp_id = ?')
           ->execute([(int)$ligne['pesp_id']]);
        $nb = 0;
      endif;
    endif;

    $db->prepare('UPDATE dd_personnages SET pe_date_modif = NOW() WHERE pe_id = ?')->execute([$g['pe_id']]);
    $stmt = $db->prepare('SELECT COALESCE(SUM(GREATEST(pesp_nb,1)),0) FROM dd_personnages_sorts_prepares
                           WHERE pesp_pe_id = ? AND pesp_cla_id = ? AND pesp_origine = 0');
    $stmt->execute([$g['pe_id'], $g['cla_id']]);
    $total = (int)$stmt->fetchColumn();
  } catch (PDOException $e) {
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur SQL : ' . $e->getMessage()]);
  }
  repondre($is_ajax, ['ok' => true, 'possede' => $nb > 0, 'nb' => $nb, 'total' => $total]);
}

/**
 * Vide la liste préparée d'une classe — la contrepartie de l'écriture immédiate
 * retenue en Q8 : refaire sa liste du matin en un geste plutôt qu'un par un.
 *
 * Ne touche QUE pesp_origine = 0 : les sorts toujours préparés ne sont pas des
 * choix du joueur et ne doivent pas disparaître.
 */
function reinitialiserPrepares(PDO $db, bool $is_ajax): void {
  $g = gardeSortPersonnage($db, $is_ajax, false);
  if ($g['cla_id'] <= 0):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Classe manquante.']);
  endif;
  try {
    $stmt = $db->prepare('DELETE FROM dd_personnages_sorts_prepares
                           WHERE pesp_pe_id = ? AND pesp_cla_id = ? AND pesp_origine = 0');
    $stmt->execute([$g['pe_id'], $g['cla_id']]);
    $supprimes = $stmt->rowCount();
    $db->prepare('UPDATE dd_personnages SET pe_date_modif = NOW() WHERE pe_id = ?')->execute([$g['pe_id']]);
  } catch (PDOException $e) {
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur SQL : ' . $e->getMessage()]);
  }
  repondre($is_ajax, ['ok' => true, 'supprimes' => $supprimes, 'total' => 0]);
}

function basculerDon(PDO $db, bool $is_ajax, int $j_id, bool $ajouter): void {
  $pe_id = intParam($_POST['pe_id'] ?? 0);
  $do_id = intParam($_POST['do_id'] ?? 0);

  if ($pe_id <= 0 || $do_id <= 0):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Identifiant manquant.']);
  endif;

  // Contrôle propriétaire + ruleset du personnage
  $stmt = $db->prepare('SELECT pe_id, pe_j_id, pe_affecte_par_j_id, pe_ruleset_var_id FROM dd_personnages WHERE pe_id = ?');
  $stmt->execute([$pe_id]);
  $row = $stmt->fetch();
  if (!$row || !peutGererPersonnage($db, $row)):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Accès refusé.']);
  endif;

  // Intégrité : le don doit exister dans le ruleset du personnage.
  // Contrôlé aussi au retrait — un id forgé ne doit pas servir à sonder la base.
  $stmt = $db->prepare('SELECT do_id FROM dd_dons WHERE do_id = ? AND do_ruleset_var_id = ?');
  $stmt->execute([$do_id, (int)$row['pe_ruleset_var_id']]);
  if (!$stmt->fetchColumn()):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Ce don n\'appartient pas au ruleset du personnage.']);
  endif;

  // Un don posé par un emplacement de capacité (SP-CH) se retire depuis cet
  // emplacement, sinon le bloc Capacités afficherait un choix sans don.
  if (!$ajouter):
    $stmt = $db->prepare('SELECT 1 FROM dd_personnages_dons WHERE ped_pe_id = ? AND ped_do_id = ? AND ped_pech_id IS NOT NULL');
    $stmt->execute([$pe_id, $do_id]);
    if ($stmt->fetchColumn()):
      repondre($is_ajax, ['ok' => false, 'erreur' => 'Ce don vient d\'une capacité de classe : retirez-le depuis le bloc Capacités de classe.']);
    endif;
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
// CHOIX LIÉS AUX CAPACITÉS DE CLASSE (SP-CH)
// ============================================================
// Reçoit en POST : pe_id, cla_id, cap_id, niveau, rang,
//   puis texte (capacité en mode « texte ») ou do_id (mode « don »), avec en option precision
//   (texte libre qui précise le don : l'arme d'une Spécialisation martiale, une école…).
// Un emplacement = une ligne de dd_personnages_choix, identifiée par sa clé
// naturelle (personnage, classe, capacité, niveau, rang) — pas par cc_id, que
// l'enregistrement d'une classe dans le compendium régénère.
// Un choix de don pose aussi le don dans dd_personnages_dons, marqué par
// ped_pech_id ; un don que le joueur possédait déjà n'est ni marqué ni retiré.

// Contrôle commun : propriétaire, clé d'emplacement. Renvoie le contexte.
function choixCapaciteCle(PDO $db, bool $is_ajax): array {
  $cle = [
    'pe_id'  => intParam($_POST['pe_id']  ?? 0),
    'cla_id' => intParam($_POST['cla_id'] ?? 0),
    'cap_id' => intParam($_POST['cap_id'] ?? 0),
    'niveau' => intParam($_POST['niveau'] ?? 0),
    'rang'   => intParam($_POST['rang']   ?? 0),
  ];
  foreach ($cle as $v):
    if ($v <= 0):
      repondre($is_ajax, ['ok' => false, 'erreur' => 'Identifiant manquant.']);
    endif;
  endforeach;

  $stmt = $db->prepare('SELECT pe_id, pe_j_id, pe_affecte_par_j_id, pe_ruleset_var_id FROM dd_personnages WHERE pe_id = ?');
  $stmt->execute([$cle['pe_id']]);
  $row = $stmt->fetch();
  if (!$row || !peutGererPersonnage($db, $row)):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Accès refusé.']);
  endif;
  $cle['ruleset_id'] = (int)$row['pe_ruleset_var_id'];
  return $cle;
}

// Libère le don posé par un emplacement. Si un autre emplacement désigne le
// même don, la marque lui passe plutôt que de retirer le don.
function liberDonChoix(PDO $db, int $pe_id, int $pech_id, ?int $do_id): void {
  $db->prepare('DELETE FROM dd_personnages_dons WHERE ped_pe_id = ? AND ped_pech_id = ?')
     ->execute([$pe_id, $pech_id]);
  if ($do_id === null) return;

  $stmt = $db->prepare('
    SELECT pech_id FROM dd_personnages_choix
     WHERE pech_pe_id = ? AND pech_do_id = ? AND pech_id <> ? LIMIT 1
  ');
  $stmt->execute([$pe_id, $do_id, $pech_id]);
  $autre = $stmt->fetchColumn();
  if ($autre):
    $db->prepare('INSERT IGNORE INTO dd_personnages_dons (ped_pe_id, ped_do_id, ped_niveau, ped_pech_id) VALUES (?, ?, NULL, ?)')
       ->execute([$pe_id, $do_id, (int)$autre]);
  endif;
}

function enregistrerChoixCapacite(PDO $db, bool $is_ajax): void {
  $c     = choixCapaciteCle($db, $is_ajax);
  $pe_id = $c['pe_id'];

  // La classe est bien celle du personnage et le niveau est atteint
  $classes = getPersonnageClasses($db, $pe_id);
  $classe  = null;
  foreach ($classes as $k):
    if ((int)$k['pc_cla_id'] === $c['cla_id']):
      $classe = $k;
    endif;
  endforeach;
  if (!$classe || $c['niveau'] > niveauReferenceClasse($classes, $classe)):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Ce choix n\'est pas (encore) accordé au personnage.']);
  endif;

  // L'emplacement existe dans le compendium
  $stmt = $db->prepare('
    SELECT cap.cap_choix_mode, cap.cap_choix_dado_id, cap.cap_choix_guerrier, cc.cc_nb_choix
      FROM dd_classe_capacite cc
      JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
     WHERE cc.cc_cla_id = ? AND cc.cc_cap_id = ? AND cc.cc_niveau = ?
     LIMIT 1
  ');
  $stmt->execute([$c['cla_id'], $c['cap_id'], $c['niveau']]);
  $emp = $stmt->fetch();
  if (!$emp || $emp['cap_choix_mode'] === '' || $c['rang'] > (int)$emp['cc_nb_choix']):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Emplacement de choix inexistant.']);
  endif;

  $do_id     = null;
  $texte     = null;
  $precision = null;   // texte libre qui accompagne un don (arme, école, compétence…) — mode don seulement
  if ($emp['cap_choix_mode'] === 'texte'):
    $texte = trim(strParam($_POST['texte'] ?? ''));
    if ($texte === ''):
      repondre($is_ajax, ['ok' => false, 'erreur' => 'Saisissez votre choix, ou effacez-le.']);
    endif;
    $texte = mb_substr($texte, 0, 255);
  else:
    $do_id = intParam($_POST['do_id'] ?? 0);
    $precision = mb_substr(trim(strParam($_POST['precision'] ?? '')), 0, 100);
    $precision = $precision === '' ? null : $precision;
    // Le don doit exister dans le ruleset du personnage (et dans la catégorie
    // proposée, le cas échéant) — un id forgé ne passe pas.
    $stmt = $db->prepare('SELECT do.do_id FROM dd_dons do WHERE do.do_id = ? AND do.do_ruleset_var_id = ?');
    $stmt->execute([$do_id, $c['ruleset_id']]);
    if ($stmt->fetchColumn() === false):
      repondre($is_ajax, ['ok' => false, 'erreur' => 'Ce don n\'appartient pas au ruleset du personnage.']);
    endif;
    // Restriction de la capacité : dons de guerrier et/ou catégorie (SP-DO)
    [$sql_restriction, $params_restriction] = conditionDonsChoix((int)$emp['cap_choix_dado_id'], (int)$emp['cap_choix_guerrier'] === 1);
    $stmt = $db->prepare('SELECT 1 FROM dd_dons do WHERE do.do_id = ?' . $sql_restriction);
    $stmt->execute(array_merge([$do_id], $params_restriction));
    if (!$stmt->fetchColumn()):
      repondre($is_ajax, ['ok' => false, 'erreur' => ((int)$emp['cap_choix_guerrier'] === 1)
        ? 'Ce don n\'est pas un don de guerrier.'
        : 'Ce don n\'est pas dans la catégorie proposée.']);
    endif;
  endif;

  try {
    $db->beginTransaction();

    $stmt = $db->prepare('
      SELECT pech_id, pech_do_id FROM dd_personnages_choix
       WHERE pech_pe_id = ? AND pech_cla_id = ? AND pech_cap_id = ? AND pech_niveau = ? AND pech_rang = ?
    ');
    $stmt->execute([$pe_id, $c['cla_id'], $c['cap_id'], $c['niveau'], $c['rang']]);
    $ancien = $stmt->fetch();

    if ($ancien):
      $pech_id = (int)$ancien['pech_id'];
      $db->prepare('UPDATE dd_personnages_choix SET pech_do_id = ?, pech_texte = ?, pech_precision = ? WHERE pech_id = ?')
         ->execute([$do_id, $texte, $precision, $pech_id]);
      $ancien_do = $ancien['pech_do_id'] !== null ? (int)$ancien['pech_do_id'] : null;
      if ($ancien_do !== null && $ancien_do !== $do_id):
        liberDonChoix($db, $pe_id, $pech_id, $ancien_do);
      endif;
    else:
      $db->prepare('
        INSERT INTO dd_personnages_choix (pech_pe_id, pech_cla_id, pech_cap_id, pech_niveau, pech_rang, pech_do_id, pech_texte, pech_precision)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ')->execute([$pe_id, $c['cla_id'], $c['cap_id'], $c['niveau'], $c['rang'], $do_id, $texte, $precision]);
      $pech_id = (int)$db->lastInsertId();
    endif;

    // Mode « don » : le don rejoint le bloc Dons, sauf s'il y figure déjà
    // (saisi à la main ou posé par un autre emplacement).
    if ($do_id !== null):
      $db->prepare('
        INSERT IGNORE INTO dd_personnages_dons (ped_pe_id, ped_do_id, ped_niveau, ped_pech_id)
        VALUES (?, ?, ?, ?)
      ')->execute([$pe_id, $do_id, $c['niveau'], $pech_id]);
    endif;

    $db->prepare('UPDATE dd_personnages SET pe_date_modif = NOW() WHERE pe_id = ?')->execute([$pe_id]);
    $db->commit();
  } catch (PDOException $e) {
    $db->rollBack();
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur SQL : ' . $e->getMessage()]);
  }

  $ctx = getCapacitesClassesPersonnage($db, $pe_id, $classes);
  repondre($is_ajax, ['ok' => true, 'restant' => $ctx['restant']]);
}

function effacerChoixCapacite(PDO $db, bool $is_ajax): void {
  $c     = choixCapaciteCle($db, $is_ajax);
  $pe_id = $c['pe_id'];

  try {
    $db->beginTransaction();

    $stmt = $db->prepare('
      SELECT pech_id, pech_do_id FROM dd_personnages_choix
       WHERE pech_pe_id = ? AND pech_cla_id = ? AND pech_cap_id = ? AND pech_niveau = ? AND pech_rang = ?
    ');
    $stmt->execute([$pe_id, $c['cla_id'], $c['cap_id'], $c['niveau'], $c['rang']]);
    $ancien = $stmt->fetch();

    if ($ancien):
      $db->prepare('DELETE FROM dd_personnages_choix WHERE pech_id = ?')->execute([(int)$ancien['pech_id']]);
      liberDonChoix($db, $pe_id, (int)$ancien['pech_id'], $ancien['pech_do_id'] !== null ? (int)$ancien['pech_do_id'] : null);
      $db->prepare('UPDATE dd_personnages SET pe_date_modif = NOW() WHERE pe_id = ?')->execute([$pe_id]);
    endif;

    $db->commit();
  } catch (PDOException $e) {
    $db->rollBack();
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur SQL : ' . $e->getMessage()]);
  }

  $ctx = getCapacitesClassesPersonnage($db, $pe_id, getPersonnageClasses($db, $pe_id));
  repondre($is_ajax, ['ok' => true, 'restant' => $ctx['restant']]);
}

// ============================================================
// ENREGISTREMENT DE L'AFFECTATION NLS PRESTIGE (SP-PE6 — DD3.5)
// ============================================================
// Reçoit en POST :
//   pe_id                  int
//   nls[][pc_prestige]     int  — pc_id de la classe de prestige (source)
//   nls[][niveau]          int  — niveau dans la classe de prestige
//   nls[][pc_base]         int  — pc_id de la classe de base réceptrice
//
// Pattern DELETE + INSERT en transaction (comme Classes et Compétences).
// Seuls les niveaux réellement affectés sont postés : une liste vide est
// valide et efface toute l'affectation (les niveaux repassent « À affecter »).
//
// Validations : intégrité uniquement (archi §7.1) — propriétaire, ruleset
// DD3.5, complétude de chaque affectation postée : les deux pc_id
// appartiennent au personnage, la source est une classe de prestige, le
// niveau est dans les bornes détenues, ce niveau fait progresser le NLS
// (drapeaux cn_niveauSort* de dd_classe_niveau) et la réceptrice est une
// classe de base lanceuse compatible avec le type de magie du niveau
// (effectif → toutes ; arcane → cla_mag_id 1 ; divin → cla_mag_id 2).
// Aucune règle de jeu au-delà — pas de contrôle de prérequis de classe.

function enregistrerNls(PDO $db, bool $is_ajax): void {
  $pe_id = intParam($_POST['pe_id'] ?? 0);
  if ($pe_id <= 0):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Identifiant manquant.']);
  endif;

  // Contrôle propriétaire + ruleset (l'affectation NLS est du DD3.5 pur)
  $stmt = $db->prepare('SELECT pe_id, pe_j_id, pe_affecte_par_j_id, pe_ruleset_var_id FROM dd_personnages WHERE pe_id = ?');
  $stmt->execute([$pe_id]);
  $row = $stmt->fetch();
  if (!$row || !peutGererPersonnage($db, $row)):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Accès refusé.']);
  endif;
  if ((int)$row['pe_ruleset_var_id'] !== 1):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'L\'affectation NLS n\'existe qu\'en DD3.5.']);
  endif;

  $nls_post = $_POST['nls'] ?? [];
  if (!is_array($nls_post)):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Format de données invalide.']);
  endif;

  // Classes du personnage, indexées par pc_id, pour tous les contrôles
  $stmt = $db->prepare('
    SELECT pc.pc_id, pc.pc_cla_id, pc.pc_niveau,
           cla.cla_clt_id, cla.cla_mag_id
      FROM dd_personnages_classes pc
      JOIN dd_classes cla ON cla.cla_id = pc.pc_cla_id
     WHERE pc.pc_pe_id = ?
  ');
  $stmt->execute([$pe_id]);
  $classes = [];
  foreach ($stmt->fetchAll() as $c):
    $classes[(int)$c['pc_id']] = $c;
  endforeach;

  // Lecture, contrôle d'intégrité et dédoublonnage sur (prestige, niveau)
  $lignes = [];
  foreach ($nls_post as $row_post):
    $pc_prestige = intParam($row_post['pc_prestige'] ?? 0);
    $niveau      = intParam($row_post['niveau']      ?? 0);
    $pc_base     = intParam($row_post['pc_base']     ?? 0);

    if ($pc_prestige <= 0 && $niveau <= 0 && $pc_base <= 0) continue; // ligne vide ignorée

    // Complétude de l'affectation : les trois champs, ou rien
    if ($pc_prestige <= 0 || $niveau <= 0 || $pc_base <= 0):
      repondre($is_ajax, ['ok' => false, 'erreur' => 'Affectation incomplète.']);
    endif;

    $prestige = $classes[$pc_prestige] ?? null;
    $base     = $classes[$pc_base]     ?? null;
    if (!$prestige || (int)$prestige['cla_clt_id'] !== 2):
      repondre($is_ajax, ['ok' => false, 'erreur' => 'Classe de prestige invalide.']);
    endif;
    if (!$base || (int)$base['cla_clt_id'] !== 1 || (int)$base['cla_mag_id'] <= 0):
      repondre($is_ajax, ['ok' => false, 'erreur' => 'La classe réceptrice doit être une classe de base lanceuse de sorts.']);
    endif;
    if ($niveau > (int)$prestige['pc_niveau']):
      repondre($is_ajax, ['ok' => false, 'erreur' => 'Niveau supérieur au niveau détenu dans la classe de prestige.']);
    endif;

    // Drapeaux du niveau : il doit faire progresser le NLS, et la réceptrice
    // doit être compatible avec le type de magie concerné.
    $stmt_cn = $db->prepare('
      SELECT cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif
        FROM dd_classe_niveau
       WHERE cn_cla_id = ? AND cn_niveau = ?
    ');
    $stmt_cn->execute([(int)$prestige['pc_cla_id'], $niveau]);
    $cn = $stmt_cn->fetch();
    $compatible = $cn && (
      (int)$cn['cn_niveauSortEffectif'] === 1
      || ((int)$cn['cn_niveauSortArcane'] === 1 && (int)$base['cla_mag_id'] === 1)
      || ((int)$cn['cn_niveauSortDivin']  === 1 && (int)$base['cla_mag_id'] === 2)
    );
    if (!$compatible):
      repondre($is_ajax, ['ok' => false, 'erreur' => 'Ce niveau ne peut pas être affecté à cette classe de base.']);
    endif;

    $lignes[$pc_prestige . '-' . $niveau] = [
      'pc_prestige' => $pc_prestige,
      'niveau'      => $niveau,
      'pc_base'     => $pc_base,
    ];
  endforeach;

  // Transaction : DELETE + INSERT
  try {
    $db->beginTransaction();

    $db->prepare('
      DELETE penl FROM dd_personnages_nls penl
        JOIN dd_personnages_classes pc ON pc.pc_id = penl.penl_pc_id_base
       WHERE pc.pc_pe_id = ?
    ')->execute([$pe_id]);

    if (!empty($lignes)):
      $stmt_ins = $db->prepare('
        INSERT INTO dd_personnages_nls (penl_pc_id_base, penl_pc_id_prestige, penl_niveau)
        VALUES (?, ?, ?)
      ');
      foreach ($lignes as $l):
        $stmt_ins->execute([$l['pc_base'], $l['pc_prestige'], $l['niveau']]);
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
 * Ne rend la main que si le personnage existe et que l'utilisateur le gère
 * (peutGererPersonnage). `$exiger_gestion = false` pour le seul rattachement :
 * le MJ ajoute à sa campagne un personnage qu'il ne gère pas encore, le droit
 * se lit alors sur la campagne (verifierCampagne).
 */
function chargerPersonnagePourCampagne(PDO $db, bool $is_ajax, bool $exiger_gestion = true): array {
  $pe_id = intParam($_POST['pe_id'] ?? 0);
  if ($pe_id <= 0):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Identifiant manquant.']);
  endif;

  $stmt = $db->prepare('
    SELECT pe_id, pe_j_id, pe_affecte_par_j_id, pe_camp_id, pe_ruleset_var_id
      FROM dd_personnages
     WHERE pe_id = ?
  ');
  $stmt->execute([$pe_id]);
  $perso = $stmt->fetch();

  if (!$perso || ($exiger_gestion && !peutGererPersonnage($db, $perso))):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Personnage introuvable ou accès refusé.']);
  endif;

  return [$pe_id, $perso];
}

/**
 * Contrôle d'une campagne avant écriture sur la liaison (SP-PE18).
 *
 * Nouvelle liaison : la campagne doit exister, partager le ruleset du
 * personnage, et l'utilisateur en être le MJ (ou l'admin) — une campagne
 * n'accueille un personnage que par la main de son MJ.
 *
 * Liaison existante (`$nouvelle = false` : retrait, participation, campagne en
 * cours déjà liée) : seul le droit compte — admin, propriétaire du personnage
 * ou MJ de cette campagne. Pas de contrôle d'intégrité : retirer une liaison
 * devenue incohérente (campagne d'un autre ruleset héritée d'un import, campagne
 * supprimée) doit rester possible.
 */
function verifierCampagne(PDO $db, bool $is_ajax, int $camp_id, array $perso, bool $nouvelle): void {
  $stmt = $db->prepare('
    SELECT camp_j_id, camp_ruleset_var_id, camp_supprime
      FROM dd_campagnes
     WHERE camp_id = ?
  ');
  $stmt->execute([$camp_id]);
  $camp = $stmt->fetch();

  if (!$camp || ($nouvelle && (int)$camp['camp_supprime'] !== 0)):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Campagne introuvable.']);
  endif;

  if (!$nouvelle):
    if (!peutModifierLiaisonCampagne($perso, (int)$camp['camp_j_id'])):
      repondre($is_ajax, ['ok' => false, 'erreur' => 'Seul le MJ de cette campagne peut modifier cette liaison.']);
    endif;
    return;
  endif;

  if (!peutRattacherACampagne((int)$camp['camp_j_id'])):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Seul le MJ de cette campagne peut y ajouter un personnage.']);
  endif;
  if ((int)$camp['camp_ruleset_var_id'] !== (int)$perso['pe_ruleset_var_id']):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Cette campagne n\'est pas dans le ruleset du personnage.']);
  endif;
}

/** Vrai si le personnage est déjà lié à la campagne. */
function campagneDejaLiee(PDO $db, int $camp_id, int $pe_id): bool {
  $stmt = $db->prepare('SELECT 1 FROM dd_campagnes_personnages WHERE cp_camp_id = ? AND cp_pe_id = ?');
  $stmt->execute([$camp_id, $pe_id]);
  return (bool)$stmt->fetchColumn();
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
  list($pe_id, $perso) = chargerPersonnagePourCampagne($db, $is_ajax, !$rattacher);

  $camp_id = intParam($_POST['camp_id'] ?? 0);
  if ($camp_id <= 0):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Campagne manquante.']);
  endif;

  verifierCampagne($db, $is_ajax, $camp_id, $perso, $rattacher);

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
    verifierCampagne($db, $is_ajax, $camp_id, $perso, !campagneDejaLiee($db, $camp_id, $pe_id));
  endif;

  try {
    $db->beginTransaction();

    if ($camp_id > 0):
      ecrireCampagneCourante($db, $pe_id, $camp_id);
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
 * Écriture de la campagne en cours, droits déjà contrôlés et transaction
 * ouverte par l'appelant : liaison créée si elle manque, forcée active.
 * Partagée par definirCampagneCourante() et l'action groupée (SP-PE19).
 */
function ecrireCampagneCourante(PDO $db, int $pe_id, int $camp_id): void {
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

  verifierCampagne($db, $is_ajax, $camp_id, $perso, false);

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

/**
 * Portée de la page Notes du personnage (SP-NO4) : 0 = campagne en cours,
 * 1 = toutes les campagnes. Préférence d'affichage, aucune autre table touchée.
 */
function definirPorteeNotes(PDO $db, bool $is_ajax): void {
  list($pe_id) = chargerPersonnagePourCampagne($db, $is_ajax);
  $scope = intParam($_POST['scope'] ?? 0) === 1 ? 1 : 0;
  $db->prepare('UPDATE dd_personnages SET pe_notes_scope = ? WHERE pe_id = ?')->execute([$scope, $pe_id]);
  repondre($is_ajax, ['ok' => true, 'scope' => $scope]);
}

// ============================================================
// AFFECTATION À UN JOUEUR (SP-PE18)
//
// Affecter transfère la propriété : pe_j_id devient le joueur, et
// pe_affecte_par_j_id garde le MJ qui a affecté — c'est elle qui l'autorise,
// lui seul avec l'admin, à retirer l'affectation (D-PE18a). Les liaisons aux
// campagnes ne bougent pas.
// ============================================================

/** Affecte le personnage au joueur `j_id_cible`. */
function affecterPersonnage(PDO $db, bool $is_ajax): void {
  list($pe_id, $perso) = chargerPersonnagePourCampagne($db, $is_ajax);

  if (!peutAffecterPersonnage($db, $perso)):
    $erreur = empty($perso['pe_affecte_par_j_id'])
      ? 'Seul un MJ peut affecter un personnage à un joueur, et seulement l\'un des siens.'
      : 'Ce personnage a déjà été affecté : retirez d\'abord l\'affectation.';
    repondre($is_ajax, ['ok' => false, 'erreur' => $erreur]);
  endif;

  $cible = intParam($_POST['j_id_cible'] ?? 0);
  $stmt  = $db->prepare('SELECT j_id FROM dd_joueurs WHERE j_id = ?');
  $stmt->execute([$cible]);
  if ($cible <= 0 || !$stmt->fetchColumn()):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Joueur introuvable.']);
  endif;
  if ($cible === (int)$perso['pe_j_id']):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Le personnage appartient déjà à ce joueur.']);
  endif;

  try {
    $db->beginTransaction();
    ecrireAffectation($db, $perso, $cible);
    $db->commit();
  } catch (PDOException $e) {
    $db->rollBack();
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur SQL : ' . $e->getMessage()]);
  }

  repondre($is_ajax, ['ok' => true, 'id' => $pe_id]);
}

/**
 * Écriture de l'affectation, droits déjà contrôlés et transaction ouverte par
 * l'appelant. Partagée par affecterPersonnage() et l'action groupée (SP-PE19).
 *
 * La trace désigne le MJ qui a affecté :
 *   - déjà posée : une réaffectation par l'admin la conserve ;
 *   - absente, personnage de l'utilisateur : elle le désigne (le MJ — admin
 *     compris — qui affecte l'un de ses personnages) ;
 *   - absente, personnage d'un tiers (admin seulement) : simple transfert de
 *     propriété, sans trace (D-PE18d).
 * Rendre le personnage au MJ affecteur efface la trace.
 */
function ecrireAffectation(PDO $db, array $perso, int $cible): void {
  $affecte_par = (int)($perso['pe_affecte_par_j_id'] ?? 0);
  if ($affecte_par <= 0):
    $affecte_par = (int)$perso['pe_j_id'] === (int)$_SESSION['j_id'] ? (int)$_SESSION['j_id'] : null;
  endif;
  if ($cible === $affecte_par):
    $affecte_par = null;
  endif;

  $db->prepare('
    UPDATE dd_personnages
       SET pe_j_id = ?, pe_affecte_par_j_id = ?, pe_date_modif = NOW()
     WHERE pe_id = ?
  ')->execute([$cible, $affecte_par, (int)$perso['pe_id']]);
}

// ============================================================
// ACTIONS GROUPÉES DE LA LISTE (SP-PE19, D-PE19a → c)
// Panneau : include/ajax/modifier/personnages-groupe.php. La sélection entière
// doit être gérée par l'utilisateur ; l'action s'applique aux personnages
// éligibles et la réponse liste ceux qui ont été écartés, avec la raison.
// ============================================================

function groupePersonnages(PDO $db, bool $is_ajax): void {
  $persos    = personnagesGroupe($db, (array)($_POST['ids'] ?? []));
  $operation = strParam($_POST['operation'] ?? '');
  if ($persos === null || !in_array($operation, ['campagne', 'joueur'], true)):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Sélection invalide ou accès refusé.']);
  endif;

  $a_ecrire = [];
  $ecartes  = [];

  if ($operation === 'campagne'):
    // Rattacher et faire campagne en cours (D-PE19a).
    $camp_id = intParam($_POST['camp_id'] ?? 0);
    $stmt    = $db->prepare('SELECT camp_j_id, camp_ruleset_var_id FROM dd_campagnes WHERE camp_id = ? AND camp_supprime = 0');
    $stmt->execute([$camp_id]);
    $camp = $stmt->fetch();
    if (!$camp || !peutRattacherACampagne((int)$camp['camp_j_id'])):
      repondre($is_ajax, ['ok' => false, 'erreur' => 'Campagne introuvable, ou dont vous n\'êtes pas le MJ.']);
    endif;
    foreach ($persos as $pe_id => $pe):
      if ((int)$pe['pe_ruleset_var_id'] !== (int)$camp['camp_ruleset_var_id']):
        $ecartes[] = ['nom' => $pe['pe_nom'], 'raison' => 'autre ruleset que la campagne'];
      elseif ((int)$pe['pe_camp_id'] === $camp_id):
        $ecartes[] = ['nom' => $pe['pe_nom'], 'raison' => 'déjà en cours dans cette campagne'];
      else:
        $a_ecrire[] = $pe;
      endif;
    endforeach;

  else:
    $cible = intParam($_POST['j_id_cible'] ?? 0);
    $stmt  = $db->prepare('SELECT j_id FROM dd_joueurs WHERE j_id = ?');
    $stmt->execute([$cible]);
    if ($cible <= 0 || !$stmt->fetchColumn()):
      repondre($is_ajax, ['ok' => false, 'erreur' => 'Joueur introuvable.']);
    endif;
    foreach ($persos as $pe_id => $pe):
      $raison = raisonNonAffectable($db, $pe);
      if ($raison === null && (int)$pe['pe_j_id'] === $cible):
        $raison = 'appartient déjà à ce joueur';
      endif;
      if ($raison !== null):
        $ecartes[] = ['nom' => $pe['pe_nom'], 'raison' => $raison];
      else:
        $a_ecrire[] = $pe;
      endif;
    endforeach;
  endif;

  try {
    $db->beginTransaction();
    foreach ($a_ecrire as $pe):
      if ($operation === 'campagne'):
        ecrireCampagneCourante($db, (int)$pe['pe_id'], $camp_id);
      else:
        ecrireAffectation($db, $pe, $cible);
      endif;
    endforeach;
    $db->commit();
  } catch (PDOException $e) {
    $db->rollBack();
    error_log('groupePersonnages : ' . $e->getMessage());
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur lors de l\'enregistrement.']);
  }

  repondre($is_ajax, ['ok' => true, 'appliques' => count($a_ecrire), 'ecartes' => $ecartes]);
}

/** Retire l'affectation : le personnage revient au MJ qui l'avait affecté. */
function retirerAffectation(PDO $db, bool $is_ajax): void {
  list($pe_id, $perso) = chargerPersonnagePourCampagne($db, $is_ajax);

  if (!peutRetirerAffectation($perso)):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Seul le MJ qui a affecté ce personnage peut retirer l\'affectation.']);
  endif;

  try {
    $db->beginTransaction();
    $db->prepare('
      UPDATE dd_personnages
         SET pe_j_id = pe_affecte_par_j_id, pe_affecte_par_j_id = NULL, pe_date_modif = NOW()
       WHERE pe_id = ?
    ')->execute([$pe_id]);
    $db->commit();
  } catch (PDOException $e) {
    $db->rollBack();
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur SQL : ' . $e->getMessage()]);
  }

  repondre($is_ajax, ['ok' => true, 'id' => $pe_id]);
}

// ============================================================
// POSSESSIONS (SP-PO8)
//
// Écriture immédiate, une ligne à la fois (pattern D-PE4a). Droit : peutGererPersonnage
// (propriétaire, MJ des campagnes du personnage, admin — D-PO18). Chaque réponse renvoie les
// totaux recalculés de l'inventaire, que la page affiche sans se recharger.
// Les objets composés (pp_type = compose) naissent par le compositeur (SP-PO10 / PO11),
// jamais par ajouterPossession.
// ============================================================

/** Charge la possession `pp_id` et contrôle le droit sur son personnage. */
function chargerPossession(PDO $db, bool $is_ajax): array {
  $pp_id = intParam($_POST['pp_id'] ?? 0);
  $stmt = $db->prepare('
    SELECT pp.*, pe.pe_id, pe.pe_j_id, pe.pe_affecte_par_j_id, pe.pe_ruleset_var_id
      FROM dd_personnages_possessions pp
      JOIN dd_personnages pe ON pe.pe_id = pp.pp_pe_id
     WHERE pp.pp_id = ?
  ');
  $stmt->execute([$pp_id]);
  $pp = $stmt->fetch();
  if (!$pp || !peutGererPersonnage($db, $pp)):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Possession introuvable ou accès refusé.']);
  endif;
  return $pp;
}

/** Marque le personnage modifié et renvoie les totaux de son inventaire. */
function apresPossession(PDO $db, int $pe_id): array {
  $db->prepare('UPDATE dd_personnages SET pe_date_modif = NOW() WHERE pe_id = ?')->execute([$pe_id]);
  return possessionsTotaux(getPersonnagePossessions($db, $pe_id));
}

/**
 * Ajoute un équipement ou un objet magique simple. POST : pe_id, type (equipement | objet),
 * id (eqt_id ou om_id), quantite (défaut 1).
 * Une ligne identique, sans nom libre ni notes et non équipée, voit sa quantité augmentée
 * plutôt que d'être doublée (un double clic ne crée pas deux lignes).
 */
function ajouterPossession(PDO $db, bool $is_ajax): void {
  list($pe_id, $perso) = chargerPersonnagePourCampagne($db, $is_ajax);
  $ruleset = (int)$perso['pe_ruleset_var_id'];
  $type    = strParam($_POST['type'] ?? '');
  $id      = intParam($_POST['id'] ?? 0);
  $qte     = max(1, min(9999, intParam($_POST['quantite'] ?? 1, 1)));

  // Même ruleset que le personnage, hors homebrew de campagne, et visible pour l'utilisateur
  // selon la règle des listes du compendium (global visible, supplément propre ou partagé ;
  // l'éditeur du compendium voit aussi les entrées masquées) — celle du sélecteur (SP-PO9).
  $params = [$id, $ruleset];
  if ($type === 'equipement'):
    $vis = listeClauseVisibilite('res.res_j_id', 'eqt.eqt_public', 'eqt.eqt_visible', $params);
    $stmt = $db->prepare("
      SELECT eqt.eqt_id
        FROM dd_equipements eqt
        LEFT JOIN dd_ressources res ON res.res_id = eqt.eqt_res_id
       WHERE eqt.eqt_id = ? AND eqt.eqt_ruleset_var_id = ? AND eqt.eqt_camp_id IS NULL AND $vis
    ");
  elseif ($type === 'objet'):
    $vis = listeClauseVisibilite('res.res_j_id', 'om.om_public', 'om.om_visible', $params);
    $stmt = $db->prepare("
      SELECT om.om_id, com.com_est_propriete, com.com_est_calcule
        FROM dd_objets_magiques om
        LEFT JOIN dd_categorie_objet_magique com ON com.com_id = om.om_com_id
        LEFT JOIN dd_ressources res ON res.res_id = om.om_res_id
       WHERE om.om_id = ? AND om.om_ruleset_var_id = ? AND om.om_camp_id IS NULL AND $vis
    ");
  else:
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Type de possession inconnu.']);
  endif;
  $stmt->execute($params);
  $ent = $stmt->fetch();

  if (!$ent):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Cet objet n\'existe pas dans le ruleset du personnage.']);
  endif;
  if ($type === 'objet' && (int)$ent['com_est_propriete'] === 1):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Une propriété spéciale ne se possède pas seule : elle se pose sur une arme ou une armure composée.']);
  endif;
  if ($type === 'objet' && $ruleset === 1 && (int)$ent['com_est_calcule'] === 1):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Potions, baguettes et parchemins se composent depuis l\'inventaire (sort et NLS).']);
  endif;

  $col = $type === 'equipement' ? 'pp_eqt_id' : 'pp_om_id';
  $stmt = $db->prepare("
    SELECT pp_id FROM dd_personnages_possessions
     WHERE pp_pe_id = ? AND pp_type = ? AND $col = ?
       AND (pp_nom IS NULL OR pp_nom = '') AND (pp_notes IS NULL OR pp_notes = '') AND pp_equipe = 0
     ORDER BY pp_id LIMIT 1
  ");
  $stmt->execute([$pe_id, $type, $id]);
  $existant = (int)$stmt->fetchColumn();

  try {
    if ($existant > 0):
      $db->prepare('UPDATE dd_personnages_possessions SET pp_quantite = LEAST(pp_quantite + ?, 9999), pp_date_maj = NOW() WHERE pp_id = ?')
         ->execute([$qte, $existant]);
      $pp_id = $existant;
    else:
      $stmt = $db->prepare('SELECT COALESCE(MAX(pp_ordre), 0) + 1 FROM dd_personnages_possessions WHERE pp_pe_id = ?');
      $stmt->execute([$pe_id]);
      $ordre = min(65535, (int)$stmt->fetchColumn());
      $db->prepare("INSERT INTO dd_personnages_possessions (pp_pe_id, pp_type, $col, pp_quantite, pp_ordre) VALUES (?, ?, ?, ?, ?)")
         ->execute([$pe_id, $type, $id, $qte, $ordre]);
      $pp_id = (int)$db->lastInsertId();
    endif;
    $totaux = apresPossession($db, $pe_id);
  } catch (PDOException $e) {
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur SQL : ' . $e->getMessage()]);
  }

  repondre($is_ajax, ['ok' => true, 'pp_id' => $pp_id, 'fusion' => $existant > 0, 'totaux' => $totaux]);
}

/**
 * Modifie un champ d'une possession. POST : pp_id, champ, valeur.
 *   quantite  1 à 9999          equipe   0 | 1
 *   charges   0 à 999, vide = aucune (baguette)
 *   nom       nom libre (200 car.), vide = nom du compendium — obligatoire pour un composé
 *   notes     texte libre, vide = aucune
 */
function modifierPossession(PDO $db, bool $is_ajax): void {
  $pp    = chargerPossession($db, $is_ajax);
  $champ = strParam($_POST['champ'] ?? '');
  $brut  = (string)($_POST['valeur'] ?? '');

  $erreur = null;
  if ($champ === 'quantite'):
    $col = 'pp_quantite';
    $val = intParam($brut);
    $erreur = $val < 1 || $val > 9999 ? 'Quantité de 1 à 9 999 (pour retirer l\'objet, utilisez Retirer).' : null;
  elseif ($champ === 'equipe'):
    $col = 'pp_equipe';
    $val = intParam($brut) === 1 ? 1 : 0;
  elseif ($champ === 'charges'):
    $col = 'pp_charges';
    $val = trim($brut) === '' ? null : intParam($brut);
    $erreur = $val !== null && ($val < 0 || $val > 999) ? 'Charges de 0 à 999.' : null;
  elseif ($champ === 'nom'):
    $col = 'pp_nom';
    $val = mb_substr(trim($brut), 0, 200);
    $erreur = $val === '' && $pp['pp_type'] === 'compose' ? 'Un objet composé garde un nom.' : null;
    $val = $val === '' ? null : $val;
  elseif ($champ === 'harmonise'):
    // DD2024 (SP-PO12) : seulement un objet magique qui requiert l'harmonisation. Plus de 3 objets
    // harmonisés est signalé sur la page, pas refusé (la fiche reste déclarative).
    $col = 'pp_harmonise';
    $val = intParam($brut) === 1 ? 1 : 0;
    $stmt = $db->prepare('SELECT om_harmonisation FROM dd_objets_magiques WHERE om_id = ?');
    $stmt->execute([(int)$pp['pp_om_id']]);
    $erreur = (int)$pp['pe_ruleset_var_id'] !== 2 || $pp['pp_type'] !== 'objet' || (int)$stmt->fetchColumn() !== 1
      ? 'Cet objet ne requiert pas d\'harmonisation.' : null;
  elseif ($champ === 'notes'):
    $col = 'pp_notes';
    $val = trim($brut) === '' ? null : mb_substr(trim($brut), 0, 5000);
  else:
    $erreur = 'Champ inconnu.';
  endif;
  if ($erreur !== null):
    repondre($is_ajax, ['ok' => false, 'erreur' => $erreur]);
  endif;

  try {
    // $col vient de la liste fermée ci-dessus, jamais de la saisie
    $db->prepare("UPDATE dd_personnages_possessions SET $col = ?, pp_date_maj = NOW() WHERE pp_id = ?")
       ->execute([$val, (int)$pp['pp_id']]);
    $totaux = apresPossession($db, (int)$pp['pe_id']);
  } catch (PDOException $e) {
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur SQL : ' . $e->getMessage()]);
  }

  repondre($is_ajax, ['ok' => true, 'champ' => $champ, 'valeur' => $val, 'totaux' => $totaux]);
}

/** Retire une possession, et les éléments d'un objet composé. POST : pp_id. */
function retirerPossession(PDO $db, bool $is_ajax): void {
  $pp = chargerPossession($db, $is_ajax);
  try {
    $db->beginTransaction();
    $db->prepare('DELETE FROM dd_personnages_possessions_elements WHERE ppe_pp_id = ?')->execute([(int)$pp['pp_id']]);
    $db->prepare('DELETE FROM dd_personnages_possessions WHERE pp_id = ?')->execute([(int)$pp['pp_id']]);
    $db->commit();
    $totaux = apresPossession($db, (int)$pp['pe_id']);
  } catch (PDOException $e) {
    if ($db->inTransaction()) $db->rollBack();
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur SQL : ' . $e->getMessage()]);
  }
  repondre($is_ajax, ['ok' => true, 'totaux' => $totaux]);
}

// ============================================================
// OBJETS COMPOSÉS (SP-PO10) — compositeur DD3.5
//
// Le serveur recalcule tout par le moteur (include/objet-compose.php, D-PO19) : rien de ce que
// le formulaire affiche n'est repris tel quel. Une composition qui enfreint une règle est
// refusée (D-PO20). Prix, coût et PX sont figés dans la ligne (photo) ; pp_prix_pc est le prix
// d'UNE pièce (lot de munitions : prix du lot ÷ quantité, D-PO23).
// ============================================================

/** Objet de base, propriétés et sorts d'une spec : tous visibles pour l'utilisateur ? Message sinon. */
function composeVisibiliteErreur(PDO $db, array $spec): ?string {
  $controles = [];
  if ((int)($spec['eqt_id'] ?? 0) > 0):
    $controles[] = ['dd_equipements eqt LEFT JOIN dd_ressources res ON res.res_id = eqt.eqt_res_id',
                    'eqt.eqt_id', 'eqt.eqt_camp_id', ['res.res_j_id', 'eqt.eqt_public', 'eqt.eqt_visible'],
                    (int)$spec['eqt_id'], 'Objet de base indisponible.'];
  endif;
  foreach ($spec['proprietes'] ?? [] as $p):
    $controles[] = ['dd_objets_magiques om LEFT JOIN dd_ressources res ON res.res_id = om.om_res_id',
                    'om.om_id', 'om.om_camp_id', ['res.res_j_id', 'om.om_public', 'om.om_visible'],
                    (int)$p['om_id'], 'Propriété spéciale indisponible.'];
  endforeach;
  foreach ($spec['sorts'] ?? [] as $s):
    $controles[] = ['dd_sorts so LEFT JOIN dd_ressources res ON res.res_id = so.so_res_id',
                    'so.so_id', 'so.so_camp_id', ['res.res_j_id', 'so.so_public', 'so.so_visible'],
                    (int)$s['so_id'], 'Sort indisponible.'];
  endforeach;

  foreach ($controles as [$from, $col_id, $col_camp, $vis, $id, $message]):
    $params = [$id];
    $clause = listeClauseVisibilite($vis[0], $vis[1], $vis[2], $params);
    // $from, $col_id et $col_camp viennent de la liste fermée ci-dessus
    $stmt = $db->prepare("SELECT 1 FROM $from WHERE $col_id = ? AND $col_camp IS NULL AND $clause");
    $stmt->execute($params);
    if (!$stmt->fetchColumn()) return $message;
  endforeach;
  return null;
}

/**
 * Crée ou recompose un objet composé. POST : pe_id, pp_id (0 = nouveau), nom (vide = nom généré),
 * puis les champs du moteur (composeSpecDepuisPost : cat, eqt_id, bonus, bonus_tete2, prop_*[], sort_*[]).
 * Recomposer garde la quantité, l'état « équipé », les charges restantes et les notes.
 */
function enregistrerCompose(PDO $db, bool $is_ajax): void {
  list($pe_id, $perso) = chargerPersonnagePourCampagne($db, $is_ajax);
  if ((int)$perso['pe_ruleset_var_id'] !== OC_RULESET):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'La composition d\'objets magiques concerne les personnages DD3.5.']);
  endif;

  $pp_id = intParam($_POST['pp_id'] ?? 0);
  $existant = null;
  if ($pp_id > 0):
    $stmt = $db->prepare('SELECT * FROM dd_personnages_possessions WHERE pp_id = ? AND pp_pe_id = ? AND pp_type = \'compose\'');
    $stmt->execute([$pp_id, $pe_id]);
    $existant = $stmt->fetch();
    if (!$existant):
      repondre($is_ajax, ['ok' => false, 'erreur' => 'Objet composé introuvable.']);
    endif;
  endif;

  $spec = composeSpecDepuisPost($_POST);
  $r    = composerObjet($db, $spec);
  if (!$r['ok']):
    repondre($is_ajax, ['ok' => false, 'erreur' => implode(' ', $r['erreurs'])]);
  endif;
  $err = composeVisibiliteErreur($db, $spec);
  if ($err !== null):
    repondre($is_ajax, ['ok' => false, 'erreur' => $err]);
  endif;

  $nom      = mb_substr(trim(strParam($_POST['nom'] ?? '')), 0, 200);
  $nom      = $nom !== '' ? $nom : $r['nom'];
  $quantite = $existant ? (int)$existant['pp_quantite'] : (int)$r['quantite'];
  $charges  = $r['charges'] === null ? null : ($existant && $existant['pp_charges'] !== null ? (int)$existant['pp_charges'] : (int)$r['charges']);
  $prix_u   = composeArrondi($r['prix_pc'] / max(1, (int)$r['quantite']));
  $eqt_id   = in_array($r['cat'], ['arme', 'armure', 'bouclier'], true) ? (int)$spec['eqt_id'] : null;

  $champs = [
    'pp_eqt_id' => $eqt_id, 'pp_nom' => $nom, 'pp_charges' => $charges, 'pp_compose_cat' => $r['cat'],
    'pp_maitre' => (int)$r['maitre'], 'pp_bonus' => $r['bonus'], 'pp_bonus_tete2' => $r['bonus_tete2'],
    'pp_nls' => $r['nls'], 'pp_prix_pc' => $prix_u, 'pp_cout_pc' => (int)$r['cout_pc'], 'pp_cout_px' => (int)$r['cout_px'],
  ];

  try {
    $db->beginTransaction();
    if ($existant):
      $sets = implode(', ', array_map(fn($c) => "$c = ?", array_keys($champs)));
      $db->prepare("UPDATE dd_personnages_possessions SET $sets, pp_date_maj = NOW() WHERE pp_id = ?")
         ->execute(array_merge(array_values($champs), [$pp_id]));
      $db->prepare('DELETE FROM dd_personnages_possessions_elements WHERE ppe_pp_id = ?')->execute([$pp_id]);
    else:
      $stmt = $db->prepare('SELECT COALESCE(MAX(pp_ordre), 0) + 1 FROM dd_personnages_possessions WHERE pp_pe_id = ?');
      $stmt->execute([$pe_id]);
      $champs = array_merge(['pp_pe_id' => $pe_id, 'pp_type' => 'compose', 'pp_quantite' => $quantite,
                             'pp_ordre' => min(65535, (int)$stmt->fetchColumn())], $champs);
      $cols = implode(', ', array_keys($champs));
      $ph   = implode(', ', array_fill(0, count($champs), '?'));
      $db->prepare("INSERT INTO dd_personnages_possessions ($cols) VALUES ($ph)")->execute(array_values($champs));
      $pp_id = (int)$db->lastInsertId();
    endif;

    $ins = $db->prepare('
      INSERT INTO dd_personnages_possessions_elements
        (ppe_pp_id, ppe_type, ppe_tete, ppe_om_id, ppe_so_id, ppe_cla_id, ppe_niveau, ppe_nls,
         ppe_parametre, ppe_suppl_pc, ppe_suppl_px, ppe_ordre)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ');
    foreach ($r['elements'] as $e):
      $ins->execute([$pp_id, $e['ppe_type'], $e['ppe_tete'], $e['ppe_om_id'], $e['ppe_so_id'], $e['ppe_cla_id'],
                     $e['ppe_niveau'], $e['ppe_nls'], $e['ppe_parametre'], $e['ppe_suppl_pc'], $e['ppe_suppl_px'], $e['ppe_ordre']]);
    endforeach;
    $db->commit();
    $totaux = apresPossession($db, $pe_id);
  } catch (PDOException $e) {
    if ($db->inTransaction()) $db->rollBack();
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur SQL : ' . $e->getMessage()]);
  }

  repondre($is_ajax, ['ok' => true, 'pp_id' => $pp_id, 'nom' => $nom, 'totaux' => $totaux]);
}

// ============================================================
// CONSOMMABLES COMPOSÉS (SP-PO11) — utilisation en jeu
//
// Potion ou huile bue : un exemplaire de moins, la ligne disparaît au dernier.
// Baguette : une charge de moins (jamais sous 0 ; une baguette vide reste dans l'inventaire).
// Parchemin : chaque sort se coche « lu » (ppe_utilise). Quand tous les sorts d'un parchemin
// en plusieurs exemplaires sont lus, l'exemplaire est consommé et les cases reviennent à zéro.
// ============================================================

/** POST pp_id : boire une potion / huile, ou utiliser une charge de baguette. */
function consommerPossession(PDO $db, bool $is_ajax): void {
  $pp    = chargerPossession($db, $is_ajax);
  $pp_id = (int)$pp['pp_id'];
  $cat   = $pp['pp_type'] === 'compose' ? (string)$pp['pp_compose_cat'] : '';
  $retire = false;

  try {
    if ($cat === 'potion' || $cat === 'huile'):
      if ((int)$pp['pp_quantite'] <= 1):
        $db->beginTransaction();
        $db->prepare('DELETE FROM dd_personnages_possessions_elements WHERE ppe_pp_id = ?')->execute([$pp_id]);
        $db->prepare('DELETE FROM dd_personnages_possessions WHERE pp_id = ?')->execute([$pp_id]);
        $db->commit();
        $retire = true;
      else:
        $db->prepare('UPDATE dd_personnages_possessions SET pp_quantite = pp_quantite - 1, pp_date_maj = NOW() WHERE pp_id = ?')
           ->execute([$pp_id]);
      endif;
    elseif ($cat === 'baguette'):
      if ((int)$pp['pp_charges'] <= 0):
        repondre($is_ajax, ['ok' => false, 'erreur' => 'Cette baguette n\'a plus de charge.']);
      endif;
      $db->prepare('UPDATE dd_personnages_possessions SET pp_charges = pp_charges - 1, pp_date_maj = NOW() WHERE pp_id = ?')
         ->execute([$pp_id]);
    else:
      repondre($is_ajax, ['ok' => false, 'erreur' => 'Seules les potions, huiles et baguettes composées se consomment ainsi.']);
    endif;
    $totaux = apresPossession($db, (int)$pp['pe_id']);
  } catch (PDOException $e) {
    if ($db->inTransaction()) $db->rollBack();
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur SQL : ' . $e->getMessage()]);
  }

  repondre($is_ajax, [
    'ok'       => true,
    'retire'   => $retire,
    'quantite' => $retire ? 0 : (int)$pp['pp_quantite'] - (($cat === 'potion' || $cat === 'huile') ? 1 : 0),
    'charges'  => $cat === 'baguette' ? (int)$pp['pp_charges'] - 1 : null,
    'totaux'   => $totaux,
  ]);
}

/** POST pp_id, ppe_id, valeur (0 | 1) : sort d'un parchemin lu ou non. */
function utiliserSortParchemin(PDO $db, bool $is_ajax): void {
  $pp    = chargerPossession($db, $is_ajax);
  $pp_id = (int)$pp['pp_id'];
  if ($pp['pp_type'] !== 'compose' || $pp['pp_compose_cat'] !== 'parchemin'):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Ce n\'est pas un parchemin composé.']);
  endif;
  $ppe_id = intParam($_POST['ppe_id'] ?? 0);
  $valeur = intParam($_POST['valeur'] ?? 0) === 1 ? 1 : 0;

  $stmt = $db->prepare('UPDATE dd_personnages_possessions_elements SET ppe_utilise = ? WHERE ppe_id = ? AND ppe_pp_id = ? AND ppe_type = \'sort\'');
  $stmt->execute([$valeur, $ppe_id, $pp_id]);
  $stmt = $db->prepare('SELECT COUNT(*) FROM dd_personnages_possessions_elements WHERE ppe_id = ? AND ppe_pp_id = ?');
  $stmt->execute([$ppe_id, $pp_id]);
  if (!$stmt->fetchColumn()):
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Sort introuvable sur ce parchemin.']);
  endif;

  // Tous les sorts lus et d'autres exemplaires en réserve : un parchemin de moins, cases remises à zéro
  $consomme = false;
  if ($valeur === 1 && (int)$pp['pp_quantite'] > 1):
    $stmt = $db->prepare('SELECT COUNT(*) FROM dd_personnages_possessions_elements WHERE ppe_pp_id = ? AND ppe_type = \'sort\' AND ppe_utilise = 0');
    $stmt->execute([$pp_id]);
    if ((int)$stmt->fetchColumn() === 0):
      try {
        $db->beginTransaction();
        $db->prepare('UPDATE dd_personnages_possessions SET pp_quantite = pp_quantite - 1, pp_date_maj = NOW() WHERE pp_id = ?')->execute([$pp_id]);
        $db->prepare('UPDATE dd_personnages_possessions_elements SET ppe_utilise = 0 WHERE ppe_pp_id = ?')->execute([$pp_id]);
        $db->commit();
        $consomme = true;
      } catch (PDOException $e) {
        if ($db->inTransaction()) $db->rollBack();
        repondre($is_ajax, ['ok' => false, 'erreur' => 'Erreur SQL : ' . $e->getMessage()]);
      }
    endif;
  endif;

  $totaux = apresPossession($db, (int)$pp['pe_id']);
  repondre($is_ajax, ['ok' => true, 'consomme' => $consomme, 'totaux' => $totaux]);
}
