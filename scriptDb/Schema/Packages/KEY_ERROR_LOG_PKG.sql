CREATE OR REPLACE PACKAGE key_error_log_pkg is /* MASTER_LINK */
/******************************************************************************
 NOME:        key_error_log_pkg
 DESCRIZIONE: Gestione tabella KEY_ERROR_LOG.
 ANNOTAZIONI: .
 REVISIONI:   
 <CODE>
 Rev.  Data       Autore  Descrizione.
 00    14/01/2019     SN  Prima emissione.
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
   
   procedure ins  
   (
     p_error_id  in KEY_ERROR_LOG.error_id%type default null
   , p_error_session  in KEY_ERROR_LOG.error_session%type default null
   , p_error_date  in KEY_ERROR_LOG.error_date%type default null
   , p_error_text  in KEY_ERROR_LOG.error_text%type default null
   , p_error_user  in KEY_ERROR_LOG.error_user%type default null
   , p_error_usertext  in KEY_ERROR_LOG.error_usertext%type default null
   , p_error_type  in KEY_ERROR_LOG.error_type%type default null
   );
   function ins  
   (
     p_error_id  in KEY_ERROR_LOG.error_id%type default null
   , p_error_session  in KEY_ERROR_LOG.error_session%type default null
   , p_error_date  in KEY_ERROR_LOG.error_date%type default null
   , p_error_text  in KEY_ERROR_LOG.error_text%type default null
   , p_error_user  in KEY_ERROR_LOG.error_user%type default null
   , p_error_usertext  in KEY_ERROR_LOG.error_usertext%type default null
   , p_error_type  in KEY_ERROR_LOG.error_type%type default null
   ) return integer;
  
end key_error_log_pkg;
/

