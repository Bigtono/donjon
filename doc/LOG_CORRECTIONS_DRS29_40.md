<!-- Mis à jour : 2026-11-07 19:00 -->

# Journal des corrections — import du DRS 29 à 40 (les monstres)

> Le texte du DRS est repris tel quel **sauf** les corrections de coquilles évidentes et les
> réparations d'extraction listées ici, pour relecture ultérieure (même principe que
> `LOG_CORRECTIONS_DRS04.md`). PDF sources : `DRS 29` à `DRS 40`
> (`C:\Users\jm-ml\OneDrive\Documents\JDR\D&D\DD 3.5\SRD\`).
>
> Quatre migrations portent ce texte :
> - `sql/2026-11-08_sp-drs9a_regles_dd35_monstres.sql` — **DRS 29 à 32**, les règles (chapitre
>   « Les monstres » de la racine « Créatures et pouvoirs spéciaux ») ;
> - `sql/2026-11-08_sp-drs9b_dons_monstres_dd35.sql` — **DRS 31**, les 4 dons absents du compendium ;
> - `sql/2026-11-08_sp-drs9c_archetypes_dd35.sql` — **DRS 35 à 40**, les 8 archétypes (compendium Races) ;
> - la migration des fiches (`sql/2026-11-08_sp-mo7c_monstres_drs_dd35.sql`, SP-MO7c), générée par `tools/generer-sp-mo7-monstres-drs.php` — **DRS 33 à 40**.

## 1. Normalisations globales

| # | Source | Traitement |
|---|---|---|
| G1 | Apostrophes typographiques `’` | remplacées par `'` (comme les lots DRS précédents) |
| G2 | Profils à plusieurs colonnes (variantes de taille, d'âge, de forme) | **une fiche par colonne** (D-MO6) ; le texte commun suit chaque fiche |
| G3 | Exposant « S » des dons supplémentaires, collé au nom par l'extraction (« Attaque en finesseS ») | « Attaque en finesse (S) » — 84 occurrences, dans les lignes « Dons » seulement |
| G4 | Puces du PDF (caractère privé U+F0B7) dans les traits raciaux des « Personnages … » | ligne « • … » ; une puce coupée par la mise en page est recollée |
| G5 | Tables d'âge des dragons, tables de taille des élémentaires, tables des archétypes | **ressaisies à la main** : en-têtes sur deux niveaux et cellules coupées sur plusieurs lignes, illisibles en extraction |
| G6 | Notes de bas de table (« 1 L'allonge de la morsure… ») | reprises en note du tableau (`>`) et retirées du texte |

## 2. Coquilles corrigées — règles (DRS 29 à 32)

| # | Où | Texte du PDF | Correction |
|---|---|---|---|
| R1 | Archétypes › Dégâts (DRS 30) | « elle ajoute 1,5 fois son **bons** de Force » | « son **bonus** de Force » |
| R2 | Augmentation des dés de vie, note de la table des compétences (DRS 30) | « la créature **à** une Intelligence de 1 » | « la créature **a** une Intelligence » |
| R3 | Archétypes acquis et hérités (DRS 30) | « Les créatures naissent **dotés** » | « naissent **dotées** » |
| R4 | Personnages monstrueux (DRS 32) | « Le profil des **monstre** détaille… d'une **créatures** moyenne » | « des **monstres** … d'une **créature** moyenne » |

## 3. Coquilles corrigées — fiches et archétypes (DRS 33 à 40)

| # | Où | Texte du PDF | Correction |
|---|---|---|---|
| F1 | Méphite salin (DRS 37) | libellé « **Ajustement possible** » | « Ajustement de niveau » |
| F2 | Catégories d'âge des dragons (DRS 36) | « Vieux **401–800** » (recouvre « Très vieux 601–800 ») | « Vieux **401–600** » |
| F3 | Attaques des dragons (DRS 36) | colonne « 1 **renversement** » | « 1 **écrasement** », nom de l'attaque décrite juste au-dessus |
| F4 | Soldat formien (DRS 37) | « **:** Attaques spéciales : venin » (deux-points orphelin) | « Attaques spéciales : venin » |
| F5 | Sanglier-garou sanguinaire, forme hybride (DRS 38) | « Géant (métamorphe)**de** taille G » | « Géant (métamorphe) de taille G » |
| F6 | Lycanthropes courants (DRS 38) | « Sanglier **sanguianire** », « **Nuetre** » | « Sanglier sanguinaire », « Neutre » |
| F7 | Squelette et zombi (DRS 39, 40) | « Bonus de base aux **sauvegarde** » | « aux **sauvegardes** » |
| F8 | Zombi (DRS 40) | section titrée « Création **d'un squelette** » (son texte parle du zombi) | archétype « Zombi » |
| F9 | Taille des élémentaires (DRS 37) | « 5m », « 3t », en-tête « Dégât s » | « 5 m », « 3 t », « Dégâts » |

## 4. Laissé tel quel

- « Le loup-garou présenté **ci-dessous** » et tournures semblables : le profil précède le texte
  dans la fiche, mais la phrase est celle du DRS.
- Les FP des dragons véritables dépendent de l'âge : la fiche n'a pas de FP (`mo_fp_id` NULL), la
  ligne « Facteur de puissance » donne la liste par âge.
