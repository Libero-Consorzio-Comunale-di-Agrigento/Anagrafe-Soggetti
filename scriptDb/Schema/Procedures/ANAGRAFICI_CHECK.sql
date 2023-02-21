CREATE OR REPLACE PROCEDURE anagrafici_check(
   p_ni                    anagrafici.ni%TYPE,
   p_dal                   anagrafici.dal%TYPE,
   p_al                    anagrafici.al%TYPE,
   p_cognome               anagrafici.cognome%TYPE, 
   p_nome                  anagrafici.nome%TYPE,
   p_partita_iva           anagrafici.partita_iva%TYPE,
   p_partita_iva_cee       anagrafici.partita_iva_cee%TYPE,
   p_codice_fiscale        anagrafici.codice_fiscale%TYPE,
   p_codice_fiscale_estero anagrafici.codice_fiscale_estero%TYPE,
   p_tipo_soggetto         anagrafici.tipo_soggetto%TYPE,
   p_tipo_operazione       VARCHAR2,     --U=update, I=insert, D=Cancellazione
   p_competenza            anagrafici.competenza%TYPE,
   p_competenza_esclusiva  anagrafici.competenza_esclusiva%TYPE,
   p_modificati_attributi  number,
   p_valorizzato_al        number,
   p_stato_diventa_chiuso  number default 0)
IS
/******************************************************************************
    NOME:        anagrafici_check.
    DESCRIZIONE: Controlli previsti dal clciente
    ARGOMENTI:   
    NOTE:        Effettua tutti i controlli previsti
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  02/01/2018 SNeg   Prima emissione.
    001 02/02/2018 SNeg   Controlli per gestione soggetti caricati ma che non
                           rispettano i vincoli del db (caricati senza trigger attivi)
    003 07/03/2018 SNeg  Verificare in alternativa codice_fiscale/codice_fiscale estero
                         e partita_iva/partita_iva_cee  
    004 04/04/2018 SNeg  In aggiornamento considerare solo i soggetti non chiusi
                          al 31/12/2017                     
    005 08/05/2018 SNeg   Se sto chiudendo un soggetto non controllo se partita iva
                          o codice fiscale in conflitto   
    006  22/08/2018 SNeg  Gestione anomalia se più record con stessi dati attivi
                          anche se non dovevano esserci (derivati da trasco). 
    007 06/09/2018  Sneg Sistemato controllo x partita iva nello stesso periodo
    008 19/09/2018  SNeg sistemato controllo x periodi sovrapposti
    009 19/09/2019  SNeg controllo codice_fiscale e partita iva che siano unici
                         solo se cambiati dati significativi
    010 20/09/2018  SNeg Consentita modifica a stato chiuso di un soggetto con "sosia"
    011 27/01/2021  SNeg Controllare lo stato del record solo se è stato modificato
                         o se la chiusura è successiva ad oggi, cioè se il record
                         risulta ancora valido ad oggi. Bug #47761
   ******************************************************************************/
   v_stesso_ni       anagrafici.ni%TYPE;
   v_data_verifica   DATE := SYSDATE;
   -- la data verifica è oggi?
   -- o è oggi solo se la competenza = 'P'?
   v_anagrafica_esistente      anagrafici%ROWTYPE;
