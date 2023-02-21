CREATE OR REPLACE PACKAGE BODY recapiti_tpk is
/******************************************************************************
 NOME:        recapiti_tpk
 DESCRIZIONE: Gestione tabella RECAPITI.
 ANNOTAZIONI: .
 REVISIONI:   .
 Rev.  Data        Autore      Descrizione.
 000   16/05/2017  snegroni  Generazione automatica. 
 001   16/05/2017  snegroni  Generazione automatica. 
 002   26/07/2017  snegroni  Generazione automatica. 
 003   30/10/2017  snegroni  Generazione automatica. 
******************************************************************************/
   s_revisione_body      constant AFC.t_revision := '003 - 30/10/2017';
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
end versione; -- recapiti_tpk.versione
--------------------------------------------------------------------------------
function PK
(
 p_id_recapito  in RECAPITI.id_recapito%type
) return t_PK is /* SLAVE_COPY */
/******************************************************************************
 NOME:        PK
 DESCRIZIONE: Costruttore di un t_PK dati gli attributi della chiave
******************************************************************************/
   d_result t_PK;   
begin
   d_result.id_recapito := p_id_recapito;
   DbC.PRE ( not DbC.PreOn or canHandle (
                                          p_id_recapito => d_result.id_recapito
                                        )
           , 'canHandle on recapiti_tpk.PK' 
           );
   return  d_result;
end PK; -- recapiti_tpk.PK
--------------------------------------------------------------------------------
function can_handle
(
 p_id_recapito  in RECAPITI.id_recapito%type
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
          p_id_recapito is null
       )
   then
      d_result := 0;
   end if;
   DbC.POST ( d_result = 1  or  d_result = 0
            , 'd_result = 1  or  d_result = 0 on recapiti_tpk.can_handle'
            );
   return  d_result;   
end can_handle; -- recapiti_tpk.can_handle
--------------------------------------------------------------------------------
function canHandle
(
 p_id_recapito  in RECAPITI.id_recapito%type
) return boolean is /* SLAVE_COPY */
/******************************************************************************
 NOME:        canHandle
 DESCRIZIONE: La chiave specificata rispetta tutti i requisiti sugli attributi componenti.
 PARAMETRI:   Attributi chiave.
 RITORNA:     number: true se la chiave e manipolabile, false altrimenti.
 NOTE:        Wrapper boolean di can_handle (cfr. can_handle).
******************************************************************************/
   d_result constant boolean := AFC.to_boolean ( can_handle (
                                                              p_id_recapito => p_id_recapito
                                                            ) 
                                               );
begin
   return  d_result;
end canHandle; -- recapiti_tpk.canHandle
--------------------------------------------------------------------------------
function exists_id
( 
 p_id_recapito  in RECAPITI.id_recapito%type
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
                                         p_id_recapito => p_id_recapito
                                        )
           , 'canHandle on recapiti_tpk.exists_id' 
           );
   begin
      select 1
      into   d_result
      from   RECAPITI
      where  
      id_recapito = p_id_recapito
      ;
   exception
      when no_data_found then
         d_result := 0;
   end;
   DbC.POST ( d_result = 1  or  d_result = 0
            , 'd_result = 1  or  d_result = 0 on recapiti_tpk.exists_id'
            );
   return  d_result;   
end exists_id; -- recapiti_tpk.exists_id
--------------------------------------------------------------------------------
function existsId
( 
 p_id_recapito  in RECAPITI.id_recapito%type
) return boolean is /* SLAVE_COPY */
/******************************************************************************
 NOME:        existsId
 DESCRIZIONE: Esistenza riga con chiave indicata.
 NOTE:        Wrapper boolean di exists_id (cfr. exists_id).
******************************************************************************/
   d_result constant boolean := AFC.to_boolean ( exists_id (
                                                            p_id_recapito => p_id_recapito
                                                           ) 
                                               );
begin
   return  d_result;
end existsId; -- recapiti_tpk.existsId
--------------------------------------------------------------------------------
procedure ins
( 
  p_id_recapito  in RECAPITI.id_recapito%type default null
, p_ni  in RECAPITI.ni%type 
, p_dal  in RECAPITI.dal%type 
, p_al  in RECAPITI.al%type default null
, p_descrizione  in RECAPITI.descrizione%type default null
, p_id_tipo_recapito  in RECAPITI.id_tipo_recapito%type 
, p_indirizzo  in RECAPITI.indirizzo%type default null
, p_provincia  in RECAPITI.provincia%type default null
, p_comune  in RECAPITI.comune%type default null
, p_cap  in RECAPITI.cap%type default null
, p_presso  in RECAPITI.presso%type default null
, p_importanza  in RECAPITI.importanza%type default null
, p_competenza  in RECAPITI.competenza%type default null
, p_competenza_esclusiva  in RECAPITI.competenza_esclusiva%type default null
, p_version  in RECAPITI.version%type default 0
, p_utente_aggiornamento  in RECAPITI.utente_aggiornamento%type default null
, p_data_aggiornamento  in RECAPITI.data_aggiornamento%type default null
) is
/******************************************************************************
 NOME:        ins
 DESCRIZIONE: Inserimento di una riga con chiave e attributi indicati.
 PARAMETRI:   Chiavi e attributi della table.
******************************************************************************/
begin
   -- Check Mandatory on Insert
   
   DbC.PRE ( not DbC.PreOn or p_ni is not null or /*default value*/ '' is not null
           , 'p_ni on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_dal is not null or /*default value*/ '' is not null
           , 'p_dal on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_al is not null or /*default value*/ 'default' is not null
           , 'p_al on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_descrizione is not null or /*default value*/ 'default' is not null
           , 'p_descrizione on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_id_tipo_recapito is not null or /*default value*/ '' is not null
           , 'p_id_tipo_recapito on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_indirizzo is not null or /*default value*/ 'default' is not null
           , 'p_indirizzo on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_provincia is not null or /*default value*/ 'default' is not null
           , 'p_provincia on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_comune is not null or /*default value*/ 'default' is not null
           , 'p_comune on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_cap is not null or /*default value*/ 'default' is not null
           , 'p_cap on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_presso is not null or /*default value*/ 'default' is not null
           , 'p_presso on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_importanza is not null or /*default value*/ 'default' is not null
           , 'p_importanza on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_competenza is not null or /*default value*/ 'default' is not null
           , 'p_competenza on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_competenza_esclusiva is not null or /*default value*/ 'default' is not null
           , 'p_competenza_esclusiva on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_version is not null or /*default value*/ 'default' is not null
           , 'p_version on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_utente_aggiornamento is not null or /*default value*/ 'default' is not null
           , 'p_utente_aggiornamento on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_data_aggiornamento is not null or /*default value*/ 'default' is not null
           , 'p_data_aggiornamento on recapiti_tpk.ins'
           );
   DbC.PRE (  not DbC.PreOn
           or (   p_id_recapito is null and /*default value*/ 'default null' is not null ) -- PK nullable on insert
           or not existsId (
                             p_id_recapito => p_id_recapito
                           )
           , 'not existsId on recapiti_tpk.ins'
           );
   insert into RECAPITI
   (
     id_recapito
   , ni
   , dal
   , al
   , descrizione
   , id_tipo_recapito
   , indirizzo
   , provincia
   , comune
   , cap
   , presso
   , importanza
   , competenza
   , competenza_esclusiva
   , version
   , utente_aggiornamento
   , data_aggiornamento
   )
   values
   (
     p_id_recapito
, p_ni
, p_dal
, p_al
, p_descrizione
, p_id_tipo_recapito
, p_indirizzo
, p_provincia
, p_comune
, p_cap
, p_presso
, p_importanza
, p_competenza
, p_competenza_esclusiva
, p_version
, p_utente_aggiornamento
, p_data_aggiornamento
   );
