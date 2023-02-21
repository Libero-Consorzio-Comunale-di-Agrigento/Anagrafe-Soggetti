CREATE OR REPLACE TRIGGER CONTATTI_TIU
/******************************************************************************
       NOME:        contatti_TIU
       DESCRIZIONE: Trigger for Check DATA Integrity
                                Check REFERENTIAL Integrity
                                  Set REFERENTIAL Integrity
                                  Set FUNCTIONAL Integrity
                             at INSERT or UPDATE on Table contatti
       ECCEZIONI:   -20007, Identificazione CHIAVE presente in TABLE
       ANNOTAZIONI:
       REVISIONI:
       Rev. Data       Autore Descrizione
       ---- ---------- ------ ------------------------------------------------------
                              Prima distribuzione.
          1 06/04/2018 SN     Aggiunto controllo x contatto unico e stessa data decorrenza
          2 12/04/2018 SN     Storicizzo anche se al è valorizzato
          3 31/07/2018 SN     Controllo su importanza univoca.
          4 27/08/2018 SN     NON fare storicizzazioni automatiche
          5 03/09/2018 SN     RIPRISTINATE storicizzazioni automatiche x problemi ad
                              anagrafica orizzontale.
          6 04/09/2018 SNeg   Consentita modifica di dal e al contemporaneamente
          7 11/09/2018 SNeg   Tolti automatismi su importanza
          8 11/09/2018 SNeg   Corrette modalità di storicizzazione
          9 24/09/2018 SNeg   Protezioni apici in check_univoco
         10 01/04/2019 SNeg  Chiusura solo di record ancora aperti
         11 09/04/2019 SNeg  Gestione errore in caso di id_tipo_recapito nullo
         12 29/10/2019 SNeg   Se in trasco non aggiornare la data di aggiornamento Bug #37304
         13 05/11/2019 SNeg   Prima chiudere il contatto poi inserire il record nuovo Bug #38025
         14 23/11/2020 SNeg  Impedire aggiornamento di dati storici Bug #34914
      ******************************************************************************/
   BEFORE INSERT OR UPDATE
   ON CONTATTI    FOR EACH ROW
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
   v_new_al date := :new.al;
   v_livello number := integritypackage.getnestlevel;
BEGIN
--dbms_output.put_line(integritypackage.getnestlevel);
--if inserting then
--dbms_output.put_line('CONTATTI **INS** ' || :new.dal ||':' || :new.id_tipo_contatto||':' || :new.al||':' || :new.id_contatto);
--else
--dbms_output.put_line('CONTATTI **UPD** ' || :new.dal||':' || :new.id_tipo_contatto||':' || :new.al||':' || :new.id_contatto||':' || :old.dal);
--end if;
  if nvl(anagrafici_pkg.trasco,0) = 1 then -- rev. 12
   :new.data_aggiornamento := sysdate;
  end if;
   :new.utente_aggiornamento := nvl(:new.utente_aggiornamento,si4.utente);
   :new.valore := trim(:new.valore); -- tolgo spazi prima e dopo
--   raise_application_error (-20999,'new comp ' || :new.competenza);
--raise_application_error (-20999, 'id_tipo_contatto=' || :old.id_tipo_contatto || ' NEW=' || :new.id_tipo_contatto);

   IF :new.importanza <= 0
   THEN
       raise_application_error (-20999,si4.get_error('A00092') ||'(contatti)'); --Il valore deve essere maggiore di 0.
   END IF;

    IF :new.id_tipo_contatto is null then
       raise_application_error(-20999, si4.get_error('A10088') || ' (VALORE x campo Tipo Contatto)' );
    end if;

    IF :new.valore is null then
       raise_application_error(-20999, si4.get_error('A10088') || ' (VALORE x ' || tipi_contatto_tpk.get_descrizione(:new.id_tipo_contatto)||' )');
    end if;

    IF :new.dal > nvl(:new.al, to_date('3333333','j'))
         THEN
