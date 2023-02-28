package it.finmatica.as4.anagrafica.ws

import javax.persistence.Column
import javax.xml.bind.annotation.XmlAccessType
import javax.xml.bind.annotation.XmlAccessorType
import javax.xml.bind.annotation.XmlElement
import javax.xml.bind.annotation.XmlType

@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "WsAnagraficaResearch")
class WsAnagraficaResearch {

    @XmlElement(required = false, name = "ni")
    Long ni

    @XmlElement(required = false, name = "dal")
    Date dal

    @XmlElement(required = false, name = "al")
    Date al

    @XmlElement(required = false, name = "cognome")
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

    @XmlElement(required = false, name = "codiceFiscaleEsteroni")
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

    @XmlElement(required = false, name = "id_recapito_residenza")
    Long id_recapito_residenza

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

    @XmlElement(required = false, name = "id_recapito_domicilio")
    Long id_recapito_domicilio

}
