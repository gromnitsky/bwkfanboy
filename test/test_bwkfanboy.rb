require_relative 'helper'

class TestBwkfanboy_2902227917 < MiniTest::Unit::TestCase
  def setup
    # this runs every time before test_*
    @cmd = cmd('bwkfanboy') # get path to the exe & cd to tests directory
  end

  def test_foobar
    fail "\u0430\u0439\u043D\u044D\u043D\u044D".encode(Encoding.default_external, 'UTF-8')
  end
end
