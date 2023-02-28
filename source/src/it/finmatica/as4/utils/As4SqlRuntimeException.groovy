package it.finmatica.as4.utils

import groovy.transform.CompileStatic

import java.sql.SQLException

@CompileStatic
class As4SqlRuntimeException extends RuntimeException {

    private final String codice

   As4SqlRuntimeException (SQLException e) {
       this (parseMessage(e), e)
   }

    private As4SqlRuntimeException(Map<String, String> map, SQLException e) {
        super(map.messaggio, e)
        this.codice = map.codice
    }

    private static Map parseMessage(SQLException e) {
        Map error = [:]
        String errorCode = String.valueOf(e.getErrorCode())
        if (errorCode.startsWith('20')) {
            String[] listError = (e.getMessage()).split('\n')
            if (listError[0].contains('[')) {
                int firstIndex = listError[0].indexOf('[') + 1
                String codError = listError[0].substring(firstIndex, firstIndex + 6)
                error.put("codice", codError)
                String msgError = listError[0].substring(20, listError[0].length())
                error.put("messaggio", msgError)
            } else {
                String[] message = (e.getMessage()).split('\n')
                error.put("codice", "-" + e.getErrorCode())
                error.put("messaggio", message[0])
            }
        } else {
            String[] message = (e.getMessage()).split('\n')
            error.put("codice", "-" + e.getErrorCode())
            error.put("messaggio", message[0])
        }
        return error
    }

    String getCodice () {
        return this.codice
    }
}
