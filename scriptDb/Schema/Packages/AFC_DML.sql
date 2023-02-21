CREATE OR REPLACE package AFC_DML is
/******************************************************************************
 NOME:        AFC_DML.
 DESCRIZIONE: General utilities for data manipulation
 ANNOTAZIONI: .
 REVISIONI: .
 <CODE>
 Rev.  Data        Autore  Descrizione.
 00    12/05/2005  CZECCA  Prima emissione.
 01    30/08/2006  FT      Aggiunta di get_ref_cursor
 02    13/08/2007  FT      Aggiunta function versione (già presente nel body)
 </CODE>
******************************************************************************/
   s_revisione constant VARCHAR2(30) := 'V1.02';
   function versione return VARCHAR2;
   pragma restrict_references( versione, WNDS, WNPS );
   procedure chk_delete
   ( p_table_name in varchar2
   , p_rowid in varchar2
   );
   function get_ref_cursor
   ( p_statement in AFC.t_statement
   ) return AFC.t_ref_cursor;
end AFC_DML;
/

