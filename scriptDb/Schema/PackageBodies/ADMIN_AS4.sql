CREATE OR REPLACE PACKAGE BODY Admin_As4
IS
    /******************************************************************************
     NOME:        Admin_Ad4
     DESCRIZIONE: Funzioni di amministrazione.
     ANNOTAZIONI: .
    REVISIONI:
     Rev. Data       Autore Descrizione
     ---- ---------- ------ ------------------------------------------------------
     00   10/06/2019 SNegro Creazione.
     01  02/03/2020 SNeg   Correzione errori
     02  09/06/2020 SNeg   Aggiunta F_SCEGLI_FRA_ANAGRAFE_SOGGETTI Bug #42600
    ******************************************************************************/
    s_revisione_body   CONSTANT AFC.t_revision := '002';

    FUNCTION versione
        RETURN VARCHAR2
    IS
    /******************************************************************************
     NOME:        versione
     DESCRIZIONE: Versione e revisione di distribuzione del package.
     RITORNA:     varchar2 stringa contenente versione e revisione.
     NOTE:        Primo numero  : versione compatibilita' del Package.
                  Secondo numero: revisione del Package specification.
                  Terzo numero  : revisione del Package body.
     REVISIONI:
     Rev. Data       Autore Descrizione
     ---- ---------- ------ ------------------------------------------------------
     00   10/06/2019 SNegro Creazione.
    ******************************************************************************/
    BEGIN
        RETURN AFC.version (s_revisione, s_revisione_body);
    END versione;

    PROCEDURE GRANT_TO
/******************************************************************************
NOME:        GRANT_TO
DESCRIZIONE: Assegna le grant all'utente passato.
PARAMETRI:   p_user      utente oracle a cui devono essere assegnate le grant.
             p_what      DB:  oggetti di base
                         CM:  gestione Comuni
                         BS:  gestione Banche e Sportelli
                         ASL: gestione ASL
                         ALL: tutti gli oggetti
                         nome singolo oggetto
                         default 'ALL'.
             p_privilege privilegio da attribuire all'utente p_user per
                         l'accesso alle tabelle (per package, procedure e
                         function viene dato sempre execute).
                         default 'all'
RITORNA:
NOTE:        --
REVISIONI:
Rev. Data       Autore Descrizione
---- ---------- ------ ------------------------------------------------------
000  10/06/2019 SN    Prima emissione.
******************************************************************************/
   (p_user           IN VARCHAR2,
    p_what           IN VARCHAR2 DEFAULT 'ALL',
    p_privilege      IN VARCHAR2 DEFAULT 'all',
    p_owner          IN VARCHAR2 DEFAULT USER,
    p_grant_option   IN VARCHAR2 DEFAULT 'NO')
    IS
        d_errore         VARCHAR2 (32767);
        d_grant_option   VARCHAR2 (2000);
        d_statement      VARCHAR2 (1000);
    BEGIN
        IF UPPER (p_grant_option) IN ('S',
                                      'SI',
                                      'Y',
                                      'YES')
        THEN
            d_grant_option := ' with grant option ';
        ELSE
            d_grant_option := '';
        END IF;

        -- TABLE - VIEW
        FOR j IN NVL (TabTVDB.FIRST, 1) .. NVL (TabTVDB.LAST, 0)
        LOOP
            BEGIN
                d_statement :=
                       'grant '
                    || p_privilege
                    || ' on '
                    || TabTVDB (j).object_name
                    || ' to '
                    || p_user
                    || d_grant_option;

                EXECUTE IMMEDIATE (d_statement);
            EXCEPTION
                WHEN OTHERS
                THEN
                    d_errore :=
                           d_errore
                        || CHR (10)
                        || 'ERRORE '
                        || d_statement
                        || ': '
                        || SQLERRM;
            END;
        END LOOP;

        -- FUNCTION / PACKAGE
        FOR j IN NVL (TabPDB.FIRST, 1) .. NVL (TabPDB.LAST, 0)
        LOOP
            BEGIN
                d_statement :=
                       'grant '
                    || 'execute'
                    || ' on '
                    || TabPDB (j).object_name
                    || ' to '
                    || p_user
                    || d_grant_option;

                EXECUTE IMMEDIATE (d_statement);
            EXCEPTION
                WHEN OTHERS
                THEN
                    d_errore :=
                           d_errore
                        || CHR (10)
                        || 'ERRORE '
                        || d_statement
                        || ': '
                        || SQLERRM;
            END;
        END LOOP;

        IF d_errore IS NOT NULL
        THEN
            raise_application_error (-20999, d_errore);
        END IF;
    END GRANT_TO;

    PROCEDURE GRANT_TO_ALL
    /******************************************************************************
    NOME:        GRANT_TO_ALL
    DESCRIZIONE: Assegna le grant a tutti gli utenti oracle per cui esiste almeno
                 un record nella tabella ISTANZE.
    ARGOMENTI:   --
    NOTE:        --
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  28/11/2005 MM     Prima emissione.
    001  02/07/2007 MM     Lancio GRANT_TO_REVOKE_FROM_ALL.
   ******************************************************************************/
   (p_what           IN VARCHAR2 DEFAULT 'ALL',
    p_privilege      IN VARCHAR2 DEFAULT 'all',
    p_owner          IN VARCHAR2 DEFAULT USER,
    p_grant_option   IN VARCHAR2 DEFAULT 'NO')
    IS
        d_errore   VARCHAR2 (32767);
        d_statement      VARCHAR2 (1000);
    BEGIN
        FOR v_user IN (SELECT DISTINCT user_oracle
                         FROM ad4_istanze)
        LOOP
            BEGIN
                grant_to (p_user           => v_user.user_oracle,
                          p_what           => p_what,
                          p_privilege      => p_privilege,
                          p_owner          => p_owner,
                          p_grant_option   => p_grant_option);
            EXCEPTION
                WHEN OTHERS
                THEN
                    d_errore :=
                           d_errore
                        || CHR (10)
                        || 'ERRORE '
                        || d_statement
                        || ': '
                        || SQLERRM;
            END;
        END LOOP;

        IF d_errore IS NOT NULL
        THEN
            raise_application_error (-20999, d_errore);
        END IF;
    END GRANT_TO_ALL;


    PROCEDURE add_DBTabT (p_objectname VARCHAR2)
    IS
    BEGIN
        b_index := b_index + 1;
        TabTVDB (b_index).object_name := p_objectname;
    END;

    PROCEDURE add_DBTabP (p_objectname VARCHAR2)
    IS
    BEGIN
        b_index := b_index + 1;
        TabPDB (b_index).object_name := p_objectname;
    END;
 /******************************************************************************
 NOME:        VALIDATE_PUBLIC_SYNONYM
 DESCRIZIONE: Tenta query su sinonimi pubblici per fare compilazione automatica
 ARGOMENTI:   p_user IN VARCHAR2 User a cui appartengono gli oggetti il cui
                                 sinonimo pubblico e da compilare.
 ECCEZIONI:
 RITORNA:     numero di oggetti che non si compilano.
ANNOTAZIONI:
******************************************************************************/
BEGIN

    -- Riempie la tabella TabAS4 con gli oggetti da gestire
    b_index := 0;
    -- Table / View DB
   add_DBTabT ('AS4_V_ANAGRAFICI');
   add_DBTabT ('AS4_V_ANAGRAFICI_STRUTTURA');
   add_DBTabT ('AS4_V_CONTATTI');
   add_DBTabT ('AS4_V_RECAPITI');
   add_DBTabT ('AS4_V_RECAPITI_CORRENTI');
   add_DBTabT ('AS4_V_SOGGETTI');
   add_DBTabT ('AS4_V_SOGGETTI_CORRENTI');
   add_DBTabT ('AS4_V_SOGGETTI_STORICO');
   add_DBTabT ('AS4_V_TIPI_CONTATTO');
   add_DBTabT ('AS4_V_TIPI_RECAPITO');
   add_DBTabT ('AS4_V_TIPI_SOGGETTO');
   add_DBTabT ('ANAGRAFE_SOGGETTI');
   add_DBTabT ('TIPI_SOGGETTO');
   add_DBTabT ('SOGGETTI');
   add_DBTabT ('STORICO_SOGGETTI');
   add_DBTabT ('STORICO_DATI_SOGGETTO');

   b_index := 0;
