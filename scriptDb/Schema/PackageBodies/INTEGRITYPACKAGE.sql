CREATE OR REPLACE PACKAGE BODY integritypackage
/******************************************************************************
 Oggetti per la gestione della Integrita Referenziale.
 Contiene le Procedure e function per la gestione del livello di annidamento dei trigger.
 Contiene le Procedure per il POSTING degli script alla fase di AFTER STATEMENT.
 REVISIONI.
 Rev. Data        Autore  Descrizione
 ---- ----------  ------  ----------------------------------------------------
 1    23/01/2001  MF      Inserimento commento.
 2    04/12/2002  SN      In caso di errore visualizza lo statement.
 3    22/12/2003  SN      Rilevamento errore in caso di select; sistemazione frase in base a default stabiliti.
 4    10/05/2004  SN      Se errore 20999 non si visualizza lo statement a meno che non sia stata settata la variabile debug a 1.
 5    20/12/2004  SN      Se errore non compreso fra 20000 e 20999 non visualizza lo statement a meno che debug sia = 1.
 6    04/08/2005  SN      Gestione di integrityerror.
 7    26/08/2005  SN      Sistemazione messaggio di errore.
 8    12/10/2005  SN      Errore rimappato attraverso si4.get_error.
 9    21/10/2005  SN      Modificato controllo errore.
 10   07/03/2006  SN      Controllo dinamico si4_get error e sistemata versione.
 11   30/08/2006  FT      Modifica dichiarazione subtype per incompatibilità con versione 7 di Oracle.
 12   14/09/2006  FT      In exec_postevent: inserita inizializzazione del nestlevel anche in caso di exception; corretta memorizzazione numero di righe processate.
 13   29/11/2006  FT      Modificata inizializzazione (a 0) del flag debug.
 14   04/12/2008  MM      Creazione procedure log.
 15   04/12/2008  MM      Creazione procedure log con parametro clob.
 16   13/05/2009  MM      Modificata procedure log con parametro clob.
 17   19/05/2009  MM      Modificata procedure log con parametro clob per incompatibilita con oracle 8.
 18   13/07/2011  FT      Allineati i commenti col nuovo standard di plsqldoc.
 19   05/03/2019  SN      In exec_postevent chiuso cursore in caso di errore.
 NOTA: In futuro verra tolta la substr nella SISTEMA MESSAGGIO quando verra
 rilasciata una versione di ad4 che lo consenta.
******************************************************************************/
as
   -- Nest level del triggerin esecuzione
   nestlevel          pls_integer;
   -- Variabile da valorizzare a 1 per visualizzare l'istruzione che genera errore in ExecPostEvent anche se con errore user defined (20999)
   debug              pls_integer := 0;
   -- Variabile utilizzata per la definizione del subtype t_lungo
   d_lungo varchar2 (32767);
   -- Type per la definizione di stringhe lunghe
   subtype t_lungo is d_lungo%type;
   -- Package body revision value
   s_revisione_body   t_revision  := '019';
   /******************************************************************************
    Restituisce versione e revisione di distribuzione del package.
   ******************************************************************************/
   function versione
   return t_revision
   is
   begin
      return s_revisione || '.' || s_revisione_body;
   end versione;
   /******************************************************************************
    Attiva la visualizzazione dell'istruzione che genera errore in ExecPostEvent anche se con errore user defined (20999).
   ******************************************************************************/
   procedure setdebugon
   is
   begin
      debug := 1;
   end;
   /******************************************************************************
    Disattiva la visualizzazione dell'istruzione che genera errore in ExecPostEvent anche se con errore user defined (20999).
   ******************************************************************************/
   procedure setdebugoff
   is
   begin
      debug := 0;
   end;
   /***********************************************************************************
    Esecuzione istruzioni memorizzate in POST Statement.
    %param p_errore: errore rilevato in esecuzione dello statement
    %param p_actual_istr: istruzione che ha generato l'errore
    %param p_messaggio: messaggio di errore da visualizzare
    %param p_codice: numero di errore da visualizzare
    REVISIONI.
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------------
    10   07/03/2006  SN    In caso di errore decide quale numero di errore visualizzare e quale messaggio. Se l'errore e user-defined quindi tra -20000 e -20999  si comporta in modo diverso a seconda che sia attivo o meno il debug:
                                     1)debug attivo: visualizza statement che ha causato l'errore.
                                     2)debug inattivo: visualizza solo il messaggio di errore.
                                     Se l'errore intercettato e generato direttamente da Oracle si pensa che fosse non voluto e viene sempre visualizzato lo statement che lo ha generato indipendentemente da come il debug e settato. Se durante l'errore viene scatenato un integrity error lo statement non viene mai visualizzato indipendentemente da come il debug e settato.
   ************************************************************************************/
   procedure sistema_messaggio_errore (
      p_errore        in       varchar2,
      p_actual_istr   in       varchar2,
      p_messaggio     out      varchar2,
      p_codice        out      varchar2
   ) is
      d_errore                t_lungo := p_errore;
      d_ultima_parte_errore   t_lungo;
      d_err_user_defined      boolean := false;
   begin
   d_errore := replace (d_errore, 'ORA-', 'ora-');
      if substr (d_errore, instr (d_errore, 'ora-') + 4, 2) = '20'
      then
         d_err_user_defined := true;
         -- se user defined ributto fuori lo stesso numero di errore
         p_codice := substr (d_errore, instr (d_errore, 'ora') + 3, 6);
      end if;
      declare
         cursor c_esiste_pac
         is
            select 1 esiste
              from all_arguments
             where package_name = 'SI4'
               and owner = user
               and position = 1
               and object_name = 'GET_ERROR';
         d_esiste_pac   c_esiste_pac%rowtype;
      begin
         open c_esiste_pac;
         fetch c_esiste_pac
          into d_esiste_pac;
         if c_esiste_pac%found and d_esiste_pac.esiste = 1
         then
            -- sistema d_errore ricaricandolo con sql dinamico
            declare
               cursor_name      integer;
               rows_processed   integer;
               d_ritorno        t_lungo;
            begin
               cursor_name := DBMS_SQL.open_cursor;
               DBMS_SQL.parse (cursor_name,
                                  'select si4.get_error('''
                               || replace (p_errore, '''', '''''')
                               || ''') from dual',
                               DBMS_SQL.native
                              );
               DBMS_SQL.define_column (cursor_name, 1, d_ritorno, 32000);
               rows_processed := DBMS_SQL.execute (cursor_name);
               --esecuzione istruzione e controllo errore
               if DBMS_SQL.fetch_rows (cursor_name) > 0
               then
                  DBMS_SQL.column_value (cursor_name, 1, d_ritorno);
                  d_errore := d_ritorno;
               -- dinamico = si4.get_error(p_errore);
               end if;
               DBMS_SQL.close_cursor (cursor_name);
            exception
               when others
               then
                  DBMS_SQL.close_cursor (cursor_name);
                  raise;
            end;
         end if;
         close c_esiste_pac;
      end;
      d_errore := replace (d_errore, 'ORA-', 'ora-');
      initnestlevel;
      p_messaggio := null;
      -- se user defined visualizzo l'istruzione solo se debug = 1
      -- altrimenti sempre visualizzata istruzione
      if d_err_user_defined
      then         -- se user defined ributto fuori lo stesso numero di errore
         if instr (d_errore, 'ora') = 1 -- inizia con codice errore
         then
         d_errore := substr (d_errore, 11);
         end if;
         if instr (d_errore, 'ora-') > 0
         then
            d_ultima_parte_errore :=
                                  substr (d_errore, instr (d_errore, 'ora-'));
            d_errore :=
               rtrim (substr (d_errore, 1, instr (d_errore, 'ora-') - 1),
                      chr (10)
                     );
         end if;
      else                                                 -- non user defined
         p_codice := -20999;
      end if;
      p_messaggio := d_errore || chr (10);
      if not d_err_user_defined or debug = 1
      then   -- se non user defined o debug attivo visualizzo anche istruzione
         p_messaggio := p_messaggio || 'ISTRUZIONE :' || p_actual_istr;
      end if;
      p_messaggio := p_messaggio || chr (10) || d_ultima_parte_errore;
      -- vincolo in powerbuilder messaggio minore di 200 caratteri
      p_messaggio := substr (p_messaggio, 1, 200) || '...';
   end sistema_messaggio_errore;
   /******************************************************************************
    Procedure to Initialize Switched Functional Integrity.
   ******************************************************************************/
   procedure setfunctional
   is
   begin
      functional := true;
   end;
   /******************************************************************************
    Procedure to Reset Switched Functional Integrity.
   ******************************************************************************/
   procedure resetfunctional
   is
   begin
      functional := false;
   end;
   /******************************************************************************
    Procedure to initialize the trigger nest level.
   ******************************************************************************/
   procedure initnestlevel
   is
   begin
      nestlevel := 0;
      d_entry := 0;
   end;
   /******************************************************************************
    Function to return the trigger nest level.
   ******************************************************************************/
   function getnestlevel
      return number
   is
   begin
      if nestlevel is null
      then
         nestlevel := 0;
      end if;
      return (nestlevel);
   end;
   /******************************************************************************
    Procedure to increase the trigger nest level
   ******************************************************************************/
   procedure nextnestlevel
   is
   begin
      if nestlevel is null
      then
         nestlevel := 0;
      end if;
      nestlevel := nestlevel + 1;
   end;
   /******************************************************************************
    Procedure to decrease the trigger nest level
   ******************************************************************************/
   procedure previousnestlevel
   is
   begin
      nestlevel := nestlevel - 1;
   end;
   /******************************************************************************
    Memorizzazione istruzioni da attivare in POST statement.
    REVISIONI.
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    1    23/01/2001  MF    Inserimento commento.
   ******************************************************************************/
   procedure set_postevent
   (p_istruzione in varchar2, p_messaggio in varchar2)
   is
      actual_level   pls_integer;
   begin
      actual_level := integritypackage.getnestlevel;
      d_entry := d_entry + 1;
      d_istruzione (d_entry) := p_istruzione;
      d_messaggio (d_entry) := lpad (actual_level, 2, '0') || p_messaggio;
   end set_postevent;
   /***********************************************************************************
    Esecuzione istruzioni memorizzate in POST Statement.
    REVISIONI.
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------------
    1    23/01/2001  MF    Inserimento commento.
    2    04/12/2002  SN    In caso di errore visualizza lo statement.
    3    22/12/2003  SN    Rilevamento errore in caso di select; Sistemazione frase in base a default stabiliti.
    4    10/05/2004  SN    Modificato ExecPostEvent per gestione errore 20999 e visualizzazione statement solo se variabile debug a 1. Usati solo 200 caratteri per messaggio di errore altrimenti problemi durante la visualizzazione in PB (x lo standard).
    10   31/10/2005  SN    Tolta substr del messaggio di errore a 200 caratteri.
    12   14/09/2006  FT    In exec_postevent: inserita inizializzazione del nestlevel anche in caso di exception; corretta memorizzazione numero di righe processate.
    19   05/03/2019  SN    In exec_postevent chiuso cursore in caso di errore.
   ************************************************************************************/
   procedure exec_postevent
   is
      cursor_id         pls_integer;
      rows_processed    pls_integer;
      actual_level      pls_integer;
      element_level     pls_integer;
      element_message   varchar2 (2000);
      d_actual_istr     t_lungo;
      d_ritorno         t_lungo;
      d_messaggio_out   t_lungo;
      d_codice_out      number (10);
   begin
      actual_level := integritypackage.getnestlevel;
      for loopcnt in 1 .. d_entry
      loop
         element_level := to_number (substr (d_messaggio (loopcnt), 1, 2));
         if element_level = actual_level
            and d_istruzione (loopcnt) is not null
         then
            integritypackage.nextnestlevel;
            begin
               d_actual_istr := d_istruzione (loopcnt);
               cursor_id := DBMS_SQL.open_cursor;
               begin
                  -- controllo ed eventuale  modifica statement
                  if upper (substr (ltrim (d_istruzione (loopcnt)), 1, 6)) =
                                                                     'SELECT'
                  then
                     d_istruzione (loopcnt) :=
                                         rtrim (d_istruzione (loopcnt), ' ;');
                  else                                           -- non select
                     --se non ci sono mettere begin e end
                     if upper (substr (ltrim (d_istruzione (loopcnt)), 1, 2)) =
                                                                         ':='
                     then
                        -- AGGIUNGO LA GESTIONE DEL RITORNO
                        d_istruzione (loopcnt) :=
                              'DECLARE d_RITORNO VARCHAR2(32000);'
                           || 'BEGIN d_RITORNO'
                           || rtrim (d_istruzione (loopcnt), ' ;')
                           || '; END;';
                     elsif upper (substr (ltrim (d_istruzione (loopcnt)), 1,
                                          5)
                                 ) != 'BEGIN'
                     then
                        -- in caso di declare mette un altro begin end esterno
                        d_istruzione (loopcnt) :=
                              'BEGIN '
                           || rtrim (d_istruzione (loopcnt), ' ;')
                           || '; END;';
                     end if;
                  end if;
                  -- controllo sintattico istruzione
                  -- Tolta andata a capo chr(13) || chr(10) altrimenti
                  -- errore inspiegabile se presente... dice che la sintassi
                  -- e sbagliata
                  DBMS_SQL.parse (cursor_id,
                                  replace (d_istruzione (loopcnt),
                                           chr (13) || chr (10),
                                           ' '
                                          ),
                                  DBMS_SQL.native
                                 );
               exception
                  when others
                  then
                     sistema_messaggio_errore (sqlerrm,
                                               d_actual_istr,
                                               d_messaggio_out,
                                               d_codice_out
                                              );
                     if d_messaggio_out is not null
                     then
                        raise_application_error (d_codice_out,
                                                 d_messaggio_out
                                                );
                     else
                        raise;
                     end if;
               end;
               if upper (substr (ltrim (d_istruzione (loopcnt)), 1, 6)) =
                                                                      'SELECT'
               then
                  begin            --esecuzione istruzione e controllo errore
                     -- definizione della colonna. Serve per riuscire ad
                     -- intercettare gli errori ORA-
                     -- non importa effettivamente caricare il valore
                     DBMS_SQL.define_column (cursor_id, 1, d_ritorno, 32000);
                     --esecuzione istruzione e controllo errore
                     rows_processed := DBMS_SQL.execute (cursor_id);
                     if DBMS_SQL.fetch_rows (cursor_id) > 0
                     then
                        rows_processed := 1;
                     end if;
                  exception
                     when others
                     then
                        sistema_messaggio_errore (sqlerrm,
                                                  d_actual_istr,
                                                  d_messaggio_out,
                                                  d_codice_out
                                                 );
                        if d_messaggio_out is not null
                        then
                           raise_application_error (d_codice_out,
                                                    d_messaggio_out
                                                   );
                        else
                           raise;
                        end if;
                  end;
                  if     rows_processed > 0
                     and substr (ltrim (substr (ltrim (d_istruzione (loopcnt)),
                                                7
                                               )
                                       ),
                                 1,
                                 1
                                ) = '0'
                  then
                     element_message := substr (d_messaggio (loopcnt), 3);
                     if element_message is null
                     then
                        element_message :=
                           'Sono presenti registrazioni collegate. Operazione non eseguita.';
                     end if;
                     raise_application_error (-20008, element_message);
                  elsif     rows_processed = 0
                        and substr
                                (ltrim (substr (ltrim (d_istruzione (loopcnt)),
                                                7
                                               )
                                       ),
                                 1,
                                 1
                                ) != '0'
                  then
                     element_message := substr (d_messaggio (loopcnt), 3);
                     if element_message is null
                     then
                        element_message :=
                           'Non e'' presente la registrazione richiesta. Operazione non eseguita.';
                     end if;
                     raise_application_error (-20008, element_message);
                  end if;
               else                                 -- non statement di SELECT
                  begin
                     rows_processed := DBMS_SQL.execute (cursor_id);
                  exception
                     when integrityerror
                     then
                        raise_application_error
                                               (-20999,
                                                substr (d_messaggio (loopcnt),
                                                        3
                                                       )
                                               );
                     when others
                     then
                        -- per evitare problemi con PB e la gestione errori scrivo minuscolo
                        sistema_messaggio_errore (sqlerrm,
                                                  d_actual_istr,
                                                  d_messaggio_out,
                                                  d_codice_out
                                                 );
                        if d_messaggio_out is not null
                        then
                           raise_application_error (d_codice_out,
                                                    d_messaggio_out
                                                   );
                        else
                           raise;
                        end if;
                  end;
               end if;
               DBMS_SQL.close_cursor (cursor_id);
            end;
            integritypackage.previousnestlevel;
            d_istruzione (loopcnt) := null;
         end if;
      end loop;
   exception
   when others then
      integritypackage.initnestlevel;
      -- rev. 19 inizio
      if dbms_sql.is_open(cursor_id) then
         DBMS_SQL.close_cursor (cursor_id);
      end if;
      -- rev. 19 fine
      raise;
   end exec_postevent;
   /***********************************************************************************
    Emissione log se previsto debug (debug = 1).
    %note p_log di tipo varchar2
    REVISIONI.
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------------
    14   04/12/2008 MM     Creazione.
   ************************************************************************************/
   procedure log
   (p_log in varchar2)
   is
      d_max integer:=250;
   begin
      if debug = 1 then
         if nvl(length(p_log),0) <= d_max then
            dbms_output.put_line(p_log);
         else
            declare
               i integer;
               d_inizio integer;
               d_loop integer:=ceil(length(p_log)/d_max);
            begin
               for i in 1 .. d_loop loop
                  d_inizio := ((i - 1) * d_max) + 1;
                  dbms_output.put_line(substr(p_log, d_inizio, d_max));
               end loop;
            end;
         end if;
      end if;
   end log;
   /***********************************************************************************
    Emissione log se previsto debug (debug = 1).
    %note p_log di tipo varchar2
    REVISIONI.
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------------
    15   20/03/2009 MM     Creazione.
    16   13/05/2009 MM     Modificata procedure log con parametro clob.
    17   19/05/2009  MM    Modificata procedure log con parametro clob per incompatibilita con oracle 8.
   ************************************************************************************/
   procedure log
   (p_log in clob)
   is
      d_max integer:=250;
      d_log varchar2(32767);
   begin
      d_log := dbms_lob.SUBSTR(p_log, 32000,1);
      if dbms_lob.GETLENGTH(p_log) > 32767 then
         d_log := d_log ||'...';
      end if;
      log(d_log);
   end log;
end integritypackage;
/

