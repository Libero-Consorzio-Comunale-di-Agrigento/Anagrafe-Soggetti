ALTER TABLE ANAGRAFICI ADD (
  CONSTRAINT ANAGRAFICI_COMPETENZA_ES_CC
  CHECK (COMPETENZA_ESCLUSIVA is null or ( COMPETENZA_ESCLUSIVA in ('E','P') ))
  ENABLE VALIDATE);

ALTER TABLE ANAGRAFICI ADD (
  CONSTRAINT ANAGRAFICI_COMUNE_NAS_CC
  CHECK (COMUNE_NAS is null or (COMUNE_NAS between 0 and 999 ))
  ENABLE VALIDATE);

ALTER TABLE ANAGRAFICI ADD (
  CONSTRAINT ANAGRAFICI_NI_CC
  CHECK (NI >= 0)
  ENABLE VALIDATE);

ALTER TABLE ANAGRAFICI ADD (
  CONSTRAINT ANAGRAFICI_PROVINCIA_NAS_CC
  CHECK (PROVINCIA_NAS is null or (PROVINCIA_NAS between 0 and 999 ))
  ENABLE VALIDATE);

ALTER TABLE ANAGRAFICI ADD (
  CONSTRAINT ANAGRAFICI_SESSO_CC
  CHECK (SESSO is null or ( SESSO in ('F','M') ))
  ENABLE VALIDATE);

ALTER TABLE ANAGRAFICI ADD (
  CONSTRAINT ANAGRAFICI_STATO_SOGGETT_CC
  CHECK (STATO_SOGGETTO in ('U','C'))
  ENABLE VALIDATE);

ALTER TABLE ANAGRAFICI ADD (
  CONSTRAINT ANAG_PK
  PRIMARY KEY
  (ID_ANAGRAFICA)
  USING INDEX ANAG_PK
  ENABLE VALIDATE);

