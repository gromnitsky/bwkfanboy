# This file is loaded by the application at start-up.

# Disable useless rack logger completely! Yay, yay!
module Rack
  class CommonLogger
    def call(env)
      # do nothing
      @app.call(env)
    end
  end
end

module Bwkfanboy
  module MySinatraConfig
    
    def self.read o
      o.configure do
        # heroku logs
        $stdout.sync = true
      end
  
      o.configure :production, :development do
      end
  
      o.configure :development do
      end
  
      o.configure :production do
        o.set :haml, ugly: true
      end
    end
    
  end
end
