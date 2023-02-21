CREATE OR REPLACE TRIGGER ANAGRAFICI_STORICO_TIU
/******************************************************************************
             NOME:        ANAGRAFICI_STORICO_TIU
             DESCRIZIONE: Trigger for salvare dati storici
                                   at INSERT or UPDATE or DELETE on Table ANAGRAFICI_STORICO
             ECCEZIONI:
             ANNOTAZIONI: -
             REVISIONI:
             Rev. Data       Autore Descrizione
             ---- ---------- ------ ------------------------------------------------------
                1 21/12/2016 SNeg   Prima distribuzione
                2 27/02/2017 SNeg   Introduzione riferimento a BI (Before Image)
                3 27/08/2018 SNeg   Mantenuta traccia delle modifiche.
            ******************************************************************************/
   AFTER INSERT OR UPDATE OR DELETE
   ON ANAGRAFICI
   FOR EACH ROW
DECLARE
   integrity_error   EXCEPTION;
   errno             INTEGER;
   errmsg            CHAR (200);
   dummy             INTEGER;
   FOUND             BOOLEAN;
   d_id_evento       NUMBER;

   FUNCTION get_id_evento
      RETURN NUMBER
   IS
      v_id_evento   NUMBER;
   BEGIN
      SELECT anas_sq.NEXTVAL INTO v_id_evento FROM DUAL;

      RETURN v_id_evento;
   END;

   PROCEDURE inserisci (p_operazione       VARCHAR2,
                        p_info             VARCHAR2,
                        p_id_evento        NUMBER DEFAULT NULL,
                        p_id_evento_rif    NUMBER DEFAULT NULL)
   IS
      v_id_evento   NUMBER;
   BEGIN
      IF p_id_evento IS NULL
      THEN
         v_id_evento := get_id_evento;
      ELSE                                                -- passato id evento
         v_id_evento := p_id_evento;
      END IF;

      IF p_info = 'NEW'
      THEN
         INSERT INTO ANAGRAFICI_STORICO (ID_EVENTO,
                                         ID_ANAGRAFICA,
                                         NI,
                                         DAL,
                                         AL,
                                         COGNOME,
                                         NOME,
                                         SESSO,
                                         DATA_NAS,
                                         PROVINCIA_NAS,
                                         COMUNE_NAS,
                                         LUOGO_NAS,
                                         CODICE_FISCALE,
                                         CODICE_FISCALE_ESTERO,
                                         PARTITA_IVA,
                                         CITTADINANZA,
                                         GRUPPO_LING,
                                         COMPETENZA,
                                         COMPETENZA_ESCLUSIVA,
                                         TIPO_SOGGETTO,
                                         STATO_CEE,
                                         PARTITA_IVA_CEE,
                                         FINE_VALIDITA,
                                         STATO_SOGGETTO,
                                         DENOMINAZIONE,
                                         NOTE,
                                         VERSION,
                                         UTENTE,
                                         DATA_AGG,
                                         DATA,
                                         OPERAZIONE,
                                         BI_RIFERIMENTO,
                                         UTENTE_AGGIORNAMENTO,
                                         USER_ORACLE,
                                         INFO,
                                         PROGRAMMA)
                 VALUES (
                           v_id_evento,
                           :new.ID_ANAGRAFICA,
                           :new.NI,
                           :new.DAL,
                           :new.AL,
                           :new.COGNOME,
                           :new.NOME,
                           :new.SESSO,
                           :new.DATA_NAS,
                           :new.PROVINCIA_NAS,
                           :new.COMUNE_NAS,
                           :new.LUOGO_NAS,
                           :new.CODICE_FISCALE,
                           :new.CODICE_FISCALE_ESTERO,
                           :new.PARTITA_IVA,
                           :new.CITTADINANZA,
                           :new.GRUPPO_LING,
                           :new.COMPETENZA,
                           :new.COMPETENZA_ESCLUSIVA,
                           :new.TIPO_SOGGETTO,
                           :new.STATO_CEE,
                           :new.PARTITA_IVA_CEE,
                           :new.FINE_VALIDITA,
                           :new.STATO_SOGGETTO,
                           :new.DENOMINAZIONE,
                           :new.NOTE,
                           :new.VERSION,
                           :new.UTENTE,
                           :new.DATA_AGG,
                           SYSDATE,
                           p_operazione,
                           p_id_evento_rif,
                           SI4.UTENTE,
                           USER,
                           ad4_sessioni_pkg.get_info (
                              USERENV ('sessionid')),
                           ad4_sessioni_pkg.get_program (
                              USERENV ('sessionid')));
      ELSIF p_info = 'OLD'
      THEN
         INSERT INTO ANAGRAFICI_STORICO (ID_EVENTO,
                                         ID_ANAGRAFICA,
                                         NI,
                                         DAL,
                                         AL,
                                         COGNOME,
                                         NOME,
                                         SESSO,
                                         DATA_NAS,
                                         PROVINCIA_NAS,
                                         COMUNE_NAS,
                                         LUOGO_NAS,
                                         CODICE_FISCALE,
                                         CODICE_FISCALE_ESTERO,
                                         PARTITA_IVA,
                                         CITTADINANZA,
                                         GRUPPO_LING,
                                         COMPETENZA,
                                         COMPETENZA_ESCLUSIVA,
                                         TIPO_SOGGETTO,
                                         STATO_CEE,
                                         PARTITA_IVA_CEE,
                                         FINE_VALIDITA,
                                         STATO_SOGGETTO,
                                         DENOMINAZIONE,
                                         NOTE,
                                         VERSION,
                                         UTENTE,
                                         DATA_AGG,
                                         DATA,
                                         OPERAZIONE,
                                         BI_RIFERIMENTO,
                                         UTENTE_AGGIORNAMENTO,
                                         USER_ORACLE,
                                         INFO,
                                         PROGRAMMA)
                 VALUES (
                           v_id_evento,
                           :old.ID_ANAGRAFICA,
                           :old.NI,
                           :old.DAL,
                           :old.AL,
                           :old.COGNOME,
                           :old.NOME,
                           :old.SESSO,
                           :old.DATA_NAS,
                           :old.PROVINCIA_NAS,
                           :old.COMUNE_NAS,
                           :old.LUOGO_NAS,
                           :old.CODICE_FISCALE,
                           :old.CODICE_FISCALE_ESTERO,
                           :old.PARTITA_IVA,
                           :old.CITTADINANZA,
                           :old.GRUPPO_LING,
                           :old.COMPETENZA,
                           :old.COMPETENZA_ESCLUSIVA,
                           :old.TIPO_SOGGETTO,
                           :old.STATO_CEE,
                           :old.PARTITA_IVA_CEE,
                           :old.FINE_VALIDITA,
                           :old.STATO_SOGGETTO,
                           :old.DENOMINAZIONE,
                           :old.NOTE,
                           :old.VERSION,
                           :old.UTENTE,
                           :old.DATA_AGG,
                           SYSDATE,
                           p_operazione,
                           p_id_evento_rif,
                           SI4.UTENTE,
                           USER,
                           ad4_sessioni_pkg.get_info (
                              USERENV ('sessionid')),
                           ad4_sessioni_pkg.get_program (
                              USERENV ('sessionid')));
      END IF;
   END;
