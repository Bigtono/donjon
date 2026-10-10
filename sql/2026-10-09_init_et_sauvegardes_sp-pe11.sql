-- 2026-10-09_init_et_sauvegardes_sp-pe11.sql
-- SP-PE11 — Initiative et modificateurs de sauvegarde sur la fiche personnage.
--
-- `pe_init` : modificateur d'initiative, saisi. La fiche ne le calcule pas —
-- il dépend de dons, d'objets et de capacités de classe que la base ne modélise
-- pas (principe « aide de jeu, pas moteur de règles », §7.1).
--
-- `pe_*_save` : un modificateur de sauvegarde par caractéristique. Les six
-- colonnes existent dans les deux rulesets ; c'est l'AFFICHAGE qui diffère —
-- DD2024 les montre toutes les six à côté du modificateur de caractéristique,
-- DD3.5 n'en expose que trois, sous leurs noms de jets : Réflexes (DEX),
-- Vigueur (CON) et Volonté (SAG).
--
-- SMALLINT signé : un modificateur peut être négatif, et dépasser 127 n'a aucun
-- sens de toute façon. Défaut 0 — une fiche existante n'a rien à déclarer.

ALTER TABLE dd_personnages
  ADD COLUMN pe_init SMALLINT NOT NULL DEFAULT 0 AFTER pe_cha,
  ADD COLUMN pe_for_save SMALLINT NOT NULL DEFAULT 0 AFTER pe_init,
  ADD COLUMN pe_con_save SMALLINT NOT NULL DEFAULT 0 AFTER pe_for_save,
  ADD COLUMN pe_dex_save SMALLINT NOT NULL DEFAULT 0 AFTER pe_con_save,
  ADD COLUMN pe_int_save SMALLINT NOT NULL DEFAULT 0 AFTER pe_dex_save,
  ADD COLUMN pe_sag_save SMALLINT NOT NULL DEFAULT 0 AFTER pe_int_save,
  ADD COLUMN pe_cha_save SMALLINT NOT NULL DEFAULT 0 AFTER pe_sag_save;
