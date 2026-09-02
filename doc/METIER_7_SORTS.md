<!-- Mis à jour : 2026-09-01 -->

# Règles métier — La magie : sorts, classes et rulesets

> Analyse fonctionnelle préalable à `SP-PE7` (vue Magie) et aux évolutions du compendium Sorts.
> **Aucun code, aucune décision d'implémentation** : ce document décrit ce que disent les règles,
> ce que la base sait déjà en faire, et ce qui manque. Les arbitrages sont en §11.
>
> Sources : SRD DD3.5 français (`DRS 20 (magie)`, `DRS 03a/03b`, `DRS 21`) et SRD DD2024
> français v5.2.1 (`règles-sorts`, section Classes, `création de personnage`).
> Relevés de base : instance locale, 2026-08-27.

---

## 1. Le point de départ

Le compendium sait déjà décrire un **sort** dans les deux rulesets (`ARCHITECTURE_7_SORTS.md`).
Ce qui n'est pas modélisé, c'est le **rapport d'une classe à ses sorts** : d'où elle les tire,
combien elle peut en lancer, quand elle peut changer d'avis. Or c'est exactement ce dont la vue
Magie a besoin.

Deux constats structurent tout le reste :

1. **DD3.5 a cinq façons différentes de lancer des sorts**, et elles ne se ramènent pas les unes
   aux autres. Un magicien, un ensorceleur et un prêtre ne manipulent pas le même objet.
2. **DD2024 a unifié tout ça** : toutes les classes préparent des sorts, à deux détails près.
   La complexité DD2024 n'est pas dans les modes d'incantation, elle est ailleurs (sorts toujours
   préparés, sous-classes, multiclassage, magie de pacte).

Le modèle de données doit donc porter la complexité de DD3.5 sans imposer sa lourdeur à DD2024.

---

## 2. Ce que le ruleset change dans la définition d'un sort

