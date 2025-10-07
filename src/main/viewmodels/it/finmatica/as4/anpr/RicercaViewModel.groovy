package it.finmatica.as4.anpr

import groovy.json.JsonBuilder
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.anagrafica.RegistroService
import it.finmatica.anagrafica.atservices.RegistroAD4Service
import org.apache.http.client.config.RequestConfig
import org.apache.http.client.methods.CloseableHttpResponse
import org.apache.http.client.methods.HttpPost
import org.apache.http.entity.StringEntity
import org.apache.http.impl.client.CloseableHttpClient
import org.apache.http.impl.client.HttpClients
import org.apache.http.util.EntityUtils
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

import java.text.SimpleDateFormat
import java.time.LocalDate
import java.time.format.DateTimeFormatter

@Slf4j
@VariableResolver(DelegatingVariableResolver)
class RicercaViewModel {

    @WireVariable
    private RegistroService registroService
    @WireVariable
    private RegistroAD4Service registroAD4Service
    @WireVariable
    private SpringSecurityService springSecurityService

    //private static final Logger log = Logger.getLogger(RicercaViewModel.class)


    Window window
    String urlATService
    String username
    String password

    String codiceFiscaleStr


    boolean generalitaVisible = false
    boolean decessoVisible = false
    boolean matrimonioVisible = false
    boolean cittadinanzaVisible = false
    boolean esistenzaVisible = false
    boolean residenzaVisible = false
    boolean famigliaVisible = false
    boolean liberoVisible = false
    boolean vedovanzaVisible = false
    boolean paternitaVisible = false
    boolean maternitaVisible = false
    boolean domicilioDigitaleVisible = false

    boolean decesso = false
    boolean matrimonio = false
    boolean cittadinanza = false
    boolean esistenza = false
    boolean residenza = false
    boolean famiglia = false
    boolean libero = false
    boolean vedovanza = false
    boolean paternita = false
    boolean maternita = false
    boolean domicilioDigitale = false


    boolean disabilita

    Ad4Utente utente

    String risultato = ""

    private static final DateTimeFormatter formatterOriginale = DateTimeFormatter.ofPattern("yyyy-MM-dd")
    private static final DateTimeFormatter formatterOutput = DateTimeFormatter.ofPattern("dd/MM/yyyy")

    @Init
    init(@ContextParam(ContextType.COMPONENT) Window w) {
        window = w
        urlATService = registroService.getValore("PRODUCTS/ANAGRAFICA", "urlATService")
        username = registroService.getValore("PRODUCTS/ANAGRAFICA", "userATService")
        password = registroService.getValore("PRODUCTS/ANAGRAFICA", "pswATService")

        List<String> visibilita = registroAD4Service.getVisibilitaCheckBox()

        for (String s : visibilita) {
            switch (s) {
                case "ANPR_C015":
                    generalitaVisible = true
                    break
                case "ANPR_C016":
                    decessoVisible = true
                    break
                case "ANPR_C017":
                    matrimonioVisible = true
                    break
                case "ANPR_C018":
                    cittadinanzaVisible = true
                    break
                case "ANPR_C019":
                    esistenzaVisible = true
                    break
                case "ANPR_C020":
                    residenzaVisible = true
                    break
                case "ANPR_C021":
                    famigliaVisible = true
                    break
                case "ANPR_C022":
                    liberoVisible = true
                    break
                case "ANPR_C023":
                    vedovanzaVisible = true
                    break
                case "ANPR_C024":
                    paternitaVisible = true
                    break
                case "ANPR_C025":
                    maternitaVisible = true
                    break
                case "INAD":
                    domicilioDigitaleVisible = true
                    break
                default:
                    log.info("Codice non riconosciuto ${s}")
            }
        }

        utente = springSecurityService?.currentUser ?: (Ad4Utente.get("GUEST"))
        risultato = ""
        disabilita = false

    }

