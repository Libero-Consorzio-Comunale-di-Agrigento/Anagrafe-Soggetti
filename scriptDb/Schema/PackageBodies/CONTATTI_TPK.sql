CREATE OR REPLACE package body contatti_tpk is
/******************************************************************************
 NOME:        contatti_tpk
 DESCRIZIONE: Gestione tabella CONTATTI.
 ANNOTAZIONI: .
 REVISIONI:   .
 Rev.  Data        Autore      Descrizione.
 000   16/05/2017  snegroni  Generazione automatica. 
 001   16/05/2017  snegroni  Generazione automatica. 
 002   16/05/2017  snegroni  Generazione automatica. 
 003   26/07/2017  snegroni  Generazione automatica. 
******************************************************************************/
   s_revisione_body      constant AFC.t_revision := '003 - 26/07/2017';
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
end versione; -- contatti_tpk.versione
--------------------------------------------------------------------------------
function PK
(
 p_id_contatto  in CONTATTI.id_contatto%type
) return t_PK is /* SLAVE_COPY */
/******************************************************************************
 NOME:        PK
 DESCRIZIONE: Costruttore di un t_PK dati gli attributi della chiave
******************************************************************************/
   d_result t_PK;   
begin
   d_result.id_contatto := p_id_contatto;
   DbC.PRE ( not DbC.PreOn or canHandle (
                                          p_id_contatto => d_result.id_contatto
                                        )
           , 'canHandle on contatti_tpk.PK' 
           );
   return  d_result;
end PK; -- contatti_tpk.PK
--------------------------------------------------------------------------------
function can_handle
(
 p_id_contatto  in CONTATTI.id_contatto%type
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
          p_id_contatto is null
       )
   then
      d_result := 0;
   end if;
   DbC.POST ( d_result = 1  or  d_result = 0
            , 'd_result = 1  or  d_result = 0 on contatti_tpk.can_handle'
            );
   return  d_result;   
end can_handle; -- contatti_tpk.can_handle
--------------------------------------------------------------------------------
function canHandle
(
 p_id_contatto  in CONTATTI.id_contatto%type
) return boolean is /* SLAVE_COPY */
/******************************************************************************
 NOME:        canHandle
 DESCRIZIONE: La chiave specificata rispetta tutti i requisiti sugli attributi componenti.
 PARAMETRI:   Attributi chiave.
 RITORNA:     number: true se la chiave e manipolabile, false altrimenti.
 NOTE:        Wrapper boolean di can_handle (cfr. can_handle).
******************************************************************************/
   d_result constant boolean := AFC.to_boolean ( can_handle (
                                                              p_id_contatto => p_id_contatto
                                                            ) 
                                               );
begin
   return  d_result;
end canHandle; -- contatti_tpk.canHandle
--------------------------------------------------------------------------------
function exists_id
( 
 p_id_contatto  in CONTATTI.id_contatto%type
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
                                         p_id_contatto => p_id_contatto
                                        )
           , 'canHandle on contatti_tpk.exists_id' 
           );
   begin
      select 1
      into   d_result
      from   CONTATTI
      where  
      id_contatto = p_id_contatto
      ;
   exception
      when no_data_found then
         d_result := 0;
   end;
   DbC.POST ( d_result = 1  or  d_result = 0
            , 'd_result = 1  or  d_result = 0 on contatti_tpk.exists_id'
            );
   return  d_result;   
end exists_id; -- contatti_tpk.exists_id
--------------------------------------------------------------------------------
function existsId
( 
 p_id_contatto  in CONTATTI.id_contatto%type
) return boolean is /* SLAVE_COPY */
/******************************************************************************
 NOME:        existsId
 DESCRIZIONE: Esistenza riga con chiave indicata.
 NOTE:        Wrapper boolean di exists_id (cfr. exists_id).
******************************************************************************/
   d_result constant boolean := AFC.to_boolean ( exists_id (
                                                            p_id_contatto => p_id_contatto
                                                           ) 
                                               );
begin
   return  d_result;
