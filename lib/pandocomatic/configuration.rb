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
    
    def set_extension dst
      dir = File.dirname dst
      ext = File.extname dst
      basename = File.basename dst, ext
      File.join dir, "#{basename}.#{find_extension dst}"
    end

    def find_extension dst
      target = determine_target dst
      if target.nil? then
        extension = 'html'
      else
        to = @config['targets'][target]['pandoc']['to']
        extension = FORMAT_TO_EXT[to] || to
      end
    end

    
    def get_target_config target
      @config['targets'][target]
    end

    def determine_target src
      @convert_patterns.select do |target, patterns|
        patterns.any? {|pattern| File.fnmatch pattern, File.basename(src)}
      end.keys.first
    end

    def to_s 
      @config
    end

  end

end
