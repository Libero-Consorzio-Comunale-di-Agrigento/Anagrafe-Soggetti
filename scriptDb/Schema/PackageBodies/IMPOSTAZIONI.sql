CREATE OR REPLACE PACKAGE BODY IMPOSTAZIONI
IS
   /******************************************************************************
    NOME:        IMPOSTAZIONI
    DESCRIZIONE: Gestione IMPOSTAZIONI
    ANNOTAZIONI: .
    REVISIONI:
    <CODE>
    Rev.  Data        Autore      Descrizione.
    00    21/05/2018  snegroni  Primo rilascio
   ******************************************************************************/
   -- Revisione del Package
   s_revisione_body   CONSTANT AFC.t_revision := '000 - 21/05/2018';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2
   IS
   /******************************************************************************
    NOME:        versione
    DESCRIZIONE: Versione e revisione di distribuzione del package.
    RITORNA:     varchar2 stringa contenente versione e revisione.
    NOTE:        Primo numero  : versione compatibilita del Package.
                 Secondo numero: revisione del Package specification.
                 Terzo numero  : revisione del Package body.
   ******************************************************************************/
   BEGIN
      RETURN AFC.version (s_revisione, s_revisione_body);
   END versione;

   FUNCTION get_preferenza (p_stringa     VARCHAR2,
                            p_contesto    VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      /***********************************************************************************************
       NOME:        get_preferenza
       DESCRIZIONE: Trova una preferenza a livello di stringa e se indicato il contesto cerca per entrambi.
       PARAMETRI:   p_stringa   VARCHAR2  Nome preferenza
                    p_contesto  VARCHAR2
       RITORNA:     VARCHAR2  : valore della preferenza
      ************************************************************************************************/
      d_valore   VARCHAR2 (2000);
      d_chiave   registro.chiave%TYPE:='PRODUCTS/ANAGRAFICA';
   BEGIN
   
      d_valore := registro_utility.leggi_stringa  ( d_chiave,  p_stringa,0);
--      IF p_stringa = 'Modificabile' AND p_contesto = 'VENEZIA'
--      THEN
--         d_valore := 'SI';
--      END IF;

--      IF p_stringa = 'Storicizzare' AND p_contesto = 'VENEZIA'
--      THEN
--         d_valore := 'SI';
--      END IF;
--      -- RicercaAnagrafeAlternativa
--      IF p_stringa = 'GetAnagraficaAltrnativa' AND p_contesto = 'VENEZIA'
--      THEN
--         d_valore := 'SI';
--      END IF;

      RETURN d_valore;
   END get_preferenza;
END IMPOSTAZIONI;
/

