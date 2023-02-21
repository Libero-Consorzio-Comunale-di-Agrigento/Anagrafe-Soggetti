CREATE OR REPLACE PACKAGE BODY contatti_pkg
/******************************************************************************
 NOME:        recapiti_pkg
 DESCRIZIONE: Gestione tabella RECAPITI.
 ANNOTAZIONI: .
 REVISIONI:   .
 Rev.  Data        Autore  Descrizione.
 001   13/02/2018  SN      Prima emissione
 002   11/09/2018  SN      Sistemazione verifica importanza
 003   27/03/2019  SN      Chiusi solo i contatti ancora aperti
 004   17/09/2019  SNeg   RRI togliere nvl in verifica di periodo già chiuso con competenza P Bug #36936
 005   29/12/2020  SN     Chiusura cursore aperto Bug #47059
******************************************************************************/
is
    s_revisione_body      constant AFC.t_revision := '005 - 29/12/2020';
   s_error_table AFC_Error.t_error_table;
   s_error_detail AFC_Error.t_error_table;
   s_warning afc.t_statement;
   d_warning_num integer;
   d_warning_msg afc.t_statement;
   d_warning     afc.t_statement;
   i integer := 1;
   /***************************************************************************************************
   d_result := s_non_modificabile_storico_num;
      s_error_detail (d_result) :='(registrazioni storiche precedenti il '
                                || TO_CHAR (d_al, 'dd/mm/yyyy')
                           || ' non consentita. Recapito storico di competenza parziale di altro progetto.)';
    IF d_result = AFC_Error.ok then
    ***************************************************************************************************/
function versione
return varchar2 is
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
end versione; -- anagrafici_pkg.versione
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE CONTATTI_RRI
/******************************************************************************
 NOME:        CONTATTI_RRI
 DESCRIZIONE: Gestisce la storicizzazione dei dati di un soggetto:
              - aggiorna la data di fine validita' dell'ultima registrazione
                storica.
 ARGOMENTI:   p_id_recapito  IN number Numero Individuale del soggetto.
              p_dal IN date   Data di inizio validita' del soggetto.
 ECCEZIONI:
 ANNOTAZIONI: la procedure viene lanciata in Post Event dal trigger
              CONTATTI_TIU in seguito all'inserimento di un nuovo
              record.
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 0    09/05/2017 SNeg    Prima emissione
 1    13/02/2018 SN     Controlli non effettuati in trasco
 3   27/03/2019  SN      Chiusi solo i contatti ancora aperti
 4   17/09/2019  SNeg   RRI togliere nvl in verifica di periodo già chiuso con competenza P
******************************************************************************/
( p_id_recapito IN NUMBER
, p_dal        IN DATE
, p_competenza IN VARCHAR2
, p_competenza_esclusiva IN VARCHAR2
, p_ID_TIPO_contatto number
)
IS
   dDalStorico DATE;
   d_al DATE;
   dCompetenza varchar2(100);
   dCompetenzaEsclusiva varchar2(10);
    v_num_contatti   NUMBER;
    errno            INTEGER;
    errmsg           CHAR (200);
    integrity_error   EXCEPTION;
    d_result AFC_ERROR.t_error_number;
BEGIN
if nvl(anagrafici_pkg.trasco,0) != 1 then -- NON sono in trasco faccio i controlli
   SELECT MAX(al) -- rev. 4
     INTO d_al
    FROM CONTATTI
   WHERE id_recapito = p_id_recapito
     AND p_dal BETWEEN dal AND NVL(al,TRUNC(SYSDATE))
     AND substr(NVL(competenza,'xxx'), 1, 2) <> substr(NVL(p_competenza,'xxx'), 1, 2)
     AND competenza_esclusiva = 'P'
     AND id_tipo_contatto = p_ID_TIPO_contatto
   ;
   IF d_al IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(-20999, si4.GET_ERROR('A10046') ||
      ' Modifica registrazioni storiche precedenti al '||TO_CHAR(d_al,'dd/mm/yyyy')||' non consentita. Contatto storico di competenza parziale di altro progetto.');
   END IF;
      -- Cerca eventuali Registrazioni storiche.
   BEGIN
--   raise_application_error (-20999,' reg storiche id_recapito' || p_id_recapito || ' p_id_tipo_contatto:' || p_id_tipo_contatto
--    || ' p_dal:' || p_dal);
      SELECT dal, competenza, competenza_esclusiva
        INTO dDalStorico, dCompetenza, dCompetenzaEsclusiva
        FROM CONTATTI
       WHERE id_recapito  = p_id_recapito
         AND id_tipo_contatto = p_id_tipo_contatto
         AND upper(tipi_contatto_tpk.get_unico(p_id_tipo_contatto))!= 'NO' -- è unico
         -- solo se è  UNICO devo chiudere il precedente
         -- devo prevedere una voce di registro??
         AND dal = (SELECT MAX(dal)
                      FROM CONTATTI
                     WHERE id_recapito  = p_id_recapito
                       AND dal < p_dal
                       AND id_tipo_contatto = p_id_tipo_contatto
                       AND al is null -- posso sistemare solo periodi aperti
                   )
         AND al is null
      ;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         dDalStorico := TO_DATE('27/02/0001','dd/mm/yyyy');
      WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20999,si4.get_error('A10068')
