
/*
	This is the Geb configuration file.
	
	See: http://www.gebish.org/manual/current/#configuration
	
	Pacchetto da installare su server jenkins: xorg-x11-server-Xvfb
*/
import org.openqa.selenium.chrome.ChromeDriver
import org.openqa.selenium.chrome.ChromeOptions
import org.openqa.selenium.firefox.FirefoxDriver
import org.openqa.selenium.remote.DesiredCapabilities
import org.openqa.selenium.remote.RemoteWebDriver

waiting {
	timeout = 10
	retryInterval = 1
}

port = System.getProperty("server.port")?:"8080"

seleniumHub = System.getProperty("selenium.hub")?:"http://selenium.svi.finmatica.local:4444/wd/hub"

// BaseUrl
String baseUrlProp=System.getProperty("baseUrl")?:"http://localhost:$port/Anagrafica/index.zul"

baseUrl = baseUrlProp

/* Questa parte serve nel caso di basic auth
String username=System.getProperty("username")?:"as4 nome"
username=username.replaceAll(" ", "%20")

String password=System.getProperty("password")?:""
password=password.replaceAll(" ", "%20")

String credentials = username + ":" + password + "@"
String protocol=baseUrlProp.substring( 0, baseUrlProp.indexOf("://") +3)
String urlTail=baseUrlProp.substring(baseUrlProp.indexOf("://") + 3, baseUrlProp.length())
baseUrl=protocol + credentials + urlTail

//Questo funziona
//baseUrl="http://as4%20nome:@mturra.finmatica.local:30000/Anagrafica/"
println("baseUrl: " + baseUrl)
println("baseUrl_b64: " + baseUrl.bytes.encodeBase64().toString())

// Test per passare la Basic Auth come header, ma non ho capito come fare!
// headers = { Authorization: 'Basic %s' % b64encode(bytes(username + ":" + password, "utf-8")).decode("ascii") }
*/

// Configure where screenshots are stored
reportsDir = 'target/test-reports/screenshots'

// Report Film Strip http://rdmueller.github.io/grails-filmStrip/
// reportingListener = new grails.plugin.filmstrip.FilmStripReportingListener()

// Optional, less noise when only failed tests generate screenshots
// reportOnTestFailureOnly = true

environments {
	def geckoDriver = new File("C:/tools/test/geckodriver/geckodriver.exe")
	System.setProperty("webdriver.gecko.driver", geckoDriver.absolutePath)
	
	ProxySelector proxy = ProxySelector.getDefault()
	ProxySelector.setDefault(proxy)
	
	// run via ./gradlew chromeTest
	// See: http://code.google.com/p/selenium/wiki/ChromeDriver
	chrome {
		atCheckWaiting = 1
		def chromeDriver = new File("C:/tools/test/chromedriver/2.35/chromedriver.exe")
		System.setProperty("webdriver.chrome.driver", chromeDriver.absolutePath)
		DesiredCapabilities capabilities = DesiredCapabilities.chrome()
		
		/* Ho utilizzato il codice per inserire un proxy per analizzare con Burp il traffico *\
		// Add the WebDriver proxy capability.
		Proxy proxy1 = new Proxy()
		proxy1.setHttpProxy("localhost:9090")
		capabilities.setCapability("proxy", proxy1)
		\**************************************************************************************/
		
		driver = { new ChromeDriver(capabilities) }
	}

	// run via ./gradlew chromeHeadlessTest
	// See: http://code.google.com/p/selenium/wiki/ChromeDriver
	chromeHeadless {
		driver = {
			ChromeOptions o = new ChromeOptions()
			o.addArguments('headless')
			new ChromeDriver(o)
		}
	}
	
	// run via ./gradlew firefoxTest
	// See: http://code.google.com/p/selenium/wiki/FirefoxDriver
	firefox {
		atCheckWaiting = 1

		driver =   { new FirefoxDriver() }
/*		{
			FirefoxProfile profile = new FirefoxProfile()
			// this avoids the "Your are signing in to..." alert
			profile.setPreference("signon.autologin.proxy", true)
			
			DesiredCapabilities desiredCapabilities = new DesiredCapabilities()
			desiredCapabilities.setCapability('acceptInsecureCerts', true)
			
			FirefoxOptions options = new FirefoxOptions().setProfile(profile).addCapabilities(desiredCapabilities)
			
			new FirefoxDriver(options)
		}
*/
	}
	
	remotefirefox {
		driver = {
			DesiredCapabilities capabilities = new DesiredCapabilities()
			// ... but only if it supports javascript
			capabilities.setJavascriptEnabled(true)
			capabilities.setBrowserName("firefox")
			capabilities.setCapability("browserstack.local", "true")
			new RemoteWebDriver(
			  new URL(seleniumHub), capabilities
			)
		 }
	}
	
	remotechrome {
		driver = {
			DesiredCapabilities capabilities = new DesiredCapabilities()
			// ... but only if it supports javascript
			capabilities.setJavascriptEnabled(true)
			capabilities.setBrowserName("chrome")
			new RemoteWebDriver(
			  new URL(seleniumHub), capabilities
			)
		 }
	}
}
