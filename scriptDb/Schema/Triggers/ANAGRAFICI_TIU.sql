CREATE OR REPLACE TRIGGER ANAGRAFICI_TIU
/******************************************************************************
 NOME:        ANAGRAFICI_TIU
 DESCRIZIONE: Trigger for Check DATA Integrity
                          Check REFERENTIAL Integrity
                            Set REFERENTIAL Integrity
                            Set FUNCTIONAL Integrity
                       at INSERT or UPDATE on Table ANAGRAFICI
 ECCEZIONI:   -20007, Identificazione CHIAVE presente in TABLE
 ANNOTAZIONI: Richiama Procedure ANAGRAFICI_PI
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
                         distribuzione.
 1    07/03/2018  SNeg  Verificare in alternativa codice_fiscale/codice_fiscale estero
                        e partita_iva/partita_iva_cee
 2    12/03/2018  SNeg  Se la funzione is_da_storicizzare torna 0 non devo storicizzare.
 3    17/05/2018  SNeg  La chiusura puo essere al giorno precedente
 4    30/05/2018  SNeg  Forzo la data di oggi solo se competenza P oppure E altrimenti
                        tengo la data impostata
 5    11/07/2018  SNeg Controllo sul dal in coda al trigger per consentire i default
 6    25/07/2018  SNeg Modificare partita iva anche se soggetto di competenza esclusiva di
                       SI4SO.
 7    04/09/2018  SNeg Consentita modifica di dal e al contemporaneamente
 8    26/03/2019  SNeg Recupero note se soggetto di Struttura Organizzativa (AMM,AOO o UO)
 9    04/04/2019  SNeg Ammesso cambio partita iva se soggetto in struttura e priorita del progetto valorizzata Bug #34207
 10  12/04/2019  SNeg  Correzione verifiche x storicizzazione automatica Bug #34384
 11   29/10/2019 SNeg  Se in trasco non aggiornare la data di aggiornamento Bug #37304
 12   05/11/2019 SNeg  Verificare competenza_esclusiva (non competenza) Bug #38025
 13   11/11/2019 SNeg  Se posticipo il dal da interfaccia bisogna storicizzare Bug #38231
 14   17/12/2019 SNeg  Il codice fiscale, la partita iva e gli esteri non devono contenere spazi. Bug #39296
 15   17/12/2019 SNeg  Se chiude automaticamente un record deve aggiornare utente modifica.Bug #39293
 16   27/01/2019 SNeg  Prima di verificare se cognome valorizzato sistemarlo in base alla denominazione. Bug #40181
 17   30/01/2020 SNeg  Errore in aggiornamento Anagrafica con solo comune o solo provincia nascita Bug #39664
 18   20/11/2020 SNeg  Impedire aggiornamento di dati storici Bug #34914
 19   26/04/2021 Sneg  usare sempre denominazione_ricerca x prestazioni Bug #48865
 20   18/05/2021 MMON  Feature #50445
 21   01/09/2021 MMon  Issue #51316 #53987 Correzione DENOMINAZIONE_RICERCA
******************************************************************************/
   BEFORE INSERT OR UPDATE
   ON ANAGRAFICI    FOR EACH ROW
DECLARE
   integrity_error    EXCEPTION;
   errno             INTEGER;
   errmsg            CHAR (200);
   dummy             INTEGER;
   FOUND             BOOLEAN;
   d_result          AFC_Error.t_error_number;
   v_ni_e_soggetto_struttura NUMBER := anagrafici_pkg.controllo_se_ni_in_struttura (:new.ni);
   d_denominazione_ricerca anagrafici.denominazione_ricerca%type;  --#51316
   d_tipo_entita     varchar2(3);
   d_codice_ipa      varchar2(200);  --#60726
BEGIN
  --per i soggetti di SO, ridetermina il campo denominazione_ricerca  --#51316 #54239
  if (anagrafici_pkg.controllo_se_ni_in_struttura (:new.ni) >= 1)and not deleting then
     --verifico il tipo di oggetto
     execute immediate 'select tipo_entita from so4_soggetti_struttura '||
                       ' where ni = '||:new.ni
     into d_tipo_entita;

     if d_tipo_entita = 'AO' then d_tipo_entita := 'AOO'; end if;

     /*if inserting then --#53987 #54239
        execute immediate 'select as4so4_pkg.get_denominazione_amm(SUBSTR('||afc.quote(:new.NOTE)||',1,INSTR('||afc.quote(:new.NOTE)||','':'')-1))'||'||'||afc.quote(':')||'||'||afc.quote(d_tipo_entita)||'||'':''||'||afc.quote(nvl(:new.denominazione,:new.cognome))||' from dual'
        into d_denominazione_ricerca;
     elsif updating then
        execute immediate 'select as4so4_pkg.get_denominazione_amm(SUBSTR('||afc.quote(:new.NOTE)||',1,INSTR('||afc.quote(:new.NOTE)||','':'')-1))'||'||'||afc.quote(':')||'||'||afc.quote(d_tipo_entita)||'||'':''||'||afc.quote(nvl(:new.cognome,:new.denominazione))||' from dual'
        into d_denominazione_ricerca;
     end if;*/
     --#60726
     d_codice_ipa := SUBSTR(:new.NOTE,1,INSTR(:new.NOTE,':')-1);
     begin
        execute immediate 'select max(denominazione) from so4_amministrazioni a,anagrafe_soggetti_table s where codice_amministrazione = upper('||d_codice_ipa||') and a.ni=s.ni'
        into d_denominazione_ricerca;
