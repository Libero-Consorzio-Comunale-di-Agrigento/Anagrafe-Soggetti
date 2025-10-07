package it.finmatica.test.pages

import geb.Module

class ToolbarSoggettoModule extends Module {
    static content = {
    	addButton { $("div.fin-add-button img") }
		updateButton { $("div.fin-update-button img") }
		readButton { $("div.fin-read-button img") }
		ricercaField { $("input.z-textbox-rounded-inp") }
		ricercaBtn { $("div.fin-btn-fast-search img") }
		
		listSoggetti { $('div.z-listbox-body') }
		cellList { $('tr.fin-row-list > td')[0] }
    }

    void clickAddButton() {
    	addButton.click();
    	waitFor { $("div.fin-win-dett") }
    }
	
	void fastSearch(String word){
		ricercaField = word
		ricercaBtn.click()
		waitFor { $('div.z-listbox-body .z-listcell') }
		cellList.click()
	}
	
	void selectedElement() {
		updateButton.click();
		waitFor { $("div.fin-win-dett") }
	}
	
	void openReadPanel() {
		readButton.click();
		waitFor { $("div.fin-win-dett") }
	}
}
