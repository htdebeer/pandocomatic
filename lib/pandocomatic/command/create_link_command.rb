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

  require_relative 'command.rb'

  require_relative '../warning.rb'
  require_relative '../error/io_error.rb'
  require_relative '../printer/warning_printer.rb'

  class CreateLinkCommand < Command

    attr_reader :src, :dst, :dst_target

    def initialize(src, dst)
      super()
      @src = src
      begin
        src_target = File.readlink @src

        if src_target.start_with? '.' then
          full_src_target = File.expand_path src_target, File.dirname(src)

          if full_src_target.start_with? src_root()
            @dst = dst
            @dst_target = src_target
          else
            WarningPrinter.new(Warning.new(:skipping_link_because_it_points_outside_the_source_tree, @src)).print
          end
        end
      rescue StandardError => e
        @errors.push IOError.new(:unable_to_read_symbolic_link, e, @src)
      end
    end

    def run()
      begin
        File.symlink @dst_target, @dst unless File.exist? @dst
      rescue StandardError => e
        raise IOError.new(:unable_to_create_symbolic_link, e, [@src, @dst])
      end
    end

    def runnable?
      not (has_errors? or @dst.nil? or @dst_target.nil? or @src.nil?)
    end

    def to_s
      "link #{File.basename @dst} → #{@dst_target}"
    end

  end
end
