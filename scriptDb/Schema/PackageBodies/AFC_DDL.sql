CREATE OR REPLACE package body AFC_DDL is
/******************************************************************************
 Handling of Definition Schema and Data Definition Manipulation
 REVISIONI.
 Rev.  Data        Autore  Descrizione
 ----  ----------  ------  ----------------------------------------------------
 001   29/11/2005  FT      Aggiunta di is_package; modifica in is_object_valid, modifica in versione.
 002   01/02/2006  FT      Aggiunta di is_procedure e is_function.
 003   08/07/2011  FT      Allineati i commenti col nuovo standard di plsqldoc.
******************************************************************************/
   -- Package body revision value
   s_revisione_body AFC.t_revision := '002';
   -- Stringa doppi apici
   s_quote constant varchar2(1) := '"';
   -- Stringa spazio
   s_space constant varchar2(1) := ' ';
--------------------------------------------------------------------------------
   function has_attribute_table_view
   ( p_object_name in AFC.t_object_name
   , p_attribute_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  number;
   function is_nullable_table_view
   ( p_object_name in AFC.t_object_name
   , p_attribute_name in AFC.t_object_name
   , p_owner_name in AFC.t_object_name default null
   ) return  number;
--------------------------------------------------------------------------------
   type t_synonym_data is record
   ( table_name all_synonyms.table_name%type
   , owner_name all_synonyms.table_owner%type
   , db_link all_synonyms.db_link%type
   );
--------------------------------------------------------------------------------
/******************************************************************************
 Restituisce versione e revisione di distribuzione del package.
******************************************************************************/
function versione return varchar2 is
begin
   return AFC.version( s_revisione, s_revisione_body );
end; -- AFC_DDL.versione
--------------------------------------------------------------------------------
/******************************************************************************
 Ritorna la stringa passatale in maiuscolo se non racchiusa tra doppi apici '"' altrimenti la stringa passata senza doppi apici iniziale e finale.
******************************************************************************/
function normalize
( p_name in varchar2
) return AFC.t_object_name
is
   d_result AFC.t_object_name;
begin
   DbC.PRE( p_name is not null );
   if IsQuoted( p_name ) then
      d_result := substr( p_name, 2, length( p_name ) - 2 );
   else
      d_result := upper( p_name );
   end if;
   return d_result;
end; -- AFC_DDL.normalize
--------------------------------------------------------------------------------
/******************************************************************************
 Controllo del dominio; requisiti di validità sui nomi gestiti in AFC_DDL.
******************************************************************************/
function can_handle
( p_name in AFC.t_object_name
) return number
is
   d_result number;
begin
   DbC.PRE( p_name is not null );
   d_result := 1;
   -- if the identifier is provided amongst quotes ('"') both the first and last character must be a quote
   if  d_result = 1
   and substr( p_name, 1, 1 ) = s_quote
   and substr( p_name, length( p_name ), 1 ) != s_quote
   then
      d_result := 0;
   end if;
   -- in no case the identifier can have leading or trailing zeros
   if  d_result = 1
   and (  substr( p_name, 1, 1 ) = s_space
       or substr( p_name, length( p_name ), 1 ) = s_space
       )
   then
      d_result := 0;
   end if;
   -- the identifier may contain spaces only when it has been provided enclosed by quote characters
   if  d_result = 1
   and instr( p_name, s_space ) != 0
   and substr( p_name, 1, 1 ) != s_quote
   then
      d_result := 0;
   end if;
   DbC.POST( d_result = 1  or  d_result = 0 );
   return  d_result;
end; -- AFC_DDL.can_handle
--------------------------------------------------------------------------------
/******************************************************************************
 Wrapper booleano di can_handle.
******************************************************************************/
function CanHandle
( p_name in AFC.t_object_name
) return boolean
is
   d_result constant boolean := AFC.to_boolean( can_handle( p_name ) );
begin
   return  d_result;
end; -- AFC_DDL.CanHandle
--------------------------------------------------------------------------------
/******************************************************************************
 Il nome è racchiuso tra doppi apici '"'?
******************************************************************************/
function is_quoted
( p_name in AFC.t_object_name
) return  number
is
   d_result number;
begin
   DbC.PRE( p_name is not null );
   -- if the identifier is provided amongst quotes ('"') both the first and last character must be a quote
   DbC.PRE( not DbC.PreOn  or  CanHandle( p_name ) );
   -- if the table identifier is provided between quotes, it is searched as it is
   -- otherwise it is searched after having converted it to the upper case
   if substr( p_name, 1, 1 ) = s_quote then
      d_result := 1;
   else
      d_result := 0;
   end if;
   DbC.POST( d_result = 1  or  d_result = 0 );
   return  d_result;
end; -- AFC_DDL.is_quoted
--------------------------------------------------------------------------------
/******************************************************************************
 Wrapper booleano di is_quoted.
******************************************************************************/
function IsQuoted
( p_name in AFC.t_object_name
) return  boolean
is
   d_result constant boolean := Afc.to_boolean( is_quoted( p_name ) );
begin
   return  d_result;
end; -- AFC_DDL.IsQuoted
--------------------------------------------------------------------------------
/******************************************************************************
 Il nome corrisponde ad un utente della base dati?
******************************************************************************/
function is_user
( p_name in AFC.t_object_name
) return  number
is
   d_result number;
begin
   DbC.PRE( p_name is not null );
   DbC.PRE( not DbC.PreOn  or  CanHandle( p_name ) );
   begin
      select 1
      into d_result
      from all_users
      where username = normalize( p_name );
   exception
      when NO_DATA_FOUND then
         d_result := 0;
   end;
   DbC.POST( d_result = 1  or  d_result = 0 );
   return  d_result;
end; -- AFC_DDL.is_user
--------------------------------------------------------------------------------
/******************************************************************************
 Wwrapper booleano di is_user.
******************************************************************************/
function IsUser
( p_name in AFC.t_object_name
) return  boolean
is
   d_result constant boolean := Afc.to_boolean( is_user( p_name ) );
begin
   return  d_result;
end; -- AFC_DDL.IsUser
--------------------------------------------------------------------------------
/******************************************************************************
 Il nome corrisponde ad una tabella della base dati?
******************************************************************************/
function is_table
( p_table_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  number
is
   d_result number;
begin
   DbC.PRE( p_table_name is not null );
   DbC.PRE( not DbC.PreOn  or  CanHandle( p_table_name ) );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or  CanHandle( p_owner_name )
          );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or IsUser( p_owner_name )
          );
   if p_owner_name is null then
      -- no explicit owner has been provided, we search the user_tables
      begin
         select 1
         into d_result
         from user_tables
         where table_name = normalize( p_table_name )
         ;
      exception
         when NO_DATA_FOUND then
            d_result := 0;
      end;
   else
      -- an owner has been explicitly provided, we search the all_tables
      begin
         select 1
         into d_result
         from all_tables
         where table_name = normalize( p_table_name )
         and   owner = normalize( p_owner_name )
         ;
      exception
         when NO_DATA_FOUND then
            d_result := 0;
      end;
   end if;
   DbC.POST( d_result = 1  or  d_result = 0 );
   return  d_result;
