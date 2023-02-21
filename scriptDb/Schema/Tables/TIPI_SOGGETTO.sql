CREATE TABLE TIPI_SOGGETTO
(
  TIPO_SOGGETTO            VARCHAR2(1 BYTE)     NOT NULL,
  DESCRIZIONE              VARCHAR2(40 BYTE)    NOT NULL,
  FLAG_TRG                 VARCHAR2(1 BYTE),
  VERSION                  NUMBER,
  UTENTE_AGGIORNAMENTO     VARCHAR2(8 BYTE),
  DATA_AGGIORNAMENTO       DATE,
  CATEGORIA_TIPO_SOGGETTO  VARCHAR2(2 BYTE)     DEFAULT 'PF'                  NOT NULL
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

COMMENT ON TABLE TIPI_SOGGETTO IS 'TISO - Tipi soggetto';

COMMENT ON COLUMN TIPI_SOGGETTO.CATEGORIA_TIPO_SOGGETTO IS 'Indicazione della categoria del tipo soggetto: PF = Persona Fisica, PG = Persona Giuridica';



