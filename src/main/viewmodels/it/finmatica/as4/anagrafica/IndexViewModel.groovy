package it.finmatica.as4.anagrafica

import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.dizionari.Ad4Comune
import it.finmatica.ad4.dizionari.Ad4Progetto
import it.finmatica.ad4.dizionari.Ad4Provincia
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.anagrafica.AnagraficaService
import it.finmatica.as4.As4Soggetto
import it.finmatica.as4.As4SoggettoCorrente
import it.finmatica.as4.dizionari.As4TipoSoggetto
import org.springframework.jdbc.core.JdbcTemplate
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.*
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

import java.text.SimpleDateFormat

//@CompileStatic
@VariableResolver(DelegatingVariableResolver)
@Slf4j
class IndexViewModel {
    @WireVariable private SpringSecurityService springSecurityService
    @WireVariable private As4DizionariService as4DizionariService
    @WireVariable private As4AnagraficaService as4AnagraficaService
	@WireVariable private AnagraficaService anagraficaService
	@WireVariable private JdbcTemplate jdbcTemplate


    Window window

    int activePage = 0
    int pageSize = 20
    int totalSize

    boolean researchActive, pannello, modifica, duplica, focus, ricercaStorico, abilitaSearchStorico, openFromUrl = false, inserimento = false

    def researchField, tipologia, progettoChiamante, competenzaEsclusiva
    Date selectedSoggettoDal
	String oggi
    def sezioni = [dizionari       : "/as4/dizionari/dizionari.zul"
                   , elencoSoggetti: "/as4/anagrafica/lista.zul"
                   , ANPR: "/as4/anpr/anpr.zul"
    ]

    String selectedSezione, tooltip, dal
    String urlSezione
    Ad4Utente utente
    def selectedSoggetto
    List listaSoggetti = []
    def soggetto
    As4SoggettoCorrente filtriSoggetto = new As4SoggettoCorrente()
    As4Soggetto filtriSoggettoStorico = new As4Soggetto()
    Map filtri = [cognome              : null
                  , nome               : null
                  , sesso              : null
                  , tipoSoggetto       : null
                  , codiceFiscale      : null
                  , codiceFiscaleEstero: null
                  , dataNascita        : null
                  , luogoNascita       : null
                  , comuneNascita      : null
                  , provinciaNascita   : null
                  , partitaIva         : null
                  , partitaIvaCee      : null
				  , dal				   : null
				  , al				   : null
				  , ni				   : null
                  , storico            : false]

    Integer prioritaProgetto
    Integer prioritaSoggetto
    Long openSoggetto
    Long idSoggettoUrl
    Date date

	private static String QUERY_RUOLI = "select count(*)\n" +
										"from ad4_utenti_gruppo\n" +
										"where gruppo = (\n" +
											"select utente\n" +
											"from ad4_utenti u, registro r\n" +
											"where u.gruppo_lavoro = r.valore\n" +
											"and chiave = 'PRODUCTS/ANAGRAFICA'\n" +
											"and stringa = ? )\n" +
											"and utente = ?"

	boolean atService = true
	boolean logAtService = true
	boolean as4 = true

