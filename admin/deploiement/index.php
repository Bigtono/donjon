<?php
// admin/deploiement/index.php — Paramètres du déploiement (SP-DP1, SP-DP2)
//
// Connexion SFTP, approbation de l'empreinte du serveur, vérification de bout
// en bout, aperçu du périmètre et journal. Les paramètres sont écrits hors du
// projet (deploiementDossierPrive()), jamais en base : la base locale est
// régulièrement exportée en dump dans sql/.
require_once __DIR__ . '/garde.php';

$config  = deploiementConfig();
$erreurs = [];
$saisie  = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST'):
  verifyCsrf();
  $section = strParam($_POST['section'] ?? '');

  try {
    if ($section === 'parametres'):
      [$nouvelle, $erreurs] = deploiementValiderConfig($_POST, $config);
      if ($erreurs):
        $saisie = $_POST; // réaffichage sans redirection, mot de passe exclu
      else:
        deploiementEnregistrerConfig($nouvelle);
        $_SESSION['flash_message'] = [
          'type' => 'success',
          'text' => 'Paramètres enregistrés.'
            . ($nouvelle['empreinte'] === '' ? ' Il reste à lire et approuver l\'empreinte du serveur.' : ''),
        ];
      endif;

    elseif ($section === 'lire_empreinte'):
      $_SESSION['deploiement_empreinte'] = [
        'hote'      => $config['hote'],
        'port'      => (int)$config['port'],
        'empreinte' => DeploiementSftp::decouvrirEmpreinte($config['hote'], (int)$config['port']),
      ];

    elseif ($section === 'approuver_empreinte'):
      // L'empreinte approuvée est celle que le serveur a présentée (gardée en
      // session), jamais une valeur postée par le formulaire.
      $proposee = $_SESSION['deploiement_empreinte'] ?? null;
      if ($proposee && $proposee['hote'] === $config['hote'] && $proposee['port'] === (int)$config['port']):
        $config['empreinte'] = $proposee['empreinte'];
        deploiementEnregistrerConfig($config);
        $_SESSION['flash_message'] = ['type' => 'success', 'text' => 'Empreinte approuvée.'];
      endif;
      unset($_SESSION['deploiement_empreinte']);

    elseif ($section === 'oublier_empreinte'):
      $config['empreinte'] = '';
      deploiementEnregistrerConfig($config);
      unset($_SESSION['deploiement_empreinte']);

    elseif ($section === 'tester'):
      @set_time_limit(120);
      $_SESSION['deploiement_test'] = deploiementTester($config);
    endif;
  } catch (Throwable $e) {
    $_SESSION['flash_message'] = ['type' => 'error', 'text' => $e->getMessage()];
  }

  if (!$erreurs):
    header('Location: ' . BASE_URL . '/admin/deploiement/index.php');
    exit;
  endif;
endif;

// --- Lecture ----------------------------------------------------------------
$valeurs   = $saisie ?? $config;
$proposee  = $_SESSION['deploiement_empreinte'] ?? null;
$test      = $_SESSION['deploiement_test'] ?? null;
unset($_SESSION['deploiement_test']);
$complete  = deploiementConfigComplete($config);
$journal   = deploiementJournal();

$perimetre = null;
$erreurPerimetre = null;
try {
  $perimetre = deploiementPerimetre($config, true);
} catch (Throwable $e) {
  $erreurPerimetre = $e->getMessage();
}

// Fichiers envoyés, regroupés par dossier de premier niveau.
$parDossier = [];
foreach ($perimetre['fichiers'] ?? [] as $chemin):
  $dossier = str_contains($chemin, '/') ? strstr($chemin, '/', true) . '/' : '(racine)';
  $parDossier[$dossier][] = $chemin;
endforeach;

$statutsJournal = [
  'succes'  => ['libelle' => 'Réussi', 'badge' => 'badge--actif'],
  'echec'   => ['libelle' => 'Échec', 'badge' => 'badge--admin'],
  'abandon' => ['libelle' => 'Abandonné', 'badge' => 'badge--inactif'],
];

