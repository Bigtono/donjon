<?php
// admin/test-email.php — Test d'envoi de mail depuis le serveur (SP-ML1, SP-ML6)
// Le destinataire se choisit parmi les comptes actifs du site, jamais en saisie
// libre : cette page ne doit pas pouvoir servir à écrire à un tiers (D-ML7).
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAdmin();

$comptes = $db->query("
  SELECT   j_id, j_pseudo, j_email
  FROM     dd_joueurs
  WHERE    j_visible = 1 AND j_email <> ''
  ORDER BY j_pseudo
")->fetchAll();

$variantes = [
  'simple'           => 'Message de test simple',
  'reinitialisation' => 'Imitation du mail de réinitialisation (lien factice)',
];

$dest_id     = (int)$_SESSION['j_id'];
$variante    = 'simple';
$envoi_tente = false;
$accepte     = false;
$heure_envoi = '';
$erreur      = null;
$reponses    = [];
$destinataire = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST'):
  verifyCsrf();
  $dest_id  = intParam($_POST['dest_id'] ?? 0);
  $variante = isset($variantes[$_POST['variante'] ?? '']) ? $_POST['variante'] : 'simple';

  foreach ($comptes as $compte):
    if ((int)$compte['j_id'] === $dest_id):
      $destinataire = $compte;
    endif;
  endforeach;

  $envoi_tente = true;
  $heure_envoi = date('d/m/Y H:i:s');

  if (!$destinataire):
    $erreur = 'Ce destinataire n\'est pas un compte actif du site.';
  elseif ($variante === 'reinitialisation'):
    // Jeton volontairement invalide : reinitialisation.php répond « Lien invalide ».
    $lien_factice = (defined('SITE_ORIGINE') ? SITE_ORIGINE : '') . BASE_URL
      . '/profil/reinitialisation.php?token=' . str_repeat('0', 64);
    $accepte = envoyerMail(
      $destinataire['j_email'],
      SUJET_MAIL_REINITIALISATION,
      corpsMailReinitialisation($destinataire['j_pseudo'], $lien_factice),
      $erreur,
      $reponses
    );
  else:
    $corps  = "Ce message confirme que le serveur a pu envoyer un mail.\n\n";
    $corps .= "Envoyé le " . $heure_envoi . " depuis l'administration de Codex DD.\n\n";
    $corps .= "— Codex DD";
    $accepte = envoyerMail($destinataire['j_email'], '[Codex DD] Test d\'envoi de mail', $corps, $erreur, $reponses);
  endif;
endif;

$page_title = 'Test d\'envoi de mail';
$css_module = 'admin';

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Test d'envoi de mail</h1>
  <a href="<?= BASE_URL ?>/admin/index.php" class="btn btn-secondary btn-sm">
    <i class="fa fa-arrow-left"></i> Administration
  </a>
</div>

<?php if ($envoi_tente && $accepte): ?>
  <div class="flash-message flash-message--info">
    Le serveur a accepté le message à <?= h($heure_envoi) ?>, pour <?= h($destinataire['j_email']) ?>.
    Cela ne prouve pas qu'il est arrivé : regardez la boîte de réception et les indésirables.
  </div>
<?php elseif ($envoi_tente): ?>
  <div class="flash-message flash-message--error">
    Le message n'a pas été accepté à <?= h($heure_envoi) ?>.
    <?php if ($erreur): ?>
      <br><?= h($erreur) ?>
    <?php endif ?>
  </div>
<?php endif ?>

<section class="admin-outils">
  <p>Expéditeur : <strong><?= h(defined('MAIL_EXPEDITEUR') ? MAIL_EXPEDITEUR : 'non configuré') ?></strong></p>
  <p>Mode d'envoi : <strong><?= h(smtpConfigure() ? 'SMTP authentifié (' . SMTP_HOTE . ')' : 'mail() de l\'hébergement') ?></strong></p>

  <?php if ($reponses): ?>
    <p>Réponses du serveur SMTP :</p>
    <pre><?= h(implode("\n", $reponses)) ?></pre>
  <?php endif ?>

  <form method="POST" action="<?= BASE_URL ?>/admin/test-email.php">
    <?= csrfField() ?>

    <div class="form-group">
      <label for="dest_id">Destinataire (comptes actifs du site)</label>
      <select id="dest_id" name="dest_id">
        <?php foreach ($comptes as $compte): ?>
          <option value="<?= (int)$compte['j_id'] ?>" <?= (int)$compte['j_id'] === $dest_id ? 'selected' : '' ?>>
            <?= h($compte['j_pseudo'] . ' — ' . $compte['j_email']) ?>
          </option>
        <?php endforeach ?>
      </select>
    </div>

    <div class="form-group">
      <label for="variante">Contenu</label>
      <select id="variante" name="variante">
        <?php foreach ($variantes as $code => $libelle): ?>
          <option value="<?= h($code) ?>" <?= $code === $variante ? 'selected' : '' ?>><?= h($libelle) ?></option>
        <?php endforeach ?>
      </select>
    </div>

    <div class="form-actions">
      <button type="submit" class="btn btn-primary">
        <i class="fa fa-paper-plane"></i> Envoyer un mail de test
      </button>
    </div>
  </form>
</section>

<?php
require_once '../include/footer.php';
?>
