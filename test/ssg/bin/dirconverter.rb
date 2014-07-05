

def convert inputdir, outputdir_parent
  dirconverter = analyse inputdir
  outputdir = mirror inputdir, outputdir_parent
  dirconverter env, inputdir, outputdir

  # convert converter, env, input, output
  # So, for a dir or file, we run the specified converter, in an environment
  # on that dir/file and create some result (or not) in the output mirrored
  # directory.
  #
  #
end

class Converter

end

class DirConverter < Converter

  # mirror dir: given a dir in the input tree, create a dir in the output tree
  # and something with the contents of the directory, recursively
end

class FileConverter < Converter
end

class CopyFile < FileConverter
end

class SkipFile < FileConverter
end

class Pandoc < FileConverter
end





def skip 
  puts "skipping this file"
end

def markdown2html file
  puts "converting markdown to html, this #{file}"
end

def copy file
  puts "copying file #{file}"
end

dir = ARGV[0]

# mapping file_spec / regexp and a function/proc

Dir.foreach(dir) do |file|
  if File.directory? file then
    # process directory, look in .pandocomatic file what dir-converter to use,
    # if none specified, use the current one.

  elsif File.symlink? file then
    # process symling

  elsif File.file? file then
    # Match files and use file converters


  else
    # odd

  end
  
  case file
  when /^\..*/
    skip
  when /.*\.markdown/
    markdown2html file
  else
    copy file
  end
end
