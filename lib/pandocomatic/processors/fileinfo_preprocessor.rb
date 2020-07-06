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

    require_relative '../processor.rb'

    # FileInfoPreprocessor collects information about a file to be converted and
    # mixes that information into that file's metadata. It is a default
    # preprocessor.
    #
    class FileInfoPreprocessor < Processor
        # Run this FileInfoPreprocessor
        #
        # @param input [String] the contents of the document being preprocessed
        # @param path [String] the path to the input document
        # @param options [Hash] pandoc options collected by pandocomatic to run on
        #   this file
        def self.run input, path, src_path, options
            created_at = File.stat(path).ctime
            modified_at = File.stat(path).mtime
            output = input
            output << "\n\n---\n"
            output << "pandocomatic-fileinfo:\n"
            output << "  from: #{options['from']}\n" if options.has_key? 'from'
            output << "  to: #{options['to']}\n" if options.has_key? 'to'
            output << "  template: #{options['template']}\n" if options.has_key? 'template'
            output << "  path: '#{path}'\n"
            output << "  src_path: '#{src_path}'\n"
            output << "  created: #{created_at.strftime '%Y-%m-%d'}\n"
            output << "  modified: #{modified_at.strftime '%Y-%m-%d'}\n"
            output << "...\n\n"
        end
    end
end
