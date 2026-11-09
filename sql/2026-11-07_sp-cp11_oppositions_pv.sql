-- ============================================================
-- SP-CP11 — Suivi des PV des oppositions d'une rencontre
-- 2026-11-07 — arbitrage D-CP13 / D-CP14 (doc/DECISIONS_LOG.md)
-- ============================================================
-- 1. dd_oppositions reçoit l'effectif (opp_nombre) et les PV max d'une
--    créature (opp_pv_max). Jusqu'ici, ces deux données n'existaient qu'en
--    texte libre (nom, bloc de stats).
-- 2. dd_oppositions_pv garde les PV courants des créatures ENTAMÉES, une ligne
--    par créature (rang 1..opp_nombre). Ligne absente = PV max.
-- 3. opp_pv_max est pré-rempli d'après la ligne « PV » du bloc de stats
--    (« PV : 42 chacun (5 DV) », « Pv 81 (18d8) »…). Les oppositions où rien
--    n'est trouvé restent à NULL ; la page relit alors les stats à l'affichage
--    (pvMaxDepuisStats(), include/helpers.php).
-- NON IDEMPOTENT (ALTER TABLE) : jouée une seule fois par le moteur de migrations.

ALTER TABLE dd_oppositions
  ADD COLUMN opp_nombre tinyint(3) unsigned NOT NULL DEFAULT 1
    COMMENT 'Effectif : nombre de créatures identiques (SP-CP11)' AFTER opp_stats,
  ADD COLUMN opp_pv_max smallint(5) unsigned DEFAULT NULL
    COMMENT 'PV max d''une créature. NULL = lus dans opp_stats à l''affichage (SP-CP11)' AFTER opp_nombre;

CREATE TABLE dd_oppositions_pv (
  opv_opp_id int(10) unsigned NOT NULL COMMENT '-> dd_oppositions',
  opv_rang   tinyint(3) unsigned NOT NULL COMMENT 'N° de la créature dans l''opposition (1..opp_nombre)',
  opv_pv     smallint(6) NOT NULL COMMENT 'PV courants (négatifs admis)',
  PRIMARY KEY (opv_opp_id, opv_rang),
  CONSTRAINT fk_opv_opp FOREIGN KEY (opv_opp_id) REFERENCES dd_oppositions (opp_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='PV courants des créatures entamées d''une opposition (SP-CP11)';

UPDATE dd_oppositions
   SET opp_pv_max = CAST(REGEXP_SUBSTR(REGEXP_SUBSTR(opp_stats, '[Pp][Vv] *:? *[0-9]+'), '[0-9]+') AS UNSIGNED)
 WHERE opp_pv_max IS NULL
   AND opp_stats REGEXP '[Pp][Vv] *:? *[0-9]+';