    @Command
    void selezionaTutti(){
        decesso = decessoVisible
        matrimonio = matrimonioVisible
        cittadinanza = cittadinanzaVisible
        esistenza = esistenzaVisible
        residenza = residenzaVisible
        famiglia = famigliaVisible
        libero = liberoVisible
        vedovanza = vedovanzaVisible
        paternita = paternitaVisible
        maternita = matrimonioVisible
        domicilioDigitale = domicilioDigitaleVisible

        BindUtils.postNotifyChange(null, null, this, "decesso")
        BindUtils.postNotifyChange(null, null, this, "matrimonio")
        BindUtils.postNotifyChange(null, null, this, "cittadinanza")
        BindUtils.postNotifyChange(null, null, this, "esistenza")
        BindUtils.postNotifyChange(null, null, this, "residenza")
        BindUtils.postNotifyChange(null, null, this, "famiglia")
        BindUtils.postNotifyChange(null, null, this, "libero")
        BindUtils.postNotifyChange(null, null, this, "vedovanza")
        BindUtils.postNotifyChange(null, null, this, "paternita")
        BindUtils.postNotifyChange(null, null, this, "maternita")
        BindUtils.postNotifyChange(null, null, this, "domicilioDigitale")
    }

    @Command
    void ricerca() {
        if (codiceFiscaleStr == null || codiceFiscaleStr.equals('')) {
            Messagebox.show('Inserire il codice fiscale', 'Attenzione', Messagebox.OK, Messagebox.EXCLAMATION)
            return
        }
        if (codiceFiscaleStr.length() != 16) {
            Messagebox.show('Il codice fiscale inserito non è corretto', 'Attenzione', Messagebox.OK, Messagebox.EXCLAMATION)
            return
        }
        if (!generalitaVisible && !decesso && !matrimonio && !cittadinanza && !esistenza && !residenza &&
                !famiglia && !libero && !vedovanza && !paternita && !maternita && !domicilioDigitale) {
            Messagebox.show('Spuntare almeno un campo', 'Attenzione', Messagebox.OK, Messagebox.EXCLAMATION)
            return
        }

        disabilita = true
        codiceFiscaleStr = codiceFiscaleStr.toUpperCase()

        if(generalitaVisible){ //C015
            risultato = "GENERALITÀ:\n"

            CloseableHttpResponse respC015 = inviaRichiesta("/anpr-service-c015", costruisceRichiestaANPR("C015"))

            if (respC015 == null) {
                risultato += "\t\tErrore in fase di invio della richiesta\n"
            } else if (respC015.getStatusLine().getStatusCode() == 200) {
                risultato += processaRispostaGeneralita(EntityUtils.toString(respC015.getEntity()))
            } else {
                risultato += "\t\tN/A\n"
            }
        }

        if (paternita) { //C024
            risultato += "\nPATERNITÀ: "

            CloseableHttpResponse resp = inviaRichiesta("/anpr-service-c024", costruisceRichiestaANPR("C024"))

            if (resp == null) {
                risultato += "Errore in fase di invio della richiesta\n"
            } else if (resp.getStatusLine().getStatusCode() == 200) {
                risultato += processaRispostaPaternita(EntityUtils.toString(resp.getEntity()))
            } else {
                risultato += "N/A\n"
            }

        }

        if (maternita) { //C025
            risultato += "\nMATERNITÀ: "

            CloseableHttpResponse resp = inviaRichiesta("/anpr-service-c025", costruisceRichiestaANPR("C025"))

            if (resp == null) {
                risultato += "Errore in fase di invio della richiesta\n"
            } else if (resp.getStatusLine().getStatusCode() == 200) {
                risultato += processaRispostaMaternita(EntityUtils.toString(resp.getEntity()))
            } else {
                risultato += "N/A\n"
            }
        }

        if (residenza) { //C020
            risultato += "\nRESIDENZA:\n"
            CloseableHttpResponse resp = inviaRichiesta("/anpr-service-e002", costruisceRichiestaANPR("C020"))

            if (resp == null) {
                risultato += "\t\tErrore in fase di invio della richiesta\n"
            } else if (resp.getStatusLine().getStatusCode() == 200) {
                risultato += processaRispostaResidenza(EntityUtils.toString(resp.getEntity()))
            } else {
                risultato += "\t\tN/A\n"
            }

        }

        if (esistenza) { //C019
            risultato += "\nESISTENZA IN VITA: "

            CloseableHttpResponse resp = inviaRichiesta("/anpr-service-c019", costruisceRichiestaANPR("C019"))

            if (resp == null) {
                risultato += "Errore in fase di invio della richiesta\n"
            } else if (resp.getStatusLine().getStatusCode() == 200) {
                risultato += processaRispostaEsistenza(EntityUtils.toString(resp.getEntity()))
            } else {
                risultato += "N/A\n"
            }

        }

        if (decesso) { //C016
            risultato += "\nDECESSO: "

            CloseableHttpResponse resp = inviaRichiesta("/anpr-service-c016", costruisceRichiestaANPR("C016"))

            if (resp == null) {
                risultato += "Errore in fase di invio della richiesta\n"
            } else if (resp.getStatusLine().getStatusCode() == 200) {
                risultato += processaRispostaDecesso(EntityUtils.toString(resp.getEntity()))
            } else {
                risultato += "N/A\n"
            }

        }

        if (matrimonio) { //C017
            risultato += "\nMATRIMONIO: "

            CloseableHttpResponse resp = inviaRichiesta("/anpr-service-c017", costruisceRichiestaANPR("C017"))

            if (resp == null) {
                risultato += "Errore in fase di invio della richiesta\n"
            } else if (resp.getStatusLine().getStatusCode() == 200) {
                risultato += processaRispostaMatrimonio(EntityUtils.toString(resp.getEntity()))
            } else {
                risultato += "N/A\n"
            }

        }

        if (vedovanza) { //C023
            risultato += "\nVEDOVANZA: "

            CloseableHttpResponse resp = inviaRichiesta("/anpr-service-c023", costruisceRichiestaANPR("C023"))

            if (resp == null) {
                risultato += "Errore in fase di invio della richiesta\n"
            } else if (resp.getStatusLine().getStatusCode() == 200) {
                risultato += processaRispostaVedovanza(EntityUtils.toString(resp.getEntity()))
            } else {
                risultato += "N/A\n"
            }

        }

        if (libero) { //C022
            risultato += "\nSTATO LIBERO: "

            CloseableHttpResponse resp = inviaRichiesta("/anpr-service-c022", costruisceRichiestaANPR("C022"))

            if (resp == null) {
                risultato += "Errore in fase di invio della richiesta\n"
            } else if (resp.getStatusLine().getStatusCode() == 200) {
                risultato += processaRispostaLibero(EntityUtils.toString(resp.getEntity()))
            } else {
                risultato += "N/A\n"
            }

        }

        if (cittadinanza) { //C018
            risultato += "\nCITTADINANZA:\n"

            CloseableHttpResponse resp = inviaRichiesta("/anpr-service-c018", costruisceRichiestaANPR("C018"))

            if (resp == null) {
                risultato += "\t\tErrore in fase di invio della richiesta\n"
            } else if (resp.getStatusLine().getStatusCode() == 200) {
                risultato += processaRispostaCittadinanza(EntityUtils.toString(resp.getEntity()))
            } else {
                risultato += "\t\tN/A\n"
            }

        }

        if (famiglia) { //C021
            risultato += "\nNUCLEO FAMIGLIARE:\n"

            CloseableHttpResponse resp = inviaRichiesta("/anpr-service-c021", costruisceRichiestaANPR("C021"))

            if (resp == null) {
                risultato += "\t\tErrore in fase di invio della richiesta\n"
            } else if (resp.getStatusLine().getStatusCode() == 200) {
                risultato += processaRispostaFamiglia(EntityUtils.toString(resp.getEntity()))
            } else {
                risultato += "\t\tN/A\n"
            }

        }

        if (domicilioDigitale) { //INAD
            risultato += "\nDOMICILIO DIGITALE (INAD):\n"

            JsonBuilder builder = new JsonBuilder()
            builder {
                codiceFiscale codiceFiscaleStr
                practicalReference "prova"
            }
            String ricJson = JsonOutput.prettyPrint(builder.toString())

            CloseableHttpResponse resp = inviaRichiesta("/dd", ricJson)

            if (resp == null) {
                risultato += "\t\tErrore in fase di invio della richiesta\n"
            } else if (resp.getStatusLine().getStatusCode() == 200) {
                risultato += processaDomicilioDigitale(EntityUtils.toString(resp.getEntity()))
            } else { //404 o altro
                risultato += "\t\tCodice fiscale non trovato, Utente non presente in INAD\n"
            }

        }

        risultato = risultato.replaceAll("null", "N/A")

        BindUtils.postNotifyChange(null, null, this, "disabilita")
        BindUtils.postNotifyChange(null, null, this, "risultato")


    }

