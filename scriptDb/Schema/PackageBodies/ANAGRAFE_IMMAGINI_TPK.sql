CREATE OR REPLACE package body anagrafe_immagini_tpk is
/******************************************************************************
 NOME:        anagrafe_immagini_tpk
 DESCRIZIONE: Gestione tabella ANAGRAFE_IMMAGINI.
 ANNOTAZIONI: .
 REVISIONI:   .
 Rev.  Data        Autore  Descrizione.
 000   15/07/2010  snegroni  Prima emissione.
******************************************************************************/
   s_revisione_body      constant AFC.t_revision := '000';
--------------------------------------------------------------------------------
function versione
return varchar2 is /* SLAVE_COPY */
/******************************************************************************
 NOME:        versione
 DESCRIZIONE: Versione e revisione di distribuzione del package.
 RITORNA:     varchar2 stringa contenente versione e revisione.
 NOTE:        Primo numero  : versione compatibilità del Package.
              Secondo numero: revisione del Package specification.
              Terzo numero  : revisione del Package body.
******************************************************************************/
begin
   return AFC.version ( s_revisione, s_revisione_body );
end versione; -- anagrafe_immagini_tpk.versione
--------------------------------------------------------------------------------
function PK
(
 p_ni  in ANAGRAFE_IMMAGINI.ni%type
) return t_PK is /* SLAVE_COPY */
/******************************************************************************
 NOME:        PK
 DESCRIZIONE: Costruttore di un t_PK dati gli attributi della chiave
******************************************************************************/
   d_result t_PK;
begin
   d_result.ni := p_ni;
   DbC.PRE ( not DbC.PreOn or canHandle (
                                          p_ni => d_result.ni
                                        )
           , 'canHandle on anagrafe_immagini_tpk.PK'
           );
   return  d_result;
end PK; -- anagrafe_immagini_tpk.PK
--------------------------------------------------------------------------------
function can_handle
(
 p_ni  in ANAGRAFE_IMMAGINI.ni%type
) return number is /* SLAVE_COPY */
/******************************************************************************
 NOME:        can_handle
 DESCRIZIONE: La chiave specificata rispetta tutti i requisiti sugli attributi componenti.
 PARAMETRI:   Attributi chiave.
 RITORNA:     number: 1 se la chiave è manipolabile, 0 altrimenti.
 NOTE:        cfr. canHandle per ritorno valori boolean.
******************************************************************************/
   d_result number;
begin
   d_result := 1;
   -- nelle chiavi primarie composte da più attributi, ciascun attributo deve essere not null
   if  d_result = 1
   and (
          p_ni is null
       )
   then
      d_result := 0;
   end if;
   DbC.POST ( d_result = 1  or  d_result = 0
            , 'd_result = 1  or  d_result = 0 on anagrafe_immagini_tpk.can_handle'
            );
   return  d_result;
end can_handle; -- anagrafe_immagini_tpk.can_handle
--------------------------------------------------------------------------------
function canHandle
(
 p_ni  in ANAGRAFE_IMMAGINI.ni%type
) return boolean is /* SLAVE_COPY */
/******************************************************************************
 NOME:        canHandle
 DESCRIZIONE: La chiave specificata rispetta tutti i requisiti sugli attributi componenti.
 PARAMETRI:   Attributi chiave.
 RITORNA:     number: true se la chiave è manipolabile, false altrimenti.
 NOTE:        Wrapper boolean di can_handle (cfr. can_handle).
******************************************************************************/
   d_result constant boolean := AFC.to_boolean ( can_handle (
                                                              p_ni => p_ni
                                                            )
                                               );
begin
   return  d_result;
end canHandle; -- anagrafe_immagini_tpk.canHandle
--------------------------------------------------------------------------------
function exists_id
(
 p_ni  in ANAGRAFE_IMMAGINI.ni%type
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
                                         p_ni => p_ni
                                        )
           , 'canHandle on anagrafe_immagini_tpk.exists_id'
           );
   begin
      select 1
      into   d_result
      from   ANAGRAFE_IMMAGINI
      where
      ni = p_ni
      ;
   exception
      when no_data_found then
         d_result := 0;
   end;
   DbC.POST ( d_result = 1  or  d_result = 0
            , 'd_result = 1  or  d_result = 0 on anagrafe_immagini_tpk.exists_id'
            );
   return  d_result;
