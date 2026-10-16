<?php
// include/ajax/detail-pp-sub/listes-picker.php
// Sélecteur de liste dynamique appelé depuis l'éditeur TinyMCE (SP-PO3) : choisit l'entité,
// les familles, la source, le tri et la légende, puis insère [[liste:…]] dans l'éditeur.
// S'affiche dans #detail-pp-sub (z-index 300), au-dessus de #modification (250) qui porte le
// formulaire en cours : la saisie n'est jamais remplacée (même principe que tableaux-picker.php).
//
// Le tag n'est pas composé ici côté navigateur : chaque changement interroge
// include/ajax/liste-apercu.php, qui valide les choix, renvoie le tag canonique et le nombre de lignes.
//
// Paramètre GET : ent (equipement | objet) — entité présélectionnée.
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9e

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../liste-parser.php';

requireAuth();
if (!canEditCompendium()):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

$ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);
$ent        = in_array($_GET['ent'] ?? '', ['equipement', 'objet'], true) ? $_GET['ent'] : 'equipement';

$entites = [
  'equipement' => 'Équipement',
  'objet'      => 'Objets magiques',
];
$familles = [];
foreach (array_keys($entites) as $e) $familles[$e] = listeFamillesProposables($db, $e, $ruleset_id);
$sources = listeSourcesProposables($db, $ruleset_id);
?>

<div class="listes-picker" data-apercu="<?= h(BASE_URL . '/include/ajax/liste-apercu.php') ?>">

  <h3 class="overlay-titre">Insérer une liste</h3>
  <p class="text-muted listes-picker__intro">
    La liste se met à jour toute seule quand le compendium change.
  </p>

  <fieldset class="listes-picker__groupe">
    <legend>Type de liste</legend>
    <?php foreach ($entites as $code => $libelle): ?>
      <label class="listes-picker__choix">
        <input type="radio" name="lp-ent" value="<?= h($code) ?>" <?= $code === $ent ? 'checked' : '' ?>>
        <?= h($libelle) ?>
      </label>
    <?php endforeach ?>
  </fieldset>

  <?php foreach ($familles as $code => $liste): ?>
    <fieldset class="listes-picker__groupe listes-picker__familles" data-ent="<?= h($code) ?>"
              <?= $code === $ent ? '' : 'hidden' ?>>
      <legend>Familles
        <span class="text-muted">
          (aucune cochée = toutes<?= $code === 'equipement' ? ' ; une famille inclut ses sous-familles' : '' ?>)
        </span>
      </legend>
      <?php if (empty($liste)): ?>
        <p class="text-muted">Aucune famille pour ce ruleset.</p>
      <?php else: ?>
        <div class="listes-picker__cases">
          <?php foreach ($liste as $f): ?>
            <label class="listes-picker__choix" style="--lp-niveau: <?= (int)$f['niveau'] ?>">
              <input type="checkbox" class="lp-fam" value="<?= h($f['slug']) ?>">
              <?= h($f['nom']) ?>
            </label>
          <?php endforeach ?>
        </div>
      <?php endif ?>
    </fieldset>
  <?php endforeach ?>

  <fieldset class="listes-picker__groupe">
    <legend>Source</legend>
    <label class="listes-picker__choix">
      <input type="radio" name="lp-src" value="actives" checked>
      Sources actives du lecteur
      <span class="text-muted">(recommandé : la liste suit les sources que chacun a cochées)</span>
    </label>
    <label class="listes-picker__choix">
      <input type="radio" name="lp-src" value="figer">
      Figer la source
      <span class="text-muted">(tous les lecteurs voient les mêmes lignes)</span>
    </label>
    <div class="listes-picker__cases listes-picker__sources" id="lp-sources" hidden>
      <?php foreach ($sources as $s): ?>
        <label class="listes-picker__choix">
          <input type="checkbox" class="lp-src" value="<?= h((string)$s['ident']) ?>"
                 <?= $s['ident'] === null ? 'disabled' : '' ?>>
          <?= h($s['nom']) ?>
          <?php if ($s['abr'] !== ''): ?><span class="text-muted">(<?= h($s['abr']) ?>)</span><?php endif ?>
          <?php if ($s['ident'] === null): ?><span class="text-muted">— nom inutilisable dans un tag</span><?php endif ?>
        </label>
      <?php endforeach ?>
    </div>
  </fieldset>

  <fieldset class="listes-picker__groupe listes-picker__options">
    <legend>Présentation</legend>
    <label>Tri
      <select id="lp-tri" class="form-control">
        <option value="">Ordre du livre</option>
        <option value="nom">Nom</option>
        <option value="prix">Prix</option>
      </select>
    </label>
    <div class="listes-picker__titre">
      <span>Légende</span>
      <label class="listes-picker__choix"><input type="radio" name="lp-titre" value="defaut" checked> Par défaut</label>
      <label class="listes-picker__choix"><input type="radio" name="lp-titre" value="perso"> Personnalisée</label>
      <label class="listes-picker__choix"><input type="radio" name="lp-titre" value="aucune"> Aucune</label>
      <input type="text" id="lp-titre-texte" class="form-control" maxlength="80" disabled
             placeholder="Texte de la légende" autocomplete="off">
    </div>
  </fieldset>

  <div class="listes-picker__resultat">
    <p class="listes-picker__compte" id="lp-compte" aria-live="polite">Calcul…</p>
    <code class="listes-picker__tag" id="lp-tag"></code>
    <p class="listes-picker__alerte" id="lp-alerte" hidden></p>
  </div>

  <div class="listes-picker__actions">
    <button type="button" class="btn btn-primary" id="lp-inserer" disabled>
      <i class="fa fa-plus"></i> Insérer dans le texte
    </button>
  </div>

