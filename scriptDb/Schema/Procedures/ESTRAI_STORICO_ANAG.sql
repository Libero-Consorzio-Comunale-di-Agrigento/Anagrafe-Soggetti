CREATE OR REPLACE PROCEDURE ESTRAI_STORICO_ANAG
( P_NI IN NUMBER) IS
    d_tree_storico  clob := empty_clob();
    D_NEW_AL                ANAGRAFICI_STORICO.AL%TYPE;
    D_NEW_COGNOME           ANAGRAFICI_STORICO.COGNOME%TYPE;
    D_NEW_NOME              ANAGRAFICI_STORICO.NOME%TYPE;
    D_NEW_SESSO             ANAGRAFICI_STORICO.SESSO%TYPE;
    D_NEW_DATA_NAS          ANAGRAFICI_STORICO.DATA_NAS%TYPE;
    D_NEW_PROVINCIA_NAS     ANAGRAFICI_STORICO.PROVINCIA_NAS%TYPE;
    D_NEW_COMUNE_NAS        ANAGRAFICI_STORICO.COMUNE_NAS%TYPE;
    D_NEW_CODICE_FISCALE    ANAGRAFICI_STORICO.CODICE_FISCALE%TYPE;
    D_NEW_LUOGO_NAS         ANAGRAFICI_STORICO.LUOGO_NAS%TYPE;    
    D_NEW_CODICE_FISCALE_ESTERO ANAGRAFICI_STORICO.CODICE_FISCALE_ESTERO%TYPE;
    D_NEW_PARTITA_IVA   ANAGRAFICI_STORICO.PARTITA_IVA%TYPE;
    D_NEW_CITTADINANZA   ANAGRAFICI_STORICO.CITTADINANZA%TYPE;
    D_NEW_GRUPPO_LING   ANAGRAFICI_STORICO.GRUPPO_LING%TYPE;
    D_NEW_COMPETENZA   ANAGRAFICI_STORICO.COMPETENZA%TYPE;
    D_NEW_COMPETENZA_ESCLUSIVA   ANAGRAFICI_STORICO.COMPETENZA_ESCLUSIVA%TYPE;
    D_NEW_TIPO_SOGGETTO   ANAGRAFICI_STORICO.TIPO_SOGGETTO%TYPE;
    D_NEW_STATO_CEE   ANAGRAFICI_STORICO.STATO_CEE%TYPE;
    D_NEW_PARTITA_IVA_CEE   ANAGRAFICI_STORICO.PARTITA_IVA_CEE%TYPE;
    D_NEW_FINE_VALIDITA   ANAGRAFICI_STORICO.FINE_VALIDITA%TYPE;
    D_NEW_STATO_SOGGETTO   ANAGRAFICI_STORICO.STATO_SOGGETTO%TYPE;
    D_NEW_NOTE        ANAGRAFICI_STORICO.NOTE%TYPE;                  