--        select max(denominazione)
--          into d_denominazione_ricerca
--          from so4_amministrazioni a,anagrafe_soggetti_table s
--         where codice_amministrazione = upper(d_codice_ipa)
--           and a.ni=s.ni
--          ;
     exception
        when others then
           null;
     end;
     d_denominazione_ricerca := d_denominazione_ricerca||':'||d_tipo_entita||':'||:new.cognome;
  end if;

  -- rev. 14 inizio
     :new.CODICE_FISCALE := translate(:new.CODICE_FISCALE,'a ','a');
     :new.CODICE_FISCALE_ESTERO:= translate(:new.CODICE_FISCALE_ESTERO,'a ','a');
     :new.PARTITA_IVA:= translate(:new.PARTITA_IVA,'a ','a');
     :new.PARTITA_IVA_CEE:= translate(:new.PARTITA_IVA_CEE,'a ','a');
  -- rev. 14 fine
  -- rev. 16 inizio
  DECLARE                    -- Allineamento  Cognome Nome e Denominazione
         d_pointer   NUMBER;
         d_nome      varchar2(2000) := :NEW.nome;
      BEGIN
         :NEW.cognome := RTRIM (:NEW.cognome);
         :NEW.nome := RTRIM (:NEW.nome);
         IF (:NEW.cognome || '  ' || :NEW.nome <>
                                             :OLD.cognome || '  '
                                             || :OLD.nome
            and :new.cognome is not null)
            or :new.denominazione  is null -- se nulla la valorizzo
         THEN
            IF d_nome IS NOT NULL THEN
               d_nome := '  '|| d_nome;
            END IF;
            :NEW.denominazione := :NEW.cognome || d_nome; --#50445
        ELSE
            IF NVL (:NEW.denominazione, ' ') <> NVL (:OLD.denominazione, ' ')
            or  (:NEW.denominazione is not null and :new.cognome is  null) -- passata denominazione e non il cognome, nome
            THEN
               d_pointer := INSTR (:NEW.denominazione, '  ');
               IF d_pointer = 0
               THEN
                  :NEW.cognome := RTRIM (:NEW.denominazione);
                  :NEW.nome := NULL;
               ELSE
                  :NEW.cognome :=
                        RTRIM (SUBSTR (:NEW.denominazione
                                     , 1
                                     , d_pointer - 1
                                      ));
                  :NEW.nome :=
                            RTRIM (SUBSTR (:NEW.denominazione, d_pointer + 2));
               END IF;
            END IF;
         END IF;
      END;
      -- rev. 16 fine
   IF :new.COGNOME is null then
       raise_application_error(-20999, si4.get_error('A10088') || ' (COGNOME)');
    end if;

-- Rev. 3 inizio
    if updating and
    (
     (trunc(sysdate -1 ) not between :new.dal and nvl(:new.al,to_date('3333333','j') )  and :new.dal <= trunc(sysdate-1))
     OR
     (trunc(sysdate) not between :new.dal and nvl(:new.al,to_date('3333333','j') )  and :new.dal > trunc(sysdate-1))
     )
    -- Rev. 3 fine
       and nvl(:old.competenza_esclusiva,'X') = 'P' then
       raise_application_error (-20999, si4.get_error('A10005') --Data di fine validita anagrafica inferiore a data decorrenza registrazione
        ||' Competenza bloccante ' || :old.competenza_esclusiva  || ' del progetto ' || :old.competenza );
    end if;
    if nvl(anagrafici_pkg.trasco,0) = 1 then -- rev. 11
       :new.data_agg := sysdate;
    end if;
    :new.utente := nvl(:new.utente,si4.utente);
    :new.nome := upper(:new.nome);
    :new.cognome := upper(:new.cognome);
    :new.denominazione := upper(:new.denominazione);
    :new.codice_fiscale := upper(:new.codice_fiscale);
    if nvl(length(:new.codice_fiscale),0) > 16 then
       raise_application_error
                               (-20999
                              ,   si4.get_error('A10006')  || ' massimo 16 caratteri' -- Codice Fiscale Errato
                              );
    end if;
       IF :new.dal > nvl(:new.al, to_date('3333333','j'))
         THEN
         -- Non possono avere dal minore di al
           raise_application_error
                               (-20999
                              ,   si4.get_error('A10070') -- Impossibile indicare una data fine inferiore alla data inizio.
                              );
       END IF;


   -- verifica di versione coerente x poter modificare con grails
   -- e controllare che il record non sia stato nel frattempo
   -- modificato da qualcun altro (consistenza)
   -- si suppone che nel campo NEW viene in realtà passato il
   -- valore OLD
--   IF UPDATING THEN
       IF updating and (:new.version IS NULL OR :old.version = :new.version)
         THEN
        :new.version := nvl(:old.version,0)+1;
       ELSIF inserting
         THEN
         :new.version := 0;
       ELSE
         -- errore probabilmente il record era stato cambiato da qualcun altro
           raise_application_error
                               (-20999
                              ,    si4.get_error('A10059')--Record cambiato dallultima lettura: Version attuale non compatibile con quella indicata
                              );
       END IF;