end; -- AFC_DDL.is_table
--------------------------------------------------------------------------------
/******************************************************************************
 Wrapper booleano di is_table.
******************************************************************************/
function IsTable
( p_table_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  boolean
is
   d_result constant boolean := Afc.to_boolean( is_table( p_table_name, p_owner_name ) );
begin
   return  d_result;
end; -- AFC_DDL.IsTable
--------------------------------------------------------------------------------
/******************************************************************************
 Il nome corrisponde ad una vista della base dati?
******************************************************************************/
function is_view
( p_view_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
 ) return  number
is
   d_result number;
begin
   DbC.PRE( p_view_name is not null );
   DbC.PRE( not DbC.PreOn  or  CanHandle( p_view_name ) );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or CanHandle( p_owner_name )
          );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or IsUser( p_owner_name )
          );
   if p_owner_name is null then
      -- no explicit owner has been provided, we search the user_views
      begin
         select 1
         into d_result
         from user_views
         where view_name = normalize( p_view_name )
         ;
      exception
         when NO_DATA_FOUND then
            d_result := 0;
      end;
   else
      -- an owner has been explicitly provided, we search the all_views
      begin
         select 1
         into d_result
         from all_views
         where view_name = normalize( p_view_name )
         and   owner = normalize( p_owner_name )
         ;
      exception
         when NO_DATA_FOUND then
            d_result := 0;
      end;
   end if;
   DbC.POST( d_result = 1  or  d_result = 0 );
   return  d_result;
