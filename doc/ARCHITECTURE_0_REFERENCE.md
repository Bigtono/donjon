<!-- Mis à jour : 2026-10-16 17:00 -->

# Codex DD v2 — Document de référence architecture

> Source de vérité pour tous les développements.
> À ouvrir dans VS Code à chaque session pour contextualiser Claude Code.
> Dernière mise à jour : Phase 2 SP-C2→C5 — répliqué sur les 7 entités restantes du compendium
> (Dons, Sorts, Compétences, Races, Classes, Objets magiques, Historiques), sur le modèle Monstres.
> SP-C0→C5 et C7 désormais complets sur les 8 entités. Deux bugs de régression corrigés le
> 2026-07-02 : disparition du supplément personnel dans `getActiveResIds()` priorité 1 (contexte
> personnage/campagne) et priorité 2 (`profil/index.php` "Mes sources" écrasait le supplément à
> chaque save). SP-C6 reste partiel : la sélection propre est désormais robuste, l'affichage des
> suppléments publics d'autres utilisateurs n'est toujours pas implémenté.
> 2026-07-04 : `config/db.config.php` refondu en fichier unique DEV/OVH à détection automatique
> d'environnement, suite à un écrasement accidentel de la config de prod (voir D-CFG1).
> 2026-07-04 (suite) : la mise en prod du fichier unique déclenche un 503 "Err1" (échec connexion
> PDO) sur OVH alors que le local fonctionne. Cause précise non confirmée (log serveur OVH non
> consulté) — `include/db.php` instrumenté pour journaliser l'environnement détecté et l'hôte DSN
> ciblé à chaque échec, sans exposer les identifiants (voir D-CFG2, diagnostic en cours).

> 2026-10-11 : nouveau projet **SP-PO — Possessions** (équipements et objets magiques), ruleset DD3.5 d'abord.
> Les règles du DRS 07 (Équipement) et du DRS 23 (Objets magiques) sont importées (`SP-DRS2`, `SP-DRS3`),
> mais **les articles ne sont pas dans les règles** : leurs fiches vivent dans le compendium. Les règles
> en affichent les listes par un nouveau tag `[[liste:equipement|…]]` / `[[liste:objet|…]]`, toujours à
> jour, filtrable par famille et par source (`SP-PO1`, §9e). `dd_equipements` (vide) est restructurée :
> familles (`dd_categorie_equipement`), prix, poids, attributs en JSON, supplément utilisateur (`SP-PO0`,
> solde `SP-E5`) ; 269 articles du DRS 07 importés avec leur description propre (`SP-PO2`). Corrections de
> texte : `doc/LOG_CORRECTIONS_DRS07_DRS23.md`. Voir §9e et §0.

> 2026-08-10 : nouveau projet **SP-TB — Tableaux de règles**. Les tableaux de données quittent
> `reg_texte` (HTML TinyMCE) pour une table dédiée `dd_tableaux`, saisis en convention texte et
> insérés dans une règle par le tag `[[tab:slug]]`. SP-TB0→TB6 livrés ; SP-TB7 (extension aux
> champs texte du compendium), SP-TB8 (écran du MJ) et SP-TB9 (tableaux DD3.5) restent à faire.
> Voir §9c.

> 2026-08-24 : **SP-TB10 / SP-TB11**. Les tableaux ne sont pas une donnée du module Règles : le
> gestionnaire quitte `regles/tableaux.php` pour `tableaux/index.php`, servi par le moteur de
> liste partagé (filtres source / écran du MJ / texte, pagination, tri) et atteignable depuis les
> barres d'outils de Règles, du Compendium et des Campagnes. Deux défauts de portée corrigés au
> passage : la propagation d'un renommage de slug ignorait les champs du compendium, et
> l'outillage CSS/JS du gestionnaire n'était chargé que sur les pages Règles. Voir §9c.

> 2026-08-12 : le module **Personnages** reçoit son code projet **`SP-PE`** et rejoint le tableau de
> bord §0 — c'était le seul chantier suivi hors checklist (sous-phases « 3.0 à 3.7 » narratives en
> §7.11). Aucun code livré n'est modifié : `SP-PE0→PE2` sont acquis depuis le 2026-06-14, le module
> est en pause depuis. `SP-PE3→PE8` restent à faire, dont un `SP-PE5` nouvellement isolé (bloc
> Campagnes de la fiche). Voir §7.11.

> 2026-08-12 (suite) : **SP-PE3 livrée** — bloc Compétences de la fiche, éditeur inline filtrable
> sur le tableau complet du ruleset, total affiché (2ᵉ exception assumée au « pas de moteur de
> règles », voir §7.7b). Aucun patch SQL. Reprise du module : `SP-PE4` (Dons).

> 2026-08-13 : correctifs hors phase autour du **ruleset actif**, en trois temps.
> (1) Changer le ruleset dans `profil/index.php` purge le contexte de navigation devenu hors-sujet
> (`resetContexteRuleset()` : personnage, campagne, scénario, chapitre, rencontre) et recharge la
> section « Mes sources » — voir §11 et §12.
> (2) `campagnes/index.php` filtre enfin sur `camp_ruleset_var_id`, comme la liste des personnages
> qui en était calquée — voir §8.
> (3) Le ruleset d'une entité n'est plus jamais saisi ni posté : 11 champs de formulaire retirés,
> point de passage unique `rulesetEnregistrement()` — voir §3, règle absolue.
> Détail dans `DECISIONS_LOG.md` [2026-08-13].

> 2026-08-14 : **SP-PE5 livrée** — bloc Campagnes de la fiche. La phase, spécifiée « lecture
> seule », a dû s'élargir à l'écriture : `dd_campagnes_personnages` n'était **alimentée par aucun
> écran** et `pe_camp_id` n'était jamais écrit, un bloc en lecture seule aurait donc été
> structurellement vide. Livré : lecture (campagne en cours + historique), éditeur inline de
> rattachement à écriture immédiate, section « Personnages » du panneau de campagne, et
> **correctif `getActiveResIds()` priorité 1** — jusqu'ici du code mort que cette phase réveillait
> en unionnant les sources de toutes les campagnes du personnage. Aucun patch SQL. Voir §7.5c et
> `DECISIONS_LOG.md` [2026-08-14]. Reprise du module : `SP-PE6` (NLS prestige DD3.5).

> 2026-08-22 : nouveau projet **SP-RS — Finalisation de l'UI smartphone**, transverse à tous les
> modules déclarés responsives en §10. `SP-RS0` (mode debug : badge de dimensions du viewport,
> activable depuis le tableau de bord admin, session uniquement) et `SP-RS1` (menu principal en
> déroulant pleine largeur sous 992px) livrées. Aucun patch SQL. Voir §10b et §10c, et
> `DECISIONS_LOG.md` [2026-08-22].
>
> 2026-08-22 (suite) : `SP-RS2` livrée — le bandeau de contexte devient un fil d'Ariane défilable
> sur une seule ligne sous 992px (150px → 57px en cascade complète), rendu inchangé au-dessus aux
> icônes de type près. Voir §10d.
>
> 2026-08-22 (suite) : `SP-RS3` livrée — listes du compendium. Le point important n'est pas
> cosmétique : le menu ⋮ était masqué sous 992px, les 9 listes étaient donc **en lecture seule sur
> téléphone**. Voir §10e.
>
> 2026-08-22 (suite) : `SP-RS3b` (barre de filtrage promue en composant partagé, module Personnages
> aligné dessus — §10f), `SP-RS4` (panneaux en feuille plein écran — §10g) et `SP-RS5a` (collecte
> des relevés d'affichage — §10h) livrées. **Un patch SQL à appliquer** :
> `sql/2026-08-22_releves_device_sp-rs5.sql` (10 colonnes `j_last_*` sur `dd_joueurs`, table
> `dd_connexions`). Reste `SP-RS5`, l'arbitrage des paliers, à instruire une fois les relevés
> accumulés.

> 2026-08-24 : nouveau projet **SP-CP — Refonte du module Campagnes**, livré le jour même
> (`SP-CP0→CP7`). Le module quitte `#detail-pp` : chaque niveau de la hiérarchie devient une page
> (`campagnes/campagne.php`, `scenario.php`, `chapitre.php`, `rencontre.php`), en deux colonnes
> 1/4–3/4 calées sur un poste de 1536 × 799, avec une colonne d'outils de partie et un bouton
> retour par niveau. Le fil d'Ariane du header devient une suite de liens — c'est ce qui lui donne
> enfin sa fonction annoncée : revenir à un niveau précis depuis n'importe quelle page du site.
> Deux composants transverses en sortent, écrits pour tout le site : le **tri par glisser-déposer**
> (`js/tri-liste.js`) et la **pastille d'enregistrement automatique** (`notifier()`) — voir §12b.
> **Un patch SQL à appliquer en prod** : `sql/2026-08-24_ordre_sp-cp.sql` (`re_ordre`, `opp_ordre`
> + backfill). Voir §8b et `DECISIONS_LOG.md` [2026-08-24].

> 2026-08-27 : **SP-PE6 livrée** — bloc NLS prestige (DD3.5) de la fiche personnage. Un tableau
> par classe de prestige influant sur le NLS, éditeur inline à commit global (mêmes partis que
> Classes et Compétences), selects filtrés par le type de magie de chaque niveau
> (drapeaux `cn_niveauSort*`). Affectation partielle autorisée (« À affecter » en rouge) ; un
> niveau sans drapeau levé est affiché « Sans progression de NLS », sans select. Aucun patch SQL
> (`dd_personnages_nls` existait). Voir §7.5d et `DECISIONS_LOG.md` [2026-08-27]. Reprise du
> module : `SP-PE7` (vue Magie).

> 2026-08-27 (suite) : analyse fonctionnelle de la magie menée avant `SP-PE7`, sur les SRD des deux
> rulesets et sur l'état réel de la base — livrée dans `METIER_7_SORTS.md`. Elle a fait apparaître
> que **six des neuf blocs de travail identifiés tombent hors du module Personnages** (compendium
> Classes, compendium Sorts, référentiel global) et que trois bloquants inconnus jusqu'ici
> interdisent tout calcul : `dd_modificateurs` **vide**, `dd_classe_niveau` DD2024 très incomplet
> (Occultiste et Rôdeur **absents de la table**), `dd_personnages_sorts` et
> `..._sorts_prepares` vides sans écran pour les alimenter.
> → Nouveau code projet **`SP-MA` — Référentiel de la magie**, transverse, sur le modèle de
> `SP-TB`. `SP-PE7` est recadrée sur la page elle-même et **bloquée par `SP-MA0→MA2`**.
> Objectif produit fixé le 2026-08-27 : donner au joueur un outil de gestion des sorts de son
> personnage, quel que soit le ruleset, tenant compte des particularités de chaque classe et du
> **multiclassage lanceur** (crucial en DD3.5), utilisable au doigt sur smartphone et tablette
> autant qu'à la souris. Voir §0, `METIER_7_SORTS.md` §10 et `DECISIONS_LOG.md` [2026-08-27]
> D-MAG1 à D-MAG4.

> 2026-08-27 (suite) : **`SP-MA0` livrée** — référentiel des classes lanceuses. Nouveau champ
> `dd_classes.cla_profil_incantation` (4 profils dans `dd_variables`, cat. `profinc`, ids figés en
> constantes `PROFINC_*` dans `helpers.php`), qui remplace les trois drapeaux `cla_sort_connu` /
> `_compris` / `_prepare` — **dépréciés, ni lus ni écrits, colonnes conservées** le temps d'une
> vérification en prod. `cla_mag_id` recadré par ruleset (D-MAG2). Deux défauts vivants corrigés au
> passage : la table « Sorts connus » de l'**Ensorceleur DD3.5** était masquée alors que sa donnée
> existait, et le **Prêtre DD3.5** n'affichait jamais ses deux selects de domaine (`SP-PE2` mort
> depuis sa livraison). **Patch SQL à appliquer en prod** :
> `sql/2026-08-27_profil_incantation_sp-ma0.sql`. Voir §0, §5, `METIER_7_SORTS.md` §6b et
> `DECISIONS_LOG.md` [2026-08-27] D-MAG7. Reprise : `SP-MA1` (seed `dd_modificateurs`).

> 2026-08-27 (suite) : **`SP-MA3` livrée** — séparation branche / registre en DD3.5. Le champ
> `so_branche` s'est révélé mélanger **quatre** notions et pas deux : branches, registres, mélanges
> avec ou sans crochets, et **données de domaine égarées** (« Cavernes 7 », « Initié de Mystra 3 »).
> S'y ajoutent des valeurs **tronquées à 20 caractères** par l'import v1→v2, alors que la colonne
> fait varchar(40) — le texte perdu l'est définitivement. Sur 690 sorts : 673 migrés proprement,
> 7 partiellement (branche et registre extraits, résidu perdu), 10 laissés intacts car ils relèvent
> de `dd_sortdomaine` (`SP-MA5`). La migration est **rejouable** : elle lit toujours la table de
> sauvegarde `dd_sorts_branche_backup_spma3`, jamais la colonne vive, ce qui rend aussi le retour
> arrière trivial. Filtre « Registre » ajouté à la liste des sorts (DD3.5 seul). **Patch SQL + script
> à passer en prod.** Voir §0 et `DECISIONS_LOG.md` [2026-08-27] D-MAG8. Reprise : `SP-MA1`.

> 2026-08-28 : **`SP-MA1` livrée** — sorts bonus de caractéristique. La phase devait seeder
> `dd_modificateurs` ; l'analyse a montré que la table était **un cache de deux fonctions pures**,
> dont l'une (`modCarac()`) était déjà écrite en PHP, et que la table n'avait jamais été lue.
> Livré par formule : `bonusSortsCarac()` et `peutLancerNiveau()` dans `helpers.php`, contrôlées
> ligne à ligne contre le SRD. Raison décisive : une table plafonnée rend **0 en silence** hors
> plage, le pire résultat pour une aide de jeu — la formule n'a pas de plage. `modCarac()` et
> `formatMod()` remontées de `personnage_helpers.php` vers `helpers.php` pour ne pas dupliquer la
> formule. `dd_modificateurs` devient morte. **Aucun patch SQL.** Voir `DECISIONS_LOG.md`
> [2026-08-27] D-MAG9. Reste dans SP-MA : `MA2` (tables DD2024), `MA4` (extensions, Q3/Q6/Q7),
> `MA5` (domaines).

> 2026-08-28 : correctif de design hors phase — les **capacités raciales** de la fiche race
> reprennent le titre des capacités de classe (`.race-detail__capacite*` groupé avec
> `.classe-detail__capacite*` dans `css/compendium-modules.css`). Mêmes entrées
> `dd_capacites_speciales`, même lecture d'une fiche à l'autre. Aucun patch SQL. Voir §5 et
> `DECISIONS_LOG.md` [2026-08-28] D-RS43.

> 2026-08-28 (suite) : **`SP-PE9` livrée** — la liste des personnages n'est plus scopée au
> propriétaire pour un **administrateur**, qui voit tous les personnages du ruleset actif, avec une
> colonne et un filtre « Joueur » réservés à ce rôle et un filtre Campagne étendu à tout le ruleset.
> Aucun droit nouveau : `canAccess()` autorisait déjà l'admin sur la fiche, les panneaux et
> `enregistrement.php` — seule la liste restait fermée. Aucun patch SQL. Voir §0, §7.4 et
> `DECISIONS_LOG.md` [2026-08-28] D-RS44.

> 2026-09-19 : ouverture de **`SP-PE10`** — passe de compaction de l'interface du module
> Personnages, une sous-phase par écran, distincte de `SP-PE8` qui reste ouverte.
> **`SP-PE10a` livrée** : dans le bloc Identité de la fiche, race / historique (DD2024) / sexe /
> alignement tiennent sur une seule rangée et la ligne Classes, pleine largeur, ferme le bloc.
> `.per-identite` passe de `grid` à `flex` — la rangée occupe toute la largeur quel que soit le
> nombre d'entrées, trois en DD3.5 comme quatre en DD2024. Le bloc perd 54px sur un poste et 40px
> sur téléphone. Aucun patch SQL. Voir §0, §7.3 et `DECISIONS_LOG.md` [2026-09-19] D-RS45.

> 2026-09-19 (suite) : **`SP-PE10b` livrée** — la vue Magie se lit en trois temps. Le tableau des
> emplacements et un panneau **« Ressources de sorts »** occupent une rangée à deux colonnes, et
> ce panneau reprend tout ce qui se comptait ailleurs : plafonds, taille des listes, cadence,
> domaines. Une ligne n'y figure que si le profil d'incantation la porte. Les listes de sorts
> passent de `columns` à un flux à écart fixe, aligné sur le titre. Deux classes citées par la
> page n'avaient **aucun style dans le projet** — `.per-liste-inline` et `.per-fiche__sous-titre`.
> Aucun patch SQL. Voir §0, §7.6b et `DECISIONS_LOG.md` [2026-09-19] D-RS46.

> 2026-09-19 (suite) : **`SP-PE10c` et `SP-PE10d` livrées.** Le tableau des emplacements prend
> l'échelle du panneau qui lui fait face au-dessus de 992px. Le **sélecteur de sorts** reçoit les
> styles qui lui manquaient — aucun de ses éléments propres n'en avait, pas même son `<ul>` :
> ligne retenue teintée (`color-mix` sur `--clr-accent`), compteurs et jetons habillés. Sous
> 992px son volet de description s'efface et la fiche du sort passe dans `#detail-pp-sub`, au
> dessus du sélecteur resté ouvert. Filtre « Les préparés seulement » ajouté au mode préparation,
> et le bouton « recopier dans le grimoire » est désormais posé et retiré au fil des bascules.
> Aucun patch SQL. Voir §0, §7.6b, §7.6c et `DECISIONS_LOG.md` [2026-09-19] D-RS47, D-RS48.

> 2026-09-19 (suite) : **`SP-PE10e` livrée** — correction de fond sur le DD3.5. Un sort s'y
> prépare **plusieurs fois**, chaque exemplaire occupant un emplacement : le sélecteur n'offrait
> qu'une bascule et l'écriture écrasait toujours `pesp_nb` à 1, si bien que la quantité, pourtant
> portée par le schéma et déjà affichée par la vue Magie, était inatteignable depuis l'écran. La
> ligne porte maintenant un compteur, et les jetons de niveau somment les exemplaires. Le DD2024
> garde sa bascule : sa liste préparée est un ensemble de sorts distincts. Aucun patch SQL — la
> colonne existait. Voir §0, §7.6c et `DECISIONS_LOG.md` [2026-09-19] D-RS49.

> 2026-09-19 (suite) : **`SP-PE10f` livrée** — compacité du sélecteur. Le niveau d'un sort passe
> de la pastille de chaque ligne à un **en-tête `sticky` par groupe**, qui se masque avec son
> groupe au filtrage ; le cadre du compteur posé la veille est retiré, et le compteur DD3.5 se
> resserre sur téléphone. Le nom du sort y gagne de 193 à 285px en répertoire, 234px en
> préparation. Aucun patch SQL. Voir §0, §7.6c et `DECISIONS_LOG.md` [2026-09-19] D-RS50.

> 2026-09-19 (suite) : **`SP-PE10g` livrée** — sur téléphone, la liste du sélecteur perd son
> cadre, qui redoublait celui de l'overlay, et déborde du padding du panneau de `--sp-sm` de
> chaque côté. Le nom du sort atteint **303px sur 375px de viewport**, contre 193px avant la
> passe. Rien ne change sur ordinateur ni sur le sélecteur de dons. Aucun patch SQL. Voir §0,
> §7.6c et `DECISIONS_LOG.md` [2026-09-19] D-RS51.

> 2026-10-07 : **`SP-PE10h` livrée** — passe de compactage sur la fiche elle-même. Sur téléphone,
> le bouton Menu rend sa ligne entière (burger en icône au bout de la ligne de titre) et le
> raccourci personnage prend toute la largeur. Le **bloc Identité** est refondu : une rangée de
> champs insécables ouverte par le niveau total, puis les classes une par ligne, sans libellé ni
> « niv. », avec les **sous-classes DD2024 entre parenthèses** derrière leur classe et les
> **prestiges en italique** à la place du badge « P ». Les caractéristiques passent en 2×3 comme
> un bloc de monstre, le bloc Combat laisse place à deux tuiles CA / PV, et les trois tiennent
> une rangée sur un poste. **Défaut corrigé au passage** : `$niveau_global` comptait les
> sous-classes — un clerc 5 / guerrier 1 affichait 7, et son bonus de maîtrise suivait. Les
> `clt_id` reçoivent leurs constantes `CLT_*`. Aucun patch SQL. Voir §0, §7.3, §7.3b et
> `DECISIONS_LOG.md` [2026-10-07] D-RS52.

> 2026-10-07 (suite) : nouveau projet **SP-DP — Déploiement en production**, livré le jour même
> (`SP-DP0→DP6`). Un bouton discret du header, visible en local seulement, envoie par **SFTP**
> les fichiers nouveaux ou modifiés vers OVH, après aperçu et confirmation explicite, puis fait
> **appliquer les migrations SQL par le serveur lui-même** — la base mutualisée OVH refuse toute
> connexion extérieure. Le périmètre est calculé par **git** (`.gitignore`) complété d'un
> `.deployignore` ; un manifeste distant mémorise ce qui a réellement été envoyé. Nouvelle table
> **`dd_migrations`**, créée par le moteur à son premier appel, avec les 37 migrations
> antérieures inscrites comme référence sans être rejouées. Le module de déploiement lui-même
> (`admin/deploiement/`) ne quitte jamais le poste. Voir §0, §6b et `DECISIONS_LOG.md`
> [2026-10-07] D-DP1 à D-DP9.

> 2026-10-10 : **`SP-PE10p` → `SP-PE10r` livrées** — compactage de la vue Magie. Les quatre cases
> de synthèse et le panneau « Ressources de sorts » fusionnent en une liste de paires libellé /
> valeur, en colonne à côté du tableau des emplacements (en ligne sur téléphone) ; le tableau perd
> sa rangée d'en-tête de groupe et « En stock » devient « Restant » ; les listes de sorts passent
> en **onglets** — Préparés par défaut —, chacun portant son compteur et ses actions, une ligne par
> niveau de sort. Le bloc d'un magicien 20 DD2024 passe d'environ 710 à 330px de haut à 1280px.
> Aucun patch SQL. Voir §0, §7.6b et `DECISIONS_LOG.md` [2026-10-10] D-RS63.

> 2026-10-10 (suite) : **`SP-PE10s` livrée** — « Réinitialiser » passe dans le sélecteur de
> préparation, les boutons d'onglet se réduisent à leur icône, et **défaut corrigé** : en DD2024
> les sorts mineurs pesaient sur le plafond de sorts préparés. Aucun patch SQL. Voir §0, §7.6b,
> §7.6c et `DECISIONS_LOG.md` [2026-10-10] D-RS64.

> 2026-10-10 (suite) : **`SP-MA6a` → `SP-MA6c` livrées** — une classe de prestige DD3.5 accorde
> soit ses propres sorts par jour, soit un niveau de lanceur à une classe de base, jamais les deux.
> Les drapeaux de progression du NLS n'étaient ni visibles ni modifiables dans le formulaire, et
> une prestige du second cas (non lanceuse) n'y avait aucune colonne de magie. La section 2 gagne
> une bascule entre les deux jeux de colonnes, le serveur garantit l'exclusivité, et la fiche
> rédige « +1 niv. profane »… **Migration** `sql/2026-10-10_drapeaux_nls_sp-ma6.sql`. Voir §0,
> §5 « Classes de prestige DD3.5 » et `DECISIONS_LOG.md` [2026-10-10] D-MAG16.

> 2026-10-10 (suite) : **`SP-MA6d` livrée** — drapeaux NLS des classes de base remis à 0
> (**migration** `sql/2026-10-10_drapeaux_nls_classes_base_sp-ma6.sql`), distinction NULL / 0
> des sorts par jour DD3.5 vérifiée par banc d'essai, et table de progression d'une classe sans
> colonnes de sorts tenue dans un téléphone. Voir §0, §5 et `DECISIONS_LOG.md` D-MAG17.


---

## 0. Suivi des phases de développement

> **Tableau de bord unique du projet.** Toute livraison significative met cette liste à jour :
> case cochée, code de phase, libellé court. Les détails vivent dans la section du module
> concerné et dans `DECISIONS_LOG.md` — jamais ici.

### SP-C — Supplément utilisateur du compendium

- [x] SP-C0 — SQL : 8 × ALTER TABLE (`_public`/`_visible`) + migration `mo_j_id`
- [x] SP-C1 — Socle helpers : `getOrCreateUserSupplement`, `getUserSupplementResId`, `canEditCompendiumEntry`
- [x] SP-C2 — Moteur `compendium-liste.php` : filtre visibilité, menu ⋮ per-entry, badge homebrew (8 entités)
- [x] SP-C3 — `detail-pp/*.php` × 8 : bouton Modifier per-entry
- [x] SP-C4 — `modifier/*.php` × 8 : source dropdown 2 groupes + `_public`/`_visible`
- [x] SP-C5 — `enregistrement.php` : ownership + sauvegarde `_public`/`_visible` + auto-création du supplément
- [ ] SP-C6 — `profil/index.php` : "Mes sources" étendu aux suppléments publics tiers *(partiel — sélection propre robuste, affichage des suppléments tiers non implémenté)*
- [x] SP-C7 — Nettoyage monstres post-migration

### SP-E — Module Équipements

- [x] SP-E0 — SQL : `CREATE TABLE dd_equipements`
- [x] SP-E1 — Contrôleur liste `compendium/equipements.php`
- [x] SP-E2 — Formulaire `modifier/equipement.php` + `enregistrement.php`
- [x] SP-E3 — Fiche détail `detail-pp/equipement.php`
- [ ] SP-E4 — `monstre-parser.php` : type liable `equipement` *(débloquée — reste `typesLiablesMonstre()` + `construireIndexAuto()` ; l'entrée `equipement` de `MO_LIEN_FICHIERS` dans `js/main.js` est posée depuis SP-PO1, les listes `[[liste:…]]` s'en servent)*
- [x] SP-E5 — Alignement sur le mécanisme Supplément utilisateur (`eqt_public`) — **soldée par SP-PO0** (2026-10-11)
- [x] SP-E6 — *soldée par SP-PO5 (2026-10-16)* — **Import de l'équipement DD2024** : `dd_equipements` ne contient que les articles DD3.5 du DRS 07 (SP-PO2). **Le schéma est tranché** (SP-PO0 : familles, prix, poids, attributs JSON) : reste à saisir les familles DD2024 (`dd_categorie_equipement`, `cae_ruleset_var_id` = 2) et à importer. Inclut les **bottes d'arme** (propriétés d'arme : Fauchage, Éraflure, Entaille, Bousculade, Sape, Ralentissement, Renversement, Harcèlement), écartées de `SP-IM5` le 2026-08-28 — elles qualifient une arme, pas un personnage. Source : `FR_SRD_CC_v5.2.1.pdf`, section équipement (absentes du PDF Classes). ~~Le schéma actuel ne porte ni dégâts, ni propriétés, ni prix~~ — résolu par SP-PO0 : propriétés d'arme, maîtrise et dégâts DD2024 = clés d'attributs de la famille

### SP-PO — Possessions (équipements et objets magiques)

> Chantier ouvert le 2026-10-11, **par ruleset** (les règles diffèrent beaucoup) : DD3.5 d'abord. Les
> règles ne portent que les mécanismes de jeu ; les articles (prix, poids, caractéristiques,
> description propre) sont des données du compendium, que les règles affichent par un tag de liste.
> Arbitrages du 2026-10-11 : `DECISIONS_LOG.md` D-PO1 à D-PO6. Détails en §9e.

- [x] SP-PO0 — Schéma : `dd_categorie_equipement` (arbre de familles, colonnes de liste en JSON), `dd_equipements` étendue (famille, prix, poids, attributs JSON, ordre, `eqt_public`), `com_slug` sur les catégories d'objets magiques ; formulaire, liste (colonnes + filtre famille avec sous-familles), fiche détail et enregistrement mis à niveau — `sql/2026-10-11_equipements_00_schema_sp-po0.sql`
- [x] SP-PO1 — Tag `[[liste:equipement|…]]` / `[[liste:objet|…]]` : `include/liste-parser.php`, paramètres `famille` / `source` / `tri` / `titre`, branché dans `rendreTexteEnrichi()` et les 3 rendus de règles, protégé du glossaire, aide contextuelle
- [x] SP-PO2 — Import des **269 équipements DD3.5** du DRS 07 avec leur description propre : 32 familles, source « DRS 3.5 » — `sql/2026-10-11_equipements_dd35_drs07_sp-po2.sql`
- [x] SP-PO2b — Source des 269 équipements DD3.5 : Manuel des joueurs 3.5 (`MdJ3.5`) au lieu de « DRS 3.5 » — `sql/2026-10-15_equipements_dd35_source_sp-po2b.sql`
- [ ] SP-PO3 — Bouton TinyMCE d'insertion d'un tag de liste (famille et source à choisir dans un picker, sur le modèle du bouton Tableaux)
- [ ] SP-PO4 — Écran de gestion des familles d'équipement (aujourd'hui : migration SQL, comme `dd_categorie_objet_magique`)
- [x] SP-PO5 — **Ruleset DD2024, équipement** : 28 familles propres au ruleset (armes courantes/de guerre × corps à corps/distance, armures, outils, matériel d'aventurier avec munitions/focaliseurs/symboles, montures et véhicules, repas, employés, services d'incantation), **238 articles** du SRD 5.2.1 avec leur description, 13 pages de règles manquantes (armes et propriétés/bottes, armures, outils, matériel, montures et véhicules, train de vie, repas, employés, sorts, fabrication, utilisation des objets magiques), 3 tableaux, listes `[[liste:equipement|…]]` aux emplacements prévus — `sql/2026-10-16_equipements_dd2024_srd_sp-po5.sql` et `sql/2026-10-16_regles_dd2024_equipement_sp-po5.sql`. Soldent `SP-E6`
- [x] SP-PO5b — **DD2024, objets magiques** : 8 pages de règles créées sous « Objets magiques » + page « Catégories » complétée (pages 215 à 220 du SRD : catégories, miscibilité des potions, règles, rareté et valeur, activation, objets maudits, résilience, fabrication, objets intelligents), page « Objets magiques de A à Z » en listes `[[liste:objet|famille=…|source=SRD 5.2.1]]` ; 9 tableaux de règles. **Descriptions des 357 objets de la source SRD retranscrites** depuis le PDF (tables aplaties ou absentes, paragraphes fusionnés, traits d'union perdus, « Yeux de lynx » manquant) : 34 nouveaux tableaux appelés par `[[tab:slug]]`, chapeau mille-sorts corrigé, 2 profils inclus au texte — `sql/2026-10-16_regles_dd2024_objets_magiques_sp-po5b.sql` et `sql/2026-10-16_objets_dd2024_srd_sp-po5b.sql` (journal : `doc/LOG_CORRECTIONS_SRD2024_OBJETS_MAGIQUES.md`)
- [ ] SP-PO6 — Possessions du personnage (inventaire, richesse, encombrement, objets harmonisés) dans le module Personnages — **à arbitrer** ; s'appuie sur `eqt_prix_pc` / `eqt_poids_g`

### SP-T — Transfert / Duplication d'opposition

- [x] SP-T0 — Transférer/Dupliquer vers une rencontre de la **même** campagne
- [ ] SP-T1 — Étendre vers une rencontre d'une **autre** campagne du MJ

### SP-TB — Tableaux de règles

- [x] SP-TB0 — SQL : `CREATE TABLE dd_tableaux`
- [x] SP-TB1 — Moteur `include/tableau-parser.php` : convention texte → HTML (en-têtes multi-niveaux, sections, alignements, notes)
- [x] SP-TB2 — Résolution du tag `[[tab:slug]]` dans `reg_texte` (vue règle + detail-pp)
- [x] SP-TB3 — UI : liste, formulaire, fiche détail, aperçu, enregistrement
- [x] SP-TB4 — Insertion depuis l'éditeur de règle : bouton TinyMCE + picker `#detail-pp-sub`
- [x] SP-TB5 — Migration des tableaux HTML existants (`sql/migrate_tableaux_sp-tb5.php`)
- [x] SP-TB6 — Portée du tag étendue à `mo_stats` (monstres)
- [x] SP-TB7 — Portée du tag étendue aux champs texte du compendium, composant CSS rendu global, bouton d'insertion TinyMCE généralisé aux 10 éditeurs
- [ ] SP-TB8 — Écran du MJ : alimenté par `tab_ecran_mj` / `tab_ecran_ordre`, mise en page
      multi-colonnes et impression
      — **débloquée** le 2026-08-24 par la livraison de SP-CP. Point d'entrée acté : le premier
      bouton de la colonne d'outils des pages Campagnes (`include/campagne-outils.php`), aujourd'hui
      inerte. Présentation retenue : ouverture dans `#detail-pp` (arbitrage SP-CP, question 1).
      Aucun tableau n'est encore coché `tab_ecran_mj` en base
- [ ] SP-TB9 — Saisie des tableaux du ruleset **DD3.5** (id 1) *(en cours au fil des lots SP-DRS — 15 tableaux livrés avec le lot 1)*
- [x] SP-TB10 — Gestionnaire sorti du module Règles (`tableaux/index.php`), servi par le moteur de liste partagé : filtres (source, écran du MJ, texte sur nom **et** slug), pagination, tri. Propagation du renommage de slug étendue aux 11 champs hôtes
- [x] SP-TB11 — Correctif d'affichage : le bouton Modifier des fiches détail (règle et tableau) passe dans le titre, il butait sur la croix de fermeture du panneau

### SP-GL — Liaison automatique des termes de glossaire

- [x] SP-GL0 — Moteur `include/glossaire-parser.php` : détection casse exacte, pluriel simple, zones HTML exclues
- [x] SP-GL1 — Branchement sur `reg_texte` (vue règle, `detail-pp/regle.php`) et sur les définitions de glossaire (`detail-pp-sub/glossaire.php`)
- [x] SP-GL2 — Handler `.glossaire-lien` déplacé de `js/regles.js` vers `js/main.js` ; style porté dans `css/modules.css`
- [x] SP-GL3 — Portée étendue aux champs texte du compendium (via rendreTexteEnrichi(), même liste de champs que SP-TB7)
- [ ] SP-GL4 — Saisie du glossaire du ruleset **DD3.5** (id 1) *(en cours au fil des lots SP-DRS — 63 termes livrés avec le lot 1)*

### SP-DRS — Import des règles DD3.5 (fichiers DRS)

> Import itératif des chapitres de règles du Document de référence du système v3.5 (~20 fichiers
> de règles sur les 40 du DRS ; les fichiers de données compendium sont hors périmètre). Chaque
> lot alimente au passage SP-TB9 (tableaux) et SP-GL4 (glossaire). Arbitrages du 2026-08-25 :
> arborescence **thématique** (pas un chapitre par fichier DRS), pages longues par section,
> mini-glossaire de termes techniques majeurs compilé au fil du traitement, ressource dédiée
> « DRS 3.5 ». Détails en §9b.

- [x] SP-DRS0 — Socle : ressource « DRS 3.5 », racines thématiques (Bases, Combat, Aventure et environnement, Créatures et pouvoirs spéciaux, Glossaire) — `sql/2026-08-25_regles_dd35_socle.sql`
- [x] SP-DRS1 — Lot 1 : DRS 01 (caractéristiques), 10 (combat), 12 (extérieur/climat), 18 (pouvoirs et états), 19 (types et sous-types) + 15 tableaux + 63 termes de glossaire — `sql/2026-08-25_regles_dd35_drs*.sql` et `_glossaire_lot1.sql`
- [x] SP-DRS2 — Lot 2 : **DRS 07 (Équipement)** — racine « Équipement » (ordre 40), 13 pages (monnaie, catégories et attributs des armes, listes, armes de maître, attributs des armures, armures de maître et pour créatures inhabituelles, enfiler/ôter, marchandises et services, bardes, lancement de sorts) + 6 tableaux + 12 termes de glossaire — `sql/2026-10-11_regles_dd35_drs07_sp-drs2.sql`. Les listes d'articles sont des tags `[[liste:equipement|…]]`. La racine « Créatures et pouvoirs spéciaux » passe de 40 à 60
- [x] SP-DRS3 — Lot 3 : **DRS 23 (Objets magiques)** — racine « Objets magiques » (ordre 50), 13 pages (catégories, détection, utilisation, taille, emplacements et affinités, sauvegardes / dégâts / réparation, charges, description, création ×4, estimation du prix, catalogue) + 11 tableaux + 9 termes — `sql/2026-10-11_regles_dd35_drs23_sp-drs3.sql`. Les fiches d'objets (DRS 24 à 28) sont des données du compendium, hors périmètre
- [ ] SP-DRS4 — Lot suivant : prochains fichiers DRS présentés par l'utilisateur (ordre d'affichage = ordre de présentation des lots)

### SP-IM — Import des données manquantes (compendium)

> Cycle d'import ouvert le 2026-08-28 : remplir les deux rulesets avant de reprendre le
> développement, une base complète rendant les tests de la fiche personnage réalistes.
> Premier lot : les **classes DD2024**, depuis `FR_SRD_CC_v5.2.1-classes.pdf`.
> Arbitrages du 2026-08-28 : `DECISIONS_LOG.md` D-IM1 à D-IM4.

- [x] SP-IM0 — Cadrage classes DD2024 : dépouillement du SRD, relevé des écarts en base, arbitrages
- [x] SP-IM1 — Socle des 12 classes de base : traits de base (dé de vie, sauvegardes, armes, armures, outils, équipement, caractéristique principale) + 87 lignes `dd_classe_competence` — `sql/2026-08-28_classes_dd2024_sp-im1.sql`
- [x] SP-IM2 — Tables de progression : 240 lignes `dd_classe_niveau` (bonus de maîtrise, emplacements, sorts mineurs et préparés, colonnes de pouvoir) + intitulés `cla_pouvoir1..5` — `sql/2026-08-28_classes_dd2024_sp-im2.sql`
- [x] SP-IM3 — Capacités de classe : 186 capacités et 258 affectations niveau par niveau, ids figés à partir de 601 — `sql/2026-08-28_classes_dd2024_sp-im3.sql`
- [x] SP-IM4 — Sous-classes du SRD : 10 créées (ids 70-79, source 93) + 2 réalignées, 58 capacités (ids 801+) — `sql/2026-08-28_classes_dd2024_sp-im4.sql`
- [x] SP-IM5 — Options du SRD importées comme **dons**, dans deux nouvelles catégories `dd_data_don` (22 « Métamagie », 23 « Manifestation occulte »), sur le modèle de la 21 « Style de combat » : 10 options de Métamagie + 28 Manifestations occultes, prérequis en `do_conditions` — `sql/2026-08-28_options_dd2024_sp-im5.sql`. **Périmètre réduit à l'analyse** : les 10 styles de combat étaient déjà en base, et les bottes d'arme sont des propriétés d'arme → `SP-E6`
- [ ] SP-IM6 — `cla_description` des 8 classes DD2024 sans texte de présentation. **Le SRD 5.2.1 n'en contient aucun** (les sections démarrent sur l'encadré des traits de base) : la saisie doit venir du Manuel des Joueurs 2024, à la main
- [x] SP-IM7 — Fiche de classe DD2024 alignée sur l'encadré « Traits de base » du SRD : ajout de Caractéristique principale, Maîtrises d'outils et Équipement de départ (jusque-là saisissables mais affichés nulle part), libellés et ordre repris du document. **Sémantique de `dd_classe_competence` tranchée** : en DD2024 la table liste les compétences éligibles et `cla_pointsCompetences` porte le nombre à choisir (« 2 au choix parmi : … ») — champ ajouté au formulaire DD2024, sans quoi chaque enregistrement le remettait à 0 — `sql/2026-08-28_classes_dd2024_sp-im7.sql`
- [x] SP-IM8 — **Espèces DD2024** : les 9 espèces du SRD (4 créées — Drakéide, Goliath, Orc, Tieffelin — et 5 réalignées), 33 traits spéciaux (ids 901+) et les 3 tables du SRD portées dans `dd_tableaux` (`ancetres-draconiques`, `lignages-elfiques`, `heritages-fielons`) — `sql/2026-08-28_races_dd2024_sp-im8.sql`
- [x] SP-IM9a — **Objets magiques DD2024, redressement** : 235 objets de la source SRD réalignés — description complète (225), rareté, harmonisation et catégorie déduites de la ligne de type du SRD — `sql/2026-08-28_objets_dd2024_sp-im9a.sql`
- [x] SP-IM9b — Les **121 déclinaisons** d'entrées génériques redressées : texte du générique propagé (table exclue), rareté propre lue dans les tables du SRD, catégorie et harmonisation du générique. Pour Pierre de Ioun, Plume magique et Figurine merveilleuse, la description reprend le chapeau **puis le seul paragraphe de la variante** — `sql/2026-08-28_objets_dd2024_sp-im9b.sql`
- [x] SP-IM9c — Les **10 objets dont le texte du SRD porte une table** : 10 tables saisies dans `dd_tableaux` (ids 43-52) et descriptions réécrites avec le tag `[[tab:slug]]` — `sql/2026-08-28_objets_dd2024_sp-im9c.sql`. Les 6 autres entrées à table du SRD sont des génériques sans ligne en base, leurs déclinaisons ayant été traitées en IM9b
- [x] SP-IM9d — Dons et historiques : **déjà saisis** (SRD complet + une partie du MdJ), rien à importer — vérifié en base le 2026-08-28

### SP-MA — Référentiel de la magie

> Chantier **transverse** ouvert le 2026-08-27 : le référentiel magie alimente le compendium Sorts,
> le compendium Classes et le module Personnages, et a une vie propre au-delà de la fiche (écran du
> MJ, monstres lanceurs de sorts). Même logique que `SP-TB`, parti du module Règles pour devenir
> autonome. Analyse fonctionnelle complète : `METIER_7_SORTS.md`. Arbitrages Q1, Q4 et Q5 rendus —
> `DECISIONS_LOG.md` [2026-08-27] D-MAG1 à D-MAG4. **Q2, Q3, Q6, Q7 et Q8 restent ouvertes** et
> conditionnent `SP-MA0` (Q2), `SP-MA4` (Q3, Q6, Q7) et `SP-PE7` (Q8).

- [x] SP-MA0 — Référentiel des classes lanceuses : champ `cla_profil_incantation` (4 profils, `dd_variables` cat. `profinc`, constantes `PROFINC_*`) remplaçant les 3 drapeaux `cla_sort_*` dépréciés ; `cla_mag_id` recadré par ruleset (DD3.5 `0/1/2`, DD2024 `0/1`) ; `cla_car_id` des 4 classes DD2024 ; `cla_domaine_divin` du Prêtre ; libellé `dd_typemagie` et filtre de liste conditionnés au ruleset. **Patch SQL à appliquer en prod** : `sql/2026-08-27_profil_incantation_sp-ma0.sql`
- [x] SP-MA1 — Sorts bonus de caractéristique : `bonusSortsCarac()` et `peutLancerNiveau()` dans `helpers.php`, **par formule et non par table** (arbitrage : une table plafonnée rend 0 en silence hors plage). `modCarac()` / `formatMod()` déplacés depuis `personnage_helpers.php`. `dd_modificateurs` devient morte. Aucun patch SQL
- [x] SP-MA2 — `dd_classe_niveau` DD2024 : les 12 classes ont désormais leurs 20 niveaux complets, emplacements de sort compris. **Livré par `SP-IM2`** le 2026-08-28 (le Moine manquait aussi, en plus de l'Occultiste et du Rôdeur)
- [x] SP-MA3 — Registre DD3.5 : champ `so_registre`, classifieur à deux listes fermées (18 branches et disciplines, 22 registres), migration rejouable adossée à une table de sauvegarde — 673 sorts nets, 7 partiels, 10 laissés intacts (données de domaine égarées → `SP-MA5`). Fiche, formulaire et **filtre Registre** de la liste. **À passer en prod** : `sql/2026-08-27_registre_sp-ma3.sql` puis `sql/2026-08-28_registre_sp-ma3_donnees.sql` (SQL pur, applicable depuis phpMyAdmin). Le script PHP `migrate_registre_sp-ma3.php` qui avait produit ces UPDATE **n'existe plus** — sans conséquence, la sortie figée en SQL lui est équivalente (empreinte MD5 contrôlée le 2026-08-28)
- [x] SP-MA4a — **Sorts toujours préparés DD2024** : table `dd_classe_sort` (+ `cs_variante` pour les 4 terrains du Cercle de la Terre) et **67 lignes du SRD** sur 9 porteurs — 3 sorts de classe et 6 sous-classes. Colonne `pesp_origine` sur `dd_personnages_sorts_prepares` pour les sorts toujours préparés **choisis** (Secrets magiques du Barde niv. 10, Sorts de prédilection du Magicien niv. 20, Arcanum de l'Occultiste). 67 noms résolus en `so_id` sans ambiguïté. **Patch SQL à passer en prod** : `sql/2026-09-01_sorts_toujours_prepares_sp-ma4a.sql`
- [x] SP-MA4b — **Cadence de renouvellement** *(Q3 tranchée le 2026-09-01, option a)* : colonne `cla_renouvellement` -> `dd_variables` cat. `cadence` (3 valeurs, constantes `CADENCE_*`), 19 classes lanceuses renseignées — dérivées du profil en DD3.5, table du SRD en DD2024. Select au formulaire, ligne à la fiche. **Patch SQL à passer en prod** : `sql/2026-09-01_cadence_renouvellement_sp-ma4b.sql`
- [ ] SP-MA4c — Reliquat non bloquant : **école de prédilection et écoles interdites du magicien DD3.5** (+1 sort préparé par niveau de sort, 2 écoles interdites — filtre le compendium à la source). Seul élément de `SP-MA4` encore ouvert
- [x] SP-MA6a — Classes de prestige DD3.5, formulaire : bascule « Sorts par jour » / « Progression du NLS » dans la section 2, trois cases par niveau (Profane, Divin, Au choix), section 1 neutralisée en mode NLS, colonnes de sorts visibles pour une prestige même sans type de magie
- [x] SP-MA6b — Enregistrement : exclusivité garantie côté serveur (mode NLS → classe non lanceuse et sorts à NULL ; mode Sorts → drapeaux à 0), drapeaux écrits pour les prestiges seulement. **Migration** `sql/2026-10-10_drapeaux_nls_sp-ma6.sql` (drapeaux NULL → 0, sorts à 0 des prestiges du cas 2 → NULL)
- [x] SP-MA6c — Fiche de la classe : une colonne « Sorts par jour » rédigée en forme courte (« +1 niv. profane »…) pour une prestige qui fait progresser le NLS
- [x] SP-MA6d — Suites : drapeaux NLS des classes de base remis à 0 (**migration** `sql/2026-10-10_drapeaux_nls_classes_base_sp-ma6.sql`), distinction NULL / 0 des sorts par jour DD3.5 vérifiée de bout en bout, table de progression sans colonnes de sorts resserrée sur téléphone (`.table-dd--etroite`)
- [ ] SP-MA6e — Archer-Mage (DD3.5) : cocher ses drapeaux de progression du NLS dans le formulaire (saisie, aucun code)
- [ ] SP-MA5 — Complétion `dd_sortdomaine` : 147 lignes sur 45 domaines (table `dd_domaines` : 72), le SRD seul en demande ~207 pour ses 23 domaines

### SP-PE — Module Personnages

> Anciennement numéroté « sous-phases 3.0 à 3.7 » (§7.11). Renuméroté en `SP-PE` le 2026-08-12
> pour rejoindre le tableau de bord — c'était le seul chantier du projet qui n'y figurait pas.
> Table de correspondance dans `DECISIONS_LOG.md` [2026-08-12].

- [x] SP-PE0 — Socle + SQL : `dd_alignements`, `pe_sexe`/`pe_al_id`/`pe_notes_scope`, liste `index.php`, routeur `enregistrement.php`, helpers, assets *(ex-3.0)*
- [x] SP-PE1 — Fiche identité : overlay `modifier/personnage.php`, `detail-pp/personnage.php`, blocs Identité / Caracs / Combat / Background, première classe à la création *(ex-3.1)*
- [x] SP-PE2 — Classes & niveaux : éditeur DOM inline sur la fiche, domaines divins DD3.5, action `enregistrerClasses` *(ex-3.2)*
- [x] SP-PE3 — Compétences : éditeur inline filtrable sur le tableau complet du ruleset, rangs DD3.5 / 0-1-2 DD2024, total affiché, persistance DELETE+INSERT des `pec_maitrise > 0` *(ex-3.3)*
- [x] SP-PE4 — Dons : sélecteur deux volets dans `#detail-pp` (liste filtrable + fiche du don), écriture immédiate par clic, compteur serveur *(ex-3.4)*
- [x] SP-PE5 — Bloc Campagnes de la fiche : campagne en cours + historique traversé, éditeur inline de rattachement à écriture immédiate, section Personnages du panneau de campagne, correctif `getActiveResIds()` priorité 1
- [x] SP-PE6 — NLS prestige (DD3.5) : un tableau par classe de prestige, affectation par niveau vers les classes de base lanceuses compatibles, commit global du bloc (action `enregistrerNls`), affectation partielle autorisée *(ex-3.5)*
- [x] SP-PE7a — **Helpers de calcul de la magie** : `getMagieContexte()` rend une entrée par classe lanceuse (profil, cadence, caractéristique, DD, NLS effectif, emplacements décomposés, plafonds, sorts toujours préparés, avertissements), plus 5 auxiliaires — `progressionLanceurComplet()`, `ligneNiveauClasse()`, `sortsToujoursPrepares()`, `nlsEffectif35()`, `niveauIncantateur2024()`. Validé par banc d'essai sur 4 cas dont l'**ensorceleur 8 / prêtre 6 DD3.5** et un **paladin 6 / occultiste 5 DD2024**, personnages synthétiques créés en transaction annulée. **Deux patchs SQL** : `sql/2026-09-01_cn_sort_null_vs_zero_sp-pe7a.sql` (distinction NULL / 0 rétablie chez le Prêtre et l'Élu divin) et `sql/2026-09-01_decalage_paladin_rodeur_sp-pe7a.sql` (tables du Paladin et du Rôdeur décalées d'une colonne)
- [x] SP-PE7b — **Vue Magie** : `personnages/magie.php` (une section par classe lanceuse — synthèse, tableau d'emplacements décomposé au survol, sorts toujours préparés non décomptés, listes du personnage), sélecteur deux volets `detail-pp/sorts-picker.php` **porté par classe** et à deux modes (réservoir / préparation), module JS `sortsPicker`, et 6 actions d'écriture immédiate dans `personnages/enregistrement.php` — dont « Recopier dans le grimoire » et « Réinitialiser la liste préparée », qui préserve les sorts toujours préparés
- [ ] SP-PE8 — Emplacement Mode jeu (suivi PV et variables par ruleset) + passe responsive < 992px sur les blocs livrés en SP-PE3→PE7 *(ex-3.7)*
- [x] SP-PE9 — Visibilité admin de la liste : `personnages/index.php` lève le scope propriétaire pour un administrateur (colonne + filtre « Joueur », filtre Campagne étendu à tout le ruleset). Aucun droit nouveau — les accès unitaires reposaient déjà sur `canAccess()`
- [ ] SP-PE10 — **Compaction de l'interface personnage** — passe de resserrement des écrans du module, sous-phase par écran (voir `DECISIONS_LOG.md` [2026-09-19] D-RS45)
  - [x] SP-PE10a — Fiche, bloc Identité : race / historique / sexe / alignement sur une seule rangée, ligne Classes en pleine largeur et en fin de bloc, `.per-identite` en flex
  - [x] SP-PE10b — Vue Magie : corps en trois temps (cases + actions, puis tableau des emplacements et panneau « Ressources de sorts » côte à côte, puis les listes), compteurs regroupés dans le panneau selon le profil d'incantation, listes de sorts en flux à écart fixe
  - [x] SP-PE10c — Vue Magie, tableau des emplacements : au-dessus de 992px, `.table-dd` est surchargé pour prendre l'échelle typographique du panneau « Ressources de sorts » qui lui fait face ; séparateur accentué neutralisé sur cette table
  - [x] SP-PE10d — Sélecteur de sorts : styles du composant (aucun n'existait), ligne retenue teintée, volet de description masqué sous 992px au profit de `#detail-pp-sub`, filtre « Les préparés seulement », bouton « grimoire » posé et retiré au fil des bascules
  - [x] SP-PE10e — Préparation DD3.5 : un sort se prépare **plusieurs fois**, la ligne porte un compteur `[−] N [+]` et `pesp_nb` est incrémenté / décrémenté ; les jetons de niveau somment les exemplaires. DD2024 inchangé (ensemble de sorts distincts)
  - [x] SP-PE10f — Sélecteur de sorts, compacité : le niveau passe de la pastille de chaque ligne à un en-tête `sticky` par groupe (masqué avec son groupe au filtrage), cadre du compteur retiré, compteur resserré sur téléphone
  - [x] SP-PE10g — Sélecteur de sorts sur téléphone : la liste perd son cadre et déborde du padding du panneau (nom du sort à 303px sur 375px de viewport)
  - [x] SP-PE10h — Compactage de la fiche : en-tête du site sur téléphone (burger en icône, raccourci personnage pleine largeur), bloc Identité refondu (rangée de champs, classes sans libellé, sous-classes entre parenthèses, prestige en italique), caractéristiques en 2×3 et tuiles CA / PV sur une rangée, boutons réduits à leur icône. **Défaut corrigé** : le niveau total comptait les sous-classes
  - [x] SP-PE10i — Caractéristiques sur téléphone : une ligne chacune (abréviation / valeur / modificateur), à la façon du bloc de stats d'un monstre ; tuiles CA / PV resserrées en conséquence ; derniers libellés de boutons retirés, avec un `title` qui suit la bascule
  - [x] SP-PE10j — Règle de graisse (libellé gras / valeur normale, même taille) appliquée à l'identité, aux classes et aux tuiles CA / PV ; lignes resserrées sur compétences, dons et NLS ; colonne Carac élargie, maîtrise abrégée « M. » / « E ». **Défaut corrigé** : le bonus de maîtrise tombait à zéro au-delà du niveau 20
  - [x] SP-PE10k — Titre du bloc Identité retiré ; sur téléphone, Retour et Modifier reviennent côte à côte sur la ligne du nom (la surcharge qui les empilait datait de leurs libellés)
  - [x] SP-PE10l — Bloc « Mode jeu » optionnel (préférence `j_affichage_mode_jeu`, **patch SQL**, masqué par défaut) ; tuile **bonus de maîtrise** dans la rangée de stats en DD2024 ; forme compacte des caractéristiques étendue à l'ordinateur (220 → 87px)
  - [x] SP-PE10m — Caractéristiques agrandies (valeur en couleur, abréviation sans fond), « BM » sur la tuile de maîtrise, et **Compétences / Dons côte à côte** au-dessus de 992px — le NLS passe sous la rangée
  - [x] SP-PE10n — Bloc NLS prestige repliable, **fermé par défaut** ; `perDeplierBloc()` ouvre le bloc quand on lance son éditeur depuis l'état replié
  - [x] SP-PE10o — Caractéristiques en colonnes de largeur fixe (`min-width: 0` compris), alignées verticalement d'un rang à l'autre ; largeurs recalculées sous 992px
  - [x] SP-PE10p — Vue Magie, synthèse de classe : les quatre cases et le panneau « Ressources de sorts » fusionnent en paires libellé / valeur (caractéristique, NLS, DD, attaque, sorts mineurs, renouvellement, domaines) — en colonne à gauche du tableau des emplacements sur ordinateur, en ligne au-dessus sous 992px
  - [x] SP-PE10q — Vue Magie, tableau des emplacements : une seule rangée d'en-tête (« Niv. » en case d'angle), en-tête en retrait à .85rem, « En stock » renommé « Restant »
  - [x] SP-PE10r — Vue Magie, listes en onglets : Préparés (par défaut) · Grimoire · À recopier, compteur dans chaque onglet, aide et actions de l'onglet actif à droite de la barre, une ligne par niveau de sort (pastille en tête), sorts toujours préparés dans le premier onglet, onglet actif mémorisé par bloc en `sessionStorage`
  - [x] SP-PE10s — Vue Magie, retouches : « Réinitialiser » déplacé dans le sélecteur de préparation, boutons d'onglet en icône seule ; **défaut corrigé** — en DD2024 les sorts mineurs comptaient dans le plafond de sorts préparés (vue Magie et sélecteur)
- [x] SP-PE11 — Initiative (`pe_init`) et six modificateurs de sauvegarde (`pe_*_save`) — **patch SQL** ; bonus de maîtrise accolé au niveau global en DD2024 ; jets de sauvegarde en 4e colonne (DD2024) ou en bloc Réflexes / Vigueur / Volonté (DD3.5) ; rangée **Capacités de race / de classe**. **Défaut corrigé** : `.modif-grid` n'était pas chargée sur la fiche personnage
- [x] SP-PE12 — Graisse : les valeurs d'initiative et de sauvegarde reviennent à la règle du module (gras au libellé seul)
- [x] SP-PE13 — En-têtes MOD / SAUV un par colonne (DD2024) ; composant `.sort-detail` déplacé de `compendium-modules.css` vers `modules.css` — les panneaux de détail ouverts hors du compendium perdaient leurs styles

> Hors périmètre SP-PE : les **objets magiques du personnage** (`personnages/objets.php` reste un
> placeholder, aucune table) — analyse métier non fiabilisée, cf. `DECISIONS_LOG.md` [2026-06-12] [D].

### SP-SC — Sous-classes DD2024 (module Classes)

> Chantier livré avant la généralisation des codes projet ; codifié le 2026-08-22 pour rejoindre
> le tableau de bord. Détail technique en §5 « Module Classes — sous-classes (DD2024) ».

- [x] SP-SC0 — Socle : `cla_cla_id` comme classe parente, type `clt_id=5`, formulaire à bascule, neutralisation serveur, fiche détail avec renvoi vers la classe parente
- [x] SP-SC1 — Finitions liste et fiche : classe de base rappelée dans la colonne Type, critère « Classe parente » conditionnel dans la barre de filtre (clé moteur `submit_onchange`), fiche alignée sur `.sort-detail__row` (Dé de vie → Formation aux armures), retrait de « Niveaux » en DD2024, liste des sous-classes sur la fiche d'une classe de base
- [x] SP-SC2 — Capacités spéciales de la fiche : requête unique agrégée (une capacité = une entrée, titrée par son premier niveau), libellé de section supprimé, titres en accent `1.2rem`, espacement porté en CSS avec palier 991px

### SP-RS — Finalisation de l'UI smartphone

- [x] SP-RS0 — Mode debug : badge dimensions viewport + paliers actifs, bascule dans le tableau de bord admin (session)
- [x] SP-RS1 — Menu principal transformé en menu déroulant pleine largeur sous 992px
- [x] SP-RS2 — Bandeau de contexte en fil d'Ariane défilable sur une ligne (150px → 57px), icônes de type, cibles 40px
- [x] SP-RS3 — Listes du compendium : menu ⋮ restauré et recadré, menu Sources empilé, cibles tactiles à 40px
- [x] SP-RS3b — Barre de filtrage promue en composant partagé (`modules.css` + `main.js`), module Personnages aligné dessus
- [x] SP-RS4 — Panneaux en feuille plein écran sous 992px, barre d'en-tête commune, `dvh`, Fermer ajouté sur `#modification`
- [x] SP-RS6a — Page Personnages : raccourci personnage remonté dans la ligne de titre du header, bouton d'ajout en icône seule, ruleset retiré du `<h1>`
- [x] SP-RS6b — Moteur de liste rendu générique (6 clés optionnelles), Personnages migré, JS des listes promu dans `main.js`
- [x] SP-RS6d — Ajustements de la liste et de la fiche personnage (gras, campagne détachée, en-tête en grille, Mode jeu repliable, Classes dans Identité, Combat côte à côte, Dons en deux colonnes)
- [x] SP-RS6e — Bloc Compétences de la fiche rendu comme le bloc Dons (liste flex + ligne d'en-tête en gras)
- [ ] SP-RS6c — Unification complète : replier les 7 capacités d'`admin-liste.php` dans le moteur, migrer `admin/utilisateurs.php`, `admin/ressources.php` et `campagnes/index.php`, supprimer `admin-liste.php`, aligner le CSS du menu ⋮ de l'admin
- [x] SP-RS5a — Collecte des relevés d'affichage : beacon, `dd_joueurs.j_last_*`, `dd_connexions`, écran admin
- [ ] SP-RS5 — Arbitrage des paliers définitifs (991 / 768 / 479) à partir des relevés accumulés dans `dd_connexions`

### SP-CP — Refonte du module Campagnes

> Le module quitte `#detail-pp` : chaque niveau de la hiérarchie devient une vraie page, avec son
> URL, son bouton retour et une colonne d'outils de partie. Arbitré et livré le 2026-08-24 —
> détail en §8 et dans `DECISIONS_LOG.md` [2026-08-24].

- [x] SP-CP0 — SQL : `re_ordre` et `opp_ordre` + backfill alphabétique (`sql/2026-08-24_ordre_sp-cp.sql`)
- [x] SP-CP1 — Socle transverse : `js/tri-liste.js` (glisser-déposer générique) et `notifier()` (pastille d'enregistrement automatique) — voir §12b
- [x] SP-CP2 — Actions `reordonner{Scenarios,Chapitres,Rencontres,Oppositions}` : contrôle de propriété sur le parent, lot complet exigé, une transaction
- [x] SP-CP3 — Gabarit deux colonnes 1/4–3/4 (cible 1536 × 799), colonne d'outils sticky, repli sous 992px
- [x] SP-CP4 — Pages `campagne.php` / `scenario.php` / `chapitre.php` / `rencontre.php`, oppositions en cartes à stats dépliées
- [x] SP-CP5 — Fil d'Ariane du header en liens pleine page ; suppression des 4 handlers `detail-pp/*` du module et du sous-panneau `detail-pp-sub/opposition.php` devenu orphelin
- [x] SP-CP6 — `js/campagne.js` aligné (suppressions par fabrique, lignes `data-href`), listes sans colonne code/abrév — préfixe `CODE : Nom`, ordre retiré des formulaires
- [x] SP-CP7 — Documentation : §0, §8, §12, §12b, `ARCHITECTURE_8_CAMPAGNES.md`, `SCHEMA_SQL.md` v1.6, `DECISIONS_LOG.md`
- [ ] SP-CP8 — Garnir la colonne d'outils : liste des aides de jeu à arbitrer (seul l'écran du MJ est identifié, cf. SP-TB8)

### SP-AD — Ajustements de la zone d'administration

> Chantier d'entretien du module Admin (§6) : ajouts ponctuels aux écrans Utilisateurs et
> Ressources, sans refonte. La migration des deux listes vers le moteur partagé reste suivie
> sous SP-RS6c.

- [x] SP-AD0 — Changement du mot de passe d'un utilisateur par l'administrateur : section facultative du formulaire d'édition (nouveau + confirmation), validation serveur, invalidation du lien de réinitialisation en attente

### SP-RB — Bascule de ruleset depuis le header

> Le badge du ruleset actif devient un switch DD3.5 / DD2024 ; chaque ruleset garde son propre
> contexte de navigation en session. Voir §3 « Bascule depuis le header ».

- [x] SP-RB0 — Bouton de bascule dans le header (ruleset actif + icône ⇄) (`profil/ruleset.php`, POST + CSRF), contexte de navigation mémorisé par ruleset (`basculerRuleset()`), rechargement de la page équivalente (`pageEquivalenteRuleset()`), profil aligné sur le même mécanisme

### SP-DP — Déploiement en production et migrations SQL

> Transfert SFTP du poste local vers OVH et application des migrations par le serveur. Module
> local `admin/deploiement/`, jamais transféré ; moteur de migrations déployé. Voir §6b.

- [x] SP-DP0 — Hygiène du périmètre : `.deployignore` (doc, scss, dumps SQL, phpinfo…), `.htaccess` refusant tout accès web à `sql/` et `config/`
- [x] SP-DP1 — Paramétrage (`admin/deploiement/index.php`) : fichier privé hors projet, lecture et épinglage de l'empreinte SSH du serveur, test de connexion de bout en bout
- [x] SP-DP2 — Périmètre calculé par git (`.gitignore` + `.deployignore` + exclusions fixes), aperçu des exclusions et de leur règle
- [x] SP-DP3 — Manifeste distant (hors `www/`), aperçu à blanc : nouveaux, modifiés, retirés en local
- [x] SP-DP4 — Bouton du header, panneau de confirmation, transfert par lots, mode maintenance, verrou, reprise / abandon, journal
- [x] SP-DP4b — Correctif : module visible par l'adresse réseau du poste (`http://192.168.1.10/donjon/`), pas seulement par `localhost`
- [x] SP-DP4c — Correctif : suppression SFTP en chemin relatif (le préfixe `/~/` n'est pas traduit dans les commandes SFTP), et plus aucun échec de suppression ignoré — la production restait en maintenance
- [x] SP-DP5 — Moteur de migrations (`include/migrations.php`, table `dd_migrations`, référence initiale des 37 migrations antérieures, écran `admin/migrations.php`)
- [x] SP-DP6 — Application automatique en production : jeton à usage unique déposé par SFTP, point d'entrée `admin/migrations-auto.php`
- [x] SP-DP7 — Premier déploiement réel (2026-10-10) : 181 fichiers envoyés, 1 migration appliquée en production
- [x] SP-DP8 — Action « Remettre en attente » (admin/migrations.php) et requête de diagnostic `sql/diagnostic_reference_sp-dp.sql`

### SP-XC — Export de classes vers la production

> Recopie en production des classes choisies avec toutes leurs données, par une migration générée
> dans `sql/`. Voir §6d.

- [x] SP-XC0 — Arbitrage : clés naturelles, classe écrasée, capacités mises à jour, liste de sorts incluse par défaut, seules les classes cochées, transport par `sql/` (D-XC1 → D-XC4)
- [x] SP-XC1 — Générateur `admin/deploiement/export-classes-lib.php` : garde-fous avant écriture, résolution par les noms, script rejouable
- [x] SP-XC2 — Page `admin/deploiement/export-classes.php` (aperçu, écriture de la migration marquée appliquée en local), tuile de l'administration et lien depuis Déploiement
- [x] SP-XC3 — Documentation (§6d, D-XC1 → D-XC4) et vérification sur une copie de la base
- [ ] SP-XC4 — Premier export réel joué en production par le déploiement (à confirmer à l'usage)
### SP-SY — Synchronisation du contenu local → production

> **En attente d'arbitrage, non prioritaire** (mis de côté le 2026-10-10). Ajouter en production
> le contenu saisi en local qui y manque, sans jamais rien écraser ni effacer. Voir §6c.

- [ ] SP-SY0 — Arbitrage des 5 questions de §6c (plages d'identifiants, périmètre de tables, modifications locales, suppressions faites en prod, forme de l'outil)
- [ ] SP-SY1 — Plages d'identifiants séparées : migration qui fait démarrer les compteurs AUTO_INCREMENT de la prod à 1 000 000 sur les tables synchronisées
- [ ] SP-SY2 — Export du contenu local en `INSERT IGNORE` (données seules, périmètre arbitré, tables de travail exclues)
- [ ] SP-SY3 — Application en production (dépôt SFTP + jeton, comme les migrations) et compte rendu par table : lignes ajoutées, lignes ignorées sur une autre contrainte d'unicité
- [ ] SP-SY4 — Bouton « Synchroniser le contenu » dans le module de déploiement, toujours après les migrations
- [ ] SP-SY5 — Selon arbitrage : mémoire des suppressions faites en prod, propagation des modifications du contenu officiel

---

## 1. Philosophie technique

- PHP classique sans framework (pages contrôleurs + includes)
- JS vanilla, CSS maison
- PDO exclusivement — prepare/execute sur toutes les requêtes
- htmlspecialchars systématique via h() sur toute sortie HTML
- Token CSRF sur tous les formulaires POST et endpoints AJAX sensibles
- Balises PHP : <?php pour les blocs logiques, <?= pour l'affichage inline
- Syntaxe alternative PHP sans accolades sauf pour function() et class
- Indentation : 2 espaces
- CSS par module : `$css_module` charge conditionnellement `[module]-modules.css` (même pattern que `$js_module`)

### URL de base — règle absolue

define('BASE_URL', '/donjon') dans config/db.config.php (chargé par require_once dans include/db.php).

Toutes les URLs du projet passent par BASE_URL — aucune URL absolue codée en dur.

| Contexte | Syntaxe |
|---|---|
| Lien HTML | href="<?= BASE_URL ?>/chemin/page.php" |
| Attribut action | action="<?= BASE_URL ?>/chemin/page.php" |
| Redirection PHP | header('Location: ' . BASE_URL . '/chemin'); |
| Asset CSS/JS | href="<?= BASE_URL ?>/css/main.css" |

### config/db.config.php — fichier commun DEV / OVH (détection automatique)

Depuis le 2026-07-04, `config/db.config.php` est un fichier **unique et strictement
identique** sur les deux hébergements (local XAMPP et OVH prod). Il n'est plus
composé de deux versions distinctes maintenues séparément : il embarque les deux
jeux d'identifiants et choisit le bon au runtime.

Détection : `$_SERVER['HTTP_HOST']` (repli sur `SERVER_NAME`) est comparé au
domaine de production `maikastel.fr`. Match → jeu OVH ; sinon → jeu local (repli
par défaut, y compris si le hôte est vide, par exemple en CLI).

```php
$domaineHote = $_SERVER['HTTP_HOST'] ?? ($_SERVER['SERVER_NAME'] ?? '');

if (strpos($domaineHote, 'maikastel.fr') !== false):
  // identifiants OVH
else:
  // identifiants locaux (XAMPP) — défaut de repli
endif;
```

Conséquence : écraser accidentellement `config/db.config.php` d'un environnement
avec la version de l'autre (transfert FTP/zip complet, mauvaise manipulation de
déploiement) n'a plus d'impact — le fichier se reconnaît lui-même. Voir D-CFG1
dans DECISIONS_LOG.md pour la décision complète et ses limites (CLI hors contexte
web non couvert par ce mécanisme).

Le fichier reste exclu du dépôt git (`.gitignore`) ; `config/db.config.example.php`
documente la structure pour un nouvel environnement, mais ne doit plus être copié
tel quel pour OVH et local séparément : c'est désormais le même fichier physique
qui est déployé aux deux endroits.

#### Diagnostic renforcé (D-CFG2, suite à échec OVH)

Le déploiement du fichier unique a produit un 503 `"Err1"` sur OVH (connexion PDO
en échec) alors que le local fonctionnait, sans que la cause exacte soit
consultable à distance. `include/db.php` journalise désormais, à chaque échec de
connexion, l'environnement détecté (`DEV_MODE`), l'hôte extrait de `DB_DSN` et
`$_SERVER['HTTP_HOST']` — **jamais** `DB_USER` ni `DB_PASS`. Objectif : distinguer
en un coup d'œil dans le log serveur si le problème vient d'une mauvaise branche
de détection (D-CFG1 : l'environnement détecté ne correspond pas à l'hébergement
réel) ou d'identifiants OVH invalides (mot de passe, utilisateur ou hôte MySQL
incorrects). Diagnostic définitif en attente de consultation du log OVH par
Jean-Michel.

---

## 2. Contexte technique

| Élément | Choix |
|---|---|
| Langage serveur | PHP classique sans framework |
| Base de données | MySQL — PDO exclusivement |
| Front-end | JS vanilla, CSS maison |
| Hébergement prod | OVH — http://maikastel.fr/donjon/ |
| Développement local | XAMPP — http://localhost/donjon/ |
| Versioning | GitHub — repo Bigtono/donjon |
| Éditeur | VS Code + plugin Claude Code |

### Conventions base de données

- Tables préfixées dd_, en local comme en production (base OVH distincte). Le renommage en
  dd2_ envisagé à l'origine n'a jamais été appliqué : le code porte `dd_` en dur (confirmé le
  2026-10-07, cf. D-DP7)
- Champs préfixés par table (ex : pe_ pour dd_personnages)
- Premier champ = id index de la table
- _j_id = propriétaire → dd_joueurs
- _camp_id = campagne → dd_campagnes
- _res_id = ressource/livre → dd_ressources
- _ruleset_var_id = version de règles → dd_variables

---

## 3. Versions de règles (rulesets)

| ID | Nom | Répertoire templates |
|---|---|---|
| 1 | DD3.5 | include/insert/DD3.5/ |
| 2 | DD2024 | include/insert/DD2024/ |

Sélection via $_SESSION['rulesetRep'] — whitelist stricte.
Les templates ruleset ne contiennent que du HTML, jamais de logique auth/session/redirection.

### Le ruleset d'une entité n'est jamais saisi — règle absolue

Aucun formulaire ne propose de choisir le ruleset d'une entité, et **aucun ne le poste** : ni select,
ni champ caché. Il est déterminé côté serveur par un point de passage unique, `rulesetEnregistrement()`
(`include/helpers.php`) :

```php
$ruleset_id = rulesetEnregistrement($db, 'dd_sorts', 'so_id', 'so_ruleset_var_id', $so_id);
// $so_id === 0  → $_SESSION['ruleset_var_id']  (création dans le ruleset actif)
// $so_id  >  0  → so_ruleset_var_id lu en base (immuable, POST ignoré)
```

Deux raisons : une entité créée dans l'autre ruleset est **invisible de toutes les listes**, qui
filtrent sur le ruleset de session — l'utilisateur crée une entrée qui disparaît ; et un POST forgé
pouvait déplacer une entrée existante d'un ruleset à l'autre, ce qui casse toutes ses liaisons
(sources, races, classes, tableaux, glossaire). Corollaire structurel : la colonne
`*_ruleset_var_id` n'apparaît que dans les `INSERT`, **jamais dans les `UPDATE`**.

Le formulaire affiche le ruleset en clair (`<input disabled>`, sans `name`) là où l'information est
utile à la saisie — Campagne et Personnage. Pour créer dans l'autre ruleset, on en change par le
switch du header (ci-dessous) ou dans son profil (§11).

**Seule exception : `include/ajax/modifier/ressource.php`** (admin) garde son select. Une ressource
est un livre source *déclaré pour* un ruleset ; l'admin en saisit indépendamment du ruleset de sa
propre session.

### Bascule depuis le header — SP-RB

Quand `j_affichage_ruleset` est actif, le badge du ruleset (`include/header.php`) est un bouton
qui n'affiche **que le ruleset actif**, suivi d'une petite icône ⇄ (`fa-right-left`) signalant
qu'il est cliquable (`.site-header__ruleset*`, `css/main.css`) — ~64-75px, contre ~117px pour la
première version à deux libellés, trop large sur téléphone. C'est un `<form>` POST vers `profil/ruleset.php` (CSRF, ruleset cible, `retour` = URI courante) : aucun JS.

**Session seulement** : la bascule ne modifie pas `j_default_ruleset_var_id` — la prochaine
connexion repart sur le ruleset du profil.

**Contexte mémorisé par ruleset** — `basculerRuleset($db, $nouveau)` (`helpers.php`), seul point
de changement du ruleset de session (le profil l'appelle aussi) :
1. range le contexte courant (`CONTEXTE_RULESET_CLES` : `last_pe_id` et la chaîne
   `last_camp/sce/scc/re_id|nom`) dans `$_SESSION['contexte_ruleset'][ancien]` ;
2. purge (`resetContexteRuleset()`) ;
3. restaure `$_SESSION['contexte_ruleset'][nouveau]` après contrôle en base : personnage existant
   et du bon ruleset ; campagne non supprimée et du bon ruleset (sinon toute la chaîne campagne
   est abandonnée).

Un personnage d'un autre ruleset consulté par lien est rangé dans **son** ruleset
(`setLastPersonnage($pe_id, $pe_ruleset)` → `memoriserPersonnageRuleset()`), et n'écrase pas le
dernier personnage du ruleset quitté au moment de la bascule.

**Page équivalente** — `pageEquivalenteRuleset($retour, $nouveau)` reconstruit la cible depuis
`BASE_URL` (jamais l'URI brute : pas de redirection ouverte) :

| Page quittée | Page rechargée |
|---|---|
| Listes (compendium, règles, campagnes, personnages, profil, admin…) | Même page, **sans la query** (les filtres visent des entités du ruleset quitté) |
| `personnages/<sous-page>.php?id=` | Même sous-page du personnage mémorisé, sinon `personnages/index.php` |
| `campagnes/<niveau>.php?id=` | Même niveau de la chaîne mémorisée, sinon l'ancêtre le plus profond, sinon `campagnes/index.php` |
| `regles/regle.php?id=` | `regles/index.php` |
| `regles/recherche.php?q=` | Même recherche (`q` conservé) |
| `compendium/historiques.php` vers DD3.5 | `compendium/index.php` |
| `enregistrement.php`, `include/`, URI hors `BASE_URL` ou fichier absent | `index.php` |

---

## 4. Modèle utilisateur et droits

### Rôles

| Rôle | Condition | Droits |
|---|---|---|
| Admin | j_admin = 1 | Tout le site, bypass filtres propriétaire |
| Gestionnaire compendium | j_compendium_manager = 1 | Édition compendium global + propre supplément |
| Utilisateur standard | par défaut | Ses propres données uniquement |
| MJ | contextuel : camp_j_id = session j_id | Données de sa campagne + personnages invités |

Le rôle MJ est contextuel — tout utilisateur devient MJ dès qu'il crée une campagne ou un univers.

### Règle de filtrage propriétaire

Toute requête sur données utilisateur : WHERE [prefix]_j_id = :user_id, sauf si admin.
Encapsulé dans ownerFilter() dans include/helpers.php.

### Fonctions d'autorisation compendium

**`canEditCompendium()`** (auth.php) — contrôle global :
- Retourne true si admin ou j_compendium_manager
- Conditionne l'affichage du bouton "Ajouter" et de la barre bulk
- Inchangée par la feature supplément

**`canEditCompendiumEntry($db, ?int $res_j_id)`** (helpers.php) — contrôle per-entry :
- Retourne true si admin
- Retourne true si `res_j_id IS NULL` (ressource officielle) + `j_compendium_manager`
- Retourne true si `res_j_id === j_id` courant (propre supplément)
- Retourne false si `res_j_id` est celui d'un autre utilisateur (même admin du compendium)
- Utilisée dans : menu ⋮ per-row dans `compendium-liste.php`, bouton Modifier dans `detail-pp/*.php`, garde de save dans `enregistrement.php`

### Visibilité des données par module

| Module | Règle |
|---|---|
| Compendium officiel | Visible par tous les utilisateurs connectés |
| Compendium — Supplément utilisateur | Propriétaire : voit tout (public + privé + brouillons). Autres avec supplément sélectionné : uniquement les entrées `_public=1 AND _visible=1`. |
| Personnages | Propriétaire + MJs des campagnes auxquelles le personnage est rattaché |
| Campagnes | Propriétaire uniquement |
| Notes MJ (cp_notes_mj) | MJ de la campagne uniquement |
| Univers privé | Propriétaire uniquement |
| Univers public | Sélectionnable par d'autres MJs |
| Articles wiki visibles | Tous les ayants droit de l'univers |
| Articles wiki cachés | Propriétaire de l'univers uniquement |

---

## 5. Compendium des règles

### Droits d'édition

1. **Compendium global** : admin + gestionnaires délégués (j_compendium_manager = 1). Visible par tous.
2. **Contenu homebrew campagne** : créé par le MJ via _camp_id. Mêmes formulaires + champ caché _camp_id. Visible MJ + joueurs de la campagne.
3. **Supplément utilisateur** : tout j_compendium_manager peut créer ses propres entrées rattachées à sa source "Supplément de {pseudo}". Voir § Supplément utilisateur ci-dessous.

### Périmètre des entités du compendium

Les entités suivantes font partie du compendium et sont filtrées par ressource via leur champ `_res_id` :

| Table | Préfixe | Ruleset | Champ ressource |
|---|---|---|---|
| dd_classes | cla | DD3.5 + DD2024 | cla_res_id |
| dd_races | ra | DD3.5 + DD2024 | ra_res_id |
| dd_sorts | so | DD3.5 + DD2024 | so_res_id |
| dd_dons | do | DD3.5 + DD2024 | do_res_id |
| dd_competences | comp | DD3.5 + DD2024 | comp_res_id |
| dd_historiques | hi | **DD2024 uniquement** | hi_res_id |
| dd_objets_magiques | om | DD3.5 + DD2024 | om_res_id |

> ⚠️ `dd_historiques` est une entité exclusive au ruleset DD2024. Elle ne doit jamais apparaître dans les pages ou formulaires DD3.5.

Cette liste est la référence pour toute vérification de dépendances (ex : suppression d'une ressource).

### Sélection des sources — chaîne de priorité

```
1. Sélection de la campagne (dd_campagnes_sources)
   actif si : personnage en session (last_pe_id) + campagne avec sélection propre
2. Sélection personnelle (dd_joueurs_sources, par ruleset)
   inclut désormais le supplément de l'utilisateur (auto-ajouté à la création)
3. Toutes les sources actives du ruleset (défaut absolu — res_j_id IS NULL uniquement)
```

### Architecture des pages du compendium — moteur de liste commun

Toutes les pages du compendium partagent la même structure et le même moteur.

Principe : chaque page déclare $listConfig puis délègue tout le rendu à include/compendium-liste.php.

Exemple de $listConfig (sorts.php) :

```php
$listConfig = [
  'entite'        => 'sort',
  'titre'         => 'Sorts',
  'from'          => 'dd_sorts so LEFT JOIN dd_colleges co ON co.co_id = so.so_co_id',
  'champ_id'      => 'so.so_id',
  'champ_res'     => 'so.so_res_id',
  'champ_ruleset' => 'so.so_ruleset_var_id',
  'champ_public'  => 'so.so_public',   // Supplément : champ _public
  'champ_visible' => 'so.so_visible',  // Supplément : champ _visible
  'colonnes'      => [
    ['sql' => 'so.so_nom',    'champ' => 'so_nom',    'label' => 'Nom',   'mobile' => true,  'tri' => true],
    ['sql' => 'so.so_niveau', 'champ' => 'so_niveau', 'label' => 'Niv.', 'mobile' => false, 'tri' => true],
    ['sql' => 'co.co_nom',    'champ' => 'co_nom',    'label' => 'Ecole', 'mobile' => false, 'tri' => true],
  ],
  'filtres'       => $filtres_specifiques,
  'url_detail'    => BASE_URL . '/include/ajax/detail-pp/sort.php',
  'url_modifier'  => BASE_URL . '/include/ajax/modifier/sort.php',
  'url_enreg'     => BASE_URL . '/compendium/enregistrement.php',
  'bulk_actions'  => [
    ['valeur' => 'supprimer', 'label' => 'Supprimer la selection'],
  ],
  // Optionnel — boutons d'action par ligne (ex : export Roll20)
  'row_actions'   => [
    [
      'label'        => 'Exporter vers Roll20',  // tooltip et texte menu ⋮
      'icon'         => 'fa-download',            // classe FontAwesome
      'href'         => BASE_URL . '/include/ajax/export/monstre-roll20.php?id={id}',
      'download'     => true,    // ajoute l'attribut HTML download
      'require_edit' => false,   // false → bouton visible pour tous
                                 // true  → item dans le menu ⋮ éditeur
    ],
  ],
];
require_once '../include/header.php';
require_once '../include/compendium-liste.php';
require_once '../include/footer.php';
```

**Clés `$listConfig` relatives au supplément (implémentées le 2026-06-20, cf. Monstres) :**

| Clé | Type | Valeur | Comportement |
|---|---|---|---|
| `champ_public` | string | `'mo.mo_public'` | Référence SQL du champ `_public` |
| `champ_visible` | string | `'mo.mo_visible'` | Référence SQL du champ `_visible` |
| `champ_res_owner` | string | `'res.res_j_id'` | Référence SQL de `res_j_id` — nécessite que `from` joigne déjà `dd_ressources` sous cet alias (le contrôleur le fait déjà pour afficher le nom de la source ; le moteur ne rajoute **pas** son propre JOIN pour éviter une collision d'alias) |

Les 3 clés doivent être déclarées **ensemble** pour activer le mécanisme. Si absentes : comportement strictement inchangé (rétro-compatible).

**Clé de filtre `submit_onchange` (2026-08-22, types `select` / `exists`) :**

`'submit_onchange' => true` sur un critère de `filtres[]` ajoute un `onchange` qui soumet la barre
de filtre dès le changement de valeur, sans passer par le bouton *Filtrer*. Utile quand la page
contrôleur fait **dépendre d'autres critères** de celui-ci : le rechargement est ce qui fait
apparaître ou disparaître les critères conditionnels.

Un critère conditionnel se construit côté page contrôleur, pas dans le moteur : la page lit la
valeur GET pilote, n'ajoute l'entrée dans `$filtres` que si la condition est remplie, et **retire
du `$_GET` la valeur du critère masqué** — sans quoi elle resterait active dans les liens de tri
et de pagination construits par `http_build_query($_GET)`. Cas de référence :
`compendium/classes.php` (critère « Classe parente », visible seulement sur le type Sous-classe).

> ⚠️ Écart avec la conception initiale (§ ci-dessus, non modifiée pour traçabilité) : le moteur
> n'ajoute **pas** lui-même le `JOIN dd_ressources` — il réutilise l'alias déjà présent dans `from`
> via `champ_res_owner`. Choix fait en implémentant Monstres : `compendium/monstres.php` joint déjà
> `dd_ressources res` pour la colonne Source, un second JOIN automatique sous le même alias aurait
> provoqué une erreur SQL (alias dupliqué). Voir `DECISIONS_LOG.md` [2026-06-20].

Séquence d'exécution de compendium-liste.php :
1. Lit GET : colonne de tri, direction, valeurs des filtres, page courante
2. Valide la colonne de tri par whitelist (colonnes avec tri = true)
3. Appelle getActiveResIds() → base sources active
4. Intersecte avec filtre sources GET si présent
5. Détecte le mode supplément (3 clés présentes) ; si l'utilisateur a des brouillons dans son
   propre supplément, résout `f_brouillons` (GET) pour le toggle "Afficher mes brouillons"
6. Construit WHERE : ruleset + camp + sources + **visibilité supplément** + texte libre + filtres spécifiques
7. Construit ORDER BY sécurisé
8. Exécute COUNT(*) → calcule pagination
9. Exécute SELECT avec LIMIT/OFFSET (inclut `{champ_res_owner} AS _res_j_id` si supplément)
10. Rend le HTML : zone filtre (+ toggle brouillons) + tableau (badge homebrew + gating per-entry du menu ⋮) + pagination + barre bulk

### Structure de chaque page liste

Zone filtre :
  - INPUT texte libre (toujours premier)
  - Critères métier spécifiques à chaque page (certains conditionnels par ruleset)
  - **Toggle "Afficher mes brouillons"** (checkbox, visible uniquement si l'utilisateur a un supplément avec des entrées `_visible=0`)
  - SELECT sources multiple (toujours dernier — restreint dans la sélection active)

Tableau :
  - Checkbox | Menu ligne | col-primary (+ badge homebrew si _res_j_id IS NOT NULL) | col-secondary...

Pagination

Barre bulk en bas : Action [SELECT] [Appliquer]

### Responsive des listes compendium

Classes CSS définies dans compendium-modules.css :

| Classe | Desktop | Mobile (<=991px) |
|---|---|---|
| .col-primary | Colonne normale | Toujours visible — ligne principale |
| .col-secondary | Colonne normale | Sous-ligne (font 0.8rem, style distinctif) |
| .col-action | Visible (modifier/supprimer) | Masqué |
| .bulk-check | Visible (checkbox) | Masqué |

### Tables des formulaires de modification

| Classe | Portée | Règles CSS |
|---|---|---|
| `.table-classe-modif` | Classe §2 (progression) et §3, Race §3 | Aucune — classe de rattachement historique |
| `.table-classe-modif--liste` | Listes de capacités injectées en JS (`#classe-cap-table`, `#race-cap-table`) | `compendium-modules.css` : largeur 100 %, cellules `padding` + `text-align: left`, en-tête `--clr-surface-alt`, colonne `.col-actions` en `width: 1%` + `nowrap` |

Le modificateur `--liste` existe parce que la table de progression (Classe §2) partage la classe de
base mais porte jusqu'à 26 colonnes d'`<input>` : elle ne doit pas hériter du padding ni de
l'alignement des listes. Toute nouvelle liste de capacités dans un formulaire compendium reprend
`table-classe-modif table-classe-modif--liste` plutôt qu'un style inline.

### Badge homebrew

Les lignes de supplément (`_res_j_id IS NOT NULL`) reçoivent la classe CSS `comp-ligne--homebrew` sur le `<tr>`.
Une icône indicateur est injectée dans `col-primary` pour signaler visuellement le contenu de supplément.
Styles dans `compendium-modules.css`.

### Confirmation de suppression

Div inline remplaçant temporairement la ligne dans le tableau. Pas de window.confirm().

### Fichiers du compendium

```
compendium/
  sorts.php, classes.php, dons.php, races.php, competences.php, objets.php
  historiques.php   (DD2024 uniquement — conditionné par ruleset en session)
  monstres.php
  enregistrement.php  (POST commun + mode ?ajax=1)

include/
  compendium-liste.php   (moteur commun)
  ajax/detail-pp/        (sort.php, classe.php, don.php, race.php, competence.php, historique.php, objet.php, monstre.php...)
  ajax/modifier/         (sort.php, classe.php, don.php, race.php, competence.php, historique.php, objet.php, monstre.php...)
```

> ⚠️ La page `compendium/historiques.php` (et ses endpoints AJAX) ne doit être accessible
> et affichée dans le menu que si `$_SESSION['rulesetRep'] === 'DD2024'`.

### enregistrement.php — mode AJAX

Détecte $_GET['ajax'] et retourne JSON {ok, id, url_detail} pour les saves individuels.
Mode normal (bulk) : redirect + flash message SESSION.

### Supplément utilisateur

#### Principe général

Tout `j_compendium_manager` peut créer ses propres entrées dans n'importe quelle section du compendium,
rattachées à sa source personnelle "Supplément de {pseudo}". Le supplément est une entrée `dd_ressources`
avec `res_j_id = j_id` et `res_camp_id IS NULL`. **1 supplément par utilisateur par ruleset.**

Le supplément est créé automatiquement (`getOrCreateUserSupplement($db, $j_id, $ruleset_var_id)`)
lors du premier save d'une entrée de supplément, puis auto-ajouté dans `dd_joueurs_sources`.

#### Droits d'édition per-entry

Voir `canEditCompendiumEntry()` au §4. Résumé :
- Seul le propriétaire peut modifier ses entrées de supplément (+ admin).
- Un autre `j_compendium_manager` ne peut PAS modifier le supplément d'autrui.

#### Visibilité des entrées

| `_public` | `_visible` | Qui voit l'entrée dans les listes |
|---|---|---|
| 0 | 1 | Propriétaire uniquement (privé normal — état par défaut) |
| 0 | 0 | Brouillon masqué — accessible via toggle "Afficher mes brouillons" |
| 1 | 1 | Tous les utilisateurs ayant le supplément sélectionné comme source |
| 1 | 0 | **INTERDIT** — contrainte UI + serveur |

Le propriétaire voit toujours toutes ses entrées (y compris les brouillons `_visible=0`) via le toggle dédié dans la barre de filtre.

#### Filtre visibilité dans le moteur de liste

```sql
-- Sans le toggle "Afficher mes brouillons" (état par défaut) :
AND (
  {champ_res_owner} IS NULL                                  -- officiel : toujours
  OR ({champ_res_owner} = :uid AND {champ_visible} = 1)      -- propriétaire : ses entrées visibles
  OR ({champ_public} = 1 AND {champ_visible} = 1)            -- supplément tiers partagé
)

-- Avec le toggle actif (?f_brouillons=1, uniquement proposé si le
-- propriétaire a ≥1 entrée _visible=0) :
AND (
  {champ_res_owner} IS NULL
  OR {champ_res_owner} = :uid                                 -- propriétaire : tout, brouillons inclus
  OR ({champ_public} = 1 AND {champ_visible} = 1)
)
```

Activé automatiquement par le moteur `compendium-liste.php` quand `champ_public`, `champ_visible`
**et** `champ_res_owner` sont déclarés dans `$listConfig`. Le toggle "Afficher mes brouillons" est
une checkbox dédiée dans la barre de filtre (paramètre GET `f_brouillons`), distincte du mécanisme
générique `filtres[]` à checkbox — gérée directement par le moteur, pas par la page contrôleur.

#### Supplément comme source sélectionnable

- Auto-ajouté dans `dd_joueurs_sources` du propriétaire dès sa création.
- Visible dans "Mes sources" d'autres utilisateurs uniquement si ≥1 entrée est publique et visible.
- Ajout explicite à une campagne (configuration des sources de la campagne) : possible mais **non
  requis** — la priorité 1 de `getActiveResIds()` et `getActiveResIdsCampagne()` incluent désormais
  toutes deux systématiquement le supplément personnel pertinent, même sans sélection explicite
  (voir bug corrigé ci-dessous et § Oppositions, Usage Oppositions — 2026-06-20).
- La priorité 3 de `getActiveResIds()` (défaut absolu) reste limitée aux ressources officielles (`res_j_id IS NULL`).

> �
 **Bug corrigé le 2026-07-02 — supplément personnel absent de la priorité 1 de `getActiveResIds()`
> (régression, listes du compendium dont Monstres).** `getActiveResIds()` possède sa propre branche
> priorité 1 (personnage actif en session via `last_pe_id`, rattaché à une campagne à sources
> explicites), distincte de `getActiveResIdsCampagne()` : elle retournait directement les
> `cs_res_id` de `dd_campagnes_sources` sans jamais appeler `getUserSupplementResId()`. Conséquence :
> dès qu'un personnage était actif dans une telle campagne, le supplément personnel de l'utilisateur
> disparaissait à la fois des résultats de liste (filtre `champ_res`) **et** du menu de sélection des
> sources dans `compendium-liste.php` (`$sources_dispo`, construit à partir du même tableau). Le
> correctif du 2026-06-22 sur `getActiveResIdsCampagne()` n'avait pas couvert cette branche sœur.
> Corrigé en ajoutant systématiquement `getUserSupplementResId($db, $j_id, $ruleset_var_id)`
> (utilisateur courant — cette fonction est scopée personnage/joueur, contrairement à
> `getActiveResIdsCampagne()` qui est scopée MJ et utilise `camp_j_id`) au tableau de sources
> retourné par la priorité 1, s'il n'y figure pas déjà.

> ⚠️ **Périmètre de la priorité 1 corrigé le 2026-08-14 (SP-PE5).** La branche interrogeait
> `dd_campagnes_personnages` sur **toutes** les campagnes actives du personnage
> (`WHERE cp_pe_id = ? AND cp_actif = 1`) et unionnait leurs sources. Le défaut était invisible :
> aucun écran n'alimentait la table de liaison, la branche n'était jamais atteinte. SP-PE5 ouvrant
> le rattachement, elle est désormais scopée sur la **campagne en cours** du personnage
> (jointure sur `pe_camp_id`, liaison devant exister **et** être active). Sans quoi les ouvrages
> autorisés par une campagne terminée resteraient ouverts dans tout le compendium de la session.

#### Helpers dédiés dans `helpers.php`

```php
// Retourne le res_id du supplément (null si non créé)
getUserSupplementResId($db, int $j_id, int $ruleset_var_id): ?int

// Crée le supplément si absent + auto-add dd_joueurs_sources, retourne res_id
getOrCreateUserSupplement($db, int $j_id, int $ruleset_var_id): int
```

---

### Module Monstres — bloc de stats à liaisons cliquables (v3)

Le module Monstres est un module de compendium **classique dans sa forme** (moteur de liste
commun `compendium-liste.php`, fiche `detail-pp`, formulaire `modifier`, dispatch dans
`enregistrement.php`), enrichi d'un **moteur de rendu propre** : `include/monstre-parser.php` (v3).

#### Principe directeur — texte brut au stockage, analyse à l'affichage

`mo_stats` est **stocké tel quel**, en texte brut. `enregistrerMonstre()` écrit la valeur POST
sans transformation (pas de `h()`, pas de passe d'analyse au save). Le **formatage** (mise en page)
et les **liens cliquables** sont recalculés **à chaque affichage** par `rendreStatsMonstre()`,
appelé depuis `include/ajax/detail-pp/monstre.php`.

```php
// include/monstre-parser.php — point d'entrée public
// Retourne ['html' => string, 'rapport' => array]  ($rapport = compteur de liens par type)
function rendreStatsMonstre(PDO $db, ?string $texte, int $ruleset_id, array $res_ids): array
```

→ Ré-édition fidèle à la source ; liens toujours à jour (une entité ajoutée plus tard devient
cliquable sans re-sauvegarde) ; aucune logique d'idempotence. La saisie se fait dans un
`<textarea>` brut — **pas de TinyMCE**, pas de `DOMDocument`.

#### Périmètre des données

Table principale `dd_monstres` (colonnes référencées par le code) :

| Champ | Rôle |
|---|---|
| `mo_nom` | Nom de la créature (obligatoire) |
| `mo_mocat_id` | Catégorie (obligatoire) → `dd_monstres_categories` |
| `mo_mogr_id` | Groupe → `dd_monstres_groupes` *(DD2024 uniquement ; `0` → stocké `NULL` en DD3.5)* |
| `mo_fp_id` | Facteur de puissance — **libellé varchar** (« 1/2 ») → référentiel `dd_fp` |
| `mo_stats` | Bloc de description en **texte brut** — analysé au rendu, jamais au save |
| `mo_res_id` | Source (obligatoire) → `dd_ressources` (officielle ou supplément utilisateur) |
| `mo_camp_id` | Homebrew de campagne (NULL = officiel ou supplément) |
| `mo_public` | 0 = privé, 1 = partagé (supplément uniquement) |
| `mo_visible` | 0 = brouillon masqué, 1 = visible (supplément uniquement) |
| `mo_ruleset_var_id` | Ruleset → `dd_variables` |

> **`mo_j_id` supprimé.** La propriété et la visibilité des monstres sont désormais gérées via
> `mo_res_id` (supplément) et `mo_camp_id` (homebrew campagne), alignées sur le mécanisme commun
> à toutes les entités du compendium. Migration via `patch_004_supplements.sql`.

> �
 **Régularisé le 2026-06-20.** `enregistrerMonstre()` (`compendium/enregistrement.php`) et le
> formulaire (`include/ajax/modifier/monstre.php`) référençaient encore `mo_j_id`, provoquant une
> erreur SQL (`Unknown column 'mo_j_id'`) à chaque save. Code aligné sur le schéma réel — voir
> `DECISIONS_LOG.md` [2026-06-20]. Reste un écart documentaire mineur : `sql/schema.sql` et le dump
> `sql/maikasteiymaika.sql` ne reflètent toujours pas `mo_mocat_id`, `mo_mogr_id`, `mo_res_id`,
> `mo_camp_id`, `mo_public`, `mo_visible` ni les tables `dd_monstres_categories`, `dd_monstres_groupes`,
> `dd_fp` — resynchronisation des fichiers SQL versionnés toujours à planifier (sans urgence, la base
> réelle fait foi).

**Visibilité — mécanisme unifié.** Portée par le moteur commun via `champ_public`/`champ_visible`/
`champ_res_owner` dans `$listConfig` (`compendium/monstres.php`, déclaré depuis le 2026-06-20).
Le filtre `extra_where` spécifique `(mo.mo_j_id IS NULL OR mo.mo_j_id = $uid)` est supprimé.

#### Formulaire — source à 2 groupes (SP-C4, fait)

Le select `mo_res_id` du formulaire (`include/ajax/modifier/monstre.php`) présente deux `<optgroup>` :
- **Sources officielles** : ressources actives avec `res_j_id IS NULL`.
- **Mon supplément** : une unique option, le supplément de l'utilisateur courant. Si celui-ci n'existe
  pas encore (aucune entrée de supplément créée pour ce ruleset), l'option porte la valeur sentinelle
  `'supplement'` plutôt qu'un `res_id` réel — la ressource est créée à la volée au premier save
  (`getOrCreateUserSupplement()`, appelée depuis `enregistrerMonstre()`, dans la transaction).

Un bloc `#mo-supplement-visibilite` (checkboxes `mo_public` / `mo_visible`) n'est affiché que lorsque
la source sélectionnée est le supplément (`data-supplement="1"` sur l'`<option>`) — masqué pour les
sources officielles, qui sont toujours `_public=1`/`_visible=1` en base. Contrainte `_public=1 ⇒
_visible=1` appliquée côté client (case Visible cochée + désactivée si Partagé est coché) **et** côté
serveur dans `enregistrerMonstre()` (la valeur cliente n'est pas fiable : un champ désactivé n'est pas
soumis en POST).

> Champ `mo_mogr_id` (Groupe, DD2024) corrigé le 2026-06-20 : redevenu **facultatif** dans le
> formulaire (`select` sans `required`, pas d'astérisque) — la colonne est nullable en base et aucune
> règle métier n'impose un groupe à tous les monstres DD2024.

#### Enregistrement — ownership (SP-C5, fait)

`enregistrerMonstre()` résout `mo_res_id` POST en trois cas :
1. Valeur `'supplement'` → `getOrCreateUserSupplement($db, $uid, $ruleset_id)`.
2. Id réel dont `res_j_id IS NULL` (officielle) → `_public`/`_visible` forcés à `1`/`1`.
3. Id réel dont `res_j_id` est défini (supplément) → garde-fou : doit être égal à l'utilisateur courant
   (ou admin), sinon `repondreErreur('Source de supplément invalide.')` — empêche d'écrire dans le
   supplément d'un autre utilisateur en forgeant la requête POST.

`supprimerMonstre()` (fonction dédiée, remplace l'appel générique `supprimerEntite()` pour cette
entité) applique le même garde-fou en lecture avant suppression : pour chaque id reçu (suppression
simple ou bulk), vérifie `canEditCompendiumEntry($db, $res_j_id)` et ignore silencieusement les ids
non autorisés plutôt que d'échouer globalement — un bulk delete mélangeant entrées officielles et
entrée d'un autre supplément (cas normalement impossible depuis l'UI, mais possible via requête
forgée) supprime uniquement la part autorisée.

#### Moteur de liste — visibilité, badge, gating (SP-C2, fait)

`compendium/monstres.php` déclare `champ_public => 'mo.mo_public'`, `champ_visible =>
'mo.mo_visible'`, `champ_res_owner => 'res.res_j_id'` (réutilise l'alias `res` déjà joint pour la
colonne Source — le moteur ne rejoint pas `dd_ressources` une seconde fois). Effets dans
`include/compendium-liste.php` :
- Filtre WHERE de visibilité (cf. § Compendium des règles → Filtre visibilité dans le moteur de liste).
- Toggle "Afficher mes brouillons" dans la barre de filtre, visible uniquement si l'utilisateur a
  ≥1 entrée `_visible=0` dans son propre supplément monstre.
- Badge homebrew : classe `comp-ligne--homebrew` sur le `<tr>` + icône `.comp-homebrew-icon` (fa-flask)
  dans `col-primary`, pour toute ligne dont `_res_j_id` n'est pas `NULL`. Styles dans
  `css/compendium-modules.css`.
- Menu ⋮ et checkbox bulk : gating per-entry via `canEditCompendiumEntry($db, $_res_j_id)` au lieu du
  droit global `canEditCompendium()` — un compendium manager ne voit plus Modifier/Supprimer sur les
  entrées du supplément d'un autre utilisateur, même s'il a le droit global d'éditer le compendium.

#### Fiche détail — bouton Modifier per-entry (SP-C3, fait)

`include/ajax/detail-pp/monstre.php` sélectionne désormais `res.res_j_id` et conditionne le bouton
Modifier à `canEditCompendiumEntry($db, $res_j_id)` au lieu de `canEditCompendium()`.

#### Liaison des entités — deux mécanismes complémentaires

**1. Tags explicites (prioritaires, résolus en pré-passe `resoudreTagsExplicites()`)** :

| Tag | Cible | Résolution |
|---|---|---|
| `#Nom du don#` | `dd_dons` | par **nom** (index, insensible casse/accents) |
| `$Nom du sort$` | `dd_sorts` | par **nom** |
| `&Nom de l'objet&` | `dd_objets_magiques` | par **nom** |
| `@id@` | `dd_regles` (tout type) | par **id** |
| `%id%` | `dd_regles` `reg_type='glossaire'` | par **id** |

> �
 **2026-06-25.** Tag `&Nom de l'objet&` ajouté pour forcer la liaison vers un objet magique
> par nom (jusqu'alors seul type liable sans tag explicite dédié).

**2. Liaison automatique (`lierAuto()`) — objets magiques/équipement + sorts + glossaire.** Sur le
texte libre, une passe relie automatiquement les **objets magiques/équipement**, les **sorts** et
les **termes de glossaire** via un index fusionné (`construireIndexAuto()`, priorité
objet > sort > glossaire). Garde-fous : normalisation casse/accents, plus longue correspondance
d'abord, longueur minimale `MO_LONGUEUR_MIN = 4`.

> �
 **2026-06-25.** Priorité inversée (`objet > sort > glossaire`, auparavant `sort > objet >
> glossaire`) : sur la ligne **Equipement**, un nom ambigu pouvant correspondre à la fois à un
> objet magique et à un sort doit se lier en priorité vers l'objet magique.

> 🐛 **2026-06-25 — correctif.** `formaterBlocDD2024()` chaîne systématiquement
> `resoudreTagsExplicites()` (pré-passe tags `#`/`$`/`&`/`@`/`%`) puis `lierAuto()` (ou
> `lierSorts()`/`lierDons()`). `lierAvecIndex()` traitait son entrée comme du texte brut
> intégral et ré-échappait via `h()` les `<span class="mo-lien">` déjà produits par la pré-passe
> de tags, les faisant apparaître littéralement à l'écran au lieu d'un lien (touchait toute
> ligne combinant un tag explicite et une liaison auto — pas seulement Equipement). Corrigé en
> découpant `lierAvecIndex()` en `lierAvecSegmentsProteges()` (détecte et préserve les blocs
> `<span class="mo-lien">...</span>` déjà présents) + `lierSegmentBrut()` (ex-corps de la
> fonction, appliqué uniquement aux segments de texte brut entre ces blocs).

> �
 **2026-06-20.** Type `objet` (`dd_objets_magiques`) ajouté à `typesLiablesMonstre()` et à
> `construireIndexAuto()`. Effet immédiat sans changement structurel supplémentaire : la ligne
> **Equipement** (label_gras DD2024, déjà passée par `lierAuto()`) et le texte des **Actions**
> (description des `pouvoir`, déjà passé par `lierAuto()`) deviennent automatiquement cliquables —
> aucun nouveau tag explicite requis, le mécanisme de liaison par nom déjà en place pour
> sorts/glossaire s'applique tel quel.

#### Dictionnaire — registre `typesLiablesMonstre()`

Registre déclaratif décrivant les types chargés **par nom** : `don`, `sort`, `objet` (table, id, nom,
colonnes ruleset/res/camp). Le **glossaire** est chargé séparément depuis `dd_regles`. Chargement
(`chargerIndexMonstre()`) scopé : **ruleset + sources actives passées en paramètre + `camp IS NULL`**
— le paramètre `$res_ids` n'est plus implicitement `getActiveResIds()` : depuis l'usage Oppositions
(2026-06-20), l'appelant peut passer `getActiveResIdsCampagne()` à la place (cf. § Oppositions
ci-dessous), `rendreStatsMonstre()` étant agnostique de la source du scope.

#### Rendu par ruleset

- **DD2024** (`formaterBlocDD2024()` + `classerLigneDD2024()`) : classification ligne par ligne —
  en-tête / ligne de **caractéristiques** (grille 3×2 via `rendreTableauCarac()`),
  **titre de section**, **label inline**, **label gras**, **sous-liste de sorts**, **pouvoir**, ligne simple.
- **DD3.5** (`formaterLigneDD35()`) : labels terminés par « : ». Ligne « Dons : » → liaison dons ;
  autres → liaison auto (sorts + objets + glossaire). Parsing automatique DD3.5 **minimal — à compléter**.

Séparateur de blocs commun : une ligne `***` → `<hr class="mo-stat-hr">`.

#### Sortie découplée du JS et résolution des liens

```html
<span class="mo-lien" data-type="sort" data-id="42">Boule de feu</span>
```

| `data-type` | Action |
|---|---|
| `regle` | ouverture de `regles/regle.php?id=…` dans un **nouvel onglet** |
| `glossaire` | `actualiserPageSub()` → `detail-pp-sub/glossaire.php` (sous-panneau) |
| `don` / `sort` / `objet` | `actualiserPageSub()` → endpoint `detail-pp` du type |

> �
 **2026-06-20.** Le handler de clic `.mo-lien` (`MO_LIEN_FICHIERS` + délégation
> `document.addEventListener('click', …)`) a été **déplacé de `js/compendium.js` vers `js/main.js`**
> (chargé sans condition sur toutes les pages, cf. `include/footer.php`). Raison : le bloc de stats
> est désormais aussi rendu sur la fiche **Opposition** du module Campagnes (`$js_module =
> 'campagne'`, ne charge jamais `compendium.js`) — sans ce déplacement, les liens y seraient inertes.
> Le mapping `MO_LIEN_FICHIERS` contenait déjà l'entrée `objet: 'objet.php'`, anticipée mais inutilisée
> jusqu'à l'ajout du type `objet` au parser le même jour.

#### Formulaire et autocomplétion des tags

`include/ajax/modifier/monstre.php` : `<textarea>` brut + popup d'**autocomplétion clavier** des
tags `@` (règle) et `%` (glossaire), alimentée par `include/ajax/autocomplete-tags-monstre.php`.
Champs : `mo_nom`, `mo_mocat_id`, `mo_mogr_id`, `mo_fp_id`, `mo_res_id`, `mo_camp_id`,
`mo_public`, `mo_visible`, `mo_stats`.

> �
 **SP-C7 (2026-06-20).** `include/ajax/modifier/monstre-old.php` (ancienne version pré-migration
> supplément, référençait encore `mo_j_id`/`mo_prive`) supprimé du dépôt — aucune référence ailleurs
> dans le code (vérifié). `include/monstre-parser.php` relu : aucune trace résiduelle de `mo_j_id`.

#### Fichiers du module

```
compendium/monstres.php                     # contrôleur liste + $listConfig (champ_public/champ_visible/champ_res_owner)
compendium/enregistrement.php               # case 'monstre' / enregistrerMonstre() (stockage brut)
include/monstre-parser.php                  # moteur d'analyse + rendu (v3) — rendreStatsMonstre() ; types don/sort/objet
include/ajax/detail-pp/monstre.php          # fiche détail (#detail-pp) — appelle rendreStatsMonstre()
include/ajax/modifier/monstre.php           # formulaire (textarea + autocomplete tags + _public/_visible)
include/ajax/autocomplete-tags-monstre.php  # suggestions tags @ (règle) / % (glossaire)
js/main.js                                  # gestionnaire délégué .mo-lien (résolution data-*) — global, depuis 2026-06-20
css/modules.css                             # styles .mo-stats / .mo-lien / grille carac — global, depuis 2026-06-20
css/compendium-modules.css                  # styles compendium restants (.mo-stats-input, .mo-tag-popup, .comp-ligne--homebrew)
```

#### Usage Oppositions (module Campagnes) — 2026-06-20

`include/ajax/detail-pp-sub/opposition.php` applique désormais `rendreStatsMonstre()` à `opp_stats`
au lieu d'un `<pre>` brut échappé. `opp_stats` est une copie texte de `mo_stats` au moment de la
sélection du monstre (cf. § `dd_oppositions` — formulaire `modifier/opposition.php`,
`chargerDepuisMonstre()`) : même format, même parser, sans adaptation. Scope de l'index de liaison :
**`getActiveResIdsCampagne($db, camp_id, camp_ruleset_var_id)`** (sources actives de la campagne),
**pas** `getActiveResIds()` (sources personnelles du visiteur) — l'opposition est un contenu de
campagne, le ruleset et les sources viennent de `camp_ruleset_var_id` remonté par jointure
(`dd_oppositions → dd_rencontres → dd_scenarios_chapitres → dd_scenarios → dd_campagnes`).

> �
 **Bug corrigé le 2026-06-20 — supplément personnel absent de `getActiveResIdsCampagne()`.**
> Avant correctif, cette fonction (`include/helpers.php`) ne retournait **jamais** le supplément
> personnel du MJ : le repli (pas de `dd_campagnes_sources` configurées) filtrait explicitement
> `res_j_id IS NULL`, et le formulaire de sélection des sources de campagne
> (`modifier/campagne.php`) ne proposait lui non plus que des sources officielles — aucun chemin
> ne permettait au supplément du MJ d'entrer dans cette liste. Conséquence concrète : le sélecteur
> de monstre pour créer une opposition (`include/ajax/recherche-monstre.php`) ne renvoyait jamais
> les monstres homebrew du MJ. Corrigé en incluant systématiquement
> `getUserSupplementResId($db, camp_j_id, ruleset_var_id)` (propriétaire de la campagne, pas
> visiteur) dans les deux branches de `getActiveResIdsCampagne()`. Bénéficie aux deux appelants
> existants (`recherche-monstre.php` et `detail-pp-sub/opposition.php`) sans changement de leur côté.

> ⚠️ **Limite UX connue, acceptée pour cette livraison urgente.** Le bloc de stats d'une opposition
> est lui-même affiché dans `#detail-pp-sub` (sous-panneau unique, sans pile/historique —
> `actualiserPageSub()` remplace toujours le contenu du même panneau, cf. `js/main.js`). Cliquer un
> lien `.mo-lien` à l'intérieur (sort, don, objet, glossaire) **remplace donc la vue Opposition** par
> la fiche du compendium ciblée, plutôt que de s'empiler par-dessus — pas de bouton « retour », seul
> « Fermer » est disponible. Comportement strictement meilleur que l'état précédent (texte brut
> totalement inerte), mais pas une vraie pile de sous-panneaux. Une vraie pile (SP ultérieur,
> non priorisé) nécessiterait de faire évoluer `actualiserPageSub()`/`fermerSubPanel()` pour empiler
> plusieurs niveaux au lieu d'un panneau unique — hors périmètre de ce correctif urgent.

> �
 **Bug corrigé le 2026-06-20 — formulaire Modifier ouvert sous la vue Opposition.** `#modification`
> (`.overlay-panel--edit`, z-index 250) est par design **sous** `#detail-pp-sub` (`.overlay-panel--sub`,
> z-index 300) — cf. commentaire `css/main.css`. Le bouton Modifier de la vue Opposition est le
> **seul endroit du code** où `actualiserPageModif()` est appelé alors qu'un `#detail-pp-sub` est
> déjà ouvert (la vue Opposition elle-même) — partout ailleurs, "Modifier" s'ouvre depuis `#detail-pp`
> (panel principal, z-index 200, toujours sous `#modification`), donc le conflit n'existait nulle
> part ailleurs. Vérifié par grep exhaustif sur tous les appels `actualiserPageModif`/
> `ouvrirModifier` du dépôt. Corrigé en fermant le sous-panneau juste avant l'ouverture du formulaire
> (`onclick="fermerSubPanel(); actualiserPageModif(...)"`) plutôt qu'en modifiant les z-index
> globaux (`actualiserPageModif()` est appelée dans tout le reste de l'app sans ce problème — un
> changement de z-index global aurait été un risque non nécessaire pour un cas isolé).

> �
 **Bug corrigé le 2026-06-21 — la liste des oppositions de la rencontre ne se rafraîchissait pas
> après modification.** Après édition d'une opposition existante, le formulaire ne faisait que
> rouvrir la vue Opposition (`actualiserPageSub(URL_OPP_DETAIL, …)`) sans jamais recharger
> `#detail-pp` (la fiche Rencontre, qui contient la liste affichée en dessous) — celle-ci gardait
> donc le nom/catégorie d'avant édition jusqu'au prochain rechargement complet de la page. La
> création (`OPP_ID === 0`) n'était pas affectée : elle appelait déjà `naviguerDetailPP(URL_RE_DETAIL,
> …)`, qui recharge intégralement `#detail-pp`. Corrigé en ajoutant `rafraichirDetailPPCourant()`
> (nouvelle fonction `js/main.js`, à côté de `naviguerDetailPP()`/`retourDetailPP()` — recharge le
> sommet de `_detailPpStack` **sans** empiler une nouvelle entrée, contrairement à
> `naviguerDetailPP()`) avant de rouvrir la vue Opposition.

> ⚠️ **Bug apparenté repéré au passage, non corrigé (hors périmètre du signalement).** Le bouton
> Supprimer de la vue Opposition (`detail-pp-sub/opposition.php`) appelle
> `campOppDemanderSuppression(oppId, reId)` (`js/campagne.js`), qui cherche les éléments
> `#camp-opp-row-{id}`/`#camp-opp-confirm-{id}` — **présents uniquement dans la liste de
> `rencontre.php`**, absents du DOM de la vue Opposition elle-même. Conséquence : cliquer
> "Supprimer" depuis la vue Opposition ne fait actuellement **rien** (early return silencieux,
> aucune erreur visible). Fonctionne correctement depuis la liste dans `rencontre.php` (le bouton
> ⋮ → Supprimer per-row). À corriger si signalé séparément — cf. `DECISIONS_LOG.md` [2026-06-21].

> �
 **Bug corrigé le 2026-06-21.** Le bouton Supprimer de la vue Opposition utilise désormais une
> fonction autonome (`oppDetailSupprimer()`, définie inline dans `detail-pp-sub/opposition.php`) avec
> `confirm()` natif au lieu de `campOppDemanderSuppression()` — ne dépend plus du DOM de la liste
> rencontre. Après succès : `fermerSubPanel()` + `rafraichirDetailPPCourant()`.

---

### Transfert / Duplication d'opposition (SP-T)

Menu ⋮ de la liste des oppositions (`include/ajax/detail-pp/rencontre.php`) : deux actions
ajoutées le 2026-06-21, **Transférer** et **Dupliquer**, toutes deux via un **popup contextuel**
(`#camp-transfer-popup`, `js/campagne.js`) listant les rencontres de la campagne (groupées
scénario › chapitre, endpoint JSON `include/ajax/liste-rencontres-campagne.php`).

| Phase | Contenu | Avancement |
|---|---|---|
| **SP-T0** | Transférer/Dupliquer une opposition vers une rencontre de la **même campagne** | �
 livré (2026-06-21) |
| **SP-T1** *(planifié, non codé)* | Étendre Transférer/Dupliquer vers une rencontre d'une **autre campagne** du MJ (sélecteur de campagne en amont de celui de rencontre dans le popup) | ⏳ à faire |

**Transférer** : `UPDATE dd_oppositions SET opp_re_id = ?`. Rencontre d'origine exclue de la liste
proposée (`exclude_re_id`). Conserve `opp_nom` tel quel.

**Dupliquer** : `INSERT` d'une copie (mêmes `opp_nom`/`opp_mocat_nom`/`opp_stats`/`opp_mo_id`, nouveau
`opp_re_id`). Rencontre d'origine **incluse** dans la liste proposée (duplication "en place" valide,
réutilise le suffixe « *- copie* » déjà acté pour la duplication — cf. `DECISIONS_LOG.md`
[2026-06-01] — uniquement quand la cible est la rencontre d'origine ; vers une rencontre différente,
le nom n'est pas modifié).

**Garde-fou serveur SP-T0** : `memeCampagne($db, $re_id_a, $re_id_b)` (`campagnes/enregistrement.php`)
vérifie explicitement que les deux rencontres appartiennent à la **même** campagne — `checkReOwner()`
seul ne suffit pas (un MJ peut posséder plusieurs campagnes ; deux rencontres "autorisées" via
`checkReOwner()` peuvent appartenir à deux campagnes différentes du même MJ). Si échec : message
"n'est pas encore disponible" plutôt qu'un refus d'accès générique — anticipe explicitement SP-T1
côté utilisateur.

**Anticipation SP-T1 dans l'interface** : le popup affiche un pied de page fixe, non cliquable
(« *Vers une autre campagne — bientôt disponible* », `.camp-transfer-popup__footer`) — réserve
visuellement la place pour l'évolution sans l'implémenter. Aucune logique de sélection de campagne
n'existe encore côté client ni serveur.

**Positionnement du popup** : `position: absolute` dans `#detail-pp` (qui est `position: fixed` +
`transform`, donc *containing block* réel du popup). Calcul par différence de
`getBoundingClientRect()` entre le bouton déclencheur et `#detail-pp`, **pas**
`offsetTop`/`offsetLeft` (à la différence de `.mo-tag-popup`) — le bouton vit dans
`.comp-menu-ligne` (`position: relative`), qui s'interposerait comme `offsetParent` et fausserait
le calcul si on suivait le même pattern que `.mo-tag-popup`.

---

### Module Équipements (SP-E, étendu par SP-PO)

> **Mise à jour 2026-10-11.** La table `dd_equipements`, vide jusque-là, est restructurée par **SP-PO0** :
> famille (`eqt_cae_id` -> `dd_categorie_equipement`), prix (`eqt_prix_pc` + `eqt_prix_txt`), poids
> (`eqt_poids_g` + `eqt_poids_txt`), attributs propres à la famille (`eqt_attributs`, JSON), ordre du
> livre (`eqt_ordre`) et supplément utilisateur (`eqt_public`). Le texte ci-dessous décrit l'état
> **antérieur** (SP-E0→E3, 2026-06) ; le modèle courant est en §9e et dans `SCHEMA_SQL.md`.

Entité **`dd_equipements`** (`eqt_*`) — équipement mondain (armes, armures, matériel non magique),
distincte de `dd_objets_magiques` (objets magiques, module déjà existant). Schéma fourni par
l'utilisateur le 2026-06-20, table créée (`sql/2026-06-20_equipements_sp-e0.sql`, committé) ;
**aucun contrôleur, formulaire ou endpoint ne l'utilise encore** — développement différé,
volontairement séquencé en étapes sur le modèle du plan SP-C (Supplément utilisateur).

> Origine : demande initiale "rendre cliquables les équipements et objets magiques" dans le bloc de
> stats Monstre (2026-06-20). `dd_equipements` n'existait pas encore en base à ce moment — seule la
> liaison **objets magiques** (`dd_objets_magiques`, déjà existante) a été câblée dans
> `monstre-parser.php` ce jour-là (cf. § Module Monstres ci-dessus). La liaison **équipement mondain**
> est différée à SP-E4, une fois la table et un endpoint de détail disponibles. Voir
> `DECISIONS_LOG.md` [2026-06-20] "Développement urgent" et [2026-06-20] "Clarification
> dd_equipements".

| Phase | Contenu | Complexité | Avancement |
|---|---|---|---|
| **SP-E0** | SQL : `CREATE TABLE dd_equipements` | Faible | �
 livré (2026-06-20, `sql/2026-06-20_equipements_sp-e0.sql`) |
| **SP-E1** | Contrôleur liste `compendium/equipements.php` (`$listConfig` — moteur générique déjà prêt, cf. SP-C2) | Modérée | �
 livré (2026-06-26) |
| **SP-E2** | Formulaire `modifier/equipement.php` + `enregistrement.php` (`case 'equipement'` / `enregistrerEquipement()`) | Modérée | �
 livré (2026-06-26) |
| **SP-E3** | Fiche détail `detail-pp/equipement.php` | Faible | �
 livré (2026-06-26) |
| **SP-E4** | `monstre-parser.php` : type `equipement` (`typesLiablesMonstre()` + `construireIndexAuto()`, priorité à arbitrer vs `objet`/`sort`/`glossaire`) + entrée `equipement: 'equipement.php'` dans `MO_LIEN_FICHIERS` (`js/main.js`) | Faible | ⏳ à faire — débloquée (SP-E3 livré, endpoint de détail existe) |
| **SP-E5** *(à arbitrer)* | Rejoindre le mécanisme Supplément utilisateur (SP-C) : ajout `eqt_public`, alignement sur `champ_public`/`champ_visible`/`champ_res_owner` | Faible | ⏳ à arbitrer — non prioritaire |

> SP-E1 à SP-E3 reproduisent exactement le pattern déjà posé pour Monstres/Objets magiques
> (contrôleur liste générique `compendium-liste.php`, formulaire `modifier/*.php`, fonction
> `enregistrer*()` dans `enregistrement.php`, endpoint `detail-pp/*.php`) — aucune inconnue
> technique, juste du volume. SP-E4 ne peut pas être fait avant SP-E3 (un lien `.mo-lien` vers un
> endpoint inexistant produirait une 404 au clic — erreur identifiée et évitée le 2026-06-20, cf.
> `DECISIONS_LOG.md`).

> �
 **2026-06-26 — SP-E1/E2/E3 livrés.** `compendium/equipements.php` (liste, sans filtre
> spécifique — `dd_equipements` n'a pas de catégorie comme `dd_dons`), `include/ajax/modifier/
> equipement.php` + `enregistrerEquipement()` dans `compendium/enregistrement.php`, `include/ajax/
> detail-pp/equipement.php`. Carte ajoutée dans `compendium/index.php`. Modèle suivi : module Dons
> (entité simple sans supplément). Point laissé tel quel : `eqt_visible` existe en base mais n'est
> pas câblé dans `$listConfig` (pas de `champ_visible` déclaré) — la liste affiche tous les
> équipements sans filtrage de visibilité, comme `dd_dons` qui n'a même pas cette colonne ; à
> traiter si besoin lors de SP-E5 (alignement Supplément). SP-E4 débloqué (endpoint de détail
> disponible) mais non fait — reste à arbitrer la priorité `equipement` vs `objet`/`sort`/`glossaire`
> dans `construireIndexAuto()`.

---

### Module Classes — sous-classes (DD2024)

#### Principe — réutilisation de `dd_classes`, pas de table dédiée

Une sous-classe DD2024 (ex. domaine divin du clerc, voie du barbare) est stockée comme une ligne
ordinaire de `dd_classes`, avec `cla_clt_id` pointant vers le type `dd_classe_type` dédié :

| clt_id | Nom | Ruleset |
|---|---|---|
| 4 | Base | DD2024 |
| 5 | Sous-classe | DD2024 |

> ⚠️ Ces `clt_id` sont des valeurs concrètes confirmées en base (dev/prod), pas des constantes
> normalisées par le code — à l'image du `cla_clt_id === 2` déjà utilisé pour le prestige DD3.5.
> Si l'ID de la ligne « Sous-classe » diffère un jour entre environnements, mettre à jour le
> littéral `5` dans les trois fichiers listés ci-dessous (Fichiers du module).

Le champ `cla_cla_id` (déjà présent en base, jusque-là inutilisé par le code) porte désormais la
classe parente d'une sous-classe — liaison N sous-classes → 1 classe. Il reste `NULL` pour toute
classe Base ou Prestige.

Le mécanisme de capacités spéciales par niveau (`dd_classe_capacite`) est réutilisé sans aucune
modification de schéma : une sous-classe étant une ligne `dd_classes` comme une autre, `cc_cla_id`
pointe directement sur son propre `cla_id`.

#### Formulaire — bascule d'affichage selon le type

`include/ajax/modifier/classe.php` affiche un sélecteur "Classe parente" (`cla_cla_id`, classes du
ruleset hors sous-classes et hors la classe en cours d'édition), visible uniquement quand
`cla_clt_id = 5`. À l'inverse, tous les champs propres à une classe "normale" — dé de vie,
niveaux max, type de magie, caractéristique LS, table de progression (Section 2), blocs DD3.5/
DD2024 de la Section 1b, intitulés de pouvoirs 1-5 — sont masqués pour ce type. Ces blocs sont
marqués par la classe CSS `.classe-champ-normal` (l'inverse, `.classe-champ-sousclasse`, pour le
champ "Classe parente"), basculée en JS par `appliquerVisibiliteType()` sur le `change` du select
`cla_clt_id`. Seuls nom, abréviation, source, campagne homebrew, description et la Section 3
(capacités spéciales) restent communs aux deux types. Le niveau max d'une sous-classe DD2024 va
toujours jusqu'à 20 comme n'importe quelle classe Base — aucune synchronisation dynamique avec la
classe parente n'est donc nécessaire pour borner l'éditeur de capacités.

#### Enregistrement — neutralisation serveur + validation

`enregistrerClasse()` (`compendium/enregistrement.php`) valide que `cla_cla_id` est renseigné si
`cla_clt_id = 5`, et neutralise côté serveur tous les champs "classe normale" (type de magie,
caractéristique LS, sorts, armes/armures/outils/équipement, points de compétences, alignement,
conditions, etc.) quand le type est Sous-classe — qu'ils aient été soumis ou non par le
formulaire — afin d'éviter des données résiduelles en base. La Section 2 (table de progression
`dd_classe_niveau`) est entièrement ignorée pour une sous-classe ; toute ligne déjà présente est
purgée (cas d'une classe Base reclassée en Sous-classe).

`supprimerClasse()` bloque désormais la suppression d'une classe si des sous-classes la
référencent via `cla_cla_id`, en plus du contrôle existant sur les personnages utilisant la classe.

#### Liste — rappel de la classe de base et filtre conditionnel (SP-SC1, 2026-08-22)

`compendium/classes.php` joint `dd_classes clapar` sur `cla.cla_cla_id` et rend la colonne **Type**
via `CONCAT(clt.clt_nom, IF(clapar.cla_nom IS NULL, '', CONCAT(' (', clapar.cla_nom, ')')))` : une
sous-classe s'affiche « Sous-classe (Barbare) », les autres types gardent le libellé seul (leur
`cla_cla_id` est `NULL`). Le tri de la colonne porte sur la même expression. La jointure est
`LEFT JOIN` sur une clé N→1, sans risque de duplication de lignes.

Le critère **Classe parente** (`f_cla_par` → `cla.cla_cla_id`) n'est ajouté à `$filtres` que
lorsque `f_clt_id` vaut `5` ; sinon la page fait `unset($_GET['f_cla_par'])` pour que le critère
masqué ne survive pas dans les liens de tri et de pagination. Le critère « Type de classe » porte
`'submit_onchange' => true` (cf. §5, moteur de liste) pour que le basculement soit immédiat. La
liste d'options n'expose que les classes ayant **au moins une sous-classe en base**
(`EXISTS (SELECT 1 FROM dd_classes sc WHERE sc.cla_cla_id = par.cla_id)`), pour ne pas proposer
d'option à résultat vide.

#### Visualisation

`include/ajax/detail-pp/classe.php` masque la ligne "Dé de vie" pour une sous-classe et affiche à
la place une ligne "Classe parente" cliquable, qui ouvre la fiche de la classe de base dans le même
`#detail-pp` via `naviguerDetailPP()` (réutilisation de la pile de navigation interne déjà utilisée
pour Campagne→Scénario, bouton ← Retour). Le reste de la fiche (compétences, armes, description)
est déjà conditionné par la présence de données et n'affiche donc rien de superflu pour une
sous-classe sans changement supplémentaire.

Symétriquement, la fiche d'une **classe de base** liste ses **sous-classes** sur le même modèle :
une ligne de renvois cliquables. Le périmètre de la requête reprend celui du moteur de liste —
sources actives (`getActiveResIds()`) **et** règle de visibilité supplément (officielle | mienne
et visible | publique et visible) — pour ne pas exposer via la fiche une entrée qu'une liste
n'aurait pas montrée. Si `getActiveResIds()` renvoie un tableau vide, la requête n'est pas
exécutée (jamais de `IN ()`).

**Mise en page des données de base (SP-SC1).** Les blocs "Compétences", "Maîtrise d'armes" et
"Formation aux armures" étaient rendus hors de `.sort-detail__body` (`font-size: .9rem`), avec le
libellé empilé au-dessus du texte : deux tailles de caractères sur la même fiche et deux
alignements. Ils sont désormais des `.sort-detail__row` du même bloc — libellé puis valeur sur la
même ligne, comme "Dé de vie" ou "Magie". Les deux champs riches (TinyMCE) portent en plus
`.sort-detail__value--html`, qui neutralise les marges de bord des `<p>` / `<ul>` générés
(`css/compendium-modules.css`) : sans cela le contenu retombe sous le libellé.

La ligne **"Niveaux"** (`cla_niveauMax`) n'est plus affichée en DD2024 — la progression y est
commune à toutes les classes, la donnée n'y porte pas d'information. Elle reste affichée en DD3.5,
où les classes de prestige ont des niveaux max distincts.

**Capacités spéciales (SP-SC2, 2026-08-22).** Les deux requêtes distinctes classe normale /
sous-classe sont remplacées par une requête unique agrégée :

```sql
SELECT cap.cap_id, cap.cap_nom, cap.cap_description, cap.cap_type,
       MIN(cc.cc_niveau) AS cap_niveau
FROM   dd_classe_capacite cc
JOIN   dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
WHERE  cc.cc_cla_id = ?
GROUP  BY cap.cap_id, cap.cap_nom, cap.cap_description, cap.cap_type
ORDER  BY cap_niveau, cap.cap_nom
```

Une capacité affectée à plusieurs niveaux (itérations : *Attaque sournoise*, *Réduction des
dégâts*…) n'apparaît **qu'une fois**, titrée par son premier niveau d'obtention. Les itérations
suivantes restent lisibles dans la table de progression pour une classe normale, dans le texte de
la capacité pour une sous-classe. Le `GROUP BY` porte sur toutes les colonnes non agrégées
(compatible `ONLY_FULL_GROUP_BY`). L'ordre est **par niveau puis par nom** — l'ancien tri
alphabétique perdait son sens dès lors que le niveau ouvre le titre.

Le libellé de section « Capacités spéciales » est supprimé : chaque titre **« Niveau X : Nom »**
ouvre son bloc et sert lui-même de séparation. Quelques affectations DD3.5 portent `cc_niveau = 0`
(donnée non renseignée) : le préfixe est alors omis, le niveau 0 n'existant pas dans les règles.

Mise en forme dans `css/compendium-modules.css` (plus aucun style inline) : titre à `1.2rem`
(+20% sur le corps de fiche) en `var(--clr-accent-2)`, le même accent que `.sort-detail__nom`, le
`.cap-type` restant en mention secondaire non grossie. L'espacement entre capacités passe à
`var(--sp-lg)` et est porté par un `margin-top` sur `.classe-detail__capacite + .classe-detail__capacite`
— jamais un `margin-bottom`, qui creuserait un vide après la dernière capacité. Sous 992px, où le
panneau est une feuille plein écran (SP-RS4), l'espacement retombe à `var(--sp-md)` et le titre à
`1.1rem` : la hauteur utile y est la ressource rare et un titre trop grand pousse les noms longs
sur trois lignes.

Les **capacités raciales** (`include/ajax/detail-pp/race.php`) partagent ce jeu de règles : les
sélecteurs `.race-detail__capacites`, `.race-detail__capacite`, `.race-detail__capacite-nom` et
`.race-detail__capacite-nom .cap-type` sont groupés avec leurs homologues `.classe-detail__*` dans
la même section de `css/compendium-modules.css` — un seul bloc à maintenir. Côté markup, la fiche
race n'a plus ni `<strong>` (la graisse vient du CSS) ni styles inline d'espacement, et le type de
capacité utilise la classe commune `.cap-type` (l'ancien `.race-detail__cap-type` n'avait aucune
règle et retombait sur le rendu par défaut).

#### Classes de prestige DD3.5 — sorts propres ou progression du NLS (SP-MA6)

Une classe de prestige DD3.5 lanceuse se comporte de l'une de deux façons, **exclusives** :

| Cas | Exemple | Saisie | `cla_mag_id` |
|---|---|---|---|
| 1 — sorts propres | Tueur de Domiel, Assassin | `cn_sort_n0..9` (+ `cn_sortConnu_n*` en répertoire) | 1 ou 2 |
| 2 — progression du NLS | Archimage, Théurge mystique | drapeaux `cn_niveauSortArcane` / `Divin` / `Effectif` (0/1 par niveau) | **0** |

Une classe du cas 2 reste **non lanceuse** : elle ne lance rien par elle-même, et `cla_mag_id > 0`
lui ouvrirait un bloc vide dans la vue Magie d'un personnage. Les drapeaux sont consommés par le
bloc NLS de la fiche (SP-PE6) et `nlsEffectif35()`.

**Le mode n'est pas stocké** : il se déduit des drapeaux (au moins un à 1 → cas 2).

- **Formulaire** — pour une prestige DD3.5, une bascule `.modif-bascule` (radios `cn_mode_magie`
  = `sorts` | `nls`) dans l'en-tête de la section 2, masquée pour les autres types
  (`.classe-champ-prestige`, JS `appliquerModeMagie()`). Les deux jeux de colonnes sont rendus ;
  la classe `est-mode-nls` de la table masque l'un ou l'autre (`.col-mode-sorts` /
  `.col-mode-nls`). En mode NLS, trois cases par niveau — **Profane, Divin, Au choix** (le théurge
  mystique coche les deux premières) — et type de magie, profil et renouvellement sont
  désactivés en section 1. Une prestige affiche ses colonnes de sorts même à `cla_mag_id = 0`.
- **Enregistrement** — exclusivité garantie par le serveur, quel que soit le formulaire soumis :
  mode NLS → `cla_mag_id`, profil et cadence à 0, `cn_sort_n*` et `cn_sortConnu_n*` à NULL ;
  mode Sorts → drapeaux à 0. Rien n'est touché si `cn_mode_magie` n'est pas soumis (création, ou
  type autre que prestige) : **les drapeaux des classes de base ne sont jamais écrits**.
- **Fiche** — cas 2 : une seule colonne « Sorts par jour », forme courte (arbitrée pour le
  téléphone) : « +1 niv. profane », « +1 niv. divin », « +1 niv. profane et divin »,
  « +1 niv. au choix », « — ». `.table-dd .col-nls` dans `modules.css`.

> **Seules les classes de prestige portent des drapeaux.** Les six classes de base lanceuses
> DD3.5 en avaient un à 1 sur chacun de leurs niveaux (erreur de saisie), remis à 0 par
> `sql/2026-10-10_drapeaux_nls_classes_base_sp-ma6.sql`.

**NULL et 0 dans `cn_sort_n*` (DD3.5)** — deux sens distincts, tenus de la saisie au calcul :
**NULL** = niveau de sort inaccessible ; **0** = niveau accessible, mais par les seuls sorts en
bonus de caractéristique (`bonusSortsCarac()`). Le formulaire enregistre un champ vide en NULL et
« 0 » en 0 ; la fiche affiche « — » et « 0 » ; `getMagieContexte()` n'ajoute le bonus qu'à un
niveau accessible. Contrôlé sur le Paladin (2026-10-10) : niveau 4, Sag 10 → N1 = 0 ; Sag 14 →
N1 = 1 ; niveau 3, Sag 18 → aucun emplacement.

**Téléphone** — une table de progression sans colonnes de sorts (non lanceuse, ou prestige du
cas 2) porte `.table-dd--etroite` : sous 768px, Aptitudes y descend de 160 à 88px, sans coupure
de mot, et la table tient à 375px. Les tables des lanceurs, qui défilent avec leurs dix colonnes
de sorts, gardent les 160px.

#### Fichiers du module

```
include/ajax/modifier/classe.php   # + select cla_cla_id, classes .classe-champ-normal/-sousclasse,
                                    #   appliquerVisibiliteType() (JS)
include/ajax/detail-pp/classe.php  # + jointure classe parente, ligne "Classe parente" cliquable,
                                    #   liste des sous-classes, données de base en .sort-detail__row
compendium/classes.php             # colonne Type avec classe de base, critère f_cla_par conditionnel
include/compendium-liste.php       # clé de filtre submit_onchange
css/compendium-modules.css         # .sort-detail__value--html
compendium/enregistrement.php      # enregistrerClasse() : validation + neutralisation des champs,
                                    #   purge dd_classe_niveau ; supprimerClasse() : dépendance sous-classes
```

---

## 6. Zone d'administration

Accessible uniquement via `requireAdmin()`. Lien affiché dans le header si `$_SESSION['j_admin'] === true`.

### Architecture — moteur admin-liste.php

La zone admin suit le même principe que le compendium : chaque page déclare un `$adminListConfig`
et délègue le rendu à `include/admin-liste.php`.

`admin-liste.php` est un moteur **distinct** de `compendium-liste.php` car ses contraintes
sont différentes : pas de filtre sources, pas de filtre ruleset, pas de champ `_camp_id`.

Différences structurelles vs compendium-liste.php :

| Aspect | compendium-liste.php | admin-liste.php |
|---|---|---|
| Auth | requireAuth() | requireAdmin() |
| Filtre sources | Oui (getActiveResIds) | Non |
| Filtre ruleset | Oui | Non |
| Filtre _camp_id IS NULL | Oui (inféré) | Non |
| Bouton Ajouter | canEditCompendium() | Toujours visible |
| Suppression | Simple | Conditionnelle selon entité |

### Blocs fonctionnels

La zone admin comporte **2 blocs** accessibles depuis `admin/index.php` (dashboard-grid) :

| Bloc | Page | Entité |
|---|---|---|
| A — Gestion des utilisateurs | admin/utilisateurs.php | dd_joueurs |
| B — Gestion des ressources | admin/ressources.php | dd_ressources |

> Les variables (`dd_variables`) sont gérées directement via phpMyAdmin —
> aucune interface d'administration n'est prévue pour cette table.

### A — Gestion des utilisateurs

**Colonnes de la liste :**

| # | Classe CSS | Contenu |
|---|---|---|
| 0 | bulk-check | Checkbox |
| 1 | col-action | Menu ⋮ : Modifier / Réactiver / Désactiver |
| 2 | col-primary | Prénom + Nom |
| 3 | col-secondary | Pseudo |
| 4 | col-secondary | Email |
| 5 | col-secondary | Badges droits : Admin / Compendium |

**Règle de suppression :** La suppression d'un utilisateur est une **désactivation** (`j_visible = 0`),
jamais un DELETE physique. Les données de jeu (personnages, campagnes, univers) sont conservées.

Les utilisateurs désactivés restent visibles dans la liste (indicateur visuel) avec une action "Réactiver".

**Bulk actions :** Désactiver la sélection.

**Formulaire modifier (overlay) :**
- Prénom, Nom, Pseudo, Email
- Droits : j_admin (checkbox), j_compendium_manager (checkbox)
- Mot de passe :
  - mode **ajout** — champ `j_password` unique, obligatoire (min. 8 caractères)
  - mode **édition** — section « Mot de passe » avec `j_pass_nouveau` + `j_pass_confirme`,
    **facultatifs** : deux champs vides = mot de passe inchangé. L'admin n'a jamais à connaître
    le mot de passe actuel (pas de champ « mot de passe actuel », contrairement à `profil/index.php`).
    Contrôles serveur : 8 caractères minimum, les deux saisies identiques. À l'écriture, un lien de
    réinitialisation en attente est invalidé (`j_reset_token` / `j_reset_token_expires` remis à NULL).

### B — Gestion des ressources

**Colonnes de la liste** (les compteurs sont calculés par sous-requêtes SQL) :

| # | Classe CSS | Contenu | Source SQL |
|---|---|---|---|
| 0 | bulk-check | Checkbox | — |
| 1 | col-action | Menu ⋮ : Modifier / Supprimer | — |
| 2 | col-primary | Nom | res_nom |
| 3 | col-secondary | Abréviation | res_abreviation |
| 4 | col-secondary | Ruleset | var_valeur via JOIN dd_variables |
| 5 | col-secondary | Propriétaire | j_pseudo si res_j_id IS NOT NULL (supplément) |
| 6 | col-secondary | Nb sorts | COUNT dd_sorts WHERE so_res_id |

**Règle de suppression :** Une ressource ne peut être supprimée que si **aucune** des tables
du compendium ne lui est rattachée. La vérification porte sur l'ensemble du périmètre :

```
dd_classes, dd_races, dd_sorts, dd_dons, dd_competences, dd_historiques, dd_objets_magiques
```

Si des données existent, la suppression est refusée avec un message explicite.

**Formulaire modifier (overlay) :**
- res_nom, res_abreviation
- res_ruleset_var_id : SELECT des rulesets (dd_variables WHERE var_cat = 'ruleset')
- res_selection : checkbox "actif par défaut dans les sélections"
- res_editeur, res_pages, res_description

### Fichiers de la zone admin

```
admin/
  index.php              ← dashboard (2 cartes)
  utilisateurs.php       ← liste utilisateurs ($adminListConfig → admin-liste.php)
  ressources.php         ← liste ressources ($adminListConfig → admin-liste.php)
  enregistrement.php     ← POST commun admin (insert/update/désactivation)

include/
  admin-liste.php        ← moteur commun admin
  ajax/
    detail-pp/
      utilisateur.php
      ressource.php
    modifier/
      utilisateur.php
      ressource.php

css/
  admin-modules.css      ← chargé si $css_module = 'admin'

js/
  admin.js               ← tri, bulk, confirmation inline (clone adapté de compendium.js)
```

---

## 6b. Déploiement en production et migrations SQL — SP-DP

Deux briques distinctes :

| Brique | Où elle vit | Rôle |
|---|---|---|
| Module de déploiement `admin/deploiement/` | **Poste local uniquement** — jamais transféré | Calcule ce qui change, l'envoie par SFTP, pilote les étapes |
| Moteur de migrations `include/migrations.php` | Local **et** production | Joue les migrations SQL en attente de la base de l'environnement où il tourne |

### Le module ne fonctionne qu'en local — quatre verrous indépendants

1. **Auto-exclusion** : `admin/deploiement/` figure dans `DEPLOIEMENT_EXCLUSIONS_FIXES`, en dur ;
   `.deployignore` ne peut pas le réintégrer.
2. **Paramètres hors projet** : `C:/xampp/private/donjon-deploiement/` (`config.json`,
   `journal.jsonl`, `verrou.json`), à côté de htdocs : hors webroot, hors git, **hors OneDrive**,
   hors de portée du déployeur. Jamais en base : la base locale part régulièrement en dump dans
   `sql/`. Le mot de passe SFTP y est en clair (D-DP3).
3. **Requête venue du poste lui-même** : `deploiementEstLocal()` exige `REMOTE_ADDR`
   **identique** à `SERVER_ADDR`, et une adresse non publique. Couvre `localhost` comme
   l'adresse réseau du poste (`http://192.168.1.10/donjon/`, l'accès habituel) ; refuse un autre
   appareil du réseau (adresse différente) et tout serveur public (D-DP10). Jamais `HTTP_HOST`
   ni `DEV_MODE` : le client choisit l'en-tête Host, et `DEV_MODE` en dérive avec un repli
   permissif (D-CFG1).
4. **Apache** : `admin/deploiement/.htaccess` en `Require local`.

`include/header.php` et `admin/index.php` testent l'existence du fichier (`is_file()`) avant de
l'inclure : en production, il est absent, rien ne s'affiche et aucune erreur n'est levée.

### Périmètre — git fait foi

| Étape | Source |
|---|---|
| Candidats | `git ls-files -c -o --exclude-standard` : suivis + nouveaux non ignorés = l'arbre de travail tel qu'il est testé, commité ou non |
| − suivis mais ignorés | `git ls-files -c -i --exclude-standard` (`export/`, `tools/` commités avant d'être ignorés) |
| − `.deployignore` | `git ls-files -c -o -i --exclude-from=.deployignore` — même syntaxe que `.gitignore`, interprétée par git |
| − exclusions fixes | `admin/deploiement/`, `config/db.config.php`, `config/.migrations-jeton`, `.maintenance`, `.git/` |

git est lancé sans shell (`proc_open` en tableau), avec `-c safe.directory=<racine>` (dépôt sur
OneDrive). git introuvable ou en échec → **refus** ; aucun repli sur « tout le dossier ».
Côté `sql/`, seules les migrations datées et le `.htaccess` partent.

### Transport — SFTP par l'extension curl

Classe `DeploiementSftp` (interface `DeploiementTransport`), sans dépendance : le curl de PHP est
compilé avec libssh2. **Empreinte de la clé du serveur épinglée**
(`CURLOPT_SSH_HOST_PUBLIC_KEY_SHA256`) ; sans empreinte approuvée, toute connexion est refusée.
La lecture de l'empreinte se fait **sans s'authentifier** : épinglage volontairement faux, la
poignée de main échoue avant l'envoi de tout identifiant et libcurl cite l'empreinte réelle.
Dans les commandes SFTP (suppression), les chemins sont **relatifs** au dossier d'ouverture de la session : le préfixe `/~/` n'y est pas traduit, contrairement à l'URL. Seule l'absence du fichier est tolérée à la suppression ; tout autre échec interrompt l'étape (D-DP11). Une poignée curl par objet, `curl_reset()` entre deux opérations : la connexion SSH est
réutilisée d'un fichier à l'autre. Chemins distants relatifs au dossier d'accueil (`/~/` dans
l'URL seulement) ou absolus.

### Manifeste et plan

`<dossier privé distant>/manifeste.json` (hors `www/`) : chemin → SHA-256 de chaque fichier
**réellement envoyé**. L'aperçu compare l'arbre local au manifeste : nouveaux, modifiés, retirés
en local. **Suppressions** décochées par défaut et limitées aux fichiers du manifeste : l'outil
ne touche jamais à ce qu'il ne connaît pas (`img/uploads/`, logs OVH, `config/`). Pas de
manifeste = premier déploiement, tout part. « Tout renvoyer » ignore le manifeste.

Le plan vit en **session** : le navigateur ne transmet que son identifiant et l'index d'étape
attendu (vérifié). Ordre des étapes (`deploiementEtapes()`) :

```
maintenance → moteur + migrations (DEPLOIEMENT_PRIORITAIRES + sql/AAAA-MM-JJ_*.sql)
            → application des migrations → reste du code → suppressions → fin de maintenance
```

Le schéma évolue **avant** le code : les migrations ajoutent, l'ancien code supporte le nouveau
schéma, l'inverse plante. Sans fichier à envoyer, ni maintenance : seulement les migrations.
Lots de 20 fichiers ou 4 Mo par appel AJAX ; le manifeste est réécrit après chaque lot, même
interrompu. Les étapes sont **rejouables** : « Reprendre » relance la même ; « Abandonner » retire
la maintenance et le verrou. La session est relâchée pendant chaque étape
(`session_write_close()`) pour ne pas bloquer les autres onglets.

### Mode maintenance

Fichier `.maintenance` à la racine du site, posé et retiré par SFTP. `include/db.php` sert alors
`include/maintenance.php` (503, `Retry-After: 60`, autonome : ni session ni base). Seul
`admin/migrations-auto.php` passe outre (`define('MAINTENANCE_IGNOREE', true)`).

### Moteur de migrations — `include/migrations.php`

- Migration = `sql/AAAA-MM-JJ_*.sql`, jouée **une fois**, dans l'ordre alphabétique du nom.
  Les autres fichiers de `sql/` (dumps, seeds, imports) sont ignorés.
- Table `dd_migrations`, créée par `migrationsAssurerTable()` au premier appel. Si elle est vide,
  la **référence initiale** (`include/migrations-reference.php`, liste figée : 37 fichiers et
  leur SHA-256 au 2026-10-07) y est inscrite au statut `reference`, sans rien exécuter.
- Statuts : `executee` (par le moteur), `reference`, `marquee` (jouée à la main, déclarée depuis
  `admin/migrations.php`). « En attente » = fichier sans ligne.
- **Découpage** : `migrationsInstructions()` sépare les instructions et retire les commentaires
  (chaînes, échappements, `--␣`, `#`, `/* */` ; `/*! */` conservé). Chaque instruction passe par
  `query()` + `closeCursor()`. **Jamais `PDO::exec()` sur un script** : dès qu'une instruction
  renvoie un résultat (`SELECT`, `SHOW`, `OPTIMIZE`…), `exec()` rend la main sans lire la suite,
  ignore les erreurs suivantes et bloque la connexion (erreur 2014) — D-DP6.
- Arrêt à la **première erreur**, avec le rang et un extrait de l'instruction fautive. MySQL
  n'annule pas un `ALTER TABLE` : une migration en échec peut rester partiellement appliquée.
- **Remettre en attente** (`migrationsRemettreEnAttente()`) : retire une ligne `reference` ou `marquee` pour que le moteur la joue — cas d'une référence fausse (D-DP12). Jamais pour une migration `executee`. Diagnostic : `sql/diagnostic_reference_sp-dp.sql`.
- Un fichier modifié après application est **signalé** (empreinte), jamais rejoué. Pour corriger
  une migration passée, en écrire une nouvelle.
- Un script contenant `DELIMITER` est refusé : à passer par phpMyAdmin, puis « Marquer comme
  appliquée ».

### Déclenchement en production — jeton à usage unique

La base mutualisée OVH refuse toute connexion extérieure : le SQL ne peut partir que du serveur.

1. Le déployeur dépose par SFTP `config/.migrations-jeton` : l'**empreinte** SHA-256 d'un jeton
   aléatoire de 256 bits, jamais le jeton.
2. Il poste le jeton à `admin/migrations-auto.php` (redirection http → https suivie sans perdre
   le POST).
3. Le serveur compare (`hash_equals`), supprime le fichier (usage unique), refuse un fichier de
   plus de 5 min (horloge du serveur), puis applique les migrations en attente et répond en JSON.

Aucun secret stocké en production. Un jeton erroné ne détruit pas le fichier (pas de sabotage
possible). Le point d'entrée n'exécute que des fichiers **déjà sur le disque**, jamais du SQL
reçu : au pire, un tiers appliquerait en avance une migration légitime. Il ne dépend que de
`include/db.php` et `include/migrations.php`, envoyés avant lui.

`config/.htaccess` et `sql/.htaccess` refusent tout accès web (syntaxe `Order` / `Deny` du
`.htaccess` racine, éprouvée sur OVH).

### Fichiers

```
admin/deploiement/          ← LOCAL UNIQUEMENT (exclusion fixe)
  .htaccess                 Require local
  lib.php                   garde, paramètres, périmètre git, DeploiementSftp, manifeste,
                            plan, étapes, migrations distantes, test, verrou, journal
  garde.php                 requireAdmin() + requête venue du poste, sinon 404
  index.php                 paramètres, empreinte, test, périmètre, journal
  panneau.php               aperçu chargé dans #modification
  ajax.php                  demarrer / etape / abandonner (POST + CSRF)
  bouton.php                bouton du header + chargement CSS/JS du module
  deploiement.js / .css
admin/migrations.php        état des migrations de la base courante (local ET prod)
admin/migrations-auto.php   point d'entrée du déployeur (jeton)
include/migrations.php      moteur
include/migrations-reference.php   référence initiale figée
include/maintenance.php     page 503
.deployignore               exclusions versionnées
```

---

## 6c. Synchronisation du contenu local → production — SP-SY (en attente d'arbitrage)

> Projet instruit le 2026-10-10, **mis de côté, non prioritaire**. Rien n'est développé. Cette
> section garde l'analyse pour reprendre le chantier. Décisions : `DECISIONS_LOG.md` D-SY1.

### Besoin

Jean-Michel alimente la base **en local**, au fil du développement (compendium, règles,
tableaux…). Le déploiement (SP-DP) transfère les fichiers et la **structure** (migrations), pas
les **données** : la prod manque donc du contenu saisi en local. Le 2026-10-10, la resynchronisation
s'est faite par copie complète de la base, hors tables des comptes (D-DP13). Ce n'est plus possible
dès que la prod porte des données propres.

**Règle posée** : le contenu de la production n'est **jamais** écrasé ni effacé ; seul le contenu
local **absent** de la prod y est ajouté.

### Familles de tables (relevé du 2026-10-10)

| Famille | Exemples | Source |
|---|---|---|
| A. Référentiels purs (aucun champ propriétaire) | `dd_classe_niveau`, `dd_classe_capacite`, `dd_capacites_speciales`, `dd_sortclasse`, `dd_sortdomaine`, `dd_variables`, `dd_domaines`, `dd_fp` | Local |
| B. Compendium (`_res_id`, parfois `_camp_id`) | `dd_sorts`, `dd_dons`, `dd_classes`, `dd_races`, `dd_objets_magiques`, `dd_monstres`, `dd_regles`, `dd_tableaux`, `dd_ressources` | **Mixte** : contenu officiel (local) + suppléments et homebrew de campagne des joueurs (prod) |
| C. Données de jeu | `dd_personnages*`, `dd_campagnes*`, `dd_scenarios`, `dd_rencontres`, `dd_oppositions`, `dd_notes`, `dd_univers*` | Prod |
| Comptes | `dd_joueurs`, `dd_joueurs_sources`, `dd_connexions` | Prod — jamais synchronisées |
| Tables de travail | `*_backup_*`, `*_import`, `*_old`, `*_v1` | Jamais synchronisées |

### Principe technique pressenti

- **`INSERT IGNORE`** : MySQL ajoute une ligne si sa clé primaire est absente et l'ignore sinon.
  Envoyer tout le contenu local en `INSERT IGNORE` réalise exactement la règle, **sans comparaison
  ligne à ligne**. Les identifiants sont conservés, donc les liens entre tables restent justes.
- **Plages d'identifiants séparées, condition indispensable.** Le 2026-10-10, local et prod ont
  les mêmes identifiants (copie complète). Ensuite, chaque base numérote de son côté : une ligne
  créée en prod et une ligne créée en local recevraient le même numéro, et `INSERT IGNORE` perdrait
  la locale **sans bruit**. Parade : faire démarrer les compteurs de la prod à 1 000 000 sur les
  tables synchronisées (migration unique).
- **Ordre** : toujours **après** un déploiement et ses migrations, le schéma doit être identique.
- **Exécution en prod** : la base OVH n'accepte que les connexions de l'hébergement. Même
  mécanisme que les migrations : fichier déposé par SFTP hors `www/`, appliqué par un point
  d'entrée protégé par jeton à usage unique (§6b).
- **Compte rendu** par table : lignes ajoutées, et surtout lignes ignorées à cause d'une **autre**
  contrainte d'unicité (slug en double…), qui seraient sinon perdues sans bruit.

### Conséquences de la règle, à arbitrer

- Une ligne **modifiée en local** (description corrigée) n'est pas propagée : la prod a déjà la
  ligne et la garde.
- Une ligne **supprimée en prod** mais présente en local serait **rajoutée** à chaque
  synchronisation, sauf à mémoriser les suppressions côté prod.
- Personnages et campagnes créés en local sont rattachés aux comptes **locaux**, dont les
  identifiants peuvent différer de ceux de la prod.

### Questions d'arbitrage (SP-SY0)

1. Plages d'identifiants : faire démarrer les compteurs de la prod à 1 000 000 ?
2. Périmètre : familles A et B seulement, ou aussi la famille C créée en local ?
3. Modifications locales : les ignorer (règle stricte), ou les propager pour le contenu officiel ?
4. Suppressions faites en prod : les mémoriser pour ne jamais rajouter une ligne supprimée exprès ?
5. Forme : commande manuelle (`mysqldump --no-create-info --insert-ignore`, importée dans le
   phpMyAdmin d'OVH), ou bouton intégré au module de déploiement ?

**Solution d'attente sans développement** : `mysqldump --no-create-info --insert-ignore` sur les
tables voulues, importé dans phpMyAdmin OVH. Ce n'est sûr qu'**avant** que la prod ait créé ses
propres lignes, faute de plages séparées.

---

## 6d. Export de classes vers la production — SP-XC

> Décisions : `DECISIONS_LOG.md` D-XC1 → D-XC4. Module **local** (`admin/deploiement/`), jamais
> transféré.

### Usage

Administration → **Export de classes** (ou lien en bas de la page Déploiement). Choisir le ruleset,
cocher les classes, garder ou non la liste de sorts, puis **Aperçu** (script affiché, rien
d'écrit) ou **Générer la migration**. Le fichier `sql/AAAA-MM-JJ_xc-HHMMSS_<classes>.sql` est écrit
et marqué appliqué en local ; le prochain déploiement l'envoie et le fait jouer par le serveur.

### Ce qui part

| Table | Traitement en production |
|---|---|
| `dd_classes` | créée si absente, puis mise à jour sur place — jamais supprimée |
| `dd_classe_niveau`, `dd_classe_competence`, `dd_classe_sort` | lignes de la classe supprimées puis réinsérées |
| `dd_capacites_speciales` | créées ou mises à jour (texte local), puis rattachées (`dd_classe_capacite` remplacée) |
| `dd_sortclasse` | remplacée si l'option est cochée (défaut), sinon intacte |

Seules les classes cochées partent : une sous-classe ne suit pas sa base, ni l'inverse. Les classes
homebrew de campagne (`cla_camp_id`) ne sont pas proposées.

### Clés naturelles

Aucun identifiant local dans le fichier. Chaque référence est résolue en production dans une
variable SQL (`@xc_res_<id>`, `@xc_cla_<id>`, `@xc_cap_<id>` — l'id est celui du local, seulement
pour nommer la variable).

| Élément | Clé |
|---|---|
| Ressource | `res_nom` + ruleset |
| Classe | `cla_nom` + ruleset + parent (`IFNULL(cla_cla_id, 0) = 0` pour une base), `cla_camp_id IS NULL` |
| Sort | `BINARY so_nom` + ruleset + livre (`so_res_id` résolu), puis rang parmi les homonymes exacts (`ORDER BY so_id LIMIT rang, 1`). Sort sans livre : `so_res_id = 0` gardé |
| Compétence | `comp_nom` + ruleset |
| Capacité | même nom déjà rattachée à la classe → nom + origine + texte identique → nom + origine si univoque en local → création |

Colonnes recopiées : lues dans le schéma local (`SHOW COLUMNS`), moins les identifiants et clés
étrangères (`XC_EXCLUSIONS`). Une colonne ajoutée par migration suit sans retoucher le code ; le
schéma de la prod est identique puisque l'export passe après les migrations.

### Garde-fous

En tête de script, avant toute écriture : ressources, classes parentes non exportées, sorts et
compétences doivent exister en production. Sinon le script échoue sur
`SET @xc_garde := (SELECT 'XC : <message>' UNION ALL SELECT '' FROM DUAL WHERE <condition>)`
(erreur 1242), et le moteur affiche l'extrait qui commence par le message. Pas de `DO` : MariaDB
n'y lève pas l'erreur. Indispensable, `dd_classe_niveau` et `dd_classe_competence` étant en MyISAM.

À la génération, refus si deux classes portent le même nom dans un ruleset, ou si une classe a deux
capacités distinctes de même nom. Les liens orphelins locaux (vers un sort, une capacité ou une
compétence disparus) sont ignorés.

### Fichiers

```
admin/deploiement/export-classes.php       page (garde.php : admin + poste local)
admin/deploiement/export-classes-lib.php   xcClassesExportables(), xcGenerer(), xcEcrireMigration()
admin/deploiement/deploiement.css          .xc-script (bloc du script dans l'aperçu)
```

---

## 7. Module Personnages

### 7.1 Finalité — aide de jeu, pas moteur de règles

La fiche du site **ne remplace pas** la fiche papier du joueur. Le module est une **aide de jeu** : le joueur
et le MJ y saisissent certaines données du personnage, librement et partiellement, pour disposer de **liens
cliquables vers les règles du compendium** pendant la partie. Objectif : réduire les recherches dans les livres.

Conséquences directes :
- Aucune règle de construction n'est implémentée (pas de prérequis de dons, pas de point-buy, pas de contrôle niveau/classe).
- Tous les éditeurs sont **déclaratifs** ; la saisie peut rester incomplète sans générer d'erreur.
- Les validations serveur portent uniquement sur l'intégrité (FK, propriétaire, complétude d'une affectation NLS), jamais sur une règle de jeu.

### 7.2 Règles métier conservées

- Un personnage possède obligatoirement une race et au moins une classe.
- DD3.5 : race de base + archétype optionnel (`pe_arc_id`), classes de prestige, affectation NLS (`dd_personnages_nls`).
- DD2024 : pas d'archétype (`pe_arc_id = 0`), pas de classe de prestige, historique (`dd_historiques`).
- La campagne **en cours** est stockée dans `pe_camp_id` (NULL = aucune) ; l'historique des campagnes traversées
  reste dans `dd_campagnes_personnages` (liaison N-N). Un personnage n'est dans qu'une seule campagne à la fois.

### 7.3 Structure — fiche unique responsive

Abandon de la navigation multi-pages V1. Une **fiche unique** `personnages/fiche.php` regroupe toutes les sections
en blocs repliables (`togglePlus`). La **Magie** reste une **vue dédiée** (`personnages/magie.php`), plus lourde.

> Priorité absolue : responsive tablette / smartphone. Le module est majoritairement utilisé par les joueurs
> en cours de partie sur petit écran. Cibles tactiles larges, table des caractéristiques en grille fluide,
> aucune action critique dépendant du survol. Seuil 992px aligné sur les autres modules.

**Ordre des blocs de la fiche** (de haut en bas — Mode jeu en tête pour accès rapide en séance) :

| Ordre | Bloc | Données | Cliquable → detail-pp |
|---|---|---|---|
| 1 | Mode jeu *(emplacement réservé)* | Suivi PV et autres variables selon ruleset — **contenu différé**. **Masqué** sauf si `j_affichage_mode_jeu` est actif (profil) | — |
| 2 | Identité *(sans titre)* | Rangée : **Niveau**, Race (+ archétype DD3.5), Sexe, Alignement, Historique (DD2024) — puis les **classes**, une par ligne | Race, Historique, Classe |
| 3 | Caractéristiques + Init + CA + PV | Une rangée de blocs, sans titres. En DD2024 les caractéristiques portent une 4e colonne, le **jet de sauvegarde** (SP-PE11) | — |
| 3b | Jets de sauvegarde *(DD3.5)* | Réflexes, Vigueur, Volonté — bloc à part, le ruleset n'en a que trois et sous d'autres noms | — |
| 4 | Compétences + Dons | Une **rangée de deux blocs** au-dessus de 992px, empilés en dessous (SP-PE10m) | Compétence, Don |
| 5 | Capacités de race + de classe | Une rangée de deux blocs, déduite des tables de liaison — aucune saisie (SP-PE11) | Capacité |
| 6 | NLS prestige *(DD3.5)* | Affectation niveaux de prestige → classes de base lanceuses. **Sous** la rangée, pleine largeur, **replié par défaut** (SP-PE10n) | — |

### 7.3b Bloc Identité et rangée de stats (SP-PE10h)

**Rangée d'identité** — des couples libellé/valeur en `flex-wrap`, chacun **insécable** : il
passe à la ligne entier quand la largeur manque. Le **niveau total** l'ouvre ; il a quitté la
ligne sous le nom du personnage.

> `$niveau_global` **exclut les sous-classes** (`cla_clt_id = CLT_SOUS_CLASSE`). Une sous-classe
> DD2024 est une ligne de `dd_personnages_classes` comme une autre mais n'ajoute aucun niveau —
> les compter donnait 7 à un clerc 5 / guerrier 1, et un bonus de maîtrise faux avec.

**Classes** — une par ligne, séparées d'un liseré pointillé, **sans libellé « Classes » ni
« niv. »** : nom puis nombre. Le bouton Modifier est posé en **absolu** au bout de la première
ligne, dont le `padding-right` lui réserve sa place : un nom long passe à la ligne avant de
l'atteindre. Une **classe de prestige** (DD3.5) s'écrit en italique — le badge « P » est retiré.
Une **sous-classe DD2024** rejoint sa classe parente (`cla_cla_id`) entre parenthèses :
« Clerc 5 (Domaine de la Vie) ».

**Rangée caractéristiques / (maîtrise) / CA / PV** — trois blocs sans titre sur une rangée,
**quatre en DD2024** : le **bonus de maîtrise** y prend une tuile « Maît. », avant CA (SP-PE10l).
Il n'existe pas en DD3.5. Tuiles à base 96px pour que les trois tiennent jusqu'à 342px.

**Rangée caractéristiques / CA / PV** — trois blocs sans titre sur une rangée
(`.per-fiche__rangee`). Les six caractéristiques tiennent en **2 lignes de 3**, comme le bloc de
stats d'un monstre ; CA et PV sont deux tuiles `.per-stat`, libellé et valeur sur la même ligne.
Sous 992px, les caractéristiques prennent leur ligne et CA / PV se partagent la suivante.

**Blocs repliables** — `perReplierBloc(idCorps, btn)` bascule, `perDeplierBloc(idCorps, idBtn)`
ouvre sans refermer. Le second sert aux blocs **repliés par défaut** dont l'en-tête garde un
bouton Modifier : `nlsEditor` l'appelle avant d'ouvrir son éditeur, sans quoi celui-ci se
chargerait dans un corps masqué. Les deux corps d'un tel bloc (lecture et édition) sont
enveloppés dans un conteneur unique, que le chevron replie.

**Initiative, bonus de maîtrise, sauvegardes (SP-PE11)** — `pe_init` et `pe_for_save` …
`pe_cha_save` sont **saisis**, jamais calculés (§7.1). L'initiative occupe une tuile de la rangée
de stats, dans les deux rulesets ; le **bonus de maîtrise** DD2024 se lit derrière le niveau
global du bloc Identité, « Niveau 6 (BM +3) ». Les **sauvegardes** s'affichent en 4e colonne des
caractéristiques en DD2024 (grille à deux caractéristiques de front sous 992px) et dans un bloc
`Réflexes / Vigueur / Volonté` en DD3.5, qui n'en connaît que trois.

**Capacités spéciales (SP-PE11)** — deux blocs sur la rangée des listes, alimentés par
`dd_race_capacite` et `dd_classe_capacite` : aucune saisie. Les capacités de classe sont filtrées
sur `cc_niveau <= pc_niveau` et groupées par classe ; une **sous-classe DD2024** emprunte le
niveau de sa classe porteuse, un **archétype DD3.5** ajoute ses capacités à celles de la race.
Chaque titre ouvre `detail-pp/capacite.php`.

> **Le composant `.sort-detail` vit dans `modules.css`** depuis SP-PE13 — en-tête, lignes,
> libellés, description et tableaux. Seize fragments de `detail-pp/` l'emploient et s'ouvrent
> hors du compendium ; dans `compendium-modules.css`, il n'était chargé que sur neuf pages.
> Ses tableaux couvrent trois saisies : `<th>` en `<thead>`, `<th>` sans `<thead>`, et `<td>`
> en `<thead>`.

> `.modif-grid` (le `display: grid` des formulaires) vit aussi dans `personnages-modules.css` :
> elle n'était déclarée que dans les feuilles compendium et admin, que la fiche ne charge pas.

**Rangée Compétences / Dons (SP-PE10m)** — `.per-fiche__rangee--listes`, deux blocs à 50 % au-dessus
de 992px, empilés en dessous. `min-width: 0` sur les deux : sans lui, le tableau de l'éditeur de
compétences impose sa largeur intrinsèque et fait déborder la rangée dès l'ouverture.

> Ses trois éléments ont une **largeur fixe**, la même pour les six, calés à gauche : les deux
> rangs de trois sont à l'aplomb l'un de l'autre (SP-PE10o). `min-width: 0` est indispensable —
> sans lui, `min-width: auto` laisse une valeur à trois chiffres élargir sa boîte et décaler sa
> ligne. Les largeurs sont plus étroites sous 992px : celles du poste ne tiennent pas dans les
> 103px qu'une colonne de la grille mesure à 342px.

> **Chaque caractéristique tient sur UNE ligne, à toutes les largeurs** : abréviation sur son
> fond, valeur, modificateur — la forme de `.mo-carac-table`. Posée sur téléphone en SP-PE10i
> (236 → 71px), étendue à l'ordinateur en SP-PE10l (220 → 87px). Les tuiles CA / PV se resserrent
> d'autant.


> Les **constantes de type de classe** (`CLT_BASE_35`, `CLT_PRESTIGE`, `CLT_PNJ`,
> `CLT_BASE_2024`, `CLT_SOUS_CLASSE`) vivent dans `include/helpers.php`, à côté des `PROFINC_*` :
> les `clt_id` littéraux se dispersaient dans le code.

**Graisse et taille (SP-PE10j)** — règle d'interface du module : le **libellé porte le gras**, la
**valeur reste en graisse normale**, et les deux ont la même taille dans la même police. Elle vaut
pour les champs d'identité (`dt` / `dd`), les classes (nom / niveau), les tuiles CA / PV / Init,
les jets de sauvegarde et la colonne SAUV des caractéristiques — **sans exception** depuis
SP-PE12, qui a repris les deux écarts introduits en SP-PE11.

**Compétences** — la colonne **Carac porte deux valeurs** (abréviation et modificateur) et reçoit
donc 4.6rem, contre 3.2 pour Maîtrise/Rangs et Total ; sur téléphone, 4.2 contre 2.4. La colonne
de maîtrise DD2024 est **abrégée « M. » et « E »**, en lecture comme dans le select de l'éditeur,
le mot entier restant dans le `title`.

> **`getBonusMaitrise()` prend le palier, pas le niveau exact** : `dd_bonus_maitrise` s'arrête au
> niveau 20, et un personnage multiclassé totalisant davantage repartait avec un bonus de zéro —
> toutes ses compétences perdaient maîtrise et expertise à l'affichage.

> **Les boutons de la fiche n'ont que leur icône** — le `title` porte le sens. `js/personnage.js`
> réinjectait des libellés à chaque bascule d'éditeur : les masquer en CSS ne suffisait pas.
> Le title suivant la bascule (« Modifier les compétences » ⇄ « Annuler la modification »), les
> quatre éditeurs inline passent par `perBasculerBoutonEditer()`, qui relève le title d'origine
> au premier passage. Les boutons d'un éditeur **ouvert** — Enregistrer, Annuler, Ajouter une
> classe, Choisir des dons — gardent leur libellé : une icône seule y serait ambiguë.

### 7.4 Liste des personnages — `personnages/index.php`

Depuis **SP-RS6b**, la page délègue au moteur partagé `compendium-liste.php` (§10) : elle ne fait plus que
déclarer `$listConfig`. Pas de sources (`champ_res` absent), pas de filtre homebrew (`champ_camp => false`),
clic de ligne vers la fiche (`url_ligne`), suppression AJAX vers l'action `supprimerPersonnage`.
Filtrage par **ruleset actif en session** (`champ_ruleset`) et, pour un joueur, par propriétaire
(`extra_where` = `pe.pe_j_id = ?`).

**Portée admin (SP-PE9)** : un administrateur voit **tous les personnages du ruleset actif**, quel que soit
leur propriétaire — `extra_where` n'est simplement pas posé pour lui. Aucun droit nouveau n'est introduit :
les accès unitaires (fiche, `detail-pp`, `modifier`, `enregistrement`) passent tous par `canAccess()`, qui
autorise déjà l'admin ; seule la liste restait scopée. `pe_j_id` n'est jamais réécrit à la mise à jour :
un personnage édité par l'admin reste la propriété de son joueur.

**Filtres** (GET) :
- **Campagne** — select des campagnes du joueur (ruleset courant). Sémantique : `pe.pe_camp_id = ?`.
  En admin : **toutes** les campagnes non supprimées du ruleset, libellées `Nom (pseudo du MJ)` pour
  départager les homonymes.
- **Classe** — select de toutes les classes du ruleset. Sémantique : `EXISTS (… dd_personnages_classes …)`.
- **Joueur** — *admin seulement* : select des joueurs ayant au moins un personnage dans le ruleset actif.
  Sémantique : `pe.pe_j_id = ?`.
- **Recherche libre** — `pe.pe_nom LIKE ?` (% en début et fin).

**Colonnes desktop** : ⋮ · Nom · Race · Classes · Alignement · Campagne en cours.
En admin, une colonne **Joueur** (`jo.j_pseudo`, triable) s'intercale juste après le nom — le `LEFT JOIN
dd_joueurs jo` est posé dans tous les cas, seule la colonne est conditionnelle.

**Responsive** (< 992px) : seul le **nom** apparaît sur la première ligne ; race, classes, alignement et campagne
sont concaténés dans un résumé `text-muted` sur la ligne suivante.

### 7.5 Édition — commit global

L'édition passe par l'**overlay AJAX** `include/ajax/modifier/personnage.php` (pattern projet). L'overlay est
**local** (DOM/JS), **zéro écriture BDD**. Toute la persistance est centralisée dans `personnages/enregistrement.php`.

- **Identité** : formulaire classique. Background / notes via TinyMCE (config complète, avec images).
- **Classes / niveaux** : éditeur DOM déclaratif (nom de classe + niveau + domaines divins DD3.5), sans validation de règles.
- **Compétences** : éditeur **inline sur la fiche** (pas dans l'overlay — cf. D-PE3a), chargeant
  **toutes** les compétences du ruleset dans un tableau `.table-dd` filtrable par nom.
  DD3.5 : input numérique (rangs 0..99, borne technique seule). DD2024 : sélecteur 0 (aucune) /
  1 (maîtrise) / 2 (expertise). Total recalculé à la volée à chaque saisie.
  Persistance DELETE + INSERT en bloc des seules lignes `pec_maitrise > 0` — une liste vide est
  valide et efface toutes les compétences. Validation serveur : propriétaire, appartenance de la
  compétence au ruleset du personnage, bornage (2 en DD2024, 99 en DD3.5).
- **Dons** : **exception au commit global** — sélecteur dédié à écriture immédiate, voir §7.5b.
- **NLS prestige (DD3.5)** : éditeur inline sur la fiche, un tableau par classe de prestige influant
  sur le NLS ; pour chaque niveau, un select des classes de base lanceuses compatibles. Saisie
  déclarative, affectation partielle autorisée — voir §7.5d.

### 7.5b Sélecteur de dons — deux volets, écriture immédiate (SP-PE4)

`include/ajax/detail-pp/dons-picker.php`, ouvert dans **`#detail-pp`** depuis le bloc Dons de la
fiche. Le panneau sert à choisir plusieurs dons d'affilée, la description de chacun étant lisible
sans quitter la liste.

| Zone | Contenu |
|---|---|
| En-tête | Nom du personnage + **compteur du total de dons du personnage** (pas de la session de choix) |
| Filtres | Recherche libre sur le nom + select de catégorie (`dd_data_don`), filtrage **100 % client** |
| Volet gauche | Liste des dons du ruleset — bouton Ajouter/Supprimer, **nom cliquable**, catégorie. Ascenseur propre |
| Volet droit | Fiche du don cliqué (`detail-pp/don.php` chargé en AJAX) + bouton Ajouter/Supprimer à droite du nom |

**Comportement** (spécifié par l'utilisateur le 2026-08-13) :
- Chaque clic **écrit immédiatement** en base (`ajouterDon` / `supprimerDon`) — le panneau n'a pas
  de bouton « Enregistrer ». Voir la justification en `DECISIONS_LOG.md` D-PE4a.
- Le panneau **reste ouvert** ; on enchaîne les choix. Fermeture par le seul bouton ✕, qui recharge
  la fiche si quelque chose a changé. Le backdrop de `#detail-pp` ne ferme pas au clic — contrairement
  à `#detail-pp-sub` —, ce qui rend ce panneau sûr pour de la saisie.
- Un don choisi passe en **surbrillance** (`.is-possede`) et son bouton devient « Supprimer ».
- Le **compteur affiche le total renvoyé par le serveur** après chaque écriture, jamais une valeur
  extrapolée côté client.
- **Deux volets conservés à toutes les largeurs** (choix utilisateur, dérogation assumée à la
  priorité mobile du §7.3) : sous 992 px, le libellé des boutons disparaît au profit de la seule
  icône et la catégorie passe sous le nom.

**Points d'implémentation :**
- Le panneau **gère lui-même** son ouverture/fermeture au lieu de passer par `actualiserPage()` :
  il doit survivre aux choix successifs, et `actualiserPage()` n'exécute pas les `<script>` injectés —
  l'initialisation ne peut donc pas venir du HTML retourné.
- Le bouton du volet droit est **posé en JS**, pas dans `detail-pp/don.php` : ce fichier est partagé
  avec le compendium et n'a pas à connaître la notion de personnage.
- Les styles `.dons-picker*` sont dans **`modules.css`** (fragment injecté par AJAX — règle
  permanente du 2026-06-14), pas dans `personnages-modules.css`.
- Idempotence garantie par la clé unique `uk_ped (ped_pe_id, ped_do_id)` + `INSERT IGNORE`.
- `ped_niveau` reste `NULL` : le niveau d'acquisition n'est pas saisi (champ indicatif, non demandé).

### 7.5c Bloc Campagnes — rattachement à écriture immédiate (SP-PE5)

Le bloc (position 9 de §7.3) a deux modes, comme Classes et Compétences : lecture par défaut,
édition au bouton. L'édition, elle, suit le parti des **Dons** — écriture immédiate, aucun bouton
« Enregistrer » : ce sont des appartenances booléennes, un commit global n'aurait rien à regrouper.

| Mode | Contenu |
|---|---|
| Lecture | Campagne en cours en tête (filet `--clr-accent-2` + badge « En cours »), puis historique traversé. Badge « Participation terminée » si `cp_actif = 0`. Nom cliquable → `detail-pp/campagne.php` (contexte `externe`) |
| Édition | Une ligne par campagne rattachable, rendue en JS depuis `perCampagnesEditeur`. Actions : Rattacher / Détacher, Campagne en cours / Plus en cours, Clore la participation / Reprendre |

**Modèle de données — deux écritures solidaires.** `dd_campagnes_personnages` est la source de
vérité du rattachement, `pe_camp_id` n'est que le raccourci « campagne en cours » (`METIER_10`).
Toute action maintient les deux dans la **même transaction**, selon quatre règles :

1. Désigner une campagne en cours crée la liaison si elle manque et la force `cp_actif = 1` — une
   campagne en cours est par définition une participation en cours.
2. Clore la participation de la campagne en cours efface `pe_camp_id` (réciproque de la règle 1).
3. Détacher la campagne en cours efface `pe_camp_id` : le raccourci ne survit pas à la liaison.
4. `camp_id = 0` sur `definirCampagneCourante` signifie « aucune campagne en cours ».

**Périmètre du rattachement** : uniquement les campagnes **du propriétaire du personnage**
(`camp_j_id = pe_j_id`), dans **son ruleset** (`pe_ruleset_var_id`, jamais celui de la session).
L'application n'a aucun mécanisme d'invitation : rattacher à la campagne d'un tiers n'a pas de
sens tant que celui-ci n'existe pas. Le filtre porte sur `pe_j_id` et non sur l'utilisateur en
session, pour qu'un admin consultant la fiche d'un autre joueur voie la même liste que lui.

**Actions serveur** (`personnages/enregistrement.php`) : `rattacherCampagne`, `detacherCampagne`,
`definirCampagneCourante`, `basculerParticipationCampagne`. Chacune renvoie l'état relu en base
(`total`, `camp_courante`, `rattache`, `actif`) — l'éditeur n'extrapole jamais, une action pouvant
en déplacer une autre (désigner une campagne en cours en destitue une). `INSERT IGNORE` sur la clé
unique `uk_cp (cp_camp_id, cp_pe_id)` rend le rattachement idempotent.

**Effet sur les sources actives.** Cette phase réveille la **priorité 1 de `getActiveResIds()`**,
jusqu'ici du code mort faute de lignes en base. Son périmètre a donc été corrigé : la **campagne
en cours** du personnage (`pe_camp_id`), avec liaison active, et non plus l'ensemble de ses
campagnes `cp_actif = 1`. Sans ce correctif, une campagne terminée continuerait d'ouvrir ses
ouvrages dans tout le compendium de la session (`$_SESSION['last_pe_id']`).

**Points d'implémentation :**
- La liste de l'éditeur est l'**union** des campagnes rattachables et des campagnes déjà liées :
  une liaison devenue non conforme (ruleset changé) reste visible et détachable.
- `getCampagnesPersonnage()` retient une campagne si la liaison existe **ou** si elle est désignée
  courante — une donnée héritée d'avant SP-PE5 ne disparaît pas silencieusement de la fiche.
- Le mode lecture est rendu côté serveur : la fiche n'est rechargée qu'à la **fermeture** de
  l'éditeur, et seulement si une écriture a eu lieu (même parti que le sélecteur de dons).
- `.per-camp*` est dans `personnages-modules.css` (bloc rendu par `fiche.php`), **sauf**
  `.per-camp__badge`, placé dans `modules.css` : le panneau de campagne, fragment injecté en AJAX,
  l'utilise aussi (règle permanente du 2026-06-14).
- Côté Campagnes, `detail-pp/campagne.php` reçoit une section **Personnages** en lecture seule
  (nom, race, classes, statut). Les noms ne sont cliquables que pour les personnages accessibles
  (`canAccess`) — `detail-pp/personnage.php` est réservé à leur propriétaire.
- `cp_notes_mj` reste **non exposé** : `METIER_10` le déclare prévu mais non actif, dépendant du
  module Notes (Phase 5).

### 7.5d Bloc NLS prestige — affectation par niveau (SP-PE6, DD3.5)

Le bloc (position 7 de §7.3) suit le pattern **Classes / Compétences** : lecture par défaut,
éditeur DOM inline (`nlsEditor`, `js/personnage.js`) à **commit global** du bloc — ce sont des
valeurs choisies dans des selects, pas des appartenances booléennes (arbitrage du 2026-08-27).

**Condition d'affichage.** Le bloc n'est rendu que si le personnage a au moins une **classe de
base lanceuse** (`cla_clt_id = 1`, `cla_mag_id > 0`) **et** une **classe de prestige**
(`cla_clt_id = 2`) dont au moins un niveau détenu fait progresser le NLS (un des drapeaux
`cn_niveauSortArcane` / `Divin` / `Effectif` de `dd_classe_niveau` levé). Sinon il est omis de la
fiche — pas de bloc vide. `getPersonnageNls()` (`include/personnage_helpers.php`) porte cette
logique et renvoie null quand le bloc n'a pas lieu d'être.

**Rendu** : un tableau `.table-dd` par classe de prestige, une ligne par niveau détenu, trois
colonnes — Niveau · Progression (libellé des drapeaux : « Arcane », « Divin », « Effectif »,
cumulables) · Classe de base affectée.

| État du niveau | Lecture | Édition |
|---|---|---|
| Aucun drapeau levé (ou niveau absent de `dd_classe_niveau`) | « Sans progression de NLS » en `text-muted` | Ligne grisée, **sans select** |
| Affecté | Nom de la classe de base (non cliquable, cf. §7.3) | Select pré-positionné |
| Non affecté | **« À affecter » en rouge** (`--clr-danger`) | Select sur « — À affecter — » |

**Compatibilité des selects** (par niveau, drapeaux cumulés en union) : `effectif` → toutes les
classes de base lanceuses ; `arcane` → `cla_mag_id = 1` ; `divin` → `cla_mag_id = 2`.

**Persistance** (`personnages/enregistrement.php`, action `enregistrerNls`) : DELETE + INSERT en
transaction dans `dd_personnages_nls` (`penl_pc_id_base`, `penl_pc_id_prestige`, `penl_niveau`).
Seuls les niveaux réellement affectés sont postés : une liste vide est valide et efface toute
l'affectation. **L'affectation partielle est autorisée** (saisie déclarative, §7.1) — la
« complétude » validée par le serveur est celle de **chaque ligne postée** : les deux `pc_id`
appartiennent au personnage, la source est une classe de prestige, le niveau est dans les bornes
détenues, il fait progresser le NLS et la réceptrice est compatible avec son type de magie.
Ruleset verrouillé : l'action refuse tout personnage non DD3.5.

**Points d'implémentation :**
- Les affectations sont **remises à zéro par tout enregistrement des classes** :
  `enregistrerClasses` supprime toutes les lignes `dd_personnages_nls` du personnage avant de
  réinsérer les classes (comportement hérité de SP-PE2, conservé — les `pc_id` changent au
  DELETE + INSERT, les affectations ne peuvent pas leur survivre).
- Un niveau absent de `dd_classe_niveau` (saisie compendium incomplète) est traité comme « sans
  progression » : le bloc n'invente pas une affectation à faire.
- `.per-nls*` vit dans `css/personnages-modules.css` (bloc rendu par `fiche.php`, jamais injecté
  en AJAX) ; le select d'édition réutilise `.per-comp-editor__select`.

### 7.6 Magie — vue dédiée

`personnages/magie.php` affiche, par classe lanceuse de sorts :
- le **nombre de sorts par jour** par niveau de sort (calcul conservé, cf. 7.7) ;
- les listes de sorts **connus / compris / préparés**, cliquables → `detail-pp/sort.php` (contexte `externe`).

La liste de sorts proposée est bornée par `getActiveResIds()` (chaîne campagne → perso → défaut, §5).

### 7.6b Disposition d'un bloc de classe (SP-PE10b, refondue en SP-PE10p→r)

Le corps d'un bloc — un par classe lanceuse — se lit **en deux temps** :

| Temps | Contenu | Classe CSS |
|---|---|---|
| 1 | Synthèse de la classe (paires libellé / valeur) et tableau des emplacements, côte à côte au-dessus de 992px, l'un sous l'autre en dessous | `.per-magie__entete` > `.per-magie__stats` + `.per-magie__colonne-empl` |
| 2 | Listes de sorts en onglets, aide et actions de l'onglet actif à droite de la barre | `.per-magie__onglets` > `.per-magie__onglets-barre` + `.per-magie__panneau` |

**Synthèse (SP-PE10p)** — `<dl>` de paires, dans cet ordre : caractéristique (son **nom** sert de
libellé : « Intelligence 18 (+4) »), NLS (écart de classe en appoint grisé, seulement s'il
existe), DD (formule « 10 + niv. +N » en DD3.5), attaque (DD2024 seulement — le champ n'est pas
produit en DD3.5), sorts mineurs (DD2024, `cn_sort_n0`), renouvellement, domaines. Règle de
graisse du module : libellé gras, valeur normale, même taille. Au-dessus de 992px, grille à deux
colonnes séparée du tableau par un filet vertical ; en dessous, champs insécables en flux, à la
façon de `.per-identite` — les quatre premiers tiennent sur deux lignes à 375px.

> Le panneau « Ressources de sorts » de SP-PE10b n'existe plus : ses compteurs de listes sont
> passés dans les onglets, le reste dans la synthèse. Le total « Sorts connus » (grimoire + à
> recopier) est abandonné.

**Tableau des emplacements (SP-PE10c, SP-PE10q)** — une seule rangée d'en-tête, la case d'angle
portant « Niv. » ; lignes « Par jour », « Sorts connus » (répertoire DD3.5) et « Restant » (miroir
de « Par jour » tant que `SP-PE8` n'a pas livré le suivi des emplacements consommés). Au-dessus
de 992px, `.per-magie__table` surcharge `.table-dd` : en-tête en retrait (.85rem, grisé), corps à
1rem gras, colonnes à 34px, padding 2px/8px. Le séparateur accentué de `.table-dd` est neutralisé
sur cette table : elle n'a qu'une colonne de libellés en regard des niveaux.

**Onglets (SP-PE10r)** — un jeu par bloc de classe, motif ARIA `tablist` (flèches gauche / droite),
onglets **secondaires** (soulignés, plus petits que la barre Fiche / Magie / Possessions) :

| Profil | Onglets |
|---|---|
| `PROFINC_GRIMOIRE` | **Préparés** · Grimoire · À recopier |
| `PROFINC_LISTE`, pacte | Préparés |
| `PROFINC_REPERTOIRE` | Répertoire |

Un profil à liste unique garde la barre réduite à un onglet : elle lui sert de titre et porte ses
actions. Chaque onglet affiche son **compteur** — `N/plafond` pour Préparés en DD2024
(`cn_sortPrepare`), le seul nombre préparé en DD3.5, où le tableau borne. **En DD2024, les sorts
mineurs (niveau 0) n'entrent pas dans ce compteur** (SP-PE10s) : ils sont connus, pas préparés,
et `cn_sort_n0` les compte à part ; en DD3.5 le niveau 0 occupe de vrais emplacements et compte.
Même règle dans le sélecteur (rendu serveur et `_majCompteurs()`). Ses outils — icône d'aide,
puis un bouton **icône seule** (`title` et `aria-label`) : « Préparer », ou « Gérer » (le
sélecteur en mode répertoire) — ne sont visibles que s'il est actif. « Réinitialiser la liste
préparée » vit dans le sélecteur de préparation (§7.6c). Les **sorts toujours préparés** ferment
le premier onglet, groupés par variante puis par niveau.

L'onglet actif est mémorisé **par bloc** en `sessionStorage` (`perMagieOnglet:<pe_id>:<pc_id>`,
lectures et écritures sous try/catch, repli sur le premier onglet) : le sélecteur de sorts
recharge la page à sa fermeture. JS : `perOnglets` dans `js/personnage.js`.

**Listes** — une ligne par niveau de sort (`.per-magie__niveau`) : la pastille de niveau une seule
fois en tête, puis les sorts en flux (`flex-wrap`, 16px entre deux sorts) qui repartent à
l'aplomb du premier. Un sort dont le niveau n'est pas résolu pour la classe ferme la liste
derrière une pastille « ? ».

### 7.6c Sélecteur de sorts — deux volets, écriture immédiate (SP-PE7b, SP-PE10d)

`include/ajax/detail-pp/sorts-picker.php`, injecté dans `#detail-pp`. Deux modes portés par la
même page : `repertoire` (alimente `dd_personnages_sorts`) et `prepare` (alimente
`dd_personnages_sorts_prepares`). Toujours **porté par classe** : une écriture ne touche jamais
la liste d'une autre classe du personnage.

**Styles (SP-PE10d)** — le composant emprunte la coque `.dons-picker` (§7.5b) mais ses éléments
propres vivent dans `css/modules.css`, section « Sélecteur de SORTS » : `.dons-picker__items`,
`.dons-picker__toggle`, `.dons-picker__decompte`, `.dons-picker__grimoire`, `.est-choisi`,
`.sorts-picker__compteur(s)`, `.sorts-picker__jeton`, `.est-plein`. Un **sort retenu** porte un
fond `color-mix` dérivé de `--clr-accent` et un filet d'accent à gauche.

**Téléphone (< 992px)** — le volet de description est masqué et la liste prend toute la largeur ;
la fiche du sort s'ouvre dans **`#detail-pp-sub`**, par-dessus le sélecteur, qui reste ouvert.
Le seuil est porté des deux côtés : média-query CSS et `matchMedia` dans `sortsPicker.voir()`.
Lignes resserrées, bouton de 44px — c'est lui qui fixe la hauteur de ligne.
La liste y perd aussi **bordure et arrondi** et déborde du padding du panneau de `--sp-sm` de
chaque côté (SP-PE10g) : son cadre redoublait celui de l'overlay à quelques pixels près. Le
compteur DD3.5 descend à 40px par bouton (SP-PE10f) — il en demande deux là où les autres modes
n'en ont qu'un.

**Filtre « les siens »** — une seule case pour les deux modes, libellée « Les siens seulement »
en répertoire et « Les préparés seulement » en préparation ; `est-choisi` porte les deux sens.

**Groupement par niveau (SP-PE10f)** — la liste arrive triée par niveau puis par nom ; un
`<li class="sorts-picker__entete">` marque chaque rupture et remplace la pastille que portait
chaque ligne. L'en-tête est `sticky` en haut de la liste et **se masque avec son groupe** :
`filtrer()` relève les niveaux encore représentés avant d'effacer les en-têtes orphelins.

**Quantité préparée (SP-PE10e, DD3.5 seulement)** — un magicien DD3.5 mémorise plusieurs fois le
même sort, chaque exemplaire occupant un emplacement de son niveau. En préparation DD3.5, la
ligne porte donc un compteur `[−] N [+]` (encadré, pour ne pas se confondre avec la pastille de
niveau qui le suit) et chaque clic vaut un exemplaire : `preparerSort` incrémente `pesp_nb`,
`retirerPrepare` le décrémente et supprime la ligne au dernier retrait. Les jetons de compteur
par niveau somment les `data-nb`, pas les lignes.

> **En DD2024 la bascule est conservée** : la liste préparée y est un ensemble de sorts
> distincts — on lance n'importe lequel avec l'emplacement de son choix — et `cn_sortPrepare`
> plafonne des sorts distincts. `gardeSortPersonnage()` rend le ruleset pour trancher côté
> écriture.

> `pesp_nb` vaut 0 par défaut en base alors qu'un exemplaire compte pour 1 : toute lecture passe
> par `GREATEST(pesp_nb, 1)`.

**Bouton « Réinitialiser » (SP-PE10s)** — en mode préparation, sur la ligne des compteurs
(`.sorts-picker__barre-prep`), à droite. Appelle `sortsPicker.reinitialiser()`, qui vide la liste
préparée de la classe (les sorts toujours préparés sont conservés) puis recharge la page. Il
quittait une place permanente dans la vue Magie pour un geste rare.

**Bouton « recopier dans le grimoire »** — n'a de sens que sur un sort retenu. Rendu par le
serveur sur les sorts déjà connus, **posé et retiré en JS** (`_majBoutonGrimoire()`) au fil des
bascules. Le profil descend dans le DOM par `data-grimoire`.

### 7.7 Calcul NLS et sorts par jour (conservé)

Exception assumée au principe « aide de jeu » : le calcul est conservé car NLS et emplacements sont liés par les
règles métier et aident réellement en séance.

```
NLS effectif = niveau de classe de base
             + bonus des classes de prestige (dd_personnages_nls, selon cn_niveauSortArcane/Divin/Effectif)
Emplacements = dd_classe_niveau.cn_sort_n0..9 (au NLS effectif)
             + bonusSortsCarac(valeur, niveau)   (helpers.php — SP-MA1)
             + 1 par niveau de sort > 0 si la classe choisit des domaines divins (DD3.5)
```

DD2024 : nombre de sorts préparés via `cn_sortPrepare` ; bonus de maîtrise via `dd_bonus_maitrise`.

### 7.7b Total de compétence (conservé — SP-PE3)

Deuxième exception assumée au principe « aide de jeu », de même nature que le NLS : le total est
le chiffre que le joueur cherche au moment de lancer le dé, et le recalculer de tête à chaque jet
annule le bénéfice de la fiche.

```
DD3.5   Total = rangs (pec_maitrise) + modificateur de la caractéristique associée
DD2024  Total = modificateur de la caractéristique associée
              + bonus de maîtrise (dd_bonus_maitrise au niveau global)
                × 1 si maîtrise, × 2 si expertise
```

Le total est **volontairement incomplet** : ni équipement, ni malus d'armure, ni bonus divers — ces
données ne sont pas saisies dans le module. La fiche l'annonce explicitement sous le tableau ; c'est
une aide de calcul, pas une valeur de fiche opposable.

Helpers : `bonusCompetence()` et `getBonusMaitrise()` (`include/personnage_helpers.php`), dupliqués
en JS dans `competencesEditor` pour le recalcul à la volée pendant la saisie.

> **Ruleset des sources — règle du module.** `getActiveResIds($db, $ruleset_var_id)` prend un second
> paramètre optionnel. La fiche et l'overlay Personnage passent **le ruleset du personnage**
> (`pe_ruleset_var_id`, figé à la création), jamais celui de la session : les deux divergent dès
> qu'un personnage est consulté depuis une session réglée sur l'autre ruleset, et le croisement
> vide silencieusement toutes les listes (compétences, classes, races). Le compendium, lui, garde
> le repli sur la session. Voir `DECISIONS_LOG.md` [2026-08-13].

**Compétences sans caractéristique** : `comp_car_id = 0` est une valeur légitime (« Langue » en
DD3.5). Le chargement fait donc un **LEFT JOIN** sur `dd_caracteristiques` — un INNER JOIN
supprimerait silencieusement ces compétences de la fiche. Modificateur 0, colonne Carac affichée
« — ».

### 7.8 Stockage des sorts

- `dd_personnages_sorts` : sorts connus (présence de ligne) / compris (`pes_compris = 1`), rattachés à `pes_pc_id`.
- `dd_personnages_sorts_prepares` : sorts préparés, avec métamagie DD3.5 (`pesp_metamagie`, `pesp_niveau`, `pesp_nb`).

### 7.9 Pages annexes

- `personnages/objets.php` : placeholder « Fonctionnalité à venir » (analyse métier non fiabilisée, aucune table).
- Onglet Notes : emplacement réservé ; le contenu relève du module Notes (Phase 5). La préférence d'affichage
  (campagne en cours / toutes les campagnes) est mémorisée sur le personnage (`pe_notes_scope`).

### 7.10 Fichiers du module

```
personnages/
  index.php          Liste filtrée (campagne / classe / recherche libre), responsive
  fiche.php          Fiche unique (sections repliables, Mode jeu en tête)
  enregistrement.php Routeur d'actions transactionnelles (commit global)
  magie.php          Vue dédiée Magie (NLS, emplacements, sorts cliquables)
  objets.php         Placeholder « Fonctionnalité à venir »

js/personnage.js                Menu contextuel, suppression inline, éditeurs DOM (3.2+)
css/personnages-modules.css     Styles module — chargé si $css_module = 'personnages'

include/personnage_helpers.php  getPersonnageContext, getPersonnageClasses,
                                getCampagnesPersonnage, getCampagnesRattachables,
                                getAlignements, getPersonnageCompetences,
                                getBonusMaitrise, modCarac, formatMod, bonusCompetence,
                                getPersonnageNls, libelleProgressionNls
                                (calcul NLS effectif et emplacements ajoutés en SP-PE7)

include/ajax/detail-pp/personnage.php   Vue détail (contexte 'externe' depuis Campagnes)
include/ajax/detail-pp/dons-picker.php  Sélecteur de dons deux volets (SP-PE4, voir §7.5b)
include/ajax/detail-pp/campagne.php     Section « Personnages » du panneau campagne (SP-PE5)
include/ajax/modifier/personnage.php    Overlay création / modification
```

> **SP-PE5 et SP-PE6 n'ont créé aucun fichier** : les blocs Campagnes et NLS prestige vivent dans
> `fiche.php`, leurs actions dans `enregistrement.php`, leurs éditeurs (`campagnesEditor`,
> `nlsEditor`) dans `js/personnage.js`.

### 7.11 Découpage en phases — code projet `SP-PE`

> **L'état d'avancement fait foi en §0.** Cette section ne décrit que le contenu de chaque phase ;
> les cases à cocher vivent exclusivement dans le tableau de bord.

| Phase | Ancien n° | Contenu |
|---|---|---|
| `SP-PE0` | 3.0 | Socle + SQL |
| `SP-PE1` | 3.1 | Fiche identité + première classe à la création |
| `SP-PE2` | 3.2 | Classes & niveaux (éditeur DOM inline, domaines divins DD3.5) |
| `SP-PE3` | 3.3 | Compétences (tableau complet du ruleset) |
| `SP-PE4` | 3.4 | Dons |
| `SP-PE5` | — | Bloc Campagnes de la fiche (lecture + rattachement, voir §7.5c) |
| `SP-PE6` | 3.5 | NLS prestige (DD3.5) |
| `SP-PE7` | 3.6 | Vue Magie (calcul NLS + sorts par jour + listes cliquables) |
| `SP-PE8` | 3.7 | Emplacement Mode jeu + passe responsive < 992px |

Ordre de reprise recommandé : `SP-PE7` → `SP-PE8`. `SP-PE7` (Magie) reste la plus lourde.

> `SP-PE5` avait été annoncée « lecture seule sur des données déjà disponibles ». Vérification
> faite à sa reprise : ces données ne pouvaient pas exister — aucun écran n'alimentait
> `dd_campagnes_personnages` ni n'écrivait `pe_camp_id`. La phase a donc livré le rattachement
> avec l'affichage (§7.5c). Leçon reportée dans `DECISIONS_LOG.md` [2026-08-14].

**Aucun patch SQL n'est attendu de `SP-PE3` à `SP-PE8`** : `dd_personnages_competences`,
`dd_personnages_dons`, `dd_personnages_nls`, `dd_personnages_sorts` et
`dd_personnages_sorts_prepares` existent déjà en base (cf. `SCHEMA_SQL.md`).

---

## 8. Module Campagnes

> Détails : `ARCHITECTURE_8_CAMPAGNES.md` (technique) et `METIER_10_Campagnes.md` (fonctionnel).
> Structure de données validée — schéma `SCHEMA_SQL.md` v1.1 (section 7).

Hiérarchie : **Campagne → Scénario → Chapitre → Rencontre → Opposition**

- **Campagne** : 1 propriétaire (`camp_j_id`, le MJ), 1 ruleset (`camp_ruleset_var_id`, **maître**,
  hérité par tout le contenu), 0–1 univers (`camp_un_id`, univers agnostiques du ruleset).
- **Sources** : `dd_campagnes_sources` — priorité 1 de la chaîne `getActiveResIds()`.
- **Personnages** : lien **N-N** via `dd_campagnes_personnages` (source de vérité).
  `dd_personnages.pe_camp_id` n'est qu'un raccourci « dernière campagne jouée ».
  Le rattachement se pilote **depuis la fiche du personnage** (SP-PE5, §7.5c) ; le panneau de
  campagne n'en donne qu'une vue en lecture seule (section « Personnages »), et le compteur de
  `campagnes/index.php` s'appuie sur la même table.
- **Rencontre** : rattachement à un chapitre **obligatoire** (`re_scc_id` NOT NULL).
  Effectifs décrits **littéralement** dans `re_composition` (texte).
- **Opposition** : copie **éditable** d'un monstre du compendium (`dd_oppositions`), propre à une
  rencontre (lien 1-N `opp_re_id`) — **ou saisie 100% manuelle**, sans monstre d'origine
  (`opp_mo_id` nullable depuis le 2026-06-20). Quand un monstre modèle est choisi (`opp_mo_id`
  renseigné), il est figé pour traçabilité ; sinon `opp_mo_id` reste `NULL` définitivement.
- **Duplication** : scénario / rencontre / opposition duplicables (suffixe « - copie »), en cascade
  descendante, **limitée au ruleset courant**.
- **Pièces jointes** : PDF uniquement, table générique `dd_fichiers`.
- **Suppression douce** (flag `_supprime`, cascade application, unlink PDF, pas d'UI restauration).
- **Contexte de navigation (header)** : derniers campagne/scénario/chapitre consultés mémorisés en
  session, raccourcis affichés dans le header sur toutes les pages — voir §12.
- **Ordre d'affichage** : les quatre niveaux sont ordonnés **manuellement**, par glisser-déposer
  (`sce_ordre`, `scc_ordre`, `re_ordre`, `opp_ordre`). Jamais saisi dans un formulaire — deux
  sources de vérité pour un même rang, c'est une de trop. Un nouvel élément se pose en fin de
  liste (`MAX(ordre)+1`), une opposition transférée ou dupliquée aussi.

**Liste `campagnes/index.php`** — liste dédiée (pas le moteur `compendium-liste.php`), filtrée sur
`camp_j_id = j_id` **et** `camp_ruleset_var_id = $_SESSION['ruleset_var_id']`, comme la liste des
personnages (§7.4, qui en est calquée). Le ruleset étant constant sur toute la liste, il est affiché
dans le titre — `Campagnes (DD2024)` — et non en colonne. Colonnes : ⋮ · Nom · Univers · Scénarios ·
Personnages. Une campagne est toujours créée dans le ruleset actif (§3, saisie impossible) : elle
apparaît donc immédiatement dans la liste où on vient de la créer.

Module **NON responsive** — usage desktop MJ exclusif. Menu visible si `j_mode_campagne = 1`.

### 8b. Navigation pleine page — SP-CP (2026-08-24)

Le module a **quitté `#detail-pp`**. Chaque niveau est une page :
`campagnes/campagne.php?id=` · `scenario.php?id=` · `chapitre.php?id=` · `rencontre.php?id=`.
Les quatre handlers `include/ajax/detail-pp/{campagne,scenario,chapitre,rencontre}.php` sont
supprimés, ainsi que `detail-pp-sub/opposition.php`, devenu orphelin. `detail-pp/monstre.php`
reste : un monstre du compendium se consulte en panneau depuis n'importe où, y compris depuis les
liens `.mo-lien` d'un bloc de stats d'opposition.

**Pourquoi** — le panneau convenait à la consultation ponctuelle, pas à la conduite d'une partie :
pas d'URL partageable, pas de retour navigateur, pas de place pour des outils de jeu, et une pile
`_detailPpStack` à tenir à jour à chaque écriture.

**Gabarit** (`css/campagnes-modules.css`, `.camp-page*`) — cible **1536 × 799** :

| Élément | Règle |
|---|---|
| Largeur du cadre | `body.camp-plein .site-main { max-width: 1500px }` — `--main-max` (1200px) est trop étroit pour une table de jeu |
| Grille | `minmax(260px, 25%)` + `minmax(0, 1fr)` — 363px / 1065px à la cible |
| Colonne gauche | Outils, `position: sticky` sous le header collant |
| Colonne droite | Données du niveau ; bandeau de titre avec nom, bouton Modifier et **bouton retour** vers le niveau supérieur |
| < 992px | Une colonne, outils au-dessus dans un bloc **replié par défaut** (`campToggleOutils()`) |

**Colonne d'outils** — `include/campagne-outils.php`, fragment commun aux quatre pages. Elle ne
contient à ce jour que l'**écran du MJ** (SP-TB8), affiché mais inerte. Le reste des aides de jeu
est à arbitrer (SP-CP8).

**Écritures** — les formulaires restent des overlays `#modification` (les cinq `modifier/*.php`
sont réutilisés tels quels). Une seule règle après commit : **recharger la page courante**, on
reste là d'où l'action est partie. Deux exceptions : la création d'une campagne depuis la liste
mène à sa page, et la suppression d'une campagne remonte à `index.php`. Corollaire :
`enregistrement.php` ne renvoie plus d'`url_detail` — le serveur ignore depuis quel niveau le
formulaire a été ouvert, la page le sait.

**Oppositions** — sur `rencontre.php`, ce ne sont plus des lignes de tableau à ouvrir une par une,
mais des **cartes dont le bloc de stats est rendu déplié** (`rendreStatsMonstre()`, index scopé aux
sources de la campagne via `getActiveResIdsCampagne()`). En partie, lire une créature ne doit
coûter aucun clic. Un bouton burger permet de replier au cas par cas.

**Listes** — plus de colonne dédiée au code / à l'abréviation : quand il existe, il **préfixe le
nom**, séparé par ` : ` (`C5 : Événement 5`), sans grisé — c'est une part du titre, pas une
métadonnée. Vaut pour les chapitres (`scc_abreviation`), les rencontres (`re_code`) et les
bandeaux de titre. La ligne entière est cliquable (`tr[data-href]`, handler délégué de
`js/campagne.js`), un vrai `<a>` restant posé sur le nom ; poignée de tri, menu ⋮, boutons et
liens sont exclus de la zone.

---

## 9. Module Wiki / Univers

Univers (public/privé) → Catégories → Articles (visible/caché)
Délégation droits via dd_univers_droits. En v1 : globale sur l'univers entier.

---

## 9b. Module Règles

Module de référence transverse : un **wiki de règles** hiérarchique et récursif, pensé pour
la consultation rapide par le MJ pendant ses parties et la recherche d'une règle précise.

### Principe — table unique récursive

Une **table unique** `dd_regles` (préfixe `reg`) modélise l'intégralité d'un livre de règles
d'un ruleset. Chaque nœud référence son parent via `reg_reg_id` (NULL = racine). Un nœud porte
un `reg_type` qui sert d'indice sémantique et d'affichage :

| reg_type | Rôle | Arbre | Contenu |
|---|---|---|---|
| `chapitre` | Conteneur structurel (peut avoir une intro) | dossier | `reg_texte` optionnel |
| `regle` | Unité consultable (feuille en pratique) | page | `reg_texte` = corps de la règle |
| `glossaire` | Terme de glossaire (définition courte, cible de renvoi) — DD2024 et DD3.5 | page | `reg_texte` = définition |

### Schéma de la table dd_regles

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| reg_id | int unsigned | PK | |
| reg_reg_id | int unsigned | null | Parent récursif -> dd_regles ; NULL = racine |
| reg_type | enum('chapitre','regle','glossaire') | nn, défaut 'regle' | |
| reg_nom | varchar(200) | nn | Titre |
| reg_slug | varchar(220) | nn, UK(reg_slug, reg_ruleset_var_id) | Version URL-safe |
| reg_texte | longtext | null | Contenu HTML (TinyMCE) |
| reg_ordre | smallint unsigned | nn, défaut 0 | Ordre parmi les frères |
| reg_ruleset_var_id | int unsigned | nn | -> dd_variables |
| reg_camp_id | int unsigned | null | **RÉSERVÉ** house rules futures |
| reg_visible | tinyint(1) | nn, défaut 1 | 0 = brouillon/masqué |
| reg_date_creation | datetime | nn | |
| reg_date_modif | datetime | nn | |

### Périmètre / scoping

- Scoping **ruleset uniquement** (`reg_ruleset_var_id`). Le moteur `compendium-liste.php` **ne s'applique pas** à ce module.
- `reg_camp_id` (nullable) est **réservé** pour de futures *house rules* de campagne.

### Droits d'édition

Même portail que le compendium global : édition réservée à `admin` + `j_compendium_manager`
(via `canEditCompendium()`). Consultation : tout utilisateur authentifié.

### Navigation « comme un livre »

1. **Sommaire / arbre** (`regles/index.php`) — arbre récursif repliable du ruleset actif.
2. **Fil d'Ariane (breadcrumb)** — sur la vue lecture.
3. **Précédent / Suivant (ordre de lecture)** — calculés sur l'**ordre de lecture linéarisé** (DFS).

### Glossaire et renvois cliquables

Termes = nœuds `dd_regles` (`reg_type = 'glossaire'`). Renvois = ancres `.glossaire-lien[data-glossaire-slug]`
dans `reg_texte`. Clic → `actualiserPageSub()` vers `detail-pp-sub/glossaire.php` (sous-panneau).

Les ancres peuvent être **écrites à la main** dans `reg_texte` (renvois du seed, entre définitions)
ou **produites au rendu** par le parser SP-GL (voir §9d). Les deux formes sont identiques et
partagent le même handler. L'index du parser est par ruleset : DD2024 (155 termes, chapitre
« Glossaire de règles ») et DD3.5 (mini-glossaire, voir ci-dessous) coexistent sans se mélanger.

### Contenu DD3.5 — import des fichiers DRS (SP-DRS)

Import itératif, un lot de fichiers DRS à la fois, arbitré le 2026-08-25 :

- **Arborescence thématique** — les racines ne calquent pas les fichiers DRS : `Les bases du jeu`
  (ordre 10), `Le combat` (20), `Aventure et environnement` (30), `Équipement` (40, SP-DRS2),
  `Objets magiques` (50, SP-DRS3), `Créatures et pouvoirs spéciaux` (60 — était 40), `Glossaire` (90). `reg_ordre` par pas de 10 partout : les lots suivants
  s'intercalent sans renumérotation. Sous une racine, un fichier DRS devient un `chapitre`
  (ex. `Les caractéristiques`), sauf quand thème et fichier coïncident (`Le combat` : les règles
  de DRS 10 sont ses enfants directs).
- **Pages longues par section** — pas un nœud par manœuvre ou par état : une règle par section
  du DRS, structurée en `<h3>` (ex. `Attaques spéciales`, `États préjudiciables`).
- **Mini-glossaire** — le DRS n'a pas de glossaire ; les termes techniques majeurs (actions,
  manœuvres, états, pouvoirs…) sont compilés au fil du traitement en définitions courtes
  `reg_type='glossaire'` sous la racine `Glossaire`, avec renvoi vers les chapitres. La casse
  exacte du parser SP-GL limite volontairement la liaison automatique : le texte 3.5 ne
  capitalise pas ses termes en milieu de phrase (à la différence du SRD 2024).
- **Tableaux** — saisis directement en convention texte dans `dd_tableaux` (aucun HTML à migrer,
  contrairement à l'historique DD2024), tags `[[tab:slug]]` dans `reg_texte`.
- **Attribution** — ressource dédiée `DRS 3.5` (OGL 1.0a), créée par le socle. Le schéma réel de
  `dd_ressources` n'a **pas** de colonne `res_pages` (le seed DD2024 la référençait — ne pas
  copier ce modèle). Le socle ajoute aussi la ressource aux **sélections personnelles DD3.5
  existantes** (`dd_joueurs_sources`) : sans cela, le gestionnaire de tableaux et les listes
  compendium filtrées par source ne montreraient jamais son contenu aux joueurs ayant une
  sélection (D-DRS2), alors que les pages Règles — non filtrées — l'affichent.
- **Fichiers SQL** — un socle (`sql/2026-08-25_regles_dd35_socle.sql`, idempotent, jamais
  destructif) + un fichier par DRS + un fichier glossaire par lot. Aucun `reg_id` codé en dur
  (parents via `LAST_INSERT_ID()` et variables `@`), réinitialisation idempotente limitée au
  sous-arbre du chapitre concerné (le glossaire supprime par liste de slugs, pour ne pas effacer
  les termes des autres lots).

### Fichiers du module

```
regles/
  index.php, regle.php, recherche.php, enregistrement.php

include/
  regles-arbre.php
  glossaire-parser.php
  ajax/
    detail-pp/regle.php
    detail-pp-sub/glossaire.php
    modifier/regle.php

css/regles-modules.css
js/regles.js
```

---

## 9d. Liaison automatique du glossaire — SP-GL

Projet **SP-GL**. Moteur : `include/glossaire-parser.php`, point d'entrée
`lierGlossaireAuto(PDO $db, ?string $html, int $ruleset_id, int $exclure_id = 0)`.

Transforme au rendu les mentions d'un terme de glossaire présentes dans un texte HTML TinyMCE
en ancres `.glossaire-lien[data-glossaire-slug]`. **Rien n'est écrit en base** : renommer un
terme du glossaire met à jour tous les renvois du site.

### Règles de détection

| # | Règle | Raison |
|---|---|---|
| 1 | Résolution **au rendu** | Pas de HTML figé à re-migrer quand le glossaire bouge |
| 2 | **Casse exacte** du `reg_nom` | Le SRD 2024 capitalise ses termes de jeu en milieu de phrase (« a le Désavantage », « un Repos court »). Sans cette contrainte, les mots courants du glossaire (Action, Arme, Cible, Créature, Objet, Sort, Mort, Vol…) produisent ~1 000 liens au lieu de ~280 |
| 3 | **Première occurrence** seulement, par terme et par nœud | Au-delà, c'est du bruit. Les ancres déjà présentes dans le HTML comptent comme la première occurrence : aucun doublon derrière un renvoi manuel |
| 4 | **Pluriel simple** : `s` / `x` final admis | « Chutes » → terme « Chute ». Les pluriels internes ne sont pas gérés (« Terrains difficiles ») — cas marginal, assumé |
| 5 | Le trait d'union est une **frontière de mot** | Sinon « Mort » se lie dans « Mort-vivant » |
| 6 | Un terme ne se lie **jamais à lui-même** sur sa propre page | Paramètre `$exclure_id` |

Index chargé sur `reg_type='glossaire'` + `reg_visible=1` + `reg_camp_id IS NULL` (un glossaire de
campagne ne fuit pas dans les règles générales), trié par longueur décroissante — l'alternation PCRE
retient la première branche qui matche, « Jet de sauvegarde contre la mort » doit donc passer avant
« Jet de sauvegarde ». Cache statique par ruleset et par requête.

### Sûreté HTML

Le HTML est découpé en balises / texte ; un compteur de profondeur met hors de portée le contenu
de `<a>`, `<code>`, `<pre>`, `<h1>`–`<h6>`, `<table>`, `<script>`, `<style>`, `<textarea>`, ainsi que
les tags `[[tab:slug]]` non encore résolus.

Les segments de texte analysés sont **décodés puis ré-échappés** par `h()` : `reg_texte` stocke les
accents en entités (`D&eacute;shydratation`), sur lesquelles aucun motif ne matcherait. Page en UTF-8
et base en `utf8mb4` : les accents ressortent en clair, HTML équivalent.

### Ordre d'appel — impératif

```php
resoudreTagsTableaux($db, lierGlossaireAuto($db, $texte, $ruleset_id, $id), $ruleset_id, $peut_editer)
```

**Glossaire d'abord, tableaux ensuite.** Le HTML des tableaux est ainsi injecté après coup et ne
traverse jamais le parser glossaire : c'est ce qui met « l'intérieur des tableaux rendus » hors de
portée, sans code dédié.

### Points de branchement

| Fichier | Nœud exclu | Phase |
|---|---|---|
| `regles/regle.php` | le nœud affiché | SP-GL1 |
| `include/ajax/detail-pp/regle.php` | le nœud affiché | SP-GL1 |
| `include/ajax/detail-pp-sub/glossaire.php` | le terme affiché | SP-GL1 |
| Les 9 champs description du compendium, via `rendreTexteEnrichi()` | aucun | **SP-GL3** |

> **SP-GL3** ne branche pas les endpoints un par un : les 12 points de rendu du compendium
> passent tous par `rendreTexteEnrichi()` (`include/tableau-parser.php`), qui enchaîne
> `lierGlossaireAuto()` puis `resoudreTagsTableaux()` dans l'ordre imposé. Une seule fonction
> à faire évoluer pour toute portée future.
>
> `$exclure_id` vaut 0 sur ces champs : une description de sort n'est pas un nœud de glossaire,
> il n'y a pas d'auto-référence à empêcher.

> ⚠ **`mo_stats` est délibérément exclu.** `monstre-parser.php` a sa propre liaison glossaire
> (`lierAuto()` + tag `%id%`) ; y ajouter SP-GL produirait des liens en double. C'est la raison
> pour laquelle `rendreTexteEnrichi()` ne doit jamais être appelé sur un bloc de stats.

### Handler de clic et style — portée globale

`.glossaire-lien` est écouté dans **`js/main.js`** (et non `regles.js`) et stylé dans
**`css/modules.css`** (et non `regles-modules.css`) : ces ancres apparaissent aussi dans `#detail-pp`
(fiche règle ouverte depuis une campagne) et dans le sous-panneau glossaire, contextes où les
fichiers du module Règles ne sont pas chargés. La base d'URL est résolue comme pour `.mo-lien` :
conteneur `[data-detail-base]` s'il existe, sinon le `BASE_URL` global posé par `footer.php`.

### Volumétrie constatée (DD2024, 2026-07-27)

155 termes, 186 nœuds avec texte → **107 renvois** produits, 0 altération du texte, 0 `<a>` imbriqué.
Coût mesuré sur le nœud le plus lourd (Combat, 18 ko) : **0,6 ms**.

---

## 9c. Tableaux de règles — SP-TB

Projet **SP-TB**. Les tableaux de données ne sont plus saisis en HTML dans `reg_texte` : ils
vivent dans une table dédiée `dd_tableaux`, sont saisis selon une **convention texte** (aucun
HTML), et sont insérés dans le corps d'une règle par un **tag**. Le HTML est produit au rendu,
le design reste intégralement géré en CSS.

Objectif structurant : un tableau devient une **donnée adressable**, réutilisable ailleurs —
notamment par le futur écran du MJ (SP-TB8), qui regroupera les tableaux marqués `tab_ecran_mj`.

### Schéma de la table dd_tableaux

| Champ | Type | Null | Commentaire |
|---|---|---|---|
| tab_id | int unsigned | PK | |
| tab_slug | varchar(120) | nn, UK(tab_slug, tab_ruleset_var_id) | **Clé du tag** `[[tab:slug]]` |
| tab_nom | varchar(200) | nn | Titre affiché au-dessus du tableau |
| tab_contenu | text | nn | Convention texte (voir ci-dessous) |
| tab_align | varchar(40) | null | Une lettre par colonne : `l` / `c` / `r` (ex. `lrr`) |
| tab_note | varchar(500) | null | Note de bas de tableau |
| tab_ruleset_var_id | int unsigned | nn | -> `dd_variables` |
| tab_res_id | int unsigned | null | -> `dd_ressources` (attribution) |
| tab_camp_id | int unsigned | null | **RÉSERVÉ** house rules, comme `reg_camp_id` |
| tab_ecran_mj | tinyint(1) | nn, défaut 0 | 1 = retenu pour l'écran du MJ (SP-TB8) |
| tab_ecran_ordre | smallint unsigned | nn, défaut 0 | Ordre sur l'écran du MJ |
| tab_visible | tinyint(1) | nn, défaut 1 | 0 = brouillon/masqué |
| tab_date_creation / tab_date_modif | datetime | nn | |

**Scoping ruleset uniquement**, droits d'édition `canEditCompendium()` — strictement calqué sur
`dd_regles`.

### Le gestionnaire — `tableaux/index.php` (SP-TB10)

À l'usage, un tableau ne s'est pas révélé être une donnée du module Règles : il est réutilisé
par le compendium et le sera par les campagnes puis l'univers. Le gestionnaire a donc quitté
`regles/` pour un module propre.

| Avant (SP-TB3) | Après (SP-TB10) |
|---|---|
| `regles/tableaux.php` | `tableaux/index.php` — l'ancienne adresse redirige en 301 (`ecran=1` → `f_ecran=1`) |
| `regles/tableaux-enregistrement.php` | `tableaux/enregistrement.php` |
| Table maison, sans filtre ni pagination | Moteur partagé `include/compendium-liste.php` |
| Atteignable depuis Règles et le compendium | + Campagnes (les trois barres d'outils) |

**Le moteur `compendium-liste.php` s'applique donc bien** — la note contraire de SP-TB3 vient de
ce que `tab_res_id` était alors laissé à NULL sur la plupart des tableaux, ce qui les aurait fait
disparaître derrière le filtre des sources actives. Les sources ont été renseignées, le mécanisme
standard du compendium s'applique tel quel (`champ_res` = `t.tab_res_id`).

Filtres offerts : **texte libre** (nom *et* slug — c'est le slug qu'on a sous les yeux quand un
tag ne résout pas), **sources** (menu à cases du moteur), **écran du MJ** (case à cocher, alimente
`extra_where`). Colonnes triables : nom, tag, écran, source, statut.

Trois capacités génériques ont été ajoutées au moteur pour ce faire — utilisables par toute autre
liste :

| Clé | Rôle |
|---|---|
| `champs_recherche` | colonnes SQL balayées par le filtre texte, en OU (défaut : la première colonne) |
| `colonnes[].valeurs` | colonne **calculée en PHP** (`[id => valeur]`) au lieu de `sql` : ni SELECT ni tri. Le tableau doit couvrir toute l'entité, pas seulement la page |
| `td.comp-col--<champ>` | chaque cellule porte le nom de sa colonne, comme `.comp-subrow__part--*` : une page peut cibler une colonne sans compter les index |

La colonne **Usages** passe par `colonnes[].valeurs` : le comptage ne s'exprime pas en SQL, les
onze champs hôtes n'ayant pas tous le même jeu de caractères (`utf8` / `utf8mb4`), ce qui fait
échouer un `UNION` sur « Illegal mix of collations ». Il est fait en PHP par
`compterUsagesTableaux()` (~40 ms, cf. ci-dessous). La cellule « Tag à insérer » retrouve son
`<code>` cliquable (copie) par un handler posé en capture sur `.comp-col--tab_tag`, qui
court-circuite le clic de ligne du moteur.

### Convention de saisie (`tab_contenu`)

Une ligne = une ligne de tableau, `|` sépare les cellules.

| Préfixe | Rôle |
|---|---|
| `!` | Ligne d'en-tête (`<th>`). Plusieurs `!` consécutifs = **en-tête à plusieurs niveaux** |
| `#` | Ligne de **section**, fusionnée sur toute la largeur |
| `>` | Note de bas de tableau |
| *(aucun)* | Ligne de données (`<td>`) |
| *(ligne vide)* | Ignorée |

**Fusions — uniquement dans les lignes `!`** :

| Cellule | Effet |
|---|---|
| *vide* | Fusion horizontale avec la cellule de gauche (`colspan`) |
| `^` | Fusion verticale avec la cellule du dessus (`rowspan`) |

Les lignes de données ne connaissent **aucune** fusion : une cellule vide reste une cellule
vide — indispensable aux grilles irrégulières (colonnes de longueurs inégales).

Exemple d'en-tête sur deux niveaux :

```
! | Rythme | | | Effet
! Distance parcourue par… | Rapide | Normal | Lent | ^
Minute | 120 m | 90 m | 60 m | —
```

Le **nombre de colonnes** est déduit de la ligne la plus large ; les lignes plus courtes sont
complétées par des cellules vides. L'**alignement** vit hors du contenu, dans `tab_align` :
le contenu reste de la donnée pure.

### Tag d'insertion

`[[tab:slug]]`, seul sur sa ligne (ou seul dans son `<p>` côté TinyMCE).

Référence **par slug et non par id** — contrairement aux tags `@id@` / `%id%` de `mo_stats`,
fragiles entre local et OVH. Le renommage d'un slug répercute automatiquement le tag dans
`reg_texte` et `mo_stats` (`_tabPropagerSlug()`), sinon toutes les insertions existantes
deviendraient silencieusement irrésolubles.

> **Pourquoi `[[…]]` et pas un délimiteur mono-caractère** comme la famille `#`/`$`/`&`/`@`/`%` :
> `reg_texte` est du HTML TinyMCE, pas du texte brut. `&` collisionne avec les entités, et un
> caractère isolé ne survit pas de façon fiable au nettoyage de collage. `[[…]]` traverse
> TinyMCE intact et reste lisible en saisie.

**Passe 1 / passe 2** — `resoudreTagsTableaux()` remplace d'abord le `<p>` **entier** quand le
tag en est le seul contenu, puis les tags nus résiduels. Sans la passe 1, un `<table>` se
retrouverait à l'intérieur d'un `<p>` : HTML invalide, le navigateur ferme le `<p>` et la mise
en page casse.

Slug inconnu ou tableau en brouillon → le tag s'affiche tel quel, échappé, en
`.reg-tab__manquant` (même politique de dégradation que `resoudreTagsExplicites()`).

### Liaison des cellules

Le contenu des cellules passe par `resoudreTagsExplicites()` — tags `#don#`, `$sort$`,
`&objet&`, `@id@` (règle), `%id%` (glossaire). **Aucune liaison automatique** (`lierAuto()`) :
trop coûteuse et trop bruyante dans une grille dense.

L'échappement est délégué à `lierAvecSegmentsProteges($txt, 0, …)` : les `<span class="mo-lien">`
produits transitent tels quels, tout le reste est `h()`-échappé, et `maxWords = 0` court-circuite
le tokenizer. L'index (`chargerIndexMonstre()`) n'est chargé que si le contenu porte au moins un
caractère de tag.

Le conteneur `<figure class="reg-tab">` porte `data-detail-base` — sans cet attribut, le handler
`.mo-lien` de `js/main.js` ne peut pas dériver l'URL des endpoints et les liens seraient inertes.

### Portée du tag

| Champ hôte | Rendu par | Phase |
|---|---|---|
| `reg_texte` | `regles/regle.php`, `detail-pp/regle.php` | SP-TB2 |
| `reg_texte` (définition de glossaire) | `detail-pp-sub/glossaire.php` | SP-TB7 — lacune SP-TB2 |
| `mo_stats` | `rendreStatsMonstre()` | SP-TB6 |
| `so_description` | `detail-pp/sort.php` | SP-TB7 |
| `cla_description` | `detail-pp/classe.php` | SP-TB7 |
| `ra_description` | `detail-pp/race.php` | SP-TB7 |
| `do_texte` | `detail-pp/don.php` | SP-TB7 |
| `comp_description` | `detail-pp/competence.php` | SP-TB7 |
| `om_description` | `detail-pp/objet.php` | SP-TB7 |
| `hi_description` | `detail-pp/historique.php` | SP-TB7 |
| `eqt_description` | `detail-pp/equipement.php` | SP-TB7 |
| `cap_description` | `detail-pp/capacite.php`, `classe.php`, `race.php` | SP-TB7 |

> **`tableauChampsHotes()` est la source de vérité de cette liste** (SP-TB10, dans
> `include/tableau-parser.php`). Trois mécanismes en dépendent et doivent partager la même
> liste : le **comptage des usages**, la **propagation d'un renommage de slug** et le
> **garde-fou de suppression**. Toute extension de la portée du tag se déclare là, et nulle
> part ailleurs.
>
> 🐛 **Défaut corrigé en SP-TB10.** `_tabPropagerSlug()` ne couvrait que `reg_texte` et
> `mo_stats` : la fonction n'avait pas suivi SP-TB7. Un tableau inséré dans une description du
> compendium — il y en avait déjà un — perdait son insertion en silence au premier renommage de
> slug, le tag s'affichant dès lors en `.reg-tab__manquant`. Les deux tables sans colonne
> ruleset (`dd_capacites_speciales`) sont propagées sans ce filtre : sans risque, l'unicité des
> slugs étant par ruleset et DD3.5 n'ayant encore aucun tableau (SP-TB9).

**Hors périmètre, volontairement** :
- `cla_conditions`, `cla_armes`, `cla_armures`, `cla_sorts` — champs courts et structurés,
  un tableau n'y a pas de sens.
- `do_conditions` (`detail-pp/don.php`) et tout champ rendu via `h()` — le tag y resterait
  littéral. **Ne jamais retirer un `h()` pour y faire passer un tag** : ce serait ouvrir une
  injection HTML sur un champ qui n'a jamais été conçu pour en contenir.
- `do_resume` — non affiché sur la fiche détail.
- Module **Campagnes** (`camp_description`, `sce_description`, `scc_description`,
  `re_description`, `re_composition`) et `res_description` — hors compendium. Techniquement
  éligibles (rendus non échappés), à arbitrer si le besoin apparaît.

`_extraitTexte()` (`regles/recherche.php`) produit un extrait en texte brut : un tag y
apparaîtrait littéralement dans les résultats de recherche. Cas marginal, non traité.

> **`mo_stats` — pourquoi une sentinelle.** `mo_stats` est du texte brut formaté ligne à ligne.
> Résoudre le tag après coup exposerait le slug à `lierAuto()`, qui tokenise les mots ≥ 4 lettres
> et injecterait un `<span>` au milieu du tag. `rendreStatsMonstre()` sort donc les lignes-tag du
> flux avant formatage, les remplace par `___TAB<n>___` (aucun mot de longueur suffisante pour
> être tokenisé), puis substitue le HTML final.

### Fichiers du module

```
tableaux/
  index.php                    liste + gestion (moteur compendium-liste.php)
  enregistrement.php           écriture (sauvegarder / supprimer)

regles/
  tableaux.php                 redirection 301 vers tableaux/index.php

include/
  tableau-parser.php           moteur : parsing, rendu, résolution du tag, slug,
                               champs hôtes et comptage des usages
  ajax/
    tableau-apercu.php               aperçu POST sans écriture
    detail-pp/tableau.php            fiche détail
    detail-pp-sub/tableaux-picker.php  sélecteur depuis l'éditeur de règle
    modifier/tableau.php             formulaire

sql/
  2026-08-10_tableaux_sp-tb0.sql   schéma
  migrate_tableaux_sp-tb5.php      migration des tableaux HTML existants
```

**CSS — répartition volontaire (SP-TB7, complétée en SP-TB10)** :

| Fichier | Contenu | Portée |
|---|---|---|
| `css/modules.css` | Composant de rendu `.reg-tab`, `.reg-tab__*` — **et depuis SP-TB10** l'outillage du gestionnaire (`.reg-tab-liste__tag*`, `.reg-tab-saisie`, `.reg-tab-apercu`, `.tableaux-picker*`, `.tableau-detail*`), les fiches détail `.regle-detail__*` et le badge `.regles-badge--ecran` | **Toutes les pages** (`header.php`, sans condition) |
| `css/regles-modules.css` | Ne conserve que ce qui est propre aux pages Règles (arbre, sommaire, recherche, surlignage) | `$css_module = 'regles'` |

> 🐛 **Second défaut du même type, corrigé en SP-TB10.** SP-TB7 avait déplacé le *composant de
> rendu* mais laissé dans `regles-modules.css` tout l'outillage : le picker s'ouvre pourtant
> depuis les dix éditeurs TinyMCE du site, et la fiche détail d'une règle comme d'un tableau
> depuis n'importe quelle page (un tag `@id@` ou `[[tab:slug]]` est résolu jusque dans les stats
> de monstre). Hors module Règles, tous s'affichaient sans style. Même cause, même remède : ce
> qui est injecté en AJAX sur une page quelconque vit dans `modules.css`. La fonction JS de copie
> du tag a suivi le même chemin (`js/regles.js` → `js/main.js`, sous le nom
> `copierTagTableau()`), pour la même raison.

> Le composant a quitté `regles-modules.css` le 2026-08-10. Un tableau n'est plus un élément du
> module Règles : il s'affiche sur les fiches du compendium (`$css_module = 'compendium'`) et
> dans les blocs de stats de monstre, y compris sur les fiches d'opposition
> (`$css_module = 'campagnes'`). Y laisser le CSS revenait à le rendre **sans aucun style** hors
> des pages Règles. Même raisonnement — et même précédent — que le CSS du glossaire, déjà
> déplacé vers `modules.css` pour cette raison.

> 🐛 **Défaut corrigé par ce déplacement.** SP-TB6 (tag dans `mo_stats`) était annoncé livré mais
> ne l'était qu'à moitié : le tag était bien résolu, le tableau sortait sans style sur
> `compendium/monstres.php` et sur les fiches d'opposition. La portée CSS avait été vérifiée pour
> les règles, pas pour les monstres.

**Indépendance au contexte** — `.reg-tab` fixe `line-height`, `color` et `text-align`, et
`.reg-tab__table` une `font-size` absolue. Sans cela le tableau héritait de son hôte
(`.regles-noeud__texte` impose `line-height: 1.7`) et changeait d'aspect d'un écran à l'autre.
Toute propriété typographique ajoutée au composant doit rester **auto-portante**.

**JS** :

| Fonction | Fichier | Rôle |
|---|---|---|
| `tableauxInitBouton(editor)` | `js/main.js` | Enregistre le bouton `tableau` dans un éditeur TinyMCE |
| `insererTableauDansEditeur(slug)` | `js/main.js` | Callback du picker — insère `<p>[[tab:slug]]</p>` |
| `TAB_EDITEUR_ACTIF` | `js/main.js` | Id de l'éditeur ayant ouvert le picker |
| `reglesCopierTag()` · `tableauConfirmerSuppression()` | `js/regles.js` | Outillage du gestionnaire |

### Aide à la saisie — bulles contextuelles

Chaque champ soumis à un parser porte une icône `?` (`aideIcone()`), dont le contenu vit dans
`include/aide-contextuelle.php`. **Une clé par jeu de parsers réellement appliqué** — annoncer
un tag là où il n'est pas résolu se paie en saisies inutilisables :

| Clé | Champs | Contenu |
|---|---|---|
| `texte-parsers` | `reg_texte` + les 9 descriptions du compendium | `[[tab:slug]]`, renvois de glossaire automatiques, et la mise en garde que `#don#`/`$sort$`/`&objet&` n'y fonctionnent **pas** |
| `tableau-convention` | `tab_contenu` | Convention complète (`!`, `#`, `>`, `\|`), fusions `^` et cellule vide, exemple, tags de cellule |
| `monstre-tags-description` | `mo_stats` | Tags explicites, liaison automatique, `[[tab:slug]]` sur ligne seule |

La bulle `texte-parsers` est **dynamique** : elle compte les termes de glossaire du ruleset actif
et bascule sur « aucun terme saisi pour ce ruleset » quand il n'y en a pas — sur DD3.5, l'auteur
sait immédiatement qu'aucun renvoi ne sera produit, plutôt que d'attendre un effet qui ne
viendra jamais.

Le `<details>` d'aide qui vivait dans `modifier/tableau.php` a été retiré au profit de ce
mécanisme : un seul système d'aide dans l'application, contenu centralisé.

CSS : `#aide-bulle` s'élargit à 460px et devient défilant **selon son contenu**
(`:has(.aide-table)`, `:has(.aide-exemple)`) — aucune variante à passer depuis le PHP ni classe
à poser en JS.

### Points d'accès au gestionnaire

| Depuis | Élément | Comportement |
|---|---|---|
| `regles/index.php` | Bouton « Tableaux » de la barre d'outils | Même onglet |
| Les 9 listes du compendium | Bouton « Tableaux » de la barre de filtre | **Nouvel onglet** |
| Éditeur TinyMCE (10 champs) | Bouton `tableau` → picker | Sous-panneau |
| Picker | Lien « Gérer » | Nouvel onglet |

> Le bouton du compendium est déclaré **une seule fois**, dans la barre d'actions de
> `include/compendium-liste.php` : le moteur sert les 9 entités (classes, compétences, dons,
> équipements, historiques, monstres, objets, races, sorts), une déclaration par page aurait été
> recopiée neuf fois. Gaté sur `canEditCompendium()`, comme le bouton « Ajouter » voisin.
> Ouverture en nouvel onglet pour préserver l'état de la liste (filtres, tri, pagination).

### Bouton d'insertion — 10 éditeurs équipés

```js
toolbar: '… | tableau | …',
setup: function (editor) { tableauxInitBouton(editor); }
```

| Formulaire | Éditeur(s) |
|---|---|
| `modifier/regle.php` | `reg_texte` (SP-TB4) |
| `modifier/sort.php` · `don.php` · `competence.php` · `objet.php` · `historique.php` · `equipement.php` | champ description (SP-TB7) |
| `modifier/classe.php` | `.tinymce-basic` + `#ov_cap_description` (overlay capacité) |
| `modifier/race.php` | `#ra_description` + `#ov_cap_description` (overlay capacité) |

> L'implémentation vit dans `js/main.js` et non dans les formulaires : elle aurait sinon été
> recopiée dix fois. `TAB_EDITEUR_ACTIF` mémorise l'éditeur **au clic** — au moment de
> l'insertion, le focus est passé au sous-panneau et `tinymce.activeEditor` n'est plus fiable.
> Les deux `setup:` préexistants (overlays capacité de `classe.php` et `race.php`) ont été
> **étendus** et non remplacés : une seconde clé `setup:` dans le même objet aurait écrasé
> silencieusement la restauration de contenu qu'ils portent.

> ⚠ Le bouton **`table` natif de TinyMCE reste présent** dans ces barres : il insère un
> `<table>` HTML directement dans le champ, c'est-à-dire exactement ce dont SP-TB affranchit
> le contenu. Le retirer est une décision produit, non prise à ce jour.

### Points d'attention

- **Le picker ne crée pas de tableau.** Il s'affiche dans `#detail-pp-sub` (z-index 300)
  au-dessus de `#modification` (250) qui porte la règle en cours d'édition. Ouvrir un
  formulaire de création occuperait `#modification` et **écraserait la règle en saisie** —
  le picker propose donc un lien « Gérer » vers `tableaux/index.php` en nouvel onglet.
- **Le débordement horizontal est porté par `.reg-tab__scroll`, jamais par `<table>`.**
  Un `table { display:block }` (comme dans l'ancien style `.regles-noeud__texte table`)
  casse `colspan`/`rowspan`.
- **`_tabSlugify()` ne dépend pas de l'extension intl.** Garde `function_exists()` + repli
  `strtr()`. L'extension est désormais active en local (ICU 71.1) et sur OVH (ICU 63.1) — le
  repli n'est donc jamais pris, mais il est conservé comme filet en cas de changement
  d'hébergement. Équivalence des deux chemins vérifiée (0 divergence sur les 13 tableaux
  migrés). `_slugify()` (`include/regles-arbre.php`) appelle `transliterator_transliterate()`
  sans garde : correct tant qu'intl reste activée dans les deux environnements.

### Migration SP-TB5

`sql/migrate_tableaux_sp-tb5.php` — script one-shot, **simulation par défaut**, idempotent.

```
navigateur (admin, ruleset = celui de la session) : …/sql/migrate_tableaux_sp-tb5.php[?go=1]
CLI (ruleset explicite, pas de session)          : php sql/migrate_tableaux_sp-tb5.php --ruleset=2 [--go]
```

Extrait le motif `<p class="table-titre">TITRE</p>` + `<table>…</table>`, convertit en
convention, crée le `dd_tableaux` et remplace le bloc par `<p>[[tab:slug]]</p>`. Deux tableaux
de titre **et** contenu identiques ne sont créés qu'une fois et partagent le même tag — c'est
le gain direct du refactor : « Bonus de maîtrise » était dupliqué dans deux règles.

Un tableau portant `colspan`/`rowspan` est **signalé et laissé intact** : les fusions ne sont
pas devinables de façon fiable, l'auteur les reprend à la main.

> �
 **Migration exécutée le 2026-08-10 sur la base locale `maikasteiymaika` (ruleset DD2024).**
> **14 blocs répartis dans 8 règles → 13 tableaux distincts** (`dd_tableaux`), 1 réutilisation
> (« Bonus de maîtrise », présent à l'identique dans `tests-d20` et `maitrise`), **0 ignoré**.
> Vérification post-migration : 0 `<table>` restant dans `reg_texte`, 0 tag non résolu,
> 0 `<figure>` imbriqué dans un `<p>`. Sauvegarde préalable du `reg_texte` des 8 règles dans
> `sql/backup/2026-08-10_reg_texte_avant_sp-tb5.sql` (rejouable tel quel pour restaurer).
>
> Le fichier `sql/import_regles_dd2024.sql` ne décrivait que **10** de ces blocs : 4 tableaux
> (règles `combat`, `allure-voyage`, `sorts-acquisition`, `sorts-ecoles-magie`) avaient été
> ajoutés depuis via l'interface. C'est la raison pour laquelle la migration opère sur la base
> et non sur le fichier d'import.
>
> ⚠ **Un titre à reprendre** : le premier tableau de la règle `combat` (catégories de taille et
> espace occupé) n'était précédé d'aucun `<p class="table-titre">`. Le repli a donc pris le nom
> de la règle : il s'appelle « Combat » / `[[tab:combat]]`. À renommer depuis
> `tableaux/index.php` — le renommage du slug se répercute automatiquement dans les onze champs
> hôtes (SP-TB10).

> ⚠ `sql/import_regles_dd2024.sql` contient encore les tableaux en HTML. Le rejouer **après**
> la migration réintroduirait les blocs `<table>` dans `reg_texte`. Le relancer impose de
> rejouer la migration derrière (elle est idempotente et re-détectera les blocs).

> 🐛 **Classe de titre incohérente (constaté 2026-08-10).** Les données écrivent
> `<p class="table-titre">`, alors que `css/regles-modules.css` définit `.titre-tableau` — c'est
> aussi ce que produit le `style_formats` de TinyMCE. Les titres de tableaux importés n'étaient
> donc pas stylés. Sans objet après SP-TB5 : le titre remonte dans `tab_nom` et la migration
> supprime le paragraphe.

---

## 9e. Listes dynamiques d'équipements et d'objets magiques — SP-PO

Projet **SP-PO**. Moteur : `include/liste-parser.php`, point d'entrée
`resoudreTagsListes(PDO $db, ?string $html, int $ruleset_id)`.

**Principe** — les règles ne portent que les mécanismes de jeu ; les articles (prix, poids,
caractéristiques, description propre) sont des données du compendium. Pour qu'une règle montre une
liste d'articles sans la recopier — et sans qu'elle vieillisse —, le texte pose un tag, résolu au
rendu comme `[[tab:slug]]`. **Rien n'est écrit en base** : ajouter un article au compendium met à
jour toutes les listes du site. Valable pour les deux rulesets ; seules les familles diffèrent.

### Syntaxe

```
[[liste:equipement]]
[[liste:equipement|famille=armes-de-guerre]]
[[liste:equipement|famille=armures-legeres,boucliers|source=DRS 3.5|tri=prix]]
[[liste:objet|famille=baguettes|titre=Baguettes du jeu de base]]
```

| Élément | Règle |
|---|---|
| Entités | `equipement` (`dd_equipements`), `objet` (`dd_objets_magiques`) |
| Séparateurs | `\|` entre paramètres, `,` entre valeurs. Tag **seul dans son paragraphe** |
| `famille` | slug(s) de catégorie. **Équipement : une famille inclut ses descendants** (`armes` = courantes + de guerre + exotiques). Objets : `com_slug`, plat. Absent = toutes (les « propriétés spéciales » DD3.5, `com_est_propriete = 1`, restent exclues, comme dans le compendium) |
| `source` | abréviation ou nom de ressource du ruleset (« DRS 3.5 »). **Absent = sources ACTIVES de l'utilisateur** (`getActiveResIds()`), comme le compendium — une même règle peut donc montrer des lignes différentes à deux utilisateurs. **Présent = ces sources-là, quelles que soient les sources actives**. Source inconnue → « Aucun élément » |
| `tri` | défaut : ordre du livre (`eqt_ordre`) puis nom ; `nom` ; `prix` (sans prix chiffré en dernier) |
| `titre` | légende du tableau (défaut : nom de la famille) ; **`titre=-` = aucune légende** (quand un `<h3>` la précède déjà) |
| Références | **par slug, jamais par id** — les ids diffèrent entre le local et OVH (même raison que `[[tab:slug]]`) |
| Dégradation | entité ou famille inconnue → le tag s'affiche tel quel, encadré en rouge (`.reg-tab__manquant`), crochets en entités pour que la seconde passe ne le re-matche pas |

### Rendu

`<figure class="reg-tab reg-liste" data-detail-base="…">` : le composant `.reg-tab*` des tableaux
est réutilisé tel quel (défilement horizontal porté par `.reg-tab__scroll`). Le nom de chaque ligne est un
`<span class="mo-lien" data-type="equipement|objet" data-id="…">` : le handler de `js/main.js`
(`MO_LIEN_FICHIERS`) ouvre la fiche détail dans `#detail-pp-sub`.

- **Équipement** — colonnes lues dans `cae_colonnes` de la catégorie (héritées du parent si NULL), hors
  colonnes `liste:false`. Lignes groupées par famille : une ligne de section par feuille (« Armes courantes ›
  Armes de corps à corps légères »), chemin relatif à la famille demandée. Un tableau **par jeu de colonnes**
  distinct si la sélection mélange des familles de structure différente (armes + armures).
- **Objets magiques** — DD3.5 : Nom, Prix (`om_prix`, « — » si 0 ou NULL) ; DD2024 : Nom, Rareté,
  Harmonisation. Sections par catégorie si plusieurs.
- Colonne **Source** ajoutée automatiquement quand le résultat mélange plusieurs sources.
- **Plafond : `LISTE_MAX_LIGNES` = 200** lignes, puis « N autre(s) ligne(s) — voir tout dans le compendium »
  (lien vers `compendium/equipements.php` ou `objets.php`).

### Visibilité

Même règle que `compendium-liste.php` (Supplément utilisateur, SP-C2), sans le toggle « brouillons » :
entrée officielle visible (ou tout pour un éditeur) · entrée du supplément du propriétaire courant si
`_visible = 1` · entrée d'un supplément tiers si `_public = 1` **et** `_visible = 1`. **Jamais de homebrew de
campagne** (`_camp_id IS NULL`). Un `getActiveResIds()` vide **omet** le filtre (pas de `IN ()`) — alors que le
moteur de liste du compendium, lui, ne retourne rien : écart assumé, une règle ne doit pas être vide.

### Ordre d'appel — impératif

```php
resoudreTagsListes($db, resoudreTagsTableaux($db, lierGlossaireAuto($db, $texte, $rs, $id), $rs), $rs)
```

Même contrainte que §9d : le glossaire d'abord, les blocs HTML injectés ensuite ne le traversent jamais.
Le parseur de glossaire isole `[[liste:…]]` comme `[[tab:…]]` (`GL_TAB_MOTIF`) : les paramètres contiennent
des mots du glossaire (« famille=armes ») qu'il ne faut pas lier. `rendreTexteEnrichi()` enchaîne les trois ;
`regles/regle.php`, `detail-pp/regle.php` et `detail-pp-sub/glossaire.php` appellent les trois explicitement.
**Non résolu dans `mo_stats`** (bloc de stats des monstres).

### Modèle de données

Voir `SCHEMA_SQL.md` (`dd_categorie_equipement`, `dd_equipements`, `com_slug`).

- **Une définition, trois usages** : `cae_colonnes` (JSON `[{k, l, a?, liste?}]`) fabrique les colonnes de la
  liste, les lignes de la fiche détail **et** les champs d'attribut du formulaire d'édition (générés en JS au
  changement de famille). Une nouvelle famille (ex. DD2024 : « Armes de guerre » avec maîtrise et propriétés)
  n'exige aucun code : une ligne de catégorie et ses colonnes.
- **Prix et poids = nombre + texte** : `eqt_prix_pc` (pièces de cuivre) et `eqt_poids_g` (grammes) servent au
  tri et aux calculs à venir (encombrement, richesse) ; `eqt_prix_txt` / `eqt_poids_txt` portent ce qui n'est
  pas un nombre (« spécial », « +50 po », « Niveau × 5 po ») et **priment à l'affichage**. Saisie du
  formulaire : « 5 po », « 12 pa », « 3 pc », « 2,5 kg », « 500 g » → nombre ; tout autre texte → texte
  (`parserPrixSaisie()`, `parserPoidsSaisie()`). Formats d'affichage : `formaterPrixPc()`, `formaterPoidsG()`
  (espaces insécables).
- **Une description propre par article** : `eqt_description` porte les règles particulières de l'article
  (arbalète, chausse-trappes, filet…). La fiche détail affiche **le bloc de données puis la description**.
  Un texte commun à plusieurs articles (menottes, selles spéciales…) est recopié sur chacun.
- **Supplément** : `eqt_public` + ressource supplément du propriétaire, même mécanisme que les 8 autres
  entités (`enregistrerEquipement()` / `supprimerEquipement()` : garde per-entry `canEditCompendiumEntry()`).

### Fichiers

```
include/liste-parser.php            moteur + familles + formats prix/poids
include/tableau-parser.php          rendreTexteEnrichi() enchaîne les trois parsers
include/glossaire-parser.php        GL_TAB_MOTIF : tags opaques
include/aide-contextuelle.php       aide du tag, avec la liste des slugs de famille du ruleset
compendium/equipements.php          liste : Famille / Prix / Poids, filtre famille (sous-familles incluses)
include/ajax/modifier/equipement.php   formulaire (famille, prix, poids, attributs dynamiques, supplément)
include/ajax/detail-pp/equipement.php  fiche : chemin de famille, bloc de données, description
css/modules.css                     .reg-liste*, .eqt-donnees*
sql/2026-10-11_equipements_00_schema_sp-po0.sql        schéma (non idempotent)
sql/2026-10-11_equipements_dd35_drs07_sp-po2.sql       32 familles + 269 articles
sql/2026-10-11_regles_dd35_drs07_sp-drs2.sql           règles Équipement
sql/2026-10-11_regles_dd35_drs23_sp-drs3.sql           règles Objets magiques
sql/2026-10-16_regles_dd2024_objets_magiques_sp-po5b.sql   règles Objets magiques DD2024 (9 pages, 9 tableaux)
sql/2026-10-16_objets_dd2024_srd_sp-po5b.sql           357 descriptions d'objets DD2024 + 44 tableaux
```

### DD2024 (SP-PO5)

Même mécanisme, familles propres au ruleset (28 lignes de `dd_categorie_equipement`, `cae_ruleset_var_id` = 2, mêmes slugs que le DD3.5 quand le sens est le même : `armes`, `armures`…). Colonnes de liste : armes `Dégâts / Propriétés / Botte d'arme / Poids / Prix` ; armures `CA / Force / Discrétion / Poids / Coût` ; outils `Caractéristique / Poids / Prix` ; véhicules `Vitesse / Équipage / Passagers / Cargaison / CA / PV / Seuil / Prix` ; services d'incantation `Disponibilité / Prix`. Source des articles : « SRD 5.2.1 » (retrouvée par abréviation). Les règles s'insèrent sous les chapitres **existants** « Équipement » (id 15 en local) et « Objets magiques » : le générateur de migrations retrouve ces nœuds **par slug** (`SET @r_equipement := (SELECT reg_id … reg_slug = 'equipement')`) et met à jour la règle `monnaie` sur place. Corrections de texte : `doc/LOG_CORRECTIONS_SRD2024_EQUIPEMENT.md`.

**Légende des listes à plusieurs tableaux** : sans `titre=`, la légende est la plus profonde famille commune aux lignes du tableau (« Munitions », « Armes »…), à défaut la famille demandée ; une ligne de section identique à la légende n'est pas répétée. Les sous-familles qui héritent des mêmes colonnes que leur parent (focaliseurs, symboles) restent dans le tableau du parent, en sections.

### DD2024 — objets magiques (SP-PO5b)

Deux migrations, **par nom et par slug** (jamais par id : ceux de la production ne sont pas ceux du local) :

- `sql/2026-10-16_regles_dd2024_objets_magiques_sp-po5b.sql` — 9 tableaux de règles (`dd_tableaux`, upsert sur `slug + ruleset`) et 9 pages sous le chapitre `objets-magiques` : `categories_objets-magiques` (slug historique, mis à jour sur place), `regles-concernant-les-objets-magiques`, `rarete-et-valeur-des-objets-magiques`, `activation-d-un-objet-magique`, `objets-maudits`, `resilience-des-objets-magiques`, `fabrication-d-objets-magiques`, `objets-magiques-intelligents`, `objets-magiques-de-a-a-z`. La dixième page du chapitre, `utiliser-les-objets-magiques` (SP-PO5, section Équipement du SRD), n'est pas touchée. La page de A à Z ne contient aucun objet saisi : un tag `[[liste:objet|famille=…|source=SRD 5.2.1|titre=-]]` par catégorie.
- `sql/2026-10-16_objets_dd2024_srd_sp-po5b.sql` — 44 tableaux, `om_description` des 357 objets de la source SRD (table temporaire `nom → texte`, `UPDATE … JOIN` filtré sur ruleset et ressource), ajout gardé de « Yeux de lynx ». Catégorie, rareté et harmonisation ont été comparées à la ligne de type du SRD pour les 236 entrées de base déjà présentes : aucun écart, elles ne sont pas réécrites.

**Convention des déclinaisons** (120 lignes tirées d'une entrée générique du SRD : anneau de résistance, parchemin de sort, pierre de Ioun, figurine merveilleuse…) : le texte commun de l'entrée générique, **la table qui s'y rattache** (`[[tab:slug]]`, la même pour toutes les déclinaisons) et le seul paragraphe de la déclinaison choisie. Les paragraphes propres aux autres déclinaisons sont écartés. Les tableaux des sacs à malices sont, eux, un par couleur.

**Profils inclus au texte** (mouche géante des figurines merveilleuses, avatar de la Mort du tarot mystérieux) : paragraphes `<p>` à libellés en gras et un tableau de caractéristiques (`mouche-geante-caracteristiques`, `avatar-de-la-mort-caracteristiques`). Pas de tag de monstre : ce ne sont pas des entrées du bestiaire.

**Pièges d'extraction** (SRD en PDF, mise en page sur deux colonnes) :

- `pdftotext` sans option rend les paragraphes entiers **mais fusionne un paragraphe à titre en gras avec le précédent** (« …dépensées, à l'aube. Sorts. Lorsque… », « …7 jours. Mouche d'ébène (rare). Cette statuette… »), éparpille les tableaux en fragments (`Sort` / `Coût en charges` / `5` / `4`…) et recolle les mots coupés par un trait d'union dur (« Reportezvous », « ellemême », « luimême », « Mortvivant »). `-layout` détache les nombres de leurs lignes. **`-raw` restitue chaque tableau ligne à ligne, dans le bon ordre** : c'est la source des tableaux.
- Les titres de capacité sont retrouvés par **liste fermée** (120 titres) et par la forme « Nom (rareté) » ; une phrase courte suivie d'une majuscule n'est pas un titre (« Cette baguette dispose de 7 charges. »).
- Une coquille du SRD est corrigée : « pas le biais du chapeau » → « par le biais » (chapeau mille-sorts). Les autres écarts sont des artefacts d'extraction (journal : `doc/LOG_CORRECTIONS_SRD2024_OBJETS_MAGIQUES.md`).
- Une migration régénérée après avoir été jouée en local change de somme de contrôle : pour la rejouer sans la déclarer « retouchée », rejouer ses instructions puis aligner `dd_migrations.mig_checksum`.

### Pièges relevés

- **Ordre des migrations = ordre alphabétique du nom.** Le schéma s'appelle `…_equipements_00_schema_…`
  pour passer **avant** `…_equipements_dd35_…` : sans le `00`, `dd35` < `sp-po0` aurait joué l'import avant
  la structure.
- **Réinitialisation d'un sous-arbre de règles : supprimer feuille par feuille.** Un `DELETE … IN (parent,
  enfants)` échoue sur `fk_reg_parent` (clé étrangère sans cascade, vérifiée ligne à ligne). Les migrations
  générées suppriment un nœud par instruction, des feuilles vers la racine. Les deux migrations de règles
  ont été rejouées deux fois de suite par `migrationsAppliquer()` pour le prouver.
- **Un test d'écriture par le vrai gestionnaire crée le supplément de l'utilisateur** si absent
  (`getOrCreateUserSupplement()` + copie de sa sélection de sources). Relevé le 2026-10-11 : ressource et
  ligne `dd_joueurs_sources` supprimées juste après le test.
- Le moteur de liste du compendium attend une clé `tri` sur **toute** colonne, y compris calculée en PHP
  (`'valeurs'`) : `'tri' => false`, sans quoi PHP émet deux avertissements par colonne.
- `pdftotext -layout` **mélange les colonnes** des grandes tables du DRS (prix détachés des noms) ; le mode
  `-raw` les restitue ligne à ligne. Les 269 articles ont été saisis depuis le mode brut ; un recoupement
  visuel reste recommandé (`LOG_CORRECTIONS_DRS07_DRS23.md` §4).

---

## 10. Responsive

| Module | Responsive | Notes |
|---|---|---|
| Compendium | Oui | col-primary/secondary/action, pas de boutons action mobile |
| Personnages | Oui | **Priorité tablette/smartphone** — fiche unique, sections repliables, cibles tactiles larges, Mode jeu en haut |
| Wiki / Univers | Oui | |
| Campagnes | Non | Desktop MJ uniquement |
| Profil | Oui | |
| Connexion / Auth | Oui | |
| Admin | Oui | Même classes CSS que le compendium |

Seuil : 992px.

Paliers effectivement déclarés dans les CSS : **991px** (seuil principal), **768px** et **479px**.
Aucun autre palier ne doit être introduit sans arbitrage.

### 10b. Menu principal déroulant — SP-RS1

Sous 992px, la nav du header devient un menu déroulant :

- `include/header.php` ajoute un bouton `#site-nav-toggle` (`.site-header__burger`) **avant** la
  nav, et la nav reçoit la classe `.site-header__nav--collapsible` + l'id `#site-nav`.
- Le bouton et le panneau ne sont rendus que pour un utilisateur **connecté** (`$nav_collapsible`) :
  hors session la nav ne contient qu'un lien « Connexion » et reste affichée telle quelle.
- CSS (`css/main.css`, media query 991px) : bouton et panneau en `flex: 0 0 100%` — ils occupent
  toute la largeur d'affichage, l'un sous l'autre, dans le flux du header (le header sticky
  grandit à l'ouverture, il ne recouvre pas la page). Liens en colonne, cible tactile 44px,
  panneau limité à `calc(100vh - 160px)` avec scroll interne.
- `.site-header__nav-label` : libellé texte des liens icône (Déconnexion), masqué en desktop,
  affiché dans le panneau.
- JS (`js/main.js`) : `toggleMenuPrincipal(forceOuvrir)` / `fermerMenuPrincipal()`, état porté par
  `.is-open` + `aria-expanded`. Fermeture au clic hors `.site-header`, à `Échap`, et au
  franchissement du seuil `NAV_BREAKPOINT` (991) au resize.

### 10c. Mode debug — badge de dimensions — SP-RS0

Outil de mise au point du responsive, **réservé aux administrateurs**.

- Bascule : `admin/index.php`, section « Outils de développement » (`section=debug`, POST + CSRF).
- Stockage : `$_SESSION['debug_ui']` uniquement — aucune colonne en base, remis à zéro à la
  déconnexion.
- Rendu : `include/header.php` émet `#debug-viewport` si `$_SESSION['debug_ui']` **et**
  `$_SESSION['j_admin']`. Les paliers surveillés sont passés en `data-breakpoints="991,768,479"`.
- Affichage : `largeur × hauteur` du viewport, `dpr`, puis chaque palier — souligné et en gras
  quand il est actif. Recalcul sur `resize` et `orientationchange`.
- Position : `.debug-viewport` en `position: fixed`, `z-index: 9000` (au-dessus des panneaux, max
  applicatif 300). Un clic fait tourner le badge entre les quatre coins, mémorisé en
  `localStorage.debugViewportCoin`.

### 10d. Bandeau de contexte en fil d'Ariane — SP-RS2

Mesures avant refonte, à 375×812 avec la cascade complète : bandeau de **150px** (4 boutons
empilés, un par ligne, 27px de haut), soit 259px consommés avant le premier contenu (32% de
l'écran). Après : **57px, quelle que soit la profondeur**.

- `include/header-context.php` produit un **rendu unique** pour toutes les largeurs : icône de
  type, libellé (`.site-header__context-type`), nom (`.site-header__context-nom`), et un
  séparateur `.site-header__context-sep` entre deux niveaux. Le niveau le plus profond porte
  `.site-header__context-btn--courant`.
- Icônes par type : `fa-dungeon` (campagne), `fa-scroll` (scénario), `fa-bookmark` (chapitre),
  `fa-dice-d20` (rencontre), `fa-user` (personnage — repli hors campagne).
- **≥992px** : rendu identique à avant SP-RS2, aux icônes près. Libellés affichés, séparateurs
  masqués, pas d'accent sur le niveau courant.
- **≤991px** : `flex-wrap: nowrap` + `overflow-x: auto`, libellés masqués, séparateurs visibles,
  cibles tactiles 40px, ancêtres tronqués en ellipsis à `max-width: 45vw`, niveau courant jamais
  tronqué et souligné par `--clr-accent-2`.
- `flex: 0 0 auto` sur les boutons est **structurant** : avec `flex-shrink: 1` (défaut) les
  boutons se compriment pour tenir dans la ligne et la barre ne déborde jamais — le fil d'Ariane
  ne défile pas et tous les noms sont tronqués.
- Dégradé de bord droit : pseudo-élément sur `#site-header-context-zone` (conteneur non
  scrollable) et non sur la barre, sinon il défilerait avec le contenu. Sur un fil court il se
  superpose au fond de la barre, donc invisible — pas de garde JS nécessaire.
- `contexteHeaderCadrer()` (`js/main.js`) amène le niveau courant à l'écran : appelée au
  `DOMContentLoaded` et à la fin de `actualiserContexteHeader()`, après injection du fragment AJAX.
- **Piège de spécificité** : Font Awesome est chargé après `main.css`, son `.fa { display }`
  l'emporte à spécificité égale. Toute règle `display` visant une icône FA doit être écrite à
  deux classes (`.site-header__context .site-header__context-sep`).

### 10e. Listes du compendium sur smartphone — SP-RS3

Le moteur `compendium-liste.php` avait déjà son dispositif mobile (toggle de filtres,
`col-primary` / `col-secondary`, sous-ligne `.comp-subrow`, barre bulk masquée). SP-RS3 corrige
ce qui ne fonctionnait pas, mesuré à 375×812 :

- **Menu ⋮ restauré.** `.col-action { display: none }` rendait les listes **en lecture seule sur
  téléphone** : ni Modifier, ni Dupliquer, ni Supprimer, ni les `row_actions` déclarées par les
  pages. La colonne est désormais affichée à 44px, bouton 40×40. Elle reste à gauche du nom,
  comme en desktop — l'ordre des colonnes est celui du moteur, identique pour les 9 entités.
- **Recadrage du menu déroulant dans le viewport** (`compToggleMenu()`, `js/compendium.js`) : le
  menu est `position: fixed` positionné depuis le bouton. Sur écran étroit il débordait à droite,
  et s'ouvrait hors écran pour les dernières lignes. Il est maintenant contraint avec 8px de
  marge et bascule au-dessus du bouton quand il n'y a pas la place dessous. Le menu est rendu
  visible **avant** la mesure — `offsetWidth`/`offsetHeight` valent 0 sous `.noDisplay`.
- **Menu Sources empilé.** En mobile le menu passe en `position: static`, mais
  `.comp-filtre-item` est un conteneur flex en ligne : le menu devenait un frère de ligne et se
  partageait la largeur avec son bouton (141px + 200px mesurés). Le conteneur passe en
  `flex-direction: column`.
- **Cibles tactiles** portées à 40px : selects de filtre (31px), bouton Sources (32px), items de
  source, labels de checkbox, boutons d'action de la barre de filtre (**20px de haut**, icône
  seule, libellé masqué en mobile), boutons de pagination (32px). La pagination peut passer sur
  deux lignes en fenêtre large — `.comp-pagination` est déjà en `flex-wrap`.

> Limite connue, non traitée : sous 992px les en-têtes des colonnes secondaires sont masqués, donc
> **seul le tri sur la colonne primaire reste accessible**. Les valeurs restent lisibles dans
> `.comp-subrow`. À reprendre si le besoin se confirme (un select « Trier par » dans le panneau de
> filtres serait le vecteur naturel).


### 10f. Barre de filtrage — composant partagé — SP-RS3b

La barre de filtrage n'est plus propre au compendium : elle vit dans `css/modules.css` (chargé sur
toutes les pages) et `js/main.js`, et sert au compendium comme au module Personnages.

- **Classes `comp-filtre-*` conservées** malgré le déplacement : les renommer imposerait de
  reprendre `compendium-liste.php`, `admin-liste.php`, `ajax/modifier/objet.php` et
  `compendium.js` sans rien apporter. Le préfixe est historique, pas un périmètre.
- **Markup de référence** (identique dans les deux modules) :
  `.comp-filtre-bar` > bouton `#filtre-toggle-btn.comp-filtre-toggle` + `#comp-filtre-content` >
  `form.comp-filtre-form` > `.comp-filtre-item` (variantes `--text`, `--sources`, `--actions`).
  Une seule barre par page : `toggleFiltresMobile()` travaille sur des identifiants fixes.
- **Pas de libellé visible** : le type de critère est porté par la première option
  (`— Campagne —`) et l'attribut `title`, comme dans le compendium.
- **Pas d'auto-soumission des selects.** Le module Personnages les soumettait au `change` ; avec
  un panneau repliable, chaque rechargement referme le panneau et interdit de poser deux critères
  d'affilée. Un seul point de soumission : le bouton Filtrer.
- L'ancien composant `.per-filtres*` est supprimé de `personnages-modules.css`.
- `admin-modules.css` conserve sa propre copie partielle (`.comp-filtre-form`, `-input`,
  `-select`), chargée après `modules.css` : les pages admin gardent leur rendu et héritent en plus
  des propriétés que leur copie ne déclare pas (contrôles pleine largeur, cibles 40px sous 992px)
  — cohérent avec §10, qui aligne déjà l'admin sur le compendium. Dé-doublonner cette copie reste
  à faire.


### 10g. Panneaux en feuille plein écran — SP-RS4

Sous 992px, `#detail-pp`, `#modification` et `#detail-pp-sub` deviennent des feuilles plein écran.
Défauts corrigés, mesurés à 375×812 avant travaux :

| Défaut | Mesure |
|---|---|
| `#detail-pp-sub` sortait de l'écran à droite | bord droit à **386px** pour 375 de viewport |
| Boutons flottants recouvrant le titre du contenu | le `<h2>` chevauchait Retour **et** Fermer |
| Cibles tactiles | Fermer **30×27**, Retour **81×32** |
| `max-height: 95vh` | `vh` ignore la barre d'URL rétractable |
| `#modification` sans bouton Fermer | ~4px de backdrop restants de chaque côté |

- **Barre d'en-tête commune.** `barrePanneau()` (`js/main.js`) enveloppe les boutons dans
  `.overlay-panel__bar`, injectée aux trois points de chargement (`_chargerDetailPP`,
  `actualiserPageModif`, `actualiserPageSub`). Aucune fiche `detail-pp/*` ni formulaire
  `modifier/*` n'est touchée : tout le chrome des panneaux vient de `main.js`.
- **`display: contents` en desktop** : la boîte de la barre disparaît, les boutons restent
  `position: absolute` aux coins du panneau — rendu de bureau strictement inchangé (vérifié à
  1280px : mêmes coordonnées qu'avant). Sous 992px la barre reprend une boîte flex, les boutons
  passent dans le flux à 44px et ne peuvent plus recouvrir le contenu.
- **Feuille** : `inset: 0`, `height: 100dvh` avec repli `100vh`, `transform: none`,
  sans rayon ni bordure latérale. Seul `.overlay-panel__inner` défile ; la barre reste fixe.
- **Sous-panneau** décalé de 24px vers le bas, coins hauts arrondis. La bande laissée visible
  appartient à `#detail-pp-sub-backdrop` (z-index 299 sous le panneau à 300) : un tap dessus
  ferme le sous-panneau — vérifié par `elementFromPoint`.
- **`#modification` reçoit un bouton Fermer** appelant `fermerModification()`. Seule évolution
  visible en desktop, assumée : le panneau d'édition ne se fermait que par le bouton Annuler du
  formulaire ou par le backdrop.
- Les marges hautes qui réservaient la bande des boutons flottants sont neutralisées sous 992px :
  `.overlay-panel .camp-detail` et `.glossaire-sub__header`. Le badge
  `.glossaire-sub__ligne-badge`, positionné en absolu pour s'aligner sur l'ancien Fermer, repasse
  en statique — il se serait sinon superposé à la barre.

### 10h. Relevés d'affichage — SP-RS5a

Base de mesures destinée à arbitrer les paliers responsive sur des données réelles.

- **Collecte** : `releveDevice()` (`js/main.js`) poste vers `include/ajax/releve-device.php` au
  premier chargement de page de chaque session authentifiée. Déclenchement piloté par
  `RELEVE_DEVICE`, posé par `include/footer.php` tant que `$_SESSION['releve_device']` est absent.
- **Données** : viewport CSS, `screen.width/height`, `devicePixelRatio`, orientation déduite du
  viewport, `maxTouchPoints`, plateforme (`navigator.userAgentData`), langue, `userAgent`.
  Aucune adresse IP, aucune géolocalisation.
- **Stockage** : instantané dans `dd_joueurs.j_last_*` (écrasé à chaque session) et ligne datée
  dans `dd_connexions`. Patch : `sql/2026-08-22_releves_device_sp-rs5.sql`.
- **Unicité** : `uk_co_session (co_j_id, co_session)` où `co_session = sha1(session_id())`, avec
  `INSERT IGNORE`. Le drapeau de session couvre le cas courant, la clé couvre les onglets ouverts
  simultanément.
- **Consultation** : `admin/connexions.php` — répartition par palier, largeurs les plus
  fréquentes, journal des 200 dernières connexions. Les bornes de la synthèse (479 / 767 / 991)
  reprennent les media queries déclarées : **à mettre à jour si un palier bouge en SP-RS5**.
- **Prérequis** : tant que le patch SQL n'est pas appliqué, le beacon échoue sans poser le drapeau
  de session — la collecte redémarre d'elle-même une fois la base à jour.

> Premiers relevés manuels, avant collecte automatique : Galaxy A52 **342 × 632** (dpr 3.16),
> Galaxy A12 **384 × 725** (dpr 1.88). Deux appareils sous 400px CSS, donc tous deux sous le
> palier 479 — celui qui n'est aujourd'hui utilisé que par une seule règle du projet. Le A52
> descend à 342px à cause du zoom d'affichage système : deux utilisateurs d'un même modèle
> peuvent tomber dans des paliers différents.

### 10i. Moteur de liste générique — SP-RS6b

`include/compendium-liste.php` n'est plus réservé au compendium : il sert **11 pages** — les 9
listes du compendium, `personnages/index.php` et `tableaux/index.php` (SP-TB10). Clés
optionnelles, toutes additives (absentes, comportement strictement inchangé) :

| Clé | Effet | Phase |
|---|---|---|
| `champ_res` absent | aucun filtre sources ni bouton Sources — entités sans `dd_ressources` | SP-RS6b |
| `extra_params` | valeurs des `?` de `extra_where`, ajoutées en fin de `$params` | SP-RS6b |
| `url_ligne` | clic de ligne vers une page (`{id}` remplacé) au lieu d'ouvrir `#detail-pp` | SP-RS6b |
| `edition_libre` | menu ⋮ ouvert sans passer par `canEditCompendium()` | SP-RS6b |
| `avec_ajout` | `false` masque les boutons Ajouter et Tableaux de la barre de filtre | SP-RS6b |
| `suppression` | `{mode:'ajax', action, param}` : appel JSON au lieu du POST `ids[]` | SP-RS6b |
| `champs_recherche` | colonnes SQL balayées par le filtre texte libre, en OU (défaut : la première colonne) | SP-TB10 |
| `colonnes[].valeurs` | colonne **calculée en PHP** (`[id => valeur]`) au lieu de `sql` : hors SELECT, jamais triable. Doit couvrir toute l'entité, pas seulement la page affichée | SP-TB10 |

Chaque `<td>` porte en outre `comp-col--<champ>` (SP-TB10), sur le modèle de
`.comp-subrow__part--*` : une page peut cibler une colonne en CSS ou en JS sans compter les
index de colonnes.

En mode `suppression: ajax`, le serveur peut répondre `{ok:false, confirmation_requise:true,
erreur}` : `compConfirmerSuppression()` affiche alors l'avertissement et réémet la requête avec
`force=1` si l'utilisateur confirme. C'est ainsi qu'un garde-fou métier (« ce tableau est encore
inséré dans N textes ») reste côté serveur tout en s'exprimant dans l'UI générique.

**CSS du moteur** — tableau, tri, menu ⋮, confirmation inline, pagination, barre bulk, et leur
media query 991px — déplacé dans `css/modules.css` avec la barre de filtrage. Une page qui inclut
le moteur n'a donc plus à charger `compendium-modules.css`. Le clone local des classes
`.comp-menu-*` de `personnages-modules.css` a été supprimé : chargé après `modules.css`, il
écrasait les cibles tactiles de 44px.

**JS des listes** (`compToggleMenu`, suppression inline, barre bulk, `rafraichirListe`) promu dans
`js/main.js` : il existait en deux copies (`compendium.js`, `admin.js`) plus une variante `per*`
dans `personnage.js`. `compToggleMenu(id, btn)` garde `btn` optionnel — sans lui, le menu reste
positionné par le CSS de la page appelante, ce qui préserve le comportement des listes admin.

> État de l'unification : **2 moteurs + 1 liste maison** (contre 3 implémentations avant).
> `admin-liste.php` sert encore `admin/utilisateurs.php` et `admin/ressources.php` — il porte 7
> capacités absentes du moteur commun (`confirm_callback`, `menu_extra_callback`,
> `row_class_callback`, `avec_modifier`/`avec_supprimer`, `action_supprimer`/`label_supprimer`,
> filtres `select_static`). `campagnes/index.php` garde sa table maison. Le gestionnaire de
> tableaux, lui, a rejoint le moteur en SP-TB10 : le motif invoqué en SP-TB3 (« scoping ruleset
> seul, pas de sources actives ») tenait à des `tab_res_id` laissés à NULL, pas au moteur.
> Voir SP-RS6c en §0.

---

## 11. Profil utilisateur

Quatre sections indépendantes (champ hidden section) : identité, mot de passe, paramètres, sources.
DEV_MODE = true (défini dans config/db.config.php, actif automatiquement en local) → lien reset MDP affiché en page.

### Paramètres utilisateur

| Paramètre | Champ | Description |
|---|---|---|
| Ruleset par défaut | j_default_ruleset_var_id | Ruleset chargé à chaque connexion |
| Apparence | j_theme | Thème visuel : dark (sombre) ou light (Parchemin) |
| Mode campagne | j_mode_campagne | Active/désactive le menu Campagnes |
| Affichage ruleset | j_affichage_ruleset | Affiche le ruleset dans le header |
| Éléments par page | j_items_par_page | Taille des listes (10/20/50/100) |

Ces cinq paramètres sont écrits en base **et** répercutés en session (`ruleset_var_id`,
`rulesetRep`, `j_mode_campagne`, `j_affichage_ruleset`, `j_theme`) : ils prennent effet
immédiatement, sans reconnexion.

> ⚠️ **Changement de ruleset** — si `j_default_ruleset_var_id` change réellement de valeur, la
> sauvegarde passe par `basculerRuleset()` (`helpers.php`, SP-RB — §3) : personnage, campagne,
> scénario, chapitre et rencontre mémorisés appartiennent au ruleset quitté ; ils sont mis de
> côté pour ce ruleset et ceux du ruleset rejoint sont restaurés. Les conserver
> afficherait des boutons de header de l'autre ruleset et, `last_pe_id` étant la priorité 1 de
> `getActiveResIds()`, ferait remonter les sources de la campagne d'un personnage hors ruleset.
> La même bascule recharge `$ruleset_nom_actif`, `$ressources_dispo` et `$res_selectionnes`, tous
> trois calculés avant le traitement du POST, pour que la section "Mes sources" ci-dessous ne reste
> pas sur les ressources du ruleset précédent. Détail en §12 et `DECISIONS_LOG.md` [2026-08-13].

### Section "Mes sources" — sélection personnelle des ressources

L'utilisateur peut choisir, pour le ruleset actif, quelles ressources alimentent son compendium.
Cette sélection correspond à la priorité 2 de getActiveResIds().

**Périmètre affiché (cible SP-C6, partiellement implémenté) :**
- Ressources globales officielles du ruleset actif (`res_j_id IS NULL`) — �
 implémenté
- Suppléments publics d'autres utilisateurs (section distincte) — visibles uniquement si ≥1 entrée est `_public=1 AND _visible=1` — ⏳ **non implémenté**, `profil/index.php` ne requête à ce jour que les ressources officielles

Le supplément de l'utilisateur lui-même **n'apparaît pas** comme case à cocher dans cette section
(il est auto-sélectionné via `dd_joueurs_sources`, sans UI dédiée).

> �
 **Bug corrigé le 2026-07-02** — le supplément personnel n'étant jamais dans les cases cochées
> (aucune case ne le représente), le `DELETE` + `INSERT` en bloc de la sauvegarde l'effaçait de
> `dd_joueurs_sources` à chaque enregistrement de "Mes sources", faisant disparaître tout le contenu
> homebrew de l'utilisateur des listes du compendium jusqu'à ce qu'il resélectionne son supplément —
> ce qu'aucune UI ne permet de faire explicitement. Corrigé en réinjectant systématiquement
> `getUserSupplementResId($db, $j_id, $ruleset_var_id_actif)` dans `$ids_valides` avant la sauvegarde.
> Cf. `DECISIONS_LOG.md` [2026-07-02] "Bug (suite) — supplément personnel toujours absent…".

**Comportement zéro sélection :** autorisé. getActiveResIds() retombe sur la priorité 3 (res_selection = 1).

**Sauvegarde :** DELETE + INSERT en bloc dans `dd_joueurs_sources`.

---

## 11b. Système de thèmes visuels

### Mécanisme

Le thème est une classe CSS sur `<body>` : `theme-dark` ou `theme-light`.

```php
// include/header.php
$theme_valides = ['dark', 'light'];
$theme_actif   = in_array($_SESSION['j_theme'] ?? '', $theme_valides, true)
                 ? $_SESSION['j_theme']
                 : 'dark';
// ...
<body class="theme-<?= $theme_actif ?>">
```

Les variables CSS sont déclarées par thème dans `css/main.css` :

```css
body.theme-dark  { --clr-bg: #1a1a2e; --clr-surface: #16213e; ... }
body.theme-light { --clr-bg: #f4f1eb; --clr-surface: #ffffff; ... }
:root            { /* typo, espacements, rayons — indépendants du thème */ }
```

### Thèmes disponibles

| Valeur | Nom | Description |
|---|---|---|
| dark | Sombre | Bleu nuit, accents rouge/or — défaut |
| light | Parchemin | Tons beiges chauds, accents bordeaux/or patiné |

### Variable CSS --clr-surface-alt

`--clr-surface-alt` est définie dans chaque thème pour les composants qui nécessitent
une surface légèrement différente de `--clr-surface-2`. Ne pas utiliser de fallback hardcodé.

### Overlays — largeurs

| Composant | max-width |
|---|---|
| .overlay-panel (detail-pp) | 960px |
| .overlay-panel--edit (modification) | 1040px |

---

## 12. Patterns d'interface

### detail-pp — contexte d'ouverture

detail-pp peut être ouvert depuis deux contextes :
- 'liste' : depuis une page liste du compendium
- 'externe' : depuis toute autre page (fiche personnage, scénario...) — DEFAUT

### Bouton Modifier dans detail-pp

Le HTML de detail-pp contient le bouton Modifier si `canEditCompendiumEntry($db, $res_j_id)` (vérification serveur, per-entry).
Pour les entités non compendium (personnages, campagnes), la vérification reste spécifique au module.

### Après modification — apresModification()

```javascript
function apresModification(data) {
  fermerModification();
  actualiserPage(data.url_detail, {id: data.id}, _detailPpContext);
  if (_detailPpContext === 'liste') {
    rafraichirListe(); // window.location.reload() — préserve les GET params
  }
}
```

### Navigation interne dans #detail-pp — pile `_detailPpStack`

> ⚠ **SP-CP (2026-08-24)** : le module Campagnes n'utilise plus cette pile — ses quatre niveaux
> sont devenus des pages (§8b). La pile reste en service pour les enchaînements du compendium et
> des règles (fiche → élément référencé → retour), et `ouvrirContextePP()` a été retirée de
> `main.js` avec le fil d'Ariane en liens.

Au sein d'un même panneau `#detail-pp`, une fiche et les éléments qu'elle référence s'enchaînent
sans rechargement de page, via une pile JS tenue dans `main.js` :

```javascript
let _detailPpStack = []; // [{ url, params }, ...] du plus ancien au plus récent

actualiserPage(url, params, context);   // réinitialise la pile à [{url, params}] — point d'entrée
naviguerDetailPP(url, params);          // empile et charge la vue suivante
retourDetailPP();                       // dépile et recharge la vue précédente (ferme si pile vide)
```

`_chargerDetailPP()` est le worker unique utilisé par les trois fonctions ci-dessus : c'est le seul
point de passage pour tout changement de panneau affiché dans `#detail-pp`.

### Mémorisation du contexte de navigation (header)

Reprise et généralisation, côté Campagnes, du mécanisme déjà initié pour les Personnages
(`setLastPersonnage()` / `getLastPersonnage()`, session uniquement, voir §7 et la chaîne de
sélection des sources). Objectif : afficher dans le header, sur **toutes** les pages, un raccourci
vers les derniers niveaux de campagne consultés, comme en v1, sans réintroduire le bricolage v1
(double écriture session page + header sur `$_GET`).

**Écriture — dans `helpers.php`. Depuis SP-CP, `setLast*()` est appelée par la PAGE du niveau
(`campagnes/campagne.php`, `scenario.php`, `chapitre.php`, `rencontre.php`) juste après son
contrôle `isMJ()`, et non plus par un handler `detail-pp/*` — la page est désormais le point de
consultation. Un niveau enfant n'est effacé QUE si l'id du niveau courant
change réellement — revisiter le même niveau (ex. clic sur un bouton du header, qui recharge le
même `id`) préserve les niveaux enfants déjà mémorisés :**

```php
function setLastCampagne(int $camp_id, string $camp_nom): void {
  $camp_change = ((int)($_SESSION['last_camp_id'] ?? 0)) !== $camp_id;
  $_SESSION['last_camp_id']  = $camp_id;
  $_SESSION['last_camp_nom'] = $camp_nom;
  if ($camp_change):
    unset($_SESSION['last_sce_id'], $_SESSION['last_sce_nom']);
    unset($_SESSION['last_scc_id'], $_SESSION['last_scc_nom']);
    unset($_SESSION['last_re_id'],  $_SESSION['last_re_nom']);
  endif;
}

function setLastScenario(int $camp_id, string $camp_nom, int $sce_id, string $sce_nom): void {
  setLastCampagne($camp_id, $camp_nom);
  $sce_change = ((int)($_SESSION['last_sce_id'] ?? 0)) !== $sce_id;
  $_SESSION['last_sce_id']  = $sce_id;
  $_SESSION['last_sce_nom'] = $sce_nom;
  if ($sce_change):
    unset($_SESSION['last_scc_id'], $_SESSION['last_scc_nom']);
    unset($_SESSION['last_re_id'],  $_SESSION['last_re_nom']);
  endif;
}

function setLastChapitre(int $camp_id, string $camp_nom, int $sce_id, string $sce_nom,
                          int $scc_id, string $scc_nom): void {
  setLastScenario($camp_id, $camp_nom, $sce_id, $sce_nom);
  $scc_change = ((int)($_SESSION['last_scc_id'] ?? 0)) !== $scc_id;
  $_SESSION['last_scc_id']  = $scc_id;
  $_SESSION['last_scc_nom'] = $scc_nom;
  if ($scc_change):
    unset($_SESSION['last_re_id'], $_SESSION['last_re_nom']);
  endif;
}

function setLastRencontre(int $camp_id, string $camp_nom, int $sce_id, string $sce_nom,
                           int $scc_id, string $scc_nom, int $re_id, string $re_nom): void {
  setLastChapitre($camp_id, $camp_nom, $sce_id, $sce_nom, $scc_id, $scc_nom);
  $_SESSION['last_re_id']  = $re_id;
  $_SESSION['last_re_nom'] = $re_nom;
}
```

Chaque handler dispose déjà, via sa jointure remontante, de tous les id/nom nécessaires (ex. :
`detail-pp/chapitre.php` joint `dd_scenarios_chapitres` → `dd_scenarios` → `dd_campagnes` et obtient
`camp_id`, `camp_nom`, `sce_id`, `sce_nom` en plus de ses propres champs) — aucune requête
supplémentaire n'est nécessaire pour la mémorisation. Le discriminant est l'id du niveau, pas le
chemin emprunté pour y arriver : sélectionner un autre scénario dans la même campagne efface
chapitre/rencontre mémorisés (changement réel), mais revisiter ce même scénario via le bouton du
header ne touche à rien en dessous (aucun changement). C'est aussi ce qui corrige l'incohérence du
v1, où le nettoyage des niveaux enfants n'était fait que par `campagne.php`/`scenario.php`, jamais
par un retour arrière simple.

**Lecture — `getHeaderCampagneContext(): array`**, sans requête base (tout est déjà en session) :

```php
function getHeaderCampagneContext(): array {
  $niveaux = [];
  if (!empty($_SESSION['last_camp_id'])):
    $niveaux[] = ['type' => 'campagne', 'id' => (int)$_SESSION['last_camp_id'], 'nom' => $_SESSION['last_camp_nom'] ?? ''];
  endif;
  if (!empty($_SESSION['last_sce_id'])):
    $niveaux[] = ['type' => 'scenario', 'id' => (int)$_SESSION['last_sce_id'], 'nom' => $_SESSION['last_sce_nom'] ?? ''];
  endif;
  if (!empty($_SESSION['last_scc_id'])):
    $niveaux[] = ['type' => 'chapitre', 'id' => (int)$_SESSION['last_scc_id'], 'nom' => $_SESSION['last_scc_nom'] ?? ''];
  endif;
  if (!empty($_SESSION['last_re_id'])):
    $niveaux[] = ['type' => 'rencontre', 'id' => (int)$_SESSION['last_re_id'], 'nom' => $_SESSION['last_re_nom'] ?? ''];
  endif;
  return $niveaux;
}
```

Cette fonction est enveloppée par `getHeaderContextNiveaux(PDO $db): array`, qui ajoute le repli
personnage et constitue le point d'entrée unique consommé par les deux appelants (rendu de page
complète et rafraîchissement à chaud, voir plus bas) :

```php
function getHeaderContextNiveaux(PDO $db): array {
  $niveaux = getHeaderCampagneContext();
  if (!empty($niveaux)):
    return $niveaux;
  endif;

  $last_pe_id = getLastPersonnage();
  if ($last_pe_id > 0):
    $stmt = $db->prepare('SELECT pe_nom FROM dd_personnages WHERE pe_id = ?');
    $stmt->execute([$last_pe_id]);
    $pe_nom = $stmt->fetchColumn();
    if ($pe_nom !== false):
      $niveaux[] = ['type' => 'personnage', 'id' => $last_pe_id, 'nom' => $pe_nom];
    endif;
  endif;

  return $niveaux;
}
```

Le repli personnage (`getLastPersonnage()`, déjà posée mais jusqu'ici jamais consommée) ne déclenche
qu'un unique `SELECT pe_nom FROM dd_personnages WHERE pe_id = ?`, seulement quand aucune campagne
n'est active — pas à chaque page.

**Invalidation au soft delete** — chaque fonction `supprimer*()` de `campagnes/enregistrement.php`
appelle, juste après son `$db->commit()`, `invalidateLastCampagneContext($niveau, $id)` :

```php
function invalidateLastCampagneContext(string $niveau, int $id): void {
  $prefixes = ['campagne' => 'camp', 'scenario' => 'sce', 'chapitre' => 'scc', 'rencontre' => 're'];
  if (!isset($prefixes[$niveau])) return;
  if ((int)($_SESSION['last_' . $prefixes[$niveau] . '_id'] ?? 0) !== $id) return;

  $chaine = array_keys($prefixes);
  $depart = array_search($niveau, $chaine);
  foreach (array_slice($chaine, $depart) as $n):
    unset($_SESSION['last_' . $prefixes[$n] . '_id'], $_SESSION['last_' . $prefixes[$n] . '_nom']);
  endforeach;
}
```

Efface le niveau supprimé et tout ce qui est en dessous, conserve les ancêtres — un lien mémorisé ne
peut donc jamais pointer vers une fiche supprimée.

**Invalidation au changement de ruleset** — personnages, campagnes, scénarios, chapitres et
rencontres appartiennent tous à un ruleset donné. Basculer de ruleset dans `profil/index.php`
(section « Paramètres ») purge donc l'intégralité du contexte mémorisé via
`resetContexteRuleset()` (`helpers.php`), appelée juste après la réécriture de
`$_SESSION['ruleset_var_id']` et **seulement si l'id change réellement** :

```php
function resetContexteRuleset(): void {
  unset($_SESSION['last_pe_id']);
  unset($_SESSION['last_camp_id'], $_SESSION['last_camp_nom']);
  unset($_SESSION['last_sce_id'],  $_SESSION['last_sce_nom']);
  unset($_SESSION['last_scc_id'],  $_SESSION['last_scc_nom']);
  unset($_SESSION['last_re_id'],   $_SESSION['last_re_nom']);
}
```

Ce n'est pas qu'un confort d'affichage : `last_pe_id` est le premier maillon de la chaîne de
sélection des sources (`getActiveResIds()`, §7). Conservé après bascule, il fait remonter les
sources de la campagne d'un personnage de l'autre ruleset — même famille de bug que
DECISIONS_LOG [2026-08-13]. La même bascule recharge aussi, dans la page profil, le libellé et les
cases à cocher de la section « Mes sources » sur le nouveau ruleset : sans cela l'écran resterait
sur les ressources du ruleset quitté jusqu'au prochain rechargement.

**Affichage** — un raccourci par niveau actif (pas de regroupement en `<select>` comme en v1), dans
un bloc dédié sous la barre de header principale. Le rendu HTML (le `foreach` sur les niveaux, les
liens, le lien personnage) est factorisé dans un fragment partagé, `include/header-context.php`,
qui attend la variable `$header_context_niveaux` déjà calculée par l'appelant et n'affiche rien si
elle est vide.

Depuis **SP-CP**, ce sont de simples liens vers les pages du module (§8b) — plus de bouton, plus de
chaîne d'ancêtres transportée en JS :

```html
<div class="site-header__context">
  <a href="/donjon/campagnes/campagne.php?id=12">Campagne : Les Mines Perdues</a>
  <a href="/donjon/campagnes/scenario.php?id=34">Scénario : L'Antre du Kobold</a>
  <a href="/donjon/campagnes/chapitre.php?id=56">Chapitre : L'Embuscade</a>
</div>
```

C'est ce qui remplit la fonction annoncée du bandeau : revenir à un niveau précis d'une campagne
**depuis n'importe quelle page du site**, y compris hors module.

`include/header.php` inclut ce fragment dans un conteneur d'ID fixe, **toujours présent dans le DOM**
même quand il est vide — c'est ce conteneur que cible le rafraîchissement à chaud décrit ci-dessous :

```html
<div id="site-header-context-zone">
  <?php include __DIR__ . '/header-context.php'; ?>
</div>
```

> **Historique** — jusqu'à SP-CP, chaque niveau était un `<button onclick="ouvrirContextePP(...)">`
> qui reconstruisait la chaîne complète d'ancêtres dans `_detailPpStack` avant de charger le
> panneau, pour que son bouton **← Retour** reste cohérent. Le passage en pages a supprimé la
> fonction et la chaîne : le retour est celui du navigateur, et chaque page porte le sien vers le
> niveau supérieur.

Le bouton « Personnage » (repli, aucune campagne active) reste un lien simple vers
`personnages/fiche.php?id=…` — cette page n'est pas un panneau `#detail-pp`, c'est un rechargement
complet classique.

#### Rafraîchissement à chaud (sans rechargement de page)

Premier jet bugué : `getHeaderContextNiveaux()` n'était lu qu'au rendu de page complète
(`include/header.php`), alors que consulter une campagne/scénario/chapitre se fait via le panneau
AJAX `#detail-pp` — la session est bien mise à jour côté serveur, mais le header déjà rendu dans le
navigateur ne le sait jamais sans F5.

Correction : un endpoint dédié recalcule et renvoie le même fragment, et `main.js` l'appelle après
chaque chargement réussi dans `#detail-pp` :

```php
// include/ajax/header-context.php
require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../auth.php';
require_once __DIR__ . '/../helpers.php';
requireAuth();
$header_context_niveaux = getHeaderContextNiveaux($db);
include __DIR__ . '/../header-context.php';
```

```javascript
// js/main.js
function actualiserContexteHeader() {
  const zone = document.getElementById('site-header-context-zone');
  if (!zone) return;
  fetch(BASE_URL + '/include/ajax/header-context.php')
    .then(r => r.text())
    .then(html => { zone.innerHTML = html; })
    .catch(() => {});
}
```

L'appel est placé dans `_chargerDetailPP()` (le worker unique du panneau, voir plus haut), donc
couvre automatiquement `actualiserPage`, `naviguerDetailPP` et `retourDetailPP` sans dupliquer
l'appel à chacun. Depuis SP-CP, les niveaux de campagne n'y passent plus (ce sont des pages, le
header est rendu par `include/header.php` à chaque chargement) ; le mécanisme reste utile au
raccourci personnage et à toute consultation en panneau qui écrit un `setLast*()`. `BASE_URL` doit être exposé en variable JS globale pour que
`main.js` puisse construire l'URL — posé une fois pour toutes dans `include/footer.php` :

```php
<script>
  var BASE_URL = <?= json_encode(BASE_URL) ?>;
</script>
<script src="<?= BASE_URL ?>/js/main.js"></script>
```

→ Piège rencontré en validation : après une modification de `header.php`/`main.js`, un onglet déjà
ouvert garde l'ancien DOM (pas de `#site-header-context-zone`) et l'ancien `main.js` en cache —
`actualiserContexteHeader()` ne trouve alors rien à mettre à jour. Un rechargement forcé (Ctrl+F5)
suffit ; ne pas confondre avec une régression du mécanisme lui-même.

#### Niveau Rencontre (SP3) — intégration complète

Le module Rencontres/Oppositions (SP3) a été construit après la mise en place initiale du mécanisme
ci-dessus, sans reprendre son intégration au niveau Chapitre/Rencontre — deux pièces manquaient :

- `include/ajax/detail-pp/chapitre.php` avait perdu son appel `setLastChapitre(...)`, écrasé lors de
  l'ajout de la section "Rencontres" à ce même fichier (régression, pas un oubli initial).
- `include/ajax/detail-pp/rencontre.php`, créé pour SP3, n'a jamais appelé `setLastRencontre(...)` —
  cette fonction elle-même n'existait que sous forme de commentaire (« SP3 à venir ») dans
  `helpers.php`, jamais implémentée au moment où SP3 a réellement été développé.

Le fragment `include/header-context.php` (tableaux `$ctx_urls`/`$ctx_labels`) ne connaissait pas non
plus le type `'rencontre'` — un contexte Rencontre actif y aurait provoqué une clé de tableau
indéfinie.

→ Règle à retenir : toute nouvelle sous-phase qui ajoute un niveau à la hiérarchie Campagnes (ou
modifie un handler `detail-pp/*.php` existant) doit systématiquement vérifier les quatre points
d'intégration du contexte de navigation : la fonction `setLast*()` dans `helpers.php`, son appel
dans le handler `detail-pp/*.php` correspondant, l'entrée dans `getHeaderCampagneContext()`, et
l'entrée dans `$ctx_urls`/`$ctx_labels` du fragment `header-context.php` — plus l'appel
`invalidateLastCampagneContext()` dans `campagnes/enregistrement.php` au moment de la suppression.
Cette checklist est reprise dans §17.

### Système d'overlays empilés — #detail-pp, #modification, #detail-pp-sub

| Conteneur | Backdrop | Rôle | Écriture BDD |
|---|---|---|---|
| `#detail-pp` | `#detail-pp-backdrop` | Panneau de détail principal (lecture) | Non |
| `#modification` | `#modification-backdrop` | Formulaire d'édition (overlay) | Non |
| `#detail-pp-sub` | `#detail-pp-sub-backdrop` | **Sous-panneau** affiché AU-DESSUS de `#detail-pp` | Non — lecture seule |

**API JavaScript (main.js) :**

```javascript
actualiserPageSub(url, params = {});  // Ouvre/rafraîchit le sous-panneau
fermerSubPanel();                     // Ferme le sous-panneau uniquement
fermerDetailPP();                     // Ferme #detail-pp + cascade modification + sous-panneau
```

### Commit global (pages modifier)

- *-modifier.php : édition locale JS/DOM — zéro écriture BDD
- *-enregistrement.php : un seul POST en transaction PDO
- Validation métier obligatoire côté serveur

### Blocs repliables (burger)

```html
<button onclick="togglePlus('id_bloc')"><i class="fa fa-bars"></i></button>
<div id="id_bloc" class="accordion-content noDisplay">
  <div class="box-data">contenu</div>
</div>
```

Style : fond var(--burger-bg), bordure var(--burger-border), texte var(--burger-text).
Le fond reste toujours "clair" dans les deux thèmes (beige #f3f3ef en dark, #f9f6f0 en light).

### Aide contextuelle — icône `?` réutilisable

Système générique permettant d'ancrer une bulle d'aide à n'importe quel label/champ, dans
toute page ou formulaire (y compris injecté en AJAX). Cf. `doc/DECISIONS_LOG.md` [2026-06-25].

**Contenu** : `include/aide-contextuelle.php` — tableau associatif `clé => closure`, chaque
closure ayant la signature `function(PDO $db, int $ruleset_id): string` (retourne le HTML de la
bulle). Closure plutôt que HTML statique pour autoriser du contenu dynamique (requête base) sans
changer l'API d'appel. Fichier édité à la main — pas de table SQL, pas d'interface admin.

**Insertion côté formulaire** (`include/helpers.php`) :

```php
function aideIcone(string $cle): string
```

Affiche `<span class="aide-icone" data-aide="CLE" tabindex="0">?</span>`, ou rien si la clé
n'existe pas dans `aide-contextuelle.php` (jamais d'erreur visible pour une faute de frappe).

```php
<label for="mo_stats">Description complète<?= aideIcone('monstre-tags-description') ?></label>
```

**Endpoint** : `include/ajax/aide.php?cle=...` (GET, `requireAuth()`) — unique pour toutes les
aides de l'application, résout la clé et exécute sa closure.

**Affichage (js/main.js)** : un seul handler délégué sur `.aide-icone`. Au clic : fetch (mis en
cache côté JS par clé, pas de re-fetch sur réouverture) puis injection de `#aide-bulle`.

⚠️ **Contrainte impérative de positionnement** : `#detail-pp` et `#detail-pp-sub` ont un
`transform` CSS (voir tableau des overlays ci-dessus), qui devient le containing block des
descendants `position: fixed` — et leur `overflow-y: auto` peut rogner un enfant statique.
`#aide-bulle` doit donc **toujours** être créée dynamiquement en enfant direct de `<body>`
(jamais nichée dans le DOM d'un panel), positionnée via `icone.getBoundingClientRect()`.
`z-index: 350` (au-dessus de `#detail-pp-sub` à 300) suffit alors, puisqu'elle est hors de tout
contexte d'empilement transformé. Fermeture : clic extérieur, Échap, re-clic sur l'icône, ou
scroll de la couche d'ouverture (listener `scroll` en `capture: true`).

**Fichiers** : `include/aide-contextuelle.php`, `include/ajax/aide.php`,
`include/helpers.php` (`aideIcone()`), `css/modules.css` (`.aide-icone`, `#aide-bulle`),
`js/main.js` (handler `.aide-icone`).

**Pour ajouter une aide ailleurs** : une entrée dans `aide-contextuelle.php` +
`<?= aideIcone('ma-cle') ?>` à l'endroit voulu. Aucune autre modification nécessaire.

---

## 12b. Composants transverses — tri par glisser-déposer et pastille d'enregistrement

Deux composants nés du besoin du module Campagnes (SP-CP1) mais **écrits pour tout le site** :
chargés partout (`js/tri-liste.js` dans `include/footer.php`, CSS dans `css/modules.css`),
sans aucune dépendance à un module.

### Tri par glisser-déposer — `js/tri-liste.js`

Contrat HTML, valable sur `<tbody>`/`<tr>` comme sur `<div>`/`<div>` — le moteur ne connaît qu'un
conteneur et des enfants directs identifiés :

```html
<tbody class="tri-liste"
       data-tri-url="/donjon/campagnes/enregistrement.php?ajax=1"
       data-tri-action="reordonnerRencontres"
       data-tri-parent="42">
  <tr data-tri-id="7">
    <td class="tri-poignee"><i class="fa fa-grip-vertical"></i></td>
    …
  </tr>
</tbody>
```

| Point | Décision |
|---|---|
| Événements | **Pointer Events**, pas l'API drag&drop HTML5 : un seul jeu d'événements souris + tactile, et `setPointerCapture()` garantit de recevoir les déplacements même hors de la ligne saisie |
| Prise | Uniquement sur `.tri-poignee` — les cellules restent cliquables pour naviguer, et un glissement accidentel est impossible |
| Tactile | `touch-action: none` sur la poignée est **indispensable** : sans lui le navigateur traite le glissement comme un défilement et n'émet plus de `pointermove` |
| Écoute | Handlers délégués sur `document` — aucune initialisation à appeler, le contenu injecté en AJAX fonctionne d'office |
| Réordonnancement | Déplacement réel du nœud dans le DOM (`insertBefore`), pas de transformation CSS |
| POST | `{ action, parent_id, ids }`, `ids` = les `data-tri-id` dans le nouvel ordre, séparés par des virgules |
| Échec | Message d'erreur puis rechargement : mieux vaut réafficher la vérité que laisser travailler sur un classement faux |

**Côté serveur**, le module hôte fournit l'action. Modèle de référence :
`reordonnerNiveau()` dans `campagnes/enregistrement.php` — propriété vérifiée sur le **parent**
(une seule remontée de hiérarchie), puis exigence d'un **lot exact** : le nombre d'ids postés doit
égaler le nombre d'enfants actifs du parent, sinon rien n'est écrit. Un lot partiel produirait des
rangs en double ; un id étranger ne peut pas être déplacé, même s'il appartient au même MJ.
Le rang écrit est l'index+1, dans une transaction.

### Pastille d'enregistrement — `notifier()`

```javascript
notifier('Ordre enregistré');                    // ok (défaut)
notifier('Ordre non enregistré', 'erreur');      // erreur
notifier('…', 'info');
```

À appeler dès qu'une donnée est écrite **sans** que l'utilisateur ait cliqué sur « Enregistrer ».
Une écriture invisible doit laisser une trace visible, sinon rien ne distingue « enregistré » de
« perdu ». À ne **pas** utiliser pour les commits explicites de formulaire : ceux-là ont déjà leur
retour (fermeture du panneau + rechargement, ou `.flash-message`).

Zone `#toast-zone` créée à la volée en enfant de `<body>`, bas-droite, pastilles empilables,
effacement automatique après `TOAST_DUREE` (2,5 s) avec transition de sortie. `z-index: 8000` —
au-dessus de tous les panneaux (max applicatif 300), sous le badge de debug (9000), qui doit
rester lisible. Même famille visuelle que ce badge (§10c).

**Branchée sur** : le tri (SP-CP1), le sélecteur de dons (SP-PE4) et le rattachement de campagne
(SP-PE5) — ces deux derniers écrivaient déjà en direct sans rien afficher.

---

## 13. Arborescence du projet

```
donjon/
  index.php
  .htaccess
  personnages/     fiche.php, enregistrement.php, magie.php, objets.php, index.php
  compendium/      sorts.php, classes.php, dons.php, races.php,
                   competences.php, objets.php, monstres.php,
                   historiques.php   (DD2024 uniquement)
                   enregistrement.php
  campagnes/       index.php (liste), campagne.php, scenario.php, chapitre.php,
                   rencontre.php   ← pages pleine page (SP-CP, §8b)
                   enregistrement.php (POST centralisé du module)
  wiki/            univers.php, articles.php
  regles/          index.php, regle.php, recherche.php, modifier.php, enregistrement.php
  profil/          index.php, mot-de-passe-oublie.php, reinitialisation.php
  admin/
    index.php
    utilisateurs.php
    ressources.php
    enregistrement.php
    migrations.php        état et application des migrations SQL (SP-DP5, §6b)
    migrations-auto.php   point d'entrée du déployeur, jeton à usage unique (SP-DP6)
    deploiement/          module de déploiement SFTP — LOCAL UNIQUEMENT, jamais transféré (§6b)
  js/
    main.js          togglePlus, actualiserPage, _detailPpContext,
                     apresModification, rafraichirListe, CSRF
    personnage.js
    compendium.js    toggleSort, submitFiltre, bulk, confirmerSuppression inline
    campagne.js
    tri-liste.js     tri par glisser-déposer générique (SP-CP1, §12b)
    wiki.js
    regles.js
    profil.js
    admin.js
  css/
    main.css                  variables par thème (body.theme-dark/light), layout, composants transverses
    modules.css               styles globaux (login, dashboard, profil, header, sélecteur thème)
    compendium-modules.css    styles compendium (liste, detail-pp, badge homebrew)
    personnages-modules.css   (Phase 3)
    campagnes-modules.css     (Phase 4)
    wiki-modules.css          (Phase 5)
    regles-modules.css
    admin-modules.css
  include/
    db.php           PDO (charge config/db.config.php pour BASE_URL + DEV_MODE + DB_*)
    auth.php         + canEditCompendium() + chargement j_theme en session
    helpers.php      + canEditCompendiumEntry() + getOrCreateUserSupplement() + getUserSupplementResId()
    header.php
    footer.php
    header-context.php      fil d Ariane (liens vers les pages campagne, §12)
    campagne-outils.php     colonne d outils des pages Campagnes (SP-CP)
    compendium-liste.php    moteur de liste commun compendium (lit $listConfig)
    admin-liste.php
    regles-arbre.php
    monstre-parser.php      moteur d'analyse + rendu du bloc de stats monstre (v3)
    personnage_helpers.php
    migrations.php          moteur de migrations SQL (SP-DP5, §6b)
    migrations-reference.php  référence initiale figée des migrations antérieures
    maintenance.php         page 503 servie par db.php pendant un déploiement
    ajax/
      detail-pp/     sort.php, classe.php, don.php, race.php, historique.php,
                     objet.php, monstre.php, ..., equipement.php
      detail-pp-sub/ glossaire.php
      modifier/      sort.php, classe.php, don.php, race.php, historique.php,
                     objet.php, monstre.php, regle.php, ..., equipement.php
      export/        monstre-roll20.php   export JSON Roll20 NPC (GET ?id=mo_id)
      autocomplete-tags-monstre.php
  sql/
    .htaccess                   ← aucun accès web
    AAAA-MM-JJ_*.sql            ← migrations, jouées par le moteur (§6b) ; seules à partir en prod
    schema.sql
    patch_001_reset_password.sql
    patch_004_supplements.sql   ← 8 ALTER TABLE (_public/_visible) + migration mo_j_id
  config/
    .htaccess                   ← aucun accès web
    db.config.php               ← jamais transféré par le déployeur
  .deployignore                 ← fichiers versionnés qui ne partent pas en production (§6b)
  uploads/
  img/
    uploads/
  doc/
    ARCHITECTURE_0_REFERENCE.md
    DECISIONS_LOG.md
    SCHEMA_SQL.md
    METIER_*.md
    roll20-api/  ImportNPC.js   script Roll20 API Pro (import NPC depuis handout)
```

---

## 14. Plan de développement

### Phase 1 — Socle technique TERMINE
Auth, session, helpers, header/footer, dashboard, profil, reset MDP, CSS design system.

### Phase 2 — Compendium EN COURS (sorts, dons, compétences, classes, races, objets, monstres, historiques)
- include/compendium-liste.php — moteur commun
- compendium/enregistrement.php — POST commun + mode AJAX
- js/compendium.js — tri, filtre, bulk, confirmation inline
- css/compendium-modules.css — styles listes, detail-pp sort, responsive compendium
- Pages : sorts, classes, dons, races, competences, objets, monstres, historiques (DD2024)
- AJAX detail-pp et modifier pour chaque entité
- Monstres : moteur de rendu dédié include/monstre-parser.php (v3)

### Phase 2 — Supplément utilisateur (SP-C)

Permet à tout j_compendium_manager de créer des entrées propres dans le compendium,
rattachées à une source "Supplément de {pseudo}" (1 par ruleset par utilisateur).

| Phase | Contenu | Complexité |
|---|---|---|
| **SP-C0** | SQL : 8 × ALTER TABLE (`_public`/`_visible`) + migration `mo_j_id` (`patch_004_supplements.sql`) | Modérée |
| **SP-C1** | Socle : `getOrCreateUserSupplement`, `getUserSupplementResId`, `canEditCompendiumEntry` | Faible |
| **SP-C2** | Moteur : `compendium-liste.php` JOIN + filtre visibilité + per-entry menu ⋮ + badge ; 8 contrôleurs | Élevée |
| **SP-C3** | `detail-pp/*.php` × 8 : bouton Modifier per-entry (`canEditCompendiumEntry`) | Modérée |
| **SP-C4** | `modifier/*.php` × 8 : source dropdown 2 groupes + `_public`/`_visible` | Modérée |
| **SP-C5** | `enregistrement.php` : ownership + save `_public`/`_visible` + auto-create supplément | Modérée |
| **SP-C6** | `profil/index.php` : "Mes sources" étendu aux suppléments publics tiers | Faible |

> �
 **Blocage levé le 2026-07-01.** `SHOW CREATE TABLE` exécuté sur les 7 tables restantes (base de
> dev locale) : `_public`/`_visible` **existent déjà en base** (migration SP-C0 appliquée en base sans
> que `SCHEMA_SQL.md` ni `patch_004_supplements.sql` committé n'aient suivi — même écart doc/base que
> l'incident `mo_j_id`, cf. `DECISIONS_LOG.md` [2026-06-20] et [2026-07-01]). `SCHEMA_SQL.md` mis à
> jour (v1.5). SP-C4/SP-C5 repris directement sur le modèle Monstres, entité par entité.
| **SP-C7** | Nettoyage monstres post-migration (suppression `monstre-old.php`, vérif `monstre-parser.php`) | Faible |

#### Avancement par entité

SP-C0 et SP-C1 sont des phases transverses (socle SQL + helpers), livrées pour les 8 entités.
SP-C2 à SP-C7 s'implémentent entité par entité. État au 2026-07-01 :

| Entité | SP-C2 (moteur liste) | SP-C3 (detail-pp) | SP-C4 (formulaire) | SP-C5 (enregistrement) | SP-C6 | SP-C7 |
|---|---|---|---|---|---|---|
| **Monstres** | �
 fait (2026-06-20) | �
 fait (2026-06-20) | �
 fait (2026-06-20) | �
 fait (2026-06-20) | — (transverse) | �
 fait (2026-06-20) |
| **Dons** | �
 fait (2026-07-01) | �
 fait (2026-07-01) | �
 fait (2026-07-01) | �
 fait (2026-07-01) | — (transverse) | n/a |
| **Sorts** | �
 fait (2026-07-01) | �
 fait (2026-07-01) | �
 fait (2026-07-01) | �
 fait (2026-07-01) | — (transverse) | n/a |
| **Compétences** | �
 fait (2026-07-01) | �
 fait (2026-07-01) | �
 fait (2026-07-01) | �
 fait (2026-07-01) | — (transverse) | n/a |
| **Races** | �
 fait (2026-07-01) | �
 fait (2026-07-01) | �
 fait (2026-07-01) | �
 fait (2026-07-01) | — (transverse) | n/a |
| **Classes** | �
 fait (2026-07-01) | �
 fait (2026-07-01) | �
 fait (2026-07-01) | �
 fait (2026-07-01) | — (transverse) | n/a |
| **Objets magiques** | �
 fait (2026-07-01) | �
 fait (2026-07-01) | �
 fait (2026-07-01)* | �
 fait (2026-07-01)* | — (transverse) | n/a |
| **Historiques** | �
 fait (2026-07-01) | �
 fait (2026-07-01) | �
 fait (2026-07-01) | �
 fait (2026-07-01) | — (transverse) | n/a |

> \* Objets magiques : `om_visible` préexistait à SP-C avec une sémantique propre (« visible par les
> joueurs », toujours modifiable, y compris sur une entrée officielle) — **conservée telle quelle**,
> non alignée sur le couple `_public`/`_visible` strict des 7 autres entités. Seul `om_public` (nouveau)
> suit le mécanisme Supplément, forcé à `0` côté serveur pour les entrées officielles. Formulaire :
> une seule checkbox « Partagé » conditionnelle (source = supplément), pas de checkbox « Visible »
> dupliquée — celle-ci reste affichée en permanence comme avant SP-C.
>
> Toutes les entités sont désormais traitées C0 à C5 (+ C7 pour Monstres uniquement, nettoyage
> spécifique à sa migration `mo_j_id`). Seul **SP-C6** (profil "Mes sources" — suppléments publics
> d'autres utilisateurs) reste en pause, cf. `DECISIONS_LOG.md` [2026-06-20] et [2026-07-01].

### Phase Admin — Zone d'administration TERMINE

### Mise en page — Thèmes TERMINE

### Phase 3 — Personnages EN COURS (`SP-PE`)
Fiche, classes/niveaux, sorts, compétences, dons, campagnes, NLS (DD3.5).
`SP-PE0→PE6` livrées (dernière livraison 2026-08-27) ; `SP-PE7→PE8` à faire — checklist en §0,
contenu des phases en §7.11.

### Phase 4 — Campagnes
Campagne (sources, univers, personnages invités), scénarios, chapitres, rencontres, oppositions,
duplication, pièces jointes PDF. Structure de données validée.

### Phase 5 — Wiki / Univers
Univers, catégories, articles, délégation, lien univers <-> campagne.

### Module Règles — Wiki de règles TERMINE
Table récursive dd_regles, arbre repliable, vue lecture (fil d'Ariane + Précédent/Suivant DFS),
recherche FULLTEXT, glossaire DD2024 (nœuds reg_type='glossaire' + ancres .glossaire-lien).

---

## 15. Tables de la base de données

### Référentiels
| Table | Préfixe | Rôle |
|---|---|---|
| dd_variables | var | Rulesets et valeurs paramétrables |
| dd_ressources | res | Livres/suppléments — res_j_id = null (officiel) ou j_id (supplément) |
| dd_caracteristiques | car | 6 caractéristiques DD |
| dd_modificateurs | mod | Modificateurs de caractéristiques |

### Technique
| Table | Préfixe | Rôle |
|---|---|---|
| dd_migrations | mig | Migrations SQL appliquées à la base de l'environnement (SP-DP5, §6b) — créée par le moteur |

### Utilisateurs
| Table | Préfixe | Rôle |
|---|---|---|
| dd_joueurs | j | Utilisateurs |
| dd_joueurs_sources | js | Sélection sources par utilisateur (inclut les suppléments) |

### Compendium
| Table | Préfixe | Champs supplément | Rôle |
|---|---|---|---|
| dd_races | ra | `ra_public`, `ra_visible` | Races jouables |
| dd_race_type | rat | — | Types de race |
| dd_classes | cla | `cla_public`, `cla_visible` | Classes de personnage |
| dd_classe_niveau | cn | — | Table de bonus par niveau |
| dd_capacites_speciales | cap | — | Capacités spéciales |
| dd_classe_capacite | cc | — | Affectation capacité → niveau |
| dd_typeMagie | mag | — | Types de magie |
| dd_colleges | co | — | Collèges de magie |
| dd_sorts | so | `so_public`, `so_visible` | Sorts |
| dd_sortclasse | sc | — | Sorts par classe |
| dd_dons | do | `do_public`, `do_visible` | Dons |
| dd_data_don | dado | — | Catégories de dons |
| dd_competences | comp | `comp_public`, `comp_visible` | Compétences (pas de `comp_camp_id`) |
| dd_historiques | hi | `hi_public`, `hi_visible` | Historiques (DD2024 uniquement) |
| dd_objets_magiques | om | `om_public` | Objets magiques (`om_visible` déjà existant) |
| dd_monstres | mo | `mo_public`, `mo_visible` | Monstres (`mo_j_id` supprimé, migration vers supplément) |
| dd_monstres_categories | mocat | — | Catégories de monstres |
| dd_monstres_groupes | mogr | — | Groupes de monstres (DD2024) |
| dd_fp | fp | — | Référentiel des facteurs de puissance |

> **Champs `_public` et `_visible` :** ajoutés via `patch_004_supplements.sql`.
> `_public` : 0 = privé (défaut), 1 = partagé. N'a de sens que pour les entrées de supplément.
> `_visible` : 0 = brouillon masqué, 1 = visible (défaut). Contrainte : `_public=1` implique `_visible=1`.

### Personnages
| Table | Préfixe | Rôle |
|---|---|---|
| dd_personnages | pe | Fiches personnages |
| dd_personnages_classes | pc | Classes du personnage |
| dd_personnages_nls | penl | NLS classes de prestige (DD3.5) |
| dd_personnages_sorts | pes | Sorts du personnage |
| dd_personnages_sorts_prepares | pesp | Sorts préparés |
| dd_personnages_competences | pec | Compétences du personnage |
| dd_personnages_dons | ped | Dons du personnage |

### Campagnes
| Table | Préfixe | Rôle |
|---|---|---|
| dd_campagnes | camp | Campagnes |
| dd_campagnes_personnages | cp | Lien N-N personnage <-> campagne |
| dd_campagnes_sources | cs | Sources actives d'une campagne (priorité 1) |
| dd_scenarios | sce | Scénarios |
| dd_scenarios_chapitres | scc | Chapitres |
| dd_rencontres | re | Rencontres |
| dd_oppositions | opp | Copie éditable d'un monstre |
| dd_fichiers | fi | Pièces jointes PDF génériques |
| dd_campagnes_notes | cpno | RÉSERVÉ |

### Wiki / Univers
| Table | Préfixe | Rôle |
|---|---|---|
| dd_univers | un | Univers wiki |
| dd_univers_droits | ud | Délégation droits édition |
| dd_univers_categories | uca | Catégories d'articles |
| dd_univers_articles | ua | Articles wiki |

### Règles (wiki de règles)
| Table | Préfixe | Rôle |
|---|---|---|
| dd_regles | reg | Chapitres et règles, hiérarchie récursive (reg_reg_id) |

### Notes
| Table | Préfixe | Rôle |
|---|---|---|
| dd_notes | no | Notes de jeu |
| dd_notes_contenus | noc | Blocs de contenu |
| dd_personnages_notes | pno | Note attribuée à un personnage |
| dd_tags | tag | Tags libres |
| dd_notes_tags | notag | Association notes <-> tags |

---

## 16. Éditeur de texte enrichi — TinyMCE

### Choix retenu

TinyMCE 6 via CDN **jsDelivr** (`https://cdn.jsdelivr.net/npm/tinymce@6/tinymce.min.js`), sans clé API
(pas de compte tiny.cloud). `base_url`/`suffix` pointent vers le même CDN pour le chargement des plugins
et du skin. Chaque formulaire d'édition charge sa propre instance via le pattern `initTMCE()` (pas de
script global partagé) car les sélecteurs, hauteurs et plugins varient par module.

> **Le script CDN n'est chargé qu'une fois par page** (correctif du 2026-10-10). Chaque formulaire
> porte son `<script src=".../tinymce.min.js">`, mais `executerScriptsInjectes()` (`js/main.js`,
> appelée par `actualiserPageModif()` et `actualiserPageSub()`) ne recrée pas un script externe
> déjà chargé — seuls les scripts en ligne sont réexécutés. Le rechargement remplaçait l'objet
> global `tinymce` après la création des éditeurs : à la deuxième ouverture d'un formulaire sans
> rechargement de la page, la saisie des champs riches était perdue à l'envoi.

### Pattern d'initialisation — `initTMCE()`

Obligatoire pour tout nouveau champ TinyMCE, sans exception :

```javascript
(function initTMCE() {
  if (typeof tinymce === 'undefined') { setTimeout(initTMCE, 100); return; }
  var isLight = document.body.classList.contains('theme-light');
  tinymce.remove('#mon_champ'); // évite les doublons sur réouverture du formulaire
  tinymce.init({
    selector:      '#mon_champ',
    language:      'fr_FR',
    menubar:       false,
    plugins:       'lists link image table code',
    toolbar:       'styles | bold italic underline | bullist numlist | link unlink image table | removeformat | code',
    height:        300,
    skin:          isLight ? 'oxide' : 'oxide-dark',
    content_css:   isLight ? 'default' : 'dark',
    content_style: isLight
      ? 'body { background:#eae6dd; color:#2a2015; font-family:inherit; font-size:14px; }'
      : 'body { background:#0f3460; color:#e0e0e0; font-family:inherit; font-size:14px; }',
    promotion:     false,
    branding:      false,
    base_url:      'https://cdn.jsdelivr.net/npm/tinymce@6',
    suffix:        '.min',
    images_upload_url:         '<?= BASE_URL ?>/include/ajax/upload-image.php',
    images_upload_credentials: true,
    automatic_uploads:         true,
  });
})();
```

Pour un overlay ouvert après le chargement initial de la page (ex. capacité spéciale d'une classe/race),
`tinymce` est déjà chargé : on omet le test `typeof tinymce === 'undefined'` mais on conserve la
détection `isLight` et l'intégralité de la configuration ci-dessus.

### Thème dynamique — fond aligné sur le thème actif

**Règle impérative** : `skin` et `content_css` ne sont **jamais** codés en dur. Ils dépendent toujours de
`document.body.classList.contains('theme-light')`, calculé à chaque `initTMCE()` (le thème peut changer
entre deux ouvertures du même formulaire dans la session).

| Thème | skin | content_css | Fond éditeur (`content_style`) | Texte |
|---|---|---|---|---|
| dark (défaut) | `oxide-dark` | `dark` | `#0f3460` (= `--clr-surface-2` thème sombre) | `#e0e0e0` |
| light (Parchemin) | `oxide` | `default` | `#eae6dd` (= `--clr-surface-2` thème clair) | `#2a2015` |

Le fond de la zone d'édition est explicitement fixé via `content_style` plutôt que de se fier au rendu
par défaut des feuilles `content_css: 'default'/'dark'` fournies par TinyMCE : ces dernières ne
correspondent pas aux teintes du design system du projet (notamment en thème clair, où le rendu par
défaut de `oxide`/`default` ne reprend pas le ton parchemin `--clr-surface-2: #eae6dd`). Les valeurs
hexadécimales ci-dessus sont la copie figée des variables CSS `--clr-surface-2` / `--clr-text` de
`main.css` (l'iframe TinyMCE est un document séparé, les `var(--clr-*)` du document parent n'y sont pas
accessibles — il faut donc dupliquer les valeurs, pas les variables).

> **Anti-pattern corrigé (2026-06-17)** : plusieurs formulaires codaient `skin: 'oxide-dark'` /
> `content_css: 'dark'` sans condition de thème. Résultat : en thème clair (Parchemin), l'éditeur
> affichait le fond bleu nuit du thème sombre au lieu du fond parchemin attendu. Tout nouveau champ
> TinyMCE doit utiliser la détection `isLight` ci-dessus.

### Barre d'outils standard

**Référence canonique (2026-06-19)** : la barre d'outils du champ Description (module Rencontres) est
la référence pour **tout** nouveau champ TinyMCE de l'application — `image` et `table` en font partie
par défaut, upload d'images compris. Un champ peut retirer `table`/`image` (et les plugins associés)
uniquement si la fonctionnalité n'a structurellement aucun sens pour ce contenu (ex. un champ de
quelques mots) — jamais par défaut, et jamais par ajout de boutons hors liste sans mise à jour de
cette doc.

| Bouton toolbar | Fonction | Plugin requis |
|---|---|---|
| `styles` | Sélecteur de style (Normal, Titre 1, Titre 2…) | aucun (natif TinyMCE 6) |
| `bold` | Gras | aucun |
| `italic` | Italique | aucun |
| `underline` | Souligné | aucun |
| `bullist` | Liste à puces | `lists` |
| `numlist` | Liste numérotée | `lists` |
| `link` | Insérer un lien | `link` |
| `unlink` | Enlever le(s) lien(s) | `link` |
| `image` | Insérer une image (upload via `images_upload_url`) | `image` |
| `table` | Insérer/éditer un tableau | `table` |
| `removeformat` | Effacer tous les styles | aucun |
| `code` | Afficher/éditer le code source HTML | `code` |

Chaîne `toolbar` canonique :
```
styles | bold italic underline | bullist numlist | link unlink image table | removeformat | code
```
Chaîne `plugins` canonique :
```
lists link image table code
```

Le bouton `styles` est natif (aucun plugin requis) et expose par défaut Paragraphe + Titres 1 à 6 sans
configuration supplémentaire. Un module peut enrichir ce sélecteur via `style_formats` (voir module
Règles ci-dessous) ; dans ce cas la liste par défaut est remplacée par la liste personnalisée — si les
niveaux de titre restent nécessaires en plus des styles personnalisés, ajouter aussi le bouton `blocks`
avec `block_formats` (cf. exemple Règles).

> **Anti-pattern corrigé (2026-06-19)** : avant cette date, la référence canonique omettait `image` et
> `table` par défaut (variante « sans images »), avec une configuration séparée « avec upload d'images »
> traitée comme cas particulier pour Campagnes/Scénarios/Personnages. Ce découpage a créé des
> incohérences entre formulaires d'un même module (ex. `re_composition` avec une toolbar allégée
> pendant que `re_description` du même formulaire avait la toolbar complète). Désormais : un seul
> standard, avec retrait explicite et justifié si nécessaire — jamais d'allègement par défaut.

### Configuration standard (image + table incluses)

Pour tout champ TinyMCE sans restriction métier particulière — c'est le cas par défaut, applicable à
Campagnes, Scénarios, Chapitres, Rencontres (Description **et** Composition), Personnages
(background/notes), etc. :

```javascript
toolbar: 'styles | bold italic underline | bullist numlist | link unlink image table | removeformat | code',
plugins: 'lists link image table code',
// ...
images_upload_url:         '<?= BASE_URL ?>/include/ajax/upload-image.php',
images_upload_credentials: true,
automatic_uploads:         true,
```

### Configuration module Règles — styles personnalisés + nettoyage du collage

Pour : module Règles uniquement (`reg_texte`). S'ajoute au pattern standard :
- `blocks` (titres `block_formats`) + `styles` (styles personnalisés `style_formats` : `Titre de
  tableau`, `Encadré`) cumulés dans la toolbar : `'blocks styles | ...'`.
- `paste_postprocess` : nettoyage des attributs hérités du collage Word (class, style, width, height,
  lang, valign, align, cellpadding, cellspacing, border), suppression des `<p>` à l'intérieur des
  tableaux, suppression des balises `<font>`, suppression des éléments vides résiduels.
- `content_style` : le fond thème (`isLight ? ... : ...`) est concaténé devant les règles spécifiques au
  module (`.glossaire-lien`, `.titre-tableau`, `.regles-encart`, `h3`/`h4`) — jamais en remplacement.

### Endpoint upload images

Fichier : `include/ajax/upload-image.php`
Répertoire : `img/uploads/` (permissions 755, dans `.gitignore`)
Retourne : `{ "location": "URL_du_fichier" }`

### Affichage du contenu TinyMCE

Le HTML généré est stocké et affiché **tel quel** (sans `h()`).

### Soumission formulaire AJAX

```javascript
tmceGet(id); // lit ed.getContent() si l'éditeur est initialisé, sinon repli sur textarea.value
// ou, pour synchroniser tous les éditeurs d'un formulaire avant FormData :
document.querySelectorAll('.tinymce-basic').forEach(function(el) {
  const ed = tinymce.get(el.id);
  if (ed && ed.initialized) el.value = ed.getContent();
});
```

---

## 17. Checklist avant chaque merge

- [ ] Aucun write AJAX dans *-modifier.php
- [ ] Payload hidden complet et cohérent au submit
- [ ] Validations serveur couvrent les cas invalides
- [ ] Transaction PDO active sur *-enregistrement.php
- [ ] ownerFilter() appliqué sur toutes les requêtes de liste (modules non-compendium)
- [ ] h() sur toutes les sorties HTML
- [ ] CSRF token vérifié sur tous les POST
- [ ] Aucune URL absolue codée en dur — BASE_URL utilisé partout
- [ ] Templates ruleset sans logique auth/session
- [ ] rulesetRep validé via whitelist avant inclusion template
- [ ] Responsive testé sur les modules concernés (hors Campagnes)
- [ ] $css_module défini dans chaque contrôleur de module
- [ ] Compendium : colonne de tri validée par whitelist avant ORDER BY
- [ ] Compendium : _detailPpContext correctement passé à actualiserPage()
- [ ] Compendium : enregistrement.php?ajax=1 retourne JSON, mode normal retourne redirect
- [ ] Compendium : historiques.php et ses endpoints conditionnés au ruleset DD2024
- [x] **Supplément : `champ_public`, `champ_visible` et `champ_res_owner` déclarés dans `$listConfig` pour les 8 pages contrôleurs** → �
 8/8 (2026-07-01)
- [x] **Supplément : filtre visibilité moteur — implémenté dans `compendium-liste.php` (générique, actif dès que les 3 clés sont déclarées)** → �
 actif sur 8/8 entités (2026-07-01)
- [x] **Supplément : menu ⋮ (liste) et bouton Modifier (`detail-pp`) conditionnés par `canEditCompendiumEntry($db, $_res_j_id)` (per-entry)** → �
 8/8 (2026-07-01)
- [x] **Supplément : formulaire `modifier/*.php` — source dropdown 2 groupes (officiel + supplément) ; `_public`/`_visible` masqués pour sources officielles** → �
 8/8 (2026-07-01) ; Objets magiques : cas particulier `om_visible` conservé (cf. § Avancement par entité)
- [x] **Supplément : contrainte serveur — si `_public = 1` alors `_visible` forcé à 1 au save** → �
 répliqué dans les 8 `enregistrer*()` (2026-07-01)
- [x] **Supplément : auto-création ressource supplément + auto-add `dd_joueurs_sources` sur premier save** → mécanisme transverse (`getOrCreateUserSupplement()`), utilisé par les 8 entités
- [x] **Supplément : badge `.comp-ligne--homebrew` sur toutes les lignes de supplément dans les listes** → �
 actif sur 8/8 (moteur générique, styles `compendium-modules.css`)
- [x] **Supplément : suppression per-entry — fonction dédiée avec garde `canEditCompendiumEntry()` requise pour chaque entité du compendium** → �
 8/8 (2026-07-01) : `supprimerMonstre()`, `supprimerDon()`, `supprimerSort()`, `supprimerCompetence()`, `supprimerRace()`, `supprimerClasse()`, `supprimerObjet()`, `supprimerHistorique()` — `supprimerEntite()` générique n'est plus utilisée que par Équipements (hors périmètre SP-C)
- [ ] **Monstres : `mo_j_id` absent de toutes les requêtes (colonne supprimée via `patch_004_supplements.sql`)**
- [ ] **Campagnes : tout nouveau niveau hiérarchique (ou handler `detail-pp/*.php` modifié) vérifie
      les 4 points d'intégration du contexte de navigation — `setLast*()` dans `helpers.php`, appel
      dans le handler, entrée dans `getHeaderCampagneContext()`, entrée dans `$ctx_urls`/`$ctx_labels`
      de `include/header-context.php` — plus `invalidateLastCampagneContext()` au moment du delete**
- [ ] Admin : requireAdmin() en tête de chaque page admin/
- [ ] Admin : suppression utilisateur = désactivation j_visible=0, jamais DELETE
- [ ] Admin : suppression ressource = vérification préalable sur les 7 tables compendium
- [ ] TinyMCE : triggerSave() appelé avant tout submit AJAX
- [ ] TinyMCE : champs description/contenu affichés sans h()
- [ ] **TinyMCE : `skin`/`content_css` jamais codés en dur — toujours `isLight ? 'oxide'/'default' : 'oxide-dark'/'dark'` via `document.body.classList.contains('theme-light')`**
- [ ] **TinyMCE : `content_style` fixe le fond/texte par thème (`#eae6dd`/`#2a2015` clair, `#0f3460`/`#e0e0e0` sombre) — alignement obligatoire sur `--clr-surface-2`/`--clr-text`**
- [ ] **TinyMCE : toolbar canonique présente — `styles | bold italic underline | bullist numlist | link unlink [table] [image] | removeformat | code`**
- [ ] Règles : module n'utilise PAS compendium-liste.php (scoping ruleset seul, pas de sources)
- [ ] Règles : Précédent/Suivant calculés par reglesOrdreLecture() (DFS), pas de colonne globale
- [ ] Règles : parent validé anti-cycle (≠ soi-même, ≠ descendant) à l'enregistrement
- [ ] Règles : recherche FULLTEXT scope ruleset actif + reg_camp_id IS NULL, fallback LIKE
- [ ] Règles : édition réservée à canEditCompendium(), consultation par tout utilisateur
- [ ] Règles (DD2024) : termes de glossaire = nœuds reg_type='glossaire'
- [ ] Règles (DD2024) : renvois = ancres `.glossaire-lien[data-glossaire-slug]` dans reg_texte
- [ ] Règles (DD2024) : clic renvoi → actualiserPageSub() vers detail-pp-sub/glossaire.php
- [ ] img/uploads/ exclu du repo (.gitignore)
- [ ] Thèmes : toute nouvelle variable CSS définie dans body.theme-dark ET body.theme-light
- [ ] Thèmes : aucun fallback de couleur hardcodé dans les composants — utiliser uniquement des var()
- [ ] CSS AJAX : tout style utilisé par un fragment injecté via AJAX hors-compendium → modules.css
- [ ] CSS AJAX : .sort-detail__edit-btn et tout composant partagé → modules.css uniquement
- [ ] Couleurs composants partagés : jamais de valeur hardcodée (#fff, #333…) — toujours var(--clr-*)
- [ ] Tableaux structurés : utiliser .table-dd + .table-dd-wrap
- [ ] Tableaux à 2 lignes d'en-tête : thead avec <tr class="thead-groupes"> pour la ligne groupe
- [ ] Style tableau : jamais de border sur th/td — alternance fond gris perle / transparent sur tbody
- [ ] Thèmes : --clr-surface-alt défini dans les deux thèmes si utilisé dans un composant

---

## 18. Export Roll20 NPC

### Objectif

Permet d'exporter un monstre du compendium vers **Roll20** au format JSON compatible
avec la fiche officielle **D&D 5e (2014)** en VF. L'utilisateur télécharge le fichier `.json`
puis l'importe dans Roll20 via le script API Pro `ImportNPC.js`.

### Fichiers

| Fichier | Rôle |
|---|---|
| `include/ajax/export/monstre-roll20.php` | Endpoint PHP — parse, build, envoie le JSON |
| `doc/roll20-api/ImportNPC.js` | Script Roll20 API Pro — importe le JSON dans une campagne |

### Flux utilisateur

```
1. Utilisateur ouvre la fiche ou la liste des monstres
2. Clique sur le bouton ↓ (icône fa-download) dans le menu ⋮
3. Téléchargement automatique de roll20_<nom>.json
4. Dans Roll20, deux modes d'import au choix :
   a) Handout  : coller le JSON dans GM Notes d'un Handout,
                 puis !import-npc [nom_handout] dans le chat
   b) Token    : poser un token sur la carte, coller le JSON dans
                 ses GM Notes, le sélectionner, puis !import-npc-token
                 → crée le personnage ET lie le token automatiquement
5. Le script API crée le personnage + ses attributs
```

### Endpoint PHP — `monstre-roll20.php`

**Accès :** `GET /include/ajax/export/monstre-roll20.php?id={mo_id}`
**Auth :** `requireAuth()` — tous les utilisateurs connectés
**Sortie :** `application/json` avec `Content-Disposition: attachment`

Fonctions internes (dans le même fichier) :

| Fonction | Rôle |
|---|---|
| `firebaseId()` | Génère un ID pseudo-Firebase 20 chars unique |
| `parseMonstreStats($texte)` | Parse `mo_stats` (DD2024) en tableau structuré |
| `parseHeader($lignes, …)` | Parse npc_type / CA / Pv / Vitesse / FP / stats / optionnels |
| `parseCaracLine($ligne, …)` | Parse une ligne For/Dex/Con… → stats Roll20 |
| `parseOptionalLine($ligne, …)` | Parse Compétences / Résistances / Sens / Langues… |
| `parseActionBlock($lignes, …)` | Parse un bloc Traits / Actions / Bonus / Réactions |
| `parseAction($nom, $desc)` | Parse une action : détecte TYPE A (attaque) ou TYPE B (description) |
| `parseIncantation($texte, …)` | Parse le bloc Incantation (carac, DD, noms de sorts) |
| `parseLegendaryBlock($lignes, …)` | Parse Actions Légendaires (intro + actions) |
| `fetchSortsByName($db, …)` | Récupère les sorts par nom (2 passes SQL : index léger + données) |
| `buildRoll20NpcJson($mo, …)` | Assemble le JSON Roll20 complet |
| `addAbilityScores($attrs, …)` | Ajoute les 6 caractéristiques + modificateurs |
| `addNpcSaves($attrs, …)` | Ajoute les sauvegardes NPC (triple champ + flag) |
| `addNpcSkills($attrs, …)` | Ajoute les compétences NPC (détecte expertise via BM) |
| `addNpcActionAttrs($attrs, …)` | Ajoute les attributs Roll20 d'une action (template ① ou ②) |
| `addSpellAttrs($attrs, …)` | Ajoute les sorts repeating_spell-N (SPELLCARD uniquement) |

### Format `mo_stats` DD2024 attendu

```
[Ligne 0 opt.]  Grand aberration, Neutre mauvais   → npc_type
CA 17 Initiative +7 (17)                            → npc_ac (Initiative ignorée, voir D-R6)
Pv 150 (20d10 + 40)                                 → hp.max + npc_hpformula
Vitesse 3 m, nage 12 m                              → npc_speed
FP 10 (5 900 PX; BM 4)                              → npc_challenge + npc_xp + pb
For 21 +5 +5  Dex 9 -1 +3  Con 15 +2 +6             → 6 stats + mods + saves
Int 18 +4 +8  Sag 15 +2 +6  Cha 18 +4 +4
[Lignes optionnelles]  Compétences / Sens / Langues / Résistances / Immunités / Vulnérabilités
Traits / Actions / Actions légendaires / Actions bonus / Réactions / Incantation
```

### Actions — 2 templates `rollbase` Roll20

- **Template ① (TYPE B — description)** : `@{wtype}&{template:npcaction} … {{description=@{show_desc}}}`
- **Template ② (TYPE A — attaque)** : `@{wtype}&{template:npcfullatk} {{attack=1}} …`

Détection TYPE A : présence de `Corps à corps :` ou `À distance :` dans le texte.

### Sorts NPC

- `spelloutput = "SPELLCARD"` pour tous les sorts PNJ (V1).
- V2 prévue : `spelloutput = "ATTACK"` pour les sorts offensifs (documenté dans DECISIONS_LOG §D-R5).
- Lookup par nom normalisé (sans accents, minuscules) dans `dd_sorts`.
- JOIN `dd_colleges` → `college2Roll20()` mappe le nom FR vers le code EN Roll20.

### Script Roll20 API — `ImportNPC.js`

Trois commandes chat, deux modes d'import :

| Commande | Source | Comportement |
|---|---|---|
| `!import-npc-ping` | — | Test de connectivité (whisper de confirmation, aucun import) |
| `!import-npc [nom_handout]` | GM Notes d'un Handout (défaut : "Import NPC") | Crée le personnage dans la bibliothèque, sans token lié |
| `!import-npc-token` | GM Notes du token sélectionné | Crée le personnage, lie le token, configure taille/barres (B1=CA lié, B2=Perc. liée, B3=PV direct)/position, synchronise avatar + token par défaut |

```
1. Lecture des GM Notes (Handout ou token sélectionné) — unescape + nettoyage HTML
2. JSON.parse()
3. createObj('character', {name, avatar})
4. Pour chaque attribut : createObj('attribute', {characterid, name, current, max})
5. wtype forcé à '/w gm ' (chuchotage toujours actif) — voir DECISIONS_LOG D-R15
6. (mode token) token.set({represents, name, width:70, height:70, bar_location:'bottom'})
7. (mode token) Barres :
   - Barre1=npc_ac liée (`bar1_link`) ; Barre2=passive_wisdom liée (`bar2_link`)
   - Barre3=hp **valeur directe** sans `bar3_link` (PV indépendants par token, cf. D-R17)
8. (mode token) avatar synchronisé depuis l'image du token (getCleanImgsrc)
9. (mode token) setDefaultTokenForCharacter(character, token) — capture l'état
   courant du token (image, taille, barres, position) comme token par défaut de la fiche
10. Whisper de confirmation au MJ
```

Le mode token reproduit le pattern utilisé par des scripts communautaires Roll20
connus (ex. 5eShapedCompanion `!shaped-import-statblock`) : lecture des GM Notes
d'un token posé sur la carte plutôt que d'un Handout intermédiaire — plus rapide
en cours de partie.

### Extension `$listConfig` — clé `row_actions`

Ajoutée dans `compendium-liste.php` de manière rétro-compatible. Permet à n'importe
quel contrôleur compendium d'ajouter des boutons d'action par ligne, sans modifier le moteur.

Voir §5 pour la documentation complète des clés `row_actions`.

### Chuchotage des jets au MJ (`wtype`)

L'attribut Roll20 `wtype` est exporté avec la valeur littérale `/w gm ` (et non
une référence `@{whispertoggle}`). Cela correspond au réglage fiche "Chuchoter
les jets au MJ : Toujours" — tous les jets du PNJ (attaques, sauvegardes,
compétences) sont automatiquement chuchotés au MJ dès l'import, sans réglage
manuel sur la fiche. Voir DECISIONS_LOG D-R8.

### Trait "Équipement"

L'équipement n'a pas d'équivalent dans les champs scalaires Roll20. Il est converti en un
trait `repeating_npctrait` nommé **Équipement**, inséré en première position, alimenté par
`$result['equipment_text']`. Deux formats `mo_stats` sont reconnus, au choix :

1. **Ligne d'en-tête** — `Équipement : dague, arc court` sur une seule ligne, avant Traits.
   Géré par `parseOptionalLine()`. Voir DECISIONS_LOG D-R3.
2. **Section dédiée** — "Équipement" seul sur sa ligne (comme Traits/Actions/Réactions),
   suivi d'un ou plusieurs paragraphes. Utile pour les PNJ à équipement conséquent
   (objets magiques, grimoires...). `equipement` est une section reconnue par
   `$sections_norm` dans `parseMonstreStats()`, bornée comme les autres sections via
   `sentinelleBloc()` — indépendante de sa position dans le texte. Voir DECISIONS_LOG D-R24.

Les deux formes alimentent le même champ `equipment_text` ; en pratique un monstre donné
n'utilise que l'une ou l'autre.

### Formats `mo_stats` supportés pour l'Incantation

Deux formats de sous-listes reconnus (séparateur `:` ou ` - `) :

```
// Format 1 — séparateur ":" (ex : Mage, Cultiste)
À volonté : lumière, thaumaturgie
2/jour chacun : boule de feu, invisibilité

// Format 2 — séparateur " - " (ex : Prêtre de Baine)
Tour de magie - assistance, lumière, thaumaturgie
Niveau 1 (3/J) - blessure, injonction
Niveau 2 (2/J) - immobilisation de personne
```

Préfixes reconnus (insensibles à la casse/accents) : `À volonté`, `N/jour`, `N/jour chacun`,
`Tour(s) de magie` (singulier ou pluriel), `Niveau N`, `Cantrip`. Voir
`estPrefixeSousListeSorts()` dans `monstre-roll20.php`.

Le DD de sauvegarde est extrait via une recherche tolérante — `DD de sauvegarde` suivi,
à moins de 30 caractères, du chiffre. Couvre aussi bien `DD de sauvegarde 14` que la
formulation standard des blocs stat traduits `DD de sauvegarde des sorts 14`.

> ⚠️ **Point de vigilance.** La boucle de collecte des sous-listes de sorts s'arrête à la
> **première** ligne qui ne matche aucun préfixe reconnu — elle ne saute pas une ligne
> isolée pour reprendre sur les suivantes. La ligne des tours de magie/cantrips étant
> toujours la première de la liste dans un bloc Incantation standard, un préfixe non
> reconnu sur cette seule ligne suffit à faire perdre **tous** les sorts du monstre, pas
> seulement les tours de magie. Toute nouvelle formulation à supporter doit donc être
> testée en priorité sur cette première ligne. Voir DECISIONS_LOG D-R23.

L'ordre des sections dans `mo_stats` est **quelconque** — `sentinelleBloc()` trouve
toujours la prochaine section qui suit la section courante dans le texte, sans liste
codée en dur de successeurs attendus (cf. DECISIONS_LOG D-R20).

### Formats de dégâts supportés dans les actions

```
Touché : 6 (1d6 + 3) dégâts contondants           ← format standard
En cas de coup réussi : 16 (2d10 + 5) points de dégâts psychiques  ← format alternatif
```

### Limitations connues (V1)

- `charactersheet_type = "npc"` cible la fiche 2014 — la fiche 2024 n'est pas supportée.
- L'initiative Roll20 = `DEX_mod + DEX_score/100` (tie-breaker) ; l'initiative DD2024 (+7 dans `mo_stats`) n'est pas mappée car la fiche 2014 ne la supporte pas.
- Les images de token/avatar ne sont pas exportées (Roll20 API : upload non disponible via script).
- Les sous-classes et dons du PNJ ne sont pas exportés (hors scope `mo_stats`). L'équipement est exporté sous forme de trait (voir ci-dessus).
- `spelloutput = "ATTACK"` différé en V2 (voir DECISIONS_LOG D-R5).
