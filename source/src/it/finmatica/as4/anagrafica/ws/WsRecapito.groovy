package it.finmatica.as4.anagrafica.ws

import javax.xml.bind.annotation.XmlAccessType
import javax.xml.bind.annotation.XmlAccessorType
import javax.xml.bind.annotation.XmlElement
import javax.xml.bind.annotation.XmlType


@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "WSRecapiti")
class WsRecapito {

    @XmlElement(required = false, name = "idRecapito")
    Long idRecapito

    @XmlElement(required = false, name = "ni")
    Long ni

    @XmlElement(required = false, name = "tipoRecapito")
    String tipoRecapito

    @XmlElement(required = true, name = "dal")
    Date dal

    @XmlElement(required = false, name = "al")
    Date al

    @XmlElement(required = false, name = "descrizione")
    String descrizione

    @XmlElement(required = false, name = "indirizzo")
    String indirizzo

    @XmlElement(required = false, name = "provincia")
    String provincia

    @XmlElement(required = false, name = "comune")
    String comune

    @XmlElement(required = false, name = "cap")
    String cap

    @XmlElement(required = false, name = "presso")
    String presso

    @XmlElement(required = false, name = "importanza")
    Long importanza
}
