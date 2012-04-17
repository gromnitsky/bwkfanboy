require_relative 'helper'

require_relative '../lib/bwkfanboy/home'

class TestHome < MiniTest::Unit::TestCase
  def setup
    # this runs every time before test_*
    @cmd = cmd('bwkfanboy') # get path to the exe & cd to tests directory

    rm_rf 'example/01'
  end

  def test_home
    h = Home.new 'example/01'
    assert_equal 'example/01/log', h.logs.to_s
    assert_equal 'example/01/plugins', h.plugins.to_s
    assert File.readable?(h.root)
    assert File.readable?(h.plugins)
    assert File.readable?(h.logs)
  end
end
