CREATE INDEX ANAG_COMU_NAS_FK ON ANAGRAFICI
(PROVINCIA_NAS, COMUNE_NAS)
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
           );


