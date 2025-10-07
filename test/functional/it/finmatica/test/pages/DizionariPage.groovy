package it.finmatica.test.pages

import geb.Page

class DizionariPage extends Page {

    static at = { $("div.z-center div.titoloAccordion").text().contains("DIZIONARI") }

    static content = {
        manualsMenu { module(ManualsMenuModule) }
    }
}
