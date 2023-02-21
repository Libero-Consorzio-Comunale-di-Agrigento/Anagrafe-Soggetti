CREATE OR REPLACE package tipi_recapito_tpk is /* MASTER_LINK */
/******************************************************************************
 NOME:        tipi_recapito_tpk
 DESCRIZIONE: Gestione tabella TIPI_RECAPITO.
 ANNOTAZIONI: .
 REVISIONI:   Table Revision: 26/07/2017 11:18:10
              SiaPKGen Revision: V1.05.014.
              SiaTPKDeclare Revision: V1.17.001.
 <CODE>
 Rev.  Data        Autore      Descrizione.
 00    26/07/2017  snegroni  Generazione automatica. 
 01    26/07/2017  snegroni  Generazione automatica. 
 </CODE>
******************************************************************************/
   -- Revisione del Package
   s_revisione constant AFC.t_revision := 'V1.01';
   s_table_name constant AFC.t_object_name := 'TIPI_RECAPITO';
   subtype t_rowtype is TIPI_RECAPITO%rowtype;
   -- Tipo del record primary key
subtype t_id_tipo_recapito  is TIPI_RECAPITO.id_tipo_recapito%type;
   type t_PK is record
   ( 
id_tipo_recapito  t_id_tipo_recapito
   );
   -- Versione e revisione
   function versione /* SLAVE_COPY */
   return varchar2;
   pragma restrict_references( versione, WNDS );
   -- Costruttore di record chiave
   function PK /* SLAVE_COPY */
   (
    p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   ) return t_PK;
   pragma restrict_references( PK, WNDS );
   -- Controllo integrita chiave
   function can_handle /* SLAVE_COPY */
   (
    p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   ) return number;
   pragma restrict_references( can_handle, WNDS );
   -- Controllo integrita chiave
   -- wrapper boolean 
   function canHandle /* SLAVE_COPY */
   (
    p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   ) return boolean;
   pragma restrict_references( canhandle, WNDS );
    -- Esistenza riga con chiave indicata
   function exists_id /* SLAVE_COPY */
   (
    p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   ) return number;
   pragma restrict_references( exists_id, WNDS );
   -- Esistenza riga con chiave indicata
   -- wrapper boolean
   function existsId /* SLAVE_COPY */
   (
    p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   ) return boolean;
   pragma restrict_references( existsid, WNDS );
   -- Inserimento di una riga
   procedure ins
   (
     p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type default null
   , p_descrizione  in TIPI_RECAPITO.descrizione%type 
   , p_unico  in TIPI_RECAPITO.unico%type default 'NO'
   , p_importanza  in TIPI_RECAPITO.importanza%type default null
   , p_version  in TIPI_RECAPITO.version%type default null
   , p_utente_aggiornamento  in TIPI_RECAPITO.utente_aggiornamento%type default null
   , p_data_aggiornamento  in TIPI_RECAPITO.data_aggiornamento%type default null
   );
   function ins  /*+ SOA  */
   (
     p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type default null
   , p_descrizione  in TIPI_RECAPITO.descrizione%type 
   , p_unico  in TIPI_RECAPITO.unico%type default 'NO'
   , p_importanza  in TIPI_RECAPITO.importanza%type default null
   , p_version  in TIPI_RECAPITO.version%type default null
   , p_utente_aggiornamento  in TIPI_RECAPITO.utente_aggiornamento%type default null
   , p_data_aggiornamento  in TIPI_RECAPITO.data_aggiornamento%type default null
   ) return number;
   -- Aggiornamento di una riga
   procedure upd  /*+ SOA  */
   (
     p_check_OLD  in integer default 0
   , p_NEW_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   , p_OLD_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type default null
   , p_NEW_descrizione  in TIPI_RECAPITO.descrizione%type default afc.default_null('TIPI_RECAPITO.descrizione')
   , p_OLD_descrizione  in TIPI_RECAPITO.descrizione%type default null
   , p_NEW_unico  in TIPI_RECAPITO.unico%type default afc.default_null('TIPI_RECAPITO.unico')
   , p_OLD_unico  in TIPI_RECAPITO.unico%type default null
   , p_NEW_importanza  in TIPI_RECAPITO.importanza%type default afc.default_null('TIPI_RECAPITO.importanza')
   , p_OLD_importanza  in TIPI_RECAPITO.importanza%type default null
   , p_NEW_version  in TIPI_RECAPITO.version%type default afc.default_null('TIPI_RECAPITO.version')
   , p_OLD_version  in TIPI_RECAPITO.version%type default null
   , p_NEW_utente_aggiornamento  in TIPI_RECAPITO.utente_aggiornamento%type default afc.default_null('TIPI_RECAPITO.utente_aggiornamento')
   , p_OLD_utente_aggiornamento  in TIPI_RECAPITO.utente_aggiornamento%type default null
   , p_NEW_data_aggiornamento  in TIPI_RECAPITO.data_aggiornamento%type default afc.default_null('TIPI_RECAPITO.data_aggiornamento')
   , p_OLD_data_aggiornamento  in TIPI_RECAPITO.data_aggiornamento%type default null
   );
   -- Aggiornamento del campo di una riga
   procedure upd_column
   (
     p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   , p_column         in varchar2
   , p_value          in varchar2 default null
   , p_literal_value  in number   default 1
   );
   procedure upd_column
   (
p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   , p_column in varchar2
   , p_value  in date
   );
   -- Cancellazione di una riga
   procedure del  /*+ SOA  */
   (
     p_check_OLD  in integer default 0
   , p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   , p_descrizione  in TIPI_RECAPITO.descrizione%type default null
   , p_unico  in TIPI_RECAPITO.unico%type default null
   , p_importanza  in TIPI_RECAPITO.importanza%type default null
   , p_version  in TIPI_RECAPITO.version%type default null
   , p_utente_aggiornamento  in TIPI_RECAPITO.utente_aggiornamento%type default null
   , p_data_aggiornamento  in TIPI_RECAPITO.data_aggiornamento%type default null
   );
