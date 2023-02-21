CREATE OR REPLACE package body tipi_soggetto_tpk is
/******************************************************************************
 NOME:        tipi_soggetto_tpk
 DESCRIZIONE: Gestione tabella TIPI_SOGGETTO.
 ANNOTAZIONI: .
 REVISIONI:   .
 Rev.  Data        Autore      Descrizione.
 000   14/05/2009  mmalferrari  Prima emissione.
 001   24/07/2017  snegroni  Generazione automatica. 
 002   14/06/2018  snegroni  Generazione automatica. 
******************************************************************************/
   s_revisione_body      constant AFC.t_revision := '002 - 14/06/2018';
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
end versione; -- tipi_soggetto_tpk.versione
--------------------------------------------------------------------------------
function PK
(
 p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
) return t_PK is /* SLAVE_COPY */
/******************************************************************************
 NOME:        PK
 DESCRIZIONE: Costruttore di un t_PK dati gli attributi della chiave
******************************************************************************/
   d_result t_PK;   
begin
   d_result.tipo_soggetto := p_tipo_soggetto;
   DbC.PRE ( not DbC.PreOn or canHandle (
                                          p_tipo_soggetto => d_result.tipo_soggetto
                                        )
           , 'canHandle on tipi_soggetto_tpk.PK' 
           );
   return  d_result;
end PK; -- tipi_soggetto_tpk.PK
--------------------------------------------------------------------------------
function can_handle
(
 p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
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
          p_tipo_soggetto is null
       )
   then
      d_result := 0;
   end if;
   DbC.POST ( d_result = 1  or  d_result = 0
            , 'd_result = 1  or  d_result = 0 on tipi_soggetto_tpk.can_handle'
            );
   return  d_result;   
end can_handle; -- tipi_soggetto_tpk.can_handle
--------------------------------------------------------------------------------
function canHandle
(
 p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
) return boolean is /* SLAVE_COPY */
/******************************************************************************
 NOME:        canHandle
 DESCRIZIONE: La chiave specificata rispetta tutti i requisiti sugli attributi componenti.
 PARAMETRI:   Attributi chiave.
 RITORNA:     number: true se la chiave e manipolabile, false altrimenti.
 NOTE:        Wrapper boolean di can_handle (cfr. can_handle).
******************************************************************************/
   d_result constant boolean := AFC.to_boolean ( can_handle (
                                                              p_tipo_soggetto => p_tipo_soggetto
                                                            ) 
                                               );
begin
   return  d_result;
end canHandle; -- tipi_soggetto_tpk.canHandle
--------------------------------------------------------------------------------
function exists_id
( 
 p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
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
                                         p_tipo_soggetto => p_tipo_soggetto
                                        )
           , 'canHandle on tipi_soggetto_tpk.exists_id' 
           );
   begin
      select 1
      into   d_result
      from   TIPI_SOGGETTO
      where  
      tipo_soggetto = p_tipo_soggetto
      ;
   exception
      when no_data_found then
         d_result := 0;
   end;
   DbC.POST ( d_result = 1  or  d_result = 0
            , 'd_result = 1  or  d_result = 0 on tipi_soggetto_tpk.exists_id'
            );
   return  d_result;   
end exists_id; -- tipi_soggetto_tpk.exists_id
--------------------------------------------------------------------------------
function existsId
( 
 p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
) return boolean is /* SLAVE_COPY */
/******************************************************************************
 NOME:        existsId
 DESCRIZIONE: Esistenza riga con chiave indicata.
 NOTE:        Wrapper boolean di exists_id (cfr. exists_id).
******************************************************************************/
   d_result constant boolean := AFC.to_boolean ( exists_id (
                                                            p_tipo_soggetto => p_tipo_soggetto
                                                           ) 
                                               );
begin
   return  d_result;
