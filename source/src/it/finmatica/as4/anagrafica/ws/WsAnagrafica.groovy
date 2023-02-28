package it.finmatica.as4.anagrafica.ws

import javax.xml.bind.annotation.XmlAccessType
import javax.xml.bind.annotation.XmlAccessorType
import javax.xml.bind.annotation.XmlElement
import javax.xml.bind.annotation.XmlType


@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "WsAnagrafica")
class WsAnagrafica {

    @XmlElement(required = false, name = "ni")
    Long ni

    @XmlElement(required = true, name = "dal")
    Date dal

    @XmlElement(required = false, name = "al")
    Date al

    @XmlElement(required = true, name = "cognome")
    String cognome

    @XmlElement(required = false, name = "nome")
    String nome

    @XmlElement(required = false, name = "sesso")
    String sesso

    @XmlElement(required = false, name = "dataNascita")
    Date dataNascita

    @XmlElement(required = false, name = "comuneNascita")
    String comuneNascita

    @XmlElement(required = false, name = "provinciaNascita")
    String provinciaNascita

    @XmlElement(required = false, name = "luogoNascita")
    String luogoNascita

    @XmlElement(required = false, name = "presso")
    String presso

    @XmlElement(required = false, name = "codiceFiscale")
    String codiceFiscale

    @XmlElement(required = false, name = "codiceFiscaleEstero")
    String codiceFiscaleEstero

    @XmlElement(required = false, name = "partitaIva")
    String partitaIva

    @XmlElement(required = false, name = "partitaIvaCee")
    String partitaIvaCee

    @XmlElement(required = false, name = "tipoSoggetto")
    String tipoSoggetto

    @XmlElement(required = false, name = "note")
    String note

    @XmlElement(required = false, name = "indirizzoResidenza")
    String indirizzoResidenza

    @XmlElement(required = false, name = "comuneResidenza")
    String comuneResidenza

    @XmlElement(required = false, name = "provinciaResidenza")
    String provinciaResidenza

    @XmlElement(required = false, name = "capResidenza")
    String capResidenza

    @XmlElement(required = false, name = "descrizioneResidenza")
    String descrizioneResidenza

    @XmlElement(required = false, name = "importanzaResidenza")
    Long importanzaResidenza

    @XmlElement(required = false, name = "indirizzoWeb")
    String indirizzoWeb

    @XmlElement(required = false, name = "noteMail")
    String noteMail

    @XmlElement(required = false, name = "importanzaMail")
    Long importanzaMail

    @XmlElement(required = false, name = "telefonoResidenza")
    String telefonoResidenza

    @XmlElement(required = false, name = "noteTelefonoResidenza")
    String noteTelefonoResidenza

    @XmlElement(required = false, name = "importanzaTelefonoResidenza")
    Long importanzaTelefonoResidenza

    @XmlElement(required = false, name = "faxResidenza")
    String faxResidenza

    @XmlElement(required = false, name = "noteFaxResidenza")
    String noteFaxResidenza

    @XmlElement(required = false, name = "importanzaFaxResidenza")
    Long importanzaFaxResidenza

    @XmlElement(required = false, name = "indirizzoDomicilio")
    String indirizzoDomicilio

    @XmlElement(required = false, name = "descrizioneDomicilio")
    String descrizioneDomicilio

    @XmlElement(required = false, name = "comuneDomicilio")
    String comuneDomicilio

    @XmlElement(required = false, name = "provinciaDomicilio")
    String provinciaDomicilio

    @XmlElement(required = false, name = "capDomicilio")
    String capDomicilio

    @XmlElement(required = false, name = "telefonoDomicilio")
    String telefonoDomicilio

    @XmlElement(required = false, name = "noteTelefonoDomicilio")
    String noteTelefonoDomicilio

    @XmlElement(required = false, name = "importanzaTelefonoDomicilio")
    Long importanzaTelefonoDomicilio

    @XmlElement(required = false, name = "faxDomicilio")
    String faxDomicilio

    @XmlElement(required = false, name = "noteFaxDomicilio")
    String noteFaxDomicilio

    @XmlElement(required = false, name = "importanzaFaxDomicilio")
    Long importanzaFaxDomicilio

//    @XmlElement(required = false, name = "denominazione")
//    String denominazione
}
