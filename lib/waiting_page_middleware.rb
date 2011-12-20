class WaitingPageMiddleware
  def initialize(app)
    @app = app
  end
 
  def call(env)
    if env['SERVER_NAME'] == env_server_name
      if env['REQUEST_URI'] == "/"
        env['PATH_INFO'] = "/wp"
        env['REQUEST_PATH'] = "/wp"
        env['REQUEST_URI'] = "/wp"        
      else
        return [200, {"Content-Type" => "text/html"}, [File.read("#{File.dirname(__FILE__)}/../public/404.html")]]
      end      
    end
    @app.call(env)    
  end
  
  def env_server_name
    Rails.env == 'development' ? 'cheeve.it.local' : 'cheeve.it'
  end
    
end