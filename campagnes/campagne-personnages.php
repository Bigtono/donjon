<?php
// campagnes/campagne-personnages.php — Page d'une campagne, onglet Personnages (SP-CP9).
// Personnages rattachés (SP-PE5) ; ajout et retrait par le MJ (SP-PE18).
// Paramètre GET : id (int) — camp_id

require_once __DIR__ . '/../include/campagne-contexte.php';

// La source de vérité du rattachement est dd_campagnes_personnages ; le
// marqueur « en cours » se lit sur le raccourci pe_camp_id du personnage.
// SP-PE18 : le MJ ajoute et retire lui-même les personnages, et tous ceux qui
// sont rattachés lui sont ouverts.
$stmt_per = $db->prepare('
  SELECT pe.pe_id,
         pe.pe_nom,
         pe.pe_j_id,
         jo.j_pseudo AS joueur_pseudo,
         ra.ra_nom,
         cp.cp_actif,
         (pe.pe_camp_id = ?) AS est_courante,
         (SELECT GROUP_CONCAT(CONCAT(cla.cla_nom, \' \', pc.pc_niveau)
                   ORDER BY cla.cla_nom SEPARATOR \' / \')
            FROM dd_personnages_classes pc
            JOIN dd_classes cla ON cla.cla_id = pc.pc_cla_id
           WHERE pc.pc_pe_id = pe.pe_id) AS classes_txt
  FROM   dd_campagnes_personnages cp
  JOIN   dd_personnages pe ON pe.pe_id = cp.cp_pe_id
  LEFT JOIN dd_joueurs jo ON jo.j_id = pe.pe_j_id
  LEFT JOIN dd_races ra ON ra.ra_id = pe.pe_ra_id
  WHERE  cp.cp_camp_id = ?
  ORDER  BY est_courante DESC, pe.pe_nom ASC
');
$stmt_per->execute([$id, $id]);
$personnages = $stmt_per->fetchAll();

// Personnages proposés à l'ajout : tous ceux du ruleset de la campagne, quel
// que soit leur joueur, hormis ceux déjà rattachés (SP-PE18, D-PE18b).
$stmt_ajout = $db->prepare('
  SELECT pe.pe_id, pe.pe_nom, jo.j_pseudo AS joueur_pseudo
  FROM   dd_personnages pe
  LEFT JOIN dd_joueurs jo ON jo.j_id = pe.pe_j_id
  WHERE  pe.pe_ruleset_var_id = ?
    AND  NOT EXISTS (SELECT 1 FROM dd_campagnes_personnages cp
                      WHERE cp.cp_camp_id = ? AND cp.cp_pe_id = pe.pe_id)
  ORDER  BY pe.pe_nom ASC, jo.j_pseudo ASC
');
$stmt_ajout->execute([(int)$camp['camp_ruleset_var_id'], $id]);
$personnages_ajout = $stmt_ajout->fetchAll();

$page_title = 'Personnages — ' . $camp['camp_nom'];

require_once '../include/header.php';

$nav_courante = 'personnages';
require __DIR__ . '/../include/campagne-entete.php';
?>

    <div class="camp-detail__section">
      <div class="camp-section__header">
        <h2 class="camp-detail__section-title">Personnages</h2>
        <?php if (!empty($personnages_ajout)): ?>
          <div class="camp-perso-ajout">
            <select id="camp-perso-ajout" aria-label="Personnage à ajouter">
              <option value="">Ajouter un personnage…</option>
              <?php foreach ($personnages_ajout as $pa): ?>
                <option value="<?= (int)$pa['pe_id'] ?>">
                  <?= h($pa['pe_nom']) ?><?= $pa['joueur_pseudo'] ? ' (' . h($pa['joueur_pseudo']) . ')' : '' ?>
                </option>
              <?php endforeach ?>
            </select>
            <button class="btn btn-primary btn-sm" title="Ajouter à la campagne"
                    onclick="campPersoAjouter(<?= $id ?>)">
              <i class="fa fa-plus"></i>
            </button>
          </div>
        <?php endif ?>
      </div>

      <?php if (empty($personnages)): ?>
        <p class="text-muted">Aucun personnage rattaché.</p>
      <?php else: ?>
        <table class="camp-sous-liste">
          <thead>
            <tr>
              <th class="col-action"></th>
              <th>Personnage</th>
              <th>Joueur</th>
              <th>Classes</th>
              <th>Statut</th>
            </tr>
          </thead>
          <tbody>
            <?php foreach ($personnages as $p): ?>
              <?php
                // Tout personnage rattaché s'ouvre au MJ (peutGererPersonnage).
                $url_per = BASE_URL . '/personnages/fiche.php?id=' . (int)$p['pe_id'];
              ?>
              <tr>
                <td class="col-action">
                  <button class="btn btn-icon btn-sm" title="Retirer de la campagne"
                          data-pe-nom="<?= h($p['pe_nom']) ?>"
                          onclick="campPersoRetirer(<?= $id ?>, <?= (int)$p['pe_id'] ?>, this.dataset.peNom)">
                    <i class="fa fa-times"></i>
                  </button>
                </td>
                <td>
                  <a href="<?= h($url_per) ?>"><?= h($p['pe_nom']) ?></a>
                  <?php if (!empty($p['ra_nom'])): ?>
                    <span class="text-muted text-sm"><?= h($p['ra_nom']) ?></span>
                  <?php endif ?>
                </td>
                <td class="text-muted"><?= h($p['joueur_pseudo'] ?? '—') ?></td>
                <td class="text-muted">
                  <?= $p['classes_txt'] ? h($p['classes_txt']) : '—' ?>
                </td>
                <td>
                  <?php if ((int)$p['est_courante'] === 1): ?>
                    <span class="per-camp__badge per-camp__badge--courante">En cours</span>
                  <?php elseif ((int)$p['cp_actif'] !== 1): ?>
                    <span class="per-camp__badge">Terminée</span>
                  <?php else: ?>
                    <span class="text-muted">—</span>
                  <?php endif ?>
                </td>
              </tr>
            <?php endforeach ?>
          </tbody>
        </table>
      <?php endif ?>
    </div>

  </section>

</div>

<?php require_once '../include/footer.php'; ?>
