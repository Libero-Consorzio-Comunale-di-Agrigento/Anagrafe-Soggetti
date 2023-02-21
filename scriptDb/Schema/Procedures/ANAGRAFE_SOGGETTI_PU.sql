CREATE OR REPLACE PROCEDURE Anagrafe_Soggetti_Pu
/******************************************************************************
 NOME:        ANAGRAFE_SOGGETTI_PU
 DESCRIZIONE: Procedure for Check REFERENTIAL Integrity
                         at UPDATE on Table ANAGRAFE_SOGGETTI
 ARGOMENTI:   Rigenerati in automatico.
 ECCEZIONI:  -20001, Informazione COLONNA non modificabile
             -20003, Non esiste riferimento su PARENT TABLE
             -20004, Identificazione di TABLE non modificabile
             -20005, Esistono riferimenti su CHILD TABLE
 ANNOTAZIONI: Richiamata da Trigger ANAGRAFE_SOGGETTI_TIU
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
                        Generata in automatico.
    1 07/09/2005 MM     Introduzione controllo di integrita referenziale su
                       XX4_ANAGRAFE_SOGGETTI.
******************************************************************************/
(  old_ni IN NUMBER
 , old_dal IN DATE
 , old_provincia_nas IN NUMBER
 , old_comune_nas IN NUMBER
 , old_provincia_res IN NUMBER
 , old_comune_res IN NUMBER
 , old_provincia_dom IN NUMBER
 , old_comune_dom IN NUMBER
 , old_tipo_soggetto IN VARCHAR
 , new_ni IN NUMBER
 , new_dal IN DATE
 , new_provincia_nas IN NUMBER
 , new_comune_nas IN NUMBER
 , new_provincia_res IN NUMBER
 , new_comune_res IN NUMBER
 , new_provincia_dom IN NUMBER
 , new_comune_dom IN NUMBER
 , new_tipo_soggetto IN VARCHAR
)
IS
   integrity_error  EXCEPTION;
   errno            INTEGER;
   errmsg           CHAR(200);
   dummy            INTEGER;
   FOUND            BOOLEAN;
   oggetto          VARCHAR2(200);
   motivo_blocco    VARCHAR2(200);
   seq              NUMBER;
   mutating         EXCEPTION;
   PRAGMA EXCEPTION_INIT(mutating, -4091);
   --  Dichiarazione UpdateChildParentExist constraint per la tabella "AD4_COMUNI"
   CURSOR cpk1_anagrafe_soggetti(var_provincia_dom NUMBER,
                   var_comune_dom NUMBER) IS
      SELECT 1
      FROM   AD4_COMUNI
      WHERE  PROVINCIA_STATO = var_provincia_dom
       AND   COMUNE = var_comune_dom
       AND   var_provincia_dom IS NOT NULL
      AND   var_provincia_dom > 0
       AND   var_comune_dom IS NOT NULL;
   --  Dichiarazione UpdateChildParentExist constraint per la tabella "AD4_COMUNI"
   CURSOR cpk2_anagrafe_soggetti(var_provincia_res NUMBER,
                   var_comune_res NUMBER) IS
      SELECT 1
      FROM   AD4_COMUNI
      WHERE  PROVINCIA_STATO = var_provincia_res
       AND   COMUNE = var_comune_res
       AND   var_provincia_res IS NOT NULL
      AND   var_provincia_res > 0
       AND   var_comune_res IS NOT NULL;
   --  Dichiarazione UpdateChildParentExist constraint per la tabella "AD4_COMUNI"
   CURSOR cpk3_anagrafe_soggetti(var_provincia_nas NUMBER,
                   var_comune_nas NUMBER) IS
      SELECT 1
      FROM   AD4_COMUNI
      WHERE  PROVINCIA_STATO = var_provincia_nas
      AND   var_provincia_nas > 0
       AND   COMUNE = var_comune_nas
       AND   var_provincia_nas IS NOT NULL
       AND   var_comune_nas IS NOT NULL;
   --  Dichiarazione UpdateChildParentExist constraint per la tabella "TIPI_SOGGETTO"
   CURSOR cpk4_anagrafe_soggetti(var_tipo_soggetto VARCHAR) IS
      SELECT 1
      FROM   TIPI_SOGGETTO
      WHERE  TIPO_SOGGETTO = var_tipo_soggetto
       AND   var_tipo_soggetto IS NOT NULL;
   --  Declaration of UpdateParentRestrict constraint for "XX4_ANAGRAFE_SOGGETTI"
   CURSOR cfk1_anagrafe_soggetti(var_ni NUMBER, var_dal DATE) IS
      SELECT oggetto, motivo_blocco
      FROM   XX4_ANAGRAFE_SOGGETTI
      WHERE  ni = var_ni
       AND   dal = var_dal
       AND   var_ni IS NOT NULL
       AND   var_dal IS NOT NULL;
