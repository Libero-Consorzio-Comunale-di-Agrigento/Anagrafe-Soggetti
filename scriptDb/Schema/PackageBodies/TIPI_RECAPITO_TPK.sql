CREATE OR REPLACE package body tipi_recapito_tpk is
/******************************************************************************
 NOME:        tipi_recapito_tpk
 DESCRIZIONE: Gestione tabella TIPI_RECAPITO.
 ANNOTAZIONI: .
 REVISIONI:   .
 Rev.  Data        Autore      Descrizione.
 000   26/07/2017  snegroni  Generazione automatica. 
 001   26/07/2017  snegroni  Generazione automatica. 
******************************************************************************/
   s_revisione_body      constant AFC.t_revision := '001 - 26/07/2017';
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
end versione; -- tipi_recapito_tpk.versione
--------------------------------------------------------------------------------
function PK
(
 p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
) return t_PK is /* SLAVE_COPY */
/******************************************************************************
 NOME:        PK
 DESCRIZIONE: Costruttore di un t_PK dati gli attributi della chiave
******************************************************************************/
   d_result t_PK;   
begin
   d_result.id_tipo_recapito := p_id_tipo_recapito;
   DbC.PRE ( not DbC.PreOn or canHandle (
                                          p_id_tipo_recapito => d_result.id_tipo_recapito
                                        )
           , 'canHandle on tipi_recapito_tpk.PK' 
           );
   return  d_result;
end PK; -- tipi_recapito_tpk.PK
--------------------------------------------------------------------------------
function can_handle
(
 p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
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
          p_id_tipo_recapito is null
       )
   then
      d_result := 0;
   end if;
   DbC.POST ( d_result = 1  or  d_result = 0
            , 'd_result = 1  or  d_result = 0 on tipi_recapito_tpk.can_handle'
            );
   return  d_result;   
end can_handle; -- tipi_recapito_tpk.can_handle
--------------------------------------------------------------------------------
function canHandle
(
 p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
) return boolean is /* SLAVE_COPY */
/******************************************************************************
 NOME:        canHandle
 DESCRIZIONE: La chiave specificata rispetta tutti i requisiti sugli attributi componenti.
 PARAMETRI:   Attributi chiave.
 RITORNA:     number: true se la chiave e manipolabile, false altrimenti.
 NOTE:        Wrapper boolean di can_handle (cfr. can_handle).
******************************************************************************/
   d_result constant boolean := AFC.to_boolean ( can_handle (
                                                              p_id_tipo_recapito => p_id_tipo_recapito
                                                            ) 
                                               );
begin
   return  d_result;
end canHandle; -- tipi_recapito_tpk.canHandle
--------------------------------------------------------------------------------
function exists_id
( 
 p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
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
                                         p_id_tipo_recapito => p_id_tipo_recapito
                                        )
           , 'canHandle on tipi_recapito_tpk.exists_id' 
           );
   begin
      select 1
      into   d_result
      from   TIPI_RECAPITO
      where  
      id_tipo_recapito = p_id_tipo_recapito
      ;
   exception
      when no_data_found then
         d_result := 0;
   end;
   DbC.POST ( d_result = 1  or  d_result = 0
            , 'd_result = 1  or  d_result = 0 on tipi_recapito_tpk.exists_id'
            );
   return  d_result;   
end exists_id; -- tipi_recapito_tpk.exists_id
--------------------------------------------------------------------------------
function existsId
( 
 p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
) return boolean is /* SLAVE_COPY */
/******************************************************************************
 NOME:        existsId
 DESCRIZIONE: Esistenza riga con chiave indicata.
 NOTE:        Wrapper boolean di exists_id (cfr. exists_id).
******************************************************************************/
   d_result constant boolean := AFC.to_boolean ( exists_id (
                                                            p_id_tipo_recapito => p_id_tipo_recapito
                                                           ) 
                                               );
begin
   return  d_result;
