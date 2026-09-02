<?
// include/header-context.php
// Fragment HTML du bloc de contexte de navigation (boutons retour rapide).
// Attend $header_context_niveaux (array) déjà calculé par l'appelant — soit
// include/header.php au chargement de page, soit include/ajax/header-context.php
// pour un rafraîchissement à chaud (cf. js/main.js).
//
// Rendu unique pour toutes les largeurs (SP-RS2) : icône de type + libellé +
// nom, séparateurs chevron entre les niveaux. Sous 992px le CSS masque les
// libellés et les séparateurs redeviennent visibles — fil d'Ariane défilable
// sur une seule ligne (cf. doc/ARCHITECTURE_0_REFERENCE.md §10d).
//
// SP-CP : les quatre niveaux de campagne sont désormais de vraies pages. Le
// fil d'Ariane est donc fait de liens (<a href>) et non plus de boutons
// rouvrant #detail-pp — c'est ce qui permet au raccourci de ramener à un
// niveau de campagne depuis n'importe quelle page du site, y compris hors
// module. La chaîne d'ancêtres n'a plus à être transportée en JS : chaque
// page reconstruit la sienne à partir de la session.
?>
<? if (!empty($header_context_niveaux)): ?>
  <div class="site-header__context">
    <?
    $ctx_base_camp = BASE_URL . '/campagnes';
    $ctx_urls = [
      'campagne'  => $ctx_base_camp . '/campagne.php',
      'scenario'  => $ctx_base_camp . '/scenario.php',
      'chapitre'  => $ctx_base_camp . '/chapitre.php',
      'rencontre' => $ctx_base_camp . '/rencontre.php',
    ];
    $ctx_labels = [
      'campagne'  => 'Campagne',
      'scenario'  => 'Scénario',
      'chapitre'  => 'Chapitre',
      'rencontre' => 'Rencontre',
    ];
    $ctx_icones = [
      'campagne'   => 'fa-dungeon',
      'scenario'   => 'fa-scroll',
      'chapitre'   => 'fa-bookmark',
      'rencontre'  => 'fa-dice-d20',
      'personnage' => 'fa-user',
    ];
    $ctx_dernier = count($header_context_niveaux) - 1;
    foreach ($header_context_niveaux as $ctx_i => $ctx_niveau):
      // Le niveau le plus profond est le contexte courant : jamais tronqué,
      // et c'est lui que le fil d'Ariane amène à l'écran au chargement.
      $ctx_classe = 'site-header__context-btn'
                  . ($ctx_i === $ctx_dernier ? ' site-header__context-btn--courant' : '');
      if ($ctx_i > 0):
    ?>
      <i class="fa fa-chevron-right site-header__context-sep" aria-hidden="true"></i>
    <?
      endif;
      if ($ctx_niveau['type'] === 'personnage'):
    ?>
      <a class="<?= $ctx_classe ?>"
         href="<?= BASE_URL ?>/personnages/fiche.php?id=<?= (int)$ctx_niveau['id'] ?>">
        <i class="fa <?= $ctx_icones['personnage'] ?>" aria-hidden="true"></i>
        <span class="site-header__context-nom"><?= h($ctx_niveau['nom']) ?></span>
      </a>
    <?
        continue;
      endif;
    ?>
      <a class="<?= $ctx_classe ?>"
         href="<?= $ctx_urls[$ctx_niveau['type']] ?>?id=<?= (int)$ctx_niveau['id'] ?>">
        <i class="fa <?= $ctx_icones[$ctx_niveau['type']] ?>" aria-hidden="true"></i>
        <span class="site-header__context-type"><?= h($ctx_labels[$ctx_niveau['type']]) ?> :</span>
        <span class="site-header__context-nom"><?= h($ctx_niveau['nom']) ?></span>
      </a>
    <? endforeach ?>
  </div>
<? endif ?>
