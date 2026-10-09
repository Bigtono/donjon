<?php
// admin/deploiement/ajax.php — Pilotage d'un déploiement, étape par étape (SP-DP4)
//
// Le navigateur enchaîne les appels : « demarrer » fige les étapes du plan
// calculé à l'aperçu (panneau.php), puis un appel « etape » par étape, dans
// l'ordre strict — l'index attendu est vérifié. Le plan vit en session : le
// navigateur ne transmet jamais de liste de fichiers, seulement l'identifiant
// du plan et des cases à cocher.
require_once __DIR__ . '/garde.php';

function repondreDeploiement(array $donnees): void {
  header('Content-Type: application/json; charset=UTF-8');
  header('Cache-Control: no-store');
  echo json_encode($donnees, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
  exit;
}

// La session est relâchée pendant le travail (une étape peut durer plusieurs
// dizaines de secondes, les autres onglets du site n'ont pas à l'attendre),
// puis rouverte le temps d'enregistrer le plan.
function sauverPlanDeploiement(?array $plan): void {
  session_start();
  if ($plan === null) {
    unset($_SESSION['deploiement']);
  } else {
    $_SESSION['deploiement'] = $plan;
  }
  session_write_close();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST'):
  http_response_code(405);
  exit;
endif;
verifyCsrf();
@set_time_limit(600);

$action = strParam($_POST['action'] ?? '');
$planId = strParam($_POST['plan'] ?? '');
$plan   = $_SESSION['deploiement'] ?? null;
session_write_close();

try {

  if ($action === 'demarrer'):
    if (!$plan || $plan['id'] !== $planId || isset($plan['etapes'])):
      throw new RuntimeException('Aperçu périmé : rouvrez le panneau de déploiement.');
    endif;
    if (time() - $plan['cree'] > DEPLOIEMENT_PLAN_DUREE):
      throw new RuntimeException('Aperçu de plus de 15 minutes : rouvrez le panneau pour le recalculer.');
    endif;
    deploiementPoserVerrou($plan['id']);
    $plan['options']   = ['migrations' => !empty($_POST['migrations']), 'supprimer' => !empty($_POST['supprimer'])];
    $plan['etapes']    = deploiementEtapes($plan, $plan['options']['migrations'], $plan['options']['supprimer']);
    $plan['prochaine'] = 0;
    $plan['debut']     = time();
    $plan['bilan']     = ['envoyes' => [], 'supprimes' => [], 'migrations' => null];
    sauverPlanDeploiement($plan);
    repondreDeploiement(['ok' => true, 'etapes' => array_column($plan['etapes'], 'libelle')]);
  endif;

  if ($action === 'etape'):
    $index = intParam($_POST['index'] ?? -1);
    if (!$plan || $plan['id'] !== $planId || !isset($plan['etapes'])):
      throw new RuntimeException('Aucun déploiement en cours dans cette session.');
    endif;
    if ($index !== $plan['prochaine']):
      throw new RuntimeException('Étape inattendue (' . $index . ' au lieu de ' . $plan['prochaine'] . ').');
    endif;
    $etape = $plan['etapes'][$index];

    if ($etape['type'] === 'fin'):
      $bilan = $plan['bilan'];
      deploiementJournaliser([
        'statut'     => 'succes',
        'duree_s'    => time() - $plan['debut'],
        'envoyes'    => $bilan['envoyes'],
        'supprimes'  => $bilan['supprimes'],
        'migrations' => $bilan['migrations'],
      ]);
      deploiementLeverVerrou();
      sauverPlanDeploiement(null);
      $resume = count($bilan['envoyes']) . ' fichier' . (count($bilan['envoyes']) > 1 ? 's envoyés' : ' envoyé');
      if ($bilan['supprimes']):
        $resume .= ', ' . count($bilan['supprimes']) . ' supprimé' . (count($bilan['supprimes']) > 1 ? 's' : '');
      endif;
      repondreDeploiement(['ok' => true, 'index' => $index, 'termine' => true, 'detail' => $resume . ' en ' . (time() - $plan['debut']) . ' s.']);
    endif;

    $config = deploiementConfig();
    try {
      $detail = deploiementExecuterEtape(new DeploiementSftp($config), $config, $plan, $index);
    } catch (Throwable $e) {
      // Le manifeste a pu avancer en cours de lot : le plan est conservé tel quel.
      sauverPlanDeploiement($plan);
      deploiementJournaliser(['statut' => 'echec', 'etape' => $etape['libelle'], 'erreur' => $e->getMessage()]);
      throw $e;
    }

    if ($etape['type'] === 'envoi'):
      $plan['bilan']['envoyes'] = array_merge($plan['bilan']['envoyes'], $etape['fichiers']);
    elseif ($etape['type'] === 'suppression'):
      $plan['bilan']['supprimes'] = array_merge($plan['bilan']['supprimes'], $etape['fichiers']);
    elseif ($etape['type'] === 'migrations'):
      $plan['bilan']['migrations'] = $detail;
    endif;
    $plan['prochaine']++;
    sauverPlanDeploiement($plan);
    repondreDeploiement(['ok' => true, 'index' => $index, 'detail' => $detail]);
  endif;

  // Abandon d'un déploiement inachevé : rouvrir le site et libérer le verrou.
  // Le code est alors en partie neuf, en partie ancien — à reprendre par un
  // nouveau déploiement, qui ne renverra que ce qui manque.
  if ($action === 'abandonner'):
    $config = deploiementConfig();
    $erreur = null;
    if (deploiementConfigComplete($config)):
      try {
        (new DeploiementSftp($config))->supprimer(deploiementCheminSite($config, '.maintenance'));
      } catch (Throwable $e) {
        $erreur = $e->getMessage();
      }
    endif;
    deploiementLeverVerrou();
    deploiementJournaliser(['statut' => 'abandon', 'erreur' => $erreur]);
    sauverPlanDeploiement(null);
    repondreDeploiement($erreur === null
      ? ['ok' => true]
      : ['ok' => false, 'erreur' => 'Verrou levé, mais la maintenance n\'a pas pu être retirée : ' . $erreur]);
  endif;

  throw new RuntimeException('Action inconnue.');

} catch (Throwable $e) {
  repondreDeploiement(['ok' => false, 'erreur' => $e->getMessage()]);
}
