CREATE OR REPLACE package anagrafici_tpk is /* MASTER_LINK */
/******************************************************************************
 NOME:        anagrafici_tpk
 DESCRIZIONE: Gestione tabella ANAGRAFICI.
 ANNOTAZIONI: .
 REVISIONI:   Table Revision: 07/01/2019 17:09:15
              SiaPKGen Revision: V2.00.001.
              SiaTPKDeclare Revision: V2.03.000.
 <CODE>
 Rev.  Data        Autore      Descrizione.
 00    08/06/2017  snegroni  Generazione automatica. 
 01    13/02/2019  SNegroni  Generazione automatica. 
 </CODE>
******************************************************************************/
   -- Revisione del Package
   s_revisione constant AFC.t_revision := 'V1.01';
   s_table_name constant AFC.t_object_name := 'ANAGRAFICI';
   subtype t_rowtype is ANAGRAFICI%rowtype;
   -- Tipo del record primary key
subtype t_id_anagrafica  is ANAGRAFICI.id_anagrafica%type;
   type t_PK is record
   ( 
id_anagrafica  t_id_anagrafica
   );
   -- Versione e revisione
   function versione /* SLAVE_COPY */
   return varchar2;
   pragma restrict_references( versione, WNDS );
   -- Costruttore di record chiave
   function PK /* SLAVE_COPY */
   (
    p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return t_PK;
   pragma restrict_references( PK, WNDS );
   -- Controllo integrita chiave
   function can_handle /* SLAVE_COPY */
   (
    p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return number;
   pragma restrict_references( can_handle, WNDS );
   -- Controllo integrita chiave
   -- wrapper boolean 
   function canHandle /* SLAVE_COPY */
   (
    p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return boolean;
   pragma restrict_references( canhandle, WNDS );
    -- Esistenza riga con chiave indicata
   function exists_id /* SLAVE_COPY */
   (
    p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return number;
   pragma restrict_references( exists_id, WNDS );
   -- Esistenza riga con chiave indicata
   -- wrapper boolean
   function existsId /* SLAVE_COPY */
   (
    p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return boolean;
   pragma restrict_references( existsid, WNDS );
   -- Inserimento di una riga
   procedure ins
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type default null
   , p_ni  in ANAGRAFICI.ni%type 
   , p_dal  in ANAGRAFICI.dal%type 
   , p_al  in ANAGRAFICI.al%type default null
   , p_cognome  in ANAGRAFICI.cognome%type 
   , p_nome  in ANAGRAFICI.nome%type default null
   , p_sesso  in ANAGRAFICI.sesso%type default null
   , p_data_nas  in ANAGRAFICI.data_nas%type default null
   , p_provincia_nas  in ANAGRAFICI.provincia_nas%type default null
   , p_comune_nas  in ANAGRAFICI.comune_nas%type default null
   , p_luogo_nas  in ANAGRAFICI.luogo_nas%type default null
   , p_codice_fiscale  in ANAGRAFICI.codice_fiscale%type default null
   , p_codice_fiscale_estero  in ANAGRAFICI.codice_fiscale_estero%type default null
   , p_partita_iva  in ANAGRAFICI.partita_iva%type default null
   , p_cittadinanza  in ANAGRAFICI.cittadinanza%type default null
   , p_gruppo_ling  in ANAGRAFICI.gruppo_ling%type default null
   , p_competenza  in ANAGRAFICI.competenza%type default null
   , p_competenza_esclusiva  in ANAGRAFICI.competenza_esclusiva%type default null
   , p_tipo_soggetto  in ANAGRAFICI.tipo_soggetto%type default null
   , p_stato_cee  in ANAGRAFICI.stato_cee%type default null
   , p_partita_iva_cee  in ANAGRAFICI.partita_iva_cee%type default null
   , p_fine_validita  in ANAGRAFICI.fine_validita%type default null
   , p_stato_soggetto  in ANAGRAFICI.stato_soggetto%type default 'U'
   , p_denominazione  in ANAGRAFICI.denominazione%type default null
   , p_note  in ANAGRAFICI.note%type default null
   , p_version  in ANAGRAFICI.version%type default 0
   , p_utente  in ANAGRAFICI.utente%type default null
   , p_data_agg  in ANAGRAFICI.data_agg%type default SYSDATE
   , p_denominazione_ricerca  in ANAGRAFICI.denominazione_ricerca%type default null
   );
   function ins  /*+ SOA  */
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type default null
   , p_ni  in ANAGRAFICI.ni%type 
   , p_dal  in ANAGRAFICI.dal%type 
   , p_al  in ANAGRAFICI.al%type default null
   , p_cognome  in ANAGRAFICI.cognome%type 
   , p_nome  in ANAGRAFICI.nome%type default null
   , p_sesso  in ANAGRAFICI.sesso%type default null
   , p_data_nas  in ANAGRAFICI.data_nas%type default null
   , p_provincia_nas  in ANAGRAFICI.provincia_nas%type default null
   , p_comune_nas  in ANAGRAFICI.comune_nas%type default null
   , p_luogo_nas  in ANAGRAFICI.luogo_nas%type default null
   , p_codice_fiscale  in ANAGRAFICI.codice_fiscale%type default null
   , p_codice_fiscale_estero  in ANAGRAFICI.codice_fiscale_estero%type default null
   , p_partita_iva  in ANAGRAFICI.partita_iva%type default null
   , p_cittadinanza  in ANAGRAFICI.cittadinanza%type default null
   , p_gruppo_ling  in ANAGRAFICI.gruppo_ling%type default null
   , p_competenza  in ANAGRAFICI.competenza%type default null
   , p_competenza_esclusiva  in ANAGRAFICI.competenza_esclusiva%type default null
   , p_tipo_soggetto  in ANAGRAFICI.tipo_soggetto%type default null
   , p_stato_cee  in ANAGRAFICI.stato_cee%type default null
   , p_partita_iva_cee  in ANAGRAFICI.partita_iva_cee%type default null
   , p_fine_validita  in ANAGRAFICI.fine_validita%type default null
   , p_stato_soggetto  in ANAGRAFICI.stato_soggetto%type default 'U'
   , p_denominazione  in ANAGRAFICI.denominazione%type default null
   , p_note  in ANAGRAFICI.note%type default null
   , p_version  in ANAGRAFICI.version%type default 0
   , p_utente  in ANAGRAFICI.utente%type default null
   , p_data_agg  in ANAGRAFICI.data_agg%type default SYSDATE
   , p_denominazione_ricerca  in ANAGRAFICI.denominazione_ricerca%type default null
   ) return number;
   -- Aggiornamento di una riga
   procedure upd  /*+ SOA  */
   (
     p_check_OLD  in integer default 0
   , p_NEW_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_OLD_id_anagrafica  in ANAGRAFICI.id_anagrafica%type default null
   , p_NEW_ni  in ANAGRAFICI.ni%type default afc.default_null('ANAGRAFICI.ni')
   , p_OLD_ni  in ANAGRAFICI.ni%type default null
   , p_NEW_dal  in ANAGRAFICI.dal%type default afc.default_null('ANAGRAFICI.dal')
   , p_OLD_dal  in ANAGRAFICI.dal%type default null
   , p_NEW_al  in ANAGRAFICI.al%type default afc.default_null('ANAGRAFICI.al')
   , p_OLD_al  in ANAGRAFICI.al%type default null
   , p_NEW_cognome  in ANAGRAFICI.cognome%type default afc.default_null('ANAGRAFICI.cognome')
   , p_OLD_cognome  in ANAGRAFICI.cognome%type default null
   , p_NEW_nome  in ANAGRAFICI.nome%type default afc.default_null('ANAGRAFICI.nome')
   , p_OLD_nome  in ANAGRAFICI.nome%type default null
   , p_NEW_sesso  in ANAGRAFICI.sesso%type default afc.default_null('ANAGRAFICI.sesso')
   , p_OLD_sesso  in ANAGRAFICI.sesso%type default null
   , p_NEW_data_nas  in ANAGRAFICI.data_nas%type default afc.default_null('ANAGRAFICI.data_nas')
   , p_OLD_data_nas  in ANAGRAFICI.data_nas%type default null
   , p_NEW_provincia_nas  in ANAGRAFICI.provincia_nas%type default afc.default_null('ANAGRAFICI.provincia_nas')
   , p_OLD_provincia_nas  in ANAGRAFICI.provincia_nas%type default null
   , p_NEW_comune_nas  in ANAGRAFICI.comune_nas%type default afc.default_null('ANAGRAFICI.comune_nas')
   , p_OLD_comune_nas  in ANAGRAFICI.comune_nas%type default null
   , p_NEW_luogo_nas  in ANAGRAFICI.luogo_nas%type default afc.default_null('ANAGRAFICI.luogo_nas')
   , p_OLD_luogo_nas  in ANAGRAFICI.luogo_nas%type default null
   , p_NEW_codice_fiscale  in ANAGRAFICI.codice_fiscale%type default afc.default_null('ANAGRAFICI.codice_fiscale')
   , p_OLD_codice_fiscale  in ANAGRAFICI.codice_fiscale%type default null
   , p_NEW_codice_fiscale_estero  in ANAGRAFICI.codice_fiscale_estero%type default afc.default_null('ANAGRAFICI.codice_fiscale_estero')
   , p_OLD_codice_fiscale_estero  in ANAGRAFICI.codice_fiscale_estero%type default null
   , p_NEW_partita_iva  in ANAGRAFICI.partita_iva%type default afc.default_null('ANAGRAFICI.partita_iva')
   , p_OLD_partita_iva  in ANAGRAFICI.partita_iva%type default null
   , p_NEW_cittadinanza  in ANAGRAFICI.cittadinanza%type default afc.default_null('ANAGRAFICI.cittadinanza')
   , p_OLD_cittadinanza  in ANAGRAFICI.cittadinanza%type default null
   , p_NEW_gruppo_ling  in ANAGRAFICI.gruppo_ling%type default afc.default_null('ANAGRAFICI.gruppo_ling')
   , p_OLD_gruppo_ling  in ANAGRAFICI.gruppo_ling%type default null
   , p_NEW_competenza  in ANAGRAFICI.competenza%type default afc.default_null('ANAGRAFICI.competenza')
   , p_OLD_competenza  in ANAGRAFICI.competenza%type default null
   , p_NEW_competenza_esclusiva  in ANAGRAFICI.competenza_esclusiva%type default afc.default_null('ANAGRAFICI.competenza_esclusiva')
   , p_OLD_competenza_esclusiva  in ANAGRAFICI.competenza_esclusiva%type default null
   , p_NEW_tipo_soggetto  in ANAGRAFICI.tipo_soggetto%type default afc.default_null('ANAGRAFICI.tipo_soggetto')
   , p_OLD_tipo_soggetto  in ANAGRAFICI.tipo_soggetto%type default null
   , p_NEW_stato_cee  in ANAGRAFICI.stato_cee%type default afc.default_null('ANAGRAFICI.stato_cee')
   , p_OLD_stato_cee  in ANAGRAFICI.stato_cee%type default null
   , p_NEW_partita_iva_cee  in ANAGRAFICI.partita_iva_cee%type default afc.default_null('ANAGRAFICI.partita_iva_cee')
   , p_OLD_partita_iva_cee  in ANAGRAFICI.partita_iva_cee%type default null
   , p_NEW_fine_validita  in ANAGRAFICI.fine_validita%type default afc.default_null('ANAGRAFICI.fine_validita')
   , p_OLD_fine_validita  in ANAGRAFICI.fine_validita%type default null
   , p_NEW_stato_soggetto  in ANAGRAFICI.stato_soggetto%type default afc.default_null('ANAGRAFICI.stato_soggetto')
   , p_OLD_stato_soggetto  in ANAGRAFICI.stato_soggetto%type default null
   , p_NEW_denominazione  in ANAGRAFICI.denominazione%type default afc.default_null('ANAGRAFICI.denominazione')
   , p_OLD_denominazione  in ANAGRAFICI.denominazione%type default null
   , p_NEW_note  in ANAGRAFICI.note%type default afc.default_null('ANAGRAFICI.note')
   , p_OLD_note  in ANAGRAFICI.note%type default null
   , p_NEW_version  in ANAGRAFICI.version%type default afc.default_null('ANAGRAFICI.version')
   , p_OLD_version  in ANAGRAFICI.version%type default null
   , p_NEW_utente  in ANAGRAFICI.utente%type default afc.default_null('ANAGRAFICI.utente')
   , p_OLD_utente  in ANAGRAFICI.utente%type default null
   , p_NEW_data_agg  in ANAGRAFICI.data_agg%type default afc.default_null('ANAGRAFICI.data_agg')
   , p_OLD_data_agg  in ANAGRAFICI.data_agg%type default null
   , p_NEW_denominazione_ricerca  in ANAGRAFICI.denominazione_ricerca%type default afc.default_null('ANAGRAFICI.denominazione_ricerca')
   , p_OLD_denominazione_ricerca  in ANAGRAFICI.denominazione_ricerca%type default null
   );
   -- Aggiornamento del campo di una riga
   procedure upd_column
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_column         in varchar2
   , p_value          in varchar2 default null
   , p_literal_value  in number   default 1
   );
   procedure upd_column
   (
p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_column in varchar2
   , p_value  in date
   );
   -- Cancellazione di una riga
   procedure del  /*+ SOA  */
   (
     p_check_OLD  in integer default 0
   , p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_ni  in ANAGRAFICI.ni%type default null
   , p_dal  in ANAGRAFICI.dal%type default null
   , p_al  in ANAGRAFICI.al%type default null
   , p_cognome  in ANAGRAFICI.cognome%type default null
   , p_nome  in ANAGRAFICI.nome%type default null
   , p_sesso  in ANAGRAFICI.sesso%type default null
   , p_data_nas  in ANAGRAFICI.data_nas%type default null
   , p_provincia_nas  in ANAGRAFICI.provincia_nas%type default null
   , p_comune_nas  in ANAGRAFICI.comune_nas%type default null
   , p_luogo_nas  in ANAGRAFICI.luogo_nas%type default null
   , p_codice_fiscale  in ANAGRAFICI.codice_fiscale%type default null
   , p_codice_fiscale_estero  in ANAGRAFICI.codice_fiscale_estero%type default null
   , p_partita_iva  in ANAGRAFICI.partita_iva%type default null
   , p_cittadinanza  in ANAGRAFICI.cittadinanza%type default null
   , p_gruppo_ling  in ANAGRAFICI.gruppo_ling%type default null
   , p_competenza  in ANAGRAFICI.competenza%type default null
   , p_competenza_esclusiva  in ANAGRAFICI.competenza_esclusiva%type default null
   , p_tipo_soggetto  in ANAGRAFICI.tipo_soggetto%type default null
   , p_stato_cee  in ANAGRAFICI.stato_cee%type default null
   , p_partita_iva_cee  in ANAGRAFICI.partita_iva_cee%type default null
   , p_fine_validita  in ANAGRAFICI.fine_validita%type default null
   , p_stato_soggetto  in ANAGRAFICI.stato_soggetto%type default null
   , p_denominazione  in ANAGRAFICI.denominazione%type default null
   , p_note  in ANAGRAFICI.note%type default null
   , p_version  in ANAGRAFICI.version%type default null
   , p_utente  in ANAGRAFICI.utente%type default null
   , p_data_agg  in ANAGRAFICI.data_agg%type default null
   , p_denominazione_ricerca  in ANAGRAFICI.denominazione_ricerca%type default null
   );
-- Getter per attributo ni di riga identificata da chiave
   function get_ni /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.ni%type;
   pragma restrict_references( get_ni, WNDS );
-- Getter per attributo dal di riga identificata da chiave
   function get_dal /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.dal%type;
   pragma restrict_references( get_dal, WNDS );
-- Getter per attributo al di riga identificata da chiave
   function get_al /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.al%type;
   pragma restrict_references( get_al, WNDS );
-- Getter per attributo cognome di riga identificata da chiave
   function get_cognome /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.cognome%type;
   pragma restrict_references( get_cognome, WNDS );
-- Getter per attributo nome di riga identificata da chiave
   function get_nome /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.nome%type;
   pragma restrict_references( get_nome, WNDS );
-- Getter per attributo sesso di riga identificata da chiave
   function get_sesso /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.sesso%type;
   pragma restrict_references( get_sesso, WNDS );
-- Getter per attributo data_nas di riga identificata da chiave
   function get_data_nas /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.data_nas%type;
   pragma restrict_references( get_data_nas, WNDS );
-- Getter per attributo provincia_nas di riga identificata da chiave
   function get_provincia_nas /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.provincia_nas%type;
   pragma restrict_references( get_provincia_nas, WNDS );
-- Getter per attributo comune_nas di riga identificata da chiave
   function get_comune_nas /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.comune_nas%type;
   pragma restrict_references( get_comune_nas, WNDS );
-- Getter per attributo luogo_nas di riga identificata da chiave
   function get_luogo_nas /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.luogo_nas%type;
   pragma restrict_references( get_luogo_nas, WNDS );
-- Getter per attributo codice_fiscale di riga identificata da chiave
   function get_codice_fiscale /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.codice_fiscale%type;
   pragma restrict_references( get_codice_fiscale, WNDS );
-- Getter per attributo codice_fiscale_estero di riga identificata da chiave
   function get_codice_fiscale_estero /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.codice_fiscale_estero%type;
   pragma restrict_references( get_codice_fiscale_estero, WNDS );
-- Getter per attributo partita_iva di riga identificata da chiave
   function get_partita_iva /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.partita_iva%type;
   pragma restrict_references( get_partita_iva, WNDS );
-- Getter per attributo cittadinanza di riga identificata da chiave
   function get_cittadinanza /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.cittadinanza%type;
   pragma restrict_references( get_cittadinanza, WNDS );
-- Getter per attributo gruppo_ling di riga identificata da chiave
   function get_gruppo_ling /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.gruppo_ling%type;
   pragma restrict_references( get_gruppo_ling, WNDS );
-- Getter per attributo competenza di riga identificata da chiave
   function get_competenza /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.competenza%type;
   pragma restrict_references( get_competenza, WNDS );
-- Getter per attributo competenza_esclusiva di riga identificata da chiave
   function get_competenza_esclusiva /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.competenza_esclusiva%type;
   pragma restrict_references( get_competenza_esclusiva, WNDS );
-- Getter per attributo tipo_soggetto di riga identificata da chiave
   function get_tipo_soggetto /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.tipo_soggetto%type;
   pragma restrict_references( get_tipo_soggetto, WNDS );
-- Getter per attributo stato_cee di riga identificata da chiave
   function get_stato_cee /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.stato_cee%type;
   pragma restrict_references( get_stato_cee, WNDS );
-- Getter per attributo partita_iva_cee di riga identificata da chiave
   function get_partita_iva_cee /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.partita_iva_cee%type;
   pragma restrict_references( get_partita_iva_cee, WNDS );
-- Getter per attributo fine_validita di riga identificata da chiave
   function get_fine_validita /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.fine_validita%type;
   pragma restrict_references( get_fine_validita, WNDS );
-- Getter per attributo stato_soggetto di riga identificata da chiave
   function get_stato_soggetto /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.stato_soggetto%type;
   pragma restrict_references( get_stato_soggetto, WNDS );
-- Getter per attributo denominazione di riga identificata da chiave
   function get_denominazione /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.denominazione%type;
   pragma restrict_references( get_denominazione, WNDS );
-- Getter per attributo note di riga identificata da chiave
   function get_note /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.note%type;
   pragma restrict_references( get_note, WNDS );
-- Getter per attributo version di riga identificata da chiave
   function get_version /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.version%type;
   pragma restrict_references( get_version, WNDS );
-- Getter per attributo utente di riga identificata da chiave
   function get_utente /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.utente%type;
   pragma restrict_references( get_utente, WNDS );
-- Getter per attributo data_agg di riga identificata da chiave
   function get_data_agg /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.data_agg%type;
   pragma restrict_references( get_data_agg, WNDS );
-- Getter per attributo denominazione_ricerca di riga identificata da chiave
   function get_denominazione_ricerca /* SLAVE_COPY */ 
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   ) return ANAGRAFICI.denominazione_ricerca%type;
   pragma restrict_references( get_denominazione_ricerca, WNDS );
-- Setter per attributo id_anagrafica di riga identificata da chiave
   procedure set_id_anagrafica
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.id_anagrafica%type default null
   );
