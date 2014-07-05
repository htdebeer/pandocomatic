# Mirroring a source directory to a target directory
#

class Mirror
  def initialize source, target
    # Target directory cannot be a (sub)directory of source directory
    abort "Target cannot be equal or a subdirectory of source directory" if is_subdir?(target, source)
    @source = source
    @target = target
  end

  def run
    mirror @source, @target
  end

  private 

  def is_subdir?(a, b)
    a.match b
  end

  def mirror_skip new_source, new_target
    #skip
  end

  def mirror_file source, target
    FileUtils.copy_file source, target
  end

  def mirror_directory source, target
    mirror source, target
  end

  def mirror_link source, target 
    # Potential problem: linking to file/dir that has not been mirrored yet.
    link = File.readlink source
    if is_subdir? link, @source
      subdir = link.sub @source, ''
      target_link = File.join @target, subdir
      if File.symlink? target 
        if File.readlink(target) == target_link
          # skip, link already exists and points to the correct path
          return
        else
          File.delete target
        end
      end
      FileUtils.ln_s target_link, target
    else
      mirror_directory source, target
    end
  end

  def mirror(source, target)

    FileUtils.mkdir_p target unless File.exist? target

    Dir.foreach(source) do |entry|

      new_source = File.join source, entry
      new_target = File.join target, entry

      if entry =~ /^\..*/
        # skip 'hidden' files and directories, including this and parent
        # directories
        mirror_skip new_source, new_target
      elsif File.symlink? new_source
        # Follow link or copy link? If the link links outside the source tree,
        # follow it as if were a directory. Otherwise, copy the link
        mirror_link new_source, new_target
      elsif File.directory? new_source
        mirror_directory new_source, new_target
      elsif File.file? new_source
        mirror_file new_source, new_target
      else
        puts "Other case? #{new_source}"
      end
    end
    
  end
end


