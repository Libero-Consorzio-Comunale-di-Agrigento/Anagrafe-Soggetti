CREATE OR REPLACE package anagrafe_soggetti_tpk is /* MASTER_LINK */
/******************************************************************************
 NOME:        anagrafe_soggetti_tpk
 DESCRIZIONE: Gestione tabella ANAGRAFE_SOGGETTI.
 ANNOTAZIONI: .
 REVISIONI:   Template Revision: 1.53.
 <CODE>
 Rev.  Data       Autore  Descrizione.
 00    29/10/2012  snegroni  Prima emissione.
 01   14/11/2012   snegroni Aggiunto parametro per version per grails
 02   31/01/2018   snegroni Gestioni apici nei valori
 </CODE>
******************************************************************************/
   -- Revisione del Package
   s_revisione constant AFC.t_revision := 'V1.02';
   s_table_name constant AFC.t_object_name := 'ANAGRAFE_SOGGETTI';
   subtype t_rowtype is ANAGRAFE_SOGGETTI%rowtype;
   -- Tipo del record primary key
subtype t_ni  is ANAGRAFE_SOGGETTI.ni%type;
subtype t_dal  is ANAGRAFE_SOGGETTI.dal%type;
   type t_PK is record
   (
ni  t_ni,
dal  t_dal
   );
   -- Versione e revisione
   function versione /* SLAVE_COPY */
   return varchar2;
   pragma restrict_references( versione, WNDS );
   -- Costruttore di record chiave
   function PK /* SLAVE_COPY */
   (
    p_ni  in ANAGRAFE_SOGGETTI.ni%type,
p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return t_PK;
   pragma restrict_references( PK, WNDS );
   -- Controllo integrità chiave
   function can_handle /* SLAVE_COPY */
   (
    p_ni  in ANAGRAFE_SOGGETTI.ni%type,
p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return number;
   pragma restrict_references( can_handle, WNDS );
   -- Controllo integrità chiave
   -- wrapper boolean
   function canHandle /* SLAVE_COPY */
   (
    p_ni  in ANAGRAFE_SOGGETTI.ni%type,
p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return boolean;
   pragma restrict_references( canhandle, WNDS );
    -- Esistenza riga con chiave indicata
   function exists_id /* SLAVE_COPY */
   (
    p_ni  in ANAGRAFE_SOGGETTI.ni%type,
p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return number;
   pragma restrict_references( exists_id, WNDS );
   -- Esistenza riga con chiave indicata
   -- wrapper boolean
   function existsId /* SLAVE_COPY */
   (
    p_ni  in ANAGRAFE_SOGGETTI.ni%type,
p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return boolean;
   pragma restrict_references( existsid, WNDS );
   -- Inserimento di una riga
   procedure ins  /*+ SOA  */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type default null
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_cognome  in ANAGRAFE_SOGGETTI.cognome%type
   , p_nome  in ANAGRAFE_SOGGETTI.nome%type default null
   , p_sesso  in ANAGRAFE_SOGGETTI.sesso%type default null
   , p_data_nas  in ANAGRAFE_SOGGETTI.data_nas%type default null
   , p_provincia_nas  in ANAGRAFE_SOGGETTI.provincia_nas%type default null
   , p_comune_nas  in ANAGRAFE_SOGGETTI.comune_nas%type default null
   , p_luogo_nas  in ANAGRAFE_SOGGETTI.luogo_nas%type default null
   , p_codice_fiscale  in ANAGRAFE_SOGGETTI.codice_fiscale%type default null
   , p_codice_fiscale_estero  in ANAGRAFE_SOGGETTI.codice_fiscale_estero%type default null
   , p_partita_iva  in ANAGRAFE_SOGGETTI.partita_iva%type default null
   , p_cittadinanza  in ANAGRAFE_SOGGETTI.cittadinanza%type default null
   , p_gruppo_ling  in ANAGRAFE_SOGGETTI.gruppo_ling%type default null
   , p_indirizzo_res  in ANAGRAFE_SOGGETTI.indirizzo_res%type default null
   , p_provincia_res  in ANAGRAFE_SOGGETTI.provincia_res%type default null
   , p_comune_res  in ANAGRAFE_SOGGETTI.comune_res%type default null
   , p_cap_res  in ANAGRAFE_SOGGETTI.cap_res%type default null
   , p_tel_res  in ANAGRAFE_SOGGETTI.tel_res%type default null
   , p_fax_res  in ANAGRAFE_SOGGETTI.fax_res%type default null
   , p_presso  in ANAGRAFE_SOGGETTI.presso%type default null
   , p_indirizzo_dom  in ANAGRAFE_SOGGETTI.indirizzo_dom%type default null
   , p_provincia_dom  in ANAGRAFE_SOGGETTI.provincia_dom%type default null
   , p_comune_dom  in ANAGRAFE_SOGGETTI.comune_dom%type default null
   , p_cap_dom  in ANAGRAFE_SOGGETTI.cap_dom%type default null
   , p_tel_dom  in ANAGRAFE_SOGGETTI.tel_dom%type default null
   , p_fax_dom  in ANAGRAFE_SOGGETTI.fax_dom%type default null
   , p_utente  in ANAGRAFE_SOGGETTI.utente%type default null
   , p_data_agg  in ANAGRAFE_SOGGETTI.data_agg%type default SYSDATE
   , p_competenza  in ANAGRAFE_SOGGETTI.competenza%type default null
   , p_tipo_soggetto  in ANAGRAFE_SOGGETTI.tipo_soggetto%type default null
   , p_flag_trg  in ANAGRAFE_SOGGETTI.flag_trg%type default null
   , p_stato_cee  in ANAGRAFE_SOGGETTI.stato_cee%type default null
   , p_partita_iva_cee  in ANAGRAFE_SOGGETTI.partita_iva_cee%type default null
   , p_fine_validita  in ANAGRAFE_SOGGETTI.fine_validita%type default null
   , p_al  in ANAGRAFE_SOGGETTI.al%type default null
   , p_denominazione  in ANAGRAFE_SOGGETTI.denominazione%type default null
   , p_indirizzo_web  in ANAGRAFE_SOGGETTI.indirizzo_web%type default null
   , p_note  in ANAGRAFE_SOGGETTI.note%type default null
   , p_competenza_esclusiva  in ANAGRAFE_SOGGETTI.competenza_esclusiva%type default null
   , p_version  in ANAGRAFE_SOGGETTI.version%type default 0
   );
   function ins  /*+ SOA  */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type default null
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_cognome  in ANAGRAFE_SOGGETTI.cognome%type
   , p_nome  in ANAGRAFE_SOGGETTI.nome%type default null
   , p_sesso  in ANAGRAFE_SOGGETTI.sesso%type default null
   , p_data_nas  in ANAGRAFE_SOGGETTI.data_nas%type default null
   , p_provincia_nas  in ANAGRAFE_SOGGETTI.provincia_nas%type default null
   , p_comune_nas  in ANAGRAFE_SOGGETTI.comune_nas%type default null
   , p_luogo_nas  in ANAGRAFE_SOGGETTI.luogo_nas%type default null
   , p_codice_fiscale  in ANAGRAFE_SOGGETTI.codice_fiscale%type default null
   , p_codice_fiscale_estero  in ANAGRAFE_SOGGETTI.codice_fiscale_estero%type default null
   , p_partita_iva  in ANAGRAFE_SOGGETTI.partita_iva%type default null
   , p_cittadinanza  in ANAGRAFE_SOGGETTI.cittadinanza%type default null
   , p_gruppo_ling  in ANAGRAFE_SOGGETTI.gruppo_ling%type default null
   , p_indirizzo_res  in ANAGRAFE_SOGGETTI.indirizzo_res%type default null
   , p_provincia_res  in ANAGRAFE_SOGGETTI.provincia_res%type default null
   , p_comune_res  in ANAGRAFE_SOGGETTI.comune_res%type default null
   , p_cap_res  in ANAGRAFE_SOGGETTI.cap_res%type default null
   , p_tel_res  in ANAGRAFE_SOGGETTI.tel_res%type default null
   , p_fax_res  in ANAGRAFE_SOGGETTI.fax_res%type default null
   , p_presso  in ANAGRAFE_SOGGETTI.presso%type default null
   , p_indirizzo_dom  in ANAGRAFE_SOGGETTI.indirizzo_dom%type default null
   , p_provincia_dom  in ANAGRAFE_SOGGETTI.provincia_dom%type default null
   , p_comune_dom  in ANAGRAFE_SOGGETTI.comune_dom%type default null
   , p_cap_dom  in ANAGRAFE_SOGGETTI.cap_dom%type default null
   , p_tel_dom  in ANAGRAFE_SOGGETTI.tel_dom%type default null
   , p_fax_dom  in ANAGRAFE_SOGGETTI.fax_dom%type default null
   , p_utente  in ANAGRAFE_SOGGETTI.utente%type default null
   , p_data_agg  in ANAGRAFE_SOGGETTI.data_agg%type default SYSDATE
   , p_competenza  in ANAGRAFE_SOGGETTI.competenza%type default null
   , p_tipo_soggetto  in ANAGRAFE_SOGGETTI.tipo_soggetto%type default null
   , p_flag_trg  in ANAGRAFE_SOGGETTI.flag_trg%type default null
   , p_stato_cee  in ANAGRAFE_SOGGETTI.stato_cee%type default null
   , p_partita_iva_cee  in ANAGRAFE_SOGGETTI.partita_iva_cee%type default null
   , p_fine_validita  in ANAGRAFE_SOGGETTI.fine_validita%type default null
   , p_al  in ANAGRAFE_SOGGETTI.al%type default null
   , p_denominazione  in ANAGRAFE_SOGGETTI.denominazione%type default null
   , p_indirizzo_web  in ANAGRAFE_SOGGETTI.indirizzo_web%type default null
   , p_note  in ANAGRAFE_SOGGETTI.note%type default null
   , p_competenza_esclusiva  in ANAGRAFE_SOGGETTI.competenza_esclusiva%type default null
   , p_version  in ANAGRAFE_SOGGETTI.version%type default 0
   ) return number;
   -- Aggiornamento di una riga
   procedure upd  /*+ SOA  */
   (
     p_check_OLD  in integer default 0
   , p_NEW_ni  in ANAGRAFE_SOGGETTI.ni%type
   , p_OLD_ni  in ANAGRAFE_SOGGETTI.ni%type default null
, p_NEW_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_OLD_dal  in ANAGRAFE_SOGGETTI.dal%type default null
   , p_NEW_cognome  in ANAGRAFE_SOGGETTI.cognome%type default afc.default_null('ANAGRAFE_SOGGETTI.cognome')
   , p_OLD_cognome  in ANAGRAFE_SOGGETTI.cognome%type default null
   , p_NEW_nome  in ANAGRAFE_SOGGETTI.nome%type default afc.default_null('ANAGRAFE_SOGGETTI.nome')
   , p_OLD_nome  in ANAGRAFE_SOGGETTI.nome%type default null
   , p_NEW_sesso  in ANAGRAFE_SOGGETTI.sesso%type default afc.default_null('ANAGRAFE_SOGGETTI.sesso')
   , p_OLD_sesso  in ANAGRAFE_SOGGETTI.sesso%type default null
   , p_NEW_data_nas  in ANAGRAFE_SOGGETTI.data_nas%type default afc.default_null('ANAGRAFE_SOGGETTI.data_nas')
   , p_OLD_data_nas  in ANAGRAFE_SOGGETTI.data_nas%type default null
   , p_NEW_provincia_nas  in ANAGRAFE_SOGGETTI.provincia_nas%type default afc.default_null('ANAGRAFE_SOGGETTI.provincia_nas')
   , p_OLD_provincia_nas  in ANAGRAFE_SOGGETTI.provincia_nas%type default null
   , p_NEW_comune_nas  in ANAGRAFE_SOGGETTI.comune_nas%type default afc.default_null('ANAGRAFE_SOGGETTI.comune_nas')
   , p_OLD_comune_nas  in ANAGRAFE_SOGGETTI.comune_nas%type default null
   , p_NEW_luogo_nas  in ANAGRAFE_SOGGETTI.luogo_nas%type default afc.default_null('ANAGRAFE_SOGGETTI.luogo_nas')
   , p_OLD_luogo_nas  in ANAGRAFE_SOGGETTI.luogo_nas%type default null
   , p_NEW_codice_fiscale  in ANAGRAFE_SOGGETTI.codice_fiscale%type default afc.default_null('ANAGRAFE_SOGGETTI.codice_fiscale')
   , p_OLD_codice_fiscale  in ANAGRAFE_SOGGETTI.codice_fiscale%type default null
   , p_NEW_codice_fiscale_estero  in ANAGRAFE_SOGGETTI.codice_fiscale_estero%type default afc.default_null('ANAGRAFE_SOGGETTI.codice_fiscale_estero')
   , p_OLD_codice_fiscale_estero  in ANAGRAFE_SOGGETTI.codice_fiscale_estero%type default null
   , p_NEW_partita_iva  in ANAGRAFE_SOGGETTI.partita_iva%type default afc.default_null('ANAGRAFE_SOGGETTI.partita_iva')
   , p_OLD_partita_iva  in ANAGRAFE_SOGGETTI.partita_iva%type default null
   , p_NEW_cittadinanza  in ANAGRAFE_SOGGETTI.cittadinanza%type default afc.default_null('ANAGRAFE_SOGGETTI.cittadinanza')
   , p_OLD_cittadinanza  in ANAGRAFE_SOGGETTI.cittadinanza%type default null
   , p_NEW_gruppo_ling  in ANAGRAFE_SOGGETTI.gruppo_ling%type default afc.default_null('ANAGRAFE_SOGGETTI.gruppo_ling')
   , p_OLD_gruppo_ling  in ANAGRAFE_SOGGETTI.gruppo_ling%type default null
   , p_NEW_indirizzo_res  in ANAGRAFE_SOGGETTI.indirizzo_res%type default afc.default_null('ANAGRAFE_SOGGETTI.indirizzo_res')
   , p_OLD_indirizzo_res  in ANAGRAFE_SOGGETTI.indirizzo_res%type default null
   , p_NEW_provincia_res  in ANAGRAFE_SOGGETTI.provincia_res%type default afc.default_null('ANAGRAFE_SOGGETTI.provincia_res')
   , p_OLD_provincia_res  in ANAGRAFE_SOGGETTI.provincia_res%type default null
   , p_NEW_comune_res  in ANAGRAFE_SOGGETTI.comune_res%type default afc.default_null('ANAGRAFE_SOGGETTI.comune_res')
   , p_OLD_comune_res  in ANAGRAFE_SOGGETTI.comune_res%type default null
   , p_NEW_cap_res  in ANAGRAFE_SOGGETTI.cap_res%type default afc.default_null('ANAGRAFE_SOGGETTI.cap_res')
   , p_OLD_cap_res  in ANAGRAFE_SOGGETTI.cap_res%type default null
   , p_NEW_tel_res  in ANAGRAFE_SOGGETTI.tel_res%type default afc.default_null('ANAGRAFE_SOGGETTI.tel_res')
   , p_OLD_tel_res  in ANAGRAFE_SOGGETTI.tel_res%type default null
   , p_NEW_fax_res  in ANAGRAFE_SOGGETTI.fax_res%type default afc.default_null('ANAGRAFE_SOGGETTI.fax_res')
   , p_OLD_fax_res  in ANAGRAFE_SOGGETTI.fax_res%type default null
   , p_NEW_presso  in ANAGRAFE_SOGGETTI.presso%type default afc.default_null('ANAGRAFE_SOGGETTI.presso')
   , p_OLD_presso  in ANAGRAFE_SOGGETTI.presso%type default null
   , p_NEW_indirizzo_dom  in ANAGRAFE_SOGGETTI.indirizzo_dom%type default afc.default_null('ANAGRAFE_SOGGETTI.indirizzo_dom')
   , p_OLD_indirizzo_dom  in ANAGRAFE_SOGGETTI.indirizzo_dom%type default null
   , p_NEW_provincia_dom  in ANAGRAFE_SOGGETTI.provincia_dom%type default afc.default_null('ANAGRAFE_SOGGETTI.provincia_dom')
   , p_OLD_provincia_dom  in ANAGRAFE_SOGGETTI.provincia_dom%type default null
   , p_NEW_comune_dom  in ANAGRAFE_SOGGETTI.comune_dom%type default afc.default_null('ANAGRAFE_SOGGETTI.comune_dom')
   , p_OLD_comune_dom  in ANAGRAFE_SOGGETTI.comune_dom%type default null
   , p_NEW_cap_dom  in ANAGRAFE_SOGGETTI.cap_dom%type default afc.default_null('ANAGRAFE_SOGGETTI.cap_dom')
   , p_OLD_cap_dom  in ANAGRAFE_SOGGETTI.cap_dom%type default null
   , p_NEW_tel_dom  in ANAGRAFE_SOGGETTI.tel_dom%type default afc.default_null('ANAGRAFE_SOGGETTI.tel_dom')
   , p_OLD_tel_dom  in ANAGRAFE_SOGGETTI.tel_dom%type default null
   , p_NEW_fax_dom  in ANAGRAFE_SOGGETTI.fax_dom%type default afc.default_null('ANAGRAFE_SOGGETTI.fax_dom')
   , p_OLD_fax_dom  in ANAGRAFE_SOGGETTI.fax_dom%type default null
   , p_NEW_utente  in ANAGRAFE_SOGGETTI.utente%type default afc.default_null('ANAGRAFE_SOGGETTI.utente')
   , p_OLD_utente  in ANAGRAFE_SOGGETTI.utente%type default null
   , p_NEW_data_agg  in ANAGRAFE_SOGGETTI.data_agg%type default afc.default_null('ANAGRAFE_SOGGETTI.data_agg')
   , p_OLD_data_agg  in ANAGRAFE_SOGGETTI.data_agg%type default null
   , p_NEW_competenza  in ANAGRAFE_SOGGETTI.competenza%type default afc.default_null('ANAGRAFE_SOGGETTI.competenza')
   , p_OLD_competenza  in ANAGRAFE_SOGGETTI.competenza%type default null
   , p_NEW_tipo_soggetto  in ANAGRAFE_SOGGETTI.tipo_soggetto%type default afc.default_null('ANAGRAFE_SOGGETTI.tipo_soggetto')
   , p_OLD_tipo_soggetto  in ANAGRAFE_SOGGETTI.tipo_soggetto%type default null
   , p_NEW_flag_trg  in ANAGRAFE_SOGGETTI.flag_trg%type default afc.default_null('ANAGRAFE_SOGGETTI.flag_trg')
   , p_OLD_flag_trg  in ANAGRAFE_SOGGETTI.flag_trg%type default null
   , p_NEW_stato_cee  in ANAGRAFE_SOGGETTI.stato_cee%type default afc.default_null('ANAGRAFE_SOGGETTI.stato_cee')
   , p_OLD_stato_cee  in ANAGRAFE_SOGGETTI.stato_cee%type default null
   , p_NEW_partita_iva_cee  in ANAGRAFE_SOGGETTI.partita_iva_cee%type default afc.default_null('ANAGRAFE_SOGGETTI.partita_iva_cee')
   , p_OLD_partita_iva_cee  in ANAGRAFE_SOGGETTI.partita_iva_cee%type default null
   , p_NEW_fine_validita  in ANAGRAFE_SOGGETTI.fine_validita%type default afc.default_null('ANAGRAFE_SOGGETTI.fine_validita')
   , p_OLD_fine_validita  in ANAGRAFE_SOGGETTI.fine_validita%type default null
   , p_NEW_al  in ANAGRAFE_SOGGETTI.al%type default afc.default_null('ANAGRAFE_SOGGETTI.al')
   , p_OLD_al  in ANAGRAFE_SOGGETTI.al%type default null
   , p_NEW_denominazione  in ANAGRAFE_SOGGETTI.denominazione%type default afc.default_null('ANAGRAFE_SOGGETTI.denominazione')
   , p_OLD_denominazione  in ANAGRAFE_SOGGETTI.denominazione%type default null
   , p_NEW_indirizzo_web  in ANAGRAFE_SOGGETTI.indirizzo_web%type default afc.default_null('ANAGRAFE_SOGGETTI.indirizzo_web')
   , p_OLD_indirizzo_web  in ANAGRAFE_SOGGETTI.indirizzo_web%type default null
   , p_NEW_note  in ANAGRAFE_SOGGETTI.note%type default afc.default_null('ANAGRAFE_SOGGETTI.note')
   , p_OLD_note  in ANAGRAFE_SOGGETTI.note%type default null
   , p_NEW_competenza_esclusiva  in ANAGRAFE_SOGGETTI.competenza_esclusiva%type default afc.default_null('ANAGRAFE_SOGGETTI.competenza_esclusiva')
   , p_OLD_competenza_esclusiva  in ANAGRAFE_SOGGETTI.competenza_esclusiva%type default null
   , p_NEW_version  in ANAGRAFE_SOGGETTI.version%type default afc.default_null('ANAGRAFE_SOGGETTI.version')
   , p_OLD_version  in ANAGRAFE_SOGGETTI.version%type default null
   );
   -- Aggiornamento del campo di una riga
   procedure upd_column
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type,
p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_column         in varchar2
   , p_value          in varchar2 default null
   , p_literal_value  in number   default 1
   );
   procedure upd_column
   (
p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_column in varchar2
   , p_value  in date
   );
   -- Cancellazione di una riga
   procedure del  /*+ SOA  */
   (
     p_check_OLD  in integer default 0
   , p_ni  in ANAGRAFE_SOGGETTI.ni%type
, p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_cognome  in ANAGRAFE_SOGGETTI.cognome%type default null
   , p_nome  in ANAGRAFE_SOGGETTI.nome%type default null
   , p_sesso  in ANAGRAFE_SOGGETTI.sesso%type default null
   , p_data_nas  in ANAGRAFE_SOGGETTI.data_nas%type default null
   , p_provincia_nas  in ANAGRAFE_SOGGETTI.provincia_nas%type default null
   , p_comune_nas  in ANAGRAFE_SOGGETTI.comune_nas%type default null
   , p_luogo_nas  in ANAGRAFE_SOGGETTI.luogo_nas%type default null
   , p_codice_fiscale  in ANAGRAFE_SOGGETTI.codice_fiscale%type default null
   , p_codice_fiscale_estero  in ANAGRAFE_SOGGETTI.codice_fiscale_estero%type default null
   , p_partita_iva  in ANAGRAFE_SOGGETTI.partita_iva%type default null
   , p_cittadinanza  in ANAGRAFE_SOGGETTI.cittadinanza%type default null
   , p_gruppo_ling  in ANAGRAFE_SOGGETTI.gruppo_ling%type default null
   , p_indirizzo_res  in ANAGRAFE_SOGGETTI.indirizzo_res%type default null
   , p_provincia_res  in ANAGRAFE_SOGGETTI.provincia_res%type default null
   , p_comune_res  in ANAGRAFE_SOGGETTI.comune_res%type default null
   , p_cap_res  in ANAGRAFE_SOGGETTI.cap_res%type default null
   , p_tel_res  in ANAGRAFE_SOGGETTI.tel_res%type default null
   , p_fax_res  in ANAGRAFE_SOGGETTI.fax_res%type default null
   , p_presso  in ANAGRAFE_SOGGETTI.presso%type default null
   , p_indirizzo_dom  in ANAGRAFE_SOGGETTI.indirizzo_dom%type default null
   , p_provincia_dom  in ANAGRAFE_SOGGETTI.provincia_dom%type default null
   , p_comune_dom  in ANAGRAFE_SOGGETTI.comune_dom%type default null
   , p_cap_dom  in ANAGRAFE_SOGGETTI.cap_dom%type default null
   , p_tel_dom  in ANAGRAFE_SOGGETTI.tel_dom%type default null
   , p_fax_dom  in ANAGRAFE_SOGGETTI.fax_dom%type default null
   , p_utente  in ANAGRAFE_SOGGETTI.utente%type default null
   , p_data_agg  in ANAGRAFE_SOGGETTI.data_agg%type default null
   , p_competenza  in ANAGRAFE_SOGGETTI.competenza%type default null
   , p_tipo_soggetto  in ANAGRAFE_SOGGETTI.tipo_soggetto%type default null
   , p_flag_trg  in ANAGRAFE_SOGGETTI.flag_trg%type default null
   , p_stato_cee  in ANAGRAFE_SOGGETTI.stato_cee%type default null
   , p_partita_iva_cee  in ANAGRAFE_SOGGETTI.partita_iva_cee%type default null
   , p_fine_validita  in ANAGRAFE_SOGGETTI.fine_validita%type default null
   , p_al  in ANAGRAFE_SOGGETTI.al%type default null
   , p_denominazione  in ANAGRAFE_SOGGETTI.denominazione%type default null
   , p_indirizzo_web  in ANAGRAFE_SOGGETTI.indirizzo_web%type default null
   , p_note  in ANAGRAFE_SOGGETTI.note%type default null
   , p_competenza_esclusiva  in ANAGRAFE_SOGGETTI.competenza_esclusiva%type default null
   , p_version  in ANAGRAFE_SOGGETTI.version%type default null
   );
-- Getter per attributo cognome di riga identificata da chiave
   function get_cognome /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.cognome%type;
   pragma restrict_references( get_cognome, WNDS );
-- Getter per attributo nome di riga identificata da chiave
   function get_nome /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.nome%type;
   pragma restrict_references( get_nome, WNDS );
-- Getter per attributo sesso di riga identificata da chiave
   function get_sesso /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.sesso%type;
   pragma restrict_references( get_sesso, WNDS );
-- Getter per attributo data_nas di riga identificata da chiave
   function get_data_nas /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.data_nas%type;
   pragma restrict_references( get_data_nas, WNDS );
-- Getter per attributo provincia_nas di riga identificata da chiave
   function get_provincia_nas /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.provincia_nas%type;
   pragma restrict_references( get_provincia_nas, WNDS );
-- Getter per attributo comune_nas di riga identificata da chiave
   function get_comune_nas /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.comune_nas%type;
   pragma restrict_references( get_comune_nas, WNDS );
-- Getter per attributo luogo_nas di riga identificata da chiave
   function get_luogo_nas /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.luogo_nas%type;
   pragma restrict_references( get_luogo_nas, WNDS );
-- Getter per attributo codice_fiscale di riga identificata da chiave
   function get_codice_fiscale /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.codice_fiscale%type;
   pragma restrict_references( get_codice_fiscale, WNDS );
-- Getter per attributo codice_fiscale_estero di riga identificata da chiave
   function get_codice_fiscale_estero /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.codice_fiscale_estero%type;
   pragma restrict_references( get_codice_fiscale_estero, WNDS );
-- Getter per attributo partita_iva di riga identificata da chiave
   function get_partita_iva /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.partita_iva%type;
   pragma restrict_references( get_partita_iva, WNDS );
-- Getter per attributo cittadinanza di riga identificata da chiave
   function get_cittadinanza /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.cittadinanza%type;
   pragma restrict_references( get_cittadinanza, WNDS );
-- Getter per attributo gruppo_ling di riga identificata da chiave
   function get_gruppo_ling /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.gruppo_ling%type;
   pragma restrict_references( get_gruppo_ling, WNDS );
-- Getter per attributo indirizzo_res di riga identificata da chiave
   function get_indirizzo_res /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.indirizzo_res%type;
   pragma restrict_references( get_indirizzo_res, WNDS );
-- Getter per attributo provincia_res di riga identificata da chiave
   function get_provincia_res /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.provincia_res%type;
   pragma restrict_references( get_provincia_res, WNDS );
-- Getter per attributo comune_res di riga identificata da chiave
   function get_comune_res /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.comune_res%type;
   pragma restrict_references( get_comune_res, WNDS );
-- Getter per attributo cap_res di riga identificata da chiave
   function get_cap_res /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.cap_res%type;
   pragma restrict_references( get_cap_res, WNDS );
-- Getter per attributo tel_res di riga identificata da chiave
   function get_tel_res /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.tel_res%type;
   pragma restrict_references( get_tel_res, WNDS );
-- Getter per attributo fax_res di riga identificata da chiave
   function get_fax_res /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.fax_res%type;
   pragma restrict_references( get_fax_res, WNDS );
-- Getter per attributo presso di riga identificata da chiave
   function get_presso /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.presso%type;
   pragma restrict_references( get_presso, WNDS );
-- Getter per attributo indirizzo_dom di riga identificata da chiave
   function get_indirizzo_dom /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.indirizzo_dom%type;
   pragma restrict_references( get_indirizzo_dom, WNDS );
-- Getter per attributo provincia_dom di riga identificata da chiave
   function get_provincia_dom /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.provincia_dom%type;
   pragma restrict_references( get_provincia_dom, WNDS );
-- Getter per attributo comune_dom di riga identificata da chiave
   function get_comune_dom /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.comune_dom%type;
   pragma restrict_references( get_comune_dom, WNDS );
-- Getter per attributo cap_dom di riga identificata da chiave
   function get_cap_dom /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.cap_dom%type;
   pragma restrict_references( get_cap_dom, WNDS );
-- Getter per attributo tel_dom di riga identificata da chiave
   function get_tel_dom /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.tel_dom%type;
   pragma restrict_references( get_tel_dom, WNDS );
-- Getter per attributo fax_dom di riga identificata da chiave
   function get_fax_dom /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.fax_dom%type;
   pragma restrict_references( get_fax_dom, WNDS );
-- Getter per attributo utente di riga identificata da chiave
   function get_utente /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.utente%type;
   pragma restrict_references( get_utente, WNDS );
-- Getter per attributo data_agg di riga identificata da chiave
   function get_data_agg /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.data_agg%type;
   pragma restrict_references( get_data_agg, WNDS );
-- Getter per attributo competenza di riga identificata da chiave
   function get_competenza /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.competenza%type;
   pragma restrict_references( get_competenza, WNDS );
-- Getter per attributo tipo_soggetto di riga identificata da chiave
   function get_tipo_soggetto /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.tipo_soggetto%type;
   pragma restrict_references( get_tipo_soggetto, WNDS );
-- Getter per attributo flag_trg di riga identificata da chiave
   function get_flag_trg /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.flag_trg%type;
   pragma restrict_references( get_flag_trg, WNDS );
-- Getter per attributo stato_cee di riga identificata da chiave
   function get_stato_cee /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.stato_cee%type;
   pragma restrict_references( get_stato_cee, WNDS );
-- Getter per attributo partita_iva_cee di riga identificata da chiave
   function get_partita_iva_cee /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.partita_iva_cee%type;
   pragma restrict_references( get_partita_iva_cee, WNDS );
-- Getter per attributo fine_validita di riga identificata da chiave
   function get_fine_validita /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.fine_validita%type;
   pragma restrict_references( get_fine_validita, WNDS );
-- Getter per attributo al di riga identificata da chiave
   function get_al /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.al%type;
   pragma restrict_references( get_al, WNDS );
-- Getter per attributo denominazione di riga identificata da chiave
   function get_denominazione /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.denominazione%type;
   pragma restrict_references( get_denominazione, WNDS );
-- Getter per attributo indirizzo_web di riga identificata da chiave
   function get_indirizzo_web /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.indirizzo_web%type;
   pragma restrict_references( get_indirizzo_web, WNDS );
-- Getter per attributo note di riga identificata da chiave
   function get_note /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.note%type;
   pragma restrict_references( get_note, WNDS );
-- Getter per attributo competenza_esclusiva di riga identificata da chiave
   function get_competenza_esclusiva /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.competenza_esclusiva%type;
   pragma restrict_references( get_competenza_esclusiva, WNDS );
-- Getter per attributo version di riga identificata da chiave
   function get_version /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   ) return ANAGRAFE_SOGGETTI.version%type;
   pragma restrict_references( get_version, WNDS );
-- Setter per attributo ni di riga identificata da chiave
   procedure set_ni
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.ni%type default null
   );
