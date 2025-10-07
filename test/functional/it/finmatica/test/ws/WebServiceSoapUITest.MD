# Test anagrafica Casi di test

## Anagrafica - 
* _tipoSoggetto_: I=Individuo, E=Persona Giuridica, G=Generico oaltri valori definiti sul dizionario)

### tpkInsertAnagrafe
Consente l’inserimento di una anagrafica nel sistema centralizzato, potendo indicare oltre ai dati prettamente anagrafici, anche le informazioni del recapito principale, ovvero della residenza o sede legale, e del recapito accessorio, ovvero domicilio o recapito secondario, e dei principali contatti ad essi associati.

### tpkInsertAnagrafici

### tpkUpdateAnagrafe

## Recapiti

* tipoRecapito: RESIDENZA, DOMICILIO e GENERICO
   
### InsertpkInsertRecapito

### tpkUpdateRecapito

### updRecapito
Consente l’aggiornamento di un recapito per il quale siano noti o la chiave identificativa univoca _idRecapito_ o la coppia di informazioni chiave identificativa _ni_ del soggetto e tipologia del recapito _tipoRecapito_ 

* Caso di _al_ valorizzato_: 
* Caso di _al_ NON valorizzato:


## Contatto 

### tpkInsertContatto
* tipoContatto: TELEFONO, FAX, MAIL o MAIL PEC ed eventuali ulteriori codifiche 

### tpkUpdateContatto
Consente l’aggiornamento di un contatto per il quale sia nota la chiave identificativa univoca _idContatto_, oltre alla chiave identificativa del contatto sono obbligatori la data di decorrenza del contatto, _dal_, ed il valore del contatto stesso.

### updContatto
Consente l’aggiornamento di un contatto per il quale siano noti o la chiave identificativa univoca _idContatto_ o la chiave identificativa _ni_ del soggetto, la tipologia del recapito _tipoRecapito_, che può assumere i valori RESIDENZA,  DOMICILIO e GENERICO, o eventuali altri valori codificati nel sistema, e la tipologia del contatto, che può assumere i valori TELEFONO, FAX , MAIL, PEC o eventuali altri valori codificati nel sistema.

## Ricerca anagrafica
Consente la ricerca all’interno del repository AS4 di un soggetto anagrafico valido, valorizzando almeno uno dei parametri di input previsti. Il metodo ritorna i dati anagrafici del o dei soggetti che soddisfano i criteri di selezione  ed il particolare il valore _ni_, che può essere utilizzato nei metodi di ricerca e di inserimento di contatti e di  recapiti descritti nei paragrafi successivi, nonché le informazioni del recapito principale, residenza o sede legale, e del domicilio, o sede secondaria. 

### per denominazione
### per cognome
### per nome
### per codiceFiscale
### per codiceFiscaleEstero
### per partitaIva

## checkRecapitoContatto
Consente  di verificare se nel sistema anagrafico centralizzato per un dato soggetto esiste il contatto indicato, eventualmente associato al recapito indicato. Sono obbligatori i parametri _ni_ e _contatto_, nel caso in cui si voglia verificare anche la congruenza sulle informazioni di recapito è necessario specificare obbligatoriamente i tre parametri _indirizzo_, _comune_ e _provincia_. Il messaggio di risposta conterrà il valore OK nel caso in cui il contatto indicato sia già stato codificato per il soggetto indicato, eventualmente associato al recapito indicato, o il valore KO in caso contrario.

Input:
* ni (obbligatorio)
* indirizzo
* comune
* provincia
* contatto

Output:
* codice: 0 (found), -1 (not found), Axxxxx codice anomalia
* esito_operazione: OK, KO, Axxxxx
* id_recapito
* id_contatto 

