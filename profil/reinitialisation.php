<?
// profil/reinitialisation.php — Réinitialisation du mot de passe via token
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

if (!empty($_SESSION['j_id'])):
  header('Location: ' . BASE_URL . '/index.php');
  exit;
endif;

$token  = strParam($_GET['token'] ?? '');
$errors = [];
$ok     = false;
$joueur = null;

if ($token):
  $stmt = $db->prepare('
    SELECT j_id, j_pseudo
    FROM   dd_joueurs
    WHERE  j_reset_token = ?
      AND  j_reset_token_expires > NOW()
      AND  j_visible = 1
  ');
  $stmt->execute([$token]);
  $joueur = $stmt->fetch();
endif;

if (!$token || !$joueur):
  $page_title = 'Lien invalide';
  require_once '../include/header.php';
?>
  <div class="login-wrapper">
    <div class="login-box">
      <h1 class="login-box__title">Lien invalide</h1>
      <p class="login-box__sub">
        Ce lien de réinitialisation est invalide ou a expiré (durée de validité : 1 heure).
      </p>
      <p class="login-box__footer">
        <a href="<?= BASE_URL ?>/profil/mot-de-passe-oublie.php">Faire une nouvelle demande</a>
      </p>
    </div>
  </div>
<?
  require_once '../include/footer.php';
  exit;
endif;

if ($_SERVER['REQUEST_METHOD'] === 'POST'):
  verifyCsrf();

  $nouveau  = $_POST['j_pass_nouveau']  ?? '';
  $confirme = $_POST['j_pass_confirme'] ?? '';

  if (strlen($nouveau) < 8)   $errors[] = 'Le mot de passe doit faire au moins 8 caractères.';
  if ($nouveau !== $confirme) $errors[] = 'Les deux mots de passe ne correspondent pas.';

  if (!$errors):
    $upd = $db->prepare('
      UPDATE dd_joueurs
      SET    j_password_hash       = ?,
             j_reset_token         = NULL,
             j_reset_token_expires = NULL
      WHERE  j_id = ?
    ');
    $upd->execute([password_hash($nouveau, PASSWORD_DEFAULT), $joueur['j_id']]);
    $ok = true;
  endif;
endif;

$page_title = 'Nouveau mot de passe';
require_once '../include/header.php';
?>

<div class="login-wrapper">
  <div class="login-box">
    <h1 class="login-box__title">Nouveau mot de passe</h1>
    <p class="login-box__sub">Bonjour <?= h($joueur['j_pseudo']) ?>, choisissez votre nouveau mot de passe.</p>

    <? if ($ok): ?>
      <div class="flash-message flash-message--success">
        Mot de passe modifié avec succès.
      </div>
      <p class="login-box__footer">
        <a href="<?= BASE_URL ?>/index.php" class="btn btn-primary" style="width:100%; text-align:center;">
          <i class="fa fa-sign-in-alt"></i> Se connecter
        </a>
      </p>

    <? else: ?>
      <? if ($errors): ?>
        <div class="flash-message flash-message--error"><?= h(implode(' ', $errors)) ?></div>
      <? endif ?>

      <form method="POST" action="<?= BASE_URL ?>/profil/reinitialisation.php?token=<?= urlencode($token) ?>">
        <?= csrfField() ?>
        <div class="form-group">
          <label for="j_pass_nouveau">Nouveau mot de passe <span class="text-muted">(8 car. min.)</span></label>
          <input type="password" id="j_pass_nouveau" name="j_pass_nouveau"
                 required minlength="8" autocomplete="new-password">
        </div>
        <div class="form-group">
          <label for="j_pass_confirme">Confirmer le mot de passe</label>
          <input type="password" id="j_pass_confirme" name="j_pass_confirme"
                 required minlength="8" autocomplete="new-password">
        </div>
        <div class="form-actions">
          <button type="submit" class="btn btn-primary" style="width:100%">
            <i class="fa fa-check"></i> Valider
          </button>
        </div>
      </form>
    <? endif ?>
  </div>
</div>

<?
require_once '../include/footer.php';
?>
