#encoding: utf-8
require 'erb'

class Document

  attr_reader :title, :content
  attr_accessor :subtitle, :date

  def initialize(title)
    @title = title
    @content = ''
  end

  def render(template, content)
    @content = content
    return ERB.new(template).result binding
  end
end



d = Document.new 'A new Title'
d.subtitle = 'with this very interesting subtitle'
template = File.read 'templates/main.erb'
content = File.read 'testcontent.html'
puts d.render template, content

