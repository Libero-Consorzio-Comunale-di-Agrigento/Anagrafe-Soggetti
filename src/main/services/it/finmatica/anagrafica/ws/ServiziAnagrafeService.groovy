package it.finmatica.anagrafica.ws

import groovy.util.logging.Slf4j
import it.finmatica.ad4.dizionari.Ad4Comune
import it.finmatica.ad4.dizionari.Ad4Provincia
import it.finmatica.ad4.dizionari.Ad4Stato
import it.finmatica.anagrafica.As4TpkWsService
import it.finmatica.as4.anagrafica.*
import it.finmatica.as4.anagrafica.ws.AnagrafeSoggettiWs
import it.finmatica.as4.anagrafica.ws.WsAnagrafica
import it.finmatica.as4.anagrafica.ws.WsAnagraficaDettagli
import it.finmatica.as4.anagrafica.ws.WsAnagraficaResearch
import it.finmatica.as4.anagrafica.ws.WsContatto
import it.finmatica.as4.anagrafica.ws.WsOutput
import it.finmatica.as4.anagrafica.ws.WsRecapito
import it.finmatica.as4.anagrafica.ws.WsSoggettoCorrente
import it.finmatica.as4.dizionari.As4TipoContatto
import it.finmatica.as4.dizionari.As4TipoRecapito
import it.finmatica.as4.dizionari.As4TipoSoggetto
import org.apache.commons.lang.time.DateUtils
import org.hibernate.criterion.CriteriaSpecification
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import javax.jws.WebParam
import javax.xml.bind.annotation.XmlElement

@Service
@Transactional//(propagation = Propagation.NEVER)
@Slf4j
class ServiziAnagrafeService {

    private final As4TpkWsService as4TpkWsService
    private final As4AnagraficaService as4AnagraficaService
    private final As4RecapitoService as4RecapitoService
    private final As4ContattoService as4ContattoService

    ServiziAnagrafeService(As4TpkWsService as4TpkWsService,
                           As4AnagraficaService as4AnagraficaService,
                           As4RecapitoService as4RecapitoService,
                           As4ContattoService as4ContattoService) {
        this.as4TpkWsService = as4TpkWsService
        this.as4AnagraficaService = as4AnagraficaService
        this.as4RecapitoService = as4RecapitoService
        this.as4ContattoService = as4ContattoService
    }

