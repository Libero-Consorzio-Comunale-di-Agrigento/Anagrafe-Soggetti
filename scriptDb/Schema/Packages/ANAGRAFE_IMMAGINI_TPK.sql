CREATE OR REPLACE package anagrafe_immagini_tpk is /* MASTER_LINK */
/******************************************************************************
 NOME:        anagrafe_immagini_tpk
 DESCRIZIONE: Gestione tabella ANAGRAFE_IMMAGINI.
 ANNOTAZIONI: .
 REVISIONI:   Template Revision: 1.53.
 <CODE>
 Rev.  Data       Autore  Descrizione.
 00    15/07/2010  snegroni  Prima emissione.
 </CODE>
******************************************************************************/
   -- Revisione del Package
   s_revisione constant AFC.t_revision := 'V1.00';
   s_table_name constant AFC.t_object_name := 'ANAGRAFE_IMMAGINI';
   subtype t_rowtype is ANAGRAFE_IMMAGINI%rowtype;
   -- Tipo del record primary key
   subtype t_ni  is ANAGRAFE_IMMAGINI.ni%type;
   type t_PK is record
   (
    ni  t_ni
   );
   -- Versione e revisione
   function versione /* SLAVE_COPY */
   return varchar2;
   pragma restrict_references( versione, WNDS );
   -- Costruttore di record chiave
   function PK /* SLAVE_COPY */
   (
    p_ni  in ANAGRAFE_IMMAGINI.ni%type
   ) return t_PK;
   pragma restrict_references( PK, WNDS );
   -- Controllo integrità chiave
   function can_handle /* SLAVE_COPY */
   (
    p_ni  in ANAGRAFE_IMMAGINI.ni%type
   ) return number;
   pragma restrict_references( can_handle, WNDS );
   -- Controllo integrità chiave
   -- wrapper boolean
   function canHandle /* SLAVE_COPY */
   (
    p_ni  in ANAGRAFE_IMMAGINI.ni%type
   ) return boolean;
   pragma restrict_references( canhandle, WNDS );
    -- Esistenza riga con chiave indicata
   function exists_id /* SLAVE_COPY */
   (
    p_ni  in ANAGRAFE_IMMAGINI.ni%type
   ) return number;
   pragma restrict_references( exists_id, WNDS );
   -- Esistenza riga con chiave indicata
   -- wrapper boolean
   function existsId /* SLAVE_COPY */
   (
    p_ni  in ANAGRAFE_IMMAGINI.ni%type
   ) return boolean;
   pragma restrict_references( existsid, WNDS );
   -- Inserimento di una riga
   procedure ins  /*+ SOA  */
   (
     p_ni  in ANAGRAFE_IMMAGINI.ni%type default null
   , p_id_immagine  in ANAGRAFE_IMMAGINI.id_immagine%type
   );
   function ins  /*+ SOA  */
   (
     p_ni  in ANAGRAFE_IMMAGINI.ni%type default null
   , p_id_immagine  in ANAGRAFE_IMMAGINI.id_immagine%type
   ) return integer;
   -- Aggiornamento di una riga
   procedure upd  /*+ SOA  */
   (
     p_check_OLD  in integer default 0
   , p_NEW_ni  in ANAGRAFE_IMMAGINI.ni%type
   , p_OLD_ni  in ANAGRAFE_IMMAGINI.ni%type default null
   , p_NEW_id_immagine  in ANAGRAFE_IMMAGINI.id_immagine%type default afc.default_null('ANAGRAFE_IMMAGINI.id_immagine')
   , p_OLD_id_immagine  in ANAGRAFE_IMMAGINI.id_immagine%type default null
   );
   -- Aggiornamento del campo di una riga
   procedure upd_column
   (
     p_ni  in ANAGRAFE_IMMAGINI.ni%type
   , p_column         in varchar2
   , p_value          in varchar2 default null
   , p_literal_value  in number   default 1
   );
   -- Cancellazione di una riga
   procedure del  /*+ SOA  */
   (
     p_check_OLD  in integer default 0
   , p_ni  in ANAGRAFE_IMMAGINI.ni%type
   , p_id_immagine  in ANAGRAFE_IMMAGINI.id_immagine%type default null
   );
   -- Getter per attributo id_immagine di riga identificata da chiave
   function get_id_immagine /* SLAVE_COPY */
   (
     p_ni  in ANAGRAFE_IMMAGINI.ni%type
   ) return ANAGRAFE_IMMAGINI.id_immagine%type;
   pragma restrict_references( get_id_immagine, WNDS );
   -- Setter per attributo ni di riga identificata da chiave
   procedure set_ni
   (
     p_ni  in ANAGRAFE_IMMAGINI.ni%type
   , p_value  in ANAGRAFE_IMMAGINI.ni%type default null
   );
   -- Setter per attributo id_immagine di riga identificata da chiave
   procedure set_id_immagine
   (
     p_ni  in ANAGRAFE_IMMAGINI.ni%type
   , p_value  in ANAGRAFE_IMMAGINI.id_immagine%type default null
   );
   -- righe corrispondenti alla selezione indicata
   function get_rows  /*+ SOA  */ /* SLAVE_COPY */
   ( p_QBE  in number default 0
   , p_other_condition in varchar2 default null
   , p_order_by in varchar2 default null
   , p_extra_columns in varchar2 default null
   , p_extra_condition in varchar2 default null
   , p_ni  in varchar2 default null
   , p_id_immagine  in varchar2 default null
   ) return AFC.t_ref_cursor;
   -- Numero di righe corrispondente alla selezione indicata
   -- Almeno un attributo deve essere valido (non null)
   function count_rows /* SLAVE_COPY */
   ( p_QBE in number default 0
   , p_other_condition in varchar2 default null
   , p_ni  in varchar2 default null
   , p_id_immagine  in varchar2 default null
   ) return integer;
end anagrafe_immagini_tpk;
/

