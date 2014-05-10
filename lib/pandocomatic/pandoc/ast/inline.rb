require_relative 'node'
require_relative 'pandoc'

module Pandocomatic
  module Pandoc
    module AST

      class Inline < Node
        
      end

      class Str < Inline
        def initialize(content)
          @content = content
        end
      end

      class Emph < Inline
        def initialize(content)
          @content = content.map {|node| Pandoc.recognize node}
        end
      end



    end
  end
end
