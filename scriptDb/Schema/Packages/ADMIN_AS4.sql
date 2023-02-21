CREATE OR REPLACE PACKAGE Admin_As4
IS
/******************************************************************************
 NOME:        ADMIN_AS4.
 DESCRIZIONE: Funzioni di amministrazione.
 ANNOTAZIONI:
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 00   10/06/2019 SNegro Creazione.
 01   02/03/2020 SNeg   Correzione errori
******************************************************************************/
   -- Revisione del Package
   s_revisione constant AFC.t_revision := 'V1.01';
   TYPE b_object_rec IS RECORD (
      object_name   ALL_OBJECTS.object_name%type
   );
   TYPE b_object_tab IS TABLE OF b_object_rec
      INDEX BY BINARY_INTEGER;
   b_index                     BINARY_INTEGER := 0;
--   TabTAS4                      b_object_tab;
--   TabPAS4                      b_object_tab;
   TabTVDB                     b_object_tab;
   TabPDB                      b_object_tab;
/******************************************************************************
 NOME:        VERSIONE
 DESCRIZIONE: Restituisce la versione e la data di distribuzione del package.
 PARAMETRI:   --
 RITORNA:     stringa varchar2 contenente versione e data.
 NOTE:        Il secondo numero della versione corrisponde alla revisione
              del package.
******************************************************************************/
   FUNCTION VERSIONE
      RETURN VARCHAR2;
/******************************************************************************
 NOME:        GRANT_TO
 DESCRIZIONE: Assegna le grant all'utente passato.
 PARAMETRI:   p_user utente oracle a cui devono essere assegnate le grant.
 RITORNA:     stringa contenente la concatenazione di eventuali errori.
******************************************************************************/
   PROCEDURE GRANT_TO (
      p_user        IN   VARCHAR2
    , p_what        IN   VARCHAR2 DEFAULT 'ALL'
    , p_privilege   IN   VARCHAR2 DEFAULT 'all'
    , p_owner       IN   VARCHAR2 default USER
    , p_grant_option IN  VARCHAR2 default 'NO'
   );
/******************************************************************************
 NOME:        GRANT_TO_ALL
 DESCRIZIONE: Assegna le grant a tutti gli utenti oracle per cui esiste almeno
              un record nella tabella ISTANZE.
 ARGOMENTI:   --
******************************************************************************/
   PROCEDURE GRANT_TO_ALL (
      p_what        IN   VARCHAR2 DEFAULT 'ALL'
    , p_privilege   IN   VARCHAR2 DEFAULT 'all'
    , p_owner       IN   VARCHAR2 default USER
    , p_grant_option IN  VARCHAR2 default 'NO'
   );

END ;
/

