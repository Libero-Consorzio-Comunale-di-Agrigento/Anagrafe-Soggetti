package it.finmatica.anagrafica.utils


import groovy.util.logging.Slf4j
import it.finmatica.utils.ExportConstant
import it.finmatica.utils.ExportingException
import org.apache.commons.csv.CSVFormat
import org.apache.commons.csv.CSVPrinter
import org.apache.commons.csv.QuoteMode
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.zkoss.zul.Filedownload
import org.zkoss.zul.Messagebox

@Slf4j
@Transactional
@Service
class ExportCsvService {

    final static char ESCAPE = '@'
    final private char YES = 'Y'


    void exportData(List objects, List fields, Map labels, Map parameters, Map formatters) {
        Messagebox.show("Estrazione avviata, download in corso.")
        PipedWriter pipedWriter = new PipedWriter()
        PipedReader pipedReader = new PipedReader()
        pipedReader.connect(pipedWriter)
        Writer bw = new BufferedWriter(pipedWriter)
        BufferedReader br = new BufferedReader(pipedReader)

        //producer
        Thread.start({ exportDataImplementation(bw, objects, fields, labels, parameters, formatters) })

        String contentType = parameters?.contentType ?: "text/csv"
        String nomeFile = (parameters?.nomeFile ?: "export") + ".csv"
        //consumer
        Filedownload.save(br, contentType, nomeFile)
    }

    private void exportDataImplementation(Writer writer, List objects, List fields, Map labels, Map parameters, Map formatters) {
        log.debug("""exportDataImplementation 
        Writer _writer $writer, 
        List objects $objects, 
        List fields $fields, 
        Map labels $labels, 
        Map parameters $parameters, 
        Map formatters $formatters
        """)
        if (objects == null || objects.size() <= 0) {
            throw new ExportingException('exportData, no data')
        }
        if (!fields) {
            throw new ExportingException('exportData, no fields mapped')
        }
        CSVPrinter csvPrinter

        CSVFormat formatString = CSVFormat.EXCEL.withDelimiter(ExportConstant.Parameters.SEMICOLON)
                .withQuote(ExportConstant.Parameters.DOUBLE_QUOTES)
                .withQuoteMode(QuoteMode.ALL)

        CSVFormat formatNumber = CSVFormat.EXCEL.withDelimiter(ExportConstant.Parameters.SEMICOLON)
                .withEscape(ESCAPE)
                .withQuoteMode(QuoteMode.NONE)

        CSVPrinter csvPrinterString = new CSVPrinter(writer, formatString)
        CSVPrinter csvPrinterNumber = new CSVPrinter(writer, formatNumber)

        try {
            //Serve per stampare l'inizio del file
            csvPrinter = csvPrinterNumber
            csvPrinter.print("")

            csvPrinter = csvPrinterString
            // Enable/Disable header output
            boolean isHeaderEnabled = true
            if (parameters?.containsKey(ExportConstant.Parameters.HEADER_ENABLED)) {
                isHeaderEnabled = parameters.get(ExportConstant.Parameters.HEADER_ENABLED)
            }

            //Create header
            if (isHeaderEnabled) {
                for (String s : fields) {
                    csvPrinter.print((labels ? labels.get(s) : s))
                }
                csvPrinter.println()
            }

            //Rows
            for (int dataIdx = 0; dataIdx < objects.size(); dataIdx++) {
                def row = objects.get(dataIdx)

                for (int fieldIdx = 0; fieldIdx < fields.size(); fieldIdx++) {

                    String key = fields.get(fieldIdx)
                    def value
                    if (key.contains(".")) {
                        String toEval = "row." + key
                        toEval = toEval.replace(".", "?.")
                        value = Eval.me("row", row, toEval)
                    } else {
                        value = row[key]
                    }

                    if (value == null) {
                        value = ''
                    } else if (value instanceof Date) {
                        value = ExportConstant.dtf.format(value)

                    } else if (value instanceof BigDecimal) {
                        csvPrinter = csvPrinterNumber
                        value = ExportConstant.decimp.format(value)
                    }

                    csvPrinter.print(value)
                    csvPrinter = csvPrinterString
                }
                csvPrinter.println()
            }
            boolean close = true
            if (parameters?.containsKey(ExportConstant.Parameters.CLOSE)) {
                close = Boolean.valueOf(parameters.get(ExportConstant.Parameters.CLOSE)?.toString())
            }
            if (close) {
                csvPrinter.flush()
                csvPrinter.close()
            }
        } catch (Throwable t) {
            StringWriter sw = new StringWriter()
            PrintWriter pw = new PrintWriter(sw)
            t.printStackTrace(pw)
            log.error("Error during export: ${sw.toString()}")
        }
    }
}