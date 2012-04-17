require_relative 'home'

module Bwkfanboy

  # Helpers for plugin authors.
  module BH
    extend self

    # FIXME: clean unsafe html for 'html' content_type
    def clean t
      t.gsub(/\s+/, ' ').strip
    end

    # Tries to parse _s_ string as a date.
    # Return the result in ISO 8601 format.
    def date(t)
      DateTime.parse(BH.clean(t)).iso8601
    rescue
      DateTime.now.iso8601
    end

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

  # Requires defined 'parse(stream)' method in plugin.
  class Plugin
    include Enumerable

    MAX_ENTRIES = 256

    # [path]    an array
    # [name]    plugin's name (without .rb extension)
    # [opt]     a hash
    def initialize path, name, opt = {}
      @path = path
      @stream = stream
      @name = name

      # Variables for plugin authours
      @opt = opt
      @uri = []
      @enc = 'UTF-8'
      @version = 1
      @copyright = ''
      @title = ''
      @content_type = ''

      @data = []
      load
    end

    attr_accessor :stream
    attr_accessor :uri, :enc, :version, :copyright, :title, :content_type

    def each(&b)
      @data.each &b
    end

    def << obj
      return @data if @data.size >= MAX_ENTRIES
      
      [:title, :link, :updated, :author, :content].each {|idx|
        obj[idx] &&= BH.clean obj[idx]
        fail "plugin: empty '#{idx}' in the entry #{obj.inspect}" if obj[idx].size == 0
      }
      
      @data << obj
    end

    def [] index
      @data[index]
    end

    def size
      @data.size
    end

    def load
      fail 'plugin: invalid search path' unless @path && @path.respond_to?(:each)
      
      p = nil
      @path.each {|idx|
        contents = Dir.glob "#{idx}/*.rb"
        pos = contents.index "#{idx}/#{@name}.rb"
        break if pos && p = contents[pos]
      }

      fail "plugin: '#{@name}' not found" unless p
      
      begin
        instance_eval File.read(p)
      rescue Exception
        fail "plugin: '#{@name}' failed to parse: #{$!}"
      end

      fail 'plugin: uri must be an array of strings' unless BH.all_set?(uri)
      fail 'plugin: enc is unset' unless BH.all_set?(enc)
      fail 'plugin: version must be an integer' unless BH.all_set?(version)
      fail 'plugin: copyright is unset' unless BH.all_set?(copyright)
      fail 'plugin: title is unset' unless BH.all_set?(title)
      fail 'plugin: content_type is unset' unless BH.all_set?(content_type)
    end

    # Runs loaded plugin's parser
    def run_parser streams
      ok = streams ? true : false
      streams.each {|i| ok = false unless i.respond_to?(:eof) } if streams
      fail 'plugin: parser expects a valid array of IO objects' unless ok

      begin
        parse streams
      rescue Exception
        fail "plugin: '#{@name}' failed to parse: #{$!}"
      end
    end
      
    def check
      fail "plugin: it ain't grab anything" if @data.size == 0
    end

  end
end
