package it.finmatica.anagrafica

import javax.persistence.Temporal
import javax.persistence.TemporalType

class AnagraficaId implements Serializable {

    private Long ni
    @Temporal(TemporalType.DATE)
    private Date dal

    public AnagraficaId(){}

    public AnagraficaId (Long ni, Date dal){
        this.ni = ni
        this.dal = dal
    }
}
