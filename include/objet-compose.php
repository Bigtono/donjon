<?php
// include/objet-compose.php — Moteur de composition des objets magiques complexes DD3.5 (SP-PO7)
//
// Un objet « composé » n'est pas une entrée du compendium : il est fabriqué pour un personnage
// à partir de règles (D-PO19). Ce moteur est le SEUL endroit où ces règles sont calculées :
// l'aperçu du compositeur (include/ajax/possession-calcul.php), l'enregistrement d'une possession
// et la fiche d'un objet à sort lié (include/ajax/detail-pp/objet.php) passent tous par lui.
// Le JS n'en recalcule rien.
//
// ENTRÉE   une « spec » (tableau), construite par composeSpecDepuisPost() ou à la main :
//   cat          arme | armure | bouclier | potion | huile | baguette | parchemin
//   eqt_id       objet de base (arme, armure, bouclier) — dd_equipements
//   bonus        bonus d'altération de 0 à 5 (tête 1 d'une arme double)
//   bonus_tete2  bonus de la tête 2 d'une arme double (0 à 5, null hors arme double)
//   proprietes   [ ['om_id' => int, 'tete' => 1|2, 'parametre' => string], … ]
//   sorts        [ ['so_id' => int, 'cla_id' => int, 'nls' => int|null,
//                   'suppl_pc' => int, 'suppl_px' => int], … ]   (nls null = NLS minimum)
//
// SORTIE   composerObjet() renvoie :
//   ok, erreurs[], avertissements[], cat, nom, quantite, charges, maitre, bonus, bonus_tete2,
//   nls, prix_pc, cout_pc, cout_px, details[] (décomposition du prix : libelle, pc),
//   elements[] (lignes prêtes pour dd_personnages_possessions_elements)
//
// Les contraintes de règle sont BLOQUANTES (D-PO20) : ok = false dès qu'une erreur subsiste,
// mais le prix est tout de même calculé sur ce qui est valide, pour l'aperçu.
//
// Montants internes en pièces de cuivre (1 po = 100 pc), comme dd_equipements.
// Références par SLUG ou par NOM, jamais par id : les ids diffèrent entre le local et OVH.
//
// Règles : DRS 23 (coûts de création), DRS 24 (armes), DRS 25 (armures, baguettes),
// DRS 27 (parchemins, potions). Détail : doc/ARCHITECTURE_0_REFERENCE.md §7.10.

require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/liste-parser.php';

define('OC_RULESET', 1);                                 // DD3.5 uniquement
define('OC_BONUS_MAX', 5);                               // altération
define('OC_TOTAL_MAX', 10);                              // altération + équivalences
define('OC_MAITRE_ARME_PC', 30000);                      // 300 po
define('OC_MAITRE_ARME_DOUBLE_PC', 60000);               // 600 po
define('OC_MAITRE_ARMURE_PC', 15000);                    // 150 po
define('OC_MAITRE_MUNITION_PC', 600);                    // 6 po pièce
define('OC_MUNITIONS_LOT', 50);                          // les munitions magiques se créent par 50
define('OC_CAT_PROP_ARME', 'proprietes-speciales-des-armes');
define('OC_CAT_PROP_ARMURE', 'proprietes-speciales-des-armures');

// Catégories du compositeur → libellé
function composeCategories(): array {
  return [
    'arme'      => 'Arme',
    'armure'    => 'Armure',
    'bouclier'  => 'Bouclier',
    'potion'    => 'Potion',
    'huile'     => 'Huile',
    'baguette'  => 'Baguette',
    'parchemin' => 'Parchemin',
  ];
}

// Paramètres par catégorie de consommable :
//   mult    multiplicateur du prix de base (× niveau du sort × NLS, en po)
//   comp    multiplicateur des composantes coûteuses (po et PX)
//   niv_max niveau de sort maximal ; nb_min / nb_max : nombre de sorts
function composeConsommables(): array {
  return [
    'potion'    => ['mult' => 50,  'comp' => 1,  'niv_max' => 3, 'nb_min' => 1, 'nb_max' => 1, 'libelle' => 'Potion'],
    'huile'     => ['mult' => 50,  'comp' => 1,  'niv_max' => 3, 'nb_min' => 1, 'nb_max' => 1, 'libelle' => 'Huile'],
    'baguette'  => ['mult' => 750, 'comp' => 50, 'niv_max' => 4, 'nb_min' => 1, 'nb_max' => 1, 'libelle' => 'Baguette'],
    'parchemin' => ['mult' => 25,  'comp' => 1,  'niv_max' => 9, 'nb_min' => 1, 'nb_max' => 6, 'libelle' => 'Parchemin'],
  ];
}

