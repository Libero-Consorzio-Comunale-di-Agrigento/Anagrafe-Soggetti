CREATE OR REPLACE PACKAGE BODY Registro_Utility IS
/******************************************************************************
 NOME:        .
 DESCRIZIONE: .
 ANNOTAZIONI: .
 REVISIONI: .
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 001  03/11/2005 MF     Inserimento funzioni di gestione "preferenza" e revisione
                        sintassi.
 002 21/11/2005  MM     Inserimento funzione copia_chiave
 003 25/09/2006  MM     Modifica funzione copia_chiave e
                        inserimento funzione get_sequenza_ordinamento
******************************************************************************/
   s_revisione_body CONSTANT VARCHAR2(30) := '003';
   s_predefinita   VARCHAR2(2000) := '(Predefinito)';
   e_stringa_not_found EXCEPTION;
   PRAGMA EXCEPTION_INIT( e_stringa_not_found, -20932 );
--
-- Funzioni private
--
PROCEDURE raise_err_registro
( in_errore      IN NUMBER
, in_riferimento IN VARCHAR2 DEFAULT NULL
) IS /* SLAVE_COPY */
   err_codice   NUMBER(10)       := in_errore;
   err_testo   VARCHAR2(2000);
BEGIN
   IF in_errore > 0 THEN
      err_codice:= in_errore*(-1);
   END IF;
   IF    err_codice = -20901 THEN
      err_testo := 'DB User non specificato';
   ELSIF err_codice = -20902 THEN
      err_testo := 'SI4 User non specificato';
   ELSIF err_codice = -20910 THEN
      err_testo := 'Radice "'||in_riferimento||'" non prevista';
   ELSIF err_codice = -20916 THEN
      err_testo := 'Impossibile alterare le radici del registro';
   ELSIF err_codice = -20919 THEN
      err_testo := 'Impossibile eliminare radici registro';
   ELSIF err_codice = -20921 THEN
      err_testo := 'Chiave "'||in_riferimento||'" gia esistente';
   ELSIF err_codice = -20922 THEN
      err_testo := 'Chiave "'||in_riferimento||'" non trovata';
   ELSIF err_codice = -20923 THEN
      err_testo := 'Chiave "'||in_riferimento||'" incompleta';
   ELSIF err_codice = -20925 THEN
      err_testo := 'Nome chiave non valido. Non utilizzare il separatore "/"';
   ELSIF err_codice = -20926 THEN
      err_testo := 'Errore creazione chiave "'||in_riferimento||'"';
   ELSIF err_codice = -20927 THEN
      err_testo := 'Errore creazione chiave parziale "'||in_riferimento||'"';
   ELSIF err_codice = -20931 THEN
      err_testo := 'Stringa "'||in_riferimento||'" gia esistente';
   ELSIF err_codice = -20932 THEN
      err_testo := 'Stringa "'||in_riferimento||'" non trovata';
   ELSIF err_codice = -20936 THEN
      err_testo := 'Errore variazione stringa "'||in_riferimento||'"';
   ELSIF err_codice = -20939 THEN
      err_testo := 'Impossibile eliminare la stringa predefinita';
   ELSE
      err_testo := 'Errore non documentato';
   END IF;
   RAISE_APPLICATION_ERROR(err_codice,err_testo);
END raise_err_registro;
--
PROCEDURE valida_chiave
(in_chiave      VARCHAR2
)
IS /* SLAVE_COPY */
BEGIN
   IF INSTR(in_chiave,'/') = 0 THEN
      raise_err_registro(20916);
   END IF;
   IF in_chiave LIKE 'DB_USERS/%'
   OR in_chiave LIKE 'SI4_USERS/%'
   OR in_chiave LIKE 'SI4_DB_USERS/%'
   OR in_chiave LIKE 'PRODUCTS/%' THEN
      NULL;
   ELSE
      raise_err_registro(20910,SUBSTR(in_chiave,1,INSTR(in_chiave,'/')-1));
   END IF;
   IF in_chiave LIKE '%/' THEN
      raise_err_registro(20923,in_chiave);
   END IF;
