CREATE OR REPLACE FORCE VIEW XX4_ANAGRAFE_SOGGETTI
(NI, DAL, MOTIVO_BLOCCO, OGGETTO)
BEQUEATH DEFINER
AS 
select to_number(null) ni, to_date(null) dal, to_char(null) motivo_blocco, to_char(null) oggetto
  from tipi_soggetto
 where tipo_soggetto = ' ';

COMMENT ON COLUMN XX4_ANAGRAFE_SOGGETTI.MOTIVO_BLOCCO IS 'Record = nessun campo modificabile; Chiave = campi chiave non modificabili; Tutti = tutti campi non modificabili tranne al (ok storicizzazione); Denominazione = T + ok storicizzazione se nuova e vecchia denominazione sono uguali.';



