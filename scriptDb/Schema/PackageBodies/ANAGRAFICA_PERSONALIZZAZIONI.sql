CREATE OR REPLACE PACKAGE BODY ANAGRAFICA_PERSONALIZZAZIONI
IS
   -- Revisione del Package
   s_revisione_body   CONSTANT AFC.t_revision := '001 - 07/09/2018';
   FUNCTION versione
      RETURN VARCHAR2
   IS
   /******************************************************************************
    NOME:        versione
    DESCRIZIONE: Versione e revisione di distribuzione del package.
    RITORNA:     varchar2 stringa contenente versione e revisione.
    NOTE:        Primo numero  : versione compatibilità del Package.
                 Secondo numero: revisione del Package specification.
                 Terzo numero  : revisione del Package body.
   ******************************************************************************/
   BEGIN
      RETURN AFC.version (s_revisione, s_revisione_body);
   END versione;                                    -- anagrafici_pkg.versione
   --------------------------------------------------------------------------------
   FUNCTION IS_MODIFICABILE_PERS_VENEZIA (
      p_ni                         IN anagrafici.ni%TYPE,
      p_dal                        IN anagrafici.dal%TYPE,
      p_competenza                 IN anagrafici.competenza%TYPE,
      p_competenza_esclusiva       IN anagrafici.competenza_esclusiva%TYPE,
      p_competenza_old             IN anagrafici.competenza%TYPE,
      p_competenza_esclusiva_old   IN anagrafici.competenza_esclusiva%TYPE)
      RETURN AFC_Error.t_error_number
   IS
      /******************************************************************************
       NOME:        IS_MODIFICABILE_PERS_VENEZIA
       DESCRIZIONE: Verifica se record modificabile o meno
       PARAMETRI:
       NOTE:        Possibile modificare un soggetto se di tipo G e lo devo chiudere
                     o se ultimo periodo per un ni.
                      1 = il record e modificabile (= AFC_Error.ok)
                   altrimeni NON e modificabile
       REVISIONI:
       Rev.  Data        Autore  Descrizione.
       000  21/05/2018   snegroni Primo rilascio
      ******************************************************************************/
      d_result   AFC_Error.t_error_number := 0;
   BEGIN
      SELECT COUNT (1)
        INTO d_result
        FROM anagrafici a
       WHERE     ni = p_ni
             AND p_dal BETWEEN dal AND NVL (al, TO_DATE ('3333333', 'j'))
             AND (   tipo_soggetto != 'G'
                  OR (tipo_soggetto = 'G' AND al IS NULL))
             AND NOT EXISTS
                    (SELECT 1
                       FROM anagrafici
                      WHERE a.ni = ni AND a.dal < dal);
      -- inizio prova x modifica generico
      IF d_result != afc_error.ok
      THEN
         -- controllo personalizzato
         SELECT COUNT (1)
           INTO d_result
           FROM anagrafici
          WHERE ni = p_ni AND tipo_soggetto = 'G';
      -- prova di concessione in modifica di un generico
      END IF;
      -- fine prova x modifica generico
      RETURN d_result;
   END IS_MODIFICABILE_PERS_VENEZIA;
   -------------------------------------------------------------------------------
   FUNCTION IS_MODIFICABILE_PERSONALIZZATO (
      p_ni                         IN anagrafici.ni%TYPE,
      p_dal                        IN anagrafici.dal%TYPE,
      p_competenza                 IN anagrafici.competenza%TYPE,
      p_competenza_esclusiva       IN anagrafici.competenza_esclusiva%TYPE,
      p_competenza_old             IN anagrafici.competenza%TYPE,
      p_competenza_esclusiva_old   IN anagrafici.competenza_esclusiva%TYPE)
      RETURN AFC_Error.t_error_number
   IS
      /*************************************************************
      RITORNO:
              1 = il record e modificabile (= AFC_Error.ok)
            altrimeni NON e modificabile
      *************************************************************/
      d_result   AFC_Error.t_error_number := AFC_Error.ok;
   BEGIN
       SELECT COUNT (1)
        INTO d_result
        FROM anagrafici a
       WHERE     ni = p_ni
             AND NOT EXISTS
                    (SELECT 1
                       FROM anagrafici
                      WHERE a.ni = ni AND a.dal < dal);
      RETURN d_result;
   END;
   FUNCTION IS_STORICIZZARE_PERS_VENEZIA (
      p_ni              IN anagrafici.ni%TYPE,
      p_dal             IN anagrafici.dal%TYPE,
      p_tipo_soggetto   IN anagrafici.tipo_soggetto%TYPE,
      p_cognome         IN anagrafici.cognome%TYPE,
      p_nome            IN anagrafici.nome%TYPE)
      RETURN AFC_Error.t_error_number
   /*************************************************************
   RITORNO:
           1 = se da storicizzare
           0 = DEVO non storicizzare
   *************************************************************/
   IS
      d_result   AFC_Error.t_error_number := AFC_Error.ok;
   BEGIN
      IF p_tipo_soggetto = 'G'
      THEN
         d_result := 0;
      END IF;
      RETURN d_result;
   END;
   FUNCTION IS_STORICIZZARE_PERSONALIZZATO (
      p_ni              IN anagrafici.ni%TYPE,
      p_dal             IN anagrafici.dal%TYPE,
      p_tipo_soggetto   IN anagrafici.tipo_soggetto%TYPE,
      p_cognome         IN anagrafici.cognome%TYPE,
      p_nome            IN anagrafici.nome%TYPE)
      RETURN AFC_Error.t_error_number
   /*************************************************************
   RITORNO:
           1 = se da storicizzare
           0 = DEVO non storicizzare
   *************************************************************/
   IS
      d_result   AFC_Error.t_error_number := AFC_Error.ok;                -- 1
   BEGIN
      -- ritorna sempre 1 se non ci sono casi particolari da gestire
      RETURN d_result;
   END;
   FUNCTION GET_ANAGRAFICA_ALTERNATIVA (
      p_ni                                anagrafici.ni%TYPE,
      p_cognome                           anagrafici.cognome%TYPE,
      p_nome                              anagrafici.nome%TYPE,
      p_partita_iva                       anagrafici.partita_iva%TYPE,
      p_codice_fiscale                    anagrafici.codice_fiscale%TYPE,
      p_competenza                 IN     ANAGRAFICI.competenza%TYPE DEFAULT NULL,
      p_id_anagrafica_utilizzare   IN OUT anagrafici.id_anagrafica%TYPE -- se ritorno nullo inserire altrimenti
                                                                       -- usare id ritornato
      )                                  --U=update, I=insert, D=Cancellazione
      RETURN NUMBER -- ni da utilizzare o null se non ha trovato una anagrafica alternativa
   /*************************************************************
   RITORNO:
           null = non trovati soggetti in competizione inseerisco nuovo soggetto
           -1   = inserire il record passato come parametro chiuso logicamente
                  e stato chiuso
           n positivo = ni da utilizzare come anagrafica e inserire
              se dovevo storicizzare viene fatto nel trigger
   *************************************************************/
   IS
      v_ni_da_usare            anagrafici.ni%TYPE;
      v_anagrafica_esistente   anagrafici%ROWTYPE;
   BEGIN
      BEGIN
            -- se trovo soggetto esattamente uguale uso quello...
            -- storicizzo e aggiorno gli altri dati
            SELECT *
              INTO v_anagrafica_esistente
              FROM anagrafici
             WHERE     cognome = p_cognome
                   AND NVL (nome, 'XXvuotoXX') = NVL (p_nome, 'XXvuotoXX')
                   AND NVL (partita_iva, 'XXpartita_ivaXX') =
                          NVL (p_partita_iva, 'XXpartita_ivaXX')
                   AND NVL (codice_fiscale, 'XXcodice_fiscaleXX') =
                          NVL (p_codice_fiscale, 'XXcodice_fiscaleXX')
                   AND stato_soggetto = 'U'
                   AND al IS NULL;
            v_ni_da_usare := v_anagrafica_esistente.ni;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;                          -- non ho trovato record ambigui
         END;
      RETURN -1;
   END;
   FUNCTION get_anag_alternativa_VENEZIA (
      p_ni                                anagrafici.ni%TYPE,
      p_cognome                           anagrafici.cognome%TYPE,
      p_nome                              anagrafici.nome%TYPE,
      p_partita_iva                       anagrafici.partita_iva%TYPE,
      p_codice_fiscale                    anagrafici.codice_fiscale%TYPE,
      p_competenza                 IN     ANAGRAFICI.competenza%TYPE DEFAULT NULL,
      p_id_anagrafica_utilizzare   IN OUT anagrafici.id_anagrafica%TYPE -- se ritorno nullo inserire altrimenti
                                                                       -- usare id ritornato
      )                                  --U=update, I=insert, D=Cancellazione
      RETURN NUMBER -- ni da utilizzare o null se non ha trovato una anagrafica alternativa
   /*************************************************************
   RITORNO:
           null = non trovati soggetti in competizione inseerisco nuovo soggetto
           -1   = inserire il record passato come parametro chiuso logicamente
                  e stato chiuso
           n positivo = ni da utilizzare come anagrafica e inserire
              se dovevo storicizzare viene fatto nel trigger
   *************************************************************/
   IS
      v_ni_da_usare            anagrafici.ni%TYPE;
      v_data_verifica          DATE := SYSDATE;
      v_anagrafica_esistente   anagrafici%ROWTYPE;
      v_progetto               anagrafici.competenza%TYPE;
      v_progetto_verificare    VARCHAR2 (10) := 'CFAFE';
   BEGIN
      p_id_anagrafica_utilizzare := NULL;
      IF p_partita_iva IS NULL AND p_codice_fiscale IS NULL
      THEN
         -- forzo inserimento con stato chiuso
         v_ni_da_usare := -1;
      ELSE
         BEGIN
            -- se trovo soggetto esattamente uguale uso quello...
            -- storicizzo e aggiorno gli altri dati
            SELECT *
              INTO v_anagrafica_esistente
              FROM anagrafici
             WHERE     cognome = p_cognome
                   AND NVL (nome, 'XXvuotoXX') = NVL (p_nome, 'XXvuotoXX')
                   AND NVL (partita_iva, 'XXpartita_ivaXX') =
                          NVL (p_partita_iva, 'XXpartita_ivaXX')
                   AND NVL (codice_fiscale, 'XXcodice_fiscaleXX') =
                          NVL (p_codice_fiscale, 'XXcodice_fiscaleXX')
                   AND stato_soggetto = 'U'
                   AND al IS NULL;
            v_ni_da_usare := v_anagrafica_esistente.ni;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;                          -- non ho trovato record ambigui
         END;
         IF v_ni_da_usare IS NULL
         THEN
            --1) pg.37
            --Soggetto in input e Soggetto in anagrafica
            --= cognome e nome/ragione sociale
            --= partita IVA
            --INPUT  codice fiscale non valorizzato
            --ANAGRAFICA codice fiscale valorizzato diverso
            --UNICO CASO IN CUI NON BISOGNA FARE NULLA MA RIUTILIZZARE una ANAGRAFICA!!!!!!!!!!!!!!!!!!!!!!
            -- caso in cui il codice fiscale a nullo.
            BEGIN
               BEGIN
                  --da applicazione: verrà richiesta l?interattività dell?utente per scegliere se utilizzare il soggetto già presente in anagrafica oppure cessarlo ed inserire quello nuovo.
                  --da automatismo: il sistema dovrà verificare se il soggetto presente in anagrafica a stato inserito come soggetto di una fattura elettronica.
                  --Se si, verrà utilizzato il soggetto in anagrafica, altrimenti, se il soggetto che si sta inserendo a collegato ad una fattura elettronica,
                  --il soggetto in anagrafica sarà storicizzato e verrà inserito il nuovo, altrimenti sarà utilizzato il soggetto in anagrafica.
                  SELECT *
                    INTO v_anagrafica_esistente
                    FROM anagrafici
                   WHERE     cognome = p_cognome
                         AND NVL (nome, 'XXvuotoXX') =
                                NVL (p_nome, 'XXvuotoXX')
                         AND partita_iva = p_partita_iva
                         AND (    p_codice_fiscale IS NULL
                              AND codice_fiscale IS NOT NULL)
                         AND stato_soggetto = 'U'
                         AND al IS NULL;                    -- soggetto aperto
                  BEGIN
                     -- cerco se esiste fattura elettronica emessa
                     SELECT progetto
                       INTO v_progetto
                       FROM xx4_anagrafici
                      WHERE     ni = v_anagrafica_esistente.ni
                            AND progetto = v_progetto_verificare
                            --                   non rilevante  AND motivo_blocco = '??'                      --?????
                            AND dal > v_anagrafica_esistente.dal;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        -- non già legato ad una fattura elettronica
                        -- competenza di inserimento a fattura elettronica
                        -- storicizzo record attuale e lo uso
                        -- mi devo fare passare tutti i valori
                        -- altrimenti aggiorno il record e lo chiudo cosa
                        -- la successiva ins lo storicizza
                        --               UPDATE   anagrafici
                        --                  SET   al = SYSDATE
                        --                WHERE   ni = v_anagrafica_esistente.ni AND al IS NULL;
                        -- NON lo chiudo, lo chiuderà il trigger, indico solo che a da usare
                        v_progetto := NULL;
                  END;
                  -- se sono qui lo ha trovato
                  IF v_progetto = v_progetto_verificare -- va bene dire che avra competenza specifica?
                  THEN                                           -- storicizzo
                     v_ni_da_usare := v_anagrafica_esistente.ni;
                  ELSE
                     v_ni_da_usare := v_anagrafica_esistente.ni;
                     -- in questo caso NON va fatto inserimento
                     p_id_anagrafica_utilizzare :=
                        v_anagrafica_esistente.id_anagrafica;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     NULL;                    -- non ho trovato record ambigui
               END;
               IF v_ni_da_usare IS NULL
               THEN
                  BEGIN
                     -- 2)
                     --= cognome e nome/ragione sociale
                     --= partita IVA
                     --INPUT  codice fiscale valorizzato
                     --ANAGRAFICA codice fiscale non valorizzato o valorizzato diverso
                     --da applicazione: verrà richiesta l?interattività dell?utente per scegliere se utilizzare il soggetto già in anagrafica oppure se cessarlo ed inserire quello nuovo.
                     --da automatismo: il sistema dovrà verificare se i soggetti sono relativi a una fattura elettronica.
                     --Se entrambi o nessuno dei due derivano da fattura elettronica si storicizza il soggetto presente in anagrafica e si inserisce il soggetto in input.
                     --Se il solo soggetto in input deriva da fattura elettronica lo si inserisce e si storicizza il soggetto presente in anagrafica.
                     --Se il soggetto presente in anagrafica deriva da fattura elettronica e quello in input no, si mantiene il soggetto presente e si carica il nuovo soggetto cessandolo logicamente.
                     SELECT *
                       INTO v_anagrafica_esistente
                       FROM anagrafici
                      WHERE     cognome = p_cognome
                            AND NVL (nome, 'XXvuotoXX') =
                                   NVL (p_nome, 'XXvuotoXX')
                            AND partita_iva = p_partita_iva
                            AND (    p_codice_fiscale IS NOT NULL
                                 AND (   codice_fiscale IS NULL
                                      OR codice_fiscale != p_codice_fiscale))
                            AND stato_soggetto = 'U'
                            AND al IS NULL;                 -- soggetto aperto
                     -- se sono qui lo ha trovato
                     IF p_competenza = v_progetto_verificare -- va bene dire che avra competenza specifica?
                     THEN
                        BEGIN
                           -- cerco se esiste fattura elettronica emessa
                           SELECT progetto
                             INTO v_progetto
                             FROM xx4_anagrafici
                            WHERE     ni = v_anagrafica_esistente.ni
                                  AND progetto = v_progetto_verificare
                                  --                   non rilevante                      AND motivo_blocco = '??'                   --?????
                                  AND dal > v_anagrafica_esistente.dal;
                           -- esiste tengo quello
                           --Se entrambi o nessuno dei due derivano da fattura elettronica si storicizza il soggetto presente in anagrafica e si inserisce il soggetto in input.
                           --                  UPDATE   anagrafici
                           --                     SET   al = SYSDATE
                           --                   WHERE   ni = v_anagrafica_esistente.ni AND al IS NULL;
                           -- NON lo chiudo, lo chiuderà il trigger, indico solo che a da usare
                           v_ni_da_usare := v_anagrafica_esistente.ni;
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              -- non già legato ad una fattura elettronica
                              -- competenza di inserimento a fattura elettronica
                              -- storicizzo record attuale e lo uso
                              -- mi devo fare passare tutti i valori
                              -- altrimenti aggiorno il record e lo chiudo cosa
                              -- la successiva ins lo storicizza
                              --                     UPDATE   anagrafici
                              --                        SET   al = SYSDATE
                              --                      WHERE   ni = v_anagrafica_esistente.ni AND al IS NULL;
                              -- NON lo chiudo, lo chiuderà il trigger, indico solo che a da usare
                              v_ni_da_usare := v_anagrafica_esistente.ni;
                        END;
                     ELSE -- quello che inserisco non a usato in fattura elettronica
                        BEGIN
                           BEGIN
                              -- cerco se esiste fattura elettronica emessa
                              SELECT progetto
                                INTO v_progetto
                                FROM xx4_anagrafici
                               WHERE     ni = v_anagrafica_esistente.ni
                                     AND progetto = v_progetto_verificare
                                     --                   non rilevante                               AND motivo_blocco = '??'                --?????
                                     AND dal > v_anagrafica_esistente.dal;
                              -- esiste tengo quello
                              -- e carico un nuovo soggetto CESSATO LOGICAMENTE
                              v_ni_da_usare := -1;
                           EXCEPTION
                              WHEN NO_DATA_FOUND
                              THEN
                                 -- non già legato ad una fattura elettronica
                                 -- competenza di inserimento a fattura elettronica
                                 -- storicizzo record attuale e lo uso
                                 -- mi devo fare passare tutti i valori
                                 -- altrimenti aggiorno il record e lo chiudo cosa
                                 -- la successiva ins lo storicizza
                                 --                        UPDATE   anagrafici
                                 --                           SET   al = SYSDATE
                                 --                         WHERE   ni = v_anagrafica_esistente.ni
                                 --                                 AND al IS NULL;
                                 -- NON lo chiudo, lo chiuderà il trigger, indico solo che a da usare
                                 v_ni_da_usare := v_anagrafica_esistente.ni;
                           END;
                        END;
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        NULL;                 -- non ho trovato record ambigui
                  END;
               END IF;
               IF v_ni_da_usare IS NULL
               THEN
                  BEGIN
                     --3)
                     --partita IVA: non valorizzata
                     --= codice fiscale
                     --cognome e nome/ragione sociale: valorizzata diversa
                     --da applicazione: verrà richiesta l?interattività dell?utente per scegliere se utilizzare il soggetto già in anagrafica oppure cessarlo ed inserire quello nuovo.
                     --da automatismo: il sistema storicizzerà il soggetto in anagrafica ed inserirà il nuovo. Opzionalmente potrà essere inviata una mail ad un indirizzo
                     -- configurabile da strumenti di amministrazione.
                     SELECT *
                       INTO v_anagrafica_esistente
                       FROM anagrafici
                      WHERE     (   cognome != p_cognome
                                 OR NVL (nome, 'XXvuotoXX') !=
                                       NVL (p_nome, 'XXvuotoXX'))
                            AND (    partita_iva IS NULL
                                 AND p_partita_iva IS NULL)
                            AND codice_fiscale = p_codice_fiscale
                            AND stato_soggetto = 'U'
                            AND al IS NULL;                 -- soggetto aperto
                     -- se sono qui lo ha trovato
                     -- si storicizza il soggetto presente in anagrafica e si inserisce il soggetto in input.
                     --            UPDATE   anagrafici
                     --               SET   al = SYSDATE
                     --             WHERE   ni = v_anagrafica_esistente.ni AND al IS NULL;
                     -- NON lo chiudo, lo chiuderà il trigger, indico solo che a da usare
                     v_ni_da_usare := v_anagrafica_esistente.ni;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        NULL;
                  --      END;
                  END;
               END IF;
               IF v_ni_da_usare IS NULL
               THEN
                  BEGIN
                     --4)
                     --= partita IVA
                     --codice fiscale: non valorizzato o valorizzato diverso
                     --cognome e nome/ragione sociale:valorizzata diversa
                     --da applicazione: verrà richiesta l?interattività dell?utente per scegliere se utilizzare il soggetto in anagrafica oppure cessarlo ed inserire quello nuovo.
                     --da automatismo: il sistema dovrà verificare se i soggetti sono relativi a una fattura elettronica.
                     --Se entrambi o nessuno dei due derivano da fattura elettronica si storicizza il soggetto presente in anagrafica e si inserisce il soggetto in input.
                     --Se il solo soggetto in input deriva da fattura elettronica lo si inserisce e si storicizza il soggetto presente in anagrafica.
                     --Se il soggetto presente in anagrafica deriva da fattura elettronica e quello in input no, si mantiene il soggetto presente e si carica il nuovo soggetto cessandolo logicamente.
                     --Opzionalmente potrà essere inviata una mail ad un indirizzo configurabile da strumenti di amministrazione.
                     SELECT *
                       INTO v_anagrafica_esistente
                       FROM anagrafici
                      WHERE     (   cognome != p_cognome
                                 OR NVL (nome, 'XXvuotoXX') !=
                                       NVL (p_nome, 'XXvuotoXX'))
                            AND partita_iva = p_partita_iva
                            AND NVL (codice_fiscale, 'XXCFISXX') !=
                                   NVL (p_codice_fiscale, 'YYCFISYY')
                            AND stato_soggetto = 'U'
                            AND al IS NULL;                 -- soggetto aperto
                     -- se sono qui lo ha trovato
                     IF p_competenza = v_progetto_verificare -- va bene dire che avra competenza specifica?
                     THEN
                        BEGIN
                           -- cerco se esiste fattura elettronica emessa
                           SELECT progetto
                             INTO v_progetto
                             FROM xx4_anagrafici
                            WHERE     ni = v_anagrafica_esistente.ni
                                  AND progetto = v_progetto_verificare
                                  --                   non rilevante                            AND motivo_blocco = '??'                   --?????
                                  AND dal > v_anagrafica_esistente.dal;
                           -- esiste tengo quello
                           --Se entrambi o nessuno dei due derivano da fattura elettronica si storicizza il soggetto presente in anagrafica e si inserisce il soggetto in input.
                           --                  UPDATE   anagrafici
                           --                     SET   al = SYSDATE
                           --                   WHERE   ni = v_anagrafica_esistente.ni AND al IS NULL;
                           -- NON lo chiudo, lo chiuderà il trigger, indico solo che a da usare
                           v_ni_da_usare := v_anagrafica_esistente.ni;
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              -- non già legato ad una fattura elettronica
                              -- competenza di inserimento a fattura elettronica
                              -- storicizzo record attuale e lo uso
                              -- mi devo fare passare tutti i valori
                              -- altrimenti aggiorno il record e lo chiudo cosa
                              -- la successiva ins lo storicizza
                              UPDATE anagrafici
                                 SET al = SYSDATE
                               WHERE     ni = v_anagrafica_esistente.ni
                                     AND al IS NULL;
                              v_ni_da_usare := v_anagrafica_esistente.ni;
                        END;
                     ELSE -- quello che inserisco non a usato in fattura elettronica
                        BEGIN
                           BEGIN
                              -- cerco se esiste fattura elettronica emessa
                              SELECT progetto
                                INTO v_progetto
                                FROM xx4_anagrafici
                               WHERE     ni = v_anagrafica_esistente.ni
                                     AND progetto = v_progetto_verificare
                                     --                   non rilevante                               AND motivo_blocco = '??'                --?????
                                     AND dal > v_anagrafica_esistente.dal;
                              -- esiste tengo quello
                              -- e carico un nuovo soggetto CESSATO LOGICAMENTE
                              v_ni_da_usare := -1;
                           EXCEPTION
                              WHEN NO_DATA_FOUND
                              THEN
                                 -- non già legato ad una fattura elettronica
                                 -- competenza di inserimento a fattura elettronica
                                 -- storicizzo record attuale e lo uso
                                 -- mi devo fare passare tutti i valori
                                 -- altrimenti aggiorno il record e lo chiudo cosa
                                 -- la successiva ins lo storicizza
                                 --                        UPDATE   anagrafici
                                 --                           SET   al = SYSDATE
                                 --                         WHERE   ni = v_anagrafica_esistente.ni
                                 --                                 AND al IS NULL;
                                 -- NON lo chiudo, lo chiuderà il trigger, indico solo che a da usare
                                 v_ni_da_usare := v_anagrafica_esistente.ni;
                           END;
                        END;
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        NULL;                 -- non ho trovato record ambigui
                  END;
               END IF;
               IF v_ni_da_usare IS NULL
               THEN
                  BEGIN
                     --5)
                     --= partita IVA
                     --= codice fiscale
                     --cognome e nome/ragione sociale:valorizzata diversa
                     --da applicazione: verrà richiesta l?interattività dell?utente per scegliere se utilizzare il soggetto già in anagrafica oppure cessarlo ed inserire quello nuovo.
                     --da automatismo: il sistema dovrà verificare se i soggetti sono relativi a una fattura elettronica.
                     --Se entrambi o nessuno dei due derivano da fattura elettronica si storicizza il soggetto presente in anagrafica e si inserisce il soggetto in input.
                     --Se il solo soggetto in input deriva da fattura elettronica lo si inserisce e si storicizza il soggetto presente in anagrafica.
                     --Se il soggetto presente in anagrafica deriva da fattura elettronica e quello in input no, si mantiene il soggetto presente e si carica il nuovo soggetto cessandolo logicamente.
                     --Opzionalmente potrà essere inviata una mail ad un indirizzo configurabile da strumenti di amministrazione.
                     --nei rimanenti casi di inserimento dovrà essere inserito un nuovo soggetto in anagrafica.
                     SELECT *
                       INTO v_anagrafica_esistente
                       FROM anagrafici
                      WHERE     (   cognome != p_cognome
                                 OR NVL (nome, 'XXvuotoXX') !=
                                       NVL (p_nome, 'XXvuotoXX'))
                            AND partita_iva = p_partita_iva
                            AND codice_fiscale = p_codice_fiscale
                            AND stato_soggetto = 'U'
                            AND al IS NULL;                 -- soggetto aperto
                     -- se sono qui lo ha trovato
                     IF p_competenza = v_progetto_verificare -- va bene dire che avra competenza specifica?
                     THEN
                        BEGIN
                           -- cerco se esiste fattura elettronica emessa
                           SELECT progetto
                             INTO v_progetto
                             FROM xx4_anagrafici
                            WHERE     ni = v_anagrafica_esistente.ni
                                  AND progetto = v_progetto_verificare
                                  --                   non rilevante                            AND motivo_blocco = '??'                   --?????
                                  AND dal > v_anagrafica_esistente.dal;
                           -- esiste tengo quello
                           --Se entrambi o nessuno dei due derivano da fattura elettronica si storicizza il soggetto presente in anagrafica e si inserisce il soggetto in input.
                           --                  UPDATE   anagrafici
                           --                     SET   al = SYSDATE
                           --                   WHERE   ni = v_anagrafica_esistente.ni AND al IS NULL;
                           -- NON lo chiudo, lo chiuderà il trigger, indico solo che a da usare
                           v_ni_da_usare := v_anagrafica_esistente.ni;
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              -- non già legato ad una fattura elettronica
                              -- competenza di inserimento a fattura elettronica
                              -- storicizzo record attuale e lo uso
                              -- mi devo fare passare tutti i valori
                              -- altrimenti aggiorno il record e lo chiudo cosa
                              -- la successiva ins lo storicizza
                              UPDATE anagrafici
                                 SET al = SYSDATE
                               WHERE     ni = v_anagrafica_esistente.ni
                                     AND al IS NULL;
                              v_ni_da_usare := v_anagrafica_esistente.ni;
                        END;
                     ELSE -- quello che inserisco non a usato in fattura elettronica
                        BEGIN
                           BEGIN
                              -- cerco se esiste fattura elettronica emessa
                              SELECT progetto
                                INTO v_progetto
                                FROM xx4_anagrafici
                               WHERE     ni = v_anagrafica_esistente.ni
                                     AND progetto = v_progetto_verificare
                                     --                   non rilevante                               AND motivo_blocco = '??'                --?????
                                     AND dal > v_anagrafica_esistente.dal;
                              -- esiste tengo quello
                              -- e carico un nuovo soggetto CESSATO LOGICAMENTE
                              v_ni_da_usare := -1;
                           EXCEPTION
                              WHEN NO_DATA_FOUND
                              THEN
                                 -- non già legato ad una fattura elettronica
                                 -- competenza di inserimento a fattura elettronica
                                 -- storicizzo record attuale e lo uso
                                 -- mi devo fare passare tutti i valori
                                 -- altrimenti aggiorno il record e lo chiudo cosa
                                 -- la successiva ins lo storicizza
                                 --                        UPDATE   anagrafici
                                 --                           SET   al = SYSDATE
                                 --                         WHERE   ni = v_anagrafica_esistente.ni
                                 --                                 AND al IS NULL;
                                 -- NON lo chiudo, lo chiuderà il trigger, indico solo che a da usare
                                 v_ni_da_usare := v_anagrafica_esistente.ni;
                           END;
                        END;
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        NULL;                 -- non ho trovato record ambigui
                  END;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;          -- non trovata ambiguita continuo i controlli
            END;
         END IF;
      END IF;                -- CODICE FISCALE  E PARTITA IVA   entrambe nulle
      RETURN v_ni_da_usare;
   END;
END;
/

