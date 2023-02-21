CREATE OR REPLACE PACKAGE BODY anagrafe_soggetti_ws_pkg
IS
/******************************************************************************
 NOME:        anagrafe_soggetti_pkg
 DESCRIZIONE: Gestione tabella anagrafe_soggetti.
 ANNOTAZIONI: .
 REVISIONI:   .
 Rev.  Data        Autore  Descrizione.
 000   26/10/2017    Prima emissione.
 001   12/06/2018  SN      Parametro p_utente, competenza e competenza_esclusiva
                           acquisito dal web service
 002   26/04/2021  SN      Integrazioni funzioni per web service gestione contatti #49854
******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision          := '002';

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

   function get_id_recapito
   (p_ni     IN ANAGRAFICI.ni%TYPE,
    p_dal    IN ANAGRAFICI.dal%TYPE,
    P_DES_RECAPITO IN TIPI_RECAPITO.DESCRIZIONE%TYPE
   ) return number
   is
        d_id_recapito   RECAPITI.ID_RECAPITO%type;
    begin
        begin
            select id_recapito
              INTO D_ID_RECAPITO
              from recapiti
             where ni = p_ni
               and id_tipo_rEcapito = (select id_tipo_recapito from tipi_recapito tr where TR.DESCRIZIONE=P_DES_RECAPITO)
               AND P_DAL BETWEEN DAL AND NVL(AL,TO_DATE(3333333,'J'));
        EXCEPTION WHEN NO_DATA_FOUND THEN
            D_ID_RECAPITO := NULL;
        END;
        RETURN D_ID_RECAPITO;
    END;


    function get_id_recapito_res
    (p_ni     IN ANAGRAFICI.ni%TYPE,
    p_dal    IN ANAGRAFICI.dal%TYPE
    ) return number
    is
        d_id_recapito   RECAPITI.ID_RECAPITO%type;
    begin
        RETURN GET_ID_RECAPITO(P_NI,P_DAL,'RESIDENZA');
    END;


   function get_id_recapito_dom
   (p_ni     IN ANAGRAFICI.ni%TYPE,
    p_dal    IN ANAGRAFICI.dal%TYPE
   ) return number
   is
    begin
        RETURN GET_ID_RECAPITO(P_NI,P_DAL,'DOMICILIO');
    END;

    function GET_ID_CONTATTO
   (P_ID_RECAPITO IN RECAPITI.id_recapito%TYPE,
    P_DES_CONTATTO IN TIPI_RECAPITO.DESCRIZIONE%TYPE
   ) return number
   is
        d_id_contatto   CONTATTI.ID_CONTATTO%type;
    begin
        begin
            select id_contatto
              INTO d_id_contatto
              from contatti
             where id_recapito = P_ID_RECAPITO
               and id_tipo_contatto = (select id_tipo_contatto from tipi_contatto tc where tc.DESCRIZIONE = P_DES_CONTATTO)
               AND sysdate BETWEEN DAL AND NVL(AL,TO_DATE(3333333,'J'));
        EXCEPTION WHEN NO_DATA_FOUND THEN
            d_id_contatto := NULL;
        END;
        RETURN d_id_contatto;
    END;



FUNCTION ins (
      p_id_anagrafica           IN ANAGRAFICI.id_anagrafica%TYPE DEFAULT NULL,
      p_ni                      IN ANAGRAFICI.ni%TYPE default NULL,
      p_dal                     IN ANAGRAFICI.dal%TYPE,
      p_al                      IN ANAGRAFICI.al%TYPE DEFAULT NULL,
      p_cognome                 IN ANAGRAFICI.cognome%TYPE,
      p_nome                    IN ANAGRAFICI.nome%TYPE DEFAULT NULL,
      p_sesso                   IN ANAGRAFICI.sesso%TYPE DEFAULT NULL,
      p_data_nas                IN ANAGRAFICI.data_nas%TYPE DEFAULT NULL,
      p_provincia_nas           IN ANAGRAFICI.provincia_nas%TYPE DEFAULT NULL,
      p_comune_nas              IN ANAGRAFICI.comune_nas%TYPE DEFAULT NULL,
      p_luogo_nas               IN ANAGRAFICI.luogo_nas%TYPE DEFAULT NULL,
      p_codice_fiscale          IN ANAGRAFICI.codice_fiscale%TYPE DEFAULT NULL,
      p_codice_fiscale_estero   IN ANAGRAFICI.codice_fiscale_estero%TYPE DEFAULT NULL,
      p_partita_iva             IN ANAGRAFICI.partita_iva%TYPE DEFAULT NULL,
      p_cittadinanza            IN ANAGRAFICI.cittadinanza%TYPE DEFAULT NULL,
      p_gruppo_ling             IN ANAGRAFICI.gruppo_ling%TYPE DEFAULT NULL,
      p_competenza              IN ANAGRAFICI.competenza%TYPE DEFAULT NULL,
      p_competenza_esclusiva    IN ANAGRAFICI.competenza_esclusiva%TYPE DEFAULT NULL,
      p_tipo_soggetto           IN ANAGRAFICI.tipo_soggetto%TYPE DEFAULT NULL,
      p_stato_cee               IN ANAGRAFICI.stato_cee%TYPE DEFAULT NULL,
      p_partita_iva_cee         IN ANAGRAFICI.partita_iva_cee%TYPE DEFAULT NULL,
      p_fine_validita           IN ANAGRAFICI.fine_validita%TYPE DEFAULT NULL,
      p_stato_soggetto          IN ANAGRAFICI.stato_soggetto%TYPE DEFAULT 'U',
      p_denominazione           IN ANAGRAFICI.denominazione%TYPE DEFAULT NULL,
      p_note                    IN ANAGRAFICI.note%TYPE DEFAULT NULL,
      p_version                 IN ANAGRAFICI.version%TYPE DEFAULT NULL,
      p_utente                  IN ANAGRAFICI.utente%TYPE DEFAULT NULL,
      p_data_agg                IN ANAGRAFICI.data_agg%TYPE DEFAULT SYSDATE,
      p_batch                      NUMBER DEFAULT 0           -- 0 = NON batch
                                                   )
      RETURN NUMBER
      is
        d_id_anagrafica number;
      begin
      if p_comune_nas = -999 or p_provincia_nas = -999 then -- viene passato dal plugin
         raise_application_error(-20999,si4.get_error('A10021') || '(nascita)');
      end if;
        d_id_anagrafica := anagrafici_pkg.ins(p_id_anagrafica           ,
      p_ni                      ,
      p_dal                    ,
      p_al                      ,
      p_cognome                 ,
      p_nome                    ,
      p_sesso                   ,
      p_data_nas               ,
      p_provincia_nas           ,
      p_comune_nas              ,
      p_luogo_nas               ,
      p_codice_fiscale          ,
      p_codice_fiscale_estero   ,
      p_partita_iva             ,
      p_cittadinanza            ,
      p_gruppo_ling             ,
      'WS', -- p_competenza
      p_competenza_esclusiva    ,
      p_tipo_soggetto           ,
      p_stato_cee               ,
      p_partita_iva_cee         ,
      p_fine_validita           ,
      p_stato_soggetto          ,
      p_denominazione           ,
      p_note                    ,
      p_version                 ,
      nvl(p_utente ,'WS'),
      p_data_agg                ,
      p_batch
        );
        return anagrafici_tpk.get_ni(d_id_anagrafica);
      end;


fUNCTION ins_anag_dom_e_res_e_mail (
      -- dati anagrafica
--      p_id_anagrafica           IN ANAGRAFICI.id_anagrafica%TYPE DEFAULT NULL,
      p_ni                      IN ANAGRAFICI.ni%TYPE default NULL,
      p_dal                     IN ANAGRAFICI.dal%TYPE,
      p_al                      IN ANAGRAFICI.al%TYPE DEFAULT NULL,
      p_cognome                 IN ANAGRAFICI.cognome%TYPE,
      p_nome                    IN ANAGRAFICI.nome%TYPE DEFAULT NULL,
      p_sesso                   IN ANAGRAFICI.sesso%TYPE DEFAULT NULL,
      p_data_nas                IN ANAGRAFICI.data_nas%TYPE DEFAULT NULL,
      p_provincia_nas           IN anagrafici.provincia_nas%TYPE DEFAULT NULL,
      p_comune_nas              IN anagrafici.comune_nas%TYPE DEFAULT NULL,
      p_luogo_nas               IN ANAGRAFICI.luogo_nas%TYPE DEFAULT NULL,
      p_codice_fiscale          IN ANAGRAFICI.codice_fiscale%TYPE DEFAULT NULL,
      p_codice_fiscale_estero   IN ANAGRAFICI.codice_fiscale_estero%TYPE DEFAULT NULL,
      p_partita_iva             IN ANAGRAFICI.partita_iva%TYPE DEFAULT NULL,
      p_cittadinanza            IN ANAGRAFICI.cittadinanza%TYPE DEFAULT NULL,
      p_gruppo_ling             IN ANAGRAFICI.gruppo_ling%TYPE DEFAULT NULL,
      p_competenza              IN ANAGRAFICI.competenza%TYPE DEFAULT NULL,
      p_competenza_esclusiva    IN ANAGRAFICI.competenza_esclusiva%TYPE DEFAULT NULL,
      p_tipo_soggetto           IN ANAGRAFICI.tipo_soggetto%TYPE DEFAULT NULL,
      p_stato_cee               IN ANAGRAFICI.stato_cee%TYPE DEFAULT NULL,
      p_partita_iva_cee         IN ANAGRAFICI.partita_iva_cee%TYPE DEFAULT NULL,
      p_fine_validita           IN ANAGRAFICI.fine_validita%TYPE DEFAULT NULL,
      p_stato_soggetto          IN ANAGRAFICI.stato_soggetto%TYPE DEFAULT 'U',
      p_denominazione           IN ANAGRAFICI.denominazione%TYPE DEFAULT NULL,
      p_note_anag               IN ANAGRAFICI.note%TYPE DEFAULT NULL,
      ----- dati residenza
--      p_id_recapito  in RECAPITI.id_recapito%type default null
--    , p_ni  in RECAPITI.ni%type
--    , p_dal  in RECAPITI.dal%type
--    , p_al  in RECAPITI.al%type default null
      p_descrizione_residenza  in RECAPITI.descrizione%type default null --p_descrizione
--    , p_id_tipo_recapito  in RECAPITI.id_tipo_recapito%type
    , p_indirizzo_res            in RECAPITI.indirizzo%type default null
    , p_provincia_res           IN recapiti.provincia%TYPE DEFAULT NULL
    , p_comune_res              IN recapiti.comune%TYPE DEFAULT NULL
    , p_cap_res  in RECAPITI.cap%type default null
    , p_presso  in RECAPITI.presso%type default null
    , p_importanza  in RECAPITI.importanza%type default null
      ---- mail
    , p_mail  in CONTATTI.valore%type  default null-- p_valore
--    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
    , p_note_mail  in CONTATTI.note%type default null
    , p_importanza_mail  in CONTATTI.importanza%type default null
    ---- tel res
    , p_tel_res  in CONTATTI.valore%type  default null-- p_valore
--    , p_id_tipo_contatto a in CONTATTI.id_tipo_contatto%type -- FISSO
    , p_note_tel_res  in CONTATTI.note%type default null
    , p_importanza_tel_res  in CONTATTI.importanza%type default null
    ---- fax res
    , p_fax_res  in CONTATTI.valore%type  default null-- p_valore
--    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
    , p_note_fax_res  in CONTATTI.note%type default null
    , p_importanza_fax_res  in CONTATTI.importanza%type default null
      -- dati DOMICILIO
    , p_descrizione_dom  in RECAPITI.descrizione%type default null --p_descrizione
    , p_indirizzo_dom  in RECAPITI.indirizzo%type default null
    , p_provincia_dom           IN recapiti.provincia%TYPE DEFAULT NULL
    , p_comune_dom              IN recapiti.comune%TYPE DEFAULT NULL
    , p_cap_dom  in RECAPITI.cap%type default null
    ---- tel dom
    , p_tel_dom  in CONTATTI.valore%type  default null-- p_valore
--    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
    , p_note_tel_dom  in CONTATTI.note%type default null
    , p_importanza_tel_dom  in CONTATTI.importanza%type default null
    ---- fax dom
    , p_fax_dom  in CONTATTI.valore%type  default null-- p_valore
--    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
    , p_note_fax_dom  in CONTATTI.note%type default null
      ---- dati generici
    ,  p_utente                  IN ANAGRAFICI.utente%TYPE DEFAULT NULL
     , p_data_agg                IN ANAGRAFICI.data_agg%TYPE DEFAULT SYSDATE
      ,
      p_batch                      NUMBER DEFAULT 1           -- 0 = NON batch
                                                   )
      RETURN NUMBER
      is
       d_id_anagrafica number;
      begin
      if p_comune_nas = -999 or p_provincia_nas = -999 then -- viene passato dal plugin
         raise_application_error(-20999,si4.get_error('A10021') || '(nascita)');
      end if;
      if p_comune_res = -999 or p_provincia_res = -999 then -- viene passato dal plugin
         raise_application_error(-20999,si4.get_error('A10021') || '(residenza)');
      end if;
      if p_comune_dom = -999 or p_provincia_dom = -999 then -- viene passato dal plugin
         raise_application_error(-20999,si4.get_error('A10021') || '(domicilio)');
      end if;
       --     raise_application_error(-20999,'Partita cee '||p_partita_iva_cee);
        d_id_anagrafica := ANAGRAFICI_PKG.INS_ANAG_DOM_E_RES_E_MAIL(p_ni                     ,
      p_dal                    ,
      p_al                      ,
      p_cognome                 ,
      p_nome                    ,
      p_sesso                   ,
      p_data_nas                ,
      p_provincia_nas           ,
      p_comune_nas              ,
      p_luogo_nas               ,
      p_codice_fiscale          ,
      p_codice_fiscale_estero   ,
      p_partita_iva             ,
      p_cittadinanza            ,
      p_gruppo_ling             ,
      'WS' , -- p_competenza   forzato per distinguere inserimenti da interfaccia ed inserimenti da WS             ,
      p_competenza_esclusiva    ,
      p_tipo_soggetto           ,
      p_stato_cee               ,
      p_partita_iva_cee         ,
      p_fine_validita           ,
      p_stato_soggetto          ,
      p_denominazione          ,
      p_note_anag               ,
      p_descrizione_residenza
    , p_indirizzo_res
    , p_provincia_res
    , p_comune_res
    , p_cap_res
    , p_presso
    , p_importanza
    , p_mail
    , p_note_mail
    , p_importanza_mail
    , p_tel_res
    , p_note_tel_res
    , p_importanza_tel_res
    , p_fax_res
    , p_note_fax_res
    , p_importanza_fax_res
    , p_descrizione_dom
    , p_indirizzo_dom
    , p_provincia_dom
    , p_comune_dom
    , p_cap_dom
    , p_tel_dom
    , p_note_tel_dom
    , p_importanza_tel_dom
    , p_fax_dom
    , p_note_fax_dom
    , nvl(p_utente ,'WS')         -- p_utente   forzato per distinguere inserimenti da interfaccia ed inserimenti da WS
     , p_data_agg
      ,p_batch
        );
        return anagrafici_tpk.get_ni(d_id_anagrafica);
      end;


   FUNCTION CHECK_RECAPITO
   (P_NI        IN NUMBER
   ,p_tipo_recapito in varchar2
   ,P_INDIRIZZO IN VARCHAR2
   ,P_PROVINCIA IN NUMBER
   ,P_COMUNE    IN NUMBER
   ) return number
   is
    D_ID_TIPO_RECAPITO      NUMBER;
    d_id_recapito           number;
   begin
   if p_comune = -999 or p_provincia = -999 then -- viene passato dal plugin
         raise_application_error(-20999,si4.get_error('A10021') || '(recapito)');
    end if;
    if p_ni is null then
        raise_application_error(-20999,si4.get_error ('A10088') ||' (NI)');
    end if;
    if p_tipo_recapito is null then
        raise_application_error(-20999,si4.get_error ('A10088') ||' (TIPO_RECAPITO)');
    end if;
    if p_indirizzo is null then
        raise_application_error(-20999,si4.get_error ('A10088') ||' (INDIRIZZO)');
    end if;
    if p_provincia is null then
        raise_application_error(-20999,si4.get_error ('A10088') ||' (PROVINCIA)');
    end if;
    if p_comune is null then
        raise_application_error(-20999,si4.get_error ('A10088') ||' (COMUNE)');
    end if;
    BEGIN
        SELECT ID_TIPO_RECAPITO
          INTO D_ID_TIPO_RECAPITO
          FROM TIPI_RECAPITO
         WHERE DESCRIZIONE = P_TIPO_RECAPITO;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        raise_application_error(-20999,si4.get_error ('A10042'));
    END;

    select max(id_recapito)
      into d_id_recapito
      from recapiti
     where id_tipo_recapito = D_ID_TIPO_RECAPITO
       and ni = P_NI
       and upper(indirizzo)= upper(p_indirizzo)
       and sysdate between dal and nvl(al,to_date(3333333,'j'))
       and comune = p_comune
       and provincia = p_provincia;
   IF d_id_recapito is null  THEN RETURN -1;
   ELSE RETURN d_id_recapito;
   END IF;
  end;


   FUNCTION CHECK_RECAPITO_CONTATTO
   (P_NI        IN NUMBER
   ,P_INDIRIZZO IN VARCHAR2
   ,P_PROVINCIA IN NUMBER
   ,P_COMUNE    IN NUMBER
   ,P_CONTATTO  IN VARCHAR2
   ,p_id_recapito out number
   ,p_id_contatto out number
   ) return number IS
    D_ID_RECAPITO   NUMBER;
    D_ID_contatTO   NUMBER;
    v_provincia     NUMBER := P_PROVINCIA;
    v_comune        NUMBER := P_COMUNE;
   BEGIN
--      if p_provincia is not null then
--         v_provincia := ad4_provincia.get_provincia(p_provincia, -- denominazione
--                                                               '' );-- sigla
--            -- se non ho trovato denominazione vedo se è la sigla
--            if v_provincia is null then
--               v_provincia := ad4_provincia.get_provincia('', -- denominazione
--                                                                   p_provincia );-- sigla
--            end if;
--            if v_provincia is null then
--               plication_error (-20999,'Impossibile decodificare la provincia');
--            end if;
--      end if;
--      if p_comune is not null then
--         v_comune    := AD4_comune.GET_COMUNE( p_comune, null, 0); -- lo voglio attivo
--         if v_comune is null then
--            raise_application_error (-20999,'Impossibile decodificare il comune');
--         end if;
--      end if;
      if v_comune = -999 or v_provincia = -999 then -- viene passato dal plugin
         raise_application_error(-20999,si4.get_error('A10021') || '(recapito)');
      end if;
    IF P_INDIRIZZO IS NOT NULL THEN -- HO PASSATO IL RECAPITO DEVO CERCARLI IN MANIERA COMBINATA
        SELECT MAX(ID_RECAPITO)
          INTO D_ID_RECAPITO
          FROM RECAPITI R, ANAGRAFICI A
         WHERE A.NI = P_NI
           AND TRUNC(SYSDATE) BETWEEN A.DAL AND NVL(A.AL,TO_DATE(3333333,'J'))
           AND R.NI = P_NI
           AND TRUNC(SYSDATE) BETWEEN R.DAL AND NVL(R.AL,TO_DATE(3333333,'J'))
           AND upper(translate (nvl(R.INDIRIZZO,'x'),'a/- _','a')) = upper(translate (nvl(P_INDIRIZZO,'Y'),'a/- _','a'))
           AND upper(nvl(R.COMUNE,-1)) = upper(nvl(v_COMUNE,-2))
           AND upper(nvl(R.PROVINCIA,-1)) = upper(nvl(v_PROVINCIA,-2))
           ;
         IF D_ID_RECAPITO IS NULL THEN
            RAISE_APPLICATION_ERROR(-20999,si4.get_error('A10055' )); --'Recapito non esistente per soggetto anagrafico');
         end if;
       select max(id_contatto)
         into D_ID_contatTO
         from contatti
        where id_recapito = d_id_recapito
          and TRUNC(sysdate) between dal
          and nvl(al,to_date(3333333,'j'))
          and upper(translate (valore,'a/- _','a')) = upper(translate (p_contatto,'a/- _','a'));
    else -- indicazioni recapito non fornite
        -- controllo se esiste il contatto
       SELECT MAX(C.ID_contatto)
          INTO D_ID_contatTO
          FROM RECAPITI R, ANAGRAFICI A, CONTATTI C
         WHERE A.NI = P_NI
           AND TRUNC(SYSDATE) BETWEEN A.DAL AND NVL(A.AL,TO_DATE(3333333,'J'))
           AND R.NI = P_NI
           AND R.ni = A.NI
           AND TRUNC(SYSDATE) BETWEEN R.DAL AND NVL(R.AL,TO_DATE(3333333,'J'))
--           AND
--           ((upper(translate (nvl(R.INDIRIZZO,'x'),'a/- _','a')) = upper(translate (nvl(R.INDIRIZZO,'x'),'a/- _','a'))
--              AND upper(nvl(R.COMUNE,-1)) = upper(nvl(v_COMUNE,-1))
--              AND upper(nvl(R.PROVINCIA,-1)) = upper(nvl(v_PROVINCIA,-1)))
--             OR (r.id_tipo_recapito = (select id_tipo_recapito from tipi_recapito where descrizione = 'RESIDENZA')
--                and c.id_tipo_contatto=(select id_tipo_contatto from tipi_contatto where descrizione = 'GENERICO'))
--               )
           AND C.id_recapito = R.id_recapito
           AND TRUNC(SYSDATE) BETWEEN c.DAL AND NVL(c.AL,TO_DATE(3333333,'J'))
           and upper(translate (c.valore,'a/- _','a')) = upper(translate (p_contatto,'a/- _','a'))
           ;
    end if;
    if d_id_contatto is not null then
        p_id_contatto := d_id_contatto;
        p_id_recapito := CONTATTI_TPK.GET_ID_RECAPITO(d_id_contatto);
        return 0;
     else
        return -1;
     end if;
   exception when others then
    return -1;
   END;


   procedure CHECK_RECAPITO_CONTATTO
   (P_NI        IN NUMBER
   ,P_INDIRIZZO IN VARCHAR2
   ,P_PROVINCIA IN NUMBER
   ,P_COMUNE    IN NUMBER
   ,P_CONTATTO  IN VARCHAR2
   ,p_result    out number
   ,p_id_recapito out number
   ,p_id_contatto out number
   )  IS
    D_ID_RECAPITO   NUMBER;
    D_ID_contatTO   NUMBER;
    v_provincia     NUMBER := P_PROVINCIA;
    v_comune        NUMBER := P_COMUNE;
   BEGIN
   if v_comune = -999 or v_provincia = -999 then -- viene passato dal plugin
         raise_application_error(-20999,si4.get_error('A10021') || '(recapito)');
      end if;
    IF P_INDIRIZZO IS NOT NULL THEN -- HO PASSATO IL RECAPITO DEVO CERCARLI IN MANIERA COMBINATA
        SELECT MAX(ID_RECAPITO)
          INTO D_ID_RECAPITO
          FROM RECAPITI R, ANAGRAFICI A
         WHERE A.NI = P_NI
           AND TRUNC(SYSDATE) BETWEEN A.DAL AND NVL(A.AL,TO_DATE(3333333,'J'))
           AND R.NI = P_NI
           AND TRUNC(SYSDATE) BETWEEN R.DAL AND NVL(R.AL,TO_DATE(3333333,'J'))
           AND upper(translate (nvl(R.INDIRIZZO,'x'),'a/- _','a')) = upper(translate (nvl(P_INDIRIZZO,'Y'),'a/- _','a'))
           AND upper(nvl(R.COMUNE,-1)) = upper(nvl(v_COMUNE,-2))
           AND upper(nvl(R.PROVINCIA,-1)) = upper(nvl(v_PROVINCIA,-2))
           ;
         IF D_ID_RECAPITO IS NULL THEN
            RAISE_APPLICATION_ERROR(-20999,si4.get_error('A10055') ); --'Recapito non esistente per soggetto anagrafico');
         end if;
       select max(id_contatto)
         into D_ID_contatTO
         from contatti
        where id_recapito = d_id_recapito
          and TRUNC(sysdate) between dal
          and nvl(al,to_date(3333333,'j'))
          and upper(translate (valore,'a/- _','a')) = upper(translate (p_contatto,'a/- _','a'));
    else -- indicazioni recapito non fornite
        -- controllo se esiste il contatto
       SELECT MAX(C.ID_contatto)
          INTO D_ID_contatTO
          FROM RECAPITI R, ANAGRAFICI A, CONTATTI C
         WHERE A.NI = P_NI
           AND TRUNC(SYSDATE) BETWEEN A.DAL AND NVL(A.AL,TO_DATE(3333333,'J'))
           AND R.NI = P_NI
           AND R.ni = A.NI
           AND TRUNC(SYSDATE) BETWEEN R.DAL AND NVL(R.AL,TO_DATE(3333333,'J'))
           AND C.id_recapito = R.id_recapito
           AND TRUNC(SYSDATE) BETWEEN c.DAL AND NVL(c.AL,TO_DATE(3333333,'J'))
           and upper(translate (c.valore,'a/- _','a')) = upper(translate (p_contatto,'a/- _','a'))
           ;
    end if;
    if d_id_contatto is not null then
        p_id_contatto := d_id_contatto;
        p_id_recapito := CONTATTI_TPK.GET_ID_RECAPITO(d_id_contatto);
        p_result := 0;
    else
        p_result := -1;
        p_id_contatto := null;
        p_id_recapito := null;
    end if;
   exception when others then
    p_result:= -1;
    p_id_contatto := null;
    p_id_recapito := null;
   END;



   procedure ins_recapito_contatto
   (P_NI        IN NUMBER
   ,P_INDIRIZZO IN VARCHAR2
   ,P_PROVINCIA IN NUMBER
   ,P_COMUNE    IN NUMBER
   ,p_tipo_contatto in varchar2
   ,P_CONTATTO  IN VARCHAR2
   ,p_result  out number
   ,p_id_recapito out number
   ,p_id_contatto out number
   ,p_utente_aggiornamento     in varchar2 default null
   ,p_competenza              in varchar2 default null
   ,p_competenza_esclusiva     in varchar2 default null
   )  is
    D_ID_RECAPITO   NUMBER;
    D_ID_contatTO   NUMBER;
    d_id_tipo_recapito_residenza number;
    d_id_tipo_recapito_generico  number;
    d_id_tipo_contatto  number;
   begin
       if p_tipo_contatto is not null and
        p_tipo_contatto not in ('MAIL','MAIL PEC') THEN
          raise_application_error(-20999,si4.get_error ('A10052')||' TIPO_CONTATTO non ammesso');
      END IF;
      if p_comune = -999 or p_provincia = -999 then -- viene passato dal plugin
         raise_application_error(-20999,si4.get_error('A10021') || '(recapito)');
      end if;
   -- se esiste già devo impedire inserimento?
       select min(id_tipo_contatto )
         into d_id_tipo_contatto
         from tipi_contatto
        where descrizione = nvl(p_tipo_contatto,'GENERICO');
        if d_id_tipo_contatto is null then
          raise_application_error(-20999,si4.get_error ('A10052') || nvl(p_tipo_contatto,'GENERICO'));
                 --'Errore in determinazione tipo contatto GENERICO');
       end if;
        if P_indirizzo is null then
            select min(id_tipo_recapito)
           into d_id_tipo_recapito_residenza
           from tipi_recapito
          where descrizione = 'RESIDENZA';
          if d_id_tipo_recapito_residenza is null then
             raise_application_error(-20999,si4.get_error ('A10042') ||'(RESIDENZA)');
             --'Errore in determinazione tipo recapito RESIDENZA');
          end if;
      -- non hanno dato indirizzo inserisco mail generica su residenza
      -- controllo se non esiste già su residenza
      SELECT MAX(R.ID_RECAPITO)
          INTO D_ID_RECAPITO
          FROM RECAPITI R, ANAGRAFICI A
         WHERE A.NI = P_NI
           AND TRUNC(SYSDATE) BETWEEN A.DAL AND NVL(A.AL,TO_DATE(3333333,'J'))
           AND R.NI = P_NI
           AND R.ni = A.NI
           AND TRUNC(SYSDATE) BETWEEN R.DAL AND NVL(R.AL,TO_DATE(3333333,'J'))
           and r.id_tipo_recapito = d_id_tipo_recapito_residenza
           ;
         if d_id_recapito is null then
         -- non esiste la residenza inserisco
          d_id_recapito :=
             recapiti_tpk.ins(p_id_recapito => NULL
            , p_ni  => p_ni
            , p_dal => TRUNC(SYSDATE)
            , p_al  =>NULL
            , p_descrizione => NULL
            , p_id_tipo_recapito => d_id_tipo_recapito_residenza
            , p_indirizzo  => p_indirizzo
            , p_provincia  => P_provincia
            , p_comune  => P_comune
            , p_cap  =>  NULL
            , p_presso  =>  NULL
            , p_importanza =>  NULL
            , p_competenza  => p_competenza
            , p_competenza_esclusiva  => p_competenza_esclusiva
            , p_version  =>  NULL
            , p_utente_aggiornamento   =>   nvl(p_utente_aggiornamento ,'WS')
            , p_data_aggiornamento  => SYSDATE
            );
         end if;

         -- controllo se esiste già quel contatto
         SELECT MAX(C.ID_contatto)
          INTO D_ID_contatTO
          FROM CONTATTI C
         WHERE C.id_recapito = d_id_recapito
           AND TRUNC(SYSDATE) BETWEEN c.DAL AND NVL(c.AL,TO_DATE(3333333,'J'))
           and upper(translate (c.valore,'a/- _','a')) = upper(translate (p_contatto,'a/- _','a'))
           ;
           if D_ID_contatTO  is null THEN
           -- inserisco come generico legato alla residenza
           D_ID_contatTO := contatti_tpk.ins(
              p_id_contatto  => null
            , p_id_recapito   => d_id_recapito
            , p_dal   => trunc(sysdate)
            , p_al   => null
            , p_valore   => p_contatto
            , p_id_tipo_contatto  => d_id_tipo_contatto
            , p_note  => null
            , p_importanza => null
            , p_competenza => p_competenza
            , p_competenza_esclusiva  => p_competenza_esclusiva
            , p_version  => null
            , p_utente_aggiornamento  => nvl(p_utente_aggiornamento ,'WS')
            , p_data_aggiornamento  => trunc(sysdate)
            ) ;
           END IF;
     else -- p_indirizzo is not null
       -- controllo se non esiste già
      SELECT MAX(R.ID_RECAPITO)
          INTO D_ID_RECAPITO
          FROM RECAPITI R, ANAGRAFICI A
         WHERE A.NI = P_NI
           AND TRUNC(SYSDATE) BETWEEN A.DAL AND NVL(A.AL,TO_DATE(3333333,'J'))
           AND R.NI = P_NI
           AND R.ni = A.NI
           AND TRUNC(SYSDATE) BETWEEN R.DAL AND NVL(R.AL,TO_DATE(3333333,'J'))
        --   and r.id_tipo_recapito = d_id_tipo_recapito_residenza
           and nvl(r.comune,-100) = nvl(p_comune,-100)
           and nvl(r.provincia,-100) = nvl(p_provincia,-100)
           and nvl(r.indirizzo,'XXYYZZ**') = nvl(p_indirizzo,'XXYYZZ**')
           ;
      if d_id_recapito is null then
           select min(id_tipo_recapito)
            into d_id_tipo_recapito_generico
            from tipi_recapito
           where descrizione = 'GENERICO';
          if d_id_tipo_recapito_generico is null then
             raise_application_error(-20999,si4.get_error ('A10042') ||'(GENERICO)');
             --'Errore in determinazione tipo recapito GENERICO');
          end if;
     -- inserisco recapito generico e contatto generico
     d_id_recapito :=
             recapiti_tpk.ins(p_id_recapito => NULL
            , p_ni  => p_ni
            , p_dal => TRUNC(SYSDATE)
            , p_al  =>NULL
            , p_descrizione => NULL
            , p_id_tipo_recapito => d_id_tipo_recapito_generico
            , p_indirizzo  => p_indirizzo
            , p_provincia  => P_provincia
            , p_comune  => P_comune
            , p_cap  =>  NULL
            , p_presso  =>  NULL
            , p_importanza =>  NULL
            , p_competenza  => p_competenza
            , p_competenza_esclusiva  => p_competenza_esclusiva
            , p_version  =>  NULL
            , p_utente_aggiornamento   => nvl(p_utente_aggiornamento ,'WS')
            , p_data_aggiornamento  => SYSDATE
            );
     end if;
       D_ID_contatTO := contatti_tpk.ins(
              p_id_contatto  => null
            , p_id_recapito   => d_id_recapito
            , p_dal   => trunc(sysdate)
            , p_al   => null
            , p_valore   => p_contatto
            , p_id_tipo_contatto  => d_id_tipo_contatto
            , p_note  => null
            , p_importanza => null
            , p_competenza => p_competenza
            , p_competenza_esclusiva  => p_competenza_esclusiva
            , p_version  => null
            , p_utente_aggiornamento  =>   nvl(p_utente_aggiornamento ,'WS')
            , p_data_aggiornamento  => trunc(sysdate)
            ) ;
     end if;
    --raise_application_error(-20999,'recapito non aggiornabile');
    p_id_recapito := d_id_recapito;
    p_id_contatto := d_id_contatto;
    p_result := 0;
   end;

   function upd_recapito
   (p_id_recapito   in number
   ,p_ni            in number
   ,p_tipo_recapito in varchar2
   ,p_dal           in date
   ,p_al            in date
   ,p_descrizione   in varchar2
   ,p_indirizzo     in varchar2
   ,p_provincia     in number
   ,p_comune        in number
   ,p_cap           in varchar2
   ,p_presso        in varchar2
   ,p_importanza    in number
   ,p_utente_aggiornamento in varchar2 default null
   ,p_competenza              in varchar2 default null
   ,p_competenza_esclusiva     in varchar2 default null
   ) return number is
    d_id_tipo_recapito  number;
    d_id_recapito     number;
    d_ni                  anagrafici.ni%TYPE:= p_ni;
    d_dal                date:= p_dal;
    v_competenza_esclusiva varchar2(1) := p_competenza_esclusiva;
   begin
   if p_comune = -999 or p_provincia = -999 then -- viene passato dal plugin
         raise_application_error(-20999,si4.get_error('A10021') || '(recapito)');
      end if;

--       raise_application_error (-20999,p_id_recapito);
    if p_id_recapito is not null then -- voglio aggiornare esattamente quel recapito
        begin
            select id_tipo_recapito, ni, dal
              into d_id_tipo_recapito, d_ni , d_dal
              from recapiti
             where id_recapito = p_id_recapito
               and trunc(sysdate) between dal and nvl(al,to_date(3333333,'j'));
               d_id_recapito := p_id_recapito;
        exception when no_data_found then
            raise_application_error(-20999,si4.get_error ('A10055') );--'Recapito inesistente'); -- da codificare
        end ;

    else
        if p_al is null then
            begin
                select re.id_recapito, re.id_tipo_recapito
                  into d_id_recapito, d_id_tipo_recapito
                  from tipi_recapito tr, recapiti re
                 where re.ni = p_ni
                   and re.id_tipo_recapito = tr.id_tipo_recapito
                   and TR.id_tipo_recapito = p_tipo_recapito
                   and trunc(sysdate) between dal and nvl(al,to_date(3333333,'j'))
                   ;
            exception when no_data_found then
                raise_application_error(-20999,si4.get_error ('A10055') );--'Recapito inesistente'); -- da codificare
                when too_many_rows then
                raise_application_error(-20999,si4.get_error ('A10086') );--'Impossibile determinare recapito da aggiornare'); -- da codificare
            end;
        else
            begin
                select re.id_recapito, re.id_tipo_recapito
                  into d_id_recapito, d_id_tipo_recapito
                  from tipi_recapito tr, recapiti re
                 where re.ni = p_ni
                   and re.id_tipo_recapito = tr.id_tipo_recapito
                   and TR.DESCRIZIONE = p_tipo_recapito
                   and trunc(sysdate) between dal and nvl(al,to_date(3333333,'j'))
                   and nvl(comune,-100) = nvl(p_comune,-100)
                   and nvl(provincia,-100) = nvl(p_provincia,-100)
                   and nvl(indirizzo,'--XXYYZZ**') = nvl(p_indirizzo,'--XXYYZZ**')
                   ;
            exception when no_data_found then
                raise_application_error(-20999,si4.get_error ('A10055') );--'Recapito inesistente'); -- da codificare
                when too_many_rows then
                raise_application_error(-20999,si4.get_error ('A10086') );--'Impossibile determinare recapito da aggiornare'); -- da codificare
            end;
        end if;
    end if;
--    raise_application_error (-20999,' id : ' || d_id_recapito);
    if p_competenza = 'WS'
    then
    v_competenza_esclusiva := 'P';
    end if;
    recapiti_tpk.upd( P_CHECK_OLD=> 0
                , P_NEW_ID_RECAPITO=>d_id_recapito
                , P_OLD_ID_RECAPITO=>d_id_recapito
                , P_NEW_NI => d_ni
                , P_OLD_NI => d_ni
                , P_NEW_DAL => d_dal
                , P_NEW_AL => p_al
                , P_NEW_ID_TIPO_RECAPITO => d_id_tipo_recapito
                , P_NEW_INDIRIZZO => p_indirizzo
                , P_NEW_PROVINCIA => p_provincia
                , P_NEW_COMUNE => p_comune
                , p_new_descrizione => p_descrizione
                , p_new_presso => p_presso
                , p_new_importanza => p_importanza
                , P_NEW_CAP => p_cap
                , P_NEW_COMPETENZA => p_competenza
                , P_NEW_COMPETENZA_ESCLUSIVA => v_competenza_esclusiva
                , P_NEW_UTENTE_AGGIORNAMENTO => nvl(p_utente_aggiornamento ,'WS')
                , P_NEW_DATA_AGGIORNAMENTO => sysdate
                );
    begin
            select id_recapito
              into d_id_recapito
              from recapiti
             where dal = p_dal
               and ni = p_ni
               and id_tipo_recapito = d_id_tipo_recapito
               and nvl(comune,-100) = nvl(p_comune,-100)
               and nvl(provincia,-100) = nvl(p_provincia,-100)
               and nvl(indirizzo,'--XXYYZZ**') = nvl(p_indirizzo,'--XXYYZZ**')
               ;
        exception when others then
            d_id_recapito := null;
        end;
    return  d_id_recapito;
   end;

   function upd_contatto
   (p_id_contatto   in number
   ,p_ni            in number
   ,p_tipo_recapito in varchar2
   ,p_tipo_contatto in varchar2
   ,p_dal           in date
   ,p_al            in date
   ,p_valore        in varchar2
   ,p_note          in varchar2
   ,p_new_utente_aggiornamento in varchar2 default null
   ,p_competenza              in varchar2 default null
   ,p_competenza_esclusiva     in varchar2 default null
   ) return number is
    d_id_tipo_contatto  number;
    d_id_contatto     number;
    v_competenza_esclusiva varchar2(1) := p_competenza_esclusiva;
   begin
    if p_id_contatto is not null then -- voglio aggiornare esattamente quel contatto
        begin
            select id_tipo_contatto
              into d_id_tipo_contatto
              from contatti
             where id_contatto = p_id_contatto
               and trunc(sysdate) between dal and nvl(al,to_date(3333333,'j'));
               d_id_contatto := p_id_contatto;
        exception when no_data_found then
            raise_application_error(-20999,si4.get_error('A10053')); --'Contatto inesistente'); -- da codificare
        end ;
    else
        if p_al is null then
            begin
                select CO.ID_TIPO_CONTATTO, CO.ID_CONTATTO
                  into d_id_tipo_CONTATTO, d_id_CONTATTO
                  from tipi_recapito tr, recapiti re, contatti co , tipi_contatto tc
                 where re.ni = p_ni
                   and re.id_tipo_recapito = tr.id_tipo_recapito
                   and TR.id_tipo_recapito = p_tipo_recapito
                   and trunc(sysdate) between re.dal and nvl(re.al,to_date(3333333,'j'))
                   and re.id_recapito = co.id_recapito
                   and trunc(sysdate) between co.dal and nvl(co.al,to_date(3333333,'j'))
                   and TC.ID_TIPO_CONTATTO = CO.ID_TIPO_CONTATTO
                   and TC.id_tipo_contatto = P_TIPO_CONTATTO
                   ;
            exception when no_data_found then
                raise_application_error(-20999,si4.get_error('A10053')); --'Contatto inesistente'); -- da codificare
                when too_many_rows then
                raise_application_error(-20999,si4.get_error('A10087')); --'Impossibile determinare contatto da aggiornare'); -- da codificare
            end;
        else
            begin
            -- in questo caso si ipotizza che se al è pieno vogliono chiudere un periodo esistente
            --
                select CO.ID_TIPO_CONTATTO, CO.ID_CONTATTO
                  into d_id_tipo_CONTATTO, d_id_CONTATTO
                  from tipi_recapito tr, recapiti re, contatti co , tipi_contatto tc
                 where re.ni = p_ni
                   and re.id_tipo_recapito = tr.id_tipo_recapito
                   and TR.id_tipo_recapito = p_tipo_recapito
                   and trunc(sysdate) between re.dal and nvl(re.al,to_date(3333333,'j'))
                   and re.id_recapito = co.id_recapito
                   and trunc(sysdate) between co.dal and nvl(co.al,to_date(3333333,'j'))
                   and TC.ID_TIPO_CONTATTO = CO.ID_TIPO_CONTATTO
                   and TC.ID_TIPO_CONTATTO = p_tipo_CONTATto
                   and co.valore = P_VALORE
                   ;
            exception when no_data_found then
                raise_application_error(-20999,si4.get_error('A10053')); --'Contatto inesistente'); -- da codificare
                when too_many_rows then
                raise_application_error(-20999,si4.get_error('A10087')); --'Impossibile determinare contatto da aggiornare'); -- da codificare
            end;
        end if;
    end if;
    if p_competenza = 'WS'
    then
    v_competenza_esclusiva := 'P';
    end if;
       CONTATTI_tpk.upd( P_CHECK_OLD=> 0
                    , P_NEW_ID_CONTATTO=>d_id_CONTATTo
                    , P_OLD_ID_CONTATTO=>d_id_CONTATTo
                    , P_NEW_DAL => p_dal
                    , P_NEW_AL => null
                    , P_NEW_ID_TIPO_CONTATTO => d_id_tipo_CONTATTO
                    , P_NEW_VALORE => p_VALORE
                    , P_NEW_NOTE => p_NOTE
                    , P_NEW_COMPETENZA=> p_competenza
                    , P_NEW_COMPETENZA_ESCLUSIVA => v_competenza_esclusiva
                    , P_NEW_UTENTE_AGGIORNAMENTO =>  nvl(p_new_utente_aggiornamento ,'WS')
                    , P_NEW_DATA_AGGIORNAMENTO => sysdate
                    );
        begin
            select id_contatto
              into d_id_contatto
              from contatti
             where dal = p_dal
               and id_tipo_contatto = d_id_tipo_CONTATTO
               and valore = p_valore
               ;
        exception when others then
            d_id_contatto := null;
        end;
        RETURN D_ID_CONTATTO;
   end;

   function GET_ID_CONTATTO_TEL_RES
   (p_ni     IN ANAGRAFICI.ni%TYPE,
    p_dal    IN ANAGRAFICI.dal%TYPE
   ) return number
   is
    begin
        RETURN GET_ID_CONTATTO(ANAGRAFE_SOGGETTI_WS_PKG.GET_ID_RECAPITO_RES (p_NI, p_DAL),'TELEFONO');
    END;

   function GET_ID_CONTATTO_FAX_RES
   (p_ni     IN ANAGRAFICI.ni%TYPE,
    p_dal    IN ANAGRAFICI.dal%TYPE
   ) return number
   is
    begin
        RETURN GET_ID_CONTATTO(ANAGRAFE_SOGGETTI_WS_PKG.GET_ID_RECAPITO_RES (p_NI, p_DAL),'FAX');
    END;

    function GET_ID_CONTATTO_TEL_DOM
   (p_ni     IN ANAGRAFICI.ni%TYPE,
    p_dal    IN ANAGRAFICI.dal%TYPE
   ) return number
   is
    begin
        RETURN GET_ID_CONTATTO(ANAGRAFE_SOGGETTI_WS_PKG.GET_ID_RECAPITO_DOM (p_NI, p_DAL),'TELEFONO');
    END;

   function GET_ID_CONTATTO_FAX_DOM
   (p_ni     IN ANAGRAFICI.ni%TYPE,
    p_dal    IN ANAGRAFICI.dal%TYPE
   ) return number
   is
    begin
        RETURN GET_ID_CONTATTO(ANAGRAFE_SOGGETTI_WS_PKG.GET_ID_RECAPITO_DOM (p_NI, p_DAL),'FAX');
    END;

   function GET_ID_CONTATTO_INDIRIZZO_WEB
   (p_ni     IN ANAGRAFICI.ni%TYPE,
    p_dal    IN ANAGRAFICI.dal%TYPE
   ) return number
   is
    begin
        RETURN GET_ID_CONTATTO(ANAGRAFE_SOGGETTI_WS_PKG.GET_ID_RECAPITO_RES (p_NI, p_DAL),'MAIL');
    END;


END anagrafe_soggetti_ws_pkg;
/

