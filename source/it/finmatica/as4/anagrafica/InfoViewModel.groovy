package it.finmatica.as4.anagrafica

import groovy.transform.CompileStatic

import it.finmatica.ad4.security.SpringSecurityService
import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Ruolo
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.utility.UtenteService
import org.springframework.transaction.annotation.Transactional
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Window

//@CompileStatic
@VariableResolver(DelegatingVariableResolver)
@Slf4j
class InfoViewModel {

	def window
	@WireVariable private SpringSecurityService springSecurityService
	@WireVariable private UtenteService utenteService
	
	Ad4Utente utente
	String ente, enteDesc, oldPassword, newPassword, confirmPassword, competenzaEsclusiva, competenza
	
	Ad4Ruolo ruolo
	
	@Init init(@ContextParam(ContextType.COMPONENT) Window w,  @ExecutionArgParam("competenzaEsclusiva") String ce, @ExecutionArgParam("competenza") String c) {
		window = w
		def session 	= Executions.getCurrent().getSession()
		
		utente  = springSecurityService.currentUser
		ruolo = Ad4Ruolo.get(springSecurityService.principal.authorities.authority[0])
		competenzaEsclusiva = ce
		competenza = c
		
	}
	
	@Command onClose () {
		Events.postEvent("onClose", window, null)
	}
}