end existsId; -- tipi_soggetto_tpk.existsId
--------------------------------------------------------------------------------
procedure ins
( 
  p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type 
, p_descrizione  in TIPI_SOGGETTO.descrizione%type 
, p_flag_trg  in TIPI_SOGGETTO.flag_trg%type default null
, p_version  in TIPI_SOGGETTO.version%type default null
, p_utente_aggiornamento  in TIPI_SOGGETTO.utente_aggiornamento%type default null
, p_data_aggiornamento  in TIPI_SOGGETTO.data_aggiornamento%type default null
, p_categoria_tipo_soggetto  in TIPI_SOGGETTO.categoria_tipo_soggetto%type default 'PF'
) is
/******************************************************************************
 NOME:        ins
 DESCRIZIONE: Inserimento di una riga con chiave e attributi indicati.
 PARAMETRI:   Chiavi e attributi della table.
******************************************************************************/
begin
   -- Check Mandatory on Insert
   
   DbC.PRE ( not DbC.PreOn or p_descrizione is not null or /*default value*/ '' is not null
           , 'p_descrizione on tipi_soggetto_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_flag_trg is not null or /*default value*/ 'default' is not null
           , 'p_flag_trg on tipi_soggetto_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_version is not null or /*default value*/ 'default' is not null
           , 'p_version on tipi_soggetto_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_utente_aggiornamento is not null or /*default value*/ 'default' is not null
           , 'p_utente_aggiornamento on tipi_soggetto_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_data_aggiornamento is not null or /*default value*/ 'default' is not null
           , 'p_data_aggiornamento on tipi_soggetto_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_categoria_tipo_soggetto is not null or /*default value*/ 'default' is not null
           , 'p_categoria_tipo_soggetto on tipi_soggetto_tpk.ins'
           );
   DbC.PRE (  not DbC.PreOn
           or (   p_tipo_soggetto is null and /*default value*/ '' is not null ) -- PK nullable on insert
           or not existsId (
                             p_tipo_soggetto => p_tipo_soggetto
                           )
           , 'not existsId on tipi_soggetto_tpk.ins'
           );
   insert into TIPI_SOGGETTO
   (
     tipo_soggetto
   , descrizione
   , flag_trg
   , version
   , utente_aggiornamento
   , data_aggiornamento
   , categoria_tipo_soggetto
   )
   values
   (
     p_tipo_soggetto
, p_descrizione
, p_flag_trg
, p_version
, p_utente_aggiornamento
, p_data_aggiornamento
, nvl( p_categoria_tipo_soggetto, 'PF' )
   );
end ins; -- tipi_soggetto_tpk.ins
--------------------------------------------------------------------------------
function ins
(
  p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type 
, p_descrizione  in TIPI_SOGGETTO.descrizione%type 
, p_flag_trg  in TIPI_SOGGETTO.flag_trg%type default null
, p_version  in TIPI_SOGGETTO.version%type default null
, p_utente_aggiornamento  in TIPI_SOGGETTO.utente_aggiornamento%type default null
, p_data_aggiornamento  in TIPI_SOGGETTO.data_aggiornamento%type default null
, p_categoria_tipo_soggetto  in TIPI_SOGGETTO.categoria_tipo_soggetto%type default 'PF'
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
           , 'p_descrizione on tipi_soggetto_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_flag_trg is not null or /*default value*/ 'default' is not null
           , 'p_flag_trg on tipi_soggetto_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_version is not null or /*default value*/ 'default' is not null
           , 'p_version on tipi_soggetto_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_utente_aggiornamento is not null or /*default value*/ 'default' is not null
           , 'p_utente_aggiornamento on tipi_soggetto_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_data_aggiornamento is not null or /*default value*/ 'default' is not null
           , 'p_data_aggiornamento on tipi_soggetto_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_categoria_tipo_soggetto is not null or /*default value*/ 'default' is not null
           , 'p_categoria_tipo_soggetto on tipi_soggetto_tpk.ins'
           );
   DbC.PRE (  not DbC.PreOn
           or (   p_tipo_soggetto is null and /*default value*/ '' is not null ) -- PK nullable on insert
           or not existsId (
                             p_tipo_soggetto => p_tipo_soggetto
                           )
           , 'not existsId on tipi_soggetto_tpk.ins'
           );
   insert into TIPI_SOGGETTO
   (
     tipo_soggetto
   , descrizione
   , flag_trg
   , version
   , utente_aggiornamento
   , data_aggiornamento
   , categoria_tipo_soggetto
   )
   values
   (
     p_tipo_soggetto
, p_descrizione
, p_flag_trg
, p_version
, p_utente_aggiornamento
, p_data_aggiornamento
, nvl( p_categoria_tipo_soggetto, 'PF' )
   );
   d_result := 0;
   return d_result;
