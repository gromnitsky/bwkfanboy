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
      @root = (dir && Pathname(dir)) || ROOT
      @logs = @root + LOGS
      
      CliConfig::DIR_CONFIG.unshift @root
      @conf = CliConfig.new
      @conf[:plugins_path] = [@root + PLUGINS, SYSTEM_PLUGINS]
      @conf.load do |o|
        yield self, o if block_given?
        o.on('-I DIR', 'Include DIR in search for plugins.') {|i|
          @conf[:plugins_path] << Pathname.new(i) if File.directory?(i)
        }
        o.on('--plugins-path', 'Print all searchable directories.') {
          print_plugins_path
          exit EX_OK
        }
      end
      
      print_env
      FileUtils.mkdir_p [@conf[:plugins_path], @logs]
    end

    def print_plugins_path
      @conf[:plugins_path].each {|i| puts i }
    end

    def print_env
      if @conf[:verbose] >= 2
        puts "Libs dir: #{CliUtils::DIR_LIB_SRC}"
        pp @conf
      end
    end

  end
end