--         'Recupero data di inizio validita'' della registrazione storica.'
           ||CHR(10)||SUBSTR(SQLERRM,5));
   END;
   -- Se esistono Registrazioni storiche.
  IF dDalStorico <>  TO_DATE('27/02/0001','dd/mm/yyyy') THEN
      -- Rev.3 del 01/09/2009 MM: gestione competenza esclusiva del record da storicizzare.
      -- Rev.4 del 13/12/2011 SNeg: controllo anche se non competenza esclusiva = E
      d_result := anagrafici_pkg.is_competenza_ok
        ( p_competenza=>p_competenza
        , p_competenza_esclusiva =>p_competenza_esclusiva
        , p_competenza_old => dCompetenza
        , p_competenza_esclusiva_old => dCompetenzaEsclusiva
        ) ;
      IF not ( d_result = AFC_Error.ok )
       then
          anagrafici_pkg.raise_error_message(d_result);
      end if;
     -- Rev.4 del 13/12/2011 SNeg: fine mod.
      -- Rev.3 del 01/09/2009 MM : fine mod.
      -- Rev.2 del 22/06/2006 MM: Gestione motivo_blocco di XX4_ANAGRAFICI.
      -- Verifica la presenza del soggetto nella vista di integrita' referenziale
      -- ed il motivo del blocco del record:
      -- se il soggetto e' presente nella vista e motivo_blocco = D (nessun
      -- campo del record e' modificabile ad eccezione di AL = e' storicizzabile)
      -- e nel nuovo record creato i campi COGNOME e NOME devono essere uguali a
      -- quelli del record storico),
      --    se e' stato modificato il campo COGNOME od il campo NOME, non permette
      --    la modifica.
       -- Rev.4    19/10/2009 MM: Errore se esistono piu' record in xx4_anagrafici
       -- per stessi id_recapito e dal.
         BEGIN
            FOR c_ref IN (SELECT oggetto, motivo_blocco
                            FROM xx4_CONTATTI
                           WHERE id_recapito = p_id_recapito AND dal = ddalstorico)
            LOOP
               IF     c_ref.motivo_blocco = 'D'
               THEN
                  raise_application_error
                       (-20999,
                        si4.GET_ERROR('A10044')
                        || ' Esistono riferimenti su CONTATTI ('
                        || c_ref.oggetto
                        || '). La registrazione non e'' modificabile (motivo blocco: '
                        || c_ref.motivo_blocco
                        || ').'
                       );
               END IF;
            END LOOP;
         END;
      -- Aggiornamento storico contatto
      BEGIN
         UPDATE CONTATTI
            SET al  = p_dal - 1
          WHERE id_recapito  = p_id_recapito
            AND dal = dDalStorico
            AND al is null  -- rev. 3
         ;
      EXCEPTION WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20999,si4.get_error('A10069')
--         'Aggiornamento data di fine validita'' della registrazione storica.'
         ||CHR(10)||SUBSTR(SQLERRM,5));
      END;
   END IF;
-- quando dovrebbe essere tutto OK
   -- CONTROLLARE x CONTATTI UNICI che non ci sia già presente un record
   IF tipi_contatto_tpk.get_unico (p_ID_TIPO_CONTATTO) = 'SI'
   THEN
      BEGIN
         SELECT COUNT (*)
           INTO v_num_contatti
           FROM contatti
          WHERE id_recapito = p_id_recapito
            AND id_tipo_contatto = p_id_tipo_contatto
            and dal = p_dal
            AND AL IS NULL;
         IF v_num_contatti > 1
         THEN
            errno := -20007;
            errmsg := si4.GET_ERROR('A10047') ;
--                 || ' Impossibile inserire più riferimenti ad un contatto indicato come UNICO ';
            RAISE integrity_error;
         END IF;                      -- Ignora Check su UNIQUE PK Integrity
      END;
   END IF;
end if; -- NON sono in trasco
EXCEPTION
   WHEN integrity_error
   THEN
      integritypackage.initnestlevel;
      raise_application_error (errno, errmsg);
   WHEN OTHERS
   THEN
      integritypackage.initnestlevel;
      RAISE;
END;
/* End Procedure: CONTATTI_RRI */
PROCEDURE CONTATTI_PU
/******************************************************************************
 NOME:        CONTATTI_PU
 DESCRIZIONE: Procedure for Check REFERENTIAL Integrity
                         at UPDATE on Table CONTATTI
 ARGOMENTI:   Rigenerati in automatico.
 ECCEZIONI:  -20001, Informazione COLONNA non modificabile
             -20003, Non esiste riferimento su PARENT TABLE
             -20004, Identificazione di TABLE non modificabile
             -20005, Esistono riferimenti su CHILD TABLE
 ANNOTAZIONI: Richiamata da Trigger CONTATTI_TIU
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
                        Prima Emissione
******************************************************************************/
(  old_id_contatto IN NUMBER
 , old_id_recapito IN NUMBER
 , old_dal IN DATE
 , old_id_tipo_contatto IN NUMBER
 , new_id_contatto IN NUMBER
 , new_id_recapito IN NUMBER
 , new_dal IN DATE
 , new_id_tipo_contatto IN NUMBER
)
IS
   integrity_error  EXCEPTION;
   errno            INTEGER;
   errmsg           CHAR(200);
   dummy            INTEGER;
   FOUND            BOOLEAN;
   oggetto          VARCHAR2(200);
   motivo_blocco    VARCHAR2(200);
   seq              NUMBER;
   mutating         EXCEPTION;
   PRAGMA EXCEPTION_INIT(mutating, -4091);
   --  Dichiarazione UpdateChildParentExist constraint per la tabella "RECAPITI"
   CURSOR cpk1_contatti(var_id_recapito VARCHAR) IS
      SELECT 1
      FROM   RECAPITI
      WHERE  id_recapito = var_id_recapito
        AND  var_id_recapito is not null ;
   --  Dichiarazione UpdateChildParentExist constraint per la tabella "TIPI_CONTATTO"
   CURSOR cpk2_tipi_contatto(var_id_tipo_contatto VARCHAR) IS
      SELECT 1
      FROM   TIPI_CONTATTO
      WHERE  id_TIPO_CONTATTO = var_id_tipo_contatto
       AND   var_id_tipo_contatto IS NOT NULL;
   --  Declaration of UpdateParentRestrict constraint for "XX4_CONTATTI"
   CURSOR cfk1_contatti(var_id_contatto NUMBER, var_dal DATE) IS
      SELECT oggetto, motivo_blocco
      FROM   XX4_CONTATTI
      WHERE  id_contatto = var_id_contatto
       AND   dal = var_dal
       AND   var_id_contatto IS NOT NULL
       AND   var_dal IS NOT NULL;
