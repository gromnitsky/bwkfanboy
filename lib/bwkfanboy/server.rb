require_relative 'home'

module Bwkfanboy
  class Server
    PIDFILE = 'server.pid'

    def initialize home
      @home = home
      @pidfile = @home.root + PIDFILE

      pidfileMake
      pidfileLock
    end

    attr_reader :pidfile
    attr_reader :lock

    # Return true on success, false on error.
    def pidfileLock
      @lock = true if File.new(@pidfile).flock(File::LOCK_EX|File::LOCK_NB)
      @lock = false
    end
    
    
    private
    
    def pidfileMake
      File.open(@pidfile, File::CREAT|File::TRUNC|File::WRONLY) {|fd|
        fd.write Process.pid
      }
    rescue
      CliUtils.errx 1, "pidfile problem: #{$!}"
    end

  end
end
