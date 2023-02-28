package it.finmatica.as4.anagrafica.ws

import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.dizionari.Ad4Comune
import it.finmatica.ad4.dizionari.Ad4Provincia
import it.finmatica.ad4.dizionari.Ad4Stato
import it.finmatica.as4.dizionari.As4TipoSoggetto

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.ManyToOne
import javax.persistence.Table
import javax.persistence.Temporal
import javax.persistence.TemporalType

@Table(name = "anagrafe_soggetti_ws")
@Entity
public class AnagrafeSoggettiWs {

    @Id
    private Long ni

    @Temporal(TemporalType.DATE)
    private Date dal
    private String nome
    private String cognome

    @Column(name = "nominativo_ricerca")
    private String nominativoRicerca
    private String sesso

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
    @JoinColumn(name = "stato_nas")
    private Ad4Stato statoNascita

    @Column(name = "luogo_nas")
    private String luogoNascita

    @Column(name = "codice_fiscale")
    private String codiceFiscale

    @Column(name = "codice_fiscale_estero")
    private String codiceFiscaleEstero

    @Column(name = "partita_iva")
    private String partitaIva
    private String cittadinanza
    @Column(name = "gruppo_ling")
    private String gruppoLing

    @Column(name = "indirizzo_res")
    private String indirizzoResidenza

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "provincia_res")
    private Ad4Provincia provinciaResidenza

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "comune_res")
    private Ad4Comune comuneResidenza

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "stato_res")
    private Ad4Stato statoResidenza

    @Column(name = "cap_res")
    private String capResidenza
    private String presso

    @Column(name = "id_recapito_res")
    private Long idRecapitoResidenza

    @Column(name = "indirizzo_dom")
    private String indirizzoDomicilio

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "provincia_dom")
    private Ad4Provincia provinciaDomicilio

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "comune_dom")
    private Ad4Comune comuneDomicilio

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "stato_dom")
    private Ad4Stato statoDomicilio

    @Column(name = "cap_dom")
    private String capDomicilio

    @Column(name = "id_recapito_dom")
    private Long idRecapitoDomicilio

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utente_agg")
    private Ad4Utente utenteAggiornamento

    @Column(name = "data_agg")
    @Temporal(TemporalType.DATE)
    private Date dataAggiornamento

    private String competenza

    @Column(name = "competenza_esclusiva")
    private String competenzaEsclusiva

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tipo_soggetto")
    private As4TipoSoggetto tipoSoggetto

    @Column(name = "flag_trg")
    private String flagTrigger

    @Column(name = "stato_cee")
    private String statoCee

    @Column(name = "partita_iva_cee")
    private String partitaIvaCee

    @Column(name = "fine_validita")
    @Temporal(TemporalType.DATE)
    private Date fineValidita

    @Temporal(TemporalType.DATE)
    private Date al

    private String denominazione
    private String note
    private String utente

    @Column(name = "fax_dom")
    private String faxDom
    @Column(name = "fax_res")
    private String faxRes
    @Column(name = "id_contatto_fax_dom")
    private Long idContattoFaxDom
    @Column(name = "id_contatto_fax_res")
    private Long idContattoFaxRes
    @Column(name = "id_contatto_indirizzo_web")
    private Long idContattoIndirizzoWeb
    @Column(name = "id_contatto_tel_dom")
    private Long idContattoTelDom
    @Column(name = "id_contatto_tel_res")
    private Long idContattoTelRes
    @Column(name = "indirizzo_web")
    private String indirizzoWeb
    @Column(name = "tel_dom")
    private String telDom
    @Column(name = "tel_res")
    private String telRes



    Long getNi() {
        return ni
    }

    void setNi(Long ni) {
        this.ni = ni
    }

    Date getDal() {
        return dal
    }

    void setDal(Date dal) {
        this.dal = dal
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

    String getNominativoRicerca() {
        return nominativoRicerca
    }

    void setNominativoRicerca(String nominativoRicerca) {
        this.nominativoRicerca = nominativoRicerca
    }

    String getSesso() {
        return sesso
    }

    void setSesso(String sesso) {
        this.sesso = sesso
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

    Ad4Stato getStatoNascita() {
        return statoNascita
    }

    void setStatoNascita(Ad4Stato statoNascita) {
        this.statoNascita = statoNascita
    }

    String getLuogoNascita() {
        return luogoNascita
    }

    void setLuogoNascita(String luogoNascita) {
        this.luogoNascita = luogoNascita
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

    String getCittadinanza() {
        return cittadinanza
    }

    void setCittadinanza(String cittadinanza) {
        this.cittadinanza = cittadinanza
    }

    String getGruppoLing() {
        return gruppoLing
    }

    void setGruppoLing(String gruppoLing) {
        this.gruppoLing = gruppoLing
    }

    String getIndirizzoResidenza() {
        return indirizzoResidenza
    }

    void setIndirizzoResidenza(String indirizzoResidenza) {
        this.indirizzoResidenza = indirizzoResidenza
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

    String getCapResidenza() {
        return capResidenza
    }

    void setCapResidenza(String capResidenza) {
        this.capResidenza = capResidenza
    }

    String getPresso() {
        return presso
    }

    void setPresso(String presso) {
        this.presso = presso
    }

    Long getIdRecapitoResidenza() {
        return idRecapitoResidenza
    }

    void setIdRecapitoResidenza(Long idRecapitoResidenza) {
        this.idRecapitoResidenza = idRecapitoResidenza
    }

    String getIndirizzoDomicilio() {
        return indirizzoDomicilio
    }

    void setIndirizzoDomicilio(String indirizzoDomicilio) {
        this.indirizzoDomicilio = indirizzoDomicilio
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

    String getCapDomicilio() {
        return capDomicilio
    }

    void setCapDomicilio(String capDomicilio) {
        this.capDomicilio = capDomicilio
    }

    Long getIdRecapitoDomicilio() {
        return idRecapitoDomicilio
    }

    void setIdRecapitoDomicilio(Long idRecapitoDomicilio) {
        this.idRecapitoDomicilio = idRecapitoDomicilio
    }

    Ad4Utente getUtenteAggiornamento() {
        return utenteAggiornamento
    }

    void setUtenteAggiornamento(Ad4Utente utenteAggiornamento) {
        this.utenteAggiornamento = utenteAggiornamento
    }

    Date getDataAggiornamento() {
        return dataAggiornamento
    }

    void setDataAggiornamento(Date dataAggiornamento) {
        this.dataAggiornamento = dataAggiornamento
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

    As4TipoSoggetto getTipoSoggetto() {
        return tipoSoggetto
    }

    void setTipoSoggetto(As4TipoSoggetto tipoSoggetto) {
        this.tipoSoggetto = tipoSoggetto
    }

    String getFlagTrigger() {
        return flagTrigger
    }

    void setFlagTrigger(String flagTrigger) {
        this.flagTrigger = flagTrigger
    }

    String getStatoCee() {
        return statoCee
    }

    void setStatoCee(String statoCee) {
        this.statoCee = statoCee
    }

    String getPartitaIvaCee() {
        return partitaIvaCee
    }

    void setPartitaIvaCee(String partitaIvaCee) {
        this.partitaIvaCee = partitaIvaCee
    }

    Date getFineValidita() {
        return fineValidita
    }

    void setFineValidita(Date fineValidita) {
        this.fineValidita = fineValidita
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

    String getNote() {
        return note
    }

    void setNote(String note) {
        this.note = note
    }

    String getUtente() {
        return utente
    }

    void setUtente(String utente) {
        this.utente = utente
    }

    String getFaxDom() {
        return faxDom
    }

    void setFaxDom(String faxDom) {
        this.faxDom = faxDom
    }

    String getFaxRes() {
        return faxRes
    }

    void setFaxRes(String faxRes) {
        this.faxRes = faxRes
    }

    Long getIdContattoFaxDom() {
        return idContattoFaxDom
    }

    void setIdContattoFaxDom(Long idContattoFaxDom) {
        this.idContattoFaxDom = idContattoFaxDom
    }

    Long getIdContattoFaxRes() {
        return idContattoFaxRes
    }

    void setIdContattoFaxRes(Long idContattoFaxRes) {
        this.idContattoFaxRes = idContattoFaxRes
    }

    Long getIdContattoIndirizzoWeb() {
        return idContattoIndirizzoWeb
    }

    void setIdContattoIndirizzoWeb(Long idContattoIndirizzoWeb) {
        this.idContattoIndirizzoWeb = idContattoIndirizzoWeb
    }

    Long getIdContattoTelDom() {
        return idContattoTelDom
    }

    void setIdContattoTelDom(Long idContattoTelDom) {
        this.idContattoTelDom = idContattoTelDom
    }

    Long getIdContattoTelRes() {
        return idContattoTelRes
    }

    void setIdContattoTelRes(Long idContattoTelRes) {
        this.idContattoTelRes = idContattoTelRes
    }

    String getIndirizzoWeb() {
        return indirizzoWeb
    }

    void setIndirizzoWeb(String indirizzoWeb) {
        this.indirizzoWeb = indirizzoWeb
    }

    String getTelDom() {
        return telDom
    }

    void setTelDom(String telDom) {
        this.telDom = telDom
    }

    String getTelRes() {
        return telRes
    }

    void setTelRes(String telRes) {
        this.telRes = telRes
    }
}
