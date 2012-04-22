@uri << 'http://www.econlib.org/cgi-bin/searcharticles.pl?sortby=DD&query=ha*'
@version = 1
@copyright = "See bwkfanboy's LICENSE file"
@title = "Latest articles from econlib.org"
@content_type = 'html'
  
def parse streams
  baseurl = 'http://www.econlib.org'
  
  doc = Nokogiri::HTML streams.first, nil, @enc
  doc.xpath("//*[@id='divResults']//tr").each {|idx|
    t = idx.xpath("td[3]//a").text
    next if t == ""
    l = baseurl + idx.xpath("td[3]//a")[0].attributes['href'].value
    u = BH.date idx.xpath("td[4]").children.text
    a = idx.xpath("td[3]/div").children[2].text
    c = idx.xpath("td[4]").children[2].text
    
    self << { 'title' => t, 'link' => l, 'updated' => u,
      'author' => a, 'content' => c }
  }
end
