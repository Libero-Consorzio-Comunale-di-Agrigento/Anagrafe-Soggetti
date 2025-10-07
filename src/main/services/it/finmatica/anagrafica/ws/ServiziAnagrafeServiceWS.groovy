package it.finmatica.anagrafica.ws

import groovy.util.logging.Slf4j
import it.finmatica.as4.anagrafica.*
import it.finmatica.as4.anagrafica.ws.WsAnagrafica
import it.finmatica.as4.anagrafica.ws.WsAnagraficaDettagli
import it.finmatica.as4.anagrafica.ws.WsAnagraficaResearch
import it.finmatica.as4.anagrafica.ws.WsContatto
import it.finmatica.as4.anagrafica.ws.WsOutput
import it.finmatica.as4.anagrafica.ws.WsRecapito
import it.finmatica.as4.anagrafica.ws.WsSoggettoCorrente
import it.finmatica.as4.anagrafica.ws.WsAnagrafica
import it.finmatica.as4.anagrafica.ws.WsAnagraficaDettagli
import it.finmatica.as4.anagrafica.ws.WsAnagraficaResearch
import it.finmatica.as4.anagrafica.ws.WsContatto
import it.finmatica.as4.anagrafica.ws.WsOutput
import it.finmatica.as4.anagrafica.ws.WsRecapito
import it.finmatica.as4.anagrafica.ws.WsSoggettoCorrente
import it.finmatica.as4.exceptions.As4SqlRuntimeException

import javax.jws.WebMethod
import javax.jws.WebParam
import javax.jws.WebResult
import javax.jws.WebService
import javax.xml.bind.annotation.XmlElement
import javax.xml.ws.BindingType
import javax.xml.ws.soap.SOAPBinding

@Slf4j
@WebService(name = "ServiziAnagrafeService", targetNamespace = "it.finmatica.as4.ws", serviceName = "ServiziAnagrafeService")
@BindingType(SOAPBinding.SOAP12HTTP_BINDING)
class ServiziAnagrafeServiceWS {

    private final ServiziAnagrafeService serviziAnagrafeService

    ServiziAnagrafeServiceWS(ServiziAnagrafeService serviziAnagrafeService) {
        this.serviziAnagrafeService = serviziAnagrafeService
    }

    @WebResult(name = "tpkInsertAnagrafeResult")
    @WebMethod(operationName = "tpkInsertAnagrafe")
    WsOutput tpkInsertAnagrafe(@WebParam(name = "anagrafe") @XmlElement(required = true) WsAnagrafica anagrafe) {
//        return serviziAnagrafeService.tpkInsertAnagrafe(anagrafe)
        WsOutput output = new WsOutput()
        try{
            output = serviziAnagrafeService.tpkInsertAnagrafe(anagrafe)
            return output
        } catch (As4SqlRuntimeException runtimeEx){
            output.codice = runtimeEx.getCodice()
            output.esito_operazione = runtimeEx.getMessage()
            return output
        }
    }

    @WebResult(name = "researchAnagrafeResult")
    @WebMethod(operationName = "researchAnagrafe")
    List<WsAnagraficaResearch> researchAnagrafe(
            @WebParam(name = "denominazione") @XmlElement(required = false) String denominazione,
            @WebParam(name = "cognome") @XmlElement(required = false) String cognome,
            @WebParam(name = "nome") @XmlElement(required = false) String nome,
            @WebParam(name = "codiceFiscale") @XmlElement(required = false) String codiceFiscale,
            @WebParam(name = "codiceFiscaleEstero") @XmlElement(required = false) String codiceFiscaleEstero,
            @WebParam(name = "partitaIva") @XmlElement(required = false) String partitaIva,
            @WebParam(name = "partitaIvaCee") @XmlElement(required = false) String partitaIvaCee) {
        return serviziAnagrafeService.researchAnagrafe(denominazione, cognome, nome, codiceFiscale, codiceFiscaleEstero, partitaIva, partitaIvaCee)
    }

