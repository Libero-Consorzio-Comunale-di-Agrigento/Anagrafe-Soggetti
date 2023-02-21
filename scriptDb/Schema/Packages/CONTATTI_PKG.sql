CREATE OR REPLACE package contatti_pkg
is
 -- Revisione del Package
   s_revisione constant AFC.t_revision := 'V1.01';

   s_table_name constant AFC.t_object_name := 'contatti';

--------------------------------------------------------------------------------
-- Versione e revisione
   function versione
   return varchar2;
   pragma restrict_references( versione, WNDS );

--   -- Messaggio previsto per il numero di eccezione indicato
--   function error_message
--   ( p_error_number  in AFC_Error.t_error_number
--   ) return AFC_Error.t_error_msg;
--   pragma restrict_references( error_message, WNDS );
   


PROCEDURE CONTATTI_RRI
( p_id_recapito IN NUMBER
, p_dal        IN DATE
, p_competenza IN VARCHAR2
, p_competenza_esclusiva IN VARCHAR2
, p_ID_TIPO_contatto number
)
 ;
 
PROCEDURE CONTATTI_PU
(  old_id_contatto IN NUMBER
 , old_id_recapito IN NUMBER
 , old_dal IN DATE
 , old_id_tipo_contatto IN NUMBER
 , new_id_contatto IN NUMBER
 , new_id_recapito IN NUMBER
 , new_dal IN DATE
 , new_id_tipo_contatto IN NUMBER
);

PROCEDURE CONTATTI_PI
(  old_id_contatto IN NUMBER
 , old_id_recapito IN NUMBER
 , old_dal IN DATE
 , old_id_tipo_contatto IN NUMBER
 , new_id_contatto IN NUMBER
 , new_id_recapito IN NUMBER
 , new_dal IN DATE
 , new_id_tipo_contatto IN NUMBER
);

procedure CONTATTI_PD
(old_id_contatto IN number,
 old_dal IN date,
 old_al IN date);


FUNCTION CONTA_RECAP_CONTATTI_DAL_AL (p_id_recapito NUMBER, p_new_id_tipo_contatto number, p_dal date, p_al date)
   RETURN NUMBER;

FUNCTION CONTA_RECAP_CONTATTI (p_id_recapito NUMBER, p_new_id_tipo_contatto number)
   RETURN NUMBER;
   
PROCEDURE CHECK_CONTATTO_UNIVOCO (var_id_contatto         NUMBER,
                                  var_id_recapito         NUMBER,
                                  var_valore              VARCHAR2,
                                  var_id_tipo_contatto    VARCHAR2,
                                  var_dal                 DATE,
                                  var_al                  DATE);
   
PROCEDURE CHECK_IMPORTANZA_UNIVOCA (var_id_contatto       NUMBER,
                                  var_id_recapito         NUMBER,
                                  var_importanza          NUMBER,
                                  var_id_tipo_contatto    VARCHAR2,
                                  var_dal                 DATE,
                                  var_al                  DATE);
                                  
                                  

procedure allinea_inte
( p_ni_as4              in anagrafici.ni%type
, p_id_tipo_contatto    in contatti.id_tipo_contatto%type
, p_indirizzo           in contatti.valore%type
, p_old_indirizzo       in contatti.valore%type
, p_utente_agg          in contatti.utente_aggiornamento%type
);


 FUNCTION ESTRAI_STORICO
    ( P_NI IN NUMBER)
    RETURN CLOB;

END;
/

