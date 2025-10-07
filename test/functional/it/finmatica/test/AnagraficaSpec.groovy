package it.finmatica.test
/*
package it.finmatica.anagrafica.test

import geb.Configuration
import geb.spock.GebReportingSpec
import it.finmatica.anagrafica.test.pages.*
import it.finmatica.as4.anagrafica.Application
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import spock.lang.*
import java.net.InetAddress

@SpringBootTest(classes = Application.class, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@Stepwise
class AnagraficaSpec extends GebReportingSpec{

	String host = InetAddress.getLocalHost().getHostAddress()

	@Value('${local.server.port}')
	int port

	def setup() {
		browser.setBaseUrl("http://${host}:${port}/Anagrafica/index.zul")
	}

	def generator = { String alphabet, int n ->
		new Random().with {
			(1..n).collect { alphabet[ nextInt( alphabet.length() ) ] }.join()
		}
	}
	static final String TIMESTAMP_STR = Long.toString(System.currentTimeMillis(), 36).toUpperCase()

	def "Login"() {
		when:
		to LoginPage
		loginModule.login()

		then:
		at HomePage
	}

	def "AperturaDizionari"() {
		when:
		to HomePage

		and:
		manualsMenu.openDizionari()

		then:
		at DizionariPage
	}

	def "AperturaElencoSoggetti"() {
		when:
		to HomePage

		and:
		manualsMenu.openElencoSoggetti()

		then:
		at ElencoSoggettiPage
	}

	def "addPerson"() {
		when:
//		to ElencoSoggettiPage
		toolbarSoggetto.clickAddButton()
		then:
		at CreatePage
	}

	
	def "insertEmptyPerson"() {
		when:
		def soggetto = [:]
		soggetto.tipo = 'SOGGETTO GENERICO'
		soggetto.giorno = new Date()
		tabSoggetto.insertEmptySogg(soggetto)
		
		then:
		at CreatePage
	}
	
	def "insertSoggettoGenerico"() {
		when:
		messageBox.clickYes()
		def soggetto = [:]
		soggetto.nome = generator((('A'..'Z')).join(), 5 )
		soggetto.cognome = 'TEST_' + TIMESTAMP_STR + generator((('A'..'Z')).join(), 5 )
		soggetto.giorno = new Date()
		soggetto.sesso = generator("MF", 1 )
		tabSoggetto.insertPersonaFisica(soggetto)

		then:
		to ElencoSoggettiPage
	}
	
	def "searchLastInsert"(){
		when:
		def word = 'TEST_' + TIMESTAMP_STR
		toolbarSoggetto.fastSearch(word)

		then:
		at ElencoSoggettiPage
	}

//	AS4 REGISTRO PRODUCTS/ANAGRAFICA Modificabile = SI
	def "updateSoggetto"(){
		when:
		toolbarSoggetto.selectedElement()

		then:
		at CreatePage
	}

	def changeData(){
		when:
		String note = 'TEST DI UPDATE'
		tabSoggetto.updatePersonaFisica(note)

		then:
		to ElencoSoggettiPage
	}
	
	def "findSoggetto"(){
		when:
		def word = 'TEST_' + TIMESTAMP_STR
		toolbarSoggetto.fastSearch(word)
		then:
		at ElencoSoggettiPage
	}
	
	def "readSoggetto"(){
		when:
		toolbarSoggetto.openReadPanel()
		
		then:
		at CreatePage
	}
	
	def closeReadPanel(){
		when:
		tabSoggetto.closeReadPanel()
		
		then:
		at ElencoSoggettiPage
	}
	
	
}
*/
