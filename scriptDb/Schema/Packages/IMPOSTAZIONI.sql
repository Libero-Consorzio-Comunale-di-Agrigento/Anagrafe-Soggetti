CREATE OR REPLACE PACKAGE IMPOSTAZIONI
IS   
   /******************************************************************************
    NOME        IMPOSTAZIONI
    DESCRIZIONE Gestione IMPOSTAZIONI
    ANNOTAZIONI .
    REVISIONI
    CODE
    Rev.  Data        Autore      Descrizione.
    00    21052018  snegroni  Primo rilascio
   
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT AFC.t_revision := 'V1.00';
   
   subtype t_impostazioni is registro.valore%TYPE; 

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (versione, WNDS);

   FUNCTION get_preferenza (p_stringa     VARCHAR2,
                            p_contesto    VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
END IMPOSTAZIONI;
/

