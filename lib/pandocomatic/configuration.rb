module Pandocomatic

    require 'yaml'
    require 'paru/pandoc'

    DEFAULT_CONFIG = YAML.load_file File.join(__dir__, 'default_configuration.yaml')

    FORMAT_TO_EXT = {
        'native' => 'hs',
        'markdown_strict' => 'markdown',
        'markdown_phpextra' => 'markdown',
        'markdown_github' => 'markdown',
        'html5' => 'html',
        'docx' => 'docx',
        'latex' => 'tex'
    }

    ASSET_MAP = {
        'template' => 'pandoc-template-dir',
        'filter' => 'pandoc-filter-dir',
        'preprocessors' => 'preprocessor-dir',
        'postprocessors' => 'postprocessor-dir'
    }

    class Configuration

        def initialize settings = DEFAULT_CONFIG
            if settings.class == Hash then
                @config_dir = Dir.pwd
            else
                # settings points to a yaml file containing the settings
                begin
                    filename = settings
                    path = File.absolute_path filename
                    @config_dir = File.dirname path
                    settings = YAML.load_file path
                rescue Exception => e
                    raise "Unable to load configuration file #{settings}: #{e.message}"
                end
            end
            @settings = {'skip' => ['.*']} # hidden files will always be skipped
            @templates = {}
            @convert_patterns = {}
            configure settings
        end

        def configure settings
            reset_settings settings['settings'] if settings.has_key? 'settings'
            if settings.has_key? 'templates' then
                settings['templates'].each do |name, template|
                    reset_template name, template
                end
            end
        end

        def reconfigure filename
            begin
                path = File.absolute_path filename
                @config_dir = File.dirname path
                settings = YAML.load_file filename
                new_config = Marshal.load(Marshal.dump(self))
                new_config.configure settings
                new_config
            rescue Exception => e
                raise "Unable to load configuration file #{filename}: #{e.message}"
            end
        end

        def marshal_dump
            [@config_dir, @settings, @templates, @convert_patterns]
        end

        def marshal_load array
            @config_dir, @settings, @templates, @convert_patterns = array
        end


        def skip? src
            if @settings.has_key? 'skip' then
                @settings['skip'].any? {|glob| File.fnmatch glob, File.basename(src)}
            else
                false
            end
        end

        def convert? src
            @convert_patterns.values.flatten.any? {|glob| File.fnmatch glob, File.basename(src)}
        end

        def recursive?
            @settings['recursive']
        end

        def follow_links?
            @settings['follow_links']
        end

        def set_extension dst
            dir = File.dirname dst
            ext = File.extname dst
            basename = File.basename dst, ext
            File.join dir, "#{basename}.#{find_extension dst}"
        end

        def find_extension dst
            template = determine_template dst
            if template.nil? then
                extension = 'html'
            else
                to = @templates[template]['pandoc']['to']
                extension = FORMAT_TO_EXT[to] || to
            end
        end

        def get_template_config template_name
            @templates[template_name]
        end

        def determine_template src
            @convert_patterns.select do |template_name, globs|
                globs.any? {|glob| File.fnmatch glob, File.basename(src)}
            end.keys.first
        end

        def update_path asset, template_asset

            if template_asset.start_with? './' then
                template_asset
            else
                File.join @settings[ASSET_MAP[asset]], template_asset
            end
        end

        def to_s 
            marshal_dump
        end

        private 

        def reset_settings settings
            settings.each do |setting, value|
                if setting == 'skip' then
                    @settings[setting].merge value
                else
                    if ASSET_MAP.values.include? setting then
                        if value.start_with? '/' then
                            # absolute path, keep
                            @settings[setting] = value
                        else
                            # relative path (wrt config file), convert to
                            # absolute path
                            @settings[setting] = File.join @config_dir, value
                        end
                    else
                        @settings[setting] = value
                    end
                end
            end
        end

        def reset_template name, template
            if @templates.has_key? name then
                @templates[name].merge! template
            else
                @templates[name] = template
            end
            if template.has_key? 'glob' then
                @convert_patterns[name] = template['glob']
            end
        end


    end

end
