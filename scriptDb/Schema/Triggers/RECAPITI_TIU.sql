CREATE OR REPLACE TRIGGER RECAPITI_TIU
/******************************************************************************
       NOME:        recapiti_TIU
       DESCRIZIONE: Trigger for Check DATA Integrity
                                Check REFERENTIAL Integrity
                                  Set REFERENTIAL Integrity
                                  Set FUNCTIONAL Integrity
                             at INSERT or UPDATE on Table recapiti
       ECCEZIONI:   -20007, Identificazione CHIAVE presente in TABLE
       ANNOTAZIONI:
       REVISIONI:
       Rev. Data       Autore Descrizione
       ---- ---------- ------ ------------------------------------------------------
                              Prima distribuzione.
          1 06/04/2018 SN     Aggiunto controllo x recapito unico e stessa data decorrenza
          2 12/04/2018 SN     Storicizzo anche se al è valorizzato
          3 20/04/2018 SN     Verifiche su date solo se recapito di tipo unico
          4 27/08/2018 SN     NON fare storicizzazioni automatiche
          5 03/09/2018 SN     RIPRISTINATE storicizzazioni automatiche x problemi ad
                              anagrafica orizzontale.
          6 04/09/2018 SNeg   Consentita modifica di dal e al contemporaneamente
          7 11/09/2018 SNeg   Tolti automatismi su importanza
          8 11/09/2018 SNeg   Corrette modalità di storicizzazione
          9 12/09/2018 SNeg   Aggiunto parametro AL per RECAPITI_PKG.RECAPITI_RRI
         10 27/03/2019  SN    Chiusi solo i contatti ancora aperti
         11 19/04/2019 SNeg   Bug #34284 se tipo_recapito non indicato migliorare segnalazione
         12 21/08/2019 Sneg   Non serve aggiornare il dal se uguale a quello già indicato Bug #36464
         13 29/10/2019 SNeg   Se in trasco non aggiornare la data di aggiornamento Bug #37304
         14 12/10/2020 SNeg   Togliere dbms_output da RECAPITI_TIU ed ANAGRAFICI_PKG Bug #45130
         15 23/11/2020 SNeg  Impedire aggiornamento di dati storici Bug #34914
      ******************************************************************************/
   BEFORE INSERT OR UPDATE
   ON RECAPITI    FOR EACH ROW
DECLARE
   integrity_error   EXCEPTION;
   errno             INTEGER;
   errmsg            CHAR (200);
   dummy             INTEGER;
   FOUND             BOOLEAN;
   d_result          AFC_Error.t_error_number;
   mutating          EXCEPTION;
   PRAGMA EXCEPTION_INIT (mutating, -4091);
   v_new_dal date := :new.dal;
   v_old_dal date := :old.dal;
   v_new_al date := :new.al;
   v_old_al date := :old.al;
   v_new_id_recapito number := :new.id_recapito;
   v_old_id_recapito number := :old.id_recapito;
   v_new_indirizzo recapiti.indirizzo%TYPE := :new.indirizzo;
   v_old_indirizzo recapiti.indirizzo%TYPE := :old.indirizzo;
   v_num_recapiti    NUMBER;
   v_attivita varchar2(1);
   v_livello number := integritypackage.getnestlevel;
BEGIN
--dbms_output.put_line(integritypackage.getnestlevel);
--if inserting then
--dbms_output.put_line('RECAPITI **INS** ' || :new.dal ||':' || :new.id_tipo_recapito||':' || :new.al||':' || :new.id_recapito);
--else
--dbms_output.put_line('RECAPITI **UPD** ' || :new.dal||':' || :new.id_tipo_recapito||':' || :new.al||':' || :new.id_recapito);
--end if;
   if updating then v_attivita := 'U';
   elsif inserting then v_attivita := 'I';
   else v_attivita := 'D';
   end if;