--    END IF;
   BEGIN                          -- Check DATA Integrity on INSERT or UPDATE
-- Rev. 6 inizio
     if updating --and :old.competenza = 'SI4SO' and :new.competenza != 'SI4SO' -- rev.9
                     -- and :old.competenza_esclusiva = 'E' -- rev.9
                      and v_ni_e_soggetto_struttura > 0
                      and nvl(:old.partita_iva,'-99') != nvl(:new.partita_iva,'-99')
                      and ad4_progetti_tpk.exists_id(:new.competenza) = 1
                      and ad4_progetti_tpk.get_priorita(:new.competenza) is not null -- gestita la priorita quindi in qualche modo abilitato a lavorare sui soggetti -- rev.9
                       -- il resto dei campi non cambia
                      and :old.dal = :new.dal
                      and :old.ni = :NEW.ni
                      and :old.cognome = :new.cognome
                      and nvl(:old.nome,'x') = nvl(:new.nome,'x')
                      and nvl(:old.sesso ,'-5') = nvl(:new.sesso                                    ,'-5')
                      and nvl(:old.data_nas ,trunc(sysdate) +10000) = nvl(:new.data_nas                              ,trunc(sysdate) +10000)
                      and nvl(:old.provincia_nas ,'-5') = nvl(:new.provincia_nas                    ,'-5')
                      and nvl(:old.comune_nas ,'-5') = nvl(:new.comune_nas                          ,'-5')
                      and nvl(:old.luogo_nas ,'-5') = nvl(:new.luogo_nas                            ,'-5')
                      and nvl(:old.codice_fiscale ,'-5') = nvl(:new.codice_fiscale                  ,'-5')
                      and nvl(:old.codice_fiscale_estero ,'-5') = nvl(:new.codice_fiscale_estero    ,'-5')
                      and nvl(:old.cittadinanza ,'-5') = nvl(:new.cittadinanza                      ,'-5')
                      and nvl(:old.gruppo_ling ,'-5') = nvl(:new.gruppo_ling                        ,'-5')
                      and nvl(:old.tipo_soggetto ,'-5') = nvl(:new.tipo_soggetto                    ,'-5')
                      and nvl(:old.stato_cee ,'-5') = nvl(:new.stato_cee                            ,'-5')
                      and nvl(:old.partita_iva_cee ,'-5') = nvl(:new.partita_iva_cee                ,'-5')
                      and nvl(:old.fine_validita ,trunc(sysdate) +10000) = nvl(:new.fine_validita                    ,trunc(sysdate) +10000)
                      and nvl(:old.stato_soggetto ,'-5') = nvl(:new.stato_soggetto                  ,'-5')
                      and nvl(:old.al ,trunc(sysdate) +10000) = nvl(:new.al                                          ,trunc(sysdate) +10000)
                      and nvl(:old.denominazione ,'-5') = nvl(:new.denominazione                    ,'-5')
                      and nvl(:old.note ,'-5') = nvl(:new.note                                      ,'-5')
     then
       -- caso in cui aggiorno solo la partita_iva
       -- lascio andare e non controllo altrimenti non si potrebbe fare
        :new.competenza := :old.competenza;
        :new.competenza_esclusiva := :old.competenza_esclusiva;
-- Rev. 6 fine
     else
      d_result := anagrafici_pkg.is_competenza_ok
        ( p_competenza=>:NEW.competenza
        , p_competenza_esclusiva =>:NEW.competenza_esclusiva
        , p_competenza_old => :OLD.competenza
        , p_competenza_esclusiva_old => :OLD.competenza_esclusiva
        ) ;
         IF NOT ( d_result = AFC_Error.ok )
       THEN
          anagrafici_pkg.raise_error_message(d_result);
       END IF;
     end if;
        IF :NEW.ID_ANAGRAFICA IS NULL THEN
               select anag_sq.nextval
                 into :NEW.ID_ANAGRAFICA
                 from dual;
        END IF;
      IF inserting and :NEW.dal IS NULL
      THEN
         :NEW.dal := NVL (TRUNC (:NEW.data_nas),  trunc(SYSDATE));
      END IF;
      IF :NEW.dal > NVL (:NEW.al, TO_DATE ('3333333', 'j'))
      THEN
         raise_application_error
                           (-20999
                          ,  si4.get_error('A10004') || '(' || :NEW.dal ||'>' || :NEW.al
                          || ').');
--                            'Data di termine validita'' ('
--                            || :NEW.al
--                            || ') inferiore a data decorrenza registrazione('
--                            || :NEW.dal
--                            || ').');
      END IF;
      IF :NEW.dal > NVL (:NEW.fine_validita, TO_DATE ('3333333', 'j'))
      THEN
         raise_application_error
                           (-20999
                          ,  si4.get_error('A10005') || '(' || :NEW.dal ||'>' || :NEW.fine_validita
                          || ').');
