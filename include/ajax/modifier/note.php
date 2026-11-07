<?php
// include/ajax/modifier/note.php
// Formulaire de création / modification d'une note du MJ (SP-NO2).
// Paramètres GET : id (int) — no_id (0 = création) ; camp_id (int, requis si id = 0) ;
//                  sce_id (int, facultatif : scénario proposé à la création)
//
// Une note = tronc commun (toujours lisible par ses destinataires) + sections
// ordonnées, chacune avec ses conditions « compétence + DD » (OU). Les sections
// sont envoyées en JSON (champ sections_json), voir enregistrerNote().

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../personnage_helpers.php';

requireAuth();

$id      = intParam($_GET['id']      ?? 0);
$camp_id = intParam($_GET['camp_id'] ?? 0);

$note = [
  'no_id'      => 0,
  'no_nom'     => '',
  'no_sce_id'  => intParam($_GET['sce_id'] ?? 0),
  'no_tyno_id' => 0,
  'no_texte'   => '',
  'no_date'    => date('Y-m-d'),
  'no_diffusion_campagne' => 0,
];

if ($id > 0):
  $stmt = $db->prepare('
    SELECT n.* FROM dd_notes n
    JOIN   dd_campagnes camp ON camp.camp_id = n.no_camp_id
    WHERE  n.no_id = ? AND n.no_supprime = 0 AND camp.camp_supprime = 0
  ');
  $stmt->execute([$id]);
  $row = $stmt->fetch();
  if (!$row):
    http_response_code(404);
    echo '<p class="erreur">Note introuvable.</p>';
    exit;
  endif;
  $note    = $row;
  $camp_id = (int)$row['no_camp_id'];
endif;

if (!$camp_id || !isMJ($db, $camp_id)):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

$stmt = $db->prepare('SELECT camp_nom, camp_ruleset_var_id FROM dd_campagnes WHERE camp_id = ?');
$stmt->execute([$camp_id]);
$camp       = $stmt->fetch();
$ruleset_id = (int)$camp['camp_ruleset_var_id'];

// Catégories du ruleset de la campagne
$stmt = $db->prepare('SELECT tyno_id, tyno_nom FROM dd_types_notes WHERE tyno_ruleset_var_id = ? ORDER BY tyno_ordre, tyno_nom');
$stmt->execute([$ruleset_id]);
$categories = $stmt->fetchAll();

// Scénarios de la campagne
$stmt = $db->prepare('SELECT sce_id, sce_nom FROM dd_scenarios WHERE sce_camp_id = ? AND sce_supprime = 0 ORDER BY sce_ordre, sce_nom');
$stmt->execute([$camp_id]);
$scenarios = $stmt->fetchAll();

// Compétences du ruleset (toutes : même périmètre que bonusCompetencesPersonnage())
$stmt = $db->prepare('SELECT comp_id, comp_nom FROM dd_competences WHERE comp_ruleset_var_id = ? ORDER BY comp_nom');
$stmt->execute([$ruleset_id]);
$competences = $stmt->fetchAll();

// Mots-clés : ceux du MJ (suggestions) et ceux de la note
$stmt = $db->prepare('SELECT tag_nom FROM dd_tags WHERE tag_j_id = ? ORDER BY tag_nom');
$stmt->execute([(int)$_SESSION['j_id']]);
$tags_mj   = $stmt->fetchAll(PDO::FETCH_COLUMN);
$tags_note = [];
if ($id > 0):
  $stmt = $db->prepare('SELECT t.tag_nom FROM dd_notes_tags nt JOIN dd_tags t ON t.tag_id = nt.notag_tag_id WHERE nt.notag_no_id = ? ORDER BY t.tag_nom');
  $stmt->execute([$id]);
  $tags_note = $stmt->fetchAll(PDO::FETCH_COLUMN);
endif;

// Sections avec leurs conditions
$sections = [];
foreach (getSectionsNotes($db, $id > 0 ? [$id] : [])[$id] ?? [] as $s):
  $sections[] = [
    'titre'      => (string)$s['noc_titre'],
    'texte'      => (string)$s['noc_texte'],
    'conditions' => array_map(fn($c) => ['comp_id' => (int)$c['nocd_comp_id'], 'dd' => (int)$c['nocd_dd']], $s['conditions']),
  ];
endforeach;

// Personnages de la campagne, et destinataires actuels. Un destinataire qui a
// quitté la campagne reste proposé (coché) : le décocher lui retire la note.
$stmt = $db->prepare('
  SELECT pe.pe_id, pe.pe_nom, cp.cp_actif,
         (pno.pno_id IS NOT NULL) AS destinataire,
         pno.pno_lu_date,
         (cp.cp_id IS NOT NULL) AS dans_campagne
    FROM dd_personnages pe
    LEFT JOIN dd_campagnes_personnages cp ON cp.cp_pe_id = pe.pe_id AND cp.cp_camp_id = ?
    LEFT JOIN dd_personnages_notes pno    ON pno.pno_pe_id = pe.pe_id AND pno.pno_no_id = ?
   WHERE cp.cp_id IS NOT NULL OR pno.pno_id IS NOT NULL
ORDER BY pe.pe_nom
');
$stmt->execute([$camp_id, $id]);
$personnages = $stmt->fetchAll();

$titre     = $id > 0 ? 'Modifier ' . h($note['no_nom']) : 'Nouvelle note';
$date_note = substr((string)$note['no_date'], 0, 10);
?>

<div class="modif-form note-form">
  <h3 class="modif-form__title"><?= $titre ?></h3>
  <p class="note-form__contexte"><?= h($camp['camp_nom']) ?> · <?= $ruleset_id === 2 ? 'DD2024' : 'DD3.5' ?></p>

  <form id="form-note" method="POST"
        action="<?= BASE_URL ?>/campagnes/enregistrement.php?ajax=1">
    <?= csrfField() ?>
    <input type="hidden" name="action"        value="enregistrerNote">
    <input type="hidden" name="no_id"         value="<?= (int)$note['no_id'] ?>">
    <input type="hidden" name="camp_id"       value="<?= $camp_id ?>">
    <input type="hidden" name="sections_json" id="note_sections_json" value="">

    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Données de la note</span>
      </div>

      <div class="modif-grid">
        <div class="form-group modif-grid__full">
          <label for="no_nom">Titre <span class="required">*</span></label>
          <input type="text" id="no_nom" name="no_nom" value="<?= h($note['no_nom']) ?>" required maxlength="200">
        </div>

        <div class="form-group">
          <label for="no_tyno_id">Catégorie <span class="required">*</span></label>
          <select id="no_tyno_id" name="no_tyno_id" required>
            <option value="">— Choisir —</option>
            <?php foreach ($categories as $cat): ?>
              <option value="<?= (int)$cat['tyno_id'] ?>" <?= (int)$cat['tyno_id'] === (int)$note['no_tyno_id'] ? 'selected' : '' ?>><?= h($cat['tyno_nom']) ?></option>
            <?php endforeach; ?>
          </select>
        </div>

        <div class="form-group">
          <label for="no_sce_id">Scénario</label>
          <select id="no_sce_id" name="no_sce_id">
            <option value="0">— Toute la campagne —</option>
            <?php foreach ($scenarios as $sce): ?>
              <option value="<?= (int)$sce['sce_id'] ?>" <?= (int)$sce['sce_id'] === (int)$note['no_sce_id'] ? 'selected' : '' ?>><?= h($sce['sce_nom']) ?></option>
            <?php endforeach; ?>
          </select>
        </div>

        <div class="form-group">
          <label for="no_date">Date</label>
          <input type="date" id="no_date" name="no_date" value="<?= h($date_note) ?>">
        </div>

        <div class="form-group">
          <label for="note-tag-saisie">Mots-clés</label>
          <div class="note-form__tags" id="note-tags">
            <?php foreach ($tags_note as $t): ?>
              <span class="note-form__tag"><?= h($t) ?><input type="hidden" name="tags[]" value="<?= h($t) ?>"><button type="button" class="note-form__tag-x" title="Retirer" aria-label="Retirer">&times;</button></span>
            <?php endforeach; ?>
            <input type="text" id="note-tag-saisie" class="note-form__tag-saisie" list="note-tags-mj"
                   maxlength="80" placeholder="Entrée ou virgule pour ajouter">
          </div>
          <datalist id="note-tags-mj">
            <?php foreach ($tags_mj as $t): ?>
              <option value="<?= h($t) ?>">
            <?php endforeach; ?>
          </datalist>
        </div>
      </div>
    </div>

    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Texte commun</span>
      </div>
      <p class="note-form__aide">Lisible par tous les destinataires. Peut rester vide si la note n'a que des sections.</p>
      <div class="form-group">
        <textarea id="no_texte" name="no_texte"><?= h($note['no_texte'] ?? '') ?></textarea>
      </div>
    </div>

    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Sections</span>
      </div>
      <p class="note-form__aide">
        Sans condition, une section est lisible par tous les destinataires. Avec des conditions, il suffit d'en
        remplir une : score (bonus total) dans la compétence ≥ DD.
      </p>
      <div id="note-sections"></div>
      <button type="button" class="btn btn-secondary btn-sm" id="note-ajout-section">
        <i class="fa fa-plus"></i> Ajouter une section
      </button>
    </div>

    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Destinataires</span>
      </div>
      <?php
        // Diffusion (SP-NO11) : toute la campagne — membres actuels et futurs,
        // inactifs compris — ou personnages choisis. En mode campagne, les cases
        // ne font que montrer les membres actuels ; elles ne sont pas envoyées.
        $diff_campagne = (int)$note['no_diffusion_campagne'] === 1;
      ?>
      <div class="note-form__diffusion">
        <label class="note-form__dest note-form__dest--tous">
          <input type="radio" name="no_diffusion_campagne" value="1" class="note-diffusion" <?= $diff_campagne ? 'checked' : '' ?>>
          Toute la campagne <span class="note-form__dest-info">(y compris les personnages ajoutés plus tard)</span>
        </label>
        <label class="note-form__dest note-form__dest--tous">
          <input type="radio" name="no_diffusion_campagne" value="0" class="note-diffusion" <?= $diff_campagne ? '' : 'checked' ?>>
          Personnages choisis
        </label>
      </div>
      <?php if (empty($personnages)): ?>
        <p class="note-form__aide">Aucun personnage n'est rattaché à cette campagne.</p>
      <?php else: ?>
        <div class="note-form__dests">
          <?php foreach ($personnages as $pe): ?>
            <?php
              $recoit = $diff_campagne ? (bool)$pe['dans_campagne'] : (bool)$pe['destinataire'];
            ?>
            <label class="note-form__dest">
              <input type="checkbox" name="pe_ids[]" value="<?= (int)$pe['pe_id'] ?>" class="note-dest"
                     data-campagne="<?= (int)$pe['dans_campagne'] ?>"
                     <?= $recoit ? 'checked' : '' ?> <?= $diff_campagne ? 'disabled' : '' ?>>
              <?= h($pe['pe_nom']) ?>
              <?php if (!$pe['dans_campagne']): ?>
                <span class="note-form__dest-info">(a quitté la campagne)</span>
              <?php elseif (!$pe['cp_actif']): ?>
                <span class="note-form__dest-info">(inactif)</span>
              <?php endif; ?>
              <?php if ($recoit): ?>
                <span class="note-form__dest-info"><?= $pe['pno_lu_date'] ? '· lue' : '· non lue' ?></span>
              <?php endif; ?>
            </label>
          <?php endforeach; ?>
        </div>
      <?php endif; ?>
      <?php if ($id > 0): ?>
        <label class="note-form__dest note-form__signaler">
          <input type="checkbox" name="signaler_maj" value="1">
          Signaler la mise à jour aux destinataires (la note redevient « nouvelle » pour eux)
        </label>
      <?php endif; ?>
    </div>

    <div class="modif-actions">
      <button type="button" class="btn btn-primary" onclick="noteForm.soumettre()">
        <i class="fa fa-save"></i> Enregistrer
      </button>
      <button type="button" class="btn btn-secondary" onclick="noteForm.fermer()">
        <i class="fa fa-times"></i> Annuler
      </button>
    </div>
  </form>

  <template id="note-section-modele">
    <div class="note-form__section">
      <div class="note-form__section-tete">
        <input type="text" class="note-form__section-titre" maxlength="200" placeholder="Intertitre (facultatif)">
        <button type="button" class="btn btn-icon btn-sm" data-act="monter" title="Monter" aria-label="Monter"><i class="fa fa-arrow-up"></i></button>
        <button type="button" class="btn btn-icon btn-sm" data-act="descendre" title="Descendre" aria-label="Descendre"><i class="fa fa-arrow-down"></i></button>
        <button type="button" class="btn btn-icon btn-sm" data-act="supprimer" title="Supprimer la section" aria-label="Supprimer la section"><i class="fa fa-trash"></i></button>
      </div>
      <textarea class="note-form__section-texte"></textarea>
      <div class="note-form__conditions"></div>
      <button type="button" class="btn btn-link btn-sm" data-act="condition"><i class="fa fa-plus"></i> Condition de compétence</button>
    </div>
  </template>

  <template id="note-condition-modele">
    <div class="note-form__condition">
      <select class="note-form__condition-comp" aria-label="Compétence">
        <option value="">— Compétence —</option>
        <?php foreach ($competences as $c): ?>
          <option value="<?= (int)$c['comp_id'] ?>"><?= h($c['comp_nom']) ?></option>
        <?php endforeach; ?>
      </select>
      <label class="note-form__condition-dd">DD <input type="number" min="1" max="60" value="15"></label>
      <button type="button" class="btn btn-icon btn-sm" data-act="retirer" title="Retirer la condition" aria-label="Retirer la condition"><i class="fa fa-times"></i></button>
    </div>
  </template>
</div>

<script src="https://cdn.jsdelivr.net/npm/tinymce@6/tinymce.min.js"></script>
<script>
(function() {
  'use strict';

  var sectionsInitiales = <?= json_encode($sections, JSON_UNESCAPED_UNICODE | JSON_HEX_TAG | JSON_HEX_AMP) ?>;
  var conteneur = document.getElementById('note-sections');
  var compteur  = 0;

  function initEditeur(id, hauteur) {
    if (typeof tinymce === 'undefined') { setTimeout(function() { initEditeur(id, hauteur); }, 100); return; }
    var isLight = document.body.classList.contains('theme-light');
    tinymce.remove('#' + id);
    tinymce.init({
      selector:      '#' + id,
      language:      'fr_FR',
      menubar:       false,
      plugins:       'lists link image table code',
      toolbar:       'styles | bold italic underline | bullist numlist | link unlink image table | removeformat | code',
      height:        hauteur,
      skin:          isLight ? 'oxide' : 'oxide-dark',
      content_css:   isLight ? 'default' : 'dark',
      content_style: isLight
        ? 'body { background:#eae6dd; color:#2a2015; font-family:inherit; font-size:14px; }'
        : 'body { background:#0f3460; color:#e0e0e0; font-family:inherit; font-size:14px; }',
      // Accents en clair (pas d'entités &eacute;) : la recherche LIKE de la liste du MJ
      // doit trouver « Thé » dans le texte enregistré (SP-NO3).
      entity_encoding: 'raw',
      promotion:     false,
      branding:      false,
      base_url:      'https://cdn.jsdelivr.net/npm/tinymce@6',
      suffix:        '.min',
      images_upload_url:         '<?= BASE_URL ?>/include/ajax/upload-image.php',
      images_upload_credentials: true,
      automatic_uploads:         true,
    });
  }

  function tmceGet(id) {
    if (typeof tinymce !== 'undefined') {
      var ed = tinymce.get(id);
      if (ed && ed.initialized) return ed.getContent();
    }
    var el = document.getElementById(id);
    return el ? el.value : '';
  }

  // Un éditeur TinyMCE ne survit pas au déplacement de son nœud (l'iframe se
  // recharge vide) : on recopie son contenu dans le textarea, on le retire,
  // on déplace, puis on le recrée.
  function detacherEditeur(section) {
    var ta = section.querySelector('.note-form__section-texte');
    ta.value = tmceGet(ta.id);
    if (typeof tinymce !== 'undefined') tinymce.remove('#' + ta.id);
  }

  function ajouterCondition(section, cond) {
    var ligne = document.getElementById('note-condition-modele').content.firstElementChild.cloneNode(true);
    if (cond) {
      ligne.querySelector('select').value = String(cond.comp_id);
      ligne.querySelector('input').value  = String(cond.dd);
    }
    section.querySelector('.note-form__conditions').appendChild(ligne);
  }

  function ajouterSection(donnees) {
    var section = document.getElementById('note-section-modele').content.firstElementChild.cloneNode(true);
    var ta      = section.querySelector('.note-form__section-texte');
    ta.id = 'note_section_' + (++compteur);
    if (donnees) {
      section.querySelector('.note-form__section-titre').value = donnees.titre || '';
      ta.value = donnees.texte || '';
      (donnees.conditions || []).forEach(function(c) { ajouterCondition(section, c); });
    }
    conteneur.appendChild(section);
    initEditeur(ta.id, 200);
  }

  conteneur.addEventListener('click', function(e) {
    var btn = e.target.closest('[data-act]');
    if (!btn) return;
    var section = btn.closest('.note-form__section');
    switch (btn.getAttribute('data-act')) {
      case 'condition':
        ajouterCondition(section, null);
        break;
      case 'retirer':
        btn.closest('.note-form__condition').remove();
        break;
      case 'supprimer':
        if (!confirm('Supprimer cette section ?')) return;
        detacherEditeur(section);
        section.remove();
        break;
      case 'monter':
      case 'descendre':
        var voisin = btn.getAttribute('data-act') === 'monter' ? section.previousElementSibling : section.nextElementSibling;
        if (!voisin) return;
        detacherEditeur(section);
        detacherEditeur(voisin);
        if (btn.getAttribute('data-act') === 'monter') conteneur.insertBefore(section, voisin);
        else conteneur.insertBefore(voisin, section);
        initEditeur(section.querySelector('.note-form__section-texte').id, 200);
        initEditeur(voisin.querySelector('.note-form__section-texte').id, 200);
        break;
    }
  });

  document.getElementById('note-ajout-section').addEventListener('click', function() { ajouterSection(null); });

  // Mots-clés : saisie libre, Entrée ou virgule pour valider, suggestions des mots-clés du MJ.
  var zoneTags  = document.getElementById('note-tags');
  var saisieTag = document.getElementById('note-tag-saisie');

  function ajouterTag(nom) {
    nom = nom.replace(/,/g, ' ').replace(/\s+/g, ' ').trim();
    if (!nom) return;
    var deja = Array.prototype.some.call(zoneTags.querySelectorAll('input[name="tags[]"]'), function(i) {
      return i.value.toLowerCase() === nom.toLowerCase();
    });
    if (deja) return;
    var chip = document.createElement('span');
    chip.className = 'note-form__tag';
    chip.appendChild(document.createTextNode(nom));
    var cache = document.createElement('input');
    cache.type = 'hidden'; cache.name = 'tags[]'; cache.value = nom;
    chip.appendChild(cache);
    var x = document.createElement('button');
    x.type = 'button'; x.className = 'note-form__tag-x'; x.title = 'Retirer'; x.setAttribute('aria-label', 'Retirer');
    x.innerHTML = '&times;';
    chip.appendChild(x);
    zoneTags.insertBefore(chip, saisieTag);
  }

  saisieTag.addEventListener('keydown', function(e) {
    if (e.key === 'Enter' || e.key === ',') {
      e.preventDefault();
      ajouterTag(saisieTag.value);
      saisieTag.value = '';
    } else if (e.key === 'Backspace' && saisieTag.value === '') {
      var dernier = saisieTag.previousElementSibling;
      if (dernier) dernier.remove();
    }
  });
  // Choix dans la liste de suggestions (pas de keydown) : validé à la sortie du champ.
  saisieTag.addEventListener('change', function() { ajouterTag(saisieTag.value); saisieTag.value = ''; });
  zoneTags.addEventListener('click', function(e) {
    if (e.target.classList.contains('note-form__tag-x')) e.target.closest('.note-form__tag').remove();
    else if (e.target === zoneTags) saisieTag.focus();
  });

  // Diffusion (SP-NO11) : « Toute la campagne » coche et fige les membres
  // actuels ; « Personnages choisis » rend la main, membres pré-cochés — passer
  // d'un mode à l'autre ne retire la note à personne sans décision du MJ.
  var radiosDiff = document.querySelectorAll('.note-diffusion');
  var majDiffusion = function() {
    var campagne = document.querySelector('.note-diffusion:checked').value === '1';
    Array.prototype.forEach.call(document.querySelectorAll('.note-dest'), function(c) {
      if (campagne) c.checked = c.getAttribute('data-campagne') === '1';
      c.disabled = campagne;
    });
  };
  Array.prototype.forEach.call(radiosDiff, function(r) { r.addEventListener('change', majDiffusion); });

  function collecterSections() {
    return Array.prototype.map.call(conteneur.querySelectorAll('.note-form__section'), function(section) {
      return {
        titre: section.querySelector('.note-form__section-titre').value.trim(),
        texte: tmceGet(section.querySelector('.note-form__section-texte').id),
        conditions: Array.prototype.map.call(section.querySelectorAll('.note-form__condition'), function(l) {
          return { comp_id: parseInt(l.querySelector('select').value, 10) || 0,
                   dd: parseInt(l.querySelector('input').value, 10) || 0 };
        }).filter(function(c) { return c.comp_id > 0; })
      };
    });
  }

  function fermer() {
    if (typeof tinymce !== 'undefined') tinymce.remove('#form-note textarea');
    fermerModification();
  }

  function soumettre() {
    var form = document.getElementById('form-note');
    if (!form) return;
    if (!document.getElementById('no_nom').value.trim()) { alert('Le titre de la note est obligatoire.'); return; }
    if (!document.getElementById('no_tyno_id').value)    { alert('La catégorie est obligatoire.'); return; }
    if (saisieTag.value.trim()) { ajouterTag(saisieTag.value); saisieTag.value = ''; }

    document.getElementById('no_texte').value = tmceGet('no_texte');
    document.getElementById('note_sections_json').value = JSON.stringify(collecterSections());

    fetch(form.getAttribute('action'), { method: 'POST', body: new FormData(form) })
      .then(function(r) { return r.json(); })
      .then(function(data) {
        if (data.ok) {
          fermer();
          window.location.reload();
        } else {
          alert(data.erreur || "Erreur lors de l'enregistrement.");
        }
      })
      .catch(function(err) { alert('Erreur : ' + err); });
  }

  initEditeur('no_texte', 260);
  sectionsInitiales.forEach(ajouterSection);

  window.noteForm = { soumettre: soumettre, fermer: fermer };
})();
</script>
