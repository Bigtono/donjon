<?php
// admin/deploiement/panneau.php — Aperçu et lancement d'un déploiement (SP-DP4)
//
// Fragment chargé dans #modification par ouvrirDeploiement() (bouton du
// header). Calcule le plan — git pour le local, manifeste pour la production —,
// le garde en session et l'affiche. Rien ne part avant la confirmation ; la
// suite est pilotée par admin/deploiement/deploiement.js.
require_once __DIR__ . '/garde.php';

$config  = deploiementConfig();
$verrou  = deploiementVerrou();
$enCours = $_SESSION['deploiement'] ?? null;
$complet = !empty($_GET['complet']);
$plan    = null;
$erreur  = null;

if (deploiementConfigComplete($config) && !$verrou):
  try {
    $plan = deploiementCalculerPlan(new DeploiementSftp($config), $config, $complet);
    $_SESSION['deploiement'] = $plan;
  } catch (Throwable $e) {
    $erreur = $e->getMessage();
  }
endif;

// Liste de fichiers repliable.
function deploiementListe(string $titre, array $fichiers, string $modificateur = ''): string {
  if (!$fichiers) {
    return '';
  }
  $html = '<details class="deploiement__liste' . ($modificateur ? ' deploiement__liste--' . $modificateur : '') . '">'
        . '<summary>' . h($titre) . ' (' . count($fichiers) . ')</summary><ul>';
  foreach ($fichiers as $fichier) {
    $html .= '<li>' . h($fichier) . '</li>';
  }
  return $html . '</ul></details>';
}

