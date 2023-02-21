Insert into REGISTRO
   (CHIAVE, STRINGA, COMMENTO, VALORE)
 Values
   ('PRODUCTS/ANAGRAFICA', 'RegistrazioneOkModificaLineare', 'Indica se registrare nella key_error_log le modifiche lineari di Anagrafica terminate con successo', 'NO');
Insert into REGISTRO
   (CHIAVE, STRINGA, COMMENTO, VALORE)
 Values
   ('PRODUCTS/ANAGRAFICA', 'RegistrazioneErroriModificaLineare', 'Indica se registrare nella key_error_log le modifiche lineari di Anagrafica terminate con errore', 'NO');
Insert into REGISTRO
   (CHIAVE, STRINGA, COMMENTO, VALORE)
 Values
   ('PRODUCTS/ANAGRAFICA', 'NOinserimentoRCEntiSO', 'Indica se impedire aggiunta di Recapiti o Contatti ai soggetti che sono enti di Struttura Organizzativa (Valori Possibili: null = NO, SI)', 'NO');
Insert into REGISTRO
   (CHIAVE, STRINGA, COMMENTO, VALORE)
 Values
   ('PRODUCTS/ANAGRAFICA', 'IndiceIntermedia', 'Indica se sono attive le ricerche sui testi (Valori Possibili: null = NO, SI)', 'SI');
Insert into REGISTRO
   (CHIAVE, STRINGA, COMMENTO, VALORE)
 Values
   ('PRODUCTS', '(Predefinito)', NULL, NULL);
Insert into REGISTRO
   (CHIAVE, STRINGA, COMMENTO, VALORE)
 Values
   ('PRODUCTS/ANAGRAFICA', 'RuoliSoloLettura', 'Elenco dei ruoli solo in lettura tramite applicativo separati da $$', NULL);
Insert into REGISTRO
   (CHIAVE, STRINGA, COMMENTO, VALORE)
 Values
   ('PRODUCTS/ANAGRAFICA', 'RicercaAnagrafeAlternativa', 'Indica se forzare utilizzo di anagrafe alternativa esistente da batch(Valori Possibili: SI, NO, valore codificato appositamente).', 'NO');
Insert into REGISTRO
   (CHIAVE, STRINGA, COMMENTO, VALORE)
 Values
   ('PRODUCTS/ANAGRAFICA', 'Storicizzare', 'Indica se forzare storicizzazione di anagrafica (Valori Possibili: SI, NO, valore codificato appositamente).', 'NO');
Insert into REGISTRO
   (CHIAVE, STRINGA, COMMENTO, VALORE)
 Values
   ('PRODUCTS/ANAGRAFICA', 'Modificabile', 'Indica se anagrafica modificabile tramite applicativo (Valori Possibili: SI, NO, valore codificato appositamente).', 'SI');
Insert into REGISTRO
   (CHIAVE, STRINGA, COMMENTO, VALORE)
 Values
   ('PRODUCTS/ANAGRAFICA', 'OrdinamentoAnagrafica', 'Indica se forzare un ordinamento per le ricerche di anagrafica (Valori Possibili: elenco dei campi separati da ,).', 'cognome, nome, dal');
COMMIT;