    WsOutput tpkInsertAnagrafe(WsAnagrafica anagrafe) {

        WsOutput output = new WsOutput()
        AnagraficaCompleta soggetto = new AnagraficaCompleta()

        soggetto.dal = anagrafe.dal
        soggetto.al = anagrafe.al
        soggetto.cognome = anagrafe.cognome
        soggetto.nome = anagrafe.nome
        soggetto.sesso = anagrafe.sesso
        soggetto.dataNascita = anagrafe.dataNascita
//        soggetto.denominazione = anagrafe.denominazione

        Ad4Comune comuneNascita
        Ad4Provincia provinciaNascita
        Ad4Stato statoNascita

        if (anagrafe.comuneNascita != null && anagrafe.provinciaNascita == null) {
            output.codice = 'A10021'
            output.esito_operazione = 'Non esiste riferimento su Comuni.'
            return output
        } else {
            if (anagrafe.provinciaNascita == null)
                provinciaNascita = null
            else {
                provinciaNascita = Ad4Provincia.findByDenominazione((anagrafe.provinciaNascita)?.toUpperCase())

                if (provinciaNascita == null) {
                    statoNascita = Ad4Stato.findByDenominazione((anagrafe.provinciaNascita)?.toUpperCase())
                    if (statoNascita == null) {
                        output.codice = 'A10091'
                        output.esito_operazione = 'Provincia non codificata'
                        return output
                    }
                }
            }
            if (anagrafe.comuneNascita == null)
                comuneNascita = null
            else if(statoNascita != null){
                comuneNascita = Ad4Comune.findByStatoAndDenominazione(statoNascita, (anagrafe.comuneNascita)?.toUpperCase())
            }else {
                comuneNascita = Ad4Comune.findByProvinciaAndDenominazione(provinciaNascita, (anagrafe.comuneNascita)?.toUpperCase())

                if (comuneNascita == null) {
                    output.codice = 'A10021'
                    output.esito_operazione = 'Non esiste riferimento su Comuni.'
                    return output
                }
            }
        }

        soggetto.comuneNascita = comuneNascita
        soggetto.provinciaNascita = provinciaNascita
        soggetto.statoNascita = statoNascita

        soggetto.luogoNascita = anagrafe.luogoNascita
        soggetto.codiceFiscale = anagrafe.codiceFiscale
        soggetto.codiceFiscaleEstero = anagrafe.codiceFiscaleEstero
        soggetto.partitaIva = anagrafe.partitaIva
        soggetto.partitaIvaCee = anagrafe.partitaIvaCee

        As4TipoSoggetto ts = As4TipoSoggetto.findByTipoSoggetto(anagrafe.tipoSoggetto)
        soggetto.tipoSoggetto = ts

        soggetto.note = anagrafe.note
        soggetto.presso = anagrafe.presso

        soggetto.indirizzoResidenza = anagrafe.indirizzoResidenza

        Ad4Comune comuneResidenza
        Ad4Provincia provinciaResidenza
        Ad4Stato statoResidenza

        if (anagrafe.comuneResidenza != null && anagrafe.provinciaResidenza == null) {
            output.codice = 'A10021'
            output.esito_operazione = 'Non esiste riferimento su Comuni.'
            return output
        } else {
            if (anagrafe.provinciaResidenza == null)
                provinciaResidenza = null
            else {
                provinciaResidenza = Ad4Provincia.findByDenominazione((anagrafe.provinciaResidenza)?.toUpperCase())

                if (provinciaResidenza == null) {
                    statoResidenza = Ad4Stato.findByDenominazione((anagrafe.provinciaResidenza)?.toUpperCase())
                    if (statoResidenza == null) {
                        output.codice = 'A10091'
                        output.esito_operazione = 'Provincia non codificata'
                        return output
                    }
                }
            }
            if (anagrafe.comuneResidenza == null)
                comuneResidenza = null
            else if(statoResidenza != null){
                comuneResidenza = Ad4Comune.findByStatoAndDenominazione(statoResidenza, (anagrafe.comuneResidenza)?.toUpperCase())
            }
            else {
                comuneResidenza = Ad4Comune.findByProvinciaAndDenominazione(provinciaResidenza, (anagrafe.comuneResidenza)?.toUpperCase())

                if (comuneResidenza == null) {
                    output.codice = 'A10021'
                    output.esito_operazione = 'Non esiste riferimento su Comuni.'
                    return output
                }
            }
        }
        soggetto.comuneResidenza = comuneResidenza
        soggetto.provinciaResidenza = provinciaResidenza
        soggetto.statoResidenza = statoResidenza
        soggetto.capResidenza = anagrafe.capResidenza

        soggetto.indirizzoWeb = anagrafe.indirizzoWeb
        soggetto.telefonoResidenza = anagrafe.telefonoResidenza
        soggetto.faxResidenza = anagrafe.faxResidenza

        soggetto.descrizioneResidenza = anagrafe.descrizioneResidenza
        soggetto.importanza = anagrafe.importanzaResidenza

        soggetto.noteMail = anagrafe.noteMail
        soggetto.importanzaMail = anagrafe.importanzaMail

        soggetto.noteTelefonoResidenza = anagrafe.noteTelefonoResidenza
        soggetto.importanzaTelefonoResidenza = anagrafe.importanzaTelefonoResidenza

        soggetto.noteFaxResidenza = anagrafe.noteFaxResidenza
        soggetto.importanzaFaxResidenza = anagrafe.importanzaFaxResidenza

        soggetto.descrizioneDomicilio = anagrafe.descrizioneDomicilio

        soggetto.indirizzoDomicilio = anagrafe.indirizzoDomicilio

        Ad4Comune comuneDomicilio
        Ad4Provincia provinciaDomicilio
        Ad4Stato statoDomicilio

        if (anagrafe.comuneDomicilio != null && anagrafe.provinciaDomicilio == null) {
            output.codice = 'A10021'
            output.esito_operazione = 'Non esiste riferimento su Comuni.'
            return output
        } else {
            if (anagrafe.provinciaDomicilio == null)
                provinciaDomicilio = null
            else {
                provinciaDomicilio = Ad4Provincia.findByDenominazione((anagrafe.provinciaDomicilio)?.toUpperCase())

                if (provinciaDomicilio == null) {
                    statoDomicilio = Ad4Stato.findByDenominazione((anagrafe.provinciaDomicilio)?.toUpperCase())
                    if (statoDomicilio == null) {
                        output.codice = 'A10091'
                        output.esito_operazione = 'Provincia non codificata'
                        return output
                    }
                }
            }
            if (anagrafe.comuneDomicilio == null)
                comuneDomicilio = null
            else if(statoDomicilio != null){
                comuneDomicilio = Ad4Comune.findByStatoAndDenominazione(statoDomicilio, (anagrafe.comuneDomicilio)?.toUpperCase())
            }
            else {
                comuneDomicilio = Ad4Comune.findByProvinciaAndDenominazione(provinciaDomicilio, (anagrafe.comuneDomicilio)?.toUpperCase())

                if (comuneDomicilio == null) {
                    output.codice = 'A10021'
                    output.esito_operazione = 'Non esiste riferimento su Comuni.'
                    return output
                }
            }
        }

        soggetto.comuneDomicilio = comuneDomicilio
        soggetto.provinciaDomicilio = provinciaDomicilio
        soggetto.statoDomicilio = statoDomicilio

        soggetto.capDomicilio = anagrafe.capDomicilio
        soggetto.telefonoDomicilio = anagrafe.telefonoDomicilio
        soggetto.faxDomicilio = anagrafe.faxDomicilio

        soggetto.noteTelefonoDomicilio = anagrafe.noteTelefonoDomicilio
        soggetto.importanzaTelefonoDomicilio = anagrafe.importanzaTelefonoDomicilio

        soggetto.noteFaxDomicilio = anagrafe.noteFaxDomicilio
        soggetto.competenza = 'WS'

//        try {
//            as4TpkWsService.pkgInsertAnagrafe(soggetto)
//            output.codice = soggetto.ni
//            output.esito_operazione = "OK"
//            return output
//        } catch (As4SqlRuntimeException e) {
//            log.info("exception " + e.getCodice() + " messaggio " + e.getMessage())
//            output.codice = e.getCodice()
//            output.esito_operazione = e.getMessage()
//            return output
//        }

        as4TpkWsService.pkgInsertAnagrafe(soggetto)
        output.codice = soggetto.ni
        output.esito_operazione = "OK"
        return output
    }

    List<WsAnagraficaResearch> researchAnagrafe(
            String denominazione,
            String cognome,
            String nome,
            String codiceFiscale,
            String codiceFiscaleEstero,
            String partitaIva,
            String partitaIvaCee) {

        List<WsAnagraficaResearch> soggettiWs = []
        AnagrafeSoggettiWs parametri = new AnagrafeSoggettiWs()
        if (!denominazione.equals("") && denominazione != null)
            parametri.denominazione = denominazione
        parametri.cognome = cognome
        if (!nome.equals("") && nome != null)
            parametri.nome = nome
        if (!codiceFiscale.equals("") && codiceFiscale != null)
            parametri.codiceFiscale = codiceFiscale
        if (!codiceFiscaleEstero.equals("") && codiceFiscaleEstero != null)
            parametri.codiceFiscaleEstero = codiceFiscaleEstero
        if (!partitaIva.equals("") && partitaIva != null)
            parametri.partitaIva = partitaIva
        if (!partitaIvaCee.equals("") && partitaIvaCee != null)
            parametri.partitaIvaCee = partitaIvaCee

        List<AnagrafeSoggettiWs> soggetti = as4TpkWsService.cercaSoggetti(parametri)
        soggetti.each { s ->
            WsAnagraficaResearch anagrafica = new WsAnagraficaResearch()

//            anagrafica.ni = s?.id
            anagrafica.ni = s?.ni
            anagrafica.dal = s?.dal
            anagrafica.al = s?.al
            anagrafica.cognome = s?.cognome
            anagrafica.nome = s?.nome
            anagrafica.sesso = s?.sesso
            anagrafica.dataNascita = s?.dataNascita
            anagrafica.comuneNascita = s?.comuneNascita?.denominazione
            anagrafica.provinciaNascita = s?.provinciaNascita?.denominazione
            anagrafica.luogoNascita = s?.luogoNascita
            anagrafica.presso = s?.presso
            anagrafica.codiceFiscale = s?.codiceFiscale
            anagrafica.codiceFiscaleEstero = s?.codiceFiscaleEstero
            anagrafica.partitaIva = s?.partitaIva
            anagrafica.partitaIvaCee = s?.partitaIvaCee
            anagrafica.tipoSoggetto = s?.tipoSoggetto?.descrizione
            anagrafica.note = s?.note
            anagrafica.indirizzoResidenza = s?.indirizzoResidenza
            anagrafica.comuneResidenza = s?.comuneResidenza
            anagrafica.provinciaResidenza = s?.provinciaResidenza
            anagrafica.capResidenza = s?.capResidenza
            anagrafica.id_recapito_residenza = s?.idRecapitoResidenza
            anagrafica.indirizzoDomicilio = s?.indirizzoDomicilio
            anagrafica.comuneDomicilio = s?.comuneDomicilio
            anagrafica.provinciaDomicilio = s?.provinciaDomicilio
            anagrafica.capDomicilio = s?.capDomicilio
            anagrafica.id_recapito_domicilio = s?.idRecapitoDomicilio

            soggettiWs.add(anagrafica)

        }
        return soggettiWs
    }

