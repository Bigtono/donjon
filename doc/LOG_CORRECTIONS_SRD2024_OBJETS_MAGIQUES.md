<!-- Mis à jour : 2026-10-16 17:00 -->

# Journal des corrections — Objets magiques DD2024 (SRD 5.2.1), SP-PO5b

Sources : `FR_SRD_CC_v5.2.1-objets_magiques.pdf` (catalogue, 258 entrées) et
`FR_SRD_CC_v5.2.1-regles_objets_magiques.pdf` (règles, pages 215 à 220).
Migrations : `sql/2026-10-16_regles_dd2024_objets_magiques_sp-po5b.sql`,
`sql/2026-10-16_objets_dd2024_srd_sp-po5b.sql`. Méthode et pièges d'extraction : `ARCHITECTURE_0_REFERENCE.md` §9e.

## 1. État relevé avant import

Les 356 objets de la source « SRD 5.2.1 » portaient déjà, pour la plupart, le texte du SRD : au rapport mot à mot,
202 des 236 entrées comparées retrouvaient au moins 97 % du texte du PDF, les 34 autres étant des tableaux ou des fusions. Ce qui manquait n'était pas du résumé mais de la **structure** :

| Constat | Objets | Traitement |
|---|---|---|
| Tableau absent d'une déclinaison alors que le texte renvoie à « la table suivante » (anneau, armure, potion de résistance, ceinturon, cor du Valhalla, gemme élémentaire, parchemin de sort, plume magique, potions de guérison, potion de force de géant, sacs à malices, tapis volant, anneau de maîtrise élémentaire) | 73 | le tableau du SRD est saisi dans `dd_tableaux`, appelé par `[[tab:slug]]` |
| Tableau **aplati** en paragraphes (« Sort cône de froid mur de glace » / « Coût en charges » / « 5 4 »…) ou entièrement absent | 25 | remplacé par le tag du tableau |
| Paragraphes fusionnés ou coupés (voir §3) | 12 | reconstruits depuis le PDF |
| Traits d'union avalés (« Reportezvous », « ellemême », « Mortvivant ») | 3 occurrences | rétablis |
| « Yeux de lynx » absent de la base | 1 | ajouté |
| Texte déjà identique au PDF (titres en gras et paragraphes re-découpés au passage) | 244 | — |

## 2. Tableaux

34 nouveaux tableaux d'objets (`dd_tableaux`, ruleset DD2024, source SRD 5.2.1), 2 profils inclus au texte, 9 tableaux de
règles. Les 10 tableaux saisis en SP-IM9c (ids 43 à 52 en local) ont été **relus contre le PDF** : tous exacts, sauf la
ligne 96–00 du chapeau mille-sorts, tronquée (« Vous sortez un objet magique du chapeau. » sans la suite : table de rareté
1d6 et durée d'une heure) — corrigée. Ils sont réémis par la migration (upsert) pour que la production les ait aussi.

Regroupements retenus : les deux demi-tableaux côte à côte du PDF (bâtons, sacs à malices, projectile tueur, armure
d'écailles de dragon, types de dégâts) sont fusionnés en un seul ; « Sort / Coût en charges » partout, y compris pour le
bâton de guérison (« soins : 1 charge par niveau de sort (maximum 4 pour un sort du 4e niveau) »).

## 3. Corrections de contenu

| Objet | Constat | Correction |
|---|---|---|
| Armure d'invulnérabilité | texte de l'armure de cuir clouté enchantée collé à la suite (titre, ligne de type, paragraphe) | retiré |
| Armure de cuir clouté enchantée | titre de l'entrée suivante (armure de mailles elfique) collé à la fin | retiré |
| Figurine merveilleuse — Chèvre d'ivoire (voyageuse) | paragraphe commun fusionné avec la queue du texte de la chèvre terrifiante | reconstruit |
| Figurines — Chèvres d'ivoire (3) | paragraphe commun « Chèvres d'ivoire (rare) » absent | ajouté |
| Figurine — Lions d'or | phrase coupée en « …vous ne pouvez plus recourir à » | texte complet |
| Chapeau mille-sorts | titre « Focaliseur d'incantation » collé au paragraphe d'introduction ; « pas le biais » (coquille du SRD) → « par le biais » ; prérequis d'harmonisation (Magicien) absent | corrigés |
| Chapelet mystique, Baguette du mage de guerre +1 à +3 | prérequis d'harmonisation (Clerc, Druide ou Paladin / incantateur) absent | ajouté en tête, comme les autres objets |
| Tarot mystérieux | « L'effet de chaque carte est décrit ci-dessous. » collé au titre de La Balance ; profil de l'avatar de la Mort absent | séparé ; profil ajouté après Le Crâne |
| Figurine — Mouche d'ébène | profil de la mouche géante absent | ajouté |

Les profils (mouche géante, avatar de la Mort) reprennent le bloc du SRD en paragraphes et en un tableau de
caractéristiques ; ils ne créent pas d'entrée du bestiaire.

## 4. Normalisations

- Traits d'union rétablis : `Reportez-vous`, `elle-même`, `lui-même` (règles), `Mort-vivant`.
- Titres de capacité en gras (`<b>Titre.</b>`) de façon uniforme, y compris ceux qui avaient été collés au paragraphe précédent.
- Listes à puces du SRD (anneau d'influence animale, sceptre de vigilance, robe du camelot) : `<ul><li>`.
- Ligne « Harmonisation requise avec … » en tête, en italique, quand le SRD précise avec qui (déjà la convention de SP-IM9a).

## 5. Règles

Texte repris tel quel du PDF (près de 300 phrases et cellules recoupées avec l'extraction : aucune coquille, hormis les
tags et les titres de paragraphe que le SRD met en gras). Seule phrase ajoutée hors SRD : « Les objets du SRD sont listés
ci-dessous par catégorie ; chaque ligne ouvre la fiche de l'objet. » (page de A à Z). « 2000 po » (sans espace) est conservé
dans la règle de fabrication, comme dans le SRD.

## 6. À surveiller

- Les déclinaisons « Ceinturon de force de géant (givre) » et « (pierres) » sont deux lignes en base, alors que le SRD
  les réunit (« givre ou pierres », rareté très rare) : les deux affichent le même tableau, qui porte la mention du SRD.
- Les profils référencés « cf. Monstres » (créatures en gras dans le SRD) ne sont pas des liens : le catalogue de monstres
  n'est pas encore relié aux objets.
