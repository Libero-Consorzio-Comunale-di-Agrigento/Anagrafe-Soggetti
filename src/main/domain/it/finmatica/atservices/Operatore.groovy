package it.finmatica.atservices

class Operatore {

    private String operatore
    private String denominazione

    Operatore(String operatore, String denominazione) {
        this.operatore = operatore
        this.denominazione = denominazione
    }

    String getOperatore() {
        return operatore
    }

    String getDenominazione() {
        return denominazione
    }

    void setOperatore(String operatore) {
        this.operatore = operatore
    }

    void setDenominazione(String denominazione) {
        this.denominazione = denominazione
    }
}
