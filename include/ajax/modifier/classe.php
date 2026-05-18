<?php
// include/ajax/modifier/classe.php
// Retourne le HTML du formulaire de création/modification d'une classe
// Appelé via ouvrirModifier() — pas de layout header/footer
//
// Paramètres GET :
//   id (int) — cla_id de la classe à modifier (0 = création)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAuth();
if (!canEditCompendium()):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

// Capture globale des erreurs PHP pour éviter un rendu tronqué silencieux
set_exception_handler(function(Throwable $e) {
  echo '<p class="erreur"><strong>Erreur serveur :</strong> '
    . htmlspecialchars($e->getMessage(), ENT_QUOTES)
    . ' (ligne ' . $e->getLine() . ')</p>';
});

$id         = intParam($_GET['id'] ?? 0);
$ruleset    = $_SESSION['rulesetRep'] ?? 'DD3.5';
$ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);
$res_ids    = getActiveResIds($db);

// ============================================================
// Valeurs par défaut
// ============================================================

$cla = [
  'cla_id'               => 0,
  'cla_nom'              => '',
  'cla_abreviation'      => '',
  'cla_clt_id'           => 1,
  'cla_dV'               => 8,
  'cla_niveauMax'        => 20,
  'cla_mag_id'           => 0,
  'cla_car_id'           => 0,
  'cla_sort_connu'       => 0,
  'cla_sort_compris'     => 0,
  'cla_sort_prepare'     => 0,
  'cla_domaine_divin'    => 0,
  'cla_pointsCompetences'=> '',
  'cla_po_niveau1'       => '',
  'cla_alignement'       => '',
  'cla_conditions'       => '',
  'cla_description'      => '',
  'cla_armes'            => '',
  'cla_armures'          => '',
  'cla_outils'           => '',
  'cla_sauvegardes'      => '',
  'cla_equipement'       => '',
  'cla_competences'      => '',
  'cla_sorts'            => '',
  'cla_caracteristiques' => '',
  'cla_pouvoir1'         => '',
  'cla_pouvoir2'         => '',
  'cla_pouvoir3'         => '',
  'cla_pouvoir4'         => '',
  'cla_pouvoir5'         => '',
  'cla_res_id'           => 0,
  'cla_camp_id'          => 0,
];

if ($id > 0):
  $stmt = $db->prepare('SELECT * FROM dd_classes WHERE cla_id = ?');
  $stmt->execute([$id]);
  $row = $stmt->fetch();
  // Fusionner avec les valeurs par défaut : les champs NULL en base
  // deviennent '' plutôt que null — évite les erreurs dans h() et (int).
  if ($row) $cla = array_merge($cla, array_map(fn($v) => $v ?? '', $row));
endif;

$niveauMax = max(1, (int)$cla['cla_niveauMax']);

// ============================================================
// Table de progression existante (section 2)
// ============================================================

$niveaux = [];
if ($id > 0):
  $stmt_niv = $db->prepare('SELECT * FROM dd_classe_niveau WHERE cn_cla_id = ? ORDER BY cn_niveau');
  $stmt_niv->execute([$id]);
  while ($row = $stmt_niv->fetch()):
    $niveaux[(int)$row['cn_niveau']] = $row;
  endwhile;
endif;

// Compléter les niveaux manquants avec des valeurs vides
for ($i = 1; $i <= $niveauMax; $i++):
  if (!isset($niveaux[$i])):
    $niveaux[$i] = ['cn_niveau' => $i];
  endif;
  foreach (['cn_bba', 'cn_reflexes', 'cn_vigueur', 'cn_volonte'] as $col):
    if (!isset($niveaux[$i][$col])) $niveaux[$i][$col] = '';
  endforeach;
  for ($s = 0; $s <= 9; $s++):
    if (!isset($niveaux[$i]['cn_sort_n' . $s]))      $niveaux[$i]['cn_sort_n' . $s]      = '';
    if (!isset($niveaux[$i]['cn_sortConnu_n' . $s])) $niveaux[$i]['cn_sortConnu_n' . $s] = '';
  endfor;
  if (!isset($niveaux[$i]['cn_sortPrepare'])) $niveaux[$i]['cn_sortPrepare'] = '';
  for ($p = 1; $p <= 5; $p++):
    if (!isset($niveaux[$i]['cn_pouvoir' . $p])) $niveaux[$i]['cn_pouvoir' . $p] = '';
  endfor;
endfor;
ksort($niveaux);

// Pouvoirs actifs (intitulé non vide)
$activePouvoirs = [];
for ($p = 1; $p <= 5; $p++):
  if (!empty(trim((string)$cla['cla_pouvoir' . $p]))):
    $activePouvoirs[] = $p;
  endif;
endfor;

$isLanceurSorts = (int)$cla['cla_mag_id'] > 0;

// ============================================================
// Capacités spéciales existantes (section 3)
// ============================================================