--raise_application_error (-20999, 'competenza=' || :old.competenza || ' NEW=' || :new.competenza);
--raise_application_error (-20999, 'versione  ' || :old.version || ' NEW=' || :new.version);
--dbms_output.put_line('recapiti_tiu ' ||  anagrafici_pkg.v_aggiornamento_da_package_on);
  if nvl(anagrafici_pkg.trasco,0) = 1 then -- rev. 13
   :new.data_aggiornamento := sysdate;
  end if;
   :new.utente_aggiornamento := nvl(:new.utente_aggiornamento,si4.utente);
   IF :new.importanza <= 0
   THEN
       raise_application_error (-20999,si4.get_error('A00092') ||'(recapiti)'); --Il valore deve essere maggiore di 0.
   END IF;
    IF :new.dal > nvl(:new.al, to_date('3333333','j'))
         THEN
         -- Non possono avere dal minore di al
           raise_application_error
                               (-20999
                              ,   si4.get_error('A10070')  -- 'Impossibile indicare una data fine inferiore alla data inizio.
                              );
       END IF;
   IF UPDATING AND :old.ni != :new.ni
   THEN
      raise_application_error (
         -20999,
         si4.get_error('A10062') --'Impossibile modificare Anagrafica di riferimento'
         );
   END IF;
   --rev. 11 inizio
   IF :new.id_tipo_recapito is null then
   raise_application_error (
         -20999,
         si4.get_error('A10088') || ' TIPO RECAPITO' --Valore Obbligatorio
         );

   END IF;
   -- verifica di versione coerente x poter modificare con grails
   -- e controllare che il record non sia stato nel frattempo
   -- modificato da qualcun altro (consistenza)
      IF updating and (:new.version IS NULL OR :old.version = :new.version)
         THEN
        :new.version := nvl(:old.version,0)+1;
       ELSIF inserting
         THEN
         :new.version := 0;
      ELSE
         -- errore probabilmente il record era stato cambiato da qualcun altro
         raise_application_error (
            -20999,
            si4.get_error('A10059')--'Record cambiato dall''ultima lettura: Version attuale non compatibile con quella indicata '
            );
      END IF;
   BEGIN                           -- Check DATA Integrity on INSERT or UPDATE
      d_result :=
         anagrafici_pkg.is_competenza_ok (
            p_competenza                 => :NEW.competenza,
            p_competenza_esclusiva       => :NEW.competenza_esclusiva,
            p_competenza_old             => :OLD.competenza,
            p_competenza_esclusiva_old   => :OLD.competenza_esclusiva);
      IF NOT (d_result = AFC_Error.ok)
      THEN
         anagrafici_pkg.raise_error_message (d_result);
      END IF;
   END;
   DECLARE
      --  Declaration of UpdateParentRestrict constraint for "RECAPITI"
      CURSOR cpk4_tipo_recapito (
         var_id_tipo_recapito    VARCHAR)
      IS
         SELECT 1
           FROM TIPI_recapito
          WHERE     id_tipo_recapito = var_id_tipo_recapito
                AND var_id_tipo_recapito IS NOT NULL;
   BEGIN                                        -- Check REFERENTIAL Integrity
      BEGIN --  Parent "TIPI_RECAPITO" deve esistere quando si modifica "RECAPITI"
--         IF :NEW.id_tipo_recapito IS NOT NULL
--         THEN
            OPEN cpk4_tipo_recapito (:NEW.Id_tipo_recapito);
            FETCH cpk4_tipo_recapito INTO dummy;
            FOUND := cpk4_tipo_recapito%FOUND;
            CLOSE cpk4_tipo_recapito;
            IF NOT FOUND
            THEN
               errno := -20003;
               errmsg := si4.get_error('A10042');
--                  'Non esiste riferimento su Tipi recapiti. La registrazione non e'' modificabile.';
               RAISE integrity_error;
            END IF;
--         END IF;
      EXCEPTION
         WHEN MUTATING
         THEN
            NULL;                       -- Ignora Check su Relazioni Ricorsive
      END;
   END;
   DECLARE
      --  Declaration of UpdateParentRestrict constraint for "RECAPITI"
      CURSOR cpk4_ni (var_ni number)
      IS
         SELECT 1
           FROM anagrafici
          WHERE ni = var_ni AND var_ni IS NOT NULL;
   BEGIN                                        -- Check REFERENTIAL Integrity
      BEGIN      --  Parent "NI" deve esistere quando si modifica "RECAPITI"
         IF :NEW.NI IS NOT NULL
         THEN
            OPEN cpk4_ni (:NEW.NI);
            FETCH cpk4_ni INTO dummy;
            FOUND := cpk4_ni%FOUND;
            CLOSE cpk4_ni;
            IF NOT FOUND
            THEN
               errno := -20003;
               errmsg := si4.get_error('A10051') || ' La registrazione in Recapiti non e'' modificabile.';
