<!-- Mis à jour : 2026-11-07 19:30 -->

# Journal d'import — scénarios, chapitres et rencontres v1 de L'Empire des Anges (SP-CV1)

Rapport produit par `tools/generer-sp-cv1-campagne-empire-v1.php` pour `sql/2026-11-08_sp-cv1_campagne_empire_v1.sql`, depuis l'export de l'ancienne application (`DEV Donjon/maikasteiymaika_mysql_db.sql`). Campagne v1 1 → v2 5 ; ids v2 = 2000 + id v1 (D-CV3). Personnages et notes hors périmètre.

## Volumes

| Scénarios | Chapitres | Rencontres | Oppositions |
|---|---|---|---|
| 2 | 10 | 64 | 119 |

## Arborescence

| Id v2 | Scénario / chapitre | Rencontres | Oppositions |
|---|---|---|---|
| **2001** | **Valombre : l'Épuration** | | |
| 2001 | D : Le Val plongé dans l'ombre | 6 | 13 |
| 2002 | C : Château Roche | 2 | 5 |
| 2003 | F : La Folie d'Azmaer | 11 | 9 |
| 2004 | L : L'antre Sinistre d'Alokair | 0 | 0 |
| 2005 | U : Soulèvement | 9 | 24 |
| **2002** | **Anauroch : l'Empire de Pénombre** | | |
| 2006 | M : La Tour du Hurlevent | 9 | 15 |
| 2007 | C : La Crypte d'Augathra la Démente | 14 | 32 |
| 2008 | W : Recherches et développements | 4 | 5 |
| 2009 | T : Sous la tour blanche | 3 | 5 |
| 2010 | S : Rivage de l'Ombre | 6 | 11 |

## Règles appliquées

- Une opposition par lien v1 (`dd_rencontres_monstres`), recopiée au jeu de la migration de la fiche v2 (`mo_id` = 2000 + id v1) : nom, catégorie, statistiques ; `opp_mo_id` figé. L'effectif est écrit dans `re_composition` (D-CV0).
- Rencontres rattachées par leur chapitre ; la rencontre v1 79 « Attaque Shadovar », sans scénario, suit son chapitre (D-CV1).
- `re_ordre` : tri naturel du code v1 dans le chapitre, puis id v1. Noms et codes débarrassés des espaces parasites.
- Descriptions vides ou restes de saisie (« 3 », « 5 », « blabla bla ») → NULL ; les autres passent par `nettoyerHtmlV1()` (D-CV2).

## Liens écartés

- Lien v1 113 : rencontre 40 absente de la v1 (supprimée), monstre 248.
- Lien v1 114 : rencontre 41 absente de la v1 (supprimée), monstre 249.
- Lien v1 115 : rencontre 42 absente de la v1 (supprimée), monstre 250.
- Lien v1 116 : rencontre 38, monstre 251 absent de la v1 (supprimé).
- Lien v1 117 : rencontre 38, monstre 252 absent de la v1 (supprimé).
- Lien v1 168 : rencontre 0 absente de la v1 (supprimée), monstre 0.
- Lien v1 182 : rencontre 67 absente de la v1 (supprimée), monstre 349.
- Lien v1 183 : rencontre 68 absente de la v1 (supprimée), monstre 350.
- Lien v1 184 : rencontre 69 absente de la v1 (supprimée), monstre 351.
