package it.finmatica.test.pages

import geb.Module

class WindowAnagModule extends Module {
    static content = {
        tabSoggetti { $("div.fin-window-anag li.fin-tab-soggetto a") }
        tabRecapiti { $("div.fin-window-anag li.fin-tab-recapiti a") }
        tabContatti { $("div.fin-window-anag li.fin-tab-contatti a") }
        tabStorico  { $("div.fin-window-anag li.fin-tab-storico a") }
    }
}