$cible = $config['utilisateur'] . '@' . $config['hote'] . ':' . $config['chemin_distant'];
?>
<div class="deploiement" id="deploiement">
  <h2 class="deploiement__titre"><i class="fa fa-cloud-arrow-up"></i> Déploiement en production</h2>

  <?php if (!deploiementConfigComplete($config)): ?>

    <p class="flash-message flash-message--info">
      Paramétrage incomplet<?= $config['hote'] !== '' && $config['empreinte'] === '' ? ' : l\'empreinte du serveur n\'est pas encore approuvée' : '' ?>.
    </p>
    <div class="form-actions">
      <a class="btn btn-primary" href="<?= BASE_URL ?>/admin/deploiement/index.php">
        <i class="fa fa-gear"></i> Paramètres du déploiement
      </a>
    </div>

  <?php elseif ($verrou): ?>

    <?php $reprise = $enCours && ($enCours['id'] ?? '') === $verrou['plan'] && isset($enCours['etapes']) ?>
    <p class="flash-message flash-message--error">
      Un déploiement commencé à <?= h(date('H:i', (int)$verrou['debut'])) ?> est resté inachevé.
      Le site de production est peut-être encore en maintenance.
    </p>
    <?php if ($reprise): ?>
      <p class="text-muted">
        Arrêt à l'étape <?= (int)$enCours['prochaine'] + 1 ?> sur <?= count($enCours['etapes']) ?> :
        <?= h($enCours['etapes'][$enCours['prochaine']]['libelle'] ?? '') ?>.
      </p>
    <?php endif ?>
    <div class="deploiement__suivi"
         <?php if ($reprise): ?>
           data-plan="<?= h($enCours['id']) ?>"
           data-prochaine="<?= (int)$enCours['prochaine'] ?>"
           data-etapes="<?= h(json_encode(array_column($enCours['etapes'], 'libelle'), JSON_UNESCAPED_UNICODE)) ?>"
         <?php endif ?>>
      <progress class="deploiement__progression noDisplay" value="0" max="1"></progress>
      <ol class="deploiement__journal"></ol>
    </div>
    <div class="form-actions deploiement__actions-reprise">
      <?php if ($reprise): ?>
        <button type="button" class="btn btn-primary" data-deploiement="reprendre">
          <i class="fa fa-rotate-right"></i> Reprendre
        </button>
      <?php endif ?>
      <button type="button" class="btn btn-secondary" data-deploiement="abandonner">
        <i class="fa fa-ban"></i> Abandonner et rouvrir le site
      </button>
    </div>

  <?php elseif ($erreur !== null): ?>

    <p class="flash-message flash-message--error"><?= h($erreur) ?></p>
    <div class="form-actions">
      <button type="button" class="btn btn-secondary" onclick="ouvrirDeploiement()">
        <i class="fa fa-rotate-right"></i> Réessayer
      </button>
      <a class="btn btn-secondary" href="<?= BASE_URL ?>/admin/deploiement/index.php">
        <i class="fa fa-gear"></i> Paramètres
      </a>
    </div>

  <?php else: ?>

    <?php
    $nbEnvoi      = count($plan['nouveaux']) + count($plan['modifies']) + count($plan['renvoyes']);
    $nbSuppr      = count($plan['supprimes']);
    $aJour        = $nbEnvoi === 0 && $nbSuppr === 0;
    ?>
    <p class="deploiement__cible">
      <i class="fa fa-server"></i> <?= h($cible) ?>
      <span class="text-muted">— <?= h($config['url_production']) ?></span>
    </p>

    <?php if ($plan['premier']): ?>
      <p class="flash-message flash-message--info">
        Premier déploiement : aucun manifeste en production, les <?= (int)$plan['nb_perimetre'] ?> fichiers
        du périmètre partent tous. Les suivants n'enverront que les changements.
      </p>
    <?php endif ?>

    <div class="deploiement__bilan">
      <span class="deploiement__chiffre"><strong><?= count($plan['nouveaux']) ?></strong> nouveaux</span>
      <span class="deploiement__chiffre"><strong><?= count($plan['modifies']) ?></strong> modifiés</span>
      <?php if ($plan['complet']): ?>
        <span class="deploiement__chiffre"><strong><?= count($plan['renvoyes']) ?></strong> renvoyés</span>
      <?php endif ?>
      <span class="deploiement__chiffre"><strong><?= $nbSuppr ?></strong> retirés en local</span>
      <span class="deploiement__chiffre"><strong><?= count($plan['migrations']) ?></strong> nouvelles migrations</span>
    </div>

    <?php if ($aJour): ?>
      <p class="text-muted">La production est à jour : aucun fichier à envoyer.</p>
    <?php endif ?>

    <?= deploiementListe('Nouveaux', $plan['nouveaux']) ?>
    <?= deploiementListe('Modifiés', $plan['modifies']) ?>
    <?= deploiementListe('Renvoyés à l\'identique', $plan['renvoyes']) ?>
    <?= deploiementListe('Retirés en local, encore en production', $plan['supprimes'], 'suppression') ?>
    <?= deploiementListe('Nouvelles migrations SQL', $plan['migrations']) ?>

    <?php if ($plan['migrations_retouchees']): ?>
      <p class="flash-message flash-message--error">
        Migration(s) déjà envoyée(s) puis modifiée(s) : <?= h(implode(', ', $plan['migrations_retouchees'])) ?>.
        Le fichier sera renvoyé mais <strong>jamais rejoué</strong> si la production l'a déjà appliqué.
        Pour corriger une migration passée, en écrire une nouvelle.
      </p>
    <?php endif ?>

    <div class="deploiement__options">
      <label class="deploiement__option">
        <input type="checkbox" name="migrations" value="1" checked>
        Appliquer les migrations SQL en attente en production
      </label>
      <?php if ($nbSuppr > 0): ?>
        <label class="deploiement__option">
          <input type="checkbox" name="supprimer" value="1">
          Supprimer en production les <?= $nbSuppr ?> fichier<?= $nbSuppr > 1 ? 's' : '' ?> retiré<?= $nbSuppr > 1 ? 's' : '' ?> en local
        </label>
      <?php endif ?>
    </div>

    <div class="form-actions deploiement__actions">
      <button type="button" class="btn btn-primary" data-deploiement="demander">
        <i class="fa fa-cloud-arrow-up"></i> <?= $aJour ? 'Vérifier les migrations…' : 'Déployer…' ?>
      </button>
      <?php if (!$plan['complet']): ?>
        <button type="button" class="btn btn-secondary" data-deploiement="complet"
                title="Ignorer le manifeste et renvoyer tous les fichiers, même inchangés">
          Tout renvoyer
        </button>
      <?php endif ?>
      <a class="btn btn-secondary" href="<?= BASE_URL ?>/admin/deploiement/index.php" title="Paramètres du déploiement">
        <i class="fa fa-gear"></i>
      </a>
    </div>

    <div class="deploiement__confirmation noDisplay"
         data-plan="<?= h($plan['id']) ?>"
         data-nb-envoi="<?= $nbEnvoi ?>"
         data-nb-suppression="<?= $nbSuppr ?>"
         data-cible="<?= h($cible) ?>">
      <p class="deploiement__question"></p>
      <div class="form-actions">
        <button type="button" class="btn btn-danger" data-deploiement="confirmer">
          <i class="fa fa-check"></i> Confirmer le déploiement
        </button>
        <button type="button" class="btn btn-secondary" data-deploiement="annuler">Annuler</button>
      </div>
    </div>

    <div class="deploiement__suivi noDisplay">
      <progress class="deploiement__progression" value="0" max="1"></progress>
      <ol class="deploiement__journal"></ol>
    </div>

  <?php endif ?>
</div>
