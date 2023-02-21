CREATE OR REPLACE PACKAGE as4so4_pkg IS /* MASTER_LINK */
/******************************************************************************
 NOME:        anagrafe_soggetti_pkg
 DESCRIZIONE: Gestione tabella anagrafe_soggetti.
 ANNOTAZIONI: .
 REVISIONI:   Template Revision: 1.1.
 <CODE>
 Rev.  Data       Autore  Descrizione.
 00    07/06/2018  VDAVALLI  Prima emissione.
 01    20/02/2019 SNegroni Procedure per gestione debug
 02    27/03/2019 SNegroni recupera_note_con_codice_amm x recupero note da validita precedente
 03    15/03/2022 MMonari  #54239
 04    26/01/2023 MMonari  #60726
 </CODE>
******************************************************************************/
   -- Revisione del Package
   s_revisione constant afc.t_revision := 'V1.04';
   s_trasco_on          number := 0;
   --#60726
   s_utente_aggiornamento contatti.utente_aggiornamento%type := null;
   s_competenza_ipa       anagrafici.competenza%type := '';
   -- Versione e revisione
   function versione /* SLAVE_COPY */
    return varchar2;

    procedure set_trasco_on;
    procedure set_trasco_off;

   procedure allinea_indirizzo_telematico
   (
      p_ni_as4           in anagrafici.ni%type
     ,p_id_tipo_contatto in contatti.id_tipo_contatto%type
     ,p_indirizzo        in contatti.valore%type
     ,p_old_indirizzo    in contatti.valore%type
     ,p_utente_agg       in contatti.utente_aggiornamento%type
   );

   function set_soggetto_uo
   (
      p_dal                       in date
     ,p_old_dal                   in date
     ,p_descrizione               in varchar2
     ,p_indirizzo                 in varchar2
     ,p_provincia                 in number
     ,p_comune                    in number
     ,p_cap                       in varchar2
     ,p_telefono                  in varchar2
     ,p_fax                       in varchar2
     ,p_progr_unita_organizzativa in number --#54239
     ,p_ni_as4                    in anagrafici.ni%type
     ,p_utente_agg                in anagrafici.utente%type
   ) return anagrafici.ni%type;

   function set_soggetto_aoo
   (
      p_dal         in date
     ,p_old_dal     in date
     ,p_descrizione in varchar2
     ,p_indirizzo   in varchar2
     ,p_provincia   in number
     ,p_comune      in number
     ,p_cap         in varchar2
     ,p_telefono    in varchar2
     ,p_fax         in varchar2
     ,p_ni_as4      in anagrafici.ni%type
     ,p_progr_aoo   in number--#60726
     ,p_utente_agg  in anagrafici.utente%type
   ) return anagrafici.ni%type;

   procedure set_denominazione_ricerca
   (
      p_ni                    anagrafici.ni%type
     ,p_dal                   anagrafici.dal%type
     ,p_denominazione_ricerca anagrafici.denominazione_ricerca%type
   );
   function get_denominazione_amm(p_codice_ipa in varchar2) return varchar2;

   procedure allinea_amm
   (
      p_ni_as4     in anagrafici.ni%type
     ,p_codice_amm in varchar2
   );

   procedure recupera_note_con_codice_amm
   (
      p_ni  anagrafici.ni%type
     ,p_dal anagrafici.dal%type
   );

   procedure set_competenza_ipa --#60726
   (
      p_utente_aggiornamento in out anagrafici.utente%type
     ,p_competenza           in out anagrafici.competenza%type
   );

end as4so4_pkg;
/