BEGIN
  IF --UPDATING AND
     NEW_id_tipo_contatto != OLD_id_tipo_contatto
   THEN
      raise_application_error (-20999,
                               si4.get_error('A10066')
--                               'Impossibile modificare il tipo di Contatto'
                               );
   END IF;
  IF --UPDATING AND
    old_id_recapito != new_id_recapito
   THEN
      raise_application_error (
         -20999,
         si4.get_error('A10065')
--         'Impossibile cambiare Recapito di riferimento'
         );
   END IF;
   BEGIN  -- Check REFERENTIAL Integrity
      --  Chiave di "CONTATTI" non modificabile se esistono referenze su "XX4_CONTATTI"
      OPEN  cfk1_contatti(OLD_id_contatto,OLD_DAL);
      FETCH cfk1_contatti INTO oggetto, motivo_blocco;
      FOUND := cfk1_contatti%FOUND;
      CLOSE cfk1_contatti;
      IF FOUND THEN
         IF (OLD_id_contatto != NEW_id_contatto) OR (OLD_DAL != NEW_DAL) OR (motivo_blocco = 'R') THEN
          errno  := -20005;
          errmsg := si4.GET_ERROR('A10044') || ' Esistono riferimenti su Contatti ('||oggetto||').';
          IF motivo_blocco = 'R' THEN
             errmsg := errmsg ||'(motivo blocco: '||motivo_blocco||')';
          END IF;
          RAISE integrity_error;
         END IF;
      END IF;
   END;
    seq := Integritypackage.GetNestLevel;
      BEGIN  --  Parent "TIPI_CONTATTO" deve esistere quando si modifica "RECAPITI"
         IF  NEW_ID_TIPO_CONTATTO IS NOT NULL AND ( seq = 0 )
         AND (   (NEW_ID_TIPO_CONTATTO != OLD_ID_TIPO_CONTATTO OR OLD_ID_TIPO_CONTATTO IS NULL) ) THEN
            OPEN  cpk2_tipi_contatto(NEW_ID_TIPO_CONTATTO);
            FETCH cpk2_tipi_contatto INTO dummy;
            FOUND := cpk2_tipi_contatto%FOUND;
            CLOSE cpk2_tipi_contatto;
            IF NOT FOUND THEN
          errno  := -20003;
          errmsg :=  si4.GET_ERROR('A10052'); -- || ' Non esiste riferimento su Tipi Contatto. La registrazione Contatti non e'' modificabile.';
          RAISE integrity_error;
            END IF;
         END IF;
      EXCEPTION
         WHEN MUTATING THEN NULL;  -- Ignora Check su Relazioni Ricorsive
      END;
      BEGIN  --  Parent "ID_RECAPITO" deve esistere quando si modifica "CONTATTI"
         IF  NEW_ID_RECAPITO IS NOT NULL AND ( seq = 0 )
         AND (   (NEW_ID_RECAPITO != OLD_ID_RECAPITO OR OLD_ID_RECAPITO IS NULL) ) THEN
            OPEN cpk1_contatti(NEW_id_recapito);
            FETCH cpk1_contatti INTO dummy;
            FOUND := cpk1_contatti%FOUND;
            CLOSE cpk1_contatti;
            IF NOT FOUND THEN
          errno  := -20003;
          errmsg := si4.GET_ERROR('A10055') ;--|| ' Non esiste riferimento su Recapiti. La registrazione CONTATTI non e'' modificabile.';
          RAISE integrity_error;
            END IF;
         END IF;
      EXCEPTION
         WHEN MUTATING THEN NULL;  -- Ignora Check su Relazioni Ricorsive
      END;
   END;
/* End Procedure: CONTATTI_PU */
PROCEDURE CONTATTI_PI
/******************************************************************************
 NOME:        CONTATTI_PI
 DESCRIZIONE: Procedure for Check REFERENTIAL Integrity
                         at INSERT on Table CONTATTI
 ARGOMENTI:   Rigenerati in automatico.
 ECCEZIONI:  -20001, Informazione COLONNA non modificabile
             -20003, Non esiste riferimento su PARENT TABLE
             -20004, Identificazione di TABLE non modificabile
             -20005, Esistono riferimenti su CHILD TABLE
 ANNOTAZIONI: Richiamata da Trigger CONTATTI_TIU
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
                        Prima Emissione
 1    13/02/2018 SN     Controlli non effettuati in trasco
******************************************************************************/
(  old_id_contatto IN NUMBER
 , old_id_recapito IN NUMBER
 , old_dal IN DATE
 , old_id_tipo_contatto IN NUMBER
 , new_id_contatto IN NUMBER
 , new_id_recapito IN NUMBER
 , new_dal IN DATE
 , new_id_tipo_contatto IN NUMBER
)
IS
   integrity_error  EXCEPTION;
   errno            INTEGER;
   errmsg           CHAR(200);
   dummy            INTEGER;
   FOUND            BOOLEAN;
   oggetto          VARCHAR2(200);
   motivo_blocco    VARCHAR2(200);
   seq              NUMBER;
   mutating         EXCEPTION;
   PRAGMA EXCEPTION_INIT(mutating, -4091);
   --  Dichiarazione UpdateChildParentExist constraint per la tabella "RECAPITI"
   CURSOR cpk1_contatti(var_id_recapito VARCHAR) IS
      SELECT 1
      FROM   RECAPITI
      WHERE  id_recapito = var_id_recapito
        AND  var_id_recapito is not null ;
   --  Dichiarazione UpdateChildParentExist constraint per la tabella "TIPI_CONTATTO"
   CURSOR cpk2_tipi_contatto(var_id_tipo_contatto VARCHAR) IS
      SELECT 1
      FROM   TIPI_CONTATTO
      WHERE  id_TIPO_CONTATTO = var_id_tipo_contatto
       AND   var_id_tipo_contatto IS NOT NULL;
