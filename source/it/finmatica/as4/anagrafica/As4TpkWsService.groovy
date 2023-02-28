package it.finmatica.as4.anagrafica

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.ad4.security.SpringSecurityService
import groovy.sql.Sql
import it.finmatica.as4.anagrafica.ws.AnagrafeSoggettiWs
import it.finmatica.as4.exceptions.As4SqlRuntimeException
import org.apache.commons.lang.time.DateUtils
import org.hibernate.SessionFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.zkoss.zk.ui.select.annotation.WireVariable

import java.sql.SQLException
import javax.sql.DataSource

import org.hibernate.criterion.CriteriaSpecification
import org.springframework.transaction.annotation.Transactional

import java.sql.Timestamp

@Transactional
@Slf4j
@Service
class As4TpkWsService {

    @Autowired
    DataSource dataSource
    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    SessionFactory sessionFactory

    void pkgInsertAnagrafe(AnagraficaCompleta soggetto) {

        Map res = [:]

        String utente = springSecurityService?.currentUser?.utente

        /** Campi NASCITA **/

        def codiceComuneNascita
        def codiceProvinciaNascita

        if (soggetto.comuneNascita == null)
            codiceComuneNascita = null
        else if (soggetto.comuneNascita?.comune != 0)
            codiceComuneNascita = (soggetto.comuneNascita?.comune) ?: -999
        else
            codiceComuneNascita = 0

        if (soggetto.provinciaNascita == null)
            codiceProvinciaNascita = soggetto.statoNascita?.id
        else
            codiceProvinciaNascita = (soggetto.provinciaNascita?.id ?: soggetto.comuneNascita?.provincia?.id) ?: -999

        /** Campi RESIDENZA **/
        def codiceComuneResidenza
        def codiceProvinciaResidenza

        if (soggetto.comuneResidenza == null)
            codiceComuneResidenza = null
        else if (soggetto.comuneResidenza?.comune != 0)
            codiceComuneResidenza = (soggetto.comuneResidenza?.comune) ?: -999
        else
            codiceComuneResidenza = 0

        if (soggetto.provinciaResidenza == null)
            codiceProvinciaResidenza = soggetto.statoResidenza?.id
        else
            codiceProvinciaResidenza = (soggetto.provinciaResidenza?.id ?: soggetto.comuneResidenza?.provincia?.id) ?: -999

        /** Campi DOMICILIO **/
        def codiceComuneDomicilio
        def codiceProvinciaDomicilio

        if (soggetto.comuneDomicilio == null)
            codiceComuneDomicilio = null
        else if (soggetto.comuneDomicilio?.comune != 0)
            codiceComuneDomicilio = (soggetto.comuneDomicilio?.comune) ?: -999
        else
            codiceComuneDomicilio = 0

        if (soggetto.provinciaDomicilio == null)
            codiceProvinciaDomicilio = soggetto.statoDomicilio?.id
        else
            codiceProvinciaDomicilio = (soggetto.provinciaDomicilio?.id ?: soggetto.comuneDomicilio?.provincia?.id) ?: -999

        Long idAnagrafica = 0
        try {
            Sql sql = new Sql(dataSource)
            sql.call("""{? = call anagrafe_soggetti_ws_pkg.ins_anag_dom_e_res_e_mail(
						 ?			--p_ni                              --IN ANAGRAFICI.ni%TYPE default NULL,
					   , ?  	    --p_dal                             --IN ANAGRAFICI.dal%TYPE,
					   , ?   	    --p_al                              --IN ANAGRAFICI.al%TYPE DEFAULT NULL,
					   , upper(?)   --p_cognome                         --IN ANAGRAFICI.cognome%TYPE,
					   , upper(?)	--p_nome                            --IN ANAGRAFICI.nome%TYPE DEFAULT NULL,
					   , ?   		--p_sesso                           --IN ANAGRAFICI.sesso%TYPE DEFAULT NULL,
					   , ?			--p_data_nas                        --IN ANAGRAFICI.data_nas%TYPE DEFAULT NULL,
					   , ?	        --p_provincia_nas                   --IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL,
					   , ?          --p_comune_nas                      --IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL,
					   , upper(?)   --p_luogo_nas                       --IN ANAGRAFICI.luogo_nas%TYPE DEFAULT NULL,
					   , upper(?)	--p_codice_fiscale                  --IN ANAGRAFICI.codice_fiscale%TYPE DEFAULT NULL,
					   , upper(?)	--p_codice_fiscale_estero           --IN ANAGRAFICI.codice_fiscale_estero%TYPE DEFAULT NULL,
					   , ?  		--p_partita_iva                     --IN ANAGRAFICI.partita_iva%TYPE DEFAULT NULL,
					   , ?		   	--p_cittadinanza                    --IN ANAGRAFICI.cittadinanza%TYPE DEFAULT NULL,
					   , ?			--p_gruppo_ling                     --IN ANAGRAFICI.gruppo_ling%TYPE DEFAULT NULL,
					   , ?          --p_competenza                      --IN ANAGRAFICI.competenza%TYPE DEFAULT NULL,
					   , ?   	    --p_competenza_esclusiva            --IN ANAGRAFICI.competenza_esclusiva%TYPE DEFAULT NULL,
					   , ?          --p_tipo_soggetto                   --IN ANAGRAFICI.tipo_soggetto%TYPE DEFAULT NULL,
					   , ?          --p_stato_cee                       --IN ANAGRAFICI.stato_cee%TYPE DEFAULT NULL,
					   , ?   	    --p_partita_iva_cee                 --IN ANAGRAFICI.partita_iva_cee%TYPE DEFAULT NULL,
					   , ?  	    --p_fine_validita                   --IN ANAGRAFICI.fine_validita%TYPE DEFAULT NULL,
					   , ?   	    --p_stato_soggetto                  --IN ANAGRAFICI.stato_soggetto%TYPE DEFAULT 'U',
					   , ?			--p_denominazione           		--IN ANAGRAFICI.denominazione%TYPE DEFAULT NULL,
					   , ?		   	--p_note_anag                       --IN ANAGRAFICI.note%TYPE DEFAULT NULL,
                       , ?          --p_descrizione_residenza           --in RECAPITI.descrizione%type default null --p_descrizione
                       , ? 			--p_indirizzo_res                   --in RECAPITI.indirizzo%type default null
                       , ?          --p_provincia_res           	    --IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL
                       , ?          --p_comune_res              		--IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL
                       , ?          --p_cap_res  						--in RECAPITI.cap%type default null
                       , ?          --p_presso  						--in RECAPITI.presso%type default null
                       , ?          --p_importanza  					--in RECAPITI.importanza%type default null
                       , ?          --p_mail  							--in CONTATTI.valore%type  default null-- p_valore
                       , ?          --p_note_mail  						--in CONTATTI.note%type default null
                       , ?          --p_importanza_mail  				--in CONTATTI.importanza%type default null
                       , ?          --p_tel_res  						--in CONTATTI.valore%type  default null-- p_valore
                       , ?          --p_note_tel_res  					--in CONTATTI.note%type default null
                       , ?          --p_importanza_tel_res  			--in CONTATTI.importanza%type default null
                       , ?          --p_fax_res  						--in CONTATTI.valore%type  default null-- p_valore
                   	   , ?          --p_note_fax_res  					--in CONTATTI.note%type default null
                       , ?          --p_importanza_fax_res  			--in CONTATTI.importanza%type default null
                       , ?          --p_descrizione_dom  				--in RECAPITI.descrizione%type default null --p_descrizione
                       , ?          --p_indirizzo_dom  					--in RECAPITI.indirizzo%type default null
                       , ?          --p_provincia_dom           		--IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL
                       , ?          --p_comune_dom              		--IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL
                       , ?          --p_cap_dom  						--in RECAPITI.cap%type default null
                       , ?          --p_tel_dom  						--in CONTATTI.valore%type  default null-- p_valore
                       , ?          --p_note_tel_dom  					--in CONTATTI.note%type default null
                       , ?          --p_importanza_tel_dom  			--in CONTATTI.importanza%type default null
                       , ?          --p_fax_dom  						--in CONTATTI.valore%type  default null-- p_valore
                       , ?          --p_note_fax_dom  					--in CONTATTI.note%type default null
                       , ?          --p_utente                  		--IN ANAGRAFICI.utente%TYPE DEFAULT NULL
                       , ?          --p_data_agg                		--IN ANAGRAFICI.data_agg%TYPE DEFAULT SYSDATE
                       , ? 			--p_batch                      		--NUMBER DEFAULT 1           -- 0 = NON batch
					) }""",
                    [
                            Sql.NUMERIC
                            , null
                            , (soggetto.dal ? new java.sql.Date(soggetto.dal.time) : null)
                            , (soggetto.al ? new java.sql.Date(soggetto.al.time) : null)
                            , soggetto.cognome
                            , soggetto.nome
                            , soggetto.sesso
                            , (soggetto.dataNascita ? new java.sql.Date(soggetto.dataNascita.time) : null)
                            , codiceProvinciaNascita
                            , codiceComuneNascita
                            , soggetto.luogoNascita
                            , soggetto.codiceFiscale
                            , soggetto.codiceFiscaleEstero
                            , soggetto.partitaIva
                            , soggetto.cittadinanza
                            , null
                            , soggetto.competenza
                            , soggetto.competenzaEsclusiva
                            , soggetto.tipoSoggetto?.tipoSoggetto
                            , null
                            , soggetto.partitaIvaCee
                            , null
                            , null
                            , soggetto.denominazione
                            , soggetto.note
                            , soggetto.descrizioneResidenza
                            , soggetto.indirizzoResidenza
                            , codiceProvinciaResidenza
                            , codiceComuneResidenza
                            , soggetto.capResidenza
                            , soggetto.presso
                            , soggetto.importanza
                            , soggetto.indirizzoWeb
                            , soggetto.noteMail
                            , soggetto.importanzaMail
                            , soggetto.telefonoResidenza
                            , soggetto.noteTelefonoResidenza
                            , soggetto.importanzaTelefonoResidenza
                            , soggetto.faxResidenza
                            , soggetto.noteFaxResidenza
                            , soggetto.importanzaFaxResidenza
                            , soggetto.descrizioneDomicilio
                            , soggetto.indirizzoDomicilio
                            , codiceProvinciaDomicilio
                            , codiceComuneDomicilio
                            , soggetto.capDomicilio
                            , soggetto.telefonoDomicilio
                            , soggetto.noteTelefonoDomicilio
                            , soggetto.importanzaTelefonoDomicilio
                            , soggetto.faxDomicilio
                            , soggetto.noteFaxDomicilio
                            , utente
                            , new java.sql.Date((new Date()).time)
                            , 1
                    ]) { BigDecimal id -> idAnagrafica = id.longValue()
            }
//            soggetto.ni = idAnagrafica
//            soggetto.refresh()

            soggetto.ni = idAnagrafica
            soggetto.dal = (soggetto.dal ? DateUtils.truncate(soggetto.dal, Calendar.DATE) : null)
            soggetto.al = (soggetto.al ? DateUtils.truncate(soggetto.al, Calendar.DATE) : null)
            soggetto.dataNascita = (soggetto.dataNascita ? DateUtils.truncate(soggetto.dataNascita, Calendar.DATE) : null)
            sessionFactory.getCurrentSession().refresh(soggetto)
//            soggetto.ni = anagraficaCompleta.ni
//            AnagraficaCompleta anagraficaCompleta = sessionFactory.getCurrentSession().get(AnagraficaCompleta, idAnagrafica)
        } catch (SQLException e) {
            throw new As4SqlRuntimeException(e)
        }

    }

