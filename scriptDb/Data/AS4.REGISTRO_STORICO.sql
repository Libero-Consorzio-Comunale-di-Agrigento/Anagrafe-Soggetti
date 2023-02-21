Insert into REGISTRO_STORICO
   (ID_EVENTO, CHIAVE, STRINGA, COMMENTO, VALORE, 
    DATA, OPERAZIONE, BI_RIFERIMENTO, UTENTE_AGG, USER_ORACLE, 
    INFO, PROGRAMMA)
 Values
   (1, 'PRODUCTS', '(Predefinito)', NULL, NULL, 
    TO_DATE('02/21/2023 10:20:43', 'MM/DD/YYYY HH24:MI:SS'), 'I', NULL, NULL, 'AS4', 
    'SVI-AT-CD-AS2::UNKNOWN::ADSADMIN', 'JDBC Thin Client');
Insert into REGISTRO_STORICO
   (ID_EVENTO, CHIAVE, STRINGA, COMMENTO, VALORE, 
    DATA, OPERAZIONE, BI_RIFERIMENTO, UTENTE_AGG, USER_ORACLE, 
    INFO, PROGRAMMA)
 Values
   (2, 'PRODUCTS/ANAGRAFICA', 'RuoliSoloLettura', 'Elenco dei ruoli solo in lettura tramite applicativo separati da $$', NULL, 
    TO_DATE('02/21/2023 10:20:43', 'MM/DD/YYYY HH24:MI:SS'), 'I', NULL, NULL, 'AS4', 
    'SVI-AT-CD-AS2::UNKNOWN::ADSADMIN', 'JDBC Thin Client');
Insert into REGISTRO_STORICO
   (ID_EVENTO, CHIAVE, STRINGA, COMMENTO, VALORE, 
    DATA, OPERAZIONE, BI_RIFERIMENTO, UTENTE_AGG, USER_ORACLE, 
    INFO, PROGRAMMA)
 Values
   (3, 'PRODUCTS/ANAGRAFICA', 'RicercaAnagrafeAlternativa', 'Indica se forzare utilizzo di anagrafe alternativa esistente da batch(Valori Possibili: SI, NO, valore codificato appositamente).', 'NO', 
    TO_DATE('02/21/2023 10:20:43', 'MM/DD/YYYY HH24:MI:SS'), 'I', NULL, NULL, 'AS4', 
    'SVI-AT-CD-AS2::UNKNOWN::ADSADMIN', 'JDBC Thin Client');
Insert into REGISTRO_STORICO
   (ID_EVENTO, CHIAVE, STRINGA, COMMENTO, VALORE, 
    DATA, OPERAZIONE, BI_RIFERIMENTO, UTENTE_AGG, USER_ORACLE, 
    INFO, PROGRAMMA)
 Values
   (4, 'PRODUCTS/ANAGRAFICA', 'Storicizzare', 'Indica se forzare storicizzazione di anagrafica (Valori Possibili: SI, NO, valore codificato appositamente).', 'NO', 
    TO_DATE('02/21/2023 10:20:43', 'MM/DD/YYYY HH24:MI:SS'), 'I', NULL, NULL, 'AS4', 
    'SVI-AT-CD-AS2::UNKNOWN::ADSADMIN', 'JDBC Thin Client');
Insert into REGISTRO_STORICO
   (ID_EVENTO, CHIAVE, STRINGA, COMMENTO, VALORE, 
    DATA, OPERAZIONE, BI_RIFERIMENTO, UTENTE_AGG, USER_ORACLE, 
    INFO, PROGRAMMA)
 Values
   (5, 'PRODUCTS/ANAGRAFICA', 'Modificabile', 'Indica se anagrafica modificabile tramite applicativo (Valori Possibili: SI, NO, valore codificato appositamente).', 'SI', 
    TO_DATE('02/21/2023 10:20:43', 'MM/DD/YYYY HH24:MI:SS'), 'I', NULL, NULL, 'AS4', 
    'SVI-AT-CD-AS2::UNKNOWN::ADSADMIN', 'JDBC Thin Client');
Insert into REGISTRO_STORICO
   (ID_EVENTO, CHIAVE, STRINGA, COMMENTO, VALORE, 
    DATA, OPERAZIONE, BI_RIFERIMENTO, UTENTE_AGG, USER_ORACLE, 
    INFO, PROGRAMMA)
 Values
   (6, 'PRODUCTS/ANAGRAFICA', 'OrdinamentoAnagrafica', 'Indica se forzare un ordinamento per le ricerche di anagrafica (Valori Possibili: elenco dei campi separati da ,).', 'cognome, nome, dal', 
    TO_DATE('02/21/2023 10:20:43', 'MM/DD/YYYY HH24:MI:SS'), 'I', NULL, NULL, 'AS4', 
    'SVI-AT-CD-AS2::UNKNOWN::ADSADMIN', 'JDBC Thin Client');
COMMIT;
