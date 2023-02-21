CREATE OR REPLACE package AFC_DDL is
/******************************************************************************
 Handling of Definition Schema and Data Definition Manipulation
 REVISIONI.
 Rev. Data       Autore     Descrizione
 ---- ---------- ---------- ------------------------------------------------------
 00   19/04/2005 CZecca     Prima emissione.
 01   14/10/2005 FTassinari Aggiunta metodi is_trigger, is_trigger_enabled, is_object_valid is_constraint, is_constraint_enabled.
 02   21/10/2005 FTassinari Modifica in is_trigger_enabled e is_constraint_enabled (possibile lancio di eccezione 'NO_DATA_FOUND').
 03   25/11/2005 FTassinari Aggiunta di is_package.
 04   01/02/2006 FTassinari Aggiunta di if_procedure e is_function.
 05   08/07/2011 FTassinari Allineati i commenti col nuovo standard di plsqldoc.
******************************************************************************/
   -- Package revision value
   s_revisione AFC.t_revision := 'V1.05';
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
   return varchar2;
   pragma restrict_references( versione, WNDS, WNPS );
   /******************************************************************************
    Ritorna la stringa passatale in maiuscolo se non racchiusa tra doppi apici '"' altrimenti la stringa passata senza doppi apici iniziale e finale.
    %param p_name stringa da normalizzare.
    %return varchar2: la stringa elaborata.
   ******************************************************************************/
   function normalize
   ( p_name in varchar2
   ) return AFC.t_object_name;
   pragma restrict_references( normalize, WNDS );
   /******************************************************************************
    Controllo del dominio; requisiti di validita sui nomi gestiti in AFC_DDL.
    %param p_name nome da controllare.
    %return number: 1 la stringa va bene (puo essere "maneggiata"), 0 se errori.
    %note cfr. CanHandle per valori di ritorno booleani.
   ******************************************************************************/
   function can_handle
   ( p_name in AFC.t_object_name
   ) return number;        -- cannot return boolean due to compatibility with other languages
   pragma restrict_references( can_handle, WNDS );
   /******************************************************************************
    Wrapper booleano di can_handle.
    %note cfr. can_handle.
   ******************************************************************************/
   function CanHandle
   ( p_name in AFC.t_object_name
   ) return boolean;
   pragma restrict_references( CanHandle, WNDS );
   /******************************************************************************
    Il nome e racchiuso tra doppi apici '"'?
    %param p_name nome da controllare.
    %return number: 1 la stringa e racchiusa da doppi apici, 0 altrimenti.
    %note cfr. IsQuoted per valori di ritorno booleani.
   ******************************************************************************/
   function is_quoted
   ( p_name in AFC.t_object_name
   ) return number;        -- cannot return boolean due to compatibility with other languages
   pragma restrict_references( is_quoted, WNDS );
   /******************************************************************************
    Wrapper booleano di is_quoted.
    %note cfr. is_quoted.
   ******************************************************************************/
   function IsQuoted
   ( p_name in AFC.t_object_name
   ) return  boolean;
   pragma restrict_references( IsQuoted, WNDS );
   /******************************************************************************
    Il nome corrisponde ad un utente della base dati?
    %param p_name nome da controllare.
    %return number: 1 l'identificatore corrisponde ad un utente 0 altrimenti.
    %note cfr. IsUser per valori di ritorno booleani.
   ******************************************************************************/
   function is_user
   ( p_name in AFC.t_object_name
   ) return  number;
   pragma restrict_references( is_user, WNDS );
   /******************************************************************************
    Wrapper booleano di is_user.
    %note cfr. is_user.
   ******************************************************************************/
   function IsUser
   ( p_name in AFC.t_object_name
   ) return  boolean;
   pragma restrict_references( IsUser, WNDS );
   /******************************************************************************
    Il nome corrisponde ad una tabella della base dati?
    %param p_table_name nome da controllare proprietario della tabella (se specificato).
    %param p_owner_name utente proprietario dell'oggetto.
    %return number: 1 l'identificatore corrisponde ad una tabella 0 altrimenti.
    %note cfr. IsTable per valori di ritorno booleani.
   ******************************************************************************/
   function is_table
   ( p_table_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  number;        -- cannot return boolean due to compatibility with other languages
   pragma restrict_references( is_table, WNDS );
   /******************************************************************************
    Wrapper booleano di is_table.
    %note cfr. is_table.
   ******************************************************************************/
   function IsTable
   ( p_table_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  boolean;
   pragma restrict_references( IsTable, WNDS );
   /******************************************************************************
    Il nome corrisponde ad una vista della base dati?
    %param p_view_name nome da controllare proprietario della vista; se non specificato si ricerca in user_views.
    %param p_owner_name utente proprietario dell'oggetto.
    %return number: 1 l'identificatore corrisponde ad una vista 0 altrimenti.
    %note cfr. IsView per valori di ritorno booleani.
   ******************************************************************************/
   function is_view
   ( p_view_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  number;        -- cannot return boolean due to compatibility with other languages
   pragma restrict_references( is_view, WNDS );
   /******************************************************************************
    Wrapper booleano di is_view.
    %note cfr. is_view.
   ******************************************************************************/
   function IsView
   ( p_view_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  boolean;
   pragma restrict_references( IsView, WNDS );
   -- pseudo user PUBLIC for synonyms
   s_PUBLIC constant AFC.t_object_name := 'PUBLIC';
   /******************************************************************************
    Il nome corrisponde ad un sinonimo della base dati?
    %param p_synonym_name nome da controllare utente proprietario del sinonimo; se non specificato si ricerca in user_synonyms.
    %param p_owner_name utente proprietario dell'oggetto.
    %return number: 1 l'identificatore corrisponde ad un sinonimo 0 altrimenti.
    %note cfr. IsSynonym per valori di ritorno booleani.
   ******************************************************************************/
   function is_synonym
   ( p_synonym_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  number;        -- cannot return boolean due to compatibility with other languages
   pragma restrict_references( is_synonym, WNDS );
   /******************************************************************************
    Wrapper booleano di is_synonym.
    %note cfr. is_synonym.
   ******************************************************************************/
   function IsSynonym
   ( p_synonym_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  boolean;
   pragma restrict_references( IsSynonym, WNDS );
   /******************************************************************************
    Il nome corrisponde ad un trigger della base dati?
    %param p_trigger_name nome da controllare utente proprietario del trigger; se non specificato si ricerca in user_trigger.
    %param p_owner_name utente proprietario dell'oggetto.
    %return number: 1 l'identificatore corrisponde ad un trigger 0 altrimenti.
    %note cfr. IsTrigger per valori di ritorno booleani.
   ******************************************************************************/
   function is_trigger
   ( p_trigger_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  number;        -- cannot return boolean due to compatibility with other languages
   pragma restrict_references( is_trigger, WNDS );
   /******************************************************************************
    Wrapper booleano di is_trigger.
    %note cfr. is_trigger.
   ******************************************************************************/
   function IsTrigger
   ( p_trigger_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  boolean;
   pragma restrict_references( IsTrigger, WNDS );
   /******************************************************************************
    Il nome corrisponde ad un constraint della base dati?
    %param p_constraint_name nome da controllare utente proprietario del constraint; se non specificato si ricerca in user_constraints.
    %param p_owner_name utente proprietario dell'oggetto.
    %return number: 1 l'identificatore corrisponde ad un constraint 0 altrimenti.
    %note cfr. IsConstraint per valori di ritorno booleani.
   ******************************************************************************/
   function is_constraint
   ( p_constraint_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  number;        -- cannot return boolean due to compatibility with other languages
   pragma restrict_references( is_constraint, WNDS );
   /******************************************************************************
    Wrapper booleano di is_constraint.
    %note cfr. is_constraint.
   ******************************************************************************/
   function IsConstraint
   ( p_constraint_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  boolean;
   pragma restrict_references( IsConstraint, WNDS );
   /******************************************************************************
    Il nome corrisponde ad un package della base dati?
    %param p_package_name nome da controllare utente proprietario del package; se non specificato si ricerca in user_objects.
    %param p_owner_name utente proprietario dell'oggetto.
    %return number: 1 l'identificatore corrisponde ad un package 0 altrimenti.
    %note cfr. IsPackage per valori di ritorno booleani.
   ******************************************************************************/
   function is_package
   ( p_package_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  number;        -- cannot return boolean due to compatibility with other languages
   pragma restrict_references( is_package, WNDS );
   /******************************************************************************
    Wrapper booleano di is_package.
    %note cfr. is_package.
   ******************************************************************************/
   function IsPackage
   ( p_package_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  boolean;
   pragma restrict_references( IsPackage, WNDS );
   /******************************************************************************
    Il nome corrisponde ad una procedure della base dati?
    %param p_procedure_name nome da controllare utente proprietario della procedure; se non specificato si ricerca in user_objects.
    %param p_owner_name utente proprietario dell'oggetto.
    %return number: 1 l'identificatore corrisponde ad una procedure 0 altrimenti.
    %note cfr. IsProcedure per valori di ritorno booleani.
   ******************************************************************************/
   function is_procedure
   ( p_procedure_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  number;        -- cannot return boolean due to compatibility with other languages
   pragma restrict_references( is_procedure, WNDS );
   /******************************************************************************
    Wrapper booleano di is_procedure.
    %note cfr. is_procedure.
   ******************************************************************************/
   function IsProcedure
   ( p_procedure_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  boolean;
   pragma restrict_references( IsProcedure, WNDS );
   /******************************************************************************
    Il nome corrisponde ad una function della base dati?
    %param p_function_name nome da controllare utente proprietario della function; se non specificato si ricerca in user_objects.
    %param p_owner_name utente proprietario dell'oggetto.
    %return number: 1 l'identificatore corrisponde ad una function 0 altrimenti.
    %note cfr. IsFunction per valori di ritorno booleani.
   ******************************************************************************/
   function is_function
   ( p_function_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  number;        -- cannot return boolean due to compatibility with other languages
   pragma restrict_references( is_function, WNDS );
   /******************************************************************************
    Wrapper booleano di is_function.
    %note cfr. is_function.
   ******************************************************************************/
   function IsFunction
   ( p_function_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  boolean;
   pragma restrict_references( IsFunction, WNDS );
   /******************************************************************************
    Il trigger è abilitato?
    %param p_trigger_name nome del trigger da controllare utente proprietario del trigger; se non specificato si ricerca in user_tables.
    %param p_owner_name utente proprietario dell'oggetto.
    %return number: 1 l'identificatore corrisponde ad un trigger abilitato 0 altrimenti.
    %note cfr. IsTriggerEnabled per valori di ritorno booleani.
   ******************************************************************************/
   function is_trigger_enabled
   ( p_trigger_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  number;        -- cannot return boolean due to compatibility with other languages
   pragma restrict_references( is_trigger_enabled, WNDS );
   /******************************************************************************
    Wrapper booleano di is_trigger_enabled.
    %note cfr. is_trigger_enabled.
   ******************************************************************************/
   function IsTriggerEnabled
   ( p_trigger_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  boolean;
   pragma restrict_references( IsTriggerEnabled, WNDS );
   /******************************************************************************
    Il constraint è abilitato?
    %param p_constraint_name del constraint da controllare utente proprietario del constraint; se non specificato si ricerca in user_tables.
    %param p_owner_name utente proprietario dell'oggetto.
    %return number: 1 l'identificatore corrisponde ad un constraint abilitato 0 altrimenti.
    %note cfr. IsConstraintEnabled per valori di ritorno booleani.
   ******************************************************************************/
   function is_constraint_enabled
   ( p_constraint_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  number;        -- cannot return boolean due to compatibility with other languages
   pragma restrict_references( is_constraint_enabled, WNDS );
   /******************************************************************************
    Wrapper booleano di is_constraint_enabled.
    %note cfr. is_constraint_enabled.
   ******************************************************************************/
   function IsConstraintEnabled
   ( p_constraint_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  boolean;
   pragma restrict_references( IsConstraintEnabled, WNDS );
   /******************************************************************************
    L'oggetto è valido?
    %param p_object_name dell'oggetto da controllare utente proprietario dell'oggetto; se non specificato si ricerca in user_objects.
    %param p_owner_name utente proprietario dell'oggetto.
    %return number: 1 l'oggetto è valido 0 altrimenti.
    %note cfr. IsObjectValid per valori di ritorno booleani.
   ******************************************************************************/
   function is_object_valid
   ( p_object_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  number;        -- cannot return boolean due to compatibility with other languages
   pragma restrict_references( is_object_valid, WNDS );
   /******************************************************************************
    Wrapper booleano di is_object_valid.
    %note cfr. is_object_valid.
   ******************************************************************************/
   function IsObjectValid
   ( p_object_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  boolean;
   pragma restrict_references( is_object_valid, WNDS );
   /******************************************************************************
    p_attribute è un attributo (campo) di p_object_name ?
    %param p_object_name
    %param p_attribute_name
    %param p_owner_name utente proprietario dell'oggetto.
    %return number: 1 se vero, 0 se falso.
    %note cfr. HasAttribute per valori di ritorno booleani p_object_name DEVE essere un tipo di object supportato da has_attribute ed esistente nel db. NON funziona con sinonimi con link a DB esterni
   ******************************************************************************/
   function has_attribute
   ( p_object_name in AFC.t_object_name
   , p_attribute_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  number;        -- cannot return boolean due to compatibility with other languages
   pragma restrict_references( has_attribute, WNDS );
   /******************************************************************************
    Wrapper booleano di has_attribute
    %note cfr. has_attribute
   ******************************************************************************/
   function HasAttribute
   ( p_object_name in AFC.t_object_name
   , p_attribute_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  boolean;
   pragma restrict_references( HasAttribute, WNDS );
   /******************************************************************************
    p_attribute è un attributo (campo) annullabile di p_object_name?
    %param p_object_name
    %param p_attribute_name
    %param p_owner_name utente proprietario dell'oggetto.
    %return number: 1 se vero, 0 se falso.
    %note cfr. IsNullable per valori di ritorno booleani p_object_name DEVE essere un tipo di object supportato da has_attribute ed esistente nel db p_attribute_name deve essere un attributo di p_object_name. NON funziona con sinonimi con link a DB esterni
   ******************************************************************************/
   function is_nullable
   ( p_object_name in AFC.t_object_name
   , p_attribute_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  number;        -- cannot return boolean due to compatibility with other languages
   pragma restrict_references( is_nullable, WNDS );
   /******************************************************************************
    Wrapper booleano di is_nullable.
    %note cfr. is_nullable.
   ******************************************************************************/
   function IsNullable
   ( p_object_name in AFC.t_object_name
   , p_attribute_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  boolean;
   pragma restrict_references( IsNullable, WNDS );
end AFC_DDL;
/

