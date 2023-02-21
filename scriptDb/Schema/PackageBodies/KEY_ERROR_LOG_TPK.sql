CREATE OR REPLACE PACKAGE BODY key_error_log_tpk is
/******************************************************************************
 NOME:        key_error_log_tpk
 DESCRIZIONE: Gestione tabella KEY_ERROR_LOG.
 ANNOTAZIONI: .
 REVISIONI:   .
 Rev.  Data        Autore  Descrizione.
 000   11/05/2009  mmalferrari  Prima emissione.
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
function PK
(
 p_error_id  in KEY_ERROR_LOG.error_id%type
) return t_PK is /* SLAVE_COPY */
/******************************************************************************
 NOME:        PK
 DESCRIZIONE: Costruttore di un t_PK dati gli attributi della chiave
******************************************************************************/
   d_result t_PK;
begin
   d_result.error_id := p_error_id;
   DbC.PRE ( not DbC.PreOn or canHandle (
                                          p_error_id => d_result.error_id
                                        )
           , 'canHandle on key_error_log_tpk.PK'
           );
   return  d_result;
end PK; -- key_error_log_tpk.PK
--------------------------------------------------------------------------------
function can_handle
(
 p_error_id  in KEY_ERROR_LOG.error_id%type
) return number is /* SLAVE_COPY */
/******************************************************************************
 NOME:        can_handle
 DESCRIZIONE: La chiave specificata rispetta tutti i requisiti sugli attributi componenti.
 PARAMETRI:   Attributi chiave.
 RITORNA:     number: 1 se la chiave e manipolabile, 0 altrimenti.
 NOTE:        cfr. canHandle per ritorno valori boolean.
******************************************************************************/
   d_result number;
begin
   d_result := 1;
   -- nelle chiavi primarie composte da piu attributi, ciascun attributo deve essere not null
   if  d_result = 1
   and (
          p_error_id is null
       )
   then
      d_result := 0;
   end if;
   DbC.POST ( d_result = 1  or  d_result = 0
            , 'd_result = 1  or  d_result = 0 on key_error_log_tpk.can_handle'
            );
   return  d_result;
end can_handle; -- key_error_log_tpk.can_handle
--------------------------------------------------------------------------------
function canHandle
(
 p_error_id  in KEY_ERROR_LOG.error_id%type
) return boolean is /* SLAVE_COPY */
/******************************************************************************
 NOME:        canHandle
 DESCRIZIONE: La chiave specificata rispetta tutti i requisiti sugli attributi componenti.
 PARAMETRI:   Attributi chiave.
 RITORNA:     number: true se la chiave e manipolabile, false altrimenti.
 NOTE:        Wrapper boolean di can_handle (cfr. can_handle).
******************************************************************************/
   d_result constant boolean := AFC.to_boolean ( can_handle (
                                                              p_error_id => p_error_id
                                                            )
                                               );
begin
   return  d_result;
end canHandle; -- key_error_log_tpk.canHandle
--------------------------------------------------------------------------------
function exists_id
(
 p_error_id  in KEY_ERROR_LOG.error_id%type
) return number is /* SLAVE_COPY */
/******************************************************************************
 NOME:        exists_id
 DESCRIZIONE: Esistenza riga con chiave indicata.
 PARAMETRI:   Attributi chiave.
 RITORNA:     number: 1 se la riga esiste, 0 altrimenti.
 NOTE:        cfr. existsId per ritorno valori boolean.
******************************************************************************/
   d_result number;
begin
   DbC.PRE ( not DbC.PreOn or canHandle (
                                         p_error_id => p_error_id
                                        )
           , 'canHandle on key_error_log_tpk.exists_id'
           );
   begin
      select 1
      into   d_result
      from   KEY_ERROR_LOG
      where
      error_id = p_error_id
      ;
   exception
      when no_data_found then
         d_result := 0;
   end;
   DbC.POST ( d_result = 1  or  d_result = 0
            , 'd_result = 1  or  d_result = 0 on key_error_log_tpk.exists_id'
            );
   return  d_result;
