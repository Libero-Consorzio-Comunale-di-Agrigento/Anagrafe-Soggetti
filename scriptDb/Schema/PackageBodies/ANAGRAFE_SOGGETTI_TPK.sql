CREATE OR REPLACE PACKAGE BODY anagrafe_soggetti_tpk is
/******************************************************************************
 NOME:        anagrafe_soggetti_tpk
 DESCRIZIONE: Gestione tabella ANAGRAFE_SOGGETTI.
 ANNOTAZIONI: .
 REVISIONI:   .
 Rev.  Data        Autore  Descrizione.
 000   29/10/2012  snegroni  Prima emissione.
 001  14/11/2012   snegroni Aggiunto parametro per version per grails
 002  01/08/2013   snegroni Corretto errore in aggiornamento soggetto
 003  22/12/2017 SN  MODIFICATA x gestire i valori con gli apici
******************************************************************************/
   s_revisione_body      constant AFC.t_revision := '003';
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
end versione; -- anagrafe_soggetti_tpk.versione
--------------------------------------------------------------------------------
function PK
(
 p_ni  in ANAGRAFE_SOGGETTI.ni%type,
p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return t_PK is /* SLAVE_COPY */
/******************************************************************************
 NOME:        PK
 DESCRIZIONE: Costruttore di un t_PK dati gli attributi della chiave
******************************************************************************/
   d_result t_PK;
begin
   d_result.ni := p_ni;
d_result.dal := p_dal;
   DbC.PRE ( not DbC.PreOn or canHandle (
                                          p_ni => d_result.ni,
p_dal => d_result.dal
                                        )
           , 'canHandle on anagrafe_soggetti_tpk.PK'
           );
   return  d_result;
end PK; -- anagrafe_soggetti_tpk.PK
--------------------------------------------------------------------------------
function can_handle
(
 p_ni  in ANAGRAFE_SOGGETTI.ni%type,
p_dal  in ANAGRAFE_SOGGETTI.dal%type
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
or p_dal is null
       )
   then
      d_result := 0;
   end if;
   DbC.POST ( d_result = 1  or  d_result = 0
            , 'd_result = 1  or  d_result = 0 on anagrafe_soggetti_tpk.can_handle'
            );
   return  d_result;
end can_handle; -- anagrafe_soggetti_tpk.can_handle
--------------------------------------------------------------------------------
function canHandle
(
 p_ni  in ANAGRAFE_SOGGETTI.ni%type,
p_dal  in ANAGRAFE_SOGGETTI.dal%type
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
,p_dal => p_dal
                                                            )
                                               );
begin
   return  d_result;
end canHandle; -- anagrafe_soggetti_tpk.canHandle
--------------------------------------------------------------------------------
function exists_id
(
 p_ni  in ANAGRAFE_SOGGETTI.ni%type,
p_dal  in ANAGRAFE_SOGGETTI.dal%type
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
,p_dal => p_dal
                                        )
           , 'canHandle on anagrafe_soggetti_tpk.exists_id'
           );
   begin
      select 1
      into   d_result
      from   ANAGRAFE_SOGGETTI
      where
      ni = p_ni
and dal = p_dal
      ;
   exception
      when no_data_found then
         d_result := 0;
   end;
   DbC.POST ( d_result = 1  or  d_result = 0
            , 'd_result = 1  or  d_result = 0 on anagrafe_soggetti_tpk.exists_id'
            );
   return  d_result;
end exists_id; -- anagrafe_soggetti_tpk.exists_id
--------------------------------------------------------------------------------
function existsId
(
 p_ni  in ANAGRAFE_SOGGETTI.ni%type,
p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return boolean is /* SLAVE_COPY */
/******************************************************************************
 NOME:        existsId
 DESCRIZIONE: Esistenza riga con chiave indicata.
 NOTE:        Wrapper boolean di exists_id (cfr. exists_id).
******************************************************************************/
   d_result constant boolean := AFC.to_boolean ( exists_id (
                                                            p_ni => p_ni
,p_dal => p_dal
                                                           )
                                               );
begin
   return  d_result;
end existsId; -- anagrafe_soggetti_tpk.existsId
--------------------------------------------------------------------------------
procedure ins
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type default null
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_cognome  in ANAGRAFE_SOGGETTI.cognome%type
, p_nome  in ANAGRAFE_SOGGETTI.nome%type default null
, p_sesso  in ANAGRAFE_SOGGETTI.sesso%type default null
, p_data_nas  in ANAGRAFE_SOGGETTI.data_nas%type default null
, p_provincia_nas  in ANAGRAFE_SOGGETTI.provincia_nas%type default null
, p_comune_nas  in ANAGRAFE_SOGGETTI.comune_nas%type default null
, p_luogo_nas  in ANAGRAFE_SOGGETTI.luogo_nas%type default null
, p_codice_fiscale  in ANAGRAFE_SOGGETTI.codice_fiscale%type default null
, p_codice_fiscale_estero  in ANAGRAFE_SOGGETTI.codice_fiscale_estero%type default null
, p_partita_iva  in ANAGRAFE_SOGGETTI.partita_iva%type default null
, p_cittadinanza  in ANAGRAFE_SOGGETTI.cittadinanza%type default null
, p_gruppo_ling  in ANAGRAFE_SOGGETTI.gruppo_ling%type default null
, p_indirizzo_res  in ANAGRAFE_SOGGETTI.indirizzo_res%type default null
, p_provincia_res  in ANAGRAFE_SOGGETTI.provincia_res%type default null
, p_comune_res  in ANAGRAFE_SOGGETTI.comune_res%type default null
, p_cap_res  in ANAGRAFE_SOGGETTI.cap_res%type default null
, p_tel_res  in ANAGRAFE_SOGGETTI.tel_res%type default null
, p_fax_res  in ANAGRAFE_SOGGETTI.fax_res%type default null
, p_presso  in ANAGRAFE_SOGGETTI.presso%type default null
, p_indirizzo_dom  in ANAGRAFE_SOGGETTI.indirizzo_dom%type default null
, p_provincia_dom  in ANAGRAFE_SOGGETTI.provincia_dom%type default null
, p_comune_dom  in ANAGRAFE_SOGGETTI.comune_dom%type default null
, p_cap_dom  in ANAGRAFE_SOGGETTI.cap_dom%type default null
, p_tel_dom  in ANAGRAFE_SOGGETTI.tel_dom%type default null
, p_fax_dom  in ANAGRAFE_SOGGETTI.fax_dom%type default null
, p_utente  in ANAGRAFE_SOGGETTI.utente%type default null
, p_data_agg  in ANAGRAFE_SOGGETTI.data_agg%type default SYSDATE
, p_competenza  in ANAGRAFE_SOGGETTI.competenza%type default null
, p_tipo_soggetto  in ANAGRAFE_SOGGETTI.tipo_soggetto%type default null
, p_flag_trg  in ANAGRAFE_SOGGETTI.flag_trg%type default null
, p_stato_cee  in ANAGRAFE_SOGGETTI.stato_cee%type default null
, p_partita_iva_cee  in ANAGRAFE_SOGGETTI.partita_iva_cee%type default null
, p_fine_validita  in ANAGRAFE_SOGGETTI.fine_validita%type default null
, p_al  in ANAGRAFE_SOGGETTI.al%type default null
, p_denominazione  in ANAGRAFE_SOGGETTI.denominazione%type default null
, p_indirizzo_web  in ANAGRAFE_SOGGETTI.indirizzo_web%type default null
, p_note  in ANAGRAFE_SOGGETTI.note%type default null
, p_competenza_esclusiva  in ANAGRAFE_SOGGETTI.competenza_esclusiva%type default null
, p_version  in ANAGRAFE_SOGGETTI.version%type default 0
) is
/******************************************************************************
 NOME:        ins
 DESCRIZIONE: Inserimento di una riga con chiave e attributi indicati.
 PARAMETRI:   Chiavi e attributi della table.
******************************************************************************/
begin
   -- Check Mandatory on Insert
   DbC.PRE ( not DbC.PreOn or p_cognome is not null or /*default value*/ '' is not null
           , 'p_cognome on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_nome is not null or /*default value*/ 'default' is not null
           , 'p_nome on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_sesso is not null or /*default value*/ 'default' is not null
           , 'p_sesso on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_data_nas is not null or /*default value*/ 'default' is not null
           , 'p_data_nas on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_provincia_nas is not null or /*default value*/ 'default' is not null
           , 'p_provincia_nas on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_comune_nas is not null or /*default value*/ 'default' is not null
           , 'p_comune_nas on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_luogo_nas is not null or /*default value*/ 'default' is not null
           , 'p_luogo_nas on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_codice_fiscale is not null or /*default value*/ 'default' is not null
           , 'p_codice_fiscale on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_codice_fiscale_estero is not null or /*default value*/ 'default' is not null
           , 'p_codice_fiscale_estero on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_partita_iva is not null or /*default value*/ 'default' is not null
           , 'p_partita_iva on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_cittadinanza is not null or /*default value*/ 'default' is not null
           , 'p_cittadinanza on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_gruppo_ling is not null or /*default value*/ 'default' is not null
           , 'p_gruppo_ling on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_indirizzo_res is not null or /*default value*/ 'default' is not null
           , 'p_indirizzo_res on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_provincia_res is not null or /*default value*/ 'default' is not null
           , 'p_provincia_res on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_comune_res is not null or /*default value*/ 'default' is not null
           , 'p_comune_res on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_cap_res is not null or /*default value*/ 'default' is not null
           , 'p_cap_res on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_tel_res is not null or /*default value*/ 'default' is not null
           , 'p_tel_res on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_fax_res is not null or /*default value*/ 'default' is not null
           , 'p_fax_res on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_presso is not null or /*default value*/ 'default' is not null
           , 'p_presso on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_indirizzo_dom is not null or /*default value*/ 'default' is not null
           , 'p_indirizzo_dom on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_provincia_dom is not null or /*default value*/ 'default' is not null
           , 'p_provincia_dom on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_comune_dom is not null or /*default value*/ 'default' is not null
           , 'p_comune_dom on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_cap_dom is not null or /*default value*/ 'default' is not null
           , 'p_cap_dom on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_tel_dom is not null or /*default value*/ 'default' is not null
           , 'p_tel_dom on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_fax_dom is not null or /*default value*/ 'default' is not null
           , 'p_fax_dom on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_utente is not null or /*default value*/ 'default' is not null
           , 'p_utente on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_data_agg is not null or /*default value*/ 'default' is not null
           , 'p_data_agg on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_competenza is not null or /*default value*/ 'default' is not null
           , 'p_competenza on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_tipo_soggetto is not null or /*default value*/ 'default' is not null
           , 'p_tipo_soggetto on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_flag_trg is not null or /*default value*/ 'default' is not null
           , 'p_flag_trg on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_stato_cee is not null or /*default value*/ 'default' is not null
           , 'p_stato_cee on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_partita_iva_cee is not null or /*default value*/ 'default' is not null
           , 'p_partita_iva_cee on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_fine_validita is not null or /*default value*/ 'default' is not null
           , 'p_fine_validita on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_al is not null or /*default value*/ 'default' is not null
           , 'p_al on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_denominazione is not null or /*default value*/ 'default' is not null
           , 'p_denominazione on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_indirizzo_web is not null or /*default value*/ 'default' is not null
           , 'p_indirizzo_web on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_note is not null or /*default value*/ 'default' is not null
           , 'p_note on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_competenza_esclusiva is not null or /*default value*/ 'default' is not null
           , 'p_competenza_esclusiva on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_version is not null or /*default value*/ 'default' is not null
           , 'p_version on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE (  not DbC.PreOn
           or (   p_ni is null and /*default value*/ 'default null' is not null ) -- PK nullable on insert
or (   p_dal is null and /*default value*/ '' is not null ) -- PK nullable on insert
           or not existsId (
                             p_ni => p_ni
,p_dal => p_dal
                           )
           , 'not existsId on anagrafe_soggetti_tpk.ins'
           );
   insert into ANAGRAFE_SOGGETTI
   (
     ni
,dal
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
   , indirizzo_res
   , provincia_res
   , comune_res
   , cap_res
   , tel_res
   , fax_res
   , presso
   , indirizzo_dom
   , provincia_dom
   , comune_dom
   , cap_dom
   , tel_dom
   , fax_dom
   , utente
   , data_agg
   , competenza
   , tipo_soggetto
   , flag_trg
   , stato_cee
   , partita_iva_cee
   , fine_validita
   , al
   , denominazione
   , indirizzo_web
   , note
   , competenza_esclusiva
   , version
   )
   values
   (
     p_ni
,p_dal
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
   , p_indirizzo_res
   , p_provincia_res
   , p_comune_res
   , p_cap_res
   , p_tel_res
   , p_fax_res
   , p_presso
   , p_indirizzo_dom
   , p_provincia_dom
   , p_comune_dom
   , p_cap_dom
   , p_tel_dom
   , p_fax_dom
   , p_utente
   , p_data_agg
   , p_competenza
   , p_tipo_soggetto
   , p_flag_trg
   , p_stato_cee
   , p_partita_iva_cee
   , p_fine_validita
   , p_al
   , p_denominazione
   , p_indirizzo_web
   , p_note
   , p_competenza_esclusiva
   , p_version
   );
