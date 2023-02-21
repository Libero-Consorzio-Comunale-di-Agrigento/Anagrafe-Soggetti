CREATE OR REPLACE package body anagrafici_tpk is
/******************************************************************************
 NOME:        anagrafici_tpk
 DESCRIZIONE: Gestione tabella ANAGRAFICI.
 ANNOTAZIONI: .
 REVISIONI:   .
 Rev.  Data        Autore      Descrizione.
 000   08/06/2017  snegroni  Generazione automatica. 
 001   13/02/2019  SNegroni  Generazione automatica. 
******************************************************************************/
   s_revisione_body      constant AFC.t_revision := '001 - 13/02/2019';
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
end versione; -- anagrafici_tpk.versione
--------------------------------------------------------------------------------
function PK
(
 p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return t_PK is /* SLAVE_COPY */
/******************************************************************************
 NOME:        PK
 DESCRIZIONE: Costruttore di un t_PK dati gli attributi della chiave
******************************************************************************/
   d_result t_PK;   
begin
   d_result.id_anagrafica := p_id_anagrafica;
   DbC.PRE ( not DbC.PreOn or canHandle (
                                          p_id_anagrafica => d_result.id_anagrafica
                                        )
           , 'canHandle on anagrafici_tpk.PK' 
           );
   return  d_result;
end PK; -- anagrafici_tpk.PK
--------------------------------------------------------------------------------
function can_handle
(
 p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
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
          p_id_anagrafica is null
       )
   then
      d_result := 0;
   end if;
   DbC.POST ( d_result = 1  or  d_result = 0
            , 'd_result = 1  or  d_result = 0 on anagrafici_tpk.can_handle'
            );
   return  d_result;   
end can_handle; -- anagrafici_tpk.can_handle
--------------------------------------------------------------------------------
function canHandle
(
 p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return boolean is /* SLAVE_COPY */
/******************************************************************************
 NOME:        canHandle
 DESCRIZIONE: La chiave specificata rispetta tutti i requisiti sugli attributi componenti.
 PARAMETRI:   Attributi chiave.
 RITORNA:     number: true se la chiave e manipolabile, false altrimenti.
 NOTE:        Wrapper boolean di can_handle (cfr. can_handle).
******************************************************************************/
   d_result constant boolean := AFC.to_boolean ( can_handle (
                                                              p_id_anagrafica => p_id_anagrafica
                                                            ) 
                                               );
begin
   return  d_result;
end canHandle; -- anagrafici_tpk.canHandle
--------------------------------------------------------------------------------
function exists_id
( 
 p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
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
                                         p_id_anagrafica => p_id_anagrafica
                                        )
           , 'canHandle on anagrafici_tpk.exists_id' 
           );
   begin
      select 1
      into   d_result
      from   ANAGRAFICI
      where  
      id_anagrafica = p_id_anagrafica
      ;
   exception
      when no_data_found then
         d_result := 0;
   end;
   DbC.POST ( d_result = 1  or  d_result = 0
            , 'd_result = 1  or  d_result = 0 on anagrafici_tpk.exists_id'
            );
   return  d_result;   
end exists_id; -- anagrafici_tpk.exists_id
--------------------------------------------------------------------------------
function existsId
( 
 p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return boolean is /* SLAVE_COPY */
/******************************************************************************
 NOME:        existsId
 DESCRIZIONE: Esistenza riga con chiave indicata.
 NOTE:        Wrapper boolean di exists_id (cfr. exists_id).
******************************************************************************/
   d_result constant boolean := AFC.to_boolean ( exists_id (
                                                            p_id_anagrafica => p_id_anagrafica
                                                           ) 
                                               );
begin
   return  d_result;
end existsId; -- anagrafici_tpk.existsId
--------------------------------------------------------------------------------
procedure ins
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type default null
, p_ni  in ANAGRAFICI.ni%type 
, p_dal  in ANAGRAFICI.dal%type 
, p_al  in ANAGRAFICI.al%type default null
, p_cognome  in ANAGRAFICI.cognome%type 
, p_nome  in ANAGRAFICI.nome%type default null
, p_sesso  in ANAGRAFICI.sesso%type default null
, p_data_nas  in ANAGRAFICI.data_nas%type default null
, p_provincia_nas  in ANAGRAFICI.provincia_nas%type default null
, p_comune_nas  in ANAGRAFICI.comune_nas%type default null
, p_luogo_nas  in ANAGRAFICI.luogo_nas%type default null
, p_codice_fiscale  in ANAGRAFICI.codice_fiscale%type default null
, p_codice_fiscale_estero  in ANAGRAFICI.codice_fiscale_estero%type default null
, p_partita_iva  in ANAGRAFICI.partita_iva%type default null
, p_cittadinanza  in ANAGRAFICI.cittadinanza%type default null
, p_gruppo_ling  in ANAGRAFICI.gruppo_ling%type default null
, p_competenza  in ANAGRAFICI.competenza%type default null
, p_competenza_esclusiva  in ANAGRAFICI.competenza_esclusiva%type default null
, p_tipo_soggetto  in ANAGRAFICI.tipo_soggetto%type default null
, p_stato_cee  in ANAGRAFICI.stato_cee%type default null
, p_partita_iva_cee  in ANAGRAFICI.partita_iva_cee%type default null
, p_fine_validita  in ANAGRAFICI.fine_validita%type default null
, p_stato_soggetto  in ANAGRAFICI.stato_soggetto%type default 'U'
, p_denominazione  in ANAGRAFICI.denominazione%type default null
, p_note  in ANAGRAFICI.note%type default null
, p_version  in ANAGRAFICI.version%type default 0
, p_utente  in ANAGRAFICI.utente%type default null
, p_data_agg  in ANAGRAFICI.data_agg%type default SYSDATE
, p_denominazione_ricerca  in ANAGRAFICI.denominazione_ricerca%type default null
) is
/******************************************************************************
 NOME:        ins
 DESCRIZIONE: Inserimento di una riga con chiave e attributi indicati.
 PARAMETRI:   Chiavi e attributi della table.
******************************************************************************/
begin
   -- Check Mandatory on Insert
   
   DbC.PRE ( not DbC.PreOn or p_ni is not null or /*default value*/ '' is not null
           , 'p_ni on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_dal is not null or /*default value*/ '' is not null
           , 'p_dal on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_al is not null or /*default value*/ 'default' is not null
           , 'p_al on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_cognome is not null or /*default value*/ '' is not null
           , 'p_cognome on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_nome is not null or /*default value*/ 'default' is not null
           , 'p_nome on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_sesso is not null or /*default value*/ 'default' is not null
           , 'p_sesso on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_data_nas is not null or /*default value*/ 'default' is not null
           , 'p_data_nas on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_provincia_nas is not null or /*default value*/ 'default' is not null
           , 'p_provincia_nas on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_comune_nas is not null or /*default value*/ 'default' is not null
           , 'p_comune_nas on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_luogo_nas is not null or /*default value*/ 'default' is not null
           , 'p_luogo_nas on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_codice_fiscale is not null or /*default value*/ 'default' is not null
           , 'p_codice_fiscale on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_codice_fiscale_estero is not null or /*default value*/ 'default' is not null
           , 'p_codice_fiscale_estero on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_partita_iva is not null or /*default value*/ 'default' is not null
           , 'p_partita_iva on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_cittadinanza is not null or /*default value*/ 'default' is not null
           , 'p_cittadinanza on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_gruppo_ling is not null or /*default value*/ 'default' is not null
           , 'p_gruppo_ling on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_competenza is not null or /*default value*/ 'default' is not null
           , 'p_competenza on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_competenza_esclusiva is not null or /*default value*/ 'default' is not null
           , 'p_competenza_esclusiva on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_tipo_soggetto is not null or /*default value*/ 'default' is not null
           , 'p_tipo_soggetto on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_stato_cee is not null or /*default value*/ 'default' is not null
           , 'p_stato_cee on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_partita_iva_cee is not null or /*default value*/ 'default' is not null
           , 'p_partita_iva_cee on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_fine_validita is not null or /*default value*/ 'default' is not null
           , 'p_fine_validita on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_stato_soggetto is not null or /*default value*/ 'default' is not null
           , 'p_stato_soggetto on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_denominazione is not null or /*default value*/ 'default' is not null
           , 'p_denominazione on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_note is not null or /*default value*/ 'default' is not null
           , 'p_note on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_version is not null or /*default value*/ 'default' is not null
           , 'p_version on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_utente is not null or /*default value*/ 'default' is not null
           , 'p_utente on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_data_agg is not null or /*default value*/ 'default' is not null
           , 'p_data_agg on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_denominazione_ricerca is not null or /*default value*/ 'default' is not null
           , 'p_denominazione_ricerca on anagrafici_tpk.ins'
           );
   DbC.PRE (  not DbC.PreOn
           or (   p_id_anagrafica is null and /*default value*/ 'default null' is not null ) -- PK nullable on insert
           or not existsId (
                             p_id_anagrafica => p_id_anagrafica
                           )
           , 'not existsId on anagrafici_tpk.ins'
           );
   insert into ANAGRAFICI
   (
     id_anagrafica
   , ni
   , dal
   , al
   , cognome
   , nome
   , sesso
   , data_nas
   , provincia_nas
   , comune_nas
   , luogo_nas
   , codice_fiscale
   , codice_fiscale_estero
   , partita_iva
   , cittadinanza
   , gruppo_ling
   , competenza
   , competenza_esclusiva
   , tipo_soggetto
   , stato_cee
   , partita_iva_cee
   , fine_validita
   , stato_soggetto
   , denominazione
   , note
   , version
   , utente
   , data_agg
   , denominazione_ricerca
   )
   values
   (
     p_id_anagrafica
, p_ni
, p_dal
, p_al
, p_cognome
, p_nome
, p_sesso
, p_data_nas
, p_provincia_nas
, p_comune_nas
, p_luogo_nas
, p_codice_fiscale
, p_codice_fiscale_estero
, p_partita_iva
, p_cittadinanza
, p_gruppo_ling
, p_competenza
, p_competenza_esclusiva
, p_tipo_soggetto
, p_stato_cee
, p_partita_iva_cee
, p_fine_validita
, nvl( p_stato_soggetto, 'U' )
, p_denominazione
, p_note
, p_version
, p_utente
, p_data_agg
, p_denominazione_ricerca
   );
end ins; -- anagrafici_tpk.ins
--------------------------------------------------------------------------------
function ins
(
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type default null
, p_ni  in ANAGRAFICI.ni%type 
, p_dal  in ANAGRAFICI.dal%type 
, p_al  in ANAGRAFICI.al%type default null
, p_cognome  in ANAGRAFICI.cognome%type 
, p_nome  in ANAGRAFICI.nome%type default null
, p_sesso  in ANAGRAFICI.sesso%type default null
, p_data_nas  in ANAGRAFICI.data_nas%type default null
, p_provincia_nas  in ANAGRAFICI.provincia_nas%type default null
, p_comune_nas  in ANAGRAFICI.comune_nas%type default null
, p_luogo_nas  in ANAGRAFICI.luogo_nas%type default null
, p_codice_fiscale  in ANAGRAFICI.codice_fiscale%type default null
, p_codice_fiscale_estero  in ANAGRAFICI.codice_fiscale_estero%type default null
, p_partita_iva  in ANAGRAFICI.partita_iva%type default null
, p_cittadinanza  in ANAGRAFICI.cittadinanza%type default null
, p_gruppo_ling  in ANAGRAFICI.gruppo_ling%type default null
, p_competenza  in ANAGRAFICI.competenza%type default null
, p_competenza_esclusiva  in ANAGRAFICI.competenza_esclusiva%type default null
, p_tipo_soggetto  in ANAGRAFICI.tipo_soggetto%type default null
, p_stato_cee  in ANAGRAFICI.stato_cee%type default null
, p_partita_iva_cee  in ANAGRAFICI.partita_iva_cee%type default null
, p_fine_validita  in ANAGRAFICI.fine_validita%type default null
, p_stato_soggetto  in ANAGRAFICI.stato_soggetto%type default 'U'
, p_denominazione  in ANAGRAFICI.denominazione%type default null
, p_note  in ANAGRAFICI.note%type default null
, p_version  in ANAGRAFICI.version%type default 0
, p_utente  in ANAGRAFICI.utente%type default null
, p_data_agg  in ANAGRAFICI.data_agg%type default SYSDATE
, p_denominazione_ricerca  in ANAGRAFICI.denominazione_ricerca%type default null
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
           , 'p_ni on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_dal is not null or /*default value*/ '' is not null
           , 'p_dal on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_al is not null or /*default value*/ 'default' is not null
           , 'p_al on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_cognome is not null or /*default value*/ '' is not null
           , 'p_cognome on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_nome is not null or /*default value*/ 'default' is not null
           , 'p_nome on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_sesso is not null or /*default value*/ 'default' is not null
           , 'p_sesso on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_data_nas is not null or /*default value*/ 'default' is not null
           , 'p_data_nas on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_provincia_nas is not null or /*default value*/ 'default' is not null
           , 'p_provincia_nas on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_comune_nas is not null or /*default value*/ 'default' is not null
           , 'p_comune_nas on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_luogo_nas is not null or /*default value*/ 'default' is not null
           , 'p_luogo_nas on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_codice_fiscale is not null or /*default value*/ 'default' is not null
           , 'p_codice_fiscale on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_codice_fiscale_estero is not null or /*default value*/ 'default' is not null
           , 'p_codice_fiscale_estero on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_partita_iva is not null or /*default value*/ 'default' is not null
           , 'p_partita_iva on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_cittadinanza is not null or /*default value*/ 'default' is not null
           , 'p_cittadinanza on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_gruppo_ling is not null or /*default value*/ 'default' is not null
           , 'p_gruppo_ling on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_competenza is not null or /*default value*/ 'default' is not null
           , 'p_competenza on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_competenza_esclusiva is not null or /*default value*/ 'default' is not null
           , 'p_competenza_esclusiva on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_tipo_soggetto is not null or /*default value*/ 'default' is not null
           , 'p_tipo_soggetto on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_stato_cee is not null or /*default value*/ 'default' is not null
           , 'p_stato_cee on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_partita_iva_cee is not null or /*default value*/ 'default' is not null
           , 'p_partita_iva_cee on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_fine_validita is not null or /*default value*/ 'default' is not null
           , 'p_fine_validita on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_stato_soggetto is not null or /*default value*/ 'default' is not null
           , 'p_stato_soggetto on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_denominazione is not null or /*default value*/ 'default' is not null
           , 'p_denominazione on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_note is not null or /*default value*/ 'default' is not null
           , 'p_note on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_version is not null or /*default value*/ 'default' is not null
           , 'p_version on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_utente is not null or /*default value*/ 'default' is not null
           , 'p_utente on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_data_agg is not null or /*default value*/ 'default' is not null
           , 'p_data_agg on anagrafici_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_denominazione_ricerca is not null or /*default value*/ 'default' is not null
           , 'p_denominazione_ricerca on anagrafici_tpk.ins'
           );
   DbC.PRE (  not DbC.PreOn
           or (   p_id_anagrafica is null and /*default value*/ 'default null' is not null ) -- PK nullable on insert
           or not existsId (
                             p_id_anagrafica => p_id_anagrafica
                           )
           , 'not existsId on anagrafici_tpk.ins'
           );
   insert into ANAGRAFICI
   (
     id_anagrafica
   , ni
   , dal
   , al
   , cognome
   , nome
   , sesso
   , data_nas
   , provincia_nas
   , comune_nas
   , luogo_nas
   , codice_fiscale
   , codice_fiscale_estero
   , partita_iva
   , cittadinanza
   , gruppo_ling
   , competenza
   , competenza_esclusiva
   , tipo_soggetto
   , stato_cee
   , partita_iva_cee
   , fine_validita
   , stato_soggetto
   , denominazione
   , note
   , version
   , utente
   , data_agg
   , denominazione_ricerca
   )
   values
   (
     p_id_anagrafica
, p_ni
, p_dal
, p_al
, p_cognome
, p_nome
, p_sesso
, p_data_nas
, p_provincia_nas
, p_comune_nas
, p_luogo_nas
, p_codice_fiscale
, p_codice_fiscale_estero
, p_partita_iva
, p_cittadinanza
, p_gruppo_ling
, p_competenza
, p_competenza_esclusiva
, p_tipo_soggetto
, p_stato_cee
, p_partita_iva_cee
, p_fine_validita
, nvl( p_stato_soggetto, 'U' )
, p_denominazione
, p_note
, p_version
, p_utente
, p_data_agg
, p_denominazione_ricerca
   ) returning id_anagrafica
   into d_result;
   return d_result;
end ins; -- anagrafici_tpk.ins
--------------------------------------------------------------------------------
procedure upd
(
  p_check_OLD  in integer default 0
, p_NEW_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_OLD_id_anagrafica  in ANAGRAFICI.id_anagrafica%type default null
, p_NEW_ni  in ANAGRAFICI.ni%type default afc.default_null('ANAGRAFICI.ni')
, p_OLD_ni  in ANAGRAFICI.ni%type default null
, p_NEW_dal  in ANAGRAFICI.dal%type default afc.default_null('ANAGRAFICI.dal')
, p_OLD_dal  in ANAGRAFICI.dal%type default null
, p_NEW_al  in ANAGRAFICI.al%type default afc.default_null('ANAGRAFICI.al')
, p_OLD_al  in ANAGRAFICI.al%type default null
, p_NEW_cognome  in ANAGRAFICI.cognome%type default afc.default_null('ANAGRAFICI.cognome')
, p_OLD_cognome  in ANAGRAFICI.cognome%type default null
, p_NEW_nome  in ANAGRAFICI.nome%type default afc.default_null('ANAGRAFICI.nome')
, p_OLD_nome  in ANAGRAFICI.nome%type default null
, p_NEW_sesso  in ANAGRAFICI.sesso%type default afc.default_null('ANAGRAFICI.sesso')
, p_OLD_sesso  in ANAGRAFICI.sesso%type default null
, p_NEW_data_nas  in ANAGRAFICI.data_nas%type default afc.default_null('ANAGRAFICI.data_nas')
, p_OLD_data_nas  in ANAGRAFICI.data_nas%type default null
, p_NEW_provincia_nas  in ANAGRAFICI.provincia_nas%type default afc.default_null('ANAGRAFICI.provincia_nas')
, p_OLD_provincia_nas  in ANAGRAFICI.provincia_nas%type default null
, p_NEW_comune_nas  in ANAGRAFICI.comune_nas%type default afc.default_null('ANAGRAFICI.comune_nas')
, p_OLD_comune_nas  in ANAGRAFICI.comune_nas%type default null
, p_NEW_luogo_nas  in ANAGRAFICI.luogo_nas%type default afc.default_null('ANAGRAFICI.luogo_nas')
, p_OLD_luogo_nas  in ANAGRAFICI.luogo_nas%type default null
, p_NEW_codice_fiscale  in ANAGRAFICI.codice_fiscale%type default afc.default_null('ANAGRAFICI.codice_fiscale')
, p_OLD_codice_fiscale  in ANAGRAFICI.codice_fiscale%type default null
, p_NEW_codice_fiscale_estero  in ANAGRAFICI.codice_fiscale_estero%type default afc.default_null('ANAGRAFICI.codice_fiscale_estero')
, p_OLD_codice_fiscale_estero  in ANAGRAFICI.codice_fiscale_estero%type default null
, p_NEW_partita_iva  in ANAGRAFICI.partita_iva%type default afc.default_null('ANAGRAFICI.partita_iva')
, p_OLD_partita_iva  in ANAGRAFICI.partita_iva%type default null
, p_NEW_cittadinanza  in ANAGRAFICI.cittadinanza%type default afc.default_null('ANAGRAFICI.cittadinanza')
, p_OLD_cittadinanza  in ANAGRAFICI.cittadinanza%type default null
, p_NEW_gruppo_ling  in ANAGRAFICI.gruppo_ling%type default afc.default_null('ANAGRAFICI.gruppo_ling')
, p_OLD_gruppo_ling  in ANAGRAFICI.gruppo_ling%type default null
, p_NEW_competenza  in ANAGRAFICI.competenza%type default afc.default_null('ANAGRAFICI.competenza')
, p_OLD_competenza  in ANAGRAFICI.competenza%type default null
, p_NEW_competenza_esclusiva  in ANAGRAFICI.competenza_esclusiva%type default afc.default_null('ANAGRAFICI.competenza_esclusiva')
, p_OLD_competenza_esclusiva  in ANAGRAFICI.competenza_esclusiva%type default null
, p_NEW_tipo_soggetto  in ANAGRAFICI.tipo_soggetto%type default afc.default_null('ANAGRAFICI.tipo_soggetto')
, p_OLD_tipo_soggetto  in ANAGRAFICI.tipo_soggetto%type default null
, p_NEW_stato_cee  in ANAGRAFICI.stato_cee%type default afc.default_null('ANAGRAFICI.stato_cee')
, p_OLD_stato_cee  in ANAGRAFICI.stato_cee%type default null
, p_NEW_partita_iva_cee  in ANAGRAFICI.partita_iva_cee%type default afc.default_null('ANAGRAFICI.partita_iva_cee')
, p_OLD_partita_iva_cee  in ANAGRAFICI.partita_iva_cee%type default null
, p_NEW_fine_validita  in ANAGRAFICI.fine_validita%type default afc.default_null('ANAGRAFICI.fine_validita')
, p_OLD_fine_validita  in ANAGRAFICI.fine_validita%type default null
, p_NEW_stato_soggetto  in ANAGRAFICI.stato_soggetto%type default afc.default_null('ANAGRAFICI.stato_soggetto')
, p_OLD_stato_soggetto  in ANAGRAFICI.stato_soggetto%type default null
, p_NEW_denominazione  in ANAGRAFICI.denominazione%type default afc.default_null('ANAGRAFICI.denominazione')
, p_OLD_denominazione  in ANAGRAFICI.denominazione%type default null
, p_NEW_note  in ANAGRAFICI.note%type default afc.default_null('ANAGRAFICI.note')
, p_OLD_note  in ANAGRAFICI.note%type default null
, p_NEW_version  in ANAGRAFICI.version%type default afc.default_null('ANAGRAFICI.version')
, p_OLD_version  in ANAGRAFICI.version%type default null
, p_NEW_utente  in ANAGRAFICI.utente%type default afc.default_null('ANAGRAFICI.utente')
, p_OLD_utente  in ANAGRAFICI.utente%type default null
, p_NEW_data_agg  in ANAGRAFICI.data_agg%type default afc.default_null('ANAGRAFICI.data_agg')
, p_OLD_data_agg  in ANAGRAFICI.data_agg%type default null
, p_NEW_denominazione_ricerca  in ANAGRAFICI.denominazione_ricerca%type default afc.default_null('ANAGRAFICI.denominazione_ricerca')
, p_OLD_denominazione_ricerca  in ANAGRAFICI.denominazione_ricerca%type default null
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
p_OLD_ni is not null
 or p_OLD_dal is not null
 or p_OLD_al is not null
 or p_OLD_cognome is not null
 or p_OLD_nome is not null
 or p_OLD_sesso is not null
 or p_OLD_data_nas is not null
 or p_OLD_provincia_nas is not null
 or p_OLD_comune_nas is not null
 or p_OLD_luogo_nas is not null
 or p_OLD_codice_fiscale is not null
 or p_OLD_codice_fiscale_estero is not null
 or p_OLD_partita_iva is not null
 or p_OLD_cittadinanza is not null
 or p_OLD_gruppo_ling is not null
 or p_OLD_competenza is not null
 or p_OLD_competenza_esclusiva is not null
 or p_OLD_tipo_soggetto is not null
 or p_OLD_stato_cee is not null
 or p_OLD_partita_iva_cee is not null
 or p_OLD_fine_validita is not null
 or p_OLD_stato_soggetto is not null
 or p_OLD_denominazione is not null
 or p_OLD_note is not null
 or p_OLD_version is not null
 or p_OLD_utente is not null
 or p_OLD_data_agg is not null
 or p_OLD_denominazione_ricerca is not null
                    )
                    and (  nvl( p_check_OLD, -1 ) = 0
                        )
                  )
           , ' "OLD values" is not null on anagrafici_tpk.upd'
           );
   d_key := PK ( 
                nvl( p_OLD_id_anagrafica, p_NEW_id_anagrafica )
               );
   DbC.PRE ( not DbC.PreOn or existsId ( 
                                         p_id_anagrafica => d_key.id_anagrafica
                                       )
           , 'existsId on anagrafici_tpk.upd' 
           );
   update ANAGRAFICI
   set 
       id_anagrafica = NVL( p_NEW_id_anagrafica, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.id_anagrafica' ), 1, id_anagrafica,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_id_anagrafica, null, id_anagrafica, null ) ) ) )
     , ni = NVL( p_NEW_ni, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.ni' ), 1, ni,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_ni, null, ni, null ) ) ) )
     , dal = NVL( p_NEW_dal, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.dal' ), 1, dal,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_dal, null, dal, null ) ) ) )
     , al = NVL( p_NEW_al, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.al' ), 1, al,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_al, null, al, null ) ) ) )
     , cognome = NVL( p_NEW_cognome, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.cognome' ), 1, cognome,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_cognome, null, cognome, null ) ) ) )
     , nome = NVL( p_NEW_nome, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.nome' ), 1, nome,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_nome, null, nome, null ) ) ) )
     , sesso = NVL( p_NEW_sesso, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.sesso' ), 1, sesso,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_sesso, null, sesso, null ) ) ) )
     , data_nas = NVL( p_NEW_data_nas, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.data_nas' ), 1, data_nas,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_data_nas, null, data_nas, null ) ) ) )
     , provincia_nas = NVL( p_NEW_provincia_nas, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.provincia_nas' ), 1, provincia_nas,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_provincia_nas, null, provincia_nas, null ) ) ) )
     , comune_nas = NVL( p_NEW_comune_nas, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.comune_nas' ), 1, comune_nas,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_comune_nas, null, comune_nas, null ) ) ) )
     , luogo_nas = NVL( p_NEW_luogo_nas, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.luogo_nas' ), 1, luogo_nas,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_luogo_nas, null, luogo_nas, null ) ) ) )
     , codice_fiscale = NVL( p_NEW_codice_fiscale, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.codice_fiscale' ), 1, codice_fiscale,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_codice_fiscale, null, codice_fiscale, null ) ) ) )
     , codice_fiscale_estero = NVL( p_NEW_codice_fiscale_estero, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.codice_fiscale_estero' ), 1, codice_fiscale_estero,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_codice_fiscale_estero, null, codice_fiscale_estero, null ) ) ) )
     , partita_iva = NVL( p_NEW_partita_iva, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.partita_iva' ), 1, partita_iva,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_partita_iva, null, partita_iva, null ) ) ) )
     , cittadinanza = NVL( p_NEW_cittadinanza, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.cittadinanza' ), 1, cittadinanza,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_cittadinanza, null, cittadinanza, null ) ) ) )
     , gruppo_ling = NVL( p_NEW_gruppo_ling, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.gruppo_ling' ), 1, gruppo_ling,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_gruppo_ling, null, gruppo_ling, null ) ) ) )
     , competenza = NVL( p_NEW_competenza, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.competenza' ), 1, competenza,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_competenza, null, competenza, null ) ) ) )
     , competenza_esclusiva = NVL( p_NEW_competenza_esclusiva, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.competenza_esclusiva' ), 1, competenza_esclusiva,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_competenza_esclusiva, null, competenza_esclusiva, null ) ) ) )
     , tipo_soggetto = NVL( p_NEW_tipo_soggetto, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.tipo_soggetto' ), 1, tipo_soggetto,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_tipo_soggetto, null, tipo_soggetto, null ) ) ) )
     , stato_cee = NVL( p_NEW_stato_cee, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.stato_cee' ), 1, stato_cee,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_stato_cee, null, stato_cee, null ) ) ) )
     , partita_iva_cee = NVL( p_NEW_partita_iva_cee, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.partita_iva_cee' ), 1, partita_iva_cee,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_partita_iva_cee, null, partita_iva_cee, null ) ) ) )
     , fine_validita = NVL( p_NEW_fine_validita, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.fine_validita' ), 1, fine_validita,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_fine_validita, null, fine_validita, null ) ) ) )
     , stato_soggetto = NVL( p_NEW_stato_soggetto, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.stato_soggetto' ), 1, stato_soggetto,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_stato_soggetto, null, stato_soggetto, null ) ) ) )
     , denominazione = NVL( p_NEW_denominazione, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.denominazione' ), 1, denominazione,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_denominazione, null, denominazione, null ) ) ) )
     , note = NVL( p_NEW_note, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.note' ), 1, note,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_note, null, note, null ) ) ) )
     , version = NVL( p_NEW_version, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.version' ), 1, version,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_version, null, version, null ) ) ) )
     , utente = NVL( p_NEW_utente, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.utente' ), 1, utente,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_utente, null, utente, null ) ) ) )
     , data_agg = NVL( p_NEW_data_agg, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.data_agg' ), 1, data_agg,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_data_agg, null, data_agg, null ) ) ) )
     , denominazione_ricerca = NVL( p_NEW_denominazione_ricerca, DECODE( AFC.IS_DEFAULT_NULL( 'ANAGRAFICI.denominazione_ricerca' ), 1, denominazione_ricerca,
                 DECODE( p_CHECK_OLD, 0, null, DECODE( p_OLD_denominazione_ricerca, null, denominazione_ricerca, null ) ) ) )
   where 
     id_anagrafica = d_key.id_anagrafica
   and (   p_check_OLD = 0
        or (   1 = 1
           and ( ni = p_OLD_ni or ( p_OLD_ni is null and ( p_check_OLD is null or ni is null ) ) )
           and ( dal = p_OLD_dal or ( p_OLD_dal is null and ( p_check_OLD is null or dal is null ) ) )
           and ( al = p_OLD_al or ( p_OLD_al is null and ( p_check_OLD is null or al is null ) ) )
           and ( cognome = p_OLD_cognome or ( p_OLD_cognome is null and ( p_check_OLD is null or cognome is null ) ) )
           and ( nome = p_OLD_nome or ( p_OLD_nome is null and ( p_check_OLD is null or nome is null ) ) )
           and ( sesso = p_OLD_sesso or ( p_OLD_sesso is null and ( p_check_OLD is null or sesso is null ) ) )
           and ( data_nas = p_OLD_data_nas or ( p_OLD_data_nas is null and ( p_check_OLD is null or data_nas is null ) ) )
           and ( provincia_nas = p_OLD_provincia_nas or ( p_OLD_provincia_nas is null and ( p_check_OLD is null or provincia_nas is null ) ) )
           and ( comune_nas = p_OLD_comune_nas or ( p_OLD_comune_nas is null and ( p_check_OLD is null or comune_nas is null ) ) )
           and ( luogo_nas = p_OLD_luogo_nas or ( p_OLD_luogo_nas is null and ( p_check_OLD is null or luogo_nas is null ) ) )
           and ( codice_fiscale = p_OLD_codice_fiscale or ( p_OLD_codice_fiscale is null and ( p_check_OLD is null or codice_fiscale is null ) ) )
           and ( codice_fiscale_estero = p_OLD_codice_fiscale_estero or ( p_OLD_codice_fiscale_estero is null and ( p_check_OLD is null or codice_fiscale_estero is null ) ) )
           and ( partita_iva = p_OLD_partita_iva or ( p_OLD_partita_iva is null and ( p_check_OLD is null or partita_iva is null ) ) )
           and ( cittadinanza = p_OLD_cittadinanza or ( p_OLD_cittadinanza is null and ( p_check_OLD is null or cittadinanza is null ) ) )
           and ( gruppo_ling = p_OLD_gruppo_ling or ( p_OLD_gruppo_ling is null and ( p_check_OLD is null or gruppo_ling is null ) ) )
           and ( competenza = p_OLD_competenza or ( p_OLD_competenza is null and ( p_check_OLD is null or competenza is null ) ) )
           and ( competenza_esclusiva = p_OLD_competenza_esclusiva or ( p_OLD_competenza_esclusiva is null and ( p_check_OLD is null or competenza_esclusiva is null ) ) )
           and ( tipo_soggetto = p_OLD_tipo_soggetto or ( p_OLD_tipo_soggetto is null and ( p_check_OLD is null or tipo_soggetto is null ) ) )
           and ( stato_cee = p_OLD_stato_cee or ( p_OLD_stato_cee is null and ( p_check_OLD is null or stato_cee is null ) ) )
           and ( partita_iva_cee = p_OLD_partita_iva_cee or ( p_OLD_partita_iva_cee is null and ( p_check_OLD is null or partita_iva_cee is null ) ) )
           and ( fine_validita = p_OLD_fine_validita or ( p_OLD_fine_validita is null and ( p_check_OLD is null or fine_validita is null ) ) )
           and ( stato_soggetto = p_OLD_stato_soggetto or ( p_OLD_stato_soggetto is null and ( p_check_OLD is null or stato_soggetto is null ) ) )
           and ( denominazione = p_OLD_denominazione or ( p_OLD_denominazione is null and ( p_check_OLD is null or denominazione is null ) ) )
           and ( note = p_OLD_note or ( p_OLD_note is null and ( p_check_OLD is null or note is null ) ) )
           and ( version = p_OLD_version or ( p_OLD_version is null and ( p_check_OLD is null or version is null ) ) )
           and ( utente = p_OLD_utente or ( p_OLD_utente is null and ( p_check_OLD is null or utente is null ) ) )
           and ( data_agg = p_OLD_data_agg or ( p_OLD_data_agg is null and ( p_check_OLD is null or data_agg is null ) ) )
           and ( denominazione_ricerca = p_OLD_denominazione_ricerca or ( p_OLD_denominazione_ricerca is null and ( p_check_OLD is null or denominazione_ricerca is null ) ) )
           )
       )
   ;
   d_row_found := SQL%ROWCOUNT;
   afc.default_null(NULL);
   DbC.ASSERTION ( not DbC.AssertionOn or d_row_found <= 1
                 , 'd_row_found <= 1 on anagrafici_tpk.upd'
                 );
   if d_row_found < 1
   then
      raise_application_error ( AFC_ERROR.modified_by_other_user_number
                              , AFC_ERROR.modified_by_other_user_msg
                              );
   end if;
end upd; -- anagrafici_tpk.upd
--------------------------------------------------------------------------------
procedure upd_column
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
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
                                        p_id_anagrafica => p_id_anagrafica
                                       )
           , 'existsId on anagrafici_tpk.upd_column' 
           );
   DbC.PRE ( not DbC.PreOn or p_column is not null
           , 'p_column is not null on anagrafici_tpk.upd_column'
           );
   DbC.PRE ( not DbC.PreOn or AFC_DDL.HasAttribute( s_table_name, p_column )
           , 'AFC_DDL.HasAttribute on anagrafici_tpk.upd_column'
           );
   DbC.PRE ( p_literal_value in ( 0, 1 ) or p_literal_value is null
           , 'p_literal_value on anagrafici_tpk.upd_column; p_literal_value = ' || p_literal_value
           );
   if p_literal_value = 1
   or p_literal_value is null
   then
      d_literal := '''';
   end if;
   d_statement := ' declare '
               || '    d_row_found number; '
               || ' begin '
               || '    update ANAGRAFICI '
               || '       set ' || p_column || ' = ' || d_literal || p_value || d_literal
               || '     where 1 = 1 '
               || nvl( AFC.get_field_condition( ' and ( id_anagrafica ', p_id_anagrafica, ' )', 0, null ), ' and ( id_anagrafica is null ) ' )
               || '    ; '
               || '    d_row_found := SQL%ROWCOUNT; '
               || '    if d_row_found < 1 '
               || '    then '
               || '       raise_application_error ( AFC_ERROR.modified_by_other_user_number, AFC_ERROR.modified_by_other_user_msg ); '
               || '    end if; '
               || ' end; ';
   AFC.SQL_execute( d_statement );
end upd_column; -- anagrafici_tpk.upd_column
--------------------------------------------------------------------------------
procedure upd_column
( 
p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
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
p_id_anagrafica => p_id_anagrafica
              , p_column => p_column
              , p_value => 'to_date( ''' || d_data || ''', ''' || AFC.date_format || ''' )'
              , p_literal_value => 0
              );   
end upd_column; -- anagrafici_tpk.upd_column
--------------------------------------------------------------------------------
procedure del
( 
  p_check_old  in integer default 0
, p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_ni  in ANAGRAFICI.ni%type default null
, p_dal  in ANAGRAFICI.dal%type default null
, p_al  in ANAGRAFICI.al%type default null
, p_cognome  in ANAGRAFICI.cognome%type default null
, p_nome  in ANAGRAFICI.nome%type default null
, p_sesso  in ANAGRAFICI.sesso%type default null
, p_data_nas  in ANAGRAFICI.data_nas%type default null
, p_provincia_nas  in ANAGRAFICI.provincia_nas%type default null
, p_comune_nas  in ANAGRAFICI.comune_nas%type default null
, p_luogo_nas  in ANAGRAFICI.luogo_nas%type default null
, p_codice_fiscale  in ANAGRAFICI.codice_fiscale%type default null
, p_codice_fiscale_estero  in ANAGRAFICI.codice_fiscale_estero%type default null
, p_partita_iva  in ANAGRAFICI.partita_iva%type default null
, p_cittadinanza  in ANAGRAFICI.cittadinanza%type default null
, p_gruppo_ling  in ANAGRAFICI.gruppo_ling%type default null
, p_competenza  in ANAGRAFICI.competenza%type default null
, p_competenza_esclusiva  in ANAGRAFICI.competenza_esclusiva%type default null
, p_tipo_soggetto  in ANAGRAFICI.tipo_soggetto%type default null
, p_stato_cee  in ANAGRAFICI.stato_cee%type default null
, p_partita_iva_cee  in ANAGRAFICI.partita_iva_cee%type default null
, p_fine_validita  in ANAGRAFICI.fine_validita%type default null
, p_stato_soggetto  in ANAGRAFICI.stato_soggetto%type default null
, p_denominazione  in ANAGRAFICI.denominazione%type default null
, p_note  in ANAGRAFICI.note%type default null
, p_version  in ANAGRAFICI.version%type default null
, p_utente  in ANAGRAFICI.utente%type default null
, p_data_agg  in ANAGRAFICI.data_agg%type default null
, p_denominazione_ricerca  in ANAGRAFICI.denominazione_ricerca%type default null
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
 or p_cognome is not null
 or p_nome is not null
 or p_sesso is not null
 or p_data_nas is not null
 or p_provincia_nas is not null
 or p_comune_nas is not null
 or p_luogo_nas is not null
 or p_codice_fiscale is not null
 or p_codice_fiscale_estero is not null
 or p_partita_iva is not null
 or p_cittadinanza is not null
 or p_gruppo_ling is not null
 or p_competenza is not null
 or p_competenza_esclusiva is not null
 or p_tipo_soggetto is not null
 or p_stato_cee is not null
 or p_partita_iva_cee is not null
 or p_fine_validita is not null
 or p_stato_soggetto is not null
 or p_denominazione is not null
 or p_note is not null
 or p_version is not null
 or p_utente is not null
 or p_data_agg is not null
 or p_denominazione_ricerca is not null
                    )
                    and (  nvl( p_check_OLD, -1 ) = 0
                        )
                  )
           , ' "OLD values" is not null on anagrafici_tpk.del'
           );
   DbC.PRE ( not DbC.PreOn or existsId (
                                         p_id_anagrafica => p_id_anagrafica
                                       )
           , 'existsId on anagrafici_tpk.del' 
           );
   delete from ANAGRAFICI
   where 
     id_anagrafica = p_id_anagrafica
   and (   p_check_OLD = 0
        or (   1 = 1
           and ( ni = p_ni or ( p_ni is null and ( p_check_OLD is null or ni is null ) ) )
           and ( dal = p_dal or ( p_dal is null and ( p_check_OLD is null or dal is null ) ) )
           and ( al = p_al or ( p_al is null and ( p_check_OLD is null or al is null ) ) )
           and ( cognome = p_cognome or ( p_cognome is null and ( p_check_OLD is null or cognome is null ) ) )
           and ( nome = p_nome or ( p_nome is null and ( p_check_OLD is null or nome is null ) ) )
           and ( sesso = p_sesso or ( p_sesso is null and ( p_check_OLD is null or sesso is null ) ) )
           and ( data_nas = p_data_nas or ( p_data_nas is null and ( p_check_OLD is null or data_nas is null ) ) )
           and ( provincia_nas = p_provincia_nas or ( p_provincia_nas is null and ( p_check_OLD is null or provincia_nas is null ) ) )
           and ( comune_nas = p_comune_nas or ( p_comune_nas is null and ( p_check_OLD is null or comune_nas is null ) ) )
           and ( luogo_nas = p_luogo_nas or ( p_luogo_nas is null and ( p_check_OLD is null or luogo_nas is null ) ) )
           and ( codice_fiscale = p_codice_fiscale or ( p_codice_fiscale is null and ( p_check_OLD is null or codice_fiscale is null ) ) )
           and ( codice_fiscale_estero = p_codice_fiscale_estero or ( p_codice_fiscale_estero is null and ( p_check_OLD is null or codice_fiscale_estero is null ) ) )
           and ( partita_iva = p_partita_iva or ( p_partita_iva is null and ( p_check_OLD is null or partita_iva is null ) ) )
           and ( cittadinanza = p_cittadinanza or ( p_cittadinanza is null and ( p_check_OLD is null or cittadinanza is null ) ) )
           and ( gruppo_ling = p_gruppo_ling or ( p_gruppo_ling is null and ( p_check_OLD is null or gruppo_ling is null ) ) )
           and ( competenza = p_competenza or ( p_competenza is null and ( p_check_OLD is null or competenza is null ) ) )
           and ( competenza_esclusiva = p_competenza_esclusiva or ( p_competenza_esclusiva is null and ( p_check_OLD is null or competenza_esclusiva is null ) ) )
           and ( tipo_soggetto = p_tipo_soggetto or ( p_tipo_soggetto is null and ( p_check_OLD is null or tipo_soggetto is null ) ) )
           and ( stato_cee = p_stato_cee or ( p_stato_cee is null and ( p_check_OLD is null or stato_cee is null ) ) )
           and ( partita_iva_cee = p_partita_iva_cee or ( p_partita_iva_cee is null and ( p_check_OLD is null or partita_iva_cee is null ) ) )
           and ( fine_validita = p_fine_validita or ( p_fine_validita is null and ( p_check_OLD is null or fine_validita is null ) ) )
           and ( stato_soggetto = p_stato_soggetto or ( p_stato_soggetto is null and ( p_check_OLD is null or stato_soggetto is null ) ) )
           and ( denominazione = p_denominazione or ( p_denominazione is null and ( p_check_OLD is null or denominazione is null ) ) )
           and ( note = p_note or ( p_note is null and ( p_check_OLD is null or note is null ) ) )
           and ( version = p_version or ( p_version is null and ( p_check_OLD is null or version is null ) ) )
           and ( utente = p_utente or ( p_utente is null and ( p_check_OLD is null or utente is null ) ) )
           and ( data_agg = p_data_agg or ( p_data_agg is null and ( p_check_OLD is null or data_agg is null ) ) )
           and ( denominazione_ricerca = p_denominazione_ricerca or ( p_denominazione_ricerca is null and ( p_check_OLD is null or denominazione_ricerca is null ) ) )
           )
       )
   ;
   d_row_found := SQL%ROWCOUNT;
   DbC.ASSERTION ( not DbC.AssertionOn or d_row_found <= 1
                 , 'd_row_found <= 1 on anagrafici_tpk.del'
                 );
   if d_row_found < 1
   then
      raise_application_error ( AFC_ERROR.modified_by_other_user_number
                              , AFC_ERROR.modified_by_other_user_msg
                              );
   end if;
   DbC.POST ( not DbC.PostOn or not existsId ( 
                                               p_id_anagrafica => p_id_anagrafica
                                             )
            , 'existsId on anagrafici_tpk.del' 
            );
end del; -- anagrafici_tpk.del
--------------------------------------------------------------------------------
function get_ni
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.ni%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_ni
 DESCRIZIONE: Getter per attributo ni di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.ni%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.ni%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_ni' 
           );
   select ni
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (true)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_ni'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'ni')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_ni'
                    );
   end if;
   return  d_result;
end get_ni; -- anagrafici_tpk.get_ni
--------------------------------------------------------------------------------
function get_dal
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.dal%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_dal
 DESCRIZIONE: Getter per attributo dal di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.dal%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.dal%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_dal' 
           );
   select dal
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (true)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_dal'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'dal')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_dal'
                    );
   end if;
   return  d_result;
end get_dal; -- anagrafici_tpk.get_dal
--------------------------------------------------------------------------------
function get_al
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.al%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_al
 DESCRIZIONE: Getter per attributo al di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.al%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.al%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_al' 
           );
   select al
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_al'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'al')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_al'
                    );
   end if;
   return  d_result;
end get_al; -- anagrafici_tpk.get_al
--------------------------------------------------------------------------------
function get_cognome
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.cognome%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_cognome
 DESCRIZIONE: Getter per attributo cognome di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.cognome%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.cognome%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_cognome' 
           );
   select cognome
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (true)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_cognome'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'cognome')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_cognome'
                    );
   end if;
   return  d_result;
end get_cognome; -- anagrafici_tpk.get_cognome
--------------------------------------------------------------------------------
function get_nome
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.nome%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_nome
 DESCRIZIONE: Getter per attributo nome di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.nome%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.nome%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_nome' 
           );
   select nome
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_nome'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'nome')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_nome'
                    );
   end if;
   return  d_result;
end get_nome; -- anagrafici_tpk.get_nome
--------------------------------------------------------------------------------
function get_sesso
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.sesso%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_sesso
 DESCRIZIONE: Getter per attributo sesso di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.sesso%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.sesso%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_sesso' 
           );
   select sesso
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_sesso'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'sesso')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_sesso'
                    );
   end if;
   return  d_result;
end get_sesso; -- anagrafici_tpk.get_sesso
--------------------------------------------------------------------------------
function get_data_nas
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.data_nas%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_data_nas
 DESCRIZIONE: Getter per attributo data_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.data_nas%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.data_nas%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_data_nas' 
           );
   select data_nas
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_data_nas'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'data_nas')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_data_nas'
                    );
   end if;
   return  d_result;
end get_data_nas; -- anagrafici_tpk.get_data_nas
--------------------------------------------------------------------------------
function get_provincia_nas
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.provincia_nas%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_provincia_nas
 DESCRIZIONE: Getter per attributo provincia_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.provincia_nas%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.provincia_nas%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_provincia_nas' 
           );
   select provincia_nas
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_provincia_nas'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'provincia_nas')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_provincia_nas'
                    );
   end if;
   return  d_result;
end get_provincia_nas; -- anagrafici_tpk.get_provincia_nas
--------------------------------------------------------------------------------
function get_comune_nas
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.comune_nas%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_comune_nas
 DESCRIZIONE: Getter per attributo comune_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.comune_nas%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.comune_nas%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_comune_nas' 
           );
   select comune_nas
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_comune_nas'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'comune_nas')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_comune_nas'
                    );
   end if;
   return  d_result;
end get_comune_nas; -- anagrafici_tpk.get_comune_nas
--------------------------------------------------------------------------------
function get_luogo_nas
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.luogo_nas%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_luogo_nas
 DESCRIZIONE: Getter per attributo luogo_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.luogo_nas%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.luogo_nas%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_luogo_nas' 
           );
   select luogo_nas
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_luogo_nas'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'luogo_nas')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_luogo_nas'
                    );
   end if;
   return  d_result;
end get_luogo_nas; -- anagrafici_tpk.get_luogo_nas
--------------------------------------------------------------------------------
function get_codice_fiscale
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.codice_fiscale%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_codice_fiscale
 DESCRIZIONE: Getter per attributo codice_fiscale di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.codice_fiscale%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.codice_fiscale%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_codice_fiscale' 
           );
   select codice_fiscale
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_codice_fiscale'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'codice_fiscale')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_codice_fiscale'
                    );
   end if;
   return  d_result;
end get_codice_fiscale; -- anagrafici_tpk.get_codice_fiscale
--------------------------------------------------------------------------------
function get_codice_fiscale_estero
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.codice_fiscale_estero%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_codice_fiscale_estero
 DESCRIZIONE: Getter per attributo codice_fiscale_estero di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.codice_fiscale_estero%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.codice_fiscale_estero%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_codice_fiscale_estero' 
           );
   select codice_fiscale_estero
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_codice_fiscale_estero'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'codice_fiscale_estero')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_codice_fiscale_estero'
                    );
   end if;
   return  d_result;
end get_codice_fiscale_estero; -- anagrafici_tpk.get_codice_fiscale_estero
--------------------------------------------------------------------------------
function get_partita_iva
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.partita_iva%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_partita_iva
 DESCRIZIONE: Getter per attributo partita_iva di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.partita_iva%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.partita_iva%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_partita_iva' 
           );
   select partita_iva
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_partita_iva'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'partita_iva')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_partita_iva'
                    );
   end if;
   return  d_result;
end get_partita_iva; -- anagrafici_tpk.get_partita_iva
--------------------------------------------------------------------------------
function get_cittadinanza
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.cittadinanza%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_cittadinanza
 DESCRIZIONE: Getter per attributo cittadinanza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.cittadinanza%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.cittadinanza%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_cittadinanza' 
           );
   select cittadinanza
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_cittadinanza'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'cittadinanza')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_cittadinanza'
                    );
   end if;
   return  d_result;
end get_cittadinanza; -- anagrafici_tpk.get_cittadinanza
--------------------------------------------------------------------------------
function get_gruppo_ling
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.gruppo_ling%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_gruppo_ling
 DESCRIZIONE: Getter per attributo gruppo_ling di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.gruppo_ling%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.gruppo_ling%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_gruppo_ling' 
           );
   select gruppo_ling
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_gruppo_ling'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'gruppo_ling')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_gruppo_ling'
                    );
   end if;
   return  d_result;
end get_gruppo_ling; -- anagrafici_tpk.get_gruppo_ling
--------------------------------------------------------------------------------
function get_competenza
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.competenza%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_competenza
 DESCRIZIONE: Getter per attributo competenza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.competenza%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.competenza%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_competenza' 
           );
   select competenza
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_competenza'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'competenza')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_competenza'
                    );
   end if;
   return  d_result;
end get_competenza; -- anagrafici_tpk.get_competenza
--------------------------------------------------------------------------------
function get_competenza_esclusiva
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.competenza_esclusiva%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_competenza_esclusiva
 DESCRIZIONE: Getter per attributo competenza_esclusiva di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.competenza_esclusiva%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.competenza_esclusiva%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_competenza_esclusiva' 
           );
   select competenza_esclusiva
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_competenza_esclusiva'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'competenza_esclusiva')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_competenza_esclusiva'
                    );
   end if;
   return  d_result;
end get_competenza_esclusiva; -- anagrafici_tpk.get_competenza_esclusiva
--------------------------------------------------------------------------------
function get_tipo_soggetto
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.tipo_soggetto%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_tipo_soggetto
 DESCRIZIONE: Getter per attributo tipo_soggetto di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.tipo_soggetto%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.tipo_soggetto%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_tipo_soggetto' 
           );
   select tipo_soggetto
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_tipo_soggetto'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'tipo_soggetto')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_tipo_soggetto'
                    );
   end if;
   return  d_result;
end get_tipo_soggetto; -- anagrafici_tpk.get_tipo_soggetto
--------------------------------------------------------------------------------
function get_stato_cee
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.stato_cee%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_stato_cee
 DESCRIZIONE: Getter per attributo stato_cee di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.stato_cee%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.stato_cee%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_stato_cee' 
           );
   select stato_cee
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_stato_cee'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'stato_cee')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_stato_cee'
                    );
   end if;
   return  d_result;
end get_stato_cee; -- anagrafici_tpk.get_stato_cee
--------------------------------------------------------------------------------
function get_partita_iva_cee
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.partita_iva_cee%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_partita_iva_cee
 DESCRIZIONE: Getter per attributo partita_iva_cee di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.partita_iva_cee%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.partita_iva_cee%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_partita_iva_cee' 
           );
   select partita_iva_cee
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_partita_iva_cee'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'partita_iva_cee')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_partita_iva_cee'
                    );
   end if;
   return  d_result;
end get_partita_iva_cee; -- anagrafici_tpk.get_partita_iva_cee
--------------------------------------------------------------------------------
function get_fine_validita
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.fine_validita%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_fine_validita
 DESCRIZIONE: Getter per attributo fine_validita di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.fine_validita%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.fine_validita%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_fine_validita' 
           );
   select fine_validita
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_fine_validita'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'fine_validita')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_fine_validita'
                    );
   end if;
   return  d_result;
end get_fine_validita; -- anagrafici_tpk.get_fine_validita
--------------------------------------------------------------------------------
function get_stato_soggetto
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.stato_soggetto%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_stato_soggetto
 DESCRIZIONE: Getter per attributo stato_soggetto di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.stato_soggetto%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.stato_soggetto%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_stato_soggetto' 
           );
   select stato_soggetto
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (true)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_stato_soggetto'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'stato_soggetto')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_stato_soggetto'
                    );
   end if;
   return  d_result;
end get_stato_soggetto; -- anagrafici_tpk.get_stato_soggetto
--------------------------------------------------------------------------------
function get_denominazione
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.denominazione%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_denominazione
 DESCRIZIONE: Getter per attributo denominazione di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.denominazione%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.denominazione%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_denominazione' 
           );
   select denominazione
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_denominazione'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'denominazione')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_denominazione'
                    );
   end if;
   return  d_result;
end get_denominazione; -- anagrafici_tpk.get_denominazione
--------------------------------------------------------------------------------
function get_note
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.note%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_note
 DESCRIZIONE: Getter per attributo note di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.note%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.note%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_note' 
           );
   select note
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_note'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'note')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_note'
                    );
   end if;
   return  d_result;
end get_note; -- anagrafici_tpk.get_note
--------------------------------------------------------------------------------
function get_version
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.version%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_version
 DESCRIZIONE: Getter per attributo version di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.version%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.version%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_version' 
           );
   select version
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_version'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'version')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_version'
                    );
   end if;
   return  d_result;
end get_version; -- anagrafici_tpk.get_version
--------------------------------------------------------------------------------
function get_utente
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.utente%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_utente
 DESCRIZIONE: Getter per attributo utente di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.utente%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.utente%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_utente' 
           );
   select utente
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_utente'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'utente')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_utente'
                    );
   end if;
   return  d_result;
end get_utente; -- anagrafici_tpk.get_utente
--------------------------------------------------------------------------------
function get_data_agg
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.data_agg%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_data_agg
 DESCRIZIONE: Getter per attributo data_agg di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.data_agg%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.data_agg%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_data_agg' 
           );
   select data_agg
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_data_agg'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'data_agg')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_data_agg'
                    );
   end if;
   return  d_result;
end get_data_agg; -- anagrafici_tpk.get_data_agg
--------------------------------------------------------------------------------
function get_denominazione_ricerca
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
) return ANAGRAFICI.denominazione_ricerca%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_denominazione_ricerca
 DESCRIZIONE: Getter per attributo denominazione_ricerca di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFICI.denominazione_ricerca%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFICI.denominazione_ricerca%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.get_denominazione_ricerca' 
           );
   select denominazione_ricerca
   into   d_result
   from   ANAGRAFICI
   where  
   id_anagrafica = p_id_anagrafica
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafici_tpk.get_denominazione_ricerca'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'denominazione_ricerca')
                    , ' AFC_DDL.IsNullable on anagrafici_tpk.get_denominazione_ricerca'
                    );
   end if;
   return  d_result;
end get_denominazione_ricerca; -- anagrafici_tpk.get_denominazione_ricerca
--------------------------------------------------------------------------------
procedure set_id_anagrafica
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.id_anagrafica%type default null
) is
/******************************************************************************
 NOME:        set_id_anagrafica
 DESCRIZIONE: Setter per attributo id_anagrafica di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_id_anagrafica' 
           );
   update ANAGRAFICI
   set id_anagrafica = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_id_anagrafica; -- anagrafici_tpk.set_id_anagrafica
--------------------------------------------------------------------------------
procedure set_ni
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.ni%type default null
) is
/******************************************************************************
 NOME:        set_ni
 DESCRIZIONE: Setter per attributo ni di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_ni' 
           );
   update ANAGRAFICI
   set ni = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_ni; -- anagrafici_tpk.set_ni
--------------------------------------------------------------------------------
procedure set_dal
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.dal%type default null
) is
/******************************************************************************
 NOME:        set_dal
 DESCRIZIONE: Setter per attributo dal di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_dal' 
           );
   update ANAGRAFICI
   set dal = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_dal; -- anagrafici_tpk.set_dal
--------------------------------------------------------------------------------
procedure set_al
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.al%type default null
) is
/******************************************************************************
 NOME:        set_al
 DESCRIZIONE: Setter per attributo al di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_al' 
           );
   update ANAGRAFICI
   set al = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_al; -- anagrafici_tpk.set_al
--------------------------------------------------------------------------------
procedure set_cognome
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.cognome%type default null
) is
/******************************************************************************
 NOME:        set_cognome
 DESCRIZIONE: Setter per attributo cognome di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_cognome' 
           );
   update ANAGRAFICI
   set cognome = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_cognome; -- anagrafici_tpk.set_cognome
--------------------------------------------------------------------------------
procedure set_nome
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.nome%type default null
) is
/******************************************************************************
 NOME:        set_nome
 DESCRIZIONE: Setter per attributo nome di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_nome' 
           );
   update ANAGRAFICI
   set nome = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_nome; -- anagrafici_tpk.set_nome
--------------------------------------------------------------------------------
procedure set_sesso
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.sesso%type default null
) is
/******************************************************************************
 NOME:        set_sesso
 DESCRIZIONE: Setter per attributo sesso di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_sesso' 
           );
   update ANAGRAFICI
   set sesso = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_sesso; -- anagrafici_tpk.set_sesso
--------------------------------------------------------------------------------
procedure set_data_nas
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.data_nas%type default null
) is
/******************************************************************************
 NOME:        set_data_nas
 DESCRIZIONE: Setter per attributo data_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_data_nas' 
           );
   update ANAGRAFICI
   set data_nas = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_data_nas; -- anagrafici_tpk.set_data_nas
--------------------------------------------------------------------------------
procedure set_provincia_nas
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.provincia_nas%type default null
) is
/******************************************************************************
 NOME:        set_provincia_nas
 DESCRIZIONE: Setter per attributo provincia_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_provincia_nas' 
           );
   update ANAGRAFICI
   set provincia_nas = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_provincia_nas; -- anagrafici_tpk.set_provincia_nas
--------------------------------------------------------------------------------
procedure set_comune_nas
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.comune_nas%type default null
) is
/******************************************************************************
 NOME:        set_comune_nas
 DESCRIZIONE: Setter per attributo comune_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_comune_nas' 
           );
   update ANAGRAFICI
   set comune_nas = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_comune_nas; -- anagrafici_tpk.set_comune_nas
--------------------------------------------------------------------------------
procedure set_luogo_nas
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.luogo_nas%type default null
) is
/******************************************************************************
 NOME:        set_luogo_nas
 DESCRIZIONE: Setter per attributo luogo_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_luogo_nas' 
           );
   update ANAGRAFICI
   set luogo_nas = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_luogo_nas; -- anagrafici_tpk.set_luogo_nas
--------------------------------------------------------------------------------
procedure set_codice_fiscale
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.codice_fiscale%type default null
) is
/******************************************************************************
 NOME:        set_codice_fiscale
 DESCRIZIONE: Setter per attributo codice_fiscale di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_codice_fiscale' 
           );
   update ANAGRAFICI
   set codice_fiscale = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_codice_fiscale; -- anagrafici_tpk.set_codice_fiscale
--------------------------------------------------------------------------------
procedure set_codice_fiscale_estero
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.codice_fiscale_estero%type default null
) is
/******************************************************************************
 NOME:        set_codice_fiscale_estero
 DESCRIZIONE: Setter per attributo codice_fiscale_estero di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_codice_fiscale_estero' 
           );
   update ANAGRAFICI
   set codice_fiscale_estero = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_codice_fiscale_estero; -- anagrafici_tpk.set_codice_fiscale_estero
--------------------------------------------------------------------------------
procedure set_partita_iva
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.partita_iva%type default null
) is
/******************************************************************************
 NOME:        set_partita_iva
 DESCRIZIONE: Setter per attributo partita_iva di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_partita_iva' 
           );
   update ANAGRAFICI
   set partita_iva = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_partita_iva; -- anagrafici_tpk.set_partita_iva
--------------------------------------------------------------------------------
procedure set_cittadinanza
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.cittadinanza%type default null
) is
/******************************************************************************
 NOME:        set_cittadinanza
 DESCRIZIONE: Setter per attributo cittadinanza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_cittadinanza' 
           );
   update ANAGRAFICI
   set cittadinanza = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_cittadinanza; -- anagrafici_tpk.set_cittadinanza
--------------------------------------------------------------------------------
procedure set_gruppo_ling
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.gruppo_ling%type default null
) is
/******************************************************************************
 NOME:        set_gruppo_ling
 DESCRIZIONE: Setter per attributo gruppo_ling di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_gruppo_ling' 
           );
   update ANAGRAFICI
   set gruppo_ling = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_gruppo_ling; -- anagrafici_tpk.set_gruppo_ling
--------------------------------------------------------------------------------
procedure set_competenza
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.competenza%type default null
) is
/******************************************************************************
 NOME:        set_competenza
 DESCRIZIONE: Setter per attributo competenza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_competenza' 
           );
   update ANAGRAFICI
   set competenza = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_competenza; -- anagrafici_tpk.set_competenza
--------------------------------------------------------------------------------
procedure set_competenza_esclusiva
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.competenza_esclusiva%type default null
) is
/******************************************************************************
 NOME:        set_competenza_esclusiva
 DESCRIZIONE: Setter per attributo competenza_esclusiva di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_competenza_esclusiva' 
           );
   update ANAGRAFICI
   set competenza_esclusiva = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_competenza_esclusiva; -- anagrafici_tpk.set_competenza_esclusiva
--------------------------------------------------------------------------------
procedure set_tipo_soggetto
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.tipo_soggetto%type default null
) is
/******************************************************************************
 NOME:        set_tipo_soggetto
 DESCRIZIONE: Setter per attributo tipo_soggetto di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_tipo_soggetto' 
           );
   update ANAGRAFICI
   set tipo_soggetto = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_tipo_soggetto; -- anagrafici_tpk.set_tipo_soggetto
--------------------------------------------------------------------------------
procedure set_stato_cee
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.stato_cee%type default null
) is
/******************************************************************************
 NOME:        set_stato_cee
 DESCRIZIONE: Setter per attributo stato_cee di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_stato_cee' 
           );
   update ANAGRAFICI
   set stato_cee = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_stato_cee; -- anagrafici_tpk.set_stato_cee
--------------------------------------------------------------------------------
procedure set_partita_iva_cee
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.partita_iva_cee%type default null
) is
/******************************************************************************
 NOME:        set_partita_iva_cee
 DESCRIZIONE: Setter per attributo partita_iva_cee di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_partita_iva_cee' 
           );
   update ANAGRAFICI
   set partita_iva_cee = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_partita_iva_cee; -- anagrafici_tpk.set_partita_iva_cee
--------------------------------------------------------------------------------
procedure set_fine_validita
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.fine_validita%type default null
) is
/******************************************************************************
 NOME:        set_fine_validita
 DESCRIZIONE: Setter per attributo fine_validita di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_fine_validita' 
           );
   update ANAGRAFICI
   set fine_validita = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_fine_validita; -- anagrafici_tpk.set_fine_validita
--------------------------------------------------------------------------------
procedure set_stato_soggetto
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.stato_soggetto%type default null
) is
/******************************************************************************
 NOME:        set_stato_soggetto
 DESCRIZIONE: Setter per attributo stato_soggetto di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_stato_soggetto' 
           );
   update ANAGRAFICI
   set stato_soggetto = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_stato_soggetto; -- anagrafici_tpk.set_stato_soggetto
--------------------------------------------------------------------------------
procedure set_denominazione
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.denominazione%type default null
) is
/******************************************************************************
 NOME:        set_denominazione
 DESCRIZIONE: Setter per attributo denominazione di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_denominazione' 
           );
   update ANAGRAFICI
   set denominazione = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_denominazione; -- anagrafici_tpk.set_denominazione
--------------------------------------------------------------------------------
procedure set_note
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.note%type default null
) is
/******************************************************************************
 NOME:        set_note
 DESCRIZIONE: Setter per attributo note di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_note' 
           );
   update ANAGRAFICI
   set note = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_note; -- anagrafici_tpk.set_note
--------------------------------------------------------------------------------
procedure set_version
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.version%type default null
) is
/******************************************************************************
 NOME:        set_version
 DESCRIZIONE: Setter per attributo version di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_version' 
           );
   update ANAGRAFICI
   set version = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_version; -- anagrafici_tpk.set_version
--------------------------------------------------------------------------------
procedure set_utente
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.utente%type default null
) is
/******************************************************************************
 NOME:        set_utente
 DESCRIZIONE: Setter per attributo utente di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_utente' 
           );
   update ANAGRAFICI
   set utente = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_utente; -- anagrafici_tpk.set_utente
--------------------------------------------------------------------------------
procedure set_data_agg
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.data_agg%type default null
) is
/******************************************************************************
 NOME:        set_data_agg
 DESCRIZIONE: Setter per attributo data_agg di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_data_agg' 
           );
   update ANAGRAFICI
   set data_agg = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_data_agg; -- anagrafici_tpk.set_data_agg
--------------------------------------------------------------------------------
procedure set_denominazione_ricerca
( 
  p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_value  in ANAGRAFICI.denominazione_ricerca%type default null
) is
/******************************************************************************
 NOME:        set_denominazione_ricerca
 DESCRIZIONE: Setter per attributo denominazione_ricerca di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId ( 
                                          p_id_anagrafica => p_id_anagrafica
                                        )
           , 'existsId on anagrafici_tpk.set_denominazione_ricerca' 
           );
   update ANAGRAFICI
   set denominazione_ricerca = p_value
   where
   id_anagrafica = p_id_anagrafica
   ;
end set_denominazione_ricerca; -- anagrafici_tpk.set_denominazione_ricerca
--------------------------------------------------------------------------------
function where_condition /* SLAVE_COPY */
( p_QBE  in number default 0
, p_other_condition in varchar2 default null
, p_id_anagrafica  in varchar2 default null
, p_ni  in varchar2 default null
, p_dal  in varchar2 default null
, p_al  in varchar2 default null
, p_cognome  in varchar2 default null
, p_nome  in varchar2 default null
, p_sesso  in varchar2 default null
, p_data_nas  in varchar2 default null
, p_provincia_nas  in varchar2 default null
, p_comune_nas  in varchar2 default null
, p_luogo_nas  in varchar2 default null
, p_codice_fiscale  in varchar2 default null
, p_codice_fiscale_estero  in varchar2 default null
, p_partita_iva  in varchar2 default null
, p_cittadinanza  in varchar2 default null
, p_gruppo_ling  in varchar2 default null
, p_competenza  in varchar2 default null
, p_competenza_esclusiva  in varchar2 default null
, p_tipo_soggetto  in varchar2 default null
, p_stato_cee  in varchar2 default null
, p_partita_iva_cee  in varchar2 default null
, p_fine_validita  in varchar2 default null
, p_stato_soggetto  in varchar2 default null
, p_denominazione  in varchar2 default null
, p_note  in varchar2 default null
, p_version  in varchar2 default null
, p_utente  in varchar2 default null
, p_data_agg  in varchar2 default null
, p_denominazione_ricerca  in varchar2 default null
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
               || AFC.get_field_condition( ' and ( id_anagrafica ', p_id_anagrafica, ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( ni ', p_ni , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( dal ', p_dal , ' )', p_QBE, AFC.date_format )
               || AFC.get_field_condition( ' and ( al ', p_al , ' )', p_QBE, AFC.date_format )
               || AFC.get_field_condition( ' and ( cognome ', p_cognome , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( nome ', p_nome , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( sesso ', p_sesso , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( data_nas ', p_data_nas , ' )', p_QBE, AFC.date_format )
               || AFC.get_field_condition( ' and ( provincia_nas ', p_provincia_nas , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( comune_nas ', p_comune_nas , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( luogo_nas ', p_luogo_nas , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( codice_fiscale ', p_codice_fiscale , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( codice_fiscale_estero ', p_codice_fiscale_estero , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( partita_iva ', p_partita_iva , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( cittadinanza ', p_cittadinanza , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( gruppo_ling ', p_gruppo_ling , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( competenza ', p_competenza , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( competenza_esclusiva ', p_competenza_esclusiva , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( tipo_soggetto ', p_tipo_soggetto , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( stato_cee ', p_stato_cee , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( partita_iva_cee ', p_partita_iva_cee , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( fine_validita ', p_fine_validita , ' )', p_QBE, AFC.date_format )
               || AFC.get_field_condition( ' and ( stato_soggetto ', p_stato_soggetto , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( denominazione ', p_denominazione , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( note ', p_note , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( version ', p_version , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( utente ', p_utente , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( data_agg ', p_data_agg , ' )', p_QBE, AFC.date_format )
               || AFC.get_field_condition( ' and ( denominazione_ricerca ', p_denominazione_ricerca , ' )', p_QBE, null )
               || ' ) ' || p_other_condition
               ;
   return d_statement;
end where_condition; --- anagrafici_tpk.where_condition
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
, p_id_anagrafica  in varchar2 default null
, p_ni  in varchar2 default null
, p_dal  in varchar2 default null
, p_al  in varchar2 default null
, p_cognome  in varchar2 default null
, p_nome  in varchar2 default null
, p_sesso  in varchar2 default null
, p_data_nas  in varchar2 default null
, p_provincia_nas  in varchar2 default null
, p_comune_nas  in varchar2 default null
, p_luogo_nas  in varchar2 default null
, p_codice_fiscale  in varchar2 default null
, p_codice_fiscale_estero  in varchar2 default null
, p_partita_iva  in varchar2 default null
, p_cittadinanza  in varchar2 default null
, p_gruppo_ling  in varchar2 default null
, p_competenza  in varchar2 default null
, p_competenza_esclusiva  in varchar2 default null
, p_tipo_soggetto  in varchar2 default null
, p_stato_cee  in varchar2 default null
, p_partita_iva_cee  in varchar2 default null
, p_fine_validita  in varchar2 default null
, p_stato_soggetto  in varchar2 default null
, p_denominazione  in varchar2 default null
, p_note  in varchar2 default null
, p_version  in varchar2 default null
, p_utente  in varchar2 default null
, p_data_agg  in varchar2 default null
, p_denominazione_ricerca  in varchar2 default null
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
               || 'select ' || nvl(p_columns,'ANAGRAFICI.*') || ' '
               || afc.decode_value( p_extra_columns, null, null, ' , ' || p_extra_columns )
               || ' from ANAGRAFICI '
               || where_condition( 
                                   p_QBE => p_QBE
                                 , p_other_condition => p_extra_condition || ' ' || p_other_condition
                                 , p_id_anagrafica => p_id_anagrafica
                                 , p_ni => p_ni
                                 , p_dal => p_dal
                                 , p_al => p_al
                                 , p_cognome => p_cognome
                                 , p_nome => p_nome
                                 , p_sesso => p_sesso
                                 , p_data_nas => p_data_nas
                                 , p_provincia_nas => p_provincia_nas
                                 , p_comune_nas => p_comune_nas
                                 , p_luogo_nas => p_luogo_nas
                                 , p_codice_fiscale => p_codice_fiscale
                                 , p_codice_fiscale_estero => p_codice_fiscale_estero
                                 , p_partita_iva => p_partita_iva
                                 , p_cittadinanza => p_cittadinanza
                                 , p_gruppo_ling => p_gruppo_ling
                                 , p_competenza => p_competenza
                                 , p_competenza_esclusiva => p_competenza_esclusiva
                                 , p_tipo_soggetto => p_tipo_soggetto
                                 , p_stato_cee => p_stato_cee
                                 , p_partita_iva_cee => p_partita_iva_cee
                                 , p_fine_validita => p_fine_validita
                                 , p_stato_soggetto => p_stato_soggetto
                                 , p_denominazione => p_denominazione
                                 , p_note => p_note
                                 , p_version => p_version
                                 , p_utente => p_utente
                                 , p_data_agg => p_data_agg
                                 , p_denominazione_ricerca => p_denominazione_ricerca
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
end get_rows; -- anagrafici_tpk.get_rows
--------------------------------------------------------------------------------
function count_rows
( p_QBE  in number default 0
, p_other_condition in varchar2 default null
, p_extra_condition in varchar2 default null
, p_columns in varchar2 default null
, p_id_anagrafica  in varchar2 default null
, p_ni  in varchar2 default null
, p_dal  in varchar2 default null
, p_al  in varchar2 default null
, p_cognome  in varchar2 default null
, p_nome  in varchar2 default null
, p_sesso  in varchar2 default null
, p_data_nas  in varchar2 default null
, p_provincia_nas  in varchar2 default null
, p_comune_nas  in varchar2 default null
, p_luogo_nas  in varchar2 default null
, p_codice_fiscale  in varchar2 default null
, p_codice_fiscale_estero  in varchar2 default null
, p_partita_iva  in varchar2 default null
, p_cittadinanza  in varchar2 default null
, p_gruppo_ling  in varchar2 default null
, p_competenza  in varchar2 default null
, p_competenza_esclusiva  in varchar2 default null
, p_tipo_soggetto  in varchar2 default null
, p_stato_cee  in varchar2 default null
, p_partita_iva_cee  in varchar2 default null
, p_fine_validita  in varchar2 default null
, p_stato_soggetto  in varchar2 default null
, p_denominazione  in varchar2 default null
, p_note  in varchar2 default null
, p_version  in varchar2 default null
, p_utente  in varchar2 default null
, p_data_agg  in varchar2 default null
, p_denominazione_ricerca  in varchar2 default null
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
               || ' ANAGRAFICI '
               || where_condition( 
                                   p_QBE => p_QBE
                                 , p_other_condition => p_extra_condition || ' ' || p_other_condition
                                 , p_id_anagrafica => p_id_anagrafica
                                 , p_ni => p_ni
                                 , p_dal => p_dal
                                 , p_al => p_al
                                 , p_cognome => p_cognome
                                 , p_nome => p_nome
                                 , p_sesso => p_sesso
                                 , p_data_nas => p_data_nas
                                 , p_provincia_nas => p_provincia_nas
                                 , p_comune_nas => p_comune_nas
                                 , p_luogo_nas => p_luogo_nas
                                 , p_codice_fiscale => p_codice_fiscale
                                 , p_codice_fiscale_estero => p_codice_fiscale_estero
                                 , p_partita_iva => p_partita_iva
                                 , p_cittadinanza => p_cittadinanza
                                 , p_gruppo_ling => p_gruppo_ling
                                 , p_competenza => p_competenza
                                 , p_competenza_esclusiva => p_competenza_esclusiva
                                 , p_tipo_soggetto => p_tipo_soggetto
                                 , p_stato_cee => p_stato_cee
                                 , p_partita_iva_cee => p_partita_iva_cee
                                 , p_fine_validita => p_fine_validita
                                 , p_stato_soggetto => p_stato_soggetto
                                 , p_denominazione => p_denominazione
                                 , p_note => p_note
                                 , p_version => p_version
                                 , p_utente => p_utente
                                 , p_data_agg => p_data_agg
                                 , p_denominazione_ricerca => p_denominazione_ricerca
                                 )
               || case 
                  when p_columns is null then ''
                  else ' ) '
                  end
               ;
   d_result := AFC.SQL_execute( d_statement );
   return d_result;
end count_rows; -- anagrafici_tpk.count_rows
--------------------------------------------------------------------------------
         
end anagrafici_tpk;
/