end; -- AFC_DDL.is_view
--------------------------------------------------------------------------------
/******************************************************************************
 Wrapper booleano di is_view.
******************************************************************************/
function IsView
( p_view_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  boolean
is
   d_result constant boolean := Afc.to_boolean( is_view( p_view_name, p_owner_name ) );
begin
   return  d_result;
end; -- AFC_DDL.IsView
--------------------------------------------------------------------------------
/******************************************************************************
 Il nome corrisponde ad un sinonimo della base dati?
******************************************************************************/
function is_synonym
( p_synonym_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name
) return  number
is
   d_result number;
begin
   DbC.PRE( p_synonym_name is not null );
   DbC.PRE( not DbC.PreOn  or  CanHandle( p_synonym_name ) );
   DbC.PRE(  not DbC.PreOn
          or  p_owner_name is null
          or  IsUser( p_owner_name )
          or  p_owner_name = s_PUBLIC
          );
   if p_owner_name is null then
      -- no explicit owner has been provided, we search the user_synonyms
      begin
         select 1
         into d_result
         from user_synonyms
         where synonym_name = normalize( p_synonym_name )
         ;
      exception
         when NO_DATA_FOUND then
            d_result := 0;
      end;
   else
      -- an owner has been explicitly provided, we search the all_tables
      begin
         select 1
         into d_result
         from all_synonyms
         where synonym_name = normalize( p_synonym_name )
         and   owner = normalize( p_owner_name )
         ;
      exception
         when NO_DATA_FOUND then
            d_result := 0;
      end;
   end if;
   DbC.POST( d_result = 1  or  d_result = 0 );
   return  d_result;
end; -- AFC_DDL.is_synonym
--------------------------------------------------------------------------------
/******************************************************************************
 Wrapper booleano di is_synonym.
******************************************************************************/
function IsSynonym
( p_synonym_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name
) return  boolean
is
   d_result constant boolean := Afc.to_boolean( is_synonym( p_synonym_name, p_owner_name ) );
begin
   return  d_result;
end; -- AFC_DDL.IsSynonym
--------------------------------------------------------------------------------
/******************************************************************************
 Il nome corrisponde ad un trigger della base dati?
******************************************************************************/
function is_trigger
( p_trigger_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  number
is
   d_result number;
begin
   DbC.PRE( p_trigger_name is not null );
   DbC.PRE( not DbC.PreOn  or  CanHandle( p_trigger_name ) );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or CanHandle( p_owner_name )
          );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or IsUser( p_owner_name )
          );
   if p_owner_name is null then
      -- no explicit owner has been provided, we search the user_triggers
      begin
         select 1
         into d_result
         from user_triggers
         where trigger_name = normalize( p_trigger_name )
         ;
      exception
         when NO_DATA_FOUND then
            d_result := 0;
      end;
   else
      -- an owner has been explicitly provided, we search the all_triggers
      begin
         select 1
         into d_result
         from all_triggers
         where trigger_name = normalize( p_trigger_name )
         and   owner = normalize( p_owner_name )
         ;
      exception
         when NO_DATA_FOUND then
            d_result := 0;
      end;
   end if;
   DbC.POST( d_result = 1  or  d_result = 0 );
   return  d_result;
end; -- AFC_DDL.is_trigger
--------------------------------------------------------------------------------
/******************************************************************************
 Wrapper booleano di is_trigger.
******************************************************************************/
function IsTrigger
( p_trigger_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  boolean
is
   d_result constant boolean := Afc.to_boolean( is_trigger( p_trigger_name, p_owner_name ) );
begin
   return  d_result;
end; -- AFC_DDL.IsTrigger
--------------------------------------------------------------------------------
/******************************************************************************
 Il nome corrisponde ad un constraint della base dati?
******************************************************************************/
function is_constraint
( p_constraint_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  number
is
   d_result number;
begin
   DbC.PRE( p_constraint_name is not null );
   DbC.PRE( not DbC.PreOn  or  CanHandle( p_constraint_name ) );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or CanHandle( p_owner_name )
          );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or IsUser( p_owner_name )
          );
   if p_owner_name is null then
      -- no explicit owner has been provided, we search the user_triggers
      begin
         select 1
         into d_result
         from user_constraints
         where constraint_name = normalize( p_constraint_name )
         ;
      exception
         when NO_DATA_FOUND then
            d_result := 0;
      end;
   else
      -- an owner has been explicitly provided, we search the all_triggers
      begin
         select 1
         into d_result
         from all_constraints
         where constraint_name = normalize( p_constraint_name )
         and   owner = normalize( p_owner_name )
         ;
      exception
         when NO_DATA_FOUND then
            d_result := 0;
      end;
   end if;
   DbC.POST( d_result = 1  or  d_result = 0 );
   return  d_result;