--    add_AS4TabT ('STORICO_DATI_SOGGETTI');
    add_DBTabT ('XX4_ANAGRAFE_SOGGETTI');
    add_DBTabT ('SOGG_SQ');
    add_DBTabT ('ANAGRAFICI');
    add_DBTabT ('RECAPITI');
    add_DBTabT ('TIPI_RECAPITO');
    add_DBTabT ('CONTATTI');
    add_DBTabT ('TIPI_CONTATTO');
    -- Riempie la tabella TabAS4 con oggetti in grant execute da gestire
    b_index := 0;
    add_DBTabP ('ANAGRAFE_SOGGETTI_REFRESH');
    add_DBTabP ('ANAGRAFE_SOGGETTI_PKG');
    add_DBTabP ('TIPI_SOGGETTO_TPK');
    add_DBTabP ('SI4');
    add_DBTabP ('ANAGRAFE_SOGGETTI_TPK');
    add_DBTabP ('ANAGRAFICI_PKG');
    add_DBTabP ('TIPI_SOGGETTO_TPK');
    add_DBTabP ('TIPI_RECAPITO_TPK');
    add_DBTabP ('TIPI_CONTATTO_TPK');
    add_DBTabP ('RECAPITI_TPK');
    add_DBTabP ('RECAPITI_PKG');
    add_DBTabP ('ANAGRAFICI_TPK');
    add_DBTabP ('ANAGRAFICI_PKG');
    add_DBTabP ('CONTATTI_TPK');
    add_DBTabP ('CONTATTI_PKG');
    add_DBTabP ('F_SCEGLI_FRA_ANAGRAFE_SOGGETTI');
    add_DBTabP ('USER_INTEGRAZIONI_AS4');

END ;
/

