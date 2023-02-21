CREATE OR REPLACE FORCE VIEW AS4_V_ANAGRAFICI_STRUTTURA
(NI, DAL, COGNOME, NOME, NOMINATIVO_RICERCA, 
 SESSO, DATA_NAS, PROVINCIA_NAS, COMUNE_NAS, STATO_NAS, 
 LUOGO_NAS, CODICE_FISCALE, CODICE_FISCALE_ESTERO, PARTITA_IVA, CITTADINANZA, 
 GRUPPO_LING, INDIRIZZO_RES, PROVINCIA_RES, COMUNE_RES, STATO_RES, 
 CAP_RES, TEL_RES, FAX_RES, PRESSO, INDIRIZZO_DOM, 
 PROVINCIA_DOM, COMUNE_DOM, STATO_DOM, CAP_DOM, TEL_DOM, 
 FAX_DOM, UTENTE_AGG, DATA_AGG, COMPETENZA, COMPETENZA_ESCLUSIVA, 
 TIPO_SOGGETTO, FLAG_TRG, STATO_CEE, PARTITA_IVA_CEE, FINE_VALIDITA, 
 AL, DENOMINAZIONE, INDIRIZZO_WEB, NOTE, UTENTE)
BEQUEATH DEFINER
AS 
SELECT a."NI",a."DAL",a."COGNOME",a."NOME",a."NOMINATIVO_RICERCA",a."SESSO",a."DATA_NAS",a."PROVINCIA_NAS",a."COMUNE_NAS",a."STATO_NAS",a."LUOGO_NAS",a."CODICE_FISCALE",a."CODICE_FISCALE_ESTERO",a."PARTITA_IVA",a."CITTADINANZA",a."GRUPPO_LING",a."INDIRIZZO_RES",a."PROVINCIA_RES",a."COMUNE_RES",a."STATO_RES",a."CAP_RES",a."TEL_RES",a."FAX_RES",a."PRESSO",a."INDIRIZZO_DOM",a."PROVINCIA_DOM",a."COMUNE_DOM",a."STATO_DOM",a."CAP_DOM",a."TEL_DOM",a."FAX_DOM",a."UTENTE_AGG",a."DATA_AGG",a."COMPETENZA",a."COMPETENZA_ESCLUSIVA",a."TIPO_SOGGETTO",a."FLAG_TRG",a."STATO_CEE",a."PARTITA_IVA_CEE",a."FINE_VALIDITA",a."AL",a."DENOMINAZIONE",a."INDIRIZZO_WEB",a."NOTE",a."UTENTE"
      FROM as4_v_soggetti_correnti a
     WHERE 1=2 -- non esiste struttura organizzativa
;