BEGIN
if nvl(anagrafici_pkg.trasco,0) != 1  then -- NON  sono in trasco faccio i controlli
    seq := Integritypackage.GetNestLevel;
   IF --INSERTING AND
      NEW_id_recapito IS NULL
   THEN
      raise_application_error (
         -20999,
         si4.get_error('A10055')
--         'Impossibile inserire un record senza Recapito di riferimento'
         );
   END IF;
      BEGIN  --  Parent "TIPI_CONTATTO" deve esistere quando si modifica "CONTATTI"
         IF  NEW_ID_TIPO_CONTATTO IS NOT NULL AND ( seq = 0 )
         AND (   (NEW_ID_TIPO_CONTATTO != OLD_ID_TIPO_CONTATTO OR OLD_ID_TIPO_CONTATTO IS NULL) ) THEN
            OPEN  cpk2_tipi_contatto(NEW_ID_TIPO_CONTATTO);
            FETCH cpk2_tipi_contatto INTO dummy;
            FOUND := cpk2_tipi_contatto%FOUND;
            CLOSE cpk2_tipi_contatto;
            IF NOT FOUND THEN
          errno  := -20003;
          errmsg := si4.GET_ERROR('A10052') ; --|| ' Non esiste riferimento su Tipi Contatto. La registrazione Contatti non e'' modificabile.';
          RAISE integrity_error;
            END IF;
         END IF;
      EXCEPTION
         WHEN MUTATING THEN NULL;  -- Ignora Check su Relazioni Ricorsive
      END;
      BEGIN  --  Parent "ID_RECAPITO" deve esistere quando si modifica "CONTATTI"
         IF NEW_ID_RECAPITO IS NOT NULL AND ( seq = 0 )
         AND (   (NEW_ID_RECAPITO != OLD_ID_RECAPITO OR OLD_ID_RECAPITO IS NULL) ) THEN
            OPEN cpk1_contatti(NEW_id_recapito);
            FETCH cpk1_contatti INTO dummy;
            FOUND := cpk1_contatti%FOUND;
            CLOSE cpk1_contatti;
            IF NOT FOUND THEN
          errno  := -20003;
          errmsg := si4.GET_ERROR('A10055'); -- || ' Non esiste riferimento su RECAPITI. La registrazione CONTATTI non e'' modificabile.';
          RAISE integrity_error;
            END IF;
         END IF;
      EXCEPTION
         WHEN MUTATING THEN NULL;  -- Ignora Check su Relazioni Ricorsive
      END;
end if; -- NON sono in trasco
   END;
/* END Procedure CONTATTI_PI */
procedure CONTATTI_PD
/******************************************************************************
 NOME:        CONTATTI_PD
 DESCRIZIONE: Procedure for Check REFERENTIAL Integrity
                         at DELETE on Table CONTATTI
 ARGOMENTI:   Rigenerati in automatico.
 ECCEZIONI:  -20006, Esistono riferimenti su CHILD TABLE
 ANNOTAZIONI: Richiamata da Trigger CONTATTI_TD
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
    0 07/09/2005 MM     Introduzione controllo di integrita referenziale su
                       XX4_CONTATTI.
******************************************************************************/
(old_id_contatto IN number,
 old_dal IN date,
 old_al IN date)
is
   integrity_error  exception;
   errno            integer;
   errmsg           char(200);
   dummy            integer;
   found            boolean;
   oggetto          varchar2(200);
   --  Declaration of DeleteParentRestrict constraint for "XX4_CONTATTI"
   cursor cfk1_CONTATTI(var_id_contatto number, var_dal date, var_al date) is
      select oggetto
      from   XX4_CONTATTI
      where  id_contatto = var_id_contatto
       and   dal between var_dal and nvl(var_al,to_date('3333333','j'))
       and   var_id_contatto is not null
       and   var_dal is not null
     UNION
      select oggetto
      from   XX4_CONTATTI
      where  id_contatto = var_id_contatto
       and   var_id_contatto is not null
       and   var_dal is null; -- se dal e' nullo nessuna registrazione e' eliminabile
begin
   begin  -- Check REFERENTIAL Integrity
      --  Cannot delete parent "CONTATTI" if children still exist in "XX4_CONTATTI"
      open  cfk1_CONTATTI(OLD_id_contatto,OLD_DAL,OLD_AL);
      fetch cfk1_CONTATTI into oggetto;
      found := cfk1_CONTATTI%FOUND;
      close cfk1_CONTATTI;
      if found then
          errno  := -20006;
          errmsg := si4.GET_ERROR('A10043') || ' ('||oggetto||')';
          raise integrity_error;
      end if;
      null;
   end;
exception
   when integrity_error then
        IntegrityPackage.InitNestLevel;
        raise_application_error(errno, errmsg);
   when others then
        IntegrityPackage.InitNestLevel;
        raise;
end;
/* End Procedure: CONTATTI_PD */
FUNCTION CONTA_RECAP_CONTATTI_DAL_AL (p_id_recapito NUMBER, p_new_id_tipo_contatto number, p_dal date, p_al date)
   RETURN NUMBER
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   v_num_id_recapito   NUMBER;
BEGIN
   SELECT COUNT (*)
     INTO v_num_id_recapito
     FROM CONTATTI
    WHERE id_recapito = p_id_recapito
      AND id_tipo_contatto = p_new_id_tipo_contatto
      AND tipi_contatto_tpk.get_unico(p_new_id_tipo_contatto) = 'SI' -- verifica se richiesto che sia unico
      AND (dal between p_dal and nvl(p_al, to_date('3333333','j'))
         OR p_dal between dal and nvl(al, to_date('3333333','j'))
         );
   RETURN v_num_id_recapito;
END;
/* End Functon: CONTA_RECAP_CONTATTI_DAL_AL */
FUNCTION CONTA_RECAP_CONTATTI (p_id_recapito NUMBER, p_new_id_tipo_contatto number)
   RETURN NUMBER
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   v_num_id_recapito   NUMBER;
BEGIN
   SELECT COUNT (*)
     INTO v_num_id_recapito
     FROM CONTATTI
    WHERE id_recapito = p_id_recapito
      AND id_tipo_contatto = p_new_id_tipo_contatto;
   RETURN v_num_id_recapito;
END;
/* End Functon: CONTA_RECAP_CONTATTI*/

PROCEDURE CHECK_CONTATTO_UNIVOCO (var_id_contatto         NUMBER,
                                  var_id_recapito         NUMBER,
                                  var_valore              VARCHAR2,
                                  var_id_tipo_contatto    VARCHAR2,
                                  var_dal                 DATE,
                                  var_al                  DATE)