end exists_id; -- anagrafe_immagini_tpk.exists_id
--------------------------------------------------------------------------------
function existsId
(
 p_ni  in ANAGRAFE_IMMAGINI.ni%type
) return boolean is /* SLAVE_COPY */
/******************************************************************************
 NOME:        existsId
 DESCRIZIONE: Esistenza riga con chiave indicata.
 NOTE:        Wrapper boolean di exists_id (cfr. exists_id).
******************************************************************************/
   d_result constant boolean := AFC.to_boolean ( exists_id (
                                                            p_ni => p_ni
                                                           )
                                               );
begin
   return  d_result;
end existsId; -- anagrafe_immagini_tpk.existsId
--------------------------------------------------------------------------------
procedure ins
(
  p_ni  in ANAGRAFE_IMMAGINI.ni%type default null
, p_id_immagine  in ANAGRAFE_IMMAGINI.id_immagine%type
) is
/******************************************************************************
 NOME:        ins
 DESCRIZIONE: Inserimento di una riga con chiave e attributi indicati.
 PARAMETRI:   Chiavi e attributi della table.
******************************************************************************/
begin
   -- Check Mandatory on Insert
   DbC.PRE ( not DbC.PreOn or p_id_immagine is not null or /*default value*/ '' is not null
           , 'p_id_immagine on anagrafe_immagini_tpk.ins'
           );
   DbC.PRE (  not DbC.PreOn
           or (   p_ni is null and /*default value*/ 'default null' is not null ) -- PK nullable on insert
           or not existsId (
                             p_ni => p_ni
                           )
           , 'not existsId on anagrafe_immagini_tpk.ins'
           );
   insert into ANAGRAFE_IMMAGINI
   (
     ni
   , id_immagine
   )
   values
   (
     p_ni
   , p_id_immagine
   );