end ins; -- tipi_soggetto_tpk.ins
--------------------------------------------------------------------------------
procedure upd
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
   DbC.PRE (  not DbC.PreOn
           or not ( ( 
p_OLD_descrizione is not null
 or p_OLD_flag_trg is not null
 or p_OLD_version is not null
 or p_OLD_utente_aggiornamento is not null
 or p_OLD_data_aggiornamento is not null
 or p_OLD_categoria_tipo_soggetto is not null
                    )
                    and (  nvl( p_check_OLD, -1 ) = 0
                        )
                  )
           , ' "OLD values" is not null on tipi_soggetto_tpk.upd'
           );
   d_key := PK ( 
                nvl( p_OLD_tipo_soggetto, p_NEW_tipo_soggetto )
               );
   DbC.PRE ( not DbC.PreOn or existsId ( 
                                         p_tipo_soggetto => d_key.tipo_soggetto
                                       )
           , 'existsId on tipi_soggetto_tpk.upd' 
           );
   update TIPI_SOGGETTO
   set 
       tipo_soggetto = NVL( p_NEW_tipo_soggetto, DECODE( AFC.IS_DEFAULT_NULL( 'TIPI_SOGGETTO.tipo_soggetto' ), 1, tipo_soggetto,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_tipo_soggetto, null, tipo_soggetto, null ) ) ) )
     , descrizione = NVL( p_NEW_descrizione, DECODE( AFC.IS_DEFAULT_NULL( 'TIPI_SOGGETTO.descrizione' ), 1, descrizione,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_descrizione, null, descrizione, null ) ) ) )
     , flag_trg = NVL( p_NEW_flag_trg, DECODE( AFC.IS_DEFAULT_NULL( 'TIPI_SOGGETTO.flag_trg' ), 1, flag_trg,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_flag_trg, null, flag_trg, null ) ) ) )
     , version = NVL( p_NEW_version, DECODE( AFC.IS_DEFAULT_NULL( 'TIPI_SOGGETTO.version' ), 1, version,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_version, null, version, null ) ) ) )
     , utente_aggiornamento = NVL( p_NEW_utente_aggiornamento, DECODE( AFC.IS_DEFAULT_NULL( 'TIPI_SOGGETTO.utente_aggiornamento' ), 1, utente_aggiornamento,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_utente_aggiornamento, null, utente_aggiornamento, null ) ) ) )
     , data_aggiornamento = NVL( p_NEW_data_aggiornamento, DECODE( AFC.IS_DEFAULT_NULL( 'TIPI_SOGGETTO.data_aggiornamento' ), 1, data_aggiornamento,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_data_aggiornamento, null, data_aggiornamento, null ) ) ) )
     , categoria_tipo_soggetto = NVL( p_NEW_categoria_tipo_soggetto, DECODE( AFC.IS_DEFAULT_NULL( 'TIPI_SOGGETTO.categoria_tipo_soggetto' ), 1, categoria_tipo_soggetto,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_categoria_tipo_soggetto, null, categoria_tipo_soggetto, null ) ) ) )
   where 
     tipo_soggetto = d_key.tipo_soggetto
   and (   p_check_OLD = 0
        or (   1 = 1
           and ( descrizione = p_OLD_descrizione or ( p_OLD_descrizione is null and ( p_check_OLD is null or descrizione is null ) ) )
           and ( flag_trg = p_OLD_flag_trg or ( p_OLD_flag_trg is null and ( p_check_OLD is null or flag_trg is null ) ) )
           and ( version = p_OLD_version or ( p_OLD_version is null and ( p_check_OLD is null or version is null ) ) )
           and ( utente_aggiornamento = p_OLD_utente_aggiornamento or ( p_OLD_utente_aggiornamento is null and ( p_check_OLD is null or utente_aggiornamento is null ) ) )
           and ( data_aggiornamento = p_OLD_data_aggiornamento or ( p_OLD_data_aggiornamento is null and ( p_check_OLD is null or data_aggiornamento is null ) ) )
           and ( categoria_tipo_soggetto = p_OLD_categoria_tipo_soggetto or ( p_OLD_categoria_tipo_soggetto is null and ( p_check_OLD is null or categoria_tipo_soggetto is null ) ) )
           )
       )
   ;
   d_row_found := SQL%ROWCOUNT;
   afc.default_null(NULL);
   DbC.ASSERTION ( not DbC.AssertionOn or d_row_found <= 1
                 , 'd_row_found <= 1 on tipi_soggetto_tpk.upd'
                 );
   if d_row_found < 1
   then
      raise_application_error ( AFC_ERROR.modified_by_other_user_number
                              , AFC_ERROR.modified_by_other_user_msg
                              );
   end if;
