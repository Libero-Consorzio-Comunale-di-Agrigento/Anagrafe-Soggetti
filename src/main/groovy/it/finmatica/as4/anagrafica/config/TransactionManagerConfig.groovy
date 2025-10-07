package it.finmatica.as4.anagrafica.config

import groovy.transform.CompileStatic
import org.hibernate.SessionFactory
import org.springframework.boot.web.servlet.FilterRegistrationBean
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.orm.jpa.support.OpenEntityManagerInViewFilter
import org.springframework.transaction.annotation.EnableTransactionManagement

import javax.persistence.EntityManagerFactory

@CompileStatic
@EnableTransactionManagement(proxyTargetClass = true)
@Configuration
class TransactionManagerConfig {

    /**
     * Filtro che apre l'entityManager per le servlet gestite da zk.
     * Necessario per poter utilizzare i vari metodi .save, .findBy, .createCriteria direttamente nei ViewModel
     * Nota che questa � considerata una "bad practice" e bisognerebbe eliminare tutte le chiamate alle domain dai ViewModel
     * @return
     */
    @Bean
    FilterRegistrationBean openEntityManagerInViewFilter() {
        FilterRegistrationBean reg = new FilterRegistrationBean(new OpenEntityManagerInViewFilter())
        reg.setEnabled(true)
        reg.setName("OpenEntityManagerInViewFilter")
        reg.setUrlPatterns(Arrays.asList("/zkau", "/zkau*", "/zkau/*", "*.zul", "*.zhtml", "/zkcomet/*"))
        return reg
    }

    /**
     * Alcuni bean richiedono la SessionFactory di Hibernate per funzionare e non sono ancora "puri JPA", quindi
     * devo "esporre" la SessionFactory che sta "nascosta" dietro al EntityManagerFactory
     * @param entityManagerFactory
     * @return
     */
    @Bean
    SessionFactory sessionFactory(EntityManagerFactory entityManagerFactory) {
        return entityManagerFactory.unwrap(SessionFactory)
    }


}