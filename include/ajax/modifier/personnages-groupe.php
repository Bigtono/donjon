<?php
// include/ajax/modifier/personnages-groupe.php
// Panneau des actions groupées de la liste des personnages (SP-PE19, D-PE19a → c).
// Ouvert par « Appliquer » de la barre groupée (clé bulk_panneau de personnages/index.php).
// Paramètres GET : action — 'campagne' | 'joueur'
//                  ids    — pe_id séparés par des virgules
// Le panneau liste la sélection, signale les personnages écartés et porte le choix ;
// l'écriture est faite par l'action groupePersonnages de personnages/enregistrement.php,
// qui rejuge l'éligibilité de chaque personnage.

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../personnage_helpers.php';

requireAuth();

$actions = [
  'campagne' => 'Affecter à une campagne',
  'joueur'   => 'Affecter à un joueur',
];
$action = strParam($_GET['action'] ?? '');
$persos = personnagesGroupe($db, explode(',', (string)($_GET['ids'] ?? '')));

if (!isset($actions[$action]) || $persos === null):
  echo '<p class="erreur">Sélection invalide ou accès refusé.</p>';
  exit;
endif;

$nb       = count($persos);
$rulesets = array_unique(array_map('intval', array_column($persos, 'pe_ruleset_var_id')));
$erreur   = null;
$choix    = [];
// Raison d'écart connue avant le choix, par personnage (affectation seulement) ;
// celles qui dépendent du choix (déjà en cours, déjà à ce joueur) viennent au retour.
$raisons  = [];

if ($action === 'campagne'):
  if (count($rulesets) > 1):
    $erreur = 'La sélection mélange des rulesets : choisissez des personnages d\'un seul ruleset.';
  else:
    // Campagnes dont l'utilisateur est le MJ (toutes celles du ruleset pour l'admin).
    foreach (getCampagnesRattachables($db, (int)reset($rulesets)) as $camp):
      $choix[(int)$camp['camp_id']] = $camp['camp_nom']
        . ((int)$camp['camp_j_id'] !== (int)$_SESSION['j_id'] ? ' (' . $camp['mj_pseudo'] . ')' : '');
    endforeach;
    if (empty($choix)) $erreur = 'Vous n\'êtes MJ d\'aucune campagne de ce ruleset.';
  endif;
else:
  foreach ($persos as $pe_id => $pe):
    $raison = raisonNonAffectable($db, $pe);
    if ($raison !== null) $raisons[$pe_id] = $raison;
  endforeach;
  if (count($raisons) === $nb):
    $erreur = 'Aucun personnage de la sélection ne peut être affecté par vous.';
  else:
    $stmt  = $db->query('SELECT j_id, j_pseudo FROM dd_joueurs ORDER BY j_pseudo');
    $choix = $stmt->fetchAll(PDO::FETCH_KEY_PAIR);
  endif;
endif;

$nb_eligibles = $nb - count($raisons);
?>