--          raise_application_error (-20999, 'contatto=' || :new.id_contatto || ' NEW dall=' || :new.dal|| ' NEW al=' || :new.al);
         -- Non possono avere dal minore di al
           raise_application_error
                               (-20999
                              ,   si4.get_error('A10070' || ' (contatto '||:new.id_contatto||':dal=' || :new.dal|| ' al=' || :new.al||')') -- 'Impossibile indicare una data fine inferiore alla data inizio.
                              );
       END IF;



      -- tolto x provare se è tutto ok
--    IF updating and :new.dal != :old.dal
--                and NVL (:NEW.al, TO_DATE ('3333333', 'j')) != NVL (:old.al, TO_DATE ('3333333', 'j'))
--         THEN
--         -- errore probabilmente il record era stato cambiato da qualcun altro
--           raise_application_error
--                               (-20999
--                              ,    si4.get_error('A10060')-- 'Impossibile cambiare contemporaneamente dal e al'
--                              );
--       END IF;


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

--   DECLARE
--      --  Declaration of UpdateParentRestrict constraint for "TIPI_CONTATTO"
--      CURSOR cpk4_tipo_contatto (
--         var_id_tipo_contatto    VARCHAR)
--      IS
--         SELECT 1
--           FROM TIPI_CONTATTO
--          WHERE id_tipo_contatto = var_id_tipo_contatto
--            AND var_id_tipo_contatto IS NOT NULL;
--   BEGIN                                        -- Check REFERENTIAL Integrity
--      BEGIN --  Parent "TIPI_CONTATTO" deve esistere quando si modifica "CONTATTI"
----         IF :NEW.id_tipo_contatto IS NOT NULL
----         THEN
--            OPEN cpk4_tipo_contatto (:NEW.Id_tipo_contatto);
--
--            FETCH cpk4_tipo_contatto INTO dummy;
--
--            FOUND := cpk4_tipo_contatto%FOUND;
--
--            CLOSE cpk4_tipo_contatto;
--
--            IF NOT FOUND
--            THEN
--               errno := -20003;
--               errmsg := si4.get_error('A10052')
--                         ||' La registrazione non e'' modificabile.';
----                  'Non esiste riferimento su Tipi contatti. La registrazione non e'' modificabile.';
--               RAISE integrity_error;
--            END IF;
----         END IF;
--      EXCEPTION
--         WHEN MUTATING
--         THEN
--            NULL;                       -- Ignora Check su Relazioni Ricorsive
--      END;
--   END;


   BEGIN                    -- Check REFERENTIAL Integrity on INSERT or UPDATE
      IF UPDATING
      THEN
         DECLARE
            v_oggetto         xx4_contatti.oggetto%TYPE;
            v_motivo_blocco   xx4_contatti.motivo_blocco%TYPE;

            --  Declaration of UpdateParentRestrict constraint for "XX4_contatti"
            CURSOR cfk1_contatti (
               var_id_contatto    NUMBER,
               var_dal            DATE)
            IS
               SELECT oggetto, motivo_blocco
                 FROM XX4_contatti
                WHERE     id_contatto = var_id_contatto
                      AND var_id_contatto IS NOT NULL
                      AND dal >= var_dal
                      AND var_dal IS NOT NULL;
         BEGIN                                  -- Check REFERENTIAL Integrity
            --  Informazioni in "contatti" non modificabili se esistono referenze su "XX4_contatti"
            OPEN cfk1_contatti (:OLD.id_contatto, SYSDATE);

            FETCH cfk1_contatti INTO V_oggetto, V_motivo_blocco;

            FOUND := cfk1_contatti%FOUND;

            CLOSE cfk1_contatti;

            IF FOUND
            THEN
               IF (V_motivo_blocco = 'R')
               THEN
                  errno := -20005;
                  errmsg := si4.get_error('A10043')
                     ||
