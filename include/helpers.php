<?
// include/helpers.php — Fonctions transverses
// À inclure après auth.php dans chaque page contrôleur

// ============================================================
// SÉCURITÉ / SORTIE
// ============================================================

// Échappe systématiquement pour l'affichage HTML
function h(string $val): string {
  return htmlspecialchars($val, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

// Nettoie un entier venant de l'input utilisateur
function intParam($val, int $default = 0): int {
  return (int)($val ?? $default);
}

// Nettoie une chaîne venant de l'input utilisateur
function strParam($val, string $default = ''): string {
  return trim((string)($val ?? $default));
}

// ============================================================
// FILTRAGE PROPRIÉTAIRE
// ============================================================

// Retourne le fragment SQL de filtrage propriétaire + les paramètres à binder
// Usage : [$where, $params] = ownerFilter('pe');
//         $stmt = $db->prepare("SELECT * FROM dd_personnages WHERE $where");
//         $stmt->execute($params);
function ownerFilter(string $prefix): array {
  if (isAdmin()) {
    return ['1=1', []];
  }
  return [
    $prefix . '_j_id = :owner_j_id',
    [':owner_j_id' => (int)$_SESSION['j_id']],
  ];
}

// Retourne true si l'utilisateur courant peut lire/écrire l'entité dont le j_id est fourni
function canAccess(int $entity_j_id): bool {
  return isAdmin() || (int)$_SESSION['j_id'] === $entity_j_id;
}

// ============================================================
// SÉLECTION DES SOURCES ACTIVES
// ============================================================

// Retourne le tableau des res_id actifs selon la chaîne de priorité :
//   1. Sélection campagne (si personnage en session rattaché à une campagne avec sa propre sélection)
//   2. Sélection personnelle de l'utilisateur (par ruleset)
//   3. Toutes les sources actives du ruleset (défaut absolu)
function getActiveResIds($db): array {
  $ruleset_var_id = (int)($_SESSION['ruleset_var_id'] ?? 1);
  $j_id           = (int)($_SESSION['j_id'] ?? 0);

  // Priorité 1 : sélection de la campagne via last_pe_id
  if (!empty($_SESSION['last_pe_id'])) {
    $pe_id = (int)$_SESSION['last_pe_id'];

    // Cherche si le personnage est dans une campagne ayant sa propre sélection
    $stmt = $db->prepare('
      SELECT cs.cs_res_id
      FROM   dd_campagnes_personnages cp
      JOIN   dd_campagnes_sources cs ON cs.cs_camp_id = cp.cp_camp_id
      WHERE  cp.cp_pe_id = ? AND cp.cp_actif = 1
    ');
    $stmt->execute([$pe_id]);
    $ids = $stmt->fetchAll(PDO::FETCH_COLUMN);
    if (!empty($ids)) return $ids;
  }

  // Priorité 2 : sélection personnelle
  if ($j_id > 0) {
    $stmt = $db->prepare('
      SELECT js_res_id
      FROM   dd_joueurs_sources
      WHERE  js_j_id = ? AND js_ruleset_var_id = ?
    ');
    $stmt->execute([$j_id, $ruleset_var_id]);
    $ids = $stmt->fetchAll(PDO::FETCH_COLUMN);
    if (!empty($ids)) return $ids;
  }

  // Priorité 3 : toutes les sources actives du ruleset
  $stmt = $db->prepare('
    SELECT res_id
    FROM   dd_ressources
    WHERE  res_ruleset_var_id = ? AND res_selection = 1 AND res_j_id IS NULL
  ');
  $stmt->execute([$ruleset_var_id]);
  return $stmt->fetchAll(PDO::FETCH_COLUMN);
}

// Génère des placeholders SQL pour un tableau d'ids
// Usage : $in = resIdsPlaceholders($ids); // retourne "?,?,?"
function resIdsPlaceholders(array $ids): string {
  return implode(',', array_fill(0, count($ids), '?'));
}

// ============================================================
// VARIABLES DD (libellés et selects)
// ============================================================

// Retourne le libellé d'une variable par son id
function libVar($db, int $var_id): string {
  $stmt = $db->prepare('SELECT var_valeur FROM dd_variables WHERE var_id = ?');
  $stmt->execute([$var_id]);
  $row = $stmt->fetch();
  return $row ? h($row['var_valeur']) : '';
}

// Retourne un <select> rempli avec les variables d'une catégorie
function optionListVar($db, string $cat, string $name, int $selected = 0, string $class = ''): string {
  $stmt = $db->prepare('
    SELECT var_id, var_valeur
    FROM   dd_variables
    WHERE  var_cat = ?
    ORDER  BY var_ordre, var_valeur
  ');
  $stmt->execute([$cat]);
  $rows = $stmt->fetchAll();

  $cls = $class ? ' class="' . h($class) . '"' : '';
  $out = '<select name="' . h($name) . '"' . $cls . '>';
  $out .= '<option value="0">— Choisir —</option>';
  foreach ($rows as $r) {
    $sel  = (int)$r['var_id'] === $selected ? ' selected' : '';
    $out .= '<option value="' . (int)$r['var_id'] . '"' . $sel . '>' . h($r['var_valeur']) . '</option>';
  }
  $out .= '</select>';
  return $out;
}

// ============================================================
// PAGINATION
// ============================================================

function getPagination(int $total, int $per_page, int $current_page): array {
  $per_page     = max(1, $per_page);
  $total_pages  = max(1, (int)ceil($total / $per_page));
  $current_page = max(1, min($current_page, $total_pages));
  $offset       = ($current_page - 1) * $per_page;

  return [
    'total'        => $total,
    'per_page'     => $per_page,
    'current_page' => $current_page,
    'total_pages'  => $total_pages,
    'offset'       => $offset,
  ];
}

// ============================================================
// CONTEXTE PERSONNAGE (last_pe_id)
// ============================================================

// Mémorise le dernier personnage consulté en session
function setLastPersonnage(int $pe_id) {
  $_SESSION['last_pe_id'] = $pe_id;
}

// Retourne le dernier pe_id consulté ou 0
function getLastPersonnage(): int {
  return (int)($_SESSION['last_pe_id'] ?? 0);
}