END valida_chiave;
--
FUNCTION verifica_chiave
( in_chiave   VARCHAR2
) RETURN BOOLEAN IS /* SLAVE_COPY */
   plsqlappoggio   NUMBER(1);
BEGIN
   /* Controllo esistenza  chiave */
   SELECT 1 INTO plsqlappoggio
     FROM REGISTRO
    WHERE chiave = in_chiave
   ;
   RETURN TRUE;
EXCEPTION
WHEN TOO_MANY_ROWS THEN
   RETURN TRUE;
WHEN NO_DATA_FOUND THEN
   RETURN FALSE;
END verifica_chiave;
FUNCTION is_number
( p_char IN VARCHAR2
) RETURN NUMBER IS /* SLAVE_COPY */
/******************************************************************************
 NOME:        is_number
 VISIBILITA': privata
 DESCRIZIONE: Verifica che la stringa passata sia un numero.
 PARAMETRI:   p_char: varchar2 stringa da controllare.
 RITORNA:     number 1: e' un numero
                     0: NON e' un numero
 NOTE:        in caso che p_char sia nullo, la funzione ritorna 1.
******************************************************************************/
   d_result    NUMBER := 1;
   d_test      NUMBER;
BEGIN
   d_test := TO_NUMBER(p_char);
   RETURN d_result;
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -6502 THEN
         RETURN 0;
      ELSE
         RAISE;
      END IF;
END is_number;
--
-- Funzioni pubbliche
--
FUNCTION versione RETURN VARCHAR2 IS /* SLAVE_COPY */
/******************************************************************************
 NOME:        versione.
 DESCRIZIONE: Restituisce versione e revisione di distribuzione del package.
 RITORNA:     VARCHAR2 stringa contenente versione e revisione.
 NOTE:        Primo numero  : versione compatibilita del Package.
              Secondo numero: revisione del Package specification.
              Terzo numero  : revisione del Package body.
******************************************************************************/
BEGIN
   RETURN s_revisione||'.'||NVL(s_revisione_body,'000');
END versione;
--
FUNCTION livello_chiave
( in_chiave      VARCHAR2
) RETURN NUMBER IS /* SLAVE_COPY */
  posizione  NUMBER(5);
BEGIN
  posizione := INSTR(in_chiave,'/');
  IF posizione > 0 THEN
    RETURN 1+livello_chiave(SUBSTR(in_chiave,posizione+1));
  ELSE
    RETURN 0;
  END IF;
END livello_chiave;
--
FUNCTION trasforma_chiave
( in_chiave      VARCHAR2
) RETURN VARCHAR2 IS /* SLAVE_COPY */
BEGIN
   RETURN trasforma_chiave(in_chiave,NULL,UPPER(USER));
END trasforma_chiave;
--
FUNCTION trasforma_chiave
( in_chiave      VARCHAR2
, in_si4_user    VARCHAR2
, in_db_user     VARCHAR2   DEFAULT NULL
)
RETURN VARCHAR2
IS /* SLAVE_COPY */
   chiave_reale   VARCHAR2(2000) := in_chiave;
BEGIN
   IF in_chiave LIKE 'LOCAL_DB_USER/%' THEN
      IF in_db_user IS NULL THEN
         raise_err_registro(20901);
      END IF;
      chiave_reale := 'DB_USERS/'||in_db_user||SUBSTR(in_chiave,INSTR(in_chiave,'/'));
   END IF;
   IF in_chiave LIKE 'LOCAL_SI4_USER/%' THEN
      IF in_si4_user IS NULL THEN
         raise_err_registro(20902);
      END IF;
      chiave_reale := 'SI4_USERS/'||in_si4_user||SUBSTR(in_chiave,INSTR(in_chiave,'/'));
   END IF;
   IF in_chiave LIKE 'CURRENT_USER/%' THEN
      IF in_si4_user IS NULL THEN
         raise_err_registro(20902);
      END IF;
      IF in_db_user IS NULL THEN
         raise_err_registro(20901);
      END IF;
      chiave_reale := 'SI4_DB_USERS/'||in_si4_user||'|'||in_db_user||SUBSTR(in_chiave,INSTR(in_chiave,'/'));
   END IF;
   RETURN chiave_reale;
