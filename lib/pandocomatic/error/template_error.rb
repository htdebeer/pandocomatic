# frozen_string_literal: true

#--
# Copyright 2022, Huub de Beer <Huub@heerdebeer.org>
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
  require_relative './pandocomatic_error'

  # A TemplateError
  class TemplateError < PandocomaticError
    # Create a new PandocomaticError
    #
    # @param type [Symbol = :unknown] the type of error, defaults to :unknown
    # @param data [Object = nil] extra information attached to this
    #   TemplateError, if any; optional
    def initialize(type = :unknown, data = nil)
      super(type, nil, data)
    end

    # Represent this template error as a string.
    # @return [String]
    def to_s
      "Environment variable '#{@data[:key]}'"\
      "#{" in '#{@data[:path]}'" unless @data[:path].nil?}"\
      ' does not exist: No substitution possible.'
    end

    # The template to print this TemplateError
    def template
      'template_error.txt'
    end

    # :environment_variable_does_not_exist
  end
end
