
require_relative '../lib/pandocomatic/pandoc/pandoc'

p = Pandocomatic::Pandoc::Pandoc.new do |c|
  c.from :latex
  c.to :markdown
  c.standalone
end

puts p.to_command

q = Pandocomatic::Pandoc::Pandoc.new
puts q.to_command

r = Pandocomatic::Pandoc::Pandoc.new do
  from :html
  metadata :author, 'Huub de Beer'
  to 'latex'
  base_header_level 3
  tab_stop 4
  normalize
  columns 78
  metadata :title
  table_of_contents
end
puts r.to_command

puts q << "**sdfsdf**"

u = Pandocomatic::Pandoc::Pandoc.new do
  from :latex
  to :html
end 
g = u << '\chapter{Title of chapter} \n\n Start of first \emph{paragraph}'
puts g
