CREATE OR REPLACE PACKAGE BODY as4so4_pkg
IS
/******************************************************************************
 NOME:        anagrafe_soggetti_pkg
 DESCRIZIONE: Gestione tabella anagrafe_soggetti.
 ANNOTAZIONI: .
 REVISIONI:   .
 Rev.  Data        Autore   Descrizione.
 000   07/06/2018  ADADAMO  Prima emissione.
 001   06/08/2018  ADADAMO  Corretto funzionamento della rettifica di un indirizzo
                            telematico nel caso abbia decorrenza uguale al giorno 
                            corrente
 002   27/03/2019 SNegroni  recupera_note_con_codice_amm x recupero note da
                            validita precedente
 003   23/09/2019 SNegroni  Modificata chiusura record
 004   29/12/2020  SN       Chiusura cursore aperto Bug #47059
 005   15/03/2022  MM       #54239
 006   26/01/2023  MM       #60726
******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision          := '006';
   s_error_table AFC_Error.t_error_table;


--------------------------------------------------------------------------------
   FUNCTION versione
      RETURN VARCHAR2
   IS /* SLAVE_COPY */
/******************************************************************************
 NOME:        versione
 DESCRIZIONE: Versione e revisione di distribuzione del package.
 RITORNA:     varchar2 stringa contenente versione e revisione.
 NOTE:        Primo numero  : versione compatibilita del Package.
              Secondo numero: revisione del Package specification.
              Terzo numero  : revisione del Package body.
******************************************************************************/
   BEGIN
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END versione;                             -- anagrafe_soggetti_pkg.versione
--------------------------------------------------------------------------------
procedure set_trasco_on
IS
BEGIN
s_trasco_on := 1;
anagrafici_pkg.trasco:= 1;
END;

procedure set_trasco_off
IS
BEGIN
s_trasco_on := 0;
anagrafici_pkg.trasco:= 0;
END;

procedure allinea_indirizzo_telematico
( p_ni_as4              in anagrafici.ni%type
, p_id_tipo_contatto    in contatti.id_tipo_contatto%type
, p_indirizzo           in contatti.valore%type
, p_old_indirizzo       in contatti.valore%type
, p_utente_agg          in contatti.utente_aggiornamento%type
)
IS
    d_id_recapito   number;
    d_ref_cursor    afc.t_ref_cursor;
    contatto_row    CONTATTI_TPK.T_ROWTYPE;
    d_id_contatto   number;
    d_tipo_anagrafe varchar2(1) := 'O'; -- vecchia anagrafica
    rettifica       boolean := false;
    --#60726
    d_utente_aggiornamento_ipa  contatti.utente_aggiornamento%type := null;
    d_competenza                anagrafici.competenza%type := null;