    private String costruisceRichiestaANPR(String codice) {
        JsonBuilder builder = new JsonBuilder()
        builder {
            idOperazioneClient codice
            criteriRicerca {
                codiceFiscale codiceFiscaleStr
            }
            datiRichiesta {
                dataRiferimentoRichiesta new SimpleDateFormat("yyyy-MM-dd").format(new Date())
                motivoRichiesta "1"
                casoUso codice
            }
        }
        return JsonOutput.prettyPrint(builder.toString())
    }

    private CloseableHttpResponse inviaRichiesta(String url, String ricJson) {
        CloseableHttpResponse res

        try {
            CloseableHttpClient client = HttpClients.custom()
                    .setDefaultRequestConfig(RequestConfig.custom()
                            .setRedirectsEnabled(false)
                            .build())
                    .build()
            HttpPost requestSendNotifica = new HttpPost(urlATService + url + "?userId=" + utente.utente)
            requestSendNotifica.addHeader("Content-Type", "application/json")
            requestSendNotifica.setHeader("Authorization", "Basic " + Base64.getEncoder().encodeToString((username + ":" + password).getBytes("UTF-8")))
            StringEntity postingString = new StringEntity(ricJson, "UTF-8")
            requestSendNotifica.setEntity(postingString)
            res = client.execute(requestSendNotifica)
        } catch (Exception e) {
            log.error("Errore in fase di invio della richiesta: Servizio ${url}\n ${e.toString()}")
            return null
        }

        return res
    }