END trasforma_chiave;
--
PROCEDURE crea_chiave
( in_chiave      IN   VARCHAR2
, in_eccezione   IN   BOOLEAN    DEFAULT TRUE
) IS
   duplicazione   EXCEPTION;
   chiave_reale   VARCHAR2(2000);
   chiave_parziale   VARCHAR2(2000);
BEGIN
   chiave_reale := trasforma_chiave(in_chiave);
   valida_chiave(chiave_reale);
   /* Controllo duplicazione chiave */
   IF verifica_chiave(chiave_reale) THEN
      RAISE duplicazione;
   END IF;
   /* Creazioni chiavi parziali */
   chiave_parziale := chiave_reale;
   WHILE INSTR(chiave_parziale,'/') > 0
   LOOP
      chiave_parziale := SUBSTR(chiave_parziale,1,INSTR(chiave_parziale,'/',-1)-1);
      /* Controllo esistenza chiave parziale */
      IF verifica_chiave(chiave_parziale) THEN
         EXIT;
      END IF;
      /* Creazione */
      BEGIN
         INSERT INTO REGISTRO
            (chiave,
             stringa
            )
         VALUES
            (chiave_parziale,
             s_predefinita
            )
         ;
      EXCEPTION WHEN OTHERS THEN
         raise_err_registro(20927,chiave_parziale);
      END;
   END LOOP;
   /* Creazione chiave terminale */
   BEGIN
      INSERT INTO REGISTRO
         (chiave,
          stringa
         )
      VALUES
         (chiave_reale,
          '(Predefinito)'
         )
      ;
   EXCEPTION WHEN OTHERS THEN
      raise_err_registro(20926,chiave_reale);
   END;
EXCEPTION WHEN duplicazione THEN
   IF in_eccezione THEN
      raise_err_registro(20921,chiave_reale);
   END IF;
END crea_chiave;
--
PROCEDURE crea_chiave
( in_chiave      IN   VARCHAR2
, in_eccezione   IN   NUMBER
) IS
BEGIN
   crea_chiave(in_chiave, in_eccezione = 1);
END crea_chiave;
--
PROCEDURE elimina_chiave
(in_chiave      IN   VARCHAR2,
 in_eccezione   IN   BOOLEAN    DEFAULT TRUE
) IS
   chiave_reale   VARCHAR2(2000);
BEGIN
   chiave_reale := trasforma_chiave(in_chiave);
   valida_chiave(chiave_reale);
   IF INSTR(chiave_reale,'/') = 0 THEN
      raise_err_registro(20916);
   END IF;
   DELETE REGISTRO
    WHERE chiave    = chiave_reale
       OR chiave LIKE chiave_reale||'/%'
   ;
   IF SQL%rowcount = 0 THEN
      IF in_eccezione THEN
         raise_err_registro(20922,chiave_reale);
      END IF;
   END IF;
END elimina_chiave;
--
PROCEDURE elimina_chiave
( in_chiave      IN   VARCHAR2
, in_eccezione   IN   NUMBER
) IS
BEGIN
   elimina_chiave(in_chiave, in_eccezione = 1);
END elimina_chiave;
--
PROCEDURE rinomina_chiave
(in_chiave      IN   VARCHAR2,
 in_nuovo_nome  IN    VARCHAR2,
 in_eccezione   IN   BOOLEAN     DEFAULT TRUE
) IS
   radice_reale   VARCHAR2(2000);
   chiave_reale   VARCHAR2(2000);
