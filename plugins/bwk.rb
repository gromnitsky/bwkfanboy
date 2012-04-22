@uri << 'http://www.dailyprincetonian.com/advanced_search/?author=Brian+Kernighan'
@copyright = "See bwkfanboy's LICENSE file"
@title = "Brian Kernighan's articles from Daily Princetonian"
@content_type = 'html'
@version = 2

# [streams]  an array of IO streamss
def parse streams
  streams.each do |io|
    baseurl = "http://www.dailyprincetonian.com"

    doc = Nokogiri::HTML io, nil, enc
    doc.xpath("//div[@class='article_item']").each do |idx|
      t = idx.xpath("h2/a").children.text
      link = idx.xpath("h2/a")[0].attributes['href'].value
      l = baseurl + link + "print"
      u = BH.date idx.xpath("h2").children[1].text
      a = idx.xpath("div/span/a[1]").children.text
      c = idx.xpath("div[@class='summary']").text
    
      self << { 'title' => t, 'link' => l, 'updated' => u,
        'author' => a, 'content' => c }
    end
  end
end
