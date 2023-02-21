CREATE OR REPLACE TRIGGER ANAGRAFICI_TB
BEFORE INSERT
    OR UPDATE
    OR DELETE
ON ANAGRAFICI
BEGIN
   -- RESET PostEvent for Custom Functional Check
   IF Integritypackage.GetNestLevel = 0 THEN
      Integritypackage.InitNestLevel;
   END IF;
END;
/


