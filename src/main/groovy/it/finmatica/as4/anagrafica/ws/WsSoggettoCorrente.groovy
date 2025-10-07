package it.finmatica.as4.anagrafica.ws

import javax.xml.bind.annotation.XmlAccessType
import javax.xml.bind.annotation.XmlAccessorType
import javax.xml.bind.annotation.XmlElement
import javax.xml.bind.annotation.XmlType


@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "WSSoggettoCorrente")
class WsSoggettoCorrente {
    @XmlElement(required = true, name = "cognome")
    String cognome

    @XmlElement(required = false, name = "nome")
    String nome

    @XmlElement(required = false, name = "sesso")
    String sesso

    @XmlElement(required = false, name = "tipoSoggetto")
    String tipoSoggetto

    @XmlElement(required = false, name = "codiceFiscale")
    String codiceFiscale

    @XmlElement(required = false, name = "partitaIva")
    String partitaIva

    @XmlElement(required = false, name = "partitaIvaCee")
    String partitaIvaCee

    @XmlElement(required = true, name = "dal")
    Date dal

    @XmlElement(required = false, name = "al")
    Date al

    @XmlElement(required = false, name = "codiceFiscaleEstero")
    String codiceFiscaleEstero

    @XmlElement(required = false, name = "dataNascita")
    Date dataNascita

    @XmlElement(required = false, name = "luogoNascita")
    String luogoNascita

    @XmlElement(required = false, name = "comuneNascita")
    String comuneNascita

    @XmlElement(required = false, name = "provinciaNascita")
    String provinciaNascita
}
