package anagrafica

class AccessoController {

    def index() {
		String url
		String progetto = params.progettoChiamante
		String soggetto = params.soggetto
		String data = params.data
		String competenzaEsclusiva = params.competenzaEsclusiva
		String tipo = params.tipo
		String visualizzaChiudi = params.visualizzaChiudi
		
		if(soggetto != null || tipo.equals('inserimento'))
			url = "/Anagrafica/as4/anagrafica/dettaglio.zul"
		else
			url = "/Anagrafica/index.zul"
			
		session.setAttribute("progetto", progetto)
		session.setAttribute("soggetto", soggetto)
		session.setAttribute("data", data)
		session.setAttribute("competenzaEsclusiva", competenzaEsclusiva)
		session.setAttribute("tipo", tipo)
		session.setAttribute("visualizzaChiudi", visualizzaChiudi)
		
		render (view:"index", model: [url:url])
	}
}