end exists_id; -- key_error_log_tpk.exists_id
--------------------------------------------------------------------------------
function existsId
(
 p_error_id  in KEY_ERROR_LOG.error_id%type
) return boolean is /* SLAVE_COPY */
/******************************************************************************
 NOME:        existsId
 DESCRIZIONE: Esistenza riga con chiave indicata.
 NOTE:        Wrapper boolean di exists_id (cfr. exists_id).
******************************************************************************/
   d_result constant boolean := AFC.to_boolean ( exists_id (
                                                            p_error_id => p_error_id
                                                           )
                                               );
begin
   return  d_result;
end existsId; -- key_error_log_tpk.existsId
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
begin
   -- Check Mandatory on Insert
   DbC.PRE ( not DbC.PreOn or p_error_session is not null or /*default value*/ 'default' is not null
           , 'p_error_session on key_error_log_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_error_date is not null or /*default value*/ 'default' is not null
           , 'p_error_date on key_error_log_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_error_text is not null or /*default value*/ 'default' is not null
           , 'p_error_text on key_error_log_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_error_user is not null or /*default value*/ 'default' is not null
           , 'p_error_user on key_error_log_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_error_usertext is not null or /*default value*/ 'default' is not null
           , 'p_error_usertext on key_error_log_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_error_type is not null or /*default value*/ 'default' is not null
           , 'p_error_type on key_error_log_tpk.ins'
           );
   DbC.PRE (  not DbC.PreOn
           or (   p_error_id is null and /*default value*/ 'default null' is not null ) -- PK nullable on insert
           or not existsId (
                             p_error_id => p_error_id
                           )
           , 'not existsId on key_error_log_tpk.ins'
           );
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
   );
end ins; -- key_error_log_tpk.ins
--------------------------------------------------------------------------------
function ins  /*+ SOA  */
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
   d_result integer;
begin
   -- Check Mandatory on Insert
   DbC.PRE ( not DbC.PreOn or p_error_session is not null or /*default value*/ 'default' is not null
           , 'p_error_session on key_error_log_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_error_date is not null or /*default value*/ 'default' is not null
           , 'p_error_date on key_error_log_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_error_text is not null or /*default value*/ 'default' is not null
           , 'p_error_text on key_error_log_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_error_user is not null or /*default value*/ 'default' is not null
           , 'p_error_user on key_error_log_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_error_usertext is not null or /*default value*/ 'default' is not null
           , 'p_error_usertext on key_error_log_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_error_type is not null or /*default value*/ 'default' is not null
           , 'p_error_type on key_error_log_tpk.ins'
           );
   DbC.PRE (  not DbC.PreOn
           or (   p_error_id is null and /*default value*/ 'default null' is not null ) -- PK nullable on insert
           or not existsId (
                             p_error_id => p_error_id
                           )
           , 'not existsId on key_error_log_tpk.ins'
           );
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
   return d_result;
end ins; -- key_error_log_tpk.ins
--------------------------------------------------------------------------------
procedure upd
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
) is
/******************************************************************************
 NOME:        upd
 DESCRIZIONE: Aggiornamento di una riga con chiave.
 PARAMETRI:   Chiavi e attributi della table
              p_check_OLD: 0 e null, ricerca senza controllo su attributi precedenti
                           1       , ricerca con controllo anche su attributi precedenti.
 NOTE:        Nel caso in cui non venga elaborato alcun record viene lanciata
              l'eccezione -20010 (cfr. AFC_ERROR).
              Se p_check_old e NULL, gli attributi vengono annullati solo se viene
              indicato anche il relativo attributo OLD.
              Se p_check_old = 1, viene controllato se il record corrispondente a
              tutti i campi passati come parametri esiste nella tabella.
******************************************************************************/
   d_key t_PK;
   d_row_found number;
