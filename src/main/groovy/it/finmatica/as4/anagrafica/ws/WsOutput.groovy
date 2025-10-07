package it.finmatica.as4.anagrafica.ws

import javax.xml.bind.annotation.XmlAccessType
import javax.xml.bind.annotation.XmlAccessorType
import javax.xml.bind.annotation.XmlElement
import javax.xml.bind.annotation.XmlType

@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "WSOutput")
class WsOutput {

    @XmlElement(required = true, name = "codice")
    String codice

    @XmlElement(required = true, name = "esito_operazione")
    String esito_operazione

    @XmlElement(required = false, name = "id_recapito")
    Long idRecapito

    @XmlElement(required = false, name = "id_contatto")
    Long idContatto
}
