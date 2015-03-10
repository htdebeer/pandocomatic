module Pandocomatic

  require 'paru/pandoc'

  class Configuration

    def initialize hash = {}
      @config = {
        :recursive => true,
        :follow_links => false,
        :skip => ['.*', 'pandocomatic.yaml'],
        :targets => {
          :markdown => {
            :pattern => ['*.markdown'],
            :pandoc => {
              :from => 'markdown',
              :to => 'html5'
            }
          }
        }
      }
      @convert_patterns = {}
    end

    def reconfigure options
      options.each do |key, value|
        if key == :targets then
          update_targets value
        else
          @config[key] = value
        end
      end
    end

    def update_targets targets
      targets.each do |name, options|
        @config[:targets][name] = options
        @convert_patterns[name] = options[:pattern]
      end
    end

    def skip? src
      @config[:skip].any? {|pattern| File.fnmatch "**/#{pattern}", src}
    end

    def convert? src
      @convert_patterns.values.any? {|pattern| File.fnmatch "**/#{pattern}", src}
    end

    def recursive?
      @config[:recursive]
    end

    def follow_links?
      @config[:follow_links]
    end

    def determine_target src
      @convert_patterns.values.select {|pattern| File.fnmatch "**/#{pattern}", src}.first
    end
    
    def convert src, dst_dir
      src_suffix = File.extname src
      src_base = File.basename src, src_suffix
      target = @config[:targets][determine_target src]
      dst_suffix = target[:pandoc][:to]
      pandoc = Paru::Pandoc.new
      target[:pandoc].each do |option, value|
        pandoc.send option, value
      end
      dst = File.join dst_dir, "#{src_base}.#{dst_suffix}"
      pandoc.output dst
      pandoc << File.read(src_file)
    end

  end

end
