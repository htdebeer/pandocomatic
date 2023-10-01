# frozen_string_literal: true

#--
# Copyright 2022 Huub de Beer <Huub@heerdebeer.org>
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
  require 'yaml'

  # Pandocomatic related path functions. Paths in pandocomatic templates have
  # various forms and behaviors. This behavior is defined by methods in this
  # module.
  module Path
    # Indicator for paths that should be treated as "relative to the root
    # path". These paths start with this ROOT_PATH_INDICATOR.
    ROOT_PATH_INDICATOR = '$ROOT$'

    # Update the path to an executable processor or executor given this
    # Configuration
    #
    # @param config [Configuration] the configuration under which to update
    #   the path.
    # @param path [String] path to the executable
    # @param dst [String] the destination path
    # @param check_executable [Boolean = false] Should the executable be
    #   verified to be executable? Defaults to false.
    #
    # @return [String] the updated path.
    def self.update_path(config, path, dst = '', check_executable: false)
      updated_path = path

      if local_path? path
        # refers to a local dir; strip the './' before appending it to
        # the source directory as to prevent /some/path/./to/path
        updated_path = path[2..]
      elsif absolute_path? path
        updated_path = path
      elsif root_relative_path? path
        updated_path = make_path_root_relative path, dst, config.root_path
      else
        updated_path = which path if check_executable

        if updated_path.nil? || !check_executable
          # refers to data-dir
          updated_path = File.join config.data_dir, path
        end
      end

      updated_path
    end

    # Cross-platform way of finding an executable in the $PATH.
    #
    # which('ruby') #=> /usr/bin/ruby
    #
    # Taken from:
    # http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby#5471032
    def self.which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable?(exe) &&
                        !File.directory?(exe)
        end
      end
      nil
    end

    # Is this path a local path in pandocomatic?
    #
    # @param path [String]
    # @return [Boolean]
    def self.local_path?(path)
      if Gem.win_platform?
        path.match('^\\.\\\\.*$')
      else
        path.start_with? './'
      end
    end

    # Is this path an absolute path in pandocomatic?
    #
    # @param path [String]
    # @return [Boolean]
    def self.absolute_path?(path)
      if Gem.win_platform?
        path.match('^[a-zA-Z]:\\\\.*$')
      else
        path.start_with? '/'
      end
    end

    # Is this path a root relative path in pandocomatic?
    #
    # @param path [String]
    # @return [Boolean]
    def self.root_relative_path?(path)
      path.start_with? ROOT_PATH_INDICATOR
    end

    # Determine the root path given a set of command-line options
    #
    # @param options [Hash]
    # @return [String]
    def self.determine_root_path(options)
      if options[:root_path_given]
        options[:root_path]
      elsif options[:output_given]
        File.absolute_path(File.dirname(options[:output]))
      else
        File.absolute_path '.'
      end
    end

    # rubocop:disable Metrics

    # Make a path root relative given the destination path and the root path
    #
    # @param path [String]
    # @param dst [String]
    # @param root [String]
    # @return [String] The root relative path
    def self.make_path_root_relative(path, dst, root)
      # Find how to get to the root directopry from dst directory.
      # Assumption is that dst is a subdirectory of root.
      dst_dir = File.dirname(File.absolute_path(dst))

      path.delete_prefix! ROOT_PATH_INDICATOR if root_relative_path? path

      if File.exist?(root) && File.realpath(dst_dir.to_s).start_with?(File.realpath(root))
        rel_start = ''

        until File.identical?(File.realpath("#{dst_dir}/#{rel_start}"), File.realpath(root))
          # invariant dst_dir/rel_start <= root
          rel_start += '../'
        end

        if rel_start.end_with?('/') && path.start_with?('/')
          "#{rel_start}#{path.delete_prefix('/')}"
        else
          "#{rel_start}#{path}"
        end
      else
        # Because the destination is not in a subdirectory of root, a
        # relative path to that root cannot be created. Instead,
        # the path is assumed to be absolute relative to root
        root = root.delete_suffix '/' if root.end_with? '/'
        path = path.delete_prefix '/' if path.start_with? '/'

        "#{root}/#{path}"
      end
    end

    # rubocop:enable Metrics
  end
end