    List<WsAnagraficaDettagli> ricercaDettagliAnagrafe(
            String denominazione,
            String cognome,
            String nome,
            String codiceFiscale,
            String codiceFiscaleEstero,
            String partitaIva,
            String partitaIvaCee) {

        List<WsAnagraficaDettagli> soggettiWs = []
        AnagrafeSoggettiWs parametri = new AnagrafeSoggettiWs()
        if (!denominazione.equals("") && denominazione != null)
            parametri.denominazione = denominazione
        parametri.cognome = cognome
        if (!nome.equals("") && nome != null)
            parametri.nome = nome
        if (!codiceFiscale.equals("") && codiceFiscale != null)
            parametri.codiceFiscale = codiceFiscale
        if (!codiceFiscaleEstero.equals("") && codiceFiscaleEstero != null)
            parametri.codiceFiscaleEstero = codiceFiscaleEstero
        if (!partitaIva.equals("") && partitaIva != null)
            parametri.partitaIva = partitaIva
        if (!partitaIvaCee.equals("") && partitaIvaCee != null)
            parametri.partitaIvaCee = partitaIvaCee

        List<AnagrafeSoggettiWs> soggetti = as4TpkWsService.cercaSoggetti(parametri)
        soggetti.each { s ->
            WsAnagraficaDettagli anagrafica = new WsAnagraficaDettagli()

//            anagrafica.ni = s?.id
            anagrafica.ni = s?.ni
            anagrafica.dal = s?.dal
            anagrafica.al = s?.al
            anagrafica.cognome = s?.cognome
            anagrafica.nome = s?.nome
            anagrafica.sesso = s?.sesso
            anagrafica.dataNascita = s?.dataNascita
            anagrafica.comuneNascita = s?.comuneNascita?.denominazione
            anagrafica.provinciaNascita = s?.provinciaNascita?.denominazione
            anagrafica.luogoNascita = s?.luogoNascita
            anagrafica.presso = s?.presso
            anagrafica.codiceFiscale = s?.codiceFiscale
            anagrafica.codiceFiscaleEstero = s?.codiceFiscaleEstero
            anagrafica.partitaIva = s?.partitaIva
            anagrafica.partitaIvaCee = s?.partitaIvaCee
            anagrafica.tipoSoggetto = s?.tipoSoggetto?.descrizione
            anagrafica.note = s?.note
            anagrafica.indirizzoResidenza = s?.indirizzoResidenza
            anagrafica.comuneResidenza = s?.comuneResidenza
            anagrafica.provinciaResidenza = s?.provinciaResidenza
            anagrafica.capResidenza = s?.capResidenza
            anagrafica.id_recapito_residenza = s?.idRecapitoResidenza
            anagrafica.indirizzoDomicilio = s?.indirizzoDomicilio
            anagrafica.comuneDomicilio = s?.comuneDomicilio
            anagrafica.provinciaDomicilio = s?.provinciaDomicilio
            anagrafica.capDomicilio = s?.capDomicilio
            anagrafica.id_recapito_domicilio = s?.idRecapitoDomicilio
            anagrafica.faxDom = s?.faxDom
            anagrafica.faxRes = s?.faxRes
            anagrafica.idContattoFaxDom = s?.idContattoFaxDom
            anagrafica.idContattoFaxRes = s?.idContattoFaxRes
            anagrafica.idContattoIndirizzoWeb = s?.idContattoIndirizzoWeb
            anagrafica.idContattoTelDom = s?.idContattoTelDom
            anagrafica.idContattoTelRes = s?.idContattoTelRes
            anagrafica.indirizzoWeb = s?.indirizzoWeb
            anagrafica.telDom = s?.telDom
            anagrafica.telRes = s?.telRes

            soggettiWs.add(anagrafica)

        }
        return soggettiWs
    }

