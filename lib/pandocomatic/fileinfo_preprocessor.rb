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

  # FileInfoPreprocessor collects information about a file to be converted and
  # mixes that information into that file's metadata. It is a default
  # preprocessor.
  class FileInfoPreprocessor < Processor
    def self.run input, path
      created_at = File.stat(path).ctime
      modified_at = File.stat(path).mtime
      output = input
      output << "\n\n---\n"
      output << "fileinfo:\n"
      output << "  path: '#{path}'\n"
      output << "  created: #{created_at.strftime '%Y-%m-%d'}\n"
      output << "  modified: #{modified_at.strftime '%Y-%m-%d'}\n"
      output << "...\n\n"
    end
  end
end
