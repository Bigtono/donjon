<?
// profil/index.php — Profil utilisateur
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAuth();

$j_id   = (int)$_SESSION['j_id'];
$errors = [];
$ok     = false;

// Chargement des données actuelles
$stmt = $db->prepare('
  SELECT j_id, j_prenom, j_nom, j_pseudo, j_email,
         j_default_ruleset_var_id, j_mode_campagne,
         j_affichage_ruleset, j_items_par_page, j_theme
  FROM   dd_joueurs
  WHERE  j_id = ?
');
$stmt->execute([$j_id]);
$joueur = $stmt->fetch();

// Chargement des rulesets disponibles
$rulesets = $db->query('
  SELECT var_id, var_valeur
  FROM   dd_variables
  WHERE  var_cat = \'ruleset\'
  ORDER  BY var_ordre
')->fetchAll();

// Ruleset actif en session
$ruleset_var_id_actif = (int)($_SESSION['ruleset_var_id'] ?? 1);
$ruleset_nom_actif    = '';
foreach ($rulesets as $r):
  if ((int)$r['var_id'] === $ruleset_var_id_actif):
    $ruleset_nom_actif = $r['var_valeur'];
  endif;
endforeach;

// Chargement des ressources globales du ruleset actif
$stmt_res = $db->prepare('
  SELECT res_id, res_nom, res_abreviation, res_selection
  FROM   dd_ressources
  WHERE  res_ruleset_var_id = ?
    AND  res_j_id IS NULL
  ORDER  BY res_nom
');
$stmt_res->execute([$ruleset_var_id_actif]);
$ressources_dispo = $stmt_res->fetchAll();

// Chargement de la sélection personnelle actuelle (pour ce ruleset)
$stmt_sel = $db->prepare('
  SELECT js_res_id
  FROM   dd_joueurs_sources
  WHERE  js_j_id = ? AND js_ruleset_var_id = ?
');
$stmt_sel->execute([$j_id, $ruleset_var_id_actif]);
$res_selectionnes = $stmt_sel->fetchAll(PDO::FETCH_COLUMN);

// Traitement du formulaire
if ($_SERVER['REQUEST_METHOD'] === 'POST'):
  verifyCsrf();
  $section = strParam($_POST['section'] ?? '');

  // --- Section données personnelles ---
  if ($section === 'identite'):
    $prenom = strParam($_POST['j_prenom'] ?? '');
    $nom    = strParam($_POST['j_nom']    ?? '');
    $pseudo = strParam($_POST['j_pseudo'] ?? '');
    $email  = strParam($_POST['j_email']  ?? '');

    if (!$pseudo) $errors[] = 'Le pseudo est obligatoire.';
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) $errors[] = 'Email invalide.';

    if (!$errors):
      $chk = $db->prepare('SELECT j_id FROM dd_joueurs WHERE j_pseudo = ? AND j_id != ?');
      $chk->execute([$pseudo, $j_id]);
      if ($chk->fetch()) $errors[] = 'Ce pseudo est déjà utilisé.';

      $chk2 = $db->prepare('SELECT j_id FROM dd_joueurs WHERE j_email = ? AND j_id != ?');
      $chk2->execute([$email, $j_id]);
      if ($chk2->fetch()) $errors[] = 'Cet email est déjà utilisé.';
    endif;

    if (!$errors):
      $upd = $db->prepare('
        UPDATE dd_joueurs
        SET    j_prenom = ?, j_nom = ?, j_pseudo = ?, j_email = ?
        WHERE  j_id = ?
      ');
      $upd->execute([$prenom, $nom, $pseudo, $email, $j_id]);
      $_SESSION['j_pseudo'] = $pseudo;
      $ok = true;
      $stmt->execute([$j_id]);
      $joueur = $stmt->fetch();
    endif;

  // --- Section mot de passe ---
  elseif ($section === 'password'):
    $actuel   = $_POST['j_pass_actuel']   ?? '';
    $nouveau  = $_POST['j_pass_nouveau']  ?? '';
    $confirme = $_POST['j_pass_confirme'] ?? '';

    $chk = $db->prepare('SELECT j_password_hash FROM dd_joueurs WHERE j_id = ?');
    $chk->execute([$j_id]);
    $hash = $chk->fetchColumn();

    if (!password_verify($actuel, $hash)) $errors[] = 'Mot de passe actuel incorrect.';
    if (strlen($nouveau) < 8)             $errors[] = 'Le nouveau mot de passe doit faire au moins 8 caractères.';
    if ($nouveau !== $confirme)           $errors[] = 'Les deux mots de passe ne correspondent pas.';

    if (!$errors):
      $upd = $db->prepare('UPDATE dd_joueurs SET j_password_hash = ? WHERE j_id = ?');
      $upd->execute([password_hash($nouveau, PASSWORD_DEFAULT), $j_id]);
      $ok = true;
    endif;

  // --- Section paramètres ---
  elseif ($section === 'parametres'):
    $ruleset_var_id    = intParam($_POST['j_default_ruleset_var_id'] ?? 0);
    $mode_campagne     = isset($_POST['j_mode_campagne'])     ? 1 : 0;
    $affichage_ruleset = isset($_POST['j_affichage_ruleset']) ? 1 : 0;
    $items_par_page    = max(5, min(100, intParam($_POST['j_items_par_page'] ?? 20)));
    $theme_post        = $_POST['j_theme'] ?? 'dark';
    $theme             = in_array($theme_post, ['dark', 'light'], true) ? $theme_post : 'dark';

    $chk = $db->prepare('SELECT var_id FROM dd_variables WHERE var_id = ? AND var_cat = \'ruleset\'');
    $chk->execute([$ruleset_var_id]);
    if (!$chk->fetch()) $errors[] = 'Ruleset invalide.';

    if (!$errors):
      $upd = $db->prepare('
        UPDATE dd_joueurs
        SET    j_default_ruleset_var_id = ?,
               j_mode_campagne          = ?,
               j_affichage_ruleset      = ?,
               j_items_par_page         = ?,
               j_theme                  = ?
        WHERE  j_id = ?
      ');
      $upd->execute([$ruleset_var_id, $mode_campagne, $affichage_ruleset, $items_par_page, $theme, $j_id]);

      $_SESSION['ruleset_var_id']      = $ruleset_var_id;
      $_SESSION['rulesetRep']          = getRulesetRep($ruleset_var_id);
      $_SESSION['j_mode_campagne']     = $mode_campagne;
      $_SESSION['j_affichage_ruleset'] = $affichage_ruleset;
      $_SESSION['j_theme']             = $theme;

      $ok = true;
      $stmt->execute([$j_id]);
      $joueur = $stmt->fetch();
    endif;

  // --- Section sources ---
  elseif ($section === 'sources'):
    // Recharger la liste autorisée côté serveur (ruleset actif, global uniquement)
    $stmt_autorises = $db->prepare('
      SELECT res_id
      FROM   dd_ressources
      WHERE  res_ruleset_var_id = ? AND res_j_id IS NULL
    ');
    $stmt_autorises->execute([$ruleset_var_id_actif]);
    $ids_autorises = $stmt_autorises->fetchAll(PDO::FETCH_COLUMN);

    // Validation : ne conserver que les res_id appartenant à la liste autorisée
    $ids_post    = isset($_POST['res_ids']) && is_array($_POST['res_ids'])
                   ? $_POST['res_ids']
                   : [];
    $ids_valides = [];
    foreach ($ids_post as $rid):
      $rid = (int)$rid;
      if (in_array($rid, $ids_autorises)) $ids_valides[] = $rid;
    endforeach;

    // DELETE + INSERT en bloc
    $del = $db->prepare('
      DELETE FROM dd_joueurs_sources
      WHERE  js_j_id = ? AND js_ruleset_var_id = ?
    ');
    $del->execute([$j_id, $ruleset_var_id_actif]);

    if (!empty($ids_valides)):
      $ins = $db->prepare('
        INSERT INTO dd_joueurs_sources (js_j_id, js_res_id, js_ruleset_var_id)
        VALUES (?, ?, ?)
      ');
      foreach ($ids_valides as $rid):
        $ins->execute([$j_id, $rid, $ruleset_var_id_actif]);
      endforeach;
    endif;

    // Recharger la sélection pour l'affichage
    $stmt_sel->execute([$j_id, $ruleset_var_id_actif]);
    $res_selectionnes = $stmt_sel->fetchAll(PDO::FETCH_COLUMN);

    $ok = true;

  endif;
endif;

$page_title = 'Mon profil';
$js_module  = 'profil';
require_once '../include/header.php';
?>

<div class="profil-page">
  <h1 class="profil-page__title">Mon profil</h1>

  <? if ($ok): ?>
    <div class="flash-message flash-message--success">Modifications enregistrées.</div>
  <? endif ?>
  <? if ($errors): ?>
    <div class="flash-message flash-message--error">
      <?= h(implode(' ', $errors)) ?>
    </div>
  <? endif ?>

  <nav class="profil-nav">
    <button class="profil-nav__btn active" onclick="showSection('identite', this)">
      <i class="fa fa-user"></i> Identité
    </button>
    <button class="profil-nav__btn" onclick="showSection('password', this)">
      <i class="fa fa-lock"></i> Mot de passe
    </button>
    <button class="profil-nav__btn" onclick="showSection('parametres', this)">
      <i class="fa fa-sliders-h"></i> Paramètres
    </button>
    <button class="profil-nav__btn" onclick="showSection('sources', this)">
      <i class="fa fa-book"></i> Mes sources
    </button>
  </nav>

  <!-- Section Identité -->
  <section class="profil-section" id="section-identite">
    <h2>Données personnelles</h2>
    <form method="POST" action="<?= BASE_URL ?>/profil/index.php">
      <?= csrfField() ?>
      <input type="hidden" name="section" value="identite">

      <div class="profil-grid">
        <div class="form-group">
          <label for="j_prenom">Prénom</label>
          <input type="text" id="j_prenom" name="j_prenom"
                 value="<?= h($joueur['j_prenom']) ?>">
        </div>
        <div class="form-group">
          <label for="j_nom">Nom</label>
          <input type="text" id="j_nom" name="j_nom"
                 value="<?= h($joueur['j_nom']) ?>">
        </div>
        <div class="form-group">
          <label for="j_pseudo">Pseudo <span class="required">*</span></label>
          <input type="text" id="j_pseudo" name="j_pseudo"
                 value="<?= h($joueur['j_pseudo']) ?>" required>
        </div>
        <div class="form-group">
          <label for="j_email">Email <span class="required">*</span></label>
          <input type="email" id="j_email" name="j_email"
                 value="<?= h($joueur['j_email']) ?>" required>
        </div>
      </div>

      <div class="form-actions">
        <button type="submit" class="btn btn-primary">
          <i class="fa fa-save"></i> Enregistrer
        </button>
      </div>
    </form>
  </section>

  <!-- Section Mot de passe -->
  <section class="profil-section noDisplay" id="section-password">
    <h2>Changer le mot de passe</h2>
    <form method="POST" action="<?= BASE_URL ?>/profil/index.php">
      <?= csrfField() ?>
      <input type="hidden" name="section" value="password">

      <div class="profil-grid profil-grid--narrow">
        <div class="form-group">
          <label for="j_pass_actuel">Mot de passe actuel</label>
          <input type="password" id="j_pass_actuel" name="j_pass_actuel"
                 required autocomplete="current-password">
        </div>
        <div class="form-group">
          <label for="j_pass_nouveau">Nouveau mot de passe <span class="text-muted">(8 caractères min.)</span></label>
          <input type="password" id="j_pass_nouveau" name="j_pass_nouveau"
                 required minlength="8" autocomplete="new-password">
        </div>
        <div class="form-group">
          <label for="j_pass_confirme">Confirmer le nouveau mot de passe</label>
          <input type="password" id="j_pass_confirme" name="j_pass_confirme"
                 required minlength="8" autocomplete="new-password">
        </div>
      </div>

      <div class="form-actions">
        <button type="submit" class="btn btn-primary">
          <i class="fa fa-key"></i> Changer le mot de passe
        </button>
      </div>
    </form>
  </section>

  <!-- Section Paramètres -->
  <section class="profil-section noDisplay" id="section-parametres">
    <h2>Paramètres de l'application</h2>
    <form method="POST" action="<?= BASE_URL ?>/profil/index.php">
      <?= csrfField() ?>
      <input type="hidden" name="section" value="parametres">

      <div class="profil-grid profil-grid--narrow">

        <div class="form-group">
          <label for="j_default_ruleset_var_id">Ruleset par défaut</label>
          <select id="j_default_ruleset_var_id" name="j_default_ruleset_var_id">
            <? foreach ($rulesets as $r): ?>
              <option value="<?= (int)$r['var_id'] ?>"
                <?= (int)$r['var_id'] === (int)$joueur['j_default_ruleset_var_id'] ? 'selected' : '' ?>>
                <?= h($r['var_valeur']) ?>
              </option>
            <? endforeach ?>
          </select>
          <p class="form-hint">Ruleset chargé par défaut à chaque connexion.</p>
        </div>

        <div class="form-group">
          <label>Apparence du site</label>
          <div class="theme-selector">
            <label class="theme-option">
              <input type="radio" name="j_theme" value="dark"
                     <?= ($joueur['j_theme'] ?? 'dark') === 'dark' ? 'checked' : '' ?>>
              <span class="theme-option__label">
                <i class="fa fa-moon"></i> Sombre
              </span>
            </label>
            <label class="theme-option">
              <input type="radio" name="j_theme" value="light"
                     <?= ($joueur['j_theme'] ?? 'dark') === 'light' ? 'checked' : '' ?>>
              <span class="theme-option__label">
                <i class="fa fa-sun"></i> Clair — Parchemin
              </span>
            </label>
          </div>
          <p class="form-hint">Le thème choisi s'applique immédiatement après enregistrement.</p>
        </div>

        <div class="form-group">
          <label class="toggle-label">
            <span>Mode campagne</span>
            <input type="checkbox" name="j_mode_campagne" value="1"
                   <?= $joueur['j_mode_campagne'] ? 'checked' : '' ?>>
            <span class="toggle-switch"></span>
          </label>
          <p class="form-hint">Active le menu Campagnes et les outils de gestion de parties.</p>
        </div>

        <div class="form-group">
          <label class="toggle-label">
            <span>Afficher le ruleset actif dans le menu</span>
            <input type="checkbox" name="j_affichage_ruleset" value="1"
                   <?= $joueur['j_affichage_ruleset'] ? 'checked' : '' ?>>
            <span class="toggle-switch"></span>
          </label>
        </div>

        <div class="form-group">
          <label for="j_items_par_page">Éléments par page dans les listes</label>
          <select id="j_items_par_page" name="j_items_par_page">
            <? foreach ([10, 20, 50, 100] as $n): ?>
              <option value="<?= $n ?>" <?= (int)$joueur['j_items_par_page'] === $n ? 'selected' : '' ?>>
                <?= $n ?>
              </option>
            <? endforeach ?>
          </select>
        </div>

      </div>

      <div class="form-actions">
        <button type="submit" class="btn btn-primary">
          <i class="fa fa-save"></i> Enregistrer les paramètres
        </button>
      </div>
    </form>
  </section>

  <!-- Section Sources -->
  <section class="profil-section noDisplay" id="section-sources">
    <h2>Mes sources — <?= h($ruleset_nom_actif) ?></h2>

    <? if (empty($ressources_dispo)): ?>
      <p class="text-muted">Aucune ressource disponible pour ce ruleset.</p>
    <? else: ?>

      <p class="form-hint mb-md">
        Sélectionnez les ressources à utiliser dans le compendium pour le ruleset
        <strong><?= h($ruleset_nom_actif) ?></strong>.
        Si aucune ressource n'est sélectionnée, le compendium affichera les sources actives par défaut.
      </p>

      <form method="POST" action="<?= BASE_URL ?>/profil/index.php">
        <?= csrfField() ?>
        <input type="hidden" name="section" value="sources">

        <div class="sources-liste">
          <? foreach ($ressources_dispo as $res): ?>
            <label class="sources-item">
              <input type="checkbox"
                     name="res_ids[]"
                     value="<?= (int)$res['res_id'] ?>"
                     <?= in_array((int)$res['res_id'], array_map('intval', $res_selectionnes)) ? 'checked' : '' ?>>
              <span class="sources-item__nom"><?= h($res['res_nom']) ?></span>
              <? if ($res['res_abreviation']): ?>
                <span class="sources-item__abrev"><?= h($res['res_abreviation']) ?></span>
              <? endif ?>
              <? if ($res['res_selection']): ?>
                <span class="sources-item__defaut" title="Sélection par défaut">★</span>
              <? endif ?>
            </label>
          <? endforeach ?>
        </div>

        <div class="form-actions">
          <button type="submit" class="btn btn-primary">
            <i class="fa fa-save"></i> Enregistrer mes sources
          </button>
          <button type="button" class="btn btn-secondary" onclick="sourcesSelectAll(true)">
            Tout sélectionner
          </button>
          <button type="button" class="btn btn-secondary" onclick="sourcesSelectAll(false)">
            Tout désélectionner
          </button>
        </div>
      </form>

    <? endif ?>
  </section>

</div>

<?
require_once '../include/footer.php';
?>