    WsOutput tpkInsertAnagrafici(WsSoggettoCorrente soggettoCorrente) {
        WsOutput output = new WsOutput()
        As4Anagrafica soggetto = new As4Anagrafica()

        soggetto.cognome = soggettoCorrente.cognome
        soggetto.nome = soggettoCorrente.nome
        soggetto.sesso = soggettoCorrente.sesso

        As4TipoSoggetto ts = As4TipoSoggetto.findByTipoSoggetto(soggettoCorrente.tipoSoggetto)

        soggetto.tipoSoggetto = ts

        soggetto.dal = soggettoCorrente.dal
        soggetto.al = soggettoCorrente.al
        soggetto.dal = soggettoCorrente.dal
        soggetto.codFiscale = soggettoCorrente.codiceFiscale
        soggetto.codFiscaleEstero = soggettoCorrente.codiceFiscaleEstero
        soggetto.partitaIva = soggettoCorrente.partitaIva
        soggetto.partitaIvaCee = soggettoCorrente.partitaIvaCee

        soggetto.dataNas = soggettoCorrente.dataNascita
        soggetto.luogoNas = soggettoCorrente.luogoNascita

        Ad4Comune comuneNascita
        Ad4Provincia provinciaNascita
        Ad4Stato statoNascita

        if (soggettoCorrente.comuneNascita != null && soggettoCorrente.provinciaNascita == null) {
            output.codice = 'A10021'
            output.esito_operazione = 'Non esiste riferimento su Comuni.'
            return output
        } else {
            if (soggettoCorrente.provinciaNascita == null)
                provinciaNascita = null
            else {
                provinciaNascita = Ad4Provincia.findByDenominazione((soggettoCorrente.provinciaNascita)?.toUpperCase())
                if (provinciaNascita == null) {
                    statoNascita = Ad4Stato.findByDenominazione((soggettoCorrente.provinciaNascita)?.toUpperCase())
                    if (statoNascita == null) {
                        output.codice = 'A10091'
                        output.esito_operazione = 'Provincia non codificata'
                        return output
                    }
                }
            }
            if (soggettoCorrente.comuneNascita == null)
                comuneNascita = null
            else {
                if (provinciaNascita == null) {
                    comuneNascita = Ad4Comune.findByProvinciaIsNullAndDenominazione(soggettoCorrente.comuneNascita?.toUpperCase())
                } else {
                    comuneNascita = Ad4Comune.findByProvinciaAndDenominazione(provinciaNascita, (soggettoCorrente.comuneNascita)?.toUpperCase())
                }
                if (comuneNascita == null) {
                    output.codice = 'A10021'
                    output.esito_operazione = 'Non esiste riferimento su Comuni.'
                    return output
                }
            }
        }
        soggetto.comuneNas = comuneNascita
        soggetto.provinciaNas = provinciaNascita
        soggetto.statoNas = statoNascita
        soggetto.competenza = 'WS'

//        try {
//            as4AnagraficaService.inserisci(soggetto)
//            output.codice = soggetto.ni
//            output.esito_operazione = "OK"
//            return output
//        } catch (As4SqlRuntimeException e) {
//            println "exception " + e.getCodice() + " messaggio " + e.getMessage()
//            output.codice = e.getCodice()
//            output.esito_operazione = e.getMessage()
//            return output
//        }

        as4AnagraficaService.inserisci(soggetto, null, null, null)
        output.codice = soggetto.ni
        output.esito_operazione = "OK"
        return output
    }

    WsOutput tpkInsertRecapito(WsRecapito recapitoWs) {

        WsOutput output = new WsOutput()
        As4Recapito recapito = new As4Recapito()

        recapito.ni = recapitoWs.ni
        recapito.dal = recapitoWs.dal
        recapito.al = recapitoWs.al
        recapito.descrizione = recapitoWs.descrizione

        As4TipoRecapito tr = As4TipoRecapito.findByDescrizione(recapitoWs.tipoRecapito)
        recapito.tipoRecapito = tr

        recapito.indirizzo = recapitoWs.indirizzo

        Ad4Comune comune
        Ad4Provincia provincia
        Ad4Stato stato

        if (recapitoWs.comune != null && recapitoWs.provincia == null) {
            output.codice = 'A10021'
            output.esito_operazione = 'Non esiste riferimento su Comuni.'
            return output
        } else {
            if (recapitoWs.provincia == null)
                provincia = null
            else {
                provincia = Ad4Provincia.findByDenominazione((recapitoWs.provincia)?.toUpperCase())

                if (provincia == null) {
                    stato = Ad4Stato.findByDenominazione((recapitoWs.provincia)?.toUpperCase())
                    if (stato == null) {
                        output.codice = 'A10091'
                        output.esito_operazione = 'Provincia non codificata'
                        return output
                    }
                }
            }
            if (recapitoWs.comune == null)
                comune = null
            else {
                comune = Ad4Comune.findByProvinciaAndDenominazione(provincia, (recapitoWs.comune)?.toUpperCase())

                if (comune == null) {
                    output.codice = 'A10021'
                    output.esito_operazione = 'Non esiste riferimento su Comuni.'
                    return output
                }
            }
        }
        recapito.provincia = provincia
        recapito.comune = comune
        recapito.stato = stato
        recapito.cap = recapitoWs.cap
        recapito.presso = recapitoWs.presso
        recapito.importanza = recapitoWs.importanza
        recapito.competenza = 'WS'

//        try {
//            as4RecapitoService.inserisci(recapito)
//            output.codice = recapito.id
//            output.esito_operazione = "OK"
//            return output
//        } catch (As4SqlRuntimeException e) {
//            println "exception " + e.getCodice() + " messaggio " + e.getMessage()
//            output.codice = e.getCodice()
//            output.esito_operazione = e.getMessage()
//            return output
//        }

        as4RecapitoService.inserisci(recapito)
        output.codice = recapito.id
        output.esito_operazione = "OK"
        return output
    }

    WsOutput tpkInsertContatto(WsContatto contattoWs) {

        As4Contatto contatto = new As4Contatto()

        contatto.id = contattoWs.idContatto

        As4TipoContatto tc = As4TipoContatto.findByDescrizione(contattoWs.tipoContatto)
        contatto.tipoContatto = tc

        As4Recapito recapito = As4Recapito.findById(contattoWs.idRecapito)
        contatto.recapito = recapito

        contatto.valore = contattoWs.valore
        contatto.note = contattoWs.note
        contatto.dal = contattoWs.dal
        contatto.al = contattoWs.al
        contatto.importanza = contattoWs.importanza
        contatto.competenza = 'WS'

        WsOutput output = new WsOutput()

//        try {
//            as4ContattoService.inserisci(contatto)
//            output.codice = contatto.id
//            output.esito_operazione = "OK"
//            return output
//        } catch (As4SqlRuntimeException e) {
//            println "exception " + e.getCodice() + " messaggio " + e.getMessage()
//            output.codice = e.getCodice()
//            output.esito_operazione = e.getMessage()
//            return output
//        }

        as4ContattoService.inserisci(contatto)
        output.codice = contatto.id
        output.esito_operazione = "OK"
        return output
    }

