require 'nokogiri'

uri << 'http://www.dailyprincetonian.com/advanced_search/?author=Brian+Kernighan'
copyright = "See bwkfanboy's LICENSE file"
title = "Brian Kernighan's articles from Daily Princetonian"
content_type = 'html'

# [stream]  an array of IO streams
def parse stream
  stream.each do |io|
    myurl = "http://www.dailyprincetonian.com"

    doc = Nokogiri::HTML io, nil, enc
    doc.xpath("//div[@class='article_item']").each do |idx|
      t = idx.xpath("h2/a").children.text
      link = idx.xpath("h2/a")[0].attributes['href'].value
      l = myurl + link + "print"
      u = BH.date idx.xpath("h2").children[1].text
      a = idx.xpath("div/span/a[1]").children.text
      c = idx.xpath("div[@class='summary']").text
    
      self << { title: t, link: l, updated: u, author: a, content: c }
    end
  end
end
