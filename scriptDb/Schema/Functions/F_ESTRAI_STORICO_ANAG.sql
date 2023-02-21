CREATE OR REPLACE FUNCTION F_ESTRAI_STORICO_ANAG
( P_NI IN NUMBER)
RETURN CLOB
 IS
    d_tree_storico  clob := empty_clob();
    d_amount     BINARY_INTEGER := 32767;
    d_char       VARCHAR2(32767);
    d_xml        VARCHAR2(32767);    
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
    dbms_lob.createTemporary(d_tree_storico,TRUE,dbms_lob.CALL);
    d_xml:='<ROWSET>'||CHR(10)||CHR(13);
    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
    for sel_storico_anag in (  select *
                                 from anagrafici_storico
                                where ni = P_NI
                                  and operazione in ('I','BI','D')
                              order by id_evento
                            ) loop
                           
        if sel_storico_anag.operazione = 'I' then --nuovi inserimenti
            D_XML:= '<ROWSET><ROW><OPERAZIONE>Anagrafica con decorrenza '||TO_CHAR(sel_storico_anag.dal,'DD/MM/YYYY')||' inserito da '||nvl(ad4_utente.get_nominativo(sel_storico_anag.utente),sel_storico_anag.utente)||' il '||TO_CHAR(sel_storico_anag.data,'DD/MM/YYYY hh24:MI:SS')||'</OPERAZIONE>'||CHR(10)||CHR(13);
            dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);
            dbms_output.put_line('Anagrafica con decorrenza '||TO_CHAR(sel_storico_anag.dal,'DD/MM/YYYY')||' inserito da '||nvl(ad4_utente.get_nominativo(sel_storico_anag.utente),sel_storico_anag.utente)||' il '||TO_CHAR(sel_storico_anag.data,'DD/MM/YYYY hh24:MI:SS'));
            if sel_storico_anag.al is not null then
                   D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>AL</ATTRIBUTO><VALORE>'||to_char(sel_storico_anag.al,'dd/mm/yyyy')||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml); 
                   dbms_output.put_Line('+ AL: '||to_char(sel_storico_anag.al,'dd/mm/yyyy'));
            end if;   
            if sel_storico_anag.cognome is not null then
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>COGNOME</ATTRIBUTO><VALORE>'||sel_storico_anag.cognome||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);            
                   dbms_output.put_Line('+ COGNOME: '||sel_storico_anag.cognome);
            end if;  
            if sel_storico_anag.NOME is not null then
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>NOME</ATTRIBUTO><VALORE>'||sel_storico_anag.nome||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);              
                   dbms_output.put_Line('+ NOME: '||sel_storico_anag.nome);
            end if;     
            if sel_storico_anag.SESSO is not null then
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>SESSO</ATTRIBUTO><VALORE>'||sel_storico_anag.SESSO||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);               
                   dbms_output.put_Line('+ SESSO: '||sel_storico_anag.SESSO);
            end if;   
            if sel_storico_anag.DATA_NAS is not null then
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>DATA NASCITA</ATTRIBUTO><VALORE>'||TO_CHAR(sel_storico_anag.DATA_NAS,'DD/MM/YYYY')||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);               
                   dbms_output.put_Line('+ DATA_NASCITA: '||TO_CHAR(sel_storico_anag.DATA_NAS,'DD/MM/YYYY'));
            end if;  
            if sel_storico_anag.PROVINCIA_NAS is not null then
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>PROVINCIA NASCITA</ATTRIBUTO><VALORE>'||sel_storico_anag.PROVINCIA_NAS||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);              
                   dbms_output.put_Line('+ PROVINCIA_NAS: '||sel_storico_anag.PROVINCIA_NAS);
            end if;     
            if sel_storico_anag.COMUNE_NAS is not null then
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>COMUNE NASCITA</ATTRIBUTO><VALORE>'||sel_storico_anag.COMUNE_NAS||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);               
                   dbms_output.put_Line('+ COMUNE_NAS: '||sel_storico_anag.COMUNE_NAS);
            end if;      
            if sel_storico_anag.LUOGO_NAS is not null then
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>LUOGO NASCITA</ATTRIBUTO><VALORE>'||sel_storico_anag.LUOGO_NAS||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);            
                   dbms_output.put_Line('+ LUOGO_NAS: '||sel_storico_anag.LUOGO_NAS);
            end if;
            if sel_storico_anag.CODICE_FISCALE is not null then
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>CODICE FISCALE</ATTRIBUTO><VALORE>'||sel_storico_anag.CODICE_FISCALE||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);              
                   dbms_output.put_Line('+ CODICE_FISCALE: '||sel_storico_anag.CODICE_FISCALE);
            end if;
            if sel_storico_anag.CODICE_FISCALE_ESTERO is not null then
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>ID. FISCALE ESTERO</ATTRIBUTO><VALORE>'||sel_storico_anag.CODICE_FISCALE_ESTERO||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);               
                   dbms_output.put_Line('+ CODICE_FISCALE_ESTERO: '||sel_storico_anag.CODICE_FISCALE_ESTERO);
            end if;
            if sel_storico_anag.PARTITA_IVA is not null then
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>PARTITA IVA</ATTRIBUTO><VALORE>'||sel_storico_anag.PARTITA_IVA||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);               
                   dbms_output.put_Line('+ PARTITA_IVA: '||sel_storico_anag.PARTITA_IVA);
            end if;
            if sel_storico_anag.partita_iva_CEE is not null then
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>PARTITA IVA CEE</ATTRIBUTO><VALORE>'||sel_storico_anag.partita_iva_CEE||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                
                   dbms_output.put_Line('+ PARTITA_IVA_CEE: '||sel_storico_anag.partita_iva_CEE);
            end if;   
            if sel_storico_anag.STATO_CEE is not null then
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>STATO CEE</ATTRIBUTO><VALORE>'||sel_storico_anag.STATO_CEE||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);              
                   dbms_output.put_Line('+ STATO_CEE: '||sel_storico_anag.STATO_CEE);
            end if;                         
            if sel_storico_anag.CITTADINANZA is not null then
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>CITTADINANZA</ATTRIBUTO><VALORE>'||sel_storico_anag.CITTADINANZA||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);              
                   dbms_output.put_Line('+ CITTADINANZA: '||sel_storico_anag.CITTADINANZA);
            end if;      
            if sel_storico_anag.GRUPPO_LING is not null then
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>GRUPPO LINGUISTICO</ATTRIBUTO><VALORE>'||sel_storico_anag.GRUPPO_LING||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);               
                   dbms_output.put_Line('+ GRUPPO_LING: '||sel_storico_anag.GRUPPO_LING);
            end if;  
            if sel_storico_anag.COMPETENZA is not null then
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>COMPETENZA</ATTRIBUTO><VALORE>'||sel_storico_anag.COMPETENZA||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);             
                   dbms_output.put_Line('+ COMPETENZA: '||sel_storico_anag.COMPETENZA);
            end if;  
            if sel_storico_anag.COMPETENZA_ESCLUSIVA is not null then
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>COMPETENZA ESCLUSIVA</ATTRIBUTO><VALORE>'||sel_storico_anag.COMPETENZA_ESCLUSIVA||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                
                   dbms_output.put_Line('+ COMPETENZA_ESCLUSIVA: '||sel_storico_anag.COMPETENZA_ESCLUSIVA);
            end if;  
            if sel_storico_anag.TIPO_SOGGETTO is not null then
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>TIPO SOGGETTO</ATTRIBUTO><VALORE>'||sel_storico_anag.TIPO_SOGGETTO||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                   
                   dbms_output.put_Line('+ TIPO_SOGGETTO: '||sel_storico_anag.TIPO_SOGGETTO);
            end if;  
            if sel_storico_anag.FINE_VALIDITA is not null then
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>FINE VALIDITA''</ATTRIBUTO><VALORE>'||to_char(sel_storico_anag.FINE_VALIDITA,'dd/mm/yyyy')||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);             
                   dbms_output.put_Line('+ FINE_VALIDITA: '||sel_storico_anag.FINE_VALIDITA);
            end if;       
            if sel_storico_anag.STATO_SOGGETTO is not null then
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>STATO SOGGETTO</ATTRIBUTO><VALORE>'||sel_storico_anag.STATO_SOGGETTO||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                
                   dbms_output.put_Line('+ STATO_SOGGETTO: '||sel_storico_anag.STATO_SOGGETTO);
            end if; 
            if sel_storico_anag.NOTE is not null then
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>NOTE</ATTRIBUTO><VALORE>'||sel_storico_anag.NOTE||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                
                   dbms_output.put_Line('+ NOTE: '||sel_storico_anag.NOTE);
            end if;    
            D_XML:= '</ROW></ROWSET>'||CHR(10)||CHR(13);
            dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                                                                                                                                                                                                                               
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
            D_XML:= '<ROWSET><ROW><OPERAZIONE>Anagrafica con decorrenza '||TO_CHAR(sel_storico_anag.dal,'DD/MM/YYYY')||' aggiornata da '||nvl(ad4_utente.get_nominativo(sel_storico_anag.utente),sel_storico_anag.utente)||' il '||TO_CHAR(sel_storico_anag.data,'DD/MM/YYYY hh24:MI:SS')||'</OPERAZIONE>'||CHR(10)||CHR(13);
            dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);               
            dbms_output.put_line('Anagrafica con decorrenza '||TO_CHAR(sel_storico_anag.dal,'DD/MM/YYYY')||' aggiornato da '||sel_storico_anag.utente||' il '||TO_CHAR(sel_storico_anag.data,'DD/MM/YYYY hh24:MI:SS') );
            if NVL(sel_storico_anag.al,TO_DATE(3333333,'J')) != NVL(D_NEW_AL,TO_DATE(3333333,'J')) THEN -- MODIFICATO AL
                IF SEL_STORICO_ANAG.AL IS NULL AND D_NEW_AL IS NOT NULL THEN
                   D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>AL</ATTRIBUTO><VALORE>'||to_char(D_NEW_AL,'dd/mm/yyyy')||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                 
                    dbms_output.put_Line('+ AL: '||D_NEW_AL);
                ELSIF SEL_STORICO_ANAG.AL IS NOT NULL AND D_NEW_AL IS NULL THEN
                   D_XML:= '<ROWSET><ROW><ICONA>delete.png</ICONA><ATTRIBUTO>AL</ATTRIBUTO><VALORE>'||to_char(SEL_STORICO_ANAG.AL,'dd/mm/yyyy')||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                  
                    dbms_output.put_Line('- AL: '||SEL_STORICO_ANAG.AL);
                ELSE
                   D_XML:= '<ROWSET><ROW><ICONA>edit.png</ICONA><ATTRIBUTO>AL</ATTRIBUTO><VALORE><![CDATA['||to_char(SEL_STORICO_ANAG.AL,'dd/mm/yyyy')||' -> '||to_char(d_new_AL,'dd/mm/yyyy')||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                   
                    dbms_output.put_LinE('AL: '||SEL_STORICO_ANAG.AL||' -> '||D_NEW_AL);    
                END IF;
            END IF;
            if NVL(sel_storico_anag.COGNOME,'x') != NVL(D_NEW_COGNOME,'x') THEN -- MODIFICATO AL
                IF sel_storico_anag.COGNOME IS NULL AND D_NEW_COGNOME IS NOT NULL THEN
                   D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>COGNOME</ATTRIBUTO><VALORE>'||D_NEW_COGNOME||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                 
                    dbms_output.put_Line('+ COGNOME: '||D_NEW_COGNOME);
                ELSIF SEL_STORICO_ANAG.COGNOME IS NOT NULL AND D_NEW_COGNOME IS NULL THEN
                   D_XML:= '<ROWSET><ROW><ICONA>delete.png</ICONA><ATTRIBUTO>COGNOME</ATTRIBUTO><VALORE>'||SEL_STORICO_ANAG.COGNOME ||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                   
                    dbms_output.put_Line('- COGNOME: '||SEL_STORICO_ANAG.COGNOME);
                ELSE
                   D_XML:= '<ROWSET><ROW><ICONA>edit.png</ICONA><ATTRIBUTO>COGNOME</ATTRIBUTO><VALORE><![CDATA['||SEL_STORICO_ANAG.cognome||' -> '||d_new_cognome||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                  
                    dbms_output.put_LinE('COGNOME: '||SEL_STORICO_ANAG.COGNOME||' -> '||D_NEW_COGNOME);    
                END IF;
            END IF;     
            if NVL(sel_storico_anag.NOME,'x') != NVL(D_NEW_NOME,'x') THEN -- MODIFICATO AL
                IF sel_storico_anag.NOME IS NULL AND D_NEW_NOME IS NOT NULL THEN
                    dbms_output.put_Line('+ NOME: '||D_NEW_NOME);
                   D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>NOME</ATTRIBUTO><VALORE>'||D_NEW_NOME||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                        
                ELSIF SEL_STORICO_ANAG.NOME IS NOT NULL AND D_NEW_NOME IS NULL THEN
                   D_XML:= '<ROWSET><ROW><ICONA>delete.png</ICONA><ATTRIBUTO>NOME</ATTRIBUTO><VALORE>'||SEL_STORICO_ANAG.NOME ||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                 
                    dbms_output.put_Line('- NOME: '||SEL_STORICO_ANAG.NOME);
                ELSE
                   D_XML:= '<ROWSET><ROW><ICONA>edit.png</ICONA><ATTRIBUTO>NOME</ATTRIBUTO><VALORE><![CDATA['||SEL_STORICO_ANAG.nome||' -> '||d_new_nome||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                  
                    dbms_output.put_LinE('NOME: '||SEL_STORICO_ANAG.NOME||' -> '||D_NEW_NOME);    
                END IF;
            END IF; 
            if NVL(sel_storico_anag.sesso,'xx') != NVL(D_NEW_sesso,'xx') THEN -- MODIFICATO AL
                IF sel_storico_anag.sesso IS NULL AND D_NEW_sesso IS NOT NULL THEN
                   D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>SESSO</ATTRIBUTO><VALORE>'||D_NEW_SESSO||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                 
                    dbms_output.put_Line('+ SESSO: '||D_NEW_SESSO);
                ELSIF SEL_STORICO_ANAG.SESSO IS NOT NULL AND D_NEW_SESSO IS NULL THEN
                   D_XML:= '<ROWSET><ROW><ICONA>delete.png</ICONA><ATTRIBUTO>SESSO</ATTRIBUTO><VALORE>'||SEL_STORICO_ANAG.SESSO ||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                  
                    dbms_output.put_Line('- SESSO: '||SEL_STORICO_ANAG.SESSO);
                ELSE
                   D_XML:= '<ROWSET><ROW><ICONA>edit.png</ICONA><ATTRIBUTO>SESSO</ATTRIBUTO><VALORE><![CDATA['||SEL_STORICO_ANAG.SESSO||' -> '||d_new_SESSO||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                  
                    dbms_output.put_LinE('SESSO: '||SEL_STORICO_ANAG.SESSO||' -> '||D_NEW_SESSO);    
                END IF;
            END IF;            
            if NVL(sel_storico_anag.data_nas,TO_DATE(3333333,'J')) != NVL(D_NEW_data_nas,TO_DATE(3333333,'J')) THEN -- MODIFICATO data_nas
                IF SEL_STORICO_ANAG.data_nas IS NULL AND D_NEW_data_nas IS NOT NULL THEN
                   D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>DATA NASCITA</ATTRIBUTO><VALORE>'||to_char(D_NEW_data_nas,'dd/mm/yyyy')||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                    
                    dbms_output.put_Line('+ data_nas: '||D_NEW_data_nas);
                ELSIF SEL_STORICO_ANAG.data_nas IS NOT NULL AND D_NEW_data_nas IS NULL THEN
                   D_XML:= '<ROWSET><ROW><ICONA>delete.png</ICONA><ATTRIBUTO>DATA NASCITA</ATTRIBUTO><VALORE>'||to_char(SEL_STORICO_ANAG.DATA_NAS,'dd/mm/yyyy')||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                  
                    dbms_output.put_Line('- data_nas: '||SEL_STORICO_ANAG.data_nas);
                ELSE
                   D_XML:= '<ROWSET><ROW><ICONA>edit.png</ICONA><ATTRIBUTO>DATA NASCITA</ATTRIBUTO><VALORE><![CDATA['||to_char(SEL_STORICO_ANAG.DATA_NAS,'dd/mm/yyyy')||' -> '||to_char(d_new_DATA_NAS,'dd/mm/yyyy')||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                  
                    dbms_output.put_LinE('data_nas: '||SEL_STORICO_ANAG.data_nas||' -> '||D_NEW_data_nas);    
                END IF;
            END IF;      
            if NVL(sel_storico_anag.provincia_nas,-1) != NVL(D_NEW_provincia_nas,-1) THEN -- MODIFICATO data_nas              
                IF SEL_STORICO_ANAG.provincia_nas IS NULL AND D_NEW_provincia_nas IS NOT NULL THEN   
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>PROVINCIA NASCITA</ATTRIBUTO><VALORE>'||D_NEW_PROVINCIA_nas||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                               
                    dbms_output.put_Line('+ provincia_nas: '||D_NEW_provincia_nas);
                ELSIF SEL_STORICO_ANAG.provincia_nas IS NOT NULL AND D_NEW_provincia_nas IS NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>delete.png</ICONA><ATTRIBUTO>PROVINCIA NASCITA</ATTRIBUTO><VALORE>'||SEL_STORICO_ANAG.PROVINCIA_NAS||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                 
                    dbms_output.put_Line('- provincia_nas: '||SEL_STORICO_ANAG.provincia_nas);
                ELSE
                   D_XML:= '<ROWSET><ROW><ICONA>edit.png</ICONA><ATTRIBUTO>PROVINCIA NASCITA</ATTRIBUTO><VALORE><![CDATA['||SEL_STORICO_ANAG.PROVINCIA_NAS||' -> '||d_new_PROVINCIA_NAS||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                  
                    dbms_output.put_LinE('provincia_nas: '||SEL_STORICO_ANAG.provincia_nas||' -> '||D_NEW_provincia_nas);    
                END IF;
            END IF; 
            if NVL(sel_storico_anag.comune_nas,-1) != NVL(D_NEW_comune_nas,-1) THEN -- MODIFICATO data_nas
                IF SEL_STORICO_ANAG.comune_nas IS NULL AND D_NEW_comune_nas IS NOT NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>COMUNE NASCITA</ATTRIBUTO><VALORE>'||D_NEW_COMUNE_nas||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                   
                    dbms_output.put_Line('+ comune_nas: '||D_NEW_comune_nas);
                ELSIF SEL_STORICO_ANAG.comune_nas IS NOT NULL AND D_NEW_comune_nas IS NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>delete.png</ICONA><ATTRIBUTO>COMUNE NASCITA</ATTRIBUTO><VALORE>'||SEL_STORICO_ANAG.COMUNE_NAS||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                   
                    dbms_output.put_Line('- comune_nas: '||SEL_STORICO_ANAG.comune_nas);
                ELSE
                   D_XML:= '<ROWSET><ROW><ICONA>edit.png</ICONA><ATTRIBUTO>COMUNE NASCITA</ATTRIBUTO><VALORE><![CDATA['||SEL_STORICO_ANAG.COMUNE_NAS||' -> '||d_new_COMUNE_NAS||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                 
                    dbms_output.put_LinE('comune_nas: '||SEL_STORICO_ANAG.comune_nas||' -> '||D_NEW_comune_nas);    
                END IF;
            END IF;         
            if NVL(sel_storico_anag.LUOGO_nas,'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX') != NVL(D_NEW_LUOGO_nas,'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX') THEN -- MODIFICATO LUOGO_nas
                IF SEL_STORICO_ANAG.LUOGO_nas IS NULL AND D_NEW_LUOGO_nas IS NOT NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>LUOGO NASCITA</ATTRIBUTO><VALORE>'||D_NEW_LUOGO_nas||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                  
                    dbms_output.put_Line('+ LUOGO_nas: '||D_NEW_LUOGO_nas);
                ELSIF SEL_STORICO_ANAG.LUOGO_nas IS NOT NULL AND D_NEW_LUOGO_nas IS NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>delete.png</ICONA><ATTRIBUTO>LUOGO NASCITA</ATTRIBUTO><VALORE>'||SEL_STORICO_ANAG.LUOGO_NAS||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                
                    dbms_output.put_Line('- LUOGO_nas: '||SEL_STORICO_ANAG.LUOGO_nas);
                ELSE
                   D_XML:= '<ROWSET><ROW><ICONA>edit.png</ICONA><ATTRIBUTO>LUOGO NASCITA</ATTRIBUTO><VALORE><![CDATA['||SEL_STORICO_ANAG.LUOGO_NAS||' -> '||d_new_LUOGO_NAS||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                   
                    dbms_output.put_LinE('LUOGO_nas: '||SEL_STORICO_ANAG.LUOGO_nas||' -> '||D_NEW_LUOGO_nas);    
                END IF;
            END IF; 
            if NVL(sel_storico_anag.CODICE_FISCALE,'xxxxxxxxxxxxxxxxx') != NVL(D_NEW_CODICE_FISCALE,'xxxxxxxxxxxxxxxxx') THEN -- MODIFICATO CF
                IF sel_storico_anag.CODICE_FISCALE IS NULL AND D_NEW_CODICE_FISCALE IS NOT NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>CODICE FISCALE</ATTRIBUTO><VALORE>'||D_NEW_CODICE_FISCALE||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                 
                    dbms_output.put_Line('+ CODICE_FISCALE: '||D_NEW_CODICE_FISCALE);
                ELSIF SEL_STORICO_ANAG.CODICE_FISCALE IS NOT NULL AND D_NEW_CODICE_FISCALE IS NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>delete.png</ICONA><ATTRIBUTO>CODICE FISCALE</ATTRIBUTO><VALORE>'||SEL_STORICO_ANAG.CODICE_FISCALE||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                  
                    dbms_output.put_Line('- CODICE_FISCALE: '||SEL_STORICO_ANAG.CODICE_FISCALE);
                ELSE
                   D_XML:= '<ROWSET><ROW><ICONA>edit.png</ICONA><ATTRIBUTO>CODICE FISCALE</ATTRIBUTO><VALORE><![CDATA['||SEL_STORICO_ANAG.CODICE_FISCALE||' -> '||d_new_CODICE_FISCALE||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                    
                    dbms_output.put_LinE('CODICE_FISCALE: '||SEL_STORICO_ANAG.CODICE_FISCALE||' -> '||D_NEW_CODICE_FISCALE);    
                END IF;
            END IF; 
            if NVL(sel_storico_anag.CODICE_FISCALE_ESTERO,'xxxxxxxxxxxxxxxxx') != NVL(D_NEW_CODICE_FISCALE_ESTERO,'xxxxxxxxxxxxxxxxx') THEN -- MODIFICATO CF
                IF sel_storico_anag.CODICE_FISCALE_ESTERO IS NULL AND D_NEW_CODICE_FISCALE_ESTERO IS NOT NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>ID. FISCALE ESTERO</ATTRIBUTO><VALORE>'||D_NEW_CODICE_FISCALE_ESTERO||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                  
                    dbms_output.put_Line('+ CODICE_FISCALE_ESTERO: '||D_NEW_CODICE_FISCALE_ESTERO);                   
                ELSIF SEL_STORICO_ANAG.CODICE_FISCALE_ESTERO IS NOT NULL AND D_NEW_CODICE_FISCALE_ESTERO IS NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>delete.png</ICONA><ATTRIBUTO>ID. FISCALE ESTERO</ATTRIBUTO><VALORE>'||SEL_STORICO_ANAG.CODICE_FISCALE_ESTERO||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                   
                    dbms_output.put_Line('- CODICE_FISCALE_ESTERO: '||SEL_STORICO_ANAG.CODICE_FISCALE_ESTERO);
                ELSE
                   D_XML:= '<ROWSET><ROW><ICONA>edit.png</ICONA><ATTRIBUTO>ID. FISCALE ESTERO</ATTRIBUTO><VALORE><![CDATA['||SEL_STORICO_ANAG.CODICE_FISCALE_ESTERO||' -> '||d_new_CODICE_FISCALE_ESTERO||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                     
                    dbms_output.put_LinE('CODICE_FISCALE_ESTERO: '||SEL_STORICO_ANAG.CODICE_FISCALE_ESTERO||' -> '||D_NEW_CODICE_FISCALE_ESTERO);    
                END IF;
            END IF;   
            if NVL(sel_storico_anag.PARTITA_IVA,'xxxxxxxxxxxxxxxxx') != NVL(D_NEW_PARTITA_IVA,'xxxxxxxxxxxxxxxxx') THEN -- MODIFICATO CF
                IF sel_storico_anag.PARTITA_IVA IS NULL AND D_NEW_PARTITA_IVA IS NOT NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>PARTITA IVA</ATTRIBUTO><VALORE>'||D_NEW_PARTITA_IVA||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                   
                    dbms_output.put_Line('+ PARTITA_IVA: '||D_NEW_PARTITA_IVA);
                ELSIF SEL_STORICO_ANAG.PARTITA_IVA IS NOT NULL AND D_NEW_PARTITA_IVA IS NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>delete.png</ICONA><ATTRIBUTO>PARTITA IVA</ATTRIBUTO><VALORE>'||SEL_STORICO_ANAG.PARTITA_IVA||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                  
                    dbms_output.put_Line('- PARTITA_IVA: '||SEL_STORICO_ANAG.PARTITA_IVA);
                ELSE
                   D_XML:= '<ROWSET><ROW><ICONA>edit.png</ICONA><ATTRIBUTO>PARTITA IVA</ATTRIBUTO><VALORE><![CDATA['||SEL_STORICO_ANAG.PARTITA_IVA||' -> '||d_new_PARTITA_IVA||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                 
                    dbms_output.put_LinE('PARTITA_IVA: '||SEL_STORICO_ANAG.PARTITA_IVA||' -> '||D_NEW_PARTITA_IVA);    
                END IF;
            END IF; 
            if NVL(sel_storico_anag.PARTITA_IVA_CEE,'xxxx') != NVL(D_NEW_PARTITA_IVA_CEE,'xxxx') THEN -- MODIFICATO CF
                IF sel_storico_anag.PARTITA_IVA_CEE IS NULL AND D_NEW_PARTITA_IVA_CEE IS NOT NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>PARTITA IVA CEE</ATTRIBUTO><VALORE>'||D_NEW_PARTITA_IVA_CEE||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                 
                    dbms_output.put_Line('+ PARTITA_IVA_CEE: '||D_NEW_PARTITA_IVA_CEE);
                ELSIF SEL_STORICO_ANAG.PARTITA_IVA_CEE IS NOT NULL AND D_NEW_PARTITA_IVA_CEE IS NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>delete.png</ICONA><ATTRIBUTO>PARTITA IVA CEE</ATTRIBUTO><VALORE>'||SEL_STORICO_ANAG.PARTITA_IVA_CEE||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                   
                    dbms_output.put_Line('- PARTITA_IVA_CEE: '||SEL_STORICO_ANAG.PARTITA_IVA_CEE);
                ELSE
                   D_XML:= '<ROWSET><ROW><ICONA>edit.png</ICONA><ATTRIBUTO>PARTITA IVA CEE</ATTRIBUTO><VALORE><![CDATA['||SEL_STORICO_ANAG.PARTITA_IVA_CEE||' -> '||d_new_PARTITA_IVA_CEE||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                    
                    dbms_output.put_LinE('PARTITA_IVA_CEE: '||SEL_STORICO_ANAG.PARTITA_IVA_CEE||' -> '||D_NEW_PARTITA_IVA_CEE);    
                END IF;
            END IF;  
            if NVL(sel_storico_anag.STATO_CEE,'xxxx') != NVL(D_NEW_STATO_CEE,'xxxx') THEN -- MODIFICATO CF
                IF sel_storico_anag.STATO_CEE IS NULL AND D_NEW_STATO_CEE IS NOT NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>STATO CEE</ATTRIBUTO><VALORE>'||D_NEW_STATO_CEE||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                   
                    dbms_output.put_Line('+ STATO_CEE: '||D_NEW_STATO_CEE);
                ELSIF SEL_STORICO_ANAG.STATO_CEE IS NOT NULL AND D_NEW_STATO_CEE IS NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>delete.png</ICONA><ATTRIBUTO>STATO CEE</ATTRIBUTO><VALORE>'||SEL_STORICO_ANAG.STATO_CEE||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                 
                    dbms_output.put_Line('- STATO_CEE: '||SEL_STORICO_ANAG.STATO_CEE);
                ELSE
                   D_XML:= '<ROWSET><ROW><ICONA>edit.png</ICONA><ATTRIBUTO>STATO CEE</ATTRIBUTO><VALORE><![CDATA['||SEL_STORICO_ANAG.STATO_CEE||' -> '||d_new_STATO_CEE||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                  
                    dbms_output.put_LinE('STATO_CEE: '||SEL_STORICO_ANAG.STATO_CEE||' -> '||D_NEW_STATO_CEE);    
                END IF;
            END IF;                         
            if NVL(sel_storico_anag.CITTADINANZA,'xxxx') != NVL(D_NEW_CITTADINANZA,'xxxx') THEN -- MODIFICATO CF
                IF sel_storico_anag.CITTADINANZA IS NULL AND D_NEW_CITTADINANZA IS NOT NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>CITTADINANZA</ATTRIBUTO><VALORE>'||D_NEW_CITTADINANZA||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                 
                    dbms_output.put_Line('+ CITTADINANZA: '||D_NEW_CITTADINANZA);
                ELSIF SEL_STORICO_ANAG.CITTADINANZA IS NOT NULL AND D_NEW_CITTADINANZA IS NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>delete.png</ICONA><ATTRIBUTO>CITTADINANZA</ATTRIBUTO><VALORE>'||SEL_STORICO_ANAG.CITTADINANZA||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                  
                    dbms_output.put_Line('- CITTADINANZA: '||SEL_STORICO_ANAG.CITTADINANZA);
                ELSE
                   D_XML:= '<ROWSET><ROW><ICONA>edit.png</ICONA><ATTRIBUTO>CITTADINANZA</ATTRIBUTO><VALORE><![CDATA['||SEL_STORICO_ANAG.CITTADINANZA||' -> '||d_new_CITTADINANZA||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                 
                    dbms_output.put_LinE('CITTADINANZA: '||SEL_STORICO_ANAG.CITTADINANZA||' -> '||D_NEW_CITTADINANZA);    
                END IF;
            END IF;     
            if NVL(sel_storico_anag.gruppo_ling,'xxxx') != NVL(D_NEW_GRUPPO_LING,'xxxx') THEN -- MODIFICATO CF
                IF sel_storico_anag.GRUPPO_LING IS NULL AND D_NEW_GRUPPO_LING IS NOT NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>GRUPPO LINGUISTICO</ATTRIBUTO><VALORE>'||D_NEW_GRUPPO_LING||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                 
                    dbms_output.put_Line('+ GRUPPO_LING: '||D_NEW_GRUPPO_LING);
                ELSIF SEL_STORICO_ANAG.GRUPPO_LING IS NOT NULL AND D_NEW_GRUPPO_LING IS NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>delete.png</ICONA><ATTRIBUTO>GRUPPO LINGUISTICO</ATTRIBUTO><VALORE>'||SEL_STORICO_ANAG.GRUPPO_LING||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                  
                    dbms_output.put_Line('- GRUPPO_LING: '||SEL_STORICO_ANAG.GRUPPO_LING);
                ELSE
                   D_XML:= '<ROWSET><ROW><ICONA>edit.png</ICONA><ATTRIBUTO>GRUPPO LINGUISTICO</ATTRIBUTO><VALORE><![CDATA['||SEL_STORICO_ANAG.GRUPPO_LING||' -> '||d_new_GRUPPO_LING||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                  
                    dbms_output.put_LinE('GRUPPO_LING: '||SEL_STORICO_ANAG.GRUPPO_LING||' -> '||D_NEW_GRUPPO_LING);    
                END IF;
            END IF;       
            if NVL(sel_storico_anag.COMPETENZA,'xxxxxxxxxxx') != NVL(D_NEW_COMPETENZA,'xxxxxxxxxxx') THEN -- MODIFICATO CF
                IF sel_storico_anag.COMPETENZA IS NULL AND D_NEW_COMPETENZA IS NOT NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>COMPETENZA</ATTRIBUTO><VALORE>'||D_NEW_COMPETENZA||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                 
                    dbms_output.put_Line('+ COMPETENZA: '||D_NEW_COMPETENZA);
                ELSIF SEL_STORICO_ANAG.COMPETENZA IS NOT NULL AND D_NEW_COMPETENZA IS NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>delete.png</ICONA><ATTRIBUTO>COMPETENZA</ATTRIBUTO><VALORE>'||SEL_STORICO_ANAG.COMPETENZA||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                 
                    dbms_output.put_Line('- COMPETENZA: '||SEL_STORICO_ANAG.COMPETENZA);
                ELSE
                   D_XML:= '<ROWSET><ROW><ICONA>edit.png</ICONA><ATTRIBUTO>COMPETENZA</ATTRIBUTO><VALORE><![CDATA['||SEL_STORICO_ANAG.COMPETENZA||' -> '||d_new_COMPETENZA||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                  
                    dbms_output.put_LinE('COMPETENZA: '||SEL_STORICO_ANAG.COMPETENZA||' -> '||D_NEW_COMPETENZA);    
                END IF;
            END IF;     
            if NVL(sel_storico_anag.COMPETENZA_ESCLUSIVA,'xx') != NVL(D_NEW_COMPETENZA_ESCLUSIVA,'xx') THEN -- MODIFICATO CF
                IF sel_storico_anag.COMPETENZA_ESCLUSIVA IS NULL AND D_NEW_COMPETENZA_ESCLUSIVA IS NOT NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>COMPETENZA ESCLUSIVA</ATTRIBUTO><VALORE>'||D_NEW_COMPETENZA_ESCLUSIVA||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                 
                    dbms_output.put_Line('+ COMPETENZA_ESCLUSIVA: '||D_NEW_COMPETENZA_ESCLUSIVA);
                ELSIF SEL_STORICO_ANAG.COMPETENZA_ESCLUSIVA IS NOT NULL AND D_NEW_COMPETENZA_ESCLUSIVA IS NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>delete.png</ICONA><ATTRIBUTO>COMPETENZA ESCLUSIVA</ATTRIBUTO><VALORE>'||SEL_STORICO_ANAG.COMPETENZA_esclusiva||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                   
                    dbms_output.put_Line('- COMPETENZA_ESCLUSIVA: '||SEL_STORICO_ANAG.COMPETENZA_ESCLUSIVA);
                ELSE
                   D_XML:= '<ROWSET><ROW><ICONA>edit.png</ICONA><ATTRIBUTO>COMPETENZA ESCLUSIVA</ATTRIBUTO><VALORE><![CDATA['||SEL_STORICO_ANAG.COMPETENZA_esclusiva||' -> '||d_new_COMPETENZA_esclusiva||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                   
                    dbms_output.put_LinE('COMPETENZA_ESCLUSIVA: '||SEL_STORICO_ANAG.COMPETENZA_ESCLUSIVA||' -> '||D_NEW_COMPETENZA_ESCLUSIVA);    
                END IF;
            END IF;    
            if NVL(sel_storico_anag.TIPO_SOGGETTO,'xx') != NVL(D_NEW_TIPO_SOGGETTO,'xx') THEN -- MODIFICATO CF
                IF sel_storico_anag.TIPO_SOGGETTO IS NULL AND D_NEW_TIPO_SOGGETTO IS NOT NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>TIPO SOGGETTO</ATTRIBUTO><VALORE>'||D_NEW_TIPO_SOGGETTO||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                 
                    dbms_output.put_Line('+ TIPO_SOGGETTO: '||D_NEW_TIPO_SOGGETTO);
                ELSIF SEL_STORICO_ANAG.TIPO_SOGGETTO IS NOT NULL AND D_NEW_TIPO_SOGGETTO IS NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>delete.png</ICONA><ATTRIBUTO>TIPO SOGGETTO</ATTRIBUTO><VALORE>'||SEL_STORICO_ANAG.TIPO_SOGGETTO||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                   
                    dbms_output.put_Line('- TIPO_SOGGETTO: '||SEL_STORICO_ANAG.TIPO_SOGGETTO);
                ELSE
                   D_XML:= '<ROWSET><ROW><ICONA>edit.png</ICONA><ATTRIBUTO>TIPO SOGGETTO</ATTRIBUTO><VALORE><![CDATA['||SEL_STORICO_ANAG.TIPO_SOGGETTO||' -> '||d_new_TIPO_SOGGETTO||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                   
                    dbms_output.put_LinE('TIPO_SOGGETTO: '||SEL_STORICO_ANAG.TIPO_SOGGETTO||' -> '||D_NEW_TIPO_SOGGETTO);    
                END IF;
            END IF;           

            if NVL(sel_storico_anag.FINE_VALIDITA,TO_DATE(3333333,'J')) != NVL(D_NEW_FINE_VALIDITA,TO_DATE(3333333,'J')) THEN -- MODIFICATO FINE_VALIDITA
                IF SEL_STORICO_ANAG.FINE_VALIDITA IS NULL AND D_NEW_FINE_VALIDITA IS NOT NULL THEN
                   D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>FINE VALIDITA''</ATTRIBUTO><VALORE>'||to_char(D_NEW_FINE_VALIDITA,'dd/mm/yyyy')||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                  
                    dbms_output.put_Line('+ FINE_VALIDITA: '||D_NEW_FINE_VALIDITA);
                ELSIF SEL_STORICO_ANAG.FINE_VALIDITA IS NOT NULL AND D_NEW_FINE_VALIDITA IS NULL THEN
                   D_XML:= '<ROWSET><ROW><ICONA>delete.png</ICONA><ATTRIBUTO>FINE VALIDITA''</ATTRIBUTO><VALORE>'||to_char(SEL_STORICO_ANAG.FINE_VALIDITA,'dd/mm/yyyy')||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                   
                    dbms_output.put_Line('- FINE_VALIDITA: '||SEL_STORICO_ANAG.FINE_VALIDITA);
                ELSE
                   D_XML:= '<ROWSET><ROW><ICONA>edit.png</ICONA><ATTRIBUTO>FINE VALIDITA''</ATTRIBUTO><VALORE><![CDATA['||to_char(SEL_STORICO_ANAG.FINE_VALIDITA,'dd/mm/yyyy')||' -> '||to_char(D_NEW_FINE_VALIDITA,'dd/mm/yyyy')||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                  
                    dbms_output.put_LinE('FINE_VALIDITA: '||SEL_STORICO_ANAG.FINE_VALIDITA||' -> '||D_NEW_FINE_VALIDITA);    
                END IF;
            END IF;  
            if NVL(sel_storico_anag.STATO_SOGGETTO,'xxxx') != NVL(D_NEW_STATO_SOGGETTO,'xxxx') THEN -- MODIFICATO CF
                IF sel_storico_anag.STATO_SOGGETTO IS NULL AND D_NEW_STATO_SOGGETTO IS NOT NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>STATO SOGGETTO</ATTRIBUTO><VALORE>'||D_NEW_STATO_SOGGETTO||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                 
                    dbms_output.put_Line('+ STATO_SOGGETTO: '||D_NEW_STATO_SOGGETTO);
                ELSIF SEL_STORICO_ANAG.STATO_SOGGETTO IS NOT NULL AND D_NEW_STATO_SOGGETTO IS NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>delete.png</ICONA><ATTRIBUTO>STATO SOGGETTO</ATTRIBUTO><VALORE>'||SEL_STORICO_ANAG.STATO_SOGGETTO||'</VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                 
                    dbms_output.put_Line('- STATO_SOGGETTO: '||SEL_STORICO_ANAG.STATO_SOGGETTO);
                ELSE
                   D_XML:= '<ROWSET><ROW><ICONA>edit.png</ICONA><ATTRIBUTO>STATO SOGGETTO</ATTRIBUTO><VALORE><![CDATA['||SEL_STORICO_ANAG.STATO_SOGGETTO||' -> '||d_new_STATO_SOGGETTO||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                  
                    dbms_output.put_LinE('STATO_SOGGETTO: '||SEL_STORICO_ANAG.STATO_SOGGETTO||' -> '||D_NEW_STATO_SOGGETTO);    
                END IF;
            END IF;    
            if NVL(sel_storico_anag.NOTE,'XxXx') != NVL(D_NEW_NOTE,'XxXx') THEN -- MODIFICATO CF
                IF sel_storico_anag.NOTE IS NULL AND D_NEW_NOTE IS NOT NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>add.png</ICONA><ATTRIBUTO>NOTE</ATTRIBUTO><VALORE><![CDATA['||D_NEW_NOTE||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                 
                    dbms_output.put_Line('+ NOTE: '||D_NEW_NOTE);
                ELSIF SEL_STORICO_ANAG.NOTE IS NOT NULL AND D_NEW_NOTE IS NULL THEN
                    D_XML:= '<ROWSET><ROW><ICONA>delete.png</ICONA><ATTRIBUTO>NOTE</ATTRIBUTO><VALORE><![CDATA['||SEL_STORICO_ANAG.NOTE||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                  
                    dbms_output.put_Line('- NOTE: '||SEL_STORICO_ANAG.NOTE);
                ELSE
                   D_XML:= '<ROWSET><ROW><ICONA>edit.png</ICONA><ATTRIBUTO>NOTE</ATTRIBUTO><VALORE><![CDATA['||SEL_STORICO_ANAG.NOTE||' -> '||d_new_NOTE||']]></VALORE></ROW></ROWSET>'||CHR(10)||CHR(13);
                   dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);                 
                    dbms_output.put_LinE('NOTE: '||SEL_STORICO_ANAG.NOTE||' -> '||D_NEW_NOTE);    
                END IF;
            END IF;                                                                                                                                                                                                   
        elsif sel_storico_anag.operazione = 'D' then --modifica del record
            dbms_output.put_line('Anagrafica con decorrenza '||TO_CHAR(sel_storico_anag.dal,'DD/MM/YYYY')||' eliminato da '||sel_storico_anag.utente||' il '||TO_CHAR(sel_storico_anag.data,'DD/MM/YYYY hh24:MI:SS'));
            D_XML:= '<ROWSET><ROW><OPERAZIONE>Anagrafica con decorrenza '||TO_CHAR(sel_storico_anag.dal,'DD/MM/YYYY')||' eliminato da '||nvl(ad4_utente.get_nominativo(sel_storico_anag.utente),sel_storico_anag.utente)||' il '||TO_CHAR(sel_storico_anag.data,'DD/MM/YYYY hh24:MI:SS')||'</OPERAZIONE></ROW></ROWSET>'||CHR(10)||CHR(13);
            dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);            
        end if;
    end loop;
    d_xml:='</ROWSET>';
    dbms_lob.writeappend(d_tree_storico, length(d_xml),d_xml);  
    RETURN    d_tree_storico;  
end;
/

