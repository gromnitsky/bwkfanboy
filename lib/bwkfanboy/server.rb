require 'logger'
require 'haml'
require 'sinatra/base'
require 'json'

require_relative 'home'
require_relative 'utils'
require_relative '../../etc/sinatra'

module Bwkfanboy
  class MyApp < Sinatra::Base
    MySinatraConfig.read self
    
    set :home, Home.new
    set :public_folder, CliUtils::DIR_LIB_SRC.parent.parent + 'public'
    set :views, CliUtils::DIR_LIB_SRC.parent.parent + 'views'

    use Rack::Deflater

    def getOpts opts
      return [] unless opts
      opts.gsub! /\s+/, ' '
      opts.strip.split ' '
    end
    
    # List all plugins
    get '/' do
      list = PluginInfo.getList settings.home.conf[:plugins_path]
      haml :list, locals: {
        meta: Meta,
        list: list
      }
    end

    get %r{/info/([a-zA-Z0-9_-]+)} do |plugin|
      cache_control :no_cache
      opts = getOpts params['o']
      begin
        PluginInfo.about(settings.home.conf[:plugins_path], plugin, opts).to_json
      rescue PluginInvalidName, PluginNoOptions
        halt 400, $!.to_s
      rescue PluginNotFound
        halt 404, $!.to_s
      rescue PluginException
        halt 500, $!.to_s
      end
    end
    
    get %r{/([a-zA-Z0-9_-]+)} do |plugin|
      begin
        opts = getOpts params['o']
        r = Utils.atom(settings.home.conf[:plugins_path], plugin, opts).to_s

        # Search for <updated> tag and set Last-Modified header
        if (m = r.match('<updated>(.+?)</updated>'))
          headers 'Last-Modified' => DateTime.parse(m.to_s).httpdate
        end
        content_type 'application/atom+xml; charset=UTF-8'
        headers 'Content-Disposition' => "inline; filename=\"#{Meta::NAME}-#{plugin}.xml"

        r
      rescue PluginInvalidName, PluginNoOptions
        halt 400, $!.to_s
      rescue PluginNotFound
        halt 404, $!.to_s
      rescue FetchException, PluginException, GeneratorException
        halt 500, $!.to_s
      end
    end
   
    run! if app_file == $0
  end
end
