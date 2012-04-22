require 'rack/test'

require_relative 'helper'
require_relative '../lib/bwkfanboy/server'

class TestServer < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    MyApp
  end
  
  def setup
    # this runs every time before test_*
    @cmd = cmd('bwkfanboy') # get path to the exe & cd to tests directory

    ENV['BWKFANBOY_CONF'] = ''
  end

  def test_list
    get '/'
    assert last_response.ok?
    assert_match /Plugins List/, last_response.body
  end

  def test_plugin_test
    get '/test?o=foo&o=bar'
    assert last_response.ok?
    assert_operator 100, :<, last_response.header['Content-Length'].to_i
    assert_equal 'application/atom+xml; charset=UTF-8', last_response.header['Content-Type']
  end

end
