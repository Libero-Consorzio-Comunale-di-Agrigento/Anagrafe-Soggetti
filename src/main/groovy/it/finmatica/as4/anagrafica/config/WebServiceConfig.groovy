package it.finmatica.as4.anagrafica.config

import groovy.transform.CompileStatic
import it.finmatica.anagrafica.ws.ServiziAnagrafeService
import it.finmatica.anagrafica.ws.ServiziAnagrafeServiceWS
import org.apache.cxf.Bus
import org.apache.cxf.jaxws.EndpointImpl
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

import javax.xml.ws.Endpoint

@CompileStatic
@Configuration
class WebServiceConfig {

    @Bean
    ServiziAnagrafeServiceWS serviziAnagrafeServiceWS(ServiziAnagrafeService serviziAnagrafeService) {
        return new ServiziAnagrafeServiceWS(serviziAnagrafeService)
    }

    @Bean
    Endpoint endpointServiziAnagrafeServiceWS(Bus bus, ServiziAnagrafeServiceWS serviziAnagrafeServiceWS) {
        EndpointImpl endpoint = new EndpointImpl(bus, serviziAnagrafeServiceWS)
        endpoint.setImplementorClass(ServiziAnagrafeServiceWS)
        endpoint.publish("/serviziAnagrafe")
        return endpoint;
    }

}