    private static String formattaData(String dataOriginale) {
        if (dataOriginale) {
            LocalDate data = LocalDate.parse(dataOriginale, formatterOriginale)
            return data.format(formatterOutput)
        }
        return ""
    }

    private static String processaErrore(def json) {
        String result = ""
        json.listaErrori.each { errore ->
            if (errore.tipoErroreAnomalia == 'E') {
                result += "\t\t${errore.codiceErroreAnomalia} - ${errore.testoErroreAnomalia}\n"
            }
        }
        return result
    }

    private static String processaRispostaGeneralita(String jsonString) {
        try {
            def json = new JsonSlurper().parseText(jsonString)

            if (json.listaErrori) {
                return processaErrore(json)
            }
            StringBuilder sb = new StringBuilder()

            def soggetto = json.listaSoggetti.datiSoggetto[0]
            def generalita = soggetto.generalita

            sb.append("\t\tNome: ${generalita.nome}\n")
            sb.append("\t\tCognome: ${generalita.cognome}\n")
            sb.append("\t\tCodice Fiscale: ${generalita.codiceFiscale?.codFiscale}\n")
            sb.append("\t\tNat${generalita.sesso == 'M' ? 'o' : 'a'} il ${formattaData(generalita.dataNascita)} ")
            if (generalita?.luogoNascita != null) {
                sb.append("a ${generalita.luogoNascita?.comune?.nomeComune} (${generalita.luogoNascita?.comune?.siglaProvinciaIstat})")
            } else {
                sb.append("a N/A")
            }
            sb.append("\n")

            sb.append("\t\tId ANPR: ${soggetto.identificativi?.idANPR}\n")

            return sb.toString()

        } catch (Exception e) {
            log.error("Errore durante il parsing dell risposta del servizio C015 (Generalità): ${e.toString()}")
            return "\t\tErrore durante il processamento della risposta\n"
        }
    }

    private static String processaRispostaDecesso(String jsonString) {
        try {
            def json = new JsonSlurper().parseText(jsonString)


            if (json.listaErrori) {
                return processaErrore(json).replaceAll("\t", "")
            }
            StringBuilder sb = new StringBuilder()

            def soggetto = json.listaSoggetti.datiSoggetto[0]

            if (soggetto.datiDecesso != null) {
                def luogo = soggetto.datiDecesso.luogoEvento
                sb.append("\n")
                sb.append("\t\tLuogo: ${luogo.nomeComune} (${luogo.siglaProvinciaIstat})\n")
                sb.append("\t\tData: ${formattaData(soggetto.datiDecesso.dataEvento)}")
            } else {
                sb.append("N/A")
            }

            sb.append("\n")


            return sb.toString()

        } catch (Exception e) {
            log.error("Errore durante il parsing dell risposta del servizio C016 (Decesso): ${e.toString()}")
            return "Errore durante il processamento della risposta\n"
        }

    }