    @WebResult(name = "ricercaDettagliAnagrafeResult")
    @WebMethod(operationName = "ricercaDettagliAnagrafe")
    List<WsAnagraficaDettagli> ricercaDettagliAnagrafe(
            @WebParam(name = "denominazione") @XmlElement(required = false) String denominazione,
            @WebParam(name = "cognome") @XmlElement(required = false) String cognome,
            @WebParam(name = "nome") @XmlElement(required = false) String nome,
            @WebParam(name = "codiceFiscale") @XmlElement(required = false) String codiceFiscale,
            @WebParam(name = "codiceFiscaleEstero") @XmlElement(required = false) String codiceFiscaleEstero,
            @WebParam(name = "partitaIva") @XmlElement(required = false) String partitaIva,
            @WebParam(name = "partitaIvaCee") @XmlElement(required = false) String partitaIvaCee) {
        return serviziAnagrafeService.ricercaDettagliAnagrafe(denominazione, cognome, nome, codiceFiscale, codiceFiscaleEstero, partitaIva, partitaIvaCee)
    }

    @WebResult(name = "getRecapitiResult")
    @WebMethod(operationName = "getRecapiti")
    List<WsRecapito> getRecapiti(
            @WebParam(name = "ni") @XmlElement(required = true) Long ni,
            @WebParam(name = "idRecapito") @XmlElement(required = false) Long idRecapito,
            @WebParam(name = "idTipoRecapito") @XmlElement(required = false) Long idTipoRecapito,
            @WebParam(name = "tipoRecapito") @XmlElement(required = false) String tipoRecapito) {

        List<As4Recapito> list = serviziAnagrafeService.getRecapiti(ni, idRecapito, idTipoRecapito, tipoRecapito)
        List<WsRecapito> wsListaRecapiti = []

        list.each { recapito->
            WsRecapito wsRecapito = new WsRecapito()
            wsRecapito.idRecapito = recapito.id
            wsRecapito.tipoRecapito = recapito?.tipoRecapito?.descrizione
            wsRecapito.dal = recapito.dal
            wsRecapito.al = recapito.al
            wsRecapito.descrizione = recapito.descrizione
            wsRecapito.indirizzo = recapito.indirizzo
            wsRecapito.provincia = recapito?.provincia?.denominazione
            wsRecapito.comune = recapito?.comune?.denominazione
            wsRecapito.cap = recapito.cap
            wsRecapito.presso = recapito.presso
            wsRecapito.importanza = recapito.importanza

            wsListaRecapiti.add(wsRecapito)
        }

        return wsListaRecapiti
    }

    @WebResult(name = "getContattiResult")
    @WebMethod(operationName = "getContatti")
    List<WsContatto> getContatti(
            @WebParam(name = "idRecapito") @XmlElement(required = true) Long idRecapito,
            @WebParam(name = "idContatto") @XmlElement(required = false) Long idContatto,
            @WebParam(name = "idTipoContatto") @XmlElement(required = false) Long idTipoContatto,
            @WebParam(name = "tipoContatto") @XmlElement(required = false) String tipoContatto) {

        List<As4Contatto> list = serviziAnagrafeService.getContatti(idRecapito, idContatto, idTipoContatto, tipoContatto)
        List<WsContatto> wsListaContatti = []

        list.each { contatto->
            WsContatto wsContatto = new WsContatto()
            wsContatto.idContatto = contatto.id
            wsContatto.idRecapito = contatto?.recapito?.id
            wsContatto.tipoContatto = contatto?.tipoContatto?.descrizione
            wsContatto.dal = contatto.dal
            wsContatto.al = contatto.al
            wsContatto.valore = contatto.valore
            wsContatto.note = contatto.note
            wsContatto.importanza = contatto.importanza

            wsListaContatti.add(wsContatto)
        }

        return wsListaContatti
    }

    @WebResult(name = "tpkInsertAnagraficiResult")
    @WebMethod(operationName = "tpkInsertAnagrafici")
    WsOutput tpkInsertAnagrafici(@WebParam(name = "soggettoCorrente") @XmlElement(required = true) WsSoggettoCorrente soggettoCorrente) {
//        return serviziAnagrafeService.tpkInsertAnagrafici(soggettoCorrente)
        WsOutput output = new WsOutput()
        try {
            output = serviziAnagrafeService.tpkInsertAnagrafici(soggettoCorrente)
            return output
        } catch (As4SqlRuntimeException runtimeEx){
            output.codice = runtimeEx.getCodice()
            output.esito_operazione = runtimeEx.getMessage()
            return output
        }

    }

