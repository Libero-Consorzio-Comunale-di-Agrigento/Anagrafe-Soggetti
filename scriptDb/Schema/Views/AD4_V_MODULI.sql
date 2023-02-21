CREATE OR REPLACE FORCE VIEW AD4_V_MODULI
(MODULO, DESCRIZIONE, PROGETTO, NOTE)
BEQUEATH DEFINER
AS 
SELECT modulo,
          descrizione,
          progetto,
          note
     FROM AD4_MODULI;


