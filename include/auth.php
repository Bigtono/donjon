<?
// include/auth.php — Gestion de session et contrôle d'accès
// À inclure après db.php dans chaque page contrôleur

// --- Démarrage sécurisé de la session ---
if (session_status() === PHP_SESSION_NONE) {
  session_set_cookie_params([
    'lifetime' => 0,
    'path'     => '/',
    'secure'   => true,
    'httponly' => true,
    'samesite' => 'Lax',
  ]);
  session_start();
}

// --- Remember me ---
function checkRememberMe($db) {
  if (isset($_SESSION['j_id'])) return;
  if (!isset($_COOKIE['remember_token'])) return;

  $token = $_COOKIE['remember_token'];
  $stmt  = $db->prepare('
    SELECT j_id, j_pseudo, j_admin, j_compendium_manager, j_default_ruleset_var_id
    FROM   dd_joueurs
    WHERE  j_remember_token = ?
      AND  j_remember_token_expires > NOW()
      AND  j_visible = 1
  ');
  $stmt->execute([$token]);
  $row = $stmt->fetch();
  if (!$row) return;

  startUserSession($row);
  // Prolonge le cookie
  setRememberCookie($token, strtotime('+30 days'));
}

function startUserSession(array $row) {
  session_regenerate_id(true);
  $_SESSION['j_id']                  = (int)$row['j_id'];
  $_SESSION['j_pseudo']              = $row['j_pseudo'];
  $_SESSION['j_admin']               = (bool)$row['j_admin'];
  $_SESSION['j_compendium_manager']  = (bool)$row['j_compendium_manager'];
  $_SESSION['ruleset_var_id']        = (int)($row['j_default_ruleset_var_id'] ?? 1);
  $_SESSION['rulesetRep']            = getRulesetRep($_SESSION['ruleset_var_id']);
}

function setRememberCookie(string $token, int $expires) {
  setcookie('remember_token', $token, [
    'expires'  => $expires,
    'path'     => '/',
    'secure'   => true,
    'httponly' => true,
    'samesite' => 'Lax',
  ]);
}

// --- Vérifications d'accès ---

// Redirige vers login si non connecté
function requireAuth(string $redirect = '/index.php') {
  if (empty($_SESSION['j_id'])) {
    header('Location: ' . $redirect);
    exit;
  }
}

// Redirige si non admin
function requireAdmin(string $redirect = '/index.php') {
  requireAuth($redirect);
  if (empty($_SESSION['j_admin'])) {
    header('Location: ' . $redirect);
    exit;
  }
}

// Vrai si l'utilisateur courant est admin
function isAdmin(): bool {
  return !empty($_SESSION['j_admin']);
}

// Vrai si l'utilisateur peut éditer le compendium global
function canEditCompendium(): bool {
  return isAdmin() || !empty($_SESSION['j_compendium_manager']);
}

// Vrai si l'utilisateur est propriétaire d'une ressource ($owner_j_id)
function isOwner(int $owner_j_id): bool {
  return isset($_SESSION['j_id']) && ((int)$_SESSION['j_id'] === $owner_j_id || isAdmin());
}

// Vrai si l'utilisateur est MJ de la campagne donnée
function isMJ($db, int $camp_id): bool {
  if (isAdmin()) return true;
  $stmt = $db->prepare('SELECT camp_j_id FROM dd_campagnes WHERE camp_id = ?');
  $stmt->execute([$camp_id]);
  $row = $stmt->fetch();
  return $row && (int)$row['camp_j_id'] === (int)$_SESSION['j_id'];
}

// --- Ruleset ---

// Whitelist stricte des rulesets autorisés
function getRulesetRep(int $ruleset_var_id): string {
  $map = [
    1 => 'DD3.5',
    2 => 'DD2024',
  ];
  return $map[$ruleset_var_id] ?? 'DD3.5';
}

// Inclut le template ruleset approprié (lecture seule, pas d'auth dedans)
function includeRulesetTemplate(string $template) {
  $rep  = $_SESSION['rulesetRep'] ?? 'DD3.5';
  $safe = ['DD3.5', 'DD2024'];
  if (!in_array($rep, $safe, true)) {
    error_log('rulesetRep invalide : ' . $rep);
    exit('Ruleset non supporté.');
  }
  $path = __DIR__ . '/insert/' . $rep . '/' . $template . '.php';
  if (!file_exists($path)) {
    error_log('Template ruleset introuvable : ' . $path);
    exit('Template manquant.');
  }
  include $path;
}

// --- CSRF ---

function csrfToken(): string {
  if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
  }
  return $_SESSION['csrf_token'];
}

function csrfField(): string {
  return '<input type="hidden" name="csrf_token" value="' . htmlspecialchars(csrfToken(), ENT_QUOTES, 'UTF-8') . '">';
}

function verifyCsrf() {
  $token = $_POST['csrf_token'] ?? '';
  if (!hash_equals(csrfToken(), $token)) {
    http_response_code(403);
    exit('Token CSRF invalide.');
  }
}

// --- Logout ---

function logout() {
  if (isset($_COOKIE['remember_token'])) {
    setRememberCookie('', time() - 3600);
  }
  session_unset();
  session_destroy();
}

// Exécution automatique : vérifie le remember me si session vide
checkRememberMe($db);
