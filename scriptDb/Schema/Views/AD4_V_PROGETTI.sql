CREATE OR REPLACE FORCE VIEW AD4_V_PROGETTI
(PROGETTO, DESCRIZIONE, PRIORITA, NOTE)
BEQUEATH DEFINER
AS 
SELECT p.progetto,
          p.descrizione,
          p.priorita,
          p.note
     FROM AD4_PROGETTI p;


