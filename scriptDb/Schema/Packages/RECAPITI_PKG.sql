CREATE OR REPLACE package recapiti_pkg
is
 -- Revisione del Package
   s_revisione constant AFC.t_revision := 'V1.00';

   s_table_name constant AFC.t_object_name := 'recapiti';

-- -- Exceptions
--   non_trovato_ni exception;
--   pragma exception_init( non_trovato_ni, -20901 );
--   s_non_trovato_ni_num constant AFC_Error.t_error_number := -20901;
--   s_non_trovato_ni_msg constant AFC_Error.t_error_msg := 'A10051';
--   
--   non_trovato_tipo_recap exception;
--   pragma exception_init( non_trovato_tipo_recap, -20902 );
--   s_non_trovato_tipo_recap_num constant AFC_Error.t_error_number := -20902;
--   s_non_trovato_tipo_recap_msg constant AFC_Error.t_error_msg := 'A10042';
--   
--   non_trovato_comune exception;
--   pragma exception_init( non_trovato_comune, -20903 );
--   s_non_trovato_comune_num constant AFC_Error.t_error_number := -20903;
--   s_non_trovato_comune_msg constant AFC_Error.t_error_msg := 'A10021';
--   
--   trovato_contatto exception;
--   pragma exception_init( trovato_contatto, -20904 );
--   s_trovato_contatto_num constant AFC_Error.t_error_number := -20904;
--   s_trovato_contatto_msg constant AFC_Error.t_error_msg := 'A10043';
--   
--   trovato_blocco_record exception;
--   pragma exception_init( trovato_blocco_record, -20905 );
--   s_trovato_blocco_record_num constant AFC_Error.t_error_number := -20905;
--   s_trovato_blocco_record_msg constant AFC_Error.t_error_msg := 'A10044';
--   
--   non_modificabile_id exception;
--   pragma exception_init( non_modificabile_id, -20906 );
--   s_non_modificabile_id_num constant AFC_Error.t_error_number := -20906;
--   s_non_modificabile_id_msg constant AFC_Error.t_error_msg := 'A10045';
--   
--   
--   
--   non_modificabile_storico exception;
--   pragma exception_init( non_modificabile_storico, -20907 );
--   s_non_modificabile_storico_num constant AFC_Error.t_error_number := -20907;
--   s_non_modificabile_storico_msg constant AFC_Error.t_error_msg := 'A10046';
--   
--   riferimento_unico exception;
--   pragma exception_init( riferimento_unico, -20908 );
--   s_riferimento_unico_num constant AFC_Error.t_error_number := -20908;
--   s_riferimento_unico_msg constant AFC_Error.t_error_msg := 'A10047';
   

--------------------------------------------------------------------------------
-- Versione e revisione
   function versione
   return varchar2;
   pragma restrict_references( versione, WNDS );

   -- Messaggio previsto per il numero di eccezione indicato
   function error_message
   ( p_error_number  in AFC_Error.t_error_number
   ) return AFC_Error.t_error_msg;
   pragma restrict_references( error_message, WNDS );
   


PROCEDURE RECAPITI_RRI
(p_ni                     IN NUMBER,
 p_dal                    IN DATE,
 p_al                     IN DATE,
 p_competenza             IN VARCHAR2,
 p_competenza_esclusiva   IN VARCHAR2,
 p_id_recapito            IN NUMBER, -- nuovo id che ho appena inserito
 p_ID_TIPO_RECAPITO          NUMBER)
 ;
 
PROCEDURE RECAPITI_PU
(  old_ID_RECAPITO IN NUMBER
 , old_NI in NUMBER
 , old_DAL in DATE
 , old_provincia IN NUMBER
 , old_comune IN NUMBER
 , old_tipo_recapito in NUMBER
 , new_ID_RECAPITO IN NUMBER
 , new_ni IN NUMBER
 , new_dal IN DATE
 , new_provincia IN NUMBER
 , new_comune IN NUMBER
 , new_tipo_recapito in NUMBER
);

PROCEDURE RECAPITI_PI
(  new_ni IN NUMBER
 , new_dal IN DATE
 , new_provincia IN NUMBER
 , new_comune IN NUMBER
 , new_tipo_recapito in NUMBER
);

procedure RECAPITI_PD
(OLD_id_recapito IN number,
 old_dal IN date,
 old_al IN date);

FUNCTION CONTA_NI_RECAPITI_DAL_AL (p_ni NUMBER, p_new_id_tipo_recapito number, p_dal date, p_al date)
   RETURN NUMBER;
   
FUNCTION CONTA_NI_RECAPITI_DAL_ALnonull (p_ni NUMBER, p_new_id_tipo_recapito number, p_dal date, p_al date)
   RETURN NUMBER;


FUNCTION CONTA_NI_RECAPITI (p_ni NUMBER, p_new_id_tipo_recapito number)
   RETURN NUMBER;

FUNCTION GET_DAL_ATTUALE_ID_RECAPITO (p_id_recapito IN RECAPITI.id_recapito%TYPE)
      RETURN RECAPITI.dal%TYPE;
      
PROCEDURE CHECK_IMPORTANZA_UNIVOCA (var_id_recapito       NUMBER,
                                  var_ni                  NUMBER,
                                  var_importanza          NUMBER,
                                  var_id_tipo_recapito    VARCHAR2,
                                  var_dal                 DATE,
                                  var_al                  DATE);


   FUNCTION ESTRAI_STORICO
    ( P_NI IN NUMBER)
    RETURN CLOB;
                                        
END;
/

