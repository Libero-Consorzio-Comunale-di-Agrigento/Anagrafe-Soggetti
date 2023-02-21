CREATE OR REPLACE FORCE VIEW AD4_V_PROVINCE
(PROVINCIA, DENOMINAZIONE, DENOMINAZIONE_AL1, DENOMINAZIONE_AL2, REGIONE, 
 SIGLA, UTENTE_AGGIORNAMENTO, DATA_AGGIORNAMENTO)
BEQUEATH DEFINER
AS 
SELECT PROVINCIA,
          DENOMINAZIONE,
          DENOMINAZIONE_AL1,
          DENOMINAZIONE_AL2,
          REGIONE,
          SIGLA,
          UTENTE_AGGIORNAMENTO,
          DATA_AGGIORNAMENTO
     FROM AD4_PROVINCE;


