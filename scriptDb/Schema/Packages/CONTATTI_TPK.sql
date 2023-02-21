CREATE OR REPLACE package contatti_tpk is /* MASTER_LINK */
/******************************************************************************
 NOME:        contatti_tpk
 DESCRIZIONE: Gestione tabella CONTATTI.
 ANNOTAZIONI: .
 REVISIONI:   Table Revision: 26/07/2017 10:51:00
              SiaPKGen Revision: V1.05.014.
              SiaTPKDeclare Revision: V1.17.001.
 <CODE>
 Rev.  Data        Autore      Descrizione.
 00    16/05/2017  snegroni  Generazione automatica. 
 01    16/05/2017  snegroni  Generazione automatica. 
 02    16/05/2017  snegroni  Generazione automatica. 
 03    26/07/2017  snegroni  Generazione automatica. 
 </CODE>
******************************************************************************/
   -- Revisione del Package
   s_revisione constant AFC.t_revision := 'V1.03';
   s_table_name constant AFC.t_object_name := 'CONTATTI';
   subtype t_rowtype is CONTATTI%rowtype;
   -- Tipo del record primary key
subtype t_id_contatto  is CONTATTI.id_contatto%type;
   type t_PK is record
   ( 
id_contatto  t_id_contatto
   );
   -- Versione e revisione
   function versione /* SLAVE_COPY */
   return varchar2;
   pragma restrict_references( versione, WNDS );
   -- Costruttore di record chiave
   function PK /* SLAVE_COPY */
   (
    p_id_contatto  in CONTATTI.id_contatto%type
   ) return t_PK;
   pragma restrict_references( PK, WNDS );
   -- Controllo integrita chiave
   function can_handle /* SLAVE_COPY */
   (
    p_id_contatto  in CONTATTI.id_contatto%type
   ) return number;
   pragma restrict_references( can_handle, WNDS );
   -- Controllo integrita chiave
   -- wrapper boolean 
   function canHandle /* SLAVE_COPY */
   (
    p_id_contatto  in CONTATTI.id_contatto%type
   ) return boolean;
   pragma restrict_references( canhandle, WNDS );
    -- Esistenza riga con chiave indicata
   function exists_id /* SLAVE_COPY */
   (
    p_id_contatto  in CONTATTI.id_contatto%type
   ) return number;
   pragma restrict_references( exists_id, WNDS );
   -- Esistenza riga con chiave indicata
   -- wrapper boolean
   function existsId /* SLAVE_COPY */
   (
    p_id_contatto  in CONTATTI.id_contatto%type
   ) return boolean;
   pragma restrict_references( existsid, WNDS );
   -- Inserimento di una riga
   procedure ins
   (
     p_id_contatto  in CONTATTI.id_contatto%type default null
   , p_id_recapito  in CONTATTI.id_recapito%type 
   , p_dal  in CONTATTI.dal%type 
   , p_al  in CONTATTI.al%type default null
   , p_valore  in CONTATTI.valore%type 
   , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type 
   , p_note  in CONTATTI.note%type default null
   , p_importanza  in CONTATTI.importanza%type default null
   , p_competenza  in CONTATTI.competenza%type default null
   , p_competenza_esclusiva  in CONTATTI.competenza_esclusiva%type default null
   , p_version  in CONTATTI.version%type default null
   , p_utente_aggiornamento  in CONTATTI.utente_aggiornamento%type default null
   , p_data_aggiornamento  in CONTATTI.data_aggiornamento%type default null
   );
   function ins  /*+ SOA  */
   (
     p_id_contatto  in CONTATTI.id_contatto%type default null
   , p_id_recapito  in CONTATTI.id_recapito%type 
   , p_dal  in CONTATTI.dal%type 
   , p_al  in CONTATTI.al%type default null
   , p_valore  in CONTATTI.valore%type 
   , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type 
   , p_note  in CONTATTI.note%type default null
   , p_importanza  in CONTATTI.importanza%type default null
   , p_competenza  in CONTATTI.competenza%type default null
   , p_competenza_esclusiva  in CONTATTI.competenza_esclusiva%type default null
   , p_version  in CONTATTI.version%type default null
   , p_utente_aggiornamento  in CONTATTI.utente_aggiornamento%type default null
   , p_data_aggiornamento  in CONTATTI.data_aggiornamento%type default null
   ) return number;
   -- Aggiornamento di una riga
   procedure upd  /*+ SOA  */
   (
     p_check_OLD  in integer default 0
   , p_NEW_id_contatto  in CONTATTI.id_contatto%type
   , p_OLD_id_contatto  in CONTATTI.id_contatto%type default null
   , p_NEW_id_recapito  in CONTATTI.id_recapito%type default afc.default_null('CONTATTI.id_recapito')
   , p_OLD_id_recapito  in CONTATTI.id_recapito%type default null
   , p_NEW_dal  in CONTATTI.dal%type default afc.default_null('CONTATTI.dal')
   , p_OLD_dal  in CONTATTI.dal%type default null
   , p_NEW_al  in CONTATTI.al%type default afc.default_null('CONTATTI.al')
   , p_OLD_al  in CONTATTI.al%type default null
   , p_NEW_valore  in CONTATTI.valore%type default afc.default_null('CONTATTI.valore')
   , p_OLD_valore  in CONTATTI.valore%type default null
   , p_NEW_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type default afc.default_null('CONTATTI.id_tipo_contatto')
   , p_OLD_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type default null
   , p_NEW_note  in CONTATTI.note%type default afc.default_null('CONTATTI.note')
   , p_OLD_note  in CONTATTI.note%type default null
   , p_NEW_importanza  in CONTATTI.importanza%type default afc.default_null('CONTATTI.importanza')
   , p_OLD_importanza  in CONTATTI.importanza%type default null
   , p_NEW_competenza  in CONTATTI.competenza%type default afc.default_null('CONTATTI.competenza')
   , p_OLD_competenza  in CONTATTI.competenza%type default null
   , p_NEW_competenza_esclusiva  in CONTATTI.competenza_esclusiva%type default afc.default_null('CONTATTI.competenza_esclusiva')
   , p_OLD_competenza_esclusiva  in CONTATTI.competenza_esclusiva%type default null
   , p_NEW_version  in CONTATTI.version%type default afc.default_null('CONTATTI.version')
   , p_OLD_version  in CONTATTI.version%type default null
   , p_NEW_utente_aggiornamento  in CONTATTI.utente_aggiornamento%type default afc.default_null('CONTATTI.utente_aggiornamento')
   , p_OLD_utente_aggiornamento  in CONTATTI.utente_aggiornamento%type default null
   , p_NEW_data_aggiornamento  in CONTATTI.data_aggiornamento%type default afc.default_null('CONTATTI.data_aggiornamento')
   , p_OLD_data_aggiornamento  in CONTATTI.data_aggiornamento%type default null
   );
   -- Aggiornamento del campo di una riga
   procedure upd_column
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   , p_column         in varchar2
   , p_value          in varchar2 default null
   , p_literal_value  in number   default 1
   );
   procedure upd_column
   (
p_id_contatto  in CONTATTI.id_contatto%type
   , p_column in varchar2
   , p_value  in date
   );
   -- Cancellazione di una riga
   procedure del  /*+ SOA  */
   (
     p_check_OLD  in integer default 0
   , p_id_contatto  in CONTATTI.id_contatto%type
   , p_id_recapito  in CONTATTI.id_recapito%type default null
   , p_dal  in CONTATTI.dal%type default null
   , p_al  in CONTATTI.al%type default null
   , p_valore  in CONTATTI.valore%type default null
   , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type default null
   , p_note  in CONTATTI.note%type default null
   , p_importanza  in CONTATTI.importanza%type default null
   , p_competenza  in CONTATTI.competenza%type default null
   , p_competenza_esclusiva  in CONTATTI.competenza_esclusiva%type default null
   , p_version  in CONTATTI.version%type default null
   , p_utente_aggiornamento  in CONTATTI.utente_aggiornamento%type default null
   , p_data_aggiornamento  in CONTATTI.data_aggiornamento%type default null
   );