end existsId; -- tipi_recapito_tpk.existsId
--------------------------------------------------------------------------------
procedure ins
( 
  p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type default null
, p_descrizione  in TIPI_RECAPITO.descrizione%type 
, p_unico  in TIPI_RECAPITO.unico%type default 'NO'
, p_importanza  in TIPI_RECAPITO.importanza%type default null
, p_version  in TIPI_RECAPITO.version%type default null
, p_utente_aggiornamento  in TIPI_RECAPITO.utente_aggiornamento%type default null
, p_data_aggiornamento  in TIPI_RECAPITO.data_aggiornamento%type default null
) is
/******************************************************************************
 NOME:        ins
 DESCRIZIONE: Inserimento di una riga con chiave e attributi indicati.
 PARAMETRI:   Chiavi e attributi della table.
******************************************************************************/
begin
   -- Check Mandatory on Insert
   
   DbC.PRE ( not DbC.PreOn or p_descrizione is not null or /*default value*/ '' is not null
           , 'p_descrizione on tipi_recapito_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_unico is not null or /*default value*/ 'default' is not null
           , 'p_unico on tipi_recapito_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_importanza is not null or /*default value*/ 'default' is not null
           , 'p_importanza on tipi_recapito_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_version is not null or /*default value*/ 'default' is not null
           , 'p_version on tipi_recapito_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_utente_aggiornamento is not null or /*default value*/ 'default' is not null
           , 'p_utente_aggiornamento on tipi_recapito_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_data_aggiornamento is not null or /*default value*/ 'default' is not null
           , 'p_data_aggiornamento on tipi_recapito_tpk.ins'
           );
   DbC.PRE (  not DbC.PreOn
           or (   p_id_tipo_recapito is null and /*default value*/ 'default null' is not null ) -- PK nullable on insert
           or not existsId (
                             p_id_tipo_recapito => p_id_tipo_recapito
                           )
           , 'not existsId on tipi_recapito_tpk.ins'
           );
   insert into TIPI_RECAPITO
   (
     id_tipo_recapito
   , descrizione
   , unico
   , importanza
   , version
   , utente_aggiornamento
   , data_aggiornamento
   )
   values
   (
     p_id_tipo_recapito
, p_descrizione
, nvl( p_unico, 'NO' )
, p_importanza
, p_version
, p_utente_aggiornamento
, p_data_aggiornamento
   );
end ins; -- tipi_recapito_tpk.ins
--------------------------------------------------------------------------------
function ins
(
  p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type default null
, p_descrizione  in TIPI_RECAPITO.descrizione%type 
, p_unico  in TIPI_RECAPITO.unico%type default 'NO'
, p_importanza  in TIPI_RECAPITO.importanza%type default null
, p_version  in TIPI_RECAPITO.version%type default null
, p_utente_aggiornamento  in TIPI_RECAPITO.utente_aggiornamento%type default null
, p_data_aggiornamento  in TIPI_RECAPITO.data_aggiornamento%type default null
) return number
/******************************************************************************
 NOME:        ins
 DESCRIZIONE: Inserimento di una riga con chiave e attributi indicati.
 PARAMETRI:   Chiavi e attributi della table.
 RITORNA:     In caso di PK formata da colonna numerica, ritorna il valore della PK
              (se positivo), in tutti gli altri casi ritorna 0; in caso di errore,
              ritorna il codice di errore
******************************************************************************/
is
   d_result number;
begin
   -- Check Mandatory on Insert
   
   DbC.PRE ( not DbC.PreOn or p_descrizione is not null or /*default value*/ '' is not null
           , 'p_descrizione on tipi_recapito_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_unico is not null or /*default value*/ 'default' is not null
           , 'p_unico on tipi_recapito_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_importanza is not null or /*default value*/ 'default' is not null
           , 'p_importanza on tipi_recapito_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_version is not null or /*default value*/ 'default' is not null
           , 'p_version on tipi_recapito_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_utente_aggiornamento is not null or /*default value*/ 'default' is not null
           , 'p_utente_aggiornamento on tipi_recapito_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_data_aggiornamento is not null or /*default value*/ 'default' is not null
           , 'p_data_aggiornamento on tipi_recapito_tpk.ins'
           );
   DbC.PRE (  not DbC.PreOn
           or (   p_id_tipo_recapito is null and /*default value*/ 'default null' is not null ) -- PK nullable on insert
           or not existsId (
                             p_id_tipo_recapito => p_id_tipo_recapito
                           )
           , 'not existsId on tipi_recapito_tpk.ins'
           );
   insert into TIPI_RECAPITO
   (
     id_tipo_recapito
   , descrizione
   , unico
   , importanza
   , version
   , utente_aggiornamento
   , data_aggiornamento
   )
   values
   (
     p_id_tipo_recapito
, p_descrizione
, nvl( p_unico, 'NO' )
, p_importanza
, p_version
, p_utente_aggiornamento
, p_data_aggiornamento
   ) returning id_tipo_recapito
   into d_result;
   return d_result;
