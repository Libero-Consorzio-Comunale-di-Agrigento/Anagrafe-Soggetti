package it.finmatica.as4.anpr


import it.finmatica.ad4.security.SpringSecurityService
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.*
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

class AnprViewModel {
    @WireVariable
    private SpringSecurityService springSecurityService

    Window window
    String selectedSezione
    String urlSezione
    def sezioni = [ricerca: "/as4/anpr/ricerca.zul"
                   , log  : "/as4/anpr/log.zul"
    ]

    boolean atService
    boolean logAtService
    boolean as4


    @Init
    init(@ContextParam(ContextType.COMPONENT) Window w,
         @ExecutionArgParam("as4") pAs4,
         @ExecutionArgParam("atService") pAtService,
         @ExecutionArgParam("logAtService") pLogAtService) {
        window = w

        atService = pAtService
        logAtService = pLogAtService
        as4 = pAs4

        if (!atService && !logAtService && !as4){ //Ruolo ATS e non possiedo diritti per operare
            Messagebox.show("Necessario abilitare l'utente per utilizzare l'applicativo", 'Attenzione', Messagebox.OK, Messagebox.EXCLAMATION)
            return
        }

        selectedSezione = atService ? "ricerca" : "log"
        urlSezione = sezioni[selectedSezione]

    }


    @Command
    public void onSelectedSezione() {
        urlSezione = sezioni[selectedSezione]
        BindUtils.postNotifyChange(null, null, this, "urlSezione")
    }


}
