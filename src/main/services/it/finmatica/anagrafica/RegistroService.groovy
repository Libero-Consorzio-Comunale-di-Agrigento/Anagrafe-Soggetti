package it.finmatica.anagrafica


import groovy.util.logging.Slf4j
import it.finmatica.as4.anagrafica.Registro
import org.springframework.stereotype.Service

@Slf4j
@Service
class RegistroService {


    String getValore(String chiave, String stringa) {

        try {
            Registro reg = Registro.createCriteria().get() {
                eq("chiave", chiave)
                eq("stringa", stringa)
            }
            return reg.valore
        } catch (Exception e) {
            log.error("RegistroService: Errore nell'accesso alla tabella REGISTRO", e)
        }

        return null
    }
}
