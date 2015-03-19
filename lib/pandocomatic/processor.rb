module Pandocomatic

    require 'open3'

    class Processor

        def self.run script, input
            output, status = Open3.capture2(script, :stdin_data => input)
            output
        end

    end
end
