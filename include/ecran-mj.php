<?php
// include/ecran-mj.php — Écran du MJ : lecture, rendu et enregistrement (SP-TB8).
//
// L'écran d'une campagne regroupe des tableaux dd_tableaux disposés dans des
// colonnes virtuelles (dd_campagnes_ecran, nombre de colonnes dans
// dd_campagnes.camp_ecran_colonnes). Le placement lui-même est calculé côté
// client (js/ecran-mj.js) : chaque tableau est posé, dans l'ordre global
// ce_ordre, au plus haut des colonnes qu'il couvre.
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9c (Écran du MJ)

require_once __DIR__ . '/tableau-parser.php';

const ECRAN_MJ_COLONNES_MIN = 2;
const ECRAN_MJ_COLONNES_MAX = 6;

// Ramène un nombre de colonnes dans les bornes admises.
function ecranMJBornerColonnes(int $nb): int
{
  return max(ECRAN_MJ_COLONNES_MIN, min(ECRAN_MJ_COLONNES_MAX, $nb));
}

// Campagne active (non supprimée) : [camp_id, camp_nom, camp_ruleset_var_id,
// camp_ecran_colonnes] ou null.
function chargerCampagneEcran(PDO $db, int $camp_id): ?array
{
  $stmt = $db->prepare('
    SELECT camp_id, camp_nom, camp_j_id, camp_ruleset_var_id, camp_ecran_colonnes
    FROM   dd_campagnes
    WHERE  camp_id = ? AND camp_supprime = 0
  ');
  $stmt->execute([$camp_id]);
  $row = $stmt->fetch();
  return $row ?: null;
}

// Tableaux posés sur l'écran d'une campagne, dans l'ordre global de placement.
// Un tableau passé en brouillon depuis son ajout disparaît de l'écran sans que
// sa ligne soit effacée : il revient s'il redevient visible.
function chargerEcranMJ(PDO $db, int $camp_id, int $ruleset_id): array
{
  $stmt = $db->prepare('
    SELECT t.*, ce.ce_colonne, ce.ce_largeur, ce.ce_replie
    FROM   dd_campagnes_ecran ce
    JOIN   dd_tableaux t ON t.tab_id = ce.ce_tab_id
    WHERE  ce.ce_camp_id = ?
      AND  t.tab_ruleset_var_id = ?
      AND  t.tab_visible = 1
    ORDER  BY ce.ce_ordre, ce.ce_id
  ');
  $stmt->execute([$camp_id, $ruleset_id]);
  return $stmt->fetchAll();
}

// Sélection proposée par le compendium (tab_ecran_mj = 1), répartie à tour de
// rôle sur les colonnes : sert à préremplir un écran vide.
function chargerSelectionProposee(PDO $db, int $ruleset_id, int $nb_colonnes): array
{
  $stmt = $db->prepare('
    SELECT * FROM dd_tableaux
    WHERE  tab_ruleset_var_id = ? AND tab_ecran_mj = 1 AND tab_visible = 1
    ORDER  BY tab_ecran_ordre, tab_nom
  ');
  $stmt->execute([$ruleset_id]);
  $rows = $stmt->fetchAll();
  foreach ($rows as $i => &$r):
    $r['ce_colonne'] = $i % $nb_colonnes;
    $r['ce_largeur'] = 1;
    $r['ce_replie']  = 0;
  endforeach;
  unset($r);
  return $rows;
}

// Tableaux désignés par leurs ids (ajout depuis le sélecteur), dans l'ordre
// demandé. Les ids hors ruleset ou masqués sont ignorés.
function chargerTableauxEcran(PDO $db, array $ids, int $ruleset_id): array
{
  $ids = array_values(array_unique(array_filter(array_map('intval', $ids), fn($v) => $v > 0)));
  if (empty($ids)) return [];

  $ph   = implode(',', array_fill(0, count($ids), '?'));
  $stmt = $db->prepare("
    SELECT * FROM dd_tableaux
    WHERE  tab_id IN ($ph) AND tab_ruleset_var_id = ? AND tab_visible = 1
  ");
  $stmt->execute(array_merge($ids, [$ruleset_id]));
  $par_id = [];
  foreach ($stmt->fetchAll() as $r):
    $r['ce_colonne'] = 0;
    $r['ce_largeur'] = 1;
    $r['ce_replie']  = 0;
    $par_id[(int)$r['tab_id']] = $r;
  endforeach;

  $out = [];
  foreach ($ids as $id):
    if (isset($par_id[$id])) $out[] = $par_id[$id];
  endforeach;
  return $out;
}

// Autres campagnes du même ruleset dont l'utilisateur est MJ (toutes pour
// l'admin), avec le nombre de tableaux de leur écran. Seules celles qui ont
// un écran non vide sont utiles à la duplication.
function listerCampagnesDuplicables(PDO $db, array $camp): array
{
  $sql = '
    SELECT c.camp_id, c.camp_nom, c.camp_ecran_colonnes, COUNT(ce.ce_id) AS nb_tableaux
    FROM   dd_campagnes c
    JOIN   dd_campagnes_ecran ce ON ce.ce_camp_id = c.camp_id
    WHERE  c.camp_supprime = 0
      AND  c.camp_id <> ?
      AND  c.camp_ruleset_var_id = ?
  ';
  $params = [(int)$camp['camp_id'], (int)$camp['camp_ruleset_var_id']];
  if (!isAdmin()):
    $sql     .= ' AND c.camp_j_id = ?';
    $params[] = (int)$_SESSION['j_id'];
  endif;
  $sql .= ' GROUP BY c.camp_id, c.camp_nom, c.camp_ecran_colonnes ORDER BY c.camp_nom';

  $stmt = $db->prepare($sql);
  $stmt->execute($params);
  return $stmt->fetchAll();
}

// Index de liaison des cellules (tags @, %, #, $, &), chargé une seule fois et
// seulement si un des tableaux en contient — même règle que resoudreTagsTableaux().
function ecranMJIndexLiaison(PDO $db, array $tableaux, int $camp_id, int $ruleset_id): array
{
  foreach ($tableaux as $t):
    if (preg_match('/[@%#$&]/', (string)$t['tab_contenu'])):
      return chargerIndexMonstre($db, $ruleset_id, getActiveResIdsCampagne($db, $camp_id, $ruleset_id));
    endif;
  endforeach;
  return [];
}

// HTML d'un tableau posé sur l'écran. Le titre est porté par la barre de
// l'élément (poignée, repliage, réglages) : rendreTableau() est appelé sans
// tab_nom pour ne pas le répéter dans un <figcaption>.
function rendreElementEcranMJ(array $t, array $index, int $ruleset_id, PDO $db): string
{
  $corps = rendreTableau(array_merge($t, ['tab_nom' => '']), $index, $ruleset_id, $db);
  $largeur = (int)($t['ce_largeur'] ?? 1) === 2 ? 2 : 1;
  $replie  = !empty($t['ce_replie']);

  ob_start(); ?>
  <article class="ecran-mj__item<?= $replie ? ' ecran-mj__item--replie' : '' ?>"
           data-tab-id="<?= (int)$t['tab_id'] ?>"
           data-col="<?= (int)($t['ce_colonne'] ?? 0) ?>"
           data-largeur="<?= $largeur ?>">
    <header class="ecran-mj__item-barre">
      <span class="ecran-mj__poignee" title="Glisser pour déplacer" aria-hidden="true">
        <i class="fa fa-grip-vertical"></i>
      </span>
      <button type="button" class="ecran-mj__item-titre" data-ecran-action="replier"
              aria-expanded="<?= $replie ? 'false' : 'true' ?>"
              title="Replier / déplier">
        <i class="fa fa-chevron-down ecran-mj__chevron" aria-hidden="true"></i>
        <?= h((string)$t['tab_nom']) ?>
      </button>
      <span class="ecran-mj__item-outils">
        <button type="button" class="ecran-mj__item-btn" data-ecran-action="largeur"
                title="Largeur : 1 ou 2 colonnes">
          <span class="ecran-mj__largeur-lib"><?= $largeur ?></span>
          <i class="fa fa-arrows-alt-h" aria-hidden="true"></i>
        </button>
        <button type="button" class="ecran-mj__item-btn" data-ecran-action="retirer"
                title="Retirer de l'écran">
          <i class="fa fa-times" aria-hidden="true"></i>
        </button>
      </span>
    </header>
    <div class="ecran-mj__item-corps"><?= $corps ?></div>
  </article>
  <?php
  return (string)ob_get_clean();
}

// HTML d'une suite de tableaux (fragment injecté par le client).
function rendreElementsEcranMJ(PDO $db, array $tableaux, int $camp_id, int $ruleset_id): string
{
  $index = ecranMJIndexLiaison($db, $tableaux, $camp_id, $ruleset_id);
  $html  = '';
  foreach ($tableaux as $t):
    $html .= rendreElementEcranMJ($t, $index, $ruleset_id, $db);
  endforeach;
  return $html;
}

// Remplace la disposition d'une campagne par celle postée.
// $elements : liste ordonnée de ['tab_id', 'col', 'largeur', 'replie'] — l'ordre
// du tableau est l'ordre global de placement.
// Retourne null si tout va bien, sinon le message d'erreur.
function enregistrerEcranMJ(PDO $db, array $camp, int $nb_colonnes, array $elements): ?string
{
  $camp_id    = (int)$camp['camp_id'];
  $ruleset_id = (int)$camp['camp_ruleset_var_id'];
  $nb_colonnes = ecranMJBornerColonnes($nb_colonnes);

  // Normalisation et dédoublonnage : un tableau ne figure qu'une fois.
  $lignes = [];
  foreach ($elements as $e):
    if (!is_array($e)) return 'Disposition illisible.';
    $tab_id = (int)($e['tab_id'] ?? 0);
    if ($tab_id <= 0 || isset($lignes[$tab_id])) continue;
    $largeur = (int)($e['largeur'] ?? 1) === 2 ? 2 : 1;
    $col     = max(0, min($nb_colonnes - $largeur, (int)($e['col'] ?? 0)));
    $lignes[$tab_id] = [$col, $largeur, !empty($e['replie']) ? 1 : 0];
  endforeach;

  // Tous les tableaux doivent exister dans le ruleset de la campagne.
  if (!empty($lignes)):
    $ids  = array_keys($lignes);
    $ph   = implode(',', array_fill(0, count($ids), '?'));
    $stmt = $db->prepare("
      SELECT COUNT(*) FROM dd_tableaux WHERE tab_id IN ($ph) AND tab_ruleset_var_id = ?
    ");
    $stmt->execute(array_merge($ids, [$ruleset_id]));
    if ((int)$stmt->fetchColumn() !== count($ids)):
      return 'Tableau inconnu ou d\'un autre ruleset — écran non enregistré.';
    endif;
  endif;

  try {
    $db->beginTransaction();
    $db->prepare('UPDATE dd_campagnes SET camp_ecran_colonnes = ? WHERE camp_id = ?')
       ->execute([$nb_colonnes, $camp_id]);
    $db->prepare('DELETE FROM dd_campagnes_ecran WHERE ce_camp_id = ?')->execute([$camp_id]);
    $ins = $db->prepare('
      INSERT INTO dd_campagnes_ecran
        (ce_camp_id, ce_tab_id, ce_colonne, ce_ordre, ce_largeur, ce_replie)
      VALUES (?, ?, ?, ?, ?, ?)
    ');
    $rang = 0;
    foreach ($lignes as $tab_id => [$col, $largeur, $replie]):
      $rang++;
      $ins->execute([$camp_id, $tab_id, $col, $rang, $largeur, $replie]);
    endforeach;
    $db->commit();
  } catch (Exception $e) {
    if ($db->inTransaction()) $db->rollBack();
    error_log('enregistrerEcranMJ : ' . $e->getMessage());
    return 'Erreur base de données.';
  }
  return null;
}
