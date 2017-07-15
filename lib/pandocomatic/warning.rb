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

    # A warning given during the conversion process.  
    class Warning

        # :skipping_link_because_it_points_outside_the_source_tree
        
        # Create a new Warning with message and some extra data
        #
        # @param message [Symbol = :unknown] the message translation key.
        # @param data [Object = nil] optional data attached to the message.
        def initialize(message = :unknown, data = nil)
            @message = message
            @data = data
        end

        # Does this Warning have any data associated with it?
        #
        # @return [Boolean] True if there is data attached, false otherwise.
        def has_data?
            not @data.nil?
        end

    end
end 
