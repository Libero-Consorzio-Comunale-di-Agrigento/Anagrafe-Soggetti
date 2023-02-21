CREATE OR REPLACE TRIGGER RECAPITI_TB
before INSERT
    or UPDATE
    or DELETE
on RECAPITI
BEGIN
   -- RESET PostEvent for Custom Functional Check
   IF IntegrityPackage.GetNestLevel = 0 THEN
      IntegrityPackage.InitNestLevel;
   END IF;
END;
/


