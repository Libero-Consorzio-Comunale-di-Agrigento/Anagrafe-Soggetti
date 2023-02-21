CREATE OR REPLACE TRIGGER TIPI_RECAPITO_TIU
/******************************************************************************
    NOME:        TIPO_recapito_TIU
    DESCRIZIONE: Trigger per impedire modifiche di descrizioni standard
    ECCEZIONI:
    ANNOTAZIONI:
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
                           Prima Emissione
       1 19/11/2020     SN Gestione tipo recapito 0=LAVORO non modificabile Bug#46210
   ******************************************************************************/
   BEFORE INSERT OR UPDATE OR DELETE
   ON TIPI_RECAPITO    FOR EACH ROW
DECLARE
   integrity_error   EXCEPTION;
   errno             INTEGER;
   errmsg            CHAR (200);
   dummy             INTEGER;
   FOUND             BOOLEAN;
   mutating         EXCEPTION;
   PRAGMA EXCEPTION_INIT(mutating, -4091);
BEGIN
  if not deleting then
     :new.descrizione := upper(:new.descrizione);
  end if;
  if inserting and :new.id_tipo_recapito is null then
      BEGIN  -- Global FUNCTIONAL Integrity at Level 0
            IF :NEW.id_tipo_recapito IS NULL THEN
               :NEW.id_tipo_recapito := Si4.NEXT_ID('TIPI_RECAPITO','ID_TIPO_RECAPITO');
            END IF;
         END;
   end if;
   -- non posso fare udpate o delete
   IF    (    :new.descrizione IS NULL
          AND :old.descrizione IN ('RESIDENZA', 'DOMICILIO','LAVORO'))
      OR (    :old.descrizione != :new.descrizione
          AND :old.descrizione IN ('RESIDENZA', 'DOMICILIO','LAVORO'))
   THEN
      raise_application_error (
         -20999,
         si4.get_error('A10083') --'Impossibile modificare la descrizione per il tipo predefinito'
         ||' Descrizione:' || :old.descrizione);
   END IF;
   -- non posso fare udpate o delete
   IF    (    :new.unico IS NULL
          AND :old.descrizione IN ('RESIDENZA', 'DOMICILIO','LAVORO'))
      OR (    :old.unico != :new.unico
          AND :old.descrizione IN ('RESIDENZA', 'DOMICILIO','LAVORO'))
   THEN
      raise_application_error (
         -20999,
         si4.get_error('A10083') --'Impossibile modificare la descrizione per il tipo predefinito'
         ||' Unico per descrizione:' || :old.descrizione);
   END IF;

   IF      nvl(:old.descrizione,'x') != :new.descrizione
          AND :new.descrizione IN ('RESIDENZA', 'DOMICILIO','LAVORO')
   THEN
      raise_application_error (
         -20999,
         si4.get_error('A10084') -- 'Impossibile riutilizzare la descrizione di tipo predefinito'
         ||':' || :new.descrizione);
   END IF;
   if deleting then
    IF  :old.descrizione IN ('RESIDENZA', 'DOMICILIO','LAVORO')
   THEN
      raise_application_error (
         -20999,
         si4.get_error('A10085') -- 'Impossibile eliminare il tipo predefinito'
         ||' Descrizione:' || :old.descrizione);
   END IF;
   -- non si può cancellare se referenziato
    DECLARE
     CURSOR cpk_id_tipo_recapito(var_id_tipo_recapito VARCHAR) IS
      SELECT 1
      FROM   recapiti
      WHERE  id_tipo_recapito = var_id_tipo_recapito;
   BEGIN                                        -- Check REFERENTIAL Integrity
      BEGIN
         IF  :OLD.id_tipo_recapito IS NOT NULL  THEN
            OPEN cpk_id_tipo_recapito (:OLD.id_tipo_recapito);

      FETCH cpk_id_tipo_recapito INTO dummy;

      FOUND := cpk_id_tipo_recapito%FOUND;

      CLOSE cpk_id_tipo_recapito;
            IF FOUND THEN
          errno  := -20003;
          errmsg := si4.get_error('A10043') ; --'Esistono riferimenti al tipo recapito impossibile cancellare.';
          RAISE integrity_error;
            END IF;
         END IF;
      EXCEPTION
         WHEN MUTATING THEN NULL;  -- Ignora Check su Relazioni Ricorsive
      END;
   END;
   end if;
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


