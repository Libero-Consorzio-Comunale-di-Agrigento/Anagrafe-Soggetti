CREATE OR REPLACE PACKAGE BODY Utilitypackage
AS
   -- Variabile per memorizzare la versione Oracle
   s_oracle_ver        INTEGER;
   -- Per save e restore dei constraint
   v_progressivo       NUMBER := 0;
   v_errore            VARCHAR2 (4000);
   v_avvenuto_errore   BOOLEAN := FALSE;
   /******************************************************************************
    Compilazione di tutti gli oggetti invalidi presenti nel DB.
    %note Tenta la compilazione in cicli successivi. Termina la compilazione quando il numero degli oggetti invalidi non varia rispetto al ciclo precedente.
    REVISIONI.
    Rev. Data        Autore  Descrizione
    ---- ----------  ------  ----------------------------------------------------
    1    23/01/2001  MF      Inserimento commento.
    2    17/12/2003  MM      Aggiunta compilazione classi java.
    4    14/12/2006  MM      Introduzione del parametro p_java_class.
    5    08/10/2007  FT      Aggiunta compilazione synonym.
    6    12/12/2007  FT      compile_all: esclusione degli oggetti il cui nome inizia con 'BIN$'.
    7    08/01/2010  SNeg    Compilazione schema PUBLIC per validare i sinonimi pubblici.
    9    18/01/2010  SNeg     Correzione errore in caso di non riuscita compilazione usata execute immediate.
    10   20/04/2016  Sneg    Aggiunti metodi di save e restore constraint
    11   29/12/2020  SN     Chiusura cursore aperto Bug #47059
   ******************************************************************************/
   PROCEDURE Compile_All (p_java_class IN NUMBER DEFAULT 1 )
   IS
      d_obj_name   VARCHAR2 (30);
      d_obj_type   VARCHAR2 (30);
      d_command    VARCHAR2 (200);
      d_rows       INTEGER;
      d_old_rows   INTEGER;
      d_return     INTEGER;
      CURSOR c_obj
      IS
           SELECT   object_name, object_type
             FROM   OBJ
            WHERE   (object_type IN
                           ('PROCEDURE',
                            'TRIGGER',
                            'FUNCTION',
                            'PACKAGE',
                            'PACKAGE BODY',
                            'VIEW')
                     OR (object_type = 'JAVA CLASS' AND p_java_class = 1)
                     OR (object_type = 'SYNONYM' AND s_oracle_ver >= 10))
                    AND status = 'INVALID'
                    AND SUBSTR (object_name, 1, 4) != 'BIN$'
         ORDER BY   DECODE (object_type,
                            'PACKAGE', 1,
                            'PACKAGE BODY', 2,
                            'FUNCTION', 3,
                            'PROCEDURE', 4,
                            'VIEW', 5,
                            6),
                    object_name;
   BEGIN
      d_old_rows := 0;
      LOOP
         d_rows := 0;
         BEGIN
            OPEN c_obj;
            LOOP
               BEGIN
                  FETCH c_obj INTO   d_obj_name, d_obj_type;
                  EXIT WHEN c_obj%NOTFOUND;
                  d_rows := d_rows + 1;
                  IF d_obj_type = 'PACKAGE BODY'
                  THEN
                     d_command :=
                        'alter PACKAGE ' || d_obj_name || ' compile BODY';
                  ELSIF d_obj_type = 'JAVA CLASS'
                  THEN
                     d_command :=
                           'alter '
                        || d_obj_type
                        || ' "'
                        || d_obj_name
                        || '" compile';
                  ELSE
                     d_command :=
                           'alter '
                        || d_obj_type
                        || ' '
                        || d_obj_name
                        || ' compile';
                  END IF;
                  EXECUTE IMMEDIATE (d_command);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;
            END LOOP;
            CLOSE c_obj;
         END;
         IF d_rows = d_old_rows
         THEN
            EXIT;
         ELSE
            d_old_rows := d_rows;
         END IF;
      END LOOP;
      DBMS_UTILITY.compile_schema ('PUBLIC');
      IF d_rows > 0
      THEN
         RAISE_APPLICATION_ERROR (
            -20999,
               'Esistono n.'
            || TO_CHAR (d_rows)
            || ' Oggetti di DataBase non validabili !'
         );
      END IF;
   END Compile_All;
   /******************************************************************************
    Restituisce la versione e la data di distribuzione del package.
   ******************************************************************************/
   FUNCTION VERSIONE
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN 'V1.10 del 20/04/2016';
   END VERSIONE;
   /******************************************************************************
    Esegue lo statement passato.
    REVISIONI.
    Rev.  Data        Autore  Descrizione
    ----  ----------  ------  ------------------------------------------------------
    004   27/09/2005  MF      Cambio nomenclatura s_revisione e s_revisione_body. Tolta dipendenza get_stringParm da Package Si4. Inserimento SQL_execute per istruzioni dinamiche.
   ******************************************************************************/
   PROCEDURE SQL_execute (p_stringa VARCHAR2)
   IS
      d_cursor           INTEGER;
      d_rows_processed   INTEGER;
   BEGIN
      d_cursor := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE (d_cursor, p_stringa, DBMS_SQL.native);
      d_rows_processed := DBMS_SQL.EXECUTE (d_cursor);
      DBMS_SQL.CLOSE_CURSOR (d_cursor);
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_SQL.CLOSE_CURSOR (d_cursor);
         RAISE;
   END SQL_EXECUTE;
   /******************************************************************************
    Disabilitazione di tutti i Trigger e i Constraint di FK e Check.
    REVISIONI.
    Rev. Data        Autore  Descrizione
    ---- ----------  ------  ----------------------------------------------------
    1    19/10/2006  VA      Creazione
   ******************************************************************************/
   PROCEDURE Disable_All
   IS
   BEGIN
      /* Disabilito tutti i trigger dello user*/
      FOR c_table IN (SELECT   DISTINCT table_name
                        FROM   USER_TRIGGERS
                       WHERE   base_object_type = 'TABLE')
      LOOP
         sql_execute (
            'alter table ' || c_table.table_name || ' disable all triggers'
         );
      END LOOP;
      /* Disabilito i constraint di FK e Check*/
      FOR c_obj IN (SELECT   table_name, constraint_name
                      FROM   USER_CONSTRAINTS
                     WHERE   constraint_type IN ('R', 'C'))
      LOOP
         sql_execute(   'alter table '
                     || c_obj.table_name
                     || ' disable constraint '
                     || c_obj.constraint_name);
      END LOOP;
   END;
   /******************************************************************************
    Abilitazione di tutti i Trigger e i Constraint di FK e Check.
    REVISIONI.
    Rev. Data        Autore  Descrizione
    ---- ----------  ------  ----------------------------------------------------
    1    19/10/2006  VA      Creazione
   ******************************************************************************/
   PROCEDURE Enable_All (p_validate NUMBER DEFAULT 1 )
   IS
      d_option   VARCHAR2 (20) := 'validate';
   BEGIN
      IF p_validate = 0
      THEN
         d_option := 'novalidate';
      END IF;
      /* Abilito tutti i trigger dello user*/
      FOR c_table IN (SELECT   DISTINCT table_name
                        FROM   USER_TRIGGERS
                       WHERE   base_object_type = 'TABLE')
      LOOP
         sql_execute (
            'alter table ' || c_table.table_name || ' enable all triggers'
         );
      END LOOP;
      /* Abilito i constraint di FK e Check*/
      FOR c_obj IN (SELECT   table_name, constraint_name
                      FROM   USER_CONSTRAINTS
                     WHERE   constraint_type IN ('R', 'C'))
      LOOP
         sql_execute(   'alter table '
                     || c_obj.table_name
                     || ' enable '
                     || d_option
                     || ' constraint '
                     || c_obj.constraint_name);
      END LOOP;
   END;
   /******************************************************************************
    Disabilitazione di tutti i Trigger e i Constraint di FK e Check per la tabella indicata.
    REVISIONI.
    Rev. Data        Autore  Descrizione
    ---- ----------  ------  ----------------------------------------------------
    8    22/06/2010  SNeg      Creazione
   ******************************************************************************/
   PROCEDURE Tab_Disable_All (p_table VARCHAR2)
   IS
   BEGIN
      /* Disabilito tutti i trigger dello user*/
      FOR c_table
      IN (SELECT   DISTINCT table_name
            FROM   USER_TRIGGERS
           WHERE   base_object_type = 'TABLE'
                   AND table_name LIKE UPPER (p_table))
      LOOP
         sql_execute (
            'alter table ' || c_table.table_name || ' disable all triggers'
         );
      END LOOP;
      /* Disabilito i constraint di FK e Check*/
      FOR c_obj
      IN (SELECT   table_name, constraint_name
            FROM   USER_CONSTRAINTS
           WHERE   constraint_type IN ('R', 'C')
                   AND table_name LIKE UPPER (p_table))
      LOOP
         sql_execute(   'alter table '
                     || c_obj.table_name
                     || ' disable constraint '
                     || c_obj.constraint_name);
      END LOOP;
   END;
   /******************************************************************************
    Abilitazione di tutti i Trigger e i Constraint di FK e Check per la tabella indicata.
    REVISIONI.
    Rev. Data        Autore  Descrizione
    ---- ----------  ------  ----------------------------------------------------
    8    22/06/2010  SNeg      Creazione
   ******************************************************************************/
   PROCEDURE Tab_Enable_All (p_table VARCHAR2, p_validate NUMBER DEFAULT 1 )
   IS
      d_option   VARCHAR2 (20) := 'validate';
   BEGIN
      IF p_validate = 0
      THEN
         d_option := 'novalidate';
      END IF;
      /* Abilito tutti i trigger dello user*/
      FOR c_table
      IN (SELECT   DISTINCT table_name
            FROM   USER_TRIGGERS
           WHERE   base_object_type = 'TABLE'
                   AND table_name LIKE UPPER (p_table))
      LOOP
         sql_execute (
            'alter table ' || c_table.table_name || ' enable all triggers'
         );
      END LOOP;
      /* Abilito i constraint di FK e Check*/
      FOR c_obj
      IN (SELECT   table_name, constraint_name
            FROM   USER_CONSTRAINTS
           WHERE   constraint_type IN ('R', 'C')
                   AND table_name LIKE UPPER (p_table))
      LOOP
         sql_execute(   'alter table '
                     || c_obj.table_name
                     || ' enable '
                     || d_option
                     || ' constraint '
                     || c_obj.constraint_name);
      END LOOP;
   END;
   /******************************************************************************
    Creazione Grant.
    REVISIONI.
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    0    10/10/03   VA    Prima emissione.
    1    06/11/03   VA    Corretto errore nella nvl.
   ******************************************************************************/
   PROCEDURE CREATE_GRANT (p_grantee   IN VARCHAR2,
                           p_object    IN VARCHAR2:= '%',
                           p_type      IN VARCHAR2:= '',
                           p_grant     IN VARCHAR2:= '',
                           p_option    IN VARCHAR2:= '',
                           p_grantor   IN VARCHAR2:= USER)
   IS
      d_grantee   VARCHAR2 (20) := UPPER (p_grantee);
      d_object    VARCHAR2 (100) := UPPER (p_object);
      d_type      VARCHAR2 (100) := UPPER (p_type);
      d_grant     VARCHAR2 (20) := UPPER (p_grant);
      d_option    VARCHAR2 (20) := UPPER (p_option);
      d_grantor   VARCHAR2 (20) := UPPER (p_grantor);
      CURSOR c_obj
      IS
         SELECT   object_name, object_type
           FROM   ALL_OBJECTS
          WHERE       object_name LIKE d_object
                  AND (object_type IN (d_type) OR NVL (d_type, '1') = '1')
                  AND owner = d_grantor
                  AND object_name NOT IN ('SI4', 'SIAREF');
   BEGIN
      IF d_grant IS NULL
      THEN
         d_grant := 'select';
      END IF;
      IF d_option = 'YES'
      THEN
         d_option := ' with grant option';
      ELSIF d_option = 'NO'
      THEN
         d_option := '';
      ELSE
         d_option := ' ' || d_option;
      END IF;
      FOR v_obj IN c_obj
      LOOP
         BEGIN
            IF v_obj.object_type IN ('FUNCTION', 'PACKAGE', 'PROCEDURE')
            THEN
               sql_execute(   'grant execute on '
                           || v_obj.object_name
                           || ' to '
                           || d_grantee
                           || ' '
                           || d_option);
            ELSE
               sql_execute(   'grant '
                           || d_grant
                           || ' on '
                           || v_obj.object_name
                           || ' to '
                           || d_grantee
                           || ' '
                           || d_option);
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END LOOP;
   END CREATE_GRANT;
   /******************************************************************************
    Assegna ad un dato oggetto le stesse grant di un'altro esistente.
    REVISIONI.
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    0    10/10/03   VA    Prima emissione.
    1    06/11/03   VA    Aggiunta possibilita di specificare il Grantor.
   ******************************************************************************/
   PROCEDURE GRANT_LIKE (p_object       IN VARCHAR2,
                         p_likeobject   IN VARCHAR2,
                         p_grantor      IN VARCHAR2:= USER)
   IS
      d_object       VARCHAR2 (20) := UPPER (p_object);
      d_likeobject   VARCHAR2 (20) := UPPER (p_likeobject);
      d_grantor      VARCHAR2 (20) := UPPER (p_grantor);
      d_option       VARCHAR2 (20) := '';
      CURSOR c_tab_privs
      IS
         SELECT   *
           FROM   ALL_TAB_PRIVS
          WHERE   grantor = d_grantor AND table_name = d_likeobject;
   BEGIN
      FOR v_tab_privs IN c_tab_privs
      LOOP
         BEGIN
            IF v_tab_privs.grantable = 'YES'
            THEN
               d_option := ' with grant option';
            ELSE
               d_option := '';
            END IF;
            sql_execute(   'grant '
                        || v_tab_privs.PRIVILEGE
                        || ' on '
                        || d_object
                        || ' to '
                        || v_tab_privs.grantee
                        || ' '
                        || d_option);
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END LOOP;
   END GRANT_LIKE;
   /******************************************************************************
    Crea i sinonimi per gli oggetti a cui si ha accesso.
    REVISIONI.
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    0    10/10/03   VA     Prima emissione.
    2    29/03/05   SN     nome del sinonimo come quello nello user che da grant
   ******************************************************************************/
   PROCEDURE CREATE_SYNONYM (p_object    IN VARCHAR2:= '%',
                             p_prefix    IN VARCHAR2:= '',
                             p_grantor   IN VARCHAR2:= '%',
                             p_grantee   IN VARCHAR2:= USER)
   IS
      d_grantee      VARCHAR2 (30) := UPPER (p_grantee);
      d_prefix       VARCHAR2 (20) := UPPER (p_prefix);
      d_grantor      VARCHAR2 (30) := UPPER (p_grantor);
      d_object       VARCHAR2 (30) := UPPER (p_object);
      CURSOR c_obj
      IS
         SELECT   DISTINCT table_name object_name, table_schema
           FROM   ALL_TAB_PRIVS
          WHERE       grantee = d_grantee
                  AND table_name LIKE d_object
                  AND grantor LIKE d_grantor;
      d_esiste       VARCHAR2 (1);
      privilegi_insufficienti EXCEPTION;
      PRAGMA EXCEPTION_INIT (privilegi_insufficienti, -1031);
      d_sinonimo     ALL_SYNONYMS.synonym_name%TYPE;
      d_msg_errore   VARCHAR2 (32767);
      d_errore       BOOLEAN := FALSE;
   BEGIN
      FOR d_obj IN c_obj
      LOOP
         d_errore := FALSE;
         BEGIN
            SELECT   '1'
              INTO   d_esiste
              FROM   ALL_SYNONYMS
             WHERE       OWNER = 'PUBLIC'
                     AND SYNONYM_NAME = d_obj.object_name
                     AND TABLE_OWNER = d_obj.table_schema
                     AND TABLE_NAME = d_obj.object_name;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN                     -- non esiste il sinonimo pubblico uguale
               BEGIN
                  SELECT   synonym_name
                    INTO   d_sinonimo
                    FROM   ALL_SYNONYMS
                   WHERE       owner = d_grantee
                           AND table_name = d_obj.object_name
                           AND table_owner = d_obj.table_schema;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     d_sinonimo := d_obj.object_name;
                  WHEN TOO_MANY_ROWS
                  THEN
                     d_msg_errore :=
                           d_msg_errore
                        || CHR (10)
                        || d_obj.table_schema
                        || '.'
                        || d_obj.object_name;
                     d_errore := TRUE;
               END;
               IF NOT d_errore
               THEN
                  BEGIN
                     sql_execute ('drop synonym ' || d_sinonimo);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        NULL;
                  END;
                  BEGIN
                     sql_execute(   'create synonym '
                                 || d_grantee
                                 || '.'
                                 || d_prefix
                                 || d_sinonimo
                                 || ' for '
                                 || d_obj.table_schema
                                 || '.'
                                 || d_obj.object_name);
                  EXCEPTION
                     WHEN privilegi_insufficienti
                     THEN
                        RAISE_APPLICATION_ERROR (
                           -20999,
                           'ERRORE dare le grant di sistema dirette',
                           TRUE
                        );
                     WHEN OTHERS
                     THEN
                        DBMS_OUTPUT.PUT_LINE ('errore ' || SQLERRM);
                        NULL;
                  END;
               END IF;
            WHEN TOO_MANY_ROWS
            THEN
               NULL;
         END;
      END LOOP;
      IF d_msg_errore IS NOT NULL
      THEN
         RAISE_APPLICATION_ERROR (
            -20999,
               'NON tutti i sinonimi sono stati creati.'
            || CHR (10)
            || ' Esistono troppi sinonimi per gli oggetti:'
            || d_msg_errore
         );
      END IF;
   END CREATE_SYNONYM;
   /******************************************************************************
    Crea le viste per gli oggetti di un dato utente accessibili
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    0    10/10/03   VA    Prima emissione.
    1    24/10/03   VA    Aggiunta possibilita di un prefisso nella creazione delle viste.
   11   29/12/2020  SN     Chiusura cursore aperto Bug #47059
   ******************************************************************************/
   PROCEDURE CREATE_VIEW (p_owner     IN VARCHAR2,
                          p_object    IN VARCHAR2:= '%',
                          p_prefix    IN VARCHAR2:= '',
                          p_db_link   IN VARCHAR2:= '')
   IS
      d_owner     VARCHAR2 (20) := UPPER (p_owner);
      d_object    VARCHAR2 (30) := UPPER (p_object);
      d_prefix    VARCHAR2 (20) := UPPER (p_prefix);
      d_db_link   VARCHAR2 (30) := '@' || p_db_link;
      d_name      VARCHAR2 (30);
      TYPE cv_type IS REF CURSOR;
      CV          cv_type;
      CURSOR c_obj
      IS
         SELECT   object_name, owner
           FROM   ALL_OBJECTS
          WHERE       owner = d_owner
                  AND object_name LIKE d_object
                  AND object_type IN ('TABLE', 'VIEW');
      d_select VARCHAR2 (200)
            :=    'SELECT tname FROM tab'
               || d_db_link
               || ' where tname like '''
               || d_object
               || ''' and tabtype in (''TABLE'',''VIEW'')' ;
      privilegi_insufficienti EXCEPTION;
      PRAGMA EXCEPTION_INIT (privilegi_insufficienti, -1031);
   BEGIN
      IF d_db_link = '@'
      THEN
         FOR v_obj IN c_obj
         LOOP
            BEGIN
               sql_execute(   'create or replace view '
                           || d_prefix
                           || v_obj.object_name
                           || ' as select * from '
                           || v_obj.owner
                           || '.'
                           || v_obj.object_name);
            EXCEPTION
               WHEN privilegi_insufficienti
               THEN
                  RAISE_APPLICATION_ERROR (
                     -20999,
                     'ERRORE dare le grant di sistema dirette',
                     TRUE
                  );
               WHEN OTHERS
               THEN
                  NULL;
            END;
         END LOOP;
      ELSE
         OPEN CV FOR d_select;
         LOOP
            FETCH CV INTO   d_name;
            EXIT WHEN CV%NOTFOUND;
            BEGIN
               sql_execute(   'create or replace view '
                           || d_prefix
                           || d_name
                           || ' as select * from '
                           || d_name
                           || d_db_link);
            EXCEPTION
               WHEN privilegi_insufficienti
               THEN
                  RAISE_APPLICATION_ERROR (
                     -20999,
                     'ERRORE dare le grant di sistema dirette',
                     TRUE
                  );
               WHEN OTHERS
               THEN
                  NULL;
            END;
         END LOOP;
      END IF;

    -- rev. 11 inizio
    if CV%ISOPEN THEN
    close CV;
    end if;
exception
when others then
    if CV%ISOPEN THEN
    close CV;
    end if;
    raise;
    -- rev. 11 fine
   END CREATE_VIEW;
   /******************************************************************************
     Restituisce elenco delle colonne che costituiscono il constraint indicato.
     %return varchar2: contiene elenco colonne separate da virgola.
     %param p_owner IN VARCHAR2 Proprietario del constraint
     %param p_constraint_name IN VARCHAR2 Nome del constraint
   REVISIONI:
     Rev. Data       Autore Descrizione
     ---- ---------- ------ ------------------------------------------------------
     0    22/04/2016 SN   Prima emissione.
    ******************************************************************************/
   FUNCTION get_constraint_columns (p_owner             IN VARCHAR2,
                                    p_constraint_name   IN VARCHAR2)
      RETURN VARCHAR2
   IS
      v_column_string   VARCHAR2 (2000) := '';
   BEGIN
      FOR p_record
      IN (  SELECT   column_name
              FROM   all_cons_columns
             WHERE   constraint_name = p_constraint_name AND owner = p_owner
          ORDER BY   position)
      LOOP
         v_column_string := v_column_string || p_record.column_name || ', ';
      END LOOP;
      v_column_string :=
         SUBSTR (v_column_string, 1, LENGTH (v_column_string) - 2);
      RETURN v_column_string;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END;
   /******************************************************************************
    Restituisce elenco delle colonne che costituiscono l'indice indicato.
    %return varchar2: contiene elenco colonne separate da virgola.
    %param p_index_name IN VARCHAR2 Nome dell indice
    %param p_table_owner IN VARCHAR2 Proprietario della tabella
    %param p_table_name IN VARCHAR2 Nome della tabella
   REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    0    22/04/2016 SN   Prima emissione.
    ******************************************************************************/
   FUNCTION get_index_columns (p_table_owner      VARCHAR2,
                               p_table_name       VARCHAR2,
                               p_index_name    IN VARCHAR2)
      RETURN VARCHAR2
   IS
      v_column_string   VARCHAR2 (2000) := '';
   BEGIN
      FOR p_record
      IN (  SELECT   column_name
              FROM   all_ind_columns
             WHERE       index_name = p_index_name
                     AND table_name = p_table_name
                     AND table_owner = p_table_owner
          ORDER BY   column_position)
      LOOP
         v_column_string := v_column_string || p_record.column_name || ', ';
      END LOOP;
      v_column_string :=
         SUBSTR (v_column_string, 1, LENGTH (v_column_string) - 2);
      RETURN v_column_string;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END;
   /******************************************************************************
    Salva le info per ricostruire il constraint nella tabella UTILITYPACKAGE_SAVE_RESTORE.
    %param p_table IN VARCHAR2 Nome della tabella
    %param p_owner IN VARCHAR2 Nome del proprietario
    %param p_constraint_type IN VARCHAR2 Tipo del constraint
    %param p_statement IN VARCHAR2 Statement da memorizzare
   REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    0    22/04/2016 SN   Prima emissione.
   ******************************************************************************/
   PROCEDURE save_info (p_table              VARCHAR2,
                        p_owner              VARCHAR2,
                        p_constraint_type    VARCHAR2,
                        p_statement          VARCHAR2)
   IS
      v_statement   VARCHAR2 (32767);
   BEGIN
      v_progressivo := v_progressivo + 1;
      v_statement :=
         'INSERT INTO UTILITYPACKAGE_SAVE_RESTORE(session_id,
                                        progressivo,
                                        TABLE_OWNER,
                                        TABLE_NAME,
                                        CONSTRAINT_TYPE,
                                        CONS_STATEMENT,
                                        tipo_attivita,
                                        data)
        VALUES   (USERENV (''sessionid''),
                  :v_progressivo,
                  UPPER (:p_owner),
                  UPPER (:p_table),
                  UPPER (:p_constraint_type),
                  UPPER (:p_statement),
                  ''S'',
                  SYSDATE)';
      EXECUTE IMMEDIATE v_statement
         USING IN v_progressivo,
               p_owner,
               p_table,
               p_constraint_type,
               p_statement;
   END;
   PROCEDURE create_table
   IS
      v_trovato   NUMBER := 0;
   BEGIN
      SELECT   1
        INTO   v_trovato
        FROM   user_tables
       WHERE   table_name = 'UTILITYPACKAGE_SAVE_RESTORE';
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         EXECUTE IMMEDIATE ('CREATE TABLE UTILITYPACKAGE_SAVE_RESTORE
                       (
                      SESSION_ID             NUMBER                 NOT NULL,
                      PROGRESSIVO            NUMBER,
                      TABLE_OWNER            VARCHAR2(30 )      NOT NULL,
                      TABLE_NAME             VARCHAR2(30 )      NOT NULL,
                      CONSTRAINT_TYPE        VARCHAR2(6 )       NOT NULL,
                      CONS_STATEMENT         VARCHAR2(4000 ),
                      TIPO_ATTIVITA          VARCHAR2(1 )       NOT NULL,
                      TABLE_OWNER_ORIGINALE  VARCHAR2(30 ),
                      TABLE_NAME_ORIGINALE   VARCHAR2(30 ),
                      STATEMENT_ORIGINALE    VARCHAR2(4000 ),
                      MESSAGGIO_ERRORE       VARCHAR2(4000 ),
                      DATA                   DATE
                       )');
         EXECUTE IMMEDIATE ('ALTER TABLE UTILITYPACKAGE_SAVE_RESTORE ADD (
  CONSTRAINT UTPA_CONSTRAINT_TYPE
 CHECK (constraint_type IN (''FK'',''PK'',''UK'',''IK'',''REF_PK'' )),
  CONSTRAINT UTPA_TIPO_ATTIVITA
 CHECK (tipo_attivita IN (''S'',''R'')))');
         EXECUTE IMMEDIATE ('CREATE INDEX UTPA_IK on UTILITYPACKAGE_SAVE_RESTORE(TABLE_OWNER, TABLE_NAME,
 TIPO_ATTIVITA)');
   END;
   /******************************************************************************
    Salva lo statement per ricostruire il constraint nella tabella UTILITYPACKAGE_SAVE_RESTORE.
    Se la tabella si autoreferenzia la estraggo  SOLO come REF_PK altrimenti dà errore
    in quanto tenta di fare l'attività più volte.
    %param p_table IN VARCHAR2 Nome della tabella
    %param p_owner IN VARCHAR2 Nome del proprietario, default USER
   REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    0    22/04/2016 SN   Prima emissione.
   ******************************************************************************/
   PROCEDURE save_constraints (p_table    VARCHAR2,
                               p_owner    VARCHAR2 DEFAULT USER )
   IS
      v_statement   VARCHAR2 (32767);
   BEGIN
      create_table;
      v_statement :=
         'DELETE   UTILITYPACKAGE_SAVE_RESTORE
       WHERE       table_owner = UPPER (:p_owner)
               AND table_name = UPPER (:p_table)
               AND tipo_attivita = ''S''';
      --      dbms_output.put_line('PRIMA cancello ' || v_statement);
      EXECUTE IMMEDIATE v_statement USING IN p_owner, p_table;
      --            dbms_output.put_line('cancello ' || v_statement);
      FOR pk
      IN (SELECT                                                  -- genera PK
                'alter table '
                   || owner
                   || '.'
                   || table_name
                   || ' add constraint '
                   || constraint_name
                   || ' primary key ('
                   || get_constraint_columns (b.owner, b.constraint_name)
                   || ');'
                      PK_script
            FROM   all_constraints b
           WHERE       b.constraint_type = 'P'
                   AND table_name = UPPER (p_table)
                   AND owner = UPPER (p_owner))
      LOOP
         save_info (p_table,
                    p_owner,
                    'PK',
                    pk.pk_script);
      END LOOP;
      FOR uk
      IN (SELECT                                                  -- genera UK
                'alter table '
                   || owner
                   || '.'
                   || table_name
                   || ' add constraint '
                   || constraint_name
                   || ' unique ('
                   || get_constraint_columns (b.owner, b.constraint_name)
                   || ');'
                      UK_script
            FROM   all_constraints b
           WHERE       b.constraint_type = 'U'
                   AND table_name = UPPER (p_table)
                   AND owner = UPPER (p_owner))
      LOOP
         save_info (p_table,
                    p_owner,
                    'UK',
                    uk.uk_script);
      END LOOP;
      FOR fk
      IN (SELECT                              -- foreign key da questa tabella
                'alter table '
                   || t1_table_owner
                   || '.'
                   || t1_table_name
                   || ' add constraint '
                   || t1_constraint_name
                   || ' foreign key ('
                   || t1_column_names
                   || ')'
                   || ' references '
                   || t2_table_owner
                   || '.'
                   || t2_table_name
                   || '('
                   || t2_column_names
                   || ') '
                   || DECODE (t1.delete_rule,
                              'CASCADE', 'ON DELETE CASCADE;',
                              ';')
                      FK_script
            FROM   (SELECT   b.table_name t1_table_name,
                             b.owner t1_table_owner,
                             b.constraint_name t1_constraint_name,
                             b.r_constraint_name t2_constraint_name,
                             b.r_owner t1_r_owner,
                             delete_rule -- Concatenate columns to handle composite
                                        -- foreign keys [handles up to 5 columns]
                             ,
                             get_constraint_columns (b.owner,
                                                     b.constraint_name)
                                t1_column_names
                      FROM   all_constraints b
                     WHERE   b.constraint_type = 'R') t1,
                   (SELECT   b.owner t2_table_owner,
                             b.constraint_name t2_constraint_name,
                             b.table_name t2_table_name,
                             b.r_owner t2_r_owner -- Concatenate columns for PK/UK referenced
                                                 -- from a composite foreign key
                             ,
                             get_constraint_columns (b.owner,
                                                     b.constraint_name)
                                t2_column_names
                      FROM   all_constraints b
                     WHERE   b.constraint_type IN ('P', 'U')) t2
           WHERE   t1.t2_constraint_name = t2.t2_constraint_name
                   AND t1.t1_r_owner = t2.t2_table_owner
                   -- ATTENZIONE se si autoreferenzia la estraggo come REF_PK
                   AND NOT (t1.t1_table_owner = t2.t2_table_owner
                            AND t1.t1_table_name = t2.t2_table_name)
                   AND t1.t1_table_name = UPPER (p_table)
                   AND t1.t1_table_owner = UPPER (p_owner))
      LOOP
         save_info (p_table,
                    p_owner,
                    'FK',
                    fk.fk_script);
      END LOOP;
      FOR IDX
      IN (SELECT      'CREATE '
                   || DECODE (i.uniqueness, 'UNIQUE', 'UNIQUE', '')
                   || ' INDEX '
                   || i.index_name
                   || ' ON '
                   || i.table_owner
                   || '.'
                   || i.table_name
                   || ' ('
                   || get_index_columns (i.table_owner,
                                         i.table_name,
                                         i.index_name)
                   || ');'
                      IDX_script
            FROM   all_indexes i
           WHERE   table_name = UPPER (p_table) AND owner = UPPER (p_owner))
      LOOP
         save_info (p_table,
                    p_owner,
                    'IK',
                    IDX.IDX_script);
      END LOOP;
      FOR REF_PK
      IN (SELECT      'alter table '
                   || t1_table_owner
                   || '.'
                   || t1_table_name
                   || ' add constraint '
                   || t1_constraint_name
                   || ' foreign key ('
                   || t1_column_names
                   || ')'
                   || ' references '
                   || t2_table_owner
                   || '.'
                   || t2_table_name
                   || ' ('
                   || t2_column_names
                   || ') '
                   || DECODE (t1.delete_rule,
                              'CASCADE', 'ON DELETE CASCADE;',
                              ';')
                      REF_PK_script
            FROM   (SELECT   b.table_name t1_table_name,
                             b.owner t1_table_owner,
                             b.constraint_name t1_constraint_name,
                             b.r_constraint_name t2_constraint_name,
                             b.r_owner t1_r_owner,
                             delete_rule -- Concatenate columns to handle composite
                                        -- foreign keys [handles up to 5 columns]
                             ,
                             get_constraint_columns (b.owner,
                                                     b.constraint_name)
                                t1_column_names
                      FROM   all_constraints b
                     WHERE   b.constraint_type = 'R') t1,
                   (SELECT   b.owner t2_table_owner,
                             b.constraint_name t2_constraint_name,
                             b.table_name t2_table_name,
                             b.r_owner t2_r_owner -- Concatenate columns for PK/UK referenced
                                                 -- from a composite foreign key
                             ,
                             get_constraint_columns (b.owner,
                                                     b.constraint_name)
                                t2_column_names
                      FROM   all_constraints b
                     WHERE       b.constraint_type IN ('P', 'U')
                             AND b.table_name = UPPER (p_table)
                             AND b.owner = UPPER (p_owner)) t2
           WHERE   t1.t2_constraint_name = t2.t2_constraint_name
                   AND t1.t1_r_owner = t2.t2_table_owner)
      LOOP
         save_info (p_table,
                    p_owner,
                    'REF_PK',
                    REF_PK.REF_PK_script);
      END LOOP;
   END;
   /******************************************************************************
   Legge le informazioni memorizzate nella UTILITYPACKAGE_SAVE_RESTORE per tabella
e user indicati e crea gli oggetti indicati sulla nuova tabella (o materialized
view) e sul nuovo user.
   %param p_from_table IN VARCHAR2 Nome della tabella da cui copiare i constraint
                                precedentemente salvati sulla UTILITYPACKAGE_SAVE_RESTORE
%param p_to_table IN VARCHAR2 Nome della tabella su cui creare i constraint
   %param p_from_user IN VARCHAR2 Nome del proprietario dell oggetto da cui copiare, default USER
%param p_to_user IN VARCHAR2 Nome del proprietario dell oggetto nel quale creare i constraint
%param p_PK indica se creare le primary key, default = SI%
%param p_UK indica se creare le unique key, default = SI%
%param p_FK indica se creare le foreign key, default = SI%
%param p_IK indica se creare gli indici, default = SI%
%param p_REF_PK indica se creare le reference key, default = SI%
REVISIONI:
   Rev. Data       Autore Descrizione
   ---- ---------- ------ ------------------------------------------------------
   0    22/04/2016 SN   Prima emissione.
  ******************************************************************************/
   PROCEDURE restore_constraints (p_from_table    VARCHAR2,
                                  p_to_table      VARCHAR2 DEFAULT NULL ,
                                  p_from_user     VARCHAR2 DEFAULT USER ,
                                  p_to_user       VARCHAR2 DEFAULT USER ,
                                  p_PK            VARCHAR2 DEFAULT 'SI' ,
                                  p_UK            VARCHAR2 DEFAULT 'SI' ,
                                  p_FK            VARCHAR2 DEFAULT 'SI' ,
                                  p_IK            VARCHAR2 DEFAULT 'SI' ,
                                  p_REF_PK        VARCHAR2 DEFAULT 'SI' )
   IS
      v_statement              VARCHAR2 (32767);
      v_statement_dinamico     VARCHAR2 (32767);
      v_to_object_type         VARCHAR2 (20);
      v_from_object_type       VARCHAR2 (20);
      v_from_table_alias       VARCHAR2 (20);
      v_to_table_alias         VARCHAR2 (20);
      v_esiste                 NUMBER := 0;
      v_esiste_gia_oggetto     NUMBER := 0;
      v_constraint_name        VARCHAR2 (30);
      v_constraint_name_new    VARCHAR2 (30);
      v_constraint_name_prop   VARCHAR2 (30);
      v_progressivo            NUMBER := 0;
      v_elenco_colonne         VARCHAR2 (2000);
      v_index_name             VARCHAR2 (30);
      v_object_name            VARCHAR2 (30);
      TYPE utpa_save_restore_type
      IS
         RECORD (
            SESSION_ID              NUMBER,
            PROGRESSIVO             NUMBER,
            TABLE_OWNER             VARCHAR2 (30),
            TABLE_NAME              VARCHAR2 (30),
            CONSTRAINT_TYPE         VARCHAR2 (6),
            CONS_STATEMENT          VARCHAR2 (4000),
            TIPO_ATTIVITA           VARCHAR2 (1),
            TABLE_OWNER_ORIGINALE   VARCHAR2 (30),
            TABLE_NAME_ORIGINALE    VARCHAR2 (30),
            STATEMENT_ORIGINALE     VARCHAR2 (4000),
            MESSAGGIO_ERRORE        VARCHAR2 (4000),
            DATA                    DATE
         );
      --   TYPE utpa_save_restore_rec IS TABLE OF utpa_save_restore_type INDEX BY BINARY_INTEGER;
      v_constraint             utpa_save_restore_type;
      TYPE restoretyp IS REF CURSOR;         -- RETURN utpa_save_restore_type;
      c_restore                restoretyp;
   BEGIN
      v_avvenuto_errore := FALSE;
      -- ORDINAMENTO in modo che prima crei i constraint e poi l'indice relativo
      v_statement_dinamico :=
         'SELECT  temp_saco.*
              FROM   UTILITYPACKAGE_SAVE_RESTORE temp_saco
             WHERE   table_owner = '''
         || UPPER (p_from_user)
         || ''' AND table_name = '''
         || UPPER (p_from_table)
         || '''
                     AND (   (constraint_type = ''PK'' AND '''
         || p_pk
         || ''' = ''SI'')
                          OR (constraint_type = ''UK'' AND '''
         || p_uk
         || ''' = ''SI'')
                          OR (constraint_type = ''IK'' AND '''
         || p_IK
         || ''' = ''SI'')
                          OR (constraint_type = ''FK'' AND '''
         || p_FK
         || ''' = ''SI'')
                          OR (constraint_type = ''REF_PK'' AND '''
         || p_REF_PK
         || ''' = ''SI''))
                     AND tipo_attivita = ''S''
          ORDER BY  DECODE (constraint_type,
                             ''IK'',
                             1,
                             ''UK'',
                             2,
                             ''PK'',
                             3,
                             ''FK'',
                             4,
                             ''REF_PK'',
                             5), substr(temp_saco.cons_statement,1,1)';
      OPEN c_restore FOR v_statement_dinamico;
      LOOP
         FETCH c_restore INTO   v_constraint;
         EXIT WHEN c_restore%NOTFOUND;
         v_statement := v_constraint.cons_statement;
         --         DBMS_OUTPUT.put_line ('originale:' || v_statement);
         SELECT   MIN (object_type)
           -- potrebbe essere table o materialized view
           INTO   v_to_object_type
           FROM   all_objects
          WHERE   object_name = NVL (p_to_table, p_from_table)
                  AND owner = NVL (p_to_user, p_from_user);
         SELECT   MIN (object_type)
           -- potrebbe essere table o materialized view
           INTO   v_from_object_type
           FROM   all_objects
          WHERE   object_name = NVL (p_from_table, p_to_table)
                  AND owner = NVL (p_from_user, p_to_user);
         IF p_to_table IS NOT NULL AND p_to_table != p_from_table
         THEN
            v_statement :=
               REPLACE (v_statement,
                        p_from_user || '.' || p_from_table,
                        p_from_user || '.' || p_to_table);
            IF p_to_user IS NOT NULL AND p_to_user != p_from_user
            THEN
               v_statement :=
                  REPLACE (v_statement,
                           p_from_user || '.' || p_to_table,
                           p_to_user || '.' || p_to_table);
            END IF;
            IF v_to_object_type = 'MATERIALIZED VIEW'
            THEN
               IF v_constraint.constraint_type != 'REF_PK'
               THEN
                  v_statement :=
                     REPLACE (v_statement,
                              'ALTER TABLE',
                              'ALTER MATERIALIZED VIEW');
               ELSE                                           -- tipo = REF_PK
                  -- devo controllare che non sia su se stessa
                  NULL;
               END IF;
            END IF;
         ELSIF p_to_user IS NOT NULL AND p_to_user != p_from_user
         THEN
            v_statement :=
               REPLACE (v_statement,
                        p_from_user || '.' || p_from_table,
                        p_to_user || '.' || p_from_table);
         END IF;
         v_esiste_gia_oggetto := 0;
         BEGIN
            -- se esiste già oggetto sulle stesse colonne NON lo devo ricreare
            v_elenco_colonne :=
               SUBSTR (
                  v_statement,
                  INSTR (v_statement, '(') + 1,
                  INSTR (v_statement, ')') - INSTR (v_statement, '(') - 1
               );
            IF v_constraint.constraint_type IN ('IK', 'UK')
            THEN
               --          DBMS_OUTPUT.put_line ('controllo se esiste indice' || v_elenco_colonne);
               SELECT   MAX (index_name)
                 INTO   v_object_name
                 FROM   all_indexes
                WHERE   table_name = NVL (p_to_table, p_from_table)
                        AND table_owner = NVL (p_to_user, p_from_user)
                        AND utilitypackage.get_index_columns (table_owner,
                                                               table_name,
                                                               index_name) =
                              v_elenco_colonne;
               IF v_object_name IS NOT NULL
               THEN
                  v_esiste_gia_oggetto := 1;
                  v_object_name := NULL;
               END IF;
            ELSE                                           -- per i constraint
               SELECT   MAX (constraint_name)
                 INTO   v_object_name
                 FROM   all_constraints
                WHERE   owner = NVL (p_to_user, p_from_user)
                  AND  table_name = NVL (p_to_table, p_from_table)
                  and constraint_type = decode(v_constraint.constraint_type, 'PK','P'
                                                                           , 'UK','U'
                                                                           , 'FK','R')
               -- le reference non le ocntrollo altrimenti dovrei verificare
               -- la tabella da cui partono
                        AND utilitypackage.get_constraint_columns (
                              owner,
                              constraint_name
                           ) = v_elenco_colonne;
               IF v_object_name IS NOT NULL
               THEN
                  v_esiste_gia_oggetto := 1;
                  v_object_name := NULL;
               END IF;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_object_name := NULL;
               v_esiste_gia_oggetto := 0;
         END;
         IF NVL (v_esiste_gia_oggetto, 0) = 0
         THEN
            --         -- controllo se esiste gia e nel caso rinomino
            v_constraint_name :=
               get_constraint_name (v_constraint.constraint_type,
                                    v_constraint.cons_statement);
            --         DBMS_OUTPUT.put_line ('constraint name :' || v_constraint_name);
            IF p_from_table != NVL (p_to_table, p_from_table)
            THEN
               -- nel constraint potrebbe esserci il nome della tabella
               v_constraint_name_new :=
                  REPLACE (v_constraint_name, p_from_table, p_to_table);
               -- nel constraint potrebbe esserci alias della tabella
               BEGIN
                  SELECT   SUBSTR (comments, 1, INSTR (comments, ' ') - 1)
                    INTO   v_from_table_alias
                    FROM   all_tab_comments
                   WHERE   table_name = p_from_table AND owner = p_from_user;
                  SELECT   SUBSTR (comments, 1, INSTR (comments, ' ') - 1)
                    INTO   v_to_table_alias
                    FROM   all_tab_comments
                   WHERE   table_name = p_to_table
                           AND owner = NVL (p_to_user, p_from_user);
                  v_constraint_name_new :=
                     REPLACE (v_constraint_name_new,
                              '_' || v_from_table_alias || '_',
                              '_' || v_to_table_alias || '_');
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     NULL;      -- se non ci sono commenti non devo fare nulla
               END;
            ELSE                               -- non cambio nome alla tabella
               v_constraint_name_new := v_constraint_name;
            END IF;                        -- non cambio il nome della tabella
            --         DBMS_OUTPUT.put_line ('constraint name NEW :' || v_constraint_name_new);
            -- verifico se oggetto non esista gia 
            IF v_constraint.constraint_type IN ('IK', 'UK')
            THEN
               SELECT   COUNT ( * )
                 INTO   v_esiste
                 FROM   all_indexes
                WHERE   index_name = v_constraint_name_new
                        AND owner = NVL (p_to_user, p_from_user);
            ELSE
               SELECT   COUNT ( * )
                 INTO   v_esiste
                 FROM   all_constraints
                WHERE   constraint_name = v_constraint_name_new
                        AND owner = NVL (p_to_user, p_from_user);
            END IF;
            v_constraint_name_prop := v_constraint_name_new;
            WHILE v_esiste > 0
            LOOP
               v_esiste := 0;                                        -- esiste
               v_progressivo := v_progressivo + 1;
               v_constraint_name_prop :=
                  SUBSTR (v_constraint_name_new,
                          1,
                          30 - LENGTH (v_progressivo))
                  || v_progressivo;
               --         DBMS_OUTPUT.put_line ('constraint name NEW proposta:' || v_constraint_name_new);
               IF v_constraint.constraint_type IN ('IK', 'UK')
               -- controllo se esiste
               THEN
                  SELECT   COUNT ( * )
                    INTO   v_esiste
                    FROM   all_indexes
                   WHERE   index_name = v_constraint_name_prop
                           AND owner = NVL (p_to_user, p_from_user);
               ELSE
                  SELECT   COUNT ( * )
                    INTO   v_esiste
                    FROM   all_constraints
                   WHERE   constraint_name = v_constraint_name_prop
                           AND owner = NVL (p_to_user, p_from_user);
               END IF;
            END LOOP;
            v_constraint_name_new := v_constraint_name_prop;
            IF v_constraint.constraint_type IN ('IK', 'UK')
            -- sostituzione
            THEN
               v_statement :=
                  REPLACE (v_statement,
                           ' INDEX ' || v_constraint_name || ' ',
                           ' INDEX ' || v_constraint_name_new || ' ');
            ELSIF v_constraint.constraint_type = 'PK'
            THEN
               -- cerco nome dell indice sulle stesse colonne
               v_elenco_colonne :=
                  SUBSTR (
                     v_statement,
                     INSTR (v_statement, '(') + 1,
                     INSTR (v_statement, ')') - INSTR (v_statement, '(') - 1
                  );
               --         DBMS_OUTPUT.put_line ('elenco colonne:' || v_elenco_colonne);
               SELECT   MAX (index_name)
                 INTO   v_index_name
                 FROM   all_indexes
                WHERE   table_name = NVL (p_to_table, p_from_table)
                        AND table_owner = NVL (p_to_user, p_from_user)
                        AND utilitypackage.get_index_columns (table_owner,
                                                               table_name,
                                                               index_name) =
                              v_elenco_colonne;
               --         DBMS_OUTPUT.put_line ('index name:' || v_index_name);
               v_constraint_name_new := NVL (v_index_name, v_constraint_name);
               --         DBMS_OUTPUT.put_line ('constraint name NEW:' || v_constraint_name_new);
               v_statement :=
                  REPLACE (v_statement,
                           ' CONSTRAINT ' || v_constraint_name || ' ',
                           ' CONSTRAINT ' || v_constraint_name_new || ' ');
            ELSE
               -- altri constraint
               v_statement :=
                  REPLACE (v_statement,
                           ' CONSTRAINT ' || v_constraint_name || ' ',
                           ' CONSTRAINT ' || v_constraint_name_new || ' ');
               IF v_constraint.constraint_type = 'REF_PK'
                  AND v_to_object_type = 'MATERIALIZED VIEW'
               THEN
                  v_statement :=
                     REPLACE (v_statement, ';', ' DEFERRABLE NOVALIDATE;');
               END IF;
            END IF;
            BEGIN
               v_errore := NULL;
               --            DBMS_OUTPUT.put_line ('modificato: ' || v_statement);
               EXECUTE IMMEDIATE (RTRIM (v_statement, ';'));
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_errore := SQLERRM;            -- MEMORIZZO errore rilevato
                  v_avvenuto_errore := TRUE;
            END;
         ELSE                                             -- indice esiste già
            v_errore := 'ATTENZIONE: NON creato in quanto GIA'' esistente';
         --           DBMS_OUTPUT.put_line ('esiste SIIIIIIIIII ' || v_esiste_gia_indice);
         END IF;                              -- verifica se esiste già indice
         v_progressivo := v_progressivo + 1;
         v_statement_dinamico :=
            'INSERT INTO UTILITYPACKAGE_SAVE_RESTORE (SESSION_ID,
                                               PROGRESSIVO,
                                               TABLE_OWNER,
                                               TABLE_NAME,
                                               CONSTRAINT_TYPE,
                                               CONS_STATEMENT,
                                               TIPO_ATTIVITA,
                                               TABLE_OWNER_ORIGINALE,
                                               TABLE_NAME_ORIGINALE,
                                               STATEMENT_ORIGINALE,
                                               MESSAGGIO_ERRORE,
                                               DATA)
           VALUES   (USERENV (''sessionid''),
                     :v_progressivo,
                     :p_to_user,
                     :p_to_table,
                     :constraint_type,
                     :v_statement,
                     ''R'',
                     :p_from_user,
                     :p_from_table,
                     :cons_statement,
                     :v_errore,
                     SYSDATE)';
         EXECUTE IMMEDIATE v_statement_dinamico
            USING v_progressivo,
                  NVL (p_to_user, p_from_user),
                  NVL (p_to_table, p_from_table),
                  v_constraint.constraint_type,
                  v_statement,
                  p_from_user,
                  p_from_table,
                  v_constraint.cons_statement,
                  v_errore;
         COMMIT;
      END LOOP;
      CLOSE c_restore;
      IF v_progressivo = 0
      THEN                                    -- NON ho trattato nessun record
         raise_application_error (
            -20999,
               'ATTENZIONE: NON ci sono constraint memorizzati per  '
            || p_from_user
            || '.'
            || p_from_table
         );
      END IF;
      COMMIT;                  -- x salvare nella tabella le attivita eseguite
      IF v_avvenuto_errore
      THEN
         raise_application_error (
            -20999,
            'ATTENZIONE: si sono verificati errori nelle attivita  per la sessione '
            || USERENV ('sessionid')
         );
      END IF;
   END;
   /******************************************************************************
    Restituisce il nome del constraint in base allo statement per la creazione
    %return varchar2: nome del constraint.
    %param p_constraint_type IN VARCHAR2 tipo del constraint
    %param p_constraint_statement IN VARCHAR2 Statement memorizzato nella UTILITYPACKAGE_SAVE_RESTORE
   REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    0    22/04/2016 SN   Prima emissione.
   ******************************************************************************/
   FUNCTION get_constraint_name (p_constraint_type         VARCHAR2,
                                 p_constraint_statement    VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      IF p_constraint_type IN ('IK', 'UK')
      THEN
         RETURN afc.get_substr (
                   SUBSTR (p_constraint_statement,
                           INSTR (p_constraint_statement, ' INDEX ') + 7),
                   ' ',
                   'P'
                );
      ELSE
         RETURN afc.get_substr (
                   SUBSTR (
                      p_constraint_statement,
                      INSTR (p_constraint_statement, ' CONSTRAINT ') + 12
                   ),
                   ' ',
                   'P'
                );
      END IF;
   END;
BEGIN
   SELECT   TO_NUMBER(SUBSTR (
                         SUBSTR (banner,
                                 INSTR (UPPER (banner), 'RELEASE') + 8),
                         1,
                         INSTR (
                            SUBSTR (banner,
                                    INSTR (UPPER (banner), 'RELEASE') + 8),
                            '.'
                         )
                         - 1
                      ))
     INTO   s_oracle_ver
     FROM   v$version
    WHERE   UPPER (banner) LIKE '%ORACLE%';
END;
/

