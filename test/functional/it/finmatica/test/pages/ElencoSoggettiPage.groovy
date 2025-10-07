package it.finmatica.test.pages

import geb.Page

class ElencoSoggettiPage extends Page {
	static atCheckWaiting = true

    static at = { $("div.fin-soggetti-win") }

    static content = {
    	manualsMenu { module ManualsMenuModule }
        toolbarSoggetto { module ToolbarSoggettoModule }
    }
}
