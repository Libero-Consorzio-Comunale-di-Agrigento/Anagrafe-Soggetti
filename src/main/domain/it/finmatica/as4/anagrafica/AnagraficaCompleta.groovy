package it.finmatica.as4.anagrafica

import it.finmatica.ad4.dizionari.Ad4Comune
import it.finmatica.ad4.dizionari.Ad4Provincia
import it.finmatica.ad4.dizionari.Ad4Stato
import it.finmatica.anagrafica.AnagraficaId
import it.finmatica.as4.dizionari.As4TipoSoggetto

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.Id
import javax.persistence.IdClass
import javax.persistence.JoinColumn
import javax.persistence.ManyToOne
import javax.persistence.Table
import javax.persistence.Temporal
import javax.persistence.TemporalType

@Table(name = "anagrafici_res_dom")
@Entity
@IdClass(AnagraficaId.class)
class AnagraficaCompleta {

    @Id
    private Long ni

    @Id
    @Temporal(TemporalType.DATE)
    private Date dal

    // dati anagrafici
    private String nome
    private String cognome
    private String sesso

    @Column(name = "luogo_nas")
    private String luogoNascita

    @Column(name = "data_nas")
    @Temporal(TemporalType.DATE)
    private Date dataNascita

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "provincia_nas")
    private Ad4Provincia provinciaNascita

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "comune_nas")
    private Ad4Comune comuneNascita

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tipo_soggetto")
    private As4TipoSoggetto tipoSoggetto

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "stato_nas")
    private Ad4Stato statoNascita

    // codici e note
    @Column(name = "codice_fiscale")
    private String codiceFiscale

    @Column(name = "codice_fiscale_estero")
    private String codiceFiscaleEstero

    @Column(name = "partita_iva")
    private String partitaIva

    @Column(name = "partita_iva_cee")
    private String partitaIvaCee

    @Column(name = "mail")
    private String indirizzoWeb

    @Column(name = "note_anag")
    private String note

    private Long importanza

    @Column(name = "note_mail")
    private String noteMail

    @Column(name = "importanza_mail")
    private Long importanzaMail

    // indirizzo di residenza
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "provincia_res")
    private Ad4Provincia provinciaResidenza

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "comune_res")
    private Ad4Comune comuneResidenza

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "stato_res")
    private Ad4Stato statoResidenza

    @Column(name = "indirizzo_res")
    private String indirizzoResidenza

    @Column(name = "cap_res")
    private String capResidenza

    @Column(name = "tel_res")
    private String telefonoResidenza

    @Column(name = "fax_res")
    private String faxResidenza

    private String cittadinanza

    @Column(name = "descrizione_residenza")
    private String descrizioneResidenza

    @Column(name = "note_tel_res")
    private String noteTelefonoResidenza

    @Column(name = "importanza_tel_res")
    private Long importanzaTelefonoResidenza

    @Column(name = "note_fax_res")
    private String noteFaxResidenza

    @Column(name = "importanza_fax_res")
    private Long importanzaFaxResidenza

    // indirizzo di domicilio
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "provincia_dom")
    private Ad4Provincia provinciaDomicilio

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "comune_dom")
    private Ad4Comune comuneDomicilio

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "stato_dom")
    private Ad4Stato statoDomicilio

    @Column(name = "indirizzo_dom")
    private String indirizzoDomicilio

    private String presso

    @Column(name = "cap_dom")
    private String capDomicilio

    @Column(name = "tel_dom")
    private String telefonoDomicilio

    @Column(name = "fax_dom")
    private String faxDomicilio

    @Column(name = "descrizione_dom")
    private String descrizioneDomicilio

    @Column(name = "note_tel_dom")
    private String noteTelefonoDomicilio

    @Column(name = "importanza_tel_dom")
    private Long importanzaTelefonoDomicilio

    @Column(name = "note_fax_dom")
    private String noteFaxDomicilio

    // dati di applicativo
    private String competenza

    @Column(name = "competenza_esclusiva")
    private String competenzaEsclusiva

