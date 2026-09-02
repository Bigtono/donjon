<?
// include/footer.php
?>
</main>

<footer class="site-footer">
  <p>Codex DD v2 — <?= date('Y') ?></p>
</footer>

<script>
  var BASE_URL = <?= json_encode(BASE_URL) ?>;
  // Beacon SP-RS5 : vrai tant que la session authentifiée courante n'a pas
  // encore transmis ses caractéristiques d'affichage (cf. releveDevice()).
  var RELEVE_DEVICE = <?= (!empty($_SESSION['j_id']) && empty($_SESSION['releve_device'])) ? 'true' : 'false' ?>;
</script>
<script src="<?= BASE_URL ?>/js/main.js"></script>
<script src="<?= BASE_URL ?>/js/tri-liste.js"></script>
<? if (!empty($js_module)): ?>
  <script src="<?= BASE_URL ?>/js/<?= $js_module ?>.js"></script>
<? endif ?>

</body>
</html>
