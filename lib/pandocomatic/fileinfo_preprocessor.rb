module Pandocomatic
    class FileInfoPreprocessor < Processor
        def self.run input, path
            created_at = File.stat(path).ctime
            modified_at = File.stat(path).mtime
            output = input
            output << "\n---\n"
            output << "fileinfo:\n"
            output << "  path: '#{path}'\n"
            output << "  created: #{created_at.strftime '%Y-%m-%d'}\n"
            output << "  modified: #{modified_at.strftime '%Y-%m-%d'}\n"
            output << "..."
            output
        end
    end
end
