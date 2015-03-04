require '../lib/pandoc/pandoc.rb'

p = Pandoc::Pandoc.new do |c|
  c.flag :sdfdsf
end
p.configure do |q|
  q.flag :meh
  q.output 'thid'
end

puts p.config