BEGIN
   -- Tengo sempre traccia delle modifiche
   IF INSERTING
   THEN
      inserisci (p_operazione => 'I', p_info => 'NEW');
   ELSIF DELETING
   THEN
      inserisci (p_operazione => 'D', p_info => 'OLD');
   ELSIF     UPDATING
         AND (   :new.ID_ANAGRAFICA != :old.ID_ANAGRAFICA
              OR :new.NI != :old.NI
              OR :new.DAL != :old.DAL
              OR NVL (:new.AL, TO_DATE ('3333333', 'j')) !=
                    NVL (:old.AL, TO_DATE ('3333333', 'j'))
              OR :new.COGNOME != :old.COGNOME
              OR NVL (:new.NOME, 'X') != NVL (:old.NOME, 'X')
              OR NVL (:new.SESSO, 'X') != NVL (:old.SESSO, 'X')
              OR NVL (:new.DATA_NAS, TO_DATE ('3333333', 'j')) !=
                    NVL (:old.DATA_NAS, TO_DATE ('3333333', 'j'))
              OR NVL (:new.PROVINCIA_NAS, -1) != NVL (:old.PROVINCIA_NAS, -1)
              OR NVL (:new.COMUNE_NAS, -1) != NVL (:old.COMUNE_NAS, -1)
              OR NVL (:new.LUOGO_NAS, 'X') != NVL (:old.LUOGO_NAS, 'X')
              OR NVL (:new.CODICE_FISCALE, 'X') !=
                    NVL (:old.CODICE_FISCALE, 'X')
              OR NVL (:new.CODICE_FISCALE_ESTERO, 'X') !=
                    NVL (:old.CODICE_FISCALE_ESTERO, 'X')
              OR NVL (:new.PARTITA_IVA, 'X') != NVL (:old.PARTITA_IVA, 'X')
              OR NVL (:new.CITTADINANZA, 'X') != NVL (:old.CITTADINANZA, 'X')
              OR NVL (:new.GRUPPO_LING, 'X') != NVL (:old.GRUPPO_LING, 'X')
              OR NVL (:new.COMPETENZA, 'X') != NVL (:old.COMPETENZA, 'X')
              OR NVL (:new.COMPETENZA_ESCLUSIVA, 'X') !=
                    NVL (:old.COMPETENZA_ESCLUSIVA, 'X')
              OR NVL (:new.TIPO_SOGGETTO, 'X') !=
                    NVL (:old.TIPO_SOGGETTO, 'X')
              OR NVL (:new.STATO_CEE, 'X') != NVL (:old.STATO_CEE, 'X')
              OR NVL (:new.PARTITA_IVA_CEE, 'X') !=
                    NVL (:old.PARTITA_IVA_CEE, 'X')
              OR NVL (:new.FINE_VALIDITA, TO_DATE ('3333333', 'j')) !=
                    NVL (:old.FINE_VALIDITA, TO_DATE ('3333333', 'j'))
              OR NVL (:new.STATO_SOGGETTO, 'X') !=
                    NVL (:old.STATO_SOGGETTO, 'X')
              OR NVL (:new.DENOMINAZIONE, 'X') !=
                    NVL (:old.DENOMINAZIONE, 'X')
              OR NVL (:new.NOTE, 'X') != NVL (:old.NOTE, 'X'))
   THEN
      d_id_evento := get_id_evento;
      inserisci (p_operazione   => 'BI',
                 p_info         => 'OLD',
                 p_id_evento    => d_id_evento);
      inserisci (p_operazione      => 'AI',
                 p_info            => 'NEW',
                 p_id_evento       => NULL,
                 p_id_evento_rif   => d_id_evento);
   END IF;
END;
/


