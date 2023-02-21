CREATE OR REPLACE package body as4_v_soggetti_correnti_tpk is
/******************************************************************************
 NOME:        as4_v_soggetti_correnti_tpk
 DESCRIZIONE: Gestione tabella AS4_V_SOGGETTI_CORRENTI.
 ANNOTAZIONI: .
 REVISIONI:   .
 Rev.  Data        Autore      Descrizione.
 000   29/05/2018  SNegroni  Generazione automatica. 
******************************************************************************/
   s_revisione_body      constant AFC.t_revision := '000 - 29/05/2018';
--------------------------------------------------------------------------------
function versione
return varchar2 is /* SLAVE_COPY */
/******************************************************************************
 NOME:        versione
 DESCRIZIONE: Versione e revisione di distribuzione del package.
 RITORNA:     varchar2 stringa contenente versione e revisione.
 NOTE:        Primo numero  : versione compatibilita del Package.
              Secondo numero: revisione del Package specification.
              Terzo numero  : revisione del Package body.
******************************************************************************/
begin
   return AFC.version ( s_revisione, s_revisione_body );
end versione; -- as4_v_soggetti_correnti_tpk.versione
--------------------------------------------------------------------------------
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
) return AFC.t_statement is /* SLAVE_COPY */
/******************************************************************************
 NOME:        where_condition
 DESCRIZIONE: Ritorna la where_condition per lo statement di select di get_rows e count_rows. 
 PARAMETRI:   p_QBE 0: viene controllato se all'inizio di ogni attributo e presente
                       un operatore, altrimenti viene usato quello di default ('=')
                    1: viene utilizzato l'operatore specificato all'inizio di ogni
                       attributo.
              p_other_condition: condizioni aggiuntive di base
              Chiavi e attributi della table
 RITORNA:     AFC.t_statement.
 NOTE:        Se p_QBE = 1 , ogni parametro deve contenere, nella prima parte,
              l'operatore da utilizzare nella where-condition.
******************************************************************************/
   d_statement AFC.t_statement;
