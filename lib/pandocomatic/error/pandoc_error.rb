# frozen_string_literal: true

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
  require_relative 'pandocomatic_error'

  # An error when running pandoc
  class PandocError < PandocomaticError
    # The template to use to print this PandocError
    def template
      'pandoc_error.txt'
    end

    # :error_running_pandoc
  end
end
