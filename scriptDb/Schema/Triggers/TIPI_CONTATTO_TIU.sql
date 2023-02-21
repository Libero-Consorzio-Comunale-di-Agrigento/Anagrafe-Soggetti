CREATE OR REPLACE TRIGGER TIPI_CONTATTO_TIU
/******************************************************************************
    NOME:        TIPI_CONTATTO_TIU
    DESCRIZIONE: Trigger per impedire modifiche di descrizioni standard
    ECCEZIONI:   -20007, Identificazione CHIAVE presente in TABLE
    ANNOTAZIONI:
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
                           Prima Emissione
   ******************************************************************************/
   BEFORE INSERT OR UPDATE OR DELETE
   ON TIPI_CONTATTO    FOR EACH ROW
DECLARE
   integrity_error   EXCEPTION;
   errno             INTEGER;
   errmsg            CHAR (200);
   dummy             INTEGER;
   FOUND             BOOLEAN;
   mutating         EXCEPTION;
   PRAGMA EXCEPTION_INIT(mutating, -4091);
BEGIN

--raise_application_error (-20999,'old versione '|| :old.version);
  if not deleting then
      :new.descrizione := upper(:new.descrizione);
      :new.unico := upper(:new.unico);
  end if;
   -- non posso fare update o delete
   IF updating and   (    :new.descrizione IS NULL
          AND :old.descrizione IN ('MAIL', 'TELEFONO', 'FAX', 'MAIL PEC'))
      OR (    :old.descrizione != :new.descrizione
          AND :old.descrizione IN ('MAIL', 'TELEFONO', 'FAX', 'MAIL PEC'))
   THEN
      raise_application_error (
         -20999,
         si4.get_error('A10083') --'Impossibile modificare il tipo predefinito'
         ||' Descrizione:' || :old.descrizione);
   END IF;
--   -- non posso fare update o delete
--   IF updating and   (    :new.unico IS NULL
--          AND :old.descrizione IN ('MAIL', 'TELEFONO', 'FAX'))
--      OR (    :old.unico != :new.unico
--          AND :old.descrizione IN ('MAIL', 'TELEFONO', 'FAX'))
--   THEN
--      raise_application_error (
--         -20999,
--         si4.get_error('A10083') --'Impossibile modificare il tipo predefinito'
--         ||' Unico pescrizione: ' || :old.descrizione);
--   END IF;

   if :new.tipo_spedizione is not null 
     and :new.tipo_spedizione not in ('MAIL','FAX','SMS') then      
      raise_application_error (
         -20999,
         si4.get_error('A10020') || ' Il tipo di spedizione non e'' tra quelli previsti.');
   end if;
   
   IF      nvl(:old.descrizione,'x') != :new.descrizione
          AND :new.descrizione IN ('MAIL', 'TELEFONO', 'FAX', 'MAIL PEC')
   THEN  
      raise_application_error (
         -20999,
         si4.get_error('A10084') -- 'Impossibile riutilizzare la descrizione di tipo predefinito'
         ||':' || :new.descrizione);
   END IF;   
   if inserting and :new.ID_TIPO_CONTATTO is null then
      BEGIN  -- Global FUNCTIONAL Integrity at Level 0
            IF :NEW.ID_TIPO_CONTATTO IS NULL THEN
               :NEW.ID_TIPO_CONTATTO := Si4.NEXT_ID('TIPI_CONTATTO','ID_TIPO_CONTATTO');
            END IF;
         END;
   end if;
   if deleting then
   IF  :old.descrizione IN ('MAIL', 'TELEFONO', 'FAX', 'MAIL PEC')
   THEN
      raise_application_error (
         -20999,
         si4.get_error('A10085') -- 'Impossibile eliminare il tipo predefinito'
         ||' Descrizione:' || :old.descrizione);
   END IF;
   -- non si può cancellare se referenziato
    DECLARE
     CURSOR cpk_id_tipo_contatto(var_id_tipo_contatto VARCHAR) IS
      SELECT 1
      FROM   contatti
      WHERE  id_tipo_contatto = var_id_tipo_contatto;
   BEGIN                                        -- Check REFERENTIAL Integrity
      BEGIN  
         IF  :OLD.id_tipo_contatto IS NOT NULL  THEN
            OPEN cpk_id_tipo_contatto (:OLD.id_tipo_contatto);

      FETCH cpk_id_tipo_contatto INTO dummy;

      FOUND := cpk_id_tipo_contatto%FOUND;
       
      CLOSE cpk_id_tipo_contatto;
            IF FOUND THEN
          errno  := -20003;
          errmsg := si4.get_error('A10043') ; --'Esistono riferimenti al tipo contatto impossibile cancellare.';
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


