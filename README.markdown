Localizame
==========

[Localizame](http://www.localizame.movistar.es/) es un servcio de movistar que permite localizar teléfonos móviles. Todas las condiciones del servicio las podrás consultar en la página del propio servicio y de forma un poquito más técnica en [el wiki](http://open.movilforum.com/wiki/index.php/API_Localizacion) que documenta la API del servicio. Recuerde que cada localización conlleva un cargo.

Para poder comenzar a usar esta API hay que enviar el mensaje CLAVE al número 424, que nos proporcionará una sesión válida por media hora.


Uso
---

  1. Instálalo!
    
        script/plugin install git://github.com/openmovilforum/localizame.git
    
  2. Crear el archivo `config/localizame.yml` que contendrá los datos por defecto para hacer login en el servicio. La contraseña se nos proporciona al enviar el mensaje y una vez nos asignan una cada vez que enviamos el mensaje para activar sesión nos dan la misma. 
  
        login: "666666666"
        password: "my_fancy_password_666"

  Esto es totalmente opcional, puedes inicializar cada vez la clase pasándole cada vez un login y un password.
  
  3. Para localizar un número de teléfono es tan sencillo como:

        loc = Localizame.new
        loc.locate("666xxxxxx")

  Si queremos iniciar sesión con un usuario distinto
  
        loc = Localizame.new(login, password)
        loc.locate("666xxxxxx")
  
  4. Autorizar y desautorizar a localizarnos:
  
        loc.authorize("mobile")
        loc.unauthorize("mobile")