// ============================================================
// 1. LECTURE D'UNE SPEC DEPUIS UN FORMULAIRE
// ============================================================

// Champs POST : cat, eqt_id, bonus, bonus_tete2,
//   prop_om[], prop_tete[], prop_param[]   (propriétés, tableaux parallèles)
//   sort_so[], sort_cla[], sort_nls[], sort_suppl_po[], sort_suppl_px[]   (sorts)
// Les composantes sont saisies en po (décimales admises) et converties en pc.
function composeSpecDepuisPost(array $post): array
{
  $entier = fn($v): int => (is_numeric($v) ? (int)$v : 0);
  $liste  = fn(string $k): array => is_array($post[$k] ?? null) ? array_values($post[$k]) : [];

  $spec = [
    'cat'         => (string)($post['cat'] ?? ''),
    'eqt_id'      => $entier($post['eqt_id'] ?? 0),
    'bonus'       => $entier($post['bonus'] ?? 0),
    'bonus_tete2' => ($post['bonus_tete2'] ?? '') === '' ? null : $entier($post['bonus_tete2']),
    'proprietes'  => [],
    'sorts'       => [],
  ];

  $om = $liste('prop_om'); $tete = $liste('prop_tete'); $param = $liste('prop_param');
  foreach ($om as $i => $id):
    if ($entier($id) <= 0) continue;
    $spec['proprietes'][] = [
      'om_id'     => $entier($id),
      'tete'      => $entier($tete[$i] ?? 1) === 2 ? 2 : 1,
      'parametre' => mb_substr(trim((string)($param[$i] ?? '')), 0, 150),
    ];
  endforeach;

  $so = $liste('sort_so'); $cla = $liste('sort_cla'); $nls = $liste('sort_nls');
  $po = $liste('sort_suppl_po'); $px = $liste('sort_suppl_px');
  foreach ($so as $i => $id):
    if ($entier($id) <= 0) continue;
    $suppl_po = str_replace([' ', ','], ['', '.'], (string)($po[$i] ?? ''));
    $spec['sorts'][] = [
      'so_id'    => $entier($id),
      'cla_id'   => $entier($cla[$i] ?? 0),
      'nls'      => ($nls[$i] ?? '') === '' ? null : $entier($nls[$i]),
      'suppl_pc' => is_numeric($suppl_po) ? (int)round((float)$suppl_po * 100) : 0,
      'suppl_px' => $entier($px[$i] ?? 0),
    ];
  endforeach;

  return $spec;
}

// ============================================================
// 2. POINT D'ENTRÉE
// ============================================================

function composerObjet(PDO $db, array $spec): array
{
  $cat = (string)($spec['cat'] ?? '');
  if (in_array($cat, ['arme', 'armure', 'bouclier'], true)) return composerArmeArmure($db, $spec);
  if (isset(composeConsommables()[$cat]))                   return composerConsommable($db, $spec);

  $r = composeResultatVide($cat);
  $r['erreurs'][] = 'Type d\'objet inconnu.';
  return $r;
}

function composeResultatVide(string $cat): array
{
  return [
    'ok' => false, 'erreurs' => [], 'avertissements' => [], 'cat' => $cat, 'nom' => '',
    'quantite' => 1, 'charges' => null, 'maitre' => 0, 'bonus' => null, 'bonus_tete2' => null,
    'nls' => null, 'prix_pc' => 0, 'cout_pc' => 0, 'cout_px' => 0, 'details' => [], 'elements' => [],
  ];
}

// Arrondi du coût en PX et des moitiés de pc : demi-unité vers le haut.
function composeArrondi(float $v): int
{
  return (int)round($v, 0, PHP_ROUND_HALF_UP);
}

// Coût de création de la partie magique : prix / 2 en po, prix / 25 en PX (DRS 23).
function composeCoutMagique(int $magie_pc): array
{
  return [composeArrondi($magie_pc / 2), composeArrondi($magie_pc / 100 / 25)];
}

