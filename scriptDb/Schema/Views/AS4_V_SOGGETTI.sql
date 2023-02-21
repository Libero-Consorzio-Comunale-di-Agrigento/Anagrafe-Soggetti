CREATE OR REPLACE FORCE VIEW AS4_V_SOGGETTI
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
SELECT s.NI,
           a.dal,                                                     --s.DAL,
           s.COGNOME,
           s.NOME,
           -- modifica per gestione delle denominazioni degli elementi di struttura
           --          DECODE (anagrafici_pkg.get_denominazione_ricerca (s.ni, a.dal),
           --                  NULL, S.COGNOME || ' ' || S.NOME,
           --                  anagrafici_pkg.get_denominazione_ricerca (s.ni, a.dal))
           --             NOMINATIVO_RICERCA,
           -- modificata il 12/02/2019 x ricercare sul campo nominativo_ricerca usando la tabella anagrafici e non usando la funzione
           -- modificata il 26/04/2021 x usare sempre denominazione_ricerca x prestazioni Bug #48865
--           DECODE (
--               denominazione_ricerca,
--               /* modifica per bug #40400*/
--               NULL, S.COGNOME || DECODE (s.nome, NULL, NULL, ' ' || S.NOME),
--               denominazione_ricerca)
           -- modificata il 26/04/2021 x usare sempre denominazione_ricerca x prestazioni Bug #48865
           denominazione_ricerca   NOMINATIVO_RICERCA,
           s.SESSO,
           s.DATA_NAS,
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
           s.LUOGO_NAS,
           DECODE (
               s.CODICE_FISCALE,
               NULL, DECODE (s.codice_fiscale_estero,
                             NULL, NULL,
                             s.codice_fiscale_estero || ' (estero)'),
               s.codice_fiscale)
               codidce_fiscale,
           s.CODICE_FISCALE_ESTERO,
           DECODE (
               s.PARTITA_IVA,
               NULL, DECODE (s.PARTITA_IVA_CEE,
                             NULL, NULL,
                             s.PARTITA_IVA_CEE || ' (estera)'),
               s.PARTITA_IVA)
               PARTITA_IVA,
           s.CITTADINANZA,
           s.GRUPPO_LING,
           s.INDIRIZZO_RES,
           CASE WHEN s.provincia_res < 200 THEN s.provincia_res ELSE NULL END
               PROVINCIA_RES,
           TO_NUMBER (
               DECODE (s.comune_res,
                       NULL, NULL,
                       s.provincia_res || LPAD (s.comune_res, 4, 0)))
               COMUNE_RES,
           CASE
               WHEN s.provincia_res < 200
               THEN
                   100
               ELSE
                   (SELECT stato_territorio
                      FROM ad4_stati_territori
                     WHERE stato_territorio = s.provincia_res)
           END
               STATO_RES,
           s.CAP_RES,
           s.TEL_RES,
           s.FAX_RES,
           s.PRESSO,
           s.INDIRIZZO_DOM,
           CASE WHEN s.provincia_dom < 200 THEN s.provincia_dom ELSE NULL END
               PROVINCIA_DOM,
           TO_NUMBER (
               DECODE (s.comune_dom,
                       NULL, NULL,
                       s.provincia_dom || LPAD (s.comune_dom, 4, 0)))
               COMUNE_DOM,
           CASE
               WHEN s.provincia_dom < 200
               THEN
                   100
               ELSE
                   (SELECT stato_territorio
                      FROM ad4_stati_territori
                     WHERE stato_territorio = s.provincia_dom)
           END
               STATO_DOM,
           s.CAP_DOM,
           s.TEL_DOM,
           s.FAX_DOM,
           s.UTENTE
               UTENTE_AGG,
           s.DATA_AGG,
           s.COMPETENZA,
           s.COMPETENZA_ESCLUSIVA,
           s.TIPO_SOGGETTO,
           s.FLAG_TRG,
           s.STATO_CEE,
           s.PARTITA_IVA_CEE,
           s.FINE_VALIDITA,
           a.al,                                                       --s.AL,
           s.DENOMINAZIONE,
           s.INDIRIZZO_WEB,
           s.NOTE,
           ad4_utente.get_utente (s.ni)
               UTENTE
      FROM AS4_ANAGRAFE_SOGGETTI s, anagrafici a
     WHERE     s.ni = a.ni
           AND s.dal BETWEEN a.dal AND NVL (a.al, SYSDATE + 1000)
           AND NOT EXISTS
                   (SELECT 1
                      FROM anagrafe_soggetti_table
                     WHERE     ni = s.ni
                           AND dal > s.dal
                           AND dal BETWEEN a.dal
                                       AND NVL (a.al, SYSDATE + 1000));