    private static String processaRispostaMatrimonio(String jsonString) {
        try {

            def json = new JsonSlurper().parseText(jsonString)

            if (json.listaErrori) {
                return processaErrore(json).replaceAll("\t", "")
            }
            StringBuilder sb = new StringBuilder()

            def soggetto = json.listaSoggetti.datiSoggetto[0]

            if (soggetto.annullamentoMatrimonio == null && soggetto.matrimonio != null) {
                def coniuge = soggetto.matrimonio.coniuge
                def luogo = soggetto.matrimonio?.datiMatrimonio?.luogoEvento
                def data = soggetto.matrimonio?.datiMatrimonio?.dataEvento
                sb.append("\n")
                sb.append("\t\tConiuge: ${coniuge.cognome} ${coniuge.nome}\n")
                sb.append("\t\tCodice fiscale: ${coniuge?.codiceFiscale?.codFiscale ?: 'N/A'}\n")
                if (luogo != null) {
                    sb.append("\t\tLuogo matrimonio: ${luogo.nomeComune} (${luogo.sigliaProvinciaIstat})\n")
                } else {
                    sb.append("\t\tLuogo matrimonio: N/A\n")
                }
                if (data != null) {
                    sb.append("\t\tData matrimonio: ${formattaData(data)}\n")
                } else {
                    sb.append("\t\tData matrimonio: N/A\n")
                }
            } else {
                sb.append("N/A\n")
            }

            return sb.toString()

        } catch (Exception e) {
            log.error("Errore durante il parsing dell risposta del servizio C017 (Matrimonio): ${e.toString()}")
            return "Errore durante il processamento della risposta\n"
        }

    }

    private static String processaRispostaCittadinanza(String jsonString) {
        try {
            def json = new JsonSlurper().parseText(jsonString)

            if (json.listaErrori) {
                return processaErrore(json)
            }
            StringBuilder sb = new StringBuilder()

            def soggetto = json.listaSoggetti.datiSoggetto[0]
            def cittadinanze = soggetto.cittadinanza

            cittadinanze.each { cittadinanza ->
                sb.append("\t\t${cittadinanza.descrizioneStato} Data Validità: ${formattaData(cittadinanza.dataValidita)}\n")
            }

            return sb.toString()
        } catch (Exception e) {
            log.error("Errore durante il parsing dell risposta del servizio C018 (Cittadinanza): ${e.toString()}")
            return "\t\tErrore durante il processamento della risposta\n"
        }

    }

    private static String processaRispostaEsistenza(String jsonString) {
        try {
            def json = new JsonSlurper().parseText(jsonString)

            if (json.listaErrori) {
                return processaErrore(json).replaceAll("\t", "")
            }
            StringBuilder sb = new StringBuilder()

            def soggetto = json.listaSoggetti.datiSoggetto[0]
            def infoSoggetto = soggetto.infoSoggettoEnte.find { it.chiave == "Verifica esistenza in vita" }

            if (infoSoggetto) {
                sb.append("${infoSoggetto.valore == "S" ? "Sì" : "No"}")
            } else {
                sb.append("N/A")
            }

            sb.append("\n")


            return sb.toString()

        } catch (Exception e) {
            log.error("Errore durante il parsing dell risposta del servizio C019 (Esistenza): ${e.toString()}")
            return "Errore durante il processamento della risposta\n"
        }

    }


