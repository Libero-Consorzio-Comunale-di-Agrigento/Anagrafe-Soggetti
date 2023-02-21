CREATE INDEX RECS_IK ON RECAPITI_STORICO
(ID_RECAPITO)
TABLESPACE AS4
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            MAXSIZE          UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );


