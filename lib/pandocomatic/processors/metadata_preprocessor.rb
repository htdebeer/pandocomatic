# frozen_string_literal: true

#--
# Copyright 2017—2024, Huub de Beer <Huub@heerdebeer.org>
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
  require 'yaml'
  require_relative '../processor'

  # MetadataPreprocessor mixes in the metadata section of a template into a
  # document before pandoc is run to convert that document. It is a default
  # preprocessor.
  class MetadataPreprocessor < Processor
    # Run this MetadataPreprocessor
    #
    # @param input [String] the contents of the document that is being
    #   preprocessed
    # @param metadata [Hash = {}] the metadata to mix-in
    def self.run(input, metadata = {})
      yaml = YAML.dump(metadata)
      Pandocomatic::LOG.debug '     | MetadataPreprocessor. Adding mined YAML blocks to metadata:' \
        "#{Pandocomatic::LOG.indent(
          yaml.sub('---', ''), 37
        )}"
      "#{input}\n\n#{yaml}...\n\n"
    end
  end
end