| | DD3.5 | DD2024 |
|---|---|---|
| Niveau du sort | **Relatif à la classe** — un même sort est niveau 3 pour le magicien et niveau 4 pour le barde. Vit dans `dd_sortclasse.sc_niveau` et `dd_sortdomaine.sd_niveau` | **Absolu** — un seul niveau par sort, `so_niveau` |
| École | 8 écoles + Universel | 8 écoles, pas d'universel |
| Branche | Oui (Charme, Coercition, Convocation, Création, Guérison, Téléportation, Appel, Chimère, Fantasme, Hallucination, Mirage, Ombre…) | Non |
| Registre | Oui, entre crochets — 19 registres SRD (acide, air, Bien, Chaos, eau, électricité, feu, force, froid, langage, Loi, lumière, Mal, mental, mort, obscurité, son, terre, terreur). Champ dédié `so_registre` depuis SP-MA3 | Non |
| Composantes | V, G, M, **F (focaliseur)**, **FD (focaliseur divin)**, **PX (coût en points d'expérience)** | V, S, M uniquement |
| Origine | **Profane** (barde, ensorceleur, magicien) ou **divine** (prêtre, druide, paladin, rôdeur) | La distinction n'existe plus |
| Jet de sauvegarde | Ligne dédiée (Annule / Partiel / 1/2 dégâts / Dévoile / Aucun) | Décrit dans le texte de l'effet |
| Résistance à la magie | Ligne dédiée | N'existe plus |
| Concentration | Une **durée** parmi d'autres | Un **état de jeu** : un seul sort de concentration à la fois → `so_concentration` |
| Rituel | N'existe pas | Mot-clé sur le temps d'incantation → `so_rituel` |
| Emplacement supérieur | **Pas d'upcasting** : dépenser plus haut est permis mais sans effet, la puissance vient du NLS (§3.3b) | Le sort **est** du niveau de l'emplacement dépensé, avec effets accrus décrits |

**Conséquence directe** : en DD3.5 la question « quel niveau a ce sort ? » n'a pas de réponse hors
contexte de classe. En DD2024 elle en a une. Toute l'interface doit poser la question dans le bon
ordre selon le ruleset.

---

## 3. DD3.5 — cinq profils d'incantation

### 3.1 Les deux origines

- **Magie profane** — barde, ensorceleur, magicien. Caractéristique Cha (barde, ensorceleur) ou
  Int (magicien). Soumise à l'**échec des sorts profanes** en armure.
- **Magie divine** — prêtre, druide, paladin, rôdeur. Caractéristique Sag. Pas d'échec en armure.

La distinction sert au jeu (parchemins utilisables, contresorts, sorts de domaine) et surtout
**au NLS des classes de prestige** : `cn_niveauSortArcane` / `cn_niveauSortDivin` /
`cn_niveauSortEffectif` — mécanique déjà livrée en `SP-PE6`.

### 3.1b Les trois états d'un sort de magicien — *lecture A, validée le 2026-08-27*

Le SRD enchaîne : se procurer le sort → le **déchiffrer** (Art de la magie DD 20 + niveau) →
l'étudier une journée → réussir un test (DD 15 + niveau) → *« le magicien **comprend** la formule
et **peut la recopier** dans son livre de sorts »* → 24 h de copie, 100 po la page. Comprendre
précède donc l'entrée au grimoire. Les sorts gagnés à la montée de niveau (2 par niveau) entrent
directement, sans test ni coût.

Deux lectures étaient possibles pour nommer les états. **Lecture A retenue**, cohérente avec le
SRD et avec ce que `SCHEMA_SQL.md` documente déjà :

| État | Sens retenu | Support en base |
|---|---|---|
| **Connu** | Le sort est à ma disposition — parchemin ramassé, grimoire emprunté ou trouvé — mais pas encore recopié dans **mon** grimoire | ligne dans `dd_personnages_sorts`, `pes_compris = 0` |
| **Compris** | Déchiffré, étudié, **recopié dans mon grimoire** | `pes_compris = 1` |
| **Préparé** | Occupe un emplacement du jour | ligne dans `dd_personnages_sorts_prepares` |

> **Règle décisive, vraie dans les deux lectures envisagées : préparable ⟺ compris.**

La liste « connus » a donc un usage propre en séance : c'est là que le joueur note les parchemins
et grimoires ramassés en aventure, avant de payer la copie. Le geste qui fait passer de l'une à
l'autre est *« Recopier dans le grimoire »*.

Les autres classes DD3.5 n'ont pas cet étage : leur réservoir est la liste de classe entière, il
n'y a rien à « connaître » ni à « comprendre ».

### 3.2 Les cinq profils

| Profil | Classes | Réservoir | Engagement quotidien | Renouvellement |
|---|---|---|---|---|
| **Grimoire** | Magicien | Sorts recopiés dans le grimoire (sous-ensemble de la liste magicien/ensorceleur) | **Prépare** : choisit chaque matin quels sorts occupent ses emplacements | +2 sorts par niveau gagné, + copie de parchemins/grimoires (test d'Art de la magie) |
| **Liste divine** | Prêtre, Druide | Toute la liste de classe, en permanence | **Prépare** après 1 h de prière | Automatique à chaque nouveau niveau de sort accessible |
| **Liste divine partielle** | Paladin, Rôdeur | Toute la liste de classe (niveaux 1 à 4 seulement) | **Prépare** | Idem, mais l'incantation ne démarre qu'au **niveau 4 de classe** |
| **Répertoire spontané** | Barde, Ensorceleur | **Répertoire figé et plafonné** (`cn_sortConnu_n0..9`) | **Spontané** : n'importe quel sort du répertoire, tant que le quota du niveau n'est pas épuisé | Nouveaux sorts à la montée de niveau + **échange** d'un sort (ensorceleur : niveau 4 puis tous les 2 niveaux ; barde : niveau 5 puis tous les 3 niveaux) |
| **Classe de prestige** | Assassin, Chevalier noir, Élu divin, Tueur de Domiel… | Variable — soit répertoire propre, soit progression du NLS d'une classe de base | Selon la classe | — |

### 3.3 Ce qui détermine le nombre de sorts par jour

```
Emplacements du niveau N
  = table de classe au NLS effectif      (dd_classe_niveau.cn_sort_n0..n9)
  + sorts bonus de caractéristique       (bonusSortsCarac(), helpers.php — SP-MA1)
  + 1 emplacement de domaine si N ≥ 1    (prêtre uniquement)
  + 1 emplacement d'école si N ≥ 1       (magicien spécialiste uniquement)
```

Précisions qui ont des conséquences d'interface :

- **Quota « 0 » ≠ pas de sorts.** Un barde niveau 1 a « 0 » sort de niveau 1 : il peut néanmoins
  lancer ceux que son bonus de Charisme lui accorde. La ligne doit donc être affichée, pas masquée.
- **Prérequis de caractéristique** : pour préparer ou lancer un sort de niveau N, il faut au moins
  `10 + N` dans la caractéristique de la classe. C'est le seul filtre dur.
- **Les emplacements de haut niveau peuvent servir aux sorts de bas niveau**, jamais l'inverse.
- Le bonus de caractéristique **n'affecte jamais le nombre de sorts connus** d'un barde ou d'un
  ensorceleur (chiffres fixes de la table).

### 3.3b L'upcasting n'existe pas en DD3.5

> Point de confusion fréquent avec la 5e, tranché le 2026-08-27. C'est **la différence
> d'interface la plus structurante entre les deux rulesets**.

Le SRD 3.5 autorise à dépenser un emplacement de niveau supérieur : *« Il est toujours possible
d'utiliser un emplacement de sort de haut niveau pour un sort de plus bas niveau. »* Mais cela
**n'apporte strictement rien** — on gaspille l'emplacement. La puissance d'un sort 3.5 dépend du
**NLS**, jamais de l'emplacement dépensé.

La seule façon d'élever le niveau d'un sort en 3.5 est le don **Sort accru** (*Heighten Spell*),
qui ne s'ajoute pas d'un delta fixe mais porte le sort au niveau choisi — un don, pas une règle
générale.

DD2024 fait l'inverse : *« le sort est considéré pour cette incantation comme du niveau
correspondant »*, avec les effets accrus décrits dans le sort.

**Conséquence sur la page Magie** : le geste de lancement diffère **par nature** entre les deux
rulesets. En DD2024, lancer implique de **choisir le niveau d'emplacement** — c'est une décision
du joueur, l'interface doit l'offrir. En DD3.5, ce choix n'existe pas : le niveau est figé à la
préparation. Ce n'est pas une page unique paramétrée par le ruleset, ce sont deux gestes
différents (portée `SP-PE8`, Mode jeu).

### 3.3c Les trois états d'un emplacement préparé (DD3.5)

Le magicien peut préparer une partie seulement de ses sorts et laisser des emplacements
**« vierges »**, qu'il remplira plus tard dans la journée (15 minutes minimum). En revanche il ne
peut ni abandonner un sort déjà préparé au profit d'un autre, ni réutiliser un emplacement déjà
dépensé — il lui faudrait pour cela 8 h de repos.

Un emplacement préparé a donc **trois** états, pas deux : `vierge` · `réservé à un sort` ·
`dépensé`. Le modèle de suivi en séance (`SP-PE8`) doit les porter tous les trois.

### 3.4 Domaines divins (prêtre)

Deux domaines choisis à la création (`pc_do_id_1`, `pc_do_id_2`), irrévocables. Chacun donne un
pouvoir accordé et **un sort par niveau de 1 à 9**. Le prêtre reçoit un emplacement de domaine
supplémentaire par niveau de sort, réservé aux sorts de ses deux domaines. Un sort de domaine
absent de la liste générale de prêtre ne peut être préparé **que** dans cet emplacement.

Restriction d'alignement : un prêtre ne peut pas lancer un sort dont le registre s'oppose à son
alignement ou à celui de son dieu (Bien / Chaos / Loi / Mal). Même règle pour le druide.

### 3.5 École de prédilection (magicien)

Choix au niveau 1 : une école de prédilection, **deux écoles interdites** (une seule si le choix
porte sur la Divination). Effets : +1 sort préparé de son école par niveau de sort accessible, +2
aux tests d'Art de la magie pour apprendre un sort de son école, et **impossibilité d'apprendre les
sorts des écoles interdites** — ce qui filtre le compendium à la source.

### 3.6 Incantation spontanée

- **Prêtre** : convertit à la volée un sort préparé (hors domaine) en sort de *soins* (prêtre bon)
  ou de *blessure* (prêtre mauvais), de niveau égal ou inférieur. Neutre : choix irrévocable à la
  création.
- **Druide** : même mécanique vers *convocation d'alliés naturels*.

> **Conséquence** : « liste préparée = liste lançable » est vrai pour le **magicien**, le paladin
> et le rôdeur, **faux pour le prêtre et le druide**. Pour ces deux classes la liste préparée est
> la *réserve*, et la liste lançable vaut « liste préparée + cibles de conversion ». La page doit
> rendre la conversion visible, sinon un joueur de prêtre ne voit pas ses soins.

### 3.7 Métamagie — un mécanisme de coût en emplacement

En DD3.5 la métamagie **est** un mécanisme d'emplacement : le don augmente le niveau effectif du
sort, donc le niveau de l'emplacement consommé.

| Don | Delta |
|---|---|
| Extension / Incantation silencieuse / Incantation statique / Sort étendu | +1 |
| Sort renforcé | +2 |
| Sort maximisé / Sort élargi | +3 |
| Sort accéléré | +4 |
| **Sort accru** | Porte le sort au niveau choisi (pas un delta fixe) |

Règles qui structurent la saisie :

- **Plusieurs dons se cumulent** sur un même sort, les deltas s'additionnent.
- Un sort ainsi modifié **ne peut pas dépasser le niveau 9** pour un lanceur normal.
- Un même sort peut être préparé **plusieurs fois** : en version normale et en une ou plusieurs
  versions métamagiques, chacune occupant son propre emplacement. La seule limite est le nombre
  d'emplacements de chaque niveau.
- Pour un lanceur **qui prépare**, le choix du don se fait **à la préparation** ; pour un lanceur
  **spontané**, à l'incantation, au prix d'un temps d'incantation allongé (sauf *Sort accéléré*).

Déjà prévu en base : `pesp_metamagie` (dons appliqués), `pesp_niveau` (niveau effectif après
application), `pesp_nb` (nombre d'exemplaires préparés).

> **En DD2024, rien de tout cela ne subsiste.** Les *dons* de métamagie ont disparu. Le mécanisme
> survit uniquement comme aptitude de l'**Ensorceleur**, payé en points de Sorcellerie — et
> surtout, il **ne modifie ni le niveau du sort, ni l'emplacement dépensé**. `pesp_metamagie` et
> `pesp_niveau` restent donc strictement DD3.5, comme l'indique déjà `SCHEMA_SQL.md`.

---

## 4. DD2024 — un modèle unique et trois variantes

> ### ⚠️ Piège documentaire — ne pas confondre 5e 2014 et 5e 2024
>
> Beaucoup de synthèses disponibles sur la 5e — y compris récentes et présentées comme portant sur
> l'édition 2024 — décrivent encore **Barde, Ensorceleur et Occultiste comme des lanceurs
> spontanés à « sorts connus »**. C'était vrai en **2014**. Ça ne l'est plus.
>
> Dans le SRD 5.2.1, ces trois classes ont l'aptitude **« Sorts préparés du 1er niveau et plus »**,
> exactement comme le Clerc et le Magicien. La notion de « sorts connus » a disparu de l'édition.
>
> **Enjeu pour nous** : suivre cette erreur reviendrait à créer un profil `repertoire_spontane`
> pour le Barde 2024, donc un onglet « Sorts connus », un plafond `cn_sortConnu_n*` et une
> logique de lancement sans préparation — tout cela faux. `repertoire_spontane` **n'existe qu'en
> DD3.5**. Vérifié sur le SRD et acté le 2026-08-27.

### 4.1 Le tronc commun

**Toutes** les classes lanceuses de DD2024 préparent leurs sorts. Il n'y a plus de « sorts
connus » au sens 3.5 :

- **Sorts mineurs** (niveau 0) : un nombre fixe connu, lançables sans emplacement, sans limite
  d'usage. Colonne « Sorts mineurs » de la table d'aptitudes.
- **Sorts préparés** (niveau 1+) : une liste plafonnée par la colonne « Sorts préparés »
  (`cn_sortPrepare`), choisie dans la liste de classe.
- **Emplacements de sort** : colonnes 1 à 9, restaurés au **repos long**. Lancer un sort dépense un
  emplacement **au moins** égal à son niveau, et le sort compte alors comme étant du niveau de
  l'emplacement.

**Le choix du niveau d'emplacement est un geste du joueur** (cf. §3.3b) : c'est la décision que la
3.5 ne connaît pas. Elle se prend au lancement, pas à la préparation, et doit donc vivre dans le
Mode jeu (`SP-PE8`), pas dans l'écran de préparation.

**Trois façons de lancer sans dépenser d'emplacement**, à rendre visibles distinctement :

| Cas | Règle |
|---|---|
| **Sorts mineurs** | Jamais d'emplacement, usage illimité |
| **Rituels** (`so_rituel`) | +10 minutes d'incantation, aucun emplacement. **Le sort doit être préparé** |
| **Savoir rituel** du Magicien | Exception à la ligne précédente : il lance en rituel un sort **de son grimoire sans l'avoir préparé**, en le lisant depuis le grimoire |

S'y ajoutent les usages gratuits accordés par certaines aptitudes (« N fois par repos long ») et
l'**Arcanum mystique** de l'Occultiste — traités en §4.4.

### 4.2 La seule vraie différence entre classes : quand la liste change

| Cadence | Classes |
|---|---|
| **À la fin d'un repos long**, changement libre | Clerc, Druide, Magicien |
| **À la fin d'un repos long**, un seul sort échangé | Paladin, Rôdeur |
| **À la montée de niveau**, un seul sort échangé | Barde, Ensorceleur, Occultiste |

C'est tout. C'est le seul axe qui distingue « lanceur préparé » de « lanceur spontané » dans
l'ancien vocabulaire.

### 4.3 Les trois variantes

**Magicien — le grimoire.** Le réservoir n'est pas la liste de classe mais le grimoire : 6 sorts de
niveau 1 au départ, +2 par niveau gagné, plus les copies. La liste préparée est un sous-ensemble du
grimoire. Deux aptitudes s'y greffent : **Savoir rituel** (lancer en rituel un sort du grimoire
*sans l'avoir préparé*) et **Restauration magique** (récupérer des emplacements au repos court).

**Occultiste — la Magie de pacte.** Modèle à part entière :
- Un petit nombre d'emplacements, **tous du même niveau**, ce niveau montant avec la classe.
- Restaurés au **repos court ou long**, pas seulement au repos long.
- Sorts préparés plafonnés au niveau des emplacements.
- **Arcanum mystique** (niveau 11+) : des sorts de niveau 6 à 9 lançables une fois par repos long,
  hors emplacements.
- En multiclassage, emplacements de pacte et emplacements ordinaires sont **interchangeables**.

**Ensorceleur — les points de Sorcellerie.** Peut convertir des points en emplacements et
inversement, et applique la **Métamagie** au prix de points. Le nombre d'emplacements devient donc
partiellement dynamique en séance.

### 4.4 Les sorts toujours préparés

Mécanique transverse et **non modélisée aujourd'hui** : de nombreuses aptitudes (sous-classes,
dons, aptitudes de classe) accordent des sorts « toujours préparés » qui **ne comptent pas** dans
le plafond `cn_sortPrepare` mais comptent comme sorts de la classe. Exemples SRD : *marque du
chasseur* pour le Rôdeur (niveau 1), *contact avec les plans* pour l'Occultiste (niveau 9), la
liste de sorts de chaque domaine de Clerc.

Certaines de ces aptitudes ajoutent aussi un usage gratuit (« sans dépenser d'emplacement,
N fois par repos long »).

### 4.5 Multiclassage

Règle explicite du SRD, sans équivalent DD3.5 :

```
Niveau d'incantateur = niveaux de Barde + Clerc + Druide + Ensorceleur + Magicien
                     + ⌈niveaux de Paladin / 2⌉ + ⌈niveaux de Rôdeur / 2⌉
```

Ce total est lu dans la table « Incantateur multiclassé » pour obtenir les emplacements. Mais les
**sorts préparés se déterminent classe par classe**, chacun avec sa propre caractéristique
d'incantation. Un personnage peut donc disposer d'emplacements d'un niveau supérieur aux sorts
qu'il sait préparer — il s'en sert alors pour ses sorts de niveau moindre.

C'est le pendant fonctionnel du NLS 3.5, mais il **ne se calcule pas de la même manière** et ne
peut pas réutiliser `dd_personnages_nls` : ici, rien à affecter manuellement, tout est déductible.

---

## 5. Synthèse comparée

| Mécanisme | DD3.5 | DD2024 |
|---|---|---|
| Niveau d'un sort | Par classe / par domaine | Absolu |
| Modes d'incantation | 3 (grimoire, liste, répertoire spontané) | 1 (préparation) + Magie de pacte |
| Sorts de niveau 0 | Emplacements par jour, comme les autres | Connus, illimités, hors emplacements |
| Sorts bonus de caractéristique | Oui, table `dd_modificateurs` | Non |
| Récupération | Repos + 1 h de préparation/prière | Repos long (repos court pour le pacte) |
| Plafond du répertoire | `cn_sortConnu_n0..9` (spontanés seulement) | `cn_sortPrepare` (toutes classes) |
| Progression multiclasse | Manuelle : affectation des niveaux de prestige (`dd_personnages_nls`) | Automatique : somme pondérée des niveaux |
| Emplacement supérieur | **Autorisé mais sans le moindre effet** — on gaspille l'emplacement | Le sort **est** du niveau de l'emplacement, effets accrus |
| Puissance du sort | Fonction du **NLS** | Fonction du **niveau de l'emplacement dépensé** |
| Choix du niveau au lancement | **N'existe pas** — figé à la préparation | **Geste du joueur** à chaque incantation |
| Lanceurs spontanés | Barde, Ensorceleur | **Aucun** — les 8 classes préparent (§4, encadré) |
| Métamagie | Dons ouverts à tous, **modifient le niveau d'emplacement** | Aptitude du seul Ensorceleur, **sans effet sur le niveau ni l'emplacement** |
| Liste préparée = liste lançable | Vrai sauf prêtre et druide (conversion spontanée) | Vrai, plus les sorts mineurs, les rituels et les usages gratuits |
| États d'un emplacement préparé | **Trois** : vierge · réservé · dépensé | Deux : disponible · dépensé |
| Domaines / spécialisation | Domaines divins, école de prédilection | Sous-classes → sorts toujours préparés |
| Ressources annexes | Coût en PX de certains sorts | Points de Sorcellerie, Arcanum, usages gratuits |

---

## 6. Traduction en modèle : trois axes plutôt que trois booléens

`dd_classes` porte aujourd'hui trois drapeaux indépendants — `cla_sort_connu`,
`cla_sort_compris`, `cla_sort_prepare` — soit huit combinaisons dont la plupart n'ont aucun sens,
et dont **aucune n'est fiable en base** (§7). L'analyse ci-dessus montre que le comportement réel
d'une classe tient dans trois axes orthogonaux, valides pour les deux rulesets :

**Axe A — Réservoir** : d'où le personnage tire ses sorts
- `liste` — toute la liste de classe (prêtre, druide, paladin, rôdeur 3.5 ; clerc, druide, paladin,
  rôdeur, barde, ensorceleur, occultiste 2024)
- `grimoire` — un sous-ensemble matérialisé qui s'enrichit par étude (magicien, les deux rulesets)
  → `dd_personnages_sorts.pes_compris = 1`
- `repertoire` — un sous-ensemble figé et plafonné par niveau de sort (barde, ensorceleur 3.5)
  → `cn_sortConnu_n0..9`

**Axe B — Engagement quotidien**
- `prepare` — un sous-ensemble est choisi au repos → `dd_personnages_sorts_prepares`
- `spontane` — tout le réservoir est lançable dans la limite du quota (DD3.5 uniquement)
- `pacte` — préparé, mais emplacements uniformes et restaurés au repos court (Occultiste 2024)

**Axe C — Cadence de renouvellement du réservoir**
- `repos_long` — clerc, druide, magicien, paladin, rôdeur (2024) ; tous les préparateurs 3.5
- `montee_niveau` — barde, ensorceleur, occultiste (2024) ; barde, ensorceleur (3.5, par échange)

Le tableau cible complet :

| Ruleset | Classe | A — Réservoir | B — Engagement | C — Cadence | Carac |
|---|---|---|---|---|---|
| 3.5 | Magicien | grimoire | prepare | repos_long | Int |
| 3.5 | Prêtre | liste | prepare | repos_long | Sag |
| 3.5 | Druide | liste | prepare | repos_long | Sag |
| 3.5 | Paladin | liste (1-4, dès N4) | prepare | repos_long | Sag |
| 3.5 | Rôdeur | liste (1-4, dès N4) | prepare | repos_long | Sag |
| 3.5 | Barde | repertoire | spontane | montee_niveau | Cha |
| 3.5 | Ensorceleur | repertoire | spontane | montee_niveau | Cha |
| 2024 | Magicien | grimoire | prepare | repos_long | Int |
| 2024 | Clerc | liste | prepare | repos_long | Sag |
| 2024 | Druide | liste | prepare | repos_long | Sag |
| 2024 | Paladin | liste | prepare | repos_long | Cha |
| 2024 | Rôdeur | liste | prepare | repos_long | Sag |
| 2024 | Barde | liste | prepare | montee_niveau | Cha |
| 2024 | Ensorceleur | liste | prepare | montee_niveau | Cha |
| 2024 | Occultiste | liste | pacte | montee_niveau | Cha |

### 6b. Implémentation retenue — `cla_profil_incantation` *(livré en `SP-MA0`)*

Les axes A et B sont un outil d'analyse : à l'arrivée, **seules quatre de leurs combinaisons
existent dans les règles**. Un enum à quatre valeurs est donc à la fois plus simple et complet, là
où trois booléens indépendants offraient huit combinaisons dont quatre absurdes.

| Valeur | `var_id` | Constante PHP | Axe A | Axe B | Ruleset |
|---|---|---|---|---|---|
| Liste préparée | 3 | `PROFINC_LISTE` | liste | prepare | les deux |
| Grimoire | 4 | `PROFINC_GRIMOIRE` | grimoire | prepare | les deux |
| Répertoire spontané | 5 | `PROFINC_REPERTOIRE` | repertoire | spontane | **DD3.5 seul** |
| Magie de pacte | 6 | `PROFINC_PACTE` | liste | pacte | **DD2024 seul** |

Stockage : `dd_classes.cla_profil_incantation` → `dd_variables` (`var_cat = 'profinc'`).
Le filtrage par ruleset vit dans `profilsIncantation($db, $ruleset_var_id)` et **nulle part
ailleurs**. Les ids sont figés en constantes plutôt que répétés dans le code, pour ne pas
reproduire l'écueil des littéraux `clt_id` dispersés.

Les trois drapeaux `cla_sort_connu` / `_compris` / `_prepare` sont **dépréciés** : plus ni lus ni
écrits, colonnes conservées le temps d'une vérification en production, contenu figé au 2026-08-27
et faux. `cla_domaine_divin` reste actif — il est orthogonal (un prêtre est « Liste préparée »
**et** à domaines).

L'axe C, lui, n'a aucun support et doit être ajouté — ou assumé comme non modélisé (§11, Q3).

---

## 7. État réel de la base — relevé du 2026-08-27

> Relevé direct sur l'instance locale. Ce paragraphe n'est pas de la spécification : c'est le
> point de départ effectif, et il est plus dégradé que la documentation ne le laisse supposer.

**Bloquants**

| Constat | Portée |
|---|---|
| ~~**`dd_modificateurs` est vide**~~ — **levé par `SP-MA1`** | La table n'est plus la source : les sorts bonus se calculent par formule (`bonusSortsCarac()`), contrôlée ligne à ligne contre le SRD. La table devient morte |
| ~~**`dd_classe_niveau` DD2024 très incomplet**~~ — **levé par `SP-IM2`** le 2026-08-28 | Les 12 classes DD2024 ont leurs 20 niveaux. Magie de pacte comprise, portée par les colonnes `cn_pouvoir` (Manifestations / Emplacements / Niveau des emplacements) conformément à la table du SRD — **`SP-PE7` devra donc traiter l'Occultiste à part** pour lire ses emplacements |
| **`dd_personnages_sorts` et `dd_personnages_sorts_prepares` sont vides** — aucun écran ne les alimente | Exactement le piège de `SP-PE5` : une vue « lecture seule » serait structurellement vide |

**Incohérences de référentiel**

- `cla_mag_id` en DD2024 : Magicien = `1` (identifiant du ruleset **DD3.5**), Rôdeur = `5`
  (**valeur inexistante** dans `dd_typemagie`), les autres = `4` (« Divine ») — alors même que
  DD2024 ne distingue plus profane et divin.
- `cla_car_id = 0` (non renseigné) pour Ensorceleur, Magicien, Occultiste et Rôdeur en DD2024.
- Les trois drapeaux `cla_sort_*` valent **0 pour toutes les classes DD2024**, et sont incohérents
  en DD3.5 : Magicien `connu=1 / compris=0` (inversé), Ensorceleur `compris=1 / connu=0` (inversé),
  Prêtre `cla_domaine_divin = 0` (alors que c'est la classe à domaines par excellence).

**Modélisation incomplète**

- ~~`so_branche` mélange **branche et registre**~~ — **résolu par `SP-MA3`** le 2026-08-27 : champ
  `so_registre` créé, 673 sorts sur 690 migrés proprement, 7 partiellement (résidu de troncature
  perdu à l'import v1), 10 laissés intacts car ce ne sont pas des branches mais des **données de
  domaine égarées** (« Cavernes 7 », « Initié de Mystra 3 ») — à reprendre en `SP-MA5`.
- `dd_sortdomaine` : 147 lignes réparties sur 45 domaines (sur 72 en table). Le SRD seul en demande
  ~207 pour ses 23 domaines. Couverture partielle.
- En DD2024, `dd_sortclasse.sc_niveau` est **identique à `so_niveau` sur les 879 lignes** : la
  table n'y sert qu'à l'appartenance, jamais au niveau.
- Aucun support pour : école de prédilection du magicien (3.5), sorts toujours préparés (2024),
  niveau des emplacements de pacte (2024), niveau d'incantateur multiclassé (2024).

**Ce qui est sain**

- 1 935 sorts DD3.5 et 339 sorts DD2024, écoles renseignées à 100 %, `so_niveau` complet en DD2024.
- `dd_sortclasse` bien peuplée dans les deux rulesets (Magicien 3.5 : 1 062 entrées ;
  Magicien 2024 : 230).
- `dd_bonus_maitrise` complet pour DD2024 (20 niveaux).
- `dd_personnages_nls` et le bloc NLS prestige livrés en `SP-PE6`.

---

## 8. Écarts à combler, par nature

**Données à saisir** (aucun développement)
1. `dd_modificateurs` — les 30 lignes valeur → modificateur → sorts bonus par niveau.
2. `dd_classe_niveau` DD2024 — compléter Barde, Ensorceleur, Paladin ; créer Occultiste et Rôdeur.
3. `dd_sortdomaine` — compléter la couverture des domaines DD3.5.

**Référentiel à corriger** (UPDATE ciblés)
4. `cla_mag_id` DD2024 — passer les 8 classes lanceuses à `1` (Q1 tranchée), et conditionner au
   ruleset tout affichage du libellé `dd_typemagie`.
5. `cla_car_id` DD2024 — Ensorceleur/Occultiste = Cha, Magicien = Int, Rôdeur = Sag,
   Paladin = Cha (et non Sag comme en DD3.5).
6. `cla_sort_connu` / `cla_sort_compris` / `cla_sort_prepare` / `cla_domaine_divin` — recoder les
   18 classes lanceuses selon le tableau §6.

**Schéma à étendre** (patch SQL — sous réserve d'arbitrage)
7. Axe C, cadence de renouvellement.
8. Séparation branche / registre en DD3.5 — **retenue** (Q4) : champ `so_registre`, script de
   migration idempotent, répercussion sur la fiche, le formulaire et la liste du compendium Sorts.
9. École de prédilection et écoles interdites du magicien DD3.5.
10. Sorts toujours préparés DD2024.
11. Niveau des emplacements de Magie de pacte DD2024.

**Sémantique à documenter** (aucun changement, mais à écrire noir sur blanc)
12. `cn_sort_n0` porte **deux sens** : emplacements de niveau 0 par jour en DD3.5, **nombre de
    sorts mineurs connus** en DD2024. Rien ne le signale aujourd'hui.

---

## 9. Ce que la vue Magie doit produire (`SP-PE7`)

La vue est **par classe lanceuse du personnage**, une section par classe.

### En-tête de section, les deux rulesets
- Nom de la classe, niveau dans la classe
- **NLS effectif** (DD3.5 : niveau de base + apports de prestige affectés en `SP-PE6` ;
  DD2024 : niveau d'incantateur multiclassé, calculé)
- Caractéristique d'incantation, sa valeur, son modificateur
- DD du jet de sauvegarde et bonus d'attaque des sorts
  (DD3.5 : `10 + niveau du sort + mod` — donc **variable par niveau de sort** ;
  DD2024 : `8 + mod + bonus de maîtrise` — valeur unique)

### Tableau des emplacements
- DD3.5 : une colonne par niveau 0-9, décomposée `table + bonus de carac + domaine + école`
- DD2024 : niveaux 1-9 pour les emplacements ordinaires, ligne distincte pour la Magie de pacte,
  ligne distincte pour le nombre de sorts mineurs connus et le plafond de sorts préparés

### Listes de sorts, selon le profil (§6)
- Réservoir `grimoire` → onglet **Grimoire** (sorts compris), alimentable
- Réservoir `repertoire` → onglet **Sorts connus**, plafonné par `cn_sortConnu_n*`, avec compteur
  restant par niveau de sort
- Réservoir `liste` → pas d'onglet propre : le sélecteur puise directement dans le compendium,
  borné par `getActiveResIds()`
- Engagement `prepare` ou `pacte` → onglet **Sorts préparés**, avec compteur
- Engagement `spontane` → pas d'onglet préparés : le répertoire *est* la liste jouable

Précisions issues des arbitrages du 2026-08-27 :

- Réservoir `grimoire` → **deux** listes, pas une : « Connus » (`pes_compris = 0`, parchemins et
  grimoires ramassés) et « Grimoire » (`pes_compris = 1`, préparables), avec le geste
  *« Recopier dans le grimoire »* qui fait passer de l'une à l'autre (§3.1b, lecture A).
- Profils `liste_preparee` du **prêtre** et du **druide** (DD3.5) : la conversion spontanée doit
  être visible à côté de la liste préparée, sinon un joueur de prêtre ne voit pas ses soins (§3.6).
- Profil `grimoire` en DD2024 : les rituels du grimoire non préparés restent lançables
  (**Savoir rituel**) — ils appartiennent à la liste jouable sans occuper de préparation (§4.1).

Tous les noms de sorts sont cliquables vers `detail-pp/sort.php`. La liste sélectionnable est
**bornée par `getActiveResIds($db, $pe_ruleset_var_id)`** — le ruleset du personnage, jamais celui
de la session (règle du module, §7.7 de la référence).

### Filtres DD3.5 à appliquer au sélecteur
- Niveau du sort **pour cette classe** (`dd_sortclasse`), plus les domaines du personnage
  (`dd_sortdomaine`) si `cla_domaine_divin = 1`
- Écoles interdites du magicien spécialiste, si l'axe est modélisé
- Registres d'alignement opposés pour prêtre et druide — **signalés, pas bloqués** (l'alignement du
  dieu n'est pas saisi)

### Ce que la vue ne fait pas
Cohérent avec le principe « aide de jeu, pas moteur de règles » (§7.7 / §7.7b de la référence) :
pas d'échec des sorts profanes en armure, pas de suivi de la concentration, pas de coût en PX, pas
de contrôle du prérequis `10 + niveau` — affiché en avertissement au plus. Le décompte des
emplacements consommés en séance relève de `SP-PE8` (Mode jeu), pas de `SP-PE7`.

**À reporter explicitement sur `SP-PE8`**, conséquences des arbitrages du 2026-08-27 :

- Le **geste de lancement diffère par nature** entre rulesets (§3.3b) : DD2024 impose de choisir le
  niveau d'emplacement à l'incantation, DD3.5 ne connaît pas ce choix. Deux gestes, pas une page
  paramétrée.
- Un emplacement préparé DD3.5 a **trois** états (`vierge` · `réservé` · `dépensé`, §3.3c) ; DD2024
  n'en a que deux. Le modèle de suivi doit porter les trois.

---

## 10. Plan de développement — `SP-MA` + `SP-PE7`

### 10.1 Objectif produit

> Fixé le 2026-08-27. C'est le critère d'acceptation de l'ensemble du chantier.

Donner au joueur un **outil de gestion des sorts de son personnage lanceur**, dans les deux
rulesets, qui :

1. **Va au but.** Un joueur en séance cherche « qu'est-ce que je peux lancer, et combien il m'en
   reste » — pas un formulaire d'administration. Le nombre de gestes pour préparer sa journée ou
   consulter un sort est le critère de conception, avant l'exhaustivité.
2. **Tient compte de la particularité de chaque classe.** Un magicien ne se gère pas comme un
   ensorceleur ni comme un prêtre. Les trois axes du §6 (réservoir / engagement / cadence)
   déterminent quels onglets et quels compteurs existent — l'interface ne montre pas ce qui n'a
   pas de sens pour la classe.
3. **Assume le multiclassage lanceur** — **point structurant, et critique en DD3.5** : un
   ensorceleur/prêtre a deux réservoirs, deux modes d'engagement, deux caractéristiques
   d'incantation et deux NLS distincts, l'un pouvant être avancé par une classe de prestige et
   pas l'autre. Rien ne se mutualise entre les deux, sauf les sorts eux-mêmes. En DD2024 le
   multiclassage est plus simple mais pas trivial : emplacements **communs** calculés sur le
   niveau d'incantateur agrégé (§4.5), mais sorts préparés et caractéristique **par classe**, plus
   l'interchangeabilité des emplacements de Magie de pacte.
4. **Marche au doigt.** Smartphone et tablette tactile au même titre que l'ordinateur, dès la
   conception et non en rattrapage — les onglets, sélecteurs et compteurs sont les éléments les
   plus manipulés du module.

Conséquence sur la structure de la page : le niveau de regroupement de premier rang est
**la classe lanceuse**, pas le niveau de sort. Un personnage monoclasse ne doit pas payer le prix
visuel du multiclassage.

### 10.2 `SP-MA` — Référentiel de la magie *(transverse)*

Code projet ouvert le 2026-08-27 (arbitrage Q5, option c). Justification : six des neuf blocs de
travail identifiés en §8 touchent le compendium Classes, le compendium Sorts ou le référentiel
global, pas le module Personnages ; et les phases `MA4`/`MA5` n'auraient aucune place légitime dans
`SP-PE`. Précédent : `SP-TB`, parti du module Règles pour devenir autonome.

| Phase | Contenu | Nature |
|---|---|---|
| `SP-MA0` | Référentiel des classes lanceuses : `cla_mag_id` recadré par ruleset (D-MAG2), `cla_car_id` des 4 classes DD2024 vides, recodage des drapeaux `cla_sort_*` et `cla_domaine_divin` sur les 18 classes, libellé `dd_typemagie` conditionné au ruleset | UPDATE + code |
| `SP-MA1` | Seed `dd_modificateurs` — 30 lignes, table **vide** aujourd'hui | Données |
| `SP-MA2` | `dd_classe_niveau` DD2024 : Barde, Ensorceleur, Paladin complétés ; Occultiste et Rôdeur **créés** | Données |
| `SP-MA3` | Registre DD3.5 : `so_registre`, migration idempotente, compendium Sorts (fiche, formulaire, liste) — D-MAG3 | Schéma + script + UI |
| `SP-MA4` | Extensions de schéma restantes : cadence de renouvellement (Q3), école de prédilection DD3.5, sorts toujours préparés DD2024 (Q7), emplacements de Magie de pacte (Q6) | Schéma |
| `SP-MA5` | Complétion `dd_sortdomaine` | Données |

### 10.3 `SP-PE7` — Vue Magie *(module Personnages)*

Recadrée sur la page elle-même, mais **l'écriture y reste** : les deux tables de sorts personnage
sont vides et aucun écran ne les alimente — une vue en lecture seule serait structurellement vide,
exactement le piège de `SP-PE5`.

1. **Helpers de calcul** dans `personnage_helpers.php` — NLS effectif par classe (DD3.5 : base +
   apports de prestige de `SP-PE6` ; DD2024 : niveau d'incantateur agrégé), emplacements par niveau
   de sort, plafonds de réservoir et de préparation.
2. **Page en lecture** — une section par classe lanceuse, en-tête et tableau d'emplacements (§9).
3. **Sélecteurs d'écriture** — grimoire, sorts connus, sorts préparés. Modèle à arbitrer (Q8).
4. **Passe responsive** — rattachée à `SP-PE8` pour la cohérence avec les autres blocs de la
   fiche, mais l'objectif 4 du §10.1 impose de concevoir tactile dès `SP-PE7`, pas de rattraper
   après coup.

### 10.4 Dépendances

```
SP-MA0 ─┐
SP-MA1 ─┼─→ SP-PE7 ─→ SP-PE8 (Mode jeu : décompte des emplacements en séance)
SP-MA2 ─┘

SP-MA3, SP-MA4, SP-MA5 : indépendantes de SP-PE7
  sauf SP-MA4 si Q3, Q6 ou Q7 sont tranchées dans le sens d'une extension de schéma
  exploitée par la vue — auquel cas SP-MA4 devient bloquante à son tour.
```

`SP-MA3` et `SP-MA5` améliorent le compendium Sorts indépendamment de la fiche : elles peuvent
être livrées avant, pendant ou après `SP-PE7`.

---

## 11. Questions d'arbitrage

> À trancher avant toute écriture de code ou de patch SQL.

**Q1 — `cla_mag_id` en DD2024. — TRANCHÉE le 2026-08-27**
`cla_mag_id` est conservé, avec une **plage de valeurs propre à chaque ruleset** :

| Ruleset | Valeurs admises | Sens |
|---|---|---|
| DD3.5 | `0` / `1` / `2` | 0 = non lanceur, 1 = magie profane, 2 = magie divine |
| DD2024 | `0` / `1` | 0 = non lanceur, **1 = lanceur de sorts, sans distinction** |

Le test `cla_mag_id > 0` continue donc d'identifier une classe lanceuse dans les deux rulesets.
La distinction profane/divine ne se lit **que** si `cla_ruleset_var_id = 1`.

Deux conséquences à porter dans le code et la doc :

1. **`cla_mag_id` cesse d'être une clé étrangère utilisable telle quelle.** En DD2024, la valeur
   `1` ne désigne plus la ligne `dd_typemagie` d'id 1 (« Prof », ruleset DD3.5) : c'est un
   drapeau. Tout affichage du libellé de type de magie doit être **conditionné au ruleset**, sous
   peine d'afficher « Magie profane » sur un Clerc DD2024.
2. **Les lignes `dd_typemagie` 3 (« Profane », DD2024) et 4 (« Divine », DD2024) deviennent
   mortes.** À supprimer ou à conserver inertes — point mineur, à traiter avec le recodage.

UPDATE à produire : les 8 classes lanceuses DD2024 passent toutes à `cla_mag_id = 1`
(aujourd'hui `4` pour Barde/Clerc/Druide/Ensorceleur/Paladin, `1` pour Magicien — valeur juste par
accident, `5` pour Rôdeur — valeur inexistante ; Occultiste à vérifier).

**Q2 — Recodage des drapeaux `cla_sort_*`.** Le tableau §6 est-il validé comme cible, et le
recodage des 18 classes lanceuses peut-il se faire par UPDATE direct — sachant qu'aucune donnée
personnage n'en dépend aujourd'hui (les deux tables de sorts personnage sont vides) ?

**Q3 — Axe C (cadence de renouvellement).** Trois options : (a) nouvelle colonne
`cla_renouvellement` sur `dd_classes` ; (b) déduction en dur dans le code depuis le nom ou l'id de
classe — refusé par principe ; (c) **non modélisé** : la cadence relève de la table du MJ, la vue
ne l'affiche pas et n'empêche rien. Vu le principe « aide de jeu », l'option (c) est défendable.
Quelle option ?

**Q4 — Branche et registre en DD3.5. — TRANCHÉE le 2026-08-27**
On sépare : ajout d'un champ **`so_registre`** et migration par script depuis `so_branche`.

Trois formes à traiter, relevées en base :

| Forme dans `so_branche` | Exemple | Cible `so_branche` | Cible `so_registre` |
|---|---|---|---|
| Branche + registres entre crochets | `Fantasme [mental, terreur]` | `Fantasme` | `mental, terreur` |
| Registre(s) seul(s), sans crochets | `Mal` · `son` · `mal, mental` | vide | `Mal` · `son` · `mal, mental` |
| Branche seule | `Coercition` · `Création` | inchangé | vide |

La deuxième forme est la seule ambiguë : elle se reconnaît au fait que la valeur appartient à la
**liste fermée des 19 registres du SRD** (acide, air, Bien, Chaos, eau, électricité, feu, force,
froid, langage, Loi, lumière, Mal, mental, mort, obscurité, son, terre, terreur) et non à la liste
des branches. La casse est irrégulière en base (`Mal` / `mal`, `son` / `Son`) : la comparaison doit
être insensible à la casse et aux accents, et la migration **normalise** la casse au passage.

Périmètre induit, hors module Personnages : fiche de sort, formulaire de création/modification et
liste du compendium Sorts — l'affichage entre crochets décrit dans `ARCHITECTURE_7_SORTS.md` cesse
d'être une convention de saisie pour devenir un rendu.

Le script de migration doit être **idempotent** et précédé d'un relevé de contrôle (nombre de
sorts par forme détectée), les 1 935 lignes n'étant pas rejouables à l'identique après coup.

**Q5 — Découpage et code projet. — TRANCHÉE le 2026-08-27**
Option (c) : **ouverture du code projet `SP-MA` — Référentiel de la magie**, transverse au
compendium Sorts, au compendium Classes et au module Personnages. `SP-PE7` est recadrée sur la
page Magie elle-même et devient bloquée par `SP-MA0→MA2`.

Raison : six des neuf blocs de travail du §8 ne touchent pas le module Personnages, et les phases
`SP-MA4`/`SP-MA5` n'auraient aucune place légitime dans `SP-PE` — elles seraient sorties de la
checklist, exactement la situation que le passage de « sous-phases 3.0 à 3.7 » à `SP-PE` a corrigée
le 2026-08-12. Précédent retenu : `SP-TB`, parti du module Règles pour devenir autonome.

Découpage détaillé en §10. Checklist en `ARCHITECTURE_0_REFERENCE.md` §0.

**Q6 — Périmètre DD2024 de la première livraison. — SANS OBJET depuis le 2026-08-28**
La question supposait une extension de schéma pour la Magie de pacte. `SP-IM2` l'a réglée autrement :
le nombre d'emplacements et leur niveau sont portés par les colonnes `cn_pouvoir1..3` de
`dd_classe_niveau` (« Manifestations occultes », « Emplacements de sort », « Niveau des
emplacements »), fidèlement à la table du SRD. Aucune extension nécessaire, l'Occultiste est traité.

> **Contrepartie, à ne pas perdre de vue** : la lecture générique « emplacements = `cn_sort_n1..9` »
> **ne vaut pas** pour l'Occultiste, dont ces colonnes restent à 0. Arbitré le 2026-09-01 :
> `SP-PE7` traitera l'Occultiste en **cas particulier explicite** plutôt que de dupliquer
> l'information dans `cn_sort_n*` — une donnée présente en deux endroits finit par diverger.

**Q7 — Sorts toujours préparés (DD2024). — TRANCHÉE le 2026-09-01**
Table de liaison retenue. Le SRD formule tous ces cas de la même façon, mot pour mot :

> « Lorsque vous atteignez un niveau de Paladin spécifié dans la table *Sorts du Serment de
> Dévotion*, les sorts qui y figurent sont toujours préparés pour vous. »
> `3 → bouclier de la foi, protection contre le mal`

Cinq cas relevés dans le SRD, dont trois seulement relèvent du référentiel :

| Cas | Exemple | Traitement |
|---|---|---|
| **A** — sort unique d'une aptitude de classe | Paladin 1 *châtiment divin*, Rôdeur 1 *marque du chasseur*, Occultiste 9 *contact avec les plans* | `dd_classe_sort` |
| **B** — table de sorts d'une sous-classe | Domaine de la Vie, Serment de Dévotion, Sorts draconiques, Cercle de la Terre, Collège du Savoir, Évocateur, Protecteur Fiélon, Chasseur | `dd_classe_sort` |
| **C** — usages gratuits, orthogonaux à A et B | « deux fois sans dépenser d'emplacement », parfois croissants | `dd_classe_sort` |
| **D** — Manifestations occultes | *armure du mage* sans emplacement | **déjà traité** : importées comme dons par `SP-IM5`, catégorie 23 |
| **E** — Arcanum mystique (Occultiste 11/13/15/17) | un sort de niveau 6 à 9 **au choix** | **choix du joueur**, pas du référentiel — voir plus bas |

**Table `dd_classe_sort`** : `cs_cla_id` → `dd_classes` (**classe ou sous-classe indifféremment**,
une sous-classe étant une classe `clt_id = 5`), `cs_so_id` → `dd_sorts`, `cs_niveau` (niveau
d'acquisition), `cs_usages` (NULL = aucun usage gratuit), `cs_recharge` (NULL / `court` / `long`).

Que `cs_cla_id` accepte les deux est ce qui permet à A et B de partager une seule table : le SRD
les formule pareil, seul le porteur change. Le modèle est en outre **celui de `dd_sortdomaine`**,
qui fait déjà ce travail pour les domaines DD3.5 — les deux rulesets partagent alors la même
mécanique.

**Volume estimé** : 8 sous-classes lanceuses × ~4 niveaux × ~2 sorts, plus les 3 sorts de classe,
soit **de l'ordre de 70 lignes**. Les 10 sous-classes du SRD existent en base depuis `SP-IM4`.

**Cas E, différé** (recommandation suivie faute de contre-indication) : l'Arcanum n'est pas un sort
fixe, il devra être stocké par personnage avec un marqueur (`pesp_origine` : 0 préparé, 1 toujours
préparé, 2 arcanum) pour ne pas peser sur le plafond. Il ne concerne que l'Occultiste de niveau 11
et plus, et le suivi des usages relève du Mode jeu. **`SP-PE7` affichera un avertissement** pour
ces personnages plutôt que de faire semblant.

**Q8 — Écriture des listes personnage. — TRANCHÉE le 2026-09-01**
**Écriture immédiate**, sur le modèle du sélecteur de dons `SP-PE4` (deux volets dans `#detail-pp`,
enregistrement au clic, compteur serveur), **portée par classe**. Un seul motif d'interaction pour
les trois listes — grimoire, connus, préparés.

Raisons : l'écriture immédiate est nettement meilleure au doigt (objectif 4 du §10.1) — pas de
formulaire long à faire défiler, pas de bouton de validation à retrouver en bas d'écran, et
`notifier()` donne déjà le retour visuel. Et un commit global couvrant plusieurs classes lanceuses
serait dangereux en multiclassage : une sauvegarde toucherait deux listes à la fois.

Contrepartie assumée : refaire une liste préparée complète coûte quelques gestes de plus qu'un
éditeur à commit unique. Une action **« Réinitialiser la liste préparée »** compense.
