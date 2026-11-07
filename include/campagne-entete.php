<?php
// include/campagne-entete.php — En-tête commun des sous-pages d'une campagne (SP-CP9).
//
// Inclus juste après include/header.php. Ouvre le gabarit deux colonnes
// (colonne Outils + contenu), affiche la barre de titre et le sous-menu, puis
// laisse la page écrire son contenu. La page referme elle-même :
//   </section>
// </div>
//
// Attendus : $id, $camp, $base_modifier, $url_enreg (campagne-contexte.php)
//            $nav_courante — description | personnages | scenarios
?>
<script>
  var campUrlModifier = <?= json_encode($base_modifier . '/campagne.php') ?>;
  var campUrlEnreg    = <?= json_encode($url_enreg) ?>;
  var campUrlEnregPer = <?= json_encode(BASE_URL . '/personnages/enregistrement.php?ajax=1') ?>;
</script>

<div class="camp-page">

  <aside class="camp-page__outils">
    <?php include __DIR__ . '/campagne-outils.php'; ?>
  </aside>

  <section class="camp-page__contenu" data-camp-id="<?= (int)$id ?>">

    <div class="camp-page__titre-bar">
      <div>
        <h1 class="camp-page__titre">
          <?= h($camp['camp_nom']) ?>
          <button class="sort-detail__edit-btn"
                  onclick="actualiserPageModif('<?= $base_modifier ?>/campagne.php', {id:<?= (int)$id ?>})"
                  title="Modifier cette campagne">
            <i class="fa fa-edit"></i>
          </button>
        </h1>
        <?php if ($camp['univers_nom']): ?>
          <div class="camp-page__meta">
            <span><i class="fa fa-globe"></i> <?= h($camp['univers_nom']) ?></span>
          </div>
        <?php endif ?>
      </div>
      <div class="camp-page__titre-actions">
        <a class="btn btn-secondary btn-sm" href="<?= BASE_URL ?>/campagnes/index.php">
          <i class="fa fa-arrow-left"></i> Campagnes
        </a>
      </div>
    </div>

    <?php require __DIR__ . '/campagne-nav.php'; ?>