    private static String processaRispostaResidenza(String jsonString) {
        try {
            def json = new JsonSlurper().parseText(jsonString)

            if (json.listaErrori) {
                return processaErrore(json)
            }
            StringBuilder sb = new StringBuilder()

            def soggetto = json.listaSoggetti.datiSoggetto[0]
            def generalita = soggetto.generalita
            def infoSoggettoEnte = soggetto.infoSoggettoEnte
            def residenza = soggetto.residenza[0]

            if (generalita?.soggettoAIRE == 'S') { // AIRE
                def loc = residenza.localitaEstera
                def ind = loc.indirizzoEstero
                sb.append("\t\tIscritt${generalita.sesso == 'M' ? 'o' : 'a'} all’Anagrafe degli Italiani Residenti all’Estero (AIRE) dal ${formattaData((String) residenza.dataDecorrenzaResidenza)}\n")
                sb.append("\t\tIndirizzo: ${ind.toponimo.denominazione} ${ind.toponimo.numeroCivico ?: ""}\n")
                sb.append("\t\tLocalità: ${ind.localita.descrizioneLocalita} ${ind.localita.provinciaContea ?: ""} (${ind.localita.descrizioneStato})\n")
                sb.append("\t\tConsolato: ${loc?.consolato?.codiceConsolato} - ${loc?.consolato?.descrizioneConsolato}")

            } else if (infoSoggettoEnte != null) { // casi particolari
                if (infoSoggettoEnte.chiave.equals('Data decesso')) {
                    sb.append("\t\tSoggetto deceduto")
                } else {
                    sb.append("\t\tN/A")
                }
            } else { //ANPR
                sb.append("\t\tIscritt${generalita.sesso == 'M' ? 'o' : 'a'} all’Anagrafe Nazionale della Popolazione Residente (ANPR) dal ${formattaData((String) residenza.dataDecorrenzaResidenza)}\n")
                sb.append("\t\tIndirizzo: ${residenza.indirizzo.toponimo.specie} ${residenza.indirizzo.toponimo?.denominazioneToponimo ?: ""}, ${residenza.indirizzo.numeroCivico.numero}")
                if (residenza.indirizzo.numeroCivico?.civicoInterno != null) {
                    sb.append(", interno ${residenza.indirizzo.numeroCivico.civicoInterno.interno1}")
                }
                sb.append("\n")
                sb.append("\t\tComune: ${residenza.indirizzo?.comune?.nomeComune} (${residenza.indirizzo?.comune?.siglaProvinciaIstat})\n")
                sb.append("\t\tCAP: ${residenza.indirizzo?.cap}")
            }

            sb.append("\n")

            return sb.toString()

        } catch (Exception e) {
            log.error("Errore durante il parsing dell risposta del servizio C020 (Residenza): ${e.toString()}")
            return "\t\tErrore durante il processamento della risposta\n"
        }
    }

    private static String processaRispostaFamiglia(String jsonString) {
        try {
            def json = new JsonSlurper().parseText(jsonString)

            if (json.listaErrori) {
                return processaErrore(json)
            }
            StringBuilder sb = new StringBuilder()

            json.listaSoggetti.datiSoggetto.each { soggetto ->

                def generalita = soggetto.generalita
                sb.append("\t\tNome: ${generalita.nome}\n")
                sb.append("\t\tCognome: ${generalita.cognome}\n")
                sb.append("\t\tCodice Fiscale: ${generalita?.codiceFiscale?.codFiscale}\n")
                sb.append("\t\tNat${generalita.sesso == 'M' ? 'o' : 'a'} il ${formattaData(generalita.dataNascita)} ")
                if (generalita?.luogoNascita != null) {
                    sb.append("a ${generalita.luogoNascita?.comune?.nomeComune} (${generalita.luogoNascita?.comune?.siglaProvinciaIstat})")
                } else {
                    sb.append("a N/A")
                }
                sb.append("\n\n")
            }

            return sb.toString()

        } catch (Exception e) {
            log.error("Errore durante il parsing dell risposta del servizio C021 (Famiglia): ${e.toString()}")
            return "\t\tErrore durante il processamento della risposta\n"
        }

    }

    private static String processaRispostaLibero(String jsonString) {
        try {
            def json = new JsonSlurper().parseText(jsonString)

            if (json.listaErrori) {
                return processaErrore(json).replaceAll("\t", "")
            }

            StringBuilder sb = new StringBuilder()
            def soggetto = json.listaSoggetti.datiSoggetto[0]
            def infoSoggetto = soggetto.infoSoggettoEnte.find { it.chiave == "Verifica stato libero" }

            if (infoSoggetto) {
                sb.append("${infoSoggetto.valore == "S" ? "Sì" : "No"}")
            } else {
                sb.append("N/A")
            }

            sb.append("\n")

            return sb.toString()

        } catch (Exception e) {
            log.error("Errore durante il parsing dell risposta del servizio C022 (Stato libero): ${e.toString()}")
            return "Errore durante il processamento della risposta\n"
        }

    }

