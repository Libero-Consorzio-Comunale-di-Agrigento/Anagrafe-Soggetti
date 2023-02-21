CREATE OR REPLACE FORCE VIEW AS4_V_ANAGRAFICI
(ID_ANAGRAFICA, NI, DAL, AL, COGNOME, 
 NOME, SESSO, DATA_NAS, PROVINCIA_NAS, COMUNE_NAS, 
 STATO_NAS, LUOGO_NAS, CODICE_FISCALE, CODICE_FISCALE_ESTERO, PARTITA_IVA, 
 CITTADINANZA, GRUPPO_LING, COMPETENZA, COMPETENZA_ESCLUSIVA, TIPO_SOGGETTO, 
 STATO_CEE, PARTITA_IVA_CEE, FINE_VALIDITA, STATO_SOGGETTO, DENOMINAZIONE, 
 NOTE, VERSION, UTENTE, DATA_AGG, DENOMINAZIONE_RICERCA)
BEQUEATH DEFINER
AS 
SELECT "ID_ANAGRAFICA",
          "NI",
          "DAL",
          "AL",
          "COGNOME",
          "NOME",
          "SESSO",
          "DATA_NAS",
          CASE WHEN s.provincia_nas < 200 THEN s.provincia_nas ELSE NULL END
             PROVINCIA_NAS,
          TO_NUMBER (
             DECODE (s.comune_nas,
                     NULL, NULL,
                     s.provincia_nas || LPAD (s.comune_nas, 4, 0)))
             COMUNE_NAS,
          CASE
             WHEN s.provincia_nas < 200
             THEN
                100
             ELSE
                (SELECT stato_territorio
                   FROM ad4_stati_territori
                  WHERE stato_territorio = s.provincia_nas)
          END
             STATO_NAS,
          "LUOGO_NAS",
          "CODICE_FISCALE",
          "CODICE_FISCALE_ESTERO",
          "PARTITA_IVA",
          "CITTADINANZA",
          "GRUPPO_LING",
          "COMPETENZA",
          "COMPETENZA_ESCLUSIVA",
          "TIPO_SOGGETTO",
          "STATO_CEE",
          "PARTITA_IVA_CEE",
          "FINE_VALIDITA",
          "STATO_SOGGETTO",
          "DENOMINAZIONE",
          "NOTE",
          "VERSION",
          "UTENTE",
          "DATA_AGG",
          "DENOMINAZIONE_RICERCA"
     FROM as4_anagrafici s;


