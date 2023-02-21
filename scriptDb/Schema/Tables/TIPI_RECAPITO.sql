CREATE TABLE TIPI_RECAPITO
(
  ID_TIPO_RECAPITO      NUMBER                  NOT NULL,
  DESCRIZIONE           VARCHAR2(60 BYTE)       NOT NULL,
  UNICO                 VARCHAR2(2 BYTE)        DEFAULT 'NO'                  NOT NULL,
  IMPORTANZA            NUMBER,
  VERSION               NUMBER,
  UTENTE_AGGIORNAMENTO  VARCHAR2(8 BYTE),
  DATA_AGGIORNAMENTO    DATE
)
TABLESPACE AS4
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

COMMENT ON TABLE TIPI_RECAPITO IS 'TIRE - Tipi Recapito';

COMMENT ON COLUMN TIPI_RECAPITO.IMPORTANZA IS 'Valori: 0 alta - 99 bassa';