end; -- AFC_DDL.is_constraint
--------------------------------------------------------------------------------
/******************************************************************************
 Wrapper booleano di is_constraint.
******************************************************************************/
function IsConstraint
( p_constraint_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  boolean
is
   d_result constant boolean := Afc.to_boolean( is_constraint( p_constraint_name, p_owner_name ) );
begin
   return  d_result;
end; -- AFC_DDL.IsConstraint
--------------------------------------------------------------------------------
/******************************************************************************
 Il nome corrisponde ad un package della base dati?
******************************************************************************/
function is_package
( p_package_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  number
is
   d_result number;
begin
   DbC.PRE( p_package_name is not null );
   DbC.PRE( not DbC.PreOn  or  CanHandle( p_package_name ) );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or CanHandle( p_owner_name )
          );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or IsUser( p_owner_name )
          );
   if p_owner_name is null then
      -- no explicit owner has been provided, we search the user_objects
      begin
         select 1
         into d_result
         from user_objects
         where object_type = 'PACKAGE'
         and   object_name = normalize( p_package_name )
         ;
      exception
         when NO_DATA_FOUND then
            d_result := 0;
      end;
   else
      -- an owner has been explicitly provided, we search the all_objects
      begin
         select 1
         into d_result
         from all_objects
         where object_type = 'PACKAGE'
         and   object_name = normalize( p_package_name )
         and   owner = normalize( p_owner_name )
         ;
      exception
         when NO_DATA_FOUND then
            d_result := 0;
      end;
   end if;
   DbC.POST( d_result = 1  or  d_result = 0 );
   return  d_result;
end; -- AFC_DDL.is_package
--------------------------------------------------------------------------------
/******************************************************************************
 Wrapper booleano di is_package.
******************************************************************************/
function IsPackage
( p_package_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  boolean
is
   d_result constant boolean := Afc.to_boolean( is_package( p_package_name, p_owner_name ) );
begin
   return  d_result;
end; -- AFC_DDL.IsPackage
--------------------------------------------------------------------------------
/******************************************************************************
 Il nome corrisponde ad una procedure della base dati?
******************************************************************************/
function is_procedure
( p_procedure_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  number
is
   d_result number;
begin
   DbC.PRE( p_procedure_name is not null );
   DbC.PRE( not DbC.PreOn  or  CanHandle( p_procedure_name ) );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or CanHandle( p_owner_name )
          );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or IsUser( p_owner_name )
          );
   if p_owner_name is null then
      -- no explicit owner has been provided, we search the user_objects
      begin
         select 1
         into d_result
         from user_objects
         where object_type = 'PROCEDURE'
         and   object_name = normalize( p_procedure_name )
         ;
      exception
         when NO_DATA_FOUND then
            d_result := 0;
      end;
   else
      -- an owner has been explicitly provided, we search the all_objects
      begin
         select 1
         into d_result
         from all_objects
         where object_type = 'PROCEDURE'
         and   object_name = normalize( p_procedure_name )
         and   owner = normalize( p_owner_name )
         ;
      exception
         when NO_DATA_FOUND then
            d_result := 0;
      end;
   end if;
   DbC.POST( d_result = 1  or  d_result = 0 );
   return  d_result;
end; -- AFC_DDL.is_procedure
--------------------------------------------------------------------------------
/******************************************************************************
 Wrapper booleano di is_procedure.
******************************************************************************/
function IsProcedure
( p_procedure_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  boolean
is
   d_result constant boolean := Afc.to_boolean( is_procedure( p_procedure_name, p_owner_name ) );
begin
   return  d_result;
end; -- AFC_DDL.IsProcedure
--------------------------------------------------------------------------------
/******************************************************************************
 Il nome corrisponde ad una function della base dati?
******************************************************************************/
function is_function
( p_function_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  number
is
   d_result number;
begin
   DbC.PRE( p_function_name is not null );
   DbC.PRE( not DbC.PreOn  or  CanHandle( p_function_name ) );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or CanHandle( p_owner_name )
          );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or IsUser( p_owner_name )
          );
   if p_owner_name is null then
      -- no explicit owner has been provided, we search the user_objects
      begin
         select 1
         into d_result
         from user_objects
         where object_type = 'FUNCTION'
         and   object_name = normalize( p_function_name )
         ;
      exception
         when NO_DATA_FOUND then
            d_result := 0;
      end;
   else
      -- an owner has been explicitly provided, we search the all_objects
      begin
         select 1
         into d_result
         from all_objects
         where object_type = 'FUNCTION'
         and   object_name = normalize( p_function_name )
         and   owner = normalize( p_owner_name )
         ;
      exception
         when NO_DATA_FOUND then
            d_result := 0;
      end;
   end if;
   DbC.POST( d_result = 1  or  d_result = 0 );
   return  d_result;