-- Setter per attributo dal di riga identificata da chiave
   procedure set_dal
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.dal%type default null
);
-- Setter per attributo cognome di riga identificata da chiave
   procedure set_cognome
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.cognome%type default null
   );
-- Setter per attributo nome di riga identificata da chiave
   procedure set_nome
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.nome%type default null
   );
-- Setter per attributo sesso di riga identificata da chiave
   procedure set_sesso
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.sesso%type default null
   );
-- Setter per attributo data_nas di riga identificata da chiave
   procedure set_data_nas
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.data_nas%type default null
   );
-- Setter per attributo provincia_nas di riga identificata da chiave
   procedure set_provincia_nas
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.provincia_nas%type default null
   );
-- Setter per attributo comune_nas di riga identificata da chiave
   procedure set_comune_nas
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.comune_nas%type default null
   );
-- Setter per attributo luogo_nas di riga identificata da chiave
   procedure set_luogo_nas
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.luogo_nas%type default null
   );
-- Setter per attributo codice_fiscale di riga identificata da chiave
   procedure set_codice_fiscale
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.codice_fiscale%type default null
   );
-- Setter per attributo codice_fiscale_estero di riga identificata da chiave
   procedure set_codice_fiscale_estero
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.codice_fiscale_estero%type default null
   );
