package it.finmatica.test

import it.finmatica.as4.utils.CFGenerator
import org.apache.commons.logging.LogFactory
import spock.lang.*

@Ignore
class CFGeneratorTest extends Specification  {
	def log = LogFactory.getLog(getClass())
	// ** fields **
	private String nome, cognome, comune, mese, sesso;
	private int anno, giorno;
	
	// Objects stored into instance fields are not shared between feature methods. 
	// Instead, every feature method gets its own object.
	
	// CFGenerator cfGen = new CFGenerator()
	
	// ** fixture methods **
	def setup() {}          // run before every feature method
	def cleanup() {}        // run after every feature method
	
	def setupSpec() {}     // run before the first feature method
	def cleanupSpec() {}   // run after the last feature method
	
	// feature methods
	// helper methods
	void 'test calcolo codice fiscale'() {
        
		expect: 'Should return the right codice fiscale!'
		CFGenerator cfGen = new CFGenerator(nome, cognome, comune, mese, anno, giorno, sesso)
		cfGen.getCodiceFiscale() == codicefiscale
		
		where:
		cognome | nome | sesso | comune | giorno | mese | anno || codicefiscale
		'Turra' | 'Matteo' | 'M' | 'Bologna' | 9 | '10' | 1971 || 'TRRMTT71R09A944J'
		'Turra' | 'Matteo' | 'M' | 'Bologna' | 9 | 'Ottobre' | 1971 || 'TRRMTT71R09A944J'
		'GUALTIERI' | 'ROBERTA' | 'F' | 'CATANZARO' | 1 | '10' | 1986 || 'GLTRRT86R41C352K'
    }
}
