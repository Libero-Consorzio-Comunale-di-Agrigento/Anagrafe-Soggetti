package it.finmatica.test.ws

import spock.lang.*
import wslite.http.auth.HTTPBasicAuthorization
import wslite.soap.SOAPClient
import wslite.soap.SOAPVersion
import org.apache.commons.logging.LogFactory

/**
* Questa classe di test utilizza la libreria ws-lite, che permette di scrivere le 
* invocazioni ai web servide in modo semplice.
* Disabilitata tramire @Ignore  
**/
class WsAnagraficaSpec extends Specification {
	private def response
	SOAPClient client
	def log = LogFactory.getLog(getClass())

	void setup() {

		String serverPort = System.properties['server.port']?:"8080"
		println "serverPort: " + serverPort

//		ProxySelector proxy = ProxySelector.getDefault();
//		ProxySelector.setDefault(proxy);
		
		String baseUrl="http://localhost:" + serverPort + "/Anagrafica/services/serviziAnagrafe"
//		String baseUrl="http://10.97.11.18:8888/Anagrafica/services/serviziAnagrafe"
//		log.debug "Setting serverUrl: " +  grailsLinkGenerator.getServerBaseURL()
		log.debug "Setting baseUrl: " + baseUrl
		client = new SOAPClient(baseUrl)	
		client.authorization = new HTTPBasicAuthorization("as4", "as4")
	}

	@Ignore
	void "TestWs"() {
		given:
		String codFis = "GLTRRT86R41C352K"
		log.debug "it:researchAnagrafe with codiceFiscale: " + codFis
		when:
		def response = client.send(
		connectTimeout:5000,
		readTimeout:10000,
		useCaches:false,
		followRedirects:false,
		sslTrustAllCerts:true) {
			version SOAPVersion.V1_2        // SOAPVersion.V1_1 is default
			soapNamespacePrefix "soap"      // "soap-env" is default
			envelopeAttributes 'xmlns:it':"it.finmatica.as4.ws"
			body {
				'it:researchAnagrafe'() { 
					codiceFiscale(codFis) 
				}
			}
		}
//		def response = client.send(
//			"""<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:it="it.finmatica.as4.ws">
//   <soap:Header/>
//   <soap:Body>
//      <it:researchAnagrafe>
//         <codiceFiscale>TRRMTT71R09A944J</codiceFiscale>
//      </it:researchAnagrafe>
//   </soap:Body>
//</soap:Envelope>"""
//)
		then:
		def soap = new XmlSlurper().parseText(response.text)
		def size = soap.Body.researchAnagrafeResponse.researchAnagrafeResult.size()
		def ni = soap.Body.researchAnagrafeResponse.researchAnagrafeResult[0].ni.text()
		assert codFis == soap.Body.researchAnagrafeResponse.researchAnagrafeResult[0].codiceFiscale.text()
		assert ni != null
	}
}
