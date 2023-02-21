CREATE OR REPLACE package MASTER_UTILITY is /* MASTER_LINK */
/******************************************************************************
 NOME:        MAsTER_UTILITY.
 DESCRIZIONE: .
 ANNOTAZIONI:
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 0    29/11/2006 MM     Creazione.
 1    11/01/2010 MM     Creazione refresh_slaves.
******************************************************************************/
cursor c_slaves(p_progetto in varchar2, p_check_attivo in number default 1) is
   SELECT distinct db_link, link_oracle
     FROM ad4_istanze, all_db_links
    WHERE progetto = p_progetto
      AND (instr('.'|| installazione ||'.', '.SLAVEGEO.') >0
            OR
           instr('.'|| installazione ||'.', '.SLAVEGEOU.') >0)
       AND owner = 'PUBLIC'
       AND UPPER (host) = UPPER (link_oracle)
       and ( p_check_attivo = 0
            or
             ( p_check_attivo = 1 and
                exists (select 1
                          from ad4_slaves
                         where db_link = all_db_links.db_link
                           and stato = 'A'
                       )
             )
          )
;
FUNCTION VERSIONE
RETURN VARCHAR2;
FUNCTION REFRESH_SLAVES_JOB
( p_refresh_group                      in varchar2
, p_istanza_master                     in varchar2 default si4.istanza
)
RETURN varchar2;
PROCEDURE REFRESH_SLAVES (
   p_refresh_group in varchar2 default null,
   p_progetto in varchar2 default null
);
end MASTER_UTILITY;
/