-- Setter per attributo ni di riga identificata da chiave
   procedure set_ni
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.ni%type default null
   );
-- Setter per attributo dal di riga identificata da chiave
   procedure set_dal
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.dal%type default null
   );
-- Setter per attributo al di riga identificata da chiave
   procedure set_al
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.al%type default null
   );
-- Setter per attributo cognome di riga identificata da chiave
   procedure set_cognome
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.cognome%type default null
   );
-- Setter per attributo nome di riga identificata da chiave
   procedure set_nome
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.nome%type default null
   );
-- Setter per attributo sesso di riga identificata da chiave
   procedure set_sesso
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.sesso%type default null
   );
-- Setter per attributo data_nas di riga identificata da chiave
   procedure set_data_nas
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.data_nas%type default null
   );
-- Setter per attributo provincia_nas di riga identificata da chiave
   procedure set_provincia_nas
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.provincia_nas%type default null
   );
-- Setter per attributo comune_nas di riga identificata da chiave
   procedure set_comune_nas
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.comune_nas%type default null
   );
-- Setter per attributo luogo_nas di riga identificata da chiave
   procedure set_luogo_nas
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.luogo_nas%type default null
   );
-- Setter per attributo codice_fiscale di riga identificata da chiave
   procedure set_codice_fiscale
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.codice_fiscale%type default null
   );