end upd; -- tipi_soggetto_tpk.upd
--------------------------------------------------------------------------------
procedure upd_column
( 
  p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
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
                                        p_tipo_soggetto => p_tipo_soggetto
                                       )
           , 'existsId on tipi_soggetto_tpk.upd_column' 
           );
   DbC.PRE ( not DbC.PreOn or p_column is not null
           , 'p_column is not null on tipi_soggetto_tpk.upd_column'
           );
   DbC.PRE ( not DbC.PreOn or AFC_DDL.HasAttribute( s_table_name, p_column )
           , 'AFC_DDL.HasAttribute on tipi_soggetto_tpk.upd_column'
           );
   DbC.PRE ( p_literal_value in ( 0, 1 ) or p_literal_value is null
           , 'p_literal_value on tipi_soggetto_tpk.upd_column; p_literal_value = ' || p_literal_value
           );
   if p_literal_value = 1
   or p_literal_value is null
   then
      d_literal := '''';
   end if;
   d_statement := ' declare '
               || '    d_row_found number; '
               || ' begin '
               || '    update TIPI_SOGGETTO '
               || '       set ' || p_column || ' = ' || d_literal || p_value || d_literal
               || '     where 1 = 1 '
               || nvl( AFC.get_field_condition( ' and ( tipo_soggetto ', p_tipo_soggetto, ' )', 0, null ), ' and ( tipo_soggetto is null ) ' )
               || '    ; '
               || '    d_row_found := SQL%ROWCOUNT; '
               || '    if d_row_found < 1 '
               || '    then '
               || '       raise_application_error ( AFC_ERROR.modified_by_other_user_number, AFC_ERROR.modified_by_other_user_msg ); '
               || '    end if; '
               || ' end; ';
   AFC.SQL_execute( d_statement );
end upd_column; -- tipi_soggetto_tpk.upd_column
--------------------------------------------------------------------------------
procedure upd_column
( 
p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
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
p_tipo_soggetto => p_tipo_soggetto
              , p_column => p_column
              , p_value => 'to_date( ''' || d_data || ''', ''' || AFC.date_format || ''' )'
              , p_literal_value => 0
              );   
end upd_column; -- tipi_soggetto_tpk.upd_column
--------------------------------------------------------------------------------
procedure del
( 
  p_check_old  in integer default 0
, p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
, p_descrizione  in TIPI_SOGGETTO.descrizione%type default null
, p_flag_trg  in TIPI_SOGGETTO.flag_trg%type default null
, p_version  in TIPI_SOGGETTO.version%type default null
, p_utente_aggiornamento  in TIPI_SOGGETTO.utente_aggiornamento%type default null
, p_data_aggiornamento  in TIPI_SOGGETTO.data_aggiornamento%type default null
, p_categoria_tipo_soggetto  in TIPI_SOGGETTO.categoria_tipo_soggetto%type default null
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
   DbC.PRE (  not DbC.PreOn
           or not ( ( 
p_descrizione is not null
 or p_flag_trg is not null
 or p_version is not null
 or p_utente_aggiornamento is not null
 or p_data_aggiornamento is not null
 or p_categoria_tipo_soggetto is not null
                    )
                    and (  nvl( p_check_OLD, -1 ) = 0
                        )
                  )
           , ' "OLD values" is not null on tipi_soggetto_tpk.del'
           );
   DbC.PRE ( not DbC.PreOn or existsId (
                                         p_tipo_soggetto => p_tipo_soggetto
                                       )
           , 'existsId on tipi_soggetto_tpk.del' 
           );
   delete from TIPI_SOGGETTO
   where 
     tipo_soggetto = p_tipo_soggetto
   and (   p_check_OLD = 0
        or (   1 = 1
           and ( descrizione = p_descrizione or ( p_descrizione is null and ( p_check_OLD is null or descrizione is null ) ) )
           and ( flag_trg = p_flag_trg or ( p_flag_trg is null and ( p_check_OLD is null or flag_trg is null ) ) )
           and ( version = p_version or ( p_version is null and ( p_check_OLD is null or version is null ) ) )
           and ( utente_aggiornamento = p_utente_aggiornamento or ( p_utente_aggiornamento is null and ( p_check_OLD is null or utente_aggiornamento is null ) ) )
           and ( data_aggiornamento = p_data_aggiornamento or ( p_data_aggiornamento is null and ( p_check_OLD is null or data_aggiornamento is null ) ) )
           and ( categoria_tipo_soggetto = p_categoria_tipo_soggetto or ( p_categoria_tipo_soggetto is null and ( p_check_OLD is null or categoria_tipo_soggetto is null ) ) )
           )
       )
   ;
   d_row_found := SQL%ROWCOUNT;
   DbC.ASSERTION ( not DbC.AssertionOn or d_row_found <= 1
                 , 'd_row_found <= 1 on tipi_soggetto_tpk.del'
                 );
   if d_row_found < 1
   then
      raise_application_error ( AFC_ERROR.modified_by_other_user_number
                              , AFC_ERROR.modified_by_other_user_msg
                              );
   end if;
   DbC.POST ( not DbC.PostOn or not existsId ( 
                                               p_tipo_soggetto => p_tipo_soggetto
                                             )
            , 'existsId on tipi_soggetto_tpk.del' 
            );
end del; -- tipi_soggetto_tpk.del
--------------------------------------------------------------------------------
function get_descrizione
( 
  p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
) return TIPI_SOGGETTO.descrizione%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_descrizione
 DESCRIZIONE: Getter per attributo descrizione di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     TIPI_SOGGETTO.descrizione%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result TIPI_SOGGETTO.descrizione%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_tipo_soggetto => p_tipo_soggetto
                                        )
           , 'existsId on tipi_soggetto_tpk.get_descrizione' 
           );
   select descrizione
   into   d_result
   from   TIPI_SOGGETTO
   where  
   tipo_soggetto = p_tipo_soggetto
   ;
  -- Check Mandatory Attribute on Table
  if (true)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on tipi_soggetto_tpk.get_descrizione'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'descrizione')
                    , ' AFC_DDL.IsNullable on tipi_soggetto_tpk.get_descrizione'
                    );
   end if;
   return  d_result;
end get_descrizione; -- tipi_soggetto_tpk.get_descrizione
--------------------------------------------------------------------------------
function get_flag_trg
( 
  p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
) return TIPI_SOGGETTO.flag_trg%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_flag_trg
 DESCRIZIONE: Getter per attributo flag_trg di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     TIPI_SOGGETTO.flag_trg%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result TIPI_SOGGETTO.flag_trg%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_tipo_soggetto => p_tipo_soggetto
                                        )
           , 'existsId on tipi_soggetto_tpk.get_flag_trg' 
           );
   select flag_trg
   into   d_result
   from   TIPI_SOGGETTO
   where  
   tipo_soggetto = p_tipo_soggetto
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on tipi_soggetto_tpk.get_flag_trg'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'flag_trg')
                    , ' AFC_DDL.IsNullable on tipi_soggetto_tpk.get_flag_trg'
                    );
   end if;
   return  d_result;
end get_flag_trg; -- tipi_soggetto_tpk.get_flag_trg
--------------------------------------------------------------------------------
function get_version
( 
  p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
) return TIPI_SOGGETTO.version%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_version
 DESCRIZIONE: Getter per attributo version di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     TIPI_SOGGETTO.version%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result TIPI_SOGGETTO.version%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_tipo_soggetto => p_tipo_soggetto
                                        )
           , 'existsId on tipi_soggetto_tpk.get_version' 
           );
   select version
   into   d_result
   from   TIPI_SOGGETTO
   where  
   tipo_soggetto = p_tipo_soggetto
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on tipi_soggetto_tpk.get_version'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'version')
                    , ' AFC_DDL.IsNullable on tipi_soggetto_tpk.get_version'
                    );
   end if;
   return  d_result;
end get_version; -- tipi_soggetto_tpk.get_version
--------------------------------------------------------------------------------
function get_utente_aggiornamento
( 
  p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
) return TIPI_SOGGETTO.utente_aggiornamento%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_utente_aggiornamento
 DESCRIZIONE: Getter per attributo utente_aggiornamento di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     TIPI_SOGGETTO.utente_aggiornamento%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result TIPI_SOGGETTO.utente_aggiornamento%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_tipo_soggetto => p_tipo_soggetto
                                        )
           , 'existsId on tipi_soggetto_tpk.get_utente_aggiornamento' 
           );
   select utente_aggiornamento
   into   d_result
   from   TIPI_SOGGETTO
   where  
   tipo_soggetto = p_tipo_soggetto
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on tipi_soggetto_tpk.get_utente_aggiornamento'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'utente_aggiornamento')
                    , ' AFC_DDL.IsNullable on tipi_soggetto_tpk.get_utente_aggiornamento'
                    );
   end if;
   return  d_result;
end get_utente_aggiornamento; -- tipi_soggetto_tpk.get_utente_aggiornamento
--------------------------------------------------------------------------------
function get_data_aggiornamento
( 
  p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
) return TIPI_SOGGETTO.data_aggiornamento%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_data_aggiornamento
 DESCRIZIONE: Getter per attributo data_aggiornamento di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     TIPI_SOGGETTO.data_aggiornamento%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result TIPI_SOGGETTO.data_aggiornamento%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_tipo_soggetto => p_tipo_soggetto
                                        )
           , 'existsId on tipi_soggetto_tpk.get_data_aggiornamento' 
           );
   select data_aggiornamento
   into   d_result
   from   TIPI_SOGGETTO
   where  
   tipo_soggetto = p_tipo_soggetto
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on tipi_soggetto_tpk.get_data_aggiornamento'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'data_aggiornamento')
                    , ' AFC_DDL.IsNullable on tipi_soggetto_tpk.get_data_aggiornamento'
                    );
   end if;
   return  d_result;
end get_data_aggiornamento; -- tipi_soggetto_tpk.get_data_aggiornamento
--------------------------------------------------------------------------------
function get_categoria_tipo_soggetto
( 
  p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
) return TIPI_SOGGETTO.categoria_tipo_soggetto%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_categoria_tipo_soggetto
 DESCRIZIONE: Getter per attributo categoria_tipo_soggetto di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     TIPI_SOGGETTO.categoria_tipo_soggetto%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result TIPI_SOGGETTO.categoria_tipo_soggetto%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_tipo_soggetto => p_tipo_soggetto
                                        )
           , 'existsId on tipi_soggetto_tpk.get_categoria_tipo_soggetto' 
           );
   select categoria_tipo_soggetto
   into   d_result
   from   TIPI_SOGGETTO
   where  
   tipo_soggetto = p_tipo_soggetto
   ;
  -- Check Mandatory Attribute on Table
  if (true)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on tipi_soggetto_tpk.get_categoria_tipo_soggetto'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'categoria_tipo_soggetto')
                    , ' AFC_DDL.IsNullable on tipi_soggetto_tpk.get_categoria_tipo_soggetto'
                    );
   end if;
   return  d_result;
end get_categoria_tipo_soggetto; -- tipi_soggetto_tpk.get_categoria_tipo_soggetto
--------------------------------------------------------------------------------
procedure set_tipo_soggetto
( 
  p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
, p_value  in TIPI_SOGGETTO.tipo_soggetto%type default null
) is
/******************************************************************************
 NOME:        set_tipo_soggetto
 DESCRIZIONE: Setter per attributo tipo_soggetto di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_tipo_soggetto => p_tipo_soggetto
                                        )
           , 'existsId on tipi_soggetto_tpk.set_tipo_soggetto' 
           );
   update TIPI_SOGGETTO
   set tipo_soggetto = p_value
   where
   tipo_soggetto = p_tipo_soggetto
   ;
end set_tipo_soggetto; -- tipi_soggetto_tpk.set_tipo_soggetto
--------------------------------------------------------------------------------
procedure set_descrizione
( 
  p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
, p_value  in TIPI_SOGGETTO.descrizione%type default null
) is
/******************************************************************************
 NOME:        set_descrizione
 DESCRIZIONE: Setter per attributo descrizione di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_tipo_soggetto => p_tipo_soggetto
                                        )
           , 'existsId on tipi_soggetto_tpk.set_descrizione' 
           );
   update TIPI_SOGGETTO
   set descrizione = p_value
   where
   tipo_soggetto = p_tipo_soggetto
   ;
end set_descrizione; -- tipi_soggetto_tpk.set_descrizione
--------------------------------------------------------------------------------
procedure set_flag_trg
( 
  p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
, p_value  in TIPI_SOGGETTO.flag_trg%type default null
) is
/******************************************************************************
 NOME:        set_flag_trg
 DESCRIZIONE: Setter per attributo flag_trg di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_tipo_soggetto => p_tipo_soggetto
                                        )
           , 'existsId on tipi_soggetto_tpk.set_flag_trg' 
           );
   update TIPI_SOGGETTO
   set flag_trg = p_value
   where
   tipo_soggetto = p_tipo_soggetto
   ;
end set_flag_trg; -- tipi_soggetto_tpk.set_flag_trg
--------------------------------------------------------------------------------
procedure set_version
( 
  p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
, p_value  in TIPI_SOGGETTO.version%type default null
) is
/******************************************************************************
 NOME:        set_version
 DESCRIZIONE: Setter per attributo version di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_tipo_soggetto => p_tipo_soggetto
                                        )
           , 'existsId on tipi_soggetto_tpk.set_version' 
           );
   update TIPI_SOGGETTO
   set version = p_value
   where
   tipo_soggetto = p_tipo_soggetto
   ;
end set_version; -- tipi_soggetto_tpk.set_version
--------------------------------------------------------------------------------
procedure set_utente_aggiornamento
( 
  p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
, p_value  in TIPI_SOGGETTO.utente_aggiornamento%type default null
) is
/******************************************************************************
 NOME:        set_utente_aggiornamento
 DESCRIZIONE: Setter per attributo utente_aggiornamento di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_tipo_soggetto => p_tipo_soggetto
                                        )
           , 'existsId on tipi_soggetto_tpk.set_utente_aggiornamento' 
           );
   update TIPI_SOGGETTO
   set utente_aggiornamento = p_value
   where
   tipo_soggetto = p_tipo_soggetto
   ;
end set_utente_aggiornamento; -- tipi_soggetto_tpk.set_utente_aggiornamento
--------------------------------------------------------------------------------
procedure set_data_aggiornamento
( 
  p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
, p_value  in TIPI_SOGGETTO.data_aggiornamento%type default null
) is
/******************************************************************************
 NOME:        set_data_aggiornamento
 DESCRIZIONE: Setter per attributo data_aggiornamento di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_tipo_soggetto => p_tipo_soggetto
                                        )
           , 'existsId on tipi_soggetto_tpk.set_data_aggiornamento' 
           );
   update TIPI_SOGGETTO
   set data_aggiornamento = p_value
   where
   tipo_soggetto = p_tipo_soggetto
   ;
end set_data_aggiornamento; -- tipi_soggetto_tpk.set_data_aggiornamento
--------------------------------------------------------------------------------
procedure set_categoria_tipo_soggetto
( 
  p_tipo_soggetto  in TIPI_SOGGETTO.tipo_soggetto%type
, p_value  in TIPI_SOGGETTO.categoria_tipo_soggetto%type default null
) is
/******************************************************************************
 NOME:        set_categoria_tipo_soggetto
 DESCRIZIONE: Setter per attributo categoria_tipo_soggetto di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_tipo_soggetto => p_tipo_soggetto
                                        )
           , 'existsId on tipi_soggetto_tpk.set_categoria_tipo_soggetto' 
           );
   update TIPI_SOGGETTO
   set categoria_tipo_soggetto = p_value
   where
   tipo_soggetto = p_tipo_soggetto
   ;
end set_categoria_tipo_soggetto; -- tipi_soggetto_tpk.set_categoria_tipo_soggetto
--------------------------------------------------------------------------------
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
               || AFC.get_field_condition( ' and ( tipo_soggetto ', p_tipo_soggetto, ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( descrizione ', p_descrizione , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( flag_trg ', p_flag_trg , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( version ', p_version , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( utente_aggiornamento ', p_utente_aggiornamento , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( data_aggiornamento ', p_data_aggiornamento , ' )', p_QBE, AFC.date_format )
               || AFC.get_field_condition( ' and ( categoria_tipo_soggetto ', p_categoria_tipo_soggetto , ' )', p_QBE, null )
               || ' ) ' || p_other_condition
               ;
   return d_statement;
end where_condition; --- tipi_soggetto_tpk.where_condition
--------------------------------------------------------------------------------
function get_rows
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
              p_columns: colonne da estrarre (se null è *)
              p_offset: rownum da cui partire per estrazione
              p_limit: rownum a cui terminare estrazione
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
   d_statement := case 
                  when p_offset is null and p_limit is null then ''
                  else 'select * from ( '
                    || 'select rownum "ROW#", t.* from ( '
                  end 
               || 'select ' || nvl(p_columns,'TIPI_SOGGETTO.*') || ' '
               || afc.decode_value( p_extra_columns, null, null, ' , ' || p_extra_columns )
               || ' from TIPI_SOGGETTO '
               || where_condition( 
                                   p_QBE => p_QBE
                                 , p_other_condition => p_extra_condition || ' ' || p_other_condition
                                 , p_tipo_soggetto => p_tipo_soggetto
                                 , p_descrizione => p_descrizione
                                 , p_flag_trg => p_flag_trg
                                 , p_version => p_version
                                 , p_utente_aggiornamento => p_utente_aggiornamento
                                 , p_data_aggiornamento => p_data_aggiornamento
                                 , p_categoria_tipo_soggetto => p_categoria_tipo_soggetto
                                 )
               || afc.decode_value( p_order_by, null, null, ' order by ' || p_order_by )
               || case 
                  when p_offset is null and p_limit is null then ''
                  else ' ) t ' 
                    || ' ) '
                    || ' where "ROW#" > ' || nvl( p_offset , 0)
                    || '   and "ROW#" <  '  || (1 + nvl( p_offset , 0) +nvl( p_limit , 999999)) 
                  end
               ;
   d_ref_cursor := AFC_DML.get_ref_cursor( d_statement );
   return d_ref_cursor;
end get_rows; -- tipi_soggetto_tpk.get_rows
--------------------------------------------------------------------------------
function count_rows
( p_QBE  in number default 0
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
              p_extra_condition: condizioni aggiuntive 
              p_columns: colonne da estrarre (se null è *)
              Chiavi e attributi della table
 RITORNA:     Numero di righe che rispettano la selezione indicata.
******************************************************************************/
   d_result          integer;
   d_statement       AFC.t_statement;
begin
   d_statement := 'select count(*) from '
               || case
                  when p_columns is null then ''
                  else ' ( select ' || p_columns ||' from '
                  end
               || ' TIPI_SOGGETTO '
               || where_condition( 
                                   p_QBE => p_QBE
                                 , p_other_condition => p_extra_condition || ' ' || p_other_condition
                                 , p_tipo_soggetto => p_tipo_soggetto
                                 , p_descrizione => p_descrizione
                                 , p_flag_trg => p_flag_trg
                                 , p_version => p_version
                                 , p_utente_aggiornamento => p_utente_aggiornamento
                                 , p_data_aggiornamento => p_data_aggiornamento
                                 , p_categoria_tipo_soggetto => p_categoria_tipo_soggetto
                                 )
               || case 
                  when p_columns is null then ''
                  else ' ) '
                  end
               ;
   d_result := AFC.SQL_execute( d_statement );
   return d_result;
end count_rows; -- tipi_soggetto_tpk.count_rows
--------------------------------------------------------------------------------
         
end tipi_soggetto_tpk;
/

