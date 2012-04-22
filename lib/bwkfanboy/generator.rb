require 'rss/maker'
require 'msgpack'

module Bwkfanboy

  # TODO: generate this class automatically via something like
  # Utils.makeExceptClass 'GeneratorException', prefix: 'generator'
  class GeneratorException < StandardError
    def initialize msg
      super msg
    end

    alias :orig_to_s :to_s
    def to_s
      "generator: #{orig_to_s}"
    end
  end
  
  module Generator
    extend self

    def unpack stream
      p = MessagePack::Unpacker.new stream
      p.each {|i| return i } # p.first or p[0] Messagepack doesn't implement
      return nil
    rescue EOFError
      return nil
    end

    # [data]  a hash; see Plugin#pack for the exact format.
    def atom data
      raise GeneratorException, 'unpacked input is nil' unless data
      
      feed = RSS::Maker.make("atom") { |maker|
        maker.channel.id = data['channel']['id']
        maker.channel.updated = data['channel']['updated']
        maker.channel.author = data['channel']['author']
        maker.channel.title = data['channel']['title']
        
        maker.channel.links.new_link {|i|
          i.href = data['channel']['link']
          i.rel = 'alternate'
          i.type = 'text/html' # eh
        }
        
        maker.items.do_sort = true

        data['x_entries'].each { |i|
          maker.items.new_item do |item|
            item.links.new_link {|k|
              k.href = i['link']
              k.rel = 'alternate'
              k.type = 'text/html' # only to make happy crappy pr2nntp gateway
            }
            item.title = i['title']
            item.author = i['author']
            item.updated = i['updated']
            item.content.type = data['channel']['x_entries_content_type']
      
            case item.content.type
            when 'text'
              item.content.content = i['content']
            when 'html'
              item.content.content = i['content']
            else
              item.content.xhtml = i['content']
            end
          end
        }
      }

      feed
    rescue
      raise GeneratorException, $!.to_s
    end
    
  end
end
