CREATE OR REPLACE PROCEDURE Anagrafe_Soggetti_Rri
/******************************************************************************
 NOME:        ANAGRAFE_SOGGETTI_RRI
 DESCRIZIONE: Gestisce la storicizzazione dei dati di un soggetto:
              - elimina eventuali registrazioni da con DAL >= nuovo DAL;
              - aggiorna la data di fine validita' dell'ultima registrazione
                storica.
 ARGOMENTI:   p_ni  IN number Numero Individuale del soggetto.
              p_dal IN date   Data di inizio validita' del soggetto.
 ECCEZIONI:
 ANNOTAZIONI: la procedure viene lanciata in Post Event dal trigger
              ANAGRAGE_SOGGETTI_TIU in seguito all'inserimento di un nuovo
              record.
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 0    11/02/2002 MM     Prima emissione.
 1    07/09/2005 MM     Gestione competenza in eliminazione di record storici.
 2    22/06/2006 MM     Gestione motivo_blocco di XX4_ANAGRAFE_SOGGETTI.
 3    01/09/2009 MM     Gestione competenza esclusiva del record da storicizzare.
 4    19/10/2009 MM     Errore se esistono piu' record in xx4_anagrafe_soggetti
                        per stessi ni e dal.
 5    13/12/2011 SNeg  Aggiunto parametro competenza_esclusiva e controllo sui valori
******************************************************************************/
( p_ni         IN NUMBER
, p_dal        IN DATE
, p_competenza IN VARCHAR2
, p_competenza_esclusiva IN VARCHAR2
, p_cognome    IN VARCHAR2
, p_nome       IN VARCHAR2
)
IS
   dDalStorico DATE;
   dCognomeStorico VARCHAR2(2000);
   dNomeStorico VARCHAR2(2000);
   d_al DATE;
   dCompetenza varchar2(100);
   dCompetenzaEsclusiva varchar2(10);
   d_result         AFC_Error.t_error_number;
BEGIN
   SELECT MAX(NVL(al,TRUNC(SYSDATE)) + 1)
     INTO d_al
    FROM ANAGRAFE_SOGGETTI
   WHERE ni = p_ni
     AND p_dal BETWEEN dal AND NVL(al,TRUNC(SYSDATE))
     AND substr(NVL(competenza,'xxx'), 1, 2) <> substr(NVL(p_competenza,'xxx'), 1, 2)
     AND competenza_esclusiva = 'P'
   ;
   IF d_al IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(-20999,'Modifica registrazioni storiche precedenti al '||TO_CHAR(d_al,'dd/mm/yyyy')||' non consentita. Soggetto storico di competenza parziale di altro progetto.');
   END IF;
   FOR sogg_storico IN ( SELECT ni, dal, competenza, competenza_esclusiva
                           FROM ANAGRAFE_SOGGETTI
                          WHERE ni = p_ni
                            AND (dal > p_dal
                             OR ( dal = p_dal AND al IS NOT NULL))
                       )
   LOOP
      d_result := anagrafe_soggetti_pkg.is_competenza_ok
        ( p_competenza=>p_competenza
        , p_competenza_esclusiva =>p_competenza_esclusiva
        , p_competenza_old => sogg_storico.competenza
        , p_competenza_esclusiva_old => sogg_storico.competenza_esclusiva
        ) ;
      IF not ( d_result = AFC_Error.ok )
       then
          anagrafe_soggetti_pkg.raise_error_message(d_result);
      ELSE
         -- Elimina Registrazioni da anagrafe_soggetti con DAL >= nuovo DAL
         BEGIN
            DELETE ANAGRAFE_SOGGETTI
             WHERE ni = sogg_storico.ni
               AND dal = sogg_storico.dal
            ;
         EXCEPTION WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20999,'Modifica registrazioni storiche.'||SUBSTR(SQLERRM,5));
         END;
      END IF;
   END LOOP;
   -- Cerca eventuali Registrazioni storiche.
   BEGIN
      SELECT dal, cognome, nome, competenza, competenza_esclusiva
        INTO dDalStorico, dCognomeStorico, dNomeStorico, dCompetenza, dCompetenzaEsclusiva
        FROM ANAGRAFE_SOGGETTI
       WHERE ni  = p_ni
         AND dal = (SELECT MAX(dal)
                      FROM ANAGRAFE_SOGGETTI
                     WHERE ni  = p_ni
                       AND dal < p_dal)
      ;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         dDalStorico := TO_DATE('27/02/0001','dd/mm/yyyy');
      WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20999,'Recupero data di inizio validita'' della registrazione storica.'||CHR(10)||SUBSTR(SQLERRM,5));
   END;
   -- Se esistono Registrazioni storiche.
   IF dDalStorico <>  TO_DATE('27/02/0001','dd/mm/yyyy') THEN
      -- Rev.3 del 01/09/2009 MM: gestione competenza esclusiva del record da storicizzare.
      -- Rev.4 del 13/12/2011 SNeg: controllo anche se non competenza esclusiva = E
      d_result := anagrafe_soggetti_pkg.is_competenza_ok
        ( p_competenza=>p_competenza
        , p_competenza_esclusiva =>p_competenza_esclusiva
        , p_competenza_old => dCompetenza
        , p_competenza_esclusiva_old => dCompetenzaEsclusiva
        ) ;
      IF not ( d_result = AFC_Error.ok )
       then
          anagrafe_soggetti_pkg.raise_error_message(d_result);
      end if;
     -- Rev.4 del 13/12/2011 SNeg: fine mod.
      -- Rev.3 del 01/09/2009 MM : fine mod.
      -- Rev.2 del 22/06/2006 MM: Gestione motivo_blocco di XX4_ANAGRAFE_SOGGETTI.
      -- Verifica la presenza del soggetto nella vista di integrita' referenziale
      -- ed il motivo del blocco del record:
      -- se il soggetto e' presente nella vista e motivo_blocco = D (nessun
      -- campo del record e' modificabile ad eccezione di AL = e' storicizzabile)
      -- e nel nuovo record creato i campi COGNOME e NOME devono essere uguali a
      -- quelli del record storico),
      --    se e' stato modificato il campo COGNOME od il campo NOME, non permette
      --    la modifica.
       -- Rev.4    19/10/2009 MM: Errore se esistono piu' record in xx4_anagrafe_soggetti
       -- per stessi ni e dal.
         BEGIN
            FOR c_ref IN (SELECT oggetto, motivo_blocco
                            FROM xx4_anagrafe_soggetti
                           WHERE ni = p_ni AND dal = ddalstorico)
            LOOP
               IF     c_ref.motivo_blocco = 'D'
                  AND (   NVL (p_cognome, ' ') <> NVL (dcognomestorico, ' ')
                       OR NVL (p_nome, ' ') <> NVL (dnomestorico, ' ')
                      )
               THEN
                  raise_application_error
                       (-20999,
                           'Esistono riferimenti su Anagrafe Soggetti ('
                        || c_ref.oggetto
                        || '). La registrazione non e'' modificabile (motivo blocco: '
                        || c_ref.motivo_blocco
                        || ').'
                       );
               END IF;
            END LOOP;
         END;
      -- Rev.2 del 22/06/2006 MM: fine mod.
      -- Aggiornamento storico_soggetti
      BEGIN
         UPDATE ANAGRAFE_SOGGETTI
            SET al  = p_dal - 1
          WHERE ni  = p_ni
            AND dal = dDalStorico
         ;
      EXCEPTION WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20999,'Aggiornamento data di fine validita'' della registrazione storica.'||CHR(10)||SUBSTR(SQLERRM,5));
      END;
   END IF;
END;
/

