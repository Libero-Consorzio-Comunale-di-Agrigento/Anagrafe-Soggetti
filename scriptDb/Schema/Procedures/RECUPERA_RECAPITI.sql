CREATE OR REPLACE PROCEDURE recupera_recapiti (
   p_id_anagrafica    anagrafici.id_anagrafica%TYPE,
   p_ni               anagrafici.ni%TYPE,
   p_dal              anagrafici.dal%TYPE)
IS
BEGIN
   -- devo farlo solo se periodo aperto con al NULLO solo in INSERIMENTO
   -- cerco se esisono
   FOR v_recapito
      IN (SELECT *
            FROM recapiti r
           WHERE ni = p_ni
                 AND dal < p_dal
                 -- mod Stefania
                 AND NOT EXISTS
                        (SELECT 1
                           FROM recapiti
                          WHERE     r.ni = ni
                                AND r.dal < dal
                                AND r.dal < p_dal))
   LOOP
      -- ricopio
      recapiti_tpk.ins (
         p_id_recapito            => NULL,
         p_ni                     => p_ni,
         p_dal                    => v_recapito.dal,
         p_al                     => v_recapito.al,
         p_descrizione            => v_recapito.descrizione,
         p_id_tipo_recapito       => v_recapito.id_tipo_recapito,
         p_indirizzo              => v_recapito.indirizzo,
         p_provincia              => v_recapito.provincia,
         p_comune                 => v_recapito.comune,
         p_cap                    => v_recapito.cap,
         p_presso                 => v_recapito.presso,
         p_importanza             => v_recapito.importanza,
         p_competenza             => v_recapito.competenza,
         p_competenza_esclusiva   => v_recapito.competenza_esclusiva,
         p_version                => v_recapito.version,
         p_utente_aggiornamento   => v_recapito.utente_aggiornamento,
         p_data_aggiornamento     => v_recapito.data_aggiornamento);
   END LOOP;
END;
/

