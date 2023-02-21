CREATE OR REPLACE TRIGGER RECAPITI_tc
after INSERT
   or UPDATE
   or DELETE
on RECAPITI
BEGIN
   -- Exec PostEvent Check REFERENTIAL Integrity
   IntegrityPackage.Exec_PostEvent;
END;
/


