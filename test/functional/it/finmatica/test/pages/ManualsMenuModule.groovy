package it.finmatica.test.pages

import geb.Module

class ManualsMenuModule extends Module {
	static content = {
		elencoSoggetti { $("button[type='button'].fin-soggetti-btn") }
		dizionari { $("button[type='button'].fin-dizionari-btn") }
//		centralPanel { $("div.z-center") }
//		titoloApp (wait: true) { $("div.z-center span.descrizioneApplicazione", 0) }
	}


	void openElencoSoggetti() {
		elencoSoggetti.click()
		//waitFor { $("div.z-center span.descrizioneApplicazione", 0) }.text() == "Elenco Soggetti presenti in Anagrafica"
		//assert titoloApp.text() == "Elenco Soggetti presenti in Anagrafica"
		//waitFor { titoloApp.text() == "Elenco Soggetti presenti in Anagrafica" }
	   // waitFor { !linksContainer.hasClass("animating") }
		waitFor { $("div.fin-soggetti-win") }
	}

	void openDizionari() {
		dizionari.click()
		waitFor { $("div.fin-dizionari-win") }
	}
}