begin
    set_competenza_ipa(d_utente_aggiornamento_ipa,d_competenza);
    if p_utente_agg = d_utente_aggiornamento_ipa then --#60726
       d_competenza := as4so4_pkg.s_competenza_ipa;
    else
       d_competenza := 'SI4SO';
    end if;
    ANAGRAFICI_PKG.TRASCO := AS4SO4_PKG.s_trasco_on;
    if p_indirizzo is not null then -- è il caso in cui sto inserendo o aggiornando un indirizzo telematico
        d_id_recapito := ANAGRAFE_SOGGETTI_WS_PKG.GET_ID_RECAPITO_RES(p_ni_as4, trunc(sysdate));
        if d_id_recapito is not null then
            d_ref_cursor := contatti_tpk.get_rows( P_ID_RECAPITO => d_id_recapito, p_id_tipo_contatto=> p_id_tipo_contatto, p_other_condition => ' and upper(valore) = upper('''||p_old_indirizzo||''') and trunc(sysdate) between dal and nvl(al,to_date(3333333,''j'')) ');
            fetch d_ref_cursor into contatto_row;
            if contatto_row.id_contatto is not null and p_indirizzo != nvl(p_old_indirizzo,'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX') then -- contatto già codificato
                -- devo chiudere il precedente
                if contatto_row.dal = trunc(sysdate) then -- è una rettifica immediata
                    CONTATTI_TPK.SET_VALORE(contatto_row.id_contatto, p_indirizzo);
                    rettifica := true;
                else
                    contatti_tpk.upd( p_NEW_id_contatto => contatto_row.id_contatto
                                    , p_OLD_id_contatto  => contatto_row.id_contatto
                                    , p_NEW_id_recapito  => d_id_recapito
                                    , p_OLD_id_recapito  => d_id_recapito
                                    , p_NEW_dal  => contatto_row.dal
                                    , p_OLD_dal  => contatto_row.dal
                                    , p_NEW_al  => trunc(sysdate)-1
                                    , p_OLD_al  => contatto_row.al
                                    , p_NEW_valore  => contatto_row.valore
                                    , p_OLD_valore  => contatto_row.valore
                                    , p_NEW_id_tipo_contatto  => contatto_row.id_tipo_contatto
                                    , p_OLD_id_tipo_contatto  => contatto_row.id_tipo_contatto
                                    , p_NEW_note  => contatto_row.NOTE
                                    , p_OLD_note  => contatto_row.NOTE
                                    , p_NEW_importanza  => contatto_row.importanza
                                    , p_OLD_importanza   => contatto_row.importanza
                                    , p_NEW_competenza   => contatto_row.competenza
                                    , p_OLD_competenza   => contatto_row.competenza
                                    , p_NEW_competenza_esclusiva   => contatto_row.competenza_esclusiva
                                    , p_OLD_competenza_esclusiva   => contatto_row.competenza_esclusiva
                                    , p_NEW_version   => contatto_row.VERSION
                                    , p_OLD_version   => contatto_row.VERSION
                                    , p_NEW_utente_aggiornamento   => P_UTENTE_AGG
                                    , p_OLD_utente_aggiornamento   => contatto_row.UTENTE_AGGIORNAMENTO
                                    , p_NEW_data_aggiornamento   => SYSDATE
                                    , p_OLD_data_aggiornamento   => contatto_row.DATA_AGGIORNAMENTO
                    );
                end if;
            end if;
        else
           d_id_recapito :=  RECAPITI_TPK.INS( p_ni  => p_ni_as4
                                             , p_dal  => trunc(sysdate)
                                             , p_al  => null
                                             , p_descrizione  => null
                                             , p_id_tipo_recapito  => 1  -- fisso residenza
                                             , p_indirizzo  => null
                                             , p_provincia   => null
                                             , p_comune   => null
                                             , p_cap   => null
                                             , p_presso  => null
                                             , p_importanza  => null
                                             , p_competenza  => d_competenza --#60726
                                             , p_competenza_esclusiva  => 'E'
                                             , p_version  => 0
                                             , p_utente_aggiornamento  => P_UTENTE_AGG
                                             , p_data_aggiornamento => sysdate
                                             );
        end if;
        if not rettifica and
         p_indirizzo != nvl(p_old_indirizzo,'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
            then
             -- rev. 003 inizio
            d_ref_cursor := contatti_tpk.get_rows( P_ID_RECAPITO => d_id_recapito, p_id_tipo_contatto=> p_id_tipo_contatto, p_other_condition => ' and upper(valore) = upper('''||p_indirizzo||''') and trunc(sysdate) between dal and nvl(al,to_date(3333333,''j'')) ');
            fetch d_ref_cursor into contatto_row;
            if contatto_row.id_contatto is null then -- contatto non già codificato e valido ad oggi
                contatti_tpk.ins( p_id_recapito  => d_id_recapito
                                , p_dal  => trunc(sysdate)
                                , p_valore  => p_indirizzo
                                , p_id_tipo_contatto  => p_id_tipo_contatto
                                , p_competenza  => d_competenza --#60726
                                , p_competenza_esclusiva  => 'E'
                                , p_utente_aggiornamento  => p_utente_agg
                                , p_data_aggiornamento => sysdate
                                );
            else -- contatto esistente e valido da oggi ad oggi
             if contatto_row.dal = trunc(sysdate) and contatto_row.al = trunc(sysdate) then
               -- risulta chiuso, lo riapro
                contatti_tpk.set_al(contatto_row.id_contatto,null);
             end if;
             -- rev. 003 fine
            end if;
        end if;
    else    -- indirizzo telematico cancellato
        d_id_recapito := ANAGRAFE_SOGGETTI_WS_PKG.GET_ID_RECAPITO_RES(p_ni_as4, trunc(sysdate));
        if d_id_recapito is not null then
            d_ref_cursor := contatti_tpk.get_rows( P_ID_RECAPITO => d_id_recapito, p_id_tipo_contatto=> p_id_tipo_contatto, p_other_condition => ' and upper(valore) = upper('''||p_old_indirizzo||''') and trunc(sysdate) between dal and nvl(al,to_date(3333333,''j'')) ');
            fetch d_ref_cursor into contatto_row;
            contatti_tpk.upd( p_NEW_id_contatto => contatto_row.id_contatto
                            , p_OLD_id_contatto  => contatto_row.id_contatto
                            , p_NEW_id_recapito  => d_id_recapito
                            , p_OLD_id_recapito  => d_id_recapito
                            , p_NEW_dal  => contatto_row.dal
                            , p_OLD_dal  => contatto_row.dal
                            , p_NEW_al  => trunc(sysdate) -- chiudo il contatto ad oggi
                            , p_OLD_al  => contatto_row.al
                            , p_NEW_valore  => contatto_row.valore
                            , p_OLD_valore  => contatto_row.valore
                            , p_NEW_id_tipo_contatto  => contatto_row.id_tipo_contatto
                            , p_OLD_id_tipo_contatto  => contatto_row.id_tipo_contatto
                            , p_NEW_note  => contatto_row.NOTE
                            , p_OLD_note  => contatto_row.NOTE
                            , p_NEW_importanza  => contatto_row.importanza
                            , p_OLD_importanza   => contatto_row.importanza
                            , p_NEW_competenza   => contatto_row.competenza
                            , p_OLD_competenza   => contatto_row.competenza
                            , p_NEW_competenza_esclusiva   => contatto_row.competenza_esclusiva
                            , p_OLD_competenza_esclusiva   => contatto_row.competenza_esclusiva
                            , p_NEW_version   => contatto_row.VERSION
                            , p_OLD_version   => contatto_row.VERSION
                            , p_NEW_utente_aggiornamento   => P_UTENTE_AGG
                            , p_OLD_utente_aggiornamento   => contatto_row.UTENTE_AGGIORNAMENTO
                            , p_NEW_data_aggiornamento   => SYSDATE
                            , p_OLD_data_aggiornamento   => contatto_row.DATA_AGGIORNAMENTO
                            );
        end if;
    end if;
    -- rev. 004 inizio
  if d_ref_cursor%ISOPEN THEN
     close d_ref_cursor;
  end if;
  -- rev. 004 fine
 ANAGRAFICI_PKG.TRASCO := 0;
    -- rev. 004 inizio
exception
when others then
    ANAGRAFICI_PKG.TRASCO := 0;
    if d_ref_cursor%ISOPEN THEN
       close d_ref_cursor;
    end if;
    raise;
    -- rev. 004 fine
end;

function get_denominazione_amm (p_codice_ipa in varchar2) return varchar2 is
    d_statement varchar2(2000);
    D_DENOMINAZIONE   VARCHAR2(2000);
begin
      d_statement := 'begin SELECT max(DENOMINAZIONE) INTO :D_DENOMINAZIONE FROM SO4_AMMINISTRAZIONI A, ANAGRAFICI S WHERE CODICE_AMMINISTRAZIONE = UPPER(:P_CODICE_IPA) AND A.NI = S.NI; EXCePTION WHEN OTHERS THEN NULL;   end;'; --#54239
      execute immediate d_statement
         using in OUT D_DENOMINAZIONE,P_CODICE_ipa;
      return d_denominazione;
end;
   procedure set_denominazione_ricerca
   ( p_ni   anagrafici.ni%type
   , p_dal  anagrafici.dal%type
   , p_denominazione_ricerca anagrafici.denominazione_ricerca%type
   ) is
   begin
    update anagrafici set denominazione_ricerca = p_denominazione_ricerca where ni = p_ni and dal =p_dal and nvl(denominazione_ricerca,'x') != nvl(p_denominazione_ricerca,'x'); --STEFANIA
   end;
function set_soggetto_uo ( p_dal                        in date
                         , p_old_dal                    in date
                         , p_descrizione                in varchar2
                         , p_indirizzo                  in varchar2
                         , p_provincia                  in number
                         , p_comune                     in number
                         , p_cap                        in varchar2
                         , p_telefono                   in varchar2
                         , p_fax                        in varchar2
                         , p_progr_unita_organizzativa  in number    --#54239
                         , p_ni_as4                     in anagrafici.ni%type
                         , p_utente_agg                 in ANAGRAFICI.UTENTE%type
                         )
   return anagrafici.ni%type
   is
        d_ni                        anagrafici.ni%type;
        d_indirizzo_web             anagrafe_soggetti.indirizzo_web%type;
        d_cognome_ok                ANAGRAFICI.DENOMINAZIONE_RICERCA%type;
        d_note                      ANAGRAFE_SOGGETTI.NOTE%type;
        D_COD_IPA_AMM               VARCHAR2(80);
        d_denominazione_ricerca     varchar2(2000);
        d_provincia         RECAPITI.PROVINCIA%type;
        d_comune            RECAPITI.comune%type;
        d_statement                  varchar2(2000);
        --#60726
        d_utente_aggiornamento_ipa  contatti.utente_aggiornamento%type := null;
        d_competenza                anagrafici.competenza%type := null;
   begin
    set_competenza_ipa(d_utente_aggiornamento_ipa,d_competenza);
    if p_utente_agg = d_utente_aggiornamento_ipa then --#60726
       d_competenza := as4so4_pkg.s_competenza_ipa;
    else
       d_competenza := 'SI4SO';
    end if;
    d_denominazione_ricerca := null;
    if p_descrizione like '%(%:%:%)%' then -- ho sia amm che aoo che uo
        d_cognome_ok := substr(p_descrizione, 1,instr(p_descrizione,'(',-1,1)-2);
        d_note :=  substr(substr(p_descrizione, instr(p_descrizione,'(',-1,1)+1),1,length(substr(p_descrizione, instr(p_descrizione,'(',-1,1)))-2);
        D_COD_IPA_AMM   := SUBSTR(D_NOTE,1,INSTR(D_NOTE,':')-1);
        d_denominazione_ricerca := get_denominazione_amm(D_COD_IPA_AMM)||':UO:'||d_cognome_ok;
    else
--        if p_descrizione like '%(%)%'  then -- c'è solo il codice amministrazione senza indicazione dell'aoo
--            d_cognome_ok := substr(p_descrizione, 1,instr(p_descrizione,'(',-1,1)-2);
--            d_COD_IPA_AMM :=  substr(substr(p_descrizione, instr(p_descrizione,'(',-1,1)+1),1,length(substr(p_descrizione, instr(p_descrizione,'(',-1,1)))-2);
--            if as4so4_pkg.get_denominazione_amm(D_COD_IPA_AMM) is not null then
--                d_denominazione_ricerca := as4so4_pkg.get_denominazione_amm(D_COD_IPA_AMM)||':UO:'||d_cognome_ok;
--            end if;
--        else
            d_cognome_ok := p_descrizione;
            d_note       := null;
 --       end if;
    end if;
    IF P_PROVINCIA IS NULL OR P_COMUNE IS NULL THEN
        d_provincia := null;
        d_comune    := null;
    ELSE
        d_provincia := P_PROVINCIA;
        d_comune    := P_COMUNE;
    END IF;
    if p_ni_as4 is null then /* devo creare il soggetto */
        as4_anagrafe_soggetti_pkg.init_ni(d_ni);
        --#54239
        d_statement := 'begin insert into so4_soggetti_unita (progr_unita_organizzativa,ni) values (:p_progr_unita_organizzativa,:d_ni);  end;'; --#54239
        execute immediate d_statement
          using in  p_progr_unita_organizzativa,d_ni;
        as4_anagrafe_soggetti_tpk.ins( p_ni                   => d_ni
                                      ,p_dal                  => nvl(p_dal,trunc(sysdate))
                                      ,p_cognome              => upper(rtrim(ltrim(d_cognome_ok)))
                                      ,p_indirizzo_res        => upper(rtrim(ltrim(p_indirizzo)))
                                      ,p_provincia_res        => d_provincia
                                      ,p_comune_res           => d_comune
                                      ,p_cap_res              => p_cap
                                      ,p_tel_res              => p_telefono
                                      ,p_fax_res              => p_fax
                                      ,p_tipo_soggetto        => 'E'
                                      ,p_utente               => p_utente_agg
                                      ,p_data_agg             => sysdate
                                      ,p_competenza           => d_competenza --#60726
                                      ,p_competenza_esclusiva => 'E'
                                      ,p_denominazione        => upper(rtrim(ltrim(d_cognome_ok)))
                                      ,p_note => d_note);
    else
        begin
            select indirizzo_web
              into d_indirizzo_web
              from anagrafe_soggetti
             where ni = p_ni_as4
               and sysdate between dal and nvl(al,to_date(3333333,'j'));
        exception when no_data_found then
            d_indirizzo_web := null;
        end;

        if nvl(p_old_dal,to_date(2222222,'j')) = nvl(p_dal,to_date(2222222,'j')) then -- sto rettificando
            as4_anagrafe_soggetti_tpk.upd( p_NEW_ni  => p_ni_as4
                                         , p_OLD_ni  => p_ni_as4
                                         , p_new_dal => p_dal
                                         , p_old_dal => p_old_dal
                                         , p_new_cognome              => upper(rtrim(ltrim(d_cognome_ok)))
                                          ,p_new_indirizzo_res        => upper(rtrim(ltrim(p_indirizzo)))
                                          ,p_new_provincia_res        => d_provincia
                                          ,p_new_comune_res           => d_comune
                                          ,p_new_cap_res              => p_cap
                                          ,p_new_tel_res              => p_telefono
                                          ,p_new_fax_res              => p_fax
                                          ,p_new_tipo_soggetto        => 'E'
                                          ,p_new_utente               => p_utente_agg
                                          ,p_new_indirizzo_web        => d_indirizzo_web -- lo ripesco dal valore corrente
                                          ,p_new_data_agg             => sysdate
                                          ,p_new_competenza           => d_competenza --#60726
                                          ,p_new_competenza_esclusiva => 'E'
                                          ,p_new_denominazione        => upper(rtrim(ltrim(d_cognome_ok)))
                                          ,p_new_note                 => d_note);
        else -- sto storicizzando
            as4_anagrafe_soggetti_tpk.ins( p_ni                   => p_ni_as4
                                      ,p_dal                  => nvl(p_dal,trunc(sysdate))
                                      ,p_cognome              => upper(rtrim(ltrim(d_cognome_ok)))
                                      ,p_indirizzo_res        => upper(rtrim(ltrim(p_indirizzo)))
                                      ,p_provincia_res        => d_provincia
                                      ,p_comune_res           => d_comune
                                      ,p_cap_res              => p_cap
                                      ,p_tel_res              => p_telefono
                                      ,p_fax_res              => p_fax
                                      ,p_tipo_soggetto        => 'E'
                                      ,p_utente               => p_utente_agg
                                      ,p_data_agg             => sysdate
                                      ,p_competenza           => d_competenza --#60726
                                      ,p_competenza_esclusiva => 'E'
                                      ,p_indirizzo_web        => d_indirizzo_web -- lo ripesco dal valore corrente
                                      ,p_denominazione        => upper(rtrim(ltrim(d_cognome_ok)))
                                      ,p_note                 => d_note
                                      );
        end if;
        d_ni := p_ni_as4;
    end if;
    set_denominazione_ricerca(d_ni, nvl(p_dal,trunc(sysdate)), nvl(d_denominazione_ricerca,upper(rtrim(ltrim(d_cognome_ok)))));
    return d_ni;
end;
function set_soggetto_aoo
   ( p_dal                        in date
    ,p_old_dal                    in date
   , p_descrizione                in varchar2
   , p_indirizzo                  in varchar2
   , p_provincia                  in number
   , p_comune                     in number
   , p_cap                        in varchar2
   , p_telefono                   in varchar2
   , p_fax                        in varchar2
   , p_ni_as4                     in anagrafici.ni%type
   , p_progr_aoo                  in number--#60726
   , p_utente_agg                 in ANAGRAFICI.UTENTE%type
   ) return  anagrafici.ni%type
  is
    d_ni                        number;
    d_cognome_ok                ANAGRAFICI.DENOMINAZIONE_RICERCA%type;
    d_note                      ANAGRAFE_SOGGETTI.NOTE%type;
    D_COD_IPA_AMM               VARCHAR2(80);
    d_denominazione_ricerca     varchar2(2000);
    d_provincia         RECAPITI.PROVINCIA%type;
    d_comune            RECAPITI.comune%type;
    d_statement                 varchar2(2000); --#60726
    --#60726
    d_utente_aggiornamento_ipa  contatti.utente_aggiornamento%type := null;
    d_competenza                anagrafici.competenza%type := null;
  begin
    set_competenza_ipa(d_utente_aggiornamento_ipa,d_competenza);
    if p_utente_agg = d_utente_aggiornamento_ipa then --#60726
       d_competenza := as4so4_pkg.s_competenza_ipa;
    else
       d_competenza := 'SI4SO';
    end if;
    if p_descrizione like '%(%:%)%' then --
        d_cognome_ok := substr(p_descrizione, 1,instr(p_descrizione,'(',-1,1)-2);
        d_note :=  substr(substr(p_descrizione, instr(p_descrizione,'(',-1,1)+1),1,length(substr(p_descrizione, instr(p_descrizione,'(',-1,1)))-2);
        D_COD_IPA_AMM   := SUBSTR(D_NOTE,1,INSTR(D_NOTE,':')-1);
        d_denominazione_ricerca := get_denominazione_amm(D_COD_IPA_AMM)||':AOO:'||d_cognome_ok;
    else
        d_cognome_ok := p_descrizione;
        d_denominazione_ricerca := get_denominazione_amm(D_COD_IPA_AMM)||':AOO:'||d_cognome_ok; --#60726
        d_note       := null;
    end if;
    IF P_PROVINCIA IS NULL OR P_COMUNE IS NULL THEN
        d_provincia := null;
        d_comune    := null;
    ELSE
        d_provincia := P_PROVINCIA;
        d_comune    := P_COMUNE;
    END IF;
    if p_ni_as4 is null then /* devo creare il soggetto */
        as4_anagrafe_soggetti_pkg.init_ni(d_ni);
        d_statement := 'begin insert into so4_soggetti_aoo (progr_aoo,ni) values (:p_progr_aoo,:d_ni);  end;'; --#60726
        execute immediate d_statement
          using in  p_progr_aoo,d_ni;
        as4_anagrafe_soggetti_tpk.ins( p_ni                   => d_ni
                                      ,p_dal                  => nvl(p_dal,trunc(sysdate))
                                      ,p_cognome              => upper(rtrim(ltrim(d_cognome_ok)))
                                      ,p_indirizzo_res        => upper(rtrim(ltrim(p_indirizzo)))
                                      ,p_provincia_res        => d_provincia
                                      ,p_comune_res           => d_comune
                                      ,p_cap_res              => p_cap
                                      ,p_tel_res              => p_telefono
                                      ,p_fax_res              => p_fax
                                      ,p_tipo_soggetto        => 'E'
                                      ,p_utente               => p_utente_agg
                                      ,p_data_agg             => sysdate
                                      ,p_competenza           => d_competenza --#60726
                                      ,p_competenza_esclusiva => 'E'
                                      ,p_note                 => d_note);
    else
        if nvl(p_old_dal,to_date(2222222,'j')) = nvl(p_dal,to_date(2222222,'j')) then -- sto RETTIFICANDO
            as4_anagrafe_soggetti_tpk.upd( p_NEW_ni  => p_ni_as4
                                         , p_OLD_ni  => p_ni_as4
                                         , p_new_dal => p_dal
                                         , p_old_dal => p_old_dal
                                         , p_new_cognome              => upper(rtrim(ltrim(d_cognome_ok)))
                                          ,p_new_indirizzo_res        => upper(rtrim(ltrim(p_indirizzo)))
                                          ,p_new_provincia_res        => d_provincia
                                          ,p_new_comune_res           => d_comune
                                          ,p_new_cap_res              => p_cap
                                          ,p_new_tel_res              => p_telefono
                                          ,p_new_fax_res              => p_fax
                                          ,p_new_tipo_soggetto        => 'E'
                                          ,p_new_utente               => p_utente_agg
                                          ,p_new_data_agg             => sysdate
                                          ,p_new_competenza           => d_competenza --#60726
                                          ,p_new_competenza_esclusiva => 'E'
                                          ,p_new_denominazione        => upper(rtrim(ltrim(d_cognome_ok)))
                                          ,p_new_note                 => d_note);
        else
            as4_anagrafe_soggetti_tpk.ins( p_ni               => p_ni_as4
                                      ,p_dal                  => nvl(p_dal,trunc(sysdate))
                                      ,p_cognome              => upper(rtrim(ltrim(d_cognome_ok)))
                                      ,p_indirizzo_res        => upper(rtrim(ltrim(p_indirizzo)))
                                      ,p_provincia_res        => d_provincia
                                      ,p_comune_res           => d_comune
                                      ,p_cap_res              => p_cap
                                      ,p_tel_res              => p_telefono
                                      ,p_fax_res              => p_fax
                                      ,p_tipo_soggetto        => 'E'
                                      ,p_utente               => p_utente_agg
                                      ,p_data_agg             => sysdate
                                      ,p_competenza           => d_competenza --#60726
                                      ,p_competenza_esclusiva => 'E'
                                      ,p_denominazione        => upper(rtrim(ltrim(d_cognome_ok)))
                                      ,p_note                 => d_note);
        end if;
        d_ni := p_ni_as4;
    end if;
    set_denominazione_ricerca(d_ni, nvl(p_dal,trunc(sysdate)), nvl(d_denominazione_ricerca,upper(rtrim(ltrim(d_cognome_ok)))));
    return d_ni;
  end;
  procedure allinea_amm( p_ni_as4                   in anagrafici.ni%type
                     , p_codice_amm               in varchar2
                     )  is
  begin
    update anagrafici set note = p_codice_amm
         , denominazione_ricerca = denominazione -- aggiunto per forzare la valorizzazione in caso di errore in trasco
      where ni = p_ni_as4
        and dal = (select max(dal) from anagrafici where ni =p_ni_as4)
        and (nvl(note,'x')  != nvl(p_codice_amm,'x') or nvl(denominazione_ricerca,'x') != denominazione) ; --STEFANIA/ANGELO
  end;

   procedure recupera_note_con_codice_amm
   ( p_ni   anagrafici.ni%type
   , p_dal  anagrafici.dal%type
   ) IS
   v_dep_note anagrafici.note%TYPE;
   BEGIN
       BEGIN
          select note
            into v_dep_note
            from anagrafici a
           where ni  = p_ni
             and dal < p_dal
             and not exists (select 1
                               from anagrafici
                              where ni  = p_ni
                                and dal < p_dal
                                and a.dal < dal);
       EXCEPTION
          when no_data_found then
           v_dep_note := null;
       END;
       if v_dep_note is not null then
           update anagrafici
              set note = v_dep_note
            where ni = p_ni
              and dal = p_dal;
       end if;
    END;

  procedure set_competenza_ipa --#60726
  (
     p_utente_aggiornamento in out anagrafici.utente%type
    ,p_competenza           in out anagrafici.competenza%type
  ) is
     d_stringa registro.valore%type;
  begin
--     if as4so4_pkg.s_utente_aggiornamento is null and as4so4_pkg.s_competenza_ipa is null then
        d_stringa                         := nvl(registro_utility.leggi_stringa('PRODUCTS/IPA'
                                                                               ,'UtenteCompetenzaAnagraficheScaricoIPA'
                                                                               ,0)
                                                ,'x');
        p_utente_aggiornamento            := substr(d_stringa
                                                   ,1
                                                   ,instr(d_stringa, ',') - 1);
        p_competenza                      := substr(d_stringa, instr(d_stringa, ',') + 1);
        as4so4_pkg.s_utente_aggiornamento := p_utente_aggiornamento;
        as4so4_pkg.s_competenza_ipa       := p_competenza;
--     end if;
  end;

BEGIN
        ANAGRAFICI_PKG.TRASCO := AS4SO4_PKG.s_trasco_on;
END as4so4_pkg;
/

