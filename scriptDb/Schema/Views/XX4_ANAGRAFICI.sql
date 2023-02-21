CREATE OR REPLACE FORCE VIEW XX4_ANAGRAFICI
(NI, DAL, MOTIVO_BLOCCO, OGGETTO, COLONNA, 
 USER_ORACLE, PROGETTO)
BEQUEATH DEFINER
AS 
SELECT TO_NUMBER (NULL) ni,
          TO_DATE (NULL) dal,
          TO_CHAR (NULL) motivo_blocco,
          TO_CHAR (NULL) oggetto,
          TO_CHAR (NULL) colonna,
          TO_CHAR (NULL) user_oracle,
          TO_CHAR (NULL) progetto
     FROM tipi_soggetto
    WHERE tipo_soggetto = ' ';


