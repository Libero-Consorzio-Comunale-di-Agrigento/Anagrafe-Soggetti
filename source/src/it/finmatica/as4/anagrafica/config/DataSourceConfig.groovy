package it.finmatica.as4.anagrafica.config

import groovy.transform.CompileStatic
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.jdbc.datasource.TransactionAwareDataSourceProxy

import javax.sql.DataSource

import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean
import org.springframework.boot.autoconfigure.jdbc.DataSourceBuilder
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Primary
import org.springframework.transaction.annotation.EnableTransactionManagement

@EnableTransactionManagement
@Configuration
public class DataSourceConfig {

    /*@Primary
    @Bean
    @ConditionalOnMissingBean(DataSource.class)
    @ConfigurationProperties("spring.datasource")
    public DataSource dataSource() {
        return DataSourceBuilder.create().build();
    }*/

    @Primary
    @Bean
    DataSource dataSource(@Qualifier("dataSourceUnproxied") DataSource dataSource) {
        return new TransactionAwareDataSourceProxy(dataSource)
    }

    @Bean
    @ConfigurationProperties(prefix = "spring.datasource")
    DataSource dataSourceUnproxied() {
        return DataSourceBuilder.create().build()
    }

    @Bean
    @ConfigurationProperties(prefix = "spring.datasources.ad4")
    @ConditionalOnMissingBean(name="ad4DataSource")
    DataSource ad4DataSource() {
        return DataSourceBuilder.create().build();
    }

}
