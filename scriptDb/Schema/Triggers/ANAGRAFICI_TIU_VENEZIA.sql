CREATE OR REPLACE TRIGGER ANAGRAFICI_TIU_VENEZIA
/******************************************************************************
 NOME:        ANAGRAFICI_TIU
 DESCRIZIONE: Trigger for Check DATA Integrity
                          Check REFERENTIAL Integrity
                            Set REFERENTIAL Integrity
                            Set FUNCTIONAL Integrity
                       at INSERT or UPDATE on Table ANAGRAFICI
 ECCEZIONI:   -20007, Identificazione CHIAVE presente in TABLE
 ANNOTAZIONI: Richiama Procedure ANAGRAFICI_PI
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
                         distribuzione.
******************************************************************************/
   BEFORE INSERT OR UPDATE
   ON ANAGRAFICI
   FOR EACH ROW
DECLARE
   integrity_error    EXCEPTION;
   errno             INTEGER;
   errmsg            CHAR (200);
   dummy             INTEGER;
   FOUND             BOOLEAN;
   d_result          AFC_Error.t_error_number;
   v_get_pref_alternativa impostazioni.t_impostazioni;
BEGIN
   v_get_pref_alternativa := impostazioni.get_preferenza ('Storicizzare', '') ;
   if v_get_pref_alternativa = 'VENEZIA' then 
   if :new.tipo_soggetto not in ('E','I') then
     :new.al  := trunc(sysdate);
     :new.stato_soggetto := 'C';
   end if;   
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