--                        'Esistono riferimenti su Contatti'
                        ' ('
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

   IF INSERTING
   THEN
      contatti_pkg.contatti_pi (:OLD.id_contatto,
                   :OLD.id_recapito,
                   :OLD.dal,
                   :OLD.id_tipo_contatto,
                   :NEW.id_contatto,
                   :NEW.id_recapito,
                   :NEW.dal,
                   :NEW.id_tipo_contatto);

      IF integritypackage.getnestlevel = 0
      THEN
         DECLARE
            --  Check UNIQUE PK Integrity per la tabella "contatti"
            CURSOR cpk_contatti (p_id_contatto NUMBER)
            IS
               SELECT 1
                 FROM contatti
                WHERE id_contatto = p_id_contatto;

            mutating   EXCEPTION;
            PRAGMA EXCEPTION_INIT (mutating, -4091);
         BEGIN                 -- Check UNIQUE Integrity on PK of "ANAGRAFICI"
            IF :NEW.id_contatto IS NOT NULL AND :NEW.dal IS NOT NULL
            THEN
               OPEN cpk_contatti (:NEW.id_contatto);

               FETCH cpk_contatti INTO dummy;

               FOUND := cpk_contatti%FOUND;

               CLOSE cpk_contatti;

               IF FOUND
               THEN
                  errno := -20007;
                  errmsg := si4.get_error('A10064')
--                        'Identificazione "'
--                     || :NEW.id_contatto
--                     || '" gia'' presente in contatti. La registrazione  non puo'' essere inserita.';
                     ||' in contatti('|| :NEW.id_contatto||'). La registrazione  non puo'' essere inserita.';
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



   IF INSERTING AND :NEW.ID_contatto IS NULL
   THEN
      SELECT CONT_sq.NEXTVAL INTO :NEW.ID_contatto FROM DUAL;
   END IF;


   -- si suppone che nel campo NEW viene in realtà passato il
   -- valore OLD
   IF UPDATING
   THEN
--      IF :new.version IS NULL OR :old.version = :new.version
--      THEN
--         :new.version := :old.version + 1;
--      ELSE
--         -- errore probabilmente il record era stato cambiato da qualcun altro
--         raise_application_error (
--            -20999,
--            'Record cambiato dall''ultima lettura: Version attuale non compatibile con quella indicata ');
--      END IF;

      --????????????????????????????????????????????????????
         -- se il record e' storico modificare il dal potrebbe portare alla
         -- scomparsa di alcuni altri record.
         IF     :OLD.al IS NOT NULL
            AND NVL (:NEW.dal, TO_DATE ('2222222', 'j')) <> :OLD.dal
         THEN
            raise_application_error
               (-20999
              , si4.get_error('A10058')|| '(Contatti)'); --Impossibile aggiornare la data di inizio validita'' di un record storico.
         END IF;

      contatti_pkg.contatti_pu (:OLD.id_contatto,
                   :OLD.id_recapito,
                   :OLD.dal,
                   :OLD.id_tipo_contatto,
                   :NEW.id_contatto,
                   :NEW.id_recapito,
                   :NEW.dal,
                   :NEW.id_tipo_contatto);
   END IF;

   -- CONTROLLARE x RECAPITI UNICI che non ci sia già presente un record


   IF  tipi_contatto_tpk.get_unico (:new.ID_TIPO_CONTATTO) = 'SI'
   -- rev 1 inizio aggiunti controlli
      and (inserting )
   -- rev 1 fine
   THEN
      -- Non posso inserire un nuovo record di tipo unico
      -- con lo stesso dal di uno esistente
      DECLARE
         CURSOR cpk5_contatto_unico_stesso_dal (var_id_recapito    VARCHAR,
                                                var_dal            DATE)
         IS
            SELECT 1
              FROM contatti
             WHERE id_contatto = var_id_recapito AND dal = var_dal;
      BEGIN                                     -- Check REFERENTIAL Integrity
         BEGIN --  Parent "TIPI_CONTATTO" deve esistere quando si modifica "ANAGRAFICI"
            IF :NEW.id_contatto IS NOT NULL
            THEN
               OPEN cpk5_contatto_unico_stesso_dal (:NEW.Id_recapito,
                                                    :NEW.dal);

               FETCH cpk5_contatto_unico_stesso_dal INTO dummy;

               FOUND := cpk5_contatto_unico_stesso_dal%FOUND;

               CLOSE cpk5_contatto_unico_stesso_dal;

               IF FOUND
               THEN
                  errno := -20003;
                  errmsg := si4.get_error('A10061') || '(' || tipi_contatto_tpk.get_descrizione (:new.ID_TIPO_CONTATTO) ||')'; --'Esiste già un record di tipo UNICO con uguale DAL.';
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
   declare
   v_conta number  ;
   begin
   v_conta := NVL(contatti_pkg.conta_recap_contatti(:new.id_recapito, :new.id_tipo_contatto ),0);
   end;
   IF ((updating and :new.dal != :old.dal and :new.dal < trunc(sysdate))
      AND NVL(contatti_pkg.conta_recap_contatti_dal_al(:new.id_recapito, :new.id_tipo_contatto, :new.dal, :new.al),0)  > 1)
      OR ((inserting and :new.dal < trunc(sysdate))
      AND NVL(contatti_pkg.conta_recap_contatti_dal_al(:new.id_recapito, :new.id_tipo_contatto, :new.dal, :new.al),0)  >= 1)