    @Init
    void init(
            @ContextParam(ContextType.COMPONENT) Window w /*, @QueryParam("progettoChiamante") String pc, @QueryParam("soggetto") Long ni, @QueryParam("data") String dal*/
			) {
        this.window = w

		def ruoli = springSecurityService?.currentUser?.ruoli
		def auth = springSecurityService.principal.authorities
        utente = springSecurityService?.currentUser ?: (Ad4Utente.get("GUEST"))



		Object[] params = new Object[2]
		params[0] = "RuoloVisualizzatoreLogATS"
		params[1] = utente.utente

		logAtService = jdbcTemplate.queryForObject(QUERY_RUOLI, params, Integer.class) > 0
		params[0] = "RuoloRicercaATS"
		atService = jdbcTemplate.queryForObject(QUERY_RUOLI, params, Integer.class) > 0
		as4 = !(ruoli.getAt(0).ruolo.equals("AS4_ATS"))

		def session 	= Executions.getCurrent().getSession()

		if(session.getAttribute('progetto') != null)
			progettoChiamante = session.getAttribute('progetto')
//		if (pc != null)
//            progettoChiamante = pc
        else
            progettoChiamante = 'AS4'

		if(session.getAttribute('competenzaEsclusiva') != null)
			competenzaEsclusiva = session.getAttribute('competenzaEsclusiva')
		else
			competenzaEsclusiva = null

        researchActive = false
        pannello = true
        modifica = true
        duplica = true
        focus = true
        abilitaSearchStorico = true
		if(as4){
			selectedSezione = "elencoSoggetti"
		} else {
			selectedSezione = "ANPR"
		}

        tipologia = ""
        urlSezione = sezioni[selectedSezione]


        oggi = new SimpleDateFormat("dd/MM/yyyy").format(new Date())

        prioritaProgetto = (Ad4Progetto.findByProgetto(progettoChiamante))?.priorita

//        if (ni != null) {
		if (session.getAttribute('soggetto') != null) {
            idSoggettoUrl = Long.parseLong(session.getAttribute('soggetto')) //ni
            openFromUrl = true
            if (session.getAttribute('data') != null) {
				dal = session.getAttribute('data')
                def regx = /^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/;

                if (!(dal.matches(regx))) {
                    Messagebox.show('Il soggetto non e\' stato trovato', 'Attenzione', Messagebox.OK, Messagebox.EXCLAMATION)
                    openFromUrl = false
                } else {
                    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy")
                    date = fmt.parse(dal)
                    openFromUrl = true
                }

            }
            if (openFromUrl)
                onOpenDatiSoggetto(null)
        }
		String tipoOggetto = 'ANAGRAFICI'
		long isInseribileResult = as4AnagraficaService.isInseribile(-1, tipoOggetto, progettoChiamante)
		if (isInseribileResult != 1)
			inserimento = true
    }

    def onRicercaSoggetto() {
        pannello = true
//        duplica = true

        totalSize = as4DizionariService.contaSoggetti(filtriSoggetto)
        listaSoggetti = as4DizionariService.cercaSoggetti(activePage, pageSize, filtriSoggetto)
		
        BindUtils.postNotifyChange(null, null, this, "totalSize")
																	  
        BindUtils.postNotifyChange(null, null, this, "listaSoggetti")
    }
	def attivaRicercaVeloce(){
		List listaSoggettiProvvisoria = as4DizionariService.ricercaVeloce(researchField, activePage*pageSize, pageSize)
		totalSize = as4DizionariService.countTotalRows(researchField)
		listaSoggetti = inizializzaListaSoggetti(listaSoggettiProvvisoria)
	}
	@NotifyChange(['totalSize', 'listaSoggetti', 'activePage'])
	@Command ricercaVeloce(){ 
		if (researchField == null || researchField.equals('') || researchField.length() < 3) {
            Messagebox.show('Inserire almeno tre caratteri per la ricerca', 'Ricerca Soggetto', Messagebox.OK, Messagebox.EXCLAMATION)
        } else {
			activePage = 0
			attivaRicercaVeloce()
			pulisciFiltri()
        }
	}

