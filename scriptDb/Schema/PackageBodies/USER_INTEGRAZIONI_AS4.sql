CREATE OR REPLACE PACKAGE BODY USER_INTEGRAZIONI_AS4
IS
/******************************************************************************
 NOME:        USER_INTEGRAZIONI_AS4
 DESCRIZIONE: Funzioni di integrazione.
 ANNOTAZIONI: Richiamata da utente che deve fare i sinonimi con:
 <user oracle ad4>.user_integrazioni_ad4.CREATE_PRIVATE_SYNONYMS('ALL',user);
 Refernzia il package ADMIN_AS4
REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 000  04/06/2019 SNeg   Introdotta per gestione sinonimi
 001  24/09/2019 SNeg   Utilizzo execute immediate e non afc
 002  02/03/2020 SNeg   Correzione errori
******************************************************************************/
   s_revisione_body   constant AFC.t_revision := '002';
   function versione
      return varchar2
   is
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
******************************************************************************/
   begin
      return AFC.version (s_revisione, s_revisione_body);
   end versione;
   procedure gestione_sinonimo_grant
/******************************************************************************
 NOME:        GESTIONE_SINONIMO_GRANT
 DESCRIZIONE: Droppa, crea il sinonimo all'oggetto, assegna, revoca le
              grant ad esso.
 ARGOMENTI:   p_drop_create:  C: Create
                              D: Drop
                              DC / CD: Droppa e crea
                              G: Grant
                              R: Revoke
                              GR / RG: Revoca e Assegna
              p_user:         utente a cui applicare l'operazione
              p_what:         DB:  oggetti di base
                              CM:  gestione Comuni
                              BS:  gestione Banche e Sportelli
                              ASL: gestione ASL
                              ALL: tutti gli oggetti
              p_synonym_name: nome del sinonimo
 NOTE:        --
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
******************************************************************************/
   (
      p_drop_create   IN       VARCHAR2
    , p_user          in       varchar2
    , p_object        IN       VARCHAR2
    , p_synonym_name  IN       VARCHAR2
    , p_privilege     IN       VARCHAR2 DEFAULT 'ALL'
    , p_error         IN OUT   varchar2
    , p_owner                  VARCHAR2 default v_user_proprietario
   )
   IS
      d_privilege   VARCHAR2 (30)    := nvl (p_privilege, 'ALL');
      d_error       VARCHAR2 (32767);
   BEGIN

      if instr (p_drop_create, 'C') > 0
      then
         CREATE_SYNONYM (p_user => p_user, p_synonym_name => p_synonym_name, p_object => p_object, p_error => d_error, p_owner => p_owner);
      end if;
      p_error := p_error||d_error;
   end gestione_sinonimo_grant;
   PROCEDURE GESTIONE_SINONIMI_GRANT
/******************************************************************************
 NOME:        GESTIONE_SINONIMI_GRANT
 DESCRIZIONE: Droppa, crea tutti i sinonimi agli oggetti, assegna, revoca le
              grant ad essi.
 ARGOMENTI:   p_user:         utente a cui applicare l'operazione
              p_what:         DB:  oggetti di base
                              CM:  gestione Comuni
                              BS:  gestione Banche e Sportelli
                              ASL: gestione ASL
                              ALL: tutti gli oggetti
              p_drop_create:  C: Create
                              D: Drop
                              DC / CD: Droppa e crea
                              G: Grant
                              R: Revoke
                              GR / RG: Revoca e Assegna
 NOTE:        --
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
******************************************************************************/
   (
      p_drop_create   IN       VARCHAR2
    , p_user          in       varchar2
    , p_what          IN       VARCHAR2
    , p_privilege     IN       VARCHAR2 DEFAULT 'ALL'
    , p_error         IN OUT   varchar2
    , p_owner                  VARCHAR2 default v_user_proprietario
   )
   IS
      d_error       VARCHAR2 (32767);
   BEGIN

         IF p_what IN ('DB', 'ALL')
         THEN
-------------------------------------------------------------------
--         Droppa e/o crea sinonimi degli oggetti di base
-------------------------------------------------------------------
            -- TABLE - VIEW
            FOR j IN NVL (admin_as4.TabTVDB.FIRST, 1) .. NVL (admin_as4.TabTVDB.LAST, 0)
            LOOP
               gestione_sinonimo_grant(p_drop_create => p_drop_create, p_user => p_user, p_object => admin_as4.TabTVDB (j).object_name, p_synonym_name => '', p_privilege => p_privilege, p_error => d_error, p_owner => p_owner);
            END LOOP;
            -- FUNCTION / PACKAGE
            FOR j IN NVL (admin_as4.TabPDB.FIRST, 1) .. NVL (admin_as4.TabPDB.LAST, 0)
            LOOP
               gestione_sinonimo_grant(p_drop_create, p_user, admin_as4.TabPDB (j).object_name, '', 'execute', d_error, p_owner);
            END LOOP;
         END IF;

      declare
      num number := length(p_error);
      v_err varchar2(32767) := substr(d_error,1,2000);
      begin
      if length(p_error) + length( d_error) > 32767 then
      raise_application_error(-20999,'Errore:' || p_error||d_error);
      end if;
      null;
      end;
      p_error := p_error||d_error;
   END GESTIONE_SINONIMI_GRANT;

   PROCEDURE CREATE_SYNONYM