--      AND NVL(contatti_pkg.conta_recap_contatti(:new.id_recapito, :new.id_tipo_contatto ),0)  > 1 questo blocca sempre
-- invece considerato il caso in cui la data andrebbe a sovrapporsi con uno dello stesso tipo e unico
   THEN
       raise_application_error (-20999,si4.get_error('A10081')|| '(Contatti)'); --Impossibile indicare data di inizio validita'' inferiore alla data odierna, esistono dati storici.
   END IF;

   IF :new.dal != :old.dal and :new.dal < recapiti_pkg.GET_DAL_ATTUALE_ID_RECAPITO(:new.id_recapito)
      AND NVL(contatti_pkg.conta_recap_contatti(:new.id_recapito, :new.id_tipo_contatto ),0)  > 1
     -- se inserimento allora old dal è nullo quindi il diverso torna FALSE
   THEN
--   raise_application_error(-20999,'CONTATTI errore get dal attuale) '|| ' dal ' || to_char(:new.dal,'dd/mm/yyyy') || to_char(recapiti_pkg.GET_DAL_ATTUALE_ID_RECAPITO(:new.id_recapito),'dd/mm/yyyy') );

       raise_application_error (-20999,si4.get_error('A10082')); --Impossibile indicare data di inizio validita'' precedente al dato di riferimento.
   END IF;

   IF UPDATING AND :new.dal < :old.dal
      AND tipi_contatto_tpk.get_unico (:new.ID_TIPO_CONTATTO) = 'SI'
      AND NVL(contatti_pkg.conta_recap_contatti_dal_al(:new.id_recapito, :new.id_tipo_contatto, :new.dal, :new.al),0)  > 1
