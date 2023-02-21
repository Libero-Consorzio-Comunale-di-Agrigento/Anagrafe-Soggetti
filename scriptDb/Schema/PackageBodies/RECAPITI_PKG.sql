CREATE OR REPLACE PACKAGE BODY recapiti_pkg
/******************************************************************************
 NOME:        recapiti_pkg
 DESCRIZIONE: Gestione tabella RECAPITI.
 ANNOTAZIONI: .
 REVISIONI:   .
 Rev.  Data        Autore  Descrizione.
 001   11/09/2018  SN      Sistemazione verifica importanza
 002   12/09/2018  SN      Modificata query x recupero contatti
 003   30/04/2019  SNeg   Comune e Provincia entrambi valorizzati o nulli Bug #34514
 004   17/09/2019  SNeg   RRI togliere nvl in verifica di periodo già chiuso con competenza P Bug #36936
******************************************************************************/
is
    s_revisione_body      constant AFC.t_revision := '004 - 17/09/2019';
   s_error_table AFC_Error.t_error_table;
   s_error_detail AFC_Error.t_error_table;
   s_warning afc.t_statement;
   d_warning_num integer;
   d_warning_msg afc.t_statement;
   d_warning     afc.t_statement;
   i integer := 1;
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
function error_message
( p_error_number  in AFC_Error.t_error_number
) return AFC_Error.t_error_msg is
/******************************************************************************
 NOME:        error_message
 DESCRIZIONE: Messaggio previsto per il numero di eccezione indicato.
 NOTE:        Restituisce il messaggio abbinato al numero indicato nella tabella
              s_error_table del Package. Se p_error_number non e presente nella
              tabella s_error_table viene lanciata l'exception -20011 (vedi AFC_Error)
******************************************************************************/
   d_result AFC_Error.t_error_msg;
   d_detail AFC_Error.t_error_msg;
begin
   if s_error_detail.exists( p_error_number )
   then
      d_detail := s_error_detail( p_error_number );
   end if;
   if s_error_table.exists( p_error_number )
   then
      d_result := s_error_table( p_error_number ) || d_detail;
      s_error_detail( p_error_number ) := '';
   else
      raise_application_error( AFC_Error.exception_not_in_table_number
                             , AFC_Error.exception_not_in_table_msg
                             );
   end if;
   return  d_result;
end error_message; -- anagrafici_pkg.error_message
--------------------------------------------------------------------------------
PROCEDURE recupera_contatti (
   p_old_id_recapito recapiti.id_recapito%TYPE,
   p_new_id_recapito recapiti.id_recapito%TYPE,
   p_dal             recapiti.dal%TYPE,
   p_al              recapiti.al%TYPE )
IS
v_nuovo_dal date;
BEGIN
   -- devo farlo solo se periodo aperto con al NULLO solo in INSERIMENTO
   -- cerco se esisono
   FOR v_contatto
      IN (SELECT *
            FROM contatti r
           WHERE id_recapito = p_old_id_recapito
           -- Rev.2 inizio
             AND dal <= nvl(p_al, to_date('3333333','j'))
             AND nvl(al, to_date('3333333','j')) >= p_dal
             -- Rev. 2 fine
                 -- mod Stefania
                 AND NOT EXISTS
                        (SELECT 1
                           FROM contatti c
                          WHERE p_new_id_recapito = c.id_recapito
                          and  c.id_tipo_contatto = r.id_tipo_contatto
                                AND c.dal = p_dal))
   LOOP
      if v_contatto.dal < p_dal then
        v_nuovo_dal := p_dal;
      elsif v_contatto.dal >= p_dal then
        v_nuovo_dal := v_contatto.dal;
      end if;
      -- ricopio
      contatti_tpk.ins (
         p_id_contatto            => NULL,
         p_id_recapito            => p_new_id_recapito,
         p_dal                    => v_nuovo_dal, --v_contatto.dal,
         p_al                     => v_contatto.al,
         p_valore                 => v_contatto.valore,
         p_id_tipo_contatto       => v_contatto.id_tipo_contatto,
         p_note                   => v_contatto.note,
         p_importanza             => v_contatto.importanza,
         p_competenza             => v_contatto.competenza,
         p_competenza_esclusiva   => v_contatto.competenza_esclusiva,
         p_version                => v_contatto.version,
         p_utente_aggiornamento   => v_contatto.utente_aggiornamento,
         p_data_aggiornamento     => v_contatto.data_aggiornamento);
   END LOOP;
END;
--------------------------------------------------------------------------------
PROCEDURE RECAPITI_RRI
/******************************************************************************
 NOME:        RECAPITI_RRI
 DESCRIZIONE: Gestisce la storicizzazione dei dati di un soggetto:
              - aggiorna la data di fine validita' dell'ultima registrazione
                storica.
 ARGOMENTI:   p_ni  IN number Numero Individuale del soggetto.
              p_dal IN date   Data di inizio validita' del soggetto.
 ECCEZIONI:
 ANNOTAZIONI: la procedure viene lanciata in Post Event dal trigger
              RECAPITI_TIU in seguito all'inserimento di un nuovo
              record.
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 0    09/05/2017 SNeg    Prima emissione
 1    13/02/2018 SN     Controlli non effettuati in trasco
 4   17/09/2019  SNeg   RRI togliere nvl in verifica di periodo già chiuso con competenza P
******************************************************************************/
(p_ni                     IN NUMBER,
 p_dal                    IN DATE,
 p_al                     IN DATE,
 p_competenza             IN VARCHAR2,
 p_competenza_esclusiva   IN VARCHAR2,
 p_id_recapito            IN NUMBER, -- nuovo id che ho appena inserito
 p_ID_TIPO_RECAPITO          NUMBER)
IS
   dDalStorico            DATE;
   d_al                   DATE;
   dCompetenza            VARCHAR2 (100);
   dCompetenzaEsclusiva   VARCHAR2 (10);
   d_result               AFC_Error.t_error_number;
    errno            INTEGER;
    errmsg           CHAR (200);
    v_num_recapiti   NUMBER;
    integrity_error   EXCEPTION;
    dIdRecapitoStorico recapiti.id_recapito%TYPE;
BEGIN
if nvl(anagrafici_pkg.trasco,0) != 1 then -- NON  sono in trasco faccio i controlli
   SELECT MAX (al) -- rev. 4
     INTO d_al
     FROM RECAPITI
    WHERE     ni = p_ni
          AND p_dal BETWEEN dal AND NVL (al, TRUNC (SYSDATE))
          AND SUBSTR (NVL (competenza, 'xxx'), 1, 2) <>
                 SUBSTR (NVL (p_competenza, 'xxx'), 1, 2)
          AND competenza_esclusiva = 'P'
          AND id_tipo_recapito = p_id_tipo_recapito;
   IF d_al IS NOT NULL
   THEN
      RAISE_APPLICATION_ERROR (
         -20999,
            si4.get_error('A10046') || ' precedenti al '
         || TO_CHAR (d_al, 'dd/mm/yyyy')
         || ' di competenza parziale di altro progetto.');
   END IF;
   -- Cerca eventuali Registrazioni storiche.
   BEGIN
      SELECT dal, competenza, competenza_esclusiva, id_recapito
        INTO dDalStorico, dCompetenza, dCompetenzaEsclusiva, dIdRecapitoStorico
        FROM RECAPITI
       WHERE     ni = p_ni
             AND id_tipo_recapito = p_id_tipo_recapito
             AND upper(tipi_recapito_tpk.get_unico(p_id_tipo_recapito))!= 'NO' -- è unico
             -- solo se è  UNICO devo chiudere il precedente
             -- devo prevedere una voce di registro??
             AND dal =
                    (SELECT MAX (dal)
                       FROM RECAPITI
                      WHERE     ni = p_ni
                            AND dal < p_dal
                            AND id_tipo_recapito = p_id_tipo_recapito
                            AND al IS NULL -- posso sistemare solo periodi aperti
                                          )
             AND al is null;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         dDalStorico := TO_DATE ('27/02/0001', 'dd/mm/yyyy');
      WHEN OTHERS
      THEN
         RAISE_APPLICATION_ERROR (
            -20999,
             si4.get_error('10068') --  'Recupero data di inizio validita'' della registrazione storica.'
            || CHR (10)
            || SUBSTR (SQLERRM, 5));
   END;
   -- Se esistono Registrazioni storiche.
   IF dDalStorico <> TO_DATE ('27/02/0001', 'dd/mm/yyyy')
   THEN
      -- Rev.3 del 01/09/2009 MM: gestione competenza esclusiva del record da storicizzare.
      -- Rev.4 del 13/12/2011 SNeg: controllo anche se non competenza esclusiva = E
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
      -- per stessi ni e dal.
      BEGIN
         FOR c_ref IN (SELECT oggetto, motivo_blocco
                         FROM xx4_recapiti
                        WHERE ni = p_ni AND dal = ddalstorico)
         LOOP
            IF c_ref.motivo_blocco = 'D'
            THEN
               raise_application_error (
                  -20999,
                     si4.get_error('A10046') || ' Esistono riferimenti su Recapiti ('
                  || c_ref.oggetto
                  || '). La registrazione non e'' modificabile (motivo blocco: '
                  || c_ref.motivo_blocco
                  || ').');
            END IF;
         END LOOP;
      END;
       -- Aggiornamento storico recapito
      BEGIN
        recapiti_pkg.recupera_contatti (  dIdRecapitoStorico,p_id_recapito ,  p_dal, p_al );