end ins; -- anagrafe_soggetti_tpk.ins
--------------------------------------------------------------------------------
function ins
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type default null
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_cognome  in ANAGRAFE_SOGGETTI.cognome%type
, p_nome  in ANAGRAFE_SOGGETTI.nome%type default null
, p_sesso  in ANAGRAFE_SOGGETTI.sesso%type default null
, p_data_nas  in ANAGRAFE_SOGGETTI.data_nas%type default null
, p_provincia_nas  in ANAGRAFE_SOGGETTI.provincia_nas%type default null
, p_comune_nas  in ANAGRAFE_SOGGETTI.comune_nas%type default null
, p_luogo_nas  in ANAGRAFE_SOGGETTI.luogo_nas%type default null
, p_codice_fiscale  in ANAGRAFE_SOGGETTI.codice_fiscale%type default null
, p_codice_fiscale_estero  in ANAGRAFE_SOGGETTI.codice_fiscale_estero%type default null
, p_partita_iva  in ANAGRAFE_SOGGETTI.partita_iva%type default null
, p_cittadinanza  in ANAGRAFE_SOGGETTI.cittadinanza%type default null
, p_gruppo_ling  in ANAGRAFE_SOGGETTI.gruppo_ling%type default null
, p_indirizzo_res  in ANAGRAFE_SOGGETTI.indirizzo_res%type default null
, p_provincia_res  in ANAGRAFE_SOGGETTI.provincia_res%type default null
, p_comune_res  in ANAGRAFE_SOGGETTI.comune_res%type default null
, p_cap_res  in ANAGRAFE_SOGGETTI.cap_res%type default null
, p_tel_res  in ANAGRAFE_SOGGETTI.tel_res%type default null
, p_fax_res  in ANAGRAFE_SOGGETTI.fax_res%type default null
, p_presso  in ANAGRAFE_SOGGETTI.presso%type default null
, p_indirizzo_dom  in ANAGRAFE_SOGGETTI.indirizzo_dom%type default null
, p_provincia_dom  in ANAGRAFE_SOGGETTI.provincia_dom%type default null
, p_comune_dom  in ANAGRAFE_SOGGETTI.comune_dom%type default null
, p_cap_dom  in ANAGRAFE_SOGGETTI.cap_dom%type default null
, p_tel_dom  in ANAGRAFE_SOGGETTI.tel_dom%type default null
, p_fax_dom  in ANAGRAFE_SOGGETTI.fax_dom%type default null
, p_utente  in ANAGRAFE_SOGGETTI.utente%type default null
, p_data_agg  in ANAGRAFE_SOGGETTI.data_agg%type default SYSDATE
, p_competenza  in ANAGRAFE_SOGGETTI.competenza%type default null
, p_tipo_soggetto  in ANAGRAFE_SOGGETTI.tipo_soggetto%type default null
, p_flag_trg  in ANAGRAFE_SOGGETTI.flag_trg%type default null
, p_stato_cee  in ANAGRAFE_SOGGETTI.stato_cee%type default null
, p_partita_iva_cee  in ANAGRAFE_SOGGETTI.partita_iva_cee%type default null
, p_fine_validita  in ANAGRAFE_SOGGETTI.fine_validita%type default null
, p_al  in ANAGRAFE_SOGGETTI.al%type default null
, p_denominazione  in ANAGRAFE_SOGGETTI.denominazione%type default null
, p_indirizzo_web  in ANAGRAFE_SOGGETTI.indirizzo_web%type default null
, p_note  in ANAGRAFE_SOGGETTI.note%type default null
, p_competenza_esclusiva  in ANAGRAFE_SOGGETTI.competenza_esclusiva%type default null
, p_version  in ANAGRAFE_SOGGETTI.version%type default 0
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
   DbC.PRE ( not DbC.PreOn or p_cognome is not null or /*default value*/ '' is not null
           , 'p_cognome on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_nome is not null or /*default value*/ 'default' is not null
           , 'p_nome on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_sesso is not null or /*default value*/ 'default' is not null
           , 'p_sesso on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_data_nas is not null or /*default value*/ 'default' is not null
           , 'p_data_nas on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_provincia_nas is not null or /*default value*/ 'default' is not null
           , 'p_provincia_nas on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_comune_nas is not null or /*default value*/ 'default' is not null
           , 'p_comune_nas on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_luogo_nas is not null or /*default value*/ 'default' is not null
           , 'p_luogo_nas on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_codice_fiscale is not null or /*default value*/ 'default' is not null
           , 'p_codice_fiscale on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_codice_fiscale_estero is not null or /*default value*/ 'default' is not null
           , 'p_codice_fiscale_estero on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_partita_iva is not null or /*default value*/ 'default' is not null
           , 'p_partita_iva on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_cittadinanza is not null or /*default value*/ 'default' is not null
           , 'p_cittadinanza on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_gruppo_ling is not null or /*default value*/ 'default' is not null
           , 'p_gruppo_ling on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_indirizzo_res is not null or /*default value*/ 'default' is not null
           , 'p_indirizzo_res on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_provincia_res is not null or /*default value*/ 'default' is not null
           , 'p_provincia_res on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_comune_res is not null or /*default value*/ 'default' is not null
           , 'p_comune_res on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_cap_res is not null or /*default value*/ 'default' is not null
           , 'p_cap_res on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_tel_res is not null or /*default value*/ 'default' is not null
           , 'p_tel_res on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_fax_res is not null or /*default value*/ 'default' is not null
           , 'p_fax_res on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_presso is not null or /*default value*/ 'default' is not null
           , 'p_presso on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_indirizzo_dom is not null or /*default value*/ 'default' is not null
           , 'p_indirizzo_dom on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_provincia_dom is not null or /*default value*/ 'default' is not null
           , 'p_provincia_dom on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_comune_dom is not null or /*default value*/ 'default' is not null
           , 'p_comune_dom on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_cap_dom is not null or /*default value*/ 'default' is not null
           , 'p_cap_dom on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_tel_dom is not null or /*default value*/ 'default' is not null
           , 'p_tel_dom on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_fax_dom is not null or /*default value*/ 'default' is not null
           , 'p_fax_dom on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_utente is not null or /*default value*/ 'default' is not null
           , 'p_utente on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_data_agg is not null or /*default value*/ 'default' is not null
           , 'p_data_agg on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_competenza is not null or /*default value*/ 'default' is not null
           , 'p_competenza on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_tipo_soggetto is not null or /*default value*/ 'default' is not null
           , 'p_tipo_soggetto on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_flag_trg is not null or /*default value*/ 'default' is not null
           , 'p_flag_trg on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_stato_cee is not null or /*default value*/ 'default' is not null
           , 'p_stato_cee on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_partita_iva_cee is not null or /*default value*/ 'default' is not null
           , 'p_partita_iva_cee on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_fine_validita is not null or /*default value*/ 'default' is not null
           , 'p_fine_validita on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_al is not null or /*default value*/ 'default' is not null
           , 'p_al on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_denominazione is not null or /*default value*/ 'default' is not null
           , 'p_denominazione on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_indirizzo_web is not null or /*default value*/ 'default' is not null
           , 'p_indirizzo_web on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_note is not null or /*default value*/ 'default' is not null
           , 'p_note on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_competenza_esclusiva is not null or /*default value*/ 'default' is not null
           , 'p_competenza_esclusiva on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE ( not DbC.PreOn or p_version is not null or /*default value*/ 'default' is not null
           , 'p_version on anagrafe_soggetti_tpk.ins'
           );
   DbC.PRE (  not DbC.PreOn
           or (   p_ni is null and /*default value*/ 'default null' is not null ) -- PK nullable on insert
or (   p_dal is null and /*default value*/ '' is not null ) -- PK nullable on insert
           or not existsId (
                             p_ni => p_ni
,p_dal => p_dal
                           )
           , 'not existsId on anagrafe_soggetti_tpk.ins'
           );
   begin
      insert into ANAGRAFE_SOGGETTI
      (
        ni
,dal
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
      , indirizzo_res
      , provincia_res
      , comune_res
      , cap_res
      , tel_res
      , fax_res
      , presso
      , indirizzo_dom
      , provincia_dom
      , comune_dom
      , cap_dom
      , tel_dom
      , fax_dom
      , utente
      , data_agg
      , competenza
      , tipo_soggetto
      , flag_trg
      , stato_cee
      , partita_iva_cee
      , fine_validita
      , al
      , denominazione
      , indirizzo_web
      , note
      , competenza_esclusiva
      , version
      )
      values
      (
        p_ni
,p_dal
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
      , p_indirizzo_res
      , p_provincia_res
      , p_comune_res
      , p_cap_res
      , p_tel_res
      , p_fax_res
      , p_presso
      , p_indirizzo_dom
      , p_provincia_dom
      , p_comune_dom
      , p_cap_dom
      , p_tel_dom
      , p_fax_dom
      , p_utente
      , p_data_agg
      , p_competenza
      , p_tipo_soggetto
      , p_flag_trg
      , p_stato_cee
      , p_partita_iva_cee
      , p_fine_validita
      , p_al
      , p_denominazione
      , p_indirizzo_web
      , p_note
      , p_competenza_esclusiva
      , p_version
      );
      d_result := 0;
   exception
      when others then
         d_result := sqlcode;
   end;
   return d_result;
