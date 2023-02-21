CREATE OR REPLACE package recapiti_tpk is /* MASTER_LINK */
/******************************************************************************
 NOME:        recapiti_tpk
 DESCRIZIONE: Gestione tabella RECAPITI.
 ANNOTAZIONI: .
 REVISIONI:   Table Revision: 30/10/2017 09:07:11
              SiaPKGen Revision: V1.05.014.
              SiaTPKDeclare Revision: V1.17.001.
 <CODE>
 Rev.  Data        Autore      Descrizione.
 00    16/05/2017  snegroni  Generazione automatica. 
 01    16/05/2017  snegroni  Generazione automatica. 
 02    26/07/2017  snegroni  Generazione automatica. 
 03    30/10/2017  snegroni  Generazione automatica. 
 </CODE>
******************************************************************************/
   -- Revisione del Package
   s_revisione constant AFC.t_revision := 'V1.03';
   s_table_name constant AFC.t_object_name := 'RECAPITI';
   subtype t_rowtype is RECAPITI%rowtype;
   -- Tipo del record primary key
subtype t_id_recapito  is RECAPITI.id_recapito%type;
   type t_PK is record
   ( 
id_recapito  t_id_recapito
   );
   
    
   -- Versione e revisione
   function versione /* SLAVE_COPY */
   return varchar2;
   pragma restrict_references( versione, WNDS );
   -- Costruttore di record chiave
   function PK /* SLAVE_COPY */
   (
    p_id_recapito  in RECAPITI.id_recapito%type
   ) return t_PK;
   pragma restrict_references( PK, WNDS );
   -- Controllo integrita chiave
   function can_handle /* SLAVE_COPY */
   (
    p_id_recapito  in RECAPITI.id_recapito%type
   ) return number;
   pragma restrict_references( can_handle, WNDS );
   -- Controllo integrita chiave
   -- wrapper boolean 
   function canHandle /* SLAVE_COPY */
   (
    p_id_recapito  in RECAPITI.id_recapito%type
   ) return boolean;
   pragma restrict_references( canhandle, WNDS );
    -- Esistenza riga con chiave indicata
   function exists_id /* SLAVE_COPY */
   (
    p_id_recapito  in RECAPITI.id_recapito%type
   ) return number;
   pragma restrict_references( exists_id, WNDS );
   -- Esistenza riga con chiave indicata
   -- wrapper boolean
   function existsId /* SLAVE_COPY */
   (
    p_id_recapito  in RECAPITI.id_recapito%type
   ) return boolean;
   pragma restrict_references( existsid, WNDS );
   -- Inserimento di una riga
   procedure ins
   (
     p_id_recapito  in RECAPITI.id_recapito%type default null
   , p_ni  in RECAPITI.ni%type 
   , p_dal  in RECAPITI.dal%type 
   , p_al  in RECAPITI.al%type default null
   , p_descrizione  in RECAPITI.descrizione%type default null
   , p_id_tipo_recapito  in RECAPITI.id_tipo_recapito%type 
   , p_indirizzo  in RECAPITI.indirizzo%type default null
   , p_provincia  in RECAPITI.provincia%type default null
   , p_comune  in RECAPITI.comune%type default null
   , p_cap  in RECAPITI.cap%type default null
   , p_presso  in RECAPITI.presso%type default null
   , p_importanza  in RECAPITI.importanza%type default null
   , p_competenza  in RECAPITI.competenza%type default null
   , p_competenza_esclusiva  in RECAPITI.competenza_esclusiva%type default null
   , p_version  in RECAPITI.version%type default 0
   , p_utente_aggiornamento  in RECAPITI.utente_aggiornamento%type default null
   , p_data_aggiornamento  in RECAPITI.data_aggiornamento%type default null
   );
   function ins  /*+ SOA  */
   (
     p_id_recapito  in RECAPITI.id_recapito%type default null
   , p_ni  in RECAPITI.ni%type 
   , p_dal  in RECAPITI.dal%type 
   , p_al  in RECAPITI.al%type default null
   , p_descrizione  in RECAPITI.descrizione%type default null
   , p_id_tipo_recapito  in RECAPITI.id_tipo_recapito%type 
   , p_indirizzo  in RECAPITI.indirizzo%type default null
   , p_provincia in RECAPITI.provincia%type default null
   , p_comune  in RECAPITI.comune%type default null
   , p_cap  in RECAPITI.cap%type default null
   , p_presso  in RECAPITI.presso%type default null
   , p_importanza  in RECAPITI.importanza%type default null
   , p_competenza  in RECAPITI.competenza%type default null
   , p_competenza_esclusiva  in RECAPITI.competenza_esclusiva%type default null
   , p_version  in RECAPITI.version%type default 0
   , p_utente_aggiornamento  in RECAPITI.utente_aggiornamento%type default null
   , p_data_aggiornamento  in RECAPITI.data_aggiornamento%type default null
   ) return number;
   -- Aggiornamento di una riga
   procedure upd  /*+ SOA  */
   (
     p_check_OLD  in integer default 0
   , p_NEW_id_recapito  in RECAPITI.id_recapito%type
   , p_OLD_id_recapito  in RECAPITI.id_recapito%type default null
   , p_NEW_ni  in RECAPITI.ni%type default afc.default_null('RECAPITI.ni')
   , p_OLD_ni  in RECAPITI.ni%type default null
   , p_NEW_dal  in RECAPITI.dal%type default afc.default_null('RECAPITI.dal')
   , p_OLD_dal  in RECAPITI.dal%type default null
   , p_NEW_al  in RECAPITI.al%type default afc.default_null('RECAPITI.al')
   , p_OLD_al  in RECAPITI.al%type default null
   , p_NEW_descrizione  in RECAPITI.descrizione%type default afc.default_null('RECAPITI.descrizione')
   , p_OLD_descrizione  in RECAPITI.descrizione%type default null
   , p_NEW_id_tipo_recapito  in RECAPITI.id_tipo_recapito%type default afc.default_null('RECAPITI.id_tipo_recapito')
   , p_OLD_id_tipo_recapito  in RECAPITI.id_tipo_recapito%type default null
   , p_NEW_indirizzo  in RECAPITI.indirizzo%type default afc.default_null('RECAPITI.indirizzo')
   , p_OLD_indirizzo  in RECAPITI.indirizzo%type default null
   , p_NEW_provincia  in RECAPITI.provincia%type default afc.default_null('RECAPITI.provincia')
   , p_OLD_provincia  in RECAPITI.provincia%type default null
   , p_NEW_comune  in RECAPITI.comune%type default afc.default_null('RECAPITI.comune')
   , p_OLD_comune  in RECAPITI.comune%type default null
   , p_NEW_cap  in RECAPITI.cap%type default afc.default_null('RECAPITI.cap')
   , p_OLD_cap  in RECAPITI.cap%type default null
   , p_NEW_presso  in RECAPITI.presso%type default afc.default_null('RECAPITI.presso')
   , p_OLD_presso  in RECAPITI.presso%type default null
   , p_NEW_importanza  in RECAPITI.importanza%type default afc.default_null('RECAPITI.importanza')
   , p_OLD_importanza  in RECAPITI.importanza%type default null
   , p_NEW_competenza  in RECAPITI.competenza%type default afc.default_null('RECAPITI.competenza')
   , p_OLD_competenza  in RECAPITI.competenza%type default null
   , p_NEW_competenza_esclusiva  in RECAPITI.competenza_esclusiva%type default afc.default_null('RECAPITI.competenza_esclusiva')
   , p_OLD_competenza_esclusiva  in RECAPITI.competenza_esclusiva%type default null
   , p_NEW_version  in RECAPITI.version%type default afc.default_null('RECAPITI.version')
   , p_OLD_version  in RECAPITI.version%type default null
   , p_NEW_utente_aggiornamento  in RECAPITI.utente_aggiornamento%type default afc.default_null('RECAPITI.utente_aggiornamento')
   , p_OLD_utente_aggiornamento  in RECAPITI.utente_aggiornamento%type default null
   , p_NEW_data_aggiornamento  in RECAPITI.data_aggiornamento%type default afc.default_null('RECAPITI.data_aggiornamento')
   , p_OLD_data_aggiornamento  in RECAPITI.data_aggiornamento%type default null
   );
   -- Aggiornamento del campo di una riga
   procedure upd_column
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   , p_column         in varchar2
   , p_value          in varchar2 default null
   , p_literal_value  in number   default 1
   );
   procedure upd_column
   (
p_id_recapito  in RECAPITI.id_recapito%type
   , p_column in varchar2
   , p_value  in date
   );
   -- Cancellazione di una riga
   procedure del  /*+ SOA  */
   (
     p_check_OLD  in integer default 0
   , p_id_recapito  in RECAPITI.id_recapito%type
   , p_ni  in RECAPITI.ni%type default null
   , p_dal  in RECAPITI.dal%type default null
   , p_al  in RECAPITI.al%type default null
   , p_descrizione  in RECAPITI.descrizione%type default null
   , p_id_tipo_recapito  in RECAPITI.id_tipo_recapito%type default null
   , p_indirizzo  in RECAPITI.indirizzo%type default null
   , p_provincia  in RECAPITI.provincia%type default null
   , p_comune  in RECAPITI.comune%type default null
   , p_cap  in RECAPITI.cap%type default null
   , p_presso  in RECAPITI.presso%type default null
   , p_importanza  in RECAPITI.importanza%type default null
   , p_competenza  in RECAPITI.competenza%type default null
   , p_competenza_esclusiva  in RECAPITI.competenza_esclusiva%type default null
   , p_version  in RECAPITI.version%type default null
   , p_utente_aggiornamento  in RECAPITI.utente_aggiornamento%type default null
   , p_data_aggiornamento  in RECAPITI.data_aggiornamento%type default null
   );
