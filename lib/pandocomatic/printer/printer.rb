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
  require 'erb'

  class Printer
    def initialize(template_file = 'help.txt')
      dir = File.dirname(__FILE__)
      @template = File.absolute_path(File.join(dir, 'views', template_file))
    end

    def to_s
      erb = ERB.new(File.read(@template))
      erb.result(binding())
    end

    def print
      puts to_s()
    end

  end
end
