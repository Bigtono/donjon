<?
// include/header-context.php
// Fragment HTML du bloc de contexte de navigation (boutons retour rapide).
// Attend $header_context_niveaux (array) déjà calculé par l'appelant — soit
// include/header.php au chargement de page, soit include/ajax/header-context.php
// pour un rafraîchissement à chaud depuis #detail-pp (cf. js/main.js).
?>
<? if (!empty($header_context_niveaux)): ?>
  <div class="site-header__context">
    <?
    $ctx_base_detail = BASE_URL . '/include/ajax/detail-pp';
    $ctx_urls = [
      'campagne' => $ctx_base_detail . '/campagne.php',
      'scenario' => $ctx_base_detail . '/scenario.php',
      'chapitre' => $ctx_base_detail . '/chapitre.php',
    ];
    $ctx_labels = ['campagne' => 'Campagne', 'scenario' => 'Scénario', 'chapitre' => 'Chapitre'];
    $ctx_chain  = [];
    foreach ($header_context_niveaux as $ctx_niveau):
      if ($ctx_niveau['type'] === 'personnage'):
    ?>
      <a class="site-header__context-btn"
         href="<?= BASE_URL ?>/personnages/fiche.php?id=<?= (int)$ctx_niveau['id'] ?>">
        <i class="fa fa-user"></i> <?= h($ctx_niveau['nom']) ?>
      </a>
    <?
        continue;
      endif;
      $ctx_chain[] = ['url' => $ctx_urls[$ctx_niveau['type']], 'params' => ['id' => $ctx_niveau['id']]];
    ?>
      <button type="button" class="site-header__context-btn"
              onclick="ouvrirContextePP(<?= h(json_encode($ctx_chain)) ?>)">
        <?= h($ctx_labels[$ctx_niveau['type']]) ?> : <?= h($ctx_niveau['nom']) ?>
      </button>
    <? endforeach ?>
  </div>
<? endif ?>
