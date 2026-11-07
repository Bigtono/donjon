<?php
// personnages/possessions.php — Inventaire du personnage (sous-page, SP-PO8).
//
// Trois blocs : Équipé / en main, Équipement, Objets magiques (simples et composés mêlés).
// Écriture immédiate (pattern D-PE4a) par personnages/enregistrement.php :
// quantité, équipé, charges, nom libre, notes, retrait. Pas de bourse ni d'encombrement
// en V1 (D-PO16). Ni valeur ni poids affichés (D-PO30) : la ligne garde sa largeur pour
// les actions ; prix et poids se lisent dans la fiche de l'objet.
// Téléphone : Équipement et Objets magiques en onglets (D-PO30).
// « Ajouter » (et « Composer » en DD3.5) dans l'en-tête de chaque bloc ; le sélecteur
// s'ouvre directement sur la liste du bloc (D-PO31).
// Objets magiques avant Équipement ; sur ordinateur, les deux blocs se replient en
// alternance (un seul déplié, Objets magiques par défaut — D-PO32).
// L'ajout passe par le sélecteur possPicker (SP-PO9, detail-pp/possessions-picker.php)
// et le compositeur (SP-PO10 / PO11).
// Droit : peutGererPersonnage, via getPersonnageContext (D-PO18).
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §7.9b
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';
require_once '../include/personnage_helpers.php';
require_once '../include/liste-parser.php';

requireAuth();

$pe_id = intParam($_GET['id'] ?? 0);
$perso = getPersonnageContext($db, $pe_id);

if (!$perso):
  header('Location: ' . BASE_URL . '/personnages/');
  exit;
endif;

setLastPersonnage((int)$perso['pe_id'], (int)$perso['pe_ruleset_var_id']);

$classes     = getPersonnageClasses($db, (int)$perso['pe_id']);
$nav_lanceur = false;
foreach ($classes as $c):
  if ((int)$c['cla_mag_id'] > 0) { $nav_lanceur = true; break; }
endforeach;

$possessions = getPersonnagePossessions($db, (int)$perso['pe_id']);

// Harmonisation DD2024 (SP-PO12) : 3 objets au plus, dépassement signalé et non bloquant
$dd2024      = (int)$perso['pe_ruleset_var_id'] === 2;
$harmonises  = $dd2024 ? count(array_filter($possessions, fn($p) => (int)$p['pp_harmonise'] === 1)) : 0;
$harmonie_max = 3;