-- Getter per attributo id_recapito di riga identificata da chiave
   function get_id_recapito /* SLAVE_COPY */ 
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   ) return CONTATTI.id_recapito%type;
   pragma restrict_references( get_id_recapito, WNDS );
-- Getter per attributo dal di riga identificata da chiave
   function get_dal /* SLAVE_COPY */ 
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   ) return CONTATTI.dal%type;
   pragma restrict_references( get_dal, WNDS );
-- Getter per attributo al di riga identificata da chiave
   function get_al /* SLAVE_COPY */ 
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   ) return CONTATTI.al%type;
   pragma restrict_references( get_al, WNDS );
-- Getter per attributo valore di riga identificata da chiave
   function get_valore /* SLAVE_COPY */ 
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   ) return CONTATTI.valore%type;
   pragma restrict_references( get_valore, WNDS );
-- Getter per attributo id_tipo_contatto di riga identificata da chiave
   function get_id_tipo_contatto /* SLAVE_COPY */ 
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   ) return CONTATTI.id_tipo_contatto%type;
   pragma restrict_references( get_id_tipo_contatto, WNDS );
-- Getter per attributo note di riga identificata da chiave
   function get_note /* SLAVE_COPY */ 
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   ) return CONTATTI.note%type;
   pragma restrict_references( get_note, WNDS );
-- Getter per attributo importanza di riga identificata da chiave
   function get_importanza /* SLAVE_COPY */ 
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   ) return CONTATTI.importanza%type;
   pragma restrict_references( get_importanza, WNDS );