-- Setter per attributo partita_iva di riga identificata da chiave
   procedure set_partita_iva
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.partita_iva%type default null
   );
-- Setter per attributo cittadinanza di riga identificata da chiave
   procedure set_cittadinanza
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.cittadinanza%type default null
   );
-- Setter per attributo gruppo_ling di riga identificata da chiave
   procedure set_gruppo_ling
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.gruppo_ling%type default null
   );
-- Setter per attributo indirizzo_res di riga identificata da chiave
   procedure set_indirizzo_res
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.indirizzo_res%type default null
   );
-- Setter per attributo provincia_res di riga identificata da chiave
   procedure set_provincia_res
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.provincia_res%type default null
   );
-- Setter per attributo comune_res di riga identificata da chiave
   procedure set_comune_res
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.comune_res%type default null
   );
-- Setter per attributo cap_res di riga identificata da chiave
   procedure set_cap_res
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.cap_res%type default null
   );
-- Setter per attributo tel_res di riga identificata da chiave
   procedure set_tel_res
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.tel_res%type default null
   );
-- Setter per attributo fax_res di riga identificata da chiave
   procedure set_fax_res
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.fax_res%type default null
   );
-- Setter per attributo presso di riga identificata da chiave
   procedure set_presso
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.presso%type default null
   );
