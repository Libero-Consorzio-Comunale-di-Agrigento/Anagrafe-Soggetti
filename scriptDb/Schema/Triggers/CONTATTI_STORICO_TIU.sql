CREATE OR REPLACE TRIGGER CONTATTI_STORICO_TIU
/******************************************************************************
             NOME:        CONTATTI_STORICO_TIU
             DESCRIZIONE: Trigger for salvare dati storici
                                   at INSERT or UPDATE or DELETE on Table CONTATTI_STORICO
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
   ON CONTATTI
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
         INSERT INTO CONTATTI_STORICO (ID_EVENTO,
                                       ID_CONTATTO,
                                       ID_RECAPITO,
                                       DAL,
                                       AL,
                                       VALORE,
                                       ID_TIPO_CONTATTO,
                                       NOTE,
                                       IMPORTANZA,
                                       COMPETENZA,
                                       COMPETENZA_ESCLUSIVA,
                                       VERSION,
                                       UTENTE_AGG,
                                       DATA_AGGIORNAMENTO,
                                       DATA,
                                       OPERAZIONE,
                                       BI_RIFERIMENTO,
                                       UTENTE_AGGIORNAMENTO,
                                       USER_ORACLE,
                                       INFO,
                                       PROGRAMMA)
                 VALUES (
                           v_id_evento,
                           :new.ID_CONTATTO,
                           :new.ID_RECAPITO,
                           :new.DAL,
                           :new.AL,
                           :new.VALORE,
                           :new.ID_TIPO_CONTATTO,
                           :new.NOTE,
                           :new.IMPORTANZA,
                           :new.COMPETENZA,
                           :new.COMPETENZA_ESCLUSIVA,
                           :new.VERSION,
                           :new.UTENTE_AGGIORNAMENTO,
                           :new.DATA_AGGIORNAMENTO,
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
         INSERT INTO CONTATTI_STORICO (ID_EVENTO,
                                       ID_CONTATTO,
                                       ID_RECAPITO,
                                       DAL,
                                       AL,
                                       VALORE,
                                       ID_TIPO_CONTATTO,
                                       NOTE,
                                       IMPORTANZA,
                                       COMPETENZA,
                                       COMPETENZA_ESCLUSIVA,
                                       VERSION,
                                       UTENTE_AGG,
                                       DATA_AGGIORNAMENTO,
                                       DATA,
                                       OPERAZIONE,
                                       BI_RIFERIMENTO,
                                       UTENTE_AGGIORNAMENTO,
                                       USER_ORACLE,
                                       INFO,
                                       PROGRAMMA)
                 VALUES (
                           v_id_evento,
                           :old.ID_CONTATTO,
                           :old.ID_RECAPITO,
                           :old.DAL,
                           :old.AL,
                           :old.VALORE,
                           :old.ID_TIPO_CONTATTO,
                           :old.NOTE,
                           :old.IMPORTANZA,
                           :old.COMPETENZA,
                           :old.COMPETENZA_ESCLUSIVA,
                           :old.VERSION,
                           :old.UTENTE_AGGIORNAMENTO,
                           :old.DATA_AGGIORNAMENTO,
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
         AND (   :new.ID_CONTATTO != :old.ID_CONTATTO
              OR :new.ID_CONTATTO != :old.ID_CONTATTO
              OR :new.ID_RECAPITO != :old.ID_RECAPITO
              OR :new.DAL != :old.DAL
              OR NVL (:new.AL, TO_DATE ('3333333', 'j')) !=
                    NVL (:old.AL, TO_DATE ('3333333', 'j'))
              OR :new.VALORE != :old.VALORE
              OR :new.ID_TIPO_CONTATTO != :old.ID_TIPO_CONTATTO
              OR NVL (:new.NOTE, 'X') != NVL (:old.NOTE, 'X')
              OR NVL (:new.IMPORTANZA, -1) != NVL (:old.IMPORTANZA, -1)
              OR NVL (:new.COMPETENZA, 'X') != NVL (:old.COMPETENZA, 'X')
              OR NVL (:new.COMPETENZA_ESCLUSIVA, 'X') !=
                    NVL (:old.COMPETENZA_ESCLUSIVA, 'X')
              OR NVL (:new.VERSION, -1) != NVL (:old.VERSION, -1)
              OR NVL (:new.UTENTE_AGGIORNAMENTO, 'X') !=
                    NVL (:old.UTENTE_AGGIORNAMENTO, 'X')
              OR NVL (:new.DATA_AGGIORNAMENTO, TO_DATE ('3333333', 'j')) !=
                    NVL (:old.DATA_AGGIORNAMENTO, TO_DATE ('3333333', 'j')))
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


