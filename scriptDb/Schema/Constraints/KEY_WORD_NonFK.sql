ALTER TABLE KEY_WORD ADD (
  CONSTRAINT KEWO_PK
  PRIMARY KEY
  (TESTO, LINGUA)
  USING INDEX KEWO_PK
  ENABLE VALIDATE);
