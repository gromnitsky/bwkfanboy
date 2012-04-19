require 'msgpack'
require 'fakefs/safe'
require 'digest/md5'

require_relative '../lib/bwkfanboy/utils'
require_relative 'helper'

class TestCLI < MiniTest::Unit::TestCase
  def setup
    # this runs every time before test_*
    @cmd = cmd('bwkfanboy') # get path to the exe & cd to tests directory
    
    @bwkfanboy_parse = File.dirname(@cmd) + '/bwkfanboy_parse'
    @bwkfanboy_generate = File.dirname(@cmd) + '/bwkfanboy_generate'
  end

  def test_bwkfanboy_parse_fail
    r = CliUtils.exec "echo '' | #{@bwkfanboy_parse}"
    assert_equal EX_USAGE, r[0]
    assert_match /bwkfanboy_parse \[options\] plugin/, r[1]

    r = CliUtils.exec "echo '' | #{@bwkfanboy_parse} BUGUS-PLUGIN"
    assert_equal EX_DATAERR, r[0]
    assert_match /'BUGUS-PLUGIN' not found/, r[1]
    
    r = CliUtils.exec "echo '' | #{@bwkfanboy_parse} bwk"
    assert_equal EX_DATAERR, r[0]
    assert_match /it ain\'t grab anything/, r[1]
  end

  def test_bwkfanboy_parse
    r = CliUtils.exec "#{@bwkfanboy_parse} bwk < example/02/plugins/bwk.html"
    assert_equal EX_OK, r[0]

    raw = MessagePack.unpack r[2]
    assert raw
    assert_equal raw['channel']['title'], "Brian Kernighan's articles from Daily Princetonian"
    assert_operator 4, :<=, raw['x_entries'].size
  end

  def test_bwkfanboy_generate_fail
    r = CliUtils.exec "echo '' | #{@bwkfanboy_generate}"
    assert_equal EX_DATAERR, r[0]
  end

  def test_bwkfanboy_fail
    r = CliUtils.exec "#{@cmd}"
    assert_equal EX_USAGE, r[0]

    r = CliUtils.exec "#{@cmd} BOGUS-PLUGIN"
    assert_equal EX_DATAERR, r[0]
    assert_match /not found/, r[1]

    r = CliUtils.exec "#{@cmd} test"
    assert_equal EX_DATAERR, r[0]
    assert_match /forget about additional options/, r[1]
  end

  def test_bwkfanboy
    r = CliUtils.exec "#{@cmd} test foo bar"
    assert_equal EX_OK, r[0]
  end

  def test_skeleton
    skel = File.read '../lib/bwkfanboy/plugin_skeleton.erb'
    FakeFS do
      File.open('skel.erb', 'w+') {|fp| fp.write skel }
      
      Utils.skeletonCreate 'skel.erb', '1'
      m1 = Digest::MD5.file('1').hexdigest
      Utils.skeletonCreate 'skel.erb', '1'
      m2 = Digest::MD5.file('1').hexdigest
      assert_equal m1, m2

      File.open('1', 'w+') {|fp| fp.write 'fffffuuuu' }
      m3 = Digest::MD5.file('1').hexdigest
      out, err = capture_io { Utils.skeletonCreate 'skel.erb', '1' }
      assert_match /1 already exists/, err
      m4 = Digest::MD5.file('1').hexdigest
      assert_equal m3, m4

      refute_equal m1, m4      
    end
  end
  
end
