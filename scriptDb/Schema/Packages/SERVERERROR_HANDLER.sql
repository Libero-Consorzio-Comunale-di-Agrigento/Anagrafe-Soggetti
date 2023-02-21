CREATE OR REPLACE package Servererror_Handler is
/******************************************************************************
 NAME:        Servererror_Handler
 DESCRIPTION: Package to handle the server_error_trigger attributes
              and to support handling of error diagnostic for end user.
 ANNOTATIONS: .
 REVISION: 
 <CODE>
 Rev.  Date        Author              Description
 00    23/05/2005  CZecca, FTassinari  First release.
 01    24/03/2006  MFantoni            Funzione Versione ritorna Type AFC.t_revision.    
 </CODE>
******************************************************************************/


   -- Revision
   s_revisione AFC.t_revision := 'V1.01';

   -- Version and revision
   function versione return AFC.t_revision;
   pragma restrict_references(versione, WNDS, WNPS);

   -- Is the trigger server_error defined in this DB?
   function exists_trigger
   return number;
   pragma restrict_references( exists_trigger, WNDS );

   -- Is the trigger server_error defined in this DB?
   -- boolean wrapper
   function ExistsTrigger
   return boolean;
   pragma restrict_references( ExistsTrigger, WNDS );

   -- Is the trigger server_error enabled in this DB?
   function trigger_is_enabled
   return number;
   pragma restrict_references( trigger_is_enabled, WNDS );

   -- Is the trigger server_error enabled into this DB?
   -- boolean wrapper
   function TriggerIsEnabled
   return boolean;
   pragma restrict_references( TriggerIsEnabled, WNDS );

   -- Is the trigger server_error_trigger switched-on?
   function trigger_on
   return number;
   pragma restrict_references( trigger_on, WNDS );

   -- Is the trigger server_error_trigger switched-on?
   -- boolean wrapper
   function TriggerOn
   return boolean;
   pragma restrict_references( TriggerOn, WNDS );

   -- To enable/disable the server_error_trigger
   procedure trigger_set
   ( p_on in number
   );

   -- To enable/disable the server_error_trigger
   -- boolean wrapper
   procedure TriggerSet
   ( p_on in boolean
   );
   
   -- Reformulate both the numeric error code and the diagnostic message
   -- for sake of simplicity for end users
   -- When not TriggerOn (specific diagnostic off t.i diagnostic for the end user)
   -- and the error in not a 'ORA-' error raises
   -- {*} AFC_Error.generic_error
   procedure handle_error;

end Servererror_Handler;
/