-- Setter per attributo codice_fiscale_estero di riga identificata da chiave
   procedure set_codice_fiscale_estero
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.codice_fiscale_estero%type default null
   );
-- Setter per attributo partita_iva di riga identificata da chiave
   procedure set_partita_iva
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.partita_iva%type default null
   );
-- Setter per attributo cittadinanza di riga identificata da chiave
   procedure set_cittadinanza
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.cittadinanza%type default null
   );
-- Setter per attributo gruppo_ling di riga identificata da chiave
   procedure set_gruppo_ling
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.gruppo_ling%type default null
   );
-- Setter per attributo competenza di riga identificata da chiave
   procedure set_competenza
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.competenza%type default null
   );
-- Setter per attributo competenza_esclusiva di riga identificata da chiave
   procedure set_competenza_esclusiva
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.competenza_esclusiva%type default null
   );
-- Setter per attributo tipo_soggetto di riga identificata da chiave
   procedure set_tipo_soggetto
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.tipo_soggetto%type default null
   );
-- Setter per attributo stato_cee di riga identificata da chiave
   procedure set_stato_cee
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.stato_cee%type default null
   );
-- Setter per attributo partita_iva_cee di riga identificata da chiave
   procedure set_partita_iva_cee
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.partita_iva_cee%type default null
   );
