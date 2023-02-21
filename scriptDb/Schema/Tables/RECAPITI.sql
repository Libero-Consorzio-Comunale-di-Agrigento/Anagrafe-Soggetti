CREATE TABLE RECAPITI
(
  ID_RECAPITO           NUMBER                  NOT NULL,
  NI                    NUMBER(8)               NOT NULL,
  DAL                   DATE                    NOT NULL,
  AL                    DATE,
  DESCRIZIONE           VARCHAR2(60 BYTE),
  ID_TIPO_RECAPITO      NUMBER                  NOT NULL,
  INDIRIZZO             VARCHAR2(120 BYTE),
  PROVINCIA             NUMBER(3),
  COMUNE                NUMBER(3),
  CAP                   VARCHAR2(5 BYTE),
  PRESSO                VARCHAR2(40 BYTE),
  IMPORTANZA            NUMBER,
  COMPETENZA            VARCHAR2(8 BYTE),
  COMPETENZA_ESCLUSIVA  VARCHAR2(1 BYTE),
  VERSION               NUMBER                  DEFAULT 0,
  UTENTE_AGGIORNAMENTO  VARCHAR2(8 BYTE),
  DATA_AGGIORNAMENTO    DATE
)
TABLESPACE AS4
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            MAXSIZE          UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

COMMENT ON TABLE RECAPITI IS 'RECA- Recapiti';

COMMENT ON COLUMN RECAPITI.IMPORTANZA IS 'Valori: 1 alta - 99 bassa';



