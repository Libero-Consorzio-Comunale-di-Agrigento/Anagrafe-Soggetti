package it.finmatica.as4.anagrafica

import groovy.util.logging.Slf4j

//import grails.validation.ValidationException

import it.finmatica.as4.utils.As4SqlRuntimeException
import org.hibernate.StaleObjectStateException
import org.springframework.dao.DataIntegrityViolationException
import org.springframework.orm.hibernate3.HibernateJdbcException
import org.zkoss.bind.BindContext
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.UiException
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
@Slf4j
class ErrorViewModel {
	
	Window self
	
	String title
	String stacktrace
	
	// mostrare dettagli
	boolean dettagli	 = false
	
//	def log = LogFactory.getLog(getClass())
	
	@Init init(@ContextParam(ContextType.COMPONENT) Window w)  {
		self = w
		Throwable exception = Executions.getCurrent().getAttribute("javax.servlet.error.exception")
//		log.error (exception.message, exception)

		def cause = (exception instanceof UiException ? exception.cause : null);
		if (cause != null) {
			checkException(cause);
		} else {
			checkException(exception);
		}
	}
	
	private void checkException (Throwable e) {
		if (e instanceof As4SqlRuntimeException) {
			title = e.message;
		} else if (e instanceof DataIntegrityViolationException) {
			title = "Oggetto non modificabile o eliminabile: esistono dipendenze."
		} else if (e instanceof StaleObjectStateException) {
			title = "Oggetto modificato da un altro utente."
//		} else if (e instanceof ValidationException) {
//			title = "Verificare i campi compilati"
		} else if (e instanceof HibernateJdbcException) {
			title = e.getSQLException().message
		} else {
			title = "Errore generico:\n\n "+e.message;
		}
		
		stacktrace = e.message+"\n"+e.getStackTrace().toString().replace(')', ')\n');
	}
	
	@Command onClose (@ContextParam(ContextType.BIND_CONTEXT) BindContext ctx) {
		dettagli = false
		Events.postEvent("onClose", self, null)
	}

}
