CREATE OR REPLACE PACKAGE Utilitypackage
/******************************************************************************
 Contiene oggetti di utilita generale.
 REVISIONI.
 Rev. Data        Autore  Descrizione
 ---- ----------  ------  ----------------------------------------------------
 1    23/01/2001  MF      Inserimento commento.
 2    17/12/2003  MM      Aggiunta compilazione classi java.
 3    19/10/2006  VA      Inserite procedure Disable_all e Enable_All, inseriti i metodi presenti nel Package SIAREF.
 4    14/12/2006  MM      Introduzione del parametro p_java_class in compile_all.
 5    08/10/2007  FT      Aggiunta compilazione synonym.
 6    12/12/2007  FT      compile_all: esclusione degli oggetti il cui nome inizia con 'BIN$'.
 7    08/01/2010  SNeg    Compilazione schema PUBLIC per validare i sinonimi pubblici.
 8    22/06/2010  SNeg    Metodi tab_disable_all e tab_enable_all per abilitare e disabilitare su una specifica tabella.
 9    07/07/2011  FT      Allineati i commenti col nuovo standard di plsqldoc.
 10   20/04/2016  Sneg    Aggiunti metodi di save e restore constraint
******************************************************************************/
AS
   /******************************************************************************
    Compila tutti gli oggetti invalidi del Schema.
   ******************************************************************************/
   PROCEDURE Compile_All( p_java_class IN NUMBER DEFAULT 1 );
   /******************************************************************************
    Disabilita tutti i trigger e i constraint di Foreign Key e di Check dello Schema.
   ******************************************************************************/
   PROCEDURE Disable_All;
   /******************************************************************************
    Abilita tutti i trigger e i constraint di Foreign Key e di Check dello Schema.
    %param p_validate IN NUMBER Forza la validate o la novalidate
   ******************************************************************************/
   PROCEDURE Enable_All(p_validate NUMBER DEFAULT 1);
   /******************************************************************************
    Disabilita tutti i trigger e i constraint di Foreign Key e di Check della tabella indicata come parametro. Il parametro viene usato in like.
    %param p_table IN VARCHAR2 Tabella per cui disabilitare
   ******************************************************************************/
   PROCEDURE Tab_Disable_All(p_table VARCHAR2);
   /******************************************************************************
    Abilita tutti i trigger e i constraint di Foreign Key e di Check dello Schema Il parametro p_table viene usato in like.
    %param p_table IN VARCHAR2 Tabella per cui abilitare
    %param p_validate IN NUMBER Forza la validate o la novalidate
   ******************************************************************************/
   PROCEDURE Tab_Enable_All(p_table VARCHAR2
                         ,p_validate NUMBER DEFAULT 1);
   /******************************************************************************
    Creazione Grant.
   ******************************************************************************/
   PROCEDURE CREATE_GRANT  (p_grantee IN VARCHAR2,
                          p_object  IN VARCHAR2 := '%',
                          p_type    IN VARCHAR2 := '',
                          p_grant   IN VARCHAR2 := '',
                          p_option  IN VARCHAR2 := '',
                          p_grantor IN VARCHAR2 := USER);
   /******************************************************************************
    Assegna ad un dato oggetto le stesse grant di un'altro esistente.
    %param p_object IN VARCHAR2 Oggetto su cui dare le grant
    %param p_likeobject IN VARCHAR2 Oggetto template
    %param p_grantor IN VARCHAR2 Utente proprietario dell'oggetto
   ******************************************************************************/
   PROCEDURE GRANT_LIKE     (p_object     IN VARCHAR2,
                           p_likeobject IN VARCHAR2,
                           p_grantor    IN VARCHAR2 DEFAULT USER);
   /******************************************************************************
    Crea i sinonimi per gli oggetti a cui si ha accesso.
    %param p_object IN VARCHAR2 Oggetto per cui creare il sinonimo
    %param p_prefix IN VARCHAR2 Eventuale prefisso da apporre al sinonimo
    %param p_grantee IN VARCHAR2 Utente proprietario del sinonimo
    %raises ORA-20999 Occorre dare la grant <Create synonym> direttamente all'utente
   ******************************************************************************/
   PROCEDURE CREATE_SYNONYM  (p_object         IN  VARCHAR2 := '%',
                            p_prefix         IN  VARCHAR2 := '',
                            p_grantor        IN  VARCHAR2 := '%',
                            p_grantee        IN  VARCHAR2 := USER );
   /******************************************************************************
    Crea le viste per gli oggetti di un dato utente accessibili
    %param p_owner IN VARCHAR2 Proprietario degli oggetti  di cui creare la vista
    %param p_object IN VARCHAR2 Oggetto di cui creare la vista
    %param p_db_link IN VARCHAR2 Eventuale dblink
    %raises ORA-20999 Occorre dare la grant <Create view> direttamente all'utente
   ******************************************************************************/
   PROCEDURE CREATE_VIEW (p_owner            IN  VARCHAR2 ,
                        p_object           IN  VARCHAR2 := '%',
                        p_prefix           IN  VARCHAR2 := '',
                        p_db_link          IN  VARCHAR2 := '');
   /******************************************************************************
    Restituisce versione e revisione di distribuzione del package.
    %return varchar2: contiene versione e revisione.
    %note Il secondo numero della versione corrisponde alla revisione del package.
   ******************************************************************************/
   FUNCTION  VERSIONE         RETURN VARCHAR2;
   /******************************************************************************
    Restituisce elenco delle colonne che costituiscono il constraint indicato.
    %return varchar2: contiene elenco colonne separate da virgola.
    %param p_owner IN VARCHAR2 Proprietario del constraint
    %param p_constraint_name IN VARCHAR2 Nome del constraint
   ******************************************************************************/
   FUNCTION get_constraint_columns (p_owner            IN VARCHAR2,
                                 p_constraint_name   IN VARCHAR2)
      RETURN VARCHAR2;
   /******************************************************************************
    Restituisce elenco delle colonne che costituiscono l'indice indicato.
    %return varchar2: contiene elenco colonne separate da virgola.
    %param p_index_name IN VARCHAR2 Nome dell indice
    %param p_table_owner IN VARCHAR2 Proprietario della tabella
    %param p_table_name IN VARCHAR2 Nome della tabella
   ******************************************************************************/
   FUNCTION get_index_columns (p_table_owner IN VARCHAR2,
                            p_table_name  IN VARCHAR2,
                            p_index_name IN VARCHAR2)
      RETURN VARCHAR2;
   /******************************************************************************
    Restituisce il nome del constraint in base allo statement per la creazione
    %return varchar2: nome del constraint.
    %param p_constraint_type IN VARCHAR2 tipo del constraint
    %param p_constraint_statement IN VARCHAR2 Statement memorizzato nella SAVE_RESTORE_CONSTRAINTS
   ******************************************************************************/
   FUNCTION get_constraint_name (p_constraint_type        VARCHAR2,
                              p_constraint_statement    VARCHAR2)
      RETURN VARCHAR2;
   /******************************************************************************
    Salva lo statement per ricostruire il constraint nella tabella SAVE_RESTORE_CONSTRAINTS.
    %param p_table IN VARCHAR2 Nome della tabella
    %param p_owner IN VARCHAR2 Nome del proprietario, default USER
   ******************************************************************************/
   PROCEDURE save_constraints (p_table    VARCHAR2,
                            p_owner    VARCHAR2 DEFAULT USER );
   /******************************************************************************
    Legge le informazioni memorizzate nella SAVE_RESTORE_CONSTRAINTS per tabella
    e user indicati e crea gli oggetti indicati sulla nuova tabella (o materialized
    view) e sul nuovo user.
    %param p_from_table IN VARCHAR2 Nome della tabella da cui copiare i constraint
                                    precedentemente salvati sulla SAVE_RESTORE_CONSTRAINTS
    %param p_to_table IN VARCHAR2 Nome della tabella su cui creare i constraint
    %param p_from_user IN VARCHAR2 Nome del proprietario dell oggetto da cui copiare, default USER
    %param p_to_user IN VARCHAR2 Nome del proprietario dell oggetto nel quale creare i constraint
    %param p_PK indica se creare le primary key, default = SI%
    %param p_UK indica se creare le unique key, default = SI%
    %param p_FK indica se creare le foreign key, default = SI%
    %param p_IK indica se creare gli indici, default = SI%
    %param p_REF_PK indica se creare le reference key, default = SI%
    NOTE: in automatico scrive lo statement in base al tipo di oggetto di destinazione
    (tabello o materialized view).
    Genera un nome univoco per il constraint sostituendo alias di tabella se definito
    nei commenti, in caso di omonimia aggiunge un progressivo.
   ******************************************************************************/
   PROCEDURE restore_constraints (p_from_table    VARCHAR2,
                               p_to_table      VARCHAR2 DEFAULT NULL ,
                               p_from_user     VARCHAR2 DEFAULT USER ,
                               p_to_user       VARCHAR2 DEFAULT USER ,
                               p_PK            VARCHAR2 DEFAULT 'SI' ,
                               p_UK            VARCHAR2 DEFAULT 'SI' ,
                               p_FK            VARCHAR2 DEFAULT 'SI' ,
                               p_IK            VARCHAR2 DEFAULT 'SI' ,
                               p_REF_PK        VARCHAR2 DEFAULT 'SI' );
END Utilitypackage;
/

