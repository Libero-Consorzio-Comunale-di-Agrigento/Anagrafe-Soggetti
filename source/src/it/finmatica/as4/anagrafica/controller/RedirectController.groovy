package it.finmatica.as4.anagrafica.controller

import groovy.transform.CompileStatic;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@CrossOrigin
@CompileStatic
@RestController
@RequestMapping("/")
class RedirectController {

    @GetMapping(value = "")
    void redirect(HttpSession session, HttpServletResponse httpServletResponse,
                       @RequestParam(value = "progettoChiamante", required = false) String progetto,
                       @RequestParam(value = "soggetto", required = false) String soggetto,
                       @RequestParam(value = "data", required = false) String data,
                       @RequestParam(value = "competenzaEsclusiva", required = false) String competenzaEsclusiva,
                       @RequestParam(value = "tipo", required = false) String tipo,
                       @RequestParam(value = "visualizzaChiudi", required = false) String visualizzaChiudi) {
        session.setAttribute("progetto", progetto)
        session.setAttribute("soggetto", soggetto)
        session.setAttribute("data", data)
        session.setAttribute("competenzaEsclusiva", competenzaEsclusiva)
        session.setAttribute("tipo", tipo)
        session.setAttribute("visualizzaChiudi", visualizzaChiudi)

        if (soggetto != null || (tipo != null && tipo.equals("inserimento"))){
            httpServletResponse.setHeader("Location", "/Anagrafica/as4/anagrafica/dettaglio.zul")
        } else {
            httpServletResponse.setHeader("Location", "/Anagrafica/index.zul")
        }
        httpServletResponse.setStatus(302);
    }
}