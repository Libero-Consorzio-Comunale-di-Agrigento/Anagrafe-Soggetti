CREATE OR REPLACE PACKAGE AFC IS
/******************************************************************************
 Procedure e Funzioni di utilita' comune.
 REVISIONI.
 Rev.  Data        Autore  Descrizione
 ----  ----------  ------  ----------------------------------------------------
 00    20/01/2003  MM      Prima emissione.
 01    18/03/2005  MF      Adozione nello Standard AFC (nessuna modifica).
 02    26/04/2005  CZ      Aggiunte to_boolean e xor.
 03    14/06/2005  MM      Creazione get_substr.
 04    01/09/2005  FT      Aggiunta dei metodi protect_wildcard, version, aggiunta dei subtype t_object_name, t_message, t_statement, t_revision.
 05    27/09/2005  MF      Cambio nomenclatura s_revisione e s_revisione_body; tolta dipendenza get_stringParm da Package Si4.
 06    24/11/2005  FT      Aggiunta di mxor.
 07    04/01/2006  MM      Aggiunta is_number.
 08    12/01/2006  MM      Aggiunta is_numeric e to_number(p_value in varchar2).
 09    01/02/2006  FT      Aumento di parametri per mxor.
 10    22/02/2006  FT      Aggiunta dei metodi get_field_condition e decode_value e del type t_ref_cursor.
 11    02/03/2006  FT      Aggiunta della function SQL_execute.
 12    21/03/2006  MF      Get_filed_condition: Introdotto prefix e suffix.
 13    19/05/2006  FT      Aggiunta metodo to_clob.
 14    25/06/2006  MF      Parametro in to_clob per ottenere empty in caso di null.
 15    28/06/2006  FT      Aggiunta funzione date_format e parametro p_date_format in get_field_condition.
 16    30/08/2006  FT      Modifica dichiarazione subtype per incompatibilità con versione 7 di Oracle; eliminazione della funzione to_clob.
 17    19/10/2006  FT      Aggiunta funzione quote.
 18    30/10/2006  FT      Aggiunta funzione countOccurrenceOf.
 19    21/12/2006  FT      Aggiunta funzione init_cronologia.
 20    27/02/2007  FT      Spostata funzione init_cronologia nel package SI4.
 21    14/03/2007  FT      Aggiunta overloading di get_field_condition per p_field_value di tipo DATE.
 22    06/04/2009  MF      Aggiunte funzioni di "default_null".
 23    25/09/2009  FT      Eliminate doppie definizioni di "default_null".
 24    14/10/2009  FT      Aggiunto metodo string_extract.
 25    29/04/2010  FT      Aggiunto parametro p_delimitatori in string_extract per indicare se restituire o meno i delimitatori.
 26    11/11/2010  SN      Aggiunto parametro nella get_substr per decidere se tenere Inizio o Fine stringa.
 27    03/05/2011  FT      Aggiunti years_between, months_between, days_between hours_between, minutes_between e seconds_between.
 28    07/07/2011  FT      Allineati i commenti col nuovo standard di plsqldoc.
******************************************************************************/

   -- Variabile utilizzata per la definizione del subtype t_revision
   d_revision  varchar2(30);
   -- Type definition of the package version
   subtype t_revision is d_revision%type;
   -- Variabile utilizzata per la definizione del subtype t_object_name
   d_object_name  varchar2(30);
   -- Type definition of a database object name
   subtype t_object_name is d_object_name%type;
   -- Variabile utilizzata per la definizione del subtype t_message
   d_message  varchar2(1000);
   -- Type definition of an output message
   subtype t_message is d_message%type;
   -- Variabile utilizzata per la definizione del subtype t_statement
   d_statement  varchar2(32000);
   -- Type definition of a string statement
   subtype t_statement is d_statement%type;
   -- Type definition of a ref_cursor
   type t_ref_cursor is ref cursor;
   -- Costante per gestione get_substr - prima_occorrenza
   prima_occorrenza  constant varchar2(1):='P';
   -- Costante per gestione get_substr - ultima_occorrenza
   ultima_occorrenza constant varchar2(1):='U';
   -- Costante per gestione get_substr - inizio_stringa
   inizio_stringa    constant varchar2(1):='I';
   -- Costante per gestione get_substr - fine_stringa
   fine_stringa      constant varchar2(1):='F';
   -- Package revision value
   s_revisione t_revision := 'V1.28';
   

   /******************************************************************************
    Restituisce versione e revisione di distribuzione del package.
    %return varchar2: contiene versione e revisione.
    %note <UL>
          <LI> Primo numero: versione compatibilita del Package.</LI>
          <LI> Secondo numero: revisione del Package specification.</LI>
          <LI> Terzo numero: revisione del Package body.</LI>
          </UL>
   ******************************************************************************/
   function versione return t_revision;
   pragma restrict_references(versione, WNDS, WNPS);
   /******************************************************************************
    Restituisce versione e revisione di distribuzione del package.
    %param p_revisione:      revisione del Package specification.
    %param p_revision_body:  revisione del Package body.
    %return varchar2: contiene versione e revisione.
    %note <UL>
          <LI> Primo numero: versione compatibilita del Package.</LI>
          <LI> Secondo numero: revisione del Package specification.</LI>
          <LI> Terzo numero: revisione del Package body.</LI>
          </UL>
   ******************************************************************************/
   function version
   ( p_revisione t_revision
   , p_revisione_body t_revision
   ) return t_revision;
   pragma restrict_references(version, WNDS, WNPS );
   /******************************************************************************
    Ottiene la stringa precedente alla stringa di separazione, modificando
    la stringa di partenza con la parte seguente, escludendo la stringa di
    separazione
    %usage Da stringa ABCD con sub-stringa B ritorna A modificando l'originale in CD.
    %param p_stringa:      Stringa da esaminare.
    %param p_separatore:   Stringa di separazione.
    %return varchar2: <UL>
                      <LI> se trovata stringa di separazione: la sottostringa;
                      <LI> se non trovata: la stringa originale.
                     </UL>
   ******************************************************************************/
   function get_substr
   ( p_stringa    IN OUT varchar2
   , p_separatore IN     varchar2
   ) return VARCHAR2;
   pragma restrict_references(get_substr, WNDS);
   /******************************************************************************
    Ottiene la stringa precedente alla stringa di separazione.
    %param p_stringa:     Stringa da esaminare.
    %param p_separatore:  Stringa di separazione.
    %param p_occorrenza:  P o U a seconda che si voglia considerare la Prima o l'ultima occorrenza della stringa di separazione
    %param p_parte:       I o F a seconda che si voglia tenere l'Inizio o la Fine della stringa
    %return varchar2: <UL>
                      <LI> se trovata stringa di separazione: la sottostringa;
                      <LI> se non trovata: la stringa originale.
                     </UL>
   ******************************************************************************/
   function get_substr
   ( p_stringa    IN  varchar2
   , p_separatore IN  varchar2
   , p_occorrenza IN  varchar2
   , p_parte      IN  varchar2 default inizio_stringa
   ) return VARCHAR2;
   pragma restrict_references(get_substr, WNDS);
   /******************************************************************************
    Estrapola un Parametro da una Stringa.
    %param p_stringa:        varchar2 Valore contenente la stringa da esaminare.
    %param p_identificativo: varchar2 Stringa identificativa del Parametro da estrarre.
    %return varchar2: valore del parametro estrapolato dalla stringa.
    %note L'identificativo puo essere:
           {*} /x seguito da " " (spazio) - Case sensitive.
           {*} -x seguito da " " (spazio) - Case sensitive.
           {*} X  seguito da "=" (uguale) - Ignore Case.
    Se il Parametro inizia con "'" (apice) o '"' (doppio apice) viene estratto fino al prossimo apice o doppio apice; altrimenti viene estratto fino allo " " (spazio).
   ******************************************************************************/
   function get_stringParm
   ( p_stringa        IN VARCHAR2
   , p_identificativo IN VARCHAR2
   ) return VARCHAR2;
   pragma restrict_references(get_stringParm, WNDS);
   /******************************************************************************
    Preleva la parte di stringa compresa/esclusa dai delimitatori indicati come parametro.
    %usage <UL>
           <LI> se p_include è TRUE ritorna la parte compresa, se FALSE ritorna la parte esclusa;
           <LI> se p_delimitatori è true restituisce anche i delimitatori, se false no
           </UL>
    %param p_stringa
    %param p_left
    %param p_right
    %param p_include
    %param p_delimitatori
    %return varchar2: la parte di stringa estratta secondo le condizioni passate
   ******************************************************************************/
   function string_extract
   ( p_stringa in varchar2
   , p_left in varchar2
   , p_right in varchar2
   , p_include in boolean default true
   , p_delimitatori in boolean default false
   ) return afc.t_statement;
   /******************************************************************************
    Numero di occorrenze di p_sottostringa in p_stringa.
    %param p_stringa:      stringa nella in esame
    %param p_sottostringa: stringa da ricercare nella stringa in esame
    %return number: il numero di occorrenze
   ******************************************************************************/
   function countOccurrenceOf
   ( p_stringa in varchar2
   , p_sottostringa in varchar2)
   return number;
   /******************************************************************************
    Protezione dei caratteri speciali ('_' e '%') nella stringa p_stringa.
    %param p_stringa: stringa da elaborare
    %return varchar2: stringa protetta
   ******************************************************************************/
   function protect_wildcard
   ( p_stringa        IN VARCHAR2
   ) return VARCHAR2;
   pragma restrict_references(protect_wildcard, WNDS);
   /******************************************************************************
    Gestione apici (aggiunta di quelli esterni e raddoppio di quelli interni) per la stringa p_stringa
    %param p_stringa: stringa da elaborare
    %return varchar2: Stringa elaborata
   ******************************************************************************/
   function quote
   ( p_stringa   in varchar2
   ) return varchar2;
   /******************************************************************************
    Conversione booleana di valori number (1,0).
    %param p_value: number: 1 o 0.
    %return boolean: true se 1, false se 0.
    %note Accetta solo argomenti validi (non nulli: NON implementa logica booleana estesa al null).
   ******************************************************************************/
   function to_boolean
   ( p_value in number
   ) return boolean;
   pragma restrict_references( to_boolean, WNDS );
   /******************************************************************************
    Conversione number di valori booleani.
    %param p_value: boolean: true o false.
    %return boolean: 1 se true, 0 se false.
    %note Accetta solo argomenti validi (non nulli: NON implementa logica booleana estesa al null).
   ******************************************************************************/
   function to_number
   ( p_value in boolean
   ) return number;
   pragma restrict_references( to_number, WNDS );
   /******************************************************************************
    Conversione number di stringhe.
    %param p_value: varchar2.
    %raises ORA-06502 in caso la stringa passata non sia un numero.
    %return number: corrispondente o exception.
   ******************************************************************************/
   function to_number
   ( p_value in varchar2
   ) return number;
   pragma restrict_references( to_number, WNDS );
   /******************************************************************************
    Esegue lo statement passato.
    %param p_stringa: statement sql da eseguire
   ******************************************************************************/
   procedure SQL_execute
   ( p_stringa t_statement
   );
   /******************************************************************************
    Esegue lo statement passato e rotorna il valore di ritorno.
    %param p_stringa: varchar2 statement sql da eseguire.
    %return varchar2: il valore di ritorno dello statement SQL p_stringa.
   ******************************************************************************/
   function SQL_execute
   ( p_stringa t_statement
   ) return varchar2;
   /******************************************************************************
    Operatore booleano di or esclusivo.
    %param p_value_1: boolean
    %param p_value_2: boolean
    %return boolean
    %note Accetta solo argomenti validi (non nulli: NON implementa logica booleana estesa al null).
   ******************************************************************************/
   function xor
   ( p_value_1 in boolean
   , p_value_2 in boolean
   ) return boolean;
   pragma restrict_references( xor, WNDS );
   /******************************************************************************
    Operatore booleano di or esclusivo.
    %param p_value_1: boolean
    %param p_value_2: boolean
    %param p_value_3: boolean
    %return boolean
    %note Accetta solo argomenti validi (non nulli: NON implementa logica booleana estesa al null).
   ******************************************************************************/
   function xor
   ( p_value_1 in boolean
   , p_value_2 in boolean
   , p_value_3 in boolean
   ) return boolean;
   pragma restrict_references( xor, WNDS );
   /******************************************************************************
    Operatore booleano di or esclusivo.
    %param p_value_1: boolean
    %param p_value_2: boolean
    %param p_value_3: boolean
    %param p_value_4: boolean
    %return boolean
    %note Accetta solo argomenti validi (non nulli: NON implementa logica booleana estesa al null).
   ******************************************************************************/
   function xor
   ( p_value_1 in boolean
   , p_value_2 in boolean
   , p_value_3 in boolean
   , p_value_4 in boolean
   ) return boolean;
   pragma restrict_references( xor, WNDS );
   /******************************************************************************
    Operatore booleano di or esclusivo: ritorna true se solo uno dei parametri e true e tutti gli altri sono false.
    %param p_value_1: boolean
    %param p_value_2: boolean
    %param p_value_3: boolean
    %param p_value_4: boolean
    %param p_value_5: boolean
    %param p_value_6: boolean
    %param p_value_7: boolean
    %param p_value_8: boolean
    %return boolean
    %note Funziona per 2, 3, 4, 5, 6, 7 e 8 operandi.
   ******************************************************************************/
   function mxor
   ( p_value_1 in boolean
   , p_value_2 in boolean
   , p_value_3 in boolean default false
   , p_value_4 in boolean default false
   , p_value_5 in boolean default false
   , p_value_6 in boolean default false
   , p_value_7 in boolean default false
   , p_value_8 in boolean default false
   ) return boolean;
   pragma restrict_references( mxor, WNDS );
   /******************************************************************************
    Verifica che la stringa passata sia un numero.
    %param p_char: varchar2 stringa da controllare.
    %return number: {*} 1 e' un numero
                    {*} 0 NON e' un numero
    %note In caso che p_char sia nullo, la funzione ritorna 1.
   ******************************************************************************/
   function is_number
   ( p_char in varchar2) return number;
   pragma restrict_references( is_number, WNDS );
   /******************************************************************************
    Verifica che la stringa passata sia formata da soli numeri.
    %param p_char: varchar2 stringa da controllare.
    %return number: {*} 1 e' formata da soli numeri
                    {*} 0 NON e' formata da soli numeri
    %note In caso che p_char sia nullo, la funzione ritorna 0. La lunghezza massima della stringa passata e' 32000.
   ******************************************************************************/
   function is_numeric
   ( p_char in varchar2) return number;
   pragma restrict_references( is_numeric, WNDS );
   /******************************************************************************
    Ottiene stringa con condizione SQL.
    %param p_prefix:       stringa per prefissare la condizione
    %param p_field_value:  valore da controllare
    %param p_suffix:       stringa per suffissare la condizione
    %param p_flag:         {*} '0' se p_field_value inizia con un operatore viene usato quello,
                                   senno viene usato l'operatore '='
                           {*} '1' condizione indicata in valore
    %param p_date_format:  se p_field_value e di tipo date, contiene il formato da utilizzare
                           per effettuare la conversione
    %return varchar2: stringa SQL
    %note Se p_field_value e NULL ritorna NULL.
   ******************************************************************************/
   function get_field_condition
   ( p_prefix      in varchar2
   , p_field_value in varchar2
   , p_suffix      in varchar2
   , p_flag        in number   default 0
   , p_date_format in varchar2 default null
   ) return varchar2;
   /******************************************************************************
    Ottiene stringa con condizione SQL.
    %param p_prefix:       stringa per prefissare la condizione
    %param p_field_value:  valore da controllare
    %param p_suffix:       stringa per suffissare la condizione
    %param p_flag:         {*} '0' condizione per uguale
                           {*} '1' condizione indicata in valore
    %param p_date_format:  se p_field_value e di tipo date, contiene il formato da
                           utilizzare per effettuare la conversione
    %return varchar2: stringa SQL
    %note Overloading per field_value di tipo DATE
   ******************************************************************************/
   function get_field_condition
   ( p_prefix      in varchar2
   , p_field_value in date
   , p_suffix      in varchar2
   , p_flag        in number   default 0
   , p_date_format in varchar2 default null
   ) return varchar2;
   /******************************************************************************
    Istruzione "decode" per PL/SQL.
    %param p_check_value:    valore da controllare
    %param p_against_value:  valore di confronto
    %param p_then_result:    risultato per uguale
    %param p_else_result:    risultato per diverso
    %return varchar2
   ******************************************************************************/
   function decode_value
   ( p_check_value in varchar2
   , p_against_value in varchar2
   , p_then_result in varchar2
   , p_else_result in varchar2
   ) return varchar2;
   /******************************************************************************
    Ritorna il formato standard di conversione di una data.
    %return varchar2: contenente il formato data
   ******************************************************************************/
   function date_format
   return varchar2;
   /******************************************************************************
    Memorizza nome item per gestione "default_null".
   ******************************************************************************/
   procedure default_null
   (
    p_item_name  in varchar2 default null
   );
   /******************************************************************************
    Ritorna valore NULL per inizializzazione default value e memorizza nome item per gestione "default_null".
    %return varchar2
   ******************************************************************************/
   function default_null
   (
    p_item_name  in varchar2 default null
   ) return varchar2;
   /******************************************************************************
    Ritorna 1 se nome item è stato valorizzato con gestione "default_null".
    %return number: {*} 1 se item inizializzato a null
                    {*} 0 se item non inizializzato.
   ******************************************************************************/
   function is_default_null
   (
    p_item_name  in varchar2
   ) return number;
   /******************************************************************************
    Ritorna il numero di anni che intercorrono tra la data p_dal e la data p_al.
    %param p_dal:  data di inizio del periodo da trattare;
    %param p_al:   data di fine del periodo da trattare;
    %param p_left: consente di indicare se si desidera il conteggio delle unità precedenti (mesi, giorni, ecc...) che verranno rappresentate nella parte decimale; se 1 non vengono trattate;
    %return number: il numero di anni che intercorrono tra la data p_dal e la data p_al.
   ******************************************************************************/
   function years_between
   ( p_dal date
   , p_al date
   , p_left integer default 0
   ) return number;
   /******************************************************************************
    Ritorna il numero di mesi che intercorrono tra la data p_dal e la data p_al.
    %param p_dal:   data di inizio del periodo da trattare;
    %param p_al:    data di fine del periodo da trattare;
    %param p_trunc: consente di indicare che si desidera il conteggio delle unità superiori a quella trattata (anni); se 1 non vengono trattate;
    %param p_left:  consente di indicare se si desidera il conteggio delle unità precedenti (giorni, ore, ecc...) che verranno rappresentate nella parte decimale; se 1 non vengono trattate;
    %return number: il numero di mesi che intercorrono tra la data p_dal e la data p_al.
   ******************************************************************************/
   function months_between
   ( p_dal date
   , p_al date
   , p_trunc integer default 0
   , p_left integer default 0
   ) return number;
   /******************************************************************************
    Ritorna il numero di giorni che intercorrono tra la data p_dal e la data p_al.
    %param p_dal:   data di inizio del periodo da trattare;
    %param p_al:    data di fine del periodo da trattare;
    %param p_trunc: consente di indicare che si desidera il conteggio delle unità superiori a quella trattata (anni, mesi); se 1 non vengono trattate;
    %param p_left:  consente di indicare se si desidera il conteggio delle unità precedenti (ore, minuti, ecc...) che verranno rappresentate nella parte decimale; se 1 non vengono trattate;
    %return number: il numero di giorni che intercorrono tra la data p_dal e la data p_al.
   ******************************************************************************/
   function days_between
   ( p_dal date
   , p_al date
   , p_trunc integer default 0
   , p_left integer default 0
   ) return number;
   /******************************************************************************
    Ritorna il numero di ore che intercorrono tra la data p_dal e la data p_al.
    %param p_dal:   data di inizio del periodo da trattare;
    %param p_al:    data di fine del periodo da trattare;
    %param p_trunc: consente di indicare che si desidera il conteggio delle unità superiori a quella trattata (anni, mesi, ecc...); se 1 non vengono trattate;
    %param p_left:  consente di indicare se si desidera il conteggio delle unità precedenti (minuti, secondi) che verranno rappresentate nella parte decimale; se 1 non vengono trattate;
    %return number: il numero di ore che intercorrono tra la data p_dal e la data p_al.
   ******************************************************************************/
   function hours_between
   ( p_dal date
   , p_al date
   , p_trunc integer default 0
   , p_left integer default 0
   ) return number;
   /******************************************************************************
    Ritorna il numero di minuti che intercorrono tra la data p_dal e la data p_al.
    %param p_dal:   data di inizio del periodo da trattare;
    %param p_al:    data di fine del periodo da trattare;
    %param p_trunc: consente di indicare che si desidera il conteggio delle unità superiori a quella trattata (anni, mesi, ecc...); se 1 non vengono trattate;
    %param p_left:  consente di indicare se si desidera il conteggio delle unità precedenti (secondi) che verranno rappresentate nella parte decimale; se 1 non vengono trattate;
    %return number: il numero di minuti che intercorrono tra la data p_dal e la data p_al.
   ******************************************************************************/
   function minutes_between
   ( p_dal date
   , p_al date
   , p_trunc integer default 0
   , p_left integer default 0
   ) return number;
   /******************************************************************************
    Ritorna il numero di secondi che intercorrono tra la data p_dal e la data p_al.
    %param p_dal:   data di inizio del periodo da trattare;
    %param p_al:    data di fine del periodo da trattare;
    %param p_trunc: consente di indicare che si desidera il conteggio delle unità superiori a quella trattata (anni, mesi, ecc...); se 1 non vengono trattate;
    %return number: il numero di secondi che intercorrono tra la data p_dal e la data p_al.
   ******************************************************************************/
   function seconds_between
   ( p_dal date
   , p_al date
   , p_trunc integer default 0
   ) return number;
end afc;
/

