CREATE OR REPLACE TRIGGER contatti_TB
before INSERT
    or UPDATE
    or DELETE
on contatti
BEGIN
   -- RESET PostEvent for Custom Functional Check
   IF IntegrityPackage.GetNestLevel = 0 THEN
      IntegrityPackage.InitNestLevel;
   END IF;
END;
/


