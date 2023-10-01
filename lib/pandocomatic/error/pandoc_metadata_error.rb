# frozen_string_literal: true

#--
# Copyright 2023 Huub de Beer <Huub@heerdebeer.org>
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

  # A PandocMetadataError
  class PandocMetadataError < PandocomaticError
    # The template to print this ConfigurationError
    def template
      'pandoc_metadata_error.txt'
    end

    # :file_contains_horizontal_lines_with_three_dashes
    # :cannot_parse_YAML_metadata
  end
end