end ins; -- tipi_recapito_tpk.ins
--------------------------------------------------------------------------------
procedure upd
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
) is
/******************************************************************************
 NOME:        upd
 DESCRIZIONE: Aggiornamento di una riga con chiave.
 PARAMETRI:   Chiavi e attributi della table
              p_check_OLD: 0    , ricerca senza controllo su attributi precedenti
                           1    , ricerca con controllo su tutti gli attributi precedenti.
                           null , ricerca con controllo sui soli attributi precedenti passati.
 NOTE:        Nel caso in cui non venga elaborato alcun record viene lanciata
              l'eccezione -20010 (cfr. AFC_ERROR).
              Se p_check_old e NULL, gli attributi vengono annullati solo se viene
              indicato anche il relativo attributo OLD.
              Se p_check_old = 1, viene controllato se il record corrispondente a
              tutti i campi passati come parametri esiste nella tabella.
              Se p_check_old e NULL, viene controllato se il record corrispondente
              ai soli campi passati come parametri esiste nella tabella.
******************************************************************************/
   d_key t_PK;
   d_row_found number;
begin
--raise_application_error(-20999,'versione' || p_old_version || ':' || p_new_version);
   DbC.PRE (  not DbC.PreOn
           or not ( ( 
p_OLD_descrizione is not null
 or p_OLD_unico is not null
 or p_OLD_importanza is not null
 or p_OLD_version is not null
 or p_OLD_utente_aggiornamento is not null
 or p_OLD_data_aggiornamento is not null
                    )
                    and (  nvl( p_check_OLD, -1 ) = 0
                        )
                  )
           , ' "OLD values" is not null on tipi_recapito_tpk.upd'
           );
   d_key := PK ( 
                nvl( p_OLD_id_tipo_recapito, p_NEW_id_tipo_recapito )
               );
   DbC.PRE ( not DbC.PreOn or existsId ( 
                                         p_id_tipo_recapito => d_key.id_tipo_recapito
                                       )
           , 'existsId on tipi_recapito_tpk.upd' 
           );
   update TIPI_RECAPITO
   set 
       id_tipo_recapito = NVL( p_NEW_id_tipo_recapito, DECODE( AFC.IS_DEFAULT_NULL( 'TIPI_RECAPITO.id_tipo_recapito' ), 1, id_tipo_recapito,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_id_tipo_recapito, null, id_tipo_recapito, null ) ) ) )
     , descrizione = NVL( p_NEW_descrizione, DECODE( AFC.IS_DEFAULT_NULL( 'TIPI_RECAPITO.descrizione' ), 1, descrizione,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_descrizione, null, descrizione, null ) ) ) )
     , unico = NVL( p_NEW_unico, DECODE( AFC.IS_DEFAULT_NULL( 'TIPI_RECAPITO.unico' ), 1, unico,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_unico, null, unico, null ) ) ) )
     , importanza = NVL( p_NEW_importanza, DECODE( AFC.IS_DEFAULT_NULL( 'TIPI_RECAPITO.importanza' ), 1, importanza,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_importanza, null, importanza, null ) ) ) )
     , version = NVL( p_NEW_version, DECODE( AFC.IS_DEFAULT_NULL( 'TIPI_RECAPITO.version' ), 1, version,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_version, null, version, null ) ) ) )
     , utente_aggiornamento = NVL( p_NEW_utente_aggiornamento, DECODE( AFC.IS_DEFAULT_NULL( 'TIPI_RECAPITO.utente_aggiornamento' ), 1, utente_aggiornamento,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_utente_aggiornamento, null, utente_aggiornamento, null ) ) ) )
     , data_aggiornamento = NVL( p_NEW_data_aggiornamento, DECODE( AFC.IS_DEFAULT_NULL( 'TIPI_RECAPITO.data_aggiornamento' ), 1, data_aggiornamento,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_data_aggiornamento, null, data_aggiornamento, null ) ) ) )
   where 
     id_tipo_recapito = d_key.id_tipo_recapito
   and (   p_check_OLD = 0
        or (   1 = 1
           and ( descrizione = p_OLD_descrizione or ( p_OLD_descrizione is null and ( p_check_OLD is null or descrizione is null ) ) )
           and ( unico = p_OLD_unico or ( p_OLD_unico is null and ( p_check_OLD is null or unico is null ) ) )
           and ( importanza = p_OLD_importanza or ( p_OLD_importanza is null and ( p_check_OLD is null or importanza is null ) ) )
           and ( version = p_OLD_version or ( p_OLD_version is null and ( p_check_OLD is null or version is null ) ) )
           and ( utente_aggiornamento = p_OLD_utente_aggiornamento or ( p_OLD_utente_aggiornamento is null and ( p_check_OLD is null or utente_aggiornamento is null ) ) )
           and ( data_aggiornamento = p_OLD_data_aggiornamento or ( p_OLD_data_aggiornamento is null and ( p_check_OLD is null or data_aggiornamento is null ) ) )
           )
       )
   ;
   d_row_found := SQL%ROWCOUNT;
   afc.default_null(NULL);
   DbC.ASSERTION ( not DbC.AssertionOn or d_row_found <= 1
                 , 'd_row_found <= 1 on tipi_recapito_tpk.upd'
                 );
   if d_row_found < 1
   then
      raise_application_error ( AFC_ERROR.modified_by_other_user_number
                              , AFC_ERROR.modified_by_other_user_msg
                              );
   end if;
