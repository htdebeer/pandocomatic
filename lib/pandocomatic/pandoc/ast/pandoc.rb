
require_relative 'node'
require_relative 'metadata'
require_relative 'block'
require_relative 'inline'

module Pandocomatic
  module Pandoc
    module AST
     
     class Pandoc

        def self.parse(doc)
          metadata = MetaData.new doc.first
          blocks = doc.last.map {|node| recognize node}

          return {metadata: metadata, blocks: blocks}
        end

        def self.recognize(data)
          type = data['t']
          content = data['c']

          begin
            classname = Object.const_get "Pandocomatic::Pandoc::AST::#{type}"
          rescue NameError
            warn "Unknown node type encountered: #{type}"
            classname = Node
          end
        
          return classname.new content
        end

     end

    end
  end
end