-- Getter per attributo descrizione di riga identificata da chiave
   function get_descrizione /* SLAVE_COPY */ 
   (
     p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   ) return TIPI_RECAPITO.descrizione%type;
   pragma restrict_references( get_descrizione, WNDS );
-- Getter per attributo unico di riga identificata da chiave
   function get_unico /* SLAVE_COPY */ 
   (
     p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   ) return TIPI_RECAPITO.unico%type;
   pragma restrict_references( get_unico, WNDS );
-- Getter per attributo importanza di riga identificata da chiave
   function get_importanza /* SLAVE_COPY */ 
   (
     p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   ) return TIPI_RECAPITO.importanza%type;
   pragma restrict_references( get_importanza, WNDS );
-- Getter per attributo version di riga identificata da chiave
   function get_version /* SLAVE_COPY */ 
   (
     p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   ) return TIPI_RECAPITO.version%type;
   pragma restrict_references( get_version, WNDS );
-- Getter per attributo utente_aggiornamento di riga identificata da chiave
   function get_utente_aggiornamento /* SLAVE_COPY */ 
   (
     p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   ) return TIPI_RECAPITO.utente_aggiornamento%type;
   pragma restrict_references( get_utente_aggiornamento, WNDS );
-- Getter per attributo data_aggiornamento di riga identificata da chiave
   function get_data_aggiornamento /* SLAVE_COPY */ 
   (
     p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   ) return TIPI_RECAPITO.data_aggiornamento%type;
   pragma restrict_references( get_data_aggiornamento, WNDS );
-- Setter per attributo id_tipo_recapito di riga identificata da chiave
   procedure set_id_tipo_recapito
   (
     p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   , p_value  in TIPI_RECAPITO.id_tipo_recapito%type default null
   );
-- Setter per attributo descrizione di riga identificata da chiave
   procedure set_descrizione
   (
     p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   , p_value  in TIPI_RECAPITO.descrizione%type default null
   );
-- Setter per attributo unico di riga identificata da chiave
   procedure set_unico
   (
     p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   , p_value  in TIPI_RECAPITO.unico%type default null
   );
-- Setter per attributo importanza di riga identificata da chiave
   procedure set_importanza
   (
     p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   , p_value  in TIPI_RECAPITO.importanza%type default null
   );
-- Setter per attributo version di riga identificata da chiave
   procedure set_version
   (
     p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   , p_value  in TIPI_RECAPITO.version%type default null
   );
-- Setter per attributo utente_aggiornamento di riga identificata da chiave
   procedure set_utente_aggiornamento
   (
     p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   , p_value  in TIPI_RECAPITO.utente_aggiornamento%type default null
   );
-- Setter per attributo data_aggiornamento di riga identificata da chiave
   procedure set_data_aggiornamento
   (
     p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
   , p_value  in TIPI_RECAPITO.data_aggiornamento%type default null
   );
   -- where_condition per statement di ricerca
   function where_condition /* SLAVE_COPY */
   ( p_QBE  in number default 0
   , p_other_condition in varchar2 default null
   , p_id_tipo_recapito  in varchar2 default null
   , p_descrizione  in varchar2 default null
   , p_unico  in varchar2 default null
   , p_importanza  in varchar2 default null
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
   , p_id_tipo_recapito  in varchar2 default null
   , p_descrizione  in varchar2 default null
   , p_unico  in varchar2 default null
   , p_importanza  in varchar2 default null
   , p_version  in varchar2 default null
   , p_utente_aggiornamento  in varchar2 default null
   , p_data_aggiornamento  in varchar2 default null
   ) return AFC.t_ref_cursor;
   -- Numero di righe corrispondente alla selezione indicata
   -- Almeno un attributo deve essere valido (non null)
   function count_rows /* SLAVE_COPY */
   ( p_QBE in number default 0
   , p_other_condition in varchar2 default null
   , p_id_tipo_recapito  in varchar2 default null
   , p_descrizione  in varchar2 default null
   , p_unico  in varchar2 default null
   , p_importanza  in varchar2 default null
   , p_version  in varchar2 default null
   , p_utente_aggiornamento  in varchar2 default null
   , p_data_aggiornamento  in varchar2 default null
   ) return integer;
end tipi_recapito_tpk;
/

