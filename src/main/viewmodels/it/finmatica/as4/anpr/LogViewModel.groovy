package it.finmatica.as4.anpr


import it.finmatica.anagrafica.atservices.LogService
import it.finmatica.anagrafica.utils.ExportCsvService
import it.finmatica.atservices.Operatore
import it.finmatica.atservices.PdndLog
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

@VariableResolver(DelegatingVariableResolver)
class LogViewModel {
    @WireVariable
    private LogService logService
    @WireVariable
    private ExportCsvService exportCsvService

    Window window

    Date dal
    Date al

    List<PdndLog> listaLog

    boolean disabilita

    Map labels = ["utente"       : "OPERATORE",
                  "servizio"     : "SERVIZIO",
                  "dataRichiesta": "DATA RICHIESTA",
                  "codiceFiscale": "CODICE FISCALE RICERCATO",
                  "esito"        : "ESITO"]

    List fields = ["utente", "servizio", "dataRichiesta", "codiceFiscale", "esito"]

    List<Operatore> operatori = [new Operatore(null, "-")]
    Operatore operatoreSelezionato


    @Init
    init(@ContextParam(ContextType.COMPONENT) Window w) {
        window = w
        operatori.addAll(logService.getOperatori())
        operatoreSelezionato = operatori.get(0)
    }

    @Command
    void ricerca() {
        if (dal == null || al == null) {
            Messagebox.show("Inserire l'intervallo temporale", 'Attenzione', Messagebox.OK, Messagebox.EXCLAMATION)
            return
        }
        if (dal.after(al)) {
            Messagebox.show("Inserire un intervallo temporale corretto", 'Attenzione', Messagebox.OK, Messagebox.EXCLAMATION)
            return
        }
        disabilita = true

        listaLog = logService.getLogs(operatoreSelezionato.operatore, dal, al)

        BindUtils.postNotifyChange(null, null, this, "disabilita")
        BindUtils.postNotifyChange(null, null, this, "listaLog")

    }

    @Command
    void azzera() {
        disabilita = false

        operatoreSelezionato = operatori.get(0)
        dal = null
        al = null

        BindUtils.postNotifyChange(null, null, this, "disabilita")
        BindUtils.postNotifyChange(null, null, this, "operatoreSelezionato")
        BindUtils.postNotifyChange(null, null, this, "dal")
        BindUtils.postNotifyChange(null, null, this, "al")


    }

    @Command
    void estrai() {


        String nomeFile = "LogAccessiANPR"

        Map parameters = ["nomeFile": nomeFile]
        exportCsvService.exportData(listaLog, fields, labels, parameters, null)

    }

}
