<?php
// include/ajax/modifier/utilisateur.php
// Retourne le HTML du formulaire de création/modification d'un utilisateur
// Paramètres GET : id (int) — j_id (0 = création)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAdmin();

$id = intParam($_GET['id'] ?? 0);

// Valeurs par défaut (création)
$j = [
  'j_id'                    => 0,
  'j_prenom'                => '',
  'j_nom'                   => '',
  'j_pseudo'                => '',
  'j_email'                 => '',
  'j_admin'                 => 0,
  'j_compendium_manager'    => 0,
  'j_mode_campagne'         => 0,
  'j_items_par_page'        => 20,
  'j_notes'                 => '',
  'j_visible'               => 1,
];

if ($id > 0):
  $stmt = $db->prepare('SELECT * FROM dd_joueurs WHERE j_id = ?');
  $stmt->execute([$id]);
  $row = $stmt->fetch();
  if ($row) $j = $row;
endif;

$titre = $id > 0 ? 'Modifier ' . h($j['j_pseudo']) : 'Nouvel utilisateur';
?>

<div class="modif-form">
  <h3 class="modif-form__title"><?= $titre ?></h3>

  <form id="form-utilisateur" method="POST"
        action="<?= BASE_URL ?>/admin/enregistrement.php?ajax=1">
    <?= csrfField() ?>
    <input type="hidden" name="entite" value="utilisateur">
    <input type="hidden" name="action" value="sauvegarder">
    <input type="hidden" name="j_id"   value="<?= (int)$j['j_id'] ?>">

    <?php // ---- Identité ---- ?>
    <div class="modif-section">
      <div class="modif-grid">

        <div class="form-group">
          <label for="j_prenom">Prénom</label>
          <input type="text" id="j_prenom" name="j_prenom"
                 value="<?= h($j['j_prenom']) ?>" maxlength="50">
        </div>

        <div class="form-group">
          <label for="j_nom">Nom</label>
          <input type="text" id="j_nom" name="j_nom"
                 value="<?= h($j['j_nom']) ?>" maxlength="50">
        </div>

        <div class="form-group">
          <label for="j_pseudo">
            Pseudo <span class="required">*</span>
          </label>
          <input type="text" id="j_pseudo" name="j_pseudo"
                 value="<?= h($j['j_pseudo']) ?>" required maxlength="50"
                 autocomplete="off">
        </div>

        <div class="form-group">
          <label for="j_email">
            Email <span class="required">*</span>
          </label>
          <input type="email" id="j_email" name="j_email"
                 value="<?= h($j['j_email']) ?>" required maxlength="150"
                 autocomplete="off">
        </div>

        <?php // Mot de passe — uniquement à la création ?>
        <?php if ($id === 0): ?>
          <div class="form-group">
            <label for="j_password">
              Mot de passe <span class="required">*</span>
              <span class="form-hint">(min. 8 caractères)</span>
            </label>
            <input type="password" id="j_password" name="j_password"
                   required minlength="8" autocomplete="new-password">
          </div>
        <?php endif ?>

      </div>
    </div>

    <?php // ---- Droits ---- ?>
    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Droits</span>
      </div>
      <div class="modif-checks">
        <label class="modif-check">
          <input type="checkbox" name="j_admin" value="1"
                 <?= (int)$j['j_admin'] ? 'checked' : '' ?>
                 <?= (int)$j['j_id'] === (int)($_SESSION['j_id'] ?? 0) ? 'disabled' : '' ?>>
          Administrateur global
        </label>
        <label class="modif-check">
          <input type="checkbox" name="j_compendium_manager" value="1"
                 <?= (int)$j['j_compendium_manager'] ? 'checked' : '' ?>>
          Gestionnaire compendium
        </label>
      </div>
      <?php if ((int)$j['j_id'] === (int)($_SESSION['j_id'] ?? 0)): ?>
        <p class="form-hint" style="margin-top: var(--sp-sm);">
          <i class="fa fa-info-circle"></i>
          Vous ne pouvez pas modifier vos propres droits d'admin.
        </p>
        <input type="hidden" name="j_admin" value="1">
      <?php endif ?>
    </div>

    <?php // ---- Paramètres ---- ?>
    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Paramètres</span>
      </div>
      <div class="modif-grid">

        <div class="form-group">
          <label for="j_items_par_page">Éléments par page</label>
          <select id="j_items_par_page" name="j_items_par_page">
            <?php foreach ([10, 20, 50, 100] as $n): ?>
              <option value="<?= $n ?>"
                <?= (int)$j['j_items_par_page'] === $n ? 'selected' : '' ?>>
                <?= $n ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <div class="form-group" style="align-self: center;">
          <label class="modif-check">
            <input type="checkbox" name="j_mode_campagne" value="1"
                   <?= (int)$j['j_mode_campagne'] ? 'checked' : '' ?>>
            Mode campagne activé
          </label>
        </div>

      </div>
    </div>

    <?php // ---- Notes admin ---- ?>
    <div class="modif-section">
      <div class="form-group">
        <label for="j_notes">Notes admin</label>
        <textarea id="j_notes" name="j_notes" rows="3"
                  placeholder="Notes internes — non visibles par l'utilisateur"><?= h($j['j_notes'] ?? '') ?></textarea>
      </div>
    </div>

    <div class="modif-actions">
      <button type="button" class="btn btn-primary"
              onclick="soumettreUtilisateur()">
        <i class="fa fa-save"></i> Enregistrer
      </button>
      <button type="button" class="btn btn-secondary"
              onclick="fermerModification()">
        <i class="fa fa-times"></i> Annuler
      </button>
    </div>

  </form>
</div>