--                  'Non esiste riferimento Anagrafici. La registrazione in Recapiti non e'' modificabile.';
               RAISE integrity_error;
            END IF;
         END IF;
      EXCEPTION
         WHEN MUTATING
         THEN
            NULL;                       -- Ignora Check su Relazioni Ricorsive
      END;
   END;
   BEGIN                    -- Check REFERENTIAL Integrity on INSERT or UPDATE
      IF UPDATING
      THEN
         DECLARE
            v_oggetto         xx4_recapiti.oggetto%TYPE;
            v_motivo_blocco   xx4_recapiti.motivo_blocco%TYPE;
            --  Declaration of UpdateParentRestrict constraint for "XX4_RECAPITI"
            CURSOR cfk1_recapiti (
               var_ni     NUMBER,
               var_id_recapito     NUMBER,
               var_dal    DATE)
            IS
               SELECT oggetto, motivo_blocco
                 FROM XX4_recapiti
                WHERE     ni = var_ni
                      AND var_ni IS NOT NULL
                      AND id_recapito = var_id_recapito
                      AND var_id_recapito IS NOT NULL
                      AND dal >= var_dal
                      AND var_dal IS NOT NULL;
         BEGIN                                  -- Check REFERENTIAL Integrity
            --  Informazioni in "recapiti" non modificabili se esistono referenze su "XX4_recapiti"
            OPEN cfk1_recapiti (:OLD.ni,:OLD.id_recapito, SYSDATE);
            FETCH cfk1_recapiti INTO V_oggetto, V_motivo_blocco;
            FOUND := cfk1_recapiti%FOUND;
            CLOSE cfk1_recapiti;
            IF FOUND
            THEN
               IF (V_motivo_blocco = 'R')
               THEN
                  errno := -20005;
                  errmsg := si4.get_error('A10063' ) || '('
--                        'Esistono riferimenti su Anagrafici ('
                     || V_oggetto
                     || '). La registrazione non e'' modificabile.';
                  IF v_motivo_blocco = 'R'
                  THEN
                     errmsg :=
                           errmsg
                        || '(motivo blocco: '
                        || V_motivo_blocco
                        || ')';
                  END IF;
                  RAISE integrity_error;
               END IF;
            END IF;
         END;
      END IF;
   END;
   if updating and :new.dal < :old.dal -- rev. 12 tolto  =
      and integritypackage.GetNestLevel > 0  then
      integritypackage.NextNestLevel;
      -- modifica della prima data
         update contatti set dal = :new.dal
           where id_recapito = :old.id_recapito
             and dal = :old.dal
             and al is null;
      integritypackage.PreviousNestlevel;
      end if;
   IF INSERTING
   THEN
--      raise_application_error(-20999, :new.provincia || ':' || :new.comune);
      recapiti_pkg.recapiti_pi (:NEW.ni,
                   :NEW.dal,
                   :NEW.provincia,
                   :NEW.comune,
                   :NEW.id_tipo_recapito);
      IF integritypackage.getnestlevel = 0
      THEN
         DECLARE
            --  Check UNIQUE PK Integrity per la tabella "RECAPITI"
            CURSOR cpk_recapiti (p_id_recapito NUMBER)
            IS
               SELECT 1
                 FROM recapiti
                WHERE id_recapito = p_id_recapito;
            mutating   EXCEPTION;
            PRAGMA EXCEPTION_INIT (mutating, -4091);
         BEGIN                 -- Check UNIQUE Integrity on PK of "ANAGRAFICI"
            IF :NEW.id_recapito IS NOT NULL AND :NEW.dal IS NOT NULL
            THEN
               OPEN cpk_recapiti (:NEW.id_recapito);
               FETCH cpk_recapiti INTO dummy;
               FOUND := cpk_recapiti%FOUND;
               CLOSE cpk_recapiti;
               IF FOUND
               THEN
                  errno := -20007;
                  errmsg := si4.get_error('A10064')
                  || ' in Recapiti (' || :NEW.id_recapito ||'). La registrazione  non puo'' essere inserita.';