--      AND NVL(contatti_pkg.conta_recap_contatti(:new.id_recapito, :new.id_tipo_contatto ),0)  > 1 questo blocca sempre
-- invece considerato il caso in cui la data andrebbe a sovrapporsi con uno dello stesso tipo e unico
   THEN
       raise_application_error (-20999,si4.get_error('A10057')); --Impossibile modificare la data di inizio validita'', esistono storicità
   END IF;


   IF INSERTING
      AND nvl(tipi_contatto_tpk.get_unico(:new.id_tipo_contatto),'NO') ='SI'
      AND  NVL(contatti_pkg.conta_recap_contatti_dal_al(:new.id_recapito, :new.id_tipo_contatto, :new.dal, :new.al),0)  >= 1
   THEN
       raise_application_error (-20999,si4.get_error('A10056')||':' || :new.id_recapito||':' || :new.id_tipo_contatto||':' || :new.dal||':' || :new.al); --Impossibile inserire periodo sovrapposto a periodi esistenti
   END IF;


   -- rev. 14 inizio
   IF UPDATING
      AND nvl(tipi_contatto_tpk.get_unico(:new.id_tipo_contatto),'NO') ='SI'
      AND NVL(contatti_pkg.CONTA_RECAP_CONTATTI_DAL_AL (:new.id_recapito, :new.id_tipo_contatto,:new.dal,null),0)  > 1
   THEN
       raise_application_error (-20999,si4.get_error('A10046'));--Errore: Modifica di registrazione storica non consentita.
   END IF;
   -- rev. 14 fine


   IF     UPDATING -- storicizzo e non faccio update
   -- rev. 8 inizio
         AND (NVL (:OLD.competenza_esclusiva, 'xxx') = 'P'
--         OR  substr(NVL (:NEW.competenza, 'xxx'), 1, 2) <> substr(NVL (:OLD.competenza, 'xxx'), 1, 2)
          or (:old.dal < :new.dal))
         AND :NEW.al IS NULL
   THEN
        declare
        d_new_dal date := :new.dal;
        d_new_al date := :new.al;
        d_old_dal date := :old.dal;
        d_old_al date := :old.al;
        begin
        null;
        end;
      -- se passata tengo la data indicata
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
            a_new_ID_RECAPITO            CONTATTI.ID_RECAPITO%TYPE;
            a_new_DAL                    CONTATTI.DAL%TYPE;
            a_new_AL                     CONTATTI.AL%TYPE;
            a_new_valore                 CONTATTI.valore%TYPE;
            a_new_ID_TIPO_contattO       CONTATTI.ID_TIPO_contattO%TYPE;
            a_new_note                   CONTATTI.note%TYPE;
            a_new_IMPORTANZA             CONTATTI.IMPORTANZA%TYPE;
            a_new_COMPETENZA             CONTATTI.COMPETENZA%TYPE;
            a_new_COMPETENZA_ESCLUSIVA   CONTATTI.COMPETENZA_ESCLUSIVA%TYPE;
            a_new_UTENTE_AGGIORNAMENTO   CONTATTI.UTENTE_AGGIORNAMENTO%TYPE;
            a_new_DATA_AGGIORNAMENTO     CONTATTI.DATA_AGGIORNAMENTO%TYPE;
         BEGIN
            a_new_ID_RECAPITO := :NEW.ID_RECAPITO;
            a_new_dal := :NEW.dal;
            a_new_al := :NEW.al;
            a_new_valore := REPLACE (:NEW.valore
                                    , ''''
                                    , ''''''
                                     );
            a_new_ID_TIPO_contattO := :NEW.ID_TIPO_contattO;
            a_new_note := REPLACE (:NEW.note
                                 , ''''
                                 , ''''''
                                  );
            a_new_IMPORTANZA := :NEW.IMPORTANZA;
            a_new_competenza := :NEW.competenza;
            a_new_competenza_esclusiva := :NEW.competenza_esclusiva;
            a_new_UTENTE_AGGIORNAMENTO := :NEW.UTENTE_AGGIORNAMENTO;
            :new.ID_RECAPITO := :old.ID_RECAPITO;
            :new.dal := :old.dal;
            :new.al := :old.al;
            :new.valore := REPLACE (:old.valore
                                    , ''''
                                    , ''''''
                                     );
            :new.ID_TIPO_contattO := :old.ID_TIPO_contattO;
            :new.note := REPLACE (:old.note
                                 , ''''
                                 , ''''''
                                  );
            :new.IMPORTANZA := :old.IMPORTANZA;
            :new.competenza := :old.competenza;
            :new.competenza_esclusiva := :old.competenza_esclusiva;
            :new.UTENTE_AGGIORNAMENTO := :old.UTENTE_AGGIORNAMENTO;
            :NEW.UTENTE_AGGIORNAMENTO := :OLD.UTENTE_AGGIORNAMENTO;
            :NEW.DATA_AGGIORNAMENTO := :OLD.DATA_AGGIORNAMENTO;
            -- rev. 13 inizio prima chiudo il contatto precedente
            IF tipi_contatto_tpk.get_unico (:new.ID_TIPO_CONTATTO) != 'SI'
             THEN -- non essendo unico non verrebbe chiuso in automatico
                a_istruzione := ' begin update contatti set al = '
                   || ' to_date('''
                   || TO_CHAR (a_new_dal-1, 'dd/mm/yyyy')
                   || ''',''dd/mm/yyyy'')'
                   || ' where id_contatto = '
                   || :old.id_contatto
                   || ' and id_tipo_contatto = '
                   || :old.ID_TIPO_CONTATTO
                   || ' and al is null '
                   ||'; end;' ;
                integritypackage.set_postevent (a_istruzione, a_messaggio);
           END IF;

            -- rev. 13 fine prima chiudo il contatto precedente
            a_istruzione :=
                  'begin '|| 'INSERT INTO CONTATTI ('
                   ||' id_contatto,ID_RECAPITO, DAL,'
                   ||' AL, VALORE, ID_TIPO_CONTATTO, '
                   ||' NOTE, IMPORTANZA, '
                   ||' COMPETENZA, COMPETENZA_ESCLUSIVA,'
                   ||' UTENTE_AGGIORNAMENTO) '-- non passo version e data_agg
                || '   select  null /* id_contatto */,'''
               || a_new_ID_RECAPITO
               || ''', to_date('''
               || TO_CHAR (a_new_dal, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy'')'
                || ', to_date('''
               || TO_CHAR (a_new_al, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy''), '''
               || a_new_VALORE
               || ''''
               || ', '''
               || a_new_ID_TIPO_CONTATTO
               || ''', '''
               || a_new_NOTE
               || ''', to_number('''
               || nvl(a_new_IMPORTANZA, :new.importanza) -- copio dal precedente se non valorizzata ora
               || '''), '''
               || a_new_competenza
               || ''', '''
               || a_new_competenza_esclusiva
               || ''', '''
               || a_new_utente_AGGIORNAMENTO
               || ''''
               || '   from dual'
               || '  where not exists (select 1'
               || '                      from CONTATTI'
               || '                     where ID_RECAPITO = '''
               || a_new_ID_RECAPITO
               || '''                      and id_tipo_contatto = '''
               || a_new_ID_TIPO_CONTATTO
               || '''                      and dal = to_date('''
               || TO_CHAR (a_new_dal, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy''))'
               || ' ; '
               || 'end;';
            integritypackage.set_postevent (a_istruzione, a_messaggio);

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
   IF   inserting and  :new.importanza IS NULL
      AND tipi_contatto_tpk.get_unico (:new.ID_TIPO_CONTATTO) = 'SI'
   THEN
      DECLARE
         v_importanza   contatti.importanza%TYPE;

         CURSOR cpk5_get_importanza (
            var_id_recapito         VARCHAR,
            var_id_tipo_contatto    VARCHAR)
         IS
            SELECT importanza
              FROM contatti
             WHERE     id_contatto = var_id_recapito
                   AND al IS NULL
                   AND id_tipo_contatto = Var_id_tipo_contatto;
      -- Check REFERENTIAL Integrity
      BEGIN
         IF     :NEW.id_recapito IS NOT NULL
            AND :NEW.ID_TIPO_CONTATTO IS NOT NULL
         THEN
            OPEN cpk5_get_importanza (:NEW.Id_recapito, :NEW.id_tipo_contatto);

            FETCH cpk5_get_importanza INTO v_importanza;

            FOUND := cpk5_get_importanza%FOUND;

            CLOSE cpk5_get_importanza;

            IF FOUND
            THEN
               :new.importanza := v_importanza;
            ELSE                                                -- non trovato
               :new.importanza :=
                  tipi_contatto_tpk.get_importanza (:new.ID_TIPO_CONTATTO);
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

   -- Consento SOLO modifiche in AVANTI non si toccano i periodi storici
   -- se non per chiudere
   -- rev.2 inizio
   IF    (INSERTING  --AND :NEW.al IS NULL tutti i casi di inserimento anche se inserisco un periodo già chiuso
   )
   -- rev.2 fine
