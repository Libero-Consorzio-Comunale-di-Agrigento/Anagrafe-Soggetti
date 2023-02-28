package it.finmatica.as4.anagrafica

import groovy.transform.CompileStatic
import java.io.File
import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.builder.SpringApplicationBuilder
import org.springframework.boot.context.embedded.ConfigurableEmbeddedServletContainer
import org.springframework.boot.context.embedded.EmbeddedServletContainerCustomizer
import org.springframework.boot.web.support.SpringBootServletInitializer
import org.springframework.context.annotation.EnableAspectJAutoProxy

@CompileStatic
@SpringBootApplication
@EnableAspectJAutoProxy(proxyTargetClass = true)
public class Application extends SpringBootServletInitializer implements EmbeddedServletContainerCustomizer {

    public static void main(String[] args) throws Exception {
        SpringApplication.run(Application.class, args)
    }

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(Application.class)
    }

    @Override
    public void customize(ConfigurableEmbeddedServletContainer container) {
        container.setDocumentRoot(new File("web-app"))
    }
}