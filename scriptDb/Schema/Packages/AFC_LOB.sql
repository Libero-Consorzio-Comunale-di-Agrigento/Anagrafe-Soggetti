CREATE OR REPLACE PACKAGE afc_lob
IS
/******************************************************************************
 NOME:        AFC_LOB.
 DESCRIZIONE: Funzioni per la gestione degli oggetti di tipo LOB.
 ANNOTAZIONI: .
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 00   30/08/2006 FT     Prima emissione.
 01   28/08/2007 FT     Aggiunte 2 versioni di to_blob (per varchar2 e clob),
                        decode_value, versione di to_clob per blob e sql_execute.
 02   11/09/2007 MM     Aggiunta replace_clob.
 03   31/10/2007 FT     Aggiunto nvl_clob
 04  19/06/2009  MM     resa pubblica riempi_text_table ed inserimento di
                        set_row_len, c_add, c_replace, c_substr, c_instr, encode_utf8.
******************************************************************************/
   s_revisione   CONSTANT afc.t_revision := 'V1.04';
   FUNCTION versione
      RETURN VARCHAR2;
   -- Trasforma stringa in CLOB
   FUNCTION TO_CLOB (
      p_testo        IN   VARCHAR2,
      p_empty_clob   IN   BOOLEAN DEFAULT FALSE
   )
      RETURN CLOB;
   FUNCTION TO_CLOB (p_testo IN BLOB, p_empty_clob IN BOOLEAN DEFAULT FALSE)
      RETURN CLOB;
   FUNCTION to_blob (
      p_testo        IN   VARCHAR2,
      p_empty_blob   IN   BOOLEAN DEFAULT FALSE
   )
      RETURN BLOB;
   FUNCTION to_blob (p_testo IN CLOB, p_empty_blob IN BOOLEAN DEFAULT FALSE)
      RETURN BLOB;
   FUNCTION decode_value (
      p_check_value     IN   CLOB,
      p_against_value   IN   CLOB,
      p_then_result     IN   CLOB,
      p_else_result     IN   CLOB
   )
      RETURN CLOB;
   -- Esecuzione istruzione dinamica contenuta nel clob
   PROCEDURE sql_execute (p_testo IN CLOB);
   -- Sostituzione di tutte le occorrenze di una stringa nel clob
   FUNCTION replace_clob (
      p_srcclob       IN   CLOB,
      p_replacestr    IN   VARCHAR2,
      p_replacewith   IN   VARCHAR2
   )
      RETURN CLOB;
   FUNCTION nvl_clob (p_check_value IN CLOB, p_then_result IN CLOB)
      RETURN CLOB;
   PROCEDURE riempi_text_table (
      p_text_table   IN OUT   DBMS_SQL.varchar2s,
      p_testo        IN       CLOB
   );
   FUNCTION C_ADD (in_clob IN CLOB, in_text IN VARCHAR2)
      RETURN CLOB;
   FUNCTION C_REPLACE (
      in_clob      IN   CLOB,
      in_search    IN   VARCHAR2,
      in_replace   IN   VARCHAR2
   )
      RETURN CLOB;
   PROCEDURE set_row_len (p_len INTEGER);
   FUNCTION C_SUBSTR (
      in_clob     IN   CLOB,
      in_start    IN   NUMBER,
      in_amount   IN   NUMBER DEFAULT NULL
   )
      RETURN CLOB;
   FUNCTION C_INSTR (
      in_clob      IN   CLOB,
      in_pattern   IN   VARCHAR2,
      in_start     IN   NUMBER DEFAULT 1,
      in_nth       IN   NUMBER DEFAULT 1,
      in_reverse   IN   NUMBER DEFAULT 0
   )
      RETURN NUMBER;
   FUNCTION encode_utf8 (in_text IN CLOB)
      RETURN CLOB;
END afc_lob;
/

