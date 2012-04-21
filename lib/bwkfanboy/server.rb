require 'logger'
require 'haml'
require 'sinatra/base'
require 'json'

require_relative 'home'
require_relative 'utils'

module Bwkfanboy
  class MyApp < Sinatra::Base
    set :home, Home.new
    set :public_folder, CliUtils::DIR_LIB_SRC.parent.parent + 'public'
    set :views, CliUtils::DIR_LIB_SRC.parent.parent + 'views'
    
    # List all plugins
    get '/' do
      list = PluginInfo.getList settings.home.conf[:plugins_path]
      haml :list, locals: {
        meta: Meta,
        list: list
      }
    end

    get %r{/info/([a-zA-Z0-9_-]+)} do |plugin|
      begin
        PluginInfo.about(settings.home.conf[:plugins_path], plugin, ['foo', 'bar']).to_json
      rescue PluginException
        halt 500, $!.to_s
      end
    end
    
    get %r{/([a-zA-Z0-9_-]+)} do |plugin|
      begin
        r = Utils.atom(settings.home.conf[:plugins_path], plugin, ['foo']).to_s

        # Search for <updated> tag and set Last-Modified header
        if (m = r.match('<updated>(.+?)</updated>'))
          headers 'Last-Modified' => DateTime.parse(m.to_s).httpdate
        end
        content_type 'application/atom+xml'
        headers 'Content-Disposition' => "inline; filename=\"#{Meta::NAME}-#{plugin}.xml"

        r
      rescue FetchException, PluginException, GeneratorException
        halt 500, $!.to_s
      end
    end
   
    run! if app_file == $0
  end
end