## checkRecapito
Il metodo consente  di verificare se nel sistema anagrafico centralizzato per un dato soggetto esiste il recapito indicato, i parametri  sono tutti obbligatori. Il messaggio conterrà l’id_recapito in caso di ricerca terminata con successo (elemento codice) o la codifica fissa -1 in caso di ricerca fallita. Nel caso in cui, a fronte dei parametri utilizzati in fase di chiamata, si sia verificata un’anomalia, l’elemento codice conterrà un identificativo di errore e nell’elemento esito_operazione verrà riportato il dettaglio dello stesso.
Input:
* ni
* tipo_recapito
* indirizzo
* comune
* provincia
Output:
* codice: id_recapito, -1, Axxxx
* esito_operazione: OK, KO, Axxxx

## insRecapitoContatto


## Inserimento anagrafica Persona Fiscica

## Inserimento anagrafica Persona Giuridica

## Inserimento anagrafica Generica
_________________________________________________________________________________________

## TestCase tpkInsertAnagrafici (PERSONA FISICA)

Test di inserimento di una anagrafica i cui valori possono essere passati come properties.
```
cognome=TURRA
nome=MATTIA
sesso=M
codiceFiscale=TRRMTT71R09A941Z
luogoNascita=Bologna
comuneNascita=Bologna
provinciaNascita=BO
```

* _tpkInsertAnagrafici I_:  Inserimento della anagrafica
* _tpkInsertAnagraficiCheckDupCodFis_:  Controllo inserimento anagrafica con lo stesso codice fiscale.
* _tpkInsertRecapitoRes_:  inserimento recapito residenza
* _tpkInsertRecapitoDup_:  inserimento recapito residenza duplicato ERR
* _tpkInsertContattoResMail_: inserimento contatto tipo MAIL recapito residenza
* _tpkInsertContattoResFax_: inserimento contatto tipo FAX recapito residenza
* _tpkInsertRecapitoDom_: inserimento recapito domicilio
* _tpkInsertRecapitoDomDup_: inserimento recapito domicilio duplicato ERR
* _tpkInsertContattoDomTel_: inserimento contatto tipo TEL recapito domicilio
* _tpkInsertContattoDomMail_: inserimento contatto tipo MAIL recapito domicilio
* _tpkInsertContattoDomMailDUP-ERR_: inserimento contatto tipo MAIL recapito domicilio con errore di validità
* _tpkInsertContattoDomMailDUP-OK_: inserimento contatto tipo MAIL recapito domicilio duplicato con validità corretta
* _tpkInsertRecapitoGen_:  inserimento recapito generico
* _researchAnagrafeFinal_: Recupero finale dei dati e controllo

## tpkInsAnagraficiChecksTestCase
Test di controllo di validazione dei campi obbligatori Persona fisica
* _ValidationChecksCognome_: controllo inserimento anagrafica senza cognome
* _ValidationChecksNome_: controllo inserimento anagrafica senza nome
* _ValidationChecksCodiceFiscale_: controllo inserimento anagrafica senza codice fiscale
* _ValidationChecksTipoSoggetto_: controllo inserimento anagrafica senza tipo soggetto

## tpkInsAnagraficiChecksTestCaseGenerico (GENERICO)
Test di controllo di validazione dei campi per anagrafica "Generica" (non occorre il codice fiscale)
* _ValidationChecksCognome_: controllo inserimento anagrafica senza cognome
* _ValidationChecksNome_: controllo esito positivo per inserimento anagrafica generica senza nome.
* _ValidationChecksNoCodiceFiscale_: controllo che non sia presente il codice fiscale
* _ValidationChecksSoloProv_: controllo solo provincia di nascita
* _ValidationChecksSoloComune_: controllo solo comune di nascita
* _ValidationChecksProvComuneNoMatch_: controllo comune e provincia non corrette (es: bologna, ferrara)
* _ValidationChecksProvComuneErr_: controllo comune e provincia non presenti tra quelle codificate

## tpkInsAnagraficiChecksTestCaseGenerico (PERSONA GIURIDICA)