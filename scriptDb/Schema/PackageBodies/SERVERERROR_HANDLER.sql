CREATE OR REPLACE package body Servererror_Handler is
/******************************************************************************
 NAME:        Servererror_Handler
 DESCRIPTION: Package to handle the server_error_trigger attributes
              and to support handling of error diagnostic for end user.
 ANNOTATIONS: .
 REVISION: 
 Rev.  Date        Author              Description
 000   23/05/2005  CZecca, FTassinari  First release.
 001   24/03/2006  MFantoni            Se il messaggio di errore e Custom (ORA-20...)
                                       reinvia quello al posto di Generic Message (ORA-20999).
 002   24/03/2006  MFantoni            Controllo errore con substr e non con instr.
******************************************************************************/

s_revisione_body AFC.t_revision := '001';

s_trigger_on boolean := true;
s_trigger_name constant varchar2(30) := 'SERVERERROR_TRIGGER';

function versione return AFC.t_revision is
/******************************************************************************
 NOME:        VERSIONE
 DESCRIZIONE: Restituisce versione e revisione di distribuzione del package.

 RITORNA:     stringa VARCHAR2 contenente versione e revisione.
 NOTE:        Primo numero  : versione compatibilita del Package.
              Secondo numero: revisione del Package specification.
              Terzo numero  : revisione del Package body.
******************************************************************************/
begin
   return AFC.version( s_revisione, s_revisione_body );
end versione; -- Servererror_Handler.versione;

--------------------------------------------------------------------------------

function exists_trigger
return number is
/******************************************************************************
 NAME:        exists_trigger
 DESCRIPTION: Is the server_error_trigger defined in this DB?
 PARAMETERS:  --
 RETURN:      number: 1 if the server_error_trigger is defined in the schema, 0 otherwise.
******************************************************************************/
   d_result number;
begin
   begin
      select 1
      into   d_result
      from   user_triggers
      where  trigger_name = s_trigger_name;
   exception
      when no_data_found then
         d_result := 0;
   end;
   
   DbC.POST( d_result = 1  or  d_result = 0 );
   return  d_result;
end; -- Servererror_Handler.exists_trigger

--------------------------------------------------------------------------------

function ExistsTrigger
return boolean is
/******************************************************************************
 NAME:        ExistsTrigger.
 DESCRIPTION: Is the server_error_trigger defined in this DB?
 NOTES:       Boolean wrapper of the exists_trigger.
******************************************************************************/
   d_result constant boolean := AFC.to_boolean( exists_trigger );
begin
   return  d_result;
end; -- Servererror_Handler.ExistsTrigger

--------------------------------------------------------------------------------

function trigger_is_enabled
return number is
/******************************************************************************
 NAME:        trigger_is_enabled
 DESCRIPTION: Is the server_error_trigger enabled in this DB?
 PARAMETERS:  --
 RETURN:      number: 1 if the server_error_trigger is enabled in the schema, 0 otherwise.
******************************************************************************/
   d_result number;
   d_status user_triggers.status%type;
begin
   DbC.PRE( not DbC.PreOn or ExistsTrigger );
   
   select status
   into   d_status
   from   user_triggers
   where  trigger_name = s_trigger_name;
      
   DbC.ASSERTION(  not DbC.AssertionOn
                or (  d_status = 'ENABLED' or d_status = 'DISABLED' )
                );
   if d_status = 'ENABLED' then
      d_result := 1;
   else
      d_result := 0;
   end if;

   DbC.POST( d_result = 1  or  d_result = 0 );
   return  d_result;
end; -- Servererror_Handler.trigger_is_enabled

--------------------------------------------------------------------------------

function TriggerIsEnabled
return boolean is
/******************************************************************************
 NAME:        TriggerIsEnabled
 DESCRIPTION: Is the server_error_trigger enabled in this DB?
 PARAMETERS:   --
 RETURN:      Boolean wrapper of the trigger_is_enabled.
******************************************************************************/
   d_result constant boolean := AFC.to_boolean( trigger_is_enabled );
begin
   return  d_result;
end; -- Servererror_Handler.TriggerIsEnabled

--------------------------------------------------------------------------------

function trigger_on
return number is
/******************************************************************************
 NAME:        trigger_on
 DESCRIPTION: Is the server_error_trigger switched-on in this DB?
 PARAMETERS:  --
 RETURN:      number: 1 if the server_error_trigger is switched-on in the schema, 0 otherwise.
******************************************************************************/
   d_result number := AFC.to_number( s_trigger_on );
begin
   return d_result;
end; -- Servererror_Handler.trigger_on

--------------------------------------------------------------------------------

function TriggerOn
return boolean is
/******************************************************************************
 NAME:        TriggerOn
 DESCRIPTION: Is the server_error_trigger switched-on?
 PARAMETERS:  --
 RETURN:      boolean: true if the server_error_trigger is switched-on in the schema, false otherwise.
******************************************************************************/
   d_result boolean := s_trigger_on;
begin
   return d_result;
end; -- Servererror_Handler.TriggerOn

--------------------------------------------------------------------------------

procedure trigger_set
( p_on in number
) is
/******************************************************************************
 NAME:        trigger_set
 DESCRIPTION: To switch on/off the server_error_trigger
 PARAMETERS:  p_on: 1 (to switch-on), 0 (to switch-off)
 NOTES:       number wrapper of TriggerSet
******************************************************************************/
begin
   TriggerSet( AFC.to_boolean( p_on ) );
end; -- Servererror_Handler.trigger_set

--------------------------------------------------------------------------------

procedure TriggerSet
( p_on in boolean
) is
/******************************************************************************
 NAME:        TriggerSet
 DESCRIPTION: To switch on/off the server_error_trigger
 PARAMETERS:  p_on: true (to switch-on), false (to switch-off)
******************************************************************************/
begin
   s_trigger_on := p_on;
end; -- Servererror_Handler.TriggerSet

--------------------------------------------------------------------------------

procedure handle_error is
/******************************************************************************
 NAME:        handle_error
 DESCRIPTION: Available when not TriggerOn, reformulates both the numeric error code
              and the diagnostic message for sake of simplicity for end users.
 REVISION:
 Rev.  Date        Author              Description
 001   24/03/2006  MFantoni            Se il messaggio di errore e Custom (ORA-20...)
                                       reinvia quello al posto di Generic Message (ORA-20999).
 002   24/03/2006  MFantoni            Controllo errore con substr e non con instr.
******************************************************************************/
   d_error_stack varchar2(32000); 
   d_error_code number(5); 
   d_error_msg varchar2(2000); 
begin
   DbC.ASSERTION( not DbC.AssertionOn or TriggerIsEnabled );
   DbC.PRE( not DbC.AssertionOn or TriggerOn );
   
   d_error_stack := DBMS_UTILITY.format_error_stack; 

   d_error_msg := si4.get_error( d_error_stack ); 
   -- Se Gestione Errori restituisce interpretazione ripropone errore ORA- in ingresso
   if substr( d_error_msg, 1, 4 ) != 'ORA-' then
      d_error_code := to_number( substr( d_error_stack, 4, 6 ) );
      if substr( d_error_stack, 1, 6 ) = 'ORA-20' then
         raise_application_error( d_error_code, d_error_msg );
      else 
         raise_application_error( AFC_Error.generic_error_number, d_error_msg );
      end if;
   end if;
   
end; -- Servererror_Handler.handle_error

--------------------------------------------------------------------------------

end Servererror_Handler;
/

