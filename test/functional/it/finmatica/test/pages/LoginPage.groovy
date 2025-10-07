package it.finmatica.test.pages

import geb.Page

class LoginPage extends Page {
    static at =  { $("form#loginForm") }

    static content = {
        loginModule { module LoginModule }
    }
}