end existsId; -- contatti_tpk.existsId
--------------------------------------------------------------------------------
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
) is
/******************************************************************************
 NOME:        ins
 DESCRIZIONE: Inserimento di una riga con chiave e attributi indicati.
 PARAMETRI:   Chiavi e attributi della table.
******************************************************************************/
begin
   -- Check Mandatory on Insert
   DbC.PRE ( not DbC.PreOn or p_id_recapito is not null or /*default value*/ '' is not null
           , 'p_id_recapito on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_dal is not null or /*default value*/ '' is not null
           , 'p_dal on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_al is not null or /*default value*/ 'default' is not null
           , 'p_al on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_valore is not null or /*default value*/ '' is not null
           , 'p_valore on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_id_tipo_contatto is not null or /*default value*/ '' is not null
           , 'p_id_tipo_contatto on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_note is not null or /*default value*/ 'default' is not null
           , 'p_note on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_importanza is not null or /*default value*/ 'default' is not null
           , 'p_importanza on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_competenza is not null or /*default value*/ 'default' is not null
           , 'p_competenza on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_competenza_esclusiva is not null or /*default value*/ 'default' is not null
           , 'p_competenza_esclusiva on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_version is not null or /*default value*/ 'default' is not null
           , 'p_version on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_utente_aggiornamento is not null or /*default value*/ 'default' is not null
           , 'p_utente_aggiornamento on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_data_aggiornamento is not null or /*default value*/ 'default' is not null
           , 'p_data_aggiornamento on contatti_tpk.ins'
           );
   DbC.PRE (  not DbC.PreOn
           or (   p_id_contatto is null and /*default value*/ 'default null' is not null ) -- PK nullable on insert
           or not existsId (
                             p_id_contatto => p_id_contatto
                           )
           , 'not existsId on contatti_tpk.ins'
           );
   insert into CONTATTI
   (
     id_contatto
   , id_recapito
   , dal
   , al
   , valore
   , id_tipo_contatto
   , note
   , importanza
   , competenza
   , competenza_esclusiva
   , version
   , utente_aggiornamento
   , data_aggiornamento
   )
   values
   (
     p_id_contatto
, p_id_recapito
, p_dal
, p_al
, p_valore
, p_id_tipo_contatto
, p_note
, p_importanza
, p_competenza
, p_competenza_esclusiva
, p_version
, p_utente_aggiornamento
, p_data_aggiornamento
   );
end ins; -- contatti_tpk.ins
--------------------------------------------------------------------------------
function ins
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
   
   DbC.PRE ( not DbC.PreOn or p_id_recapito is not null or /*default value*/ '' is not null
           , 'p_id_recapito on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_dal is not null or /*default value*/ '' is not null
           , 'p_dal on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_al is not null or /*default value*/ 'default' is not null
           , 'p_al on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_valore is not null or /*default value*/ '' is not null
           , 'p_valore on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_id_tipo_contatto is not null or /*default value*/ '' is not null
           , 'p_id_tipo_contatto on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_note is not null or /*default value*/ 'default' is not null
           , 'p_note on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_importanza is not null or /*default value*/ 'default' is not null
           , 'p_importanza on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_competenza is not null or /*default value*/ 'default' is not null
           , 'p_competenza on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_competenza_esclusiva is not null or /*default value*/ 'default' is not null
           , 'p_competenza_esclusiva on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_version is not null or /*default value*/ 'default' is not null
           , 'p_version on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_utente_aggiornamento is not null or /*default value*/ 'default' is not null
           , 'p_utente_aggiornamento on contatti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_data_aggiornamento is not null or /*default value*/ 'default' is not null
           , 'p_data_aggiornamento on contatti_tpk.ins'
           );
   DbC.PRE (  not DbC.PreOn
           or (   p_id_contatto is null and /*default value*/ 'default null' is not null ) -- PK nullable on insert
           or not existsId (
                             p_id_contatto => p_id_contatto
                           )
           , 'not existsId on contatti_tpk.ins'
           );
   insert into CONTATTI
   (
     id_contatto
   , id_recapito
   , dal
   , al
   , valore
   , id_tipo_contatto
   , note
   , importanza
   , competenza
   , competenza_esclusiva
   , version
   , utente_aggiornamento
   , data_aggiornamento
   )
   values
   (
     p_id_contatto
, p_id_recapito
, p_dal
, p_al
, p_valore
, p_id_tipo_contatto
, p_note
, p_importanza
, p_competenza
, p_competenza_esclusiva
, p_version
, p_utente_aggiornamento
, p_data_aggiornamento
   ) returning id_contatto
   into d_result;
   return d_result;
