CREATE OR REPLACE FORCE VIEW STORICO_DATI_SOGGETTO
(NI, DAL, AL, COGNOME, NOME, 
 SESSO, DATA_NAS, PROVINCIA_NAS, COMUNE_NAS, LUOGO_NAS, 
 CODICE_FISCALE, CODICE_FISCALE_ESTERO, PARTITA_IVA, CITTADINANZA, GRUPPO_LING, 
 INDIRIZZO_RES, PROVINCIA_RES, COMUNE_RES, CAP_RES, TEL_RES, 
 FAX_RES, PRESSO, INDIRIZZO_DOM, PROVINCIA_DOM, COMUNE_DOM, 
 CAP_DOM, TEL_DOM, FAX_DOM, UTENTE, DATA_AGG, 
 COMPETENZA, COMPETENZA_ESCLUSIVA, TIPO_SOGGETTO, STATO_CEE, PARTITA_IVA_CEE, 
 FINE_VALIDITA, DENOMINAZIONE, INDIRIZZO_WEB, NOTE, REGIONE_NAS, 
 DEN_REGIONE_NAS, DEN_PROVINCIA_NAS, DEN_COMUNE_NAS, REGIONE_RES, DEN_REGIONE_RES, 
 DEN_PROVINCIA_RES, DEN_COMUNE_RES, REGIONE_DOM, DEN_REGIONE_DOM, DEN_PROVINCIA_DOM, 
 DEN_COMUNE_DOM)
BEQUEATH DEFINER
AS 
SELECT ni, dal, al, cognome, nome, sesso, data_nas, provincia_nas,
 comune_nas, luogo_nas, codice_fiscale, codice_fiscale_estero,
 partita_iva, cittadinanza, gruppo_ling, indirizzo_res,
 provincia_res, comune_res, cap_res, tel_res, fax_res, presso,
 indirizzo_dom, provincia_dom, comune_dom, cap_dom, tel_dom, fax_dom,
 utente, data_agg, competenza, competenza_esclusiva, tipo_soggetto,
 stato_cee, partita_iva_cee, fine_validita, denominazione,
 indirizzo_web, note,
 DECODE(provincia_nas, NULL, NULL, ad4_provincia.get_regione (provincia_nas)) regione_nas,
 DECODE(provincia_nas, NULL, NULL, ad4_regione.get_denominazione
  (ad4_provincia.get_regione (provincia_nas)
  )) den_regione_nas,
 ad4_provincia.get_denominazione (provincia_nas) den_provincia_nas,
 ad4_comune.get_denominazione (provincia_nas,
    comune_nas
   ) den_comune_nas,
 DECODE(provincia_res, NULL, NULL, ad4_provincia.get_regione (provincia_res)) regione_res,
 DECODE(provincia_res, NULL, NULL, ad4_regione.get_denominazione
  (ad4_provincia.get_regione (provincia_res)
  )) den_regione_res,
 ad4_provincia.get_denominazione (provincia_res) den_provincia_res,
 ad4_comune.get_denominazione (provincia_res,
    comune_res
   ) den_comune_res,
 DECODE(provincia_dom, NULL, NULL, ad4_provincia.get_regione (provincia_dom)) regione_dom,
 DECODE(provincia_dom, NULL, NULL, ad4_regione.get_denominazione
  (ad4_provincia.get_regione (provincia_dom)
  )) den_regione_dom,
 ad4_provincia.get_denominazione (provincia_dom) den_provincia_dom,
 ad4_comune.get_denominazione (provincia_dom,
    comune_dom
   ) den_comune_dom
  FROM anagrafe_soggetti sdso;


