CREATE OR REPLACE PACKAGE BODY anagrafici_pkg
IS
    s_revisione_body                 CONSTANT AFC.t_revision := '045 - 04/03/2022';
    s_error_table                             AFC_Error.t_error_table;
    s_error_detail                            AFC_Error.t_error_table;
    comp_escl_no_progetto                     EXCEPTION;
    PRAGMA EXCEPTION_INIT (comp_escl_no_progetto, -20911);
    s_comp_escl_no_progetto_number   CONSTANT AFC_Error.t_error_number
                                                  := -20911 ;
    s_comp_escl_no_progetto_msg      CONSTANT AFC_Error.t_error_msg
                                                  := 'A10001' ;
    comp_escl_altrui                          EXCEPTION;
    PRAGMA EXCEPTION_INIT (comp_escl_altrui, -20912);
    s_comp_escl_altrui_number        CONSTANT AFC_Error.t_error_number
                                                  := -20912 ;
    s_comp_escl_altrui_msg           CONSTANT AFC_Error.t_error_msg
                                                  := 'A10002' ;
    comp_altrui                               EXCEPTION;
    PRAGMA EXCEPTION_INIT (comp_altrui, -20913);
    s_comp_altrui_number             CONSTANT AFC_Error.t_error_number
                                                  := -20913 ;
    s_comp_altrui_msg                CONSTANT AFC_Error.t_error_msg
                                                  := 'A10003' ;
    comu_sigla_prov                           EXCEPTION;
    PRAGMA EXCEPTION_INIT (comu_sigla_prov, -20941);
    s_comu_sigla_prov_num            CONSTANT AFC_Error.t_error_number
                                                  := -20941 ;
    s_comu_sigla_prov_msg            CONSTANT AFC_Error.t_error_msg
                                                  := 'A10041' ;


    d_indice_intermedia                       VARCHAR2 (2) := 'NO';

    /******************************************************************************
    NOME:        anagrafici_pkg
    DESCRIZIONE: Gestione tabella ANAGRAFICI.
    ANNOTAZIONI: .
     #################################################
       ATTENZIONE: se cambia questo package ricompilarlo
       anche come anagrafici_pkg_trasco
       sostituendo tutte le occorrenze di:
       TUTTI_NI_DAL_RES_DOM_OK
       con
       TUTTI_NI_DAL_RES_DOM_OK_TRASCO
     #################################################
    REVISIONI:   .
    Rev.  Data        Autore  Descrizione.
    001   25/09/2018  SNeg    Introdotta get_tipo_struttura
    ....
    011  17/10/2018 SNeg   Sistemato nvl nella greatest x calcolo del dal #33045
    012  07/01/2019 SNeg   Modificati controlli per trovare get_contatto_info
                           contatto e recapito devono essere entrambi validi in un periodo
   016  01/02/2019  SNeg Se non trovato ni da riutilizzare inserisco nuova anagrafica
   017  20/02/2019  SNeg  Introdotta nuova variabile x allineamento anagrafica solo dopo aver
                          sistemato tutte le informazioni
   018  26/02/2019  SNeg  Gestita uguaglianza sulle date di dal e al
   019  05/03/2019  SNeg  Sistemata chiamata a recapiti_tpk.ins x gestire campi presso e importanza
   020  12/03/2019  SNeg  Chiusura soggetto da anagrafe linare #33680
   021  18/03/2019  SNeg  Creazione allinea_anagrafica_e_residenza
   022  29/03/2019  SNeg  Get_contatto_info x tipi non mail
   023  01/04/2019  SNeg  Ripristinati controlli su valori non nulli x problema scarico ipa
   024  30/04/2019  SNeg  Comune e Provincia entrambi valorizzati o nulli Bug #34514
   027  10/09/2019  SNeg  Errato calcolo dal x contatti
   028  16/09/2019  SNeg  Aggiungere un contatto solo se non esiste gia
   029  17/09/2019  SNeg  RRI togliere nvl in verifica di periodo già chiuso con competenza P Bug #36936
   030  18/09/2019  SNeg  chiusura record se valore passato nullo x anagrafe lineare Bug #36934
   031  24/10/2019  SNeg  Campo indirizzo lungo almeno 120 caratteri Bug #37735
   032  29/10/2019  SNeg  Fare solo 1 volta la query sul contatto x velocizzare
   033  06/11/2019  SNeg  Non inserire il contatto se già presente Bug #38025
   034  11/11/2019  SNeg  Tempi lunghissimi in aggiornamento contatti Bug #38192
   035  28/01/2020  Sneg  Gestire parametro x abilitare aggiunta recapiti/contatti x IPA Feature #40221
   036  05/02/2020  Sneg  Consentire anche solo modifica di competenza e competenza_esclusiva Bug #40420
   037  25/02/2020  SNeg  Inserire contatto solo se già non presente Bug #40920
   038  12/10/2020  SNeg  Togliere dbms_output da RECAPITI_TIU ed ANAGRAFICI_PKG Bug #45130
                          utilizzato integritypackage.LOG al bisogno attivare con: integritypackage.setdebugon;
   039  10/11/2020  SNeg  Per aggiornare i contatti considerare anche la data del contatto appena creato Bug #45977
   040  19/11/2020  SNeg  Integrazione con ARCO introdurre e gestire tipo_ricapito 0 = LAVORO non modificabile da interfaccia Feature #46210
   041  20/11/2020  SNeg  Impedire aggiornamento di dati storici Introdotta function is_ultimo_dal Bug #34914
   042  21/12/2020  SNeg  Proteggere gli apici durante modifica denominazione_ricerca Bug #46872
   043  18/03/2021  SNeg  Proteggere caratteri speciali nei campi Bug #49059
   044  04/03/2022  MMon  Modifiche per scarico IPA Bug #54239
   045  01/12/2022  MMon  #60726
   ******************************************************************************/

    PROCEDURE init_ni (p_ni IN OUT anagrafici.ni%TYPE)
    IS
        /******************************************************************************
         NOME:        init_ni.
         DESCRIZIONE: Valorizza il campo NI.
         ARGOMENTI:   p_ni   IN OUT number campo NI.
         NOTE:        Valorizza il parametro p_ni, se nullo, con il primo valore libero
                      della sequence SOGG_SQ.
         REVISIONI:
         Rev. Data       Autore Descrizione
         ---- ---------- ------ ------------------------------------------------------
         000  28/06/2007 MM     Prima emissione.
        ******************************************************************************/
        v_trovato   NUMBER;
    BEGIN
        IF p_ni IS NULL
        THEN
            SELECT sogg_sq.NEXTVAL INTO p_ni FROM DUAL;

            -- se esisteva già record con quel ni prendo il successivo
            SELECT COUNT (*)
              INTO v_trovato
              FROM anagrafici
             WHERE ni = p_ni;

            WHILE v_trovato > 0
            LOOP
                SELECT sogg_sq.NEXTVAL INTO p_ni FROM DUAL;

                v_trovato := 0;

                SELECT COUNT (*)
                  INTO v_trovato
                  FROM anagrafici
                 WHERE ni = p_ni;
            END LOOP;
        END IF;
    END init_ni;

    PROCEDURE init_error_table
    IS
    /******************************************************************************
     NOME:        init_error_table
     DESCRIZIONE: Riempie la tabella degli errori con i messaggi relativi.
    ******************************************************************************/
    BEGIN
        -- inserimento degli errori nella tabella
        s_error_table (s_comp_escl_no_progetto_number) :=
            si4.get_error (s_comp_escl_no_progetto_msg);
        s_error_table (s_comp_escl_altrui_number) :=
            si4.get_error (s_comp_escl_altrui_msg);
        s_error_table (s_comp_altrui_number) :=
            si4.get_error (s_comp_altrui_msg);
        s_error_table (s_comu_sigla_prov_num) :=
            si4.get_error (s_comu_sigla_prov_msg);
    END init_error_table;

    FUNCTION error_message (p_err_number IN AFC_Error.t_error_number)
        RETURN AFC_Error.t_error_msg
    IS
        /******************************************************************************
         NOME:        error_message
         DESCRIZIONE: Messaggio previsto per il numero di eccezione indicato.
         NOTE:        Restituisce il messaggio abbinato al numero indicato nella tabella
                      s_error_table del Package. Se p_error_number non e presente nella
                      tabella s_error_table viene lanciata l'exception -20011
                      (vedi AFC_Error).
         REVISIONI:
         Rev. Data       Autore Descrizione
         ---- ---------- ------ ------------------------------------------------------
         000  28/06/2007 MM     Prima emissione.
        ******************************************************************************/
        d_result   AFC_Error.t_error_msg;
    BEGIN
        IF s_error_table.EXISTS (p_err_number)
        THEN
            d_result := s_error_table (p_err_number);
        ELSE
            raise_application_error (AFC_Error.exception_not_in_table_number,
                                     AFC_Error.exception_not_in_table_msg);
        END IF;

        RETURN d_result;
    END error_message;

    PROCEDURE raise_error_message (
        p_error_number   IN AFC_Error.t_error_number,
        p_precisazione   IN VARCHAR2 DEFAULT NULL)
    IS
        /******************************************************************************
         NOME:        raise_error_message
         DESCRIZIONE: Emette raise_application_error del messaggio previsto per il
                      numero di eccezione indicato.
         ARGOMENTI:   p_error_number   numero di eccezione da lanciare
                      p_precisazione   eventuale precisazione
         NOTE:        Se p_error_number non e presente nella tabella s_error_table
                      viene lanciata l'exception -20011 (vedi AFC_Error).
         REVISIONI:
         Rev. Data       Autore Descrizione
         ---- ---------- ------ ------------------------------------------------------
         000  28/06/2007 MM     Prima emissione.
        ******************************************************************************/
        d_result   AFC_Error.t_error_msg;
    BEGIN
        d_result := error_message (p_err_number => p_error_number);
        raise_application_error (
            p_error_number,
            s_error_table (p_error_number) || ' ' || p_precisazione);
    END raise_error_message;

    FUNCTION get_recapito_info (p_ni          anagrafici.ni%TYPE,
                                p_dal         anagrafici.dal%TYPE,
                                p_campo       VARCHAR2,
                                p_tipo_info   VARCHAR2)           -- RES o DOM
        RETURN VARCHAR2
    IS
        /******************************************************************************
        NOME:        get_recapito_info.
        DESCRIZIONE:
        ARGOMENTI:
        NOTE:
        REVISIONI:
        Rev. Data       Autore Descrizione
        ---- ---------- ------ ------------------------------------------------------
        000  02/01/2018 SNeg     Prima emissione.
        001  02/02/2018 SNeg   velocizzata
        031  24/10/2019  SNeg  Campo indirizzo lungo almeno 120 caratteri Bug #37735
       ******************************************************************************/
        v_valore        VARCHAR2 (32767); -- rev. 31
        v_descrizione   tipi_recapito.descrizione%TYPE;
        v_istruzione    VARCHAR2 (32767);
        v_id_recapito   NUMBER;
    BEGIN
        --       INDIRIZZO_RES,
        --   PROVINCIA_RES, COMUNE_RES, CAP_RES,
        --   TEL_RES, FAX_RES
        --, PRESSO(residenza)
        --   INDIRIZZO_DOM, PROVINCIA_DOM, COMUNE_DOM,
        --   CAP_DOM, TEL_DOM, FAX_DOM,
        IF p_tipo_info = 'RES'
        THEN
            v_descrizione := 'RESIDENZA';
        ELSIF p_tipo_info = 'DOM'
        THEN
            v_descrizione := 'DOMICILIO';
        END IF;

        -- inizio REV.001
        SELECT recapiti.id_recapito
          INTO v_id_recapito
          FROM recapiti, tipi_recapito
         WHERE     recapiti.id_tipo_recapito = tipi_recapito.id_tipo_recapito
               AND tipi_recapito.descrizione = v_descrizione
               AND recapiti.ni = p_ni
               AND p_dal BETWEEN recapiti.dal
                             AND NVL (recapiti.al, TO_DATE ('3333333', 'j'));

        EXECUTE IMMEDIATE   'select recapiti.'
                         || p_campo
                         || ' from recapiti  where id_recapito ='
                         || v_id_recapito
            INTO v_valore;

        -- fine REV.001
        RETURN v_valore;
    END;

    FUNCTION get_contatto_info (p_ni          anagrafici.ni%TYPE,
                                p_dal         anagrafici.dal%TYPE,
                                p_campo       VARCHAR2,  --MAIL, TELEFONO, FAX
                                p_tipo_info   VARCHAR2)           -- RES o DOM
        RETURN VARCHAR2
    IS
        /******************************************************************************
        NOME:        get_contatto_info.
        DESCRIZIONE:
        ARGOMENTI:
        NOTE:
        REVISIONI:
        Rev. Data       Autore Descrizione
        ---- ---------- ------ ------------------------------------------------------
        000  02/01/2018 SNeg   Prima emissione.
        001  02/02/2018 SNeg   velocizzata
        006  03/09/2018 SNeg   x integrazione con Contabilità Finanziaria prendiamo quello con importanza = 1
        009  15/10/2018 SNeg   controllo su record con importanza non presente
        012  07/01/2019 SNeg   Modificati controlli per trovare get_contatto_info
                               contatto e recapito devono essere entrambi validi in un periodo
        022  29/03/2019 SNeg  Get_contatto_info x tipi non mail
        031  24/10/2019  SNeg  Campo indirizzo lungo almeno 120 caratteri Bug #37735
        032  29/10/2019  SNeg  Fare solo 1 volta la query sul contatto x velocizzare
       ******************************************************************************/
        v_valore        VARCHAR2 (32767); -- rev. 32
        v_descrizione   tipi_recapito.descrizione%TYPE;
        v_istruzione    VARCHAR2 (32767);
    BEGIN
        --   TEL_RES, FAX_RES
        --   TEL_DOM, FAX_DOM,
        IF p_tipo_info = 'RES'
        THEN
            v_descrizione := 'RESIDENZA';
        ELSIF p_tipo_info = 'DOM'
        THEN
            v_descrizione := 'DOMICILIO';
        END IF;

        IF p_campo = 'MAIL' AND p_tipo_info = 'RES'
        -- x integrazione con Contabilità Finanziaria prendiamo quello con importanza = 1
        -- se esiste
        THEN
            BEGIN
                SELECT min(id_contatto)
                  INTO v_valore
                  FROM contatti,
                       recapiti,
                       tipi_recapito,
                       tipi_contatto
                 WHERE     contatti.id_recapito = recapiti.id_recapito
                       AND recapiti.id_tipo_recapito =
                           tipi_recapito.id_tipo_recapito
                       AND tipi_recapito.descrizione = v_descrizione
                       AND ni = p_ni
                       -- rev.12  Inizio
                       AND contatti.dal <=
                           NVL (recapiti.al, TO_DATE ('3333333', 'j'))
                       AND NVL (contatti.al, TO_DATE ('3333333', 'j')) >=
                           recapiti.dal
                       --                  AND contatti.dal BETWEEN recapiti.dal
                       --                                       AND NVL (recapiti.al,
                       --                                                TO_DATE ('3333333', 'j'))
                       -- rev.12 Fine
                       AND p_dal BETWEEN recapiti.dal
                                     AND NVL (recapiti.al,
                                              TO_DATE ('3333333', 'j'))
                       AND p_dal BETWEEN contatti.dal
                                     AND NVL (contatti.al,
                                              TO_DATE ('3333333', 'j'))
                       AND contatti.id_tipo_contatto =
                           tipi_contatto.id_tipo_contatto
                       AND tipi_contatto.descrizione = p_campo
                       -- rev. 32 inizio
                       and ( contatti.importanza = 1
                            or
                            not exists (select 1
                                          from contatti c2
                                         where contatti.id_tipo_contatto= c2.id_tipo_contatto
                                           and contatti.id_recapito = c2.id_recapito
                                           and  c2.dal <= NVL (recapiti.al, TO_DATE ('3333333', 'j'))
                                           and sysdate between c2.dal and NVL (c2.al, TO_DATE ('3333333', 'j'))
                                           and NVL (c2.al, TO_DATE ('3333333', 'j')) >= recapiti.dal
                                           and c2.importanza = 1)
                            );
            -- Inizio Rev.009
--            EXCEPTION
--                WHEN NO_DATA_FOUND
--                THEN
--                    -- inizio REV.001
--                    SELECT MIN (id_contatto)     -- valore prendiamo il minimo
--                      INTO v_valore
--                      FROM contatti,
--                           recapiti,
--                           tipi_recapito,
--                           tipi_contatto
--                     WHERE     contatti.id_recapito = recapiti.id_recapito
--                           AND recapiti.id_tipo_recapito =
--                               tipi_recapito.id_tipo_recapito
--                           AND tipi_recapito.descrizione = v_descrizione
--                           AND ni = p_ni
--                           -- rev.12  Inizio
--                           AND contatti.dal <=
--                               NVL (recapiti.al, TO_DATE ('3333333', 'j'))
--                           AND NVL (contatti.al, TO_DATE ('3333333', 'j')) >=
--                               recapiti.dal
--                           --                  AND contatti.dal BETWEEN recapiti.dal
--                           --                                       AND NVL (recapiti.al,
--                           --                                                TO_DATE ('3333333', 'j'))
--                           -- rev.12 Fine
--                           AND p_dal BETWEEN recapiti.dal
--                                         AND NVL (recapiti.al,
--                                                  TO_DATE ('3333333', 'j'))
--                           AND p_dal BETWEEN contatti.dal
--                                         AND NVL (contatti.al,
--                                                  TO_DATE ('3333333', 'j'))
--                           AND contatti.id_tipo_contatto =
--                               tipi_contatto.id_tipo_contatto
--                           AND tipi_contatto.descrizione = p_campo;
            --fine REV.001
            -- rev. 32 fine
            END;                                               -- fine Rev.009
        ELSE                           -- non mail di residenza  rev.22 inizio
            SELECT MIN (id_contatto)             -- valore prendiamo il minimo
              INTO v_valore
              FROM contatti,
                   recapiti,
                   tipi_recapito,
                   tipi_contatto
             WHERE     contatti.id_recapito = recapiti.id_recapito
                   AND recapiti.id_tipo_recapito =
                       tipi_recapito.id_tipo_recapito
                   AND tipi_recapito.descrizione = v_descrizione
                   AND ni = p_ni
                   -- rev.12  Inizio
                   AND contatti.dal <=
                       NVL (recapiti.al, TO_DATE ('3333333', 'j'))
                   AND NVL (contatti.al, TO_DATE ('3333333', 'j')) >=
                       recapiti.dal
                   --                  AND contatti.dal BETWEEN recapiti.dal
                   --                                       AND NVL (recapiti.al,
                   --                                                TO_DATE ('3333333', 'j'))
                   -- rev.12 Fine
                   AND p_dal BETWEEN recapiti.dal
                                 AND NVL (recapiti.al,
                                          TO_DATE ('3333333', 'j'))
                   AND p_dal BETWEEN contatti.dal
                                 AND NVL (contatti.al,
                                          TO_DATE ('3333333', 'j'))
                   AND contatti.id_tipo_contatto =
                       tipi_contatto.id_tipo_contatto
                   AND tipi_contatto.descrizione = p_campo;
        --rev.22 fine
        END IF;

        IF v_valore IS NOT NULL
        THEN
            RETURN contatti_tpk.get_valore (v_valore);
        ELSE
            RETURN NULL;
        END IF;
    END;

    FUNCTION get_ultimo_recapito_info (p_ni          anagrafici.ni%TYPE,
                                       p_dal         anagrafici.dal%TYPE,
                                       p_campo       VARCHAR2,
                                       p_tipo_info   VARCHAR2)    -- RES o DOM
        RETURN VARCHAR2
    IS
        v_valore        VARCHAR2 (100);
        v_descrizione   tipi_recapito.descrizione%TYPE;
        v_istruzione    VARCHAR2 (32767);
    BEGIN
        --       INDIRIZZO_RES,
        --   PROVINCIA_RES, COMUNE_RES, CAP_RES,
        --   TEL_RES, FAX_RES
        --, PRESSO(residenza)
        --   INDIRIZZO_DOM, PROVINCIA_DOM, COMUNE_DOM,
        --   CAP_DOM, TEL_DOM, FAX_DOM,
        IF p_tipo_info = 'RES'
        THEN
            v_descrizione := 'RESIDENZA';
        ELSIF p_tipo_info = 'DOM'
        THEN
            v_descrizione := 'DOMICILIO';
        END IF;

        v_istruzione :=
               'select min(recapiti.'
            || p_campo
            || ' ) from recapiti, tipi_recapito where recapiti.id_tipo_recapito = tipi_recapito.id_tipo_recapito and  tipi_recapito.descrizione= '''
            || v_descrizione
            || ''' and recapiti.ni = '
            || p_ni
            || ' and '
            || 'to_date('''
            || TO_CHAR (p_dal, 'dd/mm/yyyy hh24:mi:ss')
            || ''',''dd/mm/yyyy hh24:mi:ss'') <= nvl(recapiti.al, to_date(''3333333'',''j''))'
            || ' and not exists (select 1 from recapiti r where r.ni = '
            || p_ni
            || ' and recapiti.dal < r.dal)';

        --dbms_output.put_line('istruzione:' || v_istruzione);
        EXECUTE IMMEDIATE   'select min(recapiti.'
                         || p_campo
                         || ') from recapiti, tipi_recapito where recapiti.id_tipo_recapito = tipi_recapito.id_tipo_recapito and  tipi_recapito.descrizione= '''
                         || v_descrizione
                         || ''' and recapiti.ni = '
                         || p_ni
                         || ' and '
                         || 'to_date('''
                         || TO_CHAR (p_dal, 'dd/mm/yyyy hh24:mi:ss')
                         || ''',''dd/mm/yyyy hh24:mi:ss'')<= nvl(recapiti.al, to_date(''3333333'',''j''))'
                         || ' and not exists (select 1 from recapiti r where r.ni = '
                         || p_ni
                         || ' and recapiti.dal < r.dal)'
            INTO v_valore;

        RETURN v_valore;
    END;

    FUNCTION get_ultimo_contatto_info (p_ni          anagrafici.ni%TYPE,
                                       p_dal         anagrafici.dal%TYPE,
                                       p_campo       VARCHAR2, --MAIL, TELEFONO, FAX
                                       p_tipo_info   VARCHAR2)    -- RES o DOM
        RETURN VARCHAR2
    IS
        v_valore        VARCHAR2 (100);
        v_descrizione   tipi_recapito.descrizione%TYPE;
        v_istruzione    VARCHAR2 (32767);
    BEGIN
        --   TEL_RES, FAX_RES
        --   TEL_DOM, FAX_DOM,
        IF p_tipo_info = 'RES'
        THEN
            v_descrizione := 'RESIDENZA';
        ELSIF p_tipo_info = 'DOM'
        THEN
            v_descrizione := 'DOMICILIO';
        END IF;

        v_istruzione :=
               'SELECT min(id_contatto) --valore
  FROM contatti,
       recapiti,
       tipi_recapito,
       tipi_contatto
 WHERE     contatti.id_recapito = recapiti.id_recapito
       AND recapiti.id_tipo_recapito = tipi_recapito.id_tipo_recapito
       AND tipi_recapito.descrizione = '''
            || v_descrizione
            || '''
                      AND ni = '
            || p_ni
            || ' and '
            || 'to_date('''
            || TO_CHAR (p_dal, 'dd/mm/yyyy hh24:mi:ss')
            || ''',''dd/mm/yyyy hh24:mi:ss'')
                      <= NVL (recapiti.al,TO_DATE ( ''3333333'',''j''))
                      AND recapiti.dal BETWEEN contatti.dal
                                           AND NVL (contatti.al,TO_DATE (''3333333'', ''j''))
       AND recapiti.dal <= NVL (contatti.al, TO_DATE (''3333333'', ''j''))
       AND contatti.id_tipo_contatto = tipi_contatto.id_tipo_contatto
       AND tipi_contatto.descrizione = '''
            || p_campo
            || ''''
            || ' and not exists (select 1 from contatti c where c.id_contatto = contatti.id_contatto and contatti.dal < c.dal)'
            || ' and not exists (select 1 from recapiti r where r.ni = recapiti.ni and recapiti.dal < r.dal)';

        --      dbms_output.put_line('istruzione:' || v_istruzione);
        EXECUTE IMMEDIATE   'SELECT min(id_contatto) --valore
  FROM contatti,
       recapiti,
       tipi_recapito,
       tipi_contatto
 WHERE     contatti.id_recapito = recapiti.id_recapito
       AND recapiti.id_tipo_recapito = tipi_recapito.id_tipo_recapito
       AND tipi_recapito.descrizione = '''
                         || v_descrizione
                         || '''
                      AND ni = '
                         || p_ni
                         || ' and '
                         || 'to_date('''
                         || TO_CHAR (p_dal, 'dd/mm/yyyy hh24:mi:ss')
                         || ''',''dd/mm/yyyy hh24:mi:ss'')
                      <= NVL (recapiti.al,TO_DATE ( ''3333333'',''j''))
--                      AND recapiti.dal BETWEEN contatti.dal
--                                           AND NVL (contatti.al,TO_DATE (''3333333'', ''j''))
 AND contatti.dal BETWEEN recapiti.dal
                                           AND NVL (recapiti.al,TO_DATE (''3333333'', ''j''))
       AND recapiti.dal <= NVL (contatti.al, TO_DATE (''3333333'', ''j''))
       AND contatti.id_tipo_contatto = tipi_contatto.id_tipo_contatto
       AND tipi_contatto.descrizione = '''
                         || p_campo
                         || ''''
                         || ' and not exists (select 1 from recapiti r where r.ni = recapiti.ni and recapiti.dal < r.dal)'
                         || ' and not exists (select 1 from contatti c where c.id_contatto = contatti.id_contatto and contatti.dal < c.dal)'
            INTO v_valore;

        IF v_valore IS NOT NULL
        THEN
            RETURN contatti_tpk.get_valore (v_valore);             --v_valore;
        ELSE
            RETURN NULL;
        END IF;
    END;                                         /* get_ultimo_contatto_info*/

    FUNCTION get_recapito_ad_oggi_info (p_ni          anagrafici.ni%TYPE,
                                        p_dal         anagrafici.dal%TYPE,
                                        p_campo       VARCHAR2,
                                        p_tipo_info   VARCHAR2)   -- RES o DOM
        RETURN VARCHAR2
    IS
        v_valore        VARCHAR2 (100);
        v_descrizione   tipi_recapito.descrizione%TYPE;
        v_istruzione    VARCHAR2 (32767);
    BEGIN
        --       INDIRIZZO_RES,
        --   PROVINCIA_RES, COMUNE_RES, CAP_RES,
        --   TEL_RES, FAX_RES
        --, PRESSO(residenza)
        --   INDIRIZZO_DOM, PROVINCIA_DOM, COMUNE_DOM,
        --   CAP_DOM, TEL_DOM, FAX_DOM,
        IF p_tipo_info = 'RES'
        THEN
            v_descrizione := 'RESIDENZA';
        ELSIF p_tipo_info = 'DOM'
        THEN
            v_descrizione := 'DOMICILIO';
        END IF;

        v_istruzione :=
               'select min(recapiti.'
            || p_campo
            || ') from recapiti, tipi_recapito where recapiti.id_tipo_recapito = tipi_recapito.id_tipo_recapito and  tipi_recapito.descrizione= '''
            || v_descrizione
            || ''' and recapiti.ni = '
            || p_ni
            || ' and  sysdate between recapiti.dal and nvl(recapiti.al, to_date(''3333333'',''j''))'
            || ' and to_date('''
            || TO_CHAR (p_dal, 'dd/mm/yyyy hh24:mi:ss')
            || ''',''dd/mm/yyyy hh24:mi:ss'') <= nvl(recapiti.al, to_date(''3333333'',''j''))'
            || ' and not exists (select 1 from recapiti r where r.ni = '
            || p_ni
            || ' and recapiti.dal < r.dal and sysdate between r.dal and nvl(r.al, to_date(''3333333'',''j'')))';

        --dbms_output.put_line('istruzione:' || v_istruzione);
        EXECUTE IMMEDIATE   'select min(recapiti.'
                         || p_campo
                         || ') from recapiti, tipi_recapito where recapiti.id_tipo_recapito = tipi_recapito.id_tipo_recapito and  tipi_recapito.descrizione= '''
                         || v_descrizione
                         || ''' and recapiti.ni = '
                         || p_ni
                         || ' and  sysdate between recapiti.dal and nvl(recapiti.al, to_date(''3333333'',''j''))'
                         || ' and to_date('''
                         || TO_CHAR (p_dal, 'dd/mm/yyyy hh24:mi:ss')
                         || ''',''dd/mm/yyyy hh24:mi:ss'')<= nvl(recapiti.al, to_date(''3333333'',''j''))'
                         || ' and not exists (select 1 from recapiti r where r.ni = '
                         || p_ni
                         || ' and recapiti.dal < r.dal and sysdate between r.dal and nvl(r.al, to_date(''3333333'',''j'')) )'
            INTO v_valore;

        RETURN v_valore;
    END;                                        /* get_recapito_ad_oggi_info*/

    FUNCTION get_contatto_ad_oggi_info (p_ni          anagrafici.ni%TYPE,
                                        p_dal         anagrafici.dal%TYPE,
                                        p_campo       VARCHAR2, --MAIL, TELEFONO, FAX
                                        p_tipo_info   VARCHAR2)   -- RES o DOM
        RETURN VARCHAR2
    IS
        v_valore        VARCHAR2 (100);
        v_descrizione   tipi_recapito.descrizione%TYPE;
        v_istruzione    VARCHAR2 (32767);
    BEGIN
        --   TEL_RES, FAX_RES
        --   TEL_DOM, FAX_DOM,
        IF p_tipo_info = 'RES'
        THEN
            v_descrizione := 'RESIDENZA';
        ELSIF p_tipo_info = 'DOM'
        THEN
            v_descrizione := 'DOMICILIO';
        END IF;

        v_istruzione :=
               'SELECT min(valore)
  FROM contatti,
       recapiti,
       tipi_recapito,
       tipi_contatto
 WHERE     contatti.id_recapito = recapiti.id_recapito
       AND recapiti.id_tipo_recapito = tipi_recapito.id_tipo_recapito
       AND tipi_recapito.descrizione = '''
            || v_descrizione
            || '''
                      AND ni = '
            || p_ni
            || ' and '
            || 'to_date('''
            || TO_CHAR (p_dal, 'dd/mm/yyyy hh24:mi:ss')
            || ''',''dd/mm/yyyy hh24:mi:ss'')
                      <= NVL (recapiti.al,TO_DATE ( ''3333333'',''j''))
                      AND recapiti.dal BETWEEN contatti.dal
                                           AND NVL (contatti.al,TO_DATE (''3333333'', ''j''))
                      and sysdate between recapiti.dal and nvl(recapiti.al, to_date(''3333333'',''j''))
                      and sysdate between contatti.dal and nvl(contatti.al, to_date(''3333333'',''j''))
       AND recapiti.dal <= NVL (contatti.al, TO_DATE (''3333333'', ''j''))
       AND contatti.id_tipo_contatto = tipi_contatto.id_tipo_contatto
       AND tipi_contatto.descrizione = '''
            || p_campo
            || ''''
            || ' and not exists (select 1 from contatti c where c.id_contatto = contatti.id_contatto and contatti.dal < c.dal and sysdate between c.dal and nvl(c.al, to_date(''3333333'',''j'')))'
            || ' and not exists (select 1 from recapiti r where r.ni = recapiti.ni and recapiti.dal < r.dal and sysdate between r.dal and nvl(r.al, to_date(''3333333'',''j'')))';

        --            dbms_output.put_line('istruzione:' || v_istruzione);
        EXECUTE IMMEDIATE   'SELECT min(valore)
  FROM contatti,
       recapiti,
       tipi_recapito,
       tipi_contatto
 WHERE     contatti.id_recapito = recapiti.id_recapito
       AND recapiti.id_tipo_recapito = tipi_recapito.id_tipo_recapito
       AND tipi_recapito.descrizione = '''
                         || v_descrizione
                         || '''
                      AND ni = '
                         || p_ni
                         || ' and '
                         || 'to_date('''
                         || TO_CHAR (p_dal, 'dd/mm/yyyy hh24:mi:ss')
                         || ''',''dd/mm/yyyy hh24:mi:ss'')
                      <= NVL (recapiti.al,TO_DATE ( ''3333333'',''j''))
                      AND recapiti.dal BETWEEN contatti.dal
                                           AND NVL (contatti.al,TO_DATE (''3333333'', ''j''))
       and sysdate between recapiti.dal and nvl(recapiti.al, to_date(''3333333'',''j''))
       and sysdate between contatti.dal and nvl(contatti.al, to_date(''3333333'',''j''))
       AND recapiti.dal <= NVL (contatti.al, TO_DATE (''3333333'', ''j''))
       AND contatti.id_tipo_contatto = tipi_contatto.id_tipo_contatto
       AND tipi_contatto.descrizione = '''
                         || p_campo
                         || ''''
                         || ' and not exists (select 1 from recapiti r where r.ni = recapiti.ni and recapiti.dal < r.dal and sysdate between r.dal and nvl(r.al, to_date(''3333333'',''j'')))'
                         || ' and not exists (select 1 from contatti c where c.id_contatto = contatti.id_contatto and contatti.dal < c.dal and sysdate between c.dal and nvl(c.al, to_date(''3333333'',''j'')))'
            INTO v_valore;

        RETURN v_valore;
    END;                                         /*get_contatto_ad_oggi_info*/

    FUNCTION ins (
        p_id_anagrafica           IN ANAGRAFICI.id_anagrafica%TYPE DEFAULT NULL,
        p_ni                      IN ANAGRAFICI.ni%TYPE DEFAULT NULL,
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
        p_batch                      NUMBER DEFAULT 0         -- 0 = NON batch
                                                     )
        RETURN NUMBER
    IS
        v_trovato_ni                 NUMBER;
        v_da_inserire                VARCHAR2 (2) := 'NO';
        v_id_anagrafica              ANAGRAFICI.ni%TYPE;
        v_ni                         ANAGRAFICI.ni%TYPE;
        v_al                         DATE := p_al;
        v_stato_soggetto             anagrafici.stato_soggetto%TYPE;
        v_id_anagrafica_utilizzare   VARCHAR2 (2);
        v_tipo_soggetto              ANAGRAFICI.tipo_soggetto%TYPE
                                         := p_tipo_soggetto; --nvl(p_tipo_soggetto,'I');
    -- previsto default x insert partendo dalla SOGGETTI (giusto?????????????)
    BEGIN
        -- test x verificare se ci sono soggetti in "conflitto"
        -- però la prima volta avevamo parlato di tornare un ref- cursor mentre la
        -- seconda un ni... ci devo pensare
        -- idea al lancio è di provare ad inserire
        -- se Ok torno NI
        -- se ci sono "ambigui" ritorno codice di errore.
        --     raise_application_error (-20999, 'nuovo tipo' || p_tipo_soggetto);
        IF NVL (p_batch, 0) != 0 AND p_ni IS NULL      -- non ho già scelto NI
        THEN
            -- è una attività batch
            v_trovato_ni :=
                get_anagrafica_alternativa (p_ni,
                                            p_cognome,
                                            p_nome,
                                            p_partita_iva,
                                            p_codice_fiscale,
                                            p_competenza,
                                            v_id_anagrafica_utilizzare);
        -- se v_trovato_ni = -1 allora inserisco
        -- record chiuso logicamente
        -- non ci sono casi in cui non devo inserire se batch??
        --         IF  v_trovato_ni is null --(nvl(v_trovato_ni,-1) != -1 and get_ultimo_al (v_trovato_ni) IS NOT NULL
        --                 OR v_trovato_ni = -1
        --         THEN
        --            v_da_inserire := 'SI';
        --         END IF;
        --
        --         IF v_da_inserire = 'SI'
        --         THEN
        END IF;                                                -- se ho già NI

        IF v_trovato_ni = -1
        THEN
            v_al := (TRUNC (SYSDATE) + 1) - (1);
            v_stato_soggetto := 'C';
            v_id_anagrafica := NULL;
            v_trovato_ni := NULL;               -- non uso -1 che non ha senso
        ELSE                                        -- v_trovato è valorizzato
            v_stato_soggetto := p_stato_soggetto;
            v_id_anagrafica := NULL;
        -- uso ni trovato e il trigger chiuderà ni precedente
        -- oppure è nullo e verrà inserito record nuovo
        --               v_stato_soggetto := '';
        --               v_al := TO_DATE ('');
        -- uso ni trovato x il quale è già stato chiuso il periodo
        END IF;

        IF v_id_anagrafica_utilizzare IS NULL -- ritornato dal check se anagrafica esistente e NON da aggiornare.
        THEN
            IF NVL (LENGTH (p_codice_fiscale), 0) > 16
            THEN
                raise_application_error (
                    -20999,
                    si4.get_error ('A10006') || ' massimo 16 caratteri' -- 'Codice Fiscale Errato'
                                                                       );
            END IF;

            -- modificata chiamata con passaggio nominale
            v_id_anagrafica :=
                anagrafici_tpk.ins (
                    p_id_anagrafica           => v_id_anagrafica,
                    p_ni                      => NVL (v_trovato_ni, p_ni),
                    p_dal                     => p_dal,
                    p_al                      => v_al,
                    p_cognome                 => p_cognome,
                    p_nome                    => p_nome,
                    p_sesso                   => p_sesso,
                    p_data_nas                => p_data_nas,
                    p_provincia_nas           => p_provincia_nas,
                    p_comune_nas              => p_comune_nas,
                    p_luogo_nas               => p_luogo_nas,
                    p_codice_fiscale          => p_codice_fiscale,
                    p_codice_fiscale_estero   => p_codice_fiscale_estero,
                    p_partita_iva             => p_partita_iva,
                    p_cittadinanza            => p_cittadinanza,
                    p_gruppo_ling             => p_gruppo_ling,
                    p_competenza              => p_competenza,
                    p_competenza_esclusiva    => p_competenza_esclusiva,
                    p_tipo_soggetto           => v_tipo_soggetto,
                    p_stato_cee               => p_stato_cee,
                    p_partita_iva_cee         => p_partita_iva_cee,
                    p_fine_validita           => p_fine_validita,
                    p_stato_soggetto          => v_stato_soggetto,
                    p_denominazione           => p_denominazione,
                    p_note                    => p_note,
                    p_version                 => p_version,
                    p_utente                  => p_utente,
                    p_data_agg                => p_data_agg);
        ELSE                         -- riutilizzo di una anagrafica esistente
            v_id_anagrafica := v_id_anagrafica_utilizzare;
        END IF;

        --         END IF;
        --      END IF;
        RETURN v_id_anagrafica;
    END;

    PROCEDURE upd (
        p_NEW_id_anagrafica           IN ANAGRAFICI.id_anagrafica%TYPE,
        p_NEW_ni                      IN ANAGRAFICI.ni%TYPE DEFAULT afc.default_null (
                                                                        'ANAGRAFICI.ni'),
        p_NEW_dal                     IN ANAGRAFICI.dal%TYPE DEFAULT afc.default_null (
                                                                         'ANAGRAFICI.dal'),
        p_NEW_al                      IN ANAGRAFICI.al%TYPE DEFAULT afc.default_null (
                                                                        'ANAGRAFICI.al'),
        p_NEW_cognome                 IN ANAGRAFICI.cognome%TYPE DEFAULT afc.default_null (
                                                                             'ANAGRAFICI.cognome'),
        p_NEW_nome                    IN ANAGRAFICI.nome%TYPE DEFAULT afc.default_null (
                                                                          'ANAGRAFICI.nome'),
        p_NEW_sesso                   IN ANAGRAFICI.sesso%TYPE DEFAULT afc.default_null (
                                                                           'ANAGRAFICI.sesso'),
        p_NEW_data_nas                IN ANAGRAFICI.data_nas%TYPE DEFAULT afc.default_null (
                                                                              'ANAGRAFICI.data_nas'),
        p_NEW_provincia_nas           IN ANAGRAFICI.provincia_nas%TYPE DEFAULT afc.default_null (
                                                                                   'ANAGRAFICI.provincia_nas'),
        p_NEW_comune_nas              IN ANAGRAFICI.comune_nas%TYPE DEFAULT afc.default_null (
                                                                                'ANAGRAFICI.comune_nas'),
        p_NEW_luogo_nas               IN ANAGRAFICI.luogo_nas%TYPE DEFAULT afc.default_null (
                                                                               'ANAGRAFICI.luogo_nas'),
        p_NEW_codice_fiscale          IN ANAGRAFICI.codice_fiscale%TYPE DEFAULT afc.default_null (
                                                                                    'ANAGRAFICI.codice_fiscale'),
        p_NEW_codice_fiscale_estero   IN ANAGRAFICI.codice_fiscale_estero%TYPE DEFAULT afc.default_null (
                                                                                           'ANAGRAFICI.codice_fiscale_estero'),
        p_NEW_partita_iva             IN ANAGRAFICI.partita_iva%TYPE DEFAULT afc.default_null (
                                                                                 'ANAGRAFICI.partita_iva'),
        p_NEW_cittadinanza            IN ANAGRAFICI.cittadinanza%TYPE DEFAULT afc.default_null (
                                                                                  'ANAGRAFICI.cittadinanza'),
        p_NEW_gruppo_ling             IN ANAGRAFICI.gruppo_ling%TYPE DEFAULT afc.default_null (
                                                                                 'ANAGRAFICI.gruppo_ling'),
        p_NEW_competenza              IN ANAGRAFICI.competenza%TYPE DEFAULT afc.default_null (
                                                                                'ANAGRAFICI.competenza'),
        p_NEW_competenza_esclusiva    IN ANAGRAFICI.competenza_esclusiva%TYPE DEFAULT afc.default_null (
                                                                                          'ANAGRAFICI.competenza_esclusiva'),
        p_NEW_tipo_soggetto           IN ANAGRAFICI.tipo_soggetto%TYPE DEFAULT afc.default_null (
                                                                                   'ANAGRAFICI.tipo_soggetto'),
        p_NEW_stato_cee               IN ANAGRAFICI.stato_cee%TYPE DEFAULT afc.default_null (
                                                                               'ANAGRAFICI.stato_cee'),
        p_NEW_partita_iva_cee         IN ANAGRAFICI.partita_iva_cee%TYPE DEFAULT afc.default_null (
                                                                                     'ANAGRAFICI.partita_iva_cee'),
        p_NEW_fine_validita           IN ANAGRAFICI.fine_validita%TYPE DEFAULT afc.default_null (
                                                                                   'ANAGRAFICI.fine_validita'),
        p_NEW_stato_soggetto          IN ANAGRAFICI.stato_soggetto%TYPE DEFAULT afc.default_null (
                                                                                    'ANAGRAFICI.stato_soggetto'),
        p_NEW_denominazione           IN ANAGRAFICI.denominazione%TYPE DEFAULT afc.default_null (
                                                                                   'ANAGRAFICI.denominazione'),
        p_NEW_note                    IN ANAGRAFICI.note%TYPE DEFAULT afc.default_null (
                                                                          'ANAGRAFICI.note'),
        p_NEW_version                 IN ANAGRAFICI.version%TYPE DEFAULT afc.default_null (
                                                                             'ANAGRAFICI.version'),
        p_NEW_utente                  IN ANAGRAFICI.utente%TYPE DEFAULT afc.default_null (
                                                                            'ANAGRAFICI.utente'),
        p_NEW_data_aggiornamento      IN ANAGRAFICI.data_agg%TYPE DEFAULT afc.default_null (
                                                                              'ANAGRAFICI.data_agg'),
        p_batch                          NUMBER DEFAULT 0     -- 0 = NON batch
                                                         )
    IS
    BEGIN
        anagrafici_tpk.upd (
            p_check_OLD                   => 0,
            p_NEW_id_anagrafica           => p_NEW_id_anagrafica,
            p_NEW_ni                      => p_NEW_ni,
            p_NEW_dal                     => p_NEW_dal,
            p_NEW_al                      => p_NEW_al,
            p_NEW_cognome                 => p_NEW_cognome,
            p_NEW_nome                    => p_NEW_nome,
            p_NEW_sesso                   => p_NEW_sesso,
            p_NEW_data_nas                => p_NEW_data_nas,
            p_NEW_provincia_nas           => p_NEW_provincia_nas,
            p_NEW_comune_nas              => p_NEW_comune_nas,
            p_NEW_luogo_nas               => p_NEW_luogo_nas,
            p_NEW_codice_fiscale          => p_NEW_codice_fiscale,
            p_NEW_codice_fiscale_estero   => p_NEW_codice_fiscale_estero,
            p_NEW_partita_iva             => p_NEW_partita_iva,
            p_NEW_cittadinanza            => p_NEW_cittadinanza,
            p_NEW_gruppo_ling             => p_NEW_gruppo_ling,
            p_NEW_competenza              => p_NEW_competenza,
            p_NEW_competenza_esclusiva    => p_NEW_competenza_esclusiva,
            p_NEW_tipo_soggetto           => p_NEW_tipo_soggetto,
            p_NEW_stato_cee               => p_NEW_stato_cee,
            p_NEW_partita_iva_cee         => p_NEW_partita_iva_cee,
            p_NEW_fine_validita           => p_NEW_fine_validita,
            p_NEW_stato_soggetto          => p_NEW_stato_soggetto,
            p_NEW_denominazione           => p_NEW_denominazione,
            p_NEW_note                    => p_NEW_note,
            p_NEW_version                 => p_NEW_version,
            p_NEW_utente                  => p_NEW_utente,
            p_NEW_data_agg                => p_NEW_data_aggiornamento);
    END upd;                                             -- anagrafici_pkg.upd

    --
    --
    ---- Aggiornamento di una riga
    --   procedure upd  /*+ SOA  */
    --   (
    --     p_check_OLD  in integer default 0
    --   , p_NEW_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
    --   , p_OLD_id_anagrafica  in ANAGRAFICI.id_anagrafica%type default null
    --   , p_NEW_ni  in ANAGRAFICI.ni%type default afc.default_null('ANAGRAFICI.ni')
    --   , p_OLD_ni  in ANAGRAFICI.ni%type default null
    --   , p_NEW_dal  in ANAGRAFICI.dal%type default afc.default_null('ANAGRAFICI.dal')
    --   , p_OLD_dal  in ANAGRAFICI.dal%type default null
    --   , p_NEW_al  in ANAGRAFICI.al%type default afc.default_null('ANAGRAFICI.al')
    --   , p_OLD_al  in ANAGRAFICI.al%type default null
    --   , p_NEW_cognome  in ANAGRAFICI.cognome%type default afc.default_null('ANAGRAFICI.cognome')
    --   , p_OLD_cognome  in ANAGRAFICI.cognome%type default null
    --   , p_NEW_nome  in ANAGRAFICI.nome%type default afc.default_null('ANAGRAFICI.nome')
    --   , p_OLD_nome  in ANAGRAFICI.nome%type default null
    --   , p_NEW_sesso  in ANAGRAFICI.sesso%type default afc.default_null('ANAGRAFICI.sesso')
    --   , p_OLD_sesso  in ANAGRAFICI.sesso%type default null
    --   , p_NEW_data_nas  in ANAGRAFICI.data_nas%type default afc.default_null('ANAGRAFICI.data_nas')
    --   , p_OLD_data_nas  in ANAGRAFICI.data_nas%type default null
    --   , p_NEW_provincia_nas  in ANAGRAFICI.provincia_nas%type default afc.default_null('ANAGRAFICI.provincia_nas')
    --   , p_OLD_provincia_nas  in ANAGRAFICI.provincia_nas%type default null
    --   , p_NEW_comune_nas  in ANAGRAFICI.comune_nas%type default afc.default_null('ANAGRAFICI.comune_nas')
    --   , p_OLD_comune_nas  in ANAGRAFICI.comune_nas%type default null
    --   , p_NEW_luogo_nas  in ANAGRAFICI.luogo_nas%type default afc.default_null('ANAGRAFICI.luogo_nas')
    --   , p_OLD_luogo_nas  in ANAGRAFICI.luogo_nas%type default null
    --   , p_NEW_codice_fiscale  in ANAGRAFICI.codice_fiscale%type default afc.default_null('ANAGRAFICI.codice_fiscale')
    --   , p_OLD_codice_fiscale  in ANAGRAFICI.codice_fiscale%type default null
    --   , p_NEW_codice_fiscale_estero  in ANAGRAFICI.codice_fiscale_estero%type default afc.default_null('ANAGRAFICI.codice_fiscale_estero')
    --   , p_OLD_codice_fiscale_estero  in ANAGRAFICI.codice_fiscale_estero%type default null
    --   , p_NEW_partita_iva  in ANAGRAFICI.partita_iva%type default afc.default_null('ANAGRAFICI.partita_iva')
    --   , p_OLD_partita_iva  in ANAGRAFICI.partita_iva%type default null
    --   , p_NEW_cittadinanza  in ANAGRAFICI.cittadinanza%type default afc.default_null('ANAGRAFICI.cittadinanza')
    --   , p_OLD_cittadinanza  in ANAGRAFICI.cittadinanza%type default null
    --   , p_NEW_gruppo_ling  in ANAGRAFICI.gruppo_ling%type default afc.default_null('ANAGRAFICI.gruppo_ling')
    --   , p_OLD_gruppo_ling  in ANAGRAFICI.gruppo_ling%type default null
    --   , p_NEW_competenza  in ANAGRAFICI.competenza%type default afc.default_null('ANAGRAFICI.competenza')
    --   , p_OLD_competenza  in ANAGRAFICI.competenza%type default null
    --   , p_NEW_competenza_esclusiva  in ANAGRAFICI.competenza_esclusiva%type default afc.default_null('ANAGRAFICI.competenza_esclusiva')
    --   , p_OLD_competenza_esclusiva  in ANAGRAFICI.competenza_esclusiva%type default null
    --   , p_NEW_tipo_soggetto  in ANAGRAFICI.tipo_soggetto%type default afc.default_null('ANAGRAFICI.tipo_soggetto')
    --   , p_OLD_tipo_soggetto  in ANAGRAFICI.tipo_soggetto%type default null
    --   , p_NEW_stato_cee  in ANAGRAFICI.stato_cee%type default afc.default_null('ANAGRAFICI.stato_cee')
    --   , p_OLD_stato_cee  in ANAGRAFICI.stato_cee%type default null
    --   , p_NEW_partita_iva_cee  in ANAGRAFICI.partita_iva_cee%type default afc.default_null('ANAGRAFICI.partita_iva_cee')
    --   , p_OLD_partita_iva_cee  in ANAGRAFICI.partita_iva_cee%type default null
    --   , p_NEW_fine_validita  in ANAGRAFICI.fine_validita%type default afc.default_null('ANAGRAFICI.fine_validita')
    --   , p_OLD_fine_validita  in ANAGRAFICI.fine_validita%type default null
    --   , p_NEW_stato_soggetto  in ANAGRAFICI.stato_soggetto%type default afc.default_null('ANAGRAFICI.stato_soggetto')
    --   , p_OLD_stato_soggetto  in ANAGRAFICI.stato_soggetto%type default null
    --   , p_NEW_denominazione  in ANAGRAFICI.denominazione%type default afc.default_null('ANAGRAFICI.denominazione')
    --   , p_OLD_denominazione  in ANAGRAFICI.denominazione%type default null
    --   , p_NEW_note  in ANAGRAFICI.note%type default afc.default_null('ANAGRAFICI.note')
    --   , p_OLD_note  in ANAGRAFICI.note%type default null
    --   , p_NEW_version  in ANAGRAFICI.version%type default afc.default_null('ANAGRAFICI.version')
    --   , p_OLD_version  in ANAGRAFICI.version%type default null
    --   , p_NEW_utente  in ANAGRAFICI.utente%type default afc.default_null('ANAGRAFICI.utente')
    --   , p_OLD_utente  in ANAGRAFICI.utente%type default null
    --   , p_NEW_data_agg  in ANAGRAFICI.data_agg%type default afc.default_null('ANAGRAFICI.data_agg')
    --   , p_OLD_data_agg  in ANAGRAFICI.data_agg%type default null
    --   , p_batch                      NUMBER DEFAULT 0           -- 0 = NON batch
    --   )
    --   IS
    --   BEGIN
    --   anagrafici_tpk.upd  /*+ SOA  */
    --   ( p_check_OLD                  => p_check_OLD
    --   , p_NEW_id_anagrafica          => p_NEW_id_anagrafica
    --   , p_OLD_id_anagrafica          => p_OLD_id_anagrafica
    --   , p_NEW_ni                     => p_NEW_ni
    --   , p_OLD_ni                     => p_OLD_ni
    --   , p_NEW_dal                    => p_NEW_dal
    --   , p_OLD_dal                    => p_OLD_dal
    --   , p_NEW_al                     => p_NEW_al
    --   , p_OLD_al                     => p_OLD_al
    --   , p_NEW_cognome                => p_NEW_cognome
    --   , p_OLD_cognome                => p_OLD_cognome
    --   , p_NEW_nome                   => p_NEW_nome
    --   , p_OLD_nome                   => p_OLD_nome
    --   , p_NEW_sesso                  => p_NEW_sesso
    --   , p_OLD_sesso                  => p_OLD_sesso
    --   , p_NEW_data_nas               => p_NEW_data_nas
    --   , p_OLD_data_nas               => p_OLD_data_nas
    --   , p_NEW_provincia_nas          => p_NEW_provincia_nas
    --   , p_OLD_provincia_nas          => p_OLD_provincia_nas
    --   , p_NEW_comune_nas             => p_NEW_comune_nas
    --   , p_OLD_comune_nas             => p_OLD_comune_nas
    --   , p_NEW_luogo_nas              => p_NEW_luogo_nas
    --   , p_OLD_luogo_nas              => p_OLD_luogo_nas
    --   , p_NEW_codice_fiscale         => p_NEW_codice_fiscale
    --   , p_OLD_codice_fiscale         => p_OLD_codice_fiscale
    --   , p_NEW_codice_fiscale_estero  => p_NEW_codice_fiscale_estero
    --   , p_OLD_codice_fiscale_estero  => p_OLD_codice_fiscale_estero
    --   , p_NEW_partita_iva            => p_NEW_partita_iva
    --   , p_OLD_partita_iva            => p_OLD_partita_iva
    --   , p_NEW_cittadinanza           => p_NEW_cittadinanza
    --   , p_OLD_cittadinanza           => p_OLD_cittadinanza
    --   , p_NEW_gruppo_ling            => p_NEW_gruppo_ling
    --   , p_OLD_gruppo_ling            => p_OLD_gruppo_ling
    --   , p_NEW_competenza             => p_NEW_competenza
    --   , p_OLD_competenza             => p_OLD_competenza
    --   , p_NEW_competenza_esclusiva   => p_NEW_competenza_esclusiva
    --   , p_OLD_competenza_esclusiva   => p_OLD_competenza_esclusiva
    --   , p_NEW_tipo_soggetto          => p_NEW_tipo_soggetto
    --   , p_OLD_tipo_soggetto          => p_OLD_tipo_soggetto
    --   , p_NEW_stato_cee              => p_NEW_stato_cee
    --   , p_OLD_stato_cee              => p_OLD_stato_cee
    --   , p_NEW_partita_iva_cee        => p_NEW_partita_iva_cee
    --   , p_OLD_partita_iva_cee        => p_OLD_partita_iva_cee
    --   , p_NEW_fine_validita          => p_NEW_fine_validita
    --   , p_OLD_fine_validita          => p_OLD_fine_validita
    --   , p_NEW_stato_soggetto         => p_NEW_stato_soggetto
    --   , p_OLD_stato_soggetto         => p_OLD_stato_soggetto
    --   , p_NEW_denominazione          => p_NEW_denominazione
    --   , p_OLD_denominazione          => p_OLD_denominazione
    --   , p_NEW_note                   => p_NEW_note
    --   , p_OLD_note                   => p_OLD_note
    --   , p_NEW_version                => p_NEW_version
    --   , p_OLD_version                => p_OLD_version
    --   , p_NEW_utente                 => p_NEW_utente
    --   , p_OLD_utente                 => p_OLD_utente
    --   , p_NEW_data_agg               => p_NEW_data_agg
    --   , p_OLD_data_agg               => p_OLD_data_agg
    --   );
    --   END;
    --   FUNCTION ins_old (
    --      p_id_anagrafica           IN ANAGRAFICI.id_anagrafica%TYPE DEFAULT NULL ,
    --      p_ni                      IN ANAGRAFICI.ni%TYPE,
    --      p_dal                     IN ANAGRAFICI.dal%TYPE,
    --      p_al                      IN ANAGRAFICI.al%TYPE DEFAULT NULL ,
    --      p_cognome                 IN ANAGRAFICI.cognome%TYPE,
    --      p_nome                    IN ANAGRAFICI.nome%TYPE DEFAULT NULL ,
    --      p_sesso                   IN ANAGRAFICI.sesso%TYPE DEFAULT NULL ,
    --      p_data_nas                IN ANAGRAFICI.data_nas%TYPE DEFAULT NULL ,
    --      p_provincia_nas           IN ANAGRAFICI.provincia_nas%TYPE DEFAULT NULL ,
    --      p_comune_nas              IN ANAGRAFICI.comune_nas%TYPE DEFAULT NULL ,
    --      p_luogo_nas               IN ANAGRAFICI.luogo_nas%TYPE DEFAULT NULL ,
    --      p_codice_fiscale          IN ANAGRAFICI.codice_fiscale%TYPE DEFAULT NULL ,
    --      p_codice_fiscale_estero   IN ANAGRAFICI.codice_fiscale_estero%TYPE DEFAULT NULL
    --                                                                           ,
    --      p_partita_iva             IN ANAGRAFICI.partita_iva%TYPE DEFAULT NULL ,
    --      p_cittadinanza            IN ANAGRAFICI.cittadinanza%TYPE DEFAULT NULL ,
    --      p_gruppo_ling             IN ANAGRAFICI.gruppo_ling%TYPE DEFAULT NULL ,
    --      p_competenza              IN ANAGRAFICI.competenza%TYPE DEFAULT NULL ,
    --      p_competenza_esclusiva    IN ANAGRAFICI.competenza_esclusiva%TYPE DEFAULT NULL
    --                                                                          ,
    --      p_tipo_soggetto           IN ANAGRAFICI.tipo_soggetto%TYPE DEFAULT NULL ,
    --      p_stato_cee               IN ANAGRAFICI.stato_cee%TYPE DEFAULT NULL ,
    --      p_partita_iva_cee         IN ANAGRAFICI.partita_iva_cee%TYPE DEFAULT NULL
    --                                                                     ,
    --      p_fine_validita           IN ANAGRAFICI.fine_validita%TYPE DEFAULT NULL ,
    --      p_stato_soggetto          IN ANAGRAFICI.stato_soggetto%TYPE DEFAULT 'U' ,
    --      p_denominazione           IN ANAGRAFICI.denominazione%TYPE DEFAULT NULL ,
    --      p_note                    IN ANAGRAFICI.note%TYPE DEFAULT NULL ,
    --      p_version                 IN ANAGRAFICI.version%TYPE DEFAULT NULL ,
    --      p_utente                  IN ANAGRAFICI.utente%TYPE DEFAULT NULL ,
    --      p_data_agg                IN ANAGRAFICI.data_agg%TYPE DEFAULT SYSDATE ,
    --      p_motivo                     VARCHAR2
    --   )
    --      RETURN NUMBER
    --   /******************************************************************************
    --    NOME:        ins
    --    DESCRIZIONE: Inserimento di una riga con chiave e attributi indicati.
    --    PARAMETRI:   Chiavi e attributi della table.
    --    RITORNA:     In caso di PK formata da colonna numerica, ritorna il valore della PK
    --                 (se positivo), in tutti gli altri casi ritorna 0; in caso di errore,
    --                 ritorna il codice di errore
    --   ******************************************************************************/
    --   IS
    --      d_result   NUMBER;
    --   BEGIN
    --      -- Check Mandatory on Insert
    --
    --      BEGIN
    --         INSERT INTO ANAGRAFICI (id_anagrafica,
    --                                 ni,
    --                                 dal,
    --                                 al,
    --                                 cognome,
    --                                 nome,
    --                                 sesso,
    --                                 data_nas,
    --                                 provincia_nas,
    --                                 comune_nas,
    --                                 luogo_nas,
    --                                 codice_fiscale,
    --                                 codice_fiscale_estero,
    --                                 partita_iva,
    --                                 cittadinanza,
    --                                 gruppo_ling,
    --                                 competenza,
    --                                 competenza_esclusiva,
    --                                 tipo_soggetto,
    --                                 stato_cee,
    --                                 partita_iva_cee,
    --                                 fine_validita,
    --                                 stato_soggetto,
    --                                 denominazione,
    --                                 note,
    --                                 version,
    --                                 utente,
    --                                 data_agg)
    --           VALUES   (p_id_anagrafica,
    --                     p_ni,
    --                     p_dal,
    --                     p_al,
    --                     p_cognome,
    --                     p_nome,
    --                     p_sesso,
    --                     p_data_nas,
    --                     p_provincia_nas,
    --                     p_comune_nas,
    --                     p_luogo_nas,
    --                     p_codice_fiscale,
    --                     p_codice_fiscale_estero,
    --                     p_partita_iva,
    --                     p_cittadinanza,
    --                     p_gruppo_ling,
    --                     p_competenza,
    --                     p_competenza_esclusiva,
    --                     p_tipo_soggetto,
    --                     p_stato_cee,
    --                     p_partita_iva_cee,
    --                     p_fine_validita,
    --                     p_stato_soggetto,
    --                     p_denominazione,
    --                     p_note,
    --                     p_version,
    --                     p_utente,
    --                     p_data_agg);
    --
    --         d_result := 0;
    --      EXCEPTION
    --         WHEN OTHERS
    --         THEN
    --            d_result := SQLCODE;
    --      END;
    --
    --      RETURN d_result;
    --   END;                                                  -- anagrafici_tpk.ins
    FUNCTION ins_anag_e_res_e_mail (
        -- dati anagrafica
        --      p_id_anagrafica           IN ANAGRAFICI.id_anagrafica%TYPE DEFAULT NULL,
        p_ni                      IN ANAGRAFICI.ni%TYPE DEFAULT NULL,
        p_dal                     IN ANAGRAFICI.dal%TYPE,
        p_al                      IN ANAGRAFICI.al%TYPE DEFAULT NULL,
        p_cognome                 IN ANAGRAFICI.cognome%TYPE,
        p_nome                    IN ANAGRAFICI.nome%TYPE DEFAULT NULL,
        p_sesso                   IN ANAGRAFICI.sesso%TYPE DEFAULT NULL,
        p_data_nas                IN ANAGRAFICI.data_nas%TYPE DEFAULT NULL,
        p_provincia_nas           IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL,
        p_comune_nas              IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL,
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
        p_descrizione_residenza   IN RECAPITI.descrizione%TYPE DEFAULT NULL --p_descrizione
                                                                           --    , p_id_tipo_recapito  in RECAPITI.id_tipo_recapito%type
                                                                           ,
        p_indirizzo_res           IN RECAPITI.indirizzo%TYPE DEFAULT NULL,
        p_provincia_res           IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL,
        p_comune_res              IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL,
        p_cap_res                 IN RECAPITI.cap%TYPE DEFAULT NULL,
        p_presso                  IN RECAPITI.presso%TYPE DEFAULT NULL,
        p_importanza              IN RECAPITI.importanza%TYPE DEFAULT NULL ---- mail
                                                                          ,
        p_mail                    IN CONTATTI.valore%TYPE DEFAULT NULL -- p_valore
                                                                      --    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
                                                                      ,
        p_note_mail               IN CONTATTI.note%TYPE DEFAULT NULL,
        p_importanza_mail         IN CONTATTI.importanza%TYPE DEFAULT NULL ---- tel res
                                                                          ,
        p_tel_res                 IN CONTATTI.valore%TYPE DEFAULT NULL -- p_valore
                                                                      --    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
                                                                      ,
        p_note_tel_res            IN CONTATTI.note%TYPE DEFAULT NULL,
        p_importanza_tel_res      IN CONTATTI.importanza%TYPE DEFAULT NULL ---- fax res
                                                                          ,
        p_fax_res                 IN CONTATTI.valore%TYPE DEFAULT NULL -- p_valore
                                                                      --    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
                                                                      ,
        p_note_fax_res            IN CONTATTI.note%TYPE DEFAULT NULL,
        p_importanza_fax_res      IN CONTATTI.importanza%TYPE DEFAULT NULL,
        ---- dati generici
        p_utente                  IN ANAGRAFICI.utente%TYPE DEFAULT NULL,
        p_data_agg                IN ANAGRAFICI.data_agg%TYPE DEFAULT SYSDATE --      ,
                                                                             --      p_batch                      NUMBER DEFAULT 1           -- 0 = NON batch
                                                                             )
        RETURN NUMBER
    IS
        /*************************************************************************

        019  05/03/2019  SNeg  Sistemata chiamata a recapiti_tpk.ins x gestire campi presso e importanza
        *************************************************************************/
        v_id_anagrafica      anagrafici.id_anagrafica%TYPE;
        v_new_ni             anagrafici.ni%TYPE;
        v_new_dal            DATE;
        d_id_recapito        recapiti.id_recapito%TYPE;
        d_id_contatto        CONTATTI.id_recapito%TYPE;
        d_contatto_valore    contatti.valore%TYPE;
        d_note               contatti.note%TYPE;
        d_id_tipo_contatto   tipi_contatto.id_tipo_contatto%TYPE;
        v_provincia_nas      AD4_PROVINCE.sigla%TYPE;
        v_comune_nas         AD4_COMUNI.denominazione%TYPE;
        v_provincia_res      AD4_PROVINCE.sigla%TYPE;
        v_comune_res         AD4_COMUNI.denominazione%TYPE;
    BEGIN
        IF p_provincia_nas IS NOT NULL
        THEN
            v_provincia_nas :=
                ad4_provincia.get_provincia (NULL,            -- denominazione
                                                   p_provincia_nas);  -- sigla
        END IF;

        IF p_comune_nas IS NOT NULL
        THEN
            v_comune_nas := AD4_comune.GET_COMUNE (p_comune_nas, NULL, 0); -- lo voglio attivo
        END IF;

        IF p_provincia_res IS NOT NULL
        THEN
            v_provincia_res :=
                ad4_provincia.get_provincia (NULL,            -- denominazione
                                                   p_provincia_res);  -- sigla
        END IF;

        IF p_comune_res IS NOT NULL
        THEN
            v_comune_res := AD4_comune.GET_COMUNE (p_comune_res, NULL, 0); -- lo voglio attivo
        END IF;

        IF NVL (LENGTH (p_codice_fiscale), 0) > 16
        THEN
            raise_application_error (
                -20999,
                si4.get_error ('A10006') || ' massimo 16 caratteri' -- 'Codice Fiscale Errato'
                                                                   );
        END IF;

        -- modificata chiamata con passaggio nominale
        v_id_anagrafica :=
            anagrafici_pkg.ins (
                p_id_anagrafica           => NULL, --p_id_anagrafica           ,
                p_ni                      => NULL, --p_ni                      ,
                p_dal                     => p_dal,
                p_al                      => p_al,
                p_cognome                 => p_cognome,
                p_nome                    => p_nome,
                p_sesso                   => p_sesso,
                p_data_nas                => p_data_nas,
                p_provincia_nas           => v_provincia_nas,
                p_comune_nas              => v_comune_nas,
                p_luogo_nas               => p_luogo_nas,
                p_codice_fiscale          => p_codice_fiscale,
                p_codice_fiscale_estero   => p_codice_fiscale_estero,
                p_partita_iva             => p_partita_iva,
                p_cittadinanza            => p_cittadinanza,
                p_gruppo_ling             => p_gruppo_ling,
                p_competenza              => p_competenza,
                p_competenza_esclusiva    => p_competenza_esclusiva,
                p_tipo_soggetto           => p_tipo_soggetto,
                p_stato_cee               => p_stato_cee,
                p_partita_iva_cee         => p_partita_iva_cee,
                p_fine_validita           => p_fine_validita,
                p_stato_soggetto          => p_stato_soggetto,
                p_denominazione           => p_denominazione,
                p_note                    => p_note_anag,
                p_version                 => NULL,
                p_utente                  => p_utente,
                p_data_agg                => p_data_agg              --      ,
                                                       --      p_batch =>      p_batch
                                                       );
        v_new_ni := anagrafici_tpk.get_ni (v_id_anagrafica);
        v_new_dal := anagrafici_tpk.get_dal (v_id_anagrafica);

        -- insert in sedi x residenza
        IF    p_descrizione_residenza IS NOT NULL
           OR p_indirizzo_res IS NOT NULL
           OR p_provincia_res IS NOT NULL
           OR p_comune_res IS NOT NULL
           OR p_cap_res IS NOT NULL
           OR p_presso IS NOT NULL
           OR p_tel_res IS NOT NULL
           OR p_fax_res IS NOT NULL           -- ci sono contatti di residenza
           OR p_mail IS NOT NULL
        THEN
            d_id_recapito :=
                recapiti_tpk.ins (
                    p_id_recapito            => NULL,
                    p_ni                     => v_new_ni,              --p_ni,
                    p_dal                    => v_new_dal,            --p_dal,
                    p_al                     => p_al,
                    p_descrizione            => p_descrizione_residenza,
                    p_id_tipo_recapito       => 1 -- RESIDENZA p_id_tipo_recapito
                                                 ,
                    p_indirizzo              => p_indirizzo_res,
                    p_provincia              => v_provincia_res,
                    p_comune                 => v_comune_res,
                    p_cap                    => p_cap_res,
                    p_presso                 => p_presso,
                    p_importanza             => p_importanza,
                    p_competenza             => p_competenza,
                    p_competenza_esclusiva   => p_competenza_esclusiva,
                    p_version                => '',               --p_version,
                    p_utente_aggiornamento   => p_utente,
                    p_data_aggiornamento     => p_data_agg);

            -- inserimento del contatto x residenza
            IF    p_tel_res IS NOT NULL
               OR p_fax_res IS NOT NULL       -- ci sono contatti di residenza
               OR p_mail IS NOT NULL
            THEN
                FOR cont IN 1 .. 3
                LOOP
                    --1 = TELEFONO
                    --2 = FAX
                    --3 = MAIL
                    d_contatto_valore := NULL;

                    IF CONT = 1 AND p_TEL_RES IS NOT NULL
                    THEN
                        d_contatto_valore := p_tel_res;
                        d_note := p_note_tel_res;
                        d_id_tipo_contatto := 1;
                    ELSIF cont = 2 AND p_fax_res IS NOT NULL
                    THEN
                        d_contatto_valore := p_fax_res;
                        d_note := p_note_fax_res;
                        d_id_tipo_contatto := 2;
                    ELSIF cont = 3 AND p_mail IS NOT NULL
                    THEN
                        d_contatto_valore := p_mail;
                        d_note := p_note_mail;
                        d_id_tipo_contatto := 3;
                    END IF;

                    IF d_contatto_valore IS NOT NULL
                    THEN
                        d_id_contatto :=
                            contatti_tpk.ins (
                                p_id_contatto            => '',
                                p_id_recapito            => d_id_recapito,
                                p_dal                    => v_new_dal, --p_dal,
                                p_al                     => p_al,
                                p_valore                 => d_contatto_valore,
                                p_id_tipo_contatto       => d_id_tipo_contatto,
                                p_note                   => d_note,
                                p_competenza             => p_competenza,
                                p_competenza_esclusiva   =>
                                    p_competenza_esclusiva,
                                p_version                => '',   --p_version,
                                p_utente_aggiornamento   => p_utente,
                                p_data_aggiornamento     => p_data_agg);
                    END IF;
                END LOOP;
            END IF;
        END IF;

        RETURN v_id_anagrafica;
    END;

    FUNCTION ins_anag_dom_e_res_e_mail (
        -- dati anagrafica
        --      p_id_anagrafica           IN ANAGRAFICI.id_anagrafica%TYPE DEFAULT NULL,
        p_ni                      IN ANAGRAFICI.ni%TYPE DEFAULT NULL,
        p_dal                     IN ANAGRAFICI.dal%TYPE,
        p_al                      IN ANAGRAFICI.al%TYPE DEFAULT NULL,
        p_cognome                 IN ANAGRAFICI.cognome%TYPE,
        p_nome                    IN ANAGRAFICI.nome%TYPE DEFAULT NULL,
        p_sesso                   IN ANAGRAFICI.sesso%TYPE DEFAULT NULL,
        p_data_nas                IN ANAGRAFICI.data_nas%TYPE DEFAULT NULL,
        p_provincia_nas           IN AD4_PROVINCE.provincia%TYPE DEFAULT NULL,
        p_comune_nas              IN AD4_COMUNI.comune%TYPE DEFAULT NULL,
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
        p_descrizione_residenza   IN RECAPITI.descrizione%TYPE DEFAULT NULL --p_descrizione
                                                                           --    , p_id_tipo_recapito  in RECAPITI.id_tipo_recapito%type
                                                                           ,
        p_indirizzo_res           IN RECAPITI.indirizzo%TYPE DEFAULT NULL,
        p_provincia_res           IN AD4_PROVINCE.provincia%TYPE DEFAULT NULL,
        p_comune_res              IN AD4_COMUNI.comune%TYPE DEFAULT NULL,
        p_cap_res                 IN RECAPITI.cap%TYPE DEFAULT NULL,
        p_presso                  IN RECAPITI.presso%TYPE DEFAULT NULL,
        p_importanza              IN RECAPITI.importanza%TYPE DEFAULT NULL ---- mail
                                                                          ,
        p_mail                    IN CONTATTI.valore%TYPE DEFAULT NULL -- p_valore
                                                                      --    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
                                                                      ,
        p_note_mail               IN CONTATTI.note%TYPE DEFAULT NULL,
        p_importanza_mail         IN CONTATTI.importanza%TYPE DEFAULT NULL ---- tel res
                                                                          ,
        p_tel_res                 IN CONTATTI.valore%TYPE DEFAULT NULL -- p_valore
                                                                      --    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
                                                                      ,
        p_note_tel_res            IN CONTATTI.note%TYPE DEFAULT NULL,
        p_importanza_tel_res      IN CONTATTI.importanza%TYPE DEFAULT NULL ---- fax res
                                                                          ,
        p_fax_res                 IN CONTATTI.valore%TYPE DEFAULT NULL -- p_valore
                                                                      --    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
                                                                      ,
        p_note_fax_res            IN CONTATTI.note%TYPE DEFAULT NULL,
        p_importanza_fax_res      IN CONTATTI.importanza%TYPE DEFAULT NULL -- dati DOMICILIO
                                                                          ,
        p_descrizione_dom         IN RECAPITI.descrizione%TYPE DEFAULT NULL --p_descrizione
                                                                           ,
        p_indirizzo_dom           IN RECAPITI.indirizzo%TYPE DEFAULT NULL,
        p_provincia_dom           IN AD4_PROVINCE.provincia%TYPE DEFAULT NULL,
        p_comune_dom              IN AD4_COMUNI.comune%TYPE DEFAULT NULL,
        p_cap_dom                 IN RECAPITI.cap%TYPE DEFAULT NULL ---- tel dom
                                                                   ,
        p_tel_dom                 IN CONTATTI.valore%TYPE DEFAULT NULL -- p_valore
                                                                      --    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
                                                                      ,
        p_note_tel_dom            IN CONTATTI.note%TYPE DEFAULT NULL,
        p_importanza_tel_dom      IN CONTATTI.importanza%TYPE DEFAULT NULL ---- fax dom
                                                                          ,
        p_fax_dom                 IN CONTATTI.valore%TYPE DEFAULT NULL -- p_valore
                                                                      --    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
                                                                      ,
        p_note_fax_dom            IN CONTATTI.note%TYPE DEFAULT NULL ---- dati generici
                                                                    ,
        p_utente                  IN ANAGRAFICI.utente%TYPE DEFAULT NULL,
        p_data_agg                IN ANAGRAFICI.data_agg%TYPE DEFAULT SYSDATE,
        p_batch                      NUMBER DEFAULT 0         -- 0 = NON batch
                                                     )
        RETURN NUMBER
    IS
        /******************************************************************************
        NOME:        ins_anag_dom_e_res_e_mail.
        DESCRIZIONE: inserisce da record piatto.
        ARGOMENTI:
        NOTE:
        REVISIONI:
        Rev. Data       Autore Descrizione
        ---- ---------- ------ ------------------------------------------------------
        011  17/10/2018 SNeg   Sistemato nvl nella greatest x calcolo del dal
        014 15/01/2019  SNeg  Se non esiste anagrafica aperta faccio finta sia cambiata
                                           Anagrafica diversa anche se cambiata competenza o competenza_esclusiva
        016  01/02/2019  SNeg Se non trovato ni da riutilizzare inserisco nuova anagrafica
        037  25/02/2020  SNeg  Inserire contatto solo se già non presente Bug #40920
        038  12/10/2020  SNeg  Togliere dbms_output da RECAPITI_TIU ed ANAGRAFICI_PKG Bug #45130
       ******************************************************************************/
        v_id_anagrafica              anagrafici.id_anagrafica%TYPE;
        v_new_ni                     anagrafici.ni%TYPE;
        v_new_dal                    DATE;
        v_old_anagrafe_soggetti      anagrafe_soggetti%ROWTYPE;
        d_id_recapito                recapiti.id_recapito%TYPE;
        d_id_contatto                CONTATTI.id_recapito%TYPE;
        d_contatto_valore            contatti.valore%TYPE;
        d_note                       contatti.note%TYPE;
        d_id_tipo_contatto           tipi_contatto.id_tipo_contatto%TYPE;
        v_trovato_ni                 NUMBER;
        v_da_inserire                VARCHAR2 (2) := 'NO';
        v_ni                         ANAGRAFICI.ni%TYPE;
        v_al                         DATE;
        v_stato_soggetto             anagrafici.stato_soggetto%TYPE;
        v_id_anagrafica_utilizzare   VARCHAR2 (2);
        v_tipo_soggetto              ANAGRAFICI.tipo_soggetto%TYPE
                                         := p_tipo_soggetto; --nvl(p_tipo_soggetto,'I');
        v_cognome                    anagrafici.cognome%TYPE;
        v_nome                       anagrafici.nome%TYPE;
        d_pointer                    NUMBER;
        -- AD  17/01/2018 modifica per default su tipo soggetto da chiamata da protocollo
        d_tipo_soggetto              VARCHAR2 (1) := p_tipo_soggetto;
        --
        -- previsto default x insert partendo dalla SOGGETTI (giusto?????????????)

        v_cambiata_anagrafica        NUMBER := 1;    -- di default da inserire
        v_creare_recapito            NUMBER := 1;    -- di default da inserire
        v_dal_contatto               DATE;
        v_old_contatto               CONTATTI%ROWTYPE;
    BEGIN
        anagrafici_pkg.v_aggiornamento_da_package_on := 1;
        -- test x verificare se ci sono soggetti in "conflitto"
        -- però la prima volta avevamo parlato di tornare un ref- cursor mentre la
        -- seconda un ni... ci devo pensare
        -- idea al lancio è di provare ad inserire
        -- se Ok torno NI
        -- se ci sono "ambigui" ritorno codice di errore.
        v_cognome := p_cognome;
        v_nome := p_nome;

        IF NVL (LENGTH (p_codice_fiscale), 0) > 16
        THEN
            raise_application_error (
                -20999,
                si4.get_error ('A10006') || ' massimo 16 caratteri' -- 'Codice Fiscale Errato'
                                                                   );
        END IF;

        IF NVL (p_batch, 0) != 0 AND p_ni IS NULL      -- non ho già scelto NI
        THEN
            -- è una attività batch
            IF     p_cognome IS NULL
               AND p_nome IS NULL
               AND p_denominazione IS NOT NULL
            THEN
                d_pointer := INSTR (p_denominazione, '  ');

                IF d_pointer = 0
                THEN
                    v_cognome := RTRIM (p_denominazione);
                    v_nome := NULL;
                ELSE
                    v_cognome :=
                        RTRIM (SUBSTR (p_denominazione, 1, d_pointer - 1));
                    v_nome := RTRIM (SUBSTR (p_denominazione, d_pointer + 2));
                END IF;
            END IF;

            --         dbms_output.put_line('pkg ' || v_cognome );
            v_trovato_ni :=
                get_anagrafica_alternativa (p_ni,
                                            v_cognome,
                                            v_nome,
                                            p_partita_iva,
                                            p_codice_fiscale,
                                            p_competenza,
                                            v_id_anagrafica_utilizzare);
        -- se v_trovato_ni = -1 allora inserisco
        -- record chiuso logicamente
        -- non ci sono casi in cui non devo inserire se batch??
        --         IF  v_trovato_ni is null --(nvl(v_trovato_ni,-1) != -1 and get_ultimo_al (v_trovato_ni) IS NOT NULL
        --                 OR v_trovato_ni = -1
        --         THEN
        --            v_da_inserire := 'SI';
        --         END IF;
        --
        --         IF v_da_inserire = 'SI'
        --         THEN
        END IF;                                                -- se ho già NI

        IF v_trovato_ni = -1
        THEN
            v_al := (TRUNC (SYSDATE) + 1) - (1);
            v_stato_soggetto := 'C';
            v_id_anagrafica := NULL;
            v_trovato_ni := NULL;               -- non uso -1 che non ha senso
        ELSE                                        -- v_trovato è valorizzato
            v_stato_soggetto := p_stato_soggetto;
            v_id_anagrafica := NULL;
        -- uso ni trovato e il trigger chiuderà ni precedente
        -- oppure è nullo e verrà inserito record nuovo
        --               v_stato_soggetto := '';
        --               v_al := TO_DATE ('');
        -- uso ni trovato x il quale è già stato chiuso il periodo
        END IF;

        IF v_id_anagrafica_utilizzare IS NULL -- ritornato dal check se anagrafica esistente e NON da aggiornare.
        THEN
            -- AD  17/01/2018 modifica per default su tipo soggetto da chiamata da protocollo
            IF     d_tipo_soggetto IS NULL
               AND NVL (p_competenza, 'XXXXXXXXXX') != 'WS'
            THEN
                IF     v_nome IS NULL
                   AND (   p_partita_iva IS NOT NULL
                        OR p_partita_iva_cee IS NOT NULL)
                THEN   -- nome nullo e P.I. valorizzata  (soggetto giuridico?)
                    d_tipo_soggetto := 'E';
                ELSE
                    IF     v_nome IS NOT NULL
                       AND (   p_codice_fiscale IS NOT NULL
                            OR p_codice_fiscale_estero IS NOT NULL)
                    THEN    -- nome non null e CF valorizzato (persona fisica)
                        d_tipo_soggetto := 'I';
                    ELSE
                        d_tipo_soggetto := 'G';
                    END IF;
                END IF;
            END IF;

            BEGIN
                SELECT *
                  INTO v_old_anagrafe_soggetti
                  FROM anagrafe_soggetti
                 WHERE     ni = p_ni
                       AND SYSDATE BETWEEN dal
                                       AND NVL (al, TO_DATE ('3333333', 'j'))
                       AND al IS NULL;

                -- controllo se qualcosa è cambiato
                IF NOT (   NVL (p_COGNOME, '1') !=
                           NVL (v_old_anagrafe_soggetti.COGNOME, '1')
                        OR NVL (p_NOME, '1') !=
                           NVL (v_old_anagrafe_soggetti.NOME, '1')
                        OR NVL (p_SESSO, '1') !=
                           NVL (v_old_anagrafe_soggetti.SESSO, '1')
                        OR NVL (p_DATA_NAS, TO_DATE ('2222222', 'j')) !=
                           NVL (v_old_anagrafe_soggetti.DATA_NAS,
                                TO_DATE ('2222222', 'j'))
                        OR NVL (p_PROVINCIA_NAS, 1) !=
                           NVL (v_old_anagrafe_soggetti.PROVINCIA_NAS, 1)
                        OR NVL (p_COMUNE_NAS, 1) !=
                           NVL (v_old_anagrafe_soggetti.COMUNE_NAS, 1)
                        OR NVL (p_LUOGO_NAS, '1') !=
                           NVL (v_old_anagrafe_soggetti.LUOGO_NAS, '1')
                        OR NVL (p_CODICE_FISCALE, '1') !=
                           NVL (v_old_anagrafe_soggetti.CODICE_FISCALE, '1')
                        OR NVL (p_CODICE_FISCALE_ESTERO, '1') !=
                           NVL (
                               v_old_anagrafe_soggetti.CODICE_FISCALE_ESTERO,
                               '1')
                        OR NVL (p_PARTITA_IVA, '1') !=
                           NVL (v_old_anagrafe_soggetti.PARTITA_IVA, '1')
                        OR NVL (p_CITTADINANZA, '1') !=
                           NVL (v_old_anagrafe_soggetti.CITTADINANZA, '1')
                        OR NVL (p_GRUPPO_LING, '1') !=
                           NVL (v_old_anagrafe_soggetti.GRUPPO_LING, '1')
                        -- rev. 14 inizio
                        OR NVL (p_COMPETENZA, 'X') !=
                           NVL (v_old_anagrafe_soggetti.COMPETENZA, 'X')  --??
                        OR NVL (p_COMPETENZA_esclusiva, 'X') !=
                           NVL (v_old_anagrafe_soggetti.COMPETENZA_esclusiva,
                                'X')                                      --??
                        -- rev. 14 fine
                        OR NVL (p_NOTE_anag, '1') !=
                           NVL (v_old_anagrafe_soggetti.NOTE, '1'))
                THEN
                    v_cambiata_anagrafica := 0;
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    NULL;                                -- non esisteva prima
                    -- rev.14 inizio
                    -- non trovato periodo aperto considero che sia da inserire.
                    v_cambiata_anagrafica := 1;
            -- rev. 14 fine
            END;

            -- rev. 16 Inizio
            IF v_id_anagrafica_utilizzare IS NULL
            THEN
                -- non ho trovato anagrafica aperta
                v_cambiata_anagrafica := 1;
            END IF;

            -- rev. 16 Fine
            IF v_cambiata_anagrafica = 1
            THEN
                -- modificata chiamata con passaggio nominale
                v_id_anagrafica :=
                    anagrafici_tpk.ins (
                        P_ID_ANAGRAFICA           => NULL, --p_id_anagrafica           ,
                        P_NI                      => p_ni,
                        P_DAL                     => p_dal,
                        P_AL                      => p_al,
                        P_COGNOME                 => v_cognome,
                        P_NOME                    => v_nome,
                        p_sesso                   => p_sesso,
                        p_data_nas                => p_data_nas,
                        p_provincia_nas           => p_provincia_nas,
                        p_comune_nas              => p_comune_nas,
                        p_luogo_nas               => p_luogo_nas,
                        p_codice_fiscale          => p_codice_fiscale,
                        p_codice_fiscale_estero   => p_codice_fiscale_estero,
                        p_partita_iva             => p_partita_iva,
                        p_cittadinanza            => p_cittadinanza,
                        p_gruppo_ling             => p_gruppo_ling,
                        p_competenza              => p_competenza,
                        p_competenza_esclusiva    => p_competenza_esclusiva,
                        --                             p_tipo_soggetto           ,
                        -- AD  17/01/2018 modifica per default su tipo soggetto
                        P_TIPO_SOGGETTO           => d_tipo_soggetto,
                        P_STATO_CEE               => p_stato_cee,
                        p_partita_iva_cee         => p_partita_iva_cee,
                        P_FINE_VALIDITA           => p_fine_validita,
                        P_STATO_SOGGETTO          => p_stato_soggetto,
                        --      p_denominazione           ,
                        P_NOTE                    => p_note_anag,
                        p_version                 => NULL,
                        p_utente                  => p_utente,
                        p_data_agg                => p_data_agg      --      ,
                                                               --      p_batch =>      p_batch
                                                               );
            END IF;
        ELSE                         -- riutilizzo di una anagrafica esistente
            v_id_anagrafica := v_id_anagrafica_utilizzare;
        END IF;

        BEGIN
            v_new_ni := anagrafici_tpk.get_ni (v_id_anagrafica);
            v_new_dal := anagrafici_tpk.get_dal (v_id_anagrafica);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                v_new_ni := v_old_anagrafe_soggetti.ni;
                v_new_dal := v_old_anagrafe_soggetti.dal;

                SELECT id_anagrafica
                  INTO v_id_anagrafica
                  FROM anagrafici
                 WHERE     ni = p_ni
                       AND SYSDATE BETWEEN dal
                                       AND NVL (al, TO_DATE ('3333333', 'j'))
                       AND al IS NULL;
        END;

        -- insert in sedi x residenza
        IF     (   p_descrizione_residenza IS NOT NULL
                OR p_indirizzo_res IS NOT NULL
                OR p_provincia_res IS NOT NULL
                OR p_comune_res IS NOT NULL
                OR p_cap_res IS NOT NULL
                OR p_presso IS NOT NULL
                OR p_tel_res IS NOT NULL
                OR p_fax_res IS NOT NULL      -- ci sono contatti di residenza
                OR p_mail IS NOT NULL)
           AND                          -- cambiate informazioni per residenza
               (   NVL (p_INDIRIZZO_RES, '1') !=
                   NVL (v_old_anagrafe_soggetti.INDIRIZZO_RES, '1')
                OR NVL (p_PROVINCIA_RES, '1') !=
                   NVL (v_old_anagrafe_soggetti.PROVINCIA_RES, '1')
                OR NVL (p_COMUNE_RES, '1') !=
                   NVL (v_old_anagrafe_soggetti.COMUNE_RES, '1')
                OR NVL (p_CAP_RES, '1') !=
                   NVL (v_old_anagrafe_soggetti.CAP_RES, '1')
                OR NVL (p_PRESSO, '1') !=
                   NVL (v_old_anagrafe_soggetti.PRESSO, '1')
                OR NVL (p_mail, '1') !=
                   NVL (v_old_anagrafe_soggetti.INDIRIZZO_WEB, '1')
                OR NVL (p_TEL_RES, '1') !=
                   NVL (v_old_anagrafe_soggetti.TEL_RES, '1')
                OR NVL (p_FAX_RES, '1') !=
                   NVL (v_old_anagrafe_soggetti.FAX_RES, '1'))
        -- cambiato il recapito di residenza
        THEN
            IF     NVL (p_INDIRIZZO_RES, '1') =
                   NVL (v_old_anagrafe_soggetti.INDIRIZZO_RES, '1')
               AND NVL (p_PROVINCIA_RES, '1') =
                   NVL (v_old_anagrafe_soggetti.PROVINCIA_RES, '1')
               AND NVL (p_COMUNE_RES, '1') =
                   NVL (v_old_anagrafe_soggetti.COMUNE_RES, '1')
               AND NVL (p_CAP_RES, '1') =
                   NVL (v_old_anagrafe_soggetti.CAP_RES, '1')
               AND NVL (p_PRESSO, '1') =
                   NVL (v_old_anagrafe_soggetti.PRESSO, '1')
            THEN                          -- non cambiato il recapito ma altro
                BEGIN
                    SELECT id_recapito   -- verifica se esiste già il recapito
                      INTO d_id_recapito
                      FROM recapiti
                     WHERE     ni = v_old_anagrafe_soggetti.ni
                           AND al IS NULL
                           AND id_tipo_recapito = 1;               --residenza

                    v_creare_recapito := 0;                      -- se trovato
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        NULL;                   -- da inserire come da default
                END;
            END IF;

            IF v_creare_recapito = 1
            THEN
                d_id_recapito :=
                    recapiti_tpk.ins (
                        p_id_recapito            => NULL,
                        p_ni                     => v_new_ni,          --p_ni,
                        p_dal                    =>
                            GREATEST (
                                v_new_dal,
                                NVL (p_dal,
                                     TO_DATE ('01/01/1900', 'dd/mm/yyyy'))), --rev. 11
                        p_al                     => p_al,
                        p_descrizione            => p_descrizione_residenza,
                        p_id_tipo_recapito       => 1 -- RESIDENZA p_id_tipo_recapito
                                                     ,
                        p_indirizzo              => p_indirizzo_res,
                        p_provincia              => p_provincia_res,
                        p_comune                 => p_comune_res,
                        p_cap                    => p_cap_res,
                        p_presso                 => p_presso,
                        p_importanza             => p_importanza,
                        p_competenza             => p_competenza,
                        p_competenza_esclusiva   => p_competenza_esclusiva,
                        p_version                => '',           --p_version,
                        p_utente_aggiornamento   => p_utente,
                        p_data_aggiornamento     => p_data_agg);
            END IF;
        END IF;

        -- inserimento del contatto x residenza

        v_creare_recapito := 1;                      -- ricomincio i controlli

        IF ((   p_tel_res IS NOT NULL
             OR p_fax_res IS NOT NULL         -- ci sono contatti di residenza
             OR p_mail IS NOT NULL))
        THEN
            FOR cont IN 1 .. 3
            LOOP
                --1 = TELEFONO
                --2 = FAX
                --3 = MAIL
                d_contatto_valore := NULL;

                IF     CONT = 1
                   AND p_TEL_RES IS NOT NULL
                   AND NVL (p_TEL_RES, '1') !=
                       NVL (v_old_anagrafe_soggetti.TEL_RES, '1')
                THEN
                    d_contatto_valore := p_tel_res;
                    d_note := p_note_tel_res;
                    d_id_tipo_contatto := 1;
                ELSIF     cont = 2
                      AND p_fax_res IS NOT NULL
                      AND NVL (p_FAX_RES, '1') !=
                          NVL (v_old_anagrafe_soggetti.FAX_RES, '1')
                THEN
                    d_contatto_valore := p_fax_res;
                    d_note := p_note_fax_res;
                    d_id_tipo_contatto := 2;
                ELSIF     cont = 3
                      AND p_mail IS NOT NULL
                      AND upper(NVL (p_mail, '1')) !=
                          upper(NVL (v_old_anagrafe_soggetti.INDIRIZZO_WEB, '1')) -- rev. 33
                THEN
                    d_contatto_valore := p_mail;
                    d_note := p_note_mail;
                    d_id_tipo_contatto := 3;
                END IF;

                IF d_contatto_valore IS NOT NULL
                THEN
                    IF NVL (tipi_contatto_tpk.get_unico (d_id_tipo_contatto),
                            'NO') =
                       'SI'                                       --tipo UNICO
                    THEN
                        BEGIN
                           integritypackage.LOG ('data ' || v_new_dal);

                            SELECT c.*
                              INTO v_old_contatto
                              FROM contatti c
                             WHERE     id_recapito = d_id_recapito
                                   AND al IS NULL
                                   AND id_tipo_contatto = d_id_tipo_contatto
                                   AND NOT EXISTS
                                           (SELECT 1 -- ma a patto che non esista un record con stesso valore di contatto
                                              FROM contatti cont2
                                             WHERE     cont2.id_recapito =
                                                       d_id_recapito
                                                   AND al IS NULL
                                                   AND id_tipo_contatto =
                                                       d_id_tipo_contatto
                                                   AND upper(valore) = -- rev. 33
                                                       upper(d_contatto_valore));

                            integritypackage.LOG (
                                'aggiorno ' || v_old_contatto.id_contatto);
                            d_id_contatto := v_old_contatto.id_contatto;
                            -- aggiorno
                            integritypackage.LOG (
                                'date ' || p_dal || ':' || v_old_contatto.dal);

                            IF p_dal = v_old_contatto.dal
                            THEN
                                contatti_tpk.upd (
                                    p_new_id_contatto            => d_id_contatto,
                                    p_new_id_recapito            => d_id_recapito,
                                    p_new_dal                    => v_old_contatto.dal,
                                    p_new_al                     => p_al,
                                    p_new_valore                 => d_contatto_valore,
                                    p_new_id_tipo_contatto       =>
                                        d_id_tipo_contatto,
                                    p_new_note                   => d_note,
                                    p_new_competenza             => p_competenza,
                                    p_new_competenza_esclusiva   =>
                                        p_competenza_esclusiva,
                                    p_new_version                => '', --p_version,
                                    p_new_utente_aggiornamento   => p_utente,
                                    p_new_data_aggiornamento     => p_data_agg);
                            ELSE
                                --                     chiudo il precedente
                                contatti_tpk.upd (
                                    p_new_id_contatto            =>
                                        v_old_contatto.id_contatto,
                                    p_new_id_recapito            =>
                                        v_old_contatto.id_recapito,
                                    p_new_dal                    => v_old_contatto.dal,
                                    p_new_al                     => p_dal - 1,
                                    p_new_valore                 => v_old_contatto.valore,
                                    p_new_id_tipo_contatto       =>
                                        v_old_contatto.id_tipo_contatto,
                                    p_new_note                   => v_old_contatto.note,
                                    p_new_competenza             => p_competenza,
                                    p_new_competenza_esclusiva   =>
                                        p_competenza_esclusiva,
                                    p_new_version                => '', --p_version,
                                    p_new_utente_aggiornamento   => p_utente,
                                    p_new_data_aggiornamento     => SYSDATE);
                                RAISE NO_DATA_FOUND;              -- inserisco
                            END IF;
                        EXCEPTION
                            WHEN NO_DATA_FOUND
                            THEN                                 -- non esiste
                                NULL;
                                d_id_contatto :=
                                    contatti_tpk.ins (
                                        p_id_contatto            => '',
                                        p_id_recapito            => d_id_recapito,
                                        p_dal                    =>
                                            GREATEST (
                                                v_new_dal,
                                                NVL (
                                                    p_dal,
                                                    TO_DATE ('01/01/1900',
                                                             'dd/mm/yyyy'))), --rev. 11
                                        p_al                     => p_al,
                                        p_valore                 => d_contatto_valore,
                                        p_id_tipo_contatto       =>
                                            d_id_tipo_contatto,
                                        p_note                   => d_note,
                                        p_competenza             => p_competenza,
                                        p_competenza_esclusiva   =>
                                            p_competenza_esclusiva,
                                        p_version                => '', --p_version,
                                        p_utente_aggiornamento   => p_utente,
                                        p_data_aggiornamento     => p_data_agg);
                        END;
                    ELSE                                     -- non tipo unico
                    -- rev. 28 inizio
                    declare
                    v_esiste_gia number := 0;
                    begin
                    -- controllo che non esista già
                            SELECT count(*)
                              INTO v_esiste_gia
                              FROM contatti c
                             WHERE     id_recapito = d_id_recapito
                                   AND sysdate between dal and nvl(al,sysdate+1)
                                   AND id_tipo_contatto = d_id_tipo_contatto
                                   AND valore =  d_contatto_valore;
                        if v_esiste_gia = 0 then
                        d_id_contatto :=
                            contatti_tpk.ins (
                                p_id_contatto            => '',
                                p_id_recapito            => d_id_recapito,
                                p_dal                    =>
                                    GREATEST (
                                        v_new_dal,
                                        NVL (
                                            p_dal,
                                            TO_DATE ('01/01/1900',
                                                     'dd/mm/yyyy'))), --rev. 11
                                p_al                     => p_al,
                                p_valore                 => d_contatto_valore,
                                p_id_tipo_contatto       => d_id_tipo_contatto,
                                p_note                   => d_note,
                                p_competenza             => p_competenza,
                                p_competenza_esclusiva   =>
                                    p_competenza_esclusiva,
                                p_version                => '',   --p_version,
                                p_utente_aggiornamento   => p_utente,
                                p_data_aggiornamento     => p_data_agg);
                        end if;
                      end; -- rev. 28 fine
                    END IF;
                END IF;
            END LOOP;
        END IF;

        -- insert in sedi x domicilio
        IF     (   p_descrizione_dom IS NOT NULL
                OR p_indirizzo_dom IS NOT NULL
                OR p_provincia_dom IS NOT NULL
                OR p_comune_dom IS NOT NULL
                OR p_cap_dom IS NOT NULL
                OR p_tel_dom IS NOT NULL
                OR p_fax_dom IS NOT NULL)     -- ci sono contatti di domicilio
           AND                          -- cambiate informazioni per domicilio
               (   NVL (p_INDIRIZZO_DOM, '1') !=
                   NVL (v_old_anagrafe_soggetti.INDIRIZZO_DOM, '1')
                OR NVL (p_PROVINCIA_DOM, '1') !=
                   NVL (v_old_anagrafe_soggetti.PROVINCIA_DOM, '1')
                OR NVL (p_COMUNE_DOM, '1') !=
                   NVL (v_old_anagrafe_soggetti.COMUNE_DOM, '1')
                OR NVL (p_CAP_DOM, '1') !=
                   NVL (v_old_anagrafe_soggetti.CAP_DOM, '1')
                OR NVL (p_PRESSO, '1') !=
                   NVL (v_old_anagrafe_soggetti.PRESSO, '1')
                OR NVL (p_TEL_DOM, '1') !=
                   NVL (v_old_anagrafe_soggetti.TEL_DOM, '1')
                OR NVL (p_FAX_DOM, '1') !=
                   NVL (v_old_anagrafe_soggetti.FAX_DOM, '1'))
        THEN
            IF     NVL (p_INDIRIZZO_DOM, '1') =
                   NVL (v_old_anagrafe_soggetti.INDIRIZZO_DOM, '1')
               AND NVL (p_PROVINCIA_DOM, '1') =
                   NVL (v_old_anagrafe_soggetti.PROVINCIA_DOM, '1')
               AND NVL (p_COMUNE_DOM, '1') =
                   NVL (v_old_anagrafe_soggetti.COMUNE_DOM, '1')
               AND NVL (p_CAP_DOM, '1') =
                   NVL (v_old_anagrafe_soggetti.CAP_DOM, '1')
               AND NVL (p_PRESSO, '1') =
                   NVL (v_old_anagrafe_soggetti.PRESSO, '1')
            THEN                          -- non cambiato il recapito ma altro
                BEGIN
                    integritypackage.LOG (
                           'cercato id_recapito ni='
                        || v_old_anagrafe_soggetti.ni
                        || ' trovato:'
                        || d_id_recapito);

                    SELECT id_recapito   -- verifica se esiste già il recapito
                      INTO d_id_recapito
                      FROM recapiti
                     WHERE     ni = v_old_anagrafe_soggetti.ni
                           AND al IS NULL
                           AND id_tipo_recapito = 2;               --domicilio

                    v_creare_recapito := 0;                      -- se trovato

                    integritypackage.LOG ('trovato id_recapito');
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        NULL;                   -- da inserire come da default
                END;
            END IF;

            IF v_creare_recapito = 1
            THEN
                integritypackage.LOG ('inserire recapito');
                d_id_recapito :=
                    recapiti_tpk.ins (
                        p_id_recapito            => NULL,
                        p_ni                     => v_new_ni,          --p_ni,
                        p_dal                    =>
                            GREATEST (
                                v_new_dal,
                                NVL (p_dal,
                                     TO_DATE ('01/01/1900', 'dd/mm/yyyy'))), --rev. 11
                        p_al                     => p_al,
                        p_descrizione            => '',       --p_descrizione,
                        p_id_tipo_recapito       => 2 -- domIDENZA p_id_tipo_recapito
                                                     ,
                        p_indirizzo              => p_indirizzo_dom,
                        p_provincia              => p_provincia_dom,
                        p_comune                 => p_comune_dom,
                        p_cap                    => p_cap_dom,
                        p_presso                 => p_presso,
                        p_importanza             => p_importanza,
                        p_competenza             => p_competenza,
                        p_competenza_esclusiva   => p_competenza_esclusiva,
                        p_version                => '',           --p_version,
                        p_utente_aggiornamento   => p_utente,
                        p_data_aggiornamento     => p_data_agg);
            END IF;
        END IF;

        -- inserimento del contatto x domidenza
        IF p_tel_dom IS NOT NULL OR p_fax_dom IS NOT NULL -- ci sono contatti di domicilio
        THEN
            FOR cont IN 1 .. 2
            LOOP
                --1 = TELEFONO
                --2 = FAX

                d_contatto_valore := NULL;

                IF     CONT = 1
                   AND p_TEL_dom IS NOT NULL
                   AND NVL (p_TEL_DOM, '-1') !=
                       NVL (v_old_anagrafe_soggetti.TEL_DOM, '-1')
                THEN
                    d_contatto_valore := p_tel_dom;
                    d_note := p_note_tel_dom;
                    d_id_tipo_contatto := 1;
                ELSIF     cont = 2
                      AND p_fax_dom IS NOT NULL
                      AND NVL (p_FAX_DOM, '-1') !=
                          NVL (v_old_anagrafe_soggetti.FAX_DOM, '-1')
                THEN
                    d_contatto_valore := p_fax_dom;
                    d_note := p_note_fax_dom;
                    d_id_tipo_contatto := 2;
                END IF;

                IF d_contatto_valore IS NOT NULL
                THEN
                    IF NVL (tipi_contatto_tpk.get_unico (d_id_tipo_contatto),
                            'NO') =
                       'SI'                                       --tipo UNICO
                    THEN
                        BEGIN
                            integritypackage.LOG ('data ' || v_new_dal);
                            integritypackage.LOG ('cerco ' || d_id_recapito);
                            integritypackage.LOG (
                                   'tipo contatto '
                                || d_id_tipo_contatto
                                || ' valore:'
                                || d_contatto_valore);

                            SELECT c.*
                              INTO v_old_contatto
                              FROM contatti c
                             WHERE     id_recapito = d_id_recapito
                                   AND al IS NULL
                                   AND id_tipo_contatto = d_id_tipo_contatto
                                   AND NOT EXISTS
                                           (SELECT 1 -- ma a patto che non esista un record con stesso valore di contatto
                                              FROM contatti cont2
                                             WHERE     cont2.id_recapito =
                                                       d_id_recapito
                                                   AND al IS NULL
                                                   AND id_tipo_contatto =
                                                       d_id_tipo_contatto
                                                   AND valore =
                                                       d_contatto_valore);

                            integritypackage.LOG (
                                'aggiorno ' || v_old_contatto.id_contatto);
                            d_id_contatto := v_old_contatto.id_contatto;
                            -- aggiorno
                            integritypackage.LOG (
                                'date ' || p_dal || ':' || v_old_contatto.dal);

                            IF p_dal = v_old_contatto.dal
                            THEN
                                contatti_tpk.upd (
                                    p_new_id_contatto            => d_id_contatto,
                                    p_new_id_recapito            => d_id_recapito,
                                    p_new_dal                    => v_old_contatto.dal,
                                    p_new_al                     => p_al,
                                    p_new_valore                 => d_contatto_valore,
                                    p_new_id_tipo_contatto       =>
                                        d_id_tipo_contatto,
                                    p_new_note                   => d_note,
                                    p_new_competenza             => p_competenza,
                                    p_new_competenza_esclusiva   =>
                                        p_competenza_esclusiva,
                                    p_new_version                => '', --p_version,
                                    p_new_utente_aggiornamento   => p_utente,
                                    p_new_data_aggiornamento     => p_data_agg);
                            ELSE
                                --                     chiudo il precedente
                                contatti_tpk.upd (
                                    p_new_id_contatto            =>
                                        v_old_contatto.id_contatto,
                                    p_new_id_recapito            =>
                                        v_old_contatto.id_recapito,
                                    p_new_dal                    => v_old_contatto.dal,
                                    p_new_al                     => p_dal - 1,
                                    p_new_valore                 => v_old_contatto.valore,
                                    p_new_id_tipo_contatto       =>
                                        v_old_contatto.id_tipo_contatto,
                                    p_new_note                   => v_old_contatto.note,
                                    p_new_competenza             => p_competenza,
                                    p_new_competenza_esclusiva   =>
                                        p_competenza_esclusiva,
                                    p_new_version                => '', --p_version,
                                    p_new_utente_aggiornamento   => p_utente,
                                    p_new_data_aggiornamento     => SYSDATE);
                                RAISE NO_DATA_FOUND;              -- inserisco
                            END IF;
                        EXCEPTION
                            WHEN NO_DATA_FOUND
                            THEN                                 -- non esiste
                                NULL;
                                d_id_contatto :=
                                    contatti_tpk.ins (
                                        p_id_contatto            => '',
                                        p_id_recapito            => d_id_recapito,
                                        p_dal                    =>
                                            GREATEST (
                                                v_new_dal,
                                                NVL (
                                                    p_dal,
                                                    TO_DATE ('01/01/1900',
                                                             'dd/mm/yyyy'))), --rev. 11
                                        p_al                     => p_al,
                                        p_valore                 => d_contatto_valore,
                                        p_id_tipo_contatto       =>
                                            d_id_tipo_contatto,
                                        p_note                   => d_note,
                                        p_competenza             => p_competenza,
                                        p_competenza_esclusiva   =>
                                            p_competenza_esclusiva,
                                        p_version                => '', --p_version,
                                        p_utente_aggiornamento   => p_utente,
                                        p_data_aggiornamento     => p_data_agg);
                        END;
                    ELSE                                     -- non tipo unico
                      -- rev. 37
                       DECLARE
                       v_num_contatti               NUMBER;
                       BEGIN
                            SELECT count(*)
                              INTO v_num_contatti
                              FROM contatti c
                             WHERE     id_recapito = d_id_recapito
                                   AND sysdate between dal and nvl(al,sysdate+1)
                                   AND id_tipo_contatto = d_id_tipo_contatto
                                   AND valore = d_contatto_valore;
                        if v_num_contatti = 0 then -- rev. 37 fine
                        d_id_contatto :=
                            contatti_tpk.ins (
                                p_id_contatto            => '',
                                p_id_recapito            => d_id_recapito,
                                p_dal                    =>
                                    GREATEST (
                                        v_new_dal,
                                        NVL (
                                            p_dal,
                                            TO_DATE ('01/01/1900',
                                                     'dd/mm/yyyy'))), --rev. 11
                                p_al                     => p_al,
                                p_valore                 => d_contatto_valore,
                                p_id_tipo_contatto       => d_id_tipo_contatto,
                                p_note                   => d_note,
                                p_competenza             => p_competenza,
                                p_competenza_esclusiva   =>
                                    p_competenza_esclusiva,
                                p_version                => '',   --p_version,
                                p_utente_aggiornamento   => p_utente,
                                p_data_aggiornamento     => p_data_agg);
                           end if;
                        END;
                    END IF;
                END IF;
            END LOOP;
        END IF;

        anagrafici_pkg.v_aggiornamento_da_package_on := 0;

        INSERT INTO ALLINEA_ANAG_SOGGETTI_TAB tab
            SELECT v_new_ni
              FROM DUAL
             WHERE NOT EXISTS
                       (SELECT 1
                          FROM ALLINEA_ANAG_SOGGETTI_TAB
                         WHERE ni = v_new_ni);

        ALLINEA_ANAG_SOGGETTI_TABLE (v_new_ni);
        RETURN v_id_anagrafica;
    EXCEPTION
        WHEN OTHERS
        THEN
            anagrafici_pkg.v_aggiornamento_da_package_on := 0;
            RAISE;
    END;

    FUNCTION ins_anag_dom_e_res_e_mail_desc (
        -- dati anagrafica
        --      p_id_anagrafica           IN ANAGRAFICI.id_anagrafica%TYPE DEFAULT NULL,
        p_ni                      IN ANAGRAFICI.ni%TYPE DEFAULT NULL,
        p_dal                     IN ANAGRAFICI.dal%TYPE,
        p_al                      IN ANAGRAFICI.al%TYPE DEFAULT NULL,
        p_cognome                 IN ANAGRAFICI.cognome%TYPE,
        p_nome                    IN ANAGRAFICI.nome%TYPE DEFAULT NULL,
        p_sesso                   IN ANAGRAFICI.sesso%TYPE DEFAULT NULL,
        p_data_nas                IN ANAGRAFICI.data_nas%TYPE DEFAULT NULL,
        p_provincia_nas           IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL,
        p_comune_nas              IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL,
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
        p_descrizione_residenza   IN RECAPITI.descrizione%TYPE DEFAULT NULL --p_descrizione
                                                                           --    , p_id_tipo_recapito  in RECAPITI.id_tipo_recapito%type
                                                                           ,
        p_indirizzo_res           IN RECAPITI.indirizzo%TYPE DEFAULT NULL,
        p_provincia_res           IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL,
        p_comune_res              IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL,
        p_cap_res                 IN RECAPITI.cap%TYPE DEFAULT NULL,
        p_presso                  IN RECAPITI.presso%TYPE DEFAULT NULL,
        p_importanza              IN RECAPITI.importanza%TYPE DEFAULT NULL ---- mail
                                                                          ,
        p_mail                    IN CONTATTI.valore%TYPE DEFAULT NULL -- p_valore
                                                                      --    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
                                                                      ,
        p_note_mail               IN CONTATTI.note%TYPE DEFAULT NULL,
        p_importanza_mail         IN CONTATTI.importanza%TYPE DEFAULT NULL ---- tel res
                                                                          ,
        p_tel_res                 IN CONTATTI.valore%TYPE DEFAULT NULL -- p_valore
                                                                      --    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
                                                                      ,
        p_note_tel_res            IN CONTATTI.note%TYPE DEFAULT NULL,
        p_importanza_tel_res      IN CONTATTI.importanza%TYPE DEFAULT NULL ---- fax res
                                                                          ,
        p_fax_res                 IN CONTATTI.valore%TYPE DEFAULT NULL -- p_valore
                                                                      --    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
                                                                      ,
        p_note_fax_res            IN CONTATTI.note%TYPE DEFAULT NULL,
        p_importanza_fax_res      IN CONTATTI.importanza%TYPE DEFAULT NULL -- dati DOMICILIO
                                                                          ,
        p_descrizione_dom         IN RECAPITI.descrizione%TYPE DEFAULT NULL --p_descrizione
                                                                           ,
        p_indirizzo_dom           IN RECAPITI.indirizzo%TYPE DEFAULT NULL,
        p_provincia_dom           IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL,
        p_comune_dom              IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL,
        p_cap_dom                 IN RECAPITI.cap%TYPE DEFAULT NULL ---- tel dom
                                                                   ,
        p_tel_dom                 IN CONTATTI.valore%TYPE DEFAULT NULL -- p_valore
                                                                      --    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
                                                                      ,
        p_note_tel_dom            IN CONTATTI.note%TYPE DEFAULT NULL,
        p_importanza_tel_dom      IN CONTATTI.importanza%TYPE DEFAULT NULL ---- fax dom
                                                                          ,
        p_fax_dom                 IN CONTATTI.valore%TYPE DEFAULT NULL -- p_valore
                                                                      --    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
                                                                      ,
        p_note_fax_dom            IN CONTATTI.note%TYPE DEFAULT NULL ---- dati generici
                                                                    ,
        p_utente                  IN ANAGRAFICI.utente%TYPE DEFAULT NULL,
        p_data_agg                IN ANAGRAFICI.data_agg%TYPE DEFAULT SYSDATE,
        p_batch                      NUMBER DEFAULT 0         -- 0 = NON batch
                                                     )
        RETURN NUMBER
    IS
        /******************************************************************************
        NOME:        ins_anag_dom_e_res_e_mail_desc.
        DESCRIZIONE: inserisce da record piatto.
        ARGOMENTI:
        NOTE:
        REVISIONI:
        Rev. Data       Autore Descrizione
        ---- ---------- ------ ------------------------------------------------------
       ******************************************************************************/
        --      v_id_anagrafica anagrafici.id_anagrafica%TYPE;
        --      v_new_ni anagrafici.ni%TYPE;
        --      v_new_dal date;
        --      d_id_recapito        recapiti.id_recapito%TYPE;
        --      d_id_contatto        CONTATTI.id_recapito%TYPE;
        --      d_contatto_valore    contatti.valore%TYPE;
        --      d_note               contatti.note%TYPE;
        --      d_id_tipo_contatto   tipi_contatto.id_tipo_contatto%TYPE;
        v_provincia_nas   AD4_PROVINCE.sigla%TYPE;
        v_comune_nas      AD4_COMUNI.denominazione%TYPE;
        v_provincia_res   AD4_PROVINCE.sigla%TYPE;
        v_comune_res      AD4_COMUNI.denominazione%TYPE;
        v_provincia_dom   AD4_PROVINCE.sigla%TYPE;
        v_comune_dom      AD4_COMUNI.denominazione%TYPE;
    --      v_trovato_ni       NUMBER;
    --      v_da_inserire      VARCHAR2 (2) := 'NO';
    --      v_ni               ANAGRAFICI.ni%TYPE;
    --      v_al               DATE;
    --      v_stato_soggetto   anagrafici.stato_soggetto%TYPE;
    --     v_id_anagrafica_utilizzare  varchar2(2);
    --     v_tipo_soggetto ANAGRAFICI.tipo_soggetto%TYPE := nvl(p_tipo_soggetto,'I');
    -- previsto default x insert partendo dalla SOGGETTI (giusto?????????????)
    BEGIN
        IF p_provincia_nas IS NOT NULL
        THEN
            v_provincia_nas :=
                ad4_provincia.get_provincia (NULL,            -- denominazione
                                                   p_provincia_nas);  -- sigla
        END IF;

        IF p_comune_nas IS NOT NULL
        THEN
            v_comune_nas := AD4_comune.GET_COMUNE (p_comune_nas, NULL, 0); -- lo voglio attivo
        END IF;

        IF p_provincia_res IS NOT NULL
        THEN
            v_provincia_res :=
                ad4_provincia.get_provincia (NULL,            -- denominazione
                                                   p_provincia_res);  -- sigla
        END IF;

        IF p_comune_res IS NOT NULL
        THEN
            v_comune_res := AD4_comune.GET_COMUNE (p_comune_res, NULL, 0); -- lo voglio attivo
        END IF;

        IF p_provincia_dom IS NOT NULL
        THEN
            v_provincia_dom :=
                ad4_provincia.get_provincia (NULL,            -- denominazione
                                                   p_provincia_dom);  -- sigla
        END IF;

        IF p_comune_dom IS NOT NULL
        THEN
            v_comune_dom := AD4_comune.GET_COMUNE (p_comune_dom, NULL, 0); -- lo voglio attivo
        END IF;

        RETURN ins_anag_dom_e_res_e_mail (p_ni,
                                          p_dal,
                                          p_al,
                                          p_cognome,
                                          p_nome,
                                          p_sesso,
                                          p_data_nas,
                                          v_provincia_nas,
                                          v_comune_nas,
                                          p_luogo_nas,
                                          p_codice_fiscale,
                                          p_codice_fiscale_estero,
                                          p_partita_iva,
                                          p_cittadinanza,
                                          p_gruppo_ling,
                                          p_competenza,
                                          p_competenza_esclusiva,
                                          p_tipo_soggetto,
                                          p_denominazione,
                                          p_stato_cee,
                                          p_partita_iva_cee,
                                          p_fine_validita,
                                          p_stato_soggetto,
                                          p_note_anag,
                                          p_descrizione_residenza,
                                          p_indirizzo_res,
                                          v_provincia_res,
                                          v_comune_res,
                                          p_cap_res,
                                          p_presso,
                                          p_importanza,
                                          p_mail,
                                          p_note_mail,
                                          p_importanza_mail,
                                          p_tel_res,
                                          p_note_tel_res,
                                          p_importanza_tel_res,
                                          p_fax_res,
                                          p_note_fax_res,
                                          p_importanza_fax_res,
                                          p_descrizione_dom,
                                          p_indirizzo_dom,
                                          v_provincia_dom,
                                          v_comune_dom,
                                          p_cap_dom,
                                          p_tel_dom,
                                          p_note_tel_dom,
                                          p_importanza_tel_dom,
                                          p_fax_dom,
                                          p_note_fax_dom,
                                          p_utente,
                                          p_data_agg,
                                          p_batch);
    --      -- test x verificare se ci sono soggetti in "conflitto"
    --      -- però la prima volta avevamo parlato di tornare un ref- cursor mentre la
    --      -- seconda un ni... ci devo pensare
    --      -- idea al lancio è di provare ad inserire
    --      -- se Ok torno NI
    --      -- se ci sono "ambigui" ritorno codice di errore.
    --
    --
    --      IF NVL (p_batch, 0) != 0 and p_ni is null -- non ho già scelto NI
    --      THEN
    --         -- è una attività batch
    --         v_trovato_ni :=
    --            get_anagrafica_alternativa (p_ni,
    --                                        p_cognome,
    --                                        p_nome,
    --                                        p_partita_iva,
    --                                        p_codice_fiscale,
    --                                        p_competenza,
    --                                        v_id_anagrafica_utilizzare);
    --
    --         -- se v_trovato_ni = -1 allora inserisco
    --         -- record chiuso logicamente
    --         -- non ci sono casi in cui non devo inserire se batch??
    ----         IF  v_trovato_ni is null --(nvl(v_trovato_ni,-1) != -1 and get_ultimo_al (v_trovato_ni) IS NOT NULL
    ----                 OR v_trovato_ni = -1
    ----         THEN
    ----            v_da_inserire := 'SI';
    ----         END IF;
    ----
    ----         IF v_da_inserire = 'SI'
    ----         THEN
    --      END IF; -- se ho già NI
    --            IF v_trovato_ni = -1
    --            THEN
    --               v_al := (TRUNC (SYSDATE) + 1) - (1 );
    --               v_stato_soggetto := 'C';
    --               v_id_anagrafica := NULL;
    --               v_trovato_ni := null; -- non uso -1 che non ha senso
    --            ELSE                                    -- v_trovato è valorizzato
    --            v_stato_soggetto := p_stato_soggetto;
    --               v_id_anagrafica := NULL;
    --               -- uso ni trovato e il trigger chiuderà ni precedente
    --               -- oppure è nullo e verrà inserito record nuovo
    ----               v_stato_soggetto := '';
    ----               v_al := TO_DATE ('');
    --            -- uso ni trovato x il quale è già stato chiuso il periodo
    --            END IF;
    --
    --            if v_id_anagrafica_utilizzare is null -- ritornato dal check se anagrafica esistente e NON da aggiornare.
    --            then
    --            v_id_anagrafica := anagrafici_pkg.ins (
    --                              null, --p_id_anagrafica           ,
    --                              null, --p_ni                      ,
    --                              p_dal                     ,
    --                              p_al                      ,
    --                              p_cognome                 ,
    --                              p_nome                    ,
    --                              p_sesso                   ,
    --                              p_data_nas                ,
    --                              v_provincia_nas           ,
    --                              v_comune_nas,
    --                              p_luogo_nas               ,
    --                              p_codice_fiscale          ,
    --                              p_codice_fiscale_estero   ,
    --                              p_partita_iva             ,
    --                              p_cittadinanza            ,
    --                              p_gruppo_ling             ,
    --                              p_competenza              ,
    --                              p_competenza_esclusiva    ,
    --                              p_tipo_soggetto           ,
    --                              p_stato_cee               ,
    --                              p_partita_iva_cee         ,
    --                              p_fine_validita           ,
    --                              p_stato_soggetto          ,
    --                        --      p_denominazione           ,
    --                              p_note_anag               ,
    --                              p_version =>null          ,
    --                              p_utente  => p_utente     ,
    --                              p_data_agg => p_data_agg
    --                        --      ,
    --                        --      p_batch =>      p_batch
    --                              );
    --         else -- riutilizzo di una anagrafica esistente
    --         v_id_anagrafica := v_id_anagrafica_utilizzare;
    --         end if;
    --
    --
    --      v_new_ni := anagrafici_tpk.get_ni(v_id_anagrafica);
    --      v_new_dal := anagrafici_tpk.get_dal(v_id_anagrafica);
    --
    --      -- insert in sedi x residenza
    --      IF   p_descrizione_residenza IS NOT NULL
    --         OR p_indirizzo_res IS NOT NULL
    --         OR p_provincia_res IS NOT NULL
    --         OR p_comune_res IS NOT NULL
    --         OR p_cap_res IS NOT NULL
    --         OR p_presso IS NOT NULL
    --         OR p_tel_res IS NOT NULL
    --         OR p_fax_res IS NOT NULL          -- ci sono contatti di residenza
    --         OR p_mail IS NOT NULL
    --      THEN
    --         d_id_recapito :=
    --            recapiti_tpk.ins (
    --               p_id_recapito                => NULL,
    --               p_ni                       => v_new_ni, --p_ni,
    --               p_dal => v_new_dal, --p_dal,
    --               p_al => p_al,
    --               p_descrizione            => '',--p_descrizione,
    --               p_id_tipo_recapito           => 1    -- RESIDENZA p_id_tipo_recapito
    --                                            ,
    --               p_indirizzo              => p_indirizzo_res,
    --               p_provincia              => v_provincia_res,
    --               p_comune                 => v_comune_res,
    --               p_cap                    => p_cap_res,
    --               p_presso                 => p_presso,
    --               p_competenza             => p_competenza,
    --               p_competenza_esclusiva   => p_competenza_esclusiva,
    --               p_version                => '',--p_version,
    --               p_utente_aggiornamento   => p_utente,
    --               p_data_aggiornamento     => p_data_agg);
    --
    --         -- inserimento del contatto x residenza
    --         IF    p_tel_res IS NOT NULL
    --            OR p_fax_res IS NOT NULL       -- ci sono contatti di residenza
    --            OR p_mail IS NOT NULL
    --         THEN
    --            FOR cont IN 1 .. 3
    --            LOOP
    --               --1 = TELEFONO
    --               --2 = FAX
    --               --3 = MAIL
    --               d_contatto_valore := null;
    --               IF CONT = 1 AND p_TEL_RES IS NOT NULL
    --               THEN
    --                  d_contatto_valore := p_tel_res;
    --                  d_note := p_note_tel_res;
    --                  d_id_tipo_contatto := 1;
    --               ELSIF cont = 2 AND p_fax_res IS NOT NULL
    --               THEN
    --                  d_contatto_valore := p_fax_res;
    --                  d_note := p_note_fax_res;
    --                  d_id_tipo_contatto := 2;
    --               ELSIF cont = 3 AND p_mail IS NOT NULL
    --               THEN
    --                  d_contatto_valore := p_mail;
    --                  d_note := p_note_mail;
    --                  d_id_tipo_contatto := 3;
    --               END IF;
    --
    --               IF d_contatto_valore IS NOT NULL
    --               THEN
    --                  d_id_contatto :=
    --                     contatti_tpk.ins (
    --                        p_id_contatto => '',
    --                        p_id_recapito            => d_id_recapito,
    --                        p_dal =>v_new_dal,  --p_dal,
    --                        p_al => p_al,
    --                        p_valore                 => d_contatto_valore,
    --                        p_id_tipo_contatto       => d_id_tipo_contatto,
    --                        p_note                   => d_note,
    --                        p_competenza             => p_competenza,
    --                        p_competenza_esclusiva   => p_competenza_esclusiva,
    --                        p_version                => '',--p_version,
    --                        p_utente_aggiornamento   => p_utente,
    --                        p_data_aggiornamento     => p_data_agg);
    --               END IF;
    --            END LOOP;
    --         END IF;
    --
    --      END IF;
    --
    --       -- insert in sedi x domicilio
    --      IF   p_descrizione_dom IS NOT NULL
    --         OR p_indirizzo_dom IS NOT NULL
    --         OR p_provincia_dom IS NOT NULL
    --         OR p_comune_dom IS NOT NULL
    --         OR p_cap_dom IS NOT NULL
    --         OR p_tel_dom IS NOT NULL
    --         OR p_fax_dom IS NOT NULL          -- ci sono contatti di domicilio
    --      THEN
    --         d_id_recapito :=
    --            recapiti_tpk.ins (
    --               p_id_recapito                => NULL,
    --               p_ni                       => v_new_ni, --p_ni,
    --               p_dal => v_new_dal, --p_dal,
    --               p_al => p_al,
    --               p_descrizione            => '',--p_descrizione,
    --               p_id_tipo_recapito           => 2    -- domIDENZA p_id_tipo_recapito
    --                                            ,
    --               p_indirizzo              => p_indirizzo_dom,
    --               p_provincia              => ad4_provincia.get_provincia(null, -- denominazione
    --                                                               v_provincia_dom ),
    --               p_comune                 => AD4_comune.GET_COMUNE( v_comune_dom, null, 0),
    --               p_cap                    => p_cap_dom,
    --               p_competenza             => p_competenza,
    --               p_competenza_esclusiva   => p_competenza_esclusiva,
    --               p_version                => '',--p_version,
    --               p_utente_aggiornamento   => p_utente,
    --               p_data_aggiornamento     => p_data_agg);
    --
    --         -- inserimento del contatto x domidenza
    --         IF    p_tel_dom IS NOT NULL
    --            OR p_fax_dom IS NOT NULL       -- ci sono contatti di domicilio
    --         THEN
    --            FOR cont IN 1 .. 3
    --            LOOP
    --               --1 = TELEFONO
    --               --2 = FAX
    --               --3 = MAIL
    --               d_contatto_valore := null;
    --               IF CONT = 1 AND p_TEL_dom IS NOT NULL
    --               THEN
    --                  d_contatto_valore := p_tel_dom;
    --                  d_note := p_note_tel_dom;
    --                  d_id_tipo_contatto := 1;
    --               ELSIF cont = 2 AND p_fax_dom IS NOT NULL
    --               THEN
    --                  d_contatto_valore := p_fax_dom;
    --                  d_note := p_note_fax_dom;
    --                  d_id_tipo_contatto := 2;
    --               END IF;
    --
    --               IF d_contatto_valore IS NOT NULL
    --               THEN
    --                  d_id_contatto :=
    --                     contatti_tpk.ins (
    --                        p_id_contatto => '',
    --                        p_id_recapito            => d_id_recapito,
    --                        p_dal => v_new_dal,  --p_dal,
    --                        p_al => p_al,
    --                        p_valore                 => d_contatto_valore,
    --                        p_id_tipo_contatto       => d_id_tipo_contatto,
    --                        p_note                   => d_note,
    --                        p_competenza             => p_competenza,
    --                        p_competenza_esclusiva   => p_competenza_esclusiva,
    --                        p_version                => '',--p_version,
    --                        p_utente_aggiornamento   => p_utente,
    --                        p_data_aggiornamento     => p_data_agg);
    --               END IF;
    --            END LOOP;
    --         END IF;
    --
    --      END IF;
    --
    --
    --      return v_id_anagrafica;
    END;

    FUNCTION upd_anag_e_res_e_mail (
        -- dati anagrafica
        p_id_anagrafica           IN ANAGRAFICI.id_anagrafica%TYPE DEFAULT NULL,
        p_ni                      IN ANAGRAFICI.ni%TYPE DEFAULT NULL,
        p_dal                     IN ANAGRAFICI.dal%TYPE,
        p_al                      IN ANAGRAFICI.al%TYPE DEFAULT NULL,
        p_cognome                 IN ANAGRAFICI.cognome%TYPE,
        p_nome                    IN ANAGRAFICI.nome%TYPE DEFAULT NULL,
        p_sesso                   IN ANAGRAFICI.sesso%TYPE DEFAULT NULL,
        p_data_nas                IN ANAGRAFICI.data_nas%TYPE DEFAULT NULL,
        p_provincia_nas           IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL,
        p_comune_nas              IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL,
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
        --      p_denominazione           IN ANAGRAFICI.denominazione%TYPE DEFAULT NULL,
        p_note_anag               IN ANAGRAFICI.note%TYPE DEFAULT NULL,
        ----- dati residenza
        p_descrizione_residenza   IN RECAPITI.descrizione%TYPE DEFAULT NULL,
        p_indirizzo_res           IN RECAPITI.indirizzo%TYPE DEFAULT NULL,
        p_provincia_res           IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL,
        p_comune_res              IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL,
        p_cap_res                 IN RECAPITI.cap%TYPE DEFAULT NULL,
        p_presso                  IN RECAPITI.presso%TYPE DEFAULT NULL,
        p_importanza              IN RECAPITI.importanza%TYPE DEFAULT NULL ---- mail
                                                                          ,
        p_mail                    IN CONTATTI.valore%TYPE DEFAULT NULL,
        p_note_mail               IN CONTATTI.note%TYPE DEFAULT NULL,
        p_importanza_mail         IN CONTATTI.importanza%TYPE DEFAULT NULL,
        ---- tel_res
        p_tel_res                 IN CONTATTI.valore%TYPE DEFAULT NULL,
        p_note_tel_res            IN CONTATTI.note%TYPE DEFAULT NULL,
        p_importanza_tel_res      IN CONTATTI.importanza%TYPE DEFAULT NULL,
        ---- fax_res
        p_fax_res                 IN CONTATTI.valore%TYPE DEFAULT NULL,
        p_note_fax_res            IN CONTATTI.note%TYPE DEFAULT NULL,
        p_importanza_fax_res      IN CONTATTI.importanza%TYPE DEFAULT NULL,
        ---- dati generici
        p_utente                  IN ANAGRAFICI.utente%TYPE DEFAULT NULL,
        p_data_agg                IN ANAGRAFICI.data_agg%TYPE DEFAULT SYSDATE --      ,
                                                                             --      p_batch                      NUMBER DEFAULT 1           -- 0 = NON batch
                                                                             )
        RETURN NUMBER
    IS
    BEGIN
        RETURN ins_anag_e_res_e_mail (
                   -- dati anagrafica
                   --    p_id_anagrafica        =>  p_id_anagrafica          ,
                   p_ni                      => p_ni,
                   p_dal                     => TRUNC (SYSDATE),
                   p_al                      => p_al,
                   p_cognome                 => p_cognome,
                   p_nome                    => p_nome,
                   p_sesso                   => p_sesso,
                   p_data_nas                => p_data_nas,
                   p_provincia_nas           => p_provincia_nas,
                   p_comune_nas              => p_comune_nas,
                   p_luogo_nas               => p_luogo_nas,
                   p_codice_fiscale          => p_codice_fiscale,
                   p_codice_fiscale_estero   => p_codice_fiscale_estero,
                   p_partita_iva             => p_partita_iva,
                   p_cittadinanza            => p_cittadinanza,
                   p_gruppo_ling             => p_gruppo_ling,
                   p_competenza              => p_competenza,
                   p_competenza_esclusiva    => p_competenza_esclusiva,
                   p_tipo_soggetto           => p_tipo_soggetto,
                   p_stato_cee               => p_stato_cee,
                   p_partita_iva_cee         => p_partita_iva_cee,
                   p_fine_validita           => p_fine_validita,
                   p_stato_soggetto          => p_stato_soggetto,
                   --      p_denominazione        =>  p_denominazione          ,
                   p_note_anag               => p_note_anag,
                   ----- dati residenza
                   --      p_id_recapito
                   --    , p_ni
                   --    , p_dal
                   --    , p_al
                   p_descrizione_residenza   => p_descrizione_residenza --p_descrizione
                                                                       --    , p_id_tipo_recapito
                                                                       ,
                   p_indirizzo_res           => p_indirizzo_res,
                   p_provincia_res           => p_provincia_res,
                   p_comune_res              => p_comune_res,
                   p_cap_res                 => p_cap_res,
                   p_presso                  => p_presso,
                   p_importanza              => p_importanza         ---- mail
                                                            ,
                   p_mail                    => p_mail             -- p_valore
                                                      --    , p_id_tipo_contatto   -- FISSO
                                                      ,
                   p_note_mail               => p_note_mail,
                   p_importanza_mail         => p_importanza_mail ---- tel res
                                                                 ,
                   p_tel_res                 => p_tel_res          -- p_valore
                                                         --    , p_id_tipo_contatto -- FISSO
                                                         ,
                   p_note_tel_res            => p_note_tel_res,
                   p_importanza_tel_res      => p_importanza_tel_res ---- fax res
                                                                    ,
                   p_fax_res                 => p_fax_res --    , p_id_tipo_contatto  -- FISSO
                                                         ,
                   p_note_fax_res            => p_note_fax_res,
                   p_importanza_fax_res      => p_importanza_fax_res,
                   ---- dati generici
                   p_utente                  => p_utente,
                   p_data_agg                => p_data_agg       --          ,
                                                          --      p_batch              => p_batch                            -- 0 = NON batch
                                                          );
    END;

    FUNCTION upd_anag_dom_e_res_e_mail (
        -- dati anagrafica
        --      p_id_anagrafica           IN ANAGRAFICI.id_anagrafica%TYPE DEFAULT NULL,
        p_ni                      IN ANAGRAFICI.ni%TYPE,
        p_dal                     IN ANAGRAFICI.dal%TYPE,
        p_al                      IN ANAGRAFICI.al%TYPE DEFAULT NULL,
        p_cognome                 IN ANAGRAFICI.cognome%TYPE,
        p_nome                    IN ANAGRAFICI.nome%TYPE DEFAULT NULL,
        p_sesso                   IN ANAGRAFICI.sesso%TYPE DEFAULT NULL,
        p_data_nas                IN ANAGRAFICI.data_nas%TYPE DEFAULT NULL,
        p_provincia_nas           IN AD4_PROVINCE.provincia%TYPE DEFAULT NULL,
        p_comune_nas              IN AD4_COMUNI.comune%TYPE DEFAULT NULL,
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
        p_descrizione_residenza   IN RECAPITI.descrizione%TYPE DEFAULT NULL,
        p_indirizzo_res           IN RECAPITI.indirizzo%TYPE DEFAULT NULL,
        p_provincia_res           IN AD4_PROVINCE.provincia%TYPE DEFAULT NULL,
        p_comune_res              IN AD4_COMUNI.comune%TYPE DEFAULT NULL,
        p_cap_res                 IN RECAPITI.cap%TYPE DEFAULT NULL,
        p_presso                  IN RECAPITI.presso%TYPE DEFAULT NULL,
        p_importanza              IN RECAPITI.importanza%TYPE DEFAULT NULL ---- mail
                                                                          ,
        p_mail                    IN CONTATTI.valore%TYPE DEFAULT NULL,
        p_note_mail               IN CONTATTI.note%TYPE DEFAULT NULL,
        p_importanza_mail         IN CONTATTI.importanza%TYPE DEFAULT NULL,
        ---- tel_res
        p_tel_res                 IN CONTATTI.valore%TYPE DEFAULT NULL,
        p_note_tel_res            IN CONTATTI.note%TYPE DEFAULT NULL,
        p_importanza_tel_res      IN CONTATTI.importanza%TYPE DEFAULT NULL,
        ---- fax_res
        p_fax_res                 IN CONTATTI.valore%TYPE DEFAULT NULL,
        p_note_fax_res            IN CONTATTI.note%TYPE DEFAULT NULL,
        p_importanza_fax_res      IN CONTATTI.importanza%TYPE DEFAULT NULL -- dati DOMICILIO
                                                                          ,
        p_descrizione_dom         IN RECAPITI.descrizione%TYPE DEFAULT NULL --p_descrizione
                                                                           ,
        p_indirizzo_dom           IN RECAPITI.indirizzo%TYPE DEFAULT NULL,
        p_provincia_dom           IN AD4_PROVINCE.provincia%TYPE DEFAULT NULL,
        p_comune_dom              IN AD4_COMUNI.comune%TYPE DEFAULT NULL,
        p_cap_dom                 IN RECAPITI.cap%TYPE DEFAULT NULL ---- tel dom
                                                                   ,
        p_tel_dom                 IN CONTATTI.valore%TYPE DEFAULT NULL -- p_valore
                                                                      --    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
                                                                      ,
        p_note_tel_dom            IN CONTATTI.note%TYPE DEFAULT NULL,
        p_importanza_tel_dom      IN CONTATTI.importanza%TYPE DEFAULT NULL ---- fax dom
                                                                          ,
        p_fax_dom                 IN CONTATTI.valore%TYPE DEFAULT NULL -- p_valore
                                                                      --    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
                                                                      ,
        p_note_fax_dom            IN CONTATTI.note%TYPE DEFAULT NULL,
        ---- dati generici
        p_utente                  IN ANAGRAFICI.utente%TYPE DEFAULT NULL,
        p_data_agg                IN ANAGRAFICI.data_agg%TYPE DEFAULT SYSDATE,
        p_batch                      NUMBER DEFAULT 0         -- 0 = NON batch
                                                     )
        RETURN NUMBER
    IS
        /******************************************************************************
        NOME:        upd_anag_dom_e_res_e_mail.
        DESCRIZIONE: inserisce da record piatto.
        ARGOMENTI:
        NOTE:
        REVISIONI:
        Rev. Data       Autore Descrizione
        ---- ---------- ------ ------------------------------------------------------
        011  17/10/2018 SNeg   Sistemato nvl nella greatest x calcolo del dal
        020  12/03/2019 SNeg   Chiusura soggetto da anagrafe linare #33680
        025  21/08/2019 Sneg   Non serve aggiornare il dal se uguale a quello già indicato Bug #36464
        030  18/09/2019  SNeg  chiusura record se valore passato nullo x anagrafe lineare
        036  05/02/2020  Sneg  Consentire anche solo modifica di competenza e competenza_esclusiva Bug #40420
        039  10/11/2020  SNeg  Per aggiornare i contatti considerare anche la data del contatto appena crato Bug #45977
        ******************************************************************************/
        v_old_anagrafe_soggetti   anagrafe_soggetti%ROWTYPE;
        v_new_anagrafici          anagrafici%ROWTYPE;
        integrity_error           EXCEPTION;
        errno                     INTEGER;
        errmsg                    CHAR (200);
        dummy                     INTEGER;
        FOUND                     BOOLEAN;
        d_result                  AFC_Error.t_error_number;
        d_id_anagrafica           anagrafici.id_anagrafica%TYPE;
        v_cognome                 anagrafici.cognome%TYPE;
        v_nome                    anagrafici.nome%TYPE;
        d_id_recapito             recapiti.id_recapito%TYPE;
        d_contatto_attuale        CONTATTI%ROWTYPE;
        d_id_contatto             CONTATTI.id_recapito%TYPE;
        d_contatto_valore         contatti.valore%TYPE;
        d_id_tipo_contatto        tipi_contatto.id_tipo_contatto%TYPE;
        v_new_ni                  anagrafici.ni%TYPE;
        d_pointer                 NUMBER;
        d_note                    anagrafici.note%TYPE;
        v_nuovo_dal               DATE;

        PROCEDURE INSERIMENTO_CONTATTo_X_DOM
        IS
            v_esiste   NUMBER := 0;
        BEGIN
            IF d_contatto_valore IS NOT NULL
            THEN
                SELECT COUNT (*) -- ma a patto che non esista un record con stesso valore di contatto
                  INTO v_esiste
                  FROM contatti cont2
                 WHERE     cont2.id_recapito = d_id_recapito
                       AND al IS NULL
                       AND id_tipo_contatto = d_id_tipo_contatto
                       AND valore = d_contatto_valore;

                IF v_esiste = 0
                THEN
                    d_id_contatto :=
                        contatti_tpk.ins (
                            p_id_contatto            => '',
                            p_id_recapito            => d_id_recapito,
                            p_dal                    =>
                                nvl ( -- rev.26
                                    v_nuovo_dal,
                                    GREATEST (
                                        v_new_anagrafici.dal,
                                        NVL (
                                            p_dal,
                                            TO_DATE ('01/01/1900',
                                                     'dd/mm/yyyy')))), --????,              --p_dal,
                            p_al                     => p_al,
                            p_valore                 => d_contatto_valore,
                            p_id_tipo_contatto       => d_id_tipo_contatto,
                            p_note                   => d_note,
                            p_competenza             => p_competenza,
                            p_competenza_esclusiva   => p_competenza_esclusiva,
                            p_version                => '',       --p_version,
                            p_utente_aggiornamento   => p_utente,
                            p_data_aggiornamento     => p_data_agg);
                END IF;
            END IF;
        END;

        PROCEDURE INSERIMENTO_recapito_X_DOM
        IS
            -- rev 15 Inizio
            v_esiste_gia_stesso_dal   NUMBER;
        BEGIN
            v_nuovo_dal :=
                GREATEST (v_new_anagrafici.dal,
                          NVL (p_dal, TO_DATE ('01/01/1900', 'dd/mm/yyyy')));

            SELECT COUNT (*)
              INTO v_esiste_gia_stesso_dal
              FROM recapiti
             WHERE     ni = p_ni
                   AND dal = v_nuovo_dal
                   AND al IS NOT NULL                      -- non modificabile
                   AND id_tipo_recapito = 2;

            IF v_esiste_gia_stesso_dal > 0
            THEN
                -- esiste già
                v_nuovo_dal := TRUNC (SYSDATE);
            END IF;

            -- insert in sedi x domicilio
            d_id_recapito :=
                recapiti_tpk.ins (
                    p_id_recapito            => NULL,
                    p_ni                     => p_ni,
                    p_dal                    => v_nuovo_dal,
                    p_al                     => p_al,
                    p_descrizione            => '',           --p_descrizione,
                    p_id_tipo_recapito       => 2 -- domicilio p_id_tipo_recapito
                                                 ,
                    p_indirizzo              => p_indirizzo_dom,
                    p_provincia              => p_provincia_dom,
                    p_comune                 => p_comune_dom,
                    p_cap                    => p_cap_dom,
                    p_presso                 => p_presso,
                    p_importanza             => p_importanza,
                    p_competenza             => p_competenza,
                    p_competenza_esclusiva   => p_competenza_esclusiva,
                    p_version                => '',               --p_version,
                    p_utente_aggiornamento   => p_utente,
                    p_data_aggiornamento     => p_data_agg);

            IF p_tel_dom IS NOT NULL OR p_fax_dom IS NOT NULL -- ci sono contatti di domicilio
            THEN
                FOR cont IN 1 .. 2
                LOOP
                    --1 = TELEFONO
                    --2 = FAX
                    d_contatto_valore := NULL;

                    IF CONT = 1 AND p_TEL_DOM IS NOT NULL
                    THEN
                        d_contatto_valore := p_tel_DOM;
                        d_id_tipo_contatto := 1;
                        d_note := p_note_tel_dom;
                    ELSIF cont = 2 AND p_fax_DOM IS NOT NULL
                    THEN
                        d_contatto_valore := p_fax_DOM;
                        d_id_tipo_contatto := 2;
                        d_note := p_note_fax_dom;
                    END IF;

                    INSERIMENTO_CONTATTO_X_DOM;
                END LOOP;
            END IF;
        END;

        PROCEDURE INSERIMENTO_CONTATTO_X_RES
        IS
            v_esiste   NUMBER := 0;
        BEGIN
            IF d_contatto_valore IS NOT NULL
            THEN
                SELECT COUNT (*) -- ma a patto che non esista un record con stesso valore di contatto
                  INTO v_esiste
                  FROM contatti cont2
                 WHERE     cont2.id_recapito = d_id_recapito
                       AND al IS NULL
                       AND id_tipo_contatto = d_id_tipo_contatto
                       AND valore = d_contatto_valore;

                IF v_esiste = 0
                THEN
                    d_id_contatto :=
                        contatti_tpk.ins (
                            p_id_contatto            => '',
                            p_id_recapito            => d_id_recapito,
                            p_dal                    =>
                                nvl (-- rev.26
                                    v_nuovo_dal,
                                    GREATEST (
                                        v_new_anagrafici.dal,
                                        NVL (
                                            p_dal,
                                            TO_DATE ('01/01/1900',
                                                     'dd/mm/yyyy')))), --????,              --p_dal,
                            p_al                     => p_al,
                            p_valore                 => d_contatto_valore,
                            p_id_tipo_contatto       => d_id_tipo_contatto,
                            p_note                   => d_note,
                            p_competenza             => p_competenza,
                            p_competenza_esclusiva   => p_competenza_esclusiva,
                            p_version                => '',       --p_version,
                            p_utente_aggiornamento   => p_utente,
                            p_data_aggiornamento     => p_data_agg);
                END IF;
            END IF;
        END;

        PROCEDURE INSERIMENTO_RECAPITO_X_RES
        IS
            -- rev 15 Inizio
            v_esiste_gia_stesso_dal   NUMBER;
        BEGIN
            v_nuovo_dal :=
                GREATEST (v_new_anagrafici.dal,
                          NVL (p_dal, TO_DATE ('01/01/1900', 'dd/mm/yyyy')));

            SELECT COUNT (*)
              INTO v_esiste_gia_stesso_dal
              FROM recapiti
             WHERE     ni = p_ni
                   AND dal = v_nuovo_dal
                   AND al IS NOT NULL                      -- non modificabile
                   AND id_tipo_recapito = 1;

            IF v_esiste_gia_stesso_dal > 0
            THEN
                -- esiste già
                v_nuovo_dal := TRUNC (SYSDATE);
            END IF;


            --         raise_application_error(-20999,'trovato ' ||p_ni ||':' || p_dal);
            d_id_recapito :=
                recapiti_tpk.ins (
                    p_id_recapito            => NULL,
                    p_ni                     => p_ni,                  --p_ni,
                    p_dal                    => v_nuovo_dal, --greatest(v_new_anagrafici.dal ,  nvl(p_dal,to_date('01/01/1900','dd/mm/yyyy'))),--????,                 --p_dal,
                    -- rev 15 Fine
                    p_al                     => p_al,
                    p_descrizione            => '',           --p_descrizione,
                    p_id_tipo_recapito       => 1 -- RESIDENZA p_id_tipo_recapito
                                                 ,
                    p_indirizzo              => p_indirizzo_res,
                    p_provincia              => p_provincia_res,
                    p_comune                 => p_comune_res,
                    p_cap                    => p_cap_res,
                    p_presso                 => p_presso,
                    p_importanza             => p_importanza,
                    p_competenza             => p_competenza,
                    p_competenza_esclusiva   => p_competenza_esclusiva,
                    p_version                => '',               --p_version,
                    p_utente_aggiornamento   => p_utente,
                    p_data_aggiornamento     => p_data_agg);

            -- inserimento del contatto x residenza
            IF    p_tel_res IS NOT NULL
               OR p_fax_res IS NOT NULL       -- ci sono contatti di residenza
               OR p_mail IS NOT NULL
            THEN
                FOR cont IN 1 .. 3
                LOOP
                    --1 = TELEFONO
                    --2 = FAX
                    --3 = MAIL
                    d_contatto_valore := NULL;

                    IF CONT = 1 AND p_TEL_RES IS NOT NULL
                    THEN
                        d_contatto_valore := p_tel_res;
                        d_id_tipo_contatto := 1;
                        d_note := p_note_tel_res;
                    ELSIF cont = 2 AND p_fax_res IS NOT NULL
                    THEN
                        d_contatto_valore := p_fax_res;
                        d_id_tipo_contatto := 2;
                        d_note := p_note_fax_res;
                    ELSIF cont = 3 AND p_mail IS NOT NULL
                    THEN
                        d_contatto_valore := p_mail;
                        d_id_tipo_contatto := 3;
                        d_note := p_note_mail;
                    END IF;

                    INSERIMENTO_CONTATTO_X_RES;
                END LOOP;
            END IF;
        END;
    BEGIN
        --raise_application_error(-20999,'anagrafica ' || d_id_anagrafica || ' old_dal:' || v_old_anagrafe_soggetti.dal || ' new_dal:' ||p_dal);
        -- INIZIOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
        anagrafici_pkg.v_aggiornamento_da_package_on := 1;
        v_cognome := p_cognome;
        v_nome := p_nome;

        IF     p_cognome IS NULL
           AND p_nome IS NULL
           AND p_denominazione IS NOT NULL
        THEN
            d_pointer := INSTR (p_denominazione, '  ');

            IF d_pointer = 0
            THEN
                v_cognome := RTRIM (p_denominazione);
                v_nome := NULL;
            ELSE
                v_cognome :=
                    RTRIM (SUBSTR (p_denominazione, 1, d_pointer - 1));
                v_nome := RTRIM (SUBSTR (p_denominazione, d_pointer + 2));
            END IF;
        END IF;

        BEGIN
            SELECT *
              INTO v_old_anagrafe_soggetti
              FROM anagrafe_soggetti
             WHERE     ni = p_ni
             -- rev. 30 inizio
--               AND SYSDATE BETWEEN dal
--                                   AND NVL (al, TO_DATE ('3333333', 'j'))
             -- rev. 30 fine
               AND al IS NULL ;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (-20999, si4.get_error ('A10089')); -- Impossibile determinare record da aggiornare.);
        -- a volte succede se le storicità su anagrafe_soggetti sono diverse da quelle
        -- di anagrafici a causa di contatti o recapiti con storicità future
        END;

        -- id_anagrafica ATTUALE
        BEGIN
            SELECT id_anagrafica
              INTO d_id_anagrafica
              FROM anagrafici
             WHERE ni = p_ni
               AND SYSDATE BETWEEN dal
                                   AND NVL (al, TO_DATE ('3333333', 'j'))
               AND al IS NULL ;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (
                    -20999,
                    si4.get_error ('A10089') || ' (aperto)'); -- Impossibile determinare record da aggiornare.);
        END;

        -- come calcolo il nuovo DAL?
        --       v_new_dal := p_dal;   --????????????
        -- controllo se qualcosa è cambiato
        IF    NVL (p_dal, TRUNC (SYSDATE)) !=
              NVL (v_old_anagrafe_soggetti.dal, TRUNC (SYSDATE))
           OR NVL (p_COGNOME, '1') !=
              NVL (v_old_anagrafe_soggetti.COGNOME, '1')
           OR NVL (p_NOME, '1') != NVL (v_old_anagrafe_soggetti.NOME, '1')
           OR NVL (p_SESSO, '1') != NVL (v_old_anagrafe_soggetti.SESSO, '1')
           OR NVL (p_DATA_NAS, TO_DATE ('2222222', 'j')) !=
              NVL (v_old_anagrafe_soggetti.DATA_NAS,
                   TO_DATE ('2222222', 'j'))
           OR NVL (p_PROVINCIA_NAS, 1) !=
              NVL (v_old_anagrafe_soggetti.PROVINCIA_NAS, 1)
           OR NVL (p_COMUNE_NAS, 1) !=
              NVL (v_old_anagrafe_soggetti.COMUNE_NAS, 1)
           OR NVL (p_LUOGO_NAS, '1') !=
              NVL (v_old_anagrafe_soggetti.LUOGO_NAS, '1')
           OR NVL (p_CODICE_FISCALE, '1') !=
              NVL (v_old_anagrafe_soggetti.CODICE_FISCALE, '1')
           OR NVL (p_CODICE_FISCALE_ESTERO, '1') !=
              NVL (v_old_anagrafe_soggetti.CODICE_FISCALE_ESTERO, '1')
           OR NVL (p_PARTITA_IVA, '1') !=
              NVL (v_old_anagrafe_soggetti.PARTITA_IVA, '1')
           OR NVL (p_CITTADINANZA, '1') !=
              NVL (v_old_anagrafe_soggetti.CITTADINANZA, '1')
           OR NVL (p_GRUPPO_LING, '1') !=
              NVL (v_old_anagrafe_soggetti.GRUPPO_LING, '1')
           OR NVL (p_INDIRIZZO_RES, '1') !=
              NVL (v_old_anagrafe_soggetti.INDIRIZZO_RES, '1')
           OR NVL (p_PROVINCIA_RES, '1') !=
              NVL (v_old_anagrafe_soggetti.PROVINCIA_RES, '1')
           OR NVL (p_COMUNE_RES, '1') !=
              NVL (v_old_anagrafe_soggetti.COMUNE_RES, '1')
           OR NVL (p_CAP_RES, '1') !=
              NVL (v_old_anagrafe_soggetti.CAP_RES, '1')
           OR NVL (p_TEL_RES, '1') !=
              NVL (v_old_anagrafe_soggetti.TEL_RES, '1')
           OR NVL (p_FAX_RES, '1') !=
              NVL (v_old_anagrafe_soggetti.FAX_RES, '1')
           OR NVL (p_PRESSO, '1') !=
              NVL (v_old_anagrafe_soggetti.PRESSO, '1')
           OR NVL (p_INDIRIZZO_DOM, '1') !=
              NVL (v_old_anagrafe_soggetti.INDIRIZZO_DOM, '1')
           OR NVL (p_PROVINCIA_DOM, '1') !=
              NVL (v_old_anagrafe_soggetti.PROVINCIA_DOM, '1')
           OR NVL (p_COMUNE_DOM, '1') !=
              NVL (v_old_anagrafe_soggetti.COMUNE_DOM, '1')
           OR NVL (p_CAP_DOM, '1') !=
              NVL (v_old_anagrafe_soggetti.CAP_DOM, '1')
           OR NVL (p_TEL_DOM, '1') !=
              NVL (v_old_anagrafe_soggetti.TEL_DOM, '1')
           OR NVL (p_FAX_DOM, '1') !=
              NVL (v_old_anagrafe_soggetti.FAX_DOM, '1')
           --or nvl(p_UTENTE,'1') != nvl(v_old_anagrafe_soggetti.UTENTE ,'1')
           --or nvl(p_DATA_AGG,to_date('2222222','j')) != nvl(v_old_anagrafe_soggetti.DATA_AGG ,to_date('2222222','j'))
           -- rev. 36 inizio
           or nvl(p_COMPETENZA,'1') != nvl(v_old_anagrafe_soggetti.COMPETENZA ,'1')
           or nvl(p_COMPETENZA_ESCLUSIVA,'1') != nvl(v_old_anagrafe_soggetti.COMPETENZA_ESCLUSIVA ,'1')
           -- rev.36 fine
           OR NVL (p_TIPO_SOGGETTO, '1') !=
              NVL (v_old_anagrafe_soggetti.TIPO_SOGGETTO, '1')
           --      OR NVL (p_FLAG_TRG, '1') != NVL (v_old_anagrafe_soggetti.FLAG_TRG, '1')
           OR NVL (p_STATO_CEE, '1') !=
              NVL (v_old_anagrafe_soggetti.STATO_CEE, '1')
           OR NVL (p_PARTITA_IVA_CEE, '1') !=
              NVL (v_old_anagrafe_soggetti.PARTITA_IVA_CEE, '1')
           OR NVL (p_FINE_VALIDITA, TO_DATE ('2222222', 'j')) !=
              NVL (v_old_anagrafe_soggetti.FINE_VALIDITA,
                   TO_DATE ('2222222', 'j'))
           OR NVL (p_AL, TO_DATE ('2222222', 'j')) !=
              NVL (v_old_anagrafe_soggetti.AL, TO_DATE ('2222222', 'j'))
           OR NVL (p_DENOMINAZIONE, '1') !=
              NVL (v_old_anagrafe_soggetti.DENOMINAZIONE, '1')
           OR NVL (p_mail, '1') !=
              NVL (v_old_anagrafe_soggetti.INDIRIZZO_WEB, '1')
           OR NVL (p_NOTE_anag, '1') !=
              NVL (v_old_anagrafe_soggetti.NOTE, '1')
        THEN
            -- update anagrafici
            anagrafici_pkg.upd (
                p_new_id_anagrafica           => d_id_anagrafica,         --??
                p_new_ni                      => p_ni,
                p_new_dal                     => p_dal,
                p_new_al                      => p_al,
                p_new_cognome                 => v_cognome,
                p_new_nome                    => v_nome,
                p_new_sesso                   => p_sesso,
                p_new_data_nas                => p_data_nas,
                p_new_provincia_nas           => p_provincia_nas,
                p_new_comune_nas              => p_comune_nas,
                p_new_luogo_nas               => p_luogo_nas,
                p_new_codice_fiscale          => p_codice_fiscale,
                p_new_codice_fiscale_estero   => p_codice_fiscale_estero,
                p_new_partita_iva             => p_partita_iva,
                p_new_cittadinanza            => p_cittadinanza,
                p_new_gruppo_ling             => p_gruppo_ling,
                p_new_competenza              => p_competenza,
                p_new_competenza_esclusiva    => p_competenza_esclusiva,
                p_new_tipo_soggetto           => p_tipo_soggetto,
                p_new_stato_cee               => p_stato_cee,
                p_new_partita_iva_cee         => p_partita_iva_cee,
                p_new_fine_validita           => p_fine_validita,
                p_new_stato_soggetto          => 'U',                     --??
                p_new_denominazione           => p_denominazione,
                p_new_note                    => p_note_anag,
                p_new_version                 => '',              --p_versione
                p_new_utente                  => p_utente,
                p_new_data_aggiornamento      => p_data_agg,
                -- cambiato nome del parametro x ambiguità nella UPD
                p_batch                       => 1 -- in as4_anagrafe_soggetti considero sia batch ??
                                                  );

            BEGIN
                -- Rev. 20 #33680 Inizio
                SELECT *
                  INTO v_new_anagrafici
                  FROM anagrafici
                 WHERE     ni = p_ni
                       AND SYSDATE BETWEEN dal
                                       AND NVL (al, TO_DATE ('3333333', 'j'))
                       AND al IS NULL;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    -- sto chiudendo il record
                    v_new_anagrafici := NULL;
            END;

            -- Rev. 20 #33680 Fine
            DECLARE
                v_dal_recapito   DATE;
            BEGIN
                SELECT id_recapito, dal
                  INTO d_id_recapito, v_dal_recapito
                  FROM recapiti
                 WHERE     ni = v_old_anagrafe_soggetti.ni
                       AND al IS NULL
                       AND id_tipo_recapito = 1;

                --raise_application_error(-20999,'trovato ' || d_id_recapito);
                IF     (   NVL (p_INDIRIZZO_RES, '1') !=
                           NVL (v_old_anagrafe_soggetti.INDIRIZZO_RES, '1')
                        OR NVL (p_PROVINCIA_RES, '1') !=
                           NVL (v_old_anagrafe_soggetti.PROVINCIA_RES, '1')
                        OR NVL (p_COMUNE_RES, '1') !=
                           NVL (v_old_anagrafe_soggetti.COMUNE_RES, '1')
                        OR NVL (p_CAP_RES, '1') !=
                           NVL (v_old_anagrafe_soggetti.CAP_RES, '1')
                        OR NVL (p_PRESSO, '1') !=
                           NVL (v_old_anagrafe_soggetti.PRESSO, '1')
                        OR NVL (p_AL, TO_DATE ('2222222', 'j')) !=
                           NVL (v_old_anagrafe_soggetti.AL,
                                TO_DATE ('2222222', 'j')))
                   -- rev. 25 inizio
                   AND (   p_indirizzo_RES IS NOT NULL
                        OR p_provincia_res IS NOT NULL
                        OR p_comune_res IS NOT NULL
                        OR p_cap_res IS NOT NULL
                        OR p_presso IS NOT NULL
                        OR p_al IS NOT NULL)
                -- rev. 25 fine
                THEN
                    -- cambiato il recapito di residenza
                    -- trovato
                    recapiti_tpk.upd (
                        p_new_id_recapito            => d_id_recapito,
                        p_new_ni                     => p_ni,          --p_ni,
                        -- rev.15 inizio
                        p_new_dal                    =>
                            NVL (
                                v_dal_recapito,
                                GREATEST (
                                    v_new_anagrafici.dal,
                                    NVL (
                                        p_dal,
                                        TO_DATE ('01/01/1900', 'dd/mm/yyyy')))), --????,
                        -- rev.15 fine
                        p_new_al                     => p_al,
                        p_new_descrizione            => '',   --p_descrizione,
                        p_new_indirizzo              => p_indirizzo_res,
                        p_new_provincia              => p_provincia_res,
                        p_new_comune                 => p_comune_res,
                        p_new_cap                    => p_cap_res,
                        p_new_presso                 => p_presso,
                        p_new_competenza             => p_competenza,
                        p_new_competenza_esclusiva   => p_competenza_esclusiva,
                        p_new_version                => '',       --p_version,
                        p_new_utente_aggiornamento   => p_utente,
                        p_new_data_aggiornamento     => p_data_agg);
                END IF;                                  -- cambiata residenza

                -- rev. 25 Inizio
                -- ricalcolo nuovo dal se il recapito è stato ad esempio storicizzato
                BEGIN
                    SELECT id_recapito, dal
                      INTO d_id_recapito, v_dal_recapito
                      FROM recapiti
                     WHERE     ni = v_old_anagrafe_soggetti.ni
                           AND al IS NULL
                           AND id_tipo_recapito = 1;
                END;

                -- rev. 25 Fine
                -- update contatto x residenza
                FOR cont IN 1 .. 3
                LOOP
                    --1 = TELEFONO
                    --2 = FAX
                    --3 = MAIL
                    d_contatto_valore := NULL;

                    IF     CONT = 1
                       AND NVL (p_TEL_RES, '1') !=
                           NVL (v_old_anagrafe_soggetti.TEL_RES, '1') --AND p_TEL_RES IS NOT NULL
                    THEN
                        d_contatto_valore := p_tel_res;
                        d_id_tipo_contatto := 1;

                        --raise_application_error (-20999, 'Non trovato XX con:'||d_contatto_valore||':' || cont );
                        BEGIN
                            SELECT  c.*
                              INTO  d_contatto_attuale
                              FROM contatti c
                             WHERE     id_recapito = d_id_recapito
                                   AND al IS NULL
                                   AND id_tipo_contatto = 1
                                   -- aggiunto da AD 20/06/2018
                                   AND valore =
                                       v_old_anagrafe_soggetti.tel_res -- per individuare il record esatto
                                   AND NOT EXISTS
                                           (SELECT 1 -- ma a patto che non esista un record con stesso valore di contatto
                                              FROM contatti cont2
                                             WHERE     cont2.id_recapito =
                                                       d_id_recapito
                                                   AND al IS NULL
                                                   AND id_tipo_contatto = 1
                                                   AND valore =
                                                       d_contatto_valore);
                           d_id_contatto := d_contatto_attuale.id_contatto;
                          IF p_TEL_RES IS NOT NULL -- rev. 30 inizio
                        THEN -- aggiorno
                            --raise_application_error (-20999, 'SONO QUI con:'||d_contatto_valore );
                            -- trovato
                            null;
                            contatti_tpk.upd (
                                p_new_id_contatto            => d_id_contatto,
                                p_new_id_recapito            => d_id_recapito,
                                -- rev. 039 inizio
                                p_new_dal                    => greatest(d_contatto_attuale.dal,greatest(v_new_anagrafici.dal ,  nvl(p_dal,to_date('01/01/1900','dd/mm/yyyy')))),--????,
                                -- rev. 039 fine
                                p_new_al                     => p_al,
                                p_new_valore                 => d_contatto_valore,
                                p_new_id_tipo_contatto       => d_id_tipo_contatto,
                                p_new_note                   => p_note_tel_res,
                                p_new_competenza             => p_competenza,
                                p_new_competenza_esclusiva   =>
                                    p_competenza_esclusiva,
                                p_new_version                => '', --p_version,
                                p_new_utente_aggiornamento   => p_utente,
                                p_new_data_aggiornamento     => p_data_agg);
                         else -- valore nullo
                            contatti_tpk.upd (
                                p_new_id_contatto            => d_id_contatto,
                                p_new_id_recapito            => d_id_recapito,
                                p_new_dal                    => d_contatto_attuale.dal,
                                p_new_al                     => greatest(nvl(p_al,trunc(sysdate)-1),d_contatto_attuale.dal),
                                p_new_valore                 => d_contatto_attuale.valore,
                                p_new_id_tipo_contatto       => d_id_tipo_contatto,
                                p_new_note                   => p_note_tel_res,
                                p_new_competenza             => p_competenza,
                                p_new_competenza_esclusiva   => p_competenza_esclusiva,
                                p_new_version                => '', --p_version,
                                p_new_utente_aggiornamento   => p_utente,
                                p_new_data_aggiornamento     => p_data_agg);

                         end if;-- rev. 30 fine
                        EXCEPTION
                            WHEN NO_DATA_FOUND
                            THEN
                                -- aggiunto da AD 20/06/2018
                                DECLARE
                                    daInserire   NUMBER (1);
                                BEGIN
                                    BEGIN
                                        SELECT 0
                                          INTO daInserire
                                          FROM contatti
                                         WHERE     id_recapito =
                                                   d_id_recapito
                                               AND al IS NULL
                                               AND id_tipo_contatto = 1
                                               AND UPPER (valore) =
                                                   UPPER (d_contatto_valore);
                                    EXCEPTION
                                        WHEN NO_DATA_FOUND
                                        THEN
                                            daInserire := 1; -- non esiste il contatto con il valore che sto passando
                                    END;

                                    -- devo inserire solo se quel contatto non esiste già o non è null
                                    IF     d_contatto_valore IS NOT NULL
                                       AND daInserire = 1
                                    THEN
                                        inserimento_contatto_x_res;
                                    END IF;
                                END;
                        END;
                    ELSIF     cont = 2
                          AND NVL (p_FAX_RES, '1') !=
                              NVL (v_old_anagrafe_soggetti.FAX_RES, '1')
                    THEN
                        d_contatto_valore := p_fax_res;
                        d_id_tipo_contatto := 2;
                        d_note := p_note_fax_res;

                        BEGIN
                            SELECT *
                              INTO d_contatto_attuale
                              FROM contatti cont1
                             WHERE     id_recapito = d_id_recapito
                                   AND al IS NULL
                                   AND id_tipo_contatto = 2
                                   -- aggiunto da AD 20/06/2018
                                   AND valore =
                                       v_old_anagrafe_soggetti.fax_res -- per individuare il record esatto
                                   AND NOT EXISTS
                                           (SELECT 1 -- ma a patto che non esista un record con stesso valore di contatto
                                              FROM contatti cont2
                                             WHERE     cont2.id_recapito =
                                                       d_id_recapito
                                                   AND al IS NULL
                                                   AND id_tipo_contatto = 2
                                                   AND valore =
                                                       d_contatto_valore);
                            d_id_contatto := d_contatto_attuale.id_contatto;
                            -- trovato
                            -- rev. 30 inizio
                             IF p_fax_res IS NOT NULL  THEN
                            contatti_tpk.upd (
                                p_new_id_contatto            => d_id_contatto,
                                p_new_id_recapito            => d_id_recapito,
                                p_new_dal                    =>
                                    GREATEST (
                                        v_dal_recapito,
                                        GREATEST (
                                            v_new_anagrafici.dal,
                                            NVL (
                                                p_dal,
                                                TO_DATE ('01/01/1900',
                                                         'dd/mm/yyyy')))), --????,-- rev. 25
                                p_new_al                     => p_al,
                                p_new_valore                 => d_contatto_valore,
                                p_new_id_tipo_contatto       => d_id_tipo_contatto,
                                p_new_note                   => d_note,
                                p_new_competenza             => p_competenza,
                                p_new_competenza_esclusiva   =>
                                    p_competenza_esclusiva,
                                p_new_version                => '', --p_version,
                                p_new_utente_aggiornamento   => p_utente,
                                p_new_data_aggiornamento     => p_data_agg);
                          ELSE -- valore passato nullo devo chiudere il periodo

                            contatti_tpk.upd (
                                p_new_id_contatto            => d_id_contatto,
                                p_new_id_recapito            => d_id_recapito,
                                p_new_dal                    => d_contatto_attuale.dal,
                                p_new_al                     => greatest(nvl(p_al,trunc(sysdate)-1),d_contatto_attuale.dal), -- chiusura
                                p_new_valore                 => d_contatto_attuale.valore,
                                p_new_id_tipo_contatto       => d_id_tipo_contatto,
                                p_new_note                   => d_note,
                                p_new_competenza             => p_competenza,
                                p_new_competenza_esclusiva   =>
                                    p_competenza_esclusiva,
                                p_new_version                => '', --p_version,
                                p_new_utente_aggiornamento   => p_utente,
                                p_new_data_aggiornamento     => p_data_agg);

                          END IF;-- rev. 30 fine
                        EXCEPTION
                            WHEN NO_DATA_FOUND
                            THEN
                                -- aggiunto da AD 20/06/2018
                                DECLARE
                                    daInserire   NUMBER (1);
                                BEGIN
                                    BEGIN
                                        SELECT 0
                                          INTO daInserire
                                          FROM contatti
                                         WHERE     id_recapito =
                                                   d_id_recapito
                                               AND al IS NULL
                                               AND id_tipo_contatto = 2
                                               AND UPPER (valore) =
                                                   UPPER (d_contatto_valore);
                                    EXCEPTION
                                        WHEN NO_DATA_FOUND
                                        THEN
                                            daInserire := 1; -- non esiste il contatto con il valore che sto passando
                                    END;

                                    -- devo inserire solo se quel contatto non esiste già o non è null
                                    IF     d_contatto_valore IS NOT NULL
                                       AND daInserire = 1
                                    THEN
                                        inserimento_contatto_x_res;
                                    END IF;
                                END;
                        END;
                    ELSIF     cont = 3
                          AND NVL (p_mail, '1') !=
                              NVL (v_old_anagrafe_soggetti.INDIRIZZO_WEB,
                                   '1')
                    THEN
                        d_contatto_valore := p_mail;
                        d_id_tipo_contatto := 3;
                        d_note := p_note_mail;

                        BEGIN
                            SELECT *
                              INTO d_contatto_attuale
                              FROM contatti
                             WHERE     id_recapito = d_id_recapito
                                   AND al IS NULL
                                   AND id_tipo_contatto = 3
                                   -- aggiunto da AD 20/06/2018
                                   AND UPPER (valore) =
                                       UPPER (
                                           v_old_anagrafe_soggetti.indirizzo_web) -- per individuare il record esatto
                                   AND NOT EXISTS
                                           (SELECT 1 -- ma a patto che non esista un record con stesso valore di contatto
                                              FROM contatti cont2
                                             WHERE     cont2.id_recapito =
                                                       d_id_recapito
                                                   AND al IS NULL
                                                   AND id_tipo_contatto = 3
                                                   AND UPPER (valore) =
                                                       UPPER (
                                                           d_contatto_valore));

                            -- trovato
                            -- rev. 30 inizio
                            d_id_contatto := d_contatto_attuale.id_contatto;
                            IF p_mail IS NOT NULL  THEN
                            contatti_tpk.upd (
                                p_new_id_contatto            => d_id_contatto,
                                p_new_id_recapito            => d_id_recapito,
                                p_new_dal                    =>
                                    GREATEST (
                                        v_dal_recapito,
                                        GREATEST (
                                            v_new_anagrafici.dal,
                                            NVL (
                                                p_dal,
                                                TO_DATE ('01/01/1900',
                                                         'dd/mm/yyyy')))), --????, -- rev. 25
                                p_new_al                     => p_al,
                                p_new_valore                 => d_contatto_valore,
                                p_new_id_tipo_contatto       => d_id_tipo_contatto,
                                p_new_note                   => d_note,
                                p_new_competenza             => p_competenza,
                                p_new_competenza_esclusiva   =>
                                    p_competenza_esclusiva,
                                p_new_version                => '', --p_version,
                                p_new_utente_aggiornamento   => p_utente,
                                p_new_data_aggiornamento     => p_data_agg);
                          ELSE
                            contatti_tpk.upd (
                                p_new_id_contatto            => d_id_contatto,
                                p_new_id_recapito            => d_id_recapito,
                                p_new_dal                    => d_contatto_attuale.dal,
                                p_new_al                     => greatest(nvl(p_al,trunc(sysdate)-1),d_contatto_attuale.dal),
                                p_new_valore                 => d_contatto_attuale.valore,
                                p_new_id_tipo_contatto       => d_id_tipo_contatto,
                                p_new_note                   => d_note,
                                p_new_competenza             => p_competenza,
                                p_new_competenza_esclusiva   =>
                                    p_competenza_esclusiva,
                                p_new_version                => '', --p_version,
                                p_new_utente_aggiornamento   => p_utente,
                                p_new_data_aggiornamento     => p_data_agg);
                          END IF;-- rev. 30 fine
                        EXCEPTION
                            WHEN NO_DATA_FOUND
                            THEN
                                -- aggiunto da AD 20/06/2018
                                DECLARE
                                    daInserire   NUMBER (1);
                                BEGIN
                                    BEGIN
                                        SELECT 0
                                          INTO daInserire
                                          FROM contatti
                                         WHERE     id_recapito =
                                                   d_id_recapito
                                               AND al IS NULL
                                               AND id_tipo_contatto = 3
                                               AND UPPER (valore) =
                                                   UPPER (d_contatto_valore);
                                    EXCEPTION
                                        WHEN NO_DATA_FOUND
                                        THEN
                                            daInserire := 1; -- non esiste il contatto con il valore che sto passando
                                    END;

                                    -- devo inserire solo se quel contatto non esiste già o non è null
                                    IF     d_contatto_valore IS NOT NULL
                                       AND daInserire = 1
                                    THEN
                                        inserimento_contatto_x_res;
                                    END IF;
                                END;
                        END;
                    END IF;
                END LOOP;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN                                     -- prima non esisteva
                    IF    p_indirizzo_res IS NOT NULL
                       OR p_provincia_res IS NOT NULL
                       OR p_comune_res IS NOT NULL
                       OR p_cap_res IS NOT NULL
                       OR p_presso IS NOT NULL
                       OR p_tel_res IS NOT NULL
                       OR p_fax_res IS NOT NULL -- ci sono contatti di residenza
                       OR p_mail IS NOT NULL
                    THEN
                        inserimento_recapito_x_res;
                    END IF;

                    NULL;
            END;

            -- domicilio
            DECLARE
                v_dal_recapito   DATE;
            BEGIN
                d_id_recapito := NULL;

                BEGIN
                    --raise_application_error(-20999,'trovato ' || d_id_recapito);
                    IF     (   NVL (p_INDIRIZZO_DOM, '1') !=
                               NVL (v_old_anagrafe_soggetti.INDIRIZZO_DOM,
                                    '1')
                            OR NVL (p_PROVINCIA_DOM, '1') !=
                               NVL (v_old_anagrafe_soggetti.PROVINCIA_DOM,
                                    '1')
                            OR NVL (p_COMUNE_DOM, '1') !=
                               NVL (v_old_anagrafe_soggetti.COMUNE_DOM, '1')
                            OR NVL (p_CAP_DOM, '1') !=
                               NVL (v_old_anagrafe_soggetti.CAP_DOM, '1')
                            OR NVL (p_AL, TO_DATE ('2222222', 'j')) !=
                               NVL (v_old_anagrafe_soggetti.AL,
                                    TO_DATE ('2222222', 'j'))
                            OR NVL (p_tel_dom, '-1') !=
                               NVL (v_old_anagrafe_soggetti.tel_DOM, '-1')
                            OR NVL (p_fax_DOM, '-1') !=
                               NVL (v_old_anagrafe_soggetti.fax_DOM, '-1'))
                       -- rev. 25 inizio
                       AND (   p_indirizzo_dom IS NOT NULL
                            OR p_provincia_dom IS NOT NULL
                            OR p_comune_dom IS NOT NULL
                            OR p_cap_dom IS NOT NULL
                            OR p_tel_dom IS NOT NULL
                            OR p_fax_dom IS NOT NULL
                            or p_al is not null)
                    -- rev.25 fine
                    THEN
                        BEGIN
                            SELECT id_recapito, dal
                              INTO d_id_recapito, v_dal_recapito
                              FROM recapiti
                             WHERE     ni = v_old_anagrafe_soggetti.ni
                                   AND al IS NULL
                                   AND id_tipo_recapito = 2;

                            -- trovato
                            recapiti_tpk.upd (
                                p_new_id_recapito            => d_id_recapito,
                                p_new_ni                     => p_ni,  --p_ni,
                                p_new_dal                    =>
                                    NVL (
                                        v_dal_recapito,
                                        GREATEST (
                                            v_new_anagrafici.dal,
                                            NVL (
                                                p_dal,
                                                TO_DATE ('01/01/1900',
                                                         'dd/mm/yyyy')))), --????,
                                p_new_al                     => p_al,
                                p_new_descrizione            => '', --p_descrizione,
                                p_new_indirizzo              => p_indirizzo_dom,
                                p_new_provincia              => p_provincia_dom,
                                p_new_comune                 => p_comune_dom,
                                p_new_cap                    => p_cap_dom,
                                p_new_presso                 => p_presso,
                                p_new_competenza             => p_competenza,
                                p_new_competenza_esclusiva   =>
                                    p_competenza_esclusiva,
                                p_new_version                => '', --p_version,
                                p_new_utente_aggiornamento   => p_utente,
                                p_new_data_aggiornamento     => p_data_agg);
                        EXCEPTION
                            WHEN NO_DATA_FOUND
                            THEN                         -- prima non esisteva
                                IF    p_indirizzo_dom IS NOT NULL
                                   OR p_provincia_dom IS NOT NULL
                                   OR p_comune_dom IS NOT NULL
                                   OR p_cap_dom IS NOT NULL
                                   --               OR p_presso IS NOT NULL -- rev. 25
                                   OR p_tel_dom IS NOT NULL
                                   OR p_fax_dom IS NOT NULL -- ci sono contatti di domicilio
                                THEN
                                    inserimento_recapito_x_dom;
                                END IF;
                        END;
                    END IF;                               -- cambiato qualcosa
                END;

                -- rev. 25 Inizio
                IF        NVL (p_tel_dom, '-1') !=  NVL (v_old_anagrafe_soggetti.tel_DOM, '-1')
                        OR NVL (p_fax_DOM, '-1') != NVL (v_old_anagrafe_soggetti.fax_DOM, '-1')
                THEN
                    -- ricalcolo nuovo dal se il recapito è stato ad esempio storicizzato
                    -- rev. 25 inizio
                    SELECT MAX (id_recapito), MAX (dal)
                      INTO d_id_recapito, v_dal_recapito
                      FROM recapiti
                     WHERE     ni = v_old_anagrafe_soggetti.ni
                           AND al IS NULL
                           AND id_tipo_recapito = 2;

                    -- rev. 25 fine

                    -- rev. 25 Fine
                    --         IF p_tel_dom IS NOT NULL OR p_fax_dom IS NOT NULL -- ci sono contatti di domicilio
                    --         THEN
                    FOR cont IN 1 .. 2
                    LOOP
                        --1 = TELEFONO
                        --2 = FAX
                        d_contatto_valore := NULL;

                        -- rev. 25 inizio
                        IF     CONT = 1
                           AND NVL (p_TEL_DOM, '1') !=
                               NVL (v_old_anagrafe_soggetti.TEL_DOM, '1')
                           AND p_TEL_DOM IS NOT NULL
                        -- rev. 25 inizio
                        THEN
                            d_contatto_valore := p_tel_DOM;
                            d_id_tipo_contatto := 1;
                            d_note := p_note_tel_dom;

                            BEGIN
                                -- rev. 25 inizio
                                SELECT *
                                  INTO d_contatto_attuale
                                  FROM contatti
                                 WHERE     id_recapito = d_id_recapito
                                       AND al IS NULL
                                       AND id_tipo_contatto = 1
                                       -- aggiunto da AD 20/06/2018
                                       AND valore =
                                           v_old_anagrafe_soggetti.tel_dom -- per individuare il record esatto
                                       AND NOT EXISTS
                                               (SELECT 1 -- ma a patto che non esista un record con stesso valore di contatto
                                                  FROM contatti cont2
                                                 WHERE     cont2.id_recapito =
                                                           d_id_recapito
                                                       AND al IS NULL
                                                       AND id_tipo_contatto =
                                                           1
                                                       AND valore =
                                                           d_contatto_valore);
                                d_id_contatto := d_contatto_attuale.id_contatto;
                                -- trovato
                                -- rev. 30 inizio

                                if p_tel_dom is not null then
                                contatti_tpk.upd (
                                    p_new_id_contatto            => d_id_contatto,
                                    p_new_id_recapito            => d_id_recapito,
                                    p_new_dal                    =>
                                        GREATEST (
                                            v_dal_recapito,
                                            GREATEST (
                                                v_new_anagrafici.dal,
                                                NVL (
                                                    p_dal,
                                                    TO_DATE ('01/01/1900',
                                                             'dd/mm/yyyy')))), --rev. 25
                                    p_new_al                     => p_al,
                                    p_new_valore                 => d_contatto_valore,
                                    p_new_id_tipo_contatto       =>
                                        d_id_tipo_contatto,
                                    p_new_note                   => d_note,
                                    p_new_competenza             => p_competenza,
                                    p_new_competenza_esclusiva   =>
                                        p_competenza_esclusiva,
                                    p_new_version                => '', --p_version,
                                    p_new_utente_aggiornamento   => p_utente,
                                    p_new_data_aggiornamento     => p_data_agg);
                                 else -- p_tel_dom nullo
                                contatti_tpk.upd (
                                    p_new_id_contatto            => d_id_contatto,
                                    p_new_id_recapito            => d_id_recapito,
                                    p_new_dal                    => d_contatto_attuale.dal,
                                    p_new_al                     => greatest(nvl(p_al,trunc(sysdate)-1),d_contatto_attuale.dal),
                                    p_new_valore                 => d_contatto_attuale.valore,
                                    p_new_id_tipo_contatto       =>
                                        d_id_tipo_contatto,
                                    p_new_note                   => d_note,
                                    p_new_competenza             => p_competenza,
                                    p_new_competenza_esclusiva   =>
                                        p_competenza_esclusiva,
                                    p_new_version                => '', --p_version,
                                    p_new_utente_aggiornamento   => p_utente,
                                    p_new_data_aggiornamento     => p_data_agg);

                                 end if;-- rev. 30 fine
                            EXCEPTION
                                WHEN NO_DATA_FOUND
                                THEN
                                    IF d_contatto_valore IS NOT NULL
                                    THEN
                                        inserimento_contatto_x_dom;
                                    END IF;
                            END;
                        ELSIF     cont = 2
                              -- rev. 25 inizio
                              AND NVL (p_fax_DOM, '1') !=
                                  NVL (v_old_anagrafe_soggetti.FAX_DOM, '1')
                        -- rev. 25 fine
                        THEN
                            d_contatto_valore := p_fax_DOM;
                            d_id_tipo_contatto := 2;
                            d_note := p_note_fax_dom;

                            BEGIN
                                -- rev. 25 inizio
                                --               SELECT id_contatto
                                --                 INTO d_id_contatto
                                --                 FROM contatti
                                --                WHERE     id_recapito = d_id_recapito
                                --                      AND al IS NULL
                                --                      AND id_tipo_contatto = 2;

                                SELECT *
                                  INTO d_contatto_attuale
                                  FROM contatti cont1
                                 WHERE     id_recapito = d_id_recapito
                                       AND al IS NULL
                                       AND id_tipo_contatto = 2
                                       -- aggiunto da AD 20/06/2018
                                       AND valore =
                                           v_old_anagrafe_soggetti.fax_dom -- per individuare il record esatto
                                       AND NOT EXISTS
                                               (SELECT 1 -- ma a patto che non esista un record con stesso valore di contatto
                                                  FROM contatti cont2
                                                 WHERE     cont2.id_recapito =
                                                           d_id_recapito
                                                       AND al IS NULL
                                                       AND id_tipo_contatto =
                                                           2
                                                       AND valore =
                                                           d_contatto_valore);

                                -- rev. 25 fine
                                -- trovato
                                -- rev. 30 inizio
                                d_id_contatto := d_contatto_attuale.id_contatto;
                                if  p_fax_DOM IS NOT NULL then

                                contatti_tpk.upd (
                                    p_new_id_contatto            => d_id_contatto,
                                    p_new_id_recapito            => d_id_recapito,
                                    p_new_dal                    =>
                                        GREATEST (
                                            v_new_anagrafici.dal,
                                            NVL (
                                                p_dal,
                                                TO_DATE ('01/01/1900',
                                                         'dd/mm/yyyy'))), --????,
                                    p_new_al                     => p_al,
                                    p_new_valore                 => d_contatto_valore,
                                    p_new_id_tipo_contatto       =>
                                        d_id_tipo_contatto,
                                    p_new_note                   => d_note,
                                    p_new_competenza             => p_competenza,
                                    p_new_competenza_esclusiva   =>
                                        p_competenza_esclusiva,
                                    p_new_version                => '', --p_version,
                                    p_new_utente_aggiornamento   => p_utente,
                                    p_new_data_aggiornamento     => p_data_agg);
                               ELSE -- p_fax_dom nullo chiudo

                                contatti_tpk.upd (
                                    p_new_id_contatto            => d_id_contatto,
                                    p_new_id_recapito            => d_id_recapito,
                                    p_new_dal                    => d_contatto_attuale.dal,
                                    p_new_al                     => greatest(nvl(p_al,trunc(sysdate)-1),d_contatto_attuale.dal),
                                    p_new_valore                 => d_contatto_attuale.valore,
                                    p_new_id_tipo_contatto       => d_id_tipo_contatto,
                                    p_new_note                   => d_note,
                                    p_new_competenza             => p_competenza,
                                    p_new_competenza_esclusiva   => p_competenza_esclusiva,
                                    p_new_version                => '', --p_version,
                                    p_new_utente_aggiornamento   => p_utente,
                                    p_new_data_aggiornamento     => p_data_agg);
                               END IF;-- rev. 30 fine
                            EXCEPTION
                                WHEN NO_DATA_FOUND
                                THEN
                                    IF d_contatto_valore IS NOT NULL
                                    THEN
                                        inserimento_contatto_x_dom;
                                    END IF;
                            END;
                        END IF;
                    END LOOP;
                END IF;
            --         END IF;
            END;                                             -- v_dal_recapito
        END IF;

        -- Rev. 20 #33680 Inizio nvl con il vecchio
        anagrafici_pkg.v_aggiornamento_da_package_on := 0;

        INSERT INTO ALLINEA_ANAG_SOGGETTI_TAB tab
            SELECT NVL (v_new_ni, p_ni)
              FROM DUAL
             WHERE NOT EXISTS
                       (SELECT 1
                          FROM ALLINEA_ANAG_SOGGETTI_TAB
                         WHERE ni = NVL (v_new_ni, p_ni));

        ALLINEA_ANAG_SOGGETTI_TABLE (NVL (v_new_ni, p_ni));

        -- Rev. 20 #33680 Fine
        -- rev. 25 inizio
        IF NVL (
               impostazioni.get_preferenza (
                   p_stringa   => 'RegistrazioneOkModificaLineare'),
               'NO') =
           'SI'
        THEN
            DECLARE
                d_err      VARCHAR2 (32000);
                d_err_id   NUMBER := 0;
            BEGIN
                d_err := SUBSTR (SQLERRM, 1, 1940);

                --            ROLLBACK;            -- rev. 045
                SELECT keel_sq.NEXTVAL INTO d_err_id FROM DUAL;

                -- fa commit implicito
                key_error_log_pkg.ins (
                    p_error_id        => d_err_id,
                    p_error_session   => USERENV ('sessionid'),
                    p_error_date      => SYSDATE,
                    p_ERROR_TEXT      =>
                           'ANAGRAFICA OK: update'
                        || ': '
                        || NVL (v_new_ni, p_ni),
                    p_error_user      => USER,
                    p_ERROR_TYPE      => 'E');
            END;
        END IF;

        -- rev. 25 fine
        RETURN d_id_anagrafica;
    EXCEPTION
        WHEN integrity_error
        THEN
            anagrafici_pkg.v_aggiornamento_da_package_on := 0;
            integritypackage.initnestlevel;
            raise_application_error (errno, errmsg, TRUE);
        WHEN OTHERS
        THEN
            anagrafici_pkg.v_aggiornamento_da_package_on := 0;
            integritypackage.initnestlevel;

            IF NVL (
                   impostazioni.get_preferenza (
                       p_stringa   => 'RegistrazioneErroriModificaLineare'),
                   'NO') =
               'SI'
            THEN
                DECLARE
                    d_err      VARCHAR2 (32000);
                    d_err_id   NUMBER := 0;
                BEGIN
                    d_err := SUBSTR (SQLERRM, 1, 1940);

                    --            ROLLBACK;            -- rev. 045
                    SELECT keel_sq.NEXTVAL INTO d_err_id FROM DUAL;

                    -- fa commit implicito
                    key_error_log_pkg.ins (
                        p_error_id        => d_err_id,
                        p_error_session   => USERENV ('sessionid'),
                        p_error_date      => SYSDATE,
                        p_ERROR_TEXT      =>
                               'ANAGRAFICA errore in update'
                            || ': '
                            || NVL (v_new_ni, p_ni)
                            || ' '
                            || d_err,
                        p_error_user      => USER,
                        p_ERROR_TYPE      => 'E');


                    SELECT keel_sq.NEXTVAL INTO d_err_id FROM DUAL;

                    -- fa commit implicito
                    key_error_log_pkg.ins (
                        p_error_id        => d_err_id,
                        p_error_session   => USERENV ('sessionid'),
                        p_error_date      => SYSDATE,
                        p_ERROR_TEXT      =>
                            SUBSTR (
                                   NVL (v_new_ni, p_ni)
                                || ':'
                                || p_ni
                                || '#'
                                || d_id_contatto
                                || '#'
                                || d_id_recapito
                                || '#'
                                || p_dal
                                || '#'
                                || p_al
                                || '#'
                                || p_cognome
                                || '#'
                                || p_nome
                                || '#'
                                || p_sesso
                                || '#'
                                || p_data_nas
                                || '#'
                                || p_provincia_nas
                                || '#'
                                || p_comune_nas
                                || '#'
                                || p_luogo_nas
                                || '#'
                                || p_codice_fiscale
                                || '#'
                                || p_codice_fiscale_estero
                                || '#'
                                || p_partita_iva
                                || '#'
                                || p_cittadinanza
                                || '#'
                                || p_gruppo_ling
                                || '#'
                                || p_competenza
                                || '#'
                                || p_competenza_esclusiva
                                || '#'
                                || p_tipo_soggetto
                                || '#'
                                || p_stato_cee
                                || '#'
                                || p_partita_iva_cee
                                || '#'
                                || p_fine_validita
                                || '#'
                                || p_stato_soggetto
                                || '#'
                                || p_denominazione
                                || '#'
                                || p_note_anag
                                || '#'
                                || p_descrizione_residenza
                                || '#'
                                || p_indirizzo_res
                                || '#'
                                || p_provincia_res
                                || '#'
                                || p_comune_res
                                || '#'
                                || p_cap_res
                                || '#'
                                || p_presso
                                || '#'
                                || p_importanza
                                || '#'
                                || p_mail
                                || '#'
                                || p_note_mail
                                || '#'
                                || p_importanza_mail
                                || '#'
                                || p_tel_res
                                || '#'
                                || p_note_tel_res
                                || '#'
                                || p_importanza_tel_res
                                || '#'
                                || p_fax_res
                                || '#'
                                || p_note_fax_res
                                || '#'
                                || p_importanza_fax_res
                                || '#'
                                || p_descrizione_dom
                                || '#'
                                || p_indirizzo_dom
                                || '#'
                                || p_provincia_dom
                                || '#'
                                || p_comune_dom
                                || '#'
                                || p_cap_dom
                                || '#'
                                || p_tel_dom
                                || '#'
                                || p_note_tel_dom
                                || '#'
                                || p_importanza_tel_dom
                                || '#'
                                || p_fax_dom
                                || '#'
                                || p_note_fax_dom
                                || '#'
                                || p_utente
                                || '#'
                                || p_data_agg
                                || '#'
                                || p_batch,
                                1,
                                2000),
                        p_error_user      => USER,
                        p_ERROR_TYPE      => 'E');
                END;
            END IF;

            RAISE;
    END;

    PROCEDURE chiusura_anagrafica (p_ni   IN ANAGRAFICI.ni%TYPE,
                                   p_al      anagrafici.al%TYPE)
    IS
    BEGIN
        UPDATE anagrafici
           SET al = p_al
         WHERE al IS NULL AND ni = p_ni;
    END;

    FUNCTION get_ultimo_al (p_ni        IN ANAGRAFICI.ni%TYPE,
                            p_dal          anagrafici.dal%TYPE,
                            p_anag_al      anagrafici.al%TYPE)
        RETURN ANAGRAFICI.al%TYPE
    IS                                                        /* SLAVE_COPY */
        /******************************************************************************
         NOME:        get_ultimo_al
         DESCRIZIONE: Getter per attributo al di riga identificata dalla chiave.
         PARAMETRI:   Attributi chiave.
         RITORNA:     ANAGRAFICI.al%type.
         NOTE:        La riga identificata deve essere presente.
         Rev.  Data        Autore  Descrizione.
         008   12/10/2018  SNeg    Correzione x errore in determinazione ultimo al
                                   Messo nullo se è ultimo periodo.
         010   15/10/2018  SNeg   Periodi solo inclusi in validita anagrafica
         013   21/12/2018  SNeg  Correzione controllo periodo incluso in validita anagrafica
         018   26/02/2019  SNeg  Gestita uguaglianza sulle date di dal e al
         026   26/08/2019  Sneg  Velocizzare allineamento
         034   11/11/2019  SNeg  Tempi lunghissimi in aggiornamento contatti Bug #38192
        ******************************************************************************/
        d_result   ANAGRAFICI.al%TYPE;
    BEGIN
        BEGIN -- prova x problema di lentezza a CITTADELLA
        SELECT   distinct
               trunc((dal)) - 1  --??data
        INTO   d_result
        FROM   TUTTI_NI_DAL_RES_DOM_OK ANAG
       WHERE   ni = p_ni
         AND   dal > p_dal
         -- rev 10 inizio       e rev.13
         and   dal <=(select max(nvl(al, to_date('3333333','j'))) from anagrafici where ni = p_ni)
         -- rev 10 fine  e rev. 13
         and   dal = (  select min(dal) from TUTTI_NI_DAL_RES_DOM_OK anag2
                            where anag2.ni = anag.ni
                              and anag2.dal > p_dal) ;
--            SELECT DISTINCT TRUNC ((dal)) - 1                         --??data
--              INTO d_result
--              FROM TUTTI_NI_DAL_RES_DOM_OK ANAG
--             WHERE     ni = p_ni
--                   AND dal > p_dal
--                   -- rev 10 inizio       e rev.13
--                   AND dal < (SELECT MAX (NVL (al, TO_DATE ('3333333', 'j')))
--                                FROM anagrafici
--                               WHERE ni = p_ni)
--                   -- rev 10 fine  e rev. 13
--                   AND NOT EXISTS
--                           (SELECT 1
--                              FROM TUTTI_NI_DAL_RES_DOM_OK anag2
--                             WHERE     anag2.ni = anag.ni
--                                   AND anag2.dal < anag.dal
--                                   AND anag2.dal > p_dal);
        --      SELECT   min(dal) - 1
        --        INTO   d_result
        --        FROM   TUTTI_NI_DAL_RES_DOM_OK ANAG
        --       WHERE   ni = p_ni
        --         AND   dal > p_dal
        --         -- rev 10 inizio       e rev.13
        --         and   dal < (select max(nvl(al, to_date('3333333','j'))) from anagrafici where ni = p_ni)
        --         -- rev 10 fine  e rev. 13
        --;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                BEGIN
                    SELECT DISTINCT al                                --??data
                      INTO d_result
                      FROM anagrafici anag
                     WHERE     ni = p_ni
                           -- rev. 18 inizio
                           AND al >= p_dal
                           --         AND   al > p_dal
                           -- rev. 18 fine
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM anagrafici anag2
                                     WHERE     anag2.ni = anag.ni
                                           AND anag2.dal > anag.dal
                                           AND anag2.al > p_dal);
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        -- rev.8 inizio
                        d_result := TO_DATE (NULL);
                -- rev.8 fine
                END;
        END;

        RETURN d_result;
    END get_ultimo_al;                         -- anagrafici_pkg.get_ultimo_al

    FUNCTION get_dal_attuale_ni (p_ni IN ANAGRAFICI.ni%TYPE)
        RETURN ANAGRAFICI.dal%TYPE
    IS                                                        /* SLAVE_COPY */
        /******************************************************************************
         NOME:        get_dal_attuale_ni
         DESCRIZIONE: Getter per attributo dal di riga identificata dalla chiave.
         PARAMETRI:   Attributi chiave.
         RITORNA:     ANAGRAFICI.dal%type.
         NOTE:        La riga identificata deve essere presente.
        ******************************************************************************/
        d_result   ANAGRAFICI.al%TYPE;
    BEGIN
        BEGIN
            SELECT dal
              INTO d_result
              FROM ANAGRAFICI
             WHERE     ni = p_ni
                   AND TRUNC (SYSDATE) BETWEEN dal
                                           AND NVL (al,
                                                    TO_DATE ('3333333', 'j'));
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                d_result := '';
        END;

        RETURN d_result;
    END get_dal_attuale_ni;

    FUNCTION get_al_attuale_ni (p_ni IN ANAGRAFICI.ni%TYPE)
        RETURN ANAGRAFICI.al%TYPE
    IS                                                        /* SLAVE_COPY */
        /******************************************************************************
         NOME:        get_al_attuale_ni
         DESCRIZIONE: Getter per attributo al di riga identificata dalla chiave.
         PARAMETRI:   Attributi chiave.
         RITORNA:     ANAGRAFICI.dal%type.
         NOTE:        La riga identificata deve essere presente.
        ******************************************************************************/
        d_result   ANAGRAFICI.al%TYPE;
    BEGIN
        BEGIN
            SELECT al
              INTO d_result
              FROM ANAGRAFICI
             WHERE     ni = p_ni
                   AND TRUNC (SYSDATE) BETWEEN dal
                                           AND NVL (al,
                                                    TO_DATE ('3333333', 'j'));
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                d_result := '';
        END;

        RETURN d_result;
    END get_al_attuale_ni;                -- anagrafici_pkg.get_dal_attuale_ni

    FUNCTION is_competenza_ok (
        p_competenza                 IN anagrafici.competenza%TYPE,
        p_competenza_esclusiva       IN anagrafici.competenza_esclusiva%TYPE,
        p_competenza_old             IN anagrafici.competenza%TYPE,
        p_competenza_esclusiva_old   IN anagrafici.competenza_esclusiva%TYPE)
        RETURN AFC_Error.t_error_number
    IS
        /******************************************************************************
         NOME:        is_competenza_ok.
         DESCRIZIONE: Verifica competenza sulla modifica del soggetto.
         PARAMETRI:   p_competenza                IN   competenza
                      p_competenza_esclusiva      IN   competenza esclusiva
                      p_competenza_old            IN   precedente competenza
                      p_competenza_esclusiva_old  IN   precedente competenza esclusiva
         RITORNA:     number
                      se verifica effettuata con successo
                          afc_error.ok (1)
                      altrimenti,
                           codice di errore.
         NOTE:        Verifica la competenza sulla modifica del soggetto secondo le
                      seguenti regole:
                      1. Il soggetto non e' modificabile perche' di competenza di altro
                         progetto (codice s_comp_altrui_number) se:
                         -   e' di competenza di un progetto (p_competenza_old non nullo)
                             e la nuova competenza non e' specificata (p_competenza nullo);
                         -   e' di competenza esclusiva di un progetto diverso da quello
                             passato o su cui lo user che esegue l'operazione non ha
                             competenza;
                         -   si vuole renderlo di competenza esclusiva di un progetto su
                             cui lo user che esegue l'operazione non ha competenza;
                         -   e' di competenza di un progetto con priorita' maggiore.
                      2. Il soggetto non e' modificabile perche' si vuole renderlo di
                         competenza esclusiva ma non si specifica di quale progetto
                         (s_comp_escl_no_progetto_number).
                      Alla descrizione dell'eventuale errore nella riga corrispondente
                      della tabella degli errori viene aggiunto il codice del progetto
                      competente.
         REVISIONI:
         Rev. Data       Autore Descrizione
         ---- ---------- ------ ------------------------------------------------------
        ******************************************************************************/
        d_result         AFC_Error.t_error_number := AFC_Error.ok;
        D_new_priorita   NUMBER;
        D_old_priorita   NUMBER;
        D_messaggio      VARCHAR2 (255);
        d_competenza     anagrafici.competenza%TYPE;
    BEGIN
        init_error_table;

        DECLARE
            d_new_priorita   NUMBER;
            d_old_priorita   NUMBER;
            d_progetto       VARCHAR2 (60);
            d_messaggio      VARCHAR2 (255);
        BEGIN
            IF SUBSTR (NVL (NVL (p_competenza_old, p_competenza), 'xxx'),
                       1,
                       2) <>
               SUBSTR (NVL (p_competenza, 'xxx'), 1, 2)
            THEN
                BEGIN
                    SELECT priorita
                      INTO d_new_priorita
                      FROM ad4_progetti
                     WHERE progetto = p_competenza;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        d_new_priorita := 0;
                END;

                BEGIN
                    SELECT priorita, descrizione
                      INTO d_old_priorita, d_progetto
                      FROM ad4_progetti
                     WHERE progetto = p_competenza_OLD;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        d_old_priorita := 0;
                END;

                -- Se il progetto ha priorita' minore o se il cliente non ha impostato
                -- la priorita' tra i progetti, non permette la modifica
                IF    NVL (d_new_priorita, 0) < NVL (d_old_priorita, 0)
                   OR (d_new_priorita IS NULL AND d_old_priorita IS NULL)
                THEN
                    d_result := s_comp_altrui_number;                       --
                --               raise_application_error
                --                                   (-20999
                --                                  ,    'Soggetto di competenza del progetto '
                --                                    || d_progetto
                --                                    || ' non modificabile !');
                END IF;

                IF NVL (p_competenza_esclusiva_OLD, 'x') = 'E'
                THEN
                    d_result := s_comp_escl_altrui_number;                  --
                --               raise_application_error
                --                                   (-20999
                --                                  ,    'Soggetto di competenza esclusiva del progetto '
                --                                    || d_progetto
                --                                    || ' non modificabile !');
                END IF;
            END IF;
        END;

        IF d_result != afc_error.ok
        THEN
            s_error_table (d_result) :=
                s_error_table (d_result) || ' (' || p_competenza_old || ')';
        END IF;

        RETURN d_result;
    END is_competenza_ok;

    FUNCTION is_modificabile_ok (
        p_ni                         IN anagrafici.ni%TYPE,
        p_dal                        IN anagrafici.dal%TYPE,
        p_competenza                 IN anagrafici.competenza%TYPE,
        p_competenza_esclusiva       IN anagrafici.competenza_esclusiva%TYPE,
        p_competenza_old             IN anagrafici.competenza%TYPE,
        p_competenza_esclusiva_old   IN anagrafici.competenza_esclusiva%TYPE)
        RETURN AFC_Error.t_error_number
    /******************************************************************************
     NOME:        is_modificabile_ok.
     DESCRIZIONE: Verifica competenza sulla modifica del soggetto.
     PARAMETRI:
     RITORNA:     number
                  se verifica effettuata con successo
                      afc_error.ok (1)
                  altrimenti,
                       codice di errore.
     NOTE:
     REVISIONI:
     Rev. Data       Autore Descrizione
     ---- ---------- ------ ------------------------------------------------------
     000  13/06/2018 SN     Prima emissione.
    ******************************************************************************/
    IS
        d_result   AFC_Error.t_error_number := AFC_Error.ok;
    BEGIN
        --      raise_application_error(-20999,'data:' || p_dal);
        d_result :=
            is_competenza_ok (p_competenza,
                              p_competenza_esclusiva,
                              p_competenza_old,
                              p_competenza_esclusiva_old);

        IF d_result = afc_error.ok
        THEN
            -- controllo se ultimo periodo
            -- se ultimo trova solo 1 periodo quindi d_result = 1
            SELECT COUNT (1)
              INTO d_result
              FROM anagrafici
             WHERE     ni = p_ni
                   AND (   p_dal BETWEEN dal
                                     AND NVL (al, TO_DATE ('3333333', 'j'))
                        OR dal > p_dal);
        END IF;

        IF d_result = afc_error.ok
        THEN
            -- controllo personalizzato
            d_result :=
                is_modificabile_personalizzato (p_ni,
                                                p_dal,
                                                p_competenza,
                                                p_competenza_esclusiva,
                                                p_competenza_old,
                                                p_competenza_esclusiva_old);
        END IF;

        RETURN d_result;
    END;

    FUNCTION is_modificabile_ok (p_id_oggetto                 NUMBER,
                                 p_oggetto                    VARCHAR2,
                                 p_competenza                 VARCHAR2,
                                 p_competenza_esclusiva       VARCHAR2,
                                 p_competenza_old             VARCHAR2,
                                 p_competenza_esclusiva_old   VARCHAR2,
                                 p_utente                     VARCHAR2,
                                 p_modulo                     VARCHAR2,
                                 p_istanza                    VARCHAR2,
                                 p_ruolo_accesso              VARCHAR2)
        RETURN AFC_Error.t_error_number
    IS
        /******************************************************************************
         NOME:        is_modificabile_ok.
         DESCRIZIONE: Verifica competenza sulla modifica del soggetto.
         PARAMETRI:  P_competenza = modulo
         RITORNA:     number
                      se verifica effettuata con successo
                          afc_error.ok (1)
                      altrimenti,
                           codice di errore.
         NOTE:
         REVISIONI:
         Rev. Data       Autore Descrizione
         ---- ---------- ------ ------------------------------------------------------
         000  13/06/2018 SN     Prima emissione.
        ******************************************************************************/
        d_result     AFC_Error.t_error_number := AFC_Error.ok;
        v_get_pref   impostazioni.t_impostazioni;
    BEGIN
        v_get_pref := impostazioni.get_preferenza ('RuoliSoloLettura', '');

        IF     UPPER (v_get_pref) IS NOT NULL
           AND INSTR (
                   '$$' || v_get_pref || '$$',
                      '$$'
                   || SUBSTR (p_ruolo_accesso,
                              INSTR (p_ruolo_accesso, '_') + 1)
                   || '$$') >
               0
        THEN
            d_result := 0;
        ELSE
            --      raise_application_error(-20999,'data:' || p_dal);
            --      if p_oggetto = 'CONTATTI' then
            --      raise_application_error(-20999,p_id_oggetto ||':'||
            --                             p_oggetto                  ||':'||
            --                             p_competenza                 ||':'||
            --                             p_competenza_esclusiva       ||':'||
            --                             p_competenza_old             ||':'||
            --                             p_competenza_esclusiva_old   ||':'||
            --                             p_utente                    ||':'||
            --                             p_modulo                      ||':'||
            --                             p_istanza                     ||':'||
            --                             p_ruolo_accesso);
            --      end if;
            IF p_oggetto = 'ANAGRAFICI'
            THEN
                DECLARE
                    v_ni_e_soggetto_struttura   NUMBER
                        := controllo_se_ni_in_struttura (
                               ANAGRAFICI_TPK.get_ni (p_id_oggetto));
                    v_ni                        NUMBER
                        := ANAGRAFICI_TPK.get_ni (p_id_oggetto);
                    v_dal                       DATE
                        := ANAGRAFICI_TPK.get_dal (p_id_oggetto);
                BEGIN
                    IF v_ni_e_soggetto_struttura > 0
                    THEN
                        d_result := afc_error.ok;
                    ELSE
                        d_result :=
                            is_competenza_ok (p_competenza,
                                              p_competenza_esclusiva,
                                              p_competenza_old,
                                              p_competenza_esclusiva_old);

                        IF d_result = afc_error.ok
                        THEN
                            -- controllo se ultimo periodo
                            -- se ultimo trova solo 1 periodo quindi d_result = 1
                            SELECT COUNT (1)
                              INTO d_result
                              FROM anagrafici
                             WHERE     ni = v_ni
                                   AND (   v_dal BETWEEN dal
                                                     AND NVL (
                                                             al,
                                                             TO_DATE (
                                                                 '3333333',
                                                                 'j'))
                                        OR dal > v_dal);
                        END IF;

                        IF d_result = afc_error.ok
                        THEN
                            -- controllo personalizzato
                            d_result :=
                                is_modificabile_personalizzato (
                                    v_ni,
                                    v_dal,
                                    p_competenza,
                                    p_competenza_esclusiva,
                                    p_competenza_old,
                                    p_competenza_esclusiva_old);
                        END IF;
                    END IF;
                END;
            ELSIF p_oggetto = 'RECAPITI'
            THEN
                DECLARE
                    v_ni_e_soggetto_struttura   NUMBER
                        := controllo_se_ni_in_struttura (
                               RECAPITI_TPK.get_ni (p_id_oggetto));
                    v_ni                        NUMBER
                        := RECAPITI_TPK.get_ni (p_id_oggetto);
                    v_dal                       DATE
                        := RECAPITI_TPK.get_dal (p_id_oggetto);
                    v_tipo_recapito             NUMBER
                        := RECAPITI_TPK.get_id_tipo_recapito (p_id_oggetto);
                BEGIN
                    IF v_ni_e_soggetto_struttura > 0
                    THEN
                        d_result := afc_error.ok;

                        IF v_tipo_recapito = 1
                        THEN                                      -- RESIDENZA
                            d_result := 0;
                        END IF;
                    ELSE
                        d_result :=
                            is_competenza_ok (p_competenza,
                                              p_competenza_esclusiva,
                                              p_competenza_old,
                                              p_competenza_esclusiva_old);

                        IF d_result = afc_error.ok
                        THEN
                            -- controllo se ultimo periodo
                            -- se ultimo trova solo 1 periodo quindi d_result = 1
                            SELECT COUNT (1)
                              INTO d_result
                              FROM anagrafici
                             WHERE     ni = v_ni
                                   AND (   v_dal BETWEEN dal
                                                     AND NVL (
                                                             al,
                                                             TO_DATE (
                                                                 '3333333',
                                                                 'j'))
                                        OR dal > v_dal);
                        END IF;

                        IF d_result = afc_error.ok
                        THEN
                            -- controllo personalizzato
                            d_result :=
                                is_modificabile_personalizzato (
                                    v_ni,
                                    v_dal,
                                    p_competenza,
                                    p_competenza_esclusiva,
                                    p_competenza_old,
                                    p_competenza_esclusiva_old);
                        END IF;
                    END IF;
                END;
            ELSIF p_oggetto = 'CONTATTI'
            THEN
                DECLARE
                    v_ni_e_soggetto_struttura   NUMBER
                        := controllo_se_ni_in_struttura (
                               RECAPITI_TPK.get_ni (
                                   contatti_tpk.get_id_recapito (
                                       p_id_oggetto)));
                    v_ni                        NUMBER
                        := RECAPITI_TPK.get_ni (
                               contatti_tpk.get_id_recapito (p_id_oggetto));
                    v_dal                       DATE
                        := RECAPITI_TPK.get_dal (
                               contatti_tpk.get_id_recapito (p_id_oggetto));
                    v_tipo_recapito             NUMBER
                        := RECAPITI_TPK.get_id_tipo_recapito (
                               contatti_tpk.get_id_recapito (p_id_oggetto));
                BEGIN
                    IF v_ni_e_soggetto_struttura > 0
                    THEN
                        d_result :=
                            is_competenza_ok (p_competenza,
                                              p_competenza_esclusiva,
                                              p_competenza_old,
                                              p_competenza_esclusiva_old);

                        IF d_result = afc_error.ok
                        THEN
                            -- controllo se ultimo periodo
                            -- se ultimo trova solo 1 periodo quindi d_result = 1
                            SELECT COUNT (1)
                              INTO d_result
                              FROM anagrafici
                             WHERE     ni = v_ni
                                   AND (   v_dal BETWEEN dal
                                                     AND NVL (
                                                             al,
                                                             TO_DATE (
                                                                 '3333333',
                                                                 'j'))
                                        OR dal > v_dal);
                        END IF;

                        IF d_result = afc_error.ok
                        THEN
                            -- controllo personalizzato
                            d_result :=
                                is_modificabile_personalizzato (
                                    v_ni,
                                    v_dal,
                                    p_competenza,
                                    p_competenza_esclusiva,
                                    p_competenza_old,
                                    p_competenza_esclusiva_old);
                        END IF;
                    END IF;
                END;
            END IF;
        END IF;

        RETURN d_result;
    END;

    FUNCTION is_inseribile_ok (p_id_oggetto                 NUMBER,
                               p_oggetto                    VARCHAR2,
                               p_competenza                 VARCHAR2,
                               p_competenza_esclusiva       VARCHAR2,
                               p_competenza_old             VARCHAR2,
                               p_competenza_esclusiva_old   VARCHAR2)
        RETURN AFC_Error.t_error_number
    IS
        /******************************************************************************
         NOME:        is_inseribile_ok.
         DESCRIZIONE: Verifica competenza sulla modifica del soggetto.
         PARAMETRI:
         RITORNA:     number
                      se verifica effettuata con successo
                          afc_error.ok (1)
                      altrimenti,
                           codice di errore.
         NOTE:
         REVISIONI:
         Rev. Data       Autore Descrizione
         ---- ---------- ------ ------------------------------------------------------
         000  13/06/2018 SN     Prima emissione.
        ******************************************************************************/
        d_result   AFC_Error.t_error_number := AFC_Error.ok;
    BEGIN
        RETURN d_result;
    END;

    FUNCTION is_inseribile_ok (p_utente                 VARCHAR2,
                               p_oggetto                VARCHAR2,
                               p_id_oggetto_padre       NUMBER,
                               p_competenza             VARCHAR2,
                               p_competenza_esclusiva   VARCHAR2,
                               p_modulo                 VARCHAR2,
                               p_istanza                VARCHAR2,
                               p_ruolo_accesso          VARCHAR2)
        RETURN AFC_Error.t_error_number
    IS
        /******************************************************************************
         NOME:        is_inseribile_ok.
         DESCRIZIONE: Verifica competenza sulla modifica del soggetto.
         PARAMETRI:  ATTENZIONE: il ruolo che viene passato è quello della ad4_v_utenti_ruoli
                     modulo || '_' || ruolo.
                     p_oggetto   tipologia di oggetto, tipo RECAPITI, CONTATTI
                     p_id_oggetto_padre id_anagrafica di riferimento
         RITORNA:     number
                      se verifica effettuata con successo
                          afc_error.ok (1)
                      altrimenti,
                           codice di errore.
         NOTE:
         REVISIONI:
         Rev. Data       Autore Descrizione
         ---- ---------- ------ ------------------------------------------------------
         000  13/06/2018 SN     Prima emissione.
         035  28/01/2020 Sneg  Gestire parametro x abilitare aggiunta recapiti/contatti x IPA Feature #40221
        ******************************************************************************/
        d_result     AFC_Error.t_error_number := AFC_Error.ok;
        v_get_pref   impostazioni.t_impostazioni;
    BEGIN
        --      raise_application_error(-20999,'ruolo accesso' || p_ruolo_accesso);
        v_get_pref := impostazioni.get_preferenza ('RuoliSoloLettura', '');

        IF     UPPER (v_get_pref) IS NOT NULL
           AND INSTR (
                   '$$' || v_get_pref || '$$',
                      '$$'
                   || SUBSTR (p_ruolo_accesso,
                              INSTR (p_ruolo_accesso, '_') + 1)
                   || '$$') >
               0
        THEN
            d_result := 0;
        END IF;
        -- rev. 35 inizio
        if d_result = AFC_Error.ok then
--           -- controllo se impostato nel registro che non si devono modificare i record
--           -- relativi a enti di Struttura Organizzativa (solitamente scarico IPA).
           v_get_pref := upper(nvl(impostazioni.get_preferenza ('NOinserimentoRCEntiSO', ''),'NO'));
           if v_get_pref = 'SI' and  p_oggetto in('RECAPITI', 'CONTATTI')
           and anagrafici_pkg.controllo_se_ni_in_struttura(anagrafici_tpk.get_ni(p_id_oggetto_padre))= 1
              then
--              -- non sono ammesse modifiche e soggetto deriva da Struttura
             d_result := 2;
           end if;
        end if;
        -- rev. 35 fine

        RETURN d_result;
    END;

    FUNCTION get_rows (p_QBE                     IN NUMBER DEFAULT 0,
                       p_other_condition         IN VARCHAR2 DEFAULT NULL,
                       p_order_by                IN VARCHAR2 DEFAULT NULL,
                       p_extra_columns           IN VARCHAR2 DEFAULT NULL,
                       p_extra_condition         IN VARCHAR2 DEFAULT NULL,
                       p_id_anagrafica           IN VARCHAR2 DEFAULT NULL,
                       p_ni                      IN VARCHAR2 DEFAULT NULL,
                       p_dal                     IN VARCHAR2 DEFAULT NULL,
                       p_al                      IN VARCHAR2 DEFAULT NULL,
                       p_cognome                 IN VARCHAR2 DEFAULT NULL,
                       p_nome                    IN VARCHAR2 DEFAULT NULL,
                       p_sesso                   IN VARCHAR2 DEFAULT NULL,
                       p_data_nas                IN VARCHAR2 DEFAULT NULL,
                       p_provincia_nas           IN VARCHAR2 DEFAULT NULL,
                       p_comune_nas              IN VARCHAR2 DEFAULT NULL,
                       p_luogo_nas               IN VARCHAR2 DEFAULT NULL,
                       p_codice_fiscale          IN VARCHAR2 DEFAULT NULL,
                       p_codice_fiscale_estero   IN VARCHAR2 DEFAULT NULL,
                       p_partita_iva             IN VARCHAR2 DEFAULT NULL,
                       p_cittadinanza            IN VARCHAR2 DEFAULT NULL,
                       p_gruppo_ling             IN VARCHAR2 DEFAULT NULL,
                       p_competenza              IN VARCHAR2 DEFAULT NULL,
                       p_competenza_esclusiva    IN VARCHAR2 DEFAULT NULL,
                       p_tipo_soggetto           IN VARCHAR2 DEFAULT NULL,
                       p_stato_cee               IN VARCHAR2 DEFAULT NULL,
                       p_partita_iva_cee         IN VARCHAR2 DEFAULT NULL,
                       p_fine_validita           IN VARCHAR2 DEFAULT NULL,
                       p_stato_soggetto          IN VARCHAR2 DEFAULT NULL,
                       p_denominazione           IN VARCHAR2 DEFAULT NULL,
                       p_note                    IN VARCHAR2 DEFAULT NULL,
                       p_version                 IN VARCHAR2 DEFAULT NULL,
                       p_utente                  IN VARCHAR2 DEFAULT NULL,
                       p_data_agg                IN VARCHAR2 DEFAULT NULL)
        RETURN AFC.t_ref_cursor
    IS
    BEGIN
        RETURN anagrafici_tpk.get_rows (p_QBE,
                                        p_other_condition,
                                        p_order_by,
                                        p_extra_columns,
                                        p_extra_condition,
                                        p_id_anagrafica,
                                        p_ni,
                                        p_dal,
                                        p_al,
                                        p_cognome,
                                        p_nome,
                                        p_sesso,
                                        p_data_nas,
                                        p_provincia_nas,
                                        p_comune_nas,
                                        p_luogo_nas,
                                        p_codice_fiscale,
                                        p_codice_fiscale_estero,
                                        p_partita_iva,
                                        p_cittadinanza,
                                        p_gruppo_ling,
                                        p_competenza,
                                        p_competenza_esclusiva,
                                        p_tipo_soggetto,
                                        p_stato_cee,
                                        p_partita_iva_cee,
                                        p_fine_validita,
                                        p_stato_soggetto,
                                        p_denominazione,
                                        p_note,
                                        p_version,
                                        p_utente,
                                        p_data_agg);
    END;

    /* END get_rows */
    PROCEDURE ANAGRAFICI_PI /******************************************************************************
                             NOME:        ANAGRAFICI_PI
                             DESCRIZIONE: Procedure for Check REFERENTIAL Integrity
                                                     at INSERT on Table ANAGRAFICI
                             ARGOMENTI:   Rigenerati in automatico.
                             ECCEZIONI:  -20002, Non esiste riferimento su TABLE
                                         -20008, Numero di CHILD assegnato a TABLE non ammesso
                             ANNOTAZIONI: Richiamata da Trigger ANAGRAFICI_TIU
                             REVISIONI:
                             Rev. Data       Autore Descrizione
                             ---- ---------- ------ ------------------------------------------------------
                                                    Generata in automatico.
                            024  30/04/2019  SNeg  Comune e Provincia entrambi valorizzati o nulli Bug #34514
                            ******************************************************************************/
                            (new_provincia_nas   IN NUMBER,
                             new_comune_nas      IN NUMBER,
                             new_tipo_soggetto   IN VARCHAR)
    IS
        integrity_error   EXCEPTION;
        errno             INTEGER;
        errmsg            CHAR (200);
        dummy             INTEGER;
        FOUND             BOOLEAN;
        CARDINALITY       INTEGER;
        mutating          EXCEPTION;
        PRAGMA EXCEPTION_INIT (mutating, -4091);
        d_result          AFC_Error.t_error_number;

        --  Dichiarazione di InsertChildParentExist per la tabella padre "AD4_COMUNI"
        CURSOR cpk3_ANAGRAFICI (var_provincia_nas   NUMBER,
                                var_comune_nas      NUMBER)
        IS
            SELECT 1
              FROM AD4_COMUNI
             WHERE     PROVINCIA_STATO = var_provincia_nas
                   AND COMUNE = var_comune_nas
                   AND var_provincia_nas IS NOT NULL
                   AND var_provincia_nas > 0
                   AND var_provincia_nas != -999 -- valore usato dal WS in caso di decodifica non trovata
                   AND var_comune_nas != -999 -- valore usato dal WS in caso di decodifica non trovata
                   AND var_comune_nas IS NOT NULL;

        --  Dichiarazione di InsertChildParentExist per la tabella padre "TIPI_SOGGETTO"
        CURSOR cpk4_ANAGRAFICI (var_tipo_soggetto VARCHAR)
        IS
            SELECT 1
              FROM TIPI_SOGGETTO
             WHERE     TIPO_SOGGETTO = var_tipo_soggetto
                   AND var_tipo_soggetto IS NOT NULL;

        --  Dichiarazione UpdateChildParentExist constraint per la tabella "AD4_PROVINCE"
        CURSOR cpk5_provincia (var_provincia NUMBER)
        IS
            SELECT 1
              FROM AD4_province
             WHERE PROVINCIA = var_provincia AND var_provincia IS NOT NULL;
    BEGIN
        IF NVL (anagrafici_pkg.trasco, 0) != 1
        THEN                         -- NON sono in trasco  faccio i controlli
            BEGIN                               -- Check REFERENTIAL Integrity
                --     raise_application_error(-20999,'val prov:' || new_provincia_nas ||' comune:'|| new_comune_nas);
                BEGIN --  Parent "AD4_COMUNI" deve esistere quando si inserisce su "ANAGRAFICI"
                    IF (    NEW_PROVINCIA_NAS IS NOT NULL
                        AND                        --new_provincia_nas > 0 and
                            NEW_COMUNE_NAS IS NOT NULL)
                    -- rev. 24 inizio
                    --             or (new_comune_nas is not null and new_provincia_nas is null) -- posso passare solo il comune
                    -- rev. 24 fine
                    THEN
                        OPEN cpk3_ANAGRAFICI (NEW_PROVINCIA_NAS,
                                              NEW_COMUNE_NAS);

                        FETCH cpk3_ANAGRAFICI INTO dummy;

                        FOUND := cpk3_ANAGRAFICI%FOUND;

                        CLOSE cpk3_ANAGRAFICI;

                        IF NOT FOUND
                        THEN
                            errno := -20002;
                            errmsg := si4.get_error ('A10021'); --|| ' La registrazione Anagrafe Soggetti non puo'' essere inserita.';
                            RAISE integrity_error;
                        END IF;
                    -- rev. 24 inizio
                    ELSIF    (    NEW_PROVINCIA_NAS IS NOT NULL
                              AND NEW_COMUNE_NAS IS NULL)
                          OR (    NEW_PROVINCIA_NAS IS NULL
                              AND NEW_COMUNE_NAS IS NOT NULL)
                    THEN
                        errno := -20002;
                        errmsg := si4.get_error ('A10041'); --|| ' Comune e Provincia: entrambi presenti o entrambi vuoti';
                        RAISE integrity_error;
                    -- rev. 24 fine
                    END IF;
                EXCEPTION
                    WHEN MUTATING
                    THEN
                        NULL;           -- Ignora Check su Relazioni Ricorsive
                END;

                BEGIN --  Parent "AD4_PROVINCE" deve esistere quando si modifica "RECAPITI"
                    IF (    NEW_PROVINCIA_nas IS NOT NULL
                        AND --NEW_PROVINCIA > 0 AND -- se codice non trovato da web service viene passato -999
                            NEW_COMUNE_nas IS NULL)
                    THEN
                        OPEN cpk5_provincia (NEW_PROVINCIA_nas);

                        FETCH cpk5_provincia INTO dummy;

                        FOUND := cpk5_provincia%FOUND;

                        CLOSE cpk5_provincia;

                        IF NOT FOUND
                        THEN
                            errno := -20003;
                            errmsg := si4.get_error ('A10091'); -- || ' La registrazione non puo'' essere inserita.';
                            RAISE integrity_error;
                        END IF;
                    END IF;
                EXCEPTION
                    WHEN MUTATING
                    THEN
                        NULL;           -- Ignora Check su Relazioni Ricorsive
                END;

                BEGIN --  Parent "TIPI_SOGGETTO" deve esistere quando si inserisce su "ANAGRAFICI"
                    IF NEW_TIPO_SOGGETTO IS NOT NULL
                    THEN
                        OPEN cpk4_ANAGRAFICI (NEW_TIPO_SOGGETTO);

                        FETCH cpk4_ANAGRAFICI INTO dummy;

                        FOUND := cpk4_ANAGRAFICI%FOUND;

                        CLOSE cpk4_ANAGRAFICI;

                        IF NOT FOUND
                        THEN
                            errno := -20002;
                            errmsg := si4.get_error ('A10054'); -- || ' La registrazione Anagrafe Soggetti non puo'' essere inserita.';
                            RAISE integrity_error;
                        END IF;
                    END IF;
                EXCEPTION
                    WHEN MUTATING
                    THEN
                        NULL;           -- Ignora Check su Relazioni Ricorsive
                END;

                NULL;
            END;
        END IF;                                          -- NON sono in trasco
    EXCEPTION
        WHEN integrity_error
        THEN
            IntegrityPackage.InitNestLevel;
            raise_application_error (errno, errmsg);
        WHEN OTHERS
        THEN
            IntegrityPackage.InitNestLevel;
            RAISE;
    END;

    /* End Procedure: ANAGRAFICI_PI */
    PROCEDURE ANAGRAFICI_Pu /******************************************************************************
                             NOME:        ANAGRAFICI_PU
                             DESCRIZIONE: Procedure for Check REFERENTIAL Integrity
                                                     at UPDATE on Table ANAGRAFICI
                             ARGOMENTI:   Rigenerati in automatico.
                             ECCEZIONI:  -20001, Informazione COLONNA non modificabile
                                         -20003, Non esiste riferimento su PARENT TABLE
                                         -20004, Identificazione di TABLE non modificabile
                                         -20005, Esistono riferimenti su CHILD TABLE
                             ANNOTAZIONI: Richiamata da Trigger ANAGRAFICI_TIU
                             REVISIONI:
                             Rev. Data       Autore Descrizione
                             ---- ---------- ------ ------------------------------------------------------
                              002 13/02/2018 SN     Controlli non effettuati in trasco
                              024 30/04/2019 SNeg   Comune e Provincia entrambi valorizzati o nulli Bug #34514
                            ******************************************************************************/
                            (old_ni              IN NUMBER,
                             old_dal             IN DATE,
                             old_provincia_nas   IN NUMBER,
                             old_comune_nas      IN NUMBER,
                             old_tipo_soggetto   IN VARCHAR,
                             new_ni              IN NUMBER,
                             new_dal             IN DATE,
                             new_provincia_nas   IN NUMBER,
                             new_comune_nas      IN NUMBER,
                             new_tipo_soggetto   IN VARCHAR)
    IS
        integrity_error   EXCEPTION;
        errno             INTEGER;
        errmsg            CHAR (200);
        dummy             INTEGER;
        FOUND             BOOLEAN;
        oggetto           VARCHAR2 (200);
        motivo_blocco     VARCHAR2 (200);
        seq               NUMBER;
        mutating          EXCEPTION;
        PRAGMA EXCEPTION_INIT (mutating, -4091);
        d_result          AFC_Error.t_error_number;

        --  Dichiarazione UpdateChildParentExist constraint per la tabella "AD4_COMUNI"
        CURSOR cpk3_ANAGRAFICI (var_provincia_nas   NUMBER,
                                var_comune_nas      NUMBER)
        IS
            SELECT 1
              FROM AD4_COMUNI
             WHERE     PROVINCIA_STATO = var_provincia_nas
                   AND var_provincia_nas > 0
                   AND var_provincia_nas != -999 -- valore usato dal WS in caso di decodifica non trovata
                   AND var_comune_nas != -999 -- valore usato dal WS in caso di decodifica non trovata
                   AND COMUNE = var_comune_nas
                   AND var_provincia_nas IS NOT NULL
                   AND var_comune_nas IS NOT NULL;

        --  Dichiarazione UpdateChildParentExist constraint per la tabella "TIPI_SOGGETTO"
        CURSOR cpk4_ANAGRAFICI (var_tipo_soggetto VARCHAR)
        IS
            SELECT 1
              FROM TIPI_SOGGETTO
             WHERE     TIPO_SOGGETTO = var_tipo_soggetto
                   AND var_tipo_soggetto IS NOT NULL;

        --  Declaration of UpdateParentRestrict constraint for "XX4_ANAGRAFICI"
        CURSOR cfk1_ANAGRAFICI (var_ni NUMBER, var_dal DATE)
        IS
            SELECT oggetto, motivo_blocco
              FROM XX4_ANAGRAFICI
             WHERE     ni = var_ni
                   AND dal = var_dal
                   AND var_ni IS NOT NULL
                   AND var_dal IS NOT NULL;

        --  Dichiarazione UpdateChildParentExist constraint per la tabella "AD4_PROVINCE"
        CURSOR cpk4_provincia (var_provincia NUMBER)
        IS
            SELECT 1
              FROM AD4_province
             WHERE PROVINCIA = var_provincia AND var_provincia IS NOT NULL;
    BEGIN
        BEGIN                                   -- Check REFERENTIAL Integrity
            --  Chiave di "ANAGRAFICI" non modificabile se esistono referenze su "XX4_ANAGRAFICI"
            OPEN cfk1_ANAGRAFICI (OLD_NI, OLD_DAL);

            FETCH cfk1_ANAGRAFICI INTO oggetto, motivo_blocco;

            FOUND := cfk1_ANAGRAFICI%FOUND;

            CLOSE cfk1_ANAGRAFICI;

            IF FOUND
            THEN
                IF    (OLD_NI != NEW_NI)
                   OR (OLD_DAL != NEW_DAL)
                   OR (motivo_blocco = 'R')
                THEN
                    errno := -20005;
                    errmsg :=
                        si4.get_error ('A10044') || ' (' || oggetto || ').'; -- La registrazione non e'' modificabile.';

                    IF motivo_blocco = 'R'
                    THEN
                        errmsg :=
                               errmsg
                            || '(motivo blocco: '
                            || motivo_blocco
                            || ')';
                    END IF;

                    RAISE integrity_error;
                END IF;
            END IF;
        END;

        BEGIN
            seq := Integritypackage.GetNestLevel;

            BEGIN --  Parent "AD4_COMUNI" deve esistere quando si modifica "ANAGRAFICI"
                IF (    NEW_PROVINCIA_NAS IS NOT NULL
                    AND                            --NEW_PROVINCIA_NAS > 0 AND
                        NEW_COMUNE_NAS IS NOT NULL
                    AND (seq = 0)
                    AND ((   NEW_PROVINCIA_NAS != OLD_PROVINCIA_NAS
                          OR (OLD_PROVINCIA_NAS IS NULL)
                          OR (   NEW_COMUNE_NAS != OLD_COMUNE_NAS
                              OR OLD_COMUNE_NAS IS NULL))))
                --indicato solo il comune
                -- or (new_comune_nas is not null and new_provincia_nas is null) -- rev. 24
                -- indicata solo la provincia
                -- rev. 24 inizio non posso indicare solo provincia o solo comune
                --           OR (new_provincia_NAS is not null and new_comune_NAS is null
                --              and (new_provincia_NAS != old_provincia_NAS
                --                   and old_comune_NAS is not null)) -- cambiato qualcosa
                -- rev.24 fine
                THEN
                    OPEN cpk3_ANAGRAFICI (NEW_PROVINCIA_NAS, NEW_COMUNE_NAS);

                    FETCH cpk3_ANAGRAFICI INTO dummy;

                    FOUND := cpk3_ANAGRAFICI%FOUND;

                    CLOSE cpk3_ANAGRAFICI;

                    IF NOT FOUND
                    THEN
                        errno := -20003;
                        errmsg := si4.get_error ('A10021') || '(nascita)'; --|| ' La registrazione Anagrafe Soggetti non e'' modificabile.';
                        RAISE integrity_error;
                    END IF;
                -- rev. 24 inizio
                ELSIF    (    NEW_PROVINCIA_NAS IS NOT NULL
                          AND NEW_COMUNE_NAS IS NULL)
                      OR (    NEW_PROVINCIA_NAS IS NULL
                          AND NEW_COMUNE_NAS IS NOT NULL)
                THEN
                    errno := -20002;
                    errmsg := si4.get_error ('A10041'); --|| ' Comune e Provincia: entrambi presenti o entrambi vuoti';
                    RAISE integrity_error;
                -- rev. 24 fine
                END IF;
            EXCEPTION
                WHEN MUTATING
                THEN
                    NULL;               -- Ignora Check su Relazioni Ricorsive
            END;

            BEGIN --  Parent "AD4_PROVINCE" deve esistere quando si modifica "RECAPITI"
                IF (NEW_PROVINCIA_nas IS NOT NULL AND --NEW_PROVINCIA > 0 AND -- se codice non trovato da web service viene passato -999
                                                      NEW_COMUNE_nas IS NULL)
                THEN                                     -- comune non passato
                    OPEN cpk4_provincia (NEW_PROVINCIA_nas);

                    FETCH cpk4_provincia INTO dummy;

                    FOUND := cpk4_provincia%FOUND;

                    CLOSE cpk4_provincia;

                    IF NOT FOUND
                    THEN
                        errno := -20003;
                        errmsg := si4.get_error ('A10091') || '(nascita)'; -- || ' La registrazione non puo'' essere inserita.';
                        RAISE integrity_error;
                    END IF;
                END IF;
            EXCEPTION
                WHEN MUTATING
                THEN
                    NULL;               -- Ignora Check su Relazioni Ricorsive
            END;

            BEGIN --  Parent "TIPI_SOGGETTO" deve esistere quando si modifica "ANAGRAFICI"
                IF     NEW_TIPO_SOGGETTO IS NOT NULL
                   AND (seq = 0)
                   AND ((   NEW_TIPO_SOGGETTO != OLD_TIPO_SOGGETTO
                         OR OLD_TIPO_SOGGETTO IS NULL))
                THEN
                    OPEN cpk4_ANAGRAFICI (NEW_TIPO_SOGGETTO);

                    FETCH cpk4_ANAGRAFICI INTO dummy;

                    FOUND := cpk4_ANAGRAFICI%FOUND;

                    CLOSE cpk4_ANAGRAFICI;

                    IF NOT FOUND
                    THEN
                        errno := -20003;
                        errmsg := si4.get_error ('A10054'); -- || ' La registrazione Anagrafe Soggetti non e'' modificabile.';
                        RAISE integrity_error;
                    END IF;
                END IF;
            EXCEPTION
                WHEN MUTATING
                THEN
                    NULL;               -- Ignora Check su Relazioni Ricorsive
            END;
        END;
    EXCEPTION
        WHEN integrity_error
        THEN
            Integritypackage.InitNestLevel;
            RAISE_APPLICATION_ERROR (errno, errmsg);
        WHEN OTHERS
        THEN
            Integritypackage.InitNestLevel;
            RAISE;
    END;

    /* End Procedure: ANAGRAFICI_PU */
    PROCEDURE ANAGRAFICI_PD /******************************************************************************
                             NOME:        ANAGRAFICI_PD
                             DESCRIZIONE: Procedure for Check REFERENTIAL Integrity
                                                     at DELETE on Table ANAGRAFICI
                             ARGOMENTI:   Rigenerati in automatico.
                             ECCEZIONI:  -20006, Esistono riferimenti su CHILD TABLE
                             ANNOTAZIONI: Richiamata da Trigger ANAGRAFICI_TD
                             REVISIONI:
                             Rev. Data       Autore Descrizione
                             ---- ---------- ------ ------------------------------------------------------
                            ******************************************************************************/
                            (old_ni    IN NUMBER,
                             old_dal   IN DATE,
                             old_al    IN DATE)
    IS
        integrity_error   EXCEPTION;
        errno             INTEGER;
        errmsg            CHAR (200);
        dummy             INTEGER;
        FOUND             BOOLEAN;
        oggetto           VARCHAR2 (200);

        --  Declaration of DeleteParentRestrict constraint for "XX4_ANAGRAFICI"
        CURSOR cfk1_anagrafici (var_ni NUMBER, var_dal DATE, var_al DATE)
        IS
            SELECT oggetto
              FROM XX4_ANAGRAFICI
             WHERE     ni = var_ni
                   AND dal BETWEEN var_dal
                               AND NVL (var_al, TO_DATE ('3333333', 'j'))
                   AND var_ni IS NOT NULL
                   AND var_dal IS NOT NULL
            UNION
            SELECT oggetto
              FROM XX4_ANAGRAFICI
             WHERE ni = var_ni AND var_ni IS NOT NULL AND var_dal IS NULL; -- se dal e' nullo nessuna registrazione e' eliminabile

        CURSOR cfk2_anagrafici (var_ni NUMBER, var_dal DATE, var_al DATE)
        IS
            SELECT 1
              FROM RECAPITI
             WHERE     ni = var_ni
                   AND var_ni IS NOT NULL
                   AND dal BETWEEN var_dal
                               AND NVL (var_al, TO_DATE ('3333333', 'j'))
                   AND var_dal IS NOT NULL;
    BEGIN
        BEGIN                                   -- Check REFERENTIAL Integrity
            --  Cannot delete parent "ANAGRAFICI" if children still exist in "XX4_ANAGRAFICI"
            OPEN cfk1_anagrafici (OLD_NI, OLD_DAL, OLD_AL);

            FETCH cfk1_anagrafici INTO oggetto;

            FOUND := cfk1_anagrafici%FOUND;

            CLOSE cfk1_anagrafici;

            IF FOUND
            THEN
                errno := -20006;
                errmsg := si4.get_error ('A10044') || ' (' || oggetto || ').'; -- La registrazione non e'' cancellabile.';
                RAISE integrity_error;
            END IF;

            NULL;
        END;

        BEGIN                                   -- Check REFERENTIAL Integrity
            --  Cannot delete parent "ANAGRAFICI" if children still exist in "RECAPITI"
            OPEN cfk2_anagrafici (OLD_NI, OLD_DAL, OLD_AL);

            FETCH cfk2_anagrafici INTO oggetto;

            FOUND := cfk2_anagrafici%FOUND;

            CLOSE cfk2_anagrafici;

            IF FOUND
            THEN
                errno := -20006;
                errmsg := si4.get_error ('A10048') || ' (' || oggetto || ').'; -- La registrazione non e'' cancellabile.';
                RAISE integrity_error;
            END IF;

            NULL;
        END;
    EXCEPTION
        WHEN integrity_error
        THEN
            IntegrityPackage.InitNestLevel;
            raise_application_error (errno, errmsg);
        WHEN OTHERS
        THEN
            IntegrityPackage.InitNestLevel;
            RAISE;
    END;

    /* End Procedure: ANAGRAFICI_PD */
    PROCEDURE ANAGRAFICI_RRI /******************************************************************************
                              NOME:        Anagrafici_Rri
                              DESCRIZIONE: Gestisce la storicizzazione dei dati di un soggetto:
                                           - aggiorna la data di fine validita' dell'ultima registrazione
                                             storica.
                                             Le date di validità sono comprensive di ore, minuti e secondi.
                              ARGOMENTI:   p_ni  IN number Numero Individuale del soggetto.
                                           p_dal IN date   Data di inizio validita' del soggetto.
                              ECCEZIONI:
                              ANNOTAZIONI: la procedure viene lanciata in Post Event dal trigger
                                           ANAGRAFICI_TIU in seguito all'inserimento di un nuovo
                                           record.
                              REVISIONI:
                              Rev. Data       Autore Descrizione
                              ---- ---------- ------ ------------------------------------------------------
                              0    09/05/2017 SNeg    Prima emissione
                              1    13/02/2018 SN     Controlli non effettuati in trasco
                              029  17/09/2019  SNeg  RRI togliere nvl in verifica di periodo già chiuso con competenza P
                             ******************************************************************************/
                             (p_ni                     IN NUMBER,
                              p_dal                    IN DATE,
                              p_competenza             IN VARCHAR2,
                              p_competenza_esclusiva   IN VARCHAR2,
                              p_cognome                IN VARCHAR2,
                              p_nome                   IN VARCHAR2)
    IS
        dDalStorico            DATE;
        dCognomeStorico        VARCHAR2 (2000);
        dNomeStorico           VARCHAR2 (2000);
        d_al                   DATE;
        dCompetenza            VARCHAR2 (100);
        dCompetenzaEsclusiva   VARCHAR2 (10);
        d_result               AFC_Error.t_error_number;
    BEGIN
        IF NVL (anagrafici_pkg.trasco, 0) != 1
        THEN                         -- NON sono in trasco  faccio i controlli
            --RAISE_APPLICATION_ERROR(-20999,'controllo soggetti storici ' );
            SELECT MAX (al) -- rev. 29
              INTO d_al
              FROM ANAGRAFICI
             WHERE     ni = p_ni
                   AND p_dal BETWEEN dal AND NVL (al, TRUNC (SYSDATE))
                   AND SUBSTR (NVL (competenza, 'xxx'), 1, 2) <>
                       SUBSTR (NVL (p_competenza, 'xxx'), 1, 2)
                   AND competenza_esclusiva = 'P';

            IF d_al IS NOT NULL
            THEN
                RAISE_APPLICATION_ERROR (
                    -20999,
                       si4.get_error ('A10046')
                    || ' precedenti al '
                    || TO_CHAR (d_al, 'dd/mm/yyyy')
                    || ' non consentita. Soggetto storico di competenza parziale di altro progetto.');
            END IF;

            DECLARE
                v_num_sogg   NUMBER;
                v_min_dal    DATE;
                v_max_dal    DATE;
            BEGIN
                SELECT COUNT (*), MIN (dal) min_dal, MAX (dal) max_dal
                  INTO v_num_sogg, v_min_dal, v_max_dal
                  FROM anagrafici
                 WHERE ni = p_ni;
            -- RAISE_APPLICATION_ERROR(-20999,'controllo soggetti storici ' || p_ni||' dal:' || p_dal || ' min_dal' || v_min_dal|| ' max_dal' || v_max_dal);
            END;

            -- NON si può cancellare anche se incastro un periodo nel mezzo
            /*
           FOR sogg_storico IN ( SELECT ni, dal, competenza, competenza_esclusiva
                                   FROM ANAGRAFICI
                                  WHERE ni = p_ni
                                    AND (dal > p_dal
                                     OR ( dal = p_dal AND al IS NOT NULL))
                                   -- mod Stefania
                                    AND not exists (select 1
                                                      from anagrafici anag
                                                     where anag.ni = anagrafici.ni
                                                       and dal < anagrafici.dal
                                                       and anag.dal != p_dal
                                                       and anag.rowid != anagrafici.rowid)
                                   -- fine mod Stefania x verificare che cambio il primo
                               )
           LOOP
              d_result := anagrafici_pkg.is_competenza_ok
                ( p_competenza=>p_competenza
                , p_competenza_esclusiva =>p_competenza_esclusiva
                , p_competenza_old => sogg_storico.competenza
                , p_competenza_esclusiva_old => sogg_storico.competenza_esclusiva
                ) ;
              IF not ( d_result = AFC_Error.ok )
               then
                  anagrafici_pkg.raise_error_message(d_result);
              ELSE
                 -- Elimina Registrazioni da anagrafici con DAL >= nuovo DAL
                 BEGIN
        --               RAISE_APPLICATION_ERROR(-20999,'cancello' || p_ni||' dal:' || sogg_storico.dal);
                    DELETE ANAGRAFICI
                     WHERE ni = sogg_storico.ni
                       AND dal = sogg_storico.dal
                    ;
                 EXCEPTION WHEN OTHERS THEN
                    RAISE_APPLICATION_ERROR(-20999,si4.get_error('A10046')
                    --'Modifica registrazioni storiche.'
                    --Modifica di registrazione storica non consentita.
                    ||SUBSTR(SQLERRM,5));
                 END;
              END IF;
           END LOOP;
           */
            --      RAISE_APPLICATION_ERROR(-20999,'fuori' || p_ni||' dal:' || p_dal);
            -- Cerca eventuali Registrazioni storiche.
            BEGIN
                SELECT dal,
                       cognome,
                       nome,
                       competenza,
                       competenza_esclusiva
                  INTO dDalStorico,
                       dCognomeStorico,
                       dNomeStorico,
                       dCompetenza,
                       dCompetenzaEsclusiva
                  FROM ANAGRAFICI
                 WHERE     ni = p_ni
                       AND dal =
                           (SELECT MAX (dal)
                              FROM ANAGRAFICI
                             WHERE ni = p_ni AND dal < p_dal AND al IS NULL -- posso sistemare solo periodi aperti
                                                                           );
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    dDalStorico := TO_DATE ('27/02/0001', 'dd/mm/yyyy');
                WHEN OTHERS
                THEN
                    RAISE_APPLICATION_ERROR (
                        -20999,
                           si4.get_error ('10068') --'Recupero data di inizio validita'' della registrazione storica.'
                        || CHR (10)
                        || SUBSTR (SQLERRM, 5));
            END;

            -- Se esistono Registrazioni storiche.
            IF dDalStorico <> TO_DATE ('27/02/0001', 'dd/mm/yyyy')
            THEN
                d_result :=
                    anagrafici_pkg.is_competenza_ok (
                        p_competenza                 => p_competenza,
                        p_competenza_esclusiva       => p_competenza_esclusiva,
                        p_competenza_old             => dCompetenza,
                        p_competenza_esclusiva_old   => dCompetenzaEsclusiva);

                IF NOT (d_result = AFC_Error.ok)
                THEN
                    anagrafici_pkg.raise_error_message (d_result);
                END IF;

                -- Verifica la presenza del soggetto nella vista di integrita' referenziale
                -- ed il motivo del blocco del record:
                -- se il soggetto e' presente nella vista e motivo_blocco = D (nessun
                -- campo del record e' modificabile ad eccezione di AL = e' storicizzabile)
                -- e nel nuovo record creato i campi COGNOME e NOME devono essere uguali a
                -- quelli del record storico),
                --    se e' stato modificato il campo COGNOME od il campo NOME, non permette
                --    la modifica.
                -- per stessi ni e dal.
                BEGIN
                    FOR c_ref IN (SELECT oggetto, motivo_blocco
                                    FROM xx4_anagrafici
                                   WHERE ni = p_ni AND dal = ddalstorico)
                    LOOP
                        IF     c_ref.motivo_blocco = 'D'
                           AND (   NVL (p_cognome, ' ') <>
                                   NVL (dcognomestorico, ' ')
                                OR NVL (p_nome, ' ') <>
                                   NVL (dnomestorico, ' '))
                        THEN
                            raise_application_error (
                                -20999,
                                   si4.get_error ('A10044')
                                || ' ('
                                || c_ref.oggetto
                                || '). La registrazione non e'' modificabile (motivo blocco: '
                                || c_ref.motivo_blocco
                                || ').');
                        END IF;
                    END LOOP;
                END;

                -- Aggiornamento storico_soggetti
                IF d_result = AFC_Error.ok
                THEN
                    BEGIN
                        UPDATE ANAGRAFICI
                           SET al = p_dal - 1                        --?? data
                         WHERE ni = p_ni AND dal = dDalStorico;
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            RAISE_APPLICATION_ERROR (
                                -20999,
                                   si4.get_error ('A10069') --'Aggiornamento data di fine validita'' della registrazione storica.'
                                || CHR (10)
                                || SUBSTR (SQLERRM, 5));
                    END;
                END IF;
            END IF;
        END IF;                                          -- NON sono in trasco
    END;

    /* End Procedure: ANAGRAFICI_RRI */
    FUNCTION CONTA_NI_ANAGRAFICI_DAL_AL (p_ni NUMBER, p_dal DATE, p_al DATE)
        RETURN NUMBER
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_num_ni   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO v_num_ni
          FROM anagrafici
         WHERE     ni = p_ni
               AND (dal BETWEEN p_dal
                            AND NVL (p_al, TO_DATE ('3333333', 'j')) --         OR p_dal between dal and nvl(al, to_date('3333333','j'))
                                                                    );

        RETURN v_num_ni;
    END;

    /* End Functon: CONTA_NI_ANAGRAFICI_DAL_AL */
    FUNCTION conta_ni_anagrafici (p_ni NUMBER)
        RETURN NUMBER
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_num_ni   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO v_num_ni
          FROM anagrafici
         WHERE ni = p_ni;

        RETURN v_num_ni;
    END;

    /* End Functon: CONTA_NI_ANAGRAFICI*/
    --#54239
    FUNCTION get_soggetto_cf (p_cf varchar2)
        RETURN NUMBER
    IS
        v_ni   NUMBER;
        v_num  number;
    BEGIN
        SELECT max(ni),count(distinct ni)
          INTO v_ni,v_num
          FROM anagrafici
         WHERE codice_fiscale = p_cf
           and trunc(sysdate) between dal and nvl(al,to_date(3333333,'j')) ;
        if v_num = 1 then
           RETURN v_ni;
        elsif v_num > 1 then
           RETURN -1;
        else RETURN 0;
        end if;
    END;


    FUNCTION get_soggetti_denominazione_cr (p_denominazione_ricerca VARCHAR2)
        RETURN INTEGER
    /******************************************************************************
    NOME:        get_soggetti_denominazione_cr
    DESCRIZIONE: Restituisce il numero dei record della as4_v_soggetti_correnti
    PARAMETRI:   p_denominazione stringa da ricercare
    RITORNA:     AFC.t_ref_cursor        ref_cursor contenente i soggetti che
                                         soddisfano la condizione di ricerca
    REVISIONI:
    Rev.  Data        Autore    Descrizione
    ----  ----------  --------  ----------------------------------------------------
    004   24/07/2018  SN        Prima emissione.
    017   12/02/2019  SN        Nella catsearch tolto '*'
    ******************************************************************************/
    IS
        d_result       INTEGER;
        d_statement    AFC.t_statement;
        d_ref_cursor   AFC.t_ref_cursor;
    BEGIN
        d_statement := 'select count(*) from (';

        IF d_indice_intermedia = 'SI'
        THEN
            d_statement :=
                   d_statement                                       -- rev.17
                || 'select * from as4_v_soggetti_correnti where catsearch (denominazione,'''
                || REPLACE (REPLACE (p_denominazione_ricerca, '%', '*'),
                            '''',
                            '''''')
                || ''', NULL) > 0'
                || ' UNION '
                || ' select * from as4_v_soggetti_correnti where  partita_iva like upper(''%'
                || REPLACE (p_denominazione_ricerca, '''', '''''')
                || '%'')'
                || ' or codice_fiscale like upper(''%'
                || REPLACE (p_denominazione_ricerca, '''', '''''')
                || '%'')'
                || ' or nominativo_ricerca like upper(''%'
                || REPLACE (p_denominazione_ricerca, '''', '''''')
                || '%'')';
        ELSE                               -- non ci sono indici di intermedia
            DECLARE
                v_valori_cercare       VARCHAR2 (32767)
                                           := p_denominazione_ricerca;
                v_valore               VARCHAR2 (32767);
                v_condizione_cercare   VARCHAR2 (32767);
            BEGIN
                v_valore :=
                    REPLACE (
                        afc.get_substr (p_stringa      => v_valori_cercare,
                                        p_separatore   => ' '),
                        '''',
                        '''''');

                --                    dbms_output.put_line(v_valori_cercare || '(' || v_valore || ')');
                IF v_valore IS NOT NULL
                THEN
                    v_condizione_cercare :=
                           v_condizione_cercare
                        || ' and denominazione like upper(''%'
                        || v_valore
                        || '%'') ';
                END IF;

                WHILE v_valori_cercare IS NOT NULL
                LOOP
                    v_valore :=
                        afc.get_substr (p_stringa      => v_valori_cercare,
                                        p_separatore   => ' ');

                    IF v_valore IS NOT NULL
                    THEN
                        v_condizione_cercare :=
                               v_condizione_cercare
                            || ' and denominazione like upper(''%'
                            || v_valore
                            || '%'') ';
                    END IF;
                --                    dbms_output.put_line(v_valori_cercare || '(' || v_valore || ')');
                END LOOP;

                --                 dbms_output.put_line(':' ||v_condizione_cercare );
                --                    raise_application_error (-20999,'cercare' || substr(v_condizione_cercare,5));
                d_statement :=
                       d_statement
                    || ' select * from as4_v_soggetti_correnti where '
                    || SUBSTR (v_condizione_cercare, 5)
                    || ' or partita_iva like upper(''%'
                    || v_valore
                    || '%'')'
                    || ' or codice_fiscale like upper(''%'
                    || v_valore
                    || '%'')'
                    || ' or nominativo_ricerca like upper(''%'
                    || v_valore
                    || '%'')';                           -- tolgo il primo and
            END;
        END IF;

        d_statement := d_statement || ' ) ';
        d_result := AFC.SQL_execute (d_statement);
        RETURN d_result;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (-20999, si4.get_error ('A00002')); -- Impossibile ricercare utilizzando caratteri speciali.
    END;

    FUNCTION get_soggetti_per_denominazione (
        p_denominazione_ricerca      VARCHAR2,
        p_offset                  IN NUMBER DEFAULT NULL,
        p_limit                   IN NUMBER DEFAULT NULL)
        RETURN afc.t_ref_cursor
    IS
        /******************************************************************************
        NOME:        get_soggetti_per_denominazione
        DESCRIZIONE: Restituisce i record della as4_v_soggetti_correnti
        PARAMETRI:   p_denominazione stringa da ricercare
                     p_offset: rownum da cui partire per estrazione
                     p_limit: rownum a cui terminare estrazione
        RITORNA:     AFC.t_ref_cursor        ref_cursor contenente i soggetti che
                                             soddisfano la condizione di ricerca
        REVISIONI:
        Rev.  Data        Autore    Descrizione
        ----  ----------  --------  ----------------------------------------------------
        000   25/05/2018  SN        Prima emissione.
        004   24/07/2018  SN        Aggiunta paginazione
        005   27/08/2018  SN        Sistemato ordinamento
        ******************************************************************************/
        d_statement    AFC.t_statement;
        d_ref_cursor   AFC.t_ref_cursor;
        v_get_pref     impostazioni.t_impostazioni;
    BEGIN
        v_get_pref :=
            impostazioni.get_preferenza ('OrdinamentoAnagrafica', '');
        d_statement :=
            CASE
                WHEN p_offset IS NULL AND p_limit IS NULL
                THEN
                    ' select * from ('
                ELSE
                       'select * from ( '
                    || 'select rownum "ROW#", t.* from (  select * from ('
            END;

        IF d_indice_intermedia = 'SI'
        THEN
            d_statement :=
                   d_statement
                || 'select * from as4_v_soggetti_correnti where catsearch (denominazione,'''
                || REPLACE (REPLACE (p_denominazione_ricerca, '%', '*'),
                            '''',
                            '''''')
                || ''', NULL) > 0'
                || ' UNION '
                || ' select * from as4_v_soggetti_correnti where  partita_iva like upper(''%'
                || REPLACE (p_denominazione_ricerca, '''', '''''')
                || '%'')'
                || ' or codice_fiscale like upper(''%'
                || REPLACE (p_denominazione_ricerca, '''', '''''')
                || '%'')'
                || ' or nominativo_ricerca like upper(''%'
                || REPLACE (p_denominazione_ricerca, '''', '''''')
                || '%'')';
        ELSE                               -- non ci sono indici di intermedia
            DECLARE
                v_valori_cercare       VARCHAR2 (32767)
                                           := p_denominazione_ricerca;
                v_valore               VARCHAR2 (32767);
                v_condizione_cercare   VARCHAR2 (32767);
            BEGIN
                v_valore :=
                    REPLACE (
                        afc.get_substr (p_stringa      => v_valori_cercare,
                                        p_separatore   => ' '),
                        '''',
                        '''''');

                --                    dbms_output.put_line(v_valori_cercare || '(' || v_valore || ')');
                IF v_valore IS NOT NULL
                THEN
                    v_condizione_cercare :=
                           v_condizione_cercare
                        || ' and denominazione like upper(''%'
                        || v_valore
                        || '%'') ';
                END IF;

                WHILE v_valori_cercare IS NOT NULL
                LOOP
                    v_valore :=
                        afc.get_substr (p_stringa      => v_valori_cercare,
                                        p_separatore   => ' ');

                    IF v_valore IS NOT NULL
                    THEN
                        v_condizione_cercare :=
                               v_condizione_cercare
                            || ' and denominazione like upper(''%'
                            || v_valore
                            || '%'') ';
                    END IF;
                --                    dbms_output.put_line(v_valori_cercare || '(' || v_valore || ')');
                END LOOP;

                --                 dbms_output.put_line(':' ||v_condizione_cercare );
                --                    raise_application_error (-20999,'cercare' || substr(v_condizione_cercare,5));
                d_statement :=
                       d_statement
                    || ' select * from as4_v_soggetti_correnti where '
                    || SUBSTR (v_condizione_cercare, 5)
                    || ' or partita_iva like upper(''%'
                    || v_valore
                    || '%'')'
                    || ' or codice_fiscale like upper(''%'
                    || v_valore
                    || '%'')'
                    || ' or nominativo_ricerca like upper(''%'
                    || v_valore
                    || '%'')';                           -- tolgo il primo and
            END;
        END IF;

        d_statement :=
               d_statement
            || CASE
                   WHEN p_offset IS NULL AND p_limit IS NULL
                   THEN
                          afc.decode_value (
                              v_get_pref,
                              NULL,
                              NULL,
                              ' order by ' || RTRIM (v_get_pref, ','))
                       || ')'
                   ELSE
                          ' ) '
                       || afc.decode_value (
                              v_get_pref,
                              NULL,
                              NULL,
                              ' order by ' || RTRIM (v_get_pref, ','))
                       || ' ) t '
                       || ' ) '
                       || ' where "ROW#" > '
                       || NVL (p_offset, 0)
                       || '   and "ROW#" <  '
                       || (1 + NVL (p_offset, 0) + NVL (p_limit, 999999))
               END;
        d_ref_cursor := AFC_DML.get_ref_cursor (d_statement);
        RETURN d_ref_cursor;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (-20999, si4.get_error ('A00002'), TRUE); -- Impossibile ricercare utilizzando caratteri speciali.
    END get_soggetti_per_denominazione;

    FUNCTION controllo_se_ni_in_struttura (p_ni NUMBER)
        RETURN NUMBER
    IS
        v_conta_ni   NUMBER;
    BEGIN
        BEGIN
            EXECUTE IMMEDIATE   'select count(*)'
                             || ' from so4_soggetti_struttura  where ni ='
                             || p_ni
                INTO v_conta_ni;
        EXCEPTION
            WHEN OTHERS
            THEN
                v_conta_ni := 0;
        END;

        RETURN v_conta_ni;
    END;

    FUNCTION get_is_modificabile (
        p_tabella                    IN VARCHAR2,
        p_competenza                 IN anagrafici.competenza%TYPE,
        p_competenza_esclusiva       IN anagrafici.competenza_esclusiva%TYPE,
        p_competenza_old             IN anagrafici.competenza%TYPE,
        p_competenza_esclusiva_old   IN anagrafici.competenza_esclusiva%TYPE,
        p_utente_agg                 IN VARCHAR2,
        p_ruolo_accesso              IN VARCHAR2,
        p_id_record                  IN NUMBER)
        RETURN VARCHAR2
    IS
        /******************************************************************************
        NOME:        get_is_modificabile
        DESCRIZIONE: Verifica indicazioni sui campi modificabili
        PARAMETRI:
        RITORNA:     Restituisce le indicazioni sui campi modificabili:
                   - *  = tutti i campi sono modificabili
                   - elenco di campi separati da $$ NON modificabili
        REVISIONI:
        Rev.  Data        Autore    Descrizione
        ----  ----------  --------  ----------------------------------------------------
        000   31/05/2018  SN        Prima emissione.
        001   12/09/2018  SN        Controllo sui contatti
        012   10/12/2018  SN        Visualizzare i campi come non modificabili se competenza non lo consente
        040   19/11/2020  SNeg      Integrazione con ARCO introdurre e gestire tipo_ricapito 0 = LAVORO non modificabile da interfaccia Feature #46210
        ******************************************************************************/
        v_colonne                   VARCHAR2 (32767) := '*';
        v_ni_e_soggetto_struttura   NUMBER;
    BEGIN
        -- non ruolo in sola lettura
        IF p_tabella = 'ANAGRAFICI'
        THEN
            v_colonne := NULL;
            v_ni_e_soggetto_struttura :=
                controllo_se_ni_in_struttura (
                    ANAGRAFICI_TPK.get_ni (p_id_record));

            IF v_ni_e_soggetto_struttura > 0
            THEN
                -- viene da struttura modificabile solo partita_iva
                FOR v_col
                    IN (SELECT column_name
                          FROM user_tab_columns
                         WHERE     table_name = 'ANAGRAFICI'
                               AND column_name != 'PARTITA_IVA')
                LOOP
                    v_colonne := v_colonne || '$$' || v_col.column_name;
                END LOOP;

                v_colonne := v_colonne || '$$';
            END IF;
        ELSIF p_tabella = 'RECAPITI'
        THEN
            --         if RECAPITI_TPK.get_id_tipo_recapito (p_id_record)!= 1 then
            --      raise_application_error(-20999,p_tabella ||':'||
            --                             p_competenza                 ||':'||
            --                             p_competenza_esclusiva       ||':'||
            --                             p_competenza_old             ||':'||
            --                             p_competenza_esclusiva_old   ||':'||
            --                             p_utente_agg                    ||':'||
            --                             p_ruolo_accesso                      ||':'||
            --                             p_ruolo_accesso);
            --      end if;
            v_colonne := NULL;
            v_ni_e_soggetto_struttura :=
                controllo_se_ni_in_struttura (
                    RECAPITI_TPK.get_ni (p_id_record));

            IF    (    v_ni_e_soggetto_struttura > 0
                   AND RECAPITI_TPK.get_id_tipo_recapito (p_id_record) = 1)
               OR is_competenza_ok (p_competenza,
                                    p_competenza_esclusiva,
                                    p_competenza_old,
                                    p_competenza_esclusiva_old) !=
                  afc_error.ok
               OR recapiti_tpk.get_id_tipo_recapito (p_id_record) = 0  -- usato da ARCO non modificabile rev. 040
            THEN
                --         raise_application_error(-20999, 'valore (' || afc_error.ok ||')' || is_competenza_ok (p_competenza,
                --                                    p_competenza_esclusiva,
                --                                    p_competenza_old,
                --                                    p_competenza_esclusiva_old));
                -- viene da struttura ed è residenza NULLA risulta modificabile
                FOR v_col IN (SELECT column_name
                                FROM user_tab_columns
                               WHERE table_name = 'RECAPITI')
                LOOP
                    v_colonne := v_colonne || '$$' || v_col.column_name;
                END LOOP;

                v_colonne := v_colonne || '$$';
            --            raise_application_error(-20999, v_colonne);
            END IF;
        -- Rev. 1 inizio
        ELSIF p_tabella = 'CONTATTI'
        THEN
            v_colonne := NULL;
            v_ni_e_soggetto_struttura :=
                controllo_se_ni_in_struttura (
                    RECAPITI_TPK.get_ni (
                        contatti_tpk.get_id_recapito (p_id_record)));

            --                  if contatti_tpk.get_competenza(p_id_record) != 'SI4SO' then
            --      raise_application_error(-20999,p_tabella ||':'||
            --                             p_competenza                 ||':'||
            --                             p_competenza_esclusiva       ||':'||
            --                             p_competenza_old             ||':'||
            --                             p_competenza_esclusiva_old   ||':'||
            --                             p_utente_agg                    ||':'||
            --                             p_ruolo_accesso                      ||':'||
            --                             p_ruolo_accesso);
            --      end if;
            IF    (    v_ni_e_soggetto_struttura > 0
                   AND contatti_tpk.get_competenza (p_id_record) = 'SI4SO')
               OR is_competenza_ok (p_competenza,
                                    p_competenza_esclusiva,
                                    p_competenza_old,
                                    p_competenza_esclusiva_old) !=
                  afc_error.ok
               OR
                recapiti_tpk.get_id_tipo_recapito (contatti_tpk.get_id_recapito(p_id_record)) = 0  -- usato da ARCO non modificabile rev. 040
            THEN
                -- viene da struttura ed è di competenza di struttura organizzativa
                FOR v_col IN (SELECT column_name
                                FROM user_tab_columns
                               WHERE table_name = 'CONTATTI')
                LOOP
                    v_colonne := v_colonne || '$$' || v_col.column_name;
                END LOOP;

                v_colonne := v_colonne || '$$';
            END IF;
        -- Rev. 1 fine
        END IF;

        RETURN NVL (v_colonne, '*');
    END get_is_modificabile;

    FUNCTION ESTRAI_STORICO (P_NI IN NUMBER)
        RETURN CLOB
    IS
        /******************************************************************************
        NOME:        ESTRAI_STORICO
        DESCRIZIONE: Genera html x visualizzazione storico da interfaccia
        PARAMETRI:
        RITORNA:
        REVISIONI:
        Rev.  Data        Autore    Descrizione
        ----  ----------  --------  ----------------------------------------------------
        000   31/05/2018  AD        Prima emissione.
        024   09/04/2019  SNeg      Estrazione del comune solo se valorizzata anche la provincia
        043   18/03/2021  SNeg      Proteggere caratteri speciali nei campi Bug #49059
        ******************************************************************************/
        d_tree_storico                CLOB := EMPTY_CLOB ();
        d_amount                      BINARY_INTEGER := 32767;
        d_char                        VARCHAR2 (32767);
        d_xml                         VARCHAR2 (32767);
        D_NEW_AL                      ANAGRAFICI_STORICO.AL%TYPE;
        D_NEW_COGNOME                 ANAGRAFICI_STORICO.COGNOME%TYPE;
        D_NEW_NOME                    ANAGRAFICI_STORICO.NOME%TYPE;
        D_NEW_SESSO                   ANAGRAFICI_STORICO.SESSO%TYPE;
        D_NEW_DATA_NAS                ANAGRAFICI_STORICO.DATA_NAS%TYPE;
        D_NEW_PROVINCIA_NAS           ANAGRAFICI_STORICO.PROVINCIA_NAS%TYPE;
        D_NEW_COMUNE_NAS              ANAGRAFICI_STORICO.COMUNE_NAS%TYPE;
        D_NEW_CODICE_FISCALE          ANAGRAFICI_STORICO.CODICE_FISCALE%TYPE;
        D_NEW_LUOGO_NAS               ANAGRAFICI_STORICO.LUOGO_NAS%TYPE;
        D_NEW_CODICE_FISCALE_ESTERO   ANAGRAFICI_STORICO.CODICE_FISCALE_ESTERO%TYPE;
        D_NEW_PARTITA_IVA             ANAGRAFICI_STORICO.PARTITA_IVA%TYPE;
        D_NEW_CITTADINANZA            ANAGRAFICI_STORICO.CITTADINANZA%TYPE;
        D_NEW_GRUPPO_LING             ANAGRAFICI_STORICO.GRUPPO_LING%TYPE;
        D_NEW_COMPETENZA              ANAGRAFICI_STORICO.COMPETENZA%TYPE;
        D_NEW_COMPETENZA_ESCLUSIVA    ANAGRAFICI_STORICO.COMPETENZA_ESCLUSIVA%TYPE;
        D_NEW_TIPO_SOGGETTO           ANAGRAFICI_STORICO.TIPO_SOGGETTO%TYPE;
        D_NEW_STATO_CEE               ANAGRAFICI_STORICO.STATO_CEE%TYPE;
        D_NEW_PARTITA_IVA_CEE         ANAGRAFICI_STORICO.PARTITA_IVA_CEE%TYPE;
        D_NEW_FINE_VALIDITA           ANAGRAFICI_STORICO.FINE_VALIDITA%TYPE;
        D_NEW_STATO_SOGGETTO          ANAGRAFICI_STORICO.STATO_SOGGETTO%TYPE;
        D_NEW_NOTE                    ANAGRAFICI_STORICO.NOTE%TYPE;
        d_utente                      anagrafici_storico.utente_aggiornamento%TYPE;
        d_denominazione_provincia     VARCHAR2 (1000);
        d_denominazione_provincia2    VARCHAR2 (1000);
        d_new_des_sesso               VARCHAR2 (10);
        d_new_des_stato               VARCHAR2 (10);
        d_des_tipo_soggetto           TIPI_SOGGETTO.DESCRIZIONE%TYPE;
        d_des_tipo_soggetto2          TIPI_SOGGETTO.DESCRIZIONE%TYPE;
        d_des_utente_aggiornamento    VARCHAR2 (100);
    BEGIN
        DBMS_LOB.createTemporary (d_tree_storico, TRUE, DBMS_LOB.CALL);
        D_XML := '<ROWSET>' || CHR (10);
        DBMS_LOB.writeappend (d_tree_storico, LENGTH (d_xml), d_xml);

        FOR sel_storico_anag
            IN (  SELECT anas.*,
                         DECODE (anas.sesso,
                                 'M', 'Maschio',
                                 'F', 'Femmina',
                                 NULL)
                             des_sesso,
                         DECODE (ANAS.STATO_SOGGETTO,
                                 'U', 'In uso',
                                 'C', 'Chiuso',
                                 NULL)
                             des_stato
                    FROM anagrafici_storico anas
                   WHERE ni = P_NI AND operazione IN ('I', 'BI', 'D')
                ORDER BY id_evento)
        LOOP
            IF sel_storico_anag.operazione = 'I'
            THEN                                           --nuovi inserimenti
                d_utente :=
                    NVL (sel_storico_anag.utente_aggiornamento,
                         sel_storico_anag.utente); -- se non è tracciato l'utente dell'operazione prendo quello valorizzato
                d_des_utente_aggiornamento :=
                    ad4_soggetto.get_denominazione (
                        ad4_utente.get_soggetto (d_utente, 'N', 0));

                IF d_des_utente_aggiornamento IS NOT NULL
                THEN
                    d_des_utente_aggiornamento :=
                           NVL (ad4_utente.get_nominativo (d_utente, 'N', 0),
                                d_utente)
                        || ' - '
                        || d_des_utente_aggiornamento;
                ELSE
                    d_des_utente_aggiornamento :=
                        NVL (ad4_utente.get_nominativo (d_utente, 'N', 0),
                             d_utente);
                END IF;

                D_XML :=
                       '<ROW><LABEL_PARTE1>Anagrafica con decorrenza '
                    || TO_CHAR (sel_storico_anag.dal, 'DD/MM/YYYY')
                    || ' inserito da '
                    || d_des_utente_aggiornamento
                    || ' il '
                    || TO_CHAR (sel_storico_anag.data,
                                'DD/MM/YYYY hh24:MI:SS')
                    || '</LABEL_PARTE1>'
                    || CHR (10)
                    || '<ROWSET>'
                    || CHR (10);
                DBMS_LOB.writeappend (d_tree_storico, LENGTH (d_xml), d_xml);

                IF sel_storico_anag.al IS NOT NULL
                THEN
                    D_XML :=
                           '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>AL</LABEL_PARTE1><LABEL_PARTE3>'
                        || TO_CHAR (sel_storico_anag.al, 'dd/mm/yyyy')
                        || '</LABEL_PARTE3></ROW>'
                        || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                END IF;

                IF sel_storico_anag.cognome IS NOT NULL
                THEN
                    D_XML :=
                           '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COGNOME</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                        || sel_storico_anag.cognome
                        || ']]></LABEL_PARTE3></ROW>'
                        || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                END IF;

                IF sel_storico_anag.NOME IS NOT NULL
                THEN
                    D_XML :=
                           '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>NOME</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                        || sel_storico_anag.nome
                        || ']]></LABEL_PARTE3></ROW>'
                        || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                END IF;

                IF sel_storico_anag.SESSO IS NOT NULL
                THEN
                    D_XML :=
                           '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>SESSO</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                        || sel_storico_anag.des_SESSO
                        || ']]></LABEL_PARTE3></ROW>'
                        || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                END IF;

                IF sel_storico_anag.DATA_NAS IS NOT NULL
                THEN
                    D_XML :=
                           '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>DATA NASCITA</LABEL_PARTE1><LABEL_PARTE3>'
                        || TO_CHAR (sel_storico_anag.DATA_NAS, 'DD/MM/YYYY')
                        || '</LABEL_PARTE3></ROW>'
                        || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                END IF;

                IF sel_storico_anag.PROVINCIA_NAS IS NOT NULL
                THEN
                    BEGIN
                        IF sel_storico_anag.PROVINCIA_NAS < 200
                        THEN                             -- provincia italiana
                            d_denominazione_provincia :=
                                ad4_provincia.get_denominazione (
                                    sel_storico_anag.PROVINCIA_NAS);
                        ELSE
                            d_denominazione_provincia :=
                                ad4_stati_territori_tpk.get_denominazione (
                                    sel_storico_anag.PROVINCIA_NAS);
                        END IF;
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            d_denominazione_provincia := NULL;
                    END;

                    D_XML :=
                           '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>PROVINCIA NASCITA</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                        || d_denominazione_provincia
                        || ']]></LABEL_PARTE3></ROW>'
                        || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                END IF;

                IF sel_storico_anag.COMUNE_NAS IS NOT NULL
                THEN
                    IF sel_storico_anag.PROVINCIA_NAS IS NOT NULL
                    THEN                                       --rev.24 inizio
                        D_XML :=
                               '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COMUNE NASCITA</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                            || ad4_comuni_tpk.get_denominazione (
                                   sel_storico_anag.PROVINCIA_NAS,
                                   sel_storico_anag.COMUNE_NAS)
                            || ']]></LABEL_PARTE3></ROW>'
                            || CHR (10);
                    ELSE                          -- provincia non valorizzata
                        D_XML :=
                               '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COMUNE NASCITA</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                            || ' COMUNE NON CODIFICATO: '
                            || sel_storico_anag.COMUNE_NAS
                            || ']]></LABEL_PARTE3></ROW>'
                            || CHR (10);
                    --rev.24 fine
                    END IF;

                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                END IF;

                IF sel_storico_anag.LUOGO_NAS IS NOT NULL
                THEN
                    D_XML :=
                           '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>LUOGO NASCITA</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                        || sel_storico_anag.LUOGO_NAS
                        || ']]></LABEL_PARTE3></ROW>'
                        || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                END IF;

                IF sel_storico_anag.CODICE_FISCALE IS NOT NULL
                THEN
                    D_XML :=
                           '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>CODICE FISCALE</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                        || sel_storico_anag.CODICE_FISCALE
                        || ']]></LABEL_PARTE3></ROW>'
                        || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                END IF;

                IF sel_storico_anag.CODICE_FISCALE_ESTERO IS NOT NULL
                THEN
                    D_XML :=
                           '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>ID. FISCALE ESTERO</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                        || sel_storico_anag.CODICE_FISCALE_ESTERO
                        || ']]></LABEL_PARTE3></ROW>'
                        || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                END IF;

                IF sel_storico_anag.PARTITA_IVA IS NOT NULL
                THEN
                    D_XML :=
                           '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>PARTITA IVA</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                        || sel_storico_anag.PARTITA_IVA
                        || ']]></LABEL_PARTE3></ROW>'
                        || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                END IF;

                IF sel_storico_anag.partita_iva_CEE IS NOT NULL
                THEN
                    D_XML :=
                           '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>PARTITA IVA CEE</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                        || sel_storico_anag.partita_iva_CEE
                        || ']]></LABEL_PARTE3></ROW>'
                        || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                END IF;

                IF sel_storico_anag.STATO_CEE IS NOT NULL
                THEN
                    D_XML :=
                           '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>STATO CEE</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                        || sel_storico_anag.STATO_CEE
                        || ']]></LABEL_PARTE3></ROW>'
                        || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                END IF;

                IF sel_storico_anag.CITTADINANZA IS NOT NULL
                THEN
                    D_XML :=
                           '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>CITTADINANZA</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                        || sel_storico_anag.CITTADINANZA
                        || ']]></LABEL_PARTE3></ROW>'
                        || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                END IF;

                IF sel_storico_anag.GRUPPO_LING IS NOT NULL
                THEN
                    D_XML :=
                           '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>GRUPPO LINGUISTICO</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                        || sel_storico_anag.GRUPPO_LING
                        || ']]></LABEL_PARTE3></ROW>'
                        || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                END IF;

                IF sel_storico_anag.COMPETENZA IS NOT NULL
                THEN
                    D_XML :=
                           '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COMPETENZA</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                        || sel_storico_anag.COMPETENZA
                        || ']]></LABEL_PARTE3></ROW>'
                        || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                END IF;

                IF sel_storico_anag.COMPETENZA_ESCLUSIVA IS NOT NULL
                THEN
                    D_XML :=
                           '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COMPETENZA ESCLUSIVA</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                        || sel_storico_anag.COMPETENZA_ESCLUSIVA
                        || ']]></LABEL_PARTE3></ROW>'
                        || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                END IF;

                IF sel_storico_anag.TIPO_SOGGETTO IS NOT NULL
                THEN
                    BEGIN
                        d_des_tipo_soggetto :=
                            tipi_soggetto_tpk.get_descrizione (
                                sel_storico_anag.TIPO_SOGGETTO);
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            d_des_tipo_soggetto :=
                                sel_storico_anag.TIPO_SOGGETTO;
                    END;

                    D_XML :=
                           '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>TIPO SOGGETTO</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                        || d_des_tipo_soggetto
                        || ']]></LABEL_PARTE3></ROW>'
                        || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                END IF;

                IF sel_storico_anag.FINE_VALIDITA IS NOT NULL
                THEN
                    D_XML :=
                           '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>FINE VALIDITA''</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                        || TO_CHAR (sel_storico_anag.FINE_VALIDITA,
                                    'dd/mm/yyyy')
                        || ']]></LABEL_PARTE3></ROW>'
                        || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                END IF;

                IF sel_storico_anag.STATO_SOGGETTO IS NOT NULL
                THEN
                    D_XML :=
                           '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>STATO SOGGETTO</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                        || sel_storico_anag.des_STATO
                        || ']]></LABEL_PARTE3></ROW>'
                        || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                END IF;

                IF sel_storico_anag.NOTE IS NOT NULL
                THEN
                    D_XML :=
                           '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>NOTE</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                        || sel_storico_anag.NOTE
                        || ']]></LABEL_PARTE3></ROW>'
                        || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                END IF;

                D_XML := '</ROWSET></ROW>' || CHR (10);
                DBMS_LOB.writeappend (d_tree_storico, LENGTH (d_xml), d_xml);
            ELSIF sel_storico_anag.operazione = 'BI'
            THEN                                         --modifica del record
                BEGIN
                    SELECT al,
                           COGNOME,
                           NOME,
                           SESSO,
                           DATA_NAS,
                           PROVINCIA_NAS,
                           COMUNE_NAS,
                           LTRIM (RTRIM (CODICE_FISCALE)),
                           LUOGO_NAS,
                           CODICE_FISCALE_ESTERO,
                           PARTITA_IVA,
                           CITTADINANZA,
                           GRUPPO_LING,
                           COMPETENZA,
                           COMPETENZA_ESCLUSIVA,
                           TIPO_SOGGETTO,
                           STATO_CEE,
                           PARTITA_IVA_CEE,
                           FINE_VALIDITA,
                           STATO_SOGGETTO,
                           NOTE,
                           NVL (utente_aggiornamento, utente),
                           DECODE (sesso,
                                   'M', 'Maschio',
                                   'F', 'Femmina',
                                   NULL),
                           DECODE (STATO_SOGGETTO,
                                   'U', 'In uso',
                                   'C', 'Chiuso',
                                   NULL)
                      INTO D_NEW_AL,
                           D_NEW_COGNOME,
                           D_NEW_NOME,
                           D_NEW_SESSO,
                           D_NEW_DATA_NAS,
                           D_NEW_PROVINCIA_NAS,
                           D_NEW_COMUNE_NAS,
                           D_NEW_CODICE_FISCALE,
                           D_NEW_LUOGO_NAS,
                           D_NEW_CODICE_FISCALE_ESTERO,
                           D_NEW_PARTITA_IVA,
                           D_NEW_CITTADINANZA,
                           D_NEW_GRUPPO_LING,
                           D_NEW_COMPETENZA,
                           D_NEW_COMPETENZA_ESCLUSIVA,
                           D_NEW_TIPO_SOGGETTO,
                           D_NEW_STATO_CEE,
                           D_NEW_PARTITA_IVA_CEE,
                           D_NEW_FINE_VALIDITA,
                           D_NEW_STATO_SOGGETTO,
                           D_NEW_NOTE,
                           d_utente,
                           d_new_des_sesso,
                           d_new_des_stato
                      FROM ANAGRAFICI_STORICO
                     WHERE BI_RIFERIMENTO = SEL_STORICO_ANAG.ID_EVENTO;

                    d_des_utente_aggiornamento :=
                        ad4_soggetto.get_denominazione (
                            ad4_utente.get_soggetto (d_utente, 'N', 0));

                    IF d_des_utente_aggiornamento IS NOT NULL
                    THEN
                        d_des_utente_aggiornamento :=
                               NVL (
                                   ad4_utente.get_nominativo (d_utente,
                                                              'N',
                                                              0),
                                   d_utente)
                            || ' - '
                            || d_des_utente_aggiornamento;
                    ELSE
                        d_des_utente_aggiornamento :=
                            NVL (
                                ad4_utente.get_nominativo (d_utente, 'N', 0),
                                d_utente);
                    END IF;

                    D_XML :=
                           '<ROW><LABEL_PARTE1>Anagrafica con decorrenza '
                        || TO_CHAR (sel_storico_anag.dal, 'DD/MM/YYYY')
                        || ' aggiornata da '
                        || d_des_utente_aggiornamento
                        || ' il '
                        || TO_CHAR (sel_storico_anag.data,
                                    'DD/MM/YYYY hh24:MI:SS')
                        || '</LABEL_PARTE1>'
                        || CHR (10)
                        || '<ROWSET>'
                        || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);

                    IF NVL (sel_storico_anag.al, TO_DATE (3333333, 'J')) !=
                       NVL (D_NEW_AL, TO_DATE (3333333, 'J'))
                    THEN                                      -- MODIFICATO AL
                        IF     SEL_STORICO_ANAG.AL IS NULL
                           AND D_NEW_AL IS NOT NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>AL</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                                || TO_CHAR (D_NEW_AL, 'dd/mm/yyyy')
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSIF     SEL_STORICO_ANAG.AL IS NOT NULL
                              AND D_NEW_AL IS NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>AL</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || TO_CHAR (SEL_STORICO_ANAG.AL,
                                            'dd/mm/yyyy')
                                || ']]></LABEL_PARTE2></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSE
                            D_XML :=
                                   '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>AL</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || TO_CHAR (SEL_STORICO_ANAG.AL,
                                            'dd/mm/yyyy')
                                || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['
                                || TO_CHAR (d_new_AL, 'dd/mm/yyyy')
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        END IF;
                    END IF;

                    IF NVL (sel_storico_anag.COGNOME, 'x') !=
                       NVL (D_NEW_COGNOME, 'x')
                    THEN                                 -- MODIFICATO COGNOME
                        IF     sel_storico_anag.COGNOME IS NULL
                           AND D_NEW_COGNOME IS NOT NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COGNOME</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                                || D_NEW_COGNOME
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSIF     SEL_STORICO_ANAG.COGNOME IS NOT NULL
                              AND D_NEW_COGNOME IS NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>COGNOME</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.COGNOME
                                || ']]></LABEL_PARTE2></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSE
                            D_XML :=
                                   '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>COGNOME</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.cognome
                                || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['
                                || d_new_cognome
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        END IF;
                    END IF;

                    IF NVL (sel_storico_anag.NOME, 'x') !=
                       NVL (D_NEW_NOME, 'x')
                    THEN                                    -- MODIFICATO NOME
                        IF     sel_storico_anag.NOME IS NULL
                           AND D_NEW_NOME IS NOT NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>NOME</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                                || D_NEW_NOME
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSIF     SEL_STORICO_ANAG.NOME IS NOT NULL
                              AND D_NEW_NOME IS NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>NOME</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.NOME
                                || ']]></LABEL_PARTE2></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSE
                            D_XML :=
                                   '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>NOME</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.nome
                                || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['
                                || d_new_nome
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        END IF;
                    END IF;

                    IF NVL (sel_storico_anag.sesso, 'xx') !=
                       NVL (D_NEW_sesso, 'xx')
                    THEN                                   -- MODIFICATO SESSO
                        IF     sel_storico_anag.sesso IS NULL
                           AND D_NEW_sesso IS NOT NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>SESSO</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                                || D_NEW_des_SESSO
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSIF     SEL_STORICO_ANAG.SESSO IS NOT NULL
                              AND D_NEW_SESSO IS NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>SESSO</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.des_SESSO
                                || ']]></LABEL_PARTE2></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSE
                            D_XML :=
                                   '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>SESSO</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.des_SESSO
                                || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['
                                || d_new_des_SESSO
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        END IF;
                    END IF;

                    IF NVL (sel_storico_anag.data_nas,
                            TO_DATE (3333333, 'J')) !=
                       NVL (D_NEW_data_nas, TO_DATE (3333333, 'J'))
                    THEN                                -- MODIFICATO data_nas
                        IF     SEL_STORICO_ANAG.data_nas IS NULL
                           AND D_NEW_data_nas IS NOT NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>DATA NASCITA</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                                || TO_CHAR (D_NEW_data_nas, 'dd/mm/yyyy')
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSIF     SEL_STORICO_ANAG.data_nas IS NOT NULL
                              AND D_NEW_data_nas IS NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>DATA NASCITA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || TO_CHAR (SEL_STORICO_ANAG.DATA_NAS,
                                            'dd/mm/yyyy')
                                || ']]></LABEL_PARTE2></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSE
                            D_XML :=
                                   '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>DATA NASCITA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || TO_CHAR (SEL_STORICO_ANAG.DATA_NAS,
                                            'dd/mm/yyyy')
                                || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['
                                || TO_CHAR (d_new_DATA_NAS, 'dd/mm/yyyy')
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        END IF;
                    END IF;

                    IF NVL (sel_storico_anag.provincia_nas, -1) !=
                       NVL (D_NEW_provincia_nas, -1)
                    THEN                           -- MODIFICATO PROVINCIA_NAS
                        IF     SEL_STORICO_ANAG.provincia_nas IS NULL
                           AND D_NEW_provincia_nas IS NOT NULL
                        THEN
                            BEGIN
                                IF D_NEW_provincia_nas < 200
                                THEN                     -- provincia italiana
                                    d_denominazione_provincia :=
                                        ad4_provincia.get_denominazione (
                                            D_NEW_provincia_nas);
                                ELSE
                                    d_denominazione_provincia :=
                                        ad4_stati_territori_tpk.get_denominazione (
                                            D_NEW_provincia_nas);
                                END IF;
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    d_denominazione_provincia := NULL;
                            END;

                            D_XML :=
                                   '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>PROVINCIA NASCITA</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                                || d_denominazione_provincia
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSIF     SEL_STORICO_ANAG.provincia_nas IS NOT NULL
                              AND D_NEW_provincia_nas IS NULL
                        THEN
                            BEGIN
                                IF SEL_STORICO_ANAG.PROVINCIA_NAS < 200
                                THEN                     -- provincia italiana
                                    d_denominazione_provincia :=
                                        ad4_provincia.get_denominazione (
                                            SEL_STORICO_ANAG.PROVINCIA_NAS);
                                ELSE
                                    d_denominazione_provincia :=
                                        ad4_stati_territori_tpk.get_denominazione (
                                            SEL_STORICO_ANAG.PROVINCIA_NAS);
                                END IF;
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    d_denominazione_provincia := NULL;
                            END;

                            D_XML :=
                                   '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>PROVINCIA NASCITA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || d_denominazione_provincia
                                || ']]></LABEL_PARTE2></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSE
                            BEGIN
                                IF SEL_STORICO_ANAG.PROVINCIA_NAS < 200
                                THEN                     -- provincia italiana
                                    d_denominazione_provincia :=
                                        ad4_provincia.get_denominazione (
                                            SEL_STORICO_ANAG.PROVINCIA_NAS);
                                ELSE
                                    d_denominazione_provincia :=
                                        ad4_stati_territori_tpk.get_denominazione (
                                            SEL_STORICO_ANAG.PROVINCIA_NAS);
                                END IF;
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    d_denominazione_provincia := NULL;
                            END;

                            BEGIN
                                IF d_new_PROVINCIA_NAS < 200
                                THEN                     -- provincia italiana
                                    d_denominazione_provincia2 :=
                                        ad4_provincia.get_denominazione (
                                            d_new_PROVINCIA_NAS);
                                ELSE
                                    d_denominazione_provincia2 :=
                                        ad4_stati_territori_tpk.get_denominazione (
                                            d_new_PROVINCIA_NAS);
                                END IF;
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    d_denominazione_provincia := NULL;
                            END;

                            D_XML :=
                                   '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>PROVINCIA NASCITA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || d_denominazione_provincia
                                || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['
                                || d_denominazione_provincia2
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        END IF;
                    END IF;

                    IF NVL (sel_storico_anag.comune_nas, -1) !=
                       NVL (D_NEW_comune_nas, -1)
                    THEN                              -- MODIFICATO comune_nas
                        IF     SEL_STORICO_ANAG.comune_nas IS NULL
                           AND D_NEW_comune_nas IS NOT NULL
                        THEN
                            IF d_new_PROVINCIA_NAS IS NOT NULL
                            THEN                               --rev.24 inizio
                                D_XML :=
                                       '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COMUNE NASCITA</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                                    || ad4_comuni_tpk.get_denominazione (
                                           d_new_PROVINCIA_NAS,
                                           d_new_COMUNE_NAS)
                                    || ']]></LABEL_PARTE3></ROW>'
                                    || CHR (10);
                            ELSE                  -- provincia non valorizzata
                                D_XML :=
                                       '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COMUNE NASCITA</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                                    || ' COMUNE NON CODIFICATO: '
                                    || sel_storico_anag.COMUNE_NAS
                                    || ']]></LABEL_PARTE3></ROW>'
                                    || CHR (10);
                            --rev.24 fine
                            END IF;

                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSIF     SEL_STORICO_ANAG.comune_nas IS NOT NULL
                              AND D_NEW_comune_nas IS NULL
                        THEN
                            IF SEL_STORICO_ANAG.provincia_NAS IS NOT NULL
                            THEN                               --rev.24 inizio
                                D_XML :=
                                       '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>COMUNE NASCITA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                    || ad4_comuni_tpk.get_denominazione (
                                           SEL_STORICO_ANAG.provincia_NAS,
                                           SEL_STORICO_ANAG.COMUNE_NAS)
                                    || ']]></LABEL_PARTE2></ROW>'
                                    || CHR (10);
                            ELSE                  -- provincia non valorizzata
                                D_XML :=
                                       '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>COMUNE NASCITA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                    || ' COMUNE NON CODIFICATO: '
                                    || sel_storico_anag.COMUNE_NAS
                                    || ']]></LABEL_PARTE2></ROW>'
                                    || CHR (10);
                            --rev.24 fine
                            END IF;

                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSE
                            D_XML := NULL;

                            IF SEL_STORICO_ANAG.provincia_NAS IS NOT NULL
                            THEN                               --rev.24 inizio
                                D_XML :=
                                       '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>COMUNE NASCITA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                    || ad4_comuni_tpk.get_denominazione (
                                           SEL_STORICO_ANAG.provincia_NAS,
                                           SEL_STORICO_ANAG.COMUNE_NAS)
                                    || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA[';
                            ELSE                  -- provincia non valorizzata
                                D_XML :=
                                       '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>COMUNE NASCITA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                    || ' COMUNE NON CODIFICATO: '
                                    || sel_storico_anag.COMUNE_NAS
                                    || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['
                                    || ad4_comuni_tpk.get_denominazione (
                                           d_new_PROVINCIA_NAS,
                                           d_new_COMUNE_NAS)
                                    || ']]></LABEL_PARTE3></ROW>'
                                    || CHR (10);
                            --rev.24 fine
                            END IF;

                            IF d_new_PROVINCIA_NAS IS NOT NULL
                            THEN                               --rev.24 inizio
                                D_XML :=
                                       D_XML
                                    || ad4_comuni_tpk.get_denominazione (
                                           d_new_PROVINCIA_NAS,
                                           d_new_COMUNE_NAS)
                                    || ']]></LABEL_PARTE3></ROW>'
                                    || CHR (10);
                            ELSE                  -- provincia non valorizzata
                                D_XML :=
                                       D_XML
                                    || ' COMUNE NON CODIFICATO: '
                                    || d_new_COMUNE_NAS
                                    || ']]></LABEL_PARTE3></ROW>'
                                    || CHR (10);
                            --rev.24 fine
                            END IF;

                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        END IF;
                    END IF;

                    IF NVL (sel_storico_anag.LUOGO_nas,
                            'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX') !=
                       NVL (D_NEW_LUOGO_nas,
                            'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
                    THEN                               -- MODIFICATO LUOGO_nas
                        IF     SEL_STORICO_ANAG.LUOGO_nas IS NULL
                           AND D_NEW_LUOGO_nas IS NOT NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>LUOGO NASCITA</LABEL_PARTE1><LABEL_PARTE3>'
                                || D_NEW_LUOGO_nas
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSIF     SEL_STORICO_ANAG.LUOGO_nas IS NOT NULL
                              AND D_NEW_LUOGO_nas IS NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>LUOGO NASCITA</LABEL_PARTE1><LABEL_PARTE2>'
                                || SEL_STORICO_ANAG.LUOGO_NAS
                                || ']]></LABEL_PARTE2></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSE
                            D_XML :=
                                   '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>LUOGO NASCITA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.LUOGO_NAS
                                || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['
                                || d_new_LUOGO_NAS
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        END IF;
                    END IF;

                    IF NVL (sel_storico_anag.CODICE_FISCALE,
                            'xxxxxxxxxxxxxxxxx') !=
                       NVL (D_NEW_CODICE_FISCALE, 'xxxxxxxxxxxxxxxxx')
                    THEN                                      -- MODIFICATO CF
                        IF     sel_storico_anag.CODICE_FISCALE IS NULL
                           AND D_NEW_CODICE_FISCALE IS NOT NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>CODICE FISCALE</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                                || D_NEW_CODICE_FISCALE
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSIF     SEL_STORICO_ANAG.CODICE_FISCALE IS NOT NULL
                              AND D_NEW_CODICE_FISCALE IS NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>CODICE FISCALE</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.CODICE_FISCALE
                                || ']]></LABEL_PARTE2></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSE
                            D_XML :=
                                   '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>CODICE FISCALE</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.CODICE_FISCALE
                                || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['
                                || d_new_CODICE_FISCALE
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        END IF;
                    END IF;

                    IF NVL (sel_storico_anag.CODICE_FISCALE_ESTERO,
                            'xxxxxxxxxxxxxxxxx') !=
                       NVL (D_NEW_CODICE_FISCALE_ESTERO, 'xxxxxxxxxxxxxxxxx')
                    THEN                                      -- MODIFICATO CF
                        IF     sel_storico_anag.CODICE_FISCALE_ESTERO IS NULL
                           AND D_NEW_CODICE_FISCALE_ESTERO IS NOT NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>ID. FISCALE ESTERO</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                                || D_NEW_CODICE_FISCALE_ESTERO
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSIF     SEL_STORICO_ANAG.CODICE_FISCALE_ESTERO
                                      IS NOT NULL
                              AND D_NEW_CODICE_FISCALE_ESTERO IS NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>ID. FISCALE ESTERO</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.CODICE_FISCALE_ESTERO
                                || ']]></LABEL_PARTE2></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSE
                            D_XML :=
                                   '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>ID. FISCALE ESTERO</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.CODICE_FISCALE_ESTERO
                                || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['
                                || d_new_CODICE_FISCALE_ESTERO
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        END IF;
                    END IF;

                    IF NVL (sel_storico_anag.PARTITA_IVA,
                            'xxxxxxxxxxxxxxxxx') !=
                       NVL (D_NEW_PARTITA_IVA, 'xxxxxxxxxxxxxxxxx')
                    THEN                                      -- MODIFICATO CF
                        IF     sel_storico_anag.PARTITA_IVA IS NULL
                           AND D_NEW_PARTITA_IVA IS NOT NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>PARTITA IVA</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                                || D_NEW_PARTITA_IVA
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSIF     SEL_STORICO_ANAG.PARTITA_IVA IS NOT NULL
                              AND D_NEW_PARTITA_IVA IS NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>PARTITA IVA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.PARTITA_IVA
                                || ']]></LABEL_PARTE2></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSE
                            D_XML :=
                                   '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>PARTITA IVA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.PARTITA_IVA
                                || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['
                                || d_new_PARTITA_IVA
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        END IF;
                    END IF;

                    IF NVL (sel_storico_anag.PARTITA_IVA_CEE, 'xxxx') !=
                       NVL (D_NEW_PARTITA_IVA_CEE, 'xxxx')
                    THEN                                      -- MODIFICATO CF
                        IF     sel_storico_anag.PARTITA_IVA_CEE IS NULL
                           AND D_NEW_PARTITA_IVA_CEE IS NOT NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>PARTITA IVA CEE</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                                || D_NEW_PARTITA_IVA_CEE
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSIF     SEL_STORICO_ANAG.PARTITA_IVA_CEE
                                      IS NOT NULL
                              AND D_NEW_PARTITA_IVA_CEE IS NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>PARTITA IVA CEE</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.PARTITA_IVA_CEE
                                || ']]></LABEL_PARTE2></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSE
                            D_XML :=
                                   '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>PARTITA IVA CEE</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.PARTITA_IVA_CEE
                                || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['
                                || d_new_PARTITA_IVA_CEE
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        END IF;
                    END IF;

                    IF NVL (sel_storico_anag.STATO_CEE, 'xxxx') !=
                       NVL (D_NEW_STATO_CEE, 'xxxx')
                    THEN                                      -- MODIFICATO CF
                        IF     sel_storico_anag.STATO_CEE IS NULL
                           AND D_NEW_STATO_CEE IS NOT NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>STATO CEE</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                                || D_NEW_STATO_CEE
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSIF     SEL_STORICO_ANAG.STATO_CEE IS NOT NULL
                              AND D_NEW_STATO_CEE IS NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>STATO CEE</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.STATO_CEE
                                || ']]></LABEL_PARTE2></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSE
                            D_XML :=
                                   '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>STATO CEE</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.STATO_CEE
                                || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['
                                || d_new_STATO_CEE
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        END IF;
                    END IF;

                    IF NVL (sel_storico_anag.CITTADINANZA, 'xxxx') !=
                       NVL (D_NEW_CITTADINANZA, 'xxxx')
                    THEN                                      -- MODIFICATO CF
                        IF     sel_storico_anag.CITTADINANZA IS NULL
                           AND D_NEW_CITTADINANZA IS NOT NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>CITTADINANZA</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                                || D_NEW_CITTADINANZA
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSIF     SEL_STORICO_ANAG.CITTADINANZA IS NOT NULL
                              AND D_NEW_CITTADINANZA IS NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>CITTADINANZA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.CITTADINANZA
                                || ']]></LABEL_PARTE2></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSE
                            D_XML :=
                                   '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>CITTADINANZA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.CITTADINANZA
                                || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['
                                || d_new_CITTADINANZA
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        END IF;
                    END IF;

                    IF NVL (sel_storico_anag.gruppo_ling, 'xxxx') !=
                       NVL (D_NEW_GRUPPO_LING, 'xxxx')
                    THEN                                      -- MODIFICATO CF
                        IF     sel_storico_anag.GRUPPO_LING IS NULL
                           AND D_NEW_GRUPPO_LING IS NOT NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>GRUPPO LINGUISTICO</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                                || D_NEW_GRUPPO_LING
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSIF     SEL_STORICO_ANAG.GRUPPO_LING IS NOT NULL
                              AND D_NEW_GRUPPO_LING IS NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>GRUPPO LINGUISTICO</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.GRUPPO_LING
                                || ']]></LABEL_PARTE2></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSE
                            D_XML :=
                                   '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>GRUPPO LINGUISTICO</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.GRUPPO_LING
                                || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['
                                || d_new_GRUPPO_LING
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        END IF;
                    END IF;

                    IF NVL (sel_storico_anag.COMPETENZA, 'xxxxxxxxxxx') !=
                       NVL (D_NEW_COMPETENZA, 'xxxxxxxxxxx')
                    THEN                                      -- MODIFICATO CF
                        IF     sel_storico_anag.COMPETENZA IS NULL
                           AND D_NEW_COMPETENZA IS NOT NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COMPETENZA</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                                || D_NEW_COMPETENZA
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSIF     SEL_STORICO_ANAG.COMPETENZA IS NOT NULL
                              AND D_NEW_COMPETENZA IS NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>COMPETENZA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.COMPETENZA
                                || ']]></LABEL_PARTE2></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSE
                            D_XML :=
                                   '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>COMPETENZA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.COMPETENZA
                                || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['
                                || d_new_COMPETENZA
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        END IF;
                    END IF;

                    IF NVL (sel_storico_anag.COMPETENZA_ESCLUSIVA, 'xx') !=
                       NVL (D_NEW_COMPETENZA_ESCLUSIVA, 'xx')
                    THEN                                      -- MODIFICATO CF
                        IF     sel_storico_anag.COMPETENZA_ESCLUSIVA IS NULL
                           AND D_NEW_COMPETENZA_ESCLUSIVA IS NOT NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COMPETENZA ESCLUSIVA</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                                || D_NEW_COMPETENZA_ESCLUSIVA
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSIF     SEL_STORICO_ANAG.COMPETENZA_ESCLUSIVA
                                      IS NOT NULL
                              AND D_NEW_COMPETENZA_ESCLUSIVA IS NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>COMPETENZA ESCLUSIVA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.COMPETENZA_esclusiva
                                || ']]></LABEL_PARTE2></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSE
                            D_XML :=
                                   '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>COMPETENZA ESCLUSIVA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.COMPETENZA_esclusiva
                                || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['
                                || d_new_COMPETENZA_esclusiva
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        END IF;
                    END IF;

                    IF NVL (sel_storico_anag.TIPO_SOGGETTO, 'xx') !=
                       NVL (D_NEW_TIPO_SOGGETTO, 'xx')
                    THEN                                      -- MODIFICATO CF
                        IF     sel_storico_anag.TIPO_SOGGETTO IS NULL
                           AND D_NEW_TIPO_SOGGETTO IS NOT NULL
                        THEN
                            BEGIN
                                d_des_tipo_soggetto :=
                                    tipi_soggetto_tpk.get_descrizione (
                                        D_NEW_TIPO_SOGGETTO);
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    d_des_tipo_soggetto :=
                                        D_NEW_TIPO_SOGGETTO;
                            END;

                            D_XML :=
                                   '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>TIPO SOGGETTO</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                                || d_des_tipo_soggetto
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSIF     SEL_STORICO_ANAG.TIPO_SOGGETTO IS NOT NULL
                              AND D_NEW_TIPO_SOGGETTO IS NULL
                        THEN
                            BEGIN
                                d_des_tipo_soggetto :=
                                    tipi_soggetto_tpk.get_descrizione (
                                        SEL_STORICO_ANAG.TIPO_SOGGETTO);
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    d_des_tipo_soggetto :=
                                        SEL_STORICO_ANAG.TIPO_SOGGETTO;
                            END;

                            D_XML :=
                                   '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>TIPO SOGGETTO</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || d_des_tipo_soggetto
                                || ']]></LABEL_PARTE2></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSE
                            BEGIN
                                d_des_tipo_soggetto :=
                                    tipi_soggetto_tpk.get_descrizione (
                                        D_NEW_TIPO_SOGGETTO);
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    d_des_tipo_soggetto :=
                                        D_NEW_TIPO_SOGGETTO;
                            END;

                            BEGIN
                                d_des_tipo_soggetto2 :=
                                    tipi_soggetto_tpk.get_descrizione (
                                        SEL_STORICO_ANAG.TIPO_SOGGETTO);
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    d_des_tipo_soggetto2 :=
                                        SEL_STORICO_ANAG.TIPO_SOGGETTO;
                            END;

                            D_XML :=
                                   '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>TIPO SOGGETTO</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || d_des_tipo_soggetto2
                                || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['
                                || d_des_tipo_soggetto
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        END IF;
                    END IF;

                    IF NVL (sel_storico_anag.FINE_VALIDITA,
                            TO_DATE (3333333, 'J')) !=
                       NVL (D_NEW_FINE_VALIDITA, TO_DATE (3333333, 'J'))
                    THEN                           -- MODIFICATO FINE_VALIDITA
                        IF     SEL_STORICO_ANAG.FINE_VALIDITA IS NULL
                           AND D_NEW_FINE_VALIDITA IS NOT NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>FINE VALIDITA''</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                                || TO_CHAR (D_NEW_FINE_VALIDITA,
                                            'dd/mm/yyyy')
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSIF     SEL_STORICO_ANAG.FINE_VALIDITA IS NOT NULL
                              AND D_NEW_FINE_VALIDITA IS NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>FINE VALIDITA''</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || TO_CHAR (SEL_STORICO_ANAG.FINE_VALIDITA,
                                            'dd/mm/yyyy')
                                || ']]></LABEL_PARTE2></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSE
                            D_XML :=
                                   '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>FINE VALIDITA''</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || TO_CHAR (SEL_STORICO_ANAG.FINE_VALIDITA,
                                            'dd/mm/yyyy')
                                || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['
                                || TO_CHAR (D_NEW_FINE_VALIDITA,
                                            'dd/mm/yyyy')
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        END IF;
                    END IF;

                    IF NVL (sel_storico_anag.STATO_SOGGETTO, 'xxxx') !=
                       NVL (D_NEW_STATO_SOGGETTO, 'xxxx')
                    THEN                                      -- MODIFICATO CF
                        IF     sel_storico_anag.STATO_SOGGETTO IS NULL
                           AND D_NEW_STATO_SOGGETTO IS NOT NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>STATO SOGGETTO</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                                || D_NEW_des_STATO
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSIF     SEL_STORICO_ANAG.STATO_SOGGETTO IS NOT NULL
                              AND D_NEW_STATO_SOGGETTO IS NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>STATO SOGGETTO</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.des_STATO
                                || ']]></LABEL_PARTE2></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSE
                            D_XML :=
                                   '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>STATO SOGGETTO</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.des_STATO
                                || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['
                                || D_NEW_des_STATO
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        END IF;
                    END IF;

                    IF NVL (sel_storico_anag.NOTE, 'XxXx') !=
                       NVL (D_NEW_NOTE, 'XxXx')
                    THEN                                      -- MODIFICATO CF
                        IF     sel_storico_anag.NOTE IS NULL
                           AND D_NEW_NOTE IS NOT NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>NOTE</LABEL_PARTE1><LABEL_PARTE3><![CDATA['
                                || D_NEW_NOTE
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSIF     SEL_STORICO_ANAG.NOTE IS NOT NULL
                              AND D_NEW_NOTE IS NULL
                        THEN
                            D_XML :=
                                   '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>NOTE</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.NOTE
                                || ']]></LABEL_PARTE2></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        ELSE
                            D_XML :=
                                   '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>NOTE</LABEL_PARTE1><LABEL_PARTE2><![CDATA['
                                || SEL_STORICO_ANAG.NOTE
                                || ']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['
                                || d_new_NOTE
                                || ']]></LABEL_PARTE3></ROW>'
                                || CHR (10);
                            DBMS_LOB.writeappend (d_tree_storico,
                                                  LENGTH (d_xml),
                                                  d_xml);
                        END IF;
                    END IF;

                    D_XML := '</ROWSET></ROW>' || CHR (10);
                    DBMS_LOB.writeappend (d_tree_storico,
                                          LENGTH (d_xml),
                                          d_xml);
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        NULL;
                END;
            ELSIF sel_storico_anag.operazione = 'D'
            THEN                                         --modifica del record
                d_utente :=
                    NVL (sel_storico_anag.utente_aggiornamento,
                         sel_storico_anag.utente);
                d_des_utente_aggiornamento :=
                    ad4_soggetto.get_denominazione (
                        ad4_utente.get_soggetto (d_utente, 'N', 0));

                IF d_des_utente_aggiornamento IS NOT NULL
                THEN
                    d_des_utente_aggiornamento :=
                           NVL (ad4_utente.get_nominativo (d_utente, 'N', 0),
                                d_utente)
                        || ' - '
                        || d_des_utente_aggiornamento;
                ELSE
                    d_des_utente_aggiornamento :=
                        NVL (ad4_utente.get_nominativo (d_utente, 'N', 0),
                             d_utente);
                END IF;

                D_XML :=
                       '<ROWSET><ROW><LABEL_PARTE1>Anagrafica con decorrenza '
                    || TO_CHAR (sel_storico_anag.dal, 'DD/MM/YYYY')
                    || ' eliminato da '
                    || d_des_utente_aggiornamento
                    || ' il '
                    || TO_CHAR (sel_storico_anag.data,
                                'DD/MM/YYYY hh24:MI:SS')
                    || '</LABEL_PARTE1></ROW></ROWSET>'
                    || CHR (10);
                DBMS_LOB.writeappend (d_tree_storico, LENGTH (d_xml), d_xml);
            END IF;
        END LOOP;

        D_XML := '</ROWSET>' || CHR (10);
        DBMS_LOB.writeappend (d_tree_storico, LENGTH (d_xml), d_xml);
        RETURN d_tree_storico;
    END;

    FUNCTION get_denominazione_ricerca (p_ni    IN anagrafici.ni%TYPE,
                                        p_dal   IN anagrafici.dal%TYPE)
        RETURN VARCHAR2
    IS
        retval   VARCHAR2 (2000);
    BEGIN
        BEGIN
            SELECT denominazione_ricerca
              INTO retval
              FROM anagrafici
             WHERE     ni = p_ni
                   AND p_dal BETWEEN dal AND NVL (al, TO_DATE (3333333, 'j'));
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                retval := NULL;
        END;

        RETURN retval;
    END;


    FUNCTION get_tipo_struttura (p_ni NUMBER)
        RETURN VARCHAR2
    IS
        /******************************************************************************
          NOME:        get_tipo_struttura.
          DESCRIZIONE: Valorizza il tipo_entita.
                       AM = Amministrazione
                       AO = Area Organizzativa
                       UO = Unita Organizzativa
                       null = ni NON in Struttura Organizzativa
          ARGOMENTI:   p_ni    number campo NI.
          NOTE:        Valorizza il parametro p_ni, se nullo, con il primo valore libero
                       della sequence SOGG_SQ.
          REVISIONI:
          Rev. Data       Autore Descrizione
          ---- ---------- ------ ------------------------------------------------------
          007  25/09/2018 SNeg     Prima emissione.
         ******************************************************************************/
        v_tipo_struttura   VARCHAR2 (2);
    BEGIN
        BEGIN
            EXECUTE IMMEDIATE   'select max(tipo_entita)'
                             || ' from so4_soggetti_struttura  where ni ='
                             || p_ni
                INTO v_tipo_struttura;
        EXCEPTION
            WHEN OTHERS
            THEN
                v_tipo_struttura := NULL;
        END;

        RETURN v_tipo_struttura;
    END;


    PROCEDURE allinea_anagrafica_amm_da_ipa (
        p_ni                      IN ANAGRAFICI.ni%TYPE DEFAULT NULL,
        p_cognome                 IN ANAGRAFICI.cognome%TYPE,
        p_nome                    IN ANAGRAFICI.nome%TYPE DEFAULT NULL,
        p_sesso                   IN ANAGRAFICI.sesso%TYPE DEFAULT NULL,
        p_data_nas                IN ANAGRAFICI.data_nas%TYPE DEFAULT NULL,
        p_provincia_nas           IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL,
        p_comune_nas              IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL,
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
        p_note_anag               IN ANAGRAFICI.note%TYPE DEFAULT NULL,
        ----- dati residenza
        p_descrizione_residenza   IN RECAPITI.descrizione%TYPE DEFAULT NULL,
        p_indirizzo_res           IN RECAPITI.indirizzo%TYPE DEFAULT NULL,
        p_provincia_res           IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL,
        p_comune_res              IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL,
        p_cap_res                 IN RECAPITI.cap%TYPE DEFAULT NULL,
        p_presso                  IN RECAPITI.presso%TYPE DEFAULT NULL,
        p_importanza              IN RECAPITI.importanza%TYPE DEFAULT NULL,
        ---- mail
        p_mail                    IN CONTATTI.valore%TYPE DEFAULT NULL,
        p_note_mail               IN CONTATTI.note%TYPE DEFAULT NULL,
        p_importanza_mail         IN CONTATTI.importanza%TYPE DEFAULT NULL,
        ---- tel_res
        p_tel_res                 IN CONTATTI.valore%TYPE DEFAULT NULL,
        p_note_tel_res            IN CONTATTI.note%TYPE DEFAULT NULL,
        p_importanza_tel_res      IN CONTATTI.importanza%TYPE DEFAULT NULL,
        ---- fax_res
        p_fax_res                 IN CONTATTI.valore%TYPE DEFAULT NULL,
        p_note_fax_res            IN CONTATTI.note%TYPE DEFAULT NULL,
        p_importanza_fax_res      IN CONTATTI.importanza%TYPE DEFAULT NULL,
        ---- dati generici
        p_utente                  IN ANAGRAFICI.utente%TYPE DEFAULT NULL,
        p_data_agg                IN ANAGRAFICI.data_agg%TYPE DEFAULT SYSDATE)
    IS
        /******************************************************************************
           NOME:        ALLINEA_ANAGRAFICA_E_RESIDENZA
           DESCRIZIONE: Introdotta per la gestione degli aggiornamenti di dati anagrafici
                        di residenza (escluso mail) durante lo scarico IPA.
           ARGOMENTI:   Info sui record da sistemare
           NOTE:
           REVISIONI:
           Rev. Data       Autore Descrizione
           ---- ---------- ------ ------------------------------------------------------
           021  18/03/2019 SNeg  Creazione allinea_anagrafica_e_residenza
           042  21/12/2020 SNeg  Proteggere gli apici durante modifica denominazione_ricerca Bug #46872
          ******************************************************************************/
        v_indirizzo_web    anagrafe_soggetti.indirizzo_WEB%TYPE;
        v_old_anagrafica   anagrafici%ROWTYPE;
        v_id_anagrafica    anagrafici.id_anagrafica%TYPE;
    BEGIN
        IF p_competenza != 'AGS' OR p_competenza_esclusiva != 'E' --60726
        THEN
            raise_application_error (
                -20999,
                   si4.get_error ('A10089')
                || ' (Utilizzabile solo x scarico IPA)');
        END IF;

        -- estrazione dal e al dal soggetto presente x aggiornare i contenuti
        SELECT *
          INTO v_old_anagrafica
          FROM anagrafici
         WHERE     ni = p_ni
               AND SYSDATE BETWEEN dal AND NVL (al, TO_DATE ('3333333', 'j'))
               AND al IS NULL;

        -- estrazione mail soggetto
        SELECT indirizzo_web
          INTO v_indirizzo_web
          FROM anagrafe_soggetti
         WHERE     ni = p_ni
               AND SYSDATE BETWEEN dal AND NVL (al, TO_DATE ('3333333', 'j'))
               AND al IS NULL;

        v_id_anagrafica :=
            anagrafici_pkg.upd_anag_dom_e_res_e_mail (
                p_ni                      => p_ni,
                p_dal                     => v_old_anagrafica.dal,
                p_al                      => v_old_anagrafica.al,
                p_cognome                 => p_cognome,
                p_nome                    => p_nome,
                p_sesso                   => p_sesso,
                p_data_nas                => p_data_nas,
                p_provincia_nas           => p_provincia_nas,
                p_comune_nas              => p_comune_nas,
                p_luogo_nas               => p_luogo_nas,
                p_codice_fiscale          => p_codice_fiscale,
                p_codice_fiscale_estero   => p_codice_fiscale_estero,
                p_partita_iva             => p_partita_iva,
                p_cittadinanza            => p_cittadinanza,
                p_gruppo_ling             => p_gruppo_ling,
                p_competenza              => p_competenza,
                p_competenza_esclusiva    => p_competenza_esclusiva,
                p_tipo_soggetto           => p_tipo_soggetto,
                p_stato_cee               => p_stato_cee,
                p_partita_iva_cee         => p_partita_iva_cee,
                p_fine_validita           => p_fine_validita,
                p_stato_soggetto          => p_stato_soggetto,
                p_denominazione           => '',
                p_note_anag               => p_note_anag,
                ----- dati residenza
                p_descrizione_residenza   => p_descrizione_residenza,
                p_indirizzo_res           => p_indirizzo_res,
                p_provincia_res           => p_provincia_res,
                p_comune_res              => p_comune_res,
                p_cap_res                 => p_cap_res,
                p_presso                  => p_presso,
                p_importanza              => p_importanza,
                ---- mail NON VIENE GESTITA ripasso quella attuale
                p_mail                    => v_indirizzo_web,
                --      p_note_mail               => p_note_mail             ,
                --      p_importanza_mail         => p_importanza_mail       ,
                --- tel_res
                p_tel_res                 => p_tel_res,
                p_note_tel_res            => p_note_tel_res,
                p_importanza_tel_res      => p_importanza_tel_res,
                ---- fax_res
                p_fax_res                 => p_fax_res,
                p_note_fax_res            => p_note_fax_res,
                p_importanza_fax_res      => p_importanza_fax_res,
                -- dati DOMICILIO
                p_descrizione_dom         => '',
                p_indirizzo_dom           => '',
                p_provincia_dom           => '',
                p_comune_dom              => '',
                p_cap_dom                 => '',
                --- tel dom
                p_tel_dom                 => '',
                --    , p_id_tipo_contatto
                p_note_tel_dom            => '',
                p_importanza_tel_dom      => '',
                --- fax dom
                p_fax_dom                 => '',
                --    , p_id_tipo_contatto
                p_note_fax_dom            => '',
                ---- dati generici
                p_utente                  => p_utente,
                p_data_agg                => p_data_agg,
                p_batch                   => 0                  -- = NON batch
                                              );
        -- valorizzazione anche denominazione ricerca
        ANAGRAFICI_TPK.UPD_COLUMN (
            v_old_anagrafica.id_anagrafica,
            'DENOMINAZIONE_RICERCA',
            replace (ANAGRAFICI_TPK.GET_DENOMINAZIONE (v_old_anagrafica.id_anagrafica), '''','''''')); --rev. 42
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20999,
                   si4.get_error ('A10089')
                || ' Non trovato record valido ad oggi'); -- Impossibile determinare record da aggiornare.);
    -- se non esiste record aperto
    END;

    FUNCTION is_ultimo_dal (p_ni NUMBER, p_dal date)
        RETURN NUMBER
    IS
    /******************************************************************************
         NOME:        is_ultimo_dal.
         DESCRIZIONE: Verifica se il dal passato corrisponde all'ultimo record temporale x quel ni
         ARGOMENTI:   p_ni   number campo NI.
                      p_dal  date   data da verificare.
         NOTE:       0 = e ultimo dal
                     1 = NON e ultimo dal
         REVISIONI:
         Rev. Data       Autore Descrizione
         ---- ---------- ------ ------------------------------------------------------
         041  20/11/2020   SNeg  Impedire aggiornamento di dati storici Introdotta function is_ultimo_dal Bug #34914
        ******************************************************************************/
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_num_ni_dal   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO v_num_ni_dal
          FROM anagrafici
         WHERE ni = p_ni
           AND dal > p_dal;
        if v_num_ni_dal = 0 then
           v_num_ni_dal := 1;
        else
           v_num_ni_dal := 0;
        end if;
        RETURN v_num_ni_dal;
    END;


BEGIN
    -- blocco del package
    -- inserimento degli errori nella tabella
    s_error_table (s_comp_escl_no_progetto_number) :=
        si4.get_error (s_comp_escl_no_progetto_msg);
    s_error_table (s_comp_escl_altrui_number) :=
        si4.get_error (s_comp_escl_altrui_msg);
    s_error_table (s_comp_altrui_number) := si4.get_error (s_comp_altrui_msg);
    s_error_table (s_comu_sigla_prov_num) :=
        si4.get_error (s_comu_sigla_prov_msg);
    s_error_table (s_non_trovato_comune_num) :=
        si4.get_error (s_non_trovato_comune_msg);
    s_error_table (s_non_trovato_tipo_sogg_num) :=
        si4.get_error (s_non_trovato_tipo_sogg_msg);
    s_error_table (s_trovato_blocco_record_num) :=
        si4.get_error (s_trovato_blocco_record_msg);
    s_error_table (s_trovato_recapito_num) :=
        si4.get_error (s_trovato_recapito_msg);
    s_error_table (s_non_modificabile_storico_num) :=
        si4.get_error (s_non_modificabile_storico_msg);

    -- controllo indice intermedia
    BEGIN
      d_indice_intermedia := nvl(registro_utility.leggi_stringa  ( 'PRODUCTS/ANAGRAFICA',  'IndiceIntermedia',0),'NO'); --#54239
/*
        SELECT 'SI'
          INTO d_indice_intermedia
          FROM user_ind_columns c, user_indexes t
         WHERE     c.table_name = 'ANAGRAFICI'
               AND c.column_name = 'DENOMINAZIONE'
               AND t.table_name = 'ANAGRAFICI'
               AND c.index_name = t.index_name
               AND c.table_name = t.table_name
               AND index_type = 'DOMAIN';
*/
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            d_indice_intermedia := 'NO';
    END;
END;
/