-- Getter per attributo ni di riga identificata da chiave
   function get_ni /* SLAVE_COPY */ 
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   ) return RECAPITI.ni%type;
   pragma restrict_references( get_ni, WNDS );
-- Getter per attributo dal di riga identificata da chiave
   function get_dal /* SLAVE_COPY */ 
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   ) return RECAPITI.dal%type;
   pragma restrict_references( get_dal, WNDS );
-- Getter per attributo al di riga identificata da chiave
   function get_al /* SLAVE_COPY */ 
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   ) return RECAPITI.al%type;
   pragma restrict_references( get_al, WNDS );
-- Getter per attributo descrizione di riga identificata da chiave
   function get_descrizione /* SLAVE_COPY */ 
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   ) return RECAPITI.descrizione%type;
   pragma restrict_references( get_descrizione, WNDS );
-- Getter per attributo id_tipo_recapito di riga identificata da chiave
   function get_id_tipo_recapito /* SLAVE_COPY */ 
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   ) return RECAPITI.id_tipo_recapito%type;
   pragma restrict_references( get_id_tipo_recapito, WNDS );
-- Getter per attributo indirizzo di riga identificata da chiave
   function get_indirizzo /* SLAVE_COPY */ 
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   ) return RECAPITI.indirizzo%type;
   pragma restrict_references( get_indirizzo, WNDS );