--                        'Identificazione "'
--                     || :NEW.id_recapito
--                     || '" gia'' presente in Recapiti. La registrazione  non puo'' essere inserita.';
                  RAISE integrity_error;
               END IF;
            END IF;
         EXCEPTION
            WHEN mutating
            THEN
               NULL;                    -- Ignora Check su UNIQUE PK Integrity
         END;
      END IF;
   END IF;
   IF INSERTING AND :NEW.NI IS NULL
   THEN
      raise_application_error (
         -20999,
         si4.get_error('A10051') --|| ' ni non indicato'
--         'Impossibile inserire un record senza Anagrafica di riferimento'
         );
   END IF;
   IF INSERTING AND :NEW.ID_RECAPITO IS NULL
   THEN
      SELECT RECA_sq.NEXTVAL INTO :NEW.ID_RECAPITO FROM DUAL;
   END IF;
--  if inserting then
--  raise_application_error(-20999,'inserisco'|| :new.dal)
--;
--else
--  raise_application_error(-20999,'aggiorno'|| :new.dal)
--;
--end if;
     -- rev 1 inizio
     -- se tipo UNICO, e sto inserendo
     -- devo bloccare
IF  nvl(tipi_recapito_tpk.get_unico(:new.id_tipo_recapito),'NO') = 'SI'
      and (inserting or (updating and :new.dal != :old.dal))
   THEN
      -- Non posso inserire un nuovo record di tipo unico
      -- con lo stesso dal di uno esistente
      DECLARE
         CURSOR recapito_unico_stesso_dal (var_ni    VARCHAR,
                                           var_dal            DATE,
                                           var_id_tipo_recapito varchar2)
         IS
            SELECT 1
              FROM recapiti
             WHERE ni = var_ni
               AND dal = var_dal
               AND id_tipo_recapito= var_id_tipo_recapito;
      BEGIN                                     -- Check REFERENTIAL Integrity
         BEGIN --  Parent "TIPI_RECAPITO" deve esistere quando si modifica "RECAPITI"
            IF :NEW.ni IS NOT NULL
            THEN
               OPEN recapito_unico_stesso_dal (:NEW.ni,
                                               :NEW.dal,
                                               :new.id_tipo_recapito);
               FETCH recapito_unico_stesso_dal INTO dummy;
               FOUND := recapito_unico_stesso_dal%FOUND;
               CLOSE recapito_unico_stesso_dal;
               IF FOUND
               THEN
                  errno := -20003;
                  errmsg := si4.get_error('A10061') || '(' || tipi_recapito_tpk.get_descrizione (:new.id_tipo_recapito) ||')'; --'Esiste già un record di tipo UNICO con uguale DAL.';
                  RAISE integrity_error;
               END IF;
            END IF;
         EXCEPTION
            WHEN MUTATING
            THEN
               NULL;                    -- Ignora Check su Relazioni Ricorsive
         END;
      END;
   END IF;
   -- rev 1 fine
  IF (INSERTING AND nvl(tipi_recapito_tpk.get_unico(:new.id_tipo_recapito),'NO') ='SI'
--      AND NVL(recapiti_pkg.CONTA_NI_RECAPITI_DAL_ALnonull(:new.ni, :new.id_tipo_recapito, :new.dal, :new.al),0)  >= 1
      AND NVL(recapiti_pkg.CONTA_NI_RECAPITI_DAL_AL(:new.ni, :new.id_tipo_recapito, :new.dal, :new.al),0)  >= 1
      )
   OR (updating AND nvl(tipi_recapito_tpk.get_unico(:new.id_tipo_recapito),'NO') ='SI'
      AND NVL(recapiti_pkg.CONTA_NI_RECAPITI_DAL_AL(:new.ni, :new.id_tipo_recapito, :new.dal, :new.al),0)  > 1)
   THEN
