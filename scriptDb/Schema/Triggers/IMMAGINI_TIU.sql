CREATE OR REPLACE TRIGGER IMMAGINI_TIU
/******************************************************************************
 NOME:        IMMAGINI_TIU
 DESCRIZIONE: Trigger for Set DATA Integrity
                          Set FUNCTIONAL Integrity
                       on Table IMMAGINI
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
******************************************************************************/
   BEFORE INSERT OR UPDATE ON IMMAGINI FOR EACH ROW
DECLARE
   integrity_error  EXCEPTION;
   errno            INTEGER;
   errmsg           CHAR(200);
   FOUND            BOOLEAN;
BEGIN
   BEGIN  -- Set DATA Integrity
      /* NONE */ NULL;
   END;
  BEGIN  -- Set FUNCTIONAL Integrity
      IF Integritypackage.GetNestLevel = 0 THEN
         Integritypackage.NextNestLevel;
         BEGIN  -- Global FUNCTIONAL Integrity at Level 0
            --  Column "ID_IMMAGINE" attribuisce MAX+1
            IF :NEW.ID_IMMAGINE IS NULL THEN
               :NEW.ID_IMMAGINE := Si4.NEXT_ID('IMMAGINI','ID_IMMAGINE');
            END IF;
         END;
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