BEGIN
-- rev. 011 inizio
-- i controlli vanno fatti solo sui record che non sono stati toccati o che con questa modifica
-- vengono chiusi con una data di chiusura che è precedente ad oggi.
-- senza questo vincolo davano errore soggetti che si stavano sistemando per aderire alle richieste
-- di Venezia
  if p_modificati_attributi = 1
     OR
     p_valorizzato_al = 1 and p_al > sysdate then

   IF p_tipo_soggetto IS NULL
   THEN
      raise_application_error (-20999,
                               si4.get_error('A10078')--'Il tipo soggetto deve essere  indicato'
                               );
   END IF;

   IF p_tipo_soggetto not in ('I','E','G')
   THEN
      raise_application_error (-20999,
                               si4.get_error('A10054')
                               --'Tipo soggetto non previsto'
                               );
   END IF;

   IF     P_tipo_soggetto = 'G'
      AND (p_codice_fiscale IS NOT NULL
          --Rev.3 inizio modifica
      OR p_codice_fiscale_estero IS NOT NULL
      OR p_partita_iva_cee IS NOT NULL
          --Rev.3 fine modifica
      OR p_partita_iva IS NOT NULL
      )
   THEN
      raise_application_error (
         -20999,
          si4.get_error('A10071')
                               --'Codice Fiscale/Partita Iva NON consentiti per soggetti generici'
                               );
   END IF;

   IF p_tipo_soggetto = 'I' AND p_codice_fiscale IS NULL and p_codice_fiscale_estero is null
   THEN                                                --partita iva opzionale
      raise_application_error (
         -20999,
          si4.get_error('A10072')
                               --'Codice Fiscale obbligatorio
                            ||' per ' || tipi_soggetto_tpk.get_descrizione(p_tipo_soggetto));
   END IF;

   IF p_tipo_soggetto = 'I' AND p_nome  IS NULL and
   p_al is null -- gestione di un soggetto chiuso
   THEN                                                --partita iva opzionale
      raise_application_error (
         -20999,
         si4.get_error('A10073')
                               --'Nome obbligatorio
                            ||' per ' || tipi_soggetto_tpk.get_descrizione(p_tipo_soggetto));
   END IF;

   IF p_tipo_soggetto = 'E' AND p_partita_iva IS NULL  AND p_partita_iva_cee IS NULL
     and nvl(p_competenza,'x') != 'SI4SO' and nvl(p_competenza_esclusiva,'x') !='E'
   THEN                                            -- codice_fiscale opzionale
      raise_application_error (
         -20999,
         si4.get_error('A10074')
                               --'Partita Iva obbligatoria
                      ||' per ' || tipi_soggetto_tpk.get_descrizione(p_tipo_soggetto));
   END IF;

  END IF;
-- rev. 011 fine

--raise_application_error(-20999,'controllo ' || p_partita_iva ||':'|| p_ni ||':'||p_dal||':'||p_al);
--02660020237:75764:05-FEB-18:
-- Rev. 5 inizio
if not(p_tipo_operazione = 'U' -- sto aggiornando
     and p_modificati_attributi = 0 -- non ho modificato nulla di basilare
     and (p_valorizzato_al = 1
          OR
          p_stato_diventa_chiuso = 1)-- assegnato il valore x AL
     ) -- in queste situazioni non verifico se ci sono altri soggetti in conflitto
  then
-- Rev. 5 fine
   BEGIN
      -- partita iva è univoco
      SELECT MIN (ni)
        INTO v_stesso_ni
        FROM anagrafici
       WHERE  (  ( partita_iva = p_partita_iva and p_partita_iva is not null)
          --Rev.3 inizio modifica
              or ( partita_iva_cee = p_partita_iva_cee and p_partita_iva_cee is not null)
          --Rev.3 fine modifica
              )
             AND ni != NVL (p_ni, 0)      -- ni non passato perché inserimento
            --- controllo su date effettive
            -- Rev.007 inizio
            AND dal < nvl(p_al, to_date('3333333','j'))
            AND nvl(al, to_date('3333333','j')) > p_dal
            -- Rev.007 fine
              -- verifico che non sia rimasto da trascodifica consideriamo chiusa al 2018
             AND nvl(al,SYSDATE + 1000) >= to_date('01012018','ddmmyyyy')
             and nvl(stato_soggetto,'U') != 'C'
               ;

      IF v_stesso_ni IS NOT NULL
      THEN
         raise_application_error (
            -20999,
         si4.get_error('A10079')
                               --'Partita Iva già legata a diversa Anagrafica
            || ' ('
            || v_stesso_ni
            || ')');
      END IF;
   END;
  end if;

  if not(p_tipo_operazione = 'U' -- sto aggiornando
     and p_modificati_attributi = 0 -- non ho modificato nulla di basilare
     and  (p_valorizzato_al = 1
          OR
          p_stato_diventa_chiuso = 1)-- assegnato il valore x AL
     ) -- in queste situazioni non verifico se ci sono altri soggetti in conflitto
     then
   -- possono esistere più soggetti con stesso c.f. e diversa partita iva
   -- Non posso avere più soggetti con stesso c.f. se ne esiste uno con partita iva nulla
   BEGIN
      SELECT MIN (ni)
        INTO v_stesso_ni
        FROM anagrafici
       WHERE (( codice_fiscale = p_codice_fiscale  AND partita_iva IS NULL)
       -- rev. 3 inizio modifica
            or ( codice_fiscale = p_codice_fiscale  AND P_partita_iva IS NULL) -- voglio inserire il dato nullo in partita iva
            or (codice_fiscale_estero = p_codice_fiscale_estero and partita_iva_cee is null)
            or (codice_fiscale_estero = p_codice_fiscale_estero and P_partita_iva_cee is null)
       -- rev. 3 fine modifica
            )
       AND stato_soggetto = 'U' -- ? stato in uso?
             AND ni != NVL (p_ni, 0)      -- ni non passato perché inserimento