// Structure : cap_key → { cap_id, cap_nom, cap_description, cap_type, affectations[] }
// affectations[] : [ { cc_niveau, cc_precision } ]
$capacitesInit = [];
if ($id > 0):
  $stmt_cap = $db->prepare('
    SELECT cap.cap_id, cap.cap_nom, cap.cap_description, cap.cap_type,
           cc.cc_niveau, cc.cc_precision
    FROM   dd_classe_capacite cc
    JOIN   dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
    WHERE  cc.cc_cla_id = ?
    ORDER  BY cap.cap_nom, cc.cc_niveau
  ');
  $stmt_cap->execute([$id]);
  $tmpCaps = [];
  while ($row = $stmt_cap->fetch()):
    $capId = (int)$row['cap_id'];
    if (!isset($tmpCaps[$capId])):
      $tmpCaps[$capId] = [
        'cap_key'         => (string)$capId,
        'cap_id'          => $capId,
        'cap_nom'         => $row['cap_nom'],
        'cap_description' => $row['cap_description'] ?? '',
        'cap_type'        => $row['cap_type'] ?? '',
        'affectations'    => [],
      ];
    endif;
    $tmpCaps[$capId]['affectations'][] = [
      'cc_niveau'    => (int)$row['cc_niveau'],
      'cc_precision' => $row['cc_precision'] ?? '',
    ];
  endwhile;
  $capacitesInit = array_values($tmpCaps);
endif;

// ============================================================
// Listes de référence
// ============================================================

$stmt_clt = $db->prepare('SELECT clt_id, clt_nom FROM dd_classe_type WHERE clt_ruleset_var_id = ? ORDER BY clt_nom');
$stmt_clt->execute([$ruleset_id]);
$types_classe = $stmt_clt->fetchAll();

$stmt_mag = $db->prepare('SELECT mag_id, mag_nom FROM dd_typemagie WHERE mag_ruleset_var_id = ? ORDER BY mag_nom');
$stmt_mag->execute([$ruleset_id]);
$types_magie = $stmt_mag->fetchAll();

$caracteristiques = $db->query('SELECT car_id, car_nom FROM dd_caracteristiques ORDER BY car_id')->fetchAll();

$sources = [];
if (!empty($res_ids)):
  $ph   = resIdsPlaceholders($res_ids);
  $stmt = $db->prepare("SELECT res_id, res_nom FROM dd_ressources WHERE res_id IN ($ph) ORDER BY res_nom");
  $stmt->execute($res_ids);
  $sources = $stmt->fetchAll();
endif;

$campagnes = [];
if (!empty($_SESSION['j_mode_campagne'])):
  [$owWhere, $owParams] = ownerFilter('camp');
  $stmt = $db->prepare("SELECT camp_id, camp_nom FROM dd_campagnes WHERE $owWhere ORDER BY camp_nom");
  $stmt->execute($owParams);
  $campagnes = $stmt->fetchAll();
endif;

$titre = $id > 0 ? 'Modifier ' . h($cla['cla_nom']) : 'Nouvelle classe';

$isPrestige = ((int)$cla['cla_clt_id'] === 2);
?>

<div class="modif-form">
  <h3 class="modif-form__title"><?= $titre ?></h3>

  <form id="form-classe" method="POST" action="<?= BASE_URL ?>/compendium/enregistrement.php?ajax=1">
    <?= csrfField() ?>
    <input type="hidden" name="entite"             value="classe">
    <input type="hidden" name="action"             value="sauvegarder">
    <input type="hidden" name="cla_id"             value="<?= (int)$cla['cla_id'] ?>">
    <input type="hidden" name="cla_ruleset_var_id" value="<?= $ruleset_id ?>">
    <input type="hidden" id="capacites_payload"    name="capacites_payload"    value="[]">
    <input type="hidden" id="affectations_payload" name="affectations_payload" value="[]">
    <input type="hidden" id="payload_ready"        name="payload_ready"        value="0">

    <!-- ====================================================
         SECTION 1 — Données de base
         ==================================================== -->
    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Section 1 — Données de base</span>
      </div>

      <div class="modif-grid">

        <div class="form-group modif-grid__full">
          <label for="cla_nom">Nom <span class="required">*</span></label>
          <input type="text" id="cla_nom" name="cla_nom"
                 value="<?= h($cla['cla_nom']) ?>" required maxlength="100">
        </div>

        <div class="form-group">
          <label for="cla_abreviation">Abréviation</label>
          <input type="text" id="cla_abreviation" name="cla_abreviation"
                 value="<?= h($cla['cla_abreviation']) ?>" maxlength="20" style="width:100px;">
        </div>

        <div class="form-group">
          <label for="cla_clt_id">Type de classe</label>
          <select id="cla_clt_id" name="cla_clt_id">
            <?php foreach ($types_classe as $clt): ?>
              <option value="<?= (int)$clt['clt_id'] ?>"
                <?= (int)$cla['cla_clt_id'] === (int)$clt['clt_id'] ? 'selected' : '' ?>>
                <?= h($clt['clt_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <div class="form-group">
          <label for="cla_dV">Dé de vie</label>
          <select id="cla_dV" name="cla_dV">
            <?php foreach ([4, 6, 8, 10, 12] as $dv): ?>
              <option value="<?= $dv ?>" <?= (int)$cla['cla_dV'] === $dv ? 'selected' : '' ?>>
                d<?= $dv ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <div class="form-group">
          <label for="cla_niveauMax">Niveaux max</label>
          <select id="cla_niveauMax" name="cla_niveauMax">
            <?php foreach ([3, 5, 10, 20] as $nmax): ?>
              <option value="<?= $nmax ?>" <?= $niveauMax === $nmax ? 'selected' : '' ?>>
                <?= $nmax ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <div class="form-group">
          <label for="cla_mag_id">Type de magie</label>
          <select id="cla_mag_id" name="cla_mag_id">
            <option value="0">— Aucune —</option>
            <?php foreach ($types_magie as $mag): ?>
              <option value="<?= (int)$mag['mag_id'] ?>"
                <?= (int)$cla['cla_mag_id'] === (int)$mag['mag_id'] ? 'selected' : '' ?>>
                <?= h($mag['mag_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <div class="form-group">
          <label for="cla_car_id">Caractéristique LS</label>
          <select id="cla_car_id" name="cla_car_id">
            <option value="0">— Aucune —</option>
            <?php foreach ($caracteristiques as $car): ?>
              <option value="<?= (int)$car['car_id'] ?>"
                <?= (int)$cla['cla_car_id'] === (int)$car['car_id'] ? 'selected' : '' ?>>
                <?= h($car['car_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <div class="form-group">
          <label for="cla_res_id">Source <span class="required">*</span></label>
          <select id="cla_res_id" name="cla_res_id" required>
            <option value="">— Choisir —</option>
            <?php foreach ($sources as $src): ?>
              <option value="<?= (int)$src['res_id'] ?>"
                <?= (int)$cla['cla_res_id'] === (int)$src['res_id'] ? 'selected' : '' ?>>
                <?= h($src['res_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <?php if (!empty($campagnes)): ?>
          <div class="form-group">
            <label for="cla_camp_id">Campagne (homebrew)</label>
            <select id="cla_camp_id" name="cla_camp_id">
              <option value="">— Compendium global —</option>
              <?php foreach ($campagnes as $camp): ?>
                <option value="<?= (int)$camp['camp_id'] ?>"
                  <?= (int)$cla['cla_camp_id'] === (int)$camp['camp_id'] ? 'selected' : '' ?>>
                  <?= h($camp['camp_nom']) ?>
                </option>
              <?php endforeach ?>
            </select>
          </div>
        <?php endif ?>

      </div><!-- .modif-grid -->

      <?php // ---- Intitulés des pouvoirs 1-5 ?>
      <div class="modif-grid" style="margin-top:.5rem;">
        <?php for ($p = 1; $p <= 5; $p++): ?>
          <div class="form-group">
            <label for="cla_pouvoir<?= $p ?>">Pouvoir <?= $p ?> (intitulé colonne)</label>
            <input type="text" id="cla_pouvoir<?= $p ?>" name="cla_pouvoir<?= $p ?>"
                   value="<?= h((string)($cla['cla_pouvoir' . $p] ?? '')) ?>" maxlength="100"
                   placeholder="Laisser vide si inutilisé">
          </div>
        <?php endfor ?>
      </div>

      <div class="form-group" style="margin-top:.5rem;">
        <label for="cla_description">Description</label>
        <textarea id="cla_description" name="cla_description"
                  class="tinymce-basic"><?= $cla['cla_description'] ?? '' ?></textarea>
      </div>

    </div><!-- .modif-section S1 -->

    <!-- ====================================================
         SECTION 1b — DD3.5 uniquement
         ==================================================== -->
    <?php if ($ruleset === 'DD3.5'): ?>
    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Données DD3.5</span>
      </div>

      <div class="modif-grid">

        <div class="form-group">
          <label for="cla_pointsCompetences">Points de compétences / niveau</label>
          <input type="number" id="cla_pointsCompetences" name="cla_pointsCompetences"
                 value="<?= (int)$cla['cla_pointsCompetences'] ?>" min="0" max="20"
                 style="width:80px;">
        </div>

        <div class="form-group">
          <label for="cla_po_niveau1">Or de départ (pièces)</label>
          <input type="number" id="cla_po_niveau1" name="cla_po_niveau1"
                 value="<?= (int)$cla['cla_po_niveau1'] ?>" min="0"
                 style="width:100px;">
        </div>

        <div class="form-group">
          <label for="cla_alignement">Alignement autorisé</label>
          <input type="text" id="cla_alignement" name="cla_alignement"
                 value="<?= h($cla['cla_alignement']) ?>" maxlength="100">
        </div>

      </div>

      <div class="modif-grid" style="margin-top:.25rem;">

        <div class="form-group">
          <label>
            <input type="checkbox" name="cla_domaine_divin" value="1"
                   <?= $cla['cla_domaine_divin'] ? 'checked' : '' ?>>
            Domaines divins
          </label>
        </div>

        <div class="form-group">
          <label>
            <input type="checkbox" id="cla_sort_connu" name="cla_sort_connu" value="1"
                   <?= $cla['cla_sort_connu'] ? 'checked' : '' ?>>
            Sorts connus
          </label>
        </div>

        <div class="form-group">
          <label>
            <input type="checkbox" name="cla_sort_compris" value="1"
                   <?= $cla['cla_sort_compris'] ? 'checked' : '' ?>>
            Sorts compris (grimoire)
          </label>
        </div>

        <div class="form-group">
          <label>
            <input type="checkbox" name="cla_sort_prepare" value="1"
                   <?= $cla['cla_sort_prepare'] ? 'checked' : '' ?>>
            Préparation des sorts
          </label>
        </div>

      </div>

      <div class="form-group" style="margin-top:.5rem;">
        <label for="cla_armes">Armes &amp; armures</label>
        <textarea id="cla_armes" name="cla_armes"
                  class="tinymce-basic"><?= $cla['cla_armes'] ?? '' ?></textarea>
      </div>

      <div class="form-group">
        <label for="cla_sorts">Sorts (description de la liste)</label>
        <textarea id="cla_sorts" name="cla_sorts"
                  class="tinymce-basic"><?= $cla['cla_sorts'] ?? '' ?></textarea>
      </div>

      <?php if ($isPrestige): ?>
        <div class="form-group">
          <label for="cla_conditions">Conditions d'accès (prestige)</label>
          <textarea id="cla_conditions" name="cla_conditions"
                    class="tinymce-basic"><?= $cla['cla_conditions'] ?? '' ?></textarea>
        </div>
      <?php else: ?>
        <input type="hidden" name="cla_conditions" value="">
      <?php endif ?>

    </div><!-- .modif-section DD3.5 -->

    <?php elseif ($ruleset === 'DD2024'): ?>

    <!-- ====================================================
         SECTION 1b — DD2024 uniquement
         ==================================================== -->
    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Données DD2024</span>
      </div>

      <div class="form-group">
        <label for="cla_caracteristiques">Caractéristiques principales</label>
        <textarea id="cla_caracteristiques" name="cla_caracteristiques"
                  rows="2"><?= h($cla['cla_caracteristiques'] ?? '') ?></textarea>
      </div>

      <div class="form-group">
        <label for="cla_sauvegardes">Jets de sauvegarde maîtrisés</label>
        <textarea id="cla_sauvegardes" name="cla_sauvegardes"
                  rows="2"><?= h($cla['cla_sauvegardes'] ?? '') ?></textarea>
      </div>

      <div class="form-group">
        <label for="cla_armes">Maîtrise d'armes</label>
        <textarea id="cla_armes" name="cla_armes"
                  rows="3"><?= h($cla['cla_armes'] ?? '') ?></textarea>
      </div>

      <div class="form-group">
        <label for="cla_armures">Formation aux armures</label>
        <textarea id="cla_armures" name="cla_armures"
                  rows="3"><?= h($cla['cla_armures'] ?? '') ?></textarea>
      </div>

      <div class="form-group">
        <label for="cla_outils">Maîtrise d'outils</label>
        <textarea id="cla_outils" name="cla_outils"
                  rows="2"><?= h($cla['cla_outils'] ?? '') ?></textarea>
      </div>

      <div class="form-group">
        <label for="cla_equipement">Équipement de départ</label>
        <textarea id="cla_equipement" name="cla_equipement"
                  rows="3"><?= h($cla['cla_equipement'] ?? '') ?></textarea>
      </div>

    </div><!-- .modif-section DD2024 -->

    <?php endif ?>

    <!-- ====================================================
         SECTION 2 — Table de progression
         ==================================================== -->
    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Section 2 — Table de progression</span>
      </div>

      <?php if ($id === 0): ?>
        <p class="form-hint">
          Enregistrez d'abord la classe (Section 1) pour saisir la table de progression.
        </p>
      <?php else: ?>

        <div class="table-scroll">
          <table class="table-classe-modif">
            <thead>
              <tr>
                <th class="col-niveau">Niv.</th>
                <?php if ($ruleset === 'DD3.5'): ?>
                  <th class="col-stat">BBA</th>
                  <th class="col-stat">Réf.</th>
                  <th class="col-stat">Vig.</th>
                  <th class="col-stat">Vol.</th>
                <?php endif ?>
                <?php foreach ($activePouvoirs as $p): ?>
                  <th class="col-pouvoir"><?= h((string)($cla['cla_pouvoir' . $p] ?? '')) ?></th>
                <?php endforeach ?>
                <?php if ($isLanceurSorts): ?>
                  <?php if ($ruleset === 'DD2024'): ?>
                    <th class="col-sort" title="Sorts mineurs (niveau 0)">Min.</th>
                    <th class="col-sort" title="Sorts préparés">Prép.</th>
                    <?php for ($s = 1; $s <= 9; $s++): ?>
                      <th class="col-sort">N<?= $s ?></th>
                    <?php endfor ?>
                  <?php else: ?>
                    <?php for ($s = 0; $s <= 9; $s++): ?>
                      <th class="col-sort">S<?= $s ?></th>
                    <?php endfor ?>
                    <?php if ($cla['cla_sort_connu']): ?>
                      <?php for ($s = 0; $s <= 9; $s++): ?>
                        <th class="col-sort">C<?= $s ?></th>
                      <?php endfor ?>
                    <?php endif ?>
                  <?php endif ?>
                <?php endif ?>
              </tr>
            </thead>
            <tbody>
              <?php foreach ($niveaux as $niv => $row): ?>
                <tr>
                  <td class="col-niveau">
                    <?= $niv ?>
                    <input type="hidden" name="niveaux[<?= $niv ?>][cn_niveau]" value="<?= $niv ?>">
                  </td>
                  <?php if ($ruleset === 'DD3.5'): ?>
                    <td>
                      <input type="text" class="col-stat"
                             name="niveaux[<?= $niv ?>][cn_bba]"
                             value="<?= h($row['cn_bba']) ?>">
                    </td>
                    <td>
                      <input type="text" class="col-stat"
                             name="niveaux[<?= $niv ?>][cn_reflexes]"
                             value="<?= h($row['cn_reflexes']) ?>">
                    </td>
                    <td>
                      <input type="text" class="col-stat"
                             name="niveaux[<?= $niv ?>][cn_vigueur]"
                             value="<?= h($row['cn_vigueur']) ?>">
                    </td>
                    <td>
                      <input type="text" class="col-stat"
                             name="niveaux[<?= $niv ?>][cn_volonte]"
                             value="<?= h($row['cn_volonte']) ?>">
                    </td>
                  <?php endif ?>
                  <?php foreach ($activePouvoirs as $p): ?>
                    <td>
                      <input type="text" class="col-pouvoir"
                             name="niveaux[<?= $niv ?>][cn_pouvoir<?= $p ?>]"
                             value="<?= h((string)($row['cn_pouvoir' . $p] ?? '')) ?>">
                    </td>
                  <?php endforeach ?>
                  <?php if ($isLanceurSorts): ?>
                    <?php if ($ruleset === 'DD2024'): ?>
                      <td>
                        <input type="text" class="col-sort"
                               name="niveaux[<?= $niv ?>][cn_sort_n0]"
                               value="<?= h((string)($row['cn_sort_n0'] ?? '')) ?>">
                      </td>
                      <td>
                        <input type="text" class="col-sort"
                               name="niveaux[<?= $niv ?>][cn_sortPrepare]"
                               value="<?= h((string)($row['cn_sortPrepare'] ?? '')) ?>">
                      </td>
                      <?php for ($s = 1; $s <= 9; $s++): ?>
                        <td>
                          <input type="text" class="col-sort"
                                 name="niveaux[<?= $niv ?>][cn_sort_n<?= $s ?>]"
                                 value="<?= h((string)($row['cn_sort_n' . $s] ?? '')) ?>">
                        </td>
                      <?php endfor ?>
                    <?php else: ?>
                      <?php for ($s = 0; $s <= 9; $s++): ?>
                        <td>
                          <input type="text" class="col-sort"
                                 name="niveaux[<?= $niv ?>][cn_sort_n<?= $s ?>]"
                                 value="<?= h((string)($row['cn_sort_n' . $s] ?? '')) ?>">
                        </td>
                      <?php endfor ?>
                      <?php if ($cla['cla_sort_connu']): ?>
                        <?php for ($s = 0; $s <= 9; $s++): ?>
                          <td>
                            <input type="text" class="col-sort"
                                   name="niveaux[<?= $niv ?>][cn_sortConnu_n<?= $s ?>]"
                                   value="<?= h((string)($row['cn_sortConnu_n' . $s] ?? '')) ?>">
                          </td>
                        <?php endfor ?>
                      <?php endif ?>
                    <?php endif ?>
                  <?php endif ?>
                </tr>
              <?php endforeach ?>
            </tbody>
          </table>
        </div>

      <?php endif ?>
    </div><!-- .modif-section S2 -->

    <!-- ====================================================
         SECTION 3 — Capacités spéciales
         ==================================================== -->
    <div class="modif-section">
      <div class="modif-section__header"
           style="display:flex; justify-content:space-between; align-items:center;">
        <span class="modif-section__label">Section 3 — Capacités spéciales</span>
        <?php if ($id > 0): ?>
          <button type="button" class="btn btn-secondary btn-sm"
                  onclick="classeForm.nouvelleCapacite()">
            <i class="fa fa-plus"></i> Nouvelle capacité
          </button>
        <?php endif ?>
      </div>

      <?php if ($id === 0): ?>
        <p class="form-hint">
          Enregistrez d'abord la classe avant d'ajouter des capacités spéciales.
        </p>
      <?php else: ?>
        <div class="table-scroll">
          <table class="table-classe-modif" id="classe-cap-table">
            <thead>
              <tr>
                <th style="width:60px;">Niveau(x)</th>
                <th>Nom</th>
                <th style="width:60px;">Type</th>
                <th>Description</th>
                <th style="width:80px;">Actions</th>
              </tr>
            </thead>
            <tbody id="classe-cap-tbody"></tbody>
          </table>
        </div>
      <?php endif ?>
    </div><!-- .modif-section S3 -->

    <!-- ====================================================
         BOUTONS
         ==================================================== -->
    <div class="modif-actions">
      <button type="button" class="btn btn-primary" onclick="classeForm.soumettre()">
        <i class="fa fa-save"></i> Enregistrer
      </button>
      <button type="button" class="btn btn-secondary" onclick="fermerModification()">
        <i class="fa fa-times"></i> Annuler
      </button>
    </div>

  </form>
</div>

<!-- ====================================================
     OVERLAY — Formulaire capacité (nouvelle / modifier)
     ==================================================== -->
<div id="classe-cap-overlay"
     style="display:none; position:fixed; inset:0; background:rgba(0,0,0,.5); z-index:1100;">
  <div style="max-width:640px; margin:50px auto; background:var(--clr-surface,#fff);
              border-radius:6px; padding:20px; max-height:calc(100vh - 100px); overflow:auto;">

    <h4 id="classe-cap-titre" style="margin-top:0;">Capacité spéciale</h4>

    <div class="form-group">
      <label for="ov_cap_nom">Nom <span class="required">*</span></label>
      <input type="text" id="ov_cap_nom" maxlength="150" style="width:100%;">
    </div>

    <div class="form-group">
      <label for="ov_cap_type">Type</label>
      <input type="text" id="ov_cap_type" maxlength="50"
             placeholder="Ext, Mag, Sur…" style="width:140px;">
    </div>

    <div class="form-group">
      <label for="ov_cap_description">Description</label>
      <textarea id="ov_cap_description" rows="5" style="width:100%;"></textarea>
    </div>

    <!-- Affectations niveau / précision -->
    <div style="margin-top:.75rem;">
      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:.4rem;">
        <strong>Affectations par niveau</strong>
        <button type="button" class="btn btn-sm btn-secondary"
                onclick="classeForm.ajouterAffectation()">
          <i class="fa fa-plus"></i> Ajouter
        </button>
      </div>
      <table style="width:100%; border-collapse:collapse; font-size:.9rem;">
        <thead>
          <tr>
            <th style="text-align:left; padding:2px 6px; border-bottom:1px solid #ccc;">Niveau</th>
            <th style="text-align:left; padding:2px 6px; border-bottom:1px solid #ccc;">Précision</th>
            <th style="width:32px;"></th>
          </tr>
        </thead>
        <tbody id="ov-affect-tbody"></tbody>
      </table>
      <p id="ov-affect-vide" class="form-hint" style="display:none;">
        Aucune affectation. La capacité sera présente dans la liste mais n'apparaîtra
        dans aucun niveau du tableau.
      </p>
    </div>

    <div style="display:flex; gap:.5rem; margin-top:1rem;">
      <button type="button" class="btn btn-primary" onclick="classeForm.validerCapacite()">
        <i class="fa fa-check"></i> Valider
      </button>
      <button type="button" class="btn btn-secondary" onclick="classeForm.fermerOverlay()">
        Annuler
      </button>
    </div>
  </div>
</div>

<!-- TinyMCE -->
<script src="https://cdn.jsdelivr.net/npm/tinymce@6/tinymce.min.js"></script>
<script>
// ============================================================
// IIFE — isolation du scope (évite les conflits à la réouverture)
// ============================================================
(function() {
  'use strict';

  const CLASSE_ID  = <?= $id ?>;
  const NIVEAU_MAX = <?= $niveauMax ?>;

  // ---- État des capacités spéciales ----
  // Structure : { cap_key, cap_id, cap_nom, cap_description, cap_type, affectations[] }
  // affectations[] : { cc_niveau, cc_precision }
  let state      = <?= json_encode($capacitesInit, JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_AMP | JSON_HEX_QUOT) ?>;
  let nextTempId = -1;
  let overlayKey = null;  // cap_key de la capacité en cours d'édition (null = nouvelle)

  // ---- TinyMCE init ----
  (function initTMCE() {
    if (typeof tinymce === 'undefined') { setTimeout(initTMCE, 100); return; }
    tinymce.remove('.tinymce-basic');
    tinymce.init({
      selector:      '.tinymce-basic',
      language:      'fr_FR',
      menubar:       false,
      plugins:       'lists link',
      toolbar:       'bold italic underline | bullist numlist | h2 h3 | link | removeformat',
      height:        220,
      skin:          'oxide',
      content_css:   'default',
      content_style: 'body { background: #eae6dd; color: #1a1a1a; font-family: Segoe UI, system-ui, sans-serif; font-size: 14px; margin: 8px; }',
      promotion:     false,
      branding:      false,
      base_url:      'https://cdn.jsdelivr.net/npm/tinymce@6',
      suffix:        '.min',
    });
  })();

  // ============================================================
  // Utilitaires
  // ============================================================

  function esc(str) {
    return String(str)
      .replace(/&/g,'&amp;').replace(/</g,'&lt;')
      .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
  }

  function tmceGet(id) {
    if (typeof tinymce !== 'undefined') {
      const ed = tinymce.get(id);
      if (ed && ed.initialized) return ed.getContent();
    }
    const el = document.getElementById(id);
    return el ? el.value : '';
  }

  function findByKey(key) {
    return state.find(c => c.cap_key === key) || null;
  }

  // ============================================================
  // Rendu du tableau des capacités (section 3)
  // ============================================================

  function rendreTableau() {
    const tbody = document.getElementById('classe-cap-tbody');
    if (!tbody) return;
    tbody.innerHTML = '';

    state.forEach(function(cap) {
      const niveaux = (cap.affectations || [])
        .map(a => a.cc_niveau + (a.cc_precision ? ' (' + esc(a.cc_precision) + ')' : ''))
        .join(', ') || '—';

      const tr = document.createElement('tr');
      tr.innerHTML =
        '<td style="font-size:.85rem;">' + esc(niveaux) + '</td>' +
        '<td>' + esc(cap.cap_nom) + '</td>' +
        '<td>' + esc(cap.cap_type || '') + '</td>' +
        '<td><em style="color:#888; font-size:.85em;">' +
          (cap.cap_description ? '(contenu)' : '—') +
        '</em></td>' +
        '<td style="white-space:nowrap;">' +
          '<button type="button" class="btn btn-sm"' +
            ' onclick="classeForm.editerCapacite(\'' + cap.cap_key + '\')"' +
            ' title="Modifier"><i class="fa fa-pencil"></i></button> ' +
          '<button type="button" class="btn btn-sm btn-danger"' +
            ' onclick="classeForm.supprimerCapacite(\'' + cap.cap_key + '\')"' +
            ' title="Supprimer"><i class="fa fa-trash"></i></button>' +
        '</td>';
      tbody.appendChild(tr);
    });
  }

  // ============================================================
  // Overlay — Affectations
  // ============================================================

  function rendreAffectations(affectations) {
    const tbody  = document.getElementById('ov-affect-tbody');
    const vide   = document.getElementById('ov-affect-vide');
    if (!tbody) return;
    tbody.innerHTML = '';

    if (!affectations || !affectations.length) {
      if (vide) vide.style.display = '';
      return;
    }
    if (vide) vide.style.display = 'none';

    affectations.forEach(function(a, idx) {
      const tr = document.createElement('tr');
      tr.innerHTML =
        '<td style="padding:2px 4px;">' +
          '<input type="number" min="1" max="' + NIVEAU_MAX + '" value="' + (int(a.cc_niveau) || 1) + '"' +
          ' style="width:54px;" data-affect-niveau data-idx="' + idx + '">' +
        '</td>' +
        '<td style="padding:2px 4px;">' +
          '<input type="text" value="' + esc(a.cc_precision || '') + '"' +
          ' style="width:100%;" placeholder="ex: 3/jour" data-affect-precision data-idx="' + idx + '">' +
        '</td>' +
        '<td style="padding:2px 4px; text-align:center;">' +
          '<button type="button" class="btn btn-sm btn-danger"' +
            ' onclick="classeForm.supprimerAffectation(' + idx + ')">' +
            '<i class="fa fa-trash"></i>' +
          '</button>' +
        '</td>';
      tbody.appendChild(tr);
    });
  }

  function int(v) { return parseInt(v, 10) || 0; }

  function lireAffectations() {
    const rows = document.querySelectorAll('#ov-affect-tbody tr');
    const result = [];
    rows.forEach(function(row) {
      const niv  = int(row.querySelector('[data-affect-niveau]')?.value);
      const prec = row.querySelector('[data-affect-precision]')?.value || '';
      if (niv >= 1 && niv <= NIVEAU_MAX) {
        result.push({ cc_niveau: niv, cc_precision: prec });
      }
    });
    // Dédoublonner et trier
    const seen = {};
    return result.filter(function(a) {
      const sig = a.cc_niveau + '|' + a.cc_precision;
      if (seen[sig]) return false;
      seen[sig] = true;
      return true;
    }).sort((a, b) => a.cc_niveau - b.cc_niveau || a.cc_precision.localeCompare(b.cc_precision));
  }

  function ajouterAffectation() {
    const tbody = document.getElementById('ov-affect-tbody');
    const vide  = document.getElementById('ov-affect-vide');
    if (vide) vide.style.display = 'none';
    const idx   = tbody ? tbody.querySelectorAll('tr').length : 0;
    const tr    = document.createElement('tr');
    tr.innerHTML =
      '<td style="padding:2px 4px;">' +
        '<input type="number" min="1" max="' + NIVEAU_MAX + '" value="1"' +
        ' style="width:54px;" data-affect-niveau data-idx="' + idx + '">' +
      '</td>' +
      '<td style="padding:2px 4px;">' +
        '<input type="text" style="width:100%;" placeholder="ex: 3/jour"' +
        ' data-affect-precision data-idx="' + idx + '">' +
      '</td>' +
      '<td style="padding:2px 4px; text-align:center;">' +
        '<button type="button" class="btn btn-sm btn-danger"' +
          ' onclick="classeForm.supprimerAffectation(' + idx + ')">' +
          '<i class="fa fa-trash"></i>' +
        '</button>' +
      '</td>';
    if (tbody) tbody.appendChild(tr);
  }

  function supprimerAffectation(idx) {
    const tbody = document.getElementById('ov-affect-tbody');
    if (!tbody) return;
    const rows = tbody.querySelectorAll('tr');
    if (rows[idx]) rows[idx].remove();
    const vide = document.getElementById('ov-affect-vide');
    if (vide) vide.style.display = tbody.querySelectorAll('tr').length ? 'none' : '';
  }

  // ============================================================
  // Overlay — Ouvrir / fermer
  // ============================================================

  function ouvrirOverlay(titre, cap) {
    document.getElementById('classe-cap-titre').textContent = titre;
    document.getElementById('ov_cap_nom').value  = cap.cap_nom  || '';
    document.getElementById('ov_cap_type').value = cap.cap_type || '';

    // TinyMCE overlay : destroy + reinit propre
    if (typeof tinymce !== 'undefined') {
      const ed = tinymce.get('ov_cap_description');
      if (ed) ed.destroy();
    }
    const desc = cap.cap_description || '';
    document.getElementById('ov_cap_description').value = desc;

    rendreAffectations(cap.affectations || []);

    document.getElementById('classe-cap-overlay').style.display = 'block';

    setTimeout(function() {
      if (typeof tinymce !== 'undefined') {
        tinymce.init({
          selector:    '#ov_cap_description',
          language:    'fr_FR',
          menubar:     false,
          plugins:     'lists link',
          toolbar:     'bold italic underline | bullist numlist | link | removeformat',
          height:      180,
          skin:        'oxide-dark',
          content_css: 'dark',
          promotion:   false,
          branding:    false,
          base_url:    'https://cdn.jsdelivr.net/npm/tinymce@6',
          suffix:      '.min',
          setup: function(ed) {
            ed.on('init', function() { ed.setContent(desc); });
          },
        });
      }
      document.getElementById('ov_cap_nom').focus();
    }, 50);
  }

  function nouvelleCapacite() {
    overlayKey = null;
    ouvrirOverlay('Nouvelle capacité spéciale', {
      cap_nom: '', cap_type: '', cap_description: '', affectations: [],
    });
  }

  function editerCapacite(key) {
    overlayKey = key;
    const cap = findByKey(key);
    if (!cap) return;
    ouvrirOverlay('Modifier la capacité', cap);
  }

  function fermerOverlay() {
    if (typeof tinymce !== 'undefined') {
      const ed = tinymce.get('ov_cap_description');
      if (ed) ed.destroy();
    }
    document.getElementById('classe-cap-overlay').style.display = 'none';
  }

  function validerCapacite() {
    const nom = document.getElementById('ov_cap_nom').value.trim();
    if (!nom) { alert('Le nom de la capacité est obligatoire.'); return; }

    let desc = '';
    const ed = (typeof tinymce !== 'undefined') ? tinymce.get('ov_cap_description') : null;
    desc = (ed && ed.initialized) ? ed.getContent() : document.getElementById('ov_cap_description').value;

    const type   = document.getElementById('ov_cap_type').value.trim();
    const affects = lireAffectations();

    if (overlayKey === null) {
      // Nouvelle capacité
      const newKey = String(nextTempId--);
      state.push({
        cap_key:         newKey,
        cap_id:          0,
        cap_nom:         nom,
        cap_description: desc,
        cap_type:        type,
        affectations:    affects,
      });
    } else {
      // Modification existante
      const cap = findByKey(overlayKey);
      if (cap) {
        cap.cap_nom         = nom;
        cap.cap_description = desc;
        cap.cap_type        = type;
        cap.affectations    = affects;
      }
    }

    fermerOverlay();
    rendreTableau();
  }

  function supprimerCapacite(key) {
    const cap = findByKey(key);
    if (!cap) return;
    if (!confirm('Supprimer la capacité "' + cap.cap_nom + '" de cette classe ?')) return;
    state = state.filter(c => c.cap_key !== key);
    rendreTableau();
  }

  // ============================================================
  // Sérialisation des payloads
  // ============================================================

  function serializerPayloads() {
    const caps    = [];
    const affects = [];

    state.forEach(function(cap) {
      caps.push({
        cap_key:         cap.cap_key,
        cap_id:          cap.cap_id || 0,
        cap_nom:         cap.cap_nom,
        cap_description: cap.cap_description || '',
        cap_type:        cap.cap_type || '',
      });
      (cap.affectations || []).forEach(function(a) {
        affects.push({
          cap_key:      cap.cap_key,
          cc_niveau:    a.cc_niveau,
          cc_precision: a.cc_precision || '',
        });
      });
    });

    document.getElementById('capacites_payload').value    = JSON.stringify(caps);
    document.getElementById('affectations_payload').value = JSON.stringify(affects);
    document.getElementById('payload_ready').value        = '1';
  }

  // ============================================================
  // Soumission
  // ============================================================

  function soumettre() {
    const form = document.getElementById('form-classe');
    if (!form) return;

    // Synchroniser tous les TinyMCE du formulaire principal
    if (typeof tinymce !== 'undefined') {
      document.querySelectorAll('.tinymce-basic').forEach(function(el) {
        const ed = tinymce.get(el.id);
        if (ed && ed.initialized) el.value = ed.getContent();
      });
    }

    serializerPayloads();

    fetch(form.getAttribute('action'), {
      method: 'POST',
      body:   new FormData(form),
    })
    .then(r => r.json())
    .then(data => {
      if (data.ok) {
        apresModification(data);
      } else {
        alert(data.erreur || "Erreur lors de l'enregistrement.");
      }
    })
    .catch(err => alert('Erreur : ' + err));
  }

  // ============================================================
  // Exposition sur window
  // ============================================================

  window.classeForm = {
    nouvelleCapacite:    nouvelleCapacite,
    editerCapacite:      editerCapacite,
    fermerOverlay:       fermerOverlay,
    validerCapacite:     validerCapacite,
    supprimerCapacite:   supprimerCapacite,
    ajouterAffectation:  ajouterAffectation,
    supprimerAffectation: supprimerAffectation,
    soumettre:           soumettre,
  };

  // ============================================================
  // Initialisation — appel direct (pas de DOMContentLoaded)
  // ============================================================

  if (CLASSE_ID > 0) rendreTableau();

})(); // fin IIFE
</script>