--                            'Data di Fine Validita'' anagrafica ('
--                            || :NEW.fine_validita
--                            || ') inferiore a data decorrenza registrazione('
--                            || :NEW.dal
--                            || ').');
      END IF;
      IF :NEW.codice_fiscale IS NULL AND :OLD.codice_fiscale IS NOT NULL
          AND ad4_soggetto.is_soggetto_componente(:new.ni) = 1
      THEN
       raise_application_error
                           (-20999
                          ,   si4.get_error('A10072') || ' Non si può togliere il CODICE FISCALE ad un soggetto '
                            || 'utilizzato come componente in Struttura Organizzativa.');
      END IF;

   END;
   BEGIN                    -- Check REFERENTIAL Integrity on INSERT or UPDATE
      IF UPDATING
      THEN
         -- se il record e storico modificare il dal potrebbe portare alla
         -- scomparsa di alcuni altri record.
         IF     :OLD.al IS NOT NULL
            AND NVL (:NEW.dal, TO_DATE ('2222222', 'j')) <> :OLD.dal
         THEN
            raise_application_error
               (-20999
              ,si4.get_error('A10058')); --Impossibile aggiornare la data di inizio validita di un record storico.
         END IF;
         -- rev. 17 inizio
         if not(:old.al is null and :new.al is not null )
         -- se non sto chiudendo il record controllo su comune e provincia
         then
                  anagrafici_pkg.anagrafici_pu (:OLD.ni
                             , :OLD.dal
                             , :OLD.provincia_nas
                             , :OLD.comune_nas
                             , :OLD.tipo_soggetto
                             , :NEW.ni
                             , :NEW.dal
                             , :NEW.provincia_nas
                             , :NEW.comune_nas
                             , :NEW.tipo_soggetto
                              );
         end if;
         -- rev. 17 fine
         DECLARE
         v_oggetto xx4_anagrafici.oggetto%TYPE;
         v_motivo_blocco xx4_anagrafici.motivo_blocco%TYPE;
         --  Declaration of UpdateParentRestrict constraint for "XX4_ANAGRAFICI"
   CURSOR cfk1_anagrafici(var_ni NUMBER, var_dal DATE) IS
      SELECT oggetto, motivo_blocco
      FROM   XX4_ANAGRAFICI
      WHERE  ni = var_ni
       AND   dal >= var_dal
       AND   var_ni IS NOT NULL
       AND   var_dal IS NOT NULL;
       BEGIN  -- Check REFERENTIAL Integrity
      --  Chiave di "ANAGRAFICI" non modificabile se esistono referenze su "XX4_ANAGRAFICI"
      OPEN  cfk1_anagrafici(:OLD.NI,:OLD.DAL);
      FETCH cfk1_anagrafici INTO V_oggetto, V_motivo_blocco;
      FOUND := cfk1_anagrafici%FOUND;
      CLOSE cfk1_anagrafici;
      IF FOUND THEN
         IF (:OLD.NI != :NEW.NI) OR (:OLD.DAL != :NEW.DAL) OR (V_motivo_blocco = 'R') THEN
          errno  := -20005;
          errmsg := si4.get_error('A10063') --Esistono riferimenti su Anagrafici
                    ||'('||V_oggetto||'). La registrazione non e'' modificabile.';
          IF v_motivo_blocco = 'R' THEN
             errmsg := errmsg ||'(motivo blocco: '||V_motivo_blocco||')';
          END IF;
          RAISE integrity_error;
         END IF;
      END IF;
   END;
         -- Rev.7 del 22/06/2006 MM: Gestione motivo_blocco di XX4_ANAGRAFICI.
         -- Verifica la presenza del soggetto nella vista di integrita referenziale
         -- ed il motivo del blocco del record:
         -- se il soggetto e presente nella vista ed motivo_blocco = U (nessun
         -- campo del record e modificabile ad eccezione di AL = e storicizzabile)
         -- oppure motivo_blocco = D (come U ma nel nuovo record creato i campi
         -- COGNOME e NOME devono essere uguali a quelli attuali),
         --    se e stato modificato un qualsiasi campo <> AL, non permette la
         --    modifica.