begin
   DbC.PRE (  not DbC.PreOn
           or not ( (
p_OLD_error_session is not null or
p_OLD_error_date is not null or
p_OLD_error_text is not null or
p_OLD_error_user is not null or
p_OLD_error_usertext is not null or
p_OLD_error_type is not null
                    )
                    and (  nvl( p_check_OLD, -1 ) = 0
                        )
                  )
           , ' "OLD values" is not null on key_error_log_tpk.upd'
           );
   d_key := PK (
                nvl( p_OLD_error_id, p_NEW_error_id )
               );
   DbC.PRE ( not DbC.PreOn or existsId (
                                         p_error_id => d_key.error_id
                                       )
           , 'existsId on key_error_log_tpk.upd'
           );
   update KEY_ERROR_LOG
   set
       error_id = decode( p_check_OLD, 0,p_NEW_error_id, decode(p_NEW_error_id, p_OLD_error_id,error_id,p_NEW_error_id))
     , error_session = decode( p_check_OLD, 0,p_NEW_error_session, decode(p_NEW_error_session, p_OLD_error_session,error_session,p_NEW_error_session))
     , error_date = decode( p_check_OLD, 0,p_NEW_error_date, decode(p_NEW_error_date, p_OLD_error_date,error_date,p_NEW_error_date))
     , error_text = decode( p_check_OLD, 0,p_NEW_error_text, decode(p_NEW_error_text, p_OLD_error_text,error_text,p_NEW_error_text))
     , error_user = decode( p_check_OLD, 0,p_NEW_error_user, decode(p_NEW_error_user, p_OLD_error_user,error_user,p_NEW_error_user))
     , error_usertext = decode( p_check_OLD, 0,p_NEW_error_usertext, decode(p_NEW_error_usertext, p_OLD_error_usertext,error_usertext,p_NEW_error_usertext))
     , error_type = decode( p_check_OLD, 0,p_NEW_error_type, decode(p_NEW_error_type, p_OLD_error_type,error_type,p_NEW_error_type))
   where
     error_id = d_key.error_id
   and (   p_check_OLD = 0
        or (   1 = 1
           and ( error_session = p_OLD_error_session or ( p_OLD_error_session is null and ( p_check_OLD is null or error_session is null ) ) )
           and ( error_date = p_OLD_error_date or ( p_OLD_error_date is null and ( p_check_OLD is null or error_date is null ) ) )
           and ( error_text = p_OLD_error_text or ( p_OLD_error_text is null and ( p_check_OLD is null or error_text is null ) ) )
           and ( error_user = p_OLD_error_user or ( p_OLD_error_user is null and ( p_check_OLD is null or error_user is null ) ) )
           and ( error_usertext = p_OLD_error_usertext or ( p_OLD_error_usertext is null and ( p_check_OLD is null or error_usertext is null ) ) )
           and ( error_type = p_OLD_error_type or ( p_OLD_error_type is null and ( p_check_OLD is null or error_type is null ) ) )
           )
       )
   ;
   d_row_found := SQL%ROWCOUNT;
   DbC.ASSERTION ( not DbC.AssertionOn or d_row_found <= 1
                 , 'd_row_found <= 1 on key_error_log_tpk.upd'
                 );
   if d_row_found < 1
   then
      raise_application_error ( AFC_ERROR.modified_by_other_user_number
                              , AFC_ERROR.modified_by_other_user_msg
                              );
   end if;
end upd; -- key_error_log_tpk.upd
--------------------------------------------------------------------------------
procedure upd_column
(
  p_error_id  in KEY_ERROR_LOG.error_id%type
, p_column         in varchar2
, p_value          in varchar2 default null
, p_literal_value  in number   default 1
) is
/******************************************************************************
 NOME:        upd_column
 DESCRIZIONE: Aggiornamento del campo p_column col valore p_value.
 PARAMETRI:   p_column:        identificatore del campo da aggiornare.
              p_value:         valore da modificare.
              p_literal_value: indica se il valore e un stringa e non un numero
                               o una funzione.
******************************************************************************/
   d_statement AFC.t_statement;
   d_literal   varchar2(2);
