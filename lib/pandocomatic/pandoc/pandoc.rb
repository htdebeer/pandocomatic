
require 'json'
require_relative 'ast/pandoc'

module Pandocomatic
  module Pandoc
    class Pandoc
      def initialize()
      end

      def read(input, type = :markdown)
        output = ''

        IO.popen("pandoc -t json", "r+") do |p|
          p << input
          p.close_write
          output <<  p.read
        end

        ast = JSON.parse output
        return AST::Pandoc::parse ast
      end

      def write(type = :html)
      end

    end
  end
end
