require 'stringio'

require_relative 'helper'
require_relative '../lib/bwkfanboy/plugin'

class TestPlugin < MiniTest::Unit::TestCase
  def setup
    # this runs every time before test_*
    @cmd = cmd('bwkfanboy') # get path to the exe & cd to tests directory

    ENV['BWKFANBOY_CONF'] = ''
    @h = Home.new('example/02')
  end

  def test_allset
    assert_equal false, BH.all_set?([])
    assert_equal false, BH.all_set?(nil)
    assert_equal false, BH.all_set?('')
    assert_equal false, BH.all_set?('    ')
    assert_equal false, BH.all_set?([1,2, ''])
    assert_equal false, BH.all_set?([1,2, nil])
    assert_equal true, BH.all_set?(1)
    assert_equal true, BH.all_set?('1')
  end

  def test_entryMostRecent
    stream = [StringIO.new(File.read(@h.root + Home::PLUGINS + 'bwk.html'))]
    p = Plugin.new @h.conf[:plugins_path], 'bwk', {}
    p.run_parser stream

#    p.each {|i| puts i[:updated]}
    assert_equal '2012-03-12T00:00:00+00:00', p.entryMostRecent

    p[rand(0..3)][:updated] = '2042-03-12T00:00:00+00:00'
    assert_equal '2042-03-12T00:00:00+00:00', p.entryMostRecent
  end
  
  def test_load_ok
    stream = [StringIO.new(File.read(@h.root + Home::PLUGINS + 'bwk.html'))]
    p1 = Plugin.new @h.conf[:plugins_path], 'bwk', {}
    assert(p1)
    p1.run_parser stream

    assert_match /^http:\/\/\S+/, p1[2][:link]
    assert DateTime.parse(p1[2][:updated])
    
    [:title, :author, :content].each {|i|
      assert_operator 0, :<, p1[2][i].size
    }
    
    assert_operator 4, :<=, p1.size
  end

  def test_load_failed
    e = assert_raises(PluginException) { Plugin.new nil, 'BOGUS PLUGIN', {} }
    assert_match /invalid search path/, e.message

    
    e = assert_raises(PluginException) {
      Plugin.new @h.conf[:plugins_path], 'BOGUS PLUGIN', {}
    }
    assert_match /not found/, e.message

    e = assert_raises(PluginException) {
      p = Plugin.new @h.conf[:plugins_path], 'bwk', {}
      p.run_parser nil
    }
    assert_match /parser expects a valid array of IO objects/, e.message

    stream = [StringIO.new("")]
    p = Plugin.new @h.conf[:plugins_path], 'bwk', {}
    assert(p)
    e = assert_raises(PluginException) { p.run_parser stream }
    assert_match /it ain\'t grab anything/, e.message

    stream = [StringIO.new("fffffuuuuuuu")]
    p = Plugin.new @h.conf[:plugins_path], 'bwk', {}
    assert(p)
    e = assert_raises(PluginException) { p.run_parser stream }
    assert_match /it ain\'t grab anything/, e.message
  end

  def test_broken_plugins
    streams = [StringIO.new(File.read(@h.root + Home::PLUGINS + 'bwk.html'))]
    e = assert_raises(PluginException) {
      Plugin.new @h.conf[:plugins_path], 'empty', {}
    }
    assert_match /uri must be an array of strings/, e.message

    e = assert_raises(PluginException) {
      p = Plugin.new @h.conf[:plugins_path], 'garbage', {}
    }
    assert_match /failed to parse/, e.message
  end
end
