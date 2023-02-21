CREATE OR REPLACE TRIGGER contatti_tc
after INSERT
   or UPDATE
   or DELETE
on contatti
BEGIN
   -- Exec PostEvent Check REFERENTIAL Integrity
   IntegrityPackage.Exec_PostEvent;
END;
/


