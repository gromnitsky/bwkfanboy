# :erb: ruby-cli
# Various staff for minitest. Include this file into your 'helper.rb'.

require 'fileutils'
include FileUtils

require_relative '../lib/bwkfanboy/cliutils'
include Bwkfanboy

require 'minitest/autorun'

# Return an absolute path of a _c_.
def cmd(c)
  case File.basename(Dir.pwd)
  when Meta::NAME.downcase
    # test probably is executed from the Rakefile
    Dir.chdir('test')
    $stderr.puts('*** chdir to ' + Dir.pwd)
  when 'test'
    # we are in the test directory, there is nothing special to do
  else
    # tests were invoked by 'gem check -t bwkfanboy'
    # (for a classic rubygems 1.3.7)
    begin
      Dir.chdir(CliUtils::DIR_LIB_SRC.parent.parent + test)
    rescue
      raise "running tests from '#{Dir.pwd}' isn't supported: #{$!}"
    end
  end

  File.absolute_path('../bin/' + c)
end

# Don't remove this: falsework/2.0.0/ruby-cli/2012-03-05T05:04:11+02:00
