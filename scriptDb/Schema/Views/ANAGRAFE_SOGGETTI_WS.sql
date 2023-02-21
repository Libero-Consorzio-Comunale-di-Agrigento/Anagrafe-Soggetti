CREATE OR REPLACE FORCE VIEW ANAGRAFE_SOGGETTI_WS
(NI, DAL, COGNOME, NOME, NOMINATIVO_RICERCA, 
 SESSO, DATA_NAS, PROVINCIA_NAS, COMUNE_NAS, STATO_NAS, 
 LUOGO_NAS, CODICE_FISCALE, CODICE_FISCALE_ESTERO, PARTITA_IVA, CITTADINANZA, 
 GRUPPO_LING, INDIRIZZO_RES, PROVINCIA_RES, COMUNE_RES, STATO_RES, 
 CAP_RES, PRESSO, ID_RECAPITO_RES, TEL_RES, ID_CONTATTO_TEL_RES, 
 FAX_RES, ID_CONTATTO_FAX_RES, INDIRIZZO_DOM, PROVINCIA_DOM, COMUNE_DOM, 
 STATO_DOM, CAP_DOM, ID_RECAPITO_DOM, TEL_DOM, ID_CONTATTO_TEL_DOM, 
 FAX_DOM, ID_CONTATTO_FAX_DOM, UTENTE_AGG, DATA_AGG, COMPETENZA, 
 COMPETENZA_ESCLUSIVA, TIPO_SOGGETTO, FLAG_TRG, STATO_CEE, PARTITA_IVA_CEE, 
 FINE_VALIDITA, AL, DENOMINAZIONE, INDIRIZZO_WEB, ID_CONTATTO_INDIRIZZO_WEB, 
 NOTE, UTENTE)
BEQUEATH DEFINER
AS 
select ni
      ,dal
      ,cognome
      ,nome
      ,nominativo_ricerca
      ,sesso
      ,data_nas
      ,provincia_nas
      ,comune_nas
      ,stato_nas
      ,luogo_nas
      ,codice_fiscale
      ,codice_fiscale_estero
      ,partita_iva
      ,cittadinanza
      ,gruppo_ling
      ,indirizzo_res
      ,provincia_res
      ,comune_res
      ,stato_res
      ,cap_res
      ,presso
      ,anagrafe_soggetti_ws_pkg.get_id_recapito_res(ni, dal) id_recapito_res
      ,tel_res
      ,(select max(id_contatto)
          from contatti
         where id_recapito =
               (select anagrafe_soggetti_ws_pkg.get_id_recapito_res(ni, dal) from dual)
           and id_tipo_contatto = (select id_tipo_contatto
                                     from tipi_contatto tc
                                    where tc.descrizione = 'TELEFONO')
           and sysdate between dal and nvl(al, to_date(3333333, 'J'))) id_contatto_tel_res --#58310
      ,fax_res
      ,(select max(id_contatto)
          from contatti
         where id_recapito =
               (select anagrafe_soggetti_ws_pkg.get_id_recapito_res(ni, dal) from dual)
           and id_tipo_contatto =
               (select id_tipo_contatto from tipi_contatto tc where tc.descrizione = 'FAX')
           and sysdate between dal and nvl(al, to_date(3333333, 'J'))) id_contatto_fax_res --#58310
      ,indirizzo_dom
      ,provincia_dom
      ,comune_dom
      ,stato_dom
      ,cap_dom
      ,anagrafe_soggetti_ws_pkg.get_id_recapito_dom(ni, dal) id_recapito_dom
      ,tel_dom
      ,(select max(id_contatto)
          from contatti
         where id_recapito =
               (select anagrafe_soggetti_ws_pkg.get_id_recapito_dom(ni, dal) from dual)
           and id_tipo_contatto = (select id_tipo_contatto
                                     from tipi_contatto tc
                                    where tc.descrizione = 'TELEFONO')
           and sysdate between dal and nvl(al, to_date(3333333, 'J'))) id_contatto_tel_dom --#58310
      ,fax_dom
      ,(select max(id_contatto)
          from contatti
         where id_recapito =
               (select anagrafe_soggetti_ws_pkg.get_id_recapito_dom(ni, dal) from dual)
           and id_tipo_contatto =
               (select id_tipo_contatto from tipi_contatto tc where tc.descrizione = 'FAX')
           and sysdate between dal and nvl(al, to_date(3333333, 'J'))) id_contatto_fax_dom  --#58310
      ,utente_agg
      ,data_agg
      ,competenza
      ,competenza_esclusiva
      ,tipo_soggetto
      ,flag_trg
      ,stato_cee
      ,partita_iva_cee
      ,fine_validita
      ,al
      ,denominazione
      ,indirizzo_web
      ,(select min(id_contatto) --#52435
          from contatti
         where id_recapito =
               (select anagrafe_soggetti_ws_pkg.get_id_recapito_res(ni, dal) from dual)
           and id_tipo_contatto = (select id_tipo_contatto
                                     from tipi_contatto tc
                                    where tc.descrizione = 'MAIL')
           and sysdate between dal and nvl(al, to_date(3333333, 'J'))) id_contatto_indirizzo_web
      ,note
      ,utente
  from as4_v_soggetti_correnti;