    void pkgUpdateAnagrafe(AnagraficaCompleta soggetto) {

        Sql sql = new Sql(dataSource)
        Map res = [:]
        String utente = (springSecurityService.currentUser)?.utente

        /** Campi NASCITA **/

        def codiceComuneNascita
        def codiceProvinciaNascita

        if (soggetto.comuneNascita == null)
            codiceComuneNascita = null
        else if (soggetto.comuneNascita?.comune != 0)
            codiceComuneNascita = (soggetto.comuneNascita?.comune) ?: -999
        else
            codiceComuneNascita = 0

        if (soggetto.provinciaNascita == null)
            codiceProvinciaNascita = soggetto.statoNascita?.id
        else
            codiceProvinciaNascita = (soggetto.provinciaNascita?.id ?: soggetto.comuneNascita?.provincia?.id) ?: -999

        /** Campi RESIDENZA **/
        def codiceComuneResidenza
        def codiceProvinciaResidenza

        if (soggetto.comuneResidenza == null)
            codiceComuneResidenza = null
        else if (soggetto.comuneResidenza?.comune != 0)
            codiceComuneResidenza = (soggetto.comuneResidenza?.comune) ?: -999
        else
            codiceComuneResidenza = 0

        if (soggetto.provinciaResidenza == null)
            codiceProvinciaResidenza = soggetto.statoResidenza?.id
        else
            codiceProvinciaResidenza = (soggetto.provinciaResidenza?.id ?: soggetto.comuneResidenza?.provincia?.id) ?: -999

        /** Campi DOMICILIO **/
        def codiceComuneDomicilio
        def codiceProvinciaDomicilio

        if (soggetto.comuneDomicilio == null)
            codiceComuneDomicilio = null
        else if (soggetto.comuneDomicilio?.comune != 0)
            codiceComuneDomicilio = (soggetto.comuneDomicilio?.comune) ?: -999
        else
            codiceComuneDomicilio = 0

        if (soggetto.provinciaDomicilio == null)
            codiceProvinciaDomicilio = soggetto.statoDomicilio?.id
        else
            codiceProvinciaDomicilio = (soggetto.provinciaDomicilio?.id ?: soggetto.comuneDomicilio?.provincia?.id) ?: -999

        Long idAnagrafica = 0
        try {
            sql.call("""{? = call anagrafici_pkg.upd_anag_dom_e_res_e_mail(
					   	 ?			--p_ni                              --IN ANAGRAFICI.ni%TYPE default NULL,
					   , ?  	    --p_dal                             --IN ANAGRAFICI.dal%TYPE,
					   , ?   	    --p_al                              --IN ANAGRAFICI.al%TYPE DEFAULT NULL,
					   , upper(?)   --p_cognome                         --IN ANAGRAFICI.cognome%TYPE,
					   , upper(?)	--p_nome                            --IN ANAGRAFICI.nome%TYPE DEFAULT NULL,
					   , ?   		--p_sesso                           --IN ANAGRAFICI.sesso%TYPE DEFAULT NULL,
					   , ?			--p_data_nas                        --IN ANAGRAFICI.data_nas%TYPE DEFAULT NULL,
					   , ?	        --p_provincia_nas                   --IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL,
					   , ?          --p_comune_nas                      --IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL,
					   , upper(?)   --p_luogo_nas                       --IN ANAGRAFICI.luogo_nas%TYPE DEFAULT NULL,
					   , upper(?)	--p_codice_fiscale                  --IN ANAGRAFICI.codice_fiscale%TYPE DEFAULT NULL,
					   , upper(?)	--p_codice_fiscale_estero           --IN ANAGRAFICI.codice_fiscale_estero%TYPE DEFAULT NULL,
					   , ?  		--p_partita_iva                     --IN ANAGRAFICI.partita_iva%TYPE DEFAULT NULL,
					   , ?		   	--p_cittadinanza                    --IN ANAGRAFICI.cittadinanza%TYPE DEFAULT NULL,
					   , ?			--p_gruppo_ling                     --IN ANAGRAFICI.gruppo_ling%TYPE DEFAULT NULL,
					   , ?          --p_competenza                      --IN ANAGRAFICI.competenza%TYPE DEFAULT NULL,
					   , ?   	    --p_competenza_esclusiva            --IN ANAGRAFICI.competenza_esclusiva%TYPE DEFAULT NULL,
					   , ?          --p_tipo_soggetto                   --IN ANAGRAFICI.tipo_soggetto%TYPE DEFAULT NULL,
					   , ?          --p_stato_cee                       --IN ANAGRAFICI.stato_cee%TYPE DEFAULT NULL,
					   , ?   	    --p_partita_iva_cee                 --IN ANAGRAFICI.partita_iva_cee%TYPE DEFAULT NULL,
					   , ?  	    --p_fine_validita                   --IN ANAGRAFICI.fine_validita%TYPE DEFAULT NULL,
					   , ?   	    --p_stato_soggetto                  --IN ANAGRAFICI.stato_soggetto%TYPE DEFAULT 'U',
					   , ?   	    --p_denominazione               
					   , ?		   	--p_note_anag                       --IN ANAGRAFICI.note%TYPE DEFAULT NULL,
                       , ?          --p_descrizione_residenza           --in RECAPITI.descrizione%type default null --p_descrizione
                       , ? 			--p_indirizzo_res                   --in RECAPITI.indirizzo%type default null
                       , ?          --p_provincia_res           	    --IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL
                       , ?          --p_comune_res              		--IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL
                       , ?          --p_cap_res  						--in RECAPITI.cap%type default null
                       , ?          --p_presso  						--in RECAPITI.presso%type default null
                       , ?          --p_importanza  					--in RECAPITI.importanza%type default null
                       , ?          --p_mail  							--in CONTATTI.valore%type  default null-- p_valore
                       , ?          --p_note_mail  						--in CONTATTI.note%type default null
                       , ?          --p_importanza_mail  				--in CONTATTI.importanza%type default null
                       , ?          --p_tel_res  						--in CONTATTI.valore%type  default null-- p_valore
                       , ?          --p_note_tel_res  					--in CONTATTI.note%type default null
                       , ?          --p_importanza_tel_res  			--in CONTATTI.importanza%type default null
                       , ?          --p_fax_res  						--in CONTATTI.valore%type  default null-- p_valore
                   	   , ?          --p_note_fax_res  					--in CONTATTI.note%type default null
                       , ?          --p_importanza_fax_res  			--in CONTATTI.importanza%type default null
                       , ?          --p_descrizione_dom  				--in RECAPITI.descrizione%type default null --p_descrizione
                       , ?          --p_indirizzo_dom  					--in RECAPITI.indirizzo%type default null
                       , ?          --p_provincia_dom           		--IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL
                       , ?          --p_comune_dom              		--IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL
                       , ?          --p_cap_dom  						--in RECAPITI.cap%type default null
                       , ?          --p_tel_dom  						--in CONTATTI.valore%type  default null-- p_valore
                       , ?          --p_note_tel_dom  					--in CONTATTI.note%type default null
                       , ?          --p_importanza_tel_dom  			--in CONTATTI.importanza%type default null
                       , ?          --p_fax_dom  						--in CONTATTI.valore%type  default null-- p_valore
                       , ?          --p_note_fax_dom  					--in CONTATTI.note%type default null
                       , ?          --p_utente                  		--IN ANAGRAFICI.utente%TYPE DEFAULT NULL
                       , ?          --p_data_agg                		--IN ANAGRAFICI.data_agg%TYPE DEFAULT SYSDATE
                       , ? 			--p_batch                      		--NUMBER DEFAULT 1           -- 0 = NON batch
					) }""",
                    [
                            Sql.NUMERIC
                            , soggetto.ni
                            , (soggetto.dal ? new java.sql.Date(soggetto.dal.time) : null)
                            , (soggetto.al ? new java.sql.Date(soggetto.al.time) : null)
                            , soggetto.cognome
                            , soggetto.nome
                            , soggetto.sesso
                            , (soggetto.dataNascita ? new java.sql.Date(soggetto.dataNascita.time) : null)
                            , codiceProvinciaNascita
                            , codiceComuneNascita
                            , soggetto.luogoNascita
                            , soggetto.codiceFiscale
                            , soggetto.codiceFiscaleEstero
                            , soggetto.partitaIva
                            , soggetto.cittadinanza
                            , null
                            , soggetto.competenza
                            , soggetto.competenzaEsclusiva
                            , soggetto.tipoSoggetto?.tipoSoggetto
                            , null
                            , soggetto.partitaIvaCee
                            , null
                            , null
                            , soggetto.denominazione
                            , soggetto.note
                            , soggetto.descrizioneResidenza
                            , soggetto.indirizzoResidenza
                            , codiceProvinciaResidenza
                            , codiceComuneResidenza
                            , soggetto.capResidenza
                            , soggetto.presso
                            , soggetto.importanza
                            , soggetto.indirizzoWeb
                            , soggetto.noteMail
                            , soggetto.importanzaMail
                            , soggetto.telefonoResidenza
                            , soggetto.noteTelefonoResidenza
                            , soggetto.importanzaTelefonoResidenza
                            , soggetto.faxResidenza
                            , soggetto.noteFaxResidenza
                            , soggetto.importanzaFaxResidenza
                            , soggetto.descrizioneDomicilio
                            , soggetto.indirizzoDomicilio
                            , codiceProvinciaDomicilio
                            , codiceComuneDomicilio
                            , soggetto.capDomicilio
                            , soggetto.telefonoDomicilio
                            , soggetto.noteTelefonoDomicilio
                            , soggetto.importanzaTelefonoDomicilio
                            , soggetto.faxDomicilio
                            , soggetto.noteFaxDomicilio
                            , utente
                            , new java.sql.Date((new Date()).time)
                            , 1
                    ]) { BigDecimal id -> idAnagrafica = id.longValue()
            }

//            soggetto.ni = idAnagrafica
//            soggetto.refresh()

//            soggetto.ni = niAnagrafica
            soggetto.ni = getNi(idAnagrafica)
//            soggetto.dal = getDal(idAnagrafica)

//            AnagraficaId anagraficaId = new AnagraficaId(ni,dal)
//            soggetto.setAnagraficaId(anagraficaId)
            sessionFactory.getCurrentSession().refresh(soggetto)

        } catch (SQLException e) {
            throw new As4SqlRuntimeException(e)
        }

    }

