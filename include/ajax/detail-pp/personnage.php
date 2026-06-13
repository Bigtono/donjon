<?php
// include/ajax/detail-pp/personnage.php
// Affichage détaillé synthétique d'un personnage dans un panel #detail-pp.
// Utilisé typiquement depuis le module Campagnes (contexte 'externe').
//
// Paramètres GET ou POST :
//   id (int) — pe_id à afficher
//
// Affiche : identité, caracs+mods, combat, classes. Pas de modification ici
// (l'édition passe par /include/ajax/modifier/personnage.php).

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../personnage_helpers.php';

requireAuth();

$id = intParam($_GET['id'] ?? $_POST['id'] ?? 0);
if (!$id):
  http_response_code(400);
  echo '<p class="erreur">Identifiant manquant.</p>';
  exit;
endif;

$perso = getPersonnageContext($db, $id);
if (!$perso):
  http_response_code(404);
  echo '<p class="erreur">Personnage introuvable ou accès refusé.</p>';
  exit;
endif;

$ruleset_rep = ((int)$perso['pe_ruleset_var_id'] === 2) ? 'DD2024' : 'DD3.5';
$classes     = getPersonnageClasses($db, (int)$perso['pe_id']);
?>

<div class="per-detail">

  <div class="per-detail__header">
    <h2 class="per-detail__nom">
      <?= h($perso['pe_nom']) ?>
      <button class="sort-detail__edit-btn"
              onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/personnage.php', <?= (int)$perso['pe_id'] ?>)"
              title="Modifier ce personnage">
        <i class="fa fa-edit"></i>
      </button>
    </h2>
    <div class="per-detail__meta">
      <span><?= h($perso['ruleset_label']) ?></span>
      <?php if ($perso['campagne_courante_nom']): ?>
        · <i class="fa fa-map"></i> <?= h($perso['campagne_courante_nom']) ?>
      <?php endif ?>
    </div>
  </div>

  <!-- Identité -->
  <div class="per-detail__section">
    <h3 class="per-detail__section-titre">Identité</h3>
    <dl class="per-identite">

      <div class="per-identite__row">
        <dt>Race</dt>
        <dd>
          <?php if (!empty($perso['pe_ra_id'])): ?>
            <a href="javascript:void(0)"
               onclick="actualiserPage('<?= BASE_URL ?>/include/ajax/detail-pp/race.php', {id: <?= (int)$perso['pe_ra_id'] ?>}, 'externe')">
              <?= h($perso['race_nom']) ?>
            </a>
            <?php if ($ruleset_rep === 'DD3.5' && !empty($perso['pe_arc_id'])): ?>
              /
              <a href="javascript:void(0)"
                 onclick="actualiserPage('<?= BASE_URL ?>/include/ajax/detail-pp/race.php', {id: <?= (int)$perso['pe_arc_id'] ?>}, 'externe')">
                <?= h($perso['archetype_nom']) ?>
              </a>
            <?php endif ?>
          <?php else: ?>
            <span class="text-muted">—</span>
          <?php endif ?>
        </dd>
      </div>

      <?php if ($ruleset_rep === 'DD2024' && !empty($perso['pe_hi_id'])): ?>
        <div class="per-identite__row">
          <dt>Historique</dt>
          <dd>
            <a href="javascript:void(0)"
               onclick="actualiserPage('<?= BASE_URL ?>/include/ajax/detail-pp/historique.php', {id: <?= (int)$perso['pe_hi_id'] ?>}, 'externe')">
              <?= h($perso['historique_nom']) ?>
            </a>
          </dd>
        </div>
      <?php endif ?>

      <?php if ($perso['pe_sexe']): ?>
        <div class="per-identite__row">
          <dt>Sexe</dt>
          <dd><?= h($perso['pe_sexe']) ?></dd>
        </div>
      <?php endif ?>

      <?php if (!empty($perso['pe_al_id'])): ?>
        <div class="per-identite__row">
          <dt>Alignement</dt>
          <dd>
            <?= h($perso['alignement_nom']) ?>
            <span class="text-muted">(<?= h($perso['alignement_abr']) ?>)</span>
          </dd>
        </div>
      <?php endif ?>

    </dl>
  </div>

  <!-- Caractéristiques -->
  <div class="per-detail__section">
    <h3 class="per-detail__section-titre">Caractéristiques</h3>
    <div class="per-caracs">
      <?php
        $caracs_def = [
          ['abr' => 'FOR', 'lbl' => 'Force',        'val' => (int)$perso['pe_for']],
          ['abr' => 'CON', 'lbl' => 'Constitution', 'val' => (int)$perso['pe_con']],
          ['abr' => 'DEX', 'lbl' => 'Dextérité',    'val' => (int)$perso['pe_dex']],
          ['abr' => 'INT', 'lbl' => 'Intelligence', 'val' => (int)$perso['pe_int']],
          ['abr' => 'SAG', 'lbl' => 'Sagesse',      'val' => (int)$perso['pe_sag']],
          ['abr' => 'CHA', 'lbl' => 'Charisme',     'val' => (int)$perso['pe_cha']],
        ];
      ?>
      <?php foreach ($caracs_def as $c): ?>
        <div class="per-carac">
          <div class="per-carac__abr" title="<?= h($c['lbl']) ?>"><?= $c['abr'] ?></div>
          <div class="per-carac__val"><?= $c['val'] ?></div>
          <div class="per-carac__mod"><?= formatMod(modCarac($c['val'])) ?></div>
        </div>
      <?php endforeach ?>
    </div>
  </div>

  <!-- Combat -->
  <div class="per-detail__section">
    <h3 class="per-detail__section-titre">Combat</h3>
    <div class="per-combat">
      <div class="per-combat__stat">
        <div class="per-combat__lbl">CA</div>
        <div class="per-combat__val"><?= (int)$perso['pe_ca'] ?></div>
      </div>
      <div class="per-combat__stat">
        <div class="per-combat__lbl">PV</div>
        <div class="per-combat__val"><?= (int)$perso['pe_pv'] ?></div>
      </div>
    </div>
  </div>

  <!-- Classes -->
  <div class="per-detail__section">
    <h3 class="per-detail__section-titre">Classes</h3>
    <?php if (empty($classes)): ?>
      <p class="text-muted">Aucune classe.</p>
    <?php else: ?>
      <ul class="per-classes">
        <?php foreach ($classes as $c): ?>
          <li class="per-classes__item">
            <a href="javascript:void(0)"
               onclick="actualiserPage('<?= BASE_URL ?>/include/ajax/detail-pp/classe.php', {id: <?= (int)$c['pc_cla_id'] ?>}, 'externe')">
              <?= h($c['cla_nom']) ?>
            </a>
            <span class="per-classes__niveau">niveau <?= (int)$c['pc_niveau'] ?></span>
          </li>
        <?php endforeach ?>
      </ul>
    <?php endif ?>
  </div>

  <div class="per-detail__actions">
    <a href="<?= BASE_URL ?>/personnages/fiche.php?id=<?= (int)$perso['pe_id'] ?>" class="btn btn-primary btn-sm">
      <i class="fa fa-external-link"></i> Ouvrir la fiche complète
    </a>
  </div>

</div>