BEGIN
   chiave_reale := trasforma_chiave(in_chiave);
   valida_chiave(chiave_reale);
   IF INSTR(chiave_reale,'/') = 0 THEN
      raise_err_registro(20916);
   END IF;
   IF INSTR(in_nuovo_nome,'/') > 0 THEN
      raise_err_registro(20925);
   END IF;
   IF NOT verifica_chiave(chiave_reale) THEN
      IF in_eccezione THEN
         raise_err_registro(20922,chiave_reale);
      END IF;
   END IF;
   radice_reale := SUBSTR(chiave_reale,1,INSTR(chiave_reale,'/',-1)-1);
   UPDATE REGISTRO
      SET chiave = REPLACE(chiave,chiave_reale,radice_reale||'/'||in_nuovo_nome)
    WHERE chiave    = radice_reale
       OR chiave LIKE radice_reale||'/%'
   ;
   IF SQL%rowcount = 0 THEN
      IF in_eccezione THEN
         raise_err_registro(20922,chiave_reale);
      END IF;
   END IF;
END rinomina_chiave;
--
PROCEDURE rinomina_chiave
( in_chiave      IN   VARCHAR2
, in_nuovo_nome  IN   VARCHAR2
, in_eccezione   IN   NUMBER
) IS
BEGIN
   rinomina_chiave(in_chiave, in_nuovo_nome, in_eccezione = 1);
END rinomina_chiave;
--
PROCEDURE leggi_stringa
( in_chiave     IN   VARCHAR2
, in_stringa    IN   VARCHAR2
, out_valore    OUT  VARCHAR2
, in_eccezione  IN   BOOLEAN    DEFAULT TRUE
) IS /* SLAVE_COPY */
   chiave_reale   VARCHAR2(2000);
   chiave         VARCHAR2(2000);
BEGIN
   chiave := UPPER(in_chiave);
   chiave_reale := trasforma_chiave(chiave);
   valida_chiave(chiave_reale);
   SELECT valore
     INTO out_valore
     FROM REGISTRO
    WHERE chiave    = chiave_reale
      AND UPPER(stringa)   = UPPER(in_stringa)
   ;
EXCEPTION WHEN NO_DATA_FOUND THEN
   IF  in_eccezione THEN
      IF verifica_chiave(chiave_reale) THEN
         raise_err_registro(20932,in_stringa);
      ELSE
         raise_err_registro(20922,chiave_reale);
      END IF;
   ELSE
      out_valore := NULL;
   END IF;
END leggi_stringa;
--
FUNCTION leggi_stringa
( in_chiave    IN   VARCHAR2
, in_stringa   IN   VARCHAR2
, in_eccezione IN   NUMBER
) RETURN VARCHAR2 IS /* SLAVE_COPY */
  out_valore VARCHAR2(2000);
BEGIN
  leggi_stringa(in_chiave, in_stringa, out_valore, in_eccezione = 1);
  RETURN out_valore;
END leggi_stringa;
--
PROCEDURE scrivi_stringa
( in_chiave     IN   VARCHAR2
, in_stringa    IN   VARCHAR2
, in_valore     IN   VARCHAR2
, in_commento   IN   VARCHAR2  DEFAULT NULL
, in_eccezione  IN   BOOLEAN   DEFAULT TRUE
) IS
   chiave_reale   VARCHAR2(2000);
BEGIN
   chiave_reale := trasforma_chiave(in_chiave);
   valida_chiave(chiave_reale);
   /* Controllo esistenza chiave */
   IF NOT verifica_chiave(chiave_reale) THEN
      IF in_eccezione THEN
         raise_err_registro(20922,chiave_reale);
      ELSE
         crea_chiave(chiave_reale,FALSE);
      END IF;
   END IF;
   /* Creazione stringa */
   BEGIN
      INSERT INTO REGISTRO
         (chiave,
          stringa,
          valore,
          commento
         )
      VALUES
         (chiave_reale,
          in_stringa,
          in_valore,
          in_commento
         )
      ;
   EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
      IF in_eccezione THEN
         raise_err_registro(20931,in_stringa);
      ELSE
         UPDATE REGISTRO
            SET valore   = in_valore,
                commento = NVL(in_commento,commento)
          WHERE chiave   = chiave_reale
            AND stringa  = in_stringa
         ;
         IF SQL%rowcount != 1 THEN
            raise_err_registro(20936,in_stringa);
         END IF;
      END IF;
   END;
