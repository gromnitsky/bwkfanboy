require 'logger'
require 'securerandom'

require_relative 'home'

module Bwkfanboy
  class Server
    PIDFILE = 'server.pid'
    LOG = 'server.log'

    def initialize home, logfile = nil
      @home = home
      @pidfile = @home.root + PIDFILE

      pidfileMake
      pidfileLock

      @logfile = logfile || @home.logs + LOG
      if @logfile == $stdout
        $stdout.sync = false
        @mylog = Logger.new $stdout
      else
        @mylog = Logger.new @logfile, 4, 1024*1024
      end
      @mylog.level = Logger::INFO
    end

    attr_reader :pidfile, :lock, :logfile
    attr_accessor :mylog

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
      fail "pidfile creation problem: #{$!}"
    end

  end
end
