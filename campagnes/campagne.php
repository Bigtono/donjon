<?php
// campagnes/campagne.php — Page d'une campagne, onglet Description (SP-CP, SP-CP9).
// Remplace include/ajax/detail-pp/campagne.php : le module a quitté le
// panneau #detail-pp pour une navigation pleine page (une URL par niveau).
//
// SP-CP9 : la page est découpée en sous-pages, sur le modèle du module
// Personnages — Description (ici), Personnages (campagne-personnages.php),
// Scénarios (campagne-scenarios.php). Socle commun : include/campagne-contexte.php
// et include/campagne-entete.php.
// Paramètre GET : id (int) — camp_id

require_once __DIR__ . '/../include/campagne-contexte.php';

// Onglet mémorisé (SP-CP10) : une entrée sans onglet explicite (liste, fil
// d'Ariane, header) rouvre la sous-page laissée la dernière fois. Le lien
// « Description » du sous-menu porte o=description et échappe au renvoi.
if (!isset($_GET['o'])):
  $memo = ongletMemorise('camp-' . $id, ['personnages', 'scenarios'], '');
  if ($memo !== ''):
    header('Location: ' . BASE_URL . '/campagnes/campagne-' . $memo . '.php?id=' . $id);
    exit;
  endif;
endif;

require_once '../include/header.php';

$nav_courante = 'description';
require __DIR__ . '/../include/campagne-entete.php';
?>

    <?php if (!empty($camp['camp_resume'])): ?>
      <p class="camp-detail__resume"><?= h($camp['camp_resume']) ?></p>
    <?php endif ?>

    <?php if (!empty($camp['camp_description'])): ?>
      <div class="camp-detail__description"><?= $camp['camp_description'] ?></div>
    <?php endif ?>

    <?php if (empty($camp['camp_resume']) && empty($camp['camp_description'])): ?>
      <p class="text-muted">Aucune description pour le moment.</p>
    <?php endif ?>

    <!-- Suppression de la campagne -->
    <div class="camp-detail__actions">
      <button class="btn btn-danger btn-sm"
              data-camp-id="<?= $id ?>"
              data-camp-nom="<?= h($camp['camp_nom']) ?>"
              onclick="campagneListe.supprimer(
                parseInt(this.dataset.campId),
                this.dataset.campNom
              )">
        <i class="fa fa-trash"></i> Supprimer la campagne
      </button>
    </div>

  </section>

</div>

<?php require_once '../include/footer.php'; ?>
