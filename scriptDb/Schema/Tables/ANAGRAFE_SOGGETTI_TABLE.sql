CREATE TABLE ANAGRAFE_SOGGETTI_TABLE
(
  ID_ANAGRAFICA          NUMBER                 NOT NULL,
  NI                     NUMBER(8)              NOT NULL,
  DAL                    DATE                   NOT NULL,
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
  INDIRIZZO_RES          VARCHAR2(120 BYTE),
  PROVINCIA_RES          NUMBER(3),
  COMUNE_RES             NUMBER(3),
  CAP_RES                VARCHAR2(5 BYTE),
  TEL_RES                VARCHAR2(100 BYTE),
  FAX_RES                VARCHAR2(100 BYTE),
  PRESSO                 VARCHAR2(40 BYTE),
  INDIRIZZO_DOM          VARCHAR2(120 BYTE),
  PROVINCIA_DOM          NUMBER(3),
  COMUNE_DOM             NUMBER(3),
  CAP_DOM                VARCHAR2(5 BYTE),
  TEL_DOM                VARCHAR2(100 BYTE),
  FAX_DOM                VARCHAR2(100 BYTE),
  UTENTE                 VARCHAR2(8 BYTE),
  DATA_AGG               DATE,
  COMPETENZA             VARCHAR2(8 BYTE),
  COMPETENZA_ESCLUSIVA   VARCHAR2(1 BYTE),
  TIPO_SOGGETTO          VARCHAR2(1 BYTE),
  FLAG_TRG               VARCHAR2(1 BYTE),
  STATO_CEE              VARCHAR2(2 BYTE),
  PARTITA_IVA_CEE        VARCHAR2(14 BYTE),
  FINE_VALIDITA          DATE,
  AL                     DATE,
  DENOMINAZIONE          VARCHAR2(400 BYTE),
  INDIRIZZO_WEB          VARCHAR2(2000 BYTE),
  NOTE                   VARCHAR2(240 BYTE),
  VERSION                NUMBER(19)
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

COMMENT ON TABLE ANAGRAFE_SOGGETTI_TABLE IS 'ANST - Anagrafe Soggetti Table';