    @WebResult(name = "tpkInsertRecapitoResult")
    @WebMethod(operationName = "tpkInsertRecapito")
    WsOutput tpkInsertRecapito(@WebParam(name = "recapito") @XmlElement(required = true) WsRecapito recapitoWs) {
//        return serviziAnagrafeService.tpkInsertRecapito(recapitoWs)
        WsOutput output = new WsOutput()
        try{
            output = serviziAnagrafeService.tpkInsertRecapito(recapitoWs)
            return output
        } catch (As4SqlRuntimeException runtimeEx){
            output.codice = runtimeEx.getCodice()
            output.esito_operazione = runtimeEx.getMessage()
            return output
        }
    }

    @WebResult(name = "tpkInsertContattoResult")
    @WebMethod(operationName = "tpkInsertContatto")
    WsOutput tpkInsertContatto(@WebParam(name = "contatto") @XmlElement(required = true) WsContatto contattoWs) {
//        return serviziAnagrafeService.tpkInsertContatto(contattoWs)
        WsOutput output = new WsOutput()
        try{
            output = serviziAnagrafeService.tpkInsertContatto(contattoWs)
            return output
        } catch (As4SqlRuntimeException runtimeEx){
            output.codice = runtimeEx.getCodice()
            output.esito_operazione = runtimeEx.getMessage()
            return output
        }
    }

    @WebResult(name = "tpkUpdateRecapitoResult")
    @WebMethod(operationName = "tpkUpdateRecapito")
    WsOutput tpkUpdateRecapito(@WebParam(name = "recapitoUpd") @XmlElement(required = true) WsRecapito recapitoWs) {
//        return serviziAnagrafeService.tpkUpdateRecapito(recapitoWs)
    WsOutput output = new WsOutput()
    try{
        output = serviziAnagrafeService.tpkUpdateRecapito(recapitoWs)
        return output
    } catch (As4SqlRuntimeException runtimeEx){
        output.codice = runtimeEx.getCodice()
        output.esito_operazione = runtimeEx.getMessage()
        return output
    }
}

    @WebResult(name = "tpkUpdateContattoResult")
    @WebMethod(operationName = "tpkUpdateContatto")
    WsOutput tpkUpdateContatto(@WebParam(name = "contattoUpd") @XmlElement(required = true) WsContatto contattoWs) {
//        return serviziAnagrafeService.tpkUpdateContatto(contattoWs)
        WsOutput output = new WsOutput()
        try{
            output = serviziAnagrafeService.tpkUpdateContatto(contattoWs)
            return output
        } catch (As4SqlRuntimeException runtimeEx){
            output.codice = runtimeEx.getCodice()
            output.esito_operazione = runtimeEx.getMessage()
            return output
        }
    }

    @WebResult(name = "tpkUpdateAnagrafeResult")
    @WebMethod(operationName = "tpkUpdateAnagrafe")
    WsOutput tpkUpdateAnagrafe(@WebParam(name = "anagrafe") @XmlElement(required = true) WsAnagrafica anagrafe) {
//        return serviziAnagrafeService.tpkUpdateAnagrafe(anagrafe)
        WsOutput output = new WsOutput()
        try{
            output = serviziAnagrafeService.tpkUpdateAnagrafe(anagrafe)
            return output
        } catch (As4SqlRuntimeException runtimeEx){
            output.codice = runtimeEx.getCodice()
            output.esito_operazione = runtimeEx.getMessage()
            return output
        }
    }

    @WebResult(name = "checkRecapitoContattoResult")
    @WebMethod(operationName = "checkRecapitoContatto")
    WsOutput checkRecapitoContatto(
            @WebParam(name = "ni") @XmlElement(required = true) Long ni,
            @WebParam(name = "indirizzo") @XmlElement(required = false) String indirizzo,
            @WebParam(name = "comune") @XmlElement(required = false) String comune,
            @WebParam(name = "provincia") @XmlElement(required = false) String provincia,
            @WebParam(name = "contatto") @XmlElement(required = true) String contatto) {
//        return serviziAnagrafeService.checkRecapitoContatto(ni, indirizzo, comune, provincia, contatto)
        WsOutput output = new WsOutput()
        try{
            output = serviziAnagrafeService.checkRecapitoContatto(ni, indirizzo, comune, provincia, contatto)
            return output
        } catch (As4SqlRuntimeException runtimeEx){
            output.codice = runtimeEx.getCodice()
            output.esito_operazione = runtimeEx.getMessage()
            return output
        }
    }