end ins; -- anagrafe_immagini_tpk.ins
--------------------------------------------------------------------------------
function ins  /*+ SOA  */
(
  p_ni  in ANAGRAFE_IMMAGINI.ni%type default null
, p_id_immagine  in ANAGRAFE_IMMAGINI.id_immagine%type
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
   DbC.PRE ( not DbC.PreOn or p_id_immagine is not null or /*default value*/ '' is not null
           , 'p_id_immagine on anagrafe_immagini_tpk.ins'
           );
   DbC.PRE (  not DbC.PreOn
           or (   p_ni is null and /*default value*/ 'default null' is not null ) -- PK nullable on insert
           or not existsId (
                             p_ni => p_ni
                           )
           , 'not existsId on anagrafe_immagini_tpk.ins'
           );
   begin
      insert into ANAGRAFE_IMMAGINI
      (
        ni
      , id_immagine
      )
      values
      (
        p_ni
      , p_id_immagine
      ) returning ni
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
end ins; -- anagrafe_immagini_tpk.ins
--------------------------------------------------------------------------------
procedure upd
(
  p_check_OLD  in integer default 0
, p_NEW_ni  in ANAGRAFE_IMMAGINI.ni%type
, p_OLD_ni  in ANAGRAFE_IMMAGINI.ni%type default null
, p_NEW_id_immagine  in ANAGRAFE_IMMAGINI.id_immagine%type default afc.default_null('ANAGRAFE_IMMAGINI.id_immagine')
, p_OLD_id_immagine  in ANAGRAFE_IMMAGINI.id_immagine%type default null
) is
/******************************************************************************
 NOME:        upd
 DESCRIZIONE: Aggiornamento di una riga con chiave.
 PARAMETRI:   Chiavi e attributi della table
              p_check_OLD: 0 e null, ricerca senza controllo su attributi precedenti
                           1       , ricerca con controllo anche su attributi precedenti.
 NOTE:        Nel caso in cui non venga elaborato alcun record viene lanciata
              l'eccezione -20010 (cfr. AFC_ERROR).
              Se p_check_old è NULL, gli attributi vengono annullati solo se viene
              indicato anche il relativo attributo OLD.
              Se p_check_old = 1, viene controllato se il record corrispondente a
              tutti i campi passati come parametri esiste nella tabella.
******************************************************************************/
   d_key t_PK;
   d_row_found number;
begin
   DbC.PRE (  not DbC.PreOn
           or not ( (
p_OLD_id_immagine is not null
                    )
                    and (  nvl( p_check_OLD, -1 ) = 0
                        )
                  )
           , ' "OLD values" is not null on anagrafe_immagini_tpk.upd'
           );
   d_key := PK (
                nvl( p_OLD_ni, p_NEW_ni )
               );
   DbC.PRE ( not DbC.PreOn or existsId (
                                         p_ni => d_key.ni
                                       )
           , 'existsId on anagrafe_immagini_tpk.upd'
           );
   update ANAGRAFE_IMMAGINI
   set
       ni = nvl( p_NEW_ni, decode( afc.is_default_null( 'ANAGRAFE_IMMAGINI.ni'), 1, ni, null) )
     , id_immagine = nvl( p_NEW_id_immagine, decode( afc.is_default_null( 'ANAGRAFE_IMMAGINI.id_immagine'), 1, id_immagine, null) )
   where
     ni = d_key.ni
   and (   p_check_OLD = 0
        or (   1 = 1
           and ( id_immagine = p_OLD_id_immagine or ( p_OLD_id_immagine is null and ( p_check_OLD is null or id_immagine is null ) ) )
           )
       )
   ;
   d_row_found := SQL%ROWCOUNT;
   afc.default_null(NULL);
   DbC.ASSERTION ( not DbC.AssertionOn or d_row_found <= 1
                 , 'd_row_found <= 1 on anagrafe_immagini_tpk.upd'
                 );
   if d_row_found < 1
   then
      raise_application_error ( AFC_ERROR.modified_by_other_user_number
                              , AFC_ERROR.modified_by_other_user_msg
                              );
   end if;
end upd; -- anagrafe_immagini_tpk.upd
--------------------------------------------------------------------------------
procedure upd_column
(
  p_ni  in ANAGRAFE_IMMAGINI.ni%type
, p_column         in varchar2
, p_value          in varchar2 default null
, p_literal_value  in number   default 1
) is
/******************************************************************************
 NOME:        upd_column
 DESCRIZIONE: Aggiornamento del campo p_column col valore p_value.
 PARAMETRI:   p_column:        identificatore del campo da aggiornare.
              p_value:         valore da modificare.
              p_literal_value: indica se il valore è un stringa e non un numero
                               o una funzione.
******************************************************************************/
   d_statement AFC.t_statement;
   d_literal   varchar2(2);
begin
   DbC.PRE ( not DbC.PreOn or existsId (
                                        p_ni => p_ni
                                       )
           , 'existsId on anagrafe_immagini_tpk.upd_column'
           );
   DbC.PRE ( not DbC.PreOn or p_column is not null
           , 'p_column is not null on anagrafe_immagini_tpk.upd_column'
           );
   DbC.PRE ( not DbC.PreOn or AFC_DDL.HasAttribute( s_table_name, p_column )
           , 'AFC_DDL.HasAttribute on anagrafe_immagini_tpk.upd_column'
           );
   DbC.PRE ( p_literal_value in ( 0, 1 ) or p_literal_value is null
           , 'p_literal_value on anagrafe_immagini_tpk.upd_column; p_literal_value = ' || p_literal_value
           );
   if p_literal_value = 1
   or p_literal_value is null
   then
      d_literal := '''';
   end if;
   d_statement := ' declare '
               || '    d_row_found number; '
               || ' begin '
               || '    update ANAGRAFE_IMMAGINI '
               || '       set ' || p_column || ' = ' || d_literal || p_value || d_literal
               || '     where 1 = 1 '
               || nvl( AFC.get_field_condition( ' and ( ni ', p_ni, ' )', 0, null ), ' and ( ni is null ) ' )
               || '    ; '
               || '    d_row_found := SQL%ROWCOUNT; '
               || '    if d_row_found < 1 '
               || '    then '
               || '       raise_application_error ( AFC_ERROR.modified_by_other_user_number, AFC_ERROR.modified_by_other_user_msg ); '
               || '    end if; '
               || ' end; ';
   AFC.SQL_execute( d_statement );
end upd_column; -- anagrafe_immagini_tpk.upd_column
--------------------------------------------------------------------------------
procedure del
(
  p_check_old  in integer default 0
, p_ni  in ANAGRAFE_IMMAGINI.ni%type
, p_id_immagine  in ANAGRAFE_IMMAGINI.id_immagine%type default null
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
p_id_immagine is not null
                    )
                    and (  nvl( p_check_OLD, -1 ) = 0
                        )
                  )
           , ' "OLD values" is not null on anagrafe_immagini_tpk.del'
           );
   DbC.PRE ( not DbC.PreOn or existsId (
                                         p_ni => p_ni
                                       )
           , 'existsId on anagrafe_immagini_tpk.del'
           );
   delete from ANAGRAFE_IMMAGINI
   where
     ni = p_ni
   and (   p_check_OLD = 0
        or (   1 = 1
           and ( id_immagine = p_id_immagine or ( p_id_immagine is null and ( p_check_OLD is null or id_immagine is null ) ) )
           )
       )
   ;
   d_row_found := SQL%ROWCOUNT;
   DbC.ASSERTION ( not DbC.AssertionOn or d_row_found <= 1
                 , 'd_row_found <= 1 on anagrafe_immagini_tpk.del'
                 );
   if d_row_found < 1
   then
      raise_application_error ( AFC_ERROR.modified_by_other_user_number
                              , AFC_ERROR.modified_by_other_user_msg
                              );
   end if;
   DbC.POST ( not DbC.PostOn or not existsId (
                                               p_ni => p_ni
                                             )
            , 'existsId on anagrafe_immagini_tpk.del'
            );
end del; -- anagrafe_immagini_tpk.del
--------------------------------------------------------------------------------
function get_id_immagine
(
  p_ni  in ANAGRAFE_IMMAGINI.ni%type
) return ANAGRAFE_IMMAGINI.id_immagine%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_id_immagine
 DESCRIZIONE: Getter per attributo id_immagine di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_IMMAGINI.id_immagine%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_IMMAGINI.id_immagine%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
                                        )
           , 'existsId on anagrafe_immagini_tpk.get_id_immagine'
           );
   select id_immagine
   into   d_result
   from   ANAGRAFE_IMMAGINI
   where
   ni = p_ni
   ;
  -- Check Mandatory Attribute on Table
  if (true)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_immagini_tpk.get_id_immagine'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'id_immagine')
                    , ' AFC_DDL.IsNullable on anagrafe_immagini_tpk.get_id_immagine'
                    );
   end if;
   return  d_result;
end get_id_immagine; -- anagrafe_immagini_tpk.get_id_immagine
--------------------------------------------------------------------------------
procedure set_ni
(
  p_ni  in ANAGRAFE_IMMAGINI.ni%type
, p_value  in ANAGRAFE_IMMAGINI.ni%type default null
) is
/******************************************************************************
 NOME:        set_ni
 DESCRIZIONE: Setter per attributo ni di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
                                        )
           , 'existsId on anagrafe_immagini_tpk.set_ni'
           );
   update ANAGRAFE_IMMAGINI
   set ni = p_value
   where
   ni = p_ni
   ;
end set_ni; -- anagrafe_immagini_tpk.set_ni
--------------------------------------------------------------------------------
procedure set_id_immagine
(
  p_ni  in ANAGRAFE_IMMAGINI.ni%type
, p_value  in ANAGRAFE_IMMAGINI.id_immagine%type default null
) is
/******************************************************************************
 NOME:        set_id_immagine
 DESCRIZIONE: Setter per attributo id_immagine di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
                                        )
           , 'existsId on anagrafe_immagini_tpk.set_id_immagine'
           );
   update ANAGRAFE_IMMAGINI
   set id_immagine = p_value
   where
   ni = p_ni
   ;
end set_id_immagine; -- anagrafe_immagini_tpk.set_id_immagine
--------------------------------------------------------------------------------
function where_condition /* SLAVE_COPY */
( p_QBE  in number default 0
, p_other_condition in varchar2 default null
, p_ni  in varchar2 default null
, p_id_immagine  in varchar2 default null
) return AFC.t_statement is /* SLAVE_COPY */
/******************************************************************************
 NOME:        where_condition
 DESCRIZIONE: Ritorna la where_condition per lo statement di select di get_rows e count_rows.
 PARAMETRI:   p_other_condition
              p_QBE 0: se l'operatore da utilizzare nella where-condition è
quello di default ('=')
                    1: se l'operatore da utilizzare nella where-condition è
quello specificato per ogni attributo.
              Chiavi e attributi della table
 RITORNA:     AFC.t_statement.
 NOTE:        Se p_QBE = 1 , ogni parametro deve contenere, nella prima parte,
              l'operatore da utilizzare nella where-condition.
******************************************************************************/
   d_statement AFC.t_statement;
begin
   d_statement := ' where ( 1 = 1 '
               || AFC.get_field_condition( ' and ( ni ', p_ni, ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( id_immagine ', p_id_immagine , ' )', p_QBE, null )
               || ' ) ' || p_other_condition
               ;
   return d_statement;
end where_condition; --- anagrafe_immagini_tpk.where_condition
--------------------------------------------------------------------------------
function get_rows
( p_QBE  in number default 0
, p_other_condition in varchar2 default null
, p_order_by in varchar2 default null
, p_extra_columns in varchar2 default null
, p_extra_condition in varchar2 default null
, p_ni  in varchar2 default null
, p_id_immagine  in varchar2 default null
) return AFC.t_ref_cursor is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_rows
 DESCRIZIONE: Ritorna il risultato di una query in base ai valori che passiamo.
 PARAMETRI:   p_QBE 0: se l'operatore da utilizzare nella where-condition è
quello di default ('=')
                    1: se l'operatore da utilizzare nella where-condition è
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
   d_statement := ' select ANAGRAFE_IMMAGINI.* '
               || afc.decode_value( p_extra_columns, null, null, ' , ' || p_extra_columns )
               || ' from ANAGRAFE_IMMAGINI '
               || where_condition(
                                   p_QBE => p_QBE
                                 , p_other_condition => p_other_condition
                                 , p_ni => p_ni
                                 , p_id_immagine => p_id_immagine
                                 )
               || ' ' || p_extra_condition
               || afc.decode_value( p_order_by, null, null, ' order by ' || p_order_by )
               ;
   d_ref_cursor := AFC_DML.get_ref_cursor( d_statement );
   return d_ref_cursor;
end get_rows; -- anagrafe_immagini_tpk.get_rows
--------------------------------------------------------------------------------
function count_rows
( p_QBE  in number default 0
, p_other_condition in varchar2 default null
, p_ni  in varchar2 default null
, p_id_immagine  in varchar2 default null
) return integer is /* SLAVE_COPY */
/******************************************************************************
 NOME:        count_rows
 DESCRIZIONE: Ritorna il numero di righe della tabella gli attributi delle quali
              rispettano i valori indicati.
 PARAMETRI:   p_other_condition
              p_QBE 0: se l'operatore da utilizzare nella where-condition è
quello di default ('=')
                    1: se l'operatore da utilizzare nella where-condition è
quello specificato per ogni attributo.
              Chiavi e attributi della table
 RITORNA:     Numero di righe che rispettano la selezione indicata.
******************************************************************************/
   d_result          integer;
   d_statement       AFC.t_statement;
begin
   d_statement := ' select count( * ) from ANAGRAFE_IMMAGINI '
               || where_condition(
                                   p_QBE => p_QBE
                                 , p_other_condition => p_other_condition
                                 , p_ni => p_ni
                                 , p_id_immagine => p_id_immagine
                                 );
   d_result := AFC.SQL_execute( d_statement );
   return d_result;
end count_rows; -- anagrafe_immagini_tpk.count_rows
--------------------------------------------------------------------------------
end anagrafe_immagini_tpk;
/

