CREATE OR REPLACE TRIGGER TIPI_SOGGETTO_STORICO_TIU
/******************************************************************************
                 NOME:        TIPI_SOGGETTO_STORICO_TIU
                 DESCRIZIONE: Trigger for salvare dati storici
                                       at INSERT or UPDATE or DELETE on Table TIPI_SOGGETTO
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
    ON TIPI_SOGGETTO
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
        SELECT tiss_sq.NEXTVAL INTO v_id_evento FROM DUAL;

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
            INSERT INTO TIPI_SOGGETTO_STORICO (ID_EVENTO,
                                               TIPO_SOGGETTO,
                                               DESCRIZIONE,
                                               FLAG_TRG,
                                               VERSION,
                                               UTENTE_AGG,
                                               DATA_AGGIORNAMENTO,
                                               CATEGORIA_TIPO_SOGGETTO,
                                               DATA,
                                               OPERAZIONE,
                                               BI_RIFERIMENTO,
                                               UTENTE_AGGIORNAMENTO,
                                               USER_ORACLE,
                                               INFO,
                                               PROGRAMMA)
                     VALUES (
                         v_id_evento,
                         :new.TIPO_SOGGETTO,
                         :new.DESCRIZIONE,
                         :new.FLAG_TRG,
                         :new.VERSION,
                         :new.UTENTE_AGGIORNAMENTO,
                         :new.DATA_AGGIORNAMENTO,
                         :new.CATEGORIA_TIPO_SOGGETTO,
                         SYSDATE,
                         p_operazione,
                         p_id_evento_rif,
                         SI4.UTENTE,
                         USER,
                         ad4_sessioni_pkg.get_info (USERENV ('sessionid')),
                         ad4_sessioni_pkg.get_program (USERENV ('sessionid')));
        ELSIF p_info = 'OLD'
        THEN
            INSERT INTO TIPI_SOGGETTO_STORICO (ID_EVENTO,
                                               TIPO_SOGGETTO,
                                               DESCRIZIONE,
                                               FLAG_TRG,
                                               VERSION,
                                               UTENTE_AGG,
                                               DATA_AGGIORNAMENTO,
                                               CATEGORIA_TIPO_SOGGETTO,
                                               DATA,
                                               OPERAZIONE,
                                               BI_RIFERIMENTO,
                                               UTENTE_AGGIORNAMENTO,
                                               USER_ORACLE,
                                               INFO,
                                               PROGRAMMA)
                     VALUES (
                         v_id_evento,
                         :old.TIPO_SOGGETTO,
                         :old.DESCRIZIONE,
                         :old.FLAG_TRG,
                         :old.VERSION,
                         :old.UTENTE_AGGIORNAMENTO,
                         :old.DATA_AGGIORNAMENTO,
                         :old.CATEGORIA_TIPO_SOGGETTO,
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
    -- Tengo sempre traccia delle modifiche
    IF INSERTING
    THEN
        inserisci (p_operazione => 'I', p_info => 'NEW');
    ELSIF DELETING
    THEN
        inserisci (p_operazione => 'D', p_info => 'OLD');
    ELSIF     UPDATING
          AND (   :new.TIPO_SOGGETTO != :old.TIPO_SOGGETTO
               OR :new.DESCRIZIONE != :old.DESCRIZIONE
               OR NVL (:new.FLAG_TRG, '-1') != NVL (:old.FLAG_TRG, '-1')
               OR NVL (:new.VERSION, '-1') != NVL (:old.VERSION, '-1')
               OR NVL (:new.UTENTE_AGGIORNAMENTO, '-1') !=
                  NVL (:old.UTENTE_AGGIORNAMENTO, '-1')
               OR NVL (:new.DATA_AGGIORNAMENTO, TO_DATE ('3333333', 'j')) !=
                  NVL (:old.DATA_AGGIORNAMENTO, TO_DATE ('3333333', 'j'))
               OR :new.CATEGORIA_TIPO_SOGGETTO != :old.CATEGORIA_TIPO_SOGGETTO
               )
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