--             AND v_data_verifica BETWEEN dal AND NVL (al, SYSDATE + 1000) -- valido
            --- controllo su date effettive
            -- Rev.008 inizio
            AND dal < nvl(p_al, to_date('3333333','j'))
            AND nvl(al, to_date('3333333','j')) > p_dal
            -- Rev.008 fine
              -- verifico che non sia rimasto da trascodifica consideriamo chiusa al 2018
             AND nvl(al,SYSDATE + 1000) >= to_date('01012018','ddmmyyyy')
             and nvl(stato_soggetto,'U') != 'C'
                                                                         ;

      IF v_stesso_ni IS NOT NULL
      THEN
         raise_application_error (
            -20999,
         si4.get_error('A10080')
                               -- 'Esiste Anagrafica con uguale Codice Fiscale e Partita Iva nulla.
            || ' ('
            || v_stesso_ni
            || ')');
      END IF;
   END;
   end if; -- controllo solo se modificato solo il campo al

--   i campi cognome e nome/ragione sociale, natura giuridica, partita IVA e codice fiscale non sono modificabili.
--   Per gestire le variazioni si dovrà cessare il soggetto esistente ed inserirne uno nuovo con gli stessi valori
--   del precedente tranne che per i campi oggetto della variazione;

   IF    p_tipo_operazione = 'U' and p_ni is not null
   -- se vero una è vera anche altra condizione
    then
      BEGIN
      select *
        into v_anagrafica_esistente
        from anagrafici
       where ni = p_ni
       and dal = p_dal;
--         and al is null;
      IF  (p_cognome != v_anagrafica_esistente.cognome
      OR NVL (p_nome, 'X') != NVL (v_anagrafica_esistente.nome, 'X')
      OR NVL (p_partita_iva, 'X') != NVL (v_anagrafica_esistente.partita_iva, 'X')
       -- rev. 3 inizio modifica
      OR NVL (p_partita_iva_cee, 'X') != NVL (v_anagrafica_esistente.partita_iva_cee, 'X')
      OR NVL (p_codice_fiscale_estero, 'X') != NVL (v_anagrafica_esistente.codice_fiscale_estero, 'X')
       -- rev. 3 fine modifica
      OR NVL (p_codice_fiscale, 'X') != NVL (v_anagrafica_esistente.codice_fiscale, 'X')
      OR p_tipo_soggetto != v_anagrafica_esistente.tipo_soggetto
      )
--      and p_dal != v_anagrafica_esistente.dal
      and (p_al is not null  AND v_anagrafica_esistente.al is null) -- non è una storicizzazione
   THEN
      raise_application_error (
         -20999,
         si4.get_error('A10075')
--         'Impossibile aggiornare informazioni occorre storicizzare'
         );
   END IF;
      EXCEPTION
      when too_many_rows then
         raise_application_error (-20999,
         si4.get_error('A10076')
--         'Attenzione più periodi aperti per anagrafica
       || ' ' || p_ni);
      when no_data_found then
         null; -- nessun periodo precedente aperto (strano però)
      end;
      end if;


-- INDIRIZZO UNA VOLTA usato non può essere modificato ma solo storicizzato
-- considero la xx4_anagrafici che mi dice NI e dal di utilizzo e in caso di modifiche storicizzo tutto

--??????????????????????????????


-- CANCELLAZIONE DI un soggetto si fa con la chiusura del soggetto