BEGIN
   BEGIN  -- Check REFERENTIAL Integrity
      --  Chiave di "ANAGRAFE_SOGGETTI" non modificabile se esistono referenze su "XX4_ANAGRAFE_SOGGETTI"
      OPEN  cfk1_anagrafe_soggetti(OLD_NI,OLD_DAL);
      FETCH cfk1_anagrafe_soggetti INTO oggetto, motivo_blocco;
      FOUND := cfk1_anagrafe_soggetti%FOUND;
      CLOSE cfk1_anagrafe_soggetti;
      IF FOUND THEN
         IF (OLD_NI != NEW_NI) OR (OLD_DAL != NEW_DAL) OR (motivo_blocco = 'R') THEN
          errno  := -20005;
          errmsg := 'Esistono riferimenti su Anagrafe Soggetti ('||oggetto||'). La registrazione non e'' modificabile.';
          IF motivo_blocco = 'R' THEN
             errmsg := errmsg ||'(motivo blocco: '||motivo_blocco||')';
          END IF;
          RAISE integrity_error;
         END IF;
      END IF;
   END;
   BEGIN
      seq := Integritypackage.GetNestLevel;
      BEGIN  --  Parent "AD4_COMUNI" deve esistere quando si modifica "ANAGRAFE_SOGGETTI"
         IF  NEW_PROVINCIA_DOM IS NOT NULL AND NEW_PROVINCIA_DOM > 0 AND
             NEW_COMUNE_DOM IS NOT NULL AND ( seq = 0 )
         AND (   (NEW_PROVINCIA_DOM != OLD_PROVINCIA_DOM OR OLD_PROVINCIA_DOM IS NULL)
              OR (NEW_COMUNE_DOM != OLD_COMUNE_DOM OR OLD_COMUNE_DOM IS NULL) ) THEN
            OPEN  cpk1_anagrafe_soggetti(NEW_PROVINCIA_DOM,
                           NEW_COMUNE_DOM);
            FETCH cpk1_anagrafe_soggetti INTO dummy;
            FOUND := cpk1_anagrafe_soggetti%FOUND;
            CLOSE cpk1_anagrafe_soggetti;
            IF NOT FOUND THEN
          errno  := -20003;
          errmsg := 'Non esiste riferimento su Comuni. La registrazione Anagrafe Soggetti non e'' modificabile.';
          RAISE integrity_error;
            END IF;
         END IF;
      EXCEPTION
         WHEN MUTATING THEN NULL;  -- Ignora Check su Relazioni Ricorsive
      END;
      BEGIN  --  Parent "AD4_COMUNI" deve esistere quando si modifica "ANAGRAFE_SOGGETTI"
         IF  NEW_PROVINCIA_RES IS NOT NULL AND NEW_PROVINCIA_RES > 0 AND
             NEW_COMUNE_RES IS NOT NULL AND ( seq = 0 )
         AND (   (NEW_PROVINCIA_RES != OLD_PROVINCIA_RES OR OLD_PROVINCIA_RES IS NULL)
              OR (NEW_COMUNE_RES != OLD_COMUNE_RES OR OLD_COMUNE_RES IS NULL) ) THEN
            OPEN  cpk2_anagrafe_soggetti(NEW_PROVINCIA_RES,
                           NEW_COMUNE_RES);
            FETCH cpk2_anagrafe_soggetti INTO dummy;
            FOUND := cpk2_anagrafe_soggetti%FOUND;
            CLOSE cpk2_anagrafe_soggetti;
            IF NOT FOUND THEN
          errno  := -20003;
          errmsg := 'Non esiste riferimento su Comuni. La registrazione Anagrafe Soggetti non e'' modificabile.';
          RAISE integrity_error;
            END IF;
         END IF;
      EXCEPTION
         WHEN MUTATING THEN NULL;  -- Ignora Check su Relazioni Ricorsive
      END;
      BEGIN  --  Parent "AD4_COMUNI" deve esistere quando si modifica "ANAGRAFE_SOGGETTI"
         IF  NEW_PROVINCIA_NAS IS NOT NULL AND NEW_PROVINCIA_NAS > 0 AND
             NEW_COMUNE_NAS IS NOT NULL AND ( seq = 0 )
         AND (   (NEW_PROVINCIA_NAS != OLD_PROVINCIA_NAS OR OLD_PROVINCIA_NAS IS NULL)
              OR (NEW_COMUNE_NAS != OLD_COMUNE_NAS OR OLD_COMUNE_NAS IS NULL) ) THEN
            OPEN  cpk3_anagrafe_soggetti(NEW_PROVINCIA_NAS,
                           NEW_COMUNE_NAS);
            FETCH cpk3_anagrafe_soggetti INTO dummy;
            FOUND := cpk3_anagrafe_soggetti%FOUND;
            CLOSE cpk3_anagrafe_soggetti;
            IF NOT FOUND THEN
          errno  := -20003;
          errmsg := 'Non esiste riferimento su Comuni. La registrazione Anagrafe Soggetti non e'' modificabile.';
          RAISE integrity_error;
            END IF;
         END IF;
      EXCEPTION
         WHEN MUTATING THEN NULL;  -- Ignora Check su Relazioni Ricorsive
      END;
      BEGIN  --  Parent "TIPI_SOGGETTO" deve esistere quando si modifica "ANAGRAFE_SOGGETTI"
         IF  NEW_TIPO_SOGGETTO IS NOT NULL AND ( seq = 0 )
         AND (   (NEW_TIPO_SOGGETTO != OLD_TIPO_SOGGETTO OR OLD_TIPO_SOGGETTO IS NULL) ) THEN
            OPEN  cpk4_anagrafe_soggetti(NEW_TIPO_SOGGETTO);
            FETCH cpk4_anagrafe_soggetti INTO dummy;
            FOUND := cpk4_anagrafe_soggetti%FOUND;
            CLOSE cpk4_anagrafe_soggetti;
            IF NOT FOUND THEN
          errno  := -20003;
          errmsg := 'Non esiste riferimento su Tipi soggetto. La registrazione Anagrafe Soggetti non e'' modificabile.';
          RAISE integrity_error;
            END IF;
         END IF;
      EXCEPTION
         WHEN MUTATING THEN NULL;  -- Ignora Check su Relazioni Ricorsive
      END;
      NULL;
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