    Long getNi(Long idAnagrafica) {
        Sql sql = new Sql(dataSource)
        Long ni = 0
        try {
            sql.call("""{? = call anagrafici_tpk.get_ni(
				? 		-- p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type	
				) }""",
                    [Sql.NUMERIC
                     , idAnagrafica]) { BigDecimal id -> ni = id.longValue() }
            return ni
        } catch (Exception e) {
            e.printStackTrace()
        }

    }

    Date getDal(Long idAnagrafica) {
        Sql sql = new Sql(dataSource)
        Date dal = new Date()
        try {
            sql.call("""{? = call anagrafici_tpk.get_dal(
				? 		-- p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type	
				) }""",
                    [Sql.TIMESTAMP
                     , idAnagrafica]) { Timestamp result -> dal = new Date(result.getTime()) }
            return dal
        } catch (Exception e) {
            e.printStackTrace()
        }

    }

    List<AnagrafeSoggettiWs> cercaSoggetti(AnagrafeSoggettiWs s) {

        def lista = AnagrafeSoggettiWs.createCriteria().list() {
            createAlias('comuneNascita', 'cn', CriteriaSpecification.LEFT_JOIN)
            createAlias('provinciaNascita', 'pn', CriteriaSpecification.LEFT_JOIN)
            createAlias('comuneDomicilio', 'cd', CriteriaSpecification.LEFT_JOIN)
            createAlias('provinciaDomicilio', 'pd', CriteriaSpecification.LEFT_JOIN)
            createAlias('comuneResidenza', 'cr', CriteriaSpecification.LEFT_JOIN)
            createAlias('provinciaResidenza', 'pr', CriteriaSpecification.LEFT_JOIN)
            createAlias('tipoSoggetto', 'ts', CriteriaSpecification.LEFT_JOIN)

            if ((s.cognome)?.toUpperCase() != null)
                like("cognome", (s.cognome).toUpperCase() + "%")

            if ((s.nome)?.toUpperCase() != null)
                like("nome", (s.nome).toUpperCase() + "%")

            if ((s.denominazione)?.toUpperCase() != null)
                like("nominativoRicerca", "%" + (s.denominazione).toUpperCase() + "%")

            if ((s.codiceFiscale)?.toUpperCase() != null)
                eq("codiceFiscale", (s.codiceFiscale).toUpperCase())

            if (s.partitaIva != null)
                eq("partitaIva", s.partitaIva)

            if (s.partitaIvaCee != null)
                eq("partitaIvaCee", s.partitaIvaCee)

            if ((s.codiceFiscaleEstero)?.toUpperCase() != null)
                eq("codiceFiscaleEstero", (s.codiceFiscaleEstero).toUpperCase())

            order("cognome", "asc")
            order("nome", "asc")
        }
        return lista
    }

    Map parsingError(SQLException e) {

        Map error = [:]
        String errorCode = String.valueOf(e.getErrorCode())

        error.put('stacktrace', e)

        if (errorCode.startsWith('20')) {
            String[] listError = (e.getMessage()).split('\n')
            if (listError[0].contains('[')) {
                int firstIndex = listError[0].indexOf('[') + 1
                String codError = listError[0].substring(firstIndex, firstIndex + 6)
                error.put("codice", codError)
                String msgError = listError[0].substring(20, listError[0].length())
                error.put("messaggio", msgError)
            } else {
                String[] message = (e.getMessage()).split('\n')
                error.put("codice", "-" + e.getErrorCode())
                error.put("messaggio", message[0])
            }
        } else {
            String[] message = (e.getMessage()).split('\n')
            error.put("codice", "-" + e.getErrorCode())
            error.put("messaggio", message[0])
        }
        return error
    }
}