-- Getter per attributo provincia di riga identificata da chiave
   function get_provincia /* SLAVE_COPY */ 
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   ) return RECAPITI.provincia%type;
   pragma restrict_references( get_provincia, WNDS );
-- Getter per attributo comune di riga identificata da chiave
   function get_comune /* SLAVE_COPY */ 
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   ) return RECAPITI.comune%type;
   pragma restrict_references( get_comune, WNDS );
-- Getter per attributo cap di riga identificata da chiave
   function get_cap /* SLAVE_COPY */ 
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   ) return RECAPITI.cap%type;
   pragma restrict_references( get_cap, WNDS );
-- Getter per attributo presso di riga identificata da chiave
   function get_presso /* SLAVE_COPY */ 
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   ) return RECAPITI.presso%type;
   pragma restrict_references( get_presso, WNDS );
-- Getter per attributo importanza di riga identificata da chiave
   function get_importanza /* SLAVE_COPY */ 
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   ) return RECAPITI.importanza%type;
   pragma restrict_references( get_importanza, WNDS );
-- Getter per attributo competenza di riga identificata da chiave
   function get_competenza /* SLAVE_COPY */ 
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   ) return RECAPITI.competenza%type;
   pragma restrict_references( get_competenza, WNDS );
-- Getter per attributo competenza_esclusiva di riga identificata da chiave
   function get_competenza_esclusiva /* SLAVE_COPY */ 
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   ) return RECAPITI.competenza_esclusiva%type;
   pragma restrict_references( get_competenza_esclusiva, WNDS );
