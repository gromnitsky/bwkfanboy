require 'pathname'
require 'fileutils'

require_relative 'cliconfig'

module Bwkfanboy
  class Home
    # Home root directory
    ROOT = Pathname.new "~/.#{Meta::NAME.downcase}"
    PLUGINS = 'plugins'
    LOGS = 'log'

    SYSTEM_PLUGINS = CliUtils::DIR_LIB_SRC.parent.parent + 'plugins'

    attr_reader :root, :logs
    attr_accessor :conf
    
    # Load config & create all required directories.
    def initialize dir = nil # yield loader, o
      @root = Pathname(dir) || ROOT
      @logs = @root + LOGS
      
      CliConfig::DIR_CONFIG.unshift @root
      @conf = CliConfig.new
      @conf[:plugins_path] = [@root + PLUGINS, SYSTEM_PLUGINS]
      @conf.load do |o|
        yield self, o if block_given?
        o.on('-I DIR', 'Include DIR in search for plugins') {|i|
          @conf[:plugins_path] << Pathname.new(i) if File.directory?(i)
        }
      end
      
      FileUtils.mkdir_p [@conf[:plugins_path], @logs]
    end

  end
end
