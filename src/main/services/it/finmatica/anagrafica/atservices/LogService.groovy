package it.finmatica.anagrafica.atservices

import com.fasterxml.jackson.databind.ObjectMapper
import groovy.util.logging.Slf4j
import it.finmatica.atservices.Operatore
import it.finmatica.atservices.PdndLog
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.stereotype.Service

import javax.annotation.PostConstruct
import javax.sql.DataSource
import java.sql.Timestamp

@Slf4j
@Service
class LogService {
    @Qualifier("ad4DataSource")
    @Autowired
    DataSource ad4DataSource

    JdbcTemplate jdbcTemplate
    ObjectMapper objectMapper

    private final static String QUERY_OPERATORI = "select distinct pl.utente operatore, nvl((select denominazione from as4_anagrafe_soggetti s, ad4_utenti_soggetti us where us.soggetto = s.ni and us.utente = pl.utente and sysdate between s.dal and nvl(s.al,to_date(3333333,'j'))),pl.utente) denominazione\n" +
            "from pdnd_log pl"

    @PostConstruct
    void init() {
        jdbcTemplate = new JdbcTemplate(ad4DataSource)
        objectMapper = new ObjectMapper()
    }

    List<PdndLog> getLogs(String id, Date dal, Date al) {
        List<PdndLog> logs = new ArrayList<>()
        List<Object> params = new ArrayList<>()
        StringBuilder sql = new StringBuilder("SELECT pl.*, nvl((select denominazione from as4_anagrafe_soggetti s, ad4_utenti_soggetti us where us.soggetto = s.ni and us.utente = pl.utente and sysdate between s.dal and nvl(s.al,to_date(3333333,'j'))),pl.utente) denominazione" +
                                                " FROM pdnd_log pl WHERE TRUNC(pl.data_richiesta) BETWEEN ? AND ?")
        params.add(dal)
        params.add(al)

        if (id != null && !id.isEmpty()) {
            sql.append(" AND pl.utente = ?")
            params.add(id)
        }

        sql.append(" ORDER BY pl.data_richiesta DESC")

        try {
            List<Map<String, Object>> result = jdbcTemplate.queryForList(sql.toString(), params.toArray())

            for (Map<String, Object> row : result) {
                String logId = (String) row.get("logId")
                String user = (String) row.get("denominazione")
                String servizio = (String) row.get("servizio")
                Date dataRichiesta = processaData((Timestamp) row.get("data_richiesta"))
                Date dataFine = processaData((Timestamp) row.get("data_fine"))
                String request = (String) row.get("request")
                String response = (String) row.get("response")

                logs.add(new PdndLog(logId, user, servizio, dataRichiesta, dataFine, request, response, objectMapper))
            }
        } catch (Exception e) {
            log.error("LogService: impossibile accedere ai log su pdnd_log", e)
        }


        return logs
    }

    private static Date processaData(Timestamp ts) {
        Date data = ts != null ? new Date(ts.getTime()) : null
        return data

    }

    List<Operatore> getOperatori() {
        List<Operatore> operatori = new ArrayList<>()

        try {
            List<Map<String, Object>> result = jdbcTemplate.queryForList(QUERY_OPERATORI)

            for (Map<String, Object> row : result) {
                String op = (String) row.get("operatore")
                String den = (String) row.get("denominazione")

                operatori.add(new Operatore(op,den))
            }

        } catch (Exception e) {
            log.error("LogService: impossibile accedere agli operatori su pdnd_log", e)
        }

        return operatori

    }

}