-- Getter per attributo version di riga identificata da chiave
   function get_version /* SLAVE_COPY */ 
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   ) return RECAPITI.version%type;
   pragma restrict_references( get_version, WNDS );
-- Getter per attributo utente_aggiornamento di riga identificata da chiave
   function get_utente_aggiornamento /* SLAVE_COPY */ 
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   ) return RECAPITI.utente_aggiornamento%type;
   pragma restrict_references( get_utente_aggiornamento, WNDS );
-- Getter per attributo data_aggiornamento di riga identificata da chiave
   function get_data_aggiornamento /* SLAVE_COPY */ 
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   ) return RECAPITI.data_aggiornamento%type;
   pragma restrict_references( get_data_aggiornamento, WNDS );
-- Setter per attributo id_recapito di riga identificata da chiave
   procedure set_id_recapito
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   , p_value  in RECAPITI.id_recapito%type default null
   );
-- Setter per attributo ni di riga identificata da chiave
   procedure set_ni
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   , p_value  in RECAPITI.ni%type default null
   );
-- Setter per attributo dal di riga identificata da chiave
   procedure set_dal
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   , p_value  in RECAPITI.dal%type default null
   );
-- Setter per attributo al di riga identificata da chiave
   procedure set_al
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   , p_value  in RECAPITI.al%type default null
   );
-- Setter per attributo descrizione di riga identificata da chiave
   procedure set_descrizione
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   , p_value  in RECAPITI.descrizione%type default null
   );
-- Setter per attributo id_tipo_recapito di riga identificata da chiave
   procedure set_id_tipo_recapito
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   , p_value  in RECAPITI.id_tipo_recapito%type default null
   );
-- Setter per attributo indirizzo di riga identificata da chiave
   procedure set_indirizzo
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   , p_value  in RECAPITI.indirizzo%type default null
   );
-- Setter per attributo provincia di riga identificata da chiave
   procedure set_provincia
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   , p_value  in RECAPITI.provincia%type default null
   );
-- Setter per attributo comune di riga identificata da chiave
   procedure set_comune
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   , p_value  in RECAPITI.comune%type default null
   );
-- Setter per attributo cap di riga identificata da chiave
   procedure set_cap
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   , p_value  in RECAPITI.cap%type default null
   );
-- Setter per attributo presso di riga identificata da chiave
   procedure set_presso
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   , p_value  in RECAPITI.presso%type default null
   );
-- Setter per attributo importanza di riga identificata da chiave
   procedure set_importanza
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   , p_value  in RECAPITI.importanza%type default null
   );
-- Setter per attributo competenza di riga identificata da chiave
   procedure set_competenza
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   , p_value  in RECAPITI.competenza%type default null
   );
