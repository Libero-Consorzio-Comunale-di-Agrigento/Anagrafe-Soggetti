CREATE OR REPLACE PACKAGE BODY key_error_log_pkg is
/******************************************************************************
 NOME:        key_error_log_pkg
 DESCRIZIONE: Gestione tabella KEY_ERROR_LOG.
 ANNOTAZIONI: .
 REVISIONI:   .
 Rev.  Data        Autore  Descrizione.
 00    14/01/2019     SN  Prima emissione.
******************************************************************************/
   s_revisione_body      constant AFC.t_revision := '000';
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
end versione; -- key_error_log_tpk.versione
--------------------------------------------------------------------------------

procedure ins
(
  p_error_id  in KEY_ERROR_LOG.error_id%type default null
, p_error_session  in KEY_ERROR_LOG.error_session%type default null
, p_error_date  in KEY_ERROR_LOG.error_date%type default null
, p_error_text  in KEY_ERROR_LOG.error_text%type default null
, p_error_user  in KEY_ERROR_LOG.error_user%type default null
, p_error_usertext  in KEY_ERROR_LOG.error_usertext%type default null
, p_error_type  in KEY_ERROR_LOG.error_type%type default null
) is
/******************************************************************************
 NOME:        ins
 DESCRIZIONE: Inserimento di una riga con chiave e attributi indicati.
 PARAMETRI:   Chiavi e attributi della table.
******************************************************************************/
d_result integer;
begin
   -- Check Mandatory on Insert
   
  d_result := ins(p_error_id 
                , p_error_session
                , p_error_date  
                , p_error_text  
                , p_error_user  
                , p_error_usertext
                , p_error_type    
                ) ;
end ins; 
--------------------------------------------------------------------------------
function ins  
(
  p_error_id  in KEY_ERROR_LOG.error_id%type default null
, p_error_session  in KEY_ERROR_LOG.error_session%type default null
, p_error_date  in KEY_ERROR_LOG.error_date%type default null
, p_error_text  in KEY_ERROR_LOG.error_text%type default null
, p_error_user  in KEY_ERROR_LOG.error_user%type default null
, p_error_usertext  in KEY_ERROR_LOG.error_usertext%type default null
, p_error_type  in KEY_ERROR_LOG.error_type%type default null
) return integer
/******************************************************************************
 NOME:        ins
 DESCRIZIONE: Inserimento di una riga con chiave e attributi indicati.
 PARAMETRI:   Chiavi e attributi della table.
 RITORNA:     In caso di PK formata da colonna numerica, ritorna il valore della PK
              (se positivo), in tutti gli altri casi ritorna 0; in caso di errore,
              ritorna il codice di errore
******************************************************************************/
is
   pragma autonomous_transaction;
   d_result integer;
begin
   begin
      insert into KEY_ERROR_LOG
      (
        error_id
      , error_session
      , error_date
      , error_text
      , error_user
      , error_usertext
      , error_type
      )
      values
      (
        p_error_id
      , p_error_session
      , p_error_date
      , p_error_text
      , p_error_user
      , p_error_usertext
      , p_error_type
      ) returning error_id
      into d_result;
      if d_result < 0
      then
         d_result := 0;
      end if;
   exception
      when others then
         d_result := sqlcode;
   end;
   commit;
   return d_result;
end ins; -- key_error_log_pkg.ins
--------------------------------------------------------------------------------

end key_error_log_pkg;
/

