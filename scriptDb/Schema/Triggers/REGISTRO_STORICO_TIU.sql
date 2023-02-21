CREATE OR REPLACE TRIGGER REGISTRO_STORICO_TIU
/******************************************************************************
              NOME:        REGISTRO_STORICO_TIU
              DESCRIZIONE: Trigger for salvare dati storici
                                    at INSERT or UPDATE or DELETE on Table REGISTRO
              ECCEZIONI:
              ANNOTAZIONI: -
              REVISIONI:
              Rev. Data       Autore Descrizione
              ---- ---------- ------ ------------------------------------------------------
                 1 12/03/2020 SNeg   Prima distribuzione
             ******************************************************************************/
    AFTER INSERT OR UPDATE OR DELETE
    ON REGISTRO
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
        SELECT REST_SQ.NEXTVAL INTO v_id_evento FROM DUAL;

        RETURN v_id_evento;
    END;

    PROCEDURE inserisci (p_operazione      VARCHAR2,
                         p_info            VARCHAR2,
                         p_id_evento       NUMBER DEFAULT NULL,
                         p_id_evento_rif   NUMBER DEFAULT NULL)
    IS
        v_id_evento   NUMBER;
    BEGIN
        IF p_id_evento IS NULL
        THEN
            v_id_evento := get_id_evento;
        ELSE                                              -- passato id evento
            v_id_evento := p_id_evento;
        END IF;

        IF p_info = 'NEW'
        THEN
            INSERT INTO REGISTRO_STORICO (ID_EVENTO,
                                        CHIAVE,
                                        STRINGA,
                                        COMMENTO,
                                        VALORE,
                                        DATA,
                                        OPERAZIONE,
                                        BI_RIFERIMENTO,
                                        UTENTE_AGG,
                                        USER_ORACLE,
                                        INFO,
                                        PROGRAMMA)
                 VALUES (v_id_evento,
                         :new.CHIAVE,
                         :new.STRINGA,
                         :new.COMMENTO,
                         :new.VALORE,
                         SYSDATE,
                         p_operazione,
                         p_id_evento_rif,
                         SI4.UTENTE,
                         USER,
                         ad4_sessioni_pkg.get_info (USERENV ('sessionid')),
                         ad4_sessioni_pkg.get_program (USERENV ('sessionid')));
        ELSIF p_info = 'OLD'
        THEN
            INSERT INTO REGISTRO_STORICO (ID_EVENTO,
                                        CHIAVE,
                                        STRINGA,
                                        COMMENTO,
                                        VALORE,
                                        DATA,
                                        OPERAZIONE,
                                        BI_RIFERIMENTO,
                                        UTENTE_AGG,
                                        USER_ORACLE,
                                        INFO,
                                        PROGRAMMA)
                 VALUES (v_id_evento,
                         :old.CHIAVE,
                         :old.STRINGA,
                         :old.COMMENTO,
                         :old.VALORE,
                         SYSDATE,
                         p_operazione,
                         p_id_evento_rif,
                         SI4.UTENTE,
                         USER,
                         ad4_sessioni_pkg.get_info (USERENV ('sessionid')),
                         ad4_sessioni_pkg.get_program (USERENV ('sessionid')));
        END IF;
    END;
BEGIN
    IF INSERTING
    THEN
        inserisci (p_operazione => 'I', p_info => 'NEW');
    ELSIF DELETING
    THEN
        inserisci (p_operazione => 'D', p_info => 'OLD');
    ELSIF     UPDATING
          AND (   :new.CHIAVE != :old.CHIAVE
               OR :new.STRINGA != :old.STRINGA
               OR NVL (:new.COMMENTO, 'x') !=
                  NVL (:old.COMMENTO, 'x')
               OR NVL (:new.VALORE, 'x') !=
                  NVL (:old.VALORE, 'x'))
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


