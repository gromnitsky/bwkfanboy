require 'msgpack'
require_relative 'helper'

class TestCLI < MiniTest::Unit::TestCase
  def setup
    # this runs every time before test_*
    @cmd = cmd('bwkfanboy') # get path to the exe & cd to tests directory
    
    @bwkfanboy_parse = File.dirname(@cmd) + '/bwkfanboy_parse'
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
end
