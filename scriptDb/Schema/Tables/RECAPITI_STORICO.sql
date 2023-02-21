CREATE TABLE RECAPITI_STORICO
(
  ID_EVENTO             NUMBER                  NOT NULL,
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
  UTENTE_AGG            VARCHAR2(8 BYTE),
  DATA_AGGIORNAMENTO    DATE,
  DATA                  DATE                    NOT NULL,
  OPERAZIONE            VARCHAR2(2 BYTE),
  BI_RIFERIMENTO        NUMBER,
  UTENTE_AGGIORNAMENTO  VARCHAR2(8 BYTE),
  USER_ORACLE           VARCHAR2(30 BYTE),
  INFO                  VARCHAR2(2000 BYTE),
  PROGRAMMA             VARCHAR2(50 BYTE)
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

COMMENT ON TABLE RECAPITI_STORICO IS 'RECS - RECAPITI STORICO';

COMMENT ON COLUMN RECAPITI_STORICO.OPERAZIONE IS 'I=Insert, D=Delete, BI=Before Image, AI=After Image';

COMMENT ON COLUMN RECAPITI_STORICO.BI_RIFERIMENTO IS 'id_evento di Before Image di riferimento';