--      OR     (UPDATING AND :OLD.dal < :NEW.dal
--         AND tipi_contatto_tpk.get_unico (:new.ID_TIPO_CONTATTO) = 'SI') --???????????????????????????????????????
--   -- se tipo_contatto è unico chiudo il precedente
--   -- ricopio importanza dal record precedente (?)
   THEN
      DECLARE
         a_istruzione   VARCHAR2 (2000);
         a_messaggio    VARCHAR2 (2000);
      BEGIN
         a_messaggio := '';
         a_istruzione :=
               'begin contatti_pkg.contatti_RRI ('
            || :NEW.id_recapito
            || ', to_date('''
            || TO_CHAR (:NEW.dal, 'dd/mm/yyyy')                      --?? data
            || ''',''dd/mm/yyyy''), '''                              --?? data
            || :NEW.competenza
            || ''', '''
            || :NEW.competenza_esclusiva                   -- aggiunta  rev 12
            || ''', '''                                     -- aggiunta rev 12
            || :NEW.ID_TIPO_contatto
            || '''); end;';
         integritypackage.set_postevent (a_istruzione, a_messaggio);
      EXCEPTION
         WHEN OTHERS
         THEN
            integritypackage.initnestlevel;
            RAISE;
      END;
   END IF;

   IF :new.valore is not null THEN
   -- verifico che non esista un record sullo stesso recapito
   -- con lo stesso valore in periodi sovrapposti
     if nvl(:new.valore,'XX') !=  nvl(:old.valore,'XX')
         and :new.valore is not null then
         DECLARE
         a_istruzione   VARCHAR2 (2000);
         a_messaggio    VARCHAR2 (2000);
         BEGIN
         a_messaggio := '';
         a_istruzione :=
               'begin contatti_pkg.CHECK_CONTATTO_UNIVOCO ('
            || :NEW.id_contatto
            || ', '
            || :NEW.id_recapito
            || ', '''
            ||  REPLACE (:NEW.valore
                                    , ''''
                                    , ''''''
                                     )
            || ''', '''
            || :new.id_tipo_contatto
            || ''', to_date('''
            || TO_CHAR (:NEW.dal, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'')'
            || ', to_date('''
            || TO_CHAR (:NEW.al, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'')'
            || '); end;';
--          raise_application_error (-20999,a_istruzione);
          integritypackage.set_postevent (a_istruzione, a_messaggio);
      EXCEPTION
         WHEN OTHERS
         THEN
            integritypackage.initnestlevel;
            RAISE;
      END;
     end if;

   --upper(translate (nvl(P_INDIRIZZO,'Y'),'a/- _','a'))
   END IF;

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
               'begin contatti_pkg.CHECK_IMPORTANZA_UNIVOCA ('
            || :NEW.id_contatto
            || ', '
            || :NEW.id_recapito
            || ', '''
            || :new.importanza
            || ''', '''
            || :new.id_tipo_contatto
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
     -- Rev.3 Fine

   --upper(translate (nvl(P_INDIRIZZO,'Y'),'a/- _','a'))
   END IF;

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
/