</div>

<script>
  (function () {
    var racine = document.querySelector('.listes-picker');
    if (!racine) return;

    var urlApercu = racine.getAttribute('data-apercu');
    var compte    = document.getElementById('lp-compte');
    var tagBloc   = document.getElementById('lp-tag');
    var alerte    = document.getElementById('lp-alerte');
    var bouton    = document.getElementById('lp-inserer');
    var titreTxt  = document.getElementById('lp-titre-texte');
    var blocSrc   = document.getElementById('lp-sources');
    var tagCourant = null;
    var minuteur   = null;
    var sequence   = 0;

    function valeurRadio(nom) {
      var r = racine.querySelector('input[name="' + nom + '"]:checked');
      return r ? r.value : '';
    }

    function coches(selecteur) {
      return Array.prototype.map.call(racine.querySelectorAll(selecteur + ':checked'), function (c) { return c.value; });
    }

    // Familles : seul le groupe de l'entité choisie compte (l'autre est masqué, ses cases restent cochables)
    function familles(ent) {
      var groupe = racine.querySelector('.listes-picker__familles[data-ent="' + ent + '"]');
      if (!groupe) return [];
      return Array.prototype.map.call(groupe.querySelectorAll('.lp-fam:checked'), function (c) { return c.value; });
    }

    function afficher(etat) {
      compte.textContent = etat.compte;
      tagBloc.textContent = etat.tag || '';
      alerte.hidden = !etat.alerte;
      alerte.textContent = etat.alerte || '';
      bouton.disabled = !etat.ok;
      tagCourant = etat.ok ? etat.tag : null;
    }

    function actualiser() {
      var ent = valeurRadio('lp-ent');
      var mode = valeurRadio('lp-titre');
      var titre = mode === 'aucune' ? '-' : (mode === 'perso' ? titreTxt.value : '');
      var src = valeurRadio('lp-src') === 'figer' ? coches('.lp-src') : [];

      var q = new URLSearchParams({
        ent: ent,
        fam: familles(ent).join(','),
        src: src.join(','),
        tri: document.getElementById('lp-tri').value,
        titre: titre
      });

      var mon = ++sequence;
      compte.textContent = 'Calcul…';
      fetch(urlApercu + '?' + q.toString(), { credentials: 'same-origin' })
        .then(function (r) { return r.json(); })
        .then(function (d) {
          if (mon !== sequence) return;   // réponse périmée : un choix plus récent est en cours
          if (d.erreur || !d.tag) { afficher({ ok: false, compte: d.erreur || 'Liste invalide.', tag: '' }); return; }
          var etat = { ok: true, tag: d.tag, compte: d.lignes + (d.lignes > 1 ? ' lignes' : ' ligne') };
          if (d.lignes === 0) etat.alerte = 'Cette combinaison ne donne aucune ligne pour vos sources actives.';
          else if (d.tronquee) etat.alerte = 'Au-delà de ' + d.max + ' lignes, la liste est tronquée avec un lien vers le compendium.';
          afficher(etat);
        })
        .catch(function () {
          if (mon !== sequence) return;
          afficher({ ok: false, compte: 'Aperçu indisponible.', tag: '' });
        });
    }

    function planifier() {
      clearTimeout(minuteur);
      minuteur = setTimeout(actualiser, 150);
    }

    racine.addEventListener('change', function (e) {
      var cible = e.target;
      if (cible.name === 'lp-ent') {
        racine.querySelectorAll('.listes-picker__familles').forEach(function (g) {
          g.hidden = g.getAttribute('data-ent') !== cible.value;
        });
      }
      if (cible.name === 'lp-src') blocSrc.hidden = cible.value !== 'figer';
      if (cible.name === 'lp-titre') {
        titreTxt.disabled = cible.value !== 'perso';
        if (cible.value === 'perso') titreTxt.focus();
      }
      planifier();
    });
    titreTxt.addEventListener('input', planifier);

    bouton.addEventListener('click', function () {
      if (tagCourant && typeof insererListeDansEditeur === 'function') insererListeDansEditeur(tagCourant);
    });

    actualiser();
  }());
</script>