if p_competenza = 'SI4SO' and p_competenza_esclusiva = 'E' and p_tipo_soggetto != 'G' then
   -- controllo indirizzo_res, provincia_res, comune_res, cap_res, indirizzo_web
   BEGIN
      SELECT MIN (ni)
        INTO v_stesso_ni
        FROM anagrafici
       WHERE cognome = p_cognome
         and nvl(nome,'x') = nvl(p_nome,'x')
         and ( codice_fiscale  = p_codice_fiscale OR (codice_fiscale is null AND p_codice_fiscale is null))
       -- rev. 3 inizio modifica
         and ( codice_fiscale_estero  = p_codice_fiscale_estero OR (codice_fiscale_estero is null AND p_codice_fiscale_estero is null))
         AND ( partita_iva_cee  = p_partita_iva_cee OR (partita_iva_cee is null AND p_partita_iva_cee is null))
       -- rev. 3 fine  modifica
         AND ( partita_iva  = p_partita_iva OR (partita_iva is null AND p_partita_iva is null))
         AND ni != NVL (p_ni, 0)      -- ni non passato perché inserimento
         AND v_data_verifica BETWEEN dal AND NVL (al, SYSDATE + 1000) -- valido
         AND stato_soggetto = 'U'
         AND nvl(competenza,'x') != 'SI4SO'
         AND nvl(competenza_esclusiva,'x') != 'E'
         ;
      IF v_stesso_ni IS NOT NULL and p_tipo_operazione = 'I'
      THEN
         raise_application_error (
            -20999,
         si4.get_error('A10077')
--         'Esiste Anagrafica con Dati Uguali. Impossibile inserire, usare anagrafica esistente
            || ' ('
            || v_stesso_ni
            || ')');
      END IF;
   END;

else -- non di struttura organizzativa o meglio scarico IPA
   if p_tipo_operazione = 'I' then
--in caso di inserimento di un soggetto:
--già presente a sistema con i dati disponibili corrispondenti (cognome e nome/ragione sociale, codice fiscale e partita IVA;
--gli ultimi due dati possono essere valorizzati entrambi o uno solo con l'altro vuoto) non deve essere inserito come
--nuova anagrafica ma si dovrà utilizzare quella presente;
 BEGIN
      SELECT MIN (ni)
        INTO v_stesso_ni
        FROM anagrafici
       WHERE    cognome = p_cognome
          and nvl(nome,'x') = nvl(p_nome,'x')
          and ((( codice_fiscale  = p_codice_fiscale OR (codice_fiscale is null AND p_codice_fiscale is null))
               and  ( partita_iva  = p_partita_iva OR (partita_iva is null AND p_partita_iva is null)))
       -- rev. 3 inizio modifica
          AND( ( codice_fiscale_estero  = p_codice_fiscale_estero OR (codice_fiscale_estero is null AND p_codice_fiscale_estero is null))
             AND ( partita_iva_cee  = p_partita_iva_cee OR (partita_iva_cee is null AND p_partita_iva_cee is null)))
       -- rev. 3 fine modifica
             )
             AND ni != NVL (p_ni, 0)      -- ni non passato perché inserimento
--             AND v_data_verifica BETWEEN dal AND NVL (al, SYSDATE + 1000) -- valido
            --- controllo su date effettive
            -- Rev.008 inizio
            AND dal < nvl(p_al, to_date('3333333','j'))
            AND nvl(al, to_date('3333333','j')) > p_dal
            -- Rev.008 fine
             AND stato_soggetto = 'U'
             and p_tipo_soggetto != 'G'
             ;
      IF v_stesso_ni IS NOT NULL
      THEN
         raise_application_error (
            -20999,
         si4.get_error('A10077')
--         'Esiste Anagrafica con Dati Uguali. Impossibile inserire, usare anagrafica esistente
            || ' ('
            || v_stesso_ni
            || ')');
      END IF;
   END;
   end if;
END IF;

--o con diverso cognome e nome/ragione sociale, stessa partita IVA e diverso codice fiscale (vuoto o presente ma diverso)
-- inserimento dovrà essere bloccato restituendo un messaggio di errore che ne indichi la motivazione;
END;
/

