require 'stringio'

require_relative 'helper'
require_relative '../lib/bwkfanboy/plugin'
require_relative '../lib/bwkfanboy/fetch'

class TestFetch < MiniTest::Unit::TestCase
  
  def setup
    # this runs every time before test_*
    @cmd = cmd('bwkfanboy') # get path to the exe & cd to tests directory

    ENV['BWKFANBOY_CONF'] = ''
    @h = Home.new('example/02')
  end

  def test_fetch
    url1 = @h.root + Home::PLUGINS + 'bwk.html'
    
    streams = Fetch.openStreams [url1, url1]
    assert_equal 2, streams.size
    assert streams.sample.is_a?(File)

    # stream in an array is readale
    rs = streams.sample
    assert_operator 500, :<, rs.read.size
    rs.rewind

    # open plugin with 1 stream only
    p0 = Plugin.new @h.conf[:plugins_path], 'bwk', []
    assert p0
    p0.run_parser [streams.sample]

    # open the same plugin with 2 streams
    streams_other = Fetch.openStreams [url1, url1]
    all = Plugin.new @h.conf[:plugins_path], 'bwk', []
    assert all
    all.run_parser streams_other

    assert_operator p0.size, :<, all.size

    Fetch.closeStreams streams
  end

  def test_fetch_fail
    refute Fetch.openStreams(nil)

    e = assert_raises(FetchException) { Fetch.openStreams [] }
    assert_match /failed to open at least 1/, e.message
    
    e = assert_raises(FetchException) { Fetch.openStreams [nil] }
    assert_match /can\'t convert nil into String/, e.message

    e = assert_raises(FetchException) {
      Fetch.openStreams ["/FILE/DOESN'T/EXIST"]
    }
    assert_match /No such file or directory/, e.message
  end
end
