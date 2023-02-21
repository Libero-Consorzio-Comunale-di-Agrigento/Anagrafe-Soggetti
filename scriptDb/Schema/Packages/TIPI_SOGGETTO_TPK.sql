CREATE OR REPLACE package tipi_soggetto_tpk is /* MASTER_LINK */
/******************************************************************************
 NOME:        tipi_soggetto_tpk
 DESCRIZIONE: Gestione tabella TIPI_SOGGETTO.
 ANNOTAZIONI: .
 REVISIONI:   Table Revision: 14/06/2018 17:41:33
              SiaPKGen Revision: V2.00.001.
              SiaTPKDeclare Revision: V2.03.000.
 <CODE>
 Rev.  Data        Autore      Descrizione.
 00    14/05/2009  mmalferrari  Prima emissione.
 01    24/07/2017  snegroni  Generazione automatica. 
 02    14/06/2018  snegroni  Generazione automatica. 
 </CODE>
******************************************************************************/
   -- Revisione del Package
   s_revisione constant AFC.t_revision := 'V1.02';
   s_table_name constant AFC.t_object_name := 'TIPI_SOGGETTO';
   subtype t_rowtype is TIPI_SOGGETTO%rowtype;
   -- Tipo del record primary key
subtype t_tipo_soggetto  is TIPI_SOGGETTO.tipo_soggetto%type;
   type t_PK is record
   ( 
tipo_soggetto  t_tipo_soggetto
   );
   -- Versione e revisione
   function versione /* SLAVE_COPY */
   return varchar2;
   pragma restrict_references( versione, WNDS );
   -- Costruttore di record chiave
   function PK /* SLAVE_COPY */
   (
    p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   ) return t_PK;
   pragma restrict_references( PK, WNDS );
   -- Controllo integrita chiave
   function can_handle /* SLAVE_COPY */
   (
    p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   ) return number;
   pragma restrict_references( can_handle, WNDS );
   -- Controllo integrita chiave
   -- wrapper boolean 
   function canHandle /* SLAVE_COPY */
   (
    p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   ) return boolean;
   pragma restrict_references( canhandle, WNDS );
    -- Esistenza riga con chiave indicata
   function exists_id /* SLAVE_COPY */
   (
    p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   ) return number;
   pragma restrict_references( exists_id, WNDS );
   -- Esistenza riga con chiave indicata
   -- wrapper boolean
   function existsId /* SLAVE_COPY */
   (
    p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   ) return boolean;
   pragma restrict_references( existsid, WNDS );
   -- Inserimento di una riga
   procedure ins
   (
     p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type 
   , p_descrizione  in TIPI_SOGGETTO.descrizione%type 
   , p_flag_trg  in TIPI_SOGGETTO.flag_trg%type default null
   , p_version  in TIPI_SOGGETTO.version%type default null
   , p_utente_aggiornamento  in TIPI_SOGGETTO.utente_aggiornamento%type default null
   , p_data_aggiornamento  in TIPI_SOGGETTO.data_aggiornamento%type default null
   , p_categoria_tipo_soggetto  in TIPI_SOGGETTO.categoria_tipo_soggetto%type default 'PF'
   );
   function ins  /*+ SOA  */
   (
     p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type 
   , p_descrizione  in TIPI_SOGGETTO.descrizione%type 
   , p_flag_trg  in TIPI_SOGGETTO.flag_trg%type default null
   , p_version  in TIPI_SOGGETTO.version%type default null
   , p_utente_aggiornamento  in TIPI_SOGGETTO.utente_aggiornamento%type default null
   , p_data_aggiornamento  in TIPI_SOGGETTO.data_aggiornamento%type default null
   , p_categoria_tipo_soggetto  in TIPI_SOGGETTO.categoria_tipo_soggetto%type default 'PF'
   ) return number;
   -- Aggiornamento di una riga
   procedure upd  /*+ SOA  */
   (
     p_check_OLD  in integer default 0
   , p_NEW_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   , p_OLD_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type default null
   , p_NEW_descrizione  in TIPI_SOGGETTO.descrizione%type default afc.default_null('TIPI_SOGGETTO.descrizione')
   , p_OLD_descrizione  in TIPI_SOGGETTO.descrizione%type default null
   , p_NEW_flag_trg  in TIPI_SOGGETTO.flag_trg%type default afc.default_null('TIPI_SOGGETTO.flag_trg')
   , p_OLD_flag_trg  in TIPI_SOGGETTO.flag_trg%type default null
   , p_NEW_version  in TIPI_SOGGETTO.version%type default afc.default_null('TIPI_SOGGETTO.version')
   , p_OLD_version  in TIPI_SOGGETTO.version%type default null
   , p_NEW_utente_aggiornamento  in TIPI_SOGGETTO.utente_aggiornamento%type default afc.default_null('TIPI_SOGGETTO.utente_aggiornamento')
   , p_OLD_utente_aggiornamento  in TIPI_SOGGETTO.utente_aggiornamento%type default null
   , p_NEW_data_aggiornamento  in TIPI_SOGGETTO.data_aggiornamento%type default afc.default_null('TIPI_SOGGETTO.data_aggiornamento')
   , p_OLD_data_aggiornamento  in TIPI_SOGGETTO.data_aggiornamento%type default null
   , p_NEW_categoria_tipo_soggetto  in TIPI_SOGGETTO.categoria_tipo_soggetto%type default afc.default_null('TIPI_SOGGETTO.categoria_tipo_soggetto')
   , p_OLD_categoria_tipo_soggetto  in TIPI_SOGGETTO.categoria_tipo_soggetto%type default null
   );
   -- Aggiornamento del campo di una riga
   procedure upd_column
   (
     p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   , p_column         in varchar2
   , p_value          in varchar2 default null
   , p_literal_value  in number   default 1
   );
   procedure upd_column
   (
p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   , p_column in varchar2
   , p_value  in date
   );
   -- Cancellazione di una riga
   procedure del  /*+ SOA  */
   (
     p_check_OLD  in integer default 0
   , p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   , p_descrizione  in TIPI_SOGGETTO.descrizione%type default null
   , p_flag_trg  in TIPI_SOGGETTO.flag_trg%type default null
   , p_version  in TIPI_SOGGETTO.version%type default null
   , p_utente_aggiornamento  in TIPI_SOGGETTO.utente_aggiornamento%type default null
   , p_data_aggiornamento  in TIPI_SOGGETTO.data_aggiornamento%type default null
   , p_categoria_tipo_soggetto  in TIPI_SOGGETTO.categoria_tipo_soggetto%type default null
   );