    WsOutput tpkUpdateRecapito(WsRecapito recapitoWs) {

        WsOutput output = new WsOutput()

        As4Recapito recapito = As4Recapito.findById(recapitoWs.idRecapito)
        if (recapito == null) {
            output.codice = 'A10055'
            output.esito_operazione = 'Riferimento recapito non trovato.'
            return output
        } else {
            recapito.descrizione = recapitoWs.descrizione
            recapito.dal = recapitoWs.dal
            recapito.al = recapitoWs.al
            recapito.descrizione = recapitoWs.descrizione
            recapito.cap = recapitoWs.cap
            recapito.presso = recapitoWs.presso

            Ad4Comune comune
            Ad4Provincia provincia
            Ad4Stato stato

            if (recapitoWs.comune != null && recapitoWs.provincia == null) {
                output.codice = 'A10021'
                output.esito_operazione = 'Non esiste riferimento su Comuni.'
                return output
            } else {
                if (recapitoWs.provincia == null)
                    provincia = null
                else {
                    provincia = Ad4Provincia.findByDenominazione((recapitoWs.provincia)?.toUpperCase())

                    if (provincia == null) {
                        stato = Ad4Stato.findByDenominazione((recapitoWs.provincia)?.toUpperCase())
                        if (stato == null) {
                            output.codice = 'A10091'
                            output.esito_operazione = 'Provincia non codificata'
                            return output
                        }
                    }
                }
                if (recapitoWs.comune == null)
                    comune = null
                else {
                    comune = Ad4Comune.findByProvinciaAndDenominazione(provincia, (recapitoWs.comune)?.toUpperCase())

                    if (comune == null) {
                        output.codice = 'A10021'
                        output.esito_operazione = 'Non esiste riferimento su Comuni.'
                        return output
                    }
                }
            }
            recapito.indirizzo = recapitoWs.indirizzo
            recapito.comune = comune
            recapito.provincia = provincia
            recapito.stato = stato
            recapito.importanza = recapitoWs.importanza

            As4TipoRecapito tr = As4TipoRecapito.findByDescrizione(recapitoWs.tipoRecapito)
            recapito.tipoRecapito = tr

            recapito.competenza = 'WS'

//            try {
//                as4RecapitoService.modifica(recapito)
//                output.codice = recapito.id
//                output.esito_operazione = "OK"
//                return output
//            } catch (As4SqlRuntimeException e) {
//                println "exception " + e.getCodice() + " messaggio " + e.getMessage()
//                output.codice = e.getCodice()
//                output.esito_operazione = e.getMessage()
//                return output
//            }

            as4RecapitoService.modifica(recapito)
            output.codice = recapito.id
            output.esito_operazione = "OK"
            return output
        }

    }

    WsOutput tpkUpdateContatto(WsContatto contattoWs) {
        WsOutput output = new WsOutput()
        As4Contatto contatto = As4Contatto.findById(contattoWs.idContatto)
        if (contatto == null) {
            output.codice = 'A10053'
            output.esito_operazione = 'Riferimento contatto non trovato.'
        } else {
            contatto.valore = contattoWs.valore
            contatto.note = contattoWs.note
            contatto.dal = contattoWs.dal
            contatto.al = contattoWs.al

            As4TipoContatto tc = As4TipoContatto.findByDescrizione(contattoWs.tipoContatto)
            contatto.tipoContatto = tc
            contatto.competenza = 'WS'

//            try {
//                as4ContattoService.modifica(contatto)
//                output.codice = contatto.id
//                output.esito_operazione = "OK"
//                return output
//            } catch (As4SqlRuntimeException e) {
//                println "exception " + e.getCodice() + " messaggio " + e.getMessage()
//                output.codice = e.getCodice()
//                output.esito_operazione = e.getMessage()
//                return output
//            }

            as4ContattoService.modifica(contatto)
            output.codice = contatto.id
            output.esito_operazione = "OK"
            return output
        }
    }