end; -- AFC_DDL.is_function
--------------------------------------------------------------------------------
/******************************************************************************
 Wrapper booleano di is_function.
******************************************************************************/
function IsFunction
( p_function_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  boolean
is
   d_result constant boolean := Afc.to_boolean( is_function( p_function_name, p_owner_name ) );
begin
   return  d_result;
end; -- AFC_DDL.IsFunction
--------------------------------------------------------------------------------
/******************************************************************************
 Il trigger è abilitato?
******************************************************************************/
function is_trigger_enabled
( p_trigger_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  number
is
   d_status all_triggers.status%type;
   d_result number;
begin
   DbC.PRE( not DbC.PreOn  or  IsTrigger( p_trigger_name, p_owner_name ) );
   if p_owner_name is null then
      -- no explicit owner has been provided, we search the user_triggers
      select status
      into d_status
      from user_triggers
      where trigger_name = normalize( p_trigger_name )
      ;
   else
      -- an owner has been explicitly provided, we search the all_triggers
      select status
      into d_status
      from all_triggers
      where trigger_name = normalize( p_trigger_name )
      and   owner = normalize( p_owner_name )
      ;
   end if;
   if d_status = 'ENABLED'
   then
      d_result := 1;
   else
      d_result := 0;
   end if;
   DbC.POST( d_result = 1  or  d_result = 0 );
   return  d_result;
end; -- AFC_DDL.is_trigger_enabled
--------------------------------------------------------------------------------
/******************************************************************************
 Wrapper booleano di is_trigger_enabled.
******************************************************************************/
function IsTriggerEnabled
( p_trigger_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  boolean
is
   d_result constant boolean := Afc.to_boolean( is_trigger_enabled( p_trigger_name, p_owner_name ) );
begin
   return d_result;
end; -- AFC_DDL.IsTriggerEnabled
--------------------------------------------------------------------------------
/******************************************************************************
 Il constraint è abilitato?
******************************************************************************/
function is_constraint_enabled
( p_constraint_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  number
is
   d_status all_constraints.status%type;
   d_result number;
begin
   DbC.PRE( not DbC.PreOn  or  IsConstraint( p_constraint_name, p_owner_name ) );
   if p_owner_name is null then
      -- no explicit owner has been provided, we search the user_constraints
      select status
      into d_status
      from user_constraints
      where constraint_name = normalize( p_constraint_name )
      ;
   else
      -- an owner has been explicitly provided, we search the all_constraints
      select status
      into d_status
      from user_constraints
      where constraint_name = normalize( p_constraint_name )
      and   owner = normalize( p_owner_name )
      ;
   end if;
   if d_status = 'ENABLED'
   then
      d_result := 1;
   else
      d_result := 0;
   end if;
   DbC.POST( d_result = 1  or  d_result = 0 );
   return  d_result;
end; -- AFC_DDL.is_constraint_enabled
--------------------------------------------------------------------------------
/******************************************************************************
 Wrapper booleano di is_constraint_enabled.
******************************************************************************/
function IsConstraintEnabled
( p_constraint_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  boolean
is
   d_result constant boolean := Afc.to_boolean( is_constraint_enabled( p_constraint_name, p_owner_name ) );
begin
   return d_result;
end; -- AFC_DDL.IsConstraintEnabled
--------------------------------------------------------------------------------
/******************************************************************************
 L'oggetto è valido?
******************************************************************************/
function is_object_valid
( p_object_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  number
is
   d_status all_objects.status%type;
   d_is_table constant boolean := IsTable( p_object_name, p_owner_name );
   d_is_view constant boolean := IsView( p_object_name, p_owner_name );
   d_is_synonym constant boolean := IsSynonym( p_object_name, p_owner_name );
   d_is_trigger constant boolean := IsTrigger( p_object_name, p_owner_name );
   d_is_constraint constant boolean := IsConstraint( p_object_name, p_owner_name );
   d_is_package constant boolean := IsPackage( p_object_name, p_owner_name );
   d_is_procedure constant boolean := IsProcedure( p_object_name, p_owner_name );
   d_is_function constant boolean := IsFunction( p_object_name, p_owner_name );
   d_result number;
begin
   DbC.PRE( p_object_name is not null );
   DbC.PRE( not DbC.PreOn  or  Afc.mxor( d_is_table
                                       , d_is_view
                                       , d_is_synonym
                                       , d_is_trigger
                                       , d_is_constraint
                                       , d_is_package
                                       , d_is_procedure
                                       , d_is_function
                                       ) );
   DbC.PRE( not DbC.PreOn  or  CanHandle( p_object_name ) );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or CanHandle( p_owner_name )
          );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or IsUser( p_owner_name )
          );
   if d_is_table
   or d_is_view
   or d_is_synonym
   or d_is_trigger
   or d_is_constraint
   or d_is_procedure
   or d_is_function
   then
      if p_owner_name is null then
         -- no explicit owner has been provided, we search the user_objects
         select status
         into d_status
         from user_objects
         where object_name = normalize( p_object_name )
         ;
      else
         -- an owner has been explicitly provided, we search the all_objects
         select status
         into d_status
         from all_objects
         where object_name = normalize( p_object_name )
         and   owner = normalize( p_owner_name )
         ;
      end if;
   else
      DbC.ASSERTION( not DbC.AssertionOn or d_is_package, 'd_is_package on AFC_DDL.is_object_valid' );
      if p_owner_name is null then
         -- no explicit owner has been provided, we search the user_objects
         begin
            select status
            into d_status
            from user_objects
            where object_name = normalize( p_object_name )
            and   object_type = 'PACKAGE BODY'
            ;
         exception
         when no_data_found then
            null;
         end;
         if d_status is null
         then
            select status
            into d_status
            from user_objects
            where object_name = normalize( p_object_name )
            and   object_type = 'PACKAGE'
            ;
         end if;
      else
         -- an owner has been explicitly provided, we search the all_objects
         begin
            select status
            into d_status
            from all_objects
            where object_name = normalize( p_object_name )
            and   owner = normalize( p_owner_name )
            and   object_type = 'PACKAGE BODY'
            ;
         exception
         when no_data_found then
            null;
         end;
         if d_status is null
         then
            select status
            into d_status
            from all_objects
            where object_name = normalize( p_object_name )
            and   owner = normalize( p_owner_name )
            and   object_type = 'PACKAGE'
            ;
         end if;
      end if;
   end if;
   if d_status = 'VALID'
   then
      d_result := 1;
   else
      d_result := 0;
   end if;
   DbC.POST( d_result = 1  or  d_result = 0 );
   return  d_result;
end; -- AFC_DDL.is_object_valid
--------------------------------------------------------------------------------
/******************************************************************************
 Wrapper booleano di is_object_valid.
******************************************************************************/
function IsObjectValid
( p_object_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return boolean
is
   d_result constant boolean := Afc.to_boolean( is_object_valid( p_object_name, p_owner_name ) );
begin
   return d_result;
end; -- AFC_DDL.IsObjectValid
--------------------------------------------------------------------------------
/******************************************************************************
 Indaga ricorsivamente il dizionario dati per estrarre tabella/vista e relativo utente riferiti direttamente (o indirettamente) dal sinonimo passatole.
******************************************************************************/
function get_synonym_data
( p_synonym_name in all_synonyms.synonym_name%type
, p_owner_name in AFC.t_object_name
) return t_synonym_data
is
   d_result t_synonym_data;
   d_owner_name all_synonyms.table_owner%type;
   d_table_name all_synonyms.table_name%type;
   d_db_link all_synonyms.db_link%type;
 begin
   DbC.Pre( p_synonym_name is not null );
   DbC.Pre( not DbC.PreOn  or  IsSynonym( p_synonym_name, p_owner_name ) );
   DbC.PRE(  not DbC.PreOn
          or  p_owner_name is null
          or  CanHandle( p_owner_name )
          );
   DbC.PRE(  not DbC.PreOn
          or  p_owner_name is null
          or  IsUser( p_owner_name )
          or p_owner_name = s_PUBLIC
          );
   if p_owner_name is null then
      select table_name,   table_owner,      db_link
      into   d_table_name, d_owner_name, d_db_link
      from   user_synonyms
      where  synonym_name = normalize( p_synonym_name )
      ;
   else
      select table_name,   table_owner,      db_link
      into   d_table_name, d_owner_name, d_db_link
      from   all_synonyms
      where  synonym_name = normalize( p_synonym_name )
      and    owner = normalize( p_owner_name )
      ;
   end if;
   if d_db_link is null then
      declare
         d_is_table constant boolean := IsTable( d_table_name, d_owner_name );
         d_is_view  constant boolean := IsView( d_table_name, d_owner_name );
      begin
         if d_is_table or d_is_view then
            -- the synonym has been resolved to a local table/view
            d_result.table_name := d_table_name;
            d_result.owner_name := d_owner_name;
            d_result.db_link := null;
            DbC.POST
            (  not DbC.PostOn
            or (   d_db_link is null
               and IsUser( d_result.owner_name )
               and AFC.mxor( IsTable( d_result.table_name, d_result.owner_name )
                           , IsView( d_result.table_name, d_result.owner_name )
                           )
               )
            );
         else
            -- the synonym has not been resolved yet, it's still a synonym
            d_result := get_synonym_data( d_table_name, d_owner_name );
         end if;
      end;
   else
      -- the synonym resolves to an outer entity
      d_result.table_name := d_table_name;
      d_result.owner_name := d_owner_name;
      d_result.db_link := d_db_link;
      DbC.POST
      (  not DbC.PostOn
      or (   d_db_link is not null
         and not IsTable( d_result.table_name, d_result.owner_name )
         and not IsView( d_result.table_name, d_result.owner_name )
         )
      );
   end if;
   return d_result;
end; -- AFC_DDL.get_synonym_data
--------------------------------------------------------------------------------
/******************************************************************************
 p_attribute è un attributo (campo) di p_object_name?
******************************************************************************/
function has_attribute
( p_object_name in AFC.t_object_name
, p_attribute_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  number
is
   d_result number;
   d_is_table constant boolean := IsTable( p_object_name, p_owner_name );
   d_is_view constant boolean := IsView( p_object_name, p_owner_name );
   d_is_synonym constant boolean := IsSynonym( p_object_name, p_owner_name );
begin
   DbC.PRE( p_object_name is not null );
   DbC.PRE( not DbC.PreOn  or  CanHandle( p_object_name ) );
   DbC.PRE( not DbC.PreOn  or  Afc.xor( d_is_table, d_is_view, d_is_synonym ) );
   DbC.PRE( p_attribute_name is not null );
   DbC.PRE( not DbC.PreOn  or  CanHandle( p_attribute_name ) );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or CanHandle( p_owner_name )
          );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or IsUser( p_owner_name )
          or d_is_synonym and  p_owner_name = s_PUBLIC
          );
   if d_is_table or d_is_view then
      d_result := has_attribute_table_view( p_object_name, p_attribute_name, p_owner_name );
   else
      declare
         d_synonym_data constant t_synonym_data := get_synonym_data( p_object_name, p_owner_name );
      begin
         if d_synonym_data.db_link is null then
           -- synonym of a table/view on the current data base
           d_result := has_attribute_table_view( d_synonym_data.table_name, p_attribute_name, d_synonym_data.owner_name );
         else
           -- link to an outer db: not supported yet
           DbC.PRE( not DbC.PreOn  or  d_synonym_data.db_link is null, 'has_attribute: d_synonym_data.db_link is null' );
           d_result := null;
         end if;
      end;
   end if;
   DbC.POST( d_result = 1  or  d_result = 0 );
   return  d_result;
end; -- AFC_DDL.has_attribute
--------------------------------------------------------------------------------
/******************************************************************************
 p_attribute è un attributo (campo) di p_object_name?
******************************************************************************/
function has_attribute_table_view
( p_object_name in AFC.t_object_name
, p_attribute_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  number
is
   d_result number;
   d_is_table constant boolean := IsTable( p_object_name, p_owner_name );
   d_is_view constant boolean := IsView( p_object_name, p_owner_name );
   d_owner_name AFC.t_object_name;
begin
   DbC.PRE( p_object_name is not null );
   DbC.PRE( not DbC.PreOn  or  CanHandle( p_object_name ) );
   DbC.PRE( not DbC.PreOn  or  Afc.xor( d_is_table, d_is_view ) );
   DbC.PRE( p_attribute_name is not null );
   DbC.PRE( not DbC.PreOn  or  CanHandle( p_attribute_name ) );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or CanHandle( p_owner_name )
          );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or IsUser( p_owner_name )
          );
   if p_owner_name is null then
      d_owner_name := user;
   else
      d_owner_name := p_owner_name;
   end if;
   begin
      select 1
      into d_result
      from all_tab_columns
      where all_tab_columns.table_name = normalize( p_object_name )
      and   all_tab_columns.column_name = normalize( p_attribute_name )
      and   all_tab_columns.owner = normalize( d_owner_name )
      ;
   exception
      when NO_DATA_FOUND then
         d_result := 0;
   end;
   DbC.POST( d_result = 1  or  d_result = 0 );
   return  d_result;
end; -- AFC_DDL.has_attribute_table_view
--------------------------------------------------------------------------------
/******************************************************************************
 Wrapper booleano di has_attribute.
******************************************************************************/
function HasAttribute
( p_object_name in AFC.t_object_name
, p_attribute_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  boolean
is
   d_result constant boolean := Afc.to_boolean( has_attribute( p_object_name, p_attribute_name, p_owner_name ) );
begin
   return  d_result;
end; -- AFC_DDL.HasAttribute
--------------------------------------------------------------------------------
/******************************************************************************
 p_attribute è un attributo (campo) annullabile di p_object_name?
******************************************************************************/
function is_nullable
( p_object_name in AFC.t_object_name
, p_attribute_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  number
is
   d_result number;
   d_is_table constant boolean := IsTable( p_object_name, p_owner_name );
   d_is_view constant boolean := IsView( p_object_name, p_owner_name );
   d_is_synonym constant boolean := IsSynonym( p_object_name, p_owner_name );
begin
   DbC.PRE( p_object_name is not null );
   DbC.PRE( not DbC.PreOn  or  CanHandle( p_object_name ) );
   DbC.PRE( not DbC.PreOn  or  Afc.xor( d_is_table, d_is_view, d_is_synonym ) );
   DbC.PRE( p_attribute_name is not null );
   DbC.PRE( not DbC.PreOn  or  CanHandle( p_attribute_name ) );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or CanHandle( p_owner_name )
          );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or IsUser( p_owner_name )
          or d_is_synonym and  p_owner_name = s_PUBLIC
          );
   DbC.PRE( not DbC.PreOn  or  HasAttribute( p_object_name, p_attribute_name, p_owner_name ) );
   if d_is_table or d_is_view then
      d_result := is_nullable_table_view( p_object_name, p_attribute_name );
   else
      declare
         d_synonym_data constant t_synonym_data := get_synonym_data( p_object_name, p_owner_name );
      begin
         if d_synonym_data.db_link is null then
           -- synonym of a table/view on the current data base
           d_result := is_nullable_table_view( d_synonym_data.table_name, p_attribute_name, d_synonym_data.owner_name );
         else
           -- link to an outer db: not supported yet
           DbC.PRE( not DbC.PreOn  or  d_synonym_data.db_link is null, 'is_nullable: d_synonym_data.db_link is null' );
           d_result := null;
         end if;
      end;
   end if;
   DbC.POST( d_result = 1  or  d_result = 0 );
   return  d_result;
end; -- AFC_DDL.is_nullable
--------------------------------------------------------------------------------
/******************************************************************************
 p_attribute è un attributo (campo) annullabile di p_object_name?
******************************************************************************/
function is_nullable_table_view
( p_object_name in AFC.t_object_name
, p_attribute_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  number
is
   d_result number;
   d_is_table constant boolean := IsTable( p_object_name, p_owner_name );
   d_is_view constant boolean := IsView( p_object_name, p_owner_name );
   d_owner_name AFC.t_object_name;
begin
   DbC.PRE( p_object_name is not null );
   DbC.PRE( not DbC.PreOn  or  CanHandle( p_object_name ) );
   DbC.PRE( not DbC.PreOn  or  Afc.xor( d_is_table, d_is_view ) );
   DbC.PRE( p_attribute_name is not null );
   DbC.PRE( not DbC.PreOn or CanHandle( p_attribute_name ) );
   DbC.PRE(  not DbC.PreOn
          or p_owner_name is null
          or CanHandle( p_owner_name )
          );
   DbC.PRE( not DbC.PreOn
          or p_owner_name is null
          or IsUser( p_owner_name )
          );
   DbC.PRE( not DbC.PreOn  or  HasAttribute( p_object_name, p_attribute_name, p_owner_name ) );
   if p_owner_name is null then
      d_owner_name := user;
   else
      d_owner_name := p_owner_name;
   end if;
   declare
      d_nullable user_tab_columns.nullable%type;
   begin
      select nullable
      into d_nullable
      from all_tab_columns
      where all_tab_columns.table_name = normalize( p_object_name )
      and   all_tab_columns.column_name = normalize( p_attribute_name )
      and   all_tab_columns.owner = normalize( d_owner_name )
      ;
      DbC.ASSERTION( d_nullable = 'Y' or d_nullable = 'N' );
      if d_nullable = 'Y' then
         d_result := 1;
      else
         d_result := 0;
      end if;
   end;
   DbC.POST( d_result = 1  or  d_result = 0 );
   return  d_result;
end; -- AFC_DDL.is_nullable_table_view
--------------------------------------------------------------------------------
/******************************************************************************
 Wrapper booleano di is_nullable.
******************************************************************************/
function IsNullable
( p_object_name in AFC.t_object_name
, p_attribute_name in AFC.t_object_name
, p_owner_name in AFC.t_object_name default null
) return  boolean
 is
   d_result constant boolean := Afc.to_boolean( is_nullable( p_object_name, p_attribute_name, p_owner_name ) );
begin
   return  d_result;
end; -- AFC_DDL.IsNullable
--------------------------------------------------------------------------------
end AFC_DDL;
/

