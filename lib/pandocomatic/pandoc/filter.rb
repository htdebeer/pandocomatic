module Pandocomatic
  module Pandoc

    # Implementation of Pandoc filters, see
    # https://github.com/jgm/pandocfilters for more information

    require_relative 'pandoc'

    class Filter

      def initialize &filter
        @filter = filter
      end

      def run content, from_format = :markdown, to_format = :markdown
        input = Pandoc.new do 
          from from_format
          to :json
        end

        ast = input << content
        puts ast
        filtered_ast = @filter.call ast
        puts filtered_ast

        output = Pandoc.new do
          from :json
          to to_format
        end

        output << filtered_ast
      end

    end

  end
end