	List inizializzaListaSoggetti(List listaProvvisoria){
		List lista = []
		listaProvvisoria.each { soggetto ->
			As4SoggettoCorrente soggettoCorrente = new As4SoggettoCorrente()
			
//			soggettoCorrente.cognome = soggetto.COGNOME
//			soggettoCorrente.nome = soggetto.NOME
			soggettoCorrente.nominativoRicerca = soggetto.NOMINATIVO_RICERCA
			
			if(soggetto.TIPO_SOGGETTO != null){
				As4TipoSoggetto ts = As4TipoSoggetto.findByTipoSoggetto(soggetto.TIPO_SOGGETTO)
				soggettoCorrente.tipoSoggetto = ts
			} else
				soggettoCorrente.tipoSoggetto = null
				
			soggettoCorrente.partitaIva = soggetto.PARTITA_IVA
			soggettoCorrente.codiceFiscale = soggetto.CODICE_FISCALE
			soggettoCorrente.indirizzoResidenza = soggetto.INDIRIZZO_RES 
			soggettoCorrente.capResidenza = soggetto.CAP_RES
			
			if(soggetto.PROVINCIA_RES != null){
				Ad4Provincia provinciaResidenza = Ad4Provincia.findByProvincia(soggetto.PROVINCIA_RES)
				soggettoCorrente.provinciaResidenza = provinciaResidenza
			} else
				soggettoCorrente.provinciaResidenza = null
			
			if(soggetto.COMUNE_RES  != null){
				Ad4Comune comuneResidenza = Ad4Comune.findById(soggetto.COMUNE_RES)
				soggettoCorrente.comuneResidenza = comuneResidenza
			} else
				soggettoCorrente.comuneResidenza = null
				
			soggettoCorrente.competenza = soggetto.COMPETENZA
			soggettoCorrente.id = soggetto.NI
			soggettoCorrente.dal = soggetto.DAL
			soggettoCorrente.al = soggetto.AL
			soggettoCorrente.note = soggetto.NOTE
			
			lista.add(soggettoCorrente)
		}
		
		return lista
	}
//    @NotifyChange(["listaSoggetti", "selectedSoggetto", "totalSize", "pannello", "duplica", "modifica", "activePage"])
//    @Command
//    void ricercaGenerica() {
//        if (researchField == null) {
//            ricercaStorico = false
//            Messagebox.show('Inserire almeno un carattere per la ricerca', 'Ricerca Soggetto', Messagebox.OK, Messagebox.EXCLAMATION)
//            BindUtils.postNotifyChange(null, null, this, "ricercaStorico")
//        } else {
//            filtri.cognome = null
//            filtri.nome = null
//            filtri.sesso = null
//            filtri.tipoSoggetto = null
//            filtri.codiceFiscale = null
//            filtri.codiceFiscaleEstero = null
//            filtri.dataNascita = null
//            filtri.luogoNascita = null
//            filtri.comuneNascita = null
//            filtri.provinciaNascita = null
//            filtri.partitaIva = null
//            filtri.partitaIvaCee = null
//            activePage = 0
//            if (!ricercaStorico)
//                onRicercaSoggetto()
//            else
//                onRicercaStorico()
//            BindUtils.postNotifyChange(null, null, this, "ricercaStorico")
//        }
//    }

	@NotifyChange(["pannello", "activePage"])
    @Command
    void onRicercaStorico() {
        pannello = true
        totalSize = as4DizionariService.contaSoggettiStorici(filtriSoggettoStorico)
        listaSoggetti = as4DizionariService.cercaSoggettiStorici(activePage, pageSize, filtriSoggettoStorico)
		BindUtils.postNotifyChange(null, null, this, "totalSize")
		BindUtils.postNotifyChange(null, null, this, "listaSoggetti")
    }

    @NotifyChange(["listaSoggetti", "totalSize", "pannello", "duplica", "modifica", "activePage"])
    @Command('onPagina')
    def onPagina() {      
		if(researchField != null){
			attivaRicercaVeloce()
		} else if (ricercaStorico)
			    onRicercaStorico()
			else
				onRicercaSoggetto()
    }

    @Command
    void fastOpen() {
        if (!abilitaModifica())
            onOpenDatiSoggetto('modifica')
        else
            onOpenDatiSoggetto('lettura')
    }