// ============================================================
// 3. ARMES, ARMURES, BOUCLIERS
// ============================================================

// Objet de base : ligne dd_equipements + rôle déduit de sa famille.
//   role        arme | armure | bouclier | null (famille non enchantable)
//   emploi[]    jetons d'emploi satisfaits (cac, distance, jet, armure, bouclier, ecu)
//   degats[]    jetons de dégâts satisfaits (tranchant, perforant, contondant)
//   double      arme double
//   munition    lot de munitions (« Carreaux (10) ») ; lot = taille du lot vendu
function composeObjetBase(PDO $db, int $eqt_id): ?array
{
  $stmt = $db->prepare('
    SELECT eqt.*, cae.cae_slug
    FROM   dd_equipements eqt
    JOIN   dd_categorie_equipement cae ON cae.cae_id = eqt.eqt_cae_id
    WHERE  eqt.eqt_id = ? AND eqt.eqt_ruleset_var_id = ?
  ');
  $stmt->execute([$eqt_id, OC_RULESET]);
  $eqt = $stmt->fetch();
  return $eqt ? composeObjetBaseDepuisLigne($db, $eqt) : null;
}

// Même analyse sur une ligne déjà lue (dd_equipements.* + cae_slug) : le compositeur
// l'applique à toute la liste des objets de base sans une requête par article.
function composeObjetBaseDepuisLigne(PDO $db, array $eqt): array
{
  // Racine de la famille (armes / armures-et-boucliers), en remontant l'arbre
  $arbre = catEquipementArbre($db, OC_RULESET);
  $id = (int)$eqt['eqt_cae_id'];
  $racine = null;
  for ($i = 0; $i < 6 && isset($arbre['noeuds'][$id]); $i++):
    $racine = $arbre['noeuds'][$id]['cae_slug'];
    $id = (int)$arbre['noeuds'][$id]['cae_cae_id'];
  endfor;

  $slug  = $eqt['cae_slug'];
  $attrs = equipementAttributs($eqt);
  $nom   = (string)$eqt['eqt_nom'];
  $base  = [
    'eqt' => $eqt, 'nom' => $nom, 'role' => null, 'emploi' => [], 'degats' => [],
    'double' => false, 'munition' => false, 'lot' => 1,
    'prix_pc' => $eqt['eqt_prix_pc'] !== null ? (int)$eqt['eqt_prix_pc'] : 0,
  ];

  if ($racine === 'armes'):
    // Une arme sans prix ni texte de prix (attaque à mains nues) n'est pas un objet
    if ($eqt['eqt_prix_pc'] === null && trim((string)$eqt['eqt_prix_txt']) === '' && $slug === 'armes-courantes-mains-nues') return $base;
    $base['role'] = 'arme';
    $type = mb_strtolower((string)($attrs['type'] ?? ''));
    foreach (['tranchant', 'perforant', 'contondant'] as $d):
      if (mb_strpos($type, $d) !== false) $base['degats'][] = $d;
    endforeach;
    $base['double'] = mb_stripos((string)($attrs['part'] ?? ''), 'arme double') !== false;
    $portee = trim((string)($attrs['portee'] ?? ''));
    $a_portee = $portee !== '' && $portee !== '—';
    if (str_ends_with($slug, '-distance')):
      $base['emploi'][] = 'distance';
      if (preg_match('/\((\d+)\)\s*$/u', $nom, $m)):
        // Lot de munitions vendu par N : prix à l'unité, enchanté par 50
        $base['munition'] = true;
        $base['lot'] = max(1, (int)$m[1]);
        $base['nom'] = trim(preg_replace('/\s*\(\d+\)\s*$/u', '', $nom));
      elseif ($a_portee && !preg_match('/^(arc|arbalète|fronde|sarbacane)/iu', $nom)):
        $base['emploi'][] = 'jet';                     // dard, javeline, bolas, filet…
      endif;
    else:
      $base['emploi'][] = 'cac';
      // Arme de corps à corps lançable (dague, épieu…) : peut recevoir les propriétés de jet et à distance
      if ($a_portee) array_push($base['emploi'], 'jet', 'distance');
    endif;
  elseif ($racine === 'armures-et-boucliers'):
    if (in_array($slug, ['armures-legeres', 'armures-intermediaires', 'armures-lourdes'], true)):
      $base['role'] = 'armure';
      $base['emploi'][] = 'armure';
    elseif ($slug === 'boucliers'):
      $base['role'] = 'bouclier';
      $base['emploi'][] = 'bouclier';
      if (preg_match('/^(écu|rondache)/iu', $nom)) $base['emploi'][] = 'ecu';
    endif;
  endif;

  return $base;
}

// Propriétés spéciales demandées, lues en base (catégorie de propriétés du bon type, DD3.5)
function composeProprietesLire(PDO $db, array $om_ids, string $cat_slug): array
{
  $om_ids = array_values(array_unique(array_filter(array_map('intval', $om_ids))));
  if (empty($om_ids)) return [];
  $ph = implode(',', array_fill(0, count($om_ids), '?'));
  $stmt = $db->prepare("
    SELECT om.om_id, om.om_nom, om.om_bonus_equiv, om.om_prix, om.om_nls, om.om_restriction
    FROM   dd_objets_magiques om
    JOIN   dd_categorie_objet_magique com ON com.com_id = om.om_com_id
    WHERE  om.om_id IN ($ph)
      AND  om.om_ruleset_var_id = ?
      AND  com.com_slug = ?
      AND  com.com_est_propriete = 1
  ");
  $stmt->execute(array_merge($om_ids, [OC_RULESET, $cat_slug]));
  $res = [];
  foreach ($stmt->fetchAll() as $p) $res[(int)$p['om_id']] = $p;
  return $res;
}

// Famille d'une propriété : deux propriétés de même famille ne se cumulent pas
// (Feu / Feu intense, Défense légère / lourde, Résistance au feu / … supérieure…).
function composeProprieteFamille(string $nom): string
{
  $n = mb_strtolower(trim($nom));
  $n = preg_replace('/\s*\(\d+\)$/u', '', $n);
  $n = preg_replace('/\s+(intense|supérieure?|suprême|légère|intermédiaire|lourde)$/u', '', $n);
  return $n;
}

// Contrôle des restrictions d'une propriété contre l'objet de base. Retour : message ou null.
function composeRestrictionErreur(array $prop, array $base): ?string
{
  $jetons = preg_split('/\s+/', (string)$prop['om_restriction'], -1, PREG_SPLIT_NO_EMPTY);
  if (empty($jetons)) return null;
  $libelles = proprieteRestrictionsJetons();

  $emploi = array_values(array_intersect($jetons, array_keys($libelles['emploi'])));
  if ($emploi && !array_intersect($emploi, $base['emploi'])):
    $txt = array_map(fn($j) => mb_strtolower($libelles['emploi'][$j]), $emploi);
    return $prop['om_nom'] . ' : réservée à : ' . implode(' ou ', $txt) . '.';
  endif;

  $degats = array_values(array_intersect($jetons, array_keys($libelles['degats'])));
  if ($degats && !array_intersect($degats, $base['degats'])):
    $txt = array_map(fn($j) => mb_strtolower($libelles['degats'][$j]), $degats);
    return $prop['om_nom'] . ' : exige une arme ' . implode(' ou ', $txt) . '.';
  endif;

  return null;
}

function composerArmeArmure(PDO $db, array $spec): array
{
  $cat = $spec['cat'];
  $r = composeResultatVide($cat);
  $r['maitre'] = 1;

  $base = composeObjetBase($db, (int)($spec['eqt_id'] ?? 0));
  if (!$base):
    $r['erreurs'][] = 'Choisissez l\'objet de base.';
    return $r;
  endif;
  if ($base['role'] !== $cat):
    $r['erreurs'][] = $base['nom'] . ' n\'est pas un objet de type « ' . mb_strtolower(composeCategories()[$cat]) . ' » enchantable.';
    return $r;
  endif;

  $double = $cat === 'arme' && $base['double'];
  $tetes  = $double ? [1, 2] : [1];
  $bonus  = [1 => (int)($spec['bonus'] ?? 0), 2 => $double ? (int)($spec['bonus_tete2'] ?? 0) : 0];
  foreach ($tetes as $t):
    if ($bonus[$t] < 0 || $bonus[$t] > OC_BONUS_MAX):
      $r['erreurs'][] = 'Le bonus d\'altération va de +0 à +' . OC_BONUS_MAX . '.';
      $bonus[$t] = max(0, min(OC_BONUS_MAX, $bonus[$t]));
    endif;
  endforeach;
  $r['bonus'] = $bonus[1];
  $r['bonus_tete2'] = $double ? $bonus[2] : null;

  // Propriétés
  $cat_prop = $cat === 'arme' ? OC_CAT_PROP_ARME : OC_CAT_PROP_ARMURE;
  $demandes = $spec['proprietes'] ?? [];
  $connues  = composeProprietesLire($db, array_column($demandes, 'om_id'), $cat_prop);
  $equiv    = [1 => 0, 2 => 0];
  $fixe_pc  = [1 => 0, 2 => 0];
  $nls_prop = 0;
  $familles = [1 => [], 2 => []];
  $par_tete = [1 => [], 2 => []];
  foreach ($demandes as $i => $d):
    $d['parametre'] = trim((string)($d['parametre'] ?? ''));
    $t = $double && (int)($d['tete'] ?? 1) === 2 ? 2 : 1;
    $p = $connues[(int)$d['om_id']] ?? null;
    if (!$p):
      $r['erreurs'][] = 'Propriété inconnue ou inadaptée à ce type d\'objet.';
      continue;
    endif;
    $fam = composeProprieteFamille($p['om_nom']);
    if (isset($familles[$t][$fam])):
      $r['erreurs'][] = $p['om_nom'] . ' : ne se cumule pas avec ' . $familles[$t][$fam] . '.';
      continue;
    endif;
    $familles[$t][$fam] = $p['om_nom'];
    if ($err = composeRestrictionErreur($p, $base)) $r['erreurs'][] = $err;
    if ($p['om_bonus_equiv'] === null && $p['om_prix'] === null):
      $r['erreurs'][] = $p['om_nom'] . ' : ni équivalence ni prix renseigné au compendium.';
    endif;
    $equiv[$t]   += (int)$p['om_bonus_equiv'];
    $fixe_pc[$t] += $p['om_bonus_equiv'] === null ? (int)$p['om_prix'] * 100 : 0;
    $nls_prop     = max($nls_prop, (int)$p['om_nls']);
    $par_tete[$t][] = $p['om_nom'] . ($d['parametre'] !== '' ? ' [' . $d['parametre'] . ']' : '');
    $r['elements'][] = [
      'ppe_type' => 'propriete', 'ppe_tete' => $t, 'ppe_om_id' => (int)$p['om_id'],
      'ppe_so_id' => null, 'ppe_cla_id' => null, 'ppe_niveau' => null,
      'ppe_nls' => $p['om_nls'] !== null ? (int)$p['om_nls'] : null,
      'ppe_parametre' => $d['parametre'] !== '' ? $d['parametre'] : null,
      'ppe_suppl_pc' => 0, 'ppe_suppl_px' => 0, 'ppe_ordre' => $i,
      'libelle' => $p['om_nom'],
    ];
  endforeach;

  // Plafonds, tête par tête
  foreach ($tetes as $t):
    $lib_tete = $double ? ' (tête ' . $t . ')' : '';
    if (($equiv[$t] > 0 || $fixe_pc[$t] > 0) && $bonus[$t] < 1):
      $r['erreurs'][] = 'Une propriété spéciale exige un bonus d\'altération d\'au moins +1' . $lib_tete . '.';
    endif;
    if ($bonus[$t] + $equiv[$t] > OC_TOTAL_MAX):
      $r['erreurs'][] = 'Bonus total de +' . ($bonus[$t] + $equiv[$t]) . $lib_tete . ' : le maximum est +' . OC_TOTAL_MAX . '.';
    endif;
  endforeach;

  // Prix (DRS 24 / 25) : base + maître + (bonus effectif)² × 2 000 po (arme) ou 1 000 po (armure) + prix fixes
  $lot     = $base['munition'] ? OC_MUNITIONS_LOT : 1;
  $base_pc = $base['munition'] ? composeArrondi($base['prix_pc'] / $base['lot'] * $lot) : $base['prix_pc'];
  if ($cat === 'arme'):
    $maitre_pc = $base['munition'] ? OC_MAITRE_MUNITION_PC * $lot : ($double ? OC_MAITRE_ARME_DOUBLE_PC : OC_MAITRE_ARME_PC);
    $facteur = 200000;                                  // 2 000 po
  else:
    $maitre_pc = OC_MAITRE_ARMURE_PC;
    $facteur = 100000;                                  // 1 000 po
  endif;

  $r['details'][] = ['libelle' => $base['nom'] . ($lot > 1 ? ' (× ' . $lot . ')' : ''), 'pc' => $base_pc];
  $r['details'][] = ['libelle' => 'Qualité de maître', 'pc' => $maitre_pc];
  $magie_pc = 0;
  foreach ($tetes as $t):
    $effectif = $bonus[$t] + $equiv[$t];
    $lib_tete = $double ? ' — tête ' . $t : '';
    if ($effectif > 0):
      $pc = $effectif * $effectif * $facteur;
      $lib = 'Bonus +' . $bonus[$t] . ($equiv[$t] ? ' et équivalences +' . $equiv[$t] . ' (effectif +' . $effectif . ')' : '');
      $r['details'][] = ['libelle' => $lib . $lib_tete, 'pc' => $pc];
      $magie_pc += $pc;
    endif;
    if ($fixe_pc[$t] > 0):
      $r['details'][] = ['libelle' => 'Propriétés à prix fixe' . $lib_tete, 'pc' => $fixe_pc[$t]];
      $magie_pc += $fixe_pc[$t];
    endif;
  endforeach;

  [$cout_magie, $px] = composeCoutMagique($magie_pc);
  $r['prix_pc']  = $base_pc + $maitre_pc + $magie_pc;
  $r['cout_pc']  = $base_pc + $maitre_pc + $cout_magie;
  $r['cout_px']  = $px;
  $r['quantite'] = $lot;
  // NLS : 3 × bonus d'altération, ou celui de la propriété la plus exigeante (DRS 24)
  $nls = max(3 * max($bonus[1], $bonus[2]), $nls_prop);
  $r['nls'] = $nls > 0 ? $nls : null;

  // Nom : « Épée longue +2 (acérée, feu) », « Double-lame +2/+1 (tête 1 : … ; tête 2 : …) »
  $min = fn(array $l): string => implode(', ', array_map(fn($x) => mb_strtolower(mb_substr($x, 0, 1)) . mb_substr($x, 1), $l));
  if ($magie_pc === 0):
    $nom = $base['nom'] . ' de maître';
  elseif ($double):
    $nom = $base['nom'] . ' +' . $bonus[1] . '/+' . $bonus[2];
    $parts = [];
    foreach ($tetes as $t):
      if ($par_tete[$t]) $parts[] = 'tête ' . $t . ' : ' . $min($par_tete[$t]);
    endforeach;
    $nom .= $parts ? ' (' . implode(' ; ', $parts) . ')' : '';
  else:
    $nom = $base['nom'] . ' +' . $bonus[1] . ($par_tete[1] ? ' (' . $min($par_tete[1]) . ')' : '');
  endif;
  $r['nom'] = $nom;

  if ($base['munition']) $r['avertissements'][] = 'Munitions : prix et quantité pour un lot de ' . OC_MUNITIONS_LOT . '.';
  $r['ok'] = empty($r['erreurs']);
  return $r;
}

// ============================================================
// 4. POTIONS, HUILES, BAGUETTES, PARCHEMINS
// ============================================================

// Classes dont le NLS vaut la moitié du niveau de classe (DRS 03 : paladin, rôdeur).
function composeDemiLanceurs(): array
{
  return ['paladin', 'rôdeur'];
}

// NLS minimum pour lancer un sort de niveau $niveau dans la liste de $cla_id :
// premier niveau de classe disposant d'emplacements de ce niveau (dd_classe_niveau, 0 compris),
// divisé par deux pour un demi-lanceur. Repli si la progression est absente : 2n − 1.
function nlsMinimum(PDO $db, int $cla_id, int $niveau): int
{
  static $cache = [];
  $cle = $cla_id . ':' . $niveau;
  if (isset($cache[$cle])) return $cache[$cle];

  $niveau = max(0, min(9, $niveau));
  $col = 'cn_sort_n' . $niveau;                          // nom de colonne construit sur un entier borné
  $stmt = $db->prepare("SELECT MIN(cn_niveau) FROM dd_classe_niveau WHERE cn_cla_id = ? AND $col IS NOT NULL");
  $stmt->execute([$cla_id]);
  $niv_classe = $stmt->fetchColumn();

  if ($niv_classe === null || $niv_classe === false):
    $nls = max(1, 2 * $niveau - 1);
  else:
    $stmt = $db->prepare('SELECT cla_nom FROM dd_classes WHERE cla_id = ?');
    $stmt->execute([$cla_id]);
    $demi = in_array(mb_strtolower(trim((string)$stmt->fetchColumn())), composeDemiLanceurs(), true);
    $nls  = max(1, $demi ? intdiv((int)$niv_classe, 2) : (int)$niv_classe);
  endif;

  return $cache[$cle] = $nls;
}

// Listes de classe où figure un sort DD3.5 : [ ['cla_id','cla_nom','niveau','mag_id','nls_min'], … ]
// triées par niveau puis NLS minimum (la plus avantageuse d'abord).
function sortListesClasses(PDO $db, int $so_id): array
{
  $stmt = $db->prepare('
    SELECT sc.sc_cla_id AS cla_id, cla.cla_nom, sc.sc_niveau AS niveau, cla.cla_mag_id AS mag_id
    FROM   dd_sortclasse sc
    JOIN   dd_classes cla ON cla.cla_id = sc.sc_cla_id
    JOIN   dd_sorts   so  ON so.so_id   = sc.sc_so_id
    WHERE  sc.sc_so_id = ? AND so.so_ruleset_var_id = ? AND cla.cla_ruleset_var_id = ?
  ');
  $stmt->execute([$so_id, OC_RULESET, OC_RULESET]);
  $res = [];
  foreach ($stmt->fetchAll() as $l):
    $l['cla_id']  = (int)$l['cla_id'];
    $l['niveau']  = (int)$l['niveau'];
    $l['mag_id']  = (int)$l['mag_id'];
    $l['nls_min'] = nlsMinimum($db, $l['cla_id'], $l['niveau']);
    $res[] = $l;
  endforeach;
  usort($res, fn($a, $b) => [$a['niveau'], $a['nls_min'], $a['cla_nom']] <=> [$b['niveau'], $b['nls_min'], $b['cla_nom']]);
  return $res;
}

// « de » ou « d' » devant un nom
function composeDe(string $nom): string
{
  return preg_match('/^[aeiouyhàâéèêëîïôöûüœ]/iu', $nom) ? 'd\'' . $nom : 'de ' . $nom;
}

function composerConsommable(PDO $db, array $spec): array
{
  $cat  = $spec['cat'];
  $regl = composeConsommables()[$cat];
  $r    = composeResultatVide($cat);
  if ($cat === 'baguette') $r['charges'] = 50;

  $sorts = array_values($spec['sorts'] ?? []);
  if (count($sorts) < $regl['nb_min']):
    $r['erreurs'][] = 'Choisissez un sort.';
    return $r;
  endif;
  if (count($sorts) > $regl['nb_max']):
    $r['erreurs'][] = $regl['nb_max'] === 1
      ? $regl['libelle'] . ' : un seul sort.'
      : $regl['libelle'] . ' : ' . $regl['nb_max'] . ' sorts au maximum.';
    $sorts = array_slice($sorts, 0, $regl['nb_max']);
  endif;

  $stmt_so = $db->prepare('SELECT so_id, so_nom FROM dd_sorts WHERE so_id = ? AND so_ruleset_var_id = ?');
  $mag_ids = [];
  $nls_max = 0;
  $base_total = 0;
  $noms = [];
  foreach ($sorts as $i => $s):
    $stmt_so->execute([(int)$s['so_id'], OC_RULESET]);
    $so = $stmt_so->fetch();
    if (!$so):
      $r['erreurs'][] = 'Sort inconnu.';
      continue;
    endif;
    $listes = sortListesClasses($db, (int)$so['so_id']);
    if (empty($listes)):
      $r['erreurs'][] = $so['so_nom'] . ' : ce sort n\'appartient à aucune liste de classe.';
      continue;
    endif;
    // Liste choisie, ou la plus avantageuse
    $liste = $listes[0];
    if ((int)($s['cla_id'] ?? 0) > 0):
      $choix = array_values(array_filter($listes, fn($l) => $l['cla_id'] === (int)$s['cla_id']));
      if ($choix):
        $liste = $choix[0];
      else:
        $r['erreurs'][] = $so['so_nom'] . ' : ce sort n\'est pas dans la liste de cette classe.';
      endif;
    endif;
    $niv = $liste['niveau'];
    if ($niv > $regl['niv_max']):
      $r['erreurs'][] = $so['so_nom'] . ' : sort de niveau ' . $niv . ' (' . $liste['cla_nom'] . '), le maximum pour cet objet est ' . $regl['niv_max'] . '.';
    endif;
    $nls = $s['nls'] === null ? $liste['nls_min'] : (int)$s['nls'];
    if ($nls < $liste['nls_min']):
      $r['erreurs'][] = $so['so_nom'] . ' : NLS ' . $nls . ' trop bas, le minimum est ' . $liste['nls_min'] . ' (' . $liste['cla_nom'] . ').';
      $nls = $liste['nls_min'];
    endif;
    if ($nls > 20):
      $r['erreurs'][] = $so['so_nom'] . ' : NLS ' . $nls . ', le maximum est 20.';
      $nls = 20;
    endif;
    $mag_ids[$liste['mag_id']] = true;
    $nls_max = max($nls_max, $nls);

    // Prix de base : multiplicateur × niveau (un sort de niveau 0 compte 1/2) × NLS, en po → pc
    $base_pc = ($niv === 0 ? 50 : $niv * 100) * $nls * $regl['mult'];
    $suppl_pc = max(0, (int)($s['suppl_pc'] ?? 0));
    $suppl_px = max(0, (int)($s['suppl_px'] ?? 0));
    $comp_pc  = $regl['comp'] * ($suppl_pc + $suppl_px * 500);  // 1 PX = 5 po au prix de vente
    $base_total += $base_pc;
    $r['prix_pc'] += $base_pc + $comp_pc;
    $r['cout_pc'] += composeArrondi($base_pc / 2) + $regl['comp'] * $suppl_pc;
    $r['cout_px'] += $regl['comp'] * $suppl_px;

    $lib = $so['so_nom'] . ' (niveau ' . $niv . ' ' . $liste['cla_nom'] . ', NLS ' . $nls . ')';
    $r['details'][] = ['libelle' => $lib, 'pc' => $base_pc];
    if ($comp_pc > 0):
      $r['details'][] = ['libelle' => 'Composantes coûteuses' . ($regl['comp'] > 1 ? ' (× ' . $regl['comp'] . ')' : '') . ' — ' . $so['so_nom'], 'pc' => $comp_pc];
    endif;
    $noms[] = $so['so_nom'];
    $r['elements'][] = [
      'ppe_type' => 'sort', 'ppe_tete' => 1, 'ppe_om_id' => null,
      'ppe_so_id' => (int)$so['so_id'], 'ppe_cla_id' => $liste['cla_id'], 'ppe_niveau' => $niv,
      'ppe_nls' => $nls, 'ppe_parametre' => null,
      'ppe_suppl_pc' => $suppl_pc, 'ppe_suppl_px' => $suppl_px, 'ppe_ordre' => $i,
      'libelle' => $so['so_nom'], 'nls_min' => $liste['nls_min'],
    ];
  endforeach;

  // Un parchemin est profane ou divin, pas les deux (DRS 27)
  if ($cat === 'parchemin' && count($mag_ids) > 1):
    $r['erreurs'][] = 'Un parchemin ne mélange pas sorts profanes et divins.';
  endif;

  // PX de la partie de base : prix de base / 25 (les PX des composantes sont ajoutés plus haut)
  $r['cout_px'] += composeArrondi($base_total / 100 / 25);
  $r['nls'] = $nls_max ?: null;

  if ($cat === 'parchemin' && count($noms) > 1):
    $type = isset($mag_ids[2]) && !isset($mag_ids[1]) ? 'divin' : 'profane';
    $r['nom'] = 'Parchemin ' . $type . ' (' . count($noms) . ' sorts)';
  elseif ($noms):
    $r['nom'] = $regl['libelle'] . ' ' . composeDe(mb_strtolower(mb_substr($noms[0], 0, 1)) . mb_substr($noms[0], 1)) . ' (NLS ' . $nls_max . ')';
  endif;

  $r['ok'] = empty($r['erreurs']);
  return $r;
}