    @WebResult(name = "insRecapitoContattoResult")
    @WebMethod(operationName = "insRecapitoContatto")
    WsOutput insRecapitoContatto(
            @WebParam(name = "ni") @XmlElement(required = true) Long ni,
            @WebParam(name = "indirizzo") @XmlElement(required = false) String indirizzo,
            @WebParam(name = "comune") @XmlElement(required = false) String comune,
            @WebParam(name = "provincia") @XmlElement(required = false) String provincia,
            @WebParam(name = "tipo_contatto") @XmlElement(required = true) String tipoContatto,
            @WebParam(name = "contatto") @XmlElement(required = true) String contatto) {
//        return serviziAnagrafeService.insRecapitoContatto(ni, indirizzo, comune, provincia, tipoContatto, contatto)
        WsOutput output = new WsOutput()
        try{
            output = serviziAnagrafeService.insRecapitoContatto(ni, indirizzo, comune, provincia, tipoContatto, contatto)
            return output
        } catch (As4SqlRuntimeException runtimeEx){
            output.codice = runtimeEx.getCodice()
            output.esito_operazione = runtimeEx.getMessage()
            return output
        }
    }

    @WebResult(name = "checkRecapitoResult")
    @WebMethod(operationName = "checkRecapito")
    WsOutput checkRecapito(
            @WebParam(name = "ni") @XmlElement(required = true) Long ni,
            @WebParam(name = "tipoRecapito") @XmlElement(required = true) String tipoRecapito,
            @WebParam(name = "indirizzo") @XmlElement(required = true) String indirizzo,
            @WebParam(name = "comune") @XmlElement(required = true) String comune,
            @WebParam(name = "provincia") @XmlElement(required = true) String provincia) {
//        return serviziAnagrafeService.checkRecapito(ni, tipoRecapito, indirizzo, comune, provincia)
        WsOutput output = new WsOutput()
        try{
            output = serviziAnagrafeService.checkRecapito(ni, tipoRecapito, indirizzo, comune, provincia)
            return output
        } catch (As4SqlRuntimeException runtimeEx){
            output.codice = runtimeEx.getCodice()
            output.esito_operazione = runtimeEx.getMessage()
            return output
        }
    }

    @WebResult(name = "updRecapitoResult")
    @WebMethod(operationName = "updRecapito")
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
//        return serviziAnagrafeService.updRecapito(idRecapito, ni, tipoRecapito, dal, al, descrizione, indirizzo, provincia, comune, cap, presso, importanza)
        WsOutput output = new WsOutput()
        try{
            output = serviziAnagrafeService.updRecapito(idRecapito, ni, tipoRecapito, dal, al, descrizione, indirizzo, provincia, comune, cap, presso, importanza)
            return output
        } catch (As4SqlRuntimeException runtimeEx){
            output.codice = runtimeEx.getCodice()
            output.esito_operazione = runtimeEx.getMessage()
            return output
        }
    }

    @WebResult(name = "updContattoResult")
    @WebMethod(operationName = "updContatto")
    WsOutput updContatto(
            @WebParam(name = "idContatto") @XmlElement(required = false) Long idContatto,
            @WebParam(name = "ni") @XmlElement(required = false) Long ni,
            @WebParam(name = "tipoRecapito") @XmlElement(required = false) String tipoRecapito,
            @WebParam(name = "tipoContatto") @XmlElement(required = false) String tipoContatto,
            @WebParam(name = "dal") @XmlElement(required = true) Date dal,
            @WebParam(name = "al") @XmlElement(required = false) Date al,
            @WebParam(name = "valore") @XmlElement(required = true) String valore,
            @WebParam(name = "note") @XmlElement(required = false) String note) {
//        return serviziAnagrafeService.updContatto(idContatto, ni, tipoRecapito, tipoContatto, dal, al, valore, note)
        WsOutput output = new WsOutput()
        try{
            output = serviziAnagrafeService.updContatto(idContatto, ni, tipoRecapito, tipoContatto, dal, al, valore, note)
            return output
        } catch (As4SqlRuntimeException runtimeEx){
            output.codice = runtimeEx.getCodice()
            output.esito_operazione = runtimeEx.getMessage()
            return output
        }
    }
}
