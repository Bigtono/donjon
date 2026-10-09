<?php
// include/migrations-reference.php — Référence initiale du moteur de migrations (SP-DP5)
//
// Ces 37 migrations existaient avant le moteur (2026-10-07) et ont toutes été
// jouées à la main, en local comme en production. À la création de
// dd_migrations, elles sont enregistrées avec le statut « reference », sans être
// rejouées : la plupart ne sont pas idempotentes (un ALTER TABLE … ADD COLUMN
// rejoué échoue sur « Duplicate column name »).
//
// Valeur : empreinte SHA-256 du fichier ce jour-là. Une empreinte qui ne
// correspond plus signale un fichier retouché depuis ; le moteur l'affiche et ne
// le rejoue jamais.
//
// Liste figée : ne plus jamais y ajouter de fichier. Une nouvelle migration est
// jouée par le moteur, c'est tout son objet.

return [
  '2026-06-01_campagnes_v2_etape1.sql' => 'bed753eea238375592c036b2747b8de000a80480c0e35b1e594533092959cf8b',
  '2026-06-01_campagnes_v2_etape2a.sql' => 'bb75f7b80e2915301b43eae3341898dc9528d671a5b1577c9f834f7f8cd3a85d',
  '2026-06-12_personnages_identite.sql' => 'cb9b644fc064e0123cf1b469bade989264f662a64afeb93b62f107ef97095f89',
  '2026-06-12_personnages_socle.sql' => '15430e182a00bb24d848cdf715c1a814601ac3d010385a59061b9f299974ecb4',
  '2026-06-20_equipements_sp-e0.sql' => '689bce6765ec289f3bcd1bb45c183c0922fb9912b39ef5b9cf6cbab9f590a23c',
  '2026-06-20_oppositions_monstre_optionnel.sql' => 'd24346d2d84260a1565950a8ebc33d7d27b869cb7855280246212140c9ed41c8',
  '2026-08-10_tableaux_sp-tb0.sql' => 'e595dd54fe56db76f1dcfe3e8f2d2b5bde9111ac13ecdf7109a11d2c02d35727',
  '2026-08-15_dons_dd2024_mdj.sql' => '5fcf5ce8de7850a74d451ffb336ca90438fbefadb01f20c68271a2153e1b50d9',
  '2026-08-22_releves_device_sp-rs5.sql' => '0ef374d94207dc2afb853a720d665243787641fd5970486ce611eadcebee9663',
  '2026-08-24_ordre_sp-cp.sql' => 'ad9a9d0dae245dde196a7b819ee9cac15e1ce7e52eb0307b066e4634df401e02',
  '2026-08-25_regles_dd35_drs01.sql' => '02f35017493fa18668fea7d653cf51f33525f36510442e0af435ae6d98edbd8d',
  '2026-08-25_regles_dd35_drs10.sql' => 'a027e6a057a54cafc1ebe1d07b01696fa16c2ac9f34f6b871f0b754de2ed8f05',
  '2026-08-25_regles_dd35_drs12.sql' => '64667e6a51ae101d04f011efb71bd7342325710b9baf55f5af0f0cbec788a1fd',
  '2026-08-25_regles_dd35_drs18.sql' => '144d9115e54c309980d7af9466bd7acb4624eb574b821d4233f29a9b29ccee08',
  '2026-08-25_regles_dd35_drs19.sql' => '30e18a5934806a030416306a0f29264a4b3e90a240470b6cf4e493debf8417c9',
  '2026-08-25_regles_dd35_glossaire_lot1.sql' => 'e6307dd56c7bac249797cff8e7ead35a2e8e9a6eb2076a37fbe659266296682e',
  '2026-08-25_regles_dd35_socle.sql' => 'ba51779ea39b55c7f896af6bc75e47d6367d0ba0f464353d9c325ce7c4ade386',
  '2026-08-27_profil_incantation_sp-ma0.sql' => 'c2415c9117f9fd51418ccd4437ad33e2a7ac6b66fb12d09cf8fbdda459abec5d',
  '2026-08-27_registre_sp-ma3.sql' => 'bbef74aeb58a0d06479f7220de5ec29994824508e9a6c28f42f24f143eb8fcff',
  '2026-08-28_capacites_drop_categorie.sql' => 'fa80c405962a3bbe1d83878859d938ef107f3008ff945b6c6eda888cd1666a84',
  '2026-08-28_classes_dd2024_sp-im1.sql' => '7749f1536269f0b708c16a9af3e84f7e9f4c20a617b27d98bc1d362cbef95632',
  '2026-08-28_classes_dd2024_sp-im2.sql' => 'a7f06ab9df72eebfdee7ec38f48cf2e363f686b1e5c069f93a594b206463a222',
  '2026-08-28_classes_dd2024_sp-im3.sql' => 'a29a3a4a2f7c70e2d6f4f4e1714f3babeed77f147c52905021e90de0c317456f',
  '2026-08-28_classes_dd2024_sp-im4.sql' => '0ee82771276f4732c3b632fc34d00ebc27097eefe70efadfb0e6e22857c44db4',
  '2026-08-28_classes_dd2024_sp-im7.sql' => '98e7d21184c797e85d6851e2d3ac30fc894bee56535d81789cfac02dd4f1dc01',
  '2026-08-28_cle_unique_classe_niveau.sql' => '9fabbc8a31cbebfcc3f6203f834d23ade8ed9c195ca1dfdf90a0caf846be0f6c',
  '2026-08-28_objets_dd2024_sp-im9a.sql' => 'f52b182bcf01dd7927e337c69a96232c46a190e07a1dd78bbf71a8b28c351781',
  '2026-08-28_objets_dd2024_sp-im9b.sql' => '58d3c2f04c8aeafff3e7532ccdba843d58902a02f3486dc4cfb3150b7604eccb',
  '2026-08-28_objets_dd2024_sp-im9c.sql' => '55eff74917b242090143cd50ca4a0f1d4968719073752e5225b6bf6ae5c71913',
  '2026-08-28_options_dd2024_sp-im5.sql' => '1c58b88ca3f500a040854a2e74a0e8b972ee727794c839a4c891473b5150e275',
  '2026-08-28_races_dd2024_sp-im8.sql' => 'f26c890892879eb7b437029c71d372a7ffc85c8d4b028f120c557c3b33161603',
  '2026-08-28_registre_sp-ma3_donnees.sql' => 'b9dcf7d2e0ecf57aaabd75d199ed5ca7d606aafce0acd8caba4b447b359a58cc',
  '2026-09-01_cadence_renouvellement_sp-ma4b.sql' => 'e407c9bad65ab3067eb2fd83e34a3cc5c5dec77a0d3e1378d06ebaf58f2e2e60',
  '2026-09-01_cn_sort_null_vs_zero_sp-pe7a.sql' => 'c2336602ae5273e2655a46a9a7c97ca94d967bd98cef9f3f40d53a31b6293848',
  '2026-09-01_decalage_paladin_rodeur_sp-pe7a.sql' => '1d4905129f65ada2163dffc0f7f47dfa3e2ed6008936d8907c595224388f11b7',
  '2026-09-01_sorts_toujours_prepares_sp-ma4a.sql' => '3ad1b6e7620a6d3b15a644265cfd0a7bb2fd078b65d8a8e776c46daee8e3d659',
  '2026-10-07_mode_jeu_optionnel_sp-pe10l.sql' => 'a0fd58ccf26874f8c9c7fb468d4760b7c6a82aaed665ccefb787523fe720bb9c',
];
