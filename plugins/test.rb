@opt.each { @uri << "#{@syslib}/../../test/example/02/plugins/inc.html" }
@version = 1
@copyright = 'See bwkfanboy\'s LICENSE file'
@title = "Articles (per-user) from inc.com"
@content_type = 'html'

def parse streams
  streams.each_with_index do |io, index|
    profile = @opt[index]
    
    doc = Nokogiri::HTML(io, nil, @enc)
    doc.xpath("//div[@id='articleriver']/div/div").each do |idx|
      t = idx.xpath("h3").text
      l = idx.xpath("h3/a")[0].attributes['href'].value
      
      next if (u = idx.xpath("div[@class='byline']/span")).size == 0
      u = BH.date u.text
      
      a = idx.xpath("div[@class='byline']/a").text
      
      c = idx.xpath("p[@class='summary']")
      c.xpath("a").remove
      c = c.inner_html encoding: @enc
      
      self << { 'title' => t, 'link' => l, 'updated' => u,
        'author' => a, 'content' => c }
    end
  end
end
