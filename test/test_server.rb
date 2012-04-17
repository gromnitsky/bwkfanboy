require_relative 'helper'

require_relative '../lib/bwkfanboy/server'

class TestServer < MiniTest::Unit::TestCase
  def setup
    # this runs every time before test_*
    @cmd = cmd('bwkfanboy') # get path to the exe & cd to tests directory

    ENV['BWKFANBOY_CONF'] = ''
    rm_rf 'example/01'
    @s = Server.new Home.new('example/01')
    @s.mylog.level = Logger::DEBUG
  end

  def test_locking
    assert_match /^\d+$/, File.read(@s.pidfile)
    # file must be locked at this point
    refute @s.lock
    3.times { refute @s.pidfileLock }
  end

  def test_disklog
    assert_equal 'example/01/log/server.log', @s.logfile.to_s

    @s.mylog.debug 'a silly message'
    assert_match /a silly message/, File.read(@s.logfile)

    assert_raises(Errno::ENOENT) {
      Server.new Home.new('example/01'), '/this/does/not/exist/for/sure'
    }
  end
  
end
