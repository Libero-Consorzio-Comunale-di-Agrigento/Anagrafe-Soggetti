package it.finmatica.anagrafica.atservices


import groovy.util.logging.Slf4j
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.stereotype.Service

import javax.annotation.PostConstruct
import javax.sql.DataSource

@Slf4j
@Service
class RegistroAD4Service {
    @Qualifier("ad4DataSource")
    @Autowired
    DataSource ad4DataSource

    JdbcTemplate jdbcTemplate

    private final static String QUERY_CHECKBOX = "select SUBSTR(CHIAVE,INSTR(CHIAVE,'/',-1,1)+1)\n" +
            "from REGISTRO\n" +
            "where CHIAVE like 'PRODUCTS/ATSERVICES/CONFIG%'\n" +
            "   AND STRINGA = 'PURPOSEID'"

    @PostConstruct
    void init() {
        jdbcTemplate = new JdbcTemplate(ad4DataSource)
    }

    List<String> getVisibilitaCheckBox() {
        List<String> result = new ArrayList<>()

        try {
            result = jdbcTemplate.queryForList(QUERY_CHECKBOX, String.class)
        } catch (Exception e) {
            log.error("RegistroAD4Service: impossibile accedere al registro", e)
        }

        return result
    }


}
