module Pandocomatic

  require 'paru/pandoc'

  DEFAULT_CONFIG = {
        'recursive' => true,
        'follow_links' => false,
        'skip' => ['.*', 'pandocomatic.yaml'],
        'targets' => {
          'markdown' => {
            'pattern' => ['*.markdown', '*.md'],
            'pandoc' => {
              'from' => 'markdown',
              'to' => 'html5'
            }
          }
        }
      }

  FORMAT_TO_EXT = {
    'native' => 'hs',
    'markdown_strict' => 'markdown',
    'markdown_phpextra' => 'markdown',
    'markdown_github' => 'markdown',
    'html5' => 'html',
    'docx' => 'docx',
    'latex' => 'tex'
  }

  class Configuration

    def initialize hash = DEFAULT_CONFIG
      @config = {
        'recursive' => true,
        'follow_links' => false,
        'skip' => ['.*'],
        'targets' => {}
      }
      @convert_patterns = {}
      configure hash
    end

    def configure options
      options.each do |key, value|
        if key == 'targets' then
          update_targets value
        else
          @config[key] = value
        end
      end
    end

    def reconfigure options
      new_config = Marshal.load(Marshal.dump(self))
      new_config.configure options
      new_config
    end

    def marshal_dump
      [@config, @convert_patterns]
    end

    def marshal_load array
      @config, @convert_patterns = array
    end

    def update_targets targets
      targets.each do |name, options|
        @config['targets'][name] = options
        @convert_patterns[name] = options['pattern']
      end
    end

    def skip? src
      @config['skip'].any? {|pattern| File.fnmatch pattern, File.basename(src)}
    end

    def convert? src
      @convert_patterns.values.flatten.any? {|pattern| File.fnmatch pattern, File.basename(src)}
    end

    def recursive?
      @config['recursive']
    end

    def follow_links?
      @config['follow_links']
    end

    def determine_target src
      @convert_patterns.select do |target, patterns|
        patterns.any? {|pattern| File.fnmatch pattern, File.basename(src)}
      end.keys.first
    end
    
    def convert src, dst_dir
      src_suffix = File.extname src
      src_base = File.basename src, src_suffix
      target = @config['targets'][determine_target(src)]
      to = target['pandoc']['to']
      dst_suffix = if FORMAT_TO_EXT.keys.include? to then FORMAT_TO_EXT[to] else to end
      pandoc = Paru::Pandoc.new
      target['pandoc'].each do |option, value|
        pandoc.send option, value
      end
      dst = File.join dst_dir, "#{src_base}.#{dst_suffix}"
      pandoc.output dst
      pandoc << File.read(src)
    end

    def to_s 
      @config
    end

  end

end
