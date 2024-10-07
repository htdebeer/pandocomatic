# frozen_string_literal: true

#--
# Copyright 2014—2024, Huub de Beer <Huub@heerdebeer.org>
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
  require_relative '../processor'

  # FileInfoPreprocessor collects information about a file to be converted and
  # mixes that information into that file's metadata. It is a default
  # preprocessor.
  #
  class FileInfoPreprocessor < Processor
    # rubocop:disable Metrics/AbcSize

    # Run this FileInfoPreprocessor
    #
    # @param input [String] the contents of the document being preprocessed
    # @param path [String] the path to the input document
    # @param options [Hash] pandoc options collected by pandocomatic to run on
    #   this file
    def self.run(input, path, src_path, options)
      created_at = File.stat(path).ctime
      modified_at = File.stat(path).mtime

      file_info = "\npandocomatic-fileinfo:\n"
      file_info += "  from: #{options['from']}\n" if options.key? 'from'
      file_info += "  to: #{options['to']}\n" if options.key? 'to'
      file_info += "  template: #{options['template']}\n" if options.key? 'template'
      file_info += "  path: '#{path}'\n"
      file_info += "  src_path: '#{src_path}'\n"
      file_info += "  created: #{created_at.strftime '%Y-%m-%d'}\n"
      file_info += "  modified: #{modified_at.strftime '%Y-%m-%d'}"

      Pandocomatic::LOG.debug '     | FileInfoPreprocessor. Adding file information to metadata:' \
        "#{Pandocomatic::LOG.indent(
          file_info, 37
        )}"

      "#{input}\n\n---#{file_info}\n...\n\n"
    end

    # rubocop:enable Metrics/AbcSize
  end
end
