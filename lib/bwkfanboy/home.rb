require 'pathname'
require 'fileutils'

module Bwkfanboy
  class Home
    # Home root directory
    ROOT = Pathname.new "~/.#{Meta::NAME.downcase}"
    PLUGINS = 'plugins'
    LOGS = 'log'

    attr_reader :root, :plugins, :logs
    
    # Create all required directories
    def initialize dir = nil
      @root = Pathname(dir) || ROOT
      @plugins = @root + PLUGINS
      @logs = @root + LOGS
      
      FileUtils.mkdir_p [@plugins, @logs]
    end
  end
end
