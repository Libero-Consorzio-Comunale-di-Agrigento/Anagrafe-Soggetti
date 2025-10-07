package it.finmatica.test.pages

import geb.Module
import geb.waiting.*

class TabSoggettoModule extends Module {

    static content = {
        nomeField { $("input.fin-nome") }
        cognomeField { $("input.fin-cognome") }
        sessoField { $(".fin-sesso input") }
        sessoSelectionM { $(".fin-sesso td.z-comboitem-text")[2] }
        sessoSelectionF { $(".fin-sesso td.z-comboitem-text")[1] }
        tipoSoggettoField { $(".fin-tipo-soggetto input") }
        tipoSoggettoSogg { $(".fin-tipo-soggetto td.z-comboitem-text") }
		noteField { $("input.fin-note") }
//        tipoSoggettoSoggGenerico { $(".fin-tipo-soggetto td.z-comboitem-text", text:contains('SOGGETTO GENERICO')) }
        addButton { $(".fin-btn-ins-sogg img").findAll({ it.displayed }) }
		saveButton { $(".fin-btn-save-sogg img").findAll({ it.displayed }) }
		updButton { $(".fin-btn-upd-sogg img").findAll({ it.displayed }) }
		closeButton { $(".fin-btn-close-sogg img").findAll({ it.displayed }) }
		msgBoxOKButton { $(".z-messagebox-window .z-messagebox-btn") }
    }

	void insertEmptySogg(def anagrafica) {
		tipoSoggettoField.click()
		$("div.fin-tipo-soggetto.z-combobox-shadow") 
		$(".fin-tipo-soggetto td.z-comboitem-text", text: contains(anagrafica.tipo))[0].click()
		
		waitFor {addButton.click()}
	}
	
	void insertPersonaFisica(def anagrafica) {
		waitFor { [$("input.fin-nome"), $("input.fin-cognome")] }
//		tipoSoggettoField.click()
//		waitFor { $("div.fin-tipo-soggetto.z-combobox-shadow") }
//		$(".fin-tipo-soggetto td.z-comboitem-text", text: contains(anagrafica.tipo))[0].click()

		nomeField = anagrafica.nome
		cognomeField = anagrafica.cognome

		sessoField.click()
		waitFor { $("div.fin-sesso.z-combobox-shadow") }
		sessoSelectionM.click()
		saveButton.click()
		waitFor { msgBoxOKButton.click() }
		browser.report( "TabSoggettoModule.insertPersonaFisica")
		closeButton.click()
		//addButton.click()
	}
	
	void updatePersonaFisica(String note){
		noteField = note
		updButton.click()
	}
	
	void closeReadPanel(){
		closeButton.click()
	}
	
}