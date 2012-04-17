require_relative 'helper'

require_relative '../lib/bwkfanboy/home'

class TestHome < MiniTest::Unit::TestCase
  def setup
    # this runs every time before test_*
    @cmd = cmd('bwkfanboy') # get path to the exe & cd to tests directory

    rm_rf 'example/01'
    ENV['BWKFANBOY_CONF'] = ''
  end

  def test_home_dirs
    h = Home.new 'example/01'
    assert_equal 'example/01/log', h.logs.to_s
    assert_equal 'example/01/plugins', h.conf[:plugins_path].first.to_s
    assert_equal 2, h.conf[:plugins_path].size
    assert File.readable?(h.root)
    assert File.readable?(h.conf[:plugins_path].first.to_s)
    assert File.readable?(h.logs)
  end
  
  def test_home_opts
    ENV['BWKFANBOY_CONF'] = '-I /tmp -I /bin -I /INVALID-DIR --zzz "later on"'
    h = Home.new('example/01') {|loader, o|
      o.on('--zzz ARG', 'zzz') {|i| loader.conf[:zzz] = i }
    }
    assert_equal(['example/01/plugins', Home::SYSTEM_PLUGINS.to_s, '/tmp', '/bin'],
                 h.conf[:plugins_path].map(&:to_s) )
    assert_equal 'later on', h.conf[:zzz]
  end
end
