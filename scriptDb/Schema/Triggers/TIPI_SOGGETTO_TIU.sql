CREATE OR REPLACE TRIGGER TIPI_SOGGETTO_TIU
/******************************************************************************
 NOME:        TIPI_SOGGETTO_TIU
 DESCRIZIONE: Trigger for Check DATA Integrity
                          Check REFERENTIAL Integrity
                            Set REFERENTIAL Integrity
                            Set FUNCTIONAL Integrity
                       at INSERT or UPDATE on Table TIPI_SOGGETTO
 ECCEZIONI:   -20007, Identificazione CHIAVE presente in TABLE
 ANNOTAZIONI: Richiama Procedure TIPI_SOGGETTO_PI e TIPI_SOGGETTO_PU
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
                        Generato in automatico.
  1   31/01/2018 SN     Gestione si4.get_error.
******************************************************************************/
   BEFORE INSERT OR UPDATE ON TIPI_SOGGETTO
FOR EACH ROW
DECLARE
   integrity_error  EXCEPTION;
   errno            INTEGER;
   errmsg           CHAR(200);
   dummy            INTEGER;
   FOUND            BOOLEAN;
BEGIN
   BEGIN  -- Check DATA Integrity on INSERT or UPDATE
      /* NONE */ NULL;
   END;
   BEGIN  -- Check REFERENTIAL Integrity on INSERT or UPDATE
       IF updating and :old.descrizione IN ('PERSONA GIURIDICA', 'PERSONA FISICA')
       THEN
          raise_application_error (
             -20999,
             si4.get_error('A10083') --'Impossibile modificare il tipo predefinito'
             ||' Descrizione:' || :old.descrizione);
       END IF;
   
      IF UPDATING THEN
         Tipi_Soggetto_Pu(:OLD.TIPO_SOGGETTO,
                         :NEW.TIPO_SOGGETTO);
         NULL;
      END IF;
      IF INSERTING THEN
         IF Integritypackage.GetNestLevel = 0 THEN
            DECLARE  --  Check UNIQUE PK Integrity per la tabella "TIPI_SOGGETTO"
            CURSOR cpk_tipi_soggetto(var_TIPO_SOGGETTO VARCHAR) IS
               SELECT 1
                 FROM   TIPI_SOGGETTO
                WHERE  TIPO_SOGGETTO = var_TIPO_SOGGETTO;
            mutating         EXCEPTION;
            PRAGMA EXCEPTION_INIT(mutating, -4091);
            BEGIN  -- Check UNIQUE Integrity on PK of "TIPI_SOGGETTO"
               IF :NEW.TIPO_SOGGETTO IS NOT NULL THEN
                  OPEN  cpk_tipi_soggetto(:NEW.TIPO_SOGGETTO);
                  FETCH cpk_tipi_soggetto INTO dummy;
                  FOUND := cpk_tipi_soggetto%FOUND;
                  CLOSE cpk_tipi_soggetto;
                  IF FOUND THEN
                     errno  := -20007;
                     errmsg := si4.get_error('A10064') ||
                                 ' (' || :NEW.TIPO_SOGGETTO||' in Tipi soggetto. La registrazione  non puo'' essere inserita.';
--                               'Identificazione "'||
--                               :NEW.TIPO_SOGGETTO||
--                               '" gia'' presente in Tipi soggetto. La registrazione  non puo'' essere inserita.';
                     RAISE integrity_error;
                  END IF;
               END IF;
            EXCEPTION
               WHEN MUTATING THEN NULL;  -- Ignora Check su UNIQUE PK Integrity
            END;
         END IF;
      END IF;
   END;
   BEGIN  -- Set REFERENTIAL Integrity on UPDATE
      IF UPDATING THEN
         Integritypackage.NextNestLevel;
         Integritypackage.PreviousNestLevel;
      END IF;
   END;
   BEGIN  -- Set FUNCTIONAL Integrity on INSERT or UPDATE
      IF Integritypackage.GetNestLevel = 0 THEN
         Integritypackage.NextNestLevel;
         BEGIN  -- Global FUNCTIONAL Integrity at Level 0
            /* NONE */ NULL;
         END;
         IF Integritypackage.Functional THEN
            BEGIN  -- Switched FUNCTIONAL Integrity at Level 0
               /* NONE */ NULL;
            END;
         END IF;
         Integritypackage.PreviousNestLevel;
      END IF;
      Integritypackage.NextNestLevel;
      BEGIN  -- Full FUNCTIONAL Integrity at Any Level
         /* NONE */ NULL;
      END;
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