<div class="modif-form per-groupe">
  <h3 class="modif-form__title"><?= h($actions[$action]) ?></h3>
  <p class="per-groupe__aide"><?= $nb ?> personnage<?= $nb > 1 ? 's' : '' ?> sélectionné<?= $nb > 1 ? 's' : '' ?></p>

  <ul class="per-groupe__liste">
    <?php foreach ($persos as $pe_id => $pe): ?>
      <li class="<?= isset($raisons[$pe_id]) ? 'per-groupe__ecarte' : '' ?>">
        <?= h($pe['pe_nom']) ?>
        <?php if ($action === 'campagne'): ?>
          <span class="text-muted">· <?= $pe['campagne_nom'] !== null ? 'en cours : ' . h($pe['campagne_nom']) : 'aucune campagne en cours' ?></span>
        <?php else: ?>
          <span class="text-muted">· <?= h($pe['joueur_pseudo'] ?? '—') ?></span>
          <?php if (isset($raisons[$pe_id])): ?>
            <span class="per-groupe__raison">— écarté : <?= h($raisons[$pe_id]) ?></span>
          <?php endif ?>
        <?php endif ?>
      </li>
    <?php endforeach ?>
  </ul>

  <?php if ($erreur !== null): ?>
    <p class="erreur"><?= h($erreur) ?></p>
    <div class="modif-actions">
      <button type="button" class="btn btn-secondary" onclick="fermerModification()">
        <i class="fa fa-times"></i> Fermer
      </button>
    </div>
  <?php else: ?>
    <form id="form-per-groupe" method="POST" action="<?= BASE_URL ?>/personnages/enregistrement.php?ajax=1">
      <?= csrfField() ?>
      <input type="hidden" name="action"    value="groupePersonnages">
      <input type="hidden" name="operation" value="<?= h($action) ?>">
      <?php foreach (array_keys($persos) as $pe_id): ?>
        <input type="hidden" name="ids[]" value="<?= (int)$pe_id ?>">
      <?php endforeach ?>

      <?php if ($action === 'campagne'): ?>
        <div class="form-group">
          <label for="pg_camp_id">Campagne <span class="required">*</span></label>
          <select id="pg_camp_id" name="camp_id">
            <option value="">— Choisir —</option>
            <?php foreach ($choix as $id => $nom): ?>
              <option value="<?= (int)$id ?>"><?= h($nom) ?></option>
            <?php endforeach ?>
          </select>
        </div>
        <p class="per-groupe__aide">Les personnages sont rattachés à la campagne, qui devient leur campagne
          en cours ; leurs autres campagnes ne changent pas. Seules les campagnes dont vous êtes le MJ sont proposées.</p>

      <?php else: ?>
        <div class="form-group">
          <label for="pg_j_id">Joueur <span class="required">*</span></label>
          <select id="pg_j_id" name="j_id_cible">
            <option value="">— Choisir —</option>
            <?php foreach ($choix as $id => $pseudo): ?>
              <option value="<?= (int)$id ?>"><?= h($pseudo) ?></option>
            <?php endforeach ?>
          </select>
        </div>
        <p class="per-groupe__aide">Le joueur devient propriétaire des
          personnages<?php if (!isAdmin()): ?> ; vous seul pourrez retirer l'affectation<?php endif ?>.
          <?php if ($raisons): ?>Les personnages écartés ne sont pas modifiés.<?php endif ?></p>
      <?php endif ?>

      <div class="modif-actions">
        <button type="button" class="btn btn-primary" onclick="perGroupe.soumettre()">
          <i class="fa fa-check"></i> Valider<?php if ($nb_eligibles !== $nb): ?> (<?= $nb_eligibles ?>)<?php endif ?>
        </button>
        <button type="button" class="btn btn-secondary" onclick="fermerModification()">
          <i class="fa fa-times"></i> Annuler
        </button>
      </div>
    </form>
  <?php endif ?>
</div>

<script>
(function() {
  function soumettre() {
    var form = document.getElementById('form-per-groupe');
    if (!form) return;
    var champ = form.querySelector('select');
    if (champ && !champ.value) { alert('Faites un choix dans la liste.'); return; }

    fetch(form.getAttribute('action'), { method: 'POST', body: new FormData(form) })
      .then(function(r) { return r.json(); })
      .then(function(data) {
        if (!data.ok) {
          alert(data.erreur || "Erreur lors de l'enregistrement.");
          return;
        }
        // Les personnages écartés sont signalés avant le rechargement (D-PE19b).
        if (data.ecartes && data.ecartes.length) {
          var lignes = data.ecartes.map(function(e) { return '- ' + e.nom + ' : ' + e.raison; });
          alert(data.appliques + ' personnage(s) modifié(s).\n'
            + data.ecartes.length + ' écarté(s) :\n' + lignes.join('\n'));
        }
        fermerModification();
        window.location.reload();
      })
      .catch(function(err) { alert('Erreur : ' + err); });
  }

  window.perGroupe = { soumettre: soumettre };
})();
</script>
