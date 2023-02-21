CREATE OR REPLACE FORCE VIEW TUTTI_NI_DAL_RES_DOM_OK_VIEW
(NI, DAL)
BEQUEATH DEFINER
AS 
SELECT NI, DAL
     FROM ANAGRAFICI Anag
   UNION
   SELECT Anag.NI, GREATEST (anag.DAL, recapiti_dom.dal)
     FROM ANAGRAFICI Anag, recapiti recapiti_dom
    WHERE     anag.ni = recapiti_dom.ni
          AND NOT EXISTS
                 (SELECT 1
                    FROM anagrafici
                   WHERE     dal = GREATEST (anag.DAL, recapiti_dom.dal)
                         AND ni = anag.ni)
          AND anag.dal != GREATEST (anag.DAL, recapiti_dom.dal)
          AND (recapiti_dom.id_tipo_recapito =
                  (SELECT id_tipo_recapito
                     FROM tipi_recapito
                    WHERE (descrizione) = 'DOMICILIO'))
   UNION
   SELECT Anag.NI, GREATEST (anag.DAL, recapiti_res.dal)
     FROM ANAGRAFICI Anag, recapiti recapiti_res
    WHERE     anag.ni = recapiti_res.ni
          AND NOT EXISTS
                 (SELECT 1
                    FROM anagrafici
                   WHERE     dal = GREATEST (anag.DAL, recapiti_res.dal)
                         AND ni = anag.ni)
          AND (recapiti_res.id_tipo_recapito =
                  (SELECT id_tipo_recapito
                     FROM tipi_recapito
                    WHERE (descrizione) = 'RESIDENZA'))
   UNION
   SELECT Anag.NI, GREATEST (anag.DAL, cont.dal)
     FROM ANAGRAFICI Anag, recapiti recapiti_dom, contatti cont
    WHERE     anag.ni = recapiti_dom.ni
          AND NOT EXISTS
                 (SELECT 1
                    FROM anagrafici
                   WHERE dal = GREATEST (anag.DAL, cont.dal) AND ni = anag.ni)
          AND anag.dal != GREATEST (anag.DAL, cont.dal)
          AND (recapiti_dom.id_tipo_recapito =
                  (SELECT id_tipo_recapito
                     FROM tipi_recapito
                    WHERE (descrizione) = 'DOMICILIO'))
          AND cont.id_recapito = recapiti_dom.id_recapito
          AND cont.id_tipo_contatto IN (SELECT id_tipo_contatto
                                          FROM tipi_contatto
                                         WHERE (descrizione) IN ('FAX',
                                                                 'TELEFONO',
                                                                 'MAIL'))
   UNION
   SELECT Anag.NI, GREATEST (anag.DAL, cont.dal)
     FROM ANAGRAFICI Anag, recapiti recapiti_res, contatti cont
    WHERE     anag.ni = recapiti_res.ni
          AND NOT EXISTS
                 (SELECT 1
                    FROM anagrafici
                   WHERE dal = GREATEST (anag.DAL, cont.dal) AND ni = anag.ni)
          AND anag.dal != GREATEST (anag.DAL, cont.dal)
          AND (recapiti_res.id_tipo_recapito =
                  (SELECT id_tipo_recapito
                     FROM tipi_recapito
                    WHERE (descrizione) = 'RESIDENZA'))
          AND cont.id_recapito = recapiti_res.id_recapito
          AND cont.id_tipo_contatto IN (SELECT id_tipo_contatto
                                          FROM tipi_contatto
                                         WHERE (descrizione) IN ('FAX',
                                                                 'TELEFONO',
                                                                 'MAIL'))
   -- estrazione come al anche i dal +1
   UNION
   SELECT Anag.NI,
            DECODE (
               anag.al,
               NULL, recapiti_dom.al,
               DECODE (recapiti_dom.al,
                       NULL, anag.al,
                       GREATEST (recapiti_dom.al, anag.al)))
          + 1
     FROM ANAGRAFICI Anag, recapiti recapiti_dom
    WHERE     anag.ni = recapiti_dom.ni
          AND NOT EXISTS
                 (SELECT 1
                    FROM anagrafici
                   WHERE     dal =
                                  DECODE (
                                     anag.al,
                                     NULL, recapiti_dom.al,
                                     DECODE (
                                        recapiti_dom.al,
                                        NULL, anag.al,
                                        GREATEST (recapiti_dom.al, anag.al)))
                                + 1
                         AND ni = anag.ni)
          AND (recapiti_dom.id_tipo_recapito =
                  (SELECT id_tipo_recapito
                     FROM tipi_recapito
                    WHERE (descrizione) = 'DOMICILIO'))
          AND (anag.AL IS NOT NULL OR recapiti_dom.al IS NOT NULL)
   UNION
   SELECT Anag.NI,
            DECODE (
               anag.al,
               NULL, recapiti_res.al,
               DECODE (recapiti_res.al,
                       NULL, anag.al,
                       GREATEST (recapiti_res.al, anag.al)))
          + 1
     FROM ANAGRAFICI Anag, recapiti recapiti_res
    WHERE     anag.ni = recapiti_res.ni
          AND NOT EXISTS
                 (SELECT 1
                    FROM anagrafici
                   WHERE     dal =
                                  DECODE (
                                     anag.al,
                                     NULL, recapiti_res.al,
                                     DECODE (
                                        recapiti_res.al,
                                        NULL, anag.al,
                                        GREATEST (recapiti_res.al, anag.al)))
                                + 1
                         AND ni = anag.ni)
          AND (recapiti_res.id_tipo_recapito =
                  (SELECT id_tipo_recapito
                     FROM tipi_recapito
                    WHERE (descrizione) = 'RESIDENZA'))
          AND (anag.AL IS NOT NULL OR recapiti_res.al IS NOT NULL)
   UNION
   SELECT Anag.NI,
            DECODE (
               anag.al,
               NULL, cont.al,
               DECODE (cont.al, NULL, anag.al, GREATEST (cont.al, anag.al)))
          + 1
     FROM ANAGRAFICI Anag, recapiti recapiti_dom, contatti cont
    WHERE     anag.ni = recapiti_dom.ni
          AND NOT EXISTS
                 (SELECT 1
                    FROM anagrafici
                   WHERE     dal =
                                  DECODE (
                                     anag.al,
                                     NULL, cont.al,
                                     DECODE (cont.al,
                                             NULL, anag.al,
                                             GREATEST (cont.al, anag.al)))
                                + 1
                         AND ni = anag.ni)
          AND (recapiti_dom.id_tipo_recapito =
                  (SELECT id_tipo_recapito
                     FROM tipi_recapito
                    WHERE (descrizione) = 'DOMICILIO'))
          AND cont.id_recapito = recapiti_dom.id_recapito
          AND cont.id_tipo_contatto IN (SELECT id_tipo_contatto
                                          FROM tipi_contatto
                                         WHERE (descrizione) IN ('FAX',
                                                                 'TELEFONO',
                                                                 'MAIL'))
          AND (anag.AL IS NOT NULL OR cont.al IS NOT NULL)
   UNION
   SELECT Anag.NI,
            DECODE (
               anag.al,
               NULL, cont.al,
               DECODE (cont.al, NULL, anag.al, GREATEST (cont.al, anag.al)))
          + 1
     FROM ANAGRAFICI Anag, recapiti recapiti_res, contatti cont
    WHERE     anag.ni = recapiti_res.ni
          AND NOT EXISTS
                 (SELECT 1
                    FROM anagrafici
                   WHERE     dal =
                                  DECODE (
                                     anag.al,
                                     NULL, cont.al,
                                     DECODE (cont.al,
                                             NULL, anag.al,
                                             GREATEST (cont.al, anag.al)))
                                + 1
                         AND ni = anag.ni)
          AND (recapiti_res.id_tipo_recapito =
                  (SELECT id_tipo_recapito
                     FROM tipi_recapito
                    WHERE (descrizione) = 'RESIDENZA'))
          AND cont.id_recapito = recapiti_res.id_recapito
          AND cont.id_tipo_contatto IN (SELECT id_tipo_contatto
                                          FROM tipi_contatto
                                         WHERE (descrizione) IN ('FAX',
                                                                 'TELEFONO',
                                                                 'MAIL'))
          AND (anag.AL IS NOT NULL OR cont.al IS NOT NULL);