// Sorts des parchemins composés, pour les cases « lu » (SP-PO11)
$sorts_parchemin = [];
$ids = array_column(array_filter($possessions, fn($p) => $p['pp_type'] === 'compose' && $p['pp_compose_cat'] === 'parchemin'), 'pp_id');
if (!empty($ids)):
  $stmt = $db->prepare('
    SELECT ppe.ppe_id, ppe.ppe_pp_id, ppe.ppe_nls, ppe.ppe_utilise, so.so_id, so.so_nom
      FROM dd_personnages_possessions_elements ppe
      LEFT JOIN dd_sorts so ON so.so_id = ppe.ppe_so_id
     WHERE ppe.ppe_type = \'sort\' AND ppe.ppe_pp_id IN (' . implode(',', array_fill(0, count($ids), '?')) . ')
     ORDER BY ppe.ppe_pp_id, ppe.ppe_ordre
  ');
  $stmt->execute(array_map('intval', $ids));
  foreach ($stmt->fetchAll() as $e) $sorts_parchemin[(int)$e['ppe_pp_id']][] = $e;
endif;

$blocs = [
  'equipe'     => ['titre' => 'Équipé / en main', 'icone' => 'fa-hand-fist',   'lignes' => [], 'vide' => 'Rien d\'équipé.'],
  'magique'    => ['titre' => 'Objets magiques',  'icone' => 'fa-wand-sparkles', 'lignes' => [], 'vide' => 'Aucun objet magique.'],
  'equipement' => ['titre' => 'Équipement',       'icone' => 'fa-toolbox',     'lignes' => [], 'vide' => 'Aucun équipement.'],
];
foreach ($possessions as $p):
  $cle = (int)$p['pp_equipe'] === 1 ? 'equipe' : ($p['pp_type'] === 'equipement' ? 'equipement' : 'magique');
  $blocs[$cle]['lignes'][] = $p;
endforeach;

// Panneau actif par défaut (D-PO32) : Objets magiques. Un seul état pour les deux modes —
// l'onglet affiché sur téléphone, le bloc déplié sur ordinateur (l'autre est replié).
$onglet_defaut = 'magique';

$page_title   = 'Possessions — ' . $perso['pe_nom'];
$js_module    = 'personnage';
$css_module   = 'personnages';
$nav_courante = 'possessions';

require_once '../include/header.php';
?>

<script>
  var perPeId     = <?= (int)$perso['pe_id'] ?>;
  var perUrlEnreg = <?= json_encode(BASE_URL . '/personnages/enregistrement.php?ajax=1') ?>;
  var perUrlPossPicker = <?= json_encode(BASE_URL . '/include/ajax/detail-pp/possessions-picker.php') ?>;
  var perUrlCompose = <?= json_encode(BASE_URL . '/include/ajax/modifier/objet-compose.php') ?>;
</script>

<div class="per-fiche">

  <div class="per-fiche__header">
    <h1 class="per-fiche__nom"><?= h($perso['pe_nom']) ?></h1>
  </div>

  <?php require __DIR__ . '/../include/personnage-nav.php'; ?>

  <?php if ($dd2024): ?>
  <div class="per-poss__totaux" id="per-poss-totaux">
      <span class="per-poss__harmonie<?= $harmonises > $harmonie_max ? ' est-depasse' : '' ?>"
            title="Un personnage peut être harmonisé avec <?= $harmonie_max ?> objets magiques au plus">
        <i class="fa fa-link"></i> Harmonisés : <strong><?= $harmonises ?> / <?= $harmonie_max ?></strong>
        <?php if ($harmonises > $harmonie_max): ?>
          <i class="fa fa-triangle-exclamation" aria-label="Limite dépassée"></i>
        <?php endif ?>
      </span>
  </div>
  <?php endif ?>

  <?php foreach ($blocs as $cle => $bloc): ?>
    <?php if (empty($bloc['lignes']) && $cle === 'equipe') continue; ?>
    <?php if ($cle === 'magique'): // onglets, téléphone seulement (D-PO30) ?>
      <div class="per-poss__onglets per-magie__onglets-barre" role="tablist">
        <div class="per-magie__onglets-liste">
          <?php foreach (['magique', 'equipement'] as $o): ?>
            <button type="button" class="per-magie__onglet<?= $o === $onglet_defaut ? ' est-actif' : '' ?>" role="tab"
                    data-onglet="<?= $o ?>" aria-selected="<?= $o === $onglet_defaut ? 'true' : 'false' ?>"
                    onclick="perPossessions.onglet('<?= $o ?>')">
              <i class="fa <?= $blocs[$o]['icone'] ?>"></i> <?= h($blocs[$o]['titre']) ?>
              <span class="per-magie__onglet-compte"><?= count($blocs[$o]['lignes']) ?></span>
            </button>
          <?php endforeach ?>
        </div>
      </div>
    <?php endif ?>
    <?php $panneau = $cle !== 'equipe'; ?>
    <section class="per-fiche__bloc<?= $panneau ? ' per-poss__panneau' . ($cle === $onglet_defaut ? ' est-actif' : '') : '' ?>"
             id="bloc-poss-<?= $cle ?>"<?= $panneau ? ' data-onglet="' . $cle . '"' : '' ?>>
      <header class="per-fiche__bloc-header<?= $panneau ? ' per-fiche__bloc-header--flex' : '' ?>">
        <h2 class="per-fiche__bloc-titre">
          <i class="fa <?= $bloc['icone'] ?>"></i> <?= h($bloc['titre']) ?>
          <span class="per-poss__compte"><?= count($bloc['lignes']) ?></span>
        </h2>
        <?php if ($panneau): // ajout depuis le bloc : le sélecteur s'ouvre sur la bonne liste (D-PO31) ?>
          <div class="per-poss__bloc-outils">
            <button type="button" class="btn btn-primary btn-sm"
                    onclick="possPicker.ouvrir('<?= $cle === 'magique' ? 'objet' : 'equipement' ?>')">
              <i class="fa fa-plus"></i> Ajouter
            </button>
            <?php if ($cle === 'magique' && !$dd2024): // compositeur DD3.5 (SP-PO10) ?>
              <button type="button" class="btn btn-secondary btn-sm" title="Composer une arme, une armure, un bouclier, une potion, une baguette ou un parchemin"
                      onclick="actualiserPageModif(perUrlCompose, {pe_id: perPeId})">
                <i class="fa fa-wand-magic-sparkles"></i> Composer
              </button>
            <?php endif ?>
          </div>
          <?php // Repli en alternance, ordinateur seulement (D-PO32) : bouton et chevron de la fiche
                // (.per-fiche__replier, SP-RS6d) ; un clic déplie ce bloc et replie l'autre, ou l'inverse. ?>
          <?php $actif = $cle === $onglet_defaut; ?>
          <button type="button" class="btn btn-link btn-sm per-fiche__replier per-poss__replier<?= $actif ? ' is-open' : '' ?>"
                  aria-controls="bloc-poss-<?= $cle ?>-body" aria-expanded="<?= $actif ? 'true' : 'false' ?>"
                  onclick="perPossessions.replier('<?= $cle ?>')"
                  title="Afficher ou masquer le bloc">
            <i class="fa fa-chevron-down"></i>
          </button>
        <?php endif ?>
      </header>
      <div class="per-fiche__bloc-body" id="bloc-poss-<?= $cle ?>-body">
        <?php if (empty($bloc['lignes'])): ?>
          <p class="text-muted text-sm"><?= h($bloc['vide']) ?></p>
        <?php else: ?>
          <div class="table-dd-wrap">
            <table class="table-dd per-poss__table">
              <tbody>
                <?php foreach ($bloc['lignes'] as $p): ?>
                  <?php
                    $pp_id   = (int)$p['pp_id'];
                    $qte     = (int)$p['pp_quantite'];
                    $equipe  = (int)$p['pp_equipe'] === 1;
                    $a_notes = trim((string)$p['pp_notes']) !== '';
                  ?>
                  <tr class="per-poss__ligne" data-pp="<?= $pp_id ?>">
                    <td class="per-poss__nom">
                      <?php if ($p['manquant']): ?>
                        <span class="per-poss__intitule text-muted"><?= h($p['nom']) ?></span>
                      <?php else: ?>
                        <a href="javascript:void(0)" class="per-poss__intitule"
                           onclick="actualiserPage(<?= h(json_encode($p['lien']['url'])) ?>, {id: <?= (int)$p['lien']['id'] ?>})"><?= h($p['nom']) ?></a>
                      <?php endif ?>
                      <?php $harmo = $dd2024 && $p['pp_type'] === 'objet' && (int)$p['om_harmonisation'] === 1; ?>
                      <?php if ($harmo): ?>
                        <span class="per-poss__badge<?= (int)$p['pp_harmonise'] ? ' est-harmonise' : '' ?>"
                              title="<?= (int)$p['pp_harmonise'] ? 'Le personnage est harmonisé avec cet objet' : 'Cet objet requiert l\'harmonisation' ?>">
                          <?= (int)$p['pp_harmonise'] ? 'harmonisé' : 'harmonisation' ?>
                        </span>
                      <?php endif ?>
                      <span class="per-poss__sous">
                        <?= h($p['famille'] ?? '') ?><?= $p['nom_origine'] ? ' · ' . h($p['nom_origine']) : '' ?>
                        <?php if ($p['pp_charges'] !== null): ?>
                          · <label class="per-poss__charges">Charges
                            <input type="number" min="0" max="999" value="<?= (int)$p['pp_charges'] ?>"
                                   onchange="perPossessions.modifier(<?= $pp_id ?>, 'charges', this.value)">
                          </label>
                        <?php endif ?>
                      </span>
                      <?php if (!empty($sorts_parchemin[$pp_id])): ?>
                        <ul class="per-poss__sorts">
                          <?php foreach ($sorts_parchemin[$pp_id] as $e): ?>
                            <li class="<?= (int)$e['ppe_utilise'] ? 'est-lu' : '' ?>">
                              <label>
                                <input type="checkbox" <?= (int)$e['ppe_utilise'] ? 'checked' : '' ?>
                                       title="Sort lu (utilisé)"
                                       onchange="perPossessions.sortLu(<?= $pp_id ?>, <?= (int)$e['ppe_id'] ?>, this)">
                                <?= h($e['so_nom'] ?? 'Sort supprimé') ?> <span class="text-muted">(NLS <?= (int)$e['ppe_nls'] ?>)</span>
                              </label>
                            </li>
                          <?php endforeach ?>
                        </ul>
                      <?php endif ?>
                      <?php if ($a_notes): ?>
                        <span class="per-poss__notes-apercu"><?= nl2br(h($p['pp_notes'])) ?></span>
                      <?php endif ?>
                    </td>
                    <td class="per-poss__col-actions">
                      <div class="per-poss__actions">
                        <span class="per-poss__qte" title="Quantité">
                          <button type="button" class="btn-icon btn-sm" title="Retirer un exemplaire"
                                  onclick="perPossessions.quantite(<?= $pp_id ?>, -1)"<?= $qte <= 1 ? ' disabled' : '' ?>>−</button>
                          <span data-qte><?= $qte ?></span>
                          <button type="button" class="btn-icon btn-sm" title="Ajouter un exemplaire"
                                  onclick="perPossessions.quantite(<?= $pp_id ?>, 1)">+</button>
                        </span>
                        <?php if ($harmo): ?>
                          <?php $h = (int)$p['pp_harmonise'] === 1; ?>
                          <button type="button" class="btn-icon btn-sm<?= $h ? ' est-actif' : '' ?>"
                                  title="<?= $h ? 'Rompre l\'harmonisation' : 'S\'harmoniser (repos court)' ?>"
                                  aria-pressed="<?= $h ? 'true' : 'false' ?>"
                                  onclick="perPossessions.modifier(<?= $pp_id ?>, 'harmonise', <?= $h ? 0 : 1 ?>, true)">
                            <i class="fa fa-link"></i>
                          </button>
                        <?php endif ?>
                        <button type="button" class="btn-icon btn-sm<?= $equipe ? ' est-actif' : '' ?>"
                                title="<?= $equipe ? 'Ranger' : 'Équiper / prendre en main' ?>"
                                aria-pressed="<?= $equipe ? 'true' : 'false' ?>"
                                onclick="perPossessions.modifier(<?= $pp_id ?>, 'equipe', <?= $equipe ? 0 : 1 ?>, true)">
                          <i class="fa fa-hand-fist"></i>
                        </button>
                        <?php if ($p['pp_type'] === 'compose' && in_array($p['pp_compose_cat'], ['potion', 'huile', 'baguette'], true)): ?>
                          <?php $bag = $p['pp_compose_cat'] === 'baguette'; ?>
                          <button type="button" class="btn-icon btn-sm"
                                  title="<?= $bag ? 'Utiliser une charge' : ($p['pp_compose_cat'] === 'potion' ? 'Boire (un exemplaire de moins)' : 'Appliquer (un exemplaire de moins)') ?>"
                                  <?= $bag && (int)$p['pp_charges'] <= 0 ? 'disabled' : '' ?>
                                  onclick="perPossessions.consommer(<?= $pp_id ?>)">
                            <i class="fa <?= $bag ? 'fa-bolt' : 'fa-flask' ?>"></i>
                          </button>
                        <?php endif ?>
                        <?php if ($p['pp_type'] === 'compose'): ?>
                          <button type="button" class="btn-icon btn-sm" title="Recomposer"
                                  onclick="actualiserPageModif(perUrlCompose, {pe_id: perPeId, id: <?= $pp_id ?>})">
                            <i class="fa fa-wand-magic-sparkles"></i>
                          </button>
                        <?php endif ?>
                        <button type="button" class="btn-icon btn-sm" title="Nom et notes"
                                onclick="perPossessions.basculerEdition(<?= $pp_id ?>)">
                          <i class="fa fa-pen"></i>
                        </button>
                        <button type="button" class="btn-icon btn-sm" title="Retirer de l'inventaire"
                                onclick="perPossessions.retirer(<?= $pp_id ?>)">
                          <i class="fa fa-trash"></i>
                        </button>
                      </div>
                    </td>
                  </tr>
                  <tr class="per-poss__edition" id="per-poss-edition-<?= $pp_id ?>" hidden>
                    <td colspan="2">
                      <div class="per-poss__edition-corps">
                        <div class="form-group">
                          <label for="per-poss-nom-<?= $pp_id ?>">Nom<?= $p['pp_type'] === 'compose' ? '' : ' (vide = nom du compendium)' ?></label>
                          <input type="text" id="per-poss-nom-<?= $pp_id ?>" maxlength="200" value="<?= h((string)$p['pp_nom']) ?>"
                                 placeholder="<?= h($p['pp_type'] === 'compose' ? '' : ($p['eqt_nom'] ?? $p['om_nom'] ?? '')) ?>"
                                 onchange="perPossessions.modifier(<?= $pp_id ?>, 'nom', this.value, true)">
                        </div>
                        <div class="form-group">
                          <label for="per-poss-notes-<?= $pp_id ?>">Notes</label>
                          <textarea id="per-poss-notes-<?= $pp_id ?>" rows="2" maxlength="5000"
                                    onchange="perPossessions.modifier(<?= $pp_id ?>, 'notes', this.value, true)"><?= h((string)$p['pp_notes']) ?></textarea>
                        </div>
                      </div>
                    </td>
                  </tr>
                <?php endforeach ?>
              </tbody>
            </table>
          </div>
        <?php endif ?>
      </div>
    </section>
  <?php endforeach ?>

</div>

<?php require_once '../include/footer.php'; ?>
