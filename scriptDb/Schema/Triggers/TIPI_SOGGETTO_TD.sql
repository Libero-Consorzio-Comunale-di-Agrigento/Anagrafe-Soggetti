CREATE OR REPLACE TRIGGER TIPI_SOGGETTO_TD
/******************************************************************************
 NOME:        TIPI_SOGGETTO_TD
 DESCRIZIONE: Trigger for Set FUNCTIONAL Integrity
                        Check REFERENTIAL Integrity
                          Set REFERENTIAL Integrity
                       at DELETE on Table TIPI_SOGGETTO
 ANNOTAZIONI: Richiama Procedure TIPI_SOGGETTO_TD
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
                        Generato in automatico.
******************************************************************************/
   BEFORE DELETE ON TIPI_SOGGETTO
FOR EACH ROW
DECLARE
   integrity_error  EXCEPTION;
   errno            INTEGER;
   errmsg           CHAR(200);
   dummy            INTEGER;
   FOUND            BOOLEAN;
BEGIN
   IF  :old.descrizione IN ('PERSONA GIURIDICA', 'PERSONA FISICA')
   THEN
      raise_application_error (
         -20999,
         si4.get_error('A10085') -- 'Impossibile eliminare il tipo predefinito'
         ||' Descrizione:' || :old.descrizione);
   END IF;
   BEGIN -- Set FUNCTIONAL Integrity on DELETE
      IF Integritypackage.GetNestLevel = 0 THEN
         Integritypackage.NextNestLevel;
         BEGIN  -- Global FUNCTIONAL Integrity at Level 0
            /* NONE */ NULL;
         END;
         Integritypackage.PreviousNestLevel;
      END IF;
   END;
   BEGIN  -- Check REFERENTIAL Integrity on DELETE
      -- Child Restrict Table: ANAGRAFE_SOGGETTI
      Tipi_Soggetto_Pd(:OLD.TIPO_SOGGETTO);
   END;
   BEGIN  -- Set REFERENTIAL Integrity on DELETE
      Integritypackage.NextNestLevel;
      Integritypackage.PreviousNestLevel;
   END;
EXCEPTION
   WHEN integrity_error THEN
        Integritypackage.InitNestLevel;
        RAISE_APPLICATION_ERROR(errno, errmsg);
   WHEN OTHERS THEN
        Integritypackage.InitNestLevel;
        RAISE;
END;
/


