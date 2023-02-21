CREATE TABLE REGISTRO_STORICO
(
  ID_EVENTO       NUMBER                        NOT NULL,
  CHIAVE          VARCHAR2(512 BYTE)            NOT NULL,
  STRINGA         VARCHAR2(100 BYTE)            NOT NULL,
  COMMENTO        VARCHAR2(2000 BYTE),
  VALORE          VARCHAR2(2000 BYTE),
  DATA            DATE                          NOT NULL,
  OPERAZIONE      VARCHAR2(2 BYTE),
  BI_RIFERIMENTO  NUMBER,
  UTENTE_AGG      VARCHAR2(8 BYTE),
  USER_ORACLE     VARCHAR2(30 BYTE),
  INFO            VARCHAR2(2000 BYTE),
  PROGRAMMA       VARCHAR2(50 BYTE)
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


