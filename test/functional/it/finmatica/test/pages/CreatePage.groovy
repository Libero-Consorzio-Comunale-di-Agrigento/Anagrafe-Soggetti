package it.finmatica.test.pages

import geb.Page

class CreatePage extends Page {

	static at = {
		$( "div.fin-win-dett" )
	}

	static content = {
        tabSoggetto { module (TabSoggettoModule) }
        messageBox { module (MessageBoxModule) }
        insertButton  { $("btn.fin-btn-chiudi") }
    }
}
