package it.finmatica.test.pages

import geb.Module

class LoginModule extends Module {
    static content = {
        loginForm { $("form") }
        loginButton { $("input[type=submit]") }
    }

    void login(String username = "DDMNLP71M28E372K", String password = "lavoro17") {
        loginForm.j_username = username
        loginForm.j_password = password
        loginButton.click()
    }
}