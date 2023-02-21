CREATE OR REPLACE PACKAGE BODY Master_Utility IS
FUNCTION VERSIONE  RETURN VARCHAR2 IS
/******************************************************************************
 NOME:        VERSIONE
 DESCRIZIONE: Restituisce la versione e la data di distribuzione del package.
 PARAMETRI:   --
 RITORNA:     stringa varchar2 contenente versione e data.
 NOTE:        Il secondo numero della versione corrisponde alla revisione
              del package.
******************************************************************************/
BEGIN
   RETURN 'V1.1 del 11/01/2010';
END VERSIONE;
--
FUNCTION REFRESH_SLAVES_JOB
( p_refresh_group                       in varchar2
, p_istanza_master                      in varchar2 default si4.istanza
)
RETURN varchar2
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  d_job                                 NUMBER;
  d_return                              varchar2(4000);
  d_statement                           varchar2(4000);
  d_db_link                             varchar2(200);
  d_link_oracle                         varchar2(2000);
  d_progetto                            varchar2(20);
BEGIN
   if ad4_istanza.IS_ISTANZA_MASTER(nvl(p_istanza_master, si4.istanza)) = 1 then
      select progetto
        into d_progetto
        from ad4_istanze
       where istanza = p_istanza_master
      ;
      open master_utility.c_slaves(d_progetto, 0);
      fetch master_utility.c_slaves into d_db_link,d_link_oracle;
      while master_utility.c_slaves%found loop
         begin
            d_statement := 'CALL job_utility.crea_commit(''begin dbms_refresh.refresh@'
                           || d_db_link
                           ||'('''''||p_refresh_group||'''''); end;'') INTO :d_job';
            EXECUTE IMMEDIATE d_statement USING OUT d_job;
            d_return := d_return||'Attivato job n.'||d_job||' per allineamento di '||d_db_link||chr(13)||chr(10);
         exception
            when others then
               d_return := d_return||'Attivazione job fallita per allineamento di '||d_db_link||': '||SQLERRM||chr(13)||chr(10);
         end;
         fetch master_utility.c_slaves into d_db_link,d_link_oracle;
      end loop;
      close master_utility.c_slaves;
      commit;
   end if;
   RETURN d_return;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
      rollback;
END REFRESH_SLAVES_JOB;
PROCEDURE REFRESH_SLAVES (
   p_refresh_group in varchar2,
   p_progetto in varchar2
)
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   d_db_link      varchar2(200);
   d_link_oracle  varchar2(2000);
   d_progetto     varchar2(30) := p_progetto;
   d_refresh_group varchar2(30) := nvl(p_refresh_group, user||'G');
BEGIN
   if d_progetto is null then
      select progetto
        into d_progetto
        from ad4_istanze
       where upper(user_oracle) = user
         and INSTR ('.' || installazione || '.', '.MASTER.') > 0
      ;
   end if;
   open c_slaves(d_progetto, 0);
   fetch c_slaves into d_db_link,d_link_oracle;
   while c_slaves%found loop
      begin
         EXECUTE IMMEDIATE (   'begin DBMS_REFRESH.REFRESH@'
                               || d_db_link
                               || '('''
                               || d_refresh_group
                               || ''');end;'
                              );
      exception
         when others then
            null;
      end;
      fetch c_slaves into d_db_link,d_link_oracle;
   end loop;
   close c_slaves;
   commit;
exception
   when others then
      if c_slaves%ISOPEN then
         close c_slaves;
      end if;
      rollback;
      raise;
END;
end MASTER_UTILITY;
/