end upd; -- tipi_recapito_tpk.upd
--------------------------------------------------------------------------------
procedure upd_column
( 
  p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
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
                                        p_id_tipo_recapito => p_id_tipo_recapito
                                       )
           , 'existsId on tipi_recapito_tpk.upd_column' 
           );
   DbC.PRE ( not DbC.PreOn or p_column is not null
           , 'p_column is not null on tipi_recapito_tpk.upd_column'
           );
   DbC.PRE ( not DbC.PreOn or AFC_DDL.HasAttribute( s_table_name, p_column )
           , 'AFC_DDL.HasAttribute on tipi_recapito_tpk.upd_column'
           );
   DbC.PRE ( p_literal_value in ( 0, 1 ) or p_literal_value is null
           , 'p_literal_value on tipi_recapito_tpk.upd_column; p_literal_value = ' || p_literal_value
           );
   if p_literal_value = 1
   or p_literal_value is null
   then
      d_literal := '''';
   end if;
   d_statement := ' declare '
               || '    d_row_found number; '
               || ' begin '
               || '    update TIPI_RECAPITO '
               || '       set ' || p_column || ' = ' || d_literal || p_value || d_literal
               || '     where 1 = 1 '
               || nvl( AFC.get_field_condition( ' and ( id_tipo_recapito ', p_id_tipo_recapito, ' )', 0, null ), ' and ( id_tipo_recapito is null ) ' )
               || '    ; '
               || '    d_row_found := SQL%ROWCOUNT; '
               || '    if d_row_found < 1 '
               || '    then '
               || '       raise_application_error ( AFC_ERROR.modified_by_other_user_number, AFC_ERROR.modified_by_other_user_msg ); '
               || '    end if; '
               || ' end; ';
   AFC.SQL_execute( d_statement );
end upd_column; -- tipi_recapito_tpk.upd_column
--------------------------------------------------------------------------------
procedure upd_column
( 
p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
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
p_id_tipo_recapito => p_id_tipo_recapito
              , p_column => p_column
              , p_value => 'to_date( ''' || d_data || ''', ''' || AFC.date_format || ''' )'
              , p_literal_value => 0
              );   
end upd_column; -- tipi_recapito_tpk.upd_column
--------------------------------------------------------------------------------
procedure del
( 
  p_check_old  in integer default 0
, p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
, p_descrizione  in TIPI_RECAPITO.descrizione%type default null
, p_unico  in TIPI_RECAPITO.unico%type default null
, p_importanza  in TIPI_RECAPITO.importanza%type default null
, p_version  in TIPI_RECAPITO.version%type default null
, p_utente_aggiornamento  in TIPI_RECAPITO.utente_aggiornamento%type default null
, p_data_aggiornamento  in TIPI_RECAPITO.data_aggiornamento%type default null
) is
/******************************************************************************
 NOME:        del
 DESCRIZIONE: Cancellazione della riga indicata.
 PARAMETRI:   Chiavi e attributi della table
              p_check_OLD: 0    , ricerca senza controllo su attributi precedenti
                           1    , ricerca con controllo su tutti gli attributi precedenti.
                           null , ricerca con controllo sui soli attributi precedenti passati.
 NOTE:        Nel caso in cui non venga elaborato alcun record viene lanciata
              l'eccezione -20010 (cfr. AFC_ERROR).
              Se p_check_old = 1, viene controllato se il record corrispondente a
              tutti i campi passati come parametri esiste nella tabella.
              Se p_check_old e NULL, viene controllato se il record corrispondente
              ai soli campi passati come parametri esiste nella tabella.
******************************************************************************/
   d_row_found number;
begin
--raise_application_error(-20999,'p_id_tipo_recapito' || p_check_OLD||' ' || p_id_tipo_recapito  
--||' ' || p_descrizione 
--||' ' || p_unico 
--||' ' || p_importanza  
--||' ' || p_version 
--||' ' || p_utente_aggiornamento 
--||' ' || p_data_aggiornamento );
   DbC.PRE (  not DbC.PreOn
           or not ( ( 
p_descrizione is not null
 or p_unico is not null
 or p_importanza is not null
 or p_version is not null
 or p_utente_aggiornamento is not null
 or p_data_aggiornamento is not null
                    )
                    and (  nvl( p_check_OLD, -1 ) = 0
                        )
                  )
           , ' "OLD values" is not null on tipi_recapito_tpk.del'
           );
   DbC.PRE ( not DbC.PreOn or existsId (
                                         p_id_tipo_recapito => p_id_tipo_recapito
                                       )
           , 'existsId on tipi_recapito_tpk.del' 
           );
   delete from TIPI_RECAPITO
   where 
     id_tipo_recapito = p_id_tipo_recapito
   and (   p_check_OLD = 0
        or (   1 = 1
           and ( descrizione = p_descrizione or ( p_descrizione is null and ( p_check_OLD is null or descrizione is null ) ) )
           and ( unico = p_unico or ( p_unico is null and ( p_check_OLD is null or unico is null ) ) )
           and ( importanza = p_importanza or ( p_importanza is null and ( p_check_OLD is null or importanza is null ) ) )
           and ( version = p_version or ( p_version is null and ( p_check_OLD is null or version is null ) ) )
           and ( utente_aggiornamento = p_utente_aggiornamento or ( p_utente_aggiornamento is null and ( p_check_OLD is null or utente_aggiornamento is null ) ) )
           and ( data_aggiornamento = p_data_aggiornamento or ( p_data_aggiornamento is null and ( p_check_OLD is null or data_aggiornamento is null ) ) )
           )
       )
   ;
   d_row_found := SQL%ROWCOUNT;
   DbC.ASSERTION ( not DbC.AssertionOn or d_row_found <= 1
                 , 'd_row_found <= 1 on tipi_recapito_tpk.del'
                 );
   if d_row_found < 1
   then
      raise_application_error ( AFC_ERROR.modified_by_other_user_number
                              , AFC_ERROR.modified_by_other_user_msg
                              );
   end if;
   DbC.POST ( not DbC.PostOn or not existsId ( 
                                               p_id_tipo_recapito => p_id_tipo_recapito
                                             )
            , 'existsId on tipi_recapito_tpk.del' 
            );
end del; -- tipi_recapito_tpk.del
--------------------------------------------------------------------------------
function get_descrizione
( 
  p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
) return TIPI_RECAPITO.descrizione%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_descrizione
 DESCRIZIONE: Getter per attributo descrizione di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     TIPI_RECAPITO.descrizione%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result TIPI_RECAPITO.descrizione%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_tipo_recapito => p_id_tipo_recapito
                                        )
           , 'existsId on tipi_recapito_tpk.get_descrizione' 
           );
   select descrizione
   into   d_result
   from   TIPI_RECAPITO
   where  
   id_tipo_recapito = p_id_tipo_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (true)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on tipi_recapito_tpk.get_descrizione'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'descrizione')
                    , ' AFC_DDL.IsNullable on tipi_recapito_tpk.get_descrizione'
                    );
   end if;
   return  d_result;
end get_descrizione; -- tipi_recapito_tpk.get_descrizione
--------------------------------------------------------------------------------
function get_unico
( 
  p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
) return TIPI_RECAPITO.unico%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_unico
 DESCRIZIONE: Getter per attributo unico di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     TIPI_RECAPITO.unico%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result TIPI_RECAPITO.unico%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_tipo_recapito => p_id_tipo_recapito
                                        )
           , 'existsId on tipi_recapito_tpk.get_unico' 
           );
   select unico
   into   d_result
   from   TIPI_RECAPITO
   where  
   id_tipo_recapito = p_id_tipo_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (true)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on tipi_recapito_tpk.get_unico'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'unico')
                    , ' AFC_DDL.IsNullable on tipi_recapito_tpk.get_unico'
                    );
   end if;
   return  d_result;
end get_unico; -- tipi_recapito_tpk.get_unico
--------------------------------------------------------------------------------
function get_importanza
( 
  p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
) return TIPI_RECAPITO.importanza%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_importanza
 DESCRIZIONE: Getter per attributo importanza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     TIPI_RECAPITO.importanza%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result TIPI_RECAPITO.importanza%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_tipo_recapito => p_id_tipo_recapito
                                        )
           , 'existsId on tipi_recapito_tpk.get_importanza' 
           );
   select importanza
   into   d_result
   from   TIPI_RECAPITO
   where  
   id_tipo_recapito = p_id_tipo_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on tipi_recapito_tpk.get_importanza'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'importanza')
                    , ' AFC_DDL.IsNullable on tipi_recapito_tpk.get_importanza'
                    );
   end if;
   return  d_result;
end get_importanza; -- tipi_recapito_tpk.get_importanza
--------------------------------------------------------------------------------
function get_version
( 
  p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
) return TIPI_RECAPITO.version%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_version
 DESCRIZIONE: Getter per attributo version di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     TIPI_RECAPITO.version%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result TIPI_RECAPITO.version%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_tipo_recapito => p_id_tipo_recapito
                                        )
           , 'existsId on tipi_recapito_tpk.get_version' 
           );
   select version
   into   d_result
   from   TIPI_RECAPITO
   where  
   id_tipo_recapito = p_id_tipo_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on tipi_recapito_tpk.get_version'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'version')
                    , ' AFC_DDL.IsNullable on tipi_recapito_tpk.get_version'
                    );
   end if;
   return  d_result;
end get_version; -- tipi_recapito_tpk.get_version
--------------------------------------------------------------------------------
function get_utente_aggiornamento
( 
  p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
) return TIPI_RECAPITO.utente_aggiornamento%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_utente_aggiornamento
 DESCRIZIONE: Getter per attributo utente_aggiornamento di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     TIPI_RECAPITO.utente_aggiornamento%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result TIPI_RECAPITO.utente_aggiornamento%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_tipo_recapito => p_id_tipo_recapito
                                        )
           , 'existsId on tipi_recapito_tpk.get_utente_aggiornamento' 
           );
   select utente_aggiornamento
   into   d_result
   from   TIPI_RECAPITO
   where  
   id_tipo_recapito = p_id_tipo_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on tipi_recapito_tpk.get_utente_aggiornamento'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'utente_aggiornamento')
                    , ' AFC_DDL.IsNullable on tipi_recapito_tpk.get_utente_aggiornamento'
                    );
   end if;
   return  d_result;
end get_utente_aggiornamento; -- tipi_recapito_tpk.get_utente_aggiornamento
--------------------------------------------------------------------------------
function get_data_aggiornamento
( 
  p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
) return TIPI_RECAPITO.data_aggiornamento%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_data_aggiornamento
 DESCRIZIONE: Getter per attributo data_aggiornamento di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     TIPI_RECAPITO.data_aggiornamento%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result TIPI_RECAPITO.data_aggiornamento%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_tipo_recapito => p_id_tipo_recapito
                                        )
           , 'existsId on tipi_recapito_tpk.get_data_aggiornamento' 
           );
   select data_aggiornamento
   into   d_result
   from   TIPI_RECAPITO
   where  
   id_tipo_recapito = p_id_tipo_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on tipi_recapito_tpk.get_data_aggiornamento'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'data_aggiornamento')
                    , ' AFC_DDL.IsNullable on tipi_recapito_tpk.get_data_aggiornamento'
                    );
   end if;
   return  d_result;
end get_data_aggiornamento; -- tipi_recapito_tpk.get_data_aggiornamento
--------------------------------------------------------------------------------
procedure set_id_tipo_recapito
( 
  p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
, p_value  in TIPI_RECAPITO.id_tipo_recapito%type default null
) is
/******************************************************************************
 NOME:        set_id_tipo_recapito
 DESCRIZIONE: Setter per attributo id_tipo_recapito di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_tipo_recapito => p_id_tipo_recapito
                                        )
           , 'existsId on tipi_recapito_tpk.set_id_tipo_recapito' 
           );
   update TIPI_RECAPITO
   set id_tipo_recapito = p_value
   where
   id_tipo_recapito = p_id_tipo_recapito
   ;
end set_id_tipo_recapito; -- tipi_recapito_tpk.set_id_tipo_recapito
--------------------------------------------------------------------------------
procedure set_descrizione
( 
  p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
, p_value  in TIPI_RECAPITO.descrizione%type default null
) is
/******************************************************************************
 NOME:        set_descrizione
 DESCRIZIONE: Setter per attributo descrizione di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_tipo_recapito => p_id_tipo_recapito
                                        )
           , 'existsId on tipi_recapito_tpk.set_descrizione' 
           );
   update TIPI_RECAPITO
   set descrizione = p_value
   where
   id_tipo_recapito = p_id_tipo_recapito
   ;
end set_descrizione; -- tipi_recapito_tpk.set_descrizione
--------------------------------------------------------------------------------
procedure set_unico
( 
  p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
, p_value  in TIPI_RECAPITO.unico%type default null
) is
/******************************************************************************
 NOME:        set_unico
 DESCRIZIONE: Setter per attributo unico di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_tipo_recapito => p_id_tipo_recapito
                                        )
           , 'existsId on tipi_recapito_tpk.set_unico' 
           );
   update TIPI_RECAPITO
   set unico = p_value
   where
   id_tipo_recapito = p_id_tipo_recapito
   ;
end set_unico; -- tipi_recapito_tpk.set_unico
--------------------------------------------------------------------------------
procedure set_importanza
( 
  p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
, p_value  in TIPI_RECAPITO.importanza%type default null
) is
/******************************************************************************
 NOME:        set_importanza
 DESCRIZIONE: Setter per attributo importanza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_tipo_recapito => p_id_tipo_recapito
                                        )
           , 'existsId on tipi_recapito_tpk.set_importanza' 
           );
   update TIPI_RECAPITO
   set importanza = p_value
   where
   id_tipo_recapito = p_id_tipo_recapito
   ;
end set_importanza; -- tipi_recapito_tpk.set_importanza
--------------------------------------------------------------------------------
procedure set_version
( 
  p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
, p_value  in TIPI_RECAPITO.version%type default null
) is
/******************************************************************************
 NOME:        set_version
 DESCRIZIONE: Setter per attributo version di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_tipo_recapito => p_id_tipo_recapito
                                        )
           , 'existsId on tipi_recapito_tpk.set_version' 
           );
   update TIPI_RECAPITO
   set version = p_value
   where
   id_tipo_recapito = p_id_tipo_recapito
   ;
end set_version; -- tipi_recapito_tpk.set_version
--------------------------------------------------------------------------------
procedure set_utente_aggiornamento
( 
  p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
, p_value  in TIPI_RECAPITO.utente_aggiornamento%type default null
) is
/******************************************************************************
 NOME:        set_utente_aggiornamento
 DESCRIZIONE: Setter per attributo utente_aggiornamento di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_tipo_recapito => p_id_tipo_recapito
                                        )
           , 'existsId on tipi_recapito_tpk.set_utente_aggiornamento' 
           );
   update TIPI_RECAPITO
   set utente_aggiornamento = p_value
   where
   id_tipo_recapito = p_id_tipo_recapito
   ;
end set_utente_aggiornamento; -- tipi_recapito_tpk.set_utente_aggiornamento
--------------------------------------------------------------------------------
procedure set_data_aggiornamento
( 
  p_id_tipo_recapito  in TIPI_RECAPITO.id_tipo_recapito%type
, p_value  in TIPI_RECAPITO.data_aggiornamento%type default null
) is
/******************************************************************************
 NOME:        set_data_aggiornamento
 DESCRIZIONE: Setter per attributo data_aggiornamento di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_tipo_recapito => p_id_tipo_recapito
                                        )
           , 'existsId on tipi_recapito_tpk.set_data_aggiornamento' 
           );
   update TIPI_RECAPITO
   set data_aggiornamento = p_value
   where
   id_tipo_recapito = p_id_tipo_recapito
   ;
end set_data_aggiornamento; -- tipi_recapito_tpk.set_data_aggiornamento
--------------------------------------------------------------------------------
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
               || AFC.get_field_condition( ' and ( id_tipo_recapito ', p_id_tipo_recapito, ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( descrizione ', p_descrizione , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( unico ', p_unico , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( importanza ', p_importanza , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( version ', p_version , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( utente_aggiornamento ', p_utente_aggiornamento , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( data_aggiornamento ', p_data_aggiornamento , ' )', p_QBE, AFC.date_format )
               || ' ) ' || p_other_condition
               ;
   return d_statement;
end where_condition; --- tipi_recapito_tpk.where_condition
--------------------------------------------------------------------------------
function get_rows
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
   d_statement := ' select TIPI_RECAPITO.* '
               || afc.decode_value( p_extra_columns, null, null, ' , ' || p_extra_columns )
               || ' from TIPI_RECAPITO '
               || where_condition( 
                                   p_QBE => p_QBE
                                 , p_other_condition => p_other_condition
                                 , p_id_tipo_recapito => p_id_tipo_recapito
                                 , p_descrizione => p_descrizione
                                 , p_unico => p_unico
                                 , p_importanza => p_importanza
                                 , p_version => p_version
                                 , p_utente_aggiornamento => p_utente_aggiornamento
                                 , p_data_aggiornamento => p_data_aggiornamento
                                 )
               || ' ' || p_extra_condition
               || afc.decode_value( p_order_by, null, null, ' order by ' || p_order_by )
               ;
   d_ref_cursor := AFC_DML.get_ref_cursor( d_statement );
   return d_ref_cursor;
end get_rows; -- tipi_recapito_tpk.get_rows
--------------------------------------------------------------------------------
function count_rows
( p_QBE  in number default 0
, p_other_condition in varchar2 default null
, p_id_tipo_recapito  in varchar2 default null
, p_descrizione  in varchar2 default null
, p_unico  in varchar2 default null
, p_importanza  in varchar2 default null
, p_version  in varchar2 default null
, p_utente_aggiornamento  in varchar2 default null
, p_data_aggiornamento  in varchar2 default null
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
              Chiavi e attributi della table
 RITORNA:     Numero di righe che rispettano la selezione indicata.
******************************************************************************/
   d_result          integer;
   d_statement       AFC.t_statement;
begin
   d_statement := ' select count( * ) from TIPI_RECAPITO '
               || where_condition( 
                                   p_QBE => p_QBE
                                 , p_other_condition => p_other_condition
                                 , p_id_tipo_recapito => p_id_tipo_recapito
                                 , p_descrizione => p_descrizione
                                 , p_unico => p_unico
                                 , p_importanza => p_importanza
                                 , p_version => p_version
                                 , p_utente_aggiornamento => p_utente_aggiornamento
                                 , p_data_aggiornamento => p_data_aggiornamento
                                 );
   d_result := AFC.SQL_execute( d_statement );
   return d_result;
end count_rows; -- tipi_recapito_tpk.count_rows
--------------------------------------------------------------------------------
         
end tipi_recapito_tpk;
/