$page_title = 'Déploiement';
$css_module = 'admin';

require_once __DIR__ . '/../../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Déploiement</h1>
  <?php if ($complete): ?>
    <button type="button" class="btn btn-primary" onclick="ouvrirDeploiement()">
      <i class="fa fa-cloud-arrow-up"></i> Déployer…
    </button>
  <?php endif ?>
</div>

<p class="text-muted mb-md">
  Envoi par SFTP des fichiers modifiés vers la production, puis application des migrations SQL.
  Module local : il n'est jamais transféré. Paramètres et journal :
  <code><?= h(deploiementDossierPrive()) ?></code>, hors du projet.
</p>

<?php if ($erreurs): ?>
  <div class="flash-message flash-message--error">
    <?php foreach ($erreurs as $message): ?>
      <div><?= h($message) ?></div>
    <?php endforeach ?>
  </div>
<?php endif ?>

<div class="deploiement-sections">

  <section class="deploiement-section">
    <h2>Connexion SFTP</h2>
    <form method="POST" action="<?= BASE_URL ?>/admin/deploiement/index.php" autocomplete="off">
      <?= csrfField() ?>
      <input type="hidden" name="section" value="parametres">

      <div class="deploiement-grille">
        <div class="form-group">
          <label for="dp_hote">Hôte</label>
          <input type="text" id="dp_hote" name="hote" value="<?= h((string)$valeurs['hote']) ?>"
                 placeholder="ftp.clusterXXX.hosting.ovh.net">
        </div>
        <div class="form-group">
          <label for="dp_port">Port</label>
          <input type="number" id="dp_port" name="port" min="1" max="65535" value="<?= (int)$valeurs['port'] ?>">
        </div>
        <div class="form-group">
          <label for="dp_utilisateur">Utilisateur</label>
          <input type="text" id="dp_utilisateur" name="utilisateur" value="<?= h((string)$valeurs['utilisateur']) ?>">
        </div>
        <div class="form-group">
          <label for="dp_mdp">Mot de passe</label>
          <input type="password" id="dp_mdp" name="mot_de_passe" value="" autocomplete="new-password"
                 placeholder="<?= $config['mot_de_passe'] !== '' ? 'Enregistré — laisser vide pour le conserver' : '' ?>">
        </div>
        <div class="form-group">
          <label for="dp_chemin">Dossier du site</label>
          <input type="text" id="dp_chemin" name="chemin_distant" value="<?= h((string)$valeurs['chemin_distant']) ?>">
          <p class="form-hint">Relatif au dossier d'accueil du compte SFTP, ou absolu.</p>
        </div>
        <div class="form-group">
          <label for="dp_prive">Dossier privé distant</label>
          <input type="text" id="dp_prive" name="dossier_prive" value="<?= h((string)$valeurs['dossier_prive']) ?>">
          <p class="form-hint">Manifeste du déploiement. Hors de <code>www/</code> : jamais servi par le web.</p>
        </div>
        <div class="form-group">
          <label for="dp_url">URL du site en production</label>
          <input type="text" id="dp_url" name="url_production" value="<?= h((string)$valeurs['url_production']) ?>">
          <p class="form-hint">Sert à déclencher les migrations SQL après l'envoi.</p>
        </div>
        <div class="form-group">
          <label for="dp_git">Exécutable git <span class="text-muted">(facultatif)</span></label>
          <input type="text" id="dp_git" name="git" value="<?= h((string)$valeurs['git']) ?>"
                 placeholder="<?= h(deploiementGitExecutable(['git' => ''])) ?>">
        </div>
      </div>

      <p class="form-hint">
        Le mot de passe est conservé en clair dans le dossier privé ci-dessus : hors du site, du dépôt
        et de OneDrive. Activer le SFTP du compte dans l'espace client OVH (onglet FTP-SSH) si ce n'est
        pas déjà fait.
      </p>
      <div class="form-actions">
        <button type="submit" class="btn btn-primary"><i class="fa fa-floppy-disk"></i> Enregistrer</button>
      </div>
    </form>
  </section>

  <section class="deploiement-section">
    <h2>Empreinte du serveur</h2>
    <?php if ($config['hote'] === ''): ?>
      <p class="text-muted">Renseigner d'abord l'hôte.</p>
    <?php elseif ($proposee && $proposee['hote'] === $config['hote']): ?>
      <p>Empreinte présentée par <strong><?= h($config['hote']) ?></strong> :</p>
      <p class="deploiement-empreinte">SHA256:<?= h($proposee['empreinte']) ?></p>
      <p class="form-hint">
        La comparer avec celle qu'affiche FileZilla à la première connexion, ou avec
        <code>ssh-keyscan <?= h($config['hote']) ?> | ssh-keygen -lf -</code>. Une fois approuvée,
        toute connexion à un serveur présentant une autre clé sera refusée.
      </p>
      <div class="form-actions">
        <form method="POST" action="<?= BASE_URL ?>/admin/deploiement/index.php">
          <?= csrfField() ?>
          <input type="hidden" name="section" value="approuver_empreinte">
          <button type="submit" class="btn btn-primary"><i class="fa fa-check"></i> Approuver</button>
        </form>
        <form method="POST" action="<?= BASE_URL ?>/admin/deploiement/index.php">
          <?= csrfField() ?>
          <input type="hidden" name="section" value="oublier_empreinte">
          <button type="submit" class="btn btn-secondary">Annuler</button>
        </form>
      </div>
    <?php elseif ($config['empreinte'] !== ''): ?>
      <p><i class="fa fa-lock deploiement-ok"></i> Approuvée pour <strong><?= h($config['hote']) ?></strong> :</p>
      <p class="deploiement-empreinte">SHA256:<?= h($config['empreinte']) ?></p>
      <form method="POST" action="<?= BASE_URL ?>/admin/deploiement/index.php"
            onsubmit="return confirm('Oublier l\'empreinte approuvée ? Aucun déploiement ne sera possible avant d\'en approuver une nouvelle.');">
        <?= csrfField() ?>
        <input type="hidden" name="section" value="oublier_empreinte">
        <button type="submit" class="btn btn-secondary btn-sm">Oublier cette empreinte</button>
      </form>
    <?php else: ?>
      <p class="text-muted">
        Aucune empreinte approuvée : la lecture se fait sans s'authentifier, aucun identifiant n'est envoyé.
      </p>
      <form method="POST" action="<?= BASE_URL ?>/admin/deploiement/index.php">
        <?= csrfField() ?>
        <input type="hidden" name="section" value="lire_empreinte">
        <button type="submit" class="btn btn-primary"><i class="fa fa-fingerprint"></i> Lire l'empreinte du serveur</button>
      </form>
    <?php endif ?>
  </section>

  <section class="deploiement-section">
    <h2>Vérification</h2>
    <?php if (!$complete): ?>
      <p class="text-muted">Disponible une fois les paramètres complets et l'empreinte approuvée.</p>
    <?php else: ?>
      <p class="text-muted">
        Écrit, relit puis supprime un fichier témoin dans le dossier privé, contrôle le dossier du site
        et interroge la production. Rien d'autre n'est modifié.
      </p>
      <form method="POST" action="<?= BASE_URL ?>/admin/deploiement/index.php">
        <?= csrfField() ?>
        <input type="hidden" name="section" value="tester">
        <button type="submit" class="btn btn-secondary"><i class="fa fa-plug"></i> Tester la connexion</button>
      </form>
      <?php if ($test): ?>
        <ul class="deploiement-test">
          <?php foreach ($test as $ligne): ?>
            <li class="<?= $ligne['ok'] ? 'deploiement-ok' : 'deploiement-ko' ?>">
              <i class="fa <?= $ligne['ok'] ? 'fa-check' : 'fa-xmark' ?>"></i> <?= h($ligne['texte']) ?>
            </li>
          <?php endforeach ?>
        </ul>
      <?php endif ?>
    <?php endif ?>
  </section>

  <section class="deploiement-section">
    <h2>Périmètre</h2>
    <?php if ($erreurPerimetre !== null): ?>
      <p class="flash-message flash-message--error"><?= h($erreurPerimetre) ?></p>
    <?php else: ?>
      <p class="text-muted">
        Calculé par git : fichiers suivis et nouveaux, moins ce qu'excluent <code>.gitignore</code>,
        <code>.deployignore</code> et les exclusions fixes du module. Pour retirer un fichier versionné
        de la production, l'ajouter à <code>.deployignore</code>.
      </p>
      <div class="deploiement__bilan">
        <span class="deploiement__chiffre"><strong><?= count($perimetre['fichiers']) ?></strong> fichiers envoyés</span>
        <span class="deploiement__chiffre"><strong><?= count($perimetre['exclus']) ?></strong> exclusions</span>
      </div>
      <details class="deploiement__liste">
        <summary>Fichiers envoyés, par dossier</summary>
        <ul>
          <?php foreach ($parDossier as $dossier => $fichiers): ?>
            <li><strong><?= h($dossier) ?></strong> — <?= count($fichiers) ?></li>
          <?php endforeach ?>
        </ul>
      </details>
      <details class="deploiement__liste">
        <summary>Exclusions et leur règle</summary>
        <ul>
          <?php foreach ($perimetre['exclus'] as $chemin => $raison): ?>
            <li><?= h($chemin) ?> <span class="text-muted">— <?= h($raison) ?></span></li>
          <?php endforeach ?>
        </ul>
      </details>
    <?php endif ?>
  </section>

  <section class="deploiement-section">
    <h2>Journal</h2>
    <?php if (!$journal): ?>
      <p class="text-muted">Aucun déploiement pour le moment.</p>
    <?php else: ?>
      <div class="comp-liste-wrapper">
        <table class="comp-liste">
          <thead>
            <tr>
              <th>Date</th>
              <th>Statut</th>
              <th>Détail</th>
            </tr>
          </thead>
          <tbody>
            <?php foreach ($journal as $entree): ?>
              <?php $statut = $statutsJournal[$entree['statut'] ?? ''] ?? ['libelle' => (string)($entree['statut'] ?? '?'), 'badge' => 'badge--ruleset'] ?>
              <tr>
                <td><?= h(date('d/m/Y H:i', strtotime((string)$entree['date']))) ?></td>
                <td><span class="badge <?= h($statut['badge']) ?>"><?= h($statut['libelle']) ?></span></td>
                <td>
                  <?php if (($entree['statut'] ?? '') === 'succes'): ?>
                    <?= count($entree['envoyes'] ?? []) ?> envoyé(s), <?= count($entree['supprimes'] ?? []) ?> supprimé(s),
                    <?= (int)($entree['duree_s'] ?? 0) ?> s
                    <?php if (!empty($entree['migrations'])): ?>
                      <br><span class="text-muted"><?= h((string)$entree['migrations']) ?></span>
                    <?php endif ?>
                  <?php else: ?>
                    <?= h(trim(($entree['etape'] ?? '') . ' — ' . ($entree['erreur'] ?? ''), ' —')) ?>
                  <?php endif ?>
                </td>
              </tr>
            <?php endforeach ?>
          </tbody>
        </table>
      </div>
    <?php endif ?>
    <p class="mt-md">
      <a href="<?= BASE_URL ?>/admin/migrations.php"><i class="fa fa-database"></i> Migrations SQL de la base locale</a>
      <br>
      <a href="<?= BASE_URL ?>/admin/deploiement/export-classes.php"><i class="fa fa-file-export"></i> Export de classes vers la production</a>
    </p>
  </section>

</div>

<?php
require_once __DIR__ . '/../../include/footer.php';
?>
