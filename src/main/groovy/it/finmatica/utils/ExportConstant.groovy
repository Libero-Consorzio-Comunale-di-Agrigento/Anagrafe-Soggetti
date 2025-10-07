package it.finmatica.utils

import org.apache.commons.lang.time.FastDateFormat

import java.text.DecimalFormat
import java.text.DecimalFormatSymbols
import java.text.NumberFormat

class ExportConstant {
    public static final String TIME_FORMAT_PATTERN = "HH:mm:ss"
    public static final String DATE_FORMAT_PATTERN = "dd/MM/yyyy"
    public static final String DATE_TIME_FORMAT_PATTERN = DATE_FORMAT_PATTERN + " " + TIME_FORMAT_PATTERN
    public static final FastDateFormat df = FastDateFormat.getInstance(DATE_FORMAT_PATTERN)
    public static final FastDateFormat tf = FastDateFormat.getInstance(TIME_FORMAT_PATTERN)
    public static final FastDateFormat dtf = FastDateFormat.getInstance(DATE_TIME_FORMAT_PATTERN)
    public static final String DECIMAL_FORMAT_PATTERN = '#,##0.00000'
    public static final String DECIMAL_IMPORT_FORMAT = '0.##'
    public static final DecimalFormat decf = new DecimalFormat(DECIMAL_FORMAT_PATTERN)
    public static final DecimalFormat decimp = new DecimalFormat(DECIMAL_IMPORT_FORMAT, new DecimalFormatSymbols(Locale.ITALY))
    public static final NumberFormat intf = NumberFormat.getIntegerInstance()
    public static final int LOAD_SIZE_DEFAULT = 256


    static {
        intf.setGroupingUsed(false)
    }

    static class Parameters {

        public static final String CLOSE = 'close'
        public static final String FORMAT = 'format'
        public static final char SEMICOLON = ';'.toCharacter().charValue()
        public static final char DOUBLE_QUOTES = '"'.toCharacter().charValue()
        public static final String HEADER_ENABLED = "header.enabled"
    }
}