--         I possibili MOTIVO BLOCCO sono:
--= R (Record: nessun campo modificabile)
--= C (Chiave: campi chiave non modificabili)
--= U (nessun campo del record e modificabile ad eccezione di AL = e storicizzabile)
--= D (come U ma nel nuovo record creato i campi COGNOME e NOME devono essere uguali a quelli attuali),  se e stato modificato un qualsiasi campo <> AL, non permette la modifica.
         DECLARE
            d_oggetto   VARCHAR2 (2000);
            d_motivo    VARCHAR2 (1);
            d_blocco    BOOLEAN         := FALSE;
         BEGIN
            -- Rev.10 del 01/09/2009 MM: A34104.0.0 Errore ORA-1422 exact fetch
            -- returns more than requested number of rows in modifica di un
            -- soggetto.
            FOR rif IN (SELECT oggetto, motivo_blocco
                          FROM xx4_anagrafici
                         WHERE ni = :NEW.ni AND dal >= :NEW.dal)
            LOOP
               d_oggetto := rif.oggetto;
               d_motivo  := rif.motivo_blocco;
               -- Rev.10 del 01/09/2009 MM: A34104.0.0 fine mod.
               IF d_motivo IN ('U', 'D')
               THEN
                  BEGIN
                     FOR c_col IN (SELECT   column_name
                                       FROM user_tab_columns
                                      WHERE table_name = 'ANAGRAFICI'
                                   ORDER BY column_id)
                     LOOP
                        IF UPDATING (c_col.column_name)
                             -- non dovrei controllare se il valore nuovo e vecchio sono diversi?
                        THEN
                           IF c_col.column_name <> 'AL'
                           THEN
                              d_blocco := TRUE;
                           END IF;
                           IF d_blocco
                           THEN
                              EXIT;
                           END IF;
                        END IF;
                     END LOOP;
                     IF d_blocco
                     THEN
                        raise_application_error
                           (-20999
                          ,   si4.get_error('A10063') -- Esistono riferimenti su Anagrafici
                            || ' ('
                            || d_oggetto
                            || '). La registrazione non e'' modificabile (motivo blocco: '
                            || d_motivo
                            || ').');
                     END IF;
                  END;
               END IF;
            END LOOP;
         END;
      -- Rev.7 del 22/06/2006 MM: fine mod.
      END IF;
      IF INSERTING
      THEN
                  anagrafici_pkg.anagrafici_pi (:NEW.provincia_nas
                             , :NEW.comune_nas
                             , :NEW.tipo_soggetto
                              );
         IF integritypackage.getnestlevel = 0
         THEN
            DECLARE
               --  Check UNIQUE PK Integrity per la tabella "ANAGRAFICI"
               CURSOR cpk_anagrafici (
                  var_ni    NUMBER
                , var_dal   DATE
               )
               IS
                  SELECT 1
                    FROM anagrafici
                   WHERE ni = var_ni AND dal = var_dal;
               mutating   EXCEPTION;
               PRAGMA EXCEPTION_INIT (mutating, -4091);
            BEGIN       -- Check UNIQUE Integrity on PK of "ANAGRAFICI"
               IF :NEW.ni IS NOT NULL AND :NEW.dal IS NOT NULL
               THEN
                  OPEN cpk_anagrafici (:NEW.ni, :NEW.dal);
                  FETCH cpk_anagrafici
                   INTO dummy;
                  FOUND := cpk_anagrafici%FOUND;
                  CLOSE cpk_anagrafici;
                  IF FOUND
                  THEN
                     errno := -20007;
                     errmsg := si4.get_error('A10064')
                        ||' ('
                        || :NEW.ni
                        || ' '
                        || :NEW.dal
                        || ') in Anagrafici. La registrazione  non puo'' essere inserita.';
