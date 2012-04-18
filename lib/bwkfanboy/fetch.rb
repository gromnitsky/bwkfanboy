require 'open-uri'

module Bwkfanboy

  class FetchException < Exception
  end
  
  module Fetch
    extend self
    
    # Return an array of opened streams.
    #
    # [uri]  an array of URIs
    def openStreams uri
      return nil unless uri

      streams = []
      begin
        uri.each {|i| streams << open(i) }
      rescue
        raise FetchException, "streams: #{$!}"
      end
      
      raise FetchException, 'streams: failed to open at least 1' if streams.size == 0
      streams
    end

    def closeStreams streams
      streams.each {|i| i.close }
    rescue 
      # do nothing
    end
  end
end
