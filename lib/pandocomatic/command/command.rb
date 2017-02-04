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

  class Command

    attr_reader :errors, :warnings

    def initialize()
      @errors = []
      @warnings = []
    end

    def count()
      1
    end

    def all_errors
      @errors
    end

    def execute()
      puts to_s unless quiet?
      run if not dry_run? and runnable?
    end

    def run()
    end

    def runnable?()
      not has_errors?
    end

    def to_s
      'command'
    end

    def has_errors?()
      not @errors.empty?
    end

    def has_warnings?()
      not @warnings.empty?
    end
    
    # src file is newer than the dstination file?
    def file_modified?(src, dst)
      not File.exist? dst or File.mtime(src) > File.mtime(dst)
    end

  end
end
