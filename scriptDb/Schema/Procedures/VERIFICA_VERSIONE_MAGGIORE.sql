CREATE OR REPLACE procedure verifica_versione_maggiore(p_ver_controllare varchar2,
                                                       p_ver_richiesta varchar2)
IS
   function versione_maggiore (p_versione_controllare varchar2,
                               p_versione_confrontare varchar2,
                               p_uguale number default 1)
                               return number
   is
   v_versione_controllare varchar2(20) := p_versione_controllare;
   v_versione_confrontare varchar2(20) := p_versione_confrontare;
   v_numero_controllare number;
   v_numero_confrontare number;
   v_maggiore_contr integer := 0;
   v_uguale_contr integer := 0;
   v_minore_contr integer := 0;
   v_controllare_maggiore integer := 0;
   begin
   while v_versione_controllare is not null and v_versione_confrontare is not null
        and v_maggiore_contr = 0 and v_minore_contr = 0 loop
      v_numero_controllare  := to_number(afc.get_substr (v_versione_controllare, '.'));
      v_numero_confrontare  := to_number(afc.get_substr (v_versione_confrontare, '.'));
      if v_numero_controllare > v_numero_confrontare then
         v_maggiore_contr := 1;
      elsif v_numero_controllare = v_numero_confrontare then
         v_uguale_contr := 1;
      elsif v_numero_controllare < v_numero_confrontare then
         v_minore_contr := 1;
      end if;
   end loop;
   if  v_maggiore_contr = 1 then -- era maggiore
      v_controllare_maggiore := 1;
   end if;
   if  v_minore_contr = 1 then -- era minore
      v_controllare_maggiore := 0;
   end if;
   if v_versione_controllare is null and v_versione_confrontare is null
      and p_uguale = 1 and v_uguale_contr = 1 and v_maggiore_contr = 0 and v_minore_contr = 0 then -- vanno bene anche uguali
      v_controllare_maggiore := 1;
   end if;
   if v_versione_controllare is not null and v_versione_confrontare is null
      and v_uguale_contr = 1 and v_maggiore_contr = 0 and v_minore_contr = 0 then
      -- erano uguali ma più lungo il controllare
      v_controllare_maggiore := 1;
   end if;
   if v_versione_controllare is  null and v_versione_confrontare is not null
      and v_uguale_contr = 1 and v_maggiore_contr = 0 and v_minore_contr = 0 then
      -- erano uguali ma più lungo il confrontare
      v_controllare_maggiore := 0;
   end if;
   return v_controllare_maggiore;
   end;
   BEGIN
      if instr(p_ver_controllare,'@') >0 then
         raise_application_error (-20999, 'Attenzione istanza &1 in stato degradato. Impossibile continuare');
      end if;
      if versione_maggiore(ltrim(ltrim(p_ver_controllare,'V'),'@'),p_ver_richiesta) = 0 then
         raise_application_error (-20999, p_ver_controllare || ' deve essere superiore a '|| p_ver_richiesta);
      end if;
   END;
/

