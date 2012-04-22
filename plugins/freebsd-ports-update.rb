require 'digest/md5'

@uri << '/usr/ports/UPDATING'
@enc = 'ASCII'
@version = 3
@copyright = "See bwkfanboy's LICENSE file"
@title = "News from FreeBSD ports"
@content_type = 'text'

def my_add ready, t, l, u, a, c
  return true if ! ready
  return false if full?
  
  self << { 'title' => t, 'link' => l, 'updated' => u,
    'author' => a, 'content' => c.rstrip } if ready
  true
end

def my_clean t
  t = t[2..-1] if t[0] != "\t"
  return '' if t == nil
  t
end

def parse streams
  re_u = /^(\d{8}):$/
  re_t1 = /^ {2}AFFECTS:\s+(.+)$/
  re_t2 = /^\s+(.+)$/
  re_a = /^ {2}AUTHORS?:\s+(.+)$/

  ready = false
  mode = nil
  t = l = u = a = c = nil
  while line = streams.first.gets
    line.rstrip!

    if line =~ re_u then
      # add a new entry
      break if ! my_add(ready, t, l, u, a, c)
      ready = true
      u = BH.date($1)
      l = $1                  # partial, see below
      t = a = c = nil
      next
    end

    if ready then
      if line =~ re_t1 then
        mode = 'title'
        t = $1
        c = my_clean($&) + "\n"
        # link should be unique
        l = "file://#{@uri.first}\##{l}-#{Digest::MD5.hexdigest($1)}"
      elsif line =~ re_a
        mode = 'author'
        a = $1
        c += my_clean($&) + "\n"
      elsif line =~ re_t2 && mode == 'title'
        t += ' ' + $1
        c += my_clean($&) + "\n"
      else
        # content
        c += my_clean(line) + "\n"
        mode = nil
      end
    end

    # skipping the preamble
  end

  # add last entry
  my_add(ready, t, l, u, a, c)
end