-- Setter per attributo fine_validita di riga identificata da chiave
   procedure set_fine_validita
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.fine_validita%type default null
   );
-- Setter per attributo stato_soggetto di riga identificata da chiave
   procedure set_stato_soggetto
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.stato_soggetto%type default null
   );
-- Setter per attributo denominazione di riga identificata da chiave
   procedure set_denominazione
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.denominazione%type default null
   );
-- Setter per attributo note di riga identificata da chiave
   procedure set_note
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.note%type default null
   );
-- Setter per attributo version di riga identificata da chiave
   procedure set_version
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.version%type default null
   );
-- Setter per attributo utente di riga identificata da chiave
   procedure set_utente
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.utente%type default null
   );
-- Setter per attributo data_agg di riga identificata da chiave
   procedure set_data_agg
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.data_agg%type default null
   );
-- Setter per attributo denominazione_ricerca di riga identificata da chiave
   procedure set_denominazione_ricerca
   (
     p_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
   , p_value  in ANAGRAFICI.denominazione_ricerca%type default null
   );
   -- where_condition per statement di ricerca
   function where_condition /* SLAVE_COPY */
   ( p_QBE  in number default 0
   , p_other_condition in varchar2 default null
   , p_id_anagrafica  in varchar2 default null
   , p_ni  in varchar2 default null
   , p_dal  in varchar2 default null
   , p_al  in varchar2 default null
   , p_cognome  in varchar2 default null
   , p_nome  in varchar2 default null
   , p_sesso  in varchar2 default null
   , p_data_nas  in varchar2 default null
   , p_provincia_nas  in varchar2 default null
   , p_comune_nas  in varchar2 default null
   , p_luogo_nas  in varchar2 default null
   , p_codice_fiscale  in varchar2 default null
   , p_codice_fiscale_estero  in varchar2 default null
   , p_partita_iva  in varchar2 default null
   , p_cittadinanza  in varchar2 default null
   , p_gruppo_ling  in varchar2 default null
   , p_competenza  in varchar2 default null
   , p_competenza_esclusiva  in varchar2 default null
   , p_tipo_soggetto  in varchar2 default null
   , p_stato_cee  in varchar2 default null
   , p_partita_iva_cee  in varchar2 default null
   , p_fine_validita  in varchar2 default null
   , p_stato_soggetto  in varchar2 default null
   , p_denominazione  in varchar2 default null
   , p_note  in varchar2 default null
   , p_version  in varchar2 default null
   , p_utente  in varchar2 default null
   , p_data_agg  in varchar2 default null
   , p_denominazione_ricerca  in varchar2 default null
   ) return AFC.t_statement;
   -- righe corrispondenti alla selezione indicata
   function get_rows  /*+ SOA  */ /* SLAVE_COPY */
   ( p_QBE  in number default 0
   , p_other_condition in varchar2 default null
   , p_order_by in varchar2 default null
   , p_extra_columns in varchar2 default null
   , p_extra_condition in varchar2 default null
   , p_columns in varchar2 default null
   , p_offset in number default null
   , p_limit in number default null
   , p_id_anagrafica  in varchar2 default null
   , p_ni  in varchar2 default null
   , p_dal  in varchar2 default null
   , p_al  in varchar2 default null
   , p_cognome  in varchar2 default null
   , p_nome  in varchar2 default null
   , p_sesso  in varchar2 default null
   , p_data_nas  in varchar2 default null
   , p_provincia_nas  in varchar2 default null
   , p_comune_nas  in varchar2 default null
   , p_luogo_nas  in varchar2 default null
   , p_codice_fiscale  in varchar2 default null
   , p_codice_fiscale_estero  in varchar2 default null
   , p_partita_iva  in varchar2 default null
   , p_cittadinanza  in varchar2 default null
   , p_gruppo_ling  in varchar2 default null
   , p_competenza  in varchar2 default null
   , p_competenza_esclusiva  in varchar2 default null
   , p_tipo_soggetto  in varchar2 default null
   , p_stato_cee  in varchar2 default null
   , p_partita_iva_cee  in varchar2 default null
   , p_fine_validita  in varchar2 default null
   , p_stato_soggetto  in varchar2 default null
   , p_denominazione  in varchar2 default null
   , p_note  in varchar2 default null
   , p_version  in varchar2 default null
   , p_utente  in varchar2 default null
   , p_data_agg  in varchar2 default null
   , p_denominazione_ricerca  in varchar2 default null
   ) return AFC.t_ref_cursor;
   -- Numero di righe corrispondente alla selezione indicata
   -- Almeno un attributo deve essere valido (non null)
   function count_rows /* SLAVE_COPY */
   ( p_QBE in number default 0
   , p_other_condition in varchar2 default null
   , p_extra_condition in varchar2 default null
   , p_columns in varchar2 default null
   , p_id_anagrafica  in varchar2 default null
   , p_ni  in varchar2 default null
   , p_dal  in varchar2 default null
   , p_al  in varchar2 default null
   , p_cognome  in varchar2 default null
   , p_nome  in varchar2 default null
   , p_sesso  in varchar2 default null
   , p_data_nas  in varchar2 default null
   , p_provincia_nas  in varchar2 default null
   , p_comune_nas  in varchar2 default null
   , p_luogo_nas  in varchar2 default null
   , p_codice_fiscale  in varchar2 default null
   , p_codice_fiscale_estero  in varchar2 default null
   , p_partita_iva  in varchar2 default null
   , p_cittadinanza  in varchar2 default null
   , p_gruppo_ling  in varchar2 default null
   , p_competenza  in varchar2 default null
   , p_competenza_esclusiva  in varchar2 default null
   , p_tipo_soggetto  in varchar2 default null
   , p_stato_cee  in varchar2 default null
   , p_partita_iva_cee  in varchar2 default null
   , p_fine_validita  in varchar2 default null
   , p_stato_soggetto  in varchar2 default null
   , p_denominazione  in varchar2 default null
   , p_note  in varchar2 default null
   , p_version  in varchar2 default null
   , p_utente  in varchar2 default null
   , p_data_agg  in varchar2 default null
   , p_denominazione_ricerca  in varchar2 default null
   ) return integer;
end anagrafici_tpk;
/

