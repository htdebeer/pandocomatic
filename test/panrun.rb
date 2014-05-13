


class Pandoc



  def initialize &block 
    @options = {
      :from => :markdown,
      :to => :html5,
      :standalone => false
    }
    instance_eval(&block) if block_given?
  end

  def from format = :markdown
    @options[:from] = format
  end

  def to format = :html5
    @options[:to] = format
  end

  def standalone
    @options[:standalone] = true
  end

  def to_command
    command = "pandoc"
    @options.each do |option, value|
      if value then
        command += " --#{option} #{value}"
      end
    end
    return command
  end

  def execute input
    output = 'test'
    command = to_command
    puts command
    IO.popen(command, 'r+') do |p|
      p << input
      p.close_write
      output << p.read
    end
    return output
  end

end

p = Pandoc.new do |c|
  c.from :tex
  c.to :markdown
  c.standalone
end

puts p.to_command

q = Pandoc.new
puts q.to_command

r = Pandoc.new do
  from :html
  to :tex
end
puts r.to_command

puts q.execute "**sdfsdf**"
