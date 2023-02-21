CREATE OR REPLACE PACKAGE key_error_log_tpk is /* MASTER_LINK */
/******************************************************************************
 NOME:        key_error_log_tpk
 DESCRIZIONE: Gestione tabella KEY_ERROR_LOG.
 ANNOTAZIONI: .
 REVISIONI:   Template Revision: 1.53.
 <CODE>
 Rev.  Data       Autore  Descrizione.
 00    11/05/2009  mmalferrari  Prima emissione.
 </CODE>
******************************************************************************/
   -- Revisione del Package
   s_revisione constant AFC.t_revision := 'V1.00';
   s_table_name constant AFC.t_object_name := 'KEY_ERROR_LOG';
   subtype t_rowtype is KEY_ERROR_LOG%rowtype;
   -- Tipo del record primary key
   subtype t_error_id  is KEY_ERROR_LOG.error_id%type;
   type t_PK is record
   (
    error_id  t_error_id
   );
   -- Versione e revisione
   function versione /* SLAVE_COPY */
   return varchar2;
   pragma restrict_references( versione, WNDS );
   -- Costruttore di record chiave
   function PK /* SLAVE_COPY */
   (
    p_error_id  in KEY_ERROR_LOG.error_id%type
   ) return t_PK;
   pragma restrict_references( PK, WNDS );
   -- Controllo integrita chiave
   function can_handle /* SLAVE_COPY */
   (
    p_error_id  in KEY_ERROR_LOG.error_id%type
   ) return number;
   pragma restrict_references( can_handle, WNDS );
   -- Controllo integrita chiave
   -- wrapper boolean
   function canHandle /* SLAVE_COPY */
   (
    p_error_id  in KEY_ERROR_LOG.error_id%type
   ) return boolean;
   pragma restrict_references( canhandle, WNDS );
    -- Esistenza riga con chiave indicata
   function exists_id /* SLAVE_COPY */
   (
    p_error_id  in KEY_ERROR_LOG.error_id%type
   ) return number;
   pragma restrict_references( exists_id, WNDS );
   -- Esistenza riga con chiave indicata
   -- wrapper boolean
   function existsId /* SLAVE_COPY */
   (
    p_error_id  in KEY_ERROR_LOG.error_id%type
   ) return boolean;
   pragma restrict_references( existsid, WNDS );
   -- Inserimento di una riga
   procedure ins  /*+ SOA  */
   (
     p_error_id  in KEY_ERROR_LOG.error_id%type default null
   , p_error_session  in KEY_ERROR_LOG.error_session%type default null
   , p_error_date  in KEY_ERROR_LOG.error_date%type default null
   , p_error_text  in KEY_ERROR_LOG.error_text%type default null
   , p_error_user  in KEY_ERROR_LOG.error_user%type default null
   , p_error_usertext  in KEY_ERROR_LOG.error_usertext%type default null
   , p_error_type  in KEY_ERROR_LOG.error_type%type default null
   );
   function ins  /*+ SOA  */
   (
     p_error_id  in KEY_ERROR_LOG.error_id%type default null
   , p_error_session  in KEY_ERROR_LOG.error_session%type default null
   , p_error_date  in KEY_ERROR_LOG.error_date%type default null
   , p_error_text  in KEY_ERROR_LOG.error_text%type default null
   , p_error_user  in KEY_ERROR_LOG.error_user%type default null
   , p_error_usertext  in KEY_ERROR_LOG.error_usertext%type default null
   , p_error_type  in KEY_ERROR_LOG.error_type%type default null
   ) return integer;
   -- Aggiornamento di una riga
   procedure upd  /*+ SOA  */
   (
     p_check_OLD  in integer default 0
   , p_NEW_error_id  in KEY_ERROR_LOG.error_id%type
   , p_OLD_error_id  in KEY_ERROR_LOG.error_id%type default null
   , p_NEW_error_session  in KEY_ERROR_LOG.error_session%type default null
   , p_OLD_error_session  in KEY_ERROR_LOG.error_session%type default null
   , p_NEW_error_date  in KEY_ERROR_LOG.error_date%type default null
   , p_OLD_error_date  in KEY_ERROR_LOG.error_date%type default null
   , p_NEW_error_text  in KEY_ERROR_LOG.error_text%type default null
   , p_OLD_error_text  in KEY_ERROR_LOG.error_text%type default null
   , p_NEW_error_user  in KEY_ERROR_LOG.error_user%type default null
   , p_OLD_error_user  in KEY_ERROR_LOG.error_user%type default null
   , p_NEW_error_usertext  in KEY_ERROR_LOG.error_usertext%type default null
   , p_OLD_error_usertext  in KEY_ERROR_LOG.error_usertext%type default null
   , p_NEW_error_type  in KEY_ERROR_LOG.error_type%type default null
   , p_OLD_error_type  in KEY_ERROR_LOG.error_type%type default null
   );
   -- Aggiornamento del campo di una riga
   procedure upd_column
   (
     p_error_id  in KEY_ERROR_LOG.error_id%type
   , p_column         in varchar2
   , p_value          in varchar2 default null
   , p_literal_value  in number   default 1
   );
   procedure upd_column
   (
p_error_id  in KEY_ERROR_LOG.error_id%type
   , p_column in varchar2
   , p_value  in date
   );
   -- Cancellazione di una riga
   procedure del  /*+ SOA  */
   (
     p_check_OLD  in integer default 0
   , p_error_id  in KEY_ERROR_LOG.error_id%type
   , p_error_session  in KEY_ERROR_LOG.error_session%type default null
   , p_error_date  in KEY_ERROR_LOG.error_date%type default null
   , p_error_text  in KEY_ERROR_LOG.error_text%type default null
   , p_error_user  in KEY_ERROR_LOG.error_user%type default null
   , p_error_usertext  in KEY_ERROR_LOG.error_usertext%type default null
   , p_error_type  in KEY_ERROR_LOG.error_type%type default null
   );
   -- Getter per attributo error_session di riga identificata da chiave
   function get_error_session /* SLAVE_COPY */
   (
     p_error_id  in KEY_ERROR_LOG.error_id%type
   ) return KEY_ERROR_LOG.error_session%type;
   pragma restrict_references( get_error_session, WNDS );
   -- Getter per attributo error_date di riga identificata da chiave
   function get_error_date /* SLAVE_COPY */
   (
     p_error_id  in KEY_ERROR_LOG.error_id%type
   ) return KEY_ERROR_LOG.error_date%type;
   pragma restrict_references( get_error_date, WNDS );
   -- Getter per attributo error_text di riga identificata da chiave
   function get_error_text /* SLAVE_COPY */
   (
     p_error_id  in KEY_ERROR_LOG.error_id%type
   ) return KEY_ERROR_LOG.error_text%type;
   pragma restrict_references( get_error_text, WNDS );
   -- Getter per attributo error_user di riga identificata da chiave
   function get_error_user /* SLAVE_COPY */
   (
     p_error_id  in KEY_ERROR_LOG.error_id%type
   ) return KEY_ERROR_LOG.error_user%type;
   pragma restrict_references( get_error_user, WNDS );
   -- Getter per attributo error_usertext di riga identificata da chiave
   function get_error_usertext /* SLAVE_COPY */
   (
     p_error_id  in KEY_ERROR_LOG.error_id%type
   ) return KEY_ERROR_LOG.error_usertext%type;
   pragma restrict_references( get_error_usertext, WNDS );
   -- Getter per attributo error_type di riga identificata da chiave
   function get_error_type /* SLAVE_COPY */
   (
     p_error_id  in KEY_ERROR_LOG.error_id%type
   ) return KEY_ERROR_LOG.error_type%type;
   pragma restrict_references( get_error_type, WNDS );
   -- Setter per attributo error_id di riga identificata da chiave
   procedure set_error_id
   (
     p_error_id  in KEY_ERROR_LOG.error_id%type
   , p_value  in KEY_ERROR_LOG.error_id%type default null
   );
   -- Setter per attributo error_session di riga identificata da chiave
   procedure set_error_session
   (
     p_error_id  in KEY_ERROR_LOG.error_id%type
   , p_value  in KEY_ERROR_LOG.error_session%type default null
   );
   -- Setter per attributo error_date di riga identificata da chiave
   procedure set_error_date
   (
     p_error_id  in KEY_ERROR_LOG.error_id%type
   , p_value  in KEY_ERROR_LOG.error_date%type default null
   );
   -- Setter per attributo error_text di riga identificata da chiave
   procedure set_error_text
   (
     p_error_id  in KEY_ERROR_LOG.error_id%type
   , p_value  in KEY_ERROR_LOG.error_text%type default null
   );
   -- Setter per attributo error_user di riga identificata da chiave
   procedure set_error_user
   (
     p_error_id  in KEY_ERROR_LOG.error_id%type
   , p_value  in KEY_ERROR_LOG.error_user%type default null
   );
   -- Setter per attributo error_usertext di riga identificata da chiave
   procedure set_error_usertext
   (
     p_error_id  in KEY_ERROR_LOG.error_id%type
   , p_value  in KEY_ERROR_LOG.error_usertext%type default null
   );
   -- Setter per attributo error_type di riga identificata da chiave
   procedure set_error_type
   (
     p_error_id  in KEY_ERROR_LOG.error_id%type
   , p_value  in KEY_ERROR_LOG.error_type%type default null
   );
   -- righe corrispondenti alla selezione indicata
   function get_rows  /*+ SOA  */ /* SLAVE_COPY */
   ( p_QBE  in number default 0
   , p_other_condition in varchar2 default null
   , p_order_by in varchar2 default null
   , p_extra_columns in varchar2 default null
   , p_extra_condition in varchar2 default null
   , p_error_id  in varchar2 default null
   , p_error_session  in varchar2 default null
   , p_error_date  in varchar2 default null
   , p_error_text  in varchar2 default null
   , p_error_user  in varchar2 default null
   , p_error_usertext  in varchar2 default null
   , p_error_type  in varchar2 default null
   ) return AFC.t_ref_cursor;
   -- Numero di righe corrispondente alla selezione indicata
   -- Almeno un attributo deve essere valido (non null)
   function count_rows /* SLAVE_COPY */
   ( p_QBE in number default 0
   , p_other_condition in varchar2 default null
   , p_error_id  in varchar2 default null
   , p_error_session  in varchar2 default null
   , p_error_date  in varchar2 default null
   , p_error_text  in varchar2 default null
   , p_error_user  in varchar2 default null
   , p_error_usertext  in varchar2 default null
   , p_error_type  in varchar2 default null
   ) return integer;
end key_error_log_tpk;
/

