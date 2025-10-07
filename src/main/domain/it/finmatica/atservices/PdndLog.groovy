package it.finmatica.atservices

import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper

class PdndLog {

    private String logId
    private String utente
    private String servizio
    private Date dataRichiesta
    private Date dataFine
    private String request
    private String response
    private String codiceFiscale
    private String esito

    PdndLog(String logId, String utente, String servizio, Date dataRichiesta, Date dataFine, String request, String response, ObjectMapper objectMapper) {
        this.logId = logId
        this.utente = utente
        this.servizio = servizio
        this.dataRichiesta = dataRichiesta
        this.dataFine = dataFine
        this.request = request
        this.response = response

        JsonNode jsonNode = objectMapper.readTree(request)
        if (this.servizio.equals("inad")) {
            this.codiceFiscale = jsonNode.path("codiceFiscale").asText()
        } else {
            this.codiceFiscale = jsonNode.path("criteriRicerca").path("codiceFiscale").asText()
        }
        this.esito = this.response == null ? "NEGATIVO" : "POSITIVO"
    }

    String getCodiceFiscale() {
        return codiceFiscale
    }

    String getEsito() {
        return esito
    }

    void setCodiceFiscale(String codiceFiscale) {
        this.codiceFiscale = codiceFiscale
    }

    void setEsito(String esito) {
        this.esito = esito
    }

    String getLogId() {
        return logId
    }

    String getUtente() {
        return utente
    }

    String getServizio() {
        return servizio
    }

    Date getDataRichiesta() {
        return dataRichiesta
    }

    Date getDataFine() {
        return dataFine
    }

    String getRequest() {
        return request
    }

    String getResponse() {
        return response
    }

    void setLogId(String logId) {
        this.logId = logId
    }

    void setUtente(String utente) {
        this.utente = utente
    }

    void setServizio(String servizio) {
        this.servizio = servizio
    }

    void setDataRichiesta(Date dataRichiesta) {
        this.dataRichiesta = dataRichiesta
    }

    void setDataFine(Date dataFine) {
        this.dataFine = dataFine
    }

    void setRequest(String request) {
        this.request = request
    }

    void setResponse(String response) {
        this.response = response
    }
}
