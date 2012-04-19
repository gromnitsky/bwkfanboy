require 'erb'
require 'digest/md5'
require 'etc'

require_relative 'cliutils'
require_relative 'fetch'
require_relative 'plugin'
require_relative 'generator'

module Bwkfanboy
  module Utils
    extend self

    # [template]     a full path to a .erb file
    # [desiredName]  a future skeleton name
    def skeletonCreate template, desiredName
      t = ERB.new File.read template
      t.filename = template # to report errors relative to this file
      begin
        md5_system = Digest::MD5.hexdigest t.result(binding)
      rescue Exception
        CliUtils.errx EX_SOFTWARE, "cannot read the template: #{$!}"
      end

      if ! File.exists?(desiredName)
        # create a new skeleton
        begin
          File.open(desiredName, 'w+') { |fp| fp.puts t.result(binding) }
        rescue
          CliUtils.errx EX_IOERR, "cannot write the skeleton: #{$!}"
        end
      else
        # warn a careless user
        if md5_system != Digest::MD5.file(desiredName).hexdigest
          CliUtils.warnx "#{desiredName} already exists"
          return false
        end
      end

      true
    end

    # Do all the work of reading the plugin, parsing and generating the
    # atom feed.
    def atom pluginsPath, name, opt
      p = Plugin.new pluginsPath, name, opt
      streams = Fetch.openStreams p.uri
      p.run_parser(streams)
    
      puts Generator.atom p.export
      
      Fetch.closeStreams streams
    end
    
  end
end
