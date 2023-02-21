CREATE TABLE IMMAGINI
(
  ID_IMMAGINE  NUMBER                           NOT NULL,
  IMAGE        BLOB
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

COMMENT ON TABLE IMMAGINI IS 'Archivio Immagini';