    WsOutput tpkUpdateAnagrafe(WsAnagrafica anagrafe) {
        WsOutput output = new WsOutput()
//        AnagraficaCompleta soggetto = AnagraficaCompleta.findByNi(anagrafe.ni)
        anagrafe.dal = (anagrafe.dal ? DateUtils.truncate(anagrafe.dal, Calendar.DATE) : null)
        AnagraficaCompleta soggetto = AnagraficaCompleta.findByNiAndDal(anagrafe.ni, anagrafe.dal)
        if (soggetto == null) {
            output.codice = 'A10051'
            output.esito_operazione = 'Riferimento anagrafico non trovato.'
            return output
        } else {
            soggetto.dal = anagrafe.dal
            soggetto.al = anagrafe.al
            soggetto.cognome = anagrafe.cognome
            soggetto.nome = anagrafe.nome
            soggetto.sesso = anagrafe.sesso
            soggetto.dataNascita = anagrafe.dataNascita
//            soggetto.denominazione = anagrafe.denominazione

            Ad4Comune comuneNascita
            Ad4Provincia provinciaNascita
            Ad4Stato statoNascita

            if (anagrafe.comuneNascita != null && anagrafe.provinciaNascita == null) {
                output.codice = 'A10021'
                output.esito_operazione = 'Non esiste riferimento su Comuni.'
                return output
            } else {
                if (anagrafe.provinciaNascita == null)
                    provinciaNascita = null
                else {
                    provinciaNascita = Ad4Provincia.findByDenominazione((anagrafe.provinciaNascita)?.toUpperCase())

                    if (provinciaNascita == null) {
                        statoNascita = Ad4Stato.findByDenominazione((anagrafe.provinciaNascita)?.toUpperCase())
                        if (statoNascita == null) {
                            output.codice = 'A10091'
                            output.esito_operazione = 'Provincia non codificata'
                            return output
                        }
                    }
                }
                if (anagrafe.comuneNascita == null)
                    comuneNascita = null
                else {
                    comuneNascita = Ad4Comune.findByDenominazione((anagrafe.comuneNascita)?.toUpperCase())

                    if (comuneNascita == null) {
                        output.codice = 'A10021'
                        output.esito_operazione = 'Non esiste riferimento su Comuni.'
                        return output
                    }
                }
            }

            soggetto.comuneNascita = comuneNascita
            soggetto.provinciaNascita = provinciaNascita
            soggetto.statoNascita = statoNascita
            soggetto.luogoNascita = anagrafe.luogoNascita
            soggetto.codiceFiscale = anagrafe.codiceFiscale
            soggetto.codiceFiscaleEstero = anagrafe.codiceFiscaleEstero
            soggetto.partitaIva = anagrafe.partitaIva
            soggetto.partitaIvaCee = anagrafe.partitaIvaCee

            As4TipoSoggetto ts = As4TipoSoggetto.findByTipoSoggetto(anagrafe.tipoSoggetto)
            soggetto.tipoSoggetto = ts

            soggetto.note = anagrafe.note
            soggetto.presso = anagrafe.presso

            soggetto.indirizzoResidenza = anagrafe.indirizzoResidenza

            Ad4Comune comuneResidenza
            Ad4Provincia provinciaResidenza
            Ad4Stato statoResidenza

            if (anagrafe.comuneResidenza != null && anagrafe.provinciaResidenza == null) {
                output.codice = 'A10021'
                output.esito_operazione = 'Non esiste riferimento su Comuni.'
                return output
            } else {
                if (anagrafe.provinciaResidenza == null)
                    provinciaResidenza = null
                else {
                    provinciaResidenza = Ad4Provincia.findByDenominazione((anagrafe.provinciaResidenza)?.toUpperCase())

                    if (provinciaResidenza == null) {
                        statoResidenza = Ad4Stato.findByDenominazione((anagrafe.provinciaResidenza)?.toUpperCase())
                        if (statoResidenza == null) {
                            output.codice = 'A10091'
                            output.esito_operazione = 'Provincia non codificata'
                            return output
                        }
                    }
                }
                if (anagrafe.comuneResidenza == null)
                    comuneResidenza = null
                else {
                    comuneResidenza = Ad4Comune.findByDenominazione((anagrafe.comuneResidenza)?.toUpperCase())

                    if (comuneResidenza == null) {
                        output.codice = 'A10021'
                        output.esito_operazione = 'Non esiste riferimento su Comuni.'
                        return output
                    }
                }
            }

            soggetto.comuneResidenza = comuneResidenza
            soggetto.provinciaResidenza = provinciaResidenza
            soggetto.statoResidenza = statoResidenza

            soggetto.capResidenza = anagrafe.capResidenza

            soggetto.indirizzoWeb = anagrafe.indirizzoWeb
            soggetto.telefonoResidenza = anagrafe.telefonoResidenza
            soggetto.faxResidenza = anagrafe.faxResidenza

            soggetto.descrizioneResidenza = anagrafe.descrizioneResidenza
            soggetto.importanza = anagrafe.importanzaResidenza

            soggetto.noteMail = anagrafe.noteMail
            soggetto.importanzaMail = anagrafe.importanzaMail

            soggetto.noteTelefonoResidenza = anagrafe.noteTelefonoResidenza
            soggetto.importanzaTelefonoResidenza = anagrafe.importanzaTelefonoResidenza

            soggetto.noteFaxResidenza = anagrafe.noteFaxResidenza
            soggetto.importanzaFaxResidenza = anagrafe.importanzaFaxResidenza

            soggetto.descrizioneDomicilio = anagrafe.descrizioneDomicilio

            soggetto.indirizzoDomicilio = anagrafe.indirizzoDomicilio

            Ad4Comune comuneDomicilio
            Ad4Provincia provinciaDomicilio
            Ad4Stato statoDomicilio

            if (anagrafe.comuneDomicilio != null && anagrafe.provinciaDomicilio == null) {
                output.codice = 'A10021'
                output.esito_operazione = 'Non esiste riferimento su Comuni.'
                return output
            } else {
                if (anagrafe.provinciaDomicilio == null)
                    provinciaDomicilio = null
                else {
                    provinciaDomicilio = Ad4Provincia.findByDenominazione((anagrafe.provinciaDomicilio)?.toUpperCase())

                    if (provinciaDomicilio == null) {
                        statoDomicilio = Ad4Stato.findByDenominazione((anagrafe.provinciaDomicilio)?.toUpperCase())
                        if (statoDomicilio == null) {
                            output.codice = 'A10091'
                            output.esito_operazione = 'Provincia non codificata'
                            return output
                        }
                    }
                }
                if (anagrafe.comuneDomicilio == null) {
                    comuneDomicilio = null
                } else {
                    comuneDomicilio = Ad4Comune.findByAndDenominazione((anagrafe.comuneDomicilio)?.toUpperCase())
                    if (comuneDomicilio == null) {
                        output.codice = 'A10021'
                        output.esito_operazione = 'Non esiste riferimento su Comuni.'
                        return output
                    }
                }
            }

            soggetto.comuneDomicilio = comuneDomicilio
            soggetto.provinciaDomicilio = provinciaDomicilio
            soggetto.statoDomicilio = statoDomicilio

            soggetto.capDomicilio = anagrafe.capDomicilio
            soggetto.telefonoDomicilio = anagrafe.telefonoDomicilio
            soggetto.faxDomicilio = anagrafe.faxDomicilio

            soggetto.noteTelefonoDomicilio = anagrafe.noteTelefonoDomicilio
            soggetto.importanzaTelefonoDomicilio = anagrafe.importanzaTelefonoDomicilio

            soggetto.noteFaxDomicilio = anagrafe.noteFaxDomicilio
            soggetto.competenza = 'WS'

//            try {
//                as4TpkWsService.pkgUpdateAnagrafe(soggetto)
////                output.codice = soggetto.id
//                output.codice = soggetto.ni
//                output.esito_operazione = "OK"
//                return output
//            } catch (As4SqlRuntimeException e) {
//                println "exception " + e.getCodice() + " messaggio " + e.getMessage()
//                output.codice = e.getCodice()
//                output.esito_operazione = e.getMessage()
//                return output
//            }

            as4TpkWsService.pkgUpdateAnagrafe(soggetto)
//                output.codice = soggetto.id
            output.codice = soggetto.ni
            output.esito_operazione = "OK"
            return output
        }
    }

