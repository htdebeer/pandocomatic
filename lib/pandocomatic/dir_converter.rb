module Pandocomatic

  require 'fileutils'
  require_relative 'file_converter.rb'

  CONFIG_FILE = 'pandocomatic.yaml'

  class DirConverter

    def initialize src, dst, config
      @src_root = src
      @dst_root = dst
      @config = config
    end

    def convert src_dir = @src_root, dst_dir = @dst_root, config = @config

      ensure_directory dst_dir
      config = reconfigure config, src_dir

      # Convert each file and subdirectory according to the specifications set in config
      Dir.foreach src_dir do |filename|
        src = File.join src_dir, filename
        
        next if config.skip? src

        dst = File.join dst_dir, filename

        if File.directory? src then
            if config.recursive? then
          
              # Convert subdirectories only when the recursivity is set in the
              # configuration.
              convert src, dst, config
            else
              next # skip directories when not recursive
            end
        elsif File.symlink? src and not config.follow_links

          recreate_link src, dst

        elsif File.file? src 

          raise "Cannot read file #{src}" if not File.readable? src
          raise "Cannot write file #{dst}" if File.exist? dst and not File.writable? dst

          # Check if the source file has to be converted. If so, convert;
          # otherwise, copy it to the destination tree
          if config.convert? src then
            dst = config.set_extension dst
            Pandocomatic::FileConverter.new.convert src, dst, config
          else
            # copy file
            FileUtils.cp src, dst
          end

        else
          warn "Unclear what to do with #{src}, skipping this file"
          next        
        end

      end

    end
  
    private
    
    # If the source directory contains a configuration file, use it to
    # reconfigure the converter. Otherwise, use the current configuration
    def reconfigure current_config, src_dir
      config_file = File.join src_dir, CONFIG_FILE
      if File.exist? config_file then
        current_config.reconfigure config_file
      else
        current_config
      end
    end

    # Ensure that dir exist (and is a directory)
    def ensure_directory dir
      if Dir.exist? dir then
        raise "#{dir} is not a directory" if not File.directory? dir
      else
        begin
          Dir.mkdir dir
        rescue SystemCallError => e
          raise "Error trying to create directory #{dir}: #{e.message}"
        end
      end
    end

    # Recreate source link in destination tree if it points to somewhere inside
    # the source tree
    def recreate_link src, dst
      src_target = File.readlink(src)
      full_src_target = File.realpath src_target
      if full_src_target.start_with? @src_root
        dst_target = File.join @dst_root, src_target
        File.symlink dst_target, dst
      else
        warn "Skipping link #{src} because it points to outside the source tree"
      end
    end

  end
    
end
