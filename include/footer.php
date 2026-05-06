<?
// include/footer.php
?>
</main>

<footer class="site-footer">
  <p>Codex DD v2 — <?= date('Y') ?></p>
</footer>

<script src="<?= BASE_URL ?>/js/main.js"></script>
<? if (!empty($js_module)): ?>
  <script src="<?= BASE_URL ?>/js/<?= $js_module ?>.js"></script>
<? endif ?>

</body>
</html>
