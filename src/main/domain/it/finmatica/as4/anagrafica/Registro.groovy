package it.finmatica.as4.anagrafica

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.Id
import javax.persistence.Table

@Table(name = "registro")
@Entity
class Registro implements Serializable {

    @Column(name = "chiave")
    @Id
    private String chiave
    @Column(name = "stringa")
    @Id
    private String stringa
    @Column(name = "commento")
    private String commento
    @Column(name = "valore")
    private String valore


}