end ins; -- contatti_tpk.ins
--------------------------------------------------------------------------------
procedure upd
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
p_OLD_id_recapito is not null
 or p_OLD_dal is not null
 or p_OLD_al is not null
 or p_OLD_valore is not null
 or p_OLD_id_tipo_contatto is not null
 or p_OLD_note is not null
 or p_OLD_importanza is not null
 or p_OLD_competenza is not null
 or p_OLD_competenza_esclusiva is not null
 or p_OLD_version is not null
 or p_OLD_utente_aggiornamento is not null
 or p_OLD_data_aggiornamento is not null
                    )
                    and (  nvl( p_check_OLD, -1 ) = 0
                        )
                  )
           , ' "OLD values" is not null on contatti_tpk.upd'
           );
   d_key := PK ( 
                nvl( p_OLD_id_contatto, p_NEW_id_contatto )
               );
   DbC.PRE ( not DbC.PreOn or existsId ( 
                                         p_id_contatto => d_key.id_contatto
                                       )
           , 'existsId on contatti_tpk.upd' 
           );
   update CONTATTI
   set 
       id_contatto = NVL( p_NEW_id_contatto, DECODE( AFC.IS_DEFAULT_NULL( 'CONTATTI.id_contatto' ), 1, id_contatto,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_id_contatto, null, id_contatto, null ) ) ) )
     , id_recapito = NVL( p_NEW_id_recapito, DECODE( AFC.IS_DEFAULT_NULL( 'CONTATTI.id_recapito' ), 1, id_recapito,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_id_recapito, null, id_recapito, null ) ) ) )
     , dal = NVL( p_NEW_dal, DECODE( AFC.IS_DEFAULT_NULL( 'CONTATTI.dal' ), 1, dal,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_dal, null, dal, null ) ) ) )
     , al = NVL( p_NEW_al, DECODE( AFC.IS_DEFAULT_NULL( 'CONTATTI.al' ), 1, al,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_al, null, al, null ) ) ) )
     , valore = NVL( p_NEW_valore, DECODE( AFC.IS_DEFAULT_NULL( 'CONTATTI.valore' ), 1, valore,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_valore, null, valore, null ) ) ) )
     , id_tipo_contatto = NVL( p_NEW_id_tipo_contatto, DECODE( AFC.IS_DEFAULT_NULL( 'CONTATTI.id_tipo_contatto' ), 1, id_tipo_contatto,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_id_tipo_contatto, null, id_tipo_contatto, null ) ) ) )
     , note = NVL( p_NEW_note, DECODE( AFC.IS_DEFAULT_NULL( 'CONTATTI.note' ), 1, note,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_note, null, note, null ) ) ) )
     , importanza = NVL( p_NEW_importanza, DECODE( AFC.IS_DEFAULT_NULL( 'CONTATTI.importanza' ), 1, importanza,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_importanza, null, importanza, null ) ) ) )
     , competenza = NVL( p_NEW_competenza, DECODE( AFC.IS_DEFAULT_NULL( 'CONTATTI.competenza' ), 1, competenza,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_competenza, null, competenza, null ) ) ) )
     , competenza_esclusiva = NVL( p_NEW_competenza_esclusiva, DECODE( AFC.IS_DEFAULT_NULL( 'CONTATTI.competenza_esclusiva' ), 1, competenza_esclusiva,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_competenza_esclusiva, null, competenza_esclusiva, null ) ) ) )
     , version = NVL( p_NEW_version, DECODE( AFC.IS_DEFAULT_NULL( 'CONTATTI.version' ), 1, version,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_version, null, version, null ) ) ) )
     , utente_aggiornamento = NVL( p_NEW_utente_aggiornamento, DECODE( AFC.IS_DEFAULT_NULL( 'CONTATTI.utente_aggiornamento' ), 1, utente_aggiornamento,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_utente_aggiornamento, null, utente_aggiornamento, null ) ) ) )
     , data_aggiornamento = NVL( p_NEW_data_aggiornamento, DECODE( AFC.IS_DEFAULT_NULL( 'CONTATTI.data_aggiornamento' ), 1, data_aggiornamento,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_data_aggiornamento, null, data_aggiornamento, null ) ) ) )
   where 
     id_contatto = d_key.id_contatto
   and (   p_check_OLD = 0
        or (   1 = 1
           and ( id_recapito = p_OLD_id_recapito or ( p_OLD_id_recapito is null and ( p_check_OLD is null or id_recapito is null ) ) )
           and ( dal = p_OLD_dal or ( p_OLD_dal is null and ( p_check_OLD is null or dal is null ) ) )
           and ( al = p_OLD_al or ( p_OLD_al is null and ( p_check_OLD is null or al is null ) ) )
           and ( valore = p_OLD_valore or ( p_OLD_valore is null and ( p_check_OLD is null or valore is null ) ) )
           and ( id_tipo_contatto = p_OLD_id_tipo_contatto or ( p_OLD_id_tipo_contatto is null and ( p_check_OLD is null or id_tipo_contatto is null ) ) )
           and ( note = p_OLD_note or ( p_OLD_note is null and ( p_check_OLD is null or note is null ) ) )
           and ( importanza = p_OLD_importanza or ( p_OLD_importanza is null and ( p_check_OLD is null or importanza is null ) ) )
           and ( competenza = p_OLD_competenza or ( p_OLD_competenza is null and ( p_check_OLD is null or competenza is null ) ) )
           and ( competenza_esclusiva = p_OLD_competenza_esclusiva or ( p_OLD_competenza_esclusiva is null and ( p_check_OLD is null or competenza_esclusiva is null ) ) )
           and ( version = p_OLD_version or ( p_OLD_version is null and ( p_check_OLD is null or version is null ) ) )
           and ( utente_aggiornamento = p_OLD_utente_aggiornamento or ( p_OLD_utente_aggiornamento is null and ( p_check_OLD is null or utente_aggiornamento is null ) ) )
           and ( data_aggiornamento = p_OLD_data_aggiornamento or ( p_OLD_data_aggiornamento is null and ( p_check_OLD is null or data_aggiornamento is null ) ) )
           )
       )
   ;
   d_row_found := SQL%ROWCOUNT;
   afc.default_null(NULL);
   DbC.ASSERTION ( not DbC.AssertionOn or d_row_found <= 1
                 , 'd_row_found <= 1 on contatti_tpk.upd'
                 );
   if d_row_found < 1
   then
      raise_application_error ( AFC_ERROR.modified_by_other_user_number
                              , AFC_ERROR.modified_by_other_user_msg
                              );
   end if;
