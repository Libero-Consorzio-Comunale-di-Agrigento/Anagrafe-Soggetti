CREATE OR REPLACE FORCE VIEW AS4_V_TIPI_SOGGETTO
(TIPO_SOGGETTO, DESCRIZIONE, FLAG_TRG, CATEGORIA_TIPO_SOGGETTO)
BEQUEATH DEFINER
AS 
SELECT TIPO_SOGGETTO,
          DESCRIZIONE,
          FLAG_TRG,
          CATEGORIA_TIPO_SOGGETTO
     FROM AS4_TIPI_SOGGETTO;