begin
   d_statement := ' where ( 1 = 1 '
               || AFC.get_field_condition( ' and ( ni ', p_ni , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( dal ', p_dal , ' )', p_QBE, AFC.date_format )
               || AFC.get_field_condition( ' and ( cognome ', p_cognome , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( nome ', p_nome , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( nominativo_ricerca ', p_nominativo_ricerca , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( sesso ', p_sesso , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( data_nas ', p_data_nas , ' )', p_QBE, AFC.date_format )
               || AFC.get_field_condition( ' and ( provincia_nas ', p_provincia_nas , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( comune_nas ', p_comune_nas , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( stato_nas ', p_stato_nas , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( luogo_nas ', p_luogo_nas , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( codice_fiscale ', p_codice_fiscale , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( codice_fiscale_estero ', p_codice_fiscale_estero , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( partita_iva ', p_partita_iva , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( cittadinanza ', p_cittadinanza , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( gruppo_ling ', p_gruppo_ling , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( indirizzo_res ', p_indirizzo_res , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( provincia_res ', p_provincia_res , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( comune_res ', p_comune_res , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( stato_res ', p_stato_res , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( cap_res ', p_cap_res , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( tel_res ', p_tel_res , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( fax_res ', p_fax_res , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( presso ', p_presso , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( indirizzo_dom ', p_indirizzo_dom , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( provincia_dom ', p_provincia_dom , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( comune_dom ', p_comune_dom , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( stato_dom ', p_stato_dom , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( cap_dom ', p_cap_dom , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( tel_dom ', p_tel_dom , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( fax_dom ', p_fax_dom , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( utente_agg ', p_utente_agg , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( data_agg ', p_data_agg , ' )', p_QBE, AFC.date_format )
               || AFC.get_field_condition( ' and ( competenza ', p_competenza , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( competenza_esclusiva ', p_competenza_esclusiva , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( tipo_soggetto ', p_tipo_soggetto , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( flag_trg ', p_flag_trg , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( stato_cee ', p_stato_cee , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( partita_iva_cee ', p_partita_iva_cee , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( fine_validita ', p_fine_validita , ' )', p_QBE, AFC.date_format )
               || AFC.get_field_condition( ' and ( al ', p_al , ' )', p_QBE, AFC.date_format )
               || AFC.get_field_condition( ' and ( denominazione ', p_denominazione , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( indirizzo_web ', p_indirizzo_web , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( note ', p_note , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( utente ', p_utente , ' )', p_QBE, null )
               || ' ) ' || p_other_condition
               ;
   return d_statement;
end where_condition; --- as4_v_soggetti_correnti_tpk.where_condition
--------------------------------------------------------------------------------
function get_rows
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
) return AFC.t_ref_cursor is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_rows
 DESCRIZIONE: Ritorna il risultato di una query in base ai valori che passiamo. 
 PARAMETRI:   p_QBE 0: viene controllato se all'inizio di ogni attributo e presente
                       un operatore, altrimenti viene usato quello di default ('=')
                    1: viene utilizzato l'operatore specificato all'inizio di ogni
                       attributo.
              p_other_condition: condizioni aggiuntive di base
              p_order_by: condizioni di ordinamento
              p_extra_columns: colonne da aggiungere alla select
              p_extra_condition: condizioni aggiuntive 
              p_columns: colonne da estrarre (se null è *)
              p_offset: rownum da cui partire per estrazione
              p_limit: rownum a cui terminare estrazione
              Chiavi e attributi della table
 RITORNA:     Un ref_cursor che punta al risultato della query.
 NOTE:        Se p_QBE = 1 , ogni parametro deve contenere, nella prima parte,
              l'operatore da utilizzare nella where-condition.
              In p_extra_columns e p_order_by non devono essere passati anche la
              virgola iniziale (per p_extra_columns) e la stringa 'order by' (per
              p_order_by)
******************************************************************************/
   d_statement       AFC.t_statement;
   d_ref_cursor      AFC.t_ref_cursor;
begin
   d_statement := case 
                  when p_offset is null and p_limit is null then ''
                  else 'select * from ( '
                    || 'select rownum "ROW#", t.* from ( '
                  end 
               || 'select ' || nvl(p_columns,'AS4_V_SOGGETTI_CORRENTI.*') || ' '
               || afc.decode_value( p_extra_columns, null, null, ' , ' || p_extra_columns )
               || ' from AS4_V_SOGGETTI_CORRENTI '
               || where_condition( 
                                   p_QBE => p_QBE
                                 , p_other_condition => p_extra_condition || ' ' || p_other_condition
                                 , p_ni => p_ni
                                 , p_dal => p_dal
                                 , p_cognome => p_cognome
                                 , p_nome => p_nome
                                 , p_nominativo_ricerca => p_nominativo_ricerca
                                 , p_sesso => p_sesso
                                 , p_data_nas => p_data_nas
                                 , p_provincia_nas => p_provincia_nas
                                 , p_comune_nas => p_comune_nas
                                 , p_stato_nas => p_stato_nas
                                 , p_luogo_nas => p_luogo_nas
                                 , p_codice_fiscale => p_codice_fiscale
                                 , p_codice_fiscale_estero => p_codice_fiscale_estero
                                 , p_partita_iva => p_partita_iva
                                 , p_cittadinanza => p_cittadinanza
                                 , p_gruppo_ling => p_gruppo_ling
                                 , p_indirizzo_res => p_indirizzo_res
                                 , p_provincia_res => p_provincia_res
                                 , p_comune_res => p_comune_res
                                 , p_stato_res => p_stato_res
                                 , p_cap_res => p_cap_res
                                 , p_tel_res => p_tel_res
                                 , p_fax_res => p_fax_res
                                 , p_presso => p_presso
                                 , p_indirizzo_dom => p_indirizzo_dom
                                 , p_provincia_dom => p_provincia_dom
                                 , p_comune_dom => p_comune_dom
                                 , p_stato_dom => p_stato_dom
                                 , p_cap_dom => p_cap_dom
                                 , p_tel_dom => p_tel_dom
                                 , p_fax_dom => p_fax_dom
                                 , p_utente_agg => p_utente_agg
                                 , p_data_agg => p_data_agg
                                 , p_competenza => p_competenza
                                 , p_competenza_esclusiva => p_competenza_esclusiva
                                 , p_tipo_soggetto => p_tipo_soggetto
                                 , p_flag_trg => p_flag_trg
                                 , p_stato_cee => p_stato_cee
                                 , p_partita_iva_cee => p_partita_iva_cee
                                 , p_fine_validita => p_fine_validita
                                 , p_al => p_al
                                 , p_denominazione => p_denominazione
                                 , p_indirizzo_web => p_indirizzo_web
                                 , p_note => p_note
                                 , p_utente => p_utente
                                 )
               || afc.decode_value( p_order_by, null, null, ' order by ' || p_order_by )
               || case 
                  when p_offset is null and p_limit is null then ''
                  else ' ) t ' 
                    || ' ) '
                    || ' where "ROW#" > ' || nvl( p_offset , 0)
                    || '   and "ROW#" <  '  || (1 + nvl( p_offset , 0) +nvl( p_limit , 999999)) 
                  end
               ;
   d_ref_cursor := AFC_DML.get_ref_cursor( d_statement );
   return d_ref_cursor;
end get_rows; -- as4_v_soggetti_correnti_tpk.get_rows
--------------------------------------------------------------------------------
function count_rows
( p_QBE  in number default 0
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
) return integer is /* SLAVE_COPY */
/******************************************************************************
 NOME:        count_rows
 DESCRIZIONE: Ritorna il numero di righe della tabella gli attributi delle quali
              rispettano i valori indicati.
 PARAMETRI:   p_QBE 0: viene controllato se all'inizio di ogni attributo e presente
                       un operatore, altrimenti viene usato quello di default ('=')
                    1: viene utilizzato l'operatore specificato all'inizio di ogni
                       attributo.
              p_other_condition: condizioni aggiuntive di base
              p_extra_condition: condizioni aggiuntive 
              p_columns: colonne da estrarre (se null è *)
              Chiavi e attributi della table
 RITORNA:     Numero di righe che rispettano la selezione indicata.
******************************************************************************/
   d_result          integer;
   d_statement       AFC.t_statement;
begin
   d_statement := 'select count(*) from '
               || case
                  when p_columns is null then ''
                  else ' ( select ' || p_columns ||' from '
                  end
               || ' AS4_V_SOGGETTI_CORRENTI '
               || where_condition( 
                                   p_QBE => p_QBE
                                 , p_other_condition => p_extra_condition || ' ' || p_other_condition
                                 , p_ni => p_ni
                                 , p_dal => p_dal
                                 , p_cognome => p_cognome
                                 , p_nome => p_nome
                                 , p_nominativo_ricerca => p_nominativo_ricerca
                                 , p_sesso => p_sesso
                                 , p_data_nas => p_data_nas
                                 , p_provincia_nas => p_provincia_nas
                                 , p_comune_nas => p_comune_nas
                                 , p_stato_nas => p_stato_nas
                                 , p_luogo_nas => p_luogo_nas
                                 , p_codice_fiscale => p_codice_fiscale
                                 , p_codice_fiscale_estero => p_codice_fiscale_estero
                                 , p_partita_iva => p_partita_iva
                                 , p_cittadinanza => p_cittadinanza
                                 , p_gruppo_ling => p_gruppo_ling
                                 , p_indirizzo_res => p_indirizzo_res
                                 , p_provincia_res => p_provincia_res
                                 , p_comune_res => p_comune_res
                                 , p_stato_res => p_stato_res
                                 , p_cap_res => p_cap_res
                                 , p_tel_res => p_tel_res
                                 , p_fax_res => p_fax_res
                                 , p_presso => p_presso
                                 , p_indirizzo_dom => p_indirizzo_dom
                                 , p_provincia_dom => p_provincia_dom
                                 , p_comune_dom => p_comune_dom
                                 , p_stato_dom => p_stato_dom
                                 , p_cap_dom => p_cap_dom
                                 , p_tel_dom => p_tel_dom
                                 , p_fax_dom => p_fax_dom
                                 , p_utente_agg => p_utente_agg
                                 , p_data_agg => p_data_agg
                                 , p_competenza => p_competenza
                                 , p_competenza_esclusiva => p_competenza_esclusiva
                                 , p_tipo_soggetto => p_tipo_soggetto
                                 , p_flag_trg => p_flag_trg
                                 , p_stato_cee => p_stato_cee
                                 , p_partita_iva_cee => p_partita_iva_cee
                                 , p_fine_validita => p_fine_validita
                                 , p_al => p_al
                                 , p_denominazione => p_denominazione
                                 , p_indirizzo_web => p_indirizzo_web
                                 , p_note => p_note
                                 , p_utente => p_utente
                                 )
               || case 
                  when p_columns is null then ''
                  else ' ) '
                  end
               ;
   d_result := AFC.SQL_execute( d_statement );
   return d_result;
end count_rows; -- as4_v_soggetti_correnti_tpk.count_rows
--------------------------------------------------------------------------------
         
end as4_v_soggetti_correnti_tpk;
/

