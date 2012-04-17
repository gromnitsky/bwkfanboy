require_relative 'helper'

require_relative '../lib/bwkfanboy/server'

class TestServer < MiniTest::Unit::TestCase
  def setup
    # this runs every time before test_*
    @cmd = cmd('bwkfanboy') # get path to the exe & cd to tests directory

    rm_rf 'example/01'
    @s = Server.new Home.new('example/01')
  end

  def test_locking
    assert_match /^\d+$/, File.read(@s.pidfile)
    # file must be locked at this point
    refute @s.lock
    3.times { refute @s.pidfileLock }
  end
  
end
