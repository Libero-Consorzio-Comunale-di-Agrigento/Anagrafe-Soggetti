CREATE TABLE CONTATTI
(
  ID_CONTATTO           NUMBER                  NOT NULL,
  ID_RECAPITO           NUMBER                  NOT NULL,
  DAL                   DATE                    NOT NULL,
  AL                    DATE,
  VALORE                VARCHAR2(100 BYTE)      NOT NULL,
  ID_TIPO_CONTATTO      NUMBER                  NOT NULL,
  NOTE                  VARCHAR2(2000 BYTE),
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

COMMENT ON TABLE CONTATTI IS 'CONT - Contatti';

COMMENT ON COLUMN CONTATTI.IMPORTANZA IS 'Valori: 1 alta - 99 bassa';



