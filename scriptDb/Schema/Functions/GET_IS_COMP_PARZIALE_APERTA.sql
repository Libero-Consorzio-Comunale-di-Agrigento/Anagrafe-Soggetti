CREATE OR REPLACE FUNCTION get_is_comp_parziale_aperta
( p_ni    in number
)
RETURN number
IS
/*************************************************************
RITORNO: numero
        1 = il soggetto p_ni ha un record aperto con competenza_esclusiva = 'P'
        0 = il soggetto p_ni NON ha un record aperto con competenza_esclusiva = 'P'
        non dovrebbero esserci altri casi in quanto può esserci sono 1 periodo aperto.
REVISIONI:
       Rev. Data       Autore Descrizione
       ---- ---------- ------ ------------------------------------------------------
            06/02/2020   Sneg Prima Emissione Bug #40447
*************************************************************/
  PRAGMA AUTONOMOUS_TRANSACTION;
  v_num_competenza_parziale number:=0;
begin
  select count(*)
    into v_num_competenza_parziale
    from anagrafe_soggetti
   where ni = p_ni
     and competenza_esclusiva = 'P'
     and al is null;
  return v_num_competenza_parziale;
end;
/

