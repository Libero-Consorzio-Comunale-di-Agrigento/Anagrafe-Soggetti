CREATE OR REPLACE package as4_v_soggetti_correnti_tpk is /* MASTER_LINK */
/******************************************************************************
 NOME:        as4_v_soggetti_correnti_tpk
 DESCRIZIONE: Gestione tabella AS4_V_SOGGETTI_CORRENTI.
 ANNOTAZIONI: .
 REVISIONI:   Table Revision: 29/05/2018 10:34:00
              SiaPKGen Revision: .
              SiaTPKDeclare Revision: .
 <CODE>
 Rev.  Data        Autore      Descrizione.
 00    29/05/2018  SNegroni  Generazione automatica. 
 </CODE>
******************************************************************************/
   -- Revisione del Package
   s_revisione constant AFC.t_revision := 'V1.00';
   s_table_name constant AFC.t_object_name := 'AS4_V_SOGGETTI_CORRENTI';
   subtype t_rowtype is AS4_V_SOGGETTI_CORRENTI%rowtype;
   -- Versione e revisione
   function versione /* SLAVE_COPY */
   return varchar2;
   pragma restrict_references( versione, WNDS );
   -- where_condition per statement di ricerca
   function where_condition /* SLAVE_COPY */
   ( p_QBE  in number default 0
   , p_other_condition in varchar2 default null
   , p_ni  in varchar2 default null
   , p_dal  in varchar2 default null
   , p_cognome  in varchar2 default null
   , p_nome  in varchar2 default null
   , p_nominativo_ricerca  in varchar2 default null
   , p_sesso  in varchar2 default null
   , p_data_nas  in varchar2 default null
   , p_provincia_nas  in varchar2 default null
   , p_comune_nas  in varchar2 default null
   , p_stato_nas  in varchar2 default null
   , p_luogo_nas  in varchar2 default null
   , p_codice_fiscale  in varchar2 default null
   , p_codice_fiscale_estero  in varchar2 default null
   , p_partita_iva  in varchar2 default null
   , p_cittadinanza  in varchar2 default null
   , p_gruppo_ling  in varchar2 default null
   , p_indirizzo_res  in varchar2 default null
   , p_provincia_res  in varchar2 default null
   , p_comune_res  in varchar2 default null
   , p_stato_res  in varchar2 default null
   , p_cap_res  in varchar2 default null
   , p_tel_res  in varchar2 default null
   , p_fax_res  in varchar2 default null
   , p_presso  in varchar2 default null
   , p_indirizzo_dom  in varchar2 default null
   , p_provincia_dom  in varchar2 default null
   , p_comune_dom  in varchar2 default null
   , p_stato_dom  in varchar2 default null
   , p_cap_dom  in varchar2 default null
   , p_tel_dom  in varchar2 default null
   , p_fax_dom  in varchar2 default null
   , p_utente_agg  in varchar2 default null
   , p_data_agg  in varchar2 default null
   , p_competenza  in varchar2 default null
   , p_competenza_esclusiva  in varchar2 default null
   , p_tipo_soggetto  in varchar2 default null
   , p_flag_trg  in varchar2 default null
   , p_stato_cee  in varchar2 default null
   , p_partita_iva_cee  in varchar2 default null
   , p_fine_validita  in varchar2 default null
   , p_al  in varchar2 default null
   , p_denominazione  in varchar2 default null
   , p_indirizzo_web  in varchar2 default null
   , p_note  in varchar2 default null
   , p_utente  in varchar2 default null
   ) return AFC.t_statement;
   -- righe corrispondenti alla selezione indicata
   function get_rows  /*+ SOA  */ /* SLAVE_COPY */
   ( p_QBE  in number default 0
   , p_other_condition in varchar2 default null
   , p_order_by in varchar2 default null
   , p_extra_columns in varchar2 default null
   , p_extra_condition in varchar2 default null
   , p_columns in varchar2 default null
   , p_offset in number default null
   , p_limit in number default null
   , p_ni  in varchar2 default null
   , p_dal  in varchar2 default null
   , p_cognome  in varchar2 default null
   , p_nome  in varchar2 default null
   , p_nominativo_ricerca  in varchar2 default null
   , p_sesso  in varchar2 default null
   , p_data_nas  in varchar2 default null
   , p_provincia_nas  in varchar2 default null
   , p_comune_nas  in varchar2 default null
   , p_stato_nas  in varchar2 default null
   , p_luogo_nas  in varchar2 default null
   , p_codice_fiscale  in varchar2 default null
   , p_codice_fiscale_estero  in varchar2 default null
   , p_partita_iva  in varchar2 default null
   , p_cittadinanza  in varchar2 default null
   , p_gruppo_ling  in varchar2 default null
   , p_indirizzo_res  in varchar2 default null
   , p_provincia_res  in varchar2 default null
   , p_comune_res  in varchar2 default null
   , p_stato_res  in varchar2 default null
   , p_cap_res  in varchar2 default null
   , p_tel_res  in varchar2 default null
   , p_fax_res  in varchar2 default null
   , p_presso  in varchar2 default null
   , p_indirizzo_dom  in varchar2 default null
   , p_provincia_dom  in varchar2 default null
   , p_comune_dom  in varchar2 default null
   , p_stato_dom  in varchar2 default null
   , p_cap_dom  in varchar2 default null
   , p_tel_dom  in varchar2 default null
   , p_fax_dom  in varchar2 default null
   , p_utente_agg  in varchar2 default null
   , p_data_agg  in varchar2 default null
   , p_competenza  in varchar2 default null
   , p_competenza_esclusiva  in varchar2 default null
   , p_tipo_soggetto  in varchar2 default null
   , p_flag_trg  in varchar2 default null
   , p_stato_cee  in varchar2 default null
   , p_partita_iva_cee  in varchar2 default null
   , p_fine_validita  in varchar2 default null
   , p_al  in varchar2 default null
   , p_denominazione  in varchar2 default null
   , p_indirizzo_web  in varchar2 default null
   , p_note  in varchar2 default null
   , p_utente  in varchar2 default null
   ) return AFC.t_ref_cursor;
   -- Numero di righe corrispondente alla selezione indicata
   -- Almeno un attributo deve essere valido (non null)
   function count_rows /* SLAVE_COPY */
   ( p_QBE in number default 0
   , p_other_condition in varchar2 default null
   , p_extra_condition in varchar2 default null
   , p_columns in varchar2 default null
   , p_ni  in varchar2 default null
   , p_dal  in varchar2 default null
   , p_cognome  in varchar2 default null
   , p_nome  in varchar2 default null
   , p_nominativo_ricerca  in varchar2 default null
   , p_sesso  in varchar2 default null
   , p_data_nas  in varchar2 default null
   , p_provincia_nas  in varchar2 default null
   , p_comune_nas  in varchar2 default null
   , p_stato_nas  in varchar2 default null
   , p_luogo_nas  in varchar2 default null
   , p_codice_fiscale  in varchar2 default null
   , p_codice_fiscale_estero  in varchar2 default null
   , p_partita_iva  in varchar2 default null
   , p_cittadinanza  in varchar2 default null
   , p_gruppo_ling  in varchar2 default null
   , p_indirizzo_res  in varchar2 default null
   , p_provincia_res  in varchar2 default null
   , p_comune_res  in varchar2 default null
   , p_stato_res  in varchar2 default null
   , p_cap_res  in varchar2 default null
   , p_tel_res  in varchar2 default null
   , p_fax_res  in varchar2 default null
   , p_presso  in varchar2 default null
   , p_indirizzo_dom  in varchar2 default null
   , p_provincia_dom  in varchar2 default null
   , p_comune_dom  in varchar2 default null
   , p_stato_dom  in varchar2 default null
   , p_cap_dom  in varchar2 default null
   , p_tel_dom  in varchar2 default null
   , p_fax_dom  in varchar2 default null
   , p_utente_agg  in varchar2 default null
   , p_data_agg  in varchar2 default null
   , p_competenza  in varchar2 default null
   , p_competenza_esclusiva  in varchar2 default null
   , p_tipo_soggetto  in varchar2 default null
   , p_flag_trg  in varchar2 default null
   , p_stato_cee  in varchar2 default null
   , p_partita_iva_cee  in varchar2 default null
   , p_fine_validita  in varchar2 default null
   , p_al  in varchar2 default null
   , p_denominazione  in varchar2 default null
   , p_indirizzo_web  in varchar2 default null
   , p_note  in varchar2 default null
   , p_utente  in varchar2 default null
   ) return integer;
end as4_v_soggetti_correnti_tpk;
/