end ins; -- anagrafe_soggetti_tpk.ins
--------------------------------------------------------------------------------
procedure upd
(
  p_check_OLD  in integer default 0
, p_NEW_ni  in ANAGRAFE_SOGGETTI.ni%type
, p_OLD_ni  in ANAGRAFE_SOGGETTI.ni%type default null
, p_NEW_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_OLD_dal  in ANAGRAFE_SOGGETTI.dal%type default null
, p_NEW_cognome  in ANAGRAFE_SOGGETTI.cognome%type default afc.default_null('ANAGRAFE_SOGGETTI.cognome')
, p_OLD_cognome  in ANAGRAFE_SOGGETTI.cognome%type default null
, p_NEW_nome  in ANAGRAFE_SOGGETTI.nome%type default afc.default_null('ANAGRAFE_SOGGETTI.nome')
, p_OLD_nome  in ANAGRAFE_SOGGETTI.nome%type default null
, p_NEW_sesso  in ANAGRAFE_SOGGETTI.sesso%type default afc.default_null('ANAGRAFE_SOGGETTI.sesso')
, p_OLD_sesso  in ANAGRAFE_SOGGETTI.sesso%type default null
, p_NEW_data_nas  in ANAGRAFE_SOGGETTI.data_nas%type default afc.default_null('ANAGRAFE_SOGGETTI.data_nas')
, p_OLD_data_nas  in ANAGRAFE_SOGGETTI.data_nas%type default null
, p_NEW_provincia_nas  in ANAGRAFE_SOGGETTI.provincia_nas%type default afc.default_null('ANAGRAFE_SOGGETTI.provincia_nas')
, p_OLD_provincia_nas  in ANAGRAFE_SOGGETTI.provincia_nas%type default null
, p_NEW_comune_nas  in ANAGRAFE_SOGGETTI.comune_nas%type default afc.default_null('ANAGRAFE_SOGGETTI.comune_nas')
, p_OLD_comune_nas  in ANAGRAFE_SOGGETTI.comune_nas%type default null
, p_NEW_luogo_nas  in ANAGRAFE_SOGGETTI.luogo_nas%type default afc.default_null('ANAGRAFE_SOGGETTI.luogo_nas')
, p_OLD_luogo_nas  in ANAGRAFE_SOGGETTI.luogo_nas%type default null
, p_NEW_codice_fiscale  in ANAGRAFE_SOGGETTI.codice_fiscale%type default afc.default_null('ANAGRAFE_SOGGETTI.codice_fiscale')
, p_OLD_codice_fiscale  in ANAGRAFE_SOGGETTI.codice_fiscale%type default null
, p_NEW_codice_fiscale_estero  in ANAGRAFE_SOGGETTI.codice_fiscale_estero%type default afc.default_null('ANAGRAFE_SOGGETTI.codice_fiscale_estero')
, p_OLD_codice_fiscale_estero  in ANAGRAFE_SOGGETTI.codice_fiscale_estero%type default null
, p_NEW_partita_iva  in ANAGRAFE_SOGGETTI.partita_iva%type default afc.default_null('ANAGRAFE_SOGGETTI.partita_iva')
, p_OLD_partita_iva  in ANAGRAFE_SOGGETTI.partita_iva%type default null
, p_NEW_cittadinanza  in ANAGRAFE_SOGGETTI.cittadinanza%type default afc.default_null('ANAGRAFE_SOGGETTI.cittadinanza')
, p_OLD_cittadinanza  in ANAGRAFE_SOGGETTI.cittadinanza%type default null
, p_NEW_gruppo_ling  in ANAGRAFE_SOGGETTI.gruppo_ling%type default afc.default_null('ANAGRAFE_SOGGETTI.gruppo_ling')
, p_OLD_gruppo_ling  in ANAGRAFE_SOGGETTI.gruppo_ling%type default null
, p_NEW_indirizzo_res  in ANAGRAFE_SOGGETTI.indirizzo_res%type default afc.default_null('ANAGRAFE_SOGGETTI.indirizzo_res')
, p_OLD_indirizzo_res  in ANAGRAFE_SOGGETTI.indirizzo_res%type default null
, p_NEW_provincia_res  in ANAGRAFE_SOGGETTI.provincia_res%type default afc.default_null('ANAGRAFE_SOGGETTI.provincia_res')
, p_OLD_provincia_res  in ANAGRAFE_SOGGETTI.provincia_res%type default null
, p_NEW_comune_res  in ANAGRAFE_SOGGETTI.comune_res%type default afc.default_null('ANAGRAFE_SOGGETTI.comune_res')
, p_OLD_comune_res  in ANAGRAFE_SOGGETTI.comune_res%type default null
, p_NEW_cap_res  in ANAGRAFE_SOGGETTI.cap_res%type default afc.default_null('ANAGRAFE_SOGGETTI.cap_res')
, p_OLD_cap_res  in ANAGRAFE_SOGGETTI.cap_res%type default null
, p_NEW_tel_res  in ANAGRAFE_SOGGETTI.tel_res%type default afc.default_null('ANAGRAFE_SOGGETTI.tel_res')
, p_OLD_tel_res  in ANAGRAFE_SOGGETTI.tel_res%type default null
, p_NEW_fax_res  in ANAGRAFE_SOGGETTI.fax_res%type default afc.default_null('ANAGRAFE_SOGGETTI.fax_res')
, p_OLD_fax_res  in ANAGRAFE_SOGGETTI.fax_res%type default null
, p_NEW_presso  in ANAGRAFE_SOGGETTI.presso%type default afc.default_null('ANAGRAFE_SOGGETTI.presso')
, p_OLD_presso  in ANAGRAFE_SOGGETTI.presso%type default null
, p_NEW_indirizzo_dom  in ANAGRAFE_SOGGETTI.indirizzo_dom%type default afc.default_null('ANAGRAFE_SOGGETTI.indirizzo_dom')
, p_OLD_indirizzo_dom  in ANAGRAFE_SOGGETTI.indirizzo_dom%type default null
, p_NEW_provincia_dom  in ANAGRAFE_SOGGETTI.provincia_dom%type default afc.default_null('ANAGRAFE_SOGGETTI.provincia_dom')
, p_OLD_provincia_dom  in ANAGRAFE_SOGGETTI.provincia_dom%type default null
, p_NEW_comune_dom  in ANAGRAFE_SOGGETTI.comune_dom%type default afc.default_null('ANAGRAFE_SOGGETTI.comune_dom')
, p_OLD_comune_dom  in ANAGRAFE_SOGGETTI.comune_dom%type default null
, p_NEW_cap_dom  in ANAGRAFE_SOGGETTI.cap_dom%type default afc.default_null('ANAGRAFE_SOGGETTI.cap_dom')
, p_OLD_cap_dom  in ANAGRAFE_SOGGETTI.cap_dom%type default null
, p_NEW_tel_dom  in ANAGRAFE_SOGGETTI.tel_dom%type default afc.default_null('ANAGRAFE_SOGGETTI.tel_dom')
, p_OLD_tel_dom  in ANAGRAFE_SOGGETTI.tel_dom%type default null
, p_NEW_fax_dom  in ANAGRAFE_SOGGETTI.fax_dom%type default afc.default_null('ANAGRAFE_SOGGETTI.fax_dom')
, p_OLD_fax_dom  in ANAGRAFE_SOGGETTI.fax_dom%type default null
, p_NEW_utente  in ANAGRAFE_SOGGETTI.utente%type default afc.default_null('ANAGRAFE_SOGGETTI.utente')
, p_OLD_utente  in ANAGRAFE_SOGGETTI.utente%type default null
, p_NEW_data_agg  in ANAGRAFE_SOGGETTI.data_agg%type default afc.default_null('ANAGRAFE_SOGGETTI.data_agg')
, p_OLD_data_agg  in ANAGRAFE_SOGGETTI.data_agg%type default null
, p_NEW_competenza  in ANAGRAFE_SOGGETTI.competenza%type default afc.default_null('ANAGRAFE_SOGGETTI.competenza')
, p_OLD_competenza  in ANAGRAFE_SOGGETTI.competenza%type default null
, p_NEW_tipo_soggetto  in ANAGRAFE_SOGGETTI.tipo_soggetto%type default afc.default_null('ANAGRAFE_SOGGETTI.tipo_soggetto')
, p_OLD_tipo_soggetto  in ANAGRAFE_SOGGETTI.tipo_soggetto%type default null
, p_NEW_flag_trg  in ANAGRAFE_SOGGETTI.flag_trg%type default afc.default_null('ANAGRAFE_SOGGETTI.flag_trg')
, p_OLD_flag_trg  in ANAGRAFE_SOGGETTI.flag_trg%type default null
, p_NEW_stato_cee  in ANAGRAFE_SOGGETTI.stato_cee%type default afc.default_null('ANAGRAFE_SOGGETTI.stato_cee')
, p_OLD_stato_cee  in ANAGRAFE_SOGGETTI.stato_cee%type default null
, p_NEW_partita_iva_cee  in ANAGRAFE_SOGGETTI.partita_iva_cee%type default afc.default_null('ANAGRAFE_SOGGETTI.partita_iva_cee')
, p_OLD_partita_iva_cee  in ANAGRAFE_SOGGETTI.partita_iva_cee%type default null
, p_NEW_fine_validita  in ANAGRAFE_SOGGETTI.fine_validita%type default afc.default_null('ANAGRAFE_SOGGETTI.fine_validita')
, p_OLD_fine_validita  in ANAGRAFE_SOGGETTI.fine_validita%type default null
, p_NEW_al  in ANAGRAFE_SOGGETTI.al%type default afc.default_null('ANAGRAFE_SOGGETTI.al')
, p_OLD_al  in ANAGRAFE_SOGGETTI.al%type default null
, p_NEW_denominazione  in ANAGRAFE_SOGGETTI.denominazione%type default afc.default_null('ANAGRAFE_SOGGETTI.denominazione')
, p_OLD_denominazione  in ANAGRAFE_SOGGETTI.denominazione%type default null
, p_NEW_indirizzo_web  in ANAGRAFE_SOGGETTI.indirizzo_web%type default afc.default_null('ANAGRAFE_SOGGETTI.indirizzo_web')
, p_OLD_indirizzo_web  in ANAGRAFE_SOGGETTI.indirizzo_web%type default null
, p_NEW_note  in ANAGRAFE_SOGGETTI.note%type default afc.default_null('ANAGRAFE_SOGGETTI.note')
, p_OLD_note  in ANAGRAFE_SOGGETTI.note%type default null
, p_NEW_competenza_esclusiva  in ANAGRAFE_SOGGETTI.competenza_esclusiva%type default afc.default_null('ANAGRAFE_SOGGETTI.competenza_esclusiva')
, p_OLD_competenza_esclusiva  in ANAGRAFE_SOGGETTI.competenza_esclusiva%type default null
, p_NEW_version  in ANAGRAFE_SOGGETTI.version%type default afc.default_null('ANAGRAFE_SOGGETTI.version')
, p_OLD_version  in ANAGRAFE_SOGGETTI.version%type default null
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
              Se p_check_old = 1, viene controllato se il record corrispondente a
              tutti i campi passati come parametri esiste nella tabella.
              Se p_check_old è NULL, viene controllato se il record corrispondente
                  ai soli campi passati come parametri esiste nella tabella.
 REVISIONI:   .
 Rev.  Data        Autore  Descrizione.
 002  01/08/2013   snegroni Corretto errore in aggiornamento soggetto
******************************************************************************/
   d_key t_PK;
   d_row_found number;
begin
   DbC.PRE (  not DbC.PreOn
           or not ( (
p_OLD_cognome is not null
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
 or p_OLD_indirizzo_res is not null
 or p_OLD_provincia_res is not null
 or p_OLD_comune_res is not null
 or p_OLD_cap_res is not null
 or p_OLD_tel_res is not null
 or p_OLD_fax_res is not null
 or p_OLD_presso is not null
 or p_OLD_indirizzo_dom is not null
 or p_OLD_provincia_dom is not null
 or p_OLD_comune_dom is not null
 or p_OLD_cap_dom is not null
 or p_OLD_tel_dom is not null
 or p_OLD_fax_dom is not null
 or p_OLD_utente is not null
 or p_OLD_data_agg is not null
 or p_OLD_competenza is not null
 or p_OLD_tipo_soggetto is not null
 or p_OLD_flag_trg is not null
 or p_OLD_stato_cee is not null
 or p_OLD_partita_iva_cee is not null
 or p_OLD_fine_validita is not null
 or p_OLD_al is not null
 or p_OLD_denominazione is not null
 or p_OLD_indirizzo_web is not null
 or p_OLD_note is not null
 or p_OLD_competenza_esclusiva is not null
 or p_OLD_version is not null
                    )
                    and (  nvl( p_check_OLD, -1 ) = 0
                        )
                  )
           , ' "OLD values" is not null on anagrafe_soggetti_tpk.upd'
           );
   d_key := PK (
                nvl( p_OLD_ni, p_NEW_ni )
,nvl( p_OLD_dal, p_NEW_dal )
               );
   DbC.PRE ( not DbC.PreOn or existsId (
                                         p_ni => d_key.ni
,p_dal => d_key.dal
                                       )
           , 'existsId on anagrafe_soggetti_tpk.upd'
           );
           
           
--raise_application_error(-20999,'p_check_old' || p_check_old);--' ni: ' || d_key.ni || 'chiave' || d_key.dal );
   update ANAGRAFE_SOGGETTI
   set
       ni = nvl( p_NEW_ni, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.ni'), 1, ni, null) )
,dal = nvl( p_NEW_dal, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.dal'), 1, dal, null) )
     , cognome = nvl( p_NEW_cognome, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.cognome'), 1, cognome, null) )
     , nome = nvl( p_NEW_nome, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.nome'), 1, nome, null) )
     , sesso = nvl( p_NEW_sesso, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.sesso'), 1, sesso, null) )
     , data_nas = nvl( p_NEW_data_nas, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.data_nas'), 1, data_nas, null) )
     , provincia_nas = nvl( p_NEW_provincia_nas, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.provincia_nas'), 1, provincia_nas, null) )
     , comune_nas = nvl( p_NEW_comune_nas, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.comune_nas'), 1, comune_nas, null) )
     , luogo_nas = nvl( p_NEW_luogo_nas, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.luogo_nas'), 1, luogo_nas, null) )
     , codice_fiscale = nvl( p_NEW_codice_fiscale, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.codice_fiscale'), 1, codice_fiscale, null) )
     , codice_fiscale_estero = nvl( p_NEW_codice_fiscale_estero, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.codice_fiscale_estero'), 1, codice_fiscale_estero, null) )
     , partita_iva = nvl( p_NEW_partita_iva, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.partita_iva'), 1, partita_iva, null) )
     , cittadinanza = nvl( p_NEW_cittadinanza, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.cittadinanza'), 1, cittadinanza, null) )
     , gruppo_ling = nvl( p_NEW_gruppo_ling, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.gruppo_ling'), 1, gruppo_ling, null) )
     , indirizzo_res = nvl( p_NEW_indirizzo_res, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.indirizzo_res'), 1, indirizzo_res, null) )
     , provincia_res = nvl( p_NEW_provincia_res, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.provincia_res'), 1, provincia_res, null) )
     , comune_res = nvl( p_NEW_comune_res, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.comune_res'), 1, comune_res, null) )
     , cap_res = nvl( p_NEW_cap_res, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.cap_res'), 1, cap_res, null) )
     , tel_res = nvl( p_NEW_tel_res, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.tel_res'), 1, tel_res, null) )
     , fax_res = nvl( p_NEW_fax_res, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.fax_res'), 1, fax_res, null) )
     , presso = nvl( p_NEW_presso, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.presso'), 1, presso, null) )
     , indirizzo_dom = nvl( p_NEW_indirizzo_dom, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.indirizzo_dom'), 1, indirizzo_dom, null) )
     , provincia_dom = nvl( p_NEW_provincia_dom, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.provincia_dom'), 1, provincia_dom, null) )
     , comune_dom = nvl( p_NEW_comune_dom, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.comune_dom'), 1, comune_dom, null) )
     , cap_dom = nvl( p_NEW_cap_dom, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.cap_dom'), 1, cap_dom, null) )
     , tel_dom = nvl( p_NEW_tel_dom, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.tel_dom'), 1, tel_dom, null) )
     , fax_dom = nvl( p_NEW_fax_dom, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.fax_dom'), 1, fax_dom, null) )
     , utente = nvl( p_NEW_utente, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.utente'), 1, utente, null) )
     , data_agg = nvl( p_NEW_data_agg, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.data_agg'), 1, data_agg, null) )
     , competenza = nvl( p_NEW_competenza, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.competenza'), 1, competenza, null) )
     , tipo_soggetto = nvl( p_NEW_tipo_soggetto, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.tipo_soggetto'), 1, tipo_soggetto, null) )
     , flag_trg = nvl( p_NEW_flag_trg, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.flag_trg'), 1, flag_trg, null) )
     , stato_cee = nvl( p_NEW_stato_cee, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.stato_cee'), 1, stato_cee, null) )
     , partita_iva_cee = nvl( p_NEW_partita_iva_cee, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.partita_iva_cee'), 1, partita_iva_cee, null) )
     , fine_validita = nvl( p_NEW_fine_validita, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.fine_validita'), 1, fine_validita, null) )
     , al = nvl( p_NEW_al, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.al'), 1, al, null) )
     , denominazione = nvl( p_NEW_denominazione, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.denominazione'), 1, denominazione, null) )
     , indirizzo_web = nvl( p_NEW_indirizzo_web, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.indirizzo_web'), 1, indirizzo_web, null) )
     , note = nvl( p_NEW_note, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.note'), 1, note, null) )
     , competenza_esclusiva = nvl( p_NEW_competenza_esclusiva, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.competenza_esclusiva'), 1, competenza_esclusiva, null) )
     , version = nvl( p_NEW_version, decode( afc.is_default_null( 'ANAGRAFE_SOGGETTI.version'), 1, version, null) )
   where
     ni = d_key.ni
and dal = d_key.dal
   and (   p_check_OLD = 0
        or (   1 = 1
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
           and ( indirizzo_res = p_OLD_indirizzo_res or ( p_OLD_indirizzo_res is null and ( p_check_OLD is null or indirizzo_res is null ) ) )
           and ( provincia_res = p_OLD_provincia_res or ( p_OLD_provincia_res is null and ( p_check_OLD is null or provincia_res is null ) ) )
           and ( comune_res = p_OLD_comune_res or ( p_OLD_comune_res is null and ( p_check_OLD is null or comune_res is null ) ) )
           and ( cap_res = p_OLD_cap_res or ( p_OLD_cap_res is null and ( p_check_OLD is null or cap_res is null ) ) )
           and ( tel_res = p_OLD_tel_res or ( p_OLD_tel_res is null and ( p_check_OLD is null or tel_res is null ) ) )
           and ( fax_res = p_OLD_fax_res or ( p_OLD_fax_res is null and ( p_check_OLD is null or fax_res is null ) ) )
           and ( presso = p_OLD_presso or ( p_OLD_presso is null and ( p_check_OLD is null or presso is null ) ) )
           and ( indirizzo_dom = p_OLD_indirizzo_dom or ( p_OLD_indirizzo_dom is null and ( p_check_OLD is null or indirizzo_dom is null ) ) )
           and ( provincia_dom = p_OLD_provincia_dom or ( p_OLD_provincia_dom is null and ( p_check_OLD is null or provincia_dom is null ) ) )
           and ( comune_dom = p_OLD_comune_dom or ( p_OLD_comune_dom is null and ( p_check_OLD is null or comune_dom is null ) ) )
           and ( cap_dom = p_OLD_cap_dom or ( p_OLD_cap_dom is null and ( p_check_OLD is null or cap_dom is null ) ) )
           and ( tel_dom = p_OLD_tel_dom or ( p_OLD_tel_dom is null and ( p_check_OLD is null or tel_dom is null ) ) )
           and ( fax_dom = p_OLD_fax_dom or ( p_OLD_fax_dom is null and ( p_check_OLD is null or fax_dom is null ) ) )
           and ( utente = p_OLD_utente or ( p_OLD_utente is null and ( p_check_OLD is null or utente is null ) ) )
           and ( data_agg = p_OLD_data_agg or ( p_OLD_data_agg is null and ( p_check_OLD is null or data_agg is null ) ) )
           and ( competenza = p_OLD_competenza or ( p_OLD_competenza is null and ( p_check_OLD is null or competenza is null ) ) )
           and ( tipo_soggetto = p_OLD_tipo_soggetto or ( p_OLD_tipo_soggetto is null and ( p_check_OLD is null or tipo_soggetto is null ) ) )
           and ( flag_trg = p_OLD_flag_trg or ( p_OLD_flag_trg is null and ( p_check_OLD is null or flag_trg is null ) ) )
           and ( stato_cee = p_OLD_stato_cee or ( p_OLD_stato_cee is null and ( p_check_OLD is null or stato_cee is null ) ) )
           and ( partita_iva_cee = p_OLD_partita_iva_cee or ( p_OLD_partita_iva_cee is null and ( p_check_OLD is null or partita_iva_cee is null ) ) )
           and ( fine_validita = p_OLD_fine_validita or ( p_OLD_fine_validita is null and ( p_check_OLD is null or fine_validita is null ) ) )
           and ( al = p_OLD_al or ( p_OLD_al is null and ( p_check_OLD is null or al is null ) ) )
           and ( denominazione = p_OLD_denominazione or ( p_OLD_denominazione is null and ( p_check_OLD is null or denominazione is null ) ) )
           and ( indirizzo_web = p_OLD_indirizzo_web or ( p_OLD_indirizzo_web is null and ( p_check_OLD is null or indirizzo_web is null ) ) )
           and ( note = p_OLD_note or ( p_OLD_note is null and ( p_check_OLD is null or note is null ) ) )
           and ( competenza_esclusiva = p_OLD_competenza_esclusiva or ( p_OLD_competenza_esclusiva is null and ( p_check_OLD is null or competenza_esclusiva is null ) ) )
          -- and ( version = p_OLD_version or ( p_OLD_version is null and ( p_check_OLD is null or version is null ) ) ) IMPOSSIBILE CONTROLLARE
           )
       )
   ;
   d_row_found := SQL%ROWCOUNT;
   afc.default_null(NULL);
   DbC.ASSERTION ( not DbC.AssertionOn or d_row_found <= 1
                 , 'd_row_found <= 1 on anagrafe_soggetti_tpk.upd'
                 );
   if d_row_found < 1
   then
      raise_application_error ( AFC_ERROR.modified_by_other_user_number
                              , AFC_ERROR.modified_by_other_user_msg
                              );
   end if;
end upd; -- anagrafe_soggetti_tpk.upd
--------------------------------------------------------------------------------
procedure upd_column
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type,
p_dal  in ANAGRAFE_SOGGETTI.dal%type
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
22/12/2017 SN  MODIFICATA x gestire i valori con gli apici
******************************************************************************/
   d_statement AFC.t_statement;
   d_literal   varchar2(2);
   d_value    varchar2(32767):= p_value;
begin
   DbC.PRE ( not DbC.PreOn or existsId (
                                        p_ni => p_ni,
p_dal => p_dal
                                       )
           , 'existsId on anagrafe_soggetti_tpk.upd_column'
           );
   DbC.PRE ( not DbC.PreOn or p_column is not null
           , 'p_column is not null on anagrafe_soggetti_tpk.upd_column'
           );
   DbC.PRE ( not DbC.PreOn or AFC_DDL.HasAttribute( s_table_name, p_column )
           , 'AFC_DDL.HasAttribute on anagrafe_soggetti_tpk.upd_column'
           );
   DbC.PRE ( p_literal_value in ( 0, 1 ) or p_literal_value is null
           , 'p_literal_value on anagrafe_soggetti_tpk.upd_column; p_literal_value = ' || p_literal_value
           );       
   if p_literal_value = 1
   or p_literal_value is null
   then
      d_literal := '''';
      d_value := REPLACE (d_value
                                 , ''''
                                 , ''''''
                                  );
   end if;
   d_statement := ' declare '
               || '    d_row_found number; '
               || ' begin '
               || '    update ANAGRAFE_SOGGETTI '
               || '       set ' || p_column || ' = ' || d_literal || d_value || d_literal
               || '     where 1 = 1 '
               || nvl( AFC.get_field_condition( ' and ( ni ', p_ni, ' )', 0, null ), ' and ( ni is null ) ' )
 || nvl( AFC.get_field_condition( ' and ( dal ', p_dal, ' )', 0, AFC.date_format ), ' and ( dal is null ) ' )
               || '    ; '
               || '    d_row_found := SQL%ROWCOUNT; '
               || '    if d_row_found < 1 '
               || '    then '
               || '       raise_application_error ( AFC_ERROR.modified_by_other_user_number, AFC_ERROR.modified_by_other_user_msg ); '
               || '    end if; '
               || ' end; ';
   AFC.SQL_execute( d_statement );
end upd_column; -- anagrafe_soggetti_tpk.upd_column
--------------------------------------------------------------------------------
procedure upd_column
(
p_ni  in ANAGRAFE_SOGGETTI.ni%type,
p_dal  in ANAGRAFE_SOGGETTI.dal%type
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
p_ni => p_ni
,p_dal => p_dal
              , p_column => p_column
              , p_value => 'to_date( ''' || d_data || ''', ''' || AFC.date_format || ''' )'
              , p_literal_value => 0
              );
end upd_column; -- anagrafe_soggetti_tpk.upd_column
--------------------------------------------------------------------------------
procedure del
(
  p_check_old  in integer default 0
, p_ni  in ANAGRAFE_SOGGETTI.ni%type
, p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_cognome  in ANAGRAFE_SOGGETTI.cognome%type default null
, p_nome  in ANAGRAFE_SOGGETTI.nome%type default null
, p_sesso  in ANAGRAFE_SOGGETTI.sesso%type default null
, p_data_nas  in ANAGRAFE_SOGGETTI.data_nas%type default null
, p_provincia_nas  in ANAGRAFE_SOGGETTI.provincia_nas%type default null
, p_comune_nas  in ANAGRAFE_SOGGETTI.comune_nas%type default null
, p_luogo_nas  in ANAGRAFE_SOGGETTI.luogo_nas%type default null
, p_codice_fiscale  in ANAGRAFE_SOGGETTI.codice_fiscale%type default null
, p_codice_fiscale_estero  in ANAGRAFE_SOGGETTI.codice_fiscale_estero%type default null
, p_partita_iva  in ANAGRAFE_SOGGETTI.partita_iva%type default null
, p_cittadinanza  in ANAGRAFE_SOGGETTI.cittadinanza%type default null
, p_gruppo_ling  in ANAGRAFE_SOGGETTI.gruppo_ling%type default null
, p_indirizzo_res  in ANAGRAFE_SOGGETTI.indirizzo_res%type default null
, p_provincia_res  in ANAGRAFE_SOGGETTI.provincia_res%type default null
, p_comune_res  in ANAGRAFE_SOGGETTI.comune_res%type default null
, p_cap_res  in ANAGRAFE_SOGGETTI.cap_res%type default null
, p_tel_res  in ANAGRAFE_SOGGETTI.tel_res%type default null
, p_fax_res  in ANAGRAFE_SOGGETTI.fax_res%type default null
, p_presso  in ANAGRAFE_SOGGETTI.presso%type default null
, p_indirizzo_dom  in ANAGRAFE_SOGGETTI.indirizzo_dom%type default null
, p_provincia_dom  in ANAGRAFE_SOGGETTI.provincia_dom%type default null
, p_comune_dom  in ANAGRAFE_SOGGETTI.comune_dom%type default null
, p_cap_dom  in ANAGRAFE_SOGGETTI.cap_dom%type default null
, p_tel_dom  in ANAGRAFE_SOGGETTI.tel_dom%type default null
, p_fax_dom  in ANAGRAFE_SOGGETTI.fax_dom%type default null
, p_utente  in ANAGRAFE_SOGGETTI.utente%type default null
, p_data_agg  in ANAGRAFE_SOGGETTI.data_agg%type default null
, p_competenza  in ANAGRAFE_SOGGETTI.competenza%type default null
, p_tipo_soggetto  in ANAGRAFE_SOGGETTI.tipo_soggetto%type default null
, p_flag_trg  in ANAGRAFE_SOGGETTI.flag_trg%type default null
, p_stato_cee  in ANAGRAFE_SOGGETTI.stato_cee%type default null
, p_partita_iva_cee  in ANAGRAFE_SOGGETTI.partita_iva_cee%type default null
, p_fine_validita  in ANAGRAFE_SOGGETTI.fine_validita%type default null
, p_al  in ANAGRAFE_SOGGETTI.al%type default null
, p_denominazione  in ANAGRAFE_SOGGETTI.denominazione%type default null
, p_indirizzo_web  in ANAGRAFE_SOGGETTI.indirizzo_web%type default null
, p_note  in ANAGRAFE_SOGGETTI.note%type default null
, p_competenza_esclusiva  in ANAGRAFE_SOGGETTI.competenza_esclusiva%type default null
, p_version  in ANAGRAFE_SOGGETTI.version%type default null
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
              Se p_check_old è NULL, viene controllato se il record corrispondente
                  ai soli campi passati come parametri esiste nella tabella.
******************************************************************************/
   d_row_found number;
begin
   DbC.PRE (  not DbC.PreOn
           or not ( (
p_cognome is not null
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
 or p_indirizzo_res is not null
 or p_provincia_res is not null
 or p_comune_res is not null
 or p_cap_res is not null
 or p_tel_res is not null
 or p_fax_res is not null
 or p_presso is not null
 or p_indirizzo_dom is not null
 or p_provincia_dom is not null
 or p_comune_dom is not null
 or p_cap_dom is not null
 or p_tel_dom is not null
 or p_fax_dom is not null
 or p_utente is not null
 or p_data_agg is not null
 or p_competenza is not null
 or p_tipo_soggetto is not null
 or p_flag_trg is not null
 or p_stato_cee is not null
 or p_partita_iva_cee is not null
 or p_fine_validita is not null
 or p_al is not null
 or p_denominazione is not null
 or p_indirizzo_web is not null
 or p_note is not null
 or p_competenza_esclusiva is not null
 or p_version is not null
                    )
                    and (  nvl( p_check_OLD, -1 ) = 0
                        )
                  )
           , ' "OLD values" is not null on anagrafe_soggetti_tpk.del'
           );
   DbC.PRE ( not DbC.PreOn or existsId (
                                         p_ni => p_ni,
p_dal => p_dal
                                       )
           , 'existsId on anagrafe_soggetti_tpk.del'
           );
   delete from ANAGRAFE_SOGGETTI
   where
     ni = p_ni and
dal = p_dal
   and (   p_check_OLD = 0
        or (   1 = 1
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
           and ( indirizzo_res = p_indirizzo_res or ( p_indirizzo_res is null and ( p_check_OLD is null or indirizzo_res is null ) ) )
           and ( provincia_res = p_provincia_res or ( p_provincia_res is null and ( p_check_OLD is null or provincia_res is null ) ) )
           and ( comune_res = p_comune_res or ( p_comune_res is null and ( p_check_OLD is null or comune_res is null ) ) )
           and ( cap_res = p_cap_res or ( p_cap_res is null and ( p_check_OLD is null or cap_res is null ) ) )
           and ( tel_res = p_tel_res or ( p_tel_res is null and ( p_check_OLD is null or tel_res is null ) ) )
           and ( fax_res = p_fax_res or ( p_fax_res is null and ( p_check_OLD is null or fax_res is null ) ) )
           and ( presso = p_presso or ( p_presso is null and ( p_check_OLD is null or presso is null ) ) )
           and ( indirizzo_dom = p_indirizzo_dom or ( p_indirizzo_dom is null and ( p_check_OLD is null or indirizzo_dom is null ) ) )
           and ( provincia_dom = p_provincia_dom or ( p_provincia_dom is null and ( p_check_OLD is null or provincia_dom is null ) ) )
           and ( comune_dom = p_comune_dom or ( p_comune_dom is null and ( p_check_OLD is null or comune_dom is null ) ) )
           and ( cap_dom = p_cap_dom or ( p_cap_dom is null and ( p_check_OLD is null or cap_dom is null ) ) )
           and ( tel_dom = p_tel_dom or ( p_tel_dom is null and ( p_check_OLD is null or tel_dom is null ) ) )
           and ( fax_dom = p_fax_dom or ( p_fax_dom is null and ( p_check_OLD is null or fax_dom is null ) ) )
           and ( utente = p_utente or ( p_utente is null and ( p_check_OLD is null or utente is null ) ) )
           and ( data_agg = p_data_agg or ( p_data_agg is null and ( p_check_OLD is null or data_agg is null ) ) )
           and ( competenza = p_competenza or ( p_competenza is null and ( p_check_OLD is null or competenza is null ) ) )
           and ( tipo_soggetto = p_tipo_soggetto or ( p_tipo_soggetto is null and ( p_check_OLD is null or tipo_soggetto is null ) ) )
           and ( flag_trg = p_flag_trg or ( p_flag_trg is null and ( p_check_OLD is null or flag_trg is null ) ) )
           and ( stato_cee = p_stato_cee or ( p_stato_cee is null and ( p_check_OLD is null or stato_cee is null ) ) )
           and ( partita_iva_cee = p_partita_iva_cee or ( p_partita_iva_cee is null and ( p_check_OLD is null or partita_iva_cee is null ) ) )
           and ( fine_validita = p_fine_validita or ( p_fine_validita is null and ( p_check_OLD is null or fine_validita is null ) ) )
           and ( al = p_al or ( p_al is null and ( p_check_OLD is null or al is null ) ) )
           and ( denominazione = p_denominazione or ( p_denominazione is null and ( p_check_OLD is null or denominazione is null ) ) )
           and ( indirizzo_web = p_indirizzo_web or ( p_indirizzo_web is null and ( p_check_OLD is null or indirizzo_web is null ) ) )
           and ( note = p_note or ( p_note is null and ( p_check_OLD is null or note is null ) ) )
           and ( competenza_esclusiva = p_competenza_esclusiva or ( p_competenza_esclusiva is null and ( p_check_OLD is null or competenza_esclusiva is null ) ) )
           and ( version = p_version or ( p_version is null and ( p_check_OLD is null or version is null ) ) )
           )
       )
   ;
   d_row_found := SQL%ROWCOUNT;
   DbC.ASSERTION ( not DbC.AssertionOn or d_row_found <= 1
                 , 'd_row_found <= 1 on anagrafe_soggetti_tpk.del'
                 );
   if d_row_found < 1
   then
      raise_application_error ( AFC_ERROR.modified_by_other_user_number
                              , AFC_ERROR.modified_by_other_user_msg
                              );
   end if;
   DbC.POST ( not DbC.PostOn or not existsId (
                                               p_ni => p_ni,
p_dal => p_dal
                                             )
            , 'existsId on anagrafe_soggetti_tpk.del'
            );
end del; -- anagrafe_soggetti_tpk.del
--------------------------------------------------------------------------------
function get_cognome
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.cognome%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_cognome
 DESCRIZIONE: Getter per attributo cognome di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.cognome%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.cognome%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_cognome'
           );
   select cognome
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (true)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_cognome'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'cognome')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_cognome'
                    );
   end if;
   return  d_result;
end get_cognome; -- anagrafe_soggetti_tpk.get_cognome
--------------------------------------------------------------------------------
function get_nome
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.nome%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_nome
 DESCRIZIONE: Getter per attributo nome di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.nome%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.nome%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_nome'
           );
   select nome
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_nome'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'nome')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_nome'
                    );
   end if;
   return  d_result;
end get_nome; -- anagrafe_soggetti_tpk.get_nome
--------------------------------------------------------------------------------
function get_sesso
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.sesso%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_sesso
 DESCRIZIONE: Getter per attributo sesso di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.sesso%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.sesso%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_sesso'
           );
   select sesso
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_sesso'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'sesso')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_sesso'
                    );
   end if;
   return  d_result;
end get_sesso; -- anagrafe_soggetti_tpk.get_sesso
--------------------------------------------------------------------------------
function get_data_nas
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.data_nas%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_data_nas
 DESCRIZIONE: Getter per attributo data_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.data_nas%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.data_nas%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_data_nas'
           );
   select data_nas
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_data_nas'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'data_nas')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_data_nas'
                    );
   end if;
   return  d_result;
end get_data_nas; -- anagrafe_soggetti_tpk.get_data_nas
--------------------------------------------------------------------------------
function get_provincia_nas
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.provincia_nas%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_provincia_nas
 DESCRIZIONE: Getter per attributo provincia_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.provincia_nas%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.provincia_nas%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_provincia_nas'
           );
   select provincia_nas
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_provincia_nas'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'provincia_nas')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_provincia_nas'
                    );
   end if;
   return  d_result;
end get_provincia_nas; -- anagrafe_soggetti_tpk.get_provincia_nas
--------------------------------------------------------------------------------
function get_comune_nas
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.comune_nas%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_comune_nas
 DESCRIZIONE: Getter per attributo comune_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.comune_nas%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.comune_nas%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_comune_nas'
           );
   select comune_nas
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_comune_nas'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'comune_nas')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_comune_nas'
                    );
   end if;
   return  d_result;
end get_comune_nas; -- anagrafe_soggetti_tpk.get_comune_nas
--------------------------------------------------------------------------------
function get_luogo_nas
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.luogo_nas%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_luogo_nas
 DESCRIZIONE: Getter per attributo luogo_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.luogo_nas%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.luogo_nas%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_luogo_nas'
           );
   select luogo_nas
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_luogo_nas'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'luogo_nas')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_luogo_nas'
                    );
   end if;
   return  d_result;
end get_luogo_nas; -- anagrafe_soggetti_tpk.get_luogo_nas
--------------------------------------------------------------------------------
function get_codice_fiscale
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.codice_fiscale%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_codice_fiscale
 DESCRIZIONE: Getter per attributo codice_fiscale di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.codice_fiscale%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.codice_fiscale%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_codice_fiscale'
           );
   select codice_fiscale
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_codice_fiscale'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'codice_fiscale')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_codice_fiscale'
                    );
   end if;
   return  d_result;
end get_codice_fiscale; -- anagrafe_soggetti_tpk.get_codice_fiscale
--------------------------------------------------------------------------------
function get_codice_fiscale_estero
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.codice_fiscale_estero%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_codice_fiscale_estero
 DESCRIZIONE: Getter per attributo codice_fiscale_estero di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.codice_fiscale_estero%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.codice_fiscale_estero%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_codice_fiscale_estero'
           );
   select codice_fiscale_estero
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_codice_fiscale_estero'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'codice_fiscale_estero')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_codice_fiscale_estero'
                    );
   end if;
   return  d_result;
end get_codice_fiscale_estero; -- anagrafe_soggetti_tpk.get_codice_fiscale_estero
--------------------------------------------------------------------------------
function get_partita_iva
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.partita_iva%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_partita_iva
 DESCRIZIONE: Getter per attributo partita_iva di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.partita_iva%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.partita_iva%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_partita_iva'
           );
   select partita_iva
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_partita_iva'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'partita_iva')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_partita_iva'
                    );
   end if;
   return  d_result;
end get_partita_iva; -- anagrafe_soggetti_tpk.get_partita_iva
--------------------------------------------------------------------------------
function get_cittadinanza
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.cittadinanza%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_cittadinanza
 DESCRIZIONE: Getter per attributo cittadinanza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.cittadinanza%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.cittadinanza%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_cittadinanza'
           );
   select cittadinanza
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_cittadinanza'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'cittadinanza')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_cittadinanza'
                    );
   end if;
   return  d_result;
end get_cittadinanza; -- anagrafe_soggetti_tpk.get_cittadinanza
--------------------------------------------------------------------------------
function get_gruppo_ling
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.gruppo_ling%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_gruppo_ling
 DESCRIZIONE: Getter per attributo gruppo_ling di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.gruppo_ling%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.gruppo_ling%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_gruppo_ling'
           );
   select gruppo_ling
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_gruppo_ling'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'gruppo_ling')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_gruppo_ling'
                    );
   end if;
   return  d_result;
end get_gruppo_ling; -- anagrafe_soggetti_tpk.get_gruppo_ling
--------------------------------------------------------------------------------
function get_indirizzo_res
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.indirizzo_res%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_indirizzo_res
 DESCRIZIONE: Getter per attributo indirizzo_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.indirizzo_res%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.indirizzo_res%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_indirizzo_res'
           );
   select indirizzo_res
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_indirizzo_res'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'indirizzo_res')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_indirizzo_res'
                    );
   end if;
   return  d_result;
end get_indirizzo_res; -- anagrafe_soggetti_tpk.get_indirizzo_res
--------------------------------------------------------------------------------
function get_provincia_res
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.provincia_res%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_provincia_res
 DESCRIZIONE: Getter per attributo provincia_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.provincia_res%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.provincia_res%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_provincia_res'
           );
   select provincia_res
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_provincia_res'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'provincia_res')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_provincia_res'
                    );
   end if;
   return  d_result;
end get_provincia_res; -- anagrafe_soggetti_tpk.get_provincia_res
--------------------------------------------------------------------------------
function get_comune_res
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.comune_res%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_comune_res
 DESCRIZIONE: Getter per attributo comune_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.comune_res%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.comune_res%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_comune_res'
           );
   select comune_res
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_comune_res'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'comune_res')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_comune_res'
                    );
   end if;
   return  d_result;
end get_comune_res; -- anagrafe_soggetti_tpk.get_comune_res
--------------------------------------------------------------------------------
function get_cap_res
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.cap_res%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_cap_res
 DESCRIZIONE: Getter per attributo cap_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.cap_res%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.cap_res%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_cap_res'
           );
   select cap_res
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_cap_res'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'cap_res')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_cap_res'
                    );
   end if;
   return  d_result;
end get_cap_res; -- anagrafe_soggetti_tpk.get_cap_res
--------------------------------------------------------------------------------
function get_tel_res
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.tel_res%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_tel_res
 DESCRIZIONE: Getter per attributo tel_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.tel_res%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.tel_res%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_tel_res'
           );
   select tel_res
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_tel_res'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'tel_res')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_tel_res'
                    );
   end if;
   return  d_result;
end get_tel_res; -- anagrafe_soggetti_tpk.get_tel_res
--------------------------------------------------------------------------------
function get_fax_res
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.fax_res%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_fax_res
 DESCRIZIONE: Getter per attributo fax_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.fax_res%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.fax_res%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_fax_res'
           );
   select fax_res
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_fax_res'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'fax_res')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_fax_res'
                    );
   end if;
   return  d_result;
end get_fax_res; -- anagrafe_soggetti_tpk.get_fax_res
--------------------------------------------------------------------------------
function get_presso
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.presso%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_presso
 DESCRIZIONE: Getter per attributo presso di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.presso%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.presso%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_presso'
           );
   select presso
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_presso'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'presso')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_presso'
                    );
   end if;
   return  d_result;
end get_presso; -- anagrafe_soggetti_tpk.get_presso
--------------------------------------------------------------------------------
function get_indirizzo_dom
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.indirizzo_dom%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_indirizzo_dom
 DESCRIZIONE: Getter per attributo indirizzo_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.indirizzo_dom%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.indirizzo_dom%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_indirizzo_dom'
           );
   select indirizzo_dom
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_indirizzo_dom'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'indirizzo_dom')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_indirizzo_dom'
                    );
   end if;
   return  d_result;
end get_indirizzo_dom; -- anagrafe_soggetti_tpk.get_indirizzo_dom
--------------------------------------------------------------------------------
function get_provincia_dom
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.provincia_dom%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_provincia_dom
 DESCRIZIONE: Getter per attributo provincia_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.provincia_dom%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.provincia_dom%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_provincia_dom'
           );
   select provincia_dom
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_provincia_dom'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'provincia_dom')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_provincia_dom'
                    );
   end if;
   return  d_result;
end get_provincia_dom; -- anagrafe_soggetti_tpk.get_provincia_dom
--------------------------------------------------------------------------------
function get_comune_dom
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.comune_dom%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_comune_dom
 DESCRIZIONE: Getter per attributo comune_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.comune_dom%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.comune_dom%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_comune_dom'
           );
   select comune_dom
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_comune_dom'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'comune_dom')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_comune_dom'
                    );
   end if;
   return  d_result;
end get_comune_dom; -- anagrafe_soggetti_tpk.get_comune_dom
--------------------------------------------------------------------------------
function get_cap_dom
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.cap_dom%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_cap_dom
 DESCRIZIONE: Getter per attributo cap_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.cap_dom%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.cap_dom%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_cap_dom'
           );
   select cap_dom
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_cap_dom'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'cap_dom')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_cap_dom'
                    );
   end if;
   return  d_result;
end get_cap_dom; -- anagrafe_soggetti_tpk.get_cap_dom
--------------------------------------------------------------------------------
function get_tel_dom
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.tel_dom%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_tel_dom
 DESCRIZIONE: Getter per attributo tel_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.tel_dom%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.tel_dom%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_tel_dom'
           );
   select tel_dom
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_tel_dom'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'tel_dom')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_tel_dom'
                    );
   end if;
   return  d_result;
end get_tel_dom; -- anagrafe_soggetti_tpk.get_tel_dom
--------------------------------------------------------------------------------
function get_fax_dom
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.fax_dom%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_fax_dom
 DESCRIZIONE: Getter per attributo fax_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.fax_dom%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.fax_dom%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_fax_dom'
           );
   select fax_dom
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_fax_dom'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'fax_dom')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_fax_dom'
                    );
   end if;
   return  d_result;
end get_fax_dom; -- anagrafe_soggetti_tpk.get_fax_dom
--------------------------------------------------------------------------------
function get_utente
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.utente%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_utente
 DESCRIZIONE: Getter per attributo utente di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.utente%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.utente%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_utente'
           );
   select utente
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_utente'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'utente')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_utente'
                    );
   end if;
   return  d_result;
end get_utente; -- anagrafe_soggetti_tpk.get_utente
--------------------------------------------------------------------------------
function get_data_agg
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.data_agg%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_data_agg
 DESCRIZIONE: Getter per attributo data_agg di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.data_agg%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.data_agg%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_data_agg'
           );
   select data_agg
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_data_agg'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'data_agg')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_data_agg'
                    );
   end if;
   return  d_result;
end get_data_agg; -- anagrafe_soggetti_tpk.get_data_agg
--------------------------------------------------------------------------------
function get_competenza
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.competenza%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_competenza
 DESCRIZIONE: Getter per attributo competenza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.competenza%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.competenza%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_competenza'
           );
   select competenza
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_competenza'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'competenza')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_competenza'
                    );
   end if;
   return  d_result;
end get_competenza; -- anagrafe_soggetti_tpk.get_competenza
--------------------------------------------------------------------------------
function get_tipo_soggetto
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.tipo_soggetto%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_tipo_soggetto
 DESCRIZIONE: Getter per attributo tipo_soggetto di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.tipo_soggetto%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.tipo_soggetto%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_tipo_soggetto'
           );
   select tipo_soggetto
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_tipo_soggetto'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'tipo_soggetto')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_tipo_soggetto'
                    );
   end if;
   return  d_result;
end get_tipo_soggetto; -- anagrafe_soggetti_tpk.get_tipo_soggetto
--------------------------------------------------------------------------------
function get_flag_trg
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.flag_trg%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_flag_trg
 DESCRIZIONE: Getter per attributo flag_trg di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.flag_trg%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.flag_trg%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_flag_trg'
           );
   select flag_trg
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_flag_trg'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'flag_trg')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_flag_trg'
                    );
   end if;
   return  d_result;
end get_flag_trg; -- anagrafe_soggetti_tpk.get_flag_trg
--------------------------------------------------------------------------------
function get_stato_cee
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.stato_cee%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_stato_cee
 DESCRIZIONE: Getter per attributo stato_cee di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.stato_cee%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.stato_cee%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_stato_cee'
           );
   select stato_cee
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_stato_cee'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'stato_cee')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_stato_cee'
                    );
   end if;
   return  d_result;
end get_stato_cee; -- anagrafe_soggetti_tpk.get_stato_cee
--------------------------------------------------------------------------------
function get_partita_iva_cee
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.partita_iva_cee%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_partita_iva_cee
 DESCRIZIONE: Getter per attributo partita_iva_cee di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.partita_iva_cee%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.partita_iva_cee%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_partita_iva_cee'
           );
   select partita_iva_cee
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_partita_iva_cee'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'partita_iva_cee')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_partita_iva_cee'
                    );
   end if;
   return  d_result;
end get_partita_iva_cee; -- anagrafe_soggetti_tpk.get_partita_iva_cee
--------------------------------------------------------------------------------
function get_fine_validita
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.fine_validita%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_fine_validita
 DESCRIZIONE: Getter per attributo fine_validita di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.fine_validita%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.fine_validita%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_fine_validita'
           );
   select fine_validita
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_fine_validita'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'fine_validita')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_fine_validita'
                    );
   end if;
   return  d_result;
end get_fine_validita; -- anagrafe_soggetti_tpk.get_fine_validita
--------------------------------------------------------------------------------
function get_al
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.al%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_al
 DESCRIZIONE: Getter per attributo al di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.al%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.al%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_al'
           );
   select al
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_al'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'al')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_al'
                    );
   end if;
   return  d_result;
end get_al; -- anagrafe_soggetti_tpk.get_al
--------------------------------------------------------------------------------
function get_denominazione
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.denominazione%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_denominazione
 DESCRIZIONE: Getter per attributo denominazione di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.denominazione%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.denominazione%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_denominazione'
           );
   select denominazione
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_denominazione'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'denominazione')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_denominazione'
                    );
   end if;
   return  d_result;
end get_denominazione; -- anagrafe_soggetti_tpk.get_denominazione
--------------------------------------------------------------------------------
function get_indirizzo_web
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.indirizzo_web%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_indirizzo_web
 DESCRIZIONE: Getter per attributo indirizzo_web di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.indirizzo_web%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.indirizzo_web%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_indirizzo_web'
           );
   select indirizzo_web
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_indirizzo_web'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'indirizzo_web')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_indirizzo_web'
                    );
   end if;
   return  d_result;
end get_indirizzo_web; -- anagrafe_soggetti_tpk.get_indirizzo_web
--------------------------------------------------------------------------------
function get_note
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.note%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_note
 DESCRIZIONE: Getter per attributo note di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.note%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.note%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_note'
           );
   select note
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_note'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'note')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_note'
                    );
   end if;
   return  d_result;
end get_note; -- anagrafe_soggetti_tpk.get_note
--------------------------------------------------------------------------------
function get_competenza_esclusiva
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.competenza_esclusiva%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_competenza_esclusiva
 DESCRIZIONE: Getter per attributo competenza_esclusiva di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.competenza_esclusiva%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.competenza_esclusiva%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_competenza_esclusiva'
           );
   select competenza_esclusiva
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (false)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_competenza_esclusiva'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'competenza_esclusiva')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_competenza_esclusiva'
                    );
   end if;
   return  d_result;
end get_competenza_esclusiva; -- anagrafe_soggetti_tpk.get_competenza_esclusiva
--------------------------------------------------------------------------------
function get_version
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) return ANAGRAFE_SOGGETTI.version%type is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_version
 DESCRIZIONE: Getter per attributo version di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.version%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   d_result ANAGRAFE_SOGGETTI.version%type;
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.get_version'
           );
   select version
   into   d_result
   from   ANAGRAFE_SOGGETTI
   where
   ni = p_ni and
dal = p_dal
   ;
  -- Check Mandatory Attribute on Table
  if (true)  -- is Mandatory on Table ?
  then -- Result must be not null
      DbC.POST ( not DbC.PostOn  or  d_result is not null
               , 'd_result is not null on anagrafe_soggetti_tpk.get_version'
               );
   else -- Column must nullable on table
      DbC.ASSERTION ( not DbC.AssertionOn  or  AFC_DDL.IsNullable ( s_table_name, 'version')
                    , ' AFC_DDL.IsNullable on anagrafe_soggetti_tpk.get_version'
                    );
   end if;
   return  d_result;
end get_version; -- anagrafe_soggetti_tpk.get_version
--------------------------------------------------------------------------------
procedure set_ni
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.ni%type default null
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
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_ni'
           );
   update ANAGRAFE_SOGGETTI
   set ni = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_ni; -- anagrafe_soggetti_tpk.set_ni
--------------------------------------------------------------------------------
procedure set_dal
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.dal%type default null
) is
/******************************************************************************
 NOME:        set_dal
 DESCRIZIONE: Setter per attributo dal di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_dal'
           );
   update ANAGRAFE_SOGGETTI
   set dal = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_dal; -- anagrafe_soggetti_tpk.set_dal
--------------------------------------------------------------------------------
procedure set_cognome
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.cognome%type default null
) is
/******************************************************************************
 NOME:        set_cognome
 DESCRIZIONE: Setter per attributo cognome di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_cognome'
           );
   update ANAGRAFE_SOGGETTI
   set cognome = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_cognome; -- anagrafe_soggetti_tpk.set_cognome
--------------------------------------------------------------------------------
procedure set_nome
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.nome%type default null
) is
/******************************************************************************
 NOME:        set_nome
 DESCRIZIONE: Setter per attributo nome di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_nome'
           );
   update ANAGRAFE_SOGGETTI
   set nome = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_nome; -- anagrafe_soggetti_tpk.set_nome
--------------------------------------------------------------------------------
procedure set_sesso
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.sesso%type default null
) is
/******************************************************************************
 NOME:        set_sesso
 DESCRIZIONE: Setter per attributo sesso di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_sesso'
           );
   update ANAGRAFE_SOGGETTI
   set sesso = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_sesso; -- anagrafe_soggetti_tpk.set_sesso
--------------------------------------------------------------------------------
procedure set_data_nas
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.data_nas%type default null
) is
/******************************************************************************
 NOME:        set_data_nas
 DESCRIZIONE: Setter per attributo data_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_data_nas'
           );
   update ANAGRAFE_SOGGETTI
   set data_nas = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_data_nas; -- anagrafe_soggetti_tpk.set_data_nas
--------------------------------------------------------------------------------
procedure set_provincia_nas
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.provincia_nas%type default null
) is
/******************************************************************************
 NOME:        set_provincia_nas
 DESCRIZIONE: Setter per attributo provincia_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_provincia_nas'
           );
   update ANAGRAFE_SOGGETTI
   set provincia_nas = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_provincia_nas; -- anagrafe_soggetti_tpk.set_provincia_nas
--------------------------------------------------------------------------------
procedure set_comune_nas
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.comune_nas%type default null
) is
/******************************************************************************
 NOME:        set_comune_nas
 DESCRIZIONE: Setter per attributo comune_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_comune_nas'
           );
   update ANAGRAFE_SOGGETTI
   set comune_nas = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_comune_nas; -- anagrafe_soggetti_tpk.set_comune_nas
--------------------------------------------------------------------------------
procedure set_luogo_nas
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.luogo_nas%type default null
) is
/******************************************************************************
 NOME:        set_luogo_nas
 DESCRIZIONE: Setter per attributo luogo_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_luogo_nas'
           );
   update ANAGRAFE_SOGGETTI
   set luogo_nas = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_luogo_nas; -- anagrafe_soggetti_tpk.set_luogo_nas
--------------------------------------------------------------------------------
procedure set_codice_fiscale
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.codice_fiscale%type default null
) is
/******************************************************************************
 NOME:        set_codice_fiscale
 DESCRIZIONE: Setter per attributo codice_fiscale di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_codice_fiscale'
           );
   update ANAGRAFE_SOGGETTI
   set codice_fiscale = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_codice_fiscale; -- anagrafe_soggetti_tpk.set_codice_fiscale
--------------------------------------------------------------------------------
procedure set_codice_fiscale_estero
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.codice_fiscale_estero%type default null
) is
/******************************************************************************
 NOME:        set_codice_fiscale_estero
 DESCRIZIONE: Setter per attributo codice_fiscale_estero di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_codice_fiscale_estero'
           );
   update ANAGRAFE_SOGGETTI
   set codice_fiscale_estero = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_codice_fiscale_estero; -- anagrafe_soggetti_tpk.set_codice_fiscale_estero
--------------------------------------------------------------------------------
procedure set_partita_iva
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.partita_iva%type default null
) is
/******************************************************************************
 NOME:        set_partita_iva
 DESCRIZIONE: Setter per attributo partita_iva di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_partita_iva'
           );
   update ANAGRAFE_SOGGETTI
   set partita_iva = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_partita_iva; -- anagrafe_soggetti_tpk.set_partita_iva
--------------------------------------------------------------------------------
procedure set_cittadinanza
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.cittadinanza%type default null
) is
/******************************************************************************
 NOME:        set_cittadinanza
 DESCRIZIONE: Setter per attributo cittadinanza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_cittadinanza'
           );
   update ANAGRAFE_SOGGETTI
   set cittadinanza = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_cittadinanza; -- anagrafe_soggetti_tpk.set_cittadinanza
--------------------------------------------------------------------------------
procedure set_gruppo_ling
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.gruppo_ling%type default null
) is
/******************************************************************************
 NOME:        set_gruppo_ling
 DESCRIZIONE: Setter per attributo gruppo_ling di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_gruppo_ling'
           );
   update ANAGRAFE_SOGGETTI
   set gruppo_ling = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_gruppo_ling; -- anagrafe_soggetti_tpk.set_gruppo_ling
--------------------------------------------------------------------------------
procedure set_indirizzo_res
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.indirizzo_res%type default null
) is
/******************************************************************************
 NOME:        set_indirizzo_res
 DESCRIZIONE: Setter per attributo indirizzo_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_indirizzo_res'
           );
   update ANAGRAFE_SOGGETTI
   set indirizzo_res = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_indirizzo_res; -- anagrafe_soggetti_tpk.set_indirizzo_res
--------------------------------------------------------------------------------
procedure set_provincia_res
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.provincia_res%type default null
) is
/******************************************************************************
 NOME:        set_provincia_res
 DESCRIZIONE: Setter per attributo provincia_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_provincia_res'
           );
   update ANAGRAFE_SOGGETTI
   set provincia_res = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_provincia_res; -- anagrafe_soggetti_tpk.set_provincia_res
--------------------------------------------------------------------------------
procedure set_comune_res
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.comune_res%type default null
) is
/******************************************************************************
 NOME:        set_comune_res
 DESCRIZIONE: Setter per attributo comune_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_comune_res'
           );
   update ANAGRAFE_SOGGETTI
   set comune_res = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_comune_res; -- anagrafe_soggetti_tpk.set_comune_res
--------------------------------------------------------------------------------
procedure set_cap_res
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.cap_res%type default null
) is
/******************************************************************************
 NOME:        set_cap_res
 DESCRIZIONE: Setter per attributo cap_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_cap_res'
           );
   update ANAGRAFE_SOGGETTI
   set cap_res = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_cap_res; -- anagrafe_soggetti_tpk.set_cap_res
--------------------------------------------------------------------------------
procedure set_tel_res
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.tel_res%type default null
) is
/******************************************************************************
 NOME:        set_tel_res
 DESCRIZIONE: Setter per attributo tel_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_tel_res'
           );
   update ANAGRAFE_SOGGETTI
   set tel_res = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_tel_res; -- anagrafe_soggetti_tpk.set_tel_res
--------------------------------------------------------------------------------
procedure set_fax_res
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.fax_res%type default null
) is
/******************************************************************************
 NOME:        set_fax_res
 DESCRIZIONE: Setter per attributo fax_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_fax_res'
           );
   update ANAGRAFE_SOGGETTI
   set fax_res = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_fax_res; -- anagrafe_soggetti_tpk.set_fax_res
--------------------------------------------------------------------------------
procedure set_presso
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.presso%type default null
) is
/******************************************************************************
 NOME:        set_presso
 DESCRIZIONE: Setter per attributo presso di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_presso'
           );
   update ANAGRAFE_SOGGETTI
   set presso = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_presso; -- anagrafe_soggetti_tpk.set_presso
--------------------------------------------------------------------------------
procedure set_indirizzo_dom
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.indirizzo_dom%type default null
) is
/******************************************************************************
 NOME:        set_indirizzo_dom
 DESCRIZIONE: Setter per attributo indirizzo_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_indirizzo_dom'
           );
   update ANAGRAFE_SOGGETTI
   set indirizzo_dom = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_indirizzo_dom; -- anagrafe_soggetti_tpk.set_indirizzo_dom
--------------------------------------------------------------------------------
procedure set_provincia_dom
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.provincia_dom%type default null
) is
/******************************************************************************
 NOME:        set_provincia_dom
 DESCRIZIONE: Setter per attributo provincia_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_provincia_dom'
           );
   update ANAGRAFE_SOGGETTI
   set provincia_dom = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_provincia_dom; -- anagrafe_soggetti_tpk.set_provincia_dom
--------------------------------------------------------------------------------
procedure set_comune_dom
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.comune_dom%type default null
) is
/******************************************************************************
 NOME:        set_comune_dom
 DESCRIZIONE: Setter per attributo comune_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_comune_dom'
           );
   update ANAGRAFE_SOGGETTI
   set comune_dom = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_comune_dom; -- anagrafe_soggetti_tpk.set_comune_dom
--------------------------------------------------------------------------------
procedure set_cap_dom
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.cap_dom%type default null
) is
/******************************************************************************
 NOME:        set_cap_dom
 DESCRIZIONE: Setter per attributo cap_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_cap_dom'
           );
   update ANAGRAFE_SOGGETTI
   set cap_dom = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_cap_dom; -- anagrafe_soggetti_tpk.set_cap_dom
--------------------------------------------------------------------------------
procedure set_tel_dom
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.tel_dom%type default null
) is
/******************************************************************************
 NOME:        set_tel_dom
 DESCRIZIONE: Setter per attributo tel_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_tel_dom'
           );
   update ANAGRAFE_SOGGETTI
   set tel_dom = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_tel_dom; -- anagrafe_soggetti_tpk.set_tel_dom
--------------------------------------------------------------------------------
procedure set_fax_dom
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.fax_dom%type default null
) is
/******************************************************************************
 NOME:        set_fax_dom
 DESCRIZIONE: Setter per attributo fax_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_fax_dom'
           );
   update ANAGRAFE_SOGGETTI
   set fax_dom = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_fax_dom; -- anagrafe_soggetti_tpk.set_fax_dom
--------------------------------------------------------------------------------
procedure set_utente
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.utente%type default null
) is
/******************************************************************************
 NOME:        set_utente
 DESCRIZIONE: Setter per attributo utente di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_utente'
           );
   update ANAGRAFE_SOGGETTI
   set utente = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_utente; -- anagrafe_soggetti_tpk.set_utente
--------------------------------------------------------------------------------
procedure set_data_agg
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.data_agg%type default null
) is
/******************************************************************************
 NOME:        set_data_agg
 DESCRIZIONE: Setter per attributo data_agg di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_data_agg'
           );
   update ANAGRAFE_SOGGETTI
   set data_agg = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_data_agg; -- anagrafe_soggetti_tpk.set_data_agg
--------------------------------------------------------------------------------
procedure set_competenza
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.competenza%type default null
) is
/******************************************************************************
 NOME:        set_competenza
 DESCRIZIONE: Setter per attributo competenza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_competenza'
           );
   update ANAGRAFE_SOGGETTI
   set competenza = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_competenza; -- anagrafe_soggetti_tpk.set_competenza
--------------------------------------------------------------------------------
procedure set_tipo_soggetto
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.tipo_soggetto%type default null
) is
/******************************************************************************
 NOME:        set_tipo_soggetto
 DESCRIZIONE: Setter per attributo tipo_soggetto di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_tipo_soggetto'
           );
   update ANAGRAFE_SOGGETTI
   set tipo_soggetto = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_tipo_soggetto; -- anagrafe_soggetti_tpk.set_tipo_soggetto
--------------------------------------------------------------------------------
procedure set_flag_trg
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.flag_trg%type default null
) is
/******************************************************************************
 NOME:        set_flag_trg
 DESCRIZIONE: Setter per attributo flag_trg di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_flag_trg'
           );
   update ANAGRAFE_SOGGETTI
   set flag_trg = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_flag_trg; -- anagrafe_soggetti_tpk.set_flag_trg
--------------------------------------------------------------------------------
procedure set_stato_cee
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.stato_cee%type default null
) is
/******************************************************************************
 NOME:        set_stato_cee
 DESCRIZIONE: Setter per attributo stato_cee di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_stato_cee'
           );
   update ANAGRAFE_SOGGETTI
   set stato_cee = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_stato_cee; -- anagrafe_soggetti_tpk.set_stato_cee
--------------------------------------------------------------------------------
procedure set_partita_iva_cee
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.partita_iva_cee%type default null
) is
/******************************************************************************
 NOME:        set_partita_iva_cee
 DESCRIZIONE: Setter per attributo partita_iva_cee di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_partita_iva_cee'
           );
   update ANAGRAFE_SOGGETTI
   set partita_iva_cee = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_partita_iva_cee; -- anagrafe_soggetti_tpk.set_partita_iva_cee
--------------------------------------------------------------------------------
procedure set_fine_validita
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.fine_validita%type default null
) is
/******************************************************************************
 NOME:        set_fine_validita
 DESCRIZIONE: Setter per attributo fine_validita di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_fine_validita'
           );
   update ANAGRAFE_SOGGETTI
   set fine_validita = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_fine_validita; -- anagrafe_soggetti_tpk.set_fine_validita
--------------------------------------------------------------------------------
procedure set_al
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.al%type default null
) is
/******************************************************************************
 NOME:        set_al
 DESCRIZIONE: Setter per attributo al di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_al'
           );
   update ANAGRAFE_SOGGETTI
   set al = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_al; -- anagrafe_soggetti_tpk.set_al
--------------------------------------------------------------------------------
procedure set_denominazione
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.denominazione%type default null
) is
/******************************************************************************
 NOME:        set_denominazione
 DESCRIZIONE: Setter per attributo denominazione di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_denominazione'
           );
   update ANAGRAFE_SOGGETTI
   set denominazione = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_denominazione; -- anagrafe_soggetti_tpk.set_denominazione
--------------------------------------------------------------------------------
procedure set_indirizzo_web
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.indirizzo_web%type default null
) is
/******************************************************************************
 NOME:        set_indirizzo_web
 DESCRIZIONE: Setter per attributo indirizzo_web di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_indirizzo_web'
           );
   update ANAGRAFE_SOGGETTI
   set indirizzo_web = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_indirizzo_web; -- anagrafe_soggetti_tpk.set_indirizzo_web
--------------------------------------------------------------------------------
procedure set_note
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.note%type default null
) is
/******************************************************************************
 NOME:        set_note
 DESCRIZIONE: Setter per attributo note di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_note'
           );
   update ANAGRAFE_SOGGETTI
   set note = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_note; -- anagrafe_soggetti_tpk.set_note
--------------------------------------------------------------------------------
procedure set_competenza_esclusiva
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.competenza_esclusiva%type default null
) is
/******************************************************************************
 NOME:        set_competenza_esclusiva
 DESCRIZIONE: Setter per attributo competenza_esclusiva di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_competenza_esclusiva'
           );
   update ANAGRAFE_SOGGETTI
   set competenza_esclusiva = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_competenza_esclusiva; -- anagrafe_soggetti_tpk.set_competenza_esclusiva
--------------------------------------------------------------------------------
procedure set_version
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
, p_value  in ANAGRAFE_SOGGETTI.version%type default null
) is
/******************************************************************************
 NOME:        set_version
 DESCRIZIONE: Setter per attributo version di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
begin
   DbC.PRE ( not DbC.PreOn or  existsId (
                                          p_ni => p_ni
, p_dal => p_dal
                                        )
           , 'existsId on anagrafe_soggetti_tpk.set_version'
           );
   update ANAGRAFE_SOGGETTI
   set version = p_value
   where
   ni = p_ni and
dal = p_dal
   ;
end set_version; -- anagrafe_soggetti_tpk.set_version
--------------------------------------------------------------------------------
function where_condition /* SLAVE_COPY */
( p_QBE  in number default 0
, p_other_condition in varchar2 default null
, p_ni  in varchar2 default null
, p_dal  in varchar2 default null
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
, p_indirizzo_res  in varchar2 default null
, p_provincia_res  in varchar2 default null
, p_comune_res  in varchar2 default null
, p_cap_res  in varchar2 default null
, p_tel_res  in varchar2 default null
, p_fax_res  in varchar2 default null
, p_presso  in varchar2 default null
, p_indirizzo_dom  in varchar2 default null
, p_provincia_dom  in varchar2 default null
, p_comune_dom  in varchar2 default null
, p_cap_dom  in varchar2 default null
, p_tel_dom  in varchar2 default null
, p_fax_dom  in varchar2 default null
, p_utente  in varchar2 default null
, p_data_agg  in varchar2 default null
, p_competenza  in varchar2 default null
, p_tipo_soggetto  in varchar2 default null
, p_flag_trg  in varchar2 default null
, p_stato_cee  in varchar2 default null
, p_partita_iva_cee  in varchar2 default null
, p_fine_validita  in varchar2 default null
, p_al  in varchar2 default null
, p_denominazione  in varchar2 default null
, p_indirizzo_web  in varchar2 default null
, p_note  in varchar2 default null
, p_competenza_esclusiva  in varchar2 default null
, p_version  in varchar2 default null
) return AFC.t_statement is /* SLAVE_COPY */
/******************************************************************************
 NOME:        where_condition
 DESCRIZIONE: Ritorna la where_condition per lo statement di select di get_rows e count_rows.
 PARAMETRI:   p_QBE 0: viene controllato se all'inizio di ogni attributo è presente
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
               || AFC.get_field_condition( ' and ( ni ', p_ni, ' )', p_QBE, null )
|| AFC.get_field_condition( ' and ( dal ', p_dal, ' )', p_QBE, AFC.date_format )
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
               || AFC.get_field_condition( ' and ( indirizzo_res ', p_indirizzo_res , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( provincia_res ', p_provincia_res , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( comune_res ', p_comune_res , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( cap_res ', p_cap_res , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( tel_res ', p_tel_res , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( fax_res ', p_fax_res , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( presso ', p_presso , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( indirizzo_dom ', p_indirizzo_dom , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( provincia_dom ', p_provincia_dom , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( comune_dom ', p_comune_dom , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( cap_dom ', p_cap_dom , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( tel_dom ', p_tel_dom , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( fax_dom ', p_fax_dom , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( utente ', p_utente , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( data_agg ', p_data_agg , ' )', p_QBE, AFC.date_format )
               || AFC.get_field_condition( ' and ( competenza ', p_competenza , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( tipo_soggetto ', p_tipo_soggetto , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( flag_trg ', p_flag_trg , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( stato_cee ', p_stato_cee , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( partita_iva_cee ', p_partita_iva_cee , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( fine_validita ', p_fine_validita , ' )', p_QBE, AFC.date_format )
               || AFC.get_field_condition( ' and ( al ', p_al , ' )', p_QBE, AFC.date_format )
               || AFC.get_field_condition( ' and ( denominazione ', p_denominazione , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( indirizzo_web ', p_indirizzo_web , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( note ', p_note , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( competenza_esclusiva ', p_competenza_esclusiva , ' )', p_QBE, null )
               || AFC.get_field_condition( ' and ( version ', p_version , ' )', p_QBE, null )
               || ' ) ' || p_other_condition
               ;
   return d_statement;
end where_condition; --- anagrafe_soggetti_tpk.where_condition
--------------------------------------------------------------------------------
function get_rows
( p_QBE  in number default 0
, p_other_condition in varchar2 default null
, p_order_by in varchar2 default null
, p_extra_columns in varchar2 default null
, p_extra_condition in varchar2 default null
, p_ni  in varchar2 default null
, p_dal  in varchar2 default null
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
, p_indirizzo_res  in varchar2 default null
, p_provincia_res  in varchar2 default null
, p_comune_res  in varchar2 default null
, p_cap_res  in varchar2 default null
, p_tel_res  in varchar2 default null
, p_fax_res  in varchar2 default null
, p_presso  in varchar2 default null
, p_indirizzo_dom  in varchar2 default null
, p_provincia_dom  in varchar2 default null
, p_comune_dom  in varchar2 default null
, p_cap_dom  in varchar2 default null
, p_tel_dom  in varchar2 default null
, p_fax_dom  in varchar2 default null
, p_utente  in varchar2 default null
, p_data_agg  in varchar2 default null
, p_competenza  in varchar2 default null
, p_tipo_soggetto  in varchar2 default null
, p_flag_trg  in varchar2 default null
, p_stato_cee  in varchar2 default null
, p_partita_iva_cee  in varchar2 default null
, p_fine_validita  in varchar2 default null
, p_al  in varchar2 default null
, p_denominazione  in varchar2 default null
, p_indirizzo_web  in varchar2 default null
, p_note  in varchar2 default null
, p_competenza_esclusiva  in varchar2 default null
, p_version  in varchar2 default null
) return AFC.t_ref_cursor is /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_rows
 DESCRIZIONE: Ritorna il risultato di una query in base ai valori che passiamo.
 PARAMETRI:   p_QBE 0: viene controllato se all'inizio di ogni attributo è presente
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
   d_statement := ' select ANAGRAFE_SOGGETTI.* '
               || afc.decode_value( p_extra_columns, null, null, ' , ' || p_extra_columns )
               || ' from ANAGRAFE_SOGGETTI '
               || where_condition(
                                   p_QBE => p_QBE
                                 , p_other_condition => p_other_condition
                                 , p_ni => p_ni
, p_dal => p_dal
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
                                 , p_indirizzo_res => p_indirizzo_res
                                 , p_provincia_res => p_provincia_res
                                 , p_comune_res => p_comune_res
                                 , p_cap_res => p_cap_res
                                 , p_tel_res => p_tel_res
                                 , p_fax_res => p_fax_res
                                 , p_presso => p_presso
                                 , p_indirizzo_dom => p_indirizzo_dom
                                 , p_provincia_dom => p_provincia_dom
                                 , p_comune_dom => p_comune_dom
                                 , p_cap_dom => p_cap_dom
                                 , p_tel_dom => p_tel_dom
                                 , p_fax_dom => p_fax_dom
                                 , p_utente => p_utente
                                 , p_data_agg => p_data_agg
                                 , p_competenza => p_competenza
                                 , p_tipo_soggetto => p_tipo_soggetto
                                 , p_flag_trg => p_flag_trg
                                 , p_stato_cee => p_stato_cee
                                 , p_partita_iva_cee => p_partita_iva_cee
                                 , p_fine_validita => p_fine_validita
                                 , p_al => p_al
                                 , p_denominazione => p_denominazione
                                 , p_indirizzo_web => p_indirizzo_web
                                 , p_note => p_note
                                 , p_competenza_esclusiva => p_competenza_esclusiva
                                 , p_version => p_version
                                 )
               || ' ' || p_extra_condition
               || afc.decode_value( p_order_by, null, null, ' order by ' || p_order_by )
               ;
   d_ref_cursor := AFC_DML.get_ref_cursor( d_statement );
   return d_ref_cursor;
end get_rows; -- anagrafe_soggetti_tpk.get_rows
--------------------------------------------------------------------------------
function count_rows
( p_QBE  in number default 0
, p_other_condition in varchar2 default null
, p_ni  in varchar2 default null
, p_dal  in varchar2 default null
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
, p_indirizzo_res  in varchar2 default null
, p_provincia_res  in varchar2 default null
, p_comune_res  in varchar2 default null
, p_cap_res  in varchar2 default null
, p_tel_res  in varchar2 default null
, p_fax_res  in varchar2 default null
, p_presso  in varchar2 default null
, p_indirizzo_dom  in varchar2 default null
, p_provincia_dom  in varchar2 default null
, p_comune_dom  in varchar2 default null
, p_cap_dom  in varchar2 default null
, p_tel_dom  in varchar2 default null
, p_fax_dom  in varchar2 default null
, p_utente  in varchar2 default null
, p_data_agg  in varchar2 default null
, p_competenza  in varchar2 default null
, p_tipo_soggetto  in varchar2 default null
, p_flag_trg  in varchar2 default null
, p_stato_cee  in varchar2 default null
, p_partita_iva_cee  in varchar2 default null
, p_fine_validita  in varchar2 default null
, p_al  in varchar2 default null
, p_denominazione  in varchar2 default null
, p_indirizzo_web  in varchar2 default null
, p_note  in varchar2 default null
, p_competenza_esclusiva  in varchar2 default null
, p_version  in varchar2 default null
) return integer is /* SLAVE_COPY */
/******************************************************************************
 NOME:        count_rows
 DESCRIZIONE: Ritorna il numero di righe della tabella gli attributi delle quali
              rispettano i valori indicati.
 PARAMETRI:   p_QBE 0: viene controllato se all'inizio di ogni attributo è presente
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
   d_statement := ' select count( * ) from ANAGRAFE_SOGGETTI '
               || where_condition(
                                   p_QBE => p_QBE
                                 , p_other_condition => p_other_condition
                                 , p_ni => p_ni
, p_dal => p_dal
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
                                 , p_indirizzo_res => p_indirizzo_res
                                 , p_provincia_res => p_provincia_res
                                 , p_comune_res => p_comune_res
                                 , p_cap_res => p_cap_res
                                 , p_tel_res => p_tel_res
                                 , p_fax_res => p_fax_res
                                 , p_presso => p_presso
                                 , p_indirizzo_dom => p_indirizzo_dom
                                 , p_provincia_dom => p_provincia_dom
                                 , p_comune_dom => p_comune_dom
                                 , p_cap_dom => p_cap_dom
                                 , p_tel_dom => p_tel_dom
                                 , p_fax_dom => p_fax_dom
                                 , p_utente => p_utente
                                 , p_data_agg => p_data_agg
                                 , p_competenza => p_competenza
                                 , p_tipo_soggetto => p_tipo_soggetto
                                 , p_flag_trg => p_flag_trg
                                 , p_stato_cee => p_stato_cee
                                 , p_partita_iva_cee => p_partita_iva_cee
                                 , p_fine_validita => p_fine_validita
                                 , p_al => p_al
                                 , p_denominazione => p_denominazione
                                 , p_indirizzo_web => p_indirizzo_web
                                 , p_note => p_note
                                 , p_competenza_esclusiva => p_competenza_esclusiva
                                 , p_version => p_version
                                 );
   d_result := AFC.SQL_execute( d_statement );
   return d_result;
end count_rows; -- anagrafe_soggetti_tpk.count_rows
--------------------------------------------------------------------------------
end anagrafe_soggetti_tpk;
/