--   raise_application_error(-20999,'RECAPITI errore get dal attuale) ' ||'ni ' || :new.ni ||' id_tipo_recapito:' || :new.id_tipo_recapito || ' dal ' || to_char(:new.dal,'dd/mm/yyyy')|| ' al ' || to_char(:new.al,'dd/mm/yyyy') );
       raise_application_error (-20999,si4.get_error('A10056'));--Impossibile inserire periodo sovrapposto a periodi esistenti
   END IF;
   IF ((updating and :new.dal != :old.dal and :new.dal < trunc(sysdate))
      AND NVL(recapiti_pkg.conta_ni_recapiti_dal_al(:new.ni, :new.id_tipo_recapito, :new.dal, :new.al),0)  > 1
      -- rev.3 inizio
      AND nvl(tipi_recapito_tpk.get_unico(:new.id_tipo_recapito),'NO') ='SI')
      OR ( (inserting and :new.dal < trunc(sysdate))
      AND NVL(recapiti_pkg.conta_ni_recapiti_dal_al(:new.ni, :new.id_tipo_recapito, :new.dal, :new.al),0)  >= 1
      -- rev.3 inizio
      AND nvl(tipi_recapito_tpk.get_unico(:new.id_tipo_recapito),'NO') ='SI')
      -- rev. 3 fine
   THEN
       raise_application_error (-20999,si4.get_error('A10081')|| '(Recapiti)'); --Impossibile indicare data di inizio validita'' inferiore alla data odierna, esistono dati storici.
   END IF;
     IF :new.dal != :old.dal and :new.dal < anagrafici_pkg.get_dal_attuale_ni(:new.ni)
     AND NVL(recapiti_pkg.conta_ni_recapiti(:new.ni, :new.id_tipo_recapito),0)  > 1
     -- se inserimento allora old dal è nullo quindi il diverso torna FALSE
   THEN
--      raise_application_error(-20999,'RECAPITI errore get dal attuale) ' || ' dal ' || to_char(:new.dal,'dd/mm/yyyy') || to_char(anagrafici_pkg.get_dal_attuale_ni(:new.ni),'dd/mm/yyyy'));
       raise_application_error (-20999,si4.get_error('A10082') || '(nuovo dal ' || to_char(:new.dal,'dd/mm/yyyy') ||'<'
         || to_char(anagrafici_pkg.get_dal_attuale_ni(:new.ni),'dd/mm/yyyy')||')'); --Impossibile indicare data di inizio validita'' precedente al dato di riferimento.
   END IF;
   IF UPDATING AND :new.dal < :old.dal
      AND nvl(tipi_recapito_tpk.get_unico(:new.id_tipo_recapito),'NO') ='SI'
      AND NVL(recapiti_pkg.conta_ni_recapiti(:new.ni, :new.id_tipo_recapito),0)  > 1
   THEN
       raise_application_error (-20999,si4.get_error('A10057')); --Impossibile modificare la data di inizio validita'', esistono storicità
   END IF;
   -- rev. 15 inizio
   IF UPDATING
      AND nvl(tipi_recapito_tpk.get_unico(:new.id_tipo_recapito),'NO') ='SI'
      AND NVL(recapiti_pkg.CONTA_NI_RECAPITI_DAL_AL(:new.ni, :new.id_tipo_recapito,:new.dal,null),0)  > 1
   THEN
       raise_application_error (-20999,si4.get_error('A10046'));--Errore: Modifica di registrazione storica non consentita.
   END IF;
   -- rev. 15 fine
       -- si suppone che nel campo NEW viene in realtà passato il
   -- valore OLD
   IF UPDATING
   THEN

-- se il record e' storico modificare il dal potrebbe portare alla
         -- scomparsa di alcuni altri record.
         IF     :OLD.al IS NOT NULL
            AND NVL (:NEW.dal, TO_DATE ('2222222', 'j')) <> :OLD.dal
         THEN
            raise_application_error
               (-20999
              , si4.get_error('A10058'));
         END IF;
      recapiti_pkg.recapiti_pu (:OlD.ID_RECAPITO,
                   :OLD.ni,
                   :OLD.dal,
                   :OLD.provincia,
                   :OLD.comune,
                   :OLD.id_tipo_recapito,
                   :NEW.ID_RECAPITO,
                   :NEW.ni,
                   :NEW.dal,
                   :NEW.provincia,
                   :NEW.comune,
                   :NEW.id_tipo_recapito);
   END IF;
   IF     UPDATING -- storicizzo e non faccio update
   -- rev. 8 inizio
         AND ( NVL (:OLD.competenza_esclusiva, 'xxx') = 'P'
         --OR  substr(NVL (:NEW.competenza, 'xxx'), 1, 2) <> substr(NVL (:OLD.competenza, 'xxx'), 1, 2)
          or (:old.dal < :new.dal))
         AND :NEW.al IS NULL
      THEN
