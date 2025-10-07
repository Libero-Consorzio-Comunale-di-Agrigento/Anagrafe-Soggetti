package it.finmatica.test.ws

import com.eviware.soapui.tools.SoapUITestCaseRunner
import it.finmatica.as4.anagrafica.Application
import it.finmatica.as4.utils.CFGenerator
import org.apache.commons.logging.LogFactory
import org.junit.Ignore
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import spock.lang.Shared
import spock.lang.Specification

import java.text.SimpleDateFormat

@Ignore
@SpringBootTest(classes = Application.class, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
class WebServiceSoapUiTestItSpec extends Specification {
	@Shared
	ProxySelector proxy
	def log = LogFactory.getLog(getClass())

	String host = InetAddress.getLocalHost().getHostAddress()

	@Value('${local.server.port}')
	int port
	
	def generator = { String alphabet, int n ->
		new Random().with {
			(1..n).collect { alphabet[ nextInt( alphabet.length() ) ] }.join()
		}
	}

	def setupSpec() {
		proxy = ProxySelector.getDefault();
	}

	def cleanupSpec() {
		ProxySelector.setDefault(proxy);
	}

	void "SoapUI Test"() {
		when:
		String nome = generator( (('A'..'Z')).join(), 9 )
		String cognome = generator( (('A'..'Z')).join(), 9 )
		String nomeCEE = generator( (('A'..'Z')).join(), 9 )
		String cognomeCEE = generator( (('A'..'Z')).join(), 9 )
		String comune = 'Bologna'
		Date curdate = new Date()
		Date ago18yrs = curdate - (18*365)
		Date ago99yrs = curdate - (99*365)
		int daysbetween = ago18yrs.minus( ago99yrs )
		Date randomdate = ago99yrs + new Random().nextInt(daysbetween)
		Calendar cal = Calendar.getInstance()
		cal.setTime(randomdate)

		String mese =  cal.get(Calendar.MONTH)+1 
		int anno =  cal.get(Calendar.YEAR)
		int giorno =  cal.get(Calendar.DAY_OF_MONTH)
		String sesso = generator("MF", 1 )
		String partitaIva = generator( (('0'..'9')).join(), 11)
		String partitaIvaCEE = generator( (('0'..'9')).join(), 11)
		String dal = new SimpleDateFormat("yyyy-MM-dd'T'00:00:00").format(curdate)

		CFGenerator cfGenerator = new CFGenerator(nome, cognome, comune, mese, anno, giorno, sesso)
		String codiceFiscale = cfGenerator.getCodiceFiscale()
		log.debug "Some useful information here"
		log.info "Codice fiscale generato: " + codiceFiscale

		CFGenerator cfCEEGenerator = new CFGenerator(nomeCEE, cognomeCEE, comune, mese, anno, giorno, sesso)
		String codiceFiscaleCEE = cfCEEGenerator.getCodiceFiscale()
		log.info "Codice fiscale ESTERO generato: " + codiceFiscaleCEE

		String [] properties = [ "nome=" + nome, "cognome=" + cognome, "codiceFiscale=" + codiceFiscale, "partitaIva=" + partitaIva, "dal=" + dal, "codiceFiscaleCEE=" + codiceFiscaleCEE, "partitaIvaCEE=" + partitaIvaCEE]
		
		
		SoapUITestCaseRunner runner = new SoapUITestCaseRunner()
		runner.setProjectFile( "test/functional/it/finmatica/anagrafica/test/ws/As4-soapui-project.xml" )
		runner.setProjectProperties(properties)
//		runner.setJUnitReport(true)
//		String serverPort = System.properties['server.port']?:"8080"
		runner.setEndpoint("http://" + host + ":" + port + "/Anagrafica/services/serviziAnagrafe")
		def result = runner.run()


//		WsdlProject project = new WsdlProject("test/functional/anagrafica/As4-soapui-project.xml")
//		for (String option : properties) {
//			int ix = option.indexOf('=');
//			if (ix != -1) {
//				String name = option.substring(0, ix);
//				String value = option.substring(ix + 1);
//				log.info("Setting project property [" + name + "] to [" + value + "]");
//				project.setPropertyValue(name, value);
//			}
//		}
//		List<TestSuite> testSuites = project.getTestSuiteList()
//		for( TestSuite suite : testSuites ) {
//			List<TestCase> testCases = suite.getTestCaseList()
//			for( TestCase testCase : testCases ) {
//				System.out.println("Running SoapUI test [" + testCase.getName() + "]")
//				TestRunner runner = testCase.run(new PropertiesMap(), false)
//				runner.setJUnitReport(true)
//				runner.setEndpoint("http://localhost:8080/Anagrafica/services/serviziAnagrafe")
//				result = result && Status.FINISHED == runner.getStatus()
//			}
//		}
		then:
		result == true
		
	}
}