IS
      v_id_contatto contatti.id_contatto%TYPE;
      FOUND boolean;
      --  Controllo se esiste un record con valore uguale
      CURSOR check_contatti(var_id_contatto NUMBER, var_id_recapito NUMBER, var_valore varchar2, var_id_tipo_contatto varchar2, var_dal date, var_al date ) IS
      SELECT id_contatto
      FROM   CONTATTI
      WHERE  id_recapito = var_id_recapito
       AND   TIPI_CONTATTO_TPK.GET_TIPO_SPEDIZIONE(id_tipo_contatto) = TIPI_CONTATTO_TPK.GET_TIPO_SPEDIZIONE(var_id_tipo_contatto)
       AND   TIPI_CONTATTO_TPK.GET_TIPO_SPEDIZIONE(id_tipo_contatto) is not null
       AND   TIPI_CONTATTO_TPK.GET_TIPO_SPEDIZIONE(var_id_tipo_contatto) is not null
       AND   trim(upper(valore))  = trim(upper(var_valore))
       AND   (dal between var_dal and nvl(var_al, to_date('3333333','j'))
             OR   var_dal between dal and nvl(al, to_date('3333333','j')))
       AND   var_valore IS NOT NULL
       AND   id_contatto != var_id_contatto
       UNION ALL
       SELECT id_contatto
      FROM   CONTATTI
      WHERE  id_recapito = var_id_recapito
       AND   TIPI_CONTATTO_TPK.GET_TIPO_SPEDIZIONE(id_tipo_contatto) is  null
       AND   TIPI_CONTATTO_TPK.GET_TIPO_SPEDIZIONE(var_id_tipo_contatto) is  null
       AND   id_tipo_contatto = var_id_tipo_contatto -- solo se tipo_spedizione è nulla
       AND   trim(upper(valore))  = trim(upper(var_valore))
       AND   (dal between var_dal and nvl(var_al, to_date('3333333','j'))
             OR   var_dal between dal and nvl(al, to_date('3333333','j')))
       AND   var_valore IS NOT NULL
       AND   id_contatto != var_id_contatto;
     BEGIN  -- Check REFERENTIAL Integrity
      OPEN  check_contatti(var_id_contatto, var_id_recapito , var_valore ,  var_id_tipo_contatto , var_dal, var_al);
      FETCH check_contatti INTO v_id_contatto;
      FOUND := check_contatti%FOUND;
      CLOSE check_contatti;
      IF FOUND THEN
        raise_application_error (-20999,
                               si4.get_error('A10090')
--                               'Il contatto esiste gia'' per lo stesso recapito.'
                               );
      END IF;
END;
/* End Functon: CONTA_RECAP_CONTATTI*/




PROCEDURE CHECK_IMPORTANZA_UNIVOCA (var_id_contatto       NUMBER,
                                  var_id_recapito         NUMBER,
                                  var_importanza          NUMBER,
                                  var_id_tipo_contatto    VARCHAR2,
                                  var_dal                 DATE,
                                  var_al                  DATE)
IS
    v_id_contatto contatti.id_contatto%TYPE;
      FOUND boolean;
      --  Controllo se esiste un record con importanza uguale
      CURSOR check_contatti(var_id_contatto NUMBER, var_id_recapito NUMBER, var_importanza varchar2, var_id_tipo_contatto varchar2, var_dal date, var_al date ) IS
      SELECT id_contatto
      FROM   CONTATTI
      WHERE  id_recapito = var_id_recapito
       AND   TIPI_CONTATTO_TPK.GET_TIPO_SPEDIZIONE(id_tipo_contatto) = TIPI_CONTATTO_TPK.GET_TIPO_SPEDIZIONE(var_id_tipo_contatto)
       AND   TIPI_CONTATTO_TPK.GET_TIPO_SPEDIZIONE(id_tipo_contatto) is not null
       AND   TIPI_CONTATTO_TPK.GET_TIPO_SPEDIZIONE(var_id_tipo_contatto) is not null
       AND   trim(upper(importanza))  = trim(upper(var_importanza))
       -- rev. 2 inizio
       AND   dal <= nvl(var_al, to_date('3333333','j'))
       AND   nvl(al, to_date('3333333','j')) >= var_dal
       -- rev. 2 fine
       AND   var_importanza IS NOT NULL
       AND   id_contatto != var_id_contatto;
 BEGIN  -- Check REFERENTIAL Integrity
      OPEN  check_contatti(var_id_contatto, var_id_recapito , var_importanza ,  var_id_tipo_contatto , var_dal, var_al);
      FETCH check_contatti INTO v_id_contatto;
      FOUND := check_contatti%FOUND;
      CLOSE check_contatti;
      IF FOUND THEN
        raise_application_error (-20999,
                               si4.get_error('A10092') ||'(contatti)'
--                               'Impossibille inserire più record con uguale IMPORTANZA.'
                               );
      END IF;
END     CHECK_IMPORTANZA_UNIVOCA;

