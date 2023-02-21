CREATE OR REPLACE FORCE VIEW ANAGRAFE_SOGGETTI_VIEW
("rowid", ID_ANAGRAFICA, NI, DAL, COGNOME, 
 NOME, SESSO, DATA_NAS, PROVINCIA_NAS, COMUNE_NAS, 
 LUOGO_NAS, CODICE_FISCALE, CODICE_FISCALE_ESTERO, PARTITA_IVA, CITTADINANZA, 
 GRUPPO_LING, INDIRIZZO_RES, PROVINCIA_RES, COMUNE_RES, CAP_RES, 
 TEL_RES, FAX_RES, PRESSO, INDIRIZZO_DOM, PROVINCIA_DOM, 
 COMUNE_DOM, CAP_DOM, TEL_DOM, FAX_DOM, UTENTE, 
 DATA_AGG, COMPETENZA, COMPETENZA_ESCLUSIVA, TIPO_SOGGETTO, FLAG_TRG, 
 STATO_CEE, PARTITA_IVA_CEE, FINE_VALIDITA, AL, DENOMINAZIONE, 
 INDIRIZZO_WEB, NOTE, VERSION)
BEQUEATH DEFINER
AS 
SELECT anag.ROWID,
          anag.id_anagrafica,
          tutti.ni,
          tutti.dal,
          COGNOME,
          NOME,
          SESSO,
          DATA_NAS,
          PROVINCIA_NAS,
          COMUNE_NAS,
          LUOGO_NAS,
          CODICE_FISCALE,
          CODICE_FISCALE_ESTERO,
          PARTITA_IVA,
          CITTADINANZA,
          GRUPPO_LING,
          anagrafici_pkg.get_recapito_info (tutti.ni,
                                            tutti.dal,
                                            'INDIRIZZO',
                                            'RES')
             INDIRIZZO_RES,
          anagrafici_pkg.get_recapito_info (tutti.ni,
                                            tutti.dal,
                                            'PROVINCIA',
                                            'RES')
             PROVINCIA_RES,
          anagrafici_pkg.get_recapito_info (tutti.ni,
                                            tutti.dal,
                                            'COMUNE',
                                            'RES')
             COMUNE_RES,
          anagrafici_pkg.get_recapito_info (tutti.ni,
                                            tutti.dal,
                                            'CAP',
                                            'RES')
             CAP_RES,
          anagrafici_pkg.get_contatto_info (tutti.ni,
                                            tutti.dal,
                                            'TELEFONO',
                                            'RES')
             TEL_RES,
          anagrafici_pkg.get_contatto_info (tutti.ni,
                                            tutti.dal,
                                            'FAX',
                                            'RES')
             FAX_RES,
          anagrafici_pkg.get_recapito_info (tutti.ni,
                                            tutti.dal,
                                            'PRESSO',
                                            'RES')
             PRESSO,
          anagrafici_pkg.get_recapito_info (tutti.ni,
                                            tutti.dal,
                                            'INDIRIZZO',
                                            'DOM')
             INDIRIZZO_DOM,
          anagrafici_pkg.get_recapito_info (tutti.ni,
                                            tutti.dal,
                                            'PROVINCIA',
                                            'DOM')
             PROVINCIA_DOM,
          anagrafici_pkg.get_recapito_info (tutti.ni,
                                            tutti.dal,
                                            'COMUNE',
                                            'DOM')
             COMUNE_DOM,
          anagrafici_pkg.get_recapito_info (tutti.ni,
                                            tutti.dal,
                                            'CAP',
                                            'DOM')
             CAP_DOM,
          anagrafici_pkg.get_contatto_info (tutti.ni,
                                            tutti.dal,
                                            'TELEFONO',
                                            'DOM')
             TEL_DOM,
          anagrafici_pkg.get_contatto_info (tutti.ni,
                                            tutti.dal,
                                            'FAX',
                                            'DOM')
             FAX_DOM,
          UTENTE,
          DATA_AGG,
          COMPETENZA,
          COMPETENZA_ESCLUSIVA,
          TIPO_SOGGETTO,
          CAST ('' AS VARCHAR2 (1)) FLAG_TRG,
          STATO_CEE,
          PARTITA_IVA_CEE,
          FINE_VALIDITA,
          anagrafici_pkg.get_ultimo_al (tutti.ni, tutti.dal, anag.al) AL,
          DENOMINAZIONE,
          anagrafici_pkg.get_contatto_info (tutti.ni,
                                            tutti.dal,
                                            'MAIL',
                                            'RES')
             INDIRIZZO_WEB,                                                 --
          NOTE,
          VERSION
     --tutti.tutti.ni, tutti.tutti.dal,anag.cognome, anag.nome
     FROM TUTTI_NI_DAL_RES_DOM_OK tutti, anagrafici anag
    WHERE     tutti.ni = anag.ni
          AND tutti.dal BETWEEN anag.dal
                            AND NVL (
                                   anagrafici_pkg.get_ultimo_al (tutti.ni,
                                                                 tutti.dal,
                                                                 anag.al),
                                   TO_DATE ('3333333', 'j'))  
          AND tutti.dal BETWEEN anag.dal
                            AND NVL (anag.al, TO_DATE ('3333333', 'j'));


