
class DirContents


  def initialize path
    @entries = Dir.entries path
  end

  def files
    @entries.find_all do |entry|
      File.file? entry
    end
  end

  def hidden_files
    files.find_all do |file|
      file.match /^\..*/
    end
  end

  def subdirs
    @entries.find_all do |entry|
      File.directory? entry
    end
  end

  def hidden_subdirs
    subdirs.find_all do |subdir|
      subdir.match /^\..*/
    end
  end

  def links
    @entries.find_all do |entry|
      entry.symlink?
    end
  end

  def internal_links
  end

  def external_links
  end

  private

  def subdir_of? a, b
    a.match b
  end


end