    WsOutput checkRecapitoContatto(
            Long ni,
            String indirizzo,
            String comune,
            String provincia,
            String contatto) {

        WsOutput output = new WsOutput()

        Ad4Comune c
        Ad4Provincia p
        Ad4Stato s

        if (comune != null && provincia == null) {
            output.codice = 'A10021'
            output.esito_operazione = 'Non esiste riferimento su Comuni.'
            return output
        } else {
            if (provincia == null)
                p = null
            else {
                p = Ad4Provincia.findByDenominazione((provincia)?.toUpperCase())

                if (p == null) {
                    s = Ad4Stato.findByDenominazione((provincia)?.toUpperCase())
                    if (s == null) {
                        output.codice = 'A10091'
                        output.esito_operazione = 'Provincia non codificata'
                        return output
                    }
                }
            }
            if (comune == null)
                c = null
            else {
                c = Ad4Comune.findByProvinciaAndDenominazione(p, (comune)?.toUpperCase())

                if (c == null) {
                    output.codice = 'A10021'
                    output.esito_operazione = 'Non esiste riferimento su Comuni.'
                    return output
                }
            }
        }
        def result = as4ContattoService.verificaRecapitoContatto(ni, indirizzo, c, p, s, contatto)

        if (result.codice instanceof String) {
            if ((result.codice).contains('A')) {
                output.codice = result.codice
                output.esito_operazione = result.messaggio
            }
        } else {
            if (result.codice == 0) {
                output.codice = result.codice
                output.idRecapito = result.recapito
                output.idContatto = result.idContatto
                output.esito_operazione = 'OK'
            } else {
                output.codice = result.codice
                output.idRecapito = result.recapito
                output.idContatto = result.idContatto
                output.esito_operazione = 'KO'
            }
        }
        return output
    }

    WsOutput insRecapitoContatto(
            Long ni,
            String indirizzo,
            String comune,
            String provincia,
            String tipoContatto,
            String contatto) {

        WsOutput output = new WsOutput()

        Ad4Comune c
        Ad4Provincia p

        if (comune != null && provincia == null) {
            output.codice = 'A10021'
            output.esito_operazione = 'Non esiste riferimento su Comuni.'
            return output
        } else {
            if (provincia == null)
                p = null
            else {
                p = Ad4Provincia.findByDenominazione((provincia)?.toUpperCase())

                if (p == null) {
                    output.codice = 'A10091'
                    output.esito_operazione = 'Provincia non codificata'
                    return output
                }
            }
            if (comune == null)
                c = null
            else {
                c = Ad4Comune.findByProvinciaAndDenominazione(p, (comune)?.toUpperCase())

                if (c == null) {
                    output.codice = 'A10021'
                    output.esito_operazione = 'Non esiste riferimento su Comuni.'
                    return output
                }
            }
        }

        Map result = as4RecapitoService.inserisciRecapitoSuContatto(ni, indirizzo, c, p, tipoContatto, contatto)

        if (result.codice instanceof String) {
            if ((result.codice).contains('A')) {
                output.codice = result.codice
                output.esito_operazione = result.messaggio
            }
        } else {
            output.codice = result.codice
            output.idRecapito = result.idRecapito
            output.idContatto = result.idContatto
            output.esito_operazione = 'OK'
        }

        return output
    }

    WsOutput checkRecapito(
            Long ni,
            String tipoRecapito,
            String indirizzo,
            String comune,
            String provincia) {

        WsOutput output = new WsOutput()

        Ad4Comune c
        Ad4Provincia p
        Ad4Stato s

        if (comune != null && provincia == null) {
            output.codice = 'A10021'
            output.esito_operazione = 'Non esiste riferimento su Comuni.'
            return output
        } else {
            if (provincia == null)
                p = null
            else {
                p = Ad4Provincia.findByDenominazione((provincia)?.toUpperCase())

                if (p == null) {
                    s = Ad4Stato.findByDenominazione((provincia)?.toUpperCase())
                    if (s == null) {
                        output.codice = 'A10091'
                        output.esito_operazione = 'Provincia non codificata'
                        return output
                    }
                }
            }
            if (comune == null)
                c = null
            else {
                c = Ad4Comune.findByProvinciaAndDenominazione(p, (comune)?.toUpperCase())

                if (c == null) {
                    output.codice = 'A10021'
                    output.esito_operazione = 'Non esiste riferimento su Comuni.'
                    return output
                }
            }
        }

        def result = as4RecapitoService.checkRecapito(ni, tipoRecapito, indirizzo, c, p, s)
        // FIXME:
        if (result.codice instanceof String) {
            if ((result.codice).contains('A')) {
                output.codice = result.codice
                output.esito_operazione = result.messaggio
            }
        } else {
            if (result.codice == -1) {
                output.codice = result.codice
                output.esito_operazione = 'KO'
            } else {
                output.codice = result.codice
                output.esito_operazione = 'OK'
            }
        }

        return output
    }

    WsOutput updRecapito(
            @WebParam(name = "recapito") @XmlElement(required = false) Long idRecapito,
            @WebParam(name = "ni") @XmlElement(required = false) Long ni,
            @WebParam(name = "tipoRecapito") @XmlElement(required = false) String tipoRecapito,
            @WebParam(name = "dal") @XmlElement(required = true) Date dal,
            @WebParam(name = "al") @XmlElement(required = false) Date al,
            @WebParam(name = "descrizione") @XmlElement(required = false) String descrizione,
            @WebParam(name = "indirizzo") @XmlElement(required = false) String indirizzo,
            @WebParam(name = "provincia") @XmlElement(required = false) String provincia,
            @WebParam(name = "comune") @XmlElement(required = false) String comune,
            @WebParam(name = "cap") @XmlElement(required = false) String cap,
            @WebParam(name = "presso") @XmlElement(required = false) String presso,
            @WebParam(name = "importanza") @XmlElement(required = false) Long importanza) {

        WsOutput output = new WsOutput()
        Ad4Comune c
        Ad4Provincia p
        Ad4Stato s

        if (comune != null && provincia == null) {
            output.codice = 'A10021'
            output.esito_operazione = 'Non esiste riferimento su Comuni.'
            return output
        } else {
            if (provincia == null)
                p = null
            else {
                p = Ad4Provincia.findByDenominazione((provincia)?.toUpperCase())

                if (p == null) {
                    s = Ad4Stato.findByDenominazione((provincia)?.toUpperCase())
                    if (s == null) {
                        output.codice = 'A10091'
                        output.esito_operazione = 'Provincia non codificata'
                        return output
                    }
                }
            }
            if (comune == null)
                c = null
            else {
                c = Ad4Comune.findByProvinciaAndDenominazione(p, (comune)?.toUpperCase())

                if (c == null) {
                    output.codice = 'A10021'
                    output.esito_operazione = 'Non esiste riferimento su Comuni.'
                    return output
                }
            }
        }
        As4TipoRecapito tr = As4TipoRecapito.findByDescrizione(tipoRecapito)
        As4Recapito recapito = As4Recapito.findById(idRecapito)
        recapito.competenza = 'WS'

//        try {
//            as4RecapitoService.modificaConParametri(recapito, ni, tr.id, dal, al, descrizione, indirizzo, p, c, s, cap, presso, importanza)
//            output.codice = recapito.id
//            output.esito_operazione = "OK"
//            return output
//        } catch (As4SqlRuntimeException e) {
//            println "exception " + e.getCodice() + " messaggio " + e.getMessage()
//            output.codice = e.getCodice()
//            output.esito_operazione = e.getMessage()
//            return output
//        }

        as4RecapitoService.modificaConParametri(recapito, ni, tr.id, dal, al, descrizione, indirizzo, p, c, s, cap, presso, importanza)
        output.codice = recapito.id
        output.esito_operazione = "OK"
        return output
    }

