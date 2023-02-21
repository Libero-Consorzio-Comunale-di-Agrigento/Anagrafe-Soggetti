CREATE OR REPLACE FORCE VIEW ANAGRAFICI_RES_DOM
(NI, DAL, AL, COGNOME, NOME, 
 SESSO, DATA_NAS, PROVINCIA_NAS, COMUNE_NAS, STATO_NAS, 
 LUOGO_NAS, CODICE_FISCALE, CODICE_FISCALE_ESTERO, PARTITA_IVA, CITTADINANZA, 
 GRUPPO_LING, COMPETENZA, COMPETENZA_ESCLUSIVA, TIPO_SOGGETTO, STATO_CEE, 
 PARTITA_IVA_CEE, FINE_VALIDITA, STATO_SOGGETTO, DENOMINAZIONE, NOTE_ANAG, 
 DESCRIZIONE_RESIDENZA, INDIRIZZO_RES, PROVINCIA_RES, COMUNE_RES, STATO_RES, 
 CAP_RES, PRESSO, IMPORTANZA, MAIL, NOTE_MAIL, 
 IMPORTANZA_MAIL, TEL_RES, NOTE_TEL_RES, IMPORTANZA_TEL_RES, FAX_RES, 
 NOTE_FAX_RES, IMPORTANZA_FAX_RES, DESCRIZIONE_DOM, INDIRIZZO_DOM, PROVINCIA_DOM, 
 COMUNE_DOM, STATO_DOM, CAP_DOM, TEL_DOM, NOTE_TEL_DOM, 
 IMPORTANZA_TEL_DOM, FAX_DOM, NOTE_FAX_DOM)
BEQUEATH DEFINER
AS 
SELECT ni,
          dal,
          al,
          cognome,
          nome,
          sesso,
          data_nas,
--          provincia_nas,
--          comune_nas,
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
          luogo_nas,
          codice_fiscale,
          codice_fiscale_estero,
          partita_iva,
          cittadinanza,
          gruppo_ling,
          competenza,
          competenza_esclusiva,
          tipo_soggetto,
          stato_cee,
          partita_iva_cee,
          fine_validita,
          CAST ('' AS VARCHAR2 (1)) stato_soggetto,
          denominazione,
          CAST ('' AS VARCHAR2 (2000)) note_anag,
          CAST ('' AS VARCHAR2 (2000)) descrizione_residenza,
          indirizzo_res,
--          provincia_res,
--          comune_res,
CASE WHEN s.provincia_res < 200 THEN s.provincia_res ELSE NULL END
             PROVINCIA_res,
          TO_NUMBER (
             DECODE (s.comune_res,
                     NULL, NULL,
                     s.provincia_nas || LPAD (s.comune_res, 4, 0)))
             COMUNE_res,
          CASE
             WHEN s.provincia_res < 200
             THEN
                100
             ELSE
                (SELECT stato_territorio
                   FROM ad4_stati_territori
                  WHERE stato_territorio = s.provincia_res)
          END
             STATO_res,
          cap_res,
          presso,
          1 importanza,
          indirizzo_web mail,
          CAST ('' AS VARCHAR2 (2000)) note_mail,
          1 importanza_mail,
          tel_res,
          CAST ('' AS VARCHAR2 (2000)) note_tel_res,
          1 importanza_tel_res,
          fax_res,
          CAST ('' AS VARCHAR2 (2000)) note_fax_res,
          1 importanza_fax_res,
          CAST ('' AS VARCHAR2 (2000)) descrizione_dom,
          indirizzo_dom,
--          provincia_dom,
--          comune_dom,
CASE WHEN s.provincia_dom < 200 THEN s.provincia_dom ELSE NULL END
             PROVINCIA_dom,
          TO_NUMBER (
             DECODE (s.comune_dom,
                     NULL, NULL,
                     s.provincia_dom || LPAD (s.comune_dom, 4, 0)))
             COMUNE_dom,
          CASE
             WHEN s.provincia_dom < 200
             THEN
                100
             ELSE
                (SELECT stato_territorio
                   FROM ad4_stati_territori
                  WHERE stato_territorio = s.provincia_dom)
          END
             STATO_dom,
          cap_dom,
          tel_dom,
          CAST ('' AS VARCHAR2 (2000)) note_tel_dom,
          CAST ('' AS NUMBER) importanza_tel_dom,
          fax_dom,
          CAST ('' AS VARCHAR2 (2000)) note_fax_dom
     FROM ANAGRAFE_SOGGETTI_TABLE s;