END scrivi_stringa;
--
PROCEDURE scrivi_stringa
( in_chiave      IN   VARCHAR2
, in_stringa     IN   VARCHAR2
, in_valore      IN   VARCHAR2
, in_commento    IN   VARCHAR2
, in_eccezione   IN   NUMBER
) IS
BEGIN
   scrivi_stringa(in_chiave, in_stringa, in_valore, in_commento, in_eccezione = 1);
END scrivi_stringa;
--
PROCEDURE elimina_stringa
( in_chiave      IN   VARCHAR2
, in_stringa     IN   VARCHAR2
, in_eccezione   IN   BOOLEAN    DEFAULT TRUE
) IS
   chiave_reale   VARCHAR2(2000);
BEGIN
   IF in_stringa = s_predefinita THEN
      raise_err_registro(20939);
   END IF;
   chiave_reale := trasforma_chiave(in_chiave);
   valida_chiave(chiave_reale);
   DELETE REGISTRO
    WHERE chiave   = chiave_reale
      AND stringa    = in_stringa
   ;
   IF SQL%rowcount = 0 THEN
      IF in_eccezione THEN
         IF verifica_chiave(chiave_reale) THEN
            raise_err_registro(20932,in_stringa);
         ELSE
            raise_err_registro(20922,chiave_reale);
         END IF;
      END IF;
   END IF;
END elimina_stringa;
--
PROCEDURE elimina_stringa
( in_chiave      IN   VARCHAR2
, in_stringa     IN   VARCHAR2
, in_eccezione   IN   NUMBER
) IS
BEGIN
   elimina_stringa(in_chiave, in_stringa, in_eccezione = 1);
END elimina_stringa;
--
FUNCTION get_stringa
( in_chiave     VARCHAR2
, in_stringa    VARCHAR2
) RETURN VARCHAR2 IS /* SLAVE_COPY */
/***********************************************************************************************
 NOME:        get_stringa
 DESCRIZIONE: Ritorna il valore di una stringa per la chiave indicata.
 PARAMETRI:   p_chiave    VARCHAR2  Chiave di accesso al Registro
              p_stringa   VARCHAR2  Nome della Stringa del Registro
 RITORNA:     VARCHAR2  : valore della stringa
************************************************************************************************/
   d_result VARCHAR2(2000);
BEGIN
  BEGIN
     leggi_stringa(in_chiave, in_stringa, d_result, TRUE);
  EXCEPTION
     WHEN e_stringa_not_found THEN -- se viene intercettata una NOT FOUND riemette eccezione
                                   -- (comportamento standard per le funzioni "get_" in DbC)
        RAISE NO_DATA_FOUND;
  END;
  RETURN d_result;