end upd; -- contatti_tpk.upd
--------------------------------------------------------------------------------
procedure upd_column
( 
  p_id_contatto  in CONTATTI.id_contatto%type
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
                                        p_id_contatto => p_id_contatto
                                       )
           , 'existsId on contatti_tpk.upd_column' 
           );
   DbC.PRE ( not DbC.PreOn or p_column is not null
           , 'p_column is not null on contatti_tpk.upd_column'
           );
   DbC.PRE ( not DbC.PreOn or AFC_DDL.HasAttribute( s_table_name, p_column )
           , 'AFC_DDL.HasAttribute on contatti_tpk.upd_column'
           );
   DbC.PRE ( p_literal_value in ( 0, 1 ) or p_literal_value is null
           , 'p_literal_value on contatti_tpk.upd_column; p_literal_value = ' || p_literal_value
           );
   if p_literal_value = 1
   or p_literal_value is null
   then
      d_literal := '''';
   end if;
   d_statement := ' declare '
               || '    d_row_found number; '
               || ' begin '
               || '    update CONTATTI '
               || '       set ' || p_column || ' = ' || d_literal || p_value || d_literal
               || '     where 1 = 1 '
               || nvl( AFC.get_field_condition( ' and ( id_contatto ', p_id_contatto, ' )', 0, null ), ' and ( id_contatto is null ) ' )
               || '    ; '
               || '    d_row_found := SQL%ROWCOUNT; '
               || '    if d_row_found < 1 '
               || '    then '
               || '       raise_application_error ( AFC_ERROR.modified_by_other_user_number, AFC_ERROR.modified_by_other_user_msg ); '
               || '    end if; '
               || ' end; ';
   AFC.SQL_execute( d_statement );
end upd_column; -- contatti_tpk.upd_column
--------------------------------------------------------------------------------
procedure upd_column
( 
p_id_contatto  in CONTATTI.id_contatto%type
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
p_id_contatto => p_id_contatto
              , p_column => p_column
              , p_value => 'to_date( ''' || d_data || ''', ''' || AFC.date_format || ''' )'
              , p_literal_value => 0
              );   
end upd_column; -- contatti_tpk.upd_column
--------------------------------------------------------------------------------
procedure del
( 
  p_check_old  in integer default 0
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
p_id_recapito is not null
 or p_dal is not null
 or p_al is not null
 or p_valore is not null
 or p_id_tipo_contatto is not null
 or p_note is not null
 or p_importanza is not null
 or p_competenza is not null
 or p_competenza_esclusiva is not null
 or p_version is not null
 or p_utente_aggiornamento is not null
 or p_data_aggiornamento is not null
                    )
                    and (  nvl( p_check_OLD, -1 ) = 0
                        )
                  )
           , ' "OLD values" is not null on contatti_tpk.del'
           );
   DbC.PRE ( not DbC.PreOn or existsId (
                                         p_id_contatto => p_id_contatto
                                       )
           , 'existsId on contatti_tpk.del' 
           );
   delete from CONTATTI
   where 
     id_contatto = p_id_contatto
   and (   p_check_OLD = 0
        or (   1 = 1
           and ( id_recapito = p_id_recapito or ( p_id_recapito is null and ( p_check_OLD is null or id_recapito is null ) ) )
           and ( dal = p_dal or ( p_dal is null and ( p_check_OLD is null or dal is null ) ) )
           and ( al = p_al or ( p_al is null and ( p_check_OLD is null or al is null ) ) )
           and ( valore = p_valore or ( p_valore is null and ( p_check_OLD is null or valore is null ) ) )
           and ( id_tipo_contatto = p_id_tipo_contatto or ( p_id_tipo_contatto is null and ( p_check_OLD is null or id_tipo_contatto is null ) ) )
           and ( note = p_note or ( p_note is null and ( p_check_OLD is null or note is null ) ) )
           and ( importanza = p_importanza or ( p_importanza is null and ( p_check_OLD is null or importanza is null ) ) )
           and ( competenza = p_competenza or ( p_competenza is null and ( p_check_OLD is null or competenza is null ) ) )
           and ( competenza_esclusiva = p_competenza_esclusiva or ( p_competenza_esclusiva is null and ( p_check_OLD is null or competenza_esclusiva is null ) ) )
           and ( version = p_version or ( p_version is null and ( p_check_OLD is null or version is null ) ) )
           and ( utente_aggiornamento = p_utente_aggiornamento or ( p_utente_aggiornamento is null and ( p_check_OLD is null or utente_aggiornamento is null ) ) )
           and ( data_aggiornamento = p_data_aggiornamento or ( p_data_aggiornamento is null and ( p_check_OLD is null or data_aggiornamento is null ) ) )
           )
       )
   ;
   d_row_found := SQL%ROWCOUNT;
   DbC.ASSERTION ( not DbC.AssertionOn or d_row_found <= 1
                 , 'd_row_found <= 1 on contatti_tpk.del'
                 );
   if d_row_found < 1
   then
      raise_application_error ( AFC_ERROR.modified_by_other_user_number
                              , AFC_ERROR.modified_by_other_user_msg
                              );
   end if;
   DbC.POST ( not DbC.PostOn or not existsId ( 
                                               p_id_contatto => p_id_contatto
                                             )
            , 'existsId on contatti_tpk.del' 
            );
end del; -- contatti_tpk.del
--------------------------------------------------------------------------------
function get_id_recapito
( 
  p_id_contatto  in CONTATTI.id_contatto%type
) return CONTATTI.id_recapito%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_id_recapito
 DESCRIZIONE: Getter per attributo id_recapito di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     CONTATTI.id_recapito%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result CONTATTI.id_recapito%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.get_id_recapito' 
           );
   select id_recapito
   into   d_result
   from   CONTATTI
   where  
   id_contatto = p_id_contatto
   ;
  -- Check Mandatory Attribute on Table
  if (true)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on contatti_tpk.get_id_recapito'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'id_recapito')
                    , ' AFC_DDL.IsNullable on contatti_tpk.get_id_recapito'
                    );
   end if;
   return  d_result;
end get_id_recapito; -- contatti_tpk.get_id_recapito
--------------------------------------------------------------------------------
function get_dal
( 
  p_id_contatto  in CONTATTI.id_contatto%type
) return CONTATTI.dal%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_dal
 DESCRIZIONE: Getter per attributo dal di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     CONTATTI.dal%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result CONTATTI.dal%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.get_dal' 
           );
   select dal
   into   d_result
   from   CONTATTI
   where  
   id_contatto = p_id_contatto
   ;
  -- Check Mandatory Attribute on Table
  if (true)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on contatti_tpk.get_dal'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'dal')
                    , ' AFC_DDL.IsNullable on contatti_tpk.get_dal'
                    );
   end if;
   return  d_result;
end get_dal; -- contatti_tpk.get_dal
--------------------------------------------------------------------------------
function get_al
( 
  p_id_contatto  in CONTATTI.id_contatto%type
) return CONTATTI.al%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_al
 DESCRIZIONE: Getter per attributo al di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     CONTATTI.al%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result CONTATTI.al%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.get_al' 
           );
   select al
   into   d_result
   from   CONTATTI
   where  
   id_contatto = p_id_contatto
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on contatti_tpk.get_al'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'al')
                    , ' AFC_DDL.IsNullable on contatti_tpk.get_al'
                    );
   end if;
   return  d_result;
end get_al; -- contatti_tpk.get_al
--------------------------------------------------------------------------------
function get_valore
( 
  p_id_contatto  in CONTATTI.id_contatto%type
) return CONTATTI.valore%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_valore
 DESCRIZIONE: Getter per attributo valore di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     CONTATTI.valore%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result CONTATTI.valore%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.get_valore' 
           );
   select valore
   into   d_result
   from   CONTATTI
   where  
   id_contatto = p_id_contatto
   ;
  -- Check Mandatory Attribute on Table
  if (true)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on contatti_tpk.get_valore'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'valore')
                    , ' AFC_DDL.IsNullable on contatti_tpk.get_valore'
                    );
   end if;
   return  d_result;
end get_valore; -- contatti_tpk.get_valore
--------------------------------------------------------------------------------
function get_id_tipo_contatto
( 
  p_id_contatto  in CONTATTI.id_contatto%type
) return CONTATTI.id_tipo_contatto%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_id_tipo_contatto
 DESCRIZIONE: Getter per attributo id_tipo_contatto di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     CONTATTI.id_tipo_contatto%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result CONTATTI.id_tipo_contatto%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.get_id_tipo_contatto' 
           );
   select id_tipo_contatto
   into   d_result
   from   CONTATTI
   where  
   id_contatto = p_id_contatto
   ;
  -- Check Mandatory Attribute on Table
  if (true)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on contatti_tpk.get_id_tipo_contatto'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'id_tipo_contatto')
                    , ' AFC_DDL.IsNullable on contatti_tpk.get_id_tipo_contatto'
                    );
   end if;
   return  d_result;
end get_id_tipo_contatto; -- contatti_tpk.get_id_tipo_contatto
--------------------------------------------------------------------------------
function get_note
( 
  p_id_contatto  in CONTATTI.id_contatto%type
) return CONTATTI.note%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_note
 DESCRIZIONE: Getter per attributo note di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     CONTATTI.note%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result CONTATTI.note%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.get_note' 
           );
   select note
   into   d_result
   from   CONTATTI
   where  
   id_contatto = p_id_contatto
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on contatti_tpk.get_note'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'note')
                    , ' AFC_DDL.IsNullable on contatti_tpk.get_note'
                    );
   end if;
   return  d_result;
end get_note; -- contatti_tpk.get_note
--------------------------------------------------------------------------------
function get_importanza
( 
  p_id_contatto  in CONTATTI.id_contatto%type
) return CONTATTI.importanza%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_importanza
 DESCRIZIONE: Getter per attributo importanza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     CONTATTI.importanza%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result CONTATTI.importanza%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.get_importanza' 
           );
   select importanza
   into   d_result
   from   CONTATTI
   where  
   id_contatto = p_id_contatto
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on contatti_tpk.get_importanza'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'importanza')
                    , ' AFC_DDL.IsNullable on contatti_tpk.get_importanza'
                    );
   end if;
   return  d_result;
end get_importanza; -- contatti_tpk.get_importanza
--------------------------------------------------------------------------------
function get_competenza
( 
  p_id_contatto  in CONTATTI.id_contatto%type
) return CONTATTI.competenza%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_competenza
 DESCRIZIONE: Getter per attributo competenza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     CONTATTI.competenza%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result CONTATTI.competenza%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.get_competenza' 
           );
   select competenza
   into   d_result
   from   CONTATTI
   where  
   id_contatto = p_id_contatto
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on contatti_tpk.get_competenza'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'competenza')
                    , ' AFC_DDL.IsNullable on contatti_tpk.get_competenza'
                    );
   end if;
   return  d_result;
end get_competenza; -- contatti_tpk.get_competenza
--------------------------------------------------------------------------------
function get_competenza_esclusiva
( 
  p_id_contatto  in CONTATTI.id_contatto%type
) return CONTATTI.competenza_esclusiva%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_competenza_esclusiva
 DESCRIZIONE: Getter per attributo competenza_esclusiva di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     CONTATTI.competenza_esclusiva%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result CONTATTI.competenza_esclusiva%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.get_competenza_esclusiva' 
           );
   select competenza_esclusiva
   into   d_result
   from   CONTATTI
   where  
   id_contatto = p_id_contatto
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on contatti_tpk.get_competenza_esclusiva'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'competenza_esclusiva')
                    , ' AFC_DDL.IsNullable on contatti_tpk.get_competenza_esclusiva'
                    );
   end if;
   return  d_result;
end get_competenza_esclusiva; -- contatti_tpk.get_competenza_esclusiva
--------------------------------------------------------------------------------
function get_version
( 
  p_id_contatto  in CONTATTI.id_contatto%type
) return CONTATTI.version%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_version
 DESCRIZIONE: Getter per attributo version di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     CONTATTI.version%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result CONTATTI.version%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.get_version' 
           );
   select version
   into   d_result
   from   CONTATTI
   where  
   id_contatto = p_id_contatto
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on contatti_tpk.get_version'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'version')
                    , ' AFC_DDL.IsNullable on contatti_tpk.get_version'
                    );
   end if;
   return  d_result;
end get_version; -- contatti_tpk.get_version
--------------------------------------------------------------------------------
function get_utente_aggiornamento
( 
  p_id_contatto  in CONTATTI.id_contatto%type
) return CONTATTI.utente_aggiornamento%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_utente_aggiornamento
 DESCRIZIONE: Getter per attributo utente_aggiornamento di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     CONTATTI.utente_aggiornamento%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result CONTATTI.utente_aggiornamento%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.get_utente_aggiornamento' 
           );
   select utente_aggiornamento
   into   d_result
   from   CONTATTI
   where  
   id_contatto = p_id_contatto
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on contatti_tpk.get_utente_aggiornamento'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'utente_aggiornamento')
                    , ' AFC_DDL.IsNullable on contatti_tpk.get_utente_aggiornamento'
                    );
   end if;
   return  d_result;
end get_utente_aggiornamento; -- contatti_tpk.get_utente_aggiornamento
--------------------------------------------------------------------------------
function get_data_aggiornamento
( 
  p_id_contatto  in CONTATTI.id_contatto%type
) return CONTATTI.data_aggiornamento%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_data_aggiornamento
 DESCRIZIONE: Getter per attributo data_aggiornamento di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     CONTATTI.data_aggiornamento%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result CONTATTI.data_aggiornamento%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.get_data_aggiornamento' 
           );
   select data_aggiornamento
   into   d_result
   from   CONTATTI
   where  
   id_contatto = p_id_contatto
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on contatti_tpk.get_data_aggiornamento'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'data_aggiornamento')
                    , ' AFC_DDL.IsNullable on contatti_tpk.get_data_aggiornamento'
                    );
   end if;
   return  d_result;
end get_data_aggiornamento; -- contatti_tpk.get_data_aggiornamento
--------------------------------------------------------------------------------
procedure set_id_contatto
( 
  p_id_contatto  in CONTATTI.id_contatto%type
, p_value  in CONTATTI.id_contatto%type default null
) is
/******************************************************************************
 NOME:        set_id_contatto
 DESCRIZIONE: Setter per attributo id_contatto di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.set_id_contatto' 
           );
   update CONTATTI
   set id_contatto = p_value
   where
   id_contatto = p_id_contatto
   ;
end set_id_contatto; -- contatti_tpk.set_id_contatto
--------------------------------------------------------------------------------
procedure set_id_recapito
( 
  p_id_contatto  in CONTATTI.id_contatto%type
, p_value  in CONTATTI.id_recapito%type default null
) is
/******************************************************************************
 NOME:        set_id_recapito
 DESCRIZIONE: Setter per attributo id_recapito di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.set_id_recapito' 
           );
   update CONTATTI
   set id_recapito = p_value
   where
   id_contatto = p_id_contatto
   ;
end set_id_recapito; -- contatti_tpk.set_id_recapito
--------------------------------------------------------------------------------
procedure set_dal
( 
  p_id_contatto  in CONTATTI.id_contatto%type
, p_value  in CONTATTI.dal%type default null
) is
/******************************************************************************
 NOME:        set_dal
 DESCRIZIONE: Setter per attributo dal di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.set_dal' 
           );
   update CONTATTI
   set dal = p_value
   where
   id_contatto = p_id_contatto
   ;
end set_dal; -- contatti_tpk.set_dal
--------------------------------------------------------------------------------
procedure set_al
( 
  p_id_contatto  in CONTATTI.id_contatto%type
, p_value  in CONTATTI.al%type default null
) is
/******************************************************************************
 NOME:        set_al
 DESCRIZIONE: Setter per attributo al di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.set_al' 
           );
   update CONTATTI
   set al = p_value
   where
   id_contatto = p_id_contatto
   ;
end set_al; -- contatti_tpk.set_al
--------------------------------------------------------------------------------
procedure set_valore
( 
  p_id_contatto  in CONTATTI.id_contatto%type
, p_value  in CONTATTI.valore%type default null
) is
/******************************************************************************
 NOME:        set_valore
 DESCRIZIONE: Setter per attributo valore di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.set_valore' 
           );
   update CONTATTI
   set valore = p_value
   where
   id_contatto = p_id_contatto
   ;
end set_valore; -- contatti_tpk.set_valore
--------------------------------------------------------------------------------
procedure set_id_tipo_contatto
( 
  p_id_contatto  in CONTATTI.id_contatto%type
, p_value  in CONTATTI.id_tipo_contatto%type default null
) is
/******************************************************************************
 NOME:        set_id_tipo_contatto
 DESCRIZIONE: Setter per attributo id_tipo_contatto di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.set_id_tipo_contatto' 
           );
   update CONTATTI
   set id_tipo_contatto = p_value
   where
   id_contatto = p_id_contatto
   ;
end set_id_tipo_contatto; -- contatti_tpk.set_id_tipo_contatto
--------------------------------------------------------------------------------
procedure set_note
( 
  p_id_contatto  in CONTATTI.id_contatto%type
, p_value  in CONTATTI.note%type default null
) is
/******************************************************************************
 NOME:        set_note
 DESCRIZIONE: Setter per attributo note di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.set_note' 
           );
   update CONTATTI
   set note = p_value
   where
   id_contatto = p_id_contatto
   ;
end set_note; -- contatti_tpk.set_note
--------------------------------------------------------------------------------
procedure set_importanza
( 
  p_id_contatto  in CONTATTI.id_contatto%type
, p_value  in CONTATTI.importanza%type default null
) is
/******************************************************************************
 NOME:        set_importanza
 DESCRIZIONE: Setter per attributo importanza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.set_importanza' 
           );
   update CONTATTI
   set importanza = p_value
   where
   id_contatto = p_id_contatto
   ;
end set_importanza; -- contatti_tpk.set_importanza
--------------------------------------------------------------------------------
procedure set_competenza
( 
  p_id_contatto  in CONTATTI.id_contatto%type
, p_value  in CONTATTI.competenza%type default null
) is
/******************************************************************************
 NOME:        set_competenza
 DESCRIZIONE: Setter per attributo competenza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.set_competenza' 
           );
   update CONTATTI
   set competenza = p_value
   where
   id_contatto = p_id_contatto
   ;
end set_competenza; -- contatti_tpk.set_competenza
--------------------------------------------------------------------------------
procedure set_competenza_esclusiva
( 
  p_id_contatto  in CONTATTI.id_contatto%type
, p_value  in CONTATTI.competenza_esclusiva%type default null
) is
/******************************************************************************
 NOME:        set_competenza_esclusiva
 DESCRIZIONE: Setter per attributo competenza_esclusiva di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.set_competenza_esclusiva' 
           );
   update CONTATTI
   set competenza_esclusiva = p_value
   where
   id_contatto = p_id_contatto
   ;
end set_competenza_esclusiva; -- contatti_tpk.set_competenza_esclusiva
--------------------------------------------------------------------------------
procedure set_version
( 
  p_id_contatto  in CONTATTI.id_contatto%type
, p_value  in CONTATTI.version%type default null
) is
/******************************************************************************
 NOME:        set_version
 DESCRIZIONE: Setter per attributo version di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.set_version' 
           );
   update CONTATTI
   set version = p_value
   where
   id_contatto = p_id_contatto
   ;
end set_version; -- contatti_tpk.set_version
--------------------------------------------------------------------------------
procedure set_utente_aggiornamento
( 
  p_id_contatto  in CONTATTI.id_contatto%type
, p_value  in CONTATTI.utente_aggiornamento%type default null
) is
/******************************************************************************
 NOME:        set_utente_aggiornamento
 DESCRIZIONE: Setter per attributo utente_aggiornamento di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.set_utente_aggiornamento' 
           );
   update CONTATTI
   set utente_aggiornamento = p_value
   where
   id_contatto = p_id_contatto
   ;
end set_utente_aggiornamento; -- contatti_tpk.set_utente_aggiornamento
--------------------------------------------------------------------------------
procedure set_data_aggiornamento
( 
  p_id_contatto  in CONTATTI.id_contatto%type
, p_value  in CONTATTI.data_aggiornamento%type default null
) is
/******************************************************************************
 NOME:        set_data_aggiornamento
 DESCRIZIONE: Setter per attributo data_aggiornamento di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_contatto => p_id_contatto
                                        )
           , 'existsId on contatti_tpk.set_data_aggiornamento' 
           );
   update CONTATTI
   set data_aggiornamento = p_value
   where
   id_contatto = p_id_contatto
   ;
end set_data_aggiornamento; -- contatti_tpk.set_data_aggiornamento
--------------------------------------------------------------------------------
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
               || AFC.get_field_condition( ' and ( id_contatto ', p_id_contatto, ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( id_recapito ', p_id_recapito , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( dal ', p_dal , ' )', p_QBE, AFC.date_format )
               || AFC.get_field_condition( ' and ( al ', p_al , ' )', p_QBE, AFC.date_format )
               || AFC.get_field_condition( ' and ( valore ', p_valore , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( id_tipo_contatto ', p_id_tipo_contatto , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( note ', p_note , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( importanza ', p_importanza , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( competenza ', p_competenza , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( competenza_esclusiva ', p_competenza_esclusiva , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( version ', p_version , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( utente_aggiornamento ', p_utente_aggiornamento , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( data_aggiornamento ', p_data_aggiornamento , ' )', p_QBE, AFC.date_format )
               || ' ) ' || p_other_condition
               ;
   return d_statement;
end where_condition; --- contatti_tpk.where_condition
--------------------------------------------------------------------------------
function get_rows
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
   d_statement := ' select CONTATTI.* '
               || afc.decode_value( p_extra_columns, null, null, ' , ' || p_extra_columns )
               || ' from CONTATTI '
               || where_condition( 
                                   p_QBE => p_QBE
                                 , p_other_condition => p_other_condition
                                 , p_id_contatto => p_id_contatto
                                 , p_id_recapito => p_id_recapito
                                 , p_dal => p_dal
                                 , p_al => p_al
                                 , p_valore => p_valore
                                 , p_id_tipo_contatto => p_id_tipo_contatto
                                 , p_note => p_note
                                 , p_importanza => p_importanza
                                 , p_competenza => p_competenza
                                 , p_competenza_esclusiva => p_competenza_esclusiva
                                 , p_version => p_version
                                 , p_utente_aggiornamento => p_utente_aggiornamento
                                 , p_data_aggiornamento => p_data_aggiornamento
                                 )
               || ' ' || p_extra_condition
               || afc.decode_value( p_order_by, null, null, ' order by ' || p_order_by )
               ;
   d_ref_cursor := AFC_DML.get_ref_cursor( d_statement );
   return d_ref_cursor;
end get_rows; -- contatti_tpk.get_rows
--------------------------------------------------------------------------------
function count_rows
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
   d_statement := ' select count( * ) from CONTATTI '
               || where_condition( 
                                   p_QBE => p_QBE
                                 , p_other_condition => p_other_condition
                                 , p_id_contatto => p_id_contatto
                                 , p_id_recapito => p_id_recapito
                                 , p_dal => p_dal
                                 , p_al => p_al
                                 , p_valore => p_valore
                                 , p_id_tipo_contatto => p_id_tipo_contatto
                                 , p_note => p_note
                                 , p_importanza => p_importanza
                                 , p_competenza => p_competenza
                                 , p_competenza_esclusiva => p_competenza_esclusiva
                                 , p_version => p_version
                                 , p_utente_aggiornamento => p_utente_aggiornamento
                                 , p_data_aggiornamento => p_data_aggiornamento
                                 );
   d_result := AFC.SQL_execute( d_statement );
   return d_result;
end count_rows; -- contatti_tpk.count_rows
--------------------------------------------------------------------------------
         
end contatti_tpk;
/

