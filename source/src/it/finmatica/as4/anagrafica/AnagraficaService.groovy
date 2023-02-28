package it.finmatica.as4.anagrafica

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.ad4.security.SpringSecurityService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.context.ApplicationContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.servlet.ServletContext
import javax.sql.DataSource
import java.util.jar.Attributes
import java.util.jar.Manifest

@CompileStatic
@Slf4j
@Transactional
@Service
class AnagraficaService {

//    private final DataSource dataSource
//    private final SpringSecurityService springSecurityService
    private final ApplicationContext applicationContext

    AnagraficaService(DataSource dataSource, SpringSecurityService springSecurityService, ApplicationContext applicationContext) {
//        this.dataSource = dataSource
//        this.springSecurityService = springSecurityService
        this.applicationContext = applicationContext
    }

    String getVersione() {
        InputStream inputStream = applicationContext.getBean(ServletContext).getResourceAsStream("META-INF/MANIFEST.MF")
        if (inputStream == null) {
            return "SVILUPPO"
        }
        Manifest manifest = new Manifest(inputStream)
        Attributes attributes = manifest.getMainAttributes()
        String versione = attributes.getValue("Specification-Version")
        return versione
    }

    String getBuildNumber() {
        InputStream inputStream = applicationContext.getBean(ServletContext).getResourceAsStream("META-INF/MANIFEST.MF")
        if (inputStream == null) {
            return ""
        }
        Manifest manifest = new Manifest(inputStream)
        Attributes attributes = manifest.getMainAttributes()
        String buildNumber = attributes.getValue("Build-Number")
        return buildNumber
    }

    String getBuildTime() {
        InputStream inputStream = applicationContext.getBean(ServletContext).getResourceAsStream("META-INF/MANIFEST.MF")
        if (inputStream == null) {
            return ""
        }
        Manifest manifest = new Manifest(inputStream)
        Attributes attributes = manifest.getMainAttributes()
        String buildTime = attributes.getValue("Build-Time")
        return buildTime
    }
}
