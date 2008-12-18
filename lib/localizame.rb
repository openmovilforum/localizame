class Localizame
  
  def initialize(login = nil, password = nil)
    loc_settings ||= YAML.load_file(RAILS_ROOT + '/config/localizame.yml') rescue {}
    @login = login.nil? ? loc_settings['login'] : login.to_s
    @password = password.nil? ? loc_settings['password'] : password.to_s
    
    # configuración
    @cookie = ""
    @url_base = "www.localizame.movistar.es"
    @url_login = "/login.do"
    @url_logout = "/logout.do"
    @url_new = "/nuevousuario.do"
    @url_autorize = "/insertalocalizador.do"
    @url_unautorize = "/borralocalizador.do"
    @url_localize = "/buscar.do"
    @http = Net::HTTP.new(@url_base)

    # conseguimos la cookie
    data = "usuario=#{@login}&clave=#{@password}" 
    headers = {
      'User-Agent'    => 'Mozilla/4.0',
      'Content-Type'  => 'application/x-www-form-urlencoded',
      'Connection'    => 'Keep-Alive'
    }
    resp, data = @http.post(@url_login, data, headers)
    checkresp(resp)
    cookie = resp.response['set-cookie']
    @cookie = cookie.sub("path=/"," ").rstrip
    
    # verificamos 
    headers = {
      'Cookie'          => @cookie,
      'Accept-Encoding' => 'identity',
      'Referer'         => "http://#{@url_base}#{@url_login}",
      'User-Agent'      => 'Mozilla/4.0',
      'Content-Type'    => 'application/x-www-form-urlencoded',
      'Connection'      => 'Keep-Alive'
    }
    
    resp, data = @http.get(@url_new, headers)
    checkresp(resp)
    
  end
  
  def locate(mobile)

    data = "telefono=#{mobile}" 
    headers = {
      'Cookie'          => @cookie,
      'Accept-Encoding' => 'identity',
      'Referer'         => "http://www.localizame.movistar.es/buscalocalizadorespermisos.do",
      'User-Agent'      => 'Mozilla/4.0',
      'Content-Type'    => 'application/x-www-form-urlencoded',
      'Connection'      => 'Keep-Alive'
    }
    resp, data = @http.post(@url_localize, data, headers)
    checkresp(resp)

    # buscamos el mapa
    doc = Hpricot(resp.response.body)
    mapfield = doc.search("//input[@name='mapa']")
    mapvalues = URI.parse(mapfield.first.attributes['value']).query
    maposition = {}
    maposition = getmap(mapvalues) unless mapvalues.nil?
    
    # posición en modo texto
    position = doc.search("//input[@name='punto1']")
    position = position.first.attributes['value']
    maposition.merge({:position => position})
  end
  
  def getmap(data)
    begin
      ur = "clientes.maptel.com"
      mf = "/Unitec/Mapa/Mapa_flash.jsp"
      http = Net::HTTP.new(ur)
      resp = http.post(mf, data)
      lat = resp.body.match('var cYIco = "(.*?)";')[0].split('"')[1]
      long = resp.body.match('var cXIco = "(.*?)";')[0].split('"')[1]
      {:lat => lat, :long => long}
    rescue
      {:lat => nil, :long => nil}
    end
  end
  
  def authorize(mobile)

    data = "telefono=#{mobile}" 
    headers = {
      'Cookie'          => @cookie,
      'Accept-Encoding' => 'identity',
      'User-Agent'      => 'Mozilla/4.0',
      'Content-Type'    => 'application/x-www-form-urlencoded',
      'Connection'      => 'Keep-Alive'
    }
    resp, data = @http.post(@url_autorize, data, headers)
    checkresp(resp)

  end

  def unauthorize(mobile)

    data = "telefono=#{mobile}" 
    headers = {
      'Cookie'          => @cookie,
      'Accept-Encoding' => 'identity',
      'User-Agent'      => 'Mozilla/4.0',
      'Content-Type'    => 'application/x-www-form-urlencoded',
      'Connection'      => 'Keep-Alive'
    }
    resp, data = @http.post(@url_unautorize, data, headers)
    checkresp(resp)

  end

  def logout

    headers = {
      'Cookie'          => @cookie,
      'Accept-Encoding' => 'identity',
      'User-Agent'      => 'Mozilla/4.0',
      'Content-Type'    => 'application/x-www-form-urlencoded',
      'Connection'      => 'Keep-Alive'
    }
    resp, data = @http.post(@url_logout, data, headers)

  end
  
  def checkresp(resp)
    # valida que estamos logados buscando el titular de acceso restringido
    doc = Hpricot(resp.response.body)
    search = doc.search("span[@class='titular']")
    raise "You need to be logged in" unless search.nil? || search.first.nil? || search.first.inner_text.index("Restringido").nil?

  end
  
end
