CREATE OR REPLACE package integritypackage
/******************************************************************************
 Oggetti per la gestione della Integrita Referenziale.
 Contiene le Procedure e function per la gestione del livello di annidamento dei trigger.
 Contiene le Procedure per il POSTING degli script alla fase di AFTER STATEMENT.
 REVISIONI.
 Rev. Data        Autore  Descrizione
 ---- ----------  ------  ----------------------------------------------------
 01    23/01/2001  MF      Inserimento commento.
 02    04/12/2002  SN      In caso di errore visualizza lo statement.
 03    22/12/2003  SN      Rilevamento errore in caso di select; sistemazione frase in base a default stabiliti.
 04    10/05/2004  SN      Se errore 20999 non si visualizza lo statement a meno che non sia stata settata la variabile debug a 1.
 05    20/12/2004  SN      Se errore non compreso fra 20000 e 20999 non visualizza lo statement a meno che debug sia = 1.
 06    04/08/2005  SN      Gestione di integrityerror.
 07    26/08/2005  SN      Sistemazione messaggio di errore.
 08    12/10/2005  SN      Errore rimappato attraverso si4.get_error.
 09    21/10/2005  SN      Modificato controllo errore.
 10    30/08/2006  FT      Modifica dichiarazione subtype per incompatibilità con versione 7 di Oracle.
 11    04/12/2008  MM      Creazione procedure log.
 12    20/03/2009  MM      Creazione procedure log con parametro clob.
 13    13/07/2011  FT      Allineati i commenti col nuovo standard di plsqldoc.
 NOTA: In futuro verra tolta la substr nella SISTEMA MESSAGGIO quando verra rilasciata una versione di ad4 che lo consenta.
******************************************************************************/
as
   -- Variabile utilizzata per la definizione del subtype t_revision
   d_revision varchar2(30);
   -- Type definition of the package version
   subtype t_revision is d_revision%type;
   -- Package revision value
   s_revisione t_revision := 'V1.13';
   /******************************************************************************
    Restituisce versione e revisione di distribuzione del package.
    %return varchar2: contiene versione e revisione.
    %note <UL>
          <LI> Primo numero: versione compatibilita del Package.</LI>
          <LI> Secondo numero: revisione del Package specification.</LI>
          <LI> Terzo numero: revisione del Package body.</LI>
          </UL>
   ******************************************************************************/
   function versione
   return t_revision;
   -- Variabile per SET Switched FUNCTIONAL Integrity
   functional       boolean        := true;
   -- Eccezione utilizzata all'interno di exec_postevent
   integrityerror   exception;
   /******************************************************************************
    Attiva la visualizzazione dell'istruzione che genera errore in ExecPostEvent anche se con errore user defined (20999).
   ******************************************************************************/
   procedure setdebugon;
   /******************************************************************************
    Disattiva la visualizzazione dell'istruzione che genera errore in ExecPostEvent anche se con errore user defined (20999).
   ******************************************************************************/
   procedure setdebugoff;
   /******************************************************************************
    Procedure to Initialize Switched Functional Integrity.
   ******************************************************************************/
   procedure setfunctional;
   /******************************************************************************
    Procedure to Reset Switched Functional Integrity.
   ******************************************************************************/
   procedure resetfunctional;
   /******************************************************************************
    Procedure to initialize the trigger nest level.
   ******************************************************************************/
   procedure initnestlevel;
   /******************************************************************************
    Function to return the trigger nest level.
    %return number: the trigger nest level.
   ******************************************************************************/
   function getnestlevel
   return number;
   /******************************************************************************
    Procedure to increase the trigger nest level
   ******************************************************************************/
   procedure nextnestlevel;
   /******************************************************************************
    Procedure to decrease the trigger nest level
   ******************************************************************************/
   procedure previousnestlevel;
   -- Type definition of array of operations in post-event execution
   type t_operazione is table of varchar2 (32000)
   index by binary_integer;
   -- Type definition of message used on post-event error
   type t_messaggio is table of varchar2 (2000)
   index by binary_integer;
   -- Array of operations used in post-event execution
   d_istruzione t_operazione;
   -- Message used on post-event error
   d_messaggio t_messaggio;
   d_entry binary_integer := 0;
   /******************************************************************************
    Memorizzazione istruzioni da attivare in POST statement.
    %param a_istruzione: Istruzione SQL da memorizzare.
    %param a_messaggio: Messaggio da inviare per errore in esecuzione.
   ******************************************************************************/
   procedure set_postevent
   ( p_istruzione in varchar2
   , p_messaggio in varchar2
   );
   /******************************************************************************
    Esegue gli statement precedentemente impostati.
    %note Se inizia con: <UL>
                         <LI> SELECT: toglie eventuale ';' in fondo
                         <LI> :=    : si suppone segua la chiamata ad una funzione, viene dichiarata una variabile e le si assegna il ritorno
                         <LI> in caso di stringa diversa mette il codice fra begin e end
                         </UL>
    ******************************************************************************/
   procedure exec_postevent;
   /***********************************************************************************
    Emissione log se previsto debug (debug = 1).
    %param p_log: messaggio da visualizzare
    %note p_log di tipo varchar2
   ************************************************************************************/
   procedure log
   ( p_log in varchar2
   );
   /***********************************************************************************
    Emissione log se previsto debug (debug = 1).
    %param p_log: messaggio da visualizzare
    %note p_log di tipo clob
   ************************************************************************************/
   procedure log
   ( p_log in clob
   );
end integritypackage;
/

