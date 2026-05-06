<?php
// OUTIL TEMPORAIRE — À SUPPRIMER APRÈS USAGE
// Accessible uniquement depuis localhost
if ($_SERVER['REMOTE_ADDR'] !== '127.0.0.1' && $_SERVER['REMOTE_ADDR'] !== '::1') {
    http_response_code(403);
    exit('Accès refusé.');
}

require_once __DIR__ . '/../include/db.php';

$message = '';
$hash    = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = trim($_POST['email'] ?? '');
    $pass  = $_POST['password'] ?? '';

    if ($email && $pass) {
        $hash = password_hash($pass, PASSWORD_DEFAULT);

        $stmt = $db->prepare('UPDATE dd_joueurs SET j_password_hash = ? WHERE j_email = ?');
        $stmt->execute([$hash, $email]);

        if ($stmt->rowCount() > 0) {
            $message = ['ok', 'Mot de passe mis à jour pour ' . htmlspecialchars($email, ENT_QUOTES, 'UTF-8') . '.'];
        } else {
            $message = ['err', 'Aucun utilisateur trouvé avec cet email.'];
        }
    } else {
        $message = ['err', 'Email et mot de passe requis.'];
    }
}
?>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <title>Réinitialisation mot de passe — OUTIL TEMP</title>
  <style>
    body { font-family: sans-serif; max-width: 480px; margin: 60px auto; padding: 0 16px; }
    h1   { font-size: 1.2rem; color: #c00; }
    label { display: block; margin-top: 12px; font-weight: bold; }
    input { width: 100%; padding: 8px; margin-top: 4px; box-sizing: border-box; }
    button { margin-top: 16px; padding: 10px 20px; background: #333; color: #fff; border: none; cursor: pointer; }
    .ok  { background: #d4edda; color: #155724; padding: 10px; margin-top: 12px; }
    .err { background: #f8d7da; color: #721c24; padding: 10px; margin-top: 12px; }
    .hash { background: #f5f5f5; padding: 8px; word-break: break-all; font-size: .85rem; margin-top: 8px; }
    .warn { background: #fff3cd; color: #856404; padding: 10px; margin-bottom: 20px; font-size: .9rem; }
  </style>
</head>
<body>
  <h1>⚠ Outil temporaire — supprimer après usage</h1>

  <div class="warn">
    Ce fichier est accessible uniquement depuis localhost.<br>
    <strong>Supprime <code>tools/gen_hash.php</code> dès que tu as fini.</strong>
  </div>

  <?php if ($message): ?>
    <div class="<?= $message[0] ?>"><?= $message[1] ?></div>
    <?php if ($hash): ?>
      <p>Hash généré :</p>
      <div class="hash"><?= htmlspecialchars($hash, ENT_QUOTES, 'UTF-8') ?></div>
    <?php endif ?>
  <?php endif ?>

  <form method="POST">
    <label>Email du compte</label>
    <input type="email" name="email" value="<?= htmlspecialchars($_POST['email'] ?? '', ENT_QUOTES, 'UTF-8') ?>" required>

    <label>Nouveau mot de passe</label>
    <input type="text" name="password" required>

    <button type="submit">Mettre à jour</button>
  </form>
</body>
</html>