/******************************************************************************
 NOME:        CREATE_SYNONYM
 DESCRIZIONE: Crea il sinonimo per l'oggetto dato e ritorna eventuali
              errori in p_error.
              Se il sinonimo esiste gia'
                 se corrisponde (stesso oggetto e stesso proprietario),
                     non fa nulla,
                 altrimenti
                     droppa il sinonimo e lo ricrea.
 ARGOMENTI:   p_user:         utente in cui creare il sinonimo
              p_synonym_name: nome da assegnare al sinonimo
              p_object:       oggetto di cui fare il sinonimo
              p_error:        eventuale errore in creazione sinonimo.
 NOTE:        --
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
******************************************************************************/
   (
      p_user                    VARCHAR2
    , p_synonym_name            VARCHAR2
    , p_object                  VARCHAR2
    , p_error          IN OUT   VARCHAR2
    , p_owner                   VARCHAR2 default v_user_proprietario
   )
   IS
      d_esiste         INTEGER;
      d_statement      VARCHAR2 (4000);
      d_table_owner    ALL_SYNONYMS.table_owner%type;
      d_table_name     ALL_SYNONYMS.table_name%type;
      d_synonym_name   VARCHAR2(100);
      d_object         ALL_OBJECTS.object_name%type := upper(p_object);
   BEGIN
      if d_object is not null
      then
         d_synonym_name := p_synonym_name;
         if d_synonym_name is null
         then
            IF     SUBSTR (UPPER (p_object), 1, 4) NOT IN ('AS4_', 'DBMS')
               AND UPPER (p_object) NOT IN ('F_SCEGLI_FRA_ANAGRAFE_SOGGETTI')
            THEN
               d_synonym_name := 'AS4_';
            END IF;
            d_synonym_name := d_synonym_name || d_object;
         end if;
         DECLARE
            d_length integer;
            d_suffisso varchar2(4);
         BEGIN
            select data_length
              into d_length
              from all_tab_columns
             where table_name = 'ALL_SYNONYMS'
               and column_name = 'SYNONYM_NAME'
            ;
            IF length(d_synonym_name) > d_length THEN
               d_suffisso := substr(d_synonym_name, -4);
               d_length := LENGTH(d_synonym_name) - d_length;
               IF d_suffisso not in ('_TPK', '_PKG') THEN
                  d_synonym_name := substr(d_synonym_name, 1, length(d_synonym_name) - d_length);
               ELSE
                  d_synonym_name := substr(d_synonym_name, 1, length(d_synonym_name) - 4 - d_length)||d_suffisso;
               END IF;
            END IF;
         END;
         IF upper (p_user) || '.' || UPPER (d_synonym_name) <>
            UPPER (p_owner) || '.' || d_object
         THEN
            d_statement := 'create or replace ';
            if nvl (upper (p_user), 'PUBLIC') = 'PUBLIC'
            then
               d_statement := d_statement || ' synonym ';
            else
               d_statement := d_statement || 'synonym ' || upper (p_user) || '.';
            end if;
            d_statement :=
                  d_statement
               || UPPER (d_synonym_name)
               || ' for '
               || p_owner
               || '.'
               || d_object;
            select count(1)
              into d_esiste
              from all_objects
             where object_name = upper(d_object)
               and owner = p_owner;
            if d_esiste = 0
            then
               p_error :=
                     p_error
                  || CHR (10)
                  || '('
                  || p_user
                  || ') '
                  || ' '
                  || d_statement
                  || ': oggetto inesistente.';
            else
               BEGIN
   --DBMS_OUTPUT.PUT_LINE(d_statement);
                  execute immediate (d_statement); --rev. 1
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     p_error :=
                           p_error
                        || CHR (10)
                        || '('
                        || nvl (upper (p_user), 'PUBLIC')
                        || ') '
                        || ' '
                        || d_statement
                        || ': '
                        || SQLERRM;
               END;
            end if;
         end if;
      end if;
   END CREATE_SYNONYM;

   PROCEDURE CREATE_PRIVATE_SYNONYMS
/******************************************************************************
 NOME:        CREATE_PRIVATE_SYNONYMS
 DESCRIZIONE: Crea tutti i sinonimi  agli oggetti.
 ARGOMENTI:   p_what DB:  oggetti di base
                     CM:  gestione Comuni
                     BS:  gestione Banche e Sportelli
                     ASL: gestione ASL
                     ALL: tutti gli oggetti
 NOTE:        --
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
******************************************************************************/
   (p_what IN VARCHAR2 DEFAULT 'ALL'
   , p_user IN VARCHAR2 DEFAULT  null)
   IS
      d_error   varchar2 (32767);
   BEGIN
      GESTIONE_SINONIMI_GRANT ('C', p_user, p_what, '', d_error);
      if d_error is not null
      then
         raise_application_error (-20999, d_error);
      end if;
   END CREATE_PRIVATE_SYNONYMS;

BEGIN
  select owner
    into v_user_proprietario
    from all_objects
   where object_name = 'USER_INTEGRAZIONI_AS4'
     and object_type = 'PACKAGE';

END user_integrazioni_as4;
/