-- Setter per attributo indirizzo_dom di riga identificata da chiave
   procedure set_indirizzo_dom
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.indirizzo_dom%type default null
   );
-- Setter per attributo provincia_dom di riga identificata da chiave
   procedure set_provincia_dom
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.provincia_dom%type default null
   );
-- Setter per attributo comune_dom di riga identificata da chiave
   procedure set_comune_dom
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.comune_dom%type default null
   );
-- Setter per attributo cap_dom di riga identificata da chiave
   procedure set_cap_dom
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.cap_dom%type default null
   );
-- Setter per attributo tel_dom di riga identificata da chiave
   procedure set_tel_dom
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.tel_dom%type default null
   );
-- Setter per attributo fax_dom di riga identificata da chiave
   procedure set_fax_dom
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.fax_dom%type default null
   );
-- Setter per attributo utente di riga identificata da chiave
   procedure set_utente
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.utente%type default null
   );
-- Setter per attributo data_agg di riga identificata da chiave
   procedure set_data_agg
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.data_agg%type default null
   );
-- Setter per attributo competenza di riga identificata da chiave
   procedure set_competenza
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.competenza%type default null
   );
-- Setter per attributo tipo_soggetto di riga identificata da chiave
   procedure set_tipo_soggetto
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.tipo_soggetto%type default null
   );