-- Getter per attributo descrizione di riga identificata da chiave
   function get_descrizione /* SLAVE_COPY */ 
   (
     p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   ) return TIPI_SOGGETTO.descrizione%type;
   pragma restrict_references( get_descrizione, WNDS );
-- Getter per attributo flag_trg di riga identificata da chiave
   function get_flag_trg /* SLAVE_COPY */ 
   (
     p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   ) return TIPI_SOGGETTO.flag_trg%type;
   pragma restrict_references( get_flag_trg, WNDS );
-- Getter per attributo version di riga identificata da chiave
   function get_version /* SLAVE_COPY */ 
   (
     p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   ) return TIPI_SOGGETTO.version%type;
   pragma restrict_references( get_version, WNDS );
-- Getter per attributo utente_aggiornamento di riga identificata da chiave
   function get_utente_aggiornamento /* SLAVE_COPY */ 
   (
     p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   ) return TIPI_SOGGETTO.utente_aggiornamento%type;
   pragma restrict_references( get_utente_aggiornamento, WNDS );
-- Getter per attributo data_aggiornamento di riga identificata da chiave
   function get_data_aggiornamento /* SLAVE_COPY */ 
   (
     p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   ) return TIPI_SOGGETTO.data_aggiornamento%type;
   pragma restrict_references( get_data_aggiornamento, WNDS );
-- Getter per attributo categoria_tipo_soggetto di riga identificata da chiave
   function get_categoria_tipo_soggetto /* SLAVE_COPY */ 
   (
     p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   ) return TIPI_SOGGETTO.categoria_tipo_soggetto%type;
   pragma restrict_references( get_categoria_tipo_soggetto, WNDS );
-- Setter per attributo tipo_soggetto di riga identificata da chiave
   procedure set_tipo_soggetto
   (
     p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   , p_value  in TIPI_SOGGETTO.tipo_soggetto%type default null
   );
-- Setter per attributo descrizione di riga identificata da chiave
   procedure set_descrizione
   (
     p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   , p_value  in TIPI_SOGGETTO.descrizione%type default null
   );
-- Setter per attributo flag_trg di riga identificata da chiave
   procedure set_flag_trg
   (
     p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   , p_value  in TIPI_SOGGETTO.flag_trg%type default null
   );
-- Setter per attributo version di riga identificata da chiave
   procedure set_version
   (
     p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   , p_value  in TIPI_SOGGETTO.version%type default null
   );
-- Setter per attributo utente_aggiornamento di riga identificata da chiave
   procedure set_utente_aggiornamento
   (
     p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   , p_value  in TIPI_SOGGETTO.utente_aggiornamento%type default null
   );
-- Setter per attributo data_aggiornamento di riga identificata da chiave
   procedure set_data_aggiornamento
   (
     p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   , p_value  in TIPI_SOGGETTO.data_aggiornamento%type default null
   );
-- Setter per attributo categoria_tipo_soggetto di riga identificata da chiave
   procedure set_categoria_tipo_soggetto
   (
     p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
   , p_value  in TIPI_SOGGETTO.categoria_tipo_soggetto%type default null
   );
   -- where_condition per statement di ricerca
   function where_condition /* SLAVE_COPY */
   ( p_QBE  in number default 0
   , p_other_condition in varchar2 default null
   , p_tipo_soggetto  in varchar2 default null
   , p_descrizione  in varchar2 default null
   , p_flag_trg  in varchar2 default null
   , p_version  in varchar2 default null
   , p_utente_aggiornamento  in varchar2 default null
   , p_data_aggiornamento  in varchar2 default null
   , p_categoria_tipo_soggetto  in varchar2 default null
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
   , p_tipo_soggetto  in varchar2 default null
   , p_descrizione  in varchar2 default null
   , p_flag_trg  in varchar2 default null
   , p_version  in varchar2 default null
   , p_utente_aggiornamento  in varchar2 default null
   , p_data_aggiornamento  in varchar2 default null
   , p_categoria_tipo_soggetto  in varchar2 default null
   ) return AFC.t_ref_cursor;
   -- Numero di righe corrispondente alla selezione indicata
   -- Almeno un attributo deve essere valido (non null)
   function count_rows /* SLAVE_COPY */
   ( p_QBE in number default 0
   , p_other_condition in varchar2 default null
   , p_extra_condition in varchar2 default null
   , p_columns in varchar2 default null
   , p_tipo_soggetto  in varchar2 default null
   , p_descrizione  in varchar2 default null
   , p_flag_trg  in varchar2 default null
   , p_version  in varchar2 default null
   , p_utente_aggiornamento  in varchar2 default null
   , p_data_aggiornamento  in varchar2 default null
   , p_categoria_tipo_soggetto  in varchar2 default null
   ) return integer;
end tipi_soggetto_tpk;
/

