package it.finmatica.as4.anagrafica.ws

import javax.xml.bind.annotation.XmlAccessType
import javax.xml.bind.annotation.XmlAccessorType
import javax.xml.bind.annotation.XmlElement
import javax.xml.bind.annotation.XmlType

@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "WSContatto")
class WsContatto {

    @XmlElement(required = false, name = "idContatto")
    Long idContatto

    @XmlElement(required = false, name = "idRecapito")
    Long idRecapito

    @XmlElement(required = false, name = "tipoContatto")
    String tipoContatto

    @XmlElement(required = true, name = "dal")
    Date dal

    @XmlElement(required = false, name = "al")
    Date al

    @XmlElement(required = true, name = "valore")
    String valore

    @XmlElement(required = false, name = "note")
    String note

    @XmlElement(required = false, name = "importanza")
    Long importanza
}