-- Setter per attributo flag_trg di riga identificata da chiave
   procedure set_flag_trg
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.flag_trg%type default null
   );
-- Setter per attributo stato_cee di riga identificata da chiave
   procedure set_stato_cee
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.stato_cee%type default null
   );
-- Setter per attributo partita_iva_cee di riga identificata da chiave
   procedure set_partita_iva_cee
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.partita_iva_cee%type default null
   );
-- Setter per attributo fine_validita di riga identificata da chiave
   procedure set_fine_validita
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.fine_validita%type default null
   );
-- Setter per attributo al di riga identificata da chiave
   procedure set_al
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.al%type default null
   );
-- Setter per attributo denominazione di riga identificata da chiave
   procedure set_denominazione
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.denominazione%type default null
   );
-- Setter per attributo indirizzo_web di riga identificata da chiave
   procedure set_indirizzo_web
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.indirizzo_web%type default null
   );
-- Setter per attributo note di riga identificata da chiave
   procedure set_note
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.note%type default null
   );
-- Setter per attributo competenza_esclusiva di riga identificata da chiave
   procedure set_competenza_esclusiva
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.competenza_esclusiva%type default null
   );
-- Setter per attributo version di riga identificata da chiave
   procedure set_version
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.version%type default null
   );
   -- righe corrispondenti alla selezione indicata
   function get_rows  /*+ SOA  */ /* SLAVE_COPY */
   ( p_QBE  in number default 0
   , p_other_condition in varchar2 default null
   , p_order_by in varchar2 default null
   , p_extra_columns in varchar2 default null
   , p_extra_condition in varchar2 default null
   , p_ni  in varchar2 default null
, p_dal  in varchar2 default null
   , p_cognome  in varchar2 default null
   , p_nome  in varchar2 default null
   , p_sesso  in varchar2 default null
   , p_data_nas  in varchar2 default null
   , p_provincia_nas  in varchar2 default null
   , p_comune_nas  in varchar2 default null
   , p_luogo_nas  in varchar2 default null
   , p_codice_fiscale  in varchar2 default null
   , p_codice_fiscale_estero  in varchar2 default null
   , p_partita_iva  in varchar2 default null
   , p_cittadinanza  in varchar2 default null
   , p_gruppo_ling  in varchar2 default null
   , p_indirizzo_res  in varchar2 default null
   , p_provincia_res  in varchar2 default null
   , p_comune_res  in varchar2 default null
   , p_cap_res  in varchar2 default null
   , p_tel_res  in varchar2 default null
   , p_fax_res  in varchar2 default null
   , p_presso  in varchar2 default null
   , p_indirizzo_dom  in varchar2 default null
   , p_provincia_dom  in varchar2 default null
   , p_comune_dom  in varchar2 default null
   , p_cap_dom  in varchar2 default null
   , p_tel_dom  in varchar2 default null
   , p_fax_dom  in varchar2 default null
   , p_utente  in varchar2 default null
   , p_data_agg  in varchar2 default null
   , p_competenza  in varchar2 default null
   , p_tipo_soggetto  in varchar2 default null
   , p_flag_trg  in varchar2 default null
   , p_stato_cee  in varchar2 default null
   , p_partita_iva_cee  in varchar2 default null
   , p_fine_validita  in varchar2 default null
   , p_al  in varchar2 default null
   , p_denominazione  in varchar2 default null
   , p_indirizzo_web  in varchar2 default null
   , p_note  in varchar2 default null
   , p_competenza_esclusiva  in varchar2 default null
   , p_version  in varchar2 default null
   ) return AFC.t_ref_cursor;
   -- Numero di righe corrispondente alla selezione indicata
   -- Almeno un attributo deve essere valido (non null)
   function count_rows /* SLAVE_COPY */
   ( p_QBE in number default 0
   , p_other_condition in varchar2 default null
   , p_ni  in varchar2 default null
, p_dal  in varchar2 default null
   , p_cognome  in varchar2 default null
   , p_nome  in varchar2 default null
   , p_sesso  in varchar2 default null
   , p_data_nas  in varchar2 default null
   , p_provincia_nas  in varchar2 default null
   , p_comune_nas  in varchar2 default null
   , p_luogo_nas  in varchar2 default null
   , p_codice_fiscale  in varchar2 default null
   , p_codice_fiscale_estero  in varchar2 default null
   , p_partita_iva  in varchar2 default null
   , p_cittadinanza  in varchar2 default null
   , p_gruppo_ling  in varchar2 default null
   , p_indirizzo_res  in varchar2 default null
   , p_provincia_res  in varchar2 default null
   , p_comune_res  in varchar2 default null
   , p_cap_res  in varchar2 default null
   , p_tel_res  in varchar2 default null
   , p_fax_res  in varchar2 default null
   , p_presso  in varchar2 default null
   , p_indirizzo_dom  in varchar2 default null
   , p_provincia_dom  in varchar2 default null
   , p_comune_dom  in varchar2 default null
   , p_cap_dom  in varchar2 default null
   , p_tel_dom  in varchar2 default null
   , p_fax_dom  in varchar2 default null
   , p_utente  in varchar2 default null
   , p_data_agg  in varchar2 default null
   , p_competenza  in varchar2 default null
   , p_tipo_soggetto  in varchar2 default null
   , p_flag_trg  in varchar2 default null
   , p_stato_cee  in varchar2 default null
   , p_partita_iva_cee  in varchar2 default null
   , p_fine_validita  in varchar2 default null
   , p_al  in varchar2 default null
   , p_denominazione  in varchar2 default null
   , p_indirizzo_web  in varchar2 default null
   , p_note  in varchar2 default null
   , p_competenza_esclusiva  in varchar2 default null
   , p_version  in varchar2 default null
   ) return integer;
end anagrafe_soggetti_tpk;
/