-- se passato tengo quello
         IF :NEW.dal IS NULL OR (:NEW.dal = :OLD.DAL and NVL (:OLD.competenza_esclusiva, 'xxx') = 'P')
   -- rev. 8 fine
         THEN
            :NEW.dal := TRUNC (SYSDATE); --?? VERO????
         END IF;
         IF :new.dal != :old.dal THEN
         -- posso storicizzare
         DECLARE
            a_istruzione                  VARCHAR2 (32000);
            a_messaggio                   VARCHAR2 (2000);
            a_new_NI                     recapiti.NI%TYPE;
            a_new_DAL                    recapiti.DAL%TYPE;
            a_new_AL                     recapiti.AL%TYPE;
            a_new_DESCRIZIONE            recapiti.DESCRIZIONE%TYPE;
            a_new_ID_TIPO_RECAPITO       recapiti.ID_TIPO_RECAPITO%TYPE;
            a_new_INDIRIZZO              recapiti.INDIRIZZO%TYPE;
            a_new_PROVINCIA              recapiti.PROVINCIA%TYPE;
            a_new_COMUNE                 recapiti.COMUNE%TYPE;
            a_new_CAP                    recapiti.CAP%TYPE;
            a_new_PRESSO                 recapiti.PRESSO%TYPE;
            a_new_IMPORTANZA             recapiti.IMPORTANZA%TYPE;
            a_new_COMPETENZA             recapiti.COMPETENZA%TYPE;
            a_new_COMPETENZA_ESCLUSIVA   recapiti.COMPETENZA_ESCLUSIVA%TYPE;
            a_new_UTENTE_AGGIORNAMENTO   recapiti.UTENTE_AGGIORNAMENTO%TYPE;
            a_new_DATA_AGGIORNAMENTO     recapiti.DATA_AGGIORNAMENTO%TYPE;
         BEGIN
            a_new_ni := :NEW.ni;
            if :new.dal = :old.dal then
            a_new_dal := trunc(sysdate);
            else
            a_new_dal := :NEW.dal;
            end if;
            a_new_al := :NEW.al;
            a_new_DESCRIZIONE := REPLACE (:NEW.DESCRIZIONE
                                    , ''''
                                    , ''''''
                                     );
            a_new_ID_TIPO_RECAPITO := :NEW.ID_TIPO_RECAPITO;
            a_new_INDIRIZZO := REPLACE (:NEW.INDIRIZZO
                                 , ''''
                                 , ''''''
                                  );
            a_new_provincia := '' || TO_CHAR (:NEW.provincia) || '';
            a_new_comune := '' || TO_CHAR (:NEW.comune) || '';
            a_new_cap := :OLD.cap;
            a_new_presso := REPLACE (:NEW.presso
                                 , ''''
                                 , ''''''
                                  );
            a_new_IMPORTANZA := :NEW.IMPORTANZA;
            a_new_competenza := :NEW.competenza;
            a_new_competenza_esclusiva := :NEW.competenza_esclusiva;
            a_new_UTENTE_AGGIORNAMENTO := :NEW.UTENTE_AGGIORNAMENTO;
            :new.ni := :old.ni;
            :new.dal := :old.dal;
            :new.al := :old.al;
            :new.DESCRIZIONE := REPLACE (:old.DESCRIZIONE
                                    , ''''
                                    , ''''''
                                     );
            :new.ID_TIPO_RECAPITO := :old.ID_TIPO_RECAPITO;
            :new.INDIRIZZO := REPLACE (:old.INDIRIZZO
                                 , ''''
                                 , ''''''
                                  );
            :new.provincia := '' || TO_CHAR (:old.provincia) || '';
            :new.comune := '' || TO_CHAR (:old.comune) || '';
            :new.cap := :OLD.cap;
            :new.presso := REPLACE (:old.presso
                                 , ''''
                                 , ''''''
                                  );
            :new.IMPORTANZA := :old.IMPORTANZA;
            :new.competenza := :old.competenza;
            :new.competenza_esclusiva := :old.competenza_esclusiva;
            :new.UTENTE_AGGIORNAMENTO := :old.UTENTE_AGGIORNAMENTO;
            a_istruzione :=
                  'begin '|| 'INSERT INTO RECAPITI ('
                   ||' ID_RECAPITO, NI, DAL,'
                   ||' AL, DESCRIZIONE, ID_TIPO_RECAPITO, '
                   ||'  INDIRIZZO, PROVINCIA, COMUNE, '
                   ||' CAP, PRESSO, IMPORTANZA, '
                   ||' COMPETENZA, COMPETENZA_ESCLUSIVA,'
                   ||' UTENTE_AGGIORNAMENTO) '-- non passo version e data_agg
               || '   select  null ,'''
               || a_new_ni
               || ''', to_date('''
               || TO_CHAR (a_new_dal, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy'')'
                || ', to_date('''
               || TO_CHAR (a_new_al, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy''), '''
               || a_new_DESCRIZIONE
               || ''''
               || ', '''
               || a_new_ID_TIPO_RECAPITO
               || ''', '''
               || a_new_indirizzo
               || ''', to_number('''
               || a_new_provincia
               || '''), to_number('''
               || a_new_comune
               || '''), '''
               || a_new_cap
               || ''''
               || ', '''
               || a_new_presso
               || ''',  to_number('''
               || nvl(a_new_importanza,:new.importanza)-- copio dal precedente se non valorizzata ora
               || '''), '''
               || a_new_competenza
               || ''', '''
               || a_new_competenza_esclusiva
               || ''', '''
               || a_new_utente_AGGIORNAMENTO
               || ''''
               || '   from dual'
               || '  where not exists (select 1'
               || '                      from recapiti'
               || '                     where ni = '''
               || a_new_ni
               || '''                      and id_tipo_recapito = '''
               || a_new_ID_TIPO_RECAPITO
               || '''                     and dal = to_date('''
               || TO_CHAR (a_new_dal, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy''))'
               || ' ; '
               || 'end;';
            integritypackage.set_postevent (a_istruzione, a_messaggio);
            IF
            tipi_recapito_tpk.get_unico (:new.ID_TIPO_RECAPITO) != 'SI'
             THEN -- non essendo unico non verrebbe chiuso in automatico
                a_istruzione := ' begin update RECAPITI set al = '
                   || ' to_date('''
                   || TO_CHAR (a_new_dal-1, 'dd/mm/yyyy')
                   || ''',''dd/mm/yyyy'')'
                   || ' where id_recapito = '
                   || :old.id_recapito
                   || ' and id_tipo_recapito = '
                   || :old.ID_TIPO_RECAPITO||'; end;' ;
                integritypackage.set_postevent (a_istruzione, a_messaggio);
           END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               integritypackage.initnestlevel;
               RAISE;
         END;
         else --  :new.dal = :old.dal
         -- NON posso storicizzare
         -- devo provare di aggiornare
          null; -- lascio fare update
         end if;
      END IF;
   /* TOLTI gli automatismi su IMPORTANZA
   rev. 7 inizio
   -- IMPORTANZA (se nulla) copiata dal record precedente se dello stesso tipo e unico
   -- altrimenti dal tipo del contatto
   IF    inserting and  :new.importanza IS NULL
      AND tipi_recapito_tpk.get_unico (:new.ID_TIPO_recapito) = 'SI'
   THEN
      DECLARE
         v_importanza   recapiti.importanza%TYPE;
         CURSOR cpk5_get_importanza (
            var_ni                  VARCHAR,
            var_id_tipo_recapito    VARCHAR)
         IS
            SELECT importanza
              FROM recapiti
             WHERE ni = var_ni
               AND al IS NULL
               AND id_tipo_recapito = Var_id_tipo_recapito;
      -- Check REFERENTIAL Integrity
      BEGIN
         IF :NEW.ni IS NOT NULL AND :NEW.ID_TIPO_recapito IS NOT NULL
         THEN
            OPEN cpk5_get_importanza (:NEW.ni, :NEW.id_tipo_recapito);
            FETCH cpk5_get_importanza INTO v_importanza;
            FOUND := cpk5_get_importanza%FOUND;
            CLOSE cpk5_get_importanza;
            IF FOUND
            THEN
               :new.importanza := v_importanza;
            ELSE                                                -- non trovato
               :new.importanza :=
                  tipi_recapito_tpk.get_importanza (:new.ID_TIPO_recapito);
            END IF;
         END IF;
      EXCEPTION
         WHEN MUTATING
         THEN
            NULL;                       -- Ignora Check su Relazioni Ricorsive
      END;
   END IF;
   rev. 7 fine
   */
   if updating and :new.al is not null then
   -- chiudo anche i contatti collegati
    integritypackage.NextNestLevel;
      update contatti set al = :new.al
       where id_recapito = :old.id_recapito
          and dal < :new.al
          and al is null; -- rev. 10
      integritypackage.PreviousNestlevel;
   end if;
--  rev. 4 Inizio
    -- Consento SOLO modifiche in AVANTI non si toccano i periodi storici
   -- se non per chiudere
   -- rev.2 inizio
   IF    (INSERTING  --AND :NEW.al IS NULL tutti i casi di inserimento anche se inserisco un periodo già chiuso
   )
   -- rev.2 fine
--      OR     (UPDATING AND :OLD.dal < :NEW.dal)
--         AND tipi_recapito_tpk.get_unico (:new.ID_TIPO_RECAPITO) = 'SI'
--   --chiudo il periodo precedente solo se di tipo unico  --???????????????????????????
   THEN
      DECLARE
         a_istruzione   VARCHAR2 (2000);
         a_messaggio    VARCHAR2 (2000);
      BEGIN
         a_messaggio := '';
         a_istruzione :=
               'begin recapiti_pkg.RECAPITI_RRI ('
            || :NEW.ni
            || ', to_date('''
            || TO_CHAR (:NEW.dal, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy''), '
            -- Rev. 9 inizio
            || 'to_date('''
            || TO_CHAR (:NEW.al, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'')'
            || ', '''
            -- Rev. 9 fine
            || :NEW.competenza
            || ''','''
            || :NEW.competenza_esclusiva
            || ''', '
            || :NEW.id_recapito
            || ','
            || :NEW.ID_TIPO_RECAPITO
            || '); end;';
         integritypackage.set_postevent (a_istruzione, a_messaggio);
      EXCEPTION
         WHEN OTHERS
         THEN
            integritypackage.initnestlevel;
            RAISE;
      END;
   END IF;
--  rev. 4 Fine
   --Rev.3 Inizio
    IF :new.importanza is not null THEN
   -- verifico che non esista un record sullo stesso recapito
   -- con la stessa importanza in periodi sovrapposti
     if nvl(:new.importanza,-100) !=  nvl(:old.importanza, -100)
         and :new.importanza is not null then
         DECLARE
         a_istruzione   VARCHAR2 (2000);
         a_messaggio    VARCHAR2 (2000);
         BEGIN
         a_messaggio := '';
         a_istruzione :=
               'begin recapiti_pkg.CHECK_IMPORTANZA_UNIVOCA ('
            || :NEW.id_recapito
            || ', '
            || :NEW.ni
            || ', '''
            || :new.importanza
            || ''', '''
            || :new.id_tipo_recapito
            || ''', to_date('''
            || TO_CHAR (:NEW.dal, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'')'
            || ', to_date('''
            || TO_CHAR (:NEW.al, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'')'
            || '); end;';
--           raise_application_error (-20999,a_istruzione);
          integritypackage.set_postevent (a_istruzione, a_messaggio);
      EXCEPTION
         WHEN OTHERS
         THEN
            integritypackage.initnestlevel;
            RAISE;
      END;
     end if;
     end if;
     -- Rev.3 Fine
EXCEPTION
   WHEN integrity_error
   THEN
      integritypackage.initnestlevel;
      raise_application_error (errno, errmsg,true);
   WHEN OTHERS
   THEN
      integritypackage.initnestlevel;
      RAISE;
END;
/


