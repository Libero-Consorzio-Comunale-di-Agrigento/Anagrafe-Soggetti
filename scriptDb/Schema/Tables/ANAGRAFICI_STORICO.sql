CREATE TABLE ANAGRAFICI_STORICO
(
  ID_EVENTO              NUMBER                 NOT NULL,
  ID_ANAGRAFICA          NUMBER                 NOT NULL,
  NI                     NUMBER(8)              NOT NULL,
  DAL                    DATE                   NOT NULL,
  AL                     DATE,
  COGNOME                VARCHAR2(240 BYTE)     NOT NULL,
  NOME                   VARCHAR2(150 BYTE),
  SESSO                  VARCHAR2(1 BYTE),
  DATA_NAS               DATE,
  PROVINCIA_NAS          NUMBER(3),
  COMUNE_NAS             NUMBER(3),
  LUOGO_NAS              VARCHAR2(30 BYTE),
  CODICE_FISCALE         VARCHAR2(16 BYTE),
  CODICE_FISCALE_ESTERO  VARCHAR2(40 BYTE),
  PARTITA_IVA            VARCHAR2(11 BYTE),
  CITTADINANZA           VARCHAR2(3 BYTE),
  GRUPPO_LING            VARCHAR2(4 BYTE),
  COMPETENZA             VARCHAR2(8 BYTE),
  COMPETENZA_ESCLUSIVA   VARCHAR2(1 BYTE),
  TIPO_SOGGETTO          VARCHAR2(1 BYTE),
  STATO_CEE              VARCHAR2(2 BYTE),
  PARTITA_IVA_CEE        VARCHAR2(14 BYTE),
  FINE_VALIDITA          DATE,
  STATO_SOGGETTO         VARCHAR2(1 BYTE)       DEFAULT 'U'                   NOT NULL,
  DENOMINAZIONE          VARCHAR2(400 BYTE),
  NOTE                   VARCHAR2(240 BYTE),
  VERSION                NUMBER                 DEFAULT 0,
  UTENTE                 VARCHAR2(8 BYTE),
  DATA_AGG               DATE                   DEFAULT SYSDATE,
  DATA                   DATE                   NOT NULL,
  OPERAZIONE             VARCHAR2(2 BYTE),
  BI_RIFERIMENTO         NUMBER,
  UTENTE_AGGIORNAMENTO   VARCHAR2(8 BYTE),
  USER_ORACLE            VARCHAR2(30 BYTE),
  INFO                   VARCHAR2(2000 BYTE),
  PROGRAMMA              VARCHAR2(50 BYTE)
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

COMMENT ON TABLE ANAGRAFICI_STORICO IS 'ANAS - ANAGRAFICI STORICO';

COMMENT ON COLUMN ANAGRAFICI_STORICO.OPERAZIONE IS 'I=Insert, D=Delete, BI=Before Image, AI=After Image';

COMMENT ON COLUMN ANAGRAFICI_STORICO.BI_RIFERIMENTO IS 'id_evento di Before Image di riferimento';



