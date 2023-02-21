CREATE OR REPLACE FUNCTION si4comp_binding
( p_testo IN VARCHAR2
, p_oggetto IN VARCHAR2
, p_tipo_oggetto IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
d_testo VARCHAR2(4000);
/******************************************************************************
   NAME:       SI4COMP_BINDING
   PURPOSE:
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/01/2006          1. Created this function.
   NOTES:
      Object Name:     SI4COMP_BINDING
      Sysdate:         10/01/2006
      Date and Time:   10/01/2006, 9.58.59, and 10/01/2006 9.58.59
******************************************************************************/
BEGIN
   d_testo := REPLACE(p_testo,':'||p_tipo_oggetto,p_oggetto);
   RETURN d_testo;
   EXCEPTION
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END si4comp_binding;
/

