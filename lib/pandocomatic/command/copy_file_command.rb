#--
# Copyright 2017, Huub de Beer <Huub@heerdebeer.org>
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

  require_relative '../error/io_error.rb'
  require_relative 'command.rb'

  class CopyFileCommand < Command
    attr_reader :src

    def initialize(src, dst)
      super()
      @src = src
      @dst = dst
      @errors.push IOError.new(:file_is_not_readable, nil, @src) unless File.readable? @src
      @errors.push IOError.new(:file_is_not_writable, nil, @dst) unless not File.exist?(@dst) or File.writable?(@dst)
    end

    def run()
      begin
        FileUtils.cp(@src, @dst) if file_modified?(@src, @dst)
      rescue StandardError => e
        raise IOError.new(:unable_to_copy_file, e, [@src, @dst])
      end
    end

    def to_s()
      "Copying #{@src} to #{@dst}"
    end
    
  end
end