//    @Temporal(TemporalType.DATE)
//    private Date dal

    @Temporal(TemporalType.DATE)
    private Date al

    private String denominazione

    Long getNi() {
        return ni
    }

    void setNi(Long ni) {
        this.ni = ni
    }

    String getNome() {
        return nome
    }

    void setNome(String nome) {
        this.nome = nome
    }

    String getCognome() {
        return cognome
    }

    void setCognome(String cognome) {
        this.cognome = cognome
    }

    String getSesso() {
        return sesso
    }

    void setSesso(String sesso) {
        this.sesso = sesso
    }

    String getLuogoNascita() {
        return luogoNascita
    }

    void setLuogoNascita(String luogoNascita) {
        this.luogoNascita = luogoNascita
    }

    Date getDataNascita() {
        return dataNascita
    }

    void setDataNascita(Date dataNascita) {
        this.dataNascita = dataNascita
    }

    Ad4Provincia getProvinciaNascita() {
        return provinciaNascita
    }

    void setProvinciaNascita(Ad4Provincia provinciaNascita) {
        this.provinciaNascita = provinciaNascita
    }

    Ad4Comune getComuneNascita() {
        return comuneNascita
    }

    void setComuneNascita(Ad4Comune comuneNascita) {
        this.comuneNascita = comuneNascita
    }

    As4TipoSoggetto getTipoSoggetto() {
        return tipoSoggetto
    }

    void setTipoSoggetto(As4TipoSoggetto tipoSoggetto) {
        this.tipoSoggetto = tipoSoggetto
    }

    Ad4Stato getStatoNascita() {
        return statoNascita
    }

    void setStatoNascita(Ad4Stato statoNascita) {
        this.statoNascita = statoNascita
    }

    String getCodiceFiscale() {
        return codiceFiscale
    }

    void setCodiceFiscale(String codiceFiscale) {
        this.codiceFiscale = codiceFiscale
    }

    String getCodiceFiscaleEstero() {
        return codiceFiscaleEstero
    }

    void setCodiceFiscaleEstero(String codiceFiscaleEstero) {
        this.codiceFiscaleEstero = codiceFiscaleEstero
    }

    String getPartitaIva() {
        return partitaIva
    }

    void setPartitaIva(String partitaIva) {
        this.partitaIva = partitaIva
    }

    String getPartitaIvaCee() {
        return partitaIvaCee
    }

    void setPartitaIvaCee(String partitaIvaCee) {
        this.partitaIvaCee = partitaIvaCee
    }

    String getIndirizzoWeb() {
        return indirizzoWeb
    }

    void setIndirizzoWeb(String indirizzoWeb) {
        this.indirizzoWeb = indirizzoWeb
    }

    String getNote() {
        return note
    }

    void setNote(String note) {
        this.note = note
    }

    Long getImportanza() {
        return importanza
    }

    void setImportanza(Long importanza) {
        this.importanza = importanza
    }

    String getNoteMail() {
        return noteMail
    }

    void setNoteMail(String noteMail) {
        this.noteMail = noteMail
    }

    Long getImportanzaMail() {
        return importanzaMail
    }

    void setImportanzaMail(Long importanzaMail) {
        this.importanzaMail = importanzaMail
    }

    Ad4Provincia getProvinciaResidenza() {
        return provinciaResidenza
    }

    void setProvinciaResidenza(Ad4Provincia provinciaResidenza) {
        this.provinciaResidenza = provinciaResidenza
    }

    Ad4Comune getComuneResidenza() {
        return comuneResidenza
    }

    void setComuneResidenza(Ad4Comune comuneResidenza) {
        this.comuneResidenza = comuneResidenza
    }

    Ad4Stato getStatoResidenza() {
        return statoResidenza
    }

    void setStatoResidenza(Ad4Stato statoResidenza) {
        this.statoResidenza = statoResidenza
    }

    String getIndirizzoResidenza() {
        return indirizzoResidenza
    }

    void setIndirizzoResidenza(String indirizzoResidenza) {
        this.indirizzoResidenza = indirizzoResidenza
    }

    String getCapResidenza() {
        return capResidenza
    }

    void setCapResidenza(String capResidenza) {
        this.capResidenza = capResidenza
    }

    String getTelefonoResidenza() {
        return telefonoResidenza
    }

    void setTelefonoResidenza(String telefonoResidenza) {
        this.telefonoResidenza = telefonoResidenza
    }

    String getFaxResidenza() {
        return faxResidenza
    }

    void setFaxResidenza(String faxResidenza) {
        this.faxResidenza = faxResidenza
    }

    String getCittadinanza() {
        return cittadinanza
    }

    void setCittadinanza(String cittadinanza) {
        this.cittadinanza = cittadinanza
    }

    String getDescrizioneResidenza() {
        return descrizioneResidenza
    }

    void setDescrizioneResidenza(String descrizioneResidenza) {
        this.descrizioneResidenza = descrizioneResidenza
    }

    String getNoteTelefonoResidenza() {
        return noteTelefonoResidenza
    }

    void setNoteTelefonoResidenza(String noteTelefonoResidenza) {
        this.noteTelefonoResidenza = noteTelefonoResidenza
    }

    Long getImportanzaTelefonoResidenza() {
        return importanzaTelefonoResidenza
    }

    void setImportanzaTelefonoResidenza(Long importanzaTelefonoResidenza) {
        this.importanzaTelefonoResidenza = importanzaTelefonoResidenza
    }

    String getNoteFaxResidenza() {
        return noteFaxResidenza
    }

    void setNoteFaxResidenza(String noteFaxResidenza) {
        this.noteFaxResidenza = noteFaxResidenza
    }

    Long getImportanzaFaxResidenza() {
        return importanzaFaxResidenza
    }

    void setImportanzaFaxResidenza(Long importanzaFaxResidenza) {
        this.importanzaFaxResidenza = importanzaFaxResidenza
    }

    Ad4Provincia getProvinciaDomicilio() {
        return provinciaDomicilio
    }

    void setProvinciaDomicilio(Ad4Provincia provinciaDomicilio) {
        this.provinciaDomicilio = provinciaDomicilio
    }

    Ad4Comune getComuneDomicilio() {
        return comuneDomicilio
    }

    void setComuneDomicilio(Ad4Comune comuneDomicilio) {
        this.comuneDomicilio = comuneDomicilio
    }

    Ad4Stato getStatoDomicilio() {
        return statoDomicilio
    }

    void setStatoDomicilio(Ad4Stato statoDomicilio) {
        this.statoDomicilio = statoDomicilio
    }

    String getIndirizzoDomicilio() {
        return indirizzoDomicilio
    }

    void setIndirizzoDomicilio(String indirizzoDomicilio) {
        this.indirizzoDomicilio = indirizzoDomicilio
    }

    String getPresso() {
        return presso
    }

    void setPresso(String presso) {
        this.presso = presso
    }

    String getCapDomicilio() {
        return capDomicilio
    }

    void setCapDomicilio(String capDomicilio) {
        this.capDomicilio = capDomicilio
    }

    String getTelefonoDomicilio() {
        return telefonoDomicilio
    }

    void setTelefonoDomicilio(String telefonoDomicilio) {
        this.telefonoDomicilio = telefonoDomicilio
    }

    String getFaxDomicilio() {
        return faxDomicilio
    }

    void setFaxDomicilio(String faxDomicilio) {
        this.faxDomicilio = faxDomicilio
    }

    String getDescrizioneDomicilio() {
        return descrizioneDomicilio
    }

    void setDescrizioneDomicilio(String descrizioneDomicilio) {
        this.descrizioneDomicilio = descrizioneDomicilio
    }

    String getNoteTelefonoDomicilio() {
        return noteTelefonoDomicilio
    }

    void setNoteTelefonoDomicilio(String noteTelefonoDomicilio) {
        this.noteTelefonoDomicilio = noteTelefonoDomicilio
    }

    Long getImportanzaTelefonoDomicilio() {
        return importanzaTelefonoDomicilio
    }

    void setImportanzaTelefonoDomicilio(Long importanzaTelefonoDomicilio) {
        this.importanzaTelefonoDomicilio = importanzaTelefonoDomicilio
    }

    String getNoteFaxDomicilio() {
        return noteFaxDomicilio
    }

    void setNoteFaxDomicilio(String noteFaxDomicilio) {
        this.noteFaxDomicilio = noteFaxDomicilio
    }

    String getCompetenza() {
        return competenza
    }

    void setCompetenza(String competenza) {
        this.competenza = competenza
    }

    String getCompetenzaEsclusiva() {
        return competenzaEsclusiva
    }

    void setCompetenzaEsclusiva(String competenzaEsclusiva) {
        this.competenzaEsclusiva = competenzaEsclusiva
    }

    Date getDal() {
        return dal
    }

    void setDal(Date dal) {
        this.dal = dal
    }

    Date getAl() {
        return al
    }

    void setAl(Date al) {
        this.al = al
    }

    String getDenominazione() {
        return denominazione
    }

    void setDenominazione(String denominazione) {
        this.denominazione = denominazione
    }
}
