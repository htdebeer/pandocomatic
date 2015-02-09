require 'pathname'
require 'fileutils'

def generate_dir(src, dst, config) 

  destination = ensure_destination dst
  config = reconfigure config, src
  source_tree = Pathname.new src
  source_tree.each_child do |source_child|
    next if skip? source_child
    
    destination_child = destination.join source_child.basename

    if source_child.directory?
      generate_dir source_child, destination_child, config
    else
      if convert? source_child
        convert_file source_child, destination_child, config
      else
        FileUtils.cp source_child, destination_child
      end
    end
  end

end

def skip?(child)
  child.basename.to_s =~ /^\..*$/
end

def convert?(child)
  child.extname.to_s =~ /^(markdown|md)$/
end

def ensure_destination(dst)
  destination = Pathname.new(dst)
  destination.mkdir if not destination.exist?
  raise "Destination problem" if not destination.directory?
  destination
end


def reconfigure(config, src)
  config
end

generate_dir('/home/ht/test/src', '/home/ht/test/www', true)
