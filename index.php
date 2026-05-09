<?
// DEBUG CSRF — À SUPPRIMER APRÈS
error_log('HOST: ' . ($_SERVER['HTTP_HOST'] ?? 'n/a'));
error_log('SESSION ID: ' . session_id());
error_log('SESSION CSRF: ' . ($_SESSION['csrf_token'] ?? 'VIDE'));
error_log('POST CSRF: ' . ($_POST['csrf_token'] ?? 'ABSENT'));

// index.php — Accueil : connexion ou dashboard
require_once 'include/db.php';
require_once 'include/auth.php';
require_once 'include/helpers.php';

// Logout
if (isset($_GET['action']) && $_GET['action'] === 'logout') {
  logout();
  header('Location: ' . BASE_URL . '/index.php');
  exit;
}

// Traitement connexion
$errors = [];
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  verifyCsrf();

  $email = strParam($_POST['email'] ?? '');
  $pass  = strParam($_POST['password'] ?? '');

  if (!$email || !$pass) {
    $errors[] = 'Email et mot de passe requis.';
  } else {
    $stmt = $db->prepare('
      SELECT j_id, j_pseudo, j_password_hash, j_admin, j_compendium_manager,
             j_default_ruleset_var_id, j_remember_token, j_affichage_ruleset,
             j_mode_campagne
      FROM   dd_joueurs
      WHERE  j_email = ? AND j_visible = 1
    ');
    $stmt->execute([$email]);
    $row = $stmt->fetch();

    if (!$row || !password_verify($pass, $row['j_password_hash'])) {
      $errors[] = 'Identifiants incorrects.';
    } else {
      startUserSession($row);

      // Mise à jour dernière connexion
      $upd = $db->prepare('UPDATE dd_joueurs SET j_derniere_connexion = NOW() WHERE j_id = ?');
      $upd->execute([$row['j_id']]);

      // Remember me
      if (!empty($_POST['remember_me'])) {
        $token = bin2hex(random_bytes(32));
        $exp   = date('Y-m-d H:i:s', strtotime('+30 days'));
        $upd2  = $db->prepare('
          UPDATE dd_joueurs
          SET    j_remember_token = ?, j_remember_token_expires = ?
          WHERE  j_id = ?
        ');
        $upd2->execute([$token, $exp, $row['j_id']]);
        setRememberCookie($token, strtotime('+30 days'));
      }

      header('Location: ' . BASE_URL . '/index.php');
      exit;
    }
  }
}

// Si connecté → dashboard
if (!empty($_SESSION['j_id'])) {
  $page_title = 'Tableau de bord';
  $js_module  = '';
  require_once 'include/header.php';
?>
  <div class="flex-between mb-md">
    <h1>Bienvenue, <?= h($_SESSION['j_pseudo']) ?></h1>
    <span class="text-muted"><?= h($_SESSION['rulesetRep'] ?? '') ?></span>
  </div>

  <div class="dashboard-grid">
    <a href="<?= BASE_URL ?>/personnages/fiche.php" class="dashboard-card">
      <i class="fa fa-user"></i>
      <span>Mes personnages</span>
    </a>
    <a href="<?= BASE_URL ?>/compendium/index.php" class="dashboard-card">
      <i class="fa fa-book"></i>
      <span>Compendium</span>
    </a>
    <? if (!empty($_SESSION['j_mode_campagne'])): ?>
      <a href="<?= BASE_URL ?>/campagnes/campagne.php" class="dashboard-card">
        <i class="fa fa-map"></i>
        <span>Mes campagnes</span>
      </a>
    <? endif ?>
    <a href="<?= BASE_URL ?>/wiki/univers.php" class="dashboard-card">
      <i class="fa fa-globe"></i>
      <span>Mes univers</span>
    </a>
    <? if (!empty($_SESSION['j_admin'])): ?>
      <a href="<?= BASE_URL ?>/admin/utilisateurs.php" class="dashboard-card dashboard-card--admin">
        <i class="fa fa-cog"></i>
        <span>Administration</span>
      </a>
    <? endif ?>
  </div>

<?
  require_once 'include/footer.php';
  exit;
}

// Sinon → formulaire de connexion
$page_title = 'Connexion';
require_once 'include/header.php';
?>

<div class="login-wrapper">
  <div class="login-box">
    <h1 class="login-box__title">Codex DD</h1>
    <p class="login-box__sub">Connexion à votre espace</p>

    <? if (!empty($errors)): ?>
      <div class="flash-message flash-message--error">
        <?= h(implode(' ', $errors)) ?>
      </div>
    <? endif ?>

    <form method="POST" action="<?= BASE_URL ?>/index.php">
      <?= csrfField() ?>

      <div class="form-group">
        <label for="email">Email</label>
        <input type="email" id="email" name="email"
          value="<?= h($_POST['email'] ?? '') ?>"
          required autocomplete="email">
      </div>

      <div class="form-group">
        <label for="password">Mot de passe</label>
        <input type="password" id="password" name="password"
          required autocomplete="current-password">
      </div>

      <div class="form-group form-group--inline">
        <label>
          <input type="checkbox" name="remember_me" value="1">
          Se souvenir de moi (30 jours)
        </label>
      </div>

      <div class="form-actions">
        <button type="submit" class="btn btn-primary" style="width:100%">
          <i class="fa fa-sign-in-alt"></i> Connexion
        </button>
      </div>
      <p class="login-box__footer">
        <a href="<?= BASE_URL ?>/profil/mot-de-passe-oublie.php">Mot de passe oublié ?</a>
      </p>
    </form>
  </div>
</div>

<?
require_once 'include/footer.php';
?>