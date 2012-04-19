require 'stringio'

require_relative 'helper'
require_relative '../lib/bwkfanboy/plugin'
require_relative '../lib/bwkfanboy/generator'

class TestGenerate < MiniTest::Unit::TestCase
  def setup
    # this runs every time before test_*
    @cmd = cmd('bwkfanboy') # get path to the exe & cd to tests directory

    ENV['BWKFANBOY_CONF'] = ''
    @h = Home.new('example/02')
  end

  def test_atom
    stream = [StringIO.new(File.read(@h.root + Home::PLUGINS + 'bwk.html'))]
    p = Plugin.new @h.conf[:plugins_path], 'bwk', {}
    p.run_parser stream

    raw = StringIO.new ''
    p.pack raw
    raw.rewind

    data = Generator.unpack raw
#    pp data
    r = Generator.atom data
#    pp r
    doc = Nokogiri::HTML r.to_s
    assert_equal("Brian Kernighan's articles from Daily Princetonian",
                 doc.xpath('//feed/title').text)
  end

  def test_atom_fail
    e = assert_raises(GeneratorException) { Generator.atom nil }
    assert_match /input is nil/, e.message

    e = assert_raises(GeneratorException) { Generator.atom [1,2] }
    assert_match /can\'t convert String into Integer/, e.message
  end

  def test_unpack
    refute Generator.unpack(nil)

    raw = StringIO.new ''
    refute Generator.unpack(raw)

    raw = StringIO.new MessagePack.pack([1,2,3])
    assert_equal [1,2,3], Generator.unpack(raw)
  end
end