--         raise_application_error (-20999, 'recapito=' || dIdRecapitoStorico || ' NEW al=' || p_dal--|| ' ni=' || p_ni
--          || ' dalstorico=' || to_char(dDalStorico,'dd/mm/yyyy'));
--         raise_application_error (-20999, 'recapito=' || dIdRecapitoStorico || ' NEW al=' || p_dal|| ' ni=' || p_ni
--          || ' dalstorico=' || to_char(dDalStorico,'dd/mm/yyyy'));
         UPDATE RECAPITI
            SET al = p_dal - 1
          WHERE ni = p_ni
            AND dal = dDalStorico
            and id_recapito = dIdRecapitoStorico;
      EXCEPTION
         WHEN OTHERS
         THEN
            RAISE_APPLICATION_ERROR (
               -20999,
                  si4.get_error('A10069') --'Aggiornamento data di fine validita'' della registrazione storica.'
               || CHR (10)
               || SUBSTR (SQLERRM, 5));
      END;
   END IF;
   -- quando dovrebbe essere tutto OK
   -- CONTROLLARE x RECAPITI UNICI che non ci sia già presente un record
   IF tipi_recapito_tpk.get_unico (p_ID_TIPO_RECAPITO) = 'SI'
   THEN
      BEGIN                    -- Check UNIQUE Integrity on PK of "ANAGRAFICI"
         SELECT COUNT (*)
           INTO v_num_recapiti
           FROM recapiti
          WHERE ni = p_ni
            AND id_tipo_recapito = p_id_tipo_recapito
            and dal = p_dal
            AND AL IS NULL;
         IF v_num_recapiti > 1
         THEN
            errno := -20007;
            errmsg := si4.get_error('A10047')
               || ' (ni= "'
               || p_ni ||')';
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
/* End Procedure: RECAPITI_RRI */
PROCEDURE RECAPITI_PU
/******************************************************************************
 NOME:        RECAPITI_PU
 DESCRIZIONE: Procedure for Check REFERENTIAL Integrity
                         at UPDATE on Table RECAPITI
 ARGOMENTI:   Rigenerati in automatico.
 ECCEZIONI:  -20001, Informazione COLONNA non modificabile
             -20003, Non esiste riferimento su PARENT TABLE
             -20004, Identificazione di TABLE non modificabile
             -20005, Esistono riferimenti su CHILD TABLE
 ANNOTAZIONI: Richiamata da Trigger RECAPITI_TIU
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
                        Prima Emissione
******************************************************************************/
(  old_ID_RECAPITO IN NUMBER
 , old_NI in NUMBER
 , old_DAL in DATE
 , old_provincia IN NUMBER
 , old_comune IN NUMBER
 , old_tipo_recapito in NUMBER
 , new_ID_RECAPITO IN NUMBER
 , new_ni IN NUMBER
 , new_dal IN DATE
 , new_provincia IN NUMBER
 , new_comune IN NUMBER
 , new_tipo_recapito in NUMBER
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
   d_result AFC_Error.t_error_number := afc_error.ok;
   PRAGMA EXCEPTION_INIT(mutating, -4091);
   --  Dichiarazione UpdateChildParentExist constraint per la tabella "AD4_COMUNI"
   CURSOR cpk1_comune(var_provincia NUMBER,
                   var_comune NUMBER) IS
      SELECT 1
      FROM   AD4_COMUNI
      WHERE  PROVINCIA_STATO = var_provincia
       AND   COMUNE = var_comune
       AND   var_provincia IS NOT NULL
       AND   var_provincia > 0
       AND  var_provincia != -999 -- valore usato dal WS in caso di decodifica non trovata
       AND  var_comune != -999-- valore usato dal WS in caso di decodifica non trovata
       AND   var_comune IS NOT NULL;
   --  Dichiarazione UpdateChildParentExist constraint per la tabella "ANAGRAFICI"
   CURSOR cpk1_anagrafici(var_NI VARCHAR) IS
      SELECT 1
      FROM   ANAGRAFICI
      WHERE  NI = var_NI
       AND   var_NI IS NOT NULL;
   --  Dichiarazione UpdateChildParentExist constraint per la tabella "TIPI_RECAPITO"
   CURSOR cpk3_recapiti(var_id_tipo_recapito VARCHAR) IS
      SELECT 1
      FROM   TIPI_RECAPITO
      WHERE  id_TIPO_RECAPITO = var_id_tipo_recapito;
   --  Declaration of UpdateParentRestrict constraint for "XX4_RECAPITI"
   cursor cfk1_RECAPITI(var_id_recapito number) is
      select oggetto, motivo_blocco
      from   XX4_RECAPITI
      where  id_recapito = var_id_recapito
       and   var_id_recapito is not null;
     --  Dichiarazione UpdateChildParentExist constraint per la tabella "AD4_PROVINCE"
   CURSOR cpk4_provincia(var_provincia NUMBER) IS
      SELECT 1
      FROM   AD4_province
      WHERE  PROVINCIA = var_provincia
       AND   var_provincia IS NOT NULL;
BEGIN
   BEGIN  -- Check REFERENTIAL Integrity
      --  Chiave di "RECAPITI" non modificabile se esistono referenze su "XX4_RECAPITI"
      OPEN  cfk1_RECAPITI(OLD_ID_RECAPITO);
      FETCH cfk1_RECAPITI INTO oggetto, motivo_blocco;
      FOUND := cfk1_RECAPITI%FOUND;
      CLOSE cfk1_RECAPITI;
      IF FOUND THEN
         IF (OLD_ID_RECAPITO != NEW_ID_RECAPITO) OR (motivo_blocco = 'R') THEN
          errno  := -20005;
          errmsg := si4.get_error('A10044')  || ' ('||oggetto||')';
          IF motivo_blocco = 'R' THEN
             errmsg := errmsg ||'(motivo blocco: '||motivo_blocco||')';
          END IF;
          RAISE integrity_error;
         END IF;
      END IF;
   END;
   BEGIN
      seq := Integritypackage.GetNestLevel;
      BEGIN  --  Parent "AD4_COMUNI" deve esistere quando si modifica "RECAPITI"
         IF ( NEW_PROVINCIA IS NOT NULL AND --NEW_PROVINCIA > 0 AND -- se codice non trovato da web service viene passato -999
             NEW_COMUNE IS NOT NULL AND ( seq = 0 )
         AND (   (NEW_PROVINCIA != OLD_PROVINCIA OR OLD_PROVINCIA IS NULL)
              OR (NEW_COMUNE != OLD_COMUNE OR OLD_COMUNE IS NULL) ))
              --indicato solo il comune
              -- rev. 3 inizio
--          OR   (new_comune is not null and new_provincia is null)
--              -- indicata solo la provincia
--           OR (new_provincia is not null and new_comune is null
--              and (new_provincia != old_provincia
--                   and (old_comune != new_comune or old_comune is not null))) -- cambiato qualcosa
              -- rev. 3 fine
              THEN
            OPEN  cpk1_comune(NEW_PROVINCIA,
                           NEW_COMUNE);
            FETCH cpk1_comune INTO dummy;
            FOUND := cpk1_comune%FOUND;
            CLOSE cpk1_comune;
            IF NOT FOUND THEN
          errno  := -20003;
          errmsg := si4.get_error('A10021') ;--|| ' La registrazione Recapiti non e'' modificabile.';
          RAISE integrity_error;
            END IF;
            -- rev. 3 inizio
         elsif (NEW_PROVINCIA is not null and NEW_COMUNE is null )
               OR
               (NEW_PROVINCIA is  null and NEW_COMUNE is not null ) then
               errno  := -20003;
               errmsg := si4.get_error('A10041') ;--|| ' Comune e Provincia: entrambi presenti o entrambi vuoti';
               raise integrity_error;
            -- rev. 3 fine
         END IF;
      EXCEPTION
         WHEN MUTATING THEN NULL;  -- Ignora Check su Relazioni Ricorsive
      END;
      BEGIN  --  Parent "AD4_PROVINCE" deve esistere quando si modifica "RECAPITI"
         IF ( NEW_PROVINCIA IS NOT NULL AND --NEW_PROVINCIA > 0 AND -- se codice non trovato da web service viene passato -999
             NEW_COMUNE IS  NULL)      THEN -- comune non passato
            OPEN  cpk4_provincia(NEW_PROVINCIA);
            FETCH cpk4_provincia INTO dummy;
            FOUND := cpk4_provincia%FOUND;
            CLOSE cpk4_provincia;
            IF NOT FOUND THEN
          errno  := -20003;
          errmsg := si4.get_error('A10091');-- || ' La registrazione non puo'' essere inserita.';
          RAISE integrity_error;
            END IF;
         END IF;
      EXCEPTION
         WHEN MUTATING THEN NULL;  -- Ignora Check su Relazioni Ricorsive
      END;
      if  new_id_recapito != old_id_recapito then
         raise_application_error(-20999,si4.get_error('A10045') );
      end if;
      BEGIN  --  Parent "TIPI_RECAPITO" deve esistere quando si modifica "RECAPITI"
          IF NEW_TIPO_RECAPITO IS NOT NULL AND ( seq = 0 )
         AND (   (NEW_TIPO_RECAPITO != OLD_TIPO_RECAPITO OR OLD_TIPO_RECAPITO IS NULL) ) THEN
            OPEN  cpk3_recapiti(NEW_TIPO_RECAPITO);
            FETCH cpk3_recapiti INTO dummy;
            FOUND := cpk3_recapiti%FOUND;
            CLOSE cpk3_recapiti;
            IF NOT FOUND THEN
          errno  := -20003;
          errmsg := si4.get_error('A10042') ;
          RAISE integrity_error;
            END IF;
         END IF;
      EXCEPTION
         WHEN MUTATING THEN NULL;  -- Ignora Check su Relazioni Ricorsive
      END;
      BEGIN  --  Parent "NI" deve esistere quando si modifica "RECAPITI"
          IF NEW_NI IS NOT NULL AND ( seq = 0 )
         AND (   (NEW_NI != OLD_NI OR OLD_NI IS NULL) ) THEN
            OPEN  cpk1_anagrafici(NEW_NI);
            FETCH cpk1_anagrafici INTO dummy;
            FOUND := cpk1_anagrafici%FOUND;
            CLOSE cpk1_anagrafici;
            IF NOT FOUND THEN
          errno  := -20003;
          errmsg := si4.get_error('A10051' );-- ||'ni=' || new_ni ;--|| ' La registrazione Recapiti non e'' modificabile.';
          RAISE integrity_error;
            END IF;
         END IF;
      EXCEPTION
         WHEN MUTATING THEN NULL;  -- Ignora Check su Relazioni Ricorsive
      END;
      NULL;
   END;
EXCEPTION
   WHEN integrity_error THEN
        Integritypackage.InitNestLevel;
        RAISE_APPLICATION_ERROR(errno, errmsg);
   WHEN OTHERS THEN
        Integritypackage.InitNestLevel;
        RAISE;
END;
/* PROCEDURE RECAPITI_PU*/
PROCEDURE RECAPITI_PI
/******************************************************************************
 NOME:        RECAPITI_PI
 DESCRIZIONE: Procedure for Check REFERENTIAL Integrity
                         at INSERT on Table RECAPITI
 ARGOMENTI:   Rigenerati in automatico.
 ECCEZIONI:  -20001, Informazione COLONNA non modificabile
             -20003, Non esiste riferimento su PARENT TABLE
             -20004, Identificazione di TABLE non modificabile
             -20005, Esistono riferimenti su CHILD TABLE
 ANNOTAZIONI: Richiamata da Trigger RECAPITI_TIU
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
                        Prima Emissione
 1    13/02/2018 SN     Controlli non effettuati in trasco
 003  30/04/2019 SNeg   Comune e Provincia entrambi valorizzati o nulli Bug #34514
******************************************************************************/
(  new_ni IN NUMBER
 , new_dal IN DATE
 , new_provincia IN NUMBER
 , new_comune IN NUMBER
 , new_tipo_recapito in NUMBER
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
   d_result AFC_Error.t_error_number := afc_error.ok;
   PRAGMA EXCEPTION_INIT(mutating, -4091);
   --  Dichiarazione UpdateChildParentExist constraint per la tabella "AD4_COMUNI"
   CURSOR cpk1_comune(var_provincia NUMBER,
                   var_comune NUMBER) IS
      SELECT 1
      FROM   AD4_COMUNI
      WHERE  PROVINCIA_STATO = var_provincia
       AND   COMUNE = var_comune
       AND   var_provincia IS NOT NULL
       AND   var_provincia > 0
       AND  var_provincia != -999 -- valore usato dal WS in caso di decodifica non trovata
       AND  var_comune != -999 -- valore usato dal WS in caso di decodifica non trovata
       AND   var_comune IS NOT NULL;
   --  Dichiarazione UpdateChildParentExist constraint per la tabella "ANAGRAFICI"
   CURSOR cpk1_anagrafici(var_NI VARCHAR) IS
      SELECT 1
      FROM   ANAGRAFICI
      WHERE  NI = var_NI
       AND   var_NI IS NOT NULL;
   --  Dichiarazione UpdateChildParentExist constraint per la tabella "TIPI_RECAPITO"
   CURSOR cpk3_tipi_recapito(var_id_tipo_recapito VARCHAR) IS
      SELECT 1
      FROM   TIPI_RECAPITO
      WHERE  id_TIPO_RECAPITO = var_id_tipo_recapito
       AND   var_id_tipo_recapito IS NOT NULL;
     --  Dichiarazione UpdateChildParentExist constraint per la tabella "AD4_PROVINCE"
   CURSOR cpk4_provincia(var_provincia NUMBER) IS
      SELECT 1
      FROM   AD4_province
      WHERE  PROVINCIA = var_provincia
       AND   var_provincia IS NOT NULL;
BEGIN
if nvl(anagrafici_pkg.trasco,0) != 1  then -- NON sono in trasco faccio i controlli
   BEGIN
      seq := Integritypackage.GetNestLevel;
      BEGIN  --  Parent "AD4_COMUNI" deve esistere quando si modifica "RECAPITI"
         IF ( NEW_PROVINCIA IS NOT NULL AND --NEW_PROVINCIA > 0 AND -- se codice non trovato da web service viene passato -999
             NEW_COMUNE IS NOT NULL)
             -- rev. 3 or (new_comune is not null and new_provincia is null) -- posso passare solo il comune
             THEN
            OPEN  cpk1_comune(NEW_PROVINCIA,
                           NEW_COMUNE);
            FETCH cpk1_comune INTO dummy;
            FOUND := cpk1_comune%FOUND;
            CLOSE cpk1_comune;
            IF NOT FOUND THEN
          errno  := -20003;
          errmsg := si4.get_error('A10021');-- || ' La registrazione non puo'' essere inserita.';
          RAISE integrity_error;
            END IF;
            -- rev. 3 inizio
         elsif (NEW_PROVINCIA is not null and NEW_COMUNE is null )
               OR
               (NEW_PROVINCIA is  null and NEW_COMUNE is not null ) then
               errno  := -20003;
               errmsg := si4.get_error('A10041') ;--|| ' Comune e Provincia: entrambi presenti o entrambi vuoti';
               raise integrity_error;
            -- rev. 3 fine
         END IF;
      EXCEPTION
         WHEN MUTATING THEN NULL;  -- Ignora Check su Relazioni Ricorsive
      END;
      -- rev. 3 inizio
--       BEGIN  --  Parent "AD4_PROVINCE" deve esistere quando si modifica "RECAPITI"
--         IF ( NEW_PROVINCIA IS NOT NULL AND --NEW_PROVINCIA > 0 AND -- se codice non trovato da web service viene passato -999
--             NEW_COMUNE IS  NULL)      THEN
--            OPEN  cpk4_provincia(NEW_PROVINCIA);
--            FETCH cpk4_provincia INTO dummy;
--            FOUND := cpk4_provincia%FOUND;
--            CLOSE cpk4_provincia;
--            IF NOT FOUND THEN
--          errno  := -20003;
--          errmsg := si4.get_error('A10091');-- || ' La registrazione non puo'' essere inserita.';
--          RAISE integrity_error;
--            END IF;
--         END IF;
--      EXCEPTION
--         WHEN MUTATING THEN NULL;  -- Ignora Check su Relazioni Ricorsive
--      END;
      -- rev. 3 fine
      BEGIN  --  Parent "TIPI_RECAPITO" deve esistere quando si modifica "RECAPITI"
         IF NEW_TIPO_RECAPITO IS NOT NULL THEN
            OPEN  cpk3_tipi_recapito(NEW_TIPO_RECAPITO);
            FETCH cpk3_tipi_recapito INTO dummy;
            FOUND := cpk3_tipi_recapito%FOUND;
            CLOSE cpk3_tipi_recapito;
            IF NOT FOUND THEN
          errno  := -20003;
          errmsg := si4.get_error('A10042') ;
          RAISE integrity_error;
            END IF;
         END IF;
      EXCEPTION
         WHEN MUTATING THEN NULL;  -- Ignora Check su Relazioni Ricorsive
      END;
      BEGIN  --  Parent "NI" deve esistere quando si modifica "RECAPITI"
         IF  NEW_NI IS NOT NULL  THEN
            OPEN  cpk1_anagrafici(NEW_NI);
            FETCH cpk1_anagrafici INTO dummy;
            FOUND := cpk1_anagrafici%FOUND;
            CLOSE cpk1_anagrafici;
            IF NOT FOUND THEN
          errno  := -20003;
          errmsg := si4.get_error('A10051');--  ||'ni =' || new_ni;-- || ' La registrazione Recapiti non puo'' essere inserita.';
          RAISE integrity_error;
            END IF;
         END IF;
      EXCEPTION
         WHEN MUTATING THEN NULL;  -- Ignora Check su Relazioni Ricorsive
      END;
      NULL;
   END;
end if; -- NON sono in trasco
EXCEPTION
   WHEN integrity_error THEN
        Integritypackage.InitNestLevel;
        RAISE_APPLICATION_ERROR(errno, errmsg);
   WHEN OTHERS THEN
        Integritypackage.InitNestLevel;
        RAISE;
END;
/*END PROCEDURE RECAPITI_PI*/
procedure RECAPITI_PD
/******************************************************************************
 NOME:        RECAPITI_PD
 DESCRIZIONE: Procedure for Check REFERENTIAL Integrity
                         at DELETE on Table RECAPITI
 ARGOMENTI:   Rigenerati in automatico.
 ECCEZIONI:  -20006, Esistono riferimenti su CHILD TABLE
 ANNOTAZIONI: Richiamata da Trigger RECAPITI_TD
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
    0 07/09/2005 MM     Introduzione controllo di integrita referenziale su
                       XX4_RECAPITI.
******************************************************************************/
(OLD_id_recapito IN number,
 old_dal IN date,
 old_al IN date)
is
   integrity_error  exception;
   errno            integer;
   errmsg           char(200);
   dummy            integer;
   found            boolean;
   oggetto          varchar2(200);
   --  Declaration of DeleteParentRestrict constraint for "XX4_RECAPITI"
   cursor cfk1_RECAPITI(var_id_recapito number, var_dal date , var_al date) is
      select oggetto
      from   XX4_RECAPITI
      where  id_recapito = var_id_recapito
       and   dal between var_dal and nvl(var_al, to_date('3333333','j'))
       and   var_id_recapito is not null
       and   var_dal is not null
     UNION
      select oggetto
      from   XX4_RECAPITI
      where  id_recapito = var_id_recapito
       and   var_id_recapito is not null
       and   var_dal is null; -- se dal e' nullo nessuna registrazione e' eliminabile
     cursor cfk2_RECAPITI(var_id_recapito number, var_dal date , var_al date) is
      select id_contatto
      from   CONTATTI
      where  id_recapito = var_id_recapito
       and   var_id_recapito is not null
       and   dal between var_dal and nvl(var_al, to_date('3333333','j'))
       and   var_dal is not null;
begin
   begin  -- Check REFERENTIAL Integrity
      --  Cannot delete parent "RECAPITI" if children still exist in "XX4_RECAPITI"
      open  cfk1_RECAPITI(OLD_id_recapito,OLD_DAL, OLD_AL);
      fetch cfk1_RECAPITI into oggetto;
      found := cfk1_RECAPITI%FOUND;
      close cfk1_RECAPITI;
      if found then
          errno  := -20006;
          errmsg := si4.get_error('A10044') || ' Riferimenti su RECAPITI ('||oggetto||').';
          raise integrity_error;
      end if;
      null;
   end;
   begin  -- Check REFERENTIAL Integrity
      --  Cannot delete parent "RECAPITI" if children still exist in "RECAPITI"
      open  cfk2_RECAPITI(OLD_id_recapito,OLD_DAL, OLD_AL);
      fetch cfk2_RECAPITI into oggetto;
      found := cfk2_RECAPITI%FOUND;
      close cfk2_RECAPITI;
      if found then
          errno  := -20006;
          errmsg := si4.get_error('A10043') || ' ('||oggetto||')';
          raise integrity_error;
      end if;
   end;
exception
   when integrity_error then
        IntegrityPackage.InitNestLevel;
        raise_application_error(errno, errmsg);
   when others then
        IntegrityPackage.InitNestLevel;
        raise;
end;
/* End Procedure: RECAPITI_PD */
FUNCTION CONTA_NI_RECAPITI_DAL_AL (p_ni NUMBER, p_new_id_tipo_recapito number, p_dal date, p_al date)
   RETURN NUMBER
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   v_num_ni   NUMBER;
BEGIN
   SELECT COUNT (*)
     INTO v_num_ni
     FROM RECAPITI
    WHERE ni = p_ni
      AND id_tipo_recapito = p_new_id_tipo_recapito
      AND (dal between p_dal and nvl(p_al, to_date('3333333','j'))
           OR p_dal between dal and nvl(al, dal) -- se al aperto posso chiuderlo e non disturba
           );
   RETURN v_num_ni;
END;
/* End Functon: CONTA_NI_RECAPITI_DAL_AL */

FUNCTION CONTA_NI_RECAPITI_DAL_ALnonull (p_ni NUMBER, p_new_id_tipo_recapito number, p_dal date, p_al date)
   RETURN NUMBER
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   v_num_ni   NUMBER;
BEGIN
   SELECT COUNT (*)
     INTO v_num_ni
     FROM RECAPITI
    WHERE ni = p_ni
      AND id_tipo_recapito = p_new_id_tipo_recapito
      AND (dal between p_dal and nvl(p_al, to_date('3333333','j'))
           OR p_dal between dal and nvl(al, to_date('3333333','j'))
           )
      AND al is not null;
   RETURN v_num_ni;
END;
/* End Functon: CONTA_NI_RECAPITI_DAL_ALnonull */
FUNCTION CONTA_NI_RECAPITI (p_ni NUMBER, p_new_id_tipo_recapito number)
   RETURN NUMBER
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   v_num_ni   NUMBER;
BEGIN
   SELECT COUNT (*)
     INTO v_num_ni
     FROM RECAPITI
    WHERE ni = p_ni
      AND id_tipo_recapito = p_new_id_tipo_recapito;
   RETURN v_num_ni;
END;
/* End Function: CONTA_NI_RECAPITI*/
 FUNCTION get_dal_attuale_id_recapito (p_id_recapito IN RECAPITI.id_recapito%TYPE)
      RETURN RECAPITI.dal%TYPE
   IS                                                         /* SLAVE_COPY */
      /******************************************************************************
       NOME:        get_dal_attuale_id_recapito
       DESCRIZIONE: Getter per attributo al di riga identificata dalla chiave.
       PARAMETRI:   Attributi chiave.
       RITORNA:     RECAPITI.dal%type.
       NOTE:        La riga identificata deve essere presente.
      ******************************************************************************/
   PRAGMA AUTONOMOUS_TRANSACTION;
      d_result   RECAPITI.al%TYPE;
   BEGIN
      BEGIN
      SELECT   dal
        INTO   d_result
        FROM   RECAPITI
       WHERE   id_recapito = p_id_recapito
         AND   trunc(sysdate) between dal and nvl(al, to_date('3333333','j'));
      exception
      when no_data_found
      then
         d_result := '';
      END;
      RETURN d_result;
   END get_dal_attuale_id_recapito;                          -- recapiti_pkg.get_dal_attuale_id_recapito




PROCEDURE CHECK_IMPORTANZA_UNIVOCA (var_id_recapito       NUMBER,
                                  var_ni                  NUMBER,
                                  var_importanza          NUMBER,
                                  var_id_tipo_recapito    VARCHAR2,
                                  var_dal                 DATE,
                                  var_al                  DATE)
IS
    v_id_recapito recapiti.id_recapito%TYPE;
      FOUND boolean;
      --  Controllo se esiste un record con importanza uguale
      CURSOR check_recapiti(var_id_recapito NUMBER, var_ni NUMBER, var_importanza varchar2, var_id_tipo_recapito varchar2, var_dal date, var_al date ) IS
      SELECT id_recapito
      FROM   RECAPITI
      WHERE  ni = var_ni
       AND   id_tipo_recapito = var_id_tipo_recapito
       AND   id_tipo_recapito is not null
       AND   var_id_tipo_recapito is not null
       AND   importanza  = var_importanza
       AND   importanza is not null
       AND   var_importanza is not null
       -- rev. 1 inizio
       AND   dal <= nvl(var_al, to_date('3333333','j'))
       AND   nvl(al, to_date('3333333','j')) >= var_dal
       -- rev. 1 fine
       AND   id_recapito != var_id_recapito;
 BEGIN  -- Check REFERENTIAL Integrity
      OPEN  check_recapiti(var_id_recapito, var_ni , var_importanza ,  var_id_tipo_recapito , var_dal, var_al);
      FETCH check_recapiti INTO v_id_recapito;
      FOUND := check_recapiti%FOUND;
      CLOSE check_recapiti;
      IF FOUND THEN
        raise_application_error (-20999,
                               si4.get_error('A10092') ||'(recapiti)'
--                               'Impossibille inserire più record con uguale IMPORTANZA.'
                               );
      END IF;
END     CHECK_IMPORTANZA_UNIVOCA;

   FUNCTION ESTRAI_STORICO
    ( P_NI IN NUMBER)
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
******************************************************************************/
        d_tree_storico  clob := empty_clob();
        d_amount     BINARY_INTEGER := 32767;
        d_char       VARCHAR2(32767);
        d_xml        VARCHAR2(32767);
        d_new_descrizione       recapiti_STORICO.descrizione%type;
        D_NEW_AL                recapiti_STORICO.AL%TYPE;
        D_NEW_PROVINCIA         recapiti_STORICO.PROVINCIA%TYPE;
        D_NEW_COMUNE            recapiti_STORICO.COMUNE%TYPE;
        D_NEW_indirizzo         recapiti_STORICO.indirizzo%TYPE;
        D_NEW_id_tipo_recapito  recapiti_STORICO.id_tipo_recapito%TYPE;
        D_NEW_Cap               recapiti_STORICO.cap%TYPE;
        D_NEW_presso            recapiti_STORICO.presso%TYPE;
        D_NEW_importANZA        recapiti_STORICO.IMPORTANZA%TYPE;
        D_NEW_COMPETENZA        recapiti_STORICO.COMPETENZA%TYPE;
        D_NEW_COMPETENZA_ESCLUSIVA   recapiti_STORICO.COMPETENZA_ESCLUSIVA%TYPE;
        d_utente                recapiti_storico.utente_aggiornamento%type;
        d_denominazione_provincia   varchar2(1000);
        d_denominazione_provincia2   varchar2(1000);
        D_MODIFICA_OK           NUMBER := 0;
        length_stringa          number;
        d_des_utente_aggiornamento  varchar2(100);
    begin
        dbms_lob.createTemporary(d_tree_storico,TRUE,dbms_lob.CALL);
        D_XML:= '<ROWSET>'||CHR(10);
        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
        for sel_storico_reca in (  select *
                                     from recapiti_storico
                                    where ni = P_NI
                                      and operazione in ('I','BI','D')
                                  order by id_evento
                                ) loop
            D_MODIFICA_OK   := 0;
            if sel_storico_reca.operazione = 'I' then --nuovi inserimenti
                d_utente := nvl(sel_storico_reca.utente_aggiornamento,sel_storico_reca.utente_agg); -- se non è tracciato l'utente dell'operazione prendo quello valorizzato
                d_des_utente_aggiornamento := ad4_soggetto.get_denominazione(ad4_utente.get_soggetto(d_utente,'N',0));
                if d_des_utente_aggiornamento is not null then
                    d_des_utente_aggiornamento := nvl(ad4_utente.get_nominativo(d_utente,'N',0),d_utente)||' - '||d_des_utente_aggiornamento;
                else
                    d_des_utente_aggiornamento := nvl(ad4_utente.get_nominativo(d_utente,'N',0),d_utente);
                end if;
                D_XML:= '<ROW><LABEL_PARTE1>Recapito '||tipi_recapito_tpk.get_descrizione(sel_storico_reca.id_tipo_recapito)||' con decorrenza '||TO_CHAR(sel_storico_reca.dal,'DD/MM/YYYY')||' inserito da '||d_des_utente_aggiornamento||' il '||TO_CHAR(sel_storico_reca.data,'DD/MM/YYYY hh24:MI:SS')||'</LABEL_PARTE1>'||CHR(10)||'<ROWSET>'||CHR(10);
                dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                if sel_storico_reca.al is not null then
                       D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>AL</LABEL_PARTE1><LABEL_PARTE3>'||to_char(sel_storico_reca.al,'dd/mm/yyyy')||'</LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                end if;
                if sel_storico_reca.descrizione is not null then
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>DESCRIZIONE</LABEL_PARTE1><LABEL_PARTE3>'||sel_storico_reca.DESCRIZIONE||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                end if;
-- già indicato in testata
--                if SEL_STORICO_RECA.ID_TIPO_RECAPITO is not null then
--                        D_XML:= '<ROW><ICONA>add.png</ICONA><ATTRIBUTO>TIPO_RECAPITO</ATTRIBUTO><LABEL_PARTE3>'||SEL_STORICO_RECA.ID_TIPO_RECAPITO||'</LABEL_PARTE3></ROW>'||CHR(10);
--                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
--                end if;
                if SEL_STORICO_RECA.INDIRIZZO is not null then
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>INDIRIZZO</LABEL_PARTE1><LABEL_PARTE3>'||SEL_STORICO_RECA.INDIRIZZO||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                end if;
                if SEL_STORICO_RECA.PROVINCIA is not null then
                    begin
                        if SEL_STORICO_RECA.PROVINCIA <200 then -- provincia italiana
                            d_denominazione_provincia :=  ad4_provincia.get_denominazione(SEL_STORICO_RECA.PROVINCIA);
                        else
                            d_denominazione_provincia :=ad4_stati_territori_tpk.get_denominazione(SEL_STORICO_RECA.PROVINCIA);
                        end if;
                    exception when others then
                        d_denominazione_provincia := null;
                    end;
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>PROVINCIA</LABEL_PARTE1><LABEL_PARTE3>'||d_denominazione_provincia||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                end if;
                if SEL_STORICO_RECA.COMUNE is not null then
                 if SEL_STORICO_RECA.provincia is not null then --rev.24 inizio
                         D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COMUNE</LABEL_PARTE1><LABEL_PARTE3>'||ad4_comuni_tpk.get_denominazione(SEL_STORICO_RECA.provincia,SEL_STORICO_RECA.COMUNE)||'</LABEL_PARTE3></ROW>'||CHR(10);
                       else -- provincia non valorizzata
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COMUNE</LABEL_PARTE1><LABEL_PARTE3>'||' COMUNE NON CODIFICATO: ' || SEL_STORICO_RECA.COMUNE||'</LABEL_PARTE3></ROW>'||CHR(10);
                  --rev.24 fine
                 end if;
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                end if;
                if SEL_STORICO_RECA.CAP is not null then
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>CAP</LABEL_PARTE1><LABEL_PARTE3>'||SEL_STORICO_RECA.CAP||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                end if;
                if SEL_STORICO_RECA.PRESSO is not null then
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>PRESSO</LABEL_PARTE1><LABEL_PARTE3>'||SEL_STORICO_RECA.PRESSO||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                end if;
                if SEL_STORICO_RECA.IMPORTANZA is not null then
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>IMPORTANZA</LABEL_PARTE1><LABEL_PARTE3>'||SEL_STORICO_RECA.IMPORTANZA||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                end if;
                if SEL_STORICO_RECA.COMPETENZA is not null then
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COMPETENZA</LABEL_PARTE1><LABEL_PARTE3>'||SEL_STORICO_RECA.COMPETENZA||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                end if;
                if SEL_STORICO_RECA.COMPETENZA_ESCLUSIVA is not null then
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COMPETENZA ESCLUSIVA</LABEL_PARTE1><LABEL_PARTE3>'||SEL_STORICO_RECA.COMPETENZA_ESCLUSIVA||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                end if;
                D_XML:= '</ROWSET></ROW>'||CHR(10);
                dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
            elsif SEL_STORICO_RECA.operazione = 'BI' then --modifica del record
                SELECT al, DESCRIZIONE, ID_TIPO_RECAPITO, INDIRIZZO, PROVINCIA, COMUNE, CAP, PRESSO, IMPORTANZA, COMPETENZA, COMPETENZA_ESCLUSIVA , utente_agg
                  INTO  D_NEW_AL,
                        D_NEW_DESCRIZIONE, D_NEW_id_tipo_recapito, D_NEW_INDIRIZZO,
                        D_NEW_PROVINCIA ,
                        D_NEW_COMUNE ,
                        D_NEW_CAP  ,
                        D_NEW_PRESSO  ,
                        D_NEW_IMPORTANZA ,
                        D_NEW_COMPETENZA  ,
                        D_NEW_COMPETENZA_ESCLUSIVA ,
                        d_utente
                  FROM RECAPITI_STORICO
                 WHERE BI_RIFERIMENTO = SEL_STORICO_RECA.ID_EVENTO
                   AND OPERAZIONE = 'AI'
                   --
                   --
                   ;
                d_des_utente_aggiornamento := ad4_soggetto.get_denominazione(ad4_utente.get_soggetto(d_utente,'N',0));
                if d_des_utente_aggiornamento is not null then
                    d_des_utente_aggiornamento := nvl(ad4_utente.get_nominativo(d_utente,'N',0),d_utente)||' - '||d_des_utente_aggiornamento;
                else
                    d_des_utente_aggiornamento := nvl(ad4_utente.get_nominativo(d_utente,'N',0),d_utente);
                end if;
                D_XML:= '<ROW><LABEL_PARTE1>Recapito '||tipi_recapito_tpk.get_descrizione(sel_storico_reca.id_tipo_recapito)||' con decorrenza '||TO_CHAR(SEL_STORICO_RECA.dal,'DD/MM/YYYY')||' aggiornato da '||d_des_utente_aggiornamento||' il '||TO_CHAR(SEL_STORICO_RECA.data,'DD/MM/YYYY hh24:MI:SS')||'</LABEL_PARTE1>'||CHR(10)||'<ROWSET>'||CHR(10);
                length_stringa := length(d_xml);
                dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                if NVL(SEL_STORICO_RECA.al,TO_DATE(3333333,'J')) != NVL(D_NEW_AL,TO_DATE(3333333,'J')) THEN -- MODIFICATO AL
                    D_MODIFICA_OK := 1;
                    IF SEL_STORICO_RECA.AL IS NULL AND D_NEW_AL IS NOT NULL THEN
                       D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>AL</LABEL_PARTE1><LABEL_PARTE3>'||to_char(D_NEW_AL,'dd/mm/yyyy')||'</LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSIF SEL_STORICO_RECA.AL IS NOT NULL AND D_NEW_AL IS NULL THEN
                       D_XML:= '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>AL</LABEL_PARTE1><LABEL_PARTE2>'||to_char(SEL_STORICO_RECA.AL,'dd/mm/yyyy')||'</LABEL_PARTE2></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSE
                       D_XML:= '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>AL</LABEL_PARTE1><LABEL_PARTE2><![CDATA['||to_char(SEL_STORICO_RECA.AL,'dd/mm/yyyy')||']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['||to_char(d_new_AL,'dd/mm/yyyy')||']]></LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    END IF;
                END IF;
                if NVL(SEL_STORICO_RECA.DESCRIZIONE,'x') != NVL(D_NEW_DESCRIZIONE,'x') THEN -- MODIFICATO DESCRIZIONE
                    D_MODIFICA_OK := 1;
                    IF SEL_STORICO_RECA.DESCRIZIONE IS NULL AND D_NEW_DESCRIZIONE IS NOT NULL THEN
                       D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>DESCRIZIONE</LABEL_PARTE1><LABEL_PARTE3>'||D_NEW_DESCRIZIONE||'</LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSIF SEL_STORICO_RECA.DESCRIZIONE IS NOT NULL AND D_NEW_DESCRIZIONE IS NULL THEN
                       D_XML:= '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>DESCRIZIONE</LABEL_PARTE1><LABEL_PARTE2>'||SEL_STORICO_RECA.DESCRIZIONE ||'</LABEL_PARTE2></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSE
                       D_XML:= '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>DESCRIZIONE</LABEL_PARTE1><LABEL_PARTE2><![CDATA['||SEL_STORICO_RECA.DESCRIZIONE||']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['||d_new_DESCRIZIONE||']]></LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    END IF;
                END IF;
-- il tipo non può essere modificato
--                if NVL(SEL_STORICO_RECA.ID_TIPO_RECAPITO,-1) != NVL(D_NEW_ID_TIPO_RECAPITO,-1) THEN -- MODIFICATO AL
--                    IF SEL_STORICO_RECA.ID_TIPO_RECAPITO IS NULL AND D_NEW_ID_TIPO_RECAPITO IS NOT NULL THEN
--                       D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>TIPO RECAPITO</LABEL_PARTE1><LABEL_PARTE2>'||D_NEW_ID_TIPO_RECAPITO||'</LABEL_PARTE2></ROW>'||CHR(10);
--                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
--                    ELSIF SEL_STORICO_RECA.ID_TIPO_RECAPITO IS NOT NULL AND D_NEW_ID_TIPO_RECAPITO IS NULL THEN
--                       D_XML:= '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>TIPO RECAPITO</LABEL_PARTE1><LABEL_PARTE2>'||SEL_STORICO_RECA.ID_TIPO_RECAPITO ||'</LABEL_PARTE2></ROW>'||CHR(10);
--                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
--                    ELSE
--                       D_XML:= '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>TIPO RECAPITO</LABEL_PARTE1><LABEL_PARTE2><![CDATA['||SEL_STORICO_RECA.ID_TIPO_RECAPITO||' => '||d_new_ID_TIPO_RECAPITO||']]></LABEL_PARTE2></ROW>'||CHR(10);
--                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
--                    END IF;
--                END IF;
                if NVL(SEL_STORICO_RECA.INDIRIZZO,'xXXx') != NVL(D_NEW_INDIRIZZO,'xXXx') THEN -- MODIFICATO INDIRIZZO
                    D_MODIFICA_OK := 1;
                    IF SEL_STORICO_RECA.INDIRIZZO IS NULL AND D_NEW_INDIRIZZO IS NOT NULL THEN
                       D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>INDIRIZZO</LABEL_PARTE1><LABEL_PARTE3>'||D_NEW_INDIRIZZO||'</LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSIF SEL_STORICO_RECA.INDIRIZZO IS NOT NULL AND D_NEW_INDIRIZZO IS NULL THEN
                       D_XML:= '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>INDIRIZZO</LABEL_PARTE1><LABEL_PARTE2>'||SEL_STORICO_RECA.INDIRIZZO ||'</LABEL_PARTE2></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSE
                       D_XML:= '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>INDIRIZZO</LABEL_PARTE1><LABEL_PARTE2><![CDATA['||SEL_STORICO_RECA.INDIRIZZO||']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA[' ||d_new_INDIRIZZO||']]></LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    END IF;
                END IF;
                if NVL(SEL_STORICO_RECA.PROVINCIA,-1) != NVL(D_NEW_PROVINCIA,-1) THEN -- MODIFICATO PROVINCIA_nas
                    D_MODIFICA_OK := 1;
                    IF SEL_STORICO_RECA.PROVINCIA IS NULL AND D_NEW_PROVINCIA IS NOT NULL THEN
                        begin
                            if D_NEW_provincia <200 then -- provincia italiana
                                d_denominazione_provincia :=  ad4_provincia.get_denominazione(D_NEW_provincia);
                            else
                                d_denominazione_provincia :=ad4_stati_territori_tpk.get_denominazione(D_NEW_provincia);
                            end if;
                        exception when others then
                            d_denominazione_provincia := null;
                        end;
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>PROVINCIA</LABEL_PARTE1><LABEL_PARTE3>'||d_denominazione_provincia||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSIF SEL_STORICO_RECA.PROVINCIA IS NOT NULL AND D_NEW_PROVINCIA IS NULL THEN
                        begin
                            if SEL_STORICO_reca.PROVINCIA <200 then -- provincia italiana
                                d_denominazione_provincia :=  ad4_provincia.get_denominazione(SEL_STORICO_reca.PROVINCIA);
                            else
                                d_denominazione_provincia :=ad4_stati_territori_tpk.get_denominazione(SEL_STORICO_reca.PROVINCIA);
                            end if;
                        exception when others then
                            d_denominazione_provincia := null;
                        end;
                        D_XML:= '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>PROVINCIA</LABEL_PARTE1><LABEL_PARTE2>'||d_denominazione_provincia||'</LABEL_PARTE2></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSE
                        begin
                            if SEL_STORICO_reca.PROVINCIA <200 then -- provincia italiana
                                d_denominazione_provincia :=  ad4_provincia.get_denominazione(SEL_STORICO_reca.PROVINCIA);
                            else
                                d_denominazione_provincia :=ad4_stati_territori_tpk.get_denominazione(SEL_STORICO_reca.PROVINCIA);
                            end if;
                        exception when others then
                            d_denominazione_provincia := null;
                        end;
                        begin
                            if d_new_PROVINCIA <200 then -- provincia italiana
                                d_denominazione_provincia2 :=  ad4_provincia.get_denominazione(d_new_PROVINCIA);
                            else
                                d_denominazione_provincia2 :=ad4_stati_territori_tpk.get_denominazione(d_new_PROVINCIA);
                            end if;
                        exception when others then
                            d_denominazione_provincia := null;
                        end;
                       D_XML:= '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>PROVINCIA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['||d_denominazione_provincia||']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['||d_denominazione_PROVINCIA2||']]></LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    END IF;
                END IF;
                if NVL(SEL_STORICO_RECA.COMUNE,-1) != NVL(D_NEW_COMUNE,-1) THEN -- MODIFICATO comune
                    D_MODIFICA_OK := 1;
                    IF SEL_STORICO_RECA.COMUNE IS NULL AND D_NEW_COMUNE IS NOT NULL THEN
                       if SEL_STORICO_RECA.provincia is not null then --rev.24 inizio
                         D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COMUNE</LABEL_PARTE1><LABEL_PARTE3>'||ad4_comuni_tpk.get_denominazione(d_new_PROVINCIA,D_NEW_COMUNE)||'</LABEL_PARTE3></ROW>'||CHR(10);
                        else -- provincia non valorizzata
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COMUNE</LABEL_PARTE1><LABEL_PARTE3>'||' COMUNE NON CODIFICATO: ' ||D_NEW_COMUNE||'</LABEL_PARTE3></ROW>'||CHR(10);
                         --rev.24 fine
                        end if;
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSIF SEL_STORICO_RECA.COMUNE IS NOT NULL AND D_NEW_COMUNE IS NULL THEN
                       if SEL_STORICO_RECA.provincia is not null then --rev.24 inizio
                         D_XML:= '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>COMUNE</LABEL_PARTE1><LABEL_PARTE2>'||ad4_comuni_tpk.get_denominazione(SEL_STORICO_RECA.provincia,SEL_STORICO_RECA.COMUNE)||'</LABEL_PARTE2></ROW>'||CHR(10);
                        else -- provincia non valorizzata
                        D_XML:= '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>COMUNE</LABEL_PARTE1><LABEL_PARTE2>'||' COMUNE NON CODIFICATO: ' || SEL_STORICO_RECA.COMUNE ||'</LABEL_PARTE2></ROW>'||CHR(10);
                         --rev.24 fine
                        end if;
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSE
                        D_XML := '';
                       if SEL_STORICO_RECA.provincia is not null then --rev.24 inizio
                         D_XML:= '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>COMUNE</LABEL_PARTE1><LABEL_PARTE2><![CDATA['||ad4_comuni_tpk.get_denominazione(SEL_STORICO_RECA.provincia,SEL_STORICO_RECA.COMUNE)||']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA[' ;
                       else -- provincia non valorizzata
                        D_XML:= '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>COMUNE</LABEL_PARTE1><LABEL_PARTE2><![CDATA['||' COMUNE NON CODIFICATO: ' || SEL_STORICO_RECA.COMUNE ||']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA[' ;
                        --rev.24 fine
                        end if;
                       if d_new_PROVINCIA is not null then --rev.24 inizio
                         D_XML:= D_XML ||ad4_comuni_tpk.get_denominazione(d_new_PROVINCIA,D_NEW_COMUNE)||']]></LABEL_PARTE3></ROW>'||CHR(10);
                       else -- provincia non valorizzata
                        D_XML:= D_XML || ' COMUNE NON CODIFICATO: ' ||D_NEW_COMUNE||']]></LABEL_PARTE3></ROW>'||CHR(10);
                        --rev.24 fine
                        end if;
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    END IF;
                END IF;
                if NVL(SEL_STORICO_RECA.CAP,'xxxxxxxxxxxxxxxxx') != NVL(D_NEW_CAP,'xxxxxxxxxxxxxxxxx') THEN -- MODIFICATO CF
                    D_MODIFICA_OK := 1;
                    IF SEL_STORICO_RECA.CAP IS NULL AND D_NEW_CAP IS NOT NULL THEN
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>CAP</LABEL_PARTE1><LABEL_PARTE3>'||D_NEW_CAP||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSIF SEL_STORICO_RECA.CAP IS NOT NULL AND D_NEW_CAP IS NULL THEN
                        D_XML:= '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>CAP</LABEL_PARTE1><LABEL_PARTE2>'||SEL_STORICO_RECA.CAP||'</LABEL_PARTE2></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSE
                       D_XML:= '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>CAP</LABEL_PARTE1><LABEL_PARTE2><![CDATA['||SEL_STORICO_RECA.CAP||']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA[' ||d_new_CAP||']]></LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    END IF;
                END IF;
                if NVL(SEL_STORICO_RECA.PRESSO,'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX') != NVL(D_NEW_PRESSO,'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX') THEN -- MODIFICATO PRESSO
                    D_MODIFICA_OK := 1;
                    IF SEL_STORICO_RECA.PRESSO IS NULL AND D_NEW_PRESSO IS NOT NULL THEN
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>PRESSO</LABEL_PARTE1><LABEL_PARTE3>'||D_NEW_PRESSO||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSIF SEL_STORICO_RECA.PRESSO IS NOT NULL AND D_NEW_PRESSO IS NULL THEN
                        D_XML:= '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>PRESSO</LABEL_PARTE1><LABEL_PARTE2>'||SEL_STORICO_RECA.PRESSO||'</LABEL_PARTE2></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSE
                       D_XML:= '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>PRESSO</LABEL_PARTE1><LABEL_PARTE2><![CDATA['||SEL_STORICO_RECA.PRESSO||']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['||d_new_PRESSO||']]></LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    END IF;
                END IF;

                if NVL(SEL_STORICO_RECA.IMPORTANZA,-1) != NVL(D_NEW_IMPORTANZA,-1) THEN -- MODIFICATO CF
                    D_MODIFICA_OK := 1;
                    IF SEL_STORICO_RECA.IMPORTANZA IS NULL AND D_NEW_IMPORTANZA IS NOT NULL THEN
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>IMPORTANZA</LABEL_PARTE1><LABEL_PARTE3>'||D_NEW_IMPORTANZA||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSIF SEL_STORICO_RECA.IMPORTANZA IS NOT NULL AND D_NEW_IMPORTANZA IS NULL THEN
                        D_XML:= '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>IMPORTANZA</LABEL_PARTE1><LABEL_PARTE2>'||SEL_STORICO_RECA.IMPORTANZA||'</LABEL_PARTE2></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSE
                       D_XML:= '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>IMPORTANZA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['||SEL_STORICO_RECA.IMPORTANZA||']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['||d_new_IMPORTANZA||']]></LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    END IF;
                END IF;
                if NVL(SEL_STORICO_RECA.COMPETENZA,'xxxxxxxxxxx') != NVL(D_NEW_COMPETENZA,'xxxxxxxxxxx') THEN -- MODIFICATO CF
                    D_MODIFICA_OK := 1;
                    IF SEL_STORICO_RECA.COMPETENZA IS NULL AND D_NEW_COMPETENZA IS NOT NULL THEN
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COMPETENZA</LABEL_PARTE1><LABEL_PARTE3>'||D_NEW_COMPETENZA||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSIF SEL_STORICO_RECA.COMPETENZA IS NOT NULL AND D_NEW_COMPETENZA IS NULL THEN
                        D_XML:= '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>COMPETENZA</LABEL_PARTE1><LABEL_PARTE2>'||SEL_STORICO_RECA.COMPETENZA||'</LABEL_PARTE2></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSE
                       D_XML:= '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>COMPETENZA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['||SEL_STORICO_RECA.COMPETENZA||']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['||d_new_COMPETENZA||']]></LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    END IF;
                END IF;
                if NVL(SEL_STORICO_RECA.COMPETENZA_ESCLUSIVA,'xx') != NVL(D_NEW_COMPETENZA_ESCLUSIVA,'xx') THEN -- MODIFICATO CF
                    D_MODIFICA_OK := 1;
                    IF SEL_STORICO_RECA.COMPETENZA_ESCLUSIVA IS NULL AND D_NEW_COMPETENZA_ESCLUSIVA IS NOT NULL THEN
                        D_XML:= '<ROW><ICONA>add.png</ICONA><LABEL_PARTE1>COMPETENZA ESCLUSIVA</LABEL_PARTE1><LABEL_PARTE3>'||D_NEW_COMPETENZA_ESCLUSIVA||'</LABEL_PARTE3></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSIF SEL_STORICO_RECA.COMPETENZA_ESCLUSIVA IS NOT NULL AND D_NEW_COMPETENZA_ESCLUSIVA IS NULL THEN
                        D_XML:= '<ROW><ICONA>delete.png</ICONA><LABEL_PARTE1>COMPETENZA ESCLUSIVA</LABEL_PARTE1><LABEL_PARTE2>'||SEL_STORICO_RECA.COMPETENZA_esclusiva||'</LABEL_PARTE2></ROW>'||CHR(10);
                        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    ELSE
                       D_XML:= '<ROW><ICONA>edit.png</ICONA><LABEL_PARTE1>COMPETENZA ESCLUSIVA</LABEL_PARTE1><LABEL_PARTE2><![CDATA['||SEL_STORICO_RECA.COMPETENZA_esclusiva||']]></LABEL_PARTE2><LABEL_PARTE3><![CDATA['||d_new_COMPETENZA_esclusiva||']]></LABEL_PARTE3></ROW>'||CHR(10);
                       dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                    END IF;
                END IF;
                IF D_MODIFICA_OK = 1 THEN    -- C'è almeno una modifica
                    D_XML:= '</ROWSET></ROW>'||CHR(10);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
                else
                    D_TREE_STORICO := dbms_lob.substr(d_tree_storico,dbms_lob.getlength(d_tree_storico)-length_stringa);
                end if;
            elsif SEL_STORICO_RECA.operazione = 'D' then --modifica del record
                d_utente := nvl(sel_storico_reca.utente_aggiornamento,sel_storico_reca.utente_agg); -- scrivo un utente a caso???? andrebbe tracciato correttamente
                d_des_utente_aggiornamento := ad4_soggetto.get_denominazione(ad4_utente.get_soggetto(d_utente,'N',0));
                if d_des_utente_aggiornamento is not null then
                    d_des_utente_aggiornamento := nvl(ad4_utente.get_nominativo(d_utente,'N',0),d_utente)||' - '||d_des_utente_aggiornamento;
                else
                    d_des_utente_aggiornamento := nvl(ad4_utente.get_nominativo(d_utente,'N',0),d_utente);
                end if;
                D_XML:= '<ROWSET><ROW><LABEL_PARTE1>Recapito '||tipi_recapito_tpk.get_descrizione(sel_storico_reca.id_tipo_recapito)||' con decorrenza '||TO_CHAR(SEL_STORICO_RECA.dal,'DD/MM/YYYY')||' eliminato da '||d_des_utente_aggiornamento||' il '||TO_CHAR(SEL_STORICO_RECA.data,'DD/MM/YYYY hh24:MI:SS')||'</LABEL_PARTE1></ROW></ROWSET>'||CHR(10);
                dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
            end if;
        end loop;
        D_XML:= '</ROWSET>'||CHR(10);
        dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
        RETURN    d_tree_storico;
-- BEGIN
---- inserimento degli errori nella tabella
--   s_error_table( s_non_trovato_ni_num ) := s_non_trovato_ni_msg;
    end;

--   s_error_table( s_non_trovato_tipo_recap_num ) := s_non_trovato_tipo_recap_msg;
--   s_error_table( s_non_trovato_comune_num ) := s_non_trovato_comune_msg;
--   s_error_table( s_trovato_contatto_num ) := s_trovato_contatto_msg;
--   s_error_table( s_trovato_blocco_record_num ) := s_trovato_blocco_record_msg;
--   s_error_table( s_non_modificabile_id_num ) := s_non_modificabile_id_msg;
--   s_error_table( s_non_modificabile_storico_num ) := s_non_modificabile_storico_msg;
--   s_error_table( s_riferimento_unico_num ) := s_riferimento_unico_msg;
END;
/

