# Anagrafe-Soggetti
AS4 - Anagrafe soggetti
 
## Descrizione
Prodotto atto al censimento dei soggetti fisici e giuridici.

## Struttura del Repository

Il repository è suddiviso nelle seguente cartelle:
- __source__ contiene il codice sorgente e le risorse statiche incluse nella webapp.
- __scriptDB__ contiene gli script PL/SQL per la creazione della struttura dello schema database.

## Prerequisiti e dipendenze

### Prerequisiti
- Java JDK versione 7 o superiore
- Database Oracle versione 10 o superiore
- Apache Tomcat 7.0 dalla minor 47 alla 109 o 9.0

### Dipendenze
- Libreria Apache CXF per la creazione di servizi SOAP e relative API
- Log4j di Apache Software Foundation per il loggin
- Hibernate 5 piattaforma middleware open source che fornisce un servizio di Object-relational mapping (ORM)
- Springboot 1.5 framework open source per webapp Java
- ZK 6.5 framework per frontend web
- Libreria _ojdbc.jar_ driver oracle per Java di Oracle

## Istruzioni per l’installazione:
- Lanciare gli script della cartella _scriptDB/Schema_ per generare lo schema
- Lanciare gli script della cartella _scriptDB/Data_ per inserire i dati basilari
- Compilare il contenuto di _source/src_
- Copiare i file .class ottenuti sotto _source/war/WEB-INF/classes_
- Creare un archivio in formato .war con il contenuto di _source/war/_ e copiare il file nel contesto di tomcat

## Stato del progetto 
Stabile

## Amministrazione committente
Libero Consorzio Comunale di Agrigento

## Incaricati del mantenimento del progetto open source
Finmatica S.p.A. 
Via della Liberazione, 15
40128 Bologna

## Indirizzo e-mail a cui inviare segnalazioni di sicurezza 
sicurezza@ads.it