    private static String processaRispostaVedovanza(String jsonString) {
        try {

            def json = new JsonSlurper().parseText(jsonString)

            if (json.listaErrori) {
                return processaErrore(json).replaceAll("\t", "")
            }
            StringBuilder sb = new StringBuilder()

            def soggetto = json.listaSoggetti.datiSoggetto[0]

            if (soggetto.vedovanza != null) {
                def coniuge = soggetto?.matrimonio?.coniuge
                def luogo = soggetto.vedovanza?.datiMorteconiuge?.luogoEvento
                def data = soggetto.vedovanza?.datiMorteconiuge?.dataEvento
                sb.append("\n")
                sb.append("\t\tConiuge: ${coniuge?.cognome} ${coniuge?.nome}\n")
                sb.append("\t\tCodice fiscale: ${coniuge?.codiceFiscale?.codFiscale ?: 'N/A'}\n")
                if (luogo != null) {
                    sb.append("\t\tLuogo morte: ${luogo?.nomeComune} (${luogo?.sigliaProvinciaIstat})\n")
                } else {
                    sb.append("\t\tLuogo morte: N/A\n")
                }
                if (data != null) {
                    sb.append("\t\tData morte: ${formattaData(data)}\n")
                } else {
                    sb.append("\t\tData morte: N/A\n")
                }
            } else {
                sb.append("N/A\n")
            }

            return sb.toString()

        } catch (Exception e) {
            log.error("Errore durante il parsing dell risposta del servizio C023 (Vedovanza): ${e.toString()}")
            return "Errore durante il processamento della risposta\n"
        }

    }

    private static String processaRispostaPaternita(String jsonString) {
        try {

            def json = new JsonSlurper().parseText(jsonString)

            if (json.listaErrori) {
                return processaErrore(json).replaceAll("\t", "")
            }
            StringBuilder sb = new StringBuilder()

            def soggetto = json.listaSoggetti.datiSoggetto[0]

            if (soggetto.paternita != null) {
                def padre = soggetto.paternita.generalita
                sb.append("${padre.cognome} ${padre.nome}\n")
            } else {
                sb.append("N/A\n")
            }

            return sb.toString()

        } catch (Exception e) {
            log.error("Errore durante il parsing dell risposta del servizio C024 (Paternità): ${e.toString()}")
            return "Errore durante il processamento della risposta\n"
        }
    }

    private static String processaRispostaMaternita(String jsonString) {
        try {
            def json = new JsonSlurper().parseText(jsonString)

            if (json.listaErrori) {
                return processaErrore(json).replaceAll("\t", "")
            }
            StringBuilder sb = new StringBuilder()

            def soggetto = json.listaSoggetti.datiSoggetto[0]

            if (soggetto.maternita != null) {
                def madre = soggetto.maternita.generalita
                sb.append("${madre.cognome} ${madre.nome}\n")
            } else {
                sb.append("N/A\n")
            }

            return sb.toString()

        } catch (Exception e) {
            log.error("Errore durante il parsing dell risposta del servizio C025 (Maternità): ${e.toString()}")
            return "Errore durante il processamento della risposta\n"
        }
    }


    private static String processaDomicilioDigitale(String jsonString) {
        def json = new JsonSlurper().parseText(jsonString)
        StringBuilder sb = new StringBuilder()

        def domicilioDigitale = json.digitalAddress.each { domicilioDigitale ->

            sb.append("\t\tPEC: ${domicilioDigitale.digitalAddress}\n")
            sb.append("\t\tData Fine Validità: ${formattaData(domicilioDigitale.usageInfo.dateEndValidity.split("T")[0])}\n")
            sb.append("\n")
        }

        return sb.toString()
    }

    @Command
    void azzera() {
        disabilita = false

        codiceFiscaleStr = null

        decesso = false
        matrimonio = false
        cittadinanza = false
        esistenza = false
        residenza = false
        famiglia = false
        libero = false
        vedovanza = false
        paternita = false
        maternita = false
        domicilioDigitale = false
        risultato = ""

        BindUtils.postNotifyChange(null, null, this, "risultato")
        BindUtils.postNotifyChange(null, null, this, "disabilita")
        BindUtils.postNotifyChange(null, null, this, "codiceFiscaleStr")
        BindUtils.postNotifyChange(null, null, this, "decesso")
        BindUtils.postNotifyChange(null, null, this, "matrimonio")
        BindUtils.postNotifyChange(null, null, this, "cittadinanza")
        BindUtils.postNotifyChange(null, null, this, "esistenza")
        BindUtils.postNotifyChange(null, null, this, "residenza")
        BindUtils.postNotifyChange(null, null, this, "famiglia")
        BindUtils.postNotifyChange(null, null, this, "libero")
        BindUtils.postNotifyChange(null, null, this, "vedovanza")
        BindUtils.postNotifyChange(null, null, this, "paternita")
        BindUtils.postNotifyChange(null, null, this, "maternita")
        BindUtils.postNotifyChange(null, null, this, "domicilioDigitale")

    }


}
