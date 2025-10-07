package it.finmatica.test.pages

import geb.Page

class HomePage extends Page {
	static atCheckWaiting = true
	static at =  { $("span.descrizioneApplicazione",0).text() == "Gestione Anagrafe Generale Soggetti" }
	
	static content = {
		manualsMenu { module ManualsMenuModule }
	}
}