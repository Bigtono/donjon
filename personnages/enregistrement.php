<?php
// personnages/enregistrement.php — POST commun du module Personnages.
// Routeur d'actions transactionnelles (commit global, cf. ARCHITECTURE §7.4).
//
// SOUS-PHASE 3.0 : seule l'action `supprimerPersonnage` est implémentée
// (nécessaire pour la liste). Les actions `creerPersonnage` /
// `enregistrerPersonnage` seront ajoutées en 3.1.
//
// Toutes les actions :
//   - Vérifient le CSRF (verifyCsrf()) — sauf en mode ajax si géré par postAjax
//   - Vérifient la propriété du personnage (canAccess sur pe_j_id)
//   - Sont exécutées dans une transaction PDO
//   - Renvoient JSON {ok: bool, erreur?: string, id?: int, url?: string}
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
  // Actions à venir en 3.1+
  // --------------------------------------------------------
  case 'creerPersonnage':
  case 'enregistrerPersonnage':
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Action non implémentée en 3.0.']);
    break;

  default:
    repondre($is_ajax, ['ok' => false, 'erreur' => 'Action inconnue.']);

endswitch;