	@NotifyChange(['listaSoggetti', 'abilitaSearchStorico', 'ricercaStorico', 'researchField'])
	@Command
	def ricercaConFiltri() {
		researchField = null
		Window w = Executions.createComponents("/as4/anagrafica/ricerca.zul", window, [filtri: filtri])
		w.onClose() { event ->
			if (event.data) {
				selectedSoggetto = null
				modifica = true
				pannello = true
				activePage = 0
				ricercaStorico = event.data.ricercaStorico
				if (ricercaStorico) {
					filtriSoggettoStorico = event?.data?.soggetto
					onRicercaStorico()
				} else {
					filtriSoggetto = event?.data?.soggetto
					onRicercaSoggetto()
				}
				inizializzaFiltri(event?.data?.soggetto)
				BindUtils.postNotifyChange(null, null, this, "listaSoggetti")
				BindUtils.postNotifyChange(null, null, this, "activePage")
				BindUtils.postNotifyChange(null, null, this, "selectedSoggetto")
				BindUtils.postNotifyChange(null, null, this, "modifica")
				BindUtils.postNotifyChange(null, null, this, "pannello")
					
			}
		}
		 w.doModal()
	}
    @NotifyChange(['ricercaStorico', 'researchField', 'totalSize', 'listaSoggetti', 'activePage', 'filtri'])
    @Command
    def onOpenDatiSoggetto(@BindingParam("tipo") String tipo) {
        tipologia = tipo
        abilitaSearchStorico = true
        BindUtils.postNotifyChange(null, null, this, "abilitaSearchStorico")

        if (tipo.equals("duplica") || tipo.equals("lettura") || tipo.equals("modifica")) {
            if (selectedSoggetto != null)
                soggetto = (selectedSoggetto.id) ?: selectedSoggetto.ni

        } else if (tipo.equals("inserimento")) {
            soggetto = null
        } else {
            soggetto = idSoggettoUrl
            selectedSoggettoDal = date
        }
        Window w = Executions.createComponents("/as4/anagrafica/dettaglio.zul", window, [tipo: tipo, selectedSoggettoId: soggetto, selectedSoggettoDal: (selectedSoggetto?.dal) ?: selectedSoggettoDal, filtriSoggetto: filtri, codiceFiscalePartitaIvaObb: false, progettoChiamante: progettoChiamante, competenzaEsclusiva: competenzaEsclusiva])
		w.onClose() { event ->
			selectedSoggetto = null
			modifica = true
			pannello = true
			if(researchField != null && !(researchField.equals('')))
				attivaRicercaVeloce()
			else if (ricercaStorico)
				onRicercaStorico()
			else if(filtriSoggetto.cognome != null || filtriSoggetto.nome != null || filtriSoggetto.dal != null ||
				filtriSoggetto.al != null || filtriSoggetto.tipoSoggetto != null || filtriSoggetto.sesso != null ||
				filtriSoggetto.dataNascita != null || filtriSoggetto.comuneNascita != null || filtriSoggetto.provinciaNascita != null ||
				filtriSoggetto.luogoNascita != null || filtriSoggetto.codiceFiscale!= null || filtriSoggetto.codiceFiscaleEstero != null ||
				filtriSoggetto.partitaIva != null || filtriSoggetto.partitaIvaCee != null) 
				onRicercaSoggetto()
				
			BindUtils.postNotifyChange(null, null, this, "totalSize")
			BindUtils.postNotifyChange(null, null, this, "listaSoggetti")
			BindUtils.postNotifyChange(null, null, this, "activePage")
			BindUtils.postNotifyChange(null, null, this, "selectedSoggetto")
			BindUtils.postNotifyChange(null, null, this, "modifica")
			BindUtils.postNotifyChange(null, null, this, "pannello")
		}
        w.doModal()
    }

    public List<String> getPatterns() {
        return sezioni.collect { it.key }
    }

    @Command
    void apriSezione(@BindingParam("sezione") String sezione) {
        if (sezioni[sezione]) {
            selectedSezione = sezione
            urlSezione = sezioni[selectedSezione]
            BindUtils.postNotifyChange(null, null, this, "urlSezione")
            BindUtils.postNotifyChange(null, null, this, "selectedSezione")
        } else {
            Clients.showNotification("In fase di realizzazione", Clients.NOTIFICATION_TYPE_INFO, null, "middle_center", 3000, true)
        }
    }

    public String getVersioneApplicazione() {
//        String versione = grailsApplication.metadata['app.version'];
//        String buildNumber = grailsApplication.metadata['app.buildNumber'];
//        String buildTime = grailsApplication.metadata['app.buildTime'];

		String versione = anagraficaService.getVersione()
		String buildNumber = anagraficaService.getBuildNumber()
		String buildTime = anagraficaService.getBuildTime()

        return "Gruppo Finmatica - Versione v$versione${(buildNumber == null ? '' : '-b' + buildNumber)}${(buildTime == null ? '' : ' [' + buildTime + ']')}";
    }

