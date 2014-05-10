require_relative 'node'
require_relative 'pandoc'

module Pandocomatic
  module Pandoc
    module AST

      class Block < Node
      end

      class Plain < Block
      end

      class Para < Block
        def initialize(content)
          @content = content.map {|node| Pandoc.recognize node}
        end
      end


      class CodeBlock < Block
      end

      class RawBlock < Block
      end

      class BlockQuote < Block
      end

      class OrderedList < Block
      end

      class BulletList < Block
      end

      class DefinitionList < Block
      end

      class Header < Block
      end

      class HorizontalRule < Block
      end

      class Table < Block
      end

      class Div < Block
      end

    end
  end
end
