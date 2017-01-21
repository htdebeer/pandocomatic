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
  require_relative './pandocomatic_error.rb'

  class ConfigurationError < PandocomaticError

    TYPES = [
      :data_dir_does_not_exist,
      :data_dir_is_not_a_directory,
      :data_dir_is_not_readable,

      :config_file_does_not_exist,
      :config_file_is_not_a_file,
      :config_file_is_not_readable,
      :unable_to_load_config_file
    ]
    
    TYPES.each do |type|
      const_set type.to_s.upcase, type
    end

    attr_reader :type

    def initialize(type, option = '', error = nil)
      @type = type
      @option = option
      @error = error
      super type.to_s
    end

    def has_error?
      not @error.nil?
    end

  end
end 