-- Getter per attributo competenza di riga identificata da chiave
   function get_competenza /* SLAVE_COPY */ 
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   ) return CONTATTI.competenza%type;
   pragma restrict_references( get_competenza, WNDS );
-- Getter per attributo competenza_esclusiva di riga identificata da chiave
   function get_competenza_esclusiva /* SLAVE_COPY */ 
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   ) return CONTATTI.competenza_esclusiva%type;
   pragma restrict_references( get_competenza_esclusiva, WNDS );
-- Getter per attributo version di riga identificata da chiave
   function get_version /* SLAVE_COPY */ 
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   ) return CONTATTI.version%type;
   pragma restrict_references( get_version, WNDS );
-- Getter per attributo utente_aggiornamento di riga identificata da chiave
   function get_utente_aggiornamento /* SLAVE_COPY */ 
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   ) return CONTATTI.utente_aggiornamento%type;
   pragma restrict_references( get_utente_aggiornamento, WNDS );
-- Getter per attributo data_aggiornamento di riga identificata da chiave
   function get_data_aggiornamento /* SLAVE_COPY */ 
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   ) return CONTATTI.data_aggiornamento%type;
   pragma restrict_references( get_data_aggiornamento, WNDS );
-- Setter per attributo id_contatto di riga identificata da chiave
   procedure set_id_contatto
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   , p_value  in CONTATTI.id_contatto%type default null
   );
-- Setter per attributo id_recapito di riga identificata da chiave
   procedure set_id_recapito
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   , p_value  in CONTATTI.id_recapito%type default null
   );
-- Setter per attributo dal di riga identificata da chiave
   procedure set_dal
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   , p_value  in CONTATTI.dal%type default null
   );
-- Setter per attributo al di riga identificata da chiave
   procedure set_al
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   , p_value  in CONTATTI.al%type default null
   );
-- Setter per attributo valore di riga identificata da chiave
   procedure set_valore
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   , p_value  in CONTATTI.valore%type default null
   );
-- Setter per attributo id_tipo_contatto di riga identificata da chiave
   procedure set_id_tipo_contatto
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   , p_value  in CONTATTI.id_tipo_contatto%type default null
   );
-- Setter per attributo note di riga identificata da chiave
   procedure set_note
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   , p_value  in CONTATTI.note%type default null
   );
-- Setter per attributo importanza di riga identificata da chiave
   procedure set_importanza
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   , p_value  in CONTATTI.importanza%type default null
   );
-- Setter per attributo competenza di riga identificata da chiave
   procedure set_competenza
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   , p_value  in CONTATTI.competenza%type default null
   );
-- Setter per attributo competenza_esclusiva di riga identificata da chiave
   procedure set_competenza_esclusiva
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   , p_value  in CONTATTI.competenza_esclusiva%type default null
   );
-- Setter per attributo version di riga identificata da chiave
   procedure set_version
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   , p_value  in CONTATTI.version%type default null
   );
-- Setter per attributo utente_aggiornamento di riga identificata da chiave
   procedure set_utente_aggiornamento
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   , p_value  in CONTATTI.utente_aggiornamento%type default null
   );
-- Setter per attributo data_aggiornamento di riga identificata da chiave
   procedure set_data_aggiornamento
   (
     p_id_contatto  in CONTATTI.id_contatto%type
   , p_value  in CONTATTI.data_aggiornamento%type default null
   );
   -- where_condition per statement di ricerca
   function where_condition /* SLAVE_COPY */
   ( p_QBE  in number default 0
   , p_other_condition in varchar2 default null
   , p_id_contatto  in varchar2 default null
   , p_id_recapito  in varchar2 default null
   , p_dal  in varchar2 default null
   , p_al  in varchar2 default null
   , p_valore  in varchar2 default null
   , p_id_tipo_contatto  in varchar2 default null
   , p_note  in varchar2 default null
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
   , p_id_contatto  in varchar2 default null
   , p_id_recapito  in varchar2 default null
   , p_dal  in varchar2 default null
   , p_al  in varchar2 default null
   , p_valore  in varchar2 default null
   , p_id_tipo_contatto  in varchar2 default null
   , p_note  in varchar2 default null
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
   , p_id_contatto  in varchar2 default null
   , p_id_recapito  in varchar2 default null
   , p_dal  in varchar2 default null
   , p_al  in varchar2 default null
   , p_valore  in varchar2 default null
   , p_id_tipo_contatto  in varchar2 default null
   , p_note  in varchar2 default null
   , p_importanza  in varchar2 default null
   , p_competenza  in varchar2 default null
   , p_competenza_esclusiva  in varchar2 default null
   , p_version  in varchar2 default null
   , p_utente_aggiornamento  in varchar2 default null
   , p_data_aggiornamento  in varchar2 default null
   ) return integer;
end contatti_tpk;
/