begin
    for sel_storico_anag in (  select *
                                 from anagrafici_storico
                                where ni = P_NI
                                  and operazione in ('I','BI','D')
                              order by id_evento
                            ) loop
                           
        if sel_storico_anag.operazione = 'I' then --nuovi inserimenti
            dbms_output.put_line('Anagrafica con decorrenza '||TO_CHAR(sel_storico_anag.dal,'DD/MM/YYYY')||' inserito da '||nvl(ad4_utente.get_nominativo(sel_storico_anag.utente),sel_storico_anag.utente)||' il '||TO_CHAR(sel_storico_anag.data,'DD/MM/YYYY hh24:MI:SS'));
            if sel_storico_anag.al is not null then
                   dbms_output.put_Line('+ AL: '||to_char(sel_storico_anag.al,'dd/mm/yyyy'));
            end if;   
            if sel_storico_anag.cognome is not null then
                   dbms_output.put_Line('+ COGNOME: '||sel_storico_anag.cognome);
            end if;  
            if sel_storico_anag.NOME is not null then
                   dbms_output.put_Line('+ NOME: '||sel_storico_anag.nome);
            end if;     
            if sel_storico_anag.SESSO is not null then
                   dbms_output.put_Line('+ SESSO: '||sel_storico_anag.SESSO);
            end if;   
            if sel_storico_anag.DATA_NAS is not null then
                   dbms_output.put_Line('+ DATA_NASCITA: '||TO_CHAR(sel_storico_anag.DATA_NAS,'DD/MM/YYYY'));
            end if;  
            if sel_storico_anag.PROVINCIA_NAS is not null then
                   dbms_output.put_Line('+ PROVINCIA_NAS: '||sel_storico_anag.PROVINCIA_NAS);
            end if;     
            if sel_storico_anag.COMUNE_NAS is not null then
                   dbms_output.put_Line('+ COMUNE_NAS: '||sel_storico_anag.COMUNE_NAS);
            end if;      
            if sel_storico_anag.LUOGO_NAS is not null then
                   dbms_output.put_Line('+ LUOGO_NAS: '||sel_storico_anag.LUOGO_NAS);
            end if;
            if sel_storico_anag.CODICE_FISCALE is not null then
                   dbms_output.put_Line('+ CODICE_FISCALE: '||sel_storico_anag.CODICE_FISCALE);
            end if;
            if sel_storico_anag.CODICE_FISCALE_ESTERO is not null then
                   dbms_output.put_Line('+ CODICE_FISCALE_ESTERO: '||sel_storico_anag.CODICE_FISCALE_ESTERO);
            end if;
            if sel_storico_anag.PARTITA_IVA is not null then
                   dbms_output.put_Line('+ PARTITA_IVA: '||sel_storico_anag.PARTITA_IVA);
            end if;
            if sel_storico_anag.CITTADINANZA is not null then
                   dbms_output.put_Line('+ CITTADINANZA: '||sel_storico_anag.CITTADINANZA);
            end if;      
            if sel_storico_anag.GRUPPO_LING is not null then
                   dbms_output.put_Line('+ GRUPPO_LING: '||sel_storico_anag.GRUPPO_LING);
            end if;  
            if sel_storico_anag.COMPETENZA is not null then
                   dbms_output.put_Line('+ COMPETENZA: '||sel_storico_anag.COMPETENZA);
            end if;  
            if sel_storico_anag.COMPETENZA_ESCLUSIVA is not null then
                   dbms_output.put_Line('+ COMPETENZA_ESCLUSIVA: '||sel_storico_anag.COMPETENZA_ESCLUSIVA);
            end if;  
            if sel_storico_anag.TIPO_SOGGETTO is not null then
                   dbms_output.put_Line('+ TIPO_SOGGETTO: '||sel_storico_anag.TIPO_SOGGETTO);
            end if;  
            if sel_storico_anag.STATO_CEE is not null then
                   dbms_output.put_Line('+ STATO_CEE: '||sel_storico_anag.STATO_CEE);
            end if;    
            if sel_storico_anag.partita_iva_CEE is not null then
                   dbms_output.put_Line('+ PARTITA_IVA_CEE: '||sel_storico_anag.partita_iva_CEE);
            end if;   
            if sel_storico_anag.FINE_VALIDITA is not null then
                   dbms_output.put_Line('+ FINE_VALIDITA: '||sel_storico_anag.FINE_VALIDITA);
            end if;       
            if sel_storico_anag.STATO_SOGGETTO is not null then
                   dbms_output.put_Line('+ STATO_SOGGETTO: '||sel_storico_anag.STATO_SOGGETTO);
            end if; 
            if sel_storico_anag.NOTE is not null then
                   dbms_output.put_Line('+ NOTE: '||sel_storico_anag.NOTE);
            end if;                                                                                                                                                                                                                       
        elsif sel_storico_anag.operazione = 'BI' then --modifica del record
            SELECT al, COGNOME, NOME, SESSO, DATA_NAS,PROVINCIA_NAS ,
                    COMUNE_NAS ,
                    ltrim(rtrim(CODICE_FISCALE))  ,
                    LUOGO_NAS  ,    
                    CODICE_FISCALE_ESTERO ,
                    PARTITA_IVA  ,
                    CITTADINANZA ,
                    GRUPPO_LING  ,
                    COMPETENZA  ,
                    COMPETENZA_ESCLUSIVA ,
                    TIPO_SOGGETTO  ,
                    STATO_CEE  ,
                    PARTITA_IVA_CEE  ,
                    FINE_VALIDITA  ,
                    STATO_SOGGETTO  ,
                    NOTE 
              INTO  D_NEW_AL, D_NEW_COGNOME, D_NEW_NOME, D_NEW_SESSO, D_NEW_DATA_NAS,D_NEW_PROVINCIA_NAS ,
                    D_NEW_COMUNE_NAS ,
                    D_NEW_CODICE_FISCALE  ,
                    D_NEW_LUOGO_NAS  ,    
                    D_NEW_CODICE_FISCALE_ESTERO ,
                    D_NEW_PARTITA_IVA  ,
                    D_NEW_CITTADINANZA ,
                    D_NEW_GRUPPO_LING  ,
                    D_NEW_COMPETENZA  ,
                    D_NEW_COMPETENZA_ESCLUSIVA ,
                    D_NEW_TIPO_SOGGETTO  ,
                    D_NEW_STATO_CEE  ,
                    D_NEW_PARTITA_IVA_CEE  ,
                    D_NEW_FINE_VALIDITA  ,
                    D_NEW_STATO_SOGGETTO  ,
                    D_NEW_NOTE 
              FROM ANAGRAFICI_STORICO
             WHERE BI_RIFERIMENTO = SEL_STORICO_ANAG.ID_EVENTO
               AND OPERAZIONE = 'AI';
            dbms_output.put_line('Anagrafica con decorrenza '||TO_CHAR(sel_storico_anag.dal,'DD/MM/YYYY')||' aggiornato da '||sel_storico_anag.utente||' il '||TO_CHAR(sel_storico_anag.data,'DD/MM/YYYY hh24:MI:SS') );
            if NVL(sel_storico_anag.al,TO_DATE(3333333,'J')) != NVL(D_NEW_AL,TO_DATE(3333333,'J')) THEN -- MODIFICATO AL
                IF SEL_STORICO_ANAG.AL IS NULL AND D_NEW_AL IS NOT NULL THEN
                    dbms_output.put_Line('+ AL: '||D_NEW_AL);
                ELSIF SEL_STORICO_ANAG.AL IS NOT NULL AND D_NEW_AL IS NULL THEN
                    dbms_output.put_Line('- AL: '||SEL_STORICO_ANAG.AL);
                ELSE
                    dbms_output.put_LinE('AL: '||SEL_STORICO_ANAG.AL||' -> '||D_NEW_AL);    
                END IF;
            END IF;
            if NVL(sel_storico_anag.COGNOME,'x') != NVL(D_NEW_COGNOME,'x') THEN -- MODIFICATO AL
                IF sel_storico_anag.COGNOME IS NULL AND D_NEW_COGNOME IS NOT NULL THEN
                    dbms_output.put_Line('+ COGNOME: '||D_NEW_COGNOME);
                ELSIF SEL_STORICO_ANAG.COGNOME IS NOT NULL AND D_NEW_COGNOME IS NULL THEN
                    dbms_output.put_Line('- COGNOME: '||SEL_STORICO_ANAG.COGNOME);
                ELSE
                    dbms_output.put_LinE('COGNOME: '||SEL_STORICO_ANAG.COGNOME||' -> '||D_NEW_COGNOME);    
                END IF;
            END IF;     
            if NVL(sel_storico_anag.NOME,'x') != NVL(D_NEW_NOME,'x') THEN -- MODIFICATO AL
                IF sel_storico_anag.NOME IS NULL AND D_NEW_NOME IS NOT NULL THEN
                    dbms_output.put_Line('+ NOME: '||D_NEW_NOME);
                ELSIF SEL_STORICO_ANAG.NOME IS NOT NULL AND D_NEW_NOME IS NULL THEN
                    dbms_output.put_Line('- NOME: '||SEL_STORICO_ANAG.NOME);
                ELSE
                    dbms_output.put_LinE('NOME: '||SEL_STORICO_ANAG.NOME||' -> '||D_NEW_NOME);    
                END IF;
            END IF; 
            if NVL(sel_storico_anag.sesso,'xx') != NVL(D_NEW_sesso,'xx') THEN -- MODIFICATO AL
                IF sel_storico_anag.sesso IS NULL AND D_NEW_sesso IS NOT NULL THEN
                    dbms_output.put_Line('+ SESSO: '||D_NEW_SESSO);
                ELSIF SEL_STORICO_ANAG.SESSO IS NOT NULL AND D_NEW_SESSO IS NULL THEN
                    dbms_output.put_Line('- SESSO: '||SEL_STORICO_ANAG.SESSO);
                ELSE
                    dbms_output.put_LinE('SESSO: '||SEL_STORICO_ANAG.SESSO||' -> '||D_NEW_SESSO);    
                END IF;
            END IF;            
            if NVL(sel_storico_anag.data_nas,TO_DATE(3333333,'J')) != NVL(D_NEW_data_nas,TO_DATE(3333333,'J')) THEN -- MODIFICATO data_nas
                IF SEL_STORICO_ANAG.data_nas IS NULL AND D_NEW_data_nas IS NOT NULL THEN
                    dbms_output.put_Line('+ data_nas: '||D_NEW_data_nas);
                ELSIF SEL_STORICO_ANAG.data_nas IS NOT NULL AND D_NEW_data_nas IS NULL THEN
                    dbms_output.put_Line('- data_nas: '||SEL_STORICO_ANAG.data_nas);
                ELSE
                    dbms_output.put_LinE('data_nas: '||SEL_STORICO_ANAG.data_nas||' -> '||D_NEW_data_nas);    
                END IF;
            END IF;      
            if NVL(sel_storico_anag.provincia_nas,-1) != NVL(D_NEW_provincia_nas,-1) THEN -- MODIFICATO data_nas
                IF SEL_STORICO_ANAG.provincia_nas IS NULL AND D_NEW_provincia_nas IS NOT NULL THEN
                    dbms_output.put_Line('+ provincia_nas: '||D_NEW_provincia_nas);
                ELSIF SEL_STORICO_ANAG.provincia_nas IS NOT NULL AND D_NEW_provincia_nas IS NULL THEN
                    dbms_output.put_Line('- provincia_nas: '||SEL_STORICO_ANAG.provincia_nas);
                ELSE
                    dbms_output.put_LinE('provincia_nas: '||SEL_STORICO_ANAG.provincia_nas||' -> '||D_NEW_provincia_nas);    
                END IF;
            END IF; 
            if NVL(sel_storico_anag.comune_nas,-1) != NVL(D_NEW_comune_nas,-1) THEN -- MODIFICATO data_nas
                IF SEL_STORICO_ANAG.comune_nas IS NULL AND D_NEW_comune_nas IS NOT NULL THEN
                    dbms_output.put_Line('+ comune_nas: '||D_NEW_comune_nas);
                ELSIF SEL_STORICO_ANAG.comune_nas IS NOT NULL AND D_NEW_comune_nas IS NULL THEN
                    dbms_output.put_Line('- comune_nas: '||SEL_STORICO_ANAG.comune_nas);
                ELSE
                    dbms_output.put_LinE('comune_nas: '||SEL_STORICO_ANAG.comune_nas||' -> '||D_NEW_comune_nas);    
                END IF;
            END IF;         
            if NVL(sel_storico_anag.LUOGO_nas,'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX') != NVL(D_NEW_LUOGO_nas,'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX') THEN -- MODIFICATO LUOGO_nas
                IF SEL_STORICO_ANAG.LUOGO_nas IS NULL AND D_NEW_LUOGO_nas IS NOT NULL THEN
                    dbms_output.put_Line('+ LUOGO_nas: '||D_NEW_LUOGO_nas);
                ELSIF SEL_STORICO_ANAG.LUOGO_nas IS NOT NULL AND D_NEW_LUOGO_nas IS NULL THEN
                    dbms_output.put_Line('- LUOGO_nas: '||SEL_STORICO_ANAG.LUOGO_nas);
                ELSE
                    dbms_output.put_LinE('LUOGO_nas: '||SEL_STORICO_ANAG.LUOGO_nas||' -> '||D_NEW_LUOGO_nas);    
                END IF;
            END IF; 
            if NVL(sel_storico_anag.CODICE_FISCALE,'xxxxxxxxxxxxxxxxx') != NVL(D_NEW_CODICE_FISCALE,'xxxxxxxxxxxxxxxxx') THEN -- MODIFICATO CF
                IF sel_storico_anag.CODICE_FISCALE IS NULL AND D_NEW_CODICE_FISCALE IS NOT NULL THEN
                    dbms_output.put_Line('+ CODICE_FISCALE: '||D_NEW_CODICE_FISCALE);
                ELSIF SEL_STORICO_ANAG.CODICE_FISCALE IS NOT NULL AND D_NEW_CODICE_FISCALE IS NULL THEN
                    dbms_output.put_Line('- CODICE_FISCALE: '||SEL_STORICO_ANAG.CODICE_FISCALE);
                ELSE
                    dbms_output.put_LinE('CODICE_FISCALE: '||SEL_STORICO_ANAG.CODICE_FISCALE||' -> '||D_NEW_CODICE_FISCALE);    
                END IF;
            END IF; 
            if NVL(sel_storico_anag.CODICE_FISCALE_ESTERO,'xxxxxxxxxxxxxxxxx') != NVL(D_NEW_CODICE_FISCALE_ESTERO,'xxxxxxxxxxxxxxxxx') THEN -- MODIFICATO CF
                IF sel_storico_anag.CODICE_FISCALE_ESTERO IS NULL AND D_NEW_CODICE_FISCALE_ESTERO IS NOT NULL THEN
                    dbms_output.put_Line('+ CODICE_FISCALE_ESTERO: '||D_NEW_CODICE_FISCALE_ESTERO);
                ELSIF SEL_STORICO_ANAG.CODICE_FISCALE_ESTERO IS NOT NULL AND D_NEW_CODICE_FISCALE_ESTERO IS NULL THEN
                    dbms_output.put_Line('- CODICE_FISCALE_ESTERO: '||SEL_STORICO_ANAG.CODICE_FISCALE_ESTERO);
                ELSE
                    dbms_output.put_LinE('CODICE_FISCALE_ESTERO: '||SEL_STORICO_ANAG.CODICE_FISCALE_ESTERO||' -> '||D_NEW_CODICE_FISCALE_ESTERO);    
                END IF;
            END IF;   
            if NVL(sel_storico_anag.PARTITA_IVA,'xxxxxxxxxxxxxxxxx') != NVL(D_NEW_PARTITA_IVA,'xxxxxxxxxxxxxxxxx') THEN -- MODIFICATO CF
                IF sel_storico_anag.PARTITA_IVA IS NULL AND D_NEW_PARTITA_IVA IS NOT NULL THEN
                    dbms_output.put_Line('+ PARTITA_IVA: '||D_NEW_PARTITA_IVA);
                ELSIF SEL_STORICO_ANAG.PARTITA_IVA IS NOT NULL AND D_NEW_PARTITA_IVA IS NULL THEN
                    dbms_output.put_Line('- PARTITA_IVA: '||SEL_STORICO_ANAG.PARTITA_IVA);
                ELSE
                    dbms_output.put_LinE('PARTITA_IVA: '||SEL_STORICO_ANAG.PARTITA_IVA||' -> '||D_NEW_PARTITA_IVA);    
                END IF;
            END IF; 
            if NVL(sel_storico_anag.CITTADINANZA,'xxxx') != NVL(D_NEW_CITTADINANZA,'xxxx') THEN -- MODIFICATO CF
                IF sel_storico_anag.CITTADINANZA IS NULL AND D_NEW_CITTADINANZA IS NOT NULL THEN
                    dbms_output.put_Line('+ CITTADINANZA: '||D_NEW_CITTADINANZA);
                ELSIF SEL_STORICO_ANAG.CITTADINANZA IS NOT NULL AND D_NEW_CITTADINANZA IS NULL THEN
                    dbms_output.put_Line('- CITTADINANZA: '||SEL_STORICO_ANAG.CITTADINANZA);
                ELSE
                    dbms_output.put_LinE('CITTADINANZA: '||SEL_STORICO_ANAG.CITTADINANZA||' -> '||D_NEW_CITTADINANZA);    
                END IF;
            END IF;     
            if NVL(sel_storico_anag.gruppo_ling,'xxxx') != NVL(D_NEW_GRUPPO_LING,'xxxx') THEN -- MODIFICATO CF
                IF sel_storico_anag.GRUPPO_LING IS NULL AND D_NEW_GRUPPO_LING IS NOT NULL THEN
                    dbms_output.put_Line('+ GRUPPO_LING: '||D_NEW_GRUPPO_LING);
                ELSIF SEL_STORICO_ANAG.GRUPPO_LING IS NOT NULL AND D_NEW_GRUPPO_LING IS NULL THEN
                    dbms_output.put_Line('- GRUPPO_LING: '||SEL_STORICO_ANAG.GRUPPO_LING);
                ELSE
                    dbms_output.put_LinE('GRUPPO_LING: '||SEL_STORICO_ANAG.GRUPPO_LING||' -> '||D_NEW_GRUPPO_LING);    
                END IF;
            END IF;       
            if NVL(sel_storico_anag.COMPETENZA,'xxxxxxxxxxx') != NVL(D_NEW_COMPETENZA,'xxxxxxxxxxx') THEN -- MODIFICATO CF
                IF sel_storico_anag.COMPETENZA IS NULL AND D_NEW_COMPETENZA IS NOT NULL THEN
                    dbms_output.put_Line('+ COMPETENZA: '||D_NEW_COMPETENZA);
                ELSIF SEL_STORICO_ANAG.COMPETENZA IS NOT NULL AND D_NEW_COMPETENZA IS NULL THEN
                    dbms_output.put_Line('- COMPETENZA: '||SEL_STORICO_ANAG.COMPETENZA);
                ELSE
                    dbms_output.put_LinE('COMPETENZA: '||SEL_STORICO_ANAG.COMPETENZA||' -> '||D_NEW_COMPETENZA);    
                END IF;
            END IF;     
            if NVL(sel_storico_anag.COMPETENZA_ESCLUSIVA,'xx') != NVL(D_NEW_COMPETENZA_ESCLUSIVA,'xx') THEN -- MODIFICATO CF
                IF sel_storico_anag.COMPETENZA_ESCLUSIVA IS NULL AND D_NEW_COMPETENZA_ESCLUSIVA IS NOT NULL THEN
                    dbms_output.put_Line('+ COMPETENZA_ESCLUSIVA: '||D_NEW_COMPETENZA_ESCLUSIVA);
                ELSIF SEL_STORICO_ANAG.COMPETENZA_ESCLUSIVA IS NOT NULL AND D_NEW_COMPETENZA_ESCLUSIVA IS NULL THEN
                    dbms_output.put_Line('- COMPETENZA_ESCLUSIVA: '||SEL_STORICO_ANAG.COMPETENZA_ESCLUSIVA);
                ELSE
                    dbms_output.put_LinE('COMPETENZA_ESCLUSIVA: '||SEL_STORICO_ANAG.COMPETENZA_ESCLUSIVA||' -> '||D_NEW_COMPETENZA_ESCLUSIVA);    
                END IF;
            END IF;    
            if NVL(sel_storico_anag.TIPO_SOGGETTO,'xx') != NVL(D_NEW_TIPO_SOGGETTO,'xx') THEN -- MODIFICATO CF
                IF sel_storico_anag.TIPO_SOGGETTO IS NULL AND D_NEW_TIPO_SOGGETTO IS NOT NULL THEN
                    dbms_output.put_Line('+ TIPO_SOGGETTO: '||D_NEW_TIPO_SOGGETTO);
                ELSIF SEL_STORICO_ANAG.TIPO_SOGGETTO IS NOT NULL AND D_NEW_TIPO_SOGGETTO IS NULL THEN
                    dbms_output.put_Line('- TIPO_SOGGETTO: '||SEL_STORICO_ANAG.TIPO_SOGGETTO);
                ELSE
                    dbms_output.put_LinE('TIPO_SOGGETTO: '||SEL_STORICO_ANAG.TIPO_SOGGETTO||' -> '||D_NEW_TIPO_SOGGETTO);    
                END IF;
            END IF;           
            if NVL(sel_storico_anag.STATO_CEE,'xxxx') != NVL(D_NEW_STATO_CEE,'xxxx') THEN -- MODIFICATO CF
                IF sel_storico_anag.STATO_CEE IS NULL AND D_NEW_STATO_CEE IS NOT NULL THEN
                    dbms_output.put_Line('+ STATO_CEE: '||D_NEW_STATO_CEE);
                ELSIF SEL_STORICO_ANAG.STATO_CEE IS NOT NULL AND D_NEW_STATO_CEE IS NULL THEN
                    dbms_output.put_Line('- STATO_CEE: '||SEL_STORICO_ANAG.STATO_CEE);
                ELSE
                    dbms_output.put_LinE('STATO_CEE: '||SEL_STORICO_ANAG.STATO_CEE||' -> '||D_NEW_STATO_CEE);    
                END IF;
            END IF;      
            if NVL(sel_storico_anag.PARTITA_IVA_CEE,'xxxx') != NVL(D_NEW_PARTITA_IVA_CEE,'xxxx') THEN -- MODIFICATO CF
                IF sel_storico_anag.PARTITA_IVA_CEE IS NULL AND D_NEW_PARTITA_IVA_CEE IS NOT NULL THEN
                    dbms_output.put_Line('+ PARTITA_IVA_CEE: '||D_NEW_PARTITA_IVA_CEE);
                ELSIF SEL_STORICO_ANAG.PARTITA_IVA_CEE IS NOT NULL AND D_NEW_PARTITA_IVA_CEE IS NULL THEN
                    dbms_output.put_Line('- PARTITA_IVA_CEE: '||SEL_STORICO_ANAG.PARTITA_IVA_CEE);
                ELSE
                    dbms_output.put_LinE('PARTITA_IVA_CEE: '||SEL_STORICO_ANAG.PARTITA_IVA_CEE||' -> '||D_NEW_PARTITA_IVA_CEE);    
                END IF;
            END IF;   
            if NVL(sel_storico_anag.FINE_VALIDITA,TO_DATE(3333333,'J')) != NVL(D_NEW_FINE_VALIDITA,TO_DATE(3333333,'J')) THEN -- MODIFICATO FINE_VALIDITA
                IF SEL_STORICO_ANAG.FINE_VALIDITA IS NULL AND D_NEW_FINE_VALIDITA IS NOT NULL THEN
                    dbms_output.put_Line('+ FINE_VALIDITA: '||D_NEW_FINE_VALIDITA);
                ELSIF SEL_STORICO_ANAG.FINE_VALIDITA IS NOT NULL AND D_NEW_FINE_VALIDITA IS NULL THEN
                    dbms_output.put_Line('- FINE_VALIDITA: '||SEL_STORICO_ANAG.FINE_VALIDITA);
                ELSE
                    dbms_output.put_LinE('FINE_VALIDITA: '||SEL_STORICO_ANAG.FINE_VALIDITA||' -> '||D_NEW_FINE_VALIDITA);    
                END IF;
            END IF;  
            if NVL(sel_storico_anag.STATO_SOGGETTO,'xxxx') != NVL(D_NEW_STATO_SOGGETTO,'xxxx') THEN -- MODIFICATO CF
                IF sel_storico_anag.STATO_SOGGETTO IS NULL AND D_NEW_STATO_SOGGETTO IS NOT NULL THEN
                    dbms_output.put_Line('+ STATO_SOGGETTO: '||D_NEW_STATO_SOGGETTO);
                ELSIF SEL_STORICO_ANAG.STATO_SOGGETTO IS NOT NULL AND D_NEW_STATO_SOGGETTO IS NULL THEN
                    dbms_output.put_Line('- STATO_SOGGETTO: '||SEL_STORICO_ANAG.STATO_SOGGETTO);
                ELSE
                    dbms_output.put_LinE('STATO_SOGGETTO: '||SEL_STORICO_ANAG.STATO_SOGGETTO||' -> '||D_NEW_STATO_SOGGETTO);    
                END IF;
            END IF;    
            if NVL(sel_storico_anag.NOTE,'XxXx') != NVL(D_NEW_NOTE,'XxXx') THEN -- MODIFICATO CF
                IF sel_storico_anag.NOTE IS NULL AND D_NEW_NOTE IS NOT NULL THEN
                    dbms_output.put_Line('+ NOTE: '||D_NEW_NOTE);
                ELSIF SEL_STORICO_ANAG.NOTE IS NOT NULL AND D_NEW_NOTE IS NULL THEN
                    dbms_output.put_Line('- NOTE: '||SEL_STORICO_ANAG.NOTE);
                ELSE
                    dbms_output.put_LinE('NOTE: '||SEL_STORICO_ANAG.NOTE||' -> '||D_NEW_NOTE);    
                END IF;
            END IF;                                                                                                                                                                                                   
        elsif sel_storico_anag.operazione = 'D' then --modifica del record
            dbms_output.put_line('Anagrafica con decorrenza '||TO_CHAR(sel_storico_anag.dal,'DD/MM/YYYY')||' eliminato da '||sel_storico_anag.utente||' il '||TO_CHAR(sel_storico_anag.data,'DD/MM/YYYY hh24:MI:SS'));
        end if;
    end loop;
end;
/