end ins; -- recapiti_tpk.ins
--------------------------------------------------------------------------------
function ins
(
  p_id_recapito  in RECAPITI.id_recapito%type default null
, p_ni  in RECAPITI.ni%type 
, p_dal  in RECAPITI.dal%type 
, p_al  in RECAPITI.al%type default null
, p_descrizione  in RECAPITI.descrizione%type default null
, p_id_tipo_recapito  in RECAPITI.id_tipo_recapito%type 
, p_indirizzo  in RECAPITI.indirizzo%type default null
, p_provincia  in RECAPITI.provincia%type default null
, p_comune  in RECAPITI.comune%type default null
, p_cap  in RECAPITI.cap%type default null
, p_presso  in RECAPITI.presso%type default null
, p_importanza  in RECAPITI.importanza%type default null
, p_competenza  in RECAPITI.competenza%type default null
, p_competenza_esclusiva  in RECAPITI.competenza_esclusiva%type default null
, p_version  in RECAPITI.version%type default 0
, p_utente_aggiornamento  in RECAPITI.utente_aggiornamento%type default null
, p_data_aggiornamento  in RECAPITI.data_aggiornamento%type default null
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
   
   DbC.PRE ( not DbC.PreOn or p_ni is not null or /*default value*/ '' is not null
           , 'p_ni on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_dal is not null or /*default value*/ '' is not null
           , 'p_dal on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_al is not null or /*default value*/ 'default' is not null
           , 'p_al on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_descrizione is not null or /*default value*/ 'default' is not null
           , 'p_descrizione on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_id_tipo_recapito is not null or /*default value*/ '' is not null
           , 'p_id_tipo_recapito on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_indirizzo is not null or /*default value*/ 'default' is not null
           , 'p_indirizzo on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_provincia is not null or /*default value*/ 'default' is not null
           , 'p_provincia on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_comune is not null or /*default value*/ 'default' is not null
           , 'p_comune on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_cap is not null or /*default value*/ 'default' is not null
           , 'p_cap on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_presso is not null or /*default value*/ 'default' is not null
           , 'p_presso on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_importanza is not null or /*default value*/ 'default' is not null
           , 'p_importanza on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_competenza is not null or /*default value*/ 'default' is not null
           , 'p_competenza on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_competenza_esclusiva is not null or /*default value*/ 'default' is not null
           , 'p_competenza_esclusiva on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_version is not null or /*default value*/ 'default' is not null
           , 'p_version on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_utente_aggiornamento is not null or /*default value*/ 'default' is not null
           , 'p_utente_aggiornamento on recapiti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_data_aggiornamento is not null or /*default value*/ 'default' is not null
           , 'p_data_aggiornamento on recapiti_tpk.ins'
           );
   DbC.PRE (  not DbC.PreOn
           or (   p_id_recapito is null and /*default value*/ 'default null' is not null ) -- PK nullable on insert
           or not existsId (
                             p_id_recapito => p_id_recapito
                           )
           , 'not existsId on recapiti_tpk.ins'
           );
   insert into RECAPITI
   (
     id_recapito
   , ni
   , dal
   , al
   , descrizione
   , id_tipo_recapito
   , indirizzo
   , provincia
   , comune
   , cap
   , presso
   , importanza
   , competenza
   , competenza_esclusiva
   , version
   , utente_aggiornamento
   , data_aggiornamento
   )
   values
   (
     p_id_recapito
, p_ni
, p_dal
, p_al
, p_descrizione
, p_id_tipo_recapito
, p_indirizzo
, p_provincia
, p_comune
, p_cap
, p_presso
, p_importanza
, p_competenza
, p_competenza_esclusiva
, p_version
, p_utente_aggiornamento
, p_data_aggiornamento
   ) returning id_recapito
   into d_result;
   return d_result;
end ins; -- recapiti_tpk.ins
--------------------------------------------------------------------------------
procedure upd
(
  p_check_OLD  in integer default 0
, p_NEW_id_recapito  in RECAPITI.id_recapito%type
, p_OLD_id_recapito  in RECAPITI.id_recapito%type default null
, p_NEW_ni  in RECAPITI.ni%type default afc.default_null('RECAPITI.ni')
, p_OLD_ni  in RECAPITI.ni%type default null
, p_NEW_dal  in RECAPITI.dal%type default afc.default_null('RECAPITI.dal')
, p_OLD_dal  in RECAPITI.dal%type default null
, p_NEW_al  in RECAPITI.al%type default afc.default_null('RECAPITI.al')
, p_OLD_al  in RECAPITI.al%type default null
, p_NEW_descrizione  in RECAPITI.descrizione%type default afc.default_null('RECAPITI.descrizione')
, p_OLD_descrizione  in RECAPITI.descrizione%type default null
, p_NEW_id_tipo_recapito  in RECAPITI.id_tipo_recapito%type default afc.default_null('RECAPITI.id_tipo_recapito')
, p_OLD_id_tipo_recapito  in RECAPITI.id_tipo_recapito%type default null
, p_NEW_indirizzo  in RECAPITI.indirizzo%type default afc.default_null('RECAPITI.indirizzo')
, p_OLD_indirizzo  in RECAPITI.indirizzo%type default null
, p_NEW_provincia  in RECAPITI.provincia%type default afc.default_null('RECAPITI.provincia')
, p_OLD_provincia  in RECAPITI.provincia%type default null
, p_NEW_comune  in RECAPITI.comune%type default afc.default_null('RECAPITI.comune')
, p_OLD_comune  in RECAPITI.comune%type default null
, p_NEW_cap  in RECAPITI.cap%type default afc.default_null('RECAPITI.cap')
, p_OLD_cap  in RECAPITI.cap%type default null
, p_NEW_presso  in RECAPITI.presso%type default afc.default_null('RECAPITI.presso')
, p_OLD_presso  in RECAPITI.presso%type default null
, p_NEW_importanza  in RECAPITI.importanza%type default afc.default_null('RECAPITI.importanza')
, p_OLD_importanza  in RECAPITI.importanza%type default null
, p_NEW_competenza  in RECAPITI.competenza%type default afc.default_null('RECAPITI.competenza')
, p_OLD_competenza  in RECAPITI.competenza%type default null
, p_NEW_competenza_esclusiva  in RECAPITI.competenza_esclusiva%type default afc.default_null('RECAPITI.competenza_esclusiva')
, p_OLD_competenza_esclusiva  in RECAPITI.competenza_esclusiva%type default null
, p_NEW_version  in RECAPITI.version%type default afc.default_null('RECAPITI.version')
, p_OLD_version  in RECAPITI.version%type default null
, p_NEW_utente_aggiornamento  in RECAPITI.utente_aggiornamento%type default afc.default_null('RECAPITI.utente_aggiornamento')
, p_OLD_utente_aggiornamento  in RECAPITI.utente_aggiornamento%type default null
, p_NEW_data_aggiornamento  in RECAPITI.data_aggiornamento%type default afc.default_null('RECAPITI.data_aggiornamento')
, p_OLD_data_aggiornamento  in RECAPITI.data_aggiornamento%type default null
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

--raise_application_error(-20999,' id recapito ' ||  p_NEW_id_recapito);

--raise_application_error(-20999,' Competenze new-old: '||
--p_NEW_competenza  ||'-'||  p_OLD_competenza ||' '||  p_NEW_competenza_esclusiva||'-'||  p_OLD_competenza_esclusiva);
   DbC.PRE (  not DbC.PreOn
           or not ( ( 
p_OLD_ni is not null
 or p_OLD_dal is not null
 or p_OLD_al is not null
 or p_OLD_descrizione is not null
 or p_OLD_id_tipo_recapito is not null
 or p_OLD_indirizzo is not null
 or p_OLD_provincia is not null
 or p_OLD_comune is not null
 or p_OLD_cap is not null
 or p_OLD_presso is not null
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
           , ' "OLD values" is not null on recapiti_tpk.upd'
           );
   d_key := PK ( 
                nvl( p_OLD_id_recapito, p_NEW_id_recapito )
               );
   DbC.PRE ( not DbC.PreOn or existsId ( 
                                         p_id_recapito => d_key.id_recapito
                                       )
           , 'existsId on recapiti_tpk.upd' 
           );
   update RECAPITI
   set 
       id_recapito = NVL( p_NEW_id_recapito, DECODE( AFC.IS_DEFAULT_NULL( 'RECAPITI.id_recapito' ), 1, id_recapito,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_id_recapito, null, id_recapito, null ) ) ) )
     , ni = NVL( p_NEW_ni, DECODE( AFC.IS_DEFAULT_NULL( 'RECAPITI.ni' ), 1, ni,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_ni, null, ni, null ) ) ) )
     , dal = NVL( p_NEW_dal, DECODE( AFC.IS_DEFAULT_NULL( 'RECAPITI.dal' ), 1, dal,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_dal, null, dal, null ) ) ) )
     , al = NVL( p_NEW_al, DECODE( AFC.IS_DEFAULT_NULL( 'RECAPITI.al' ), 1, al,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_al, null, al, null ) ) ) )
     , descrizione = NVL( p_NEW_descrizione, DECODE( AFC.IS_DEFAULT_NULL( 'RECAPITI.descrizione' ), 1, descrizione,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_descrizione, null, descrizione, null ) ) ) )
     , id_tipo_recapito = NVL( p_NEW_id_tipo_recapito, DECODE( AFC.IS_DEFAULT_NULL( 'RECAPITI.id_tipo_recapito' ), 1, id_tipo_recapito,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_id_tipo_recapito, null, id_tipo_recapito, null ) ) ) )
     , indirizzo = NVL( p_NEW_indirizzo, DECODE( AFC.IS_DEFAULT_NULL( 'RECAPITI.indirizzo' ), 1, indirizzo,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_indirizzo, null, indirizzo, null ) ) ) )
     , provincia = NVL( p_NEW_provincia, DECODE( AFC.IS_DEFAULT_NULL( 'RECAPITI.provincia' ), 1, provincia,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_provincia, null, provincia, null ) ) ) )
     , comune = NVL( p_NEW_comune, DECODE( AFC.IS_DEFAULT_NULL( 'RECAPITI.comune' ), 1, comune,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_comune, null, comune, null ) ) ) )
     , cap = NVL( p_NEW_cap, DECODE( AFC.IS_DEFAULT_NULL( 'RECAPITI.cap' ), 1, cap,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_cap, null, cap, null ) ) ) )
     , presso = NVL( p_NEW_presso, DECODE( AFC.IS_DEFAULT_NULL( 'RECAPITI.presso' ), 1, presso,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_presso, null, presso, null ) ) ) )
     , importanza = NVL( p_NEW_importanza, DECODE( AFC.IS_DEFAULT_NULL( 'RECAPITI.importanza' ), 1, importanza,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_importanza, null, importanza, null ) ) ) )
     , competenza = NVL( p_NEW_competenza, DECODE( AFC.IS_DEFAULT_NULL( 'RECAPITI.competenza' ), 1, competenza,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_competenza, null, competenza, null ) ) ) )
     , competenza_esclusiva = NVL( p_NEW_competenza_esclusiva, DECODE( AFC.IS_DEFAULT_NULL( 'RECAPITI.competenza_esclusiva' ), 1, competenza_esclusiva,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_competenza_esclusiva, null, competenza_esclusiva, null ) ) ) )
     , version = NVL( p_NEW_version, DECODE( AFC.IS_DEFAULT_NULL( 'RECAPITI.version' ), 1, version,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_version, null, version, null ) ) ) )
     , utente_aggiornamento = NVL( p_NEW_utente_aggiornamento, DECODE( AFC.IS_DEFAULT_NULL( 'RECAPITI.utente_aggiornamento' ), 1, utente_aggiornamento,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_utente_aggiornamento, null, utente_aggiornamento, null ) ) ) )
     , data_aggiornamento = NVL( p_NEW_data_aggiornamento, DECODE( AFC.IS_DEFAULT_NULL( 'RECAPITI.data_aggiornamento' ), 1, data_aggiornamento,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_data_aggiornamento, null, data_aggiornamento, null ) ) ) )
   where 
     id_recapito = d_key.id_recapito
   and (   p_check_OLD = 0
        or (   1 = 1
           and ( ni = p_OLD_ni or ( p_OLD_ni is null and ( p_check_OLD is null or ni is null ) ) )
           and ( dal = p_OLD_dal or ( p_OLD_dal is null and ( p_check_OLD is null or dal is null ) ) )
           and ( al = p_OLD_al or ( p_OLD_al is null and ( p_check_OLD is null or al is null ) ) )
           and ( descrizione = p_OLD_descrizione or ( p_OLD_descrizione is null and ( p_check_OLD is null or descrizione is null ) ) )
           and ( id_tipo_recapito = p_OLD_id_tipo_recapito or ( p_OLD_id_tipo_recapito is null and ( p_check_OLD is null or id_tipo_recapito is null ) ) )
           and ( indirizzo = p_OLD_indirizzo or ( p_OLD_indirizzo is null and ( p_check_OLD is null or indirizzo is null ) ) )
           and ( provincia = p_OLD_provincia or ( p_OLD_provincia is null and ( p_check_OLD is null or provincia is null ) ) )
           and ( comune = p_OLD_comune or ( p_OLD_comune is null and ( p_check_OLD is null or comune is null ) ) )
           and ( cap = p_OLD_cap or ( p_OLD_cap is null and ( p_check_OLD is null or cap is null ) ) )
           and ( presso = p_OLD_presso or ( p_OLD_presso is null and ( p_check_OLD is null or presso is null ) ) )
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
                 , 'd_row_found <= 1 on recapiti_tpk.upd'
                 );
   if d_row_found < 1
   then
      raise_application_error ( AFC_ERROR.modified_by_other_user_number
                              , AFC_ERROR.modified_by_other_user_msg
                              );
   end if;
   
end upd; -- recapiti_tpk.upd
--------------------------------------------------------------------------------
procedure upd_column
( 
  p_id_recapito  in RECAPITI.id_recapito%type
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
                                        p_id_recapito => p_id_recapito
                                       )
           , 'existsId on recapiti_tpk.upd_column' 
           );
   DbC.PRE ( not DbC.PreOn or p_column is not null
           , 'p_column is not null on recapiti_tpk.upd_column'
           );
   DbC.PRE ( not DbC.PreOn or AFC_DDL.HasAttribute( s_table_name, p_column )
           , 'AFC_DDL.HasAttribute on recapiti_tpk.upd_column'
           );
   DbC.PRE ( p_literal_value in ( 0, 1 ) or p_literal_value is null
           , 'p_literal_value on recapiti_tpk.upd_column; p_literal_value = ' || p_literal_value
           );
   if p_literal_value = 1
   or p_literal_value is null
   then
      d_literal := '''';
   end if;
   d_statement := ' declare '
               || '    d_row_found number; '
               || ' begin '
               || '    update RECAPITI '
               || '       set ' || p_column || ' = ' || d_literal || p_value || d_literal
               || '     where 1 = 1 '
               || nvl( AFC.get_field_condition( ' and ( id_recapito ', p_id_recapito, ' )', 0, null ), ' and ( id_recapito is null ) ' )
               || '    ; '
               || '    d_row_found := SQL%ROWCOUNT; '
               || '    if d_row_found < 1 '
               || '    then '
               || '       raise_application_error ( AFC_ERROR.modified_by_other_user_number, AFC_ERROR.modified_by_other_user_msg ); '
               || '    end if; '
               || ' end; ';
   AFC.SQL_execute( d_statement );
end upd_column; -- recapiti_tpk.upd_column
--------------------------------------------------------------------------------
procedure upd_column
( 
p_id_recapito  in RECAPITI.id_recapito%type
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
p_id_recapito => p_id_recapito
              , p_column => p_column
              , p_value => 'to_date( ''' || d_data || ''', ''' || AFC.date_format || ''' )'
              , p_literal_value => 0
              );   
end upd_column; -- recapiti_tpk.upd_column
--------------------------------------------------------------------------------
procedure del
( 
  p_check_old  in integer default 0
, p_id_recapito  in RECAPITI.id_recapito%type
, p_ni  in RECAPITI.ni%type default null
, p_dal  in RECAPITI.dal%type default null
, p_al  in RECAPITI.al%type default null
, p_descrizione  in RECAPITI.descrizione%type default null
, p_id_tipo_recapito  in RECAPITI.id_tipo_recapito%type default null
, p_indirizzo  in RECAPITI.indirizzo%type default null
, p_provincia  in RECAPITI.provincia%type default null
, p_comune  in RECAPITI.comune%type default null
, p_cap  in RECAPITI.cap%type default null
, p_presso  in RECAPITI.presso%type default null
, p_importanza  in RECAPITI.importanza%type default null
, p_competenza  in RECAPITI.competenza%type default null
, p_competenza_esclusiva  in RECAPITI.competenza_esclusiva%type default null
, p_version  in RECAPITI.version%type default null
, p_utente_aggiornamento  in RECAPITI.utente_aggiornamento%type default null
, p_data_aggiornamento  in RECAPITI.data_aggiornamento%type default null
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
p_ni is not null
 or p_dal is not null
 or p_al is not null
 or p_descrizione is not null
 or p_id_tipo_recapito is not null
 or p_indirizzo is not null
 or p_provincia is not null
 or p_comune is not null
 or p_cap is not null
 or p_presso is not null
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
           , ' "OLD values" is not null on recapiti_tpk.del'
           );
   DbC.PRE ( not DbC.PreOn or existsId (
                                         p_id_recapito => p_id_recapito
                                       )
           , 'existsId on recapiti_tpk.del' 
           );
   delete from RECAPITI
   where 
     id_recapito = p_id_recapito
   and (   p_check_OLD = 0
        or (   1 = 1
           and ( ni = p_ni or ( p_ni is null and ( p_check_OLD is null or ni is null ) ) )
           and ( dal = p_dal or ( p_dal is null and ( p_check_OLD is null or dal is null ) ) )
           and ( al = p_al or ( p_al is null and ( p_check_OLD is null or al is null ) ) )
           and ( descrizione = p_descrizione or ( p_descrizione is null and ( p_check_OLD is null or descrizione is null ) ) )
           and ( id_tipo_recapito = p_id_tipo_recapito or ( p_id_tipo_recapito is null and ( p_check_OLD is null or id_tipo_recapito is null ) ) )
           and ( indirizzo = p_indirizzo or ( p_indirizzo is null and ( p_check_OLD is null or indirizzo is null ) ) )
           and ( provincia = p_provincia or ( p_provincia is null and ( p_check_OLD is null or provincia is null ) ) )
           and ( comune = p_comune or ( p_comune is null and ( p_check_OLD is null or comune is null ) ) )
           and ( cap = p_cap or ( p_cap is null and ( p_check_OLD is null or cap is null ) ) )
           and ( presso = p_presso or ( p_presso is null and ( p_check_OLD is null or presso is null ) ) )
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
                 , 'd_row_found <= 1 on recapiti_tpk.del'
                 );
   if d_row_found < 1
   then
      raise_application_error ( AFC_ERROR.modified_by_other_user_number
                              , AFC_ERROR.modified_by_other_user_msg
                              );
   end if;
   DbC.POST ( not DbC.PostOn or not existsId ( 
                                               p_id_recapito => p_id_recapito
                                             )
            , 'existsId on recapiti_tpk.del' 
            );
end del; -- recapiti_tpk.del
--------------------------------------------------------------------------------
function get_ni
( 
  p_id_recapito  in RECAPITI.id_recapito%type
) return RECAPITI.ni%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_ni
 DESCRIZIONE: Getter per attributo ni di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     RECAPITI.ni%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result RECAPITI.ni%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.get_ni' 
           );
   select ni
   into   d_result
   from   RECAPITI
   where  
   id_recapito = p_id_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (true)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on recapiti_tpk.get_ni'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'ni')
                    , ' AFC_DDL.IsNullable on recapiti_tpk.get_ni'
                    );
   end if;
   return  d_result;
end get_ni; -- recapiti_tpk.get_ni
--------------------------------------------------------------------------------
function get_dal
( 
  p_id_recapito  in RECAPITI.id_recapito%type
) return RECAPITI.dal%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_dal
 DESCRIZIONE: Getter per attributo dal di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     RECAPITI.dal%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result RECAPITI.dal%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.get_dal' 
           );
   select dal
   into   d_result
   from   RECAPITI
   where  
   id_recapito = p_id_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (true)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on recapiti_tpk.get_dal'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'dal')
                    , ' AFC_DDL.IsNullable on recapiti_tpk.get_dal'
                    );
   end if;
   return  d_result;
end get_dal; -- recapiti_tpk.get_dal
--------------------------------------------------------------------------------
function get_al
( 
  p_id_recapito  in RECAPITI.id_recapito%type
) return RECAPITI.al%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_al
 DESCRIZIONE: Getter per attributo al di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     RECAPITI.al%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result RECAPITI.al%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.get_al' 
           );
   select al
   into   d_result
   from   RECAPITI
   where  
   id_recapito = p_id_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on recapiti_tpk.get_al'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'al')
                    , ' AFC_DDL.IsNullable on recapiti_tpk.get_al'
                    );
   end if;
   return  d_result;
end get_al; -- recapiti_tpk.get_al
--------------------------------------------------------------------------------
function get_descrizione
( 
  p_id_recapito  in RECAPITI.id_recapito%type
) return RECAPITI.descrizione%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_descrizione
 DESCRIZIONE: Getter per attributo descrizione di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     RECAPITI.descrizione%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result RECAPITI.descrizione%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.get_descrizione' 
           );
   select descrizione
   into   d_result
   from   RECAPITI
   where  
   id_recapito = p_id_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on recapiti_tpk.get_descrizione'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'descrizione')
                    , ' AFC_DDL.IsNullable on recapiti_tpk.get_descrizione'
                    );
   end if;
   return  d_result;
end get_descrizione; -- recapiti_tpk.get_descrizione
--------------------------------------------------------------------------------
function get_id_tipo_recapito
( 
  p_id_recapito  in RECAPITI.id_recapito%type
) return RECAPITI.id_tipo_recapito%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_id_tipo_recapito
 DESCRIZIONE: Getter per attributo id_tipo_recapito di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     RECAPITI.id_tipo_recapito%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result RECAPITI.id_tipo_recapito%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.get_id_tipo_recapito' 
           );
   select id_tipo_recapito
   into   d_result
   from   RECAPITI
   where  
   id_recapito = p_id_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (true)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on recapiti_tpk.get_id_tipo_recapito'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'id_tipo_recapito')
                    , ' AFC_DDL.IsNullable on recapiti_tpk.get_id_tipo_recapito'
                    );
   end if;
   return  d_result;
end get_id_tipo_recapito; -- recapiti_tpk.get_id_tipo_recapito
--------------------------------------------------------------------------------
function get_indirizzo
( 
  p_id_recapito  in RECAPITI.id_recapito%type
) return RECAPITI.indirizzo%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_indirizzo
 DESCRIZIONE: Getter per attributo indirizzo di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     RECAPITI.indirizzo%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result RECAPITI.indirizzo%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.get_indirizzo' 
           );
   select indirizzo
   into   d_result
   from   RECAPITI
   where  
   id_recapito = p_id_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on recapiti_tpk.get_indirizzo'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'indirizzo')
                    , ' AFC_DDL.IsNullable on recapiti_tpk.get_indirizzo'
                    );
   end if;
   return  d_result;
end get_indirizzo; -- recapiti_tpk.get_indirizzo
--------------------------------------------------------------------------------
function get_provincia
( 
  p_id_recapito  in RECAPITI.id_recapito%type
) return RECAPITI.provincia%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_provincia
 DESCRIZIONE: Getter per attributo provincia di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     RECAPITI.provincia%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result RECAPITI.provincia%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.get_provincia' 
           );
   select provincia
   into   d_result
   from   RECAPITI
   where  
   id_recapito = p_id_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on recapiti_tpk.get_provincia'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'provincia')
                    , ' AFC_DDL.IsNullable on recapiti_tpk.get_provincia'
                    );
   end if;
   return  d_result;
end get_provincia; -- recapiti_tpk.get_provincia
--------------------------------------------------------------------------------
function get_comune
( 
  p_id_recapito  in RECAPITI.id_recapito%type
) return RECAPITI.comune%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_comune
 DESCRIZIONE: Getter per attributo comune di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     RECAPITI.comune%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result RECAPITI.comune%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.get_comune' 
           );
   select comune
   into   d_result
   from   RECAPITI
   where  
   id_recapito = p_id_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on recapiti_tpk.get_comune'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'comune')
                    , ' AFC_DDL.IsNullable on recapiti_tpk.get_comune'
                    );
   end if;
   return  d_result;
end get_comune; -- recapiti_tpk.get_comune
--------------------------------------------------------------------------------
function get_cap
( 
  p_id_recapito  in RECAPITI.id_recapito%type
) return RECAPITI.cap%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_cap
 DESCRIZIONE: Getter per attributo cap di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     RECAPITI.cap%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result RECAPITI.cap%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.get_cap' 
           );
   select cap
   into   d_result
   from   RECAPITI
   where  
   id_recapito = p_id_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on recapiti_tpk.get_cap'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'cap')
                    , ' AFC_DDL.IsNullable on recapiti_tpk.get_cap'
                    );
   end if;
   return  d_result;
end get_cap; -- recapiti_tpk.get_cap
--------------------------------------------------------------------------------
function get_presso
( 
  p_id_recapito  in RECAPITI.id_recapito%type
) return RECAPITI.presso%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_presso
 DESCRIZIONE: Getter per attributo presso di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     RECAPITI.presso%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result RECAPITI.presso%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.get_presso' 
           );
   select presso
   into   d_result
   from   RECAPITI
   where  
   id_recapito = p_id_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on recapiti_tpk.get_presso'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'presso')
                    , ' AFC_DDL.IsNullable on recapiti_tpk.get_presso'
                    );
   end if;
   return  d_result;
end get_presso; -- recapiti_tpk.get_presso
--------------------------------------------------------------------------------
function get_importanza
( 
  p_id_recapito  in RECAPITI.id_recapito%type
) return RECAPITI.importanza%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_importanza
 DESCRIZIONE: Getter per attributo importanza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     RECAPITI.importanza%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result RECAPITI.importanza%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.get_importanza' 
           );
   select importanza
   into   d_result
   from   RECAPITI
   where  
   id_recapito = p_id_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on recapiti_tpk.get_importanza'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'importanza')
                    , ' AFC_DDL.IsNullable on recapiti_tpk.get_importanza'
                    );
   end if;
   return  d_result;
end get_importanza; -- recapiti_tpk.get_importanza
--------------------------------------------------------------------------------
function get_competenza
( 
  p_id_recapito  in RECAPITI.id_recapito%type
) return RECAPITI.competenza%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_competenza
 DESCRIZIONE: Getter per attributo competenza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     RECAPITI.competenza%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result RECAPITI.competenza%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.get_competenza' 
           );
   select competenza
   into   d_result
   from   RECAPITI
   where  
   id_recapito = p_id_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on recapiti_tpk.get_competenza'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'competenza')
                    , ' AFC_DDL.IsNullable on recapiti_tpk.get_competenza'
                    );
   end if;
   return  d_result;
end get_competenza; -- recapiti_tpk.get_competenza
--------------------------------------------------------------------------------
function get_competenza_esclusiva
( 
  p_id_recapito  in RECAPITI.id_recapito%type
) return RECAPITI.competenza_esclusiva%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_competenza_esclusiva
 DESCRIZIONE: Getter per attributo competenza_esclusiva di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     RECAPITI.competenza_esclusiva%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result RECAPITI.competenza_esclusiva%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.get_competenza_esclusiva' 
           );
   select competenza_esclusiva
   into   d_result
   from   RECAPITI
   where  
   id_recapito = p_id_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on recapiti_tpk.get_competenza_esclusiva'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'competenza_esclusiva')
                    , ' AFC_DDL.IsNullable on recapiti_tpk.get_competenza_esclusiva'
                    );
   end if;
   return  d_result;
end get_competenza_esclusiva; -- recapiti_tpk.get_competenza_esclusiva
--------------------------------------------------------------------------------
function get_version
( 
  p_id_recapito  in RECAPITI.id_recapito%type
) return RECAPITI.version%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_version
 DESCRIZIONE: Getter per attributo version di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     RECAPITI.version%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result RECAPITI.version%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.get_version' 
           );
   select version
   into   d_result
   from   RECAPITI
   where  
   id_recapito = p_id_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on recapiti_tpk.get_version'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'version')
                    , ' AFC_DDL.IsNullable on recapiti_tpk.get_version'
                    );
   end if;
   return  d_result;
end get_version; -- recapiti_tpk.get_version
--------------------------------------------------------------------------------
function get_utente_aggiornamento
( 
  p_id_recapito  in RECAPITI.id_recapito%type
) return RECAPITI.utente_aggiornamento%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_utente_aggiornamento
 DESCRIZIONE: Getter per attributo utente_aggiornamento di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     RECAPITI.utente_aggiornamento%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result RECAPITI.utente_aggiornamento%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.get_utente_aggiornamento' 
           );
   select utente_aggiornamento
   into   d_result
   from   RECAPITI
   where  
   id_recapito = p_id_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on recapiti_tpk.get_utente_aggiornamento'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'utente_aggiornamento')
                    , ' AFC_DDL.IsNullable on recapiti_tpk.get_utente_aggiornamento'
                    );
   end if;
   return  d_result;
end get_utente_aggiornamento; -- recapiti_tpk.get_utente_aggiornamento
--------------------------------------------------------------------------------
function get_data_aggiornamento
( 
  p_id_recapito  in RECAPITI.id_recapito%type
) return RECAPITI.data_aggiornamento%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_data_aggiornamento
 DESCRIZIONE: Getter per attributo data_aggiornamento di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     RECAPITI.data_aggiornamento%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result RECAPITI.data_aggiornamento%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.get_data_aggiornamento' 
           );
   select data_aggiornamento
   into   d_result
   from   RECAPITI
   where  
   id_recapito = p_id_recapito
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on recapiti_tpk.get_data_aggiornamento'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'data_aggiornamento')
                    , ' AFC_DDL.IsNullable on recapiti_tpk.get_data_aggiornamento'
                    );
   end if;
   return  d_result;
end get_data_aggiornamento; -- recapiti_tpk.get_data_aggiornamento
--------------------------------------------------------------------------------
procedure set_id_recapito
( 
  p_id_recapito  in RECAPITI.id_recapito%type
, p_value  in RECAPITI.id_recapito%type default null
) is
/******************************************************************************
 NOME:        set_id_recapito
 DESCRIZIONE: Setter per attributo id_recapito di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.set_id_recapito' 
           );
   update RECAPITI
   set id_recapito = p_value
   where
   id_recapito = p_id_recapito
   ;
end set_id_recapito; -- recapiti_tpk.set_id_recapito
--------------------------------------------------------------------------------
procedure set_ni
( 
  p_id_recapito  in RECAPITI.id_recapito%type
, p_value  in RECAPITI.ni%type default null
) is
/******************************************************************************
 NOME:        set_ni
 DESCRIZIONE: Setter per attributo ni di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.set_ni' 
           );
   update RECAPITI
   set ni = p_value
   where
   id_recapito = p_id_recapito
   ;
end set_ni; -- recapiti_tpk.set_ni
--------------------------------------------------------------------------------
procedure set_dal
( 
  p_id_recapito  in RECAPITI.id_recapito%type
, p_value  in RECAPITI.dal%type default null
) is
/******************************************************************************
 NOME:        set_dal
 DESCRIZIONE: Setter per attributo dal di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.set_dal' 
           );
   update RECAPITI
   set dal = p_value
   where
   id_recapito = p_id_recapito
   ;
end set_dal; -- recapiti_tpk.set_dal
--------------------------------------------------------------------------------
procedure set_al
( 
  p_id_recapito  in RECAPITI.id_recapito%type
, p_value  in RECAPITI.al%type default null
) is
/******************************************************************************
 NOME:        set_al
 DESCRIZIONE: Setter per attributo al di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.set_al' 
           );
   update RECAPITI
   set al = p_value
   where
   id_recapito = p_id_recapito
   ;
end set_al; -- recapiti_tpk.set_al
--------------------------------------------------------------------------------
procedure set_descrizione
( 
  p_id_recapito  in RECAPITI.id_recapito%type
, p_value  in RECAPITI.descrizione%type default null
) is
/******************************************************************************
 NOME:        set_descrizione
 DESCRIZIONE: Setter per attributo descrizione di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.set_descrizione' 
           );
   update RECAPITI
   set descrizione = p_value
   where
   id_recapito = p_id_recapito
   ;
end set_descrizione; -- recapiti_tpk.set_descrizione
--------------------------------------------------------------------------------
procedure set_id_tipo_recapito
( 
  p_id_recapito  in RECAPITI.id_recapito%type
, p_value  in RECAPITI.id_tipo_recapito%type default null
) is
/******************************************************************************
 NOME:        set_id_tipo_recapito
 DESCRIZIONE: Setter per attributo id_tipo_recapito di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.set_id_tipo_recapito' 
           );
   update RECAPITI
   set id_tipo_recapito = p_value
   where
   id_recapito = p_id_recapito
   ;
end set_id_tipo_recapito; -- recapiti_tpk.set_id_tipo_recapito
--------------------------------------------------------------------------------
procedure set_indirizzo
( 
  p_id_recapito  in RECAPITI.id_recapito%type
, p_value  in RECAPITI.indirizzo%type default null
) is
/******************************************************************************
 NOME:        set_indirizzo
 DESCRIZIONE: Setter per attributo indirizzo di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.set_indirizzo' 
           );
   update RECAPITI
   set indirizzo = p_value
   where
   id_recapito = p_id_recapito
   ;
end set_indirizzo; -- recapiti_tpk.set_indirizzo
--------------------------------------------------------------------------------
procedure set_provincia
( 
  p_id_recapito  in RECAPITI.id_recapito%type
, p_value  in RECAPITI.provincia%type default null
) is
/******************************************************************************
 NOME:        set_provincia
 DESCRIZIONE: Setter per attributo provincia di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.set_provincia' 
           );
   update RECAPITI
   set provincia = p_value
   where
   id_recapito = p_id_recapito
   ;
end set_provincia; -- recapiti_tpk.set_provincia
--------------------------------------------------------------------------------
procedure set_comune
( 
  p_id_recapito  in RECAPITI.id_recapito%type
, p_value  in RECAPITI.comune%type default null
) is
/******************************************************************************
 NOME:        set_comune
 DESCRIZIONE: Setter per attributo comune di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.set_comune' 
           );
   update RECAPITI
   set comune = p_value
   where
   id_recapito = p_id_recapito
   ;
end set_comune; -- recapiti_tpk.set_comune
--------------------------------------------------------------------------------
procedure set_cap
( 
  p_id_recapito  in RECAPITI.id_recapito%type
, p_value  in RECAPITI.cap%type default null
) is
/******************************************************************************
 NOME:        set_cap
 DESCRIZIONE: Setter per attributo cap di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.set_cap' 
           );
   update RECAPITI
   set cap = p_value
   where
   id_recapito = p_id_recapito
   ;
end set_cap; -- recapiti_tpk.set_cap
--------------------------------------------------------------------------------
procedure set_presso
( 
  p_id_recapito  in RECAPITI.id_recapito%type
, p_value  in RECAPITI.presso%type default null
) is
/******************************************************************************
 NOME:        set_presso
 DESCRIZIONE: Setter per attributo presso di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.set_presso' 
           );
   update RECAPITI
   set presso = p_value
   where
   id_recapito = p_id_recapito
   ;
end set_presso; -- recapiti_tpk.set_presso
--------------------------------------------------------------------------------
procedure set_importanza
( 
  p_id_recapito  in RECAPITI.id_recapito%type
, p_value  in RECAPITI.importanza%type default null
) is
/******************************************************************************
 NOME:        set_importanza
 DESCRIZIONE: Setter per attributo importanza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.set_importanza' 
           );
   update RECAPITI
   set importanza = p_value
   where
   id_recapito = p_id_recapito
   ;
end set_importanza; -- recapiti_tpk.set_importanza
--------------------------------------------------------------------------------
procedure set_competenza
( 
  p_id_recapito  in RECAPITI.id_recapito%type
, p_value  in RECAPITI.competenza%type default null
) is
/******************************************************************************
 NOME:        set_competenza
 DESCRIZIONE: Setter per attributo competenza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.set_competenza' 
           );
   update RECAPITI
   set competenza = p_value
   where
   id_recapito = p_id_recapito
   ;
end set_competenza; -- recapiti_tpk.set_competenza
--------------------------------------------------------------------------------
procedure set_competenza_esclusiva
( 
  p_id_recapito  in RECAPITI.id_recapito%type
, p_value  in RECAPITI.competenza_esclusiva%type default null
) is
/******************************************************************************
 NOME:        set_competenza_esclusiva
 DESCRIZIONE: Setter per attributo competenza_esclusiva di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.set_competenza_esclusiva' 
           );
   update RECAPITI
   set competenza_esclusiva = p_value
   where
   id_recapito = p_id_recapito
   ;
end set_competenza_esclusiva; -- recapiti_tpk.set_competenza_esclusiva
--------------------------------------------------------------------------------
procedure set_version
( 
  p_id_recapito  in RECAPITI.id_recapito%type
, p_value  in RECAPITI.version%type default null
) is
/******************************************************************************
 NOME:        set_version
 DESCRIZIONE: Setter per attributo version di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.set_version' 
           );
   update RECAPITI
   set version = p_value
   where
   id_recapito = p_id_recapito
   ;
end set_version; -- recapiti_tpk.set_version
--------------------------------------------------------------------------------
procedure set_utente_aggiornamento
( 
  p_id_recapito  in RECAPITI.id_recapito%type
, p_value  in RECAPITI.utente_aggiornamento%type default null
) is
/******************************************************************************
 NOME:        set_utente_aggiornamento
 DESCRIZIONE: Setter per attributo utente_aggiornamento di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.set_utente_aggiornamento' 
           );
   update RECAPITI
   set utente_aggiornamento = p_value
   where
   id_recapito = p_id_recapito
   ;
end set_utente_aggiornamento; -- recapiti_tpk.set_utente_aggiornamento
--------------------------------------------------------------------------------
procedure set_data_aggiornamento
( 
  p_id_recapito  in RECAPITI.id_recapito%type
, p_value  in RECAPITI.data_aggiornamento%type default null
) is
/******************************************************************************
 NOME:        set_data_aggiornamento
 DESCRIZIONE: Setter per attributo data_aggiornamento di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_recapito => p_id_recapito
                                        )
           , 'existsId on recapiti_tpk.set_data_aggiornamento' 
           );
   update RECAPITI
   set data_aggiornamento = p_value
   where
   id_recapito = p_id_recapito
   ;
end set_data_aggiornamento; -- recapiti_tpk.set_data_aggiornamento
--------------------------------------------------------------------------------
function where_condition /* SLAVE_COPY */
( p_QBE  in number default 0
, p_other_condition in varchar2 default null
, p_id_recapito  in varchar2 default null
, p_ni  in varchar2 default null
, p_dal  in varchar2 default null
, p_al  in varchar2 default null
, p_descrizione  in varchar2 default null
, p_id_tipo_recapito  in varchar2 default null
, p_indirizzo  in varchar2 default null
, p_provincia  in varchar2 default null
, p_comune  in varchar2 default null
, p_cap  in varchar2 default null
, p_presso  in varchar2 default null
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
               || AFC.get_field_condition( ' and ( id_recapito ', p_id_recapito, ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( ni ', p_ni , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( dal ', p_dal , ' )', p_QBE, AFC.date_format )
               || AFC.get_field_condition( ' and ( al ', p_al , ' )', p_QBE, AFC.date_format )
               || AFC.get_field_condition( ' and ( descrizione ', p_descrizione , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( id_tipo_recapito ', p_id_tipo_recapito , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( indirizzo ', p_indirizzo , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( provincia ', p_provincia , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( comune ', p_comune , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( cap ', p_cap , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( presso ', p_presso , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( importanza ', p_importanza , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( competenza ', p_competenza , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( competenza_esclusiva ', p_competenza_esclusiva , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( version ', p_version , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( utente_aggiornamento ', p_utente_aggiornamento , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( data_aggiornamento ', p_data_aggiornamento , ' )', p_QBE, AFC.date_format )
               || ' ) ' || p_other_condition
               ;
   return d_statement;
end where_condition; --- recapiti_tpk.where_condition
--------------------------------------------------------------------------------
function get_rows
( p_QBE  in number default 0
, p_other_condition in varchar2 default null
, p_order_by in varchar2 default null
, p_extra_columns in varchar2 default null
, p_extra_condition in varchar2 default null
, p_id_recapito  in varchar2 default null
, p_ni  in varchar2 default null
, p_dal  in varchar2 default null
, p_al  in varchar2 default null
, p_descrizione  in varchar2 default null
, p_id_tipo_recapito  in varchar2 default null
, p_indirizzo  in varchar2 default null
, p_provincia  in varchar2 default null
, p_comune  in varchar2 default null
, p_cap  in varchar2 default null
, p_presso  in varchar2 default null
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
   d_statement := ' select RECAPITI.* '
               || afc.decode_value( p_extra_columns, null, null, ' , ' || p_extra_columns )
               || ' from RECAPITI '
               || where_condition( 
                                   p_QBE => p_QBE
                                 , p_other_condition => p_other_condition
                                 , p_id_recapito => p_id_recapito
                                 , p_ni => p_ni
                                 , p_dal => p_dal
                                 , p_al => p_al
                                 , p_descrizione => p_descrizione
                                 , p_id_tipo_recapito => p_id_tipo_recapito
                                 , p_indirizzo => p_indirizzo
                                 , p_provincia => p_provincia
                                 , p_comune => p_comune
                                 , p_cap => p_cap
                                 , p_presso => p_presso
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
end get_rows; -- recapiti_tpk.get_rows
--------------------------------------------------------------------------------
function count_rows
( p_QBE  in number default 0
, p_other_condition in varchar2 default null
, p_id_recapito  in varchar2 default null
, p_ni  in varchar2 default null
, p_dal  in varchar2 default null
, p_al  in varchar2 default null
, p_descrizione  in varchar2 default null
, p_id_tipo_recapito  in varchar2 default null
, p_indirizzo  in varchar2 default null
, p_provincia  in varchar2 default null
, p_comune  in varchar2 default null
, p_cap  in varchar2 default null
, p_presso  in varchar2 default null
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
   d_statement := ' select count( * ) from RECAPITI '
               || where_condition( 
                                   p_QBE => p_QBE
                                 , p_other_condition => p_other_condition
                                 , p_id_recapito => p_id_recapito
                                 , p_ni => p_ni
                                 , p_dal => p_dal
                                 , p_al => p_al
                                 , p_descrizione => p_descrizione
                                 , p_id_tipo_recapito => p_id_tipo_recapito
                                 , p_indirizzo => p_indirizzo
                                 , p_provincia => p_provincia
                                 , p_comune => p_comune
                                 , p_cap => p_cap
                                 , p_presso => p_presso
                                 , p_importanza => p_importanza
                                 , p_competenza => p_competenza
                                 , p_competenza_esclusiva => p_competenza_esclusiva
                                 , p_version => p_version
                                 , p_utente_aggiornamento => p_utente_aggiornamento
                                 , p_data_aggiornamento => p_data_aggiornamento
                                 );
   d_result := AFC.SQL_execute( d_statement );
   return d_result;
end count_rows; -- recapiti_tpk.count_rows
--------------------------------------------------------------------------------

   
         
end recapiti_tpk;
/

