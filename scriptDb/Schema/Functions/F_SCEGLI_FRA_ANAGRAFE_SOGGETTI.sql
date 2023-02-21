CREATE OR REPLACE FUNCTION F_SCEGLI_FRA_ANAGRAFE_SOGGETTI (
    p_codice_fiscale   IN anagrafe_soggetti.codice_fiscale%TYPE,
    p_competenza       IN anagrafe_soggetti.competenza%TYPE DEFAULT '%')
    RETURN NUMBER
IS
BEGIN
    RETURN anagrafe_soggetti_pkg.SCEGLI_FRA_ANAGRAFE_SOGGETTI (
               p_codice_fiscale,
               p_competenza);
END;
/

