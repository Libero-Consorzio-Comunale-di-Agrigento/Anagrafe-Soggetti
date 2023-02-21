CREATE UNIQUE INDEX DR$ANAG_DENOM_RICERCA_CTX$X ON DR$ANAG_DENOM_RICERCA_CTX$I
(DR$TOKEN, DR$TOKEN_TYPE, DR$ROWID)
TABLESPACE AS4
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
COMPRESS 2;

