<?
// profil/mot-de-passe-oublie.php — Demande de réinitialisation du mot de passe
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

if (!empty($_SESSION['j_id'])):
  header('Location: ' . BASE_URL . '/index.php');
  exit;
endif;

$message  = '';
$is_error = false;

if ($_SERVER['REQUEST_METHOD'] === 'POST'):
  verifyCsrf();

  $email = strParam($_POST['email'] ?? '');

  if (!filter_var($email, FILTER_VALIDATE_EMAIL)):
    $message  = 'Adresse email invalide.';
    $is_error = true;
  else:
    $stmt = $db->prepare('SELECT j_id, j_pseudo FROM dd_joueurs WHERE j_email = ? AND j_visible = 1');
    $stmt->execute([$email]);
    $joueur = $stmt->fetch();

    // Réponse identique dans tous les cas (anti-énumération)
    $message = 'Si cette adresse correspond à un compte, vous allez recevoir un email avec un lien de réinitialisation.';

    if ($joueur):
      $token   = bin2hex(random_bytes(32));
      $expires = date('Y-m-d H:i:s', strtotime('+1 hour'));

      $upd = $db->prepare('
        UPDATE dd_joueurs
        SET    j_reset_token = ?, j_reset_token_expires = ?
        WHERE  j_id = ?
      ');
      $upd->execute([$token, $expires, $joueur['j_id']]);

      $lien  = 'http' . (isset($_SERVER['HTTPS']) ? 's' : '') . '://' . $_SERVER['HTTP_HOST'];
      $lien .= BASE_URL . '/profil/reinitialisation.php?token=' . urlencode($token);

      $sujet  = '[Codex DD] Réinitialisation de votre mot de passe';
      $corps  = "Bonjour " . $joueur['j_pseudo'] . ",\n\n";
      $corps .= "Vous avez demandé la réinitialisation de votre mot de passe.\n\n";
      $corps .= "Cliquez sur ce lien (valable 1 heure) :\n" . $lien . "\n\n";
      $corps .= "Si vous n'êtes pas à l'origine de cette demande, ignorez cet email.\n\n";
      $corps .= "— Codex DD";

      $headers = 'From: noreply@' . $_SERVER['HTTP_HOST'] . "\r\n" .
                 'Content-Type: text/plain; charset=UTF-8';

      mail($email, $sujet, $corps, $headers);
    endif;
  endif;
endif;

$page_title = 'Mot de passe oublié';
require_once '../include/header.php';
?>

<div class="login-wrapper">
  <div class="login-box">
    <h1 class="login-box__title">Mot de passe oublié</h1>
    <p class="login-box__sub">Saisissez votre email pour recevoir un lien de réinitialisation.</p>

    <? if ($message): ?>
      <div class="flash-message flash-message--<?= $is_error ? 'error' : 'info' ?>">
        <?= h($message) ?>
      </div>
    <? endif ?>

    <? if (!$message || $is_error): ?>
      <form method="POST" action="<?= BASE_URL ?>/profil/mot-de-passe-oublie.php">
        <?= csrfField() ?>
        <div class="form-group">
          <label for="email">Adresse email</label>
          <input type="email" id="email" name="email"
                 value="<?= h($_POST['email'] ?? '') ?>"
                 required autocomplete="email">
        </div>
        <div class="form-actions">
          <button type="submit" class="btn btn-primary" style="width:100%">
            <i class="fa fa-paper-plane"></i> Envoyer le lien
          </button>
        </div>
      </form>
    <? endif ?>

    <p class="login-box__footer">
      <a href="<?= BASE_URL ?>/index.php"><i class="fa fa-arrow-left"></i> Retour à la connexion</a>
    </p>
  </div>
</div>

<?
require_once '../include/footer.php';
?>
