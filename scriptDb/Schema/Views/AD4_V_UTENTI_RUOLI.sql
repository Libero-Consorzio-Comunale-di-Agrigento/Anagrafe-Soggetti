CREATE OR REPLACE FORCE VIEW AD4_V_UTENTI_RUOLI
(UTENTE, RUOLO, ISTANZA)
BEQUEATH DEFINER
AS 
SELECT utente, modulo || '_' || ruolo ruolo, istanza
     FROM AD4_DIRITTI_ACCESSO
    WHERE istanza = 'AS4';