    WsOutput updContatto(
            Long idContatto,
            Long ni,
            String tipoRecapito,
            String tipoContatto,
            Date dal,
            Date al,
            String valore,
            String note) {

        As4TipoRecapito tr = As4TipoRecapito.findByDescrizione(tipoRecapito)
        As4TipoContatto tc = As4TipoContatto.findByDescrizione(tipoContatto)

        As4Contatto contatto = As4Contatto.findById(idContatto)
        contatto.competenza = 'WS'

        WsOutput output = new WsOutput()
//        try {
//            as4ContattoService.modificaConParametri(contatto, ni, tr.id, tc.id, dal, al, valore, note)
//            output.codice = contatto.id
//            output.esito_operazione = "OK"
//            return output
//        } catch (As4SqlRuntimeException e) {
//            println "exception " + e.getCodice() + " messaggio " + e.getMessage()
//            output.codice = e.getCodice()
//            output.esito_operazione = e.getMessage()
//            return output
//        }

        as4ContattoService.modificaConParametri(contatto, ni, tr.id, tc.id, dal, al, valore, note)
        output.codice = contatto.id
        output.esito_operazione = "OK"
        return output
    }


    List<As4Contatto> getContatti(Long idRecapito, Long idContatto, Long idTipoContatto, String descTipoContatto){

        Date oggi = DateUtils.truncate(new Date(), Calendar.DATE)
        As4Recapito recapito = As4Recapito.findById(idRecapito)
        As4TipoContatto tipoContatto, tipoContattoSearch

        if (idTipoContatto && descTipoContatto){
            tipoContatto = As4TipoContatto.findByIdAndDescrizione(idTipoContatto, descTipoContatto.toUpperCase())
            tipoContattoSearch = tipoContatto?tipoContatto:setErrTipoContatto()
        }
        else if (idTipoContatto != null){
            tipoContatto = As4TipoContatto.findById(idTipoContatto)
            tipoContattoSearch = tipoContatto?tipoContatto:setErrTipoContatto()
        }
        else if (descTipoContatto){
            tipoContatto = As4TipoContatto.findByDescrizione(descTipoContatto.toUpperCase())
            tipoContattoSearch = tipoContatto?tipoContatto:setErrTipoContatto()
        }

        return As4Contatto.createCriteria().list() {
            createAlias("tipoContatto", "tc", CriteriaSpecification.LEFT_JOIN)
            createAlias("recapito", "r", CriteriaSpecification.LEFT_JOIN)
            eq("recapito", recapito)

            or{
                isNull("al")
                and{
                    le("dal",oggi)
                    ge("al", oggi)
                }
            }
            if (idContatto) {
                eq("id", idContatto)
            }
            if(tipoContattoSearch){
                eq("tipoContatto", tipoContattoSearch)
            }
        }

    }

    As4TipoContatto setErrTipoContatto(){
        As4TipoContatto tc = new As4TipoContatto()
        tc.id = -1
        return tc
    }

    List<As4Recapito> getRecapiti(Long ni, Long idRecapito, Long idTipoRecapito, String descTipoRecapito){

        As4TipoRecapito tipoRecapito, tipoRecapitoSearch
        Date oggi = DateUtils.truncate(new Date(), Calendar.DATE)
        if (idTipoRecapito && descTipoRecapito){
            tipoRecapito = As4TipoRecapito.findByIdAndDescrizione(idTipoRecapito, descTipoRecapito.toUpperCase())
            tipoRecapitoSearch = tipoRecapito?tipoRecapito:setErrTipoRecapito()
        }
        else if (idTipoRecapito != null){
            tipoRecapito = As4TipoRecapito.findById(idTipoRecapito)
            tipoRecapitoSearch = tipoRecapito?tipoRecapito:setErrTipoRecapito()
        }
        else if (descTipoRecapito){
            tipoRecapito = As4TipoRecapito.findByDescrizione(descTipoRecapito.toUpperCase())
            tipoRecapitoSearch = tipoRecapito?tipoRecapito:setErrTipoRecapito()
        }

        return As4Recapito.createCriteria().list() {
            createAlias("tipoRecapito", "tp", CriteriaSpecification.LEFT_JOIN)
            createAlias("provincia", "p", CriteriaSpecification.LEFT_JOIN)
            createAlias("comune", "c", CriteriaSpecification.LEFT_JOIN)
            eq("ni", ni)
            or{
                isNull("al")
                and{
                    le("dal",oggi)
                    ge("al", oggi)
                }
            }

            if (idRecapito) {
                eq("id", idRecapito)
            }
            if(tipoRecapitoSearch){
                eq("tipoRecapito", tipoRecapitoSearch)
            }
        }

    }

    As4TipoRecapito setErrTipoRecapito(){
        As4TipoRecapito tr = new As4TipoRecapito()
        tr.id = -1
        return tr
    }
}
