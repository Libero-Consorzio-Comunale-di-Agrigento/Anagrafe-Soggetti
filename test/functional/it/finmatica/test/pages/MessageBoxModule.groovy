package it.finmatica.test.pages

import geb.Module

class MessageBoxModule extends Module {

    static content = {
        title     { $("div.z-messagebox-window div.z-window-header").text() }
        messsage  { $("div.z-messagebox-window div.z-window-content div.z-messagebox span.z-label") }
        yesButton { $("div.z-messagebox-window button.z-messagebox-btn", 0)}
        noButton  { $("div.z-messagebox-window button.z-messagebox-btn", 1)}

    }

    void clickYes() {
    	yesButton.click();
    }

    void clickNo() {
    	noButton.click();
    }
}