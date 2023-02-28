package it.finmatica.as4.anagrafica.config

import groovy.transform.CompileStatic
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.autoconfigure.condition.ConditionalOnJndi
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Primary
import org.springframework.jdbc.datasource.lookup.JndiDataSourceLookup

import javax.sql.DataSource

@CompileStatic
@Configuration
class JndiDataSourceConfig {

    @Primary
    @Bean(destroyMethod = "")
    @ConditionalOnJndi
    public DataSource dataSource (@Value("\${spring.datasource.jndi-name}") String jndiName) {
        return new JndiDataSourceLookup().getDataSource(jndiName);
    }

    @Bean(destroyMethod = "")
    @ConditionalOnJndi
    public DataSource ad4DataSource (@Value("\${spring.datasources.ad4.jndi-name}") String jndiName) {
        return new JndiDataSourceLookup().getDataSource(jndiName);
    }

}