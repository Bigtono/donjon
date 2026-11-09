<?php
// include/opposition-pv.php — Suivi des PV des créatures d'une rencontre (SP-CP11).
//
// Une opposition = opp_nombre créatures identiques de opp_pv_max PV chacune.
// Les PV courants vivent dans dd_oppositions_pv, une ligne par créature
// ENTAMÉE : ligne absente = PV max. Le même composant de créature (.camp-pv)
// est rendu deux fois — dans le bandeau commun de l'onglet Oppositions et dans
// la fiche de l'opposition — et js/campagne.js tient les deux copies
// synchronisées par leur clé data-pv-cle (« oppid-rang »).

// ------------------------------------------------------------
// Effectifs lus dans la composition de la rencontre (SP-CP11c)
// ------------------------------------------------------------
// La composition (re_composition, HTML TinyMCE) énumère les effectifs ligne à
// ligne : « 5 × Asabi Brute », « 2 x Gnoll ». C'est là, et non dans le nom de
// l'opposition, que la v1 portait le nombre de créatures.

// Nom ramené à une forme comparable : texte brut, minuscules, sans accents ni
// apostrophe typographique, espaces réduits. Le décodage est double : les
// compositions importées contiennent des entités encodées deux fois (&amp;apos;).
function normaliserNomOpposition(string $nom): string {
  $nom = strip_tags($nom);
  for ($i = 0; $i < 2; $i++) $nom = html_entity_decode($nom, ENT_QUOTES | ENT_HTML5, 'UTF-8');
  $nom = str_replace(['’', '‘', "\u{00A0}"], ["'", "'", ' '], mb_strtolower(trim($nom)));
  $nom = strtr($nom, ['é'=>'e','è'=>'e','ê'=>'e','ë'=>'e','à'=>'a','â'=>'a','î'=>'i','ï'=>'i',
                      'ô'=>'o','ö'=>'o','û'=>'u','ù'=>'u','ü'=>'u','ç'=>'c']);
  return preg_replace('/\s+/u', ' ', $nom);
}

// [nom normalisé => effectif] pour chaque ligne « N × Nom » de la composition.
function effectifsComposition(?string $composition): array {
  if (!$composition) return [];
  $texte  = preg_replace('/<(br|\/p|\/li|\/div|\/h\d)[^>]*>/i', "\n", $composition);
  $texte  = html_entity_decode(strip_tags($texte), ENT_QUOTES | ENT_HTML5, 'UTF-8');
  $effectifs = [];
  foreach (preg_split('/\R/u', $texte) as $ligne):
    if (!preg_match('/^\s*(\d{1,2})\s*[×xX*]\s*(.+?)\s*$/u', $ligne, $m)) continue;
    $effectifs[normaliserNomOpposition($m[2])] = (int)$m[1];
  endforeach;
  return $effectifs;
}

// Effectif d'une opposition d'après la composition, 0 si elle n'y figure pas.
// Tolère un pluriel en « s » d'un côté ou de l'autre (« Asabis »).
function effectifOpposition(array $effectifs, string $opp_nom): int {
  $nom = normaliserNomOpposition($opp_nom);
  if (isset($effectifs[$nom])) return $effectifs[$nom];
  foreach ($effectifs as $cle => $n):
    if (rtrim($cle, 's') === rtrim($nom, 's')) return $n;
  endforeach;
  return 0;
}

// PV courants des oppositions données : [opp_id => [rang => pv]].
function chargerPvOppositions(PDO $db, array $opp_ids): array {
  $opp_ids = array_values(array_filter(array_map('intval', $opp_ids)));
  if (!$opp_ids) return [];
  $marques = implode(',', array_fill(0, count($opp_ids), '?'));
  $stmt = $db->prepare("SELECT opv_opp_id, opv_rang, opv_pv FROM dd_oppositions_pv WHERE opv_opp_id IN ($marques)");
  $stmt->execute($opp_ids);
  $pv = [];
  foreach ($stmt->fetchAll() as $r) $pv[(int)$r['opv_opp_id']][(int)$r['opv_rang']] = (int)$r['opv_pv'];
  return $pv;
}

// Créatures d'une opposition, prêtes à rendre : effectif, PV max (colonne,
// ou lus dans les stats à défaut) et PV courants.
function creaturesOpposition(array $opp, array $pv_courants): array {
  $nombre = max(1, (int)($opp['opp_nombre'] ?? 1));
  $max    = (int)($opp['opp_pv_max'] ?? 0) ?: pvMaxDepuisStats($opp['opp_stats'] ?? '');
  $liste  = [];
  for ($rang = 1; $rang <= $nombre; $rang++):
    $liste[] = [
      'rang'  => $rang,
      'label' => $nombre > 1 ? $opp['opp_nom'] . ' ' . $rang : $opp['opp_nom'],
      'pv'    => $pv_courants[$rang] ?? $max,
      'max'   => $max,
    ];
  endfor;
  return $liste;
}

// Rendu d'une créature : nom, jauge, PV courants / max, champ de dégâts ou de
// soins. $avec_nom = false dans la fiche, où le nom de l'opposition est déjà
// en titre et où seul le numéro distingue les créatures.
function rendrePvCreature(int $opp_id, array $c, bool $avec_nom = true): string {
  $max   = (int)$c['max'];
  $pv    = (int)$c['pv'];
  $cle   = $opp_id . '-' . (int)$c['rang'];
  $label = $avec_nom ? $c['label'] : '#' . (int)$c['rang'];
  ob_start();
  if ($max <= 0): ?>
    <div class="camp-pv camp-pv--inconnu">
      <span class="camp-pv__nom"><?= h($label) ?></span>
      <span class="camp-pv__aide">PV max à saisir dans l'opposition</span>
    </div>
  <?php else:
    $pct = max(0, min(100, (int)round($pv * 100 / $max)));
    $etat = $pv <= 0 ? ' est-hors-combat' : ($pct <= 50 ? ' est-blesse' : ''); ?>
    <div class="camp-pv<?= $etat ?>" data-pv-cle="<?= h($cle) ?>"
         data-pv-opp="<?= $opp_id ?>" data-pv-rang="<?= (int)$c['rang'] ?>"
         data-pv="<?= $pv ?>" data-pv-max="<?= $max ?>">
      <span class="camp-pv__nom" title="<?= h($c['label']) ?>"><?= h($label) ?></span>
      <span class="camp-pv__jauge" aria-hidden="true"><span style="width:<?= $pct ?>%"></span></span>
      <span class="camp-pv__valeur"><b><?= $pv ?></b> / <?= $max ?></span>
      <input type="number" class="camp-pv__delta" min="0" max="9999" inputmode="numeric"
             placeholder="±" aria-label="PV à retirer ou à rendre — <?= h($c['label']) ?>">
      <button type="button" class="camp-pv__btn" data-pv-op="moins"
              title="Dégâts (Entrée)" aria-label="Infliger les dégâts"><i class="fa fa-minus"></i></button>
      <button type="button" class="camp-pv__btn" data-pv-op="plus"
              title="Soins" aria-label="Rendre les PV"><i class="fa fa-plus"></i></button>
    </div>
  <?php endif;
  return ob_get_clean();
}