-- Setter per attributo competenza_esclusiva di riga identificata da chiave
   procedure set_competenza_esclusiva
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   , p_value  in RECAPITI.competenza_esclusiva%type default null
   );
-- Setter per attributo version di riga identificata da chiave
   procedure set_version
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   , p_value  in RECAPITI.version%type default null
   );
-- Setter per attributo utente_aggiornamento di riga identificata da chiave
   procedure set_utente_aggiornamento
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   , p_value  in RECAPITI.utente_aggiornamento%type default null
   );
-- Setter per attributo data_aggiornamento di riga identificata da chiave
   procedure set_data_aggiornamento
   (
     p_id_recapito  in RECAPITI.id_recapito%type
   , p_value  in RECAPITI.data_aggiornamento%type default null
   );
   -- where_condition per statement di ricerca
   function where_condition /* SLAVE_COPY */
   ( p_QBE  in number default 0
   , p_other_condition in varchar2 default null
   , p_id_recapito  in varchar2 default null
   , p_ni  in varchar2 default null
   , p_dal  in varchar2 default null
   , p_al  in varchar2 default null
   , p_descrizione  in varchar2 default null
   , p_id_tipo_recapito  in varchar2 default null
   , p_indirizzo  in varchar2 default null
   , p_provincia  in varchar2 default null
   , p_comune  in varchar2 default null
   , p_cap  in varchar2 default null
   , p_presso  in varchar2 default null
   , p_importanza  in varchar2 default null
   , p_competenza  in varchar2 default null
   , p_competenza_esclusiva  in varchar2 default null
   , p_version  in varchar2 default null
   , p_utente_aggiornamento  in varchar2 default null
   , p_data_aggiornamento  in varchar2 default null
   ) return AFC.t_statement;
   -- righe corrispondenti alla selezione indicata
   function get_rows  /*+ SOA  */ /* SLAVE_COPY */
   ( p_QBE  in number default 0
   , p_other_condition in varchar2 default null
   , p_order_by in varchar2 default null
   , p_extra_columns in varchar2 default null
   , p_extra_condition in varchar2 default null
   , p_id_recapito  in varchar2 default null
   , p_ni  in varchar2 default null
   , p_dal  in varchar2 default null
   , p_al  in varchar2 default null
   , p_descrizione  in varchar2 default null
   , p_id_tipo_recapito  in varchar2 default null
   , p_indirizzo  in varchar2 default null
   , p_provincia  in varchar2 default null
   , p_comune  in varchar2 default null
   , p_cap  in varchar2 default null
   , p_presso  in varchar2 default null
   , p_importanza  in varchar2 default null
   , p_competenza  in varchar2 default null
   , p_competenza_esclusiva  in varchar2 default null
   , p_version  in varchar2 default null
   , p_utente_aggiornamento  in varchar2 default null
   , p_data_aggiornamento  in varchar2 default null
   ) return AFC.t_ref_cursor;
   -- Numero di righe corrispondente alla selezione indicata
   -- Almeno un attributo deve essere valido (non null)
   function count_rows /* SLAVE_COPY */
   ( p_QBE in number default 0
   , p_other_condition in varchar2 default null
   , p_id_recapito  in varchar2 default null
   , p_ni  in varchar2 default null
   , p_dal  in varchar2 default null
   , p_al  in varchar2 default null
   , p_descrizione  in varchar2 default null
   , p_id_tipo_recapito  in varchar2 default null
   , p_indirizzo  in varchar2 default null
   , p_provincia  in varchar2 default null
   , p_comune  in varchar2 default null
   , p_cap  in varchar2 default null
   , p_presso  in varchar2 default null
   , p_importanza  in varchar2 default null
   , p_competenza  in varchar2 default null
   , p_competenza_esclusiva  in varchar2 default null
   , p_version  in varchar2 default null
   , p_utente_aggiornamento  in varchar2 default null
   , p_data_aggiornamento  in varchar2 default null
   ) return integer;
   
   
end recapiti_tpk;
/