--                           'Identificazione "'
--                        || :NEW.ni
--                        || ' '
--                        || :NEW.dal
--                        || '" gia'' presente in Anagrafici. La registrazione  non puo'' essere inserita.';
                     RAISE integrity_error;
                  END IF;
               END IF;
            EXCEPTION
               WHEN mutating
               THEN
                  NULL;                -- Ignora Check su UNIQUE PK Integrity
            END;
         END IF;
      END IF;
   END;
   DECLARE
   v_min_dal date;
   v_num_record_x_ni number := 0;
   BEGIN                          -- Set PostEvent Check REFERENTIAL Integrity
   IF integritypackage.getnestlevel = 0
         THEN
      IF INSERTING AND :NEW.ni IS NULL
      THEN
               -- inizializzazione campo NI
      anagrafici_pkg.init_ni(:NEW.ni);
      END IF;
      -- Rev. 15 INIZIO
      IF INSERTING AND :NEW.ni IS NOT NULL THEN
      -- controllo se il dal e minore del dal della prima storicita
      -- per quel ni e se ci sono altri record
          SELECT MIN(dal), count(*)
            INTO v_min_dal, v_num_record_x_ni
            FROM anagrafici
          WHERE ni = :NEW.ni;
            IF NVL(v_min_dal,TO_DATE ('2222222', 'j')) > :new.dal and v_num_record_x_ni > 1 THEN
             raise_application_error
                   (-20999
                   ,  si4.get_error('A10067')
                  --, 'Impossibile aggiornare la PRIMA data di inizio validita'' di una anagrafica.'
                  );
            END IF;
      END IF;
   end if; -- solo primo livello
   IF UPDATING AND :new.dal < :old.dal
      AND NVL(anagrafici_pkg.conta_ni_anagrafici(:new.ni),0)  > 1
   THEN
       raise_application_error (-20999,si4.get_error('A10057') || '(Anagrafici)');--Impossibile modificare la data di inizio validita, esistono storicità
   END IF;
   IF UPDATING AND  :new.al is null and  :old.al is not null and NVL(anagrafici_pkg.conta_ni_anagrafici_dal_al(:new.ni, :new.dal, :new.al),0)  > 1
   THEN
       raise_application_error (-20999,si4.get_error('A10076'));--Errore: piu periodi aperti per anagrafica
   END IF;
   IF INSERTING AND NVL(anagrafici_pkg.conta_ni_anagrafici_dal_al(:new.ni, :new.dal, :new.al),0)  >= 1
   THEN
       raise_application_error (-20999,si4.get_error('A10056'));--Impossibile inserire periodo sovrapposto a periodi esistenti
   END IF;
   -- rev. 18 inizio
   IF UPDATING AND
   ( nvl(:new.al, trunc(sysdate)) !=  nvl(:old.al, trunc(sysdate))
     OR
      :new.dal != :old.dal)
   and NVL(anagrafici_pkg.is_ultimo_dal(:new.ni, :old.dal),0)  != 1
   THEN
       raise_application_error (-20999,si4.get_error('A10046'));--Errore: Modifica di registrazione storica non consentita.
   END IF;
   -- rev. 18 fine
   if updating and :new.dal < :old.dal then
      DECLARE
            a_istruzione   VARCHAR2 (2000);
            a_messaggio    VARCHAR2 (2000);
         BEGIN
            a_messaggio := '';
            a_istruzione :=
            'update recapiti set dal = '
               || ' to_date('''
               || TO_CHAR (:NEW.dal, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy'') '
               || ' where ni = '
               || :old.ni
               || ' and dal = '
               || ' to_date('''
               || TO_CHAR (:OLD.dal, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy'') and al is null';
            integritypackage.set_postevent (a_istruzione, a_messaggio);
         EXCEPTION
            WHEN OTHERS
            THEN
               integritypackage.initnestlevel;
               RAISE;
         END;
      end if;
   --Funzione che evita storicizzazione in alcune situazioni
   -- rev.10 inizio
      declare
   v_forzare_storicizzare number := 0;
   v_mod_dati_da_storicizzare number := 0;
   begin
   v_forzare_storicizzare := IS_STORICIZZARE_PERSONALIZZATO( p_ni => :old.ni,
                                              p_dal => :old.dal,
                                              p_tipo_soggetto => :old.tipo_soggetto,
                                              p_cognome => :old.cognome,
                                              p_nome => :old.nome ) ;
   if -- cambiano i dati di base devo sempre storicizzare (richiesta di VENEZIA)
               NVL (:NEW.cognome, 'xxx') <> NVL (:OLD.cognome, 'xxx')
              OR NVL (:NEW.nome, 'xxx') <> NVL (:OLD.nome, 'xxx')
              OR NVL (:NEW.codice_fiscale, 'xxx') <> NVL (:OLD.codice_fiscale, 'xxx')
              --Rev.1 inizio modifica
              OR NVL (:NEW.codice_fiscale_estero, 'xxx') <> NVL (:OLD.codice_fiscale_estero, 'xxx')
              OR NVL (:NEW.partita_iva_cee, 'xxx') <> NVL (:OLD.partita_iva_cee, 'xxx')
              --Rev.1 fine modifica
              OR NVL (:NEW.partita_iva, 'xxx') <> NVL (:OLD.partita_iva, 'xxx')
              or (:old.dal < :new.dal) then
              v_mod_dati_da_storicizzare :=   1;
   end if;
  IF 1 = 1 then
   -- VERIFICHE SE OCCORRE STORICIZZARE
   -- rev. 13 inizio
   IF  ( UPDATING
         AND
           ((NVL (:OLD.competenza_esclusiva, 'xxx') = 'P'
             --AND substr(NVL (:NEW.competenza, 'xxx'), 1, 2) <> substr(NVL (:OLD.competenza, 'xxx'), 1, 2)
             OR :NEW.dal > :OLD.dal -- solo in avanti si storicizza
             OR NVL (:NEW.cognome, 'xxx') <> NVL (:OLD.cognome, 'xxx')
             OR NVL (:NEW.nome, 'xxx') <> NVL (:OLD.nome, 'xxx')
             )
           OR (v_forzare_storicizzare = 1
             -- cambiano i dati di base devo sempre storicizzare (richiesta di VENEZIA)
             AND v_mod_dati_da_storicizzare = 1
              )
            )
          AND sysdate between :old.dal and nvl(:new.al, to_date('3333333','j')) -- per storicizzare anche su record chiusi
          )
   -- rev. 13 fine
      THEN
    -- se viene passato il dal uso quello
    -- non posso usare dal inferiori ad oggi
    -- Rev 4. inizio
         IF :NEW.dal IS NULL OR (:NEW.dal <= TRUNC (SYSDATE) and :old.competenza_esclusiva in ('P','E')) -- rev. 12
            OR (v_forzare_storicizzare = 1   AND     v_mod_dati_da_storicizzare = 1 )-- rev.10
          -- Rev 4. fine
         THEN
            :NEW.dal := TRUNC (SYSDATE) ;
         END IF;
         IF :new.dal != :old.dal THEN
         -- posso storicizzare
         DECLARE
            a_istruzione                  VARCHAR2 (32000);
            a_messaggio                   VARCHAR2 (2000);
            --#50445
            a_new_ni                      anagrafici.ni%type;
            a_new_dal                     DATE;
            a_new_cognome                 anagrafici.cognome%type;
            a_new_nome                    anagrafici.nome%type;
            a_new_sesso                   anagrafici.sesso%type;
            a_new_data_nas                DATE;
            a_new_provincia_nas           anagrafici.provincia_nas%type;
            a_new_comune_nas              anagrafici.comune_nas%type;
            a_new_luogo_nas               anagrafici.luogo_nas%type;
            a_new_codice_fiscale          anagrafici.codice_fiscale%type;
            a_new_codice_fiscale_estero   anagrafici.codice_fiscale_estero%type;
            a_new_partita_iva             anagrafici.partita_iva%type;
            a_new_cittadinanza            anagrafici.cittadinanza%type;
            a_new_gruppo_ling             anagrafici.gruppo_ling%type;
            a_new_utente                  anagrafici.utente%type;
            a_new_competenza              anagrafici.competenza%type;
            a_new_tipo_soggetto           anagrafici.tipo_soggetto%type;
            a_new_stato_cee               anagrafici.stato_cee%type;
            a_new_partita_iva_cee         anagrafici.partita_iva_cee%type;
            a_new_fine_validita           anagrafici.fine_validita%type;
            a_new_stato_soggetto          anagrafici.stato_soggetto%type;
            a_new_al                      anagrafici.al%type;
            a_new_denominazione           anagrafici.denominazione%type;
            a_new_note                    anagrafici.note%type;
            a_new_competenza_esclusiva    anagrafici.competenza_esclusiva%type;
            --#50445
         BEGIN
            a_new_ni := :NEW.ni;
            if :new.dal = :old.dal then
            a_new_dal := trunc(sysdate);
            else
            a_new_dal := :NEW.dal;
            end if;
            a_new_cognome := REPLACE (:NEW.cognome
                                    , ''''
                                    , ''''''
                                     );
            a_new_nome := REPLACE (:NEW.nome
                                 , ''''
                                 , ''''''
                                  );
            a_new_sesso := :NEW.sesso;
            a_new_data_nas := :NEW.data_nas;
            a_new_provincia_nas := '' || TO_CHAR (:NEW.provincia_nas) || '';
            a_new_comune_nas := '' || TO_CHAR (:NEW.comune_nas) || '';
            a_new_luogo_nas := REPLACE (:NEW.luogo_nas
                                      , ''''
                                      , ''''''
                                       );
            a_new_codice_fiscale := REPLACE (:NEW.codice_fiscale
                                    , ''''
                                    , ''''''
                                     );
            a_new_codice_fiscale_estero := :NEW.codice_fiscale_estero;
            a_new_partita_iva := REPLACE (:NEW.partita_iva
                                    , ''''
                                    , ''''''
                                     );
            a_new_cittadinanza := :NEW.cittadinanza;
            a_new_gruppo_ling := :NEW.gruppo_ling;
            a_new_utente := :NEW.utente;
            a_new_competenza := :NEW.competenza;
            a_new_tipo_soggetto := :NEW.tipo_soggetto;
            a_new_stato_cee := :NEW.stato_cee;
            a_new_partita_iva_cee := :NEW.partita_iva_cee;
            a_new_fine_validita := :NEW.fine_validita;
            a_new_stato_soggetto := :NEW.stato_soggetto;
            a_new_al := :NEW.al;
            a_new_denominazione := REPLACE (:NEW.denominazione
                                          , ''''
                                          , ''''''
                                           );
            a_new_note := REPLACE (:NEW.note
                                 , ''''
                                 , ''''''
                                  );
            a_new_competenza_esclusiva := :NEW.competenza_esclusiva;
            :NEW.ni := :OLD.ni;
            :NEW.dal := :OLD.dal;
            :NEW.cognome := :OLD.cognome;
            :NEW.nome := :OLD.nome;
            :NEW.sesso := :OLD.sesso;
            :NEW.data_nas := :OLD.data_nas;
            :NEW.provincia_nas := :OLD.provincia_nas;
            :NEW.comune_nas := :OLD.comune_nas;
            :NEW.luogo_nas := :OLD.luogo_nas;
            :NEW.codice_fiscale := :OLD.codice_fiscale;
            :NEW.codice_fiscale_estero := :OLD.codice_fiscale_estero;
            :NEW.partita_iva := :OLD.partita_iva;
            :NEW.cittadinanza := :OLD.cittadinanza;
            :NEW.gruppo_ling := :OLD.gruppo_ling;
            :NEW.utente := a_new_utente; -- rev. 15 :OLD.utente;
            :NEW.data_agg := :OLD.data_agg;
            :NEW.competenza := :OLD.competenza;
            :NEW.tipo_soggetto := :OLD.tipo_soggetto;
            :NEW.stato_cee := :OLD.stato_cee;
            :NEW.partita_iva_cee := :OLD.partita_iva_cee;
            :NEW.fine_validita := :OLD.fine_validita;
            :NEW.stato_soggetto := :OLD.stato_soggetto;
            if :old.al is not null then
               :new.al := a_new_dal-1;
            else-- se non era chiuso
               :new.al := :OLD.al;
            end if;
--            :NEW.al := :OLD.al;
            :NEW.denominazione := :OLD.denominazione;
            :NEW.note := :OLD.note;
            :NEW.competenza_esclusiva := :OLD.competenza_esclusiva;
            a_istruzione :=
                  'begin '|| 'INSERT INTO ANAGRAFICI ('
|| '   ID_ANAGRAFICA, NI, DAL, '
|| '   AL, COGNOME, NOME, '
|| '   SESSO, DATA_NAS, PROVINCIA_NAS, '
|| '   COMUNE_NAS, LUOGO_NAS, CODICE_FISCALE, '
|| '   CODICE_FISCALE_ESTERO, PARTITA_IVA, CITTADINANZA, '
|| '   GRUPPO_LING, COMPETENZA, COMPETENZA_ESCLUSIVA, '
|| '   TIPO_SOGGETTO, STATO_CEE, PARTITA_IVA_CEE, '
|| '   FINE_VALIDITA, STATO_SOGGETTO, DENOMINAZIONE, '
|| '   NOTE,  UTENTE) ' -- non passo version e data_agg
|| '   select  null /* ID_ANAGRAFICA */,'''
               || a_new_ni
               || ''', to_date('''
               || TO_CHAR (a_new_dal, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy'')'
                || ', to_date('''
               || TO_CHAR (a_new_al, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy''), '''
               || a_new_cognome
               || ''''
               || ', '''
               || a_new_nome
               || ''', '''
               || a_new_sesso
               || ''''
               || ', to_date('''
               || TO_CHAR (a_new_data_nas, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy'')'
               || ', to_number('''
               || a_new_provincia_nas
               || '''), to_number('''
               || a_new_comune_nas
               || '''), '''
               || a_new_luogo_nas
               || ''''
               || ', '''
               || a_new_codice_fiscale
               || ''', '''
               || a_new_codice_fiscale_estero
               || ''', '''
               || a_new_partita_iva
               || ''''
               || ', '''
               || a_new_cittadinanza
               || ''', '''
               || a_new_gruppo_ling
               || ''', '''
               || a_new_competenza
               || ''', '''
               || a_new_competenza_esclusiva
               || ''', '''
               || a_new_tipo_soggetto
               || ''', '''
               || a_new_stato_cee
               || ''', '''
               || a_new_partita_iva_cee
               || ''', to_date('''
               || TO_CHAR (a_new_fine_validita, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy'')'
               || ', '''
               || a_new_stato_soggetto -- calcolare
               || ''','''
               || a_new_denominazione
               || ''', '''
               || a_new_note
               || ''', '''
               || a_new_utente
               || ''''
               || '   from dual'
               || '  where not exists (select 1'
               || '                      from anagrafici'
               || '                     where ni = '''
               || a_new_ni
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
         else
         -- NON posso storicizzare
         -- devo provare di aggiornare
          null; -- lascio fare update
         end if;
      END IF;
   END IF; -- controllo funzione is_da_storicizzare
    end;
    -- Consento SOLO modifiche in AVANTI non si toccano i periodi storici
      -- se non per chiudere
      IF (INSERTING AND :NEW.al IS NULL) OR (UPDATING AND :OLD.dal <> :NEW.dal)
      THEN
         DECLARE
            a_istruzione   VARCHAR2 (2000);
            a_messaggio    VARCHAR2 (2000);
         BEGIN
            a_messaggio := '';
            a_istruzione :=
                  'begin anagrafici_pkg.ANAGRAFICI_RRI ('
               || :NEW.ni
               || ', to_date('''
               || TO_CHAR (:NEW.dal, 'dd/mm/yyyy')--?? data
               || ''',''dd/mm/yyyy''), '''--?? data
               || :NEW.competenza
               || ''', '''
               || :NEW.competenza_esclusiva -- aggiunta  rev 12
               || ''', ''' -- aggiunta rev 12
               || REPLACE (:NEW.cognome
                         , ''''
                         , ''''''
                          )
               || ''', '''
               || REPLACE (:NEW.nome
                         , ''''
                         , ''''''
                          )
               || '''); end;';
            integritypackage.set_postevent (a_istruzione, a_messaggio);
         EXCEPTION
            WHEN OTHERS
            THEN
               integritypackage.initnestlevel;
               RAISE;
         END;
      END IF;
   END;
      IF :new.dal is null then
       raise_application_error(-20999, si4.get_error('A10088') || ' (DAL)');
    end if;

   --rev. 8 inizio
         if not deleting then --#51316
            if anagrafici_pkg.controllo_se_ni_in_struttura (:new.ni) >= 1  then
            if inserting and :new.denominazione_ricerca is null then
               :new.denominazione_ricerca := d_denominazione_ricerca ;
            end if;
            if updating then
            :new.denominazione_ricerca := d_denominazione_ricerca ;
             -- in struttura
                 if nvl(:new.note ,'xxx') != nvl(:old.note,'xxx')
                    and :new.note is null
                    and :old.note is not null then
                    :new.note := :old.note;
                end if;
            elsif inserting and :new.note is null then
                 DECLARE
                    a_istruzione   VARCHAR2 (2000);
                    a_messaggio    VARCHAR2 (2000);
                 BEGIN
                    a_messaggio := 'Recupero Note';
                    a_istruzione :=
                          'begin as4so4_pkg.recupera_note_con_codice_amm ('
                       || :NEW.ni
                       || ', to_date('''
                       || TO_CHAR (:NEW.dal, 'dd/mm/yyyy')
                       || ''',''dd/mm/yyyy'')'
                       || '); end;';
                    integritypackage.set_postevent (a_istruzione, a_messaggio);
                 EXCEPTION
                    WHEN OTHERS
                    THEN
                       integritypackage.initnestlevel;
                       RAISE;
                 END;
            end if;
            else --#51316
                     :new.denominazione_ricerca := :new.denominazione;
            end if;
            end if;
            -- rev. 8 fine
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


