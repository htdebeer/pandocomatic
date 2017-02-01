#--
# Copyright 2014, 2015, 2016, 2017, Huub de Beer <Huub@heerdebeer.org>
# 
# This file is part of pandocomatic.
# 
# Pandocomatic is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
# 
# Pandocomatic is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
# 
# You should have received a copy of the GNU General Public License along
# with pandocomatic.  If not, see <http://www.gnu.org/licenses/>.
#++
module Pandocomatic

  require 'fileutils'

  require_relative 'file_converter.rb'
  require_relative 'converter.rb'

  require_relative 'printer/converter_printer.rb'

  require_relative 'error/io_error.rb'

  class DirConverter < Converter

    def convert(src_dir = @src, dst_dir = @dst, config = @config)
      ensure_directory dst_dir
      config = reconfigure config, src_dir

      ConverterPrinter.new(:cd_dir, src_dir).print unless config.quiet?

      # Convert each file and subdirectory according to the specifications set in config
      Dir.foreach src_dir do |filename|
        src = File.join src_dir, filename

        next if config.skip? src

        raise IOError.new(:file_or_directory_does_not_exist, nil, src) unless File.exist? src

        dst = File.join dst_dir, filename

        if File.symlink? src and not config.follow_links?
          # Symlinks are also recognized as files and directories, so first
          # check if they should be followed (and treated as files and
          # directories), or if they should be recreated (if follow-links
          # setting is false
          ConverterPrinter.new(:recreate_symlink, src, dst).print unless config.quiet?
          recreate_link src, dst
        elsif File.directory? src then
          if config.recursive? then
            # Convert subdirectories only when the recursivity is set in the
            # configuration.
            convert src, dst, config
          else
            ConverterPrinter.new(:skipping_directory, src).print unless config.quiet?
            next # skip directories when not recursive
          end
        elsif File.file? src 
          raise IOError.new(:file_is_not_readable, nil, src) unless File.readable? src
          raise IOError.new(:file_is_not_writable, nil, dst) unless not File.exist? dst or File.writable? dst

          # Check if the source file has to be converted. If so, convert;
          # otherwise, copy it to the destination tree
          if config.convert? src then
            dst = config.set_extension dst
            FileConverter.new(src, dst, config).convert if file_modified? src, dst
          else
            # copy file
            ConverterPrinter.new(:copying_file, src, dst).print unless config.quiet?
            begin
              FileUtils.cp src, dst if file_modified? src, dst
            rescue StandardError => e
              raise IOError.new(:unable_to_copy_file, e, [src, dst])
            end
          end
        else
          # Unclear what to do with this file, skipping it
          ConverterPrinter.new(:unclear_what_to_do, src).print unless config.quiet?
          next        
        end
      end
    end

    private

    # If the source directory contains a configuration file, use it to
    # reconfigure the converter. Otherwise, use the current configuration
    def reconfigure(current_config, src_dir)
      config_file = File.join src_dir, Pandocomatic::CONFIG_FILE
      if File.exist? config_file then
        current_config.reconfigure config_file
      else
        current_config
      end
    end

    # Ensure that dir exist (and is a directory)
    def ensure_directory(dir)
      if Dir.exist? dir
        raise IOError.new(:directory_is_not_readable, nil, dir) unless File.readable? dir
        raise IOError.new(:directory_is_not_a_directory, nil, dir) unless File.directory? dir
      else
        begin
          Dir.mkdir dir
        rescue SystemError => e
          raise IOError.new(:error_creating_directory, e, dir)
        end
      end
    end

    # Recreate source link in destination tree if it points to somewhere inside
    # the source tree using relative paths
    def recreate_link(src, dst)
      begin
        src_target = File.readlink src
      rescue StandardError => e
        raise IOError.new(:unable_to_read_symbolic_link, e, src)
      end

      if src_target.start_with? '.' then
        full_src_target = File.expand_path src_target, File.dirname(src)
        dst_target = src_target
        if full_src_target.start_with? File.absolute_path(@src_root)
          begin
            File.symlink dst_target, dst unless File.exist? dst
          rescue StandardError => e
            raise IOError.new(:unable_to_create_symbolic_link, e, [src, dst])
          end
        else
          warn "Skipping link #{src} because it points to outside the source tree"
        end
      end
    end

    def file_modified?(src, dst)
      # src file is newer than the dstination file?
      not File.exist? dst or File.mtime(src) > File.mtime(dst)
    end

  end

end