    String descrizioneIndirizzo(def sc) {
        String descrizioneIndirizzo = ""
        if (sc.indirizzoResidenza != null)
            descrizioneIndirizzo += sc.indirizzoResidenza

        if (sc.capResidenza != null)
            descrizioneIndirizzo += " " + sc.capResidenza

        if (sc.comuneResidenza != null)
            descrizioneIndirizzo += " " + sc.comuneResidenza + " "
			
		if (sc.provinciaResidenza != null)
			descrizioneIndirizzo += " (" + sc.provinciaResidenza + ")"

        return descrizioneIndirizzo
    }

	@NotifyChange(['inserimento', 'modifica', 'pannello'])
	@Command gestisciCompetenze(){
		abilitaModifica()
//		abilitaInserimento()
	}
	
   
    def abilitaModifica() {
		String tipoOggetto = "ANAGRAFICI"
        modifica = false
        pannello = false
        long isModificaleResult = as4AnagraficaService.isModificabile(selectedSoggetto, tipoOggetto, progettoChiamante)
		println "modificabile " +  isModificaleResult
        if (isModificaleResult != 1)
            modifica = true
    }
	
	def abilitaInserimento() {
		String tipoOggetto = "ANAGRAFICI"
		inserimento = false
		pannello = false
		long isInseribileResult = as4AnagraficaService.isInseribile(selectedSoggetto, tipoOggetto, progettoChiamante)
		println "inseribile " +  isInseribileResult
		if (isInseribileResult != 1)
			inserimento = true
	}

    def inizializzaFiltri(def soggetto) {
		
		filtri.cognome = soggetto.cognome
        filtri.cognome = soggetto.cognome
        filtri.nome = soggetto.nome
        filtri.sesso = soggetto.sesso
        filtri.tipoSoggetto = soggetto.tipoSoggetto
        filtri.codiceFiscale = soggetto.codiceFiscale
        filtri.codiceFiscaleEstero = soggetto.codiceFiscaleEstero
        filtri.dataNascita = soggetto.dataNascita
        filtri.luogoNascita = soggetto.luogoNascita
        filtri.comuneNascita = soggetto.comuneNascita
        filtri.provinciaNascita = soggetto.provinciaNascita
        filtri.partitaIva = soggetto.partitaIva
        filtri.partitaIvaCee = soggetto.partitaIvaCee
		filtri.dal = soggetto.dal
		filtri.al = soggetto.al
        filtri.storico = ricercaStorico
		if(ricercaStorico)
			filtri.ni = soggetto.ni
		else
			filtri.ni = soggetto.id
    }

	def pulisciFiltri() {
		
		filtri.cognome = null
		filtri.nome = null
		filtri.sesso = null
		filtri.tipoSoggetto = null
		filtri.codiceFiscale = null
		filtri.codiceFiscaleEstero = null
		filtri.dataNascita = null
		filtri.luogoNascita = null
		filtri.comuneNascita = null
		filtri.provinciaNascita = null
		filtri.partitaIva = null
		filtri.partitaIvaCee = null
		filtri.dal = null
		filtri.al = null
		filtri.storico = null
	}
    @Command
    void onCheckStorico(@BindingParam("target") def target) {
        if (target.checked) {
            selectedSoggetto = new As4Soggetto()
            ricercaStorico = true
            filtri.storico = true
        } else {
            selectedSoggetto = new As4SoggettoCorrente()
            ricercaStorico = false
            filtri.storico = true
        }
    }

    @Command
    void doLogout() {
        Executions.sendRedirect("/logout")
    }

    Long descrizioneIdentificativoSoggetto(def s) {
        Long identificativo

        if (s instanceof As4SoggettoCorrente)
            identificativo = s.id
        else if (s instanceof As4Soggetto)
            identificativo = s.ni

        return identificativo
    }
	
	String descrizioneCategoria(String categoria){
		String url
		
		switch (categoria) {
			case 'PF':
				url = '/images/afc/18x18/child.png'
				tooltip = 'PERSONA FISICA'
				break
			case 'PG':
				url = '/images/afc/18x18/people_home.png'
				tooltip = 'PERSONA GIURIDICA'
				break
		}

		return url
	}
	
	@Command onOpenInformazioniUtente () {
		Executions.createComponents ("info.zul", null, [competenzaEsclusiva: competenzaEsclusiva, competenza: progettoChiamante]).doModal()
	}
}