END get_stringa;
--
FUNCTION get_preferenza
( p_stringa VARCHAR2
, p_modulo  VARCHAR2 DEFAULT NULL
, p_utente  VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2 IS /* SLAVE_COPY */
/***********************************************************************************************
 NOME:        get_preferenza
 DESCRIZIONE: Trova una preferenza a livello di utente di sistema,
              se non e' definito l'utente cerca a livello di DB User,
              se e indicato il modulo cerca sulla chiave PRODUCT/NomeModulo.
 PARAMETRI:   p_stringa   VARCHAR2  Nome preferenza
              p_modulo    VARCHAR2  Modulo di sistema per il quale cercare la chiave
              p_utente    VARCHAR2  Nome utente di sistema
 RITORNA:     VARCHAR2  : valore della preferenza
************************************************************************************************/
   d_valore VARCHAR2(2000);
   d_chiave VARCHAR2(512);
BEGIN
   -- Ricerca preferenza a livello utente di sistema
   d_valore := Registro_Utility.get_preferenza_SI4_DB_USERS (p_stringa, p_modulo , p_utente);
   -- Ricerca preferenza a livello di db user
   IF d_valore IS NULL THEN
      d_valore := Registro_Utility.get_preferenza_DB_USERS (p_stringa, p_modulo);
   END IF;
   -- Ricerca preferenza a livello generale per lo specifico modulo
   IF d_valore IS NULL AND p_modulo IS NOT NULL THEN
      d_chiave := 'PRODUCTS/'||UPPER(p_modulo);
      leggi_stringa (d_chiave,p_stringa, d_valore, FALSE);
   END IF;
   RETURN d_valore;
END get_preferenza;
--
FUNCTION get_preferenza_SI4_DB_USERS
( p_stringa VARCHAR2
, p_modulo  VARCHAR2 DEFAULT NULL
, p_utente  VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2 IS /* SLAVE_COPY */
/***********************************************************************************************
 NOME:        get_preferenza_SI4_DB_USER
 DESCRIZIONE: Trova una preferenza a livello di utente di sistema con chiave
                 SI4_DB_USERS/NomeSi4User|NomeUser/PRODUCTS/NomeModulo
              o in seconda istanza
                 SI4_DB_USERS/NomeSi4User|NomeUser.
 PARAMETRI:   P_STRINGA   VARCHAR2  Nome preferenza
              P_MODULO    VARCHAR2  Modulo AD4 per il quale cercare la chiave.
              P_UTENTE    VARCHAR2  Codice utente AD4
 RITORNA:     VARCHAR2  : valore della preferenza
************************************************************************************************/
   d_valore VARCHAR2(2000) := '';
   d_chiave VARCHAR2(512);
BEGIN
   -- Ricerca preferenza a livello utente di sistema con e senza modulo
   IF p_utente IS NOT NULL AND p_modulo IS NOT NULL THEN
      d_chiave := 'SI4_DB_USERS/'||p_utente||'|'||USER||'/PRODUCTS/'||UPPER(p_modulo);
      leggi_stringa (d_chiave,p_stringa, d_valore, FALSE);
   END IF;
   IF p_utente IS NOT NULL AND d_valore IS NULL THEN
      d_chiave := 'SI4_DB_USERS/'||p_utente||'|'||USER;
      leggi_stringa (d_chiave,p_stringa, d_valore, FALSE);
   END IF;
   RETURN d_valore;
END get_preferenza_SI4_DB_USERS;
--
FUNCTION get_preferenza_DB_USERS
( p_stringa VARCHAR2
, p_modulo  VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2 IS /* SLAVE_COPY */
/***********************************************************************************************
 NOME:        get_preferenza_DB_USER
 DESCRIZIONE: Trova una preferenza a livello di DB User con chiave
                 DB_USER|NomeUser/PRODUCTS/NomeModulo
              o in seconda istanza la chiave
                 DB_USER|NomeUser.
 PARAMETRI:   P_STRINGA   VARCHAR2  Nome preferenza
              P_MODULO    VARCHAR2  Modulo AD4 per il quale cercare la chiave
 RITORNA:     VARCHAR2  : valore della preferenza
************************************************************************************************/
   d_valore VARCHAR2(2000) := '';
   d_chiave VARCHAR2(512);
BEGIN
   -- Ricerca preferenza a livello di db user con e senza modulo
   IF p_modulo IS NOT NULL THEN
      d_chiave := 'DB_USERS/'||USER||'/PRODUCTS/'||UPPER(p_modulo);
      leggi_stringa (d_chiave,p_stringa, d_valore, FALSE);
   END IF;
   IF d_valore IS NULL THEN
      d_chiave := 'DB_USERS/'||USER;
      leggi_stringa (d_chiave,p_stringa, d_valore, FALSE);
   END IF;
   RETURN d_valore;
END get_preferenza_DB_USERS;
--
FUNCTION  is_preferenza
( p_stringa VARCHAR2
, p_modulo  VARCHAR2 DEFAULT NULL
, p_utente  VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2 IS /* SLAVE_COPY */
/***********************************************************************************************
 NOME:        is_preferenza
 DESCRIZIONE: Verifica che la preferenza sia stata impostata specificamente per i parametri
              passati.
 PARAMETRI:   P_STRINGA   VARCHAR2  Nome preferenza
              P_MODULO    VARCHAR2  Modulo AD4 per il quale cercare la chiave
 RITORNA:     VARCHAR2  : 1 preferenza impostata, 0 preferenza non impostata
************************************************************************************************/
   d_valore VARCHAR2(2000);
   d_chiave VARCHAR2(512);
BEGIN
   -- Ricerca preferenza a livello utente di sistema
   IF p_utente IS NOT NULL AND p_modulo IS NOT NULL THEN
      d_chiave := 'SI4_DB_USERS/'||p_utente||'|'||USER||'/PRODUCTS/'||UPPER(p_modulo);
      leggi_stringa (d_chiave,p_stringa, d_valore, FALSE);
     IF d_valore IS NOT NULL THEN
        RETURN 1;
     ELSE
        RETURN 0;
     END IF;
   END IF;
   -- Ricerca preferenza a livello di db user
   IF p_modulo IS NOT NULL THEN
      d_chiave := 'DB_USERS/'||USER||'/PRODUCTS/'||UPPER(p_modulo);
      leggi_stringa (d_chiave,p_stringa, d_valore, FALSE);
     IF d_valore IS NOT NULL THEN
        RETURN 1;
     ELSE
        RETURN 0;
     END IF;
   ELSE
      d_chiave := 'DB_USERS/'||USER;
      leggi_stringa (d_chiave,p_stringa, d_valore, FALSE);
      IF d_valore IS NOT NULL THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END IF;
END is_preferenza;
--
PROCEDURE set_preferenza
( p_stringa VARCHAR2
, p_valore  VARCHAR2
, p_modulo  VARCHAR2 DEFAULT NULL
, p_utente  VARCHAR2 DEFAULT NULL
) IS
/***********************************************************************************************
 NOME:        set_preferenza
 DESCRIZIONE: Registra una preferenza a livello di utente di sistema,
              se non e' definito l'utente registra a livello di DB user,
              se e indicato il modulo aggiunge PRODUCT/NomeModulo.
 ARGOMENTI:   p_stringa   VARCHAR2  Nome preferenza
              p_valore    VARCHAR2  Valore preferenza
              p_modulo    VARCHAR2  Modulo di sistema per il quale cercare la chiave
              p_utente    VARCHAR2  Nome utente di sistema
************************************************************************************************/
   d_chiave   VARCHAR2(512);
BEGIN
   -- Composizione della chiave con cui andare a scrivere su registro
   IF p_utente IS NOT NULL THEN
      d_chiave := 'SI4_DB_USERS/'||p_utente||'|'||USER;
      IF p_modulo IS NOT NULL THEN
         d_chiave := d_chiave||'/PRODUCTS/'||UPPER(p_modulo);
     END IF;
   ELSE
      d_chiave := 'DB_USERS/'||USER;
      IF p_modulo IS NOT NULL THEN
         d_chiave := d_chiave||'/PRODUCTS/'||UPPER(p_modulo);
     END IF;
   END IF;
   crea_chiave(d_chiave, FALSE);
   elimina_stringa(d_chiave ,p_stringa, FALSE);
   -- Se il valore della preferenza e gia presente a livello piu generale non si effettua la registrazione.
   IF p_valore != NVL(get_preferenza (p_stringa, p_modulo, p_utente),' ') THEN
         scrivi_stringa(d_chiave, p_stringa, p_valore);
   END IF;
END set_preferenza;
FUNCTION get_sequenza_ordinamento
/***********************************************************************************************
 NOME:        get_sequenza_ordinamento
 DESCRIZIONE: Recupera la sequenza di ordinamento della stringa di una chiave leggendo gli
              ultimi caratteri della colonna commento.
              Se sono '(<numero>)' numero e' la sequenza di ordinamento della stringa all'interno
              della chiave.
 PARAMETRI:   campi chiave.
 RITORNA:     NUMBER  : sequenza
************************************************************************************************/
( p_chiave IN VARCHAR2
, p_stringa IN VARCHAR2)
RETURN NUMBER
IS /* SLAVE_COPY */
   d_seq      NUMBER;
   d_commento VARCHAR2(4000);
   i          INTEGER := -2;
BEGIN
   SELECT commento
     INTO d_commento
     FROM REGISTRO
    WHERE chiave = p_chiave
      AND LOWER(stringa) = LOWER(p_stringa)
   ;
   IF SUBSTR(d_commento, -1, 1) = ')' THEN
      WHILE is_number(SUBSTR(d_commento, i, 1)) = 1 LOOP
         d_seq := TO_NUMBER(SUBSTR(d_commento, i, -(i + 1)));
       i := i - 1;
      END LOOP;
   END IF;
   RETURN d_seq;
END get_sequenza_ordinamento;
PROCEDURE copia_chiave
/***********************************************************************************************
 NOME:        copia_chiave
 DESCRIZIONE: Copia la struttura di una chiave in un'altra; la chiave creata puo' sostituire
              l'esistente o essere solo copiata (a seconda del valore di in_sostituisci); possono
              essere copiati anche i valori delle stringhe della chiave di partenza o solo la
              struttura(a seconda del valore di in_copia_valori).
 ARGOMENTI:   in_chiave_from      VARCHAR2  Chiave da copiare/sostituire
              in_chiave_to        VARCHAR2  Chiave in cui copiare o che sostituisce
              in_sostituisci      NUMBER    1 in_chiave_to viene sostituita a in_chiave_from
                                            0 in_chiave_to viene creata con la stessa struttura
                                              di in_chiave_from.
                                            default: 1
              in_copia_valori     NUMBER    1 copia anche i valori delle stringhe di in_chiave_from
                                            0 copia solo la struttura di in_chiave_from in in_chiave_to
                                            default: 1
************************************************************************************************/
(in_chiave_from   IN   VARCHAR2,
 in_chiave_to     IN   VARCHAR2,
 in_sostituisci   IN   NUMBER    DEFAULT 1,
 in_copia_valori  IN   NUMBER    DEFAULT 1
) IS
   chiave_reale_from VARCHAR2(2000);
   chiave_padre_from VARCHAR2(2000);
   chiave_reale_to   VARCHAR2(2000);
BEGIN
   IF in_chiave_to IS NULL THEN
      raise_err_registro(20916);
   END IF;
   chiave_reale_to := trasforma_chiave(in_chiave_to);
   chiave_reale_from := trasforma_chiave(in_chiave_from);
   valida_chiave(chiave_reale_from);
   IF INSTR(chiave_reale_from,'/') = 0 THEN
      raise_err_registro(20916);
   END IF;
   chiave_padre_from := SUBSTR(chiave_reale_from, 1, INSTR(chiave_reale_from, '/' ,-1) -1);
   FOR c_chiave IN (SELECT chiave, stringa, DECODE(in_copia_valori, 1, valore, '') valore, commento
                      FROM REGISTRO
                     WHERE chiave    = chiave_reale_from
                        OR chiave LIKE chiave_reale_from||'/%') LOOP
      BEGIN
         INSERT INTO REGISTRO (chiave, stringa, valore, commento)
         VALUES (REPLACE(c_chiave.chiave, chiave_padre_from, chiave_reale_to), c_chiave.stringa, c_chiave.valore, c_chiave.commento)
         ;
      EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
         IF in_sostituisci = 1 THEN
            UPDATE REGISTRO
               SET valore  = c_chiave.valore
             WHERE chiave  = REPLACE(c_chiave.chiave, chiave_padre_from, chiave_reale_to)
               AND stringa = c_chiave.stringa
            ;
         ELSE
            NULL;
         END IF;
      END;
   END LOOP;
END copia_chiave;
END Registro_Utility;
/