begin
   DbC.PRE ( not DbC.PreOn or existsId (
                                        p_error_id => p_error_id
                                       )
           , 'existsId on key_error_log_tpk.upd_column'
           );
   DbC.PRE ( not DbC.PreOn or p_column is not null
           , 'p_column is not null on key_error_log_tpk.upd_column'
           );
   DbC.PRE ( not DbC.PreOn or AFC_DDL.HasAttribute( s_table_name, p_column )
           , 'AFC_DDL.HasAttribute on key_error_log_tpk.upd_column'
           );
   DbC.PRE ( p_literal_value in ( 0, 1 ) or p_literal_value is null
           , 'p_literal_value on key_error_log_tpk.upd_column; p_literal_value = ' || p_literal_value
           );
   if p_literal_value = 1
   or p_literal_value is null
   then
      d_literal := '''';
   end if;
   d_statement := ' declare '
               || '    d_row_found number; '
               || ' begin '
               || '    update KEY_ERROR_LOG '
               || '       set ' || p_column || ' = ' || d_literal || p_value || d_literal
               || '     where 1 = 1 '
               || nvl( AFC.get_field_condition( ' and ( error_id ', p_error_id, ' )', 0, null ), ' and ( error_id is null ) ' )
               || '    ; '
               || '    d_row_found := SQL%ROWCOUNT; '
               || '    if d_row_found < 1 '
               || '    then '
               || '       raise_application_error ( AFC_ERROR.modified_by_other_user_number, AFC_ERROR.modified_by_other_user_msg ); '
               || '    end if; '
               || ' end; ';
   AFC.SQL_execute( d_statement );
end upd_column; -- key_error_log_tpk.upd_column
--------------------------------------------------------------------------------
procedure upd_column
(
p_error_id  in KEY_ERROR_LOG.error_id%type
, p_column  in varchar2
, p_value   in date
) is
/******************************************************************************
 NOME:        upd_column
 DESCRIZIONE: Aggiornamento del campo p_column col valore p_value.
 NOTE:        Richiama se stessa con il parametro date convertito in stringa.
******************************************************************************/
   d_data varchar2(19);
begin
   d_data := to_char( p_value, AFC.date_format );
   upd_column (
p_error_id => p_error_id
              , p_column => p_column
              , p_value => 'to_date( ''' || d_data || ''', ''' || AFC.date_format || ''' )'
              , p_literal_value => 0
              );
end upd_column; -- key_error_log_tpk.upd_column
--------------------------------------------------------------------------------
procedure del
(
  p_check_old  in integer default 0
, p_error_id  in KEY_ERROR_LOG.error_id%type
, p_error_session  in KEY_ERROR_LOG.error_session%type default null
, p_error_date  in KEY_ERROR_LOG.error_date%type default null
, p_error_text  in KEY_ERROR_LOG.error_text%type default null
, p_error_user  in KEY_ERROR_LOG.error_user%type default null
, p_error_usertext  in KEY_ERROR_LOG.error_usertext%type default null
, p_error_type  in KEY_ERROR_LOG.error_type%type default null
) is
/******************************************************************************
 NOME:        del
 DESCRIZIONE: Cancellazione della riga indicata.
 PARAMETRI:   Chiavi e attributi della table.
              p_check_OLD: 0, ricerca senza controllo su attributi precedenti
                           1, ricerca con controllo anche su attributi precedenti.
 NOTE:        Nel caso in cui non venga elaborato alcun record viene lanciata
              l'eccezione -20010 (cfr. AFC_ERROR).
              Se p_check_old = 1, viene controllato se il record corrispondente a
              tutti i campi passati come parametri esiste nella tabella.
******************************************************************************/
   d_row_found number;
begin
   DbC.PRE (  not DbC.PreOn
           or not ( (
p_error_session is not null or
p_error_date is not null or
p_error_text is not null or
p_error_user is not null or
p_error_usertext is not null or
p_error_type is not null
                    )
                    and (  nvl( p_check_OLD, -1 ) = 0
                        )
                  )
           , ' "OLD values" is not null on key_error_log_tpk.del'
           );
   DbC.PRE ( not DbC.PreOn or existsId (
                                         p_error_id => p_error_id
                                       )
           , 'existsId on key_error_log_tpk.del'
           );
   delete from KEY_ERROR_LOG
   where
     error_id = p_error_id
   and (   p_check_OLD = 0
        or (   1 = 1
           and ( error_session = p_error_session or ( p_error_session is null and ( p_check_OLD is null or error_session is null ) ) )
           and ( error_date = p_error_date or ( p_error_date is null and ( p_check_OLD is null or error_date is null ) ) )
           and ( error_text = p_error_text or ( p_error_text is null and ( p_check_OLD is null or error_text is null ) ) )
           and ( error_user = p_error_user or ( p_error_user is null and ( p_check_OLD is null or error_user is null ) ) )
           and ( error_usertext = p_error_usertext or ( p_error_usertext is null and ( p_check_OLD is null or error_usertext is null ) ) )
           and ( error_type = p_error_type or ( p_error_type is null and ( p_check_OLD is null or error_type is null ) ) )
           )
       )
   ;
   d_row_found := SQL%ROWCOUNT;
   DbC.ASSERTION ( not DbC.AssertionOn or d_row_found <= 1
                 , 'd_row_found <= 1 on key_error_log_tpk.del'
                 );
   if d_row_found < 1
   then
      raise_application_error ( AFC_ERROR.modified_by_other_user_number
                              , AFC_ERROR.modified_by_other_user_msg
                              );
   end if;
   DbC.POST ( not DbC.PostOn or not existsId (
                                               p_error_id => p_error_id
                                             )
            , 'existsId on key_error_log_tpk.del'
            );
end del; -- key_error_log_tpk.del
--------------------------------------------------------------------------------
function get_error_session
(
  p_error_id  in KEY_ERROR_LOG.error_id%type
) return KEY_ERROR_LOG.error_session%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_error_session
 DESCRIZIONE: Getter per attributo error_session di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     KEY_ERROR_LOG.error_session%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result KEY_ERROR_LOG.error_session%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_error_id => p_error_id
                                        )
           , 'existsId on key_error_log_tpk.get_error_session'
           );
   select error_session
   into   d_result
   from   KEY_ERROR_LOG
   where
   error_id = p_error_id
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on key_error_log_tpk.get_error_session'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'error_session')
                    , ' AFC_DDL.IsNullable on key_error_log_tpk.get_error_session'
                    );
   end if;
   return  d_result;
end get_error_session; -- key_error_log_tpk.get_error_session
--------------------------------------------------------------------------------
function get_error_date
(
  p_error_id  in KEY_ERROR_LOG.error_id%type
) return KEY_ERROR_LOG.error_date%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_error_date
 DESCRIZIONE: Getter per attributo error_date di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     KEY_ERROR_LOG.error_date%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result KEY_ERROR_LOG.error_date%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_error_id => p_error_id
                                        )
           , 'existsId on key_error_log_tpk.get_error_date'
           );
   select error_date
   into   d_result
   from   KEY_ERROR_LOG
   where
   error_id = p_error_id
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on key_error_log_tpk.get_error_date'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'error_date')
                    , ' AFC_DDL.IsNullable on key_error_log_tpk.get_error_date'
                    );
   end if;
   return  d_result;
end get_error_date; -- key_error_log_tpk.get_error_date
--------------------------------------------------------------------------------
function get_error_text
(
  p_error_id  in KEY_ERROR_LOG.error_id%type
) return KEY_ERROR_LOG.error_text%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_error_text
 DESCRIZIONE: Getter per attributo error_text di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     KEY_ERROR_LOG.error_text%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result KEY_ERROR_LOG.error_text%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_error_id => p_error_id
                                        )
           , 'existsId on key_error_log_tpk.get_error_text'
           );
   select error_text
   into   d_result
   from   KEY_ERROR_LOG
   where
   error_id = p_error_id
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on key_error_log_tpk.get_error_text'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'error_text')
                    , ' AFC_DDL.IsNullable on key_error_log_tpk.get_error_text'
                    );
   end if;
   return  d_result;
end get_error_text; -- key_error_log_tpk.get_error_text
--------------------------------------------------------------------------------
function get_error_user
(
  p_error_id  in KEY_ERROR_LOG.error_id%type
) return KEY_ERROR_LOG.error_user%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_error_user
 DESCRIZIONE: Getter per attributo error_user di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     KEY_ERROR_LOG.error_user%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result KEY_ERROR_LOG.error_user%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_error_id => p_error_id
                                        )
           , 'existsId on key_error_log_tpk.get_error_user'
           );
   select error_user
   into   d_result
   from   KEY_ERROR_LOG
   where
   error_id = p_error_id
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on key_error_log_tpk.get_error_user'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'error_user')
                    , ' AFC_DDL.IsNullable on key_error_log_tpk.get_error_user'
                    );
   end if;
   return  d_result;
end get_error_user; -- key_error_log_tpk.get_error_user
--------------------------------------------------------------------------------
function get_error_usertext
(
  p_error_id  in KEY_ERROR_LOG.error_id%type
) return KEY_ERROR_LOG.error_usertext%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_error_usertext
 DESCRIZIONE: Getter per attributo error_usertext di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     KEY_ERROR_LOG.error_usertext%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result KEY_ERROR_LOG.error_usertext%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_error_id => p_error_id
                                        )
           , 'existsId on key_error_log_tpk.get_error_usertext'
           );
   select error_usertext
   into   d_result
   from   KEY_ERROR_LOG
   where
   error_id = p_error_id
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on key_error_log_tpk.get_error_usertext'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'error_usertext')
                    , ' AFC_DDL.IsNullable on key_error_log_tpk.get_error_usertext'
                    );
   end if;
   return  d_result;
end get_error_usertext; -- key_error_log_tpk.get_error_usertext
--------------------------------------------------------------------------------
function get_error_type
(
  p_error_id  in KEY_ERROR_LOG.error_id%type
) return KEY_ERROR_LOG.error_type%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_error_type
 DESCRIZIONE: Getter per attributo error_type di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     KEY_ERROR_LOG.error_type%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result KEY_ERROR_LOG.error_type%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_error_id => p_error_id
                                        )
           , 'existsId on key_error_log_tpk.get_error_type'
           );
   select error_type
   into   d_result
   from   KEY_ERROR_LOG
   where
   error_id = p_error_id
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on key_error_log_tpk.get_error_type'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'error_type')
                    , ' AFC_DDL.IsNullable on key_error_log_tpk.get_error_type'
                    );
   end if;
   return  d_result;
end get_error_type; -- key_error_log_tpk.get_error_type
--------------------------------------------------------------------------------
procedure set_error_id
(
  p_error_id  in KEY_ERROR_LOG.error_id%type
, p_value  in KEY_ERROR_LOG.error_id%type default null
) is
/******************************************************************************
 NOME:        set_error_id
 DESCRIZIONE: Setter per attributo error_id di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_error_id => p_error_id
                                        )
           , 'existsId on key_error_log_tpk.set_error_id'
           );
   update KEY_ERROR_LOG
   set error_id = p_value
   where
   error_id = p_error_id
   ;
end set_error_id; -- key_error_log_tpk.set_error_id
--------------------------------------------------------------------------------
procedure set_error_session
(
  p_error_id  in KEY_ERROR_LOG.error_id%type
, p_value  in KEY_ERROR_LOG.error_session%type default null
) is
/******************************************************************************
 NOME:        set_error_session
 DESCRIZIONE: Setter per attributo error_session di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_error_id => p_error_id
                                        )
           , 'existsId on key_error_log_tpk.set_error_session'
           );
   update KEY_ERROR_LOG
   set error_session = p_value
   where
   error_id = p_error_id
   ;
end set_error_session; -- key_error_log_tpk.set_error_session
--------------------------------------------------------------------------------
procedure set_error_date
(
  p_error_id  in KEY_ERROR_LOG.error_id%type
, p_value  in KEY_ERROR_LOG.error_date%type default null
) is
/******************************************************************************
 NOME:        set_error_date
 DESCRIZIONE: Setter per attributo error_date di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_error_id => p_error_id
                                        )
           , 'existsId on key_error_log_tpk.set_error_date'
           );
   update KEY_ERROR_LOG
   set error_date = p_value
   where
   error_id = p_error_id
   ;
end set_error_date; -- key_error_log_tpk.set_error_date
--------------------------------------------------------------------------------
procedure set_error_text
(
  p_error_id  in KEY_ERROR_LOG.error_id%type
, p_value  in KEY_ERROR_LOG.error_text%type default null
) is
/******************************************************************************
 NOME:        set_error_text
 DESCRIZIONE: Setter per attributo error_text di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_error_id => p_error_id
                                        )
           , 'existsId on key_error_log_tpk.set_error_text'
           );
   update KEY_ERROR_LOG
   set error_text = p_value
   where
   error_id = p_error_id
   ;
end set_error_text; -- key_error_log_tpk.set_error_text
--------------------------------------------------------------------------------
procedure set_error_user
(
  p_error_id  in KEY_ERROR_LOG.error_id%type
, p_value  in KEY_ERROR_LOG.error_user%type default null
) is
/******************************************************************************
 NOME:        set_error_user
 DESCRIZIONE: Setter per attributo error_user di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_error_id => p_error_id
                                        )
           , 'existsId on key_error_log_tpk.set_error_user'
           );
   update KEY_ERROR_LOG
   set error_user = p_value
   where
   error_id = p_error_id
   ;
end set_error_user; -- key_error_log_tpk.set_error_user
--------------------------------------------------------------------------------
procedure set_error_usertext
(
  p_error_id  in KEY_ERROR_LOG.error_id%type
, p_value  in KEY_ERROR_LOG.error_usertext%type default null
) is
/******************************************************************************
 NOME:        set_error_usertext
 DESCRIZIONE: Setter per attributo error_usertext di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_error_id => p_error_id
                                        )
           , 'existsId on key_error_log_tpk.set_error_usertext'
           );
   update KEY_ERROR_LOG
   set error_usertext = p_value
   where
   error_id = p_error_id
   ;
end set_error_usertext; -- key_error_log_tpk.set_error_usertext
--------------------------------------------------------------------------------
procedure set_error_type
(
  p_error_id  in KEY_ERROR_LOG.error_id%type
, p_value  in KEY_ERROR_LOG.error_type%type default null
) is
/******************************************************************************
 NOME:        set_error_type
 DESCRIZIONE: Setter per attributo error_type di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_error_id => p_error_id
                                        )
           , 'existsId on key_error_log_tpk.set_error_type'
           );
   update KEY_ERROR_LOG
   set error_type = p_value
   where
   error_id = p_error_id
   ;
end set_error_type; -- key_error_log_tpk.set_error_type
--------------------------------------------------------------------------------
function where_condition /* SLAVE_COPY */
( p_QBE  in number default 0
, p_other_condition in varchar2 default null
, p_error_id  in varchar2 default null
, p_error_session  in varchar2 default null
, p_error_date  in varchar2 default null
, p_error_text  in varchar2 default null
, p_error_user  in varchar2 default null
, p_error_usertext  in varchar2 default null
, p_error_type  in varchar2 default null
) return AFC.t_statement is /* SLAVE_COPY */
/******************************************************************************
 NOME:        where_condition
 DESCRIZIONE: Ritorna la where_condition per lo statement di select di get_rows e count_rows.
 PARAMETRI:   p_other_condition
              p_QBE 0: se l'operatore da utilizzare nella where-condition e
                       quello di default ('=')
                    1: se l'operatore da utilizzare nella where-condition e
                       quello specificato per ogni attributo.
              Chiavi e attributi della table
 RITORNA:     AFC.t_statement.
 NOTE:        Se p_QBE = 1 , ogni parametro deve contenere, nella prima parte,
              l'operatore da utilizzare nella where-condition.
******************************************************************************/
   d_statement AFC.t_statement;
begin
   d_statement := ' where ( 1 = 1 '
               || AFC.get_field_condition( ' and ( error_id ', p_error_id, ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( error_session ', p_error_session , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( error_date ', p_error_date , ' )', p_QBE, AFC.date_format )
               || AFC.get_field_condition( ' and ( error_text ', p_error_text , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( error_user ', p_error_user , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( error_usertext ', p_error_usertext , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( error_type ', p_error_type , ' )', p_QBE, null )
               || ' ) ' || p_other_condition
               ;
   return d_statement;
end where_condition; --- key_error_log_tpk.where_condition
--------------------------------------------------------------------------------
function get_rows
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
) return AFC.t_ref_cursor is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_rows
 DESCRIZIONE: Ritorna il risultato di una query in base ai valori che passiamo.
 PARAMETRI:   p_QBE 0: se l'operatore da utilizzare nella where-condition e
                       quello di default ('=')
                    1: se l'operatore da utilizzare nella where-condition e
                       quello specificato per ogni attributo.
              p_other_condition: condizioni aggiuntive di base
              p_order_by: condizioni di ordinamento
              p_extra_columns: colonne aggiungere alla select
              p_extra_condition: condizioni aggiuntive
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
   d_statement := ' select KEY_ERROR_LOG.* '
               || afc.decode_value( p_extra_columns, null, null, ' , ' || p_extra_columns )
               || ' from KEY_ERROR_LOG '
               || where_condition(
                                   p_QBE => p_QBE
                                 , p_other_condition => p_other_condition
                                 , p_error_id => p_error_id
                                 , p_error_session => p_error_session
                                 , p_error_date => p_error_date
                                 , p_error_text => p_error_text
                                 , p_error_user => p_error_user
                                 , p_error_usertext => p_error_usertext
                                 , p_error_type => p_error_type
                                 )
               || ' ' || p_extra_condition
               || afc.decode_value( p_order_by, null, null, ' order by ' || p_order_by )
               ;
   d_ref_cursor := AFC_DML.get_ref_cursor( d_statement );
   return d_ref_cursor;
end get_rows; -- key_error_log_tpk.get_rows
--------------------------------------------------------------------------------
function count_rows
( p_QBE  in number default 0
, p_other_condition in varchar2 default null
, p_error_id  in varchar2 default null
, p_error_session  in varchar2 default null
, p_error_date  in varchar2 default null
, p_error_text  in varchar2 default null
, p_error_user  in varchar2 default null
, p_error_usertext  in varchar2 default null
, p_error_type  in varchar2 default null
) return integer is /* SLAVE_COPY */
/******************************************************************************
 NOME:        count_rows
 DESCRIZIONE: Ritorna il numero di righe della tabella gli attributi delle quali
              rispettano i valori indicati.
 PARAMETRI:   p_other_condition
              p_QBE 0: se l'operatore da utilizzare nella where-condition e
                       quello di default ('=')
                    1: se l'operatore da utilizzare nella where-condition e
                       quello specificato per ogni attributo.
              Chiavi e attributi della table
 RITORNA:     Numero di righe che rispettano la selezione indicata.
******************************************************************************/
   d_result          integer;
   d_statement       AFC.t_statement;
begin
   d_statement := ' select count( * ) from KEY_ERROR_LOG '
               || where_condition(
                                   p_QBE => p_QBE
                                 , p_other_condition => p_other_condition
                                 , p_error_id => p_error_id
                                 , p_error_session => p_error_session
                                 , p_error_date => p_error_date
                                 , p_error_text => p_error_text
                                 , p_error_user => p_error_user
                                 , p_error_usertext => p_error_usertext
                                 , p_error_type => p_error_type
                                 );
   d_result := AFC.SQL_execute( d_statement );
   return d_result;
end count_rows; -- key_error_log_tpk.count_rows
--------------------------------------------------------------------------------
end key_error_log_tpk;
/

