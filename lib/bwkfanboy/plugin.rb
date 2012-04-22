require 'msgpack'
require 'nokogiri'

module Bwkfanboy

  # Helpers for plugin authors.
  module BH
    extend self

    # FIXME: clean unsafe html for 'html' content_type
    def clean t
      return '' unless t
      t.gsub(/\s+/, ' ').strip
    end

    # Tries to parse _s_ string as a date.
    # Return the result in ISO 8601 format.
    def date(t)
      DateTime.parse(BH.clean(t)).iso8601
    rescue
      DateTime.now.iso8601
    end

    # See test_plugin.rb
    def all_set? t
      return false unless t
      
      if t.is_a?(Array)
        return false if t.size == 0
        
        t.each {|i|
          return false unless i
          return false if i.to_s.strip.size == 0
        }
      end

      return false if t.to_s.strip.size == 0
      true
    end
    
  end

  class PluginException < StandardError
    def initialize msg
      super msg
    end

    alias :orig_to_s :to_s
    # looks clumsy
    def to_s
      "plugin: #{orig_to_s}"
    end
  end

  class PluginInvalidName < PluginException
  end

  class PluginNotFound < PluginException
  end

  class PluginNoOptions < PluginException
  end
  
  # Requires defined 'parse(streams)' method in plugin.
  #
  # Raises only PluginException on purpose.
  class Plugin
    include Enumerable

    MAX_ENTRIES = 128
    NAME_RE = /^[a-zA-Z0-9-]+$/

    # [path]    an array
    # [name]    plugin's name (without .rb extension)
    # [opt]     an array
    # [&block]  you can examine the Plugin object there
    def initialize path, name, opt, &block
      @path = path
      raise PluginInvalidName, "name doesn't match #{NAME_RE}" unless validName?(name)
      @name = name
      @origin = nil # a path where plugin was found
      @syslib = File.dirname __FILE__

      # Variables for plugin authours
      @opt = (opt && opt.map(&:to_s)) || []
      @uri = []
      @enc = 'UTF-8'
      @version = 1
      @copyright = ''
      @title = ''
      @content_type = ''

      @data = []
      load &block
    end

    attr_accessor :origin
    attr_accessor :uri, :enc, :version, :copyright, :title, :content_type

    def validName? name
      name =~ NAME_RE
    end
    
    def each &b
      @data.each &b
    end

    def << obj
      return @data if full?
      
      ['title', 'link', 'updated', 'author', 'content'].each {|idx|
        obj[idx] &&= BH.clean obj[idx]
        raise PluginException, "empty '#{idx}' in the entry #{obj.inspect}" if obj[idx].size == 0
      }
      
      @data << obj
    end

    def full?
      @data.size >= MAX_ENTRIES
    end
    
    def [] index
      @data[index]
    end

    def size
      @data.size
    end

    def pack stream = ''
      # hopefully, urf8 will survive
      MessagePack.pack export, stream
    end

    def export
      {
        'channel' => {
          'updated' => entryMostRecent,
          'id' => @uri.to_s,
          'author' => @copyright,
          'title' => @title,
          'link' => @uri.first,
          'x_entries_content_type' => @content_type,
        },
        'x_entries' => @data
      }
    end

    # We can do this while adding a new entry, not here
    def entryMostRecent
      return nil if @data.size == 0
      
      max = DateTime.parse @data.sample['updated']
      @data.each {|idx|
        cur = DateTime.parse idx['updated']
        max = cur if max < cur
      }

      return max.iso8601
    end
    
    def load
      raise PluginException, 'invalid search path' unless @path && @path.respond_to?(:each)
      
      p = nil
      @path.each {|idx|
        contents = Dir.glob "#{idx}/*.rb"
        pos = contents.index "#{idx}/#{@name}.rb"
        if pos && p = contents[pos]
          @origin = idx
          break
        end
      }

      raise PluginNotFound, "'#{@name}' not found" unless p
      
      begin
        instance_eval File.read(p)
      rescue Exception
        raise PluginException, "'#{@name}' failed to parse: #{$!}"
      end

      unless BH.all_set?(uri)
        raise PluginException, 'uri must be an array of strings' if @opt.size != 0
        raise PluginNoOptions, 'don\'t we forget about additional options?'
      end
      raise PluginException, 'enc is unset' unless BH.all_set?(enc)
      raise PluginException, 'version must be an integer' unless BH.all_set?(version)
      raise PluginException, 'copyright is unset' unless BH.all_set?(copyright)
      raise PluginException, 'title is unset' unless BH.all_set?(title)
      raise PluginException, 'content_type is unset' unless BH.all_set?(content_type)

      # use this, for example, to print a message to user that loading
      # was fine
      yield self if block_given?
    end

    # Runs loaded plugin's parser
    def run_parser streams
      ok = streams ? true : false
      streams.each {|i| ok = false unless i.respond_to?(:eof) } if streams
      raise PluginException, 'parser expects a valid array of IO objects' unless ok

      begin
        parse streams
      rescue Exception
        raise PluginException, "'#{@name}' failed to parse: #{$!}"
      end

      check
    end
      
    def check
      raise PluginException, "it ain't grab anything" if @data.size == 0
    end

  end

  module PluginInfo
    extend self
    
    def about path, name, opt
      p = Plugin.new path, name, opt
      r = {}
      ['title', 'version', 'copyright', 'uri'].each {|idx|
        r[idx] = p.send(idx)
      }
      r
    end

    def getList path
      r = []
      path.each {|idx|
        dir = idx.to_s
        e = { dir => [] }
        Dir.glob("#{dir}/*.rb").each {|file|
          e[dir] << File.basename(file, '.rb')
        }
        r << e
      }

      r
    end
    
  end
end
