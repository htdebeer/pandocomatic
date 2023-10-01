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

  # An IOError
  class IOError < PandocomaticError
    # The template to use when printing this IOError
    def template
      'io_error.txt'
    end

    # :file_does_not_exist file
    # :file_is_not_a_file file
    # :file_is_not_readable file
    # :file_is_not_writable file

    # :error_opening_file file
    # :error_writing_file file

    # :directory_does_not_exist dir
    # :directory_is_not_a_directory dir
    # :directory_is_not_readable dir
    # :directory_is_not_writable dir

    # :error_opening_directory dir
    # :error_creating_directory dir

    # :file_or_directory_does_not_exist src
    # :unable_to_copy_file [src, dst]
    # :unable_to_create_symbolic_link [src, dst]
    # :unable_to_read_symbolic_link [src]
  end
end
