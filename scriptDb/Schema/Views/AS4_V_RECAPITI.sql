CREATE OR REPLACE FORCE VIEW AS4_V_RECAPITI
(ID_RECAPITO, NI, DAL, AL, DESCRIZIONE, 
 ID_TIPO_RECAPITO, INDIRIZZO, PROVINCIA, COMUNE, STATO, 
 CAP, PRESSO, IMPORTANZA, COMPETENZA, COMPETENZA_ESCLUSIVA, 
 VERSION, UTENTE_AGGIORNAMENTO, DATA_AGGIORNAMENTO)
BEQUEATH DEFINER
AS 
SELECT ID_RECAPITO,
          NI,
          DAL,
          AL,
          DESCRIZIONE,
          ID_TIPO_RECAPITO,
          INDIRIZZO,
          CASE WHEN provincia < 200 THEN provincia ELSE NULL END PROVINCIA,
          TO_NUMBER (
             DECODE (comune, NULL, NULL, provincia || LPAD (comune, 4, 0)))
             COMUNE,
          CASE
             WHEN s.provincia < 200
             THEN
                100
             ELSE
                (SELECT stato_territorio
                   FROM ad4_stati_territori
                  WHERE stato_territorio = s.provincia)
          END
             STATO,
          CAP,
          PRESSO,
          IMPORTANZA,
          COMPETENZA,
          COMPETENZA_ESCLUSIVA,
          VERSION,
          UTENTE_AGGIORNAMENTO,
          DATA_AGGIORNAMENTO
     FROM AS4_RECAPITI s;