procedure allinea_inte
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
begin
    d_id_recapito := ANAGRAFE_SOGGETTI_WS_PKG.GET_ID_RECAPITO_RES(p_ni_as4, trunc(sysdate));
    dbms_output.put_line('Recapito: '||d_id_recapito);
    d_ref_cursor := contatti_tpk.get_rows( P_ID_RECAPITO => d_id_recapito, p_id_tipo_contatto=> p_id_tipo_contatto, p_other_condition => ' and upper(valore) = upper('''||p_old_indirizzo||''') and trunc(sysdate) between dal and nvl(al,to_date(3333333,''j'')) ');
    fetch d_ref_cursor into contatto_row;
    dbms_output.put_line('contatto da aggiornare '||contatto_row.id_contatto);
    if contatto_row.id_contatto is not null then -- contatto già codificato
        -- devo chiudere il precedente
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
    contatti_tpk.ins( p_id_recapito  => d_id_recapito
                    , p_dal  => trunc(sysdate)
                    , p_valore  => p_indirizzo
                    , p_id_tipo_contatto  => p_id_tipo_contatto
                    , p_competenza  => 'SI4SO'
                    , p_competenza_esclusiva  => null
                    , p_utente_aggiornamento  => p_utente_agg
                    , p_data_aggiornamento => sysdate
                    );
    -- rev. 005 inizio
    if d_ref_cursor%ISOPEN THEN
    close d_ref_cursor;
    end if;
exception
when others then
    if d_ref_cursor%ISOPEN THEN
    close d_ref_cursor;
    end if;
    raise;
    -- rev. 005 fine
end;

 FUNCTION ESTRAI_STORICO
    ( P_NI IN NUMBER)
    RETURN CLOB
     IS
        d_tree_storico  clob := empty_clob();
        d_amount     BINARY_INTEGER := 32767;
        d_char       VARCHAR2(32767);
        d_xml        VARCHAR2(32767);
        d_new_valore            contatti_STORICO.valore%type;
        D_NEW_AL                contatti_STORICO.AL%TYPE;
        D_NEW_id_tipo_contatto  contatti_STORICO.id_tipo_contatto%TYPE;
        D_NEW_note              contatti_STORICO.note%TYPE;
        D_NEW_importANZA        recapiti_STORICO.IMPORTANZA%TYPE;
        D_NEW_COMPETENZA        recapiti_STORICO.COMPETENZA%TYPE;
        D_NEW_COMPETENZA_ESCLUSIVA   recapiti_STORICO.COMPETENZA_ESCLUSIVA%TYPE;
        d_utente                contatti_storico.utente_aggiornamento%type;
        D_MODIFICA_OK           NUMBER := 0;
        length_stringa          number;
        d_des_utente_aggiornamento  varchar2(100);
    begin
        dbms_lob.createTemporary(d_tree_storico,TRUE,dbms_lob.CALL);
        D_XML:= '<ROWSET>'||CHR(10);
        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
        for sel_storico_cont in (  select *
                                     from contatti_storico
                                    where id_recapito in (select id_recapito from recapiti where ni = p_ni)
                                      and operazione in ('I','BI','D')
                                  order by id_evento
                                ) loop
            D_MODIFICA_OK   := 0;
            if sel_storico_cont.operazione = 'I' then --nuovi inserimenti
                d_utente := nvl(sel_storico_cont.utente_aggiornamento,sel_storico_cont.utente_agg); -- se non è tracciato l'utente dell'operazione prendo quello valorizzato
                d_des_utente_aggiornamento := ad4_soggetto.get_denominazione(ad4_utente.get_soggetto(d_utente,'N',0));
                if d_des_utente_aggiornamento is not null then
                    d_des_utente_aggiornamento := nvl(ad4_utente.get_nominativo(d_utente,'N',0),d_utente)||' - '||d_des_utente_aggiornamento;
                else
                    d_des_utente_aggiornamento := nvl(ad4_utente.get_nominativo(d_utente,'N',0),d_utente);
                end if;
                D_XML:= '<ROW><LABEL_PARTE1>Contatto '||TIPI_CONTATTO_TPK.GET_DESCRIZIONE(sel_storico_cont.ID_TIPO_CONTATTO)||' su recapito '||TIPI_RECAPITO_TPK.GET_DESCRIZIONE(recapiti_tpk.get_id_tipo_recapito(sel_storico_cont.id_RECAPITO))||' con decorrenza '||TO_CHAR(sel_storico_cont.dal,'DD/MM/YYYY')||' inserito da '||d_des_utente_aggiornamento||' il '||TO_CHAR(sel_storico_cont.data,'DD/MM/YYYY hh24:MI:SS')||'</LABEL_PARTE1>'||CHR(10)||'<ROWSET>'||CHR(10);
                dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                if sel_storico_cont.al is not null then
                       D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>AL</LABEL_PARTE1><LABEL_PARTE3>'||to_char(sel_storico_cont.al,'dd/mm/yyyy')||'</LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                end if;
                if sel_storico_cont.valore is not null then
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>VALORE</LABEL_PARTE1><LABEL_PARTE3>'||sel_storico_cont.VALORE||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                end if;
-- già specificato in testata
--                if sel_storico_cont.ID_TIPO_CONTATTO is not null then
--                        D_XML:= '<ROW><ICONA>add.png</ICONA><ATTRIBUTO>TIPO CONTATTO</ATTRIBUTO><VALORE>'||sel_storico_cont.ID_TIPO_CONTATTO||'</VALORE></ROW>'||CHR(10);
--                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
--                end if;
                if sel_storico_cont.NOTE is not null then
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>NOTE</LABEL_PARTE1><LABEL_PARTE3>'||sel_storico_cont.NOTE||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                end if;
                if sel_storico_cont.IMPORTANZA is not null then
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>IMPORTANZA</LABEL_PARTE1><LABEL_PARTE3>'||sel_storico_cont.IMPORTANZA||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                end if;
                if sel_storico_cont.COMPETENZA is not null then
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COMPETENZA</LABEL_PARTE1><LABEL_PARTE3>'||sel_storico_cont.COMPETENZA||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                end if;
                if sel_storico_cont.COMPETENZA_ESCLUSIVA is not null then
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COMPETENZA ESCLUSIVA</LABEL_PARTE1><LABEL_PARTE3>'||sel_storico_cont.COMPETENZA_ESCLUSIVA||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                end if;
                D_XML:= '</ROWSET></ROW>'||CHR(10);
                dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
            elsif sel_storico_cont.operazione = 'BI' then --modifica del record
                SELECT al, VALORE, ID_TIPO_CONTATTO, NOTE, IMPORTANZA, COMPETENZA, COMPETENZA_ESCLUSIVA , utente_agg
                  INTO  D_NEW_AL,
                        D_NEW_VALORE, D_NEW_id_tipo_CONTATTO, D_NEW_NOTE,
                        D_NEW_IMPORTANZA ,
                        D_NEW_COMPETENZA  ,
                        D_NEW_COMPETENZA_ESCLUSIVA ,
                        d_utente
                  FROM CONTATTI_STORICO
                 WHERE BI_RIFERIMENTO = sel_storico_cont.ID_EVENTO
                   AND OPERAZIONE = 'AI'
-- controllo che almeno uno degli attributi da valutare siano cambiati
--                   and  ( NVL(sel_storico_cont.al,TO_DATE(3333333,'J')) != NVL(AL,TO_DATE(3333333,'J')) or
--                          NVL(sel_storico_cont.valore,'x') != NVL(valore,'x') or
--                          NVL(sel_storico_cont.NOTE,'xXXx') != NVL(NOTE,'xXXx') or
--                          NVL(sel_storico_cont.IMPORTANZA,-1) != NVL(iMPORTANZA,-1) or
--                          NVL(sel_storico_cont.COMPETENZA,'xxxxxxxxxxx') != NVL(COMPETENZA,'xxxxxxxxxxx') or
--                          NVL(sel_storico_cont.COMPETENZA_ESCLUSIVA,'xx') != NVL(COMPETENZA_ESCLUSIVA,'xx')
--                        )

                     ;
                d_des_utente_aggiornamento := ad4_soggetto.get_denominazione(ad4_utente.get_soggetto(d_utente,'N',0));
                if d_des_utente_aggiornamento is not null then
                    d_des_utente_aggiornamento := nvl(ad4_utente.get_nominativo(d_utente,'N',0),d_utente)||' - '||d_des_utente_aggiornamento;
                else
                    d_des_utente_aggiornamento := nvl(ad4_utente.get_nominativo(d_utente,'N',0),d_utente);
                end if;
                D_XML:= '<ROW><LABEL_PARTE1>Contatto '||TIPI_CONTATTO_TPK.GET_DESCRIZIONE(sel_storico_cont.ID_TIPO_CONTATTO)||' su recapito '||TIPI_RECAPITO_TPK.GET_DESCRIZIONE(recapiti_tpk.get_id_tipo_recapito(sel_storico_cont.id_RECAPITO))||' con decorrenza '||TO_CHAR(sel_storico_cont.dal,'DD/MM/YYYY')||' aggiornato da '||d_des_utente_aggiornamento||' il '||TO_CHAR(sel_storico_cont.data,'DD/MM/YYYY hh24:MI:SS')||'</LABEL_PARTE1>'||CHR(10)||'<ROWSET>'||CHR(10);
                length_stringa := length(d_xml);
                dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                if NVL(sel_storico_cont.al,TO_DATE(3333333,'J')) != NVL(D_NEW_AL,TO_DATE(3333333,'J')) THEN -- MODIFICATO AL
                    D_MODIFICA_OK := 1;
                    IF sel_storico_cont.AL IS NULL AND D_NEW_AL IS NOT NULL THEN
                       D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>AL</LABEL_PARTE1><LABEL_PARTE3>'||to_char(D_NEW_AL,'dd/mm/yyyy')||'</LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSIF sel_storico_cont.AL IS NOT NULL AND D_NEW_AL IS NULL THEN
                       D_XML:= '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>AL</LABEL_PARTE1><LABEL_PARTE2>'||to_char(sel_storico_cont.AL,'dd/mm/yyyy')||'</LABEL_PARTE2></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSE
                       D_XML:= '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>AL</LABEL_PARTE1><LABEL_PARTE2><![CDATA['||to_char(sel_storico_cont.AL,'dd/mm/yyyy')||']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['||to_char(d_new_AL,'dd/mm/yyyy')||']]></LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    END IF;
                END IF;
                if NVL(sel_storico_cont.valore,'x') != NVL(D_NEW_valore,'x') THEN -- MODIFICATO AL
                    D_MODIFICA_OK := 1;
                    IF sel_storico_cont.VALORE IS NULL AND D_NEW_VALORE IS NOT NULL THEN
                       D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>LABEL_PARTE2</LABEL_PARTE1><LABEL_PARTE3>'||D_NEW_VALORE||'</LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSIF sel_storico_cont.VALORE IS NOT NULL AND D_NEW_VALORE IS NULL THEN
                       D_XML:= '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>LABEL_PARTE2</LABEL_PARTE1><LABEL_PARTE2>'||sel_storico_cont.VALORE ||'</LABEL_PARTE2></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSE
                       D_XML:= '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>LABEL_PARTE2</LABEL_PARTE1><LABEL_PARTE2><![CDATA['||sel_storico_cont.VALORE||']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['||d_new_VALORE||']]></LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    END IF;
                END IF;
-- la tipologia di contatto non può essere modificata!!!!!
--                if NVL(sel_storico_cont.ID_TIPO_CONTATTO,-1) != NVL(D_NEW_ID_TIPO_CONTATTO,-1) THEN -- MODIFICATO AL
--                    IF sel_storico_cont.ID_TIPO_CONTATTO IS NULL AND D_NEW_ID_TIPO_CONTATTO IS NOT NULL THEN
--                       D_XML:= '<ROW><ICONA>add.png</ICONA><ATTRIBUTO>TIPO CONTATTO</ATTRIBUTO><LABEL_PARTE2>'||D_NEW_ID_TIPO_CONTATTO||'</LABEL_PARTE2></ROW>'||CHR(10);
--                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
--                    ELSIF sel_storico_cont.ID_TIPO_CONTATTO IS NOT NULL AND D_NEW_ID_TIPO_CONTATTO IS NULL THEN
--                       D_XML:= '<ROW><ICONA>delete.png</ICONA><ATTRIBUTO>TIPO CONTATTO</ATTRIBUTO><LABEL_PARTE2>'||sel_storico_cont.ID_TIPO_CONTATTO ||'</LABEL_PARTE2></ROW>'||CHR(10);
--                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
--                    ELSE
--                       D_XML:= '<ROW><ICONA>edit.png</ICONA><ATTRIBUTO>TIPO CONTATTO</ATTRIBUTO><LABEL_PARTE2><![CDATA['||sel_storico_cont.ID_TIPO_CONTATTO||' => '||d_new_ID_TIPO_CONTATTO||']]></LABEL_PARTE2></ROW>'||CHR(10);
--                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
--                    END IF;
--                END IF;
                if NVL(sel_storico_cont.NOTE,'xXXx') != NVL(D_NEW_NOTE,'xXXx') THEN -- MODIFICATO AL
                    D_MODIFICA_OK := 1;
                    IF sel_storico_cont.NOTE IS NULL AND D_NEW_NOTE IS NOT NULL THEN
                       D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>NOTE</LABEL_PARTE1><LABEL_PARTE3>'||D_NEW_NOTE||'</LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSIF sel_storico_cont.NOTE IS NOT NULL AND D_NEW_NOTE IS NULL THEN
                       D_XML:= '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>NOTE</LABEL_PARTE1><LABEL_PARTE2>'||sel_storico_cont.NOTE ||'</LABEL_PARTE2></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSE
                       D_XML:= '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>NOTE</LABEL_PARTE1><LABEL_PARTE2><![CDATA['||sel_storico_cont.NOTE||']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['||d_new_NOTE||']]></LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    END IF;
                END IF;
                if NVL(sel_storico_cont.IMPORTANZA,-1) != NVL(D_NEW_IMPORTANZA,-1) THEN -- MODIFICATO importanza
                    D_MODIFICA_OK := 1;
                    IF sel_storico_cont.IMPORTANZA IS NULL AND D_NEW_IMPORTANZA IS NOT NULL THEN
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>IMPORTANZA</LABEL_PARTE1><LABEL_PARTE3>'||D_NEW_IMPORTANZA||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSIF sel_storico_cont.IMPORTANZA IS NOT NULL AND D_NEW_IMPORTANZA IS NULL THEN
                        D_XML:= '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>IMPORTANZA</LABEL_PARTE1><LABEL_PARTE2>'||sel_storico_cont.IMPORTANZA||'</LABEL_PARTE2></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSE
                       D_XML:= '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>IMPORTANZA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['||sel_storico_cont.IMPORTANZA||']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['||d_new_IMPORTANZA||']]></LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    END IF;
                END IF;
                if NVL(sel_storico_cont.COMPETENZA,'xxxxxxxxxxx') != NVL(D_NEW_COMPETENZA,'xxxxxxxxxxx') THEN -- MODIFICATO competenza
                    D_MODIFICA_OK := 1;
                    IF sel_storico_cont.COMPETENZA IS NULL AND D_NEW_COMPETENZA IS NOT NULL THEN
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COMPETENZA</LABEL_PARTE1><LABEL_PARTE3>'||D_NEW_COMPETENZA||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSIF sel_storico_cont.COMPETENZA IS NOT NULL AND D_NEW_COMPETENZA IS NULL THEN
                        D_XML:= '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>COMPETENZA</LABEL_PARTE1><LABEL_PARTE2>'||sel_storico_cont.COMPETENZA||'</LABEL_PARTE2></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSE
                       D_XML:= '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>COMPETENZA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['||sel_storico_cont.COMPETENZA||']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['||d_new_COMPETENZA||']]></LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    END IF;
                END IF;
                if NVL(sel_storico_cont.COMPETENZA_ESCLUSIVA,'xx') != NVL(D_NEW_COMPETENZA_ESCLUSIVA,'xx') THEN -- MODIFICATO competenza esclusiva
                    D_MODIFICA_OK := 1;
                    IF sel_storico_cont.COMPETENZA_ESCLUSIVA IS NULL AND D_NEW_COMPETENZA_ESCLUSIVA IS NOT NULL THEN
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COMPETENZA ESCLUSIVA</LABEL_PARTE1><LABEL_PARTE3>'||D_NEW_COMPETENZA_ESCLUSIVA||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSIF sel_storico_cont.COMPETENZA_ESCLUSIVA IS NOT NULL AND D_NEW_COMPETENZA_ESCLUSIVA IS NULL THEN
                        D_XML:= '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>COMPETENZA ESCLUSIVA</LABEL_PARTE1><LABEL_PARTE2>'||sel_storico_cont.COMPETENZA_esclusiva||'</LABEL_PARTE2></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSE
                       D_XML:= '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>COMPETENZA ESCLUSIVA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['||sel_storico_cont.COMPETENZA_esclusiva||']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['||d_new_COMPETENZA_esclusiva||']]></LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    END IF;
                END IF;
                if d_modifica_ok = 1 then
                    D_XML:= '</ROWSET></ROW>'||CHR(10);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                else
                     D_TREE_STORICO := dbms_lob.substr(d_tree_storico,dbms_lob.getlength(d_tree_storico)-length_stringa);
                end if;
            elsif sel_storico_cont.operazione = 'D' then --modifica del record
                d_utente := nvl(sel_storico_cont.utente_aggiornamento,sel_storico_cont.utente_agg); -- scrivo un utente a caso???? andrebbe tracciato correttamente
                d_des_utente_aggiornamento := ad4_soggetto.get_denominazione(ad4_utente.get_soggetto(d_utente,'N',0));
                if d_des_utente_aggiornamento is not null then
                    d_des_utente_aggiornamento := nvl(ad4_utente.get_nominativo(d_utente,'N',0),d_utente)||' - '||d_des_utente_aggiornamento;
                else
                    d_des_utente_aggiornamento := nvl(ad4_utente.get_nominativo(d_utente,'N',0),d_utente);
                end if;
                D_XML:= '<ROWSET><ROW><LABEL_PARTE1>Contatto '||TIPI_CONTATTO_TPK.GET_DESCRIZIONE(sel_storico_cont.ID_TIPO_CONTATTO)||' su recapito '||TIPI_RECAPITO_TPK.GET_DESCRIZIONE(recapiti_tpk.get_id_tipo_recapito(sel_storico_cont.id_RECAPITO))||' con decorrenza '||TO_CHAR(sel_storico_cont.dal,'DD/MM/YYYY')||' eliminato da '||d_des_utente_aggiornamento||' il '||TO_CHAR(sel_storico_cont.data,'DD/MM/YYYY hh24:MI:SS')||'</LABEL_PARTE1></ROW></ROWSET>'||CHR(10);
                dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
            end if;
        end loop;
        D_XML:= '</ROWSET>'||CHR(10);
        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
        RETURN    d_tree_storico;
    end;



END;
/

